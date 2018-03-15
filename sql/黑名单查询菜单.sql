prompt Importing table SYS_PERMISSION...
set feedback off
set define off
insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval,(select t.permission_id from SYS_PERMISSION t WHERE t.name = '柜面业务查询'), '卡黑名单查询', null, 5, 'javascript:void(0)', 'F', 'Y', 'closed', 'jsp/statistics/blackrecord.jsp', 'icon-accManage', 'A', null, to_date('11-09-2015', 'dd-mm-yyyy'), to_date('13-09-2015 04:17:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

prompt Done.
