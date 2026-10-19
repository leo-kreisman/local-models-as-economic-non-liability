## Regressões percebidas, relatos públicos e estabilidade operacional

A experiência dos programadores é evidência relevante para uma decisão de compra. Não depende de reconhecimento do fornecedor para ser registrada. Nesta revisão, a pergunta foi dividida em três: que problemas foram relatados; que mudanças foram medidas; e o que se sabe sobre sua causa. A ausência de comprovação de intenção não apaga relatos de perda de qualidade ou custo de retrabalho.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **API** — interface de programação de aplicações; conecta componentes de software; **JSON** — JavaScript Object Notation; formato de dados estruturados.

<!-- acronym-note:end -->

### Volume observável: amostra rastreável, não estimativa de toda a internet

Em 16/10/2026, a API pública do GitHub retornou **102 issues** para a consulta `repo:anthropics/claude-code is:issue "4.8" "degradation"`. As duas páginas foram coletadas; a lista está em [dados/github-search.json](dados/github-search.json). São correspondências de busca em título/corpo/comentários, incluindo possíveis duplicatas e referências indiretas. **Não são 102 incidentes confirmados, nem 102 pessoas, nem uma medida da proporção de usuários insatisfeitos.** A busca não constitui censo de Reddit, X ou LinkedIn.

<!-- acronym-note:start -->

**Siglas e notações da tabela:** **JSONL** — JSON Lines; um registro JSON por linha.

<!-- acronym-note:end -->

