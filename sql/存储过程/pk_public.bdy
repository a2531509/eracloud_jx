CREATE OR REPLACE PACKAGE BODY pk_public IS
  /*=======================================================================================*/
  --分解字符串
  /*=======================================================================================*/
  FUNCTION f_splitstr(av_in      IN VARCHAR2,
                      av_partstr IN VARCHAR2,
                      av_out     OUT myarray) RETURN INT DETERMINISTIC IS
    i         BINARY_INTEGER;
    ipos      BINARY_INTEGER;
    lspartstr INT;
    sinmsg    LONG;

  BEGIN
    IF (av_in IS NULL) OR (av_partstr IS NULL) THEN
      RETURN - 1;
    END IF;
    i         := 1;
    ipos      := 1;
    sinmsg    := av_in;
    lspartstr := length(av_partstr); --在循环外先计算av_partstr长度
    LOOP
      -- 改用 loop 循环
      EXIT WHEN sinmsg IS NULL;
      ipos := instr(sinmsg, av_partstr, 1, 1);
      IF ipos = 0 THEN
        av_out(i) := sinmsg;
        i := i + 1;
        EXIT; -- 退出循环
      END IF;
      av_out(i) := substr(sinmsg, 1, ipos - 1);
      sinmsg := substr(sinmsg, ipos + lspartstr);
      IF sinmsg IS NULL THEN
        i := i + 1;
        av_out(i) := '';
        i := i + 1;
        EXIT;
      END IF;
      i := i + 1;
    END LOOP;

    IF i > 1 THEN
      RETURN i - 1;
    ELSE
      RETURN - 1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN - 1;
  END f_splitstr;

  /*=======================================================================================*/
  --把数组av_start到av_end的置空
  /*=======================================================================================*/
  PROCEDURE p_initarray(av_in    IN OUT myarray,
                        av_start NUMBER,
                        av_end   NUMBER) IS
  BEGIN
    FOR i IN av_start .. av_end LOOP
      IF av_in.count < i THEN
        av_in(i) := NULL;
      END IF;
    END LOOP;
  END p_initarray;
  /*=======================================================================================*/
  --查询系统参数
  /*=======================================================================================*/
  FUNCTION f_getsyspara(av_paraname IN sys_para.para_code%TYPE --参数名称
                        ) RETURN VARCHAR2 IS
    lv_paravalue sys_para.para_value%TYPE;
  BEGIN
    SELECT para_value
      INTO lv_paravalue
      FROM sys_para
     WHERE para_code = upper(av_paraname);
    RETURN lv_paravalue;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN '0';
    WHEN OTHERS THEN
      RETURN '-1';
  END f_getsyspara;
  /*=======================================================================================*/
  --卡号分表取模
  /*=======================================================================================*/
  FUNCTION f_cardmode(av_cardno VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
  BEGIN
    --卡号4位校验码前的2位
    RETURN TRIM(to_char(MOD(substrb(av_cardno, lengthb(av_cardno) - 5, 2),
                            cs_cm_card_nums),
                        '00'));
  END f_cardmode;
  /*=======================================================================================*/
  --根据卡号返回卡片所在表名
  /*=======================================================================================*/
  FUNCTION f_getcardtablebycard_no(av_cardno VARCHAR2) RETURN VARCHAR2
    DETERMINISTIC IS
    lv_mode VARCHAR2(2);
  BEGIN
    lv_mode := f_cardmode(av_cardno);
    RETURN 'cm_card_' || lv_mode;
  END f_getcardtablebycard_no;
  /*=======================================================================================*/
  --根据卡号返回账户所在表名
  /*=======================================================================================*/
  FUNCTION f_getsubledgertablebycard_no(av_cardno VARCHAR2) RETURN VARCHAR2
    DETERMINISTIC IS
    lv_mode VARCHAR2(2);
  BEGIN
    lv_mode := f_cardmode(av_cardno);
    RETURN 'acc_account_sub' || lv_mode;
  END f_getsubledgertablebycard_no;
  /*=======================================================================================*/
  --根据卡号返回积分构成表所在表名
  /*=======================================================================================*/
  FUNCTION f_getpointsperiodbycard_no(av_cardno VARCHAR2) RETURN VARCHAR2
    DETERMINISTIC IS
    lv_mode VARCHAR2(2);
  BEGIN
    lv_mode := f_cardmode(av_cardno);
    RETURN 'points_book_' || lv_mode;
  END f_getpointsperiodbycard_no;
  /*=======================================================================================*/
  --根据卡号、交易日期返回卡片交易记录表所在表名
  /*=======================================================================================*/
  FUNCTION f_gettrcardtable(av_cardno VARCHAR2, av_trdate DATE)
    RETURN VARCHAR2 DETERMINISTIC IS
    lv_trdate VARCHAR2(6);
    lv_mode   VARCHAR2(2);
  BEGIN
    lv_trdate := to_char(av_trdate, 'yyyymm');
    -- lv_mode   := f_cardmode(av_cardno);
    RETURN 'pay_card_deal_rec_' || lv_trdate;
  END f_gettrcardtable;
  /*=======================================================================================*/
  --记调试日志
  /*=======================================================================================*/
  PROCEDURE p_insertrzcllog(av_remark   acc_rzcllog.remark%TYPE,
                            av_actionno NUMBER) IS
    --PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    p_insertrzcllog_('0', av_remark, av_actionno);
  END p_insertrzcllog;
  /*=======================================================================================*/
  --记调试日志
  /*=======================================================================================*/
  PROCEDURE p_insertrzcllog_(av_log_flag CHAR, --是否记日志开关，0是1否
                             av_remark   acc_rzcllog.remark%TYPE,
                             av_actionno NUMBER) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF av_log_flag <> '0' THEN
      RETURN;
    END IF;
    INSERT INTO acc_rzcllog
      (id, oper_date, remark, deal_no)
    VALUES
      (seq_rzcllog.nextval, SYSDATE, av_remark, av_actionno);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
      ROLLBACK;
  END p_insertrzcllog_;
  /*=======================================================================================*/
  --根据机构号取虚拟的admin柜员编号
  /*=======================================================================================*/
  FUNCTION f_getorgoperid(av_orgid VARCHAR2 --机构编号
                          ) RETURN VARCHAR2 DETERMINISTIC IS
  BEGIN
    RETURN 'admin' /*'admin_' || av_orgid*/
    ;
  END f_getorgoperid;
  /*=======================================================================================*/
  --根据机构号取虚拟的admin柜员信息
  /*=======================================================================================*/
  PROCEDURE p_getorgoperator(av_orgid    VARCHAR2, --机构编号
                             av_operator OUT sys_USERS%ROWTYPE, --柜员
                             av_res      OUT VARCHAR2, --传出参数代码
                             av_msg      OUT VARCHAR2 --传出参数错误信息
                             ) IS

  BEGIN
    av_operator.User_Id := f_getorgoperid(av_orgid);
    SELECT *
      INTO av_operator
      FROM sys_USERS
     WHERE user_id = av_operator.user_id;
    av_res := pk_public.cs_res_ok;
  EXCEPTION
    WHEN no_data_found THEN
      av_res := pk_public.cs_res_operatorerr;
      av_msg := '机构号' || av_orgid || '未建对应柜员';
  END p_getorgoperator;
  /*=======================================================================================*/
  --根据卡类型查询科目号--充值卡充值时用到
  /*=======================================================================================*/
  FUNCTION f_getitemnobycardtype(av_cardtype VARCHAR2 --卡类型
                                 ) RETURN VARCHAR2 IS
    lv_itemno acc_open_conf.item_id%TYPE;
  BEGIN
    SELECT item_id
      INTO lv_itemno
      FROM acc_open_conf
     WHERE main_type = '1'
       AND sub_type = av_cardtype
       AND rownum < 2;
    RETURN lv_itemno;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END f_getitemnobycardtype;
  /*=======================================================================================*/
  --根据科目号和机构号查找机构分账户
  /*=======================================================================================*/
  PROCEDURE p_getorgsubledger(av_orgid     VARCHAR2, --机构号
                              av_itemno    VARCHAR2, --科目号
                              av_subledger OUT acc_account_sub%ROWTYPE, --分户账
                              av_res       OUT VARCHAR2, --传出参数代码
                              av_msg       OUT VARCHAR2 --传出参数错误信息
                              ) IS
  BEGIN
    SELECT t1.*
      INTO av_subledger
      FROM acc_account_sub t1, sys_organ t2
     WHERE t1.customer_id = t2.customer_id
       AND t1.item_id = av_itemno
       AND t2.org_id = av_orgid;
    av_res := cs_res_ok;
  EXCEPTION
    WHEN no_data_found THEN
      BEGIN
        SELECT t1.*
          INTO av_subledger
          FROM acc_account_sub t1, pay_divide_org t2
         WHERE t1.customer_id = t2.customer_id
           AND t1.item_id = av_itemno
           AND t2.org_id = av_orgid;
        av_res := cs_res_ok;
      EXCEPTION
        WHEN no_data_found THEN
          av_res := cs_res_accnotexit;
          av_msg := '根据科目号' || av_itemno || '和机构号' || av_orgid || '找不到分户账';
      END;
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '根据科目号' || av_itemno || '和机构' || av_orgid || '查询分账号发生错误：' ||
                SQLERRM;
  END p_getorgsubledger;
  /*=======================================================================================*/
  --根据科目号和网点号查找分账户
  /*=======================================================================================*/
  PROCEDURE p_getsubledgerbyclientid(av_clientid  VARCHAR2, --客户号/网点号
                                     av_itemno    VARCHAR2, --科目号
                                     av_subledger OUT acc_account_sub%ROWTYPE, --分户账
                                     av_res       OUT VARCHAR2, --传出参数代码
                                     av_msg       OUT VARCHAR2 --传出参数错误信息
                                     ) IS
  BEGIN
    SELECT *
      INTO av_subledger
      FROM acc_account_sub
     WHERE customer_id = av_clientid
       AND item_id = av_itemno;
    av_res := cs_res_ok;
  EXCEPTION
    WHEN no_data_found THEN
      av_res := cs_res_accnotexit;
      av_msg := '根据科目号' || av_itemno || '和网点号' || av_clientid || '找不到分户账';
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '根据科目号和客户号\网点号查询分账号发生错误：' || SQLERRM;
  END p_getsubledgerbyclientid;
  /*=======================================================================================*/
  --根据卡号和账户类型查找分账户-----
  /*=======================================================================================*/
  PROCEDURE p_getsubledgerbycardno(av_cardno    VARCHAR2, --卡号
                                   av_acckind   VARCHAR2, --账户类型
                                   av_walletid  IN acc_account_sub.wallet_no%TYPE, --钱包编号
                                   av_subledger OUT acc_account_sub%ROWTYPE, --分户账
                                   av_res       OUT VARCHAR2, --传出参数代码
                                   av_msg       OUT VARCHAR2 --传出参数错误信息
                                   ) IS
    lv_tablename    VARCHAR2(50);
    lv_isparent     VARCHAR2(1); --0主卡1副卡
    lv_parentcardno VARCHAR2(50); --主卡卡号
  BEGIN
    --查主卡卡号
     --lv_tablename := pk_public.f_getcardtablebycard_no(av_cardno);
     --lv_tablename := 'card_baseinfo';
    IF av_acckind = cs_acckind_qb THEN
      lv_parentcardno := av_cardno;
    ELSE
      select main_flag, main_card_no
        into lv_isparent, lv_parentcardno
        from card_baseinfo
       where card_no = av_cardno;
      IF lv_isparent = '0' THEN
        lv_parentcardno := av_cardno;
      END IF;
    END IF;
    --查分户账
    /* lv_tablename := pk_public.f_getsubledgertablebycard_no(lv_parentcardno);
    EXECUTE IMMEDIATE 'select * from ' || lv_tablename ||
                      ' where card_no = :1 and acc_kind = :2 and wallet_id = :3'
      INTO av_subledger
      USING lv_parentcardno, av_acckind, av_walletid;*/

    select *
      into av_subledger
      from acc_account_sub
     where card_no = lv_parentcardno
       and acc_kind = av_acckind
       and wallet_no = av_walletid;
    av_res := cs_res_ok;
  EXCEPTION
    WHEN no_data_found THEN
      av_res := cs_res_accnotexit;
      av_msg := '根据卡号' || av_cardno || '和账户类型' || av_acckind || '，钱包编号' ||
                av_walletid || '找不到分户账';
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '根据卡号' || av_cardno || '和账户类型' || av_acckind || '，钱包编号' ||
                av_walletid || '查询分账号发生错误：' || SQLERRM;
  END p_getsubledgerbycardno;
  /*=======================================================================================*/
  --根据卡号和账户类型查找账户余额    ????修改到此
  /*=======================================================================================*/
  FUNCTION f_getcardbalance(av_cardno   VARCHAR2, --卡号
                            av_acckind  VARCHAR2, --账户类型
                            av_walletid VARCHAR2 --钱包编号
                            ) RETURN NUMBER IS
    lv_subledger acc_account_sub%ROWTYPE;
    lv_res       VARCHAR2(8);
    lv_msg       VARCHAR2(1024);
  BEGIN
    p_getsubledgerbycardno(av_cardno, --卡号
                           av_acckind, --账户类型
                           av_walletid, --钱包编号
                           lv_subledger, --分户账
                           lv_res, --传出参数代码
                           lv_msg --传出参数错误信息
                           );
    IF lv_res <> cs_res_ok THEN
      raise_application_error(-20000, lv_msg);
    ELSE
      RETURN lv_subledger.bal;
    END IF;
  END f_getcardbalance;
  /*=======================================================================================*/
  --根据卡号查找卡片基本信息
  /*=======================================================================================*/
  PROCEDURE p_getcardbycardno(av_cardno VARCHAR2, --卡号
                              av_card   OUT card_baseinfo%ROWTYPE, --卡片基本信息
                              av_res    OUT VARCHAR2, --传出参数代码
                              av_msg    OUT VARCHAR2 --传出参数错误信息
                              ) IS
    lv_tablename VARCHAR2(50);
  BEGIN
    /* lv_tablename := pk_public.f_getcardtablebycard_no(av_cardno);
    EXECUTE IMMEDIATE 'select * from ' || lv_tablename ||
                      ' where card_no = :1'
      INTO av_card
      USING av_cardno;*/

    select * into av_card from card_baseinfo where card_no = av_cardno;
    av_res := cs_res_ok;

  EXCEPTION
    WHEN no_data_found THEN
      av_res := cs_res_cardiderr;
      av_msg := '根据卡号' || av_cardno || '找不到卡片基本信息';
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '根据卡号查询卡片基本信息发生错误：' || SQLERRM;
  END p_getcardbycardno;
  /*=======================================================================================*/
  --根据卡号查找卡类型
  /*=======================================================================================*/
  FUNCTION f_getcardtypebycardno(av_cardno VARCHAR2 --卡号
                                 ) RETURN VARCHAR2 IS
    lv_tablename VARCHAR2(50);
    lv_cardtype  card_baseinfo.card_type%TYPE;
  BEGIN
    /* lv_tablename := pk_public.f_getcardtablebycard_no(av_cardno);
    EXECUTE IMMEDIATE 'select card_type from ' || lv_tablename ||
                      ' where card_no = :1'
      INTO lv_cardtype
      USING av_cardno;*/
    select card_type
      into lv_cardtype
      from card_baseinfo
     where card_no = av_cardno;
    RETURN lv_cardtype;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END f_getcardtypebycardno;
  /*=======================================================================================*/
  --根据账号和卡号查找账户类型
  /*=======================================================================================*/
  FUNCTION f_getacckindbyaccnoandcardno(av_accno  acc_account_sub.acc_no%TYPE, --账号
                                        av_cardno VARCHAR2 --卡号
                                        ) RETURN VARCHAR2 IS
    lv_tablename VARCHAR2(50);
    lv_acckind   acc_account_sub.acc_kind%TYPE;
  BEGIN
    /* lv_tablename := pk_public.f_getsubledgertablebycard_no(av_cardno);
    EXECUTE IMMEDIATE 'select acc_kind from ' || lv_tablename ||
                      ' where acc_no = :1'
      INTO lv_acckind
      USING av_accno;*/
    select acc_kind
      into lv_acckind
      from acc_account_sub
     where acc_no = av_accno;
    RETURN lv_acckind;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END f_getacckindbyaccnoandcardno;
  /*=======================================================================================*/
  --根据卡类型查卡参数表
  /*=======================================================================================*/
  PROCEDURE p_getcardparabycardtype(av_cardtype VARCHAR2, --卡类型
                                    av_para     OUT card_config%ROWTYPE, --卡参数表
                                    av_res      OUT VARCHAR2, --传出参数代码
                                    av_msg      OUT VARCHAR2 --传出参数错误信息
                                    ) IS
  BEGIN
    SELECT * INTO av_para FROM card_config WHERE card_type = av_cardtype;
    av_res := cs_res_ok;
  EXCEPTION
    WHEN no_data_found THEN
      av_res := cs_res_dberr;
      av_msg := '没有卡类型' || av_cardtype || '的卡参数';
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '根据卡类型查卡参数发生错误：' || SQLERRM;
  END p_getcardparabycardtype;
  /*=======================================================================================*/
  --判断卡交易密码
  /*=======================================================================================*/
  PROCEDURE p_judgetradepwd(av_card card_baseinfo%ROWTYPE, --卡信息
                            av_pwd  VARCHAR2, --密码
                            av_res  OUT VARCHAR2, --传出参数代码
                            av_msg  OUT VARCHAR2 --传出参数错误信息
                            ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    lv_tablename VARCHAR2(50);
  BEGIN
    IF av_pwd IS NULL THEN
      av_res := cs_res_ok;
      RETURN;
    end IF;
    IF av_card.pay_pwd_err_num >= cs_trade_pwd_err_num THEN
      av_res := cs_res_pwderrnum;
      av_msg := '交易密码输错次数超限';
      RETURN;
    ELSIF av_card.pay_pwd <> av_pwd THEN
      av_res := cs_res_pwderr;
      av_msg := '密码错误';

      /*lv_tablename := pk_public.f_getcardtablebycard_no(av_card.card_no);
      EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                        ' set pay_pwd_err_num = pay_pwd_err_num + 1 where card_no = :1'
        USING av_card.card_no;*/
      update card_baseinfo
         set pay_pwd_err_num = pay_pwd_err_num + 1
       where card_no = av_card.card_no;
      COMMIT;
      RETURN;
    ELSE
      /* lv_tablename := pk_public.f_getcardtablebycard_no(av_card.card_no);
      EXECUTE IMMEDIATE 'update ' || lv_tablename ||
                        ' set pay_pwd_err_num = 0 where card_no = :1'
        USING av_card.card_no;*/

      update card_baseinfo
         set pay_pwd_err_num = 0
       where card_no = av_card.card_no;
      COMMIT;
    END IF;
    av_res := cs_res_ok;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '判断密码发生未知错误' || SQLERRM;
      ROLLBACK;
  END p_judgetradepwd;

  PROCEDURE p_judgeservicepwd(av_cert_no VARCHAR2, --证件号码
                            av_customer_name VARCHAR2,--姓名
                            av_pwd  VARCHAR2, --密码
                            av_res  OUT VARCHAR2, --传出参数代码
                            av_msg  OUT VARCHAR2 --传出参数错误信息
                            )is
      lv_base_personal base_personal%rowtype;
   begin
       if av_cert_no is null then
           av_res := cs_res_paravalueerr;
           av_msg := '证件号码不能为空！';
           return;
       end if;
       if av_customer_name is null then
           av_res := cs_res_paravalueerr;
           av_msg := '客户姓名不能为空！';
           return;
       end if;
       if av_pwd is null then
           av_res := cs_res_paravalueerr;
           av_msg := '服务密码不能为空！';
           return;
       end if;
       begin
           select * into lv_base_personal from base_personal where cert_no = av_cert_no and name = av_customer_name;
       exception when others then
           av_res := cs_res_cardis_err;
           av_msg := '未找到有效客户信息，无法判断服务密码！';
           return;
       end;
       if nvl(lv_base_personal.serv_pwd_err_num,0) >= cs_serv_pwd_err_num then
           av_res := cs_res_cardis_err;
           av_msg := '服务密码输错次数超限！';
           return;
       end if;
       if nvl(lv_base_personal.serv_pwd,'0') = '0' then
           av_res := cs_res_pwderr;
           av_msg := '客户服务密码信息不存在，请先进行密码重置！';
           return;
       end if;
       if av_pwd <> lv_base_personal.serv_pwd then
           av_res := cs_res_pwderr;
           av_msg := '服务密码不正确！';
           update base_personal  set serv_pwd_err_num = nvl(serv_pwd_err_num,0) + 1
           where cert_no = av_cert_no and name = av_customer_name;
           commit;
           return;
       else
           update base_personal set serv_pwd_err_num = 0
           where cert_no = av_cert_no and name = av_customer_name;
           commit;
       end if;
       av_res := cs_res_ok;
   exception when others then
       av_res := cs_res_unknownerr;
       av_msg := '判断密码发生未知错误' || SQLERRM;
       ROLLBACK;
   end p_judgeservicepwd;

   PROCEDURE p_judgepaypwd(av_card_no VARCHAR2, --卡号
                            av_pwd  VARCHAR2, --密码
                            av_res  OUT VARCHAR2, --传出参数代码
                            av_msg  OUT VARCHAR2 --传出参数错误信息
                            ) is
      lv_card_baseinfo card_baseinfo%rowtype;
      lv_sys_para  VARCHAR2(12);
   BEGIN
       SELECT para_value INTO lv_sys_para FROM sys_para WHERE para_code = 'TRADE_PWD_ERR_NUM';
       if av_card_no is  null then
           av_res := cs_res_paravalueerr;
           av_msg := '判断交易密码，卡号不能为空！';
           return;
       end if;
       if av_pwd is  null then
           av_res := cs_res_paravalueerr;
           av_msg := '判断交易密码，上送密码不能为空！';
           return;
       end if;
       begin
           select * into lv_card_baseinfo from card_baseinfo where card_no = av_card_no;
       exception when others then
           av_res := cs_res_cardiderr;
           av_msg := '卡片信息不存在！';
           return;
       end;
       if nvl(lv_card_baseinfo.pay_pwd_err_num,0) > nvl(lv_sys_para,0) then
           av_res := cs_res_pwderrnum;
           av_msg := '交易密码输错次数超限';
           RETURN;
       end if;
       if nvl(lv_card_baseinfo.pay_pwd,'0') = '0' then
           av_res := cs_res_pwderrnum;
           av_msg := '交易密码信息不存在，请先进行交易密码重置！';
           RETURN;
       end if;
       if lv_card_baseinfo.pay_pwd <>  av_pwd then
           av_res := cs_res_pwderr;
           av_msg := '密码错误';
           update card_baseinfo set pay_pwd_err_num = nvl(pay_pwd_err_num,0) + 1
           where card_no = lv_card_baseinfo.card_no;
           commit;
           return;
       else
           update card_baseinfo set pay_pwd_err_num = 0
           where card_no = lv_card_baseinfo.card_no;
           commit;
       end if;
       av_res := cs_res_ok;
   exception when others then
       av_res := cs_res_unknownerr;
       av_msg := '判断密码发生未知错误' || SQLERRM;
       rollback;
   end p_judgepaypwd;
   --判断接入点信息
   PROCEDURE p_judgeacpt(av_acpt_type VARCHAR2,--受理点类型
                        av_acpt_id  VARCHAR2, --受理点编号/网点编号
                        av_user_id  VARCHAR2, --终端号/操作员
                        av_res  out varchar2,--传入代码
                        av_msg  OUT VARCHAR2 --传出参数错误信息
                        ) is
       lv_sys_users sys_users%rowtype;
       lv_base_co_org base_co_org%rowtype;
   begin
       if av_acpt_type is null then
           av_res := pk_public.cs_res_paravalueerr;
           av_msg := '受理点类型不能为空';
           return;
       elsif av_acpt_type = '1' then
           begin
               select * into lv_sys_users from sys_users where USER_ID = av_user_id;
               if lv_sys_users.status <> 'A' then
                  av_res := pk_public.cs_res_user_err;
                  av_msg := '操作员状态不正常';
                  return;
               end if;
               if lv_sys_users.brch_id <> av_acpt_id then
                  av_res := pk_public.cs_res_user_err;
                  av_msg := '受理点编号和操作员信息不一致';
                  return;
               end if;
           exception
               when no_data_found then
                  av_res := pk_public.cs_res_user_err;
                  av_msg := '操作员信息不存在';
                  return;
               when others then
                  av_res := pk_public.cs_res_unknownerr;
                  av_msg := sqlerrm;
                  return;
           end;
       elsif av_acpt_type = '1' then
           begin
              select * into lv_base_co_org from base_co_org where co_org_id = av_acpt_id;
              if lv_base_co_org.co_state <> '0' then
                  av_res := pk_public.cs_res_co_org_novalidateerr;
                  av_msg := sqlerrm;
                  return;
              end if;
           exception
               when no_data_found then
                  av_res := pk_public.cs_res_baseco_nofounderr;
                  av_msg := '受理点信息未登记';
                  return;
               when others then
                  av_res := pk_public.cs_res_unknownerr;
                  av_msg := sqlerrm;
                  return;
           end;
       else
           av_res := pk_public.cs_res_paravalueerr;
           av_msg := '受理点类型不正确';
           return;
       end if;
       av_res := pk_public.cs_res_ok;
       av_msg := '';
   end p_judgeacpt;
  /*=======================================================================================*/
  --判断预存款限额
  /*=======================================================================================*/
  PROCEDURE p_judgebranchagentlimit(av_brchid  VARCHAR2, --网点编号
                                    av_balance NUMBER, --扣除金额后的预存款余额
                                    av_res     OUT VARCHAR2, --传出参数代码
                                    av_msg     OUT VARCHAR2 --传出参数错误信息
                                    ) IS
    lv_limit NUMBER;
  BEGIN
    BEGIN
      SELECT balance
        INTO lv_limit
        FROM sys_branch_agent_limit
       WHERE brch_id = av_brchid
         AND state = '0';
    EXCEPTION
      WHEN no_data_found THEN
        lv_limit := 0;
    END;
    IF av_balance < lv_limit THEN
      --超过限额
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '预存款不足';
      RETURN;
    END IF;
    av_res := cs_res_ok;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '判断预存款限额发生未知错误' || SQLERRM;
      ROLLBACK;
  END p_judgebranchagentlimit;

    /*=======================================================================================*/
  --判断卡状态下该交易是否准许
  /*=======================================================================================*/
  PROCEDURE p_judgecardstatebandeal(av_card_no  VARCHAR2, --卡号
                                    av_deal_code VARCHAR2, --交易代码
                                    av_res     OUT VARCHAR2, --传出参数代码
                                    av_msg     OUT VARCHAR2 --传出参数错误信息
                                    )IS
      lv_count NUMBER;
      lv_card_baseinfo card_baseinfo%ROWTYPE;
  BEGIN
      IF av_card_no IS NULL OR av_deal_code IS NULL THEN
         av_res:=cs_res_paravalueerr;
      END IF;
      --查询卡信息
      SELECT * INTO lv_card_baseinfo FROM card_baseinfo WHERE card_no  = av_card_no;
      IF lv_card_baseinfo.card_no IS NULL THEN
         av_res:=cs_res_cardiderr;
         av_msg:='卡号验证不通过';
      END IF;
      SELECT COUNT(1) INTO lv_count FROM acc_state_trading_ban WHERE BAN_DEAL_CODE = av_deal_code AND card_type = lv_card_baseinfo.card_type;
      IF lv_count >1 THEN
         av_res:=cs_res_card_ban_deal;
         av_msg:='该卡当前状态不准许进行该交易';
      END IF;
  END p_judgecardstatebandeal;

  /*=======================================================================================*/
  --判断某个账户类型和卡号判断次交易是否正确
  /*=======================================================================================*/
  PROCEDURE p_judgecardacciftrade(av_card_no  VARCHAR2, --卡号
                                    av_acc_kind VARCHAR2, --交易代码
                                    av_amt      VARCHAR2,--交易金额
                                    av_pwd_falg  NUMBER,--交易是否输入密码
                                    av_res     OUT VARCHAR2, --传出参数代码
                                    av_msg     OUT VARCHAR2 --传出参数错误信息
                                    ) IS
       lv_count NUMBER(10);
       lv_daycountamt NUMBER(32);
       lv_daycount NUMBER(32);
       lv_ACC_CREDIT_LIMIT ACC_CREDIT_LIMIT%ROWTYPE;
       lv_pay_clr_para  pay_clr_para%ROWTYPE;
       lv_tablename  VARCHAR2(50);
   BEGIN
      av_res:='00000000';
      --1查询系统是否配置此参数，如果没有配置则不验证
      SELECT COUNT(1) INTO lv_count from ACC_CREDIT_LIMIT t WHERE t.card_no = av_card_no AND t.acc_kind = av_acc_kind;
      IF lv_count =0 THEN
         RETURN;
      END IF;
      --2存在参数，a，判断每笔交易限额  b，判断日累计消费限额  c，如果是免密码交易，判断是否超限 d,判断消费笔数
      SELECT * INTO lv_ACC_CREDIT_LIMIT FROM ACC_CREDIT_LIMIT t WHERE t.card_no = av_card_no AND t.acc_kind = av_acc_kind;
      --a
     IF lv_ACC_CREDIT_LIMIT.Amt >0 THEN
        IF av_amt > lv_ACC_CREDIT_LIMIT.AMT THEN
            av_res:=pk_public.cs_res_tramt_acc_oneerr;
            av_msg:='账户单笔交易超过限额';
        END IF;
      END IF;
      --b
      SELECT * INTO lv_pay_clr_para FROM pay_clr_para;
      lv_tablename := 'pay_card_deal_rec_'||substr(lv_pay_clr_para.clr_date,1,4)||substr(lv_pay_clr_para.clr_date,6,2);

      IF lv_ACC_CREDIT_LIMIT.Max_Amt >0 THEN
        EXECUTE IMMEDIATE 'select nvl(abs(sum(amt)),0)  from  ' || lv_tablename ||
                      ' where amt<0 and clr_date = :1'
         into lv_daycountamt
        USING lv_pay_clr_para.clr_date;
        IF lv_daycountamt > lv_ACC_CREDIT_LIMIT.Max_Amt THEN
            av_res:=pk_public.cs_res_tramt_acc_allerr;
            av_msg:='账户日累计交易金额超过限额';
        END IF;
      END IF;
      --d
      IF lv_ACC_CREDIT_LIMIT.Max_Num >0 THEN
        EXECUTE IMMEDIATE 'select count(1)  from  ' || lv_tablename ||
                      ' where amt<0 and clr_date = :1'
         into lv_daycount
        USING lv_pay_clr_para.clr_date;
        IF lv_daycount > lv_ACC_CREDIT_LIMIT.Max_Num THEN
            av_res:=pk_public.cs_res_trmun_acc_allerr;
            av_msg:='账户日累计交易笔数超过限额';
        END IF;
      END IF;
      --c
      IF av_pwd_falg = 1 THEN
         IF lv_ACC_CREDIT_LIMIT.Min_Amt > 0 THEN
            IF av_amt > lv_ACC_CREDIT_LIMIT.Min_Amt THEN
                av_res:=pk_public.cs_res_wallettramt_allerr;
                av_msg:='小额免密码交易超过限额';
            END IF;
         END IF;
      END IF;

   END  p_judgecardacciftrade;


  /*=======================================================================================*/
  --取传入参数
  /*=======================================================================================*/
  PROCEDURE p_getinputpara(av_in        IN VARCHAR2, --传入参数
                           av_minnum    IN NUMBER, --参数最少个数
                           av_maxnum    IN NUMBER, --参数最多个数
                           av_procedure IN VARCHAR2, --调用的函数名
                           av_out       OUT myarray, --转换成参数数组
                           av_res       OUT VARCHAR2, --传出参数代码
                           av_msg       OUT VARCHAR2 --传出参数错误信息
                           ) IS
    lv_count NUMBER;
  BEGIN
    --写传入参数日志
    pk_public.p_insertrzcllog(av_procedure || ':' || av_in, '0');
    --分解传入参数
    lv_count := f_splitstr(av_in, '|', av_out);
    IF lv_count < av_minnum THEN
      av_res := cs_res_paravalueerr;
      av_msg := '传入参数个数不正确' || lv_count;
      RETURN;
    END IF;
    --后面增加的参数不传的话置空
    p_initarray(av_out, lv_count + 1, av_maxnum);
    av_res := cs_res_ok;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '取传入参数发生错误' || SQLERRM;
  END p_getinputpara;
  /*=======================================================================================*/
  --根据传入的sql数组执行sql
  /*=======================================================================================*/
  PROCEDURE p_dealsqlbyarray(av_varlist IN strarray) IS
  BEGIN
    FOR x IN 1 .. av_varlist.count LOOP
      IF (av_varlist(x) IS NOT NULL) THEN
        BEGIN
          EXECUTE IMMEDIATE av_varlist(x);
        EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line(av_varlist(x));
            raise_application_error(-20000,
                                    av_varlist(x) || ':' || SQLERRM);
        END;
      END IF;
    END LOOP;
  END p_dealsqlbyarray;
/*=======================================================================================*/
  --构造第二卡号校验位
  /*=======================================================================================*/

  FUNCTION createSubCardNo(prefix in varchar2,seq in varchar2) return varchar2 as--构造第二卡号校验位
  begin
  declare
    tempNum integer:=0;
    totalNum integer:=0;
    ret integer:=0;
    begin
        if prefix='A' then totalnum := 10*3;
        elsif prefix='B' then totalnum := 11 * 3;
        elsif prefix='C' then totalnum := 12 * 3;
        elsif prefix='D' then totalnum := 13 * 3;
        elsif prefix='E' then totalnum := 14 * 3;
        elsif prefix='F' then totalnum := 15 * 3;
        elsif prefix='G' then totalnum := 16 * 3;
        elsif prefix='H' then totalnum := 17 * 3;
        elsif prefix='I' then totalnum := 18 * 3;
        else totalnum := 10* 3;
        end if;

        for i in 1..7 loop
            if i=1 then tempNum:=7;
            elsif i=2 then tempNum:=9;
            elsif i=3 then tempNum:=10;
            elsif i=4 then tempNum:=5;
            elsif i=5 then tempNum:=8;
            elsif i=6 then tempNum:=4;
            elsif i=7 then tempNum:=2;
            end if;
            totalNum:=totalNum+tempNum*to_number(substr(seq,i,1));
        end loop;
        ret := 11-MOD(totalNum,11);
        if ret=10 then
             return prefix||seq||'X';
        elsif ret=11 then
             return prefix||seq||'0';
        else
            return prefix||seq||ret;
        end if;
    exception
      when others then
        RAISE_APPLICATION_ERROR('zt-95995', sqlerrm);
    end;
  end createSubCardNo;

  /*=======================================================================================*/
  --获取两个时间戳毫秒差
  /*=======================================================================================*/
  FUNCTION f_timestamp_diff(endtime IN TIMESTAMP, starttime IN TIMESTAMP)
    RETURN INTEGER AS
    str      VARCHAR2(50);
    misecond INTEGER;
    seconds  INTEGER;
    minutes  INTEGER;
    hours    INTEGER;
    days     INTEGER;
  BEGIN
    str      := to_char(endtime - starttime);
    misecond := to_number(SUBSTR(str, INSTR(str, ' ') + 10, 3));
    seconds  := to_number(SUBSTR(str, INSTR(str, ' ') + 7, 2));
    minutes  := to_number(SUBSTR(str, INSTR(str, ' ') + 4, 2));
    hours    := to_number(SUBSTR(str, INSTR(str, ' ') + 1, 2));
    days     := to_number(SUBSTR(str, 1, INSTR(str, ' ')));
    RETURN days * 24 * 60 * 60 * 1000 + hours * 60 * 60 * 1000 + minutes * 60 * 1000 + seconds * 1000 + misecond;
  END;
  /*====================================================================================
    根据客户编号获取客户信息
  */
  PROCEDURE p_getBasePersonalByCustomerId(av_customer_id BASE_PERSONAL.CUSTOMER_ID%TYPE,
                                            av_base_personal OUT base_personal%ROWTYPE,
                                            av_res OUT VARCHAR2,
                                            av_msg OUT VARCHAR2) IS

  BEGIN
      IF AV_CUSTOMER_ID IS NULL THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据客户编号获取人员信息，客户编号不能为空';
          RETURN;
      END IF;
      SELECT * INTO AV_BASE_PERSONAL FROM BASE_PERSONAL WHERE CUSTOMER_ID = AV_CUSTOMER_ID;
      av_res := PK_PUBLIC.cs_res_ok;
      av_msg := '';
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据客户编号' || AV_CUSTOMER_ID || '找不到人员信息';
          RETURN;
      WHEN TOO_MANY_ROWS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据客户编号' || AV_CUSTOMER_ID || '找到多个人员信息';
          RETURN;
      WHEN OTHERS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据客户编号' || AV_CUSTOMER_ID || '获取人员信息出现错误' || SQLERRM;
  END p_getBasePersonalByCustomerId;
  /*====================================================================================
    根据证件号码获取客户信息
  */
  PROCEDURE p_getBasePersonalByCertNo(av_cert_no BASE_PERSONAL.CERT_NO%TYPE,
                                        av_base_personal OUT base_personal%ROWTYPE,
                                        av_res OUT VARCHAR2,
                                        av_msg OUT VARCHAR2) IS

  BEGIN
      IF av_cert_no IS NULL THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据证件号码获取人员信息，证件号码不能为空';
          RETURN;
      END IF;
      SELECT * INTO AV_BASE_PERSONAL FROM BASE_PERSONAL WHERE cert_no = av_cert_no;
      av_res := PK_PUBLIC.cs_res_ok;
      av_msg := '';
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据证件号码' || av_cert_no || '找不到人员信息';
          RETURN;
      WHEN TOO_MANY_ROWS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据证件号码' || av_cert_no || '找到多个人员信息';
          RETURN;
      WHEN OTHERS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '根据证件号码' || av_cert_no || '获取人员信息出现错误' || SQLERRM;
  END p_getBasePersonalByCertNo;
BEGIN
  -- Initialization
  cs_cm_card_nums         := f_getsyspara('CM_CARD_NUMS');
  /*cs_trade_pwd_err_num    := f_getsyspara('TRADE_PWD_ERR_NUM');
  cs_serv_pwd_err_num     := f_getsyspara('SERV_PWD_ERR_NUM');
  cs_points_exchange_acc  := f_getsyspara('POINTS_EXCHANGE_ACC');
  cs_points_exchange_rate := f_getsyspara('POINTS_EXCHANGE_RATE');
  cs_points_period_rule   := f_getsyspara('POINTS_PERIOD_RULE');
  cs_points_period        := f_getsyspara('POINTS_PERIOD');*/

END pk_public;
/

