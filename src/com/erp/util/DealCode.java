package com.erp.util;

public class DealCode {	
	//+++++++++++++++++++++++++++++++++++++++++合作机构管理类+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer CO_ORG_MANAGER_ADD=10301010;//合作机构新增
	public static final Integer CO_ORG_MANAGER_EDIT=10301020;//合作机构编辑
	public static final Integer CO_ORG_MANAGER_PASS=10301030;//合作机构审核通过
	public static final Integer CO_ORG_MANAGER_NOPASS=10301040;//合作机构审核不通过
	public static final Integer CO_ORG_MANAGER_ZX=10301050;//合作机构注销
	public static final Integer CO_ORG_MANAGER_QY=10301060;//合作机构启用
	
	//+++++++++++++++++++++++++++++++++++++++基本业务类10+++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer MERCHANTTYPE_SAVE=10202010;//商户管理_商户类型管理
	public static final Integer MERCHANT_MAINKEY=10202020;//商户管理_主密钥卡发卡
	public static final Integer MERCHANT_RATE_PREINSTALL_ADD=10202030;//商户管理_商户费率预设新增
	public static final Integer MERCHANT_RATE_PREINSTALL_EDIT=10202040;//商户管理_商户费率预设新增
	public static final Integer MERCHANT_RATE_PREINSTALL_DELETE=10202050;//商户管理_商户费率预设删除
	public static final Integer MERCHANT_RATE_PREINSTALL_AUDIT=10202060;//商户管理_商户费率预设审核
	public static final Integer MERCHANT_RATE_PREINSTALL_WORKNOW=10202070;//商户管理_商户费率预设立即生效
	public static final Integer SETTLEMENT_MODE_ADD=10202080;//商户结算模式新增
	public static final Integer SETTLEMENT_MODE_EIDT=10202090;//商户结算模式编辑
	public static final Integer SETTLEMENT_MODE_DEL=10202100;//商户结算模式删除
	public static final Integer MERCHANT_ACCKIND_LMT=10202110;//商消费账户关联
	public static final Integer MERCHANT_CONSUME_LMT=10202120;//商消费模式设置
	public static final Integer MERCHANT_DISCOUNT = 10202190;// 商户折扣率管理
	public static final Integer MERCHANT_SETTLEMENT_PAYMENT=10202130;//商户结算
	public static final Integer TERMINAL_ADD=10202140;//终端添加
	public static final Integer TERMINAL_BATCH_ADD=10202141;//终端批量添加
	public static final Integer TERMINAL_CANCEL=10202150;//终端注销
	public static final Integer TERMINAL_EDIT=10202160;//终端修改
	public static final Integer CONSUMEMODE_ADD=10202170;//消费模式新增
	public static final Integer CONSUMEMODE_EDIT=10202180;//消费修改模式
	
	//+++++++++++++++++++++++++++++++++++++++客户+++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer BASE_DATA_SJCJ_ADD = 10101010;//人员基本信息新增
	public static final Integer BASE_DATA_SJCJ_EDIT = 10101020;//人员基本信息编辑
	public static final Integer PHOTO_IMPORT_SIGNONE=10101060;//单个照片导入
	public static final Integer PHOTO_IMPORT_READCERT=10101070;//读身份证照片导入
	public static final Integer PHOTO_IMPORT_ZIPFILE =10101080;//批量照片导入
	public static final Integer STOCK_TYPE_ADD = 10501010;//库存类型新增
	public static final Integer STOCK_TYPE_DEL = 10501021;//库存类型删除
	public static final Integer STOCK_TYPE_EDIT = 10501030;//库存类型编辑
	public static final Integer STOCK_TYPE_ENABLE = 10501040;//库存类型启用
	public static final Integer STOCK_TYPE_DISABLE = 10501051;//库存类型禁用
	public static final Integer STOCK_ACC_OPEN = 10501090;//库存账户开户
	public static final Integer STOCK_DELIVERY = 10502010;//库存配送
	public static final Integer STOCK_DELIVERY_CONFIRM = 10502020;//库存配送确认
	public static final Integer STOCK_DELIVERY_CANCEL = 10502031;//库存配送取消
	public static final Integer STOCK_TELLER_RECEIVE = 10502040;//柜员领用
	public static final Integer STOCK_TELLER_TRANSITIONMAIN = 10502050;//柜员交接
	public static final Integer STOCK_IMPORT_SMK = 10502060;//实名制卡导入
	public static final Integer STOCK_LXIMPORT_SMK = 10502070;//本地制卡导入
	public static final Integer STOCK_UNUSE_CARD_REG = 10502080;//废卡登记
	public static final Integer STOCK_CANCEL_CARD_REG = 10502090;//本地制卡取消制卡
	
