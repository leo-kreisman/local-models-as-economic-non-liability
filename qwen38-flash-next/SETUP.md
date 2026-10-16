# Qwen3.8-Flash-Next on this workstation — research digest & plan

Researched 2026-10-01. Target machine: **i7-8700K / 64 GB DDR4 / 2× RTX 5060 Ti 16 GB (PCIe 3.0 x8) / 3.6 TB NVMe**.

---

## 0. BLOCKER — disk space

| Mount | Size | Avail | Use |
|---|---:|---:|---:|
| `/home` (nvme0n1p5) | 1.6 T | **48 G** | 97% |
| `/` (nvme0n1p4) | 100 G | 27 G | 72% |

The model file alone is 75–104 GB. **You cannot download it today.**

But: `nvme0n1` is **3.6 TB** and only ~1.71 TB is partitioned (p1..p5). There is
**~1.9 TB unallocated** on the same NVMe. Allocate it before anything else:

```bash
sudo parted /dev/nvme0n1 print free     # confirm the free range
# create p6 over the free space, then:
sudo mkfs.ext4 -L models /dev/nvme0n1p6
sudo mkdir -p /mnt/models && sudo mount /dev/nvme0n1p6 /mnt/models
sudo chown $USER:$USER /mnt/models
```

Put `/mnt/models` on the NVMe, **not** on the SATA SSDs or the `ST500DM002` HDD —
the whole technique below depends on low-latency random 4K reads.

---

## 1. What the model actually is

`Qwen3.8-Flash-Next` is **not** a dense 180B. It decomposes as:

| Portion | Params | File cost @ UD-Q4_K_XL | Role |
|---|---:|---:|---|
| MoE compute weights | 128.8 B (6 B active) | ~76.9 GiB | real matmuls — **must be resident** |
| **PLE / n-gram table** (`per_layer_token_embd.weight`) | 51.2 B | ~26.8 GiB | **pure row lookup — can live on disk** |
| MTP draft head | 4 B | ~1.9 GB sidecar | optional spec decode |
| **Total** | ~180 B | **103.7 GiB** | |

Arch in llama.cpp: `qwen4exp` (`Qwen4ExpForConditionalGeneration`), 48 layers, only **12**
use full attention (GQA, 2 KV heads); the rest are GDN/Mamba-style state that does **not**
grow with context. KV = **24 KB/token** → 262 K ctx = 6 GiB, 64 K = 1.5 GiB.

## 2. The technique — "the 0xBakeer trick"

This is the single answer to your question, and it is *not* expert-SSD-streaming:

```bash
-ot "per_layer_token_embd=CPU"   # pin the 51B table to CPU backend, never copy to GPU
--load-mode mmap                 # (aka -lm mmap) serve those pages from NVMe on demand
```

Why it works: a matmul weight is read **in full** every token, so if it's not resident,
throughput collapses to disk bandwidth. An embedding table is different — per token the
model gathers **~16 rows out of 320,001,536** (0.000005% of it), addressed deterministically
by an n-gram hash *before* the gather runs. That's a handful of small reads, which is exactly
what the OS page cache over NVMe is good at.

Effect: 103.7 GiB file → only ~77 GiB resident for Q4. **This is what makes a 96 GB
VRAM+RAM machine plausible at all.**

### Things that were measured and DO NOT work (don't waste time)
- **Warming the table** — no effect (faults no longer dominate once CUDA graphs engage).
  `WARM=0` upstream.
- **Lower-bit K-quants are SLOWER** (Q3_K_XL 90 GB ran 14% slower than Q4_K_XL 111 GB).
  This config is **overhead-bound, not bandwidth-bound**. *But* IQ-series quants show the
  opposite (IQ1_S 33 t/s vs IQ4_XS 27 t/s) — **use IQ, not K-quants**, for a small build.
- **Deeper speculation** — activating k draft tokens unions the experts across positions,
  2–3× verification traffic. `n_max=3` is the optimum; 48–64 collapses decode to 14–18 t/s.
