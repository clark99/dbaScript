select dump('徐长亮',16) from dual--16进制
--Typ=96 Len=9: e5,be,90,e9,95,bf,e4,ba,ae
select dump('徐长亮',1016) from dual--16进制
--Typ=96 Len=9 CharacterSet=AL32UTF8: e5,be,90,e9,95,bf,e4,ba,ae
--注：typ=1表示varchar2,typ=2表示number,type=96表示char
    --len表示该字符串所在的字节；GBK一个汉字需要2个字节，UTF8一个汉字占3个字节
select to_number('e5be90','xxxxxx') from dual;--15056528
select to_number('e995bf','xxxxxx') from dual;--15308223
select to_number('e4baae','xxxxxx') from dual;--14989998
select chr(15056528)||chr(15308223)||chr(14989998) from dual;--徐长亮
select ascii('徐') from dual  --15056528
select ascii('长') from dual  --15308223
select ascii('亮') from dual  --14989998