#!/usr/bin/env bash
# bench.sh — measure the running server on the two task shapes that actually differ.
#
#   ./bench.sh
#   PORT=8000 ALIAS=qwen3.8-flash-next ./bench.sh
#
# Why two shapes: upstream measurements show the SAME box produces both ~88 t/s and
# ~28 t/s on the same afternoon. ngram-mod speculates from your prompt, so a
# file-rewrite (answer is already in the question) accelerates ~3x, while free-form
# prose falls back to the honest unaccelerated rate. Any single "tok/s" is meaningless
# without the task attached.
set -euo pipefail

PORT="${PORT:-8000}"
ALIAS="${ALIAS:-qwen3.8-flash-next}"
BASE="http://127.0.0.1:$PORT"

command -v curl >/dev/null || { echo "curl missing"; exit 1; }
curl -sf "$BASE/health" >/dev/null || { echo "ERROR: no server on $BASE"; exit 1; }

run() { # $1 = label, $2 = prompt, $3 = max_tokens
  local label="$1" prompt="$2" n="$3" body out
  body=$(printf '%s' "$prompt" | python3 -c 'import json,sys; print(json.dumps({"model":sys.argv[1],"prompt":sys.stdin.read(),"max_tokens":int(sys.argv[2]),"temperature":0,"stream":False}))' "$ALIAS" "$n")
  out=$(curl -sf "$BASE/v1/completions" -H 'Content-Type: application/json' -d "$body")
  printf '%s' "$out" | python3 -c '
import json,sys
r=json.load(sys.stdin); t=r.get("timings") or {}
g=t.get("predicted_per_second"); p=t.get("prompt_per_second"); n=t.get("predicted_n")
print(f"  {sys.argv[1]:<34} decode {g:6.1f} t/s   prefill {p:8.1f} t/s   ({n} tok)" if g else f"  {sys.argv[1]}: no timings in response")
' "$label"
}

echo "== smoke =="
body=$(python3 -c 'import json;print(json.dumps({"model":"'"$ALIAS"'","messages":[{"role":"user","content":"Reply with exactly: OK"}],"max_tokens":8,"temperature":0}))')
curl -sf "$BASE/v1/chat/completions" -H 'Content-Type: application/json' -d "$body" \
  | python3 -c 'import json,sys; print("  ->", json.load(sys.stdin)["choices"][0]["message"]["content"].strip())'

echo
echo "== decode throughput =="
# Shape A: copy-heavy — the answer is sitting in the prompt. Spec decode shines.
run "rewrite-file (spec-friendly)" \
"Here is a Python file. Change every occurrence of 'foo' to 'bar' and return the whole file unchanged otherwise.\n\n$(seq 1 400 | sed 's/^/value_/; s/$/ = foo /' | paste -sd'\n')" 256

# Shape B: free-form — nothing to copy, spec decode cannot help.
run "free-form prose" \
"Write a short essay about why latency matters more than throughput for interactive coding agents." 256

echo
echo "Context: KV is 24 KB/token f16. CTX=32768 costs 0.8 GiB; 262144 costs 6 GiB."
echo "If decode is far below ~8 t/s, lower N_CPU_MOE (push experts to VRAM) or"
echo "lower CTX. If it OOMs, raise N_CPU_MOE. See SETUP.md section 4."
