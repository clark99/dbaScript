-------------------------------------------
--路径关系 sys_connect_by_path(parentunit_id, ', ')
--connect_by_isleaf:叶子
--connect_by_root:根节点
--level：梯队，层级
-------------------------------------------
select level,
       unit_id,
       sys_connect_by_path(parentunit_id, ', ') PATH,
       connect_by_isleaf leaf,
       connect_by_root unit_id "根节点"
  from j1_dw.etl_meta_unit t
 where unit_id in
       ('151.02', '152.02', '155.02', '156.02', '157.02', '158.02')
 start with parentunit_id = '100.02'
connect by nocycle prior unit_id = parentunit_id;

     LEVEL            UNIT_ID PATH                                                 LEAF     根节点
---------- ------------------ ------------------------------------------------      ----     -----
         1             151.02 , 100.02                                               0     151.02
         2             152.02 , 100.02, 151.02                                       0     151.02
         3             155.02 , 100.02, 151.02, 152.02                               0     151.02
         4             156.02 , 100.02, 151.02, 152.02, 155.02                       0     151.02
         5             157.02 , 100.02, 151.02, 152.02, 155.02, 156.02               0     151.02
         6             158.02 , 100.02, 151.02, 152.02, 155.02, 156.02, 157.02       1     151.02
 
/**************************************
应用--取叶子，获得完整路径
**************************************/
select level,
       unit_id,
       sys_connect_by_path(parentunit_id, ',') PATH,
       connect_by_iscycle Cycle,
       connect_by_isleaf "leaf_node",
       connect_by_root unit_id as "root_node"
  from j1_dw.etl_meta_unit t
--取叶子
 where connect_by_isleaf = 1
      --对层次查询结果进行过滤
   and unit_id <> connect_by_root unit_id
--层次查询的条件
 start with parentunit_id is not null
connect by nocycle prior unit_id = parentunit_id
 order by 3, 1, 6
