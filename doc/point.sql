prompt Importing table sys_permission...
set feedback off
set define off
insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '清分结算' ), '积分管理', '清分结算', 5, 'pointManager', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-merSettleYear', 'A', '积分管理', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('09-09-2015 16:14:25', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '积分管理' ), '积分参数设置', '积分管理', 1, 'pointParaManage', 'F', 'Y', 'closed', '/jsp/pointManger/pointParaMain.jsp', 'icon-itemManage', 'A', '参数设置', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('09-09-2015 16:43:03', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '积分参数设置' ), '积分参数添加', '积分参数设置', 1, 'addPointPara', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '积分参数添加', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('10-09-2015 11:49:37', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '积分参数设置' ), '积分参数编辑', '积分参数设置', 2, 'editPointPara', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '积分参数编辑', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('10-09-2015 11:50:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '积分参数设置' ), '积分参数注销', '积分参数设置', 3, 'cancelPointPara', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'A', '积分参数注销', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('10-09-2015 11:50:33', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '积分参数设置' ), '积分参数激活', '积分参数设置', 4, 'activePointPara', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '积分参数激活', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('10-09-2015 11:50:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '积分参数设置' ), '积分参数删除', '积分参数设置', 5, 'delPointPara', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '积分参数删除', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('10-09-2015 11:51:20', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '积分管理' ), '积分余额查询', '积分管理', 2, 'queryPointBal', 'F', 'Y', 'closed', '/jsp/pointManger/queryPointBalMain.jsp', 'icon-merSettleYear', 'A', '积分余额查询', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('09-09-2015 16:27:50', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '积分管理' ), '积分明细查询', '积分管理', 3, 'queryPointDetail', 'F', 'Y', 'closed', '/jsp/pointManger/queryPointDetailMain.jsp', 'icon-merSettleYear', 'A', '积分明细查询', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('09-09-2015 16:28:12', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);


prompt Done.
