CREATE OR REPLACE PACKAGE pk_recharge IS
  -- Purpose : 充值
  /*
  信用
    acc_sub_ledger 增加字段 credit 表示信用额度 信用支出least(credit,greatest(0,credit-balance))
    acc_daybook    增加字段 db_credit,cr_credit,card_credit
    tr_card        增加字段credit,card_credit
    分户账余额0  信用额度0
    1、充值100   分户账balance 100 credit 0
                 流水 db_amt 100 credit 0
    2、信用额度变成200 分户账balance 300 db_credit 200
                       流水  db_amt 200  db_credit 200
    3、消费50    分户账balance250 credit 200
                 流水  db_amt 50  db_credit 0
    4、消费200   分户账balance50  credit 200
                 流水  db_amt 200 db_credit 150
    5、充值300   分户账balance350 credit 200
                 流水  db_amt 300 db_credit 150
    6、信用额度变成300 分户账 450  credit 300
                       流水db_amt 300 db_credit 100
    6、信用额度变成100 分户账 250  credit 100
                       流水db_amt -100 db_credit -200

  */

  /*=======================================================================================*/
  --充值写灰记录
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5acpt_id      受理点编号(网点号或商户编号)
  --       6tr_batch_no  批次号
  --       7term_tr_no   终端交易流水号
  --       8card_no      卡号
  --       9card_tr_count卡交易计数器
  --      10card_bal     钱包交易前金额
  --      11acc_kind     账户类型
  --      12wallet_id    钱包编号 默认00
  --      13tr_amt       充值金额(更改信用额度时传入更改后的信用额度)
  --      14pay_source   充值资金来源0现金1转账2充值卡3促销4更改信用额度5网点预存款
  --      15sourcecard   充值卡卡号或银行卡卡号
  --      16rechg_pwd    充值卡密码
  --      17note         备注
  --      18tr_state     9写灰记录0直接写正常记录
  --      19encrypt      充值后卡账户金额密文
  /*=======================================================================================*/
  PROCEDURE p_recharge(av_in    IN VARCHAR2, --传入参数
                       av_debug IN VARCHAR2, --1写调试日志
                       av_res   OUT VARCHAR2, --传出代码
                       av_msg   OUT VARCHAR2 --传出错误信息
                       );
  /*=======================================================================================*/
  --充值确认
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no|6clr_date|7encrypt确认后卡账户金额密文|8确认前卡账户金额明文
  /*=======================================================================================*/
  PROCEDURE p_rechargeconfirm_onerow(av_in    IN VARCHAR2, --传入参数
                                     av_debug IN VARCHAR2, --1写调试日志
                                     av_res   OUT VARCHAR2, --传出代码
                                     av_msg   OUT VARCHAR2 --传出错误信息
                                     );
  /*=======================================================================================*/
  --充值确认
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5action_no|6clr_date|7card_no|8确认后卡账户金额密文
  /*=======================================================================================*/
  PROCEDURE p_rechargeconfirm(av_in    IN VARCHAR2, --传入参数
                              av_debug IN VARCHAR2, --1写调试日志
                              av_res   OUT VARCHAR2, --传出代码
                              av_msg   OUT VARCHAR2 --传出错误信息
                              );
  /*=======================================================================================*/
  --充值撤销
  --    如果原记录是灰记录，把记录改成充正状态，
  --                正常记录：新增一条负的灰记录，原记录改成撤销状态写撤销时间
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no|6clr_date|7card_tr_count|8card_bal|9撤销后卡账户金额密文|10撤销前卡账户余额
  /*=======================================================================================*/
  PROCEDURE p_rechargecancel_onerow(av_in    IN VARCHAR2, --传入参数
                                    av_debug IN VARCHAR2, --1写调试日志
                                    av_res   OUT VARCHAR2, --传出代码
                                    av_msg   OUT VARCHAR2 --传出错误信息
                                    );
  /*=======================================================================================*/
  --充值撤销
  --    如果原记录是灰记录，把记录改成充正状态，
  --                正常记录：新增一条负的灰记录，原记录改成撤销状态写撤销时间
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5action_no|6clr_date|7card_no|8tr_state|9card_tr_count|10card_bal|11撤销后卡账户金额密文
  /*=======================================================================================*/
  PROCEDURE p_rechargecancel(av_in    IN VARCHAR2, --传入参数
                             av_debug IN VARCHAR2, --1写调试日志
                             av_res   OUT VARCHAR2, --传出代码
                             av_msg   OUT VARCHAR2 --传出错误信息
                             );
  /*=======================================================================================*/
  --充值冲正记录改成灰记录状态
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no  原充值记录的业务流水号
  /*=======================================================================================*/
  PROCEDURE p_rechargecancel2ash(av_in    IN VARCHAR2, --传入参数
                                 av_debug IN VARCHAR2, --1写调试日志
                                 av_res   OUT VARCHAR2, --传出代码
                                 av_msg   OUT VARCHAR2 --传出错误信息
                                 );
  /*=======================================================================================*/
  --账户返现
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5acpt_id|6tr_batch_no|7term_tr_no|8card_no|9card_tr_count|10card_bal|11acc_kind|12wallet_id|13tr_amt|
  --       14note|15返现后金额密文
  /*=======================================================================================*/
  PROCEDURE p_returncash(av_in    IN VARCHAR2, --传入参数
                         av_debug IN VARCHAR2, --1调试
                         av_res   OUT VARCHAR2, --传出代码
                         av_msg   OUT VARCHAR2 --传出错误信息
                         );
  /*=======================================================================================*/
  --充值到网点预存款
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5acpt_id      网点号  预存款的网点
  --       6tr_batch_no  批次号
  --       7term_tr_no   终端交易流水号
  --       8tr_amt       充值金额(更改信用额度时传入更改后的信用额度)
  --       9pay_source   充值资金来源0现金1转账4更改信用额度
  --      10note         备注
  --      11tr_state     9写灰记录0直接写正常记录
  /*=======================================================================================*/
  PROCEDURE p_recharge2brch(av_in    IN VARCHAR2, --传入参数
                            av_debug IN VARCHAR2, --1调试
                            av_res   OUT VARCHAR2, --传出代码
                            av_msg   OUT VARCHAR2 --传出错误信息
                            );
END pk_recharge;
/

