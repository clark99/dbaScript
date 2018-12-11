declare
  lvc_ldmtab     varchar2(50 char);
  lvc_ldmsql     varchar2(2000 char);
  lvc_ldmcount   number;
  lvc_hxsql      varchar2(2000 char);
  lvc_hxcount    number;
  lvc_radio      number;
  lvc_source_tab varchar2(200 char);
  /*  lvc_target_tab varchar2(200 char);
  */
  cursor cur is
    SELECT distinct 'LDM' || SUBSTR(a.target_tab, 4) as ldm_tab,
                    'SELECT /*+parallel(16)*/ COUNT(*) FROM J1_LDM.' ||
                    'LDM' || SUBSTR(a.target_tab, 4) AS EXEC_SQL_01,
                    'SELECT /*+parallel(16)*/count(*) FROM HX_ZGXT.' ||
                    SUBSTR(A.SOURCE_TAB, 1, LENGTH(SOURCE_TAB) - 2) AS EXEC_SQL_02,
                    SUBSTR(A.SOURCE_TAB, 1, LENGTH(SOURCE_TAB) - 2) as source_tab
      FROM J1_G3_ZBQ.ETL_TABLE_MAPPING A
     WHERE 'LDM' || SUBSTR(a.target_tab, 4) IN
           ('LDMT02_YE_SBXX',
            'LDMT02_YE_SFXX',
            'LDMT02_JBXX_YZCWSBQC',
            'LDMT02_YE_TTXX',
            'LDMT02_YE_KDTSKXX',
            'LDMT02_YE_ZQJMXX',
            'LDMT02_YE_ZZSLDSK',
            'LDMT02_YE_ZQJMXX',
            'LDMT02_YE_JSZNJ',
            'LDMT02_YE_YJSKXX',
            'LDMT02_JCXY_DQDEHD',
            'LDMT02_JCXY_JMQYNSHD',
            'LDMT02_JCXY_SZDJXXB',
            'LDMT02_JBXX_ZRR',
            'LDMT02_JCFZ_JCAJXX',
            'LDMT02_ZGXY_RDNSRZGXX',
            'LDMT02_ZGXY_YH_SSJMSPXX',
            'LDMT02_JBXX_NSZHDJXX',
            'LDMT02_JBXX_NSRZTBG',
            'LDMT04_SB_ZZSSBB_YBNSR',
            'LDMT04_SB_ZZSNSSBB_XGMNSR',
            'LDMT04_SB_ZZS_YGZXGMNSRSBB',
            'LDMT04_SB_ZZS_FB1_YGZBQXSMX',
            'LDMT04_SB_ZZS_FB2_YGZBQJXMX',
            'LDMT04_SB_SDSYSBB_A',
            'LDMT04_SB_SDSYSBB_B',
            'LDMT04_SB_14ND_SDSNDNSSBBAL',
            'LDMT04_SB_XFSNSSBB',
            'LDMT04_SB_XFSNSSB_ZB',
            'LDMT04_SB_QYSDSYJD_A_GDZCJSZJB'
            )
       AND SUBSTR(A.SOURCE_TAB, LENGTH(SOURCE_TAB)) = 'A'
       and length(source_tab)<50
     order by ldm_tab;

begin

  dbms_output.put_line( /*rpad('target_tab',40,' ')||*/rpad('table_name',
                            40,
                            ' ') ||
                       rpad('| ldm_count',
                            22,
                            ' ') ||
                       rpad('| hx_table_name',
                            42,
                            ' ') ||
                       rpad('| hx_count',
                            22,
                            ' ') ||
                       rpad('| LDM差值',
                            20,
                            ' '));
  dbms_output.put_line(rpad('-', 150, '-'));
  for mycur in cur loop
  
    lvc_ldmtab     := mycur.ldm_tab;
    lvc_ldmsql     := mycur.EXEC_SQL_01;
    lvc_hxsql      := mycur.EXEC_SQL_02;
    lvc_source_tab := mycur.source_tab;
    /*  lvc_target_tab:=mycur.target_tab;*/
    begin
    execute immediate lvc_ldmsql
      into lvc_ldmcount;
    execute immediate lvc_hxsql
      into lvc_hxcount;
    lvc_radio := lvc_hxcount - lvc_ldmcount;
    dbms_output.put_line( /*rpad(lvc_target_tab,40,' ')||'| '||*/rpad(lvc_ldmtab,
                              40,
                              ' ') || '| ' ||
                         rpad(lvc_ldmcount,
                              20,
                              ' ') || '| ' ||
                         rpad(lvc_source_tab,
                              40,
                              ' ') || '| ' ||
                         rpad(lvc_hxcount,
                              20,
                              ' ') || '| ' ||
                         rpad(lvc_radio,
                              20,
                              ' '));
  exception
    when others then
      dbms_output.put_line(lvc_ldmtab||lvc_hxsql);
  end;
  end loop;
end;

table_name                              | ldm_count           | hx_table_name                           | hx_count            | LDM差值           
------------------------------------------------------------------------------------------------------------------------------------------------------
LDMT02_JBXX_NSRZTBG                     | 23330914            | DJ_NSRZTBGXXB                           | 23330914            | 0                   
LDMT02_JBXX_NSZHDJXX                    | 1179008             | DJ_NSRXX                                | 1179010             | 2                   
LDMT02_JBXX_YZCWSBQC                    | 64425224            | SB_YSBTJ                                | 64425224            | 0                   



