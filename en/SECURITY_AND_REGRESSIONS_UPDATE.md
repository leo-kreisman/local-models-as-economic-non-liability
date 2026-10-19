## Perceived regressions, public reports and operational stability

The experience of programmers is relevant evidence for a purchase decision. It doesn't depend on recognition of the supplier to be registered. In this review, the question was divided into three: what problems were reported; what changes were measured; and what is known about its cause. The absence of proof of intention does not erase reports of loss of quality or cost of rework.

### observable volume: traceable sample, not estimate of the entire internet

On October 16, 2026, the public API of GitHub returned **102 issues** for consultation `repo:anthropics/claude-code is:issue "4.8" "degradation"`. The two pages were collected; the list is in [data/github-search.json](dados/github-search.json). These are search correspondences in title/body/comments, including possible duplicates and indirect references. **There are not 102 confirmed incidents, neither 102 people, nor a measure of the proportion of dissatisfied users.** The search does not constitute Reddit, X or LinkedIn census.

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

![Original Marginlab table: dates, versions and pass rates](assets/marginlab-tabela.webp)

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

![Electromagnetic probe positioned next to the Raspberry Pi board in the published experiment](assets/experimento-em.webp)

Image: Figure 3 of [article by Alhalawani and collaborators](https://arxiv.org/html/2610.14215v1), reproduction for analysis. The visible positioning of the probe helps distinguish the experiment from a generic claim about someone sitting a metre away.

The transcript mixes EM emissions, power consumption, temperature, cache and rack-based adversaries as if they produced the same text recovery. They are different mechanisms. The video does not provide sufficient evidence for the claim that any USB-C charger, coworking power strip or cheap SDR recovers an arbitrary prompt, character by character, from a Mac or NPU. “More heat” also does not demonstrate greater data recoverability. These statements are not adopted as facts.

There's another real threat on [I Know What You Said, USENIX Security 2025](https://www.usenix.org/conference/usenixsecurity25/presentation/gao-zibo): cache leak, with opposing process and shared features. The [full paper](https://www.usenix.org/system/files/usenixsecurity25-gao-zibo.pdf) discusses memory sharing control and cache partitioning in compatible hardware. This supports workload isolation and platform selection, but does not allow to say that any VM solves any side channel.

For common corporate environments, the first steps are to protect the host, limit execution and egress, control accessories and maintain physical access under management. For secrets that justify physically close and specialized opponent, add emission assessment, qualified shielding and dedicated infrastructure. “Constant power” and random noise are not universal options ready for MLX or llama.cpp; require specific implementation and validation.

**Security conclusion:** local inference reduces an important class of exposure — routine transmission to third parties — and increases operational control. It can be protected with practices already documented by large providers. It does not offer physical invisibility, just as cloud services must also protect hardware and isolate customers. The proper approach is to compare threat models and residual risk, rather than equating all scenarios.
