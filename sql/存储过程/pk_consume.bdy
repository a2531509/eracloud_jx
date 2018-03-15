CREATE OR REPLACE PACKAGE BODY pk_consume IS
  --���������̻��ն�������ˮ��Ϊ���� tr_state 3��״̬����,ֻ��0���� 1������ 9�Ҽ�¼
  --���� ------acc_daybookд������¼
  --���� ------ԭ��¼�ĳɳ���״̬,����һ������¼ old_action_no дԭ��¼action_no
  --��������---����¼����,����һ���������Ѽ�¼ old_action_no д������¼action_no
  --�˻� ------��������¼ old_action_no дԭ��¼action_no
  --�˻�����---�˻���¼�ĳɳ���״̬,����һ������¼ old_action_no д�˻���¼action_no
  --�������ѣ�
  --1ȡ�˻��б�2ȡ�˻���Ϣ3���Ѽ���4���ѿۿ�5��������6����7�˻�����8�˻�9�˻���������10�˻�����
  --BS_MERCHANT_LIMIT   �̻��޶����ñ�
  --CM_CARD_LIMIT_CONF  ��Ƭ�޶�����

  /*=======================================================================================*/
  --�����̻��� �����˻��б�
  --av_table:code_value code_name
  /*=======================================================================================*/
  PROCEDURE p_getAccKindList(av_bizid IN base_merchant.merchant_id%TYPE, --�̻�����
                             av_table OUT pk_public.t_cur --�˻��б�
                             ) IS
  BEGIN

    /*OPEN av_table FOR
    SELECT code_value, code_name
      FROM sys_code
     WHERE code_type = 'ACC_KIND'
       AND code_value = '02'
    UNION
    SELECT code_value, code_name
      FROM sys_code
     WHERE code_type = 'ACC_KIND'
       AND code_value IN (SELECT acc_kind
                            FROM pay_merchant_acctype t1, base_merchant t2
                           WHERE t1.merchant_id = t2.merchant_id
                             AND t2.merchant_id = av_bizid);*/
    --������Ĭ���˻����̻�����Ч��
    OPEN av_table FOR
      SELECT code_value, code_name
        FROM sys_code
       WHERE code_type = 'ACC_KIND'
         AND code_value IN (SELECT acc_kind
                              FROM pay_merchant_acctype t1
                             WHERE t1.merchant_id = av_bizid);

  END p_getAccKindList;
  /*=======================================================================================*/
  --�����̻��� ��������ģʽ
  --av_table:mode_id mode_name
  /*=======================================================================================*/
  PROCEDURE p_getPayMode(av_bizid IN base_merchant.merchant_id%TYPE, --�̻�����
                         av_table OUT pk_public.t_cur --�˻��б�
                         ) IS
  BEGIN
    OPEN av_table FOR
      select t.mode_id, t.mode_name
        from pay_acctype_sqn t, BASE_MERCHANT_MODE b
       where t.mode_id = b.mode_id
         and b.mode_state = 0
         and b.merchant_id = av_bizid;
  END p_getPayMode;
  /*=======================================================================================*/
  --ȡ�˻���Ϣ
  --av_table:acc_no,acc_kind,acc_name,item_no,acc_state,balance,balance_encrypt,frz_flag,frz_amt,psw
  /*=======================================================================================*/
  PROCEDURE p_getcardacc(av_cardno  VARCHAR2, --����
                         av_acckind VARCHAR2, --�˻�����
                         av_res     OUT VARCHAR2, --������������
                         av_msg     OUT VARCHAR2, --��������������Ϣ
                         av_table   OUT pk_public.t_cur) IS
  BEGIN
    OPEN av_table FOR
      select t1.acc_no,
             t1.acc_kind,
             t1.acc_name,
             t1.item_id,
             t1.acc_state,
             t1.BAL,
             t1.BAL_CRYPT,
             t1.frz_flag,
             t1.frz_amt,
             t2.PAY_PWD
        from acc_account_sub t1, card_baseinfo t2
       where t1.card_no = t2.card_no
         and t1.card_no = av_cardno
         and t1.acc_kind = av_acckind;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := 'ȡ�˻���Ϣ��������' || SQLERRM;
  END p_getcardacc;

  /*=======================================================================================*/
  --��֤�ն�
  /*=======================================================================================*/
  PROCEDURE p_validterm(av_bizid      IN VARCHAR2, --�̻���
                        av_termid     IN VARCHAR2, --�ն˺�
                        av_login_flag IN VARCHAR2, --1���δǩ�����ش���
                        av_res        OUT VARCHAR2, --��������
                        av_msg        OUT VARCHAR2, --����������Ϣ
                        av_merchant   OUT base_merchant%ROWTYPE --�̻�
                        ) IS
  BEGIN
    BEGIN
      SELECT *
        INTO av_merchant
        FROM base_merchant
       WHERE merchant_id = av_bizid
         AND merchant_state = '0';
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_busierr;
        av_msg := '�̻�������';
        RETURN;
    END;
    DECLARE
      lv_login_flag VARCHAR2(10);
    BEGIN
      SELECT login_flag
        INTO lv_login_flag
        FROM base_tag_end
       WHERE own_id = av_bizid
         AND end_id = av_termid
         AND end_state = '1';
      IF av_login_flag = '1' AND lv_login_flag <> '1' THEN
        av_res := pk_public.cs_res_notlogin;
        av_msg := '�ն�δǩ��';
        RETURN;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_termerr;
        av_msg := '�ն˲�����';
        RETURN;
    END;
  END p_validterm;

  /*=======================================================================================*/
  --ȡ�����е�ǩ���������
  /*=======================================================================================*/
  FUNCTION f_getorgfrzamt(av_orgid VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF av_orgid IS NOT NULL THEN
      RETURN 40;
    ELSE
      RETURN 40;
    END IF;
  END f_getorgfrzamt;

  /*=======================================================================================*/
  --��������_����
  --av_in: ���ֶ���|�ָ�
  --       1tr_code    ���״���
  --       2card_no    ����
  --       3tr_amt     ���ѽ��
  --       4mode_no    ����ģʽ
  --       5av_bizid    ����������
  --av_out: �˻��б�acclist
  --      acclist      �˻��б� acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsume_calc(av_in  IN VARCHAR2, --�������
                                 av_res OUT VARCHAR2, --��������
                                 av_msg OUT VARCHAR2, --����������Ϣ
                                 av_out OUT VARCHAR2 --��������
                                 ) IS
    lv_count     NUMBER;
    lv_in        pk_public.myarray; --�����������
    lv_mode      PAY_ACCTYPE_SQN%ROWTYPE; --����ģʽ
    lv_acclist   pk_public.myarray; --�����˻�����
    lv_subledger acc_account_sub%ROWTYPE; --���ֻ���
    lv_tempamt   NUMBER; --�ֻ��˿۷ѽ��
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             5, --�������ٸ���
                             5, --����������
                             'pk_consume.p_onlineconsume_calc', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;

    BEGIN
      if lv_in(4) IS NULL then
        --����ģʽΪ��ʱ���򿴵�ǰ�̻��Ƿ�ֻ��һ������ģʽ�����ж������쳣��һ����ȡ��
        select count(*)
          into lv_count
          from BASE_MERCHANT_MODE t
         where t.merchant_id = lv_in(5)
           and t.mode_state = '0';
        IF lv_count = 0 THEN
           select t.*
                  into lv_mode
                       from PAY_ACCTYPE_SQN t
                       where t.mode_id = '2';
        ELSE
           if lv_count <> 1 then
              av_res := pk_public.cs_res_paravalueerr;
                  av_msg := '���̻��ж�������ģʽ����ָ��ģʽ��������';
                    return;
           end if;
           select t.*
           into lv_mode
                from PAY_ACCTYPE_SQN t
                where t.mode_id = (select b.mode_id
                              from BASE_MERCHANT_MODE b
                             where b.merchant_id = lv_in(5)
                               and t.mode_state = '0');
        END IF;

      else
        --ȡָ��������ģʽ
        SELECT t.*
          INTO lv_mode
          from PAY_ACCTYPE_SQN t
         WHERE t.mode_id = lv_in(4)
           AND t.mode_state = '0';
      end if;
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_paravalueerr;
        av_msg := 'û�и�����ģʽ';
        RETURN;
    END;

    lv_count := pk_public.f_splitstr(lv_mode.ACC_SQN, '|', lv_acclist);
    IF lv_count <= 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '������ģʽû���˺�';
      RETURN;
    END IF;

    --����ÿ���˻����Ѷ���
    FOR i IN 1 .. lv_acclist.count LOOP
      --ȡ���ֻ���
      pk_public.p_getsubledgerbycardno(lv_in(2), --����
                                       lv_acclist(i), --�˻�����
                                       pk_public.cs_defaultwalletid, --Ǯ�����
                                       lv_subledger, --�ֻ���
                                       av_res, --������������
                                       av_msg --��������������Ϣ
                                       );
      IF av_res = pk_public.cs_res_ok THEN
        --����۳����
        IF lv_subledger.bal - lv_subledger.frz_amt >= lv_in(3) THEN
          lv_tempamt := lv_in(3);
        ELSE
          --��ǰ�˻�����ʱ����۳�ȫ�����
          lv_tempamt := lv_subledger.bal - lv_subledger.frz_amt;
        END IF;
        lv_in(3) := lv_in(3) - lv_tempamt;
        --��װ���ز���
        IF lv_tempamt > 0 THEN
          IF av_out IS NOT NULL THEN
            av_out := av_out || ',';
          END IF;
          av_out := av_out || lv_subledger.acc_kind || '$' || lv_tempamt || '$' ||
                    lv_subledger.bal || '$' || lv_subledger.bal_crypt;
        END IF;
        if lv_in(3) = 0 then
          --�����ѽ��Ϊ0�����˳�LOOP
          exit;
        end if;
      END IF;
    END LOOP;
    IF lv_in(3) = 0 THEN
      av_res := pk_public.cs_res_ok;
      av_msg := '';
    ELSE
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '�˻�����';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�����������ѷ�������' || SQLERRM;
  END p_onlineconsume_calc;
  /*=======================================================================================*/
  --��������
  --av_in: ���ֶ���|�ָ�
  --       1action_no    ҵ����ˮ��--�յĻ�ȡ�洢������ȡ����
  --       2tr_code      ������
  --       3oper_id      ����Ա/�ն˺�
  --       4oper_time    ����ʱ��--�յĻ�ȡ�洢������ȡ���ݿ�ʱ��
  --       5acpt_id      �������(����Ż��̻����)
  --       6tr_batch_no  ���κ�
  --       7term_tr_no   �ն˽�����ˮ��
  --       8card_no      ����
  --       9pwd          ���� Ϊ��ʱ���򲻴���
  --      10tr_amt       �ܽ��׽��
  --      11acclist      �˻��б�Ϊ��ʱ�����������м��� acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      12note         ��ע
  --      13acpt_type    ��������
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsume(av_in    IN VARCHAR2, --�������
                            av_debug IN VARCHAR2, --1����
                            av_res   OUT VARCHAR2, --��������
                            av_msg   OUT VARCHAR2, --����������Ϣ
                            av_out   OUT VARCHAR2 --��������
                            ) IS
    lv_count            NUMBER;
    lv_in               pk_public.myarray; --�����������
    lv_acclist          pk_public.myarray; --�˻��б�
    lv_acc              pk_public.myarray; --�˻�
    lv_dbsubledger      acc_account_sub%ROWTYPE; --�跽�ֻ���
    lv_crsubledger      acc_account_sub%ROWTYPE; --�����ֻ���
    lv_clrdate          pay_clr_para.clr_date%type; --�������
    lv_accbookno        ACC_INOUT_DETAIL.ACC_INOUT_NO%TYPE; --������ˮ��
    lv_card             card_baseinfo%ROWTYPE; --��������Ϣ
    lv_merchant         base_merchant%ROWTYPE; --�̻�
    lv_merchantlimit    pay_merchant_lim%ROWTYPE; --�̻������޶��
    lv_detail_tablename varchar(50);
    lv_ACC_CREDIT_LIMIT ACC_CREDIT_LIMIT%ROWTYPE; --���˻����Ʋ���
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             14, --�������ٸ���
                             14, --����������
                             'pk_consume.p_onlineconsume', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --action_no
    IF lv_in(1) IS NULL THEN
      SELECT seq_action_no.nextval INTO lv_in(1) FROM dual;
    END IF;
    --4oper_time
    IF lv_in(4) IS NULL THEN
      lv_in(4) := to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss');
    ELSIF abs(to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss') - SYSDATE) >
          10 / 24 / 60 THEN
      --ʱ�����10����
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�����ҵ��ʱ���ϵͳʱ��������10����';
      RETURN;
    END IF;
    --����action_no clr_date oper_time
    av_out := lv_in(1) || '|' || lv_clrdate || '|' || lv_in(4);
    --ȡ��������Ϣ
    pk_public.p_getcardbycardno(lv_in(8), --����
                                lv_card, --��Ƭ������Ϣ
                                av_res, --������������
                                av_msg --��������������Ϣ
                                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --�жϿ�״̬
    IF lv_card.card_state <> '1' THEN
      av_res := pk_public.cs_res_accstateerr;
      av_msg := '��״̬������';
      RETURN;
    END IF;
    --�ж�����

    /*pk_public.p_judgetradepwd(lv_card, --����Ϣ
                              lv_in(9), --����
                              av_res, --������������
                              av_msg --��������������Ϣ
                              );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;*/

    --����ն��Ƿ�ǩ��
    p_validterm(lv_in(5), --�̻���
                lv_in(3), --�ն˺�
                '1', --1���δǩ�����ش���
                av_res, --��������
                av_msg, --����������Ϣ
                lv_merchant --�̻���clientid
                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    lv_detail_tablename := 'ACC_INOUT_DETAIL_' ||
                           substr(REPLACE(lv_clrdate, '-', ''), 0, 6);
    --�ж��̻������޶�
    BEGIN
      SELECT t.*
        INTO lv_merchantlimit
        FROM pay_merchant_lim t
       WHERE t.merchant_id = lv_merchant.merchant_id;
      --�Ƿ񵥴γ���
      IF lv_merchantlimit.lim_01 > 0 THEN
        IF lv_in(10) > lv_merchantlimit.lim_01 THEN
          av_res := pk_public.cs_res_consume_quotas_amt;
          av_msg := '�̻��������ѳ��޶�';
          RETURN;
        END IF;
      END IF;
      --�Ƿ����Ѵ�������
      if lv_merchantlimit.lim_02 > 0 then
        execute immediate 'select count(DEAL_NO) from ' ||
                          lv_detail_tablename ||
                          ' where DEAL_STATE=0 and DB_CARD_NO=:1 and CLR_DATE=:2 and DEAL_CODE=:3'
          into lv_count
          using lv_in(8), lv_clrdate, lv_in(2);
        if lv_merchantlimit.lim_02 <= lv_count then
          av_res := pk_public.cs_res_consume_quotas_amt;
          av_msg := '���������Ѵ����Ѵ�����';
          return;
        end if;
      end if;
      --�Ƿ������ѽ���
      if lv_merchantlimit.lim_03 > 0 then
        execute immediate 'select sum(DB_AMT) from ' || lv_detail_tablename ||
                          ' where DEAL_STATE=0 and DB_CARD_NO=:1 and CLR_DATE=:2 and DEAL_CODE=:3'
          into lv_count
          using lv_in(8), lv_clrdate, lv_in(2);
        if lv_merchantlimit.lim_03 <= lv_count then
          av_res := pk_public.cs_res_consume_quotas_amt;
          av_msg := '�����������ܶ��Ѵ�����';
          return;
        end if;
      end if;
    EXCEPTION
      WHEN no_data_found THEN
        --δ�����޶�Ͳ��ж�
        NULL;
    END;

    --��֤�����Ƿ��ظ�
    EXECUTE IMMEDIATE 'select count(DEAL_NO) from ' || lv_detail_tablename ||
                      ' where acpt_id=:1 and user_id=:2 and DEAL_BATCH_NO=:3 and END_DEAL_NO=:4 '
      INTO lv_count
      USING lv_in(5), lv_in(3), lv_in(6), lv_in(7);
    IF lv_count > 0 THEN
      av_res := pk_public.cs_res_rowunequalone;
      av_msg := '���������ظ�';
      RETURN;
    END IF;

    --ȡ�����ֻ���
    pk_public.p_getsubledgerbyclientid(lv_merchant.customer_id, --�̻�client_id
                                       pk_public.cs_accitem_biz_clr, --�̻��������
                                       lv_crsubledger,
                                       av_res,
                                       av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;

    lv_count := pk_public.f_splitstr(lv_in(11), ',', lv_acclist);
    IF lv_count = 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '���ѵ��˻��б���Ϊ��';
      RETURN;
    END IF;
    FOR i IN 1 .. lv_acclist.count LOOP
      lv_count := pk_public.f_splitstr(lv_acclist(i), '$', lv_acc);
      --ȡ�跽�ֻ���
      pk_public.p_getsubledgerbycardno(lv_in(8), --����
                                       lv_acc(1), --�˻�����
                                       pk_public.cs_defaultwalletid, --Ǯ�����
                                       lv_dbsubledger, --�ֻ���
                                       av_res, --������������
                                       av_msg --��������������Ϣ
                                       );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      -- �жϿ��˻������޶�
      pk_public.p_judgecardacciftrade(lv_in(8),
                                      lv_acc(1),
                                      abs(lv_acc(2)),
                                      0,
                                      av_res,
                                      av_msg);
      --�ж�
      IF lv_dbsubledger.bal - lv_dbsubledger.credit_lmt < lv_acc(2) THEN
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '�˻�����';
        RETURN;
      END IF;
      --д��ˮ
      SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
      pk_business.p_account(lv_dbsubledger, --�跽�˻�,
                            lv_crsubledger, --�����˻�,
                            NULL, --�跽���潻��ǰ���
                            NULL, --�������潻��ǰ���
                            NULL, --�跽��Ƭ���׼�����
                            NULL, --������Ƭ���׼�����
                            lv_acc(4), --�跽�������
                            NULL, --�����������
                            lv_acc(2), --���׽��
                            0, --���÷�����
                            lv_accbookno, --������ˮ��
                            lv_in(2), --���״���
                            lv_crsubledger.org_id, --��������
                            lv_crsubledger.org_id, --�������
                            lv_in(13), --��������
                            lv_in(5), --��������(�����/�̻��ŵ�)
                            lv_in(3), --������Ա/�ն˺�
                            lv_in(6), --�������κ�
                            lv_in(7), --�ն˽�����ˮ��
                            to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --����ʱ��
                            '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                            lv_in(1), --ҵ����ˮ��
                            lv_in(12), --��ע
                            lv_clrdate, --�������
                            null,
                            av_debug,
                            av_res,
                            av_msg);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�������ѷ�������' || SQLERRM;
  END p_onlineconsume;

  /*=======================================================================================*/
  --�������ѳ���_����
  --av_in: ���ֶ���|�ָ�
  --       1acpt_id      �������(����Ż��̻����)
  --       2oper_id      ����Ա/�ն˺�
  --       3tr_batch_no  ���κ�
  --       4term_tr_no   �ն˽�����ˮ��
  --       5card_no      ����
  --av_out: ԭ����action_no|ԭ����clr_date|�˻��б�acclist
  --      acclist      �˻��б� acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumecancel_calc(av_in  IN VARCHAR2, --�������
                                       av_res OUT VARCHAR2, --��������
                                       av_msg OUT VARCHAR2, --����������Ϣ
                                       av_out OUT VARCHAR2 --��������
                                       ) IS
    lv_in           pk_public.myarray; --�����������
    lv_clrdate      pay_clr_para.clr_date%type; --�������
    lv_cursor       pk_public.t_cur; --�α�
    lv_temp         VARCHAR2(100);
    lv_tablename    VARCHAR2(50);
    lv_actionno     VARCHAR2(20); --ԭ����action_no
    lv_acc_input_no varchar2(50); --������ˮ
    lv_count        NUMBER;
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             5, --�������ٸ���
                             5, --����������
                             'pk_consume.p_onlineconsumecancel_calc', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    lv_tablename := 'ACC_INOUT_DETAIL_' ||
                    substr(REPLACE(lv_clrdate, '-', ''), 0, 6);

    OPEN lv_cursor FOR 'select t1.ACC_INOUT_NO,t1.deal_no,t2.acc_kind || ''$'' || t1.db_amt || ''$'' || t2.bal || ''$'' || t2.bal_crypt ' || --
     ' from ' || lv_tablename || ' t1,acc_account_sub t2' || --
     ' where t1.db_acc_no = t2.acc_no and t1.deal_state = 0 ' || --
     ' and t1.acpt_id = :1 and t1.user_id = :2 and t1.deal_batch_no = :3 and t1.end_deal_no = :4 and t1.db_card_no=:5'
      USING lv_in(1), lv_in(2), lv_in(3), lv_in(4), lv_in(5);
    LOOP
      FETCH lv_cursor
        INTO lv_acc_input_no, lv_actionno, lv_temp;
      EXIT WHEN lv_cursor%NOTFOUND;
      --�����Ƿ���ڳ������������˻��ȼ�¼
      EXECUTE IMMEDIATE 'select count(*) from ' || lv_tablename ||
                        ' where OLD_ACC_INOUT_NO=:1 and DEAL_STATE =0'
        INTO lv_count
        USING lv_acc_input_no;
      if lv_count > 0 then
        av_res := pk_public.cs_res_glideflushesed;
        av_msg := '�����ظ����������';
        RETURN;
      end if;

      IF av_out IS NOT NULL THEN
        av_out := av_out || ',';
      END IF;
      av_out := av_out || lv_temp;
    END LOOP;
    CLOSE lv_cursor;

    IF lv_actionno IS NULL THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := '���Ѽ�¼������';
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    av_out := lv_actionno || '|' || lv_clrdate || '|' || av_out;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�����������ѳ�����������' || SQLERRM;
  END p_onlineconsumecancel_calc;

  /*=======================================================================================*/
  --�������ѳ���_����
  --av_in: ���ֶ���|�ָ�
  --       1acpt_id      �������(����Ż��̻����)
  --       2oper_id      ����Ա/�ն˺�
  --       3tr_batch_no  ���κ�
  --       4action_no   �ն˽�����ˮ��
  --       5amt      ����
  --av_out: ԭ����action_no|ԭ����clr_date|�˻��б�acclist
  --      acclist      �˻��б� acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumeundo_calc(av_in  IN VARCHAR2, --�������
                                     av_res OUT VARCHAR2, --��������
                                     av_msg OUT VARCHAR2, --����������Ϣ
                                     av_out OUT VARCHAR2 --��������
                                     ) IS
    lv_in           pk_public.myarray; --�����������
    lv_clrdate      pay_clr_para.clr_date%type; --�������
    lv_cursor       pk_public.t_cur; --�α�
    lv_temp         VARCHAR2(100);
    lv_tablename    VARCHAR2(50);
    lv_actionno     VARCHAR2(20); --ԭ����action_no
    lv_acc_input_no varchar2(50); --������ˮ
    lv_count        NUMBER;
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             5, --�������ٸ���
                             5, --����������
                             'pk_consume.p_onlineconsumecancel_calc', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    lv_tablename := 'ACC_INOUT_DETAIL_' ||
                    substr(REPLACE(lv_clrdate, '-', ''), 0, 6);

    OPEN lv_cursor FOR 'select t1.ACC_INOUT_NO,t1.deal_no,t2.acc_kind || ''$'' || t1.db_amt || ''$'' || t2.bal || ''$'' || t2.bal_crypt ' || --
     ' from ' || lv_tablename || ' t1,acc_account_sub t2' || --
     ' where t1.db_acc_no = t2.acc_no and t1.deal_state = 0 ' || --
     ' and t1.acpt_id = :1 and t1.user_id = :2 and t1.deal_batch_no = :3 and t1.deal_no = :4'
      USING lv_in(1), lv_in(2), lv_in(3), lv_in(4);
    LOOP
      FETCH lv_cursor
        INTO lv_acc_input_no, lv_actionno, lv_temp;
      EXIT WHEN lv_cursor%NOTFOUND;
      --�����Ƿ���ڳ������������˻��ȼ�¼
      EXECUTE IMMEDIATE 'select count(*) from ' || lv_tablename ||
                        ' where OLD_ACC_INOUT_NO=:1 and DEAL_STATE =0'
        INTO lv_count
        USING lv_acc_input_no;
      if lv_count > 0 then
        av_res := pk_public.cs_res_glideflushesed;
        av_msg := '�����ظ����������';
        RETURN;
      end if;

      IF av_out IS NOT NULL THEN
        av_out := av_out || ',';
      END IF;
      av_out := av_out || lv_temp;
    END LOOP;
    CLOSE lv_cursor;

    IF lv_actionno IS NULL THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := '���Ѽ�¼������';
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    av_out := lv_actionno || '|' || lv_clrdate || '|' || av_out;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�����������ѳ�����������' || SQLERRM;
  END p_onlineconsumeundo_calc;
  /*=======================================================================================*/
  --�������ѳ���
  --av_in: ���ֶ���|�ָ�
  --       1action_no    ҵ����ˮ��
  --       2tr_code      ������
  --       3oper_id      ����Ա/�ն˺�
  --       4oper_time    ����ʱ��
  --       5acpt_id      �������(����Ż��̻����)
  --       6tr_batch_no  ���κ�
  --       7term_tr_no   �ն˽�����ˮ��
  --       8card_no      ����
  --       9tr_amt       �ܽ��׽��
  --      10acclist      �˻��б� acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      11action_no    ��������action_no
  --      12clr_date     ��������¼��clr_date
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumecancel(av_in    IN VARCHAR2, --�������
                                  av_debug IN VARCHAR2, --1����
                                  av_res   OUT VARCHAR2, --��������
                                  av_msg   OUT VARCHAR2, --����������Ϣ
                                  av_out   OUT VARCHAR2 --��������
                                  ) IS
    lv_count      NUMBER;
    lv_in         pk_public.myarray; --�����������
    lv_acclist    pk_public.myarray; --�˻��б�
    lv_acc        pk_public.myarray; --�˻�
    lv_clrdate    pay_clr_para.clr_date%type; --�������
    lv_daybook    acc_inout_detail%ROWTYPE;
    lv_onedayBook acc_inout_detail%ROWTYPE;
    lv_sumamt     NUMBER; --�������ϸ�ܽ��
    lv_merchant   base_merchant%ROWTYPE; --�̻�
    lv_tablename  VARCHAR2(50);
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             12, --�������ٸ���
                             12, --����������
                             'pk_consume.p_onlineconsumecancel', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    --action_no
    IF lv_in(1) IS NULL THEN
      SELECT seq_action_no.nextval INTO lv_in(1) FROM dual;
    END IF;
    IF lv_in(4) IS NULL THEN
      lv_in(4) := to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss');
    ELSIF abs(to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss') - SYSDATE) >
          10 / 24 / 60 THEN
      --ʱ�����10����
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�����ҵ��ʱ���ϵͳʱ��������10����';
      RETURN;
    END IF;
    --����action_no clr_date oper_time
    av_out := lv_in(1) || '|' || lv_clrdate || '|' || lv_in(4);

    lv_count := pk_public.f_splitstr(lv_in(10), ',', lv_acclist);
    IF lv_count = 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�˻��б���Ϊ��';
      RETURN;
    END IF;

    --����ն��Ƿ�ǩ��
    p_validterm(lv_in(5), --�̻���
                lv_in(3), --�ն˺�
                '1', --1���δǩ�����ش���
                av_res, --��������
                av_msg, --����������Ϣ
                lv_merchant --�̻���clientid
                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;

    lv_tablename := 'ACC_INOUT_DETAIL_' ||
                    substr(REPLACE(lv_clrdate, '-', ''), 0, 6);
    lv_sumamt    := 0;
    FOR i IN 1 .. lv_acclist.count LOOP
      lv_count := pk_public.f_splitstr(lv_acclist(i), '$', lv_acc);
      EXECUTE IMMEDIATE 'select * from ' || lv_tablename ||
                        ' where deal_no = :1 and db_acc_kind = :2 and DEAL_STATE = 0'
        INTO lv_daybook
        USING lv_in(11), lv_acc(1);
      pk_business.p_daybookcancel_onerow(lv_daybook, --Ҫ����daybook
                                         NULL, --sys_operator
                                         lv_in(1), --��ҵ����ˮ��
                                         lv_in(12), --������¼���������
                                         lv_clrdate, --��ǰ�������
                                         lv_in(2), --���״���
                                         NULL, --�跽���潻��ǰ���
                                         NULL, --�������潻��ǰ���
                                         NULL, --�跽��Ƭ���׼�����
                                         NULL, --������Ƭ���׼�����
                                         lv_acc(4), --�跽�������
                                         NULL, --�����������
                                         lv_acc(3) - lv_acc(2), --�跽����ǰ���
                                         NULL, --��������ǰ���
                                         '1', --1ֱ��ȷ��
                                         av_debug, --1д������־
                                         av_res, --��������
                                         av_msg --����������Ϣ
                                         );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      lv_sumamt := lv_sumamt + lv_acc(2);
    END LOOP;
    IF lv_sumamt <> lv_in(9) THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '����������ܽ�����ϸ�еĽ�һ��';
      RETURN;
    END IF;
    EXECUTE IMMEDIATE 'select count(*) from acc_inout_detail_' ||
                      REPLACE(substr(lv_in(12), 0, 7), '-', '') ||
                      ' where deal_no = :1 and db_amt > 0 and deal_state = 0'
      INTO lv_count
      USING lv_in(11);
    IF lv_count <> 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '���ܲ��ֳ���';
      RETURN;
    END IF;
    -- ���³�����ˮΪ������ն���ˮ,���򱣴����ԭ���׵��ն���ˮ
    EXECUTE IMMEDIATE 'update  ' || lv_tablename ||
                      ' set end_deal_no = :1  where deal_no = :2'
      USING lv_in(7), lv_in(1);
    EXECUTE IMMEDIATE 'update  pay_card_deal_rec_' ||
                      substr(REPLACE(lv_clrdate, '-', ''), 0, 6) ||
                      ' set end_deal_no = :1  where deal_no = :2'
      USING lv_in(7), lv_in(1);

    -- ��������ļ�¼��old_acc_inout_no����Ҫ�޸�old_acc_inout_no
    --�ļ�¼Ϊ����״̬��ͬʱ�޸�pay_card_deal_rec
    IF lv_daybook.old_acc_inout_no IS NOT NULL THEN
      ---������ʼ������ˮ
      EXECUTE IMMEDIATE 'select * from ' || lv_tablename ||
                        ' where acc_inout_no = :1'
        INTO lv_onedayBook
        USING lv_daybook.old_acc_inout_no;

      EXECUTE IMMEDIATE 'update  ' || lv_tablename ||
                        ' set deal_state = 0  where deal_no = :1'
        USING lv_onedayBook.deal_no;
      EXECUTE IMMEDIATE 'update  pay_card_deal_rec_' ||
                        substr(REPLACE(lv_clrdate, '-', ''), 0, 6) ||
                        ' set deal_state = 0  where deal_no = :1'
        USING lv_onedayBook.deal_no;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�������ѳ�����������' || SQLERRM;
  END p_onlineconsumecancel;

  /*=======================================================================================*/
  --���������˻�_����
  --av_in: ���ֶ���|�ָ�
  --       1action_no    ���Ѽ�¼��ҵ����ˮ��
  --       2card_no      ����
  --       3clr_date     ���Ѽ�¼���������
  --       4tr_amt       �˻����
  --       av_out: �˻��б�acclist
  --      acclist      �˻��б� acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumereturn_calc(av_in  IN VARCHAR2, --�������
                                       av_res OUT VARCHAR2, --��������
                                       av_msg OUT VARCHAR2, --����������Ϣ
                                       av_out OUT VARCHAR2 --��������
                                       ) IS
    lv_in              pk_public.myarray; --�����������
    lv_clrdate         pay_clr_para.clr_date%TYPE; --�������
    lv_cursor          pk_public.t_cur; --�α�
    lv_tablename       VARCHAR2(50);
    lv_totaltemp       NUMBER; --���˻���� ��ʱ������������ÿ���˻����۳�
    lv_amt             NUMBER; --�ֻ����˻����
    lv_balance         NUMBER; --�ֻ����˻�ǰ���
    lv_balance_encrypt ACC_ACCOUNT_SUB.Bal_Crypt%TYPE; --�ֻ����˻�ǰ�������
    lv_acckind         acc_account_sub.acc_kind%type; --�˻�����
    lv_count           NUMBER;
    lv_acc_input_no    varchar2(50); --������ˮ
    lv_temp            VARCHAR2(100);
    lv_actionno        VARCHAR2(20); --ԭ����action_no
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             4, --�������ٸ���
                             4, --����������
                             'pk_consume.p_onlineconsumereturn_calc', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    lv_clrdate   := lv_in(3);
    lv_totaltemp := lv_in(4);

    /* lv_tablename := 'ACC_INOUT_DETAIL_' ||
    substr(REPLACE(lv_clrdate, '-', ''), 0, 6);*/
    --�˴�Ϊ20160302Ϊ��Ӧ�����޸�
    /*IF length(REPLACE(lv_clrdate,'-','')) = 8 THEN
        lv_tablename := 'ACC_INOUT_DETAIL_' || substr(REPLACE(lv_clrdate, '-', ''), 1, 6);
    --ELSIF length(REPLACE(lv_clrdate,'-','')) = 8
    ELSE
        lv_tablename := 'ACC_INOUT_DETAIL_2016' || substr(REPLACE(lv_clrdate, '-', ''), 0, 2);
    END IF;  */

    lv_tablename := 'ACC_INOUT_DETAIL_' || substr(REPLACE(lv_clrdate, '-', ''), 1, 6);
    --�ж����޳������˻���¼

    OPEN lv_cursor FOR 'select t1.ACC_INOUT_NO,t1.deal_no,t2.acc_kind || ''$'' || t1.db_amt || ''$'' || t2.bal || ''$'' || t2.bal_crypt ' || --
     ' from ' || lv_tablename || ' t1,acc_account_sub t2' || --
     ' where t1.db_acc_no = t2.acc_no and t1.deal_state = 0 ' || --
     ' and t1.acpt_id = :1 and t1.user_id = :2 and t1.deal_batch_no = :3 and t1.end_deal_no = :4 and t1.db_card_no=:5'
      USING lv_in(1), lv_in(2), lv_in(3), lv_in(4), lv_in(5);
    LOOP
      FETCH lv_cursor
        INTO lv_acc_input_no, lv_actionno, lv_temp;
      EXIT WHEN lv_cursor%NOTFOUND;
      --�����Ƿ���ڳ������������˻��ȼ�¼
      EXECUTE IMMEDIATE 'select count(*) from ' || lv_tablename ||
                        ' where OLD_ACC_INOUT_NO=:1 and DEAL_STATE =0'
        INTO lv_count
        USING lv_acc_input_no;
      if lv_count > 0 then
        av_res := pk_public.cs_res_glideflushesed;
        av_msg := '��ˮ�ѳ��������ɽ����˻�';
        RETURN;
      end if;

      IF av_out IS NOT NULL THEN
        av_out := av_out || ',';
      END IF;
      av_out := av_out || lv_temp;
    END LOOP;

    --������ʱ�Ŀ۷�˳�����˻�
    OPEN lv_cursor FOR 'select t1.db_amt - nvl(t1.returnamt,0) as amt,t2.acc_kind,t2.bal,t2.BAL_CRYPT from ' || lv_tablename || ' t1,acc_account_sub t2' || --
     ' where t1.db_acc_no = t2.acc_no and t1.DEAL_STATE = 0 and t1.db_amt > 0 ' || --
     ' and t1.DEAL_NO = :1 order by ACC_INOUT_NO desc'
      USING lv_in(1);
    LOOP
      FETCH lv_cursor
        INTO lv_amt, lv_acckind, lv_balance, lv_balance_encrypt;
      EXIT WHEN lv_cursor%NOTFOUND;

      IF lv_amt >= lv_totaltemp THEN
        --������� > ���˻����
        lv_amt       := lv_totaltemp;
        lv_totaltemp := 0;
      ELSE
        --���ѽ�� < ���˻����
        lv_totaltemp := lv_totaltemp - lv_amt;
      END IF;
      IF lv_amt > 0 THEN
        IF av_out IS NOT NULL THEN
          av_out := av_out || ',';
        END IF;
        av_out := av_out || lv_acckind || '$' || lv_amt || '$' ||
                  lv_balance || '$' || lv_balance_encrypt;
      END IF;
    END LOOP;
    CLOSE lv_cursor;

    IF av_out IS NULL THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := '���Ѽ�¼������';
      RETURN;
    END IF;
    IF lv_totaltemp > 0 THEN
      av_res := pk_public.cs_res_cancelfeeerr;
      av_msg := '���˻������������ѽ��';
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�������������˻���������' || SQLERRM;
  END p_onlineconsumereturn_calc;

  /*=======================================================================================*/
  --���������˻�
  --av_in: ���ֶ���|�ָ�
  --       1action_no    ҵ����ˮ��
  --       2tr_code      ������
  --       3oper_id      ����Ա/�ն˺�
  --       4oper_time    ����ʱ��
  --       5acpt_id      �������(����Ż��̻����)
  --       6tr_batch_no  ���κ�
  --       7term_tr_no   �ն˽�����ˮ��
  --       8card_no      ����
  --       9tr_amt       �ܽ��׽��
  --      10acclist      �˻��б� acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      11action_no    ���˻���action_no
  --      12clr_date     ���˻���¼��clr_date
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumereturn(av_in    IN VARCHAR2, --�������
                                  av_debug IN VARCHAR2, --1����
                                  av_res   OUT VARCHAR2, --��������
                                  av_msg   OUT VARCHAR2, --����������Ϣ
                                  av_out   OUT VARCHAR2 --��������
                                  ) IS
    lv_count       NUMBER;
    lv_tablename   VARCHAR2(50);
    lv_in          pk_public.myarray; --�����������
    lv_acclist     pk_public.myarray; --�˻��б�
    lv_acc         pk_public.myarray; --�˻�
    lv_clrdate     pay_clr_para.clr_date%TYPE; --�������
    lv_daybook     acc_inout_detail%ROWTYPE;
    lv_sumamt      NUMBER; --�������ϸ�ܽ��
    lv_dbsubledger acc_account_sub%ROWTYPE; --�跽�ֻ���
    lv_crsubledger acc_account_sub%ROWTYPE; --�����ֻ���
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --������ˮ��
    lv_merchant    base_merchant%ROWTYPE; --�̻�
    lv_trdate      DATE; --���Ѽ�¼�Ľ���ʱ��
    lv_cardno      card_baseinfo%ROWTYPE;
    lv_cardconfig  card_config%ROWTYPE;
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             12, --�������ٸ���
                             12, --����������
                             'pk_consume.p_onlineconsumereturn', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    --action_no
    IF lv_in(1) IS NULL THEN
      SELECT seq_action_no.nextval INTO lv_in(1) FROM dual;
    END IF;
    -- 20160302��Ӧ���޸�
    lv_in(4) := to_char(SYSDATE,'yyyy-mm-dd hh24:mi:ss') ;--'20' || lv_in(4);
    --lv_in(12) := '2016' || lv_in(12);
    /*IF lv_in(4) IS NULL THEN
      lv_in(4) := to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss');
    ELSIF abs(to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss') - SYSDATE) >
          10 / 24 / 60 THEN
      --ʱ�����10����
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�����ҵ��ʱ���ϵͳʱ��������10����';
      RETURN;
    END IF;*/
    --����action_no clr_date oper_time
    av_out := lv_in(1) || '|' || lv_clrdate || '|' || lv_in(4);

    lv_count := pk_public.f_splitstr(lv_in(10), ',', lv_acclist);
    IF lv_count = 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�˻��б���Ϊ��';
      RETURN;
    END IF;

    --����ն��Ƿ�ǩ��
    p_validterm(lv_in(5), --�̻���
                lv_in(3), --�ն˺�
                '1', --1���δǩ�����ش���
                av_res, --��������
                av_msg, --����������Ϣ
                lv_merchant --�̻���clientid
                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;

    lv_sumamt := 0;
    FOR i IN 1 .. lv_acclist.count LOOP
      lv_count := pk_public.f_splitstr(lv_acclist(i), '$', lv_acc);
      EXECUTE IMMEDIATE 'select * from acc_inout_detail_' ||
                        substr(REPLACE(lv_in(12), '-', ''), 0, 6) ||
                        ' where deal_no = :1 and db_acc_kind = :2 and deal_state = 0'
        INTO lv_daybook
        USING lv_in(11), lv_acc(1);

      --ȡ�跽�ֻ���
      pk_public.p_getsubledgerbycardno(lv_daybook.db_card_no, --����
                                       lv_daybook.db_acc_kind, --�˻�����
                                       pk_public.cs_defaultwalletid, --Ǯ�����
                                       lv_dbsubledger, --�ֻ���
                                       av_res, --������������
                                       av_msg --��������������Ϣ
                                       );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      -- �ж��˻����Ƿ��˻�����Ƿ�ﵽ����޶�
      BEGIN
        SELECT *
          INTO lv_cardno
          FROM card_baseinfo t
         WHERE t.card_no = lv_daybook.db_card_no;
        IF lv_cardno.card_type IS NOT NULL THEN
          SELECT *
            INTO lv_cardconfig
            FROM card_config b
           WHERE b.card_type = lv_cardno.card_type;

          IF abs(lv_acc(2)) + lv_dbsubledger.bal >
             lv_cardconfig.ACC_CASE_RECHG_LMT THEN
            av_res := pk_public.cs_res_rechg_exceed_limit;
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      --ȡ�����ֻ���
      pk_public.p_getsubledgerbyclientid(lv_daybook.cr_customer_id, --�̻�client_id
                                         pk_public.cs_accitem_biz_clr, --�̻��������
                                         lv_crsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
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
                            lv_acc(4), --�跽�������
                            NULL, --�����������
                            -lv_acc(2), --���׽��
                            0, --���÷�����
                            lv_accbookno, --������ˮ��
                            lv_in(2), --���״���
                            lv_crsubledger.org_id, --��������
                            lv_crsubledger.org_id, --�������
                            lv_daybook.acpt_type, --��������
                            lv_daybook.acpt_id, --��������(�����/�̻��ŵ�)
                            lv_in(3), --������Ա/�ն˺�
                            lv_in(6), --�������κ�
                            lv_in(7), --�ն˽�����ˮ��
                            to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --����ʱ��
                            '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                            lv_in(1), --ҵ����ˮ��
                            '�˻���ԭacc_book_no:' || lv_daybook.acc_inout_no, --��ע
                            lv_clrdate, --�������
                            lv_daybook.acc_inout_no,
                            av_debug, --1����
                            av_res, --������������
                            av_msg --��������������Ϣ
                            );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --����daybookԭ��¼���˻����
      EXECUTE IMMEDIATE 'update acc_inout_detail_' ||
                        substr(REPLACE(lv_in(12), '-', ''), 0, 6) ||
                        ' set returnamt = nvl(returnamt,0) + :1 where deal_no = :2 and db_acc_kind = :3 and deal_state = 0 returning deal_date into :4'
        USING lv_acc(2), lv_daybook.deal_no, lv_daybook.db_acc_kind
        RETURNING INTO lv_trdate;

      --����tr_cardԭ��¼���˻����
      lv_tablename := 'pay_card_deal_rec_' ||
                      substr(REPLACE(lv_in(12), '-', ''), 0, 6);
      EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                        ' set returnamt = nvl(returnamt,0) + :1 where deal_no = :2 and acc_kind = :3 and deal_state = 0'
        USING lv_acc(2), lv_daybook.deal_no, lv_daybook.db_acc_kind;

      lv_sumamt := lv_sumamt + lv_acc(2);
    END LOOP;
    IF lv_sumamt <> lv_in(9) THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '����������ܽ�����ϸ�еĽ�һ��';
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '���������˻���������' || SQLERRM;
  END p_onlineconsumereturn;

  /*=======================================================================================*/
  --�������ѳ���_����
  --av_in: ���ֶ���|�ָ�
  --       1acpt_id      �������(����Ż��̻����)
  --       2oper_id      ����Ա/�ն˺�
  --       3tr_batch_no  ���κ�
  --       4term_tr_no   �ն˽�����ˮ��
  --       5card_no      ����
  --       av_out: ԭ�˻�action_no|ԭ�˻�clr_date|�˻��б�acclist
  --      acclist      �˻��б� acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlinereturncancel_calc(av_in  IN VARCHAR2, --�������
                                      av_res OUT VARCHAR2, --��������
                                      av_msg OUT VARCHAR2, --����������Ϣ
                                      av_out OUT VARCHAR2 --��������
                                      ) IS
    --lv_count     number;
    lv_in        pk_public.myarray; --�����������
    lv_clrdate   pay_clr_para.clr_date%TYPE; --�������
    lv_cursor    pk_public.t_cur; --�α�
    lv_temp      VARCHAR2(100);
    lv_tablename VARCHAR2(50);
    lv_actionno  VARCHAR2(20); --ԭ����action_no
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             5, --�������ٸ���
                             5, --����������
                             'pk_consume.p_onlinereturncancel_calc', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    lv_tablename := 'ACC_INOUT_DETAIL_' ||
                    substr(REPLACE(lv_clrdate, '-', ''), 0, 6);

    OPEN lv_cursor FOR 'select t1.deal_no,t2.acc_kind || ''$'' || t1.db_amt || ''$'' || t2.balance || ''$'' || t2.balance_encrypt ' || --
     ' from ' || lv_tablename || ' t1,acc_account_sub t2' || --
     ' where t1.db_acc_no = t2.acc_no and t1.deal_state = 0 and db_amt < 0 ' || --
     ' and t1.acpt_id = :1 and t1.oper_id = :2 and t1.tr_batch_no = :3 and t1.end_deal_no = :4'
      USING lv_in(1), lv_in(2), lv_in(3), lv_in(4);
    LOOP
      FETCH lv_cursor
        INTO lv_actionno, lv_temp;
      EXIT WHEN lv_cursor%NOTFOUND;
      IF av_out IS NOT NULL THEN
        av_out := av_out || ',';
      END IF;
      av_out := av_out || lv_temp;
    END LOOP;
    CLOSE lv_cursor;

    IF lv_actionno IS NULL THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := '�����˻���¼������';
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    av_out := lv_actionno || '|' || lv_clrdate || '|' || av_out;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�������������˻�������������' || SQLERRM;
  END p_onlinereturncancel_calc;
  /*=======================================================================================*/
  --���������˻�����
  --av_in: ���ֶ���|�ָ�
  --       1action_no    ҵ����ˮ��
  --       2tr_code      ������
  --       3oper_id      ����Ա/�ն˺�
  --       4oper_time    ����ʱ��
  --       5acpt_id      �������(����Ż��̻����)
  --       6tr_batch_no  ���κ�
  --       7term_tr_no   �ն˽�����ˮ��
  --       8card_no      ����
  --       9tr_amt       �ܽ��׽��
  --      10acclist      �˻��б� acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      11action_no    ��������action_no
  --      12clr_date     ��������¼��clr_date
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlinereturncancel(av_in    IN VARCHAR2, --�������
                                 av_debug IN VARCHAR2, --1����
                                 av_res   OUT VARCHAR2, --��������
                                 av_msg   OUT VARCHAR2, --����������Ϣ
                                 av_out   OUT VARCHAR2 --��������
                                 ) IS
    lv_count     NUMBER;
    lv_tablename VARCHAR2(50);
    lv_in        pk_public.myarray; --�����������
    lv_acclist   pk_public.myarray; --�˻��б�
    lv_acc       pk_public.myarray; --�˻�
    lv_clrdate   pay_clr_para.clr_date%TYPE; --�������
    lv_daybook   acc_inout_detail%ROWTYPE;
    lv_sumamt    NUMBER; --�������ϸ�ܽ��
    lv_merchant  base_merchant%ROWTYPE; --�̻�
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             13, --�������ٸ���
                             13, --����������
                             'pk_consume.p_onlinereturncancel', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    --action_no
    IF lv_in(1) IS NULL THEN
      SELECT seq_action_no.nextval INTO lv_in(1) FROM dual;
    END IF;
    IF lv_in(4) IS NULL THEN
      lv_in(4) := to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss');
    ELSIF abs(to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss') - SYSDATE) >
          10 / 24 / 60 THEN
      --ʱ�����10����
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�����ҵ��ʱ���ϵͳʱ��������10����';
      RETURN;
    END IF;
    --����action_no clr_date oper_time
    av_out := lv_in(1) || '|' || lv_clrdate || '|' || lv_in(4);

    lv_count := pk_public.f_splitstr(lv_in(11), ',', lv_acclist);
    IF lv_count = 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�˻��б���Ϊ��';
      RETURN;
    END IF;

    --����ն��Ƿ�ǩ��
    p_validterm(lv_in(5), --�̻���
                lv_in(3), --�ն˺�
                '1', --1���δǩ�����ش���
                av_res, --��������
                av_msg, --����������Ϣ
                lv_merchant --�̻���clientid
                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;

    lv_sumamt := 0;
    FOR i IN 1 .. lv_acclist.count LOOP
      lv_count := pk_public.f_splitstr(lv_acclist(i), '$', lv_acc);
      EXECUTE IMMEDIATE 'select * from acc_inout_detail_' ||
                        REPLACE(lv_in(12), '-', '') ||
                        ' where deal_no = :1 and db_acc_kind = :2 and deal_state = 0'
        INTO lv_daybook
        USING lv_in(11), lv_acc(1);
      pk_business.p_daybookcancel_onerow(lv_daybook, --Ҫ����daybook
                                         NULL, --sys_operator
                                         lv_in(1), --��ҵ����ˮ��
                                         lv_in(13), --������¼���������
                                         lv_clrdate, --��ǰ�������
                                         lv_in(2), --���״���
                                         NULL, --�跽���潻��ǰ���
                                         NULL, --�������潻��ǰ���
                                         NULL, --�跽��Ƭ���׼�����
                                         NULL, --������Ƭ���׼�����
                                         lv_acc(4), --�跽�������
                                         NULL, --�����������
                                         lv_acc(3) - lv_acc(2), --�跽����ǰ���
                                         NULL, --��������ǰ���
                                         '1', --1ֱ��ȷ��
                                         av_debug, --1д������־
                                         av_res, --��������
                                         av_msg --����������Ϣ
                                         );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --�������Ѽ�¼�е��˻���� (�˻���¼��lv_daybook.db_amt�Ǹ���)
      EXECUTE IMMEDIATE 'update acc_inout_detail_' ||
                        substr(REPLACE(lv_clrdate, '-', ''), 0, 6) ||
                        ' set returnamt = nvl(returnamt,0) + :1 where acc_inout_no = :2 and deal_state = 0'
        USING lv_daybook.db_amt, lv_daybook.old_acc_inout_no;
      --����tr_card���Ѽ�¼���˻����
      lv_tablename := 'pay_card_deal_rec_' ||
                      substr(REPLACE(lv_clrdate, '-', ''), 0, 6);
      EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                        ' set returnamt = nvl(returnamt,0) + :1 where acc_inout_no = :2 and deal_state = 0'
        USING lv_daybook.db_amt, lv_daybook.old_acc_inout_no;

      lv_sumamt := lv_sumamt + lv_acc(2);
    END LOOP;
    IF lv_sumamt <> lv_in(9) THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '����������ܽ�����ϸ�еĽ�һ��';
      RETURN;
    END IF;
    EXECUTE IMMEDIATE 'select count(*) from acc_inout_detail_' ||
                      REPLACE(lv_in(12), '-', '') ||
                      ' where deal_no = :1 and db_amt < 0 and deal_state = 0'
      INTO lv_count
      USING lv_in(12);
    IF lv_count <> 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '���ܲ��ֳ���';
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�������ѳ�����������' || SQLERRM;
  END p_onlinereturncancel;

  /*=======================================================================================*/
  --POS����
  --av_in: ���ֶ���|�ָ�
  --       1acpt_id      �̻����
  --       2oper_id      �ն˱��
  --       3tr_batch_no  ���κ�
  --       4consumecount ���ѱ���
  --       5consumeamt   ���ѽ��
  --       6returncount  �˻�����
  --       7returnamt    �˻����
  --       8startdate    ��ʼ����yyyy-mm-dd
  --       9enddate      ��������yyyy-mm-dd
  --      10rechgcount   ��ֵ����
  --      11rechgamt     ��ֵ���
  --av_out:���ֶ���|�ָ�
  --       1consumecount ���ѱ���
  --       2consumeamt   ���ѽ��
  --       3returncount  �˻�����
  --       4returnamt    �˻����
  --       5rechgcount   ��ֵ����
  --       6rechgamt     ��ֵ���
  /*=======================================================================================*/
  /*PROCEDURE p_posBalanceAccount(av_in  IN VARCHAR2, --�������
                                av_res OUT VARCHAR2, --��������
                                av_msg OUT VARCHAR2, --����������Ϣ
                                av_out OUT VARCHAR2 --��������
                                ) IS
    lv_clrdate        pay_clr_para.clr_date%TYPE; --�������
    lv_in             pk_public.myarray; --�����������
    lv_balanceaccount tr_posbalanceaccount%ROWTYPE;
    lv_tempnum        NUMBER;
    lv_tempamt        NUMBER;
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             11, --�������ٸ���
                             11, --����������
                             'pk_consume.p_posBalanceAccount', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM clr_control_para;
    IF lv_in(8) IS NULL THEN
      --��ʼ���ڿգ���ȡ�������ǰ3��
      lv_in(8) := to_char(to_date(lv_clrdate, 'yyyy-mm-dd') - 3,
                          'yyyy-mm-dd');
    END IF;
    --��ǰ���һ��
    lv_in(8) := to_char(to_date(lv_in(8), 'yyyy-mm-dd') - 1, 'yyyy-mm-dd');
    IF lv_in(9) IS NULL THEN
      --�������ڿգ���ȡ�������
      lv_in(9) := lv_clrdate;
    END IF;
    lv_clrdate := lv_in(8);
    SELECT seq_comp_ser_no.nextval
      INTO lv_balanceaccount.comp_ser_no
      FROM dual;
    lv_balanceaccount.biz_id         := lv_in(1);
    lv_balanceaccount.term_id        := lv_in(2);
    lv_balanceaccount.tr_batch_no    := lv_in(3);
    lv_balanceaccount.stat_cns_num   := 0;
    lv_balanceaccount.stat_cns_amt   := 0;
    lv_balanceaccount.stat_ret_num   := 0;
    lv_balanceaccount.stat_ret_amt   := 0;
    lv_balanceaccount.stat_rechg_num := 0;
    lv_balanceaccount.stat_rechg_amt := 0;
    lv_balanceaccount.send_cns_num   := lv_in(4);
    lv_balanceaccount.send_cns_amt   := lv_in(5);
    lv_balanceaccount.send_ret_num   := lv_in(6);
    lv_balanceaccount.send_ret_amt   := lv_in(7);
    lv_balanceaccount.send_rechg_num := lv_in(10);
    lv_balanceaccount.send_rechg_amt := lv_in(11);
    WHILE lv_clrdate <= lv_in(9) LOOP
      IF lv_balanceaccount.send_cns_num > 0 THEN
        --���� db_amt > 0 and db_card_no is not null and cr_card_no is null
        EXECUTE IMMEDIATE 'select count(distinct action_no),sum(db_amt) from acc_inout_detail_' ||
                          REPLACE(lv_clrdate, '-', '') ||
                          ' where acpt_id = :1 and oper_id = :2 and tr_batch_no = :3 and db_amt > 0 and db_card_no is not null and cr_card_no is null and tr_state = 0'
          INTO lv_tempnum, lv_tempamt
          USING lv_balanceaccount.biz_id, lv_balanceaccount.term_id, lv_balanceaccount.tr_batch_no;
        lv_balanceaccount.stat_cns_num := lv_balanceaccount.stat_cns_num +
                                          lv_tempnum;
        lv_balanceaccount.stat_cns_amt := lv_balanceaccount.stat_cns_amt +
                                          lv_tempamt;
      END IF;
      IF lv_balanceaccount.send_ret_num > 0 THEN
        --�˻� db_amt < 0 and db_card_no is not null and cr_card_no is null
        EXECUTE IMMEDIATE 'select count(distinct action_no),sum(db_amt) from acc_inout_detail_' ||
                          REPLACE(lv_clrdate, '-', '') ||
                          ' where acpt_id = :1 and oper_id = :2 and tr_batch_no = :3 and db_amt < 0 and db_card_no is not null and cr_card_no is null and tr_state = 0'
          INTO lv_tempnum, lv_tempamt
          USING lv_balanceaccount.biz_id, lv_balanceaccount.term_id, lv_balanceaccount.tr_batch_no;
        lv_balanceaccount.stat_ret_num := lv_balanceaccount.stat_ret_num +
                                          lv_tempnum;
        lv_balanceaccount.stat_ret_amt := lv_balanceaccount.stat_ret_amt +
                                          lv_tempamt;
      END IF;
      IF lv_balanceaccount.send_cns_num > 0 THEN
        --��ֵ db_amt > 0 and db_card_no is null and cr_card_no is not null
        EXECUTE IMMEDIATE 'select count(distinct action_no),sum(db_amt) from acc_inout_detail_' ||
                          REPLACE(lv_clrdate, '-', '') ||
                          ' where acpt_id = :1 and oper_id = :2 and tr_batch_no = :3 and db_amt > 0 and db_card_no is null and cr_card_no is not null and tr_state = 0'
          INTO lv_tempnum, lv_tempamt
          USING lv_balanceaccount.biz_id, lv_balanceaccount.term_id, lv_balanceaccount.tr_batch_no;
        lv_balanceaccount.stat_rechg_num := lv_balanceaccount.stat_rechg_num +
                                            lv_tempnum;
        lv_balanceaccount.stat_rechg_amt := lv_balanceaccount.stat_rechg_amt +
                                            lv_tempamt;
      END IF;
      lv_clrdate                       := to_char(to_date(lv_clrdate,
                                                          'yyyy-mm-dd') + 1,
                                                  'yyyy-mm-dd');
    END LOOP;
    IF lv_balanceaccount.stat_cns_num = lv_balanceaccount.send_cns_num AND
       lv_balanceaccount.stat_cns_amt = lv_balanceaccount.send_cns_amt AND
       lv_balanceaccount.stat_ret_num = lv_balanceaccount.send_ret_num AND
       lv_balanceaccount.stat_ret_amt = lv_balanceaccount.send_ret_amt AND
       lv_balanceaccount.stat_rechg_num = lv_balanceaccount.send_rechg_num AND
       lv_balanceaccount.stat_rechg_amt = lv_balanceaccount.send_rechg_amt THEN
      --ȫƽ
      lv_balanceaccount.comp_flag := '00';
    ELSIF lv_balanceaccount.stat_cns_num = lv_balanceaccount.send_cns_num AND
          lv_balanceaccount.stat_cns_amt = lv_balanceaccount.send_cns_amt AND
          lv_balanceaccount.stat_ret_num = lv_balanceaccount.send_ret_num AND
          lv_balanceaccount.stat_ret_amt = lv_balanceaccount.send_ret_amt THEN
      --�����˻�ƽ
      lv_balanceaccount.comp_flag := '15';
    ELSIF lv_balanceaccount.stat_cns_num = lv_balanceaccount.send_cns_num AND
          lv_balanceaccount.stat_cns_amt = lv_balanceaccount.send_cns_amt AND
          lv_balanceaccount.stat_rechg_num =
          lv_balanceaccount.send_rechg_num AND
          lv_balanceaccount.stat_rechg_amt =
          lv_balanceaccount.send_rechg_amt THEN
      --���ѳ�ֵƽ
      lv_balanceaccount.comp_flag := '16';
    ELSIF lv_balanceaccount.stat_ret_num = lv_balanceaccount.send_ret_num AND
          lv_balanceaccount.stat_ret_amt = lv_balanceaccount.send_ret_amt AND
          lv_balanceaccount.stat_rechg_num =
          lv_balanceaccount.send_rechg_num AND
          lv_balanceaccount.stat_rechg_amt =
          lv_balanceaccount.send_rechg_amt THEN
      --�˻���ֵƽ
      lv_balanceaccount.comp_flag := '17';
    ELSIF lv_balanceaccount.stat_cns_num = lv_balanceaccount.send_cns_num AND
          lv_balanceaccount.stat_cns_amt = lv_balanceaccount.send_cns_amt THEN
      --����ƽ
      lv_balanceaccount.comp_flag := '12';
    ELSIF lv_balanceaccount.stat_ret_num = lv_balanceaccount.send_ret_num AND
          lv_balanceaccount.stat_ret_amt = lv_balanceaccount.send_ret_amt THEN
      --�˻�ƽ
      lv_balanceaccount.comp_flag := '13';
    ELSIF lv_balanceaccount.stat_rechg_num =
          lv_balanceaccount.send_rechg_num AND
          lv_balanceaccount.stat_rechg_amt =
          lv_balanceaccount.send_rechg_amt THEN
      --��ֵƽ
      lv_balanceaccount.comp_flag := '14';
    ELSE
      lv_balanceaccount.comp_flag := '11';
    END IF;
    av_out := lv_balanceaccount.stat_cns_num || '|' ||
              lv_balanceaccount.stat_cns_amt || '|' ||
              lv_balanceaccount.stat_ret_num || '|' ||
              lv_balanceaccount.stat_ret_amt || '|' ||
              lv_balanceaccount.stat_rechg_num || '|' ||
              lv_balanceaccount.stat_rechg_amt;
    INSERT INTO tr_posbalanceaccount VALUES lv_balanceaccount;
  END p_posBalanceAccount;*/
  /*=======================================================================================*/
  --�ѻ�������������
  /*=======================================================================================*/
  PROCEDURE p_writedaybook(av_offline         IN pay_offline%ROWTYPE, --�ѻ��ļ���¼
                           av_dbsubledger     IN acc_account_sub%ROWTYPE, --��Ǯ���˻�
                           av_crsubledger     IN acc_account_sub%ROWTYPE, --�̻���������˻�
                           av_pointssubledger IN acc_account_sub%ROWTYPE, --���������˻�
                           av_operator        IN sys_users%ROWTYPE, --����Ա
                           av_clrdate         IN VARCHAR2, --�������
                           av_debug           IN VARCHAR2, --1����
                           av_res             OUT VARCHAR2, --��������
                           av_msg             OUT VARCHAR2 --����������Ϣ
                           ) IS
    lv_accbookno    acc_inout_detail.acc_inout_no%TYPE; --������ˮ��
    lv_clrdate      pay_clr_para.clr_date%TYPE; --�������
    lv_dbsubledger  acc_account_sub%ROWTYPE; --���˻�
    lv_pointstrcode VARCHAR2(8) := '820201'; --�ͻ��ֵĽ��״���
    --  lv_vipdiscount  prmt_biz_vip_discount%ROWTYPE; --�ۿ�
    lv_dd TIMESTAMP := systimestamp;
  BEGIN
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    ----------------------------------------------------------------------------------
    --1��д���Ѽ�¼
    ----------------------------------------------------------------------------------
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    IF av_dbsubledger.acc_no IS NULL THEN
      pk_public.p_getsubledgerbycardno(av_offline.card_no, --����
                                       pk_public.cs_acckind_qb, --�˻�����
                                       pk_public.cs_defaultwalletid, --Ǯ�����
                                       lv_dbsubledger, --�ֻ���
                                       av_res, --������������
                                       av_msg --��������������Ϣ
                                       );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSE
      lv_dbsubledger := av_dbsubledger;
    END IF;
    pk_public.p_insertrzcllog_('9',
                               'p_writedaybook begin p_account:' ||
                               av_offline.deal_no,
                               pk_public.f_timestamp_diff(systimestamp,
                                                          lv_dd));
    pk_business.p_account(lv_dbsubledger, --�跽�˻�
                          av_crsubledger, --�����˻�
                          av_offline.acc_bal, --�跽���潻��ǰ���
                          NULL, --�������潻��ǰ���
                          av_offline.card_deal_count, --�跽��Ƭ���׼�����
                          NULL, --������Ƭ���׼�����
                          NULL, --�跽�������
                          NULL, --�����������
                          av_offline.deal_amt, --���׽��
                          greatest(0,
                                   av_offline.deal_amt -
                                   (av_offline.acc_bal -
                                   av_offline.credit_limit)), --���÷�����
                          lv_accbookno, --������ˮ��
                          av_offline.deal_code, --���״���
                          av_operator.org_id, --��������
                          av_operator.org_id, --�������
                          pk_public.cs_acpt_type_sh, --��������
                          av_offline.acpt_id, --��������(�����/�̻��ŵ�)
                          av_offline.end_id, --������Ա/�ն˺�
                          av_offline.deal_batch_no, --�������κ�
                          av_offline.end_deal_no, --�ն˽�����ˮ��
                          to_date(av_offline.deal_date, 'yyyymmddhh24miss'), --����ʱ��
                          '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                          av_offline.deal_no, --ҵ����ˮ��
                          '�ѻ�����', --��ע
                          lv_clrdate, --�������
                          null,
                          av_debug, --1����
                          av_res, --������������
                          av_msg --��������������Ϣ
                          );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    pk_public.p_insertrzcllog_('9',
                               'p_writedaybook end p_account:' ||
                               av_offline.deal_no,
                               pk_public.f_timestamp_diff(systimestamp,
                                                          lv_dd));
    ----------------------------------------------------------------------------------
    --2���̻����ۿ�
    ----------------------------------------------------------------------------------
    --�Ƚ�������=��Ч���ڣ�û�еĻ��������������
    --  BEGIN
    /*BEGIN
      SELECT *
        INTO lv_vipdiscount
        FROM prmt_biz_vip_discount
       WHERE card_no = av_offline.card_no
         AND discount_date = substrb(av_offline.tr_date, 1, 8)
         AND biz_id = av_offline.acpt_id
         AND discount_id =
             (SELECT MAX(discount_id)
                FROM prmt_biz_vip_discount
               WHERE card_no = av_offline.card_no
                 AND discount_date = substrb(av_offline.tr_date, 1, 8)
                 AND biz_id = av_offline.acpt_id);
    EXCEPTION
      WHEN no_data_found THEN
        BEGIN
          SELECT *
            INTO lv_vipdiscount
            FROM prmt_biz_vip_discount
           WHERE card_no = av_offline.card_no
             AND discount_date < substrb(av_offline.tr_date, 1, 8)
             AND biz_id = av_offline.acpt_id
             AND discount_id =
                 (SELECT MIN(discount_id)
                    FROM prmt_biz_vip_discount
                   WHERE card_no = av_offline.card_no
                     AND discount_date < substrb(av_offline.tr_date, 1, 8)
                     AND biz_id = av_offline.acpt_id);
        EXCEPTION
          WHEN no_data_found THEN
            lv_vipdiscount.discount_id := 0;
        END;
    END;*/
    /* lv_vipdiscount.discount_id := 0;
      IF lv_vipdiscount.discount_id > 0 THEN
        --���ۿ� ���̻������ ��δȦ���˻�
        DECLARE
          lv_zkdbsubledger acc_sub_ledger%ROWTYPE; --�̻�������˻�
          lv_zkcrsubledger acc_sub_ledger%ROWTYPE; --δȦ���˻�
          lv_zktrcode      VARCHAR2(6) := '820501'; --�ۿ۵Ľ��״���
        BEGIN
          --ȡ�跽�ֻ���
          pk_public.p_getsubledgerbyclientid(av_crsubledger.client_id, --�̻�client_id
                                             pk_public.cs_accitem_biz_clr, --�̻��������
                                             lv_zkdbsubledger,
                                             av_res,
                                             av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
          --ȡ�����ֻ���
          pk_public.p_getsubledgerbycardno(av_offline.card_no,
                                           '09',
                                           pk_public.cs_defaultwalletid, --Ǯ�����
                                           lv_zkcrsubledger,
                                           av_res,
                                           av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
          --д��ˮ
          SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
          pk_business.p_account(lv_zkdbsubledger, --�跽�˻�
                                lv_zkcrsubledger, --�����˻�
                                NULL, --�跽���潻��ǰ���
                                NULL, --�������潻��ǰ���
                                NULL, --�跽��Ƭ���׼�����
                                NULL, --������Ƭ���׼�����
                                NULL, --�跽�������
                                NULL, --�����������
                                av_offline.tr_amt *
                                (100 - lv_vipdiscount.discount) / 100, --���׽��
                                0, --���÷�����
                                lv_accbookno, --������ˮ��
                                lv_zktrcode, --���״���
                                av_operator.org_id, --�������
                                pk_public.cs_acpt_type_wd, --��������
                                av_operator.brch_id, --��������(�����/�̻��ŵ�)
                                av_operator.oper_id, --������Ա/�ն˺�
                                NULL, --�������κ�
                                NULL, --�ն˽�����ˮ��
                                SYSDATE, --����ʱ��
                                '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                                av_offline.action_no, --ҵ����ˮ��
                                '�̻��ۿ�', --��ע
                                lv_clrdate, --�������
                                av_debug, --1����
                                av_res, --������������
                                av_msg --��������������Ϣ
                                );
        END;
      END IF;
    END;*/

    ----------------------------------------------------------------------------------
    --3���ͻ���
    ----------------------------------------------------------------------------------
    /*   IF av_offline.points > 0 THEN
      pk_points.p_generate(av_pointssubledger, --���ֽ跽�ֻ���
                           lv_dbsubledger.card_no, --����
                           av_offline.points, --����
                           lv_pointstrcode, --���״���
                           av_operator.org_id, --����������
                           av_operator.brch_id, --��������(�����/�̻��ŵ�)
                           av_operator.oper_id, --������Ա/�ն˺�
                           NULL, --�������κ�
                           NULL, --�ն˽�����ˮ��
                           av_offline.action_no, --ҵ����ˮ��
                           '���ͻ���', --��ע
                           lv_clrdate, --�������
                           av_debug, --1����
                           av_res, --��������
                           av_msg --����������Ϣ
                           );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;*/
    pk_public.p_insertrzcllog_('9',
                               'p_writedaybook end:' || av_offline.deal_no,
                               pk_public.f_timestamp_diff(systimestamp,
                                                          lv_dd));
  END p_writedaybook;
  /*=======================================================================================*/
  --�ѻ���������
  --av_in: ���ֶ���|�ָ�
  --1org_id|2co_org_id|3acpt_id|4end_id|5batch_no|6ser_no|7card_no|8CARD_IN_TYPE|9CARD_IN_SUBTYPE|10CARD_VALID_DATE|
  --11Applyusedate|12Applyvaliddate|13Moneynum|14Psamid|15Psamnum|16CardBalmoney|17Trademoney|18Tradetime|19Tradetype|20Tac|
  --21Flag|22deal_state|23SEND_FILE_NAME|24FILE_LINE_NO|25TR_CODE
  --
  /*=======================================================================================*/
  PROCEDURE p_upofflineconsume(av_in    IN VARCHAR2, --�������
                               av_debug IN VARCHAR2, --1����
                               av_res   OUT VARCHAR2, --��������
                               av_msg   OUT VARCHAR2 --����������Ϣ
                               ) IS
    lv_count NUMBER;
    lv_in    pk_public.myarray; --�����������
  BEGIN
    av_res := '00000000';
    pk_public.p_getinputpara(av_in, --�������
                             25, --�������ٸ���
                             25, --����������
                             'pk_consume.p_upofflineconsume', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    INSERT INTO pay_offline
      (end_deal_no,
       acpt_id,
       end_id,
       card_no,
       card_in_type,
       card_in_subtype,
       card_valid_date,
       card_start_date,
       app_valid_date,
       card_deal_count,
       psam_deal_no,
       acc_bal,
       deal_amt,
       deal_date,
       deal_kind,
       psam_no,
       tac,
       ash_flag,
       credit_limit,
       deal_batch_no,
       send_file_name,
       file_line_no,
       send_date,
       deal_no,
       deal_code,
       deal_state,
       clr_date,
       refuse_reason,
       org_id,
       cancel_deal_batch_id,
       cancel_end_deal_no,
       points)
    VALUES
      (lv_in(6),
       lv_in(3),
       lv_in(4),
       lv_in(7),
       lv_in(8),
       lv_in(9),
       lv_in(10),
       lv_in(11),
       lv_in(12),
       lv_in(13),
       lv_in(15),
       lv_in(16),
       lv_in(17),
       lv_in(18),
       lv_in(19),
       lv_in(14),
       lv_in(20),
       lv_in(21),
       0,
       lv_in(5),
       lv_in(23),
       lv_in(24),
       SYSDATE,
       seq_action_no.nextval,
       lv_in(25),
       nvl(lv_in(22), '0'),
       NULL,
       NULL,
       lv_in(1),
       NULL,
       NULL,
       NULL);
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�ѻ����ͷ�������' || SQLERRM;
  END p_upofflineconsume;
  /*=======================================================================================*/
  --�ѻ����ݴ���
  --av_in: ���ֶ���|�ָ�
  --       1biz_id    �̻���
  --�ܸ�ԭ��:00����Ƭ���з�����01��tac���02�����ݷǷ�03�������ظ�04���Ҽ�¼05������06-��������09�����ܸ�10��������
  /*=======================================================================================*/
  PROCEDURE p_offlineconsume(av_in    IN VARCHAR2, --�������
                             av_debug IN VARCHAR2, --1����
                             av_res   OUT VARCHAR2, --��������
                             av_msg   OUT VARCHAR2 --����������Ϣ
                             ) IS
    lv_dbsubledger     acc_account_sub%ROWTYPE; --���˻�
    lv_crsubledger     acc_account_sub%ROWTYPE; --�̻��������
    lv_pointssubledger acc_account_sub%ROWTYPE; --���������˻�
    lv_merchant        base_merchant%ROWTYPE; --�̻�
    lv_clrdate         pay_clr_para.clr_date%TYPE; --�������
    lv_tablename       VARCHAR2(50);
    lv_count           NUMBER;
    lv_sumAmt          NUMBER;
    lv_in              pk_public.myarray; --�����������
    lv_operator        sys_users%ROWTYPE; --admin����Ա
    lv_dd              TIMESTAMP := systimestamp;
    lv_deal_date       DATE;
    ------------------------------------------------------------------------------------
    --�Ƶ��ܸ���
    ------------------------------------------------------------------------------------
    PROCEDURE p_move2black(av_actionno NUMBER, av_reason VARCHAR2) IS
    BEGIN
      UPDATE pay_offline
         SET refuse_reason = av_reason
       WHERE deal_no = av_actionno;
      INSERT INTO pay_offline_black
        SELECT * FROM pay_offline WHERE deal_no = av_actionno;
      DELETE FROM pay_offline WHERE deal_no = av_actionno;
    END p_move2black;
  BEGIN
    -----------------------------------------------------------------------------------
    --1��ȡ������� ϵͳ������ȡ
    -----------------------------------------------------------------------------------
    pk_public.p_getinputpara(av_in, --�������
                             1, --�������ٸ���
                             1, --����������
                             'pk_consume.p_offlineconsume', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    pk_public.p_insertrzcllog_('2',
                               'p_offlineconsume begin clr_date:' || av_in,
                               pk_public.f_timestamp_diff(systimestamp,
                                                          lv_dd));
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --ȡ�̻���������˻�
    SELECT *
      INTO lv_merchant
      FROM base_merchant
     WHERE merchant_id = lv_in(1);
    pk_public.p_getsubledgerbyclientid(lv_merchant.customer_id, --�̻�client_id
                                       pk_public.cs_accitem_biz_clr, --�̻��������
                                       lv_crsubledger,
                                       av_res,
                                       av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;

    --ȡ���������˻�
    pk_public.p_getorgoperator(lv_merchant.org_id, --�������
                               lv_operator, --��Ա
                               av_res, --������������
                               av_msg --��������������Ϣ
                               );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    pk_public.p_getorgsubledger(lv_operator.org_id,
                                pk_public.cs_accitem_org_points,
                                lv_pointssubledger,
                                av_res,
                                av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    -----------------------------------------------------------------------------------
    --3��������ʱ������
    -----------------------------------------------------------------------------------
    pk_public.p_insertrzcllog_('2',
                               'p_offlineconsume begin temp:' || av_in,
                               pk_public.f_timestamp_diff(systimestamp,
                                                          lv_dd));
    FOR lv_filename IN (SELECT *
                          FROM pay_offline_filename
                         WHERE merchant_id = lv_in(1)
                           AND (send_file_name LIKE 'XF%' /*or send_file_name is null*/
                               )
                           /*AND state = '2'*/) LOOP

      FOR lv_offline IN (SELECT t.*
                           FROM pay_offline t
                          WHERE acpt_id = lv_in(1)
                            AND send_file_name = lv_filename.send_file_name) LOOP
        pk_public.p_insertrzcllog_('2',
                                   'p_offlineconsume action_no:' ||
                                   lv_offline.deal_no,
                                   pk_public.f_timestamp_diff(systimestamp,
                                                              lv_dd));
        --ȡ���ֻ���
        pk_public.p_getsubledgerbycardno(lv_offline.card_no, --����
                                         pk_public.cs_acckind_qb, --�˻�����
                                         pk_public.cs_defaultwalletid, --Ǯ�����
                                         lv_dbsubledger, --�ֻ���
                                         av_res, --������������
                                         av_msg --��������������Ϣ
                                         );
        -------------------------------------------------------------------------------
        --3.0���жϽ���ʱ���ʽ�Ƿ���ȷ
        -------------------------------------------------------------------------------
        BEGIN
          SELECT to_date(lv_offline.deal_date, 'yyyymmddhh24miss')
            INTO lv_deal_date
            FROM dual;
        EXCEPTION
          WHEN OTHERS THEN
            p_move2black(lv_offline.deal_no, '07');
            GOTO templooplabel;
        END;
        -------------------------------------------------------------------------------
        --3.1���˻�������02
        -------------------------------------------------------------------------------
        IF av_res <> pk_public.cs_res_ok THEN
          p_move2black(lv_offline.deal_no, '02');
          GOTO templooplabel;
        END IF;
        -------------------------------------------------------------------------------
        --3.2�������ظ�03
        -------------------------------------------------------------------------------
        lv_tablename := pk_public.f_gettrcardtable(lv_offline.card_no,
                                                   to_date(lv_offline.deal_date,
                                                           'yyyymmddhh24miss'));
        EXECUTE IMMEDIATE 'select count(*) from pay_offline_list t '||
                        ' where card_no = :1 and t.end_deal_no = :2 and t.end_id = :3 and t.deal_batch_no = :4 ' ||
                        '  and t.acpt_id = :5'
        INTO lv_count
        USING lv_offline.card_no, lv_offline.end_deal_no,lv_offline.end_id,lv_offline.deal_batch_no,lv_offline.acpt_id;
        IF lv_count > 0 THEN
          p_move2black(lv_offline.deal_no, '03');
          GOTO templooplabel;
        END IF;

        -------------------------------------------------------------------------------
        --3.3��tac��01 �Ҽ�¼04
        -------------------------------------------------------------------------------
        IF lv_offline.refuse_reason IN ('01', '04') THEN
          p_move2black(lv_offline.deal_no, lv_offline.refuse_reason);
          GOTO templooplabel;
        ELSIF lv_offline.ash_flag = '01' THEN
          p_move2black(lv_offline.deal_no, '04');
          GOTO templooplabel;
        END IF;
        -------------------------------------------------------------------------------
        --3.4������05
        -------------------------------------------------------------------------------
        IF lv_offline.deal_amt > lv_dbsubledger.bal THEN
          p_move2black(lv_offline.deal_no, '05');
          GOTO templooplabel;
        END IF;
        -------------------------------------------------------------------------------
        --3.5����������06
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        --3.6����������
        -------------------------------------------------------------------------------
        pk_public.p_insertrzcllog_('2',
                                   'p_offlineconsume begin p_writedaybook:' ||
                                   av_in,
                                   pk_public.f_timestamp_diff(systimestamp,
                                                              lv_dd));
        --д��ˮ �ۿ� ����
        p_writedaybook(lv_offline, --�ѻ��ļ���¼
                       lv_dbsubledger, --��Ǯ���˻�
                       lv_crsubledger, --�̻���������˻�
                       lv_pointssubledger, --���������˻�
                       lv_operator, --����Ա
                       lv_clrdate, --�������
                       av_debug, --1����
                       av_res, --��������
                       av_msg --����������Ϣ
                       );
        IF av_res <> pk_public.cs_res_ok THEN
          --ROLLBACK;
          --GOTO templooplabel;
          RETURN;
        END IF;

        pk_public.p_insertrzcllog_('2',
                                   'p_offlineconsume end p_writedaybook:' ||
                                   lv_offline.deal_no,
                                   pk_public.f_timestamp_diff(systimestamp,
                                                              lv_dd));
        --�ƶ�����
        --   lv_tablename := 'tr_offline_' || REPLACE(lv_clrdate, '-', '');
        UPDATE pay_offline
           SET clr_date = lv_clrdate
         WHERE deal_no = lv_offline.deal_no;

        insert into pay_offline_list values lv_offline;
        delete from pay_offline t where t.deal_no = lv_offline.deal_no;

        /* EXECUTE IMMEDIATE 'insert into ' || lv_tablename ||
                          ' select * from tr_offline where action_no = :1'
          USING lv_offline.action_no;
        DELETE FROM tr_offline WHERE action_no = lv_offline.action_no;*/
        pk_public.p_insertrzcllog_('2',
                                   'p_offlineconsume end move:' ||
                                   lv_offline.deal_no,
                                   pk_public.f_timestamp_diff(systimestamp,
                                                              lv_dd));
        -------------------------------------------------------------------------------
        --3.7����¼�������
        -------------------------------------------------------------------------------
        <<templooplabel>>
        NULL;
        COMMIT;
      END LOOP;
      UPDATE pay_offline_filename
         SET state = '3'
       WHERE send_file_name = lv_filename.send_file_name
         /*AND state = '2'*/;

      --���´�������ȷ�ϱ�����ȷ�Ͻ��ܸ������;ܸ���� �����������͵������
      select count(1), sum(t.deal_amt)
        into lv_count, lv_sumAmt
        from pay_offline_list t
       where t.send_file_name = lv_filename.send_file_name;
        update pay_offline_filename t1
           set t1.confirm_num = lv_count, t1.confirm_amt = lv_sumAmt
         where t1.send_file_name = lv_filename.send_file_name;

      select count(1), sum(t.deal_amt)
        into lv_count, lv_sumAmt
        from pay_offline_black t
       where t.send_file_name = lv_filename.send_file_name;
        update pay_offline_filename t1
           set t1.refuse_num = lv_count, t1.refuse_amt = lv_sumAmt
         where t1.send_file_name = lv_filename.send_file_name;

      IF SQL%ROWCOUNT = 0 THEN
        --�Ѵ���continue
        av_res := -1;
        av_msg := '��������ڴ����˳�';
        RETURN;
      ELSE
        COMMIT;
      END IF;
    END LOOP;

    -----------------------------------------------------------------------------------
    --4������ܸ����еĻҼ�¼
    -----------------------------------------------------------------------------------
    FOR lv_offline IN (SELECT t.*
                         FROM pay_offline_black t
                        WHERE acpt_id = lv_in(1)
                          AND refuse_reason IN ('01', '04')) LOOP
      --ȡ���ֻ���
      pk_public.p_getsubledgerbycardno(lv_offline.card_no, --����
                                       pk_public.cs_acckind_qb, --�˻�����
                                       pk_public.cs_defaultwalletid, --Ǯ�����
                                       lv_dbsubledger, --�ֻ���
                                       av_res, --������������
                                       av_msg --��������������Ϣ
                                       );
      -------------------------------------------------------------------------------
      --4.1���˻�������02
      -------------------------------------------------------------------------------
      IF av_res <> pk_public.cs_res_ok THEN
        UPDATE pay_offline_black
           SET refuse_reason = '02'
         WHERE deal_no = lv_offline.deal_no;
        GOTO blacklooplabel;
      END IF;
      -------------------------------------------------------------------------------
      --4.2�������ظ�03
      -------------------------------------------------------------------------------
      lv_tablename := pk_public.f_gettrcardtable(lv_offline.card_no,
                                                 to_date(lv_offline.deal_date,
                                                         'yyyymmddhh24miss'));
     EXECUTE IMMEDIATE 'select count(*) from pay_offline_list t '||
                        ' where card_no = :1 and t.end_deal_no = :2 and t.end_id = :3 and t.deal_batch_no = :4 ' ||
                        ' and t.acpt_id = :5'
        INTO lv_count
        USING lv_offline.card_no, lv_offline.end_deal_no,lv_offline.end_id,lv_offline.deal_batch_no,lv_offline.acpt_id;
      IF lv_count > 0 THEN
        UPDATE pay_offline_black
           SET refuse_reason = '03'
         WHERE deal_no = lv_offline.deal_no;
        GOTO blacklooplabel;
      END IF;
      -------------------------------------------------------------------------------
      --4.3������05
      -------------------------------------------------------------------------------
      IF lv_offline.deal_amt > lv_dbsubledger.bal THEN
        --����Ĳ����ľܸ�ԭ��
        GOTO blacklooplabel;
      END IF;
      -------------------------------------------------------------------------------
      --4.4����������06
      -------------------------------------------------------------------------------
      -------------------------------------------------------------------------------
      --4.5��������һ����¼�ж��Ƿ��ܵ���
      -------------------------------------------------------------------------------
      --����һ��������ˮ�ļ�¼
      DECLARE
        lv_temptablename VARCHAR2(50);
        lv_trdate        DATE;
      BEGIN
        lv_trdate := to_date(substrb(lv_offline.deal_date, 1, 6), 'yyyymm');
        WHILE lv_trdate <= trunc(SYSDATE, 'mm') --�������óɳ���һ���¾Ͳ�����
         LOOP
          lv_temptablename := pk_public.f_gettrcardtable(lv_offline.card_no,
                                                         lv_trdate);
          EXECUTE IMMEDIATE 'select count(*) from ' || lv_temptablename ||
                            ' where card_no = :1 and card_counter = :2  and amt < 0 and acc_kind = ''01'''
            INTO lv_count
            USING lv_offline.card_no, lv_offline.card_deal_count + 1;
          IF lv_count > 0 THEN
            --������һ����¼
            EXECUTE IMMEDIATE 'select count(*) from ' || lv_temptablename ||
                              ' where card_no = :1 and card_counter = :2 and card_bal = :3  and amt < 0 and acc_kind = ''01'''
              INTO lv_count
              USING lv_offline.card_no, lv_offline.card_deal_count + 1, lv_offline.acc_bal - lv_offline.deal_amt;
            IF lv_count > 0 THEN
              --����
              UPDATE pay_offline_black
                 SET refuse_reason = '00', clr_date = lv_clrdate
               WHERE deal_no = lv_offline.deal_no;
              --д��ˮ �ۿ� ����
              p_writedaybook(lv_offline, --�ѻ��ļ���¼
                             lv_dbsubledger, --��Ǯ���˻�
                             lv_crsubledger, --�̻���������˻�
                             lv_pointssubledger, --���������˻�
                             lv_operator, --����Ա
                             lv_clrdate, --�������
                             av_debug, --1����
                             av_res, --��������
                             av_msg --����������Ϣ
                             );
              IF av_res <> pk_public.cs_res_ok THEN
                --ROLLBACK;
                --GOTO blacklooplabel;
                RETURN;
              END IF;
              --�ƶ�����
              /*  lv_tablename := 'tr_offline_' || REPLACE(lv_clrdate, '-', '');
              EXECUTE IMMEDIATE 'insert into ' || lv_tablename ||
                                ' select * from tr_offline_black where action_no = :1'
                USING lv_offline.action_no;*/
              insert into pay_offline_list
                select *
                  from pay_offline_black
                 where deal_no = lv_offline.deal_no;
              DELETE FROM pay_offline_black
               WHERE deal_no = lv_offline.deal_no;
              update pay_offline_filename t2
                 set t2.adjust_num = t2.adjust_num + 1,
                     t2.refuse_num = t2.refuse_num - 1,
                     t2.adjust_amt = t2.adjust_amt + lv_offline.deal_amt,
                     t2.refuse_amt = t2.refuse_amt - lv_offline.deal_amt
               where t2.send_file_name = lv_offline.send_file_name;
            ELSE
              --�����ܸ�
              UPDATE pay_offline_black
                 SET refuse_reason = '09'
               WHERE deal_no = lv_offline.deal_no;
            END IF;
            EXIT;
          ELSE
            --��ǰ�²����ڣ����¸��µļ�¼
            lv_trdate := add_months(lv_trdate, 1);
          END IF;
        END LOOP;
      END; --����������һ����¼�ж��Ƿ��ܵ���

      -------------------------------------------------------------------------------
      --4.6����¼�������
      -------------------------------------------------------------------------------
      <<blacklooplabel>>
      NULL;

    --COMMIT;
    END LOOP;
    pk_public.p_insertrzcllog_('0',
                               'p_offlineconsume end:' || av_in,
                               pk_public.f_timestamp_diff(systimestamp,
                                                          lv_dd));
    --av_res :=pk_public.cs_res_ok;
      av_res := '00000000';
      av_msg := '';
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_dberr;
      av_msg := SQLERRM;
  END p_offlineconsume;

  /*=======================================================================================*/
  --�ѻ����ѻҼ�¼ȷ��
  --av_in: ���ֶ���|�ָ�
  --       action_no
  /*=======================================================================================*/
  PROCEDURE p_ashconfirm(av_in    IN VARCHAR2, --�������
                         av_debug IN VARCHAR2, --1����
                         av_res   OUT VARCHAR2, --��������
                         av_msg   OUT VARCHAR2 --����������Ϣ
                         ) IS
    lv_tablename       VARCHAR2(50);
    lv_offline         pay_offline%ROWTYPE;
    lv_clrdate         pay_clr_para.clr_date%TYPE; --�������
    lv_crsubledger     acc_account_sub%ROWTYPE; --�̻��������
    lv_pointssubledger acc_account_sub%ROWTYPE; --���������˻�
    lv_merchant        base_merchant%ROWTYPE; --�̻�
    lv_in              pk_public.myarray; --�����������
    lv_operator        sys_users%ROWTYPE; --admin����Ա
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             1, --�������ٸ���
                             1, --����������
                             'pk_consume.p_ashconfirm', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    BEGIN
      SELECT *
        INTO lv_offline
        FROM pay_offline_black
       WHERE deal_no = lv_in(1);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_glidenotexit;
        av_msg := 'δ�ҵ���ˮ��Ϊ' || lv_in(1) || '�����ѻҼ�¼';
        RETURN;
    END;
    IF lv_offline.deal_amt < 0 THEN
      --������˻��ĻҼ�¼  �˻���ˮȷ�ϣ�������д�Ҽ�¼ʱ�Ѿ��۳�
      pk_business.p_ashconfirm(lv_clrdate, --�������
                               lv_offline.deal_no, --ҵ����ˮ��
                               NULL, --�跽�������
                               NULL, --�����������
                               av_debug, --1д������־
                               av_res, --��������
                               av_msg --����������Ϣ
                               );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSE
      --ȡ�̻���������˻�
      SELECT *
        INTO lv_merchant
        FROM base_merchant
       WHERE merchant_id = lv_offline.acpt_id;
      pk_public.p_getsubledgerbyclientid(lv_merchant.customer_id, --�̻�client_id
                                         pk_public.cs_accitem_biz_clr, --�̻��������
                                         lv_crsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      pk_public.p_getorgoperator(lv_merchant.org_id, --�������
                                 lv_operator, --��Ա
                                 av_res, --������������
                                 av_msg --��������������Ϣ
                                 );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --ȡ���������˻�
      IF lv_offline.points > 0 THEN
        pk_public.p_getorgsubledger(lv_operator.org_id,
                                    pk_public.cs_accitem_org_points,
                                    lv_pointssubledger,
                                    av_res,
                                    av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
      END IF;
      --����
      UPDATE pay_offline_black
         SET refuse_reason = '00', clr_date = lv_clrdate, deal_state = '0'
       WHERE deal_no = lv_offline.deal_no;
      --д��ˮ �ۿ� ����
      p_writedaybook(lv_offline, --�ѻ��ļ���¼
                     NULL, --��Ǯ���˻�
                     lv_crsubledger, --�̻���������˻�
                     lv_pointssubledger, --���������˻�
                     lv_operator, --����Ա
                     lv_clrdate, --�������
                     av_debug, --1����
                     av_res, --��������
                     av_msg --����������Ϣ
                     );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
    --�ƶ�����
    /* lv_tablename := 'tr_offline_' || REPLACE(lv_clrdate, '-', '');
    EXECUTE IMMEDIATE 'insert into ' || lv_tablename ||
                      ' select * from tr_offline_black where action_no = :1'
      USING lv_offline.action_no;
    DELETE FROM tr_offline_black WHERE action_no = lv_offline.action_no;*/
    insert into pay_offline
      select * from pay_offline_black where deal_no = lv_offline.deal_no;
    DELETE FROM pay_offline_black WHERE deal_no = lv_offline.deal_no;
    av_res := '00000000';
    av_msg := '';
  END p_ashconfirm;

  /*=======================================================================================*/
  --�ѻ������˻�
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no  ԭaction_no
  --       6clr_date   ԭ���Ѽ�¼���������
  --       7card_bal   Ǯ������ǰ���
  --       8card_tr_count�����׼�����
  /*=======================================================================================*/
  PROCEDURE p_offlineconsumereturn(av_in    IN VARCHAR2, --�������
                                   av_debug IN VARCHAR2, --1����
                                   av_res   OUT VARCHAR2, --��������
                                   av_msg   OUT VARCHAR2 --����������Ϣ
                                   ) IS
    --lv_offline      tr_offline%ROWTYPE;
    lv_tablename    VARCHAR2(50);
    lv_newtablename VARCHAR2(50);
    lv_in           pk_public.myarray; --�����������
    lv_clrdate      pay_clr_para.clr_date%TYPE; --�������
    lv_cardno       VARCHAR2(20); --����
    lv_points       NUMBER; --����
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             8, --�������ٸ���
                             8, --����������
                             'pk_consume.p_offlineconsumereturn', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    -- lv_tablename    := 'tr_offline_' || REPLACE(lv_in(6), '-', '');
    -- lv_newtablename := 'tr_offline_black'; --��д�Ҽ�¼����ȷ�� 'tr_offline_' || REPLACE(lv_clrdate, '-', '');
    --����ԭ��¼
    /* EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                    ' set tr_state=1,cancel_tr_batch_id=:1,cancel_term_ser_no=:2 where action_no=:3 returning card_no,points into :4,:5'
    USING lv_in(6), lv_in(1), lv_in(5)
    RETURNING INTO lv_cardno, lv_points;*/
    update pay_offline
       set deal_state           = 1,
           cancel_deal_batch_id = lv_in(6),
           cancel_end_deal_no   = lv_in(1)
     where deal_no = lv_in(5)
    RETURNING card_no, points INTO lv_cardno, lv_points;
    IF SQL%ROWCOUNT = 0 THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := 'δ�ҵ���ˮ��Ϊ' || lv_in(5) || '��δ�˻����Ѽ�¼';
      RETURN;
    END IF;
    --�����˻���¼
    /* EXECUTE IMMEDIATE 'insert into ' || lv_newtablename ||
                    '(tr_ser_no, acpt_id, term_id, card_no, card_in_type, card_in_subtype, card_valid_date, card_start_date, app_valid_date, card_tr_count, psam_tr_no, acc_bal, tr_amt, tr_date, tr_kind, psam_no, tac, ash_flag, credit_limit, tr_batch_no, send_file_name, file_line_no, send_date, action_no, tr_code, tr_state, clr_date, refuse_reason, org_id, cancel_tr_batch_id, cancel_term_ser_no, points)' ||
                    ' select tr_ser_no, acpt_id, term_id, card_no, card_in_type, card_in_subtype, card_valid_date, card_start_date, app_valid_date, card_tr_count, psam_tr_no, acc_bal, -tr_amt, tr_date, tr_kind, psam_no, tac, ash_flag, credit_limit, tr_batch_no, send_file_name, file_line_no, send_date, :1, tr_code, tr_state, clr_date, refuse_reason, org_id, cancel_tr_batch_id, :2, -points from ' ||
                    lv_tablename || ' where action_no = :3'
    USING lv_in(1), lv_in(5), lv_in(5);*/

    insert into pay_offline_black
      (end_deal_no,
       acpt_id,
       end_id,
       card_no,
       card_in_type,
       card_in_subtype,
       card_valid_date,
       card_start_date,
       app_valid_date,
       card_deal_count,
       psam_deal_no,
       acc_bal,
       deal_amt,
       deal_date,
       deal_kind,
       psam_no,
       tac,
       ash_flag,
       credit_limit,
       deal_batch_no,
       send_file_name,
       file_line_no,
       send_date,
       deal_no,
       deal_code,
       deal_state,
       clr_date,
       refuse_reason,
       org_id,
       cancel_deal_batch_id,
       cancel_end_deal_no,
       points)
      select end_deal_no,
             acpt_id,
             end_id,
             card_no,
             card_in_type,
             card_in_subtype,
             card_valid_date,
             card_start_date,
             app_valid_date,
             card_deal_count,
             psam_deal_no,
             acc_bal,
             -deal_amt,
             deal_date,
             deal_kind,
             psam_no,
             tac,
             ash_flag,
             credit_limit,
             deal_batch_no,
             send_file_name,
             file_line_no,
             send_date,
             lv_in(1),
             deal_code,
             deal_state,
             clr_date,
             refuse_reason,
             org_id,
             cancel_deal_batch_id,
             lv_in(5),
             -points
        from pay_offline
       where deal_no = lv_in(5);
    --��������
    /* IF lv_points <> 0 THEN
      pk_points.p_generatecancel(lv_cardno, --����
                                 lv_points, --����
                                 lv_in(6), --�������
                                 av_res, --��������
                                 av_msg --����������Ϣ
                                 );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;*/
    --�����˻���ˮ
    pk_business.p_daybookcancel(lv_in(5), --Ҫ����ҵ����ˮ��
                                lv_in(1), --��ҵ����ˮ��
                                lv_in(6), --������¼���������
                                lv_clrdate, --��ǰ�������
                                lv_in(2), --���״���
                                NULL, --lv_in(3), --��Ա���
                                lv_in(7), --�跽���潻��ǰ���
                                NULL, --�������潻��ǰ���
                                lv_in(8), --�跽��Ƭ���׼�����
                                NULL, --������Ƭ���׼�����
                                NULL, --�跽�������
                                NULL, --�����������
                                '0', --1ֱ��ȷ��
                                av_debug, --1д������־
                                av_res, --��������
                                av_msg --����������Ϣ
                                );
  END p_offlineconsumereturn;

  /*=======================================================================================*/
  --�ѻ����ѻҼ�¼���� --����״̬Ϊ�ѳ���
  --av_in: ���ֶ���|�ָ�
  --       action_no
  /*=======================================================================================*/
  PROCEDURE p_ashcancel(av_in    IN VARCHAR2, --�������
                        av_debug IN VARCHAR2, --1����
                        av_res   OUT VARCHAR2, --��������
                        av_msg   OUT VARCHAR2 --����������Ϣ
                        ) IS
    lv_offline   pay_offline%ROWTYPE;
    lv_in        pk_public.myarray; --�����������
    lv_tablename VARCHAR2(50);
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             1, --�������ٸ���
                             1, --����������
                             'pk_consume.p_ashcancel', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    BEGIN
      SELECT *
        INTO lv_offline
        FROM pay_offline_black
       WHERE deal_no = lv_in(1);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_glidenotexit;
        av_msg := 'δ�ҵ���ˮ��Ϊ' || lv_in(1) || '�����ѻҼ�¼';
        RETURN;
    END;
    UPDATE pay_offline_black SET deal_state = '2' WHERE deal_no = lv_in(1);
    IF lv_offline.deal_amt < 0 THEN
      --�˻��Ҽ�¼������ԭ��¼��״̬�����ּӻ�ȥ
      --��������
      /*   pk_points.p_generatecancel(lv_offline.card_no, --����
                                 lv_offline.points, --����
                                 lv_offline.clr_date, --�������-------------------
                                 av_res, --��������
                                 av_msg --����������Ϣ
                                 );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;*/
      --����ԭ��¼
      /* lv_tablename := 'tr_offline_' ||
                      REPLACE(lv_offline.cancel_tr_batch_id, '-', '');
      EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                        ' set tr_state=0,cancel_tr_batch_id=null,cancel_term_ser_no=null where action_no=:1'
        USING lv_offline.cancel_term_ser_no;*/

      update pay_offline
         set deal_state           = 0,
             cancel_deal_batch_id = null,
             cancel_end_deal_no   = null
       where deal_no = lv_offline.cancel_end_deal_no;
    END IF;

    IF av_debug = '1' THEN
      NULL;
    END IF;
    av_res := pk_public.cs_res_ok;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�ѻ����ѻҼ�¼������������' || SQLERRM;
  END p_ashcancel;
  /*=======================================================================================*/
  --�ѻ����Ѿܸ��ĳ�����
  --av_in: ���ֶ���|�ָ�
  --       action_no
  /*=======================================================================================*/
  PROCEDURE p_black2normal(av_in    IN VARCHAR2, --�������
                           av_debug IN VARCHAR2, --1����
                           av_res   OUT VARCHAR2, --��������
                           av_msg   OUT VARCHAR2 --����������Ϣ
                           ) IS
    lv_tablename       VARCHAR2(50);
    lv_offline         pay_offline%ROWTYPE;
    lv_in              pk_public.myarray; --�����������
    lv_crsubledger     acc_account_sub%ROWTYPE; --�̻��������
    lv_pointssubledger acc_account_sub%ROWTYPE; --���������˻�
    lv_merchant        base_merchant%ROWTYPE; --�̻�
    lv_operator        sys_users%ROWTYPE; --����Ա
    lv_clrdate         pay_clr_para.clr_date%TYPE; --�������
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             1, --�������ٸ���
                             1, --����������
                             'pk_consume.p_cancel2normal', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    BEGIN
      SELECT *
        INTO lv_offline
        FROM pay_offline_black
       WHERE deal_no = lv_in(1);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_glidenotexit;
        av_msg := 'δ�ҵ���ˮ��Ϊ' || lv_in(1) || '�����Ѽ�¼';
        RETURN;
    END;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --ȡ�̻���������˻�
    SELECT *
      INTO lv_merchant
      FROM base_merchant
     WHERE merchant_id = lv_offline.acpt_id;
    pk_public.p_getsubledgerbyclientid(lv_merchant.customer_id, --�̻�client_id
                                       pk_public.cs_accitem_biz_clr, --�̻��������
                                       lv_crsubledger,
                                       av_res,
                                       av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;

    --ȡ���������˻�
    pk_public.p_getorgoperator(lv_merchant.org_id, --�������
                               lv_operator, --��Ա
                               av_res, --������������
                               av_msg --��������������Ϣ
                               );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    pk_public.p_getorgsubledger(lv_operator.org_id,
                                pk_public.cs_accitem_org_points,
                                lv_pointssubledger,
                                av_res,
                                av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --д��ˮ �ۿ� ����
    p_writedaybook(lv_offline, --�ѻ��ļ���¼
                   NULL, --��Ǯ���˻�
                   lv_crsubledger, --�̻���������˻�
                   lv_pointssubledger, --���������˻�
                   lv_operator, --����Ա
                   lv_clrdate, --�������
                   av_debug, --1����
                   av_res, --��������
                   av_msg --����������Ϣ
                   );
    IF av_res <> pk_public.cs_res_ok THEN
      --ROLLBACK;
      --GOTO templooplabel;
      RETURN;
    END IF;
    --�ƶ�����
    UPDATE pay_offline_black
       SET deal_state = '0', refuse_reason = '00'
     WHERE deal_no = lv_offline.deal_no;
    lv_tablename := 'pay_offline_list';
    /*UPDATE pay_offline
      SET clr_date = lv_clrdate
    WHERE deal_no = lv_offline.deal_no;*/
    EXECUTE IMMEDIATE 'insert into ' || lv_tablename ||
                      ' select * from pay_offline_black where deal_no = :1'
      USING lv_offline.deal_no;
    DELETE FROM pay_offline_black WHERE deal_no = lv_offline.deal_no;
    av_res := pk_public.cs_res_ok;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�ѻ����ѻҼ�¼������������' || SQLERRM;
  END p_black2normal;
  /*=======================================================================================*/
  --ȡ��Ա������Ϣ
  --av_in: ���ֶ���|�ָ�  card_no|cert_no|sub_card_no|
  /*=======================================================================================*/
  PROCEDURE p_getPersonalInfo(av_in    VARCHAR2, --���
                              av_debug IN VARCHAR2, --1����
                              av_res   OUT VARCHAR2, --������������
                              av_msg   OUT VARCHAR2, --��������������Ϣ
                              av_table OUT pk_public.t_cur) IS
    lv_in pk_public.myarray; --�����������
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             3, --�������ٸ���
                             3, --����������
                             'pk_consume.p_onlineconsume_calc', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    if lv_in(1) is not null then
      OPEN av_table FOR 'select t1.cert_no,t1.name,t1.mobile_no  from base_personal t1,card_baseinfo t2  where t1.customer_id = t2.customer_id and   t2.card_no = :1'
        USING lv_in(1);
      av_res := pk_public.cs_res_ok;
      av_msg := NULL;
    end if;
    if lv_in(2) is not null then
      OPEN av_table FOR 'select select t1.cert_no,t1.name,t1.mobile_no  from base_personal t1,card_baseinfo t2  where t1.customer_id = t2.customer_id and   t1.cert_no = :1'
        USING lv_in(2);
      av_res := pk_public.cs_res_ok;
      av_msg := NULL;
    end if;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := 'ȡ�˻���Ϣ��������' || SQLERRM;
  END p_getPersonalInfo;
  /*=======================================================================================*/
  --��ȡ����ģʽ�����ݴ������
  --av_in: 1merchant_id|
  --       2acc_kind|
  --       3cousume_type  0 ���˻����� 1 ��������
  /*=======================================================================================*/
  PROCEDURE p_getConsumeMode(av_in           IN VARCHAR2, --�������
                             av_debug        IN VARCHAR2, --1����
                             av_res          OUT VARCHAR2, --��������
                             av_msg          OUT VARCHAR2, --����������Ϣ
                             av_consume_mode OUT VARCHAR2 --��������ģʽ
                             ) is
    lv_count NUMBER;
    lv_in    pk_public.myarray; --�����������
  begin
    --���в���
    pk_public.p_getinputpara(av_in, --�������
                             3, --�������ٸ���
                             3, --����������
                             'pk_consume.p_onlineconsume_calc', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --�����̻��ź��˻����ͽ�������ģʽ�Ĳ���
    IF lv_in(3) is null or lv_in(3) > 1 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�����������Ϊ�ջ��ʽ����ȷ';
    END IF;
    --��ȡ�̻�����ģʽ
    BEGIN
      IF lv_in(3) = 0 THEN
        --���˻����� ���봫���˻�����
        IF lv_in(2) IS NULL THEN
          av_res := '1';
          av_msg := 'ѡ���˻�����ģʽʱ�������������˻�';
        END IF;
        select t2.mode_id
          into av_consume_mode
          from base_merchant_mode t1, pay_acctype_sqn t2
         where t1.mode_id = t2.mode_id
           and t2.mode_state = '0'
           AND t1.mode_state = '0'
           and t1.merchant_id = lv_in(1)
           and t1.mode_type = '0'
           and t2.acc_sqn = lv_in(2);
      END IF;
      IF lv_in(3) = 1 THEN
        SELECT count(1)
          into lv_count
          from base_merchant_mode t1, pay_acctype_sqn t2
         where t1.mode_id = t2.mode_id
           and t2.mode_state = '0'
           AND t1.mode_state = '0'
           and t1.merchant_id = lv_in(1)
           and t1.mode_type = '1';
        IF lv_count <> 1 THEN
          av_res := '1';
          av_msg := 'δ�ҵ�Ψһ��һ���ۺ�����ģʽ�����������������ϵϵͳ����Ա';
        END IF;
        select t2.mode_id
          into av_consume_mode
          from base_merchant_mode t1, pay_acctype_sqn t2
         where t1.mode_id = t2.mode_id
           and t2.mode_state = '0'
           AND t1.mode_state = '0'
           and t1.merchant_id = lv_in(1)
           and t1.mode_type = '1';
      END IF;
    EXCEPTION
      when NO_DATA_FOUND then
        av_res := '1';
        av_msg := 'δ�ҵ���ص�����ģʽ����';
    END;
  end p_getConsumeMode;
  /*=======================================================================================*/
  --ǩ������
  --ÿ��������ǩ�����Ӿ�Ӫ�����̻������0.4Ԫ����Ա����δȦ���˻��ϣ�
  --  ͬʱÿ��ǩ��30�μ����ϵĴ��¸���10Ԫ��˽�Ľ�����
  --      ÿ��ǩ��100�μ����ϵ��������10Ԫ��˽�
  /*=======================================================================================*/
  /* PROCEDURE p_signpromotion(as_filename VARCHAR2, --ǩ���ļ���
                            av_debug    IN VARCHAR2, --1����
                            av_res      OUT VARCHAR2, --��������
                            av_msg      OUT VARCHAR2 --����������Ϣ
                            ) IS
    lv_send_money   NUMBER;
    lv_dbsubledger1 acc_sub_ledger%ROWTYPE; --�̻�������˻�
    --lv_dbsubledger2  acc_sub_ledger%ROWTYPE; --�̻��������˻�
    lv_crsubledger   acc_sub_ledger%ROWTYPE; --��δȦ���˻�
    lv_operator      sys_operator%ROWTYPE; --����Ա
    lv_merchant      bs_merchant%ROWTYPE; --�̻�
    lv_accbookno     acc_daybook.acc_book_no%TYPE; --������ˮ��
    lv_bizsigntrcode VARCHAR2(8) := '820301'; --�̻�ǩ�������Ľ��״���
    lv_clrdate       clr_control_para.clr_date%TYPE; --�������
    lv_obj           json;
    lv_count         NUMBER;
    lv_oldactionno   NUMBER;
  BEGIN
    SELECT clr_date INTO lv_clrdate FROM clr_control_para;

    --��ɾ���ظ�
    --�����Ѵ������ɴ�����¼
    DELETE FROM prmt_signin_list t
     WHERE send_file_name = as_filename
       AND ROWID <> (SELECT MIN(ROWID)
                       FROM prmt_signin_list
                      WHERE biz_id = t.biz_id
                        AND card_no = t.card_no
                        AND trunc(tr_date, 'dd') = trunc(t.tr_date, 'dd')
                        AND deal_state = '0');
    --ɾ��δ���ɴ�����¼�е��ظ�
    DELETE FROM prmt_signin_list t
     WHERE send_file_name = as_filename
       AND ROWID >
           (SELECT MIN(ROWID)
              FROM prmt_signin_list
             WHERE biz_id = t.biz_id
               AND card_no = t.card_no
               AND trunc(tr_date, 'dd') = trunc(t.tr_date, 'dd'));
    FOR lv_sign IN (SELECT *
                      FROM prmt_signin_list
                     WHERE send_file_name = as_filename) LOOP
      SELECT COUNT(*)
        INTO lv_count
        FROM prmt_signin_list
       WHERE biz_id = lv_sign.biz_id
         AND card_no = lv_sign.card_no
         AND trunc(tr_date, 'dd') = trunc(lv_sign.tr_date, 'dd')
         AND action_no < lv_sign.action_no;
      IF lv_count > 0 THEN
        --�ظ�
        NULL;
      ELSE
        --ȡδȦ���˻�
        pk_public.p_getsubledgerbycardno(lv_sign.card_no,
                                         pk_public.cs_acckind_wqc, --δȦ���˻�
                                         pk_public.cs_defaultwalletid, --Ǯ�����
                                         lv_crsubledger,
                                         av_res,
                                         av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;

        IF lv_merchant.biz_id IS NULL THEN
          BEGIN
            SELECT *
              INTO lv_merchant
              FROM bs_merchant
             WHERE biz_id = lv_sign.biz_id;
            --ȡ�̻�������˻�
            pk_public.p_getsubledgerbyclientid(lv_merchant.client_id, --�̻�client_id
                                               pk_public.cs_accitem_biz_clr, --�̻��������
                                               lv_dbsubledger1,
                                               av_res,
                                               av_msg);
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
            /*--ȡ�̻���������˻�
            pk_public.p_getsubledgerbyclientid(lv_merchant.client_id, --�̻�client_id
                                               pk_public.cs_accitem_biz_clr, --�̻��������
                                               lv_dbsubledger2,
                                               av_res,
                                               av_msg);
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
            --ȡ���������Ա
            pk_public.p_getorgoperator(lv_merchant.org_id, --�������
                                       lv_operator, --��Ա
                                       av_res, --������������
                                       av_msg --��������������Ϣ
                                       );
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
            --�����action_no
            SELECT MAX(action_no)
              INTO lv_oldactionno
              FROM prmt_signin_apply
             WHERE biz_id = lv_merchant.biz_id
               AND apply_date = to_char(lv_sign.tr_date, 'yyyy-mm-dd');
          END;
          --���ù���---------------------
          SELECT f_getruleresult('{"req_Code": "1003", "tr_date": "' ||
                                 to_char(lv_sign.tr_date, 'yyyy-mm-dd') ||
                                 '", "card_no": "' || lv_sign.card_no ||
                                 '", "org_id": "' || lv_sign.org_id || '"}')
            INTO av_msg
            FROM dual;
          lv_obj := json(av_msg);
          IF json_ext.get_string(lv_obj, 'result') <> '0' THEN
            av_res := pk_public.cs_res_ruleerr;
            av_msg := json_ext.get_string(lv_obj, 'msg');
            RETURN;
          END IF;
          lv_send_money := nvl(json_ext.get_string(lv_obj, 'send_money'), 0);
        END IF;

        ---------------------------------
        IF lv_send_money > 0 THEN
          --ÿ��������ǩ�����Ӿ�Ӫ�����̻������0.4Ԫ����Ա����δȦ���˻��ϣ�
          SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
          pk_business.p_account(lv_dbsubledger1, --�跽�˻�
                                lv_crsubledger, --�����˻�
                                NULL, --�跽���潻��ǰ���
                                NULL, --�������潻��ǰ���
                                NULL, --�跽��Ƭ���׼�����
                                NULL, --������Ƭ���׼�����
                                NULL, --�跽�������
                                NULL, --�����������
                                lv_send_money, --���׽��
                                0, --���÷�����
                                lv_accbookno, --������ˮ��
                                lv_bizsigntrcode, --���״���
                                lv_operator.org_id, --�������
                                pk_public.cs_acpt_type_wd, --��������
                                lv_sign.biz_id, --��������(�����/�̻��ŵ�)
                                lv_operator.oper_id, --������Ա/�ն˺�
                                NULL, --�������κ�
                                NULL, --�ն˽�����ˮ��
                                SYSDATE, --����ʱ��
                                '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                                lv_sign.action_no, --ҵ����ˮ��
                                '�̻�ǩ������', --��ע
                                lv_clrdate, --�������
                                av_debug, --1����
                                av_res, --������������
                                av_msg --��������������Ϣ
                                );
          IF av_res <> pk_public.cs_res_ok THEN
            ROLLBACK;
            --UPDATE tr_offline_filename SET state = '1' WHERE
          ELSE
            UPDATE prmt_signin_list
               SET rel_no_day = lv_accbookno, deal_state = '0'
             WHERE action_no = lv_sign.action_no;
            COMMIT;
          END IF;
          --������ᣬд�ⶳ��ˮ
          UPDATE acc_sub_ledger
             SET frz_amt = frz_amt - lv_send_money
           WHERE acc_no = lv_dbsubledger2.acc_no;
          --д������ˮ
          INSERT INTO acc_frozen_book
            (action_no,
             issue_org_id,
             org_id,
             acpt_id,
             term_id, --5
             tr_batch_no,
             tr_ser_no,
             tr_date,
             tr_amt,
             frz_amt, --10
             tr_code,
             frz_type,
             acc_no,
             card_no,
             frz_flag, --15
             acc_bal,
             old_action_no,
             insert_date,
             oper_id,
             rec_type, --20
             clr_date,
             cancel_tr_batch_id,
             cancel_term_ser_no,
             cancel_reason,
             apply_date, --25
             thaw_state,
             posp_proc_state,
             note)
          VALUES
            (lv_sign.action_no,
             lv_dbsubledger2.issue_org_id,
             lv_merchant.org_id,
             lv_merchant.biz_id,
             lv_sign.term_id, --5
             lv_sign.tr_batch_no,
             lv_sign.term_tr_no,
             SYSDATE,
             0,
             -lv_send_money, --10
             'tr_code', --tr_code
             '00',
             lv_dbsubledger2.acc_no,
             lv_dbsubledger2.card_no,
             '1', --15
             (lv_dbsubledger2.balance - lv_dbsubledger2.frz_amt +
             lv_send_money),
             NULL, --old_action_no----------------------------------
             SYSDATE,
             NULL,
             '0', --20
             lv_clrdate,
             NULL,
             NULL,
             NULL,
             to_char(lv_sign.tr_date, 'yyyy-mm-dd'), --25
             '1',
             '0',
             NULL);
        END IF;
      END IF;
    END LOOP;
    SELECT COUNT(*)
      INTO lv_count
      FROM prmt_signin_list
     WHERE send_file_name = as_filename
       AND deal_state = '1'
       AND rownum < 2;
    IF lv_count = 0 THEN
      --ȫ���Ѵ�������״̬
      UPDATE tr_offline_filename
         SET state = '3'
       WHERE send_file_name = as_filename;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_dberr;
      av_msg := SQLERRM;
      ROLLBACK;
  END p_signpromotion;*/

  /*=======================================================================================*/
  --ǩ������
  --  ͬʱÿ��ǩ��30�μ����ϵĴ��¸���10Ԫ��˽�Ľ�����
  /*=======================================================================================*/
  /* PROCEDURE p_signpromotion_month(as_month VARCHAR2, --�·� yyyy-mm
                                  av_debug IN VARCHAR2, --1����
                                  av_res   OUT VARCHAR2, --��������
                                  av_msg   OUT VARCHAR2 --����������Ϣ
                                  ) IS
    lv_month_send_money NUMBER;
    lv_dbsubledger2     acc_sub_ledger%ROWTYPE; --��������֧���˻�
    lv_crsubledger      acc_sub_ledger%ROWTYPE; --��δȦ���˻�
    lv_operator         sys_operator%ROWTYPE; --����Ա
    lv_merchant         bs_merchant%ROWTYPE; --�̻�
    lv_accbookno        acc_daybook.acc_book_no%TYPE; --������ˮ��
    lv_signawardtrcode  VARCHAR2(8) := '820302'; --ǩ�������Ľ��״���
    lv_clrdate          clr_control_para.clr_date%TYPE; --�������
    lv_obj              json;
    lv_lastdate         VARCHAR2(10) := to_char(last_day(to_date(as_month,
                                                                 'yyyy-dd')),
                                                'yyyy-mm-dd');
    lv_actionno         NUMBER;
  BEGIN
    SELECT clr_date INTO lv_clrdate FROM clr_control_para;
    SELECT seq_action_no.nextval INTO lv_actionno FROM dual;
    FOR lv_sign IN (SELECT card_no, org_id, MIN(biz_id) AS biz_id
                      FROM prmt_signin_list
                     WHERE tr_date >= to_date(as_month, 'yyyy-mm')
                       AND tr_date <
                           add_months(to_date(as_month, 'yyyy-mm'), 1)
                       AND rel_no_mon IS NULL
                     GROUP BY card_no, org_id) LOOP
      --���ù���---------------------
      SELECT f_getruleresult('{"req_Code": "1003", "tr_date": "' ||
                             lv_lastdate || '", "card_no": "' ||
                             lv_sign.card_no || '", "org_id": "' ||
                             lv_sign.org_id || '"}')
        INTO av_msg
        FROM dual;
      lv_obj := json(av_msg);
      IF json_ext.get_string(lv_obj, 'result') <> '0' THEN
        av_res := pk_public.cs_res_ruleerr;
        av_msg := json_ext.get_string(lv_obj, 'msg');
        RETURN;
      END IF;
      lv_month_send_money := nvl(json_ext.get_string(lv_obj,
                                                     'month_send_money'),
                                 0);
      ---------------------------------
      IF lv_month_send_money > 0 THEN
        --ȡδȦ���˻�
        pk_public.p_getsubledgerbycardno(lv_sign.card_no,
                                         pk_public.cs_acckind_wqc, --δȦ���˻�
                                         pk_public.cs_defaultwalletid, --Ǯ�����
                                         lv_crsubledger,
                                         av_res,
                                         av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
        --ȡ��������֧���˻�
        BEGIN
          SELECT *
            INTO lv_merchant
            FROM bs_merchant
           WHERE biz_id = lv_sign.biz_id;
          pk_public.p_getorgoperator(lv_merchant.org_id, --�������
                                     lv_operator, --��Ա
                                     av_res, --������������
                                     av_msg --��������������Ϣ
                                     );
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
          --ȡ��������֧���˻�
          pk_public.p_getorgsubledger(lv_operator.org_id,
                                      pk_public.cs_accitem_org_prmt_out,
                                      lv_dbsubledger2,
                                      av_res,
                                      av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
        END;
        --ÿ��ǩ��30�μ����ϵĴ��¸���10Ԫ��˽�Ľ�����
        SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
        pk_business.p_account(lv_dbsubledger2, --�跽�˻�
                              lv_crsubledger, --�����˻�
                              NULL, --�跽���潻��ǰ���
                              NULL, --�������潻��ǰ���
                              NULL, --�跽��Ƭ���׼�����
                              NULL, --������Ƭ���׼�����
                              NULL, --�跽�������
                              NULL, --�����������
                              lv_month_send_money, --���׽��
                              0, --���÷�����
                              lv_accbookno, --������ˮ��
                              lv_signawardtrcode, --���״���
                              lv_operator.org_id, --�������
                              pk_public.cs_acpt_type_wd, --��������
                              lv_sign.biz_id, --��������(�����/�̻��ŵ�)
                              lv_operator.oper_id, --������Ա/�ն˺�
                              NULL, --�������κ�
                              NULL, --�ն˽�����ˮ��
                              SYSDATE, --����ʱ��
                              '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                              lv_actionno, --ҵ����ˮ��
                              '��ǩ���ﵽ��������', --��ע
                              lv_clrdate, --�������
                              av_debug, --1����
                              av_res, --������������
                              av_msg --��������������Ϣ
                              );
        IF av_res <> pk_public.cs_res_ok THEN
          ROLLBACK;
        ELSE
          UPDATE prmt_signin_list
             SET rel_no_mon = lv_accbookno
           WHERE card_no = lv_sign.card_no
             AND tr_date >= to_date(as_month, 'yyyy-mm')
             AND tr_date < add_months(to_date(as_month, 'yyyy-mm'), 1);
          COMMIT;
        END IF;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_dberr;
      av_msg := SQLERRM;
      ROLLBACK;
  END p_signpromotion_month;*/

  /*=======================================================================================*/
  --ǩ������
  --  ÿ��ǩ��100�μ����ϵ��������10Ԫ��˽�
  /*=======================================================================================*/
  /* PROCEDURE p_signpromotion_year(as_year  VARCHAR2, --��� yyyy
                                 av_debug IN VARCHAR2, --1����
                                 av_res   OUT VARCHAR2, --��������
                                 av_msg   OUT VARCHAR2 --����������Ϣ
                                 ) IS
    lv_year_send_money NUMBER;
    lv_dbsubledger2    acc_sub_ledger%ROWTYPE; --��������֧���˻�
    lv_crsubledger     acc_sub_ledger%ROWTYPE; --��δȦ���˻�
    lv_operator        sys_operator%ROWTYPE; --����Ա
    lv_merchant        bs_merchant%ROWTYPE; --�̻�
    lv_accbookno       acc_daybook.acc_book_no%TYPE; --������ˮ��
    lv_signawardtrcode VARCHAR2(8) := '820302'; --ǩ�������Ľ��״���
    lv_clrdate         clr_control_para.clr_date%TYPE; --�������
    lv_obj             json;
    lv_lastdate        VARCHAR2(10) := as_year || '-12-31';
    lv_actionno        NUMBER;
  BEGIN
    SELECT clr_date INTO lv_clrdate FROM clr_control_para;
    SELECT seq_action_no.nextval INTO lv_actionno FROM dual;
    FOR lv_sign IN (SELECT card_no, org_id, MIN(biz_id) AS biz_id
                      FROM prmt_signin_list
                     WHERE tr_date >= to_date(as_year, 'yyyy')
                       AND tr_date <
                           add_months(to_date(as_year, 'yyyy'), 12)
                       AND rel_no_year IS NULL
                     GROUP BY card_no, org_id) LOOP
      --���ù���---------------------
      SELECT f_getruleresult('{"req_Code": "1003", "tr_date": "' ||
                             lv_lastdate || '", "card_no": "' ||
                             lv_sign.card_no || '", "org_id": "' ||
                             lv_sign.org_id || '"}')
        INTO av_msg
        FROM dual;
      lv_obj := json(av_msg);
      IF json_ext.get_string(lv_obj, 'result') <> '0' THEN
        av_res := pk_public.cs_res_ruleerr;
        av_msg := json_ext.get_string(lv_obj, 'msg');
        RETURN;
      END IF;
      lv_year_send_money := nvl(json_ext.get_string(lv_obj,
                                                    'year_send_money'),
                                0);
      ---------------------------------
      IF lv_year_send_money > 0 THEN
        --ȡδȦ���˻�
        pk_public.p_getsubledgerbycardno(lv_sign.card_no,
                                         pk_public.cs_acckind_wqc, --δȦ���˻�
                                         pk_public.cs_defaultwalletid, --Ǯ�����
                                         lv_crsubledger,
                                         av_res,
                                         av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
        --ȡ��������֧���˻�
        BEGIN
          SELECT *
            INTO lv_merchant
            FROM bs_merchant
           WHERE biz_id = lv_sign.biz_id;
          pk_public.p_getorgoperator(lv_merchant.org_id, --�������
                                     lv_operator, --��Ա
                                     av_res, --������������
                                     av_msg --��������������Ϣ
                                     );
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
          --ȡ��������֧���˻�
          pk_public.p_getorgsubledger(lv_operator.org_id,
                                      pk_public.cs_accitem_org_prmt_out,
                                      lv_dbsubledger2,
                                      av_res,
                                      av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
        END;
        --ÿ��ǩ��100�μ����ϵ��������10Ԫ��˽�
        SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
        pk_business.p_account(lv_dbsubledger2, --�跽�˻�
                              lv_crsubledger, --�����˻�
                              NULL, --�跽���潻��ǰ���
                              NULL, --�������潻��ǰ���
                              NULL, --�跽��Ƭ���׼�����
                              NULL, --������Ƭ���׼�����
                              NULL, --�跽�������
                              NULL, --�����������
                              lv_year_send_money, --���׽��
                              0, --���÷�����
                              lv_accbookno, --������ˮ��
                              lv_signawardtrcode, --���״���
                              lv_operator.org_id, --�������
                              pk_public.cs_acpt_type_wd, --��������
                              lv_sign.biz_id, --��������(�����/�̻��ŵ�)
                              lv_operator.oper_id, --������Ա/�ն˺�
                              NULL, --�������κ�
                              NULL, --�ն˽�����ˮ��
                              SYSDATE, --����ʱ��
                              '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                              lv_actionno, --ҵ����ˮ��
                              '��ǩ���ﵽ��������', --��ע
                              lv_clrdate, --�������
                              av_debug, --1����
                              av_res, --������������
                              av_msg --��������������Ϣ
                              );
        IF av_res <> pk_public.cs_res_ok THEN
          ROLLBACK;
        ELSE
          UPDATE prmt_signin_list
             SET rel_no_year = lv_accbookno
           WHERE card_no = lv_sign.card_no
             AND tr_date >= to_date(as_year, 'yyyy')
             AND tr_date < add_months(to_date(as_year, 'yyyy'), 12);
          COMMIT;
        END IF;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_dberr;
      av_msg := SQLERRM;
      ROLLBACK;
  END p_signpromotion_year;
  /*=======================================================================================*/
  --��������
  --VIP��ÿ������1Ԫ��˽�һ��365Ԫ
  /*=======================================================================================*/
  /* PROCEDURE p_vippromotion(av_trdate IN VARCHAR2, --����yyyy-mm-dd
                           av_debug  IN VARCHAR2, --1����
                           av_res    OUT VARCHAR2, --��������
                           av_msg    OUT VARCHAR2 --����������Ϣ
                           ) IS
    lv_send_money_vip      NUMBER;
    lv_send_money_bankcard NUMBER;
    lv_operator            sys_operator%ROWTYPE; --����Ա
    lv_actionno            acc_daybook.action_no%TYPE; --ҵ����ˮ��
    lv_accbookno           acc_daybook.acc_book_no%TYPE; --������ˮ��
    lv_clrdate             clr_control_para.clr_date%TYPE; --�������
    lv_obj                 json;
    lv_cursor              pk_public.t_cur; --�α�
    lv_tablename           VARCHAR2(50);
    lv_sql                 VARCHAR2(4000);
    lv_card                cm_card_00%ROWTYPE; --��������Ϣ
    lv_dbsubledger         acc_sub_ledger%ROWTYPE; --��������֧���˻�
    lv_crsubledger         acc_sub_ledger%ROWTYPE; --��δȦ���˻�
    lv_vipawardtrcode      VARCHAR2(8) := '820304'; --VIPÿ�����͵Ľ��״���
    lv_bindbankawardtrcode VARCHAR2(8) := '820303'; --VIPÿ�����͵Ľ��״���

  BEGIN
    SELECT clr_date INTO lv_clrdate FROM clr_control_para;
    SELECT seq_action_no.nextval INTO lv_actionno FROM dual;
    FOR i IN 1 .. pk_public.cs_cm_card_nums LOOP
      lv_tablename := upper('cm_card_' || TRIM(to_char(i - 1, '00')));
      lv_sql       := 'select * from ' || lv_tablename ||
                      ' where card_state = 1 and (card_vip = ''1'' or bank_card_no is not null) order by org_id';
      OPEN lv_cursor FOR lv_sql;
      LOOP
        FETCH lv_cursor
          INTO lv_card;
        EXIT WHEN lv_cursor%NOTFOUND;
        --���ù���---------------------
        SELECT f_getruleresult('{"req_Code": "1004", "tr_date": "' ||
                               av_trdate || '", "card_no": "' ||
                               lv_card.card_no || '", "org_id": "' ||
                               lv_card.issue_org_id || '"}')
          INTO av_msg
          FROM dual;
        dbms_output.put_line(av_msg);
        lv_obj := json(av_msg);
        IF json_ext.get_string(lv_obj, 'result') <> '0' THEN
          av_res := pk_public.cs_res_ruleerr;
          av_msg := json_ext.get_string(lv_obj, 'msg');
          RETURN;
        END IF;
        lv_send_money_vip      := nvl(json_ext.get_string(lv_obj,
                                                          'send_money_vip'),
                                      0);
        lv_send_money_bankcard := nvl(json_ext.get_string(lv_obj,
                                                          'send_money_bankcard'),
                                      0);
        IF TRUE AND (lv_send_money_vip > 0 OR lv_send_money_bankcard > 0) THEN
          IF lv_operator.oper_id IS NULL OR
             lv_operator.org_id <> lv_card.org_id THEN
            pk_public.p_getorgoperator(lv_card.org_id, --�������
                                       lv_operator, --��Ա
                                       av_res, --������������
                                       av_msg --��������������Ϣ
                                       );
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
            --ȡ��������֧���˻�
            pk_public.p_getorgsubledger(lv_operator.org_id,
                                        pk_public.cs_accitem_org_prmt_out,
                                        lv_dbsubledger,
                                        av_res,
                                        av_msg);
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
          END IF;
          --ȡδȦ���˻�
          pk_public.p_getsubledgerbycardno(lv_card.card_no,
                                           pk_public.cs_acckind_wqc, --δȦ���˻�
                                           pk_public.cs_defaultwalletid, --Ǯ�����
                                           lv_crsubledger,
                                           av_res,
                                           av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            pk_public.p_insertrzcllog('����������' || av_msg, 0);
            av_res := pk_public.cs_res_ok;
          ELSE
            IF lv_send_money_vip > 0 THEN
              SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
              pk_business.p_account(lv_dbsubledger, --�跽�˻�
                                    lv_crsubledger, --�����˻�
                                    NULL, --�跽���潻��ǰ���
                                    NULL, --�������潻��ǰ���
                                    NULL, --�跽��Ƭ���׼�����
                                    NULL, --������Ƭ���׼�����
                                    NULL, --�跽�������
                                    NULL, --�����������
                                    lv_send_money_vip, --���׽��
                                    0, --���÷�����
                                    lv_accbookno, --������ˮ��
                                    lv_vipawardtrcode, --���״���
                                    lv_operator.org_id, --�������
                                    pk_public.cs_acpt_type_wd, --��������
                                    lv_operator.brch_id, --��������(�����/�̻��ŵ�)
                                    lv_operator.oper_id, --������Ա/�ն˺�
                                    NULL, --�������κ�
                                    NULL, --�ն˽�����ˮ��
                                    to_date(av_trdate, 'yyyy-mm-dd'), --����ʱ��
                                    '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                                    lv_actionno, --ҵ����ˮ��
                                    'VIP��ÿ������', --��ע
                                    lv_clrdate, --�������
                                    av_debug, --1����
                                    av_res, --������������
                                    av_msg --��������������Ϣ
                                    );
              IF av_res <> pk_public.cs_res_ok THEN
                RETURN;
              END IF;
            END IF;
            IF lv_send_money_bankcard > 0 THEN
              SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
              pk_business.p_account(lv_dbsubledger, --�跽�˻�
                                    lv_crsubledger, --�����˻�
                                    NULL, --�跽���潻��ǰ���
                                    NULL, --�������潻��ǰ���
                                    NULL, --�跽��Ƭ���׼�����
                                    NULL, --������Ƭ���׼�����
                                    NULL, --�跽�������
                                    NULL, --�����������
                                    lv_send_money_bankcard, --���׽��
                                    0, --���÷�����
                                    lv_accbookno, --������ˮ��
                                    lv_bindbankawardtrcode, --���״���
                                    lv_operator.org_id, --�������
                                    pk_public.cs_acpt_type_wd, --��������
                                    lv_operator.brch_id, --��������(�����/�̻��ŵ�)
                                    lv_operator.oper_id, --������Ա/�ն˺�
                                    NULL, --�������κ�
                                    NULL, --�ն˽�����ˮ��
                                    to_date(av_trdate, 'yyyy-mm-dd'), --����ʱ��
                                    '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                                    lv_actionno, --ҵ����ˮ��
                                    'ǩ�����п���Э�飬ÿ�»���', --��ע
                                    lv_clrdate, --�������
                                    av_debug, --1����
                                    av_res, --������������
                                    av_msg --��������������Ϣ
                                    );
              IF av_res <> pk_public.cs_res_ok THEN
                RETURN;
              END IF;
            END IF;
          END IF;
        END IF;
        COMMIT;
      END LOOP;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_dberr;
      av_msg := SQLERRM;
  END p_vippromotion;*/

  /**
    --�˻�����
    ������Ϣ
    --       1deal_no       ������ˮ��
    --       2acpt_id       �������(����Ż��̻����)
    --       3acpt_type     ��������
    --       4user_id       ����Ա/�ն˺�
    --       5deal_time     ����ʱ��--�յĻ�ȡ�洢������ȡ���ݿ�ʱ��  ��ʽ YYYYMMDDHHMISS
    --       6card_no       ����
    --       7acc_kind      �˻�����
    --       8pwd           ����
    --       9freezeamt     ������
    --       10amt           ����ǰ���
    --       11deal_batch_no ���κ�
    --       12end_deal_no   �ն˽�����ˮ��
    --       13end_id       �ն˱��
    --       14freeze_type  ��������
    --       15note         ��ע
  */
  procedure p_accFreeze(av_in    in varchar2,
                        av_debug in varchar2,
                        av_res   out varchar2,
                        av_msg   out varchar2,
                        av_out   out varchar2) as
    lv_in              pk_public.myarray; --�����������
    lv_clrdate         pay_clr_para.clr_date%TYPE; --�������
    lv_card            card_baseinfo%rowtype;
    lv_acc_account_sub acc_account_sub%rowtype;
    --lv_deal_no acc_freeze_rec.deal_no%type;
    isAllFreeze  varchar2(1);
    lv_amt       acc_account_sub.bal%type;
    lv_deal_time date;
  begin
    pk_public.p_getinputpara(av_in, --�������
                             12, --�������ٸ���
                             15, --����������
                             'pk_consume.accFreeze', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    --�������������Ϣ
    if av_res <> pk_public.cs_res_ok then
      return;
    end if;
    --��ȡ���������Ϣ
    begin
      select sysdate into lv_deal_time from dual;
      select clr_date into lv_clrdate from pay_clr_para t;
    exception
      when no_data_found then
        av_res := pk_public.cs_res_unknownerr;
        av_msg := '�������������Ϣ������';
        return;

    end;
    --���Ῠ�Ų���Ϊ��
    if lv_in(6) is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '���Ῠ�Ų���Ϊ��';
      return;
    end if;
    --�����˻����Ͳ���Ϊ��
    if lv_in(7) is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�����˻����Ͳ���Ϊ��';
      return;
    end if;
    --�������ȷ
    if lv_in(9) is null or lv_in(9) <= 0 then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�������ȷ';
      return;
    end if;
    if lv_in(5) is null then
      lv_in(5) := to_char(lv_deal_time, 'yyyymmddhh24miss');
    end if;
    --��ȡ��Ƭ��Ϣ
    pk_public.p_getcardbycardno(lv_in(6), lv_card, av_res, av_msg);
    if av_res <> pk_public.cs_res_ok THEN
      return;
    end if;
    --�жϿ�״̬
    if lv_card.card_state <> '1' then
      av_res := pk_public.cs_res_accstateerr;
      av_msg := '��״̬������';
      return;
    end if;
    pk_public.p_getsubledgerbycardno(lv_in(6), --����
                                     lv_in(7), --�˻�����
                                     pk_public.cs_defaultwalletid, --Ǯ�����
                                     lv_acc_account_sub, --�ֻ���
                                     av_res, --������������
                                     av_msg --��������������Ϣ
                                     );
    if av_res <> pk_public.cs_res_ok THEN
      return;
    end if;
    --�ж��˻�״̬�Ƿ�����
    if lv_acc_account_sub.acc_state <> '1' then
      av_res := pk_public.cs_res_accstateerr;
      av_msg := '�˻�״̬������';
      return;
    end if;
    if lv_acc_account_sub.bal - lv_acc_account_sub.credit_lmt -
       lv_acc_account_sub.frz_amt < lv_in(9) THEN
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '�˻�����';
      return;
    end if;
    --�����ʱ�Ѷ����� + �¶����� = �˻����  ��Ϊ2ȫ������ ������1���ֶ���
    if lv_acc_account_sub.bal = (lv_acc_account_sub.frz_amt + lv_in(9)) then
      isAllFreeze := '2';
    else
      isAllFreeze := '1';
    end if;
    --�����˻��Ķ������,�����־
    update acc_account_sub t
       set t.frz_amt  = nvl(t.frz_amt, 0) + lv_in(9),
           t.frz_date = lv_deal_time,
           t.frz_flag = isAllFreeze
     where t.card_no = lv_in(6)
       and t.acc_kind = lv_in(7) return t.bal into lv_amt;
    if sql%rowcount <> 1 then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '��������' || sql%rowcount || '��';
      return;
    end if;
    if lv_amt <> lv_in(10) then
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '�˻�ԭʼ����б䶯�������½��в���';
      return;
    end if;
    if lv_in(1) is null then
      select seq_action_no.nextval into lv_in(1) from dual;
    end if;
    insert into acc_freeze_rec b
      (b.deal_no,
       b.acpt_id,
       b.end_id,
       b.deal_batch_no,
       b.end_deal_no,
       b.deal_date,
       b.deal_amt,
       b.frz_amt,
       b.deal_code,
       b.frz_type,
       b.acc_no,
       b.card_no,
       b.acc_kind,
       b.frz_flag,
       b.acc_bal,
       --b.old_deal_no,
       b.insert_date,
       b.user_id,
       b.rec_type,
       b.clr_date,
       --b.cancel_deal_batch_no,
       --b.cancel_end_deal_no,
       --b.cancel_reason,
       b.flag,
       b.end_sign_state,
       b.note)
    values
      (lv_in(1), --��ˮ��
       lv_in(2), --�����
       lv_in(13), --�����ն˱��
       lv_in(11), --���κ�
       lv_in(12), --�ն˽�����ˮ��
       to_date(lv_in(5), 'yyyymmddhh24miss'), --��������
       0,
       lv_in(9),
       50601010, --���ύ����
       lv_in(14), --��������
       lv_acc_account_sub.acc_no,
       lv_in(6),
       lv_in(7),
       isAllFreeze,
       (lv_acc_account_sub.bal - to_number(lv_in(9))),
       --'',--ԭʼ��ˮ��
       lv_deal_time, --���ʱ��
       lv_in(4), --�����Ա
       '0', --��������
       lv_clrdate,
       '0',
       '0',
       lv_in(15));
    av_res := pk_public.cs_res_ok;
    av_msg := '';
    av_out := lv_in(1) || '|' || lv_clrdate || '|' ||
              to_char(lv_deal_time, 'yyyymmddhh24miss');
  exception
    when others then
      rollback;
      av_res := pk_public.cs_res_unknownerr;
      av_msg := sqlerrm;
  end p_accFreeze;
  /**
    --�˻����ⶳ
    ������Ϣ
    --       1deal_no       ��ˮ��
    --       2acpt_id       �������(����Ż��̻����)
    --       3acpt_type     ��������
    --       4user_id       ����Ա/�ն˺�
    --       5deal_time     ����ʱ��--�յĻ�ȡ�洢������ȡ���ݿ�ʱ��
    --       6old_deal_no   ԭʼ������ˮ
    --       7pwd           ����
    --       8deal_batch_no ���κ�
    --       9end_deal_no   �ն˽�����ˮ��
    --       10end_id        �ն˱��
    --       11note         ��ע
  */
  procedure p_accUnFreeze(av_in    in varchar2,
                          av_debug in varchar2,
                          av_res   out varchar2,
                          av_msg   out varchar2,
                          av_out   out varchar2) as
    lv_in         pk_public.myarray; --�����������
    lv_acc_freeze acc_freeze_rec%rowtype;
    --lv_deal_no acc_freeze_rec.deal_no%type;
    lv_clrdate          acc_freeze_rec.clr_date%type;
    lv_deal_time        acc_freeze_rec.deal_date%type;
    isAllFreeze         acc_freeze_rec.frz_flag%type;
    lv_acc_account_sub  acc_account_sub%rowtype;
    lv_amt              acc_account_sub.bal%type;
    lv_freeze_amt       acc_account_sub.frz_amt%type;
    lv_last_update_time acc_account_sub.frz_date%type;
  begin
    pk_public.p_getinputpara(av_in, --�������
                             11, --�������ٸ���
                             11, --����������
                             'pk_consume.accUnFreeze', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    --�������������Ϣ
    if av_res <> pk_public.cs_res_ok then
      return;
    end if;
    --��ȡ���������Ϣ
    begin
      select sysdate into lv_deal_time from dual;
      select clr_date into lv_clrdate from pay_clr_para;
    exception
      when no_data_found then
        av_res := pk_public.cs_res_unknownerr;
        av_msg := '�������������Ϣ������';
        return;

    end;
    if lv_in(6) is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := 'ԭʼ�˻�������ˮ����Ϊ��';
      return;
    end if;
    if lv_in(5) is null then
      lv_in(5) := to_char(lv_deal_time, 'yyyymmddhh24miss');
    end if;
    begin
      select *
        into lv_acc_freeze
        from acc_freeze_rec
       where deal_no = lv_in(6)
         and deal_code = '50601010';
    exception
      when others then
        av_res := pk_public.cs_res_unknownerr;
        av_msg := '����ԭʼ������ˮδ�ҵ���Ч���˻������¼��Ϣ���ѳɹ��ⶳ�����ظ��ⶳ';
        return;
    end;
    if lv_acc_freeze.rec_type <> '0' then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := 'ԭʼ�˻������¼״̬������';
      return;
    end if;
    pk_public.p_getsubledgerbycardno(lv_acc_freeze.card_no, --����
                                     lv_acc_freeze.acc_kind, --�˻�����
                                     pk_public.cs_defaultwalletid, --Ǯ�����
                                     lv_acc_account_sub, --�ֻ���
                                     av_res, --������������
                                     av_msg --��������������Ϣ
                                     );
    if av_res <> pk_public.cs_res_ok THEN
      return;
    end if;
    if lv_acc_account_sub.bal < lv_acc_freeze.frz_amt then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�ⶳ�������˻����';
      return;
    end if;
    --������ʷ��  �Ƿ����ͬһ�������ͬһ�̻��Ľⶳ��?
    lv_acc_freeze.rec_type             := '1';
    lv_acc_freeze.cancel_deal_batch_no := lv_in(8);
    lv_acc_freeze.cancel_end_deal_no   := lv_in(9);
    lv_acc_freeze.cancel_reason        := lv_in(11);
    insert into acc_freeze_his values lv_acc_freeze;
    if lv_in(1) is null then
      select seq_action_no.nextval into lv_in(1) from dual;
    end if;
    lv_acc_freeze.deal_no       := lv_in(1); --����ˮ
    lv_acc_freeze.old_deal_no   := lv_in(6); --ԭʼ��ˮ
    lv_acc_freeze.rec_type      := '0'; --�ⶳ��¼״̬
    lv_acc_freeze.acpt_id       := lv_in(2);
    lv_acc_freeze.user_id       := lv_in(4);
    lv_acc_freeze.deal_date     := to_date(lv_in(5), 'yyyymmddhh24miss');
    lv_acc_freeze.deal_batch_no := lv_in(8);
    lv_acc_freeze.end_deal_no   := lv_in(9);
    lv_acc_freeze.end_id        := lv_in(10);
    lv_acc_freeze.note          := lv_in(11);
    lv_acc_freeze.clr_date      := lv_clrdate;
    lv_acc_freeze.insert_date   := lv_deal_time;
    lv_acc_freeze.deal_code     := '50601021';
    insert into acc_freeze_rec values lv_acc_freeze;
    delete from acc_freeze_rec where deal_no = lv_in(6);
    --����˻�������ͽⶳ�����ͬ ���˻���Ϊ����״̬,���� ��Ϊ���ֶ���
    if lv_acc_account_sub.frz_amt = lv_acc_freeze.frz_amt then
      isAllFreeze         := '0';
      lv_last_update_time := null;
    else
      begin
        select max(c.insert_date)
          into lv_last_update_time
          from acc_freeze_rec c
         where c.card_no = lv_acc_freeze.card_no
           and c.acc_kind = lv_acc_freeze.acc_kind
           and c.deal_code = '50601010'
           and c.rec_type = '0';
      exception
        when others then
          lv_last_update_time := lv_deal_time;
      end;
      isAllFreeze := '1';
    end if;
    --�����˻��Ķ������,�����־
    update acc_account_sub t
       set t.frz_amt  = nvl(t.frz_amt, 0) - lv_acc_freeze.frz_amt,
           t.frz_date = lv_last_update_time,
           t.frz_flag = isAllFreeze
     where t.card_no = lv_acc_freeze.card_no
       and t.acc_kind = lv_acc_freeze.acc_kind return t.bal,
     t.frz_amt into lv_amt, lv_freeze_amt;
    if sql%rowcount <> 1 then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '��������' || sql%rowcount || '��';
      return;
    end if;
    if lv_freeze_amt < 0 then
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '�ⶳ�������˻������ܽ��';
      return;
    end if;
    if lv_amt <> lv_acc_account_sub.bal then
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '�˻�ԭʼ����б䶯�������½��в���';
      return;
    end if;
    av_res := pk_public.cs_res_ok;
    av_msg := '';
    av_out := lv_in(1) || '|' || lv_clrdate || '|' ||
              to_char(lv_deal_time, 'yyyymmddhh24miss');
  exception
    when others then
      rollback;
      av_res := pk_public.cs_res_unknownerr;
      av_msg := sqlerrm;
  end p_accUnFreeze;
  
  
  
  /*=======================================================================================*/
  --�ѻ����ݴ���twz
  --av_deal_no ��ˮ��
  --�ܸ�ԭ��:00����Ƭ���з�����01��tac���02�����ݷǷ�03�������ظ�04���Ҽ�¼05������06-��������09�����ܸ�10��������
  /*=======================================================================================*/
  PROCEDURE p_offlineconsume_twz(av_deal_no    IN VARCHAR2, --�������
                             av_debug IN VARCHAR2, --1����
                             av_res   OUT VARCHAR2, --��������
                             av_msg   OUT VARCHAR2 --����������Ϣ
                             ) is 
        lv_dbsubledger     acc_account_sub%ROWTYPE; --���˻�
        lv_crsubledger     acc_account_sub%ROWTYPE; --�̻��������
        lv_pointssubledger acc_account_sub%ROWTYPE; --���������˻�
        lv_merchant        base_merchant%ROWTYPE; --�̻�
        lv_clrdate         pay_clr_para.clr_date%TYPE; --�������
        lv_tablename       VARCHAR2(50);
        lv_count           NUMBER;
        lv_sumAmt          NUMBER;
        lv_in              pk_public.myarray; --�����������
        lv_operator        sys_users%ROWTYPE; --admin����Ա
        lv_dd              TIMESTAMP := systimestamp;
        lv_deal_date       DATE;
        lv_offline         pay_offline%rowtype;
        ------------------------------------------------------------------------------------
        --�Ƶ��ܸ���
        ------------------------------------------------------------------------------------
        PROCEDURE p_move2black(av_actionno NUMBER, av_reason VARCHAR2) IS
        BEGIN
          UPDATE pay_offline
             SET refuse_reason = av_reason
           WHERE deal_no = av_actionno;
          INSERT INTO pay_offline_black
            SELECT * FROM pay_offline WHERE deal_no = av_actionno;
          DELETE FROM pay_offline WHERE deal_no = av_actionno;
        END p_move2black;
   begin
          -----------------------------------------------------------------------------------
          --1��ȡ������� ϵͳ������ȡ
          -----------------------------------------------------------------------------------
          if av_deal_no is null then
              av_res := pk_public.cs_res_ok;
              return;
          end if;
          
          pk_public.p_insertrzcllog_('2',
                                     'p_offlineconsume begin clr_date:' || av_Deal_no,
                                     pk_public.f_timestamp_diff(systimestamp,
                                                                lv_dd));
          SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
          
          select count(1) into lv_count from pay_offline t WHERE deal_no = av_deal_no;
          
          if lv_count = 0 then
              av_res := pk_public.cs_res_ok;
              return;
          end if;
          
          SELECT  * into lv_offline FROM pay_offline t WHERE deal_no = av_deal_no;
          
          --ȡ�̻���������˻�
          SELECT *
            INTO lv_merchant
            FROM base_merchant
           WHERE merchant_id = lv_offline.acpt_id;
          pk_public.p_getsubledgerbyclientid(lv_merchant.customer_id, --�̻�client_id
                                             pk_public.cs_accitem_biz_clr, --�̻��������
                                             lv_crsubledger,
                                             av_res,
                                             av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;

          --ȡ���������˻�
          pk_public.p_getorgoperator(lv_merchant.org_id, --�������
                                     lv_operator, --��Ա
                                     av_res, --������������
                                     av_msg --��������������Ϣ
                                     );
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
          
          pk_public.p_getorgsubledger(lv_operator.org_id,
                                      pk_public.cs_accitem_org_points,
                                      lv_pointssubledger,
                                      av_res,
                                      av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
          
          -----------------------------------------------------------------------------------
          --3��������ʱ������
          -----------------------------------------------------------------------------------
          pk_public.p_insertrzcllog_('2',
                                     'p_offlineconsume begin temp:' || av_Deal_no,
                                     pk_public.f_timestamp_diff(systimestamp,
                                                                lv_dd));
          
          --ȡ���ֻ���
          pk_public.p_getsubledgerbycardno(lv_offline.card_no, --����
                                           pk_public.cs_acckind_qb, --�˻�����
                                           pk_public.cs_defaultwalletid, --Ǯ�����
                                           lv_dbsubledger, --�ֻ���
                                           av_res, --������������
                                           av_msg --��������������Ϣ
                                           );
          -------------------------------------------------------------------------------
          --3.0���жϽ���ʱ���ʽ�Ƿ���ȷ
          -------------------------------------------------------------------------------
          BEGIN
            SELECT to_date(lv_offline.deal_date, 'yyyymmddhh24miss')
              INTO lv_deal_date
              FROM dual;
          EXCEPTION
            WHEN OTHERS THEN
              p_move2black(lv_offline.deal_no, '07');
               GOTO templooplabel;
          END;
          -------------------------------------------------------------------------------
          --3.1���˻�������02
          -------------------------------------------------------------------------------
          IF av_res <> pk_public.cs_res_ok THEN
            p_move2black(lv_offline.deal_no, '02');
             GOTO templooplabel;
          END IF;
          
          -------------------------------------------------------------------------------
          --3.2��tac��01 �Ҽ�¼04
          -------------------------------------------------------------------------------
          IF lv_offline.refuse_reason IN ('01', '04') THEN
            p_move2black(lv_offline.deal_no, lv_offline.refuse_reason);
              GOTO templooplabel;
          ELSIF lv_offline.ash_flag = '01' THEN
            p_move2black(lv_offline.deal_no, '04');
              GOTO templooplabel;
          END IF;
          
          -------------------------------------------------------------------------------
          --3.4������05
          -------------------------------------------------------------------------------
          IF lv_offline.deal_amt > lv_dbsubledger.bal THEN
            p_move2black(lv_offline.deal_no, '05');
              GOTO templooplabel;
          END IF;
                    
          -------------------------------------------------------------------------------
          --3.3�������ظ�03
          -------------------------------------------------------------------------------
          lv_tablename := pk_public.f_gettrcardtable(lv_offline.card_no,
                                                     to_date(lv_offline.deal_date,
                                                             'yyyymmddhh24miss'));
          EXECUTE IMMEDIATE 'select count(*) from ' || lv_tablename ||
                            ' where card_no = :1 and CARD_COUNTER = :2 and acc_kind = ''01'''
            INTO lv_count
            USING lv_offline.card_no, lv_offline.card_deal_count;
          IF lv_count > 0 THEN
            p_move2black(lv_offline.deal_no, '03');
              GOTO templooplabel;
          END IF;   
          
          select count(*) into lv_count from pay_offline_list t where t.card_no=lv_offline.card_no and t.card_deal_count=lv_offline.card_deal_count and t.tac=lv_offline.tac;       
          IF lv_count > 0 THEN
            p_move2black(lv_offline.deal_no, '03');
              GOTO templooplabel;
          END IF;  
          -------------------------------------------------------------------------------
          --3.5����������06
          -------------------------------------------------------------------------------
          -------------------------------------------------------------------------------
          --3.6����������
          -------------------------------------------------------------------------------
          pk_public.p_insertrzcllog_('2',
                                     'p_offlineconsume begin p_writedaybook:' ||
                                     av_Deal_no,
                                     pk_public.f_timestamp_diff(systimestamp,
                                                                lv_dd));
          --д��ˮ �ۿ� ����
          p_writedaybook(lv_offline, --�ѻ��ļ���¼
                         lv_dbsubledger, --��Ǯ���˻�
                         lv_crsubledger, --�̻���������˻�
                         lv_pointssubledger, --���������˻�
                         lv_operator, --����Ա
                         lv_clrdate, --�������
                         av_debug, --1����
                         av_res, --��������
                         av_msg --����������Ϣ
                         );
          IF av_res <> pk_public.cs_res_ok THEN
            --ROLLBACK;
            --GOTO templooplabel;
            RETURN;
          END IF;

          pk_public.p_insertrzcllog_('2',
                                     'p_offlineconsume end p_writedaybook:' ||
                                     lv_offline.deal_no,
                                     pk_public.f_timestamp_diff(systimestamp,
                                                                lv_dd));
          --�ƶ�����
          --   lv_tablename := 'tr_offline_' || REPLACE(lv_clrdate, '-', '');
          UPDATE pay_offline
             SET clr_date = lv_clrdate
           WHERE deal_no = lv_offline.deal_no;

          insert into pay_offline_list values lv_offline;
          delete from pay_offline t where t.deal_no = lv_offline.deal_no;
         
           
          pk_public.p_insertrzcllog_('2',
                                     'p_offlineconsume end move:' ||
                                     lv_offline.deal_no,
                                     pk_public.f_timestamp_diff(systimestamp,
                                                                lv_dd));
            -------------------------------------------------------------------------------
            --3.7����¼�������
            -------------------------------------------------------------------------------
             <<templooplabel>>
            COMMIT;
            select count(1) into lv_count from pay_offline t where t.send_file_name = lv_offline.send_file_name;
            if lv_count = 0 then
                UPDATE pay_offline_filename
                       SET state = '3'
                WHERE send_file_name = lv_offline.send_file_name
                       AND state = '2';
                 --���´�������ȷ�ϱ�����ȷ�Ͻ��ܸ������;ܸ���� �����������͵������
                select count(1), sum(t.deal_amt)
                  into lv_count, lv_sumAmt
                  from pay_offline_list t
                 where t.send_file_name = lv_offline.send_file_name;
                update pay_offline_filename t1
                   set t1.confirm_num = lv_count, t1.confirm_amt = lv_sumAmt
                 where t1.send_file_name = lv_offline.send_file_name;

                select count(1), sum(t.deal_amt)
                  into lv_count, lv_sumAmt
                  from pay_offline_black t
                 where t.send_file_name = lv_offline.send_file_name;
                update pay_offline_filename t1
                   set t1.refuse_num = lv_count, t1.refuse_amt = lv_sumAmt
                 where t1.send_file_name = lv_offline.send_file_name;
            end if;
   end p_offlineconsume_twz;
   
   
BEGIN
  -- initialization
  NULL;
END pk_consume;
/

