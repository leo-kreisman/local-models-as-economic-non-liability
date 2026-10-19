"""Build both offline editions from checked-in sources; no translation service required."""
from pathlib import Path
import csv,html,json,re,runpy
import markdown
BASE=Path(__file__).resolve().parents[1]
ROOT=BASE/'en'
pt=runpy.run_path(str(BASE/'pesquisa_html/gerar_html.py'))
CSS=pt['CSS']
JS=pt['JS']
for old,new in {
 'pt-BR':'en-US', 'Tabela ':'Table ', '; rolagem horizontal':'; horizontal scrolling',
 'Copiar tabela':'Copy table',' como texto':' as text','Copiada':'Copied',
 ' meses':' months','Sem retorno':'No payback','Investimento: ':'Investment: ',
 ' · Antes: ':' · Before: ','/mês · Depois: ':'/month · After: ',
 '/mês. Cenário calculado; a parcela evitada deve ser medida na fatura.':'/month. Calculated scenario; the avoided portion must be measured against the bill.'
}.items():JS=JS.replace(old,new)
SOURCES={}
def convert(md):
 obj=markdown.Markdown(extensions=['tables','fenced_code','toc','sane_lists'])
 body=obj.convert(md);refs=[];mapping={}
 def link(m):
  url,label=m.group(1),m.group(2)
  if not url.startswith(('https://','http://')):return m.group(0)
  clean=html.unescape(url)
  if clean not in mapping:
   mapping[clean]=len(mapping)+1;refs.append((clean,re.sub('<[^>]+>','',label)))
  n=mapping[clean];SOURCES.setdefault(clean,re.sub('<[^>]+>','',label))
  return f'<a href="{url}" target="_blank" rel="noopener noreferrer">{label}</a><sup class="ref"><a href="#ref-{n}" aria-label="Reference {n}">[{n}]</a></sup>'
 body=re.sub(r'<a href="([^"]+)">(.*?)</a>',link,body,flags=re.S)
 body=re.sub(r'<p><img alt="([^"]*)" src="([^"]*)" ?/?></p>',lambda m:f'<figure class="figure"><a href="{m[2]}" aria-label="Open full-size image"><img src="{m[2]}" alt="{m[1]}" loading="lazy" decoding="async"></a><figcaption>{m[1]}</figcaption></figure>',body)
 bibliography='<section class="references chapter" id="references"><h2>References and traceability</h2><p class="small">Links collected in this edition. Caveats about access, date and strength of evidence remain alongside the findings. Sources consulted through October 16, 2026.</p><ol>'
 for i,(u,l) in enumerate(refs,1):bibliography+=f'<li id="ref-{i}"><a href="{html.escape(u)}" target="_blank" rel="noopener noreferrer">{html.escape(l)}</a><span class="url">{html.escape(u)}</span></li>'
 bibliography+='</ol></section>'
 heads=re.findall(r'<h2 id="([^"]+)">(.*?)</h2>',body)
 toc=''.join(f'<a href="#{i}">{t}</a>' for i,t in heads)+'<a href="#references">References</a>'
 pieces=re.split(r'(?=<h2 id=)',body)
 body=pieces[0]+''.join('<section class="chapter">'+s+'</section>' for s in pieces[1:])
 return body+bibliography,toc,len(refs)

def topbar(active):
 counterpart={'report.html':'relatorio.html','proposal.html':'proposta.html','slides.html':'slides.html'}[active]
 return '<div class="progress"></div><a class="skip" href="#content">Skip to content</a><header class="topbar"><a class="brand" href="report.html">ENGINEERING · AI UNDER CONTROL</a><nav aria-label="Documents">'+''.join(f'<a href="{f}"'+(' aria-current="page"' if f==active else '')+f'>{l}</a>' for f,l in [('report.html','Research'),('proposal.html','Investment'),('slides.html','Leadership')])+f'<a href="../pesquisa_html/{counterpart}" lang="pt-BR" hreflang="pt-BR">Português</a></nav><button class="print">Print / PDF</button></header>'

def calculator():
 return '''<section class="calc no-print-break" aria-labelledby="calc-title"><span class="badge">Adjustable scenario • local calculation</span><h3 id="calc-title">How much must the bill fall for the investment to pay for itself?</h3><p class="small">Illustrative amounts in US dollars. No input is sent over the network. Operations and repairs are monthly, per person.</p><div class="calc-grid">
<label>People<input id="people" type="number" min="1" max="10000" value="5"></label><label>Hardware per person · US$<input id="capex" type="number" min="0" value="5000"></label><label>Current API per person/month · US$<input id="bill" type="number" min="0" value="2000"></label><label>Bill actually avoided · %<input id="avoid" type="number" min="0" max="100" value="50"></label><label>Local operations per person/month · US$<input id="ops" type="number" min="0" value="100"></label><label>Implementation + contingency · US$<input id="setup" type="number" min="0" value="16400"></label><label>Repairs/extra work per person/month · US$<input id="repair" type="number" min="0" value="0"></label></div><div class="results" aria-live="polite"><div><small>Net monthly savings</small><strong id="saving">US$ 4,500</strong></div><div><small>Simple payback</small><strong id="payback">9.2 months</strong></div><div><small>First-year balance</small><strong id="year">US$ 12,600</strong></div></div><p id="calc-detail" class="small" style="margin-top:18px"></p></section>'''

