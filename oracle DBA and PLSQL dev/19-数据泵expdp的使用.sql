
1.impdp dblink

impdp system/system full=y directory=dump_dir dumpfile='database link' include=db_link VERSION=11.2.0.1

2.expdp

expdp system/oracle123 directory=exp_dir TABLES=j1_ldm.ldmt02_ye_sfxx dumpfile=sfxx20151230%U.dmp logfile=exp_sfxx20151230.LOG PARALLEL=8 filesize=10g CONTENT=DATA_ONLY compression=all


3.impdp

impdp system/oracle123 directory=exp_dir TABLES=j1_ldm.ldmt02_ye_sfxx dumpfile=sfxx20151230%U.dmp logfile=imp_sfxx20151230.LOG PARALLEL=8
