/**********************************************
使用oracle sql优化指导器-oracle sql tuning advisor：
***********************************************/
--[1]启动sql tuning advisor：
     --(1)获得sql_id--根据查询锁的sql中的sql_id
     --(2)需要有相关的权限
declare
  lv_task_name varchar2(30);
begin
  lv_task_name := DBMS_SQLTUNE.create_tuning_task(sql_id => 'a5wm7knru65x6',
                                                  scope       => 'comprehensive',
                                                  time_limit  => '300', --修改时间5分钟=300
                                                  task_name   => 'tuning_TMP_YZCWSBQC_RK',--修改task_name,创建task
                                                  description => 'task to tune a query');
  dbms_output.put_line(lv_task_name);
  DBMS_SQLTUNE.execute_tuning_task(task_name => 'tuning_TMP_YZCWSBQC_RK');
end;
--[2]查询sql tuning advisor任务执行情况
select * from dba_advisor_tasks where task_name='tuning_TMP_YZCWSBQC_RK';
--[3]查看sql优化指导报告
select dbms_sqltune.report_tuning_task('tuning_TMP_YZCWSBQC_RK') from dual;
--[4]执行sql优化指导，创建sql profile
  --Recommendation (estimated benefit: 47.99%)
begin
  dbms_sqltune.accept_sql_profile(task_name  => 'tuning_TMP_YZCWSBQC_RK',
                                  task_owner => 'SYSTEM',
                                  replace    => TRUE);
end;
/************************************************
查看存在性能问题的表：
*************************************************/
--[2]查看锁
SELECT distinct s.username,
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
   and s.username in ('J1_DW', 'J1_LDCX', 'J1_LDM', 'J1_G3_ZBQ')
 --and machine='fjstj1ap01'
 --and s.inst_id = '1';
 order by o.object_name, s.username;

--[2]查看正在执行的sql：
SELECT p.sql_fulltext
  FROM gv$locked_object l, gv$session s, gv$sqlarea p
 WHERE l.session_id = s.sid
   and s.sql_id = p.sql_id;

/**********************************************************
创建索引-优化高阶加工
**********************************************************/
1.
[过程]PKG_3_CXTJ_RD_DW.P_DM2_RD_SDSSZDJQKTJ
[表]TMP_ETL_DW1_QGJ_FIRSTLAST
[优化]
  Recommendation (estimated benefit: 99.99%)
------------------------------------------
create index J1_LDM.IDX$$_02200001 on J1_LDM.LDMT04_SB_SFTYSBB("YXBZ") tablespace ts_ldm_data parallel 16;
[优化2]
  Recommendation (estimated benefit: 98.94%)
  ------------------------------------------
create index J1_LDM.IDX$$_024A0001 on J1_LDM.LDMT02_JCXY_SZDJXXB("NSRZHDAH","ZSXM_DM") tablespace ts_ldm_idx parallel 32;
create index J1_DW.IDX$$_024A0002 on J1_DW.DW0_DJ_NSZHDJXX("TJRQ","SJJGPD","DJZCLX_DM") tablespace ts_ldm_idx parallel 32;
create index J1_DW.IDX$$_024A0003 on J1_DW.DW0_DJ_NSRZHSX("TJRQ","SJJGPD","NSRZHDAH","YGZLX_DM") tablespace ts_ldm_idx parallel 32;

2.
[表]T1_SB_FJSF_Y
[优化]
 Recommendation (estimated benefit: 86.36%)
  ------------------------------------------
create index J1_LDM.IDX$$_02240001 on  J1_LDM.LDMT02_YE_SBXX("NSRZHDAH",SUBSTR("SBRQ",1,6)||'01') tablespace ts_ldm_idx parallel 32;

3.
[过程]PKG_3_DM0.P_DM0_SB_YZCWSBQC
[表]TMP_YZCWSBQC_RK
[优化]
  Recommendation (estimated benefit: 94.21%)
  ------------------------------------------
 create index J1_LDM.IDX$$_024D0001 on J1_LDM.LDMT02_YE_SFXX("NSRZHDAH","ZSXM_DM","ZSPM_DM","SSSQQ","SSSQZ") tablespace ts_ldm_idx parallel 32 local;
 drop index j1_ldm.IDX_T02_YE_SFXX_NSRZHDAH;

