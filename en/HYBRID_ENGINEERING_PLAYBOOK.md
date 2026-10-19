## Engineering operating model: local execution, selective cloud use and reusable harnesses

Research update: October 19, 2026. The economic target is recurring engineering work with executable acceptance criteria. Three paths must be compared: deterministic automation, a local model, and local + cloud collaboration. A cloud model can also build reusable procedures offline; that investment need not recur on every task. The following separates measured results, vendor implementations and the proposed enterprise architecture. No model-performance or penetration tests were executed for this update.

### Hybrid economics: the evidence that most directly informs engineering

| Evidence | Configuration and workload | Published result | Decision implication |
|---|---|---|---|
| Nav, organizational experiment | Qwen3.6-35B mixed 4/8-bit, MLX, M4 Max 48 GB; Sonnet 4.6 orchestrator; OpenCode | Ktor mapper change: US$ 0.339 cloud versus US$ 0.134 hybrid; TypeScript rename: US$ 0.227 versus US$ 0.121 | About 60.5% and 46.7% lower remote cost in those paired experiments |
| Nav, negative control | Same model pair and harness, Spring repository | US$ 0.092 cloud versus US$ 0.164 hybrid | About 78.3% higher cost; route by measured task class, not language alone |
| Hybrid Coding Arena | M4 Max 64 GB; local models, four supported harnesses and cloud routing | README: 24/24 passes, 8% cloud fraction, US$ 0.022/task for Cline + Qwen cascade | Small repeated task set; the cloud-fraction definition has a documented inconsistency |
| HERA, April 2025 | Local Mistral 7B via llama.cpp/RTX 4090 with remote GPT-4 | HumanEval: US$ 0.056 to US$ 0.044/request; HotpotQA: US$ 0.054 to US$ 0.043 | Calculated API reductions of 21.4% and 20.4%; local TCO excluded |
| MinionS | Local processing coordinated by a remote model | 5.7× lower remote cost, retaining 97.9% of baseline performance | Document-analysis evidence; not a coding productivity benchmark |

