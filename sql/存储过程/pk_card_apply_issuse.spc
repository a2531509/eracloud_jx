CREATE OR REPLACE PACKAGE PK_CARD_APPLY_ISSUSE IS

  /*=======================================================================================*/
  --个人发放
  /*=======================================================================================*/
  PROCEDURE P_ONECARD_ISSUSE(AS_CARD_NO         VARCHAR2, --卡号
                             AS_DEAL_NO         INTEGER, --中心交易流水号
                             AS_BANK_NO         VARCHAR2, --银行卡号
                             AS_STOCK_FLAG      VARCHAR2, --是否更新库房，0有，1没有
                             AS_SYNCH2CARDUPATE VARCHAR2, --是否同步到交换平台，0同步，1不同步
                             AS_ACPT_TYPE       VARCHAR2, --受理点类型-1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场 ---- 必埴
                             AV_RES             OUT VARCHAR2, --传出参数代码
                             AV_MSG             OUT VARCHAR2 --传出参数错误信息
                             );
  /*=======================================================================================*/
  --规模发放建卡分户账 （含扣除押金）
  /*=======================================================================================*/
  PROCEDURE P_BATCH_ISSUSE(AS_DEAL_CODE IN ACC_INOUT_DETAIL.DEAL_CODE%TYPE, --交易代码
                           AS_TASKID    IN CARD_APPLY.TASK_ID%TYPE, --任务号
                           AS_CARD_TYPE IN CARD_BASEINFO.CARD_TYPE%TYPE, --卡类型
                           AS_DEAL_NO   IN INTEGER, --业务流水号
                           AV_MSG       OUT VARCHAR2, --传出参数
                           AV_RES       OUT VARCHAR2);

  /*=======================================================================================*/
  --同步到社保 taskId,Bs_Person person,Cm_Card card,Cm_Card oldcard,Sys_Action_Log log,String applyType,long count
  /*=======================================================================================*/
  PROCEDURE P_SYNCH2CARD_UPATE(AS_TASKID    VARCHAR2, --卡号
                               AS_CERT_NO   varchar2, --中心交易流水号
                               AS_CARD_NO1  VARCHAR2, --是否更新库房，0有，1没有
                               AS_CARD_NO2  VARCHAR2, --是否同步到交换平台，0同步，1不同步
                               AS_DEAL_NO   INTEGER, --交易流水号
                               AS_APPLYTYPE VARCHAR2, --申领类型
                               AV_RES       OUT VARCHAR2, --传出参数代码
                               AV_MSG       OUT VARCHAR2 --传出参数错误信息
                               );

  /*=======================================================================================*/
  --插入任务明细
  /*=======================================================================================*/
  PROCEDURE P_INSERTCARDTASKLIST(AV_TASKID IN VARCHAR2, --任务号
                                 AV_DEBUG  IN VARCHAR2, --调试0是，1否
                                 AV_RES    OUT VARCHAR2, --传出参数代码
                                 AV_MSG    OUT VARCHAR2 --传出参数错误信息
                                 );
  -- Author  : hujc
  -- Created : 2015/7/3 14:39:11
  -- Purpose : 银川卡管理

  /*=======================================================================================*/
  --申请制卡
  --av_in: 1姓名
  --       2性别
  --       3证件类型
  --       4证件号码----必填
  --       5市民卡卡号-----必填
  --       6户籍所在城区
  --       7户籍所在乡镇（街道）
  --       8户籍所在村（社区）
  --       9居住地址
  --      10联系地址
  --      11邮政编码
  --      12固定电话
  --      13手机号码-----必填
  --      14电子邮件
  --      15单位客户名称
  --      16终端代码或网点，----必埴
  --      17银行(机构)代码,---必埴
  --      18柜员号-----必填
  --      19备注
  --      20卡类型
  --      21民族
  --      22户籍类型 0 本地 1 外地
  --      23工本费--金额单位：分
  --      24加急费--金额单位：分
  --      25代理人证件类型
  --      26代理人证件号码
  --      27代理人姓名
  --      28代理人联系电话
  --      29受理点类型-1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场 ---- 必埴
  --      30终端交易流水号--必填
  -- av_out：1持卡人姓名
  --         2持卡人性别
  --         3持卡人证件类型
  --         4持卡人证件号码
  --         5卡主类型 01
  --         6卡子类型 00
  --         7卡有效日期
  --         8启用标志
  --         9公共钱包应用启动日期
  --         10公共钱包应用有效日期

  /*=======================================================================================*/
  PROCEDURE P_APPLYCARD(AV_IN    IN VARCHAR2, --传入参数
                        AV_DEBUG IN VARCHAR2, --1调试
                        AV_OUT   OUT VARCHAR2, --返回信息
                        AV_RES   OUT VARCHAR2, --传出代码
                        AV_MSG   OUT VARCHAR2 --传出错误信息
                        );

  PROCEDURE P_PERSONAL_APPLY(AV_IN    IN VARCHAR2, --传入参数
                             AV_DEBUG IN VARCHAR2, --1调试
                             AV_OUT   OUT VARCHAR2, --返回信息
                             AV_RES   OUT VARCHAR2, --传出代码
                             AV_MSG   OUT VARCHAR2 --传出错误信息
                             );

  /*=======================================================================================*/
  --开发放
  --av_in: 1卡号
  --       2证件类型
  --       3证件号码
  --       4姓名
  --       5开户银行
  --       6卫生卡号
  --       7卡类型
  --       8受卡方的标识码
  --       9柜员号
  --       10备注
  --       11 是否有老卡 0 是 1 否
  --       12 老卡卡号
  /*=======================================================================================*/
  PROCEDURE P_OPENACCANDCARD(AV_IN    IN VARCHAR2, --传入参数
                             AV_DEBUG IN VARCHAR2, --1调试
                             AV_RES   OUT VARCHAR2, --传出代码
                             AV_MSG   OUT VARCHAR2 --传出错误信息
                             );

  PROCEDURE P_SMZ_KFF(AV_IN  VARCHAR2, --参数信息
                      AV_RES OUT VARCHAR2, --传出参数代码
                      AV_MSG OUT VARCHAR2, --传出参数错误信息
                      AV_OUT OUT VARCHAR2);

  --判断受理点类型
  --av_acpt_id 受理点编号
  --av_acpt_type受理点类型
  --av_oper_id 操作员编号
  --av_sys_users 操作员信息
  --av_base_co_org 合作机构信息
  --av_res 处理结果代码
  --av_msg 处理结果说明
  PROCEDURE P_JUDGE_ACPT(AV_ACPT_ID     VARCHAR2,
                         AV_ACPT_TYPE   VARCHAR2,
                         AV_OPER_ID     VARCHAR2,
                         AV_SYS_USERS   OUT SYS_USERS%ROWTYPE,
                         AV_BASE_CO_ORG OUT BASE_CO_ORG%ROWTYPE,
                         AV_RES         OUT VARCHAR2,
                         AV_MSG         OUT VARCHAR2);

  PROCEDURE P_BATCH_KFF(AV_IN  IN VARCHAR2,
                        AV_RES OUT VARCHAR2,
                        AV_MSG OUT VARCHAR2);

  PROCEDURE P_UNDO_SMZ_KFF(AV_IN  VARCHAR2,
                           AV_RES OUT VARCHAR2,
                           AV_MSG OUT VARCHAR2,
                           AV_OUT OUT VARCHAR2);

  PROCEDURE P_GETCARDAPPLYBYCARDNO(AV_CARD_NO    CARD_APPLY.CARD_NO%TYPE,
                                   AV_CARD_APPLY OUT CARD_APPLY%ROWTYPE,
                                   AV_RES        OUT VARCHAR2,
                                   AV_MSG        OUT VARCHAR2);
  --根据卡号获取卡信息
  PROCEDURE P_GET_CARD_BASEINFO(
                                AV_CARD_NO CARD_BASEINFO.CARD_NO%TYPE,
                                AV_CARD_BASEINFO OUT CARD_BASEINFO%ROWTYPE,
                                AV_RES OUT VARCHAR2,
                                AV_MSG OUT VARCHAR2
                               );

  --根据证件号码获取人员信息
  --av_cert_no 客户编号
  --av_base_personal 人员信息
  --av_res 处理结果代码
  --av_msg 处理结果说明
  PROCEDURE P_GET_BASE_PERSONAL(AV_CERT_NO   BASE_PERSONAL.CERT_NO%TYPE,
                                AV_BASE_PERSONAL OUT BASE_PERSONAL%ROWTYPE,
                                AV_RES           OUT VARCHAR2,
                                AV_MSG           OUT VARCHAR2);

  --获取绑定银行卡信息
  PROCEDURE P_GET_BIND_BANKCARD(AV_CARD_NO CARD_BASEINFO.SUB_CARD_NO%TYPE,
                                AV_CARD_BIND_BANKCARD OUT CARD_BIND_BANKCARD%ROWTYPE,
                                AV_RES           OUT VARCHAR2,
                                AV_MSG           OUT VARCHAR2);
  --根据客户编号获取人员信息
  --av_customer_id 客户编号
  --av_base_personal 人员信息
  --av_res 处理结果代码
  --av_msg 处理结果说明
  PROCEDURE P_GETBASEPERSONALBYCUSTOMERID(AV_CUSTOMER_ID   BASE_PERSONAL.CUSTOMER_ID%TYPE,
                                          AV_BASE_PERSONAL OUT BASE_PERSONAL%ROWTYPE,
                                          AV_RES           OUT VARCHAR2,
                                          AV_MSG           OUT VARCHAR2);

  --根据卡类型获取卡参数配置信息
  --av_card_type 卡累心
  --av_card_config 卡参数配置信息
  --av_res 处理结果代码
  --av_msg 处理结果说明
  PROCEDURE P_GETCARDCONFIGBYCARDTYPE(AV_CARD_TYPE   CARD_CONFIG.CARD_TYPE%TYPE,
                                      AV_CARD_CONFIG OUT CARD_CONFIG%ROWTYPE,
                                      AV_RES         OUT VARCHAR2,
                                      AV_MSG         OUT VARCHAR2);

  PROCEDURE P_APPLY_BANK_SH(AV_IN  VARCHAR2,
                            AV_RES OUT VARCHAR2,
                            AV_MSG OUT VARCHAR2);

  --申领撤销
  --av_in
  --1.受理点编号
  --2.受理点类型
  --3.操作员
  --4.操作流水
  --5.申领单号
  --6.代理人证件类型
  --7.代理人证件号码
  --8.代理人姓名
  --9.代理人电话
  --10.备注
  PROCEDURE p_Apply_Cancel(av_in VARCHAR2,av_res OUT VARCHAR2,av_msg OUT VARCHAR2,av_out OUT VARCHAR2);
   --卡片回收
  --1.受理点编号
  --2.受理点类型
  --3.操作员
  --4.操作流水
  --5.卡号
  --6.盒号
  --7.顺序号  可空
  --8.是否转库存
  --9.备注
  procedure p_card_recovery(av_in varchar2,av_res out varchar2,av_msg out varchar2,av_out out varchar2);
END PK_CARD_APPLY_ISSUSE;
/

