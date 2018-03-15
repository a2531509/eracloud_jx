CREATE OR REPLACE PACKAGE BODY pk_consume_ghk IS
  /*=======================================================================================*/
  --联机消费_判断卡号是否准许消费

  --merchantid IN VARCHAR2,--商户编号
  --cardno     IN VARCHAR2,--卡号
  --sqn_mode   IN varchar2,--商户消费模式merchantid      商户号

  /*=======================================================================================*/
    PROCEDURE p_checkIDinfo(merchantid IN VARCHAR2,--商户编号
                          cardno     IN VARCHAR2,--卡号
                          sqn_mode   IN VARCHAR2,--商户消费模式
                          av_sqn_mode OUT pay_acctype_sqn%ROWTYPE,--传出消费模式
                          av_res      OUT VARCHAR2, --传出代码
                          av_msg      OUT VARCHAR2 --传出错误信息
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
             av_msg := '商户信息验证失败';
             RETURN;
        END;
         BEGIN
             SELECT * INTO lv_card FROM card_baseinfo t WHERE t.card_no = cardno;
             IF lv_card.customer_id IS NOT NULL THEN
                 select * INTO lv_base_person FROM base_personal t WHERE t.customer_id = lv_card.customer_id;
                 IF lv_base_person.cert_no IS NOT NULL THEN
                    --查询工会人员信息是否属于这个商户
                    /*SELECT a.attr_merchant_id INTO lv_unionbizid FROM base_unionist@con_union_link a WHERE a.card_no = cardno;
                    IF lv_unionbizid <> lv_base_merchant.merchant_id THEN
                        av_res :=pk_public.cs_res_checkcongh_walerr;
                        av_msg :='该人人员不准许在该商户下消费';
                        RETURN;
                    END IF;*/
                    --判断该卡是否开过该商户下关联的消费模式对应的账户
                    if sqn_mode IS NULL  then
                        --消费模式为空时，则看当前商户是否只有一种消费模式，若有多种则异常，一种则取用
                        select count(*) into lv_count from  BASE_MERCHANT_MODE t where t.merchant_id=merchantid and t.mode_state='0';
                        if lv_count <> 1 then
                          av_res := pk_public.cs_res_paravalueerr;
                          av_msg := '此商户有多种消费模式，需指定模式进行消费';
                          return;
                        end if;
                        select t.* into av_sqn_mode
                        from PAY_ACCTYPE_SQN t where t.mode_id = (select b.mode_id from BASE_MERCHANT_MODE b where b.merchant_id=merchantid and t.mode_state='0');
                    ELSE
                        --判断传入的消费模式是否属于该商户
                        SELECT COUNT(1) INTO lv_count FROM base_merchant_mode t WHERE t.merchant_id = merchantid AND t.mode_id = sqn_mode;
                        IF lv_count = 0 THEN
                            av_res := pk_public.cs_res_sqnmode_mererr;
                            av_msg := '传入的商户消费模式不正确';
                        END IF;
                        --取指定的消费模式
                        SELECT COUNT(1) INTO lv_count FROM PAY_ACCTYPE_SQN y WHERE y.mode_id =sqn_mode;
                        IF lv_count = 0 THEN
                            av_res := pk_public.cs_res_sqnmode_mererr;
                            av_msg := '传入的商户消费模式不正确';
                        END IF;
                        SELECT t.*
                          INTO av_sqn_mode
                          from PAY_ACCTYPE_SQN t
                          WHERE t.mode_id = sqn_mode
                          AND t.mode_state = '0';

                    end if;
                 ELSE
                     av_res := pk_public.cs_res_personalvil_err;
                     av_msg := '客户信息验证失败';
                     RETURN;
                 END IF;
             ELSE
               av_res := pk_public.cs_res_cardiderr;
               av_msg := '未找到对应的卡信息';
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
            av_msg :='数据库未知错误';
            RETURN;

    END  p_checkIDinfo;

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
  --获取账户打折信息，返回该账户折扣后金额，记录此次消费的折扣信息
  /*=======================================================================================*/
  PROCEDURE p_getrealdealamt(av_bizid      IN VARCHAR2, --商户号
                        av_acc_kind     IN VARCHAR2, --账户号
                        av_amt          IN NUMBER,--原始交易金额
                        av_discount_info OUT VARCHAR2,--折扣率
                        av_real_amt      OUT VARCHAR2,--实际消费金额
                        av_res        OUT VARCHAR2, --传出代码
                        av_msg        OUT VARCHAR2 --传出错误信息
                        ) IS
     lv_base_merchant_discount base_merchant_discount%ROWTYPE;
     ls_days    pk_public.myarray; --用户打折方式内容数组
     ln_count   NUMBER;
     as_clrdate varchar2(10);
     ln_three_amt NUMBER;

      --判断是否到达打折条件条件 如果没有直接返回无打折的金额
      FUNCTION f_candiscount(as_clrdate     VARCHAR2,
                            lv_base_merchant_discount base_merchant_discount%Rowtype) RETURN VARCHAR2 IS
        ls_days  pk_public.myarray;
        ln_count NUMBER;
      BEGIN
        IF lv_base_merchant_discount.DISCOUNT_TYPE = '2' THEN  -- 周方式的打折
            --判断今天是否打折
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

         ELSIF lv_base_merchant_discount.DISCOUNT_TYPE = '2' THEN  -- 月打折方式
            ln_count := pk_public.f_splitstr(lv_base_merchant_discount.discount_txt, '|', ls_days);
            FOR i IN 1 .. ln_count LOOP
              IF to_number(substr(as_clrdate, 9, 2)) = to_number(ls_days(i)) --日子相同
                 OR ls_days(i) = 32 AND --或设置月底结算并且是月底
                 to_date(as_clrdate, 'yyyy-mm-dd') =
                 last_day(to_date(as_clrdate, 'yyyy-mm-dd')) THEN
                RETURN '1';
              END IF;
            END LOOP;
         ELSIF lv_base_merchant_discount.DISCOUNT_TYPE = '1' THEN  -- 指定日期打折方式
           IF lv_base_merchant_discount.discount_txt = as_clrdate THEN
              RETURN '1';
           END IF;
         ELSE --没有配置就按照0打折的方式进行计算
            RETURN '0';
         END IF;
        --没到结算条件
        RETURN '0';
      END f_candiscount;
  BEGIN


     av_res :=pk_public.cs_res_ok;
     SELECT t.clr_date INTO as_clrdate FROM pay_clr_para t;
     --获取最新生效的打折信息
     BEGIN
       SELECT * INTO lv_base_merchant_discount FROM base_merchant_discount t
              WHERE t.merchant_id =av_bizid AND t.acc_kind = av_acc_kind AND STARTDATE =
               (SELECT MAX(STARTDATE)
                  FROM base_merchant_discount
                 WHERE merchant_id = av_bizid
                   AND acc_kind = av_acc_kind
                   AND STATE = '1'
                   AND STARTDATE <= SYSDATE);
     --开始计算该账户的实际消费金额
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
           av_msg := '未找到任何折扣信息';

     END;




  END p_getrealdealamt;

 /*=======================================================================================*/
  --联机消费_计算
  --av_in: 各字段以|分割
  --       1tr_code    交易代码
  --       2card_no    卡号
  --       3tr_amt     消费金额
  --       4mode_no    消费模式
  --       5av_bizid    合作机构号/商户编号
  --av_out: 账户列表acclist
  --      acclist      账户列表 acc_kind$amt$balance$balance_encrypt$discount$accname,acc_kind$amt$balance$balance_encrypt$discount$accname
  /*=======================================================================================*/
  PROCEDURE p_onlineconsume_calc(av_in  IN VARCHAR2, --传入参数
                                 av_res OUT VARCHAR2, --传出代码
                                 av_msg OUT VARCHAR2, --传出错误信息
                                 av_out OUT VARCHAR2, --传出参数
                                 av_cash_amt OUT VARCHAR2--现金付款金额
                                 ) IS
    lv_count     NUMBER;
    lv_in        pk_public.myarray; --传入参数数组
    lv_mode      PAY_ACCTYPE_SQN%ROWTYPE; --消费模式
    lv_acclist   pk_public.myarray; --消费账户数组
    lv_subledger acc_account_sub%ROWTYPE; --卡分户账
    lv_tempamt   NUMBER; --分户账扣费金额
    lv_realamt   NUMBER;
    lv_discountinfo NUMBER;
    lv_merchantlimit pay_merchant_lim%ROWTYPE; --
    lv_detail_tablename varchar(50);
    lv_clrdate       pay_clr_para.clr_date%type; --清分日期
    lv_acc_name  VARCHAR2(50);
    lv_real_discoutamt NUMBER;
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
       p_checkIDinfo(lv_in(5),
                     lv_in(2),
                     lv_in(4),
                     lv_mode,
                     av_res,
                     av_msg);
       IF av_res <> pk_public.cs_res_ok THEN
           av_res := pk_public.cs_res_sqngetmode_mererr;
           av_msg := '验证客户和商户绑定数据出错';
            RETURN;
       END IF;
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_paravalueerr;
        av_msg := '验证客户和商户绑定数据出错';
        RETURN;
    END;

    lv_count := pk_public.f_splitstr(lv_mode.ACC_SQN, '|', lv_acclist);
    IF lv_count <= 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '该消费模式没有账号';
      RETURN;
    END IF;
    --判断商户消费限额
    BEGIN
      SELECT t.*
        INTO lv_merchantlimit
        FROM pay_merchant_lim t
       WHERE t.merchant_id = lv_in(5);
       --是否单次超限
      IF lv_merchantlimit.lim_01 > 0 THEN
        IF lv_in(10) > lv_merchantlimit.lim_01 THEN
          av_res := pk_public.cs_res_consume_quotas_amt;
          av_msg := '商户单次消费超限额';
          RETURN;
        END IF;
      END IF;
      --是否消费次数超限
      if lv_merchantlimit.lim_02 >0 then
         execute immediate 'select count(DEAL_NO) from '||lv_detail_tablename||' where DEAL_STATE=0 and DB_CARD_NO=:1 and CLR_DATE=:2 and DEAL_CODE=:3'
         into lv_count
         using lv_in(8),lv_clrdate,lv_in(2);
         if lv_merchantlimit.lim_02 <= lv_count then
           av_res := pk_public.cs_res_consume_quotas_amt;
           av_msg := '卡当日消费次数已达上限';
           return;
         end if;
      end if;
      --是否当日消费金额超限
      if lv_merchantlimit.lim_03 >0 then
         execute immediate 'select sum(DB_AMT) from '||lv_detail_tablename||' where DEAL_STATE=0 and DB_CARD_NO=:1 and CLR_DATE=:2 and DEAL_CODE=:3'
         into lv_count
         using lv_in(8),lv_clrdate,lv_in(2);
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
        --取该账户的打折金额

         p_getrealdealamt(lv_in(5),lv_acclist(i),lv_in(3),lv_discountinfo,lv_realamt,av_res,av_msg);

         lv_real_discoutamt := lv_in(3)*(lv_discountinfo/100);
         IF av_res <> pk_public.cs_res_ok THEN
            RETURN;
         END IF;
        --计算扣除金额
        lv_in(3) := lv_realamt;
        IF lv_subledger.bal - lv_subledger.frz_amt >= lv_realamt THEN
          lv_tempamt := lv_realamt;
        ELSE
          --当前账户金额不足时，则扣除全部余额
          lv_tempamt := lv_subledger.bal - lv_subledger.frz_amt;
        END IF;
        lv_in(3) := lv_in(3) - lv_tempamt;
        lv_real_discoutamt :=  lv_real_discoutamt - lv_tempamt;
        --组装返回参数
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
          --当消费金额为0，则退出LOOP
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
    lv_count         NUMBER;
    lv_in            pk_public.myarray; --传入参数数组
    lv_acclist       pk_public.myarray; --账户列表
    lv_acc           pk_public.myarray; --账户
    lv_dbsubledger   acc_account_sub%ROWTYPE;--借方分户账
    lv_crsubledger   acc_account_sub%ROWTYPE; --贷方分户账
    lv_clrdate       pay_clr_para.clr_date%type; --清分日期
    lv_accbookno     ACC_INOUT_DETAIL.ACC_INOUT_NO%TYPE; --记账流水号
    lv_card          card_baseinfo%ROWTYPE; --卡基本信息
    lv_merchant      base_merchant%ROWTYPE; --商户
    lv_merchantlimit pay_merchant_lim%ROWTYPE; --商户消费限额表
    lv_detail_tablename varchar(50);
    lv_ACC_CREDIT_LIMIT ACC_CREDIT_LIMIT%ROWTYPE;--卡账户限制参数
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
    lv_detail_tablename := 'ACC_INOUT_DETAIL_' || substr(REPLACE(lv_clrdate, '-', ''),0,6);




    --验证数据是否重复
    EXECUTE IMMEDIATE 'select count(DEAL_NO) from ' ||
                      lv_detail_tablename ||
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
                            lv_crsubledger.org_id,--发卡机构
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
    lv_in        pk_public.myarray; --传入参数数组
    lv_clrdate   pay_clr_para.clr_date%type; --清分日期
    lv_cursor    pk_public.t_cur; --游标
    lv_temp      VARCHAR2(100);
    lv_tablename VARCHAR2(50);
    lv_actionno  VARCHAR2(20); --原消费action_no
    lv_acc_input_no varchar2(50);--账务流水
    lv_count         NUMBER;
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
      --查找是否存在撤销、冲正及退货等记录
      EXECUTE IMMEDIATE 'select count(*) from ' ||lv_tablename||' where OLD_ACC_INOUT_NO=:1 and DEAL_STATE =0'
        INTO lv_count
        USING lv_acc_input_no;
      if lv_count >0 then
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
    lv_in        pk_public.myarray; --传入参数数组
    lv_clrdate   pay_clr_para.clr_date%type; --清分日期
    lv_cursor    pk_public.t_cur; --游标
    lv_temp      VARCHAR2(100);
    lv_tablename VARCHAR2(50);
    lv_actionno  VARCHAR2(20); --原消费action_no
    lv_acc_input_no varchar2(50);--账务流水
    lv_count         NUMBER;
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
      --查找是否存在撤销、冲正及退货等记录
      EXECUTE IMMEDIATE 'select count(*) from ' ||lv_tablename||' where OLD_ACC_INOUT_NO=:1 and DEAL_STATE =0'
        INTO lv_count
        USING lv_acc_input_no;
      if lv_count >0 then
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
    lv_count    NUMBER;
    lv_in       pk_public.myarray; --传入参数数组
    lv_acclist  pk_public.myarray; --账户列表
    lv_acc      pk_public.myarray; --账户
    lv_clrdate  pay_clr_para.clr_date%type; --清分日期
    lv_daybook  acc_inout_detail%ROWTYPE;
    lv_onedayBook acc_inout_detail%ROWTYPE;
    lv_sumamt   NUMBER; --传入的明细总金额
    lv_merchant base_merchant%ROWTYPE; --商户
    lv_tablename VARCHAR2(50);
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

    lv_tablename := 'ACC_INOUT_DETAIL_' || substr(REPLACE(lv_clrdate, '-', ''),0,6);
    lv_sumamt := 0;
    FOR i IN 1 .. lv_acclist.count LOOP
      lv_count := pk_public.f_splitstr(lv_acclist(i), '$', lv_acc);
      EXECUTE IMMEDIATE 'select * from ' ||lv_tablename||' where deal_no = :1 and db_acc_kind = :2 and DEAL_STATE = 0'
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
   /* IF lv_sumamt <> lv_in(9) THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '传入参数中总金额和明细中的金额不一致';
      RETURN;
    END IF;*/
    EXECUTE IMMEDIATE 'select count(*) from acc_inout_detail_' ||
                      REPLACE(substr(lv_in(12),0,7), '-', '') ||
                      ' where deal_no = :1 and db_amt > 0 and deal_state = 0'
      INTO lv_count
      USING lv_in(11);
    IF lv_count <> 0 THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '不能部分充正';
      RETURN;
    END IF;
    -- 更新撤销流水为传入的终端流水,否则保存的是原交易的终端流水
    EXECUTE IMMEDIATE 'update  ' ||lv_tablename||' set end_deal_no = :1  where deal_no = :2'
        USING lv_in(7), lv_in(1);
    EXECUTE IMMEDIATE 'update  pay_card_deal_rec_' ||substr(REPLACE(lv_clrdate, '-', ''),0,6)||' set end_deal_no = :1  where deal_no = :2'
        USING lv_in(7), lv_in(1);

    -- 如果撤销的记录有old_acc_inout_no则需要修改old_acc_inout_no
    --的记录为正常状态，同时修改pay_card_deal_rec
    IF lv_daybook.old_acc_inout_no IS NOT NULL THEN
         ---查找起始交易流水
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
      av_msg := '联机消费充正发生错误：' || SQLERRM;
  END p_onlineconsumecancel;

  procedure p_uniondkdskqrorcancel(av_db_acc_no        varchar2, --借方账户
                       av_cr_acc_no        varchar2, --贷方账户
                       av_dbcardbal        number, --借方交易前卡面金额
                       av_crcardbal        number, --贷方交易前卡面金额
                       av_dbcardcounter    NUMBER, --借方卡片交易计数器
                       av_crcardcounter    NUMBER, --贷方卡片交易计数器
                       av_dbbalanceencrypt IN VARCHAR2, --借方金额密文
                       av_crbalanceencrypt IN VARCHAR2, --贷方金额密文
                       av_tramt            acc_inout_detail.db_amt%TYPE, --交易金额
                       av_credit           acc_inout_detail.db_credit_amt%TYPE, --信用发生额
                       av_accbookno        acc_inout_detail.acc_inout_no%TYPE, --记账流水号
                       av_trcode           acc_inout_detail.deal_code%TYPE, --交易代码
                       av_issueorgid       acc_inout_detail.card_org_id%TYPE, --发卡机构
                       av_orgid            acc_inout_detail.acpt_org_id%TYPE, --受理机构
                       av_acpttype         acc_inout_detail.acpt_type%TYPE, --受理点分类
                       av_acptid           acc_inout_detail.acpt_id%TYPE, --受理点编码(网点号/商户号等)
                       av_operid           acc_inout_detail.user_id%TYPE, --操作柜员/终端号
                       av_trbatchno        acc_inout_detail.deal_batch_no%TYPE, --交易批次号
                       av_termtrno         acc_inout_detail.end_deal_no%TYPE, --终端交易流水号
                       av_trdate_str       varchar2, --交易时间
                       av_trstate          acc_inout_detail.deal_state%TYPE, --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                       av_actionno         acc_inout_detail.deal_no%TYPE, --业务流水号
                       av_note             acc_inout_detail.note%TYPE, --备注
                       av_clrdate          pay_clr_para.clr_date%TYPE, --清分日期
                       av_otherin          VARCHAR2 DEFAULT NULL, --其它传入参数 退货时传入原acc_book_no
                       av_debug            IN VARCHAR2, --1调试
                       av_res              OUT VARCHAR2, --传出参数代码
                       av_msg              OUT VARCHAR2 --传出参数错误信息
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
      av_msg := '借方账户不存在.';
      return;
    end if;

    if av_cr_num <> 1 then
      av_res := pk_public.cs_res_accnotexit;
      av_msg := '贷方账户不存在.';
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

