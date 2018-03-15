CREATE OR REPLACE PACKAGE pk_merchantsettle IS

  -- Purpose : 商户结算
  /*=======================================================================================*/
  --对一商户进行结算
  /*=======================================================================================*/
  PROCEDURE p_settle(av_bizid  IN base_merchant.merchant_id%TYPE, --商户号
                     av_operid IN sys_users.user_id%TYPE, --结算柜员
                     av_res    OUT VARCHAR2, --传出代码
                     av_msg    OUT VARCHAR2 --传出错误信息
                     );
  /*=======================================================================================*/
  --对所有商户进行结算
  /*=======================================================================================*/
  PROCEDURE p_settle(av_operid IN sys_users.user_id%TYPE, --结算柜员
                     av_res    OUT VARCHAR2, --传出代码
                     av_msg    OUT VARCHAR2 --传出错误信息
                     );
  /*=======================================================================================*/
  --对一商户进行即时结算
  /*=======================================================================================*/
  PROCEDURE p_settle_immediate(av_bizid  IN base_merchant.merchant_id%TYPE, --商户号
                               av_operid IN sys_users.user_id%TYPE, --结算柜员
                               av_res    OUT VARCHAR2, --传出代码
                               av_msg    OUT VARCHAR2 --传出错误信息
                               );
  /*=======================================================================================*/
  --对所有商户进行结算的job
  /*=======================================================================================*/
  PROCEDURE p_job;
  /*=======================================================================================*/
  --商户结算回退
  /*=======================================================================================*/
  PROCEDURE p_settlerollback(av_stlsumno IN stl_deal_sum.stl_sum_no%TYPE, --商户结算汇总序号
                             av_res      OUT VARCHAR2, --传出代码
                             av_msg      OUT VARCHAR2 --传出错误信息
                             );
  /*=======================================================================================*/
  --商户结算支付
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|5stlsumnos|6NOTE
  --stlsumnos：STL_SUM_NO$CARD_TYPE$ACC_KIND,STL_SUM_NO$CARD_TYPE$ACC_KIND
  /*=======================================================================================*/
  PROCEDURE p_settlepay(av_in    IN VARCHAR2, --传入参数
                        av_debug IN VARCHAR2, --1调试
                        av_res   OUT VARCHAR2, --传出代码
                        av_msg   OUT VARCHAR2 --传出错误信息
                        );
END pk_merchantsettle;
/