	//+++++++++++++++++++++++++++++++++++++++商户+++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer MERCHANT_ARCHIVES_CONSUME_MODE_ADD = 10201410;//商户消费模式新增
	public static final Integer MERCHANT_ARCHIVES_CONSUME_MODE_EDIT = 10201420;//商户消费模式修改
	public static final Integer MERCHANT_ADD=10201010;// 商户新增1010	10201010
	public static final Integer MERCHANT_EDIT=10201020;//商户编辑1020	10201020
	public static final Integer MERCHANT_CHECK_YES=10201030;//商户审核通过1030	10201030
	public static final Integer MERCHANT_CHECK_NO=10201040;//商户审核不通过1040	10201040
	public static final Integer MERCHANT_ZX=10201050;//商户注销1050	10201050
	public static final Integer MERCHANT_START=10201060;//商户启用1060	10201060
	public static final Integer MERCHANT_CANCEL=10201070;//商户暂停1070	10201070
	
	
	public static final Integer CARD_PRODUCT=10901010;//卡片档案
	public static final Integer BASE_PROVIDER=10901020;//供应商管理
	public static final Integer BASE_PSAM=10901030;//PSAM卡管理
	public static final Integer BASE_VENDOR=10301080;//卡商管理
	//+++++++++++++++++++++++++++++++++++++++卡管理类20 管理类+++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer APPLY_TYPE_GMSL=20401030;//批量申领
	public static final Integer APPLY_TYPE_GMSL_VIEW=20401031;//批量申领预览
	public static final Integer APPLY_TYPE_GMSL_SAVE=20401032;//批量申领预览保存
	public static final Integer APPLY_TYPE_LXSL=20401010;//个人申领1010	20401010
	public static final Integer APPLY_TYPE_BCPKSL=20402010;//半成品卡申领
	public static final Integer APPLY_TYPE_READ=20401020;//读身份证申领1020	20401020
	public static final Integer APPLY_TYPE_IMPORT=20401040;//导入申领1040	20401040
	public static final Integer APPLY_TYPE_QUERY=20401070;//申领查询1070	20401070
    public static final Integer APPLY_TYPE_BACK=20401080;//申领回退1080	20401080
    public static final Integer APPLY_JRSBK_IMPORT=20402020;//金融市民卡数据导入
    public static final Integer APPLY_JRSBK_DEL=20402030;//金融市民卡导入数据删除
    public static final Integer APPLY_JRSBK_APPLY=20402040;//金融市民卡导入申领
    public static final Integer APPLY_TYPE_SB_APPLYS=20402050;//嘉兴省社保申领
    public static final Integer APPLY_TYPE_SB_APPLYS_cancel=20402051;//嘉兴省社保申领撤销
    public static final Integer APPLY_TYPE_SB_MKCARD=20402060;//嘉兴省社保制卡完成
    public static final Integer APPLY_TYPE_SB_APPLYS_BK=20402070;//嘉兴省社保补卡
    public static final Integer APPLY_TYPE_SB_APPLYS_HK=20402080;//嘉兴省社保换卡

	public static final Integer ISSUSE_TYPE_PERSONAL= 20401050;//个人发放1050	20401050
	public static final Integer ISSUSE_TYPE_BATCH=20401060;//规模发放1060	20401060
	//public static final Integer ISSUSE_TYPE_RECOVER_CARD= 20401070;//回收卡发放1070	20401070
	public static final Integer ISSUSE_TYPE_PERSONA_DEL= 20401090;//个人发放撤销1090	20401090
	public static final Integer CARD_RECOVERY_SAVE=2040100;//卡片回收登记
	public static final Integer CARD_RECOVERY_ISSUSE=2040110;//回收卡发放
	public static final Integer ISSUSE_OLD_ZZ_NEW=2040120;//换发 老卡转新卡
    public static final Integer CARD_SERVICE_FJMK_SALE=20208020;//非记名卡销售
	
	public static final Integer THIRD_TYPE_APPLY=20403010;//第三方申领3010	20403010
	public static final Integer THIRD_TYPE_ISSUSE=20403020;//第三方发放3020	20403020
	public static final Integer THIRD_TYPE_BACK=20403030;//第三方申领回退3030	20403030
	
	
	public static final Integer KFW_OPEN_YEARCARD = 20409010; //开通年卡
	public static final Integer KFW_CON_YEARCARD = 20409020; //开通年卡  年卡续费
	public static final Integer KFW_CANCEL_YEARCARD =20409030; //旅游年卡取消
	public static final Integer KFW_TRANS_YEARCARD = 20409040;//旅游年卡应用开通
	public static final Integer KFW_SYN_YEARCARD = 20409050; //补换卡发放时同步老卡的应用开通信息
	
