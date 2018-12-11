set user=system
set password=system
set ORACLE_SID=ds_qjbj1dw


sqlplus %user%/%password%@%ORACLE_SID% @./init-object.sql

pause