def document(file,title,subtitle,eyebrow,md,calc=False):
 body,toc,count=convert(md)
 if calc:body=calculator()+body
 out=f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="description" content="{html.escape(subtitle)}"><title>{html.escape(title)}</title><style>{CSS}</style></head><body>{topbar(file)}<div class="hero"><div class="eyebrow">{eyebrow}</div><h1>{title}</h1><p class="dek">{subtitle}</p><div class="meta">October 16, 2026 edition · {count} linked references · Static HTML, no external services</div></div><div class="layout"><aside class="sidebar"><details open><summary>In this document</summary><label class="visually-hidden" for="toc-search">Search the table of contents</label><input id="toc-search" type="search" placeholder="Filter contents · Ctrl K">{toc}</details></aside><main id="content">{body}</main></div><footer class="foot">Cumulative research for business decisions. No model benchmark was run by this research. Sources, assumptions and limitations are identified. Open the three HTML files directly in your browser; preserve the shared assets folder.</footer><script>{JS}</script></body></html>'''
 (ROOT/file).write_text(out)
 return count

lead='''## Guidance for reading and decision-making

This dossier brings together the accumulated research, including benchmarks, costs, business cases and security controls. The business hypothesis is to test local inference for verifiable work and retain the cloud for authorized tasks where it delivers more value. Decisions should track quality, cost per task and data leaving the environment.

The material has three reading levels: this report preserves the detail and sources; the [investment proposal](proposal.html) organizes the problem, solution and budget; the [leadership slides](slides.html) highlight the decision and its limitations. HTML tables can be copied. Source images are accompanied by provenance and were visually checked.

**Updates in this edition:** reports of Opus 4.8 regression were expanded with public data; the two transcripts were checked claim by claim; Google, NVIDIA and local runtimes provide examples of applicable controls. The absence of proof of corporate intent does not negate the experience reported by programmers. Local security is manageable, but must cover tools, networking, logs and physical access.

'''
md=(ROOT/'RESEARCH_REPORT.md').read_text()
md=re.sub(r'^# .*\n','',md,count=1)
# Keep the translated conversational quotations, with their complete content.
md=re.sub(r'(### (?:Original request for this update[^\n]*|Request received[^\n]*)\n)(.*?)(?=\n### )',lambda m:'<details class="archive"><summary>'+m[1].strip('# \n')+'</summary>\n\n'+m[2]+'\n</details>\n',md,flags=re.S)
needle='[Textbooks Are All You Need'
pos=md.find(needle)
if pos>=0:
 start=md.rfind('\n\n',0,pos)+2
 md=md[:start]+'![Original FigmaTrace table: accuracy by evaluation and data preparation method](../pesquisa_html/assets/figmatrace-tabela.webp)\n\nVisual source: [FigmaTrace, table 3](https://arxiv.org/html/2608.21460v1), screenshot of the original HTML; includes regressions and the mean row to allow verification.\n\n'+md[start:]
count=document('report.html','Local models for software engineering','Evidence, performance, savings and security — from the developer’s computer to shared infrastructure.','01 / Research report',lead+md)
proposal=re.sub(r'^# .*\n','',(ROOT/'INVESTMENT_PROPOSAL.md').read_text(),count=1)
document('proposal.html','Investing in local AI capacity','Problem, solution and required investment for an engineering pilot with cost and data controls.','02 / Investment proposal',proposal,True)
slides=json.loads((ROOT/'SLIDES.json').read_text())
body=''.join(f'<section class="slide {"dark" if s["dark"] else ""}" id="slide-{i}" aria-label="Slide {i}: {html.escape(s["title"])}"><div class="eyebrow">{s["label"]}</div><h2>{s["title"]}</h2><div class="slide-content">{s["body"]}</div><div class="source">{s["source"]}</div><span class="slide-number">{i:02} / {len(slides):02}</span></section>' for i,s in enumerate(slides,1))
(ROOT/'slides.html').write_text(f'<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Local AI — leadership decision</title><style>{CSS}{pt["DECKCSS"]}</style></head><body class="deck">{topbar("slides.html")}<main id="content">{body}</main><div class="slide-controls"><button id="previous" aria-label="Previous slide">←</button><span class="slide-count" aria-live="polite">1 / {len(slides)}</span><button id="next" aria-label="Next slide">→</button><button id="fullscreen">Full screen</button></div><script>{JS}{pt["DECKJS"]}</script></body></html>')
with (ROOT/'data/sources.csv').open('w',newline='') as f:
 w=csv.writer(f);w.writerow(['url','label_in_document']);w.writerows(SOURCES.items())
print(f'English: {count} report sources; {len(slides)} slides')
