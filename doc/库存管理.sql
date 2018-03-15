prompt Importing table SYS_PERMISSION...
set feedback off
set define off
insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select t.permission_id from SYS_PERMISSION t WHERE t.name LIKE '%基础库房%'), '库存账户查询', null, 3, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/stock/stockaccsub.jsp', 'icon-brchCuteDayBal', 'A', '库存分账户查询', to_date('09-09-2015 23:58:45', 'dd-mm-yyyy hh24:mi:ss'), to_date('09-09-2015 23:58:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select t.permission_id from SYS_PERMISSION t WHERE t.name LIKE '%基础库房%'), '库存明细查询', null, 7, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/stock/stocklistmain.jsp', 'icon-db', 'A', '库存明细查询;查询库存物品信息', to_date('09-09-2015 15:27:05', 'dd-mm-yyyy hh24:mi:ss'), to_date('09-09-2015 15:27:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select t.permission_id from SYS_PERMISSION t WHERE t.name LIKE '%基础库房%'), '柜员上交', null, 2, 'javascript:void(0)', 'F', 'Y', 'closed', '/stockManage/stockManageAction!toTellerSj.action', 'icon-zhcx', 'A', null, to_date('10-09-2015', 'dd-mm-yyyy'), to_date('10-09-2015 11:19:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

prompt Done.