	public static final Integer CARD_BIND_BANKCARD_VALID = 20409060;//卡片绑定银行卡验证
	public static final Integer CARD_BIND_BANKCARD_BIND = 20409061;//卡片绑定银行卡绑定
	public static final Integer CARD_BIND_BANKCARD_UNBIND = 20409062;//卡片绑定银行卡解绑
	public static final Integer CARD_BIND_BANKCARD_BIND_BATCH = 20409063;//卡片绑定银行卡绑定(批量)
	public static final Integer CARD_BIND_BANKCARD_PREBIND = 20409064;//卡片绑定银行卡预绑定
	public static final Integer ACC_QCQF_LIMIT_SET = 20409100;//圈存限额设置
	public static final Integer CARD_BIND_ACC_QC_TYPE = 20409110;//设置圈存方式
    public static final Integer CARD_BIND_BANKCARD_ACTIVE= 20409120;//银行卡绑定激活
    public static final Integer CARD_APPLY_YH_CHECK= 20409130;//银行卡绑定激活
	
	public static final Integer ZXC_APP_OPEN = 20409090;//自行车应用开通
	public static final Integer ZXC_APP_CANCEL = 20409091; //自行车应用取消
    public static final Integer ZXC_APP_OPEN_HJL_CONFIRM = 20409500; //自行车应用开通灰记录确认
    public static final Integer ZXC_APP_OPEN_HJL_CANCEL = 20409501; //自行车应用开通灰记录确认
    public static final Integer ZXC_APP_CANCEL_HJL_CONFIRM = 20409500; //自行车应用终止灰记录确认
    public static final Integer ZXC_APP_CANCEL_HJL_CANCEL = 20409501; //自行车应用终止灰记录确认

    public static final Integer CARD_APP_OPEN_JFB_OPEN = 20409200;//积分宝应用开通
    public static final Integer CARD_APP_OPEN_JFB_CLOSE = 20409201;//积分宝应用取消
	
//	+++++++++++++++++++++++++++++++++++++++++++++++++++++++卡管理类20 管理类导出卫生银行审核+++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	public static final Integer PUBLICCARD_EXPORTTOWJW=20405010;//采购计划导出给卫计委
	public static final Integer PUBLICCARD_IMPORTBWJW=20405020;//采购计划导入卫计委文件
	public static final Integer PUBLICCARD_EXPORTTOYH=20405030;//采购计划导出给银行
	public static final Integer PUBLICCARD_IMPORTBYH=20505040;//采购计划导入银行文件
	public static final Integer APPLY_PROCESS_ADDMXTOTASK = 20405050;//任务明细新增人员
	public static final Integer APPLY_PROCESS_DELETEMXFROMTASK = 20405060;//任务明细删除人员
	

	public static final Integer PUBLICCARD_QUERY=20201010;//采购计划查询1010	20201010
	public static final Integer PUBLICCARD_ADD=20202010;//采购计划新增
	public static final Integer PUBLICCARD_DEL=20202020;//采购计划删除
	public static final Integer PUBLICCARD_EXPORT=20201013;//采购计划导出
	public static final Integer PUBLICCARD_CHECK=20201020;//非个性化采购审核1020	20201020
	public static final Integer PUBLICCARD_IMPORT=20201080;//非个性化采购数据导入1020	20201020
	

	public static final Integer TASK_MANAGE_ADD=20201030;//任务生成1030	20201030
	public static final Integer TASK_MANAGE_QUERY=20201040;//任务管理1040	20201040
	public static final Integer TASK_MANAGE_DEL=20201050;//任务删除1040	20201050
	public static final Integer MAKE_CARD_TASK_EXPORT = 20201060;//导出制卡数据
	public static final Integer MAKE_CARD_TASK_EXPORT_BANK_OPENACC = 20201070;//导出银行开户

	
	public static final Integer PUBLICCARD_IMPORTBYFAC=20203010;//采购计划导入银行文件
	public static final Integer PUBLICCARD_BACKTASK=20203020;//采购计划导入银行文件
	public static final Integer PUBLICCARD_BACKOPENACC=20203030;//采购计划开户
	public static final Integer PUBLICCARD_LXSLCODE = 20203040;//采购计划零星申领
	public static final Integer PUBLICCARD_LXSLOPENACC = 20203050;//采购计划零星申领开户
	
