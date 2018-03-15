prompt Importing table sys_code...
set feedback off
set define off
insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BASE_END_STATE', '终端状态', '0', '未启用', '0', 1, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BASE_END_STATE', '终端状态', '1', '启用', '0', 2, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BASE_END_STATE', '终端状态', '2', '维修', '0', 3, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BASE_END_STATE', '终端状态', '3', '报废', '0', 4, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BASE_END_STATE', '终端状态', '4', '出库', '0', 5, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BASE_END_STATE', '终端状态', '5', '回收', '0', 6, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('BASE_END_STATE', '终端状态', '9', '注销', '0', 7, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('OUT_GOODS_STATE', '货款状态', '1', '已开具发票，款已付清', '0', 1, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('OUT_GOODS_STATE', '货款状态', '2', '已开具发票，款未付清', '0', 2, null);

insert into sys_code (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('OUT_GOODS_STATE', '货款状态', '3', '未开具发票，未付款', '0', 3, null);


prompt Done.
