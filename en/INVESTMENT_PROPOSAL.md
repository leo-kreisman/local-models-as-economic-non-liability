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

The initial selection should compare a dense 27B and a 35B MoE, in 4 and 8 bits, within the team’s harness. Total MoE parameter count determines storage, while the active portion helps explain computation cost; these measures are not interchangeable. A configuration of approximately 64 GB is a practical candidate for these models, but context, the IDE, test containers and concurrent processes must be included in measurements. Larger models with SSD offloading are a later experimental track: I/O cost and latency must be compared with the quality gain.

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
