1.会话

select program,row_wait_obj#,lockwait
from v$session
where sid='313'   --等待的对象，row_wait_obj# 780841

select sql_exec_start,event,wait_class,state,blocking_session_status,blocking_session
from v$session
where sid='313'
--  	SQL_EXEC_START	EVENT	WAIT_CLASS	STATE
--	2016/1/28 5:55:59	gc current request	Cluster	WAITING


2.等待的对象，row_wait_obj

select * 
from dba_objects 
where object_id=780841  
--DM2_LDCX_SBJCZB   LIST_2020160101 TABLE PARTITION 2016/1/28 4:58:40

3.会话等待

select * from v$session_wait where sid='313'
--SID	SEQ#	EVENT	P1TEXT	P1	P1RAW	P2TEXT	P2	P2RAW	P3TEXT	P3	P3RAW	WAIT_CLASS_ID	WAIT_CLASS#	WAIT_CLASS
--313	611	gc current request	file#	25	0000000000000019	block#	724896	00000000000B0FA0	id#	33554440	0000000002000008	3871361733	11	Cluster


4.会话等待的文件

select tablespace_name,file_name from dba_data_files where file_id='25'  

--+DATA/scstj1dw/datafile/ts_ldcx_data02.dbf


5.会话等待的extends

select * from dba_extents where file_id='25' AND block_id='724896'

6.一致性读的block

select * from gv$cr_block_server
-- cr_block:一致性读
-- current_block:在
--INST_ID	CR_REQUESTS	CURRENT_REQUESTS
--1	53342764	9082117
--2	1884546	1967386

7.锁中的会话信息

select * from v$lock where sid='313'
select trunc(id1/65536) usn,mod(id1,65536) slot,id2 wrap,lmode,BLOCK,TYPE from v$lock where sid='313' and type in ('TX')
--   	ADDR	KADDR	SID	                     TYPE	ID1	     ID2	LMODE	REQUEST	CTIME	BLOCK
--4	00007F564D3E2400	00007F564D3E2460	313	TM	780778	    0	6	0	       20478	2
--5	0000004F7E328B88	0000004F7E328C00	313	TX	63701062	719	6	0	       20478	2
--6	0000004F7E329598	0000004F7E329610	313	TX	63701019	719	6	0	       20475	1
--TM id1=object_id

--TX id1=usn+slot id2=seq
--lockmod 6-exclusive(x)
--block=2:golobal:lock is golbal
--block=1:blcking:this lock blocks other processes

8.锁对象的slot信息

select xidusn,xidslot,xidsqn
       object_id,session_id,locked_mode
from v$locked_object 
where session_id='313'

--XIDUSN	XIDSLOT	OBJECT_ID	SESSION_ID	LOCKED_MODE
--972	70	719	313	6
select * from dba_objects where object_id='313'  --SYS	CLUSTER_NODES TABLE

select trunc(id1/65536) usn,mod(id1,65536) slot,id2 wrap,lmode,BLOCK,TYPE from v$lock where sid='313' and type in ('TX')
-- 972	70	719	6	2	TX
-- 972	27	719	6	1	TX



10.阻塞另外一个锁的信息

select a.sid holdsid ,b.sid waitsid,a.type,a.id1,a.id2
from v$lock a, v$lock b
where a.id1=b.id1 and a.id2=b.id2
and a.block=1
and b.block=0

/*313	3029	TX	63701019	719
313	1777	TX	63701019	719
313	2500	TX	63701019	719*/

11.另外一个锁的信息：

--2500
select program,row_wait_obj#,lockwait
from v$session
where sid='2500'   --等待的对象，python@liqxd (TNS V1-V3)

select sql_exec_start,event,wait_class,state,blocking_session_status,blocking_session
from v$session
where sid='2500'
--SQL_EXEC_START	EVENT	WAIT_CLASS	STATE	BLOCKING_SESSION_STATUS	BLOCKING_SESSION
--2016/1/28 10:06:02	enq: TX - contention	Other	WAITING	VALID	313

select * from v$session_wait where sid='2500' or sid='3029'
--SID	SEQ#	EVENT	P1TEXT	P1	P1RAW	P2TEXT	P2	P2RAW	P3TEXT	P3	P3RAW
--2500	35753	enq: TX - contention	name|mode	1415053316	0000000054580004	usn<<16 | slot	63701019	0000000003CC001B	sequence	719	00000000000002CF

select * from v$lock where sid='2500'
--ADDR	KADDR	SID	TYPE	ID1	ID2	LMODE	REQUEST	CTIME	BLOCK
--4	0000004F6275F8D8	0000004F6275F930	2500	TX	63701019	719	0	4	13368	0

select * from v$transation

--TM id1=object_id
--TX id1=usn+slot id2=seq
--lockmod 6-exclusive(x)
--block=2:golobal:lock is golbal
--block=0:none
select xidusn,xidslot,xidsqn
       object_id,session_id,locked_mode
from v$locked_object 
where session_id='2500'

--XIDUSN	XIDSLOT	OBJECT_ID	SESSION_ID	LOCKED_MODE
--201	27	6513	3029	6
select * from dba_objects where object_id='6513'  --1	SYS	WRH$_PGA_TARGET_ADVICE		6513	6513	TABLE


