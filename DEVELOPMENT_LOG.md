# Development Log

## Session Handoff — 2026-09-24 16:15 -03

**Goal:** Repair the broken OpenAI Codex CLI install after upgrading `@openai/codex` 0.114.0 → 0.156.1 and the resulting `codex: No such file or directory` + TUI bootstrap 401.

**Failed Paths:**
- Assumed the installer had left a broken/half-removed install. It had not — the standalone install was intact and consistent.
- Assumed the `bash: /home/scribe/.nvm/versions/node/v24.14.0/bin/codex: No such file or directory` error meant a missing binary. It was a **stale bash command-hash entry** left over from the npm install that `npm uninstall -g` had just removed. Bash kept resolving the old hashed absolute path instead of re-searching `$PATH`.
- Assumed the 401 was an install/version mismatch between npm 0.114.0 and standalone 0.156.1. Version was irrelevant.

**Final Solution:**
Two independent faults, only one of which was a real breakage.

1. *Launcher (cosmetic, already self-resolved).* The `npm install -g` → standalone migration is correct:
   - `~/.local/bin/codex` → `~/.codex/packages/standalone/current/bin/codex`
   - `current` → `releases/0.156.1-x86_64-unknown-linux-musl`
   - `.bashrc:157` exports `PATH="/home/scribe/.local/bin:$PATH"`
   - `codex --version` → `codex-cli 0.156.1`; `codex doctor` → `✓ install consistent`, `✓ runtime`, `✓ disk`.
   The error only ever appeared in the *old* shell whose hash table still pointed at the deleted nvm path. Fix is `hash -r` (or open a new terminal). No files needed changing.

2. *Auth (the actual breakage).* `~/.codex/auth.json` has `auth_mode: "chatgpt"` but its OAuth tokens are dead:
   - `id_token` expired 2026-03-13, `access_token` expired 2026-03-23 — six months stale (`auth.json` mtime Mar 12 2026).
   - `refresh_token` no longer refreshes, so no silent recovery; the server answers `workspace routing discovery unauthorized (401)`.
   - Note `codex login status` still reports "Logged in using ChatGPT" — it does **not** validate expiry, so it is misleading here. Check token `exp` claims instead.
   - A separate `OPENAI_API_KEY` in the environment (len 164) **is** valid (HTTP 200 against `/v1/models`).

**Follow-up — Astra / model access (asked same session):**
- User expected their new plan to unlock "Astra". Clarified: **model entitlement is decided server-side; a local reinstall neither grants nor revokes it.**
- Evidence gathered:
  - `grep -a` on the 0.156.1 binary finds the slugs compiled in: `gpt-6-astra` (23 hits, plus `openai.gpt-6-astra`), `gpt-5.6-terra`, `gpt-5.6-luna`, `gpt-5.6-sol`. So the **new client knows Astra**; the old npm 0.114.0 client would not have offered it.
  - `~/.codex/models_cache.json` is stale — `client_version: 0.114.0`, `fetched_at: 2026-03-20`, 12 models, **no astra entry**. It refreshes only after a successful auth.
- Therefore the sequence is: `hash -r` → `codex login` → `/model` re-fetches the list against the account. Only then is the answer about Astra meaningful.
- Verification limit: no working credential existed to query entitlements with, so **whether the plan actually includes Astra could not be confirmed from this machine.** If it is absent after a successful login, it is an OpenAI account/plan matter, not local.

**Unresolved (next session):**
- User chose **browser re-login**, which is interactive and must be run by the user:
  ```
  codex logout && codex login
  ```
  Then confirm with `codex login status` and launch the TUI. If the 401 persists after a successful login, the cause is upstream account state (ChatGPT workspace/plan not entitled to Codex), not the local machine.
- Falling back to the API key is available but not chosen, because it changes billing from subscription quota to per-token: `printenv OPENAI_API_KEY | codex login --with-api-key`.
- `codex doctor` flags one benign warning: `⚠ websocket  Responses WebSocket failed; HTTPS fallback may still work`. Not investigated; suspected proxy/VPN/firewall WebSocket policy. Worth revisiting only if streaming misbehaves.
- `~/.codex/config.toml` pins `model = "gpt-5.4"`, `model_reasoning_effort = "high"` — confirmed valid, untouched.

