CREATE OR REPLACE PACKAGE BODY pk_business IS
  /*=======================================================================================*/
  --���˻�
  --av_in: 1deal_no|2deal_code|3user_id|4deal_time|
  --5obj_type     ���ͣ����˻���������һ�£�0-����1-����/�� 2-��λ 3-�̻�4-����5-����������
  --6sub_type     ������(���ô���)
  --7obj_id       �˻����������ǿ�ʱ�����뿨�ţ�(�������ʱ������֮����,�ָ� cardno1,cardno2)
  --                             ��������client_id��
  --8pwd          ����
  --9encrypt      ���˻��������(�������ʱ��֮����,�ָ� encrypt1,encrypt2)
  /*=======================================================================================*/
  PROCEDURE p_createaccount(av_in  IN VARCHAR2, --�������
                            av_res OUT VARCHAR2, --������������
                            av_msg OUT VARCHAR2 --��������������Ϣ
                            ) IS
    lv_count NUMBER;
    lv_in    pk_public.myarray; --�����������
    lv_oper  sys_USERS%ROWTYPE; --��Ա
    lv_card  card_baseinfo%ROWTYPE; --��Ƭ������Ϣ
    --lv_tablename VARCHAR2(20); --card_baseinfo�ȵı���
    lv_accname acc_account_sub.acc_name%TYPE; --�˻�����
    --lv_sql       VARCHAR2(2000);
    lv_dd     TIMESTAMP := systimestamp;
    lv_count1 NUMBER;
  BEGIN
    --ȡ���������ɲ�������
    pk_public.p_getinputpara(av_in, --�������
                             9, --�������ٸ���
                             9, --����������
                             'pk_business.p_createaccount', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
  
    if lv_in(7) is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�ͻ���Ų���Ϊ��';
      return;
    end if;
    --ȡ��Ա��Ϣ
  
    BEGIN
      SELECT * INTO lv_oper FROM sys_users WHERE user_id = lv_in(3);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := 'δ�ҵ���Ա���' || lv_in(3);
        RETURN;
    END;
  
    IF lv_in(5) = pk_public.cs_client_type_card THEN
      --����Ĳ������ֻ��˵����������ǿ�ʱ�����˻�
      DECLARE
        lv_cardnos  pk_public.myarray; --��������
        lv_encrypts pk_public.myarray; --�����������
      
      BEGIN
        lv_count  := pk_public.f_splitstr(lv_in(7), ',', lv_cardnos); --lv_in(7)�ǿ��Ŵ��ã��������ָ�
        lv_count  := pk_public.f_splitstr(lv_in(9), ',', lv_encrypts); --lv_in(9)�ǽ�����Ĵ����á������ָ�
        lv_count1 := lv_count;
      
        FOR i IN 1 .. lv_cardnos.count LOOP
          IF lv_cardnos(i) IS NOT NULL THEN
            --���ݿ���ȡ��������Ϣ
            pk_public.p_getcardbycardno(lv_cardnos(i), --����
                                        lv_card, --��Ƭ������Ϣ
                                        av_res, --������������
                                        av_msg --��������������Ϣ
                                        );
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
          
            --ȡ�˻�����
            BEGIN
              SELECT NAME
                INTO lv_accname
                FROM base_personal
               WHERE customer_id = lv_card.customer_id;
            EXCEPTION
              WHEN no_data_found THEN
                lv_accname := '���˻�';
            END;
            --�����˻��������ͺͿ�����ȡ�����˻������ñ����ݣ��Դ˽������˻�
            FOR lv_acc_open_conf IN (SELECT t1.*, t2.item_name, t2.bal_type
                                       FROM acc_open_conf t1, acc_item t2
                                      WHERE t1.item_id = t2.item_id
                                        AND main_type = lv_in(5)
                                        AND sub_type = lv_card.card_type
                                        AND conf_state =
                                            pk_public.cs_yesno_yes) LOOP
            
              select count(*)
                into lv_count
                from acc_account_sub
               where card_no = lv_cardnos(i)
                 and acc_kind = lv_acc_open_conf.acc_kind;
              IF lv_count = 0 THEN
                INSERT INTO acc_account_sub
                  (acc_no,
                   customer_id,
                   customer_type,
                   card_no,
                   acc_name,
                   bal,
                   bal_crypt,
                   credit_lmt,
                   item_id,
                   bal_type,
                   acc_kind,
                   frz_amt,
                   lss_date,
                   frz_flag,
                   frz_date,
                   last_deal_date,
                   org_id,
                   open_brch_id,
                   open_user_id,
                   open_date,
                   cls_date,
                   cls_user_id,
                   acc_state,
                   card_type,
                   wallet_no)
                VALUES
                  (seq_acc_sub_ledger.nextval, --acc_no
                   lv_card.customer_id, --customer_id
                   lv_in(5), -- customer_type
                   lv_card.card_no, --card_no
                   lv_accname, -- acc_name
                   0, --bal
                   decode(lv_acc_open_conf.acc_kind,
                          '01',
                          NULL,
                          '03',
                          null,
                          decode(lv_count1, -1, null, lv_encrypts(i))),
                   /*lv_encrypts(i)), --bal_crypt*/
                   0, --credit_lmt
                   lv_acc_open_conf.item_id, -- item_id,
                   lv_acc_open_conf.bal_type, --bal_type
                   lv_acc_open_conf.acc_kind, --acc_kind
                   0, --frz_amt
                   NULL, --lss_date
                   '0', --frz_flag
                   NULL, --frz_date
                   NULL, -- last_deal_date
                   lv_oper.org_id, -- org_id
                   lv_oper.brch_id, --open_brch_id,
                   lv_oper.user_id, -- open_user_id,
                   SYSDATE, --open_date,
                   NULL, --cls_date
                   NULL, --cls_user_id,
                   '1', -- acc_state
                   lv_card.card_type,
                   pk_public.cs_defaultwalletid);
              END IF;
            END LOOP;
          END IF;
        END LOOP;
      END;
    ELSE
      --�������˻�
      FOR lv_acc_open_conf IN (SELECT t1.*, t2.item_name, t2.bal_type
                                 FROM acc_open_conf t1, acc_item t2
                                WHERE t1.item_id = t2.item_id
                                  AND main_type = lv_in(5)
                                  AND conf_state = pk_public.cs_yesno_yes) LOOP
        SELECT COUNT(*)
          INTO lv_count
          FROM acc_account_sub
         WHERE customer_id = lv_in(7)
           AND item_id = lv_acc_open_conf.item_id;
        IF lv_count = 0 THEN
          SELECT decode(lv_in(5),
                        '0',
                        '����',
                        '2',
                        '��λ',
                        '3',
                        '�̻�',
                        '4',
                        '��Ӫ����',
                        '5',
                        '��������',
                        '') || '_' || lv_acc_open_conf.item_name
            INTO lv_accname
            FROM dual;
          INSERT INTO acc_account_sub
            (acc_no,
             customer_id,
             customer_type,
             card_no,
             acc_name,
             bal,
             bal_crypt,
             credit_lmt,
             item_id,
             bal_type,
             acc_kind,
             frz_amt,
             lss_date,
             frz_flag,
             frz_date,
             last_deal_date,
             org_id,
             open_brch_id,
             open_user_id,
             open_date,
             cls_date,
             cls_user_id,
             acc_state,
             wallet_no)
          VALUES
            (seq_acc_sub_ledger.nextval,
             lv_in(7),
             lv_in(5),
             NULL,
             lv_accname,
             0,
             NULL,
             0,
             lv_acc_open_conf.item_id,
             lv_acc_open_conf.bal_type,
             lv_acc_open_conf.acc_kind,
             0,
             NULL,
             '0',
             NULL,
             NULL,
             lv_oper.org_id,
             lv_oper.brch_id,
             lv_oper.user_id,
             SYSDATE,
             NULL,
             NULL,
             '1',
             pk_public.cs_defaultwalletid);
        END IF;
      END LOOP;
    END IF;
  
    av_res := pk_public.cs_res_ok;
    av_msg := '�˻������ɹ�';
    pk_public.p_insertrzcllog_('0',
                               'p_createaccount end:' || av_in,
                               f_timestamp_diff(systimestamp, lv_dd));
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '���˻���������' || SQLERRM;
  END p_createaccount;

  /*=======================================================================================*/
  --���˻�����
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time
  --5main_type     ���ͣ����˻���������һ�£�0-����1-����/�� 2-��λ 3-�̻�4-������
  --6sub_type     ������(���ô���)
  --7obj_id       �˻����������ǿ�ʱ�����뿨�ţ�(�������ʱ������֮����,�ָ� cardno1,cardno2)
  --                             ��������customer_id��
  /*=======================================================================================*/
  PROCEDURE p_createaccountcancel(av_in  IN VARCHAR2, --�������
                                  av_res OUT VARCHAR2, --������������
                                  av_msg OUT VARCHAR2 --��������������Ϣ
                                  ) IS
    lv_count     NUMBER;
    lv_in        pk_public.myarray; --�����������
    lv_tablename VARCHAR2(20); --cm_card�ȵı���
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             7, --�������ٸ���
                             7, --����������
                             'pk_business.p_createaccountcancel', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_in(5) = pk_public.cs_client_type_card THEN
      --�����˻�����
      DECLARE
        lv_cardnos pk_public.myarray; --��������
      BEGIN
        lv_count := pk_public.f_splitstr(lv_in(7), ',', lv_cardnos);
        FOR i IN 1 .. lv_cardnos.count LOOP
          IF lv_cardnos(i) IS NOT NULL THEN
            /* lv_tablename := pk_public.f_getsubledgertablebycard_no(lv_in(7));
            EXECUTE IMMEDIATE 'select count(*) from ' || lv_tablename ||
                              ' where card_no = :1 and bal <> 0'
              INTO lv_count
              USING lv_cardnos(i);*/
            select count(*)
              into lv_count
              from acc_account_sub
             where card_no = lv_cardnos(i)
               and bal <> 0;
            IF lv_count > 0 THEN
              av_res := '-1';
              av_msg := '�˻�������0�����ܳ���';
              RETURN;
            ELSE
              /* EXECUTE IMMEDIATE 'delete from ' || lv_tablename ||
                              ' where card_no = :1 and bal = 0'
              USING lv_cardnos(i);*/
              delete from acc_account_sub where card_no = lv_cardnos(i);
            END IF;
          END IF;
        END LOOP;
      END;
    ELSE
      --�������˻�����
      IF lv_in(7) is not null then
        SELECT COUNT(*)
          INTO lv_count
          FROM acc_account_sub
         WHERE customer_id = lv_in(7)
           AND bal <> 0;
        IF lv_count > 0 THEN
          av_res := '-1';
          av_msg := '�˻�������0�����ܳ���';
          RETURN;
        ELSE
          DELETE FROM acc_account_sub
           WHERE customer_id = lv_in(7)
             AND bal = 0;
        END IF;
      END IF;
    END IF;
  
    av_res := pk_public.cs_res_ok;
    av_msg := '�������˻��ɹ�';
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�������˻���������' || SQLERRM;
  END p_createaccountcancel;
  /*=======================================================================================*/
  --�����ֽ�β��
  /*=======================================================================================*/
  PROCEDURE p_updatecashbox(av_actionno IN NUMBER, --������ˮ��
                            av_trcode   IN VARCHAR2, --���״���
                            av_operid   IN VARCHAR2, --��Ա���
                            av_trdate   IN VARCHAR2, --����yyyy-mm-dd hh24:mi:ss
                            av_amt      IN NUMBER, --���
                            av_summary  IN VARCHAR2, --��ע
                            av_clrdate  IN VARCHAR2, --�������
                            av_res      OUT VARCHAR2, --������������
                            av_msg      OUT VARCHAR2 --��������������Ϣ
                            ) IS
  BEGIN
    p_updatecashbox(av_actionno, --������ˮ��
                    av_trcode, --���״���
                    av_operid, --��Ա���
                    av_trdate, --����yyyy-mm-dd hh24:mi:ss
                    av_amt, --���
                    av_summary, --��ע
                    av_clrdate, --�������
                    NULL, --�Է�����
                    NULL, --�Է�����
                    NULL, --�Է���Ա
                    av_res, --������������
                    av_msg --��������������Ϣ
                    );
  END p_updatecashbox;
  /*=======================================================================================*/
  --�����ֽ�β��
  /*=======================================================================================*/
  PROCEDURE p_updatecashbox(av_actionno    IN NUMBER, --������ˮ��
                            av_trcode      IN VARCHAR2, --���״���
                            av_operid      IN VARCHAR2, --��Ա���
                            av_trdate      IN VARCHAR2, --����yyyy-mm-dd hh24:mi:ss
                            av_amt         IN NUMBER, --���
                            av_summary     IN VARCHAR2, --��ע
                            av_clrdate     IN VARCHAR2, --�������
                            av_otherorgid  IN VARCHAR2, --�Է�����
                            av_otherbrchid IN VARCHAR2, --�Է�����
                            av_otheroperid IN VARCHAR2, --�Է���Ա
                            av_res         OUT VARCHAR2, --������������
                            av_msg         OUT VARCHAR2 --��������������Ϣ
                            ) IS
    lv_box      cash_box%ROWTYPE; --�ֽ�β��
    lv_operator sys_users%ROWTYPE;
    lv_dd       TIMESTAMP := systimestamp;
  BEGIN
    --�ж�
    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = av_operid;
      SELECT * INTO lv_box FROM cash_box WHERE user_id = av_operid;
    EXCEPTION
      WHEN no_data_found THEN
        av_msg := av_operid || 'û�й�Աβ�䣡';
        av_res := pk_public.cs_res_operatorerr;
        RETURN;
    END;
    IF lv_box.td_blc + av_amt - lv_box.frz_amt < 0 THEN
      av_msg := av_operid || '�Ĺ�Աβ����㣡';
      av_res := pk_public.cs_res_cashinsufbalance;
      RETURN;
    END IF;
    IF lv_operator.cash_lmt > 0 THEN
      IF lv_box.td_blc + av_amt > lv_operator.cash_lmt THEN
        av_msg := av_operid || '�Ĺ�Աβ�䳬���޶���Ƚ���������';
        av_res := pk_public.cs_res_cashinsufbalance;
        RETURN;
      END IF;
    END IF;
    --����
    UPDATE cash_box
       SET td_in_num  = td_in_num + CASE WHEN av_amt > 0 THEN 1 ELSE 0 END,
           td_in_amt  = td_in_amt + CASE WHEN av_amt > 0 THEN av_amt ELSE 0 END,
           td_out_num = td_out_num + CASE WHEN av_amt < 0 THEN 1 ELSE 0 END,
           td_out_amt = td_out_amt + CASE WHEN av_amt < 0 THEN abs(av_amt) ELSE 0 END,
           td_blc     = td_blc + av_amt
     WHERE user_id = av_operid
       AND td_blc >= -av_amt;
    IF SQL%ROWCOUNT = 0 THEN
      av_msg := av_operid || '�Ĺ�Աβ����㣡';
      av_res := pk_public.cs_res_cashinsufbalance;
      RETURN;
    END IF;
  
    INSERT INTO cash_box_rec
      (cash_ser_no, --  �ֽ���ˮ���к�
       user_id, -- ��Ա��
       brch_id, -- �����
       org_id, --����
       coin_kind, -- ����(hbzl)
       summary, -- ժҪ(zy)
       in_out_date, -- ��������
       amt, --  ������
       in_out_flag, -- �ո���־(sfbz)(1-�� ��2-��)
       cs_bal, --  �ֽ���
       deal_code, -- ���״���
       deal_no, -- ҵ����ˮ��
       clr_date, --�������
       other_org_id, --�Է�����
       other_brch_id, --�Է�����
       other_user_id --�Է���Ա
       )
    VALUES
      (seq_cash_ser_no.nextval,
       lv_box.user_id,
       lv_box.brch_id,
       lv_box.org_id,
       lv_box.coin_kind,
       av_summary,
       to_date(av_trdate, 'yyyy-mm-dd hh24:mi:ss'),
       av_amt,
       CASE WHEN av_amt > 0 THEN 1 ELSE 2 END,
       lv_box.td_blc + av_amt,
       av_trcode,
       av_actionno,
       av_clrdate,
       av_otherorgid,
       av_otherbrchid,
       av_otheroperid);
    av_res := pk_public.cs_res_ok;
  
    pk_public.p_insertrzcllog_('9',
                               'updatecashbox:' || av_operid || ',' ||
                               f_timestamp_diff(systimestamp, lv_dd),
                               av_actionno);
  EXCEPTION
    WHEN OTHERS THEN
      av_msg := nvl(av_msg, '�����ֽ�β�䷢������') || SQLERRM;
      av_res := pk_public.cs_res_unknownerr;
      RETURN;
  END p_updatecashbox;
  /*=======================================================================================*/
  --���·ֻ���
  /*=======================================================================================*/
  PROCEDURE p_updatesubledger(av_accno          IN NUMBER, --�˺�
                              av_amt            IN NUMBER, --���
                              av_credit         IN NUMBER, --����
                              av_balance_old    in varchar2, --ԭ���
                              av_balanceencrypt IN VARCHAR2, --�������
                              av_cardno         IN VARCHAR2, --����
                              av_res            OUT VARCHAR2, --������������
                              av_msg            OUT VARCHAR2 --��������������Ϣ
                              ) IS
    lv_tablename VARCHAR2(50);
    lv_balance   acc_account_sub.bal%TYPE;
    lv_balattr   acc_account_sub.bal_type%TYPE;
    -- lv_points    acc_sub_ledger.points%TYPE;
    lv_acckind  acc_account_sub.acc_kind%TYPE;
    lv_itemno   acc_account_sub.item_id%TYPE;
    lv_clientid acc_account_sub.customer_id%TYPE;
    lv_dd       TIMESTAMP := systimestamp;
  BEGIN
    IF av_cardno IS NULL THEN
      UPDATE acc_account_sub
         SET bal        = bal + av_amt,
             credit_lmt = credit_lmt + av_credit,
             --  bal_crypt = av_balanceencrypt,
             last_deal_date = to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss')
       WHERE acc_no = av_accno
      RETURNING bal, item_id, customer_id INTO lv_balance, lv_itemno, lv_clientid;
    
      IF lv_itemno = pk_public.cs_accitem_brch_prestore AND av_amt < 0 THEN
        --Ԥ����˻����ж��޶�
        pk_public.p_judgebranchagentlimit(lv_clientid, --������
                                          lv_balance, --�۳������Ԥ������
                                          av_res, --������������
                                          av_msg --��������������Ϣ
                                          );
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
      END IF;
    ELSE
      /* lv_tablename := pk_public.f_getsubledgertablebycard_no(av_cardno);
      EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                        ' set balance = balance + :1,credit = credit + :2,balance_encrypt=:3,' ||
                        ' prv_tr_date = to_char(sysdate,''yyyy-mm-dd hh24:mi:ss'') ' ||
                        ' where acc_no = :4 returning balance,bal_attr,acc_kind,points into :5,:6,:7,:8'
        USING av_amt, av_credit, av_balanceencrypt, av_accno
        RETURNING INTO lv_balance, lv_balattr, lv_acckind, lv_points;*/
      /*IF av_balance_old IS NULL THEN
        av_res := pk_public.cs_res_dberr;
        av_msg := '�����ԭ����Ϊ��';
        RETURN;
      END IF;*/
    
      IF lv_acckind IN ('02') AND av_balanceencrypt IS NULL THEN
        av_res := pk_public.cs_res_dberr;
        av_msg := '�����˻�����Ľ�����Ĳ���Ϊ��';
        RETURN;
      END IF;
    
      UPDATE acc_account_sub
         SET bal            = bal + av_amt,
             credit_lmt     = credit_lmt + av_credit,
             bal_crypt      = av_balanceencrypt,
             last_deal_date = to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss')
       WHERE acc_no = av_accno
      -- and bal_crypt <> av_balance_oldcrypt  --���Ĳ���ͬʱ����
      RETURNING bal, bal_type, acc_kind INTO lv_balance, lv_balattr, lv_acckind;
    
      /* if sql%rowcount = 0 then
          av_res := pk_public.cs_res_dberr;
          av_msg := '�����˻�����ʱ��������Ҳ����˿�'|| av_cardno||'�˻�';
        RETURN;
      END IF;*/
    
      IF lv_acckind in ('02') and
         lv_balance <> nvl(av_balance_old, 0) + av_amt THEN
        --�����˻���Ҫ�ж��ǲ���ͬʱ�����˻�,
        av_res := pk_public.cs_res_dberr;
        av_msg := '�˻�����ǰ����ȷ';
        RETURN;
      END IF;
    
      IF lv_balattr = '2' AND lv_balance < 0 THEN
        --����С��0
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '����';
        RETURN;
      END IF;
      /*  IF lv_acckind IN ('02') AND av_balanceencrypt IS NULL THEN
        --�����˻� ���ҽ�����Ĵ����
        NULL; ------------------��ʱȡ�������
        /*EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                          ' set balance_encrypt=:1 where acc_no = :2'
          USING av_balanceencrypt, av_accno;
      END IF;*/
    END IF;
    av_res := pk_public.cs_res_ok;
    pk_public.p_insertrzcllog_('9',
                               'updatesubledger:' || av_accno || ',' ||
                               f_timestamp_diff(systimestamp, lv_dd),
                               0);
  EXCEPTION
    WHEN OTHERS THEN
      av_msg := nvl(av_msg, '���·ֻ��˷�������') || SQLERRM;
      av_res := pk_public.cs_res_unknownerr;
      RETURN;
  END p_updatesubledger;

  /*=======================================================================================*/
  --���ݽ�����·ֻ��˺��ֽ�β��
  /*=======================================================================================*/
  PROCEDURE p_updatesubledgerandcashbox(av_db_accno           acc_inout_detail.db_acc_no%TYPE, --�跽�˺�
                                        av_db_cardno          acc_inout_detail.db_card_no%TYPE, --�跽����
                                        av_db_itemno          VARCHAR2, --�跽��Ŀ��
                                        av_db_balance_old     varchar2, --�跽�˻�����ǰ���
                                        av_db_balance_encrypt VARCHAR2, --�跽�˻����׺�������
                                        av_cr_accno           acc_inout_detail.cr_acc_no%TYPE, --�����˺�
                                        av_cr_cardno          acc_inout_detail.cr_card_no%TYPE, --��������
                                        av_cr_itemno          VARCHAR2, --������Ŀ��
                                        av_cr_balance_old     varchar2, --�����˻�����ǰ���
                                        av_cr_balance_encrypt VARCHAR2, --�����˻����׺�������
                                        av_actionno           NUMBER, --������ˮ��
                                        av_trcode             VARCHAR2, --���״���
                                        av_operid             VARCHAR2, --��Ա���
                                        av_trdate             DATE, --��������
                                        av_tramt              NUMBER, --���׽��
                                        av_credit             NUMBER, --���÷�����
                                        av_note               VARCHAR2, --��ע
                                        av_clrdate            VARCHAR2, --�������
                                        av_res                OUT VARCHAR2, --������������
                                        av_msg                OUT VARCHAR2 --��������������Ϣ
                                        ) IS
    lv_cardno varchar2(20) := ''; ---���׿���
  BEGIN
    /*IF av_trcode NOT LIKE '9090%' AND  av_trcode <> '20601050' AND av_trcode <> '20601060' AND
        (av_trcode <=30101021 OR  av_trcode >= 40000001) THEN
      IF av_db_itemno <> pk_public.cs_accitem_co_org_rechage_in THEN
        --д�ֽ�β��
        IF av_db_itemno = pk_public.cs_accitem_cash AND av_cr_itemno = pk_public.cs_accitem_cash AND av_trcode <> '50801010'  THEN
            --�ֽ𽻽ӵ��ֽ�β�䵥������
            \*NULL;*\
             pk_business.p_updatecashbox(av_actionno, --������ˮ��
                                        av_trcode, --���״���
                                        av_operid, --��Ա���
                                        to_char(av_trdate,
                                                'yyyy-mm-dd hh24:mi:ss'), --����yyyy-mm-dd hh24:mi:ss
                                        av_tramt, --���
                                        av_note, --��ע
                                        av_clrdate, --�������
                                        av_res, --������������
                                        av_msg --��������������Ϣ
                                        );
             IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
        ELSIF av_db_itemno = pk_public.cs_accitem_cash OR av_db_itemno = pk_public.cs_accitem_brch_prestore  THEN
          --���ֽ�--����������Ǯ��ҵ��Ҳ���ֽ���ˮ
          IF av_cr_itemno <> pk_public.cs_accitem_biz_clr THEN
            pk_business.p_updatecashbox(av_actionno, --������ˮ��
                                        av_trcode, --���״���
                                        av_operid, --��Ա���
                                        to_char(av_trdate,
                                                'yyyy-mm-dd hh24:mi:ss'), --����yyyy-mm-dd hh24:mi:ss
                                        av_tramt, --���
                                        av_note, --��ע
                                        av_clrdate, --�������
                                        av_res, --������������
                                        av_msg --��������������Ϣ
                                        );
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
          END IF;
        ELSIF av_cr_itemno = pk_public.cs_accitem_cash OR
              av_db_itemno NOT IN
              (pk_public.cs_accitem_cash, pk_public.cs_accitem_org_bank,
               pk_public.cs_accitem_co_org_rechage_in) AND
              av_cr_itemno = pk_public.cs_accitem_brch_prestore THEN
          --���ֽ�--����������ǮʱҲ���ֽ���ˮ�������������ֵʱ���ǣ�
          pk_business.p_updatecashbox(av_actionno, --������ˮ��
                                      av_trcode, --���״���
                                      av_operid, --��Ա���
                                      to_char(av_trdate,
                                              'yyyy-mm-dd hh24:mi:ss'), --����yyyy-mm-dd hh24:mi:ss
                                      -av_tramt, --���
                                      av_note, --��ע
                                      av_clrdate, --�������
                                      av_res, --������������
                                      av_msg --��������������Ϣ
                                      );
               IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
          elsif av_cr_itemno = pk_public.cs_accitem_cash  and av_trcode='50801030' then
               pk_business.p_updatecashbox(av_actionno, --������ˮ��
                                      av_trcode, --���״���
                                      av_operid, --��Ա���
                                      to_char(av_trdate,
                                              'yyyy-mm-dd hh24:mi:ss'), --����yyyy-mm-dd hh24:mi:ss
                                      -abs(av_tramt), --���
                                      av_note, --��ע
                                      av_clrdate, --�������
                                      av_res, --������������
                                      av_msg --��������������Ϣ
                                      );
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
        END IF;
      END IF;
    END IF;*/
  
    IF av_cr_itemno = av_db_itemno THEN
      IF av_cr_itemno = pk_public.cs_accitem_org_bank OR
         av_db_itemno = pk_public.cs_accitem_org_bank THEN
        IF av_cr_itemno IN ('702101', '703101', '709999') OR
           av_db_itemno IN ('702101', '703101', '709999') THEN
          pk_business.p_updatecashbox(av_actionno, --������ˮ��
                                      av_trcode, --���״���
                                      av_operid, --��Ա���
                                      to_char(av_trdate,
                                              'yyyy-mm-dd hh24:mi:ss'), --����yyyy-mm-dd hh24:mi:ss
                                      av_tramt, --���
                                      av_note, --��ע
                                      av_clrdate, --�������
                                      av_res, --������������
                                      av_msg --��������������Ϣ
                                      );
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
        END IF;
      END IF;
    ELSE
      IF av_cr_itemno = pk_public.cs_accitem_cash OR
         av_db_itemno = pk_public.cs_accitem_cash THEN
        IF av_trcode NOT LIKE '9090%' THEN
          IF av_trcode = '50801030' THEN
            pk_business.p_updatecashbox(av_actionno, --������ˮ��
                                        av_trcode, --���״���
                                        av_operid, --��Ա���
                                        to_char(av_trdate,
                                                'yyyy-mm-dd hh24:mi:ss'), --����yyyy-mm-dd hh24:mi:ss
                                        av_tramt, --���
                                        av_note, --��ע
                                        av_clrdate, --�������
                                        av_res, --������������
                                        av_msg --��������������Ϣ
                                        );
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
          ELSE
            IF av_trcode <> '50801010' AND av_trcode <> '30601020' and
               av_trcode <> '20501190' and av_trcode <> '30601021' THEN
              pk_business.p_updatecashbox(av_actionno, --������ˮ��
                                          av_trcode, --���״���
                                          av_operid, --��Ա���
                                          to_char(av_trdate,
                                                  'yyyy-mm-dd hh24:mi:ss'), --����yyyy-mm-dd hh24:mi:ss
                                          av_tramt, --���
                                          av_note, --��ע
                                          av_clrdate, --�������
                                          av_res, --������������
                                          av_msg --��������������Ϣ
                                          );
              IF av_res <> pk_public.cs_res_ok THEN
                RETURN;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  
    --����acc_sub_ledger
    p_updatesubledger(av_db_accno, --�˺�
                      -av_tramt, --���
                      -av_credit, --����
                      av_db_balance_old, --����ǰ���
                      av_db_balance_encrypt, --�������
                      av_db_cardno, --����
                      av_res, --������������
                      av_msg --��������������Ϣ
                      );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    p_updatesubledger(av_cr_accno, --�˺�
                      av_tramt, --���
                      av_credit, --����
                      av_cr_balance_old, --����ǰ���
                      av_cr_balance_encrypt, --�������
                      av_cr_cardno, --����
                      av_res, --������������
                      av_msg --��������������Ϣ
                      );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    -----���Ͷ���------------
    if av_trcode in
       ('30101020', '30101010', '30105020', '30105010', '30101040',
        '30302010', '30601030', '30601020', '30101021', '30101011',
        '40201010', '40202010', '40202031', '40201031', '40202022',
        '40102022', '40202051', '40102051') then
      select card_no
        into lv_cardno
        from acc_account_sub b
       where b.acc_no = av_db_accno;
      if lv_cardno is null then
        select card_no
          into lv_cardno
          from acc_account_sub b
         where b.acc_no = av_cr_accno;
      end if;
      pk_interface_service.p_save_sms_message(av_trcode,
                                              av_actionno,
                                              lv_cardno,
                                              av_tramt,
                                              av_db_balance_old,
                                              av_res,
                                              av_msg);
    end if;
  
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '���·ֻ��˺��ֽ�β�䷢������' || SQLERRM;
  END p_updatesubledgerandcashbox;
  /*=======================================================================================*/
  --���ݽ���˻��������˷���
  /*=======================================================================================*/
  PROCEDURE p_account(av_db               acc_account_sub%ROWTYPE, --�跽�˻�
                      av_cr               acc_account_sub%ROWTYPE, --�����˻�
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
                      av_trdate           acc_inout_detail.deal_date%TYPE, --����ʱ��
                      av_trstate          acc_inout_detail.deal_state%TYPE, --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                      av_actionno         acc_inout_detail.deal_no%TYPE, --ҵ����ˮ��
                      av_note             acc_inout_detail.note%TYPE, --��ע
                      av_clrdate          pay_clr_para.clr_date%TYPE, --�������
                      av_otherin          VARCHAR2 DEFAULT NULL, --����������� �˻�ʱ����ԭacc_book_no
                      av_debug            IN VARCHAR2, --1����
                      av_res              OUT VARCHAR2, --������������
                      av_msg              OUT VARCHAR2 --��������������Ϣ
                      ) IS
    lv_tablename VARCHAR2(50);
    lv_sql       VARCHAR2(2000);
    lv_dd        TIMESTAMP := systimestamp;
  BEGIN
    IF av_debug = '9' THEN
      pk_public.p_insertrzcllog('����', av_actionno);
    END IF;
    --111111111111111111111111дacc_daybook
    IF av_trstate = '9' THEN
      lv_tablename := 'acc_inout_detail';
    ELSE
      lv_tablename := 'acc_inout_detail_' ||
                      to_char(to_date(av_clrdate, 'yyyy-mm-dd'), 'yyyymm'); ---ÿ��һ�ű�
    END IF;
    lv_sql := 'insert into ' || lv_tablename ||
              ' (acc_inout_no,deal_code,card_org_id,' ||
              'acpt_org_id,acpt_type,acpt_id,user_id,deal_batch_no,end_deal_no,deal_date,rev_time,old_acc_inout_no,' ||
              'db_acc_name,db_item_id,db_acc_no,db_card_no,db_customer_id,db_card_type,db_acc_kind,db_acc_bal,db_amt,db_credit_amt,db_card_bal,db_card_counter,' ||
              'cr_acc_name,cr_item_id,cr_acc_no,cr_card_no,cr_customer_id,cr_card_type,cr_acc_kind,cr_acc_bal,cr_amt,cr_credit_amt,cr_card_bal,cr_card_counter,' ||
              'deal_state,deal_no,insert_time,note,clr_date)' || --
              'values(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18,:19,' ||
              ':20,:21,:22,:23,:24,:25,:26,:27,:28,:29,:30,:31,:32,:33,:34,:35,:36,:37,:38,sysdate,:39,:40)';
    EXECUTE IMMEDIATE lv_sql
      USING av_accbookno, av_trcode, av_issueorgid, --
    av_orgid, av_acpttype, av_acptid, av_operid, av_trbatchno, av_termtrno, av_trdate, '', nvl(av_otherin, ''), --
    substrb(av_db.acc_name, 1, 20), av_db.item_id, av_db.acc_no, av_db.card_no, av_db.customer_id, av_db.card_type, av_db.acc_kind, av_db.bal, av_tramt, av_credit, av_dbcardbal, av_dbcardcounter, --
    substrb(av_cr.acc_name, 1, 20), av_cr.item_id, av_cr.acc_no, av_cr.card_no, av_cr.customer_id, av_cr.card_type, av_cr.acc_kind, av_cr.bal, av_tramt, av_credit, av_crcardbal, av_crcardcounter, --
    av_trstate, av_actionno, av_note, av_clrdate;
    --22222222222222222222222дtr_card
    IF av_db.card_no IS NOT NULL THEN
      IF av_trstate = '9' THEN
        lv_tablename := 'pay_card_deal_rec';
      ELSE
        -- lv_tablename := pk_public.f_gettrcardtable(av_db.card_no, av_trdate);
        lv_tablename := 'pay_card_deal_rec_' ||
                        to_char(av_trdate, 'yyyymm'); ----��Ҫ���Ǵ���Ľ���ʱ���Ҳ�������������������
      END IF;
      --tr_card��amt������ʾ��Ǯ��Ǯ
      lv_sql := 'insert into ' || lv_tablename ||
                '(id, acc_inout_no, deal_code, org_id,co_org_id,' ||
                ' acpt_type,acpt_id, user_id, deal_batch_no, end_deal_no, deal_date, rev_time, old_acc_inout_no,' ||
                ' customer_id,acc_name, acc_no, card_no, card_type,acc_kind,acc_bal, amt, credit,card_bal, card_counter, deal_state,' ||
                ' deal_no, insert_time,clr_date, note)' || --
                'select seq_tr_card_id.nextval,:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,' ||
                ':18,:19,:20,:21,:22,:23,:24,:25,sysdate,:26,:27 from dual';
      EXECUTE IMMEDIATE lv_sql
        USING av_accbookno, av_trcode, av_issueorgid, av_orgid, av_acpttype, av_acptid, av_operid, av_trbatchno, av_termtrno, av_trdate, '', av_otherin, --
      av_db.customer_id, substrb(av_db.acc_name, 1, 20), av_db.acc_no, av_db.card_no, av_db.card_type, av_db.acc_kind, av_db.bal, -av_tramt, -av_credit, av_dbcardbal, av_dbcardcounter, av_trstate, --
      av_actionno, av_clrdate, av_note;
    END IF;
    IF av_cr.card_no IS NOT NULL THEN
      IF av_trstate = '9' THEN
        lv_tablename := 'pay_card_deal_rec';
      ELSE
        -- lv_tablename := pk_public.f_gettrcardtable(av_cr.card_no, av_trdate);
        lv_tablename := 'pay_card_deal_rec_' ||
                        to_char(av_trdate, 'yyyymm'); ----��Ҫ���Ǵ���Ľ���ʱ���Ҳ�������������������
      END IF;
      lv_sql := 'insert into ' || lv_tablename ||
                '(id, acc_inout_no, deal_code,org_id,co_org_id,' ||
                ' acpt_type,acpt_id, user_id, deal_batch_no, end_deal_no, deal_date, rev_time, old_acc_inout_no,' ||
                ' customer_id,acc_name, acc_no, card_no, card_type,acc_kind,acc_bal, amt, credit,card_bal, card_counter, deal_state,' ||
                ' deal_no, insert_time,clr_date, note)' || --
                'select seq_tr_card_id.nextval,:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,' ||
                ':18,:19,:20,:21,:22,:23,:24,:25,sysdate,:26,:27 from dual';
      EXECUTE IMMEDIATE lv_sql
        USING av_accbookno, av_trcode, av_issueorgid, av_orgid, --
      av_acpttype, av_acptid, av_operid, av_trbatchno, av_termtrno, av_trdate, '', av_otherin, --
      av_cr.customer_id, substrb(av_cr.acc_name, 1, 20), av_cr.acc_no, av_cr.card_no, av_cr.card_type, av_cr.acc_kind, av_cr.bal, av_tramt, av_credit, av_crcardbal, av_crcardcounter, av_trstate, --
      av_actionno, av_clrdate, av_note;
    END IF;
    --3333333333333333333333���·ֻ��ˣ������ֽ�β��
    IF av_trstate <> '9' THEN
      p_updatesubledgerandcashbox(av_db.acc_no, --�跽�˺�
                                  av_db.card_no, --�跽����
                                  av_db.item_id, --�跽��Ŀ��
                                  av_db.bal, --�跽�˻�����ǰ�������
                                  av_dbbalanceencrypt, --�跽�˻����׺�������
                                  av_cr.acc_no, --�����˺�
                                  av_cr.card_no, --��������
                                  av_cr.item_id, --������Ŀ��
                                  av_cr.bal, --�����˻�����ǰ���
                                  av_crbalanceencrypt, --�����˻����׺�������
                                  av_actionno, --������ˮ��
                                  av_trcode, --���״���
                                  av_operid, --��Ա���
                                  av_trdate, --��������
                                  av_tramt, --���׽��
                                  av_credit, --���÷�����
                                  av_note, --��ע
                                  av_clrdate, --�������
                                  av_res, --������������
                                  av_msg --��������������Ϣ
                                  );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
    av_res := pk_public.cs_res_ok;
    pk_public.p_insertrzcllog_('9',
                               'p_account end:' || av_actionno,
                               f_timestamp_diff(systimestamp, lv_dd));
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '���˷�������' || SQLERRM;
  END p_account;
  /*=======================================================================================*/
  --�Ҽ�¼ȷ��  ���һ���˻���ˮ��¼��ȷ��
  /*=======================================================================================*/
  PROCEDURE p_ashconfirm_onerow(av_clrdate          IN pay_clr_para.clr_date%TYPE, --�������
                                av_daybook          IN acc_inout_detail%ROWTYPE, --Ҫȷ�ϵ�daybook
                                av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                                av_crbalanceencrypt IN VARCHAR2, --�����������
                                av_dbaccbal         IN varchar2, --�跽����ǰ���
                                av_craccbal         IN varchar2, --��������ǰ���
                                av_debug            IN VARCHAR2, --1д������־
                                av_res              OUT VARCHAR2, --��������
                                av_msg              OUT VARCHAR2 --����������Ϣ
                                ) IS
    lv_tablename VARCHAR2(50);
    lv_clrdate   pay_clr_para.clr_date%TYPE; --�������
    lv_trdate    DATE;
  BEGIN
    IF av_debug = '1' THEN
      pk_public.p_insertrzcllog('�Ҽ�¼ȷ��', av_daybook.deal_no);
    END IF;
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    av_res := pk_public.cs_res_ok;
    UPDATE acc_inout_detail
       SET deal_state = '0',
           clr_date   = lv_clrdate,
           db_acc_bal = nvl(av_dbaccbal, db_acc_bal),
           cr_acc_bal = nvl(av_craccbal, cr_acc_bal)
     WHERE acc_inout_no = av_daybook.acc_inout_no
       AND deal_state = '9'
    RETURNING deal_date INTO lv_trdate;
    if av_daybook.acpt_type = '2' then
      --��������POS��ֵ
      update tr_serv_rec r
         set r.deal_state = '0', r.clr_date = av_clrdate
       where r.deal_state = '9'
         and r.deal_no = av_daybook.deal_no;
    end if;
    IF SQL%ROWCOUNT = 0 THEN
      av_res := '99';
      av_msg := '������Ҫȷ�ϵĻҼ�¼';
      RETURN;
    END IF;
    --�ƶ�acc_daybook
    EXECUTE IMMEDIATE 'insert into acc_inout_detail_' ||
                      to_char(to_date(lv_clrdate, 'yyyy-mm-dd'), 'yyyymm') ||
                      ' select * from acc_inout_detail' ||
                      ' where acc_inout_no = :1'
      USING av_daybook.acc_inout_no;
    DELETE FROM acc_inout_detail
     WHERE acc_inout_no = av_daybook.acc_inout_no;
  
    --�ƶ��跽���ŵĽ��׻Ҽ�¼
    IF av_daybook.db_card_no IS NOT NULL THEN
      UPDATE pay_card_deal_rec
         SET deal_state = '0',
             clr_date   = lv_clrdate,
             acc_bal    = nvl(av_dbaccbal, acc_bal)
       WHERE acc_inout_no = av_daybook.acc_inout_no
         AND card_no = av_daybook.db_card_no
         AND deal_state = '9';
      -- lv_tablename := pk_public.f_gettrcardtable(av_daybook.db_card_no,lv_trdate);
      lv_tablename := 'pay_card_deal_rec_' || to_char(lv_trdate, 'yyyymm'); ----��Ҫ���Ǵ���Ľ���ʱ���Ҳ�������������������
    
      --�ж��Ƿ��ҵõ��ñ�����Ҳ����ñ��������ԭ��¼����
    
      EXECUTE IMMEDIATE 'insert into ' || lv_tablename ||
                        ' select * from pay_card_deal_rec where acc_inout_no = :1 and card_no = :2'
        USING av_daybook.acc_inout_no, av_daybook.db_card_no;
      DELETE FROM pay_card_deal_rec
       WHERE acc_inout_no = av_daybook.acc_inout_no
         AND card_no = av_daybook.db_card_no;
    END IF;
    --�ƶ��������ŵĽ��׻Ҽ�¼
    IF av_daybook.cr_card_no IS NOT NULL THEN
      UPDATE pay_card_deal_rec
         SET deal_state = '0',
             clr_date   = lv_clrdate,
             acc_bal    = nvl(av_craccbal, acc_bal)
       WHERE acc_inout_no = av_daybook.acc_inout_no
         AND card_no = av_daybook.cr_card_no
         AND deal_state = '9';
    
      --  lv_tablename := pk_public.f_gettrcardtable(av_daybook.cr_card_no,lv_trdate);
    
      lv_tablename := 'pay_card_deal_rec_' || to_char(lv_trdate, 'yyyymm'); ----��Ҫ���Ǵ���Ľ���ʱ���Ҳ�������������������
      EXECUTE IMMEDIATE 'insert into ' || lv_tablename ||
                        ' select * from pay_card_deal_rec where acc_inout_no = :1 and card_no = :2'
        USING av_daybook.acc_inout_no, av_daybook.cr_card_no;
      DELETE FROM pay_card_deal_rec
       WHERE acc_inout_no = av_daybook.acc_inout_no
         AND card_no = av_daybook.cr_card_no;
    END IF;
  
    --���·ֻ��˺� �����ֽ�β��
    p_updatesubledgerandcashbox(av_daybook.db_acc_no, --�跽�˺�
                                av_daybook.db_card_no, --�跽����
                                av_daybook.db_item_id, --�跽��Ŀ��
                                av_dbaccbal, --�跽�˻�����ǰ���
                                av_dbbalanceencrypt, --�跽�˻����׺�������
                                av_daybook.cr_acc_no, --�����˺�
                                av_daybook.cr_card_no, --��������
                                av_daybook.cr_item_id, --������Ŀ��
                                av_craccbal, --�����˻�����ǰ���
                                av_crbalanceencrypt, --�����˻����׺�������
                                av_daybook.deal_no, --������ˮ��
                                av_daybook.deal_code, --���״���
                                av_daybook.user_id, --��Ա���
                                av_daybook.deal_date, --��������
                                av_daybook.db_amt, --���׽��
                                av_daybook.db_credit_amt, --���÷�����
                                av_daybook.note, --��ע
                                lv_clrdate, --�������
                                av_res, --������������
                                av_msg --��������������Ϣ
                                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
  
    av_res := pk_public.cs_res_ok;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�Ҽ�¼ȷ�Ϸ�������' || SQLERRM;
  END p_ashconfirm_onerow;
  /*=======================================================================================*/
  --�Ҽ�¼ȷ��  ���ݴ����acc_book_no��ȷ��
  /*=======================================================================================*/
  PROCEDURE p_ashconfirmbyaccbookno(av_clrdate          IN pay_clr_para.clr_date%TYPE, --�������
                                    av_accbookno        IN VARCHAR2, --Ҫȷ�ϵ�acc_book_no
                                    av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                                    av_crbalanceencrypt IN VARCHAR2, --�����������
                                    av_dbaccbal         IN varchar2, --�跽����ǰ���
                                    av_craccbal         IN varchar2, --��������ǰ���
                                    av_debug            IN VARCHAR2, --1д������־
                                    av_res              OUT VARCHAR2, --��������
                                    av_msg              OUT VARCHAR2 --����������Ϣ
                                    ) IS
    lv_daybook acc_inout_detail%ROWTYPE;
  BEGIN
    SELECT *
      INTO lv_daybook
      FROM acc_inout_detail
     WHERE acc_inout_no = av_accbookno
       AND deal_state = '9';
    p_ashconfirm_onerow(av_clrdate, --�������
                        lv_daybook, --Ҫȷ�ϵ�daybook
                        av_dbbalanceencrypt, --�跽�������
                        av_crbalanceencrypt, --�����������
                        av_dbaccbal, --�跽����ǰ���
                        av_craccbal, --��������ǰ���
                        av_debug, --1д������־
                        av_res, --��������
                        av_msg --����������Ϣ
                        );
  EXCEPTION
    WHEN no_data_found THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := '�˺���ˮ��Ϊ' || av_accbookno || '�ĻҼ�¼������';
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�Ҽ�¼ȷ�Ϸ�������' || SQLERRM;
  END p_ashconfirmbyaccbookno;
  /*=======================================================================================*/
  --�Ҽ�¼ȷ��
  /*=======================================================================================*/
  PROCEDURE p_ashconfirm(av_clrdate          IN pay_clr_para.clr_date%TYPE, --�������
                         av_actionno         IN NUMBER, --ҵ����ˮ��
                         av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                         av_crbalanceencrypt IN VARCHAR2, --�����������
                         av_debug            IN VARCHAR2, --1д������־
                         av_res              OUT VARCHAR2, --��������
                         av_msg              OUT VARCHAR2 --����������Ϣ
                         ) IS
    lv_clrdate pay_clr_para.clr_date%TYPE; --�������
    lv_dbbal   acc_account_sub.bal%type;
    lv_crbal   acc_account_sub.bal%type;
    lv_rows    NUMBER := 0;
  BEGIN
    IF av_debug = '1' THEN
      pk_public.p_insertrzcllog('�Ҽ�¼ȷ��', av_actionno);
    END IF;
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    av_res := pk_public.cs_res_ok;
    FOR lv_daybook IN (SELECT *
                         FROM acc_inout_detail
                        WHERE deal_no = av_actionno
                          AND deal_state = '9') LOOP
      lv_rows := lv_rows + 1;
      select nvl(t.bal, 0)
        into lv_dbbal
        from acc_account_sub t
       where t.acc_no = lv_daybook.db_acc_no; --ȡ�跽�˻�ԭ��������
    
      select nvl(t.bal, 0)
        into lv_crbal
        from acc_account_sub t
       where t.acc_no = lv_daybook.cr_acc_no; --ȡ�����˻�ԭ��������
    
      p_ashconfirm_onerow(av_clrdate, --�������
                          lv_daybook, --Ҫȷ�ϵ�daybook
                          av_dbbalanceencrypt, --�跽�������
                          av_crbalanceencrypt, --�����������
                          lv_dbbal, --�跽����ǰ���
                          lv_crbal, --��������ǰ���
                          av_debug, --1д������־
                          av_res, --��������
                          av_msg --����������Ϣ
                          );
    END LOOP;
    IF lv_rows = 0 THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := '������Ҫȷ�ϵĻҼ�¼';
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�Ҽ�¼ȷ�Ϸ�������' || SQLERRM;
  END p_ashconfirm;
  /*=======================================================================================*/
  --�Ҽ�¼����
  /*=======================================================================================*/
  PROCEDURE p_ashcancel(av_clrdate  IN pay_clr_para.clr_date%TYPE, --�������
                        av_actionno IN NUMBER, --ҵ����ˮ��
                        av_debug    IN VARCHAR2, --1д������־
                        av_res      OUT VARCHAR2, --��������
                        av_msg      OUT VARCHAR2 --����������Ϣ
                        ) IS
    lv_clrdate      pay_clr_para.clr_date%TYPE; --�������
    lv_cardno       pay_card_deal_rec.card_no%TYPE; --����
    lv_oldaccbookno acc_inout_detail.old_acc_inout_no%TYPE; --�������ļ�����ˮ��
    lv_oldaccbook   acc_inout_detail%ROWTYPE; --�������ļ���
    --���ݳ����ļ�����ˮ�źͿ���ȡ�������
    FUNCTION f_getoldclrdate(av_accbookno pay_card_deal_rec.acc_inout_no%TYPE,
                             av_cardno    pay_card_deal_rec.card_no%TYPE)
      RETURN VARCHAR2 IS
      lv_month     VARCHAR2(10);
      lv_tablename VARCHAR2(50);
      lv_count     NUMBER;
    BEGIN
      lv_month := substrb(lv_clrdate, 1, 8) || '01';
      WHILE lv_month > '2015-05-01' LOOP
        --�����������ں��������֮��Ѱ��ԭ��¼�Ĵ�����������
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
    IF av_debug = '1' THEN
      pk_public.p_insertrzcllog('�Ҽ�¼ȡ��', av_actionno);
    END IF;
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    -------------------����ǳ�ֵ����ֵ����Ҫ��ԭ��ֵ����״̬
    --����acc_daybook
    UPDATE acc_inout_detail
       SET deal_state = '2'
     WHERE deal_no = av_actionno
       AND deal_state = '9';
    IF SQL%ROWCOUNT = 0 THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := '������Ҫȡ���ĻҼ�¼';
      RETURN;
    END IF;
    --����tr_card
    UPDATE pay_card_deal_rec
       SET deal_state = '2', clr_date = lv_clrdate
     WHERE deal_no = av_actionno
       AND deal_state = '9'
    RETURNING MAX(old_acc_inout_no), MAX(card_no) INTO lv_oldaccbookno, lv_cardno;
    select *
      into lv_oldaccbook
      from acc_inout_detail de
     where de.deal_no = av_actionno;
    if lv_oldaccbook.acpt_type = '2' then
      --��������POS��ֵ
      update tr_serv_rec r
         set r.deal_state = '2', clr_date = lv_clrdate
       where r.deal_state = '9'
         and r.deal_no = av_actionno;
    end if;
    -------------------����ǳ�����¼�ĻҼ�¼ȡ������Ҫ����ԭ��¼��״̬�ͳ���ʱ��
    IF SQL%ROWCOUNT > 0 THEN
      IF lv_oldaccbookno IS NOT NULL THEN
        --����ԭ��¼��״̬�ͳ���ʱ��
        DECLARE
          lv_oldclrdate VARCHAR2(10);
          lv_oldtrdate  DATE;
        BEGIN
          lv_oldclrdate := f_getoldclrdate(lv_oldaccbookno, lv_cardno);
          IF lv_oldclrdate IS NOT NULL THEN
            EXECUTE IMMEDIATE 'update acc_inout_detail_' ||
                              to_char(to_date(lv_oldclrdate, 'yyyy-mm-dd'),
                                      'yyyymm') ||
                              ' set deal_state = 0,rev_time = null,note = note || ''_ȡ������'' where acc_inout_no = ' ||
                              lv_oldaccbookno ||
                              ' returning deal_date into :1'
              RETURNING INTO lv_oldtrdate;
            --FOR i IN 0 .. pk_public.cs_cm_card_nums - 1 LOOP
            EXECUTE IMMEDIATE 'update pay_card_deal_rec_' ||
                              to_char(lv_oldtrdate, 'yyyymm') ||
                              ' set deal_state = 0,rev_time = null,note = note || ''_ȡ������'' where acc_inout_no = ' ||
                              lv_oldaccbookno;
            -- END LOOP;
          END IF;
        END;
      END IF;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�Ҽ�¼ȡ����������' || SQLERRM;
  END p_ashcancel;
  /*=======================================================================================*/
  --���˳��� ���һ��acc_daybook��¼������ daybook����˻�����,���д��
  /*=======================================================================================*/
  PROCEDURE p_daybookcancel_onerow(av_daybook          IN acc_inout_detail%ROWTYPE, --Ҫ����daybook
                                   av_operator         IN sys_users%ROWTYPE, --��ǰ��Ա
                                   av_actionno2        IN NUMBER, --��ҵ����ˮ��
                                   av_clrdate1         IN VARCHAR2, --������¼���������
                                   av_clrdate2         IN VARCHAR2, --��ǰ�������
                                   av_trcode           IN VARCHAR2, --���״���
                                   av_dbcardbal        IN NUMBER, --�跽���潻��ǰ���
                                   av_crcardbal        IN NUMBER, --�������潻��ǰ���
                                   av_dbcardcounter    IN NUMBER, --�跽��Ƭ���׼�����
                                   av_crcardcounter    IN NUMBER, --������Ƭ���׼�����
                                   av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                                   av_crbalanceencrypt IN VARCHAR2, --�����������
                                   av_dbaccbal         in varchar2, --�跽����ǰ���
                                   av_craccbal         IN varchar2, --��������ǰ���
                                   av_confirm          IN VARCHAR2, --1ֱ��ȷ��
                                   av_debug            IN VARCHAR2, --1д������־
                                   av_res              OUT VARCHAR2, --��������
                                   av_msg              OUT VARCHAR2 --����������Ϣ
                                   ) IS
    lv_tablename    VARCHAR2(50);
    lv_newtablename VARCHAR2(50);
    lv_newaccbookno acc_inout_detail.acc_inout_no%TYPE; --������¼��acc_book_no
    lv_sql          VARCHAR2(2000);
    lv_clrdate      pay_clr_para.clr_date%TYPE; --�������
    lv_oldtrdate    DATE;
    lv_daybook      acc_inout_detail%ROWTYPE;
    lv_sysactionlog sys_action_log%ROWTYPE;
    lv_count        number;
  BEGIN
    IF av_debug = '1' THEN
      pk_public.p_insertrzcllog('���˳�����ԭacc_inout_no' ||
                                av_daybook.acc_inout_no || '����deal_no' ||
                                av_actionno2,
                                av_actionno2);
    END IF;
  
    lv_clrdate := av_clrdate2;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    SELECT count(1)
      INTO lv_count
      FROM Sys_Action_Log t
     WHERE t.deal_no = av_actionno2;
    if lv_count = 0 then
      lv_sysactionlog.deal_no   := av_actionno2;
      lv_sysactionlog.deal_time := sysdate;
    end if;
    --����ԭ��¼�ĳɳ���״̬д����ʱ��
    EXECUTE IMMEDIATE 'update acc_inout_detail_' ||
                      to_char(to_date(av_clrdate1, 'yyyy-mm-dd'), 'yyyymm') ||
                      ' set deal_state = 1,rev_time = sysdate,note = note || ''_�ѳ���''' ||
                      ' where acc_inout_no = :1 and deal_state = 0 returning deal_date into :2'
      USING av_daybook.acc_inout_no
      RETURNING INTO lv_oldtrdate;
    IF SQL%ROWCOUNT = 0 THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := '������Ҫ�����ļ�¼';
      RETURN;
    END IF;
  
    --����acc_inout_datail ������¼
    lv_daybook := av_daybook;
  
    IF av_operator.user_id IS NOT NULL AND --����ҵ������ļ��ˣ�������
       av_operator.user_id <> av_daybook.user_id THEN
      --������Ա��ԭ��Ա��һ��ʱ  ȡ���ڹ�Ա
      lv_daybook.user_id     := av_operator.user_id;
      lv_daybook.acpt_org_id := av_operator.org_id;
      lv_daybook.acpt_id     := av_operator.brch_id;
    
      --�跽���ֽ��Ŀ���߽跽������Ԥ����Ŀ
    
      IF lv_daybook.db_item_id = pk_public.cs_accitem_cash OR
         lv_daybook.db_item_id = pk_public.cs_accitem_brch_prestore THEN
        DECLARE
          lv_branch      sys_branch%ROWTYPE; --����
          lv_dbsubledger acc_account_sub%ROWTYPE; --�ֻ���
        BEGIN
          SELECT *
            INTO lv_branch
            FROM sys_branch
           WHERE brch_id = av_operator.brch_id;
        
          IF lv_branch.brch_type = '3' THEN
            --��������
            lv_dbsubledger.item_id := pk_public.cs_accitem_brch_prestore;
          ELSE
            lv_dbsubledger.item_id := pk_public.cs_accitem_cash;
          END IF;
        
          --ȡ�跽�ֻ���
          pk_public.p_getsubledgerbyclientid(av_operator.brch_id,
                                             lv_dbsubledger.item_id,
                                             lv_dbsubledger,
                                             av_res,
                                             av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
          lv_daybook.db_acc_name    := lv_dbsubledger.acc_name;
          lv_daybook.db_item_id     := lv_dbsubledger.item_id;
          lv_daybook.db_acc_no      := lv_dbsubledger.acc_no;
          lv_daybook.db_customer_id := lv_dbsubledger.customer_id;
          lv_daybook.db_acc_bal     := lv_dbsubledger.bal;
        END;
      ELSIF lv_daybook.cr_item_id = pk_public.cs_accitem_cash OR
            lv_daybook.db_item_id NOT IN
            (pk_public.cs_accitem_cash, pk_public.cs_accitem_org_bank) AND
            lv_daybook.cr_item_id = pk_public.cs_accitem_brch_prestore THEN
        DECLARE
          lv_branch      sys_branch%ROWTYPE; --����
          lv_crsubledger acc_account_sub%ROWTYPE; --�ֻ���
        BEGIN
          SELECT *
            INTO lv_branch
            FROM sys_branch
           WHERE brch_id = av_operator.brch_id;
          IF lv_branch.brch_type = '3' THEN
            --��������
            lv_crsubledger.item_id := pk_public.cs_accitem_brch_prestore;
          ELSE
            lv_crsubledger.item_id := pk_public.cs_accitem_cash;
          END IF;
          --ȡ�����ֻ���
          pk_public.p_getsubledgerbyclientid(av_operator.brch_id,
                                             lv_crsubledger.item_id,
                                             lv_crsubledger,
                                             av_res,
                                             av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
          lv_daybook.cr_acc_name    := lv_crsubledger.acc_name;
          lv_daybook.cr_item_id     := lv_crsubledger.item_id;
          lv_daybook.cr_acc_no      := lv_crsubledger.acc_no;
          lv_daybook.cr_customer_id := lv_crsubledger.customer_id;
          lv_daybook.cr_acc_bal     := lv_crsubledger.bal;
        END;
      ELSE
        --ȡ����˻��Ľ���ǰ���
        IF av_dbaccbal IS NULL THEN
          IF lv_daybook.db_card_no IS NULL THEN
            --��ͨ�˻�
            SELECT bal
              INTO lv_daybook.db_acc_bal
              FROM acc_account_sub
             WHERE acc_no = lv_daybook.db_acc_no;
          ELSE
            --���˻�
            SELECT pk_public.f_getcardbalance(lv_daybook.db_card_no,
                                              lv_daybook.db_acc_kind,
                                              pk_public.cs_defaultwalletid)
              INTO lv_daybook.db_acc_bal
              FROM dual;
          END IF;
        END IF;
        IF av_craccbal IS NULL THEN
          IF lv_daybook.cr_card_no IS NULL THEN
            --��ͨ�˻�
            SELECT bal
              INTO lv_daybook.cr_acc_bal
              FROM acc_account_sub
             WHERE acc_no = lv_daybook.cr_acc_no;
          ELSE
            --���˻�
            SELECT pk_public.f_getcardbalance(lv_daybook.cr_card_no,
                                              lv_daybook.cr_acc_kind,
                                              pk_public.cs_defaultwalletid)
              INTO lv_daybook.cr_acc_bal
              FROM dual;
          END IF;
        END IF;
      END IF;
    END IF; ----����������Ա��ԭ��Ա��һ�µĴ���
  
    --��������¼  Ҫ�����using �﷨��������
    SELECT seq_acc_book_no.nextval INTO lv_newaccbookno FROM dual;
  
    lv_sql := 'insert into acc_inout_detail' ||
              '(acc_inout_no,deal_code,card_org_id,' ||
              'acpt_org_id,acpt_type,acpt_id,user_id,deal_batch_no,end_deal_no,deal_date,rev_time,old_acc_inout_no,' ||
              'db_acc_name,db_item_id,db_acc_no,db_card_no,db_customer_id,db_card_type,db_acc_kind,db_acc_bal,db_amt,db_credit_amt,db_card_bal,db_card_counter,' ||
              'cr_acc_name,cr_item_id,cr_acc_no,cr_card_no,cr_customer_id,cr_card_type,cr_acc_kind,cr_acc_bal,cr_amt,cr_credit_amt,cr_card_bal,cr_card_counter,' ||
              'deal_state,deal_no,insert_time,note,clr_date)' || --
              'select :1,:2,card_org_id,' ||
              ':1,acpt_type,:2,:3,deal_batch_no,end_deal_no,to_date(''' ||
              to_char(nvl(lv_sysactionlog.deal_time, sysdate),
                      'yyyy-mm-dd hh24:mi:ss') ||
              ''',''yyyy-mm-dd hh24:mi:ss''), null,acc_inout_no,' ||
              ':3,:4,:5,db_card_no,:7,db_card_type,:8,:9,-db_amt,-db_credit_amt,:10,:11,' ||
              ':12,:13,:14,cr_card_no,:15,cr_card_type,:16,:17,-cr_amt,-cr_credit_amt,:18,:19,' ||
              '9,:20,sysdate,:21,:22 from acc_inout_detail_' ||
              to_char(to_date(av_clrdate1, 'yyyy-mm-dd'), 'yyyymm') ||
              ' where acc_inout_no =:8';
    EXECUTE IMMEDIATE lv_sql
      USING lv_newaccbookno, av_trcode, --
    lv_daybook.acpt_org_id, lv_daybook.acpt_id, lv_daybook.user_id, --
    lv_daybook.db_acc_name, lv_daybook.db_item_id, lv_daybook.db_acc_no, lv_daybook.db_customer_id, lv_daybook.db_acc_kind, nvl(av_dbaccbal, lv_daybook.db_acc_bal), CASE lv_daybook.db_acc_kind WHEN '01' THEN av_dbcardbal ELSE NULL END, CASE lv_daybook.db_acc_kind WHEN '01' THEN av_dbcardcounter ELSE NULL END, --
    lv_daybook.cr_acc_name, lv_daybook.cr_item_id, lv_daybook.cr_acc_no, lv_daybook.cr_customer_id, lv_daybook.cr_acc_kind, nvl(av_craccbal, lv_daybook.cr_acc_bal), CASE lv_daybook.cr_acc_kind WHEN '01' THEN av_crcardbal ELSE NULL END, CASE lv_daybook.cr_acc_kind WHEN '01' THEN av_crcardcounter ELSE NULL END, --
    av_actionno2, av_daybook.note || '����', av_clrdate2, av_daybook.acc_inout_no;
  
    --ת����
    IF av_daybook.db_card_no IS NOT NULL THEN
      lv_tablename := pk_public.f_gettrcardtable(av_daybook.db_card_no,
                                                 lv_oldtrdate);
      EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                        ' set deal_state = 1,rev_time = sysdate,note = note || ''_�ѳ���''' ||
                        ' where acc_inout_no = :1 and acc_no = :accno and deal_state = 0'
        USING av_daybook.acc_inout_no, av_daybook.db_acc_no;
      lv_newtablename := 'pay_card_deal_rec';
      lv_sql          := 'insert into ' || lv_newtablename ||
                         '(id, acc_inout_no, deal_code, org_id,' ||
                         ' acpt_type,acpt_id, user_id, deal_batch_no, end_deal_no, deal_date, rev_time, old_acc_inout_no,' ||
                         ' customer_id,acc_name, acc_no, card_no,card_type,acc_kind, acc_bal, amt,credit, card_bal, card_counter, deal_state,' ||
                         ' deal_no, insert_time,clr_date, note)' ||
                         'select seq_tr_card_id.nextval, :1, :2, :3,' ||
                         'acpt_type,:1, :2, deal_batch_no, end_deal_no, to_date(''' ||
                         to_char(nvl(lv_sysactionlog.deal_time, sysdate),
                                 'yyyy-mm-dd hh24:mi:ss') ||
                         ''',''yyyy-mm-dd hh24:mi:ss''), null, acc_inout_no,' ||
                         'customer_id,acc_name, acc_no, card_no,card_type,acc_kind, :2, -amt,-credit, :3, :4, 9,' ||
                         ':5, sysdate,:6, :7 from ' || lv_tablename ||
                         ' where acc_inout_no =:7 and acc_no = :8';
      EXECUTE IMMEDIATE lv_sql
        USING lv_newaccbookno, av_trcode, lv_daybook.card_org_id, lv_daybook.acpt_id, lv_daybook.user_id, --
      nvl(av_dbaccbal, lv_daybook.db_acc_bal), CASE lv_daybook.db_acc_kind WHEN '01' THEN av_dbcardbal ELSE NULL END, CASE lv_daybook.db_acc_kind WHEN '01' THEN av_dbcardcounter ELSE NULL END, av_actionno2, lv_clrdate, av_daybook.note || '����', av_daybook.acc_inout_no, av_daybook.db_acc_no;
    END IF;
  
    --ת�뿨�����׼�¼�޸ĳ��ѳ��������볷����¼���Ҽ�¼��
    IF av_daybook.cr_card_no IS NOT NULL THEN
      lv_tablename := pk_public.f_gettrcardtable(av_daybook.cr_card_no,
                                                 lv_oldtrdate);
      EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                        ' set deal_state = 1,rev_time = sysdate,note = note || ''_�ѳ���''' ||
                        ' where acc_inout_no = :1 and acc_no = :accno and deal_state = 0'
        USING av_daybook.acc_inout_no, av_daybook.cr_acc_no;
      lv_newtablename := 'pay_card_deal_rec';
      lv_sql          := 'insert into ' || lv_newtablename ||
                         '(id, acc_inout_no, deal_code, org_id,' ||
                         ' acpt_type,acpt_id, user_id, deal_batch_no, end_deal_no, deal_date, rev_time, old_acc_inout_no,' ||
                         ' customer_id,acc_name, acc_no, card_no,card_type,acc_kind, acc_bal, amt,credit, card_bal, card_counter, deal_state,' ||
                         ' deal_no, insert_time,clr_date, note)' ||
                         'select seq_tr_card_id.nextval, :1, :2, :3,' ||
                         'acpt_type,:1, :2, deal_batch_no, end_deal_no,to_date(''' ||
                         to_char(nvl(lv_sysactionlog.deal_time, sysdate),
                                 'yyyy-mm-dd hh24:mi:ss') ||
                         ''',''yyyy-mm-dd hh24:mi:ss''), null, acc_inout_no,' ||
                         'customer_id,acc_name, acc_no, card_no,card_type,acc_kind, :2, -amt,-credit, :3, :4, 9,' ||
                         ':5, sysdate,:6, :7 from ' || lv_tablename ||
                         ' where acc_inout_no =:7 and acc_no = :8';
      EXECUTE IMMEDIATE lv_sql
        USING lv_newaccbookno, av_trcode, lv_daybook.card_org_id, lv_daybook.acpt_id, lv_daybook.user_id, --
      nvl(av_craccbal, lv_daybook.cr_acc_bal), CASE lv_daybook.cr_acc_kind WHEN '01' THEN av_crcardbal ELSE NULL END, CASE lv_daybook.cr_acc_kind WHEN '01' THEN av_crcardcounter ELSE NULL END, av_actionno2, lv_clrdate, av_daybook.note || '����', av_daybook.acc_inout_no, av_daybook.cr_acc_no;
    END IF;
  
    IF av_confirm = '1' THEN
      --ֱ��ȷ��
    
      p_ashconfirmbyaccbookno(lv_clrdate, --�������
                              lv_newaccbookno, --ҵ����ˮ��
                              av_dbbalanceencrypt, --�跽�������
                              av_crbalanceencrypt, --�����������
                              av_dbaccbal, --�跽����ǰ���
                              av_craccbal, --��������ǰ���
                              av_debug, --1д������־
                              av_res, --��������
                              av_msg --����������Ϣ
                              );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSE
      av_res := pk_public.cs_res_ok;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '���˳�����������' || SQLERRM;
  END p_daybookcancel_onerow;
  /*=======================================================================================*/
  --���˳��� ���ݴ����acc_book_no������ daybook����˻�����,���д��
  /*=======================================================================================*/
  PROCEDURE p_daybookcancelbyaccbookno(av_accbookno        IN VARCHAR2, --Ҫ����acc_book_no
                                       av_actionno2        IN NUMBER, --��ҵ����ˮ��
                                       av_clrdate1         IN VARCHAR2, --������¼���������
                                       av_clrdate2         IN VARCHAR2, --��ǰ�������
                                       av_trcode           IN VARCHAR2, --���״���
                                       av_operid           IN VARCHAR2, --��ǰ��Ա
                                       av_dbcardbal        IN NUMBER, --�跽���潻��ǰ���
                                       av_crcardbal        IN NUMBER, --�������潻��ǰ���
                                       av_dbcardcounter    IN NUMBER, --�跽��Ƭ���׼�����
                                       av_crcardcounter    IN NUMBER, --������Ƭ���׼�����
                                       av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                                       av_crbalanceencrypt IN VARCHAR2, --�����������
                                       av_dbaccbal         in varchar2,
                                       av_craccbal         in varchar2,
                                       av_confirm          IN VARCHAR2, --1ֱ��ȷ��
                                       av_debug            IN VARCHAR2, --1д������־
                                       av_res              OUT VARCHAR2, --��������
                                       av_msg              OUT VARCHAR2 --����������Ϣ
                                       ) IS
    lv_daybook  acc_inout_detail%ROWTYPE;
    lv_cursor   pk_public.t_cur; --�α�
    lv_operator sys_users%ROWTYPE; --��Ա
  BEGIN
    SELECT * INTO lv_operator FROM sys_users WHERE user_id = av_operid;
    OPEN lv_cursor FOR 'select * from acc_inout_detail_' || to_char(to_date(av_clrdate1,
                                                                            'yyyy-mm-dd'),
                                                                    'yyyymm') || ' where acc_inout_no = :1 and deal_state = 0'
      USING av_accbookno; ---acc_book_no ����Ψһ�𣿣���������
    LOOP
      FETCH lv_cursor
        INTO lv_daybook;
      EXIT WHEN lv_cursor%NOTFOUND;
      p_daybookcancel_onerow(lv_daybook, --Ҫ����daybook
                             lv_operator, --��ǰ��Ա
                             av_actionno2, --��ҵ����ˮ��
                             av_clrdate1, --������¼���������
                             av_clrdate2, --��ǰ�������
                             av_trcode, --���״���
                             av_dbcardbal, --�跽���潻��ǰ���
                             av_crcardbal, --�������潻��ǰ���
                             av_dbcardcounter, --�跽��Ƭ���׼�����
                             av_crcardcounter, --������Ƭ���׼�����
                             av_dbbalanceencrypt, --�跽�������
                             av_crbalanceencrypt, --�����������
                             av_dbaccbal,
                             av_craccbal,
                             av_confirm, --1ֱ��ȷ��
                             av_debug, --1д������־
                             av_res, --��������
                             av_msg --����������Ϣ
                             );
      IF av_res <> pk_public.cs_res_ok THEN
        CLOSE lv_cursor;
        RETURN;
      END IF;
    END LOOP;
  
    CLOSE lv_cursor;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '���˳�����������' || SQLERRM;
  END p_daybookcancelbyaccbookno;
  /*=======================================================================================*/
  --ҵ����ˮ�ż��˳��� ������¼ daybook����˻�����,���д��   1��ҵ����ˮ�ſ��ܺܶ���acc_inout_detail ?????,������ô����һ�´��룿������
  /*=======================================================================================*/
  PROCEDURE p_daybookcancel(av_actionno1        IN NUMBER, --Ҫ����ҵ����ˮ��
                            av_actionno2        IN NUMBER, --��ҵ����ˮ��
                            av_clrdate1         IN VARCHAR2, --������¼���������
                            av_clrdate2         IN VARCHAR2, --��ǰ�������
                            av_trcode           IN VARCHAR2, --���״���
                            av_operid           IN VARCHAR2, --��ǰ��Ա
                            av_dbcardbal        IN NUMBER, --�跽���潻��ǰ���
                            av_crcardbal        IN NUMBER, --�������潻��ǰ���
                            av_dbcardcounter    IN NUMBER, --�跽��Ƭ���׼�����
                            av_crcardcounter    IN NUMBER, --������Ƭ���׼�����
                            av_dbbalanceencrypt IN VARCHAR2, --�跽�������
                            av_crbalanceencrypt IN VARCHAR2, --�����������
                            av_confirm          IN VARCHAR2, --1ֱ��ȷ��
                            av_debug            IN VARCHAR2, --1д������־
                            av_res              OUT VARCHAR2, --��������
                            av_msg              OUT VARCHAR2 --����������Ϣ
                            ) IS
    --lv_tablename    varchar2(50);
    --lv_newtablename varchar2(50);
    lv_daybook acc_inout_detail%ROWTYPE;
    --lv_newaccbookno acc_daybook.acc_book_no%type; --������¼��acc_book_no
    --lv_sql          varchar2(2000);
    lv_cursor   pk_public.t_cur; --�α�
    lv_clrdate  pay_clr_para.clr_date%TYPE; --�������
    lv_operator sys_users%ROWTYPE; --��Ա
  BEGIN
    IF av_debug = '1' THEN
      pk_public.p_insertrzcllog('���˳�����ԭaction_no' || av_actionno1 ||
                                '����action_no' || av_actionno2,
                                av_actionno2);
    END IF;
    lv_clrdate := av_clrdate2;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    SELECT * INTO lv_operator FROM sys_users WHERE user_id = av_operid;
    --����������¼
    --�ж��Ƿ�������
    NULL;
    OPEN lv_cursor FOR 'select * from acc_inout_detail_' || to_char(to_date(av_clrdate1,
                                                                            'yyyy-mm-dd'),
                                                                    'yyyymm') || ' where deal_no = :1 and deal_state = 0'
      USING av_actionno1;
    LOOP
      FETCH lv_cursor
        INTO lv_daybook;
      EXIT WHEN lv_cursor%NOTFOUND;
    
      --�Ƿ�Ҫȡ����ǰ������ģ���������
    
      p_daybookcancel_onerow(lv_daybook, --Ҫ����daybook
                             lv_operator, --��ǰ��Ա
                             av_actionno2, --��ҵ����ˮ��
                             av_clrdate1, --������¼���������
                             lv_clrdate, --��ǰ�������
                             av_trcode, --���״���
                             av_dbcardbal, --�跽���潻��ǰ���
                             av_crcardbal, --�������潻��ǰ���
                             av_dbcardcounter, --�跽��Ƭ���׼�����
                             av_crcardcounter, --������Ƭ���׼�����
                             av_dbbalanceencrypt, --�跽�������
                             av_crbalanceencrypt, --�����������
                             NULL, --�跽����ǰ���
                             av_crcardbal, --��������ǰ���
                             av_confirm, --1ֱ��ȷ��
                             av_debug, --1д������־
                             av_res, --��������
                             av_msg --����������Ϣ
                             );
      IF av_res <> pk_public.cs_res_ok THEN
        CLOSE lv_cursor;
        RETURN;
      END IF;
    END LOOP;
  
    CLOSE lv_cursor;
  
    av_res := pk_public.cs_res_ok;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '���˳�����������' || SQLERRM;
  END p_daybookcancel;
  /*=======================================================================================*/
  --��ȡ���˻������ѷ���ѵ�
  --  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --           5item_no|6amt|7note|8acpt_type|9pay_source(0�ֽ�1ת��)
  /*=======================================================================================*/
  PROCEDURE p_cost(av_in    IN VARCHAR2, --�������
                   av_debug IN VARCHAR2, --1����
                   av_res   OUT VARCHAR2, --������������
                   av_msg   OUT VARCHAR2 --��������������Ϣ
                   ) IS
    --lv_count       number;
    lv_in          pk_public.myarray; --�����������
    lv_dbsubledger acc_account_sub%ROWTYPE; --�跽�ֻ���
    lv_crsubledger acc_account_sub%ROWTYPE; --�����ֻ���
    lv_operator    sys_users%ROWTYPE; --��Ա
    lv_branch      sys_branch%ROWTYPE; --����
    lv_clrdate     pay_clr_para.clr_date%TYPE; --�������
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --������ˮ��
    --lv_starttime  INT;
    lv_dd TIMESTAMP := systimestamp;
  BEGIN
    --lv_starttime := dbms_utility.get_time;
    pk_public.p_getinputpara(av_in, --�������
                             8, --�������ٸ���
                             9, --����������
                             'pk_business.p_cost', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_in(9) IS NULL THEN
      lv_in(9) := '0';
    END IF;
    --select to_number(lv_in(6)) from dual;
    pk_public.p_insertrzcllog_('0',
                               'p_cost start:' ||
                               f_timestamp_diff(systimestamp, lv_dd),
                               lv_in(1));
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
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
  
    /*--���ֽ� ��������
    IF lv_in(6) > 0 THEN
      IF lv_in(9) = '0' THEN
        lv_dbsubledger.item_id := pk_public.cs_accitem_cash;
        IF lv_branch.brch_type = '3' THEN
          --��������
          lv_dbsubledger.item_id := pk_public.cs_accitem_brch_prestore;
        END IF;
        --ȡ�跽�ֻ���
        pk_public.p_getsubledgerbyclientid(lv_operator.brch_id,
                                           lv_dbsubledger.item_id,
                                           lv_dbsubledger,
                                           av_res,
                                           av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
      ELSE
        lv_dbsubledger.item_id := pk_public.cs_accitem_org_bank;
        pk_public.p_getorgsubledger(lv_operator.org_id,
                                    lv_dbsubledger.item_id,
                                    lv_dbsubledger,
                                    av_res,
                                    av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
      END IF;
    
      lv_crsubledger.item_id := lv_in(5);
      --ȡ�����ֻ���
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  lv_crsubledger.item_id,
                                  lv_crsubledger,
                                  av_res, --������������
                                  av_msg --��������������Ϣ
                                  );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --�˻�
    
    ELSIF lv_in(6) < 0 THEN
      lv_dbsubledger.item_id := lv_in(5);
      IF lv_in(9) = '0' THEN
        lv_crsubledger.item_id := pk_public.cs_accitem_cash;
        IF lv_branch.brch_type = '3' THEN
          --��������
          lv_crsubledger.item_id := pk_public.cs_accitem_brch_prestore;
        END IF;
        --ȡ�����ֻ���
        pk_public.p_getsubledgerbyclientid(lv_operator.brch_id,
                                           lv_crsubledger.item_id,
                                           lv_crsubledger,
                                           av_res, --������������
                                           av_msg --��������������Ϣ
                                           );
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
      ELSE
        lv_crsubledger.item_id := pk_public.cs_accitem_org_bank;
        pk_public.p_getorgsubledger(lv_operator.org_id,
                                    lv_crsubledger.item_id,
                                    lv_crsubledger,
                                    av_res,
                                    av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
      END IF;
      --ȡ�跽�ֻ���
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  lv_dbsubledger.item_id,
                                  lv_dbsubledger,
                                  av_res,
                                  av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSE
      RETURN;
    END IF;*/
    --д��ˮ
    IF lv_in(9) = '0' THEN
      lv_dbsubledger.item_id := pk_public.cs_accitem_cash;
      IF lv_branch.brch_type = '3' THEN
        --��������
        lv_dbsubledger.item_id := pk_public.cs_accitem_brch_prestore;
      END IF;
      --ȡ�跽�ֻ���
      pk_public.p_getsubledgerbyclientid(lv_operator.brch_id,
                                         lv_dbsubledger.item_id,
                                         lv_dbsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSE
      lv_dbsubledger.item_id := pk_public.cs_accitem_org_bank;
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  lv_dbsubledger.item_id,
                                  lv_dbsubledger,
                                  av_res,
                                  av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
  
    lv_crsubledger.item_id := lv_in(5);
    --ȡ�����ֻ���
    pk_public.p_getorgsubledger(lv_operator.org_id,
                                lv_crsubledger.item_id,
                                lv_crsubledger,
                                av_res, --������������
                                av_msg --��������������Ϣ
                                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    pk_public.p_insertrzcllog_('0',
                               'p_cost start p_account:' ||
                               f_timestamp_diff(systimestamp, lv_dd),
                               lv_in(1));
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    p_account(lv_dbsubledger, --�跽�˻�
              lv_crsubledger, --�����˻�
              NULL, --�跽���潻��ǰ���
              NULL, --������Ƭ���׼�����
              NULL, --�跽��Ƭ���׼�����
              NULL, --������Ƭ���׼�����
              NULL, --�跽�������
              NULL, --�����������
              lv_in(6), --���׽��
              0, --���÷�����
              lv_accbookno, --������ˮ��
              lv_in(2), --���״���
              lv_crsubledger.org_id, --��������
              lv_operator.org_id, --�������
              lv_in(8), --��������
              lv_operator.brch_id, --��������(�����/�̻��ŵ�)
              lv_operator.user_id, --������Ա/�ն˺�
              NULL, --�������κ�
              NULL, --�ն˽�����ˮ��
              to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --����ʱ��
              '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
              lv_in(1), --ҵ����ˮ��
              lv_in(7), --��ע
              lv_clrdate, --�������
              null,
              av_debug, --1����
              av_res, --������������
              av_msg --��������������Ϣ
              );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --pk_public.p_insertrzcllog('������ ʱ��' || to_char(dbms_utility.get_time-lv_starttime) || '���������' || av_in, -99990003);
    pk_public.p_insertrzcllog_('0',
                               'p_cost end:' || av_in,
                               f_timestamp_diff(systimestamp, lv_dd));
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�շѼ��˷�������' || SQLERRM;
  END p_cost;
  /*=======================================================================================*/
  --�ֽ𽻽�
  --  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --           5oper_id1|6oper_id2|7amt|8note|9acpt_type
  /*=======================================================================================*/
  PROCEDURE p_cashhandover(av_in    IN VARCHAR2, --�������
                           av_debug IN VARCHAR2, --1����
                           av_res   OUT VARCHAR2, --������������
                           av_msg   OUT VARCHAR2 --��������������Ϣ
                           ) IS
    --lv_count       number;
    lv_in          pk_public.myarray; --�����������
    lv_dbsubledger acc_account_sub%ROWTYPE; --�跽�ֻ���
    lv_crsubledger acc_account_sub%ROWTYPE; --�����ֻ���
    lv_operator    sys_users%ROWTYPE; --��Ա
    lv_operator1   sys_users%ROWTYPE; --��Ա1
    lv_operator2   sys_users%ROWTYPE; --��Ա2
    lv_clrdate     pay_clr_para.clr_date%TYPE; --�������
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --������ˮ��
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             8, --�������ٸ���
                             9, --����������
                             'pk_business.p_cashhandover', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
  
    IF lv_in(3) <> lv_in(5) AND lv_in(3) <> lv_in(6) THEN
      av_res := pk_public.cs_res_operatorerr;
      av_msg := '�ֽ𽻽ӵ�������Ա�б�����һ���ǲ�����Ա';
      RETURN;
    END IF;
    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = lv_in(3);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := 'δ�ҵ���Ա���' || lv_in(3);
        RETURN;
    END;
    BEGIN
      SELECT * INTO lv_operator1 FROM sys_users WHERE user_id = lv_in(5);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := 'δ�ҵ���Ա���' || lv_in(5);
        RETURN;
    END;
    BEGIN
      SELECT * INTO lv_operator2 FROM sys_users WHERE user_id = lv_in(6);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := 'δ�ҵ���Ա���' || lv_in(6);
        RETURN;
    END;
    --���ֽ�
    p_updatecashbox(lv_in(1), --������ˮ��
                    lv_in(2), --���״���
                    lv_operator1.user_id, --��Ա���
                    lv_in(4), --����yyyy-mm-dd hh24:mi:ss
                    -lv_in(7), --���
                    lv_in(8), --��ע
                    lv_clrdate, --�������
                    lv_operator2.org_id, --�Է�����
                    lv_operator2.brch_id, --�Է�����
                    lv_operator2.user_id, --�Է���Ա
                    av_res, --������������
                    av_msg --��������������Ϣ
                    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --���ֽ�
    p_updatecashbox(lv_in(1), --������ˮ��
                    lv_in(2), --���״���
                    lv_operator2.user_id, --��Ա���
                    lv_in(4), --����yyyy-mm-dd hh24:mi:ss
                    lv_in(7), --���
                    lv_in(8), --��ע
                    lv_clrdate, --�������
                    lv_operator1.org_id, --�Է�����
                    lv_operator1.brch_id, --�Է�����
                    lv_operator1.user_id, --�Է���Ա
                    av_res, --������������
                    av_msg --��������������Ϣ
                    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_operator1.brch_id <> lv_operator2.brch_id THEN
      --���ֽ� ���ֽ�
      lv_dbsubledger.item_id := pk_public.cs_accitem_cash;
      lv_crsubledger.item_id := pk_public.cs_accitem_cash;
      --ȡ�跽�ֻ���
      pk_public.p_getsubledgerbyclientid(lv_operator1.brch_id,
                                         lv_dbsubledger.item_id,
                                         lv_dbsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --ȡ�����ֻ���
      pk_public.p_getsubledgerbyclientid(lv_operator2.brch_id,
                                         lv_crsubledger.item_id,
                                         lv_crsubledger,
                                         av_res, --������������
                                         av_msg --��������������Ϣ
                                         );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --д��ˮ
      SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
      p_account(lv_dbsubledger, --�跽�˻�
                lv_crsubledger, --�����˻�
                NULL, --�跽���潻��ǰ���
                NULL, --������Ƭ���׼�����
                NULL, --�跽��Ƭ���׼�����
                NULL, --������Ƭ���׼�����
                NULL, --�跽�������
                NULL, --�����������
                lv_in(7), --���׽��
                0, --���÷�����
                lv_accbookno, --������ˮ��
                lv_in(2), --���״���
                lv_operator.org_id, --��������
                lv_operator.org_id, --�������
                lv_in(9), --��������
                lv_operator.brch_id, --��������(�����/�̻��ŵ�)
                lv_operator.user_id, --������Ա/�ն˺�
                NULL, --�������κ�
                NULL, --�ն˽�����ˮ��
                to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --����ʱ��
                '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                lv_in(1), --ҵ����ˮ��
                lv_in(8), --��ע
                lv_clrdate, --�������
                null,
                av_debug, --1����
                av_res, --������������
                av_msg --��������������Ϣ
                );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�ֽ���˷�������' || SQLERRM;
  END p_cashhandover;

  /*=======================================================================================*/
  --��ʱ�������ű�����ʹ�����ݵ���ʷ�����ڿ����Զ����ɺ󴥷�
  --ԭ�򣬿��ű���״̬Ϊ��ʹ�ã���action_no��Ӧ������״̬>�����ɲ������Ƶ���ʷ��
  --�ұ�����ǰ�������ɹ���Ŀ������е����ֵ�����������ɵĿ����ظ�
  /*=======================================================================================*/
  PROCEDURE p_card_no_2_his(av_res OUT VARCHAR2, --��������
                            av_msg OUT VARCHAR2 --����������Ϣ
                            ) IS
    ld_date       DATE := SYSDATE;
    ls_max_cardno card_no.card_no%TYPE := '1';
    ln_count      NUMBER;
  BEGIN
    av_res   := pk_public.cs_res_ok;
    ln_count := 0;
    FOR lrec_cardno IN (SELECT t.deal_no,
                               --t.task_sum,--������
                               --b.cnt,--������
                               b.city, --����
                               b.card_catalog, --������
                               b.card_type --��С��
                          FROM card_apply_task t,
                               (SELECT deal_no,
                                       --count(1) cnt,
                                       MAX(city) city,
                                       MAX(card_catalog) card_catalog,
                                       MAX(card_type) card_type
                                  FROM card_no
                                 WHERE used = '0' --��ʹ��
                                 GROUP BY deal_no) b
                         WHERE t.deal_no = b.deal_no
                           AND t.task_state > '0' --����״̬>������
                         ORDER BY t.task_id) LOOP
      --�ҳ���ǰ���ű��У���ǰͬ����ǰ׺���Ŀ��ţ������˿��Ų�ɾ��
      SELECT MAX(card_no)
        INTO ls_max_cardno
        FROM card_no t
       WHERE city = lrec_cardno.city
         AND (card_catalog IS NULL OR
             card_catalog = lrec_cardno.card_catalog)
         AND (card_type IS NULL OR card_type = lrec_cardno.card_type);
    
      /* INSERT INTO card_no_his
      SELECT t.*, ld_date
        FROM card_no t
       WHERE deal_no = lrec_cardno.deal_no
         AND used = '0'
         AND card_no <> ls_max_cardno;*/
      ln_count := ln_count + SQL%ROWCOUNT;
      DELETE FROM card_no
       WHERE deal_no = lrec_cardno.deal_no
         AND used = '0'
         AND card_no <> ls_max_cardno;
      ln_count := ln_count + SQL%ROWCOUNT;
    END LOOP;
    av_msg := ln_count || '';
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '�Ƴ����ŵ���ʱ���쳣��' || SQLERRM;
    
  END p_card_no_2_his;

  /*=======================================================================================*/
  --�г��ű������ʱ������
  /*=======================================================================================*/
  /* procedure p_change_market_reg_no is
    ld_date date := sysdate;
    ls_date varchar2(10);
  begin
    select to_char(ld_date, 'yyyy-mm-dd') into ls_date from dual;
    for lrec_m in (select *
                     from bs_market_change
                    where STATE = '0' --δ��Ч
                      and valid_date <= ls_date --�ѵ���Ч����
                    order by valid_date, MARKET_REG_NO) loop
      --������¼��Ч
      update bs_market_change
         set valid_date = ls_date, EFFECT_TIME = ld_date
       where id = lrec_m.id;
      update bs_market
         set market_reg_no = lrec_m.market_reg_no
       where market_id = lrec_m.market_id;
  
      --ǰһ����¼ʧЧ
      update bs_market_change
         set invalid_date = ls_date
       where market_reg_no_old = lrec_m.market_reg_no_old
         and state = '2'; --ʧЧ
    end loop;
    /* exception
    when others then
      null;
  end p_change_market_reg_no;*/

  procedure p_account2(av_db_acc_no        varchar2, --�跽�˻�
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
  end p_account2;

END pk_business;
/

