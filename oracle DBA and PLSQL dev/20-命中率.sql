select round((1-(p.value-d.value-lobs.value)/logical.value)*100,2),p.inst_id
from gv$sysstat p,gv$sysstat d,gv$sysstat lobs,gv$sysstat logical
where p.name='physical reads'
and d.name='physical reads direct'
and lobs.name='physical reads direct (lob)'
and logical.name='session logical reads'
and p.inst_id=d.inst_id
and p.inst_id=lobs.inst_id
and p.inst_id=logical.inst_id