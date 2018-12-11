select a.tablespace_name, round(a.bytes / (1024 * 1024 * 1024)) total_GB
  from sys.sm$ts_avail a order by total_GB desc

select b.tablespace_name, round(b.bytes / (1024 * 1024 * 1024)) used_GB
  from sys.sm$ts_used b
  
select c.tablespace_name, round(c.bytes / (1024 * 1024 * 1024)) used_GB
  from sys.sm$ts_free c


select a.tablespace_name, round(a.bytes / (1024 * 1024 * 1024)) total_GB
  from sys.sm$ts_avail a order by total_GB desc
      
      --
 SELECT /*+parallel(32)*/
 a.tablespace_name,
        round(a.bytes / (1024 * 1024 * 1024)) total_GB,
        round(b.bytes / (1024 * 1024 * 1024)) used_GB,
        round(c.bytes / (1024 * 1024 * 1024)) free_GB,
        trunc((c.bytes * 100) / a.bytes) "% FREE "
   FROM sys.sm$ts_avail a, sys.sm$ts_used b, sys.sm$ts_free c
  WHERE a.tablespace_name = b.tablespace_name
    AND a.tablespace_name = c.tablespace_name
    and a.tablespace_name like '%DATA%'


       --temp
       SELECT * FROM DBA_TEMP_FILES;
       SELECT tablespace_name,
              round(tablespace_size / 1024 / 1024/1024,2) total_GB
         FROM DBA_TEMP_FREE_SPACE;

      SELECT sum(round(tablespace_size / 1024 / 1024/1024,2))
         FROM DBA_TEMP_FREE_SPACE;
        
      --undo
 select a.file_id,
        a.file_name,
        a.filesize as "文件大小",
        b.freesize as "剩余空间GB",
        (a.filesize - b.freesize) as "使用空间GB"
   from (select file_id,
                file_name,
                round(bytes / 1024 / 1024 / 1024) filesize
           from dba_data_files
          where tablespace_name like 'UNDO%') a,
        (select file_id, round(sum(dfs.bytes) / 1024 / 1024 / 1024) freesize
           from dba_free_space dfs
          where tablespace_name like 'UNDO%'
          group by file_id) b
  where a.file_id = b.file_id
  order by b.freesize desc
 
      
      --redo
      select * from v$log;
      