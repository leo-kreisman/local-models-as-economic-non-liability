"""Check both language editions in a real browser; no inference benchmarks."""
from pathlib import Path
import json
from playwright.sync_api import sync_playwright
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'output/playwright'
OUT.mkdir(parents=True,exist_ok=True)
results=[];errors=[];requests=[]
with sync_playwright() as p:
 browser=p.chromium.launch(executable_path='/usr/bin/google-chrome',headless=True,args=['--no-sandbox'])
 page=browser.new_page()
 page.on('pageerror',lambda e:errors.append(str(e)))
 page.on('request',lambda r:requests.append(r.url) if r.url.startswith('http') else None)
 for lang,folder,names in [('en','en',['report','proposal','slides']),('pt-BR','pesquisa_html',['relatorio','proposta','slides'])]:
  for width,height in [(1440,1000),(390,844)]:
   page.set_viewport_size({'width':width,'height':height})
   for name in names:
    path=ROOT/folder/(name+'.html')
    page.goto(path.as_uri(),wait_until='networkidle')
    page.evaluate("[...document.images].forEach(i=>i.loading='eager')")
    page.wait_for_function('[...document.images].every(i=>i.complete)')
    assert page.locator('html').get_attribute('lang')==lang
    broken=page.evaluate("[...document.querySelectorAll('a[href^=\"#\"]')].filter(a=>!document.getElementById(decodeURIComponent(a.hash.slice(1)))).map(a=>a.hash)")
    images=page.evaluate('[...document.images].every(i=>i.naturalWidth>0)')
    overflow=page.evaluate('document.documentElement.scrollWidth>innerWidth')
    assert not broken and images and not overflow,(path,broken,images,overflow)
    if name in ['proposal','proposta']:
     expected=['9.2 months','27.6 months','No payback'] if lang=='en' else ['9,2 meses','27,6 meses','Sem retorno']
     assert page.locator('#payback').inner_text()==expected[0]
     for value,text in zip(['20','0'],expected[1:]):
      page.locator('#avoid').fill(value)
      assert page.locator('#payback').inner_text()==text
    if name=='slides':
     page.keyboard.press('ArrowRight');page.wait_for_timeout(700)
     assert page.locator('.slide-count').inner_text()=='2 / 16'
    page.screenshot(path=str(OUT/f'{lang}-{name}-{width}.png'))
    results.append({'file':str(path.relative_to(ROOT)),'width':width,'anchors_ok':True,'images_ok':True,'overflow':False})
 browser.close()
assert not errors and not requests,(errors,requests)
result={'pages':results,'js_errors':errors,'external_requests':requests}
(ROOT/'en/data/html-verification.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
