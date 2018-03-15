CREATE OR REPLACE PACKAGE pk_statistic IS
  -- Purpose : 统计

  /*=======================================================================================*/
  --根据轧账基础表tr_day_bal_base，再统计到轧账数据表中tr_day_bal_data
  /*=======================================================================================*/
  PROCEDURE p_daybal_data(av_clrdate        varchar2, --清分日期
                          av_daybal_type    IN varchar2, --1柜员，2网点，3机构
                          av_daybal_ownerid IN VARCHAR2, --轧账主体编号
                          av_actionno       in number, --业务流水号
                          av_debug          IN VARCHAR2, --1调试
                          av_res            OUT VARCHAR2, --传出参数代码
                          av_msg            OUT VARCHAR2 --传出参数错误信息
                          );
  /*=======================================================================================*/
  --轧账 汇总数据到 tr_day_bal_base，最后再汇总到tr_day_bal_data表中
  --  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --           5clr_date|6daybal_type|7daybal_owner_id
  --daybal_type:1个人，2网点(先个人再网点)，3机构(日切后触发，用于生成营业报表的基础数据)
  /*=======================================================================================*/
  PROCEDURE p_daybal(av_in    IN VARCHAR2, --传入参数
                     av_debug IN VARCHAR2, --1调试
                     av_res   OUT VARCHAR2, --传出参数代码
                     av_msg   OUT VARCHAR2 --传出参数错误信息
                     );
  /*=======================================================================================*/
  --按起止时间批量生成轧账基础数据表tr_day_bal_base
  --as_orgid，生成指定机构（或所有机构[as_org为空时]）、网点、柜员数据
  /*=======================================================================================*/
  PROCEDURE p_batch_daybal(as_start_date varchar2, --开始日期yyyy-mm-dd，为空默认为当天
                           as_end_date   varchar2, --结束日期yyyy-mm-dd，为空默认为当天
                           as_orgid      sys_organ.org_id%type, --为空时统计所有机构
                           av_actionno   in number, --业务流水号
                           av_debug      IN VARCHAR2, --1调试
                           av_res        OUT VARCHAR2, --传出参数代码
                           av_msg        OUT VARCHAR2 --传出参数错误信息
                           );
  /*=======================================================================================*/
  --按起止时间批量生成轧账数据表tr_day_bal_data，前提是tr_day_base数据已经生成
  --av_daybal_type为1柜员：生成柜员数据，2网点：生成网点、柜员数据，3机构：生成机构、网点、柜员数据
  /*=======================================================================================*/
  PROCEDURE p_batch_daybal_data(as_start_date     varchar2, --开始日期yyyy-mm-dd，为空默认为当天
                                as_end_date       varchar2, --结束日期yyyy-mm-dd，为空默认为当天
                                av_daybal_type    varchar2, --1柜员，2网点，3机构
                                av_daybal_ownerid IN VARCHAR2, --轧账主体编号
                                av_actionno       in number, --业务流水号
                                av_debug          IN VARCHAR2, --1调试
                                av_res            OUT VARCHAR2, --传出参数代码
                                av_msg            OUT VARCHAR2 --传出参数错误信息
                                );
  /*=======================================================================================*/
  --充值消费统计，按清分日期统计账户流水表记录到stat_charge_consume，定时器触发
  --界面查询时，直接查询临时表
  /*=======================================================================================*/
  procedure p_stat_charge_consume(av_clrdate varchar2, --清分日期
                                  av_orgid   sys_organ.org_id%type, --机构，为空时统计所有机构
                                  av_debug   IN VARCHAR2, --调试0是，1否
                                  av_res     OUT VARCHAR2, --传出参数代码
                                  av_msg     OUT VARCHAR2 --传出参数错误信息
                                  );
  /*=======================================================================================*/
  --批量手工生成充值消费统计，按清分日期统计账户流水表记录到stat_charge_consume，定时器触发
  --界面查询时，直接查询临时表
  /*=======================================================================================*/
  procedure p_batch_stat_charge_consume(av_start_date varchar2, --开始日期yyyy-mm-dd，为空默认为当天
                                        av_end_date   varchar2, --结束日期yyyy-mm-dd，为空默认为当天
                                        av_orgid      sys_organ.org_id%type, --机构，为空时统计所有机构
                                        av_debug      IN VARCHAR2, --调试0是，1否
                                        av_res        OUT VARCHAR2, --传出参数代码
                                        av_msg        OUT VARCHAR2 --传出参数错误信息
                                        );
  /*=======================================================================================*/
  --代理业务统计，按清分日期统计综合业务表记录到stat_agent_busi，定时器触发
  --界面查询时，直接查询临时表
  /*=======================================================================================*/
  procedure p_stat_agent_busi(av_clrdate varchar2, --清分日期
                              av_coorgid sys_organ.org_id%type, --机构
                              av_debug   IN VARCHAR2, --调试0是，1否
                              av_res     OUT VARCHAR2, --传出参数代码
                              av_msg     OUT VARCHAR2 --传出参数错误信息
                              );
  /*=======================================================================================*/
  --批量手工统计：代理业务统计，按清分日期统计综合业务表记录到stat_agent_busi，定时器触发
  --界面查询时，直接查询临时表
  /*=======================================================================================*/
  procedure p_batch_stat_agent_busi(av_start_date varchar2, --开始日期yyyy-mm-dd，为空默认为当天
                                    av_end_date   varchar2, --结束日期yyyy-mm-dd，为空默认为当天
                                    av_coorgid    sys_organ.org_id%type, --机构
                                    av_debug      IN VARCHAR2, --调试0是，1否
                                    av_res        OUT VARCHAR2, --传出参数代码
                                    av_msg        OUT VARCHAR2 --传出参数错误信息
                                    );
  /*=======================================================================================*/
  --现金业务统计，直接取轧账数据表tr_day_bal_data中的CASH_ITEM对应的统计项
  --界面查询时，直接查询临时表
  /*=======================================================================================*/
  procedure p_stat_cash_busi(av_clrdate        varchar2, --清分日期
                             av_daybal_type    varchar2, --1柜员，2网点，3机构
                             av_daybal_ownerid IN VARCHAR2, --轧账主体编号
                             av_debug          IN VARCHAR2, --调试0是，1否
                             av_res            OUT VARCHAR2, --传出参数代码
                             av_msg            OUT VARCHAR2 --传出参数错误信息
                             );
  /*=======================================================================================*/
  --批量手工统计：现金业务统计，直接取轧账数据表tr_day_bal_data中的CASH_ITEM对应的统计项
  --界面查询时，直接查询临时表
  /*=======================================================================================*/
  procedure p_batch_stat_cash_busi(as_start_date     varchar2, --开始日期yyyy-mm-dd，为空默认为当天
                                   as_end_date       varchar2, --结束日期yyyy-mm-dd，为空默认为当天
                                   av_daybal_type    varchar2, --1柜员，2网点，3机构
                                   av_daybal_ownerid IN VARCHAR2, --轧账主体编号
                                   av_debug          IN VARCHAR2, --调试0是，1否
                                   av_res            OUT VARCHAR2, --传出参数代码
                                   av_msg            OUT VARCHAR2 --传出参数错误信息
                                   );

  /*=======================================================================================*/
  --进行脱机数据的对账的清算数据统计
  /*=======================================================================================*/
  procedure p_clr_offline_sum(av_biz_id   varchar2, --商户号
                              av_clr_date varchar2, --清分日期
                              av_debug    IN VARCHAR2, --调试0是，1否
                              av_res      OUT VARCHAR2, --传出参数代码
                              av_msg      OUT VARCHAR2 --传出参数错误信息
                              );

  /*=======================================================================================*/
  --备付金充值统计
  /*=======================================================================================*/
  procedure p_stat_readypay_sum(av_org_id   varchar2, --商户号
                                av_clr_date varchar2, --清分日期
                                av_debug    IN VARCHAR2, --调试0是，1否
                                av_res      OUT VARCHAR2, --传出参数代码
                                av_msg      OUT VARCHAR2 --传出参数错误信息
                                );
  /*=======================================================================================*/
  --合作机构充值消费统计，
  /*=======================================================================================*/
  procedure p_stat_charge_consume_co_org(av_clrdate   varchar2, --清分日期
                                         av_co_org_id base_co_org.co_org_id%type, --机构，为空时统计所有机构
                                         av_debug     IN VARCHAR2, --调试0是，1否
                                         av_res       OUT VARCHAR2, --传出参数代码
                                         av_msg       OUT VARCHAR2 --传出参数错误信息
                                         );
END pk_statistic;
/

