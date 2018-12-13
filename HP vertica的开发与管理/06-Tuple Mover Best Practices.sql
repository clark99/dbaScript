一.ROS WOS概述：

(1)WOS is stored as unsorted data
(2)data that is loaded into ROS is stored as sorted, encoded, and compressed data, based on projection design.

(1)Moveout:
	 moves data from a WOS container into a new ROS container. 新的文件容器
(2)mergeout:
	consolidates ROS containers and purges deleted records.

二。Tuple Mover Moveout OperationTuple mover


1.Detect WOS Spillover溢出
(1)WOS memory - WOSDATA - 2GB 每个节点
(2)危害：If you load data into the WOS faster than the Tuple Mover can move the data out, the data can spill into ROS until space in the WOS becomes available
(3)严重危害：create ROS containers much faster than预期，slows the moveout operation
(4)
SELECT node_name,
       count(*)
FROM dc_execution_engine_events
WHERE event_type = 'WOS_SPILL'
GROUP BY node_name;

node_name      count 
-------------- ----- 
v_dws_node0003 3     
v_dws_node0001 3     
v_dws_node0002 3     
v_dws_node0004 3     

event_type event_description                         operator_name event_details                                                                                                                          suggested_action                                               
---------- ----------------------------------------- ------------- -------------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------- 
WOS_SPILL  WOS Full; spilling to a new ROS container DataTarget    WOS full during INSERT into v_temp_schema.TEMP0_SOURCE_TOTAL_D_super after loading 1101610 rows and 57389731 bytes in 1 WOS containers Consider DIRECT load, more aggressive Moveout, or a larger WOS 
WOS_SPILL  WOS Full; spilling to a new ROS container DataTarget    WOS full during INSERT into BDW_FDL.FDL_T02_CPM_OPERATE_LOG_b1 after loading 321253 rows and 57196459 bytes in 1 WOS containers        Consider DIRECT load, more aggressive Moveout, or a larger WOS 
WOS_SPILL  WOS Full; spilling to a new ROS container DataTarget    WOS full during INSERT into BDW_FDL.FDL_T02_CPM_OPERATE_LOG_b0 after loading 321606 rows and 57204381 bytes in 1 WOS containers        Consider DIRECT load, more aggressive Moveout, or a larger WOS 


最佳实践：

1.Use COPY DIRECT for Loading Large Data Files
2.Configuration Parameter: MoveOutInterval
Set this parameter to a value that is less than the time it takes to fill half of the WOS
3.Uncommitted Data in WOS
If the WOS is filled with data from uncommitted transactions, moveout cannot move data out. This can lead to a WOS spillover into ROS
4.Do not use the WOS for Large Temporary Tables
Do not use the WOS to load temporary tables with a large data set (more than 50 MB per node). The moveout operation does not move out temporary table data and the data is dropped when the transaction or session ends.
5.maxMemorySize of WOSDATA Resource Pool
Do not increase the size of WOS memory unless you aggressively load data into many tables and the data in WOS per projection is not more than a few hundred megabytes. If you have more than a few hundred MB in the WOS per projection, you could encounter inconsistent query performance.
6.Configuration Parameter: MoveOutSizePct
 For example, if you set this value to 40, then the moveout operation does not move out projections until the WOS is 40% full and can help batch data before moving the data out.
7.

三。Tuple Mover Mergeout Operation：Best Practices for Mergeout
1.Use WOS for Trickle Loads or Batch Load with DIRECT HINT
(1)Trickle loading into WOS helps batch data before moving into disk, which reduces the number of ROS containers created.
(2) For larger files, batch load directly into ROS using DIRECT HINT.
2.MemorySize of TM Resource Pool
If your database has wide tables (more than 100 columns), increase the MemorySize of the TM resource pool from the default of 200MB to 6GB and change the PLANNEDCONCURRENCY parameter to 3. Reserve at least 2GB per Tuple Mover mergeout thread to speed up operations on wide tables.
3.Partitions per Table
(1)警告：Vertica does not merge ROS containers across partitions. 
(2)危害：Thus, tables with hundreds of partitions can hit ROS pushback quickly
4.Limit Projection Sets Anchored on the Same Table
Do not have more than two projection sets anchored on the same table. Having more than two sets of projections per table can lead to wasted system resources.
5.Projection Sort Order Guidelines
Include fewer than 10 columns in the sort order and avoid having wide VARCHAR columns in the sort order.  This helps decrease the time it takes for the mergeout operation to run. Long running operations can block mergeout threads, which increases the number of ROS containers.
6。Batch Deletes and Updates Whenever Possible 

四。How does the Tuple Mover mergeout STRATA algorithm work?元组移动合并地层算法是如何工作的?

