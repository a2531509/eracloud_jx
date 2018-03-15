create or replace package body pk_interface_service is
  /*=======================================================================================*/
  ---�������(���˵İ汾--��ֵ����)
  /*=======================================================================================*/
  PROCEDURE p_save_sms_message(av_dealcode IN INTEGER, --���״���
                               av_dealno   IN NUMBER, --��ˮ��
                               av_cardno   IN VARCHAR2, --����
                               av_tramt    IN  NUMBER, --���׽��
                               av_bef_bal  IN  NUMBER, --����ǰ���---�˻���
                               av_res      OUT VARCHAR2, --������ 00 �ɹ�
                               av_msg      OUT VARCHAR2) is
    --��������������Ϣ
    lv_sms_type VARCHAR2(2) := '02'; --�������� 01���ţ�02��ֵ��03���ѣ�04Ȧ�棬05�������06��ʧ,07���,08����������99�Զ������
    lv_content  VARCHAR2(300) := '����֪ͨ';
    lv_time     varchar2(30);
    lv_date     varchar2(6);
    LV_COUNT    NUMBER := 0;
    LV_AMT      NUMBER := 0; ---���׽��
    LV_BEF_BAL  NUMBER := 0; --����ǰ���---��Ƭ��
    LV_aft_bal  NUMBER := 0; --���׺���
    LV_AFT_BAL_TJ  NUMBER := 0; --���׺���
    LV_PERSONAL BASE_PERSONAL%ROWTYPE; -- ��Ա������Ϣ
    LV_ACCACCOUNTSUB ACC_ACCOUNT_SUB%ROWTYPE;--�˻���Ϣ
    lv_smessages sys_smessages%ROWTYPE; -- ������Ϣ
    lv_basecoorg base_co_org%ROWTYPE;--����������Ϣ
    lv_acptid    acc_inout_detail.acpt_id%TYPE;--�����������
  begin
    lv_time := to_char(sysdate, 'yyyy"��"mm"��"dd"��"hh24"ʱ"mi"��"'); --ҵ��ʱ��
    lv_date := to_char(sysdate, 'yyyymm'); --�˻�������ˮ
    if av_dealcode in('30101010','30101011','30101040','30105020','30105010') then
        execute immediate ' select a.cr_amt,a.cr_card_bal,acpt_id  from acc_inout_detail_' ||
               lv_date || ' a where a.deal_no=' || av_dealno   into  LV_AMT, LV_BEF_BAL,lv_acptid;
         IF av_dealcode in('30105020','30105010') then
              --����������Ϣ
             select * into lv_basecoorg from base_co_org g where g.co_org_id=lv_acptid;
         END IF;
      
     else
        execute immediate ' select a.db_amt,a.db_card_bal,acpt_id  from acc_inout_detail_' ||
               lv_date || ' a where a.deal_no=' || av_dealno   into  LV_AMT, LV_BEF_BAL,lv_acptid;
    end if;  
    --select a.db_amt,a.db_acc_bal into LV_AMT,LV_BEF_BAL from acc_inout_detail a where a.deal_no=av_dealno;
    LV_aft_bal := (av_tramt + av_bef_bal); --���׺���
    LV_AMT     := abs(LV_AMT) / 100; --���׽��
    LV_aft_bal := abs(LV_BEF_BAL) / 100; --���׺���
    
    
    ----��Ա��Ϣ
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
      av_msg := '��Ա��Ϣ�Ϳ���Ϣ������';
      RETURN;
    end if;
  
    
   select * into LV_ACCACCOUNTSUB from acc_account_sub b where b.CARD_NO=av_cardno AND B.ACC_KIND='02';
    if av_dealcode=30101020 then
      --�����˻���ֵ
      lv_sms_type := '02';
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || '��' || lv_time ||
                     '���������˻���ֵ' || abs(av_tramt/100) || 'Ԫ����ǰ�����˻����Ϊ' || LV_ACCACCOUNTSUB.BAL/100 ||
                     'Ԫ���ۼ������񿨣�';
    elsif av_dealcode = 30101010 then
      --Ǯ���˻��ֽ��ֵ��
      lv_sms_type := '02';
      LV_AFT_BAL_TJ := (av_tramt + LV_BEF_BAL) / 100; --��Ƭ���׺���
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || '��' || lv_time ||
                     '��������Ǯ����ֵ' || abs(av_tramt/100) || 'Ԫ����ǰ����Ǯ�����Ϊ' || LV_AFT_BAL_TJ ||
                     'Ԫ���ۼ������񿨣�';
      elsif av_dealcode = 30105010 then
      --�˻�����������ֵ��
      lv_sms_type := '02';
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || ',���������˻���' || lv_time ||
                     '��ͨ��'||lv_basecoorg.co_org_name||'��ֵ' || abs(av_tramt/100) || 'Ԫ����ǰ�����˻����Ϊ'|| LV_ACCACCOUNTSUB.BAL/100 ||'Ԫ���ۼ������񿨣�';
     elsif av_dealcode = 30105020 then
      --Ǯ���˻�����������ֵ��
      lv_sms_type := '02';
      LV_AFT_BAL_TJ := (av_tramt + LV_BEF_BAL) / 100; --��Ƭ���׺���
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || ',���������˻���' || lv_time ||
                     '��ͨ��'||lv_basecoorg.co_org_name||'��ֵ' || abs(av_tramt/100) || 'Ԫ����ǰ����Ǯ�����Ϊ' || LV_AFT_BAL_TJ ||
                     'Ԫ���ۼ������񿨣�';
    elsif av_dealcode = 30101040 then
      --�˻�������Ǯ��Ȧ��
      lv_sms_type := '04';
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || '��' || lv_time ||
                     '�����������˻���' || LV_PERSONAL.NAME || '������Ǯ���˻�Ȧ��' || abs(av_tramt/100) ||
                     'Ԫ������Ǯ�����' || (LV_BEF_BAL+av_tramt)/100 || 'Ԫ���ۼ������񿨣�';
    elsif av_dealcode = 30302010 then
      --�����˻��������˻�Ȧ��
      lv_sms_type := '04';
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || '��' || lv_time ||
                     '���������˻��������˻�Ȧ��' || abs(av_tramt/100) || 'Ԫ�������˻����' || LV_ACCACCOUNTSUB.BAL/100 ||
                     'Ԫ���ۼ������񿨣�';
    elsif av_dealcode = 30601030 or av_dealcode = 30601020 then
      --��λ�����ת��
      lv_sms_type := '02';
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || '��' || lv_time ||
                     '�����������˻��յ���λ��ֵ��' || abs(av_tramt/100) || 'Ԫ�������˻����' ||
                     LV_ACCACCOUNTSUB.BAL/100 || 'Ԫ���ۼ������񿨣�';
    elsif av_dealcode = 30101021  then
      --�����˻���ֵ������
      lv_sms_type := '02';
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || ',���������˻���' || lv_time ||
                     '��������ֵ' || abs(av_tramt/100) || 'Ԫ����ǰ�����˻����Ϊ' || LV_ACCACCOUNTSUB.BAL/100 ||
                     'Ԫ���ۼ������񿨣�';
    elsif av_dealcode = 30101011 then
      --����Ǯ����ֵ����
      lv_sms_type := '02';
      LV_AFT_BAL_TJ := (av_tramt + LV_BEF_BAL) / 100; --��Ƭ���׺���
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || '����������Ǯ����' || lv_time ||
                     '��������ֵ' || abs(av_tramt/100) || 'Ԫ����ǰ����Ǯ�����Ϊ' ||(abs(LV_BEF_BAL)-abs(av_tramt))/100 ||
                     'Ԫ���ۼ������񿨣�';
    elsif av_dealcode = 40201010 or av_dealcode = 40202010 then
      --����
      lv_sms_type := '03';
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || '��' || lv_time ||
                     '�����������˻�����֧��' || abs(av_tramt/100) || 'Ԫ�������˻����Ϊ' || LV_ACCACCOUNTSUB.BAL/100 ||
                     'Ԫ���ۼ������񿨣�';
    elsif av_dealcode = 40202031 or av_dealcode = 40201031 then
      --���ѳ���
      lv_sms_type := '03';
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || '��' || lv_time ||
                     '�����������˻����ѳ���' || abs(av_tramt/100) || 'Ԫ�������˻����Ϊ' || LV_ACCACCOUNTSUB.BAL/100 ||
                     'Ԫ���ۼ������񿨣�';
    elsif av_dealcode = 40202022 or av_dealcode = 40102022 then
      --���ѳ���
      lv_sms_type := '03';
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || '��' || lv_time ||
                     '�����������˻����ѳ���' || abs(av_tramt/100) || 'Ԫ�������˻����Ϊ' || LV_ACCACCOUNTSUB.BAL/100 ||
                     'Ԫ���ۼ������񿨣�';
    elsif av_dealcode = 40202051 or av_dealcode = 40102051 then
      --�����˻�
      lv_sms_type := '03';
      lv_content  := '�𾴵�' || LV_PERSONAL.NAME || '��' || lv_time ||
                     '�����������˻������˻�' || abs(av_tramt/100) || 'Ԫ�������˻����Ϊ' || LV_ACCACCOUNTSUB.BAL/100 ||
                     'Ԫ���ۼ������񿨣�';
    else
      lv_sms_type := '03';
      lv_content  := '��л�����ü�����ᱣ�����񿨣�����ͨ���ͷ�����967225�ͷ�����վwww.jxsmk.com��ȡ�������ۼ������񿨣�';
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
     ---------Զ�̲���----------

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

