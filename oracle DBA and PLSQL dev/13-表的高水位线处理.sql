SELECT OWNER,
       SEGMENT_NAME TABLE_NAME,
       GREATEST(ROUND(100 * (NVL(HWM - AVG_USED_BLOCKS, 0) /
                      GREATEST(NVL(HWM, 1), 1)),
                      2),
                0) || '%' WASTE_PER,
       ROUND(BYTES / 1024 / 1024 / 1024, 2) TABLE_GB,
       NUM_ROWS,
       SEGMENT_TYPE
       --,O_TABLESPACE_NAME TABLESPACE_NAME
  FROM (SELECT A.OWNER OWNER,
               A.SEGMENT_NAME,
               A.SEGMENT_TYPE,
               A.BYTES,
               B.NUM_ROWS,
               A.BLOCKS BLOCKS,
               A.BLOCKS - B.EMPTY_BLOCKS - 1 HWM,
               DECODE(ROUND((B.AVG_ROW_LEN * NUM_ROWS *
                            (1 + (PCT_FREE / 100))) / C.BLOCKSIZE,
                            0),
                      0,
                      1,
                      ROUND((B.AVG_ROW_LEN * NUM_ROWS *
                            (1 + (PCT_FREE / 100))) / C.BLOCKSIZE,
                            0)) + 2 AVG_USED_BLOCKS,
               B.TABLESPACE_NAME O_TABLESPACE_NAME
          FROM SYS.DBA_SEGMENTS A, SYS.DBA_TABLES B, SYS.TS$ C
         WHERE A.OWNER = B.OWNER
           and SEGMENT_NAME = TABLE_NAME
           and SEGMENT_TYPE = 'TABLE'
           AND B.TABLESPACE_NAME = C.NAME
        UNION ALL
        SELECT A.OWNER OWNER,
               SEGMENT_NAME,
               'PARTITION TABLE' as SEGMENT_TYPE,
               sum(BYTES),
               sum(B.NUM_ROWS),
               sum(A.BLOCKS) BLOCKS,
               sum(A.BLOCKS - B.EMPTY_BLOCKS - 1) HWM,
               sum(DECODE(ROUND((B.AVG_ROW_LEN * B.NUM_ROWS *
                                (1 + (B.PCT_FREE / 100))) / C.BLOCKSIZE,
                                0),
                          0,
                          1,
                          ROUND((B.AVG_ROW_LEN * B.NUM_ROWS *
                                (1 + (B.PCT_FREE / 100))) / C.BLOCKSIZE,
                                0)) + 2) AVG_USED_BLOCKS,
               B.TABLESPACE_NAME O_TABLESPACE_NAME
          FROM SYS.DBA_SEGMENTS       A,
               SYS.DBA_TAB_PARTITIONS B,
               SYS.TS$                C,
               SYS.DBA_TABLES         D
         WHERE A.OWNER = B.TABLE_OWNER
           and SEGMENT_NAME = B.TABLE_NAME
           and SEGMENT_TYPE = 'TABLE PARTITION'
           AND B.TABLESPACE_NAME = C.NAME
           AND D.OWNER = B.TABLE_OWNER
           AND D.TABLE_NAME = B.TABLE_NAME
           AND A.PARTITION_NAME = B.PARTITION_NAME
         group by A.OWNER, SEGMENT_NAME, B.TABLESPACE_NAME)
 WHERE O_TABLESPACE_NAME = 'TS_DW_DATA' --过滤表空间 
   AND OWNER = 'J1_DW'                  --过滤用户
   AND GREATEST(ROUND(100 * (NVL(HWM - AVG_USED_BLOCKS, 0) /
                      GREATEST(NVL(HWM, 1), 1)),
                      2),
                0) > 30 --段的空间浪费百分大于30%
   AND BLOCKS > 32768 --size大于1G
 ORDER BY 5 DESC, 4 DESC;
