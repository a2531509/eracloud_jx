prompt Importing table sys_permission...
set feedback off
set define off
insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '��ֽ���' ), '���ֹ���', '��ֽ���', 5, 'pointManager', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-merSettleYear', 'A', '���ֹ���', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('09-09-2015 16:14:25', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '���ֹ���' ), '���ֲ�������', '���ֹ���', 1, 'pointParaManage', 'F', 'Y', 'closed', '/jsp/pointManger/pointParaMain.jsp', 'icon-itemManage', 'A', '��������', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('09-09-2015 16:43:03', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '���ֲ�������' ), '���ֲ������', '���ֲ�������', 1, 'addPointPara', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '���ֲ������', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('10-09-2015 11:49:37', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '���ֲ�������' ), '���ֲ����༭', '���ֲ�������', 2, 'editPointPara', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '���ֲ����༭', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('10-09-2015 11:50:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '���ֲ�������' ), '���ֲ���ע��', '���ֲ�������', 3, 'cancelPointPara', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'A', '���ֲ���ע��', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('10-09-2015 11:50:33', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '���ֲ�������' ), '���ֲ�������', '���ֲ�������', 4, 'activePointPara', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '���ֲ�������', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('10-09-2015 11:50:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '���ֲ�������' ), '���ֲ���ɾ��', '���ֲ�������', 5, 'delPointPara', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '���ֲ���ɾ��', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('10-09-2015 11:51:20', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '���ֹ���' ), '��������ѯ', '���ֹ���', 2, 'queryPointBal', 'F', 'Y', 'closed', '/jsp/pointManger/queryPointBalMain.jsp', 'icon-merSettleYear', 'A', '��������ѯ', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('09-09-2015 16:27:50', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into sys_permission (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (seq_func_id.nextval, (select PERMISSION_ID from sys_permission t where t.name = '���ֹ���' ), '������ϸ��ѯ', '���ֹ���', 3, 'queryPointDetail', 'F', 'Y', 'closed', '/jsp/pointManger/queryPointDetailMain.jsp', 'icon-merSettleYear', 'A', '������ϸ��ѯ', to_date('09-09-2015', 'dd-mm-yyyy'), to_date('09-09-2015 16:28:12', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);


prompt Done.
