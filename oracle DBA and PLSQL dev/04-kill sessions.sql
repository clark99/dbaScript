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
  
-- alter system kill session '594,49230' immediate;

SELECT p.sql_fulltext
  FROM gv$locked_object l, gv$session s, gv$sqlarea p
 WHERE l.session_id = s.sid
   and s.sql_id = p.sql_id;
   

