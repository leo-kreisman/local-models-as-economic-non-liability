# Capacidade local de IA para engenharia

Proposta para decisão • Problem/Context + Solution + Required Investment • 16 de outubro de 2026

## Problem / Context — o problema e o contexto

A proposta é criar capacidade de inferência sob controle da empresa para reduzir o custo variável de programação assistida, conservar código e contexto sensível e aumentar a previsibilidade do ambiente. O objetivo inicial é substituir uma parcela verificável do consumo remoto de usuários intensivos, preservando acesso à nuvem para tarefas que justifiquem esse custo. O piloto proposto envolve cinco profissionais durante seis semanas, com tarefas de backend, UI, testes e manutenção de repositórios.

O relato recebido aponta profissionais com gastos de US$ 2 mil–10 mil. Para esta proposta, assume-se que a unidade seja **por profissional por mês**; confirmar a periodicidade e a fatura é parte da linha de base. Não se trata de média de mercado. Assinaturas, consumo API, valores estimados por monitores e faturas efetivas precisam ser separados. Cache, tamanho de contexto, repetição de ferramentas e agentes paralelos explicam por que preço por assento não descreve a despesa de um usuário intensivo.

O custo atual tem três componentes: inferência e serviços externos; tempo de engenharia para revisar e corrigir; e risco de dependência do fornecedor. Reduzir apenas a primeira parcela pode piorar o resultado se o modelo local exigir muito mais retrabalho. Por isso, a medida econômica do piloto será custo por tarefa aceita, acompanhada de tempo de ciclo e qualidade, além do gasto mensal. O [estudo Pegatron](https://arxiv.org/html/2607.13080v1), detalhado no relatório, ilustra esse cuidado: o TCO modelado melhora com infraestrutura compartilhada, mas piora sob alocação dedicada no mesmo caso.

A estabilidade também tem valor econômico. Há relatos de programadores de regressão do Opus 4.8 com exemplos e artefatos, como [#63861](https://github.com/anthropics/claude-code/issues/63861) e [#67606](https://github.com/anthropics/claude-code/issues/67606). Esses relatos merecem tratamento operacional mesmo quando a causa permanece incerta. A busca registrada encontrou 102 correspondências no GitHub, não 102 incidentes confirmados. O [acompanhamento Marginlab](https://marginlab.ai/blog/claude-code-degraded-before-opus-4-8/) mostra variação diária do produto em outro episódio, anterior ao lançamento do 4.8. A decisão não depende de provar degradação deliberada: poder conservar uma configuração aprovada e manter alternativas já reduz dependência.

Código enviado para inferência remota não se torna automaticamente propriedade do fornecedor. Há contratos empresariais que restringem treinamento, como a [política comercial Anthropic](https://privacy.claude.com/en/articles/9267385-does-anthropic-act-as-a-data-processor-or-controller). Ainda assim, a empresa precisa decidir onde contexto, logs, avaliações e feedback podem ser processados e retidos. A [reflexão de Satya Nadella](https://snscratchpad.com/posts/reverse-information-paradox/) reforça o valor estratégico desse conhecimento. Não foi demonstrada cessão de sistemas de IBM, HP ou Dell; o problema tratado aqui é a exposição e a dependência que podem ser administradas.

## Solution — solução proposta

A arquitetura proposta mantém um modelo local principal, o repositório, a busca de contexto e a execução de testes dentro do ambiente controlado. Tarefas elegíveis usam esse caminho por padrão. Um gateway aplica regras de dados e orçamento para enviar à nuvem somente o contexto necessário de tarefas autorizadas. Conteúdo que não pode sair permanece local; dificuldade do modelo não autoriza automaticamente exportação. Essa é uma combinação **local + nuvem**, não apenas roteamento entre duas APIs externas.

A escolha inicial deve comparar um 27B denso e um 35B MoE, em 4 e 8 bits, no harness utilizado pela equipe. A contagem total do MoE determina armazenamento, enquanto a parte ativa ajuda a explicar custo de computação; não são medidas intercambiáveis. Uma configuração de aproximadamente 64 GB é candidata prática para esses modelos, mas contexto, IDE, containers de testes e processos concorrentes precisam entrar na medição. Modelos maiores com offloading em SSD são uma trilha experimental posterior: o custo de I/O e a latência devem ser comparados ao ganho de qualidade.

A [model card Qwen3.8-27B](https://huggingface.co/Qwen/Qwen3.8-27B) mostra evolução mantendo 27B, e o [FigmaTrace](https://arxiv.org/html/2608.21460v1) mostra especialização do mesmo modelo com dados de GUI. São justificativas para avaliar modelos compactos, não garantias de equivalência universal. O [DeepSeek V4.1 Flash](https://arxiv.org/html/2609.19969v1) é uma arquitetura maior com cache mais eficiente; sua evolução não deve ser descrita como simples melhora de dataset com tamanho constante.

| Trabalho | Caminho inicial | Validação antes de aceitar |
|---|---|---|
| Backend e APIs | Modelo local para alterações delimitadas, SQL e integração | Testes unitários, contrato de API, análise de segurança e revisão do diff |
| QA | Geração local de casos, fixtures e testes; execução isolada | Compilação, execução repetida, cobertura útil e detecção de flakiness |
| UI | Modelo local com contexto visual quando suportado | Capturas, comparação visual, acessibilidade e testes Playwright |
| Código legado | Explicação e refatoração local por módulo | Testes de caracterização e preservação de comportamento |
| Arquitetura ou falha difícil | Revisão humana e, quando autorizado, escalonamento remoto | Comparação de solução, custo, dados enviados e tarefa efetivamente resolvida |

Há dois modos de disponibilizar essa capacidade. Máquinas individuais conservam isolamento e evitam fila compartilhada, mas podem ter baixa utilização. Um servidor interno com API facilita manutenção e rateio, mas exige planejamento de concorrência e controle de acesso entre projetos. Um cluster de Macs não deve ser comprado supondo soma linear de RAM ou tokens/s: divisão de um modelo entre nós, réplicas independentes e filas de tarefas têm custos diferentes. Os casos e benchmarks do relatório orientam os ensaios; não substituem um dimensionamento do time.

### Agentes e editor: conservar o fluxo, escolher o backend

O piloto incluirá Oh My Pi, OpenCode e Aider como alternativas configuráveis, além da possibilidade de conservar Claude Code, Codex CLI, Copilot CLI e VS Code com inferência local. Os caminhos estão documentados em [OMP Providers](https://github.com/can1357/oh-my-pi/blob/main/docs/providers.md), [OpenCode Providers](https://opencode.ai/docs/providers/), [Ollama para Claude Code](https://docs.ollama.com/integrations/claude-code), [OpenAI — CLI](https://learn.chatgpt.com/docs/developer-commands?surface=cli), [GitHub — Copilot BYOK](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/use-byok-models) e [VS Code — modelos](https://code.visualstudio.com/docs/agent-customization/language-models). A integração preserva a interface familiar e pode diminuir esforço de adoção; o benefício será medido, sem redução presumida do orçamento.

A escolha considerará a política efetiva de ferramentas e a contenção no sistema operacional. OMP e OpenCode oferecem controles granulares, mas seus padrões documentados são permissivos: `yolo` no primeiro e `allow` para a maioria das ferramentas no segundo. Fontes: [OMP Settings](https://github.com/can1357/oh-my-pi/blob/main/docs/settings.md) e [OpenCode Permissions](https://opencode.ai/docs/permissions/). A proposta é qualificar configurações restritas. Não há ranking independente de segurança entre esses produtos apresentado aqui. No Mac, o [sandbox de Bash do Claude Code](https://code.claude.com/docs/en/sandboxing) usa Seatbelt; VM Linux não é a única opção de isolamento.

O aceite deve confirmar o destino da inferência e dos serviços auxiliares, testar execução e arquivos proibidos e verificar que a configuração de um projeto não relaxe a política corporativa. O detalhamento de comandos, limites do modo offline e recursos do editor está no relatório. A verba de integração contempla essa qualificação de harnesses.

### Segurança de estações com acesso à internet

Os candidatos propostos são **OMP, OpenCode e Aider**, com MLX ou llama.cpp atrás de gateway local autenticado. Hermes e OpenClaw estão fora da implantação. Separar execução de código, inferência, consulta à internet e exportação para nuvem em componentes controlados independentemente. No Mac, o modelo pode usar a GPU do host enquanto as ferramentas do agente rodam em VM restrita; apenas a rota necessária ao gateway é exposta à VM.

Docker documenta [OpenCode em sandboxes locais](https://docs.docker.com/ai/sandboxes/agents/opencode/) com isolamento por microVM. Anthropic publica um [runtime de sandbox no SO](https://github.com/anthropics/sandbox-runtime) aplicável a processos arbitrários. São referências de implementação, não certificação do piloto. A [documentação do servidor MLX](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/SERVER.md) alerta explicitamente contra uso produtivo com suas verificações básicas; um listener de desenvolvimento não deve ser exposto como serviço empresarial completo.

O acesso à internet usará intermediário de consulta restrito. Negar uploads arbitrários e saída direta do executor, validar redirecionamentos e destinos DNS, bloquear endpoints privados/metadados e separar navegação de acesso a código sensível. Domínios permitidos sozinhos não impedem exfiltração. Exportação para nuvem exige decisão separada sobre dados; dificuldade ou falha de teste não autoriza enviar código proprietário. Credenciais ficam fora do contexto, e APIs compartilhadas exigem identidade e isolamento por projeto.

A aceitação inclui testes de vazamento de segredos sintéticos, instruções maliciosas em arquivos e páginas, leitura não autorizada, saída de rede em instalação de dependências, sobreposição de configuração, acesso a banco de produção e isolamento de sessão de navegador. Os [limites documentados pelo Docker](https://docs.docker.com/ai/sandboxes/security/isolation) incluem segredos não rastreados legíveis em clone mode e autoridade concedida por encaminhamento SSH; ambos exigem tratamento explícito. CI independente revisa patches, workflows e hooks. Timeouts e limites de tokens/gasto contêm loops e fallback descontrolado.

Canais laterais físicos são ameaça especializada secundária, documentada no apêndice da pesquisa. O investimento principal protege ativos cotidianos da estação contra roubo de credenciais, execução fora do workspace, exportação de dados, comprometimento da cadeia de suprimentos e persistência. A matriz completa de controles/testes está no [guia de engenharia](GUIA_ENGENHARIA_HIBRIDA.md).

### Roteamento por evidência e trabalho recorrente

O piloto priorizará edições mecânicas, propagação de DTO, expansão de regressões, alterações SQL delimitadas e manutenção UI. O Nav reporta custos pareados nuvem/híbrido de US$ 0,339/0,134 para mapper Ktor e US$ 0,227/0,121 para renomeação frontend, mas US$ 0,092/0,164 para Spring: delegar pode aumentar a fatura. O [estudo Nav](https://raw.githubusercontent.com/navikt/mlx-workspace/main/reports/local-inference-findings.md) apoia qualificar famílias de tarefas em vez de prometer uma taxa única de economia para todo código.

O [estudo HERA](https://arxiv.org/html/2504.00434v1), publicado em abril de 2025 com autores ligados à Microsoft, demonstra alocação local + nuvem, não implantação interna na Microsoft. O custo remoto HumanEval cai de US$ 0,056 para US$ 0,044, excluindo TCO local e com perda de qualidade. O destaque de 8% no README Arena conflita com as [notas revisadas](https://github.com/RunanywhereAI/hybrid-arena/blob/main/docs/release-notes/v1.4.1.md), que registram 10,3% dos tokens na nuvem. Nenhum equivale diretamente a percentual de economia na fatura.

### Construir harnesses reutilizáveis e amortizar seu custo

Usar um modelo de nuvem autorizado para propor dois harnesses iniciais a partir de exemplos públicos ou minimizados e aprovados. Congelar o modelo local e avaliar mudanças de instruções, recuperação, schemas de ferramentas e recuperação de erros contra testes independentes. O [SkillOpt](https://www.microsoft.com/en-us/research/blog/skillopt-agent-skills-as-trainable-parameters/) oferece evidência de otimização de uma camada externa de skills; seus benchmarks não voltados a código não estabelecem equivalência de código empresarial. Para QA repetitivo, [Gungnir](https://arxiv.org/html/2610.14161v1) demonstra caminho complementar: melhorar geradores reutilizáveis de testes e executá-los sem novas chamadas a LLM.

Medir quatro braços: fluxo atual de nuvem, harness local genérico, harness local especializado e local especializado + nuvem. Incluir codemods determinísticos quando apropriado. Contar tentativas, planejamento remoto, categorias de cache, revisão humana, operação e desenvolvimento de harness. A otimização pela nuvem nunca deve alterar testes ocultos de aceitação nem política empresarial de segurança. As horas existentes de integração e segurança permanecem provisórias; ampliar além de dois harnesses exige nova estimativa.

### Piloto de seis semanas e decisão de expansão

Na primeira semana, FinOps e engenharia consolidam faturas, categorias de tokens, cache, tarefas e tempo de revisão. A segunda semana instala o ambiente e testa seus controles. Nas semanas três a cinco, os mesmos tipos de tarefa são comparados entre fluxo atual e fluxo local + nuvem, com ordem alternada quando viável para reduzir efeito de aprendizagem. A última semana consolida qualidade, despesa efetivamente evitada e capacidade por estação ou servidor.

Um conjunto inicial de 100 tarefas reais, distribuídas entre backend, UI, QA e manutenção, é uma **proposta de avaliação**, não amostra que garanta significância estatística. Os limiares de aprovação devem ser definidos antes da execução. Como ponto inicial para negociação: economia total de pelo menos 30%, queda de no máximo 5 pontos percentuais na taxa de tarefas aceitas, nenhuma exposição não autorizada nos testes de segurança e aumento de até 10% no tempo de ciclo. Defeitos críticos exigem análise própria, sem compensação por uma média de custo favorável.

O time de plataforma responde pelo runtime e atualizações; segurança pelas políticas e testes; FinOps pela fatura e rateio; líderes de engenharia e QA pela aceitação dos resultados. A expansão depende dessas evidências. Não se propõe desligar a capacidade atual antes de qualificar o caminho local.

## Required Investment — investimento necessário

O orçamento abaixo é **cenário de planejamento**, sem cotação vinculante. A faixa sugerida pelo usuário, US$ 2.500–5.000 por estação, precisa ser confirmada para RAM, chip, SSD, impostos e garantia específicos. O cenário central usa o teto dessa faixa, cinco estações e trabalho de implantação explicitamente contabilizado. Não presume que uma estação substitua um número ilimitado de agentes.

| Componente do piloto | Premissa | Valor |
|---|---|---:|
| Cinco estações | 5 × US$ 5.000 | US$ 25.000 |
| Implantação e integração | 80 horas × US$ 100/h | US$ 8.000 |
| Validação de segurança e qualidade | 30 horas × US$ 100/h | US$ 3.000 |
| Contingência | 15% de US$ 36.000 | US$ 5.400 |
| **Investimento inicial planejado** | Hardware + trabalho + contingência | **US$ 41.400** |
| Operação local recorrente | Hipótese de US$ 100/estação/mês | **US$ 500/mês** |

As horas podem representar alocação interna, não desembolso adicional, mas têm custo de oportunidade. O custo recorrente é hipótese a validar e não deve duplicar trabalho já contabilizado. Licenças, administração adicional, treinamento especializado, SSD de reposição e adequações físicas entram no orçamento se necessários. A API remanescente é despesa operacional contínua; não está escondida no investimento inicial.

### Cenários de retorno com investimento completo

Assumem cinco usuários, redução efetiva de 50% da fatura, US$ 500/mês de operação e US$ 41.400 iniciais. Nenhum custo extra de retrabalho foi presumido; se surgir, deve ser subtraído. Os valores de US$ 2 mil–10 mil derivam do relato do usuário, não de média empresarial publicada.

| API atual por pessoa/mês | API atual do time/mês | API + operação após migração | Economia mensal | Payback completo | Saldo em 12 meses após investimento |
|---:|---:|---:|---:|---:|---:|
| US$ 2.000 | US$ 10.000 | US$ 5.500 | US$ 4.500 | 9,20 meses | US$ 12.600 |
| US$ 5.000 | US$ 25.000 | US$ 13.000 | US$ 12.000 | 3,45 meses | US$ 102.600 |
| US$ 10.000 | US$ 50.000 | US$ 25.500 | US$ 24.500 | 1,69 mês | US$ 252.600 |

Com conta de US$ 2.000 por pessoa e apenas 20% de redução da fatura, a economia cai para US$ 1.500/mês e o retorno vai a 27,6 meses. Essa sensibilidade impede tratar economia alta como garantida. Para recuperar o cenário central em 12 meses, é preciso evitar pelo menos US$ 3.950/mês de API do time, antes de eventuais custos humanos extras — 39,5% da conta inicial de US$ 10.000.

Se o time já possui hardware suficiente, o investimento incremental pode ser muito menor. Se pretende compartilhar infraestrutura, é necessário medir throughput, fila e isolamento antes de reduzir a quantidade de máquinas na planilha. A comparação deve usar TCO com a mesma qualidade de entrega e o mesmo horizonte.

### Decisão solicitada à gestão

Aprovar um piloto com teto planejado de US$ 41.400 de investimento inicial e responsáveis definidos, condicionado à confirmação das faturas, das configurações de hardware e dos critérios de aceitação. Essa aprovação é uma proposta contida no documento, não uma compra ou autorização presumida. Ao final de seis semanas, apresentar uma decisão de expandir, ajustar ou encerrar, sustentada por tarefas aceitas, segurança demonstrada e despesa evitada.
