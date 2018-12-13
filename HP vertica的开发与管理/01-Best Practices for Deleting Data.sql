1.vertica删除数据的方式：
	The DELETE statement does not actually delete data from the disk storage; it marks rows as deleted so that they can be retrieved by historical queries.
	The UPDATE statement performs two tasks: It writes the new data and marks the old data for deletion
	The DELETE statement does not delete the data from the disk storage. Instead, the statement creates a delete vector that records the position of the deleted record and the epoch when the delete was committed.

2.Different Types of Delete
	(1)Single Row Delete,
		wos, Depends on projection design, Recommended in WOS so that deleted rows are combined in one delete vector when data is moved out.
	(2)Trickle Load,
		wos, Depends on Projection Design, Recommended for small batches that happen at frequent intervals. Recommended in WOS so that deleted rows are combined in one delete vector when data is moved out.
	(3)Bulk Delete,
		Direct ROS, Depends on Projection Design, Recommended because it creates one delete vector for each ROS that has data to be marked as deleted.
	(4)Drop Partition,
		Fast with catalog removal and storage is removed in the background, Recommended to clean historic data. It forces the moveout operation before executing to move data inserted in ROS that belongs to partition to be removed.
	(6)Truncate
		Fast with catalog object changes and storage is removed in the background.Removes all storage associated with a table while preserving the table definition. Recommended when you need to clean the table content.

3.Removing Deleted Data
	(1)AHM:Ancient History Mark
		an epoch that represents the time until which the history is retained
		Any history older than the AHM is eligible for permanent removal.
	(2)purge policy of tuple mover
		HistoryRetentionTime, 秒,临时保留时间
			To disable, set the HistoryRetentionTime configuration parameter to -1
			SELECT * FROM CONFIGURATION_PARAMETERS where parameter_name='HistoryRetentionTime';
				parameter_name       current_value description
		-------------------- ------------- -----------------------------------------------------------
		HistoryRetentionTime 0             Number of seconds of epochs kept in the epoch map (seconds)

		HistoryRetentionEpochs:	
			set the HistoryRetentionTime configuration parameter to -1 and set the number of historical epochs to be saved
			SELECT * FROM CONFIGURATION_PARAMETERS where parameter_name='HistoryRetentionEpochs';

		parameter_name       current_value description
		-------------------- ------------- -----------------------------------------------------------
		HistoryRetentionEpochs	-1	Upper bound on the number of epochs kept in the epoch map

	(3)PurgeMergeoutPercent
		Specify the percentage of deleted rows that need to be reached in order to permanently remove the data
		SELECT * FROM CONFIGURATION_PARAMETERS where parameter_name='PurgeMergeoutPercent';
		parameter_name       current_value description                                                                              
		-------------------- ------------- ---------------------------------------------------------------------------------------- 
		PurgeMergeoutPercent 20            Maximum % of rows that may be deleted before Tuple Mover purges the ROS through mergeout 

4.Managing Delete Vectors
	(1)替代删除数据truncate,drop partition,SWAP_PARTITIONS_BETWEEN_TABLES 
	(2)
5.批量删除Bulk Delete
	(1)Use bulk delete instead of multiple single deletes
	(2) You can delete the records in a single delete statement, which creates one delete vector per statement. 
	     You can also create one bulk delete statement that creates one delete vector per ROS container that contains deleted data.

	     Load the delete predicate in a temporary table.
         Delete rows in one statement by joining the temporary table with the delete predicates and the table with data to be deleted.
6.批量删除试验：
	(1)普通删除：注：删除了1+1行两个文件 一共两个delete_vector
		SELECT *
		FROM storage_containers
		WHERE storage_type='ROS'
		  AND SCHEMA_NAME='BDW_BDL'
		  AND projection_name='BDL_PHONE_APP_INFO_b0'
		ORDER BY STORAGE_OID;
