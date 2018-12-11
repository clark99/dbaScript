select * from  v$transaction;
xindusn: undo segment number; 38
xidslot:slot number 109
xidsqn: sequence number(wrap#)
ubablk: undo record  of  undo file block number: uba block number;
ubafil: undo record of undo file number;

select * from v$lock;
--当前回话：
select distinct  sid from v$mystat;
select * from v$locked_object;

--v$transtion中的sql
select b.*
from v$transaction a,v$session b
where a.addr=b.paddr;
