1.执行
select count(*) from dual

2.查看执行sql

SELECT sql_id,
       address,
       hash_value,
       executions,
       loads,
       parse_calls,
       invalidations
FROM v$sqlarea
WHERE sql_text = 'select count(*) from dual'

-- 3.清除共享池

-- alter system flush shared_pool

-- -- 为了一个SQL而清空整个共享池，这个代价确实太大了，何况对于一个繁忙的OLTP系统而言，
-- -- 这个刷新共享池的操作所带来的风险和后果与直接关闭数据库相比，也没有太大的差别

-- 4.查看执行sql为空

-- SELECT sql_id,
--        address,
--        hash_value,
--        executions,
--        loads,
--        parse_calls,
--        invalidations
-- FROM v$sqlarea
-- WHERE sql_text = 'select count(*) from dual'

6.

grant select on dual to public

7.清理出缓存

exec dbms_shared_pool.purge('00000000B6C61FC0,4094900530', 'c')
过程PURGE的第一个参数为V$SQLAREA中用逗号分隔的ADDRESS列和HASH_VALUE列的值，
第二个参数’c’表示PURGE的对象是CURSOR，不过实际上这里可以使用除了P（PROCEDURE/FUNCTION/PACKAGE）、T（TYPE）、R（TRIGGER）和Q（SEQUENCE）的任何值