4.
[表]TMP_YZCWSBQC_SB
[优化]
  Recommendation (estimated benefit: 86.89%)
  ------------------------------------------
 create index J1_LDM.IDX$$_024E0001 on J1_LDM.LDMT02_YE_SBXX("ZFRQ","SBQX") tablespace ts_ldm_idx parallel 32 local;

5.
[过程]PKG_3_DM0.P_DM0_SB_YZCWSBQC
[表]TMP_JBXX_YZCWSBQC
[优化]
  Recommendation (estimated benefit: 99.99%)
  ------------------------------------------
create index J1_LDM.IDX$$_02510001 on J1_LDM.LDMT02_JBXX_YZCWSBQC("ZFRQ","SBQX") tablespace ts_ldm_idx parallel 23;

6.
[过程]4031.02  PKG_3_DM0_SB.P_DM0_SB_ZDSYSBQKQC
[表]DM0_SB_ZDSYSBQKQC 
[优化]
  Recommendation (estimated benefit: 89.6%)
  ----------------------------------------
create index J1_DW.IDX$$_025F0001 on J1_DW.DM0_SB_LFSBNSRQC("TJRQ") tablespace ts_dw_idx parallel 32;

[优化2]
drop index J1_DW.IDX_DM0_SB_YZCWSBQC_TJRQ8824;
create index j1_dw.I_DM0_SB_YZCWSBQC_3 on J1_DW.DM0_SB_YZCWSBQC("TJRQ","SJJGPD","NSRSWJG_DM") tablespace ts_dw_idx parallel 32;
create index j1_dw.I_DM0_SB_LFSBNSRQC_4 on J1_DW.DM0_SB_LFSBNSRQC("NSRZHDAH","ZSXM_DM","SSSQQ","SSSQZ") tablespace ts_dw_idx parallel 32;

7.
[表]DM2_ZS_ZDSYQYRKHXS
[优化]
Recommendation (estimated benefit: 88.41%)
------------------------------------------
create index J1_DW.IDX$$_026F0001 on J1_DW.DM0_ZS_NSRRKSRYTJ("SJJGPD") tablespace ts_dw_idx parallel 32;


/**********************************************************
排查tjrq sjjgpd缺失索引-优化高阶加工
**********************************************************/
--[1]表清单：创建dw_tables --667
create table dw_tables as 
SELECT distinct nvl(b.param_table,
                    substr(b.unit_code, instr(b.unit_code, '.P_') + 3)) as dw_table
  FROM J1_DW.ETL_META_UNIT B
--表清单2-排除DW1-DW3的表 --556 --dw1,dw2,dw3不考虑sjjgdp索引,dm0,dm2才创建sjjgpd索引
create table dw_tables_dm
as
SELECT distinct substr(b.unit_code, instr(b.unit_code, '.P_') + 3) as dw_table
  FROM J1_DW.ETL_META_UNIT B
 where b.param_table is null
--[2]查看'TJRQ', 'SJJGPD'索引的创建情况
select * from 
(select distinct T.table_owner,
       t.table_name,
       COUNT(INDEX_NAME) OVER(PARTITION BY TABLE_NAME) as bz
  from dba_ind_columns T
 where TABLE_owner = 'J1_DW'
   AND COLUMN_NAME IN ('TJRQ', 'SJJGPD')
   )
 where bz=2;
--[3]查询'TJRQ', 'SJJGPD'的组合索引情况：
select index_name,count(*)
  from dba_ind_columns T
 where TABLE_owner = 'J1_DW'
   AND COLUMN_NAME IN ('TJRQ', 'SJJGPD')
   group by index_name
   having count(*) >1
 --result 
