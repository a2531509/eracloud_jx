CREATE OR REPLACE PACKAGE pk_public IS

  -- Purpose : 公用包
  TYPE myarray IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  --游标
  TYPE t_cur IS REF CURSOR;

  cs_cm_card_nums         NUMBER := 20; --卡片表分表数量
  cs_trade_pwd_err_num    NUMBER := 6; --交易密码输错次数
  cs_serv_pwd_err_num     NUMBER := 6; --服务密码输错次数
  cs_co_org_serv_pwd_err_num     NUMBER := 6; --合作机构密码输错次数
  cs_points_exchange_acc  VARCHAR2(2) := '09'; --积分兑换目标账户，取账户类型，09未圈存账户
  cs_points_exchange_rate NUMBER := 100; --积分兑现比例100兑1元，值为100
  cs_points_period_rule   NUMBER := 4; --积分生成：积分计期规则，1天2月3季4年
  cs_points_period        NUMBER := 1; --积分生成：积分有效期，与计期规则配合使用，按天时可填365，按月时可填24
  cs_yesno_yes        CONSTANT VARCHAR2(1) := '0'; --是否_是
  cs_yesno_no         CONSTANT VARCHAR2(1) := '1'; --是否_否
  cs_defaultwalletid  CONSTANT VARCHAR2(2) := '00'; --默认钱包编号
  cs_client_type_card CONSTANT VARCHAR2(1) := '1'; --客户类型（0-网点1-个人/卡 2-单位 3-商户4-机构）
  cs_acpt_type_wd     CONSTANT VARCHAR2(1) := '1'; --受理点分类：(0-商户 1-网点)
  cs_acpt_type_sh     CONSTANT VARCHAR2(1) := '0'; --受理点分类：(0-商户 1-网点)

  CARD_TYPE_SMZK CONSTANT card_baseinfo.card_type%TYPE  := '120';--全功能卡 卡类型

  --账户类型
  cs_acckind_pt   CONSTANT acc_account_sub.acc_kind%TYPE := '00'; --普通账户
  cs_acckind_qb   CONSTANT acc_account_sub.acc_kind%TYPE := '01'; --钱包账户
  cs_acckind_zj   CONSTANT acc_account_sub.acc_kind%TYPE := '02'; --资金账户
  cs_acckind_jf   CONSTANT acc_account_sub.acc_kind%TYPE := '03'; --积分账户
  cs_acckind_djq  CONSTANT acc_account_sub.acc_kind%TYPE := '04'; --代金券账户
  cs_acckind_zfbt CONSTANT acc_account_sub.acc_kind%TYPE := '05'; --政府补贴账户
  cs_acckind_zy   CONSTANT acc_account_sub.acc_kind%TYPE := '06'; --专用账户
  cs_acckind_czk  CONSTANT acc_account_sub.acc_kind%TYPE := '07'; --充值卡账户
  cs_acckind_yhq  CONSTANT acc_account_sub.acc_kind%TYPE := '08'; --优惠券账户
  cs_acckind_wqc  CONSTANT acc_account_sub.acc_kind%TYPE := '09'; --未圈存账户
  cs_acckind_yj   CONSTANT acc_account_sub.acc_kind%TYPE := '10'; --押金账户

  --科目号
  cs_accitem_cash                CONSTANT acc_item.item_id%TYPE := '101101'; --现金
  cs_accitem_org_bank            CONSTANT acc_item.item_id%TYPE := '102100'; --机构往来款
  cs_accitem_org_points          CONSTANT acc_item.item_id%TYPE := '102101'; --机构积分
  cs_accitem_card_deposit_300    CONSTANT acc_item.item_id%TYPE := '201101'; --卡存款
  cs_accitem_card_points         CONSTANT acc_item.item_id%TYPE := '201102'; --卡片个人积分
  cs_accitem_card_deposit_310    CONSTANT acc_item.item_id%TYPE := '201103'; --商户卡卡存款
  cs_accitem_card_deposit_800    CONSTANT acc_item.item_id%TYPE := '201104'; --充值卡卡存款
  cs_accitem_card_foregift       CONSTANT acc_item.item_id%TYPE := '201105'; --卡押金
  cs_accitem_biz_clr             CONSTANT acc_item.item_id%TYPE := '205101'; --商户待清算款
  cs_accitem_biz_stl             CONSTANT acc_item.item_id%TYPE := '205102'; --商户结算金
  cs_accitem_brch_prestore       CONSTANT acc_item.item_id%TYPE := '207101'; --代理网点预存款
  cs_accitem_org_handding_fee_in CONSTANT acc_item.item_id%TYPE := '701101'; --手续费收入
  cs_accitem_org_cost_in         CONSTANT acc_item.item_id%TYPE := '702101'; --卡工本费
  cs_accitem_org_serv_fee_in     CONSTANT acc_item.item_id%TYPE := '703101'; --卡押金/服务费收入
  cs_accitem_org_zxc_ree_in      CONSTANT acc_item.item_id%TYPE := '703102'; --自行车押金收入
  cs_accitem_org_remain_in       CONSTANT acc_item.item_id%TYPE := '709101'; --卡残值收入款
  cs_accitem_org_other_in        CONSTANT acc_item.item_id%TYPE := '709999'; --其他收入
  cs_accitem_org_prmt_out        CONSTANT acc_item.item_id%TYPE := '713101'; --促销支出
  cs_accitem_org_points_chg_out  CONSTANT acc_item.item_id%TYPE := '713102'; --积分兑换支出
  cs_accitem_org_credit_chg_out  CONSTANT acc_item.item_id%TYPE := '713103'; --信用支出
  cs_accitem_co_org_rechage_in   CONSTANT acc_item.item_id%TYPE := '208101'; --合作机构应收款
  cs_accitem_co_rechage_yck_in   CONSTANT acc_item.item_id%TYPE := '208301'; --合作机构预存款

  --申领状态
  --申领状态00-已申请,10-任务已生成 20-制卡中 30-已制卡 40-已配送 50-已接收  60-已发放 70-已退卡 90注销)

  kg_card_apply_ysq CONSTANT  VARCHAR2(2) := '00';
  kg_card_apply_rwysc CONSTANT  VARCHAR2(2) := '10';
  kg_card_apply_yfwjw    constant  varchar2(2) := '11';--已发卫计委
  kg_card_apply_wjwshbtg constant  varchar2(2) := '12';--卫计委审核不通过
  kg_card_apply_wjwshtg  constant  varchar2(2) := '13';--卫计委审核已通过
  kg_card_apply_yfbank   constant  varchar2(2) := '14';--已发银行
  kg_card_apply_yhshbtg  constant  varchar2(2) := '15';--银行审核不通过
  kg_card_apply_yhshtg   constant  varchar2(2) := '16';--银行审核通过
  kg_card_apply_yfst     constant  varchar2(2) := '17';--已发省厅
  kg_card_apply_stshbtg  constant  varchar2(2) := '18';--省厅审核不通过
  kg_card_apply_stshtg   constant  varchar2(2) := '19';--省厅审核通过
  kg_card_apply_zkz CONSTANT  VARCHAR2(2) := '20';
  kg_card_apply_yzk CONSTANT  VARCHAR2(2) := '30';
  kg_card_apply_yps CONSTANT  VARCHAR2(2) := '40';
  kg_card_apply_yjs CONSTANT  VARCHAR2(2) := '50';
  kg_card_apply_yff CONSTANT  VARCHAR2(2) := '60';
  kg_card_apply_ytk CONSTANT  VARCHAR2(2) := '70';
  kg_card_apply_yhs      constant  varchar2(2) := '80';
  kg_card_apply_yzx CONSTANT  VARCHAR2(2) := '90';

  --任务状态
  --任务状态(00任务已生成,10制卡中,20已制卡,30已配送,40已接收,50发卡过程中90发放完成)
  kg_card_task_ysc CONSTANT  VARCHAR2(2) := '00';
  kg_card_task_yfwjw  CONSTANT  VARCHAR2(2) := '01';--已发卫计委
  kg_card_task_wjwysh CONSTANT  VARCHAR2(2) := '02';--卫计委已审核
  kg_card_task_yfyh   CONSTANT  VARCHAR2(2) := '03';--已发银行
  kg_card_task_yhysh  CONSTANT  VARCHAR2(2) := '04';--银行已审核
  kg_card_task_yfst   CONSTANT  VARCHAR2(2) := '05';--已发省厅
  kg_card_task_stysh  CONSTANT  VARCHAR2(2) := '06';--省厅已审核
  kg_card_task_zkz CONSTANT  VARCHAR2(2) := '10';
  kg_card_task_yzk CONSTANT  VARCHAR2(2) := '20';
  kg_card_task_yps CONSTANT  VARCHAR2(2) := '30';
  kg_card_task_yjs CONSTANT  VARCHAR2(2) := '40';
  kg_card_task_fkz CONSTANT  VARCHAR2(2) := '50';
  kg_card_task_yff CONSTANT  VARCHAR2(2) := '90';

  --错误码
  cs_res_ok                   CONSTANT VARCHAR2(8) := '00000000'; --成功
  cs_res_paravalueerr         CONSTANT VARCHAR2(8) := '88880001'; --参数值错误
  cs_res_validatetypeerr      CONSTANT VARCHAR2(8) := '88880002'; --验证类型错误
  cs_res_clr_control_paraerr  CONSTANT VARCHAR2(8) := '88880003'; --获取服务状态出错
  cs_res_sysworking           CONSTANT VARCHAR2(8) := '88880004'; --系统正在日终处理,请稍后
  cs_res_operatorerr          CONSTANT VARCHAR2(8) := '88880005'; --用户或密码验证失败
  cs_res_cashinsufbalance     CONSTANT VARCHAR2(8) := '88880006'; --柜员尾箱不足
  cs_res_cardiderr            CONSTANT VARCHAR2(8) := '88880007'; --卡号验证不通过
  cs_res_accnotexit           CONSTANT VARCHAR2(8) := '88880008'; --账户不存在
  cs_res_accstateerr          CONSTANT VARCHAR2(8) := '88880009'; --帐户状态为不可用
  cs_res_accinsufbalance      CONSTANT VARCHAR2(8) := '88880010'; --账户余额不足
  cs_res_pwderr               CONSTANT VARCHAR2(8) := '88880011'; --密码错误
  cs_res_pwderrnum            CONSTANT VARCHAR2(8) := '88880012'; --密码输错超过超限
  cs_res_prepaidcardisused    CONSTANT VARCHAR2(8) := '88880013'; --充值卡已使用
  cs_res_prepaidcardnotexist  CONSTANT VARCHAR2(8) := '88880014'; --充值卡不存在
  cs_res_prepaidcardfeeerr    CONSTANT VARCHAR2(8) := '88880015'; --充值卡金额错误
  cs_res_prepaidcardpwderr    CONSTANT VARCHAR2(8) := '88880016'; --充值卡密码错误
  cs_res_rechg_exceed_limit   CONSTANT VARCHAR2(8) := '88880017'; --充值超限
  cs_res_busierr              CONSTANT VARCHAR2(8) := '88880018'; --商户验证失败
  cs_res_termerr              CONSTANT VARCHAR2(8) := '88880019'; --终端验证失败
  cs_res_relogin              CONSTANT VARCHAR2(8) := '88880020'; --已签到，不能重复签到
  cs_res_relogout             CONSTANT VARCHAR2(8) := '88880021'; --已签退，不能重复签退
  cs_res_notlogin             CONSTANT VARCHAR2(8) := '88880022'; --终端未签到
  cs_res_glidenotexit         CONSTANT VARCHAR2(8) := '88880023'; --冲正/撤销的流水号不存在
  cs_res_glideinfoerr         CONSTANT VARCHAR2(8) := '88880024'; --冲正/撤销的流水信息不正确
  cs_res_glideflushesed       CONSTANT VARCHAR2(8) := '88880025'; --流水已冲正，不能重复冲正
  cs_res_flushesoperdifferent CONSTANT VARCHAR2(8) := '88880026'; --撤销操作员和原操作员必须相同
  cs_res_tr_dataerr           CONSTANT VARCHAR2(8) := '88880027'; --交易数据错误
  cs_res_tradeiderr           CONSTANT VARCHAR2(8) := '88880028'; --交易码错误
  cs_res_cancelfeeerr         CONSTANT VARCHAR2(8) := '88880029'; --退货总金额大于原消费金额，系统拒绝本次交易
  cs_res_exp_acc_unallowed    CONSTANT VARCHAR2(8) := '88880030'; --该商户不允许使用此专用账户消费
  cs_res_consume_quotas_amt   CONSTANT VARCHAR2(8) := '88880031'; --单笔消费超出限额
  cs_res_consume_quotas_num   CONSTANT VARCHAR2(8) := '88880032'; --日消费超出次数
  cs_res_rljljxf_amt          CONSTANT VARCHAR2(8) := '88880033'; --日消费超出金额
  cs_res_rowunequalone        CONSTANT VARCHAR2(8) := '88880034'; --数据不唯一或数据重复;
  cs_res_signin_apply_unique  CONSTANT VARCHAR2(8) := '88880035'; --其它商户正在申请;
  cs_res_signin_apply_max     CONSTANT VARCHAR2(8) := '88880036'; --报名名额已满;
  cs_res_user_err             CONSTANT VARCHAR2(8) := '88880037'; --受卡方身份识别错误;
  cs_res_cardis_err           CONSTANT VARCHAR2(8) := '88880038'; --该客户存在卡号，不可重复申领;
  cs_res_oldcardnull_err      CONSTANT VARCHAR2(8) := '88880039'; --老卡不能为空;
  cs_res_oldcardnotexist_err  CONSTANT VARCHAR2(8) := '88880040'; --原账户信息不存在;
  cs_res_oldcardtansvil_err   CONSTANT VARCHAR2(8) := '88880041'; --补换卡验证失败;
  cs_res_personalvil_err      CONSTANT VARCHAR2(8) := '88880042'; --客户信息验证失败;
  cs_res_card_ban_deal        CONSTANT VARCHAR2(8) := '88880043'; --卡状态该交易码禁止交易;
  cs_res_consume_upbig_num    CONSTANT VARCHAR2(8) := '88880044'; --商户累计超出大额交易笔数报警;
  cs_res_co_check_bill_rep    CONSTANT VARCHAR2(8) := '88880045'; --合作机构不可以重复对账
  cs_res_co_check_bill_nomsg  CONSTANT VARCHAR2(8) := '88880046'; --合作机构对账信息不存在
  cs_res_access_pointtr_err   CONSTANT VARCHAR2(8) := '88880047'; --接入点交易验证失败
  cs_res_baseco_nofounderr    CONSTANT VARCHAR2(8) := '88880048'; --合作机构信息未登记
  cs_res_tagdev_validateerr   CONSTANT VARCHAR2(8) := '88880049'; --终端设备号验证出错
  cs_res_cardisblackerr       CONSTANT VARCHAR2(8) := '88880050'; --卡是否为黑名单卡
  cs_res_cardstateiserr       CONSTANT VARCHAR2(8) := '88880051'; --卡状态不正常
  cs_res_co_org_novalidateerr CONSTANT VARCHAR2(8) := '88880052'; --合作机构不合法
  cs_res_apply_msg_err        CONSTANT VARCHAR2(8) := '88880053'; --申领记录不正确
  cs_res_nobhktype_err        CONSTANT VARCHAR2(8) := '88880054'; --申领记录不是补换卡记录
  cs_res_amt_is_zero          CONSTANT VARCHAR2(8) := '88880055'; --老卡账户余额是0无需进行转账
  cs_res_tramt_acc_oneerr     CONSTANT VARCHAR2(8) := '88880056'; --账户单笔消费超限
  cs_res_tramt_acc_allerr     CONSTANT VARCHAR2(8) := '88880057'; --账户累计消费超限
  cs_res_wallettramt_allerr   CONSTANT VARCHAR2(8) := '88880058'; --小额消费单笔消费超限
  cs_res_trmun_acc_allerr     CONSTANT VARCHAR2(8) := '88880059'; -- 账户累计消费笔数超限
  cs_res_onerechage_accerr    CONSTANT VARCHAR2(8) := '88880060'; -- 联机账户单笔充值超限
  cs_res_onerechage_walerr    CONSTANT VARCHAR2(8) := '88880061'; -- 电子钱包单笔充值超限
  cs_res_checkcongh_walerr    CONSTANT VARCHAR2(8) := '88880062'; -- 卡号对应的人员不准许在刚商户下消费
  cs_res_sqnmode_mererr       CONSTANT VARCHAR2(8) := '88880063'; -- 传入的消费模式不属于该商户
  cs_res_sqngetmode_mererr    CONSTANT VARCHAR2(8) := '88880064'; -- 获取账户消费模式出错
  cs_res_no_bind_bank         CONSTANT VARCHAR2(8) := '88880065'; -- 卡未绑定银行
  cs_res_bind_bank_err        CONSTANT VARCHAR2(8) := '88880066'; --绑定银行错误，不是本银行的卡
  cs_res_bind_bankno_err      CONSTANT VARCHAR2(8) := '88880067'; --解绑时传入的银行卡卡号和当前绑定的卡号不一致
  cs_res_bind_bank_more       CONSTANT VARCHAR2(8) := '88880068'; --找到多条绑定记录
  cs_res_card_apply_noexist   CONSTANT VARCHAR2(8) := '88880069'; --卡片对应的申领记录不存在
  cs_res_card_apply_noyjs     CONSTANT VARCHAR2(8) := '88880070'; --卡片对应的申领记录不是已接收状态
  cs_res_bcp_not_exist        CONSTANT VARCHAR2(8) := '88880071'; --根据银行卡卡号找不到对应的卡号
  cs_res_bcp_has_more         CONSTANT VARCHAR2(8) := '88880072'; --
  cs_res_bcp_has_bind         CONSTANT VARCHAR2(8) := '88880073'; --银行卡对应的卡号已经使用
  cs_res_bcp_notmadecard_list CONSTANT VARCHAR2(8) := '88880074'; --半成品卡采购明细不粗在
  cs_res_bcp_notmadecard_task CONSTANT VARCHAR2(8) := '88880075'; --半成品卡采购任务不存在
  cs_res_bcp_not_madecard     CONSTANT VARCHAR2(8) := '88880076'; --不是半成品卡采购的任务
  cs_res_not_cardconfig       CONSTANT VARCHAR2(8) := '88880077'; --卡配置参数信息不正确
  cs_res_bcp_updateerr        CONSTANT VARCHAR2(8) := '88880078'; --更新半成品卡使用状态失败


  --------卡发放错误码
  cs_res_grant_cardType_err   CONSTANT VARCHAR2(8) :=  '22220001'; --目前不支持该卡类型的发放
  cs_res_grant_nofindapply_err    CONSTANT VARCHAR2(8) := '22220002'; --未找到任何申领数据
  cs_res_grant_nofindtaks_err  CONSTANT VARCHAR2(8) := '22220003';--未找到任何任务数据数据
  cs_res_grant_condition_err  CONSTANT  VARCHAR2(8) := '22220004';--不满足发放条件
  cs_res_grant_taskcondition_err  CONSTANT  VARCHAR2(8) := '22220005';--任务状态不正确，不准许发放

  cs_res_ruleerr    CONSTANT VARCHAR2(8) := '88880070'; --调用规则引擎错误
  cs_res_dberr      CONSTANT VARCHAR2(8) := '88880080'; --数据错误统称
  cs_no_datafound_err  CONSTANT VARCHAR2(8) := '88880098';--未找到任何数据
  cs_res_unknownerr CONSTANT VARCHAR2(8) := '88880099'; --未知错误
  --------库存错误代码-----
  cs_res_kc1 CONSTANT VARCHAR2(8) := '11111001'; --库存明细错误
  cs_res_kc2    CONSTANT VARCHAR2(8) := '11111002'; --库存账户错误
  cs_res_kc3    CONSTANT VARCHAR2(8) := '11111003'; --库存更新报错误
  --------申领错误代码-----
  cs_res_apply1 CONSTANT VARCHAR2(8) := '11112001'; --申领验证错误
  cs_res_apply2 CONSTANT VARCHAR2(8) := '11112002'; --申领状态不正确
  cs_res_apply3 CONSTANT VARCHAR2(8) := '11112003'; --申领报错
  /*=======================================================================================*/
  --分解字符串
  /*=======================================================================================*/
  FUNCTION f_splitstr(av_in      IN VARCHAR2,
                      av_partstr IN VARCHAR2,
                      av_out     OUT myarray) RETURN INT DETERMINISTIC;
  /*=======================================================================================*/
  --把数组av_start到av_end的置空
  /*=======================================================================================*/
  PROCEDURE p_initarray(av_in    IN OUT myarray,
                        av_start NUMBER,
                        av_end   NUMBER);
  /*=======================================================================================*/
  --查询系统参数
  /*=======================================================================================*/
  FUNCTION f_getsyspara(av_paraname IN sys_para.para_code%TYPE --参数名称
                        ) RETURN VARCHAR2;
  /*=======================================================================================*/
  --根据卡号返回卡片所在表名
  /*=======================================================================================*/
  FUNCTION f_getcardtablebycard_no(av_cardno VARCHAR2) RETURN VARCHAR2
    DETERMINISTIC;
  /*=======================================================================================*/
  --根据卡号返回账户所在表名
  /*=======================================================================================*/
  FUNCTION f_getsubledgertablebycard_no(av_cardno VARCHAR2) RETURN VARCHAR2
    DETERMINISTIC;
  /*=======================================================================================*/
  --根据卡号返回积分构成表所在表名
  /*=======================================================================================*/
  FUNCTION f_getpointsperiodbycard_no(av_cardno VARCHAR2) RETURN VARCHAR2
    DETERMINISTIC;
  /*=======================================================================================*/
  --根据卡号、清分日期返回卡片交易记录表所在表名
  /*=======================================================================================*/
  FUNCTION f_gettrcardtable(av_cardno VARCHAR2, av_trdate DATE)
    RETURN VARCHAR2 DETERMINISTIC;
  /*=======================================================================================*/
  --记调试日志
  /*=======================================================================================*/
  PROCEDURE p_insertrzcllog(av_remark   acc_rzcllog.remark%TYPE,
                            av_actionno NUMBER);
  /*=======================================================================================*/
  --记调试日志
  /*=======================================================================================*/
  PROCEDURE p_insertrzcllog_(av_log_flag CHAR, --是否记日志开关，0是1否
                             av_remark   acc_rzcllog.remark%TYPE,
                             av_actionno NUMBER);
  /*=======================================================================================*/
  --根据机构号取虚拟的admin柜员编号
  /*=======================================================================================*/
  FUNCTION f_getorgoperid(av_orgid VARCHAR2 --机构编号
                          ) RETURN VARCHAR2 DETERMINISTIC;
  /*=======================================================================================*/
  --根据机构号取虚拟的admin柜员
  /*=======================================================================================*/
  PROCEDURE p_getorgoperator(av_orgid    VARCHAR2, --机构编号
                             av_operator OUT sys_USERS%ROWTYPE, --柜员
                             av_res      OUT VARCHAR2, --传出参数代码
                             av_msg      OUT VARCHAR2 --传出参数错误信息
                             );
  /*=======================================================================================*/
  --根据卡类型查询科目号--充值卡充值时用到
  /*=======================================================================================*/
  FUNCTION f_getitemnobycardtype(av_cardtype VARCHAR2 --卡类型
                                 ) RETURN VARCHAR2;
  /*=======================================================================================*/
  --根据科目号和机构号查找机构分账户
  /*=======================================================================================*/
  PROCEDURE p_getorgsubledger(av_orgid     VARCHAR2, --机构号
                              av_itemno    VARCHAR2, --科目号
                              av_subledger OUT acc_account_sub%ROWTYPE, --分户账
                              av_res       OUT VARCHAR2, --传出参数代码
                              av_msg       OUT VARCHAR2 --传出参数错误信息
                              );
  /*=======================================================================================*/
  --根据科目号和网点号查找分账户
  /*=======================================================================================*/
  PROCEDURE p_getsubledgerbyclientid(av_clientid  VARCHAR2, --客户号/网点号
                                     av_itemno    VARCHAR2, --科目号
                                     av_subledger OUT acc_account_sub%ROWTYPE, --分户账
                                     av_res       OUT VARCHAR2, --传出参数代码
                                     av_msg       OUT VARCHAR2 --传出参数错误信息
                                     );
  /*=======================================================================================*/
  --根据卡号和账户类型查找分账户
  /*=======================================================================================*/
  PROCEDURE p_getsubledgerbycardno(av_cardno    VARCHAR2, --卡号
                                   av_acckind   VARCHAR2, --账户类型
                                   av_walletid  IN acc_account_sub.wallet_no%TYPE, --钱包编号
                                   av_subledger OUT acc_account_sub%ROWTYPE, --分户账
                                   av_res       OUT VARCHAR2, --传出参数代码
                                   av_msg       OUT VARCHAR2 --传出参数错误信息
                                   );
  /*=======================================================================================*/
  --根据卡号和账户类型查找账户余额
  /*=======================================================================================*/
  FUNCTION f_getcardbalance(av_cardno   VARCHAR2, --卡号
                            av_acckind  VARCHAR2, --账户类型
                            av_walletid VARCHAR2 --钱包编号
                            ) RETURN NUMBER;
  /*=======================================================================================*/
  --根据卡号查找卡片基本信息
  /*=======================================================================================*/
  PROCEDURE p_getcardbycardno(av_cardno VARCHAR2, --卡号
                              av_card   OUT card_baseinfo%ROWTYPE, --卡片基本信息
                              av_res    OUT VARCHAR2, --传出参数代码
                              av_msg    OUT VARCHAR2 --传出参数错误信息
                              );
  /*=======================================================================================*/
  --根据卡号查找卡类型
  /*=======================================================================================*/
  FUNCTION f_getcardtypebycardno(av_cardno VARCHAR2 --卡号
                                 ) RETURN VARCHAR2;
  /*=======================================================================================*/
  --根据账号和卡号查找账户类型
  /*=======================================================================================*/
  FUNCTION f_getacckindbyaccnoandcardno(av_accno  acc_account_sub.acc_no%TYPE, --账号
                                        av_cardno VARCHAR2 --卡号
                                        ) RETURN VARCHAR2;
  /*=======================================================================================*/
  --根据卡类型查卡参数表
  /*=======================================================================================*/
  PROCEDURE p_getcardparabycardtype(av_cardtype VARCHAR2, --卡类型
                                    av_para     OUT card_config%ROWTYPE, --卡参数表
                                    av_res      OUT VARCHAR2, --传出参数代码
                                    av_msg      OUT VARCHAR2 --传出参数错误信息
                                    );
  /*=======================================================================================*/
  --判断卡交易密码
  /*=======================================================================================*/
  PROCEDURE p_judgetradepwd(av_card card_baseinfo%ROWTYPE, --卡信息
                            av_pwd  VARCHAR2, --密码
                            av_res  OUT VARCHAR2, --传出参数代码
                            av_msg  OUT VARCHAR2 --传出参数错误信息
                            );

  /*=======================================================================================*/
  --判断个人服务密码
  /*=======================================================================================*/
  PROCEDURE p_judgeservicepwd(av_cert_no VARCHAR2, --证件号码
                            av_customer_name VARCHAR2,--姓名
                            av_pwd  VARCHAR2, --密码
                            av_res  OUT VARCHAR2, --传出参数代码
                            av_msg  OUT VARCHAR2 --传出参数错误信息
                            );
  PROCEDURE p_judgepaypwd(av_card_no VARCHAR2, --卡号
                        av_pwd  VARCHAR2, --密码
                        av_res  OUT VARCHAR2, --传出参数代码
                        av_msg  OUT VARCHAR2 --传出参数错误信息
                        );
  PROCEDURE p_judgeacpt(av_acpt_type VARCHAR2,--受理点类型
                        av_acpt_id  VARCHAR2, --受理点编号/网点编号
                        av_user_id  VARCHAR2, --终端号/操作员
                        av_res  out varchar2,--传入代码
                        av_msg  OUT VARCHAR2 --传出参数错误信息
                        ) ;
  /*=======================================================================================*/
  --判断预存款限额
  /*=======================================================================================*/
  PROCEDURE p_judgebranchagentlimit(av_brchid  VARCHAR2, --网点编号
                                    av_balance NUMBER, --扣除金额后的预存款余额
                                    av_res     OUT VARCHAR2, --传出参数代码
                                    av_msg     OUT VARCHAR2 --传出参数错误信息
                                    );
  /*=======================================================================================*/
  --判断卡状态下该交易是否准许
  /*=======================================================================================*/
  PROCEDURE p_judgecardstatebandeal(av_card_no  VARCHAR2, --卡号
                                    av_deal_code VARCHAR2, --交易代码
                                    av_res     OUT VARCHAR2, --传出参数代码
                                    av_msg     OUT VARCHAR2 --传出参数错误信息
                                    );
  /*=======================================================================================*/
  --判断某个账户类型和卡号判断次交易是否正确
  /*=======================================================================================*/
  PROCEDURE p_judgecardacciftrade(av_card_no  VARCHAR2, --卡号
                                    av_acc_kind VARCHAR2, --交易代码
                                    av_amt      VARCHAR2,--交易金额
                                    av_pwd_falg  NUMBER,--交易是否输入密码 0 是 1 否
                                    av_res     OUT VARCHAR2, --传出参数代码
                                    av_msg     OUT VARCHAR2 --传出参数错误信息
                                    );
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
                           );
  /*=======================================================================================*/
  --根据传入的sql数组执行sql
  /*=======================================================================================*/
  PROCEDURE p_dealsqlbyarray(av_varlist IN strarray);
  /*=======================================================================================*/
  --获取两个时间戳毫秒差
  /*=======================================================================================*/
  FUNCTION f_timestamp_diff(endtime IN TIMESTAMP, starttime IN TIMESTAMP)
    RETURN INTEGER;
   /*=======================================================================================*/
  --构造第二卡号校验位
  /*=======================================================================================*/

    FUNCTION createSubCardNo(prefix in varchar2,seq in varchar2) return varchar2;


    /*====================================================================================
    根据客户编号获取客户信息
    */
    PROCEDURE p_getBasePersonalByCustomerId(av_customer_id BASE_PERSONAL.CUSTOMER_ID%TYPE,
                                            av_base_personal OUT base_personal%ROWTYPE,
                                            av_res OUT VARCHAR2,
                                            av_msg OUT VARCHAR2);
    /*====================================================================================
    根据证件号码获取客户信息
    */
    PROCEDURE p_getBasePersonalByCertNo(av_cert_no BASE_PERSONAL.CERT_NO%TYPE,
                                        av_base_personal OUT base_personal%ROWTYPE,
                                        av_res OUT VARCHAR2,
                                        av_msg OUT VARCHAR2);
END pk_public;
/

