--------------------------------------------------------------------------------------------
----创建时间：2016-04-11
----创建目的：检查中指向落地表的同义词，并且更正
----创建人：徐长亮
---- 注：需要输入dblink: select * from dba_db_links where owner='PUBLIC' 
--------------------------------------------------------------------------------------------
DECLARE
  LVC_SQL VARCHAR2(4000);
  --HX_ZGXT同义词还原
  CURSOR CUR_HX IS
    SELECT 'CREATE OR REPLACE SYNONYM HX_ZGXT.' || A.TABLE_NAME || ' FOR ' ||
           A.OWNER || '.' || A.TABLE_NAME || '@' || '&SJQFK_DBLINK' SYNONYM_SQL
      FROM ALL_TABLES@ &SJQFK_DBLINK A, DBA_SYNONYMS B
     WHERE B.OWNER = ''
       AND B.TABLE_OWNER IN ()
       AND A.TABLE_NAME = B.SYNONYM_NAME
       AND A.TABLE_NAME NOT LIKE '%$%'
       AND A.OWNER IN ('')
     ORDER BY A.OWNER, A.TABLE_NAME;
BEGIN
  --还原HX_ZGXT同义词
  FOR MYCUR IN CUR_HX LOOP
    BEGIN
      LVC_SQL := MYCUR.SYNONYM_SQL;
      EXECUTE IMMEDIATE LVC_SQL;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('创建同义词失败.' ||
                             TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') ||
                             ', SQLCODE:' || TO_CHAR(SQLCODE) || SQLERRM);
    END;
  END LOOP;
END;