I_DM0_SB_XWQY_2015YH_TJRQ	2
IDX_DM0_SB_SBSETJ_TJRQ	2
IDX_SB_QYSDSHDZST_TJRQ	2
PK_DM0_SB_QYSDSZDJMS	2


--[3]综合查询--分别创建

--a.所有表(dw_tables)创建tjrq索引
SELECT 'CREATE BITMAP INDEX J1_DW.I_' || DW_TABLE || '_TJRQ ON J1_DW.' ||
       DW_TABLE || '(TJRQ) TABLESPACE TS_DW_IDX'
  FROM DW_TABLES a
 WHERE NOT EXISTS (select 1
          from dba_ind_columns T
         where TABLE_owner = 'J1_DW'
           AND COLUMN_NAME = 'TJRQ'
           AND T.table_name = a.dw_table);
           
--dm0,dm2表(dw_tables_dm)创建sjjgdp索引
SELECT 'CREATE BITMAP INDEX J1_DW.I_' || DW_TABLE || '_SJJGPD ON J1_DW.' ||
       DW_TABLE || '(SJJGPD) TABLESPACE TS_DW_IDX'
  FROM dw_tables_dm a
 WHERE NOT EXISTS (select 1
          from dba_ind_columns T
         where TABLE_owner = 'J1_DW'
           AND COLUMN_NAME = 'SJJGPD'
           AND T.table_name = a.dw_table);


/**********************************************************
添加hints暗示-优化高阶加工
**********************************************************/

--[1]去轨迹-DW2
--a.过程：PKG_3_DW2_COMMON.P_DW2_TYZH_SJSC_LASTFIRST
--b.处理：
#line 1260           lvc_sql_sjsc_merge_last := 'merge/*+parallel(4) leading(B) use_hash(B,A)*/ into '||avc_target_tab||' B
#line 1261                                     using (SELECT /*+parallel(4) leading(B) use_hash(B,A)*/A.NSRZHDAH NSRZHDAH,
'


--[2]PKG_3_CXTJ_DJ_DW3.P_DW3_DJ_GLNSR
#line 68                 select /*+use_hash(B,C) index(C I_DW0_DJ_NSRZHSX_3) index(B I_DW0_DJ_NSZHDJXX_3)*/'''||lvc_tjrq||''' TJRQ,



--[3]PKG_3_DM1_SB_QGJ_DW.P_DM0_SB_LXLSRXGMNSRQC
#line 256       LVC_SQL := ' MERGE /*+ use_hash(A,B)*/INTO DM0_SB_LXLSRXGMNSRQC A
'
#line 416        FROM (SELECT /*+parallel(4) index(A I_DW1_SB_ZZS_XGM_6) index_rs(A I_DW1_SB_ZZS_XGM_NSRSWJG_DM) use_hash(A,B)*/ A.TJRQ,

--[4]PKG_DM0_TJL.P_DM0_WZ_YQSBQC
#line 513             SELECT /*+ materialize PARALLEL(4) leading(B) use_hash(B,A)*/
#line 529             SELECT /*+ materialize PARALLEL(4) leading(H) use_hash(A,H)*/
#line 542             SELECT /*+ materialize PARALLEL(4) leading(c) use_hash(c,b,a)*/
#line 573             (SELECT /*+ materialize PARALLEL(4) */DISTINCT A.NSRSBH
#line 723            SELECT /*+ PARALLEL(4) use_hash(b,a,h) leading(b) index(a,IDX_LDMT02_JBXX_YZCWSBQC_TJND) index(a,IDX_LDMT02_JBXX_YZCWSBQC_TJYF) index(h,IDX_FZ_WFWZXX_WFSD_DM)*/

--[5]PKG_3_DJ_SZHY.P_DM0_DJ_SZHYYZYMNSRQC
#line 193                select/*+parallel(8) leading(A) use_hash(A,B)*/

--[6] PKG_3_DW0_DJ.P_DW0_DJ_HZNSQYBA A.B两个表笛卡尔积处理：

