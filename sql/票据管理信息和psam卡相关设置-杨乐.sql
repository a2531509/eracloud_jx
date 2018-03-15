prompt Importing table sys_code...
set feedback off
set define off
insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BILL_TYPE', '票据类型', '1', '银行汇票', '0', 1, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BILL_TYPE', '票据类型', '2', '商业汇票', '0', 2, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BILL_TYPE', '票据类型', '3', '商业本票', '0', 3, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BILL_TYPE', '票据类型', '4', '银行本票', '0', 4, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BILL_TYPE', '票据类型', '5', '记名支票', '0', 5, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BILL_TYPE', '票据类型', '6', '不记名支票', '0', 6, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BILL_TYPE', '票据类型', '7', '划线支票', '0', 7, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BILL_TYPE', '票据类型', '8', '现金支票', '0', 8, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BILL_TYPE', '票据类型', '9', '转帐支票', '0', 9, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('PSAM_STATE', 'psam状态', '0', '正常', '0', 0, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('PSAM_STATE', 'psam状态', '1', '已注销', '0', 1, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('PSAM_STATE', 'psam状态', '2', '已领用', '0', 2, null);
prompt Done.
