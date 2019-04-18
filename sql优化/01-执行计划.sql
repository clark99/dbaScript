1.sql执行:

sql语句
|
解析器 -- 软解析 -- hash -- 库缓存命中
|
|
硬解析 -- rbo
|
|
cbo

2.执行计划的影响因素
(1)统计信息
    对象统计信息:表,列,索引
    系统统计信息:IO cpu
(2)优化器,hints
(3)初始化参数
(4)索引
(5)分区
(6)并行

一.执行计划
1.explain plan
(1)执行计划放在explain表中
(2)不实际执行
(3)
select plan_table_output form table(dbms_xplain.display)

2.v$sql_plan
select plan_table_output form table(dbms_xplain.display_cursor(''));

3.awr
select plan_table_output form table(dbms_xplain.display_awk(''));

4.sqlplus autotrace
set autotrace on;

5.plsql developer && sql developer

6.读取执行计划
(1).从左侧联系往右看,直到看到并列的地方
(2).并列的部分上面先执行
(3).对于不并列的,右侧先执行

二.访问路径
1.全表扫描
2.行ID扫描
3.索引扫描
4.其他

1.全表扫描
(1)高水位线以下的数据

三.索引扫描
1.唯一
2.最大最小
3.范围-降序
4.跳跃式
5.完全和快速扫描
