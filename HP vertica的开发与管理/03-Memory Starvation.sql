-- Check memory usage on your system
SELECT node_name, round(start_time, 'SS') as start_time,
   round(end_time, 'SS') as end_time,
   round(100 -
           ( free_memory_sample_sum       / free_memory_sample_count +
             buffer_memory_sample_sum     / free_memory_sample_count +
             file_cache_memory_sample_sum / file_cache_memory_sample_count ) /
           ( total_memory_sample_sum      / total_memory_sample_count ) * 100.0, 2.0)
   as average_memory_usage_percent
FROM dc_memory_info_by_second
WHERE start_time between '2018-12-13 04:00:00-04' and '2018-12-13 05:00:00-04'
order by start_time, node_name;

-- Check the size of the catalog.

SELECT node_name
       ,max(ts) AS ts
       ,max(catalog_size_in_MB) AS catlog_size_in_MB
FROM (
       SELECT node_name,trunc((dc_allocation_pool_statistics_by_second."time")::TIMESTAMP, 'SS'::VARCHAR(2)) AS ts ,sum((dc_allocation_pool_statistics_by_second.total_memory_max_value - dc_allocation_pool_statistics_by_second.free_memory_min_value)) / (1024 * 1024) AS catalog_size_in_MB
       FROM dc_allocation_pool_statistics_by_second
       GROUP BY 1,trunc((dc_allocation_pool_statistics_by_second."time")::TIMESTAMP, 'SS'::VARCHAR(2))
       ) foo
GROUP BY 1
ORDER BY 1;

node_name      ts                  catlog_size_in_MB        
-------------- ------------------- ------------------------ 
v_dws_node0001 2018-12-13 16:53:10 10931.077804565429687500 
v_dws_node0002 2018-12-13 16:53:10 12312.716888427734375000 
v_dws_node0003 2018-12-13 16:53:10 9564.030792236328125000  
v_dws_node0004 2018-12-13 16:53:10 9187.402099609375000000  

