CREATE OR REPLACE PACKAGE BODY pk_recharge IS
  cs_pay_source_xj   CONSTANT CHAR(1) := '0'; --充值资金来源0现金1转账2充值卡3促销4更改信用额度5网点预存款6商户签到促销7签到奖励
  cs_pay_source_zz   CONSTANT CHAR(1) := '1'; --充值资金来源0现金1转账2充值卡3促销4更改信用额度5网点预存款6商户签到促销7签到奖励
  cs_pay_source_czk  CONSTANT CHAR(1) := '2'; --充值资金来源0现金1转账2充值卡3促销4更改信用额度5网点预存款6商户签到促销7签到奖励
  cs_pay_source_cx   CONSTANT CHAR(1) := '3'; --充值资金来源0现金1转账2充值卡3促销4更改信用额度5网点预存款6商户签到促销7签到奖励
  cs_pay_source_xy   CONSTANT CHAR(1) := '4'; --充值资金来源0现金1转账2充值卡3促销4更改信用额度5网点预存款6商户签到促销7签到奖励
  cs_pay_source_yck  CONSTANT CHAR(1) := '5'; --充值资金来源0现金1转账2充值卡3促销4更改信用额度5网点预存款6商户签到促销7签到奖励
  cs_pay_source_qdcx CONSTANT CHAR(1) := '6'; --充值资金来源0现金1转账2充值卡3促销4更改信用额度5网点预存款6商户签到促销7签到奖励
  cs_pay_source_qdjl CONSTANT CHAR(1) := '7'; --充值资金来源0现金1转账2充值卡3促销4更改信用额度5网点预存款6商户签到促销7签到奖励

  /*=======================================================================================*/
  --充值写灰记录
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acpt_id      受理点编号(网点号或商户编号或合作机构编号
  --       6tr_batch_no  批次号
  --       7term_tr_no   终端交易流水号
  --       8card_no      卡号
  --       9card_tr_count卡交易计数器
  --      10card_bal     钱包交易前金额
  --      11acc_kind     账户类型
  --      12wallet_id    钱包编号 默认00
  --      13tr_amt       充值金额(更改信用额度时传入更改后的信用额度)
  --      14pay_source   充值资金来源0现金1转账2充值卡3促销4更改信用额度5网点预存款6商户签到促销7签到奖励--> 类型1包含转账
  --      15sourcecard   充值卡卡号或银行卡卡号或商户clientid
  --      16rechg_pwd    充值卡密码
  --      17note         备注
  --      18tr_state     9写灰记录0直接写正常记录
  --      19encrypt      充值后卡账户金额密文
  --      20acpt_type    受理点分类 ---》2合作机构
  --      21acc_bal      卡账户交易前金额
  /*=======================================================================================*/
  PROCEDURE p_recharge(av_in    IN VARCHAR2, --传入参数
                       av_debug IN VARCHAR2, --1调试
                       av_res   OUT VARCHAR2, --传出代码
                       av_msg   OUT VARCHAR2 --传出错误信息
                       ) IS
    --lv_count       number;
    lv_in          pk_public.myarray; --传入参数数组
    lv_dbsubledger acc_account_sub%ROWTYPE; --借方分户账
    lv_crsubledger acc_account_sub%ROWTYPE; --贷方分户账
    lv_operator    sys_users%ROWTYPE; --柜员
    lv_branch      sys_branch%ROWTYPE; --网点
    lv_clrdate     pay_clr_para.clr_date%TYPE; --清分日期
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --记账流水号
    lrec_rechg     card_recharge%ROWTYPE; --充值卡
    lv_card        card_baseinfo%ROWTYPE; --卡基本信息
    lv_cardpara    card_config%ROWTYPE; --卡参数表
    lv_credit      acc_account_sub.credit_lmt%TYPE; --信用发生额
    lv_co_org      base_co_org%ROWTYPE;--合作机构
    av_co_org_id   VARCHAR2(20);
    lv_tablename   VARCHAR2(100);
    lv_count       NUMBER;
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             17, --参数最少个数
                             21, --参数最多个数
                             'pk_recharge.p_recharge', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --判断充值流水是否重复，只针对合作机构的机内判断
    IF lv_in(20) = '2' THEN 
      IF lv_in(18) = '9' THEN
        lv_tablename := 'pay_card_deal_rec';
      ELSE
        lv_tablename := 'pay_card_deal_rec_' ||substr(replace(lv_clrdate,'-',''),0,6); ----需要考虑传入的交易时间找不到表的情况
      END IF;
      execute immediate 'select count(1) from '||lv_tablename||' t where t.acpt_id = :1 and  t.user_id =:2 and t.deal_batch_no =:3  and t.END_DEAL_NO =:4 '
         into lv_count
         using lv_in(5),lv_in(3),lv_in(6),lv_in(7);
         if lv_count > 1 then
           av_res := pk_public.cs_res_rowunequalone;
           av_msg := '交易数据重复';
           return;
         end if;
    END IF;
    --默认写灰记录
    IF lv_in(18) IS NULL THEN
      lv_in(18) := '9';
    ELSIF lv_in(18) NOT IN ('9', '0') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := 'tr_state只能9或0';
      RETURN;
    END IF;
    --钱包编号默认00
    lv_in(12) := nvl(lv_in(12), pk_public.cs_defaultwalletid);
    IF lv_in(14) = '9' THEN--工会充值，直接去指定的网点id
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
              --代理网点
              IF lv_in(14) = cs_pay_source_xj THEN
                lv_in(14) := cs_pay_source_yck;
              END IF;
            END IF;
          EXCEPTION
            WHEN no_data_found THEN
              av_res := pk_public.cs_res_operatorerr;
              av_msg := '未找到柜员编号' || lv_in(3);
              RETURN;
          END;
      END IF;
      --受理网点或商户号
      IF lv_in(5) IS NULL THEN
        lv_in(5) := lv_operator.brch_id;
      END IF;
    END IF;

    --取借方分户账

    IF lv_in(20) = '2' THEN
      BEGIN
         select * into lv_co_org from base_co_org where co_org_id = lv_in(5);
            if lv_co_org.co_state <> '0' then
               av_res := pk_public.cs_res_co_org_novalidateerr;
               av_msg := '受卡方身份验证失败';
               return;
            end if;
         EXCEPTION
            WHEN no_data_found THEN
               av_res := pk_public.cs_res_co_org_novalidateerr;
               av_msg := '受卡方身份验证失败';
      END;
    END IF;

    IF lv_in(14) = cs_pay_source_xj THEN
      --现金
          IF lv_in(20) = '2' THEN
             --合作机构现金
             lv_dbsubledger.item_id :=pk_public.cs_accitem_co_org_rechage_in;
          ELSE
             --其他
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
      --转账
          IF lv_in(20) = '2' THEN
             --合作机构现金
             lv_dbsubledger.item_id :=pk_public.cs_accitem_co_org_rechage_in;
             pk_public.p_getsubledgerbyclientid(lv_co_org.customer_id,
                                             lv_dbsubledger.item_id,
                                             lv_dbsubledger,
                                             av_res,
                                             av_msg);
          ELSE
             --其他
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
      --充值卡
      BEGIN
        SELECT *
          INTO lrec_rechg
          FROM card_recharge
         WHERE card_no = lv_in(15);                   --面额为什么不取
        IF lrec_rechg.use_state <> '2' THEN
          av_res := pk_public.cs_res_prepaidcardnotexist;
          av_msg := '充值卡' || lv_in(15) || --
                    CASE lrec_rechg.use_state
                      WHEN '0' THEN
                       '未使用'
                      WHEN '1' THEN
                       '未激活'
                      WHEN '3' THEN
                       '已使用'
                      WHEN '9' THEN
                       '已注销'
                      ELSE
                       '不是已激活状态'
                    END;
          RETURN;
        ELSE
          IF lrec_rechg.pwd <> lv_in(16) THEN
            av_res := pk_public.cs_res_prepaidcardpwderr;
            av_msg := '充值卡密码不正确';
            RETURN;
          END IF;
        END IF;
        --充值金额
        SELECT face_val
          INTO lv_in(13)
          FROM card_config
         WHERE card_type = lrec_rechg.card_type;
      EXCEPTION
        WHEN no_data_found THEN
          av_res := pk_public.cs_res_prepaidcardnotexist;
          av_msg := '不存在该充值卡' || lv_in(15);
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
      --更改充值卡状态
      UPDATE card_recharge
         SET use_state = '3'
       WHERE card_no = lv_in(15)
         AND use_state = '2';
      IF SQL%ROWCOUNT = 0 THEN
        av_res := pk_public.cs_res_prepaidcardisused;
        av_msg := '充值卡' || lv_in(15) || '已被使用';
        RETURN;
      END IF;
    ELSIF lv_in(14) = cs_pay_source_cx THEN
      --促销
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
      --商户签到促销 借商户结算金
      lv_dbsubledger.item_id := pk_public.cs_accitem_biz_stl;
      pk_public.p_getsubledgerbyclientid(lv_in(15), --商户client_id
                                         lv_dbsubledger.item_id, --商户结算金
                                         lv_dbsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSIF lv_in(14) = cs_pay_source_qdjl THEN
      --签到奖励
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
      --更改信用额度
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
      --网点预存款
      lv_dbsubledger.item_id := pk_public.cs_accitem_brch_prestore;
      pk_public.p_getsubledgerbyclientid(lv_operator.brch_id,
                                         lv_dbsubledger.item_id,
                                         lv_dbsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      pk_public.p_judgebranchagentlimit(lv_dbsubledger.customer_id, --网点编号
                                        lv_dbsubledger.bal - lv_in(13), --扣除金额后的预存款余额
                                        av_res, --传出参数代码
                                        av_msg --传出参数错误信息
                                        );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSE
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '传入参数pay_source错误';
      RETURN;
    END IF;

    --取贷方分户账
    pk_public.p_getsubledgerbycardno(lv_in(8), --卡号
                                     lv_in(11), --账户类型
                                     lv_in(12), --钱包编号
                                     lv_crsubledger, --分户账
                                     av_res, --传出参数代码
                                     av_msg --传出参数错误信息
                                     );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_crsubledger.acc_kind IN ('02') AND
       lv_crsubledger.bal <> nvl(lv_in(21), 0) THEN
      --联机账户需要判断是不是同时更新账户
      av_res := pk_public.cs_res_dberr;
      av_msg := '账户交易前金额不正确';
      RETURN;
    END IF;
    --取卡基本信息和卡参数表
    pk_public.p_getcardbycardno(lv_crsubledger.card_no, --卡号
                                lv_card, --卡片基本信息
                                av_res, --传出参数代码
                                av_msg --传出参数错误信息
                                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    ELSE
      pk_public.p_getcardparabycardtype(lv_card.card_type, --卡类型
                                        lv_cardpara, --卡参数表
                                        av_res, --传出参数代码
                                        av_msg --传出参数错误信息
                                        );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
    --判断状态
    /*if lv_crsubledger.acc_state <> '1' then
      av_res := pk_public.cs_res_accstateerr;
      av_msg := '账户状态不正常';
      return;
    end if;*/
    IF lv_in(14) = cs_pay_source_xy THEN
      --更改信用额度
      IF lv_crsubledger.bal + (lv_in(13) - lv_crsubledger.credit_lmt) < 0 THEN
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '账户余额不足';
        RETURN;
      ELSE
        lv_credit := lv_in(13) - lv_crsubledger.credit_lmt;
        lv_in(13) := lv_credit;
      END IF;
    ELSIF lv_in(11) IN ('01', '02') THEN
      --充值限额

      IF lv_crsubledger.acc_kind = pk_public.cs_acckind_qb THEN
        IF nvl(lv_cardpara.wallet_one_allow_max,0) >0 THEN
           IF  lv_in(13)> nvl(lv_cardpara.wallet_one_allow_max,0) THEN
              av_res := pk_public.cs_res_onerechage_walerr;
              av_msg := '电子钱包单笔充值超过限额';
              RETURN;
           END IF;
        END IF;
        IF nvl(lv_cardpara.wallet_case_rechg_lmt, 0) > 0 THEN
          IF lv_in(13) + lv_crsubledger.bal >
             lv_cardpara.wallet_case_rechg_lmt THEN
            av_res := pk_public.cs_res_rechg_exceed_limit;
            av_msg := '电子钱包充值超过限额';
            RETURN;
          END IF;
        END IF;

      ELSIF lv_crsubledger.acc_kind = pk_public.cs_acckind_zj THEN

        IF nvl(lv_cardpara.acc_one_allow_max, 0) > 0 THEN
          IF lv_in(13)  >
             lv_cardpara.acc_one_allow_max THEN
            av_res := pk_public.cs_res_onerechage_accerr;
            av_msg := '资金账户单笔充值超过限额';
            RETURN;
          END IF;
        END IF;

        IF nvl(lv_cardpara.acc_case_rechg_lmt, 0) > 0 THEN
          IF lv_in(13) + lv_crsubledger.bal >
             lv_cardpara.acc_case_rechg_lmt THEN
            av_res := pk_public.cs_res_rechg_exceed_limit;
            av_msg := '资金账户充值超过限额';
            RETURN;
          END IF;
        END IF;
      END IF;
      IF lv_in(14) = cs_pay_source_zz THEN
        IF lv_in(13) > lv_cardpara.bank_rechg_lmt THEN
          av_res := pk_public.cs_res_rechg_exceed_limit;
          av_msg := '银行卡单次圈存超过限额';
          RETURN;
        END IF;
      END IF;
      IF lv_in(14) = cs_pay_source_xj THEN
        IF lv_in(13) < lv_cardpara.cash_rechg_low THEN
          av_res := pk_public.cs_res_rechg_exceed_limit;
          av_msg := '现金充值不能低于最低限额';
          RETURN;
        END IF;
      END IF;
      IF lv_crsubledger.acc_kind = pk_public.cs_acckind_zj THEN
        IF lv_in(13) < lv_cardpara.cash_rechg_low THEN
          av_res := pk_public.cs_res_rechg_exceed_limit;
          av_msg := '账户充值不能低于最低限额';
          RETURN;
        END IF;
      END IF;
      --计算信用发生额
      IF lv_crsubledger.credit_lmt <= lv_crsubledger.bal THEN
        --未透支
        lv_credit := 0;
      ELSE
        --已透支，补信用
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
    --写流水
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    pk_business.p_account(lv_dbsubledger, --借方账户
                          lv_crsubledger, --贷方账户
                          NULL, --借方卡面交易前金额
                          lv_in(10), --贷方卡面交易前金额
                          NULL, --借方卡片交易计数器
                          lv_in(9), --贷方卡片交易计数器
                          NULL, --借方金额密文
                          lv_in(19), --贷方金额密文
                          lv_in(13), --交易金额
                          lv_credit, --信用发生额
                          lv_accbookno, --记账流水号
                          lv_in(2), --交易代码
                          lv_crsubledger.org_id, --发卡机构
                          av_co_org_id, --受理机构
                          lv_in(20), --受理点分类
                          lv_in(5), --受理点编码(网点号/商户号等)
                          nvl(lv_in(3),'admin'), --操作柜员/终端号
                          lv_in(6), --交易批次号
                          lv_in(7), --终端交易流水号
                          to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --交易时间
                          lv_in(18), --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                          lv_in(1), --业务流水号
                          lv_in(17), --备注
                          lv_clrdate, --清分日期
                          null,
                          av_debug, --1调试
                          av_res, --传出参数代码
                          av_msg --传出参数错误信息
                          );

  IF lv_in(20) = '2' THEN   ---合作机构充值写综合日志记录
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
             lv_in(2), --交易代码,
             lv_card.customer_id,
             lv_dbsubledger.acc_name,
             lv_in(8), --卡号,
             lv_card.card_no,
             lv_card.card_type,
             '1',
             to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'),
             lv_in(5), --受理点编码(网点号/商户号等)
              nvl(lv_in(3),'admin'), --操作柜员/终端号
             lv_clrdate,
             lv_in(18),
             lv_in(17), --备注
             '0',
             '0',
             '0',
             lv_in(13),
             '0');

         end if;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '充值发生错误：' || SQLERRM;
  END p_recharge;

  /*=======================================================================================*/
  --充值确认
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no|6clr_date|7encrypt确认后卡账户金额密文|8确认前卡账户金额明文/9卡账户金额密文
  /*=======================================================================================*/
  PROCEDURE p_rechargeconfirm_onerow(av_in    IN VARCHAR2, --传入参数
                                     av_debug IN VARCHAR2, --1写调试日志
                                     av_res   OUT VARCHAR2, --传出代码
                                     av_msg   OUT VARCHAR2 --传出错误信息
                                     ) IS
    --lv_count   number;
    lv_in pk_public.myarray; --传入参数数组
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             8, --参数最少个数
                             8, --参数最多个数
                             'pk_recharge.p_rechargeconfirm_onerow', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --灰记录确认
    pk_business.p_ashconfirmbyaccbookno(lv_in(6), --清分日期
                                        lv_in(5), --acc_book_no
                                        NULL, --借方金额密文
                                        lv_in(7), --贷方金额密文
                                        NULL, --借方交易前金额
                                        lv_in(8), --贷方交易前金额
                                        av_debug, --1写调试日志
                                        av_res, --传出代码
                                        av_msg --传出错误信息
                                        );
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '充值灰记录确认发生错误：' || SQLERRM;
  END p_rechargeconfirm_onerow;
  /*=======================================================================================*/
  --充值确认
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no|6clr_date|7card_no|8确认后卡账户金额密文
  /*=======================================================================================*/
  PROCEDURE p_rechargeconfirm(av_in    IN VARCHAR2, --传入参数
                              av_debug IN VARCHAR2, --1写调试日志
                              av_res   OUT VARCHAR2, --传出代码
                              av_msg   OUT VARCHAR2 --传出错误信息
                              ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --传入参数数组
    lv_clrdate pay_clr_para.clr_date%TYPE; --清分日期
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             7, --参数最少个数
                             8, --参数最多个数
                             'pk_recharge.p_rechargeconfirm', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --灰记录确认
    pk_business.p_ashconfirm(lv_clrdate, --清分日期
                             lv_in(5), --业务流水号
                             NULL, --借方金额密文
                             lv_in(8), --贷方金额密文
                             av_debug, --1写调试日志
                             av_res, --传出代码
                             av_msg --传出错误信息
                             );
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '充值灰记录确认发生错误：' || SQLERRM;
  END p_rechargeconfirm;

  /*=======================================================================================*/
  --充值撤销
  --    如果原记录是灰记录，把记录改成充正状态，
  --                正常记录：新增一条负的灰记录，原记录改成撤销状态写撤销时间
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no|6clr_date|7card_tr_count|8card_bal|9撤销后卡账户金额密文|10撤销前卡账户余额/11撤销前卡账户密文
  /*=======================================================================================*/
  PROCEDURE p_rechargecancel_onerow(av_in    IN VARCHAR2, --传入参数
                                    av_debug IN VARCHAR2, --1写调试日志
                                    av_res   OUT VARCHAR2, --传出代码
                                    av_msg   OUT VARCHAR2 --传出错误信息
                                    ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --传入参数数组
    lv_clrdate pay_clr_para.clr_date%TYPE; --清分日期
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             10, --参数最少个数
                             10, --参数最多个数
                             'pk_recharge.p_rechargecancel_onerow', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    IF lv_in(2) = '90901051' THEN
       pk_business.p_daybookcancelbyaccbookno(lv_in(5), --要撤销acc_book_no
                                           lv_in(1), --新业务流水号
                                           lv_in(6), --撤销记录的清分日期
                                           lv_clrdate, --当前清分日期
                                           lv_in(2), --交易代码
                                           lv_in(3), --当前柜员
                                           NULL, --借方卡面交易前金额
                                           lv_in(8), --贷方卡面交易前金额
                                           NULL, --借方卡片交易计数器
                                           lv_in(7), --贷方卡片交易计数器
                                           NULL, --借方金额密文
                                           lv_in(9), --贷方金额密文
                                           NULL, --借方交易前金额
                                           lv_in(10), --贷方交易前金额
                                           '1', --1直接确认
                                           av_debug, --1写调试日志
                                           av_res, --传出代码
                                           av_msg --传出错误信息
                                           );
    ELSE
      pk_business.p_daybookcancelbyaccbookno(lv_in(5), --要撤销acc_book_no
                                           lv_in(1), --新业务流水号
                                           lv_in(6), --撤销记录的清分日期
                                           lv_clrdate, --当前清分日期
                                           lv_in(2), --交易代码
                                           lv_in(3), --当前柜员
                                           NULL, --借方卡面交易前金额
                                           lv_in(8), --贷方卡面交易前金额
                                           NULL, --借方卡片交易计数器
                                           lv_in(7), --贷方卡片交易计数器
                                           NULL, --借方金额密文
                                           lv_in(9), --贷方金额密文
                                           NULL, --借方交易前金额
                                           lv_in(10), --贷方交易前金额
                                           '0', --1直接确认
                                           av_debug, --1写调试日志
                                           av_res, --传出代码
                                           av_msg --传出错误信息
                                           );
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '充值撤销发生错误：' || SQLERRM;
  END p_rechargecancel_onerow;

  /*=======================================================================================*/
  --充值撤销
  --    如果原记录是灰记录，把记录改成充正状态，
  --                正常记录：新增一条负的灰记录，原记录改成撤销状态写撤销时间
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no|6clr_date|7card_no|8tr_state|9card_tr_count|10card_bal|11撤销后卡账户金额密文
  /*=======================================================================================*/
  PROCEDURE p_rechargecancel(av_in    IN VARCHAR2, --传入参数
                             av_debug IN VARCHAR2, --1写调试日志
                             av_res   OUT VARCHAR2, --传出代码
                             av_msg   OUT VARCHAR2 --传出错误信息
                             ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --传入参数数组
    lv_clrdate pay_clr_para.clr_date%TYPE; --清分日期
    /*lv_cash_box  cash_box%ROWTYPE;
    lv_count NUMBER;*/
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             11, --参数最少个数
                             11, --参数最多个数
                             'pk_recharge.p_rechargecancel', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
     --判断尾箱
     /*SELECT COUNT(1) INTO lv_count FROM cash_box_rec;
     IF lv_count > 0 THEN
       SELECT * INTO lv_cash_box FROM cash_box_rec;
       IF lv_cash_box.td_blc -abs()
     END IF;*/
     
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    IF lv_in(8) = '9' THEN
      --灰记录取消
      pk_business.p_ashcancel(lv_clrdate, --清分日期
                              lv_in(5), --业务流水号
                              av_debug, --1写调试日志
                              av_res, --传出代码
                              av_msg --传出错误信息
                              );
    ELSIF lv_in(8) = '0' THEN
      --撤销正常记录
      pk_business.p_daybookcancel(lv_in(5), --要撤销业务流水号
                                  lv_in(1), --新业务流水号
                                  lv_in(6), --撤销记录的清分日期
                                  lv_clrdate, --当前清分日期
                                  lv_in(2), --交易代码
                                  lv_in(3), --柜员编号
                                  NULL, --借方卡面交易前金额
                                  lv_in(10), --贷方卡面交易前金额
                                  NULL, --借方卡片交易计数器
                                  lv_in(9), --贷方卡片交易计数器
                                  NULL, --借方金额密文
                                  lv_in(11), --贷方金额密文
                                  '1', --1直接确认
                                  av_debug, --1写调试日志
                                  av_res, --传出代码
                                  av_msg --传出错误信息
                                  );
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '充值撤销发生错误：' || SQLERRM;
  END p_rechargecancel;

  /*=======================================================================================*/
  --充值冲正记录改成灰记录状态
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no  原充值记录的业务流水号
  /*=======================================================================================*/
  PROCEDURE p_rechargecancel2ash(av_in    IN VARCHAR2, --传入参数
                                 av_debug IN VARCHAR2, --1写调试日志
                                 av_res   OUT VARCHAR2, --传出代码
                                 av_msg   OUT VARCHAR2 --传出错误信息
                                 ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --传入参数数组
    lv_clrdate pay_clr_para.clr_date%TYPE; --清分日期
    lv_cardno       pay_card_deal_rec.card_no%TYPE; --卡号
    lv_oldaccbookno acc_inout_detail.old_acc_inout_no%TYPE; --被撤销的记账流水号
    --根据撤销的记账流水号和卡号取清分日期
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
    pk_public.p_getinputpara(av_in, --传入参数
                             5, --参数最少个数
                             5, --参数最多个数
                             'pk_recharge.p_rechargecancel2ash', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
    --撤销记录的冲正改成灰记录，需要更改原充值记录
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
                              ' set tr_state = 1,rev_time = sysdate,note = note || ''_撤销'' where acc_book_no = ' ||
                              lv_oldaccbookno ||
                              ' returning tr_date into :1'
              RETURNING INTO lv_oldtrdate;
            FOR i IN 0 .. pk_public.cs_cm_card_nums - 1 LOOP
              EXECUTE IMMEDIATE 'update tr_card_' || TRIM(to_char(i, '00')) || '_' ||
                                to_char(lv_oldtrdate, 'yyyymm') ||
                                ' set tr_state = 1,rev_time = sysdate,note = note || ''_撤销'' where acc_book_no = ' ||
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
      av_msg := '充值冲正记录恢复成灰记录状态发生错误：' || SQLERRM;
  END p_rechargecancel2ash;

  /*=======================================================================================*/
  --账户返现
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acpt_id|6tr_batch_no|7term_tr_no|8card_no|9card_tr_count|10card_bal|11acc_kind|12wallet_id|13tr_amt|
  --       14note|15返现后金额密文|16acpt_type|17卡账户交易前金额
  /*=======================================================================================*/
  PROCEDURE p_returncash(av_in    IN VARCHAR2, --传入参数
                         av_debug IN VARCHAR2, --1调试
                         av_res   OUT VARCHAR2, --传出代码
                         av_msg   OUT VARCHAR2 --传出错误信息
                         ) IS
    --lv_count       number;
    lv_in          pk_public.myarray; --传入参数数组
    lv_dbsubledger acc_account_sub%ROWTYPE; --借方分户账
    lv_crsubledger acc_account_sub%ROWTYPE; --贷方分户账
    lv_operator    sys_users%ROWTYPE; --柜员
    lv_branch      sys_branch%ROWTYPE; --网点
    lv_clrdate     pay_clr_para.clr_date%TYPE; --清分日期
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --记账流水号
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             16, --参数最少个数
                             17, --参数最多个数
                             'pk_recharge.p_returncash', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    --钱包编号默认00
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
        av_msg := '未找到柜员编号' || lv_in(3);
        RETURN;
    END;
    --取借方分户账
    pk_public.p_getsubledgerbycardno(lv_in(8), --卡号
                                     lv_in(11), --账户类型
                                     lv_in(12), --钱包编号
                                     lv_dbsubledger, --分户账
                                     av_res, --传出参数代码
                                     av_msg --传出参数错误信息
                                     );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    ELSE
      IF lv_dbsubledger.bal - lv_dbsubledger.credit_lmt < lv_in(13) THEN
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '账户余额不足';
        RETURN;
      END IF;
      IF lv_dbsubledger.acc_kind IN ('02') AND
         lv_dbsubledger.bal <> nvl(lv_in(17), 0) THEN
        --联机账户需要判断是不是同时更新账户
        av_res := pk_public.cs_res_dberr;
        av_msg := '账户交易前金额不正确';
        RETURN;
      END IF;
    END IF;
    --取贷方分户账
    --现金
    lv_crsubledger.item_id := pk_public.cs_accitem_cash;
    IF lv_branch.brch_type = '3' THEN
      --代理网点
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

    --写流水
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    pk_business.p_account(lv_dbsubledger, --借方账户
                          lv_crsubledger, --贷方账户
                          NULL, --借方卡面交易前金额
                          lv_in(10), --贷方卡面交易前金额
                          NULL, --借方卡片交易计数器
                          lv_in(9), --贷方卡片交易计数器
                          lv_in(15), --借方金额密文
                          NULL, --贷方金额密文
                          lv_in(13), --交易金额
                          0, --信用发生额
                          lv_accbookno, --记账流水号
                          lv_in(2), --交易代码
                          lv_crsubledger.org_id, --发卡机构
                          lv_operator.org_id, --受理机构
                          lv_in(16), --受理点分类
                          lv_in(5), --受理点编码(网点号/商户号等)
                          lv_in(3), --操作柜员/终端号
                          lv_in(6), --交易批次号
                          lv_in(7), --终端交易流水号
                          to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --交易时间
                          '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                          lv_in(1), --业务流水号
                          lv_in(14), --备注
                          lv_clrdate, --清分日期
                          null,
                          av_debug, --1调试
                          av_res, --传出参数代码
                          av_msg --传出参数错误信息
                          );
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '账户返现发生错误：' || SQLERRM;
  END p_returncash;
  /*=======================================================================================*/
  --充值到网点预存款
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acpt_id      网点号  预存款的网点
  --       6tr_batch_no  批次号
  --       7term_tr_no   终端交易流水号
  --       8tr_amt       充值金额(更改信用额度时传入更改后的信用额度)
  --       9pay_source   充值资金来源0现金1转账4更改信用额度
  --      10note         备注
  --      11tr_state     9写灰记录0直接写正常记录
  --      12acpt_type    受理点分类
  /*=======================================================================================*/
  PROCEDURE p_recharge2brch(av_in    IN VARCHAR2, --传入参数
                            av_debug IN VARCHAR2, --1调试
                            av_res   OUT VARCHAR2, --传出代码
                            av_msg   OUT VARCHAR2 --传出错误信息
                            ) IS
    lv_count       NUMBER;
    lv_in          pk_public.myarray; --传入参数数组
    lv_dbsubledger acc_account_sub%ROWTYPE; --借方分户账
    lv_crsubledger acc_account_sub%ROWTYPE; --贷方分户账
    lv_operator    sys_users%ROWTYPE; --柜员
    lv_branch      sys_branch%ROWTYPE; --网点
    lv_clrdate     pay_clr_para.clr_date%TYPE; --清分日期
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --记账流水号
    lv_credit      acc_account_sub.credit_lmt%TYPE; --信用发生额
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             11, --参数最少个数
                             12, --参数最多个数
                             'pk_recharge.p_recharge2brch', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    --默认写正常记录
    IF lv_in(11) IS NULL THEN
      lv_in(11) := '0';
    ELSIF lv_in(11) NOT IN ('9', '0') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := 'tr_state只能9或0';
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
        av_msg := '不能是代理网点的柜员，' || lv_in(3);
        RETURN;
      END IF;
      SELECT COUNT(*)
        INTO lv_count
        FROM sys_branch
       WHERE brch_id = lv_in(5)
         AND brch_type = '3';
      IF lv_count = 0 THEN
        av_res := pk_public.cs_res_paravalueerr;
        av_msg := '传入的预存款的网点不是代理网点，' || lv_in(5);
        RETURN;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := '未找到柜员编号' || lv_in(3);
        RETURN;
    END;
    --预存款网点
    IF lv_in(5) IS NULL OR lv_in(5) = lv_operator.brch_id THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '预存款网点错误';
      RETURN;
    END IF;
    --取贷方分户账
    pk_public.p_getsubledgerbyclientid(lv_in(5),
                                       pk_public.cs_accitem_brch_prestore,
                                       lv_crsubledger,
                                       av_res,
                                       av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --取借方分户账
    IF lv_in(9) = cs_pay_source_xj THEN
      --现金
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
      --转账
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
      --更改信用额度
      lv_dbsubledger.item_id := pk_public.cs_accitem_org_credit_chg_out;
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  lv_dbsubledger.item_id,
                                  lv_dbsubledger,
                                  av_res,
                                  av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --更改信用额度
      IF lv_crsubledger.bal + (lv_in(8) - lv_crsubledger.credit_lmt) < 0 THEN
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '账户余额不足';
        RETURN;
      ELSE
        lv_credit := lv_in(8) - lv_crsubledger.credit_lmt;
        lv_in(8) := lv_credit;
      END IF;
    ELSE
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '传入参数pay_source错误';
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
                          lv_in(8), --交易金额
                          nvl(lv_credit, 0), --信用发生额
                          lv_accbookno, --记账流水号
                          lv_in(2), --交易代码
                          lv_crsubledger.org_id, --发卡机构
                          lv_operator.org_id, --受理机构
                          lv_in(12), --受理点分类
                          lv_operator.brch_id, --受理点编码(网点号/商户号等)
                          lv_in(3), --操作柜员/终端号
                          lv_in(6), --交易批次号
                          lv_in(7), --终端交易流水号
                          to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --交易时间
                          lv_in(11), --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                          lv_in(1), --业务流水号
                          lv_in(10), --备注
                          lv_clrdate, --清分日期
                          null,
                          av_debug, --1调试
                          av_res, --传出参数代码
                          av_msg --传出参数错误信息
                          );
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '充值到网点预存款账户发生错误：' || SQLERRM;
  END p_recharge2brch;

BEGIN
  -- initialization
  NULL;
END pk_recharge;
/

