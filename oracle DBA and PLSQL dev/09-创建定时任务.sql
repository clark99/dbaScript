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