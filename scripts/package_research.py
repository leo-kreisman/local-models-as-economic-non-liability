"""Package indexed research files, then hash all published files. Run after git add."""
from pathlib import Path
import subprocess,zipfile,hashlib
ROOT=Path(__file__).resolve().parents[1]
files=[p for p in subprocess.check_output(['git','ls-files','-z'],cwd=ROOT).decode().split('\0') if p]
bundled=[p for p in files if not p.endswith('.zip') and p!='MANIFESTO_SHA256.txt']
for name in ['research_bilingual.zip','pesquisa_modelos_locais_html.zip']:
 with zipfile.ZipFile(ROOT/name,'w',zipfile.ZIP_DEFLATED) as z:
  for p in bundled:z.write(ROOT/p,p)
files=sorted(set(files)|{'research_bilingual.zip','pesquisa_modelos_locais_html.zip'})
(ROOT/'MANIFESTO_SHA256.txt').write_text(''.join(hashlib.sha256((ROOT/p).read_bytes()).hexdigest()+'  '+p+'\n' for p in files if p!='MANIFESTO_SHA256.txt'))
print(f'Packaged {len(bundled)} files in each offline bundle; refreshed SHA-256 manifest.')
