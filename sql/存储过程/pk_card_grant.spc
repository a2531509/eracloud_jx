create or replace package PK_CARD_GRANT is

  -- Author  : ADMINISTRATOR
  -- Created : 2015/8/7 15:28:23
  -- Purpose :


  /*=======================================================================================*/
  --卡发放（目前只支持A卡）
  /*=======================================================================================*/
  PROCEDURE card_grand(av_in  IN VARCHAR2, --传入参数
                      av_action_no  OUT VARCHAR2,--传出参数返回业务流水号
                      av_res OUT VARCHAR2, --传出参数代码
                      av_msg OUT VARCHAR2 --传出参数错误信息
                      );
end PK_CARD_GRANT;
/

