CREATE OR REPLACE PACKAGE BODY pk_consume_ghk IS
  /*=======================================================================================*/
  --��������_�жϿ����Ƿ�׼������

  --merchantid IN VARCHAR2,--�̻����
  --cardno     IN VARCHAR2,--����
  --sqn_mode   IN varchar2,--�̻�����ģʽmerchantid      �̻���

  /*=======================================================================================*/
    PROCEDURE p_checkIDinfo(merchantid IN VARCHAR2,--�̻����
                          cardno     IN VARCHAR2,--����
                          sqn_mode   IN VARCHAR2,--�̻�����ģʽ
                          av_sqn_mode OUT pay_acctype_sqn%ROWTYPE,--��������ģʽ
                          av_res      OUT VARCHAR2, --��������
                          av_msg      OUT VARCHAR2 --����������Ϣ
    ) IS
        lv_card          card_baseinfo%ROWTYPE;
        lv_base_merchant base_merchant%ROWTYPE;
        lv_base_person   base_personal%ROWTYPE;
        lv_unionbizid    VARCHAR2(20);
        lv_count         NUMBER;
    BEGIN
        av_res := pk_public.cs_res_ok;
        BEGIN
             SELECT * INTO lv_base_merchant FROM base_merchant t WHERE t.merchant_id =merchantid  AND merchant_state = '0';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             av_res := pk_public.cs_res_busierr;
             av_msg := '�̻���Ϣ��֤ʧ��';
             RETURN;
        END;
         BEGIN
             SELECT * INTO lv_card FROM card_baseinfo t WHERE t.card_no = cardno;
             IF lv_card.customer_id IS NOT NULL THEN
                 select * INTO lv_base_person FROM base_personal t WHERE t.customer_id = lv_card.customer_id;
                 IF lv_base_person.cert_no IS NOT NULL THEN
                    --��ѯ������Ա��Ϣ�Ƿ���������̻�
                    /*SELECT a.attr_merchant_id INTO lv_unionbizid FROM base_unionist@con_union_link a WHERE a.card_no = cardno;
                    IF lv_unionbizid <> lv_base_merchant.merchant_id THEN
                        av_res :=pk_public.cs_res_checkcongh_walerr;
                        av_msg :='������Ա��׼���ڸ��̻�������';
                        RETURN;
                    END IF;*/
                    --�жϸÿ��Ƿ񿪹����̻��¹���������ģʽ��Ӧ���˻�
                    if sqn_mode IS NULL  then
                        --����ģʽΪ��ʱ���򿴵�ǰ�̻��Ƿ�ֻ��һ������ģʽ�����ж������쳣��һ����ȡ��
                        select count(*) into lv_count from  BASE_MERCHANT_MODE t where t.merchant_id=merchantid and t.mode_state='0';
                        if lv_count <> 1 then
                          av_res := pk_public.cs_res_paravalueerr;
                          av_msg := '���̻��ж�������ģʽ����ָ��ģʽ��������';
                          return;
                        end if;
                        select t.* into av_sqn_mode
                        from PAY_ACCTYPE_SQN t where t.mode_id = (select b.mode_id from BASE_MERCHANT_MODE b where b.merchant_id=merchantid and t.mode_state='0');
                    ELSE
                        --�жϴ��������ģʽ�Ƿ����ڸ��̻�
                        SELECT COUNT(1) INTO lv_count FROM base_merchant_mode t WHERE t.merchant_id = merchantid AND t.mode_id = sqn_mode;
                        IF lv_count = 0 THEN
                            av_res := pk_public.cs_res_sqnmode_mererr;
                            av_msg := '������̻�����ģʽ����ȷ';
                        END IF;
                        --ȡָ��������ģʽ
                        SELECT COUNT(1) INTO lv_count FROM PAY_ACCTYPE_SQN y WHERE y.mode_id =sqn_mode;
                        IF lv_count = 0 THEN
                            av_res := pk_public.cs_res_sqnmode_mererr;
                            av_msg := '������̻�����ģʽ����ȷ';
                        END IF;
                        SELECT t.*
                          INTO av_sqn_mode
                          from PAY_ACCTYPE_SQN t
                          WHERE t.mode_id = sqn_mode
                          AND t.mode_state = '0';

                    end if;
                 ELSE
                     av_res := pk_public.cs_res_personalvil_err;
                     av_msg := '�ͻ���Ϣ��֤ʧ��';
                     RETURN;
                 END IF;
             ELSE
               av_res := pk_public.cs_res_cardiderr;
               av_msg := 'δ�ҵ���Ӧ�Ŀ���Ϣ';
               RETURN;
             END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             av_res := pk_public.cs_no_datafound_err;
             RETURN;
        END;

       EXCEPTION
          WHEN OTHERS THEN
            av_res := pk_public.cs_res_unknownerr;
            av_msg :='���ݿ�δ֪����';
            RETURN;

    END  p_checkIDinfo;

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
  --��ȡ�˻�������Ϣ�����ظ��˻��ۿۺ����¼�˴����ѵ��ۿ���Ϣ
  /*=======================================================================================*/
  PROCEDURE p_getrealdealamt(av_bizid      IN VARCHAR2, --�̻���
                        av_acc_kind     IN VARCHAR2, --�˻���
                        av_amt          IN NUMBER,--ԭʼ���׽��
                        av_discount_info OUT VARCHAR2,--�ۿ���
                        av_real_amt      OUT VARCHAR2,--ʵ�����ѽ��
                        av_res        OUT VARCHAR2, --��������
                        av_msg        OUT VARCHAR2 --����������Ϣ
                        ) IS
     lv_base_merchant_discount base_merchant_discount%ROWTYPE;
     ls_days    pk_public.myarray; --�û����۷�ʽ��������
     ln_count   NUMBER;
     as_clrdate varchar2(10);
     ln_three_amt NUMBER;

      --�ж��Ƿ񵽴������������ ���û��ֱ�ӷ����޴��۵Ľ��
      FUNCTION f_candiscount(as_clrdate     VARCHAR2,
                            lv_base_merchant_discount base_merchant_discount%Rowtype) RETURN VARCHAR2 IS
        ls_days  pk_public.myarray;
        ln_count NUMBER;
      BEGIN
        IF lv_base_merchant_discount.DISCOUNT_TYPE = '2' THEN  -- �ܷ�ʽ�Ĵ���
            --�жϽ����Ƿ����
            ln_count := pk_public.f_splitstr(lv_base_merchant_discount.discount_txt, '|', ls_days);
            FOR i IN 1 .. ln_count LOOP
              IF to_char(to_date(as_clrdate, 'yyyy-mm-dd'), 'd') - 1 =
                 CASE ls_days(i)
                   WHEN '7' THEN
                    '0'
                   ELSE
                    ls_days(i)
                 END THEN
                RETURN '1';
              END IF;
            END LOOP;

         ELSIF lv_base_merchant_discount.DISCOUNT_TYPE = '2' THEN  -- �´��۷�ʽ
            ln_count := pk_public.f_splitstr(lv_base_merchant_discount.discount_txt, '|', ls_days);
            FOR i IN 1 .. ln_count LOOP
              IF to_number(substr(as_clrdate, 9, 2)) = to_number(ls_days(i)) --������ͬ
                 OR ls_days(i) = 32 AND --�������µ׽��㲢�����µ�
                 to_date(as_clrdate, 'yyyy-mm-dd') =
                 last_day(to_date(as_clrdate, 'yyyy-mm-dd')) THEN
                RETURN '1';
              END IF;
            END LOOP;
         ELSIF lv_base_merchant_discount.DISCOUNT_TYPE = '1' THEN  -- ָ�����ڴ��۷�ʽ
           IF lv_base_merchant_discount.discount_txt = as_clrdate THEN
              RETURN '1';
           END IF;
         ELSE --û�����þͰ���0���۵ķ�ʽ���м���
            RETURN '0';
         END IF;
        --û����������
        RETURN '0';
      END f_candiscount;
  BEGIN


     av_res :=pk_public.cs_res_ok;
     SELECT t.clr_date INTO as_clrdate FROM pay_clr_para t;
     --��ȡ������Ч�Ĵ�����Ϣ
     BEGIN
       SELECT * INTO lv_base_merchant_discount FROM base_merchant_discount t
              WHERE t.merchant_id =av_bizid AND t.acc_kind = av_acc_kind AND STARTDATE =
               (SELECT MAX(STARTDATE)
                  FROM base_merchant_discount
                 WHERE merchant_id = av_bizid
                   AND acc_kind = av_acc_kind
                   AND STATE = '1'
                   AND STARTDATE <= SYSDATE);
     --��ʼ������˻���ʵ�����ѽ��
      IF f_candiscount(as_clrdate,
                       lv_base_merchant_discount) ='1' THEN
          av_discount_info := lv_base_merchant_discount.discount;
          IF instr((lv_base_merchant_discount.discount/100)*av_amt,'.')>0 THEN
             av_real_amt  := f_getthreenumber(to_char((lv_base_merchant_discount.discount/100)*av_amt,'fm9999999990.000000000'));
          ELSE
             av_real_amt  := f_getthreenumber((lv_base_merchant_discount.discount/100)*av_amt);
          END IF;


      ELSE
           av_discount_info :='100';
           av_real_amt:=av_amt;
      END IF;
     EXCEPTION
        WHEN no_data_found THEN
           av_discount_info :='100';
           av_real_amt:=av_amt;
           av_res := pk_public.cs_res_ok;
           av_msg := 'δ�ҵ��κ��ۿ���Ϣ';

     END;




  END p_getrealdealamt;

 /*=======================================================================================*/
  --��������_����
  --av_in: ���ֶ���|�ָ�
  --       1tr_code    ���״���
  --       2card_no    ����
  --       3tr_amt     ���ѽ��
  --       4mode_no    ����ģʽ
  --       5av_bizid    ����������/�̻����
  --av_out: �˻��б�acclist
  --      acclist      �˻��б� acc_kind$amt$balance$balance_encrypt$discount$accname,acc_kind$amt$balance$balance_encrypt$discount$accname
  /*=======================================================================================*/
  PROCEDURE p_onlineconsume_calc(av_in  IN VARCHAR2, --�������
                                 av_res OUT VARCHAR2, --��������
                                 av_msg OUT VARCHAR2, --����������Ϣ
                                 av_out OUT VARCHAR2, --��������
                                 av_cash_amt OUT VARCHAR2--�ֽ𸶿���
                                 ) IS
    lv_count     NUMBER;
    lv_in        pk_public.myarray; --�����������
    lv_mode      PAY_ACCTYPE_SQN%ROWTYPE; --����ģʽ
    lv_acclist   pk_public.myarray; --�����˻�����
    lv_subledger acc_account_sub%ROWTYPE; --���ֻ���
    lv_tempamt   NUMBER; --�ֻ��˿۷ѽ��
    lv_realamt   NUMBER;
    lv_discountinfo NUMBER;
    lv_merchantlimit pay_merchant_lim%ROWTYPE; --
    lv_detail_tablename varchar(50);
    lv_clrdate       pay_clr_para.clr_date%type; --�������
    lv_acc_name  VARCHAR2(50);
    lv_real_discoutamt NUMBER;
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
       p_checkIDinfo(lv_in(5),
                     lv_in(2),
                     lv_in(4),
                     lv_mode,
                     av_res,
                     av_msg);
       IF av_res <> pk_public.cs_res_ok THEN
           av_res := pk_public.cs_res_sqngetmode_mererr;
           av_msg := '��֤�ͻ����̻������ݳ���';
            RETURN;
       END IF;
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_paravalueerr;
        av_msg := '��֤�ͻ����̻������ݳ���';
        RETURN;
    END;

    lv_count := pk_public.f_splitstr(lv_mode.ACC_SQN, '|', lv_acclist);
    IF lv_count <= 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '������ģʽû���˺�';
      RETURN;
    END IF;
    --�ж��̻������޶�
    BEGIN
      SELECT t.*
        INTO lv_merchantlimit
        FROM pay_merchant_lim t
       WHERE t.merchant_id = lv_in(5);
       --�Ƿ񵥴γ���
      IF lv_merchantlimit.lim_01 > 0 THEN
        IF lv_in(10) > lv_merchantlimit.lim_01 THEN
          av_res := pk_public.cs_res_consume_quotas_amt;
          av_msg := '�̻��������ѳ��޶�';
          RETURN;
        END IF;
      END IF;
      --�Ƿ����Ѵ�������
      if lv_merchantlimit.lim_02 >0 then
         execute immediate 'select count(DEAL_NO) from '||lv_detail_tablename||' where DEAL_STATE=0 and DB_CARD_NO=:1 and CLR_DATE=:2 and DEAL_CODE=:3'
         into lv_count
         using lv_in(8),lv_clrdate,lv_in(2);
         if lv_merchantlimit.lim_02 <= lv_count then
           av_res := pk_public.cs_res_consume_quotas_amt;
           av_msg := '���������Ѵ����Ѵ�����';
           return;
         end if;
      end if;
      --�Ƿ������ѽ���
      if lv_merchantlimit.lim_03 >0 then
         execute immediate 'select sum(DB_AMT) from '||lv_detail_tablename||' where DEAL_STATE=0 and DB_CARD_NO=:1 and CLR_DATE=:2 and DEAL_CODE=:3'
         into lv_count
         using lv_in(8),lv_clrdate,lv_in(2);
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
        --ȡ���˻��Ĵ��۽��

         p_getrealdealamt(lv_in(5),lv_acclist(i),lv_in(3),lv_discountinfo,lv_realamt,av_res,av_msg);

         lv_real_discoutamt := lv_in(3)*(lv_discountinfo/100);
         IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
         END IF;
        --����۳����
        lv_in(3) := lv_realamt;
        IF lv_subledger.bal - lv_subledger.frz_amt >= lv_realamt THEN
          lv_tempamt := lv_realamt;
        ELSE
          --��ǰ�˻�����ʱ����۳�ȫ�����
          lv_tempamt := lv_subledger.bal - lv_subledger.frz_amt;
        END IF;
        lv_in(3) := lv_in(3) - lv_tempamt;
        lv_real_discoutamt :=  lv_real_discoutamt - lv_tempamt;
        --��װ���ز���
        IF lv_tempamt > 0 THEN
          IF av_out IS NOT NULL THEN
            av_out := av_out || ',';
          END IF;
          SELECT t1.acc_name INTO lv_acc_name FROM acc_kind_config t1 WHERE t1.acc_kind = lv_subledger.acc_kind;
          av_out := av_out || lv_subledger.acc_kind || '$' || lv_tempamt || '$' ||
                    lv_subledger.bal || '$' ||
                    lv_subledger.bal_crypt|| '$' ||lv_discountinfo|| '$' ||lv_acc_name;
        END IF;
        if lv_in(3)=0 then
          --�����ѽ��Ϊ0�����˳�LOOP
          exit;
         end if;
         lv_in(3) :=to_char(lv_real_discoutamt/(lv_discountinfo/100),'fm9999999990.000000000');
      END IF;
    END LOOP;
    av_cash_amt := lv_in(3);
    av_res := pk_public.cs_res_ok;
    av_msg := '';

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
    lv_count         NUMBER;
    lv_in            pk_public.myarray; --�����������
    lv_acclist       pk_public.myarray; --�˻��б�
    lv_acc           pk_public.myarray; --�˻�
    lv_dbsubledger   acc_account_sub%ROWTYPE;--�跽�ֻ���
    lv_crsubledger   acc_account_sub%ROWTYPE; --�����ֻ���
    lv_clrdate       pay_clr_para.clr_date%type; --�������
    lv_accbookno     ACC_INOUT_DETAIL.ACC_INOUT_NO%TYPE; --������ˮ��
    lv_card          card_baseinfo%ROWTYPE; --��������Ϣ
    lv_merchant      base_merchant%ROWTYPE; --�̻�
    lv_merchantlimit pay_merchant_lim%ROWTYPE; --�̻������޶��
    lv_detail_tablename varchar(50);
    lv_ACC_CREDIT_LIMIT ACC_CREDIT_LIMIT%ROWTYPE;--���˻����Ʋ���
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
    lv_detail_tablename := 'ACC_INOUT_DETAIL_' || substr(REPLACE(lv_clrdate, '-', ''),0,6);




    --��֤�����Ƿ��ظ�
    EXECUTE IMMEDIATE 'select count(DEAL_NO) from ' ||
                      lv_detail_tablename ||
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
                            lv_crsubledger.org_id,--��������
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
    lv_in        pk_public.myarray; --�����������
    lv_clrdate   pay_clr_para.clr_date%type; --�������
    lv_cursor    pk_public.t_cur; --�α�
    lv_temp      VARCHAR2(100);
    lv_tablename VARCHAR2(50);
    lv_actionno  VARCHAR2(20); --ԭ����action_no
    lv_acc_input_no varchar2(50);--������ˮ
    lv_count         NUMBER;
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
    lv_tablename := 'ACC_INOUT_DETAIL_' || substr(REPLACE(lv_clrdate, '-', ''),0,6);

    OPEN lv_cursor FOR 'select t1.ACC_INOUT_NO,t1.deal_no,t2.acc_kind || ''$'' || t1.db_amt || ''$'' || t2.bal || ''$'' || t2.bal_crypt ' || --
     ' from ' || lv_tablename || ' t1,acc_account_sub t2' || --
     ' where t1.db_acc_no = t2.acc_no and t1.deal_state = 0 ' || --
     ' and t1.acpt_id = :1 and t1.user_id = :2 and t1.deal_batch_no = :3 and t1.end_deal_no = :4 and t1.db_card_no=:5'
      USING lv_in(1), lv_in(2), lv_in(3), lv_in(4),lv_in(5);
    LOOP
      FETCH lv_cursor
        INTO lv_acc_input_no,lv_actionno, lv_temp;
      EXIT WHEN lv_cursor%NOTFOUND;
      --�����Ƿ���ڳ������������˻��ȼ�¼
      EXECUTE IMMEDIATE 'select count(*) from ' ||lv_tablename||' where OLD_ACC_INOUT_NO=:1 and DEAL_STATE =0'
        INTO lv_count
        USING lv_acc_input_no;
      if lv_count >0 then
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
    lv_in        pk_public.myarray; --�����������
    lv_clrdate   pay_clr_para.clr_date%type; --�������
    lv_cursor    pk_public.t_cur; --�α�
    lv_temp      VARCHAR2(100);
    lv_tablename VARCHAR2(50);
    lv_actionno  VARCHAR2(20); --ԭ����action_no
    lv_acc_input_no varchar2(50);--������ˮ
    lv_count         NUMBER;
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
    lv_tablename := 'ACC_INOUT_DETAIL_' || substr(REPLACE(lv_clrdate, '-', ''),0,6);

    OPEN lv_cursor FOR 'select t1.ACC_INOUT_NO,t1.deal_no,t2.acc_kind || ''$'' || t1.db_amt || ''$'' || t2.bal || ''$'' || t2.bal_crypt ' || --
     ' from ' || lv_tablename || ' t1,acc_account_sub t2' || --
     ' where t1.db_acc_no = t2.acc_no and t1.deal_state = 0 ' || --
     ' and t1.acpt_id = :1 and t1.user_id = :2 and t1.deal_batch_no = :3 and t1.deal_no = :4'
      USING lv_in(1), lv_in(2), lv_in(3), lv_in(4);
    LOOP
      FETCH lv_cursor
        INTO lv_acc_input_no,lv_actionno, lv_temp;
      EXIT WHEN lv_cursor%NOTFOUND;
      --�����Ƿ���ڳ������������˻��ȼ�¼
      EXECUTE IMMEDIATE 'select count(*) from ' ||lv_tablename||' where OLD_ACC_INOUT_NO=:1 and DEAL_STATE =0'
        INTO lv_count
        USING lv_acc_input_no;
      if lv_count >0 then
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
    lv_count    NUMBER;
    lv_in       pk_public.myarray; --�����������
    lv_acclist  pk_public.myarray; --�˻��б�
    lv_acc      pk_public.myarray; --�˻�
    lv_clrdate  pay_clr_para.clr_date%type; --�������
    lv_daybook  acc_inout_detail%ROWTYPE;
    lv_onedayBook acc_inout_detail%ROWTYPE;
    lv_sumamt   NUMBER; --�������ϸ�ܽ��
    lv_merchant base_merchant%ROWTYPE; --�̻�
    lv_tablename VARCHAR2(50);
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

    lv_tablename := 'ACC_INOUT_DETAIL_' || substr(REPLACE(lv_clrdate, '-', ''),0,6);
    lv_sumamt := 0;
    FOR i IN 1 .. lv_acclist.count LOOP
      lv_count := pk_public.f_splitstr(lv_acclist(i), '$', lv_acc);
      EXECUTE IMMEDIATE 'select * from ' ||lv_tablename||' where deal_no = :1 and db_acc_kind = :2 and DEAL_STATE = 0'
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
   /* IF lv_sumamt <> lv_in(9) THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '����������ܽ�����ϸ�еĽ�һ��';
      RETURN;
    END IF;*/
    EXECUTE IMMEDIATE 'select count(*) from acc_inout_detail_' ||
                      REPLACE(substr(lv_in(12),0,7), '-', '') ||
                      ' where deal_no = :1 and db_amt > 0 and deal_state = 0'
      INTO lv_count
      USING lv_in(11);
    IF lv_count <> 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '���ܲ��ֳ���';
      RETURN;
    END IF;
    -- ���³�����ˮΪ������ն���ˮ,���򱣴����ԭ���׵��ն���ˮ
    EXECUTE IMMEDIATE 'update  ' ||lv_tablename||' set end_deal_no = :1  where deal_no = :2'
        USING lv_in(7), lv_in(1);
    EXECUTE IMMEDIATE 'update  pay_card_deal_rec_' ||substr(REPLACE(lv_clrdate, '-', ''),0,6)||' set end_deal_no = :1  where deal_no = :2'
        USING lv_in(7), lv_in(1);

    -- ��������ļ�¼��old_acc_inout_no����Ҫ�޸�old_acc_inout_no
    --�ļ�¼Ϊ����״̬��ͬʱ�޸�pay_card_deal_rec
    IF lv_daybook.old_acc_inout_no IS NOT NULL THEN
         ---������ʼ������ˮ
        EXECUTE IMMEDIATE 'select * from ' ||lv_tablename||' where acc_inout_no = :1'
        INTO lv_onedayBook
        USING lv_daybook.old_acc_inout_no;

        EXECUTE IMMEDIATE 'update  ' ||lv_tablename||' set deal_state = 0  where deal_no = :1'
        USING lv_onedayBook.deal_no;
        EXECUTE IMMEDIATE 'update  pay_card_deal_rec_' ||substr(REPLACE(lv_clrdate, '-', ''),0,6)||' set deal_state = 0  where deal_no = :1'
        USING lv_onedayBook.deal_no;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�������ѳ�����������' || SQLERRM;
  END p_onlineconsumecancel;

  procedure p_uniondkdskqrorcancel(av_db_acc_no        varchar2, --�跽�˻�
                       av_cr_acc_no        varchar2, --�����˻�
                       av_dbcardbal        number, --�跽����ǰ������
                       av_crcardbal        number, --��������ǰ������
                       av_dbcardcounter    NUMBER, --�跽��Ƭ���׼�����
                       av_crcardcounter    NUMBER, --������Ƭ���׼�����
                       av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                       av_crbalanceencrypt IN VARCHAR2, --�����������
                       av_tramt            acc_inout_detail.db_amt%TYPE, --���׽��
                       av_credit           acc_inout_detail.db_credit_amt%TYPE, --���÷�����
                       av_accbookno        acc_inout_detail.acc_inout_no%TYPE, --������ˮ��
                       av_trcode           acc_inout_detail.deal_code%TYPE, --���״���
                       av_issueorgid       acc_inout_detail.card_org_id%TYPE, --��������
                       av_orgid            acc_inout_detail.acpt_org_id%TYPE, --�������
                       av_acpttype         acc_inout_detail.acpt_type%TYPE, --��������
                       av_acptid           acc_inout_detail.acpt_id%TYPE, --��������(�����/�̻��ŵ�)
                       av_operid           acc_inout_detail.user_id%TYPE, --������Ա/�ն˺�
                       av_trbatchno        acc_inout_detail.deal_batch_no%TYPE, --�������κ�
                       av_termtrno         acc_inout_detail.end_deal_no%TYPE, --�ն˽�����ˮ��
                       av_trdate_str       varchar2, --����ʱ��
                       av_trstate          acc_inout_detail.deal_state%TYPE, --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                       av_actionno         acc_inout_detail.deal_no%TYPE, --ҵ����ˮ��
                       av_note             acc_inout_detail.note%TYPE, --��ע
                       av_clrdate          pay_clr_para.clr_date%TYPE, --�������
                       av_otherin          VARCHAR2 DEFAULT NULL, --����������� �˻�ʱ����ԭacc_book_no
                       av_debug            IN VARCHAR2, --1����
                       av_res              OUT VARCHAR2, --������������
                       av_msg              OUT VARCHAR2 --��������������Ϣ
                       ) is
    av_db     acc_account_sub%ROWTYPE;
    av_cr     acc_account_sub%ROWTYPE;
    av_db_num number;
    av_cr_num number;
    av_trdate acc_inout_detail.deal_date%TYPE;
  begin
    av_trdate := to_date(av_trdate_str, 'yyyy-mm-dd hh24:mi:ss');

    select *
      into av_db
      from acc_account_sub
     where acc_no = av_db_acc_no
       and acc_state = '1';

    av_db_num := sql%rowcount;

    select *
      into av_cr
      from acc_account_sub
     where acc_no = av_cr_acc_no
       and acc_state = '1';

    av_cr_num := sql%rowcount;

    if av_db_num <> 1 then
      av_res := pk_public.cs_res_accnotexit;
      av_msg := '�跽�˻�������.';
      return;
    end if;

    if av_cr_num <> 1 then
      av_res := pk_public.cs_res_accnotexit;
      av_msg := '�����˻�������.';
      return;
    end if;

    pk_business.p_account(av_db,
                          av_cr,
                          av_dbcardbal,
                          av_crcardbal,
                          av_dbcardcounter,
                          av_crcardcounter,
                          av_dbbalanceencrypt,
                          av_crbalanceencrypt,
                          av_tramt,
                          av_credit,
                          av_accbookno,
                          av_trcode,
                          av_issueorgid,
                          av_orgid,
                          av_acpttype,
                          av_acptid,
                          av_operid,
                          av_trbatchno,
                          av_termtrno,
                          av_trdate,
                          av_trstate,
                          av_actionno,
                          av_note,
                          av_clrdate,
                          av_otherin,
                          av_debug,
                          av_res => av_res,
                          av_msg => av_msg);
  end p_uniondkdskqrorcancel;
END pk_consume_ghk;
/

