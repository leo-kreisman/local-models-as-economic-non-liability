# Capacidade local de IA para engenharia

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **IA** — inteligência artificial.

<!-- acronym-note:end -->

Proposta para decisão • Problem/Context + Solution + Required Investment • 16 de outubro de 2026

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **UI** — interface do usuário; **API** — interface de programação de aplicações; conecta componentes de software; **TCO** — custo total de propriedade, incluindo aquisição e operação; **US$** — dólares dos Estados Unidos; **IBM** — International Business Machines; empresa; **HP** — Hewlett-Packard; nome de empresa usado no contexto citado.

<!-- acronym-note:end -->

## Problem / Context — o problema e o contexto

A proposta é criar capacidade de inferência sob controle da empresa para reduzir o custo variável de programação assistida, conservar código e contexto sensível e aumentar a previsibilidade do ambiente. O objetivo inicial é substituir uma parcela verificável do consumo remoto de usuários intensivos, preservando acesso à nuvem para tarefas que justifiquem esse custo. O piloto proposto envolve cinco profissionais durante seis semanas, com tarefas de backend, UI, testes e manutenção de repositórios.

O relato recebido aponta profissionais com gastos de US$ 2 mil–10 mil. Para esta proposta, assume-se que a unidade seja **por profissional por mês**; confirmar a periodicidade e a fatura é parte da linha de base. Não se trata de média de mercado. Assinaturas, consumo API, valores estimados por monitores e faturas efetivas precisam ser separados. Cache, tamanho de contexto, repetição de ferramentas e agentes paralelos explicam por que preço por assento não descreve a despesa de um usuário intensivo.

