prompt Created on 2016年5月10日 by xuclc
set feedback off

--define TABLESPACE_NAME=&1;
--define INDEX_TABLESPACE_NAME=&2;

-- ============================================================
--   Table: J1_dw.etl_dw_lock_list_minus
--   Table: J1_dw.etl_dw_lock_list
--   汉字名称: J1_dw用户过程中收集统计信息的表清单
--   创建时间: 2016年5月10日
--   创建人： xuclc
-- ============================================================
prompt '表etl_dw_lock_list_minus本次新增'
prompt '表etl_dw_lock_list本次新增'
prompt '创建前,etl_dw_lock_list_minus是否已创建，如创建，则先删除'
prompt '创建前,etl_dw_lock_list是否已创建，如创建，则先删除'
DECLARE
  LI_COUNT NUMBER(10); --表是否存在标志
  LVC_SQL  VARCHAR2(2000 CHAR);
BEGIN
    SELECT COUNT(*)
      INTO LI_COUNT
      FROM USER_TABLES
     WHERE TABLE_NAME = 'ETL_DW_LOCK_LIST_MINUS';
    IF LI_COUNT = 1 THEN
      LVC_SQL := 'TRUNCATE TABLE ETL_DW_LOCK_LIST_MINUS';
      EXECUTE IMMEDIATE LVC_SQL;
      LVC_SQL := 'DROP TABLE ETL_DW_LOCK_LIST_MINUS';
      EXECUTE IMMEDIATE LVC_SQL;
    END IF;
    
    SELECT COUNT(*)
      INTO LI_COUNT
      FROM USER_TABLES
     WHERE TABLE_NAME = 'ETL_DW_LOCK_LIST';
    IF LI_COUNT = 1 THEN
      LVC_SQL := 'TRUNCATE TABLE ETL_DW_LOCK_LIST';
      EXECUTE IMMEDIATE LVC_SQL;
      LVC_SQL := 'DROP TABLE ETL_DW_LOCK_LIST';
      EXECUTE IMMEDIATE LVC_SQL;
    END IF;
    
END;
/

create table etl_dw_lock_list_minus as 
select distinct case
                  when substr(trim(text), 1, 3) = 'lvc' then
                   substr(text,
                          instr(t.text, ',''', 1, 1) + 3,
                          instr(t.text, ',', 1, 2) -
                          instr(t.text, ',''', 1, 1) - 5)
                  else
                   substr(text,
                          instr(t.text, ',''', 1, 1) + 2,
                          instr(t.text, ',', 1, 2) -
                          instr(t.text, ',''', 1, 1) - 3)
                end as lock_tab
  from user_source t
 WHERE upper(t.text) like '%DBMS_STATS.GATHER_TABLE_STATS%'
   and t.name <> 'PKG_3_DW1_SB'
union
select distinct substr(t.text,
                       instr(t.text, '''', 1, 1) + 1,
                       instr(t.text, '''', 1, 2) - instr(t.text, '''', 1, 1) - 1) as lock_tab
  from user_source t, user_source t1
 where t.name = t1.name
   and t1.name = 'PKG_3_DW1_SB'
   and upper(t1.text) like '%DBMS_STATS.GATHER_TABLE_STATS%'
   and t.line = t1.line + 1;
   
    comment on table etl_dw_lock_list_minus is 'J1_dw用户过程中收集统计信息的表清单';
    comment on column etl_dw_lock_list_minus.lock_tab
    is '表名';

create table etl_dw_lock_list as
select distinct substr(unit_code, instr(unit_code, '.P_') + 3) as lock_tab /*,
                substr(unit_id, 1, instr(unit_id, '.') - 1) as unit_id*/
  from etl_meta_unit
 where param_table is null
   and unit_id not in (select unit_id from etl_unit_minus)
   and substr(unit_code, instr(unit_code, '.P_') + 3) like 'D%'
   and substr(unit_code, instr(unit_code, '.P_') + 3) not in
       (select lock_tab from etl_dw_lock_list_minus) 
union
select param_table as lock_tab
  from etl_meta_unit
 where param_table is not null;
 
comment on table etl_dw_lock_list is 'J1_dw用户锁定收集统计信息的表清单'; 
comment on column etl_dw_lock_list.lock_tab is '表名';

set feedback on
prompt Done.

