CREATE OR REPLACE PACKAGE BODY pk_merchantsettle IS
  --���ѽ�������401001 �� 402001��ͷ

  /*=======================================================================================*/
  --������ֿ�ʼ�������ڽ���
  /*=======================================================================================*/
  PROCEDURE p_settle(av_stlmode   stl_mode%ROWTYPE, --����ģʽ��
                     av_merchant  IN base_merchant%ROWTYPE, --�̻�
                     av_operid    IN sys_users.user_id%TYPE, --��Ա���
                     av_begindate IN pay_clr_sum.clr_date%TYPE, --��ֿ�ʼ����
                     av_enddate   IN pay_clr_sum.clr_date%TYPE, --��ֽ�������
                     av_type      IN VARCHAR2, --1:--ȫ������ 21:ȫ�������� ���� 22:ȫ�������� �˻� 23:ȫ�������� ������ 31:�����˻����������Ѳ����� �����˻� 32:�����˻����������Ѳ����� ������ 41:���������������˻������� ���������� 42:���������������˻������� �˻�
                     av_res       OUT VARCHAR2, --��������
                     av_msg       OUT VARCHAR2, --����������Ϣ
                     av_jsrq      IN VARCHAR2 DEFAULT NULL --�������� ��ʱ����ʱȡ��ǰ������ڣ�������nullȡ����������һ��
                     ) IS
    ls_jsrq         CHAR(10) := NULL;
    lv_stlsumno     stl_deal_sum.stl_sum_no%TYPE; --�������
    lv_feerate      pay_fee_rate%ROWTYPE; --����
    lv_stltradelist stl_deal_list%ROWTYPE; --������ϸ
    lv_operid       sys_users.user_id%TYPE;
    --�������Ѳ���������ֳ�
    PROCEDURE p_setfee(as_trcode stl_deal_list.deal_code%TYPE) IS
      ln_jgfc  NUMBER;
      ln_count NUMBER;
      --in_fdamt NUMBER := 0;
      --in_fee_rate number := 0;
    BEGIN
      --��ȡ����
      SELECT *
        INTO lv_feerate
        FROM pay_fee_rate t
       WHERE t.merchant_id = av_merchant.merchant_id
         AND t.deal_code = as_trcode
         AND t.fee_state = '0'
         AND begindate =
             (SELECT MAX(begindate)
                FROM pay_fee_rate
               WHERE merchant_id = av_merchant.merchant_id
                 AND deal_code = as_trcode
                 AND fee_state = '0'
                 AND begindate <= to_date(av_enddate, 'yyyy-mm-dd'));
      lv_stltradelist.fee_rate_id := lv_feerate.fee_rate_id;
      lv_stltradelist.in_out      := lv_feerate.in_out;
      --��������1��������2������3�̶������ fee_rate  ���ʣ�ͳһ��10000
      IF lv_feerate.fee_type = '1' THEN
        --������ڰ������ֶ���ȡ�����
        /*SELECT COUNT(*)
          INTO in_fdamt
          FROM clr_fee_rate_section t
         WHERE t.fee_rate_id = lv_feerate.fee_rate_id;*/
        lv_stltradelist.fee_amt := 0;
        IF lv_feerate.have_section = 0 THEN
          DECLARE
            TYPE ln_list IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
            ln_section ln_list;
            ln_feerate ln_list;
          BEGIN
            SELECT t.section_num, t.fee_rate BULK COLLECT
              INTO ln_section, ln_feerate
              FROM pay_fee_rate_section t
             WHERE t.fee_rate_id = lv_feerate.fee_rate_id
             ORDER BY section_num;
            ln_section(ln_section.count + 1) := 999999999999999;
            FOR i IN 1 .. ln_section.count - 1 LOOP
              IF lv_stltradelist.deal_num >= ln_section(i + 1) THEN
                lv_stltradelist.fee_amt := lv_stltradelist.fee_amt +
                                           (ln_section(i + 1) -
                                           ln_section(i)) * ln_feerate(i) /
                                           10000;
              ELSE
                lv_stltradelist.fee_amt := lv_stltradelist.fee_amt +
                                           greatest(0,(1+lv_stltradelist.deal_num -
                                           ln_section(i))) * ln_feerate(i) /
                                           10000;
                EXIT;
              END IF;
            END LOOP;
          END;
        ELSE
          lv_stltradelist.fee_amt := (lv_stltradelist.deal_num *
                                     lv_feerate.fee_rate )/ 10000;
        END IF;
        --�����������ֶ���ȡ�����

      ELSIF lv_feerate.fee_type = '2' THEN
        --������ڰ����ֶ���ȡ������
        lv_stltradelist.fee_amt := 0;
        IF lv_feerate.have_section = 0 THEN
          DECLARE
            TYPE ln_list IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
            ln_section ln_list;
            ln_feerate ln_list;
          BEGIN
            SELECT t.section_num, t.fee_rate BULK COLLECT
              INTO ln_section, ln_feerate
              FROM pay_fee_rate_section t
             WHERE t.fee_rate_id = lv_feerate.fee_rate_id
             ORDER BY section_num;
            ln_section(ln_section.count + 1) := 999999999999999;
            FOR i IN 1 .. ln_section.count - 1 LOOP
              IF lv_stltradelist.deal_amt > ln_section(i + 1) THEN
                lv_stltradelist.fee_amt := lv_stltradelist.fee_amt +
                                           (ln_section(i + 1) -
                                           ln_section(i)) * ln_feerate(i) /
                                           10000;
              ELSE
                lv_stltradelist.fee_amt := lv_stltradelist.fee_amt +
                                           greatest(0,(abs(lv_stltradelist.deal_amt) -
                                           ln_section(i))) * ln_feerate(i) /
                                           10000;
                EXIT;
              END IF;
            END LOOP;
          END;
        ELSE
          lv_stltradelist.fee_amt := (abs(lv_stltradelist.deal_amt) *
                                     lv_feerate.fee_rate) / 10000;
        END IF;
        --���������ֶ���ȡ������
      ELSIF lv_feerate.fee_type = '3' THEN
        lv_stltradelist.fee_amt := lv_feerate.fee_rate / 10000; --�̶�����ֱ��ȡ
      ELSE
        lv_stltradelist.fee_amt := 0;
      END IF;
      /*
      -- �������
      lv_stltradelist.fee_amt := least(lv_stltradelist.fee_amt,
                                         lv_feerate.fee_max);
      -- ��С�����
      lv_stltradelist.fee_amt := greatest(lv_stltradelist.fee_amt,
                                            lv_feerate.fee_min);
      */
      IF lv_feerate.in_out = '1' THEN
        lv_stltradelist.fee_amt := -abs(lv_stltradelist.fee_amt);
      END IF;
     /* IF   lv_stltradelist.deal_code = '40201051' or lv_stltradelist.deal_code = '40101051' THEN
        lv_stltradelist.deal_amt := -lv_stltradelist.deal_amt;
      END IF;*/
      --��������ֳ�
      SELECT COUNT(*)
        INTO ln_count
        FROM pay_divide_rate_detail
       WHERE div_id = av_merchant.div_id
         AND card_type = lv_stltradelist.card_type;
      --and div_state = '0';
      INSERT INTO stl_deal_list_div
        (stl_sum_no,
         list_no,
         merchant_id,
         deal_code,
         card_type,
         acc_kind, --
         fee_amt,
         fee_stl_date,
         oper_date,
         org_id,
         div_id,
         div_type,
         clr_fixed,
         clr_percent,
         div_fee)
        SELECT lv_stltradelist.stl_sum_no,
               lv_stltradelist.list_no,
               av_merchant.merchant_id,
               lv_stltradelist.deal_code,
               lv_stltradelist.card_type,
               lv_stltradelist.acc_kind,
               lv_stltradelist.fee_amt,
               NULL,
               SYSDATE,
               t.org_id,
               div_id,
               div_type,
               clr_fixed,
               clr_percent,
               decode(div_type,
                      '0',
                      clr_percent * lv_stltradelist.fee_amt,
                      '1',
                      clr_fixed,
                      0)
          FROM pay_divide_rate_detail t
         WHERE div_id = av_merchant.div_id
           AND (ln_count = 0 AND card_type = '0' OR
               card_type = lv_stltradelist.card_type);
      --��д������ϸ�еķ���ѣ���ֹ��һ��
      SELECT SUM(div_fee)
        INTO ln_jgfc
        FROM stl_deal_list_div
       WHERE list_no = lv_stltradelist.list_no;
      IF lv_stltradelist.fee_amt <> ln_jgfc THEN
        UPDATE stl_deal_list_div
           SET div_fee = div_fee - (ln_jgfc - lv_stltradelist.fee_amt)
         WHERE list_no = lv_stltradelist.list_no
           AND rownum < 2;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        lv_stltradelist.fee_rate_id := '-1';
        IF  lv_stltradelist.deal_code = '40201051' or lv_stltradelist.deal_code = '40201051'  THEN
          --�˻�
          lv_stltradelist.in_out := '1';
          lv_stltradelist.fee_amt:= 0;
          /*lv_stltradelist.deal_amt := -lv_stltradelist.deal_amt;*/
          lv_stltradelist.deal_amt := lv_stltradelist.deal_amt;
        ELSE
          lv_stltradelist.in_out := '0';
        END IF;
      WHEN OTHERS THEN
        av_res := -1;
        av_msg := nvl(av_msg, '�������ѷ�������:') || SQLERRM;
    END p_setfee;


  BEGIN
    ls_jsrq := nvl(av_jsrq,
                   to_char(to_date(av_enddate, 'yyyy-mm-dd') + 1,
                           'yyyy-mm-dd'));
    IF av_operid IS NULL THEN
      lv_operid := pk_public.f_getorgoperid(av_merchant.org_id);
    ELSE
      lv_operid := av_operid;
    END IF;
    --��ȡ�������
    SELECT seq_stl_sum_no.nextval INTO lv_stlsumno FROM dual;
    --1:--ȫ������ 21:ȫ�������� ���� 22:ȫ�������� �˻� 23:ȫ�������� ������ 31:�����˻����������Ѳ����� �����˻� 32:�����˻����������Ѳ����� ������ 41:���������������˻������� ���������� 42:���������������˻������� �˻�
    IF av_type IN ('1', '21', '31', '41') THEN
      --����
      UPDATE pay_clr_sum
         SET stl_date = ls_jsrq, stl_flag = '0', stl_sum_no = lv_stlsumno
       WHERE merchant_id = av_merchant.merchant_id
         AND to_date(clr_date, 'yyyy-mm-dd') >=
             to_date(av_begindate, 'yyyy-mm-dd')
         AND to_date(clr_date, 'yyyy-mm-dd') <=
             to_date(av_enddate, 'yyyy-mm-dd')
         AND ( deal_code = '40201010' or deal_code = '40101010' or deal_code = '40201051')
         AND stl_sum_no IS NULL;
    END IF;
    IF av_type IN ('1', '22', '31', '42') THEN
      --�˻�
      UPDATE pay_clr_sum
         SET stl_date = ls_jsrq, stl_flag = '0', stl_sum_no = lv_stlsumno
       WHERE merchant_id = av_merchant.merchant_id
         AND to_date(clr_date, 'yyyy-mm-dd') >=
             to_date(av_begindate, 'yyyy-mm-dd')
         AND to_date(clr_date, 'yyyy-mm-dd') <=
             to_date(av_enddate, 'yyyy-mm-dd')
         AND (deal_code = '40201051' OR deal_code = '40101051' )
         AND stl_sum_no IS NULL;
    END IF;
    IF av_type IN ('1', '23', '32', '41') THEN
      --������
      UPDATE pay_clr_sum
         SET fee_stl_date   = ls_jsrq,
             fee_stl_flag   = '0',
             fee_stl_sum_no = lv_stlsumno
       WHERE merchant_id = av_merchant.merchant_id
         AND to_date(clr_date, 'yyyy-mm-dd') >=
             to_date(av_begindate, 'yyyy-mm-dd')
         AND to_date(clr_date, 'yyyy-mm-dd') <=
             to_date(av_enddate, 'yyyy-mm-dd')
         AND fee_stl_sum_no IS NULL;
    END IF;
    IF SQL%ROWCOUNT = 0 THEN
      av_res := 0;
      --return;
    END IF;
    FOR lrec_clr IN (SELECT merchant_id,
                            deal_code,
                            card_type,
                            acc_kind,
                            SUM(deal_num) AS deal_num,
                            SUM(deal_amt) AS deal_amt
                       FROM pay_clr_sum
                      WHERE stl_sum_no = lv_stlsumno
                         OR fee_stl_sum_no = lv_stlsumno
                      GROUP BY merchant_id, deal_code, card_type, acc_kind) LOOP
      --������ϸ
      SELECT seq_list_no.nextval INTO lv_stltradelist.list_no FROM dual;
      lv_stltradelist.stl_sum_no := lv_stlsumno; --stl_sum_no  ����������
      lv_stltradelist.deal_code    := lrec_clr.deal_code; --tr_code  ���״���
      lv_stltradelist.card_type  := lrec_clr.card_type; --������
      lv_stltradelist.acc_kind   := lrec_clr.acc_kind; --�˻�����
      lv_stltradelist.oth_fee    := 0;
      lv_stltradelist.deal_num     := lrec_clr.deal_num;
      lv_stltradelist.deal_amt     := lrec_clr.deal_amt;
      IF av_type IN ('1', '23', '32', '41') THEN
        p_setfee(lrec_clr.deal_code); --�������Ѻͷ��ʴ��롢��֧��־
      ELSE
        p_setfee(lrec_clr.deal_code); --�������Ѻͷ��ʴ��롢��֧��־
      END IF;
      IF av_type IN ('23', '32') THEN
        lv_stltradelist.deal_num := 0;
        lv_stltradelist.deal_amt := '0';
      END IF;
      INSERT INTO stl_deal_list VALUES lv_stltradelist;
    END LOOP;
    --��������������
    INSERT INTO stl_deal_sum
      (stl_sum_no, --�������
       stl_date, --��������
       merchant_id, --�̻�����
       merchant_name, --�̻�����
       stl_days, --��������
       --stl_times, --�������
       deal_num, --�ܱ���
       deal_amt, --�ܽ��
       deal_fee, --�����
       stl_amt, --������
       --stl_p_amt, --�Ѹ�����
       chk_date, --��������
       chk_user_id, --������
       vrf_date, --����ȷ������
       vrf_user_id, --����ȷ����
       reg_no, --�ص�������
       --inv_flag, --�Ƿ��ѿ�Ʊ(0-�� 1-��)
       --inv_bat_no, --��Ʊ����
       user_id, --���ɹ�Ա
       oper_date, --��������
       stl_state, --����״̬(0-������ 1-�Ѷ��� 2-����ȷ�� 3-�Ѵ�� 4 �����ȷ��)
       note, --��ע
       --card_org_id, --��������
       th_num,
       th_amt, --�˻����
       card_type, --������
       acc_kind, --�˻�����
       begin_date, --��ʼ����
       end_date,
       stl_mode,
       stl_way)
      SELECT lv_stlsumno, --�������
             ls_jsrq, --��������
             av_merchant.merchant_id, --�̻�����
             av_merchant.merchant_name, --�̻�����
             0, --��������
             --1, --�������
             nvl(SUM(deal_num), 0), --�ܱ���
             CASE
               WHEN av_type = '41' THEN
                --nvl(SUM(decode(substrb(deal_code, 1, 3), '811', 0, deal_amt)), 0) --�ܽ��
                nvl(sum(decode(deal_code,'40201051',0,'40101051',0,deal_amt)),0) --�ܽ��
               ELSE
                nvl(SUM(deal_amt), 0)
             END tramt,
             nvl(SUM(fee_amt), 0),
             CASE
               WHEN av_type = '41' THEN
                --nvl(SUM(decode(substrb(deal_code, 1, 3), '811', 0, deal_amt)), 0) -
                --nvl(SUM(fee_amt), 0)
                nvl(sum(decode(deal_code,'40201051',0,'40101051',0,deal_amt)),0)-
                nvl(sum(fee_amt),0)
               ELSE
                nvl(SUM(deal_amt), 0) - nvl(SUM(fee_amt), 0)
             END stl_amt, --nvl(sum(decode(tr_code, '2834', -1, 1) * (nvl(tr_amt, 0) - nvl(fee_amt, 0))),0), --������
             --0, --�Ѹ�����
             NULL, --��������
             NULL, --������
             NULL, --����ȷ������
             NULL, --����ȷ����
             NULL, --�ص�������
             --'1', --�Ƿ��ѿ�Ʊ(0-�� 1-��)
             --null, --��Ʊ����
             lv_operid, --���ɹ�Ա
             SYSDATE, --��������
             '0', --����״̬
             NULL, --��ע
             --'1001', --��������
             nvl(SUM(decode(in_out, '1', deal_num, 0)), 0),
             nvl(SUM(decode(in_out, '1', deal_amt, 0)), 0),
             card_type, --������
             acc_kind, --�˻�����
             av_begindate, --��ʼ����
             av_enddate, --��������
             av_stlmode.stl_mode,
             av_stlmode.stl_way
        FROM stl_deal_list
       WHERE stl_sum_no = lv_stlsumno
       GROUP BY card_type, acc_kind;
       UPDATE stl_deal_sum t SET t.tot_deal_num = nvl(t.deal_num,0) +nvl(t.th_num,0),
              t.tot_deal_amt = nvl(t.deal_amt,0)-nvl(t.deal_fee,0) WHERE t.stl_sum_no = lv_stlsumno;
       UPDATE stl_deal_sum t SET t.begin_date =(SELECT MIN(t1.clr_date) from pay_clr_sum t1 WHERE t1.stl_sum_no = lv_stlsumno),
         t.end_date =(SELECT MAX(t1.clr_date) from pay_clr_sum t1 WHERE t1.stl_sum_no = lv_stlsumno) WHERE t.stl_sum_no = lv_stlsumno;
    av_res := 0;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := -1;
      av_msg := nvl(av_msg, '�̻����㷢������:') || SQLERRM;
  END p_settle;

  /*=======================================================================================*/
  --��һ�̻����н���
  /*=======================================================================================*/
  PROCEDURE p_settle(av_bizid  IN base_merchant.merchant_id%TYPE, --�̻���
                     av_operid IN sys_users.user_id%TYPE, --�����Ա
                     av_res    OUT VARCHAR2, --��������
                     av_msg    OUT VARCHAR2 --����������Ϣ
                     ) IS
    lv_merchant  base_merchant%ROWTYPE; --�̻���Ϣ
    lv_begindate VARCHAR2(10) := NULL; --��ֿ�ʼ����
    lv_enddate   VARCHAR2(10) := NULL; --��ֽ�������
    lv_sum       NUMBER;
    lv_stlmode   stl_mode%ROWTYPE; --����ģʽ��
    lv_operid    sys_users.user_id%TYPE;
    --ȡ����ģʽ
    FUNCTION f_getstlmode(as_clrdate VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      SELECT *
        INTO lv_stlmode
        FROM stl_mode
       WHERE merchant_id = lv_merchant.merchant_id
         AND valid_date =
             (SELECT MAX(valid_date)
                FROM stl_mode
               WHERE merchant_id = lv_merchant.merchant_id
                 AND valid_date <= to_date(as_clrdate, 'yyyy-mm-dd'));
      RETURN '1';
    EXCEPTION
      WHEN no_data_found THEN
        RETURN '0';
    END f_getstlmode;
    --ȡδ������
    FUNCTION f_getsum(av_type      VARCHAR2,
                      av_begindate VARCHAR2,
                      av_enddate   VARCHAR2) RETURN NUMBER IS
    BEGIN
      IF av_type = '1' THEN
        --ȫ������
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE merchant_id = lv_merchant.merchant_id
           AND (stl_sum_no IS NULL OR fee_stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '21' THEN
        --ȫ�������� ����
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate
           AND deal_code IN ('40101010','40201010') ; --����
      ELSIF av_type = '22' THEN
        --ȫ�������� �˻�
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate
           AND deal_code IN ('40102051','40201051') ; --�˻�
      ELSIF av_type = '23' THEN
        --ȫ�������� ������
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (fee_stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '31' THEN
        --�����˻����������Ѳ����� �����˻�
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '32' THEN
        --�����˻����������Ѳ����� ������
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (fee_stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '41' THEN
        --���������������˻������� ����������
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate
           AND deal_code IN ('40101010','40201010');
      ELSIF av_type = '42' THEN
        --���������������˻������� �˻�
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate
           AND deal_code IN ('40102051','40201051');
      END IF;
      RETURN lv_sum;
    END f_getsum;
    --�ж��Ƿ񵽴�������� �޶��ʱ��ȡlv_sum�ٵ���
    FUNCTION f_canstl(as_clrdate     VARCHAR2,
                      as_lastclrdate VARCHAR2,
                      as_stlway      VARCHAR2,
                      as_stldays     VARCHAR2,
                      an_limit       NUMBER) RETURN VARCHAR2 IS
      ls_days  pk_public.myarray;
      ln_count NUMBER;
    BEGIN
      --���ѽ��㷽ʽ01-�ս� 02-�޶�� 03-�ܽ� 04 �½�05�ս�+�½� 06�޶��+�½�
      IF as_stlway IN ('01', '05') THEN
        --�սᡢ�ս�+�½�
        ln_count := (to_date(as_clrdate, 'yyyy-mm-dd') -
                    to_date(as_lastclrdate, 'yyyy-mm-dd')) MOD as_stldays;
        IF ln_count = 0 THEN
          RETURN '1';
        END IF;
        IF as_stlway = '05' THEN
          IF to_date(as_clrdate, 'yyyy-mm-dd') =
             last_day(to_date(as_clrdate, 'yyyy-mm-dd')) THEN
            RETURN '1';
          END IF;
        END IF;
      ELSIF as_stlway IN ('02', '06') THEN
        --�޶��
        IF lv_sum >= an_limit THEN
          RETURN '1';
        END IF;
        IF as_stlway = '06' THEN
          IF to_date(as_clrdate, 'yyyy-mm-dd') =
             last_day(to_date(as_clrdate, 'yyyy-mm-dd')) THEN
            RETURN '1';
          END IF;
        END IF;
      ELSIF as_stlway = '03' THEN
        --�ܽ�
        ln_count := pk_public.f_splitstr(as_stldays, '|', ls_days);
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
      ELSIF as_stlway = '04' THEN
        --�½�
        ln_count := pk_public.f_splitstr(as_stldays, '|', ls_days);
        FOR i IN 1 .. ln_count LOOP
          IF to_number(substr(as_clrdate, 9, 2)) = to_number(ls_days(i)) --������ͬ
             OR ls_days(i) = 32 AND --�������µ׽��㲢�����µ�
             to_date(as_clrdate, 'yyyy-mm-dd') =
             last_day(to_date(as_clrdate, 'yyyy-mm-dd')) THEN
            RETURN '1';
          END IF;
        END LOOP;
      ELSIF as_stlway = '07' THEN
        --����
        IF substrb(as_clrdate, 6, 5) IN
           ('03-31', '06-30', '09-30', '12-31') THEN
          RETURN '1';
        END IF;
      END IF;
      --û����������
      RETURN '0';
    END f_canstl;
    FUNCTION p_getmindate(date1 VARCHAR2,
                          date2 VARCHAR2 DEFAULT NULL,
                          date3 VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
      out_date VARCHAR2(50);
    BEGIN
      IF date1 IS NULL AND date2 IS NULL AND date3 IS NULL THEN
        RETURN NULL;
      END IF;
      out_date := least(nvl(date1, '2999-01-01'),
                        nvl(date2, '2999-01-01'),
                        nvl(date3, '2999-01-01'));
      RETURN out_date;
    END p_getmindate;
    --ȡ���㿪ʼ����
    PROCEDURE p_setbegindate(trcode VARCHAR2) IS
      xf  VARCHAR2(50);
      th  VARCHAR2(50);
      sxf VARCHAR(50);
    BEGIN
      IF lv_begindate IS NULL THEN
        --ȡ��һ�ν������� �� lv_begindate
        IF trcode = 1 THEN
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO xf
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND stl_sum_no IS NOT NULL
             AND deal_code IN ('40101010','40201010');
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO th
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND stl_sum_no IS NOT NULL
             AND deal_code IN ('40102051','40201051');
          SELECT MAX(to_char(to_date(fee_stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO sxf
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND fee_stl_sum_no IS NOT NULL;
             
          /*SELECT MIN(to_char(to_date(clr_Date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO xf
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND stl_sum_no IS  NULL
             AND deal_code IN ('40101010','40201010');
          SELECT MIN(to_char(to_date(clr_Date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO th
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND stl_sum_no IS  NULL
             AND deal_code IN ('40102051','40201051');
          SELECT MIN(to_char(to_date(clr_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO sxf
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND fee_stl_sum_no IS  NULL;*/
          lv_begindate := p_getmindate(xf, th, sxf);
        END IF;
        IF trcode = 21 THEN
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO xf
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND stl_sum_no IS NOT NULL
             AND deal_code IN ('40101010','40201010');
          lv_begindate := p_getmindate(xf);
        END IF;
        IF trcode = 22 THEN
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO th
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND stl_sum_no IS NOT NULL
             AND deal_code IN ('40102051','40201051');
          lv_begindate := p_getmindate(th, NULL, NULL);
        END IF;
        IF trcode = 23 THEN
          SELECT MAX(to_char(to_date(fee_stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO sxf
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND fee_stl_sum_no IS NOT NULL;
          lv_begindate := p_getmindate(sxf, NULL, NULL);
        END IF;
        IF trcode = 31 THEN
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO xf
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND stl_sum_no IS NOT NULL
             AND deal_code IN ('40101010','40201010');
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO th
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND stl_sum_no IS NOT NULL
             AND deal_code IN ('40102051','40201051');
          lv_begindate := p_getmindate(xf, th, NULL);
        END IF;
        IF trcode = 32 THEN
          SELECT MAX(to_char(to_date(fee_stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO sxf
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND fee_stl_sum_no IS NOT NULL;
          lv_begindate := p_getmindate(sxf, NULL, NULL);
        END IF;
        IF trcode = 41 THEN
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO xf
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND stl_sum_no IS NOT NULL
             AND deal_code IN ('40101010','40201010');
          SELECT MAX(to_char(to_date(fee_stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO sxf
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND fee_stl_sum_no IS NOT NULL;
          lv_begindate := p_getmindate(xf, sxf, NULL);
        END IF;
        IF trcode = 42 THEN
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO th
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid
             AND stl_sum_no IS NOT NULL
             AND deal_code IN ('40102051','40201051');
          lv_begindate := p_getmindate(th, NULL, NULL);
        END IF;
        -- select to_char(to_date(max(stl_date), 'yyyy-mm-dd'), 'yyyy-mm-dd') into lv_begindate from stl_trade_sum where biz_id = av_bizid;
        IF lv_begindate IS NULL THEN
          SELECT MIN(clr_date)
            INTO lv_begindate
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid;
        END IF;
      ELSE
        SELECT to_char(to_date(lv_enddate, 'yyyy-mm-dd') + 1, 'yyyy-mm-dd')
          INTO lv_begindate
          FROM dual;
      END IF;
    END p_setbegindate;
    --ȡ��һ�����㿪ʼ��������
    PROCEDURE p_setnextbeginenddate IS
      ls_days  pk_public.myarray;
      ln_count NUMBER;
    BEGIN
      --��ʼ����
      IF lv_begindate IS NULL THEN
        --ȡ��һ�ν������� �� lv_begindate
        SELECT to_char(to_date(MAX(stl_date), 'yyyy-mm-dd'), 'yyyy-mm-dd')
          INTO lv_begindate
          FROM stl_deal_sum
         WHERE merchant_id = av_bizid;

        IF lv_begindate IS NULL THEN
          SELECT MIN(clr_date)
            INTO lv_begindate
            FROM pay_clr_sum
           WHERE merchant_id = av_bizid;
        END IF;
      ELSE
        SELECT to_char(to_date(lv_enddate, 'yyyy-mm-dd') + 1, 'yyyy-mm-dd')
          INTO lv_begindate
          FROM dual;
      END IF;
      --��������
      IF lv_begindate IS NOT NULL THEN
        IF lv_stlmode.stl_way IN ('02', '06') THEN
          --�޶�ᡢ�޶��+�½�
          lv_enddate := lv_begindate;
          WHILE lv_enddate < to_char(1 + SYSDATE, 'yyyy-mm-dd') LOOP
            /*select sum(decode(t2.fee_flag, '1', -tr_amt, tr_amt))
             into lv_sum
             from clr_trade_sum t1, clr_fee_rate_section t2
            where t1.biz_id = t2.biz_id
              and t2.fee_state = '0'
              and t1.tr_code = t2.tr_code
              and t1.biz_id = lv_merchant.biz_id
              and t1.clr_date >= lv_begindate
              and t1.clr_date <= lv_enddate
              and t1.stl_sum_no is null;*/
            /*if lv_sum >= to_number(lv_merchant.stl_limit) then
              return;
            end if;*/
            IF lv_stlmode.stl_way = '06' THEN
              --�޶��+�½�
              IF lv_enddate =
                 to_char(last_day(to_date(lv_begindate, 'yyyy-mm-dd')),
                         'yyyy-mm-dd') THEN
                --���µף�����
                RETURN;
              END IF;
            END IF;
            lv_enddate := to_char(to_date(lv_enddate, 'yyyy-mm-dd') + 1,
                                  'yyyy-mm-dd');
          END LOOP;
        ELSIF lv_stlmode.stl_way = '03' THEN
          --�ܽ� lv_merchant.stl_days 1-7
          ln_count   := pk_public.f_splitstr(lv_stlmode.stl_way,
                                             '|',
                                             ls_days);
          lv_enddate := lv_begindate;
          WHILE lv_enddate < to_char(1 + SYSDATE, 'yyyy-mm-dd') LOOP
            FOR i IN 1 .. ln_count LOOP
              IF to_char(to_date(lv_enddate, 'yyyy-mm-dd'), 'd') - 1 =
                 CASE ls_days(i)
                   WHEN '7' THEN
                    '0'
                   ELSE
                    ls_days(i)
                 END THEN
                RETURN;
              END IF;
            END LOOP;
            lv_enddate := to_char(to_date(lv_enddate, 'yyyy-mm-dd') + 1,
                                  'yyyy-mm-dd');
          END LOOP;
        ELSIF lv_stlmode.stl_way = '04' THEN
          --�½�
          ln_count   := pk_public.f_splitstr(lv_stlmode.stl_way,
                                             '|',
                                             ls_days);
          lv_enddate := lv_begindate;
          WHILE lv_enddate < to_char(1 + SYSDATE, 'yyyy-mm-dd') LOOP
            FOR i IN 1 .. ln_count LOOP
              IF to_number(substr(lv_enddate, 9, 2)) =
                 to_number(ls_days(i)) --������ͬ
                 OR ls_days(i) = 32 AND --�������µ׽��㲢�����µ�
                 to_date(lv_enddate, 'yyyy-mm-dd') =
                 last_day(to_date(lv_enddate, 'yyyy-mm-dd')) THEN
                RETURN;
              END IF;
            END LOOP;
            lv_enddate := to_char(to_date(lv_enddate, 'yyyy-mm-dd') + 1,
                                  'yyyy-mm-dd');
          END LOOP;

        ELSIF lv_stlmode.stl_way = '05' THEN
          --�ս�+�½�
          SELECT to_char(least(to_date(lv_begindate, 'yyyy-mm-dd') +
                               lv_stlmode.stl_way - 1,
                               last_day(to_date(lv_begindate, 'yyyy-mm-dd'))),
                         'yyyy-mm-dd')
            INTO lv_enddate
            FROM dual;
        ELSE
          -- lv_merchant.stl_way = '01' then
          --�����������ս�
          SELECT to_char(to_date(lv_begindate, 'yyyy-mm-dd') +
                         lv_stlmode.stl_way - 1,
                         'yyyy-mm-dd')
            INTO lv_enddate
            FROM dual;
        END IF;
      END IF;
    END p_setnextbeginenddate;
  BEGIN
    SELECT * INTO lv_merchant FROM base_merchant WHERE merchant_id = av_bizid;
    IF av_operid IS NULL THEN
      lv_operid := pk_public.f_getorgoperid(lv_merchant.org_id);
    ELSE
      lv_operid := av_operid;
    END IF;
    --p_setnextbeginenddate;
    p_setbegindate(1);
    IF lv_begindate IS NOT NULL THEN
      --ѭ�����ɽ�������
      lv_enddate := to_char(to_date(lv_begindate, 'yyyy-mm-dd') + 0,
                            'yyyy-mm-dd');
      WHILE lv_enddate < to_char(SYSDATE, 'yyyy-mm-dd') LOOP
        --ȡ����Ľ���ģʽ
        IF f_getstlmode(lv_enddate) = '1' THEN
          --���ݽ���ģʽ�ж��Ƿ񵽴��������
          -- 1ȫ������2ȫ��������3�����˻����������Ѳ�����4���������������˻�������
          IF lv_stlmode.stl_mode = '1' THEN
            lv_begindate := NULL;
            p_setbegindate(1);
            --1ȫ������
            IF lv_stlmode.stl_way IN ('02', '06') THEN
              --�޶�
              lv_sum := f_getsum('1', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way,
                        lv_stlmode.stl_days,
                        lv_sum) = '1' THEN
              --�ﵽ��������
              p_settle(lv_stlmode,
                       lv_merchant, --�̻���
                       lv_operid, --�����Ա
                       lv_begindate, --��ֿ�ʼ����
                       lv_enddate, --��ֽ�������
                       '1',
                       av_res, --������� 0��ʾ��ȷ
                       av_msg --����ԭ��
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
          ELSIF lv_stlmode.stl_mode = '2' THEN
            --2ȫ��������
            --2.1����
            lv_begindate := NULL;
            p_setbegindate(21);
            IF lv_stlmode.stl_way IN ('02', '06') THEN
              --�޶�
              lv_sum := f_getsum('21', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way,
                        lv_stlmode.stl_days,
                        lv_sum) = '1' THEN
              --�ﵽ��������
              p_settle(lv_stlmode,
                       lv_merchant, --�̻���
                       lv_operid, --�����Ա
                       lv_begindate, --��ֿ�ʼ����
                       lv_enddate, --��ֽ�������
                       '21',
                       av_res, --������� 0��ʾ��ȷ
                       av_msg --����ԭ��
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
            --2.2�˻�
            lv_begindate := NULL;
            p_setbegindate(22);
            IF lv_stlmode.stl_way_ret IN ('02', '06') THEN
              --�޶�
              lv_sum := f_getsum('22', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way_ret,
                        lv_stlmode.stl_way_ret,
                        lv_sum) = '1' THEN
              --�ﵽ��������
              p_settle(lv_stlmode,
                       lv_merchant, --�̻���
                       lv_operid, --�����Ա
                       lv_begindate, --��ֿ�ʼ����
                       lv_enddate, --��ֽ�������
                       '22',
                       av_res, --������� 0��ʾ��ȷ
                       av_msg --����ԭ��
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
            --2.3������
            lv_begindate := NULL;
            p_setbegindate(23);
            IF lv_stlmode.stl_way_fee IN ('02', '06') THEN
              --�޶�
              lv_sum := f_getsum('23', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way_fee,
                        lv_stlmode.stl_way_fee,
                        lv_sum) = '1' THEN
              p_settle(lv_stlmode,
                       lv_merchant, --�̻���
                       lv_operid, --�����Ա
                       lv_begindate, --��ֿ�ʼ����
                       lv_enddate, --��ֽ�������
                       '23',
                       av_res, --������� 0��ʾ��ȷ
                       av_msg --����ԭ��
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
          ELSIF lv_stlmode.stl_mode = '3' THEN
            --3�����˻����������Ѳ�����
            --3.1�����˻�
            lv_begindate := NULL;
            p_setbegindate(31);
            IF lv_stlmode.stl_way IN ('02', '06') THEN
              --�޶�
              lv_sum := f_getsum('31', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way,
                        lv_stlmode.stl_days,
                        lv_sum) = '1' THEN
              --�ﵽ��������
              p_settle(lv_stlmode,
                       lv_merchant, --�̻���
                       lv_operid, --�����Ա
                       lv_begindate, --��ֿ�ʼ����
                       lv_enddate, --��ֽ�������
                       '31',
                       av_res, --������� 0��ʾ��ȷ
                       av_msg --����ԭ��
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
            --3.2������
            lv_begindate := NULL;
            p_setbegindate(32);
            IF lv_stlmode.stl_way_fee IN ('02', '06') THEN
              --�޶�
              lv_sum := f_getsum('32', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way_fee,
                        lv_stlmode.stl_days_fee,
                        lv_sum) = '1' THEN
              p_settle(lv_stlmode,
                       lv_merchant, --�̻���
                       lv_operid, --�����Ա
                       lv_begindate, --��ֿ�ʼ����
                       lv_enddate, --��ֽ�������
                       '32',
                       av_res, --������� 0��ʾ��ȷ
                       av_msg --����ԭ��
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;

            END IF;
          ELSIF lv_stlmode.stl_mode = '4' THEN
            --4���������������˻�������
            --4.1����������
            lv_begindate := NULL;
            p_setbegindate(41);
            IF lv_stlmode.stl_way IN ('02', '06') THEN
              --�޶�
              lv_sum := f_getsum('41', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way,
                        lv_stlmode.stl_days,
                        lv_sum) = '1' THEN
              --�ﵽ��������
              p_settle(lv_stlmode,
                       lv_merchant, --�̻���
                       lv_operid, --�����Ա
                       lv_begindate, --��ֿ�ʼ����
                       lv_enddate, --��ֽ�������
                       '41',
                       av_res, --������� 0��ʾ��ȷ
                       av_msg --����ԭ��
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
            --4.2�˻�
            lv_begindate := NULL;
            p_setbegindate(42);
            IF lv_stlmode.stl_way_ret IN ('02', '06') THEN
              --�޶�
              lv_sum := f_getsum('42', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way_ret,
                        lv_stlmode.stl_days_ret,
                        lv_sum) = '1' THEN
              --�ﵽ��������
              p_settle(lv_stlmode,
                       lv_merchant, --�̻���
                       lv_operid, --�����Ա
                       lv_begindate, --��ֿ�ʼ����
                       lv_enddate, --��ֽ�������
                       '42',
                       av_res, --������� 0��ʾ��ȷ
                       av_msg --����ԭ��
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
          END IF;
        ELSE
          --û�����ý���ģʽ
          pk_public.p_insertrzcllog('û�����ý���ģʽ' || lv_enddate,
                                    av_bizid);
          RETURN;
        END IF;
        --p_setnextbeginenddate;
        lv_enddate := to_char(to_date(lv_enddate, 'yyyy-mm-dd') + 1,
                              'yyyy-mm-dd');
      END LOOP;
    END IF;

    av_res := 0;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := -1;
      dbms_output.put_line('������Ϣ��' || dbms_utility.format_error_stack);
      av_msg := av_msg || '������Ϣ��' || SQLERRM;
  END p_settle;

  /*=======================================================================================*/
  --�������̻����н���
  /*=======================================================================================*/
  PROCEDURE p_settle(av_operid IN sys_users.user_id%TYPE, --�����Ա
                     av_res    OUT VARCHAR2, --��������
                     av_msg    OUT VARCHAR2 --����������Ϣ
                     ) IS
    lv_operid sys_users.user_id%TYPE;
  BEGIN
    FOR merchant IN (SELECT * FROM base_merchant) LOOP
      IF av_operid IS NULL THEN
        lv_operid := pk_public.f_getorgoperid(merchant.org_id);
      ELSE
        lv_operid := av_operid;
      END IF;
      p_settle(merchant.merchant_id, lv_operid, av_res, av_msg);
      IF av_res <> 0 THEN
        RETURN;
      END IF;
    END LOOP;

  END p_settle;

  /*=======================================================================================*/
  --��һ�̻����м�ʱ����
  /*=======================================================================================*/
  PROCEDURE p_settle_immediate(av_bizid  IN base_merchant.merchant_id%TYPE, --�̻���
                               av_operid IN sys_users.user_id%TYPE, --�����Ա
                               av_res    OUT VARCHAR2, --��������
                               av_msg    OUT VARCHAR2 --����������Ϣ
                               ) IS
    lv_merchant  base_merchant%ROWTYPE; --�̻���
    lv_stlmode   stl_mode%ROWTYPE; --����ģʽ��
    lv_clrdate   pay_clr_para.clr_date%TYPE; --�������
    lv_begindate VARCHAR2(10) := NULL; --��ֿ�ʼ����
    lv_enddate   VARCHAR2(10) := NULL; --��ֽ�������
  BEGIN
    SELECT * INTO lv_merchant FROM base_merchant WHERE merchant_id = av_bizid;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --δ��ּ�¼�������
    pk_cutday.p_clr(lv_merchant.merchant_id, --�̻���
                    lv_clrdate, --�������
                    av_res, --��������
                    av_msg --����������Ϣ
                    );
    IF av_res <> '00' THEN
      RETURN;
    END IF;
    --���м�¼���н���
    SELECT MIN(clr_date), MAX(clr_date)
      INTO lv_begindate, lv_enddate
      FROM pay_clr_sum
     WHERE merchant_id = av_bizid
       AND (stl_sum_no IS NULL OR fee_stl_sum_no IS NULL);
    lv_enddate := lv_clrdate;
    p_settle(lv_stlmode,
             lv_merchant, --�̻���
             av_operid, --�����Ա
             lv_begindate, --��ֿ�ʼ����
             lv_enddate, --��ֽ�������
             '1',
             av_res, --������� 0��ʾ��ȷ
             av_msg, --����ԭ��
             lv_clrdate);
    IF av_res <> 0 THEN
      RETURN;
    END IF;
  END p_settle_immediate;

  /*=======================================================================================*/
  --�������̻����н����job
  /*=======================================================================================*/
  PROCEDURE p_job IS
    av_msg VARCHAR2(1000);
    av_res NUMBER;
  BEGIN
    pk_merchantsettle.p_settle('admin', av_res, av_msg);
    IF av_res < 0 THEN
      ROLLBACK;
    ELSE
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END p_job;

  /*=======================================================================================*/
  --�̻��������
  /*=======================================================================================*/
  PROCEDURE p_settlerollback(av_stlsumno IN stl_deal_sum.stl_sum_no%TYPE, --�̻�����������
                             av_res      OUT VARCHAR2, --��������
                             av_msg      OUT VARCHAR2 --����������Ϣ
                             ) IS
    lv_tradesum stl_deal_sum%ROWTYPE;
  BEGIN
    BEGIN
      SELECT *
        INTO lv_tradesum
        FROM stl_deal_sum
       WHERE stl_sum_no = av_stlsumno
         AND rownum < 2;
    EXCEPTION
      WHEN no_data_found THEN
        av_res := 0;
        RETURN;
    END;
    SELECT COUNT(*)
      INTO av_res
      FROM stl_deal_sum
     WHERE merchant_id = lv_tradesum.merchant_id
       AND stl_date >= lv_tradesum.stl_date
       AND stl_state > '0'
       AND rownum < 2;
    IF av_res > 0 THEN
      av_res := -1;
      av_msg := '����������ں�������˻�֧����¼�����ܻ��ˣ�';
      RETURN;
    END IF;
    FOR tradesum IN (SELECT *
                       FROM stl_deal_sum
                      WHERE merchant_id = lv_tradesum.merchant_id
                        AND stl_date >= lv_tradesum.stl_date
                        AND stl_state = '0'
                      ORDER BY stl_date DESC) LOOP
      DELETE FROM stl_deal_list_div
       WHERE stl_sum_no = tradesum.stl_sum_no;
      DELETE FROM stl_deal_list WHERE stl_sum_no = tradesum.stl_sum_no;
      UPDATE pay_clr_sum
         SET stl_date = NULL, stl_flag = '1', stl_sum_no = NULL
       WHERE stl_sum_no = tradesum.stl_sum_no;
      UPDATE pay_clr_sum
         SET fee_stl_date = NULL, fee_stl_flag = '1', fee_stl_sum_no = NULL
       WHERE fee_stl_sum_no = tradesum.stl_sum_no;
      DELETE FROM stl_deal_sum WHERE stl_sum_no = tradesum.stl_sum_no;
    END LOOP;
  END p_settlerollback;

  /*=======================================================================================*/
  --�̻�����֧��
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|5stlsumnos|6note|7bank_sheet_no
  --stlsumnos��stl_sum_no$card_type$acc_kind,stl_sum_no$card_type$acc_kind
  /*=======================================================================================*/
  PROCEDURE p_settlepay(av_in    IN VARCHAR2, --�������
                        av_debug IN VARCHAR2, --1����
                        av_res   OUT VARCHAR2, --��������
                        av_msg   OUT VARCHAR2 --����������Ϣ
                        ) IS
    lv_count         NUMBER;
    lv_clrdate       pay_clr_para.clr_date%TYPE; --�������
    lv_in            pk_public.myarray; --�����������
    lv_stllist       pk_public.myarray; --�����б�
    lv_stl           pk_public.myarray; --�����¼����
    lv_stltradesum   stl_deal_sum%ROWTYPE;
    lv_dbsubledger   acc_account_sub%ROWTYPE; --�跽�ֻ���
    lv_crsubledger   acc_account_sub%ROWTYPE; --�����ֻ���
    lv_operator      sys_users%ROWTYPE; --����Ա
    lv_accbookno     acc_inout_detail.acc_inout_no%TYPE; --������ˮ��
    lv_remit_book_no stl_receipt_reg.reg_no%TYPE;
  BEGIN
    pk_public.p_getinputpara(av_in, --�������
                             7, --�������ٸ���
                             7, --����������
                             'pk_merchantsettle.p_settlepay', --���õĺ�����
                             lv_in, --ת���ɲ�������
                             av_res, --������������
                             av_msg --��������������Ϣ
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
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
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = lv_in(3);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := 'δ�ҵ���Ա���' || lv_in(3);
        RETURN;
    END;

    lv_count := pk_public.f_splitstr(lv_in(5), ',', lv_stllist);
    IF lv_count = 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '�����б���Ϊ��';
      RETURN;
    END IF;
    FOR i IN 1 .. lv_stllist.count LOOP
      lv_count := pk_public.f_splitstr(lv_stllist(i), '$', lv_stl);
      --���̻��������
      SELECT *
        INTO lv_stltradesum
        FROM stl_deal_sum
       WHERE stl_sum_no = lv_stl(1)
         AND card_type = lv_stl(2)
         AND acc_kind = lv_stl(3);
      --����stl_trade_sum
      SELECT seq_remit_book_no.nextval INTO lv_remit_book_no FROM dual;
      UPDATE stl_deal_sum
         SET stl_state     = '9',
             vrf_date      = SYSDATE,
             vrf_user_id   = lv_in(3),
             reg_no = lv_remit_book_no
       WHERE stl_sum_no = lv_stl(1)
         AND card_type = lv_stl(2)
         AND acc_kind = lv_stl(3)
         AND stl_state <> '9';
      IF SQL%ROWCOUNT = 0 THEN
        av_res := pk_public.cs_res_paravalueerr;
        av_msg := '�ý����¼��֧���������ظ�֧��';
        RETURN;
      END IF;
      --дstl_remit_book
      INSERT INTO stl_receipt_reg
        (reg_no,
         note,
         org_id,
         merchant_id,
         stl_amt,
         pay_date,
         pay_user_id, --
         pay_bank_id,
         pay_acc_name,
         pay_acc_no,
         rcv_bank_id,
         rcv_acc_name,
         rcv_acc_no, --
         vrf_amt,
         vrf_date,
         vrf_user_id,
         err_msg,
         pay_state,
         bank_sheet_no)
      VALUES
        (lv_remit_book_no,
         lv_in(6),
         lv_dbsubledger.org_id,
         lv_stltradesum.merchant_id,
         lv_stltradesum.stl_amt,
         SYSDATE,
         lv_in(3), --
         NULL,
         NULL,
         NULL,
         NULL,
         NULL,
         NULL, --
         lv_stltradesum.stl_amt,
         SYSDATE,
         lv_in(3),
         NULL,
         '1',
         lv_in(7));

      SELECT customer_id
        INTO lv_dbsubledger.customer_id
        FROM base_merchant
       WHERE merchant_id = lv_stltradesum.merchant_id;
      pk_public.p_getsubledgerbyclientid(lv_dbsubledger.customer_id, --�̻�client_id
                                         pk_public.cs_accitem_biz_clr, --�̻��������
                                         lv_dbsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --���̻����˻����̻������
      BEGIN
        pk_public.p_getsubledgerbyclientid(lv_dbsubledger.customer_id, --�̻�client_id
                                           pk_public.cs_accitem_biz_stl, --�̻������
                                           lv_crsubledger,
                                           av_res,
                                           av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
      END;
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
                            lv_stltradesum.stl_amt, --���׽��
                            0, --���÷�����
                            lv_accbookno, --������ˮ��
                            lv_in(2), --���״���
                            lv_dbsubledger.org_id, --��������
                            lv_crsubledger.org_id, --�������
                            '0', --��������
                            lv_operator.brch_id, --��������(�����/�̻��ŵ�)
                            lv_in(3), --������Ա/�ն˺�
                            NULL, --�������κ�
                            NULL, --�ն˽�����ˮ��
                            to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --����ʱ��
                            '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                            lv_in(1), --ҵ����ˮ��
                            lv_in(6), --��ע
                            lv_clrdate, --�������
                            null,
                            av_debug, --1����
                            av_res, --������������
                            av_msg --��������������Ϣ
                            );
      --���̻�������� ����������������
      FOR lv_divfee IN (SELECT *
                          FROM stl_deal_list_div
                         WHERE stl_sum_no = lv_stl(1)
                           AND card_type = lv_stl(2)
                           AND acc_kind = lv_stl(3)) LOOP
        pk_public.p_getorgsubledger(lv_divfee.org_id,
                                    pk_public.cs_accitem_org_handding_fee_in,
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
                              lv_divfee.div_fee, --���׽��
                              0, --���÷�����
                              lv_accbookno, --������ˮ��
                              lv_in(2), --���״���
                              lv_dbsubledger.org_id, --��������
                              lv_crsubledger.org_id, --�������
                              '0', --��������
                              lv_operator.brch_id, --��������(�����/�̻��ŵ�)
                              lv_in(3), --������Ա/�ն˺�
                              NULL, --�������κ�
                              NULL, --�ն˽�����ˮ��
                              to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --����ʱ��
                              '0', --������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
                              lv_in(1), --ҵ����ˮ��
                              lv_in(6), --��ע
                              lv_clrdate, --�������
                              null,
                              av_debug, --1����
                              av_res, --������������
                              av_msg --��������������Ϣ
                              );
      END LOOP;

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := -1;
      dbms_output.put_line('������Ϣ��' || dbms_utility.format_error_stack);
      av_msg := av_msg || '������Ϣ��' || SQLERRM;
  END p_settlepay;

BEGIN
  -- initialization
  NULL;
END pk_merchantsettle;
/

