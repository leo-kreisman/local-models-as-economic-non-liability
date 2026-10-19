"""Maintain contextual bilingual acronym notes in research sources and slide content."""
from pathlib import Path
import re,json,subprocess,html
ROOT=Path(__file__).resolve().parents[1]
TERMS=json.loads((ROOT/'research/acronyms.json').read_text())
START='<!-- acronym-note:start -->'
END='<!-- acronym-note:end -->'
def clean(text):
 return re.sub(re.escape(START)+r'.*?'+re.escape(END)+r'\n\n','',text,flags=re.S)
def visible(text):
 text=re.sub(r'```.*?```','',text,flags=re.S)
 text=re.sub(r'\]\([^)]*\)',']',text)
 text=re.sub(r'https?://[^\s<>]+','',text)
 text=re.sub(r'<[^>]+>',' ',text)
 return html.unescape(text)
def found(text):
 text=visible(text)
 return [k for k in TERMS if (re.search(r'\d+B\b',text) if k=='B / A…B' else re.search(r'(?<![A-Za-z0-9])'+re.escape(k)+r'(?:s)?(?![A-Za-z])',text))]
def description(keys,lang):
 return '; '.join(f'**{k}** — {TERMS[k][lang]}' for k in keys)+'.'
def note(text,lang,kind):
 keys=found(text)
 if not keys:return ''
 label=({'section':'Siglas e notações desta seção','table':'Siglas e notações da tabela'} if lang=='pt' else {'section':'Acronyms and notation in this section','table':'Acronyms and notation in this table'})[kind]
 return START+'\n\n**'+label+':** '+description(keys,lang)+'\n\n'+END+'\n\n'
def annotate_md(text,lang):
 text=clean(text);lines=text.splitlines(keepends=True);output=[];i=0
 while i<len(lines):
  if lines[i].startswith('```'):
   output.append(lines[i]);i+=1
   while i<len(lines):
    line=lines[i];output.append(line);i+=1
    if line.startswith('```'):break
   continue
  if re.match(r'^#{1,6} ',lines[i]):
   end=i+1
   while end<len(lines) and not re.match(r'^#{1,6} ',lines[end]):end+=1
   prose=''.join(line for line in lines[i:end] if not line.lstrip().startswith(('|','>')))
   annotation=note(prose,lang,'section')
   if lines[i].startswith('# '):
    output.extend([lines[i],'\n',annotation]);i+=1
    while i<len(lines) and not lines[i].strip():i+=1
   else:output.extend([annotation,lines[i]]);i+=1
   continue
  if lines[i].startswith('|') and i+1<len(lines) and re.match(r'^\|[\s:|\-]+$',lines[i+1].strip()):
   end=i+2
   while end<len(lines) and lines[end].startswith('|'):end+=1
   table=''.join(lines[i:end]);output.extend([note(table,lang,'table'),table]);i=end;continue
  output.append(lines[i]);i+=1
 return ''.join(output)
def slide_note(content,title,lang):
 content=clean(content)
 keys=found(title+' '+content)
 if not keys:return content
 label='Siglas e notações' if lang=='pt' else 'Acronyms and notation'
 definitions='; '.join(f'<b>{html.escape(k)}</b>: {html.escape(TERMS[k][lang])}' for k in keys)
 return START+f'<p class="acronym-note"><strong>{label}:</strong> {definitions}.</p>'+END+'\n\n'+content
if __name__=='__main__':
 paths=subprocess.check_output(['git','ls-files','*.md'],cwd=ROOT,text=True).splitlines()
 for name in paths:
  p=ROOT/name;lang='en' if name.startswith('en/') or name=='README.md' else 'pt'
  p.write_text(annotate_md(p.read_text(),lang))
 # Generated PT slides are also annotated by the generator, including its base slides.
 for name,lang in [('en/SLIDES.json','en'),('pesquisa_html/SLIDES_FOCO.json','pt'),('pesquisa_html/SLIDES_APOIO.json','pt')]:
  p=ROOT/name;data=json.loads(p.read_text());items=data.values() if isinstance(data,dict) else data
  for item in items:item['body']=slide_note(item['body'],item['title'],lang)
  p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')
 print(f'Annotated {len(paths)} Markdown documents and bilingual slide sources.')
