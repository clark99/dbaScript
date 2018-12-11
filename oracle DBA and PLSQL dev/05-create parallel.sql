CREATE TABLE J1_DW.SB_YSBTJ AS SELECT /*+PARALLEL(8) */* FROM HX_ZGXT.SB_YSBTJ;
create index J1_DW.I_SB_SBB_SBUUID on J1_DW.sb_sbb(sbuuid) parallel 32 tablespace ts_DW_idx;
create index J1_DW.I_SB_SBB_pzxh on J1_DW.sb_sbb(pzxh) parallel 32 tablespace ts_DW_idx;
alter index J1_DW.I_SB_SBB_SBUUID noparallel;
alter index J1_DW.I_SB_SBB_pzxh noparallel;