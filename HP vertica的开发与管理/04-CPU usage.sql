SELECT node_name, round(start_time, 'SS') as start_time, round(end_time, 'SS') as end_time, round(100 -
((idle_microseconds_end_value - idle_microseconds_start_value) /
(user_microseconds_end_value + nice_microseconds_end_value + system_microseconds_end_value
+ idle_microseconds_end_value + io_wait_microseconds_end_value + irq_microseconds_end_value
+ soft_irq_microseconds_end_value + steal_microseconds_end_value + guest_microseconds_end_value
- user_microseconds_start_value - nice_microseconds_start_value - system_microseconds_start_value
- idle_microseconds_start_value - io_wait_microseconds_start_value - irq_microseconds_start_value
- soft_irq_microseconds_start_value - steal_microseconds_start_value - guest_microseconds_start_value)
) * 100, 2.0) average_cpu_usage_percent
FROM dc_cpu_aggregate_by_second
where start_time between '2018-12-13 15:00:00' and '2018-12-13 16:00:00'
order by start_time, node_name;

node_name      start_time          end_time            average_cpu_usage_percent 
-------------- ------------------- ------------------- ------------------------- 
v_dws_node0001 2018-12-13 15:00:00 2018-12-13 15:00:01 37.22                     
v_dws_node0002 2018-12-13 15:00:00 2018-12-13 15:00:01 36.14                     
v_dws_node0003 2018-12-13 15:00:00 2018-12-13 15:00:01 43.92                     
v_dws_node0004 2018-12-13 15:00:00 2018-12-13 15:00:01 34.3                      