node_name      schema_name projection_id     projection_name       storage_type storage_oid       total_row_count deleted_row_count used_bytes start_epoch end_epoch grouping   segment_lower_bound segment_upper_bound is_sorted location_label delete_vector_count 
-------------- ----------- ----------------- --------------------- ------------ ----------------- --------------- ----------------- ---------- ----------- --------- ---------- ------------------- ------------------- --------- -------------- ------------------- 
v_dws_node0001 BDW_BDL     45035996954884542 BDL_PHONE_APP_INFO_b0 ROS          45035998399780737 35435           35435             467414     18117322    18117322  PROJECTION 0                   1073741823          true                     1                   

v_dws_node0002	BDW_BDL	4.5036E+16	BDL_PHONE_APP_INFO_b0	ROS	4.95396E+16	38002	0	500962	18852594	18852594	PROJECTION	1073741824	2147483647	TRUE		0
v_dws_node0003	BDW_BDL	4.5036E+16	BDL_PHONE_APP_INFO_b0	ROS	5.40432E+16	37618	0	496346	18852594	18852594	PROJECTION	2147483648	3221225471	TRUE		0

		select * from BDW_BDL.BDL_PHONE_APP_INFO ORDER BY PHONE_NO;
		DELETE FROM BDW_BDL.BDL_PHONE_APP_INFO WHERE PHONE_NO IN ('13001000010','13001017372','13001018696');
		COMMIT;

v_dws_node0002	BDW_BDL	4.5036E+16	BDL_PHONE_APP_INFO_b0	ROS	4.95396E+16	38002	2	500962	18852594	18852594	PROJECTION	1073741824	2147483647	TRUE		1
v_dws_node0003	BDW_BDL	4.5036E+16	BDL_PHONE_APP_INFO_b0	ROS	5.40432E+16	37618	1	496346	18852594	18852594	PROJECTION	2147483648	3221225471	TRUE		1
	
	(2)
	第一步其他表存放删除的数据
	select PHONE_NO FROM BDW_BKBDL.BKBDL_PHONE_APP_INFO WHERE PHONE_NO IN ('13001020566','13001024615','13001033330') and data_dt='2018-12-12';
	第二步删除Bulk Delete
	DELETE /*+ direct */ from BDW_BDL.BDL_PHONE_APP_INFO WHERE PHONE_NO IN (select PHONE_NO FROM BDW_BKBDL.BKBDL_PHONE_APP_INFO WHERE PHONE_NO IN ('13001020566','13001024615','13001033330') and data_dt='2018-12-12');

v_dws_node0002	BDW_BDL	45035996954884542	BDL_PHONE_APP_INFO_b0	ROS	49539598019924897	38002	4	500962	18852594	18852594	PROJECTION	1073741824	2147483647	true		2
v_dws_node0003	BDW_BDL	45035996954884542	BDL_PHONE_APP_INFO_b0	ROS	54043197643570513	37618	2	496346	18852594	18852594	PROJECTION	2147483648	3221225471	true		2


	注：(1)删除了4+2=3+3行数据两次两个文件，一共四个delete_vector


7.Mergeout Delete Vectors
(1)Merging the delete vectors is better than purging the entire table. 
(2)Purging a table rewrites the data set of ROS containers without the deleted rows
(3) If the number of deleted rows is small in comparison with the total rows of the table, do not purge the table
(4)To avoid a ROS pushback，, reduce the number of delete vectors 避免性能下降和ROS pushback，mergeout ROS, purging delete data;
(5) The Tuple Mover performs an automatic mergeout by combining two or more ROS containers into a single container without the deleted rows
(6)但是，如果每个ROS容器的删除向量数量小于PurgeMergeoutPercent(默认值是20%)，合并操作不会清除删除的记录。
(7)Using many DELETE statements to delete multiple rows creates many small containers to hold the deletion marks,Each container consumes resources and impacts performance
SELECT DO_TM_TASK('dvmergeout','BDW_BDL.BDL_PHONE_APP_INFO');

8.Purging Partitions
SELECT MAKE_AHM_NOW();
SELECT PURGE_PARTITION('store.store_orders_fact',200511);
SELECT PURGE('store.store_orders_fact');
SELECT PURGE_PARTITION ('store_orders_fact_b0');