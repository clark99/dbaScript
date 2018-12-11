-- 一系列oracle函数(regular expresstion)
/******************************************************
regexp_like
--(1)类似like操作符,用于where语句;
--(2)不能用于select字句
--语法
--regexp_like(srcstr,pattern,[,match_option])
--match_option:
--'c',区分大小写(默认)
--'i',不区分大小写；
--'n',允许匹配任意字符匹配换行符
--'m',处理元字符串多行情况

regexp_instr
--(1)寻找一个正则表达式匹配，并且找到匹配返回一个给定字符串的位置；
--(2)类似instr函数，返回位置
--语法：
--regexp_inst(srcstr,partern[, posttion,occurrence,return_option,match_option])
--position: 搜索开始的位置
--occurrence：搜索字符串的出现
--return_option:表示发生的开始或者结束位置


regexp_replace
 --(1)搜索一个正则表达式，用替换字符替换它;
 --(2)类似replace函数 
 --语法
 --regexp_substr(srcstr,partern[, replacestr,position,occurrence,match_option])

regexp_substr
 --返回一个匹配的字串
 --类似substr
 --语法
  regexp_substr(srcstr,partern[, posttion,occurrence,match_option])


*******************************************************/

/*=====================================================
POSIX 元字符(POSIX标准字符集)
--元字符是具有特殊含义的特殊字符
=======================================================*/

--(1)
--* 匹配0,或者更多

select * from j1_dw.etl_meta_unit where regexp_like(unit_name,'(*)');
---------------------------------------------
--(2)
--| 交替匹配
--(0|2)交替匹配0和2
select * from j1_dw.etl_meta_unit where regexp_like(unit_name,'P_DM(0|2)_(YH|ZM)');
--result:
   P_DM0_YH_SSJMSPXXQC
   P_DM2_YH_SSJMSPHSTJB
--------------------------------------------
--(3)
--^ 匹配行开始
--(^5) 5开头
select * from j1_dw.etl_meta_unit where regexp_like(unit_id,'(^5)');

--reult:
   548.02
--------------------------------------------
--(4)
--$ 匹配行结束
--(5$) 5结束
select * from j1_dw.etl_meta_unit where regexp_like(unit_id,'(5$)');
--result:
       5029.05
--------------------------------------------
--(5)
--[] 匹配列表中任何一个表示的表达式的括号表达式
--[(5$),(^5)] 5开头或者5结尾

select * from j1_dw.etl_meta_unit where regexp_like(unit_id,'[(5$),(^5)]');
       --result:
       548.02
       934.05
--[((5|2)$)(^(1|5))] 5或者2开头，1或者5结尾
--或者[((5|2)$),(^(1|5))]
select * from j1_dw.etl_meta_unit where regexp_like(unit_id,'[((5|2)$)(^(1|5))]');

---------------------------------------------
--(6)
--[^exp] 括号中正则表达式的否定表达

----------------------------------------------
--(7)
--{m}精确匹配m次
--(X){2} 精确匹配2次X
select * from j1_ldcx.etl_meta_unit where regexp_like(unit_code,'(X){2}');
  --result:
  P_DM0_YHS_DJHZXX
---------------------------------------------
--(8)
--[::] 指定一个字符类，匹配该类中任意字符

---------------------------------------------
--(9)
--\
--四种含义：1，代表自身；2，引用下一个字符；3，引入一个操作符；4，do nothing
---------------------------------------------
--(10)
--+
--匹配一个或者多个事件
---------------------------------------------
--(11)
--?
--匹配0个或者一个事件
--****oracle 11g不建议使用
----------------------------------------------
--(12)
--. 匹配任意支持的字符，NULL除外
--(X){2}.(Z){2}(Q){2}精确匹配X两次，Z两次，Q两次
select * from j1_ldcx.etl_meta_unit where regexp_like(unit_code,'(X){2}.(Z){2}(Q){2}');
--result:
       P_DM0_ZK_SWDJXXWZZQQKQC
       P_DM2_ZK_SWDJXXWZZQQKTJ
--=============================================
--(13)
--()
--分组表达式，当做一个单独的子表达式
---------------------------------------------
--(14)
--\n
--返回引用表达式
---------------------------------------------
--(15)
--[==]
--指定等价类
---------------------------------------------
--(16)
--[..]
--指定一个排序元素；

/*=====================================================
Perl正则表达式扩展
--除了POSXI标准，oracle支持Perl_influenced元字符
=======================================================*/
--\d  一个数字字符
--\D  一个非数字字符
--\w  一个字母字符
--\W  一个非字母字符
--\s  一个空白字符
--\S  一个非空白字符
--\A  匹配开头的字符
--\Z  匹配结束字符，或者换行符
--\z  匹配结束的字符
--*?  匹配0或者更多次
--+?  匹配1或者更多次
--??  匹配0或者1次
--{n}? 匹配n次
--{n，m}? 匹配大于n次，小于M次

/*=====================================================
oracle 正则表达式使用技巧

--(1)使用正则表达式检查约束条件
--当定义检查约束之后，可以添加正则表达式条件来检查数据是否符合约束
=======================================================*/

--(1)添加unit_code约束，PKG开头
alter table etl_meta_unit_bak add constraint etl_meta_unit_unit_code
check(regexp_like(unit_code,'(^PKG)')) enable novalidate;

--test
insert into etl_meta_unit_bak(unit_id,unit_code) values('5500.02','p_test')
 --ORA-02290: check constraint (J1_LDM.ETL_META_UNIT_UNIT_CODE) violated

--(2)添加unit_id约束，有点
alter table etl_meta_unit_bak add constraint etl_meta_unit_unit_id
check(regexp_like(unit_id,'\.')) enable novalidate;

--test
insert into etl_meta_unit_bak(unit_id,unit_code) values('5500','PKG')
--ORA-02290: check constraint (J1_LDM.ETL_META_UNIT_UNIT_ID) violated




