--比对COLUMN_ID
SELECT COLUMN_NAME,COLUMN_ID FROM DBA_TAB_COLUMNS WHERE TABLE_NAME='LDMT04_SB_GRSDS_SRNSMX'
MINUS
SELECT COLUMN_NAME,COLUMN_ID FROM DBA_TAB_COLUMNS WHERE TABLE_NAME='INFT04_SB_GRSDS_SRNSMX'
---------------------------------------------\
--创建过程
CREATE OR REPLACE PROCEDURE J1_LDM.P_GRSDS_SRNSMX IS
begin
  execute immediate 'alter session enable parallel ddl';
  execute immediate 'truncate table j1_ldm.LDMT04_SB_GRSDS_SRNSMX';
  
/*  --前提是：COLUMN_ID
  SELECT COLUMN_NAME,COLUMN_ID FROM DBA_TAB_COLUMNS WHERE TABLE_NAME='LDMT04_SB_GRSDS_SRNSMX'
  MINUS
  SELECT COLUMN_NAME,COLUMN_ID FROM DBA_TAB_COLUMNS WHERE TABLE_NAME='INFT04_SB_GRSDS_SRNSMX'
*/

  insert /*+append parallel(32) */
  into j1_ldm.LDMT04_SB_GRSDS_SRNSMX
  select /*+parallel(32) */* 
  from J1_g3_zbq.INFT04_SB_GRSDS_SRNSMX;
  commit;
end;

-----------------------------------------------
--step:--03 执行过程
-----------------------------------------------
declare
  job number;
begin
  sys.dbms_job.submit(job  => job,
                      what => '
begin
  -- Call the procedure
  J1_LDM.P_GRSDS_SRNSMX;
end;
',
                      --修改date,select sysdate from dual;
                      next_date => to_date('2016/9/7 16:10:09',
                                           'yyyy/mm/dd hh24:mi:ss'),
                      interval  => 'sysdate+99999');
  commit;
  DBMS_OUTPUT.PUT_LINE(job);
end;

----------------------------------------------
select round(sum(bytes)/1024/1024/1024,2), sum(blocks)
  from dba_segments
 where segment_name = 'LDMT04_SB_GRSDS_SRNSMX'
 group by segment_name
--1 82.84 2714390
select /*+parallel(32)*/count(1) from j1_ldm.LDMT04_SB_GRSDS_SRNSMX
--142522092