#line 173                                 AND ((B.SJJZRQ >= ''' || LVC_SJJGRQ_Q || '''
#line 174                                 AND B.SJJZRQ <= ''' || LVC_SJJGRQ_Z || ''')
#line 175                                 OR (C.SJJZRQ >= ''' || LVC_SJJGRQ_Q || '''
#line 176                                 AND C.SJJZRQ <= ''' || LVC_SJJGRQ_Z || '''))


           
/**********************************************************
创建sql profile-优化高阶加工
**********************************************************/
1.
[过程]PKG_3_DM0_SB.P_DM0_SB_LXLFSBNSRQC
[表]TMP_SB_LFSBNSRQC
[优化]
2- SQL Profile Finding (see explain plans section below)
--------------------------------------------------------
  A potentially better execution plan was found for this statement.
  Recommendation (estimated benefit: 92.89%)
  ------------------------------------------
begin
  dbms_sqltune.accept_sql_profile(task_name  => 'TMP_SB_LFSBNSRQC',
                                  task_owner => 'SYSTEM',
                                  replace    => TRUE);
end;
--优化之后执行计划：--全表扫描，不走索引
2- Using SQL Profile
--------------------
Plan hash value: 2621270583
-----------------------------------------------------------------------
| Id  | Operation          | Name             | Rows  | Bytes | Cost  |
-----------------------------------------------------------------------
|   0 | INSERT STATEMENT   |                  |     1 |     6 | 39419 |
|   1 |  LOAD AS SELECT    | TMP_SB_LFSBNSRQC |       |       |       |
|*  2 |   TABLE ACCESS FULL| DM0_SB_LFSBNSRQC |     1 |     6 | 39419 |
-----------------------------------------------------------------------

2.
[过程] PKG_3_CXTJ_DJ_DW.P_DM0_DJ_FZCHQKQC
[表]DM0_DJ_FZCHQKQC --d5rhppkfhfhax
[优化]
3- SQL Profile Finding (see explain plans section below)
--------------------------------------------------------
  Recommendation (estimated benefit: 99.99%)
------------------------------------------
begin
  dbms_sqltune.accept_sql_profile(task_name  => 'DM0_DJ_FZCHQKQC',
                                  task_owner => 'SYSTEM',
                                  replace    => TRUE);
end;

3.
[表]DM0_ZGZKFX_NSRCXSBHS 
[优化]
1- SQL Profile Finding (see explain plans section below)
--------------------------------------------------------
  Recommendation (estimated benefit: 99.99%)
  ------------------------------------------
begin
  dbms_sqltune.accept_sql_profile(task_name =>
            'DM0_ZGZKFX_NSRCXSBHS', task_owner => 'SYSTEM', replace => TRUE);
end;
----执行计划：
2- Using SQL Profile
--------------------
Plan hash value: 3588118733
-----------------------------------------------------------------------------------------------------------------------
| Id  | Operation                      | Name                 | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------------
|   0 | INSERT STATEMENT               |                      |     1 |   563 |  5359   (3)| 00:01:37 |       |       |
|   1 |  LOAD AS SELECT                | DM0_ZGZKFX_NSRCXSBHS |       |       |            |          |       |       |
|   2 |   HASH GROUP BY                |                      |     1 |   563 |  5359   (3)| 00:01:37 |       |       |
|*  3 |    HASH JOIN RIGHT OUTER       |                      |  1407K|   755M|  5279   (1)| 00:01:36 |       |       |
|   4 |     PARTITION LIST SINGLE      |                      |  4604 |   359K|  5268   (1)| 00:01:35 |   KEY |   KEY |
|*  5 |      TABLE ACCESS FULL         | DM0_DJ_NSRQC         |  4604 |   359K|  5268   (1)| 00:01:35 |   KEY |   KEY |
|*  6 |     TABLE ACCESS BY INDEX ROWID| LDMT02_YE_SBXX       |  1407K|   648M|     2   (0)| 00:00:01 |       |       |
|*  7 |      INDEX RANGE SCAN          | IDX$$_024E0001       |     1 |       |     2   (0)| 00:00:01 |       |       |
-----------------------------------------------------------------------------------------------------------------------




