SELECT OWNER,
       object_name,
       object_type,
       'alter ' || decode(t.OBJECT_TYPE, 'PACKAGE BODY', 'PACKAGE', t.OBJECT_TYPE) || ' ' || t.OWNER || '.' || t.OBJECT_NAME || ' compile;'
FROM dba_objects t
WHERE status = 'INVALID'
  AND object_type IN ('PACKAGE',
                      'PACKAGE BODY',
                      'PROCEDURE',
                      'FUNCTION' ,
                      'VIEW')
--  AND OWNER IN ('')
ORDER BY OWNER,
         object_type;



 
