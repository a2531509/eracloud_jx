CREATE OR REPLACE PACKAGE BODY pk_business IS
  /*=======================================================================================*/
  --建账户
  --av_in: 1deal_no|2deal_code|3user_id|4deal_time|
  --5obj_type     类型（与账户主体类型一致，0-网点1-个人/卡 2-单位 3-商户4-机构5-合作机构）
  --6sub_type     卡类型(不用传入)
  --7obj_id       账户主体类型是卡时，传入卡号，(多个卡号时，卡号之间以,分割 cardno1,cardno2)
  --                             其它传入client_id，
  --8pwd          不用
  --9encrypt      卡账户金额密文(多个卡号时，之间以,分割 encrypt1,encrypt2)
  /*=======================================================================================*/
  PROCEDURE p_createaccount(av_in  IN VARCHAR2, --传入参数
                            av_res OUT VARCHAR2, --传出参数代码
                            av_msg OUT VARCHAR2 --传出参数错误信息
                            ) IS
    lv_count NUMBER;
    lv_in    pk_public.myarray; --传入参数数组
    lv_oper  sys_USERS%ROWTYPE; --柜员
    lv_card  card_baseinfo%ROWTYPE; --卡片基本信息
    --lv_tablename VARCHAR2(20); --card_baseinfo等的表名
    lv_accname acc_account_sub.acc_name%TYPE; --账户名称
    --lv_sql       VARCHAR2(2000);
    lv_dd     TIMESTAMP := systimestamp;
    lv_count1 NUMBER;
  BEGIN
    --取传入参数组成参数数组
    pk_public.p_getinputpara(av_in, --传入参数
                             9, --参数最少个数
                             9, --参数最多个数
                             'pk_business.p_createaccount', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
  
    if lv_in(7) is null then
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := '客户编号不能为空';
      return;
    end if;
    --取柜员信息
  
    BEGIN
      SELECT * INTO lv_oper FROM sys_users WHERE user_id = lv_in(3);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := '未找到柜员编号' || lv_in(3);
        RETURN;
    END;
  
    IF lv_in(5) = pk_public.cs_client_type_card THEN
      --传入的参数：分户账的主体类型是卡时建卡账户
      DECLARE
        lv_cardnos  pk_public.myarray; --卡号数组
        lv_encrypts pk_public.myarray; --金额密文数组
      
      BEGIN
        lv_count  := pk_public.f_splitstr(lv_in(7), ',', lv_cardnos); --lv_in(7)是卡号串用，’，’分割
        lv_count  := pk_public.f_splitstr(lv_in(9), ',', lv_encrypts); --lv_in(9)是金额密文串，用‘，’分割
        lv_count1 := lv_count;
      
        FOR i IN 1 .. lv_cardnos.count LOOP
          IF lv_cardnos(i) IS NOT NULL THEN
            --根据卡号取卡基本信息
            pk_public.p_getcardbycardno(lv_cardnos(i), --卡号
                                        lv_card, --卡片基本信息
                                        av_res, --传出参数代码
                                        av_msg --传出参数错误信息
                                        );
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
          
            --取账户名称
            BEGIN
              SELECT NAME
                INTO lv_accname
                FROM base_personal
               WHERE customer_id = lv_card.customer_id;
            EXCEPTION
              WHEN no_data_found THEN
                lv_accname := '卡账户';
            END;
            --根据账户主体类型和卡类型取建立账户的配置表数据，以此建立卡账户
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
      --建其它账户
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
                        '网点',
                        '2',
                        '单位',
                        '3',
                        '商户',
                        '4',
                        '运营机构',
                        '5',
                        '合作机构',
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
    av_msg := '账户建立成功';
    pk_public.p_insertrzcllog_('0',
                               'p_createaccount end:' || av_in,
                               f_timestamp_diff(systimestamp, lv_dd));
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '建账户发生错误：' || SQLERRM;
  END p_createaccount;

  /*=======================================================================================*/
  --建账户撤销
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time
  --5main_type     类型（与账户主体类型一致，0-网点1-个人/卡 2-单位 3-商户4-机构）
  --6sub_type     卡类型(不用传入)
  --7obj_id       账户主体类型是卡时，传入卡号，(多个卡号时，卡号之间以,分割 cardno1,cardno2)
  --                             其它传入customer_id，
  /*=======================================================================================*/
  PROCEDURE p_createaccountcancel(av_in  IN VARCHAR2, --传入参数
                                  av_res OUT VARCHAR2, --传出参数代码
                                  av_msg OUT VARCHAR2 --传出参数错误信息
                                  ) IS
    lv_count     NUMBER;
    lv_in        pk_public.myarray; --传入参数数组
    lv_tablename VARCHAR2(20); --cm_card等的表名
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             7, --参数最少个数
                             7, --参数最多个数
                             'pk_business.p_createaccountcancel', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_in(5) = pk_public.cs_client_type_card THEN
      --建卡账户撤销
      DECLARE
        lv_cardnos pk_public.myarray; --卡号数组
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
              av_msg := '账户余额不等于0，不能撤销';
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
      --建其它账户撤销
      IF lv_in(7) is not null then
        SELECT COUNT(*)
          INTO lv_count
          FROM acc_account_sub
         WHERE customer_id = lv_in(7)
           AND bal <> 0;
        IF lv_count > 0 THEN
          av_res := '-1';
          av_msg := '账户余额不等于0，不能撤销';
          RETURN;
        ELSE
          DELETE FROM acc_account_sub
           WHERE customer_id = lv_in(7)
             AND bal = 0;
        END IF;
      END IF;
    END IF;
  
    av_res := pk_public.cs_res_ok;
    av_msg := '撤销建账户成功';
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '撤销建账户发生错误：' || SQLERRM;
  END p_createaccountcancel;
  /*=======================================================================================*/
  --更新现金尾箱
  /*=======================================================================================*/
  PROCEDURE p_updatecashbox(av_actionno IN NUMBER, --交易流水号
                            av_trcode   IN VARCHAR2, --交易代码
                            av_operid   IN VARCHAR2, --柜员编号
                            av_trdate   IN VARCHAR2, --日期yyyy-mm-dd hh24:mi:ss
                            av_amt      IN NUMBER, --金额
                            av_summary  IN VARCHAR2, --备注
                            av_clrdate  IN VARCHAR2, --清分日期
                            av_res      OUT VARCHAR2, --传出参数代码
                            av_msg      OUT VARCHAR2 --传出参数错误信息
                            ) IS
  BEGIN
    p_updatecashbox(av_actionno, --交易流水号
                    av_trcode, --交易代码
                    av_operid, --柜员编号
                    av_trdate, --日期yyyy-mm-dd hh24:mi:ss
                    av_amt, --金额
                    av_summary, --备注
                    av_clrdate, --清分日期
                    NULL, --对方机构
                    NULL, --对方网点
                    NULL, --对方柜员
                    av_res, --传出参数代码
                    av_msg --传出参数错误信息
                    );
  END p_updatecashbox;
  /*=======================================================================================*/
  --更新现金尾箱
  /*=======================================================================================*/
  PROCEDURE p_updatecashbox(av_actionno    IN NUMBER, --交易流水号
                            av_trcode      IN VARCHAR2, --交易代码
                            av_operid      IN VARCHAR2, --柜员编号
                            av_trdate      IN VARCHAR2, --日期yyyy-mm-dd hh24:mi:ss
                            av_amt         IN NUMBER, --金额
                            av_summary     IN VARCHAR2, --备注
                            av_clrdate     IN VARCHAR2, --清分日期
                            av_otherorgid  IN VARCHAR2, --对方机构
                            av_otherbrchid IN VARCHAR2, --对方网点
                            av_otheroperid IN VARCHAR2, --对方柜员
                            av_res         OUT VARCHAR2, --传出参数代码
                            av_msg         OUT VARCHAR2 --传出参数错误信息
                            ) IS
    lv_box      cash_box%ROWTYPE; --现金尾箱
    lv_operator sys_users%ROWTYPE;
    lv_dd       TIMESTAMP := systimestamp;
  BEGIN
    --判断
    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = av_operid;
      SELECT * INTO lv_box FROM cash_box WHERE user_id = av_operid;
    EXCEPTION
      WHEN no_data_found THEN
        av_msg := av_operid || '没有柜员尾箱！';
        av_res := pk_public.cs_res_operatorerr;
        RETURN;
    END;
    IF lv_box.td_blc + av_amt - lv_box.frz_amt < 0 THEN
      av_msg := av_operid || '的柜员尾箱金额不足！';
      av_res := pk_public.cs_res_cashinsufbalance;
      RETURN;
    END IF;
    IF lv_operator.cash_lmt > 0 THEN
      IF lv_box.td_blc + av_amt > lv_operator.cash_lmt THEN
        av_msg := av_operid || '的柜员尾箱超过限额！请先进行网点存款';
        av_res := pk_public.cs_res_cashinsufbalance;
        RETURN;
      END IF;
    END IF;
    --更新
    UPDATE cash_box
       SET td_in_num  = td_in_num + CASE WHEN av_amt > 0 THEN 1 ELSE 0 END,
           td_in_amt  = td_in_amt + CASE WHEN av_amt > 0 THEN av_amt ELSE 0 END,
           td_out_num = td_out_num + CASE WHEN av_amt < 0 THEN 1 ELSE 0 END,
           td_out_amt = td_out_amt + CASE WHEN av_amt < 0 THEN abs(av_amt) ELSE 0 END,
           td_blc     = td_blc + av_amt
     WHERE user_id = av_operid
       AND td_blc >= -av_amt;
    IF SQL%ROWCOUNT = 0 THEN
      av_msg := av_operid || '的柜员尾箱金额不足！';
      av_res := pk_public.cs_res_cashinsufbalance;
      RETURN;
    END IF;
  
    INSERT INTO cash_box_rec
      (cash_ser_no, --  现金流水序列号
       user_id, -- 柜员号
       brch_id, -- 网点号
       org_id, --机构
       coin_kind, -- 币种(hbzl)
       summary, -- 摘要(zy)
       in_out_date, -- 发生日期
       amt, --  发生额
       in_out_flag, -- 收付标志(sfbz)(1-收 、2-付)
       cs_bal, --  现金结存
       deal_code, -- 交易代码
       deal_no, -- 业务流水号
       clr_date, --清分日期
       other_org_id, --对方机构
       other_brch_id, --对方网点
       other_user_id --对方柜员
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
      av_msg := nvl(av_msg, '更新现金尾箱发生错误') || SQLERRM;
      av_res := pk_public.cs_res_unknownerr;
      RETURN;
  END p_updatecashbox;
  /*=======================================================================================*/
  --更新分户账
  /*=======================================================================================*/
  PROCEDURE p_updatesubledger(av_accno          IN NUMBER, --账号
                              av_amt            IN NUMBER, --金额
                              av_credit         IN NUMBER, --信用
                              av_balance_old    in varchar2, --原金额
                              av_balanceencrypt IN VARCHAR2, --金额密文
                              av_cardno         IN VARCHAR2, --卡号
                              av_res            OUT VARCHAR2, --传出参数代码
                              av_msg            OUT VARCHAR2 --传出参数错误信息
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
        --预存款账户，判断限额
        pk_public.p_judgebranchagentlimit(lv_clientid, --网点编号
                                          lv_balance, --扣除金额后的预存款余额
                                          av_res, --传出参数代码
                                          av_msg --传出参数错误信息
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
        av_msg := '传入的原金额不能为空';
        RETURN;
      END IF;*/
    
      IF lv_acckind IN ('02') AND av_balanceencrypt IS NULL THEN
        av_res := pk_public.cs_res_dberr;
        av_msg := '联机账户传入的金额密文不能为空';
        RETURN;
      END IF;
    
      UPDATE acc_account_sub
         SET bal            = bal + av_amt,
             credit_lmt     = credit_lmt + av_credit,
             bal_crypt      = av_balanceencrypt,
             last_deal_date = to_char(SYSDATE, 'yyyy-mm-dd hh24:mi:ss')
       WHERE acc_no = av_accno
      -- and bal_crypt <> av_balance_oldcrypt  --密文不能同时更新
      RETURNING bal, bal_type, acc_kind INTO lv_balance, lv_balattr, lv_acckind;
    
      /* if sql%rowcount = 0 then
          av_res := pk_public.cs_res_dberr;
          av_msg := '更新账户密文时出错或者找不到此卡'|| av_cardno||'账户';
        RETURN;
      END IF;*/
    
      IF lv_acckind in ('02') and
         lv_balance <> nvl(av_balance_old, 0) + av_amt THEN
        --联机账户需要判断是不是同时更新账户,
        av_res := pk_public.cs_res_dberr;
        av_msg := '账户交易前金额不正确';
        RETURN;
      END IF;
    
      IF lv_balattr = '2' AND lv_balance < 0 THEN
        --余额不能小于0
        av_res := pk_public.cs_res_accinsufbalance;
        av_msg := '余额不足';
        RETURN;
      END IF;
      /*  IF lv_acckind IN ('02') AND av_balanceencrypt IS NULL THEN
        --联机账户 并且金额密文传入空
        NULL; ------------------临时取金额密文
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
      av_msg := nvl(av_msg, '更新分户账发生错误') || SQLERRM;
      av_res := pk_public.cs_res_unknownerr;
      RETURN;
  END p_updatesubledger;

  /*=======================================================================================*/
  --根据借贷更新分户账和现金尾箱
  /*=======================================================================================*/
  PROCEDURE p_updatesubledgerandcashbox(av_db_accno           acc_inout_detail.db_acc_no%TYPE, --借方账号
                                        av_db_cardno          acc_inout_detail.db_card_no%TYPE, --借方卡号
                                        av_db_itemno          VARCHAR2, --借方科目号
                                        av_db_balance_old     varchar2, --借方账户交易前金额
                                        av_db_balance_encrypt VARCHAR2, --借方账户交易后金额密文
                                        av_cr_accno           acc_inout_detail.cr_acc_no%TYPE, --贷方账号
                                        av_cr_cardno          acc_inout_detail.cr_card_no%TYPE, --贷方卡号
                                        av_cr_itemno          VARCHAR2, --贷方科目号
                                        av_cr_balance_old     varchar2, --贷方账户交易前金额
                                        av_cr_balance_encrypt VARCHAR2, --贷方账户交易后金额密文
                                        av_actionno           NUMBER, --交易流水号
                                        av_trcode             VARCHAR2, --交易代码
                                        av_operid             VARCHAR2, --柜员编号
                                        av_trdate             DATE, --交易日期
                                        av_tramt              NUMBER, --交易金额
                                        av_credit             NUMBER, --信用发生额
                                        av_note               VARCHAR2, --备注
                                        av_clrdate            VARCHAR2, --清分日期
                                        av_res                OUT VARCHAR2, --传出参数代码
                                        av_msg                OUT VARCHAR2 --传出参数错误信息
                                        ) IS
    lv_cardno varchar2(20) := ''; ---交易卡号
  BEGIN
    /*IF av_trcode NOT LIKE '9090%' AND  av_trcode <> '20601050' AND av_trcode <> '20601060' AND
        (av_trcode <=30101021 OR  av_trcode >= 40000001) THEN
      IF av_db_itemno <> pk_public.cs_accitem_co_org_rechage_in THEN
        --写现金尾箱
        IF av_db_itemno = pk_public.cs_accitem_cash AND av_cr_itemno = pk_public.cs_accitem_cash AND av_trcode <> '50801010'  THEN
            --现金交接的现金尾箱单独更新
            \*NULL;*\
             pk_business.p_updatecashbox(av_actionno, --交易流水号
                                        av_trcode, --交易代码
                                        av_operid, --柜员编号
                                        to_char(av_trdate,
                                                'yyyy-mm-dd hh24:mi:ss'), --日期yyyy-mm-dd hh24:mi:ss
                                        av_tramt, --金额
                                        av_note, --备注
                                        av_clrdate, --清分日期
                                        av_res, --传出参数代码
                                        av_msg --传出参数错误信息
                                        );
             IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
        ELSIF av_db_itemno = pk_public.cs_accitem_cash OR av_db_itemno = pk_public.cs_accitem_brch_prestore  THEN
          --收现金--代理网点收钱做业务也记现金流水
          IF av_cr_itemno <> pk_public.cs_accitem_biz_clr THEN
            pk_business.p_updatecashbox(av_actionno, --交易流水号
                                        av_trcode, --交易代码
                                        av_operid, --柜员编号
                                        to_char(av_trdate,
                                                'yyyy-mm-dd hh24:mi:ss'), --日期yyyy-mm-dd hh24:mi:ss
                                        av_tramt, --金额
                                        av_note, --备注
                                        av_clrdate, --清分日期
                                        av_res, --传出参数代码
                                        av_msg --传出参数错误信息
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
          --付现金--代理网点退钱时也记现金流水（给代理网点充值时不记）
          pk_business.p_updatecashbox(av_actionno, --交易流水号
                                      av_trcode, --交易代码
                                      av_operid, --柜员编号
                                      to_char(av_trdate,
                                              'yyyy-mm-dd hh24:mi:ss'), --日期yyyy-mm-dd hh24:mi:ss
                                      -av_tramt, --金额
                                      av_note, --备注
                                      av_clrdate, --清分日期
                                      av_res, --传出参数代码
                                      av_msg --传出参数错误信息
                                      );
               IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
          elsif av_cr_itemno = pk_public.cs_accitem_cash  and av_trcode='50801030' then
               pk_business.p_updatecashbox(av_actionno, --交易流水号
                                      av_trcode, --交易代码
                                      av_operid, --柜员编号
                                      to_char(av_trdate,
                                              'yyyy-mm-dd hh24:mi:ss'), --日期yyyy-mm-dd hh24:mi:ss
                                      -abs(av_tramt), --金额
                                      av_note, --备注
                                      av_clrdate, --清分日期
                                      av_res, --传出参数代码
                                      av_msg --传出参数错误信息
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
          pk_business.p_updatecashbox(av_actionno, --交易流水号
                                      av_trcode, --交易代码
                                      av_operid, --柜员编号
                                      to_char(av_trdate,
                                              'yyyy-mm-dd hh24:mi:ss'), --日期yyyy-mm-dd hh24:mi:ss
                                      av_tramt, --金额
                                      av_note, --备注
                                      av_clrdate, --清分日期
                                      av_res, --传出参数代码
                                      av_msg --传出参数错误信息
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
            pk_business.p_updatecashbox(av_actionno, --交易流水号
                                        av_trcode, --交易代码
                                        av_operid, --柜员编号
                                        to_char(av_trdate,
                                                'yyyy-mm-dd hh24:mi:ss'), --日期yyyy-mm-dd hh24:mi:ss
                                        av_tramt, --金额
                                        av_note, --备注
                                        av_clrdate, --清分日期
                                        av_res, --传出参数代码
                                        av_msg --传出参数错误信息
                                        );
            IF av_res <> pk_public.cs_res_ok THEN
              RETURN;
            END IF;
          ELSE
            IF av_trcode <> '50801010' AND av_trcode <> '30601020' and
               av_trcode <> '20501190' and av_trcode <> '30601021' THEN
              pk_business.p_updatecashbox(av_actionno, --交易流水号
                                          av_trcode, --交易代码
                                          av_operid, --柜员编号
                                          to_char(av_trdate,
                                                  'yyyy-mm-dd hh24:mi:ss'), --日期yyyy-mm-dd hh24:mi:ss
                                          av_tramt, --金额
                                          av_note, --备注
                                          av_clrdate, --清分日期
                                          av_res, --传出参数代码
                                          av_msg --传出参数错误信息
                                          );
              IF av_res <> pk_public.cs_res_ok THEN
                RETURN;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
  
    --更新acc_sub_ledger
    p_updatesubledger(av_db_accno, --账号
                      -av_tramt, --金额
                      -av_credit, --信用
                      av_db_balance_old, --交易前金额
                      av_db_balance_encrypt, --金额密文
                      av_db_cardno, --卡号
                      av_res, --传出参数代码
                      av_msg --传出参数错误信息
                      );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    p_updatesubledger(av_cr_accno, --账号
                      av_tramt, --金额
                      av_credit, --信用
                      av_cr_balance_old, --交易前金额
                      av_cr_balance_encrypt, --金额密文
                      av_cr_cardno, --卡号
                      av_res, --传出参数代码
                      av_msg --传出参数错误信息
                      );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    -----发送短信------------
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
      av_msg := '更新分户账和现金尾箱发生错误：' || SQLERRM;
  END p_updatesubledgerandcashbox;
  /*=======================================================================================*/
  --根据借贷账户公共记账方法
  /*=======================================================================================*/
  PROCEDURE p_account(av_db               acc_account_sub%ROWTYPE, --借方账户
                      av_cr               acc_account_sub%ROWTYPE, --贷方账户
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
                      av_trdate           acc_inout_detail.deal_date%TYPE, --交易时间
                      av_trstate          acc_inout_detail.deal_state%TYPE, --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                      av_actionno         acc_inout_detail.deal_no%TYPE, --业务流水号
                      av_note             acc_inout_detail.note%TYPE, --备注
                      av_clrdate          pay_clr_para.clr_date%TYPE, --清分日期
                      av_otherin          VARCHAR2 DEFAULT NULL, --其它传入参数 退货时传入原acc_book_no
                      av_debug            IN VARCHAR2, --1调试
                      av_res              OUT VARCHAR2, --传出参数代码
                      av_msg              OUT VARCHAR2 --传出参数错误信息
                      ) IS
    lv_tablename VARCHAR2(50);
    lv_sql       VARCHAR2(2000);
    lv_dd        TIMESTAMP := systimestamp;
  BEGIN
    IF av_debug = '9' THEN
      pk_public.p_insertrzcllog('记账', av_actionno);
    END IF;
    --111111111111111111111111写acc_daybook
    IF av_trstate = '9' THEN
      lv_tablename := 'acc_inout_detail';
    ELSE
      lv_tablename := 'acc_inout_detail_' ||
                      to_char(to_date(av_clrdate, 'yyyy-mm-dd'), 'yyyymm'); ---每月一张表
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
    --22222222222222222222222写tr_card
    IF av_db.card_no IS NOT NULL THEN
      IF av_trstate = '9' THEN
        lv_tablename := 'pay_card_deal_rec';
      ELSE
        -- lv_tablename := pk_public.f_gettrcardtable(av_db.card_no, av_trdate);
        lv_tablename := 'pay_card_deal_rec_' ||
                        to_char(av_trdate, 'yyyymm'); ----需要考虑传入的交易时间找不到表的情况？？？？？
      END IF;
      --tr_card中amt正负表示加钱扣钱
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
                        to_char(av_trdate, 'yyyymm'); ----需要考虑传入的交易时间找不到表的情况？？？？？
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
    --3333333333333333333333更新分户账，更新现金尾箱
    IF av_trstate <> '9' THEN
      p_updatesubledgerandcashbox(av_db.acc_no, --借方账号
                                  av_db.card_no, --借方卡号
                                  av_db.item_id, --借方科目号
                                  av_db.bal, --借方账户交易前金额密文
                                  av_dbbalanceencrypt, --借方账户交易后金额密文
                                  av_cr.acc_no, --贷方账号
                                  av_cr.card_no, --贷方卡号
                                  av_cr.item_id, --贷方科目号
                                  av_cr.bal, --贷方账户交易前金额
                                  av_crbalanceencrypt, --贷方账户交易后金额密文
                                  av_actionno, --交易流水号
                                  av_trcode, --交易代码
                                  av_operid, --柜员编号
                                  av_trdate, --交易日期
                                  av_tramt, --交易金额
                                  av_credit, --信用发生额
                                  av_note, --备注
                                  av_clrdate, --清分日期
                                  av_res, --传出参数代码
                                  av_msg --传出参数错误信息
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
      av_msg := '记账发生错误：' || SQLERRM;
  END p_account;
  /*=======================================================================================*/
  --灰记录确认  针对一条账户流水记录做确认
  /*=======================================================================================*/
  PROCEDURE p_ashconfirm_onerow(av_clrdate          IN pay_clr_para.clr_date%TYPE, --清分日期
                                av_daybook          IN acc_inout_detail%ROWTYPE, --要确认的daybook
                                av_dbbalanceencrypt IN VARCHAR2, --借方金额密文
                                av_crbalanceencrypt IN VARCHAR2, --贷方金额密文
                                av_dbaccbal         IN varchar2, --借方交易前金额
                                av_craccbal         IN varchar2, --贷方交易前金额
                                av_debug            IN VARCHAR2, --1写调试日志
                                av_res              OUT VARCHAR2, --传出代码
                                av_msg              OUT VARCHAR2 --传出错误信息
                                ) IS
    lv_tablename VARCHAR2(50);
    lv_clrdate   pay_clr_para.clr_date%TYPE; --清分日期
    lv_trdate    DATE;
  BEGIN
    IF av_debug = '1' THEN
      pk_public.p_insertrzcllog('灰记录确认', av_daybook.deal_no);
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
      --合作机构POS充值
      update tr_serv_rec r
         set r.deal_state = '0', r.clr_date = av_clrdate
       where r.deal_state = '9'
         and r.deal_no = av_daybook.deal_no;
    end if;
    IF SQL%ROWCOUNT = 0 THEN
      av_res := '99';
      av_msg := '不存在要确认的灰记录';
      RETURN;
    END IF;
    --移动acc_daybook
    EXECUTE IMMEDIATE 'insert into acc_inout_detail_' ||
                      to_char(to_date(lv_clrdate, 'yyyy-mm-dd'), 'yyyymm') ||
                      ' select * from acc_inout_detail' ||
                      ' where acc_inout_no = :1'
      USING av_daybook.acc_inout_no;
    DELETE FROM acc_inout_detail
     WHERE acc_inout_no = av_daybook.acc_inout_no;
  
    --移动借方卡号的交易灰记录
    IF av_daybook.db_card_no IS NOT NULL THEN
      UPDATE pay_card_deal_rec
         SET deal_state = '0',
             clr_date   = lv_clrdate,
             acc_bal    = nvl(av_dbaccbal, acc_bal)
       WHERE acc_inout_no = av_daybook.acc_inout_no
         AND card_no = av_daybook.db_card_no
         AND deal_state = '9';
      -- lv_tablename := pk_public.f_gettrcardtable(av_daybook.db_card_no,lv_trdate);
      lv_tablename := 'pay_card_deal_rec_' || to_char(lv_trdate, 'yyyymm'); ----需要考虑传入的交易时间找不到表的情况？？？？？
    
      --判断是否找得到该表，如果找不到该表则放入在原记录表里
    
      EXECUTE IMMEDIATE 'insert into ' || lv_tablename ||
                        ' select * from pay_card_deal_rec where acc_inout_no = :1 and card_no = :2'
        USING av_daybook.acc_inout_no, av_daybook.db_card_no;
      DELETE FROM pay_card_deal_rec
       WHERE acc_inout_no = av_daybook.acc_inout_no
         AND card_no = av_daybook.db_card_no;
    END IF;
    --移动贷方卡号的交易灰记录
    IF av_daybook.cr_card_no IS NOT NULL THEN
      UPDATE pay_card_deal_rec
         SET deal_state = '0',
             clr_date   = lv_clrdate,
             acc_bal    = nvl(av_craccbal, acc_bal)
       WHERE acc_inout_no = av_daybook.acc_inout_no
         AND card_no = av_daybook.cr_card_no
         AND deal_state = '9';
    
      --  lv_tablename := pk_public.f_gettrcardtable(av_daybook.cr_card_no,lv_trdate);
    
      lv_tablename := 'pay_card_deal_rec_' || to_char(lv_trdate, 'yyyymm'); ----需要考虑传入的交易时间找不到表的情况？？？？？
      EXECUTE IMMEDIATE 'insert into ' || lv_tablename ||
                        ' select * from pay_card_deal_rec where acc_inout_no = :1 and card_no = :2'
        USING av_daybook.acc_inout_no, av_daybook.cr_card_no;
      DELETE FROM pay_card_deal_rec
       WHERE acc_inout_no = av_daybook.acc_inout_no
         AND card_no = av_daybook.cr_card_no;
    END IF;
  
    --更新分户账和 更新现金尾箱
    p_updatesubledgerandcashbox(av_daybook.db_acc_no, --借方账号
                                av_daybook.db_card_no, --借方卡号
                                av_daybook.db_item_id, --借方科目号
                                av_dbaccbal, --借方账户交易前金额
                                av_dbbalanceencrypt, --借方账户交易后金额密文
                                av_daybook.cr_acc_no, --贷方账号
                                av_daybook.cr_card_no, --贷方卡号
                                av_daybook.cr_item_id, --贷方科目号
                                av_craccbal, --贷方账户交易前金额
                                av_crbalanceencrypt, --贷方账户交易后金额密文
                                av_daybook.deal_no, --交易流水号
                                av_daybook.deal_code, --交易代码
                                av_daybook.user_id, --柜员编号
                                av_daybook.deal_date, --交易日期
                                av_daybook.db_amt, --交易金额
                                av_daybook.db_credit_amt, --信用发生额
                                av_daybook.note, --备注
                                lv_clrdate, --清分日期
                                av_res, --传出参数代码
                                av_msg --传出参数错误信息
                                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
  
    av_res := pk_public.cs_res_ok;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '灰记录确认发生错误：' || SQLERRM;
  END p_ashconfirm_onerow;
  /*=======================================================================================*/
  --灰记录确认  根据传入的acc_book_no做确认
  /*=======================================================================================*/
  PROCEDURE p_ashconfirmbyaccbookno(av_clrdate          IN pay_clr_para.clr_date%TYPE, --清分日期
                                    av_accbookno        IN VARCHAR2, --要确认的acc_book_no
                                    av_dbbalanceencrypt IN VARCHAR2, --借方金额密文
                                    av_crbalanceencrypt IN VARCHAR2, --贷方金额密文
                                    av_dbaccbal         IN varchar2, --借方交易前金额
                                    av_craccbal         IN varchar2, --贷方交易前金额
                                    av_debug            IN VARCHAR2, --1写调试日志
                                    av_res              OUT VARCHAR2, --传出代码
                                    av_msg              OUT VARCHAR2 --传出错误信息
                                    ) IS
    lv_daybook acc_inout_detail%ROWTYPE;
  BEGIN
    SELECT *
      INTO lv_daybook
      FROM acc_inout_detail
     WHERE acc_inout_no = av_accbookno
       AND deal_state = '9';
    p_ashconfirm_onerow(av_clrdate, --清分日期
                        lv_daybook, --要确认的daybook
                        av_dbbalanceencrypt, --借方金额密文
                        av_crbalanceencrypt, --贷方金额密文
                        av_dbaccbal, --借方交易前金额
                        av_craccbal, --贷方交易前金额
                        av_debug, --1写调试日志
                        av_res, --传出代码
                        av_msg --传出错误信息
                        );
  EXCEPTION
    WHEN no_data_found THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := '账号流水号为' || av_accbookno || '的灰记录不存在';
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '灰记录确认发生错误：' || SQLERRM;
  END p_ashconfirmbyaccbookno;
  /*=======================================================================================*/
  --灰记录确认
  /*=======================================================================================*/
  PROCEDURE p_ashconfirm(av_clrdate          IN pay_clr_para.clr_date%TYPE, --清分日期
                         av_actionno         IN NUMBER, --业务流水号
                         av_dbbalanceencrypt IN VARCHAR2, --借方金额密文
                         av_crbalanceencrypt IN VARCHAR2, --贷方金额密文
                         av_debug            IN VARCHAR2, --1写调试日志
                         av_res              OUT VARCHAR2, --传出代码
                         av_msg              OUT VARCHAR2 --传出错误信息
                         ) IS
    lv_clrdate pay_clr_para.clr_date%TYPE; --清分日期
    lv_dbbal   acc_account_sub.bal%type;
    lv_crbal   acc_account_sub.bal%type;
    lv_rows    NUMBER := 0;
  BEGIN
    IF av_debug = '1' THEN
      pk_public.p_insertrzcllog('灰记录确认', av_actionno);
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
       where t.acc_no = lv_daybook.db_acc_no; --取借方账户原金额和密文
    
      select nvl(t.bal, 0)
        into lv_crbal
        from acc_account_sub t
       where t.acc_no = lv_daybook.cr_acc_no; --取贷方账户原金额和密文
    
      p_ashconfirm_onerow(av_clrdate, --清分日期
                          lv_daybook, --要确认的daybook
                          av_dbbalanceencrypt, --借方金额密文
                          av_crbalanceencrypt, --贷方金额密文
                          lv_dbbal, --借方交易前金额
                          lv_crbal, --贷方交易前金额
                          av_debug, --1写调试日志
                          av_res, --传出代码
                          av_msg --传出错误信息
                          );
    END LOOP;
    IF lv_rows = 0 THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := '不存在要确认的灰记录';
      RETURN;
    END IF;
    av_res := pk_public.cs_res_ok;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '灰记录确认发生错误：' || SQLERRM;
  END p_ashconfirm;
  /*=======================================================================================*/
  --灰记录撤销
  /*=======================================================================================*/
  PROCEDURE p_ashcancel(av_clrdate  IN pay_clr_para.clr_date%TYPE, --清分日期
                        av_actionno IN NUMBER, --业务流水号
                        av_debug    IN VARCHAR2, --1写调试日志
                        av_res      OUT VARCHAR2, --传出代码
                        av_msg      OUT VARCHAR2 --传出错误信息
                        ) IS
    lv_clrdate      pay_clr_para.clr_date%TYPE; --清分日期
    lv_cardno       pay_card_deal_rec.card_no%TYPE; --卡号
    lv_oldaccbookno acc_inout_detail.old_acc_inout_no%TYPE; --被撤销的记账流水号
    lv_oldaccbook   acc_inout_detail%ROWTYPE; --被撤销的记账
    --根据撤销的记账流水号和卡号取清分日期
    FUNCTION f_getoldclrdate(av_accbookno pay_card_deal_rec.acc_inout_no%TYPE,
                             av_cardno    pay_card_deal_rec.card_no%TYPE)
      RETURN VARCHAR2 IS
      lv_month     VARCHAR2(10);
      lv_tablename VARCHAR2(50);
      lv_count     NUMBER;
    BEGIN
      lv_month := substrb(lv_clrdate, 1, 8) || '01';
      WHILE lv_month > '2015-05-01' LOOP
        --大于上线日期和清分日期之间寻找原纪录的处理的清分日期
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
      pk_public.p_insertrzcllog('灰记录取消', av_actionno);
    END IF;
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    -------------------如果是充值卡充值，需要还原充值卡的状态
    --更改acc_daybook
    UPDATE acc_inout_detail
       SET deal_state = '2'
     WHERE deal_no = av_actionno
       AND deal_state = '9';
    IF SQL%ROWCOUNT = 0 THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := '不存在要取消的灰记录';
      RETURN;
    END IF;
    --更改tr_card
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
      --合作机构POS充值
      update tr_serv_rec r
         set r.deal_state = '2', clr_date = lv_clrdate
       where r.deal_state = '9'
         and r.deal_no = av_actionno;
    end if;
    -------------------如果是撤销记录的灰记录取消，需要更改原记录的状态和撤销时间
    IF SQL%ROWCOUNT > 0 THEN
      IF lv_oldaccbookno IS NOT NULL THEN
        --更改原记录的状态和撤销时间
        DECLARE
          lv_oldclrdate VARCHAR2(10);
          lv_oldtrdate  DATE;
        BEGIN
          lv_oldclrdate := f_getoldclrdate(lv_oldaccbookno, lv_cardno);
          IF lv_oldclrdate IS NOT NULL THEN
            EXECUTE IMMEDIATE 'update acc_inout_detail_' ||
                              to_char(to_date(lv_oldclrdate, 'yyyy-mm-dd'),
                                      'yyyymm') ||
                              ' set deal_state = 0,rev_time = null,note = note || ''_取消撤销'' where acc_inout_no = ' ||
                              lv_oldaccbookno ||
                              ' returning deal_date into :1'
              RETURNING INTO lv_oldtrdate;
            --FOR i IN 0 .. pk_public.cs_cm_card_nums - 1 LOOP
            EXECUTE IMMEDIATE 'update pay_card_deal_rec_' ||
                              to_char(lv_oldtrdate, 'yyyymm') ||
                              ' set deal_state = 0,rev_time = null,note = note || ''_取消撤销'' where acc_inout_no = ' ||
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
      av_msg := '灰记录取消发生错误：' || SQLERRM;
  END p_ashcancel;
  /*=======================================================================================*/
  --记账撤销 针对一条acc_daybook记录做撤销 daybook借贷账户不变,金额写负
  /*=======================================================================================*/
  PROCEDURE p_daybookcancel_onerow(av_daybook          IN acc_inout_detail%ROWTYPE, --要撤销daybook
                                   av_operator         IN sys_users%ROWTYPE, --当前柜员
                                   av_actionno2        IN NUMBER, --新业务流水号
                                   av_clrdate1         IN VARCHAR2, --撤销记录的清分日期
                                   av_clrdate2         IN VARCHAR2, --当前清分日期
                                   av_trcode           IN VARCHAR2, --交易代码
                                   av_dbcardbal        IN NUMBER, --借方卡面交易前金额
                                   av_crcardbal        IN NUMBER, --贷方卡面交易前金额
                                   av_dbcardcounter    IN NUMBER, --借方卡片交易计数器
                                   av_crcardcounter    IN NUMBER, --贷方卡片交易计数器
                                   av_dbbalanceencrypt IN VARCHAR2, --借方金额密文
                                   av_crbalanceencrypt IN VARCHAR2, --贷方金额密文
                                   av_dbaccbal         in varchar2, --借方交易前金额
                                   av_craccbal         IN varchar2, --贷方交易前金额
                                   av_confirm          IN VARCHAR2, --1直接确认
                                   av_debug            IN VARCHAR2, --1写调试日志
                                   av_res              OUT VARCHAR2, --传出代码
                                   av_msg              OUT VARCHAR2 --传出错误信息
                                   ) IS
    lv_tablename    VARCHAR2(50);
    lv_newtablename VARCHAR2(50);
    lv_newaccbookno acc_inout_detail.acc_inout_no%TYPE; --新增记录的acc_book_no
    lv_sql          VARCHAR2(2000);
    lv_clrdate      pay_clr_para.clr_date%TYPE; --清分日期
    lv_oldtrdate    DATE;
    lv_daybook      acc_inout_detail%ROWTYPE;
    lv_sysactionlog sys_action_log%ROWTYPE;
    lv_count        number;
  BEGIN
    IF av_debug = '1' THEN
      pk_public.p_insertrzcllog('记账撤销，原acc_inout_no' ||
                                av_daybook.acc_inout_no || '，新deal_no' ||
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
    --更改原记录改成撤销状态写撤销时间
    EXECUTE IMMEDIATE 'update acc_inout_detail_' ||
                      to_char(to_date(av_clrdate1, 'yyyy-mm-dd'), 'yyyymm') ||
                      ' set deal_state = 1,rev_time = sysdate,note = note || ''_已撤销''' ||
                      ' where acc_inout_no = :1 and deal_state = 0 returning deal_date into :2'
      USING av_daybook.acc_inout_no
      RETURNING INTO lv_oldtrdate;
    IF SQL%ROWCOUNT = 0 THEN
      av_res := pk_public.cs_res_glidenotexit;
      av_msg := '不存在要撤销的记录';
      RETURN;
    END IF;
  
    --产生acc_inout_datail 撤销纪录
    lv_daybook := av_daybook;
  
    IF av_operator.user_id IS NOT NULL AND --柜面业务产生的记账？？？？
       av_operator.user_id <> av_daybook.user_id THEN
      --撤销柜员和原柜员不一致时  取现在柜员
      lv_daybook.user_id     := av_operator.user_id;
      lv_daybook.acpt_org_id := av_operator.org_id;
      lv_daybook.acpt_id     := av_operator.brch_id;
    
      --借方是现金科目或者借方是网点预存款科目
    
      IF lv_daybook.db_item_id = pk_public.cs_accitem_cash OR
         lv_daybook.db_item_id = pk_public.cs_accitem_brch_prestore THEN
        DECLARE
          lv_branch      sys_branch%ROWTYPE; --网点
          lv_dbsubledger acc_account_sub%ROWTYPE; --分户账
        BEGIN
          SELECT *
            INTO lv_branch
            FROM sys_branch
           WHERE brch_id = av_operator.brch_id;
        
          IF lv_branch.brch_type = '3' THEN
            --代理网点
            lv_dbsubledger.item_id := pk_public.cs_accitem_brch_prestore;
          ELSE
            lv_dbsubledger.item_id := pk_public.cs_accitem_cash;
          END IF;
        
          --取借方分户账
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
          lv_branch      sys_branch%ROWTYPE; --网点
          lv_crsubledger acc_account_sub%ROWTYPE; --分户账
        BEGIN
          SELECT *
            INTO lv_branch
            FROM sys_branch
           WHERE brch_id = av_operator.brch_id;
          IF lv_branch.brch_type = '3' THEN
            --代理网点
            lv_crsubledger.item_id := pk_public.cs_accitem_brch_prestore;
          ELSE
            lv_crsubledger.item_id := pk_public.cs_accitem_cash;
          END IF;
          --取贷方分户账
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
        --取借贷账户的交易前金额
        IF av_dbaccbal IS NULL THEN
          IF lv_daybook.db_card_no IS NULL THEN
            --普通账户
            SELECT bal
              INTO lv_daybook.db_acc_bal
              FROM acc_account_sub
             WHERE acc_no = lv_daybook.db_acc_no;
          ELSE
            --卡账户
            SELECT pk_public.f_getcardbalance(lv_daybook.db_card_no,
                                              lv_daybook.db_acc_kind,
                                              pk_public.cs_defaultwalletid)
              INTO lv_daybook.db_acc_bal
              FROM dual;
          END IF;
        END IF;
        IF av_craccbal IS NULL THEN
          IF lv_daybook.cr_card_no IS NULL THEN
            --普通账户
            SELECT bal
              INTO lv_daybook.cr_acc_bal
              FROM acc_account_sub
             WHERE acc_no = lv_daybook.cr_acc_no;
          ELSE
            --卡账户
            SELECT pk_public.f_getcardbalance(lv_daybook.cr_card_no,
                                              lv_daybook.cr_acc_kind,
                                              pk_public.cs_defaultwalletid)
              INTO lv_daybook.cr_acc_bal
              FROM dual;
          END IF;
        END IF;
      END IF;
    END IF; ----结束撤销柜员和原柜员不一致的处理
  
    --新增负记录  要搞清楚using 语法？？？？
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
    av_actionno2, av_daybook.note || '撤销', av_clrdate2, av_daybook.acc_inout_no;
  
    --转出卡
    IF av_daybook.db_card_no IS NOT NULL THEN
      lv_tablename := pk_public.f_gettrcardtable(av_daybook.db_card_no,
                                                 lv_oldtrdate);
      EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                        ' set deal_state = 1,rev_time = sysdate,note = note || ''_已撤销''' ||
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
      nvl(av_dbaccbal, lv_daybook.db_acc_bal), CASE lv_daybook.db_acc_kind WHEN '01' THEN av_dbcardbal ELSE NULL END, CASE lv_daybook.db_acc_kind WHEN '01' THEN av_dbcardcounter ELSE NULL END, av_actionno2, lv_clrdate, av_daybook.note || '撤销', av_daybook.acc_inout_no, av_daybook.db_acc_no;
    END IF;
  
    --转入卡卡交易记录修改成已撤销，插入撤销纪录（灰记录）
    IF av_daybook.cr_card_no IS NOT NULL THEN
      lv_tablename := pk_public.f_gettrcardtable(av_daybook.cr_card_no,
                                                 lv_oldtrdate);
      EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                        ' set deal_state = 1,rev_time = sysdate,note = note || ''_已撤销''' ||
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
      nvl(av_craccbal, lv_daybook.cr_acc_bal), CASE lv_daybook.cr_acc_kind WHEN '01' THEN av_crcardbal ELSE NULL END, CASE lv_daybook.cr_acc_kind WHEN '01' THEN av_crcardcounter ELSE NULL END, av_actionno2, lv_clrdate, av_daybook.note || '撤销', av_daybook.acc_inout_no, av_daybook.cr_acc_no;
    END IF;
  
    IF av_confirm = '1' THEN
      --直接确认
    
      p_ashconfirmbyaccbookno(lv_clrdate, --清分日期
                              lv_newaccbookno, --业务流水号
                              av_dbbalanceencrypt, --借方金额密文
                              av_crbalanceencrypt, --贷方金额密文
                              av_dbaccbal, --借方交易前金额
                              av_craccbal, --贷方交易前金额
                              av_debug, --1写调试日志
                              av_res, --传出代码
                              av_msg --传出错误信息
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
      av_msg := '记账撤销发生错误：' || SQLERRM;
  END p_daybookcancel_onerow;
  /*=======================================================================================*/
  --记账撤销 根据传入的acc_book_no做撤销 daybook借贷账户不变,金额写负
  /*=======================================================================================*/
  PROCEDURE p_daybookcancelbyaccbookno(av_accbookno        IN VARCHAR2, --要撤销acc_book_no
                                       av_actionno2        IN NUMBER, --新业务流水号
                                       av_clrdate1         IN VARCHAR2, --撤销记录的清分日期
                                       av_clrdate2         IN VARCHAR2, --当前清分日期
                                       av_trcode           IN VARCHAR2, --交易代码
                                       av_operid           IN VARCHAR2, --当前柜员
                                       av_dbcardbal        IN NUMBER, --借方卡面交易前金额
                                       av_crcardbal        IN NUMBER, --贷方卡面交易前金额
                                       av_dbcardcounter    IN NUMBER, --借方卡片交易计数器
                                       av_crcardcounter    IN NUMBER, --贷方卡片交易计数器
                                       av_dbbalanceencrypt IN VARCHAR2, --借方金额密文
                                       av_crbalanceencrypt IN VARCHAR2, --贷方金额密文
                                       av_dbaccbal         in varchar2,
                                       av_craccbal         in varchar2,
                                       av_confirm          IN VARCHAR2, --1直接确认
                                       av_debug            IN VARCHAR2, --1写调试日志
                                       av_res              OUT VARCHAR2, --传出代码
                                       av_msg              OUT VARCHAR2 --传出错误信息
                                       ) IS
    lv_daybook  acc_inout_detail%ROWTYPE;
    lv_cursor   pk_public.t_cur; --游标
    lv_operator sys_users%ROWTYPE; --柜员
  BEGIN
    SELECT * INTO lv_operator FROM sys_users WHERE user_id = av_operid;
    OPEN lv_cursor FOR 'select * from acc_inout_detail_' || to_char(to_date(av_clrdate1,
                                                                            'yyyy-mm-dd'),
                                                                    'yyyymm') || ' where acc_inout_no = :1 and deal_state = 0'
      USING av_accbookno; ---acc_book_no 不是唯一吗？？？？？？
    LOOP
      FETCH lv_cursor
        INTO lv_daybook;
      EXIT WHEN lv_cursor%NOTFOUND;
      p_daybookcancel_onerow(lv_daybook, --要撤销daybook
                             lv_operator, --当前柜员
                             av_actionno2, --新业务流水号
                             av_clrdate1, --撤销记录的清分日期
                             av_clrdate2, --当前清分日期
                             av_trcode, --交易代码
                             av_dbcardbal, --借方卡面交易前金额
                             av_crcardbal, --贷方卡面交易前金额
                             av_dbcardcounter, --借方卡片交易计数器
                             av_crcardcounter, --贷方卡片交易计数器
                             av_dbbalanceencrypt, --借方金额密文
                             av_crbalanceencrypt, --贷方金额密文
                             av_dbaccbal,
                             av_craccbal,
                             av_confirm, --1直接确认
                             av_debug, --1写调试日志
                             av_res, --传出代码
                             av_msg --传出错误信息
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
      av_msg := '记账撤销发生错误：' || SQLERRM;
  END p_daybookcancelbyaccbookno;
  /*=======================================================================================*/
  --业务流水号记账撤销 撤销记录 daybook借贷账户不变,金额写负   1个业务流水号可能很多条acc_inout_detail ?????,密文怎么可能一致传入？？？？
  /*=======================================================================================*/
  PROCEDURE p_daybookcancel(av_actionno1        IN NUMBER, --要撤销业务流水号
                            av_actionno2        IN NUMBER, --新业务流水号
                            av_clrdate1         IN VARCHAR2, --撤销记录的清分日期
                            av_clrdate2         IN VARCHAR2, --当前清分日期
                            av_trcode           IN VARCHAR2, --交易代码
                            av_operid           IN VARCHAR2, --当前柜员
                            av_dbcardbal        IN NUMBER, --借方卡面交易前金额
                            av_crcardbal        IN NUMBER, --贷方卡面交易前金额
                            av_dbcardcounter    IN NUMBER, --借方卡片交易计数器
                            av_crcardcounter    IN NUMBER, --贷方卡片交易计数器
                            av_dbbalanceencrypt IN VARCHAR2, --借方金额密文
                            av_crbalanceencrypt IN VARCHAR2, --贷方金额密文
                            av_confirm          IN VARCHAR2, --1直接确认
                            av_debug            IN VARCHAR2, --1写调试日志
                            av_res              OUT VARCHAR2, --传出代码
                            av_msg              OUT VARCHAR2 --传出错误信息
                            ) IS
    --lv_tablename    varchar2(50);
    --lv_newtablename varchar2(50);
    lv_daybook acc_inout_detail%ROWTYPE;
    --lv_newaccbookno acc_daybook.acc_book_no%type; --新增记录的acc_book_no
    --lv_sql          varchar2(2000);
    lv_cursor   pk_public.t_cur; --游标
    lv_clrdate  pay_clr_para.clr_date%TYPE; --清分日期
    lv_operator sys_users%ROWTYPE; --柜员
  BEGIN
    IF av_debug = '1' THEN
      pk_public.p_insertrzcllog('记账撤销，原action_no' || av_actionno1 ||
                                '，新action_no' || av_actionno2,
                                av_actionno2);
    END IF;
    lv_clrdate := av_clrdate2;
    IF lv_clrdate IS NULL THEN
      SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    END IF;
    SELECT * INTO lv_operator FROM sys_users WHERE user_id = av_operid;
    --撤销正常记录
    --判断是否允许撤销
    NULL;
    OPEN lv_cursor FOR 'select * from acc_inout_detail_' || to_char(to_date(av_clrdate1,
                                                                            'yyyy-mm-dd'),
                                                                    'yyyymm') || ' where deal_no = :1 and deal_state = 0'
      USING av_actionno1;
    LOOP
      FETCH lv_cursor
        INTO lv_daybook;
      EXIT WHEN lv_cursor%NOTFOUND;
    
      --是否要取交易前金额密文？？？？？
    
      p_daybookcancel_onerow(lv_daybook, --要撤销daybook
                             lv_operator, --当前柜员
                             av_actionno2, --新业务流水号
                             av_clrdate1, --撤销记录的清分日期
                             lv_clrdate, --当前清分日期
                             av_trcode, --交易代码
                             av_dbcardbal, --借方卡面交易前金额
                             av_crcardbal, --贷方卡面交易前金额
                             av_dbcardcounter, --借方卡片交易计数器
                             av_crcardcounter, --贷方卡片交易计数器
                             av_dbbalanceencrypt, --借方金额密文
                             av_crbalanceencrypt, --贷方金额密文
                             NULL, --借方交易前金额
                             av_crcardbal, --贷方交易前金额
                             av_confirm, --1直接确认
                             av_debug, --1写调试日志
                             av_res, --传出代码
                             av_msg --传出错误信息
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
      av_msg := '记账撤销发生错误：' || SQLERRM;
  END p_daybookcancel;
  /*=======================================================================================*/
  --收取或退还工本费服务费等
  --  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --           5item_no|6amt|7note|8acpt_type|9pay_source(0现金1转账)
  /*=======================================================================================*/
  PROCEDURE p_cost(av_in    IN VARCHAR2, --传入参数
                   av_debug IN VARCHAR2, --1调试
                   av_res   OUT VARCHAR2, --传出参数代码
                   av_msg   OUT VARCHAR2 --传出参数错误信息
                   ) IS
    --lv_count       number;
    lv_in          pk_public.myarray; --传入参数数组
    lv_dbsubledger acc_account_sub%ROWTYPE; --借方分户账
    lv_crsubledger acc_account_sub%ROWTYPE; --贷方分户账
    lv_operator    sys_users%ROWTYPE; --柜员
    lv_branch      sys_branch%ROWTYPE; --网点
    lv_clrdate     pay_clr_para.clr_date%TYPE; --清分日期
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --记账流水号
    --lv_starttime  INT;
    lv_dd TIMESTAMP := systimestamp;
  BEGIN
    --lv_starttime := dbms_utility.get_time;
    pk_public.p_getinputpara(av_in, --传入参数
                             8, --参数最少个数
                             9, --参数最多个数
                             'pk_business.p_cost', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
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
        av_msg := '未找到柜员编号' || lv_in(3);
        RETURN;
    END;
  
    /*--借现金 贷工本费
    IF lv_in(6) > 0 THEN
      IF lv_in(9) = '0' THEN
        lv_dbsubledger.item_id := pk_public.cs_accitem_cash;
        IF lv_branch.brch_type = '3' THEN
          --代理网点
          lv_dbsubledger.item_id := pk_public.cs_accitem_brch_prestore;
        END IF;
        --取借方分户账
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
      --取贷方分户账
      pk_public.p_getorgsubledger(lv_operator.org_id,
                                  lv_crsubledger.item_id,
                                  lv_crsubledger,
                                  av_res, --传出参数代码
                                  av_msg --传出参数错误信息
                                  );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --退还
    
    ELSIF lv_in(6) < 0 THEN
      lv_dbsubledger.item_id := lv_in(5);
      IF lv_in(9) = '0' THEN
        lv_crsubledger.item_id := pk_public.cs_accitem_cash;
        IF lv_branch.brch_type = '3' THEN
          --代理网点
          lv_crsubledger.item_id := pk_public.cs_accitem_brch_prestore;
        END IF;
        --取贷方分户账
        pk_public.p_getsubledgerbyclientid(lv_operator.brch_id,
                                           lv_crsubledger.item_id,
                                           lv_crsubledger,
                                           av_res, --传出参数代码
                                           av_msg --传出参数错误信息
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
      --取借方分户账
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
    --写流水
    IF lv_in(9) = '0' THEN
      lv_dbsubledger.item_id := pk_public.cs_accitem_cash;
      IF lv_branch.brch_type = '3' THEN
        --代理网点
        lv_dbsubledger.item_id := pk_public.cs_accitem_brch_prestore;
      END IF;
      --取借方分户账
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
    --取贷方分户账
    pk_public.p_getorgsubledger(lv_operator.org_id,
                                lv_crsubledger.item_id,
                                lv_crsubledger,
                                av_res, --传出参数代码
                                av_msg --传出参数错误信息
                                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    pk_public.p_insertrzcllog_('0',
                               'p_cost start p_account:' ||
                               f_timestamp_diff(systimestamp, lv_dd),
                               lv_in(1));
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    p_account(lv_dbsubledger, --借方账户
              lv_crsubledger, --贷方账户
              NULL, --借方卡面交易前金额
              NULL, --贷方卡片交易计数器
              NULL, --借方卡片交易计数器
              NULL, --贷方卡片交易计数器
              NULL, --借方金额密文
              NULL, --贷方金额密文
              lv_in(6), --交易金额
              0, --信用发生额
              lv_accbookno, --记账流水号
              lv_in(2), --交易代码
              lv_crsubledger.org_id, --发卡机构
              lv_operator.org_id, --受理机构
              lv_in(8), --受理点分类
              lv_operator.brch_id, --受理点编码(网点号/商户号等)
              lv_operator.user_id, --操作柜员/终端号
              NULL, --交易批次号
              NULL, --终端交易流水号
              to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --交易时间
              '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
              lv_in(1), --业务流水号
              lv_in(7), --备注
              lv_clrdate, --清分日期
              null,
              av_debug, --1调试
              av_res, --传出参数代码
              av_msg --传出参数错误信息
              );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --pk_public.p_insertrzcllog('工本费 时间' || to_char(dbms_utility.get_time-lv_starttime) || '，传入参数' || av_in, -99990003);
    pk_public.p_insertrzcllog_('0',
                               'p_cost end:' || av_in,
                               f_timestamp_diff(systimestamp, lv_dd));
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '收费记账发生错误：' || SQLERRM;
  END p_cost;
  /*=======================================================================================*/
  --现金交接
  --  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --           5oper_id1|6oper_id2|7amt|8note|9acpt_type
  /*=======================================================================================*/
  PROCEDURE p_cashhandover(av_in    IN VARCHAR2, --传入参数
                           av_debug IN VARCHAR2, --1调试
                           av_res   OUT VARCHAR2, --传出参数代码
                           av_msg   OUT VARCHAR2 --传出参数错误信息
                           ) IS
    --lv_count       number;
    lv_in          pk_public.myarray; --传入参数数组
    lv_dbsubledger acc_account_sub%ROWTYPE; --借方分户账
    lv_crsubledger acc_account_sub%ROWTYPE; --贷方分户账
    lv_operator    sys_users%ROWTYPE; --柜员
    lv_operator1   sys_users%ROWTYPE; --柜员1
    lv_operator2   sys_users%ROWTYPE; --柜员2
    lv_clrdate     pay_clr_para.clr_date%TYPE; --清分日期
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --记账流水号
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             8, --参数最少个数
                             9, --参数最多个数
                             'pk_business.p_cashhandover', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
  
    IF lv_in(3) <> lv_in(5) AND lv_in(3) <> lv_in(6) THEN
      av_res := pk_public.cs_res_operatorerr;
      av_msg := '现金交接的两个柜员中必须有一个是操作柜员';
      RETURN;
    END IF;
    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = lv_in(3);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := '未找到柜员编号' || lv_in(3);
        RETURN;
    END;
    BEGIN
      SELECT * INTO lv_operator1 FROM sys_users WHERE user_id = lv_in(5);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := '未找到柜员编号' || lv_in(5);
        RETURN;
    END;
    BEGIN
      SELECT * INTO lv_operator2 FROM sys_users WHERE user_id = lv_in(6);
    EXCEPTION
      WHEN no_data_found THEN
        av_res := pk_public.cs_res_operatorerr;
        av_msg := '未找到柜员编号' || lv_in(6);
        RETURN;
    END;
    --付现金
    p_updatecashbox(lv_in(1), --交易流水号
                    lv_in(2), --交易代码
                    lv_operator1.user_id, --柜员编号
                    lv_in(4), --日期yyyy-mm-dd hh24:mi:ss
                    -lv_in(7), --金额
                    lv_in(8), --备注
                    lv_clrdate, --清分日期
                    lv_operator2.org_id, --对方机构
                    lv_operator2.brch_id, --对方网点
                    lv_operator2.user_id, --对方柜员
                    av_res, --传出参数代码
                    av_msg --传出参数错误信息
                    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    --收现金
    p_updatecashbox(lv_in(1), --交易流水号
                    lv_in(2), --交易代码
                    lv_operator2.user_id, --柜员编号
                    lv_in(4), --日期yyyy-mm-dd hh24:mi:ss
                    lv_in(7), --金额
                    lv_in(8), --备注
                    lv_clrdate, --清分日期
                    lv_operator1.org_id, --对方机构
                    lv_operator1.brch_id, --对方网点
                    lv_operator1.user_id, --对方柜员
                    av_res, --传出参数代码
                    av_msg --传出参数错误信息
                    );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_operator1.brch_id <> lv_operator2.brch_id THEN
      --借现金 贷现金
      lv_dbsubledger.item_id := pk_public.cs_accitem_cash;
      lv_crsubledger.item_id := pk_public.cs_accitem_cash;
      --取借方分户账
      pk_public.p_getsubledgerbyclientid(lv_operator1.brch_id,
                                         lv_dbsubledger.item_id,
                                         lv_dbsubledger,
                                         av_res,
                                         av_msg);
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --取贷方分户账
      pk_public.p_getsubledgerbyclientid(lv_operator2.brch_id,
                                         lv_crsubledger.item_id,
                                         lv_crsubledger,
                                         av_res, --传出参数代码
                                         av_msg --传出参数错误信息
                                         );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
      --写流水
      SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
      p_account(lv_dbsubledger, --借方账户
                lv_crsubledger, --贷方账户
                NULL, --借方卡面交易前金额
                NULL, --贷方卡片交易计数器
                NULL, --借方卡片交易计数器
                NULL, --贷方卡片交易计数器
                NULL, --借方金额密文
                NULL, --贷方金额密文
                lv_in(7), --交易金额
                0, --信用发生额
                lv_accbookno, --记账流水号
                lv_in(2), --交易代码
                lv_operator.org_id, --发卡机构
                lv_operator.org_id, --受理机构
                lv_in(9), --受理点分类
                lv_operator.brch_id, --受理点编码(网点号/商户号等)
                lv_operator.user_id, --操作柜员/终端号
                NULL, --交易批次号
                NULL, --终端交易流水号
                to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --交易时间
                '0', --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                lv_in(1), --业务流水号
                lv_in(8), --备注
                lv_clrdate, --清分日期
                null,
                av_debug, --1调试
                av_res, --传出参数代码
                av_msg --传出参数错误信息
                );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '现金记账发生错误：' || SQLERRM;
  END p_cashhandover;

  /*=======================================================================================*/
  --定时触发卡号表中已使用数据到历史表，可在卡号自动生成后触发
  --原则，卡号表中状态为已使用，且action_no对应的任务状态>已生成才允许移到历史表，
  --且保留当前卡号生成规则的卡号序列的最大值，以免新生成的卡号重复
  /*=======================================================================================*/
  PROCEDURE p_card_no_2_his(av_res OUT VARCHAR2, --传出代码
                            av_msg OUT VARCHAR2 --传出错误信息
                            ) IS
    ld_date       DATE := SYSDATE;
    ls_max_cardno card_no.card_no%TYPE := '1';
    ln_count      NUMBER;
  BEGIN
    av_res   := pk_public.cs_res_ok;
    ln_count := 0;
    FOR lrec_cardno IN (SELECT t.deal_no,
                               --t.task_sum,--任务数
                               --b.cnt,--卡号数
                               b.city, --城市
                               b.card_catalog, --卡大类
                               b.card_type --卡小类
                          FROM card_apply_task t,
                               (SELECT deal_no,
                                       --count(1) cnt,
                                       MAX(city) city,
                                       MAX(card_catalog) card_catalog,
                                       MAX(card_type) card_type
                                  FROM card_no
                                 WHERE used = '0' --已使用
                                 GROUP BY deal_no) b
                         WHERE t.deal_no = b.deal_no
                           AND t.task_state > '0' --任务状态>已生成
                         ORDER BY t.task_id) LOOP
      --找出当前卡号表中，当前同卡号前缀最大的卡号，保留此卡号不删除
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
      av_msg := '移除卡号到临时表异常：' || SQLERRM;
    
  END p_card_no_2_his;

  /*=======================================================================================*/
  --市场号变更，定时器触发
  /*=======================================================================================*/
  /* procedure p_change_market_reg_no is
    ld_date date := sysdate;
    ls_date varchar2(10);
  begin
    select to_char(ld_date, 'yyyy-mm-dd') into ls_date from dual;
    for lrec_m in (select *
                     from bs_market_change
                    where STATE = '0' --未生效
                      and valid_date <= ls_date --已到生效日期
                    order by valid_date, MARKET_REG_NO) loop
      --本条记录生效
      update bs_market_change
         set valid_date = ls_date, EFFECT_TIME = ld_date
       where id = lrec_m.id;
      update bs_market
         set market_reg_no = lrec_m.market_reg_no
       where market_id = lrec_m.market_id;
  
      --前一条记录失效
      update bs_market_change
         set invalid_date = ls_date
       where market_reg_no_old = lrec_m.market_reg_no_old
         and state = '2'; --失效
    end loop;
    /* exception
    when others then
      null;
  end p_change_market_reg_no;*/

  procedure p_account2(av_db_acc_no        varchar2, --借方账户
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
  end p_account2;

END pk_business;
/

