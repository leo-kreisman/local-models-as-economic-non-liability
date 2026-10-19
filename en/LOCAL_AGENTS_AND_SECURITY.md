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
