prompt Created on 2016年5月10日 by xuclc
set feedback off

--define TABLESPACE_NAME=&1;
--define INDEX_TABLESPACE_NAME=&2;

-- ============================================================
--   Table: etl_tab_statistics_log
--   汉字名称: 表的统计信息锁定的日志
--   创建时间: 2016年5月11日
--   创建人： xuclc
-- ============================================================
prompt '表etl_tab_statistics_log本次新增'
prompt '创建前,etl_tab_statistics_log是否已创建，如创建，则先删除'

DECLARE
  LI_COUNT NUMBER(10); --表是否存在标志
  LVC_SQL  VARCHAR2(2000 CHAR);
BEGIN
    SELECT COUNT(*)
      INTO LI_COUNT
      FROM USER_TABLES
     WHERE TABLE_NAME = 'ETL_TAB_STATISTICS_LOG';
    IF LI_COUNT = 1 THEN
      LVC_SQL := 'TRUNCATE TABLE ETL_TAB_STATISTICS_LOG';
      EXECUTE IMMEDIATE LVC_SQL;
      LVC_SQL := 'DROP TABLE ETL_TAB_STATISTICS_LOG';
      EXECUTE IMMEDIATE LVC_SQL;
    END IF;
END;
/

create table ETL_TAB_STATISTICS_LOG
(
       owner      varchar2(50 char),
       table_name varchar2(50 char),
       exe_time   date,
       opt_type   varchar2(500 char),
       out_msg    varchar2(4000 char)
);

comment on table ETL_TAB_STATISTICS_LOG is '表的统计信息锁定的日志';
comment on column ETL_TAB_STATISTICS_LOG.owner is '用户名';
comment on column ETL_TAB_STATISTICS_LOG.table_name is '表名';
comment on column ETL_TAB_STATISTICS_LOG.exe_time is '执行时间';
comment on column ETL_TAB_STATISTICS_LOG.opt_type is '操作类型：收集统计信息or锁定统计信息';
comment on column ETL_TAB_STATISTICS_LOG.out_msg is '输出日志';

grant insert on ETL_TAB_STATISTICS_LOG to public;

set feedback on
prompt Done.

