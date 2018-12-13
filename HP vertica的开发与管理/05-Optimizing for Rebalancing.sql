1.问题：
Rebalancing is complex: CPU-, disk-, and network-intensive. Because rebalancing requires a large amount of data movement, the process can take a long time.

2.监控

select * from REBALANCE_TABLE_STATUS;
select * from REBALANCE_PROJECTION_STATUS;

3.

SELECT node_name, session_id, session_start_timestamp, description
 FROM system_sessions
 WHERE is_active;

SELECT node_name, session_id, session_start_timestamp, description
 FROM system_sessions
 WHERE session_type = 'REBALANCE_CLUSTER'
 AND is_active;

4.
SELECT session_id, projection_name, refresh_status, refresh_method, refresh_phase
 FROM projection_refreshes;

SELECT session_id, projection_name, refresh_status, refresh_method, refresh_phase
 FROM projection_refreshes
 WHERE refresh_method = 'rebalance'
 AND is_executing; 

5.
SELECT CASE
     WHEN (is_destroyed ) THEN 'deleted'
     ELSE 'created'
     END AS container, projection_name, SUM(row_count) AS rows_processed, COUNT(*) n_containers
  FROM vs_rebalance_separated_storage_containers
  GROUP BY  1, 2
  ORDER BY 1, 2;

6.
SELECT DATE_TRUNC ('hour', grant_time), node_name,
COUNT(*) number_of_tx, MAX(time - grant_time) max_time_lock_held
FROM dc_lock_releases
WHERE time - grant_time>'1 min'
AND mode IN ('X', 'S', 'O')
--AND object_name NOT LIKE 'ElasticCluster'
GROUP BY 1, 2
ORDER BY 4 desc;


 SELECT DISTINCT query_requests.transaction_id, statement_id, request
FROM dc_lock_releases JOIN query_requests USING (session_id)
WHERE time - grant_time > '2 min'
AND mode IN ('X','S')
--AND object_name NOT LIKE 'ElasticCluster'
ORDER BY statement_id;

7.
SELECT time, session_id, error_level, node_name, log_message
   FROM dc_errors WHERE session_id IN
      (SELECT DISTINCT session_id
       FROM dc_session_starts
       --WHERE session_type = 'REBALANCE_CLUSTER'
       ) 
   ORDER BY time DESC;
