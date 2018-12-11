select distinct 'exec dbms_stats.gather_table_stats(''J1_LD'',''' ||
                table_name ||
                ''',degree=>32,cascade=>TRUE,force=>TRUE,estimate_percent => dbms_stats.auto_sample_size,granularity => ''all'',method_opt => ''for all indexed columns'')',
                table_name
  from dba_tab_statistics t
 where owner = 'J1_LDM'
   AND (last_analyzed is null or stale_stats = 'YES')
 order by table_name desc;


 select distinct 'exec dbms_stats.gather_table_stats(''J1_LDM'',''' ||
                  table_name ||
                  ''',degree=>32,cascade=>TRUE,force=>TRUE,estimate_percent => dbms_stats.auto_sample_size,granularity => ''all'',method_opt => ''for all indexed columns'')',
                  table_name
    from user_tab_statistics t
   where (last_analyzed is null or stale_stats = 'YES')
   order by table_name desc;