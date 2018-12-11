select owner, 
       constraint_name, 
       index_name, 
       constraint_type, 
       table_name
  from user_constraints
  where table_name='LDMT04_PGSJ_YYDJAPSHPGJL_ZSSQ'
  and constraint_type='P';
 --1	J1_LDM	LDMT04_PGSJ_YYDJAPSHPGJL	LDMT04_PGSJ_YYDJAPSHPGJL	P	LDMT04_PGSJ_YYDJAPSHPGJL_ZSSQ

select owner, 
       constraint_name, 
       column_name, 
       position
  from user_cons_columns a
 where position is not null
   and constraint_name = 'LDMT04_PGSJ_YYDJAPSHPGJL'
 order by constraint_name, position

--1	J1_LDM	LDMT04_PGSJ_YYDJAPSHPGJL	NSRZHDAH	1
--2	J1_LDM	LDMT04_PGSJ_YYDJAPSHPGJL	BDXH	2
--3	J1_LDM	LDMT04_PGSJ_YYDJAPSHPGJL	XMXH	3
--4	J1_LDM	LDMT04_PGSJ_YYDJAPSHPGJL	CZXH	4
--5	J1_LDM	LDMT04_PGSJ_YYDJAPSHPGJL	WSPZXH	5
--6	J1_LDM	LDMT04_PGSJ_YYDJAPSHPGJL	ZYWXH	6

select index_name, 
       table_name, 
       column_name, 
       column_position
  from user_ind_columns
 where index_name = 'LDMT04_PGSJ_YYDJAPSHPGJL'
 order by column_position
---
select index_name,
       index_type,
       table_owner,
       table_name,
       uniqueness,
       tablespace_name
  from user_indexes
 where index_name = 'LDMT04_PGSJ_YYDJAPSHPGJL'
   and uniqueness = 'UNIQUE'
   and index_type = 'NORMAL'
   
declare
  lvc_table           varchar2(50 char);
  lvc_sql             varchar2(1000 char);
  lvc_owner           varchar2(50 char); --用户名
  lvc_constraint_name varchar2(50 char); --约束名称
  lvc_index_name      varchar2(50 char); --唯一索引名称
  lvc_tablespace_name varchar2(50 char);
  type type_constraint is record(
    owner           varchar2(50 char),
    constraint_name varchar2(50 char),
    index_name      varchar2(50 char));
  obj_constraint type_constraint;

begin
  lvc_table := 'LDMT04_PGSJ_YYDJAPSHPGJL_ZSSQ';
  lvc_sql   := 'select owner, 
       constraint_name, 
       index_name
  from user_constraints
  where table_name=''' || lvc_table || '''
  and constraint_type=''P''';

  execute immediate lvc_sql
    into obj_constraint;

  lvc_sql := 'select tablespace_name
  from user_indexes
 where table_name=''' || lvc_table || '''
   and uniqueness = ''UNIQUE''
   and index_type = ''NORMAL''
   and table_owner=''' || obj_constraint.owner || '''
   and index_name=''' || obj_constraint.index_name || '''';

  execute immediate lvc_sql
    into lvc_tablespace_name;
  --dbms_output.put_line(lvc_tablespace_name);

  
end;
