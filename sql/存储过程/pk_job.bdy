CREATE OR REPLACE PACKAGE BODY pk_job IS
  /*=======================================================================================*/
  --定时创建表
  /*=======================================================================================*/
  PROCEDURE p_createobject IS
  BEGIN
    pk_createobject.p_create;
  END p_createobject;
  /*=======================================================================================*/
  --定时日终
  /*=======================================================================================*/
  PROCEDURE p_cutday(av_operid IN sys_users.user_id%TYPE, --结算柜员
                     av_res    OUT VARCHAR2, --传出代码
                     av_msg    OUT VARCHAR2)--传出错误信息
                     IS
    lv_clrdate pay_clr_para.clr_date%type;
  BEGIN
    select clr_date into lv_clrdate from pay_clr_para t;

    pk_public.p_insertrzcllog('开始p_daybal', -99990001);
    p_daybal(lv_clrdate);
    COMMIT;

    pk_public.p_insertrzcllog('结束p_daybal,开始pk_job.p_cutday',
                              -99990001);
    pk_cutday.p_job;
    COMMIT;

    pk_public.p_insertrzcllog('结束pk_cutday.p_job,开始p_merchantsettle',
                              -99990001);
    p_merchantsettle;
    COMMIT;

    pk_public.p_insertrzcllog('结束p_merchantsettle,开始p_stat', -99990001);
    p_stat(lv_clrdate);
    COMMIT;

    pk_public.p_insertrzcllog('结束p_stat,开始p_change_market_reg_no',
                              -99990001);
   -- pk_business.p_change_market_reg_no;
    COMMIT;

    pk_public.p_insertrzcllog('结束pk_job.p_cutday', -99990001);
  END p_cutday;
  /*=======================================================================================*/
  --VIP卡每日赠送1元买菜金，一年365元
  /*=======================================================================================*/
 /* PROCEDURE p_vippromotion IS
    lv_res VARCHAR2(10);
    lv_msg VARCHAR2(1000);
  BEGIN
    pk_consume.p_vippromotion(to_char(SYSDATE - 1, 'yyyy-mm-dd'), --日期yyyy-mm-dd
                              '0', --1调试
                              lv_res, --传出代码
                              lv_msg --传出错误信息
                              );
    IF lv_res <> pk_public.cs_res_ok THEN
      ROLLBACK;
      --Raise_application_error(-20000, lv_msg);
    END IF;
  END p_vippromotion;
  /*=======================================================================================*/
  --定时商户结算
  /*=======================================================================================*/
  PROCEDURE p_merchantsettle IS
  BEGIN
    pk_merchantsettle.p_job;
  END p_merchantsettle;

  /*=======================================================================================*/
  --报表统计，日切后执行，因为日切中有处理消费数据环节
  /*=======================================================================================*/
  PROCEDURE p_stat(lv_clrdate in pay_clr_para.clr_date%type) IS
    lv_res VARCHAR2(10);
    lv_msg VARCHAR2(1000);
    --lv_actionno sys_action_log.action_no%type;
  BEGIN
    --充值消费统计
    pk_statistic.p_batch_stat_charge_consume(lv_clrdate, --清分日期
                                             lv_clrdate, --清分日期
                                             null, --机构，为空时统计所有机构
                                             '1', --调试0是，1否
                                             lv_res, --传出参数代码
                                             lv_msg --传出参数错误信息
                                             );
    if lv_res <> pk_public.cs_res_ok then
      pk_public.p_insertrzcllog('异常p_batch_stat_charge_consume:' || lv_msg,
                                -99980001);
    end if;

    --代理业务统计
    pk_statistic.p_batch_stat_agent_busi(lv_clrdate, --清分日期
                                         lv_clrdate, --清分日期
                                         null, --所有机构
                                         '1', --调试0是，1否
                                         lv_res,
                                         lv_msg);
    if lv_res <> pk_public.cs_res_ok then
      pk_public.p_insertrzcllog('异常p_stat_agent_busi:' || lv_msg,
                                -99980001);
    end if;

    --现金业务统计
    pk_statistic.p_batch_stat_cash_busi(lv_clrdate, --清分日期
                                        lv_clrdate, --清分日期
                                        '3', --1柜员，2网点，3机构
                                        null, --轧账主体编号,，所有机构
                                        '1', --调试0是，1否7
                                        lv_res,
                                        lv_msg);
    if lv_res <> pk_public.cs_res_ok then
      pk_public.p_insertrzcllog('异常p_batch_stat_cash_busi:' || lv_msg,
                                -99980001);
    end if;

    --统计备付金报表
    pk_statistic.p_stat_readypay_sum('1001' ,
                                     lv_clrdate ,
                                     '1',
                                     lv_res,
                                     lv_msg);
    if lv_res <> pk_public.cs_res_ok then
      pk_public.p_insertrzcllog('异常p_batch_stat_cash_busi:' || lv_msg,
                                -99980001);
    end if;
  END p_stat;

  /*=======================================================================================*/
  --轧账，日切前执行，日切中有处理轧账标志字段
  /*=======================================================================================*/
  PROCEDURE p_daybal(lv_clrdate in pay_clr_para.clr_date%type) IS
    lv_res      VARCHAR2(10);
    lv_msg      VARCHAR2(1000);
    lv_actionno sys_action_log.deal_no%type;
  BEGIN
    select seq_action_no.nextval into lv_actionno from dual;
    pk_statistic.p_batch_daybal(lv_clrdate,
                                lv_clrdate,
                                null, --所有机构
                                lv_actionno, --业务流水号
                                '1', --调试0是，1否
                                lv_res,
                                lv_msg);
    if lv_res <> pk_public.cs_res_ok then
      pk_public.p_insertrzcllog('异常p_batch_daybal:' || lv_msg, -99980001);
    end if;
  END p_daybal;
BEGIN
  NULL;
END pk_job;
/

