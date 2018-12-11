select 'alter database datafile ''' || file_name || ''' autoextend off;'
  from dba_data_files
 where tablespace_name like 'TS%';

select 'alter database tempfile ''' || file_name || ''' autoextend off;'
  from dba_temp_files
 where tablespace_name like 'TS%';

select 'alter database datafile ''' || file_name || ''' autoextend off;'
  from dba_data_files
 where tablespace_name like 'TS%';

select 'alter database tempfile ''' || file_name || ''' autoextend off;'
  from dba_temp_files
 where tablespace_name like 'TS%';