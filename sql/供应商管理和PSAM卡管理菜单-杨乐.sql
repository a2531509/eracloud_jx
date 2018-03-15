prompt Importing table SYS_PERMISSION...
set feedback off
set define off
insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (SELECT PERMISSION_ID FROM Sys_Permission WHERE NAME='合作机构'), '供应商管理', null, 3, 'BaseProvider', 'F', 'Y', 'closed', 'jsp/baseProvider/baseProvider.jsp', 'icon-orgOpenAcc', 'A', '供应商信息管理', to_date('20-09-2015', 'dd-mm-yyyy'), to_date('24-09-2015 15:53:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (SELECT PERMISSION_ID FROM Sys_Permission WHERE NAME='PASM卡管理'), 'PSAM卡管理', null, 1, 'basePsam', 'F', 'Y', 'closed', 'jsp/basePsam/basePsam.jsp', 'icon-dzqbcz', 'A', 'PSAM卡管理', to_date('21-09-2015', 'dd-mm-yyyy'), to_date('24-09-2015 15:52:35', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

prompt Done.
