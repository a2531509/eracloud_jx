CREATE OR REPLACE PACKAGE BODY pk_cutday IS

  /*=======================================================================================*/
  --2日切--更改清分日期
  /*=======================================================================================*/
  PROCEDURE p_closeacc(av_res OUT VARCHAR2, --传出代码
                       av_msg OUT VARCHAR2 --传出错误信息
                       ) IS
    lv_newdate pay_clr_para.clr_date%TYPE; --新清分日期
    lv_control    pay_clr_para%ROWTYPE; --批处理控制参数表
    lv_sysdate    DATE;
    lv_between_days number;
  BEGIN
    lv_between_days:=0;
    SELECT * INTO lv_control FROM pay_clr_para;
    --计算新的清分日期--24点之前新清分日期为当前日期，24点之后新清分日期为下一日期
    /*lv_sysdate := SYSDATE;
    IF to_char(lv_sysdate, 'hh24') < '24' THEN
      lv_newdate := to_char(lv_sysdate, 'yyyy-mm-dd');
    ELSE
      lv_newdate := to_char(lv_sysdate + 1, 'yyyy-mm-dd');
    END IF;*/
    SELECT to_char(to_date(lv_control.clr_date,'yyyy-mm-dd') + 1, 'yyyy-mm-dd') INTO lv_newdate FROM dual;
    /*IF lv_newdate >=to_char(SYSDATE,'yyyy-mm-dd') THEN
      av_res := '-1';
      av_msg := '已日切，不需要再日切';
      RETURN;
    END IF;*/
    select  to_date(lv_control.clr_date,'yyyy-mm-dd') -to_date(trunc(sysdate)) into lv_between_days from dual;
    if lv_between_days >=1  then
      av_res := '-1';
      av_msg := '已日切，不需要再日切';
      RETURN;
    end if;
    --更改清分日期
    IF lv_newdate <= lv_control.clr_date THEN
      --已是新清分日期
      av_res := '-1';
      av_msg := '已日切，不需要再日切';
      RETURN;
    ELSE
      UPDATE pay_clr_para
         SET clr_date         = lv_newdate,
             acc_switch       = '0',
             batch_proc_state = '2'
       WHERE clr_date = lv_control.clr_date
         AND acc_switch = '1';
      IF SQL%ROWCOUNT = 0 THEN
        av_res := '-2';
        av_msg := '已日切，不需要再日切';
        RETURN;
      END IF;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
      ROLLBACK;
  END p_closeacc;  ---看过 修改过？？？？
  /*=======================================================================================*/
  --3总分核对 写总账表
  /*=======================================================================================*/
  PROCEDURE p_checkbalance(av_clrdate VARCHAR2, --清分日期
                           av_res     OUT VARCHAR2, --传出代码
                           av_msg     OUT VARCHAR2 --传出错误信息
                           ) IS
    lv_bal   NUMBER;
    lv_genacc acc_account_gen%ROWTYPE; --日总账表
    lv_clrdate   pay_clr_para.clr_date%TYPE;
    lv_tableName Varchar2(100);
  BEGIN
  --修改日切控制表数据
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT to_char(to_date(clr_date, 'yyyy-mm-dd') - 1, 'yyyy-mm-dd')
        INTO lv_clrdate
        FROM pay_clr_para;
    END IF;
    UPDATE pay_clr_para
       SET batch_proc_state = '3'
     WHERE acc_switch = '0'
       AND batch_proc_state = '2';
    COMMIT;
    --1111111111111111111111帐户借贷平衡检查
    SELECT nvl(SUM(bal), 0) INTO lv_bal FROM acc_account_sub;
  /*  FOR i IN 0 .. pk_public.cs_cm_card_nums - 1 LOOP
      EXECUTE IMMEDIATE 'select nvl(sum(bal),0) + ' || lv_bal ||
                        ' from acc_sub_ledger_' || TRIM(to_char(i, '00'))
        INTO lv_bal;
    END LOOP;*/
    IF lv_bal <> 0 THEN
      av_msg := '帐户借贷不平，差值：' || to_char(lv_bal);
      pk_public.p_insertrzcllog(av_msg, REPLACE(lv_clrdate, '-', ''));
    END IF;
    lv_tableName:='acc_inout_detail_'||to_char(to_date(lv_clrdate, 'yyyy-mm-dd'), 'yyyymm');
    --2222222222222222222222流水借贷平衡检查
    EXECUTE IMMEDIATE 'select nvl(sum(db_amt - cr_amt),0) ' ||
                      ' from ' || lv_tableName ||
                      ' where db_amt <> cr_amt'
      INTO lv_bal;
    IF lv_bal <> 0 THEN
      av_msg := '流水借贷不平，差值：' || to_char(lv_bal);
      pk_public.p_insertrzcllog(av_msg, REPLACE(lv_clrdate, '-', ''));
    END IF;
    --3333333333333333333333写日总账表
    FOR lv_item IN (SELECT * FROM acc_item WHERE item_lvl = '2') LOOP
      lv_genacc.clr_date    := lv_clrdate;
      lv_genacc.item_id     := lv_item.item_id;
      lv_genacc.item_lvl    := lv_item.item_lvl;
      lv_genacc.top_item_id := lv_item.top_item_id;
      lv_genacc.bal_type    := lv_item.bal_type;
      --上日余额
      BEGIN
        SELECT cur_bal
          INTO lv_genacc.prv_bal
          FROM acc_account_gen
         WHERE item_id = lv_item.item_id
           AND clr_date = (SELECT MAX(clr_date)
                             FROM acc_account_gen
                            WHERE item_id = lv_item.item_id
                              AND clr_date < lv_clrdate);
      EXCEPTION
        WHEN no_data_found THEN
          lv_genacc.prv_bal := 0;
      END;
      lv_genacc.prv_bal := nvl(lv_genacc.prv_bal, 0);
      --当日流水金额
      EXECUTE IMMEDIATE 'select count(*),nvl(sum(db_amt),0) ' ||
                        ' from acc_inout_detail_'||
                        trim(to_char(to_date(lv_clrdate, 'yyyy-mm-dd'), 'yyyymm')) ||
                        ' where db_item_id = :1 and deal_state in (0,1,3)'
        INTO lv_genacc.db_num, lv_genacc.db_amt
        USING lv_item.item_id;
      EXECUTE IMMEDIATE 'select count(*),nvl(sum(cr_amt),0) ' ||
                        ' from acc_inout_detail_'||
                        trim(to_char(to_date(lv_clrdate, 'yyyy-mm-dd'), 'yyyymm'))||
                        ' where cr_item_id = :1 and deal_state in (0,1,3)'
        INTO lv_genacc.cr_num, lv_genacc.cr_amt
        USING lv_item.item_id;
      --当日余额
      lv_genacc.cur_bal := lv_genacc.prv_bal - lv_genacc.db_amt +
                              lv_genacc.cr_amt;
      --分户账笔数金额
      SELECT COUNT(*), nvl(SUM(bal), 0)
        INTO lv_genacc.acc_num, lv_genacc.acc_amt
        FROM acc_account_sub
       WHERE item_id = lv_item.item_id;
     /* FOR i IN 0 .. pk_public.cs_cm_card_nums - 1 LOOP
        EXECUTE IMMEDIATE 'select count(*) + ' || lv_genacc.acc_num ||
                          ',nvl(sum(balance),0) + ' || lv_genacc.acc_amt ||
                          ' from acc_sub_ledger_' || TRIM(to_char(i, '00')) ||
                          ' where item_no = :1'
          INTO lv_genacc.acc_num, lv_genacc.acc_amt
          USING lv_item.item_no;
      END LOOP;*/
      --总分核对
      DELETE FROM acc_account_gen
       WHERE clr_date = lv_clrdate
         AND item_id = lv_item.item_id;
      IF SQL%ROWCOUNT > 0 THEN
        lv_genacc.acc_amt := lv_genacc.cur_bal;
      END IF;
      IF lv_genacc.cur_bal <> lv_genacc.acc_amt THEN
        lv_genacc.chk_flag := '1';
      ELSE
        lv_genacc.chk_flag := '0';
      END IF;
      lv_genacc.gen_sub := lv_genacc.cur_bal - lv_genacc.acc_amt;
      --保存
      INSERT INTO acc_account_gen VALUES lv_genacc;
    END LOOP;

    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
      ROLLBACK;
  END p_checkbalance;
  /*=======================================================================================*/
  --4打开账户
  /*=======================================================================================*/
  PROCEDURE p_openacc(av_res OUT VARCHAR2, --传出代码
                      av_msg OUT VARCHAR2 --传出错误信息
                      ) IS
  BEGIN
    UPDATE pay_clr_para
       SET acc_switch = '1', batch_proc_state = '4'
     WHERE acc_switch = '0'
       AND batch_proc_state = '3';
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
      ROLLBACK;
  END p_openacc;
  /*=======================================================================================*/
  --5日初始化
  /*=======================================================================================*/
  PROCEDURE p_datebegin(av_res OUT VARCHAR2, --传出代码
                        av_msg OUT VARCHAR2 --传出错误信息
                        ) IS
  lv_card_config   card_config%ROWTYPE;
  BEGIN
    --更新服务状态
    UPDATE pay_clr_para
       SET batch_proc_state = '5', last_modi_time = SYSDATE
     WHERE acc_switch = '1'
       AND batch_proc_state = '4';
    IF SQL%ROWCOUNT > 0 THEN
      COMMIT;
      --现金尾箱
      UPDATE cash_box
         SET yd_blc     = td_blc,
             td_in_num  = 0,
             td_in_amt  = 0,
             td_out_num = 0,
             td_out_amt = 0;

      --当日是否已轧帐(0是1否)
      UPDATE sys_users t SET t.isemployee = '1' WHERE t.isemployee = '0';


      --临时挂失卡自定解挂失
      /*FOR dd IN (SELECT t.*,t.rowid FROM card_config t ) LOOP
         FOR cc IN (SELECT t1.*,t1.rowid FROM acc_account_sub t1 WHERE  TRUNC(lss_Date-SYSDATE)-1 >dd.temp_lost_days) LOOP
          UPDATE acc_account_sub t SET t.lss_date = NULL,t.acc_state = '1'
             WHERE t.card_no = cc.card_no AND t.card_type = dd.card_type;
          UPDATE card_baseinfo t2 SET t2.card_state = '1' ,t2.last_modify_date = SYSDATE WHERE
             t2.card_no = cc.card_no AND t2.card_type = dd.card_type;
          END LOOP;
      END LOOP;*/
       declare
          lm_res varchar2(20);
          lm_msg varchar2(200);
      BEGIN
   FOR dd IN (SELECT t.*,t.rowid FROM card_config t ) LOOP
     FOR cc IN (SELECT t1.*,t1.rowid,b.cert_no certno1 FROM card_baseinfo t1,base_personal b WHERE t1.card_state = '2' AND t1.card_type = dd.card_type and t1.customer_id = b.customer_id and TRUNC(SYSDATE - t1.last_modify_date)+1   >= dd.temp_lost_days) LOOP
       BEGIN
          UPDATE acc_account_sub t SET t.lss_date = NULL,t.acc_state = '1' WHERE t.card_no = cc.card_no AND t.card_type = dd.card_type;
          UPDATE card_baseinfo t2 SET t2.card_state = '1' ,t2.last_modify_date = SYSDATE WHERE t2.card_no = cc.card_no AND t2.card_type = dd.card_type;
          IF dd.card_type IN ('100','120') THEN
            INSERT INTO CARD_UPDATE
                  (CARDUPDATESEQ,
                   CLIENTID,
                   SUB_CARDID,
                   SUB_CARDNUMBER,
                   NAME,
                   CERTTYPE,
                   CERTNUMBER,
                   SEX,
                   CARDBIZTYPE,
                   OLD_SUBCARDID,
                   OLD_SUBCARDNUMBER,
                   PERSONALID,
                   SWITCHNODE,
                   UPDATETIME,
                   ACTIONNO,
                   CARD_TYPE,
                   VERSION,
                   ORG_CODE,
                   ISSUE_DATE,
                   VALID_DATE,
                   NATION,
                   BIRTHDAY,
                   RESIDE_ADDR,
                   MED_WHOLE_NO,
                   PRO_ORG_CODE,
                   PRO_MEDIA_TYPE,
                   PRO_VERSION,
                   PRO_INIT_DATE,
                   CLBZ,
                   CLSJ,
                   STCLSJ,
                   NOTE)
                  SELECT SEQ_CARD_UPDATE_XH.NEXTVAL, B.CUSTOMER_ID, D.SUB_CARD_ID, D.SUB_CARD_NO, B.NAME, B.CERT_TYPE, B.CERT_NO, B.GENDER,'5',null,null, S.PERSONAL_ID, '04', SYSDATE, null, D.CARD_TYPE, D.VERSION, D.INIT_ORG_ID, D.ISSUE_DATE, D.VALID_DATE, B.NATION, B.BIRTHDAY, B.LETTER_ADDR, S.MED_WHOLE_NO, NULL, NULL, NULL, NULL, '0', NULL, NULL, NULL
                    FROM CARD_BASEINFO D, BASE_PERSONAL B, BASE_SIINFO S
                   WHERE D.CUSTOMER_ID = B.CUSTOMER_ID
                     AND B.CERT_NO = S.CERT_NO
                     AND D.CARD_NO = cc.card_no
                     AND B.CERT_NO = cc.certno1
                     AND S.RESERVE_7 <> '1';
                 
               END IF;
               pk_public.p_insertrzcllog('自动解挂成功' || cc.card_no,0);
               COMMIT;
                BEGIN
                pk_service_outer.p_card_black(seq_action_no.nextval,cc.card_no,'1','',to_char(sysdate,'yyyy-mm-dd hh24:mi:ss'),lm_res,lm_msg);
                exception when others THEN
                  NULL;
                END;
            exception when others then 
                   ROLLBACK;
                   pk_public.p_insertrzcllog('自动解挂失败' || cc.card_no,0);
            end;
      END LOOP;
  END LOOP;
  EXCEPTION WHEN OTHERS THEN 
       pk_public.p_insertrzcllog('自动解挂error ' || Sqlerrm,0);
  end;


      --更新密码输入错误次数
      UPDATE sys_users a SET a.LOGIN_COUNT = 0 WHERE a.login_count > 0;
      update card_baseinfo set pay_pwd_err_num = 0 where pay_pwd_err_num > 0;
      update card_baseinfo set net_pay_pwd_err_num = 0 where net_pay_pwd_err_num > 0;
    END IF;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
      ROLLBACK;
  END p_datebegin;
  /*=======================================================================================*/
  --6批处理
  /*=======================================================================================*/
  PROCEDURE p_batchdeal(av_clrdate VARCHAR2, --清分日期
                        av_res     OUT VARCHAR2, --传出代码
                        av_msg     OUT VARCHAR2 --传出错误信息
                        ) IS
    lv_clrdate pay_clr_para.clr_date%TYPE;
  BEGIN
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT to_char(to_date(clr_date, 'yyyy-mm-dd') - 1, 'yyyy-mm-dd')
        INTO lv_clrdate
        FROM pay_clr_para;
    END IF;
    --生成清分记录
    FOR lv_merchant IN (SELECT * FROM base_merchant WHERE merchant_state='0') LOOP
      p_clr(lv_merchant.merchant_id, --商户号
            lv_clrdate, --清分日期
            av_res, --传出代码
            av_msg --传出错误信息
            );
      IF av_res <> pk_public.cs_res_ok THEN
        ROLLBACK;
        RETURN;
      ELSE
        COMMIT;
      END IF;
    END LOOP;
    --生成合作机构清分记录
   /* FOR lv_co_org IN (SELECT * FROM base_co_org where CHECK_TYPE <> 3) LOOP
      p_clr(lv_co_org.co_org_id, --商户号
            lv_clrdate, --清分日期
            av_res, --传出代码
            av_msg --传出错误信息
            );
      IF av_res <> pk_public.cs_res_ok THEN
        ROLLBACK;
        RETURN;
      END IF;
    END LOOP;*/

    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
      ROLLBACK;
  END p_batchdeal;

  /*=======================================================================================*/
  --清分
  /*=======================================================================================*/
  PROCEDURE p_clr(av_bizid   VARCHAR2, --商户号
                  av_clrdate VARCHAR2, --清分日期
                  av_res     OUT VARCHAR2, --传出代码
                  av_msg     OUT VARCHAR2 --传出错误信息
                  ) IS
    lv_cursor      pk_public.t_cur; --游标
    lv_tablename   VARCHAR2(50);
    lv_clrtradesum pay_clr_sum%ROWTYPE; --清分汇总表
    lv_clrdate     pay_clr_para.clr_date%TYPE;
    lv_clrno       pay_clr_sum.clr_no%TYPE;
    --保存清分汇总表
    PROCEDURE p_insertclrtradesum IS
    BEGIN
      lv_clrtradesum.clr_no   := lv_clrno;
      lv_clrtradesum.clr_date := av_clrdate;
      lv_clrtradesum.merchant_id   := av_bizid;
      INSERT INTO pay_clr_sum VALUES lv_clrtradesum;
    END p_insertclrtradesum;
  BEGIN
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT to_char(to_date(clr_date, 'yyyy-mm-dd') - 1, 'yyyy-mm-dd')
        INTO lv_clrdate
        FROM pay_clr_para;
    END IF;
    lv_tablename := 'acc_inout_detail_' ||trim(to_char(to_date(lv_clrdate, 'yyyy-mm-dd'), 'yyyymm'));
    --生成清分记录(运营机构自有商户清算)/*and POSP_PROC_STATE =''0''*/
    SELECT seq_clr_no.nextval INTO lv_clrno FROM dual;
    EXECUTE IMMEDIATE 'update ' || lv_tablename || ' set clr_no = ' ||
                      lv_clrno ||
                      ' where acpt_id =:1 and deal_state in (0,3) ' || 'and clr_date =:2' ||
                      ' and clr_no is null  and deal_code in(''40101010'',''40101051'',''40201010'',''40201051'')' --clr_no有值的是已经即时清分过的
      USING av_bizid,lv_clrdate;
    OPEN lv_cursor FOR 'select 0,null,null,deal_code,db_card_type,db_acc_kind,' || --
     ' count(*),sum(db_amt),null,null,null,null,null,null' || --
     ' from ' || lv_tablename || ' t1 ' || --
     ' where acpt_id=:1 and deal_state in (0,3) and clr_no = :2' || --
     ' group by deal_code,db_card_type,db_acc_kind '
      USING av_bizid, lv_clrno;
    LOOP
      FETCH lv_cursor
        INTO lv_clrtradesum;
      EXIT WHEN lv_cursor%NOTFOUND;
      p_insertclrtradesum;
    END LOOP;
    CLOSE lv_cursor;

    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
  END p_clr;

  /*=======================================================================================*/
  --合作机构清分   对账主体如果选择的base_co_org CHECK_TYPE 为 3时 先不清算，等到对账平再结算
  /*=======================================================================================*/
  PROCEDURE p_co_clr(av_co_org_id   VARCHAR2, -- 合作机构号
                  av_clrdate VARCHAR2, --清分日期
                  av_res     OUT VARCHAR2, --传出代码
                  av_msg     OUT VARCHAR2 --传出错误信息
                  ) IS
    lv_cursor      pk_public.t_cur; --游标
    lv_cursor_cosume pk_public.t_cur; --游标
    lv_tablename   VARCHAR2(50);
    lv_clrtradesum pay_co_clr_sum%ROWTYPE; --清分汇总表
    lv_clrdate     pay_clr_para.clr_date%TYPE;
    lv_clrno       pay_clr_sum.clr_no%TYPE;
    --保存清分汇总表
    PROCEDURE p_insertclrtradesum_co IS
    BEGIN
      lv_clrtradesum.clr_no   := lv_clrno;
      lv_clrtradesum.clr_date := av_clrdate;
      lv_clrtradesum.acpt_id  := av_co_org_id;
      INSERT INTO pay_co_clr_sum VALUES lv_clrtradesum;
    END p_insertclrtradesum_co;
  BEGIN
    lv_clrdate := av_clrdate;
    IF lv_clrdate IS NULL THEN
      SELECT to_char(to_date(clr_date, 'yyyy-mm-dd') - 1, 'yyyy-mm-dd')
        INTO lv_clrdate
        FROM pay_clr_para;
    END IF;
    lv_tablename := 'acc_inout_detail' ||trim(to_char(to_date(lv_clrdate, 'yyyy-mm-dd'), 'yyyymm'));
    --生成清分记录
    SELECT seq_clr_no.nextval INTO lv_clrno FROM dual;
    EXECUTE IMMEDIATE 'update ' || lv_tablename || ' set clr_no = ' ||
                      lv_clrno ||
                      ' where acpt_org_id =:1 and tr_state in (0,3) ' ||
                      ' and clr_no is null and deal_code in (''40102010'',''40102051'',''40202010'',''40202051'')' --clr_no有值的是已经即时清分过的
      USING av_co_org_id;
      --充值数据汇总
    OPEN lv_cursor FOR 'select 0,null,null,null,acpt_acpt_id,acpt_type,deal_code,db_card_type,db_acc_kind,' || --
     ' count(*),sum(cr_amt),null,null,null,null,null,null' || --
     ' from ' || lv_tablename || ' t1 ' || --
     ' where acpt_org_id =:1  and deal_state in (0,3) and clr_no = :2 and deal_code like ''%30%''' || --
     ' group by acpt_org_id,card_org_id,acpt_id,acpt_type,deal_code,cr_card_type,cr_acc_kind,clr_date'
      USING av_co_org_id, lv_clrno;
    LOOP
      FETCH lv_cursor
        INTO lv_clrtradesum;
      EXIT WHEN lv_cursor%NOTFOUND;
      p_insertclrtradesum_co;
    END LOOP;
    CLOSE lv_cursor;
      --消费数据汇总
    OPEN lv_cursor_cosume FOR 'select 0,null,null,null,acpt_acpt_id,acpt_type,deal_code,db_card_type,db_acc_kind,' || --
     ' count(*),sum(db_amt),null,null,null,null,null,null' || --
     ' from ' || lv_tablename || ' t1 ' || --
     ' where acpt_org_id =:1  and deal_state in (0,3) and clr_no = :2  and deal_code like ''%4020%''' || --
     ' group by acpt_org_id,card_org_id,acpt_id,acpt_type,deal_code,db_card_type,db_acc_kind,clr_date '
      USING av_co_org_id, lv_clrno;
    LOOP
      FETCH lv_cursor_cosume
        INTO lv_clrtradesum;
      EXIT WHEN lv_cursor%NOTFOUND;
      p_insertclrtradesum_co;
    END LOOP;
    CLOSE lv_cursor_cosume;

    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := SQLERRM;
  END p_co_clr;


  PROCEDURE p_test IS
    lv_res  VARCHAR2(8); --传出代码
    lv_msg  VARCHAR2(1024); --传出错误信息
    lv_date DATE := to_date('2015-06-25', 'yyyy-mm-dd');
  BEGIN
    WHILE lv_date < trunc(SYSDATE, 'dd') LOOP
      p_checkbalance(to_char(lv_date, 'yyyy-mm-dd'), lv_res, lv_msg);
      lv_date := lv_date + 1;
    END LOOP;

  END p_test;
  /*=======================================================================================*/
  --签到促销
  --每次消费者签到，从经营户的商户卡里扣0.4元给会员卡的未圈存账户上；
  --  同时每月签到30次及以上的次月给予10元买菜金的奖励，
  --      每年签到100次及以上的另外给予10元买菜金。
  /*=======================================================================================*/
 /* PROCEDURE p_signpromotion IS
    lv_res     VARCHAR2(10);
    lv_msg     VARCHAR2(1000);
    lv_sysdate DATE := SYSDATE;
  BEGIN
    FOR lv_sign IN (SELECT send_file_name
                      FROM pay_offline_filename
                     WHERE state = '1'
                       AND file_type = 'QD') LOOP
      BEGIN
        pk_consume.p_signpromotion(lv_sign.send_file_name, --签到文件名
                                   '0', --1调试
                                   lv_res, --传出代码
                                   lv_msg --传出错误信息
                                   );
        IF lv_res <> pk_public.cs_res_ok THEN
          ROLLBACK;
          pk_public.p_insertrzcllog('pk_consume.p_signpromotion,send_file_name:' ||
                                    lv_sign.send_file_name || ',err:' ||
                                    lv_msg,
                                    -1);
        ELSE
          COMMIT;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
      END;
    END LOOP;
    IF to_char(lv_sysdate, 'dd') = '01' THEN
      --月
      pk_consume.p_signpromotion_month(to_char(lv_sysdate - 1, 'yyyy-mm'), --月份yyyy-mm
                                      '0', --1调试
                                      lv_res, --传出代码
                                      lv_msg --传出错误信息
                                      );
      IF lv_res <> pk_public.cs_res_ok THEN
        ROLLBACK;
        --Raise_application_error(-20000, lv_msg);
      END IF;
      IF to_char(lv_sysdate, 'mm') = '01' THEN
        --年
        pk_consume.p_signpromotion_year(to_char(lv_sysdate - 1, 'yyyy'), --年份yyyy
                                        '0', --1调试
                                        lv_res, --传出代码
                                        lv_msg --传出错误信息
                                        );
        IF lv_res <> pk_public.cs_res_ok THEN
          ROLLBACK;
          --Raise_application_error(-20000, lv_msg);
        END IF;
      END IF;
    END IF;
  END p_signpromotion;
  /*=======================================================================================*/
  --日切job
  --记acc_rzcllog 的action -999900001开始
  /*=======================================================================================*/
  PROCEDURE p_job IS
    lv_res VARCHAR2(8); --传出代码
    lv_msg VARCHAR2(1024); --传出错误信息
  BEGIN
    pk_public.p_insertrzcllog('开始pk_cutday.p_job', -99990001);
    --消费文件处理
    FOR lv_merchant IN (SELECT * FROM base_merchant) LOOP
      pk_consume.p_offlineconsume(lv_merchant.merchant_id, --传入参数
                                  '0', --1调试
                                  lv_res, --传出代码
                                  lv_msg --传出错误信息
                                  );
      IF lv_res <> pk_public.cs_res_ok THEN
        ROLLBACK;
        pk_public.p_insertrzcllog('pk_consume.p_offlineconsume,merchantid:' ||
                                  lv_merchant.merchant_id || ',err:' || lv_msg,
                                  -1);
      ELSE
        COMMIT;
      END IF;
    END LOOP;
    --pk_public.p_insertrzcllog('结束消费文件处理,开始签到处理', -99990001);
    --签到处理
    --p_signpromotion;
    --pk_public.p_insertrzcllog('结束签到处理,开始p_closeacc', -99990001);
    p_closeacc(lv_res, lv_msg);
    pk_public.p_insertrzcllog('结束p_closeacc,开始p_checkbalance',
                              -99990001);
    p_checkbalance(NULL, lv_res, lv_msg);
    pk_public.p_insertrzcllog('结束p_checkbalance,开始p_openacc',
                              -99990001);
    p_openacc(lv_res, lv_msg);
    pk_public.p_insertrzcllog('结束p_openacc,开始p_datebegin', -99990001);
    p_datebegin(lv_res, lv_msg);
    pk_public.p_insertrzcllog('结束p_datebegin,开始p_batchdeal', -99990001);
    p_batchdeal(NULL, lv_res, lv_msg);
    pk_public.p_insertrzcllog('结束pk_cutday.p_job', -99990001);
  END p_job;
BEGIN
  -- initialization
  NULL;
END pk_cutday;
/

