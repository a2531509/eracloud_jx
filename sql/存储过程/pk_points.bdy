CREATE OR REPLACE PACKAGE BODY pk_points IS
  /*=======================================================================================*/
  --积分兑换
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acpt_id        受理点编号(网点号或商户编号)
  --       6tr_batch_no    批次号
  --       7term_tr_no     终端交易流水号
  --       8card_no        卡号
  --       9tr_amt         兑换的积分数
  --      10type           兑换类型 1兑换到未圈存账户2兑换礼品3积分到期扣减
  --      11note           备注
  --      12encrypt        兑换类型是1时 兑换后未圈存账户金额密文
  --      13acpt_type      受理点分类
  --av_out: 1acc_book_no,points_from
  --     points_from: 积分构成，如果是扣取多期积分登记内容为2013:300|2014:200
  /*=======================================================================================*/
  PROCEDURE p_exchange(av_in    IN VARCHAR2, --传入参数
                       av_debug IN VARCHAR2, --1调试
                       av_res   OUT VARCHAR2, --传出代码
                       av_msg   OUT VARCHAR2, --传出错误信息
                       av_out   OUT VARCHAR2 --传出参数
                       ) IS
    --lv_count       NUMBER;
    lv_in          pk_public.myarray; --传入参数数组
    lv_dbsubledger acc_account_sub%ROWTYPE; --借方分户账
    lv_crsubledger acc_account_sub%ROWTYPE; --贷方分户账
    lv_operator    sys_users%ROWTYPE; --操作员
    lv_clrdate     pay_clr_para.clr_date%TYPE; --清分日期
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --记账流水号
    lv_tablename   VARCHAR2(50);
    lv_sql         VARCHAR2(2000);
    TYPE t_points IS TABLE OF points_book%ROWTYPE;
    lv_points t_points;
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             12, --参数最少个数
                             13, --参数最多个数
                             'pk_points.p_exchange', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
        av_msg := '未找到柜员编号' || lv_in(3);
        RETURN;
    END;
    --受理网点或商户号
    IF lv_in(5) IS NULL THEN
      lv_in(5) := lv_operator.brch_id;
    END IF;
    --11111111111111111积分扣除
    --取借方分户账
    pk_public.p_getsubledgerbycardno(lv_in(8), --卡号
                                     pk_public.cs_acckind_jf, --账户类型
                                     pk_public.cs_defaultwalletid, --钱包编号
                                     lv_dbsubledger, --分户账
                                     av_res, --传出参数代码
                                     av_msg --传出参数错误信息
                                     );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_dbsubledger.bal < lv_in(9) THEN
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '积分余额不足';
      RETURN;
    END IF;
    --计算每年/每月的积分分别扣多少
    DECLARE
      lv_tempamt NUMBER;
    BEGIN
      lv_tablename := pk_public.f_getpointsperiodbycard_no(lv_dbsubledger.card_no);
      IF lv_in(10) = 3 THEN
        --积分到期扣减
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
          --够扣
          IF av_out IS NOT NULL THEN
            av_out := av_out || '|';
          END IF;
          av_out := av_out || lv_points(i).period_name || ':' || lv_tempamt;
          EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                            ' set points_used = points_used + :1 where period_id = :2 and points_used=:3'
            USING lv_tempamt, lv_points(i).period_id, lv_points(i).points_used;
          IF SQL%ROWCOUNT = 0 THEN
            av_res := pk_public.cs_res_dberr;
            av_msg := '有另外一个进程在扣除积分';
            RETURN;
          ELSE
            lv_tempamt := 0;
            EXIT;
          END IF;
        ELSE
          --不够扣
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
            av_msg := '有另外一个进程在扣除积分';
            RETURN;
          ELSE
            lv_tempamt := lv_tempamt - (lv_points(i).points_sum - lv_points(i)
                          .points_used);
          END IF;
        END IF;
      END LOOP;
      IF lv_tempamt > 0 THEN
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '积分余额不足';
        RETURN;
      END IF;
    END;
    --结束计算每年/每月的积分分别扣多少

    --取贷方分户账
    pk_public.p_getorgsubledger(lv_operator.org_id,
                                pk_public.cs_accitem_org_points,
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
                          lv_in(9), --交易金额
                          0, --信用发生额
                          lv_accbookno, --记账流水号
                          lv_in(2), --交易代码
                          NULL,--发卡机构
                          lv_operator.org_id, --受理机构
                          lv_in(13), --受理点分类
                          lv_in(5), --受理点编码(网点号/商户号等)
                          lv_in(3), --操作柜员/终端号
                          lv_in(6), --交易批次号
                          lv_in(7), --终端交易流水号
                          to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --交易时间
                          '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                          lv_in(1), --业务流水号
                          lv_in(11), --备注
                          lv_clrdate, --清分日期
                          NULL, --其它传入参数 退货时传入原acc_book_no
                          av_debug, --1调试
                          av_res, --传出参数代码
                          av_msg --传出参数错误信息
                          );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    ELSE
      av_out := lv_accbookno || ',' || av_out;
    END IF;
    --222222222222222222转入未圈存账户
    IF lv_in(10) = '1' THEN
      --取借方分户账
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  pk_public.cs_accitem_org_points_chg_out,
                                  lv_dbsubledger,
                                  av_res,
                                  av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --取贷方分户账
      pk_public.p_getsubledgerbycardno(lv_in(8),
                                       pk_public.cs_points_exchange_acc,
                                       pk_public.cs_defaultwalletid, --钱包编号
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
                            lv_in(12), --贷方金额密文
                            lv_in(9) * pk_public.cs_points_exchange_rate / 100, --交易金额
                            0, --信用发生额
                            lv_accbookno, --记账流水号
                            lv_in(2), --交易代码
                            lv_operator.org_id, --发卡机构
                            lv_operator.org_id, --受理机构
                            lv_in(13), --受理点分类
                            lv_in(5), --受理点编码(网点号/商户号等)
                            lv_in(3), --操作柜员/终端号
                            lv_in(6), --交易批次号
                            lv_in(7), --终端交易流水号
                            to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --交易时间
                            '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                            lv_in(1), --业务流水号
                            lv_in(11), --备注
                            lv_clrdate, --清分日期
                            av_debug, --1调试
                            NULL,--其他参数
                            av_res, --传出参数代码
                            av_msg --传出参数错误信息
                            );
    END IF;
  END p_exchange;

  /*=======================================================================================*/
  --积分兑换撤销
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no 原记录的action_no
  --       6clr_date  原记录的清分日期
  --       7card_no   卡号
  --       8encrypt   撤销后未圈存账户金额密文
  /*=======================================================================================*/
  PROCEDURE p_exchangecancel(av_in    IN VARCHAR2, --传入参数
                             av_debug IN VARCHAR2, --1调试
                             av_res   OUT VARCHAR2, --传出代码
                             av_msg   OUT VARCHAR2, --传出错误信息
                             av_out   OUT VARCHAR2 --传出参数
                             ) IS
    lv_count      NUMBER;
    lv_in         pk_public.myarray; --传入参数数组
    lv_operator   sys_users%ROWTYPE; --操作员
    lv_clrdate    pay_clr_para.clr_date%TYPE; --清分日期
    lv_tablename  VARCHAR2(50);
    lv_pointsfrom points_exchange_info.points_from%TYPE; --积分构成
    lv_points     pk_public.myarray; --积分构成数组
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             9, --参数最少个数
                             9, --参数最多个数
                             'pk_points.p_exchangecancel', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
        av_msg := '未找到柜员编号' || lv_in(3);
        RETURN;
    END;
    --根据兑换时的积分构成还原积分
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
          av_msg := '积分兑换信息中的积分构成错误';
          RETURN;
        END IF;
        EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                          ' set points_used=points_used - :1 where card_no = :2 and period_name = :3'
          USING substrb(lv_points(i), instrb(lv_points(i), ':') + 1), lv_in(7), substrb(lv_points(i), 1, instrb(lv_points(i), ':') - 1);
        IF SQL%ROWCOUNT = 0 THEN
          av_res := pk_public.cs_res_dberr;
          av_msg := '积分构成表中未找到对应的周期记录，卡号' || lv_in(7) || '，周期' ||
                    substrb(lv_points(i), 1, instrb(lv_points(i), ':') - 1);
          RETURN;
        END IF;
      END IF;
    END LOOP;
    --撤销流水
    pk_business.p_daybookcancel(lv_in(5), --要撤销业务流水号
                                lv_in(1), --新业务流水号
                                lv_in(6), --撤销记录的清分日期
                                lv_clrdate, --当前清分日期
                                lv_in(2), --交易代码
                                lv_in(3), --柜员编号
                                NULL, --借方卡面交易前金额
                                NULL, --贷方卡面交易前金额
                                NULL, --借方卡片交易计数器
                                NULL, --贷方卡片交易计数器
                                NULL, --借方金额密文
                                lv_in(8), --贷方金额密文
                                '1', --1直接确认
                                av_debug, --1写调试日志
                                av_res, --传出代码
                                av_msg --传出错误信息
                                );
    av_out := NULL;
  END p_exchangecancel;

  /*=======================================================================================*/
  --积分生成
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acpt_id        受理点编号(网点号或商户编号)
  --       6tr_batch_no    批次号
  --       7term_tr_no     终端交易流水号
  --       8card_no        卡号
  --       9tr_amt         增加的积分数
  --      10type           积分增加的途径
  --      11note           备注
  /*=======================================================================================*/
  PROCEDURE p_generate(av_in    IN VARCHAR2, --传入参数
                       av_debug IN VARCHAR2, --1调试
                       av_res   OUT VARCHAR2, --传出代码
                       av_msg   OUT VARCHAR2, --传出错误信息
                       av_out   OUT VARCHAR2 --传出参数
                       ) IS
    --lv_count       number;
    lv_in          pk_public.myarray; --传入参数数组
    lv_dbsubledger acc_account_sub%ROWTYPE; --借方分户账
    --lv_crsubledger acc_account_sub%ROWTYPE; --贷方分户账
    lv_operator sys_users%ROWTYPE; --操作员
    lv_clrdate  pay_clr_para.clr_date%TYPE; --清分日期
    --lv_accbookno   acc_daybook.acc_book_no%TYPE; --记账流水号
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             11, --参数最少个数
                             11, --参数最多个数
                             'pk_points.p_generate', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
        av_msg := '未找到柜员编号' || lv_in(3);
        RETURN;
    END;
    --受理网点或商户号
    IF lv_in(5) IS NULL THEN
      lv_in(5) := lv_operator.brch_id;
    END IF;
    --11111111111111111积分生成
    --取借方分户账
    pk_public.p_getorgsubledger(lv_operator.org_id,
                                pk_public.cs_accitem_org_points,
                                lv_dbsubledger,
                                av_res,
                                av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    p_generate(lv_dbsubledger, --积分借方分户账
               lv_in(8), --卡号
               lv_in(9), --积分
               lv_in(2), --交易代码
               lv_operator.org_id, --受理点机构号
               lv_in(5), --受理点编码(网点号/商户号等)
               lv_in(3), --操作柜员/终端号
               lv_in(6), --交易批次号
               lv_in(7), --终端交易流水号
               lv_in(1), --业务流水号
               lv_in(11), --备注
               lv_clrdate, --清分日期
               av_debug, --1调试
               av_res, --传出代码
               av_msg --传出错误信息
               );
    av_out := NULL;
  END p_generate;

  /*=======================================================================================*/
  --根据清分日期取积分的记期周期和失效日期
  /*=======================================================================================*/
  PROCEDURE p_getpointsperiod(av_clrdate      IN VARCHAR2, --清分日期
                              av_period_name  OUT VARCHAR2, --计期说明，如2014-01-01(天)、2014-01(月)、2014(年)
                              av_invalid_date OUT VARCHAR2, --积分失效日期
                              av_res          OUT VARCHAR2, --传出代码
                              av_msg          OUT VARCHAR2 --传出错误信息
                              ) IS
  BEGIN
    --生成 积分构成表
    IF pk_public.cs_points_period_rule = '1' THEN
      --1天2月3季4年
      av_period_name := av_clrdate;
      --失效日期
      av_invalid_date := to_char(to_date(av_clrdate, 'yyyy-mm-dd') +
                                 pk_public.cs_points_period,
                                 'yyyy-mm-dd');
    ELSIF pk_public.cs_points_period_rule = '2' THEN
      --2月
      av_period_name  := substr(av_clrdate, 1, 7);
      av_invalid_date := to_char(add_months(to_date(av_period_name,
                                                    'yyyy-mm'),
                                            pk_public.cs_points_period),
                                 'yyyy-mm-dd');
    ELSIF pk_public.cs_points_period_rule = '3' THEN
      --3季
      av_period_name  := to_char(trunc(to_date(av_clrdate, 'yyyy-mm-dd'),
                                       'Q'),
                                 'yyyy-mm');
      av_invalid_date := to_char(add_months(to_date(av_period_name,
                                                    'yyyy-mm'),
                                            3 * pk_public.cs_points_period),
                                 'yyyy-mm-dd');
    ELSIF pk_public.cs_points_period_rule = '4' THEN
      --4年
      av_period_name  := substr(av_clrdate, 1, 4);
      av_invalid_date := (av_period_name + pk_public.cs_points_period) ||
                         '-01-01';
    ELSE
      av_res := pk_public.cs_res_dberr;
      av_msg := '系统参数表中积分计期规则参数错误';
      RETURN;
    END IF;

    av_res := pk_public.cs_res_ok;
  END p_getpointsperiod;

  /*=======================================================================================*/
  --积分生成
  /*=======================================================================================*/
  PROCEDURE p_generate(av_dbsubledger IN acc_account_sub%ROWTYPE, --积分借方分户账
                       av_cardno      IN VARCHAR2, --卡号
                       av_amt         IN NUMBER, --积分
                       av_trcode      IN VARCHAR2, --交易代码
                       av_orgid       IN VARCHAR2, --受理点机构号
                       av_brchid      IN VARCHAR2, --受理点编码(网点号/商户号等)
                       av_operid      IN VARCHAR2, --操作柜员/终端号
                       av_trbatchno   IN VARCHAR2, --交易批次号
                       av_termtrno    IN VARCHAR2, --终端交易流水号
                       av_actionno    IN NUMBER, --业务流水号
                       av_note        IN VARCHAR2, --备注
                       av_clrdate     IN VARCHAR2, --清分日期
                       av_debug       IN VARCHAR2, --1调试
                       av_res         OUT VARCHAR2, --传出代码
                       av_msg         OUT VARCHAR2 --传出错误信息
                       ) IS
    lv_count        NUMBER;
    lv_tablename    VARCHAR2(50);
    lv_crsubledger  acc_account_sub%ROWTYPE; --贷方分户账
    lv_clrdate      pay_clr_para.clr_date%TYPE; --清分日期
    lv_accbookno    acc_inout_detail.acc_inout_no%TYPE; --记账流水号
    lv_period_name  VARCHAR2(20); --计期说明，如2014-01-01(天)、2014-01(月)、2014(年)
    lv_invalid_date VARCHAR2(20); --积分失效日期
  BEGIN
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    --取积分的记期周期和失效日期
    p_getpointsperiod(lv_clrdate, --清分日期
                      lv_period_name, --计期说明，如2014-01-01(天)、2014-01(月)、2014(年)
                      lv_invalid_date, --积分失效日期
                      av_res, --传出代码
                      av_msg --传出错误信息
                      );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --取贷方分户账
    pk_public.p_getsubledgerbycardno(av_cardno, --卡号
                                     pk_public.cs_acckind_jf, --账户类型
                                     pk_public.cs_defaultwalletid, --钱包编号
                                     lv_crsubledger, --分户账
                                     av_res, --传出参数代码
                                     av_msg --传出参数错误信息
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
    --写流水
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    pk_business.p_account(av_dbsubledger, --借方账户
                          lv_crsubledger, --贷方账户
                          NULL, --借方卡面交易前金额
                          NULL, --贷方卡面交易前金额
                          NULL, --借方卡片交易计数器
                          NULL, --贷方卡片交易计数器
                          NULL, --借方金额密文
                          NULL, --贷方金额密文
                          av_amt, --交易金额
                          0, --信用发生额
                          lv_accbookno, --记账流水号
                          av_trcode, --交易代码
                          av_orgid,--发卡机构
                          av_orgid, --受理机构
                          pk_public.cs_acpt_type_wd, --受理点分类
                          av_brchid, --受理点编码(网点号/商户号等)
                          av_operid, --操作柜员/终端号
                          av_trbatchno, --交易批次号
                          av_termtrno, --终端交易流水号
                          SYSDATE, --交易时间
                          '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                          av_actionno, --业务流水号
                          av_note, --备注
                          lv_clrdate, --清分日期
                          NULL,--其他参数
                          av_debug, --1调试
                          av_res, --传出参数代码
                          av_msg --传出参数错误信息
                          );
  END p_generate;

  /*=======================================================================================*/
  --撤销积分生成 (只更新积分构成表，账户在流水撤销中统一处理)
  /*=======================================================================================*/
  PROCEDURE p_generatecancel(av_cardno  IN VARCHAR2, --卡号
                             av_amt     IN NUMBER, --积分
                             av_clrdate IN VARCHAR2, --清分日期
                             av_res     OUT VARCHAR2, --传出代码
                             av_msg     OUT VARCHAR2 --传出错误信息
                             ) IS
    lv_count        NUMBER;
    lv_tablename    VARCHAR2(50);
    lv_crsubledger  acc_account_sub%ROWTYPE; --贷方分户账
    lv_clrdate      pay_clr_para.clr_date%TYPE; --清分日期
    lv_period_name  VARCHAR2(20); --计期说明，如2014-01-01(天)、2014-01(月)、2014(年)
    lv_invalid_date VARCHAR2(20); --积分失效日期
  BEGIN
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    --取积分的记期周期和失效日期
    p_getpointsperiod(lv_clrdate, --清分日期
                      lv_period_name, --计期说明，如2014-01-01(天)、2014-01(月)、2014(年)
                      lv_invalid_date, --积分失效日期
                      av_res, --传出代码
                      av_msg --传出错误信息
                      );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --取贷方分户账
    pk_public.p_getsubledgerbycardno(av_cardno, --卡号
                                     pk_public.cs_acckind_jf, --账户类型
                                     pk_public.cs_defaultwalletid, --钱包编号
                                     lv_crsubledger, --分户账
                                     av_res, --传出参数代码
                                     av_msg --传出参数错误信息
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
      av_msg := '数据异常，积分构成表中找到该周期的积分';
      RETURN;
    ELSE
      EXECUTE IMMEDIATE 'UPDATE ' || lv_tablename ||
                        ' SET points_tot = points_tot - :1 WHERE card_no = :2 AND period_name = :3 and points_tot >= points_used + :4'
        USING av_amt, av_cardno, lv_period_name, av_amt;
      IF SQL%ROWCOUNT = 0 THEN
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '积分余额不足';
        RETURN;
      END IF;
    END IF;
  END p_generatecancel;
BEGIN
  -- initialization
  NULL;
END pk_points;
/

