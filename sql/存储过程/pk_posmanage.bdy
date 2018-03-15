CREATE OR REPLACE PACKAGE BODY "PK_POSMANAGE" IS
  /*=======================================================================================*/
  --ҵ������
  /*=======================================================================================*/
  PROCEDURE p_busi_lock(av_marketid IN VARCHAR2, --�г���
                        av_bizid    IN VARCHAR2, --�̻���
                        av_termid   IN VARCHAR2, --�ն˺�
                        av_trcode   IN VARCHAR2 --����Ա���
                        ) is
    PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    insert into sys_busi_lock
      (busi_key, deal_code, org_id, brch_id, oper_id, insert_time)
    values
      (av_marketid ||  av_trcode, --ƴ�ӹؼ���av_bizid ||
       av_trcode,
       null,
       null,
       av_termid,
       sysdate);
    commit;
    null;
  end p_busi_lock;
  /*=======================================================================================*/
  --ҵ�����
  /*=======================================================================================*/
  PROCEDURE p_busi_unlock(av_marketid IN VARCHAR2, --�г���
                          av_bizid    IN VARCHAR2, --�̻���
                          av_termid   IN VARCHAR2, --�ն˺�
                          av_trcode   IN VARCHAR2 --����Ա���
                          ) is
    PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    delete from sys_busi_lock
     where deal_code = av_trcode
       and busi_key = av_marketid ||  av_trcode; --ƴ�ӹؼ���av_bizid ||

    commit;
    null;
  end p_busi_unlock;

  /*=======================================================================================*/
  --��֤�̻��ն�
  /*=======================================================================================*/
  PROCEDURE p_validate_biz_term(av_bizid       IN VARCHAR2, --�̻���
                                av_termid      IN VARCHAR2, --�ն˺�
                                av_dev_no      IN VARCHAR2,-- �豸��
                                av_market_flag in varchar2, --�Ƿ���֤�г���0��1��
                                av_res         OUT VARCHAR2, --������ 00 �ɹ�
                                av_msg         OUT VARCHAR2 --��������������Ϣ
                                /*av_market      out base_market%rowtype --�����г�����*/
                                ) is
    lv_merchant base_merchant%ROWTYPE;
    lv_co_org   base_co_org%ROWTYPE;
    lv_term     base_tag_end%ROWTYPE;
    lv_access_dev_trlimit access_point_trlimit%ROWTYPE;
    lv_dev  VARCHAR2(50);
    cursor tr_cursor is SELECT substr(t.access_point_trcode,1,2) code2  FROM access_point_trlimit t WHERE
        t.access_point_id =av_termid  AND (t.access_point_trcode like'30%' OR t.access_point_trcode LIKE '40%')
        GROUP BY substr(t.access_point_trcode,1,2);
    --lv_market   base_market%rowtype;
  begin
    --��֤�̻� state  0-����/1-����
    --1�������ն˺Ų�ѯ�ն�׼��Ľ���  group by ACCESS_POINT_TRCODE�ֶε�ǰ��λ
    --2������ǳ�ֵ�ն���֤����������Ϣ�治����
    --3������������ն���֤�̻��ն�
    BEGIN
       for c in tr_cursor loop
          IF c.code2='30' THEN
             BEGIN
                SELECT * INTO lv_co_org FROM base_co_org t1 WHERE t1.org_id  = av_bizid  AND t1.co_state = '0';
              EXCEPTION
                WHEN no_data_found THEN
                  av_res := pk_public.cs_res_baseco_nofounderr;
                  av_msg := '����������Ϣ������' || av_bizid;
                  RETURN;
              END;
          ELSE
               BEGIN
                  SELECT * INTO lv_merchant FROM base_merchant WHERE merchant_id = av_bizid AND merchant_state = '0';
                 EXCEPTION
                 WHEN no_data_found THEN
                   av_res := pk_public.cs_res_busierr;
                   av_msg := '�̻��Ų�����' || av_bizid;
                   RETURN;
                END;
          END IF;
        end loop;
        --��֤�ն�  login_flag  ��½��־0ǩ��1ǩ��2����3����  �ն�״̬0-δ����1-����9-ע��
          BEGIN
            SELECT *
              INTO lv_term
              FROM base_tag_end
             WHERE own_id = av_bizid
               AND end_id = av_termid
               AND end_state = '1';
          EXCEPTION
            WHEN no_data_found THEN
              av_res := pk_public.cs_res_termerr;
              av_msg := '�ն˺Ų�����biz_id' || av_bizid || ',term_id' || av_termid;
              RETURN;
          END;
         --��֤�ն˰󶨵��豸���Ƿ���ȷ
         BEGIN
            SELECT dev_no INTO lv_dev FROM base_tag_end d WHERE d.end_id =av_termid;
            IF lv_dev <> av_dev_no THEN
               av_res := pk_public.cs_res_tagdev_validateerr;
               av_msg := '�豸����֤ʧ��' || av_bizid || ',term_id' || av_termid || ',dev_id' || av_dev_no;
            END IF;
         EXCEPTION
            WHEN no_data_found THEN
              av_res := pk_public.cs_res_termerr;
              av_msg := '�ն˺Ų�����biz_id' || av_bizid || ',term_id' || av_termid;
              RETURN;
         END;
      EXCEPTION
        WHEN OTHERS THEN
           av_res := pk_public.cs_res_dberr;
           RETURN;
    END;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    --null;
  end p_validate_biz_term;
  /*=======================================================================================*/
  --ǩ�����������ã���Ҫ�Ƿ��ز����Ƚ�����
  /*=======================================================================================*/
  PROCEDURE p_login_heart(av_bizid    IN VARCHAR2, --�̻���
                          av_termid   IN VARCHAR2, --�ն˺�
                          av_operid   IN VARCHAR2, --����Ա���
                          av_Device_No IN VARCHAR2,--�豸��
                          av_opt_flag varchar2, --1ǩ����2����
                          av_res      OUT VARCHAR2, --������ 00 �ɹ�
                          av_msg      OUT VARCHAR2, --��������������Ϣ
                          av_table    OUT pk_public.t_cur
                          --av_ret    OUT VARCHAR2 --/*1������ˮ��|2����ʱ��|3���κ�|
                          ) IS
    lv_merchant    base_merchant%ROWTYPE;
    lv_actionno    number:=0; --��̨��ˮ��
    lv_hosttime    varchar2(20); --��̨ʱ��yyyymmddhh24miss
    lv_trbatchno   base_tag_end.deal_batch_no%type; --���κ�
    lv_blackver    number; --�������汾��
    lv_softver     varchar2(20) := ''; --����汾��
    lv_adver       varchar2(20) := ''; --���汾��
    lv_clr_para    pay_clr_para%ROWTYPE;
    lv_login_tr_code varchar2(20) :='40301010';
    lv_base_tag_end base_tag_end%ROWTYPE;
    lv_sys_user     sys_users%ROWTYPE;
    --lv_signin_flag varchar2(1); --��ǩ����־
    lv_count       number;
  BEGIN
    --��֤�̻��ն�
    p_validate_biz_term(av_bizid,
                        av_termid,
                        av_Device_No,
                        '0',
                        av_res,
                        av_msg/*,
                        lv_market*/);
    if av_res <> pk_public.cs_res_ok then
        RETURN;
    end if;
    SELECT * INTO lv_base_tag_end FROM base_tag_end a WHERE a.end_id = av_termid;
    IF lv_base_tag_end.user_id IS NULL THEN
        lv_base_tag_end.user_id := 'admin';
    END IF;
    SELECT COUNT(1) INTO lv_count FROM sys_users WHERE user_id=lv_base_tag_end.user_id;
    IF lv_count <= 0 THEN
        lv_base_tag_end.user_id := 'admin';
    END IF;
    SELECT * INTO lv_sys_user FROM sys_users WHERE user_id=lv_base_tag_end.user_id;
    SELECT * INTO lv_clr_para FROM pay_clr_para;
    --�������汾
    /*SELECT nvl(max(version), 0)
      INTO lv_blackver
      FROM cm_card_black_for_market
     WHERE market_reg_no = lv_market.market_reg_no;*/
    select nvl(max(version), 0) INTO lv_blackver from card_black;
    --ϵͳʱ��
    lv_hosttime := to_char(SYSDATE, 'yyyymmddhh24miss');
    --����ҵ��ǩ����Ҫ
    if av_opt_flag = '1' then
      --������ˮ�ţ��ն˲���
      SELECT seq_action_no.nextval INTO lv_actionno FROM dual;
      INSERT INTO sys_action_log(deal_no,
                                 deal_code,
                                 org_id,
                                 brch_id,
                                 user_id,
                                 deal_time,
                                 log_type,
                                 message,
                                 in_out_data,
                                 can_roll,
                                 co_org_id)
                                 VALUES
                                 (lv_actionno,
                                 lv_login_tr_code,
                                 lv_sys_user.org_id,
                                 lv_sys_user.brch_id,
                                 lv_sys_user.user_id,
                                 SYSDATE,
                                 '0',
                                 '�ն�ǩ��',
                                 'av_end_id'||av_termid,
                                 '1',
                                 NULL
                                 );

      --�������ظ�ǩ��
      /*SELECT count(1) INTO lv_count FROM base_tag_end WHERE own_id=av_bizid AND end_id =av_termid AND login_flag = '1';
      IF lv_count > 0 THEN
          av_msg := '��ǩ�������ظ�ǩ��';
          av_res := pk_public.cs_res_relogin;
          RETURN;
      END IF;
      */
      --�ն�ǩ��״̬��0ǩ��1ǩ��2����3����
      UPDATE base_tag_end SET login_flag = '1', user_id = av_operid, login_time = SYSDATE
      WHERE own_id = av_bizid AND end_id = av_termid;

      --����ǩ��ǩ�˱�
      INSERT INTO sys_login_log
        (login_no, oper_term_id, logon_time, user_type, log_type,login_batch_no,login_clr_date)
      VALUES
        (seq_login_no.nextval, av_termid, SYSDATE, '1', '2',lv_trbatchno,lv_clr_para.clr_date);
    else
      --������¼
      update base_tag_end
         set last_time = sysdate
       where own_id = av_bizid
         and end_id = av_termid;
    end if;
    open av_table for
      select lv_actionno    as action_no,
             lv_hosttime    as host_time,
             lv_base_tag_end.deal_batch_no    as tr_batch_no
        from dual t;

    --COMMIT;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      av_msg := SQLERRM;
      av_res := pk_public.cs_res_unknownerr;
      --ROLLBACK;
  END p_login_heart;
  /*=======================================================================================*/
  --ǩ��
  /*=======================================================================================*/
  PROCEDURE p_login(av_bizid  IN VARCHAR2, --�̻���
                    av_termid IN VARCHAR2, --�ն˺�
                    av_operid IN VARCHAR2, --����Ա���
                    av_Device_No IN VARCHAR2,--�豸��
                    av_res    OUT VARCHAR2, --������ 00 �ɹ�
                    av_msg    OUT VARCHAR2, --��������������Ϣ
                    av_table  OUT pk_public.t_cur) IS

  BEGIN
    p_login_heart(av_bizid, --�̻���
                  av_termid, --�ն˺�
                  av_operid, --����Ա���
                  av_Device_No,--�豸��
                  '1', --1ǩ����2����
                  av_res, --������ 00 �ɹ�
                  av_msg, --��������������Ϣ
                  av_table);
  END p_login;
  /*=======================================================================================*/
  --����
  /*=======================================================================================*/
  PROCEDURE p_heart(av_bizid  IN VARCHAR2, --�̻���
                    av_termid IN VARCHAR2, --�ն˺�
                    av_operid IN VARCHAR2, --����Ա���
                    av_Device_No IN VARCHAR2,--�豸��
                    av_res    OUT VARCHAR2, --������ 00 �ɹ�
                    av_msg    OUT VARCHAR2, --��������������Ϣ
                    av_table  OUT pk_public.t_cur) IS

  BEGIN
    p_login_heart(av_bizid, --�̻���
                  av_termid, --�ն˺�
                  av_operid, --����Ա���
                  av_Device_No,--�豸��
                  '2', --1ǩ����2����
                  av_res, --������ 00 �ɹ�
                  av_msg, --��������������Ϣ
                  av_table);
  END p_heart;
  /*=======================================================================================*/
  --ǩ��
  /*=======================================================================================*/
  PROCEDURE p_logout(av_bizid      IN VARCHAR2, --�̻���
                     av_termid     IN VARCHAR2, --�ն˺�
                     av_Device_No IN VARCHAR2,--�豸��
                     --av_trbatchno1 IN VARCHAR2, --���κ�
                     av_res        OUT VARCHAR2, --������ 00 �ɹ�
                     av_msg        OUT VARCHAR2 --��������������Ϣ
                     --av_actionno   OUT VARCHAR2, --pos������ˮ��
                     --av_trbatchno2 OUT VARCHAR2 --���κ�
                     ) IS
    qtzt       VARCHAR2(2);
    pclient_id VARCHAR2(10);
  BEGIN
    --av_trbatchno2 := av_trbatchno1;
    --��֤�̻��ն�
    p_validate_biz_term(av_bizid, av_termid,av_Device_No, '1', av_res, av_msg/*, lv_market*/);
    if av_res <> pk_public.cs_res_ok then
      RETURN;
    end if;
    --������ˮ��
    --SELECT seq_action_no.nextval INTO av_actionno FROM dual;

    --����ǩ��ǩ�˱�
    INSERT INTO sys_login_log
      (login_no, oper_term_id, logoff_time, user_type, log_type)
    VALUES
      (seq_login_no.nextval, av_termid, SYSDATE, '1', '3');

    --�������κ�״̬
    UPDATE base_tag_end
       SET login_flag  = '0',
           deal_batch_no = TRIM(to_char(to_number(nvl(deal_batch_no, '0')) + 1,
                                      '0000000000'))
     WHERE own_id = av_bizid
       AND end_id = av_termid;
    --RETURNING deal_batch_no INTO av_trbatchno2;

    --���¸��ն��Ѷ��ʵ��������ݵ�״̬
    --posp_proc_state: 0δ���ʣ�1����ƽ��2�����ʲ�ƽ��3: ��ǩ�ˡ�����ʱ�����Ѿ�ǩ�˵Ľ����
    /*update tr_consume_temp
      set posp_proc_state = '3'
    where acpt_id = av_bizid
      and term_id = av_termid
      and posp_proc_state <> '0'
      and rec_type = '0';*/

    --COMMIT;
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      av_msg := SQLERRM;
      av_res := pk_public.cs_res_unknownerr;
      --ROLLBACK;
  END p_logout;

  /*=======================================================================================*/
  --���غ�����
  /*=======================================================================================*/
  PROCEDURE p_downblackcard(av_bizid       IN VARCHAR2, --�̻���
                            av_termid      IN VARCHAR2, --�ն˺�
                            av_Device_No   IN VARCHAR2,--�豸��
                            av_regno       in varchar2, --�ն��ϵ��г��ǼǺ�
                            av_count       IN INTEGER, --ÿ�δ��͵ļ�¼��
                            av_next        INTEGER, --��һ����¼�Ŀ�ʼ��,��1��ʼ
                            av_version     INTEGER, --�ն˰汾��
                            av_res         OUT VARCHAR2, --������ 00 �ɹ�
                            av_msg         OUT VARCHAR2, --��������������Ϣ
                            av_followstate OUT INTEGER, --������״̬��1��ʾ�к�������0��ʾû�к�����
                            av_maxversion  OUT INTEGER, --�汾��
                            av_table       OUT pk_public.t_cur) IS
    lv_totalcount INTEGER := 0; --�ܼ�¼��
    lv_merchant   base_merchant%ROWTYPE;
  BEGIN
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;

    av_followstate := 0;
    lv_totalcount  := 0;
    av_maxversion  := 0;

    OPEN av_table FOR
      SELECT card_id, blk_state FROM card_black_for_dept WHERE 1 = 2;
    --��֤�̻��ն�
    p_validate_biz_term(av_bizid,av_termid,av_Device_No,'1',av_res,av_msg);
    if av_res <> pk_public.cs_res_ok then
      RETURN;
    end if;

    --����������;�����Ŵ�С��������ֻ����״̬Ϊ��blk_state='0' ��Ч��־Ϊ0��
    OPEN av_table FOR
      SELECT card_id, blk_state
        FROM (SELECT rownum AS tt, card_id, blk_state
                FROM (SELECT card_id, blk_state
                        FROM card_black
                       WHERE version > av_version
                         /*AND market_reg_no = lv_market.market_reg_no*/
                         AND ((av_version = 0 AND blk_state = 0) OR
                             (av_version > 0))
                       ORDER BY card_id)
               ORDER BY card_id)
       WHERE tt >= av_next
         AND tt <= av_next + av_count;

    select count(1)
      into lv_totalcount
      FROM card_black
     WHERE version > av_version
       /*AND market_reg_no = lv_market.market_reg_no*/
       AND ((av_version = 0 AND blk_state = 0) OR (av_version > 0));

    --���һ���� select para_name, para_value from sys_para where para_name='hmdbb';
    IF av_next + av_count >= lv_totalcount THEN
      SELECT MAX(version)
        INTO av_maxversion
        FROM card_black
       /*WHERE market_reg_no = lv_merchant.market_id*/;
      av_followstate := 0;
    ELSE
      av_followstate := 1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      av_msg := SQLERRM;
      av_res := pk_public.cs_res_unknownerr;
  END p_downblackcard;

  /*=======================================================================================*/
  --���ز�������Ҫ������ǰ�г��ǼǺţ��Լ�ftp�Ȳ���
  /*=======================================================================================*/
  PROCEDURE p_downparam(av_bizid  IN VARCHAR2, --�̻��ţ��ӿ��е��̻����ǿ�Ϊ�գ�Ϊ�Σ���
                        av_termid IN VARCHAR2, --�ն˺�
                        av_Device_No IN VARCHAR2, --�豸��
                        av_res    OUT VARCHAR2, --������ 00 �ɹ�
                        av_msg    OUT VARCHAR2, --��������������Ϣ
                        av_table  OUT pk_public.t_cur) is
    lv_totalcount INTEGER := 0; --�ܼ�¼��
    lv_merchant   base_merchant%ROWTYPE;
    lv_term       base_tag_end%ROWTYPE;
  BEGIN
    --��֤�̻��ն�
    p_validate_biz_term(av_bizid,
                        av_termid,
                        av_Device_No,
                        '0',
                        av_res,
                        av_msg/*,
                        lv_market*/);
    if av_res <> pk_public.cs_res_ok then
      RETURN;
    end if;

    /* av_ret := lv_term.term_id || '|' || lv_term.own_id || '|' ||
    lv_market.market_id || '|' || lv_market.market_reg_no;*/
    open av_table for
      select lv_term.end_id as term_id,
             lv_term.own_id as biz_id,
             max(ftp_ip) as ftp_ip,
             max(ftp_port) as ftp_port,
             max(ftp_user) as ftp_user,
             max(ftp_pwd) as ftp_pwd,
             max(ftp_dir) as ftp_dir
        from (select t.ftp_use,
                     decode(t.ftp_para_name, 'IP', t.ftp_para_value, null) ftp_ip,
                     decode(t.ftp_para_name, 'PORT', t.ftp_para_value, null) ftp_port,
                     decode(t.ftp_para_name,
                            'USER_NAME',
                            t.ftp_para_value,
                            null) ftp_user,
                     decode(t.ftp_para_name, 'PWD', t.ftp_para_value, null) ftp_pwd,
                     decode(t.ftp_para_name,
                            'UPLOAD',
                            t.ftp_para_value,
                            null) ftp_dir
                from sys_ftp_conf t
               where ftp_use = 'TERM_OFFLINE_TRADE') t
       group by t.ftp_use;
    /* max(ftp_ip) || '|' || max(ftp_port) || '|' ||
          max(ftp_user) || '|' || max(ftp_pwd) || '|' || max(ftp_dir)
     into av_ret
     from (select t.ftp_use,
                  decode(t.ftp_para_name, 'IP', t.ftp_para_value, null) ftp_ip,
                  decode(t.ftp_para_name, 'PORT', t.ftp_para_value, null) ftp_port,
                  decode(t.ftp_para_name,
                         'USER_NAME',
                         t.ftp_para_value,
                         null) ftp_user,
                  decode(t.ftp_para_name, 'PWD', t.ftp_para_value, null) ftp_pwd,
                  decode(t.ftp_para_name, 'UPLOAD', t.ftp_para_value, null) ftp_dir
             from sys_ftp_conf t
            where ftp_use = 'TERM_OFFLINE_TRADE') t
    group by t.ftp_use;*/

    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
  EXCEPTION
    WHEN OTHERS THEN
      av_msg := SQLERRM;
      av_res := pk_public.cs_res_unknownerr;
  END p_downparam;


  /*=======================================================================================*/
  --�̻����ײ�ѯ
  /*=======================================================================================*/
  PROCEDURE p_merchant_trans(av_bizid       IN VARCHAR2, --�̻���
                             av_termid      IN VARCHAR2, --�ն˺�
                             av_clrdate     in varchar2, --��������yyyymmdd
                             av_acckind     in varchar2, --�˻����ͣ�01Ǯ����02����
                             av_count       IN INTEGER, --ÿ�δ��͵ļ�¼��
                             av_next        INTEGER, --��һ����¼�Ŀ�ʼ��,��1��ʼ
                             av_res         OUT VARCHAR2, --������ 00 �ɹ�
                             av_msg         OUT VARCHAR2, --��������������Ϣ
                             av_followstate OUT INTEGER, --������״̬��1��ʾ�к�������0��ʾû�к�����
                             av_totalcount OUT INTEGER, --�ܼ�¼��
                             av_table       OUT pk_public.t_cur) IS
   -- lv_totalcount INTEGER := 0; --�ܼ�¼��
    lv_merchant   base_merchant%ROWTYPE;
    lv_acckind    acc_inout_detail.db_acc_kind%type;
    lv_sql_head   varchar2(4000); --sqlͷ
    lv_sql_from   varchar2(4000); --sql����
    lr_cursor     pk_public.t_cur; --�α�
  BEGIN
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;
    av_followstate := 0;
    av_totalcount  := 0;
    /* lv_acckind     := av_acckind;
    if lv_acckind is null then
      lv_acckind := pk_public.cs_acckind_zj;
      null;
    end if;*/

    lv_sql_from := ' FROM acc_inout_detail' || '_' || substr(av_clrdate,0,6) ||
                   ' WHERE ACPT_ID = :1
         and (:2 is null or db_acc_kind = :3)
         and deal_state not in (''1'', ''2'', ''9'')';
    lv_sql_head := 'select deal_no,
             deal_batch_no,
             end_deal_no,
             db_card_no,
             db_acc_kind as acc_kind,
             user_id as term_id,
             decode(db_acc_kind,
                   ' || pk_public.cs_acckind_qb || ',
                    db_card_bal,
                    db_acc_bal) prv_bal,
             abs(db_amt) amt,
             (decode(db_acc_kind,
                     ' || pk_public.cs_acckind_qb || ',
                     db_card_bal,
                     db_acc_bal) + db_amt) aft_bal,
             to_char(deal_date, ''yyyymmdd'') tr_date,
             to_char(deal_date, ''hh24miss'') tr_time,
             deal_code';
             /*(case
               when deal_code in (810001, 810101) then
                ''1'' --����
               when deal_code in (811001, 811101) then
                ''3'' --�˻�
             end) tr_type*/

    open lr_cursor for 'select count (1) ' || lv_sql_from
      using av_bizid, av_acckind, av_acckind;
    LOOP
      FETCH lr_cursor
        INTO av_totalcount;
      EXIT WHEN lr_cursor%NOTFOUND;
    END LOOP;
    CLOSE lr_cursor;

    OPEN av_table FOR 'SELECT * from (SELECT rownum AS tt, b.* from(' || lv_sql_head || lv_sql_from || ' order by tr_time) b)where tt>=:4 and tt<=:5'
      using av_bizid, av_acckind, av_acckind, av_next, av_next+av_count;

    --���һ���� select para_name, para_value from sys_para where para_name='hmdbb';
    IF av_next + av_count >= av_totalcount THEN
      av_followstate := 0;
    ELSE
      av_followstate := 1;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      av_msg := SQLERRM;
      av_res := pk_public.cs_res_unknownerr;
  END p_merchant_trans;

  /*=======================================================================================*/
  --�����ϴ��ļ���
  /*=======================================================================================*/
  PROCEDURE p_saveFileName(av_filename VARCHAR2,
                           av_filetype varchar2, --�ļ����ͣ�����չ,XF����,ZK�ۿ�,QDǩ��
                           av_bizid    VARCHAR2) IS
  BEGIN
    INSERT INTO pay_offline_filename
      (send_file_name, file_type, send_date, merchant_id, state)
    VALUES
      (av_filename, av_filetype, SYSDATE, av_bizid, '0');
  END p_saveFileName;

