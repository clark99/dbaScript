一.vertica的存储结构：

1.storage_containers-存放文件ROS信息：
	--某个表的ros信息统计
	SELECT SCHEMA_NAME,
	       projection_name,
	       sum(total_row_count) as total_row_count,         --计算表的记录行数
	       sum(deleted_row_count) as deleted_row_count,     --计算表的标记delete的记录行数
	       round(sum(used_bytes)/1024/1024,2) as used_mb,   --计算表占用的物理空间大小
	       sum(delete_vector_count) as delete_vector_count,
	       count(*) as ROS_FILE_COUNT,
	       TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS')
	FROM storage_containers
	WHERE storage_type='ROS'
	 AND SCHEMA_NAME='BDW_SDL'
	 and projection_name like 'SDL_CASH_COLLECT_TRADE_D%'
	GROUP BY SCHEMA_NAME,projection_name;

	--所有表的b0 projection的ros信息统计：
	SELECT SCHEMA_NAME,
       projection_name,
       sum(total_row_count) as TOTAL_ROW_COUNT,
       sum(deleted_row_count) as deleted_row_count,
       round(sum(used_bytes)/1024/1024,2) as USED_BYTES_MB,
       sum(delete_vector_count) as DELETE_VECTOR_COUNT,
       count(*) as ROS_FILE_COUNT,
       TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS') as EXEC_DATE
	FROM storage_containers
	WHERE storage_type='ROS'
	 -- AND SCHEMA_NAME='BDW_ADL'
	 and projection_name like '%_b0'
	GROUP BY SCHEMA_NAME,projection_name

	--vertica数据库schema使用情况监控：
	SELECT round(sum(used_bytes)/1024/1024/1024,2) AS size_in_gb,
	       sum(total_row_count) AS TOTAL_ROW_COUNT,
	       sum(deleted_row_count) AS deleted_row_count,
	       sum(delete_vector_count) AS DELETE_VECTOR_COUNT,
	       count(*) AS ROS_FILE_COUNT,
	       sysdate ,
	       node_name ,
	       SCHEMA_NAME
	FROM storage_containers
	GROUP BY node_name,
	         SCHEMA_NAME;

	--vertica数据库磁盘的信息监控：
	SELECT round(sum(used_bytes)/1024/1024/1024,2) AS size_in_gb,
	       sum(total_row_count) AS TOTAL_ROW_COUNT,
	       sum(deleted_row_count) AS deleted_row_count,
	       sum(delete_vector_count) AS DELETE_VECTOR_COUNT,
	       count(*) AS ROS_FILE_COUNT,
	       sysdate
	FROM storage_containers

2.projection_storage存放映射projection的物理信息

	SELECT projection_schema
			projection_name,
		   sum(ros_row_count) as ros_row_count,						--计算表的记录行数
		   round(sum(ros_used_bytes)/1024/1024,2) as used_mb,       --计算表占用的物理空间大小
		   sum(ros_count) as ros_count,								--计算表的物理文件个数
		   TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS') as exec_time
	FROM projection_storage
	WHERE projection_name='SDL_CASH_COLLECT_TRADE_D_b0'
	group by projection_schema,projection_name
	ORDER BY projection_name

	SELECT *
	FROM projection_storage                                        --计算表在每个node节点的ros物理文件信息
	WHERE projection_name='SDL_CASH_COLLECT_TRADE_D_b0'
	ORDER BY projection_name,
         node_name;


