create or replace package body pk_interface_service is
  /*=======================================================================================*/
  ---保存短信(嘉兴的版本--充值消费)
  /*=======================================================================================*/
  PROCEDURE p_save_sms_message(av_dealcode IN INTEGER, --交易代码
                               av_dealno   IN NUMBER, --流水号
                               av_cardno   IN VARCHAR2, --卡号
                               av_tramt    IN  NUMBER, --交易金额
                               av_bef_bal  IN  NUMBER, --交易前金额---账户的
                               av_res      OUT VARCHAR2, --返回码 00 成功
                               av_msg      OUT VARCHAR2) is
    --传出参数错误信息
    lv_sms_type VARCHAR2(2) := '02'; --短信类型 01发放，02充值，03消费，04圈存，05密码服务，06挂失,07解挂,08其他卡服务，99自定义短信
    lv_content  VARCHAR2(300) := '短信通知';
    lv_time     varchar2(30);
    lv_date     varchar2(6);
    LV_COUNT    NUMBER := 0;
    LV_AMT      NUMBER := 0; ---交易金额
    LV_BEF_BAL  NUMBER := 0; --交易前金额---卡片上
    LV_aft_bal  NUMBER := 0; --交易后金额
    LV_AFT_BAL_TJ  NUMBER := 0; --交易后金额
    LV_PERSONAL BASE_PERSONAL%ROWTYPE; -- 人员基本信息
    LV_ACCACCOUNTSUB ACC_ACCOUNT_SUB%ROWTYPE;--账户信息
    lv_smessages sys_smessages%ROWTYPE; -- 短信信息
    lv_basecoorg base_co_org%ROWTYPE;--合作机构信息
    lv_acptid    acc_inout_detail.acpt_id%TYPE;--合作机构编号
  begin
    lv_time := to_char(sysdate, 'yyyy"年"mm"月"dd"日"hh24"时"mi"分"'); --业务时间
    lv_date := to_char(sysdate, 'yyyymm'); --账户交易流水
    if av_dealcode in('30101010','30101011','30101040','30105020','30105010') then
        execute immediate ' select a.cr_amt,a.cr_card_bal,acpt_id  from acc_inout_detail_' ||
               lv_date || ' a where a.deal_no=' || av_dealno   into  LV_AMT, LV_BEF_BAL,lv_acptid;
         IF av_dealcode in('30105020','30105010') then
              --合作机构信息
             select * into lv_basecoorg from base_co_org g where g.co_org_id=lv_acptid;
         END IF;
      
     else
        execute immediate ' select a.db_amt,a.db_card_bal,acpt_id  from acc_inout_detail_' ||
               lv_date || ' a where a.deal_no=' || av_dealno   into  LV_AMT, LV_BEF_BAL,lv_acptid;
    end if;  
    --select a.db_amt,a.db_acc_bal into LV_AMT,LV_BEF_BAL from acc_inout_detail a where a.deal_no=av_dealno;
    LV_aft_bal := (av_tramt + av_bef_bal); --交易后金额
    LV_AMT     := abs(LV_AMT) / 100; --交易金额
    LV_aft_bal := abs(LV_BEF_BAL) / 100; --交易后金额
    
    
    ----人员信息
    select count(*)
      into LV_COUNT
      from base_personal l, card_baseinfo c
     where c.customer_id = l.customer_id
       and c.card_type in ('100', '120')
       --and c.card_state = '1'
       and c.card_no = av_cardno;
    if LV_COUNT > 0 then
      select l.*
        into LV_PERSONAL
        from base_personal l, card_baseinfo c
       where c.customer_id = l.customer_id
         and c.card_type in ('100', '120')
        -- and c.card_state = '1'
         and c.card_no = av_cardno;
    else
      av_res := pk_public.cs_res_busierr;
      av_msg := '人员信息和卡信息不存在';
      RETURN;
    end if;
  
    
   select * into LV_ACCACCOUNTSUB from acc_account_sub b where b.CARD_NO=av_cardno AND B.ACC_KIND='02';
    if av_dealcode=30101020 then
      --联机账户充值
      lv_sms_type := '02';
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || '，' || lv_time ||
                     '，向市民卡账户充值' || abs(av_tramt/100) || '元，当前市民卡账户余额为' || LV_ACCACCOUNTSUB.BAL/100 ||
                     '元。［嘉兴市民卡］';
    elsif av_dealcode = 30101010 then
      --钱包账户现金充值：
      lv_sms_type := '02';
      LV_AFT_BAL_TJ := (av_tramt + LV_BEF_BAL) / 100; --卡片交易后金额
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || '，' || lv_time ||
                     '，向市民卡钱包充值' || abs(av_tramt/100) || '元，当前市民卡钱包余额为' || LV_AFT_BAL_TJ ||
                     '元。［嘉兴市民卡］';
      elsif av_dealcode = 30105010 then
      --账户合作机构充值：
      lv_sms_type := '02';
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || ',您的市民卡账户于' || lv_time ||
                     '，通过'||lv_basecoorg.co_org_name||'充值' || abs(av_tramt/100) || '元，当前市民卡账户余额为'|| LV_ACCACCOUNTSUB.BAL/100 ||'元。［嘉兴市民卡］';
     elsif av_dealcode = 30105020 then
      --钱包账户合作机构充值：
      lv_sms_type := '02';
      LV_AFT_BAL_TJ := (av_tramt + LV_BEF_BAL) / 100; --卡片交易后金额
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || ',您的市民卡账户于' || lv_time ||
                     '，通过'||lv_basecoorg.co_org_name||'充值' || abs(av_tramt/100) || '元，当前市民卡钱包余额为' || LV_AFT_BAL_TJ ||
                     '元。［嘉兴市民卡］';
    elsif av_dealcode = 30101040 then
      --账户至市民卡钱包圈存
      lv_sms_type := '04';
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || '，' || lv_time ||
                     '，您的市民卡账户向' || LV_PERSONAL.NAME || '的市民卡钱包账户圈存' || abs(av_tramt/100) ||
                     '元，市民卡钱包余额' || (LV_BEF_BAL+av_tramt)/100 || '元。［嘉兴市民卡］';
    elsif av_dealcode = 30302010 then
      --银行账户向市民卡账户圈存
      lv_sms_type := '04';
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || '，' || lv_time ||
                     '，绑定银行账户向市民卡账户圈存' || abs(av_tramt/100) || '元，市民卡账户余额' || LV_ACCACCOUNTSUB.BAL/100 ||
                     '元。［嘉兴市民卡］';
    elsif av_dealcode = 30601030 or av_dealcode = 30601020 then
      --单位向个人转账
      lv_sms_type := '02';
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || '，' || lv_time ||
                     '，您的市民卡账户收到单位充值款' || abs(av_tramt/100) || '元，市民卡账户余额' ||
                     LV_ACCACCOUNTSUB.BAL/100 || '元。［嘉兴市民卡］';
    elsif av_dealcode = 30101021  then
      --市民卡账户充值撤销：
      lv_sms_type := '02';
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || ',您的市民卡账户于' || lv_time ||
                     '，撤销充值' || abs(av_tramt/100) || '元，当前市民卡账户余额为' || LV_ACCACCOUNTSUB.BAL/100 ||
                     '元。［嘉兴市民卡］';
    elsif av_dealcode = 30101011 then
      --市民卡钱包充值撤销
      lv_sms_type := '02';
      LV_AFT_BAL_TJ := (av_tramt + LV_BEF_BAL) / 100; --卡片交易后金额
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || '，您的市民卡钱包于' || lv_time ||
                     '，撤销充值' || abs(av_tramt/100) || '元，当前市民卡钱包余额为' ||(abs(LV_BEF_BAL)-abs(av_tramt))/100 ||
                     '元。［嘉兴市民卡］';
    elsif av_dealcode = 40201010 or av_dealcode = 40202010 then
      --消费
      lv_sms_type := '03';
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || '，' || lv_time ||
                     '，您的市民卡账户消费支出' || abs(av_tramt/100) || '元，市民卡账户余额为' || LV_ACCACCOUNTSUB.BAL/100 ||
                     '元。［嘉兴市民卡］';
    elsif av_dealcode = 40202031 or av_dealcode = 40201031 then
      --消费撤消
      lv_sms_type := '03';
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || '，' || lv_time ||
                     '，您的市民卡账户消费撤消' || abs(av_tramt/100) || '元，市民卡账户余额为' || LV_ACCACCOUNTSUB.BAL/100 ||
                     '元。［嘉兴市民卡］';
    elsif av_dealcode = 40202022 or av_dealcode = 40102022 then
      --消费冲正
      lv_sms_type := '03';
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || '，' || lv_time ||
                     '，您的市民卡账户消费冲正' || abs(av_tramt/100) || '元，市民卡账户余额为' || LV_ACCACCOUNTSUB.BAL/100 ||
                     '元。［嘉兴市民卡］';
    elsif av_dealcode = 40202051 or av_dealcode = 40102051 then
      --消费退货
      lv_sms_type := '03';
      lv_content  := '尊敬的' || LV_PERSONAL.NAME || '，' || lv_time ||
                     '，您的市民卡账户消费退货' || abs(av_tramt/100) || '元，市民卡账户余额为' || LV_ACCACCOUNTSUB.BAL/100 ||
                     '元。［嘉兴市民卡］';
    else
      lv_sms_type := '03';
      lv_content  := '感谢您启用嘉兴社会保障市民卡！您可通过客服热线967225和服务网站www.jxsmk.com获取帮助。［嘉兴市民卡］';
    END IF;
        lv_smessages.sms_no      := SEQ_SYS_SMESSAGES.NEXTVAL;
        lv_smessages.sms_type    := lv_sms_type;
        lv_smessages.customer_id :=LV_PERSONAL.Customer_Id;
        lv_smessages.card_no     :=av_cardno;
        lv_smessages.mobile_no   := nvl(LV_PERSONAL.Mobile_No,'0');
        lv_smessages.content     := lv_content;
        lv_smessages.rtn_state   := '';
        lv_smessages.sms_state   := '0';
        lv_smessages.send_time   := null;
        lv_smessages.oper_id     := 'admin';
        lv_smessages.deal_code   := av_dealcode;
        lv_smessages.deal_no     :=av_dealno;
        lv_smessages.create_time := to_char(sysdate,'yyyy-mm-dd hh24:mi:ss');
        lv_smessages.note        := '';
        insert into sys_smessages values lv_smessages;
     ---------远程插入----------

    insert into onecard_jx.sys_smessages@onecard_db1
      (sms_no,
       sms_type,
       client_id,
       card_no,
       mobile_no,
       content,---6
       rtn_state,
       sms_state,
       oper_id,
       tr_code,
       action_no,
       time)

    values
      (SEQ_SYS_SMESSAGES.nextval@ONECARD_DB1,
       lv_sms_type,
       LV_PERSONAL.Customer_Id,
       av_cardno,
       nvl(LV_PERSONAL.Mobile_No,'0'),
       lv_content,---6
       '',
       '0',
       'admin',
       '',
       av_dealno,
       to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss'));
    av_res := pk_public.cs_res_ok;
    av_msg := '';
  end p_save_sms_message;
BEGIN
  -- initialization
  NULL;
end pk_interface_service;
/

