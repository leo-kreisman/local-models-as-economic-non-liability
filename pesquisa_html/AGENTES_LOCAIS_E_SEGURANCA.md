## Agentes de código, modelos locais e VS Code: opções concretas de implantação

Atualização de 16 de outubro de 2026. A interface de desenvolvimento, o modelo que produz tokens e as permissões de execução são camadas separadas. É possível manter um agente conhecido e mudar seu backend para uma estação ou servidor interno. Portanto, problemas de segurança de um agente com acesso irrestrito não invalidam a inferência local: existe escolha de harness, configuração de permissões e isolamento externo. A documentação abaixo confirma caminhos de integração; não é um teste de desempenho ou uma auditoria comparativa dos produtos.

### Compatibilidade e controles documentados

| Interface | Caminho para inferência local | Controles e pontos de verificação | Fonte primária |
|---|---|---|---|
| Oh My Pi / `omp` | Descoberta de Ollama, llama.cpp e LM Studio; providers configuráveis | Políticas de aprovação por ferramenta e comando; revisar configuração efetiva, extensões e permissões do processo | [Providers](https://github.com/can1357/oh-my-pi/blob/main/docs/providers.md), [Settings](https://github.com/can1357/oh-my-pi/blob/main/docs/settings.md) |
| OpenCode | Provider local com API compatível, incluindo Ollama e LM Studio | `allow`, `ask`, `deny` por ferramenta/caminho/comando; regras não substituem isolamento do SO | [Providers](https://opencode.ai/docs/providers/), [Permissions](https://opencode.ai/docs/permissions/) |
| Claude Code / `claude` | Ollama fornece API compatível com Anthropic; `ollama launch claude` ou endpoint manual | Fluxo de aprovação; sandbox de Bash com isolamento de arquivos e rede, conforme plataforma | [Integração Ollama](https://docs.ollama.com/integrations/claude-code), [Sandbox Anthropic](https://code.claude.com/docs/en/sandboxing) |
| Codex CLI | `--oss --local-provider ollama` ou `lmstudio`, com modelo servido localmente | Sandbox e aprovação configuráveis; manter restrições ao mudar o backend | [Referência oficial OpenAI](https://learn.chatgpt.com/docs/developer-commands?surface=cli), [Segurança e aprovações](https://learn.chatgpt.com/docs/agent-approvals-security) |
| GitHub Copilot CLI | Endpoint próprio compatível, inclusive Ollama; modo offline documentado | `COPILOT_OFFLINE=true` evita contato com servidores GitHub; o endpoint também precisa ser local | [BYOK e modo offline](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-byok-models) |
| VS Code | Chat com modelos locais pelo seletor de provedores; CLIs também podem rodar no terminal integrado | Escolher modelos locais também para tarefas auxiliares; revisar extensões e recursos remotos | [Modelos no VS Code](https://code.visualstudio.com/docs/agent-customization/language-models) |

**Oh My Pi e OpenCode são alternativas configuráveis; “mais seguros” não é uma propriedade demonstrada apenas pelo nome.** No Oh My Pi consultado, `tools.approvalMode` tem padrão `yolo`, enquanto `always-ask` e políticas por ferramenta permitem restringir ações. A documentação mostra que configuração de projeto pode substituir listas globais, inclusive `disabledProviders`. Uma política corporativa precisa validar o resultado efetivo. No OpenCode, a maioria das permissões inicia em `allow`; há tratamento específico para arquivos `.env` e confirmação para diretórios externos. Esses padrões devem ser revistos antes de processar projetos sensíveis. Fontes: [OMP Settings](https://github.com/can1357/oh-my-pi/blob/main/docs/settings.md) e [OpenCode Permissions](https://opencode.ai/docs/permissions/).

A comparação correta considera uma configuração concreta: ferramentas expostas, arquivos montados, credenciais disponíveis, destinos de rede, extensões e possibilidade de o repositório alterar políticas. Um harness aberto permite inspecionar e adaptar esses componentes; isso facilita governança, mas não constitui certificação. Não foi localizado nesta atualização um benchmark independente que classifique esses seis ambientes por resistência a exfiltração sob condições equivalentes.

### Exemplos de conexão, sem trocar o trabalho do desenvolvedor

Os exemplos abaixo são ilustrativos e não foram executados nesta pesquisa. `MODELO_LOCAL_INSTALADO` deve ser substituído pelo identificador realmente instalado no runtime. A compatibilidade depende de versão, protocolo, streaming, chamadas de ferramentas e contexto disponível; o nome do modelo isoladamente não garante funcionamento agentivo.

No Codex CLI, a seleção explícita do backend local pode ser feita assim, preservando a política de sandbox e aprovações adotada pela equipe:

```bash
codex --oss --local-provider ollama --model MODELO_LOCAL_INSTALADO
```

A [referência oficial OpenAI](https://learn.chatgpt.com/docs/developer-commands?surface=cli) documenta as opções. O comando conecta o harness a um modelo local; não instala pesos nem comprova que todas as ferramentas auxiliares estejam offline.

No Claude Code, a [integração documentada pelo Ollama](https://docs.ollama.com/integrations/claude-code) permite selecionar o modelo no launcher ou configurar a conexão diretamente:

```bash
ANTHROPIC_BASE_URL=http://127.0.0.1:11434 \
ANTHROPIC_AUTH_TOKEN=ollama \
ANTHROPIC_API_KEY="" \
claude --model MODELO_LOCAL_INSTALADO
```

`ollama` nesse exemplo é um valor de compatibilidade, não proteção de acesso ao servidor. Modelos marcados como cloud continuam remotos, mesmo com o Ollama instalado na máquina. Trata-se de usar o **cliente Claude Code com outro modelo**, não de executar os pesos proprietários do Claude localmente.

No Copilot CLI, o [GitHub documenta](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-byok-models) configuração de endpoint e modo offline:

```bash
COPILOT_PROVIDER_BASE_URL=http://127.0.0.1:11434 \
COPILOT_MODEL=MODELO_LOCAL_INSTALADO \
COPILOT_OFFLINE=true \
copilot
```

O modelo precisa suportar tool calling e streaming. A documentação recomenda contexto de pelo menos 128k para melhores resultados, o que deve entrar no dimensionamento de memória; não se deve presumir que quantização de pesos resolva o custo do KV cache. Endpoint remoto continua remoto com a flag offline.

No [VS Code](https://code.visualstudio.com/docs/agent-customization/language-models), o caminho documentado é `Chat: Manage Language Models`, adicionar um provedor local e selecionar o modelo. `chat.utilityModel` e `chat.utilitySmallModel` também podem apontar para modelos locais. A documentação distingue chat local de sugestões inline e recursos dependentes de embeddings/serviços Copilot, que não passam automaticamente a funcionar offline. O suporte BYOK em sessões do Copilot harness no Agent Host é indicado como experimental. Não se deve extrapolar suporte do terminal para toda extensão de IDE.

### Sandbox real também existe no Mac

A seção anterior destacou controles Linux do OpenShell. Há outra opção relevante: o [sandbox do Claude Code](https://code.claude.com/docs/en/sandboxing) documenta Seatbelt no macOS e bubblewrap no Linux/WSL2, com regras para arquivos e rede. Portanto, uma VM Linux não é a única possibilidade de isolamento no Mac. É preciso verificar o alcance do sandbox de Bash, as ferramentas executadas fora dele e o tratamento de exceções. Não se propõe habilitar flags que removam aprovações ou isolamento.

### Como escolher para backend, testes e UI

O piloto deve comparar pelo menos dois harnesses com o mesmo modelo e a mesma política de acesso. Na primeira execução, permitir leitura do repositório e proposta de diff; depois liberar escrita no workspace e testes em ambiente descartável. Para UI, expor navegador e aplicação de teste sem sessão corporativa autenticada. Para backend, usar banco de testes e credenciais de escopo mínimo. Para QA, executar fixtures e testes sem acesso de escrita à produção. São critérios de implantação propostos, não controles já instalados nesta pesquisa.

| Critério de aceitação proposto | Evidência que o piloto deve guardar |
|---|---|
| Inferência permanece interna | Destino real das conexões, incluindo títulos, compactação, embeddings e subagentes |
| Arquivos e segredos têm fronteiras | Tentativas controladas de leitura fora do workspace; nenhuma credencial real nos testes |
| Execução está contida | Tentativas de acessar rede e volumes proibidos; registro de bloqueio pelo SO/proxy |
| Políticas resistem à configuração do projeto | Comparação da configuração efetiva antes e depois de abrir repositório não confiável |
| Mudanças são verificáveis | Diff, build e testes executados; aceitação por revisão, sem confiar somente na declaração do agente |
| Há economia real | Custo por tarefa aceita, latência, tempo de revisão, operação local e API remanescente |

O ganho econômico potencial é conservar editor e fluxo conhecidos enquanto se reduz inferência paga e se administra o contexto localmente. Isso pode reduzir esforço de migração, mas precisa ser medido. A verba de integração já prevista deve incluir compatibilidade dos harnesses e políticas; nenhum desconto no investimento foi presumido sem execução do piloto. Quando houver escalonamento, ele continua sendo **local + nuvem**, com autorização de dados, orçamento e registro do destino.
