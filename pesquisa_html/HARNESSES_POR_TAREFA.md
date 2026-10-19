# Dois harnesses especializados para o piloto

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **OMP** — Oh My Pi; agente de programação.

<!-- acronym-note:end -->

Exemplos de projeto, não configurações implantadas nem alegações de sucesso medido. Aplicáveis a adaptadores qualificados de OMP, OpenCode ou Aider. As permissões são impostas pela plataforma; estas instruções não são o limite de segurança.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **API** — interface de programação de aplicações; conecta componentes de software; **DTO** — objeto de transferência de dados.

<!-- acronym-note:end -->

## Harness A — propagar um campo de DTO aprovado

**Contrato de entrada:** revisão fixada do repositório, nome/tipo do campo, opcionalidade, padrão, contrato de serialização, versão da API afetada, escopo aprovado de arquivos e requisitos de compatibilidade. Decisões de negócio ausentes provocam escalonamento antes da edição. Fornecer apenas definições, usos e exemplos aprovados relacionados, não todo o repositório por padrão.

**Procedimento do executor:** inspecionar definições e pontos de chamada; listar edições pretendidas; preferir transformação determinística quando disponível; atualizar DTO, mapeamento e construções necessárias; executar build aprovado e testes relevantes de contrato; inspecionar o diff em busca de alterações não relacionadas. Retornar patch, verificações executadas, códigos de saída e questões pendentes. Nunca afirmar aprovação de teste não executado.

**Ferramentas externas:** leitura/busca restritas ao worktree, patch limitado aos caminhos de código aprovados e executor de testes com manifesto fixo de comandos. Sem rede arbitrária, banco de produção, arquivos de segredos, shell do host ou escrita nas fixtures ocultas de avaliação. Credenciais do runtime são intermediadas, não embutidas nas instruções.

**Regra de parada:** o controlador permite no máximo duas tentativas de reparo no experimento inicial, depois registra falha ou aplica política aprovada de escalonamento. Um controlador valida a solicitação de ferramenta; o modelo não amplia seu próprio orçamento. Duas tentativas são premissa do piloto, não valor ótimo medido.

**Aceitação:** compilação aprovada; mudanças de schema correspondem ao contrato; chamadores anteriores permanecem compatíveis quando exigido; arquivos não relacionados e testes protegidos não mudam; regressões não introduzem novas falhas. Uma pessoa aprova alterações de semântica de negócio. Falha de segurança rejeita a execução mesmo com testes funcionais aprovados.

## Harness B — expandir uma suíte existente de regressão

**Contrato de entrada:** comportamento-alvo, regressão conhecida ou especificação explícita, convenções existentes, fixtures sintéticas e escopo permitido de arquivos de teste. Não inferir invariante de negócio apenas pelo comportamento da implementação atual.

**Procedimento do executor:** inspecionar alvo e testes; propor caso de borda ausente; adicionar teste com asserção útil; executar na referência; usar mutante fornecido pelo controlador ou revisão defeituosa conhecida para demonstrar detecção; restaurar referência e repetir. Reportar defeito exato detectado e resultado instável. Teste aprovado sem sensibilidade demonstrada não é automaticamente aceito.

**Regra de parada:** tentativas e tempo limitados, sem produção nem alterações do verificador independente. Separar falha de criação de arquivo, teste inválido, teste instável e defeito real do produto. O resultado Nav sobre criação de testes exige validar esse caminho explicitamente, não supor funcionamento porque renomeação funciona.

**Aceitação:** o teste proposto passa na fixture correta, falha para o defeito designado, permanece estável nas repetições predefinidas e não enfraquece asserções nem ignora cobertura existente. A suíte independente permanece sem acesso de escrita. Escores de mutação exigem conjunto fixo e relevante de mutantes, não apenas as mutações que o agente escolher.

## Contrato do otimizador de nuvem

O otimizador recebe schemas de tarefas aprovados, categorias sanitizadas de erro e exemplos permitidos. Propõe patch nas instruções e no schema de ferramentas, com justificativa e falha esperada a corrigir. Não recebe credenciais brutas, código proibido nem respostas de testes ocultos. A exportação de dados é aprovada independentemente da necessidade de otimização.

O controlador compara candidato e versão vigente congelada em conjunto separado, medindo aceitação, tipos de falha, custo, latência e violações de política. Rejeita regressões, preserva resultados negativos e submete candidatos aprovados à revisão. A nuvem pode sugerir verificação mais forte, mas não substituir o verificador independente nem alterar permissões de implantação. A promoção produz artefato versionado com modelo/quantização, versões de agente/runtime, escopo, avaliação e alvo de rollback.

O otimizador mais caro é acionado no desenvolvimento ou revisão programada, não necessariamente em toda tarefa local. Comparar seu custo amortizado à fatura remota evitada. Se um gerador determinístico ou codemod atende aos mesmos critérios, pode ser o caminho recorrente sem inferência alguma.