	//++++++++++++++++++++++++++++++++++++++卡服务类+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer NAMEDCARD_REISSUE=20501010;//记名卡补卡
	public static final Integer NAMEDCARD_CHG=20501020;//记名卡换卡
	public static final Integer NONAMEDCARD_CHG=20501030;//非记名卡换卡
	public static final Integer CARD_LOSS=20501040;//挂失
	public static final Integer CARD_LOSS_PRE=20501050;//预挂失
	public static final Integer CARD_RELOSS=20501060;//解挂
	public static final Integer NAMEDCARD_REDEEM=20501070;//记名卡注销
	public static final Integer BALANCE_RESTORE=20501080;//余额返还
	public static final Integer BALANCE_RESTORE_IMPORT=20501082;//余额返还导入
	public static final Integer CARD_APP_LOCK=20501090;//卡片应用锁定
	public static final Integer CARD_APP_UNLOCK=20501100;//卡片应用解锁
	public static final Integer CARD_BUS_TYPE_MOD=20501160;//公交子类型修改
	public static final Integer NAMEDCARD_REISSUE_UNDO=20501171;//记名卡补卡撤销（补卡类型的申领记录撤销）
	public static final Integer NAMEDCARD_CHG_UNDO=20501181;//记名卡换卡撤销（换卡类型的申领记录撤销）
	public static final Integer BALANCE_RESTORE_CONFIRM=20501190;//余额返现确认
	public static final Integer BALANCE_RESTORE_CANCEL=20501200;//余额返现撤销(撤销登记记录，不是)
	public static final Integer BHK_QB_ZZ=30101070;//换卡钱包转账
	public static final Integer BHK_QB_ZZ_BZ=30101080;//换卡转钱包补账（卡面余额多）
	public static final Integer BHK_QB_ZZ_DJ=30101090;//换卡转钱包登记（坏卡）
	
	public static final Integer PERSON_SERVICEPWD_RESET=20502010;//个人服务密码重置
	public static final Integer PERSON_SERVICEPWD_MODIFY=20502020;//个人服务密码修改
	public static final Integer PERSON_TRADEPWD_RESET=20502030;//个人交易密码重置
	public static final Integer PERSON_TRADEPWD_MODIFY=20502040;//个人交易密码修改
	public static final Integer SB_PWD_RESET=20502050;//个人交易密码重置
	public static final Integer SB_PWD_MODIFY=20502060;//个人交易密码修改
	public static final Integer SPERSON_SERVICEPWD_RESET = 20502070;//服务密码
	
	
	//+++++++++++++++++++++++++++++++++++++++充值卡管理类+++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer RECHANGE_CARD_SELL=20501110;// 充值卡单张销售1110	20501110
	public static final Integer RECHANGE_CARD_BATCHSELL=20501120;//充值卡批量销售1120	20501120
	public static final Integer RECHANGE_CARD_BATHCHUSED=20501130;//充值卡批量启用1130	20501130
	public static final Integer RECHANGE_CARD_UNDO=20501140;//充值卡销售撤销1140	20501140
	public static final Integer RECHANGE_CARD_RETURNED=20501150;//充值卡销售回款1150	20501150
	public static final Integer RECHANGE_CARD_IMPORT=20501160;//充值卡制卡数据导入
	
