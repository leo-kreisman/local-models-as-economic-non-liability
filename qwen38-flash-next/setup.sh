#!/usr/bin/env bash
# setup.sh — build llama.cpp (master, qwen4exp) for sm_120 and fetch a Qwen3.8-Flash-Next GGUF.
#
#   ./setup.sh build          clone + compile llama.cpp
#   ./setup.sh download       fetch + verify the GGUF
#   ./setup.sh all            both
#
# Overridable:
#   ROOT        install root            (default: /mnt/models)  <-- MUST be the NVMe
#   SRC         llama.cpp checkout      (default: $HOME/src/llama.cpp)
#   HF_REPO     GGUF repo               (default: ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF)
#   HF_REV      pinned revision         (default: c67535ccaa71f61547bb323a2828d5298221d83e)
#   HF_INCLUDE  file globs              (default: '*IQ3_XXS*' '*mmproj*')
#   CUDA_ARCH   sm target               (default: 120  -- NOT 121, that is GB10-only)
#   JOBS        build parallelism       (default: 6)
set -euo pipefail

ROOT="${ROOT:-/mnt/models}"
SRC="${SRC:-$HOME/src/llama.cpp}"
HF_REPO="${HF_REPO:-ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF}"
HF_REV="${HF_REV:-c67535ccaa71f61547bb323a2828d5298221d83e}"
HF_INCLUDE="${HF_INCLUDE:-*IQ3_XXS* *mmproj*}"
CUDA_ARCH="${CUDA_ARCH:-120}"
JOBS="${JOBS:-6}"
MODEL_DIR="$ROOT/Qwen3.8-Flash-Next"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

preflight() {
  command -v git   >/dev/null || die "git missing"
  command -v cmake >/dev/null || die "cmake missing (apt install cmake)"
  for d in "${CUDA_HOME:-}" /usr/local/cuda-13.0 /usr/local/cuda-12.8 /usr/local/cuda; do
    [ -n "$d" ] && [ -x "$d/bin/nvcc" ] && { export CUDA_HOME="$d"; export PATH="$d/bin:$PATH"; break; }
  done
  command -v nvcc >/dev/null || die "nvcc missing — install the CUDA toolkit"

  log "nvcc: $(nvcc --version | tail -1)"
  log "gpus: $(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader | paste -sd' | ')"

  # The technique depends on NVMe latency. Refuse to put a 76 GB model on a SATA SSD or HDD.
  local dev
  dev="$(df --output=source "$ROOT" 2>/dev/null | tail -1 || true)"
  if [ -n "$dev" ] && [[ "$dev" != *nvme* ]]; then
    die "$ROOT resolves to $dev, which is not NVMe. The PLE table is served by
       random 4K reads — put it on the NVMe. See section 0 of SETUP.md."
  fi

  local avail_gib
  avail_gib=$(df -BG --output=avail "$ROOT" 2>/dev/null | tail -1 | tr -dc '0-9' || echo 0)
  [ "${avail_gib:-0}" -lt 90 ] && cat <<EOF
WARNING: only ${avail_gib} GiB free on $ROOT. You need ~80 GiB for the model + ~10 GiB build/scratch.
         See section 0 of SETUP.md (there is ~1.9 TB unallocated on nvme0n1).
EOF

  if [ "$(awk 'NR>1' /proc/swaps 2>/dev/null | wc -l)" -gt 0 ]; then
    echo "NOTE: swap is active ($(awk 'NR>1{u+=$4} END{printf "%.1f", u/1048576}' /proc/swaps) GiB in use)."
    echo "      Run 'sudo swapoff -a' before serving — resident weights must never page out,"
    echo "      only cold n-gram pages should evict from the page cache."
  fi
  return 0
}

build() {
  mkdir -p "$(dirname "$SRC")"
  if [ ! -d "$SRC/.git" ]; then
    log "cloning llama.cpp"
    git clone https://github.com/ggml-org/llama.cpp.git "$SRC"
  fi
  log "fetching master (qwen4exp merged 2026-08-27 via PR #27742 — no patches needed)"
  git -C "$SRC" fetch origin master --force
  git -C "$SRC" checkout -q FETCH_HEAD
  log "at $(git -C "$SRC" log --oneline -1)"

  cmake -S "$SRC" -B "$SRC/build" \
    -DGGML_CUDA=ON \
    -DCMAKE_CUDA_ARCHITECTURES="$CUDA_ARCH" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLAMA_BUILD_SERVER=ON \
    -DGGML_NATIVE=ON

  log "compiling (-j$JOBS) — this is the slow part"
  cmake --build "$SRC/build" --config Release -j"$JOBS" --target llama-server llama-cli llama-bench

  "$SRC/build/bin/llama-server" --version || true
  log "built: $SRC/build/bin/llama-server"
}

download() {
  mkdir -p "$MODEL_DIR"
  local hf
  if command -v hf >/dev/null 2>&1; then hf=hf
  elif command -v huggingface-cli >/dev/null 2>&1; then hf=huggingface-cli
  else die "install the hub client:  pip install -U 'huggingface_hub[cli]'"; fi

  log "dry-run: what would download from $HF_REPO@${HF_REV:0:8}"
  $hf download "$HF_REPO" --revision "$HF_REV" --local-dir "$MODEL_DIR" --dry-run 2>/dev/null || true
  cat <<'EOF'

  Confirm the filenames above match HF_INCLUDE (default '*IQ3_XXS*' '*mmproj*').
  If the quant you want has different names, re-run with:
      HF_INCLUDE='*Q2_K_XL*' ./setup.sh download
  Sizes (for planning):  IQ3_XXS 75.8 GB | UD-Q2_K_XL 78.9 GB | UD-Q3_K_XL 90 GB | UD-Q4_K_XL 103.7 GB
EOF

  # Split the patterns ourselves with globbing off, so '*IQ3_XXS*' is not
  # expanded against whatever happens to be in the current directory.
  local -a inc=()
  set -f
  for g in $HF_INCLUDE; do inc+=(--include "$g"); done
  set +f

  $hf download "$HF_REPO" \
    --revision "$HF_REV" \
    --local-dir "$MODEL_DIR" \
    "${inc[@]}"

  log "downloaded into $MODEL_DIR:"
  ls -lh "$MODEL_DIR"
  log "verify SHA-256 against the repo manifest (manifests/gsq-iq3xxs.json upstream) — do not skip"
}

case "${1:-all}" in
  build)    preflight; build ;;
  download) preflight; download ;;
  all)      preflight; build; download ;;
  *) die "usage: $0 [build|download|all]" ;;
esac
