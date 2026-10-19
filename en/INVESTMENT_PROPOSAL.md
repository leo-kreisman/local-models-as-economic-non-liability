# Local AI capacity for engineering

Decision proposal • Problem/Context + Solution + Required Investment • October 16, 2026

## Problem / Context — the problem and its context

The proposal is to create inference capacity under company control to reduce the variable cost of assisted programming, retain code and sensitive context, and make the environment more predictable. The initial objective is to replace a verifiable portion of intensive users’ remote consumption while retaining cloud access for tasks that justify its cost. The proposed pilot involves five professionals over six weeks, with backend, UI, testing and repository-maintenance tasks.

The report received describes professionals spending US$ 2 thousand–10 thousand. For this proposal, the unit is assumed to be **per professional per month**; confirming the billing period and invoice is part of establishing the baseline. This is not a market average. Subscriptions, API consumption, monitor estimates and actual invoices must be distinguished. Cache, context size, repeated tool use and parallel agents explain why per-seat pricing does not describe an intensive user’s spending.

Current costs have three components: inference and external services; engineering time for review and correction; and vendor-dependence risk. Reducing only the first component can worsen the outcome if the local model requires much more rework. The pilot’s economic metric will therefore be cost per accepted task, accompanied by cycle time and quality, as well as monthly spending. The [Pegatron study](https://arxiv.org/html/2607.13080v1), detailed in the report, illustrates this caution: modeled TCO improves with shared infrastructure but worsens under dedicated allocation in the same case.

Stability also has economic value. Programmers have reported Opus 4.8 regressions with examples and artifacts, such as [#63861](https://github.com/anthropics/claude-code/issues/63861) and [#67606](https://github.com/anthropics/claude-code/issues/67606). These reports warrant operational attention even when their cause remains uncertain. The recorded search found 102 GitHub matches, not 102 confirmed incidents. [Marginlab’s monitoring](https://marginlab.ai/blog/claude-code-degraded-before-opus-4-8/) shows daily product variation in a different episode, before the 4.8 release. The decision does not depend on proving deliberate degradation: the ability to retain an approved configuration and maintain alternatives already reduces dependence.

Code sent for remote inference does not automatically become the provider’s property. Enterprise contracts can restrict training, as in [Anthropic’s commercial policy](https://privacy.claude.com/en/articles/9267385-does-anthropic-act-as-a-data-processor-or-controller). Even so, the company must decide where context, logs, evaluations and feedback may be processed and retained. [Satya Nadella’s reflection](https://snscratchpad.com/posts/reverse-information-paradox/) reinforces the strategic value of this knowledge. No transfer of IBM, HP or Dell systems was demonstrated; the issue addressed here is exposure and dependence that can be managed.

## Solution — proposed solution

The proposed architecture keeps a primary local model, the repository, context retrieval and test execution inside the controlled environment. Eligible tasks use this path by default. A gateway applies data and budget rules to send only the necessary context of authorized tasks to the cloud. Content that cannot leave remains local; difficulty encountered by the model does not automatically authorize export. This is a **local + cloud** combination, not merely routing between two external APIs.

The initial selection should compare a dense 27B and a 35B MoE, in 4 and 8 bits, within the team’s harness. Total MoE parameter count determines storage, while the active portion helps explain computation cost; these measures are not interchangeable. A configuration of approximately 64 GB is a practical candidate for these models, but context, the IDE, test containers and concurrent processes must be included in measurements. Flash-Next with SSD offloading joins the 64 GB pilot; DeepSeek V4.1 will have its own qualification: I/O cost and latency must be compared with the quality gain.

The [Qwen3.8-27B model card](https://huggingface.co/Qwen/Qwen3.8-27B) shows improvement while retaining 27B, and [FigmaTrace](https://arxiv.org/html/2608.21460v1) shows specialization of the same model with GUI data. These justify evaluating compact models; they do not guarantee universal equivalence. [DeepSeek V4.1 Flash](https://arxiv.org/html/2609.19969v1) is a larger architecture with a more efficient cache; its evolution should not be described as simply improving the dataset while keeping size constant.

| Work | Initial path | Validation before acceptance |
|---|---|---|
| Backend and APIs | Local model for bounded changes, SQL and integration | Unit tests, API contracts, security analysis and diff review |
| QA | Local generation of cases, fixtures and tests; isolated execution | Compilation, repeated execution, useful coverage and flakiness detection |
| UI | Local model with visual context when supported | Screenshots, visual comparison, accessibility and Playwright tests |
| Legacy code | Local explanation and refactoring by module | Characterization tests and behavior preservation |
| Architecture or difficult failure | Human review and, when authorized, remote escalation | Comparison of the solution, cost, data sent and whether the task was actually solved |

There are two ways to provide this capacity. Individual machines retain isolation and avoid a shared queue, but may have low utilization. An internal API server facilitates maintenance and cost allocation, but requires concurrency planning and access controls between projects. A Mac cluster should not be purchased on the assumption that RAM or tokens/s add linearly: splitting a model across nodes, independent replicas and task queues have different costs. The report’s cases and benchmarks guide trials; they do not replace sizing for the team.

### Agents and editor: retain the workflow, choose the backend

The pilot will include Oh My Pi, OpenCode and Aider as configurable alternatives, alongside the possibility of retaining Claude Code, Codex CLI, Copilot CLI and VS Code with local inference. The paths are documented in [OMP Providers](https://github.com/can1357/oh-my-pi/blob/main/docs/providers.md), [OpenCode Providers](https://opencode.ai/docs/providers/), [Ollama for Claude Code](https://docs.ollama.com/integrations/claude-code), [OpenAI — CLI](https://learn.chatgpt.com/docs/developer-commands?surface=cli), [GitHub — Copilot BYOK](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-byok-models) and [VS Code — models](https://code.visualstudio.com/docs/agent-customization/language-models). Integration preserves a familiar interface and may reduce adoption effort; the benefit will be measured, without assuming a budget reduction.

Selection will consider the effective tool policy and operating-system containment. OMP and OpenCode offer granular controls, but their documented defaults are permissive: `yolo` in the former and `allow` for most tools in the latter. Sources: [OMP Settings](https://github.com/can1357/oh-my-pi/blob/main/docs/settings.md) and [OpenCode Permissions](https://opencode.ai/docs/permissions/). The proposal is to qualify restricted configurations. No independent security ranking of these products is presented here. On Mac, the [Claude Code Bash sandbox](https://code.claude.com/docs/en/sandboxing) uses Seatbelt; a Linux VM is not the only isolation option.

Acceptance must confirm the destination of inference and auxiliary services, test prohibited execution and file access, and verify that a project’s configuration does not relax corporate policy. Commands, offline-mode limitations and editor capabilities are detailed in the report. The integration budget includes this harness qualification.

### Internet-enabled workstation security

The proposed candidates are **OMP, OpenCode and Aider**, with MLX or llama.cpp behind an authenticated local gateway. Hermes and OpenClaw are outside the deployment. Separate code execution, inference, internet retrieval and cloud export into independently controlled components. On Mac, the model can use the host GPU while agent tools run in a restricted VM; only the necessary gateway route is exposed to that VM.

Docker documents [OpenCode in local sandboxes](https://docs.docker.com/ai/sandboxes/agents/opencode/) with microVM isolation. Anthropic publishes an [OS-level sandbox runtime](https://github.com/anthropics/sandbox-runtime) applicable to arbitrary processes. These are implementation references, not a certification of the pilot. The [MLX server documentation](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/SERVER.md) explicitly warns against production use with its basic security checks; a development listener must not be exposed as a complete enterprise service.

Internet access will use a restricted retrieval broker. Deny arbitrary uploads and direct worker egress, validate redirects and DNS destinations, block private/metadata endpoints and separate browsing from sensitive source access. Allowed domains alone cannot prevent exfiltration. Cloud export requires a separate data decision; difficulty or test failure does not authorize sending proprietary code. Credentials remain outside the model context, and shared APIs require identity and project isolation.

Acceptance includes synthetic-secret leakage tests, malicious instructions in repository files and web pages, unauthorized file reads, dependency-install egress, configuration overrides, production-database access and browser-session isolation. [Docker's documented limits](https://docs.docker.com/ai/sandboxes/security/isolation) include readable untracked secrets in clone mode and authority granted by SSH forwarding; both must be addressed explicitly. Independent CI reviews patches, workflows and hooks. Timeouts and token/spend limits contain loops and uncontrolled fallback.

Physical side channels are a specialist secondary threat model, documented in the research appendix. The primary investment protects everyday workstation assets against credential theft, execution outside the workspace, data export, supply-chain compromise and persistence. The complete control/test matrix is in the [engineering playbook](HYBRID_ENGINEERING_PLAYBOOK.md).

### Evidence-led task routing and recurring work

The pilot will prioritize mechanical edits, DTO propagation, regression-test expansion, bounded SQL changes and UI maintenance. Nav reports paired cloud/hybrid costs of US$ 0.339/0.134 for a Ktor mapper change and US$ 0.227/0.121 for a frontend rename, but US$ 0.092/0.164 for Spring: delegation can increase the bill. The [Nav study](https://raw.githubusercontent.com/navikt/mlx-workspace/main/reports/local-inference-findings.md) therefore supports qualifying task families rather than promising one savings rate for all coding.

The [HERA study](https://arxiv.org/html/2504.00434v1), published in April 2025 with Microsoft-affiliated authors, demonstrates local + cloud resource allocation, not an internal Microsoft rollout. HumanEval remote cost falls from US$ 0.056 to US$ 0.044, excluding local TCO and with a quality tradeoff. The Arena README's 8% headline conflicts with [revised release notes](https://github.com/RunanywhereAI/hybrid-arena/blob/main/docs/release-notes/v1.4.1.md), which give 10.3% of tokens in the cloud. Neither is a direct invoice-saving percentage.

### Build reusable task harnesses, then amortize their cost

Use an authorized cloud model to propose two initial harnesses from public or minimized approved examples. Freeze the local model and evaluate changes to instructions, retrieval, tool schemas and recovery steps against independent tests. [SkillOpt](https://www.microsoft.com/en-us/research/blog/skillopt-agent-skills-as-trainable-parameters/) provides evidence for optimizing an external skill layer; its non-coding benchmarks do not establish enterprise code parity. For repetitive QA, [Gungnir](https://arxiv.org/html/2610.14161v1) demonstrates a complementary path: improve reusable test generators and run them without further LLM calls.

Measure four arms: current cloud workflow, generic local harness, specialized local harness and specialized local + cloud. Include deterministic codemods where appropriate. Count all retries, cloud planning, cache categories, human review, operations and harness development. Cloud optimization must never modify hidden acceptance tests or enterprise security policy. The existing integration and security hours remain provisional; expansion beyond two harnesses requires a revised estimate.

### Six-week pilot and expansion decision

In the first week, FinOps and engineering consolidate invoices, token categories, cache, tasks and review time. The second week installs the environment and tests its controls. In weeks three to five, the same task types are compared between the current workflow and the local + cloud workflow, alternating order where feasible to reduce learning effects. The last week consolidates quality, spending actually avoided and capacity per workstation or server.

An initial set of 100 real tasks, distributed across backend, UI, QA and maintenance, is an **evaluation proposal**, not a sample guaranteed to deliver statistical significance. Acceptance thresholds must be defined before execution. As an initial basis for negotiation: total savings of at least 30%, a decline of no more than 5 percentage points in the task-acceptance rate, no unauthorized exposure in security tests, and up to a 10% increase in cycle time. Critical defects require separate analysis and cannot be offset by a favorable average cost.

The platform team is responsible for runtime and updates; security for policies and tests; FinOps for billing and cost allocation; and engineering and QA leaders for accepting the results. Expansion depends on this evidence. The proposal does not call for shutting down existing capacity before qualifying the local path.

## 32, 48 and 64 GB workstations: local capacity with proportional investment

Update: October 19, 2026. The pilot should also start on existing 32, 48 and 64 GB machines. Memory capacity, chip speed, quantization and implementation are separate variables. Published measurements reach 20–30 tokens/s and above in selected configurations; a 128–512 GB workstation is not required to begin. The figures below were published by their executors, not reproduced in this research. NR means not reported in this selection.

### Benchmarks directly useful for smaller configurations

| Physical machine | Model / format | Runtime and residency | PP tok/s | Decode tok/s | Condition and source |
|---|---|---|---:|---:|---|
| M1 Pro, 32 GB, 14-core GPU | Qwen3.6-35B-A3B Q4_K_S | llama.cpp b9466 / Metal; weights in memory | NR | 25.4 | 22.4 GB wired at 32K; host swap ~7.6 GB during agent work. [Executor](https://raw.githubusercontent.com/marcofariasmx/local-llm-apple-silicon/main/README.md) |
| M1 Max, 32 GB | Qwen3.8-27B MLX 4-bit | MLX; resident | 81.76 | 15.81 | 512 input / 700 output; 3 runs; peak 16.39 GB. [Executor](https://www.reddit.com/r/LocalLLM/comments/1wa0dl3/qwen3827b_on_m1_max_32gb_mlx_158_toks_vs_llamacpp/) |
| M1 Max, 32 GB | Qwen3.8-Flash-Next; experts mainly IQ2_K | MoEspresso 3; SSD; KV K4/V4; Cache-Prior | NR | 12–15 | Author requires memory headroom; bias favors resident experts and changes routing. [Executor](https://www.reddit.com/r/LocalLLaMA/comments/1wrqql8/qwen38flashnext_125b_at_1215_toks_on_a_2021_32gb/) |
| M4 Pro, 48 GB | Qwen3.8-27B 4-bit | Rapid-MLX 0.13.1; resident | 117 | 15.2 | Peak 18.9 GB; TTFT 18.2 s; community submission. [Record](https://rapidmlx.com/benchmarks/qwen3.8-27b-4bit/apple-m4-pro) |
| M5 Max, 48 GiB, 40-core GPU | Qwen3.8-27B 4-bit | MLX 0.32.1 / mlx-lm 0.31.3; no draft | NR | 13.70 / 13.62 / 13.34 | Medians at 840 / 3156 / 12263 input tokens; uncontrolled background load. [Study](https://llm-speed.com/blog/qwen3-8-27b-m5-max-48gb) |
| M5 Pro, 48 GB | Qwen3.8-Flash-Next 4-bit; file ~104 GB | Slotstream, MLX / Swift; experts on SSD | NR | ~12 | MTP still planned in the account; context and repetitions NR. [Author](https://www.reddit.com/r/Qwen_AI/comments/1w3tjkw/running_the_104_gb_qwen38flashnext_on_a_48_gb_mac/) |
| M4 Pro, 64 GB | Qwen3.8-27B oQ4e / oQ8 | oMLX 0.6.1, MTP | NR | 20.8 / 16.6 | 8K context; quantization comparison from the same master. [Discussion](https://github.com/jundot/omlx/discussions/2811) |
| M1 Max, 64 GB | Qwen3.6-35B-A3B 8-bit / Q8_0 | MLX / llama.cpp Metal; resident | ~190 / ~245 | 26.22 / 34 | Input ~1K; peaks 42 / 44 GB; incomplete versions. [Executor](https://sleepyquant.rest/blog/mlx-vs-llama-cpp-35b-m1-max-benchmark/) |
| M2 Max, 64 GB | Qwen3.6-35B-A3B NVFP4 | Ollama / MLX; resident | NR | 71.3 / 69.3 / 67.8 | Short / medium / long prompts; thinking off; median of 3. [Experiment](https://github.com/robgil/local-ai-benchmark-mac-stuido-m2) |
| M5 Pro, 64 GB | Qwen3.8-Flash-Next V3; 95.5 GiB, mixed quantization | llama.cpp fork; SSD; active draft | ~367 | ~27.6 | Prompt ~4K. [Executor](https://www.reddit.com/r/LocalLLaMA/comments/1wk14il/qwen38flashnext_955_gib_on_a_64gb_mac_at_27_toks/) |
| M5 Pro, 64 GB | Same Flash-Next V3 | Slipstream; SSD | NR | 35.0 / 37.5 | Python / Rust tasks, temperature 0. [Comparison](https://www.reddit.com/r/LocalLLaMA/comments/1wva7l2/running_955_gib_qwen38flashnext_at_4152_toks_on_a/) |
| M5 Pro, 64 GB | DeepSeek-V4.1-Flash; 299 GiB container | WARP, CPU path; internal SSD | NR | 3.77 / 3.71 | Outputs 64 / 200 tokens; budget 46.45 GB. [Project](https://raw.githubusercontent.com/sqliteai/warp/main/README.md) |

The WARP result fills the earlier gap in documented DeepSeek V4.1 Flash execution on a 64 GB Mac; it does not demonstrate 20–30 tokens/s for this model and hardware, or establish the ceiling of other runtimes. The Bonsai model remains excluded. Colibri remains in the earlier technical comparison, without turning DeepSeek V4 results into V4.1 results.

### What to buy or reuse at each capacity

| Memory | Priority path | Precision and headroom | Expansion criterion |
|---|---|---|---|
| 32 GB | Reuse for 27B Q4 and 35B MoE Q4 on bounded tasks | Measure IDE, browser and containers; do not assume comfortable 27B or 35B Q8 operation | Expand if memory pressure or task time disrupt work |
| 48 GB | Compare 27B Q4/Q8 and 35B MoE Q4; Flash-Next SSD as an experimental alternative | 35B Q8 requires peak, context and tool qualification; 27B Q8 does not guarantee prefill headroom | Purchase after testing actual load, not weight size alone |
| 64 GB | Compare 27B and 35B Q4/Q8; include Flash-Next SSD from the pilot | More room for the development environment; SSD does not equal swap | DeepSeek V4.1 SSD in its own qualification track, without an assumed speed target |

In the [Nav capacity experiment](https://github.com/navikt/mlx-workspace/blob/main/reports/48gb-question.md), a 36 GB wired limit was applied to a larger machine: this is not a speed benchmark of a physical 48 GB Mac. The text records loops and prefill failures despite weights fitting. The operational consequence is to test working memory and limit repeated calls in the client.

The llm-speed 48 GiB experiment published TTFT of 8.17 / 27.66 / 113.21 s for the table's three inputs, with thinking disabled. Its peak of 27.17 tokens/s on the smallest input does not replace the median of 13.70. Concurrent load explains why testing must include the working environment, although this study does not isolate its causal contribution.

### From speed to engineering savings

A home-operation account reports approximately 60 tokens/s with a 32 GB VRAM GPU, 64 GB RAM and SSD. This is evidence supplied by the proposal owner, without attached logs, GPU model, checkpoint, quantization, context or reasoning/output separation. It is not a Mac measurement and does not allow the same rate to be assigned to each cited model. Reproduction should record these fields and compare the same accepted task on smaller workstations.

PP processes context; decode generates tokens. Without separate events, the table does not split reasoning and final response. SSD embeddings/Engram, expert streaming and swap have different costs. Speculation, quantization and routing changes must also be declared; tokens/s does not demonstrate code quality.

The proposed economic workflow is: recurring local tasks → independent tests → bounded repair → authorized cloud use when necessary. The harness should reduce unnecessary context, select suitable tools and prevent loops; the cloud can improve it once for many local executions. Compare four arms: cloud, generic local, local with harness, and local with harness + cloud. Measure accepted-task cost, remote invoice, review, latency and energy. Security retains an isolated executor, authenticated gateway and controlled network egress, including on smaller machines.

The budget should compare reuse with gradual purchasing. The US$ 2500–5000 per workstation range is a planning assumption, not a quotation or an automatic mapping between price and RAM. Five workstations represent US$ 12500–25000 in hardware alone; integration, security, operation and rework remain in TCO. Do not multiply local tokens by nominal remote token prices to claim savings: measure the net invoice reduction, including caching and escalations.

## Required Investment — investment required

The budget below is a **planning scenario**, without a binding quotation. The user’s suggested range, US$ 2,500–5,000 per workstation, must be confirmed for the specific RAM, chip, SSD, taxes and warranty. The central scenario uses the upper end of that range, five workstations, and explicitly accounts for implementation work. It does not assume that one workstation replaces an unlimited number of agents.

| Pilot component | Assumption | Amount |
|---|---|---:|
| Five workstations | 5 × US$ 5,000 | US$ 25,000 |
| Deployment and integration | 80 hours × US$ 100/h | US$ 8,000 |
| Security and quality validation | 30 hours × US$ 100/h | US$ 3,000 |
| Contingency | 15% of US$ 36,000 | US$ 5,400 |
| **Planned initial investment** | Hardware + labor + contingency | **US$ 41,400** |
| Recurring local operations | Assumed US$ 100/workstation/month | **US$ 500/month** |

The hours may represent internal allocation rather than additional cash expenditure, but they have an opportunity cost. Recurring cost is an assumption to validate and should not duplicate work already counted. Licenses, additional administration, specialized training, replacement SSDs and physical modifications enter the budget if needed. Remaining API consumption is ongoing operating expenditure; it is not hidden in the initial investment.

### Payback scenarios including the full investment

These assume five users, a 50% effective bill reduction, US$ 500/month in operations and US$ 41,400 upfront. No extra rework cost was assumed; if it occurs, it must be subtracted. The US$ 2 thousand–10 thousand amounts derive from the user’s report, not a published enterprise average.

| Current API per person/month | Current team API/month | API + operations after migration | Monthly savings | Full payback | Balance after 12 months, net of investment |
|---:|---:|---:|---:|---:|---:|
| US$ 2,000 | US$ 10,000 | US$ 5,500 | US$ 4,500 | 9.20 months | US$ 12,600 |
| US$ 5,000 | US$ 25,000 | US$ 13,000 | US$ 12,000 | 3.45 months | US$ 102,600 |
| US$ 10,000 | US$ 50,000 | US$ 25,500 | US$ 24,500 | 1.69 months | US$ 252,600 |

At US$ 2,000 per person and only a 20% bill reduction, savings fall to US$ 1,500/month and payback extends to 27.6 months. This sensitivity prevents treating high savings as guaranteed. To recover the central scenario within 12 months, at least US$ 3,950/month of the team’s API spending must be avoided before any extra human costs — 39.5% of the initial US$ 10,000 bill.

If the team already has sufficient hardware, incremental investment may be much smaller. If it wants shared infrastructure, throughput, queues and isolation must be measured before reducing the machine count in the spreadsheet. The comparison should use TCO with the same delivery quality and time horizon.

### Decision requested from management

Approve a pilot with a planned ceiling of US$ 41,400 in initial investment and designated owners, subject to confirmation of invoices, hardware configurations and acceptance criteria. This approval is a proposal in the document, not a purchase or assumed authorization. At the end of six weeks, present a decision to expand, adjust or stop, supported by accepted tasks, demonstrated security and avoided spending.