	//++++++++++++++++++++++++++++++++++++++++现金充值交易码类+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer RECHARGE_CASH_WALLET=30101010;//现金→钱包
	public static final Integer RECHARGE_CASH_WALLET_REV=30101011;//现金→钱包_撤销
	public static final Integer RECHARGE_CASH_ACC=30101020;//现金→联机账户
	public static final Integer RECHARGE_CASH_ACC_REV=30101021;//现金→联机账户_撤销
	public static final Integer RECHARGE_ACC_ACC=30101030;//联机→联机  
	public static final Integer RECHARGE_ACC_WALLET=30101040;//联机→钱包
	public static final Integer RECHARGE_WALLET_ACC=30101050; //钱包→联机（此交易代码暂时先这么写的，需要改的）
	public static final Integer RECHARGE_WALLET_WALLET=30101060; //钱包→钱包
	public static final Integer REISSUE_CHG_TURN_PURSE=30101070;//补换转钱包
	public static final Integer REISSUE_CASH_WD=30101100;//柜面批量充未登账户
	public static final Integer REISSUE_CASH_WD_DEL=30101110;//柜面批量充未登账户删除
	
	
	public static final Integer RECHARGE_BANK_ACC=30302010;//银行卡→联机账户
	public static final Integer RECHARGE_BANK_WALLET=30302020;//银行卡→钱包
	public static final Integer RECHARGE_RECHARGECARD_ACC=30501010;//充值卡→联机账户
	public static final Integer BASE_BILL=30202010;//票据管理
	public static final Integer RECHARGE_RECHARGECARD_WALLET=30501020;//充值卡→钱包
	public static final Integer RECHARGE_CASH_PRESTORE_REV=30701011;//现金→网点预充值_撤销
	public static final Integer RECHARGE_BANK_PRESTORE_REV=30701021;//银行卡→网点预充值_撤销
	public static final Integer RECHARGE_CASH_PRESTORE=30701010;//现金→网点预充值
	public static final Integer RECHARGE_BANK_PRESTORE=30701020;//银行卡→网点预充值
	public static final Integer RECHARGE_NORECHARGE_WALLET_REV=30801011;//待圈存账户→钱包_撤销
	public static final Integer RECHARGE_NORECHARGE_WALLET=30801010;//待圈存账户→钱包
	public static final Integer TRM_CHARGE_BANK2WALLET=30802010;//终端_银行卡→钱包
	public static final Integer TRM_CHARGE_SPECACC2WALLET=30802020;//终端_未圈存账户→钱包
	public static final Integer TRM_CHARGE_ACC2WALLET=30802030;//终端_联机→钱包
	public static final Integer TRM_CHARGE_CHARGECARD2WALLET=30802040;//终端_充值卡→钱包
	public static final Integer TRM_CHARGE_CASH2WALLET_REV=30802051;//终端_现金→钱包_撤销
	public static final Integer TRM_CHARGE_BANK2WALLET_REV=30802011;//终端_银行卡→钱包_撤销
	public static final Integer TRM_CHARGE_SPECACC2WALLET_REV=30802021;//终端_未圈存账户→钱包_撤销
	public static final Integer TRM_CHARGE_ACC2WALLET_REV=30802031;//终端_联机→钱包_撤销
	
	//++++++++++++++++++++++++++++++++++++++++合作机构业务类+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer RECHARGE_ACC_CASH=30105010;//合作机构现金→联机
	public static final Integer RECHARGE_ACC_CASH_CX=30105011;//合作机构现金→联机撤销
	public static final Integer RECHARGE_ACC_TO_QB=30105030;//合作机构联机→钱包
	public static final Integer RECHARGE_QB_CASH=30105020;//合作机构现金→钱包
	public static final Integer RECHARGE_QB_CASH_CX=30105021;//合作机构现金→钱包 撤销
	// 这俩好像没用到
	public static final Integer CORECHAGE_CZ_ZJZH=30105010;//外围接口充值联机
	public static final Integer CORECHAGE_CZCX_ZJZH=30105010;//外围接口充值联机撤销
	public static final Integer CORECHAGE_CZ_QBZH=30105020;//外围接口充值电子钱包
	public static final Integer CORECHAGE_CZCX_QBZH=30105020;//外围接口充值电子钱包撤销
	public static final Integer COTRANSFER_LJ2QB_QBZH=30105030;//外围接口联机到钱包
	public static final Integer COTRANSFER_LJ2QBCX_QBZH=30105031;//外围接口联机到钱包撤销
	public static final Integer COTRANSFER_WD2QB_QBZH=30105040;//外围接口未登项到钱包
	public static final Integer COTRANSFER_WD2QBCX_QBZH=30105041;//外围接口未登项到钱包撤销
	public static final Integer COTRANSFER_LJ2LJ_QBZH=30105060;//外围接口联机到联机
	public static final Integer COTRANSFER_LJ2LJCX_QBZH=30105061;//外围接口联机到联机撤销
	public static final Integer COSERVICE_LJ2YH=30105070;//外围接口联机到银行卡
	public static final Integer COSERVICE_LJ2YHCX=30105071;//外围接口联机到银行卡撤销
	public static final Integer CORECHAGE_QF_ZJZH=30105090;//外围接口圈付到联机账户
	public static final Integer CORECHAGE_QFCX_ZJZH=30105091;//外围接口圈付到联机账户撤销
	
