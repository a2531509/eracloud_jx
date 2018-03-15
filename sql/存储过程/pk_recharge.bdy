CREATE OR REPLACE PACKAGE BODY pk_recharge IS
  cs_pay_source_xj   CONSTANT CHAR(1) := '0'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
  cs_pay_source_zz   CONSTANT CHAR(1) := '1'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
  cs_pay_source_czk  CONSTANT CHAR(1) := '2'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
  cs_pay_source_cx   CONSTANT CHAR(1) := '3'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
  cs_pay_source_xy   CONSTANT CHAR(1) := '4'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
  cs_pay_source_yck  CONSTANT CHAR(1) := '5'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
  cs_pay_source_qdcx CONSTANT CHAR(1) := '6'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
  cs_pay_source_qdjl CONSTANT CHAR(1) := '7'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������

  /*=======================================================================================*/
  --��ֵд�Ҽ�¼
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acpt_id      �������(����Ż��̻���Ż�����������
  --       6tr_batch_no  ���κ�
  --       7term_tr_no   �ն˽�����ˮ��
  --       8card_no      ����
  --       9card_tr_count�����׼�����
  --      10card_bal     Ǯ������ǰ���
  --      11acc_kind     �˻�����
  --      12wallet_id    Ǯ����� Ĭ��00
  --      13tr_amt       ��ֵ���(�������ö��ʱ������ĺ�����ö��)
  --      14pay_source   ��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������--> ����1����ת��
  --      15sourcecard   ��ֵ�����Ż����п����Ż��̻�clientid
  --      16rechg_pwd    ��ֵ������
  --      17note         ��ע
  --      18tr_state     9д�Ҽ�¼0ֱ��д������¼
  --      19encrypt      ��ֵ���˻��������
  --      20acpt_type    �������� ---��2��������
  --      21acc_bal      ���˻�����ǰ���
  /*=======================================================================================*/
  PROCEDURE p_recharge(av_in    IN VARCHAR2, --�������
                       av_debug IN VARCHAR2, --1����
                       av_res   OUT VARCHAR2, --��������
                       av_msg   OUT VARCHAR2 --����������Ϣ
                       ) IS
    --lv_count       number;
    lv_in          pk_public.myarray; --�����������
    lv_dbsubledger acc_account_sub%ROWTYPE; --�跽�ֻ���
    lv_crsubledger acc_account_sub%ROWTYPE; --�����ֻ���
    lv_operator    sys_users%ROWTYPE; --��Ա
    lv_branch      sys_branch%ROWTYPE; --����
    lv_clrdate     pay_clr_para.clr_date%TYPE; --�������
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --������ˮ��
    lrec_rechg     card_recharge%ROWTYPE; --��ֵ��
    lv_card        card_baseinfo%ROWTYPE; --��������Ϣ
    lv_cardpara    card_config%ROWTYPE; --��������
    lv_credit      acc_account_sub.credit_lmt%TYPE; --���÷�����
    lv_co_org      base_co_org%ROWTYPE;--��������
    av_co_org_id   VARCHAR2(20);
    lv_tablename   VARCHAR2(100);
    lv_count       NUMBER;
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             17, --�������ٸ���
                             21, --����������
                             'pk_recharge.p_recharge', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --�жϳ�ֵ��ˮ�Ƿ��ظ���ֻ��Ժ��������Ļ����ж�
    IF lv_in(20) = '2' THEN 
      IF lv_in(18) = '9' THEN
        lv_tablename := 'pay_card_deal_rec';
      ELSE
        lv_tablename := 'pay_card_deal_rec_' ||substr(replace(lv_clrdate,'-',''),0,6); ----��Ҫ���Ǵ���Ľ���ʱ���Ҳ���������
      END IF;
      execute immediate 'select count(1) from '||lv_tablename||' t where t.acpt_id = :1 and  t.user_id =:2 and t.deal_batch_no =:3  and t.END_DEAL_NO =:4 '
         into lv_count
         using lv_in(5),lv_in(3),lv_in(6),lv_in(7);
         if lv_count > 1 then
           av_res := pk_public.cs_res_rowunequalone;
           av_msg := '���������ظ�';
           return;
         end if;
    END IF;
    --Ĭ��д�Ҽ�¼
    IF lv_in(18) IS NULL THEN
      lv_in(18) := '9';
    ELSIF lv_in(18) NOT IN ('9', '0') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := 'tr_stateֻ��9��0';
      RETURN;
    END IF;
    --Ǯ�����Ĭ��00
    lv_in(12) := nvl(lv_in(12), pk_public.cs_defaultwalletid);
    IF lv_in(14) = '9' THEN--�����ֵ��ֱ��ȥָ��������id
       lv_operator.Brch_Id:=lv_in(5);
       lv_operator.user_id:='admin';
    ELSE
      IF lv_in(20) <> '2' THEN
          BEGIN
            SELECT * INTO lv_operator FROM sys_users WHERE user_id = lv_in(3);
            SELECT *
              INTO lv_branch
              FROM sys_branch
             WHERE brch_id = lv_operator.brch_id;

            IF lv_branch.brch_type = '3' THEN
              --��������
              IF lv_in(14) = cs_pay_source_xj THEN
                lv_in(14) := cs_pay_source_yck;
              END IF;
            END IF;
          EXCEPTION
            WHEN no_data_found THEN
              av_res := pk_public.cs_res_operatorerr;
              av_msg := 'δ�ҵ���Ա���' || lv_in(3);
              RETURN;
          END;
      END IF;
      --����������̻���
      IF lv_in(5) IS NULL THEN
        lv_in(5) := lv_operator.brch_id;
      END IF;
    END IF;

    --ȡ�跽�ֻ���

    IF lv_in(20) = '2' THEN
      BEGIN
         select * into lv_co_org from base_co_org where co_org_id = lv_in(5);
            if lv_co_org.co_state <> '0' then
               av_res := pk_public.cs_res_co_org_novalidateerr;
               av_msg := '�ܿ��������֤ʧ��';
               return;
            end if;
         EXCEPTION
            WHEN no_data_found THEN
               av_res := pk_public.cs_res_co_org_novalidateerr;
               av_msg := '�ܿ��������֤ʧ��';
      END;
    END IF;

    IF lv_in(14) = cs_pay_source_xj THEN
      --�ֽ�
          IF lv_in(20) = '2' THEN
             --���������ֽ�
             lv_dbsubledger.item_id :=pk_public.cs_accitem_co_org_rechage_in;
          ELSE
             --����
              lv_dbsubledger.item_id := pk_public.cs_accitem_cash;
          END IF;
          lv_operator.brch_id :=lv_in(5);
          pk_public.p_getsubledgerbyclientid(lv_operator.brch_id,
                                             lv_dbsubledger.item_id,
                                             lv_dbsubledger,
                                             av_res,
                                             av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
    ELSIF lv_in(14) = cs_pay_source_zz THEN
      --ת��
          IF lv_in(20) = '2' THEN
             --���������ֽ�
             lv_dbsubledger.item_id :=pk_public.cs_accitem_co_org_rechage_in;
             pk_public.p_getsubledgerbyclientid(lv_co_org.customer_id,
                                             lv_dbsubledger.item_id,
                                             lv_dbsubledger,
                                             av_res,
                                             av_msg);
          ELSE
             --����
              lv_dbsubledger.item_id := pk_public.cs_accitem_org_bank;
               pk_public.p_getorgsubledger(lv_operator.org_id,
                                      lv_dbsubledger.item_id,
                                      lv_dbsubledger,
                                      av_res,
                                      av_msg);
          END IF;

          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
    ELSIF lv_in(14) = cs_pay_source_czk THEN
      --��ֵ��
      BEGIN
        SELECT *
          INTO lrec_rechg
          FROM card_recharge
         WHERE card_no = lv_in(15);                   --���Ϊʲô��ȡ
        IF lrec_rechg.use_state <> '2' THEN
          av_res := pk_public.cs_res_prepaidcardnotexist;
          av_msg := '��ֵ��' || lv_in(15) || --
                    CASE lrec_rechg.use_state
                      WHEN '0' THEN
                       'δʹ��'
                      WHEN '1' THEN
                       'δ����'
                      WHEN '3' THEN
                       '��ʹ��'
                      WHEN '9' THEN
                       '��ע��'
                      ELSE
                       '�����Ѽ���״̬'
                    END;
          RETURN;
        ELSE
          IF lrec_rechg.pwd <> lv_in(16) THEN
            av_res := pk_public.cs_res_prepaidcardpwderr;
            av_msg := '��ֵ�����벻��ȷ';
            RETURN;
          END IF;
        END IF;
        --��ֵ���
        SELECT face_val
          INTO lv_in(13)
          FROM card_config
         WHERE card_type = lrec_rechg.card_type;
      EXCEPTION
        WHEN no_data_found THEN
          av_res := pk_public.cs_res_prepaidcardnotexist;
          av_msg := '�����ڸó�ֵ��' || lv_in(15);
          RETURN;
      END;
      lv_dbsubledger.item_id := pk_public.cs_accitem_card_deposit_800; --f_getitemnobycardtype(lrec_rechg.card_type);
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  lv_dbsubledger.item_id,
                                  lv_dbsubledger,
                                  av_res,
                                  av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --���ĳ�ֵ��״̬
      UPDATE card_recharge
         SET use_state = '3'
       WHERE card_no = lv_in(15)
         AND use_state = '2';
      IF SQL%ROWCOUNT = 0 THEN
        av_res := pk_public.cs_res_prepaidcardisused;
        av_msg := '��ֵ��' || lv_in(15) || '�ѱ�ʹ��';
        RETURN;
      END IF;
    ELSIF lv_in(14) = cs_pay_source_cx THEN
      --����
      lv_dbsubledger.item_id := pk_public.cs_accitem_org_prmt_out;
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  lv_dbsubledger.item_id,
                                  lv_dbsubledger,
                                  av_res,
                                  av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSIF lv_in(14) = cs_pay_source_qdcx THEN
      --�̻�ǩ������ ���̻������
      lv_dbsubledger.item_id := pk_public.cs_accitem_biz_stl;
      pk_public.p_getsubledgerbyclientid(lv_in(15), --�̻�client_id
                                         lv_dbsubledger.item_id, --�̻������
                                         lv_dbsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSIF lv_in(14) = cs_pay_source_qdjl THEN
      --ǩ������
      lv_dbsubledger.item_id := pk_public.cs_accitem_org_prmt_out;
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  lv_dbsubledger.item_id,
                                  lv_dbsubledger,
                                  av_res,
                                  av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSIF lv_in(14) = cs_pay_source_xy THEN
      --�������ö��
      lv_dbsubledger.item_id := pk_public.cs_accitem_org_credit_chg_out;
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  lv_dbsubledger.item_id,
                                  lv_dbsubledger,
                                  av_res,
                                  av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSIF lv_in(14) = cs_pay_source_yck THEN
      --����Ԥ���
      lv_dbsubledger.item_id := pk_public.cs_accitem_brch_prestore;
      pk_public.p_getsubledgerbyclientid(lv_operator.brch_id,
                                         lv_dbsubledger.item_id,
                                         lv_dbsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      pk_public.p_judgebranchagentlimit(lv_dbsubledger.customer_id, --������
                                        lv_dbsubledger.bal - lv_in(13), --�۳������Ԥ������
                                        av_res, --������������
                                        av_msg --��������������Ϣ
                                        );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSE
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�������pay_source����';
      RETURN;
    END IF;

    --ȡ�����ֻ���
    pk_public.p_getsubledgerbycardno(lv_in(8), --����
                                     lv_in(11), --�˻�����
                                     lv_in(12), --Ǯ�����
                                     lv_crsubledger, --�ֻ���
                                     av_res, --������������
                                     av_msg --��������������Ϣ
                                     );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_crsubledger.acc_kind IN ('02') AND
       lv_crsubledger.bal <> nvl(lv_in(21), 0) THEN
      --�����˻���Ҫ�ж��ǲ���ͬʱ�����˻�
      av_res := pk_public.cs_res_dberr;
      av_msg := '�˻�����ǰ����ȷ';
      RETURN;
    END IF;
    --ȡ��������Ϣ�Ϳ�������
    pk_public.p_getcardbycardno(lv_crsubledger.card_no, --����
                                lv_card, --��Ƭ������Ϣ
                                av_res, --������������
                                av_msg --��������������Ϣ
                                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    ELSE
      pk_public.p_getcardparabycardtype(lv_card.card_type, --������
                                        lv_cardpara, --��������
                                        av_res, --������������
                                        av_msg --��������������Ϣ
                                        );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
    --�ж�״̬
    /*if lv_crsubledger.acc_state <> '1' then
      av_res := pk_public.cs_res_accstateerr;
      av_msg := '�˻�״̬������';
      return;
    end if;*/
    IF lv_in(14) = cs_pay_source_xy THEN
      --�������ö��
      IF lv_crsubledger.bal + (lv_in(13) - lv_crsubledger.credit_lmt) < 0 THEN
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '�˻�����';
        RETURN;
      ELSE
        lv_credit := lv_in(13) - lv_crsubledger.credit_lmt;
        lv_in(13) := lv_credit;
      END IF;
    ELSIF lv_in(11) IN ('01', '02') THEN
      --��ֵ�޶�

      IF lv_crsubledger.acc_kind = pk_public.cs_acckind_qb THEN
        IF nvl(lv_cardpara.wallet_one_allow_max,0) >0 THEN
           IF  lv_in(13)> nvl(lv_cardpara.wallet_one_allow_max,0) THEN
              av_res := pk_public.cs_res_onerechage_walerr;
              av_msg := '����Ǯ�����ʳ�ֵ�����޶�';
              RETURN;
           END IF;
        END IF;
        IF nvl(lv_cardpara.wallet_case_rechg_lmt, 0) > 0 THEN
          IF lv_in(13) + lv_crsubledger.bal >
             lv_cardpara.wallet_case_rechg_lmt THEN
            av_res := pk_public.cs_res_rechg_exceed_limit;
            av_msg := '����Ǯ����ֵ�����޶�';
            RETURN;
          END IF;
        END IF;

      ELSIF lv_crsubledger.acc_kind = pk_public.cs_acckind_zj THEN

        IF nvl(lv_cardpara.acc_one_allow_max, 0) > 0 THEN
          IF lv_in(13)  >
             lv_cardpara.acc_one_allow_max THEN
            av_res := pk_public.cs_res_onerechage_accerr;
            av_msg := '�ʽ��˻����ʳ�ֵ�����޶�';
            RETURN;
          END IF;
        END IF;

        IF nvl(lv_cardpara.acc_case_rechg_lmt, 0) > 0 THEN
          IF lv_in(13) + lv_crsubledger.bal >
             lv_cardpara.acc_case_rechg_lmt THEN
            av_res := pk_public.cs_res_rechg_exceed_limit;
            av_msg := '�ʽ��˻���ֵ�����޶�';
            RETURN;
          END IF;
        END IF;
      END IF;
      IF lv_in(14) = cs_pay_source_zz THEN
        IF lv_in(13) > lv_cardpara.bank_rechg_lmt THEN
          av_res := pk_public.cs_res_rechg_exceed_limit;
          av_msg := '���п�����Ȧ�泬���޶�';
          RETURN;
        END IF;
      END IF;
      IF lv_in(14) = cs_pay_source_xj THEN
        IF lv_in(13) < lv_cardpara.cash_rechg_low THEN
          av_res := pk_public.cs_res_rechg_exceed_limit;
          av_msg := '�ֽ��ֵ���ܵ�������޶�';
          RETURN;
        END IF;
      END IF;
      IF lv_crsubledger.acc_kind = pk_public.cs_acckind_zj THEN
        IF lv_in(13) < lv_cardpara.cash_rechg_low THEN
          av_res := pk_public.cs_res_rechg_exceed_limit;
          av_msg := '�˻���ֵ���ܵ�������޶�';
          RETURN;
        END IF;
      END IF;
      --�������÷�����
      IF lv_crsubledger.credit_lmt <= lv_crsubledger.bal THEN
        --δ͸֧
        lv_credit := 0;
      ELSE
        --��͸֧��������
        lv_credit := least(lv_in(13),
                           lv_crsubledger.credit_lmt - lv_crsubledger.bal);
      END IF;
    ELSE
      lv_credit := 0;
    END IF;
    av_co_org_id :=lv_operator.org_id;
    IF lv_in(20) = '2' THEN
       av_co_org_id := lv_co_org.co_org_id;
    END IF;
    --д��ˮ
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    pk_business.p_account(lv_dbsubledger, --�跽�˻�
                          lv_crsubledger, --�����˻�
                          NULL, --�跽���潻��ǰ���
                          lv_in(10), --�������潻��ǰ���
                          NULL, --�跽��Ƭ���׼�����
                          lv_in(9), --������Ƭ���׼�����
                          NULL, --�跽�������
                          lv_in(19), --�����������
                          lv_in(13), --���׽��
                          lv_credit, --���÷�����
                          lv_accbookno, --������ˮ��
                          lv_in(2), --���״���
                          lv_crsubledger.org_id, --��������
                          av_co_org_id, --�������
                          lv_in(20), --��������
                          lv_in(5), --��������(�����/�̻��ŵ�)
                          nvl(lv_in(3),'admin'), --������Ա/�ն˺�
                          lv_in(6), --�������κ�
                          lv_in(7), --�ն˽�����ˮ��
                          to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --����ʱ��
                          lv_in(18), --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                          lv_in(1), --ҵ����ˮ��
                          lv_in(17), --��ע
                          lv_clrdate, --�������
                          null,
                          av_debug, --1����
                          av_res, --������������
                          av_msg --��������������Ϣ
                          );

  IF lv_in(20) = '2' THEN   ---����������ֵд�ۺ���־��¼
     insert into tr_serv_rec
      (deal_no,
       deal_code,
       customer_id,
       customer_name,
       card_id,
       card_no,
       card_type,
       card_amt,
       biz_time,
       brch_id,
       user_id,
       clr_date,
       deal_state,
       note,
       urgent_fee,
       cost_fee,
       rsv_one,
       rsv_two,
       rsv_three
       )values(
             lv_in(1),
             lv_in(2), --���״���,
             lv_card.customer_id,
             lv_dbsubledger.acc_name,
             lv_in(8), --����,
             lv_card.card_no,
             lv_card.card_type,
             '1',
             to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'),
             lv_in(5), --��������(�����/�̻��ŵ�)
              nvl(lv_in(3),'admin'), --������Ա/�ն˺�
             lv_clrdate,
             lv_in(18),
             lv_in(17), --��ע
             '0',
             '0',
             '0',
             lv_in(13),
             '0');

         end if;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '��ֵ��������' || SQLERRM;
  END p_recharge;

  /*=======================================================================================*/
  --��ֵȷ��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no|6clr_date|7encryptȷ�Ϻ��˻��������|8ȷ��ǰ���˻��������/9���˻��������
  /*=======================================================================================*/
  PROCEDURE p_rechargeconfirm_onerow(av_in    IN VARCHAR2, --�������
                                     av_debug IN VARCHAR2, --1д������־
                                     av_res   OUT VARCHAR2, --��������
                                     av_msg   OUT VARCHAR2 --����������Ϣ
                                     ) IS
    --lv_count   number;
    lv_in pk_public.myarray; --�����������
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             8, --�������ٸ���
                             8, --����������
                             'pk_recharge.p_rechargeconfirm_onerow', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --�Ҽ�¼ȷ��
    pk_business.p_ashconfirmbyaccbookno(lv_in(6), --�������
                                        lv_in(5), --acc_book_no
                                        NULL, --�跽�������
                                        lv_in(7), --�����������
                                        NULL, --�跽����ǰ���
                                        lv_in(8), --��������ǰ���
                                        av_debug, --1д������־
                                        av_res, --��������
                                        av_msg --����������Ϣ
                                        );
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '��ֵ�Ҽ�¼ȷ�Ϸ�������' || SQLERRM;
  END p_rechargeconfirm_onerow;
  /*=======================================================================================*/
  --��ֵȷ��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no|6clr_date|7card_no|8ȷ�Ϻ��˻��������
  /*=======================================================================================*/
  PROCEDURE p_rechargeconfirm(av_in    IN VARCHAR2, --�������
                              av_debug IN VARCHAR2, --1д������־
                              av_res   OUT VARCHAR2, --��������
                              av_msg   OUT VARCHAR2 --����������Ϣ
                              ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --�����������
    lv_clrdate pay_clr_para.clr_date%TYPE; --�������
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             7, --�������ٸ���
                             8, --����������
                             'pk_recharge.p_rechargeconfirm', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --�Ҽ�¼ȷ��
    pk_business.p_ashconfirm(lv_clrdate, --�������
                             lv_in(5), --ҵ����ˮ��
                             NULL, --�跽�������
                             lv_in(8), --�����������
                             av_debug, --1д������־
                             av_res, --��������
                             av_msg --����������Ϣ
                             );
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '��ֵ�Ҽ�¼ȷ�Ϸ�������' || SQLERRM;
  END p_rechargeconfirm;

  /*=======================================================================================*/
  --��ֵ����
  --    ���ԭ��¼�ǻҼ�¼���Ѽ�¼�ĳɳ���״̬��
  --                ������¼������һ�����ĻҼ�¼��ԭ��¼�ĳɳ���״̬д����ʱ��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no|6clr_date|7card_tr_count|8card_bal|9�������˻��������|10����ǰ���˻����/11����ǰ���˻�����
  /*=======================================================================================*/
  PROCEDURE p_rechargecancel_onerow(av_in    IN VARCHAR2, --�������
                                    av_debug IN VARCHAR2, --1д������־
                                    av_res   OUT VARCHAR2, --��������
                                    av_msg   OUT VARCHAR2 --����������Ϣ
                                    ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --�����������
    lv_clrdate pay_clr_para.clr_date%TYPE; --�������
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             10, --�������ٸ���
                             10, --����������
                             'pk_recharge.p_rechargecancel_onerow', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    IF lv_in(2) = '90901051' THEN
       pk_business.p_daybookcancelbyaccbookno(lv_in(5), --Ҫ����acc_book_no
                                           lv_in(1), --��ҵ����ˮ��
                                           lv_in(6), --������¼���������
                                           lv_clrdate, --��ǰ�������
                                           lv_in(2), --���״���
                                           lv_in(3), --��ǰ��Ա
                                           NULL, --�跽���潻��ǰ���
                                           lv_in(8), --�������潻��ǰ���
                                           NULL, --�跽��Ƭ���׼�����
                                           lv_in(7), --������Ƭ���׼�����
                                           NULL, --�跽�������
                                           lv_in(9), --�����������
                                           NULL, --�跽����ǰ���
                                           lv_in(10), --��������ǰ���
                                           '1', --1ֱ��ȷ��
                                           av_debug, --1д������־
                                           av_res, --��������
                                           av_msg --����������Ϣ
                                           );
    ELSE
      pk_business.p_daybookcancelbyaccbookno(lv_in(5), --Ҫ����acc_book_no
                                           lv_in(1), --��ҵ����ˮ��
                                           lv_in(6), --������¼���������
                                           lv_clrdate, --��ǰ�������
                                           lv_in(2), --���״���
                                           lv_in(3), --��ǰ��Ա
                                           NULL, --�跽���潻��ǰ���
                                           lv_in(8), --�������潻��ǰ���
                                           NULL, --�跽��Ƭ���׼�����
                                           lv_in(7), --������Ƭ���׼�����
                                           NULL, --�跽�������
                                           lv_in(9), --�����������
                                           NULL, --�跽����ǰ���
                                           lv_in(10), --��������ǰ���
                                           '0', --1ֱ��ȷ��
                                           av_debug, --1д������־
                                           av_res, --��������
                                           av_msg --����������Ϣ
                                           );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '��ֵ������������' || SQLERRM;
  END p_rechargecancel_onerow;

  /*=======================================================================================*/
  --��ֵ����
  --    ���ԭ��¼�ǻҼ�¼���Ѽ�¼�ĳɳ���״̬��
  --                ������¼������һ�����ĻҼ�¼��ԭ��¼�ĳɳ���״̬д����ʱ��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no|6clr_date|7card_no|8tr_state|9card_tr_count|10card_bal|11�������˻��������
  /*=======================================================================================*/
  PROCEDURE p_rechargecancel(av_in    IN VARCHAR2, --�������
                             av_debug IN VARCHAR2, --1д������־
                             av_res   OUT VARCHAR2, --��������
                             av_msg   OUT VARCHAR2 --����������Ϣ
                             ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --�����������
    lv_clrdate pay_clr_para.clr_date%TYPE; --�������
    /*lv_cash_box  cash_box%ROWTYPE;
    lv_count NUMBER;*/
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             11, --�������ٸ���
                             11, --����������
                             'pk_recharge.p_rechargecancel', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
     --�ж�β��
     /*SELECT COUNT(1) INTO lv_count FROM cash_box_rec;
     IF lv_count > 0 THEN
       SELECT * INTO lv_cash_box FROM cash_box_rec;
       IF lv_cash_box.td_blc -abs()
     END IF;*/
     
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    IF lv_in(8) = '9' THEN
      --�Ҽ�¼ȡ��
      pk_business.p_ashcancel(lv_clrdate, --�������
                              lv_in(5), --ҵ����ˮ��
                              av_debug, --1д������־
                              av_res, --��������
                              av_msg --����������Ϣ
                              );
    ELSIF lv_in(8) = '0' THEN
      --����������¼
      pk_business.p_daybookcancel(lv_in(5), --Ҫ����ҵ����ˮ��
                                  lv_in(1), --��ҵ����ˮ��
                                  lv_in(6), --������¼���������
                                  lv_clrdate, --��ǰ�������
                                  lv_in(2), --���״���
                                  lv_in(3), --��Ա���
                                  NULL, --�跽���潻��ǰ���
                                  lv_in(10), --�������潻��ǰ���
                                  NULL, --�跽��Ƭ���׼�����
                                  lv_in(9), --������Ƭ���׼�����
                                  NULL, --�跽�������
                                  lv_in(11), --�����������
                                  '1', --1ֱ��ȷ��
                                  av_debug, --1д������־
                                  av_res, --��������
                                  av_msg --����������Ϣ
                                  );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '��ֵ������������' || SQLERRM;
  END p_rechargecancel;

  /*=======================================================================================*/
  --��ֵ������¼�ĳɻҼ�¼״̬
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no  ԭ��ֵ��¼��ҵ����ˮ��
  /*=======================================================================================*/
  PROCEDURE p_rechargecancel2ash(av_in    IN VARCHAR2, --�������
                                 av_debug IN VARCHAR2, --1д������־
                                 av_res   OUT VARCHAR2, --��������
                                 av_msg   OUT VARCHAR2 --����������Ϣ
                                 ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --�����������
    lv_clrdate pay_clr_para.clr_date%TYPE; --�������
    lv_cardno       pay_card_deal_rec.card_no%TYPE; --����
    lv_oldaccbookno acc_inout_detail.old_acc_inout_no%TYPE; --�������ļ�����ˮ��
    --���ݳ����ļ�����ˮ�źͿ���ȡ�������
    FUNCTION f_getoldclrdate(av_accbookno pay_card_deal_rec.acc_inout_no%TYPE,
                             av_cardno    pay_card_deal_rec.card_no%TYPE)
      RETURN VARCHAR2 IS
      lv_month     VARCHAR2(10);
      lv_tablename VARCHAR2(50);
      lv_count     NUMBER;
    BEGIN
      lv_month := substrb(lv_clrdate, 1, 8) || '01';
      WHILE lv_month > '201410' LOOP
        lv_tablename := pk_public.f_gettrcardtable(av_cardno,
                                                   to_date(lv_month,
                                                           'yyyy-mm-dd'));
        EXECUTE IMMEDIATE 'select count(*) from ' || lv_tablename ||
                          ' where acc_inout_no = ' || av_accbookno
          INTO lv_count;
        IF lv_count > 0 THEN
          EXECUTE IMMEDIATE 'select max(clr_date) from ' || lv_tablename ||
                            ' where acc_inout_no = ' || av_accbookno
            INTO lv_month;
          RETURN lv_month;
        ELSE
          lv_month := to_char(add_months(to_date(lv_month, 'yyyy-mm-dd'),
                                         -1),
                              'yyyy-mm-dd');
        END IF;
      END LOOP;
      RETURN NULL;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END f_getoldclrdate;
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             5, --�������ٸ���
                             5, --����������
                             'pk_recharge.p_rechargecancel2ash', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    UPDATE acc_inout_detail
       SET deal_state = '9'
     WHERE deal_no = lv_in(5)
       AND deal_state = '2';
    UPDATE pay_card_deal_rec
       SET deal_state = '9'
     WHERE deal_no = lv_in(5)
       AND deal_state = '2'
    RETURNING MAX(old_acc_inout_no), MAX(card_no) INTO lv_oldaccbookno, lv_cardno;
    --������¼�ĳ����ĳɻҼ�¼����Ҫ����ԭ��ֵ��¼
    IF SQL%ROWCOUNT > 0 THEN
      IF lv_oldaccbookno IS NOT NULL THEN
        DECLARE
          lv_oldclrdate VARCHAR2(10);
          lv_oldtrdate  DATE;
        BEGIN
          lv_oldclrdate := f_getoldclrdate(lv_oldaccbookno, lv_cardno);
          IF lv_oldclrdate IS NOT NULL THEN
            EXECUTE IMMEDIATE 'update acc_daybook_' ||
                              REPLACE(lv_oldclrdate, '-', '') ||
                              ' set tr_state = 1,rev_time = sysdate,note = note || ''_����'' where acc_book_no = ' ||
                              lv_oldaccbookno ||
                              ' returning tr_date into :1'
              RETURNING INTO lv_oldtrdate;
            FOR i IN 0 .. pk_public.cs_cm_card_nums - 1 LOOP
              EXECUTE IMMEDIATE 'update tr_card_' || TRIM(to_char(i, '00')) || '_' ||
                                to_char(lv_oldtrdate, 'yyyymm') ||
                                ' set tr_state = 1,rev_time = sysdate,note = note || ''_����'' where acc_book_no = ' ||
                                lv_oldaccbookno;
            END LOOP;
          END IF;
        END;
      END IF;
    END IF;
    IF av_debug = '1' THEN
      NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '��ֵ������¼�ָ��ɻҼ�¼״̬��������' || SQLERRM;
  END p_rechargecancel2ash;

  /*=======================================================================================*/
  --�˻�����
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acpt_id|6tr_batch_no|7term_tr_no|8card_no|9card_tr_count|10card_bal|11acc_kind|12wallet_id|13tr_amt|
  --       14note|15���ֺ�������|16acpt_type|17���˻�����ǰ���
  /*=======================================================================================*/
  PROCEDURE p_returncash(av_in    IN VARCHAR2, --�������
                         av_debug IN VARCHAR2, --1����
                         av_res   OUT VARCHAR2, --��������
                         av_msg   OUT VARCHAR2 --����������Ϣ
                         ) IS
    --lv_count       number;
    lv_in          pk_public.myarray; --�����������
    lv_dbsubledger acc_account_sub%ROWTYPE; --�跽�ֻ���
    lv_crsubledger acc_account_sub%ROWTYPE; --�����ֻ���
    lv_operator    sys_users%ROWTYPE; --��Ա
    lv_branch      sys_branch%ROWTYPE; --����
    lv_clrdate     pay_clr_para.clr_date%TYPE; --�������
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --������ˮ��
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             16, --�������ٸ���
                             17, --����������
                             'pk_recharge.p_returncash', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    --Ǯ�����Ĭ��00
    lv_in(12) := nvl(lv_in(12), pk_public.cs_defaultwalletid);
    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = lv_in(3);
      SELECT *
        INTO lv_branch
        FROM sys_branch
       WHERE brch_id = lv_operator.brch_id;
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := 'δ�ҵ���Ա���' || lv_in(3);
        RETURN;
    END;
    --ȡ�跽�ֻ���
    pk_public.p_getsubledgerbycardno(lv_in(8), --����
                                     lv_in(11), --�˻�����
                                     lv_in(12), --Ǯ�����
                                     lv_dbsubledger, --�ֻ���
                                     av_res, --������������
                                     av_msg --��������������Ϣ
                                     );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    ELSE
      IF lv_dbsubledger.bal - lv_dbsubledger.credit_lmt < lv_in(13) THEN
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '�˻�����';
        RETURN;
      END IF;
      IF lv_dbsubledger.acc_kind IN ('02') AND
         lv_dbsubledger.bal <> nvl(lv_in(17), 0) THEN
        --�����˻���Ҫ�ж��ǲ���ͬʱ�����˻�
        av_res := pk_public.cs_res_dberr;
        av_msg := '�˻�����ǰ����ȷ';
        RETURN;
      END IF;
    END IF;
    --ȡ�����ֻ���
    --�ֽ�
    lv_crsubledger.item_id := pk_public.cs_accitem_cash;
    IF lv_branch.brch_type = '3' THEN
      --��������
      lv_crsubledger.item_id := pk_public.cs_accitem_brch_prestore;
    END IF;
    if lv_in(2) = '20501190' then
        lv_crsubledger.item_id := pk_public.cs_accitem_org_bank;
        pk_public.p_getorgsubledger(lv_operator.org_id,
                                    lv_crsubledger.item_id,
                                    lv_crsubledger,
                                    av_res,
                                    av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
    else
        pk_public.p_getsubledgerbyclientid(lv_operator.brch_id,
                                           lv_crsubledger.item_id,
                                           lv_crsubledger,
                                           av_res,
                                           av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
    end if;

    --д��ˮ
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    pk_business.p_account(lv_dbsubledger, --�跽�˻�
                          lv_crsubledger, --�����˻�
                          NULL, --�跽���潻��ǰ���
                          lv_in(10), --�������潻��ǰ���
                          NULL, --�跽��Ƭ���׼�����
                          lv_in(9), --������Ƭ���׼�����
                          lv_in(15), --�跽�������
                          NULL, --�����������
                          lv_in(13), --���׽��
                          0, --���÷�����
                          lv_accbookno, --������ˮ��
                          lv_in(2), --���״���
                          lv_crsubledger.org_id, --��������
                          lv_operator.org_id, --�������
                          lv_in(16), --��������
                          lv_in(5), --��������(�����/�̻��ŵ�)
                          lv_in(3), --������Ա/�ն˺�
                          lv_in(6), --�������κ�
                          lv_in(7), --�ն˽�����ˮ��
                          to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --����ʱ��
                          '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                          lv_in(1), --ҵ����ˮ��
                          lv_in(14), --��ע
                          lv_clrdate, --�������
                          null,
                          av_debug, --1����
                          av_res, --������������
                          av_msg --��������������Ϣ
                          );
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�˻����ַ�������' || SQLERRM;
  END p_returncash;
  /*=======================================================================================*/
  --��ֵ������Ԥ���
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acpt_id      �����  Ԥ��������
  --       6tr_batch_no  ���κ�
  --       7term_tr_no   �ն˽�����ˮ��
  --       8tr_amt       ��ֵ���(�������ö��ʱ������ĺ�����ö��)
  --       9pay_source   ��ֵ�ʽ���Դ0�ֽ�1ת��4�������ö��
  --      10note         ��ע
  --      11tr_state     9д�Ҽ�¼0ֱ��д������¼
  --      12acpt_type    ��������
  /*=======================================================================================*/
  PROCEDURE p_recharge2brch(av_in    IN VARCHAR2, --�������
                            av_debug IN VARCHAR2, --1����
                            av_res   OUT VARCHAR2, --��������
                            av_msg   OUT VARCHAR2 --����������Ϣ
                            ) IS
    lv_count       NUMBER;
    lv_in          pk_public.myarray; --�����������
    lv_dbsubledger acc_account_sub%ROWTYPE; --�跽�ֻ���
    lv_crsubledger acc_account_sub%ROWTYPE; --�����ֻ���
    lv_operator    sys_users%ROWTYPE; --��Ա
    lv_branch      sys_branch%ROWTYPE; --����
    lv_clrdate     pay_clr_para.clr_date%TYPE; --�������
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --������ˮ��
    lv_credit      acc_account_sub.credit_lmt%TYPE; --���÷�����
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             11, --�������ٸ���
                             12, --����������
                             'pk_recharge.p_recharge2brch', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    --Ĭ��д������¼
    IF lv_in(11) IS NULL THEN
      lv_in(11) := '0';
    ELSIF lv_in(11) NOT IN ('9', '0') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := 'tr_stateֻ��9��0';
      RETURN;
    END IF;
    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = lv_in(3);
      SELECT *
        INTO lv_branch
        FROM sys_branch
       WHERE brch_id = lv_operator.brch_id;
      IF lv_branch.brch_type = '3' THEN
        av_res := pk_public.cs_res_paravalueerr;
        av_msg := '�����Ǵ�������Ĺ�Ա��' || lv_in(3);
        RETURN;
      END IF;
      SELECT COUNT(*)
        INTO lv_count
        FROM sys_branch
       WHERE brch_id = lv_in(5)
         AND brch_type = '3';
      IF lv_count = 0 THEN
        av_res := pk_public.cs_res_paravalueerr;
        av_msg := '�����Ԥ�������㲻�Ǵ������㣬' || lv_in(5);
        RETURN;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := 'δ�ҵ���Ա���' || lv_in(3);
        RETURN;
    END;
    --Ԥ�������
    IF lv_in(5) IS NULL OR lv_in(5) = lv_operator.brch_id THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := 'Ԥ����������';
      RETURN;
    END IF;
    --ȡ�����ֻ���
    pk_public.p_getsubledgerbyclientid(lv_in(5),
                                       pk_public.cs_accitem_brch_prestore,
                                       lv_crsubledger,
                                       av_res,
                                       av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --ȡ�跽�ֻ���
    IF lv_in(9) = cs_pay_source_xj THEN
      --�ֽ�
      lv_dbsubledger.item_id := pk_public.cs_accitem_cash;
      pk_public.p_getsubledgerbyclientid(lv_operator.brch_id,
                                         lv_dbsubledger.item_id,
                                         lv_dbsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSIF lv_in(9) = cs_pay_source_zz THEN
      --ת��
      lv_dbsubledger.item_id := pk_public.cs_accitem_org_bank;
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  lv_dbsubledger.item_id,
                                  lv_dbsubledger,
                                  av_res,
                                  av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSIF lv_in(9) = cs_pay_source_xy THEN
      --�������ö��
      lv_dbsubledger.item_id := pk_public.cs_accitem_org_credit_chg_out;
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  lv_dbsubledger.item_id,
                                  lv_dbsubledger,
                                  av_res,
                                  av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --�������ö��
      IF lv_crsubledger.bal + (lv_in(8) - lv_crsubledger.credit_lmt) < 0 THEN
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '�˻�����';
        RETURN;
      ELSE
        lv_credit := lv_in(8) - lv_crsubledger.credit_lmt;
        lv_in(8) := lv_credit;
      END IF;
    ELSE
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�������pay_source����';
      RETURN;
    END IF;

    --д��ˮ
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    pk_business.p_account(lv_dbsubledger, --�跽�˻�
                          lv_crsubledger, --�����˻�
                          NULL, --�跽���潻��ǰ���
                          NULL, --�������潻��ǰ���
                          NULL, --�跽��Ƭ���׼�����
                          NULL, --������Ƭ���׼�����
                          NULL, --�跽�������
                          NULL, --�����������
                          lv_in(8), --���׽��
                          nvl(lv_credit, 0), --���÷�����
                          lv_accbookno, --������ˮ��
                          lv_in(2), --���״���
                          lv_crsubledger.org_id, --��������
                          lv_operator.org_id, --�������
                          lv_in(12), --��������
                          lv_operator.brch_id, --��������(�����/�̻��ŵ�)
                          lv_in(3), --������Ա/�ն˺�
                          lv_in(6), --�������κ�
                          lv_in(7), --�ն˽�����ˮ��
                          to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --����ʱ��
                          lv_in(11), --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                          lv_in(1), --ҵ����ˮ��
                          lv_in(10), --��ע
                          lv_clrdate, --�������
                          null,
                          av_debug, --1����
                          av_res, --������������
                          av_msg --��������������Ϣ
                          );
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '��ֵ������Ԥ����˻���������' || SQLERRM;
  END p_recharge2brch;

BEGIN
  -- initialization
  NULL;
END pk_recharge;
/

