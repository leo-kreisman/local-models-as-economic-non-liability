# Modelos locais para engenharia de software: economia, desempenho e governança

Pesquisa acumulada em português, com fontes, casos empresariais, benchmarks e cenários de investimento. Escopo híbrido: **local + nuvem**. Atualização: 16 de outubro de 2026.

## Documentos principais

- [Relatório completo em Markdown](RELATORIO_PESQUISA_MODELOS_LOCAIS.md) — 199 referências no HTML correspondente.
- [Relatório HTML](pesquisa_html/relatorio.html) — tabelas copiáveis, imagens das fontes e navegação.
- [Proposta HTML](pesquisa_html/proposta.html) — Problem/Context + Solution + Required Investment e calculadora.
- [Apresentação HTML](pesquisa_html/slides.html) — 16 slides para gestão e diretoria.
- [Agentes locais e segurança](pesquisa_html/AGENTES_LOCAIS_E_SEGURANCA.md) — Oh My Pi, OpenCode, Claude Code, Codex CLI, Copilot CLI e VS Code.
- [Pacote HTML offline](pesquisa_modelos_locais_html.zip).

O GitHub mostra o código dos HTMLs. Para a apresentação renderizada, clone ou baixe o repositório e abra os arquivos no navegador, mantendo a pasta `assets` junto deles. Não exige servidor nem serviços externos para leitura. Links de fontes exigem internet. Não foi ativado GitHub Pages.

## Evidências e reprodução

A pesquisa distingue resultados de fornecedores, medições independentes, relatos de usuários, inferências e cenários calculados. Os benchmarks dos modelos não foram executados neste projeto. A verificação automatizada cobre os documentos HTML, a calculadora, imagens, navegação, responsividade e ausência de requisições externas durante a leitura.

- [Fontes em CSV](pesquisa_html/dados/fontes.csv).
- [Proveniência das imagens](pesquisa_html/dados/imagens.json).
- [Resultado da verificação HTML](pesquisa_html/dados/verificacao-html.json).
- [Manifesto de integridade SHA-256](MANIFESTO_SHA256.txt), cobrindo os arquivos publicados, exceto o próprio manifesto e os metadados Git.

Para regenerar: instalar a dependência Python `Markdown` e executar `python pesquisa_html/gerar_html.py`. A verificação em `pesquisa_html/dados/verificar_html.py` requer Playwright e Google Chrome no caminho indicado pelo script. Os Markdown são as fontes editáveis dos documentos.

## Conteúdo integral preservado

Incluídos também o histórico de desenvolvimento, os scripts anteriores, a pasta `qwen38-flash-next`, as imagens PNG/WebP e o cache de compilação Node preexistente, conforme a solicitação de publicação integral. O cache é um artefato incidental, não requisito para leitura nem prova de benchmark.

Os scripts de setup abaixo configuram **Ollama Cloud**: sua presença neste arquivo histórico não os converte em implantação local. A orientação sobre agentes locais está nos documentos de pesquisa.

---

## Documentação anterior dos scripts (preservada)

# OpenCode + Ollama Cloud Setup Scripts

Automated setup scripts for Windows and Ubuntu / Linux to:
1. Register `OLLAMA_API_KEY` permanently in environment variables.
2. Install the `opencode` CLI (via official installer, package manager, or standalone binary).
3. Connect to Ollama Cloud (`https://ollama.com/v1`) and dynamically configure all available models.
4. Set up OpenCode configuration (`opencode.json`) and credentials (`auth.json`).

---

## 🐧 Ubuntu / Linux Setup

Pass **[setup_opencode_ubuntu.sh](file:///home/scribe/Projects/miscellaneous/coding_models/setup_opencode_ubuntu.sh)** to your friend:

### Option 1: Interactive Execution
```bash
chmod +x setup_opencode_ubuntu.sh
./setup_opencode_ubuntu.sh
```
It will prompt for `OLLAMA_API_KEY` and set up everything automatically.

### Option 2: Non-interactive (One-liner)
```bash
./setup_opencode_ubuntu.sh --api-key "your_ollama_api_key_here"
```

---

## 🪟 Windows Setup

Pass **[setup_opencode.cmd](file:///home/scribe/Projects/miscellaneous/coding_models/setup_opencode.cmd)** to your friend:

### Option 1: Double-Click Launcher (Easiest)
1. Double-click **`setup_opencode.cmd`**.
2. Enter the **`OLLAMA_API_KEY`** when prompted.

### Option 2: PowerShell
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\setup_opencode_ollama.ps1 -ApiKey "your_ollama_api_key_here"
```

---

## Available Models Configured
The scripts fetch live models from `https://ollama.com/api/tags` and configure them under the `ollama` provider:
- `ollama/glm-5.3` (default)
- `ollama/deepseek-v4.1-flash`
- `ollama/deepseek-v4-pro:0813`
- `ollama/kimi-k3`
- `ollama/kimi-k2.7-code`
- `ollama/kimi-k2.6`
- `ollama/mistral-large-3:675b`
- `ollama/minimax-m3`
- `ollama/minimax-m2.7`
- `ollama/nemotron-3-super`
- `ollama/nemotron-3-ultra`
- `ollama/nemotron-3-nano:30b`
- `ollama/gpt-oss:120b`
- `ollama/gpt-oss:20b`
- `ollama/gemma4:31b`
- `ollama/glm-5.2`
- `ollama/glm-5.3-flash`

---

## Using OpenCode After Setup
Once installed, open a terminal in any project:
```bash
# Reload environment variables
source ~/.bashrc

# Start OpenCode with default model
opencode

# Or launch directly with a specific model
opencode --model ollama/glm-5.3
opencode --model ollama/deepseek-v4.1-flash

# List all models
opencode models ollama
```
