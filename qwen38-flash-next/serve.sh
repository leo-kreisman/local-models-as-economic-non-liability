#!/usr/bin/env bash
# serve.sh — launch Qwen3.8-Flash-Next with the 51B n-gram (PLE) table left on NVMe.
#
#   ./serve.sh                 start the server (foreground)
#   N_CPU_MOE=8 ./serve.sh     fewer experts on CPU (more VRAM needed, faster decode)
#   CTX=8192 ./serve.sh        smaller context if you are short on RAM
#
# THE ONE IDEA: `-ot per_layer_token_embd=CPU` pins the 51B lookup table to the CPU
# backend, and mmap serves its pages from NVMe on demand. It is a pure row gather
# (~16 rows out of 320,001,536 per token), so it is nearly free on disk. That removes
# ~27 GiB from the resident budget and is the only reason a 96 GB machine is viable.
#
# TUNING `N_CPU_MOE` (the only knob that matters):
#   VRAM budget here is ~30 GiB (2x16 minus desktop). All non-expert weights go to GPU;
#   experts are split. Start at 0 and raise until the server starts without OOM, then
#   add 2 and confirm it still starts. Watch with:
#       nvidia-smi dmon -s mu
#       grep -E 'offloaded|buffer size' server.log
set -euo pipefail

ROOT="${ROOT:-/mnt/models}"
LLAMA_BIN="${LLAMA_BIN:-$HOME/src/llama.cpp/build/bin/llama-server}"
MODEL_DIR="${MODEL_DIR:-$ROOT/Qwen3.8-Flash-Next}"

# Point at the FIRST shard; llama.cpp follows the shard split itself.
MODEL="${MODEL:-$(ls "$MODEL_DIR"/*00001-of-*.gguf 2>/dev/null | head -1 || true)}"
if [ -z "$MODEL" ]; then
  MODEL="$(ls "$MODEL_DIR"/*.gguf 2>/dev/null | grep -vi mmproj | head -1 || true)"
fi
# Optional vision projector; empty string means text-only.
MMPROJ="${MMPROJ:-$(ls "$MODEL_DIR"/mmproj*.gguf 2>/dev/null | head -1 || true)}"

CTX="${CTX:-32768}"          # 24 KB/token f16 KV -> 32K = 0.8 GiB, 64K = 1.5 GiB, 262K = 6 GiB
N_CPU_MOE="${N_CPU_MOE:-0}"  # experts pushed to system RAM. Raise this until VRAM fits.
PORT="${PORT:-8000}"
ALIAS="${ALIAS:-qwen3.8-flash-next}"
LOG="${LOG:-$PWD/server.log}"

[ -x "$LLAMA_BIN" ] || { echo "ERROR: $LLAMA_BIN not found — run ./setup.sh build"; exit 1; }
if [ -z "$MODEL" ] || [ ! -f "$MODEL" ]; then
  echo "ERROR: no GGUF found in $MODEL_DIR — run ./setup.sh download"; exit 1
fi

if [ "$(awk 'NR>1' /proc/swaps 2>/dev/null | wc -l)" -gt 0 ]; then
  echo "WARNING: swap is on. 'sudo swapoff -a' first, or resident weights will page out and thrash."
fi

# ---------------------------------------------------------------------------
# The trick: pin the PLE table to CPU and let mmap page it in from NVMe.
# ---------------------------------------------------------------------------
ARGS=(
  -m "$MODEL"
  --alias "$ALIAS"
  -ot "per_layer_token_embd=CPU"
  --load-mode mmap

  # ---- device placement -------------------------------------------------
  --n-gpu-layers 999
  --n-cpu-moe "$N_CPU_MOE"
  --split-mode layer          # no P2P on this box (topo: PHB); layer beats tensor
  --tensor-split 1,1

  # ---- context ----------------------------------------------------------
  --ctx-size "$CTX"
  --parallel 1                # REQUIRED: a 2nd in-flight request aborts (qwen4exp.cpp:284)
  --batch-size 2048
  --ubatch-size 512
  --flash-attn on
  --cache-type-k f16          # KV MUST stay f16: quantized KV aborts (qwen4exp.cpp:544)
  --cache-type-v f16

  # ---- throughput -------------------------------------------------------
  # ngram-mod speculates from your own prompt: ~3x on file-rewrite work, ~1x on prose.
  # Do NOT raise n_max past the default 3 -- deeper drafts union the MoE experts across
  # positions and collapse decode to 14-18 t/s (measured upstream).
  --spec-type ngram-mod

  # ---- server behaviour (upstream-measured profile) ---------------------
  --no-kv-unified
  --cache-prompt
  --cache-reuse 0
  --slot-prompt-similarity 0.10
  --cache-ram 0
  --no-cache-idle-slots
  --no-context-shift
  --fit off                   # --fit crashes: LLM_ARCH_QWEN4EXP missing from graph_max_nodes
  --jinja
  --chat-template-kwargs '{"enable_thinking":true,"reasoning_effort":"low"}'
  --temp 1.0 --top-p 0.95 --top-k 20
  --host 0.0.0.0 --port "$PORT"
)

# Vision projector is optional; omit the flag entirely when absent.
if [ -n "$MMPROJ" ]; then ARGS+=(--mmproj "$MMPROJ"); fi

cat <<EOF
model  : $MODEL
mmproj : ${MMPROJ:-<none: text only>}
ctx    : $CTX    n-cpu-moe: $N_CPU_MOE    port: $PORT
log    : $LOG
EOF
echo

set -x
exec "$LLAMA_BIN" "${ARGS[@]}" 2>&1 | tee "$LOG"
