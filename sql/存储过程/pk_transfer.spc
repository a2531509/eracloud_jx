CREATE OR REPLACE PACKAGE pk_transfer IS
  -- Purpose : 转账
  /*=======================================================================================*/
  --转账
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --      5acpt_id        受理点编号(网点号或商户编号)
  --      6tr_batch_no    批次号
  --      7term_tr_no     终端交易流水号
  --      8card_no1       转出卡号
  --      9card_tr_count1 转出卡交易计数器
  --      10card_bal1     转出卡钱包交易前金额
  --      11acc_kind1     转出卡账户类型
  --      12wallet_id1    转出卡钱包编号 默认00
  --      13card_no2      转入卡号
  --      14card_tr_count2转入卡交易计数器
  --      15card_bal2     转入卡钱包交易前金额
  --      16acc_kind2     转入卡账户类型
  --      17wallet_id2    转入卡钱包编号 默认00
  --      18tr_amt        转账金额  null时转出所有金额
  --      19note          备注
  /*=======================================================================================*/
  PROCEDURE p_transfer(av_in    IN VARCHAR2, --传入参数
                       av_debug IN VARCHAR2, --1调试
                       av_res   OUT VARCHAR2, --传出代码
                       av_msg   OUT VARCHAR2 --传出错误信息
                       );
  /*=======================================================================================*/
  --转账确认
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no|6clr_date|7转出卡确认前卡账户金额明文|8转入卡确认前卡账户金额明文|9转出卡转账后金额密文|10转入卡转账后金额密文
  /*=======================================================================================*/
  PROCEDURE p_transferconfirm_onerow(av_in    IN VARCHAR2, --传入参数
                              av_debug IN VARCHAR2, --1写调试日志
                              av_res   OUT VARCHAR2, --传出代码
                              av_msg   OUT VARCHAR2 --传出错误信息
                              );
  /*=======================================================================================*/
  --转账确认
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5action_no|6clr_date|7card_no1|8card_no2
  /*=======================================================================================*/
  PROCEDURE p_transferconfirm(av_in    IN VARCHAR2, --传入参数
                              av_debug IN VARCHAR2, --1写调试日志
                              av_res   OUT VARCHAR2, --传出代码
                              av_msg   OUT VARCHAR2 --传出错误信息
                              );
  /*=======================================================================================*/
  --转账撤销
  --    如果原记录是灰记录，把记录改成充正状态，
  --                正常记录：新增一条负的灰记录，原记录改成撤销状态写撤销时间
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no        账户流水号
  --       6clr_date          写灰记录时的清分日期
  --       7acc_bal1         转出卡撤销前账户余额
  --       8acc_bal2         转入卡撤销前账户余额
  --       9card_tr_count1   转出卡卡交易计数器
  --      10card_tr_count2   转入卡卡交易计数器
  --      11card_bal1        转出卡钱包交易前金额
  --      12card_bal2        转入卡钱包交易前金额
  --      13encrypt1      转出卡转账后金额密文
  --      14encrypt2      转入卡转账后金额密文
  /*=======================================================================================*/
  PROCEDURE p_transfercancel_onerow(av_in    IN VARCHAR2, --传入参数
                                    av_debug IN VARCHAR2, --1写调试日志
                                    av_res   OUT VARCHAR2, --传出代码
                                    av_msg   OUT VARCHAR2 --传出错误信息
                                    );
  /*=======================================================================================*/
  --转账撤销
  --    如果原记录是灰记录，把记录改成充正状态，
  --                正常记录：新增一条负的灰记录，原记录改成撤销状态写撤销时间
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5action_no|6clr_date|7tr_state|8card_no1|9card_no2|
  --       10card_tr_count1|11card_tr_count2|12card_bal1|13card_bal2
  /*=======================================================================================*/
  PROCEDURE p_transfercancel(av_in    IN VARCHAR2, --传入参数
                             av_debug IN VARCHAR2, --1写调试日志
                             av_res   OUT VARCHAR2, --传出代码
                             av_msg   OUT VARCHAR2 --传出错误信息
                             );
END pk_transfer;
/