	//+++++++++++++++++++++++++++++++++++++++消费类+++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer OFFLINE_CONSUME=40101010;//	商户脱机消费
	public static final Integer OFFLINE_CONSUME_CANCEL=40101022;//	商户脱机消费冲正
	public static final Integer OFFLINE_CONSUME_UNDO=40101031;//	商户消费脱机消费撤销
	public static final Integer OFFLINE_CONSUME_UNDO_CANCEL=40101042;//	商户消费脱机消费撤销冲正
	public static final Integer OFFLINE_CONSUME_RETURN=40101051;//	商户脱机消费退货
	public static final Integer OFFLINE_CONSUME_RETURN_CANCEL=40101062;//	商户脱机消费退货冲正
	public static final Integer OFFLINE_CONSUME_CHECK_BILL=40101090;//	商户脱机数据对账
	public static final Integer CO_OFFLINE_CONSUME=40102010;//	合作机构脱机消费
	public static final Integer CO_OFFLINE_CONSUME_CANCEL=40102022;//	合作机构脱机消费冲正
	public static final Integer CO_OFFLINE_CONSUME_UNDO=40102031;//	合作机构脱机消费撤销
	public static final Integer CO_OFFLINE_CONSUME_UNDO_CANCEL=40102042;//	合作机构脱机消费撤销冲正
	public static final Integer CO_OFFLINE_CONSUME_RETURN=40102051;//	合作机构消费退货
	public static final Integer CO_OFFLINE_CONSUME_RETURN_CANCEL=40102062;//	合作机构消费退货冲正
	public static final Integer CO_OFFLINE_CONSUME_CHECK_BILL=40102090;//	合作机构脱机数据对账
	public static final Integer ONLINE_CONSUME=40201010;//	商户联机消费
	public static final Integer ONLINE_CONSUME_POS=40101020;//联机→POS联机消费
	public static final Integer ONLINE_CONSUME_CANCEL=40201022;//	商户联机消费冲正
	public static final Integer ONLINE_CONSUME_UNDO=40201031;//	商户联机消费撤销
	public static final Integer ONLINE_CONSUME_UNDO_CANCEL=40201042;//	商户联机消费撤销冲正
	public static final Integer ONLINE_CONSUME_RETURN=40201051	;//商户联机消费退货
	public static final Integer ONLINE_CONSUME_RETURN_CANCEL=40201062;//商户联机消费退货冲正
	public static final Integer ONLINE_CONSUME_CHECK_BILL=40201070;//商户联机数据对账
	public static final Integer CO_ONLINE_CONSUME=40202010;//合作机构联机消费
	public static final Integer CO_ONLINE_CONSUME_CANCEL=40202022;//合作机构联机消费冲正
	public static final Integer CO_ONLINE_CONSUME_UNDO=40202031;//合作机构联机消费撤销
	public static final Integer CO_ONLINE_CONSUME_UNDO_CANCEL=40202042;//合作机构联机消费撤销冲正
	public static final Integer CO_ONLINE_CONSUME_RETURN=40202051;//合作机构联机消费退货
	public static final Integer CO_ONLINE_CONSUME_RETURN_CANCEL=40202062;//合作机构联机消费退货冲正
	public static final Integer CO_ONLINE_CONSUME_CHECK_BILL=40202070;//合作机构联机数据对账
	
	
	
	//+++++++++++++++++++++++++++++++++++++++账户管理类交易代码+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer ACC_MANAGER_ADD = 50101010;//账户类型新增
	public static final Integer ACC_MANAGER_EDIT = 50101020;//账户类型编辑
	public static final Integer ACC_MANAGER_DEL = 50101031;//账户类型删除
	public static final Integer ACC_MANAGER_ENABLE = 50101040;//启用账户类型
	public static final Integer ACC_MANAGER_DISABLE = 50101051;//禁用账户类型
	//+++++++++++++++++++++++++++++++++++++++账户开户规则管理类交易代码+++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer ACC_OPEN_RULE_ADD = 50201010;//账户开户规则新增
	public static final Integer ACC_OPEN_RULE_EDIT= 50201020;//账户开户规则编辑
	public static final Integer ACC_OPEN_RULE_DEL=50201031;//账户开户规则删除
	public static final Integer ACC_OPEN_RULE_ENABLE=50201040;//账户开户规则启用
	public static final Integer ACC_OPEN_RULE_DISABLE=50201051;//账户开户规则禁用
	//+++++++++++++++++++++++++++++++++++++++账户状态和禁止交易码进行关联的管理+++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer ACC_STATE_TRADING_BAN_MANAGER_ADD=50301010;//账户状态和禁止交易码进行关联新增
	public static final Integer ACC_STATE_TRADING_BAN_MANAGER_EDIT=50301020;//账户状态和禁止交易码进行关联编辑
	public static final Integer ACC_STATE_TRADING_BAN_MANAGER_DEAL=50301031;//账户状态和禁止交易码进行关联删除
	public static final Integer ACC_STATE_TRADING_BAN_MANAGER_ENABLE=50301040;//账户状态和禁止交易码进行关联启用
	public static final Integer ACC_STATE_TRADING_BAN_MANAGER_DISABLE=50301051;//账户状态和禁止交易码进行关联禁用
	//+++++++++++++++++++++++++++++++++++++++账户消费额度限制管理+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer ACC_CREDIT_LIMIT_ADD=50401010;//账户消费限额新增
	public static final Integer ACC_CREDIT_LIMIT_EDIT=50401020;//账户消费限额编辑
	public static final Integer ACC_CREDIT_LIMIT_DEL=50401031;//账户消费限额删除
	public static final Integer ACC_CREDIT_LIMIT_ENABLE=50401040;//账户消费限额启用
	public static final Integer ACC_CREDIT_LIMIT_DISABLE=50401051;//账户消费限额禁用
	//++++++++++++++++++++++++++++++++++++++++账户锁定管理+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer ACC_STATE_LOCK=50501011;//账户锁定
	public static final Integer ACC_STATE_UNLOCK=50501020;//账户解锁
	public static final Integer ACC_STATE_ENABLE=50501030;//账户激活
	public static final Integer ACC_STATE_FREEZE=50501040;//账户金额冻结
	public static final Integer ACC_STATE_UNFREEZE=50501051;//账户金额解冻
	
