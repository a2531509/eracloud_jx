prompt Importing table SYS_PERMISSION...
set feedback off
set define off
insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10343, 965, '交易密码修改', '密码服务', 3, 'TradingPassword', 'F', 'Y', 'closed', '/jsp/pwdservice/paypwdmodify.jsp', 'icon-sys', 'A', '卡片联机账户支付密码', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('15-06-2015 12:30:47', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10344, 965, '交易密码重置', '密码服务', 4, 'TradingPassword', 'F', 'Y', 'closed', '/jsp/pwdservice/paypwdreset.jsp', 'icon-comp', 'A', '卡联机账户支付密码重置', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('15-06-2015 12:31:18', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10345, 1066, '网点存款', '现金管理', 3, 'BranchCk', 'F', 'Y', 'closed', '/cashManage/cashManageAction!toBranchDeposit.action', 'icon-orgBranchAccoutManage', 'A', '网点存款', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('29-05-2015 20:28:55', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10346, 1082, '钱包账户充值', '充值业务', 1, 'Dzqb', 'F', 'Y', 'closed', '/jsp/rechargeservice/offlineaccountrecharge.jsp', 'icon-dzqbcz', 'A', '电子钱包充值', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('02-06-2015 10:05:44', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10347, 1082, '联机账户充值', '充值业务', 2, 'onlineaccountrecharge', 'F', 'Y', 'closed', '/jsp/rechargeservice/onlineaccountrecharge.jsp', 'icon-ljcz', 'A', '联机账户充值', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('05-06-2015 09:36:46', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10348, 1082, '钱包充值撤销', '充值业务', 3, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/rechargeservice/undoofflineaccrecharge.jsp', 'icon-dzqbcx', 'A', '电子钱包撤销', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('07-06-2015 09:35:24', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10349, 1082, '联机充值撤销', '充值业务', 4, 'UndoRecharge', 'F', 'Y', 'closed', '/jsp/rechargeservice/undoonlineaccrecharge.jsp', 'icon-ljcx', 'A', '联机充值撤销', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('05-06-2015 15:53:30', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10350, 963, '卡片注销', '卡片服务', 5, 'zxCard', 'F', 'Y', 'closed', '/jsp/cardService/cardzx.jsp', 'icon-zx', 'A', '卡片注销', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('27-05-2015 19:18:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10354, 4119, '消费账户新增', '消费账户控制', 1, 'merAccConsAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '消费账户新增', to_date('27-05-2015', 'dd-mm-yyyy'), to_date('27-05-2015 16:52:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10355, 4119, '消费账户编辑', '消费账户控制', 2, 'merAccConsEidt', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '消费账户编辑', to_date('27-05-2015 16:52:56', 'dd-mm-yyyy hh24:mi:ss'), to_date('27-05-2015 16:52:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10428, null, '统计查询', null, 6, 'Statisticalinquiry', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-comp', 'A', '系统统计查询', to_date('30-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:15:00', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10429, 10428, '柜面查询', '统计查询', 3, 'GMQuery', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-orgOpenAcc', 'A', '柜面查询', to_date('30-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:15:13', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10430, 10429, '业务凭证查询', '柜面查询', 2, 'pzQuery', 'F', 'Y', 'closed', '/jsp/statistics/voucher.jsp', 'icon-db', 'A', '业务凭证查询', to_date('30-05-2015', 'dd-mm-yyyy'), to_date('01-06-2015 23:48:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10465, 10346, '钱包账户读卡', '钱包账户充值', 1, 'OfflineRechargeReadCard', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '钱包账户充值读卡', to_date('05-06-2015 16:23:58', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-06-2015 16:23:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10466, 10346, '钱包账户充值保存', '钱包账户充值', 2, 'OfflineRechargeSave', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '钱包账户充值保存', to_date('05-06-2015 16:25:33', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-06-2015 16:25:33', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10485, 10349, '联机账户充值撤销读卡', '联机充值撤销', 3, 'onlinerechargecanelreadcard', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', null, to_date('06-06-2015 14:51:33', 'dd-mm-yyyy hh24:mi:ss'), to_date('06-06-2015 14:51:33', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10486, 10349, '联机账户充值撤销读身份证', '联机充值撤销', 4, 'onlinerechargecanelreadidcard', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', null, to_date('06-06-2015 14:53:49', 'dd-mm-yyyy hh24:mi:ss'), to_date('06-06-2015 14:53:49', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10641, 10638, '制卡任务生成', '制作管理', 3, 'cardProMade', 'F', 'Y', 'closed', 'jsp/madeCardPro.jsp', 'icon-madeCardPro', 'A', '制卡任务生成', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:33:24', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10739, 4108, '消费模式管理', '商户结算', 4, 'consumeModeMag', 'F', 'Y', 'closed', 'jsp/merchant/merConsumeMode.jsp', 'icon-merchantMag', 'A', '消费模式管理', to_date('24-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:04:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10740, 10739, '消费模式新增', '商户消费模式', 1, 'addConsumeMode', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '消费模式新增', to_date('24-06-2015', 'dd-mm-yyyy'), to_date('25-06-2015 15:01:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10741, 10739, '消费模式修改', '商户消费模式', 2, 'editConsumeMode', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-edit', 'A', '消费模式修改', to_date('24-06-2015', 'dd-mm-yyyy'), to_date('24-06-2015 16:00:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10742, 10739, '消费模式删除', '商户消费模式', 3, 'delComsumeMode', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '消费模式删除', to_date('24-06-2015 15:59:42', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-06-2015 15:59:42', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10759, 1082, '灰记录处理', '充值业务', 7, 'DealAsRecord', 'F', 'Y', 'closed', '/jsp/rechargeservice/dealashrecord.jsp', 'icon-export', 'A', '灰记录处理', to_date('26-06-2015', 'dd-mm-yyyy'), to_date('26-06-2015 13:51:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10779, 963, '余额返现', '卡片服务', 6, 'cardService', 'F', 'Y', 'closed', '/jsp/cardService/acccashback.jsp', 'icon-undo', 'A', '余额返现', to_date('17-07-2015', 'dd-mm-yyyy'), to_date('17-07-2015 17:33:32', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10780, 10429, '充值消费查询', '柜面查询', 4, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/statistics/consumerecord.jsp', 'icon-orgBranchAccoutManage', 'A', null, to_date('18-07-2015 11:16:17', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-07-2015 11:16:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10419, 10345, '网点存款确认存款', '网点存款', 1, 'certainDeposit', 'O', 'Y', 'open', 'javascript:void(0)', 'icon-save', 'A', '网点存款确认存款', to_date('29-05-2015', 'dd-mm-yyyy'), to_date('29-05-2015 23:38:57', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10431, 4080, '商户终端管理', '基础管理', 9, 'terminalMag', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-termMag', 'I', '商户终端管理', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:07:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10432, 10430, '凭证查询', '业务凭证查询', 1, 'voucherQuery', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '凭证查询,执行查询', to_date('01-06-2015 17:27:05', 'dd-mm-yyyy hh24:mi:ss'), to_date('01-06-2015 17:27:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10433, 10430, '凭证预览打印', '业务凭证查询', 2, 'voucherView', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '凭证预览并进行打印', to_date('01-06-2015 17:29:17', 'dd-mm-yyyy hh24:mi:ss'), to_date('01-06-2015 17:29:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10665, 10640, '任务回退', '制卡任务管理', 0, 'taskReBack', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-undo', 'A', '任务回退', to_date('13-06-2015', 'dd-mm-yyyy'), to_date('14-08-2015 11:48:03', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4086, 11101, '商户类型管理', '商户管理', 1, 'merchantQues', 'F', 'Y', 'closed', 'jsp/merchant/merchantTypeMain.jsp', 'icon-merchantQues', 'A', '商户类型管理', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:52:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4106, 4080, '商户结算参数', '基础管理', 8, 'merSettleParam', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-mersettlePara', 'I', '商户结算参数', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:05:42', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4108, 10859, '商户结算', '清分结算', 3, 'merSettle', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-merchantsettle', 'A', '商户结算', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:03:37', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4080, null, '基础管理', null, 3, 'merchantMag', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-merchantMag', 'A', '基础管理', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:49:46', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4084, 11101, '商户入网登记', '商户管理', 2, 'merchantMsgMag', 'F', 'Y', 'closed', 'jsp/merchant/merchantRegistMain.jsp', 'icon-merchantDown', 'A', '商户入网登记', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:51:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4230, 1066, '柜员调剂', '现金管理', 2, 'toTellerTransferIndex', 'F', 'Y', 'closed', '/cashManage/cashManageAction!toTellerTransferIndex.action', 'icon-role', 'A', '柜员现金调剂', to_date('25-05-2015', 'dd-mm-yyyy'), to_date('25-05-2015 15:05:51', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4232, 4084, '商户信息预览', '商户信息维护', 1, 'viewMerchantInfo', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-undo', 'A', '商户信息预览', to_date('25-05-2015 17:35:27', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-05-2015 17:35:27', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4234, 4084, '商户增加', '商户信息维护', 2, 'merchantAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '商户增加', to_date('25-05-2015 17:36:21', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-05-2015 17:36:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4236, 4084, '商户编辑', '商户信息维护', 3, 'merchantEidt', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '商户编辑', to_date('25-05-2015', 'dd-mm-yyyy'), to_date('25-05-2015 17:37:54', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4053, 40, '网点账户开户', '网点管理', 4, 'brchAccOpen', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-orgOpenAcc', 'A', '网点账户开户', to_date('22-05-2015', 'dd-mm-yyyy'), to_date('22-05-2015 21:32:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (965, 968, '密码服务', '柜面服务', 6, 'pwdservice', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-pwdService', 'A', null, to_date('24-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:24:08', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1066, 10830, '现金管理', '账户管理', 5, 'CashManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-auto', 'A', null, to_date('24-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:59:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (963, 968, '卡片服务', '柜面服务', 5, 'cardService', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-cardService', 'A', null, to_date('24-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:23:53', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (59, 1, '参数设置', '系统管理', 12, '11', 'F', 'N', 'closed', 'jsp/sysParameter/sysParameterMain.jsp', 'icon-remove', 'A', '111', to_date('17-06-2013', 'dd-mm-yyyy'), to_date('31-03-2015 18:57:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (968, null, '柜面服务', null, 0, 'cardApp', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-counterServiceManage', 'A', '申领服务', to_date('04-04-2015', 'dd-mm-yyyy'), to_date('04-05-2015 20:40:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1088, 967, '网点管理', '系统管理', 2, 'brachManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-branchManage', 'A', '网点管理', to_date('26-04-2015', 'dd-mm-yyyy'), to_date('26-04-2015 14:18:04', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (967, null, '系统管理', null, 8, 'sysMgr', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-sys', 'A', '系统管理', to_date('23-05-2013', 'dd-mm-yyyy'), to_date('23-05-2015 11:31:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (2, 1, '程式管理', '系统管理', 0, 'funMgr', 'F', 'Y', 'closed', 'jsp/function/functionMain.jsp', 'icon-pro', 'A', '程式管理', to_date('23-05-2013', 'dd-mm-yyyy'), to_date('20-08-2015 09:36:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (2080, 965, '服务密码重置', '密码服务', 2, 'pwdserviceAction', 'F', 'Y', 'closed', '/jsp/pwdservice/servicepwdreset.jsp', 'icon-role', 'A', '个人服务密码重置', to_date('21-05-2015 09:43:17', 'dd-mm-yyyy hh24:mi:ss'), to_date('21-05-2015 09:43:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1104, 1088, '网点账户开户', '网点管理', 2, 'orgBrchAcountManage', 'F', 'Y', 'closed', '2', 'icon-orgOpenAcc', 'I', '网点账户开户', to_date('26-04-2015', 'dd-mm-yyyy'), to_date('22-05-2015 21:30:35', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (7, 1, '权限分派', '系统管理', 3, 'funOMgr', 'F', 'Y', 'closed', 'jsp/permission/permissionAssignmentMain.jsp', 'icon-config', 'A', '菜单功能分派', to_date('23-05-2013', 'dd-mm-yyyy'), to_date('22-06-2013 09:15:57', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (40, 1088, '网点管理', '网点管理', 1, 'brchManage', 'F', 'Y', 'closed', 'jsp/organization/organizationMain.jsp', 'icon-branchEditMange', 'A', '网点管理', to_date('14-06-2013', 'dd-mm-yyyy'), to_date('22-05-2015 21:30:51', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (39, null, '1123123', null, 123, '123123', 'F', 'Y', 'closed', '32123', 'icon-edit', 'I', '123123123123', to_date('14-06-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (46, 1, '123123', '系统管理', 123, '2312', 'F', 'Y', 'closed', '1231', 'icon-back', 'I', '3123123123123', to_date('18-06-2013', 'dd-mm-yyyy'), to_date('18-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (32, 27, '用户结束编辑', '系统管理', 19, 'userEndEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-end', 'I', null, to_date('27-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (33, 27, '用户保存', '系统管理', 20, 'userSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'I', null, to_date('27-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (42, 40, '网点编辑', '网点管理', 1, 'brchEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('22-05-2015 21:31:22', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (43, 40, '网点删除', '网点管理', 2, 'brchDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('22-05-2015 21:31:40', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (37, 27, '用户delll', '用户管理', 123, '123', 'O', 'Y', 'open', '123', 'icon-undo', 'I', '123123123', to_date('14-06-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (41, 40, '网点增加', '网点管理', 0, 'brchAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', null, to_date('14-06-2013', 'dd-mm-yyyy'), to_date('22-05-2015 21:31:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (31, 27, '用户删除', '系统管理', 18, 'userDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'A', null, to_date('27-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (23, 7, '角色编辑', '系统管理', 11, 'roleEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '角色编辑', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (24, 7, '角色删除', '系统管理', 12, 'roleDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '角色删除', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (21, 7, '权限分配保存', '系统管理', 9, 'perConfig', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-config', 'A', '权限分配保存', to_date('24-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (22, 7, '角色新增', '系统管理', 10, 'roleAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-role', 'A', '角色新增', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (29, 27, '用户新增', '用户管理', 16, 'userAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '123123123123', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('18-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (30, 27, '用户编辑', '系统管理', 17, 'userEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', null, to_date('27-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (25, 7, '角色结束编辑', '系统管理', 13, 'roleEndEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'I', '角色结束编辑', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (26, 7, '角色保存', '系统管理', 14, 'roleSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'I', '角色保存', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4082, 4080, '商户登记管理', '基础管理', 7, 'merchantAdd', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-merchantAdd', 'I', '商户登记管理', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:04:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4141, 4108, '商户结算审核', '商户结算信息', 1, 'merSettleCK', 'F', 'Y', 'closed', 'jsp/merchant/merSettleCKMain.jsp', 'icon-merSettleCK', 'A', '商户结算审核', to_date('24-05-2015', 'dd-mm-yyyy'), to_date('03-06-2015 11:36:51', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4143, 4108, '商户结算处理', '商户结算信息', 2, 'merSettleRS', 'F', 'Y', 'closed', 'jsp/merchant/merSettleRSMain.jsp', 'icon-merSettleRS', 'A', '商户结算处理', to_date('24-05-2015 11:14:16', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 11:14:16', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4145, 4108, '商户结算支付', '商户结算信息', 3, 'merSettlePay', 'F', 'Y', 'closed', 'jsp/merchant/merSettlePayMain.jsp', 'icon-merSettlePay', 'A', '商户结算支付', to_date('24-05-2015 11:15:11', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 11:15:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4147, 4108, '商户结算查询', '商户结算信息', 4, 'merSettleQuery', 'F', 'Y', 'closed', 'jsp/merchant/merSettleQueryMain.jsp', 'icon-merSettleQuery', 'A', '商户结算查询', to_date('24-05-2015 11:20:05', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 11:20:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4149, 4108, '商户结算月报', '商户结算信息', 5, 'merSettleMon', 'F', 'Y', 'closed', '/jsp/merchant/merSettleReportMonth.jsp', 'icon-merSettleMon', 'A', '商户结算月报', to_date('24-05-2015', 'dd-mm-yyyy'), to_date('01-09-2015 11:30:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4151, 4108, '商户结算年报', '商户结算信息', 6, 'merSettleYear', 'F', 'Y', 'closed', 'jsp/merchant/merSettleReportYear.jsp', 'icon-merSettleYear', 'A', '商户结算年报', to_date('24-05-2015', 'dd-mm-yyyy'), to_date('01-09-2015 11:30:39', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4153, 4108, '行业结算信息', '商户结算信息', 7, 'merSettleInDus', 'F', 'Y', 'closed', 'jsp/merchant/merSettleInDusMain.jsp', 'icon-merSettleInDus', 'A', '行业结算信息', to_date('24-05-2015 11:22:50', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 11:22:50', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4172, 4086, '类型新增', '商户类型管理', 1, 'merTypeAdd', 'O', 'Y', 'open', 'javascript:void(0)', 'icon-adds', 'A', '类型新增', to_date('24-05-2015 17:25:23', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 17:25:23', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4174, 4086, '类型修改', '商户类型管理', 2, 'merTypeEite', 'O', 'Y', 'open', 'javascrpit:void(0);', 'icon-edit', 'A', '类型修改', to_date('24-05-2015 17:26:26', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 17:26:26', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4176, 4086, '预览商户', '商户类型管理', 3, 'TypeOnwMer', 'O', 'Y', 'open', 'javascrpit:void(0);', 'icon-merchantsettle', 'A', '预览商户', to_date('24-05-2015', 'dd-mm-yyyy'), to_date('24-05-2015 21:40:38', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4201, 1066, '现金尾箱', '现金管理', 1, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/cashmanage/cashbox.jsp', 'icon-orgManage', 'A', '柜员现金尾箱信息查询', to_date('24-05-2015 21:02:32', 'dd-mm-yyyy hh24:mi:ss'), to_date('24-05-2015 21:02:32', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (3475, 3812, '机构销户保存', '机构账户销户', 2, 'orgCloseAcc', 'O', 'Y', 'open', 'javascript:void();', 'icon-cancel', 'I', '机构销户保存', to_date('21-05-2015', 'dd-mm-yyyy'), to_date('22-05-2015 19:03:39', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (3478, 1331, '机构注销', '机构管理', 3, 'orgCancel', 'O', 'Y', 'open', 'javascript:void()', 'icon-remove', 'A', '机构注销', to_date('21-05-2015', 'dd-mm-yyyy'), to_date('21-05-2015 14:09:08', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (3812, 1095, '机构账户销户', '机构管理', 3, 'orgAccManage', 'F', 'N', 'closed', 'jsp/orgManage/orgCloseMain.jsp', 'icon-orgCloseAcc', 'I', '机构账户销户', to_date('22-05-2015', 'dd-mm-yyyy'), to_date('22-05-2015 19:03:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4101, 11101, '商户限额设置', '商户管理', 0, 'merchantQuota', 'F', 'Y', 'closed', 'jsp/merchant/merchantQuotaMain.jsp', 'icon-merchantErr', 'A', '商户限额设置', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:52:44', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4119, 4108, '消费账户控制', '商户结算', 1, 'consumeKind', 'F', 'Y', 'closed', 'jsp/merchant/consumeKindMain.jsp', 'icon-merConsumeKind', 'A', '消费账户控制', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:04:59', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4121, 4108, '结算模式设置', '商户结算', 2, 'settleMode', 'F', 'Y', 'closed', 'jsp/merchant/merSettleMode.jsp', 'icon-merSettleMode', 'A', '结算模式控制', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:05:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4123, 4108, '消费费率设置', '商户结算', 3, 'setttleRate', 'F', 'Y', 'closed', 'jsp/merchant/merSettleRateMain.jsp', 'icon-merSettleRate', 'A', '消费费率设置', to_date('23-05-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:05:30', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10351, 963, '账户查询', '卡片服务', 11, 'accountQuery', 'F', 'Y', 'closed', '/jsp/cardService/accountquery.jsp', 'icon-zhcx', 'A', '卡账户查询', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('27-05-2015 19:02:41', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10352, 4101, '限额参数添加', '商户限额设置', 1, 'merchantLmtAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '限额参数添加', to_date('26-05-2015 23:58:01', 'dd-mm-yyyy hh24:mi:ss'), to_date('26-05-2015 23:58:01', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10353, 4101, '限额参数编辑', '商户限额设置', 2, 'merchantLmtEidt', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '限额参数编辑', to_date('26-05-2015', 'dd-mm-yyyy'), to_date('24-06-2015 15:52:55', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10356, 4121, '编辑结算模式', '结算模式设置', 1, 'merSettleModeEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '编辑结算模式', to_date('27-05-2015 17:56:43', 'dd-mm-yyyy hh24:mi:ss'), to_date('27-05-2015 17:56:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10357, 4121, '删除结算模式', '结算模式设置', 2, 'merSettleModeDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'A', '删除结算模式', to_date('27-05-2015', 'dd-mm-yyyy'), to_date('29-07-2015 14:18:47', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10391, 10351, '执行账户查询', '账户查询', 1, 'accountQuery', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '执行账户查询', to_date('27-05-2015 19:08:35', 'dd-mm-yyyy hh24:mi:ss'), to_date('27-05-2015 19:08:35', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10392, 10350, '卡注销执行', '卡片注销', 1, 'zxCard', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '卡注销执行', to_date('27-05-2015 19:19:04', 'dd-mm-yyyy hh24:mi:ss'), to_date('27-05-2015 19:19:04', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10399, 4123, '商户费率预览', '消费费率设置', 1, 'merConsRateView', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', '商户费率预览', to_date('28-05-2015', 'dd-mm-yyyy'), to_date('28-05-2015 10:47:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10400, 4123, '商户费率添加', '消费费率设置', 2, 'merConsRateAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '商户费率添加', to_date('28-05-2015 10:50:03', 'dd-mm-yyyy hh24:mi:ss'), to_date('28-05-2015 10:50:03', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10401, 4123, '商户费率编辑', '消费费率设置', 3, 'merConsRateEidt', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '商户费率编辑', to_date('28-05-2015 10:51:56', 'dd-mm-yyyy hh24:mi:ss'), to_date('28-05-2015 10:51:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10402, 4123, '商户费率审核', '消费费率设置', 4, 'merConsRateChcek', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-checkInfo', 'A', '商户费率审核', to_date('28-05-2015', 'dd-mm-yyyy'), to_date('28-05-2015 11:11:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10403, 4123, '商户费率删除', '消费费率设置', 5, 'merConsRateDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '商户费率删除', to_date('28-05-2015', 'dd-mm-yyyy'), to_date('28-05-2015 11:14:48', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10440, 10428, '柜面业务查询', '统计查询', 2, 'javascript:void(0);', 'F', 'Y', 'closed', '/jsp/statistics/businessquery.jsp', 'icon-item', 'I', '柜面业务查询', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('01-06-2015 17:38:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10441, 10429, '柜面业务查询', '柜面查询', 1, 'businessquery1', 'F', 'Y', 'closed', '/jsp/statistics/businessquery.jsp', 'icon-item', 'A', '柜面业务查询', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('01-06-2015 23:47:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10442, 11103, '商户终端管理', '设备管理', 1, 'terminalManager', 'F', 'Y', 'closed', 'jsp/merchant/teminalMagMain.jsp', 'icon-termManage', 'A', '商户终端管理', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:06:44', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10443, 10442, '商户终端新增', '商户终端管理', 1, 'terminalAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '商户终端新增', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('01-06-2015 18:08:53', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10444, 10442, '商户终端编辑', '商户终端管理', 2, 'terminalEidt', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '商户终端编辑', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('01-06-2015 18:09:06', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10445, 10442, '商户终端注销', '商户终端管理', 3, 'terminalCancel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '商户终端注销', to_date('01-06-2015', 'dd-mm-yyyy'), to_date('01-06-2015 18:09:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10446, 4141, '结算信息预览', '商户结算审核', 1, 'viewMerSettleInfo', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', '结算信息预览', to_date('02-06-2015 14:34:56', 'dd-mm-yyyy hh24:mi:ss'), to_date('02-06-2015 14:34:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10447, 4141, '商户结算审核', '商户结算审核', 3, 'chkMerSettleInfo', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-checkInfo', 'A', '商户结算审核', to_date('02-06-2015', 'dd-mm-yyyy'), to_date('06-06-2015 15:49:10', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10448, 4141, '商户结算回退', '商户结算审核', 2, 'rollBackSettle', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-back', 'A', '商户结算回退', to_date('05-06-2015', 'dd-mm-yyyy'), to_date('06-06-2015 15:48:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10798, 10639, '采购审核', '非个性化制卡', 2, 'madeCardCheck', 'F', 'N', 'closed', 'jsp/madeCardManage/madeCardCheck.jsp', 'icon-merchantMag', 'I', null, to_date('25-07-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:35:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10799, 10857, '开户规则管理', '账户管理', 3, 'accountManagementService', 'F', 'Y', 'closed', '/jsp/accManage/openaccruleindex.jsp', 'icon-rulers', 'A', '开户规则管理', to_date('27-07-2015', 'dd-mm-yyyy'), to_date('07-08-2015 10:45:42', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10803, 10857, '账户交易管理', '账户管理', 4, 'accountManagerAction', 'F', 'Y', 'closed', '/jsp/accManage/accstatebandealcodeindex.jsp', 'icon-transaction_3d', 'A', '当前账户状态下，禁止交易的交易代码。', to_date('28-07-2015', 'dd-mm-yyyy'), to_date('07-08-2015 10:46:22', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10814, 10857, '账户额度管理', '账户管理', 5, 'accountManagerAction', 'F', 'Y', 'closed', '/jsp/accManage/acccreditslimitindex.jsp', 'icon-dzqbcz', 'A', '账户额度限制管理,设置账户单笔（单日）交易最大额度显示', to_date('31-07-2015', 'dd-mm-yyyy'), to_date('07-08-2015 11:23:08', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10817, 10798, '采购审核保存', '采购审核', 1, 'madeCardCheck', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-checkInfo', 'I', null, to_date('03-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:35:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10818, 10664, '卫生申领', '申领信息', 6, '卫生申领', 'F', 'Y', 'closed', '/jsp/cardApp/wsApply.jsp', null, 'I', null, to_date('03-08-2015 17:01:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('03-08-2015 17:02:12', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10819, 10638, '卫生申领', '制作管理', 6, '卫生申领', 'F', 'Y', 'closed', '/jsp/cardApp/wsApply.jsp', 'icon-cardService', 'A', null, to_date('03-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:31:32', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10820, 10638, '导出银行', '制作管理', 7, '银行申领', 'F', 'Y', 'closed', '/jsp/cardApp/yhApply.jsp', 'icon-dzqbcz', 'A', '导出银行', to_date('03-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:31:47', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10821, 10820, '银行申领查询', '银行申领', 1, 'yhApplyQuery', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-tip', 'A', null, to_date('03-08-2015 17:08:11', 'dd-mm-yyyy hh24:mi:ss'), to_date('03-08-2015 17:08:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10822, 10820, '银行申领确认', '银行申领', 2, 'yhApplySave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', null, to_date('03-08-2015 17:09:56', 'dd-mm-yyyy hh24:mi:ss'), to_date('03-08-2015 17:09:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10823, 10820, '银行返回上传', '银行申领', 3, 'yhApplyUpload', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-undo', 'A', null, to_date('03-08-2015 17:11:10', 'dd-mm-yyyy hh24:mi:ss'), to_date('03-08-2015 17:11:10', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10824, 10819, '卫生申领查询', '卫生申领', 1, 'wsApplyQuery', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-tip', 'I', null, to_date('03-08-2015', 'dd-mm-yyyy'), to_date('11-08-2015 20:18:25', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10825, 10819, '卫生申领确认', '卫生申领', 2, 'wsApplySave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'I', null, to_date('03-08-2015 17:16:16', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-08-2015 20:18:32', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10826, 10819, '卫生申领返回', '卫生申领', 3, 'wsApplyUpload', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-undo', 'I', null, to_date('03-08-2015', 'dd-mm-yyyy'), to_date('11-08-2015 20:18:36', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10828, 11109, '账户激活管理', '状态管理', 7, 'accountManagerAction', 'F', 'Y', 'closed', '/jsp/accManage/accenableindex.jsp', 'icon-account_enable', 'A', '账户激活', to_date('04-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:31:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10829, 11109, '账户冻结管理', '状态管理', 8, 'accountManagerAction', 'F', 'Y', 'closed', '/jsp/accManage/accfreezeindex.jsp', 'icon-accountLock', 'A', '账户金额冻结', to_date('04-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:31:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10830, null, '账户管理', null, 4, 'accountsManag', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon_accounts_Manage', 'A', '账户管理', to_date('05-08-2015', 'dd-mm-yyyy'), to_date('07-08-2015 11:16:13', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10831, 10859, '日终处理', '清分结算', 1, 'accDayBal', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon_accounts_DayBal', 'A', '日终处理', to_date('05-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:01:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10832, 10831, '柜员扎帐', '扎帐处理', 1, 'userDayBal', 'F', 'Y', 'closed', '/cuteDayManage/cuteDayAction!initUserInfo.action', 'icon-userCuteDayBal', 'A', '柜员扎帐', to_date('05-08-2015', 'dd-mm-yyyy'), to_date('05-08-2015 15:15:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10833, 10831, '网点扎帐', '扎帐处理', 2, 'branchDayBal', 'F', 'Y', 'closed', '/cuteDayManage/cuteDayAction!initBrchInfo.action', 'icon-brchCuteDayBal', 'A', '网点扎帐', to_date('05-08-2015', 'dd-mm-yyyy'), to_date('05-08-2015 22:16:40', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10834, 10832, '临时扎帐', '柜员扎帐', 1, 'userDayCutTemp', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'I', '临时扎帐', to_date('05-08-2015 15:29:42', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-08-2015 15:41:22', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10835, 10832, '最终扎帐', '柜员扎帐', 2, 'userCuteDayEnd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '最终扎帐', to_date('05-08-2015 15:30:35', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-08-2015 15:30:35', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10837, 10833, '强制柜员扎帐', '网点扎帐', 2, 'enforceUserDayBal', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-paraManage', 'A', '强制柜员扎帐', to_date('05-08-2015', 'dd-mm-yyyy'), to_date('10-08-2015 09:13:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10857, 10830, '基本信息', '账户管理', 1, 'javascript:void(0)', 'F', 'Y', 'closed', 'javascript:void(0)', 'icon-walletConsumeDo', 'A', null, to_date('07-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:59:13', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10858, 963, '卡片补卡', '卡片服务', 1, 'cardService', 'F', 'Y', 'closed', '/cardService/cardServiceAction!bkCardIndex.action', 'icon-account_lock01', 'A', null, to_date('07-08-2015', 'dd-mm-yyyy'), to_date('10-08-2015 10:57:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10860, 371, '单个上传', '照片导入', 1, 'photoSignUpload', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '单个上传', to_date('10-08-2015 14:45:59', 'dd-mm-yyyy hh24:mi:ss'), to_date('10-08-2015 14:45:59', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10861, 371, '读身份证上传', '照片导入', 2, 'readCertUpload', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '读身份证上传', to_date('10-08-2015', 'dd-mm-yyyy'), to_date('10-08-2015 14:47:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10862, 371, '批量上传', '照片导入', 3, 'photoZipUpload', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '批量上传', to_date('10-08-2015', 'dd-mm-yyyy'), to_date('10-08-2015 14:48:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10877, 10819, '任务明细预览', '卫生申领', 0, 'viewHealthTaskList', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', '任务明细预览', to_date('11-08-2015 20:21:01', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-08-2015 20:21:01', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10878, 10819, '明细添加', '卫生申领', 1, 'addHealthTaskList', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '明细添加', to_date('11-08-2015', 'dd-mm-yyyy'), to_date('11-08-2015 20:23:30', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10879, 10819, '明细删除', '卫生申领', 2, 'deleteHealthTaskList', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '明细删除', to_date('11-08-2015 20:24:26', 'dd-mm-yyyy hh24:mi:ss'), to_date('11-08-2015 20:24:26', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10881, 233, '查看预览', '批量申领', 1, 'batchApplyView', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-viewInfo', 'A', null, to_date('12-08-2015 14:26:13', 'dd-mm-yyyy hh24:mi:ss'), to_date('12-08-2015 14:26:13', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10886, 10640, '任务删除', '制卡任务管理', 5, 'toTaskDelete', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-bdel', 'A', null, to_date('14-08-2015 13:26:05', 'dd-mm-yyyy hh24:mi:ss'), to_date('14-08-2015 13:26:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10887, 10640, '增加人员', '制卡任务管理', 7, 'addTaskList', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', null, to_date('14-08-2015 14:12:33', 'dd-mm-yyyy hh24:mi:ss'), to_date('14-08-2015 14:12:33', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10891, 968, '申领服务', '柜面服务', 4, 'cardIssue', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-branchEditMange', 'A', null, to_date('14-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:38:42', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10892, 10891, '个人发放', '申领发放', 3, 'oneCardIssuse', 'F', 'Y', 'closed', '/jsp/cardIssuse/oneCardIssuse.jsp', 'icon-accManage', 'A', null, to_date('14-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:19:00', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10893, 10891, '规模发放', '申领发放', 4, 'batchIssuse', 'F', 'Y', 'closed', '/jsp/cardIssuse/batchIssuse.jsp', 'icon-userCuteDayBal', 'A', null, to_date('14-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:19:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10894, 963, '卡片换卡', '卡片服务', 2, 'CardService', 'F', 'Y', 'closed', '/cardService/cardServiceAction!hkCardIndex.action', 'icon_accounts_Manage', 'A', null, to_date('15-08-2015', 'dd-mm-yyyy'), to_date('15-08-2015 17:28:29', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10895, 10891, '卡片回收登记', '申领发放', 8, 'cardRecoverReg', 'F', 'Y', 'closed', '/jsp/cardRecoverRegister/cardRecoverReg.jsp', 'icon-taskExpBank', 'A', '卡片回收登记', to_date('15-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:10:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10896, 10891, '卡片回收登记撤销', '申领发放', 9, 'cardRecRegUndo', 'F', 'Y', 'closed', '/jsp/cardRecoverRegister/cardRecoverRegUndo.jsp', 'icon-ljcx', 'A', '卡片回收登记撤销', to_date('15-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:10:36', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10897, 10894, '换卡免功能费权限', '卡片换卡', 1, 'chgCardNoMoney', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '换卡免功能费权限,有权限则换卡原因下拉框显示：质量原因，工本费0元，没有此权限将收取20元工本费', to_date('16-08-2015 00:00:12', 'dd-mm-yyyy hh24:mi:ss'), to_date('16-08-2015 00:00:12', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11091, 10638, '银行导入', '制作管理', 8, 'yhImportApply', 'F', 'Y', 'closed', '/jsp/cardApp/yhImportApply.jsp', 'icon-back', 'A', '银行导入', to_date('17-08-2015', 'dd-mm-yyyy'), to_date('25-08-2015 10:15:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11092, 10638, '预申领查询', '制作管理', 2, '预申领查询', 'F', 'Y', 'closed', '/jsp/cardApp/queryApplyView.jsp', 'icon-walletConsumeDo', 'A', '预申领查询', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:33:06', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11093, 11092, '预申领删除', '预申领查询', 1, 'delApplyView', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-cancel', 'A', null, to_date('18-08-2015 13:04:58', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 13:04:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11094, 10891, '发放撤销', '申领发放', 5, 'undoCardIssuse', 'F', 'Y', 'closed', '/jsp/cardIssuse/undoCardIssuse.jsp', 'icon-undo', 'A', '发放撤销', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:19:38', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11095, 10891, '申领情况查询', '申领发放', 10, 'applyStateQuery', 'F', 'Y', 'closed', '/jsp/', 'icon-auto', 'I', '申领情况查询', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:22:46', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11096, 963, '综合信息查询', '卡片服务', 12, 'cardCompQuery', 'F', 'Y', 'closed', '/jsp/cardService/cardCompQuery.jsp', 'icon-payment', 'A', '综合信息查询', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:28:25', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11097, 10638, '制卡情况查询', '制作管理', 11, 'query', 'F', 'Y', 'closed', '/jsp', 'icon-payment', 'A', '制卡情况查询', to_date('18-08-2015 15:36:05', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 15:36:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11098, 10638, '第三方审核结果查询', '制作管理', 12, 'queryExpState', 'F', 'Y', 'closed', '/jsp/cardApp/queryExpState.jsp', 'icon-end', 'A', '第三方审核结果查询', to_date('18-08-2015 15:37:42', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 15:37:42', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11099, 10637, '参数管理', '卡物管理', 5, 'cardParaManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-orgAccManage', 'A', '参数管理', to_date('18-08-2015 15:39:55', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 15:39:55', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11100, 10637, 'PASM卡管理', '卡物管理', 6, 'pasmManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-dzqbcz', 'A', 'PASM卡管理', to_date('18-08-2015 15:41:35', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 15:41:35', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11101, 4080, '商户管理', '基础管理', 2, 'merchantManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-merchantQues', 'A', '商户管理', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:53:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10449, 4143, '商户结算打印', '商户结算处理', 2, 'printSettle', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-print', 'A', '商户结算打印', to_date('05-06-2015', 'dd-mm-yyyy'), to_date('06-06-2015 00:03:40', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10450, 10347, '联机账户读卡充值', '联机账户充值', 1, 'OnlineRechargeReadCard', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '联机账户读卡充值', to_date('05-06-2015 15:55:15', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-06-2015 15:55:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10451, 10347, '联机账户(无卡)充值', '联机账户充值', 2, 'OnlineRechargeQueryCard', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '联机账户(无卡)充值,输入卡号查询，充值。', to_date('05-06-2015 15:57:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-06-2015 15:57:36', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10452, 10347, '联机充值确定', '联机账户充值', 3, 'OnlineRechargeSave', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '联机充值确定,点击保存确定充值。', to_date('05-06-2015 16:02:12', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-06-2015 16:02:12', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10479, 10349, '联机账户充值撤销保存', '联机充值撤销', 2, 'onlinerechargecanelsave', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '联机账户充值撤销查询按钮', to_date('06-06-2015', 'dd-mm-yyyy'), to_date('06-06-2015 14:47:53', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10480, 10349, '联机账户充值撤销查询', '联机充值撤销', 1, 'onlinerechargecanelquery', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '联机账户充值撤销查询', to_date('06-06-2015 14:47:28', 'dd-mm-yyyy hh24:mi:ss'), to_date('06-06-2015 14:47:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10489, 4145, '商户结算预览', '商户结算支付', 1, 'merpaymentView', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', '商户结算预览', to_date('06-06-2015 15:23:29', 'dd-mm-yyyy hh24:mi:ss'), to_date('06-06-2015 15:23:29', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10490, 4145, '商户结算支付', '商户结算支付', 2, 'merpaymentSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-payment', 'A', '商户结算支付', to_date('06-06-2015 15:24:20', 'dd-mm-yyyy hh24:mi:ss'), to_date('06-06-2015 15:24:20', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10634, 1082, '联机转账联机', '充值业务', 5, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/rechargeservice/transfersonlineacc2onlineacc.jsp', 'icon-orgOpenAcc', 'A', '联机转联机充值', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-06-2015 22:12:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10635, 10634, '联机转脱机账户', '联机转账联机', 6, 'javascript:void(0)', 'F', 'Y', 'closed', '11', null, 'I', '卡片联机账户转脱机账户充值', to_date('07-06-2015 00:04:46', 'dd-mm-yyyy hh24:mi:ss'), to_date('07-06-2015 00:05:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10636, 1082, '联机转账脱机', '充值业务', 6, 'OnlineToOffline', 'F', 'Y', 'closed', '/jsp/rechargeservice/transfersonlineacc2offlineacc.jsp', 'icon-time', 'A', null, to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-06-2015 22:12:08', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10637, null, '卡务管理', null, 2, 'madeCardMag', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-madeCardMag', 'A', '卡物管理', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:19:53', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10638, 10637, '制作管理', '卡物管理', 2, 'madeCardOnlyMag', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-madeCardOnly', 'A', '个性化制卡', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:30:30', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10639, 10637, '非个性化制卡', '卡物管理', 3, 'madeCardNotOnly', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-madeCardNotOnly', 'I', '非个性化制卡', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:35:09', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10640, 10638, '制卡任务管理', '制作管理', 4, 'madeCardOlyGL', 'F', 'Y', 'closed', 'jsp/taskManage/taskMain.jsp', 'icon-makeTaskMag', 'A', '制卡任务管理', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:33:40', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10642, 10819, '导出卫生', '卫生申领', 4, 'cardOnlyTaskExpToHealth', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '导出卫生', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('11-08-2015 20:21:25', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10643, 10820, '导出银行', '银行申领', 3, 'cardOnlyTaskExpToBank', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '导出银行', to_date('07-06-2015', 'dd-mm-yyyy'), to_date('11-08-2015 20:12:59', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10659, 10819, '导入卫生返回', '卫生申领', 5, 'cardOnlyTaskImpByHealth', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-import', 'A', '导入卫生返回', to_date('09-06-2015', 'dd-mm-yyyy'), to_date('11-08-2015 20:21:38', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10660, 11091, '导入银行返回', '银行导入', 4, 'cardOnlyTaskImpByBank', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-import', 'A', '导入银行返回', to_date('10-06-2015', 'dd-mm-yyyy'), to_date('17-08-2015 21:19:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10661, 10640, '导入卡厂返回', '制卡任务管理', 5, 'cardOnlyTaskImpByFact', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-import', 'A', '导入卡厂返回', to_date('10-06-2015', 'dd-mm-yyyy'), to_date('10-06-2015 15:59:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10664, 10891, '申领信息查询', '申领发放', 10, 'cardAppMore', 'F', 'Y', 'closed', '/jsp/cardApp/applyMsg.jsp', 'icon-orgOpenAcc', 'A', '申领历史信息查询', to_date('12-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:23:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10679, 10640, '批量开户', '制卡任务管理', 6, 'cardOnlyTaskOpenAcc', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'I', '批量开户', to_date('15-06-2015 12:10:59', 'dd-mm-yyyy hh24:mi:ss'), to_date('15-06-2015 15:30:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10680, 10343, '联机账户支付密码修改保存', '交易密码修改', 1, 'savePayPwdModify', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '联机账户支付密码修改保存', to_date('15-06-2015 23:03:49', 'dd-mm-yyyy hh24:mi:ss'), to_date('15-06-2015 23:03:49', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10681, 10344, '联机账户支付密码重置', '交易密码重置', 1, 'savePayPwdReset', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '联机账户支付密码重置', to_date('15-06-2015 23:04:28', 'dd-mm-yyyy hh24:mi:ss'), to_date('15-06-2015 23:04:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10699, 10429, '柜面业务统计', '柜面查询', 3, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/statistics/businessAmount.jsp', 'icon-role', 'A', null, to_date('16-06-2015', 'dd-mm-yyyy'), to_date('16-06-2015 09:49:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10700, 4147, '预览结算明细', '商户结算查询', 1, 'viewMerSettleInfo_Query', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', '预览结算明细', to_date('16-06-2015', 'dd-mm-yyyy'), to_date('16-06-2015 10:34:46', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10701, 4147, '商户结算Exec导出', '商户结算查询', 2, 'merQuexportExcel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-excel', 'A', '商户结算Exec导出', to_date('16-06-2015 10:35:50', 'dd-mm-yyyy hh24:mi:ss'), to_date('16-06-2015 10:35:50', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10702, 4147, '商户结算财务导出', '商户结算查询', 3, 'merSettleFinance', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '商户结算财务导出', to_date('16-06-2015', 'dd-mm-yyyy'), to_date('16-06-2015 10:37:03', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10719, 10638, '非个性化卡制作', '制作管理', 10, 'madenotonlyCard', 'F', 'Y', 'closed', 'jsp/madeCardManage/madeNotOnlyCard.jsp', 'icon-madeCardPro', 'A', '非个性化卡制作', to_date('17-06-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:34:46', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10797, 10857, '账户类型管理', '账户管理', 2, 'javascript:void(0)', 'F', 'Y', 'closed', '/accountManager/accountManagerAction!accTypeIndex.action', 'icon-account_card', 'A', '账户类型管理', to_date('25-07-2015', 'dd-mm-yyyy'), to_date('07-08-2015 10:45:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10800, 4108, '商户消费模式设置', '商户结算', 5, 'merGetCosMode', 'F', 'Y', 'closed', '/jsp/merchant/merGetCosModeMian.jsp', 'icon-merchantAdd', 'A', '商户消费模式设置', to_date('28-07-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:04:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10801, 10800, '商户消费模式新增', '商户消费模式设置', 1, 'merGetCosModeAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '商户消费模式新增', to_date('28-07-2015', 'dd-mm-yyyy'), to_date('28-07-2015 16:50:10', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10802, 10800, '商户消费模式编辑', '商户消费模式设置', 2, 'merGetCosModeEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '商户消费模式编辑', to_date('28-07-2015', 'dd-mm-yyyy'), to_date('28-07-2015 16:50:41', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10827, 11109, '账户锁定管理', '状态管理', 7, 'accountManagerAction', 'F', 'Y', 'closed', '/jsp/accManage/acclockandunlock.jsp', 'icon-account_lock01', 'A', '账户锁定与解锁', to_date('03-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:31:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10836, 10833, '最终扎帐', '网点扎帐', 1, 'brchDayBalEnd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '最终扎帐', to_date('05-08-2015 22:20:02', 'dd-mm-yyyy hh24:mi:ss'), to_date('05-08-2015 22:20:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10859, null, '清分结算', null, 5, 'strogeRoomManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon_stroge-room', 'A', '库房管理', to_date('10-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:00:38', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10882, 228, '批量申领撤销', '申领服务', 8, '批量申领撤销', 'F', 'Y', 'closed', '/jsp/cardApp/delBatch.jsp', 'icon-comp', 'I', null, to_date('13-08-2015', 'dd-mm-yyyy'), to_date('13-08-2015 20:59:34', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10883, 10882, '批量申领撤销保存', '批量申领撤销', 2, 'delBatchSave', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-save', 'I', null, to_date('13-08-2015', 'dd-mm-yyyy'), to_date('13-08-2015 20:59:24', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10884, 10882, '批量申领撤销查询', '批量申领撤销', 1, 'delBatchQuery', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-tip', 'I', null, to_date('13-08-2015', 'dd-mm-yyyy'), to_date('13-08-2015 20:59:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10885, 10640, '任务查看删除人员', '制卡任务管理', 3, 'deleteTaskList', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-cancel', 'A', null, to_date('14-08-2015', 'dd-mm-yyyy'), to_date('14-08-2015 09:43:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10888, 10719, '新增非个性化卡采购任务', '采购计划', 1, 'notOnlyCardTaskAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '新增非个性化卡采购任务', to_date('14-08-2015', 'dd-mm-yyyy'), to_date('14-08-2015 17:07:32', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10889, 10719, '删除非个性化卡采购任务', '采购计划', 2, 'notOnlyCardTaskDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '删除非个性化卡采购任务', to_date('14-08-2015 17:07:08', 'dd-mm-yyyy hh24:mi:ss'), to_date('14-08-2015 17:07:08', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10890, 10719, '导出非个性化卡采购任务', '采购计划', 3, 'notOnlyCardTaskExp', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-export', 'A', '导出非个性化卡采购任务', to_date('14-08-2015 17:09:02', 'dd-mm-yyyy hh24:mi:ss'), to_date('14-08-2015 17:09:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10898, 963, '应用锁定', '卡片服务', 8, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/cardService/applock.jsp', 'icon-signin', 'A', '卡片应用锁定', to_date('16-08-2015', 'dd-mm-yyyy'), to_date('16-08-2015 12:19:09', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10899, 963, '应用解锁', '卡片服务', 9, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/cardService/appunlock.jsp', 'icon-signout', 'A', '卡片应用解锁', to_date('16-08-2015', 'dd-mm-yyyy'), to_date('16-08-2015 12:19:39', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10900, 963, '卡内信息查询', '卡片服务', 10, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/cardService/cardinfoandaccinfo.jsp', 'icon-accManage', 'A', '卡片信息查询、账户信息查询、卡内信息查询', to_date('16-08-2015', 'dd-mm-yyyy'), to_date('19-08-2015 17:00:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10902, 10898, '卡片应用锁定保存', '应用锁定', 1, 'saveAppLockHjl', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '卡片应用锁定保存', to_date('17-08-2015', 'dd-mm-yyyy'), to_date('17-08-2015 11:18:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10917, 10892, '发放保存', '个人发放', 1, 'toOneCardIssuse', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', null, to_date('17-08-2015 15:10:39', 'dd-mm-yyyy hh24:mi:ss'), to_date('17-08-2015 15:10:39', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (10918, 10893, '规模发放保存', '规模发放', 1, 'toBatchSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', null, to_date('17-08-2015', 'dd-mm-yyyy'), to_date('17-08-2015 15:12:44', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11090, 968, '银行导入', '柜面服务', 8, 'yhImportApply', 'F', 'Y', 'closed', '/jsp/cardApp/yhImportApply.jsp', 'icon-back', 'I', '银行导入', to_date('17-08-2015 21:17:12', 'dd-mm-yyyy hh24:mi:ss'), to_date('17-08-2015 21:18:06', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (44, 1, '日志管理', '系统管理', 45, 'logMgr', 'F', 'Y', 'closed', 'jsp/logs/logsMain.jsp', 'icon-pro', 'I', '日志管理', to_date('18-06-2013', 'dd-mm-yyyy'), to_date('27-08-2015 14:10:11', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (45, null, '123123', null, 123, '123', 'F', 'Y', 'closed', '123', null, 'I', '123123123', to_date('18-06-2013', 'dd-mm-yyyy'), to_date('18-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (38, 4, 'ttttt', '数据库管理', 123, '123123123123', 'F', 'N', 'closed', '123', 'icon-undo', 'I', '123123123123123123', to_date('14-06-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (28, 1, '用户角色分派', '系统管理', 16, 'userRoleMgr', 'F', 'Y', 'closed', 'jsp/roleConfig/roleConfigMain.jsp', 'icon-role', 'A', '用户角色分配', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('22-06-2013 09:16:35', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (27, 1, '柜员管理', '系统管理', 15, 'userMain', 'F', 'Y', 'closed', 'jsp/user/userMain.jsp', 'icon-adds', 'A', '用户管理', to_date('27-05-2013', 'dd-mm-yyyy'), to_date('21-07-2015 21:25:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (55, 4, '12312311', '数据库管理', 123, '123', 'O', 'Y', 'closed', '123', null, 'I', '123123123123123123123', to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (36, 27, '用户del', '用户管理', 1, '123', 'F', 'Y', 'closed', '123', 'icon-cancel', 'I', '123123', to_date('14-06-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (50, 1, '数据字典', '系统管理', 5, 'dicMgr', 'F', 'N', 'closed', 'jsp/systemCode/systemCodeMain.jsp', 'icon-undo', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-08-2015 16:20:41', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1, 967, '系统管理', '系统管理', 4, 'sysMgr', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-config', 'A', '系统管理', to_date('23-05-2013', 'dd-mm-yyyy'), to_date('18-08-2015 16:18:42', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1331, 1095, '机构管理', '机构管理', 1, 'orgManageIndex', 'F', 'Y', 'closed', 'jsp/orgManage/orgManageMain.jsp', 'icon-orgAccManage', 'A', '机构管理', to_date('27-04-2015', 'dd-mm-yyyy'), to_date('27-04-2015 23:51:29', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1333, 1095, '机构账户开户', '机构管理', 2, 'orgAccManage', 'F', 'N', 'closed', 'jsp/orgManage/orgOpenMain.jsp', 'icon-orgOpenAcc', 'I', '机构账户开户', to_date('27-04-2015', 'dd-mm-yyyy'), to_date('22-05-2015 19:03:46', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (243, 228, '个人信息管理', '客户服务', 1, 'dataAcount', 'F', 'Y', 'closed', 'jsp/dataAcount/dataAcountMain.jsp', 'icon-data-acount', 'A', '个人信息管理', to_date('04-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:07:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1326, 10857, '账户科目管理', '基本信息', 1, 'itemManage', 'F', 'Y', 'closed', 'jsp/paraManage/itemMain.jsp', 'icon-itemManage', 'A', '科目管理', to_date('27-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:17:26', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (780, 228, '测试', '申领服务', 1, '1', 'F', 'Y', 'closed', '1', 'icon-bedit', 'I', null, to_date('23-04-2015', 'dd-mm-yyyy'), to_date('23-04-2015 22:34:02', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1329, 11099, '卡片参数管理', '参数管理', 23, 'cardParaManage', 'F', 'Y', 'closed', 'jsp/paraManage/cardParaMain.jsp', 'icon-itemManage', 'A', '卡参数管理', to_date('27-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:40:18', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1335, 1095, '机构账户销户', '机构管理', 3, 'orgClose', 'F', 'Y', 'closed', 'jsp/orgManage/orgCloseMain.jsp', 'icon-orgCloseAcc', 'I', '机构账户销户', to_date('27-04-2015', 'dd-mm-yyyy'), to_date('21-05-2015 12:27:49', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1342, 1088, '网点账户销户', '网点管理', 3, 'brachClose', 'F', 'Y', 'closed', '3', 'icon-orgCloseAcc', 'I', '网点账户销户', to_date('28-04-2015', 'dd-mm-yyyy'), to_date('22-05-2015 21:30:32', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (867, 780, '测试1', '测试', 1, '1', 'F', 'Y', 'closed', '1', 'icon-role', 'I', null, to_date('23-04-2015 15:44:28', 'dd-mm-yyyy hh24:mi:ss'), to_date('23-04-2015 22:33:59', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (233, 10638, '批量申领', '制作管理', 1, 'cardAppMore', 'F', 'Y', 'closed', '/jsp/cardApp/batchApplyView.jsp', 'icon-card-apply', 'A', '批量申领', to_date('04-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:32:52', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (231, 10891, '个人申领', '申领发放', 1, 'oneCardApp', 'F', 'Y', 'closed', 'jsp/cardApp/oneCardApply.jsp', 'icon-card-apply', 'A', '个人申领', to_date('04-04-2015', 'dd-mm-yyyy'), to_date('21-08-2015 19:40:37', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (228, 968, '客户服务', '柜面服务', 0, 'cardApp', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-item', 'A', '客户服务', to_date('04-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 15:07:30', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1557, 1553, '解挂保存', '卡片解挂', 1, 'cardunLostSave', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-ok', 'A', '解挂保存', to_date('04-05-2015', 'dd-mm-yyyy'), to_date('04-05-2015 20:29:00', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1095, 967, '机构管理', '系统管理', 1, 'orgManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-orgManage', 'A', '机构管理', to_date('26-04-2015 14:18:54', 'dd-mm-yyyy hh24:mi:ss'), to_date('26-04-2015 14:18:54', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1553, 963, '卡片解挂', '卡片服务', 4, 'cardunLost', 'F', 'Y', 'closed', 'jsp/cardService/cardUnlockManageMain.jsp', 'icon-cardunlostManage', 'A', '卡片解挂', to_date('04-05-2015 20:20:00', 'dd-mm-yyyy hh24:mi:ss'), to_date('04-05-2015 20:20:00', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1324, 967, '日志管理', '系统管理', 5, 'logManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-paraManage', 'I', '日志管理', to_date('27-04-2015', 'dd-mm-yyyy'), to_date('27-08-2015 14:09:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (2014, 965, '服务密码修改', '密码服务', 1, 'ServicePassword', 'F', 'Y', 'closed', '/jsp/pwdservice/servicepwdmodify.jsp', 'icon-time', 'A', null, to_date('16-05-2015', 'dd-mm-yyyy'), to_date('16-05-2015 23:16:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (2087, 1331, '机构开户保存', '机构管理', 4, 'orgOpenAcc', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '机构开户保存', to_date('21-05-2015', 'dd-mm-yyyy'), to_date('22-05-2015 17:02:20', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1082, 968, '充值服务', '柜面服务', 7, 'rechgService', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-rechgCard', 'A', '充值业务', to_date('25-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:38:53', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (371, 228, '个人照片导入', '客户服务', 2, 'photoImport', 'F', 'Y', 'closed', 'jsp/photoImport/photoImportMain.jsp', 'icon-pro', 'A', '照片导入', to_date('09-04-2015', 'dd-mm-yyyy'), to_date('18-08-2015 17:01:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1551, 963, '卡片挂失', '卡片服务', 3, 'cardLost', 'F', 'Y', 'closed', 'jsp/cardService/cardLostManage.jsp', 'icon-cardlostManage', 'A', '卡片挂失', to_date('04-05-2015 20:13:10', 'dd-mm-yyyy hh24:mi:ss'), to_date('04-05-2015 20:13:10', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1546, 963, '卡片挂失', '卡片服务', 1, 'cardLost', 'F', 'Y', 'closed', 'jsp/cardService/cardLostMain.jsp', 'icon-cardlostManage', 'I', '卡片挂失', to_date('04-05-2015', 'dd-mm-yyyy'), to_date('04-05-2015 20:08:20', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (47, 44, '日志新增', '日志管理', 1, 'logAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'I', null, to_date('18-06-2013', 'dd-mm-yyyy'), to_date('27-08-2015 14:10:04', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (62, 59, '保存', '参数设置', 3, 'parSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (56, 4, '12312311', '数据库管理', 123123, '123', 'O', 'Y', 'open', '1231', 'icon-back', 'I', '23123123', to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (60, 59, '结束编辑', '参数设置', 1, 'parEndEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-end', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (61, 59, '删除', '参数设置', 2, 'parDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (52, 50, '字典编辑', '数据字典', 1, 'dicEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (49, 44, '日志删除', '日志管理', 3, 'logDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'I', null, to_date('18-06-2013', 'dd-mm-yyyy'), to_date('27-08-2015 14:10:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (53, 50, '字典删除', '数据字典', 2, 'dicDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (54, 4, '123', '数据库管理', 123, '123', 'O', 'Y', 'open', '123', 'icon-edit', 'I', '123123123123', to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (51, 50, '字典新增', '数据字典', 0, 'dicAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', null, to_date('17-06-2013', 'dd-mm-yyyy'), to_date('17-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (48, 44, '日志编辑', '日志管理', 2, 'logEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'I', null, to_date('18-06-2013', 'dd-mm-yyyy'), to_date('27-08-2015 14:10:01', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (4, 1, '数据库管理', '系统管理', 2, '1123', 'F', 'Y', 'open', 'druid/index.html', 'icon-db', 'A', '123123123123123123', to_date('23-05-2013', 'dd-mm-yyyy'), to_date('20-06-2013 15:08:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (16, 2, '菜单功能新增', '系统管理', 4, 'funAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '菜单功能新增', to_date('24-05-2013', 'dd-mm-yyyy'), to_date('27-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1568, 1329, '卡参数删除', '卡参数管理', 3, 'cardParadel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '卡参数删除', to_date('04-05-2015 21:43:07', 'dd-mm-yyyy hh24:mi:ss'), to_date('04-05-2015 21:43:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (2018, 2014, '服务密码修改', '服务密码修改', 1, 'ServicePassword', 'O', 'Y', 'open', 'javascript:void(0)', 'icon-edit', 'A', '服务密码修改', to_date('16-05-2015', 'dd-mm-yyyy'), to_date('16-05-2015 23:17:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (19, 2, '菜单结束编辑', '系统管理', 7, 'funEndEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'I', '结束编辑', to_date('24-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (20, 2, '菜单保存', '系统管理', 8, 'funSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'I', '保存', to_date('24-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (17, 2, '菜单功能编辑', '系统管理', 5, 'funEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '菜单功能编辑', to_date('24-05-2013', 'dd-mm-yyyy'), to_date('14-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (18, 2, '菜单功能删除', '程式管理', 6, 'funDel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '菜单功能删除', to_date('24-05-2013', 'dd-mm-yyyy'), to_date('02-04-2015 22:52:50', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1566, 1329, '卡参数编辑', '卡参数管理', 2, 'cardParaEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '卡参数编辑', to_date('04-05-2015 21:42:06', 'dd-mm-yyyy hh24:mi:ss'), to_date('04-05-2015 21:42:06', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (637, 371, '照片导入保存', '照片导入', 8, 'photoUplodd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', null, to_date('20-04-2015', 'dd-mm-yyyy'), to_date('10-08-2015 14:46:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (640, 243, '数据采集添加', '数据采集', 1, 'personAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', null, to_date('20-04-2015', 'dd-mm-yyyy'), to_date('20-04-2015 15:50:41', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1404, 1331, '机构添加', '机构管理', 1, 'orgationAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '机构添加', to_date('02-05-2015', 'dd-mm-yyyy'), to_date('02-05-2015 10:59:20', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1407, 1331, '机构编辑', '机构管理', 2, 'orgationEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '机构编辑', to_date('02-05-2015 11:00:15', 'dd-mm-yyyy hh24:mi:ss'), to_date('02-05-2015 11:00:15', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1555, 1551, '挂失保存', '卡片挂失', 1, 'cardLostSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '挂失保存', to_date('04-05-2015', 'dd-mm-yyyy'), to_date('04-05-2015 21:40:23', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1564, 1329, '卡参数添加', '卡参数管理', 1, 'cardParaAdd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '卡参数添加', to_date('04-05-2015 21:41:04', 'dd-mm-yyyy hh24:mi:ss'), to_date('04-05-2015 21:41:04', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (642, 243, '数据采集修改', '数据采集', 2, 'personEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', null, to_date('20-04-2015', 'dd-mm-yyyy'), to_date('20-04-2015 15:50:49', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (1346, 1326, '编辑', '科目管理', 1, 'accItemEdit', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-edit', 'A', '编辑', to_date('28-04-2015', 'dd-mm-yyyy'), to_date('28-04-2015 14:56:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (34, 28, '用户角色分派', '系统管理', 21, 'userRoleConfig', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-config', 'A', '用户角色分派', to_date('29-05-2013', 'dd-mm-yyyy'), to_date('29-05-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (35, 2, '123', '程式管理', 1, '123', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'I', '123123', to_date('13-06-2013', 'dd-mm-yyyy'), to_date('13-06-2013', 'dd-mm-yyyy'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11177, 10638, '制卡导入', '制作管理', 9, 'doCardImp', 'F', 'Y', 'closed', '/jsp/cardApp/doCardImpMain.jsp', 'icon-import', 'A', '制卡导入', to_date('25-08-2015', 'dd-mm-yyyy'), to_date('25-08-2015 10:19:28', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11178, 11177, '制卡导入保存', '制卡导入', 1, 'doCardImpSave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', '制卡导入保存', to_date('25-08-2015', 'dd-mm-yyyy'), to_date('25-08-2015 10:22:01', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11222, 10759, '灰记录自动处理', '灰记录处理', 1, 'ashrecordautosave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', '灰记录自动处理', to_date('26-08-2015', 'dd-mm-yyyy'), to_date('26-08-2015 10:32:08', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11223, 10759, '灰记录确认保存', '灰记录处理', 2, 'ashrecordcofirmsave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '灰记录确认保存', to_date('26-08-2015', 'dd-mm-yyyy'), to_date('26-08-2015 10:31:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11224, 10759, '灰记录冲正保存', '灰记录处理', 3, 'ashrecordcanelsave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-back', 'A', '灰记录冲正保存', to_date('26-08-2015 10:33:06', 'dd-mm-yyyy hh24:mi:ss'), to_date('26-08-2015 10:33:06', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11237, 11218, '商户变更保存', null, 1, 'merchantEidt', 'O', 'Y', 'open', 'javascrip:viod(0);', 'icon-edit', 'A', null, to_date('26-08-2015 20:58:30', 'dd-mm-yyyy hh24:mi:ss'), to_date('26-08-2015 20:58:30', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11238, 11217, '商户信息审核', null, 1, 'merchantCheck', 'O', 'Y', 'open', 'javascript:viod(0);', 'icon-save', 'A', null, to_date('26-08-2015 21:16:09', 'dd-mm-yyyy hh24:mi:ss'), to_date('26-08-2015 21:16:09', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11109, 10830, '状态管理', '账户管理', 2, 'accountStatManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-account_lock01', 'A', '状态管理', to_date('18-08-2015 16:29:56', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 16:29:56', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11163, 11094, '发放撤销保存', '发放撤销', 1, 'undoCardIssuse', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-undo', 'A', null, to_date('19-08-2015', 'dd-mm-yyyy'), to_date('19-08-2015 21:05:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11170, 11102, '合作机构入网审核', null, 2, 'javascript:void(0)', 'F', 'Y', 'closed', '/jsp/agentorg/cooperationagencymanage.jsp', 'icon_accounts_DayBal', 'A', '合作机构入网审核', to_date('22-08-2015', 'dd-mm-yyyy'), to_date('24-08-2015 09:42:25', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11241, 11239, '预览对账明细', '合作机构对账', 1, 'coCheckViewList', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', '预览对账明细', to_date('28-08-2015', 'dd-mm-yyyy'), to_date('28-08-2015 16:28:05', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11242, 11239, '合作机构补交易', '合作机构对账', 2, 'dealdzcorepair', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-back', 'A', '合作机构补交易', to_date('28-08-2015 16:30:14', 'dd-mm-yyyy hh24:mi:ss'), to_date('28-08-2015 16:30:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11243, 11239, '运营机构撤销', '合作机构对账', 3, 'dealdzorgcancel', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-cancel', 'A', '运营机构撤销', to_date('28-08-2015 16:32:07', 'dd-mm-yyyy hh24:mi:ss'), to_date('28-08-2015 16:32:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11244, 11239, '运营机构补交易', '合作机构对账', 4, 'dealdzorgadd', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-adds', 'A', '运营机构补交易', to_date('28-08-2015 16:34:07', 'dd-mm-yyyy hh24:mi:ss'), to_date('28-08-2015 16:34:07', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11245, 11239, '合作机构记录删除', '合作机构对账', 5, 'dealdzdeletemx', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-remove', 'A', '合作机构记录删除', to_date('28-08-2015 16:36:01', 'dd-mm-yyyy hh24:mi:ss'), to_date('28-08-2015 16:36:01', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11277, 11240, '预览公交明细', '脱机数据对账', 1, 'viewGjMx', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-viewInfo', 'A', '预览公交明细', to_date('01-09-2015 17:25:19', 'dd-mm-yyyy hh24:mi:ss'), to_date('01-09-2015 17:25:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11278, 11240, '公交明细调整为可付', '脱机数据对账', 2, 'offlineDeal', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-ok', 'A', '公交明细调整为可付', to_date('01-09-2015 17:59:59', 'dd-mm-yyyy hh24:mi:ss'), to_date('01-09-2015 17:59:59', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11162, 10900, '卡内信息查询读卡', '卡信息查询', 1, 'cardinfoinnerquery', 'O', 'Y', 'open', 'javascript:void(0)', null, 'A', '卡内信息查询读卡', to_date('19-08-2015 12:55:41', 'dd-mm-yyyy hh24:mi:ss'), to_date('19-08-2015 12:55:41', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11179, 11166, '合作机构入网登记新增', null, 1, 'basecoorgregisterAdd', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '合作机构入网登记新增', to_date('25-08-2015 11:57:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 11:57:36', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11180, 11166, '合作机构入网登记编辑', null, 1, 'basecoorgregisterEdit', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '合作机构入网登记编辑', to_date('25-08-2015 11:58:18', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 11:58:18', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11181, 11170, '合作机构入网审核新增', null, 1, 'basecoorgmanageAdd', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '合作机构入网审核新增', to_date('25-08-2015 12:00:41', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 12:00:41', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11182, 11170, '合作机构入网审核编辑', null, 2, 'basecoorgmanageEdit', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '合作机构入网审核编辑', to_date('25-08-2015 12:01:36', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 12:01:36', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11183, 11170, '合作机构入网审核', null, 3, 'basecoorgmanageSh', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '合作机构入网审核', to_date('25-08-2015 12:02:31', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 12:02:31', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11184, 11170, '合作机构入网登记状态管理', null, 4, 'basecoorgmanageState', 'O', 'Y', 'open', 'javascript:void(0);', null, 'A', '合作机构入网登记状态管理', to_date('25-08-2015 12:03:21', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 12:03:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11102, 4080, '合作机构', '基础管理', 3, 'corpManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-merSettleQuery', 'A', '合作机构管理', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('22-08-2015 18:09:18', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11103, 4080, '设备管理', '基础管理', 4, 'equipmentManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-termMag', 'A', '设备管理', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('18-08-2015 16:07:09', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11104, 4080, '基础库房', '基础管理', 5, 'baseStock', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon_accounts_Manage', 'A', '基础库房', to_date('18-08-2015 15:57:17', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 15:57:17', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11105, 10859, '对账管理', '清分结算', 2, 'checkBillManage', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-account_card', 'A', '对账管理', to_date('18-08-2015', 'dd-mm-yyyy'), to_date('26-08-2015 15:57:10', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11106, 10428, '营业报表', '统计查询', 1, 'businessReport', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-print', 'A', '营业报表', to_date('18-08-2015 16:14:51', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 16:14:51', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11107, 10428, '充值消费统计', '统计查询', 2, 'regandconStat', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon-orgBranchAccoutManage', 'A', '充值消费统计', to_date('18-08-2015 16:15:58', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 16:15:58', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11108, 10428, '柜面业务统计', '统计查询', 4, 'countStat', 'F', 'Y', 'closed', 'javascript:void(0);', 'icon_accounts_Manage', 'A', '柜面业务统计', to_date('18-08-2015 16:16:48', 'dd-mm-yyyy hh24:mi:ss'), to_date('18-08-2015 16:16:48', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11168, 10891, '个人申领撤销', null, 2, 'undoOneCardApply', 'F', 'Y', 'closed', '/jsp/cardApp/undoOneCardApply.jsp', 'icon-undo', 'A', null, to_date('20-08-2015', 'dd-mm-yyyy'), to_date('21-08-2015 19:42:31', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11169, 11168, '个人申领撤销保存', null, 1, 'undoOneCardApplySave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', null, to_date('20-08-2015 17:31:45', 'dd-mm-yyyy hh24:mi:ss'), to_date('20-08-2015 17:31:45', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11167, 231, '个人申领保存', null, 1, 'onecardApplySave', 'O', 'Y', 'open', 'javascript:void(0);', 'icon-save', 'A', null, to_date('20-08-2015', 'dd-mm-yyyy'), to_date('27-08-2015 15:42:00', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11239, 11105, '合作机构对账', '对账管理', 1, 'corpcheckbill', 'F', 'Y', 'closed', '/jsp/clrsettlemanage/corpcheckbill.jsp', 'icon_accounts_Manage', 'A', '合作机构对账', to_date('26-08-2015', 'dd-mm-yyyy'), to_date('26-08-2015 22:29:19', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11240, 11105, '脱机数据对账', '对账管理', 2, 'dealofflinebill', 'F', 'Y', 'closed', '/jsp/clrsettlemanage/dealofflineconsume.jsp', 'icon-ljcx', 'A', '脱机数据对账', to_date('26-08-2015 22:31:24', 'dd-mm-yyyy hh24:mi:ss'), to_date('26-08-2015 22:31:24', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11166, 11102, '合作机构入网登记', null, 1, 'CooperationAgency', 'F', 'Y', 'closed', '/jsp/agentorg/cooperationagencyregister.jsp', 'icon-comp', 'A', '合作机构入网登记', to_date('20-08-2015', 'dd-mm-yyyy'), to_date('20-08-2015 17:52:21', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11217, 11101, '商户信息审批', null, 3, '1', 'F', 'Y', 'closed', '/jsp/merchantManage/merchantCheck.jsp', 'icon-merchantMag', 'A', null, to_date('25-08-2015', 'dd-mm-yyyy'), to_date('26-08-2015 21:09:06', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11218, 11101, '商户信息变更', null, 5, '1', 'F', 'Y', 'closed', '/jsp/merchantManage/merchantUpdate.jsp', 'icon-merchantQues', 'A', null, to_date('25-08-2015', 'dd-mm-yyyy'), to_date('26-08-2015 21:10:14', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11219, 11101, '商户资格暂停', null, 6, '1', 'F', 'Y', 'closed', '1', 'icon-counterServiceManage', 'A', null, to_date('25-08-2015 19:52:39', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 19:52:39', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11220, 11101, '商户资格启用', null, 7, '1', 'F', 'Y', 'closed', '1', 'icon-sys', 'A', null, to_date('25-08-2015 19:53:43', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 19:53:43', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11221, 11101, '商户退网登记', null, 9, '1', 'F', 'Y', 'closed', '1', 'icon-undo', 'A', null, to_date('25-08-2015 19:55:03', 'dd-mm-yyyy hh24:mi:ss'), to_date('25-08-2015 19:55:03', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

insert into SYS_PERMISSION (PERMISSION_ID, PID, NAME, PNAME, SORT, MYID, TYPE, ISUSED, STATE, URL, ICONCLS, STATUS, DESCRIPTION, CREATED, LASTMOD, CREATER, MODIFYER)
values (11257, 1066, '存款确认', null, 4, 'cashManageAction', 'F', 'Y', 'closed', '/jsp/cashmanage/depositoutletsconfirm.jsp', 'icon_accounts_DayBal', 'A', '网点存款确认', to_date('01-09-2015', 'dd-mm-yyyy'), to_date('02-09-2015 16:06:01', 'dd-mm-yyyy hh24:mi:ss'), 1, 1);

prompt Done.