**Reusable gotchas:**
- After any global package manager uninstall/swap, run `hash -r`; a cached hash outlives the file and mimics a broken install.
- `codex login status` is not an expiry check.
- Duplicate `~/.local/bin` entries in `.bashrc` (lines 142 and 157) are harmless but redundant.

---

## Session Handoff — 2026-10-01 00:30 -03

**Goal:** Find the best approach for running Qwen3.8-Flash-Next locally on this workstation, offloading to SSD while using RAM + VRAM. Deliver a runnable setup.

**Failed Paths:**
- First assumption was that "SSD offload" meant streaming the **MoE expert weights** from disk (llama.cpp PR #25294, `--moe-stream-*`). Wrong: that PR is unmerged, and it **auto-disables mmap** — which kills the technique that actually matters.
- Second wrong assumption: that `--tensor-read-lazy` (PR #27794, merged) was the SSD lever. Wrong: it is scoped to PLE/engram tables only; the author explicitly said expert tensors must *not* be marked `TENSOR_READ_LAZY`.
- Assumed the target machine was a DGX Spark like every published recipe. It is not — that changes almost every conclusion (see below).
- Backtick-"comments" inside a line-continued `exec` command in the first draft of `serve.sh` were a quoting hazard; rewrote using a bash array.

**Final Solution:**
The model is **not** a dense 180B. It decomposes into 128.8B MoE compute weights (6B active) + a **51.2B n-gram/PLE lookup table** (`per_layer_token_embd.weight`) + a 4B MTP head. At UD-Q4_K_XL the file is 103.7 GiB, of which **26.8 GiB is the PLE table**.

The trick ("0xBakeer"), and the entire answer to the SSD-offload question:

```bash
-ot "per_layer_token_embd=CPU"   # pin the 51B table to the CPU backend, never copy to GPU
--load-mode mmap                 # serve its pages from NVMe on demand
```

It works because the table is a **pure row gather** (~16 rows out of 320,001,536 per token, addressed deterministically by a 3-gram hash) — never a matmul. A matmul weight read in full every token collapses to disk bandwidth; a sparse gather does not. That removes 26.8 GiB from the resident budget.

Host spec discovered: **i7-8700K / 62.7 GiB DDR4 / 2× RTX 5060 Ti 16 GB @ PCIe 3.0 x8, topo `PHB` (no P2P) / 3.6 TB Kingston NVMe**. Budget ≈ 30 GiB usable VRAM + 54 GiB RAM = **~84 GiB resident**. So the requirement is `file_size − PLE_size ≤ 84 GiB` → Q4_K_XL (compute ~77 GiB) does not fit; **ISTA-DASLab GSQ-RCO IQ3_XXS (75.84 GB)** is the recommended start.

Key deltas vs the published DGX Spark numbers: discrete GPUs over PCIe 3.0 x8 with no P2P → use `--split-mode layer`, not tensor; DDR4 at ~41 GB/s is the real bottleneck. Build for **sm_120**, not the DGX's sm_121.

Also established: upstream `qwen4exp` (PR #27742) **merged to master 2026-08-27**, so the DGX patch set is now redundant — build master. Hard constraints: `--parallel 1` required; KV must stay f16 (quantized KV aborts); `--fit` crashes; Flash-Next GGUF ships no MTP tensors so use `--spec-type ngram-mod`.

**Deliverables:** `qwen38-flash-next/{SETUP.md,setup.sh,serve.sh,bench.sh}` — all three scripts pass `bash -n`, and `serve.sh` argv was verified by stubbing `LLAMA_BIN=/bin/echo`.

**Unresolved (next session):**
- **BLOCKER: disk.** `/home` has 48 GB free (97% full), `/` has 27 GB. The model needs 75–105 GB. But `nvme0n1` is 3.6 TB with only ~1.71 TB partitioned — **~1.9 TB unallocated**. Must carve a partition + mount before anything. Not yet done.
- **Swap is on and 11 GiB of the 16 GiB zram is in use.** Upstream is explicit that resident weights must never page out. `sudo swapoff -a` before serving; the pre-existing memory pressure is unexplained and worth investigating separately.
- `N_CPU_MOE` default is set to 0 with instructions to raise it; the actual tuned value for this box is unmeasured. Expect roughly 8–20 t/s decode / 150–400 t/s prefill, not the 19–88 t/s GB10 figures — but this is an estimate, not a measurement.
- Exact GGUF filenames in `ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF` were never confirmed (`setup.sh` does a `--dry-run` first and the `HF_INCLUDE` glob may need adjusting).
- Nothing was executed: no build, no download, no serve. All four files are untested against a real model.

**Reusable gotchas:**
- For MoE, **"N B active" is a speed property, not a memory property** — all N-hundred-B params must still be stored somewhere.
- On this model the config is **overhead-bound, not bandwidth-bound**: upstream measured Q3_K_XL (90 GB) as *14% slower* than Q4_K_XL (111 GB). But the **IQ** series behaves oppositely (IQ1_S 33 t/s vs IQ4_XS 27 t/s). Prefer IQ over K-quants for small builds.
- Do not raise ngram `n_max` past the default 3 — deeper drafts union the MoE experts across positions and drop decode to 14–18 t/s.
- `cudaHostRegister`/pageable-copy pathologies documented for GB10 are unified-memory artifacts; they do not transfer to discrete-PCIe rigs.

---

## Session Handoff — 2026-10-08 21:00 -03

**Goal:** Answer "with a good harness, how much juice can I extract from FrogNano 4B for professional coding?" (follow-on from the earlier FrogNano-vs-MiniCPM viability question.)

**Failed Paths:**
- Searched for a FrogNano ↔ Cline / Roo Code / Continue integration. **None exists.** FrogNano is a research report, not a shipped product; Leaf is a benchmark harness, not a plugin. Anyone using it locally wires it up themselves.
- Initially conflated the headline 61.5% with model capability. It is a Leaf-harness number, and the paper's own ablation shows the harness is worth ~29 points to a 4B model.

**Final Solution / findings:**
- **Harness gains transfer.** FrogNano in mini-SWE-agent (single `bash` tool, unseen harness): 43.8% (base) → **56.4%**, only 5.2 below Leaf's 61.5%. Budget discipline transfers too (87.1 vs 100.5 turns; turn-cap 9.8% vs 31.6%).
- **Harness is a 4B-specific lever.** Base Qwen3.5-4B went 8.3% (R2E-Gym) → 37.2% (Leaf). MiniMax-M2.5 is unchanged across harnesses (66.5% both). Don't expect harness swaps to move a large model.
- **The real ceiling is reasoning, not interface.** 90.8% of failures are reasoning gaps vs 7% premature termination; 24.8% of attempts introduce a regression. Within the largest failure class: wrong root cause 38.8%, misread spec 31.5%, API misunderstanding 14.1%.
- **Capability is real, not distilled.** Pass@8 gap vs base stays constant as k rises.
- **Cheapest real gain:** 3-candidate round-robin verifier → 62.8% pass@1 (vs 61.4% single verifier, 61.53% random).
- **Known limits:** only 1.71% parallel tool calls; multi-tool use collapsed 32% → 0.16% by iteration 3. MindStudio hands-on: strong Python/backend, failed HTML/JS front-end.
- **Caveats:** Pith flags 61.5% as contaminated (SWE-bench Verified also served as the training-time validation set) and cites an Appendix G reward-hacking case against the "0 effective hacks" claim. Model card says quantized formats and CPU-only serving are **unvalidated**.

**Unresolved:** nothing actionable locally — no FrogNano weights were downloaded, and there is no harness to install. Revisit only if the user wants an actual local wiring (SGLang `--reasoning-parser qwen3 --tool-call-parser qwen3_coder` + a Leaf-shaped 5-tool client).


## 2026-10-16 — Pesquisa e publicação integral

Atualizados relatório, proposta e apresentação com integração de Oh My Pi, OpenCode, Claude Code, Codex CLI, Copilot CLI e VS Code com modelos locais; limitações de segurança e controles por plataforma, com documentação primária. Relatório HTML com 199 referências e apresentação com 16 slides. Verificação de desktop/celular, âncoras, imagens, calculadora e navegação concluída sem erros JavaScript ou requisições HTTP durante leitura. Publicação solicitada no repositório leo-kreisman/local-models-as-economic-non-liability. Mantidos scripts e artefatos anteriores.