	public static final Integer TELLER_SWAP =50801010;//柜员调剂
	public static final Integer BRANCH_DEPOSIT=50801020;//网点存款
	public static final Integer BRANCH_DEPOSIT_CONFIRM=50801030;//网点存款确认
	
	//+++++++++++++++++++++++++++++++++++++++账户管理管理类+++++++++++++++++++++++++++++++++++++++++++++++++++++++
	
	public static final Integer MERCHANT_ACC_ADD = 50501060;//商户账户开户
	public static final Integer ORG_OPEN_ACC=50501070;//机构开户
	public static final Integer BRCH_OPEN_ACC = 50501080;//网点编辑
	public static final Integer ACC_BLANCE_ENCRYPT=50501090;//账户余额加密
	
	
	
	
	//+++++++++++++++++++++++++++++++++++++++日终处理类+++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer CUTE_USER_DAY_BAL = 60101010;//柜员扎帐
	public static final Integer CUTE_BRCH_DAY_BAL = 60101020;//网点扎帐
	public static final Integer CUTE_REFORCE_USER_DAY_BAL = 60101030;//强制网点柜员轧账
	public static final Integer CO_CHECK_LIST_COREPAIR = 60601010;//平账合作机构补交易
	public static final Integer CO_CHECK_LIST_ORGCANCEL = 60601020;//平账运营机构充值撤销交易
	public static final Integer CO_CHECK_LIST_ORGADD = 60601030;//平账运营机构补充值交易
	public static final Integer CO_CHECK_LIST_CODELETEMX = 60601040;//平账运营机构补消费交易
	public static final Integer DEAL_OFFLINE_IN = 60601050;//电子钱包手工入账
	public static final Integer ADD_ADJUST_INFO = 60603010;//添加调账信息
	public static final Integer CHCEK_ADJUST_INFO = 60603020;//审核调账信息
	public static final Integer DEL_ADJUST_INFO = 60603030;//删除调账信息
	public static final Integer SAVE_ADJUST_INFO = 60603040;//保存调账信息
	public static final Integer POINT_PARA_ADD = 60701010;//积分参数添加
	public static final Integer POINT_PARA_EDIT = 60701020;//积分参数编辑
	public static final Integer POINT_PARA_DELETE = 60701030;//积分参数删除
	public static final Integer POINT_PARA_CANCEL = 60701040;//积分参数注销
	public static final Integer POINT_PARA_ACTIVE = 60701050;//积分参数激活
	public static final Integer RECHARGE_WALLET_HJL_QR=60601060;//灰记录确认
	public static final Integer RECHARGE_WALLET_HJL_QX=60601061;//灰记录取消
	
	public static final Integer OFFLINE_DATA_CONFIRM = 60901010;//脱机数据处理确认
	
	public static final Integer ONLINE_DATA_RETURN_HANDLE = 60801010;//手工退货登记
	
