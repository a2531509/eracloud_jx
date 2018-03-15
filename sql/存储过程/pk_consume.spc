CREATE OR REPLACE PACKAGE pk_consume IS
  -- Purpose : 消费
  /*=======================================================================================*/
  --根据商户号 返回账户列表
  --av_table:code_value code_name
  /*=======================================================================================*/
  PROCEDURE p_getAccKindList(av_bizid IN base_merchant.merchant_id%TYPE, --商户编码
                             av_table OUT pk_public.t_cur --账户列表
                             );

  /*=======================================================================================*/
  --取账户信息
  --av_table:acc_no,acc_kind,acc_name,item_no,acc_state,balance,balance_encrypt,frz_flag,frz_amt,psw
  /*=======================================================================================*/
  PROCEDURE p_getcardacc(av_cardno  VARCHAR2, --卡号
                         av_acckind VARCHAR2, --账户类型
                         av_res     OUT VARCHAR2, --传出参数代码
                         av_msg     OUT VARCHAR2, --传出参数错误信息
                         av_table   OUT pk_public.t_cur);
  /*=======================================================================================*/
  --联机消费_计算
  --av_in: 各字段以|分割
  --       1tr_code    交易代码
  --       2card_no    卡号
  --       3tr_amt     消费金额
  --       4mode_no    消费模式
  --av_out: 账户列表acclist
  --      acclist      账户列表 acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsume_calc(av_in  IN VARCHAR2, --传入参数
                                 av_res OUT VARCHAR2, --传出代码
                                 av_msg OUT VARCHAR2, --传出错误信息
                                 av_out OUT VARCHAR2 --传出参数
                                 );
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
  --       9pwd          密码
  --      10tr_amt       总交易金额
  --      11acclist      账户列表 acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      12note         备注
  --      13acpt_type    受理点分类
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsume(av_in    IN VARCHAR2, --传入参数
                            av_debug IN VARCHAR2, --1调试
                            av_res   OUT VARCHAR2, --传出代码
                            av_msg   OUT VARCHAR2, --传出错误信息
                            av_out   OUT VARCHAR2 --传出参数
                            );
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
                                       );
  /*=======================================================================================*/
  --联机消费撤销_计算
  --av_in: 各字段以|分割
  --       1acpt_id      受理点编号(网点号或商户编号)
  --       2oper_id      操作员/终端号
  --       3tr_batch_no  批次号
  --       4action_no   终端交易流水号
  --       5camt      卡号
  --av_out: 原消费action_no|原消费clr_date|账户列表acclist
  --      acclist      账户列表 acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumeundo_calc(av_in  IN VARCHAR2, --传入参数
                                     av_res OUT VARCHAR2, --传出代码
                                     av_msg OUT VARCHAR2, --传出错误信息
                                     av_out OUT VARCHAR2 --传出参数
                                     );
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
  --      10tr_amt       总交易金额
  --      11acclist      账户列表 acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      12action_no    被充正的action_no
  --      13clr_date     被充正记录的clr_date
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumecancel(av_in    IN VARCHAR2, --传入参数
                                  av_debug IN VARCHAR2, --1调试
                                  av_res   OUT VARCHAR2, --传出代码
                                  av_msg   OUT VARCHAR2, --传出错误信息
                                  av_out   OUT VARCHAR2 --传出参数
                                  );

  /*=======================================================================================*/
  --联机消费退货_计算
  --av_in: 各字段以|分割
  --       1action_no    消费记录的业务流水号
  --       2card_no      卡号
  --       3clr_date     消费记录的清分日期
  --       4tr_amt       退货金额
  --       5
  --av_out: 账户列表acclist
  --      acclist      账户列表 acc_kind$amt$balance$balance_encrypt,acc_kind$amt$balance$balance_encrypt
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumereturn_calc(av_in  IN VARCHAR2, --传入参数
                                       av_res OUT VARCHAR2, --传出代码
                                       av_msg OUT VARCHAR2, --传出错误信息
                                       av_out OUT VARCHAR2 --传出参数
                                       );
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
  --      10tr_amt       总交易金额
  --      11acclist      账户列表 acc_kind$amt$balance_new$balance_encrypt_new,acc_kind$amt$balance_new$balance_encrypt_new
  --      12action_no    被退货的action_no
  --      13clr_date     被退货记录的clr_date
  --av_out 1action_no|clr_date|oper_time
  /*=======================================================================================*/
  PROCEDURE p_onlineconsumereturn(av_in    IN VARCHAR2, --传入参数
                                  av_debug IN VARCHAR2, --1调试
                                  av_res   OUT VARCHAR2, --传出代码
                                  av_msg   OUT VARCHAR2, --传出错误信息
                                  av_out   OUT VARCHAR2 --传出参数
                                  );

  /*=======================================================================================*/
  --脱机数据上送
  --av_in: 各字段以|分割
  --org_id|co_org_id|acpt_id|end_id|batch_no|ser_no|card_no|CARD_IN_TYPE|CARD_IN_SUBTYPE|CARD_VALID_DATE|
  --Applyusedate|Applyvaliddate|Moneynum|Psamid|Psamnum|CardBalmoney|Trademoney|Tradetime|Tradetype|Tac|
  --Flag|deal_state|SEND_FILE_NAME|FILE_LINE_NO|TR_CODE
  --
  /*=======================================================================================*/
  PROCEDURE p_upofflineconsume(av_in    IN VARCHAR2, --传入参数
                               av_debug IN VARCHAR2, --1调试
                               av_res   OUT VARCHAR2, --传出代码
                               av_msg   OUT VARCHAR2 --传出错误信息
                               );

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
                             );
  /*=======================================================================================*/
  --脱机消费灰记录确认
  --av_in: 各字段以|分割
  --       action_no
  /*=======================================================================================*/
  PROCEDURE p_ashconfirm(av_in    IN VARCHAR2, --传入参数
                         av_debug IN VARCHAR2, --1调试
                         av_res   OUT VARCHAR2, --传出代码
                         av_msg   OUT VARCHAR2 --传出错误信息
                         );
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
                                   );
  /*=======================================================================================*/
  --脱机消费灰记录冲正 --更改状态为已冲正
  --av_in: 各字段以|分割
  --       action_no
  /*=======================================================================================*/
  PROCEDURE p_ashcancel(av_in    IN VARCHAR2, --传入参数
                        av_debug IN VARCHAR2, --1调试
                        av_res   OUT VARCHAR2, --传出代码
                        av_msg   OUT VARCHAR2 --传出错误信息
                        );
  /*=======================================================================================*/
  --脱机消费拒付改成正常
  --av_in: 各字段以|分割
  --       action_no
  /*=======================================================================================*/
  PROCEDURE p_black2normal(av_in    IN VARCHAR2, --传入参数
                           av_debug IN VARCHAR2, --1调试
                           av_res   OUT VARCHAR2, --传出代码
                           av_msg   OUT VARCHAR2 --传出错误信息
                           );
  /*=======================================================================================*/
  --取人员基本信息
  --av_in: 各字段以|分割  card_no|cert_no|sub_card_no|
  /*=======================================================================================*/
  PROCEDURE p_getPersonalInfo(av_in    IN VARCHAR2, --传入参数
                              av_debug IN VARCHAR2, --1调试
                              av_res   OUT VARCHAR2, --传出代码
                              av_msg   OUT VARCHAR2, --传出错误信息
                              av_table OUT pk_public.t_cur);

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
                             );
  /*=======================================================================================*/
  --签到促销
  --每次消费者签到，从经营户的商户卡里扣0.4元给会员卡的未圈存账户上；
  --  同时每月签到30次及以上的次月给予10元买菜金的奖励，
  --      每年签到100次及以上的另外给予10元买菜金。
  /*=======================================================================================*/
  /*PROCEDURE p_signpromotion(as_filename VARCHAR2, --签到文件名
                            av_debug    IN VARCHAR2, --1调试
                            av_res      OUT VARCHAR2, --传出代码
                            av_msg      OUT VARCHAR2 --传出错误信息
                            );
  /*=======================================================================================*/
  --签到促销
  --  同时每月签到30次及以上的次月给予10元买菜金的奖励，
  /*=======================================================================================*/
  /*  PROCEDURE p_signpromotion_month(as_month VARCHAR2, --月份 yyyy-mm
                                  av_debug IN VARCHAR2, --1调试
                                  av_res   OUT VARCHAR2, --传出代码
                                  av_msg   OUT VARCHAR2 --传出错误信息
                                  );
  /*=======================================================================================*/
  --签到促销
  --  每年签到100次及以上的另外给予10元买菜金。
  /*=======================================================================================*/
  /* PROCEDURE p_signpromotion_year(as_year  VARCHAR2, --年份 yyyy
  av_debug IN VARCHAR2, --1调试
  av_res   OUT VARCHAR2, --传出代码
  av_msg   OUT VARCHAR2 --传出错误信息
  );*/
  /*=======================================================================================*/
  --其它促销
  --VIP卡每日赠送1元买菜金，一年365元
  /*=======================================================================================*/
  /*PROCEDURE p_vippromotion(av_trdate IN VARCHAR2, --日期yyyy-mm-dd
  av_debug  IN VARCHAR2, --1调试
  av_res    OUT VARCHAR2, --传出代码
  av_msg    OUT VARCHAR2 --传出错误信息
  );*/
  procedure p_accFreeze(av_in    in varchar2,
                        av_debug in varchar2,
                        av_res   out varchar2,
                        av_msg   out varchar2,
                        av_out   out varchar2);
   /*=======================================================================================*/
    --账户金额解冻
    --参数信息
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

  /*=======================================================================================*/                       
  procedure p_accUnFreeze(av_in    in varchar2,
                          av_debug in varchar2,
                          av_res   out varchar2,
                          av_msg   out varchar2,
                          av_out   out varchar2);
                          
  /*=======================================================================================*/
  --脱机数据处理twz
  --av_deal_no 流水号
  --拒付原因:00－卡片发行方调整01－tac码错02－数据非法03－数据重复04－灰记录05－金额不足06-测试数据09调整拒付10正常数据
  /*=======================================================================================*/
  PROCEDURE p_offlineconsume_twz(av_deal_no    IN VARCHAR2, --传入参数
                             av_debug IN VARCHAR2, --1调试
                             av_res   OUT VARCHAR2, --传出代码
                             av_msg   OUT VARCHAR2 --传出错误信息
                             );
END pk_consume;
/

