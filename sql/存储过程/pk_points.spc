CREATE OR REPLACE PACKAGE pk_points IS
  -- Purpose : 积分
  /*=======================================================================================*/
  --积分兑换
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --      5acpt_id        受理点编号(网点号或商户编号)
  --      6tr_batch_no    批次号
  --      7term_tr_no     终端交易流水号
  --      8card_no        卡号
  --      9tr_amt         兑换的积分数
  --      10type          兑换类型 1兑换到未圈存账户2兑换礼品3积分到期扣减
  --      11note          备注
  /*=======================================================================================*/
  PROCEDURE p_exchange(av_in    IN VARCHAR2, --传入参数
                       av_debug IN VARCHAR2, --1调试
                       av_res   OUT VARCHAR2, --传出代码
                       av_msg   OUT VARCHAR2, --传出错误信息
                       av_out   OUT VARCHAR2 --传出参数
                       );
  /*=======================================================================================*/
  --积分兑换撤销
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no 原记录的action_no
  --       6clr_date  原记录的清分日期
  --       7card_no   卡号
  --       8encrypt   撤销后未圈存账户金额密文
  /*=======================================================================================*/
  PROCEDURE p_exchangecancel(av_in    IN VARCHAR2, --传入参数
                             av_debug IN VARCHAR2, --1调试
                             av_res   OUT VARCHAR2, --传出代码
                             av_msg   OUT VARCHAR2, --传出错误信息
                             av_out   OUT VARCHAR2 --传出参数
                             );
  /*=======================================================================================*/
  --积分生成
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --       5acpt_id        受理点编号(网点号或商户编号)
  --       6tr_batch_no    批次号
  --       7term_tr_no     终端交易流水号
  --       8card_no        卡号
  --       9tr_amt         增加的积分数
  --      10type           积分增加的途径
  --      11note           备注
  /*=======================================================================================*/
  PROCEDURE p_generate(av_in    IN VARCHAR2, --传入参数
                       av_debug IN VARCHAR2, --1调试
                       av_res   OUT VARCHAR2, --传出代码
                       av_msg   OUT VARCHAR2, --传出错误信息
                       av_out   OUT VARCHAR2 --传出参数
                       );
  /*=======================================================================================*/
  --根据清分日期取记期周期和失效日期
  /*=======================================================================================*/
  PROCEDURE p_getpointsperiod(av_clrdate      IN VARCHAR2, --清分日期
                              av_period_name  OUT VARCHAR2, --计期说明，如2014-01-01(天)、2014-01(月)、2014(年)
                              av_invalid_date OUT VARCHAR2, --积分失效日期
                              av_res          OUT VARCHAR2, --传出代码
                              av_msg          OUT VARCHAR2 --传出错误信息
                              );
  /*=======================================================================================*/
  --积分生成
  /*=======================================================================================*/
  PROCEDURE p_generate(av_dbsubledger IN acc_account_sub%ROWTYPE, --积分借方分户账
                       av_cardno      IN VARCHAR2, --卡号
                       av_amt         IN NUMBER, --积分
                       av_trcode      IN VARCHAR2, --交易代码
                       av_orgid       IN VARCHAR2, --受理点机构号
                       av_brchid      IN VARCHAR2, --受理点编码(网点号/商户号等)
                       av_operid      IN VARCHAR2, --操作柜员/终端号
                       av_trbatchno   IN VARCHAR2, --交易批次号
                       av_termtrno    IN VARCHAR2, --终端交易流水号
                       av_actionno    IN NUMBER, --业务流水号
                       av_note        IN VARCHAR2, --备注
                       av_clrdate     IN VARCHAR2, --清分日期
                       av_debug       IN VARCHAR2, --1调试
                       av_res         OUT VARCHAR2, --传出代码
                       av_msg         OUT VARCHAR2 --传出错误信息
                       );
  /*=======================================================================================*/
  --撤销积分生成 (只更新积分构成表，账户在流水撤销中统一处理)
  /*=======================================================================================*/
  PROCEDURE p_generatecancel(av_cardno  IN VARCHAR2, --卡号
                             av_amt     IN NUMBER, --积分
                             av_clrdate IN VARCHAR2, --清分日期
                             av_res     OUT VARCHAR2, --传出代码
                             av_msg     OUT VARCHAR2 --传出错误信息
                             );
END pk_points;
/

