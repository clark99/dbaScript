begin
  sys.dbms_job.submit(job => :job,
                      what => 'EMD_MAINTENANCE.EXECUTE_EM_DBMS_JOB_PROCS();',
                      next_date => to_date('13-07-2016 15:58:04', 'dd-mm-yyyy hh24:mi:ss'),
                      interval => 'sysdate + 1 / (24 * 60)');
  commit;
end;

begin
  sysman.EMD_MAINTENANCE.remove_em_dbms_jobs;
end;


/**************************
关闭OEM定时dbms_jobs
****************************/
---登录SYSMAN/oracle123用户执行：
select job,
       log_user,
       schema_user,
       next_date,
       broken,
       failures,
       interval,
       what
  from dba_jobs
 where log_user = 'SYS'
   and BROKEN = 'N';

(1)
--3  EMD_MAINTENANCE.EXECUTE_EM_DBMS_JOB_PROCS();
declare
begin
  sys.dbms_job.broken(job => 1, broken => TRUE);
  commit;
end;
/**************************
关闭SYS定时dbms_scheduler
****************************/
select owner,
       job_name,
       job_action,
       comments,
       schedule_name,
       program_name,
       enabled,
       state,
       run_count,
       repeat_interval,
       next_run_date
  from dba_scheduler_jobs
 where enabled = 'TRUE'
 AND OWNER<>'J1_CXTJ'
 
(1)
declare
  -- force boolean := sys.diutil.int_to_bool(:force);
  -- Disable a program, chain, job, window or window_group.
  -- The procedure will NOT return an error if the object was already disabled.
begin
  --dbms_scheduler.stop_job('SPOT.QUEST_PPCM_JOB_PM_1');
  dbms_scheduler.disable('PURGE_LOG',TRUE);
  dbms_scheduler.disable('DRA_REEVALUATE_OPEN_FAILURES',TRUE);
  dbms_scheduler.disable('BSLN_MAINTAIN_STATS_JOB',TRUE);                                                 
end;
