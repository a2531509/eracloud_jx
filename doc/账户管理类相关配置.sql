--增加系统参数信息
--insert into SYS_PARA (PARA_CODE, PARA_VALUE, PARA_VALUE2, PARA_VALUE3, PARA_VALUE4, PARA_VALUE5, PARA_VALUE6, PARA_VALUE7, PARA_VALUE8, PARA_DESC)
--values ('TRADE_PWD_DEFAULT', '666888', null, null, null, null, null, null, null, '创建账户时：交易密码初始密码，密码规则为常数时有效');
--修改城市代码（生成卡号前4位）
--update SYS_PARA t set t.para_value = '7500' where t.para_code = 'CITY_CODE'
--++++++++++++++账户类型相关操作交易代码+++++++++++++++++++++++++++++++++++++++++++++++++++
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50101010, '新增账户类型', 'ACC_MANAGER', 'ADD', null, null, null, null, null, null, null, null, '1', '1', '0', '新增账户类型', 1, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50101020, '编辑账户类型', 'ACC_MANAGER', 'EDIT', null, null, null, null, null, null, null, null, '1', '1', '0', '编辑账户类型', 2, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50101031, '删除账户类型', 'ACC_MANAGER', 'DEL', null, null, null, null, null, null, null, null, '1', '1', '0', '删除账户类型', 3, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50201010, '启用账户类型', 'ACC_MANAGER', 'ENABLE', null, null, null, null, null, null, null, null, '1', '1', '0', '启用账户类型', 4, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50201021, '禁用账户类型', 'ACC_MANAGER', 'DISABLE', null, null, null, null, null, null, null, null, '1', '1', '0', '禁用账户类型', 5, null);

--++++++++++++++账户开户规则交易码+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50301010, '新增账户状态和禁止交易码进行关联', 'ACC_STATE_TRADING_BAN_MANAGER', 'ADD', null, null, null, null, null, null, null, null, '1', '1', '0', '新增账户状态和禁止交易码进行关联', 1, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50301020, '编辑账户状态和禁止交易码进行关联', 'ACC_STATE_TRADING_BAN_MANAGER', 'EDIT', null, null, null, null, null, null, null, null, '1', '1', '0', '编辑账户状态和禁止交易码进行关联', 2, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50301031, '删除账户状态和禁止交易码进行关联', 'ACC_STATE_TRADING_BAN_MANAGER', 'DEL', null, null, null, null, null, null, null, null, '1', '1', '0', '删除账户状态和禁止交易码进行关联', 3, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50301040, '启用账户状态和禁止交易码进行关联', 'ACC_STATE_TRADING_BAN_MANAGER', 'ENABLE', null, null, null, null, null, null, null, null, '1', '1', '0', '启用账户状态和禁止交易码进行关联', 4, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50301051, '禁用账户状态和禁止交易码进行关联', 'ACC_STATE_TRADING_BAN_MANAGER', 'DISABLE', null, null, null, null, null, null, null, null, '1', '1', '0', '禁用账户状态和禁止交易码进行关联', 5, null);

--++++++++++++++++账户消费额度限制管理+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50401010, '新增账户消费限额信息', 'ACC_CREDIT_LIMIT', 'ADD', null, null, null, null, null, null, null, null, '1', '1', '0', '新增账户消费限额信息', 1, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50401020, '编辑账户消费限额信息', 'ACC_CREDIT_LIMIT', 'EDIT', null, null, null, null, null, null, null, null, '1', '1', '0', '编辑账户消费限额信息', 2, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50401031, '删除账户消费限额信息', 'ACC_CREDIT_LIMIT', 'DEL', null, null, null, null, null, null, null, null, '1', '1', '0', '删除账户消费限额信息', 3, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50401040, '启用账户消费限额信息', 'ACC_CREDIT_LIMIT', 'ENABLE', null, null, null, null, null, null, null, null, '1', '1', '0', '启用账户消费限额信息', 4, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50401051, '禁用账户消费限额信息', 'ACC_CREDIT_LIMIT', 'DISABLE', null, null, null, null, null, null, null, null, '1', '1', '0', '禁用账户消费限额信息', 5, null);

