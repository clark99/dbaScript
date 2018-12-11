/*****************************
{1}查看存在性能问题的表：
******************************/
--查看锁
SELECT distinct
       s.username,
       s.inst_id,
       o.object_name,
       s.wait_class,
       'alter system kill session ''' || s.sid || ',' || s.serial# ||
       ''' immediate;' as sql_kill_session,
       'ps -ef | grep ' || p.spid || ' | grep -v grep' as shell_grep_proc,
       'kill -9 ' || p.spid as shell_kill_proc,
       s.blocking_session,
       s.seconds_in_wait,
       machine,
       p.program,
       s.sql_id
  FROM gv$locked_object l, dba_objects o, gv$session s, gv$process p
 WHERE l.object_id = o.object_id
   AND l.session_id = s.sid
   and s.paddr = p.addr
   and s.username in ('J1_DW','J1_LDCX','J1_LDM','J1_G3_ZBQ')
   --and machine='fjstj1ap01'
   --and s.inst_id = '1';
   order by o.object_name,s.username;
---------------------------------------------
--查看正在执行的sql：

SELECT p.sql_fulltext
  FROM gv$locked_object l, gv$session s, gv$sqlarea p
 WHERE l.session_id = s.sid
   and s.sql_id = p.sql_id;
-----------------------------------------------   
/******************************************
{2}使用sql tunning advisor 进行sql优化：
*******************************************/
declare
  lv_task_name varchar2(30);
begin
  --select instance_name,instance_number from v$instance;
  lv_task_name := DBMS_SQLTUNE.create_tuning_task(sql_id => 'a5wm7knru65x6',
                                                  scope       => 'comprehensive',
                                                  --修改时间60*5
                                                  time_limit  => '240',
                                                  task_name   => 'TMP_YZCWSBQC_RK',
                                                  description => 'task to tune a query');
  dbms_output.put_line(lv_task_name);
  DBMS_SQLTUNE.execute_tuning_task(task_name => 'TMP_YZCWSBQC_RK');
end;

--select * from dba_advisor_tasks where task_name='TMP_YZCWSBQC_RK';

select dbms_sqltune.report_tuning_task('TMP_YZCWSBQC_RK') from dual;


begin
  dbms_sqltune.accept_sql_profile(task_name  => 'TMP_DM2_LDCX_DJ_SWDJQKTJ',
                                  task_owner => 'SYSTEM',
                                  replace    => TRUE);
end;

begin
  dbms_stats.gather_table_stats(ownname          => 'J1_LDCX',
                                tabname          => 'TMP_LDCX_RD_ZDYZG_LSXX',
                                estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
                                method_opt       => 'FOR ALL COLUMNS SIZE AUTO');
  dbms_stats.gather_table_stats(ownname          => 'J1_LDCX',
                                tabname          => 'TMP_LDCX_ZDSYHJCZB_SRGM_GRQBSE',
                                estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
                                method_opt       => 'FOR ALL COLUMNS SIZE AUTO');
  dbms_stats.gather_table_stats(ownname          => 'J1_LDCX',
                                tabname          => 'TMP_LDCX_ZDSYHJCZB',
                                estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
                                method_opt       => 'FOR ALL COLUMNS SIZE AUTO');
end;