	public static final Integer CORP_RECHARGE=30601010;//单位账户充值
	public static final Integer CORP_BATCH_RECHARGE=30601020;//单位批量充值
	public static final Integer CORP_BATCH_RECHARGE_CANCEL=30601021;//单位批量充值撤销
	public static final Integer CORP_BATCH_RECHARGE_IMPORT=30601022;//单位批量充值导入
	public static final Integer CORP_BATCH_RECHARGE_CHECK=30601023;//单位批量充值数据审核
	public static final Integer CORP_BATCH_RECHARGE_DELETE=30601024;//单位批量充值数据删除
	public static final Integer CG_CORP_ACC_BATCH_RECHARGE = 30601030;//车改批量充值
	public static final Integer CG_CORP_ACC_BATCH_RECHARGE_CANCEL = 30601031;//车改批量充值撤销
	public static final Integer CORP_REGISTER=30601040;//单位入网登记
	public static final Integer CORP_MODIFY=30601041;//单位信息修改
	public static final Integer CORP_CHECK=30601042;//单位信息审核
	public static final Integer CORP_ENABLED=30601043;//单位状态修改
	public static final Integer CORP_OPEN_ACC=30601044;//单位开户
	//+++++++++++++++++++++++++++++++++++++++商户结算类+++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer MERCHANT_SETTLEMENT=60201010;//商户结算审核
	public static final Integer MERCHANT_SETTLEMENT_ROLLBACK=60201020;//商户结算回退
	public static final Integer MERCHANT_SETTLEMENT_PRINTPAY=60201030;//结算支付清单打印
	public static final Integer ADD_CARD_ORG_BIND_SECTION=60201040;//新增发卡方信息
	
	
	public static final Integer PWD_ERR_NUM_PARA_SET = 90409010;//密码输入错误次数设置
	public static final Integer SERV_PWD_NUM_UNDO_SET = 90409020;//服务密码输入错误次数设置
	public static final Integer TRADE_PWD_NUM_UNDO_SET = 90409030;//交易面膜输入错误次数设置
	public static final Integer UPDATE_CARDINFO = 90409090;//更新卡信息
	
	public static final Integer PAY_CARRE_FORM_CORP_RECHARGE = 90409040;//车改充值（单位）
	public static final Integer PAY_CARRE_FORM_MANAGER = 90409041;//车改充值信息管理
	public static final Integer SIINFO_MEDWHOLENO_UPDATE = 90409050;//统筹区编码变更
	
	
	//+++++++++++++++++++++++++++++++++++++++系统管理类+++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public static final Integer  CARD_PARA_ADD =  90701010;//卡参数新增
	public static final Integer  CARD_PARA_EDIT = 90701020;//卡参数编辑
	public static final Integer  ACC_ITEM_EDIT= 90701070;//科目管理
	public static final Integer  FTP_CONF_MANAGE = 90701080;//ftp管理
	
	public static final Integer ORG_ADD=90701030;//机构新增
	public static final Integer ORG_EDIT=90701040;//机构编辑
	public static final Integer ORG_DEL=90701050;//机构注销
	public static final Integer BRCH_ADD=90701060;//网点新增
	public static final Integer USER_PWD_CHG=90701070;//柜员密码修改
	
	public static final Integer UNION_BRCH_ID = 90902010;
	public static final Integer UNION_BRCH_OPENACC = 90902020;
	public static final Integer UNION_DKD_SQQR = 90902030;
	public static final Integer UNION_DKD_SQQR_CANCEL = 90902040;
	public static final Integer UNION_DKD_FF = 90902050;
	public static final Integer UNION_DKD_FF_CANCEL = 90902051;
	public static final Integer CARD_STATE_SYNCHRONIZE = 90902060;
	
	public static final Integer OPER_CASH_BOX_DETAIL_PRINT = 90801010;
	public static final Integer OPER_TRANSFER_DETAIL_PRINT = 90801011;
	
	public static final Integer DELETE_MANUAL_RETURN_INFO = 90802010;
	public static final Integer CARD_INSURANCE_INFO_IMPORT = 90802020;// 卡片保险数据导入
	public static final Integer CARD_INSURANCE_INFO_DELETE = 90802030;// 卡片保险数据删除
	public static final Integer LK_BRCH_SET = 90802040;// 领卡网点设置
	
	public static final Integer UPDATE_ST_CARD_STATE = 90802050;// 省厅卡状态变更
	public static final Integer UPDATE_ST_CARD_MED_WHOLE_NO = 90802060;// 省厅卡统筹区状态变更
	public static final Integer CARD_RECEIVE_REGIST = 90802070;// 领卡登记
	public static final Integer CORP_NET_APP_IMPORT = 90802080;// 社保单位申领数据导入（社保系统通过接口）
	public static final Integer PERSON_MERGE = 90802090;// 人员合并
}
