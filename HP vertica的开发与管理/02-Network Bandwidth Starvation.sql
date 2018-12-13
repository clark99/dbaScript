SELECT node_name
     ,start_time StartTime
     ,end_time EndTime
     ,tx_kbytes_per_sec
     ,rx_kbytes_per_sec
     ,tx_kbytes_per_sec + rx_kbytes_per_sec total_kbytes_per_sec
FROM (
     SELECT node_name
           ,round(min(start_time), 'SS') AS start_time
           ,round(max(end_time), 'SS') AS end_time
           ,round(((sum(tx_bytes_end_value - tx_bytes_start_value) / 1024) / (datediff('millisecond', min(start_time), max(end_time)) / 1000))::FLOAT, 2) AS tx_kbytes_per_sec
           ,round(((sum(rx_bytes_end_value - rx_bytes_start_value) / 1024) / (datediff('millisecond', min(start_time), max(end_time)) / 1000))::FLOAT, 2) AS rx_kbytes_per_sec
     FROM dc_network_info_by_second
     WHERE start_time > '2018-12-13 04:00:00-04'
           AND end_time < '2018-12-13 05:00:00-04'
                 and
           interface_id LIKE 'bond0'
     GROUP BY node_name
           ,round(start_time, 'SS')
     ) a
ORDER BY 2,node_name;