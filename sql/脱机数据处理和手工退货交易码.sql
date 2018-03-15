prompt Importing table sys_code_tr...
set feedback off
set define off
insert into sys_code_tr (DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE, ROWID)
values (60801010, '手工退货登记', 'ADJUST_ONLINE_HANDLE', 'ADJUST_ONLINE_HANDLE_RETURN', null, null, null, null, null, null, null, null, '1', '1', '0', '手工退货登记', null, null, null);

insert into sys_code_tr (DEAL_CODE, DEAL_CODE_NAME, DEAL_CODE_TYPE, FIELD_NAME, NUM, NUM2, NUM3, AMT, AMT2, AMT3, AMT4, AMT5, BETWEEN_FLAG, IS_TOSUM, STATE, CODEDESC, ORD_NO, VOUCHER_TITLE, ROWID)
values (60901010, '脱机数据处理确认', 'OFFLINE_ADJUST', 'OFFLINE_ADJUST_CONFIRM', null, null, null, null, null, null, null, null, '1', '1', '0', '脱机数据处理确认', null, null, null);

prompt Done.
