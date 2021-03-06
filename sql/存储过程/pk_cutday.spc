CREATE OR REPLACE PACKAGE pk_cutday IS
  -- Purpose : 日切
  --  1、脱机数据处理   处理数据，不更改控制表状态
  --  2、关闭账户  ACC_SWITCH       = '0',BATCH_PROC_STATE = '2'
  --  3、总分核对  ACC_SWITCH       = '0',BATCH_PROC_STATE = '3'
  --  4、打开账户  ACC_SWITCH       = '1',BATCH_PROC_STATE = '4'
  --  5、日初始化  ACC_SWITCH       = '1',BATCH_PROC_STATE = '5'
  --  6、批处理         处理数据，不更改控制表状态
  /*=======================================================================================*/
  --2日切--更改清分日期
  /*=======================================================================================*/
  PROCEDURE p_closeacc(av_res OUT VARCHAR2, --传出代码
                       av_msg OUT VARCHAR2 --传出错误信息
                       );
  /*=======================================================================================*/
  --3总分核对 写总账表
  /*=======================================================================================*/
  PROCEDURE p_checkbalance(av_clrdate VARCHAR2, --清分日期
                           av_res     OUT VARCHAR2, --传出代码
                           av_msg     OUT VARCHAR2 --传出错误信息
                           );
  /*=======================================================================================*/
  --4打开账户
  /*=======================================================================================*/
  PROCEDURE p_openacc(av_res OUT VARCHAR2, --传出代码
                      av_msg OUT VARCHAR2 --传出错误信息
                      );
  /*=======================================================================================*/
  --5日初始化
  /*=======================================================================================*/
  PROCEDURE p_datebegin(av_res OUT VARCHAR2, --传出代码
                        av_msg OUT VARCHAR2 --传出错误信息
                        );
  /*=======================================================================================*/
  --6批处理
  /*=======================================================================================*/
  PROCEDURE p_batchdeal(av_clrdate VARCHAR2, --清分日期
                        av_res     OUT VARCHAR2, --传出代码
                        av_msg     OUT VARCHAR2 --传出错误信息
                        );
  /*=======================================================================================*/
  --清分
  /*=======================================================================================*/
  PROCEDURE p_clr(av_bizid   VARCHAR2, --商户号
                  av_clrdate VARCHAR2, --清分日期
                  av_res     OUT VARCHAR2, --传出代码
                  av_msg     OUT VARCHAR2 --传出错误信息
                  );
  /*=======================================================================================*/
  --合作机构清分
  /*=======================================================================================*/
  PROCEDURE p_co_clr(av_co_org_id   VARCHAR2, -- 合作机构号
                  av_clrdate VARCHAR2, --清分日期
                  av_res     OUT VARCHAR2, --传出代码
                  av_msg     OUT VARCHAR2 --传出错误信息
                  );
  /*=============p_job==========================================================================*/
  --日切job
  /*=======================================================================================*/
  PROCEDURE p_job;
  PROCEDURE p_test;
END pk_cutday;
/

