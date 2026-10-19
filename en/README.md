# Local models for software engineering: savings, performance and governance

**English (primary)** · [Português](../README.pt-BR.md)

Research available in English and Portuguese, with sources, business cases, benchmarks and investment scenarios. Hybrid Scope: **local + cloud**. Update: October 16, 2026.

## Main documents

- [Full report on Markdown](RESEARCH_REPORT.md) — 199 references in the corresponding HTML.
- [HTML Report](report.html) — copyable tables, images of sources and navigation.
- [HTML Proposal](proposal.html) — Problem/Context + Solution + Required Investment and calculator.
- [HTML Slideshow](slides.html) — 16 slides for management and board.
- [Local agents and security](LOCAL_AGENTS_AND_SECURITY.md) — Oh My Pi, OpenCode, Claude Code, Codex CLI, Copilot CLI and VS Code.
- [HTML package offline](../research_bilingual.zip).

GitHub shows the HTML code. For the rendered presentation, clone or download the repository and open the files in the browser, preserving the repository directory structure. It does not require server or external services for reading. Source links require internet. GitHub Pages has not been activated.

## Evidence and reproduction

The research distinguishes results from suppliers, independent measurements, user reports, inferences and calculated scenarios. Model benchmarks were not executed in this project. Automated verification covers HTML documents, calculator, images, navigation, responsiveness and absence of external requests during reading.

- [CSV Sources](data/sources.csv).
- [Image provenance](../pesquisa_html/dados/imagens.json).
- [HTML Check Output](../pesquisa_html/dados/verificacao-html.json).
- [Integrity manifest SHA-256](../MANIFESTO_SHA256.txt), covering the published files except the manifest itself and Git metadata.

To regenerate: install Python dependency `Markdown` and execute `python scripts/build_english.py`. The check in `pesquisa_html/dados/verificar_html.py` requires Playwright and Google Chrome on the path indicated by the script. The Markdowns are the editable sources of the documents.

## Scope and support files

This repository contains the research for this session and the useful features to consult, edit, regenerate and verify the documents. Includes Markdown, HTML, original and optimized images, source data, Python scripts for generation and verification, ZIP and integrity manifest.

Old installation scripts, experimental settings and Node cache from the workspace are not part of the research. They were removed from the current version of the repository, preserving local copies. The initial commit remains in the Git history.

## Parallel translations

Portuguese originals remain in their original locations. English documents are in `en/`, including the full report, investment proposal, security updates, research history and slides. Figures reproduce the original sources; translated captions accompany them. The English edition preserves the research date and claims rather than updating the evidence.

Run `python scripts/verify_translation.py` to check table structures, numeric values, heading counts and source URLs against the Portuguese originals. Run `python scripts/verify_documents.py` for browser checks of both editions (requires Python Playwright and Google Chrome).