| Registro primário | Conteúdo documentado | Sinal quantitativo disponível |
|---|---|---|
| [GitHub #63861, 30/05/2026](https://github.com/anthropics/claude-code/issues/63861) | Declarações de verificação sem executar o build; comentários descrevem problemas em outros projetos e comparação com 4.7 | 9 comentários; 6 reações positivas à issue |
| [GitHub #67606, 11/06/2026](https://github.com/anthropics/claude-code/issues/67606) | Autor relata mensagens de usuário inventadas e fatos de ferramentas incorretos, com verificação de JSONL | 16 comentários; 4 reações positivas |
| [GitHub #69398, 18/06/2026](https://github.com/anthropics/claude-code/issues/69398) | Relato de falhas de instrução e raciocínio em Code e Cowork, em sessões distintas | 3 comentários; nenhuma reação registrada; encerrada como duplicata |
| [Reddit: erros e lentidão, 24/06/2026](https://www.reddit.com/r/Anthropic/comments/1ueevsb/degraded_performance_elevated_error_rate_on/) | Discussão de indisponibilidade, latência e suspeita de mudança antes de lançamento | Resultado indexado exibia +27 votos; não é contagem de relatos independentes |
| [Reddit: “Opus 4.8 is really bad”](https://www.reddit.com/r/Claudeopus/comments/1ugdo34/opus_48_is_really_bad_did_they_downgrade_the/) | Insatisfação com código, acompanhada de respostas de usuários que mantêm boa experiência | Contagem não obtida de modo confiável |
| [Reddit: workflows dinâmicos](https://www.reddit.com/r/ClaudeCode/comments/1tt8mxx/why_48_feels_broken_if_youre_not_running_dynamic/) | Discussão sobre modelo, orquestração e adaptação do fluxo | Contagem não obtida de modo confiável |
| [Juan J. Ramirez, LinkedIn](https://www.linkedin.com/posts/juanjramirez_opus-48-is-the-first-time-i-can-confidently-activity-7466552263008837632-hPeb) | Relato profissional recomendando retorno ao 4.6 | Testemunho, não experimento publicado |
| [Aryan Kathawale, LinkedIn](https://www.linkedin.com/posts/kiritocode1_man-claude-opus-48-is-a-major-degradation-activity-7468209923391377409-jiFi) | Dificuldades com edições e estrutura de arquivos | Testemunho, não experimento publicado |

Metadados das três issues foram preservados em JSON. Os 28 comentários somados incluem discussão e possíveis participantes repetidos. Não equivalem a 28 desenvolvedores afetados. A API Reddit retornou 403; não foram inventadas contagens para preencher a lacuna. A amostra também contém opiniões favoráveis, evitando apresentar unanimidade que as fontes não mostram.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **CLI** — interface de linha de comando; **SWE** — engenharia de software; família de benchmarks de tarefas de software; **HTML** — HyperText Markup Language; formato de documentos web.

<!-- acronym-note:end -->

### Medição externa e reconhecimento de regressões anteriores

A [Marginlab, 29/05/2026](https://marginlab.ai/blog/claude-code-degraded-before-opus-4-8/), acompanhou Claude Code diariamente em um subconjunto de SWE-bench Pro. Publicou cinco dias abaixo do baseline de 65%, seguidos de recuperação. A tabela original foi capturada para inspeção visual:

<!-- acronym-note:start -->

**Siglas e notações da tabela:** **CLI** — interface de linha de comando.

<!-- acronym-note:end -->

| Data de maio/2026 | CLI | Pass rate publicado |
|---|---|---:|
| 21 | 2.1.148 | 64% |
| 22 | 2.1.150 | 50% |
| 23 | 2.1.150 | 54% |
| 24 | 2.1.150 | 50% |
| 25 | 2.1.150 | 50% |
| 26 | 2.1.152 | 52% |
| 27 | 2.1.153 | 66% |
| 28 | 2.1.156 | 72% |

A média aritmética dos cinco dias de queda é **51,2%**, 13,8 pontos abaixo do baseline. O modelo anterior era **Opus 4.7**, e a recuperação coincide com troca de versão do CLI e chegada do 4.8. Os autores suspeitam do harness. O episódio demonstra variação operacional; não deve ser rebatizado como medição de degradação posterior do Opus 4.8.

![Tabela original da Marginlab: datas, versões e taxas de aprovação](assets/marginlab-tabela.webp)

Fonte da imagem: [Marginlab](https://marginlab.ai/blog/claude-code-degraded-before-opus-4-8/), captura da tabela HTML original, 16/10/2026.

A [Anthropic reconheceu em 23/04/2026](https://www.anthropic.com/engineering/april-23-postmortem) três alterações que prejudicaram o produto: redução do esforço padrão, descarte indevido de raciocínio anterior e uma instrução de concisão. O episódio afetou 4.6/4.7 e antecede 4.8. Mostra que feedback externo pode revelar regressões que os testes internos não captaram inicialmente. Não é necessário aceitar a narrativa da empresa como explicação universal; também não é correto afirmar que fornecedores nunca reconhecem regressões.

**Consequência para gestão:** avaliar a estabilidade do conjunto modelo + harness + configuração + serving, manter testes sentinela e uma rota alternativa. Pesos e versões locais sob controle permitem congelar uma configuração aprovada. Continuam necessários testes ao trocar quantização, template, runtime ou instruções. A hipótese específica de redução deliberada para liberar datacenters segue sem demonstração causal nesta amostra.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **IDE** — ambiente integrado de desenvolvimento.

<!-- acronym-note:end -->

## Segurança de modelos locais: controles executáveis e limites reais

Modelos open-weight podem integrar uma arquitetura empresarial controlada. Pesos acessíveis não são uma barreira a identidade, isolamento, auditoria ou controle de rede. A segurança decorre do sistema inteiro: arquivos, runtime, IDE, agentes, credenciais, ferramentas, atualizações, infraestrutura e pessoas. O objetivo é impedir ações e fluxos de dados não autorizados, mesmo quando o modelo produz uma instrução inadequada.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **API** — interface de programação de aplicações; conecta componentes de software; **MLX** — framework de aprendizado de máquina da Apple; nome de runtime, não de quantização; **VM** — máquina virtual.

<!-- acronym-note:end -->

### O que Google e NVIDIA efetivamente documentam

O [Google descreve o Private Compute Core](https://security.googleblog.com/2022/12/trust-in-transparency-private-compute.html) como ambiente isolado, com limites de comunicação entre processos e mecanismos publicamente inspecionáveis. Na [documentação Gemini Nano/AICore](https://developer.android.com/ai/gemini-nano), o serviço não tem acesso direto à internet; downloads passam por Private Compute Services, pedidos são isolados e inputs/outputs não são retidos após processamento. É evidência concreta de proteção de inferência no dispositivo. Não comprova que Google execute Qwen de código em notebooks de seus engenheiros, nem que todo aplicativo cliente herde automaticamente essas garantias.

A [NVIDIA documenta OpenShell](https://docs.nvidia.com/openshell/latest/security/best-practices) com controles separados para rede, filesystem, processos e inferência. Há políticas de egress, Landlock, seccomp, redução de privilégios e autenticação de gateways. São mecanismos de contenção fora do prompt. O [tutorial de NemoClaw com inferência local](https://developer.nvidia.com/blog/build-a-secure-always-on-local-ai-agent-with-nvidia-nemoclaw-and-openclaw/) mostra um caminho operacional, mas integrações como Telegram continuam enviando mensagens a serviços externos. **“Inferência local” não transforma uma integração remota em comunicação local.**

**Limite de plataforma:** Landlock e seccomp são mecanismos de Linux. No Mac, a implantação deve definir uma fronteira equivalente — por exemplo, executar ferramentas do agente em uma VM Linux isolada e expor somente a API autenticada do serviço MLX no host. Isso exige controlar também a rede, os volumes e as credenciais da VM; não torna os controles Linux nativos do macOS. É uma proposta de arquitetura, a validar no piloto.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **UI** — interface do usuário; **IDE** — ambiente integrado de desenvolvimento; **MCP** — Model Context Protocol; conecta agentes a ferramentas e dados; **FAQ** — perguntas frequentes.

<!-- acronym-note:end -->

### Matriz de proteção para código, testes, backend e UI

As medidas abaixo são uma proposta de engenharia baseada nas fontes citadas, a ser validada no ambiente da empresa. “Gerenciável” significa controles disponíveis e responsabilidades definidas; não imunidade a toda vulnerabilidade.

<!-- acronym-note:start -->

**Siglas e notações da tabela:** **LLM** — modelo de linguagem de grande porte; **API** — interface de programação de aplicações; conecta componentes de software; **IDE** — ambiente integrado de desenvolvimento; **VM** — máquina virtual; **TLS** — Transport Layer Security; protege dados em trânsito; **RBAC** — controle de acesso baseado em papéis; **ACL** — lista de controle de acesso.

<!-- acronym-note:end -->

| Risco | Controle recomendado | Como demonstrar que funciona | Risco residual |
|---|---|---|---|
| Prompts enviados a terceiros | Bloquear saída de rede por padrão; endpoint local; allowlist explícita de destinos | Captura de tráfego no host/gateway durante tarefas reais; teste com destino proibido | IDE, plugin ou processo fora da política pode enviar dados |
| API local exposta | Bind em loopback; para times, gateway TLS + identidade + RBAC + limites | Verificar portas e provar rejeição de chamadas sem credencial | Um usuário autorizado ainda pode abusar do acesso concedido |
| Prompt injection em repositório/documento | Separar conteúdo de instruções; restringir tools; sandbox; aprovação externa para ações privilegiadas | Repositório de teste com instruções maliciosas; tentativa de exfiltração bloqueada | Detecção por outro LLM não é garantia absoluta |
| Credenciais disponíveis ao agente | Cofre e credenciais temporárias; injeção pelo proxy; nunca montar secrets de produção | Inspecionar ambiente, mounts e logs; tentar ler um secret de teste | Permissões excessivas no proxy podem permitir uso indevido |
| Execução de código e testes | Conta sem privilégios, container/VM descartável, mounts mínimos, sem socket Docker privilegiado | Testar escape de escopo, escrita fora da pasta e acesso à rede | Vulnerabilidades de kernel/runtime exigem patches |
| Pesos, pacotes ou plugins comprometidos | Origem aprovada, hashes, versões fixadas, inventário e validação de formatos | Conferência de hash, scanner e instalação em ambiente isolado | Hash prova integridade em relação à referência, não ausência de comportamento malicioso |
| Logs, índices e backups | ACL por projeto, criptografia, retenção mínima, embeddings locais e backups gerenciados | Verificar acesso cruzado e descarte; testar restauração | Dados em uso permanecem acessíveis a processos privilegiados |
| Mudanças silenciosas | Fixar modelo, quantização, template e runtime; rollout com canário e rollback | Bateria de tarefas sentinela antes/depois | Driver e sistema operacional também afetam execução |
| Canais laterais por software | Host dedicado para conteúdo mais sensível; impedir processos/co-tenants não confiáveis; isolamento de memória/cache compatível | Revisão do modelo de ameaça e testes especializados | Containers compartilham kernel e não eliminam todo canal lateral |
| Sondas físicas, acessórios e furto | Sala/rack controlado, inventário de docks/carregadores, proteção do equipamento e disco | Auditoria física; laboratório especializado quando necessário | Criptografia do disco não blinda emissões durante inferência |

A [Brave](https://brave.com/blog/indirect-prompt-injection/) demonstrou prompt injection em produtos locais e remotos e propõe defesa em profundidade, menor privilégio e controle do fluxo de informação. O ponto relevante é conter consequências no sistema, em vez de confiar exclusivamente em alinhamento ou em uma instrução “não vaze dados”.

Em ferramentas já disponíveis, [LM Studio documenta operação offline](https://lmstudio.ai/docs/app/offline) e [autenticação ao servir na rede](https://lmstudio.ai/docs/developer/core/server/serve-on-network). A [FAQ oficial Ollama](https://github.com/ollama/ollama/blob/main/docs/faq.mdx) documenta `OLLAMA_NO_CLOUD=1`. Esses controles não substituem a verificação da IDE, MCP, logs e tráfego. No workspace desta pesquisa há scripts configurados para **Ollama Cloud**; eles não são, por si, a implantação local proposta neste documento.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **URL** — localizador uniforme de recursos; endereço de um recurso; **PII** — informações de identificação pessoal; **B / A…B** — B indica bilhões de parâmetros; A antes da contagem indica parâmetros ativos por token.

<!-- acronym-note:end -->

### Leitura crítica da primeira transcrição fornecida

Não foi fornecido URL ou título identificável do vídeo; os tempos abaixo se referem à transcrição enviada. As publicações subjacentes foram buscadas separadamente.

<!-- acronym-note:start -->

**Siglas e notações da tabela:** **API** — interface de programação de aplicações; conecta componentes de software; **PII** — informações de identificação pessoal; **AAAI** — associação para o avanço da inteligência artificial.

<!-- acronym-note:end -->

| Trecho | Verificação e correção | Fonte |
|---|---|---|
| 0:00–0:18: execução local conserva prompts e respostas | Válido quando o fluxo inteiro permanece local; ferramentas, telemetria e sincronização precisam ser incluídas no escopo | [LM Studio offline](https://lmstudio.ai/docs/app/offline) |
| 0:25–0:39: guia SitePoint de fevereiro | Guia de 15/02/2026 localizado; é tutorial editorial, não auditoria de segurança | [SitePoint](https://www.sitepoint.com/definitive-guide-local-llms-2026-privacy-tools-hardware/) |
| 0:40–0:47 e 2:34–2:41: filtro OpenAI como botão que bloqueia categorias | O produto existe, mas é modelo open-weight de detecção/remoção de PII, não um firewall universal de privacidade | [Anúncio oficial](https://openai.com/index/introducing-openai-privacy-filter/) |
| 0:47–0:58 e 2:41–2:49: comparação AIMultiple | Página localizada; comparar topologia e custo não prova que latência local será sempre menor | [AIMultiple](https://aimultiple.com/cloud-llm) |
| 0:58–1:12: elimina interceptação e atualização indesejada | Elimina o envio daquele prompt à API remota se não houver chamada; não elimina interceptação local, malware ou atualização do runtime | Análise de arquitetura; controles na matriz acima |
| 1:12–1:19 e 2:49–2:58: “Egard”, maio/2026 | O nome encontrado é **Eguard**, publicado em AAAI em 14/03/2026, com preprint de 2024. Defende embeddings contra inversão, não todos os dados nem canais físicos | [AAAI](https://ojs.aaai.org/index.php/AAAI/article/view/40876) |
| 1:19–1:35: NVIDIA e Brave | Publicações localizadas; sandbox contém acesso, mas prompt injection permanece relevante | [NVIDIA](https://developer.nvidia.com/blog/build-a-secure-always-on-local-ai-agent-with-nvidia-nemoclaw-and-openclaw/), [Brave](https://brave.com/blog/indirect-prompt-injection/) |
| 1:35–1:57 e 3:07–3:23: How-To Geek e XDA | Os artigos exatos, com essas datas e afirmações, não foram autenticados nesta busca. A viabilidade de endpoints locais está documentada pelos runtimes | [LM Studio API](https://lmstudio.ai/docs/developer/core/server) |
| 1:57–2:20: velocidade, offline e quantização | Offline e controle de versões são viáveis; velocidade e memória dependem de hardware, contexto, engine e quantização | Tabelas de hardware deste relatório |

O [OpenAI Privacy Filter](https://openai.com/index/introducing-openai-privacy-filter/) foi anunciado em 22/04/2026: 1,5B parâmetros totais, 50M ativos, execução local e oito categorias de dados. A OpenAI declara usar uma versão ajustada em seus próprios fluxos de privacidade. Pode compor uma barreira de minimização antes de um fallback remoto. **Remover PII não remove automaticamente propriedade intelectual, lógica de negócio ou todos os segredos.** O filtro tem falsos negativos e requer avaliação por domínio.

[Eguard](https://ojs.aaai.org/index.php/AAAI/article/view/40876) reporta proteção de mais de 95% dos tokens contra os ataques de inversão avaliados, preservando utilidade. O resultado é específico de embeddings e dos adversários testados. Não é “95% de segurança” de uma implantação, nem proteção eletromagnética do computador.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **LLM** — modelo de linguagem de grande porte; **GPU** — unidade de processamento gráfico; **CPU** — unidade central de processamento; **NPU** — unidade de processamento neural; **MLX** — framework de aprendizado de máquina da Apple; nome de runtime, não de quantização; **Q4** — família de quantização em 4 bits; sufixos identificam o formato específico; **VM** — máquina virtual; **EM** — eletromagnético; refere-se aqui a emissões físicas; **SDR** — rádio definido por software; **USB** — Universal Serial Bus; padrão de conexão de periféricos; **B / A…B** — B indica bilhões de parâmetros; A antes da contagem indica parâmetros ativos por token.

<!-- acronym-note:end -->

### Segunda transcrição: canal físico real, narrativa excessivamente generalizada

O preprint [Physical Side-Channel Attacks on Edge LLMs, outubro/2026](https://arxiv.org/html/2610.14215v1) oferece evidência concreta: Llama-3.2-1B Q4_K_M em CPU de Raspberry Pi 5, sonda junto à placa, frequência fixada e osciloscópio de laboratório. Reporta 97,2% na classificação de 50 palavras previamente perfiladas; para palavras não vistas, 67% de top-100. Os resultados não equivalem a reconstrução exata de qualquer prompt em qualquer laptop. O artigo apresenta GPUs como extensão futura e discute blindagem, randomização e mascaramento como possíveis defesas.

![Sonda eletromagnética posicionada junto à placa do Raspberry Pi no experimento publicado](assets/experimento-em.webp)

Imagem: figura 3 do [artigo de Alhalawani e colaboradores](https://arxiv.org/html/2610.14215v1), reprodução para análise. O posicionamento visível da sonda ajuda a distinguir o experimento de uma alegação genérica sobre alguém sentado a um metro de distância.

A transcrição mistura emissões EM, consumo elétrico, temperatura, cache e adversários em racks como se produzissem a mesma recuperação de texto. São mecanismos diferentes. O vídeo não fornece evidência suficiente para a alegação de que qualquer carregador USB-C, régua de coworking ou SDR barato recupere um prompt arbitrário, caractere a caractere, de um Mac ou NPU. “Mais calor” também não demonstra maior recuperabilidade de dados. Essas afirmações não são adotadas como fatos.

Há outra ameaça real em [I Know What You Said, USENIX Security 2025](https://www.usenix.org/conference/usenixsecurity25/presentation/gao-zibo): vazamento por cache, com processo adversário e recursos compartilhados. O [paper completo](https://www.usenix.org/system/files/usenixsecurity25-gao-zibo.pdf) discute controle de compartilhamento de memória e particionamento de cache em hardware compatível. Isso apoia isolamento de workloads e seleção de plataforma, mas não permite dizer que qualquer VM resolve qualquer canal lateral.

Para ambientes corporativos comuns, as primeiras medidas são proteger o host, limitar execução e egress, controlar acessórios e manter acesso físico sob gestão. Para segredos que justificam adversário fisicamente próximo e especializado, acrescentar avaliação de emissões, blindagem qualificada e infraestrutura dedicada. “Constant power” e ruído aleatório não são opções universais prontas de MLX ou llama.cpp; exigem implementação e validação específicas.

**Conclusão de segurança:** inferência local reduz uma classe importante de exposição — envio rotineiro a terceiros — e aumenta o controle operacional. Pode ser protegida com práticas já documentadas por grandes fornecedores. Não oferece invisibilidade física, assim como serviços em nuvem também precisam proteger hardware e isolamento entre clientes. O correto é comparar modelos de ameaça e risco residual, e não equiparar todos os cenários.
