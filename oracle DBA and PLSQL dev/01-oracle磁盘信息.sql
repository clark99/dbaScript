--1.查看数据库信息
	--数据库信息
    select instance_number,instance_name,host_name from v$instance;
    select name,value,display_value from v$parameter where name in('remote_listener','local_listener');
    select dbid,name,db_unique_name,created,log_mode,platform_name from v$database;
	--内存分配情况
    select * from v$sgastat;
    select * from v$pgastat;


-----------------------------------------------
--step:01 回收站
-----------------------------------------------
--sys as sysdba用户执行
 purge dba_recyclebin;
--or 各个用户执行
purge recyclebin;
---------------------------------------------
SELECT a.tablespace_name,
       round(a.bytes / (1024 * 1024 * 1024)) total_GB,
       round(b.bytes / (1024 * 1024 * 1024)) used_GB,
       round(c.bytes / (1024 * 1024 * 1024)) free_GB 
  FROM sys.sm$ts_avail a, sys.sm$ts_used b, sys.sm$ts_free c
 WHERE a.tablespace_name = b.tablespace_name
   AND a.tablespace_name = c.tablespace_name
   and (a.tablespace_name LIKE 'TS_ZBQ%' OR
       a.tablespace_name LIKE 'TS_LDM%' OR a.tablespace_name LIKE 'TS_DW%' OR
       a.tablespace_name LIKE 'TS_LDCX%')
 order by a.tablespace_name desc;

或者
 select a.tablespace_name,
        a.tablespacesize as total_GB,
        b.freesize as free_GB,
        (a.tablespacesize - b.freesize) as used_GB
   from (select tablespace_name,
                round(sum(bytes) / 1024 / 1024 / 1024) as tablespacesize
           from dba_data_files
          where tablespace_name IN ('TS_DW_DATA','TS_DW_IDX')
          group by tablespace_name) a,
        (select tablespace_name,
                round(sum(dfs.bytes) / 1024 / 1024 / 1024) freesize
           from dba_free_space dfs
          where tablespace_name in ('TS_DW_DATA','TS_DW_IDX')
          group by tablespace_name) b
  where a.tablespace_name=b.tablespace_name
  order by a.tablespacesize desc;


--asm磁盘组使用情况
select group_number,
       name,
       round(total_Mb / 1024, 2) total_GB,
       round(free_mb / 1024, 2) free_GB
  from v$asm_diskgroup;

---------------------------------------------
--临时表空间查看
-----------------------------------------------       
SELECT file_id, tablespace_name,file_name, blocks, user_blocks, bytes, user_bytes
  FROM DBA_TEMP_FILES;

SELECT tablespace_name,
round(tablespace_size / 1024 / 1024 / 1024, 2) total_GB
FROM DBA_TEMP_FREE_SPACE;


alter database tempfile '+DATA/sxltj1dw/tempfile/ts_zbq_tmp.285.921078955' resize 10M;
alter database tempfile '+DATA/sxltj1dw/tempfile/ts_dw_tmp.287.921078963' resize 10M;

--select * from dba_tablespaces;
--reuslt:
-----------------------------------------------  
select a.file_id,
       a.file_name,
       a.filesize as "文件大小",
       b.freesize as "剩余空间GB",
       (a.filesize - b.freesize) as "使用空间GB"
  from (
       select file_id,
               file_name,
               round(bytes / 1024 / 1024 / 1024) filesize
          from dba_data_files
         where tablespace_name = 'TS_LDM_IDX'
         ) a,
       (
       select file_id, round(sum(dfs.bytes) / 1024 / 1024 / 1024) freesize
          from dba_free_space dfs
         where tablespace_name = 'TS_LDM_IDX'
         group by file_id
         ) b
 where a.file_id = b.file_id
 order by b.freesize desc;
 
or

 select a.tablespace_name,
        a.tablespacesize as total_GB,
        b.freesize as free_GB,
        (a.tablespacesize - b.freesize) as used_GB
   from (select tablespace_name,
                round(sum(bytes) / 1024 / 1024 / 1024) as tablespacesize
           from dba_data_files
          where tablespace_name IN ('TS_LDM_DATA','TS_DW_DATA','TS_LDCX_DATA')
          group by tablespace_name) a,
        (select tablespace_name,
                round(sum(dfs.bytes) / 1024 / 1024 / 1024) freesize
           from dba_free_space dfs
          where tablespace_name in ('TS_LDM_DATA','TS_DW_DATA','TS_LDCX_DATA')
          group by tablespace_name) b
  where a.tablespace_name=b.tablespace_name
  order by a.tablespacesize desc;

-----------------------------------------------
--step:--05 收缩表空间
-----------------------------------------------  
ALTER DATABASE DATAFILE '+DATA/sxltj1dw/datafile/ts_ldm_idx.296.921775159' RESIZE 20G;


--2.查看DB_LINKS
select * from dba_db_links where owner='PUBLIC'

--3.查看同义词
SELECT SYNONYM_NAME
FROM DBA_SYNONYMS
WHERE OWNER IN ();

-- 4.drop table --慎用
SELECT 'DROP TABLE J1_G3_ZBQ.' || TABLE_NAME || ' purge;'
FROM dba_tables
WHERE OWNER IN ();