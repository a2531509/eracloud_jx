prompt Importing table SYS_CODE...
set feedback off
set define off
insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CARD_TYPE_BANKSTRIPE', '磁条类型', '0', '银行卡', '0', 1, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CARD_TYPE_BANKSTRIPE', '磁条类型', '1', '非银行卡', '0', 2, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CARD_TYPE_MEDIA', '介质类型', '3', 'NFC卡', '0', 3, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CARD_TYPE_MEDIA', '介质类型', '5', 'simall卡', '0', 5, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CARD_TYPE_MEDIA', '介质类型', '1', '普通卡', '0', 1, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CARD_TYPE_MEDIA', '介质类型', '4', '贴面卡', '0', 4, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CARD_TYPE_MEDIA', '介质类型', '2', '异形卡', '0', 2, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CARD_TYPE_STATE', '卡片状态', '0', '使用中', '0', 1, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CARD_TYPE_STATE', '卡片状态', '1', '已注销', '0', 2, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('PROVIODER_STATE', '供应商状态', '0', '正常', '0', 1, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('PROVIODER_STATE', '供应商状态', '1', '注销', '0', 2, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('PROVIODER_TYPE', '供应商类型', '1', 'POS机具供应商', '0', 1, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('PROVIODER_TYPE', '供应商类型', '2', '读写卡机具供应商', '0', 2, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('PROVIODER_TYPE', '供应商类型', '3', '3PSAM卡供应商', '0', 3, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CHIP_TYPE', '芯片类型', '1', '单接触式CPU卡', '0', 1, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CHIP_TYPE', '芯片类型', '2', '单非接触式CPU卡', '0', 2, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CHIP_TYPE', '芯片类型', '3', '接触非接CPU卡', '0', 3, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CHIP_TYPE', '芯片类型', '4', '双界面卡', '0', 4, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CHIP_TYPE', '芯片类型', '5', '单接触逻辑卡', '0', 5, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CHIP_TYPE', '芯片类型', '6', '单非接M1卡', '0', 6, null);

insert into SYS_CODE (CODE_TYPE, TYPE_NAME, CODE_VALUE, CODE_NAME, CODE_STATE, ORD_NO, FIELD_NAME)
values ('CHIP_TYPE', '芯片类型', '7', '充值卡', '0', 7, null);

prompt Done.
