--
----lengthb(str)=54
--PKG_3_BBTJ_SB.P_DM0_SB_FCSQC  count(DW3_SB_FCS_Y)： 1
-- create table etl_unit_xuclc(xh char(10 char),table_name char(30 char),unit_id varchar2(30 char),unit_code varchar2(60 char),unit_group varchar2(20 char));
declare
  cursor cur is
    select distinct unit_id,
                    upper(substr(unit_code, 1, instr(unit_code, '.') - 1)) as p_name,
                    upper(substr(unit_code, instr(unit_code, '.') + 1)) as proc_name
      from etl_meta_unit
     where unit_id in (select a.parentunit_id --父节点
                         from J1_DW.etl_meta_unit a, J1_DW.etl_unit_xuclc b
                        where a.unit_id = b.unit_id);
  max_line      number;
  mine_line     number;
  lvc_p_name    varchar2(200 char);
  lvc_proc_name varchar2(200 char);
  lvc_sql       varchar2(2000 char);
  lvc_text      varchar2(2000 char);
  lvc_a         varchar2(30 char);
  LVC_UNIT_ID   varchar2(30 char);

begin
   
  execute immediate 'truncate table etl_unit_from_xuclc';

  for mycur in cur loop
    begin
      lvc_p_name    := mycur.p_name;
      lvc_proc_name := mycur.proc_name;
    
      lvc_sql := 'select min(line)
  from user_source
 where name = ''' || mycur.p_name || '''
   and type=''PACKAGE BODY''
   and text like ''%' || mycur.proc_name || '%''';
      execute immediate lvc_sql
        into mine_line;
      --print_proc(mine_line);
    
      lvc_sql := 'select min(line)
  from user_source
 where name = ''' || mycur.p_name || '''
   and type=''PACKAGE BODY''
   and line >' || mine_line || '+10
   and (upper(text) like ''%PROCEDURE%'')';
      execute immediate lvc_sql
        into max_line;
      --print_proc(max_line);
    
      lvc_sql := 'select substr(UPPER(TRIM(TEXT)),6), substr(UPPER(TRIM(TEXT)),6,(instr(UPPER(TRIM(TEXT)),'','')-7))
  from user_source
 where name = ''' || mycur.p_name || '''
   and type = ''PACKAGE BODY''
   and line >=' || mine_line || '
   and line <=' || max_line || '
   and (upper(text) like ''%FROM%'') ';
      execute immediate lvc_sql
        into lvc_text,lvc_a;
    
      lvc_sql:='select unit_id from j1_dw.etl_meta_unit where param_table like ''%'||trim(lvc_a)||'''';
      execute immediate lvc_sql into LVC_UNIT_ID;
      --if lvc_count > 0 then
        --print_proc('('||mycur.unit_id||')'||lvc_p_name || '.' || lvc_proc_name ||
        --           ' ' || lvc_text);
        --drop table etl_unit_from_xuclc;
       --create table etl_unit_from_xuclc(unit_id varchar2(50 char),package_name varchar2(50 char),procedure_name varchar2(50 char),from_text varchar2(500 char),A_table varchar2(30 char),A_UNIT_ID VARCHAR2(30 CHAR));
        insert into etl_unit_from_xuclc values (mycur.unit_id,lvc_p_name,lvc_proc_name,lvc_text,lvc_a,LVC_UNIT_ID);
        commit;
      
      --end if;
    exception
      when others then
        print_proc(lvc_p_name || '.' || lvc_proc_name);
    end;
  end loop;
end;
