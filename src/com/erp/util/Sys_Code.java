package com.erp.util;

public class Sys_Code {
	public static String ACC_KIND_PTZH="00";//普通账户
	public static String ACC_KIND_QBZH="01";//钱包账户
	public static String ACC_KIND_ZJZH="02";//资金账户
	public static String ACC_KIND_JFZH="03";//积分账户
	public static String ACC_KIND_CZKZH="07";//充值卡账户
	public static String ACC_KIND_WQCZH="09";//未圈存账户
	public static String ACC_KIND_YJZH="10";//押金账户
	public static String ACC_STATE_ZC="1";//正常
	public static String ACC_STATE_KTGS="2";//口头挂失
	public static String ACC_STATE_SMGS="3";//书面挂失
	public static String ACC_STATE_ZX="9";//注销
	public static String ACPT_TYPE_SH="0";//商户
	public static String ACPT_TYPE_WD="1";//网点
	public static String ALM_ERR_REASON_PWD_ERR="01";//密码错误
	public static String ALM_ERR_REASON_OUT_OF_FUND="02";//余额不足
	public static String ALM_ERR_REASON_R01_1BIZ_1CARD_AMT_1DAY="R01";//同一商户当日同一卡号交易金额合计超额
	public static String ALM_ERR_REASON_R02_1BIZ_1CARD_CNT_1DAY="R02";//同一商户同卡号笔数超过
	public static String ALM_ERR_REASON_R03="R03";//备用
	public static String ALM_ERR_REASON_R04_1BIZ_1AMT_ERR_CNT_1DAY="R04";//同一商户当日有超过一笔同金额超限额交易且其中有失败交易笔数
	public static String ALM_ERR_REASON_R05_1BIZ_1AMT_CNT_1DAY="R05";//同一商户当日相同金额交易超笔数
	public static String ALM_ERR_REASON_R06_1BIZ_AMT_1DAY="R06";//同一商户日交易量总金额超最大值
	public static String ALM_ERR_REASON_R07_1BIZ_CNT_1DAY="R07";//同一商户日交易总笔数超最大值
	public static String ALM_ERR_REASON_R08_1BIZ_1AMT_REP_CNT_MDAY="R08";//同一商户相同金额的重复交易笔数超最大值
	public static String ALM_ERR_REASON_R09_1CARD_CNT_MDAY="R09";//3日内，同一卡号交易笔数超最大值
	public static String ALM_ERR_REASON_R10_1CARD_AMT_MDAY="R10";//3日内，同一卡号超交易金额超最大值
	public static String ALM_ERR_REASON_R11_1BIZ_1CARD_1CNT_AMT_1DAY="R11";//同一商户当日同一卡号单笔金额超最大值
	public static String ALM_ERR_REASON_R12_1BIZ_1CARD_CNT_MDAY="R12";//3日内，同一卡号同一商户交易笔数超最大值
	public static String ALM_ERR_REASON_R13_1BIZ_1CARD_AMT_MDAY="R13";//3日内，同一卡号同一商户交易金额超最大值
	public static String ALM_STATE_YX="0";//有效
	public static String ALM_STATE_WX="1";//无效
	public static String ALM_TYPE_KY="1";//可疑
	public static String ALM_TYPE_SB="2";//失败
	public static String APPLY_STATE_YSQ="0";//已申请
	public static String APPLY_STATE_RWYSC="1";//任务已生成
	public static String APPLY_STATE_ZKZ="2";//制卡中
	public static String APPLY_STATE_YZK="3";//已制卡
	public static String APPLY_STATE_YPS="4";//已配送
	public static String APPLY_STATE_YJS="5";//已接收
	public static String APPLY_STATE_YFF="6";//已发放
	public static String APPLY_STATE_YTK="7";//已退卡
	public static String APPLY_STATE_YHS="8";//已回收
	public static String APPLY_STATE_ZX="9";//注销
	public static String BAL_ATTR_JF="1";//借方
	public static String BAL_ATTR_DF="2";//贷方
	public static String BAL_ATTR_SF="3";//双方
	public static String BAL_RESULT_WCL="0";//未处理
	public static String BAL_RESULT_FX="1";//返现
	public static String BAL_RESULT_KKZZ="2";//卡卡转账
	public static String BAL_RESULT_CZ="3";//残值
	public static String BAL_RESULT_TZHK="7";//透支已还款
	public static String BLK_STATE_YX="0";//有效
	public static String BLK_STATE_WX="1";//无效
	public static String BLK_TYPE_GS="01";//挂失
	public static String BLK_TYPE_ZX="09";//注销
	public static String BRCH_LEVEL_YJ="1";//一
	public static String BRCH_LEVEL_EJ="2";//二
	public static String BRCH_LEVEL_SJ="3";//三
	public static String BRCH_TYPE_ZY="1";//自有网点
	public static String BRCH_TYPE_ZZ="2";//自助网点
	public static String BRCH_TYPE_DL="3";//代理网点
	public static String CANCEL_REASON_SWTK="1";//死亡退卡
	public static String CANCEL_REASON_TK="2";//退卡
	public static String CANCEL_REASON_DSBK="3";//丢失补卡
	public static String CANCEL_REASON_HK="4";//换卡
	public static String CARD_STATE_WQY="0";//未启用
	public static String CARD_STATE_ZC="1";//正常
	public static String CARD_STATE_KTGS="2";//口头挂失
	public static String CARD_STATE_SMGS="3";//书面挂失
	public static String CARD_STATE_ZX="9";//注销
	public static String CARD_TYPE_300="300";//菜市通卡
	public static String CARD_TYPE_310="310";//商户卡
	public static String CARD_TYPE_500="500";//菜市通非记名卡
	public static String CARD_TYPE_802="802";//20充值卡
	public static String CARD_TYPE_805="805";//50充值卡
	public static String CARD_TYPE_810="810";//100充值卡
	public static String CARD_TYPE_820="820";//200充值卡
	public static String CARD_TYPE_850="850";//500充值卡
	public static String CARD_TYPE_CATALOG_QGN="1";//全功能卡
	public static String CARD_TYPE_CATALOG_JMGX="2";//记名个性卡
	public static String CARD_TYPE_CATALOG_JMFGX="3";//记名非个性卡
	public static String CARD_TYPE_CATALOG_FJM="5";//非记名卡
	public static String CARD_TYPE_CATALOG_BCP="7";//半成品卡
	public static String CARD_TYPE_CATALOG_CZ="8";//充值卡
	public static String CARD_TYPE_CATALOG_LP="9";//礼品卡
	public static String CARD_VIP_PTK="0";//普通卡
	public static String CARD_VIP_VIP="1";//VIP卡
	public static String CERT_TYPE_SFZ="1";//身份证
	public static String CERT_TYPE_HKB="2";//户口簿
	public static String CERT_TYPE_JGZ="3";//军官证
	public static String CERT_TYPE_HZ="4";//护照
	public static String CERT_TYPE_HJZM="5";//户籍证明
	public static String CERT_TYPE_QT="6";//其他
	public static String CHG_CARD_REASON_ZLWT="01";//质量问题
	public static String CHG_CARD_REASON_SH="02";//损坏
	public static String CHG_CARD_REASON_QT="99";//其他
	public static String CHK_FLAG_WSH="0";//未审核
	public static String CHK_FLAG_YSH="1";//已审核
	public static String CLIENT_HAVE_ONLY="0";//一张卡
	public static String CLIENT_HAVE_MORE="1";//多张卡
	public static String CLIENT_TYPE_WD="0";//网点
	public static String CLIENT_TYPE_GRORK="1";//个人/卡
	public static String CLIENT_TYPE_DW="2";//单位
	public static String CLIENT_TYPE_SH="3";//商户
	public static String CLIENT_TYPE_JG="4";//机构
	public static String CLIENT_TYPE_SALE_GR="1";//个人
	public static String CLIENT_TYPE_SALE_DW="2";//单位
	public static String COIN_TYPE_RMB="1";//人民币
	public static String COIN_TYPE_JF="2";//积分
	public static String DAYBAL_TYPE_GR="1";//柜员
	public static String DAYBAL_TYPE_WD="2";//网点
	public static String DAYBAL_TYPE_JG="3";//机构
	public static String DAY_BAL_FLAG_Y="0";//已轧账
	public static String DAY_BAL_FLAG_N ="1";//未轧账
	public static String DISPATCH_WAY_ZKRW="1";//制卡任务配送
	public static String DISPATCH_WAY_HD="2";//号段配送
	public static String DIV_TYPE_BL="0";//比例
	public static String DIV_TYPE_DZ="1";//定值
	public static String DRW_FLAG_WQ="0";//未取
	public static String DRW_FLAG_YQ="1";//已取
	public static String ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD="0";//充值(加)
	public static String ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB="1";//消费(减)
	public static String ENCRYPT_SERVICE_CODE_ENCRYPTPIN="0101";//加密密码
	public static String ENCRYPT_SERVICE_CODE_CHANGEPIN="0102";//密码转换
	public static String ENCRYPT_SERVICE_CODE_ENCRYPTMONEY="0103";//加密金额
	public static String ENCRYPT_SERVICE_CODE_MONEYCAL="0104";//金额运算
	public static String ENCRYPT_SERVICE_CODE_CARDNO_VERIFYCODE="0102";//生成卡号校验位
	public static String ENCRYPT_SERVICE_CODE_CREATE_CARD_PIN="0106";//生成/验证卡密码明文，充值卡用
	public static String ENCRYPT_SERVICE_CODE_CHECKTAC="0107";//TAC验证
	public static String ENCRYPT_SERVICE_CODE_RECHARGE_MAC2="0108";//生成充值MAC2
	public static String ENCRYPT_SERVICE_CODE_MODIFY_MAC="0109";//生成修改卡信息MAC
	public static String ENCRYPT_SERVICE_CODE_WORKKEY="0101";//取工作密钥
	public static String ENCRYPT_SERVICE_CODE_MAINKEY="0100";//取主密钥
	public static String ENCRYPT_SERVICE_CODE_CREATE_CARD_ENCRYPTPIN="2";//生成卡密码密文，消费卡，暂未开
	public static String FEE_CONF_YW="0";//按业务收费
	public static String FEE_CONF_DS="1";//定时收费
	public static String FEE_FREQUENCY_Z="0";//日
	public static String FEE_FREQUENCY_R="1";//周
	public static String FEE_FREQUENCY_Y="2";//月
	public static String FEE_FREQUENCY_J="3";//季
	public static String FEE_FREQUENCY_BN="4";//半年
	public static String FEE_FREQUENCY_N="5";//年
	public static String FEE_RATE_TYPE_BSFL="1";//笔数费率
	public static String FEE_RATE_TYPE_JEFL="2";//金额费率
	public static String FEE_RATE_TYPE_GDFL="3";//固定费率
	public static String FEE_STATE_ZY="0";//在用
	public static String FEE_STATE_TY="1";//停用
	public static String FEE_TYPE_FWF="1";//服务费
	public static String FEE_TYPE_YJ="2";//押金
	public static String FEE_TYPE_GBF="3";//工本费
	public static String FEE_TYPE_SXF="4";//手续费
	public static String FEE_TYPE_ITEM_FWF="1";//703101
	public static String FEE_TYPE_ITEM_YJ="2";//201105
	public static String FEE_TYPE_ITEM_GBF="3";//702101
	public static String FEE_TYPE_ITEM_SXF="4";//701101
	public static String FRZ_FLAG_ZC="0";//正常
	public static String FRZ_FLAG_BFDJ="1";//部分冻结
	public static String FRZ_FLAG_QBDJ="2";//全部冻结
	public static String GIFT_GET_WAY_YJ="1";//邮寄
	public static String GIFT_GET_WAY_ZT="2";//自提
	public static String GIFT_GET_WAY_JK="9";//均可
	public static String GIFT_SEND_STATE_WFH="0";//未发货
	public static String GIFT_SEND_STATE_YFH="1";//已发货
	public static String GIFT_SEND_STATE_YSH="9";//已收货
	public static String GOODS_STATE_ZC="0";//正常
	public static String GOODS_STATE_HSDCL="1";//回收卡待处理
	public static String GOODS_STATE_BF="9";//报废
	public static String HASEFFECT_YSX="0";//当前生效
	public static String HASEFFECT_WSX="1";//未生效
	public static String HAVE_SECTION_S="0";//是
	public static String HAVE_SECTION_F="1";//否
	public static String IMPEXP_CATEGORY_DC="0";//导出
	public static String IMPEXP_CATEGORY_DR="1";//导入
	public static String INDUS_LEVEL_YJ="1";//第一级
	public static String INDUS_LEVEL_EJ="2";//第二级
	public static String INDUS_LEVEL_SJ="3";//第三级
	public static String INV_FLAG_WK="0";//未开
	public static String INV_FLAG_YK="1";//已开
	public static String IN_OUT_FLAG_IN="1";//收
	public static String IN_OUT_FLAG_OUT="2";//付
	public static String IN_OUT_FLAG_INOUT="3";//收付
	public static String ITEM_LVL_YJ="1";//一级
	public static String ITEM_LVL_EJ="2";//二级
	public static String ITEM_LVL_SJ="3";//三级
	public static String LOGIN_FLAG_QT="0";//签退
	public static String LOGIN_FLAG_QD="1";//签到
	public static String LOGIN_FLAG_SS="2";//上送
	public static String LOGIN_FLAG_DZ="3";//对账
	public static String LSS_TYPE_KTGS="2";//口头挂失
	public static String LSS_TYPE_SMGS="3";//书面挂失
	public static String Log_Type_0="0";//登录
	public static String Log_Type_1="1";//下线
	public static String Log_Type_2="2";//签到
	public static String Log_Type_3="3";//签退
	public static String Log_Type_4="4";//锁定
	public static String Log_Type_5="5";//解锁
	public static String MAKE_TYPE_XCZK="0";//现场发卡
	public static String MAKE_TYPE_HXZK="1";//后续制卡
	public static String MAKE_WAY_WB="1";//外包
	public static String MAKE_WAY_BD="2";//本地
	public static String MARKET_CHANGE_STATE_WSX="0";//未生效
	public static String MARKET_CHANGE_STATE_ZC="1";//正常
	public static String MARKET_CHANGE_STATE_YSX="2";//已失效
	public static String MARKET_LEVEL_YJSC="1";//一级市场
	public static String MARKET_LEVEL_ZJSC="2";//二级市场
	public static String MARKET_LEVEL_SJSC="3";//三级市场
	public static String MARKET_STATE_ZC="0";//正常
	public static String MARKET_STATE_ZX="1";//注销
	public static String MARKET_TYPE_ZHCSC="1";//综合菜市场
	public static String MARKET_TYPE_SCSC="2";//蔬菜市场
	public static String MARKET_TYPE_SGSC="3";//水果市场
	public static String MERCHANT_STATE_ZC="0";//正常
	public static String MERCHANT_STATE_ZX="1";//注销
	public static String MERCHANT_STATE_DSH="2";//待审核
	public static String OPER_LEVEL_YBGY="0";//一般柜员
	public static String OPER_LEVEL_WDZG="1";//网点主管
	public static String OPER_LEVEL_WDJZWD="2";//网点及子网点
	public static String OPER_LEVEL_JGQX="3";//当前机构
	public static String OPER_LEVEL_JGJZJG="4";//机构及子机构
	public static String OPER_LEVEL_SYSJQX="9";//所有数据权限
	public static String ORG_CLASS_YIJ="1";//总公司
	public static String ORG_CLASS_ERJ="2";//省级
	public static String ORG_CLASS_SANJ="3";//市级
	public static String ORG_CLASS_SIJ="4";//子机构
	public static String ORG_TYPE_FKJG="01";//发卡机构
	public static String ORG_TYPE_QSJG="02";//清算机构
	public static String ORG_TYPE_SDJG="03";//收单机构
	public static String ORG_TYPE_JJTZF="04";//机具投资方
	public static String ORG_TYPE_YH="05";//银行
	public static String ORG_TYPE_YL="06";//银联
	public static String OWN_TYPE_GY="0";//柜员
	public static String OWN_TYPE_KH="1";//客户
	public static String PAY_FLAG_WF="0";//未付
	public static String PAY_FLAG_YFZPWQR="1";//已付支票未确认
	public static String PAY_FLAG_BFZF="8";//部分支付
	public static String PAY_FLAG_YF="9";//已付
	public static String PAY_SOURCE_XJ="0";//现金
	public static String PAY_SOURCE_ZZ="1";//转账/银行卡
	public static String PAY_SOURCE_CZK="2";//充值卡
	public static String PAY_SOURCE_CX="3";//促销
	public static String PAY_SOURCE_XY="4";//更改信用额度
	public static String PAY_STATE_DK="1";//已打款
	public static String PAY_STATE_QR="2";//银行确认
	public static String PAY_STATE_TH="3";//银行退回
	public static String PAY_WAY_XJ="1";//现金
	public static String PAY_WAY_HK="2";//汇款
	public static String PAY_WAY_ZP="3";//支票
	public static String PER_OR_BIZ_GR="0";//个人
	public static String PER_OR_BIZ_SH="1";//商户
	public static String POINTS_EXCHANGE_RULE_ACC="1";//积分转账户
	public static String POINTS_EXCHANGE_RULE_GIFT="2";//积分兑礼品
	public static String POINTS_PERIOD_RULE_DAY="1";//天
	public static String POINTS_PERIOD_RULE_MONTH="2";//月
	public static String POINTS_PERIOD_RULE_SEASON="3";//季
	public static String POINTS_PERIOD_RULE_YEAR="4";//年
	public static String POSP_PROC_FLAG_TJJY="00";//脱机
	public static String POSP_PROC_FLAG_LJJY="01";//联机
	public static String PRESET_Y="0";//是
	public static String PRESET_N="1";//否
	public static String PWD_RULE_CL="0";//常量
	public static String PWD_RULE_ZJHM6W="1";//证件号末6位
	public static String PWD_RULE_SJHM6W="2";//手机号末6位
	public static String PWD_TYPE_FWMM="1";//服务密码
	public static String PWD_TYPE_JYMM="2";//交易密码
	public static String QUERY_TYPE_YEAR="0";//年
	public static String QUERY_TYPE_MONTH="1";//月
	public static String QUERY_TYPE_WEEK="2";//周
	public static String RECHARGE_STEP_1="1";//充值第一步
	public static String RECHARGE_STEP_2="2";//充值第二步
	public static String RECHG_STATE_WSY="0";//未使用
	public static String RECHG_STATE_WJH="1";//未激活
	public static String RECHG_STATE_YJH="2";//已激活
	public static String RECHG_STATE_YSY="3";//已使用
	public static String RECHG_STATE_YZX="9";//已注销
	public static String REISSUE_CHG_FLAG_BK="1";//补卡
	public static String REISSUE_CHG_FLAG_HK="2";//换卡
	public static String RET_BAL_PRECI_QB="0";//全部
	public static String RET_BAL_PRECI_J="1";//角
	public static String RET_BAL_PRECI_Y="2";//元
	public static String RET_BAL_TYPE_BH="1";//补换
	public static String RET_BAL_TYPE_SH="2";//赎回
	public static String RET_WAY_CANCEL_FX="1";//返现
	public static String RET_WAY_CANCEL_KKZZ="2";//卡卡转账
	public static String RET_WAY_CANCEL_CZ="3";//残值
	public static String RET_WAY_CANCEL_BCL="8";//不处理
	public static String RET_WAY_CANCEL_JK="9";//均可
	public static String RET_WAY_CHANGE_FX="1";//返现
	public static String RET_WAY_CHANGE_KKZZ="2";//卡卡转账
	public static String RET_WAY_CHANGE_CZ="3";//残值
	public static String RET_WAY_CHANGE_BCL="8";//不处理
	public static String RET_WAY_CHANGE_JK="9";//均可
	public static String SALELIST_STATE_WQY="0";//未启用[未激活]
	public static String SALELIST_STATE_ZC="1";//正常[已激活]
	public static String SALELIST_STATE_CX="8";//撤销[销售撤销]
	public static String SALELIST_STATE_TK="9";//退卡[已注销退卡]
	public static String SALE_STATE_ZC="0";//正常
	public static String SALE_STATE_CX="1";//撤销
	public static String SELF_STL_ZJ="0";//自己结算
	public static String SELF_STL_SJ="1";//上级结算
	public static String SH_STATE_ZCYSH="0";//正常（已审核）
	public static String SH_STATE_ZX="1";//注销
	public static String SH_STATE_DSH="9";//待审核
	public static String SND_FLAG_BS="0";//不送
	public static String SND_FLAG_DS="1";//待送
	public static String SND_FLAG_ZZS="2";//正在送
	public static String SND_FLAG_YSD="3";//已送达
	public static String STATE_ZC="0";//正常
	public static String STATE_ZX="1";//注销
	public static String STAT_ACPT_TYPE_BRCH="1";//网点
	public static String STAT_ACPT_TYPE_BIZ="2";//商户
	public static String STAT_TYPE_GY="1";//柜员
	public static String STAT_TYPE_WD="2";//网点
	public static String STK_SEND_STATE_YES="0";//已确认
	public static String STK_SEND_STATE_NO="1";//未确认
	public static String STK_SEND_STATE_RET="2";//已退库
	public static String STK_TYPE_ZNK="1";//智能卡
	public static String STL_STATE_JS="0";//待审核
	public static String STL_STATE_SH="1";//已审核
	public static String STL_STATE_DC="2";//已导出
	public static String STL_STATE_ZF="9";//已支付
	public static String STL_WAY_AAAjSRAAVAAEChmACQ="01";//日结
	public static String STL_WAY_AAAjSRAAVAAEChmACR="02";//限额结
	public static String STL_WAY_AAAjSRAAVAAEChmACS="03";//周结
	public static String STL_WAY_AAAjSRAAVAAEChmACT="04";//月结
	public static String STL_WAY_AAAjSRAAVAAEChmACU="05";//日结+月结
	public static String STL_WAY_AAAjSRAAVAAEChmACV="06";//限额结+月结
	public static String STOCK_OUTFLAG_OPER="0";//柜员
	public static String STOCK_OUTFLAG_BRCH="1";//网点
	public static String TASK_SRC_LXSLHZ="0";//零星申领汇总
	public static String TASK_SRC_GMSL="1";//规模申领
	public static String TASK_SRC_FGXHCG="2";//非个性化采购任务
	public static String TASK_STATE_RWYSC="0";//任务已生成
	public static String TASK_STATE_ZKZ="1";//制卡中
	public static String TASK_STATE_YZK="2";//已制卡
	public static String TASK_STATE_YPS="3";//已配送
	public static String TASK_STATE_YJS="4";//已接收
	public static String TASK_STATE_FKGCZ="5";//发卡过程中
	public static String TASK_STATE_YFF="9";//已发放
	public static String TASK_WAY_WD="0";//网点
	public static String TASK_WAY_SQ="1";//社区
	public static String TASK_WAY_DW="2";//单位
	public static String TERM_ACPT_TYPE_SH="0";//商户
	public static String TERM_ACPT_TYPE_WD="1";//网点
	public static String TERM_FLAG_0="0";//签退
	public static String TERM_FLAG_1="1";//签到
	public static String TERM_FLAG_2="2";//上送
	public static String TERM_FLAG_3="3";//对账
	public static String TERM_OFFER_GM="1";//自购
	public static String TERM_OFFER_ZY="2";//租用
	public static String TERM_STATE_WQY="0";//未启用
	public static String TERM_STATE_QY="1";//启用
	public static String TERM_STATE_ZX="9";//注销
	public static String TERM_TRADE_CONF_TYPE_BRCH="1";//按网点
	public static String TERM_TRADE_CONF_TYPE_BIZ="2";//按商户
	public static String TERM_TRADE_CONF_TYPE_TERM="3";//按终端
	public static String TERM_TYPE_RA="1";//人工
	public static String TERM_TYPE_ZZ="2";//自助
	public static String TERM_TYPE_XN="9";//虚拟
	public static String TERM_USAGE_ZF="1";//支付终端
	public static String TERM_USAGE_FZF="2";//非支付终端
	public static String TRCODE_TYPE_CXYW="09";//促销业务
	public static String TRCODE_TYPE_KZGL="10";//库账管理
	public static String TRCODE_TYPE_GMFW="11";//柜面服务
	public static String TRCODE_TYPE_KHFW="12";//客户服务
	public static String TRCODE_TYPE_SHGL="13";//商户管理
	public static String TRCODE_TYPE_ZHGL="14";//账户管理
	public static String TRCODE_TYPE_ZKJH="15";//制卡计划
	public static String TRCODE_TYPE_ZJYW="16";//中间业务
	public static String TRCODE_TYPE_JFGL="17";//积分管理
	public static String TRCODE_TYPE_KHXX="18";//客户信息
	public static String TRCODE_TYPE_CXTJ="70";//查询统计
	public static String TRCODE_TYPE_JKFW="80";//接口服务
	public static String TRCODE_TYPE_XFJK="81";//消费接口
	public static String TRCODE_TYPE_XTGL="90";//系统管理
	public static String TR_DAY_BAL_DATATYPE_JE="1";//金额
	public static String TR_DAY_BAL_DATATYPE_JF="2";//积分
	public static String TR_DAY_BAL_DATATYPE_SL="3";//数量
	public static String TR_STATE_ZC="0";//正常
	public static String TR_STATE_CX="1";//撤销
	public static String TR_STATE_CZ="2";//冲正
	public static String TR_STATE_TH="3";//退货
	public static String TR_STATE_HJL="9";//灰记录
	public static String TYPE_LEVEL_LPDJ1="1";//一级
	public static String TYPE_LEVEL_LPDJ2="2";//二级
	public static String TYPE_LEVEL_LPDJ3="3";//三级
	public static String TYPE_LEVEL_LPDJ4="4";//四级
	public static String UNIT_OF_MEASURE_GE="1";//个
	public static String UNIT_OF_MEASURE_FU="10";//副
	public static String UNIT_OF_MEASURE_ZHA="11";//扎
	public static String UNIT_OF_MEASURE_DA="12";//打
	public static String UNIT_OF_MEASURE_PI="13";//匹
	public static String UNIT_OF_MEASURE_DAI="14";//袋
	public static String UNIT_OF_MEASURE_BU="15";//部
	public static String UNIT_OF_MEASURE_TAO="16";//套
	public static String UNIT_OF_MEASURE_JUAN="17";//卷
	public static String UNIT_OF_MEASURE_ZU="18";//组
	public static String UNIT_OF_MEASURE_SHUANG="19";//双
	public static String UNIT_OF_MEASURE_JIN="20";//斤
	public static String UNIT_OF_MEASURE_GUAN="21";//罐
	public static String UNIT_OF_MEASURE_BAO="22";//包
	public static String UNIT_OF_MEASURE_PING="23";//瓶
	public static String UNIT_OF_MEASURE_JIA="24";//件
	public static String UNIT_OF_MEASURE_DUI="3";//对
	public static String UNIT_OF_MEASURE_SHENG="4";//升
	public static String UNIT_OF_MEASURE_XIANG="5";//箱
	public static String UNIT_OF_MEASURE_TONG="6";//桶
	public static String UNIT_OF_MEASURE_BEN="7";//本
	public static String UNIT_OF_MEASURE_HE="8";//盒
	public static String UNIT_OF_MEASURE_ZHI="9";//只
	public static String URGENT_BD="0";//本地制卡
	public static String URGENT_WB="1";//外包制卡
	public static String URGENT_BDJJ="2";//本地加急
	public static String URGENT_WBJJ="3";//外包加急
	public static String USED_YSY="0";//已使用
	public static String USED_WSY="1";//未使用
	public static String USER_TYPE_OPER="0";//柜员
	public static String USER_TYPE_TERM="1";//终端
	public static String VRF_FLAG_BP="0";//不批
	public static String VRF_FLAG_DP="1";//待批
	public static String VRF_FLAG_YP="2";//已批
	public static String YES_NO_YES="0";//是
	public static String YES_NO_NO="1";//否
}