declare
  lvc_ldmtab     varchar2(50 char);
  lvc_ldmsql     varchar2(2000 char);
  lvc_ldmcount   number;
  lvc_hxsql      varchar2(2000 char);
  lvc_hxcount    number;
  lvc_radio      number;
  lvc_source_tab varchar2(200 char);
  lvc_unit_id    varchar2(50 char);
  cursor cur is
    SELECT B.unit_id,
           nvl(b.param_table,
               substr(b.unit_code, instr(b.unit_code, '.P_') + 3)) as tab_name,
           'SELECT /*+parallel(16)*/ COUNT(*) FROM J1_DW.' ||
           nvl(b.param_table,
               substr(b.unit_code, instr(b.unit_code, '.P_') + 3)) AS EXEC_SQL_01,
           'SELECT /*+parallel(16)*/count(*) FROM J1_DW.' ||
           nvl(nvl(a.param_table,
               substr(a.unit_code, instr(a.unit_code, '.P_') + 3)),
               nvl(b.param_table,
               substr(b.unit_code, instr(b.unit_code, '.P_') + 3))
               ) AS EXEC_SQL_02,
           nvl(
           nvl(a.param_table,
               substr(a.unit_code, instr(a.unit_code, '.P_') + 3)),
               '不存在源表'
               ) as source_tab
      FROM J1_DW.ETL_META_UNIT B, J1_DW.ETL_META_UNIT A
     WHERE a.unit_id(+) = b.parentunit_id
       and B.unit_id in ('9901.02',
                         '9902.02',
                         '100099.01',
                         '31801.01',
                         '31804.01',
                         '31805.01',
                         '31806.01',
                         '31808.01',
                         '31810.01',
                         '31811.01',
                         '31812.01',
                         '31813.01',
                         '31814.01',
                         '31815.01',
                         '31816.01',
                         '31817.01',
                         '31818.01',
                         '35801.01',
                         '35802.01',
                         '35803.01',
                         '35804.01',
                         '35805.01',
                         '35806.01',
                         '35807.01',
                         '35808.01',
                         '100100.05',
                         '100101.05',
                         '100102.05',
                         '100103.05',
                         '100104.05',
                         '100105.05',
                         '100106.05',
                         '100107.05',
                         '100108.05',
                         '100109.05',
                         '100110.05',
                         '100111.05')
     order by b.unit_id;

begin
 dbms_output.put_line( rpad('unit_id',15,' ')||rpad('| tab_name',
                            42,
                            ' ') ||
                       rpad('| tab_count',
                            22,
                            ' ') ||
                       rpad('| source_table',
                            42,
                            ' ') ||
                       rpad('| source_count',
                            22,
                            ' ') ||
                       rpad('| 差值',
                            20,
                            ' '));
  dbms_output.put_line(rpad('-', 160, '-'));
  for mycur in cur loop
    lvc_unit_id    := mycur.unit_id;
    lvc_ldmtab     := mycur.tab_name;
    lvc_ldmsql     := mycur.EXEC_SQL_01;
    lvc_hxsql      := mycur.EXEC_SQL_02;
    lvc_source_tab := mycur.source_tab;
    execute immediate lvc_ldmsql
      into lvc_ldmcount;
    execute immediate lvc_hxsql
      into lvc_hxcount;
    lvc_radio := lvc_hxcount - lvc_ldmcount;
     begin
      execute immediate lvc_ldmsql
        into lvc_ldmcount;
      execute immediate lvc_hxsql
        into lvc_hxcount;
    exception
      when others then
        dbms_output.put_line('----'||lvc_unit_id||'----'||lvc_ldmtab||'----'||lvc_hxsql);
    end;
    lvc_radio := lvc_hxcount - lvc_ldmcount;
    dbms_output.put_line( rpad(lvc_unit_id,15,' ')||'| '||rpad(lvc_ldmtab,
                              40,
                              ' ') || '| ' ||
                         rpad(lvc_ldmcount,
                              20,
                              ' ') || '| ' ||
                         rpad(lvc_source_tab,
                              40,
                              ' ') || '| ' ||
                         rpad(lvc_hxcount,
                              20,
                              ' ') || '| ' ||
                         rpad(lvc_radio,
                              20,
                              ' '));
  end loop;
end;

unit_id        | tab_name                                | tab_count           | source_table                            | source_count        | 差值              
----------------------------------------------------------------------------------------------------------------------------------------------------------------
9901.02        | DW0_DJ_NSRZHSX                          | 21157236            | 不存在源表                              | 21157236            | 0                   
9902.02        | DW0_DJ_NSZHDJXX                         | 21157263            | 不存在源表                              | 21157263            | 0                   
31801.01       | DW1_SB_SDS_JMCZ_ND                      | 0                   | 不存在源表                              | 0                   | 0                   
31804.01       | DW1_SB_SDS_JMHD_ND                      | 0                   | 不存在源表                              | 0                   | 0                   
31805.01       | DW1_SB_SDS_JMCZ_14ND                    | 0                   | 不存在源表                              | 0                   | 0                   
31806.01       | DW1_SB_SDS_JMCZ_14ND_JWSDDM             | 0                   | 不存在源表                              | 0                   | 0                   

