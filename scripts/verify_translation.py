from pathlib import Path
from html.parser import HTMLParser
from collections import Counter
from decimal import Decimal
import re,json,markdown
r=Path(__file__).resolve().parents[1]
class Tables(HTMLParser):
 def __init__(self):super().__init__();self.tables=[];self.cell=None;self.row=None;self.table=None
 def handle_starttag(self,t,a):
  if t=='table':self.table=[]
  if t=='tr':self.row=[]
  if t in ('td','th'):self.cell=''
 def handle_data(self,d):
  if self.cell is not None:self.cell+=d
 def handle_endtag(self,t):
  if t in ('td','th'):self.row.append(self.cell);self.cell=None
  if t=='tr':self.table.append(self.row);self.row=None
  if t=='table':self.tables.append(self.table);self.table=None

def tables(s):
 p=Tables();p.feed(markdown.markdown(s,extensions=['tables','fenced_code']));return p.tables

def nums(s,pt):
 out=[]
 for m in re.finditer(r'\d+(?:[.,]\d+)*',s):
  v=m[0];after=s[m.end():]
  # Model/release versions with multiple separators are identifiers.
  if len(v.split('.'))>2 and not re.fullmatch(r'\d{1,3}(?:\.\d{3})+',v):out.append(v);continue
  if pt:
   if ',' in v:v=v.replace('.','').replace(',','.')
   elif re.fullmatch(r'\d{1,3}(?:\.\d{3})+',v):v=v.replace('.','')
  else:v=v.replace(',','')
  try:
   n=Decimal(v)
   if re.match(r'\s*(?:mil\b|thousand\b)',after):n*=1000
   if re.match(r'\s*(?:milhões\b|million\b)',after):n*=1000000
   out.append(str(n.normalize()))
  except:out.append(v)
 return Counter(out)

pairs=[('RELATORIO_PESQUISA_MODELOS_LOCAIS.md','en/RESEARCH_REPORT.md'),('pesquisa_html/PROPOSTA_INVESTIMENTO.md','en/INVESTMENT_PROPOSAL.md'),('pesquisa_html/AGENTES_LOCAIS_E_SEGURANCA.md','en/LOCAL_AGENTS_AND_SECURITY.md'),('pesquisa_html/ATUALIZACAO_SEGURANCA_E_REGRESSOES.md','en/SECURITY_AND_REGRESSIONS_UPDATE.md')]
pairs.append(('pesquisa_html/GUIA_ENGENHARIA_HIBRIDA.md','en/HYBRID_ENGINEERING_PLAYBOOK.md'))
pairs.append(('pesquisa_html/HARNESSES_POR_TAREFA.md','en/TASK_HARNESSES.md'))
report=[]
for a,b in pairs:
 pt=(r/a).read_text();en=(r/b).read_text();t1=tables(pt);t2=tables(en)
 urls=lambda s:Counter(re.findall(r'https?://[^\s)<>]+',s))
 errors=[]
 for i,(u,v) in enumerate(zip(t1,t2)):
  if len(u)!=len(v):errors.append({'table':i,'row_counts':[len(u),len(v)]})
  for j,(x,y) in enumerate(zip(u,v)):
   if len(x)!=len(y):errors.append({'table':i,'row':j,'columns':[len(x),len(y)]})
   for k,(s,t) in enumerate(zip(x,y)):
    if nums(s,True)!=nums(t,False):errors.append({'table':i,'row':j,'cell':k,'pt':s,'en':t,'numbers_pt':dict(nums(s,True)),'numbers_en':dict(nums(t,False))})
 report.append({'pt':a,'en':b,'tables':[len(t1),len(t2)],'headings':[len(re.findall('^#+ ',pt,re.M)),len(re.findall('^#+ ',en,re.M))],'urls_equal':urls(pt)==urls(en),'table_numeric_differences':errors})
print(json.dumps(report,ensure_ascii=False,indent=2))
(r/'en/data/translation-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2))

assert all(x["urls_equal"] and x["tables"][0]==x["tables"][1] and x["headings"][0]==x["headings"][1] and not x["table_numeric_differences"] for x in report), "Translation consistency check failed"
