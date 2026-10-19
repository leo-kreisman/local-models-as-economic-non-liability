# Local and specialized models for development and QA

Cumulative research report. Updated on October 16, 2026.

Smaller specialized models can outperform larger generalist models in bounded workflows. Local deployment can reduce external dependencies and make inference accessible on workstations. The decision depends on quality in the actual workflow, required memory, concurrency and the full operating cost.

This report brings together business cases, open model benchmarks, Apple Silicon infrastructure and the Snorkel and UC Berkeley study on specialization of a 4B parameter model. Results published by the authors are identified as such; no model execution or experimental reproduction was performed in this research.

## How to interpret the evidence

| Category | What it establishes |
|---|---|
| Controlled study | Effect observed in the conditions and participants of the experiment |
| Business case identified | Real use, with metrics that can be self-reported |
| Authors' Benchmark | Ability in the set and published protocol |
| Hardware Demonstration | Viability and performance in that configuration |
| Tutorial or product available | Possibility of deployment, without proving adoption or return |
| Engineering Inference | Hypothesis to guide a pilot, still dependent on measurement |

Execution on the professional machine, on-premises server and VPC are different modalities. An internal big tech tool does not itself prove inference on notebooks or a local desktop cluster.

## Business cases in development and QA

| Organisation | Use and published results | Evidence Scope |
|---|---|---|
| Google | Internal code completion: more than 10 thousand developers, three months, a 6% reduction in time between builds and tests | Internal production; does not show inference on notebook. [Source](https://research.google/blog/ml-enhanced-code-completion-improves-developer-productivity/?hl=en_GB&version=v1) |
| Google | Experience with 96 engineers: estimated reduction of 21% in the time of a business task, with wide confidence interval | Controlled study; limited generalizability to other workflows. [Article](https://arxiv.org/abs/2410.12944) |
| IBM | watsonx Code Assistant: self-reported average savings of 56% in explanation, 59% in documentation, 38% in code generation and 38% in test generation | Internal challenge; inference topology not detailed. [Case](https://www.ibm.com/case-studies/ibm-software-team) |
| Meta | TestGen-LLM: 75% of the tests generated compiled, 57% passed reliably and 25% increased coverage; 73% of the recommendations accepted in test-a-thons | Two internal LLMs; automatic validation before recommendation. [Article](https://arxiv.org/abs/2402.09171) |
| Apple | Minions distributes inference to idle Mac GPUs | Distributed inference platform; does not measure programming productivity. [Publication](https://machinelearning.apple.com/research/distributed-gpu-cloud) |

IBM numbers involve 107 teams for explanation, 153 for documentation, 112 for code generation and 34 for testing. The case does not support assigning these gains to Granite executed locally. IBM separately publishes a [Granite 4 tutorial with Ollama, Continue and VS Code](https://developer.ibm.com/tutorials/awb-local-ai-copilot-ibm-granite-code-ollama-continue/), which documents the local architecture.

In the Meta study, “25% of the tests increased coverage” does not mean a 25% increase in total coverage. The flow combines generation with compilation, execution and filtering of candidates. It is a useful reference for evaluating tests produced by local models.

The [Tabnine](https://www.tabnine.com/platform/) offers on-premises and air-gapped deployment. The commercial availability of this modality does not identify which architecture each client uses.

The [MetaDesign Solutions](https://metadesignsolutions.com/case-study/air-gapped-ai-ide-financial-institution) reports DeepSeek Coder quantized in private GPUs with Kubernetes and extension VS Code to an anonymous bank, with over 800 developers in 60 days. The page associates 40% to different metrics; the percentage is not a clear enough basis to estimate investment return.

## Mac minis and shared servers

### Yembo

CTO Zach Rattner describes eight M4/M4 Pro Mac minis, initially with two machines dedicated to AI. whisper.cpp and Silero VAD replaced cloud transcription, with reported savings of US$ 40 thousand per year. The cluster also runs GitHub Actions, CircleCI and Playwright regressions; build and lint reportedly went from four minutes to 40 seconds. [Original report](https://zachrattner.com/projects/ai-mac-cluster)

The published financial savings relate to transcription. The build improvement relates to CI infrastructure. Neither metric should be presented as a proven benefit of an LLM writing code.

### EXO

Demonstration on eight 64 GB M4 Pro Mac minis, with 512 GB in aggregate and 4-bit models:

| Model | First token | Generation |
|---|---:|---:|
| DeepSeek V3 671B | 2.91 s | 5.37 tokens/s |
| Llama 3.1 405B | 29.71 s | 0.88 tokens/s |
| Llama 3.3 70B | 3.14 s | 3.89 tokens/s |

Source: [EXO](https://blog.exolabs.net/day-2/). The values demonstrate execution in this configuration; they do not dimension dozens of simultaneous sessions.

For an internal API, there are two options to compare: dividing the weights of a model between machines or distributing requests between complete replicas. The first increases the memory capacity; the second can increase the ability to serve users. The choice requires measuring prefill, generation, queues and latency under concurrency.

## Open models and coding benchmarks

Results declared by developers, consulted in the first round of this research:

| Model | Architecture | Published results |
|---|---|---|
| Qwen3.6-35B-A3B | MoE with 35B total and approximately 3B active parameters | SWE-bench Verified 73.4; Pro 49.5; Terminal-Bench 2.0 51.5. [Source](https://huggingface.co/Qwen/Qwen3.6-35B-A3B) |
| Qwen3.8-27B | 27B, dense blocks | SWE-bench Pro 61.7; Terminal-Bench 2.1 73.0; NL2Repo 42.3. [Source](https://huggingface.co/Qwen/Qwen3.8-27B) |
| Qwen3.8-Flash-Next | 125B main, 6B active, plus 51B of embeddings n-gram | SWE-bench Pro 62.5; Multilingual 81.0; NL2Repo 48.1. [Source](https://huggingface.co/Qwen/Qwen3.8-Flash-Next) |
| DeepSeek-V4.1-Flash | 552B on backbone and 196B memory Engram | DeepSWE v1.1 74.2 with mini-SWE; Terminal-Bench 2.1 90.6 with DeepSeek Harness Minimal. [Source](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash) |

The table is not a uniform ranking. There are different versions of benchmarks, agents, contexts and budgets. Qwen informs task fixes in SWE-bench Pro. DeepSeek himself reports DeepSWE 69.8 with Claude Code and 74.2 with mini-SWE, illustrating the influence of the agent that involves the model.

### Memory and SSD offloading

Active parameters indicate a computing feature, not the total weights to store. Approaches of pure weights in 4 bits: 35B correspond to 17.5 GB and 27B to 13.5 GB. Cache, metadata, buffers and operating system require additional memory.

The [DeepSeek-V4.1 report](https://arxiv.org/html/2609.19969v1) describes reduction of persistent KV cache to about 1/8 of the one used by V4-Flash. This does not mean reducing the memory of the entire model in the same proportion. The [Article Qwen3.8-Next](https://arxiv.org/abs/2608.30320) describes n-gram embeddings kept out of the accelerator. Sparse access to tables, expert transfer and cache offload are different mechanisms.

## Snorkel and UC Berkeley study of a 4B specialist

### Main result

The rLLM-FinQA-4B was adjusted from Qwen3-4B-Instruct-2507 with GRPO. The published comparison uses Qwen3-235B-A22B, a MoE; the approximate ratio of 59 times refers to total parameters, not to a 59-fold reduction in cost or latency.

| Model | FINQA | FinQA Reasoning |
|---|---:|---:|
| Qwen3-4B-Instruct-2507 before adjustment | 27.90% | 13.90% |
| Qwen3-235B-A22B | 51.37% | 18.90% |
| rLLM-FinQA-4B after adjustment | 59.70% | 26.60% |

Source: [official model card](https://huggingface.co/rLLM/rLLM-FinQA-4B). Calculated gains: +31.8 percentage points in FinQA against the original 4B; +8.33 against 235B. In Reasoning, +12.7 points against the original 4B, approximately 91.4% relative improvement.

These are financial analysis benchmarks with tools. The result demonstrates effective specialization in this distribution of tasks; it does not measure general software development or adoption by a business team.

### The example of YouTube advertising revenue

In the transcript provided by [Kobie Crawford’s lecture](https://www.youtube.com/watch?v=TNwJ1LMiENk), 235B tries to consult a non-existent table, repeats the attempt and responds without obtaining the data. The adjusted 4B discovers the tables, inspects schema, query, finds a column error and corrects the query before responding.

| Video Excerpt | Subject |
|---|---|
| [7min08s](https://www.youtube.com/watch?v=TNwJ1LMiENk&t=428s) | 235B model failure |
| [10min47s](https://www.youtube.com/watch?v=TNwJ1LMiENk&t=647s) | GRPO and run cost |
| [14min32s](https://www.youtube.com/watch?v=TNwJ1LMiENk&t=872s) | Discovery, schema and autocorrection in 4B |
| [16min32s](https://www.youtube.com/watch?v=TNwJ1LMiENk&t=992s) | Ablations and transfer to multiple tables |
| [18min30s](https://www.youtube.com/watch?v=TNwJ1LMiENk&t=1110s) | Rubrics for diagnosing behaviors |

The example illustrates the mechanism; the aggregate table is the performance evidence. The video and AIE page links could not be read by this research browser; the narrative details and timestamps above come from the transcript supplied by the user, corroborated as to the overall result by the authors’ publications.

### Environment data and versions

The OpenEnv environment published by Snorkel contains 290 evaluation questions about 22 companies. The lecture also describes 79 more complex examples of reasoning. These evaluation sets should not be confused with the training corpus. [Environment description](https://snorkel.ai/blog/building-finqa-an-open-rl-environment-for-financial-reasoning-agents/)

There are interface differences: the model card list `get_table_names`, `get_table_info`, `sql_query` and `calculator`. The OpenEnv version describes `get_descriptions`, `get_table_info`, `sql_query` and `submit_answer`. The transcribed speech uses `get_table_name`. For reproduction, the environment version and its tool contract should be fixed.

The model card describes reward with LLM evaluator; the OpenEnv article describes normalized numerical comparison and binary reward. They are descriptions of versions that should not be merged into a single recipe without checking the corresponding code.

### Simple training and transfer

Snorkel publishes the following internal ablations of Pass@1: only single table, 66.3%; mixture of one and several tables, 61.6%; curriculum from one to several tables, 64.8%. The 66.3% belong to internal ablation, while 59.7% is the published result of the main benchmark. [Publication of 18 February 2026](https://snorkel.ai/blog/how-tool-discipline-let-a-4b-model-outsmart-a-235b-giant-on-financial-tasks/)

The training with simple tasks presented transfer to multiple table questions. This maintains that discovering resources and reacting to errors were relevant behaviors in that environment. It does not establish that complex tasks should always be excluded from training.

### Cost of training and inference savings

Snorkel reports eight H100 GPUs and costs less than $500 per execution. The lecture mentions approximately 21 hours. The publication also projects a 90% reduction in the cost of inference to a scenario of 50,000 monthly queries. The projection is not an audited savings on an identified client. [Snorkel Source](https://snorkel.ai/blog/how-tool-discipline-let-a-4b-model-outsmart-a-235b-giant-on-financial-tasks/)

The value per execution should not be interpreted as a complete cost of creating the expert. For business budgets, data, experts, environmental engineering, evaluations, unsuccessful experiments and maintenance should be separately accounted for. The published cost does not mean that the training took place on a notebook.

### Developer machine execution

Weights are available in BF16 under Apache 2.0; the repository contains approximately 8.84 GB, including two weight files of about 4.41 GB each. This makes local deployment much more accessible than storing hundreds of billions of parameters. [Published Archives](https://huggingface.co/rLLM/rLLM-FinQA-4B/tree/main)

As an engineering estimate, a 16 GB GPU is a plausible candidate to test this model in BF16 with limited context and concurrency. Real consumption includes cache and buffers; file size is not a guarantee to fit into an 8 GB GPU. In this research, there is no measurement of tokens/s in consumer or Mac GPU, nor confirmation of preservation of quality after quantization.

An entirely local application needs also to maintain necessary tools, data and services within the defined infrastructure. Hosting the weights locally does not automatically make all the flow local.

## Applying specialization to developers and QA professionals

The hypothesis supported by the study is that a small model can learn recurring tool procedures and outperform a larger generalist in that workflow. Transfer to development should be measured using software tasks, because the FinQA experiment did not test it directly.

| Behavior in the study | Hypothesis of software application | Proposed assessment criteria |
|---|---|---|
| Discover tables before consulting | Find files and symbols before editing | References and files really exist |
| Inspect schema | Read API signature, types and configuration | Call compatible with the project |
| Fix Column Error | React build or test failure | Correction eliminates failure without regression |
| Respond to data obtained | Ground diagnosis in logs and execution | Evidence corresponds to the conclusion |
| Use tools selectively | Run relevant tests | Defect reproduced and test detects the failure |

The rubrics suggested in the talk help distinguish errors in discovery, interpretation, tool calling, recovery and the final answer. This breakdown guides which examples to produce before investing in training. The reward used in RL can remain scalar; a diagnostic rubric does not have to be the reward function itself.

For a pilot, compare original model, original model with improved instructions and agent, and specialized model. Keep test tasks separate from training and include new repositories or periods. Measure success, regressions, human review, latency and cost per accepted task. Thus, it is possible to know how much of the gain comes from training and how much comes from the environment.

## Other companies with small specialists and local execution

Complementary research October 16, 2026. The cases below distinguish results of specialization, usable products and published savings. No percentage is a general promise to another environment.

### JetBrains and Mellum for code completion

JetBrains describes an industrial pipeline of 4B models with contextual training, fill-in-the-middle and DPO alignment. The October 2025 article reports deployment for hundreds of thousands of users and evaluations with production telemetry. [Article Mellum](https://arxiv.org/abs/2510.05788)

In the April 2025 publication, the rate of acceptance of suggestions was 35% in Java and Python and 44% in Go. Mellum's participation in the code entered in the editor was 23%, 23% and 30%, respectively. These metrics belong to the cloud completion service described in the article, not to a local version evaluation. Acceptance of suggestions also does not equal proportional reduction in delivery time. [Training and metrics](https://blog.jetbrains.com/ai/2025/04/mellum-how-we-trained-a-model-to-excel-in-code-completion/)

In July 2025, the company announced local execution of Mellum-all by Ollama or LM Studio at AI Assistant and its own extension to VS Code. The extension uses Mellum-4b-sft-all. It is direct evidence of product for programming on the developer's machine. [Local announcement](https://blog.jetbrains.com/ai/2025/07/whats-new-with-mellum-expanded-language-support-and-new-ways-to-use-it-locally/) and [demonstrable extension](https://marketplace.visualstudio.com/items?itemName=JetBrains.local-mellum).

Classification: product in use, specialized model and documented local path. The main specialty of this version is completion, not autonomous resolution of any engineering task.

### Google and FunctionGemma for tools on device

FunctionGemma is a 270M variant specialized in function calls. Google reports an increase from 58% to 85% in the Mobile Actions review after fine-tuning, in separate evaluation set. The December 2025 announcement includes Tiny Garden at the AI Edge Gallery and Physics Playground in the browser as local demonstrations. [Announcement and demonstrations](https://blog.google/innovation-and-ai/technology/developers-tools/functiongemma/)

There's one [Official tuning notebook for Mobile Actions](https://github.com/google-gemini/gemma-cookbook/blob/main/FunctionGemma/%5BFunctionGemma%5DFinetune_FunctionGemma_270M_for_Mobile_Actions_with_Hugging_Face.ipynb). The result connects specific training and execution on the device, but measures mobile actions, not programming. For QA, a restricted tool controller is an application to investigate; the study does not demonstrate a general test agent.

Classification: benchmark of the authors and reproducible demonstrations; no identified business client or monetary savings measured in this announcement.

### Rocketgraph with distil labs and IBM Power

In October 2025, Rocketgraph published a solution based on Granite 3.3 8B fine-tuned for its OpenCypher dialect. It describes more than 15 thousand validated examples and execution on IBM Power infrastructure. The report claims query translation in under 200 ms, compared with 2–5 seconds for remote LLMs including network time. It also claims to achieve 85% of Claude 4 performance. [Rocketgraph Report](https://rocketgraph.com/2025/10/distil-labs-enables-rocketgraphs-private-ai-on-ibm-power/)

The case does not support saying that 8B overcame Claude 4: 85% is a relative comparison whose protocol is not detailed enough on the page. Ads of 10 times more speed and 100 times less energy should remain as supplier claims, without treating them as controlled hardware comparison.

The publication of distil labs explains the specialization: generalist models generated incompatible Cypher syntax and omitted specific functions of the product. Documentation and examples were converted into synthetic data validated in the system itself. [Adaptation process](https://www.distillabs.ai/blog/distil-labs-enables-rocketgraphs-private-ai-on-ibm-power-with-small-language-models/)

Classification: commercial solution reported by the company incorporating it, with identified infrastructure. It is a precedent close to specializing a model for APIs, libraries or internal languages.

### Knowunity and savings from specialization in production

Knowunity uses custom distil labs models for selected tasks, including classification of questions by school subject. The supplier shall publish a separate comparison of the test set and costs obtained from use in production for several days:

| Metric | Gemini 2.5 Flash Lite | Specialized model |
|---|---:|---:|
| Accuracy | 81% | 93% |
| Latency p50 | 0.49 s | 0.27 s |
| Latency p95 | 0.81 s | 0.59 s |
| Cost per million requests | US$ 109 | US$ 35 |

The report assigns approximately 68% of savings to the selected tasks. The latency tests used bursts of up to 10 requests/s, while the reported production traffic exceeds 130/s. Therefore, the table does not directly measure latency in this higher load. [Case Knowunity](https://www.distillabs.ai/blog/how-knowunity-used-distil-labs-cut-llm-bill-68-percent/)

Classification: identified commercial case and supplier metrics with CTO statement. It documents reported savings of specialization; the described implementation uses the supplier's inference platform and does not prove on-premises execution. The exact number of parameters of the deployed model is not reported.

### Octodet and specialized log analysis

Distil labs reports adjustment of Llama 8B for Octodet, using security knowledge and synthetic examples. The evaluation assigns scores by LLM evaluator to four parts of the response. The aggregate was 57% versus 47% of the best LLM compared; in the classification section, 88% versus 63% of Qwen3-235B-A22B. [Method and results](https://www.distillabs.ai/blog/teaching-small-language-models-new-skills-training-a-local-cybersecurity-agent/)

These numbers are scores of the described protocol, not sensitivity, specificity or detection rate proven in actual incidents. The [deployment page](https://www.distillabs.ai/use-cases/regulated-and-on-prem/) informs execution on-premises.

Classification: customer identified in supplier's report, with comparison of specialization and private deployment. The use case is security; the application to triage of test logs and CI is a transfer hypothesis.

### Mistral and All Hands AI with Devstral

The original Devstral, published in May 2025, was trained to solve real issues and reached 46.8% in SWE-bench Verified. Mistral reports overcoming DeepSeek-V3-0324 of 671B under the same agent OpenHands. The ad includes documentation and video tutorial for local use. [Devstral Ad](https://mistral.ai/news/devstral/)

The [technical article](https://arxiv.org/abs/2509.25193) describes Devstral-Small as a 24B model adjusted for code agents. It is more direct evidence of specialization for software engineering than FinQA, although the result is still benchmark.

For the later Devstral Small 2 generation, the Vibe documentation provides deployment by local API and indicates GPU from 24 GB to 4 bits and 32K context. This setting is not the condition of the original Devstral benchmark and does not automatically inherit its score. [Offline Use Guide](https://docs.mistral.ai/vibe/code/cli/offline-models)

Classification: open model, benchmark and documented local integration; no corporate productivity gain assigned here.

### Salesforce with APIGen and xLAM

Salesforce published xLAM in sizes of 1B and 7B, among others, specialized in function calls. APIGen pipeline combines 3,673 executable APIs into 21 categories and validates example format, execution, and semantics. In the BFCL V1 at the time, the company reported that xLAM-7B surpassed models GPT-4 and Claude 3 Opus. [Publication of September 2024](https://www.salesforce.com/blog/xlam-large-action-models/) and [APIGen article](https://arxiv.org/abs/2406.18518).

Classification: research with public models and data. The historical comparison supports specialization for tools; it is not a current classification of models or proof that Salesforce customers run xLAM on their own computers.

### Microsoft Research with rStar-Coder

The RStar-Coder article, from May 2025, describes 418,000 competitive programming problems and 580,000 verifiable reasoning and testing solutions. Qwen2.5-7B reports from 17.4% to 57.3% in LiveCodeBench; 14B goes from 23.3% to 62.5%. [Article](https://arxiv.org/abs/2505.21297)

Classification: specialization research with gain measured in programming. Benchmark is not equivalent to repository maintenance, and the study does not feature a team of developers using the locally in production model. It also does not show adjustment cost comparable to the FinQA $500.

### NVIDIA Research and architectures with various model sizes

The position article Small Language Models are the Future of Agentic AI recommends specializing small models for repetitive steps and booking larger models for broader needs. It proposes a heterogeneous architecture and an approach to converting LLM-based agents to SLM. [Study Page](https://research.nvidia.com/labs/lpr/slm-agents/)

Classification: technical argument and architectural proposal, not customer case or universal proof of savings. It is useful as a basis for separating subtasks from a development agent.

### What these cases add to the decision

| Question | Evidence more directly related |
|---|---|
| Is there code product with small model available locally? | JetBrains Mellum |
| Adjustment of a tiny model improves tool calls? | Google FunctionGemma |
| Does a company incorporate a specialist in its own infrastructure? | Rocketgraph in IBM Power |
| Is there a published savings in production? | Knowunity, on selected tasks and hosted inference |
| Can a smaller model overcome a larger one in software engineering? | Devstral, under the published SWE-bench/OpenHands protocol |
| Verifiable data improves small code models? | Microsoft rStar-Coder |
| Is there a precedent for logs specialized in private environment? | Octodet, with evaluation by LLM judge |

The methods differ: GRPO in FinQA, adjustment and DPO in Mellum, supervised data and distillation in other cases. The set supports specialization, assessment by task and choice of adequate size; it does not allow all gains to be attributed to the same training method.

## Small models specialized in code: benchmarks and scope of evidence

Enlarged research on October 16, 2026. “Little” in this section mainly identifies dense models of 4B–14B; 24B–32B come as comparison. Cheap API model does not imply few parameters, and active MoE parameters do not equal the memory required to store all weights.

### External model evaluation: Aider

Aider’s historical editing benchmark requires modifying Python files in 133 Exercism exercises and correctly applying the changes. It is an evaluation external to the model developers, run with the Aider agent; it does not represent all engineering work. It was replaced by the harder Polyglot benchmark.

| Model | Editing historical result | Registered format |
|---|---:|---|
| Qwen2.5-Coder-7B-Instruct | 57.9% | whole |
| Qwen2.5-Coder-14B-Instruct | 69.2% | whole |
| Qwen2.5-Coder-32B-Instruct | 71.4% | diff |
| Yi-Coder-9B-Chat | 54.1% | whole |

These results show useful ability of small editing experts, but should not be read as percentages of productivity or resolution of business issues. The formats and settings differ. [Original table and protocol](https://aider.chat/docs/leaderboards/edit.html)

### Specialization to solve issues: SWE-Lego 8B

The SWE-Lego adjusts Qwen3-8B by supervised training, with agent trajectories and intermediate error management. Report **42.2% pass@1 in SWE-bench Verified**; with 16 trajectories and selection by verifier, comes to **49.6%**. 32B reaches 52.6% and 58.8%, respectively. There are code, data and scripts published.

It is evidence directly related to the maintenance of repositories, closer to development work than competitive programming. However, the numbers are of the authors, not an independent reproduction. TTS@16 consumes multiple attempts and a verifier: it is not equivalent to the cost of an 8B call. The publication does not prove the same score after quantization or on a notebook. [Project, method and results](https://swe-lego.github.io/)

### Business evidence and other experts already documented

| Case | What it supports | What remains unproven |
|---|---|---|
| JetBrains Mellum 4B | Autocomplete commercial product specialist; documented local option | Cloud production metrics do not automatically measure local version |
| Microsoft rStar-Coder 7B | Big gain in LiveCodeBench after specialization | Enterprise productivity and total training cost |
| Devstral 24B | Specialist in engineering agents and documented local deployment | Same quality and latency in the quantization chosen by the user |
| Salesforce xLAM 1B/7B | Tool Call Experts | General performance as a code agent or adoption on client desktops |

The sources and numbers of these cases are in the respective previous sections. Among the cases found, Mellum is the most direct example of small code product; SWE-Lego is an issue resolution research. I did not gather both under the proven corporate deployment label.

## Hybrid architectures exclusively local + cloud

Scope fixed by user's express request: the hybrid must run an LLM on the developer's machine or on its own server and another on the cloud. Combinations exclusively between remote APIs were removed from this section and from synthesis. The execution of local tools by a remote model without a local LLM does not meet the criteria.

### Nav: Code delegation to Qwen on Mac, with Claude in the cloud

The public repository `navikt/mlx-workspace` documents a study of august 2026 with Claude Sonnet 4.6 as remote orchestrator and Qwen3.6-35B-A3B-OptiQ local, mixed quantization 4/8 bits, in M4 Max with 48 GB. The hybrid arm uses opencode; the comparison with local sessions in the Copilot CLI is another experiment.

In Ktor tasks, the median dropped from US$ 0.106 to US$ 0.085 in renaming and from US$ 0.339 to US$ 0.134 in spreading a field: approximately 19% and 61% in cloud savings, with the same results in verifications. However, the analogous task in Spring cost 1.79 times more in the hybrid. There are small samples by comparison; the suite already presented flaws before the changes and the criterion considers new failures.

It is organizational evidence with code and public results, no independent audit or savings of the entire organization. The cost does not include TCO from Mac. The model has 35B total parameters and 3B active: it does not occupy the memory of a dense 3B model. [Technical report](https://github.com/navikt/mlx-workspace/blob/main/reports/local-inference-findings.md)

### MCCom: autocomplete with a 121M local model and a cloud model

The article Balancing Latency and Accuracy of Code Completion via Local-Cloud Model Cascading describes a local model of 121 million parameters and remote model drive guided by user actions. Includes speculative decoding and iterative context retrieval.

In RepoEval and StmtEval, authors report up to 47.9% less latency and 46.3% less use of LLM, with reported improvement of 8.9% in exact match. Reduction of use does not automatically equate to the same monetary reduction. It is accepted research in the FSE 2026, according to registration, not corporate case in production. The result is autocomplete lines, not complete resolution of issues. [Article](https://arxiv.org/abs/2603.05974)

### Hybrid Coding Arena: a reproducible laptop benchmark

RunAnywhere publishes an environment comparing local, remote and hybrid routes in a 64 GB Max M4. The Cline + Qwen3.6 + cascade scenario records 24/24 approvals on tasks D1/D5, cloud fraction of 8% and US$ 0.022 per task. This fraction should not be converted into 92% of total savings.

Configuration, results and methodology files are available. It is benchmark of the proponents themselves, with few types of tasks and repetitions; 24 executions do not mean 24 distinct tasks. The historical label “refactors” includes functionality additions and scripts. It is not customer deployment or performance proof in large repositories. [Repository and limitations](https://github.com/RunanywhereAI/hybrid-arena)

### MinionS: Local execution with cloud coordination

The work of Stanford et al. makes the remote model decompose the task and local model process parts of the documents, returning selected results. Report **5.7 times less remote cost**, preserving **97.9% of performance** the exclusively remote execution. This corresponds to approximately 82.5% reduction in remote expenditure, with small relative loss of performance.

The tests involve financial, medical and scientific documents; they are not programming benchmarks. The number is remote inference cost, not TCO with purchase of hardware, power and local operation. It is a demonstration of research, with no business case of proven code in this publication. It serves as the basis for testing local reading of files and sending of reduced context, application that here is our inference. [Article Minions](https://arxiv.org/abs/2502.15964) and [technical demonstration](https://hazyresearch.stanford.edu/blog/2025-02-24-minions).

## Use cases to demonstrate savings with local + cloud

Extension of October 16, 2026, focused on economic results. API savings, reduction of tokens and TCO are different metrics. The numbers below belong to the study conditions and prices; they are not automatic projections for current models or for any team.

### HERA: code generation and agents with locally executed steps

Research by the University of Virginia with Microsoft authors, using local models via llama.cpp in RTX 4090 and remote API models. The main pair is Mistral 7B + GPT-4; there is also evaluation with Llama 8B + Claude 3.5.

| Evaluated use | Cloud only, US$/request | Hybrid, US$/request | Reduction calculated from the table |
|---|---:|---:|---:|
| Function Generation, HumanEval | 0.056 | 0.044 | 21.4% |
| Multiple-step questions, HotpotQA | 0.054 | 0.043 | 20.4% |
| Shopping Agent, Webshop | 0.084 | 0.058 | 31.0% |

The table monetizes remote use, treating the local model as zero cost; it does not include acquisition, energy and maintenance. There is a loss of quality in relation to the entirely remote execution. The text also alternates references to GPT-4/GPT-4o and roundes the economic range, so the values serve as historical experimental evidence, not current budget. It is not Microsoft's productive deployment or independent validation. [HERA, configuration and table 3](https://arxiv.org/html/2504.00434v1)

### Enterprise engineering: simulated total hybrid savings, including repairs

Inference Economics of Enterprise Coding Agents accompanies a developer in two 28-day periods, comparing Claude by API and GLM on-premises. Then simulate hybrid routing over 613 commits, assigning infrastructure, operation and repair work costs.

| Policy in the replay | Estimated TCO | Savings versus API | Simulated proportion of repair commits |
|---|---:|---:|---:|
| Only Claude/API | US$ 11,419 | Reference | 49.1% |
| High-difficulty tasks in the cloud; the rest local | US$ 8,412 | 26.3% | 64.6% |
| High- and medium-difficulty tasks in the cloud; the rest local | US$ 9,890 | 13.4% | 57.9% |

It is counterfactual simulation with observed data, not savings performed by a hybrid gateway. It depends on shared GPU allocation, Taiwan's work costs and linear scalability hypothesis. The periods were not randomized and also change tools/configurations; they do not causally isolate the model. FCR is a proportion of commits classified as repair, not percentage of users affected by bugs. [Study, section VI-C and table XIV](https://arxiv.org/html/2607.13080v1)

### DeloitteSage: a business case for a cost-efficient architecture, without a published percentage

Deloitte and Intel document an accelerator with Llama 3.1 8B on AI PC and Claude via Bedrock for IT support. For summarization, it combines the same local 8B with remote Llama 3.1 70B. TechSage attends queries and troubleshooting; MeetingBuddy summarizes meetings and schedule follow-up. Routing considers complexity, available resources and data sensitivity.

The material demonstrates a concrete business application of local + cloud designed to reduce remote spending, but does not present financial table before/after, number of users, audited savings or independent benchmark. It should illustrate architecture and uses, not substantiate a percentage of savings. We did not attribute to it the 55% of another Deloitte CPU study in AWS, which is outside this scope. [DeloitteSage case, especially pages 3–4](https://www.deloitte.com/content/dam/assets-zone3/us/en/docs/services/consulting/2025/deloittesage-case-study.pdf)

### What to use in economic argumentation

| Usage | Proper evidence | Sustained statement |
|---|---|---|
| Mechanical changes in code | Nav Experiments described above | Delegation to the local model saved remote expenditure on specific tasks; the result may reverse |
| Function Generation | HERA | There is monetized reduction of API in benchmark, with local cost excluded and quality tradeoff |
| Reading extensive documents | MinionS | Reducing remote processing can greatly reduce remote expense |
| Difficulty routing in business repository | Replay of the Inference Economics study | Hybrid TCO can be smaller even including repairs, under explicit hypotheses |
| IT support and meeting summary | DeloitteSage | Large company developed local architecture + cloud for efficiency; undisclosed numerical savings |

For QA, the studies consulted do not yet offer a strong case of monetary savings in production with local + cloud test generation and equivalent quality. Code benchmark and acceptance of patches do not replace rate of defects detected by tests.

### Results not accepted as proof of savings in production

- **Local-Splitter:** announces 45–79% less tokens, but the evaluation also executes the model that represents the cloud locally: Gemma 3 4B, with Llama 3.2 3B on the other role. Use ten synthetic samples per class and limited quality evaluator. It is exploratory simulation of techniques, not demonstration of reduction of a real cloud invoice. [Limitations and configuration](https://arxiv.org/html/2604.12301v1)
- **Inference Sentinel:** reports US$ 0.0844 against US$ 0.2687 of hypothetical baseline, or 68.6%. There are 200 synthetic prompts, zeroed local cost, greater local latency and no demonstration of functional equivalence. There is divergence between legend and table in the local fraction. We do not use it as a business case or as evidence of savings while maintaining quality. [Results and limitations](https://kraghavan.ca/llm/infrastructure/benchmarks/2026/03/21/inference-sentinel-benchmarks2.html)
- **Oflight:** it presents anonymous client and divergent numbers between the title of 55% and the table of 65.6%; does not publish logs or comparable quality evaluation. It does not integrate the main set of economic proof. [Supplier report](https://www.oflight.co.jp/en/columns/hybrid-ai-cloud-local-llm-cost-reduction-2026)

### How to turn these cases into a return calculation

For a proposed implementation, first measure the difference of remote expenditure per task completed, maintaining the same quality criterion. Then subtract incremental local cost and additional review/rework. The initial investment should be compared with the monthly net savings, not tokens eliminated.

`net monthly savings = avoided API spending − additional local energy/operations − additional review/rework`

`payback in months = initial investment / net monthly savings`

For TCO accounting, include depreciation and recurring hardware costs; for payback, use the initial investment without again discounting its depreciation in cash flow. Existing equipment has lower incremental disbursement, but can still have opportunity cost and impact on the developer's work. These are calculation guidelines, not economies observed in sources.

## Engineering focus: backend, frontend/UI and testing

Enlarged research on October 16, 2026. Maintained the requirement of a local LLM effectively combined with a remote LLM. Economic evidence is more solid for delimited editing than for integral application creation or test generation.

### Nav: extending the analysis to TypeScript frontend and tests

In addition to the previously described backends, the study evaluated renaming in `familie-tilbake-frontend`, with React 19 and Express 5. The remote median dropped from **US$ 0.227 to US$ 0.121**, calculated reduction of **46.7%**; eight executions per arm passed through checks, in suite of 61 files and 572 tests. This measures frontend code maintenance, not visual UI quality.

In unit tests, encouraging local delegation resulted in a failure between two delegated samples. In the investigation of three frontend bugs, the isolated local model solved none. They are small samples and distinct conditions; they do not show savings in QA. The report itself excludes generalizations for sustained use by the team. [Nav study, sections 3.4, 7.3 and 7.4](https://github.com/navikt/mlx-workspace/blob/main/reports/local-inference-findings.md)

### Pulpcut: implementing visual effects with a local executor

Developer reports adding texture support and blending to frontend Pulpcut, delegating `visualTexture.ts` and methods of integration with FabricCanvasManager to local models in RTX 5060 Ti 16 GB. The remote model coordinates, reviews and integrates; TypeScript, lint and tests validate. The preferred executable was Qwen3-Coder-30B.

In one session, reported about US$ 10.60 of remote cost and US$ 1.80 of equivalent cost avoided by approximately 99,000 local tokens. The latter value is counterfactual estimate, not the result of performing the same task fully in the cloud. It does not include hardware, energy and review. The savings of 20–75% mentioned by the author are expectations, not proven benchmarks.

It is an individual primary report, with published instructions, without audit or controlled repetition. It is useful for describing concrete UI work, but weak to design business savings. [Experience report](https://www.reddit.com/r/vibecoding/comments/1t9eqad/i_tested_a_hybrid_localmodel_frontiermodel_coding/) and [orchestration configuration](https://gist.github.com/AlexanderIstomin/ac7469ebaf7cba1e23bba328f424a48f).

### UI and backend E2E tests: local vision + remote generation

The paper Agentic AI-Based Automated Test Case Generation and Execution describes a shift-management application: DOCX requirements are processed by an LLM through the Groq API; eight screenshots are analyzed by local LLaVA through Ollama. The workflow produces Gherkin scenarios, human review and Python scripts with Playwright/Pytest, including UI interactions and API checks.

It is an effective example of the requested architecture applied to tests. However, the published comparison mainly uses qualitative classifications, does not disclose cost before/after and does not isolate the gain of performing vision locally. The implementation in CI appears as future work. Therefore, classified as a limited academic demonstration of hybrid QA, without proven economics. [Article, sections 5 and 6](https://www.irjet.net/archives/V13/i4/IRJET-V13I04372.pdf)

### Agentic QE: local generation with repair, integration still to be verified

The project offers Qwen3-Coder-30B via Ollama to generate tests and repeat the attempt after rejection. The documentation presents configuration together with remote agents, but contains a divergence: README announces fallback, while the guide explicitly informs that the current modality is local with repair, without automatic escalation for paid models. We do not treat the local cascade→cloud as confirmed end-to-end functionality.

The objective test described verifies the presence of test blocks and assertions; this is not equivalent to compilation, execution or mutation score. Without cost measured by useful test published on these pages, it is an implementation candidate, not a case of savings. [README](https://github.com/proffesor-for-testing/agentic-qe) and [functionality status guide](https://github.com/proffesor-for-testing/agentic-qe/blob/main/docs/guides/free-tier-local-models.md).

### Related examples that do not count as local + cloud hybrids

- **Cascaded Code Editing:** combines large and small model, but monetary valuation uses call prices to DeepInfra. It does not sustain the savings of a local deployment + cloud. [Cost method](https://arxiv.org/html/2604.19201v1)
- **CodeLead/Silicon Exchange** demonstrates React/TypeScript application construction, business rules and testing with local model, comparing separate local and remote executions. It does not show the cost of a hybrid joint execution. [Demonstration and limits](https://codelead.dev/case-study/)
- **QAMind:** generates tests with local Qwen, although the application uses servers for other components. The page informs that remote inference is a future possibility; local LLM hosted application does not equal two local LLMs + cloud. [Architecture](https://www.qamind.ai/local-ai)

### Evidence Matrix for Software Engineering

| Area | Case within the scope | Evidence of savings | Limit |
|---|---|---|---|
| Backend Kotlin/Ktor | Nav, field propagation and renaming | Measure in tasks, described above | Does not represent any backend change |
| Backend Spring | Nav | Countervailing: delegation increased cost | It prevents you from promising a universal savings |
| Frontend React/TypeScript Maintenance | Nav | 46.7% less remote expense in the experiment | Renaming; not visual design |
| UI/canvas implementation | Pulpcut | Local Tokens and Estimated Cost Avoided | No controlled comparison or TCO |
| E2E tests and API validation | Article with LLaVA + Groq | Not published | Demonstrates architecture and script generation |
| Generation of unit tests | Agentic QE | Not published | Contradictory fallback status; limited validation |
| Autocomplete | MCCom, previous section | Less remote usage, no invoice comparison | Completing lines is not delivering features |

To support an savings proposal, prioritize maintenance tasks with verifiable output and compare the cost per approved change. For UI, add visual criteria, accessibility and interaction; for QA, measure defects found and non-trivial tests. These criteria are a proposal for our evaluation, not results already demonstrated by the cases.

## How to reduce bias in evaluation

There is no guarantee of “not biased” benchmark. In this study, we distinguished external evaluation to the manufacturer, reproducible results from authors and commercial reports. Open code facilitates auditing, but does not transform a self-reported result into independent validation.

The **LLMRouterBench** it brings together more than 400,000 instances, 21 datasets, 33 models and ten routing methods. By re-evaluating methods under common protocol, you find several recent routers, including commercial ones, that do not consistently overcome a simple baseline. It also observes decreasing returns when increasing the set of models. It is a methodological reference on the evaluation of routers, not evidence of local deployment + cloud; its coverage does not replace tests in the company’s repository. [Paper and resources](https://arxiv.org/abs/2601.07206)

For a code comparison and QA, we propose the following protocol, as our methodological recommendation:

1. Use real issues and defects separated by date and repository of adjustment data; reserve unpublished tasks for the final test.
2. Compare the same agent, tools, context, limit of attempts and deadline in four conditions: strong model, expert alone, routing and division in specialists.
3. Run functional and regressive tests. For test generation, also measure detected defects and mutation score, avoiding using line coverage only.
4. Measure cost per task correctly completed, p50/p95 latency, human review, scaling, repetition and cache. Repeat executions and report variation.
5. Evaluate the quantized model in real hardware. Separate API savings, total cost of inference and return including training and maintenance.

A minimum account for the waterfall that always tries the small first is:

`average cost = small-model cost + escalated fraction × large-model cost after escalation + validation + allocated infrastructure/operations`

The large-model cost after escalation may include all previous context and a new attempt. With direct routing, the small-model call does not occur on every task. For hybrids organized by subtask, the costs of all components are added. The final metric should divide the full expense by the number of accepted tasks, including spending on failures.

### Summary for adoption

| Need | Evidence That Helps Most | Main limitation |
|---|---|---|
| Small specialized autocomplete | Mellum | Separate cloud and local metrics |
| Small open agent for issues | SWE-Lego 8B | Result of the authors; cost and quantization to be measured |
| Local code delegation + cloud in organization | Nav: Qwen on Mac + Claude remote | Savings changes according to task; limited study, not TCO |
| Autocomplete local + cloud with tiny specialist | MCCom 121M | Less remote use is not measured monetary savings |
| Local routing playback + cloud | Hybrid Coding Arena | Small set of tasks; results of the proponents |
| Local effective collaboration–cloud | MinionS | Documentary Benchmark and Remote Cost |
| Choose router without marketing depend | LLMRouterBench and internal evaluation | No router dominates all distributions |

The evidence favors small specialists for bounded tasks and hybrid systems evaluated by cost per correct task. We have still not found, in these sources, a case that simultaneously combines a small local coding LLM, an identified user company, audited total savings and an independent controlled comparison. This defines the limits of what has been demonstrated, without invalidating the partial product and research results.

## Mac benchmarks from 16 to 512 GB: RAM, SSD and generation

Research consulted on **16/10/2026**. The numbers below are measurements published by users and runtime developers, not tests performed by us. There is no single test here that simultaneously controls chip, quantization, context and software in all capabilities. **Do not interpret the table as a ranking by RAM capacity.** The section “Expanded coverage: 4 and 8 bits” below complements this cutout with controlled pairs and faster settings; the first tables do not represent a performance ceiling. NR means unreported/verified in the source consulted.

### What to Measure: Prefill, Reasoning and Final Response

- **PP/prefill:** prompt token processing. It's not the speed of reasoning.
- **TG/decode:** generation of new tokens, including reasoning tokens when the model generates them. Many sources add reasoning and final response.
- **Reasoning tok/s and output tok/s:** may differ empirically, by content, growing context, moe routing and acceptance of speculative decoding. There's no universal multiplier between them. A test with thinking off doesn't measure Reasoning.
- **TTFT:** time until the first token; register whether it includes loading and counts the first reasoning token or only final content. For agents it is also important the time until the first executable tool call.
- **Time per task:** includes reading of the repository, reasoning, editing, tools, testing and new attempts; it is more useful economically than the peak of tokens/s.

In sources that do not separate the phases, we report **Aggregated decode**, without inventing two speeds. Approach to plan an execution: `time = loading + prefill + reasoning_tokens / reasoning_rate + response_tokens / response_rate + tools`. For example, 4,000 tokens of reasoning at 20 tok/s already require 200 seconds before the answer; this is an illustrative calculation, not a benchmark.

### Memory-resident models: measurements on smaller and midrange Macs

“Resident” in this table describes compute weights loaded into memory, without deliberate streaming of experts. It does not guarantee the absence of memory pressure caused by other applications. GB and GiB are maintained according to the sources.

| RAM / chip | Model and format | Runtime and load | PP tok/s | TG tok/s | Memory/observation | Source |
|---|---|---|---:|---:|---|---|
| 24 GB / M4 Pro | Qwen3.8-27B Q4_K_M | llama.cpp b10488; pp2048/tg128; 3 repetitions | 96.8 | 11.4 | File 17.77 GB; adjusted GPU memory limit | [Author](https://www.reddit.com/r/ollama/comments/1vrqi3d/qwen3827b_on_a_24gb_m4_pro_mac_mini_benchmarks/) |
| 24 GB/same M4 Pro | Qwen3.8-27B IQ4_XS | Same protocol | 95.4 | 10.9 | File 15.57 GB; leaves more space for context | [Author](https://www.reddit.com/r/ollama/comments/1vrqi3d/qwen3827b_on_a_24gb_m4_pro_mac_mini_benchmarks/) |
| 32 GB/M1 Max, GPU 24 cores | Qwen3.8-27B MLX 4-bit | 512 input / 700 output; 3 runs | 81.76 | 15.81 | Peak 16.39 GB | [Author](https://www.reddit.com/r/LocalLLM/comments/1wa0dl3/qwen3827b_on_m1_max_32gb_mlx_158_toks_vs_llamacpp/) |
| 32 GB / same M1 Max | Qwen3.8-27B UD-Q4_K_M | llama.cpp, Metal and Flash Attention; same load | 99.61 | 9.69 | Different quantization: does not isolate runtime alone | [Author](https://www.reddit.com/r/LocalLLM/comments/1wa0dl3/qwen3827b_on_m1_max_32gb_mlx_158_toks_vs_llamacpp/) |
| 48 GB/M4 Pro | Qwen3.8-27B 4-bit | Rapid-MLX 0.13.1; Community submission | 117 | 15.2 | Peak 18.9 GB; TTFT 18.2 s; a submission | [Registration](https://rapidmlx.com/benchmarks/qwen3.8-27b-4bit/apple-m4-pro) |
| 64 GB/M2 Max | Qwen3.6-27B NVFP4 | Ollama/MLX; short/medium/long prompts; thinking off | NR | 17.2 / 17.0 / 16.8 | Median 3 runs; output limited to 256 tokens | [Experiment](https://github.com/robgil/local-ai-benchmark-mac-stuido-m2) |
| 64 GB / same M2 Max | Qwen3.6-35B-A3B NVFP4 | Same set of scenarios | NR | 71.3 / 69.3 / 67.8 | Author informs approximately 21 GB residents | [Experiment](https://github.com/robgil/local-ai-benchmark-mac-stuido-m2) |

In the last pair, MoE 35B is approximately four times faster than the dense 27B in this test. This does not demonstrate four times more quality, nor does it guarantee the same advantage with another runtime. The repository publishes scripts, but indicates output files ignored by Git; we do not treat this as independent reproduction.

### Flash-Next and larger models: memory and SSD

There are three different situations: **resident weights**, **lookup of embeddings on SSD** and **streaming experts on SSD**. The second makes sparse access to tables; the third moves weights necessary for calculation. macOS Swap is a fourth situation and does not equal an optimized offloading mechanism.

| RAM / chip | Model / format | Residence and runtime | Load | PP tok/s | TG tok/s | Source |
|---|---|---|---|---:|---:|---|
| 64 GB / M5 Pro | Qwen3.8-Flash-Next V3, mixed quantisation, 95.5 GiB | Experts and table in SSD; fork llama.cpp; active draft | Prompt ~4K | ~367 | ~27.6 | [Author and fork](https://www.reddit.com/r/LocalLLaMA/comments/1wk14il/qwen38flashnext_955_gib_on_a_64gb_mac_at_27_toks/) |
| 64 GB / same M5 Pro | Same V3 checkpoint | SSD; Slipstream; temperature 0 | Python `merge_intervals` | NR | 35.0 | [Comparison of the author](https://www.reddit.com/r/LocalLLaMA/comments/1wva7l2/running_955_gib_qwen38flashnext_at_4152_toks_on_a/) |
| 64 GB / same M5 Pro | Same V3 checkpoint | SSD; Slipstream | Parser CSV Rust | NR | 37.5 | [Same experiment](https://www.reddit.com/r/LocalLLaMA/comments/1wva7l2/running_955_gib_qwen38flashnext_at_4152_toks_on_a/) |
| 96 GB/M2 Max, GPU 38 cores | Flash-Next oQ4e-MTP | oMLX 0.7.0.dev4; offload expert; KV 8-bit, MTP | 8,192 tokens | 315.1 | 30.4 | [Registration](https://omlx.ai/benchmarks/performance/pjf8s09q) |
| 128 GB / M5 Max | Flash-Next UD-IQ4_XS | initial llama.cpp/Metal without MTP; table via mmap | pp512/tg128, initial depth zero | 966 | 33.0 | [Heretik](https://heretik.io/qwen38-flash-next-262k-macbook/) |
| 128 GB / M5 Max | Flash-Next Optimized Speed, 4-bit dynamic | MTPLX 2.12.0; resident weights, SSD table, MTP | 4,061 input / 512 output, thinking off | 1,453 | 74.1 | [Developer](https://www.mtplx.com/models/qwen3.8-flash-next/) |
| 192 GB/M2 Ultra, GPU 76 cores | Flash-Next oQ4e-MTP | oMLX 0.7.0.dev2; KV 2-bit, MTP | 8,192 tokens, Python | 745.3 | 57.6 | [Registration](https://omlx.ai/benchmarks/performance/juqwik8d) |
| 256 GB / M3 Ultra | Flash-Next 4-bit | Rapid-MLX 0.13.2; resident without MTP | 8,156 input / 256 output | 883.1 | 23.40 | [Model card and protocol](https://huggingface.co/rapid-mlx/Qwen3.8-Flash-Next-4bit) |
| 256 GB / same M3 Ultra | Same Flash-Next 4-bit | Separate experiment, fixed MTP K=1 | 8,156 input / 256 output | NR | 32.20 | [Same study](https://huggingface.co/rapid-mlx/Qwen3.8-Flash-Next-4bit) |
| 256 GB / M3 Ultra | GLM-5.3-Flash 320B, 4-bit | Rapid-MLX 0.13.4 candidate; resident without speculation | 8,192 input / 256 output | 359.6 | 27.75 | [Logs and methodology](https://github.com/raullenchai/Rapid-MLX/blob/main/docs/benchmarks/recent-large-models-m3-ultra.md) |
| 256 GB/M5 Ultra, GPU 80 cores | Qwen3.6-35B-A3B 4-bit | oMLX 0.7.0, MTP, KV 8-bit | 32K / 128 output, warm | 7,653 | 135.0 | [Community experiment](https://www.reddit.com/r/oMLX/comments/1wusa85/omlx_070_vs_070rc1_benchmark_what_changed_7/) |
| 256 GB / same M5 Ultra | Flash-Next oQ4e-MTP | Same runtime and protocol | 32K / 128 output | 5,672 | 114.6 | [Same experiment](https://www.reddit.com/r/oMLX/comments/1wusa85/omlx_070_vs_070rc1_benchmark_what_changed_7/) |
| 512 GB/M3 Ultra, GPU 80 cores | DeepSeek-V3-0324 671B, 4-bit | MLX; resident | Short/long prompts; 3 declared executions | See footnote | 20.9 | [Repository](https://github.com/cnrai/llm-perfbench) |
| 512 GB / same M3 Ultra | DeepSeek-R1 Q4_K_M | llama.cpp; resident | Same repository | See footnote | 15.5 | [Repository](https://github.com/cnrai/llm-perfbench) |

Notes on interpretation:

- **64 GB:** The old Flash-Next test dropped from ~27.6 to 3.7 tok/s by overly increasing the expert cache and provoking swap. The new Slipstream publishes an average of 40.8 tok/s in six tasks, but this is the result of the developer himself, not independent validation. The optional Swift variant was not mixed with the V3 checkpoint in this table.
- **96 GB:** peak 74.9 GB in the oMLX record; deactivating offload expert does not prove that the entire n-gram table remains resident. The field `dflash_ssd_cache` refers to cache, does not prove absence of any access to weights in SSD.
- **128 GB/MTPLX:** approximately 83 GB of resident weights plus working memory; n-gram table of 32 GB in SSD. The promotional peak of 125.8 tok/s came from a request with almost all cached prompt; it does not represent cold reading of the repository.
- **192 GB:** peak of 103.9 GB in the registry; the 2-bit KV requires separate quality evaluation.
- **256 GB/GLM:** active memory of 180.6 GB and peak 195.6 GB in test up to 32K. The test was not physically qualified on 192 GB Mac.
- **512 GB:** the repository calls the input metric “input tokenization”, without definition clear enough to match it to PP. We kept out of the PP column the published values of 114.6 and 12.9. V3 occupies 381 GB in MLX; R1 occupies 435 GB on llama.cpp. The title announces 21.4 tok/s for V3, but the table records 20.9; we adopted the table. These are previous models, not DeepSeek V4.1.

### DeepSeek V4.1 Flash: minimum demo and useful streaming

| Host | Implementation | PP tok/s | Decode tok/s | TTFT / condition |
|---|---|---:|---:|---|
| M1 Mac mini, 16 GB | Official weights FP4/FP8; experimental MLX; Internal SSD | NR | **~0.044** | 108.3 s; 22.8 seconds/token, 8 token repeat |
| M5 Max, 128 GB | ds4 upstream, a SSD | 17.96 | 10.18 | 512 input / 200 output |
| Same M5 Max | Fork Argonaut, same SSD | 30.98 | 18.66 | Same comparative session of 27/09 |
| Same M5 Max | Fork, internal SSD + 2 external | 42.41 | 22.25 | Same checkpoint of ~518 GB; median pairs |

The [16 GB experiment](https://github.com/atbender/deepseek-v41-flash-mac-mini) uses approximately 510 GB of files and does not replace the model with a smaller one. Conversion `1 / 22,8` That's 0.044 tok/s. It measures only a few steps and there was use of swap; it proves technical execution, not appropriate to an interactive code agent. The published animation accelerates reproduction 12 times, explicitly informed by the author.

The [Argonaut Labs](https://argonautlabs.ai/) compares the same hardware and checkpoint, with identical outputs verified by hash. “Steady decode” excludes the first step; including this step, the three results are 9.90, 17.45 and 20.74 tok/s. A later configuration of 04/10 prioritizes prefill: 75.06 PP and 19.31 TG with three discs. Do not combine the best PP of this configuration with the best TG of the previous one as if it were an execution. It is research by the system developers, with published data, not external audit.

**Specific gap:** we did not find sufficiently documented benchmark of the **DeepSeek V4.1 Flash on 64 GB Mac**. There's one [discussion with claim of 8.2–9.5 tok/s in M3 Ultra 256 GB to 2-bit](https://huggingface.co/deepseek-ai/DeepSeek-V4.1-Flash/discussions/56), but it gathers references from third parties and does not control runtime/quantization against the M5 Max. We don't use it to conclude that SSD beats RAM.

### Long context: the same machine can deliver very different speeds

Flash-Next UD-IQ4_XS on M5 Max 128 GB, llama.cpp initial, without MTP. The author measured an increase of **512 tokens** at different depths of the KV; these PPs are not the average to fill the entire window from scratch.

| Depth already filled | PP512 tok/s | TG128 tok/s |
|---:|---:|---:|
| 4,096 | 776 | 30.7 |
| 32,768 | 324 | 24.8 |
| 65,536 | 241 | 23.0 |
| 131,072 | 154 | 17.0 |
| 262,144 | 80 | 10.9 |

One run per depth; peak 106 GB wired and approximately 126 GB total at the extreme. The table uses mmap and page cache, so the author’s expression “without offload” does not constitute proof that each checkpoint page was permanently in RAM. [Method and results](https://heretik.io/qwen38-flash-next-262k-macbook/)

For Qwen3.8-27B, the developer MTPLX publishes 58.7 tok/s on a code task with medium reasoning and 35.1–37.3 on long generations with xhigh, M5 Max and Pack Optimized Speed. That compares. **different complete loads**, does not measure alone Reasoning against final response. The same page documents 30.4 tok/s at 88K and 18.4 to 147K in another version. [Conditions and quantizations](https://www.mtplx.com/models/qwen3.8-27b/)

### What actually fits in each range

The table below is interpretation of capacity from measurements, not a promise of speed or exhaustive enumeration of all possible models.

| RAM | Range of use sustained by evidence | Relevant limit |
|---|---|---|
| 16 GB | DeepSeek V4.1 via demonstrated SSD; no 27B/35B resident benchmark validated in this selection | DeepSeek measured at ~0.044 tok/s; lack of evidence of interactive performance of the models requested in this capacity |
| 24 GB | Qwen3.8-27B Q4/IQ4 with context and environment controlled | Little space for IDE, browser, containers and view; do not assume any Q4 fit |
| 32–36 GB | 27B Q4 and quantised 35B MoE candidates | Direct measurement of 32 GB above; we do not assign 36 GB extrapolated speed |
| 48–64 GB | 27B/35B Q4–Q8, as checkpoint and context | 64 GB also has Flash-Next demo with streaming experts |
| 96 GB | Quantized Flash-Next with residence/lookup care | Runtime and quantization decide how much must remain in GPU memory |
| 128 GB | Flash-Next Q4; DeepSeek V4.1 with SSD | Maximum context, concurrency and local applications compete for slack |
| 192 GB | Flash-Next Q4 with larger margin | Do not assume that GLM 320B with 32K fits by weight size |
| 256 GB | Flash-Next in greater precision; GLM-5.3-Flash Q4 measured | Greater precision and more RAM do not guarantee more tokens/s |
| 512 GB | DeepSeek V3/R1 671B Q4 residents demonstrated | Do not automatically extrapolate to all V4.1 tensors |

In the example of approximately 64 GB, **27B and 35B MoE can stay fully in memory in quantized versions**; this does not mean integral BF16. Only the raw weights to BF16 would be approximately 54 and 70 GB, respectively, before caches, buffers and system. Similarly, 35B-A3B activates few parameters per token, but needs to store all experts to be resident.

There is no “largest model that fits” without defining acceptable accuracy and latency: streaming allows you to run much larger checkpoints than RAM, such as DeepSeek in 16 GB, but this execution can be impractical for programming. To choose the working machine, reserve memory for developer tools and compare **time and cost per approved task**.

### Recommended protocol for a reproducible pilot

Our proposal: register complete chip, cores GPU, RAM, SSD/model/interface, runtime/commit, checkpoint review, quantization, KV, MTP/drafter and GPU memory limit. Measure one request at a time and, separately, concurrency from 2 and 4 users. Use 4K, 32K and 128K code prompts; register warmup, at least three repetitions, cold/hot cache, 1,024 generated tokens or natural ending.

Separate tokens and reasoning/response times when protocol provides both; also store TTFT, first final token, first tool, active/peak memory, swap and physical bytes of SSD. Evaluate quants with the same backend, UI and test tasks. Report median and dispersion, and distinguish correct output only fast. These data allow you to compare resident versus SSD without confusing runtime optimization, less accuracy or hot cache with hardware advantage.

## Expanded coverage: 4 and 8 bits, MLX, llama.cpp, Colibri and Engram

Update from 10/16/2026, after the review requested by the user. **Previous selection was insufficient to characterize the available performance.** Their results continue as records of the tested settings, but should not be interpreted as ceiling or typical range of each chip. The expansion prioritizes pairs in the same hardware, includes 27B and 35B on larger Macs and identifies speculative acceleration.

Numbers continue to be published by third parties. Primary source means reporting of the executor itself, not independent validation. A single independent test covering the entire RAM × chip × quantization × runtime × context matrix has not been found. NR = not reported in this selection. RAM in the hardware column is the ability of the tested machine, **not the minimum memory required**.

### Qwen3.8-27B: 4 and 8 bit comparison

| Hardware | Runtime / acceleration | Weight quantization | Load | PP tok/s | TG tok/s | Source |
|---|---|---|---|---:|---:|---|
| M4 Pro, 64 GB | oMLX 0.6.1, MTP | oQ4e | 8K | NR | 20.8 | [A](https://github.com/jundot/omlx/discussions/2811) |
| M4 Pro, 64 GB | Same environment | oQ8 | 8K | NR | 16.6 | [A](https://github.com/jundot/omlx/discussions/2811) |
| M5 Max, 128 GB | MLX 0.32 / mlx-vlm 0.6.14, MTP | 4-bit | PP2048/TG128; depth 0 | 853.75 | 47.00 | [B](https://github.com/NathanMaine/qwen-mlx-offline/blob/main/docs/BENCHMARKS.md) |
| M5 Max, 128 GB | Same environment | 8-bit | Same protocol | 882.74 | 28.72 | [B](https://github.com/NathanMaine/qwen-mlx-offline/blob/main/docs/BENCHMARKS.md) |
| M5 Max, 128 GB | Same environment | 4-bit | Depth 8,192; PP2048/TG128 | 809.78 | 36.05 | [B](https://github.com/NathanMaine/qwen-mlx-offline/blob/main/docs/BENCHMARKS.md) |
| M5 Max, 128 GB | Same environment | 8-bit | Same protocol | 741.25 | 26.44 | [B](https://github.com/NathanMaine/qwen-mlx-offline/blob/main/docs/BENCHMARKS.md) |
| M5 Max, 128 GB | llama.cpp; Flash Attention Off | UD-Q4_K_XL | Separate tests PP512 and TG128 | 753.09 | 25.98 | [C](https://qiita.com/sukimaengineer/items/43049f30df14cb06542b) |
| M5 Max, 128 GB | Same environment | Q8_0 | Same protocol | 703.81 | 17.92 | [C](https://qiita.com/sukimaengineer/items/43049f30df14cb06542b) |
| M3 Ultra, 512 GB | oMLX 0.6.1, MTP | oQ4e | 8K | NR | 65.0 | [A](https://github.com/jundot/omlx/discussions/2811) |
| M3 Ultra, 512 GB | Same environment | oQ8 | 8K | NR | 43.0 | [A](https://github.com/jundot/omlx/discussions/2811) |

**A:** Quants derived from the same master BF16; MLX 0.32, thinking off in comparison. The reporting machines are independent replicas, not a cluster adding their speed. **B:** three repetitions, KV 8-bit, thinking off; resident weights approximately 15.5–15.7 GB in 4-bit and 28.1–28.4 GB in 8-bit. **C:** does not report speculative acceleration in the aforementioned trials. With Flash Attention on, the same test records Q4: 664.82 PP / 25.28 TG; Q8: 645.45 PP / 17.24 TG.

These pairs show the advantage of 4 bit generation in measured conditions. They do not show that 4 bits always improve prefill: in B pair with zero depth, 8 bits had nominally higher PP. MLX and llama.cpp lines use different protocols, quants and acceleration; the table does not establish an isolated victory of a runtime.

### Qwen3.6-35B-A3B: 4/8 bits and acceleration on same Mac

| Hardware | Runtime | Weights | Load | TG without MTP reported | TG with MTP | Source |
|---|---|---|---|---:|---:|---|
| M5 Max, 128 GB | oMLX 0.6.4 | oQ4e | Code request by API | 100.2 | 119.2 | [Author's trial](https://jacar.es/en/how-to-install-and-tune-omlx-on-m5-max-128-gb/) |
| M5 Max, 128 GB | Same runtime | 8-bit | Same load class | 79.7 | 117.5 | [Same test](https://jacar.es/en/how-to-install-and-tune-omlx-on-m5-max-128-gb/) |
| M5 Max, 128 GB | Same runtime | oQ4e | Context of approximately 15K | 100.2 | 115.5 | [Same test](https://jacar.es/en/how-to-install-and-tune-omlx-on-m5-max-128-gb/) |
| M5 Max, 128 GB | Same runtime | 8-bit | Context of approximately 15K | 84.0 | 90.7 | [Same test](https://jacar.es/en/how-to-install-and-tune-omlx-on-m5-max-128-gb/) |

The 4-bit path uses Lightning MTP; the 8-bit path, VLM MTP. Temperature 0.6; the author records strong thermal pressure during much of the collection. Prefill tests embedded in the same article go through another execution path, so they were not combined with these TGs as if they were a single request. They are measurements of the author, without independent reproduction.

An additional comparison in **M1 Max 64 GB** published 35B in 8 bits: **MLX 26.22 TG / ~190 PP**, against **llama.cpp Q8_0 Metal 34 TG / ~245 PP**, with input of approximately 1K. The protocol describes five prompts, three repetitions and outputs of 50/500 tokens; memory peaks of 42 and 44 GB, respectively. Versions and use of MTP are not sufficiently specified for a definitive modern comparison. [SleepyQuant Experiment](https://sleepyquant.rest/blog/mlx-vs-llama-cpp-35b-m1-max-benchmark/)

### 27B and 35B also on 256 and 512 GB Macs

These are additional measurements, not extrapolations from smaller Macs. Larger machines can run small models; you don't need to choose a model that fills your RAM.

| Hardware | Model / weights | Runtime / acceleration | Input or context | PP tok/s | TG tok/s | Source |
|---|---|---|---|---:|---:|---|
| M3 Ultra, 256 GB | Qwen3.8-27B 4-bit | Rapid-MLX, Auto MTP | ~8K | 330.8 | 43.38 | [Protocol and logs](https://github.com/raullenchai/Rapid-MLX/blob/main/docs/benchmarks/recent-large-models-m3-ultra.md) |
| M3 Ultra, 512 GB, GPU 80 | Qwen3.8-27B 4-bit | oMLX 0.5.8.dev2, without MTP/DFlash | 1K | 427.2 | 36.2 | [Registration](https://omlx.ai/benchmarks/performance/ehzfv9r6) |
| Same hardware | Same model | Same runtime | 8K | 416.9 | 34.6 | [Registration](https://omlx.ai/benchmarks/performance/ehzfv9r6) |
| Same hardware | Same model | Same runtime | 32K | 379.8 | 30.5 | [Registration](https://omlx.ai/benchmarks/performance/ehzfv9r6) |
| M3 Ultra, 512 GB, GPU 80 | Qwen3.6-35B-A3B 8-bit | oMLX 0.5.4, VLM MTP | 1K | 2,787 | 92.3 | [Registration](https://omlx.ai/benchmarks/performance/o39q2ywa) |
| Same hardware | Same model | Same runtime | 16K | 2,531 | 82.5 | [Registration](https://omlx.ai/benchmarks/performance/o39q2ywa) |
| Same hardware | Same model | Same runtime | 64K | 1,638 | 68.5 | [Registration](https://omlx.ai/benchmarks/performance/o39q2ywa) |
| M5 Ultra, 256 GB, GPU 80 | Qwen3.6-35B-A3B 4-bit | oMLX 0.7.0, MTP, KV 8-bit | 4K / output 128 | 9,126 | 158.3 | [Community test](https://www.reddit.com/r/oMLX/comments/1wusa85/omlx_070_vs_070rc1_benchmark_what_changed_7/) |
| Same hardware | Same model | Same runtime | 32K / output 128 | 7,653 | 135.0 | [Same test](https://www.reddit.com/r/oMLX/comments/1wusa85/omlx_070_vs_070rc1_benchmark_what_changed_7/) |

Pairs 27B **4/8-bit on M3 Ultra 512 GB** are in the first table of this expansion. In the 35B record of 512 GB, `vlm_mtp_enabled` is active, although another field called `mtp_enabled` be false: classifying this execution simply as “without MTP” would be incorrect. The memory peak ranges from 37.5 GB in 1K to 41.4 GB in 64K. In record 27B without speculation, the peak ranges from 15.8 to 21.6 GB. Having used 512 GB does not mean needing this capacity for these models.

**Accelerated result to follow:** a submission for Rapid-MLX, in M3 Ultra 512 GB with 35B 8-bit, compares 72.94 TG without DFlash with **235.75 TG with DFlash**, generating 1,024 tokens; the acceptance reported was 88.87%. With 4,096 tokens, it records 71.84 against 189.89 TG. Prompt, context, repetitions and version are not sufficiently documented. It is evidence of a faster configuration reported by the executor, but not a sustained guaranteed rate for agents. The repetition of the table in the project documentation does not constitute a second reproduction. [Original submission](https://github.com/raullenchai/Rapid-MLX/issues/472)

### Colibri: offloading measurements and comparison limits

Colibri is an inference runtime with CPU/Metal paths and streaming/cache mechanisms. It is not a quantization equivalent to Q4 or an automatic feature present in MLX or llama.cpp. In this collection, their most documented Mac trials involve large models; we did not find controlled pairs Colibri × MLX × llama.cpp for the same 27B/35B and checkpoint.

| Hardware | Model and implementation | PP tok/s | TG tok/s | Condition | Source |
|---|---|---:|---:|---|---|
| M4 Max, 128 GB | GLM-5.3-Flash int4 g64, Colibri Metal | NR | 1.850–1.895 | Two SSDs; RAM 96 GB budget; output 512; expert cache variation | [Benchmarks Colibri](https://github.com/JustVugg/colibri/blob/main/docs/benchmarks.md) |
| M5 Max, 128 GB | GLM-5.2, Colibri Metal | NR | 2.06 | `--ram 110`; learned pinning 46.9 GB; output 1,024 | [Benchmarks Colibri](https://github.com/JustVugg/colibri/blob/main/docs/benchmarks.md) |
| M4 Pro, 48 GB | GLM-5.2, Colibri | NR | 0.30 Metal / 0.18 CPU | Comparison reported in the project | [Benchmarks Colibri](https://github.com/JustVugg/colibri/blob/main/docs/benchmarks.md) |
| M3 Ultra, 256 GB | GLM-5.2 int4, Colibri Metal | NR | 0.39 → 1.45 | Budget RAM 40 → 160 GB; GPU shared with another load | [Adjustment report](https://github.com/JustVugg/colibri/issues/180) |
| M5 Pro, 48 GB | DeepSeek V4 Flash, Colibri CPU arm64 | 1.33 | 1.28 | 189 cold tokens; output 48; budget 24 GiB; TTFT 142 s | [Executor log](https://github.com/JustVugg/colibri/issues/1696) |
| Same hardware | Same model, hot cache | 1.75 | 1.34 | 189 tokens; output 48; TTFT 108 s | [Same log](https://github.com/JustVugg/colibri/issues/1696) |

In the 256 GB test, MTP was turned off; there were additional adjustments, including selection of experts, and contention with another service. Do not assign all gain exclusively to RAM. In the 48 GB test, it is about **V4 Flash, not V4.1**, and the measured path is CPU. The maintainer clarifies that there is batch prefill; the numbers do not prove absence of this feature and do not estimate the speed of the Metal path.

These Colibri rates do not replace the results ds4/Argonaut and Flash-Next presented above. They are different models, formats, backends and residence policies. Selecting only the lower rates would again produce a slightly representative image of what SSD allows.

### Engram: what is in the SSD matters as much as capacity

**Engram is a memory/lookup component of the model, not a fourth runtime comparable to MLX, llama.cpp and Colibri.** In the Colibri documentation for DeepSeek V4.1, the checkpoint of approximately 510 GB is decomposed in about 203 GB of Engram FP8, 289 GB of FP4 experts and 18 GB of other tensors. The project estimates approximately 13 KB of lookup Engram per token, against about 4.5 GB of expert weights before the cache effect. These numbers describe the documented implementation, not universal traffic of all runtimes. [Documentation V4.1](https://github.com/JustVugg/colibri/blob/main/docs/deepseek-v41.md)

Consequently, three settings informally called “SSD offload” may have very different behaviors:

1. Resident experts and table lookup on SSD.
2. Part of RAM experts, remaining read from SSD with cache/prefetch.
3. Pressured memory and operating system swap.

This distinction also applies when comparing Flash-Next n-gram tables with DeepSeek Engram: similar lookup function does not mean identical architecture or access volume. FP4 in experts and FP8 in tables do not mean whole model in 4 or 8 bits.

**New point for DeepSeek V4.1 resident:** Rapid-MLX published 7.31 TG in M3 Ultra 256 GB, GPU 60 cores, MLX 0.32.2, 199 GiB artifact and reported peak 213.51 GB. But it's an experimental variant **2-bit with 336 out of 384 experts per layer**, no vision/MTP. Therefore, it is not equivalent quality comparison to the complete official checkpoint in streaming and does not enter Q4/Q8 pairs. The developer reports preservation of routing mass, which does not replace code and tool evaluation. [Measurement and limitations](https://rapidmlx.com/blog/deepseek-v41-on-a-mac-and-the-router-problem)

### How to interpret better results on smaller machines

The expanded selection maintains that it is possible to obtain rates much higher than the initial selection. It does not support ordering the machines only by RAM. To compare the user's result with the publications, they must coincide:

- Model, review, quantization of weights and KV; Q4_K, IQ4, oQ4e and MLX 4-bit affine are not interchangeable files.
- Version/backend, MTP or DFlash, draft size and acceptance rate.
- Real context depth, incremental prompt size, cache and output length.
- Thinking and counting of tokens; rate per user versus aggregated throughput.
- Chip, cores, thermal pressure, memory used by IDE/containers and real expert residence.

**4-bit and 8-bit also need quality comparison.** The benchmarks of this expansion measure speed; they do not prove equivalence in tests, multifile editing, SQL, tools or UI. For economic decision, repeat the same tasks and register approval, rework and total time. A gain in TG with more errors can increase the cost per correct task.


## Enterprise savings: per token, developer, team and infrastructure

Consultation: **16/10/2026**. This expansion distinguishes measured data, modeled accounting, commercial claims and our calculations. Hybrid in this report continues to mean **local inference + cloud inference**. Hosting only the gateway locally does not meet that criterion. Values in USD, no exchange rate conversion or taxes, unless otherwise stated.

### Original request for this update — translated; Portuguese original preserved

> also look now for success cases of medium and large companies that achieved significant savings per team by adopting this, showing everything from granular spending per token to monthly spending, individuals and teams, make a comparative table of what the market average based on company data spends per developer and what that would buy for teams, show the companies clustering Macs and those building their own servers and giving people machines capable of running powerful models that are good enough, look for average spending and savings at these companies, also look for the following figures, I know there are benchmarks showing that models like opus 4.8 worked well, but then it was nerfed to offer more datacenter resources to newer models, and also show recent papers from universities and research centers showing that for day-to-day development the harness and these local models cope as well as a sonnet or an opus, that beyond a certain number of billions of parameters they already achieve what is needed, to reiterate, are you writing all this into the doc as I asked, verbatim with every link, every article, every bit of research and source? If you did not, you disregarded everything

**State of the record:** the previous sections preserve synthesis and references, not an integral transcription of every query or open page. There is no complete retrospective file of all previous search results. This update adds sources, inclusion/exclusion criteria and reproducible accounts. Third-party texts are synthesized, with short links and snippets when needed; full reproduction of protected articles is not promised. The transcription provided by the user about Snorkel was previously analyzed, but is not fully reproduced in this file.

### Companies and organizations: what has been effectively demonstrated

| Organisation / documented size | Implementation | Verifiable result in this research | Economic evidence and limit |
|---|---|---|---|
| **Pegatron / PEGAVERSE**, big manufacturer | GLM-5.1/5.2 NVFP4 through OpenCode/vLLM on an internal GB200 NVL72 | Development of production monorepo; longitudinal comparison | Individual case detailed below; not study of the entire company. [E01](https://arxiv.org/html/2607.13080v1) |
| **Yembo**, company operating in more than 20 countries; headcount not confirmed | Eight Mac minis M4/M4 Pro; two dedicated to AI, whisper.cpp; fallback AWS | Declared reduction of $40,000/year in Google Cloud; also local CI and Playwright | **Quantified savings is transcription**, not code LLM; arithmetic average US$ 3,333/month, without complete TCO. [E02](https://zachrattner.com/projects/ai-mac-cluster) |
| **Nav**, Norwegian public body, non-private enterprise | Pilot nav-pilot; Qwen/MLX on Macs, remote agent delegation option | 35B 8-bit: 96/96 replies on code and 124/128 verified single file editions; Standard Q4 for delegated mechanical editing | Evidence of qualification by task; did not publish in this source consolidated monthly invoice or savings per team. [E03](https://github.com/navikt/mlx-workspace) |
| **Samsung Electronics**, big business | Gauss/code.i internal; family with Compact, Balanced and Supreme versions | About 60% of DX developers used code.i; monthly usage quadrupled | Confirms self-model adoption. It does not specify cost/dev, hardware per user or that code.i use the on-device version. [E04](https://news.samsung.com/uk/samsung-electronics-hosts-samsung-developer-conference-korea-2024-unveils-its-improved-gen-ai-model) |
| **Infosys**, big business | NT-Java-1.1B and research Mify-Coder 2.5B | Java model explicitly intended for PCs; compact specialization research | It demonstrates technology and research, not a fleet of distributed PCs with measured savings. [E05](https://huggingface.co/InfosysEnterprise/NT-Java-1.1B), [E06](https://arxiv.org/abs/2512.23747) |
| **Google**, big business | Internal Smart Paste, integrated into the IDE | Study of use in approximately 40,000 engineers; 42.5% acceptance of suggestions | Evidence of specialized flow utility, no cost/dev or proof of execution on laptop. [E07](https://research.google/blog/smart-paste-for-context-aware-adjustments-to-pasted-code/) |
| **Unidentified company**, Kendall Eberly’s account | Pilot with MacBook Pro 128 GB; server proposal in datacenter | Author reports team interest in revision, bugs and vulnerabilities | does not inform the company, participants, invoices or percentage of savings; **not classified as proven financial success**. [E08](https://www.linkedin.com/posts/kendall-eberly-914223161_at-home-i-like-to-mess-around-with-local-activity-7500220117461577729-bJ6p) |

**Search results by organization size:** there is own implementation in large organization and an identified case of Mac cluster with expense reduction. We did not find a comparable public series of medium/large companies with all fields: local LLM for code, number of active users, accounts before/after, equivalent quality, CAPEX, operation and net savings. Therefore, we do not assign to Samsung, Google, IBM or Infosys monetary savings that their sources do not publish.

### Pegatron: a detailed case of self-hosted infrastructure

One developer, two periods of 28 days, non-randomized; local allocation valued by equivalent rent of four B200, without acquisition audit. [E01, tables XI and discussion VI-A](https://arxiv.org/html/2607.13080v1)

| Metric | Claude Opus 4.7/4.8 | Local GLM Shared | GLM local dedicated |
|---|---:|---:|---:|
| Computing / 28 days | US$ 8,785.21 | US$ 2,560.00 | US$ 10,752.00 |
| Cost effective / million processed tokens | US$ 0.573 | US$ 2.83 | US$ 11.87 |
| Modeled TCO, including operation/repairs | US$ 9,773.96 | US$ 5,859.25 | US$ 14,051.25 |
| Variation of TCO against API | — | **−40.1%** | **+43.8%** |

Shared computing: −70.9%; repair commits: 45.9% → 74.9%. API: $4.90 entry, 675.38 writing, 7601.01 cache reading, 503.92 output. The volumes of tokens differ. **It's not a business average.** The previous hybrid replay is counterfactual.

### How much companies spend per developer

| Origin | Person/month | Team effectively informed | What the number means |
|---|---:|---|---|
| Anthropic, business deployment telemetry | **US$ 150–250** | Unpublished size/sample on this page | Supplier reference for Claude Code; US$ 13/day active, 90% below US$ 30/day active. It's not the average of the entire market. [E09](https://code.claude.com/docs/en/costs) |
| Seahawk Media, co-founder's account | **~ $1,300.** | Unpublished sample headcount | Declared average, including API and subscriptions; individual users $610, 980, 1,380 and 2,340. The source mixes names/prices of plans, requiring caution. [E10](https://gautamkhorana.com/blog/claude-code-cost-agency-scale-2026/) |
| Pegatron, Intensive Developer | $8785.21 API / **28 days** | A Developer | Extreme case of agents; see previous table, without converting it automatically into calendar month. [E01](https://arxiv.org/html/2607.13080v1) |
| LifeArc / Fission Labs | Uncalculable | Rollout in 12–15 Dev/Infra/QA engineers | Snapshot of **a group**: US$ 42.08, 1,042 requests and ceiling US$ 50; do not divide by the whole rollout. Local Gateway doesn't prove local inference. [E11](https://www.fissionlabs.com/blog-posts/putting-ai-spend-under-control-without-slowing-engineering) |

**There is no basis for a representative average combining these lines.** There are no sample weights, number of active users, distribution and uniform cost definition. $200 below is just the midpoint of the Anthropic track for planning. $1,300 is an agency report, not a market percentile. We did not multiply US$ 13 by 22 to “correct” the monthly average: the source uses active days and aggregate populations.

### From tokens to monthly costs: a reproducible calculation

Official prices consulted on the research date, USD by **1 million** tokens; standard charge, no contractual discounts, additional tools or fast mode. [E12, price table](https://platform.claude.com/docs/en/about-claude/pricing)

| Model | Normal input | Writing cache 5 min | cache Reading | Output |
|---|---:|---:|---:|---:|
| Sonnet 4.6 | 3.00 | 3.75 | 0.30 | 15.00 |
| Opus 4.8 | 5.00 | 6.25 | 0.50 | 25.00 |
| Sonnet 5.5 | 2.00 | 2.50 | 0.10 | 10.00 |
| Opus 5.5 | 4.00 | 5.00 | 0.20 | 20.00 |

**Calculated example, not observed consumption:** per developer/month, 10M standard input tokens + 10M writing + 80M cache reading + 2M output. The categories are disjoint.

| Model | Entry | Writing | Reading | Output | Individual total | Team 10 | Team 50 |
|---|---:|---:|---:|---:|---:|---:|---:|
| Sonnet 4.6 | 30 | 37.50 | 24 | 30 | **121.50** | 1,215 | 6,075 |
| Opus 4.8 | 50 | 62.50 | 40 | 50 | **202.50** | 2,025 | 10,125 |
| Sonnet 5.5 | 20 | 25 | 8 | 20 | **73.00** | 730 | 3,650 |
| Opus 5.5 | 40 | 50 | 16 | 40 | **146.00** | 1,460 | 7,300 |

Formula: `cost = input_M × input_price + write_M × write_price + read_M × read_price + output_M × output_price`. By token, divide the price/MTok by 1,000,000. The scenario equals counts, nontext or tasks: tokenizers and behavior of the models differ. Thought tokens, attempts and tools need to be included in the actual measurement. A local model has no external invoice for token, but has cost amortized by useful token and approved task.

### What a team's budget would buy

**Equivalence of budget, no recommendation of purchase or proof of simultaneous capacity.** American reference prices: Mac Studio M5 Max from US$2,499; M5 Ultra from $5,499. These are input settings, not the Macs 128/256/512 GB of benchmarks. [E13, Apple](https://www.apple.com/newsroom/2026/09/the-new-mac-mini-and-mac-studio-are-available-today/)

As a reference with explicit RAM, Jeff Geerling's test documented M3 Ultra 256 GB at $8,099 and 512 GB at $11,699 in December 2025. They're historical prices from that configuration. The set of two of each totals **US$ 39,596**, before network/rack. [E14, test and prices](https://www.jeffgeerling.com/blog/2025/15-tb-vram-on-mac-studio-rdma-over-thunderbolt-5/)

| Persons | Reference US$ 150–250/dev/month: time/month | Average point $200: annual budget | How many M3 Ultra 512 GB to $11,699 this budget equals | Annual balance before any operation |
|---:|---:|---:|---:|---:|
| 1 | 150–250 | 2,400 | 0 | 2,400 |
| 10 | 1,500–2,500 | 24,000 | 2 | 602 |
| 25 | 3,750–6,250 | 60,000 | 5 | 1,505 |
| 50 | 7,500–12,500 | 120,000 | 10 | 3,010 |
| 100 | 15,000–25,000 | 240,000 | 20 | 6,020 |

**Alternative example for ten people:** annual budget of $24,000 would buy two M3 Ultra 256 GB for historical prices, total $16,198, remaining US$7,802. The agency's reference, US$ 1,300/dev/month, corresponds to US$ 156 thousand/year for ten people — our projection, not the total expenditure published by Seahawk. A historical cluster of $39,596 would represent 25.4% of this budget.

Buy RAM does not automatically buy service to N developers. For 27B/35B, it can be better to operate independent replicas; divide a single model between Macs meets another need, the aggregate capacity. The choice requires concurrency, context, TTFT and time per task measured. Apple's prices are floors and Geerling's are historical: get exact setting quote before treating equivalence as acquisition budget.

### Net local + cloud savingss: explicit sensitivity analysis

**Our illustrative scenarios**, not company results. Baseline $200/dev/month; amortization in 36 months; migration eliminates 70% of **invoice** remote, preserving 30% to cloud. This does not presuppose that 70% of tokens or tasks are local.

| Scene | CAPEX | Depreciation/month | Energy/maintenance/month | Human/month operation | Residual cloud/month | Total/month | Baseline/month | Savings |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| A dev, new machine | 4,000 | 111.11 | 20 | 50 | 60 | **241.11** | 200 | **−20.6%** |
| A dev, incremental upgrade | 1,000 | 27.78 | 20 | 50 | 60 | **157.78** | 200 | **21.1%** |
| Team of ten, pilot-sized server | 8,000 | 222.22 | 100 | 250 | 600 | **1172.22** | 2,000 | **41.4%** |

The third scenario only works if the pilot proves capacity and quality. For him, the minimum fraction of the invoice eliminated is `(222,22 + 100 + 250) / 2.000 = 28,6%`, before rework. With 70%, the simple return of the initial disbursement would be `8,000 / (2,000 − 600 − 100 − 250) = 7.62 months`. Do not depreciate again in the cash flow. Add difference of human hours of repair, cost of unavailability, backup and possible license.

### Who is clustering Macs — and what not to conflate

- **Yembo:** business implementation identified with eight minis and transcription loads, CI and QA. The US$40,000/year refers to the reduction in transcript cloud expenditure. There is no proof in this source of a single LLM partitioned by the eight Macs.
- **Apple / demonstration by Jeff Geerling:** four Studios, 1.5 TB aggregate, Exo/RDMA and llama.cpp; Qwen3 235B reached 32 tok/s in the rehearsal. Borrowed equipment for testing, not case of a business team that published monthly savings. [E14](https://www.jeffgeerling.com/blog/2025/15-tb-vram-on-mac-studio-rdma-over-thunderbolt-5/)
- **Nav:** model/integration distribution for local machines in pilot; not Macs cluster. The 48/64 GB options are project requirements/profiles, no proof of new purchase for the entire organization.
- **Pegatron:** Internal GPU cluster, not Mac. The savings depends on the ratio of resources; assign the cost of an entire rack to a user or promise that a fraction serves a hundred users distorts the case.
- **HPE + Tabnine and IBM watsonx Code Assistant for Z:** on-prem architectures documented. The existence of the product does not confirm specific customer, number of servers purchased or invoice reduction. [E15, HPE](https://www.hpe.com/psnow/doc/a50014107enw), [E16, IBM](https://www.ibm.com/docs/en/SSK5UBS_2.0/pdf/watsonx_code_assistant_for_z_2.4.20.pdf)

### Academic and industry research: small models and harnesses

The results below support specialization, decomposition and well-adjusted tools. **They do not establish a universal number of billions of parameters from which any model equals any Sonnet/Opus in daily work.** They also do not automatically measure the Q4/MLX version running on your Mac.

| Work / institution / date | Model and result | What it shows; limit |
|---|---|---|
| **Terminus-4B**, Microsoft, May/2026 | Qwen3-4B specialized in terminal. At SWE-bench C#, agent Opus 4.6 maintained 46.7% resolution; its tokens dropped from 1,010k to 693k, plus 25k in subagent | Strong evidence to delegate build/tests/logs to small expert. It does not replace the main agent or prove local business deployment. [R01](https://arxiv.org/html/2605.03195v1) |
| **SWE-Master**, Renmin University + BOSS Zhipin, February/2026 | Qwen2.5-Coder-32B: 61.4% SWE-bench Verified; 70.8% with TTS@8 | Post-training and pursuit elevate performance. The result with eight candidates has a different budget from pass@1. [R02](https://arxiv.org/html/2602.03411v1) |
| **SWE-World**, Renmin University + BOSS Zhipin, February/2026 | 32B: 6.2% → 52.0% SFT → 55.0% RL → 68.2% with TTS | Capacity depends not only on size; training and budgeting matter. Benchmark is not equivalent to a team's routine study. [R03](https://arxiv.org/html/2602.03419v1) |
| **SWE-Zero / SWE-Hero**, NVIDIA Research, April/2026 | 32B: 62.2% Verified; 44.1% Multilingual | Specialization and transfer between languages. Do not prove parity with Opus 4.8 in all software. [R04](https://arxiv.org/html/2604.01496v1) |
| **Beyond the Model / NanoHarness**, Nanjing University of Science and Technology, TUM and Nanjing University, September/2026 | Ten models, three benchmarks; 7.37 and 6.21 points gains in Qwen3.7-Max and DeepSeek-V4-Pro | Direct evidence of the harness effect; the examples of gain are large models. Structured tools help, but compression and generic subagents can worsen results. [R05](https://arxiv.org/html/2609.32459v1) |
| **Draft-Model Gate / Speculative Uncertainty**, Tel Aviv University + IITU, September/2026 | Qwen3-4B evaluates actions; cost reduction in tokens of 14–19% | It is not a free gain: success in Verified fell 49% → 44%; DA-Code 64% → 63%, despite fewer errors per execution. It's not a local fleet demonstration. [R06](https://arxiv.org/html/2609.05274v1) |
| **Mify-Coder**, Infosys AI Research, preprint December/2025 | 2.5B specialist, trained with 4.2T tokens | Evidence of code/function calling compact; it is research by the proposing company, not independent audit or observed monthly savings. [E06](https://arxiv.org/abs/2512.23747) |

**Reading applicable to day to day:** there is good justification to test 4B in delimited execution tasks and 27–35B in edits, code questions and verifiable tasks. The Nav case offers practical evidence of qualification of these classes. Visual UI, architecture, extensive changes and difficult fixes need their own ratings; they do not automatically inherit the terminal success rate or SWE-bench. Harness can improve or worsen performance and does not invariably recover absent model capabilities.

### Opus 4.8: capacity, degradation and hypothesis about datacenters

The proposed hypothesis contains three different statements:

1. **The model was useful:** compatible with use in documented production at Pegatron; does not mean absence of errors.
2. **Users observed regressions:** the expansion of this research records 102 search correspondences in GitHub and examines reports on multiple platforms, detailed in the section “Perceived regressions”. There are specific public reports of Opus 4.8, such as the issue #68428 of June/2026, marked as requiring reproduction. Slow/dissatisfaction report is not a controlled benchmark before/after. [R07](https://github.com/anthropics/claude-code/issues/68428)
3. **There was intentional degradation to release datacenters:** **unproven in the sources consulted**. We found no experiment to identify this cause or verifiable technical statement to confirm it.

There is an official post-mortem of **23/04/2026**: effort changes, incorrect thinking disposal and concision instructions have harmed Claude Code. The episode involves Sonnet 4.6 and Opus 4.6/4.7; the company stated that the API was not affected. It is evidence of regression in the product/harness, **no evidence of the alleged motive for Opus 4.8**. [R08](https://www.anthropic.com/engineering/april-23-postmortem)

To test the claim, it would be necessary to compare the same ID/review, tasks, harness, effort, budget and environment, with repeated executions and recorded dates. Latency, commercial limit, prompt alteration, routing and weight quality are distinct variables. Fixing local weights and runtime facilitates reproducibility, but quantization updates, models and harness also need controlled regression.

### Record of additional sources and inclusion decisions

All consulted on October 16, 2026. The above IDs allow you to locate each claim; the links below also record sources that did not support the desired framework. They're not a transcript of the articles.

| Source / link | Type and decision |
|---|---|
| [Anyscale: Run coding agents on your own GPUs](https://www.anyscale.com/blog/run-coding-agents-on-your-own-gpus) | Benchmark/supplier architecture. The example uses GPU AWS; not classified as proven savings on own physical server or local+cloud hybrid. |
| [Anyscale: COST-ESTIMATE.md](https://github.com/anyscale/llm-serving-for-coding-agents/blob/main/part3-optimize/notes/COST-ESTIMATE.md) | Projection, non-accounting: ~US$ 58/dev/month always connected or ~US$ 17 during business hours, assuming 50 devs/GPU. Comparison excludes complete operation; without converting into realized savings. |
| [Nav: Model decision](https://github.com/navikt/mlx-workspace/blob/main/reports/2026-09-23-local-model-evaluation/decision.md) | Live document; records faults and delegation costs beyond successes. Not only use the highest favorable percentage. |
| [Nav: results of open questions](https://github.com/navikt/mlx-workspace/blob/main/reports/2026-10-12-open-questions/oq3a-results.md) | Complement to the gates published in the README; results by task/harness, without monthly corporate invoice. |
| [Seahawk: actual costs declared](https://gautamkhorana.com/blog/claude-code-cost-agency-scale-2026/) | Identified operator report; no dataset/auditable invoices. Inconsistencies of plan names reduce confidence in decomposition, do not allow silently correcting the source. |
| [LifeArc / Fission Labs](https://www.fissionlabs.com/blog-posts/putting-ai-spend-under-control-without-slowing-engineering) | Identified client; expense governance. No financial baseline and no local model proof. |
| [Codeium, US$ 1.21M claim → US$ 787k for 112 engineers](https://www.johal.in/we-saved-35-ai-coding-assistant-costs-switching) | Report without company identified or independent proof; not incorporated to the average or treated as confirmed case. |
| [AgentCost: case study](https://agentcost.in/docs/guides/case-study/) | The text itself identifies composite scenarios; excluded from the table of real companies. |
| [HAMS: Self-hosted offshore agents](https://www.hams.tech/blog/cto-case-study-self-hosted-ai-coding-agents-offshore-pods-2026.html) | Mixing offshore hiring savings with AI; without decomposition enough to assign savings to the local model. |
| [ByteBell: FAQ and Token Reduction Claims](https://bytebell.dev/faqs/) | Local context product, no local LLM proof. The account 38,900 → 4,400 represents 88.7%, not the 96% announced; not used as a proven savings. |
| [Taicli: example of routing](https://taicli.com/) | Commercial illustration combines clouds and a local path; it does not isolate the local contribution or publish auditable experiment. |
| [Tabnine: architecture](https://docs.tabnine.com/main/welcome/readme/architecture/deployment-options) | Confirms Kubernetes on-prem/air-gapped; does not demonstrate which deployment was used by each customer quoted in marketing. |
| [Tabnine: Context Engine](https://www.tabnine.com/pricing-enterprise-context-engine/) | “Up to 80%” minus tokens is allegation of internal benchmarks; no comparable customer/cost base. |
| [Google: AI in software engineering](https://research.google/blog/ai-in-software-engineering-at-google-progress-and-the-path-ahead/) | Contextualizes adoption and gains; does not provide the local account per requested developer. |
| [IBM: installation WCA for Z](https://www.ibm.com/docs/en/SSK5UBS_2.0/pdf/watsonx_code_assistant_for_z_2.4.20.pdf) | Confirms possibility of entire stack on-prem; does not prove internal savings of IBM using recent local Macs/LLMs. |
| [NVIDIA: readjustment DGX Spark, 23/02/2026](https://forums.developer.nvidia.com/t/2-23-2026-price-change-announcement/361713) | MSRP reported went from $3,999 to $4,699. It avoided using outdated launch price as current quotation; it requires new quote for acquisition. |
| [Two Mac minis M4, llama.cpp RPC](https://gist.github.com/karlhendrik/355bb6cbf98861b21177a6b7857e79f7) | Technical demonstration, not medium/large company with published invoice reduction. |
| [Community assessment on alleged nerf 4.8](https://zenn.dev/oqamura/articles/85945cef3d7432) | A trail of reports; not a source of causal evidence about datacenter allocation. |
| [What Should a Software Team Spend on Agents?](https://arxiv.org/html/2610.20394v1) | Simulation study, October/2026; no company account observed or market average. |
| [Control the Harness, Control the Cost](https://arxiv.org/abs/2609.28919) | Company emulated of 10,000 seats; no evidence of savings performed in site+cloud. |
| [Cadence: engineering AI spand](https://cadence.withremote.ai/blog/engineering-ai-spend-2026) and [Cohrint: costs](https://cohrint.com/blog/ai-coding-cost-benchmarks-2026) | Market ranges; do not replace comparable primary sample. Not used to manufacture weighted average. |

### Research trail and remaining gaps

Consultations included combinations of `company engineering local LLM self hosted coding cost savings per developer Mac cluster`, `Mac Studio cluster developers cost savings`, `Mac mini cluster company LLM engineers`, `coding assistant on-prem case study`, Samsung/Infosys/IBM/Google/Bosch/Agoda/Criteo companies, `Opus 4.8 degradation`, and `harness small coding site:arxiv.org 2026`. Authors' sources, documentation, repositories and full articles were followed when accessible. Results unrelated to code inference, such as medical coding and generic CI migration, were not converted into cases of LLM.

The documentable economic conclusion is **conditional**: there is a large company with significant savings under shared allocation and there is a business Mac cluster with AI savings; there are still comparable public accounts missing to calculate an average savings of programming teams with Macs. Small expert studies support delegation of specific tasks. They do not support the universal equivalence of any 27B/35B to any frontier model, nor a guarantee of savings only by the size of the model.


## Intensive costs per token, proprietary knowledge and evolution without increasing parameters

Update: October 16, 2026. Scope: software engineering, code, testing, backend and UI; local inference or combination **local + cloud**. Bonsai remains excluded. Values in US dollars, no exchange rate conversion. This section complements, without replacing, previous cases and benchmarks.

### Request received — translated; Portuguese original preserved

> companies spend per token, just where I work some people’s spending ranges from 2 thousand to 10 thousand dollars, by the way show Sathya Natela’s comment on twitter that programmers pay with their code because the price paid nowadays does not cover AI costs, show the articles and everything already proven about the liability of large software companies, like IBM, HP, Dell, that if they keep using AI they will end up indirectly handing over code and deterministic systems to AI companies, and that in a way the companies behind these models are already offering systems of this nature integrated into their platforms, there are serious articles about this, also bring up that if costs continue like this they are unsustainable for the future and that if companies do not adopt local models or at least a hybrid approach, they will give up their data and code and incur high costs, when a 2500 to 5000 dollar machine could be running a powerful local model handling coding and keeping the data contained locally, protecting sensitive information. Besides, in the long run it pays for itself, look for articles showing the major evolution of the qwen3.8 model with 27B parameters proving that dataset quality is what changed the model’s result rather than its size, and this also proves the performance of the new deepseek4.1 flash, which did not increase in size but changed the quality of the dataset

### Range of $2,000–10,000: how to correctly incorporate it

The user reports spending of $2,000–10,000 from some professionals in his company. It is witness evidence provided by the interlocutor, without invoices, distribution of the team or period explained in this message. **The scenarios below assume that these values are monthly per person.** They do not represent a market average. The range previously mentioned in Claude Code's documentation is not a ceiling for spending and does not invalidate intensive users with much larger accounts.

The relevant economic unit is actual billed spending: uncached input, cache writes and reads, billed output and reasoning, tools and infrastructure. The amount estimated by a token monitor under a subscription is not necessarily the bill paid. People must also be distinguished from concurrent agents: one developer can operate many agents.

```text
API bill = Σ[(tokens in each category / 1,000,000) × contracted rate for that category]
             + separately billed tools and services

Net monthly savings = bill actually avoided
                        − incremental local operations
                        − incremental cost of repairs, waiting and escalation

Simple payback in months = incremental investment / net monthly savings
```

Categories should not count twice the same tokens. Cache ratio, discounts and hired model greatly alter the conversion of tokens into dollars. To compare quality, add cost per accepted task and human review time.

### Nadella: the original statement found and what it actually says

Primary source: Satya Nadella, **The Reverse Information Paradox**, July 12, 2026, on his blog [sn scratchpad](https://snscratchpad.com/posts/reverse-information-paradox/).

Short verbatim excerpt:

> “You essentially pay for intelligence twice”

Translation: “You essentially pay twice for intelligence.” Nadella describes payment in cash and exposure of proprietary knowledge needed to make the model useful. Discuss the value of prompts, tools, corrections and evaluations, defending corporate control over learning and orchestration. It is a strategic criticism also made by an AI provider, not a contract audit of all competitors.

**The formulation found does not say that the code of programmers necessarily subsidizes a tariff below cost.** The original statement connecting these two statements was not found in this study. Therefore, do not assign this additional conclusion to Nadella.

About X/Twitter: two addresses attributed to the article were found in secondary sources: [2076323181154230284](https://x.com/satyanadella/article/2076323181154230284) and [2066182223213293753](https://x.com/satyanadella/article/2066182223213293753). Both failed to open the tool. **The correct permalink on X remains unauthenticated; the above quote was checked in the primary blog**, also linked by [ITPro's report of 14/07/2026](https://www.itpro.com/technology/artificial-intelligence/a-company-should-be-able-to-use-a-model-without-giving-up-the-knowledge-that-makes-it-unique-microsoft-ceo-satya-nadella-says-enterprises-shouldnt-be-sharing-so-much-data-with-ai-providers).

### Intellectual property, liability and competition: evidence with different scopes

| Question | Evidence consulted | Supported conclusion and limitation |
|---|---|---|
| Exposure of sensitive data and IP risks | [NIST AI 600-1, generative AI profile](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf), especially MP-4.1 | Recognizes risks of privacy, intellectual property and third party integration; recommends governance and incident handling. You don't claim that every remote call transfers rights. |
| Concentration, dependence and commercial information | [FTC, AI partnership study, January/2025](https://search.ftc.gov/news-events/news/press-releases/2025/01/ftc-issues-staff-report-ai-partnerships-investments-study) and [report](https://www.ftc.gov/system/files/ftc_gov/pdf/p246201_aipartnerships6breport_redacted.pdf) | It points out potential switching costs and access to sensitive information in the relationships between cloud providers and model developers. The object is these partnerships; it is not proof of ownership of IBM, HP or Dell client code. |
| Business contract and training | [Anthropic: controller/operator](https://privacy.claude.com/en/articles/9267385-does-anthropic-act-as-a-data-processor-or-controller) | In commercial products, the company declares not to train with customer data, unless it participates voluntarily in the indicated program. The page distinguishes commercial products from Free/Pro/Max, including its use in Claude Code. |
| Obligations and contractual limits | [Anthropic Commercial Terms](https://www.anthropic.com/legal/commercial-terms), Sections E, K and L | There is confidentiality, obligations on input rights and indemnification with exclusions. Sending content without authorization can generate contractual exposure; it is not equivalent to an automatic IP conviction or transfer. Negotiated contracts need to be examined separately. |
| IBM Policy | [Security and privacy in watsonx](https://www.ibm.com/docs/en/watsonx/w-and-w/2.3.x?topic=overview-security-foundation-models) | The indexed documentation states that sent content and results are not used to train models developed by IBM. Full opening failed in this consultation; retain access limitation. |
| Agents and operational leak | [IBM: PI/IP/confidential sharing](https://www.ibm.com/docs/en/watsonx/saas?topic=atlas-sharing-ippiconfidential-information-user) | The risk catalogue describes agents with unrestricted access that can share information. The mechanism can also exist with local model and external tools. |
| Offering products that compete with traditional services | [Anthropic: Code Modernization Playbook](https://resources.anthropic.com/code-modernization-playbook) and [PDF](https://resources.anthropic.com/hubfs/Code%20Modernization%20Playbook.pdf) | There is an offer of code modernization, including legacy systems. It is evidence of commercial advancement on tasks previously provided by integrators; it does not demonstrate that products were built with IBM, HP or Dell's confidential code. |
| Integrated model supplier tools | [Official Repository Qwen3.8](https://github.com/QwenLM/Qwen3.8/blob/main/README.md) | It features Qoder, QwenWork and Qwen Code with models and APIs. It proves expansion of the layer of models for work tools; not appropriation of customer systems. |

**No documents were found proving that IBM, HP or Dell handed over their deterministic systems to laboratories by using coding assistants.** Nor has a specific judicial liability of these three companies as a result of this claim been demonstrated. “Liability” needs to distinguish contractual/legal liability from strategic risk of dependence or competition.

Remote processing, retention, training and property are different issues. A supplier can process code for inference without acquiring its title and without authorization for training. Even so, the company may prefer local execution to reduce the exposure surface, control versions, and retain evaluations and feedback. Nadella's criticism is relevant to this decision, but it does not replace the reading of the contract and configuration of the product used.

### Dell: additional evidence directly related to intensive spending and code

The [Official announcement of Dell Deskside Agentic AI of 18/05/2026](https://www.dell.com/en-us/dt/corporate/newsroom/announcements/detailpage.press-releases~usa~2026~05~dell-technologies-delivers-production-ready-agentic-ai-from-deskside-to-data-center.htm) presents local execution, sandbox and security policies for agents, including programming assistants. Claims reduction of up to 87% in two years and return in certain scenarios from three months. The notes identify Signal65/Futurum analysis with prices and performance provided by Dell, as well as hypotheses of use. It is evidence of business strategy and modeling; not an savings carried out by an identified client company.

The [ITPro, in the launch coverage](https://www.itpro.com/technology/artificial-intelligence/dell-unveils-deskside-agentic-ai-at-dell-technologies-world-2026), assigns to executive Jon Seigal the report of a developer Dell consuming **1 billion tokens and $3,400 in 24 hours**. This is arithmetically equivalent to $3.40 per million aggregated tokens, but does not reveal the input/output/cache mix. It is executive report to the press, without published invoice; not average per developer. It corroborates the existence of users with expenses much higher than seat fees.

The official article [Own Your AI: Dell Pro Max with GB10, 09/07/2026](https://www.dell.com/en-us/blog/own-your-ai-dell-pro-max-with-gb10/) compares a machine of approximately **US$ 6,300** with a **US$ 15 thousand–25 thousand/year** for a team of ten. It's a commercial proposal from the manufacturer, out of the $2,500–5,000 budget. Do not literally adopt their cost expressions “only electricity” or total lack of risk: support, administration, quality and security remain relevant.

#### Examination of the Signal65 study, instead of reproducing only the advertising percentage

[The Economics of Agentic AI, Mitch Lewis and Ryan Shrout, Signal65, May/2026](https://signal65.com/wp-content/uploads/2026/05/Signal65-Insights_The-Economics-of-Agentic-AI.pdf): modeling with Dell/NVIDIA data, not customer invoices. Development uses Nemotron-3-Super-120B-A12B, 80% use and persistent agents up to 24 hours/day, 260 days/year. It takes approximately 21 million input tokens and 330,000 output per agent/day; 65% cache and 40% cloud discount. Reference rates: US$ 5.54/M input, caching US$ 0.554/M output US$ 28.97/M. It projects around 87% savings in GB300; it does not prove equivalence of patches accepted between models.

**Our calculation using these assumptions:**

```text
Cost/agent/day = [21 × (0.35 × 5.54 + 0.65 × 0.554) + 0.330 × 28.97] × 0.60
                = US$ 34.70472
Average cost/agent/month = 34.70472 × 260 / 12 = US$ 751.94
```

An agent is not equivalent to an employee. The result is also not a single effective per-token rate. The study covers programming, testing, review, SQL and API integration, but does not provide a comparison per accepted patch. The economic conclusion requires validating quality, prefill capacity and concurrency in the actual workflow. Persistent use favors amortization; a laptop used for a few hours does not inherit the same percentage.

### Payback for a US$ 2,500–5,000 machine within the range reported by the user

**Calculated scenarios, not observed cases.** Monthly expense, effective drop of 50% of API invoice and additional $100/month for local operation are assumed. The latter value is an illustrative hypothesis; it must be replaced by the measured cost. It is not assumed that 50% of requests are 50% of dollars: the table uses money effectively avoided after local routing + cloud. Additional human costs should still be discounted.

| Current API per person/month | Remaining API | Local operation | Net monthly savings before additional work | Payback $2,500 | Payback $5,000. | Savings in 12 months after purchase of $5,000 |
|---:|---:|---:|---:|---:|---:|---:|
| US$ 2,000 | US$ 1,000 | US$ 100 | US$ 900 | 2.78 months | 5.56 months | US$ 5,800 |
| US$ 5,000 | US$ 2,500 | US$ 100 | US$ 2,400 | 1.04 month | 2.08 months | US$ 23,800 |
| US$ 10,000 | US$ 5,000 | US$ 100 | US$ 4,900 | 0.51 month | 1.02 month | US$ 53,800 |

For ten professionals with the same individual expenditure and **a $5,000 machine per person**, the investment is $50,000. The scenarios result in $9,000, $24,000 or $49,000 in monthly savings and $58,000, $238 thousand or $538 thousand in the first year after CAPEX. They are arithmetic scales, not the average of a team: the original report refers to some professionals, not to all.

Sensitivity to recover $5,000 in 12 months, with US$ 100/month of operation and no additional work: just avoid US$ 516.67/month API. That corresponds to **25.83%**, **10.33%** or **5.17%** of the respective $2,000, $5,000 and $10,000 bills. Integration costs increase the threshold; an existing machine or smaller incremental purchase reduces it.

These values make the pilot economically relevant to intensive users. They do not guarantee that the machine can produce the required volume with the same quality. It should be measured especially if the high cost comes from a repeated context that can be eliminated, from well-defined local tasks or difficult reasoning that will continue to require cloud.

### Hardware in this budget and effective data protection

For pure weights, before metadata and execution memory, 27B requires approximately 13.5 GB in 4 bits or 27 GB in 8 bits; 35B requires 17.5 GB or 35 GB, respectively. They're decimal calculations of parameters × bits, **not measured total consumption**. OS, IDE, view, buffers and KV cache also occupy memory. In MoE, low active parameters do not eliminate the need to store experts. For 64 GB, the four combinations are plausible candidates for residence, with context and simultaneous load adjusted; the previous benchmark tables detail results effectively measured.

The budget of $2,500–5,000 should buy a **full configuration specified**, not just a product whose initial price appears on a page. The [article Framework](https://frame.work/blog/the-best-framework-laptops-at-every-price-point) published 128 GB from US$ 1,999, but it is historical reference: there are subsequent increases in memory, and the current configurator failed in this query. Therefore, do not register $1,999 as current quotation. Apple prices and configuration limits are already in the previous sections; the GB10 of $6,300 quoted above does not fit in this budget.

The [Dell Pro AI Studio](https://www.dell.com/en-us/shop/software/lp/dell-pro-ai-studio) document processing on compatible REST device and API to switch local/remote inference. It is product evidence appropriate to hybrid architecture, not independent savings measurement. The [HP Z brochure for data science](https://h20195.www2.hp.com/v2/GetDocument.aspx?docname=c09108524) it was located as a local infrastructure track, but the integral opening failed; it was not converted into a case of expenses or a proof of legal responsibility of HP.

**Proposed architecture for the team:** maintain repositories, indexing, embeddings, running tests, logs and main model in the controlled environment. Directing to the cloud only authorized tasks and their necessary minimum context, with appropriate contract and budget per task. Restrict network output, telemetry and tools/MCP. If a confidential task cannot come out, the fallback must remain local or human. Running only the weights locally, keeping the whole context in a remote tool, does not produce the same result of privacy.

### Sustainability: what can be said

It is demonstrable by calculation that a tariff per decreasing token does not guarantee a fall in invoice when volume, context and concurrency grow faster. Dell herself uses this argument in her ad. There are also premises where local processing substantially reduces the cost — and the Pegatron case, previously documented, shows that rating and repair costs can reverse the result.

No demonstration was found that **any current API price is below its marginal cost** nor that every company that remains in the cloud will necessarily lose code or become financially unfeasible. Aggregate losses at a laboratory, training cost, subscription subsidy and margin of inference are different measures. Do not infer one from the other without compatible revenue and cost data.

Sustained formulation: **full dependence on tariff inference creates exposure to volume, tariffs, versions and policies of the supplier; local capacity can reduce this exposure and conserve knowledge and data when quality and use justify its total cost.** Return must be demonstrated by avoided expense and approved tasks, not only by tokens/s.

### Qwen3.8-27B: substantial improvement with 27B, no proof of exclusive cause

Results published in [official model card Qwen3.8-27B](https://huggingface.co/Qwen/Qwen3.8-27B), compared to Qwen3.6-27B. These are evaluations by the authors, not an independent replication:

| Benchmark | Qwen3.6-27B | Qwen3.8-27B | Absolute gain |
|---|---:|---:|---:|
| Terminal Bench 2.1, Terminus | 63.4 | 73.0 | +9.6 points |
| SWE-bench Pro | 53.5 | 61.7 | +8.2 points |
| NL2Repo-Bench | 36.2 | 42.3 | +6.1 points |
| DeepSWE 1.1 | 13.3 | 42.2 | +28.9 points |

The nominal count remains 27B. This shows that increasing parameters **It's not necessary for every advance**. It does not isolate dataset quality as a single cause: training, post-training, reasoning budget and integration with the harness also matter. The comparison published with Opus in SWE-bench Pro uses external results for Opus and retests suitable for other models; do not treat it as a uniform duel. Nor automatically transfer the score to Q4, short context or specific Mac.

#### More direct evidence of data and specialization: Qwen3.8-27B + FigmaTrace

[Article FigmaTrace](https://arxiv.org/html/2608.21460v1), [dataset](https://huggingface.co/datasets/PatronusAI/figmatrace) and [adjusted weights](https://huggingface.co/PatronusAI/Qwen3.8-27B-Figmatrace-SFT). The study applies SFT to the same 27B, compares task phase preparation with length segmentation and measures accuracy by action in GUI:

| Evaluation | Base 27B | Phase SFT | SFT per length |
|---|---:|---:|---:|
| GUI-Odyssey | 44.0 | 53.7 | 40.0 |
| AndroidControl | 82.7 | 99.1 | 67.3 |
| Mind2Web viewport 1000 | 65.3 | 68.7 | 70.0 |
| VideoGUI without directed instructions | 26.0 | 19.3 | 21.3 |

Data preparation influences results without increasing the model, but there are regressions and better preparation varies by evaluation. The table of the article reports means 63.8 versus 56.3; subtraction is 7.5 points, although the text mentions 7.3. The discrepancy is preserved. These are tasks of visual interaction, not frontend approval, backend or end-to-end software testing. Study of the proponents themselves; external replication not located.

As a code antecedent, [Textbooks Are All You Need, Microsoft Research, 2023](https://arxiv.org/abs/2306.11644), describes Phi-1 of 1.3B, selected and synthetic data, HumanEval 50.6% and MBPP 55.5%. It supports the value of specialized data; they are historical benchmarks of functions, insufficient to prove current equivalence in complete engineering. The Snorkel case already documented offers other evidence of behavioral change by training in financial tools.

### DeepSeek V4.1 Flash: correction of the premise on size

The [Official technical report](https://arxiv.org/html/2609.19969v1), Table 1, contradicts the statement of unaltered size:

| Measure | DeepSeek V4 Flash | DeepSeek V4.1 Flash |
|---|---:|---:|
| Backbone Parameters | 284B | 552B |
| Token active parameters | 13B | 8B in prefill / 16B in decode |

Backbone increased approximately **94.4%**. The report assigns efficiency to Causal Encoder-Decoder, CSA2, cache accuracy and execution strategy: global KV in approximately 1/4 and persistent in approximately 1/8 of the previous. Data and post-training have also changed. So, smaller cache **does not mean** less weights or constant size. This model does not serve as an experiment that isolates dataset while maintaining fixed architecture and size. The separation between weights/experts, Engram and KV cache remains necessary to analyze offloading on SSD.

### Record of searches and unresolved items in this update

Nadella's speech title and attributions to X were searched; IBM documents on privacy/IP; Dell Deskside, Pro AI Studio and Signal65 methodology; HP Z; commercial terms Anthropic; NIST and FTC; model card and repository Qwen3.8; DeepSeek report V4.1; FigmaTrace and Phi. The links used are close to each finding. This section is a verifiable synthesis with short quotes, **not an integral transcription of third party articles**.

Clues not promoted to facts: two divergent permalinks of X; tariff claim below the cost attributed to Nadella; proven responsibility of IBM/HP/Dell for code assignment; historical framework price presented as current; universal equality between quantized local Qwen and Opus; exclusive causality of dataset in Qwen3.8 evolution; unchanged DeepSeek size V4.1. The last two were separated in non-isolated hypothesis and contradicted premise, respectively.


## Perceived regressions, public reports and operational stability

The experience of programmers is relevant evidence for a purchase decision. It doesn't depend on recognition of the supplier to be registered. In this review, the question was divided into three: what problems were reported; what changes were measured; and what is known about its cause. The absence of proof of intention does not erase reports of loss of quality or cost of rework.

### observable volume: traceable sample, not estimate of the entire internet

On October 16, 2026, the public API of GitHub returned **102 issues** for consultation `repo:anthropics/claude-code is:issue "4.8" "degradation"`. The two pages were collected; the list is in [data/github-search.json](../pesquisa_html/dados/github-search.json). These are search correspondences in title/body/comments, including possible duplicates and indirect references. **There are not 102 confirmed incidents, neither 102 people, nor a measure of the proportion of dissatisfied users.** The search does not constitute Reddit, X or LinkedIn census.

| Primary registration | Documented content | Quantitative signal available |
|---|---|---|
| [GitHub #63861, 30/05/2026](https://github.com/anthropics/claude-code/issues/63861) | Check statements without running build; comments describe problems in other projects and comparison with 4.7 | 9 comments; 6 positive reactions to this |
| [GitHub #67606, 11/06/2026](https://github.com/anthropics/claude-code/issues/67606) | Author reports invented user messages and incorrect tool facts, with JSONL verification | 16 comments; 4 positive reactions |
| [GitHub #69398, 18/06/2026](https://github.com/anthropics/claude-code/issues/69398) | Reports of failure of instruction and reasoning in Code and Cowork, in different sessions | 3 comments; no registered reaction; closed as duplicate |
| [Reddit: errors and slowness, 24/06/2026](https://www.reddit.com/r/Anthropic/comments/1ueevsb/degraded_performance_elevated_error_rate_on/) | Discussion of unavailability, latency and suspected change before launch | Indexed result displayed +27 votes; it is not independent report count |
| [Reddit: “Opus 4.8 is really bad”](https://www.reddit.com/r/Claudeopus/comments/1ugdo34/opus_48_is_really_bad_did_they_downgrade_the/) | Dissatisfaction with code, accompanied by responses from users who maintain good experience | Count not reliably obtained |
| [Reddit: dynamic workflows](https://www.reddit.com/r/ClaudeCode/comments/1tt8mxx/why_48_feels_broken_if_youre_not_running_dynamic/) | Discussion on model, orchestration and flow adaptation | Count not reliably obtained |
| [Juan J. Ramirez, LinkedIn](https://www.linkedin.com/posts/juanjramirez_opus-48-is-the-first-time-i-can-confidently-activity-7466552263008837632-hPeb) | Professional report recommending return to 4.6 | Testimony, not published experiment |
| [Aryan Kathawale, LinkedIn](https://www.linkedin.com/posts/kiritocode1_man-claude-opus-48-is-a-major-degradation-activity-7468209923391377409-jiFi) | Difficulties with editing and file structure | Testimony, not published experiment |

Metadata from the three issues were preserved in JSON. The 28 comments added include discussion and possible repeated participants. They are not equivalent to 28 affected developers. The Reddit API returned 403; counts were not invented to fill the gap. The sample also contains favorable opinions, avoiding presenting unanimity that the sources do not show.

### External measurement and recognition of previous regressions

The [Marginlab, 29/05/2026](https://marginlab.ai/blog/claude-code-degraded-before-opus-4-8/), accompanied Claude Code daily in a subset of SWE-bench Pro. Published five days below the 65% baseline, followed by recovery. The original table was captured for visual inspection:

| Date of May/2026 | CLI | Published Pass Rate |
|---|---|---:|
| 21 | 2.1.148 | 64% |
| 22 | 2.1.150 | 50% |
| 23 | 2.1.150 | 54% |
| 24 | 2.1.150 | 50% |
| 25 | 2.1.150 | 50% |
| 26 | 2.1.152 | 52% |
| 27 | 2.1.153 | 66% |
| 28 | 2.1.156 | 72% |

The arithmetic average of the five days of fall is **51.2%**, 13.8 points below baseline. The previous model was **Opus 4.7**, and recovery coincides with CLI version exchange and arrival of 4.8. The authors suspect the harness. The episode shows operational variation; it should not be renamed as measurement of posterior degradation of Opus 4.8.

![Original Marginlab table: dates, versions and pass rates](../pesquisa_html/assets/marginlab-tabela.webp)

Image source: [Marginlab](https://marginlab.ai/blog/claude-code-degraded-before-opus-4-8/), capture of the original HTML table, 10/16/2026.

The [Anthropic recognized on 23/04/2026](https://www.anthropic.com/engineering/april-23-postmortem) three changes that harmed the product: a reduction in default effort, improper discarding of prior reasoning and a conciseness instruction. The episode affected 4.6/4.7 and predates 4.8. It shows that external feedback can reveal regressions that internal tests initially missed. There is no need to accept the company’s account as a universal explanation; it is also incorrect to claim that providers never acknowledge regressions.

**Consequence for management:** evaluate the stability of the set model + harness + configuration + serving, maintain sentinel tests and an alternative route. Weights and local versions under control allow you to freeze an approved configuration. Tests are still required when exchanging quantization, model, runtime or instructions. The specific hypothesis of deliberate reduction to release datacenters follows without causal demonstration in this sample.

## Local model security: enforceable controls and real limits

Open-weight models can integrate a controlled business architecture. Accessible weights are not a barrier to identity, isolation, audit or network control. Security stems from the entire system: files, runtime, IDE, agents, credentials, tools, updates, infrastructure and people. The objective is to prevent unauthorized actions and data flows, even when the model produces inadequate instruction.

### What Google and NVIDIA effectively document

The [Google describes Private Compute Core](https://security.googleblog.com/2022/12/trust-in-transparency-private-compute.html) as an isolated environment, with limits of communication between processes and publicly inspectable mechanisms. In [Gemini Nano/AICore documentation](https://developer.android.com/ai/gemini-nano), the service does not have direct internet access; downloads pass through Private Compute Services, requests are isolated and inputs/outputs are not retained after processing. It's concrete evidence of inference protection on the device. It does not prove that Google executes Qwen code on your engineers' notebooks, or that every customer application automatically inherits these warranties.

The [NVIDIA documents OpenShell](https://docs.nvidia.com/openshell/latest/security/best-practices) with separate controls for network, filesystem, processes and inference. There are egress policies, Landlock, seccomp, reduced privileges and gateway authentication. They're containment mechanisms outside the prompt. The [NemoClaw tutorial with local inference](https://developer.nvidia.com/blog/build-a-secure-always-on-local-ai-agent-with-nvidia-nemoclaw-and-openclaw/) shows an operational path, but integrations like Telegram continue to send messages to external services. **“Local Inference” does not transform remote integration into local communication.**

**Platform limit:** Landlock and seccomp are Linux mechanisms. On Mac, deployment should define an equivalent border — for example, run agent tools on an isolated Linux VM and expose only the authenticated MLX service API on the host. This also requires controlling the network, volumes and credentials of VM; it does not make Linux controls native to macOS. It's an architecture proposal, validating on the pilot.

### Protection matrix for code, testing, backend and UI

The measures below are an engineering proposal based on the cited sources, to be validated in the company environment. “Manageable” means available controls and defined responsibilities; not immunity to all vulnerability.

| Risk | Recommended control | How to demonstrate it works | Residual risk |
|---|---|---|---|
| Prompts sent to third parties | Block outbound traffic by default; local endpoint; explicit destination allowlist | Host/gateway traffic capture during real tasks; forbidden destination test | IDE, plugin or process out of policy can send data |
| Local API exposed | Bind to loopback; for teams, TLS gateway + identity + RBAC + limits | Check ports and prove unaccredited call rejection | An authorized user may still abuse the access granted |
| Prompt injection in repository/document | Separate instruction content; restrict tools; sandbox; external approval for privileged actions | Test Repository with malicious instructions; attempt of blocked exfiltration | Detection by another LLM is not absolute guarantee |
| Credentials available to the agent | Safe deposit box and temporary credentials; proxy injection; never mount production secrets | Inspect environment, mounts and logs; try to read a test secret | Excessive proxy permissions may allow improper use |
| Code execution and testing | Unprivileged account, disposable container/VM, minimum mounts, no Docker socket privileged | Test scope escape, written out of folder and network access | Kernel/runtime vulnerabilities require patches |
| Compromised weights, packages or plugins | Approved origin, hashes, fixed versions, inventory and format validation | Hash verification, scanning and installation in an isolated environment | Hash proves integrity to the reference, not absence of malicious behavior |
| Logs, indexes and backups | ACL per project, encryption, minimum retention, local embeddings and managed backups | Check cross access and discard; test restore | Data in use remains accessible to privileged processes |
| Silent Changes | Pin model, quantization, template and runtime; rollout with a canary and rollback | Sentinel task battery before/after | Driver and operating system also affect execution |
| Side Channels by Software | Host dedicated to more sensitive content; prevent untrusted processes/co-tenants; compatible memory/cache isolation | Review of the threat model and specialized testing | Containers share kernel and do not eliminate every side channel |
| Physical probes, accessories and theft | Controlled room/rack, docks/loaders inventory, equipment and disk protection | Physical audit; specialized laboratory when necessary | Disk encryption does not shield emissions during inference |

The [Brave](https://brave.com/blog/indirect-prompt-injection/) demonstrated prompt injection in local and remote products and proposes defense in depth, less privilege and control of information flow. The relevant point is to contain consequences in the system rather than rely exclusively on alignment or an instruction “do not leak data”.

In tools already available, [LM Studio documents offline operation](https://lmstudio.ai/docs/app/offline) and [authentication while serving on the network](https://lmstudio.ai/docs/developer/core/server/serve-on-network). The [Official Ollama FAQ](https://github.com/ollama/ollama/blob/main/docs/faq.mdx) documentation `OLLAMA_NO_CLOUD=1`. These controls do not replace the verification of IDE, MCP, logs and traffic. In the workspace of this research there are scripts configured for **Ollama Cloud**; they are not, by themselves, the local deployment proposed in this document.

### Critical reading of the first transcript provided

No identifiable video URL or title was provided; the times below refer to the sent transcript. The underlying publications were searched separately.

| Excerpt | Verification and correction | Source |
|---|---|---|
| 0:00–0:18: local execution saves prompts and answers | Valid when the entire flow remains local; tools, telemetry and synchronization need to be included in the scope | [LM Studio offline](https://lmstudio.ai/docs/app/offline) |
| 0:25–0:39: February SitePoint guide | Guide of 15/02/2026 located; it is editorial tutorial, not security audit | [SitePoint](https://www.sitepoint.com/definitive-guide-local-llms-2026-privacy-tools-hardware/) |
| 0:40–0:47 and 2:34–2:41: OpenAI filter as a button that blocks categories | The product exists, but it is open-weight PII detection/removal model, not a universal privacy firewall | [Official notice](https://openai.com/index/introducing-openai-privacy-filter/) |
| 0:47–0:58 and 2:41–2:49: AIMultiple comparison | Localized page; comparing topology and cost does not prove that local latency will always be lower | [AIMultiple](https://aimultiple.com/cloud-llm) |
| 0:58–1:12: eliminates unwanted intercept and update | Deletes sending that prompt to the remote API if there is no call; does not delete local intercept, malware or runtime update | Architecture analysis; controls in the above matrix |
| 1:12–1:19 and 2:49–2:58: “Egard”, May/2026 | The name found is **Eguard**, published in AAAI on 14/03/2026, with a preprint of 2024. Protects embeddings against inversion, not all data or physical channels | [AAAI](https://ojs.aaai.org/index.php/AAAI/article/view/40876) |
| 1:19–1:35: NVIDIA and Brave | Localized publications; sandbox contains access, but prompt injection remains relevant | [NVIDIA](https://developer.nvidia.com/blog/build-a-secure-always-on-local-ai-agent-with-nvidia-nemoclaw-and-openclaw/), [Brave](https://brave.com/blog/indirect-prompt-injection/) |
| 1:35–1:57 and 3:07–3:23: How-To Geek and XDA | The exact articles, with these dates and statements, were not authenticated in this search. The viability of local endpoints is documented by runtimes | [LM Studio API](https://lmstudio.ai/docs/developer/core/server) |
| 1:57–2:20: speed, offline and quantisation | Offline and version control are viable; speed and memory depend on hardware, context, engine and quantization | Hardware tables of this report |

The [OpenAI Privacy Filter](https://openai.com/index/introducing-openai-privacy-filter/) it was announced on 22/04/2026: 1.5B total parameters, 50M active, local execution and eight data categories. OpenAI declares to use an adjusted version in its own privacy streams. It can compose a minimization barrier before a remote fallback. **Removing PII does not automatically remove intellectual property, business logic or all secrets.** The filter has false negatives and requires domain evaluation.

[Eguard](https://ojs.aaai.org/index.php/AAAI/article/view/40876) reports protection of more than 95% of tokens against the inversion attacks evaluated, preserving utility. The result is specific to embeddings and tested opponents. It is not “95% security” of a computer deployment, nor electromagnetic protection.

### Second transcription: real physical channel, overly generalized narrative

The preprint [Physical Side-Channel Attacks on Edge LLMs, October/2026](https://arxiv.org/html/2610.14215v1) offers concrete evidence: Llama-3.2-1B Q4_K_M in Raspberry Pi 5 CPU, probe next to the board, fixed frequency and laboratory oscilloscope. It reports 97.2% in the classification of 50 previously profiled words; for unseen words, 67% of top-100. The results do not equal the exact reconstruction of any prompt on any laptop. The article presents GPUs as a future extension and discusses shielding, randomization and masking as possible defenses.

![Electromagnetic probe positioned next to the Raspberry Pi board in the published experiment](../pesquisa_html/assets/experimento-em.webp)

Image: Figure 3 of [article by Alhalawani and collaborators](https://arxiv.org/html/2610.14215v1), reproduction for analysis. The visible positioning of the probe helps distinguish the experiment from a generic claim about someone sitting a metre away.

The transcript mixes EM emissions, power consumption, temperature, cache and rack-based adversaries as if they produced the same text recovery. They are different mechanisms. The video does not provide sufficient evidence for the claim that any USB-C charger, coworking power strip or cheap SDR recovers an arbitrary prompt, character by character, from a Mac or NPU. “More heat” also does not demonstrate greater data recoverability. These statements are not adopted as facts.

There's another real threat on [I Know What You Said, USENIX Security 2025](https://www.usenix.org/conference/usenixsecurity25/presentation/gao-zibo): cache leak, with opposing process and shared features. The [full paper](https://www.usenix.org/system/files/usenixsecurity25-gao-zibo.pdf) discusses memory sharing control and cache partitioning in compatible hardware. This supports workload isolation and platform selection, but does not allow to say that any VM solves any side channel.

For common corporate environments, the first steps are to protect the host, limit execution and egress, control accessories and maintain physical access under management. For secrets that justify physically close and specialized opponent, add emission assessment, qualified shielding and dedicated infrastructure. “Constant power” and random noise are not universal options ready for MLX or llama.cpp; require specific implementation and validation.

**Security conclusion:** local inference reduces an important class of exposure — routine transmission to third parties — and increases operational control. It can be protected with practices already documented by large providers. It does not offer physical invisibility, just as cloud services must also protect hardware and isolate customers. The proper approach is to compare threat models and residual risk, rather than equating all scenarios.


## Conclusions and open questions

The Snorkel case shows that a small expert can overcome a much larger generalist in the use of financial tools. The published weights allow testing local inference. The evidence supports the strategy of centrally training and distributing smaller specialists, but the financial return and programming utility depend on the flow and hardware measured.

Additional cases demonstrate local code product, commercial experts and gains in software benchmarks. They remain open for the team that will adopt the solution: performance after quantization, latency in available hardware, quality in their own code and QA tasks, full cost of specialization and maintenance when tools or schemas change. Also missing, in the cases consulted, proof of IBM or Google using specifically the recent Qwen and DeepSeek on desktops with measured gains.

## Code agents, local models and VS Code: concrete deployment options

Update October 16, 2026. The development interface, model that produces tokens and execution permissions are separate layers. You can keep a known agent and change your backend to an internal station or server. Therefore, security problems of an agent with unrestricted access do not invalidate local inference: there is choice of harness, permission setting and external isolation. The documentation below confirms integration paths; it is not a performance test or a comparative product audit.

### Compatibility and documented controls

| Interface | Path to local inference | Controls and checkpoints | Primary source |
|---|---|---|---|
| Oh My Pi / `omp` | Discovery of Ollama, llama.cpp and LM Studio; configurable providers | Tool and command approval policies; review effective configuration, extensions and process permissions | [Providers](https://github.com/can1357/oh-my-pi/blob/main/docs/providers.md), [Settings](https://github.com/can1357/oh-my-pi/blob/main/docs/settings.md) |
| OpenCode | Local provider with compatible API including Ollama and LM Studio | `allow`, `ask`, `deny` by tool/path/command; rules do not replace OS isolation | [Providers](https://opencode.ai/docs/providers/), [Permissions](https://opencode.ai/docs/permissions/) |
| Claude Code / `claude` | Ollama provides API compatible with Anthropic; `ollama launch claude` or manual endpoint | Approval flow; Bash sandbox with file isolation and network, according to platform | [Integration Ollama](https://docs.ollama.com/integrations/claude-code), [Sandbox Anthropic](https://code.claude.com/docs/en/sandboxing) |
| Codex CLI | `--oss --local-provider ollama` or `lmstudio`, with model served locally | Configurable Sandbox and approval; maintain restrictions while changing the backend | [Official reference OpenAI](https://learn.chatgpt.com/docs/developer-commands?surface=cli), [Security and approvals](https://learn.chatgpt.com/docs/agent-approvals-security) |
| GitHub Copilot CLI | Custom compatible endpoint, including Ollama; documented offline mode | `COPILOT_OFFLINE=true` avoids contact with GitHub servers; the endpoint also needs to be local | [BYOK and offline mode](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-byok-models) |
| VS Code | Chat with local models by provider selector; CLIs can also run on the integrated terminal | Choose local models also for auxiliary tasks; review extensions and remote features | [Models in VS Code](https://code.visualstudio.com/docs/agent-customization/language-models) |

**Oh My Pi and OpenCode are configurable alternatives; “safer” is not a property demonstrated by name only.** In the Oh My Pi consulted, `tools.approvalMode` defaults to `yolo`, while `always-ask` and policies by tool allow to restrict actions. Documentation shows that project configuration can replace global lists, including `disabledProviders`. A corporate policy needs to validate the effective outcome. In OpenCode, most permissions start at `allow`; there is specific processing for files `.env` and confirmation for external directories. These defaults should be reviewed before processing sensitive projects. Sources: [OMP Settings](https://github.com/can1357/oh-my-pi/blob/main/docs/settings.md) and [OpenCode Permissions](https://opencode.ai/docs/permissions/).

A proper comparison considers a specific configuration: exposed tools, mounted files, available credentials, network destinations, extensions and whether the repository can change policies. An open harness allows these components to be inspected and adapted; this facilitates governance but does not constitute certification. This update did not find an independent benchmark ranking these six environments by resistance to exfiltration under equivalent conditions.

### Connection examples, without changing the developer’s workflow

The examples below are illustrative and were not executed in this research. `INSTALLED_LOCAL_MODEL` must be replaced with the identifier actually installed in the runtime. Compatibility depends on the version, protocol, streaming, tool calls and available context; the model name alone does not guarantee agentic functionality.

In Codex CLI, the explicit selection of the local backend can be done thus, preserving the sandbox policy and approvals adopted by the team:

```bash
codex --oss --local-provider ollama --model INSTALLED_LOCAL_MODEL
```

The [official OpenAI reference](https://learn.chatgpt.com/docs/developer-commands?surface=cli) documents the options. The command connects the harness to a local model; it does not install weights or prove that all auxiliary tools are offline.

In Claude Code, the [integration documented by Ollama](https://docs.ollama.com/integrations/claude-code) allows you to select the model in the launcher or configure the connection directly:

```bash
ANTHROPIC_BASE_URL=http://127.0.0.1:11434 \
ANTHROPIC_AUTH_TOKEN=ollama \
ANTHROPIC_API_KEY="" \
claude --model INSTALLED_LOCAL_MODEL
```

`ollama` in this example is a compatibility value, not server access protection. Models marked as cloud remain remote, even with Ollama installed on the machine. This means using the **Claude Code client with another model**, not running Claude’s proprietary weights locally.

For Copilot CLI, [GitHub documents](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-byok-models) endpoint configuration and offline mode:

```bash
COPILOT_PROVIDER_BASE_URL=http://127.0.0.1:11434 \
COPILOT_MODEL=INSTALLED_LOCAL_MODEL \
COPILOT_OFFLINE=true \
copilot
```

The model needs to support tool calling and streaming. The documentation recommends a context of at least 128k for better results, which should enter memory sizing; it should not be assumed that weight quantization will solve the cost of KV cache. Remote endpoint is still remote with the flag offline.

In [VS Code](https://code.visualstudio.com/docs/agent-customization/language-models), the documented path is `Chat: Manage Language Models`, add a local provider and select the model. `chat.utilityModel` and `chat.utilitySmallModel` can also point to local models. The documentation distinguishes local chat from inline suggestions and dependent features of Copilot embeddings/services, which do not automatically go offline. The BYOK support for Copilot harness sessions in Agent Host is indicated as experimental. You should not extrapolate terminal support to every IDE extension.

### Real Sandbox also exists on Mac

The previous section highlighted OpenShell Linux controls. There is another relevant option: the [Claude Code sandbox](https://code.claude.com/docs/en/sandboxing) documents Seatbelt on macOS and bubblewrap on Linux/WSL2, with rules for files and network. Therefore, a Linux VM is not the only possibility of isolation on Mac. It is necessary to check the range of Bash sandbox, the tools executed outside it and the treatment of exceptions. It is not proposed to enable flags that remove approvals or isolation.

### How to choose for backend, testing and UI

The pilot should compare at least two harnesses with the same model and access policy. In the first run, allow repository reading and a proposed diff; then allow workspace writes and tests in a disposable environment. For UI work, expose a browser and test application without an authenticated corporate session. For backend work, use a test database and minimally scoped credentials. For QA, run fixtures and tests without write access to production. These are proposed deployment criteria, not controls already installed in this research.

| Proposed acceptance criterion | Evidence that the pilot must keep |
|---|---|
| Inference remains internal | Real destination of connections, including titles, compaction, embeddings and subagents |
| Files and secrets have boundaries | Controlled reading attempts outside workspace; no real credentials in the tests |
| Run is contained | Attempts to access network and prohibited volumes; OS/proxy blocking record |
| Policies resist project configuration | Comparison of effective configuration before and after opening an untrusted repository |
| Changes are verifiable | Diff, build and tests performed; acceptance by review, without relying solely on agent statement |
| There are real savings | Cost per accepted task, latency, revision time, local operation and remaining API |

The potential economic benefit is to retain a familiar editor and workflow while reducing paid inference and managing context locally. This may reduce migration effort, but it must be measured. The integration budget already planned should cover harness compatibility and policies; no investment reduction was assumed without running the pilot. When escalation occurs, it remains **local + cloud**, with authorization of data, budget and destination record.


## Update History

| Date | Embedded content |
|---|---|
| 16 October 2026 | Local Harnesses: Oh My Pi, OpenCode, Claude Code, Codex CLI, Copilot CLI and VS Code; controls, defaults, integration and validation; preparation of integral publication in GitHub |
| 16 October 2026 | Three HTML documents; public reports of regression and causality limits; transcript verification; local security, Google/NVIDIA controls and side channel research; source images and investment calculator |
| 16 October 2026 | Consolidation of initial research on companies, local infrastructure, Mac minis, models and benchmarks |
| 16 October 2026 | Study verification Snorkel and UC Berkeley, publication of weights, metrics, cost, tool versions and implications for development and QA |
| 16 October 2026 | Inclusion of JetBrains, Google FunctionGemma, Rocketgraph, Knowunity, Octodet, Mistral and All Hands AI, Salesforce, Microsoft Research and NVIDIA Research, with distinction between product, benchmark and deployment |
| 16 October 2026 | Benchmarks Aider and SWE-Lego and economic protocol; initial selection of hybrids was corrected in the following update |
| 16 October 2026 | Hybrid scope restricted to local + cloud: removal of only remote cases; inclusion of Nav, MCCom and Hybrid Coding Arena, maintaining MinionS |
| 16 October 2026 | Local savings + cloud: HERA, TCO replay with repairs, DeloitteSage, claim deletion criteria and return calculation |
| 16 October 2026 | Cut backend, frontend/UI and QA: Nav TypeScript, Pulpcut, LLaVA/Groq with Playwright, Agential QE limitations and deletion of examples without local + cloud combination |
| 16 October 2026 | Mac Benchmarks 16–512 GB: Residents, streaming experts and SSD lookup; PP, decode, Reasoning, context, conditions and gaps |
| 16 October 2026 | Extension of Q4/Q8, 27B/35B in Max and Ultra 256/512 GB; MLX and llama.cpp; MTP/DFlash; benchmarks Colibri and Engram/experts distinction in SSD |
| 16 October 2026 | Economics by token/dev/time, Pegatron and Yembo, business costs, hardware equivalence, local sensitivity+cloud, harness/expert surveys, verification of claim on Opus 4.8 and record of rejected sources |
| 16 October 2026 | Intensive spending of $2,000–10,000, speaks original Nadella, IP and contracts, Dell/Signal65, local return scenarios+cloud, data and specialization Qwen/FigmaTrace and DeepSeek size correction V4.1 |

Additional technical reference: [post rLLM](https://rllm-project.com/post.html?post=finqa.md). The address answered only with the loading structure; the numbers recorded above were checked in the model card and Snorkel publications.
