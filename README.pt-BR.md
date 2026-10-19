# Modelos locais para engenharia de software: economia, desempenho e governança

Pesquisa acumulada em português, com fontes, casos empresariais, benchmarks e cenários de investimento. Escopo híbrido: **local + nuvem**. Atualização: 19 de outubro de 2026.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **CLI** — interface de linha de comando; **HTML** — HyperText Markup Language; formato de documentos web.

<!-- acronym-note:end -->

## Documentos principais

- [Guia de engenharia híbrida](pesquisa_html/GUIA_ENGENHARIA_HIBRIDA.md) — economia medida, segurança de estações com internet e harnesses reutilizáveis.

- [Relatório completo em Markdown](RELATORIO_PESQUISA_MODELOS_LOCAIS.md) — 226 referências no HTML correspondente.
- [Relatório HTML](pesquisa_html/relatorio.html) — tabelas copiáveis, imagens das fontes e navegação.
- [Proposta HTML](pesquisa_html/proposta.html) — Problem/Context + Solution + Required Investment e calculadora.
- [Apresentação HTML](pesquisa_html/slides.html) — 16 slides para gestão e diretoria.
- [Agentes locais e segurança](pesquisa_html/AGENTES_LOCAIS_E_SEGURANCA.md) — Oh My Pi, OpenCode, Claude Code, Codex CLI, Copilot CLI e VS Code.
- [Pacote HTML offline](pesquisa_modelos_locais_html.zip).

O GitHub mostra o código dos HTMLs. Para a apresentação renderizada, clone ou baixe o repositório e abra os arquivos no navegador, mantendo a pasta `assets` junto deles. Não exige servidor nem serviços externos para leitura. Links de fontes exigem internet. Não foi ativado GitHub Pages.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **CSV** — valores separados por vírgulas; formato de dados tabulares; **HTML** — HyperText Markup Language; formato de documentos web; **SHA-256** — algoritmo de hash seguro com resumo de 256 bits; verificação de integridade.

<!-- acronym-note:end -->

## Evidências e reprodução

A pesquisa distingue resultados de fornecedores, medições independentes, relatos de usuários, inferências e cenários calculados. Os benchmarks dos modelos não foram executados neste projeto. A verificação automatizada cobre os documentos HTML, a calculadora, imagens, navegação, responsividade e ausência de requisições externas durante a leitura.

- [Fontes em CSV](pesquisa_html/dados/fontes.csv).
- [Proveniência das imagens](pesquisa_html/dados/imagens.json).
- [Resultado da verificação HTML](pesquisa_html/dados/verificacao-html.json).
- [Manifesto de integridade SHA-256](MANIFESTO_SHA256.txt), cobrindo os arquivos publicados, exceto o próprio manifesto e os metadados Git.

Para regenerar: instalar a dependência Python `Markdown` e executar `python pesquisa_html/gerar_html.py`. A verificação em `pesquisa_html/dados/verificar_html.py` requer Playwright e Google Chrome no caminho indicado pelo script. Os Markdown são as fontes editáveis dos documentos.

<!-- acronym-note:start -->

**Siglas e notações desta seção:** **HTML** — HyperText Markup Language; formato de documentos web; **ZIP** — formato de arquivo compactado.

<!-- acronym-note:end -->

## Escopo e arquivos de apoio

Este repositório contém a pesquisa desta sessão e os recursos úteis para consultar, editar, regenerar e verificar seus documentos. Inclui Markdown, HTML, imagens originais e otimizadas, dados das fontes, scripts Python de geração e verificação, ZIP e manifesto de integridade.

Scripts antigos de instalação, configurações experimentais e cache Node da pasta de trabalho não fazem parte da pesquisa. Foram retirados da versão atual do repositório, preservando as cópias locais. O commit inicial permanece no histórico Git.
