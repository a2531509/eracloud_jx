CREATE OR REPLACE PACKAGE BODY pk_consume IS
  --操作都以商户终端批次流水作为条件 tr_state 3的状态不用,只有0正常 1被撤销 9灰记录
  --消费 ------acc_daybook写正常记录
  --撤销 ------原记录改成撤销状态,新增一条负记录 old_action_no 写原记录action_no
  --撤销充正---负记录不变,新增一条正常消费记录 old_action_no 写撤销记录action_no
  --退货 ------新增负记录 old_action_no 写原记录action_no
  --退货充正---退货记录改成撤销状态,新增一条正记录 old_action_no 写退货记录action_no
  --联机消费：
  --1取账户列表2取账户信息3消费计算4消费扣款5冲正计算6冲正7退货计算8退货9退货冲正计算10退货冲正
  --BS_MERCHANT_LIMIT   商户限额配置表
  --CM_CARD_LIMIT_CONF  卡片限额配置

  /*=======================================================================================*/
  --根据商户号 返回账户列表
  --av_table:code_value code_name
  /*=======================================================================================*/
  PROCEDURE p_getAccKindList(av_bizid IN base_merchant.merchant_id%TYPE, --商户编码
                             av_table OUT pk_public.t_cur --账户列表
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
    --不处理默认账户和商户的有效性
    OPEN av_table FOR
      SELECT code_value, code_name
        FROM sys_code
       WHERE code_type = 'ACC_KIND'
         AND code_value IN (SELECT acc_kind
                              FROM pay_merchant_acctype t1
                             WHERE t1.merchant_id = av_bizid);

  END p_getAccKindList;
  /*=======================================================================================*/
  --根据商户号 返回消费模式
  --av_table:mode_id mode_name
  /*=======================================================================================*/
  PROCEDURE p_getPayMode(av_bizid IN base_merchant.merchant_id%TYPE, --商户编码
                         av_table OUT pk_public.t_cur --账户列表
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
  --取账户信息
  --av_table:acc_no,acc_kind,acc_name,item_no,acc_state,balance,balance_encrypt,frz_flag,frz_amt,psw
  /*=======================================================================================*/
  PROCEDURE p_getcardacc(av_cardno  VARCHAR2, --卡号
                         av_acckind VARCHAR2, --账户类型
                         av_res     OUT VARCHAR2, --传出参数代码
                         av_msg     OUT VARCHAR2, --传出参数错误信息
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
      av_msg := '取账户信息发生错误：' || SQLERRM;
  END p_getcardacc;

  /*=======================================================================================*/
  --验证终端
  /*=======================================================================================*/
  PROCEDURE p_validterm(av_bizid      IN VARCHAR2, --商户号
                        av_termid     IN VARCHAR2, --终端号
                        av_login_flag IN VARCHAR2, --1如果未签到返回错误
                        av_res        OUT VARCHAR2, --传出代码
                        av_msg        OUT VARCHAR2, --传出错误信息
                        av_merchant   OUT base_merchant%ROWTYPE --商户
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
        av_msg := '商户不存在';
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
        av_msg := '终端未签到';
        RETURN;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_termerr;
        av_msg := '终端不存在';
        RETURN;
    END;
  END p_validterm;

  /*=======================================================================================*/
  --取规则中的签到冻结参数
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
  --联机消费_计算
  --av_in: 各字段以|分割
  --       1tr_code    交易代码
  --       2card_no    卡号
  --       3tr_amt     消费金额
  --       4mode_no    消费模式
  --       5av_bizid    合作机构号
  --av_out: 账户列表acclist
  --      acclist      账户列表 acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsume_calc(av_in  IN VARCHAR2, --传入参数
                                 av_res OUT VARCHAR2, --传出代码
                                 av_msg OUT VARCHAR2, --传出错误信息
                                 av_out OUT VARCHAR2 --传出参数
                                 ) IS
    lv_count     NUMBER;
    lv_in        pk_public.myarray; --传入参数数组
    lv_mode      PAY_ACCTYPE_SQN%ROWTYPE; --消费模式
    lv_acclist   pk_public.myarray; --消费账户数组
    lv_subledger acc_account_sub%ROWTYPE; --卡分户账
    lv_tempamt   NUMBER; --分户账扣费金额
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             5, --参数最少个数
                             5, --参数最多个数
                             'pk_consume.p_onlineconsume_calc', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;

    BEGIN
      if lv_in(4) IS NULL then
        --消费模式为空时，则看当前商户是否只有一种消费模式，若有多种则异常，一种则取用
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
                  av_msg := '此商户有多种消费模式，需指定模式进行消费';
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
        --取指定的消费模式
        SELECT t.*
          INTO lv_mode
          from PAY_ACCTYPE_SQN t
         WHERE t.mode_id = lv_in(4)
           AND t.mode_state = '0';
      end if;
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_paravalueerr;
        av_msg := '没有该消费模式';
        RETURN;
    END;

    lv_count := pk_public.f_splitstr(lv_mode.ACC_SQN, '|', lv_acclist);
    IF lv_count <= 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '该消费模式没有账号';
      RETURN;
    END IF;

    --计算每个账户消费多少
    FOR i IN 1 .. lv_acclist.count LOOP
      --取卡分户账
      pk_public.p_getsubledgerbycardno(lv_in(2), --卡号
                                       lv_acclist(i), --账户类型
                                       pk_public.cs_defaultwalletid, --钱包编号
                                       lv_subledger, --分户账
                                       av_res, --传出参数代码
                                       av_msg --传出参数错误信息
                                       );
      IF av_res = pk_public.cs_res_ok THEN
        --计算扣除金额
        IF lv_subledger.bal - lv_subledger.frz_amt >= lv_in(3) THEN
          lv_tempamt := lv_in(3);
        ELSE
          --当前账户金额不足时，则扣除全部余额
          lv_tempamt := lv_subledger.bal - lv_subledger.frz_amt;
        END IF;
        lv_in(3) := lv_in(3) - lv_tempamt;
        --组装返回参数
        IF lv_tempamt > 0 THEN
          IF av_out IS NOT NULL THEN
            av_out := av_out || ',';
          END IF;
          av_out := av_out || lv_subledger.acc_kind || '$' || lv_tempamt || '$' ||
                    lv_subledger.bal || '$' || lv_subledger.bal_crypt;
        END IF;
        if lv_in(3) = 0 then
          --当消费金额为0，则退出LOOP
          exit;
        end if;
      END IF;
    END LOOP;
    IF lv_in(3) = 0 THEN
      av_res := pk_public.cs_res_ok;
      av_msg := '';
    ELSE
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '账户余额不足';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '计算联机消费发生错误：' || SQLERRM;
  END p_onlineconsume_calc;
  /*=======================================================================================*/
  --联机消费
  --av_in: 各字段以|分割
  --       1action_no    业务流水号--空的话取存储过程中取序列
  --       2tr_code      交易码
  --       3oper_id      操作员/终端号
  --       4oper_time    操作时间--空的话取存储过程中取数据库时间
  --       5acpt_id      受理点编号(网点号或商户编号)
  --       6tr_batch_no  批次号
  --       7term_tr_no   终端交易流水号
  --       8card_no      卡号
  --       9pwd          密码 为空时，则不处理
  --      10tr_amt       总交易金额
  --      11acclist      账户列表，为空时，则主动进行计算 acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      12note         备注
  --      13acpt_type    受理点分类
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsume(av_in    IN VARCHAR2, --传入参数
                            av_debug IN VARCHAR2, --1调试
                            av_res   OUT VARCHAR2, --传出代码
                            av_msg   OUT VARCHAR2, --传出错误信息
                            av_out   OUT VARCHAR2 --传出参数
                            ) IS
    lv_count            NUMBER;
    lv_in               pk_public.myarray; --传入参数数组
    lv_acclist          pk_public.myarray; --账户列表
    lv_acc              pk_public.myarray; --账户
    lv_dbsubledger      acc_account_sub%ROWTYPE; --借方分户账
    lv_crsubledger      acc_account_sub%ROWTYPE; --贷方分户账
    lv_clrdate          pay_clr_para.clr_date%type; --清分日期
    lv_accbookno        ACC_INOUT_DETAIL.ACC_INOUT_NO%TYPE; --记账流水号
    lv_card             card_baseinfo%ROWTYPE; --卡基本信息
    lv_merchant         base_merchant%ROWTYPE; --商户
    lv_merchantlimit    pay_merchant_lim%ROWTYPE; --商户消费限额表
    lv_detail_tablename varchar(50);
    lv_ACC_CREDIT_LIMIT ACC_CREDIT_LIMIT%ROWTYPE; --卡账户限制参数
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             14, --参数最少个数
                             14, --参数最多个数
                             'pk_consume.p_onlineconsume', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
      --时间大于10分钟
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '传入的业务时间和系统时间相差大于10分钟';
      RETURN;
    END IF;
    --返回action_no clr_date oper_time
    av_out := lv_in(1) || '|' || lv_clrdate || '|' || lv_in(4);
    --取卡基本信息
    pk_public.p_getcardbycardno(lv_in(8), --卡号
                                lv_card, --卡片基本信息
                                av_res, --传出参数代码
                                av_msg --传出参数错误信息
                                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --判断卡状态
    IF lv_card.card_state <> '1' THEN
      av_res := pk_public.cs_res_accstateerr;
      av_msg := '卡状态不正常';
      RETURN;
    END IF;
    --判断密码

    /*pk_public.p_judgetradepwd(lv_card, --卡信息
                              lv_in(9), --密码
                              av_res, --传出参数代码
                              av_msg --传出参数错误信息
                              );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;*/

    --检查终端是否签到
    p_validterm(lv_in(5), --商户号
                lv_in(3), --终端号
                '1', --1如果未签到返回错误
                av_res, --传出代码
                av_msg, --传出错误信息
                lv_merchant --商户的clientid
                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    lv_detail_tablename := 'ACC_INOUT_DETAIL_' ||
                           substr(REPLACE(lv_clrdate, '-', ''), 0, 6);
    --判断商户消费限额
    BEGIN
      SELECT t.*
        INTO lv_merchantlimit
        FROM pay_merchant_lim t
       WHERE t.merchant_id = lv_merchant.merchant_id;
      --是否单次超限
      IF lv_merchantlimit.lim_01 > 0 THEN
        IF lv_in(10) > lv_merchantlimit.lim_01 THEN
          av_res := pk_public.cs_res_consume_quotas_amt;
          av_msg := '商户单次消费超限额';
          RETURN;
        END IF;
      END IF;
      --是否消费次数超限
      if lv_merchantlimit.lim_02 > 0 then
        execute immediate 'select count(DEAL_NO) from ' ||
                          lv_detail_tablename ||
                          ' where DEAL_STATE=0 and DB_CARD_NO=:1 and CLR_DATE=:2 and DEAL_CODE=:3'
          into lv_count
          using lv_in(8), lv_clrdate, lv_in(2);
        if lv_merchantlimit.lim_02 <= lv_count then
          av_res := pk_public.cs_res_consume_quotas_amt;
          av_msg := '卡当日消费次数已达上限';
          return;
        end if;
      end if;
      --是否当日消费金额超限
      if lv_merchantlimit.lim_03 > 0 then
        execute immediate 'select sum(DB_AMT) from ' || lv_detail_tablename ||
                          ' where DEAL_STATE=0 and DB_CARD_NO=:1 and CLR_DATE=:2 and DEAL_CODE=:3'
          into lv_count
          using lv_in(8), lv_clrdate, lv_in(2);
        if lv_merchantlimit.lim_03 <= lv_count then
          av_res := pk_public.cs_res_consume_quotas_amt;
          av_msg := '卡当日消费总额已达上限';
          return;
        end if;
      end if;
    EXCEPTION
      WHEN no_data_found THEN
        --未配置限额就不判断
        NULL;
    END;

    --验证数据是否重复
    EXECUTE IMMEDIATE 'select count(DEAL_NO) from ' || lv_detail_tablename ||
                      ' where acpt_id=:1 and user_id=:2 and DEAL_BATCH_NO=:3 and END_DEAL_NO=:4 '
      INTO lv_count
      USING lv_in(5), lv_in(3), lv_in(6), lv_in(7);
    IF lv_count > 0 THEN
      av_res := pk_public.cs_res_rowunequalone;
      av_msg := '消费数据重复';
      RETURN;
    END IF;

    --取贷方分户账
    pk_public.p_getsubledgerbyclientid(lv_merchant.customer_id, --商户client_id
                                       pk_public.cs_accitem_biz_clr, --商户待清算款
                                       lv_crsubledger,
                                       av_res,
                                       av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;

    lv_count := pk_public.f_splitstr(lv_in(11), ',', lv_acclist);
    IF lv_count = 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '消费的账户列表不能为空';
      RETURN;
    END IF;
    FOR i IN 1 .. lv_acclist.count LOOP
      lv_count := pk_public.f_splitstr(lv_acclist(i), '$', lv_acc);
      --取借方分户账
      pk_public.p_getsubledgerbycardno(lv_in(8), --卡号
                                       lv_acc(1), --账户类型
                                       pk_public.cs_defaultwalletid, --钱包编号
                                       lv_dbsubledger, --分户账
                                       av_res, --传出参数代码
                                       av_msg --传出参数错误信息
                                       );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      -- 判断卡账户消费限额
      pk_public.p_judgecardacciftrade(lv_in(8),
                                      lv_acc(1),
                                      abs(lv_acc(2)),
                                      0,
                                      av_res,
                                      av_msg);
      --判断
      IF lv_dbsubledger.bal - lv_dbsubledger.credit_lmt < lv_acc(2) THEN
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '账户余额不足';
        RETURN;
      END IF;
      --写流水
      SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
      pk_business.p_account(lv_dbsubledger, --借方账户,
                            lv_crsubledger, --贷方账户,
                            NULL, --借方卡面交易前金额
                            NULL, --贷方卡面交易前金额
                            NULL, --借方卡片交易计数器
                            NULL, --贷方卡片交易计数器
                            lv_acc(4), --借方金额密文
                            NULL, --贷方金额密文
                            lv_acc(2), --交易金额
                            0, --信用发生额
                            lv_accbookno, --记账流水号
                            lv_in(2), --交易代码
                            lv_crsubledger.org_id, --发卡机构
                            lv_crsubledger.org_id, --受理机构
                            lv_in(13), --受理点分类
                            lv_in(5), --受理点编码(网点号/商户号等)
                            lv_in(3), --操作柜员/终端号
                            lv_in(6), --交易批次号
                            lv_in(7), --终端交易流水号
                            to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --交易时间
                            '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                            lv_in(1), --业务流水号
                            lv_in(12), --备注
                            lv_clrdate, --清分日期
                            null,
                            av_debug,
                            av_res,
                            av_msg);
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '联机消费发生错误：' || SQLERRM;
  END p_onlineconsume;

  /*=======================================================================================*/
  --联机消费充正_计算
  --av_in: 各字段以|分割
  --       1acpt_id      受理点编号(网点号或商户编号)
  --       2oper_id      操作员/终端号
  --       3tr_batch_no  批次号
  --       4term_tr_no   终端交易流水号
  --       5card_no      卡号
  --av_out: 原消费action_no|原消费clr_date|账户列表acclist
  --      acclist      账户列表 acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumecancel_calc(av_in  IN VARCHAR2, --传入参数
                                       av_res OUT VARCHAR2, --传出代码
                                       av_msg OUT VARCHAR2, --传出错误信息
                                       av_out OUT VARCHAR2 --传出参数
                                       ) IS
    lv_in           pk_public.myarray; --传入参数数组
    lv_clrdate      pay_clr_para.clr_date%type; --清分日期
    lv_cursor       pk_public.t_cur; --游标
    lv_temp         VARCHAR2(100);
    lv_tablename    VARCHAR2(50);
    lv_actionno     VARCHAR2(20); --原消费action_no
    lv_acc_input_no varchar2(50); --账务流水
    lv_count        NUMBER;
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             5, --参数最少个数
                             5, --参数最多个数
                             'pk_consume.p_onlineconsumecancel_calc', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
      --查找是否存在撤销、冲正及退货等记录
      EXECUTE IMMEDIATE 'select count(*) from ' || lv_tablename ||
                        ' where OLD_ACC_INOUT_NO=:1 and DEAL_STATE =0'
        INTO lv_count
        USING lv_acc_input_no;
      if lv_count > 0 then
        av_res := pk_public.cs_res_glideflushesed;
        av_msg := '不能重复撤销或冲正';
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
      av_msg := '消费记录不存在';
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    av_out := lv_actionno || '|' || lv_clrdate || '|' || av_out;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '计算联机消费充正发生错误：' || SQLERRM;
  END p_onlineconsumecancel_calc;

  /*=======================================================================================*/
  --联机消费撤销_计算
  --av_in: 各字段以|分割
  --       1acpt_id      受理点编号(网点号或商户编号)
  --       2oper_id      操作员/终端号
  --       3tr_batch_no  批次号
  --       4action_no   终端交易流水号
  --       5amt      卡号
  --av_out: 原消费action_no|原消费clr_date|账户列表acclist
  --      acclist      账户列表 acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumeundo_calc(av_in  IN VARCHAR2, --传入参数
                                     av_res OUT VARCHAR2, --传出代码
                                     av_msg OUT VARCHAR2, --传出错误信息
                                     av_out OUT VARCHAR2 --传出参数
                                     ) IS
    lv_in           pk_public.myarray; --传入参数数组
    lv_clrdate      pay_clr_para.clr_date%type; --清分日期
    lv_cursor       pk_public.t_cur; --游标
    lv_temp         VARCHAR2(100);
    lv_tablename    VARCHAR2(50);
    lv_actionno     VARCHAR2(20); --原消费action_no
    lv_acc_input_no varchar2(50); --账务流水
    lv_count        NUMBER;
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             5, --参数最少个数
                             5, --参数最多个数
                             'pk_consume.p_onlineconsumecancel_calc', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
      --查找是否存在撤销、冲正及退货等记录
      EXECUTE IMMEDIATE 'select count(*) from ' || lv_tablename ||
                        ' where OLD_ACC_INOUT_NO=:1 and DEAL_STATE =0'
        INTO lv_count
        USING lv_acc_input_no;
      if lv_count > 0 then
        av_res := pk_public.cs_res_glideflushesed;
        av_msg := '不能重复撤销或冲正';
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
      av_msg := '消费记录不存在';
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    av_out := lv_actionno || '|' || lv_clrdate || '|' || av_out;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '计算联机消费充正发生错误：' || SQLERRM;
  END p_onlineconsumeundo_calc;
  /*=======================================================================================*/
  --联机消费充正
  --av_in: 各字段以|分割
  --       1action_no    业务流水号
  --       2tr_code      交易码
  --       3oper_id      操作员/终端号
  --       4oper_time    操作时间
  --       5acpt_id      受理点编号(网点号或商户编号)
  --       6tr_batch_no  批次号
  --       7term_tr_no   终端交易流水号
  --       8card_no      卡号
  --       9tr_amt       总交易金额
  --      10acclist      账户列表 acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      11action_no    被充正的action_no
  --      12clr_date     被充正记录的clr_date
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumecancel(av_in    IN VARCHAR2, --传入参数
                                  av_debug IN VARCHAR2, --1调试
                                  av_res   OUT VARCHAR2, --传出代码
                                  av_msg   OUT VARCHAR2, --传出错误信息
                                  av_out   OUT VARCHAR2 --传出参数
                                  ) IS
    lv_count      NUMBER;
    lv_in         pk_public.myarray; --传入参数数组
    lv_acclist    pk_public.myarray; --账户列表
    lv_acc        pk_public.myarray; --账户
    lv_clrdate    pay_clr_para.clr_date%type; --清分日期
    lv_daybook    acc_inout_detail%ROWTYPE;
    lv_onedayBook acc_inout_detail%ROWTYPE;
    lv_sumamt     NUMBER; --传入的明细总金额
    lv_merchant   base_merchant%ROWTYPE; --商户
    lv_tablename  VARCHAR2(50);
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             12, --参数最少个数
                             12, --参数最多个数
                             'pk_consume.p_onlineconsumecancel', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
      --时间大于10分钟
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '传入的业务时间和系统时间相差大于10分钟';
      RETURN;
    END IF;
    --返回action_no clr_date oper_time
    av_out := lv_in(1) || '|' || lv_clrdate || '|' || lv_in(4);

    lv_count := pk_public.f_splitstr(lv_in(10), ',', lv_acclist);
    IF lv_count = 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '账户列表不能为空';
      RETURN;
    END IF;

    --检查终端是否签到
    p_validterm(lv_in(5), --商户号
                lv_in(3), --终端号
                '1', --1如果未签到返回错误
                av_res, --传出代码
                av_msg, --传出错误信息
                lv_merchant --商户的clientid
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
      pk_business.p_daybookcancel_onerow(lv_daybook, --要撤销daybook
                                         NULL, --sys_operator
                                         lv_in(1), --新业务流水号
                                         lv_in(12), --撤销记录的清分日期
                                         lv_clrdate, --当前清分日期
                                         lv_in(2), --交易代码
                                         NULL, --借方卡面交易前金额
                                         NULL, --贷方卡面交易前金额
                                         NULL, --借方卡片交易计数器
                                         NULL, --贷方卡片交易计数器
                                         lv_acc(4), --借方金额密文
                                         NULL, --贷方金额密文
                                         lv_acc(3) - lv_acc(2), --借方交易前金额
                                         NULL, --贷方交易前金额
                                         '1', --1直接确认
                                         av_debug, --1写调试日志
                                         av_res, --传出代码
                                         av_msg --传出错误信息
                                         );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      lv_sumamt := lv_sumamt + lv_acc(2);
    END LOOP;
    IF lv_sumamt <> lv_in(9) THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '传入参数中总金额和明细中的金额不一致';
      RETURN;
    END IF;
    EXECUTE IMMEDIATE 'select count(*) from acc_inout_detail_' ||
                      REPLACE(substr(lv_in(12), 0, 7), '-', '') ||
                      ' where deal_no = :1 and db_amt > 0 and deal_state = 0'
      INTO lv_count
      USING lv_in(11);
    IF lv_count <> 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '不能部分充正';
      RETURN;
    END IF;
    -- 更新撤销流水为传入的终端流水,否则保存的是原交易的终端流水
    EXECUTE IMMEDIATE 'update  ' || lv_tablename ||
                      ' set end_deal_no = :1  where deal_no = :2'
      USING lv_in(7), lv_in(1);
    EXECUTE IMMEDIATE 'update  pay_card_deal_rec_' ||
                      substr(REPLACE(lv_clrdate, '-', ''), 0, 6) ||
                      ' set end_deal_no = :1  where deal_no = :2'
      USING lv_in(7), lv_in(1);

    -- 如果撤销的记录有old_acc_inout_no则需要修改old_acc_inout_no
    --的记录为正常状态，同时修改pay_card_deal_rec
    IF lv_daybook.old_acc_inout_no IS NOT NULL THEN
      ---查找起始交易流水
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
      av_msg := '联机消费充正发生错误：' || SQLERRM;
  END p_onlineconsumecancel;

  /*=======================================================================================*/
  --联机消费退货_计算
  --av_in: 各字段以|分割
  --       1action_no    消费记录的业务流水号
  --       2card_no      卡号
  --       3clr_date     消费记录的清分日期
  --       4tr_amt       退货金额
  --       av_out: 账户列表acclist
  --      acclist      账户列表 acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumereturn_calc(av_in  IN VARCHAR2, --传入参数
                                       av_res OUT VARCHAR2, --传出代码
                                       av_msg OUT VARCHAR2, --传出错误信息
                                       av_out OUT VARCHAR2 --传出参数
                                       ) IS
    lv_in              pk_public.myarray; --传入参数数组
    lv_clrdate         pay_clr_para.clr_date%TYPE; --清分日期
    lv_cursor          pk_public.t_cur; --游标
    lv_tablename       VARCHAR2(50);
    lv_totaltemp       NUMBER; --总退货金额 临时变量，计算完每个账户都扣除
    lv_amt             NUMBER; --分户账退货金额
    lv_balance         NUMBER; --分户账退货前余额
    lv_balance_encrypt ACC_ACCOUNT_SUB.Bal_Crypt%TYPE; --分户账退货前金额密文
    lv_acckind         acc_account_sub.acc_kind%type; --账户类型
    lv_count           NUMBER;
    lv_acc_input_no    varchar2(50); --账务流水
    lv_temp            VARCHAR2(100);
    lv_actionno        VARCHAR2(20); --原消费action_no
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             4, --参数最少个数
                             4, --参数最多个数
                             'pk_consume.p_onlineconsumereturn_calc', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    lv_clrdate   := lv_in(3);
    lv_totaltemp := lv_in(4);

    /* lv_tablename := 'ACC_INOUT_DETAIL_' ||
    substr(REPLACE(lv_clrdate, '-', ''), 0, 6);*/
    --此处为20160302为适应嘉兴修改
    /*IF length(REPLACE(lv_clrdate,'-','')) = 8 THEN
        lv_tablename := 'ACC_INOUT_DETAIL_' || substr(REPLACE(lv_clrdate, '-', ''), 1, 6);
    --ELSIF length(REPLACE(lv_clrdate,'-','')) = 8
    ELSE
        lv_tablename := 'ACC_INOUT_DETAIL_2016' || substr(REPLACE(lv_clrdate, '-', ''), 0, 2);
    END IF;  */

    lv_tablename := 'ACC_INOUT_DETAIL_' || substr(REPLACE(lv_clrdate, '-', ''), 1, 6);
    --判断有无撤销和退货记录

    OPEN lv_cursor FOR 'select t1.ACC_INOUT_NO,t1.deal_no,t2.acc_kind || ''$'' || t1.db_amt || ''$'' || t2.bal || ''$'' || t2.bal_crypt ' || --
     ' from ' || lv_tablename || ' t1,acc_account_sub t2' || --
     ' where t1.db_acc_no = t2.acc_no and t1.deal_state = 0 ' || --
     ' and t1.acpt_id = :1 and t1.user_id = :2 and t1.deal_batch_no = :3 and t1.end_deal_no = :4 and t1.db_card_no=:5'
      USING lv_in(1), lv_in(2), lv_in(3), lv_in(4), lv_in(5);
    LOOP
      FETCH lv_cursor
        INTO lv_acc_input_no, lv_actionno, lv_temp;
      EXIT WHEN lv_cursor%NOTFOUND;
      --查找是否存在撤销、冲正及退货等记录
      EXECUTE IMMEDIATE 'select count(*) from ' || lv_tablename ||
                        ' where OLD_ACC_INOUT_NO=:1 and DEAL_STATE =0'
        INTO lv_count
        USING lv_acc_input_no;
      if lv_count > 0 then
        av_res := pk_public.cs_res_glideflushesed;
        av_msg := '流水已冲正，不可进行退货';
        RETURN;
      end if;

      IF av_out IS NOT NULL THEN
        av_out := av_out || ',';
      END IF;
      av_out := av_out || lv_temp;
    END LOOP;

    --按消费时的扣费顺序反向退货
    OPEN lv_cursor FOR 'select t1.db_amt - nvl(t1.returnamt,0) as amt,t2.acc_kind,t2.bal,t2.BAL_CRYPT from ' || lv_tablename || ' t1,acc_account_sub t2' || --
     ' where t1.db_acc_no = t2.acc_no and t1.DEAL_STATE = 0 and t1.db_amt > 0 ' || --
     ' and t1.DEAL_NO = :1 order by ACC_INOUT_NO desc'
      USING lv_in(1);
    LOOP
      FETCH lv_cursor
        INTO lv_amt, lv_acckind, lv_balance, lv_balance_encrypt;
      EXIT WHEN lv_cursor%NOTFOUND;

      IF lv_amt >= lv_totaltemp THEN
        --消费余额 > 总退货金额
        lv_amt       := lv_totaltemp;
        lv_totaltemp := 0;
      ELSE
        --消费金额 < 总退货金额
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
      av_msg := '消费记录不存在';
      RETURN;
    END IF;
    IF lv_totaltemp > 0 THEN
      av_res := pk_public.cs_res_cancelfeeerr;
      av_msg := '总退货金额大于总消费金额';
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '计算联机消费退货发生错误：' || SQLERRM;
  END p_onlineconsumereturn_calc;

  /*=======================================================================================*/
  --联机消费退货
  --av_in: 各字段以|分割
  --       1action_no    业务流水号
  --       2tr_code      交易码
  --       3oper_id      操作员/终端号
  --       4oper_time    操作时间
  --       5acpt_id      受理点编号(网点号或商户编号)
  --       6tr_batch_no  批次号
  --       7term_tr_no   终端交易流水号
  --       8card_no      卡号
  --       9tr_amt       总交易金额
  --      10acclist      账户列表 acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      11action_no    被退货的action_no
  --      12clr_date     被退货记录的clr_date
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumereturn(av_in    IN VARCHAR2, --传入参数
                                  av_debug IN VARCHAR2, --1调试
                                  av_res   OUT VARCHAR2, --传出代码
                                  av_msg   OUT VARCHAR2, --传出错误信息
                                  av_out   OUT VARCHAR2 --传出参数
                                  ) IS
    lv_count       NUMBER;
    lv_tablename   VARCHAR2(50);
    lv_in          pk_public.myarray; --传入参数数组
    lv_acclist     pk_public.myarray; --账户列表
    lv_acc         pk_public.myarray; --账户
    lv_clrdate     pay_clr_para.clr_date%TYPE; --清分日期
    lv_daybook     acc_inout_detail%ROWTYPE;
    lv_sumamt      NUMBER; --传入的明细总金额
    lv_dbsubledger acc_account_sub%ROWTYPE; --借方分户账
    lv_crsubledger acc_account_sub%ROWTYPE; --贷方分户账
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --记账流水号
    lv_merchant    base_merchant%ROWTYPE; --商户
    lv_trdate      DATE; --消费记录的交易时间
    lv_cardno      card_baseinfo%ROWTYPE;
    lv_cardconfig  card_config%ROWTYPE;
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             12, --参数最少个数
                             12, --参数最多个数
                             'pk_consume.p_onlineconsumereturn', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    --action_no
    IF lv_in(1) IS NULL THEN
      SELECT seq_action_no.nextval INTO lv_in(1) FROM dual;
    END IF;
    -- 20160302适应性修改
    lv_in(4) := to_char(SYSDATE,'yyyy-mm-dd hh24:mi:ss') ;--'20' || lv_in(4);
    --lv_in(12) := '2016' || lv_in(12);
    /*IF lv_in(4) IS NULL THEN
      lv_in(4) := to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss');
    ELSIF abs(to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss') - SYSDATE) >
          10 / 24 / 60 THEN
      --时间大于10分钟
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '传入的业务时间和系统时间相差大于10分钟';
      RETURN;
    END IF;*/
    --返回action_no clr_date oper_time
    av_out := lv_in(1) || '|' || lv_clrdate || '|' || lv_in(4);

    lv_count := pk_public.f_splitstr(lv_in(10), ',', lv_acclist);
    IF lv_count = 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '账户列表不能为空';
      RETURN;
    END IF;

    --检查终端是否签到
    p_validterm(lv_in(5), --商户号
                lv_in(3), --终端号
                '1', --1如果未签到返回错误
                av_res, --传出代码
                av_msg, --传出错误信息
                lv_merchant --商户的clientid
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

      --取借方分户账
      pk_public.p_getsubledgerbycardno(lv_daybook.db_card_no, --卡号
                                       lv_daybook.db_acc_kind, --账户类型
                                       pk_public.cs_defaultwalletid, --钱包编号
                                       lv_dbsubledger, --分户账
                                       av_res, --传出参数代码
                                       av_msg --传出参数错误信息
                                       );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      -- 判断退货是是否账户余额是否达到最大限额
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
      --取贷方分户账
      pk_public.p_getsubledgerbyclientid(lv_daybook.cr_customer_id, --商户client_id
                                         pk_public.cs_accitem_biz_clr, --商户待清算款
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
                            lv_acc(4), --借方金额密文
                            NULL, --贷方金额密文
                            -lv_acc(2), --交易金额
                            0, --信用发生额
                            lv_accbookno, --记账流水号
                            lv_in(2), --交易代码
                            lv_crsubledger.org_id, --发卡机构
                            lv_crsubledger.org_id, --受理机构
                            lv_daybook.acpt_type, --受理点分类
                            lv_daybook.acpt_id, --受理点编码(网点号/商户号等)
                            lv_in(3), --操作柜员/终端号
                            lv_in(6), --交易批次号
                            lv_in(7), --终端交易流水号
                            to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --交易时间
                            '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                            lv_in(1), --业务流水号
                            '退货，原acc_book_no:' || lv_daybook.acc_inout_no, --备注
                            lv_clrdate, --清分日期
                            lv_daybook.acc_inout_no,
                            av_debug, --1调试
                            av_res, --传出参数代码
                            av_msg --传出参数错误信息
                            );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --更改daybook原纪录的退货金额
      EXECUTE IMMEDIATE 'update acc_inout_detail_' ||
                        substr(REPLACE(lv_in(12), '-', ''), 0, 6) ||
                        ' set returnamt = nvl(returnamt,0) + :1 where deal_no = :2 and db_acc_kind = :3 and deal_state = 0 returning deal_date into :4'
        USING lv_acc(2), lv_daybook.deal_no, lv_daybook.db_acc_kind
        RETURNING INTO lv_trdate;

      --更改tr_card原纪录的退货金额
      lv_tablename := 'pay_card_deal_rec_' ||
                      substr(REPLACE(lv_in(12), '-', ''), 0, 6);
      EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                        ' set returnamt = nvl(returnamt,0) + :1 where deal_no = :2 and acc_kind = :3 and deal_state = 0'
        USING lv_acc(2), lv_daybook.deal_no, lv_daybook.db_acc_kind;

      lv_sumamt := lv_sumamt + lv_acc(2);
    END LOOP;
    IF lv_sumamt <> lv_in(9) THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '传入参数中总金额和明细中的金额不一致';
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '联机消费退货发生错误：' || SQLERRM;
  END p_onlineconsumereturn;

  /*=======================================================================================*/
  --联机消费充正_计算
  --av_in: 各字段以|分割
  --       1acpt_id      受理点编号(网点号或商户编号)
  --       2oper_id      操作员/终端号
  --       3tr_batch_no  批次号
  --       4term_tr_no   终端交易流水号
  --       5card_no      卡号
  --       av_out: 原退货action_no|原退货clr_date|账户列表acclist
  --      acclist      账户列表 acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlinereturncancel_calc(av_in  IN VARCHAR2, --传入参数
                                      av_res OUT VARCHAR2, --传出代码
                                      av_msg OUT VARCHAR2, --传出错误信息
                                      av_out OUT VARCHAR2 --传出参数
                                      ) IS
    --lv_count     number;
    lv_in        pk_public.myarray; --传入参数数组
    lv_clrdate   pay_clr_para.clr_date%TYPE; --清分日期
    lv_cursor    pk_public.t_cur; --游标
    lv_temp      VARCHAR2(100);
    lv_tablename VARCHAR2(50);
    lv_actionno  VARCHAR2(20); --原消费action_no
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             5, --参数最少个数
                             5, --参数最多个数
                             'pk_consume.p_onlinereturncancel_calc', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
      av_msg := '消费退货记录不存在';
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    av_out := lv_actionno || '|' || lv_clrdate || '|' || av_out;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '计算联机消费退货充正发生错误：' || SQLERRM;
  END p_onlinereturncancel_calc;
  /*=======================================================================================*/
  --联机消费退货充正
  --av_in: 各字段以|分割
  --       1action_no    业务流水号
  --       2tr_code      交易码
  --       3oper_id      操作员/终端号
  --       4oper_time    操作时间
  --       5acpt_id      受理点编号(网点号或商户编号)
  --       6tr_batch_no  批次号
  --       7term_tr_no   终端交易流水号
  --       8card_no      卡号
  --       9tr_amt       总交易金额
  --      10acclist      账户列表 acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      11action_no    被充正的action_no
  --      12clr_date     被充正记录的clr_date
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlinereturncancel(av_in    IN VARCHAR2, --传入参数
                                 av_debug IN VARCHAR2, --1调试
                                 av_res   OUT VARCHAR2, --传出代码
                                 av_msg   OUT VARCHAR2, --传出错误信息
                                 av_out   OUT VARCHAR2 --传出参数
                                 ) IS
    lv_count     NUMBER;
    lv_tablename VARCHAR2(50);
    lv_in        pk_public.myarray; --传入参数数组
    lv_acclist   pk_public.myarray; --账户列表
    lv_acc       pk_public.myarray; --账户
    lv_clrdate   pay_clr_para.clr_date%TYPE; --清分日期
    lv_daybook   acc_inout_detail%ROWTYPE;
    lv_sumamt    NUMBER; --传入的明细总金额
    lv_merchant  base_merchant%ROWTYPE; --商户
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             13, --参数最少个数
                             13, --参数最多个数
                             'pk_consume.p_onlinereturncancel', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
      --时间大于10分钟
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '传入的业务时间和系统时间相差大于10分钟';
      RETURN;
    END IF;
    --返回action_no clr_date oper_time
    av_out := lv_in(1) || '|' || lv_clrdate || '|' || lv_in(4);

    lv_count := pk_public.f_splitstr(lv_in(11), ',', lv_acclist);
    IF lv_count = 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '账户列表不能为空';
      RETURN;
    END IF;

    --检查终端是否签到
    p_validterm(lv_in(5), --商户号
                lv_in(3), --终端号
                '1', --1如果未签到返回错误
                av_res, --传出代码
                av_msg, --传出错误信息
                lv_merchant --商户的clientid
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
      pk_business.p_daybookcancel_onerow(lv_daybook, --要撤销daybook
                                         NULL, --sys_operator
                                         lv_in(1), --新业务流水号
                                         lv_in(13), --撤销记录的清分日期
                                         lv_clrdate, --当前清分日期
                                         lv_in(2), --交易代码
                                         NULL, --借方卡面交易前金额
                                         NULL, --贷方卡面交易前金额
                                         NULL, --借方卡片交易计数器
                                         NULL, --贷方卡片交易计数器
                                         lv_acc(4), --借方金额密文
                                         NULL, --贷方金额密文
                                         lv_acc(3) - lv_acc(2), --借方交易前金额
                                         NULL, --贷方交易前金额
                                         '1', --1直接确认
                                         av_debug, --1写调试日志
                                         av_res, --传出代码
                                         av_msg --传出错误信息
                                         );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --更新消费记录中的退货金额 (退货记录的lv_daybook.db_amt是负数)
      EXECUTE IMMEDIATE 'update acc_inout_detail_' ||
                        substr(REPLACE(lv_clrdate, '-', ''), 0, 6) ||
                        ' set returnamt = nvl(returnamt,0) + :1 where acc_inout_no = :2 and deal_state = 0'
        USING lv_daybook.db_amt, lv_daybook.old_acc_inout_no;
      --更改tr_card消费纪录的退货金额
      lv_tablename := 'pay_card_deal_rec_' ||
                      substr(REPLACE(lv_clrdate, '-', ''), 0, 6);
      EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                        ' set returnamt = nvl(returnamt,0) + :1 where acc_inout_no = :2 and deal_state = 0'
        USING lv_daybook.db_amt, lv_daybook.old_acc_inout_no;

      lv_sumamt := lv_sumamt + lv_acc(2);
    END LOOP;
    IF lv_sumamt <> lv_in(9) THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '传入参数中总金额和明细中的金额不一致';
      RETURN;
    END IF;
    EXECUTE IMMEDIATE 'select count(*) from acc_inout_detail_' ||
                      REPLACE(lv_in(12), '-', '') ||
                      ' where deal_no = :1 and db_amt < 0 and deal_state = 0'
      INTO lv_count
      USING lv_in(12);
    IF lv_count <> 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '不能部分充正';
      RETURN;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '联机消费充正发生错误：' || SQLERRM;
  END p_onlinereturncancel;

  /*=======================================================================================*/
  --POS对账
  --av_in: 各字段以|分割
  --       1acpt_id      商户编号
  --       2oper_id      终端编号
  --       3tr_batch_no  批次号
  --       4consumecount 消费笔数
  --       5consumeamt   消费金额
  --       6returncount  退货笔数
  --       7returnamt    退货金额
  --       8startdate    开始日期yyyy-mm-dd
  --       9enddate      结束日期yyyy-mm-dd
  --      10rechgcount   充值笔数
  --      11rechgamt     充值金额
  --av_out:各字段以|分割
  --       1consumecount 消费笔数
  --       2consumeamt   消费金额
  --       3returncount  退货笔数
  --       4returnamt    退货金额
  --       5rechgcount   充值笔数
  --       6rechgamt     充值金额
  /*=======================================================================================*/
  /*PROCEDURE p_posBalanceAccount(av_in  IN VARCHAR2, --传入参数
                                av_res OUT VARCHAR2, --传出代码
                                av_msg OUT VARCHAR2, --传出错误信息
                                av_out OUT VARCHAR2 --传出参数
                                ) IS
    lv_clrdate        pay_clr_para.clr_date%TYPE; --清分日期
    lv_in             pk_public.myarray; --传入参数数组
    lv_balanceaccount tr_posbalanceaccount%ROWTYPE;
    lv_tempnum        NUMBER;
    lv_tempamt        NUMBER;
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             11, --参数最少个数
                             11, --参数最多个数
                             'pk_consume.p_posBalanceAccount', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM clr_control_para;
    IF lv_in(8) IS NULL THEN
      --开始日期空，就取清分日期前3天
      lv_in(8) := to_char(to_date(lv_clrdate, 'yyyy-mm-dd') - 3,
                          'yyyy-mm-dd');
    END IF;
    --往前多查一天
    lv_in(8) := to_char(to_date(lv_in(8), 'yyyy-mm-dd') - 1, 'yyyy-mm-dd');
    IF lv_in(9) IS NULL THEN
      --结束日期空，就取清分日期
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
        --消费 db_amt > 0 and db_card_no is not null and cr_card_no is null
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
        --退货 db_amt < 0 and db_card_no is not null and cr_card_no is null
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
        --充值 db_amt > 0 and db_card_no is null and cr_card_no is not null
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
      --全平
      lv_balanceaccount.comp_flag := '00';
    ELSIF lv_balanceaccount.stat_cns_num = lv_balanceaccount.send_cns_num AND
          lv_balanceaccount.stat_cns_amt = lv_balanceaccount.send_cns_amt AND
          lv_balanceaccount.stat_ret_num = lv_balanceaccount.send_ret_num AND
          lv_balanceaccount.stat_ret_amt = lv_balanceaccount.send_ret_amt THEN
      --消费退货平
      lv_balanceaccount.comp_flag := '15';
    ELSIF lv_balanceaccount.stat_cns_num = lv_balanceaccount.send_cns_num AND
          lv_balanceaccount.stat_cns_amt = lv_balanceaccount.send_cns_amt AND
          lv_balanceaccount.stat_rechg_num =
          lv_balanceaccount.send_rechg_num AND
          lv_balanceaccount.stat_rechg_amt =
          lv_balanceaccount.send_rechg_amt THEN
      --消费充值平
      lv_balanceaccount.comp_flag := '16';
    ELSIF lv_balanceaccount.stat_ret_num = lv_balanceaccount.send_ret_num AND
          lv_balanceaccount.stat_ret_amt = lv_balanceaccount.send_ret_amt AND
          lv_balanceaccount.stat_rechg_num =
          lv_balanceaccount.send_rechg_num AND
          lv_balanceaccount.stat_rechg_amt =
          lv_balanceaccount.send_rechg_amt THEN
      --退货充值平
      lv_balanceaccount.comp_flag := '17';
    ELSIF lv_balanceaccount.stat_cns_num = lv_balanceaccount.send_cns_num AND
          lv_balanceaccount.stat_cns_amt = lv_balanceaccount.send_cns_amt THEN
      --消费平
      lv_balanceaccount.comp_flag := '12';
    ELSIF lv_balanceaccount.stat_ret_num = lv_balanceaccount.send_ret_num AND
          lv_balanceaccount.stat_ret_amt = lv_balanceaccount.send_ret_amt THEN
      --退货平
      lv_balanceaccount.comp_flag := '13';
    ELSIF lv_balanceaccount.stat_rechg_num =
          lv_balanceaccount.send_rechg_num AND
          lv_balanceaccount.stat_rechg_amt =
          lv_balanceaccount.send_rechg_amt THEN
      --充值平
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
  --脱机数据正常处理
  /*=======================================================================================*/
  PROCEDURE p_writedaybook(av_offline         IN pay_offline%ROWTYPE, --脱机文件记录
                           av_dbsubledger     IN acc_account_sub%ROWTYPE, --卡钱包账户
                           av_crsubledger     IN acc_account_sub%ROWTYPE, --商户待清算款账户
                           av_pointssubledger IN acc_account_sub%ROWTYPE, --机构积分账户
                           av_operator        IN sys_users%ROWTYPE, --操作员
                           av_clrdate         IN VARCHAR2, --清分日期
                           av_debug           IN VARCHAR2, --1调试
                           av_res             OUT VARCHAR2, --传出代码
                           av_msg             OUT VARCHAR2 --传出错误信息
                           ) IS
    lv_accbookno    acc_inout_detail.acc_inout_no%TYPE; --记账流水号
    lv_clrdate      pay_clr_para.clr_date%TYPE; --清分日期
    lv_dbsubledger  acc_account_sub%ROWTYPE; --卡账户
    lv_pointstrcode VARCHAR2(8) := '820201'; --送积分的交易代码
    --  lv_vipdiscount  prmt_biz_vip_discount%ROWTYPE; --折扣
    lv_dd TIMESTAMP := systimestamp;
  BEGIN
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    ----------------------------------------------------------------------------------
    --1、写消费记录
    ----------------------------------------------------------------------------------
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    IF av_dbsubledger.acc_no IS NULL THEN
      pk_public.p_getsubledgerbycardno(av_offline.card_no, --卡号
                                       pk_public.cs_acckind_qb, --账户类型
                                       pk_public.cs_defaultwalletid, --钱包编号
                                       lv_dbsubledger, --分户账
                                       av_res, --传出参数代码
                                       av_msg --传出参数错误信息
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
    pk_business.p_account(lv_dbsubledger, --借方账户
                          av_crsubledger, --贷方账户
                          av_offline.acc_bal, --借方卡面交易前金额
                          NULL, --贷方卡面交易前金额
                          av_offline.card_deal_count, --借方卡片交易计数器
                          NULL, --贷方卡片交易计数器
                          NULL, --借方金额密文
                          NULL, --贷方金额密文
                          av_offline.deal_amt, --交易金额
                          greatest(0,
                                   av_offline.deal_amt -
                                   (av_offline.acc_bal -
                                   av_offline.credit_limit)), --信用发生额
                          lv_accbookno, --记账流水号
                          av_offline.deal_code, --交易代码
                          av_operator.org_id, --发卡机构
                          av_operator.org_id, --受理机构
                          pk_public.cs_acpt_type_sh, --受理点分类
                          av_offline.acpt_id, --受理点编码(网点号/商户号等)
                          av_offline.end_id, --操作柜员/终端号
                          av_offline.deal_batch_no, --交易批次号
                          av_offline.end_deal_no, --终端交易流水号
                          to_date(av_offline.deal_date, 'yyyymmddhh24miss'), --交易时间
                          '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                          av_offline.deal_no, --业务流水号
                          '脱机消费', --备注
                          lv_clrdate, --清分日期
                          null,
                          av_debug, --1调试
                          av_res, --传出参数代码
                          av_msg --传出参数错误信息
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
    --2、商户返折扣
    ----------------------------------------------------------------------------------
    --先交易日期=生效日期，没有的话，找最近的那条
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
        --有折扣 借商户结算金 贷未圈存账户
        DECLARE
          lv_zkdbsubledger acc_sub_ledger%ROWTYPE; --商户结算金账户
          lv_zkcrsubledger acc_sub_ledger%ROWTYPE; --未圈存账户
          lv_zktrcode      VARCHAR2(6) := '820501'; --折扣的交易代码
        BEGIN
          --取借方分户账
          pk_public.p_getsubledgerbyclientid(av_crsubledger.client_id, --商户client_id
                                             pk_public.cs_accitem_biz_clr, --商户待清算款
                                             lv_zkdbsubledger,
                                             av_res,
                                             av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
          --取贷方分户账
          pk_public.p_getsubledgerbycardno(av_offline.card_no,
                                           '09',
                                           pk_public.cs_defaultwalletid, --钱包编号
                                           lv_zkcrsubledger,
                                           av_res,
                                           av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
          --写流水
          SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
          pk_business.p_account(lv_zkdbsubledger, --借方账户
                                lv_zkcrsubledger, --贷方账户
                                NULL, --借方卡面交易前金额
                                NULL, --贷方卡面交易前金额
                                NULL, --借方卡片交易计数器
                                NULL, --贷方卡片交易计数器
                                NULL, --借方金额密文
                                NULL, --贷方金额密文
                                av_offline.tr_amt *
                                (100 - lv_vipdiscount.discount) / 100, --交易金额
                                0, --信用发生额
                                lv_accbookno, --记账流水号
                                lv_zktrcode, --交易代码
                                av_operator.org_id, --受理机构
                                pk_public.cs_acpt_type_wd, --受理点分类
                                av_operator.brch_id, --受理点编码(网点号/商户号等)
                                av_operator.oper_id, --操作柜员/终端号
                                NULL, --交易批次号
                                NULL, --终端交易流水号
                                SYSDATE, --交易时间
                                '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                                av_offline.action_no, --业务流水号
                                '商户折扣', --备注
                                lv_clrdate, --清分日期
                                av_debug, --1调试
                                av_res, --传出参数代码
                                av_msg --传出参数错误信息
                                );
        END;
      END IF;
    END;*/

    ----------------------------------------------------------------------------------
    --3、送积分
    ----------------------------------------------------------------------------------
    /*   IF av_offline.points > 0 THEN
      pk_points.p_generate(av_pointssubledger, --积分借方分户账
                           lv_dbsubledger.card_no, --卡号
                           av_offline.points, --积分
                           lv_pointstrcode, --交易代码
                           av_operator.org_id, --受理点机构号
                           av_operator.brch_id, --受理点编码(网点号/商户号等)
                           av_operator.oper_id, --操作柜员/终端号
                           NULL, --交易批次号
                           NULL, --终端交易流水号
                           av_offline.action_no, --业务流水号
                           '赠送积分', --备注
                           lv_clrdate, --清分日期
                           av_debug, --1调试
                           av_res, --传出代码
                           av_msg --传出错误信息
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
  --脱机数据上送
  --av_in: 各字段以|分割
  --1org_id|2co_org_id|3acpt_id|4end_id|5batch_no|6ser_no|7card_no|8CARD_IN_TYPE|9CARD_IN_SUBTYPE|10CARD_VALID_DATE|
  --11Applyusedate|12Applyvaliddate|13Moneynum|14Psamid|15Psamnum|16CardBalmoney|17Trademoney|18Tradetime|19Tradetype|20Tac|
  --21Flag|22deal_state|23SEND_FILE_NAME|24FILE_LINE_NO|25TR_CODE
  --
  /*=======================================================================================*/
  PROCEDURE p_upofflineconsume(av_in    IN VARCHAR2, --传入参数
                               av_debug IN VARCHAR2, --1调试
                               av_res   OUT VARCHAR2, --传出代码
                               av_msg   OUT VARCHAR2 --传出错误信息
                               ) IS
    lv_count NUMBER;
    lv_in    pk_public.myarray; --传入参数数组
  BEGIN
    av_res := '00000000';
    pk_public.p_getinputpara(av_in, --传入参数
                             25, --参数最少个数
                             25, --参数最多个数
                             'pk_consume.p_upofflineconsume', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
      av_msg := '脱机上送发生错误：' || SQLERRM;
  END p_upofflineconsume;
  /*=======================================================================================*/
  --脱机数据处理
  --av_in: 各字段以|分割
  --       1biz_id    商户号
  --拒付原因:00－卡片发行方调整01－tac码错02－数据非法03－数据重复04－灰记录05－金额不足06-测试数据09调整拒付10正常数据
  /*=======================================================================================*/
  PROCEDURE p_offlineconsume(av_in    IN VARCHAR2, --传入参数
                             av_debug IN VARCHAR2, --1调试
                             av_res   OUT VARCHAR2, --传出代码
                             av_msg   OUT VARCHAR2 --传出错误信息
                             ) IS
    lv_dbsubledger     acc_account_sub%ROWTYPE; --卡账户
    lv_crsubledger     acc_account_sub%ROWTYPE; --商户待清算款
    lv_pointssubledger acc_account_sub%ROWTYPE; --机构积分账户
    lv_merchant        base_merchant%ROWTYPE; --商户
    lv_clrdate         pay_clr_para.clr_date%TYPE; --清分日期
    lv_tablename       VARCHAR2(50);
    lv_count           NUMBER;
    lv_sumAmt          NUMBER;
    lv_in              pk_public.myarray; --传入参数数组
    lv_operator        sys_users%ROWTYPE; --admin操作员
    lv_dd              TIMESTAMP := systimestamp;
    lv_deal_date       DATE;
    ------------------------------------------------------------------------------------
    --移到拒付表
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
    --1、取传入参数 系统参数获取
    -----------------------------------------------------------------------------------
    pk_public.p_getinputpara(av_in, --传入参数
                             1, --参数最少个数
                             1, --参数最多个数
                             'pk_consume.p_offlineconsume', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    pk_public.p_insertrzcllog_('2',
                               'p_offlineconsume begin clr_date:' || av_in,
                               pk_public.f_timestamp_diff(systimestamp,
                                                          lv_dd));
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --取商户待清算款账户
    SELECT *
      INTO lv_merchant
      FROM base_merchant
     WHERE merchant_id = lv_in(1);
    pk_public.p_getsubledgerbyclientid(lv_merchant.customer_id, --商户client_id
                                       pk_public.cs_accitem_biz_clr, --商户待清算款
                                       lv_crsubledger,
                                       av_res,
                                       av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;

    --取机构积分账户
    pk_public.p_getorgoperator(lv_merchant.org_id, --机构编号
                               lv_operator, --柜员
                               av_res, --传出参数代码
                               av_msg --传出参数错误信息
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
    --3、处理临时表数据
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
        --取卡分户账
        pk_public.p_getsubledgerbycardno(lv_offline.card_no, --卡号
                                         pk_public.cs_acckind_qb, --账户类型
                                         pk_public.cs_defaultwalletid, --钱包编号
                                         lv_dbsubledger, --分户账
                                         av_res, --传出参数代码
                                         av_msg --传出参数错误信息
                                         );
        -------------------------------------------------------------------------------
        --3.0、判断交易时间格式是否正确
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
        --3.1、账户不存在02
        -------------------------------------------------------------------------------
        IF av_res <> pk_public.cs_res_ok THEN
          p_move2black(lv_offline.deal_no, '02');
          GOTO templooplabel;
        END IF;
        -------------------------------------------------------------------------------
        --3.2、数据重复03
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
        --3.3、tac错01 灰记录04
        -------------------------------------------------------------------------------
        IF lv_offline.refuse_reason IN ('01', '04') THEN
          p_move2black(lv_offline.deal_no, lv_offline.refuse_reason);
          GOTO templooplabel;
        ELSIF lv_offline.ash_flag = '01' THEN
          p_move2black(lv_offline.deal_no, '04');
          GOTO templooplabel;
        END IF;
        -------------------------------------------------------------------------------
        --3.4、金额不足05
        -------------------------------------------------------------------------------
        IF lv_offline.deal_amt > lv_dbsubledger.bal THEN
          p_move2black(lv_offline.deal_no, '05');
          GOTO templooplabel;
        END IF;
        -------------------------------------------------------------------------------
        --3.5、测试数据06
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        --3.6、正常数据
        -------------------------------------------------------------------------------
        pk_public.p_insertrzcllog_('2',
                                   'p_offlineconsume begin p_writedaybook:' ||
                                   av_in,
                                   pk_public.f_timestamp_diff(systimestamp,
                                                              lv_dd));
        --写流水 折扣 积分
        p_writedaybook(lv_offline, --脱机文件记录
                       lv_dbsubledger, --卡钱包账户
                       lv_crsubledger, --商户待清算款账户
                       lv_pointssubledger, --机构积分账户
                       lv_operator, --操作员
                       lv_clrdate, --清分日期
                       av_debug, --1调试
                       av_res, --传出代码
                       av_msg --传出错误信息
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
        --移动数据
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
        --3.7、记录处理结束
        -------------------------------------------------------------------------------
        <<templooplabel>>
        NULL;
        COMMIT;
      END LOOP;
      UPDATE pay_offline_filename
         SET state = '3'
       WHERE send_file_name = lv_filename.send_file_name
         /*AND state = '2'*/;

      --更新处理结果的确认笔数和确认金额，拒付笔数和拒付金额 ，调整笔数和调整金额
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
        --已处理，continue
        av_res := -1;
        av_msg := '另外进程在处理，退出';
        RETURN;
      ELSE
        COMMIT;
      END IF;
    END LOOP;

    -----------------------------------------------------------------------------------
    --4、处理拒付表中的灰记录
    -----------------------------------------------------------------------------------
    FOR lv_offline IN (SELECT t.*
                         FROM pay_offline_black t
                        WHERE acpt_id = lv_in(1)
                          AND refuse_reason IN ('01', '04')) LOOP
      --取卡分户账
      pk_public.p_getsubledgerbycardno(lv_offline.card_no, --卡号
                                       pk_public.cs_acckind_qb, --账户类型
                                       pk_public.cs_defaultwalletid, --钱包编号
                                       lv_dbsubledger, --分户账
                                       av_res, --传出参数代码
                                       av_msg --传出参数错误信息
                                       );
      -------------------------------------------------------------------------------
      --4.1、账户不存在02
      -------------------------------------------------------------------------------
      IF av_res <> pk_public.cs_res_ok THEN
        UPDATE pay_offline_black
           SET refuse_reason = '02'
         WHERE deal_no = lv_offline.deal_no;
        GOTO blacklooplabel;
      END IF;
      -------------------------------------------------------------------------------
      --4.2、数据重复03
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
      --4.3、金额不足05
      -------------------------------------------------------------------------------
      IF lv_offline.deal_amt > lv_dbsubledger.bal THEN
        --金额不足的不更改拒付原因
        GOTO blacklooplabel;
      END IF;
      -------------------------------------------------------------------------------
      --4.4、测试数据06
      -------------------------------------------------------------------------------
      -------------------------------------------------------------------------------
      --4.5、根据下一条记录判断是否能调整
      -------------------------------------------------------------------------------
      --找下一卡交易流水的记录
      DECLARE
        lv_temptablename VARCHAR2(50);
        lv_trdate        DATE;
      BEGIN
        lv_trdate := to_date(substrb(lv_offline.deal_date, 1, 6), 'yyyymm');
        WHILE lv_trdate <= trunc(SYSDATE, 'mm') --可以设置成超过一个月就不处理
         LOOP
          lv_temptablename := pk_public.f_gettrcardtable(lv_offline.card_no,
                                                         lv_trdate);
          EXECUTE IMMEDIATE 'select count(*) from ' || lv_temptablename ||
                            ' where card_no = :1 and card_counter = :2  and amt < 0 and acc_kind = ''01'''
            INTO lv_count
            USING lv_offline.card_no, lv_offline.card_deal_count + 1;
          IF lv_count > 0 THEN
            --存在下一条记录
            EXECUTE IMMEDIATE 'select count(*) from ' || lv_temptablename ||
                              ' where card_no = :1 and card_counter = :2 and card_bal = :3  and amt < 0 and acc_kind = ''01'''
              INTO lv_count
              USING lv_offline.card_no, lv_offline.card_deal_count + 1, lv_offline.acc_bal - lv_offline.deal_amt;
            IF lv_count > 0 THEN
              --调整
              UPDATE pay_offline_black
                 SET refuse_reason = '00', clr_date = lv_clrdate
               WHERE deal_no = lv_offline.deal_no;
              --写流水 折扣 积分
              p_writedaybook(lv_offline, --脱机文件记录
                             lv_dbsubledger, --卡钱包账户
                             lv_crsubledger, --商户待清算款账户
                             lv_pointssubledger, --机构积分账户
                             lv_operator, --操作员
                             lv_clrdate, --清分日期
                             av_debug, --1调试
                             av_res, --传出代码
                             av_msg --传出错误信息
                             );
              IF av_res <> pk_public.cs_res_ok THEN
                --ROLLBACK;
                --GOTO blacklooplabel;
                RETURN;
              END IF;
              --移动数据
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
              --调整拒付
              UPDATE pay_offline_black
                 SET refuse_reason = '09'
               WHERE deal_no = lv_offline.deal_no;
            END IF;
            EXIT;
          ELSE
            --当前月不存在，找下个月的记录
            lv_trdate := add_months(lv_trdate, 1);
          END IF;
        END LOOP;
      END; --结束根据下一条记录判断是否能调整

      -------------------------------------------------------------------------------
      --4.6、记录处理结束
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
  --脱机消费灰记录确认
  --av_in: 各字段以|分割
  --       action_no
  /*=======================================================================================*/
  PROCEDURE p_ashconfirm(av_in    IN VARCHAR2, --传入参数
                         av_debug IN VARCHAR2, --1调试
                         av_res   OUT VARCHAR2, --传出代码
                         av_msg   OUT VARCHAR2 --传出错误信息
                         ) IS
    lv_tablename       VARCHAR2(50);
    lv_offline         pay_offline%ROWTYPE;
    lv_clrdate         pay_clr_para.clr_date%TYPE; --清分日期
    lv_crsubledger     acc_account_sub%ROWTYPE; --商户待清算款
    lv_pointssubledger acc_account_sub%ROWTYPE; --机构积分账户
    lv_merchant        base_merchant%ROWTYPE; --商户
    lv_in              pk_public.myarray; --传入参数数组
    lv_operator        sys_users%ROWTYPE; --admin操作员
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             1, --参数最少个数
                             1, --参数最多个数
                             'pk_consume.p_ashconfirm', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
        av_msg := '未找到流水号为' || lv_in(1) || '的消费灰记录';
        RETURN;
    END;
    IF lv_offline.deal_amt < 0 THEN
      --如果是退货的灰记录  账户流水确认，积分在写灰记录时已经扣除
      pk_business.p_ashconfirm(lv_clrdate, --清分日期
                               lv_offline.deal_no, --业务流水号
                               NULL, --借方金额密文
                               NULL, --贷方金额密文
                               av_debug, --1写调试日志
                               av_res, --传出代码
                               av_msg --传出错误信息
                               );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    ELSE
      --取商户待清算款账户
      SELECT *
        INTO lv_merchant
        FROM base_merchant
       WHERE merchant_id = lv_offline.acpt_id;
      pk_public.p_getsubledgerbyclientid(lv_merchant.customer_id, --商户client_id
                                         pk_public.cs_accitem_biz_clr, --商户待清算款
                                         lv_crsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      pk_public.p_getorgoperator(lv_merchant.org_id, --机构编号
                                 lv_operator, --柜员
                                 av_res, --传出参数代码
                                 av_msg --传出参数错误信息
                                 );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --取机构积分账户
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
      --调整
      UPDATE pay_offline_black
         SET refuse_reason = '00', clr_date = lv_clrdate, deal_state = '0'
       WHERE deal_no = lv_offline.deal_no;
      --写流水 折扣 积分
      p_writedaybook(lv_offline, --脱机文件记录
                     NULL, --卡钱包账户
                     lv_crsubledger, --商户待清算款账户
                     lv_pointssubledger, --机构积分账户
                     lv_operator, --操作员
                     lv_clrdate, --清分日期
                     av_debug, --1调试
                     av_res, --传出代码
                     av_msg --传出错误信息
                     );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
    --移动数据
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
  --脱机消费退货
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no  原action_no
  --       6clr_date   原消费记录的清分日期
  --       7card_bal   钱包交易前金额
  --       8card_tr_count卡交易计数器
  /*=======================================================================================*/
  PROCEDURE p_offlineconsumereturn(av_in    IN VARCHAR2, --传入参数
                                   av_debug IN VARCHAR2, --1调试
                                   av_res   OUT VARCHAR2, --传出代码
                                   av_msg   OUT VARCHAR2 --传出错误信息
                                   ) IS
    --lv_offline      tr_offline%ROWTYPE;
    lv_tablename    VARCHAR2(50);
    lv_newtablename VARCHAR2(50);
    lv_in           pk_public.myarray; --传入参数数组
    lv_clrdate      pay_clr_para.clr_date%TYPE; --清分日期
    lv_cardno       VARCHAR2(20); --卡号
    lv_points       NUMBER; --积分
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             8, --参数最少个数
                             8, --参数最多个数
                             'pk_consume.p_offlineconsumereturn', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    -- lv_tablename    := 'tr_offline_' || REPLACE(lv_in(6), '-', '');
    -- lv_newtablename := 'tr_offline_black'; --先写灰记录，再确认 'tr_offline_' || REPLACE(lv_clrdate, '-', '');
    --更新原记录
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
      av_msg := '未找到流水号为' || lv_in(5) || '的未退货消费记录';
      RETURN;
    END IF;
    --新增退货记录
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
    --撤销积分
    /* IF lv_points <> 0 THEN
      pk_points.p_generatecancel(lv_cardno, --卡号
                                 lv_points, --积分
                                 lv_in(6), --清分日期
                                 av_res, --传出代码
                                 av_msg --传出错误信息
                                 );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;*/
    --撤销账户流水
    pk_business.p_daybookcancel(lv_in(5), --要撤销业务流水号
                                lv_in(1), --新业务流水号
                                lv_in(6), --撤销记录的清分日期
                                lv_clrdate, --当前清分日期
                                lv_in(2), --交易代码
                                NULL, --lv_in(3), --柜员编号
                                lv_in(7), --借方卡面交易前金额
                                NULL, --贷方卡面交易前金额
                                lv_in(8), --借方卡片交易计数器
                                NULL, --贷方卡片交易计数器
                                NULL, --借方金额密文
                                NULL, --贷方金额密文
                                '0', --1直接确认
                                av_debug, --1写调试日志
                                av_res, --传出代码
                                av_msg --传出错误信息
                                );
  END p_offlineconsumereturn;

  /*=======================================================================================*/
  --脱机消费灰记录冲正 --更改状态为已冲正
  --av_in: 各字段以|分割
  --       action_no
  /*=======================================================================================*/
  PROCEDURE p_ashcancel(av_in    IN VARCHAR2, --传入参数
                        av_debug IN VARCHAR2, --1调试
                        av_res   OUT VARCHAR2, --传出代码
                        av_msg   OUT VARCHAR2 --传出错误信息
                        ) IS
    lv_offline   pay_offline%ROWTYPE;
    lv_in        pk_public.myarray; --传入参数数组
    lv_tablename VARCHAR2(50);
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             1, --参数最少个数
                             1, --参数最多个数
                             'pk_consume.p_ashcancel', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
        av_msg := '未找到流水号为' || lv_in(1) || '的消费灰记录';
        RETURN;
    END;
    UPDATE pay_offline_black SET deal_state = '2' WHERE deal_no = lv_in(1);
    IF lv_offline.deal_amt < 0 THEN
      --退货灰记录，更改原纪录的状态，积分加回去
      --撤销积分
      /*   pk_points.p_generatecancel(lv_offline.card_no, --卡号
                                 lv_offline.points, --积分
                                 lv_offline.clr_date, --清分日期-------------------
                                 av_res, --传出代码
                                 av_msg --传出错误信息
                                 );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;*/
      --更新原记录
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
      av_msg := '脱机消费灰记录冲正发生错误：' || SQLERRM;
  END p_ashcancel;
  /*=======================================================================================*/
  --脱机消费拒付改成正常
  --av_in: 各字段以|分割
  --       action_no
  /*=======================================================================================*/
  PROCEDURE p_black2normal(av_in    IN VARCHAR2, --传入参数
                           av_debug IN VARCHAR2, --1调试
                           av_res   OUT VARCHAR2, --传出代码
                           av_msg   OUT VARCHAR2 --传出错误信息
                           ) IS
    lv_tablename       VARCHAR2(50);
    lv_offline         pay_offline%ROWTYPE;
    lv_in              pk_public.myarray; --传入参数数组
    lv_crsubledger     acc_account_sub%ROWTYPE; --商户待清算款
    lv_pointssubledger acc_account_sub%ROWTYPE; --机构积分账户
    lv_merchant        base_merchant%ROWTYPE; --商户
    lv_operator        sys_users%ROWTYPE; --操作员
    lv_clrdate         pay_clr_para.clr_date%TYPE; --清分日期
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             1, --参数最少个数
                             1, --参数最多个数
                             'pk_consume.p_cancel2normal', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
        av_msg := '未找到流水号为' || lv_in(1) || '的消费记录';
        RETURN;
    END;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --取商户待清算款账户
    SELECT *
      INTO lv_merchant
      FROM base_merchant
     WHERE merchant_id = lv_offline.acpt_id;
    pk_public.p_getsubledgerbyclientid(lv_merchant.customer_id, --商户client_id
                                       pk_public.cs_accitem_biz_clr, --商户待清算款
                                       lv_crsubledger,
                                       av_res,
                                       av_msg);
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;

    --取机构积分账户
    pk_public.p_getorgoperator(lv_merchant.org_id, --机构编号
                               lv_operator, --柜员
                               av_res, --传出参数代码
                               av_msg --传出参数错误信息
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
    --写流水 折扣 积分
    p_writedaybook(lv_offline, --脱机文件记录
                   NULL, --卡钱包账户
                   lv_crsubledger, --商户待清算款账户
                   lv_pointssubledger, --机构积分账户
                   lv_operator, --操作员
                   lv_clrdate, --清分日期
                   av_debug, --1调试
                   av_res, --传出代码
                   av_msg --传出错误信息
                   );
    IF av_res <> pk_public.cs_res_ok THEN
      --ROLLBACK;
      --GOTO templooplabel;
      RETURN;
    END IF;
    --移动数据
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
      av_msg := '脱机消费灰记录冲正发生错误：' || SQLERRM;
  END p_black2normal;
  /*=======================================================================================*/
  --取人员基本信息
  --av_in: 各字段以|分割  card_no|cert_no|sub_card_no|
  /*=======================================================================================*/
  PROCEDURE p_getPersonalInfo(av_in    VARCHAR2, --入参
                              av_debug IN VARCHAR2, --1调试
                              av_res   OUT VARCHAR2, --传出参数代码
                              av_msg   OUT VARCHAR2, --传出参数错误信息
                              av_table OUT pk_public.t_cur) IS
    lv_in pk_public.myarray; --传入参数数组
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             3, --参数最少个数
                             3, --参数最多个数
                             'pk_consume.p_onlineconsume_calc', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
      av_msg := '取账户信息发生错误：' || SQLERRM;
  END p_getPersonalInfo;
  /*=======================================================================================*/
  --获取消费模式，根据传入参数
  --av_in: 1merchant_id|
  --       2acc_kind|
  --       3cousume_type  0 单账户消费 1 复合消费
  /*=======================================================================================*/
  PROCEDURE p_getConsumeMode(av_in           IN VARCHAR2, --传入参数
                             av_debug        IN VARCHAR2, --1调试
                             av_res          OUT VARCHAR2, --传出代码
                             av_msg          OUT VARCHAR2, --传出错误信息
                             av_consume_mode OUT VARCHAR2 --传出消费模式
                             ) is
    lv_count NUMBER;
    lv_in    pk_public.myarray; --传入参数数组
  begin
    --分切参数
    pk_public.p_getinputpara(av_in, --传入参数
                             3, --参数最少个数
                             3, --参数最多个数
                             'pk_consume.p_onlineconsume_calc', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --根据商户号和账户类型进行消费模式的查找
    IF lv_in(3) is null or lv_in(3) > 1 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '传入参数不能为空或格式不正确';
    END IF;
    --获取商户消费模式
    BEGIN
      IF lv_in(3) = 0 THEN
        --单账户消费 必须传入账户类型
        IF lv_in(2) IS NULL THEN
          av_res := '1';
          av_msg := '选择单账户消费模式时，请输入消费账户';
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
          av_msg := '未找到唯一的一种综合消费模式，请检查输入参数或联系系统管理员';
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
        av_msg := '未找到相关的消费模式配置';
    END;
  end p_getConsumeMode;
  /*=======================================================================================*/
  --签到促销
  --每次消费者签到，从经营户的商户卡里扣0.4元给会员卡的未圈存账户上；
  --  同时每月签到30次及以上的次月给予10元买菜金的奖励，
  --      每年签到100次及以上的另外给予10元买菜金。
  /*=======================================================================================*/
  /* PROCEDURE p_signpromotion(as_filename VARCHAR2, --签到文件名
                            av_debug    IN VARCHAR2, --1调试
                            av_res      OUT VARCHAR2, --传出代码
                            av_msg      OUT VARCHAR2 --传出错误信息
                            ) IS
    lv_send_money   NUMBER;
    lv_dbsubledger1 acc_sub_ledger%ROWTYPE; --商户结算金账户
    --lv_dbsubledger2  acc_sub_ledger%ROWTYPE; --商户待清算账户
    lv_crsubledger   acc_sub_ledger%ROWTYPE; --卡未圈存账户
    lv_operator      sys_operator%ROWTYPE; --操作员
    lv_merchant      bs_merchant%ROWTYPE; --商户
    lv_accbookno     acc_daybook.acc_book_no%TYPE; --记账流水号
    lv_bizsigntrcode VARCHAR2(8) := '820301'; --商户签到促销的交易代码
    lv_clrdate       clr_control_para.clr_date%TYPE; --清分日期
    lv_obj           json;
    lv_count         NUMBER;
    lv_oldactionno   NUMBER;
  BEGIN
    SELECT clr_date INTO lv_clrdate FROM clr_control_para;

    --先删除重复
    --当日已存在生成促销记录
    DELETE FROM prmt_signin_list t
     WHERE send_file_name = as_filename
       AND ROWID <> (SELECT MIN(ROWID)
                       FROM prmt_signin_list
                      WHERE biz_id = t.biz_id
                        AND card_no = t.card_no
                        AND trunc(tr_date, 'dd') = trunc(t.tr_date, 'dd')
                        AND deal_state = '0');
    --删除未生成促销记录中的重复
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
        --重复
        NULL;
      ELSE
        --取未圈存账户
        pk_public.p_getsubledgerbycardno(lv_sign.card_no,
                                         pk_public.cs_acckind_wqc, --未圈存账户
                                         pk_public.cs_defaultwalletid, --钱包编号
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
            --取商户结算金账户
            pk_public.p_getsubledgerbyclientid(lv_merchant.client_id, --商户client_id
                                               pk_public.cs_accitem_biz_clr, --商户待清算款
                                               lv_dbsubledger1,
                                               av_res,
                                               av_msg);
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
            /*--取商户待清算款账户
            pk_public.p_getsubledgerbyclientid(lv_merchant.client_id, --商户client_id
                                               pk_public.cs_accitem_biz_clr, --商户待清算款
                                               lv_dbsubledger2,
                                               av_res,
                                               av_msg);
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
            --取机构虚拟柜员
            pk_public.p_getorgoperator(lv_merchant.org_id, --机构编号
                                       lv_operator, --柜员
                                       av_res, --传出参数代码
                                       av_msg --传出参数错误信息
                                       );
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
            --冻结的action_no
            SELECT MAX(action_no)
              INTO lv_oldactionno
              FROM prmt_signin_apply
             WHERE biz_id = lv_merchant.biz_id
               AND apply_date = to_char(lv_sign.tr_date, 'yyyy-mm-dd');
          END;
          --调用规则---------------------
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
          --每次消费者签到，从经营户的商户卡里扣0.4元给会员卡的未圈存账户上；
          SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
          pk_business.p_account(lv_dbsubledger1, --借方账户
                                lv_crsubledger, --贷方账户
                                NULL, --借方卡面交易前金额
                                NULL, --贷方卡面交易前金额
                                NULL, --借方卡片交易计数器
                                NULL, --贷方卡片交易计数器
                                NULL, --借方金额密文
                                NULL, --贷方金额密文
                                lv_send_money, --交易金额
                                0, --信用发生额
                                lv_accbookno, --记账流水号
                                lv_bizsigntrcode, --交易代码
                                lv_operator.org_id, --受理机构
                                pk_public.cs_acpt_type_wd, --受理点分类
                                lv_sign.biz_id, --受理点编码(网点号/商户号等)
                                lv_operator.oper_id, --操作柜员/终端号
                                NULL, --交易批次号
                                NULL, --终端交易流水号
                                SYSDATE, --交易时间
                                '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                                lv_sign.action_no, --业务流水号
                                '商户签到促销', --备注
                                lv_clrdate, --清分日期
                                av_debug, --1调试
                                av_res, --传出参数代码
                                av_msg --传出参数错误信息
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
          --解除冻结，写解冻流水
          UPDATE acc_sub_ledger
             SET frz_amt = frz_amt - lv_send_money
           WHERE acc_no = lv_dbsubledger2.acc_no;
          --写冻结流水
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
      --全部已处理，更改状态
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
  --签到促销
  --  同时每月签到30次及以上的次月给予10元买菜金的奖励，
  /*=======================================================================================*/
  /* PROCEDURE p_signpromotion_month(as_month VARCHAR2, --月份 yyyy-mm
                                  av_debug IN VARCHAR2, --1调试
                                  av_res   OUT VARCHAR2, --传出代码
                                  av_msg   OUT VARCHAR2 --传出错误信息
                                  ) IS
    lv_month_send_money NUMBER;
    lv_dbsubledger2     acc_sub_ledger%ROWTYPE; --机构促销支出账户
    lv_crsubledger      acc_sub_ledger%ROWTYPE; --卡未圈存账户
    lv_operator         sys_operator%ROWTYPE; --操作员
    lv_merchant         bs_merchant%ROWTYPE; --商户
    lv_accbookno        acc_daybook.acc_book_no%TYPE; --记账流水号
    lv_signawardtrcode  VARCHAR2(8) := '820302'; --签到奖励的交易代码
    lv_clrdate          clr_control_para.clr_date%TYPE; --清分日期
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
      --调用规则---------------------
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
        --取未圈存账户
        pk_public.p_getsubledgerbycardno(lv_sign.card_no,
                                         pk_public.cs_acckind_wqc, --未圈存账户
                                         pk_public.cs_defaultwalletid, --钱包编号
                                         lv_crsubledger,
                                         av_res,
                                         av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
        --取机构促销支出账户
        BEGIN
          SELECT *
            INTO lv_merchant
            FROM bs_merchant
           WHERE biz_id = lv_sign.biz_id;
          pk_public.p_getorgoperator(lv_merchant.org_id, --机构编号
                                     lv_operator, --柜员
                                     av_res, --传出参数代码
                                     av_msg --传出参数错误信息
                                     );
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
          --取机构促销支出账户
          pk_public.p_getorgsubledger(lv_operator.org_id,
                                      pk_public.cs_accitem_org_prmt_out,
                                      lv_dbsubledger2,
                                      av_res,
                                      av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
        END;
        --每月签到30次及以上的次月给予10元买菜金的奖励，
        SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
        pk_business.p_account(lv_dbsubledger2, --借方账户
                              lv_crsubledger, --贷方账户
                              NULL, --借方卡面交易前金额
                              NULL, --贷方卡面交易前金额
                              NULL, --借方卡片交易计数器
                              NULL, --贷方卡片交易计数器
                              NULL, --借方金额密文
                              NULL, --贷方金额密文
                              lv_month_send_money, --交易金额
                              0, --信用发生额
                              lv_accbookno, --记账流水号
                              lv_signawardtrcode, --交易代码
                              lv_operator.org_id, --受理机构
                              pk_public.cs_acpt_type_wd, --受理点分类
                              lv_sign.biz_id, --受理点编码(网点号/商户号等)
                              lv_operator.oper_id, --操作柜员/终端号
                              NULL, --交易批次号
                              NULL, --终端交易流水号
                              SYSDATE, --交易时间
                              '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                              lv_actionno, --业务流水号
                              '月签到达到次数奖励', --备注
                              lv_clrdate, --清分日期
                              av_debug, --1调试
                              av_res, --传出参数代码
                              av_msg --传出参数错误信息
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
  --签到促销
  --  每年签到100次及以上的另外给予10元买菜金。
  /*=======================================================================================*/
  /* PROCEDURE p_signpromotion_year(as_year  VARCHAR2, --年份 yyyy
                                 av_debug IN VARCHAR2, --1调试
                                 av_res   OUT VARCHAR2, --传出代码
                                 av_msg   OUT VARCHAR2 --传出错误信息
                                 ) IS
    lv_year_send_money NUMBER;
    lv_dbsubledger2    acc_sub_ledger%ROWTYPE; --机构促销支出账户
    lv_crsubledger     acc_sub_ledger%ROWTYPE; --卡未圈存账户
    lv_operator        sys_operator%ROWTYPE; --操作员
    lv_merchant        bs_merchant%ROWTYPE; --商户
    lv_accbookno       acc_daybook.acc_book_no%TYPE; --记账流水号
    lv_signawardtrcode VARCHAR2(8) := '820302'; --签到奖励的交易代码
    lv_clrdate         clr_control_para.clr_date%TYPE; --清分日期
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
      --调用规则---------------------
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
        --取未圈存账户
        pk_public.p_getsubledgerbycardno(lv_sign.card_no,
                                         pk_public.cs_acckind_wqc, --未圈存账户
                                         pk_public.cs_defaultwalletid, --钱包编号
                                         lv_crsubledger,
                                         av_res,
                                         av_msg);
        IF av_res <> pk_public.cs_res_ok THEN
          RETURN;
        END IF;
        --取机构促销支出账户
        BEGIN
          SELECT *
            INTO lv_merchant
            FROM bs_merchant
           WHERE biz_id = lv_sign.biz_id;
          pk_public.p_getorgoperator(lv_merchant.org_id, --机构编号
                                     lv_operator, --柜员
                                     av_res, --传出参数代码
                                     av_msg --传出参数错误信息
                                     );
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
          --取机构促销支出账户
          pk_public.p_getorgsubledger(lv_operator.org_id,
                                      pk_public.cs_accitem_org_prmt_out,
                                      lv_dbsubledger2,
                                      av_res,
                                      av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;
        END;
        --每年签到100次及以上的另外给予10元买菜金。
        SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
        pk_business.p_account(lv_dbsubledger2, --借方账户
                              lv_crsubledger, --贷方账户
                              NULL, --借方卡面交易前金额
                              NULL, --贷方卡面交易前金额
                              NULL, --借方卡片交易计数器
                              NULL, --贷方卡片交易计数器
                              NULL, --借方金额密文
                              NULL, --贷方金额密文
                              lv_year_send_money, --交易金额
                              0, --信用发生额
                              lv_accbookno, --记账流水号
                              lv_signawardtrcode, --交易代码
                              lv_operator.org_id, --受理机构
                              pk_public.cs_acpt_type_wd, --受理点分类
                              lv_sign.biz_id, --受理点编码(网点号/商户号等)
                              lv_operator.oper_id, --操作柜员/终端号
                              NULL, --交易批次号
                              NULL, --终端交易流水号
                              SYSDATE, --交易时间
                              '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                              lv_actionno, --业务流水号
                              '年签到达到次数奖励', --备注
                              lv_clrdate, --清分日期
                              av_debug, --1调试
                              av_res, --传出参数代码
                              av_msg --传出参数错误信息
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
  --其它促销
  --VIP卡每日赠送1元买菜金，一年365元
  /*=======================================================================================*/
  /* PROCEDURE p_vippromotion(av_trdate IN VARCHAR2, --日期yyyy-mm-dd
                           av_debug  IN VARCHAR2, --1调试
                           av_res    OUT VARCHAR2, --传出代码
                           av_msg    OUT VARCHAR2 --传出错误信息
                           ) IS
    lv_send_money_vip      NUMBER;
    lv_send_money_bankcard NUMBER;
    lv_operator            sys_operator%ROWTYPE; --操作员
    lv_actionno            acc_daybook.action_no%TYPE; --业务流水号
    lv_accbookno           acc_daybook.acc_book_no%TYPE; --记账流水号
    lv_clrdate             clr_control_para.clr_date%TYPE; --清分日期
    lv_obj                 json;
    lv_cursor              pk_public.t_cur; --游标
    lv_tablename           VARCHAR2(50);
    lv_sql                 VARCHAR2(4000);
    lv_card                cm_card_00%ROWTYPE; --卡基本信息
    lv_dbsubledger         acc_sub_ledger%ROWTYPE; --机构促销支出账户
    lv_crsubledger         acc_sub_ledger%ROWTYPE; --卡未圈存账户
    lv_vipawardtrcode      VARCHAR2(8) := '820304'; --VIP每日赠送的交易代码
    lv_bindbankawardtrcode VARCHAR2(8) := '820303'; --VIP每日赠送的交易代码

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
        --调用规则---------------------
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
            pk_public.p_getorgoperator(lv_card.org_id, --机构编号
                                       lv_operator, --柜员
                                       av_res, --传出参数代码
                                       av_msg --传出参数错误信息
                                       );
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
            --取机构促销支出账户
            pk_public.p_getorgsubledger(lv_operator.org_id,
                                        pk_public.cs_accitem_org_prmt_out,
                                        lv_dbsubledger,
                                        av_res,
                                        av_msg);
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
          END IF;
          --取未圈存账户
          pk_public.p_getsubledgerbycardno(lv_card.card_no,
                                           pk_public.cs_acckind_wqc, --未圈存账户
                                           pk_public.cs_defaultwalletid, --钱包编号
                                           lv_crsubledger,
                                           av_res,
                                           av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            pk_public.p_insertrzcllog('其它促销：' || av_msg, 0);
            av_res := pk_public.cs_res_ok;
          ELSE
            IF lv_send_money_vip > 0 THEN
              SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
              pk_business.p_account(lv_dbsubledger, --借方账户
                                    lv_crsubledger, --贷方账户
                                    NULL, --借方卡面交易前金额
                                    NULL, --贷方卡面交易前金额
                                    NULL, --借方卡片交易计数器
                                    NULL, --贷方卡片交易计数器
                                    NULL, --借方金额密文
                                    NULL, --贷方金额密文
                                    lv_send_money_vip, --交易金额
                                    0, --信用发生额
                                    lv_accbookno, --记账流水号
                                    lv_vipawardtrcode, --交易代码
                                    lv_operator.org_id, --受理机构
                                    pk_public.cs_acpt_type_wd, --受理点分类
                                    lv_operator.brch_id, --受理点编码(网点号/商户号等)
                                    lv_operator.oper_id, --操作柜员/终端号
                                    NULL, --交易批次号
                                    NULL, --终端交易流水号
                                    to_date(av_trdate, 'yyyy-mm-dd'), --交易时间
                                    '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                                    lv_actionno, --业务流水号
                                    'VIP卡每日赠送', --备注
                                    lv_clrdate, --清分日期
                                    av_debug, --1调试
                                    av_res, --传出参数代码
                                    av_msg --传出参数错误信息
                                    );
              IF av_res <> pk_public.cs_res_ok THEN
                RETURN;
              END IF;
            END IF;
            IF lv_send_money_bankcard > 0 THEN
              SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
              pk_business.p_account(lv_dbsubledger, --借方账户
                                    lv_crsubledger, --贷方账户
                                    NULL, --借方卡面交易前金额
                                    NULL, --贷方卡面交易前金额
                                    NULL, --借方卡片交易计数器
                                    NULL, --贷方卡片交易计数器
                                    NULL, --借方金额密文
                                    NULL, --贷方金额密文
                                    lv_send_money_bankcard, --交易金额
                                    0, --信用发生额
                                    lv_accbookno, --记账流水号
                                    lv_bindbankawardtrcode, --交易代码
                                    lv_operator.org_id, --受理机构
                                    pk_public.cs_acpt_type_wd, --受理点分类
                                    lv_operator.brch_id, --受理点编码(网点号/商户号等)
                                    lv_operator.oper_id, --操作柜员/终端号
                                    NULL, --交易批次号
                                    NULL, --终端交易流水号
                                    to_date(av_trdate, 'yyyy-mm-dd'), --交易时间
                                    '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                                    lv_actionno, --业务流水号
                                    '签订银行卡绑定协议，每月获赠', --备注
                                    lv_clrdate, --清分日期
                                    av_debug, --1调试
                                    av_res, --传出参数代码
                                    av_msg --传出参数错误信息
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
    --账户金额冻结
    参数信息
    --       1deal_no       操作流水号
    --       2acpt_id       受理点编号(网点号或商户编号)
    --       3acpt_type     受理点分类
    --       4user_id       操作员/终端号
    --       5deal_time     操作时间--空的话取存储过程中取数据库时间  格式 YYYYMMDDHHMISS
    --       6card_no       卡号
    --       7acc_kind      账户类型
    --       8pwd           密码
    --       9freezeamt     冻结金额
    --       10amt           冻结前余额
    --       11deal_batch_no 批次号
    --       12end_deal_no   终端交易流水号
    --       13end_id       终端编号
    --       14freeze_type  冻结类型
    --       15note         备注
  */
  procedure p_accFreeze(av_in    in varchar2,
                        av_debug in varchar2,
                        av_res   out varchar2,
                        av_msg   out varchar2,
                        av_out   out varchar2) as
    lv_in              pk_public.myarray; --传入参数数组
    lv_clrdate         pay_clr_para.clr_date%TYPE; --清分日期
    lv_card            card_baseinfo%rowtype;
    lv_acc_account_sub acc_account_sub%rowtype;
    --lv_deal_no acc_freeze_rec.deal_no%type;
    isAllFreeze  varchar2(1);
    lv_amt       acc_account_sub.bal%type;
    lv_deal_time date;
  begin
    pk_public.p_getinputpara(av_in, --传入参数
                             12, --参数最少个数
                             15, --参数最多个数
                             'pk_consume.accFreeze', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    --解析请求参数信息
    if av_res <> pk_public.cs_res_ok then
      return;
    end if;
    --获取清分日期信息
    begin
      select sysdate into lv_deal_time from dual;
      select clr_date into lv_clrdate from pay_clr_para t;
    exception
      when no_data_found then
        av_res := pk_public.cs_res_unknownerr;
        av_msg := '清分日期配置信息不存在';
        return;

    end;
    --冻结卡号不能为空
    if lv_in(6) is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '冻结卡号不能为空';
      return;
    end if;
    --冻结账户类型不能为空
    if lv_in(7) is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '冻结账户类型不能为空';
      return;
    end if;
    --冻结金额不正确
    if lv_in(9) is null or lv_in(9) <= 0 then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '冻结金额不正确';
      return;
    end if;
    if lv_in(5) is null then
      lv_in(5) := to_char(lv_deal_time, 'yyyymmddhh24miss');
    end if;
    --获取卡片信息
    pk_public.p_getcardbycardno(lv_in(6), lv_card, av_res, av_msg);
    if av_res <> pk_public.cs_res_ok THEN
      return;
    end if;
    --判断卡状态
    if lv_card.card_state <> '1' then
      av_res := pk_public.cs_res_accstateerr;
      av_msg := '卡状态不正常';
      return;
    end if;
    pk_public.p_getsubledgerbycardno(lv_in(6), --卡号
                                     lv_in(7), --账户类型
                                     pk_public.cs_defaultwalletid, --钱包编号
                                     lv_acc_account_sub, --分户账
                                     av_res, --传出参数代码
                                     av_msg --传出参数错误信息
                                     );
    if av_res <> pk_public.cs_res_ok THEN
      return;
    end if;
    --判断账户状态是否锁定
    if lv_acc_account_sub.acc_state <> '1' then
      av_res := pk_public.cs_res_accstateerr;
      av_msg := '账户状态不正常';
      return;
    end if;
    if lv_acc_account_sub.bal - lv_acc_account_sub.credit_lmt -
       lv_acc_account_sub.frz_amt < lv_in(9) THEN
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '账户余额不足';
      return;
    end if;
    --如果此时已冻结金额 + 新冻结金额 = 账户余额  则为2全部冻结 否则是1部分冻结
    if lv_acc_account_sub.bal = (lv_acc_account_sub.frz_amt + lv_in(9)) then
      isAllFreeze := '2';
    else
      isAllFreeze := '1';
    end if;
    --更新账户的冻结余额,冻结标志
    update acc_account_sub t
       set t.frz_amt  = nvl(t.frz_amt, 0) + lv_in(9),
           t.frz_date = lv_deal_time,
           t.frz_flag = isAllFreeze
     where t.card_no = lv_in(6)
       and t.acc_kind = lv_in(7) return t.bal into lv_amt;
    if sql%rowcount <> 1 then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '更新数据' || sql%rowcount || '行';
      return;
    end if;
    if lv_amt <> lv_in(10) then
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '账户原始金额有变动，请重新进行操作';
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
      (lv_in(1), --流水号
       lv_in(2), --受理点
       lv_in(13), --受理终端编号
       lv_in(11), --批次号
       lv_in(12), --终端交易流水号
       to_date(lv_in(5), 'yyyymmddhh24miss'), --处理日期
       0,
       lv_in(9),
       50601010, --冻结交易码
       lv_in(14), --冻结类型
       lv_acc_account_sub.acc_no,
       lv_in(6),
       lv_in(7),
       isAllFreeze,
       (lv_acc_account_sub.bal - to_number(lv_in(9))),
       --'',--原始流水号
       lv_deal_time, --入库时间
       lv_in(4), --处理柜员
       '0', --受理类型
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
    --账户金额解冻
    参数信息
    --       1deal_no       流水号
    --       2acpt_id       受理点编号(网点号或商户编号)
    --       3acpt_type     受理点分类
    --       4user_id       操作员/终端号
    --       5deal_time     操作时间--空的话取存储过程中取数据库时间
    --       6old_deal_no   原始冻结流水
    --       7pwd           密码
    --       8deal_batch_no 批次号
    --       9end_deal_no   终端交易流水号
    --       10end_id        终端编号
    --       11note         备注
  */
  procedure p_accUnFreeze(av_in    in varchar2,
                          av_debug in varchar2,
                          av_res   out varchar2,
                          av_msg   out varchar2,
                          av_out   out varchar2) as
    lv_in         pk_public.myarray; --传入参数数组
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
    pk_public.p_getinputpara(av_in, --传入参数
                             11, --参数最少个数
                             11, --参数最多个数
                             'pk_consume.accUnFreeze', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    --解析请求参数信息
    if av_res <> pk_public.cs_res_ok then
      return;
    end if;
    --获取清分日期信息
    begin
      select sysdate into lv_deal_time from dual;
      select clr_date into lv_clrdate from pay_clr_para;
    exception
      when no_data_found then
        av_res := pk_public.cs_res_unknownerr;
        av_msg := '清分日期配置信息不存在';
        return;

    end;
    if lv_in(6) is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '原始账户冻结流水不能为空';
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
        av_msg := '根据原始冻结流水未找到有效的账户冻结记录信息或已成功解冻不能重复解冻';
        return;
    end;
    if lv_acc_freeze.rec_type <> '0' then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '原始账户冻结记录状态不正常';
      return;
    end if;
    pk_public.p_getsubledgerbycardno(lv_acc_freeze.card_no, --卡号
                                     lv_acc_freeze.acc_kind, --账户类型
                                     pk_public.cs_defaultwalletid, --钱包编号
                                     lv_acc_account_sub, --分户账
                                     av_res, --传出参数代码
                                     av_msg --传出参数错误信息
                                     );
    if av_res <> pk_public.cs_res_ok THEN
      return;
    end if;
    if lv_acc_account_sub.bal < lv_acc_freeze.frz_amt then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '解冻金额大于账户余额';
      return;
    end if;
    --移入历史表  是否控制同一网点或是同一商户的解冻呢?
    lv_acc_freeze.rec_type             := '1';
    lv_acc_freeze.cancel_deal_batch_no := lv_in(8);
    lv_acc_freeze.cancel_end_deal_no   := lv_in(9);
    lv_acc_freeze.cancel_reason        := lv_in(11);
    insert into acc_freeze_his values lv_acc_freeze;
    if lv_in(1) is null then
      select seq_action_no.nextval into lv_in(1) from dual;
    end if;
    lv_acc_freeze.deal_no       := lv_in(1); --新流水
    lv_acc_freeze.old_deal_no   := lv_in(6); --原始流水
    lv_acc_freeze.rec_type      := '0'; --解冻记录状态
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
    --如果账户冻结金额和解冻金额相同 则账户改为正常状态,否则 改为部分冻结
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
    --更新账户的冻结余额,冻结标志
    update acc_account_sub t
       set t.frz_amt  = nvl(t.frz_amt, 0) - lv_acc_freeze.frz_amt,
           t.frz_date = lv_last_update_time,
           t.frz_flag = isAllFreeze
     where t.card_no = lv_acc_freeze.card_no
       and t.acc_kind = lv_acc_freeze.acc_kind return t.bal,
     t.frz_amt into lv_amt, lv_freeze_amt;
    if sql%rowcount <> 1 then
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '更新数据' || sql%rowcount || '行';
      return;
    end if;
    if lv_freeze_amt < 0 then
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '解冻金额大于账户冻结总金额';
      return;
    end if;
    if lv_amt <> lv_acc_account_sub.bal then
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '账户原始金额有变动，请重新进行操作';
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
  --脱机数据处理twz
  --av_deal_no 流水号
  --拒付原因:00－卡片发行方调整01－tac码错02－数据非法03－数据重复04－灰记录05－金额不足06-测试数据09调整拒付10正常数据
  /*=======================================================================================*/
  PROCEDURE p_offlineconsume_twz(av_deal_no    IN VARCHAR2, --传入参数
                             av_debug IN VARCHAR2, --1调试
                             av_res   OUT VARCHAR2, --传出代码
                             av_msg   OUT VARCHAR2 --传出错误信息
                             ) is 
        lv_dbsubledger     acc_account_sub%ROWTYPE; --卡账户
        lv_crsubledger     acc_account_sub%ROWTYPE; --商户待清算款
        lv_pointssubledger acc_account_sub%ROWTYPE; --机构积分账户
        lv_merchant        base_merchant%ROWTYPE; --商户
        lv_clrdate         pay_clr_para.clr_date%TYPE; --清分日期
        lv_tablename       VARCHAR2(50);
        lv_count           NUMBER;
        lv_sumAmt          NUMBER;
        lv_in              pk_public.myarray; --传入参数数组
        lv_operator        sys_users%ROWTYPE; --admin操作员
        lv_dd              TIMESTAMP := systimestamp;
        lv_deal_date       DATE;
        lv_offline         pay_offline%rowtype;
        ------------------------------------------------------------------------------------
        --移到拒付表
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
          --1、取传入参数 系统参数获取
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
          
          --取商户待清算款账户
          SELECT *
            INTO lv_merchant
            FROM base_merchant
           WHERE merchant_id = lv_offline.acpt_id;
          pk_public.p_getsubledgerbyclientid(lv_merchant.customer_id, --商户client_id
                                             pk_public.cs_accitem_biz_clr, --商户待清算款
                                             lv_crsubledger,
                                             av_res,
                                             av_msg);
          IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
          END IF;

          --取机构积分账户
          pk_public.p_getorgoperator(lv_merchant.org_id, --机构编号
                                     lv_operator, --柜员
                                     av_res, --传出参数代码
                                     av_msg --传出参数错误信息
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
          --3、处理临时表数据
          -----------------------------------------------------------------------------------
          pk_public.p_insertrzcllog_('2',
                                     'p_offlineconsume begin temp:' || av_Deal_no,
                                     pk_public.f_timestamp_diff(systimestamp,
                                                                lv_dd));
          
          --取卡分户账
          pk_public.p_getsubledgerbycardno(lv_offline.card_no, --卡号
                                           pk_public.cs_acckind_qb, --账户类型
                                           pk_public.cs_defaultwalletid, --钱包编号
                                           lv_dbsubledger, --分户账
                                           av_res, --传出参数代码
                                           av_msg --传出参数错误信息
                                           );
          -------------------------------------------------------------------------------
          --3.0、判断交易时间格式是否正确
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
          --3.1、账户不存在02
          -------------------------------------------------------------------------------
          IF av_res <> pk_public.cs_res_ok THEN
            p_move2black(lv_offline.deal_no, '02');
             GOTO templooplabel;
          END IF;
          
          -------------------------------------------------------------------------------
          --3.2、tac错01 灰记录04
          -------------------------------------------------------------------------------
          IF lv_offline.refuse_reason IN ('01', '04') THEN
            p_move2black(lv_offline.deal_no, lv_offline.refuse_reason);
              GOTO templooplabel;
          ELSIF lv_offline.ash_flag = '01' THEN
            p_move2black(lv_offline.deal_no, '04');
              GOTO templooplabel;
          END IF;
          
          -------------------------------------------------------------------------------
          --3.4、金额不足05
          -------------------------------------------------------------------------------
          IF lv_offline.deal_amt > lv_dbsubledger.bal THEN
            p_move2black(lv_offline.deal_no, '05');
              GOTO templooplabel;
          END IF;
                    
          -------------------------------------------------------------------------------
          --3.3、数据重复03
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
          --3.5、测试数据06
          -------------------------------------------------------------------------------
          -------------------------------------------------------------------------------
          --3.6、正常数据
          -------------------------------------------------------------------------------
          pk_public.p_insertrzcllog_('2',
                                     'p_offlineconsume begin p_writedaybook:' ||
                                     av_Deal_no,
                                     pk_public.f_timestamp_diff(systimestamp,
                                                                lv_dd));
          --写流水 折扣 积分
          p_writedaybook(lv_offline, --脱机文件记录
                         lv_dbsubledger, --卡钱包账户
                         lv_crsubledger, --商户待清算款账户
                         lv_pointssubledger, --机构积分账户
                         lv_operator, --操作员
                         lv_clrdate, --清分日期
                         av_debug, --1调试
                         av_res, --传出代码
                         av_msg --传出错误信息
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
          --移动数据
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
            --3.7、记录处理结束
            -------------------------------------------------------------------------------
             <<templooplabel>>
            COMMIT;
            select count(1) into lv_count from pay_offline t where t.send_file_name = lv_offline.send_file_name;
            if lv_count = 0 then
                UPDATE pay_offline_filename
                       SET state = '3'
                WHERE send_file_name = lv_offline.send_file_name
                       AND state = '2';
                 --更新处理结果的确认笔数和确认金额，拒付笔数和拒付金额 ，调整笔数和调整金额
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