--++++++++++++++++账户锁定与解锁管理,账户冻结与解冻+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50501011, '账户锁定', 'ACC_STATE', 'LOCK', null, null, null, null, null, null, null, null, '1', '1', '0', '账户锁定', 1, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50501020, '账户解锁', 'ACC_STATE', 'UNLOCK', null, null, null, null, null, null, null, null, '1', '1', '0', '账户解锁', 2, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50501030, '账户激活', 'ACC_STATE', 'ENABLE', null, null, null, null, null, null, null, null, '1', '1', '0', '账户激活', 3, null);

insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50501040, '账户冻结', 'ACC_STATE', 'FREEZE', null, null, null, null, null, null, null, null, '1', '1', '0', '账户冻结', 4, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50501051, '账户解冻', 'ACC_STATE', 'UNFREEZE', null, null, null, null, null, null, null, null, '1', '1', '0', '账户解冻', 5, null);

--++++++++++++++++人员基础信息管理新增/编辑++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (10101010, '人员基础信息新增', 'BASE_DATA', 'ADD', null, null, null, null, null, null, null, null, '1', '1', '0', '人员基础信息新增', 1, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (10101020, '人员基础信息编辑', 'BASE_DATA', 'EDIT', null, null, null, null, null, null, null, null, '1', '1', '0', '人员基础信息编辑', 2, null);

--++++++++++++++++任务管理++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20201050, '任务删除', 'TASK_MANAGE', 'DELETE', null, null, null, null, null, null, null, null, '1', '1', '0', '任务删除', 2, null);

insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20201030, '任务生成', 'TASK_MANAGE', 'ADD', null, null, null, null, null, null, null, null, '1', '1', '0', '任务生成', 2, null);

insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20201040, '任务查询', 'TASK_MANAGE', 'QUERY', null, null, null, null, null, null, null, null, '1', '1', '0', '任务查询', 2, null);

--+++++++++++++++++++++++++++++++++++卡服务+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501010, '补卡', 'NAMEDCARD', 'REISSUE', null, null, null, null, null, null, null, null, '1', '1', '0', '补卡', 1, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501020, '换卡', 'NAMEDCARD', 'CHG', null, null, null, null, null, null, null, null, '1', '1', '0', '换卡', 2, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501030, '非记名卡换卡', 'NONAMEDCARD', 'CHG', null, null, null, null, null, null, null, null, '1', '1', '0', '非记名卡换卡', 3, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501040, '挂失', 'CARD', 'LOSS', null, null, null, null, null, null, null, null, '1', '1', '0', '挂失', 4, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501050, '预挂失', 'CARD', 'LOSS_PRE', null, null, null, null, null, null, null, null, '1', '1', '0', '预挂失', 5, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501060, '解挂', 'CARD', 'RELOSS', null, null, null, null, null, null, null, null, '1', '1', '0', '解挂', 6, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501070, '注销', 'NAMEDCARD', 'REDEEM', null, null, null, null, null, null, null, null, '1', '1', '0', '注销', 7, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501080, '余额返现', 'BALANCE', 'RESTORE', null, null, null, null, null, null, null, null, '1', '1', '0', '余额返现', 8, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501090, '卡片应用锁定', 'CARD_APP', 'LOCK', null, null, null, null, null, null, null, null, '1', '1', '0', '卡片应用锁定', 9, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501100, '卡片应用解锁', 'CARD_APP', 'UNLOCK', null, null, null, null, null, null, null, null, '1', '1', '0', '卡片应用解锁', 10, null);

insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501160, '公交子类型修改', 'CARD_BUS_TYPE', 'MOD', null, null, null, null, null, null, null, null, '1', '1', '0', '公交子类型修改',11, null);

--++++++++++++++++++++++++++++++++++++++服务密码管理++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20502010, '服务密码重置', 'PERSON_SERVICEPWD', 'RESET', null, null, null, null, null, null, null, null, '1', '1', '0', '服务密码重置', 1, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20502020, '服务密码修改', 'PERSON_SERVICEPWD', 'MODIFY', null, null, null, null, null, null, null, null, '1', '1', '0', '服务密码修改', 2, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20502030, '交易密码重置', 'PERSON_TRADEPWD', 'RESET', null, null, null, null, null, null, null, null, '1', '1', '0', '交易密码重置', 3, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20502040, '交易密码修改', 'PERSON_TRADEPWD', 'MODIFY', null, null, null, null, null, null, null, null, '1', '1', '0', '交易密码修改', 4, null);

