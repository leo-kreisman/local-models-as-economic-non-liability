"""Recompute published cost deltas; this does not rerun model benchmarks."""
from pathlib import Path
from decimal import Decimal
import csv,json
ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/'research/2026-10-19'
checks=[]
with (DATA/'hybrid-costs.csv').open() as f:
 for row in csv.DictReader(f):
  base=Decimal(row['cloud_usd_per_task_or_request']);hybrid=Decimal(row['hybrid_usd_per_task_or_request'])
  saving=(base-hybrid)/base*100
  assert abs(saving-Decimal(row['calculated_remote_saving_percent']))<Decimal('.0001')
  checks.append({'case':row['case'],'recomputed_saving_percent':float(saving),'verified':True})
assert Decimal('.04')+Decimal('.20')*Decimal('.60')+Decimal('.03')+Decimal('.06')==Decimal('.25')
assert Decimal('300')/Decimal('.25')==1200
result={'status':'arithmetic_verified_only','published_cost_checks':checks,'illustrative_harness_break_even_tasks':1200,'model_benchmarks_executed':False,'security_tests_executed':False}
(DATA/'economic-verification.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
