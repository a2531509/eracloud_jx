prompt Importing table SYS_PERMISSION...
set feedback off
set define off
insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (SELECT PERMISSION_ID FROM Sys_Permission WHERE NAME='设备管理'), '卡商管理', null, 4, 'baseVendor', 'F', 'Y', 'closed', 'jsp/baseVendor/baseVendor.jsp', 'icon-orgAccManage', 'A', '卡商信息管理', to_date('27-09-2015', 'dd-mm-yyyy'), to_date('27-09-2015 11:31:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (SELECT PERMISSION_ID FROM Sys_Permission WHERE NAME='设备管理'), '票据管理', null, 8, 'baseBill', 'F', 'Y', 'closed', 'jsp/baseBill/baseBill.jsp', 'icon-print', 'A', '票据管理', to_date('29-09-2015 14:54:14', 'dd-mm-yyyy hh24:mi:ss'), to_date('29-09-2015 14:54:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

prompt Done.
