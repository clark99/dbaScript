1.

select owner, constraint_name, index_name, constraint_type, table_name
  from DBA_constraints
 where table_name = 'LDMT04_SB_GRSDS_SRNSMX'
   AND OWNER = 'J1_LDM'
   and constraint_type = 'P';  


2.
 select 'create unique index ' || A.index_name || ' on ' || A.table_name || '(' ||
        WMSYS.WM_CONCAT(a.column_name) || ')' ||
        ' parallel 16 tablespace TS_LDM_IDX nologging;'
   from dba_ind_columns A ,DBA_constraints B
  where A.table_owner = 'J1_LDM'
    AND A.TABLE_NAME = 'LDMT04_SB_GRSDS_SRNSMX'
    AND A.index_name = B.constraint_name
    AND A.table_owner=b.owner
    AND A.TABLE_NAME=B.TABLE_NAME
    AND b.constraint_type ='P'
  GROUP BY A.INDEX_NAME, A.TABLE_NAME;
--create unique index PK_LDMT04_SB_GRSDS_SRNSMX on LDMT04_SB_GRSDS_SRNSMX(XMXH,BDXH) parallel 16 tablespace TS_LDM_IDX nologging;
 

3.
 select 'alter table ' || a.table_name || ' add constraint ' || a.index_name ||
        ' primary key (' || wmsys.wm_concat(a.column_name) || ')' || ' ;'
   from dba_ind_columns A ,DBA_constraints B
  where A.table_owner = 'J1_LDM'
    AND A.TABLE_NAME = 'LDMT04_SB_GRSDS_SRNSMX'
    AND A.index_name = B.constraint_name
    AND A.table_owner=b.owner
    AND A.TABLE_NAME=B.TABLE_NAME
    AND b.constraint_type ='P'
  GROUP BY A.INDEX_NAME, A.TABLE_NAME;
--alter table LDMT04_SB_GRSDS_SRNSMX add constraint PK_LDMT04_SB_GRSDS_SRNSMX primary key (XMXH,BDXH) ;

4.
 select 'create bitmap index J1_LDM.' || a.index_name || ' on J1_LDM.' || a.table_name || '(' ||
         a.column_name || ')' ||
        ' local parallel 16 tablespace TS_LDM_IDX nologging;'
   from dba_ind_columns A ,DBA_constraints B
  where A.table_owner = 'J1_LDM'
    AND A.TABLE_NAME = 'LDMT04_SB_GRSDS_SRNSMX'
    AND A.index_name <> B.constraint_name
    AND A.table_owner=b.owner
    AND A.TABLE_NAME=B.TABLE_NAME
    AND b.constraint_type <>'P'


5.
 select 'alter table ' || table_name || ' add constraint ' || index_name ||
        ' primary key (' || wmsys.wm_concat(column_name) || ')' || ' ;'
   from dba_ind_columns
  where table_owner = 'J1_LDM'
    AND TABLE_NAME = 'LDMT02_JBXX_YZCWSBQC'
    AND index_name = 'PK_LDMT02_JBXX_YZCWSBQC'
  group by index_name, table_name;



6.

create unique index j1_ldm.PK_LDMT02_YE_SBXX on j1_ldm.LDMT02_YE_SBXX (NSRZHDAH, WSPZXH, YWXH, NSRSWJG_DM) Parallel 32 tablespace TS_LDM_IDX nologging;
--no parallel
 SELECT 'alter  index '||table_owner||'.' || index_name || ' noparallel;'
   FROM DBA_IND_COLUMNS
  WHERE table_owner = 'J1_LDM'
    AND TABLE_NAME = 'LDMT02_YE_SBXX';
--PK
alter table LDMT02_YE_SBXX                    
add constraint PK_LDMT02_YE_SBXX primary key(NSRZHDAH, WSPZXH, YWXH, NSRSWJG_DM);
