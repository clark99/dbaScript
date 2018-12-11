--查看阻塞锁
SELECT (   '节点 '
          || a.inst_id
          || ' session '
          || a.sid
          || ','
          || a_s.serial#
          || ' 阻塞了 节点 '
          || b.inst_id
          || ' session '
          || b.sid
          || ','
          || b_s.serial#)
            blockinfo,
         a.inst_id,
         a_s.sid,
         a_s.schemaname,
         a_s.module,
         a_s.status,
         a.TYPE lock_type,
         a.id1,
         a.id2,
         DECODE (a.lmode,
                 0, 'none',
                 1, NULL,
                 2, 'row-S (SS)',
                 3, 'row-X (SX)',
                 4, 'share (S)',
                 5, 'S/Row-X (SSX)',
                 6, 'exclusive (X)')
            lock_mode,
         '后为被阻塞信息' remark_flag,
         b.inst_id blocked_inst_id,
         b_s.sid blocked_sid,
         b.TYPE blocked_lock_type,
         DECODE (b.request,
                 0, 'none',
                 1, NULL,
                 2, 'row-S (SS)',
                 3, 'row-X (SX)',
                 4, 'share (S)',
                 5, 'S/Row-X (SSX)',
                 6, 'exclusive (X)')
            blocked_lock_request,
         b_s.schemaname blocked_schemaname,
         b_s.module blocked_module,
         b_s.status blocked_status,
         b_s.sql_id blocked_sql_id,
         obj.owner blocked_owner,
         obj.object_name blocked_object_name,
         obj.object_type blocked_object_type/*,
         CASE
            WHEN b_s.row_wait_obj# <> -1
            THEN
               DBMS_ROWID.rowid_create (1,
                                        obj.data_object_id,
                                        b_s.row_wait_file#,
                                        b_s.row_wait_block#,
                                        b_s.row_wait_row#)
            ELSE
               '-1'
         END
            blocked_rowid,  --被阻塞数据的rowid
         DECODE (obj.object_type,
                 'TABLE',    'select * from '
                          || obj.owner
                          || '.'
                          || obj.object_name
                          || ' where rowid='''
                          || DBMS_ROWID.rowid_create (1,
                                                      obj.data_object_id,
                                                      b_s.row_wait_file#,
                                                      b_s.row_wait_block#,
                                                      b_s.row_wait_row#)
                          || '''',
                 NULL)
            blocked_data_querysql*/
    FROM gv$lock a,
         gv$lock b,
         gv$session a_s,
         gv$session b_s,
         dba_objects obj
   WHERE     a.id1 = b.id1
         AND a.id2 = b.id2
         AND a.block > 0    --阻塞了其他人
         AND b.request > 0
         AND (   (a.inst_id = b.inst_id AND a.sid <> b.sid)
              OR (a.inst_id <> b.inst_id))
         AND a.sid = a_s.sid
         AND a.inst_id = a_s.inst_id
         AND b.sid = b_s.sid
         AND b.inst_id = b_s.inst_id
         AND b_s.row_wait_obj# = obj.object_id(+)
ORDER BY a.inst_id, a.sid;
