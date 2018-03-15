CREATE OR REPLACE PACKAGE BODY pk_public IS
  /*=======================================================================================*/
  --�ֽ��ַ���
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
    lspartstr := length(av_partstr); --��ѭ�����ȼ���av_partstr����
    LOOP
      -- ���� loop ѭ��
      EXIT WHEN sinmsg IS NULL;
      ipos := instr(sinmsg, av_partstr, 1, 1);
      IF ipos = 0 THEN
        av_out(i) := sinmsg;
        i := i + 1;
        EXIT; -- �˳�ѭ��
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
  --������av_start��av_end���ÿ�
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
  --��ѯϵͳ����
  /*=======================================================================================*/
  FUNCTION f_getsyspara(av_paraname IN sys_para.para_code%TYPE --��������
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
  --���ŷֱ�ȡģ
  /*=======================================================================================*/
  FUNCTION f_cardmode(av_cardno VARCHAR2) RETURN VARCHAR2 DETERMINISTIC IS
  BEGIN
    --����4λУ����ǰ��2λ
    RETURN TRIM(to_char(MOD(substrb(av_cardno, lengthb(av_cardno) - 5, 2),
                            cs_cm_card_nums),
                        '00'));
  END f_cardmode;
  /*=======================================================================================*/
  --���ݿ��ŷ��ؿ�Ƭ���ڱ���
  /*=======================================================================================*/
  FUNCTION f_getcardtablebycard_no(av_cardno VARCHAR2) RETURN VARCHAR2
    DETERMINISTIC IS
    lv_mode VARCHAR2(2);
  BEGIN
    lv_mode := f_cardmode(av_cardno);
    RETURN 'cm_card_' || lv_mode;
  END f_getcardtablebycard_no;
  /*=======================================================================================*/
  --���ݿ��ŷ����˻����ڱ���
  /*=======================================================================================*/
  FUNCTION f_getsubledgertablebycard_no(av_cardno VARCHAR2) RETURN VARCHAR2
    DETERMINISTIC IS
    lv_mode VARCHAR2(2);
  BEGIN
    lv_mode := f_cardmode(av_cardno);
    RETURN 'acc_account_sub' || lv_mode;
  END f_getsubledgertablebycard_no;
  /*=======================================================================================*/
  --���ݿ��ŷ��ػ��ֹ��ɱ����ڱ���
  /*=======================================================================================*/
  FUNCTION f_getpointsperiodbycard_no(av_cardno VARCHAR2) RETURN VARCHAR2
    DETERMINISTIC IS
    lv_mode VARCHAR2(2);
  BEGIN
    lv_mode := f_cardmode(av_cardno);
    RETURN 'points_book_' || lv_mode;
  END f_getpointsperiodbycard_no;
  /*=======================================================================================*/
  --���ݿ��š��������ڷ��ؿ�Ƭ���׼�¼�����ڱ���
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
  --�ǵ�����־
  /*=======================================================================================*/
  PROCEDURE p_insertrzcllog(av_remark   acc_rzcllog.remark%TYPE,
                            av_actionno NUMBER) IS
    --PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    p_insertrzcllog_('0', av_remark, av_actionno);
  END p_insertrzcllog;
  /*=======================================================================================*/
  --�ǵ�����־
  /*=======================================================================================*/
  PROCEDURE p_insertrzcllog_(av_log_flag CHAR, --�Ƿ����־���أ�0��1��
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
  --���ݻ�����ȡ�����admin��Ա���
  /*=======================================================================================*/
  FUNCTION f_getorgoperid(av_orgid VARCHAR2 --�������
                          ) RETURN VARCHAR2 DETERMINISTIC IS
  BEGIN
    RETURN 'admin' /*'admin_' || av_orgid*/
    ;
  END f_getorgoperid;
  /*=======================================================================================*/
  --���ݻ�����ȡ�����admin��Ա��Ϣ
  /*=======================================================================================*/
  PROCEDURE p_getorgoperator(av_orgid    VARCHAR2, --�������
                             av_operator OUT sys_USERS%ROWTYPE, --��Ա
                             av_res      OUT VARCHAR2, --������������
                             av_msg      OUT VARCHAR2 --��������������Ϣ
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
      av_msg := '������' || av_orgid || 'δ����Ӧ��Ա';
  END p_getorgoperator;
  /*=======================================================================================*/
  --���ݿ����Ͳ�ѯ��Ŀ��--��ֵ����ֵʱ�õ�
  /*=======================================================================================*/
  FUNCTION f_getitemnobycardtype(av_cardtype VARCHAR2 --������
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
  --���ݿ�Ŀ�źͻ����Ų��һ������˻�
  /*=======================================================================================*/
  PROCEDURE p_getorgsubledger(av_orgid     VARCHAR2, --������
                              av_itemno    VARCHAR2, --��Ŀ��
                              av_subledger OUT acc_account_sub%ROWTYPE, --�ֻ���
                              av_res       OUT VARCHAR2, --������������
                              av_msg       OUT VARCHAR2 --��������������Ϣ
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
          av_msg := '���ݿ�Ŀ��' || av_itemno || '�ͻ�����' || av_orgid || '�Ҳ����ֻ���';
      END;
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '���ݿ�Ŀ��' || av_itemno || '�ͻ���' || av_orgid || '��ѯ���˺ŷ�������' ||
                SQLERRM;
  END p_getorgsubledger;
  /*=======================================================================================*/
  --���ݿ�Ŀ�ź�����Ų��ҷ��˻�
  /*=======================================================================================*/
  PROCEDURE p_getsubledgerbyclientid(av_clientid  VARCHAR2, --�ͻ���/�����
                                     av_itemno    VARCHAR2, --��Ŀ��
                                     av_subledger OUT acc_account_sub%ROWTYPE, --�ֻ���
                                     av_res       OUT VARCHAR2, --������������
                                     av_msg       OUT VARCHAR2 --��������������Ϣ
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
      av_msg := '���ݿ�Ŀ��' || av_itemno || '�������' || av_clientid || '�Ҳ����ֻ���';
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '���ݿ�Ŀ�źͿͻ���\����Ų�ѯ���˺ŷ�������' || SQLERRM;
  END p_getsubledgerbyclientid;
  /*=======================================================================================*/
  --���ݿ��ź��˻����Ͳ��ҷ��˻�-----
  /*=======================================================================================*/
  PROCEDURE p_getsubledgerbycardno(av_cardno    VARCHAR2, --����
                                   av_acckind   VARCHAR2, --�˻�����
                                   av_walletid  IN acc_account_sub.wallet_no%TYPE, --Ǯ�����
                                   av_subledger OUT acc_account_sub%ROWTYPE, --�ֻ���
                                   av_res       OUT VARCHAR2, --������������
                                   av_msg       OUT VARCHAR2 --��������������Ϣ
                                   ) IS
    lv_tablename    VARCHAR2(50);
    lv_isparent     VARCHAR2(1); --0����1����
    lv_parentcardno VARCHAR2(50); --��������
  BEGIN
    --����������
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
    --��ֻ���
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
      av_msg := '���ݿ���' || av_cardno || '���˻�����' || av_acckind || '��Ǯ�����' ||
                av_walletid || '�Ҳ����ֻ���';
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '���ݿ���' || av_cardno || '���˻�����' || av_acckind || '��Ǯ�����' ||
                av_walletid || '��ѯ���˺ŷ�������' || SQLERRM;
  END p_getsubledgerbycardno;
  /*=======================================================================================*/
  --���ݿ��ź��˻����Ͳ����˻����    ????�޸ĵ���
  /*=======================================================================================*/
  FUNCTION f_getcardbalance(av_cardno   VARCHAR2, --����
                            av_acckind  VARCHAR2, --�˻�����
                            av_walletid VARCHAR2 --Ǯ�����
                            ) RETURN NUMBER IS
    lv_subledger acc_account_sub%ROWTYPE;
    lv_res       VARCHAR2(8);
    lv_msg       VARCHAR2(1024);
  BEGIN
    p_getsubledgerbycardno(av_cardno, --����
                           av_acckind, --�˻�����
                           av_walletid, --Ǯ�����
                           lv_subledger, --�ֻ���
                           lv_res, --������������
                           lv_msg --��������������Ϣ
                           );
    IF lv_res <> cs_res_ok THEN
      raise_application_error(-20000, lv_msg);
    ELSE
      RETURN lv_subledger.bal;
    END IF;
  END f_getcardbalance;
  /*=======================================================================================*/
  --���ݿ��Ų��ҿ�Ƭ������Ϣ
  /*=======================================================================================*/
  PROCEDURE p_getcardbycardno(av_cardno VARCHAR2, --����
                              av_card   OUT card_baseinfo%ROWTYPE, --��Ƭ������Ϣ
                              av_res    OUT VARCHAR2, --������������
                              av_msg    OUT VARCHAR2 --��������������Ϣ
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
      av_msg := '���ݿ���' || av_cardno || '�Ҳ�����Ƭ������Ϣ';
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '���ݿ��Ų�ѯ��Ƭ������Ϣ��������' || SQLERRM;
  END p_getcardbycardno;
  /*=======================================================================================*/
  --���ݿ��Ų��ҿ�����
  /*=======================================================================================*/
  FUNCTION f_getcardtypebycardno(av_cardno VARCHAR2 --����
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
  --�����˺źͿ��Ų����˻�����
  /*=======================================================================================*/
  FUNCTION f_getacckindbyaccnoandcardno(av_accno  acc_account_sub.acc_no%TYPE, --�˺�
                                        av_cardno VARCHAR2 --����
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
  --���ݿ����Ͳ鿨������
  /*=======================================================================================*/
  PROCEDURE p_getcardparabycardtype(av_cardtype VARCHAR2, --������
                                    av_para     OUT card_config%ROWTYPE, --��������
                                    av_res      OUT VARCHAR2, --������������
                                    av_msg      OUT VARCHAR2 --��������������Ϣ
                                    ) IS
  BEGIN
    SELECT * INTO av_para FROM card_config WHERE card_type = av_cardtype;
    av_res := cs_res_ok;
  EXCEPTION
    WHEN no_data_found THEN
      av_res := cs_res_dberr;
      av_msg := 'û�п�����' || av_cardtype || '�Ŀ�����';
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '���ݿ����Ͳ鿨������������' || SQLERRM;
  END p_getcardparabycardtype;
  /*=======================================================================================*/
  --�жϿ���������
  /*=======================================================================================*/
  PROCEDURE p_judgetradepwd(av_card card_baseinfo%ROWTYPE, --����Ϣ
                            av_pwd  VARCHAR2, --����
                            av_res  OUT VARCHAR2, --������������
                            av_msg  OUT VARCHAR2 --��������������Ϣ
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
      av_msg := '������������������';
      RETURN;
    ELSIF av_card.pay_pwd <> av_pwd THEN
      av_res := cs_res_pwderr;
      av_msg := '�������';

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
      av_msg := '�ж����뷢��δ֪����' || SQLERRM;
      ROLLBACK;
  END p_judgetradepwd;

  PROCEDURE p_judgeservicepwd(av_cert_no VARCHAR2, --֤������
                            av_customer_name VARCHAR2,--����
                            av_pwd  VARCHAR2, --����
                            av_res  OUT VARCHAR2, --������������
                            av_msg  OUT VARCHAR2 --��������������Ϣ
                            )is
      lv_base_personal base_personal%rowtype;
   begin
       if av_cert_no is null then
           av_res := cs_res_paravalueerr;
           av_msg := '֤�����벻��Ϊ�գ�';
           return;
       end if;
       if av_customer_name is null then
           av_res := cs_res_paravalueerr;
           av_msg := '�ͻ���������Ϊ�գ�';
           return;
       end if;
       if av_pwd is null then
           av_res := cs_res_paravalueerr;
           av_msg := '�������벻��Ϊ�գ�';
           return;
       end if;
       begin
           select * into lv_base_personal from base_personal where cert_no = av_cert_no and name = av_customer_name;
       exception when others then
           av_res := cs_res_cardis_err;
           av_msg := 'δ�ҵ���Ч�ͻ���Ϣ���޷��жϷ������룡';
           return;
       end;
       if nvl(lv_base_personal.serv_pwd_err_num,0) >= cs_serv_pwd_err_num then
           av_res := cs_res_cardis_err;
           av_msg := '�����������������ޣ�';
           return;
       end if;
       if nvl(lv_base_personal.serv_pwd,'0') = '0' then
           av_res := cs_res_pwderr;
           av_msg := '�ͻ�����������Ϣ�����ڣ����Ƚ����������ã�';
           return;
       end if;
       if av_pwd <> lv_base_personal.serv_pwd then
           av_res := cs_res_pwderr;
           av_msg := '�������벻��ȷ��';
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
       av_msg := '�ж����뷢��δ֪����' || SQLERRM;
       ROLLBACK;
   end p_judgeservicepwd;

   PROCEDURE p_judgepaypwd(av_card_no VARCHAR2, --����
                            av_pwd  VARCHAR2, --����
                            av_res  OUT VARCHAR2, --������������
                            av_msg  OUT VARCHAR2 --��������������Ϣ
                            ) is
      lv_card_baseinfo card_baseinfo%rowtype;
      lv_sys_para  VARCHAR2(12);
   BEGIN
       SELECT para_value INTO lv_sys_para FROM sys_para WHERE para_code = 'TRADE_PWD_ERR_NUM';
       if av_card_no is  null then
           av_res := cs_res_paravalueerr;
           av_msg := '�жϽ������룬���Ų���Ϊ�գ�';
           return;
       end if;
       if av_pwd is  null then
           av_res := cs_res_paravalueerr;
           av_msg := '�жϽ������룬�������벻��Ϊ�գ�';
           return;
       end if;
       begin
           select * into lv_card_baseinfo from card_baseinfo where card_no = av_card_no;
       exception when others then
           av_res := cs_res_cardiderr;
           av_msg := '��Ƭ��Ϣ�����ڣ�';
           return;
       end;
       if nvl(lv_card_baseinfo.pay_pwd_err_num,0) > nvl(lv_sys_para,0) then
           av_res := cs_res_pwderrnum;
           av_msg := '������������������';
           RETURN;
       end if;
       if nvl(lv_card_baseinfo.pay_pwd,'0') = '0' then
           av_res := cs_res_pwderrnum;
           av_msg := '����������Ϣ�����ڣ����Ƚ��н����������ã�';
           RETURN;
       end if;
       if lv_card_baseinfo.pay_pwd <>  av_pwd then
           av_res := cs_res_pwderr;
           av_msg := '�������';
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
       av_msg := '�ж����뷢��δ֪����' || SQLERRM;
       rollback;
   end p_judgepaypwd;
   --�жϽ������Ϣ
   PROCEDURE p_judgeacpt(av_acpt_type VARCHAR2,--���������
                        av_acpt_id  VARCHAR2, --�������/������
                        av_user_id  VARCHAR2, --�ն˺�/����Ա
                        av_res  out varchar2,--�������
                        av_msg  OUT VARCHAR2 --��������������Ϣ
                        ) is
       lv_sys_users sys_users%rowtype;
       lv_base_co_org base_co_org%rowtype;
   begin
       if av_acpt_type is null then
           av_res := pk_public.cs_res_paravalueerr;
           av_msg := '��������Ͳ���Ϊ��';
           return;
       elsif av_acpt_type = '1' then
           begin
               select * into lv_sys_users from sys_users where USER_ID = av_user_id;
               if lv_sys_users.status <> 'A' then
                  av_res := pk_public.cs_res_user_err;
                  av_msg := '����Ա״̬������';
                  return;
               end if;
               if lv_sys_users.brch_id <> av_acpt_id then
                  av_res := pk_public.cs_res_user_err;
                  av_msg := '������źͲ���Ա��Ϣ��һ��';
                  return;
               end if;
           exception
               when no_data_found then
                  av_res := pk_public.cs_res_user_err;
                  av_msg := '����Ա��Ϣ������';
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
                  av_msg := '�������Ϣδ�Ǽ�';
                  return;
               when others then
                  av_res := pk_public.cs_res_unknownerr;
                  av_msg := sqlerrm;
                  return;
           end;
       else
           av_res := pk_public.cs_res_paravalueerr;
           av_msg := '��������Ͳ���ȷ';
           return;
       end if;
       av_res := pk_public.cs_res_ok;
       av_msg := '';
   end p_judgeacpt;
  /*=======================================================================================*/
  --�ж�Ԥ����޶�
  /*=======================================================================================*/
  PROCEDURE p_judgebranchagentlimit(av_brchid  VARCHAR2, --������
                                    av_balance NUMBER, --�۳������Ԥ������
                                    av_res     OUT VARCHAR2, --������������
                                    av_msg     OUT VARCHAR2 --��������������Ϣ
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
      --�����޶�
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := 'Ԥ����';
      RETURN;
    END IF;
    av_res := cs_res_ok;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := '�ж�Ԥ����޶��δ֪����' || SQLERRM;
      ROLLBACK;
  END p_judgebranchagentlimit;

    /*=======================================================================================*/
  --�жϿ�״̬�¸ý����Ƿ�׼��
  /*=======================================================================================*/
  PROCEDURE p_judgecardstatebandeal(av_card_no  VARCHAR2, --����
                                    av_deal_code VARCHAR2, --���״���
                                    av_res     OUT VARCHAR2, --������������
                                    av_msg     OUT VARCHAR2 --��������������Ϣ
                                    )IS
      lv_count NUMBER;
      lv_card_baseinfo card_baseinfo%ROWTYPE;
  BEGIN
      IF av_card_no IS NULL OR av_deal_code IS NULL THEN
         av_res:=cs_res_paravalueerr;
      END IF;
      --��ѯ����Ϣ
      SELECT * INTO lv_card_baseinfo FROM card_baseinfo WHERE card_no  = av_card_no;
      IF lv_card_baseinfo.card_no IS NULL THEN
         av_res:=cs_res_cardiderr;
         av_msg:='������֤��ͨ��';
      END IF;
      SELECT COUNT(1) INTO lv_count FROM acc_state_trading_ban WHERE BAN_DEAL_CODE = av_deal_code AND card_type = lv_card_baseinfo.card_type;
      IF lv_count >1 THEN
         av_res:=cs_res_card_ban_deal;
         av_msg:='�ÿ���ǰ״̬��׼����иý���';
      END IF;
  END p_judgecardstatebandeal;

  /*=======================================================================================*/
  --�ж�ĳ���˻����ͺͿ����жϴν����Ƿ���ȷ
  /*=======================================================================================*/
  PROCEDURE p_judgecardacciftrade(av_card_no  VARCHAR2, --����
                                    av_acc_kind VARCHAR2, --���״���
                                    av_amt      VARCHAR2,--���׽��
                                    av_pwd_falg  NUMBER,--�����Ƿ���������
                                    av_res     OUT VARCHAR2, --������������
                                    av_msg     OUT VARCHAR2 --��������������Ϣ
                                    ) IS
       lv_count NUMBER(10);
       lv_daycountamt NUMBER(32);
       lv_daycount NUMBER(32);
       lv_ACC_CREDIT_LIMIT ACC_CREDIT_LIMIT%ROWTYPE;
       lv_pay_clr_para  pay_clr_para%ROWTYPE;
       lv_tablename  VARCHAR2(50);
   BEGIN
      av_res:='00000000';
      --1��ѯϵͳ�Ƿ����ô˲��������û����������֤
      SELECT COUNT(1) INTO lv_count from ACC_CREDIT_LIMIT t WHERE t.card_no = av_card_no AND t.acc_kind = av_acc_kind;
      IF lv_count =0 THEN
         RETURN;
      END IF;
      --2���ڲ�����a���ж�ÿ�ʽ����޶�  b���ж����ۼ������޶�  c������������뽻�ף��ж��Ƿ��� d,�ж����ѱ���
      SELECT * INTO lv_ACC_CREDIT_LIMIT FROM ACC_CREDIT_LIMIT t WHERE t.card_no = av_card_no AND t.acc_kind = av_acc_kind;
      --a
     IF lv_ACC_CREDIT_LIMIT.Amt >0 THEN
        IF av_amt > lv_ACC_CREDIT_LIMIT.AMT THEN
            av_res:=pk_public.cs_res_tramt_acc_oneerr;
            av_msg:='�˻����ʽ��׳����޶�';
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
            av_msg:='�˻����ۼƽ��׽����޶�';
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
            av_msg:='�˻����ۼƽ��ױ��������޶�';
        END IF;
      END IF;
      --c
      IF av_pwd_falg = 1 THEN
         IF lv_ACC_CREDIT_LIMIT.Min_Amt > 0 THEN
            IF av_amt > lv_ACC_CREDIT_LIMIT.Min_Amt THEN
                av_res:=pk_public.cs_res_wallettramt_allerr;
                av_msg:='С�������뽻�׳����޶�';
            END IF;
         END IF;
      END IF;

   END  p_judgecardacciftrade;


  /*=======================================================================================*/
  --ȡ�������
  /*=======================================================================================*/
  PROCEDURE p_getinputpara(av_in        IN VARCHAR2, --�������
                           av_minnum    IN NUMBER, --�������ٸ���
                           av_maxnum    IN NUMBER, --����������
                           av_procedure IN VARCHAR2, --���õĺ�����
                           av_out       OUT myarray, --ת���ɲ�������
                           av_res       OUT VARCHAR2, --������������
                           av_msg       OUT VARCHAR2 --��������������Ϣ
                           ) IS
    lv_count NUMBER;
  BEGIN
    --д���������־
    pk_public.p_insertrzcllog(av_procedure || ':' || av_in, '0');
    --�ֽ⴫�����
    lv_count := f_splitstr(av_in, '|', av_out);
    IF lv_count < av_minnum THEN
      av_res := cs_res_paravalueerr;
      av_msg := '���������������ȷ' || lv_count;
      RETURN;
    END IF;
    --�������ӵĲ��������Ļ��ÿ�
    p_initarray(av_out, lv_count + 1, av_maxnum);
    av_res := cs_res_ok;
  EXCEPTION
    WHEN OTHERS THEN
      av_res := cs_res_unknownerr;
      av_msg := 'ȡ���������������' || SQLERRM;
  END p_getinputpara;
  /*=======================================================================================*/
  --���ݴ����sql����ִ��sql
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
  --����ڶ�����У��λ
  /*=======================================================================================*/

  FUNCTION createSubCardNo(prefix in varchar2,seq in varchar2) return varchar2 as--����ڶ�����У��λ
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
  --��ȡ����ʱ��������
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
    ���ݿͻ���Ż�ȡ�ͻ���Ϣ
  */
  PROCEDURE p_getBasePersonalByCustomerId(av_customer_id BASE_PERSONAL.CUSTOMER_ID%TYPE,
                                            av_base_personal OUT base_personal%ROWTYPE,
                                            av_res OUT VARCHAR2,
                                            av_msg OUT VARCHAR2) IS

  BEGIN
      IF AV_CUSTOMER_ID IS NULL THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '���ݿͻ���Ż�ȡ��Ա��Ϣ���ͻ���Ų���Ϊ��';
          RETURN;
      END IF;
      SELECT * INTO AV_BASE_PERSONAL FROM BASE_PERSONAL WHERE CUSTOMER_ID = AV_CUSTOMER_ID;
      av_res := PK_PUBLIC.cs_res_ok;
      av_msg := '';
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '���ݿͻ����' || AV_CUSTOMER_ID || '�Ҳ�����Ա��Ϣ';
          RETURN;
      WHEN TOO_MANY_ROWS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '���ݿͻ����' || AV_CUSTOMER_ID || '�ҵ������Ա��Ϣ';
          RETURN;
      WHEN OTHERS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '���ݿͻ����' || AV_CUSTOMER_ID || '��ȡ��Ա��Ϣ���ִ���' || SQLERRM;
  END p_getBasePersonalByCustomerId;
  /*====================================================================================
    ����֤�������ȡ�ͻ���Ϣ
  */
  PROCEDURE p_getBasePersonalByCertNo(av_cert_no BASE_PERSONAL.CERT_NO%TYPE,
                                        av_base_personal OUT base_personal%ROWTYPE,
                                        av_res OUT VARCHAR2,
                                        av_msg OUT VARCHAR2) IS

  BEGIN
      IF av_cert_no IS NULL THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '����֤�������ȡ��Ա��Ϣ��֤�����벻��Ϊ��';
          RETURN;
      END IF;
      SELECT * INTO AV_BASE_PERSONAL FROM BASE_PERSONAL WHERE cert_no = av_cert_no;
      av_res := PK_PUBLIC.cs_res_ok;
      av_msg := '';
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '����֤������' || av_cert_no || '�Ҳ�����Ա��Ϣ';
          RETURN;
      WHEN TOO_MANY_ROWS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '����֤������' || av_cert_no || '�ҵ������Ա��Ϣ';
          RETURN;
      WHEN OTHERS THEN
          AV_RES := PK_PUBLIC.CS_RES_UNKNOWNERR;
          AV_MSG := '����֤������' || av_cert_no || '��ȡ��Ա��Ϣ���ִ���' || SQLERRM;
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

