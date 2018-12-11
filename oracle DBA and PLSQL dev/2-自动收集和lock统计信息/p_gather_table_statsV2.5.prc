create or replace procedure p_gather_table_stats(avc_schema in varchar2 --输入需要收集统计信息的用户
                                                 ) is
  --01. stale_table_global处理不是分区表的统计信息失效
  cursor stale_table_global is
    select /*+ unnest */
    distinct owner, table_name
      from dba_tab_statistics
     where (last_analyzed is null or stale_stats = 'YES')
       and owner = upper(avc_schema)
          --排除partition_name,subpartition_name
       and partition_name is null
       and subpartition_name is null;

  --02. stale_table_part处理一维分区表的统计信息失效
  cursor stale_table_part is
    select /*+ unnest */
    distinct owner, table_name, partition_name
      from dba_tab_statistics
     where (last_analyzed is null or stale_stats = 'YES')
       and owner = upper(avc_schema)
          --确定partition_name，排除subpartition_name
       and partition_name is not null
       and subpartition_name is null;

  --03.stale_table_subpart处理二维分区表的统计信息失效
  cursor stale_table_subpart is
    select distinct owner, table_name, partition_name
      from dba_tab_statistics
     where (last_analyzed is null or stale_stats = 'YES')
       and owner = upper(avc_schema)
       and partition_name is not null
       and subpartition_name is not null;

begin
  --01.处理不是分区表的统计信息失效
  --SELECT * FROM USER_TAB_MODIFICATIONS来展示统计结果，因为信息不是实时刷新到数据字典，所以
  dbms_stats.flush_database_monitoring_info;
  for stale in stale_table_global loop
    begin
      dbms_stats.gather_table_stats(ownname          => stale.owner,
                                    tabname          => stale.table_name,
                                    estimate_percent => dbms_stats.auto_sample_size,
                                    --for all columns size repeat替换for all indexed columns
                                    method_opt  => 'for all indexed columns',
                                    degree      => 8,
                                    granularity => 'GLOBAL',
                                    cascade     => true,
                                    --force - gather statistics of table even if it is locked.
                                    force => true);
    exception
      when others then
        --raise_application_error(-20001, to_char(sqlcode) || sqlerrm);
        dbms_output.put_line(to_char(sqlcode) || sqlerrm);
    end;
  end loop;
  
  
  --02.处理一维分区表的统计信息失效
  dbms_stats.flush_database_monitoring_info;
  for stale_part in stale_table_part loop
    begin
      dbms_stats.gather_table_stats(ownname          => stale_part.owner,
                                    tabname          => stale_part.table_name,
                                    partname         => stale_part.partition_name,
                                    estimate_percent => dbms_stats.auto_sample_size,
                                    --for all columns size repeat替换for all indexed columns
                                    method_opt  => 'for all indexed columns',
                                    degree      => 8,
                                    granularity => 'PARTITION',
                                    cascade     => true,
                                    --force - gather statistics of table even if it is locked.
                                    force => true);
    exception
      when others then
        --raise_application_error(-20001, to_char(sqlcode) || sqlerrm);
        dbms_output.put_line(to_char(sqlcode) || sqlerrm);
    end;
  end loop;

  
  --03.处理二维分区表的统计信息失效
  dbms_stats.flush_database_monitoring_info;
  for stale_subpart in stale_table_subpart loop
    begin
      dbms_stats.gather_table_stats(ownname          => stale_subpart.owner,
                                    tabname          => stale_subpart.table_name,
                                    partname         => stale_subpart.partition_name,
                                    estimate_percent => dbms_stats.auto_sample_size,
                                    --for all columns size repeat替换for all indexed columns
                                    method_opt  => 'for all indexed columns',
                                    degree      => 8,
                                    granularity => 'SUBPARTITION',
                                    cascade     => true,
                                    --force - gather statistics of table even if it is locked.
                                    force => true);
    exception
      when others then
        --raise_application_error(-20001, to_char(sqlcode) || sqlerrm);
        dbms_output.put_line(to_char(sqlcode) || sqlerrm);
    end;
  end loop;

  

exception
  when others THEN
    dbms_output.put_line(to_char(sqlcode) || sqlerrm);
end;
/
