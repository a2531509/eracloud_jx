CREATE OR REPLACE PACKAGE BODY pk_points IS
  /*=======================================================================================*/
  --���ֶһ�
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acpt_id        �������(����Ż��̻����)
  --       6tr_batch_no    ���κ�
  --       7term_tr_no     �ն˽�����ˮ��
  --       8card_no        ����
  --       9tr_amt         �һ��Ļ�����
  --      10type           �һ����� 1�һ���δȦ���˻�2�һ���Ʒ3���ֵ��ڿۼ�
  --      11note           ��ע
  --      12encrypt        �һ�������1ʱ �һ���δȦ���˻��������
  --      13acpt_type      ��������
  --av_out: 1acc_book_no,points_from
  --     points_from: ���ֹ��ɣ�����ǿ�ȡ���ڻ��ֵǼ�����Ϊ2013:300|2014:200
  /*=======================================================================================*/
  PROCEDURE p_exchange(av_in    IN VARCHAR2, --�������
                       av_debug IN VARCHAR2, --1����
                       av_res   OUT VARCHAR2, --��������
                       av_msg   OUT VARCHAR2, --����������Ϣ
                       av_out   OUT VARCHAR2 --��������
                       ) IS
    --lv_count       NUMBER;
    lv_in          pk_public.myarray; --�����������
    lv_dbsubledger acc_account_sub%ROWTYPE; --�跽�ֻ���
    lv_crsubledger acc_account_sub%ROWTYPE; --�����ֻ���
    lv_operator    sys_users%ROWTYPE; --����Ա
    lv_clrdate     pay_clr_para.clr_date%TYPE; --�������
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --������ˮ��
    lv_tablename   VARCHAR2(50);
    lv_sql         VARCHAR2(2000);
    TYPE t_points IS TABLE OF points_book%ROWTYPE;
    lv_points t_points;
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             12, --�������ٸ���
                             13, --����������
                             'pk_points.p_exchange', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = lv_in(3);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := 'δ�ҵ���Ա���' || lv_in(3);
        RETURN;
    END;
    --����������̻���
    IF lv_in(5) IS NULL THEN
      lv_in(5) := lv_operator.brch_id;
    END IF;
    --11111111111111111���ֿ۳�
    --ȡ�跽�ֻ���
    pk_public.p_getsubledgerbycardno(lv_in(8), --����
                                     pk_public.cs_acckind_jf, --�˻�����
                                     pk_public.cs_defaultwalletid, --Ǯ�����
                                     lv_dbsubledger, --�ֻ���
                                     av_res, --������������
                                     av_msg --��������������Ϣ
                                     );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_dbsubledger.bal < lv_in(9) THEN
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '��������';
      RETURN;
    END IF;
    --����ÿ��/ÿ�µĻ��ֱַ�۶���
    DECLARE
      lv_tempamt NUMBER;
    BEGIN
      lv_tablename := pk_public.f_getpointsperiodbycard_no(lv_dbsubledger.card_no);
      IF lv_in(10) = 3 THEN
        --���ֵ��ڿۼ�
        lv_sql := 'select * from ' || lv_tablename ||
                  ' where card_no = :1 order by period_name';
      ELSE
        lv_sql := 'select * from ' || lv_tablename ||
                  ' where card_no = :1 and invalid_date > to_char(sysdate,''yyyy-mm-dd'') order by period_name';
      END IF;

      EXECUTE IMMEDIATE lv_sql BULK COLLECT
        INTO lv_points
        USING lv_in(8);
      lv_tempamt := lv_in(9);
      FOR i IN 1 .. lv_points.count LOOP
        IF lv_points(i).points_sum - lv_points(i).points_used >= lv_tempamt THEN
          --����
          IF av_out IS NOT NULL THEN
            av_out := av_out || '|';
          END IF;
          av_out := av_out || lv_points(i).period_name || ':' || lv_tempamt;
          EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                            ' set points_used = points_used + :1 where period_id = :2 and points_used=:3'
            USING lv_tempamt, lv_points(i).period_id, lv_points(i).points_used;
          IF SQL%ROWCOUNT = 0 THEN
            av_res := pk_public.cs_res_dberr;
            av_msg := '������һ�������ڿ۳�����';
            RETURN;
          ELSE
            lv_tempamt := 0;
            EXIT;
          END IF;
        ELSE
          --������
          IF av_out IS NOT NULL THEN
            av_out := av_out || '|';
          END IF;
          av_out := av_out || lv_points(i).period_name || ':' ||
                    (lv_points(i).points_sum - lv_points(i).points_used);
          EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                            ' set points_used = points_used + :1 where period_id = :2 and points_used=:3'
            USING lv_points(i).points_sum - lv_points(i).points_used, lv_points(i).period_id, lv_points(i).points_used;
          IF SQL%ROWCOUNT = 0 THEN
            av_res := pk_public.cs_res_dberr;
            av_msg := '������һ�������ڿ۳�����';
            RETURN;
          ELSE
            lv_tempamt := lv_tempamt - (lv_points(i).points_sum - lv_points(i)
                          .points_used);
          END IF;
        END IF;
      END LOOP;
      IF lv_tempamt > 0 THEN
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '��������';
        RETURN;
      END IF;
    END;
    --��������ÿ��/ÿ�µĻ��ֱַ�۶���

    --ȡ�����ֻ���
    pk_public.p_getorgsubledger(lv_operator.org_id,
                                pk_public.cs_accitem_org_points,
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
                          NULL, --�跽�������
                          NULL, --�����������
                          lv_in(9), --���׽��
                          0, --���÷�����
                          lv_accbookno, --������ˮ��
                          lv_in(2), --���״���
                          NULL,--��������
                          lv_operator.org_id, --�������
                          lv_in(13), --��������
                          lv_in(5), --��������(�����/�̻��ŵ�)
                          lv_in(3), --������Ա/�ն˺�
                          lv_in(6), --�������κ�
                          lv_in(7), --�ն˽�����ˮ��
                          to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --����ʱ��
                          '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                          lv_in(1), --ҵ����ˮ��
                          lv_in(11), --��ע
                          lv_clrdate, --�������
                          NULL, --����������� �˻�ʱ����ԭacc_book_no
                          av_debug, --1����
                          av_res, --������������
                          av_msg --��������������Ϣ
                          );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    ELSE
      av_out := lv_accbookno || ',' || av_out;
    END IF;
    --222222222222222222ת��δȦ���˻�
    IF lv_in(10) = '1' THEN
      --ȡ�跽�ֻ���
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  pk_public.cs_accitem_org_points_chg_out,
                                  lv_dbsubledger,
                                  av_res,
                                  av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --ȡ�����ֻ���
      pk_public.p_getsubledgerbycardno(lv_in(8),
                                       pk_public.cs_points_exchange_acc,
                                       pk_public.cs_defaultwalletid, --Ǯ�����
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
                            NULL, --�跽�������
                            lv_in(12), --�����������
                            lv_in(9) * pk_public.cs_points_exchange_rate / 100, --���׽��
                            0, --���÷�����
                            lv_accbookno, --������ˮ��
                            lv_in(2), --���״���
                            lv_operator.org_id, --��������
                            lv_operator.org_id, --�������
                            lv_in(13), --��������
                            lv_in(5), --��������(�����/�̻��ŵ�)
                            lv_in(3), --������Ա/�ն˺�
                            lv_in(6), --�������κ�
                            lv_in(7), --�ն˽�����ˮ��
                            to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --����ʱ��
                            '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                            lv_in(1), --ҵ����ˮ��
                            lv_in(11), --��ע
                            lv_clrdate, --�������
                            av_debug, --1����
                            NULL,--��������
                            av_res, --������������
                            av_msg --��������������Ϣ
                            );
    END IF;
  END p_exchange;

  /*=======================================================================================*/
  --���ֶһ�����
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no ԭ��¼��action_no
  --       6clr_date  ԭ��¼���������
  --       7card_no   ����
  --       8encrypt   ������δȦ���˻��������
  /*=======================================================================================*/
  PROCEDURE p_exchangecancel(av_in    IN VARCHAR2, --�������
                             av_debug IN VARCHAR2, --1����
                             av_res   OUT VARCHAR2, --��������
                             av_msg   OUT VARCHAR2, --����������Ϣ
                             av_out   OUT VARCHAR2 --��������
                             ) IS
    lv_count      NUMBER;
    lv_in         pk_public.myarray; --�����������
    lv_operator   sys_users%ROWTYPE; --����Ա
    lv_clrdate    pay_clr_para.clr_date%TYPE; --�������
    lv_tablename  VARCHAR2(50);
    lv_pointsfrom points_exchange_info.points_from%TYPE; --���ֹ���
    lv_points     pk_public.myarray; --���ֹ�������
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             9, --�������ٸ���
                             9, --����������
                             'pk_points.p_exchangecancel', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = lv_in(3);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := 'δ�ҵ���Ա���' || lv_in(3);
        RETURN;
    END;
    --���ݶһ�ʱ�Ļ��ֹ��ɻ�ԭ����
    SELECT points_from
      INTO lv_pointsfrom
      FROM points_exchange_info
     WHERE action_no = lv_in(5);
    lv_count     := pk_public.f_splitstr(lv_pointsfrom, '|', lv_points);
    lv_tablename := pk_public.f_getpointsperiodbycard_no(lv_in(7));
    FOR i IN 1 .. lv_count LOOP
      IF lv_points(i) IS NOT NULL THEN
        IF instrb(lv_points(i), ':') < 1 THEN
          av_res := pk_public.cs_res_dberr;
          av_msg := '���ֶһ���Ϣ�еĻ��ֹ��ɴ���';
          RETURN;
        END IF;
        EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                          ' set points_used=points_used - :1 where card_no = :2 and period_name = :3'
          USING substrb(lv_points(i), instrb(lv_points(i), ':') + 1), lv_in(7), substrb(lv_points(i), 1, instrb(lv_points(i), ':') - 1);
        IF SQL%ROWCOUNT = 0 THEN
          av_res := pk_public.cs_res_dberr;
          av_msg := '���ֹ��ɱ���δ�ҵ���Ӧ�����ڼ�¼������' || lv_in(7) || '������' ||
                    substrb(lv_points(i), 1, instrb(lv_points(i), ':') - 1);
          RETURN;
        END IF;
      END IF;
    END LOOP;
    --������ˮ
    pk_business.p_daybookcancel(lv_in(5), --Ҫ����ҵ����ˮ��
                                lv_in(1), --��ҵ����ˮ��
                                lv_in(6), --������¼���������
                                lv_clrdate, --��ǰ�������
                                lv_in(2), --���״���
                                lv_in(3), --��Ա���
                                NULL, --�跽���潻��ǰ���
                                NULL, --�������潻��ǰ���
                                NULL, --�跽��Ƭ���׼�����
                                NULL, --������Ƭ���׼�����
                                NULL, --�跽�������
                                lv_in(8), --�����������
                                '1', --1ֱ��ȷ��
                                av_debug, --1д������־
                                av_res, --��������
                                av_msg --����������Ϣ
                                );
    av_out := NULL;
  END p_exchangecancel;

  /*=======================================================================================*/
  --��������
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acpt_id        �������(����Ż��̻����)
  --       6tr_batch_no    ���κ�
  --       7term_tr_no     �ն˽�����ˮ��
  --       8card_no        ����
  --       9tr_amt         ���ӵĻ�����
  --      10type           �������ӵ�;��
  --      11note           ��ע
  /*=======================================================================================*/
  PROCEDURE p_generate(av_in    IN VARCHAR2, --�������
                       av_debug IN VARCHAR2, --1����
                       av_res   OUT VARCHAR2, --��������
                       av_msg   OUT VARCHAR2, --����������Ϣ
                       av_out   OUT VARCHAR2 --��������
                       ) IS
    --lv_count       number;
    lv_in          pk_public.myarray; --�����������
    lv_dbsubledger acc_account_sub%ROWTYPE; --�跽�ֻ���
    --lv_crsubledger acc_account_sub%ROWTYPE; --�����ֻ���
    lv_operator sys_users%ROWTYPE; --����Ա
    lv_clrdate  pay_clr_para.clr_date%TYPE; --�������
    --lv_accbookno   acc_daybook.acc_book_no%TYPE; --������ˮ��
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             11, --�������ٸ���
                             11, --����������
                             'pk_points.p_generate', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = lv_in(3);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := 'δ�ҵ���Ա���' || lv_in(3);
        RETURN;
    END;
    --����������̻���
    IF lv_in(5) IS NULL THEN
      lv_in(5) := lv_operator.brch_id;
    END IF;
    --11111111111111111��������
    --ȡ�跽�ֻ���
    pk_public.p_getorgsubledger(lv_operator.org_id,
                                pk_public.cs_accitem_org_points,
                                lv_dbsubledger,
                                av_res,
                                av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    p_generate(lv_dbsubledger, --���ֽ跽�ֻ���
               lv_in(8), --����
               lv_in(9), --����
               lv_in(2), --���״���
               lv_operator.org_id, --����������
               lv_in(5), --��������(�����/�̻��ŵ�)
               lv_in(3), --������Ա/�ն˺�
               lv_in(6), --�������κ�
               lv_in(7), --�ն˽�����ˮ��
               lv_in(1), --ҵ����ˮ��
               lv_in(11), --��ע
               lv_clrdate, --�������
               av_debug, --1����
               av_res, --��������
               av_msg --����������Ϣ
               );
    av_out := NULL;
  END p_generate;

  /*=======================================================================================*/
  --�����������ȡ���ֵļ������ں�ʧЧ����
  /*=======================================================================================*/
  PROCEDURE p_getpointsperiod(av_clrdate      IN VARCHAR2, --�������
                              av_period_name  OUT VARCHAR2, --����˵������2014-01-01(��)��2014-01(��)��2014(��)
                              av_invalid_date OUT VARCHAR2, --����ʧЧ����
                              av_res          OUT VARCHAR2, --��������
                              av_msg          OUT VARCHAR2 --����������Ϣ
                              ) IS
  BEGIN
    --���� ���ֹ��ɱ�
    IF pk_public.cs_points_period_rule = '1' THEN
      --1��2��3��4��
      av_period_name := av_clrdate;
      --ʧЧ����
      av_invalid_date := to_char(to_date(av_clrdate, 'yyyy-mm-dd') +
                                 pk_public.cs_points_period,
                                 'yyyy-mm-dd');
    ELSIF pk_public.cs_points_period_rule = '2' THEN
      --2��
      av_period_name  := substr(av_clrdate, 1, 7);
      av_invalid_date := to_char(add_months(to_date(av_period_name,
                                                    'yyyy-mm'),
                                            pk_public.cs_points_period),
                                 'yyyy-mm-dd');
    ELSIF pk_public.cs_points_period_rule = '3' THEN
      --3��
      av_period_name  := to_char(trunc(to_date(av_clrdate, 'yyyy-mm-dd'),
                                       'Q'),
                                 'yyyy-mm');
      av_invalid_date := to_char(add_months(to_date(av_period_name,
                                                    'yyyy-mm'),
                                            3 * pk_public.cs_points_period),
                                 'yyyy-mm-dd');
    ELSIF pk_public.cs_points_period_rule = '4' THEN
      --4��
      av_period_name  := substr(av_clrdate, 1, 4);
      av_invalid_date := (av_period_name + pk_public.cs_points_period) ||
                         '-01-01';
    ELSE
      av_res := pk_public.cs_res_dberr;
      av_msg := 'ϵͳ�������л��ּ��ڹ����������';
      RETURN;
    END IF;

    av_res := pk_public.cs_res_ok;
  END p_getpointsperiod;

  /*=======================================================================================*/
  --��������
  /*=======================================================================================*/
  PROCEDURE p_generate(av_dbsubledger IN acc_account_sub%ROWTYPE, --���ֽ跽�ֻ���
                       av_cardno      IN VARCHAR2, --����
                       av_amt         IN NUMBER, --����
                       av_trcode      IN VARCHAR2, --���״���
                       av_orgid       IN VARCHAR2, --����������
                       av_brchid      IN VARCHAR2, --��������(�����/�̻��ŵ�)
                       av_operid      IN VARCHAR2, --������Ա/�ն˺�
                       av_trbatchno   IN VARCHAR2, --�������κ�
                       av_termtrno    IN VARCHAR2, --�ն˽�����ˮ��
                       av_actionno    IN NUMBER, --ҵ����ˮ��
                       av_note        IN VARCHAR2, --��ע
                       av_clrdate     IN VARCHAR2, --�������
                       av_debug       IN VARCHAR2, --1����
                       av_res         OUT VARCHAR2, --��������
                       av_msg         OUT VARCHAR2 --����������Ϣ
                       ) IS
    lv_count        NUMBER;
    lv_tablename    VARCHAR2(50);
    lv_crsubledger  acc_account_sub%ROWTYPE; --�����ֻ���
    lv_clrdate      pay_clr_para.clr_date%TYPE; --�������
    lv_accbookno    acc_inout_detail.acc_inout_no%TYPE; --������ˮ��
    lv_period_name  VARCHAR2(20); --����˵������2014-01-01(��)��2014-01(��)��2014(��)
    lv_invalid_date VARCHAR2(20); --����ʧЧ����
  BEGIN
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    --ȡ���ֵļ������ں�ʧЧ����
    p_getpointsperiod(lv_clrdate, --�������
                      lv_period_name, --����˵������2014-01-01(��)��2014-01(��)��2014(��)
                      lv_invalid_date, --����ʧЧ����
                      av_res, --��������
                      av_msg --����������Ϣ
                      );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --ȡ�����ֻ���
    pk_public.p_getsubledgerbycardno(av_cardno, --����
                                     pk_public.cs_acckind_jf, --�˻�����
                                     pk_public.cs_defaultwalletid, --Ǯ�����
                                     lv_crsubledger, --�ֻ���
                                     av_res, --������������
                                     av_msg --��������������Ϣ
                                     );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --
    lv_tablename := 'points_book';
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || lv_tablename ||
                      ' WHERE card_no = :1 AND period_name = :2'
      INTO lv_count
      USING av_cardno, lv_period_name;
    IF lv_count = 0 THEN
      EXECUTE IMMEDIATE 'INSERT INTO ' || lv_tablename ||
                        '(period_id, org_id,acc_no, client_id, card_no, card_type, points_tot, points_used, period_rule, period_name, invalid_date, insert_time)' ||
                        'SELECT SEQ_ACC_POINTS_PERIOD_ID.nextval,:1,:2,:3,:4,:5,0,:6,:7,:8,:9,SYSDATE FROM dual'
        USING lv_crsubledger.org_id,lv_crsubledger.acc_no, lv_crsubledger.customer_id, av_cardno, lv_crsubledger.card_type, av_amt, pk_public.cs_points_period_rule, lv_period_name, lv_invalid_date;
      NULL;
    ELSE
      EXECUTE IMMEDIATE 'UPDATE ' || lv_tablename ||
                        ' SET points_sum = points_sum + :1 WHERE card_no = :2 AND period_name = :3'
        USING av_amt, av_cardno, lv_period_name;
    END IF;
    --д��ˮ
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    pk_business.p_account(av_dbsubledger, --�跽�˻�
                          lv_crsubledger, --�����˻�
                          NULL, --�跽���潻��ǰ���
                          NULL, --�������潻��ǰ���
                          NULL, --�跽��Ƭ���׼�����
                          NULL, --������Ƭ���׼�����
                          NULL, --�跽�������
                          NULL, --�����������
                          av_amt, --���׽��
                          0, --���÷�����
                          lv_accbookno, --������ˮ��
                          av_trcode, --���״���
                          av_orgid,--��������
                          av_orgid, --�������
                          pk_public.cs_acpt_type_wd, --��������
                          av_brchid, --��������(�����/�̻��ŵ�)
                          av_operid, --������Ա/�ն˺�
                          av_trbatchno, --�������κ�
                          av_termtrno, --�ն˽�����ˮ��
                          SYSDATE, --����ʱ��
                          '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                          av_actionno, --ҵ����ˮ��
                          av_note, --��ע
                          lv_clrdate, --�������
                          NULL,--��������
                          av_debug, --1����
                          av_res, --������������
                          av_msg --��������������Ϣ
                          );
  END p_generate;

  /*=======================================================================================*/
  --������������ (ֻ���»��ֹ��ɱ��˻�����ˮ������ͳһ����)
  /*=======================================================================================*/
  PROCEDURE p_generatecancel(av_cardno  IN VARCHAR2, --����
                             av_amt     IN NUMBER, --����
                             av_clrdate IN VARCHAR2, --�������
                             av_res     OUT VARCHAR2, --��������
                             av_msg     OUT VARCHAR2 --����������Ϣ
                             ) IS
    lv_count        NUMBER;
    lv_tablename    VARCHAR2(50);
    lv_crsubledger  acc_account_sub%ROWTYPE; --�����ֻ���
    lv_clrdate      pay_clr_para.clr_date%TYPE; --�������
    lv_period_name  VARCHAR2(20); --����˵������2014-01-01(��)��2014-01(��)��2014(��)
    lv_invalid_date VARCHAR2(20); --����ʧЧ����
  BEGIN
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    --ȡ���ֵļ������ں�ʧЧ����
    p_getpointsperiod(lv_clrdate, --�������
                      lv_period_name, --����˵������2014-01-01(��)��2014-01(��)��2014(��)
                      lv_invalid_date, --����ʧЧ����
                      av_res, --��������
                      av_msg --����������Ϣ
                      );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --ȡ�����ֻ���
    pk_public.p_getsubledgerbycardno(av_cardno, --����
                                     pk_public.cs_acckind_jf, --�˻�����
                                     pk_public.cs_defaultwalletid, --Ǯ�����
                                     lv_crsubledger, --�ֻ���
                                     av_res, --������������
                                     av_msg --��������������Ϣ
                                     );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --
    lv_tablename := pk_public.f_getpointsperiodbycard_no(av_cardno);
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || lv_tablename ||
                      ' WHERE card_no = :1 AND period_name = :2'
      INTO lv_count
      USING av_cardno, lv_period_name;
    IF lv_count = 0 THEN
      av_res := pk_public.cs_res_dberr;
      av_msg := '�����쳣�����ֹ��ɱ����ҵ������ڵĻ���';
      RETURN;
    ELSE
      EXECUTE IMMEDIATE 'UPDATE ' || lv_tablename ||
                        ' SET points_tot = points_tot - :1 WHERE card_no = :2 AND period_name = :3 and points_tot >= points_used + :4'
        USING av_amt, av_cardno, lv_period_name, av_amt;
      IF SQL%ROWCOUNT = 0 THEN
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '��������';
        RETURN;
      END IF;
    END IF;
  END p_generatecancel;
BEGIN
  -- initialization
  NULL;
END pk_points;
/

