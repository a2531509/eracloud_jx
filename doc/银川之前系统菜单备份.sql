prompt Importing table SYS_PERMISSION...
set feedback off
set define off
insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10343, 965, '���������޸�', '�������', 3, 'TradingPassword', 'F', 'Y', 'closed', '/jsp/pwdservice/paypwdmodify.jsp', 'icon-sys', 'A', '��Ƭ�����˻�֧������', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('15-06-2015 12:30:47', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10344, 965, '������������', '�������', 4, 'TradingPassword', 'F', 'Y', 'closed', '/jsp/pwdservice/paypwdreset.jsp', 'icon-comp', 'A', '�������˻�֧����������', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('15-06-2015 12:31:18', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10345, 1066, '������', '�ֽ����', 3, 'BranchCk', 'F', 'Y', 'closed', '/cashManage/cashManageAction!toBranchDeposit.action', 'icon-orgBranchAccoutManage', 'A', '������', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('29-05-2015 20:28:55', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10346, 1082, 'Ǯ���˻���ֵ', '��ֵҵ��', 1, 'Dzqb', 'F', 'Y', 'closed', '/jsp/rechargeservice/offlineaccountrecharge.jsp', 'icon-dzqbcz', 'A', '����Ǯ����ֵ', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('02-06-2015 10:05:44', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10347, 1082, '�����˻���ֵ', '��ֵҵ��', 2, 'onlineaccountrecharge', 'F', 'Y', 'closed', '/jsp/rechargeservice/onlineaccountrecharge.jsp', 'icon-ljcz', 'A', '�����˻���ֵ', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('05-06-2015 09:36:46', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10348, 1082, 'Ǯ����ֵ����', '��ֵҵ��', 3, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/rechargeservice/undoofflineaccrecharge.jsp', 'icon-dzqbcx', 'A', '����Ǯ������', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('07-06-2015 09:35:24', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10349, 1082, '������ֵ����', '��ֵҵ��', 4, 'UndoRecharge', 'F', 'Y', 'closed', '/jsp/rechargeservice/undoonlineaccrecharge.jsp', 'icon-ljcx', 'A', '������ֵ����', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('05-06-2015 15:53:30', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10350, 963, '��Ƭע��', '��Ƭ����', 5, 'zxCard', 'F', 'Y', 'closed', '/jsp/cardService/cardzx.jsp', 'icon-zx', 'A', '��Ƭע��', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('27-05-2015 19:18:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10354, 4119, '�����˻�����', '�����˻�����', 1, 'merAccConsAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '�����˻�����', to_date('27-05-2015', 'dd-mm-yyyy'), to_date('27-05-2015 16:52:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10355, 4119, '�����˻��༭', '�����˻�����', 2, 'merAccConsEidt', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '�����˻��༭', to_date('27-05-2015 16:52:56', 'dd-mm-yyyy hh24:mi:ss'), to_date('27-05-2015 16:52:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10428, null, 'ͳ�Ʋ�ѯ', null, 6, 'Statisticalinquiry', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-comp', 'A', 'ϵͳͳ�Ʋ�ѯ', to_date('30-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:15:00', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10429, 10428, '�����ѯ', 'ͳ�Ʋ�ѯ', 3, 'GMQuery', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-orgOpenAcc', 'A', '�����ѯ', to_date('30-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:15:13', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10430, 10429, 'ҵ��ƾ֤��ѯ', '�����ѯ', 2, 'pzQuery', 'F', 'Y', 'closed', '/jsp/statistics/voucher.jsp', 'icon-db', 'A', 'ҵ��ƾ֤��ѯ', to_date('30-05-2015', 'dd-mm-yyyy'), to_date('01-06-2015 23:48:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10465, 10346, 'Ǯ���˻�����', 'Ǯ���˻���ֵ', 1, 'OfflineRechargeReadCard', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', 'Ǯ���˻���ֵ����', to_date('05-06-2015 16:23:58', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-06-2015 16:23:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10466, 10346, 'Ǯ���˻���ֵ����', 'Ǯ���˻���ֵ', 2, 'OfflineRechargeSave', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', 'Ǯ���˻���ֵ����', to_date('05-06-2015 16:25:33', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-06-2015 16:25:33', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10485, 10349, '�����˻���ֵ��������', '������ֵ����', 3, 'onlinerechargecanelreadcard', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', null, to_date('06-06-2015 14:51:33', 'dd-mm-yyyy hh24:mi:ss'), to_date('06-06-2015 14:51:33', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10486, 10349, '�����˻���ֵ���������֤', '������ֵ����', 4, 'onlinerechargecanelreadidcard', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', null, to_date('06-06-2015 14:53:49', 'dd-mm-yyyy hh24:mi:ss'), to_date('06-06-2015 14:53:49', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10641, 10638, '�ƿ���������', '��������', 3, 'cardProMade', 'F', 'Y', 'closed', 'jsp/madeCardPro.jsp', 'icon-madeCardPro', 'A', '�ƿ���������', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:33:24', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10739, 4108, '����ģʽ����', '�̻�����', 4, 'consumeModeMag', 'F', 'Y', 'closed', 'jsp/merchant/merConsumeMode.jsp', 'icon-merchantMag', 'A', '����ģʽ����', to_date('24-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:04:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10740, 10739, '����ģʽ����', '�̻�����ģʽ', 1, 'addConsumeMode', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '����ģʽ����', to_date('24-06-2015', 'dd-mm-yyyy'), to_date('25-06-2015 15:01:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10741, 10739, '����ģʽ�޸�', '�̻�����ģʽ', 2, 'editConsumeMode', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-edit', 'A', '����ģʽ�޸�', to_date('24-06-2015', 'dd-mm-yyyy'), to_date('24-06-2015 16:00:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10742, 10739, '����ģʽɾ��', '�̻�����ģʽ', 3, 'delComsumeMode', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '����ģʽɾ��', to_date('24-06-2015 15:59:42', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-06-2015 15:59:42', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10759, 1082, '�Ҽ�¼����', '��ֵҵ��', 7, 'DealAsRecord', 'F', 'Y', 'closed', '/jsp/rechargeservice/dealashrecord.jsp', 'icon-export', 'A', '�Ҽ�¼����', to_date('26-06-2015', 'dd-mm-yyyy'), to_date('26-06-2015 13:51:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10779, 963, '����', '��Ƭ����', 6, 'cardService', 'F', 'Y', 'closed', '/jsp/cardService/acccashback.jsp', 'icon-undo', 'A', '����', to_date('17-07-2015', 'dd-mm-yyyy'), to_date('17-07-2015 17:33:32', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10780, 10429, '��ֵ���Ѳ�ѯ', '�����ѯ', 4, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/statistics/consumerecord.jsp', 'icon-orgBranchAccoutManage', 'A', null, to_date('18-07-2015 11:16:17', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-07-2015 11:16:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10419, 10345, '������ȷ�ϴ��', '������', 1, 'certainDeposit', 'O', 'Y', 'open', 'javascript:void(0)', 'icon-save', 'A', '������ȷ�ϴ��', to_date('29-05-2015', 'dd-mm-yyyy'), to_date('29-05-2015 23:38:57', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10431, 4080, '�̻��ն˹���', '��������', 9, 'terminalMag', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-termMag', 'I', '�̻��ն˹���', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:07:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10432, 10430, 'ƾ֤��ѯ', 'ҵ��ƾ֤��ѯ', 1, 'voucherQuery', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', 'ƾ֤��ѯ,ִ�в�ѯ', to_date('01-06-2015 17:27:05', 'dd-mm-yyyy hh24:mi:ss'), to_date('01-06-2015 17:27:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10433, 10430, 'ƾ֤Ԥ����ӡ', 'ҵ��ƾ֤��ѯ', 2, 'voucherView', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', 'ƾ֤Ԥ�������д�ӡ', to_date('01-06-2015 17:29:17', 'dd-mm-yyyy hh24:mi:ss'), to_date('01-06-2015 17:29:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10665, 10640, '�������', '�ƿ��������', 0, 'taskReBack', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-undo', 'A', '�������', to_date('13-06-2015', 'dd-mm-yyyy'), to_date('14-08-2015 11:48:03', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4086, 11101, '�̻����͹���', '�̻�����', 1, 'merchantQues', 'F', 'Y', 'closed', 'jsp/merchant/merchantTypeMain.jsp', 'icon-merchantQues', 'A', '�̻����͹���', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:52:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4106, 4080, '�̻��������', '��������', 8, 'merSettleParam', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-mersettlePara', 'I', '�̻��������', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:05:42', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4108, 10859, '�̻�����', '��ֽ���', 3, 'merSettle', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-merchantsettle', 'A', '�̻�����', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:03:37', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4080, null, '��������', null, 3, 'merchantMag', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-merchantMag', 'A', '��������', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:49:46', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4084, 11101, '�̻������Ǽ�', '�̻�����', 2, 'merchantMsgMag', 'F', 'Y', 'closed', 'jsp/merchant/merchantRegistMain.jsp', 'icon-merchantDown', 'A', '�̻������Ǽ�', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:51:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4230, 1066, '��Ա����', '�ֽ����', 2, 'toTellerTransferIndex', 'F', 'Y', 'closed', '/cashManage/cashManageAction!toTellerTransferIndex.action', 'icon-role', 'A', '��Ա�ֽ����', to_date('25-05-2015', 'dd-mm-yyyy'), to_date('25-05-2015 15:05:51', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4232, 4084, '�̻���ϢԤ��', '�̻���Ϣά��', 1, 'viewMerchantInfo', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-undo', 'A', '�̻���ϢԤ��', to_date('25-05-2015 17:35:27', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-05-2015 17:35:27', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4234, 4084, '�̻�����', '�̻���Ϣά��', 2, 'merchantAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '�̻�����', to_date('25-05-2015 17:36:21', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-05-2015 17:36:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4236, 4084, '�̻��༭', '�̻���Ϣά��', 3, 'merchantEidt', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '�̻��༭', to_date('25-05-2015', 'dd-mm-yyyy'), to_date('25-05-2015 17:37:54', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4053, 40, '�����˻�����', '�������', 4, 'brchAccOpen', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-orgOpenAcc', 'A', '�����˻�����', to_date('22-05-2015', 'dd-mm-yyyy'), to_date('22-05-2015 21:32:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (965, 968, '�������', '�������', 6, 'pwdservice', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-pwdService', 'A', null, to_date('24-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:24:08', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1066, 10830, '�ֽ����', '�˻�����', 5, 'CashManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-auto', 'A', null, to_date('24-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:59:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (963, 968, '��Ƭ����', '�������', 5, 'cardService', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-cardService', 'A', null, to_date('24-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:23:53', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (59, 1, '��������', 'ϵͳ����', 12, '11', 'F', 'N', 'closed', 'jsp/sysParameter/sysParameterMain.jsp', 'icon-remove', 'A', '111', to_date('17-06-2013', 'dd-mm-yyyy'), to_date('31-03-2015 18:57:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (968, null, '�������', null, 0, 'cardApp', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-counterServiceManage', 'A', '�������', to_date('04-04-2015', 'dd-mm-yyyy'), to_date('04-05-2015 20:40:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1088, 967, '�������', 'ϵͳ����', 2, 'brachManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-branchManage', 'A', '�������', to_date('26-04-2015', 'dd-mm-yyyy'), to_date('26-04-2015 14:18:04', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (967, null, 'ϵͳ����', null, 8, 'sysMgr', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-sys', 'A', 'ϵͳ����', to_date('23-05-2013', 'dd-mm-yyyy'), to_date('23-05-2015 11:31:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (2, 1, '��ʽ����', 'ϵͳ����', 0, 'funMgr', 'F', 'Y', 'closed', 'jsp/function/functionMain.jsp', 'icon-pro', 'A', '��ʽ����', to_date('23-05-2013', 'dd-mm-yyyy'), to_date('20-08-2015 09:36:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (2080, 965, '������������', '�������', 2, 'pwdserviceAction', 'F', 'Y', 'closed', '/jsp/pwdservice/servicepwdreset.jsp', 'icon-role', 'A', '���˷�����������', to_date('21-05-2015 09:43:17', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-05-2015 09:43:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1104, 1088, '�����˻�����', '�������', 2, 'orgBrchAcountManage', 'F', 'Y', 'closed', '2', 'icon-orgOpenAcc', 'I', '�����˻�����', to_date('26-04-2015', 'dd-mm-yyyy'), to_date('22-05-2015 21:30:35', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (7, 1, 'Ȩ�޷���', 'ϵͳ����', 3, 'funOMgr', 'F', 'Y', 'closed', 'jsp/permission/permissionAssignmentMain.jsp', 'icon-config', 'A', '�˵����ܷ���', to_date('23-05-2013', 'dd-mm-yyyy'), to_date('22-06-2013 09:15:57', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (40, 1088, '�������', '�������', 1, 'brchManage', 'F', 'Y', 'closed', 'jsp/organization/organizationMain.jsp', 'icon-branchEditMange', 'A', '�������', to_date('14-06-2013', 'dd-mm-yyyy'), to_date('22-05-2015 21:30:51', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (39, null, '1123123', null, 123, '123123', 'F', 'Y', 'closed', '32123', 'icon-edit', 'I', '123123123123', to_date('14-06-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (46, 1, '123123', 'ϵͳ����', 123, '2312', 'F', 'Y', 'closed', '1231', 'icon-back', 'I', '3123123123123', to_date('18-06-2013', 'dd-mm-yyyy'), to_date('18-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (32, 27, '�û������༭', 'ϵͳ����', 19, 'userEndEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-end', 'I', null, to_date('27-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (33, 27, '�û�����', 'ϵͳ����', 20, 'userSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'I', null, to_date('27-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (42, 40, '����༭', '�������', 1, 'brchEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('22-05-2015 21:31:22', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (43, 40, '����ɾ��', '�������', 2, 'brchDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('22-05-2015 21:31:40', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (37, 27, '�û�delll', '�û�����', 123, '123', 'O', 'Y', 'open', '123', 'icon-undo', 'I', '123123123', to_date('14-06-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (41, 40, '��������', '�������', 0, 'brchAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', null, to_date('14-06-2013', 'dd-mm-yyyy'), to_date('22-05-2015 21:31:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (31, 27, '�û�ɾ��', 'ϵͳ����', 18, 'userDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'A', null, to_date('27-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (23, 7, '��ɫ�༭', 'ϵͳ����', 11, 'roleEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '��ɫ�༭', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (24, 7, '��ɫɾ��', 'ϵͳ����', 12, 'roleDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '��ɫɾ��', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (21, 7, 'Ȩ�޷��䱣��', 'ϵͳ����', 9, 'perConfig', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-config', 'A', 'Ȩ�޷��䱣��', to_date('24-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (22, 7, '��ɫ����', 'ϵͳ����', 10, 'roleAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-role', 'A', '��ɫ����', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (29, 27, '�û�����', '�û�����', 16, 'userAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '123123123123', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('18-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (30, 27, '�û��༭', 'ϵͳ����', 17, 'userEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', null, to_date('27-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (25, 7, '��ɫ�����༭', 'ϵͳ����', 13, 'roleEndEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'I', '��ɫ�����༭', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (26, 7, '��ɫ����', 'ϵͳ����', 14, 'roleSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'I', '��ɫ����', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4082, 4080, '�̻��Ǽǹ���', '��������', 7, 'merchantAdd', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-merchantAdd', 'I', '�̻��Ǽǹ���', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:04:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4141, 4108, '�̻��������', '�̻�������Ϣ', 1, 'merSettleCK', 'F', 'Y', 'closed', 'jsp/merchant/merSettleCKMain.jsp', 'icon-merSettleCK', 'A', '�̻��������', to_date('24-05-2015', 'dd-mm-yyyy'), to_date('03-06-2015 11:36:51', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4143, 4108, '�̻����㴦��', '�̻�������Ϣ', 2, 'merSettleRS', 'F', 'Y', 'closed', 'jsp/merchant/merSettleRSMain.jsp', 'icon-merSettleRS', 'A', '�̻����㴦��', to_date('24-05-2015 11:14:16', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 11:14:16', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4145, 4108, '�̻�����֧��', '�̻�������Ϣ', 3, 'merSettlePay', 'F', 'Y', 'closed', 'jsp/merchant/merSettlePayMain.jsp', 'icon-merSettlePay', 'A', '�̻�����֧��', to_date('24-05-2015 11:15:11', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 11:15:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4147, 4108, '�̻������ѯ', '�̻�������Ϣ', 4, 'merSettleQuery', 'F', 'Y', 'closed', 'jsp/merchant/merSettleQueryMain.jsp', 'icon-merSettleQuery', 'A', '�̻������ѯ', to_date('24-05-2015 11:20:05', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 11:20:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4149, 4108, '�̻������±�', '�̻�������Ϣ', 5, 'merSettleMon', 'F', 'Y', 'closed', '/jsp/merchant/merSettleReportMonth.jsp', 'icon-merSettleMon', 'A', '�̻������±�', to_date('24-05-2015', 'dd-mm-yyyy'), to_date('01-09-2015 11:30:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4151, 4108, '�̻������걨', '�̻�������Ϣ', 6, 'merSettleYear', 'F', 'Y', 'closed', 'jsp/merchant/merSettleReportYear.jsp', 'icon-merSettleYear', 'A', '�̻������걨', to_date('24-05-2015', 'dd-mm-yyyy'), to_date('01-09-2015 11:30:39', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4153, 4108, '��ҵ������Ϣ', '�̻�������Ϣ', 7, 'merSettleInDus', 'F', 'Y', 'closed', 'jsp/merchant/merSettleInDusMain.jsp', 'icon-merSettleInDus', 'A', '��ҵ������Ϣ', to_date('24-05-2015 11:22:50', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 11:22:50', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4172, 4086, '��������', '�̻����͹���', 1, 'merTypeAdd', 'O', 'Y', 'open', 'javascript:void(0)', 'icon-adds', 'A', '��������', to_date('24-05-2015 17:25:23', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 17:25:23', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4174, 4086, '�����޸�', '�̻����͹���', 2, 'merTypeEite', 'O', 'Y', 'open', 'javascrpit:void(0);', 'icon-edit', 'A', '�����޸�', to_date('24-05-2015 17:26:26', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 17:26:26', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4176, 4086, 'Ԥ���̻�', '�̻����͹���', 3, 'TypeOnwMer', 'O', 'Y', 'open', 'javascrpit:void(0);', 'icon-merchantsettle', 'A', 'Ԥ���̻�', to_date('24-05-2015', 'dd-mm-yyyy'), to_date('24-05-2015 21:40:38', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4201, 1066, '�ֽ�β��', '�ֽ����', 1, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/cashmanage/cashbox.jsp', 'icon-orgManage', 'A', '��Ա�ֽ�β����Ϣ��ѯ', to_date('24-05-2015 21:02:32', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 21:02:32', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (3475, 3812, '������������', '�����˻�����', 2, 'orgCloseAcc', 'O', 'Y', 'open', 'javascript:void();', 'icon-cancel', 'I', '������������', to_date('21-05-2015', 'dd-mm-yyyy'), to_date('22-05-2015 19:03:39', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (3478, 1331, '����ע��', '��������', 3, 'orgCancel', 'O', 'Y', 'open', 'javascript:void()', 'icon-remove', 'A', '����ע��', to_date('21-05-2015', 'dd-mm-yyyy'), to_date('21-05-2015 14:09:08', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (3812, 1095, '�����˻�����', '��������', 3, 'orgAccManage', 'F', 'N', 'closed', 'jsp/orgManage/orgCloseMain.jsp', 'icon-orgCloseAcc', 'I', '�����˻�����', to_date('22-05-2015', 'dd-mm-yyyy'), to_date('22-05-2015 19:03:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4101, 11101, '�̻��޶�����', '�̻�����', 0, 'merchantQuota', 'F', 'Y', 'closed', 'jsp/merchant/merchantQuotaMain.jsp', 'icon-merchantErr', 'A', '�̻��޶�����', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:52:44', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4119, 4108, '�����˻�����', '�̻�����', 1, 'consumeKind', 'F', 'Y', 'closed', 'jsp/merchant/consumeKindMain.jsp', 'icon-merConsumeKind', 'A', '�����˻�����', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:04:59', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4121, 4108, '����ģʽ����', '�̻�����', 2, 'settleMode', 'F', 'Y', 'closed', 'jsp/merchant/merSettleMode.jsp', 'icon-merSettleMode', 'A', '����ģʽ����', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:05:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4123, 4108, '���ѷ�������', '�̻�����', 3, 'setttleRate', 'F', 'Y', 'closed', 'jsp/merchant/merSettleRateMain.jsp', 'icon-merSettleRate', 'A', '���ѷ�������', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:05:30', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10351, 963, '�˻���ѯ', '��Ƭ����', 11, 'accountQuery', 'F', 'Y', 'closed', '/jsp/cardService/accountquery.jsp', 'icon-zhcx', 'A', '���˻���ѯ', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('27-05-2015 19:02:41', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10352, 4101, '�޶�������', '�̻��޶�����', 1, 'merchantLmtAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '�޶�������', to_date('26-05-2015 23:58:01', 'dd-mm-yyyy hh24:mi:ss'), to_date('26-05-2015 23:58:01', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10353, 4101, '�޶�����༭', '�̻��޶�����', 2, 'merchantLmtEidt', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '�޶�����༭', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('24-06-2015 15:52:55', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10356, 4121, '�༭����ģʽ', '����ģʽ����', 1, 'merSettleModeEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '�༭����ģʽ', to_date('27-05-2015 17:56:43', 'dd-mm-yyyy hh24:mi:ss'), to_date('27-05-2015 17:56:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10357, 4121, 'ɾ������ģʽ', '����ģʽ����', 2, 'merSettleModeDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'A', 'ɾ������ģʽ', to_date('27-05-2015', 'dd-mm-yyyy'), to_date('29-07-2015 14:18:47', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10391, 10351, 'ִ���˻���ѯ', '�˻���ѯ', 1, 'accountQuery', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', 'ִ���˻���ѯ', to_date('27-05-2015 19:08:35', 'dd-mm-yyyy hh24:mi:ss'), to_date('27-05-2015 19:08:35', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10392, 10350, '��ע��ִ��', '��Ƭע��', 1, 'zxCard', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '��ע��ִ��', to_date('27-05-2015 19:19:04', 'dd-mm-yyyy hh24:mi:ss'), to_date('27-05-2015 19:19:04', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10399, 4123, '�̻�����Ԥ��', '���ѷ�������', 1, 'merConsRateView', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', '�̻�����Ԥ��', to_date('28-05-2015', 'dd-mm-yyyy'), to_date('28-05-2015 10:47:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10400, 4123, '�̻��������', '���ѷ�������', 2, 'merConsRateAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '�̻��������', to_date('28-05-2015 10:50:03', 'dd-mm-yyyy hh24:mi:ss'), to_date('28-05-2015 10:50:03', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10401, 4123, '�̻����ʱ༭', '���ѷ�������', 3, 'merConsRateEidt', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '�̻����ʱ༭', to_date('28-05-2015 10:51:56', 'dd-mm-yyyy hh24:mi:ss'), to_date('28-05-2015 10:51:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10402, 4123, '�̻��������', '���ѷ�������', 4, 'merConsRateChcek', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-checkInfo', 'A', '�̻��������', to_date('28-05-2015', 'dd-mm-yyyy'), to_date('28-05-2015 11:11:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10403, 4123, '�̻�����ɾ��', '���ѷ�������', 5, 'merConsRateDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '�̻�����ɾ��', to_date('28-05-2015', 'dd-mm-yyyy'), to_date('28-05-2015 11:14:48', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10440, 10428, '����ҵ���ѯ', 'ͳ�Ʋ�ѯ', 2, 'javascript:void(0);', 'F', 'Y', 'closed', '/jsp/statistics/businessquery.jsp', 'icon-item', 'I', '����ҵ���ѯ', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('01-06-2015 17:38:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10441, 10429, '����ҵ���ѯ', '�����ѯ', 1, 'businessquery1', 'F', 'Y', 'closed', '/jsp/statistics/businessquery.jsp', 'icon-item', 'A', '����ҵ���ѯ', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('01-06-2015 23:47:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10442, 11103, '�̻��ն˹���', '�豸����', 1, 'terminalManager', 'F', 'Y', 'closed', 'jsp/merchant/teminalMagMain.jsp', 'icon-termManage', 'A', '�̻��ն˹���', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:06:44', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10443, 10442, '�̻��ն�����', '�̻��ն˹���', 1, 'terminalAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '�̻��ն�����', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('01-06-2015 18:08:53', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10444, 10442, '�̻��ն˱༭', '�̻��ն˹���', 2, 'terminalEidt', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '�̻��ն˱༭', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('01-06-2015 18:09:06', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10445, 10442, '�̻��ն�ע��', '�̻��ն˹���', 3, 'terminalCancel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '�̻��ն�ע��', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('01-06-2015 18:09:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10446, 4141, '������ϢԤ��', '�̻��������', 1, 'viewMerSettleInfo', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', '������ϢԤ��', to_date('02-06-2015 14:34:56', 'dd-mm-yyyy hh24:mi:ss'), to_date('02-06-2015 14:34:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10447, 4141, '�̻��������', '�̻��������', 3, 'chkMerSettleInfo', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-checkInfo', 'A', '�̻��������', to_date('02-06-2015', 'dd-mm-yyyy'), to_date('06-06-2015 15:49:10', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10448, 4141, '�̻��������', '�̻��������', 2, 'rollBackSettle', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-back', 'A', '�̻��������', to_date('05-06-2015', 'dd-mm-yyyy'), to_date('06-06-2015 15:48:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10798, 10639, '�ɹ����', '�Ǹ��Ի��ƿ�', 2, 'madeCardCheck', 'F', 'N', 'closed', 'jsp/madeCardManage/madeCardCheck.jsp', 'icon-merchantMag', 'I', null, to_date('25-07-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:35:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10799, 10857, '�����������', '�˻�����', 3, 'accountManagementService', 'F', 'Y', 'closed', '/jsp/accManage/openaccruleindex.jsp', 'icon-rulers', 'A', '�����������', to_date('27-07-2015', 'dd-mm-yyyy'), to_date('07-08-2015 10:45:42', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10803, 10857, '�˻����׹���', '�˻�����', 4, 'accountManagerAction', 'F', 'Y', 'closed', '/jsp/accManage/accstatebandealcodeindex.jsp', 'icon-transaction_3d', 'A', '��ǰ�˻�״̬�£���ֹ���׵Ľ��״��롣', to_date('28-07-2015', 'dd-mm-yyyy'), to_date('07-08-2015 10:46:22', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10814, 10857, '�˻���ȹ���', '�˻�����', 5, 'accountManagerAction', 'F', 'Y', 'closed', '/jsp/accManage/acccreditslimitindex.jsp', 'icon-dzqbcz', 'A', '�˻�������ƹ���,�����˻����ʣ����գ������������ʾ', to_date('31-07-2015', 'dd-mm-yyyy'), to_date('07-08-2015 11:23:08', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10817, 10798, '�ɹ���˱���', '�ɹ����', 1, 'madeCardCheck', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-checkInfo', 'I', null, to_date('03-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:35:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10818, 10664, '��������', '������Ϣ', 6, '��������', 'F', 'Y', 'closed', '/jsp/cardApp/wsApply.jsp', null, 'I', null, to_date('03-08-2015 17:01:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('03-08-2015 17:02:12', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10819, 10638, '��������', '��������', 6, '��������', 'F', 'Y', 'closed', '/jsp/cardApp/wsApply.jsp', 'icon-cardService', 'A', null, to_date('03-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:31:32', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10820, 10638, '��������', '��������', 7, '��������', 'F', 'Y', 'closed', '/jsp/cardApp/yhApply.jsp', 'icon-dzqbcz', 'A', '��������', to_date('03-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:31:47', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10821, 10820, '���������ѯ', '��������', 1, 'yhApplyQuery', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-tip', 'A', null, to_date('03-08-2015 17:08:11', 'dd-mm-yyyy hh24:mi:ss'), to_date('03-08-2015 17:08:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10822, 10820, '��������ȷ��', '��������', 2, 'yhApplySave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', null, to_date('03-08-2015 17:09:56', 'dd-mm-yyyy hh24:mi:ss'), to_date('03-08-2015 17:09:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10823, 10820, '���з����ϴ�', '��������', 3, 'yhApplyUpload', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-undo', 'A', null, to_date('03-08-2015 17:11:10', 'dd-mm-yyyy hh24:mi:ss'), to_date('03-08-2015 17:11:10', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10824, 10819, '���������ѯ', '��������', 1, 'wsApplyQuery', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-tip', 'I', null, to_date('03-08-2015', 'dd-mm-yyyy'), to_date('11-08-2015 20:18:25', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10825, 10819, '��������ȷ��', '��������', 2, 'wsApplySave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'I', null, to_date('03-08-2015 17:16:16', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-08-2015 20:18:32', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10826, 10819, '�������췵��', '��������', 3, 'wsApplyUpload', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-undo', 'I', null, to_date('03-08-2015', 'dd-mm-yyyy'), to_date('11-08-2015 20:18:36', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10828, 11109, '�˻��������', '״̬����', 7, 'accountManagerAction', 'F', 'Y', 'closed', '/jsp/accManage/accenableindex.jsp', 'icon-account_enable', 'A', '�˻�����', to_date('04-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:31:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10829, 11109, '�˻��������', '״̬����', 8, 'accountManagerAction', 'F', 'Y', 'closed', '/jsp/accManage/accfreezeindex.jsp', 'icon-accountLock', 'A', '�˻�����', to_date('04-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:31:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10830, null, '�˻�����', null, 4, 'accountsManag', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon_accounts_Manage', 'A', '�˻�����', to_date('05-08-2015', 'dd-mm-yyyy'), to_date('07-08-2015 11:16:13', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10831, 10859, '���մ���', '��ֽ���', 1, 'accDayBal', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon_accounts_DayBal', 'A', '���մ���', to_date('05-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:01:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10832, 10831, '��Ա����', '���ʴ���', 1, 'userDayBal', 'F', 'Y', 'closed', '/cuteDayManage/cuteDayAction!initUserInfo.action', 'icon-userCuteDayBal', 'A', '��Ա����', to_date('05-08-2015', 'dd-mm-yyyy'), to_date('05-08-2015 15:15:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10833, 10831, '��������', '���ʴ���', 2, 'branchDayBal', 'F', 'Y', 'closed', '/cuteDayManage/cuteDayAction!initBrchInfo.action', 'icon-brchCuteDayBal', 'A', '��������', to_date('05-08-2015', 'dd-mm-yyyy'), to_date('05-08-2015 22:16:40', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10834, 10832, '��ʱ����', '��Ա����', 1, 'userDayCutTemp', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'I', '��ʱ����', to_date('05-08-2015 15:29:42', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-08-2015 15:41:22', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10835, 10832, '��������', '��Ա����', 2, 'userCuteDayEnd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '��������', to_date('05-08-2015 15:30:35', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-08-2015 15:30:35', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10837, 10833, 'ǿ�ƹ�Ա����', '��������', 2, 'enforceUserDayBal', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-paraManage', 'A', 'ǿ�ƹ�Ա����', to_date('05-08-2015', 'dd-mm-yyyy'), to_date('10-08-2015 09:13:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10857, 10830, '������Ϣ', '�˻�����', 1, 'javascript:void(0)', 'F', 'Y', 'closed', 'javascript:void(0)', 'icon-walletConsumeDo', 'A', null, to_date('07-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:59:13', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10858, 963, '��Ƭ����', '��Ƭ����', 1, 'cardService', 'F', 'Y', 'closed', '/cardService/cardServiceAction!bkCardIndex.action', 'icon-account_lock01', 'A', null, to_date('07-08-2015', 'dd-mm-yyyy'), to_date('10-08-2015 10:57:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10860, 371, '�����ϴ�', '��Ƭ����', 1, 'photoSignUpload', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '�����ϴ�', to_date('10-08-2015 14:45:59', 'dd-mm-yyyy hh24:mi:ss'), to_date('10-08-2015 14:45:59', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10861, 371, '�����֤�ϴ�', '��Ƭ����', 2, 'readCertUpload', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '�����֤�ϴ�', to_date('10-08-2015', 'dd-mm-yyyy'), to_date('10-08-2015 14:47:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10862, 371, '�����ϴ�', '��Ƭ����', 3, 'photoZipUpload', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '�����ϴ�', to_date('10-08-2015', 'dd-mm-yyyy'), to_date('10-08-2015 14:48:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10877, 10819, '������ϸԤ��', '��������', 0, 'viewHealthTaskList', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', '������ϸԤ��', to_date('11-08-2015 20:21:01', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-08-2015 20:21:01', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10878, 10819, '��ϸ���', '��������', 1, 'addHealthTaskList', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '��ϸ���', to_date('11-08-2015', 'dd-mm-yyyy'), to_date('11-08-2015 20:23:30', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10879, 10819, '��ϸɾ��', '��������', 2, 'deleteHealthTaskList', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '��ϸɾ��', to_date('11-08-2015 20:24:26', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-08-2015 20:24:26', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10881, 233, '�鿴Ԥ��', '��������', 1, 'batchApplyView', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-viewInfo', 'A', null, to_date('12-08-2015 14:26:13', 'dd-mm-yyyy hh24:mi:ss'), to_date('12-08-2015 14:26:13', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10886, 10640, '����ɾ��', '�ƿ��������', 5, 'toTaskDelete', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-bdel', 'A', null, to_date('14-08-2015 13:26:05', 'dd-mm-yyyy hh24:mi:ss'), to_date('14-08-2015 13:26:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10887, 10640, '������Ա', '�ƿ��������', 7, 'addTaskList', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', null, to_date('14-08-2015 14:12:33', 'dd-mm-yyyy hh24:mi:ss'), to_date('14-08-2015 14:12:33', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10891, 968, '�������', '�������', 4, 'cardIssue', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-branchEditMange', 'A', null, to_date('14-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:38:42', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10892, 10891, '���˷���', '���췢��', 3, 'oneCardIssuse', 'F', 'Y', 'closed', '/jsp/cardIssuse/oneCardIssuse.jsp', 'icon-accManage', 'A', null, to_date('14-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:19:00', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10893, 10891, '��ģ����', '���췢��', 4, 'batchIssuse', 'F', 'Y', 'closed', '/jsp/cardIssuse/batchIssuse.jsp', 'icon-userCuteDayBal', 'A', null, to_date('14-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:19:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10894, 963, '��Ƭ����', '��Ƭ����', 2, 'CardService', 'F', 'Y', 'closed', '/cardService/cardServiceAction!hkCardIndex.action', 'icon_accounts_Manage', 'A', null, to_date('15-08-2015', 'dd-mm-yyyy'), to_date('15-08-2015 17:28:29', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10895, 10891, '��Ƭ���յǼ�', '���췢��', 8, 'cardRecoverReg', 'F', 'Y', 'closed', '/jsp/cardRecoverRegister/cardRecoverReg.jsp', 'icon-taskExpBank', 'A', '��Ƭ���յǼ�', to_date('15-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:10:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10896, 10891, '��Ƭ���յǼǳ���', '���췢��', 9, 'cardRecRegUndo', 'F', 'Y', 'closed', '/jsp/cardRecoverRegister/cardRecoverRegUndo.jsp', 'icon-ljcx', 'A', '��Ƭ���յǼǳ���', to_date('15-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:10:36', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10897, 10894, '�����⹦�ܷ�Ȩ��', '��Ƭ����', 1, 'chgCardNoMoney', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '�����⹦�ܷ�Ȩ��,��Ȩ���򻻿�ԭ����������ʾ������ԭ�򣬹�����0Ԫ��û�д�Ȩ�޽���ȡ20Ԫ������', to_date('16-08-2015 00:00:12', 'dd-mm-yyyy hh24:mi:ss'), to_date('16-08-2015 00:00:12', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11091, 10638, '���е���', '��������', 8, 'yhImportApply', 'F', 'Y', 'closed', '/jsp/cardApp/yhImportApply.jsp', 'icon-back', 'A', '���е���', to_date('17-08-2015', 'dd-mm-yyyy'), to_date('25-08-2015 10:15:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11092, 10638, 'Ԥ�����ѯ', '��������', 2, 'Ԥ�����ѯ', 'F', 'Y', 'closed', '/jsp/cardApp/queryApplyView.jsp', 'icon-walletConsumeDo', 'A', 'Ԥ�����ѯ', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:33:06', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11093, 11092, 'Ԥ����ɾ��', 'Ԥ�����ѯ', 1, 'delApplyView', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-cancel', 'A', null, to_date('18-08-2015 13:04:58', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 13:04:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11094, 10891, '���ų���', '���췢��', 5, 'undoCardIssuse', 'F', 'Y', 'closed', '/jsp/cardIssuse/undoCardIssuse.jsp', 'icon-undo', 'A', '���ų���', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:19:38', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11095, 10891, '���������ѯ', '���췢��', 10, 'applyStateQuery', 'F', 'Y', 'closed', '/jsp/', 'icon-auto', 'I', '���������ѯ', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:22:46', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11096, 963, '�ۺ���Ϣ��ѯ', '��Ƭ����', 12, 'cardCompQuery', 'F', 'Y', 'closed', '/jsp/cardService/cardCompQuery.jsp', 'icon-payment', 'A', '�ۺ���Ϣ��ѯ', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:28:25', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11097, 10638, '�ƿ������ѯ', '��������', 11, 'query', 'F', 'Y', 'closed', '/jsp', 'icon-payment', 'A', '�ƿ������ѯ', to_date('18-08-2015 15:36:05', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 15:36:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11098, 10638, '��������˽����ѯ', '��������', 12, 'queryExpState', 'F', 'Y', 'closed', '/jsp/cardApp/queryExpState.jsp', 'icon-end', 'A', '��������˽����ѯ', to_date('18-08-2015 15:37:42', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 15:37:42', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11099, 10637, '��������', '�������', 5, 'cardParaManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-orgAccManage', 'A', '��������', to_date('18-08-2015 15:39:55', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 15:39:55', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11100, 10637, 'PASM������', '�������', 6, 'pasmManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-dzqbcz', 'A', 'PASM������', to_date('18-08-2015 15:41:35', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 15:41:35', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11101, 4080, '�̻�����', '��������', 2, 'merchantManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-merchantQues', 'A', '�̻�����', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:53:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10449, 4143, '�̻������ӡ', '�̻����㴦��', 2, 'printSettle', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-print', 'A', '�̻������ӡ', to_date('05-06-2015', 'dd-mm-yyyy'), to_date('06-06-2015 00:03:40', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10450, 10347, '�����˻�������ֵ', '�����˻���ֵ', 1, 'OnlineRechargeReadCard', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '�����˻�������ֵ', to_date('05-06-2015 15:55:15', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-06-2015 15:55:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10451, 10347, '�����˻�(�޿�)��ֵ', '�����˻���ֵ', 2, 'OnlineRechargeQueryCard', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '�����˻�(�޿�)��ֵ,���뿨�Ų�ѯ����ֵ��', to_date('05-06-2015 15:57:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-06-2015 15:57:36', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10452, 10347, '������ֵȷ��', '�����˻���ֵ', 3, 'OnlineRechargeSave', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '������ֵȷ��,�������ȷ����ֵ��', to_date('05-06-2015 16:02:12', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-06-2015 16:02:12', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10479, 10349, '�����˻���ֵ��������', '������ֵ����', 2, 'onlinerechargecanelsave', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '�����˻���ֵ������ѯ��ť', to_date('06-06-2015', 'dd-mm-yyyy'), to_date('06-06-2015 14:47:53', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10480, 10349, '�����˻���ֵ������ѯ', '������ֵ����', 1, 'onlinerechargecanelquery', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '�����˻���ֵ������ѯ', to_date('06-06-2015 14:47:28', 'dd-mm-yyyy hh24:mi:ss'), to_date('06-06-2015 14:47:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10489, 4145, '�̻�����Ԥ��', '�̻�����֧��', 1, 'merpaymentView', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', '�̻�����Ԥ��', to_date('06-06-2015 15:23:29', 'dd-mm-yyyy hh24:mi:ss'), to_date('06-06-2015 15:23:29', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10490, 4145, '�̻�����֧��', '�̻�����֧��', 2, 'merpaymentSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-payment', 'A', '�̻�����֧��', to_date('06-06-2015 15:24:20', 'dd-mm-yyyy hh24:mi:ss'), to_date('06-06-2015 15:24:20', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10634, 1082, '����ת������', '��ֵҵ��', 5, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/rechargeservice/transfersonlineacc2onlineacc.jsp', 'icon-orgOpenAcc', 'A', '����ת������ֵ', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-06-2015 22:12:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10635, 10634, '����ת�ѻ��˻�', '����ת������', 6, 'javascript:void(0)', 'F', 'Y', 'closed', '11', null, 'I', '��Ƭ�����˻�ת�ѻ��˻���ֵ', to_date('07-06-2015 00:04:46', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-06-2015 00:05:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10636, 1082, '����ת���ѻ�', '��ֵҵ��', 6, 'OnlineToOffline', 'F', 'Y', 'closed', '/jsp/rechargeservice/transfersonlineacc2offlineacc.jsp', 'icon-time', 'A', null, to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-06-2015 22:12:08', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10637, null, '�������', null, 2, 'madeCardMag', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-madeCardMag', 'A', '�������', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:19:53', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10638, 10637, '��������', '�������', 2, 'madeCardOnlyMag', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-madeCardOnly', 'A', '���Ի��ƿ�', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:30:30', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10639, 10637, '�Ǹ��Ի��ƿ�', '�������', 3, 'madeCardNotOnly', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-madeCardNotOnly', 'I', '�Ǹ��Ի��ƿ�', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:35:09', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10640, 10638, '�ƿ��������', '��������', 4, 'madeCardOlyGL', 'F', 'Y', 'closed', 'jsp/taskManage/taskMain.jsp', 'icon-makeTaskMag', 'A', '�ƿ��������', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:33:40', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10642, 10819, '��������', '��������', 4, 'cardOnlyTaskExpToHealth', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '��������', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('11-08-2015 20:21:25', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10643, 10820, '��������', '��������', 3, 'cardOnlyTaskExpToBank', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '��������', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('11-08-2015 20:12:59', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10659, 10819, '������������', '��������', 5, 'cardOnlyTaskImpByHealth', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-import', 'A', '������������', to_date('09-06-2015', 'dd-mm-yyyy'), to_date('11-08-2015 20:21:38', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10660, 11091, '�������з���', '���е���', 4, 'cardOnlyTaskImpByBank', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-import', 'A', '�������з���', to_date('10-06-2015', 'dd-mm-yyyy'), to_date('17-08-2015 21:19:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10661, 10640, '���뿨������', '�ƿ��������', 5, 'cardOnlyTaskImpByFact', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-import', 'A', '���뿨������', to_date('10-06-2015', 'dd-mm-yyyy'), to_date('10-06-2015 15:59:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10664, 10891, '������Ϣ��ѯ', '���췢��', 10, 'cardAppMore', 'F', 'Y', 'closed', '/jsp/cardApp/applyMsg.jsp', 'icon-orgOpenAcc', 'A', '������ʷ��Ϣ��ѯ', to_date('12-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:23:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10679, 10640, '��������', '�ƿ��������', 6, 'cardOnlyTaskOpenAcc', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'I', '��������', to_date('15-06-2015 12:10:59', 'dd-mm-yyyy hh24:mi:ss'), to_date('15-06-2015 15:30:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10680, 10343, '�����˻�֧�������޸ı���', '���������޸�', 1, 'savePayPwdModify', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '�����˻�֧�������޸ı���', to_date('15-06-2015 23:03:49', 'dd-mm-yyyy hh24:mi:ss'), to_date('15-06-2015 23:03:49', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10681, 10344, '�����˻�֧����������', '������������', 1, 'savePayPwdReset', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '�����˻�֧����������', to_date('15-06-2015 23:04:28', 'dd-mm-yyyy hh24:mi:ss'), to_date('15-06-2015 23:04:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10699, 10429, '����ҵ��ͳ��', '�����ѯ', 3, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/statistics/businessAmount.jsp', 'icon-role', 'A', null, to_date('16-06-2015', 'dd-mm-yyyy'), to_date('16-06-2015 09:49:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10700, 4147, 'Ԥ��������ϸ', '�̻������ѯ', 1, 'viewMerSettleInfo_Query', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', 'Ԥ��������ϸ', to_date('16-06-2015', 'dd-mm-yyyy'), to_date('16-06-2015 10:34:46', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10701, 4147, '�̻�����Exec����', '�̻������ѯ', 2, 'merQuexportExcel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-excel', 'A', '�̻�����Exec����', to_date('16-06-2015 10:35:50', 'dd-mm-yyyy hh24:mi:ss'), to_date('16-06-2015 10:35:50', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10702, 4147, '�̻�������񵼳�', '�̻������ѯ', 3, 'merSettleFinance', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '�̻�������񵼳�', to_date('16-06-2015', 'dd-mm-yyyy'), to_date('16-06-2015 10:37:03', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10719, 10638, '�Ǹ��Ի�������', '��������', 10, 'madenotonlyCard', 'F', 'Y', 'closed', 'jsp/madeCardManage/madeNotOnlyCard.jsp', 'icon-madeCardPro', 'A', '�Ǹ��Ի�������', to_date('17-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:34:46', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10797, 10857, '�˻����͹���', '�˻�����', 2, 'javascript:void(0)', 'F', 'Y', 'closed', '/accountManager/accountManagerAction!accTypeIndex.action', 'icon-account_card', 'A', '�˻����͹���', to_date('25-07-2015', 'dd-mm-yyyy'), to_date('07-08-2015 10:45:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10800, 4108, '�̻�����ģʽ����', '�̻�����', 5, 'merGetCosMode', 'F', 'Y', 'closed', '/jsp/merchant/merGetCosModeMian.jsp', 'icon-merchantAdd', 'A', '�̻�����ģʽ����', to_date('28-07-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:04:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10801, 10800, '�̻�����ģʽ����', '�̻�����ģʽ����', 1, 'merGetCosModeAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '�̻�����ģʽ����', to_date('28-07-2015', 'dd-mm-yyyy'), to_date('28-07-2015 16:50:10', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10802, 10800, '�̻�����ģʽ�༭', '�̻�����ģʽ����', 2, 'merGetCosModeEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '�̻�����ģʽ�༭', to_date('28-07-2015', 'dd-mm-yyyy'), to_date('28-07-2015 16:50:41', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10827, 11109, '�˻���������', '״̬����', 7, 'accountManagerAction', 'F', 'Y', 'closed', '/jsp/accManage/acclockandunlock.jsp', 'icon-account_lock01', 'A', '�˻����������', to_date('03-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:31:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10836, 10833, '��������', '��������', 1, 'brchDayBalEnd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '��������', to_date('05-08-2015 22:20:02', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-08-2015 22:20:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10859, null, '��ֽ���', null, 5, 'strogeRoomManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon_stroge-room', 'A', '�ⷿ����', to_date('10-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:00:38', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10882, 228, '�������쳷��', '�������', 8, '�������쳷��', 'F', 'Y', 'closed', '/jsp/cardApp/delBatch.jsp', 'icon-comp', 'I', null, to_date('13-08-2015', 'dd-mm-yyyy'), to_date('13-08-2015 20:59:34', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10883, 10882, '�������쳷������', '�������쳷��', 2, 'delBatchSave', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-save', 'I', null, to_date('13-08-2015', 'dd-mm-yyyy'), to_date('13-08-2015 20:59:24', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10884, 10882, '�������쳷����ѯ', '�������쳷��', 1, 'delBatchQuery', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-tip', 'I', null, to_date('13-08-2015', 'dd-mm-yyyy'), to_date('13-08-2015 20:59:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10885, 10640, '����鿴ɾ����Ա', '�ƿ��������', 3, 'deleteTaskList', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-cancel', 'A', null, to_date('14-08-2015', 'dd-mm-yyyy'), to_date('14-08-2015 09:43:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10888, 10719, '�����Ǹ��Ի����ɹ�����', '�ɹ��ƻ�', 1, 'notOnlyCardTaskAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '�����Ǹ��Ի����ɹ�����', to_date('14-08-2015', 'dd-mm-yyyy'), to_date('14-08-2015 17:07:32', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10889, 10719, 'ɾ���Ǹ��Ի����ɹ�����', '�ɹ��ƻ�', 2, 'notOnlyCardTaskDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', 'ɾ���Ǹ��Ի����ɹ�����', to_date('14-08-2015 17:07:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('14-08-2015 17:07:08', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10890, 10719, '�����Ǹ��Ի����ɹ�����', '�ɹ��ƻ�', 3, 'notOnlyCardTaskExp', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '�����Ǹ��Ի����ɹ�����', to_date('14-08-2015 17:09:02', 'dd-mm-yyyy hh24:mi:ss'), to_date('14-08-2015 17:09:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10898, 963, 'Ӧ������', '��Ƭ����', 8, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/cardService/applock.jsp', 'icon-signin', 'A', '��ƬӦ������', to_date('16-08-2015', 'dd-mm-yyyy'), to_date('16-08-2015 12:19:09', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10899, 963, 'Ӧ�ý���', '��Ƭ����', 9, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/cardService/appunlock.jsp', 'icon-signout', 'A', '��ƬӦ�ý���', to_date('16-08-2015', 'dd-mm-yyyy'), to_date('16-08-2015 12:19:39', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10900, 963, '������Ϣ��ѯ', '��Ƭ����', 10, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/cardService/cardinfoandaccinfo.jsp', 'icon-accManage', 'A', '��Ƭ��Ϣ��ѯ���˻���Ϣ��ѯ��������Ϣ��ѯ', to_date('16-08-2015', 'dd-mm-yyyy'), to_date('19-08-2015 17:00:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10902, 10898, '��ƬӦ����������', 'Ӧ������', 1, 'saveAppLockHjl', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '��ƬӦ����������', to_date('17-08-2015', 'dd-mm-yyyy'), to_date('17-08-2015 11:18:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10917, 10892, '���ű���', '���˷���', 1, 'toOneCardIssuse', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', null, to_date('17-08-2015 15:10:39', 'dd-mm-yyyy hh24:mi:ss'), to_date('17-08-2015 15:10:39', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10918, 10893, '��ģ���ű���', '��ģ����', 1, 'toBatchSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', null, to_date('17-08-2015', 'dd-mm-yyyy'), to_date('17-08-2015 15:12:44', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11090, 968, '���е���', '�������', 8, 'yhImportApply', 'F', 'Y', 'closed', '/jsp/cardApp/yhImportApply.jsp', 'icon-back', 'I', '���е���', to_date('17-08-2015 21:17:12', 'dd-mm-yyyy hh24:mi:ss'), to_date('17-08-2015 21:18:06', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (44, 1, '��־����', 'ϵͳ����', 45, 'logMgr', 'F', 'Y', 'closed', 'jsp/logs/logsMain.jsp', 'icon-pro', 'I', '��־����', to_date('18-06-2013', 'dd-mm-yyyy'), to_date('27-08-2015 14:10:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (45, null, '123123', null, 123, '123', 'F', 'Y', 'closed', '123', null, 'I', '123123123', to_date('18-06-2013', 'dd-mm-yyyy'), to_date('18-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (38, 4, 'ttttt', '���ݿ����', 123, '123123123123', 'F', 'N', 'closed', '123', 'icon-undo', 'I', '123123123123123123', to_date('14-06-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (28, 1, '�û���ɫ����', 'ϵͳ����', 16, 'userRoleMgr', 'F', 'Y', 'closed', 'jsp/roleConfig/roleConfigMain.jsp', 'icon-role', 'A', '�û���ɫ����', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('22-06-2013 09:16:35', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (27, 1, '��Ա����', 'ϵͳ����', 15, 'userMain', 'F', 'Y', 'closed', 'jsp/user/userMain.jsp', 'icon-adds', 'A', '�û�����', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('21-07-2015 21:25:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (55, 4, '12312311', '���ݿ����', 123, '123', 'O', 'Y', 'closed', '123', null, 'I', '123123123123123123123', to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (36, 27, '�û�del', '�û�����', 1, '123', 'F', 'Y', 'closed', '123', 'icon-cancel', 'I', '123123', to_date('14-06-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (50, 1, '�����ֵ�', 'ϵͳ����', 5, 'dicMgr', 'F', 'N', 'closed', 'jsp/systemCode/systemCodeMain.jsp', 'icon-undo', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-08-2015 16:20:41', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1, 967, 'ϵͳ����', 'ϵͳ����', 4, 'sysMgr', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-config', 'A', 'ϵͳ����', to_date('23-05-2013', 'dd-mm-yyyy'), to_date('18-08-2015 16:18:42', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1331, 1095, '��������', '��������', 1, 'orgManageIndex', 'F', 'Y', 'closed', 'jsp/orgManage/orgManageMain.jsp', 'icon-orgAccManage', 'A', '��������', to_date('27-04-2015', 'dd-mm-yyyy'), to_date('27-04-2015 23:51:29', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1333, 1095, '�����˻�����', '��������', 2, 'orgAccManage', 'F', 'N', 'closed', 'jsp/orgManage/orgOpenMain.jsp', 'icon-orgOpenAcc', 'I', '�����˻�����', to_date('27-04-2015', 'dd-mm-yyyy'), to_date('22-05-2015 19:03:46', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (243, 228, '������Ϣ����', '�ͻ�����', 1, 'dataAcount', 'F', 'Y', 'closed', 'jsp/dataAcount/dataAcountMain.jsp', 'icon-data-acount', 'A', '������Ϣ����', to_date('04-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:07:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1326, 10857, '�˻���Ŀ����', '������Ϣ', 1, 'itemManage', 'F', 'Y', 'closed', 'jsp/paraManage/itemMain.jsp', 'icon-itemManage', 'A', '��Ŀ����', to_date('27-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:17:26', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (780, 228, '����', '�������', 1, '1', 'F', 'Y', 'closed', '1', 'icon-bedit', 'I', null, to_date('23-04-2015', 'dd-mm-yyyy'), to_date('23-04-2015 22:34:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1329, 11099, '��Ƭ��������', '��������', 23, 'cardParaManage', 'F', 'Y', 'closed', 'jsp/paraManage/cardParaMain.jsp', 'icon-itemManage', 'A', '����������', to_date('27-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:40:18', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1335, 1095, '�����˻�����', '��������', 3, 'orgClose', 'F', 'Y', 'closed', 'jsp/orgManage/orgCloseMain.jsp', 'icon-orgCloseAcc', 'I', '�����˻�����', to_date('27-04-2015', 'dd-mm-yyyy'), to_date('21-05-2015 12:27:49', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1342, 1088, '�����˻�����', '�������', 3, 'brachClose', 'F', 'Y', 'closed', '3', 'icon-orgCloseAcc', 'I', '�����˻�����', to_date('28-04-2015', 'dd-mm-yyyy'), to_date('22-05-2015 21:30:32', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (867, 780, '����1', '����', 1, '1', 'F', 'Y', 'closed', '1', 'icon-role', 'I', null, to_date('23-04-2015 15:44:28', 'dd-mm-yyyy hh24:mi:ss'), to_date('23-04-2015 22:33:59', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (233, 10638, '��������', '��������', 1, 'cardAppMore', 'F', 'Y', 'closed', '/jsp/cardApp/batchApplyView.jsp', 'icon-card-apply', 'A', '��������', to_date('04-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:32:52', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (231, 10891, '��������', '���췢��', 1, 'oneCardApp', 'F', 'Y', 'closed', 'jsp/cardApp/oneCardApply.jsp', 'icon-card-apply', 'A', '��������', to_date('04-04-2015', 'dd-mm-yyyy'), to_date('21-08-2015 19:40:37', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (228, 968, '�ͻ�����', '�������', 0, 'cardApp', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-item', 'A', '�ͻ�����', to_date('04-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:07:30', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1557, 1553, '��ұ���', '��Ƭ���', 1, 'cardunLostSave', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-ok', 'A', '��ұ���', to_date('04-05-2015', 'dd-mm-yyyy'), to_date('04-05-2015 20:29:00', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1095, 967, '��������', 'ϵͳ����', 1, 'orgManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-orgManage', 'A', '��������', to_date('26-04-2015 14:18:54', 'dd-mm-yyyy hh24:mi:ss'), to_date('26-04-2015 14:18:54', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1553, 963, '��Ƭ���', '��Ƭ����', 4, 'cardunLost', 'F', 'Y', 'closed', 'jsp/cardService/cardUnlockManageMain.jsp', 'icon-cardunlostManage', 'A', '��Ƭ���', to_date('04-05-2015 20:20:00', 'dd-mm-yyyy hh24:mi:ss'), to_date('04-05-2015 20:20:00', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1324, 967, '��־����', 'ϵͳ����', 5, 'logManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-paraManage', 'I', '��־����', to_date('27-04-2015', 'dd-mm-yyyy'), to_date('27-08-2015 14:09:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (2014, 965, '���������޸�', '�������', 1, 'ServicePassword', 'F', 'Y', 'closed', '/jsp/pwdservice/servicepwdmodify.jsp', 'icon-time', 'A', null, to_date('16-05-2015', 'dd-mm-yyyy'), to_date('16-05-2015 23:16:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (2087, 1331, '������������', '��������', 4, 'orgOpenAcc', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '������������', to_date('21-05-2015', 'dd-mm-yyyy'), to_date('22-05-2015 17:02:20', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1082, 968, '��ֵ����', '�������', 7, 'rechgService', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-rechgCard', 'A', '��ֵҵ��', to_date('25-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:38:53', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (371, 228, '������Ƭ����', '�ͻ�����', 2, 'photoImport', 'F', 'Y', 'closed', 'jsp/photoImport/photoImportMain.jsp', 'icon-pro', 'A', '��Ƭ����', to_date('09-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 17:01:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1551, 963, '��Ƭ��ʧ', '��Ƭ����', 3, 'cardLost', 'F', 'Y', 'closed', 'jsp/cardService/cardLostManage.jsp', 'icon-cardlostManage', 'A', '��Ƭ��ʧ', to_date('04-05-2015 20:13:10', 'dd-mm-yyyy hh24:mi:ss'), to_date('04-05-2015 20:13:10', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1546, 963, '��Ƭ��ʧ', '��Ƭ����', 1, 'cardLost', 'F', 'Y', 'closed', 'jsp/cardService/cardLostMain.jsp', 'icon-cardlostManage', 'I', '��Ƭ��ʧ', to_date('04-05-2015', 'dd-mm-yyyy'), to_date('04-05-2015 20:08:20', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (47, 44, '��־����', '��־����', 1, 'logAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'I', null, to_date('18-06-2013', 'dd-mm-yyyy'), to_date('27-08-2015 14:10:04', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (62, 59, '����', '��������', 3, 'parSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (56, 4, '12312311', '���ݿ����', 123123, '123', 'O', 'Y', 'open', '1231', 'icon-back', 'I', '23123123', to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (60, 59, '�����༭', '��������', 1, 'parEndEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-end', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (61, 59, 'ɾ��', '��������', 2, 'parDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (52, 50, '�ֵ�༭', '�����ֵ�', 1, 'dicEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (49, 44, '��־ɾ��', '��־����', 3, 'logDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'I', null, to_date('18-06-2013', 'dd-mm-yyyy'), to_date('27-08-2015 14:10:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (53, 50, '�ֵ�ɾ��', '�����ֵ�', 2, 'dicDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (54, 4, '123', '���ݿ����', 123, '123', 'O', 'Y', 'open', '123', 'icon-edit', 'I', '123123123123', to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (51, 50, '�ֵ�����', '�����ֵ�', 0, 'dicAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (48, 44, '��־�༭', '��־����', 2, 'logEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'I', null, to_date('18-06-2013', 'dd-mm-yyyy'), to_date('27-08-2015 14:10:01', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4, 1, '���ݿ����', 'ϵͳ����', 2, '1123', 'F', 'Y', 'open', 'druid/index.html', 'icon-db', 'A', '123123123123123123', to_date('23-05-2013', 'dd-mm-yyyy'), to_date('20-06-2013 15:08:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (16, 2, '�˵���������', 'ϵͳ����', 4, 'funAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '�˵���������', to_date('24-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1568, 1329, '������ɾ��', '����������', 3, 'cardParadel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '������ɾ��', to_date('04-05-2015 21:43:07', 'dd-mm-yyyy hh24:mi:ss'), to_date('04-05-2015 21:43:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (2018, 2014, '���������޸�', '���������޸�', 1, 'ServicePassword', 'O', 'Y', 'open', 'javascript:void(0)', 'icon-edit', 'A', '���������޸�', to_date('16-05-2015', 'dd-mm-yyyy'), to_date('16-05-2015 23:17:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (19, 2, '�˵������༭', 'ϵͳ����', 7, 'funEndEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'I', '�����༭', to_date('24-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (20, 2, '�˵�����', 'ϵͳ����', 8, 'funSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'I', '����', to_date('24-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (17, 2, '�˵����ܱ༭', 'ϵͳ����', 5, 'funEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '�˵����ܱ༭', to_date('24-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (18, 2, '�˵�����ɾ��', '��ʽ����', 6, 'funDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '�˵�����ɾ��', to_date('24-05-2013', 'dd-mm-yyyy'), to_date('02-04-2015 22:52:50', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1566, 1329, '�������༭', '����������', 2, 'cardParaEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '�������༭', to_date('04-05-2015 21:42:06', 'dd-mm-yyyy hh24:mi:ss'), to_date('04-05-2015 21:42:06', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (637, 371, '��Ƭ���뱣��', '��Ƭ����', 8, 'photoUplodd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', null, to_date('20-04-2015', 'dd-mm-yyyy'), to_date('10-08-2015 14:46:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (640, 243, '���ݲɼ����', '���ݲɼ�', 1, 'personAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', null, to_date('20-04-2015', 'dd-mm-yyyy'), to_date('20-04-2015 15:50:41', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1404, 1331, '�������', '��������', 1, 'orgationAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '�������', to_date('02-05-2015', 'dd-mm-yyyy'), to_date('02-05-2015 10:59:20', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1407, 1331, '�����༭', '��������', 2, 'orgationEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '�����༭', to_date('02-05-2015 11:00:15', 'dd-mm-yyyy hh24:mi:ss'), to_date('02-05-2015 11:00:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1555, 1551, '��ʧ����', '��Ƭ��ʧ', 1, 'cardLostSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '��ʧ����', to_date('04-05-2015', 'dd-mm-yyyy'), to_date('04-05-2015 21:40:23', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1564, 1329, '���������', '����������', 1, 'cardParaAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '���������', to_date('04-05-2015 21:41:04', 'dd-mm-yyyy hh24:mi:ss'), to_date('04-05-2015 21:41:04', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (642, 243, '���ݲɼ��޸�', '���ݲɼ�', 2, 'personEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', null, to_date('20-04-2015', 'dd-mm-yyyy'), to_date('20-04-2015 15:50:49', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1346, 1326, '�༭', '��Ŀ����', 1, 'accItemEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '�༭', to_date('28-04-2015', 'dd-mm-yyyy'), to_date('28-04-2015 14:56:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (34, 28, '�û���ɫ����', 'ϵͳ����', 21, 'userRoleConfig', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-config', 'A', '�û���ɫ����', to_date('29-05-2013', 'dd-mm-yyyy'), to_date('29-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (35, 2, '123', '��ʽ����', 1, '123', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'I', '123123', to_date('13-06-2013', 'dd-mm-yyyy'), to_date('13-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11177, 10638, '�ƿ�����', '��������', 9, 'doCardImp', 'F', 'Y', 'closed', '/jsp/cardApp/doCardImpMain.jsp', 'icon-import', 'A', '�ƿ�����', to_date('25-08-2015', 'dd-mm-yyyy'), to_date('25-08-2015 10:19:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11178, 11177, '�ƿ����뱣��', '�ƿ�����', 1, 'doCardImpSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', '�ƿ����뱣��', to_date('25-08-2015', 'dd-mm-yyyy'), to_date('25-08-2015 10:22:01', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11222, 10759, '�Ҽ�¼�Զ�����', '�Ҽ�¼����', 1, 'ashrecordautosave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', '�Ҽ�¼�Զ�����', to_date('26-08-2015', 'dd-mm-yyyy'), to_date('26-08-2015 10:32:08', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11223, 10759, '�Ҽ�¼ȷ�ϱ���', '�Ҽ�¼����', 2, 'ashrecordcofirmsave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '�Ҽ�¼ȷ�ϱ���', to_date('26-08-2015', 'dd-mm-yyyy'), to_date('26-08-2015 10:31:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11224, 10759, '�Ҽ�¼��������', '�Ҽ�¼����', 3, 'ashrecordcanelsave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-back', 'A', '�Ҽ�¼��������', to_date('26-08-2015 10:33:06', 'dd-mm-yyyy hh24:mi:ss'), to_date('26-08-2015 10:33:06', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11237, 11218, '�̻��������', null, 1, 'merchantEidt', 'O', 'Y', 'open', 'javascrip:viod(0);', 'icon-edit', 'A', null, to_date('26-08-2015 20:58:30', 'dd-mm-yyyy hh24:mi:ss'), to_date('26-08-2015 20:58:30', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11238, 11217, '�̻���Ϣ���', null, 1, 'merchantCheck', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-save', 'A', null, to_date('26-08-2015 21:16:09', 'dd-mm-yyyy hh24:mi:ss'), to_date('26-08-2015 21:16:09', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11109, 10830, '״̬����', '�˻�����', 2, 'accountStatManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-account_lock01', 'A', '״̬����', to_date('18-08-2015 16:29:56', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 16:29:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11163, 11094, '���ų�������', '���ų���', 1, 'undoCardIssuse', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-undo', 'A', null, to_date('19-08-2015', 'dd-mm-yyyy'), to_date('19-08-2015 21:05:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11170, 11102, '���������������', null, 2, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/agentorg/cooperationagencymanage.jsp', 'icon_accounts_DayBal', 'A', '���������������', to_date('22-08-2015', 'dd-mm-yyyy'), to_date('24-08-2015 09:42:25', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11241, 11239, 'Ԥ��������ϸ', '������������', 1, 'coCheckViewList', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', 'Ԥ��������ϸ', to_date('28-08-2015', 'dd-mm-yyyy'), to_date('28-08-2015 16:28:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11242, 11239, '��������������', '������������', 2, 'dealdzcorepair', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-back', 'A', '��������������', to_date('28-08-2015 16:30:14', 'dd-mm-yyyy hh24:mi:ss'), to_date('28-08-2015 16:30:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11243, 11239, '��Ӫ��������', '������������', 3, 'dealdzorgcancel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'A', '��Ӫ��������', to_date('28-08-2015 16:32:07', 'dd-mm-yyyy hh24:mi:ss'), to_date('28-08-2015 16:32:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11244, 11239, '��Ӫ����������', '������������', 4, 'dealdzorgadd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '��Ӫ����������', to_date('28-08-2015 16:34:07', 'dd-mm-yyyy hh24:mi:ss'), to_date('28-08-2015 16:34:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11245, 11239, '����������¼ɾ��', '������������', 5, 'dealdzdeletemx', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '����������¼ɾ��', to_date('28-08-2015 16:36:01', 'dd-mm-yyyy hh24:mi:ss'), to_date('28-08-2015 16:36:01', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11277, 11240, 'Ԥ��������ϸ', '�ѻ����ݶ���', 1, 'viewGjMx', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', 'Ԥ��������ϸ', to_date('01-09-2015 17:25:19', 'dd-mm-yyyy hh24:mi:ss'), to_date('01-09-2015 17:25:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11278, 11240, '������ϸ����Ϊ�ɸ�', '�ѻ����ݶ���', 2, 'offlineDeal', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '������ϸ����Ϊ�ɸ�', to_date('01-09-2015 17:59:59', 'dd-mm-yyyy hh24:mi:ss'), to_date('01-09-2015 17:59:59', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11162, 10900, '������Ϣ��ѯ����', '����Ϣ��ѯ', 1, 'cardinfoinnerquery', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '������Ϣ��ѯ����', to_date('19-08-2015 12:55:41', 'dd-mm-yyyy hh24:mi:ss'), to_date('19-08-2015 12:55:41', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11179, 11166, '�������������Ǽ�����', null, 1, 'basecoorgregisterAdd', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '�������������Ǽ�����', to_date('25-08-2015 11:57:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 11:57:36', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11180, 11166, '�������������ǼǱ༭', null, 1, 'basecoorgregisterEdit', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '�������������ǼǱ༭', to_date('25-08-2015 11:58:18', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 11:58:18', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11181, 11170, '�������������������', null, 1, 'basecoorgmanageAdd', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '�������������������', to_date('25-08-2015 12:00:41', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 12:00:41', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11182, 11170, '��������������˱༭', null, 2, 'basecoorgmanageEdit', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '��������������˱༭', to_date('25-08-2015 12:01:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 12:01:36', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11183, 11170, '���������������', null, 3, 'basecoorgmanageSh', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '���������������', to_date('25-08-2015 12:02:31', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 12:02:31', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11184, 11170, '�������������Ǽ�״̬����', null, 4, 'basecoorgmanageState', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '�������������Ǽ�״̬����', to_date('25-08-2015 12:03:21', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 12:03:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11102, 4080, '��������', '��������', 3, 'corpManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-merSettleQuery', 'A', '������������', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('22-08-2015 18:09:18', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11103, 4080, '�豸����', '��������', 4, 'equipmentManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-termMag', 'A', '�豸����', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:07:09', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11104, 4080, '�����ⷿ', '��������', 5, 'baseStock', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon_accounts_Manage', 'A', '�����ⷿ', to_date('18-08-2015 15:57:17', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 15:57:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11105, 10859, '���˹���', '��ֽ���', 2, 'checkBillManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-account_card', 'A', '���˹���', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('26-08-2015 15:57:10', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11106, 10428, 'Ӫҵ����', 'ͳ�Ʋ�ѯ', 1, 'businessReport', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-print', 'A', 'Ӫҵ����', to_date('18-08-2015 16:14:51', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 16:14:51', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11107, 10428, '��ֵ����ͳ��', 'ͳ�Ʋ�ѯ', 2, 'regandconStat', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-orgBranchAccoutManage', 'A', '��ֵ����ͳ��', to_date('18-08-2015 16:15:58', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 16:15:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11108, 10428, '����ҵ��ͳ��', 'ͳ�Ʋ�ѯ', 4, 'countStat', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon_accounts_Manage', 'A', '����ҵ��ͳ��', to_date('18-08-2015 16:16:48', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 16:16:48', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11168, 10891, '�������쳷��', null, 2, 'undoOneCardApply', 'F', 'Y', 'closed', '/jsp/cardApp/undoOneCardApply.jsp', 'icon-undo', 'A', null, to_date('20-08-2015', 'dd-mm-yyyy'), to_date('21-08-2015 19:42:31', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11169, 11168, '�������쳷������', null, 1, 'undoOneCardApplySave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', null, to_date('20-08-2015 17:31:45', 'dd-mm-yyyy hh24:mi:ss'), to_date('20-08-2015 17:31:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11167, 231, '�������챣��', null, 1, 'onecardApplySave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', null, to_date('20-08-2015', 'dd-mm-yyyy'), to_date('27-08-2015 15:42:00', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11239, 11105, '������������', '���˹���', 1, 'corpcheckbill', 'F', 'Y', 'closed', '/jsp/clrsettlemanage/corpcheckbill.jsp', 'icon_accounts_Manage', 'A', '������������', to_date('26-08-2015', 'dd-mm-yyyy'), to_date('26-08-2015 22:29:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11240, 11105, '�ѻ����ݶ���', '���˹���', 2, 'dealofflinebill', 'F', 'Y', 'closed', '/jsp/clrsettlemanage/dealofflineconsume.jsp', 'icon-ljcx', 'A', '�ѻ����ݶ���', to_date('26-08-2015 22:31:24', 'dd-mm-yyyy hh24:mi:ss'), to_date('26-08-2015 22:31:24', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11166, 11102, '�������������Ǽ�', null, 1, 'CooperationAgency', 'F', 'Y', 'closed', '/jsp/agentorg/cooperationagencyregister.jsp', 'icon-comp', 'A', '�������������Ǽ�', to_date('20-08-2015', 'dd-mm-yyyy'), to_date('20-08-2015 17:52:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11217, 11101, '�̻���Ϣ����', null, 3, '1', 'F', 'Y', 'closed', '/jsp/merchantManage/merchantCheck.jsp', 'icon-merchantMag', 'A', null, to_date('25-08-2015', 'dd-mm-yyyy'), to_date('26-08-2015 21:09:06', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11218, 11101, '�̻���Ϣ���', null, 5, '1', 'F', 'Y', 'closed', '/jsp/merchantManage/merchantUpdate.jsp', 'icon-merchantQues', 'A', null, to_date('25-08-2015', 'dd-mm-yyyy'), to_date('26-08-2015 21:10:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11219, 11101, '�̻��ʸ���ͣ', null, 6, '1', 'F', 'Y', 'closed', '1', 'icon-counterServiceManage', 'A', null, to_date('25-08-2015 19:52:39', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 19:52:39', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11220, 11101, '�̻��ʸ�����', null, 7, '1', 'F', 'Y', 'closed', '1', 'icon-sys', 'A', null, to_date('25-08-2015 19:53:43', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 19:53:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11221, 11101, '�̻������Ǽ�', null, 9, '1', 'F', 'Y', 'closed', '1', 'icon-undo', 'A', null, to_date('25-08-2015 19:55:03', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 19:55:03', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11257, 1066, '���ȷ��', null, 4, 'cashManageAction', 'F', 'Y', 'closed', '/jsp/cashmanage/depositoutletsconfirm.jsp', 'icon_accounts_DayBal', 'A', '������ȷ��', to_date('01-09-2015', 'dd-mm-yyyy'), to_date('02-09-2015 16:06:01', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

prompt Done.