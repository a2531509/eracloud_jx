CREATE OR REPLACE PACKAGE BODY pk_job IS
  /*=======================================================================================*/
  --��ʱ������
  /*=======================================================================================*/
  PROCEDURE p_createobject IS
  BEGIN
    pk_createobject.p_create;
  END p_createobject;
  /*=======================================================================================*/
  --��ʱ����
  /*=======================================================================================*/
  PROCEDURE p_cutday(av_operid IN sys_users.user_id%TYPE, --�����Ա
                     av_res    OUT VARCHAR2, --��������
                     av_msg    OUT VARCHAR2)--����������Ϣ
                     IS
    lv_clrdate pay_clr_para.clr_date%type;
  BEGIN
    select clr_date into lv_clrdate from pay_clr_para t;

    pk_public.p_insertrzcllog('��ʼp_daybal', -99990001);
    p_daybal(lv_clrdate);
    COMMIT;

    pk_public.p_insertrzcllog('����p_daybal,��ʼpk_job.p_cutday',
                              -99990001);
    pk_cutday.p_job;
    COMMIT;

    pk_public.p_insertrzcllog('����pk_cutday.p_job,��ʼp_merchantsettle',
                              -99990001);
    p_merchantsettle;
    COMMIT;

    pk_public.p_insertrzcllog('����p_merchantsettle,��ʼp_stat', -99990001);
    p_stat(lv_clrdate);
    COMMIT;

    pk_public.p_insertrzcllog('����p_stat,��ʼp_change_market_reg_no',
                              -99990001);
   -- pk_business.p_change_market_reg_no;
    COMMIT;

    pk_public.p_insertrzcllog('����pk_job.p_cutday', -99990001);
  END p_cutday;
  /*=======================================================================================*/
  --VIP��ÿ������1Ԫ��˽�һ��365Ԫ
  /*=======================================================================================*/
 /* PROCEDURE p_vippromotion IS
    lv_res VARCHAR2(10);
    lv_msg VARCHAR2(1000);
  BEGIN
    pk_consume.p_vippromotion(to_char(SYSDATE - 1, 'yyyy-mm-dd'), --����yyyy-mm-dd
                              '0', --1����
                              lv_res, --��������
                              lv_msg --����������Ϣ
                              );
    IF lv_res <> pk_public.cs_res_ok THEN
      ROLLBACK;
      --Raise_application_error(-20000, lv_msg);
    END IF;
  END p_vippromotion;
  /*=======================================================================================*/
  --��ʱ�̻�����
  /*=======================================================================================*/
  PROCEDURE p_merchantsettle IS
  BEGIN
    pk_merchantsettle.p_job;
  END p_merchantsettle;

  /*=======================================================================================*/
  --����ͳ�ƣ����к�ִ�У���Ϊ�������д����������ݻ���
  /*=======================================================================================*/
  PROCEDURE p_stat(lv_clrdate in pay_clr_para.clr_date%type) IS
    lv_res VARCHAR2(10);
    lv_msg VARCHAR2(1000);
    --lv_actionno sys_action_log.action_no%type;
  BEGIN
    --��ֵ����ͳ��
    pk_statistic.p_batch_stat_charge_consume(lv_clrdate, --�������
                                             lv_clrdate, --�������
                                             null, --������Ϊ��ʱͳ�����л���
                                             '1', --����0�ǣ�1��
                                             lv_res, --������������
                                             lv_msg --��������������Ϣ
                                             );
    if lv_res <> pk_public.cs_res_ok then
      pk_public.p_insertrzcllog('�쳣p_batch_stat_charge_consume:' || lv_msg,
                                -99980001);
    end if;

    --����ҵ��ͳ��
    pk_statistic.p_batch_stat_agent_busi(lv_clrdate, --�������
                                         lv_clrdate, --�������
                                         null, --���л���
                                         '1', --����0�ǣ�1��
                                         lv_res,
                                         lv_msg);
    if lv_res <> pk_public.cs_res_ok then
      pk_public.p_insertrzcllog('�쳣p_stat_agent_busi:' || lv_msg,
                                -99980001);
    end if;

    --�ֽ�ҵ��ͳ��
    pk_statistic.p_batch_stat_cash_busi(lv_clrdate, --�������
                                        lv_clrdate, --�������
                                        '3', --1��Ա��2���㣬3����
                                        null, --����������,�����л���
                                        '1', --����0�ǣ�1��7
                                        lv_res,
                                        lv_msg);
    if lv_res <> pk_public.cs_res_ok then
      pk_public.p_insertrzcllog('�쳣p_batch_stat_cash_busi:' || lv_msg,
                                -99980001);
    end if;

    --ͳ�Ʊ����𱨱�
    pk_statistic.p_stat_readypay_sum('1001' ,
                                     lv_clrdate ,
                                     '1',
                                     lv_res,
                                     lv_msg);
    if lv_res <> pk_public.cs_res_ok then
      pk_public.p_insertrzcllog('�쳣p_batch_stat_cash_busi:' || lv_msg,
                                -99980001);
    end if;
  END p_stat;

  /*=======================================================================================*/
  --���ˣ�����ǰִ�У��������д������˱�־�ֶ�
  /*=======================================================================================*/
  PROCEDURE p_daybal(lv_clrdate in pay_clr_para.clr_date%type) IS
    lv_res      VARCHAR2(10);
    lv_msg      VARCHAR2(1000);
    lv_actionno sys_action_log.deal_no%type;
  BEGIN
    select seq_action_no.nextval into lv_actionno from dual;
    pk_statistic.p_batch_daybal(lv_clrdate,
                                lv_clrdate,
                                null, --���л���
                                lv_actionno, --ҵ����ˮ��
                                '1', --����0�ǣ�1��
                                lv_res,
                                lv_msg);
    if lv_res <> pk_public.cs_res_ok then
      pk_public.p_insertrzcllog('�쳣p_batch_daybal:' || lv_msg, -99980001);
    end if;
  END p_daybal;
BEGIN
  NULL;
END pk_job;
/

