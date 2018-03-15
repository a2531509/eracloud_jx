CREATE OR REPLACE PACKAGE pk_business IS
  -- Purpose : 业务
  /*=======================================================================================*/
  --建账户
  --av_in: 1action_no|2tr_code|3oper_id|4oper_time|
  --5obj_type     类型（与账户主体类型一致，0-网点1-个人/卡 2-单位 3-商户4-机构）
  --6sub_type     卡类型(不用传入)
  --7obj_id       账户主体类型是卡时，传入卡号，(多个卡号时，卡号之间以,分割 cardno1,cardno2)
  --                             其它传入client_id，
  --8pwd          不用
  --9encrypt      卡账户金额密文(多个卡号时，之间以,分割 encrypt1,encrypt2)
  /*=======================================================================================*/
  PROCEDURE p_createaccount(av_in  IN VARCHAR2, --传入参数
                            av_res OUT VARCHAR2, --传出参数代码
                            av_msg OUT VARCHAR2 --传出参数错误信息
                            );
  /*=======================================================================================*/
  --建账户撤销
  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|5OBJ_TYPE|6SUB_TYPE|7OBJ_ID|
  /*=======================================================================================*/
  PROCEDURE p_createaccountcancel(av_in  IN VARCHAR2, --传入参数
                                  av_res OUT VARCHAR2, --传出参数代码
                                  av_msg OUT VARCHAR2 --传出参数错误信息
                                  );
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
                            );
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
                            );
  /*=======================================================================================*/
  --更新分户账
  /*=======================================================================================*/
  PROCEDURE p_updatesubledger(av_accno          IN NUMBER, --账号
                              av_amt            IN NUMBER, --金额
                              av_credit         IN NUMBER, --信用
                              av_balance_old    in varchar2, --交易前金额
                              av_balanceencrypt IN VARCHAR2, --金额密文
                              av_cardno         IN VARCHAR2, --卡号
                              av_res            OUT VARCHAR2, --传出参数代码
                              av_msg            OUT VARCHAR2 --传出参数错误信息
                              );
  /*=======================================================================================*/
  --根据借贷账户公共记账方法
  /*=======================================================================================*/
  PROCEDURE p_account(av_db        acc_account_sub%ROWTYPE, --借方账户
                      av_cr        acc_account_sub%ROWTYPE, --贷方账户
                      av_dbcardbal NUMBER, --借方卡面交易前金额
                      av_crcardbal NUMBER, --贷方卡片交易前金额

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
                      );
  /*=======================================================================================*/
  --灰记录确认  针对一条acc_daybook记录做确认
  /*=======================================================================================*/
  PROCEDURE p_ashconfirm_onerow(av_clrdate          IN pay_clr_para.clr_date%TYPE, --清分日期
                                av_daybook          IN acc_inout_detail%ROWTYPE, --要确认的daybook
                                av_dbbalanceencrypt IN VARCHAR2, --借方金额密文
                                av_crbalanceencrypt IN VARCHAR2, --贷方金额密文
                                av_dbaccbal         IN VARCHAR2, --借方交易前金额
                                av_craccbal         IN VARCHAR2, --贷方交易前金额
                                av_debug            IN VARCHAR2, --1写调试日志
                                av_res              OUT VARCHAR2, --传出代码
                                av_msg              OUT VARCHAR2 --传出错误信息
                                );
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
                                    );
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
                         );
  /*=======================================================================================*/
  --灰记录取消
  /*=======================================================================================*/
  PROCEDURE p_ashcancel(av_clrdate  IN pay_clr_para.clr_date%TYPE, --清分日期
                        av_actionno IN NUMBER, --业务流水号
                        av_debug    IN VARCHAR2, --1写调试日志
                        av_res      OUT VARCHAR2, --传出代码
                        av_msg      OUT VARCHAR2 --传出错误信息
                        );
  /*=======================================================================================*/
  --记账撤销 针对一条acc_daybook记录做撤销 daybook借贷账户不变,金额写负
  /*=======================================================================================*/
  PROCEDURE p_daybookcancel_onerow(av_daybook          IN acc_inout_detail%ROWTYPE, --要撤销daybook
                                   av_operator         IN sys_users%ROWTYPE, --当前操作员
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
                                   av_dbaccbal         IN VARCHAR2, --借方交易前金额
                                   av_craccbal         IN VARCHAR2, --贷方交易前金额
                                   av_confirm          IN VARCHAR2, --1直接确认
                                   av_debug            IN VARCHAR2, --1写调试日志
                                   av_res              OUT VARCHAR2, --传出代码
                                   av_msg              OUT VARCHAR2 --传出错误信息
                                   );
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
                                       av_dbaccbal         IN VARCHAR2, --借方交易前金额
                                       av_craccbal         IN VARCHAR2, --贷方交易前金额
                                       av_confirm          IN VARCHAR2, --1直接确认
                                       av_debug            IN VARCHAR2, --1写调试日志
                                       av_res              OUT VARCHAR2, --传出代码
                                       av_msg              OUT VARCHAR2 --传出错误信息
                                       );
  /*=======================================================================================*/
  --记账撤销
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
                            );
  /*=======================================================================================*/
  --收取或退还工本费服务费等
  --  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --           5item_no|6amt|7note
  /*=======================================================================================*/
  PROCEDURE p_cost(av_in    IN VARCHAR2, --传入参数
                   av_debug IN VARCHAR2, --1调试
                   av_res   OUT VARCHAR2, --传出参数代码
                   av_msg   OUT VARCHAR2 --传出参数错误信息
                   );
  /*=======================================================================================*/
  --现金交接
  --  --AV_IN: 1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|
  --           5oper_id1|6oper_id2|7amt|8note
  /*=======================================================================================*/
  PROCEDURE p_cashhandover(av_in    IN VARCHAR2, --传入参数
                           av_debug IN VARCHAR2, --1调试
                           av_res   OUT VARCHAR2, --传出参数代码
                           av_msg   OUT VARCHAR2 --传出参数错误信息
                           );

  /*=======================================================================================*/
  --定时触发卡号表中已使用数据到历史表，可在卡号自动生成后触发
  --原则，卡号表中状态为已使用，且action_no对应的任务状态>已生成才允许移到历史表，
  --且保留当前卡号生成规则的卡号序列的最大值，以免新生成的卡号重复
  /*=======================================================================================*/
  PROCEDURE p_card_no_2_his(av_res OUT VARCHAR2, --传出代码
                            av_msg OUT VARCHAR2 --传出错误信息;
                            );

  /*=======================================================================================*/
  --市场号变更，定时器触发
  /*=======================================================================================*/
  -- procedure p_change_market_reg_no;

  procedure p_account2(av_db_acc_no        in varchar2, --借方账户
                       av_cr_acc_no        in varchar2, --贷方账户
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
                       );
END pk_business;
/