- **MoE expert SSD-streaming (llama.cpp PR #25294)** — still unmerged, and it **auto-disables
  mmap**, which kills the PLE trick. Skip it.
- `VLLM_PLE_CPU_OFFLOAD=1` — hangs. vLLM was ~2× slower than llama.cpp on dual 5060 Ti.

## 3. Your machine vs the reference machine

Every published number (19–22 t/s base, 88 t/s on copy-heavy, 34–71 t/s on GX10) is from a
**DGX Spark / GB10**: 128 GB *unified* memory at **273 GB/s**, hardware-coherent ATS, GPU can
dereference host memory directly, NVLink-C2C.

Your rig is the opposite: **discrete** GPUs over **PCIe 3.0 x8**, no P2P (`nvidia-smi topo`
shows `PHB` — both cards behind the same host bridge, transfers route through host RAM),
64 GB of DDR4-2666 dual-channel (~41 GB/s). Consequences:

1. **Do not expect GB10 numbers.** Expect roughly 8–20 t/s decode, 150–400 t/s prefill.
   The n-gram spec decode win (up to ~3×) *should* still apply, and it's the reason to do this.
2. **Prefer `-sm layer` over `-sm tensor`.** With no P2P, tensor-split shuffles activations
   through host memory every layer. Layer-split keeps cross-GPU traffic minimal.
3. **The DRAM side is your bottleneck.** Anything that lands in system RAM runs at ~41 GB/s.
   Push as much as physically possible onto the 30 GB of usable VRAM.
4. PCIe 3.0 x8 itself is *not* the problem — dual-5060 Ti measurements show <4% link
   utilisation, and MoE is exactly the case where splits work well (only ~6B active/token).

## 4. Memory budget for your box

| Resource | Raw | Usable for weights |
|---|---:|---:|
| VRAM (2× 16 GB) | 32 GiB | **~30 GiB** (Xorg/gnome hold ~0.6 GiB on GPU0) |
| System RAM | 62.7 GiB | **~54 GiB** (leave 8 GiB for OS + page cache + KV) |
| **Resident total** | | **~84 GiB** |

Since the PLE table is off-loaded to disk, you need **`file_size − PLE_size ≤ ~84 GiB`**.

| Quant | File | Verdict |
|---|---:|---|
| UD-Q4_K_XL | 103.7–111 GiB | ❌ compute portion ~77 GiB — no room for KV/OS |
| UD-Q3_K_XL | 90.0 GB | ⚠️ marginal, and K-quant is slower anyway |
| **GSQ-RCO IQ3_XXS** | **75.84 GB** | ✅ **start here** — published, hash-pinned, measured |
| UD-Q2_K_XL | 78.9 GB | ✅ fallback |
| UD-IQ1_M / IQ2 | 74.5 GB | ✅ last resort |

**Recommendation: ISTA-DASLab `GSQ-RCO IQ3_XXS`** — it is the quant with published, reproducible
numbers (32 K/65 K decode, perplexity +0.8% vs Q3_K_XL), it is hash-verified, and it is the
smallest 3-bit build found.

## 5. Two things to fix before serving

1. **Disable swap.** Upstream run.sh is explicit: cold n-gram pages should be evicted from the
   page cache, never have resident weights pushed into swap. You currently have **16 GB zram
   with 11 GB already in use** — that is active memory pressure and it will thrash.
   `sudo swapoff -a` before serving.
2. **Close the desktop.** GPU0 currently carries Xorg + gnome-shell + Firefox + VS Code +
   Antigravity (~0.6 GiB and climbing). Every MiB of VRAM matters here.

## 6. Known constraints (verified upstream, will bite you)

- `--parallel 1` is **required** — a 2nd in-flight request aborts (`qwen4exp.cpp:284`).
- **Quantized KV aborts.** Keep `-ctk f16 -ctv f16`. (Saves little anyway: 24 KB/token.)
- `--fit` **crashes** (`LLM_ARCH_QWEN4EXP` missing from `graph_max_nodes`). Use `--fit off`.
- The Flash-Next GGUF ships **no `nextn`/MTP tensors** — MTP spec decode is unavailable on it.
  Use `--spec-type ngram-mod` instead.
- qwen4exp **merged to llama.cpp master on 2026-08-27** (PR #27742). The old DGX patches are
  now redundant — **build master, don't patch**. This also picks up upstream MoE fusion
  (softmax+top-k, GEMV), measured by NVIDIA at ~35% MoE uplift.
- **Vision needs a separate `mmproj-F16.gguf`** (~0.9 GiB) from the Unsloth repo.

## 7. Files in this directory

| File | Purpose |
|---|---|
| `setup.sh` | clone+build llama.cpp for **sm_120** (not 121), then download+verify the GGUF |
| `serve.sh` | the tuned launch — all values overridable by env var |
| `bench.sh` | smoke + decode throughput against the running server |
| `SETUP.md` | this document |

## Sources

- [0xBakeer/qwen38-flash-next-spark](https://github.com/0xBakeer/qwen38-flash-next-spark) — canonical recipe, `docs/how-it-works.md`, `docs/ruled-out.md`
- [styles01/sparkrun-recipes](https://github.com/styles01/sparkrun-recipes/blob/main/runbooks/qwen38-flash-next-image.md) — containerised launch flags
- [sxuff/qwen38-flash-next-dgx-spark](https://github.com/sxuff/qwen38-flash-next-dgx-spark) — hash-pinned IQ3_XXS profile + systemd unit
- [llama.cpp PR #27742](https://github.com/ggml-org/llama.cpp/pull/27742) — qwen4exp, merged 2026-08-27
- [llama.cpp PR #27794](https://github.com/ggml-org/llama.cpp/pull/27794) — `--tensor-read-lazy` (PLE only, NOT experts)
- [llama.cpp PR #25294](https://github.com/ggml-org/llama.cpp/pull/25294) — MoE expert disk streaming (unmerged, conflicts with mmap)
- [Kurokosama/club-dual-5060ti](https://github.com/Kurokosama/club-dual-5060ti) — PCIe 3.0 dual 5060 Ti measurements
- [5p00kyy/club-5060ti](https://github.com/5p00kyy/club-5060ti) — dual-card MoE presets
- [PMZFX multi-gpu.md](https://github.com/PMZFX/intel-arc-pro-b70-benchmarks/blob/master/multi-gpu.md) — layer vs tensor split, x8 penalty analysis
- [unsloth/Qwen3.8-Flash-Next-GGUF](https://huggingface.co/unsloth/Qwen3.8-Flash-Next-GGUF)