O custo atual tem três componentes: inferência e serviços externos; tempo de engenharia para revisar e corrigir; e risco de dependência do fornecedor. Reduzir apenas a primeira parcela pode piorar o resultado se o modelo local exigir muito mais retrabalho. Por isso, a medida econômica do piloto será custo por tarefa aceita, acompanhada de tempo de ciclo e qualidade, além do gasto mensal. O [estudo Pegatron](https://arxiv.org/html/2607.13080v1), detalhado no relatório, ilustra esse cuidado: o TCO modelado melhora com infraestrutura compartilhada, mas piora sob alocação dedicada no mesmo caso.

A estabilidade também tem valor econômico. Há relatos de programadores de regressão do Opus 4.8 com exemplos e artefatos, como [#63861](https://github.com/anthropics/claude-code/issues/63861) e [#67606](https://github.com/anthropics/claude-code/issues/67606). Esses relatos merecem tratamento operacional mesmo quando a causa permanece incerta. A busca registrada encontrou 102 correspondências no GitHub, não 102 incidentes confirmados. O [acompanhamento Marginlab](https://marginlab.ai/blog/claude-code-degraded-before-opus-4-8/) mostra variação diária do produto em outro episódio, anterior ao lançamento do 4.8. A decisão não depende de provar degradação deliberada: poder conservar uma configuração aprovada e manter alternativas já reduz dependência.

Código enviado para inferência remota não se torna automaticamente propriedade do fornecedor. Há contratos empresariais que restringem treinamento, como a [política comercial Anthropic](https://privacy.claude.com/en/articles/9267385-does-anthropic-act-as-a-data-processor-or-controller). Ainda assim, a empresa precisa decidir onde contexto, logs, avaliações e feedback podem ser processados e retidos. A [reflexão de Satya Nadella](https://snscratchpad.com/posts/reverse-information-paradox/) reforça o valor estratégico desse conhecimento. Não foi demonstrada cessão de sistemas de IBM, HP ou Dell; o problema tratado aqui é a exposição e a dependência que podem ser administradas.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **GUI** — interface gráfica do usuário; **API** — interface de programação de aplicações; conecta componentes de software; **IDE** — ambiente integrado de desenvolvimento; **RAM** — memória de acesso aleatório; memória de trabalho; **SSD** — unidade de armazenamento de estado sólido; **GB** — gigabyte, unidade decimal de capacidade de dados; **MoE** — mistura de especialistas; ativa parte das redes de especialistas por token; **B / A…B** — B indica bilhões de parâmetros; A antes da contagem indica parâmetros ativos por token.

<!-- acronym-note:end -->

## Solution — solução proposta

A arquitetura proposta mantém um modelo local principal, o repositório, a busca de contexto e a execução de testes dentro do ambiente controlado. Tarefas elegíveis usam esse caminho por padrão. Um gateway aplica regras de dados e orçamento para enviar à nuvem somente o contexto necessário de tarefas autorizadas. Conteúdo que não pode sair permanece local; dificuldade do modelo não autoriza automaticamente exportação. Essa é uma combinação **local + nuvem**, não apenas roteamento entre duas APIs externas.

A escolha inicial deve comparar um 27B denso e um 35B MoE, em 4 e 8 bits, no harness utilizado pela equipe. A contagem total do MoE determina armazenamento, enquanto a parte ativa ajuda a explicar custo de computação; não são medidas intercambiáveis. Uma configuração de aproximadamente 64 GB é candidata prática para esses modelos, mas contexto, IDE, containers de testes e processos concorrentes precisam entrar na medição. Flash-Next com offloading em SSD integra o piloto de 64 GB; DeepSeek V4.1 terá qualificação própria: o custo de I/O e a latência devem ser comparados ao ganho de qualidade.

A [model card Qwen3.8-27B](https://huggingface.co/Qwen/Qwen3.8-27B) mostra evolução mantendo 27B, e o [FigmaTrace](https://arxiv.org/html/2608.21460v1) mostra especialização do mesmo modelo com dados de GUI. São justificativas para avaliar modelos compactos, não garantias de equivalência universal. O [DeepSeek V4.1 Flash](https://arxiv.org/html/2609.19969v1) é uma arquitetura maior com cache mais eficiente; sua evolução não deve ser descrita como simples melhora de dataset com tamanho constante.

<!-- acronym-note:start -->

**Siglas e notações da tabela:** **QA** — garantia da qualidade; **UI** — interface do usuário; **API** — interface de programação de aplicações; conecta componentes de software; **SQL** — Structured Query Language; linguagem de consulta a bancos de dados.

<!-- acronym-note:end -->

| Trabalho | Caminho inicial | Validação antes de aceitar |
|---|---|---|
| Backend e APIs | Modelo local para alterações delimitadas, SQL e integração | Testes unitários, contrato de API, análise de segurança e revisão do diff |
| QA | Geração local de casos, fixtures e testes; execução isolada | Compilação, execução repetida, cobertura útil e detecção de flakiness |
| UI | Modelo local com contexto visual quando suportado | Capturas, comparação visual, acessibilidade e testes Playwright |
| Código legado | Explicação e refatoração local por módulo | Testes de caracterização e preservação de comportamento |
| Arquitetura ou falha difícil | Revisão humana e, quando autorizado, escalonamento remoto | Comparação de solução, custo, dados enviados e tarefa efetivamente resolvida |

Há dois modos de disponibilizar essa capacidade. Máquinas individuais conservam isolamento e evitam fila compartilhada, mas podem ter baixa utilização. Um servidor interno com API facilita manutenção e rateio, mas exige planejamento de concorrência e controle de acesso entre projetos. Um cluster de Macs não deve ser comprado supondo soma linear de RAM ou tokens/s: divisão de um modelo entre nós, réplicas independentes e filas de tarefas têm custos diferentes. Os casos e benchmarks do relatório orientam os ensaios; não substituem um dimensionamento do time.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **CLI** — interface de linha de comando; **OMP** — Oh My Pi; agente de programação; **VM** — máquina virtual; **BYOK** — usar sua própria chave; fornecer uma credencial do provedor.

<!-- acronym-note:end -->

### Agentes e editor: conservar o fluxo, escolher o backend

O piloto incluirá Oh My Pi, OpenCode e Aider como alternativas configuráveis, além da possibilidade de conservar Claude Code, Codex CLI, Copilot CLI e VS Code com inferência local. Os caminhos estão documentados em [OMP Providers](https://github.com/can1357/oh-my-pi/blob/main/docs/providers.md), [OpenCode Providers](https://opencode.ai/docs/providers/), [Ollama para Claude Code](https://docs.ollama.com/integrations/claude-code), [OpenAI — CLI](https://learn.chatgpt.com/docs/developer-commands?surface=cli), [GitHub — Copilot BYOK](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-byok-models) e [VS Code — modelos](https://code.visualstudio.com/docs/agent-customization/language-models). A integração preserva a interface familiar e pode diminuir esforço de adoção; o benefício será medido, sem redução presumida do orçamento.

A escolha considerará a política efetiva de ferramentas e a contenção no sistema operacional. OMP e OpenCode oferecem controles granulares, mas seus padrões documentados são permissivos: `yolo` no primeiro e `allow` para a maioria das ferramentas no segundo. Fontes: [OMP Settings](https://github.com/can1357/oh-my-pi/blob/main/docs/settings.md) e [OpenCode Permissions](https://opencode.ai/docs/permissions/). A proposta é qualificar configurações restritas. Não há ranking independente de segurança entre esses produtos apresentado aqui. No Mac, o [sandbox de Bash do Claude Code](https://code.claude.com/docs/en/sandboxing) usa Seatbelt; VM Linux não é a única opção de isolamento.

O aceite deve confirmar o destino da inferência e dos serviços auxiliares, testar execução e arquivos proibidos e verificar que a configuração de um projeto não relaxe a política corporativa. O detalhamento de comandos, limites do modo offline e recursos do editor está no relatório. A verba de integração contempla essa qualificação de harnesses.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **API** — interface de programação de aplicações; conecta componentes de software; **GPU** — unidade de processamento gráfico; **MLX** — framework de aprendizado de máquina da Apple; nome de runtime, não de quantização; **OMP** — Oh My Pi; agente de programação; **VM** — máquina virtual; **SO** — sistema operacional; **CI** — integração contínua; verificações automatizadas de compilação e testes; **DNS** — sistema de nomes de domínio; resolve nomes na rede; **SSH** — Secure Shell; protocolo de acesso remoto autenticado.

<!-- acronym-note:end -->

### Segurança de estações com acesso à internet

Os candidatos propostos são **OMP, OpenCode e Aider**, com MLX ou llama.cpp atrás de gateway local autenticado. Hermes e OpenClaw estão fora da implantação. Separar execução de código, inferência, consulta à internet e exportação para nuvem em componentes controlados independentemente. No Mac, o modelo pode usar a GPU do host enquanto as ferramentas do agente rodam em VM restrita; apenas a rota necessária ao gateway é exposta à VM.

Docker documenta [OpenCode em sandboxes locais](https://docs.docker.com/ai/sandboxes/agents/opencode/) com isolamento por microVM. Anthropic publica um [runtime de sandbox no SO](https://github.com/anthropics/sandbox-runtime) aplicável a processos arbitrários. São referências de implementação, não certificação do piloto. A [documentação do servidor MLX](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/SERVER.md) alerta explicitamente contra uso produtivo com suas verificações básicas; um listener de desenvolvimento não deve ser exposto como serviço empresarial completo.

O acesso à internet usará intermediário de consulta restrito. Negar uploads arbitrários e saída direta do executor, validar redirecionamentos e destinos DNS, bloquear endpoints privados/metadados e separar navegação de acesso a código sensível. Domínios permitidos sozinhos não impedem exfiltração. Exportação para nuvem exige decisão separada sobre dados; dificuldade ou falha de teste não autoriza enviar código proprietário. Credenciais ficam fora do contexto, e APIs compartilhadas exigem identidade e isolamento por projeto.

A aceitação inclui testes de vazamento de segredos sintéticos, instruções maliciosas em arquivos e páginas, leitura não autorizada, saída de rede em instalação de dependências, sobreposição de configuração, acesso a banco de produção e isolamento de sessão de navegador. Os [limites documentados pelo Docker](https://docs.docker.com/ai/sandboxes/security/isolation) incluem segredos não rastreados legíveis em clone mode e autoridade concedida por encaminhamento SSH; ambos exigem tratamento explícito. CI independente revisa patches, workflows e hooks. Timeouts e limites de tokens/gasto contêm loops e fallback descontrolado.

Canais laterais físicos são ameaça especializada secundária, documentada no apêndice da pesquisa. O investimento principal protege ativos cotidianos da estação contra roubo de credenciais, execução fora do workspace, exportação de dados, comprometimento da cadeia de suprimentos e persistência. A matriz completa de controles/testes está no [guia de engenharia](GUIA_ENGENHARIA_HIBRIDA.md).

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **UI** — interface do usuário; **TCO** — custo total de propriedade, incluindo aquisição e operação; **HERA** — sistema de alocação de tarefas entre local e nuvem avaliado no estudo citado; **DTO** — objeto de transferência de dados; **SQL** — Structured Query Language; linguagem de consulta a bancos de dados; **US$** — dólares dos Estados Unidos.

<!-- acronym-note:end -->

### Roteamento por evidência e trabalho recorrente

O piloto priorizará edições mecânicas, propagação de DTO, expansão de regressões, alterações SQL delimitadas e manutenção UI. O Nav reporta custos pareados nuvem/híbrido de US$ 0,339/0,134 para mapper Ktor e US$ 0,227/0,121 para renomeação frontend, mas US$ 0,092/0,164 para Spring: delegar pode aumentar a fatura. O [estudo Nav](https://raw.githubusercontent.com/navikt/mlx-workspace/main/reports/local-inference-findings.md) apoia qualificar famílias de tarefas em vez de prometer uma taxa única de economia para todo código.

O [estudo HERA](https://arxiv.org/html/2504.00434v1), publicado em abril de 2025 com autores ligados à Microsoft, demonstra alocação local + nuvem, não implantação interna na Microsoft. O custo remoto HumanEval cai de US$ 0,056 para US$ 0,044, excluindo TCO local e com perda de qualidade. O destaque de 8% no README Arena conflita com as [notas revisadas](https://github.com/RunanywhereAI/hybrid-arena/blob/main/docs/release-notes/v1.4.1.md), que registram 10,3% dos tokens na nuvem. Nenhum equivale diretamente a percentual de economia na fatura.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **LLM** — modelo de linguagem de grande porte; **QA** — garantia da qualidade.

<!-- acronym-note:end -->

### Construir harnesses reutilizáveis e amortizar seu custo

Usar um modelo de nuvem autorizado para propor dois harnesses iniciais a partir de exemplos públicos ou minimizados e aprovados. Congelar o modelo local e avaliar mudanças de instruções, recuperação, schemas de ferramentas e recuperação de erros contra testes independentes. O [SkillOpt](https://www.microsoft.com/en-us/research/blog/skillopt-agent-skills-as-trainable-parameters/) oferece evidência de otimização de uma camada externa de skills; seus benchmarks não voltados a código não estabelecem equivalência de código empresarial. Para QA repetitivo, [Gungnir](https://arxiv.org/html/2610.14161v1) demonstra caminho complementar: melhorar geradores reutilizáveis de testes e executá-los sem novas chamadas a LLM.

Medir quatro braços: fluxo atual de nuvem, harness local genérico, harness local especializado e local especializado + nuvem. Incluir codemods determinísticos quando apropriado. Contar tentativas, planejamento remoto, categorias de cache, revisão humana, operação e desenvolvimento de harness. A otimização pela nuvem nunca deve alterar testes ocultos de aceitação nem política empresarial de segurança. As horas existentes de integração e segurança permanecem provisórias; ampliar além de dois harnesses exige nova estimativa.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **QA** — garantia da qualidade; **UI** — interface do usuário; **FinOps** — prática de operações financeiras para gerir consumo e custo de tecnologia.

<!-- acronym-note:end -->

### Piloto de seis semanas e decisão de expansão

Na primeira semana, FinOps e engenharia consolidam faturas, categorias de tokens, cache, tarefas e tempo de revisão. A segunda semana instala o ambiente e testa seus controles. Nas semanas três a cinco, os mesmos tipos de tarefa são comparados entre fluxo atual e fluxo local + nuvem, com ordem alternada quando viável para reduzir efeito de aprendizagem. A última semana consolida qualidade, despesa efetivamente evitada e capacidade por estação ou servidor.

Um conjunto inicial de 100 tarefas reais, distribuídas entre backend, UI, QA e manutenção, é uma **proposta de avaliação**, não amostra que garanta significância estatística. Os limiares de aprovação devem ser definidos antes da execução. Como ponto inicial para negociação: economia total de pelo menos 30%, queda de no máximo 5 pontos percentuais na taxa de tarefas aceitas, nenhuma exposição não autorizada nos testes de segurança e aumento de até 10% no tempo de ciclo. Defeitos críticos exigem análise própria, sem compensação por uma média de custo favorável.

O time de plataforma responde pelo runtime e atualizações; segurança pelas políticas e testes; FinOps pela fatura e rateio; líderes de engenharia e QA pela aceitação dos resultados. A expansão depende dessas evidências. Não se propõe desligar a capacidade atual antes de qualificar o caminho local.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **GB** — gigabyte, unidade decimal de capacidade de dados; **NR** — não reportado na medição citada.

<!-- acronym-note:end -->

## Estações de 32, 48 e 64 GB: capacidade local com investimento proporcional

Atualização: 19 de outubro de 2026. O piloto deve começar também nas máquinas existentes de 32, 48 e 64 GB. Capacidade de memória, velocidade do chip, quantização e implementação são variáveis distintas. Há medições publicadas na faixa de 20–30 tokens/s e acima dela em configurações selecionadas; não é necessário comprar uma estação de 128–512 GB para iniciar. Os números abaixo são publicados pelos executores, não reproduções desta pesquisa. NR significa não reportado nesta seleção.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **GB** — gigabyte, unidade decimal de capacidade de dados; **WARP** — Weight-Aware Runtime and Paging; runtime de inferência com streaming de pesos.

<!-- acronym-note:end -->

### Benchmarks diretamente úteis ao dimensionamento menor

<!-- acronym-note:start -->

**Siglas e notações da tabela:** **GPU** — unidade de processamento gráfico; **CPU** — unidade central de processamento; **SSD** — unidade de armazenamento de estado sólido; **GB** — gigabyte, unidade decimal de capacidade de dados; **GiB** — gibibyte, unidade binária de capacidade de dados; **MLX** — framework de aprendizado de máquina da Apple; nome de runtime, não de quantização; **oMLX** — software de serviço de modelos construído sobre MLX; **MTP** — predição de múltiplos tokens para geração especulativa; **PP** — processamento do prompt ou prefill; processa tokens de entrada; **TTFT** — tempo até o primeiro token; **KV** — cache de chaves e valores; armazena estado de atenção; **NR** — não reportado na medição citada; **Q4** — família de quantização em 4 bits; sufixos identificam o formato específico; **Q8** — família de quantização em 8 bits; sufixos identificam o formato específico; **IQ2_K** — formato de quantização de poucos bits usado para pesos do modelo; **NVFP4** — formato de ponto flutuante de 4 bits da NVIDIA; **WARP** — Weight-Aware Runtime and Paging; runtime de inferência com streaming de pesos; **tok/s** — tokens por segundo; medida de vazão; **K4/V4** — caches de chaves e valores quantizados em 4 bits; **B / A…B** — B indica bilhões de parâmetros; A antes da contagem indica parâmetros ativos por token.

<!-- acronym-note:end -->

| Máquina física | Modelo / formato | Runtime e residência | PP tok/s | Decode tok/s | Condição e fonte |
|---|---|---|---:|---:|---|
| M1 Pro, 32 GB, GPU 14 núcleos | Qwen3.6-35B-A3B Q4_K_S | llama.cpp b9466 / Metal; pesos em memória | NR | 25,4 | 22,4 GB wired a 32K; swap do host ~7,6 GB no trabalho de agente. [Executor](https://raw.githubusercontent.com/marcofariasmx/local-llm-apple-silicon/main/README.md) |
| M1 Max, 32 GB | Qwen3.8-27B MLX 4-bit | MLX; residente | 81,76 | 15,81 | 512 entrada / 700 saída; 3 execuções; pico 16,39 GB. [Executor](https://www.reddit.com/r/LocalLLM/comments/1wa0dl3/qwen3827b_on_m1_max_32gb_mlx_158_toks_vs_llamacpp/) |
| M1 Max, 32 GB | Qwen3.8-Flash-Next; especialistas principalmente IQ2_K | MoEspresso 3; SSD; KV K4/V4; Cache-Prior | NR | 12–15 | Autor exige folga de memória; viés favorece especialistas residentes e altera roteamento. [Executor](https://www.reddit.com/r/LocalLLaMA/comments/1wrqql8/qwen38flashnext_125b_at_1215_toks_on_a_2021_32gb/) |
| M4 Pro, 48 GB | Qwen3.8-27B 4-bit | Rapid-MLX 0.13.1; residente | 117 | 15,2 | Pico 18,9 GB; TTFT 18,2 s; submissão comunitária. [Registro](https://rapidmlx.com/benchmarks/qwen3.8-27b-4bit/apple-m4-pro) |
| M5 Max, 48 GiB, GPU 40 núcleos | Qwen3.8-27B 4-bit | MLX 0.32.1 / mlx-lm 0.31.3; sem draft | NR | 13,70 / 13,62 / 13,34 | Medianas em 840 / 3156 / 12263 tokens de entrada; carga de fundo não controlada. [Estudo](https://llm-speed.com/blog/qwen3-8-27b-m5-max-48gb) |
| M5 Pro, 48 GB | Qwen3.8-Flash-Next 4-bit; arquivo ~104 GB | Slotstream, MLX / Swift; especialistas no SSD | NR | ~12 | MTP ainda planejado no relato; contexto e repetições NR. [Autor](https://www.reddit.com/r/Qwen_AI/comments/1w3tjkw/running_the_104_gb_qwen38flashnext_on_a_48_gb_mac/) |
| M4 Pro, 64 GB | Qwen3.8-27B oQ4e / oQ8 | oMLX 0.6.1, MTP | NR | 20,8 / 16,6 | Contexto 8K; comparação de quantizações do mesmo master. [Discussão](https://github.com/jundot/omlx/discussions/2811) |
| M1 Max, 64 GB | Qwen3.6-35B-A3B 8-bit / Q8_0 | MLX / llama.cpp Metal; residente | ~190 / ~245 | 26,22 / 34 | Entrada ~1K; picos 42 / 44 GB; versões incompletas. [Executor](https://sleepyquant.rest/blog/mlx-vs-llama-cpp-35b-m1-max-benchmark/) |
| M2 Max, 64 GB | Qwen3.6-35B-A3B NVFP4 | Ollama / MLX; residente | NR | 71,3 / 69,3 / 67,8 | Prompts curto / médio / longo; thinking off; mediana de 3. [Experimento](https://github.com/robgil/local-ai-benchmark-mac-stuido-m2) |
| M5 Pro, 64 GB | Qwen3.8-Flash-Next V3; 95,5 GiB, quantização mista | Fork llama.cpp; SSD; draft ativo | ~367 | ~27,6 | Prompt ~4K. [Executor](https://www.reddit.com/r/LocalLLaMA/comments/1wk14il/qwen38flashnext_955_gib_on_a_64gb_mac_at_27_toks/) |
| M5 Pro, 64 GB | Mesmo Flash-Next V3 | Slipstream; SSD | NR | 35,0 / 37,5 | Tarefas Python / Rust, temperatura 0. [Comparação](https://www.reddit.com/r/LocalLLaMA/comments/1wva7l2/running_955_gib_qwen38flashnext_at_4152_toks_on_a/) |
| M5 Pro, 64 GB | DeepSeek-V4.1-Flash; container 299 GiB | WARP, caminho CPU; SSD interno | NR | 3,77 / 3,71 | Saídas 64 / 200 tokens; orçamento 46,45 GB. [Projeto](https://raw.githubusercontent.com/sqliteai/warp/main/README.md) |

O resultado WARP preenche a lacuna anterior de execução documentada do DeepSeek V4.1 Flash em Mac de 64 GB; não demonstra 20–30 tokens/s nesse modelo e hardware, nem estabelece o teto de outros runtimes. O modelo Bonsai continua excluído. Colibri permanece na comparação técnica anterior, sem transformar resultados de DeepSeek V4 em V4.1.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **GB** — gigabyte, unidade decimal de capacidade de dados; **GiB** — gibibyte, unidade binária de capacidade de dados; **TTFT** — tempo até o primeiro token.

<!-- acronym-note:end -->

### O que comprar ou reutilizar por capacidade

<!-- acronym-note:start -->

**Siglas e notações da tabela:** **IDE** — ambiente integrado de desenvolvimento; **SSD** — unidade de armazenamento de estado sólido; **GB** — gigabyte, unidade decimal de capacidade de dados; **MoE** — mistura de especialistas; ativa parte das redes de especialistas por token; **Q4** — família de quantização em 4 bits; sufixos identificam o formato específico; **Q8** — família de quantização em 8 bits; sufixos identificam o formato específico; **B / A…B** — B indica bilhões de parâmetros; A antes da contagem indica parâmetros ativos por token.

<!-- acronym-note:end -->

| Memória | Caminho prioritário | Precisão e folga | Critério de expansão |
|---|---|---|---|
| 32 GB | Reutilizar para 27B Q4 e 35B MoE Q4 em tarefas delimitadas | Medir IDE, navegador e containers; não presumir 27B ou 35B Q8 confortáveis | Expandir se pressão de memória ou tempo por tarefa prejudicarem o trabalho |
| 48 GB | Comparar 27B Q4/Q8 e 35B MoE Q4; Flash-Next SSD como alternativa experimental | Q8 do 35B requer qualificação de pico, contexto e ferramentas; Q8 do 27B não garante folga de prefill | Comprar após teste com carga real, não apenas tamanho dos pesos |
| 64 GB | Comparar 27B e 35B Q4/Q8; incluir Flash-Next SSD desde o piloto | Mais margem para ambiente de desenvolvimento; SSD não equivale a swap | DeepSeek V4.1 SSD em trilha de qualificação própria, sem meta de velocidade presumida |

No [ensaio de capacidade do Nav](https://github.com/navikt/mlx-workspace/blob/main/reports/48gb-question.md), um limite wired de 36 GB foi aplicado a uma máquina maior: isso não é benchmark de velocidade de um Mac físico de 48 GB. O texto registra loops e falhas de prefill apesar de pesos que cabiam. A consequência operacional é testar memória de trabalho e limitar chamadas repetidas no cliente.

O ensaio de 48 GiB do llm-speed publicou TTFT de 8,17 / 27,66 / 113,21 s nas três entradas da tabela, com thinking desligado. Seu pico de 27,17 tokens/s na menor entrada não substitui a mediana de 13,70. A carga concorrente explica por que o teste deve incluir o ambiente de trabalho, embora esse estudo não isole sua contribuição causal.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **TCO** — custo total de propriedade, incluindo aquisição e operação; **GPU** — unidade de processamento gráfico; **RAM** — memória de acesso aleatório; memória de trabalho; **VRAM** — memória de vídeo disponível ao processador gráfico; **SSD** — unidade de armazenamento de estado sólido; **GB** — gigabyte, unidade decimal de capacidade de dados; **PP** — processamento do prompt ou prefill; processa tokens de entrada; **US$** — dólares dos Estados Unidos.

<!-- acronym-note:end -->

### Da velocidade à economia de engenharia

Um relato de operação doméstica informa aproximadamente 60 tokens/s com GPU de 32 GB de VRAM, 64 GB de RAM e SSD. É evidência fornecida pelo responsável pela proposta, sem logs anexados, modelo de GPU, checkpoint, quantização, contexto ou separação de reasoning/output. Não corresponde a uma medição em Mac nem permite atribuir a mesma taxa a cada modelo citado. A reprodução deve registrar esses campos e comparar a mesma tarefa aceita nas estações menores.

PP processa o contexto; decode gera tokens. Sem eventos separados, a tabela não divide reasoning e resposta final. SSD de embeddings/Engram, streaming de especialistas e swap têm custos diferentes. Especulação, quantização e alteração do roteamento também precisam ser declaradas; tokens/s não demonstram qualidade de código.

O fluxo econômico proposto é: tarefas recorrentes locais → testes independentes → reparo limitado → nuvem autorizada quando necessário. O harness deve reduzir contexto desnecessário, escolher ferramentas adequadas e impedir loops; a nuvem pode aperfeiçoá-lo uma vez para muitas execuções locais. Comparar quatro braços: nuvem, local genérico, local com harness e local com harness + nuvem. Medir custo por tarefa aceita, fatura remota, revisão, latência e energia. Segurança mantém executor isolado, gateway autenticado e saída de rede controlada, inclusive nas máquinas menores.

O orçamento deve comparar reaproveitamento com compra gradual. A faixa de US$ 2500–5000 por estação é uma hipótese de planejamento, não cotação nem correspondência automática entre preço e RAM. Cinco estações representam US$ 12500–25000 somente em hardware; integração, segurança, operação e retrabalho continuam no TCO. Não multiplicar tokens locais pelo preço nominal de tokens remotos para declarar economia: medir a redução líquida da fatura, inclusive cache e escalonamentos.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **API** — interface de programação de aplicações; conecta componentes de software; **RAM** — memória de acesso aleatório; memória de trabalho; **SSD** — unidade de armazenamento de estado sólido; **US$** — dólares dos Estados Unidos.

<!-- acronym-note:end -->

## Required Investment — investimento necessário

O orçamento abaixo é **cenário de planejamento**, sem cotação vinculante. A faixa sugerida pelo usuário, US$ 2.500–5.000 por estação, precisa ser confirmada para RAM, chip, SSD, impostos e garantia específicos. O cenário central usa o teto dessa faixa, cinco estações e trabalho de implantação explicitamente contabilizado. Não presume que uma estação substitua um número ilimitado de agentes.

<!-- acronym-note:start -->

**Siglas e notações da tabela:** **US$** — dólares dos Estados Unidos.

<!-- acronym-note:end -->

| Componente do piloto | Premissa | Valor |
|---|---|---:|
| Cinco estações | 5 × US$ 5.000 | US$ 25.000 |
| Implantação e integração | 80 horas × US$ 100/h | US$ 8.000 |
| Validação de segurança e qualidade | 30 horas × US$ 100/h | US$ 3.000 |
| Contingência | 15% de US$ 36.000 | US$ 5.400 |
| **Investimento inicial planejado** | Hardware + trabalho + contingência | **US$ 41.400** |
| Operação local recorrente | Hipótese de US$ 100/estação/mês | **US$ 500/mês** |

As horas podem representar alocação interna, não desembolso adicional, mas têm custo de oportunidade. O custo recorrente é hipótese a validar e não deve duplicar trabalho já contabilizado. Licenças, administração adicional, treinamento especializado, SSD de reposição e adequações físicas entram no orçamento se necessários. A API remanescente é despesa operacional contínua; não está escondida no investimento inicial.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **API** — interface de programação de aplicações; conecta componentes de software; **TCO** — custo total de propriedade, incluindo aquisição e operação; **US$** — dólares dos Estados Unidos.

<!-- acronym-note:end -->

### Cenários de retorno com investimento completo

Assumem cinco usuários, redução efetiva de 50% da fatura, US$ 500/mês de operação e US$ 41.400 iniciais. Nenhum custo extra de retrabalho foi presumido; se surgir, deve ser subtraído. Os valores de US$ 2 mil–10 mil derivam do relato do usuário, não de média empresarial publicada.

<!-- acronym-note:start -->

**Siglas e notações da tabela:** **API** — interface de programação de aplicações; conecta componentes de software; **US$** — dólares dos Estados Unidos.

<!-- acronym-note:end -->

| API atual por pessoa/mês | API atual do time/mês | API + operação após migração | Economia mensal | Payback completo | Saldo em 12 meses após investimento |
|---:|---:|---:|---:|---:|---:|
| US$ 2.000 | US$ 10.000 | US$ 5.500 | US$ 4.500 | 9,20 meses | US$ 12.600 |
| US$ 5.000 | US$ 25.000 | US$ 13.000 | US$ 12.000 | 3,45 meses | US$ 102.600 |
| US$ 10.000 | US$ 50.000 | US$ 25.500 | US$ 24.500 | 1,69 mês | US$ 252.600 |

Com conta de US$ 2.000 por pessoa e apenas 20% de redução da fatura, a economia cai para US$ 1.500/mês e o retorno vai a 27,6 meses. Essa sensibilidade impede tratar economia alta como garantida. Para recuperar o cenário central em 12 meses, é preciso evitar pelo menos US$ 3.950/mês de API do time, antes de eventuais custos humanos extras — 39,5% da conta inicial de US$ 10.000.

Se o time já possui hardware suficiente, o investimento incremental pode ser muito menor. Se pretende compartilhar infraestrutura, é necessário medir throughput, fila e isolamento antes de reduzir a quantidade de máquinas na planilha. A comparação deve usar TCO com a mesma qualidade de entrega e o mesmo horizonte.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **US$** — dólares dos Estados Unidos.

<!-- acronym-note:end -->

### Decisão solicitada à gestão

Aprovar um piloto com teto planejado de US$ 41.400 de investimento inicial e responsáveis definidos, condicionado à confirmação das faturas, das configurações de hardware e dos critérios de aceitação. Essa aprovação é uma proposta contida no documento, não uma compra ou autorização presumida. Ao final de seis semanas, apresentar uma decisão de expandir, ajustar ou encerrar, sustentada por tarefas aceitas, segurança demonstrada e despesa evitada.
