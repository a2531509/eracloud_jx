CREATE OR REPLACE PACKAGE pk_consume_ghk IS
  -- Purpose : 消费

  /*=======================================================================================*/
  --联机消费_判断卡号是否准许消费

  --merchantid IN VARCHAR2,--商户编号
  --cardno     IN VARCHAR2,--卡号
  --sqn_mode   IN varchar2,--商户消费模式merchantid      商户号

  /*=======================================================================================*/

  PROCEDURE p_checkIDinfo(merchantid IN VARCHAR2,--商户编号
                          cardno     IN VARCHAR2,--卡号
                          sqn_mode   IN VARCHAR2,--商户消费模式
                          av_sqn_mode OUT pay_acctype_sqn%ROWTYPE,--传出消费模式
                          av_res      OUT VARCHAR2, --传出代码
                          av_msg      OUT VARCHAR2 --传出错误信息
    );
  /*=======================================================================================*/
  --联机消费_计算
  --av_in: 各字段以|分割
  --       1tr_code    交易代码
  --       2card_no    卡号
  --       3tr_amt     消费金额
  --       4mode_no    消费模式
  --av_out: 账户列表acclist
  --      acclist      账户列表 acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsume_calc(av_in  IN VARCHAR2, --传入参数
                                 av_res OUT VARCHAR2, --传出代码
                                 av_msg OUT VARCHAR2, --传出错误信息
                                 av_out OUT VARCHAR2, --传出参数
                                 av_cash_amt OUT VARCHAR2--现金付款金额
                                 );
  /*=======================================================================================*/
  --联机消费
  --av_in: 各字段以|分割
  --       1action_no    业务流水号--空的话取存储过程中取序列
  --       2tr_code      交易码
  --       3oper_id      操作员/终端号
  --       4oper_time    操作时间--空的话取存储过程中取数据库时间
  --       5acpt_id      受理点编号(网点号或商户编号)
  --       6tr_batch_no  批次号
  --       7term_tr_no   终端交易流水号
  --       8card_no      卡号
  --       9pwd          密码
  --      10tr_amt       总交易金额
  --      11acclist      账户列表 acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      12note         备注
  --      13acpt_type    受理点分类
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsume(av_in    IN VARCHAR2, --传入参数
                            av_debug IN VARCHAR2, --1调试
                            av_res   OUT VARCHAR2, --传出代码
                            av_msg   OUT VARCHAR2, --传出错误信息
                            av_out   OUT VARCHAR2 --传出参数
                            );
  /*=======================================================================================*/
  --联机消费充正_计算
  --av_in: 各字段以|分割
  --       1acpt_id      受理点编号(网点号或商户编号)
  --       2oper_id      操作员/终端号
  --       3tr_batch_no  批次号
  --       4term_tr_no   终端交易流水号
  --       5card_no      卡号
  --av_out: 原消费action_no|原消费clr_date|账户列表acclist
  --      acclist      账户列表 acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumecancel_calc(av_in  IN VARCHAR2, --传入参数
                                       av_res OUT VARCHAR2, --传出代码
                                       av_msg OUT VARCHAR2, --传出错误信息
                                       av_out OUT VARCHAR2 --传出参数
                                       );
  /*=======================================================================================*/
  --联机消费撤销_计算
  --av_in: 各字段以|分割
  --       1acpt_id      受理点编号(网点号或商户编号)
  --       2oper_id      操作员/终端号
  --       3tr_batch_no  批次号
  --       4action_no   终端交易流水号
  --       5camt      卡号
  --av_out: 原消费action_no|原消费clr_date|账户列表acclist
  --      acclist      账户列表 acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumeundo_calc(av_in  IN VARCHAR2, --传入参数
                                       av_res OUT VARCHAR2, --传出代码
                                       av_msg OUT VARCHAR2, --传出错误信息
                                       av_out OUT VARCHAR2 --传出参数
                                       );
  /*=======================================================================================*/
  --联机消费充正
  --av_in: 各字段以|分割
  --       1action_no    业务流水号
  --       2tr_code      交易码
  --       3oper_id      操作员/终端号
  --       4oper_time    操作时间
  --       5acpt_id      受理点编号(网点号或商户编号)
  --       6tr_batch_no  批次号
  --       7term_tr_no   终端交易流水号
  --       8card_no      卡号
  --      10tr_amt       总交易金额
  --      11acclist      账户列表 acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      12action_no    被充正的action_no
  --      13clr_date     被充正记录的clr_date
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumecancel(av_in    IN VARCHAR2, --传入参数
                                  av_debug IN VARCHAR2, --1调试
                                  av_res   OUT VARCHAR2, --传出代码
                                  av_msg   OUT VARCHAR2, --传出错误信息
                                  av_out   OUT VARCHAR2 --传出参数
                                  );

  procedure p_uniondkdskqrorcancel(av_db_acc_no        in varchar2, --借方账户
                       av_cr_acc_no        in varchar2, --贷方账户
                       av_dbcardbal        number, --借方交易前卡面金额
                       av_crcardbal        number, --贷方交易前卡面金额
                       av_dbcardcounter    NUMBER, --借方卡片交易计数器
                       av_crcardcounter    NUMBER, --贷方卡片交易计数器
                       av_dbbalanceencrypt IN VARCHAR2, --借方金额密文
                       av_crbalanceencrypt IN VARCHAR2, --贷方金额密文
                       av_tramt            acc_inout_detail.db_amt%TYPE, --交易金额
                       av_credit           acc_inout_detail.db_credit_amt%TYPE, --信用发生额
                       av_accbookno        acc_inout_detail.acc_inout_no%TYPE, --记账流水号
                       av_trcode           acc_inout_detail.deal_code%TYPE, --交易代码
                       av_issueorgid       acc_inout_detail.card_org_id%TYPE, --发卡机构
                       av_orgid            acc_inout_detail.acpt_org_id%TYPE, --受理机构
                       av_acpttype         acc_inout_detail.acpt_type%TYPE, --受理点分类
                       av_acptid           acc_inout_detail.acpt_id%TYPE, --受理点编码(网点号/商户号等)
                       av_operid           acc_inout_detail.user_id%TYPE, --操作柜员/终端号
                       av_trbatchno        acc_inout_detail.deal_batch_no%TYPE, --交易批次号
                       av_termtrno         acc_inout_detail.end_deal_no%TYPE, --终端交易流水号
                       av_trdate_str       varchar2, --交易时间
                       av_trstate          acc_inout_detail.deal_state%TYPE, --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                       av_actionno         acc_inout_detail.deal_no%TYPE, --业务流水号
                       av_note             acc_inout_detail.note%TYPE, --备注
                       av_clrdate          pay_clr_para.clr_date%TYPE, --清分日期
                       av_otherin          VARCHAR2 DEFAULT NULL, --其它传入参数 退货时传入原acc_book_no
                       av_debug            IN VARCHAR2, --1调试
                       av_res              OUT VARCHAR2, --传出参数代码
                       av_msg              OUT VARCHAR2 --传出参数错误信息
                       );


END pk_consume_ghk;
/

