CREATE OR REPLACE PACKAGE BODY pk_merchantsettle IS
  --消费交易码已401001 和 402001开头

  /*=======================================================================================*/
  --按照清分开始结束日期结算
  /*=======================================================================================*/
  PROCEDURE p_settle(av_stlmode   stl_mode%ROWTYPE, --结算模式表
                     av_merchant  IN base_merchant%ROWTYPE, --商户
                     av_operid    IN sys_users.user_id%TYPE, --柜员编号
                     av_begindate IN pay_clr_sum.clr_date%TYPE, --清分开始日期
                     av_enddate   IN pay_clr_sum.clr_date%TYPE, --清分结束日期
                     av_type      IN VARCHAR2, --1:--全额轧差 21:全部不轧差 消费 22:全部不轧差 退货 23:全部不轧差 手续费 31:消费退货轧差手续费不轧差 消费退货 32:消费退货轧差手续费不轧差 手续费 41:消费手续费轧差退货不轧差 消费手续费 42:消费手续费轧差退货不轧差 退货
                     av_res       OUT VARCHAR2, --传出代码
                     av_msg       OUT VARCHAR2, --传出错误信息
                     av_jsrq      IN VARCHAR2 DEFAULT NULL --结算日期 即时结算时取当前清分日期，否则传入null取结束日期下一天
                     ) IS
    ls_jsrq         CHAR(10) := NULL;
    lv_stlsumno     stl_deal_sum.stl_sum_no%TYPE; --汇总序号
    lv_feerate      pay_fee_rate%ROWTYPE; --费率
    lv_stltradelist stl_deal_list%ROWTYPE; --结算明细
    lv_operid       sys_users.user_id%TYPE;
    --计算服务费并计算机构分成
    PROCEDURE p_setfee(as_trcode stl_deal_list.deal_code%TYPE) IS
      ln_jgfc  NUMBER;
      ln_count NUMBER;
      --in_fdamt NUMBER := 0;
      --in_fee_rate number := 0;
    BEGIN
      --获取费率
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
      --费率类型1笔数费率2金额费率3固定服务费 fee_rate  费率，统一除10000
      IF lv_feerate.fee_type = '1' THEN
        --如果存在按笔数分段收取服务费
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
        --结束按笔数分段收取服务费

      ELSIF lv_feerate.fee_type = '2' THEN
        --如果存在按金额分段收取手续费
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
        --结束按金额分段收取手续费
      ELSIF lv_feerate.fee_type = '3' THEN
        lv_stltradelist.fee_amt := lv_feerate.fee_rate / 10000; --固定费用直接取
      ELSE
        lv_stltradelist.fee_amt := 0;
      END IF;
      /*
      -- 最大服务费
      lv_stltradelist.fee_amt := least(lv_stltradelist.fee_amt,
                                         lv_feerate.fee_max);
      -- 最小服务费
      lv_stltradelist.fee_amt := greatest(lv_stltradelist.fee_amt,
                                            lv_feerate.fee_min);
      */
      IF lv_feerate.in_out = '1' THEN
        lv_stltradelist.fee_amt := -abs(lv_stltradelist.fee_amt);
      END IF;
     /* IF   lv_stltradelist.deal_code = '40201051' or lv_stltradelist.deal_code = '40101051' THEN
        lv_stltradelist.deal_amt := -lv_stltradelist.deal_amt;
      END IF;*/
      --计算机构分成
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
      --反写结算明细中的服务费，防止金额不一致
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
          --退货
          lv_stltradelist.in_out := '1';
          lv_stltradelist.fee_amt:= 0;
          /*lv_stltradelist.deal_amt := -lv_stltradelist.deal_amt;*/
          lv_stltradelist.deal_amt := lv_stltradelist.deal_amt;
        ELSE
          lv_stltradelist.in_out := '0';
        END IF;
      WHEN OTHERS THEN
        av_res := -1;
        av_msg := nvl(av_msg, '计算服务费发生错误:') || SQLERRM;
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
    --获取汇总序号
    SELECT seq_stl_sum_no.nextval INTO lv_stlsumno FROM dual;
    --1:--全额轧差 21:全部不轧差 消费 22:全部不轧差 退货 23:全部不轧差 手续费 31:消费退货轧差手续费不轧差 消费退货 32:消费退货轧差手续费不轧差 手续费 41:消费手续费轧差退货不轧差 消费手续费 42:消费手续费轧差退货不轧差 退货
    IF av_type IN ('1', '21', '31', '41') THEN
      --消费
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
      --退货
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
      --手续费
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
      --结算明细
      SELECT seq_list_no.nextval INTO lv_stltradelist.list_no FROM dual;
      lv_stltradelist.stl_sum_no := lv_stlsumno; --stl_sum_no  结算汇总序号
      lv_stltradelist.deal_code    := lrec_clr.deal_code; --tr_code  交易代码
      lv_stltradelist.card_type  := lrec_clr.card_type; --卡类型
      lv_stltradelist.acc_kind   := lrec_clr.acc_kind; --账户类型
      lv_stltradelist.oth_fee    := 0;
      lv_stltradelist.deal_num     := lrec_clr.deal_num;
      lv_stltradelist.deal_amt     := lrec_clr.deal_amt;
      IF av_type IN ('1', '23', '32', '41') THEN
        p_setfee(lrec_clr.deal_code); --计算服务费和费率代码、收支标志
      ELSE
        p_setfee(lrec_clr.deal_code); --计算服务费和费率代码、收支标志
      END IF;
      IF av_type IN ('23', '32') THEN
        lv_stltradelist.deal_num := 0;
        lv_stltradelist.deal_amt := '0';
      END IF;
      INSERT INTO stl_deal_list VALUES lv_stltradelist;
    END LOOP;
    --插入结算汇总数据
    INSERT INTO stl_deal_sum
      (stl_sum_no, --汇总序号
       stl_date, --结算日期
       merchant_id, --商户编码
       merchant_name, --商户名称
       stl_days, --结算周期
       --stl_times, --结算次数
       deal_num, --总笔数
       deal_amt, --总金额
       deal_fee, --服务费
       stl_amt, --结算金额
       --stl_p_amt, --已付款项
       chk_date, --对账日期
       chk_user_id, --对账人
       vrf_date, --结算确认日期
       vrf_user_id, --结算确认人
       reg_no, --回单打款序号
       --inv_flag, --是否已开票(0-是 1-否)
       --inv_bat_no, --开票批次
       user_id, --生成柜员
       oper_date, --生成日期
       stl_state, --结算状态(0-已生成 1-已对帐 2-结算确认 3-已打款 4 打款已确认)
       note, --备注
       --card_org_id, --发卡机构
       th_num,
       th_amt, --退货金额
       card_type, --卡类型
       acc_kind, --账户类型
       begin_date, --开始日期
       end_date,
       stl_mode,
       stl_way)
      SELECT lv_stlsumno, --汇总序号
             ls_jsrq, --结算日期
             av_merchant.merchant_id, --商户编码
             av_merchant.merchant_name, --商户名称
             0, --结算周期
             --1, --结算次数
             nvl(SUM(deal_num), 0), --总笔数
             CASE
               WHEN av_type = '41' THEN
                --nvl(SUM(decode(substrb(deal_code, 1, 3), '811', 0, deal_amt)), 0) --总金额
                nvl(sum(decode(deal_code,'40201051',0,'40101051',0,deal_amt)),0) --总金额
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
             END stl_amt, --nvl(sum(decode(tr_code, '2834', -1, 1) * (nvl(tr_amt, 0) - nvl(fee_amt, 0))),0), --结算金额
             --0, --已付款项
             NULL, --对账日期
             NULL, --对账人
             NULL, --结算确认日期
             NULL, --结算确认人
             NULL, --回单打款序号
             --'1', --是否已开票(0-是 1-否)
             --null, --开票批次
             lv_operid, --生成柜员
             SYSDATE, --生成日期
             '0', --结算状态
             NULL, --备注
             --'1001', --发卡机构
             nvl(SUM(decode(in_out, '1', deal_num, 0)), 0),
             nvl(SUM(decode(in_out, '1', deal_amt, 0)), 0),
             card_type, --卡类型
             acc_kind, --账户类型
             av_begindate, --开始日期
             av_enddate, --结束日期
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
      av_msg := nvl(av_msg, '商户结算发生错误:') || SQLERRM;
  END p_settle;

  /*=======================================================================================*/
  --对一商户进行结算
  /*=======================================================================================*/
  PROCEDURE p_settle(av_bizid  IN base_merchant.merchant_id%TYPE, --商户号
                     av_operid IN sys_users.user_id%TYPE, --结算柜员
                     av_res    OUT VARCHAR2, --传出代码
                     av_msg    OUT VARCHAR2 --传出错误信息
                     ) IS
    lv_merchant  base_merchant%ROWTYPE; --商户信息
    lv_begindate VARCHAR2(10) := NULL; --清分开始日期
    lv_enddate   VARCHAR2(10) := NULL; --清分结束日期
    lv_sum       NUMBER;
    lv_stlmode   stl_mode%ROWTYPE; --结算模式表
    lv_operid    sys_users.user_id%TYPE;
    --取结算模式
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
    --取未结算金额
    FUNCTION f_getsum(av_type      VARCHAR2,
                      av_begindate VARCHAR2,
                      av_enddate   VARCHAR2) RETURN NUMBER IS
    BEGIN
      IF av_type = '1' THEN
        --全额轧差
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE merchant_id = lv_merchant.merchant_id
           AND (stl_sum_no IS NULL OR fee_stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '21' THEN
        --全部不轧差 消费
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate
           AND deal_code IN ('40101010','40201010') ; --消费
      ELSIF av_type = '22' THEN
        --全部不轧差 退货
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate
           AND deal_code IN ('40102051','40201051') ; --退货
      ELSIF av_type = '23' THEN
        --全部不轧差 手续费
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (fee_stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '31' THEN
        --消费退货轧差手续费不轧差 消费退货
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '32' THEN
        --消费退货轧差手续费不轧差 手续费
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (fee_stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate;
      ELSIF av_type = '41' THEN
        --消费手续费轧差退货不轧差 消费手续费
        SELECT SUM(deal_amt)
          INTO lv_sum
          FROM pay_clr_sum
         WHERE  merchant_id = lv_merchant.merchant_id
           AND (stl_sum_no IS NULL)
           AND clr_date >= av_begindate
           AND clr_date <= av_enddate
           AND deal_code IN ('40101010','40201010');
      ELSIF av_type = '42' THEN
        --消费手续费轧差退货不轧差 退货
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
    --判断是否到达结算条件 限额结时先取lv_sum再调用
    FUNCTION f_canstl(as_clrdate     VARCHAR2,
                      as_lastclrdate VARCHAR2,
                      as_stlway      VARCHAR2,
                      as_stldays     VARCHAR2,
                      an_limit       NUMBER) RETURN VARCHAR2 IS
      ls_days  pk_public.myarray;
      ln_count NUMBER;
    BEGIN
      --消费结算方式01-日结 02-限额结 03-周结 04 月结05日结+月结 06限额结+月结
      IF as_stlway IN ('01', '05') THEN
        --日结、日结+月结
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
        --限额结
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
        --周结
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
        --月结
        ln_count := pk_public.f_splitstr(as_stldays, '|', ls_days);
        FOR i IN 1 .. ln_count LOOP
          IF to_number(substr(as_clrdate, 9, 2)) = to_number(ls_days(i)) --日子相同
             OR ls_days(i) = 32 AND --或设置月底结算并且是月底
             to_date(as_clrdate, 'yyyy-mm-dd') =
             last_day(to_date(as_clrdate, 'yyyy-mm-dd')) THEN
            RETURN '1';
          END IF;
        END LOOP;
      ELSIF as_stlway = '07' THEN
        --季结
        IF substrb(as_clrdate, 6, 5) IN
           ('03-31', '06-30', '09-30', '12-31') THEN
          RETURN '1';
        END IF;
      END IF;
      --没到结算条件
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
    --取结算开始日期
    PROCEDURE p_setbegindate(trcode VARCHAR2) IS
      xf  VARCHAR2(50);
      th  VARCHAR2(50);
      sxf VARCHAR(50);
    BEGIN
      IF lv_begindate IS NULL THEN
        --取上一次结算日期 到 lv_begindate
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
    --取下一个结算开始结束日期
    PROCEDURE p_setnextbeginenddate IS
      ls_days  pk_public.myarray;
      ln_count NUMBER;
    BEGIN
      --开始日期
      IF lv_begindate IS NULL THEN
        --取上一次结算日期 到 lv_begindate
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
      --结束日期
      IF lv_begindate IS NOT NULL THEN
        IF lv_stlmode.stl_way IN ('02', '06') THEN
          --限额结、限额结+月结
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
              --限额结+月结
              IF lv_enddate =
                 to_char(last_day(to_date(lv_begindate, 'yyyy-mm-dd')),
                         'yyyy-mm-dd') THEN
                --到月底，结算
                RETURN;
              END IF;
            END IF;
            lv_enddate := to_char(to_date(lv_enddate, 'yyyy-mm-dd') + 1,
                                  'yyyy-mm-dd');
          END LOOP;
        ELSIF lv_stlmode.stl_way = '03' THEN
          --周结 lv_merchant.stl_days 1-7
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
          --月结
          ln_count   := pk_public.f_splitstr(lv_stlmode.stl_way,
                                             '|',
                                             ls_days);
          lv_enddate := lv_begindate;
          WHILE lv_enddate < to_char(1 + SYSDATE, 'yyyy-mm-dd') LOOP
            FOR i IN 1 .. ln_count LOOP
              IF to_number(substr(lv_enddate, 9, 2)) =
                 to_number(ls_days(i)) --日子相同
                 OR ls_days(i) = 32 AND --或设置月底结算并且是月底
                 to_date(lv_enddate, 'yyyy-mm-dd') =
                 last_day(to_date(lv_enddate, 'yyyy-mm-dd')) THEN
                RETURN;
              END IF;
            END LOOP;
            lv_enddate := to_char(to_date(lv_enddate, 'yyyy-mm-dd') + 1,
                                  'yyyy-mm-dd');
          END LOOP;

        ELSIF lv_stlmode.stl_way = '05' THEN
          --日结+月结
          SELECT to_char(least(to_date(lv_begindate, 'yyyy-mm-dd') +
                               lv_stlmode.stl_way - 1,
                               last_day(to_date(lv_begindate, 'yyyy-mm-dd'))),
                         'yyyy-mm-dd')
            INTO lv_enddate
            FROM dual;
        ELSE
          -- lv_merchant.stl_way = '01' then
          --其它都当做日结
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
      --循环生成结算数据
      lv_enddate := to_char(to_date(lv_begindate, 'yyyy-mm-dd') + 0,
                            'yyyy-mm-dd');
      WHILE lv_enddate < to_char(SYSDATE, 'yyyy-mm-dd') LOOP
        --取当天的结算模式
        IF f_getstlmode(lv_enddate) = '1' THEN
          --根据结算模式判断是否到达结算条件
          -- 1全部轧差2全部不轧差3消费退货轧差手续费不轧差4消费手续费轧差退货不轧差
          IF lv_stlmode.stl_mode = '1' THEN
            lv_begindate := NULL;
            p_setbegindate(1);
            --1全部轧差
            IF lv_stlmode.stl_way IN ('02', '06') THEN
              --限额
              lv_sum := f_getsum('1', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way,
                        lv_stlmode.stl_days,
                        lv_sum) = '1' THEN
              --达到结算条件
              p_settle(lv_stlmode,
                       lv_merchant, --商户号
                       lv_operid, --结算柜员
                       lv_begindate, --清分开始日期
                       lv_enddate, --清分结束日期
                       '1',
                       av_res, --错误代码 0表示正确
                       av_msg --错误原因
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
          ELSIF lv_stlmode.stl_mode = '2' THEN
            --2全部不轧差
            --2.1消费
            lv_begindate := NULL;
            p_setbegindate(21);
            IF lv_stlmode.stl_way IN ('02', '06') THEN
              --限额
              lv_sum := f_getsum('21', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way,
                        lv_stlmode.stl_days,
                        lv_sum) = '1' THEN
              --达到结算条件
              p_settle(lv_stlmode,
                       lv_merchant, --商户号
                       lv_operid, --结算柜员
                       lv_begindate, --清分开始日期
                       lv_enddate, --清分结束日期
                       '21',
                       av_res, --错误代码 0表示正确
                       av_msg --错误原因
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
            --2.2退货
            lv_begindate := NULL;
            p_setbegindate(22);
            IF lv_stlmode.stl_way_ret IN ('02', '06') THEN
              --限额
              lv_sum := f_getsum('22', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way_ret,
                        lv_stlmode.stl_way_ret,
                        lv_sum) = '1' THEN
              --达到结算条件
              p_settle(lv_stlmode,
                       lv_merchant, --商户号
                       lv_operid, --结算柜员
                       lv_begindate, --清分开始日期
                       lv_enddate, --清分结束日期
                       '22',
                       av_res, --错误代码 0表示正确
                       av_msg --错误原因
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
            --2.3手续费
            lv_begindate := NULL;
            p_setbegindate(23);
            IF lv_stlmode.stl_way_fee IN ('02', '06') THEN
              --限额
              lv_sum := f_getsum('23', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way_fee,
                        lv_stlmode.stl_way_fee,
                        lv_sum) = '1' THEN
              p_settle(lv_stlmode,
                       lv_merchant, --商户号
                       lv_operid, --结算柜员
                       lv_begindate, --清分开始日期
                       lv_enddate, --清分结束日期
                       '23',
                       av_res, --错误代码 0表示正确
                       av_msg --错误原因
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
          ELSIF lv_stlmode.stl_mode = '3' THEN
            --3消费退货轧差手续费不轧差
            --3.1消费退货
            lv_begindate := NULL;
            p_setbegindate(31);
            IF lv_stlmode.stl_way IN ('02', '06') THEN
              --限额
              lv_sum := f_getsum('31', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way,
                        lv_stlmode.stl_days,
                        lv_sum) = '1' THEN
              --达到结算条件
              p_settle(lv_stlmode,
                       lv_merchant, --商户号
                       lv_operid, --结算柜员
                       lv_begindate, --清分开始日期
                       lv_enddate, --清分结束日期
                       '31',
                       av_res, --错误代码 0表示正确
                       av_msg --错误原因
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
            --3.2手续费
            lv_begindate := NULL;
            p_setbegindate(32);
            IF lv_stlmode.stl_way_fee IN ('02', '06') THEN
              --限额
              lv_sum := f_getsum('32', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way_fee,
                        lv_stlmode.stl_days_fee,
                        lv_sum) = '1' THEN
              p_settle(lv_stlmode,
                       lv_merchant, --商户号
                       lv_operid, --结算柜员
                       lv_begindate, --清分开始日期
                       lv_enddate, --清分结束日期
                       '32',
                       av_res, --错误代码 0表示正确
                       av_msg --错误原因
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;

            END IF;
          ELSIF lv_stlmode.stl_mode = '4' THEN
            --4消费手续费轧差退货不轧差
            --4.1消费手续费
            lv_begindate := NULL;
            p_setbegindate(41);
            IF lv_stlmode.stl_way IN ('02', '06') THEN
              --限额
              lv_sum := f_getsum('41', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way,
                        lv_stlmode.stl_days,
                        lv_sum) = '1' THEN
              --达到结算条件
              p_settle(lv_stlmode,
                       lv_merchant, --商户号
                       lv_operid, --结算柜员
                       lv_begindate, --清分开始日期
                       lv_enddate, --清分结束日期
                       '41',
                       av_res, --错误代码 0表示正确
                       av_msg --错误原因
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
            --4.2退货
            lv_begindate := NULL;
            p_setbegindate(42);
            IF lv_stlmode.stl_way_ret IN ('02', '06') THEN
              --限额
              lv_sum := f_getsum('42', lv_begindate, lv_enddate);
            END IF;
            IF f_canstl(lv_enddate,
                        lv_begindate,
                        lv_stlmode.stl_way_ret,
                        lv_stlmode.stl_days_ret,
                        lv_sum) = '1' THEN
              --达到结算条件
              p_settle(lv_stlmode,
                       lv_merchant, --商户号
                       lv_operid, --结算柜员
                       lv_begindate, --清分开始日期
                       lv_enddate, --清分结束日期
                       '42',
                       av_res, --错误代码 0表示正确
                       av_msg --错误原因
                       );
              IF av_res <> 0 THEN
                RETURN;
              END IF;
            END IF;
          END IF;
        ELSE
          --没有设置结算模式
          pk_public.p_insertrzcllog('没有设置结算模式' || lv_enddate,
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
      dbms_output.put_line('错误信息：' || dbms_utility.format_error_stack);
      av_msg := av_msg || '错误信息：' || SQLERRM;
  END p_settle;

  /*=======================================================================================*/
  --对所有商户进行结算
  /*=======================================================================================*/
  PROCEDURE p_settle(av_operid IN sys_users.user_id%TYPE, --结算柜员
                     av_res    OUT VARCHAR2, --传出代码
                     av_msg    OUT VARCHAR2 --传出错误信息
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
  --对一商户进行即时结算
  /*=======================================================================================*/
  PROCEDURE p_settle_immediate(av_bizid  IN base_merchant.merchant_id%TYPE, --商户号
                               av_operid IN sys_users.user_id%TYPE, --结算柜员
                               av_res    OUT VARCHAR2, --传出代码
                               av_msg    OUT VARCHAR2 --传出错误信息
                               ) IS
    lv_merchant  base_merchant%ROWTYPE; --商户表
    lv_stlmode   stl_mode%ROWTYPE; --结算模式表
    lv_clrdate   pay_clr_para.clr_date%TYPE; --清分日期
    lv_begindate VARCHAR2(10) := NULL; --清分开始日期
    lv_enddate   VARCHAR2(10) := NULL; --清分结束日期
  BEGIN
    SELECT * INTO lv_merchant FROM base_merchant WHERE merchant_id = av_bizid;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --未清分记录进行清分
    pk_cutday.p_clr(lv_merchant.merchant_id, --商户号
                    lv_clrdate, --清分日期
                    av_res, --传出代码
                    av_msg --传出错误信息
                    );
    IF av_res <> '00' THEN
      RETURN;
    END IF;
    --所有记录进行结算
    SELECT MIN(clr_date), MAX(clr_date)
      INTO lv_begindate, lv_enddate
      FROM pay_clr_sum
     WHERE merchant_id = av_bizid
       AND (stl_sum_no IS NULL OR fee_stl_sum_no IS NULL);
    lv_enddate := lv_clrdate;
    p_settle(lv_stlmode,
             lv_merchant, --商户号
             av_operid, --结算柜员
             lv_begindate, --清分开始日期
             lv_enddate, --清分结束日期
             '1',
             av_res, --错误代码 0表示正确
             av_msg, --错误原因
             lv_clrdate);
    IF av_res <> 0 THEN
      RETURN;
    END IF;
  END p_settle_immediate;

  /*=======================================================================================*/
  --对所有商户进行结算的job
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
  --商户结算回退
  /*=======================================================================================*/
  PROCEDURE p_settlerollback(av_stlsumno IN stl_deal_sum.stl_sum_no%TYPE, --商户结算汇总序号
                             av_res      OUT VARCHAR2, --传出代码
                             av_msg      OUT VARCHAR2 --传出错误信息
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
      av_msg := '在这结算日期后已有审核或支付记录，不能回退！';
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
  --商户结算支付
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|5stlsumnos|6note|7bank_sheet_no
  --stlsumnos：stl_sum_no$card_type$acc_kind,stl_sum_no$card_type$acc_kind
  /*=======================================================================================*/
  PROCEDURE p_settlepay(av_in    IN VARCHAR2, --传入参数
                        av_debug IN VARCHAR2, --1调试
                        av_res   OUT VARCHAR2, --传出代码
                        av_msg   OUT VARCHAR2 --传出错误信息
                        ) IS
    lv_count         NUMBER;
    lv_clrdate       pay_clr_para.clr_date%TYPE; --清分日期
    lv_in            pk_public.myarray; --传入参数数组
    lv_stllist       pk_public.myarray; --结算列表
    lv_stl           pk_public.myarray; --结算记录主键
    lv_stltradesum   stl_deal_sum%ROWTYPE;
    lv_dbsubledger   acc_account_sub%ROWTYPE; --借方分户账
    lv_crsubledger   acc_account_sub%ROWTYPE; --贷方分户账
    lv_operator      sys_users%ROWTYPE; --操作员
    lv_accbookno     acc_inout_detail.acc_inout_no%TYPE; --记账流水号
    lv_remit_book_no stl_receipt_reg.reg_no%TYPE;
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             7, --参数最少个数
                             7, --参数最多个数
                             'pk_merchantsettle.p_settlepay', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
      --时间大于10分钟
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '传入的业务时间和系统时间相差大于10分钟';
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = lv_in(3);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := '未找到柜员编号' || lv_in(3);
        RETURN;
    END;

    lv_count := pk_public.f_splitstr(lv_in(5), ',', lv_stllist);
    IF lv_count = 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '结算列表不能为空';
      RETURN;
    END IF;
    FOR i IN 1 .. lv_stllist.count LOOP
      lv_count := pk_public.f_splitstr(lv_stllist(i), '$', lv_stl);
      --借商户待清算款
      SELECT *
        INTO lv_stltradesum
        FROM stl_deal_sum
       WHERE stl_sum_no = lv_stl(1)
         AND card_type = lv_stl(2)
         AND acc_kind = lv_stl(3);
      --更改stl_trade_sum
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
        av_msg := '该结算记录已支付，不能重复支付';
        RETURN;
      END IF;
      --写stl_remit_book
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
      pk_public.p_getsubledgerbyclientid(lv_dbsubledger.customer_id, --商户client_id
                                         pk_public.cs_accitem_biz_clr, --商户待清算款
                                         lv_dbsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --贷商户卡账户（商户结算金）
      BEGIN
        pk_public.p_getsubledgerbyclientid(lv_dbsubledger.customer_id, --商户client_id
                                           pk_public.cs_accitem_biz_stl, --商户结算金
                                           lv_crsubledger,
                                           av_res,
                                           av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
      END;
      --写流水
      SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
      pk_business.p_account(lv_dbsubledger, --借方账户
                            lv_crsubledger, --贷方账户
                            NULL, --借方卡面交易前金额
                            NULL, --贷方卡面交易前金额
                            NULL, --借方卡片交易计数器
                            NULL, --贷方卡片交易计数器
                            NULL, --借方金额密文
                            NULL, --贷方金额密文
                            lv_stltradesum.stl_amt, --交易金额
                            0, --信用发生额
                            lv_accbookno, --记账流水号
                            lv_in(2), --交易代码
                            lv_dbsubledger.org_id, --发卡机构
                            lv_crsubledger.org_id, --受理机构
                            '0', --受理点分类
                            lv_operator.brch_id, --受理点编码(网点号/商户号等)
                            lv_in(3), --操作柜员/终端号
                            NULL, --交易批次号
                            NULL, --终端交易流水号
                            to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --交易时间
                            '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                            lv_in(1), --业务流水号
                            lv_in(6), --备注
                            lv_clrdate, --清分日期
                            null,
                            av_debug, --1调试
                            av_res, --传出参数代码
                            av_msg --传出参数错误信息
                            );
      --借商户待清算款 贷机构手续费收入
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
        --写流水
        SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
        pk_business.p_account(lv_dbsubledger, --借方账户
                              lv_crsubledger, --贷方账户
                              NULL, --借方卡面交易前金额
                              NULL, --贷方卡面交易前金额
                              NULL, --借方卡片交易计数器
                              NULL, --贷方卡片交易计数器
                              NULL, --借方金额密文
                              NULL, --贷方金额密文
                              lv_divfee.div_fee, --交易金额
                              0, --信用发生额
                              lv_accbookno, --记账流水号
                              lv_in(2), --交易代码
                              lv_dbsubledger.org_id, --发卡机构
                              lv_crsubledger.org_id, --受理机构
                              '0', --受理点分类
                              lv_operator.brch_id, --受理点编码(网点号/商户号等)
                              lv_in(3), --操作柜员/终端号
                              NULL, --交易批次号
                              NULL, --终端交易流水号
                              to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --交易时间
                              '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                              lv_in(1), --业务流水号
                              lv_in(6), --备注
                              lv_clrdate, --清分日期
                              null,
                              av_debug, --1调试
                              av_res, --传出参数代码
                              av_msg --传出参数错误信息
                              );
      END LOOP;

    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := -1;
      dbms_output.put_line('错误信息：' || dbms_utility.format_error_stack);
      av_msg := av_msg || '错误信息：' || SQLERRM;
  END p_settlepay;

BEGIN
  -- initialization
  NULL;
END pk_merchantsettle;
/