Sources: [Nav measurement report](https://raw.githubusercontent.com/navikt/mlx-workspace/main/reports/local-inference-findings.md), [Arena README](https://github.com/RunanywhereAI/hybrid-arena), [HERA tables 3–4](https://arxiv.org/html/2504.00434v1), [MinionS](https://arxiv.org/abs/2502.15964). These are author-reported experiments, not independently audited company-wide savings. HERA includes Microsoft-affiliated researchers; it does not establish a Microsoft production rollout. Its reported quality tradeoff and historical prices prevent treating the savings as a current quotation.

**Correction to the 8% headline.** Arena's v1.4.1 release notes explicitly define cloud fraction as cloud tokens divided by all tokens and report **10.3%**, not 8%, for the highlighted cascade cell. They say earlier drafts used call estimates that double-counted local meta-calls. The README still advertises 8%. This update retains both as a source inconsistency, not interchangeable measurements. Neither establishes an equivalent percentage reduction in the invoice. Quantization and model identity should be pinned by artifact, not inferred from inconsistent descriptive labels. [Release notes v1.4.1](https://github.com/RunanywhereAI/hybrid-arena/blob/main/docs/release-notes/v1.4.1.md).


HERA also reports the quality and local-use tradeoff for HumanEval: Mistral + GPT-4 reaches 47.8% accuracy with 28.4% SLM use and US$ 0.044/request; Llama + Claude reaches 44.2%, 36.6% and US$ 0.053. These compare two hybrid pairs, not hybrid against their cloud-only baselines. More local use does not by itself establish better quality or lower cost. [HERA table 4](https://arxiv.org/html/2504.00434v1).

### Real repositories and test cases, rather than generic chat prompts

Nav identifies `navikt/isoppfolgingstilfelle` (Ktor), `navikt/ia-tjenester-metrikker` (Spring) and `navikt/familie-tilbake-frontend` (React/Express). These are public repositories from a real organization serving the welfare system. Checks include compilation and repository tests; the frontend uses 61 test files and 572 tests. The baseline backend suite already had failures, so “verified” means no new failures, not universal correctness. Local-only sessions passed simple questions, comments, renames and DTO changes in small samples; creating a new test file succeeded in 0/3 attempts. These results support qualification by task, not blanket replacement of QA. [Nav study and limitations](https://raw.githubusercontent.com/navikt/mlx-workspace/main/reports/local-inference-findings.md).

Arena's harder D6 suite contains an LRU/TTL cache, a token bucket, topological sorting and a mini-template parser: four tasks with 80 tests, repeated with three seeds. The published results are 8/12 local-only, 9/12 cascade and 12/12 cloud-only. The headline success on easier tasks therefore does not transfer unchanged to harder work. Release notes and README also differ on some failure classifications and cloud fractions; preserve raw runs and the selected revision when reproducing. [D6 specification and results](https://github.com/RunanywhereAI/hybrid-arena/blob/main/docs/release-notes/v1.5.0.md).

### Industry evidence for specialization and reusable automation

| Organization or study | Concrete engineering activity | Evidence and boundary |
|---|---|---|
| Google | Migrating internal Google Ads identifiers and related code | Model-assisted changes are combined with validation and unit tests; demonstrates a bounded migration workflow, not local small-model savings. [Google Research](https://research.google/blog/accelerating-code-migrations-with-ai/) |
| Meta, ACH | Generate mutants and regression tests that detect them | Production engineering approach with executable fault-detection checks; does not establish a workstation-local model or token-cost reduction. [Meta Engineering](https://engineering.fb.com/2025/02/05/security/revolutionizing-software-testing-llm-powered-bug-catchers-meta-ach/) |
| Tiger Data, pg-aiguide | Postgres schema design, version-specific documentation and curated skills | Open-source domain guidance. The original article describes qualitative evaluation, not a controlled small-model benchmark or measured savings. [Tiger Data](https://www.tigerdata.com/blog/we-taught-ai-to-write-real-postgres-code-open-sourced-it), [repository](https://github.com/timescale/pg-aiguide) |
| NUS, Gungnir | Evolve reusable SQL test generators for SQLite, DuckDB and PostgreSQL | 44 developer-confirmed bugs, 34 fixed; a separate DuckDB run reports five confirmed bugs for US$ 20.85. After evolution, generation runs without LLM calls. This is research on real database engines, not a demonstrated local-LLM deployment. [Paper](https://arxiv.org/html/2610.14161v1) |

Gungnir is particularly relevant to recurring QA: spend inference on improving the generator, validate the change, then reuse the program. This is a complementary savings mechanism, not a local + cloud LLM benchmark. A local model can later assist triage, but that extension is proposed here, not measured in the paper.

### Cloud-assisted harness development, with local execution afterward

A harness includes instructions, context retrieval, tools, state, retry limits and verifiers. Optimizing a skill file changes only one component; changing model weights is a separate intervention. A strong cloud model may propose a harness using public examples or approved, minimized context. The resulting artifact can be reviewed, versioned and executed repeatedly with local weights.

Microsoft's **SkillOpt** uses an optimizer model to revise skills for a frozen target model, with bounded edits and held-out validation. Its evaluation includes Qwen3.5-4B, six non-coding benchmarks and 52 evaluation cells. This supports the mechanism of external procedural improvement, not a claim of coding parity with a frontier model. **GEPA** reports prompt optimization using up to 35× fewer rollouts than its GRPO comparison; this is not a 35× reduction in the complete cloud bill. [SkillOpt](https://www.microsoft.com/en-us/research/blog/skillopt-agent-skills-as-trainable-parameters/), [GEPA, ICLR 2026](https://proceedings.iclr.cc/paper_files/paper/2026/hash/0e9e708b6f48e14fd0ac29e167413f76-Abstract-Conference.html).

Microsoft also reports an internal Rust formal-verification agent improved by over ten points through prompt tuning at less than US$ 6 per task. The presentation does not provide a complete local-workstation deployment or enterprise savings account. Agent Lightning supports separate optimization infrastructure rather than requiring a wholesale rewrite of the agent. [Microsoft presentation](https://www.microsoft.com/en-us/research/video/agent-lightning-one-learning-system-that-makes-all-agents-evolve/), [Agent Lightning repository](https://github.com/microsoft/agent-lightning).

**Proposed lifecycle:** select one recurring task family; assemble de-identified training cases and an untouched evaluation set; establish the existing cloud-only baseline; ask the cloud model to propose concise instructions, tool schemas and bounded recovery procedures; run candidates locally; promote only candidates that improve accepted-task cost without violating quality or security thresholds; retain rollback and periodically reassess drift. The optimizer must not edit its own acceptance tests or security policy. Hidden tests and final human review remain outside the agent's writable workspace.

| Reusable harness | Local work | Independent acceptance gate | Escalation condition |
|---|---|---|---|
| DTO/API propagation | Apply a specified field through types, mappers and call sites | Build, schema compatibility and contract tests | Ambiguous business rule or incompatible contract |
| Mechanical refactoring | Rename or apply an approved transformation | AST/symbol checks, compilation and regression tests | Conflicting semantics; use a deterministic codemod where sufficient |
| Regression-test expansion | Add cases from existing patterns and synthetic fixtures | Test execution, mutation detection, flakiness checks | No useful assertion or failure after bounded repair |
| Postgres migration | Generate a bounded migration using pinned-version guidance | Disposable database, invariants, rollback, lock and plan checks | Destructive operation or unexplained query-plan regression |
| UI maintenance | Update a known component and its test cases | Accessibility, interaction, screenshots and E2E | New design judgment or unexplained visual divergence |
| CI triage/documentation | Classify sanitized failures and draft references | Links to actual code/log evidence; human acceptance | Missing evidence, sensitive data or uncertain diagnosis |

These are pilot candidates, not a measured claim that most of the organization's workload is already covered. Measure their frequency in completed tickets and pull requests. Start with repetitive, bounded operations; retain human ownership of requirements, architecture and production approval.

### Secure internet-enabled workstations: practical architecture

The inference process does not need unrestricted internet access merely because the agent needs documentation. Separate the local inference service, code-execution worker, retrieval broker and cloud gateway. A malicious page can influence model output; the deployment must still prevent that output from acquiring unauthorized capabilities.

```text
Managed workstation
  reviewed worktree -> isolated agent worker (OpenCode / OMP / Aider)
                         |-> authenticated local inference gateway -> MLX or llama.cpp
                         |-> disposable test runner and synthetic database
                         |-> retrieval broker -> approved public documentation
                         |-> export gate -> authorized cloud inference
  independent verifier <- proposed patch and test evidence
  credential broker, network policy and audit remain outside agent control
```

On Apple Silicon, MLX can remain on the host for GPU access while agent tools execute in a separate VM. The VM receives access only to the inference gateway and approved brokers, not unrestricted access to host services. A loopback-only host listener is not automatically reachable from a VM; configure an authenticated, narrowly routed bridge or proxy deliberately. On Linux, a dedicated unprivileged worker, sandbox/container or VM can separate the agent from the inference service; a container sharing the host kernel is a different boundary from a VM. GPU passthrough is not required merely to run build tools in the worker.

**Industrial implementations demonstrate feasibility, not immunity.** Docker documents OpenCode in local microVM sandboxes and policy-controlled connectivity. Anthropic reports an 84% reduction in permission prompts in its internal sandbox usage and publishes a runtime for filesystem/network restrictions on arbitrary processes. That percentage measures prompts, not attack prevention. These mechanisms can support a local-model architecture without adopting Hermes or OpenClaw. [Docker OpenCode integration](https://docs.docker.com/ai/sandboxes/agents/opencode/), [Anthropic implementation](https://www.anthropic.com/engineering/claude-code-sandboxing), [sandbox-runtime](https://github.com/anthropics/sandbox-runtime).

### Control design and acceptance tests

The table is a proposed enterprise baseline. Each control must be verified on the exact OS, runtime, agent and policy version. Tests use synthetic secrets and isolated fixtures, never actual production credentials.

| Surface | Required control | Acceptance test and evidence |
|---|---|---|
| Public web access | Separate fetch broker; approved domains and paths; validate redirects, DNS results and private-address restrictions | A permitted documentation fetch succeeds; redirects to a forbidden host and metadata/private endpoints fail |
| Exfiltration | Deny direct worker egress; prohibit arbitrary query strings, uploads and write APIs; inspect permitted requests | Synthetic marker cannot leave through URL, body, DNS or a spawned process; capture gateway decisions |
| Code confidentiality | Do not give a browsing worker sensitive repository access; transfer only approved snippets | Same malicious page cannot obtain secrets or source outside its assigned task scope |
| Credentials | Brokered short-lived scopes; no credentials in prompt, environment, repository or broad SSH forwarding | Worker cannot read the key or use a broker to act on another project |
| Workspace | Disposable worktree; minimum mounts; no home directory, host Docker socket or production volumes | Symlink, traversal and child-process access outside the worktree fail |
| Prompt injection | Treat pages, issues, logs and repository instructions as untrusted data; enforce permissions outside prompts | Instructions to export data or alter policy fail even when the model attempts compliance |
| Dependencies and tools | Approved registries, pinned artifacts, reviewed install scripts, internal mirrors | Unapproved package download and installation-time egress are blocked |
| Runtime API | Local binding or private gateway; authentication, request limits and project isolation | Unauthenticated inference denied; another project cannot retrieve logs, contexts or cached results |
| Agent configuration | Corporate policy outside repository write access; review plugins, MCP servers and project config before execution | Opening a repository cannot silently weaken the effective policy or launch host commands |
| UI testing | Dedicated browser profile, synthetic account, restricted destinations | Test browser has no corporate session cookies and cannot reach unrelated internal applications |
| Database/backend | Ephemeral database and narrow test role; production inaccessible | Migration can run against fixtures but cannot connect to production or alter external schemas |
| Output and persistence | Independent CI, protected tests, review of workflows/hooks/config as well as source | Agent cannot hide a failure by changing tests or persist an executable hook on the host |
| Availability and cost | Timeouts, token/step limits, concurrency queues, cloud spend caps | Repetition loop terminates, hung server is isolated, fallback cannot exceed authorized budget |
| Audit and updates | Minimal-content logs, retention/access policy, signed/pinned releases and rollback | Security events are traceable without retaining raw secrets; rollback restores a known configuration |

Domain allowlists alone do not prevent leaks to an allowed service, including a Git host or cloud model. Retrieval-only access and authorized data export are separate permissions. DLP and model-based classification are supplementary; they cannot reliably recognize all proprietary business logic. Restricted projects should have no cloud export path. Internet access remains useful, but the browsing component should not inherit every permission of the coding component.

Docker's documentation explicitly notes that clone mode can still expose untracked `.env` files and that SSH forwarding grants usable authority even when keys stay outside the VM. A local MCP process can also execute with host privileges outside sandbox isolation. These are configuration obligations, not reasons to abandon containment. [Docker isolation layers](https://docs.docker.com/ai/sandboxes/security/isolation), [Docker security boundaries](https://docs.docker.com/ai/sandboxes/security/).

### Runtime and agent-specific implementation decisions

| Component | Verified capability or limitation | Deployment consequence |
|---|---|---|
| MLX-LM | Official server documentation warns that basic security checks are insufficient for production | Keep inference behind a qualified gateway; do not expose the development server as the enterprise security boundary. [MLX server](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/SERVER.md) |
| llama.cpp | API-key and TLS configuration exist; authentication defaults to none | Configure identity and limits explicitly; service authentication does not constrain tools executed by the agent. [Server documentation](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md) |
| OpenCode | `allow`, `ask`, `deny`, per-tool/per-agent rules; permissive defaults | Qualify effective policy and an external sandbox; do not broadly allow shell or package managers merely to reduce prompts. [Permissions](https://opencode.ai/docs/permissions/) |
| Oh My Pi | `yolo` default; approval policies; Bash policies are not containment and do not automatically cover `eval` | Select restrictive mode, constrain every execution path and enforce OS/network boundaries independently. [Settings](https://github.com/can1357/oh-my-pi/blob/main/docs/settings.md) |
| Aider | Local-compatible providers and lint/test feedback | Use a restricted worktree and external execution sandbox; lint/test commands themselves execute project code. [Providers](https://aider.chat/docs/llms/other.html), [Testing](https://aider.chat/docs/usage/lint-test.html) |

There is no demonstrated universal security ranking placing one of these agents above all others. OMP, OpenCode and Aider are the proposed qualification candidates. Hermes and OpenClaw are outside the proposed deployment. Physical side channels remain a specialist appendix; the primary workstation controls address code execution, credential theft, network export, supply chain and persistence.

### Measure savings without confusing tokens, requests and money

Record local and cloud input/output tokens, cache reads/writes, retries, routing decisions, tool use, latency and acceptance. The remote bill must use each provider's actual billing categories; raw token counts alone are misleading when cached tokens dominate. Report both cost per attempted task and cost per accepted task, counting failed attempts and repairs. Include human review and waiting, amortized hardware, energy, operations and harness development.

For a task family, let B be cloud-only cost per accepted task, L local operating cost, q the fraction requiring cloud fallback, F its average additional cloud cost, H harness maintenance per task and R incremental review/rework. The proposal is favorable when **L + q × F + H + R < B**, at acceptable quality and latency. A token-based cloud fraction cannot be substituted for q. For a continuously orchestrated hybrid workflow, account for all planning and coordination calls rather than using a fallback-only equation.

Illustrative assumptions, not market measurements: B = US$ 0.50, L = US$ 0.04, q = 0.20, F = US$ 0.60, H = US$ 0.03, R = US$ 0.06 gives US$ 0.25/task, a 50% reduction. Adding US$ 0.30 of incremental review makes it US$ 0.55 and removes the economic advantage. If building and validating a harness costs US$ 300 and saves US$ 0.25 per subsequent accepted task after recurring costs, break-even is 1,200 tasks. Charge that initial investment once; do not also amortize it into H in the same calculation.

### Pilot with business-relevant repositories and measurable gates

Select completed, reviewable tasks from the company's own repository history, with approval to use them and synthetic data. Include a backend service, a React/TypeScript interface and a PostgreSQL-backed application; add a database-engine fixture suite where relevant. Public Nav repositories and Arena tasks are reproducibility references, not substitutes for the company's workload distribution.

Compare four arms on the same pinned tasks: existing cloud workflow; local with a generic harness; local with a specialized harness; specialized local + cloud. Add a deterministic baseline for mechanical transformations. Preserve independent acceptance tests, fixed attempt budgets, cold/warm cache conditions and all failures. Hold out entire task families or modules when testing generalization; never tune against the final evaluation set. Repeat enough tasks to show uncertainty and report separate outcomes for backend, UI and QA rather than one misleading aggregate.

The six-week pilot remains the investment framework, but security qualification and harness development require allocated engineering time. The existing 80 integration hours and 30 security/validation hours are provisional allocations, not proof that every control and task family fits. Start with two task-specific harnesses and the minimum necessary tool surface; revise the budget before expanding. No monthly team savings should be attributed to a published task-level benchmark without measuring volume, utilization and total costs.

Implementation companion: [Two task-specific harnesses](TASK_HARNESSES.md).
