select owner,
       object_name,
       object_type,
       'alter ' ||
       decode(t.OBJECT_TYPE, 'PACKAGE BODY', 'PACKAGE', t.OBJECT_TYPE) || ' ' ||
       t.OWNER || '.' || t.OBJECT_NAME || ' compile;'
  from dba_objects t
 where status = 'INVALID'
   and object_type in
       ('PACKAGE', 'PACKAGE BODY'/*, 'PROCEDURE', 'FUNCTION'*/, 'VIEW')
   and owner in
       ('')
 order by owner, object_type;