--�ϴ�����������
--���س��а�����

  /*=======================================================================================*/
  --�������
  --av_in
  --     1pbiz_id                      �̻���
  --     2pterm_id                     �ն˺�
  --     3pch                          ���κ�
  --     4pconsumenormolnum            �������ѱ���
  --     5pconsumenormolamt            �������ѽ��
  --     6pconsumecancelnum            �������ѱ���
  --     7pconsumecancelamt            �������ѽ��
  --     8pconsumereturnnum            �����˻�����
  --     9pconsumereturnamt            �����˻����
  /*=======================================================================================*/
  procedure pos_BalanceAccount(
                          av_in      IN VARCHAR2,
                          av_res         OUT VARCHAR2, --������ 00 �ɹ�
                          av_msg         OUT VARCHAR2, --��������������Ϣ
                          av_check_flag  OUT VARCHAR2, --0����ƽ 1 ���˲�ƽ
                          rAction_No out varchar2,         --POS������ˮ��
                          rconsumeCount out integer,       --��������(�����ѻ�������) �����ܱ���
                          rconsumeFee out float,           --��������(�����ѻ�������)  �����ܽ��
                          rconsumereturncount OUT INTEGER,  --�˻� �����ܱ���
                          rconsumereturnamt   OUT INTEGER,  --�˻� �����ܽ��
                          rcancelCount out integer,        --��������
                          rcancelFee out float             --�������
                       )IS
    lv_in            pk_public.myarray; --�����������
    lv_sys_login_log    sys_login_log%ROWTYPE;
    lv_table_name       VARCHAR2(200);
    lv_start_date       DATE;
    lv_end_date         DATE;
    lv_pay_clr_para     pay_clr_para%ROWTYPE;
    d                   INTEGER;
    av_counsumenum_temp INTEGER :=0;
    av_counsumeamt_temp INTEGER :=0;
    av_returnnum_temp   INTEGER :=0;
    av_returnamt_temp   INTEGER :=0;
    av_undonum_temp     INTEGER :=0;
    av_undoamt_temp     INTEGER :=0;
  BEGIN
     --�ֽ⴫�����
     av_res:=pk_public.cs_res_dberr;
     pk_public.p_getinputpara(av_in, --�������
                       9, --�������ٸ���
                       9, --����������
                       'pk_recharge.p_recharge', --���õĺ�����
                       lv_in, --ת���ɲ�������
                       av_res, --������������
                       av_msg --��������������Ϣ
                       );
     IF av_res <> pk_public.cs_res_ok THEN
     RETURN;
     END IF;
    --�������κŴ�sys_login_log�л�ȡ��Ҫ���˵��������ĸ������
    BEGIN
         SELECT * INTO lv_sys_login_log FROM sys_login_log a WHERE a.term_id =lv_in(2) AND a.login_batch_no=lv_in(3);
         EXCEPTION
           WHEN no_data_found THEN
              av_res := pk_public.cs_res_baseco_nofounderr;
              av_msg := '��ѯ�����̻�ǩ����Ϣ' || lv_in(2);
              RETURN;
    END;
    SELECT * INTO lv_pay_clr_para FROM pay_clr_para;
    lv_start_date :=to_date(lv_pay_clr_para.clr_date,'yyyy-mm-dd');
    lv_end_date   :=to_Date(lv_sys_login_log.login_clr_date,'yyyy-mm-dd');

    SELECT months_between(lv_end_Date,lv_start_Date) INTO  d  FROM dual;
    --ѭ��ͳ�Ʊ����ͽ�� ������ˮ״̬0-���� 1-���� 2-����3�˻�9-�Ҽ�¼
    FOR c IN 0..d  LOOP
       lv_table_name :='pay_card_deal_rec_'||to_char(ADD_MONTHS(lv_start_Date,c),'yyyymm');
       --ͳ�����������ͽ��
        EXECUTE IMMEDIATE
                'select count(*),sum(cr_amt) into av_counsumenum_temp,av_counsumeamt_temp from '||lv_table_name ||
                ' where DEAL_STATE = ''0'' and ACPT_ID = :1 and USER_ID = :2 and DEAL_BATCH_NO= :3  '
          USING  lv_in(1),lv_in(2),lv_in(3);
          rconsumeCount := rconsumeCount+ abs(av_counsumenum_temp);
          rconsumeFee := rconsumeFee+ abs(av_counsumeamt_temp);
       --ͳ�Ƴ��������ͽ��
        EXECUTE IMMEDIATE
                'select count(*),sum(cr_amt) into av_undonum_temp,av_undoamt_temp from '||lv_table_name ||
                ' where DEAL_STATE = ''0'' and amt<0 and ACPT_ID = :1 and USER_ID = :2 and DEAL_BATCH_NO= :3  '
          USING  lv_in(1),lv_in(2),lv_in(3);
          rcancelCount := rcancelCount+ abs(av_undonum_temp);
          rcancelFee := rcancelFee+ abs(av_undoamt_temp);
       --ͳ���˻������ͽ��
       EXECUTE IMMEDIATE
                'select count(*),sum(cr_amt) into av_returnnum_temp,av_returnamt_temp from '||lv_table_name ||
                ' where DEAL_STATE = ''3'' and ACPT_ID = :1 and USER_ID = :2 and DEAL_BATCH_NO= :3  '
          USING  lv_in(1),lv_in(2),lv_in(3);
          rconsumereturncount := rconsumereturncount+ abs(av_returnnum_temp);
          rconsumereturnamt := rconsumereturnamt+ abs(av_returnamt_temp);
    END LOOP;
    --�ж϶��˽��
    av_check_flag :='1';
    IF lv_in(4) = rconsumeCount AND  lv_in(5) = rconsumeFee AND lv_in(6)=rconsumereturncount AND lv_in(7) <>rcancelCount
       AND lv_in(8) = rcancelFee AND lv_in(9)=rconsumereturncount AND rconsumereturnamt=lv_in(10) THEN
       av_check_flag := '0';
       FOR c IN 0..d  LOOP
           lv_table_name :='pay_card_deal_rec_'||to_char(ADD_MONTHS(lv_start_Date,c),'yyyymm');
            EXECUTE IMMEDIATE
                'update  '||lv_table_name ||
                ' set POSP_PROC_STATE = ''0'' where  ACPT_ID = :1 and USER_ID = :2 and DEAL_BATCH_NO= :3  '
          USING  lv_in(1),lv_in(2),lv_in(3);
       END LOOP;
    END IF;
      exception
          when others then
            rollback;
          RAISE_APPLICATION_ERROR('-20001',sqlerrm);

  END pos_BalanceAccount;

BEGIN
  -- initialization
  NULL;
END pk_posmanage;
/

