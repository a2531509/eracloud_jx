create or replace package body pk_co_org_handle IS
       cs_pay_source_xj   CONSTANT CHAR(1) := '0'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
       cs_pay_source_zz   CONSTANT CHAR(1) := '1'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
       cs_pay_source_czk  CONSTANT CHAR(1) := '2'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
       cs_pay_source_cx   CONSTANT CHAR(1) := '3'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
       cs_pay_source_xy   CONSTANT CHAR(1) := '4'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
       cs_pay_source_yck  CONSTANT CHAR(1) := '5'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
       cs_pay_source_qdcx CONSTANT CHAR(1) := '6'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������
       cs_pay_source_qdjl CONSTANT CHAR(1) := '7'; --��ֵ�ʽ���Դ0�ֽ�1ת��2��ֵ��3����4�������ö��5����Ԥ���6�̻�ǩ������7ǩ������

 /*=======================================================================================*/
  --������ֿ�ʼ�������ڽ���
  /*=======================================================================================*/
  PROCEDURE p_settle(av_stlmode   in stl_co_mode%ROWTYPE, --����ģʽ��
                     av_co_org    IN base_co_org%ROWTYPE, --�̻�
                     av_operid    IN sys_users.user_id%TYPE, --��Ա���
                     av_begindate IN pay_co_clr_sum.clr_date%TYPE, --��ֿ�ʼ����
                     av_enddate   IN pay_co_clr_sum.clr_date%TYPE, --��ֽ�������
                     av_type      IN VARCHAR2, --1:--ȫ������ 21:ȫ�������� ���� 22:ȫ�������� �˻� 23:ȫ�������� ������ 31:�����˻����������Ѳ����� �����˻� 32:�����˻����������Ѳ����� ������ 41:���������������˻������� ���������� 42:���������������˻������� �˻�
                     av_res       OUT VARCHAR2, --��������
                     av_msg       OUT VARCHAR2, --����������Ϣ
                     av_jsrq      IN VARCHAR2 DEFAULT NULL --�������� ��ʱ����ʱȡ��ǰ������ڣ�������nullȡ����������һ��
                     ) IS
    ls_jsrq         CHAR(10) := NULL;
    lv_stlsumno     stl_deal_sum.stl_sum_no%TYPE; --�������
    lv_feerate      pay_co_fee_rate%ROWTYPE; --����
    lv_stltradelist stl_co_deal_list%ROWTYPE; --������ϸ
    lv_operid       sys_users.user_id%TYPE;
        /*=======================================================================================*/
            --��������--start
        /*=======================================================================================*/
    PROCEDURE p_setfee(as_trcode stl_deal_list.deal_code%TYPE) IS
      ln_jgfc  NUMBER;
      ln_count NUMBER;
      --in_fdamt NUMBER := 0;
      --in_fee_rate number := 0;
    BEGIN
      --��ȡ����
      SELECT *
        INTO lv_feerate
        FROM pay_co_fee_rate t
       WHERE t.co_org_id = av_co_org.co_org_id
         AND t.deal_code = as_trcode
         AND t.fee_state = '0'
         AND begindate =
             (SELECT MAX(begindate)
                FROM pay_co_fee_rate
               WHERE co_org_id = av_co_org.co_org_id
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
          lv_stltradelist.fee_amt := lv_stltradelist.deal_num *
                                     lv_feerate.fee_rate / 10000;
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
                                           greatest(0,(lv_stltradelist.deal_amt -
                                           ln_section(i))) * ln_feerate(i) /
                                           10000;
                EXIT;
              END IF;
            END LOOP;
          END;
        ELSE
          lv_stltradelist.fee_amt := lv_stltradelist.deal_amt *
                                     lv_feerate.fee_rate / 10000;
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
      IF lv_feerate.in_out = '2' THEN
        lv_stltradelist.fee_amt := -abs(lv_stltradelist.fee_amt);
      END IF;
      IF lv_stltradelist.deal_code = '40102051' OR lv_stltradelist.deal_code = '40202051'  THEN
        lv_stltradelist.deal_amt := -lv_stltradelist.deal_amt;
      END IF;
      --��������ֳ�
      SELECT COUNT(*)
        INTO ln_count
        FROM pay_divide_rate_detail
       WHERE div_id = av_co_org.div_id
         AND card_type = lv_stltradelist.card_type;
      --and div_state = '0';
      INSERT INTO stl_co_deal_list_div
      (stl_sum_no,
       list_no,
       co_org_id,
       deal_code,
       card_type,
       acc_kind,
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
               av_co_org.div_id,
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
         WHERE div_id = av_co_org.div_id
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
        IF lv_stltradelist.deal_code = '40102051' OR lv_stltradelist.deal_code = '40202051' THEN
          --�˻�
          lv_stltradelist.in_out := '1';
          lv_stltradelist.deal_amt := -lv_stltradelist.deal_amt;
        ELSE
          lv_stltradelist.in_out := '0';
        END IF;
      WHEN OTHERS THEN
        av_res := -1;
        av_msg := nvl(av_msg, '�������ѷ�������:') || SQLERRM;
    END p_setfee;
    /*=======================================================================================*/
            --��������----end
    /*=======================================================================================*/


  BEGIN
    ls_jsrq := nvl(av_jsrq,
                   to_char(to_date(av_enddate, 'yyyy-mm-dd') + 1,
                           'yyyy-mm-dd'));
    IF av_operid IS NULL THEN
      lv_operid := pk_public.f_getorgoperid(av_co_org.org_id);
    ELSE
      lv_operid := av_operid;
    END IF;
    --��ȡ�������
    SELECT seq_stl_sum_no.nextval INTO lv_stlsumno FROM dual;
    --1:--ȫ������
    --21:ȫ�������� ���� 22:ȫ�������� �˻� 23:ȫ�������� ������ 24: ��ֵ������ ��ֵ  25 �� ��ֵ������ �����
    --31:�����˻����������Ѳ����� �����˻� 32:�����˻����������Ѳ����� ������
    --41:���������������˻������� ���������� 42:���������������˻������� �˻�

    IF av_type IN ('1', '24') THEN
      --��ֵ
      UPDATE pay_co_clr_sum
         SET stl_date = ls_jsrq, stl_flag = '0', stl_sum_no = lv_stlsumno
       WHERE co_org_id = av_co_org.co_org_id
         AND to_date(clr_date, 'yyyy-mm-dd') >=
             to_date(av_begindate, 'yyyy-mm-dd')
         AND to_date(clr_date, 'yyyy-mm-dd') <=
             to_date(av_enddate, 'yyyy-mm-dd')
         AND deal_code LIKE '%30%'--��ֵ
         AND stl_sum_no IS NULL;
    END IF;

    IF av_type IN ('1', '21', '31', '41') THEN
      --����
      UPDATE pay_co_clr_sum
         SET stl_date = ls_jsrq, stl_flag = '0', stl_sum_no = lv_stlsumno
       WHERE co_org_id = av_co_org.co_org_id
         AND to_date(clr_date, 'yyyy-mm-dd') >=
             to_date(av_begindate, 'yyyy-mm-dd')
         AND to_date(clr_date, 'yyyy-mm-dd') <=
             to_date(av_enddate, 'yyyy-mm-dd')
         AND (deal_code = '40102010' or deal_code = '40202010')--����
         AND stl_sum_no IS NULL;
    END IF;
    IF av_type IN ('1', '22', '31', '42') THEN
      --�˻�
      UPDATE pay_co_clr_sum
         SET stl_date = ls_jsrq, stl_flag = '0', stl_sum_no = lv_stlsumno
       WHERE co_org_id = av_co_org.co_org_id
         AND to_date(clr_date, 'yyyy-mm-dd') >=
             to_date(av_begindate, 'yyyy-mm-dd')
         AND to_date(clr_date, 'yyyy-mm-dd') <=
             to_date(av_enddate, 'yyyy-mm-dd')
         AND (deal_code = '40102051' or deal_code = '40202051') --�˻�
         AND stl_sum_no IS NULL;
    END IF;

    IF av_type IN ('1', '23', '32', '41','25') THEN
      --������
      UPDATE pay_co_clr_sum
         SET fee_stl_date   = ls_jsrq,
             fee_stl_flag   = '0',
             fee_stl_sum_no = lv_stlsumno
       WHERE co_org_id = av_co_org.co_org_id
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

    FOR lrec_clr IN (SELECT co_org_id,
                            deal_code,
                            card_type,
                            acc_kind,
                            SUM(deal_num) AS deal_num,
                            SUM(deal_amt) AS deal_amt
                       FROM pay_co_clr_sum
                      WHERE stl_sum_no = lv_stlsumno
                         OR fee_stl_sum_no = lv_stlsumno
                      GROUP BY co_org_id, deal_code, card_type, acc_kind) LOOP
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
      IF av_type IN ('23', '32','25') THEN
        lv_stltradelist.deal_num := 0;
        lv_stltradelist.deal_amt := '0';
      END IF;
      INSERT INTO stl_deal_list VALUES lv_stltradelist;
    END LOOP;
    --��������������
    INSERT INTO stl_co_deal_sum
     (stl_sum_no,
      co_org_id,
      co_org_name,
      org_id,
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
      th_amt, --�˻����
      card_type, --������
      acc_kind, --�˻�����
      begin_date, --��ʼ����
      end_date,
      stl_mode,
      stl_way)
      SELECT lv_stlsumno, --�������
             av_co_org.co_org_name,
             av_co_org.co_org_id,
             av_co_org.org_id,
             0, --��������
             --1, --�������
             nvl(SUM(deal_num), 0), --�ܱ���
             CASE
               WHEN av_type = '41' THEN
                --nvl(SUM(decode(substrb(deal_code, 1, 3), '811', 0, deal_amt)), 0) --�ܽ��
                nvl(sum(decode(deal_code,'40102051',0,'40202051',0,deal_amt)),0)
               ELSE
                nvl(SUM(deal_amt), 0)
             END tramt,
             nvl(SUM(fee_amt), 0),
             CASE
               WHEN av_type = '41' THEN
                --nvl(SUM(decode(substrb(deal_code, 1, 3), '811', 0, deal_amt)), 0) -
                nvl(sum(decode(deal_code,'40102051',0,'40202051',0,deal_amt)),0)-
                nvl(SUM(fee_amt), 0)
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
       /*=====================================��ʼ���г�ֵ�����================================*/


    av_res := 0;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := -1;
      av_msg := nvl(av_msg, '�̻����㷢������:') || SQLERRM;
  END p_settle;

  /*=======================================================================================*/
  --��һ�����������н���
  /*=======================================================================================*/
  PROCEDURE p_settle(av_co_org_id  IN base_co_org.co_org_id%TYPE, --������
                     av_operid IN sys_users.user_id%TYPE, --�����Ա
                     av_res    OUT VARCHAR2, --��������
                     av_msg    OUT VARCHAR2 --����������Ϣ
                     ) IS
    lv_coOrg  base_co_org%ROWTYPE; --������Ϣ
    lv_begindate VARCHAR2(10) := NULL; --��ֿ�ʼ����
    lv_enddate   VARCHAR2(10) := NULL; --��ֽ�������
    lv_sum       NUMBER;
    lv_stlmode   stl_co_mode%ROWTYPE; --����ģʽ��
    lv_operid    sys_users.user_id%TYPE;
     --ȡ����ģʽ
    FUNCTION f_getstlmode(as_clrdate VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
      SELECT *
        INTO lv_stlmode
        FROM stl_co_mode
       WHERE co_org_id = lv_coOrg.Co_Org_Id
         AND valid_date =
             (SELECT MAX(valid_date)
                FROM stl_co_mode
               WHERE co_org_id = lv_coOrg.Co_Org_Id
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
          FROM pay_co_clr_sum
         WHERE co_org_id = lv_coOrg.Co_Org_Id
           AND (stl_sum_no IS NULL OR fee_stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '21' THEN
        --ȫ�������� ����
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_co_clr_sum
         WHERE co_org_id = lv_coOrg.Co_Org_Id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate
           AND (deal_code = '40102010' or deal_code = '40202010') ; --����
      ELSIF av_type = '22' THEN
        --ȫ�������� �˻�
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_co_clr_sum
         WHERE co_org_id = lv_coOrg.Co_Org_Id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate
           AND (deal_code = '40102051' or deal_code = '40202051'); --�˻�
      ELSIF av_type = '23' THEN
        --ȫ�������� ������
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_co_clr_sum
         WHERE co_org_id = lv_coOrg.Co_Org_Id
           AND (fee_stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '24' THEN
         --ȫ��������  ��ֵ
         SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_co_clr_sum
         WHERE co_org_id = lv_coOrg.Co_Org_Id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate
           AND deal_code LIKE '30%'; --��ֵ
      ELSIF av_type = '25' THEN
        --ȫ��������   �����
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_co_clr_sum
         WHERE co_org_id = lv_coOrg.Co_Org_Id
           AND (fee_stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '31' THEN
        --�����˻����������Ѳ����� �����˻�
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_co_clr_sum
         WHERE co_org_id = lv_coOrg.Co_Org_Id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '32' THEN
        --�����˻����������Ѳ����� ������
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_co_clr_sum
         WHERE co_org_id = lv_coOrg.Co_Org_Id
           AND (fee_stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '41' THEN
        --���������������˻������� ����������
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_co_clr_sum
         WHERE co_org_id = lv_coOrg.Co_Org_Id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate
           AND (deal_code = '40102010' or deal_code = '40202010');
      ELSIF av_type = '42' THEN
        --���������������˻������� �˻�
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_co_clr_sum
         WHERE co_org_id = lv_coOrg.Co_Org_Id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate
           AND (deal_code = '40102051' or deal_code = '40202051');
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
    FUNCTION p_getmindate(date0 VARCHAR2,
                          date1 VARCHAR2 DEFAULT NULL,
                          date2 VARCHAR2 DEFAULT NULL,
                          date3 VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
      out_date VARCHAR2(50);
    BEGIN
      IF date1 IS NULL AND date1 IS NULL AND date2 IS NULL AND date3 IS NULL THEN
        RETURN NULL;
      END IF;
      out_date := least(nvl(date0, '2999-01-01'),
                        nvl(date1, '2999-01-01'),
                        nvl(date2, '2999-01-01'),
                        nvl(date3, '2999-01-01'));
      RETURN out_date;
    END p_getmindate;
    --ȡ���㿪ʼ����
    PROCEDURE p_setbegindate(trcode VARCHAR2) IS
      cz  VARCHAR2(50);
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
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND stl_sum_no IS NOT NULL
             AND (deal_code = '40102010' or deal_code = '40202010');

           SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO cz
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND stl_sum_no IS NOT NULL
             AND deal_code LIKE '30%';

          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO th
           FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND (deal_code = '40102051' or deal_code = '40202051');
          SELECT MAX(to_char(to_date(fee_stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO sxf
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND fee_stl_sum_no IS NOT NULL;

          lv_begindate := p_getmindate(cz,xf, th, sxf);

        END IF;
        IF trcode = 21 THEN
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO xf
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND stl_sum_no IS NOT NULL
             AND (deal_code = '40102010' or deal_code = '40202010');
          lv_begindate := p_getmindate(xf);
        END IF;

        IF trcode = 22 THEN
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO th
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND stl_sum_no IS NOT NULL
             AND (deal_code = '40102051' or deal_code = '40202051');
          lv_begindate := p_getmindate(th, NULL, NULL);
        END IF;

        IF trcode = 23 THEN
          SELECT MAX(to_char(to_date(fee_stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO sxf
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND fee_stl_sum_no IS NOT NULL;
          lv_begindate := p_getmindate(sxf, NULL, NULL);
        END IF;

        IF trcode = 24 THEN
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO xf
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND stl_sum_no IS NOT NULL
             AND deal_code LIKE '30%';
          lv_begindate := p_getmindate(xf);
        END IF;

        IF trcode = 25 THEN
          SELECT MAX(to_char(to_date(fee_stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO sxf
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND fee_stl_sum_no IS NOT NULL;
          lv_begindate := p_getmindate(sxf, NULL, NULL);
        END IF;

        IF trcode = 31 THEN
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO xf
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND stl_sum_no IS NOT NULL
             AND (deal_code = '40102010' or deal_code = '40202010');
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO th
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND stl_sum_no IS NOT NULL
             AND (deal_code = '40102051' or deal_code = '40202051');
          lv_begindate := p_getmindate(xf, th, NULL);
        END IF;
        IF trcode = 32 THEN
          SELECT MAX(to_char(to_date(fee_stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO sxf
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND fee_stl_sum_no IS NOT NULL;
          lv_begindate := p_getmindate(sxf, NULL, NULL);
        END IF;
        IF trcode = 41 THEN
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO xf
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND stl_sum_no IS NOT NULL
             AND (deal_code = '40102010' or deal_code = '40202010');
          SELECT MAX(to_char(to_date(fee_stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO sxf
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND fee_stl_sum_no IS NOT NULL;
          lv_begindate := p_getmindate(xf, sxf, NULL);
        END IF;
        IF trcode = 42 THEN
          SELECT MAX(to_char(to_date(stl_date, 'yyyy-mm-dd') - 0,
                             'yyyy-mm-dd'))
            INTO th
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id
             AND stl_sum_no IS NOT NULL
             AND (deal_code = '40102051' or deal_code = '40202051');
          lv_begindate := p_getmindate(th, NULL, NULL);
        END IF;
        -- select to_char(to_date(max(stl_date), 'yyyy-mm-dd'), 'yyyy-mm-dd') into lv_begindate from stl_trade_sum where biz_id = av_bizid;
        IF lv_begindate IS NULL THEN
          SELECT MIN(clr_date)
            INTO lv_begindate
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id;
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
          FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id;

        IF lv_begindate IS NULL THEN
          SELECT MIN(clr_date)
            INTO lv_begindate
            FROM pay_co_clr_sum
           WHERE co_org_id = av_co_org_id;
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
    SELECT * INTO lv_coOrg FROM base_co_org WHERE co_org_id = av_co_org_id;
    IF av_operid IS NULL THEN
      lv_operid := pk_public.f_getorgoperid(lv_coOrg.org_id);
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
                       lv_coOrg, --�̻���
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
                       lv_coOrg, --�̻���
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
                       lv_coOrg, --�̻���
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
                       lv_coOrg, --�̻���
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
            --2.4 ��ֵ
            lv_begindate := NULL;
            p_setbegindate(21);
            IF lv_stlmode.stl_way IN ('02', '06') THEN
              --�޶�
              lv_sum := f_getsum('24', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way,
                        lv_stlmode.stl_days,
                        lv_sum) = '1' THEN
              --�ﵽ��������
              p_settle(lv_stlmode,
                       lv_coOrg, --�̻���
                       lv_operid, --�����Ա
                       lv_begindate, --��ֿ�ʼ����
                       lv_enddate, --��ֽ�������
                       '24',
                       av_res, --������� 0��ʾ��ȷ
                       av_msg --����ԭ��
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
            --2.5 �����
            lv_begindate := NULL;
            p_setbegindate(23);
            IF lv_stlmode.stl_way_fee IN ('02', '06') THEN
              --�޶�
            lv_sum := f_getsum('25', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way_fee,
                        lv_stlmode.stl_way_fee,
                        lv_sum) = '1' THEN
              p_settle(lv_stlmode,
                       lv_coOrg, --�̻���
                       lv_operid, --�����Ա
                       lv_begindate, --��ֿ�ʼ����
                       lv_enddate, --��ֽ�������
                       '25',
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
                       lv_coOrg, --�̻���
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
                       lv_coOrg, --�̻���
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
                       lv_coOrg, --�̻���
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
                       lv_coOrg, --�̻���
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
                                    av_co_org_id);
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
    FOR coorg IN (SELECT * FROM base_co_org) LOOP
      IF av_operid IS NULL THEN
        lv_operid := pk_public.f_getorgoperid(coorg.org_id);
      ELSE
        lv_operid := av_operid;
      END IF;
      p_settle(coorg.co_org_id, lv_operid, av_res, av_msg);
      IF av_res <> 0 THEN
        RETURN;
      END IF;
    END LOOP;

  END p_settle;

   /*=======================================================================================*/
  --�������̻����н����job
  /*=======================================================================================*/
  PROCEDURE p_job IS
    av_msg VARCHAR2(1000);
    av_res NUMBER;
  BEGIN
    pk_co_org_handle.p_settle('admin', av_res, av_msg);
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
  PROCEDURE p_settlerollback(av_stlsumno IN stl_co_deal_sum.stl_sum_no%TYPE, --������������������
                             av_res      OUT VARCHAR2, --��������
                             av_msg      OUT VARCHAR2 --����������Ϣ
                             ) IS
    lv_tradesum stl_co_deal_sum%ROWTYPE;
  BEGIN
    BEGIN
      SELECT *
        INTO lv_tradesum
        FROM stl_co_deal_sum
       WHERE stl_sum_no = av_stlsumno
         AND rownum < 2;
    EXCEPTION
      WHEN no_data_found THEN
        av_res := 0;
        RETURN;
    END;
    SELECT COUNT(*)
      INTO av_res
      FROM stl_co_deal_sum
     WHERE co_org_id = lv_tradesum.co_org_id
       AND stl_date >= lv_tradesum.stl_date
       AND stl_state > '0'
       AND rownum < 2;
    IF av_res > 0 THEN
      av_res := -1;
      av_msg := '����������ں�������˻�֧����¼�����ܻ��ˣ�';
      RETURN;
    END IF;
    FOR tradesum IN (SELECT *
                       FROM stl_co_deal_sum
                      WHERE co_org_id = lv_tradesum.co_org_id
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
  --������������
  /*=======================================================================================*/
  PROCEDURE p_check_bill(av_co_org_id IN base_co_org.co_org_id%TYPE, --�����������
                               av_acpt_id   IN VARCHAR2,--�������
                               av_batch_id  IN VARCHAR2,--���κ�
                               av_end_id    IN VARCHAR2,--�ն˺�
                               av_check_type IN VARCHAR2,--�������� 01 ��ֵ 02 ����
                               av_check_filenmae IN VARCHAR2, --�����ļ���
                               av_check_date IN VARCHAR2, --��������yyyymmdd
                               av_check_zc_sum  IN NUMBER,--���������ܱ���
                               av_check_zc_amt  IN NUMBER,--���������ܽ��
                               --av_check_cx_sum  IN NUMBER,--���˳�������
                               --av_check_cx_amt  IN NUMBER,--���˳������
                               av_check_th_sum  IN NUMBER,--�����˻�����
                               av_check_th_amt  IN NUMBER,--�����˻����
                               av_res      OUT VARCHAR2, --��������
                               av_msg      OUT VARCHAR2 --����������Ϣ
                             ) is


         datenow  DATE;
         lv_tablename   VARCHAR2(50);
         sys_zc_count number;
         sys_zc_amt   number;
         sys_cx_count number;
         sys_cx_amt  number;
         sys_th_count number;
         sys_th_amt  number;
         check_id  number;
         lv_base_co_org_id base_co_org%rowtype;
         lv_action_no varchar2(22);
         ln_count NUMBER;
       BEGIN
            av_res :='00000000';
            av_msg :='';
            --�жϺ��������Ƿ����
            begin
             select * into lv_base_co_org_id from base_co_org where co_org_id = av_co_org_id;
            exception
              when NO_DATA_FOUND THEN
                av_res := pk_public.cs_res_co_org_novalidateerr;
                return;
            end;
            --�ж��Ƿ��Ѿ������˶���
           SELECT COUNT(1) INTO ln_count FROM pay_co_check_single t WHERE t.CO_ORG_ID = av_co_org_id AND t.acpt_id = av_acpt_id
           AND t.check_date  = av_check_date AND  t.proc_state IN('0','1','3');

           IF ln_count > 0   THEN  --���ɷ����ظ�����
              av_res := pk_public.cs_res_co_check_bill_rep;
              av_msg := '�����ظ�����';
           END IF;
            select sysdate into datenow from dual;
            select seq_action_no.nextval into lv_action_no from dual;
            --ͳ�����������ͽ��
            lv_tablename:='acc_inout_detail_' ||trim(substr(av_check_date,1,6));
            EXECUTE IMMEDIATE
                    'select count(*),sum(cr_amt) from '||lv_tablename ||
                    ' where DEAL_STATE = ''0'' and acpt_id = :1 and clr_date = :2'
                    into sys_zc_count,sys_zc_amt
              USING av_co_org_id,SUBSTR(av_check_date,1,4)||'-'||SUBSTR(av_check_date,5,2)||'-'||SUBSTR(av_check_date,7,2);
            --���������ͽ��
            EXECUTE IMMEDIATE
                    'select count(*),sum(cr_amt) from '||lv_tablename ||
                    ' where DEAL_STATE = ''1'' and acpt_id = :1 and clr_date = :2'
                    into sys_cx_count,sys_cx_amt
              USING av_co_org_id,SUBSTR(av_check_date,1,4)||'-'||SUBSTR(av_check_date,5,2)||'-'||SUBSTR(av_check_date,7,2);
            --�˻������ͽ��
            EXECUTE IMMEDIATE
                    'select count(*),sum(cr_amt) from '||lv_tablename ||
                    ' where DEAL_STATE = ''3'' and acpt_id = :1 and clr_date =:2'
                    into sys_th_count,sys_th_amt
              USING av_co_org_id,SUBSTR(av_check_date,1,4)||'-'||SUBSTR(av_check_date,5,2)||'-'||SUBSTR(av_check_date,7,2);
             --���ɶ�������
             select SEQ_COOPER_CHECK_ID.Nextval into check_id from dual;
             insert into PAY_CO_CHECK_SINGLE(
                 ID,
                 CARD_ORG_ID,
                 CO_ORG_ID,
                 acpt_ID,
                 FILE_TYPE,
                 FILE_NAME,
                 CHECK_DATE,
                 EXIST_DETAIL,
                 TOTAL_ZC_SUM,
                 TOTAL_ZC_AMT,
                 TOTAL_CX_SUM,
                 TOTAL_CX_AMT,
                 TOTAL_TH_SUM,
                 TOTAL_TH_AMT,
                 INSERT_DATE,
                 LAST_CHECK_TIME,
                 PROC_STATE,
                 JS_STATE,
                 REMIT_NO,
                 JS_user_ID,
                 JS_DATE,
                 deal_NO,
                 DZPZLX)
              values(check_id,
                 lv_base_co_org_id.org_id,
                 av_co_org_id,
                 av_acpt_id,
                 av_check_type,
                 av_check_filenmae,
                 av_check_date,
                 0,
                 0,
                 0,
                 0,
                 0,
                 av_check_th_sum,
                 av_check_th_amt,
                 sysdate,
                 sysdate,
                 1,
                 0,
                 null,
                 null,
                 null,
                 lv_action_no,
                 '03'
                 );
                 --��ʼ����
                 if sys_zc_count <> av_check_zc_sum or sys_zc_amt <> av_check_zc_amt
                    or sys_th_count <> av_check_th_sum or sys_th_amt <> av_check_th_amt
                    then
                    --���˲�ƽ
                    update PAY_CO_CHECK_SINGLE t set t.proc_state ='2',t.last_check_time = sysdate where t.id = check_id;
                 else
                   update PAY_CO_CHECK_SINGLE t set t.proc_state ='0',t.dzpzlx = '01',t.last_check_time = sysdate where t.id = check_id;
                   --����ƽֱ�Ӹ������յĶ��˺�ƽ�˱���
                    UPDATE PAY_CO_CHECK_SINGLE t SET t.sj_total_zc_sum =  av_check_zc_sum , t.sj_total_zc_amt = av_check_zc_amt,
                      t.sj_total_cx_sum =0 ,t.sj_total_cx_amt = 0, t.sj_total_th_sum = av_check_th_sum,
                      t.sj_total_th_amt = av_check_th_amt WHERE t.id = check_id;

                 end if;
        EXCEPTION
          WHEN OTHERS THEN
            av_res := pk_public.cs_res_dberr;
            av_msg := '���ݿ�δ֪����'||sqlerrm;
       END p_check_bill;

  /*=======================================================================================*/
  --��������������ϸ���
  /*=======================================================================================*/

  procedure p_check_bill_implist(av_co_org_id IN base_co_org.co_org_id%TYPE, --�����������
                       av_acpt_id IN VARCHAR2, --����������
                       av_termid in varchar2,--�ն˺�
                       av_trbatchno in varchar2,--���κ�
                       av_trserno in varchar2,--�ն���ˮ
                       av_cardno in varchar2,-- ����
                       av_bank_id in varchar2,--���б��
                       av_bank_acc in varchar2,--�����˻�
                       av_cr_card_no in varchar2,--ת�뿨����
                       av_cr_acc_kind in varchar2,--ת���˻�����
                       av_db_card_no in varchar2,--ת��������
                       av_db_acc_kind in varchar2,--ת���˻�����
                       av_acc_bal in varchar2,--����ǰ���
                       av_deal_count in varchar2,--�������
                       av_tramt  in number,--���׽��
                       av_trdate in varchar2,--yyyy-mm-dd hh24:mi:ss
                       av_actionno in number,
                       av_clrdate in varchar2,--yyyy-mm-dd
                       av_co_clrdate in varchar2, --yyyy-mm-dd
                       av_file_line in varchar2,
                       av_deal_code IN VARCHAR2,-- ���״���
                       av_res      OUT VARCHAR2, --��������
                       av_msg      OUT VARCHAR2 --����������Ϣ
                       ) is
           datenow  DATE;
           deal_actionno varchar2(22);
           lv_pay_co_check_single   PAY_CO_CHECK_SINGLE%rowtype;
           lv_count number;
           lv_count2 number;
           lv_tablename varchar2(50);
           lv_deal_code varchar2(8) := '60400210';
           lv_action_no varchar2(50);
           begin
             select sysdate into datenow from dual;
             select * into lv_pay_co_check_single from PAY_CO_CHECK_SINGLE t
                    where t.co_org_id = av_co_org_id and t.check_date = replace(av_clrdate, '-', '');

              /*if lv_pay_co_check_single.PROC_STATE <> '2' then
                  av_res:=0;
                  av_msg:='������ϸ�ϴ�ʧ�� '||av_actionno;
                  return;
              end if;*/

              --��������
              lv_tablename:= 'acc_inout_detail_'||substr(av_clrdate,1,4)||substr(av_clrdate,6,2);
              EXECUTE IMMEDIATE
                   'select count(*) from '|| lv_tablename||
                   ' where deal_no = :1 and clr_date =:2 and deal_state = ''0'''
                    into lv_count
                 USING av_actionno,av_clrdate;
              
              --�Ҽ�¼   
              select count(*) into lv_count2 from acc_inout_detail where deal_no = av_actionno and clr_date = av_clrdate and deal_state = '9';

              --���������־
              select seq_action_no.nextval into deal_actionno from dual;
              insert into sys_action_log(deal_no,
                                         deal_code,
                                         org_id,
                                         brch_id,
                                         user_id,
                                         deal_time,
                                         log_type,
                                         message,
                                         ip,
                                         in_out_data,
                                         note)
                                      values(
                                         deal_actionno,
                                         lv_deal_code,
                                         lv_pay_co_check_single.card_org_id,
                                         '',
                                         'admin',
                                         sysdate,
                                         '0',
                                         '�ϴ�������ϸ',
                                         null,
                                         null,
                                         '�ϴ�������ϸ'
                                      );
              --�м�¼
              if lv_count > 0 then
                --�в����ϵͳ���ڼ�¼
                select count(*) into lv_count from pay_co_check_list where deal_no = av_actionno and clr_date = av_clrdate;
                if lv_count=0 then
                 select SEQ_COOPER_CHECK_LIST_ID.NEXTVAL into lv_action_no from dual;
                  EXECUTE IMMEDIATE
                   'insert into pay_co_check_list_temp(id,
                                                      fileid,
                                                      file_line_no,
                                                      org_id,
                                                      co_org_id,
                                                      acpt_id,
                                                      end_id,
                                                      deal_batch_no,
                                                      end_deal_no,
                                                      bank_id,
                                                      bank_acc,
                                                      card_no,
                                                      acc_kind,
                                                      card_no2,
                                                      acc_kind2,
                                                      amt,
                                                      amtbef,
                                                      purseserial,
                                                      old_action_no,
                                                      state,
                                                      oper_state,
                                                      user_id,
                                                      bz,
                                                      deal_no,
                                                      oper_type,
                                                      oper_date,
                                                      deal_date,
                                                      deal_user_id,
                                                      clr_date,
                                                      co_clr_date,
                                                      deal_code)
                                                      select
                                                      :1,
                                                      :2,
                                                      :3,
                                                      :4,
                                                      :5,
                                                      acpt_id,
                                                      user_id,
                                                      DEAL_BATCH_NO,
                                                      END_DEAL_NO,
                                                      :6,
                                                      :7,
                                                      cr_card_no,
                                                      cr_acc_kind,
                                                      db_card_no,
                                                      db_acc_kind,
                                                      cr_amt,
                                                      CR_CARD_BAL,
                                                      CR_CARD_COUNTER,
                                                      deal_no,
                                                      0,
                                                      1,
                                                      ''admin'',
                                                      ''ϵͳƥ���ϵ���ϸ'',
                                                      :8,
                                                      ''05'',
                                                      :9,
                                                      :10,
                                                      ''admin'',
                                                      :11,
                                                      :12,
                                                      deal_code
                                                      from '||lv_tablename|| ' where deal_no =:13'
                                        using lv_action_no,lv_pay_co_check_single.id,av_file_line,
                                               lv_pay_co_check_single.card_org_id,lv_pay_co_check_single.co_org_id,
                                               av_bank_id,av_bank_acc,deal_actionno,sysdate,to_date(av_trdate, 'yyyy-mm-dd hh24:mi:ss'),av_clrdate, av_co_clrdate,av_actionno;

                end if;
              --�лҼ�¼
              elsif lv_count2 > 0 then
                select count(*) into lv_count from pay_co_check_list where deal_no = av_actionno and clr_date = av_clrdate;
                if lv_count = 0 then
                 select SEQ_COOPER_CHECK_LIST_ID.NEXTVAL into lv_action_no from dual;
                  EXECUTE IMMEDIATE
                   'insert into pay_co_check_list_temp(id,
                                                      fileid,
                                                      file_line_no,
                                                      org_id,
                                                      co_org_id,
                                                      acpt_id,
                                                      end_id,
                                                      deal_batch_no,
                                                      end_deal_no,
                                                      bank_id,
                                                      bank_acc,
                                                      card_no,
                                                      acc_kind,
                                                      card_no2,
                                                      acc_kind2,
                                                      amt,
                                                      amtbef,
                                                      purseserial,
                                                      old_action_no,
                                                      state,
                                                      oper_state,
                                                      user_id,
                                                      bz,
                                                      deal_no,
                                                      oper_type,
                                                      oper_date,
                                                      deal_date,
                                                      deal_user_id,
                                                      clr_date,
                                                      co_clr_date,
                                                      deal_code)
                                                      select
                                                      :1,
                                                      :2,
                                                      :3,
                                                      :4,
                                                      :5,
                                                      acpt_id,
                                                      user_id,
                                                      DEAL_BATCH_NO,
                                                      END_DEAL_NO,
                                                      :6,
                                                      :7,
                                                      cr_card_no,
                                                      cr_acc_kind,
                                                      db_card_no,
                                                      db_acc_kind,
                                                      cr_amt,
                                                      CR_CARD_BAL,
                                                      CR_CARD_COUNTER,
                                                      deal_no,
                                                      3,
                                                      0,
                                                      ''admin'',
                                                      ''ϵͳƥ���ϵ���ϸ'',
                                                      :8,
                                                      null,
                                                      :9,
                                                      :10,
                                                      ''admin'',
                                                      :11,
                                                      :12,
                                                      deal_code
                                                      from acc_inout_detail where deal_no =:13 and deal_state = ''9'''
                                        using lv_action_no,lv_pay_co_check_single.id,av_file_line,
                                               lv_pay_co_check_single.card_org_id,lv_pay_co_check_single.co_org_id,
                                               av_bank_id,av_bank_acc,deal_actionno,sysdate,to_date(av_trdate, 'yyyy-mm-dd hh24:mi:ss'),av_clrdate, av_co_clrdate,av_actionno;

                end if;
              else
                --û��������ϴ���¼
                 insert into pay_co_check_list_temp(id,
                                                      fileid,
                                                      file_line_no,
                                                      org_id,
                                                      co_org_id,
                                                      acpt_id,
                                                      end_id,
                                                      deal_batch_no,
                                                      end_deal_no,
                                                      bank_id,
                                                      bank_acc,
                                                      card_no,
                                                      acc_kind,
                                                      card_no2,
                                                      acc_kind2,
                                                      amt,
                                                      amtbef,
                                                      purseserial,
                                                      old_action_no,
                                                      state,
                                                      oper_state,
                                                      user_id,
                                                      bz,
                                                      deal_no,
                                                      OPER_TYPE,
                                                      OPER_DATE,
                                                      deal_date,
                                                      deal_user_id,
                                                      clr_date,
                                                      co_clr_date,
                                                      deal_code)
                                                      values(
                                                      SEQ_COOPER_CHECK_LIST_ID.Nextval,
                                                      lv_pay_co_check_single.id,
                                                      av_file_line,
                                                      lv_pay_co_check_single.card_org_id,
                                                      lv_pay_co_check_single.co_org_id,
                                                      av_acpt_id,
                                                      av_termid,
                                                      av_trbatchno,
                                                      av_trserno,
                                                      av_bank_id,
                                                      av_bank_acc,
                                                      av_cr_card_no,
                                                      av_cr_acc_kind,
                                                      av_db_card_no,
                                                      av_db_acc_kind,
                                                      av_tramt,
                                                      av_acc_bal,
                                                      av_deal_count,
                                                      av_actionno,
                                                      2,
                                                      0,
                                                      'admin',
                                                      'ϵͳƥ���ϵ���ϸ',
                                                      deal_actionno,
                                                      null,
                                                      sysdate,
                                                      to_date(av_trdate, 'yyyy-mm-dd hh24:mi:ss'),
                                                      'admin',
                                                      av_clrdate,
                                                      av_co_clrdate,
                                                      av_deal_code);
              end if;
              av_res := pk_public.cs_res_ok;
          EXCEPTION
          WHEN OTHERS THEN
            av_res := pk_public.cs_res_dberr;
            av_msg := '���ݿ�δ֪����'||sqlcode||sqlerrm;
  end p_check_bill_implist;
   /*=======================================================================================*/
  --��������������ϸ����
  /*=======================================================================================*/

    PROCEDURE  p_check_list_bill(av_co_org_id  IN base_co_org.co_org_id%TYPE,--��������
                               av_acpt_id   IN VARCHAR2,--����������
                               av_clr_date IN VARCHAR2,--�������� yyyymmdd
                               av_res      OUT VARCHAR2, --��������
                               av_msg      OUT VARCHAR2 --����������Ϣ
                               )IS
      ln_count NUMBER;
      ln_amt number;
      ln_pay_co_bill_sign pay_co_check_single%ROWTYPE;
      lv_talbe_name VARCHAR2(50);
      lv_talbe_name2 VARCHAR2(50);
      zcsc_num number;--�ϴ��������ױ���
      zcsc_amt number;--�ϴ��������׽��
      lv_TOTAL_ZCFROMADD_SUM  NUMBER(16);--������������������ױ���
      lv_TOTAL_ZCFROMADD_AMT  NUMBER(16);--������������������׽��
      lv_TOTAL_CXFROMADD_SUM  NUMBER(16);--������������������ױ���
      lv_TOTAL_CXFROMADD_AMT  NUMBER(16);--������������������׽��
      lv_TOTAL_THFROMADD_SUM  NUMBER(16);--������������˻����ױ���
      lv_TOTAL_THFROMADD_AMT  NUMBER(16);--������������˻����׽��
      lv_TOTAL_ZCTOADD_NUM  NUMBER(16);--��Ӫ��������������ױ���
      lv_TOTAL_ZCTOADD_AMT  NUMBER(16);--��Ӫ��������������׽��
      lv_TOTAL_CXTOADD_NUM  NUMBER(16);--��Ӫ��������������ױ���
      lv_TOTAL_CXTOADD_AMT  NUMBER(16);--��Ӫ��������������׽��
      lv_TOTAL_THTOADD_NUM  NUMBER(16);--��Ӫ��������˻����ױ���
      lv_TOTAL_THTOADD_AMT  NUMBER(16);--��Ӫ��������˻����׽��
      BEGIN
        SELECT COUNT(1) INTO ln_count FROM dual;

         --�ж��Ƿ���ڶ�����Ϣ
         SELECT COUNT(1) INTO ln_count FROM pay_co_check_single t  WHERE t.CO_ORG_ID = av_co_org_id AND t.acpt_id = av_acpt_id
         AND t.check_date  = av_clr_date;
        IF ln_count = 0  THEN
           av_res := pk_public.cs_res_co_check_bill_nomsg;
           av_msg := '������Ϣ������';
        END IF ;
        
        select * into ln_pay_co_bill_sign FROM pay_co_check_single t  WHERE t.CO_ORG_ID = av_co_org_id AND t.acpt_id = av_acpt_id
         AND t.check_date  = av_clr_date;

        --�ж��Ƿ��Ѿ������˶���
         /*SELECT COUNT(1) INTO ln_count FROM pay_co_check_single t WHERE t.CO_ORG_ID = av_co_org_id AND t.acpt_id = av_acpt_id
         AND t.check_date  = av_clr_date AND  t.proc_state IN('0','1','3');

         IF ln_count > 0   THEN  --���ɷ����ظ�����
            av_res := pk_public.cs_res_co_check_bill_rep;
            av_msg := '�����ظ�����';
            return;
         END IF;*/

        -- 1������ʱ��ļ�¼������˼�¼��
        INSERT INTO pay_co_check_list SELECT * FROM pay_co_check_list_temp b WHERE b.fileid = ln_pay_co_bill_sign.id;

        ---2, �������񿨶�������ݵ�������ϸ��
        lv_talbe_name := 'acc_inout_detail_'||substr(av_clr_date,1,6);
        lv_talbe_name2 := 'PAY_CARD_DEAL_REC_'||substr(av_clr_date,1,6);
        EXECUTE IMMEDIATE  'insert into pay_co_check_list select
                                      SEQ_COOPER_CHECK_LIST_ID.Nextval,
                                      :1,
                                      null,
                                      card_org_id,
                                      acpt_org_id,
                                      acpt_id,
                                      user_id,
                                      deal_batch_no,
                                      end_deal_no,
                                      null,
                                      null,
                                      cr_card_no,
                                      cr_acc_kind,
                                      null,
                                      db_card_no,
                                      db_acc_kind,
                                      cr_amt,
                                      CR_ACC_BAL,
                                      CR_CARD_COUNTER,
                                      deal_no,
                                      ''1'',
                                      ''0'',
                                      ''admin'',
                                      ''��Ӫ�������˶������'',
                                      null,
                                      null,
                                      a1.deal_date,
                                      a1.user_id,
                                      null,
                                      :2,
                                      :3,
                                      null,
                                      deal_code from '||lv_talbe_name||' a1 where a1.clr_date =:4 and deal_state = ''0'' and acpt_id =:5 and exists
                                      (SELECT 1
                                       FROM '||lv_talbe_name2||' A2
                                       WHERE A2.DEAL_NO = A1.DEAL_NO and posp_proc_state is null) and not exists (select 1 from pay_co_check_list where old_action_no = a1.deal_no)'
                                USING ln_pay_co_bill_sign.id,substr(av_clr_date,1,4)||'-'||substr(av_clr_date,5,2)||'-'||substr(av_clr_date,7,2), substr(av_clr_date,1,4)||'-'||substr(av_clr_date,5,2)||'-'||substr(av_clr_date,7,2),
                                      substr(av_clr_date,1,4)||'-'||substr(av_clr_date,5,2)||'-'||substr(av_clr_date,7,2), ln_pay_co_bill_sign.co_org_id;
       ---3, �޸Ķ����ܱ������

       --����ǳ�ֵ���ˣ�
       IF ln_pay_co_bill_sign.file_type ='01' THEN
         -- ͳ�������������
          SELECT COUNT(1),SUM(t.amt) INTO zcsc_num, zcsc_amt
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='0' AND t.deal_code  IN ('30105010','30105020');
         -- ͳ������������������ı���
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_ZCFROMADD_SUM,lv_TOTAL_ZCFROMADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='2' AND t.deal_code  IN ('30105010','30105020');
         -- ͳ��������Ӫ�����������
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_ZCTOADD_NUM,lv_TOTAL_ZCTOADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='1' AND t.deal_code IN ('30105010','30105020');
        /* -- ͳ�Ƴ���������������ı���
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_CXFROMADD_SUM,lv_TOTAL_CXFROMADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='1' AND t.deal_code  IN
                 (SELECT deal_code FROM sys_code_tr WHERE VOUCHER_TITLE = '03');
         -- ͳ�Ƴ�����Ӫ�����������
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_CXTOADD_NUM,lv_TOTAL_CXTOADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='2' AND t.deal_code  IN
                 (SELECT deal_code FROM sys_code_tr WHERE VOUCHER_TITLE = '03');*/
         -- ���¶��˱��¼
         UPDATE pay_co_check_single a SET TOTAL_ZC_SUM = zcsc_num, TOTAL_ZC_AMT = zcsc_amt, a.total_zcfromadd_sum = lv_TOTAL_ZCFROMADD_SUM ,
                a.total_zcfromadd_amt =  lv_TOTAL_ZCFROMADD_AMT,a.total_zctoadd_num = lv_TOTAL_ZCTOADD_NUM,
                a.total_zctoadd_amt =  lv_TOTAL_ZCTOADD_AMT  WHERE a.id =ln_pay_co_bill_sign.id;

         -- ���� pay_card_deal_rec_xx ����״̬
         EXECUTE IMMEDIATE 'update ' || lv_talbe_name2 || ' t set posp_proc_state = ''0'' 
                 where deal_state = ''0'' 
                 and exists 
                 (select 1 from pay_co_check_list 
                         where oper_state = ''1'' 
                         and old_action_no = t.deal_no 
                         and fileid = :1)'
         USING ln_pay_co_bill_sign.id;
         
         select count(*), sum(t.amt) into ln_count, ln_amt from pay_co_check_list t where t.fileid = ln_pay_co_bill_sign.id;
         if ln_count = zcsc_num and ln_amt = zcsc_amt then
            update pay_co_check_single a set a.proc_state = '0', DZPZLX = '01', SJ_TOTAL_ZC_SUM = zcsc_num, SJ_TOTAL_ZC_AMT = zcsc_amt WHERE a.id =ln_pay_co_bill_sign.id;
         else
            update pay_co_check_single a set a.proc_state = '3' WHERE a.id =ln_pay_co_bill_sign.id;
         end if;
       END IF;

       /*IF ln_pay_co_bill_sign.file_type ='02' THEN
         -- ͳ������������������ı���
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_ZCFROMADD_SUM,lv_TOTAL_ZCFROMADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='1' AND t.deal_code  IN
                 (SELECT deal_code FROM sys_code_tr WHERE VOUCHER_TITLE = '07');
         -- ͳ��������Ӫ�����������
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_ZCTOADD_NUM,lv_TOTAL_ZCTOADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='2' AND t.deal_code  IN
                 (SELECT deal_code FROM sys_code_tr WHERE VOUCHER_TITLE = '07');
          -- ͳ�Ƴ���������������ı���
          SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_CXFROMADD_SUM,lv_TOTAL_CXFROMADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='1' AND t.deal_code  IN
                 (SELECT deal_code FROM sys_code_tr WHERE VOUCHER_TITLE = '08');
         -- ͳ�Ƴ�����Ӫ�����������
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_CXTOADD_NUM,lv_TOTAL_CXTOADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='2' AND t.deal_code  IN
                 (SELECT deal_code FROM sys_code_tr WHERE VOUCHER_TITLE = '08');
         -- ���¶��˱��¼
         UPDATE pay_co_check_single a SET a.total_zcfromadd_sum = lv_TOTAL_ZCFROMADD_SUM ,
                a.total_zcfromadd_amt =  lv_TOTAL_ZCFROMADD_AMT,a.total_zctoadd_num = lv_TOTAL_ZCTOADD_NUM,
                a.total_zctoadd_amt =  lv_TOTAL_ZCTOADD_AMT , a.total_cxfromadd_sum  = lv_TOTAL_CXFROMADD_SUM,
                a.total_cxfromadd_amt  = lv_TOTAL_ZCTOADD_AMT WHERE a.id =ln_pay_co_bill_sign.id;

        END IF;*/


        IF ln_pay_co_bill_sign.file_type ='03' THEN
         -- ͳ������������������ı���
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_ZCFROMADD_SUM,lv_TOTAL_ZCFROMADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='1' AND t.deal_code  IN ('40202010','40102010');
         -- ͳ��������Ӫ�����������
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_ZCTOADD_NUM,lv_TOTAL_ZCTOADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='2' AND t.deal_code  IN ('40202010','40102010');
        /* -- ͳ�Ƴ���������������ı���
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_CXFROMADD_SUM,lv_TOTAL_CXFROMADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='1' AND t.deal_code  IN
                 (SELECT deal_code FROM sys_code_tr WHERE VOUCHER_TITLE = '06');
         -- ͳ�Ƴ�����Ӫ�����������
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_CXTOADD_NUM,lv_TOTAL_CXTOADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='2' AND t.deal_code  IN
                 (SELECT deal_code FROM sys_code_tr WHERE VOUCHER_TITLE = '06');*/
         -- ͳ���˻�������������ı���
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_THFROMADD_SUM,lv_TOTAL_THFROMADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='1' AND t.deal_code  IN ('40102051','40202051');
         -- ͳ���˻���Ӫ�����������
         SELECT COUNT(1),SUM(t.amt) INTO lv_TOTAL_THTOADD_NUM,lv_TOTAL_THTOADD_AMT
                 FROM pay_co_check_list t WHERE t.fileid = ln_pay_co_bill_sign.id
                 AND t.state ='2' AND t.deal_code  IN ('40102051','40202051');

         -- ���¶��˱��¼
         UPDATE pay_co_check_single a SET a.total_zcfromadd_sum = lv_TOTAL_ZCFROMADD_SUM ,
                a.total_zcfromadd_amt =  lv_TOTAL_ZCFROMADD_AMT,a.total_zctoadd_num = lv_TOTAL_ZCTOADD_NUM,
                a.total_zctoadd_amt =  lv_TOTAL_ZCTOADD_AMT ,a.total_thfromadd_sum  = lv_TOTAL_THFROMADD_SUM,
                a.total_thfromadd_amt  = lv_TOTAL_THTOADD_AMT,a.total_thtoadd_num  = lv_TOTAL_THTOADD_NUM,
                a.total_thtoadd_amt = lv_TOTAL_THTOADD_AMT
                WHERE a.id =ln_pay_co_bill_sign.id;
        END IF;
        av_res := pk_public.cs_res_ok;
       EXCEPTION
          WHEN OTHERS THEN
            av_res := pk_public.cs_res_dberr;
            av_msg := '['||sqlcode||']'||sqlerrm;
      END p_check_list_bill;
end pk_co_org_handle;
/

