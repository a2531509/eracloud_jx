CREATE OR REPLACE PACKAGE BODY "PK_POSMANAGE" IS
  /*=======================================================================================*/
  --业务锁定
  /*=======================================================================================*/
  PROCEDURE p_busi_lock(av_marketid IN VARCHAR2, --市场号
                        av_bizid    IN VARCHAR2, --商户号
                        av_termid   IN VARCHAR2, --终端号
                        av_trcode   IN VARCHAR2 --操作员编号
                        ) is
    PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    insert into sys_busi_lock
      (busi_key, deal_code, org_id, brch_id, oper_id, insert_time)
    values
      (av_marketid ||  av_trcode, --拼接关键字av_bizid ||
       av_trcode,
       null,
       null,
       av_termid,
       sysdate);
    commit;
    null;
  end p_busi_lock;
  /*=======================================================================================*/
  --业务解锁
  /*=======================================================================================*/
  PROCEDURE p_busi_unlock(av_marketid IN VARCHAR2, --市场号
                          av_bizid    IN VARCHAR2, --商户号
                          av_termid   IN VARCHAR2, --终端号
                          av_trcode   IN VARCHAR2 --操作员编号
                          ) is
    PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    delete from sys_busi_lock
     where deal_code = av_trcode
       and busi_key = av_marketid ||  av_trcode; --拼接关键字av_bizid ||

    commit;
    null;
  end p_busi_unlock;

  /*=======================================================================================*/
  --验证商户终端
  /*=======================================================================================*/
  PROCEDURE p_validate_biz_term(av_bizid       IN VARCHAR2, --商户号
                                av_termid      IN VARCHAR2, --终端号
                                av_dev_no      IN VARCHAR2,-- 设备号
                                av_market_flag in varchar2, --是否验证市场，0是1否
                                av_res         OUT VARCHAR2, --返回码 00 成功
                                av_msg         OUT VARCHAR2 --传出参数错误信息
                                /*av_market      out base_market%rowtype --返回市场对象*/
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
    --验证商户 state  0-正常/1-消户
    --1，更具终端号查询终端准许的交易  group by ACCESS_POINT_TRCODE字段的前两位
    --2，如果是充值终端验证合作机构信息存不存在
    --3，如果是消费终端验证商户终端
    BEGIN
       for c in tr_cursor loop
          IF c.code2='30' THEN
             BEGIN
                SELECT * INTO lv_co_org FROM base_co_org t1 WHERE t1.org_id  = av_bizid  AND t1.co_state = '0';
              EXCEPTION
                WHEN no_data_found THEN
                  av_res := pk_public.cs_res_baseco_nofounderr;
                  av_msg := '合作机构信息不存在' || av_bizid;
                  RETURN;
              END;
          ELSE
               BEGIN
                  SELECT * INTO lv_merchant FROM base_merchant WHERE merchant_id = av_bizid AND merchant_state = '0';
                 EXCEPTION
                 WHEN no_data_found THEN
                   av_res := pk_public.cs_res_busierr;
                   av_msg := '商户号不存在' || av_bizid;
                   RETURN;
                END;
          END IF;
        end loop;
        --验证终端  login_flag  登陆标志0签退1签到2上送3对账  终端状态0-未启用1-启用9-注销
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
              av_msg := '终端号不存在biz_id' || av_bizid || ',term_id' || av_termid;
              RETURN;
          END;
         --验证终端绑定的设备号是否正确
         BEGIN
            SELECT dev_no INTO lv_dev FROM base_tag_end d WHERE d.end_id =av_termid;
            IF lv_dev <> av_dev_no THEN
               av_res := pk_public.cs_res_tagdev_validateerr;
               av_msg := '设备号验证失败' || av_bizid || ',term_id' || av_termid || ',dev_id' || av_dev_no;
            END IF;
         EXCEPTION
            WHEN no_data_found THEN
              av_res := pk_public.cs_res_termerr;
              av_msg := '终端号不存在biz_id' || av_bizid || ',term_id' || av_termid;
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
  --签到、心跳共用，主要是返回参数比较相似
  /*=======================================================================================*/
  PROCEDURE p_login_heart(av_bizid    IN VARCHAR2, --商户号
                          av_termid   IN VARCHAR2, --终端号
                          av_operid   IN VARCHAR2, --操作员编号
                          av_Device_No IN VARCHAR2,--设备号
                          av_opt_flag varchar2, --1签到，2心跳
                          av_res      OUT VARCHAR2, --返回码 00 成功
                          av_msg      OUT VARCHAR2, --传出参数错误信息
                          av_table    OUT pk_public.t_cur
                          --av_ret    OUT VARCHAR2 --/*1中心流水号|2主机时间|3批次号|
                          ) IS
    lv_merchant    base_merchant%ROWTYPE;
    lv_actionno    number:=0; --后台流水号
    lv_hosttime    varchar2(20); --后台时间yyyymmddhh24miss
    lv_trbatchno   base_tag_end.deal_batch_no%type; --批次号
    lv_blackver    number; --黑名单版本号
    lv_softver     varchar2(20) := ''; --软件版本号
    lv_adver       varchar2(20) := ''; --广告版本号
    lv_clr_para    pay_clr_para%ROWTYPE;
    lv_login_tr_code varchar2(20) :='40301010';
    lv_base_tag_end base_tag_end%ROWTYPE;
    lv_sys_user     sys_users%ROWTYPE;
    --lv_signin_flag varchar2(1); --可签到标志
    lv_count       number;
  BEGIN
    --验证商户终端
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
    --黑名单版本
    /*SELECT nvl(max(version), 0)
      INTO lv_blackver
      FROM cm_card_black_for_market
     WHERE market_reg_no = lv_market.market_reg_no;*/
    select nvl(max(version), 0) INTO lv_blackver from card_black;
    --系统时间
    lv_hosttime := to_char(SYSDATE, 'yyyymmddhh24miss');
    --以下业务签到需要
    if av_opt_flag = '1' then
      --中心流水号，终端不用
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
                                 '终端签到',
                                 'av_end_id'||av_termid,
                                 '1',
                                 NULL
                                 );

      --不可以重复签到
      /*SELECT count(1) INTO lv_count FROM base_tag_end WHERE own_id=av_bizid AND end_id =av_termid AND login_flag = '1';
      IF lv_count > 0 THEN
          av_msg := '已签到不可重复签到';
          av_res := pk_public.cs_res_relogin;
          RETURN;
      END IF;
      */
      --终端签到状态：0签退1签到2上送3对账
      UPDATE base_tag_end SET login_flag = '1', user_id = av_operid, login_time = SYSDATE
      WHERE own_id = av_bizid AND end_id = av_termid;

      --插入签到签退表
      INSERT INTO sys_login_log
        (login_no, oper_term_id, logon_time, user_type, log_type,login_batch_no,login_clr_date)
      VALUES
        (seq_login_no.nextval, av_termid, SYSDATE, '1', '2',lv_trbatchno,lv_clr_para.clr_date);
    else
      --心跳记录
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
  --签到
  /*=======================================================================================*/
  PROCEDURE p_login(av_bizid  IN VARCHAR2, --商户号
                    av_termid IN VARCHAR2, --终端号
                    av_operid IN VARCHAR2, --操作员编号
                    av_Device_No IN VARCHAR2,--设备号
                    av_res    OUT VARCHAR2, --返回码 00 成功
                    av_msg    OUT VARCHAR2, --传出参数错误信息
                    av_table  OUT pk_public.t_cur) IS

  BEGIN
    p_login_heart(av_bizid, --商户号
                  av_termid, --终端号
                  av_operid, --操作员编号
                  av_Device_No,--设备号
                  '1', --1签到，2心跳
                  av_res, --返回码 00 成功
                  av_msg, --传出参数错误信息
                  av_table);
  END p_login;
  /*=======================================================================================*/
  --心跳
  /*=======================================================================================*/
  PROCEDURE p_heart(av_bizid  IN VARCHAR2, --商户号
                    av_termid IN VARCHAR2, --终端号
                    av_operid IN VARCHAR2, --操作员编号
                    av_Device_No IN VARCHAR2,--设备号
                    av_res    OUT VARCHAR2, --返回码 00 成功
                    av_msg    OUT VARCHAR2, --传出参数错误信息
                    av_table  OUT pk_public.t_cur) IS

  BEGIN
    p_login_heart(av_bizid, --商户号
                  av_termid, --终端号
                  av_operid, --操作员编号
                  av_Device_No,--设备号
                  '2', --1签到，2心跳
                  av_res, --返回码 00 成功
                  av_msg, --传出参数错误信息
                  av_table);
  END p_heart;
  /*=======================================================================================*/
  --签退
  /*=======================================================================================*/
  PROCEDURE p_logout(av_bizid      IN VARCHAR2, --商户号
                     av_termid     IN VARCHAR2, --终端号
                     av_Device_No IN VARCHAR2,--设备号
                     --av_trbatchno1 IN VARCHAR2, --批次号
                     av_res        OUT VARCHAR2, --返回码 00 成功
                     av_msg        OUT VARCHAR2 --传出参数错误信息
                     --av_actionno   OUT VARCHAR2, --pos中心流水号
                     --av_trbatchno2 OUT VARCHAR2 --批次号
                     ) IS
    qtzt       VARCHAR2(2);
    pclient_id VARCHAR2(10);
  BEGIN
    --av_trbatchno2 := av_trbatchno1;
    --验证商户终端
    p_validate_biz_term(av_bizid, av_termid,av_Device_No, '1', av_res, av_msg/*, lv_market*/);
    if av_res <> pk_public.cs_res_ok then
      RETURN;
    end if;
    --中心流水号
    --SELECT seq_action_no.nextval INTO av_actionno FROM dual;

    --插入签到签退表
    INSERT INTO sys_login_log
      (login_no, oper_term_id, logoff_time, user_type, log_type)
    VALUES
      (seq_login_no.nextval, av_termid, SYSDATE, '1', '3');

    --更新批次和状态
    UPDATE base_tag_end
       SET login_flag  = '0',
           deal_batch_no = TRIM(to_char(to_number(nvl(deal_batch_no, '0')) + 1,
                                      '0000000000'))
     WHERE own_id = av_bizid
       AND end_id = av_termid;
    --RETURNING deal_batch_no INTO av_trbatchno2;

    --更新该终端已对帐的消费数据的状态
    --posp_proc_state: 0未对帐；1对帐平；2：对帐不平；3: 已签退。结算时：将已经签退的结算掉
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
  --下载黑名单
  /*=======================================================================================*/
  PROCEDURE p_downblackcard(av_bizid       IN VARCHAR2, --商户号
                            av_termid      IN VARCHAR2, --终端号
                            av_Device_No   IN VARCHAR2,--设备号
                            av_regno       in varchar2, --终端上的市场登记号
                            av_count       IN INTEGER, --每次传送的记录数
                            av_next        INTEGER, --下一条记录的开始号,从1开始
                            av_version     INTEGER, --终端版本号
                            av_res         OUT VARCHAR2, --返回码 00 成功
                            av_msg         OUT VARCHAR2, --传出参数错误信息
                            av_followstate OUT INTEGER, --后续包状态：1表示有后续包，0表示没有后续包
                            av_maxversion  OUT INTEGER, --版本号
                            av_table       OUT pk_public.t_cur) IS
    lv_totalcount INTEGER := 0; --总记录数
    lv_merchant   base_merchant%ROWTYPE;
  BEGIN
    av_res := pk_public.cs_res_ok;
    av_msg := NULL;

    av_followstate := 0;
    lv_totalcount  := 0;
    av_maxversion  := 0;

    OPEN av_table FOR
      SELECT card_id, blk_state FROM card_black_for_dept WHERE 1 = 2;
    --验证商户终端
    p_validate_biz_term(av_bizid,av_termid,av_Device_No,'1',av_res,av_msg);
    if av_res <> pk_public.cs_res_ok then
      RETURN;
    end if;

    --黑名单卡号;按卡号从小到大排序，只下载状态为：blk_state='0' 有效标志为0的
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

    --最后一个包 select para_name, para_value from sys_para where para_name='hmdbb';
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
  --下载参数，主要包括当前市场登记号，以及ftp等参数
  /*=======================================================================================*/
  PROCEDURE p_downparam(av_bizid  IN VARCHAR2, --商户号，接口中的商户号是可为空，为何？？
                        av_termid IN VARCHAR2, --终端号
                        av_Device_No IN VARCHAR2, --设备号
                        av_res    OUT VARCHAR2, --返回码 00 成功
                        av_msg    OUT VARCHAR2, --传出参数错误信息
                        av_table  OUT pk_public.t_cur) is
    lv_totalcount INTEGER := 0; --总记录数
    lv_merchant   base_merchant%ROWTYPE;
    lv_term       base_tag_end%ROWTYPE;
  BEGIN
    --验证商户终端
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
  --商户交易查询
  /*=======================================================================================*/
  PROCEDURE p_merchant_trans(av_bizid       IN VARCHAR2, --商户号
                             av_termid      IN VARCHAR2, --终端号
                             av_clrdate     in varchar2, --清算日期yyyymmdd
                             av_acckind     in varchar2, --账户类型，01钱包，02联机
                             av_count       IN INTEGER, --每次传送的记录数
                             av_next        INTEGER, --下一条记录的开始号,从1开始
                             av_res         OUT VARCHAR2, --返回码 00 成功
                             av_msg         OUT VARCHAR2, --传出参数错误信息
                             av_followstate OUT INTEGER, --后续包状态：1表示有后续包，0表示没有后续包
                             av_totalcount OUT INTEGER, --总记录数
                             av_table       OUT pk_public.t_cur) IS
   -- lv_totalcount INTEGER := 0; --总记录数
    lv_merchant   base_merchant%ROWTYPE;
    lv_acckind    acc_inout_detail.db_acc_kind%type;
    lv_sql_head   varchar2(4000); --sql头
    lv_sql_from   varchar2(4000); --sql条件
    lr_cursor     pk_public.t_cur; --游标
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
                ''1'' --消费
               when deal_code in (811001, 811101) then
                ''3'' --退货
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

    --最后一个包 select para_name, para_value from sys_para where para_name='hmdbb';
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
  --保存上传文件名
  /*=======================================================================================*/
  PROCEDURE p_saveFileName(av_filename VARCHAR2,
                           av_filetype varchar2, --文件类型，可扩展,XF消费,ZK折扣,QD签到
                           av_bizid    VARCHAR2) IS
  BEGIN
    INSERT INTO pay_offline_filename
      (send_file_name, file_type, send_date, merchant_id, state)
    VALUES
      (av_filename, av_filetype, SYSDATE, av_bizid, '0');
  END p_saveFileName;

--上传锁卡黑名单
--下载城市白名单

  /*=======================================================================================*/
  --结算对账
  --av_in
  --     1pbiz_id                      商户号
  --     2pterm_id                     终端号
  --     3pch                          批次号
  --     4pconsumenormolnum            正常消费笔数
  --     5pconsumenormolamt            正常消费金额
  --     6pconsumecancelnum            撤销消费笔数
  --     7pconsumecancelamt            撤销消费金额
  --     8pconsumereturnnum            消费退货笔数
  --     9pconsumereturnamt            消费退货金额
  /*=======================================================================================*/
  procedure pos_BalanceAccount(
                          av_in      IN VARCHAR2,
                          av_res         OUT VARCHAR2, --返回码 00 成功
                          av_msg         OUT VARCHAR2, --传出参数错误信息
                          av_check_flag  OUT VARCHAR2, --0对账平 1 对账不平
                          rAction_No out varchar2,         --POS中心流水号
                          rconsumeCount out integer,       --正常消费(包括脱机和联机) 交易总笔数
                          rconsumeFee out float,           --正常消费(包括脱机和联机)  交易总金额
                          rconsumereturncount OUT INTEGER,  --退货 交易总笔数
                          rconsumereturnamt   OUT INTEGER,  --退货 交易总金额
                          rcancelCount out integer,        --撤销笔数
                          rcancelFee out float             --撤销金额
                       )IS
    lv_in            pk_public.myarray; --传入参数数组
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
     --分解传入参数
     av_res:=pk_public.cs_res_dberr;
     pk_public.p_getinputpara(av_in, --传入参数
                       9, --参数最少个数
                       9, --参数最多个数
                       'pk_recharge.p_recharge', --调用的函数名
                       lv_in, --转换成参数数组
                       av_res, --传出参数代码
                       av_msg --传出参数错误信息
                       );
     IF av_res <> pk_public.cs_res_ok THEN
     RETURN;
     END IF;
    --根据批次号从sys_login_log中获取需要对账的批次在哪个表格当中
    BEGIN
         SELECT * INTO lv_sys_login_log FROM sys_login_log a WHERE a.term_id =lv_in(2) AND a.login_batch_no=lv_in(3);
         EXCEPTION
           WHEN no_data_found THEN
              av_res := pk_public.cs_res_baseco_nofounderr;
              av_msg := '查询不到商户签到信息' || lv_in(2);
              RETURN;
    END;
    SELECT * INTO lv_pay_clr_para FROM pay_clr_para;
    lv_start_date :=to_date(lv_pay_clr_para.clr_date,'yyyy-mm-dd');
    lv_end_date   :=to_Date(lv_sys_login_log.login_clr_date,'yyyy-mm-dd');

    SELECT months_between(lv_end_Date,lv_start_Date) INTO  d  FROM dual;
    --循环统计笔数和金额 交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
    FOR c IN 0..d  LOOP
       lv_table_name :='pay_card_deal_rec_'||to_char(ADD_MONTHS(lv_start_Date,c),'yyyymm');
       --统计正常笔数和金额
        EXECUTE IMMEDIATE
                'select count(*),sum(cr_amt) into av_counsumenum_temp,av_counsumeamt_temp from '||lv_table_name ||
                ' where DEAL_STATE = ''0'' and ACPT_ID = :1 and USER_ID = :2 and DEAL_BATCH_NO= :3  '
          USING  lv_in(1),lv_in(2),lv_in(3);
          rconsumeCount := rconsumeCount+ abs(av_counsumenum_temp);
          rconsumeFee := rconsumeFee+ abs(av_counsumeamt_temp);
       --统计撤销笔数和金额
        EXECUTE IMMEDIATE
                'select count(*),sum(cr_amt) into av_undonum_temp,av_undoamt_temp from '||lv_table_name ||
                ' where DEAL_STATE = ''0'' and amt<0 and ACPT_ID = :1 and USER_ID = :2 and DEAL_BATCH_NO= :3  '
          USING  lv_in(1),lv_in(2),lv_in(3);
          rcancelCount := rcancelCount+ abs(av_undonum_temp);
          rcancelFee := rcancelFee+ abs(av_undoamt_temp);
       --统计退货笔数和金额
       EXECUTE IMMEDIATE
                'select count(*),sum(cr_amt) into av_returnnum_temp,av_returnamt_temp from '||lv_table_name ||
                ' where DEAL_STATE = ''3'' and ACPT_ID = :1 and USER_ID = :2 and DEAL_BATCH_NO= :3  '
          USING  lv_in(1),lv_in(2),lv_in(3);
          rconsumereturncount := rconsumereturncount+ abs(av_returnnum_temp);
          rconsumereturnamt := rconsumereturnamt+ abs(av_returnamt_temp);
    END LOOP;
    --判断对账结果
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