--++++++++++++++++++++++++++++++++++++++合作机构管理类+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (10301010, '合作机构新增', 'CO_ORG_MANAGER', 'ADD', null, null, null, null, null, null, null, null, '1', '1', '0', '合作机构新增', 1, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (10301020, '合作机构编辑', 'CO_ORG_MANAGER', 'EDIT', null, null, null, null, null, null, null, null, '1', '1', '0', '合作机构编辑', 2, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (10301030, '合作机构审核通过', 'CO_ORG_MANAGER', 'PASS', null, null, null, null, null, null, null, null, '1', '1', '0', '合作机构审核通过', 3, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (10301040, '合作机构审核不通过', 'CO_ORG_MANAGER', 'NOPASS', null, null, null, null, null, null, null, null, '1', '1', '0', '合作机构审核不通过', 4, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (10301050, '合作机构注销', 'CO_ORG_MANAGER', 'ZX', null, null, null, null, null, null, null, null, '1', '1', '0', '合作机构注销', 5, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (10301060, '合作机构启用', 'CO_ORG_MANAGER', 'QY', null, null, null, null, null, null, null, null, '1', '1', '0', '合作机构启用', 6, null);


--+++++++++++++++++++++++++++++++++++现金管理+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50801010, '柜员调剂', 'TELLER', 'SWAP', null, null, null, null, null, null, null, null, '1', '1', '0', '柜员调剂', 1, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50801020, '网点存款', 'BRANCH', 'DEPOSIT', null, null, null, null, null, null, null, null, '1', '1', '0', '网点存款', 2, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (50801030, '网点存款确认', 'BRANCH', 'DEPOSIT_CONFIRM', null, null, null, null, null, null, null, null, '1', '1', '0', '网点存款确认', 3, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (30101070, '换卡转钱包', 'REISSUE_CHG', 'TURN_PURSE', null, null, null, null, null, null, null, null, '1', '1', '0', '换卡转钱包', 0, null);
--++++++++++++++++++++++++++++++++++补换卡撤销+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501171, '补卡撤销', 'NAMEDCARD', 'REISSUE_UNDO', null, null, null, null, null, null, null, null, '1', '0', '0', '补卡撤销', 3, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20501181, '换卡撤销', 'NAMEDCARD', 'CHG_UNDO', null, null, null, null, null, null, null, null, '1', '0', '0', '换卡撤销', 0, null);

--柜面未登账户批量充值
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (30101100, '柜面批量充未登账户', 'REISSUE_CASH', 'WD', null, null, null, null, null, null, null, null, '1', '0', '0', '柜面批量充未登账户', 3, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (30101110, '柜面批量充未登账户删除', 'REISSUE_CASH_WD', 'DEL', null, null, null, null, null, null, null, null, '1', '0', '0', '柜面批量充未登账户删除', 0, null);
--嘉兴省社保卡申领、制卡完成
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20402050, '省社保申领制卡', 'APPLY_TYPE_SB', 'APPLYS', null, null, null, null, null, null, null, null, '1', '0', '0', '省社保申领制卡', 3, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20402060, '省社保制卡完成', 'APPLY_TYPE_SB', 'MKCARD', null, null, null, null, null, null, null, null, '1', '0', '0', '省社保制卡完成', 0, null);
insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20402051, '省社保取消制卡', 'APPLY_TYPE_SB', 'MKCARD', null, null, null, null, null, null, null, null, '1', '0', '0', '省社保制卡完成', 0, null);

insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20402070, '省社保补卡', 'APPLY_TYPE_SB_bk', 'MKCARD', null, null, null, null, null, null, null, null, '1', '0', '0', '省社保补卡', 0, null);

insert into SYS_CODE_TR 
(DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE)
values (20402080, '省社保换卡', 'APPLY_TYPE_SB-HK', 'MKCARD', null, null, null, null, null, null, null, null, '1', '0', '0', '省社保换卡', 0, null);