3.查看表的segment分区信息：
	SELECT GET_PROJECTIONS('BDW_BDL.BDL_ACC_BIND');	-- Projection Name: [Segmented] [Seg Cols] [# of Buddies] [Buddy Projections] [Safe] [UptoDate] [Stats]
	select * from PROJECTIONS where projection_name='SDL_CASH_COLLECT_TRADE_D_b0';

4.整理表的物理文件碎片，合并文件
	select DO_TM_TASK ('moveout',  'BDW_SDL.SDL_CASH_COLLECT_TRADE_D_b0');
	select DO_TM_TASK ('mergeout', 'BDW_SDL.SDL_CASH_COLLECT_TRADE_D_b0');
	select DO_TM_TASK ('moveout',  'BDW_SDL.SDL_CASH_COLLECT_TRADE_D_b1');
	select DO_TM_TASK ('mergeout', 'BDW_SDL.SDL_CASH_COLLECT_TRADE_D_b1');
	合并之后的效果：
	projection_name ros_row_count used_mb                                  ros_count exec_time           
	--------------- ------------- ---------------------------------------- --------- ------------------- 
	BDW_SDL         9176297       302.470000000000000000000000000000000000 122       2018-12-05 18:48:17 
	BDW_SDL         7893818       260.360000000000000000000000000000000000 12        2018-12-05 18:56:50 


二.vertica集群的高可用,vertica的冗余,数据安全,副本：
	1.K-Safety
		SELECT GET_DESIGN_KSAFE();

	2.vertica集群信息：
		(1)节点信息:
			select node_name , node_id , node_type from nodes where node_type= 'PERMANENT';
			select * from vs_nodes;

		(2)集群信息
			select * from v_catalog.CLUSTER_LAYOUT;
			select * from v_internal.vs_cluster_layout

	3.Vertica的数据安全-Data Safety
	(1)节点依赖：
		SELECT GET_NODE_DEPENDENCIES ();
		-- in the binary form 00011, where node 1 = 1, node 2 = 1, node 3 = 0, node 4 = 0, and node 5 = 0. 1 indicates that segments exist on the node and 0 indicates that segments do not exist on the node.
		Deps:
		0011 - cnt: 2166
		0110 - cnt: 2166
		1001 - cnt: 2166
		1100 - cnt: 2166
		1111 - cnt: 7

		SELECT vs_node_dependencies.dependency_id,
			   CLUSTER_LAYOUT.cluster_position,
			   CLUSTER_LAYOUT.node_name,
			   vs_node_dependencies.ref_count
		FROM v_internal.vs_node_dependencies
		JOIN CLUSTER_LAYOUT ON vs_node_dependencies.node_oid=CLUSTER_LAYOUT.node_id
		order by node_name,dependency_id;

		SELECT vnd.ref_count,
		       vnd.dependency_id,
		       vcl.node_name,
		       vcl.fault_group_name
		FROM vs_node_dependencies vnd
		INNER JOIN vs_cluster_layout vcl ON vnd.node_oid=vcl.node_id
		WHERE vnd.ref_count = 2166
		ORDER BY vnd.ref_count,
	         vnd.dependency_id,
         vcl.node_name;

		SELECT dependency_id,
		       min(node_name) AS node_x,
		       max(node_name) AS node_y
		FROM vs_node_dependencies
		JOIN nodes ON node_oid = node_id
		GROUP BY 1 HAVING count(*) = 2
		ORDER BY 1;
			SELECT dependency_id,
		       MIN (node_name) node_x,
		       MAX(node_name) node_y,
		       COUNT(*) dep_count
		FROM vs_node_dependencies
		JOIN nodes ON (node_oid = node_id)
		GROUP BY 1
		ORDER BY 1;

		dependency_id node_x         node_y         
		------------- -------------- -------------- 
		0             v_dws_node0001 v_dws_node0002 
		1             v_dws_node0002 v_dws_node0003 
		3             v_dws_node0003 v_dws_node0004
		2             v_dws_node0001 v_dws_node0004 


三.vertica删除数据：
	1.内存WOS中删除的数据及文件：
		select node_name,
				count(dv_oid) as delete_vector_count,
				sum(deleted_row_count) as deleted_row_count,
				round(sum(used_bytes)/100/100,2) as deletion_used_bytes_mb,
				sysdate
		from delete_vectors
		where storage_type='DVWOS'
		group by node_name;

	2.内存ROS中删除的数据及文件

		SELECT node_name,
		       count(dv_oid) AS delete_vector_count,
		       sum(deleted_row_count) AS deleted_row_count,
		       round(sum(used_bytes)/100/100,2) AS deletion_used_bytes_mb,
		       sysdate
		FROM delete_vectors
		WHERE storage_type='DVROS'
		GROUP BY node_name;

	3.mergeout
	-- When you delete data from the database, HP Vertica does not remove it. Instead, it marks the data as deleted
	-- the Tuple Mover looks for deletion marker containers that hold few entries, it merges them together into a single larger container.
	-- It does not purge or otherwise affect the deleted data—it just consolidates the deletion mark containers;
	--验证mergeout

	4.Historical query
	   AT TIME 'timestamp' SELECT...
  	   AT EPOCH epoch_number SELECT...
       AT EPOCH LATEST SELECT...

    6.purge
    -- A purge operation permanently removes deleted data from physical storage so that the disk space can be reused
	--验证purge:
	select purge();
	SELECT round(sum(used_bytes)/1024/1024/1024,2) AS size_in_gb,
	        sum(total_row_count) as TOTAL_ROW_COUNT,
	       sum(deleted_row_count) as deleted_row_count,
	       sum(delete_vector_count) as DELETE_VECTOR_COUNT,
	       count(*) as ROS_FILE_COUNT,
	       sysdate
	FROM v_monitor.storage_containers;
	SELECT count(dv_oid) AS delete_vector_count,
	       sum(deleted_row_count) AS deleted_row_count,
	       round(sum(used_bytes)/100/100,2) AS deletion_used_bytes_mb,
	       sysdate
	FROM delete_vectors
	WHERE storage_type='DVROS';

	7.Setting a Purge Policy:HistoryRetentionTime
	-- select * from configuration_parameters where parameter_name='HistoryRetentionTime ';
	-- 清除数据的首选方法是建立一个策略，确定哪些已删除的数据有资格被清除。当元组移动器执行合并操作时，将自动清除符合条件的数据。

四.查看vertica的表的元数据：
	1.列的顺序：
	SELECT ordinal_position,
       COLUMN_NAME,
       data_type
	FROM columns
	WHERE table_schema='bdw_bdl'
	  AND TABLE_NAME='BDL_T_PAY_ORDER_INFO_HIS'
	ORDER BY ordinal_position;
	SELECT a.ordinal_position,
	       a.column_name,
	       a.data_type,
	       a.column_name=b.column_name,
	       a.data_type=b.data_type
	FROM columns a,
	     columns b
	WHERE a.table_schema='TEMP'
	  AND a.table_name='BDL_T_PAY_ORDER_INFO_HIS'
	  AND b.table_schema='BDW_BDL'
	  AND b.table_name='BDL_T_PAY_ORDER_INFO_HIS'
	  AND b.ordinal_position=a.ordinal_position;

	  2.

五.vertica的权限对象管理：
	1.表的赋权：

SELECT 'grant '||privileges_description||' on '||object_schema||'.'||object_name||' to '||grantee||';'
FROM grants
WHERE object_name='FDL_T02_TRMINAL_TRADE'
  AND grantee NOT IN
    (SELECT CURRENT_USER());

	2.

六.vertcia参数的设置：
	1.Configuration parameter (vertica.conf) 修改历史
	select * from configuration_changes;

	2.Configuration Parameters information
		SELECT parameter_name,
		       CURRENT_VALUE,
		       DEFAULT_VALUE,
		       description
		FROM CONFIGURATION_PARAMETERS
		WHERE change_requires_restart IS FALSE
		  AND IS_MISMATCH IS FALSE
		  AND parameter_name not in ('SnmpTrapEvents');

	3.修改参数：
		(1)方式1：
		SELECT GET_CONFIG_PARAMETER('MoveOutInterval');  --300
		SELECT SET_CONFIG_PARAMETER('MergeOutInterval', 60);
		(2)方式2：
		SELECT * FROM CONFIGURATION_PARAMETERS where parameter_name='MaxClientSessions';
		ALTER DATABASE dws SET MaxClientSessions = 200

七.vertica的事务, 会话, 锁,隔离：
	1.会话：
		SELECT 'select close_session('''||session_id||''');',s.*
		FROM sessions s
		WHERE current_statement<>''
		  and session_id<>(select current_session());
	3.事务
	4.事务隔离
	1.锁：
		(1)简单查看：
		select * from locks;
		SELECT * FROM lock_usage;
		(2)锁类型：


八.vertica的全库存储优化:
	1.mergeout

	SELECT 'select DO_TM_TASK (''moveout'', '''||projection_schema||'.'||projection_name||''');' AS dm_moveout,
	       'select DO_TM_TASK (''mergeout'', '''||projection_schema||'.'||projection_name||''');' AS dm_mergeout
	FROM projections
	INNER JOIN TABLES ON IS_TEMP_TABLE IS FALSE
	AND IS_SYSTEM_TABLE IS FALSE
	AND TABLES.table_name=projections.anchor_table_name
	AND TABLES.TABLE_SCHEMA=projections.projection_schema
	ORDER BY projection_schema,
	         projection_name;

	2.purge
	select purge();

	3.优化效果监控：
	SELECT count(dv_oid) AS delete_vector_count,
	       sum(deleted_row_count) AS deleted_row_count,
	       round(sum(used_bytes)/100/100,2) AS deletion_used_bytes_mb,
	       sysdate
	FROM delete_vectors
	WHERE storage_type='DVROS';
	
	SELECT round(sum(used_bytes)/1024/1024/1024,2) AS size_in_gb,
	       sum(total_row_count) AS TOTAL_ROW_COUNT,
	       sum(deleted_row_count) AS deleted_row_count,
	       sum(delete_vector_count) AS DELETE_VECTOR_COUNT,
	       count(*) AS ROS_FILE_COUNT,
	       sysdate
	FROM v_monitor.storage_containers;

九.vertica的sql开发
	1.序列的使用：
		(1)方式1：
		CREATE SEQUENCE my_seq START 104;
		SELECT CURRVAL('my_seq');
		SELECT NEXTVAL('my_seq'), product_description FROM product_dimension LIMIT 10;
		
		(2)方式2：
		-- 主键：IDENTITY ( start, increment)
		 CREATE TABLE temp.customer4(
		     ID IDENTITY(1,1),  --主键关键字
		     lname VARCHAR(25),
		     fname VARCHAR(25), 
		     membership_card INTEGER
		   );
		
		INSERT INTO temp.customer4(lname, fname, membership_card) VALUES ('Gupta', 'Saleem', 475987); --id主键自增
	
		(3)方式3
		CREATE TABLE customer2(
		      id INTEGER DEFAULT NEXTVAL('my_seq'),
		      lname VARCHAR(25), 
		      fname VARCHAR(25),
		      membership_card INTEGER
		);
		INSERT INTO customer2 VALUES (default,'Carr', 'Mary', 87432); --序列自增

十.vertica表的统计信息：
	1.统计信息失效的表：

	SELECT DISTINCT HAS_STATISTICS,
					PROJECTION_SCHEMA,
	                ANCHOR_TABLE_NAME
	FROM PROJECTIONS
	INNER JOIN TABLES ON IS_TEMP_TABLE IS FALSE
	AND IS_SYSTEM_TABLE IS FALSE
	AND TABLES.table_name=projections.anchor_table_name
	AND TABLES.TABLE_SCHEMA=projections.projection_schema
	WHERE HAS_STATISTICS='false'
	ORDER BY PROJECTION_SCHEMA,ANCHOR_TABLE_NAME;

	2.收集统计信息的脚本：
	SELECT DISTINCT HAS_STATISTICS,
					PROJECTION_SCHEMA,
	                ANCHOR_TABLE_NAME,
	                'select ANALYZE_STATISTICS('''||(projection_schema||'.'||ANCHOR_TABLE_NAME)||''');'
	FROM PROJECTIONS
	INNER JOIN TABLES ON IS_TEMP_TABLE IS FALSE
	AND IS_SYSTEM_TABLE IS FALSE
	AND TABLES.table_name=projections.anchor_table_name
	AND TABLES.TABLE_SCHEMA=projections.projection_schema
	WHERE HAS_STATISTICS='false'
	ORDER BY PROJECTION_SCHEMA,ANCHOR_TABLE_NAME;