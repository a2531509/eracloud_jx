CREATE OR REPLACE PACKAGE BODY pk_transfer IS
  /*=======================================================================================*/
  --转账
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acpt_id        受理点编号(网点号或商户编号)
  --       6tr_batch_no    批次号
  --       7term_tr_no     终端交易流水号
  --       8card_no1       转出卡号
  --       9card_tr_count1 转出卡交易计数器
  --      10card_bal1     转出卡钱包交易前金额
  --      11acc_kind1     转出卡账户类型
  --      12wallet_id1    转出卡钱包编号 默认00
  --      13card_no2      转入卡号
  --      14card_tr_count2转入卡交易计数器
  --      15card_bal2     转入卡钱包交易前金额
  --      16acc_kind2     转入卡账户类型
  --      17wallet_id2    转入卡钱包编号 默认00
  --      18tr_amt        转账金额  null时转出所有金额
  --      19pwd           转账密码
  --      20note          备注
  --      21encrypt1      转出卡转账后金额密文
  --      22encrypt2      转入卡转账后金额密文
  --      23tr_state      9写灰记录0直接写正常记录
  --      24acpt_type     受理点分类
  --      25acc_bal1      转出卡账户交易前金额
  --      26acc_bal2      转入卡账户交易前金额
  /*=======================================================================================*/
  PROCEDURE p_transfer(av_in    IN VARCHAR2, --传入参数
                       av_debug IN VARCHAR2, --1调试
                       av_res   OUT VARCHAR2, --传出代码
                       av_msg   OUT VARCHAR2 --传出错误信息
                       ) IS
    --lv_count       number;
    lv_in          pk_public.myarray; --传入参数数组
    lv_dbsubledger acc_account_sub%ROWTYPE; --借方分户账
    lv_crsubledger acc_account_sub%ROWTYPE; --贷方分户账
    lv_operator    sys_users%ROWTYPE; --操作员
    lv_clrdate     pay_clr_para.clr_date%TYPE; --清分日期
    lv_accbookno   acc_inout_detail.acc_inout_no%TYPE; --记账流水号
    lv_card        card_baseinfo%ROWTYPE; --卡基本信息
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             23, --参数最少个数
                             26, --参数最多个数
                             'pk_transfer.p_transfer', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;

    --默认写灰记录
    IF lv_in(23) IS NULL THEN
      lv_in(23) := '9';
    ELSIF lv_in(23) NOT IN ('9', '0') THEN
      av_res := pk_public.cs_res_paravalueerr;
      av_msg := 'tr_state只能9或0';
      RETURN;
    END IF;
    --钱包编号默认00
    lv_in(12) := nvl(lv_in(12), pk_public.cs_defaultwalletid);
    lv_in(17) := nvl(lv_in(17), pk_public.cs_defaultwalletid);
    BEGIN
      SELECT * INTO lv_operator FROM sys_users WHERE user_id = lv_in(3);
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
    END IF;
    --取卡基本信息和卡参数表
    pk_public.p_getcardbycardno(lv_dbsubledger.card_no, --卡号
                                lv_card, --卡片基本信息
                                av_res, --传出参数代码
                                av_msg --传出参数错误信息
                                );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    ELSE
      --判断密码
      pk_public.p_judgetradepwd(lv_card, --卡信息
                                lv_in(19), --密码
                                av_res, --传出参数代码
                                av_msg --传出参数错误信息
                                );
      IF av_res <> pk_public.cs_res_ok THEN
        RETURN;
      END IF;
    END IF;
    IF lv_in(18) IS NULL THEN
      --转账金额传入null时转出所有金额
      lv_in(18) := lv_dbsubledger.bal;
    END IF;
    --取贷方分户账
    pk_public.p_getsubledgerbycardno(lv_in(13), --卡号
                                     lv_in(16), --账户类型
                                     lv_in(17), --钱包编号
                                     lv_crsubledger, --分户账
                                     av_res, --传出参数代码
                                     av_msg --传出参数错误信息
                                     );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    IF lv_dbsubledger.acc_kind IN ('02') AND
       lv_dbsubledger.bal <> nvl(lv_in(25), 0) THEN
      --联机账户需要判断是不是同时更新账户
      av_res := pk_public.cs_res_dberr;
      av_msg := '转出卡账户交易前金额不正确';
      RETURN;
    END IF;
    IF lv_crsubledger.acc_kind IN ('02') AND
       lv_crsubledger.bal <> nvl(lv_in(26), 0) THEN
      --联机账户需要判断是不是同时更新账户
      av_res := pk_public.cs_res_dberr;
      av_msg := '转入卡账户交易前金额不正确';
      RETURN;
    END IF;
    --判断是否允许转账
    IF lv_dbsubledger.bal - lv_dbsubledger.credit_lmt < lv_in(18) THEN
      av_res := pk_public.cs_res_accinsufbalance;
      av_msg := '账户余额不足';
      RETURN;
    END IF;
    IF lv_in(24)='2' THEN
       lv_operator.org_id := lv_in(5);
    END IF;
    --写流水
    SELECT seq_acc_book_no.nextval INTO lv_accbookno FROM dual;
    pk_business.p_account(lv_dbsubledger, --借方账户
                          lv_crsubledger, --贷方账户
                          lv_in(10), --借方卡面交易前金额
                          lv_in(15), --贷方卡面交易前金额
                          lv_in(9), --借方卡片交易计数器
                          lv_in(14), --贷方卡片交易计数器
                          lv_in(21), --借方金额密文
                          lv_in(22), --贷方金额密文
                          lv_in(18), --交易金额
                          0, --信用发生额
                          lv_accbookno, --记账流水号
                          lv_in(2), --交易代码
                          lv_crsubledger.org_id, --发卡机构
                          lv_operator.org_id, --受理机构
                          lv_in(24),--受理点分类
                          lv_in(5), --受理点编码(网点号/商户号等)
                          lv_in(3), --操作柜员/终端号
                          lv_in(6), --交易批次号
                          lv_in(7), --终端交易流水号
                          to_date(lv_in(4), 'yyyy-mm-dd hh24:mi:ss'), --交易时间
                          lv_in(23), --交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
                          lv_in(1), --业务流水号
                          lv_in(20), --备注
                          lv_clrdate, --清分日期
                          null,--其它传入参数 退货时传入原acc_book_no
                          av_debug, --1调试
                          av_res, --传出参数代码
                          av_msg --传出参数错误信息
                          );
  END p_transfer;

  /*=======================================================================================*/
  --转账确认
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no|6clr_date|7转出卡确认前卡账户金额明文|8转入卡确认前卡账户金额明文|9转出卡转账后金额密文|10转入卡转账后金额密文
  /*=======================================================================================*/
  PROCEDURE p_transferconfirm_onerow(av_in    IN VARCHAR2, --传入参数
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
                             'pk_transfer.p_transferconfirm_onerow', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    --灰记录确认
    pk_business.p_ashconfirmbyaccbookno(lv_in(6), --清分日期
                                        lv_in(5), --acc_book_no
                                        lv_in(9), --借方金额密文
                                        lv_in(10), --贷方金额密文
                                        lv_in(7), --借方交易前金额
                                        lv_in(8), --贷方交易前金额
                                        av_debug, --1写调试日志
                                        av_res, --传出代码
                                        av_msg --传出错误信息
                                        );
  END p_transferconfirm_onerow;
  /*=======================================================================================*/
  --转账确认
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no|6clr_date|7card_no1|8card_no2|9转出卡转账后金额密文|10转入卡转账后金额密文
  /*=======================================================================================*/
  PROCEDURE p_transferconfirm(av_in    IN VARCHAR2, --传入参数
                              av_debug IN VARCHAR2, --1写调试日志
                              av_res   OUT VARCHAR2, --传出代码
                              av_msg   OUT VARCHAR2 --传出错误信息
                              ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --传入参数数组
    lv_clrdate pay_clr_para.clr_date%TYPE; --清分日期
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             8, --参数最少个数
                             10, --参数最多个数
                             'pk_transfer.p_transferconfirm', --调用的函数名
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
                             lv_in(9), --借方金额密文
                             lv_in(10), --贷方金额密文
                             av_debug, --1写调试日志
                             av_res, --传出代码
                             av_msg --传出错误信息
                             );
  END p_transferconfirm;

  /*=======================================================================================*/
  --转账撤销
  --    如果原记录是灰记录，把记录改成充正状态，
  --                正常记录：新增一条负的灰记录，原记录改成撤销状态写撤销时间
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5acc_book_no        账户流水号
  --       6clr_date          写灰记录时的清分日期
  --       7acc_bal1         转出卡撤销前账户余额
  --       8acc_bal2         转入卡撤销前账户余额
  --       9card_tr_count1   转出卡卡交易计数器
  --      10card_tr_count2   转入卡卡交易计数器
  --      11card_bal1        转出卡钱包交易前金额
  --      12card_bal2        转入卡钱包交易前金额
  --      13encrypt1      转出卡转账后金额密文
  --      14encrypt2      转入卡转账后金额密文
  /*=======================================================================================*/
  PROCEDURE p_transfercancel_onerow(av_in    IN VARCHAR2, --传入参数
                                    av_debug IN VARCHAR2, --1写调试日志
                                    av_res   OUT VARCHAR2, --传出代码
                                    av_msg   OUT VARCHAR2 --传出错误信息
                                    ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --传入参数数组
    lv_clrdate pay_clr_para.clr_date%TYPE; --清分日期
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             13, --参数最少个数
                             13, --参数最多个数
                             'pk_transfer.p_transfercancel_onerow', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    pk_business.p_daybookcancelbyaccbookno(lv_in(5), --要撤销acc_book_no
                                           lv_in(1), --新业务流水号
                                           lv_in(6), --撤销记录的清分日期
                                           lv_clrdate, --当前清分日期
                                           lv_in(2), --交易代码
                                           lv_in(3), --当前柜员
                                           lv_in(11), --借方卡面交易前金额
                                           lv_in(12), --贷方卡面交易前金额
                                           lv_in(9), --借方卡片交易计数器
                                           lv_in(10), --贷方卡片交易计数器
                                           lv_in(13), --借方金额密文
                                           lv_in(14), --贷方金额密文
                                           lv_in(7), --借方交易前金额
                                           lv_in(8), --贷方交易前金额
                                           '0', --1直接确认
                                           av_debug, --1写调试日志
                                           av_res, --传出代码
                                           av_msg --传出错误信息
                                           );
  EXCEPTION
    WHEN OTHERS THEN
      av_res := pk_public.cs_res_unknownerr;
      av_msg := '转账撤销 发生错误：' || SQLERRM;
  END p_transfercancel_onerow;
  /*=======================================================================================*/
  --转账撤销
  --    如果原记录是灰记录，把记录改成充正状态，
  --                正常记录：新增一条负的灰记录，原记录改成撤销状态写撤销时间
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --       5action_no         转账时的业务流水号
  --       6clr_date          写灰记录时的清分日期
  --       7tr_state          原转账记录状态  灰记录或正常记录允许撤销
  --       8card_no1          转出卡号
  --       9card_no2          转入卡号
  --      10card_tr_count1   转出卡卡交易计数器
  --      11card_tr_count2   转入卡卡交易计数器
  --      12card_bal1        转出卡钱包交易前金额
  --      13card_bal2        转入卡钱包交易前金额
  --      14encrypt1      转出卡转账后金额密文
  --      15encrypt2      转入卡转账后金额密文
  /*=======================================================================================*/
  PROCEDURE p_transfercancel(av_in    IN VARCHAR2, --传入参数
                             av_debug IN VARCHAR2, --1写调试日志
                             av_res   OUT VARCHAR2, --传出代码
                             av_msg   OUT VARCHAR2 --传出错误信息
                             ) IS
    --lv_count   number;
    lv_in      pk_public.myarray; --传入参数数组
    lv_clrdate pay_clr_para.clr_date%TYPE; --清分日期
  BEGIN
    pk_public.p_getinputpara(av_in, --传入参数
                             15, --参数最少个数
                             15, --参数最多个数
                             'pk_transfer.p_transfercancel', --调用的函数名
                             lv_in, --转换成参数数组
                             av_res, --传出参数代码
                             av_msg --传出参数错误信息
                             );
    IF av_res <> pk_public.cs_res_ok THEN
      RETURN;
    END IF;
    SELECT clr_date INTO lv_clrdate FROM pay_clr_para;
    IF lv_in(7) = '9' THEN
      --取消灰记录
      pk_business.p_ashcancel(lv_clrdate, --清分日期
                              lv_in(5), --业务流水号
                              av_debug, --1写调试日志
                              av_res, --传出代码
                              av_msg --传出错误信息
                              );
    ELSIF lv_in(7) = '0' THEN
      --撤销正常记录
      pk_business.p_daybookcancel(lv_in(5), --要撤销业务流水号
                                  lv_in(1), --新业务流水号
                                  lv_in(6), --撤销记录的清分日期
                                  lv_clrdate, --当前清分日期
                                  lv_in(2), --交易代码
                                  lv_in(3), --柜员编号
                                  lv_in(12), --借方卡面交易前金额
                                  lv_in(13), --贷方卡面交易前金额
                                  lv_in(10), --借方卡片交易计数器
                                  lv_in(11), --贷方卡片交易计数器
                                  lv_in(14), --借方金额密文
                                  lv_in(15), --贷方金额密文
                                  '0', --1直接确认
                                  av_debug, --1写调试日志
                                  av_res, --传出代码
                                  av_msg --传出错误信息
                                  );
    END IF;
  END p_transfercancel;
BEGIN
  -- initialization
  NULL;
END pk_transfer;
/

