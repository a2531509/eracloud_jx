create or replace package pk_interface_service is

  -- Author  : ADMINISTRATOR
  -- Created : 2016/7/15 9:20:16
  -- Purpose :

  /*=======================================================================================*/
  ---保存短信
  /*=======================================================================================*/
  PROCEDURE p_save_sms_message(av_dealcode IN INTEGER, --交易代码
                               av_dealno   IN NUMBER, --流水号
                               av_cardno   IN VARCHAR2, --卡号
                               av_tramt    IN  NUMBER, --交易金额
                               av_bef_bal  IN  NUMBER, --交易前金额
                               av_res      OUT VARCHAR2, --返回码 00 成功
                               av_msg      OUT VARCHAR2); --传出参数错误信息

end pk_interface_service;
/

