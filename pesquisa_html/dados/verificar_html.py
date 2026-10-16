from pathlib import Path
from playwright.sync_api import sync_playwright
import json
root=Path(__file__).resolve().parents[1]
report=[]
with sync_playwright() as p:
 b=p.chromium.launch(executable_path='/usr/bin/google-chrome',headless=True,args=['--no-sandbox'])
 page=b.new_page(viewport={'width':1440,'height':1000},device_scale_factor=1)
 errors=[];requests=[]
 page.on('pageerror',lambda e:errors.append(str(e)))
 page.on('request',lambda r:requests.append(r.url) if r.url.startswith('http') else None)
 for file in ['relatorio.html','proposta.html','slides.html']:
  page.goto((root/file).as_uri(),wait_until='networkidle')
  page.evaluate("() => [...document.images].forEach(i=>i.loading='eager')")
  page.wait_for_function("[...document.images].every(i=>i.complete)")
  failures=page.evaluate('''() => [...document.querySelectorAll('a[href^="#"]')].filter(a=>!document.getElementById(decodeURIComponent(a.hash.slice(1)))).map(a=>a.hash)''')
  imgs=page.evaluate('''() => [...document.images].map(i=>({src:i.getAttribute('src'),ok:i.complete&&i.naturalWidth>0}))''')
  page.screenshot(path=f'/tmp/{file}-desktop.png')
  report.append({'file':file,'broken_anchors':failures,'images':imgs,'horizontal_overflow':page.evaluate('document.documentElement.scrollWidth > innerWidth')})
  if file=='proposta.html':
   assert page.locator('#payback').inner_text()=='9,2 meses'
   page.locator('#avoid').fill('20');assert page.locator('#payback').inner_text()=='27,6 meses'
   page.locator('#avoid').fill('0');assert page.locator('#payback').inner_text()=='Sem retorno'
   page.locator('#avoid').fill('50')
   page.locator('.calc').screenshot(path='/tmp/calculadora.png')
  if file=='slides.html':
   page.keyboard.press('ArrowRight');page.wait_for_timeout(700);assert page.locator('.slide-count').inner_text()=='2 / 16'
   overflow=[]
   for i in range(1,17):
    slide=page.locator(f'#slide-{i}')
    h=slide.evaluate('(s)=>s.getBoundingClientRect().height')
    if h>1001:overflow.append({'slide':i,'height':h})
   report[-1]['tall_slides_desktop']=overflow
   page.locator('#slide-8').scroll_into_view_if_needed();page.screenshot(path='/tmp/slide-seguranca.png')
   page.pdf(path='/tmp/slides-check.pdf',prefer_css_page_size=True,print_background=True)
 for file in ['relatorio.html','proposta.html','slides.html']:
  page.set_viewport_size({'width':390,'height':844})
  page.goto((root/file).as_uri(),wait_until='networkidle');page.screenshot(path=f'/tmp/{file}-mobile.png')
  report.append({'file':file,'mobile_horizontal_overflow':page.evaluate('document.documentElement.scrollWidth > innerWidth'), 'widths':page.evaluate('[document.documentElement.scrollWidth,innerWidth]'), 'overflow_elements':page.evaluate("[...document.querySelectorAll('body *')].filter(e=>e.getBoundingClientRect().right>innerWidth+1&&!e.closest('.table-scroll')).map(e=>[e.tagName,e.className,e.getBoundingClientRect().right])")})
 b.close()
print(json.dumps({'pages':report,'js_errors':errors,'external_requests':requests},ensure_ascii=False,indent=2))
(root/'dados'/'verificacao-html.json').write_text(json.dumps({'pages':report,'js_errors':errors,'external_requests':requests},ensure_ascii=False,indent=2))
