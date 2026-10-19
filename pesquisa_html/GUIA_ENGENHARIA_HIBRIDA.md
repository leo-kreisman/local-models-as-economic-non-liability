## Modelo operacional de engenharia: execução local, nuvem seletiva e harnesses reutilizáveis

Atualização da pesquisa: 19 de outubro de 2026. O alvo econômico é o trabalho recorrente de engenharia com critérios executáveis de aceitação. Três caminhos devem ser comparados: automação determinística, modelo local e colaboração local + nuvem. Um modelo de nuvem também pode construir procedimentos reutilizáveis em uma etapa separada; esse investimento não precisa se repetir em cada tarefa. O texto separa resultados medidos, implementações de fornecedores e a arquitetura empresarial proposta. Nenhum teste de desempenho de modelos ou de invasão foi executado nesta atualização.

### Economia híbrida: as evidências mais diretamente aplicáveis à engenharia

| Evidência | Configuração e trabalho | Resultado publicado | Implicação para a decisão |
|---|---|---|---|
| Nav, experimento organizacional | Qwen3.6-35B misto 4/8-bit, MLX, M4 Max 48 GB; Sonnet 4.6 orquestrador; OpenCode | Alteração de mapper Ktor: US$ 0,339 nuvem versus US$ 0,134 híbrido; renomeação TypeScript: US$ 0,227 versus US$ 0,121 | Cerca de 60,5% e 46,7% menos custo remoto nesses experimentos pareados |
| Nav, controle negativo | Mesmo par de modelos e harness, repositório Spring | US$ 0,092 nuvem versus US$ 0,164 híbrido | Custo cerca de 78,3% maior; rotear pela classe de tarefa medida, não apenas pela linguagem |
| Hybrid Coding Arena | M4 Max 64 GB; modelos locais, quatro harnesses suportados e roteamento para nuvem | README: 24/24 aprovações, fração de nuvem de 8%, US$ 0,022/tarefa para Cline + Qwen em cascata | Conjunto pequeno de tarefas repetidas; existe inconsistência documentada na definição da fração de nuvem |
| HERA, abril de 2025 | Mistral 7B local via llama.cpp/RTX 4090 com GPT-4 remoto | HumanEval: US$ 0,056 para US$ 0,044/requisição; HotpotQA: US$ 0,054 para US$ 0,043 | Reduções calculadas de API de 21,4% e 20,4%; TCO local excluído |
| MinionS | Processamento local coordenado por modelo remoto | Custo remoto 5,7× menor, preservando 97,9% do desempenho de referência | Evidência de análise documental; não é benchmark de produtividade em código |

