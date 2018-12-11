SELECT OWNER,
       SEGMENT_NAME TABLE_NAME,
       SEGMENT_TYPE,
       GREATEST(ROUND(100 * (NVL(HWM - AVG_USED_BLOCKS, 0) /
                      GREATEST(NVL(HWM, 1), 1)),
                      2),
                0) WASTE_PER,
       ROUND(BYTES / 1024/1024/1024, 2) TABLE_GB,
       NUM_ROWS,
       BLOCKS,
       EMPTY_BLOCKS,
       HWM HIGHWATER_MARK,
       AVG_USED_BLOCKS,
/*       CHAIN_PER,
       EXTENTS,
       MAX_EXTENTS,
       ALLO_EXTENT_PER,*/
/*       DECODE(GREATEST(MAX_FREE_SPACE - NEXT_EXTENT, 0), 0, 'N', 'Y') CAN_EXTEND_SPACE,
*//*       NEXT_EXTENT,*/
/*       MAX_FREE_SPACE,*/
       O_TABLESPACE_NAME TABLESPACE_NAME
  FROM (SELECT A.OWNER OWNER,
               A.SEGMENT_NAME,
               A.SEGMENT_TYPE,
               A.BYTES,
               B.NUM_ROWS,
               A.BLOCKS BLOCKS,
               B.EMPTY_BLOCKS EMPTY_BLOCKS,
               A.BLOCKS - B.EMPTY_BLOCKS - 1 HWM,
               DECODE(ROUND((B.AVG_ROW_LEN * NUM_ROWS *
                            (1 + (PCT_FREE / 100))) / C.BLOCKSIZE,
                            0),
                      0,
                      1,
                      ROUND((B.AVG_ROW_LEN * NUM_ROWS *
                            (1 + (PCT_FREE / 100))) / C.BLOCKSIZE,
                            0)) + 2 AVG_USED_BLOCKS,
            /*   ROUND(100 *
                     (NVL(B.CHAIN_CNT, 0) / GREATEST(NVL(B.NUM_ROWS, 1), 1)),
                     2) CHAIN_PER,
               ROUND(100 * (A.EXTENTS / A.MAX_EXTENTS), 2) ALLO_EXTENT_PER,
               A.EXTENTS EXTENTS,
               A.MAX_EXTENTS MAX_EXTENTS,
               B.NEXT_EXTENT NEXT_EXTENT,*/
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
               sum(B.EMPTY_BLOCKS) EMPTY_BLOCKS,
               sum(A.BLOCKS - B.EMPTY_BLOCKS - 1) HWM,
               sum(DECODE(ROUND((B.AVG_ROW_LEN * B.NUM_ROWS *
                            (1 + (B.PCT_FREE / 100))) / C.BLOCKSIZE,
                            0),
                      0,
                      1,
                      ROUND((B.AVG_ROW_LEN * B.NUM_ROWS *
                            (1 + (B.PCT_FREE / 100))) / C.BLOCKSIZE,
                            0)) + 2) AVG_USED_BLOCKS,
              /* sum(ROUND(100 *
                     (NVL(B.CHAIN_CNT, 0) / GREATEST(NVL(B.NUM_ROWS, 1), 1)),
                     2)) CHAIN_PER,
               sum(ROUND(100 * (A.EXTENTS / A.MAX_EXTENTS), 2)) ALLO_EXTENT_PER,
               sum(A.EXTENTS) EXTENTS,
               sum(A.MAX_EXTENTS) MAX_EXTENTS,
               sum(B.NEXT_EXTENT,*/
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
           group by A.OWNER,SEGMENT_NAME,B.TABLESPACE_NAME)
 WHERE O_TABLESPACE_NAME='TS_DW_DATA'
   AND GREATEST(ROUND(100 * (NVL(HWM - AVG_USED_BLOCKS, 0) /
                      GREATEST(NVL(HWM, 1), 1)),
                      2),
                0) > 25
   AND OWNER = 'J1_DW'
   AND BLOCKS > 128
 ORDER BY 5 DESC, 4 ASC, 7 ASC;