Fontes: [Relatório de medição Nav](https://raw.githubusercontent.com/navikt/mlx-workspace/main/reports/local-inference-findings.md), [README Arena](https://github.com/RunanywhereAI/hybrid-arena), [HERA tabelas 3–4](https://arxiv.org/html/2504.00434v1), [MinionS](https://arxiv.org/abs/2502.15964). São experimentos relatados pelos autores, não economias de toda uma empresa auditadas independentemente. O HERA inclui pesquisadores ligados à Microsoft; não comprova implantação produtiva na Microsoft. A perda de qualidade relatada e os preços históricos impedem tratar a economia como cotação atual.

**Correção do destaque de 8%.** As notas da versão v1.4.1 do Arena definem explicitamente fração de nuvem como tokens de nuvem divididos por todos os tokens e reportam **10,3%**, não 8%, para a célula de cascata destacada. Informam que versões anteriores usavam estimativas de chamadas que contavam duas vezes metachamadas locais. O README ainda anuncia 8%. Esta atualização preserva ambos como inconsistência da fonte, não medições intercambiáveis. Nenhum estabelece redução percentual equivalente na fatura. Quantização e identidade do modelo devem ser fixadas pelo artefato, não inferidas de rótulos descritivos inconsistentes. [Notas v1.4.1](https://github.com/RunanywhereAI/hybrid-arena/blob/main/docs/release-notes/v1.4.1.md).


O HERA também reporta a relação entre qualidade e uso local no HumanEval: Mistral + GPT-4 atinge 47,8% de precisão, 28,4% de uso de SLM e US$ 0,044/requisição; Llama + Claude atinge 44,2%, 36,6% e US$ 0,053. São comparações entre dois pares híbridos, não entre híbrido e respectivas referências somente nuvem. Mais uso local não estabelece sozinho maior qualidade ou menor custo. [HERA tabela 4](https://arxiv.org/html/2504.00434v1).

### Repositórios reais e casos de teste, em vez de prompts genéricos de chat

O Nav identifica `navikt/isoppfolgingstilfelle` (Ktor), `navikt/ia-tjenester-metrikker` (Spring) e `navikt/familie-tilbake-frontend` (React/Express). São repositórios públicos de uma organização real que atende ao sistema de proteção social. As verificações incluem compilação e testes dos repositórios; o frontend usa 61 arquivos de teste e 572 testes. A suíte de backend já apresentava falhas na referência, portanto “verificado” significa ausência de novas falhas, não correção universal. Sessões inteiramente locais aprovaram perguntas simples, comentários, renomeações e alterações de DTO em pequenas amostras; a criação de um novo arquivo de teste teve 0/3 aprovações. Esses resultados apoiam qualificação por tarefa, não substituição irrestrita de QA. [Estudo Nav e limitações](https://raw.githubusercontent.com/navikt/mlx-workspace/main/reports/local-inference-findings.md).

A suíte mais difícil D6 do Arena contém cache LRU/TTL, token bucket, ordenação topológica e um interpretador de templates: quatro tarefas com 80 testes, repetidas com três seeds. Os resultados publicados são 8/12 somente local, 9/12 cascata e 12/12 somente nuvem. O sucesso destacado em tarefas mais fáceis, portanto, não se transfere inalterado ao trabalho mais difícil. Notas de versão e README também divergem em algumas classificações de falhas e frações de nuvem; preservar execuções brutas e revisão escolhida na reprodução. [Especificação D6 e resultados](https://github.com/RunanywhereAI/hybrid-arena/blob/main/docs/release-notes/v1.5.0.md).

### Evidência industrial de especialização e automação reutilizável

| Organização ou estudo | Atividade concreta de engenharia | Evidência e limite |
|---|---|---|
| Google | Migração de identificadores internos do Google Ads e código relacionado | Alterações assistidas por modelo combinadas com validação e testes unitários; demonstra fluxo delimitado de migração, não economia com modelo pequeno local. [Google Research](https://research.google/blog/accelerating-code-migrations-with-ai/) |
| Meta, ACH | Gerar mutantes e testes de regressão que os detectem | Abordagem de engenharia em produção com verificações executáveis de detecção de defeitos; não estabelece modelo local na estação nem redução de custo de tokens. [Meta Engineering](https://engineering.fb.com/2025/02/05/security/revolutionizing-software-testing-llm-powered-bug-catchers-meta-ach/) |
| Tiger Data, pg-aiguide | Modelagem de schemas Postgres, documentação por versão e skills revisadas | Orientação de domínio open source. O artigo original descreve avaliação qualitativa, não benchmark controlado de modelo pequeno ou economia medida. [Tiger Data](https://www.tigerdata.com/blog/we-taught-ai-to-write-real-postgres-code-open-sourced-it), [repositório](https://github.com/timescale/pg-aiguide) |
| NUS, Gungnir | Evoluir geradores reutilizáveis de testes SQL para SQLite, DuckDB e PostgreSQL | 44 bugs confirmados pelos desenvolvedores, 34 corrigidos; execução separada com DuckDB relata cinco bugs confirmados por US$ 20,85. Após a evolução, a geração roda sem chamadas a LLM. Pesquisa sobre motores reais de banco, não implantação comprovada de LLM local. [Artigo](https://arxiv.org/html/2610.14161v1) |

Gungnir é particularmente relevante ao QA recorrente: gastar inferência para melhorar o gerador, validar a mudança e reutilizar o programa. É um mecanismo complementar de economia, não benchmark de LLMs local + nuvem. Um modelo local pode depois auxiliar a triagem, mas essa extensão é proposta aqui, não medida no artigo.

### Desenvolvimento de harness com apoio da nuvem e execução local posterior

Um harness inclui instruções, recuperação de contexto, ferramentas, estado, limites de tentativas e verificadores. Otimizar um arquivo de skill altera apenas um componente; modificar pesos é outra intervenção. Um modelo forte de nuvem pode propor um harness usando exemplos públicos ou contexto minimizado e autorizado. O artefato resultante pode ser revisado, versionado e executado repetidamente com pesos locais.

O **SkillOpt**, da Microsoft, usa um modelo otimizador para revisar skills de um modelo-alvo congelado, com alterações limitadas e validação separada. Sua avaliação inclui Qwen3.5-4B, seis benchmarks não voltados a código e 52 células de avaliação. Isso apoia o mecanismo de melhoria procedimental externa, não uma alegação de equivalência de código com modelo de fronteira. O **GEPA** reporta otimização de prompts com até 35× menos rollouts que sua comparação GRPO; isso não significa redução de 35× na fatura total de nuvem. [SkillOpt](https://www.microsoft.com/en-us/research/blog/skillopt-agent-skills-as-trainable-parameters/), [GEPA, ICLR 2026](https://proceedings.iclr.cc/paper_files/paper/2026/hash/0e9e708b6f48e14fd0ac29e167413f76-Abstract-Conference.html).

A Microsoft também relata um agente interno de verificação formal Rust que melhorou mais de dez pontos por ajuste de prompts a menos de US$ 6 por tarefa. A apresentação não fornece implantação completa em estação local nem balanço de economia empresarial. O Agent Lightning suporta infraestrutura separada de otimização sem exigir reescrita integral do agente. [Apresentação Microsoft](https://www.microsoft.com/en-us/research/video/agent-lightning-one-learning-system-that-makes-all-agents-evolve/), [repositório Agent Lightning](https://github.com/microsoft/agent-lightning).

**Ciclo proposto:** selecionar uma família recorrente de tarefas; reunir casos de treinamento sem dados identificáveis e um conjunto de avaliação intocado; estabelecer a referência atual somente nuvem; solicitar à nuvem instruções concisas, schemas de ferramentas e recuperação limitada; executar candidatos localmente; promover somente os que melhorarem custo por tarefa aceita sem violar limites de qualidade ou segurança; manter rollback e reavaliar mudanças de comportamento periodicamente. O otimizador não pode editar seus próprios testes de aceitação nem a política de segurança. Testes ocultos e revisão humana final permanecem fora do workspace gravável do agente.

| Harness reutilizável | Trabalho local | Critério independente de aceitação | Condição para escalonamento |
|---|---|---|---|
| Propagação DTO/API | Aplicar campo especificado em tipos, mappers e pontos de chamada | Build, compatibilidade de schema e testes de contrato | Regra de negócio ambígua ou contrato incompatível |
| Refatoração mecânica | Renomear ou aplicar transformação aprovada | Verificações AST/símbolos, compilação e regressão | Semânticas conflitantes; usar codemod determinístico quando suficiente |
| Expansão de regressão | Adicionar casos a partir de padrões existentes e fixtures sintéticas | Execução, detecção de mutantes e verificação de instabilidade | Ausência de asserção útil ou falha após reparo limitado |
| Migração Postgres | Gerar migração delimitada com orientação da versão fixada | Banco descartável, invariantes, rollback, locks e planos | Operação destrutiva ou regressão inexplicada de plano |
| Manutenção UI | Atualizar componente conhecido e seus testes | Acessibilidade, interação, capturas e E2E | Nova decisão de design ou divergência visual inexplicada |
| Triagem CI/documentação | Classificar falhas sanitizadas e redigir referências | Links para evidência real de código/log; aceitação humana | Evidência ausente, dados sensíveis ou diagnóstico incerto |

São candidatos ao piloto, não uma afirmação medida de que a maior parte do trabalho da organização já está coberta. Medir sua frequência em tickets e pull requests concluídos. Começar por operações repetitivas e delimitadas; preservar responsabilidade humana por requisitos, arquitetura e aprovação de produção.

### Estações com internet e segurança: arquitetura prática

O processo de inferência não precisa de internet irrestrita apenas porque o agente precisa consultar documentação. Separar serviço de inferência local, executor de código, intermediário de consulta e gateway de nuvem. Uma página maliciosa pode influenciar a saída do modelo; a implantação ainda deve impedir que essa saída adquira capacidades não autorizadas.

```text
Estação gerenciada
  worktree revisado -> executor isolado do agente (OpenCode / OMP / Aider)
                        |-> gateway autenticado de inferência local -> MLX ou llama.cpp
                        |-> executor descartável de testes e banco sintético
                        |-> intermediário de consulta -> documentação pública aprovada
                        |-> controle de exportação -> inferência autorizada na nuvem
  verificador independente <- patch proposto e evidências de teste
  credenciais, política de rede e auditoria fora do controle do agente
```

Em Apple Silicon, MLX pode permanecer no host para usar a GPU enquanto as ferramentas do agente rodam em VM separada. A VM recebe acesso somente ao gateway de inferência e intermediários aprovados, não acesso irrestrito aos serviços do host. Um listener do host restrito a loopback não fica automaticamente acessível à VM; configurar deliberadamente uma ponte ou proxy autenticado e de roteamento restrito. Em Linux, executor dedicado sem privilégios, sandbox/container ou VM podem separar agente e inferência; um container que compartilha kernel com o host tem limite diferente de uma VM. Não é necessário passthrough de GPU apenas para executar ferramentas de build no executor.

**Implementações industriais demonstram viabilidade, não imunidade.** Docker documenta OpenCode em sandboxes locais com microVM e conectividade controlada por políticas. Anthropic relata redução de 84% dos pedidos de permissão no uso interno de sandbox e publica um runtime para restringir filesystem/rede de processos arbitrários. O percentual mede pedidos, não prevenção de ataques. Esses mecanismos podem apoiar uma arquitetura de modelos locais sem adotar Hermes ou OpenClaw. [Integração Docker OpenCode](https://docs.docker.com/ai/sandboxes/agents/opencode/), [implementação Anthropic](https://www.anthropic.com/engineering/claude-code-sandboxing), [sandbox-runtime](https://github.com/anthropics/sandbox-runtime).

### Desenho dos controles e testes de aceitação

A tabela é uma referência empresarial proposta. Cada controle deve ser verificado na versão exata de sistema operacional, runtime, agente e política. Os testes usam segredos sintéticos e fixtures isoladas, nunca credenciais reais de produção.

| Superfície | Controle necessário | Teste de aceitação e evidência |
|---|---|---|
| Acesso à web pública | Intermediário separado; domínios e caminhos aprovados; validar redirecionamentos, DNS e endereços privados | Consulta permitida funciona; redirecionamentos para host proibido e endpoints privados/metadados falham |
| Exfiltração | Negar saída direta do executor; proibir consultas arbitrárias, uploads e APIs de escrita; inspecionar requisições permitidas | Marcador sintético não sai por URL, corpo, DNS ou subprocesso; registrar decisões do gateway |
| Confidencialidade do código | Não dar ao executor de navegação acesso a repositório sensível; transferir apenas trechos aprovados | A mesma página maliciosa não obtém segredos nem código fora do escopo atribuído |
| Credenciais | Escopos temporários intermediados; nenhuma credencial no prompt, ambiente, repositório ou encaminhamento SSH amplo | Executor não lê a chave nem usa o intermediário para agir em outro projeto |
| Workspace | Worktree descartável; mounts mínimos; sem diretório pessoal, socket Docker do host ou volumes de produção | Acesso por symlink, travessia de caminhos e subprocessos fora do worktree falha |
| Prompt injection | Tratar páginas, issues, logs e instruções de repositório como dados não confiáveis; permissões fora dos prompts | Instruções para exportar dados ou alterar política falham mesmo quando o modelo tenta obedecer |
| Dependências e ferramentas | Registries aprovados, artefatos fixados, scripts de instalação revisados e mirrors internos | Download não aprovado e saída de rede durante instalação são bloqueados |
| API do runtime | Binding local ou gateway privado; autenticação, limites e isolamento por projeto | Inferência sem autenticação negada; outro projeto não recupera logs, contextos ou cache |
| Configuração do agente | Política corporativa fora da escrita do repositório; revisar plugins, MCP e configuração antes da execução | Abrir repositório não reduz silenciosamente a política efetiva nem inicia comandos no host |
| Testes UI | Perfil dedicado de navegador, conta sintética e destinos restritos | Navegador não tem cookies corporativos nem alcança aplicações internas não relacionadas |
| Banco/backend | Banco efêmero e papel de teste restrito; produção inacessível | Migração executa em fixtures, mas não conecta à produção nem altera schemas externos |
| Saída e persistência | CI independente, testes protegidos, revisão de workflows/hooks/config além do código | Agente não esconde falha alterando testes nem persiste hook executável no host |
| Disponibilidade e custo | Timeouts, limites de tokens/passos, filas de concorrência e teto de nuvem | Loop termina, servidor travado é isolado e fallback não excede orçamento autorizado |
| Auditoria e atualizações | Logs mínimos, retenção/acesso definidos, releases assinadas/fixadas e rollback | Eventos rastreáveis sem segredos brutos; rollback restaura configuração conhecida |

Allowlist de domínio sozinha não impede vazamento para um serviço permitido, incluindo host Git ou modelo de nuvem. Acesso somente para consulta e exportação autorizada de dados são permissões distintas. DLP e classificação por modelo são complementares; não reconhecem com confiabilidade toda lógica proprietária. Projetos restritos não devem ter rota de exportação para nuvem. A internet continua útil, mas o componente de navegação não deve herdar todas as permissões do componente de código.

A documentação Docker observa explicitamente que clone mode ainda pode expor arquivos `.env` não rastreados e que encaminhamento SSH concede autoridade utilizável mesmo mantendo chaves fora da VM. Um processo MCP local também pode executar com privilégios do host, fora do isolamento. São obrigações de configuração, não motivos para abandonar contenção. [Camadas de isolamento Docker](https://docs.docker.com/ai/sandboxes/security/isolation), [limites de segurança Docker](https://docs.docker.com/ai/sandboxes/security/).

### Decisões de implementação por runtime e agente

| Componente | Capacidade ou limitação verificada | Consequência para implantação |
|---|---|---|
| MLX-LM | Documentação oficial alerta que verificações básicas do servidor são insuficientes para produção | Manter inferência atrás de gateway qualificado; não expor servidor de desenvolvimento como limite de segurança empresarial. [Servidor MLX](https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/SERVER.md) |
| llama.cpp | Configuração de chave API e TLS existe; autenticação padrão é nenhuma | Configurar identidade e limites explicitamente; autenticação do serviço não restringe ferramentas do agente. [Documentação do servidor](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md) |
| OpenCode | Regras `allow`, `ask`, `deny` por ferramenta/agente; padrões permissivos | Qualificar política efetiva e sandbox externo; não liberar shell ou gerenciadores de pacotes amplamente só para reduzir perguntas. [Permissões](https://opencode.ai/docs/permissions/) |
| Oh My Pi | Padrão `yolo`; políticas de aprovação; regras Bash não são contenção e não cobrem automaticamente `eval` | Selecionar modo restritivo, limitar todo caminho de execução e impor limites independentes de SO/rede. [Configuração](https://github.com/can1357/oh-my-pi/blob/main/docs/settings.md) |
| Aider | Provedores compatíveis com execução local e feedback de lint/testes | Worktree restrito e sandbox externo; comandos de lint/teste também executam código do projeto. [Provedores](https://aider.chat/docs/llms/other.html), [Testes](https://aider.chat/docs/usage/lint-test.html) |

Não existe ranking universal de segurança demonstrado que coloque um desses agentes acima de todos os demais. OMP, OpenCode e Aider são os candidatos propostos à qualificação. Hermes e OpenClaw estão fora da implantação proposta. Canais laterais físicos permanecem como apêndice especializado; os controles principais de estação tratam execução de código, roubo de credenciais, exportação de rede, cadeia de suprimentos e persistência.

### Medir economia sem confundir tokens, requisições e dinheiro

Registrar tokens locais e remotos de entrada/saída, leituras/escritas de cache, tentativas, decisões de roteamento, ferramentas, latência e aceitação. A fatura remota precisa usar as categorias reais de cobrança; totais brutos de tokens enganam quando cache domina. Reportar custo por tentativa e por tarefa aceita, contando falhas e reparos. Incluir revisão e espera humana, hardware amortizado, energia, operação e desenvolvimento de harness.

Para uma família de tarefas, B é custo somente nuvem por tarefa aceita, L custo de operação local, q fração que exige fallback, F custo remoto adicional médio desse fallback, H manutenção de harness por tarefa e R revisão/retrabalho incremental. A proposta é favorável quando **L + q × F + H + R < B**, com qualidade e latência aceitáveis. Fração de tokens em nuvem não substitui q. Em fluxo híbrido continuamente orquestrado, contabilizar todas as chamadas de planejamento e coordenação, em vez de usar equação apenas de fallback.

Premissas ilustrativas, não medições de mercado: B = US$ 0,50, L = US$ 0,04, q = 0,20, F = US$ 0,60, H = US$ 0,03, R = US$ 0,06 resultam em US$ 0,25/tarefa, redução de 50%. Acrescentar US$ 0,30 de revisão incremental leva a US$ 0,55 e elimina a vantagem econômica. Se construir e validar um harness custar US$ 300 e economizar US$ 0,25 por tarefa aceita posterior, após custos recorrentes, o equilíbrio ocorre em 1.200 tarefas. Contabilizar esse investimento inicial uma vez; não amortizá-lo também em H no mesmo cálculo.

### Piloto com repositórios relevantes ao negócio e critérios mensuráveis

Selecionar tarefas concluídas e revisáveis do histórico de repositórios da empresa, com autorização de uso e dados sintéticos. Incluir backend, interface React/TypeScript e aplicação com PostgreSQL; acrescentar suíte de fixtures de motor de banco quando pertinente. Os repositórios públicos Nav e tarefas Arena são referências de reprodutibilidade, não substitutos da distribuição de trabalho da empresa.

Comparar quatro braços nas mesmas tarefas fixadas: fluxo atual de nuvem; local com harness genérico; local com harness especializado; local especializado + nuvem. Acrescentar referência determinística para transformações mecânicas. Preservar testes independentes de aceitação, orçamento fixo de tentativas, condições de cache frio/quente e todas as falhas. Separar famílias inteiras ou módulos para testar generalização; nunca ajustar no conjunto final de avaliação. Repetir tarefas suficientes para mostrar incerteza e reportar backend, UI e QA separadamente, em vez de um agregado enganoso.

O piloto de seis semanas permanece como estrutura de investimento, mas qualificação de segurança e desenvolvimento de harness precisam de tempo de engenharia alocado. As 80 horas de integração e 30 de segurança/validação existentes são alocações provisórias, não prova de que todos os controles e famílias cabem. Começar com dois harnesses especializados e a superfície mínima de ferramentas; revisar orçamento antes de ampliar. Nenhuma economia mensal de time deve ser atribuída a benchmark publicado por tarefa sem medir volume, utilização e custos totais.

Complemento de implementação: [Dois harnesses especializados](HARNESSES_POR_TAREFA.md).
