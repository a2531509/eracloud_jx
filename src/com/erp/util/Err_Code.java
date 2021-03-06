package com.erp.util;

public class Err_Code {
	public static Integer NO_IS_NEED_NOT_NULL=10010101;//物品编号和辅助编号必须有一项不为空
	public static Integer STOCK_LIST_IS_NULL=10010102;//查询得知在库存明细中不存在！
	public static Integer CARD_INFOR_OR_TASK_ID_IS_NOT_NULL=10010201;//发放库存接口中卡片信息或任务号不能同时为空！
	public static Integer CARD_NO_IS_NOT_NULL=10010202;//卡号不能为空！
	public static Integer CUR_STK_LIST_IS_NOT_NULL=10010203;//当前库存明细不存在！
	public static Integer STK_LIST_NUM_AND_CUR_BUSINESS_INCON=10010204;//库存明细数量与当前业务操作数量不一致！
	public static Integer STK_GOODS_AVAILABLE_NUM_NOT_ENOUGH=10010205;//库存物品可用数量不够！
	public static Integer CALL_UPDATE_STK_LIST_INTERFACE_ERROR=10010206;//发放调用更新库存明细接口发生错误！
	public static Integer PAY_THE_STK_LEDGER_DOES_NOT_EXIST=10010207;//付方库存分户账不存在！
	public static Integer STK_RECORD_IS_NULL=10010301;//库存业务记录不存在！
	public static Integer STK_RECORD_IS_NOT_CUR_TELLER_OPERATOR=10010302;//库存业务记录非本柜员的操作！
	public static Integer STK_LIST_IS_NULL=10010303;//库存业务流水或明细不存在！
	public static Integer STK_SUB_LEDGER_IS_NULL=10010304;//库存户账不存在！
	public static Integer CARD_NO_IS_NULL=10010401;//卡号不能为空！
	public static Integer CARD_START_NUM_IS_NOT_ZERO=10010402;//非记名卡启用数量不能为0
	public static Integer STK_GOODS_NUM_NOT_ENOUGH=10010403;//付方库存物品可用数量不够！
	public static Integer STK_LIST_NUM_INCON=10010404;//库存明细数量与当前业务操作数量不一致！
	public static Integer STK_LEDGER_IS_NULL=10010405;//付方库存账户不存在！
	public static Integer OLD_STK_LIST_AND_CUR_BUSINESS_INCON=10010502;//老卡库存明细数量与当前业务操作数量不一致！
	public static Integer OLD_STK_LIST_IS_NULL=10010503;//老卡库存明细不存在！
	public static Integer GOODS_RECOVERY_STK_SUB_LEDGET_IS_NULL=10010504;//物品状态为回收卡待处理的分户账不存在！
	public static Integer NEW_CARD_STK_LIST_CUR_BUSINESS_INCON=10010505;//新卡库存明细数量与当前业务操作数量不一致！
	public static Integer NEW_CARD_STK_LIST_IS_NULL=10010506;//新卡库存明细不存在！
	public static Integer CUR_STK_SUB_LEDGET_IS_NULL=10010507;//库存分户账不存在！
	public static Integer CUR_STK_NUM_NOT_ENOUGH=10010508;//库存数量不足！
	public static Integer STK_BUSINESS_RECORD_IS_NULL=10010601;//库存业务记录不存在！
	public static Integer STK_BUSINESS_RECORD_IS_NOT_CUR_OPER=10010602;//业务流水号为的记录不是柜员的操作记录！
	public static Integer OLD_CARD_STK_STREAM_IS_NULL=10010603;//旧卡库存业务流水信息不存在！
	public static Integer NEW_CARD_STK_STREAM_IS_NULL=10010604;//新卡库存存业务流水不存在!
	public static Integer OLD_CARD_STK_LIST_IS_NULL=10010605;//旧卡库存明细不存在！
	public static Integer NEW_CARD_NO_STK_LIST_IS_NULL=10010606;//新卡库存明细不存在！
	public static Integer STK_STREAM_NUM_AND_CARD_NUM_INCON=10010607;//库存业务流水数量与卡数量不一致！
	public static Integer NOT_SEACH_THE_CUR_STK_TYPE_INFOR=10020401;//未查询到当前库存类型信息！
	public static Integer QUERY_TO_THE_DOT_WITHOUT_ORG_INFOR=10030201;//未查询到该网点对应的机构信息!
	public static Integer NOT_NEED_TO_QUERY_STATE_INFOR_ACC_ITEMS=10030202;//未查询到需要开户的物品状态信息!
	public static Integer CUR_ACC_STK_NUM_MORE_THAN_ZERO_CAN_NOT_CLEAN=10030401;//当前账户库存数量大于0，不能销户！
	public static Integer CUR_ACC_IS_CLEAN=10030402;//该账户已经销户！
	public static Integer CUR_ACC_BAL_IS_NOT_ZERO_CAN_NOT_CLEAN=10030403;//该账户余额不为0，不能销户！
	public static Integer FILE_FORMAT_NOT_RIGHT=10040201;//文件格式不正确
	public static Integer TASK_NUM_NOT_LIST_NUM=10040202;//任务制卡数量与明细制卡数量不一致，请检查
	public static Integer IMP_FILE_TASK_ID_INFOR_NOT_HAVE_AT_ROWS=10040203;//导入文件任务号对应的制卡任务信息不存在
	public static Integer TASK_NUM_NOT_TASK_LIST_NUM=10040204;//制卡导入文件中任务数量与制卡导入文件中制卡明细数量不一致
	public static Integer TASK_NUM_GT_LIST_NUM_AT_ROWS=10040205;//导入文件中的任务制卡数量不能大于原始制卡任务信息中的制卡数量

	public static Integer IMP_FILE_TASK_STK_STATE_NOT_IMP=10040206;//导入文件中的制卡任务其库中任务状态不为“制卡中”，不能导入
	public static Integer IMP_FILE_HAVE_PCH_NOT_MUCH=10040207;//导入文件中包含不同批次的制卡任务信息
	public static Integer LIST_NUM_GT_TASK_NUM=10040208;//导入文件中的制卡明细数不能大于原制卡任务数量
	public static Integer STK_SUB_LEDGET_IS_NOT_HAVE=10040209;//库存分户账不存在
	public static Integer TASK_ID_IS_NOT_HAVE=10040210;//制卡任务不存在
	public static Integer FILE_IMP_CARD_NUM_ZERO=10040211;//文件导入卡数量为零
	public static Integer FILE_IMP_HAVE_NUM_RECORD_NOT_IMP=10040212;//请不要重复导入
	public static Integer STK_NOT_HAVE_BATCH_ID=10040213;//当前库中不存在卡制作采购批次号
	public static Integer FILE_IMP_GT_BATCH_LIST_NUM=10040214;//当前文件导入制卡明细数不能大于该批次的制卡明细数
	public static Integer CUR_FILE_NUM_INFOR_NOT_RIGHT_CHECK_FILE=10040215;//信息不正确，请校验文件
	public static Integer FILE_IMP_ERROR=10040216;//制卡文件导入发生错误
	public static Integer IMP_FILE_DATA_NOT_RIGHT=10040217;//当前导入文件数据不正确
	public static Integer TASK_STATE_NOT_DIS=10050201;//当前制卡任务的任务状态不为“已制卡”，不能进行配送操作
	public static Integer TASK_STK_CODE_IS_NULL=10050202;//当前制卡任务对应的库存代码为空
	public static Integer STK_TYPE_OUT_IN_STK_TASK_BETCH_OUT_IN_STK=10050203;//当前库存类型对应的出入库方式只能按制卡任务批量出入库
	public static Integer DIS_IS_NOT_NULL=10050204;//配送方式不能为空
	public static Integer PERSON_NOT_EXITS_OLDCARD=11020701;//用户不存在需要转账的老卡
	public static Integer RECHARGE_RULE_ERR=11040001;//充值业务规则不满足
	public static Integer RECHARGE_CASH_TRSTEP_ERR=11040102;//业务处理步骤不正确
	public static Integer RECHARGE_CASH_AMT_ERR=11040103;//交易金额不能为空
	public static Integer RECHARGE_CASH_ACCBALBEF_ERR=11040104;//交易前金额不能为空
	public static Integer CASH_RECHG_LOW_ERR=11040105;//钱包账户最低充值金额
	public static Integer WALLET_CASE_RECHG_LMT_ERR=11040106;//钱包账户最高限额
	public static Integer TR_SERV_REC_MES_EXIST=11040107;//综合业务记录不存在
	public static Integer RECHARGE_CASH_ACC_AMT_ERR=11040201;//交易金额不能为空
	public static Integer ACC_RECHG_LOW_ERR=11040202;//账户最低充值金额
	public static Integer ACC_CASE_RECHG_LMT_ERR=11040203;//账户最高限额
	public static Integer RECHARGE_CASH_SERVICE_EXIST=11049901;//交易服务不存在
	public static Integer HAVE_KEPT_THE_PURCHASING_PLAN_UPDATE_NOT_ALLOWED=15010201;//已经保存的采购计划，不允许更新
	public static Integer PLEASE_FILL_IN_THE_CARD_NUMBER_OF_TASKS=15010202;//请填写制卡任务数量！
	public static Integer THE_CUR_PROCUREMENT_PLANS_TO_ACQUIRE_CARD_FAILURE=15010203;//当前采购计划获取卡号失败
	public static Integer CARD_TYPE_IS_NOT_NULL=15010204;//卡类型不能为空！
	public static Integer THE_SYSTEM_LOG_SEQUENCE_NUM_CAN_NOT_BE_EMPTY=15010205;//系统日志流水号不能为空
	public static Integer CITY_IDIS_NOT_NULL=15010206;//城市号不能为空
	public static Integer CUR_CARD_NO_HAVE_NUM_ERROR=15010207;//当前卡号获取数量不正确
	public static Integer LOAD_CARD_NO_IS_ERROR=15010208;//获取卡号发生问题
	public static Integer CREATE_CARD_NO_IS_ERROR=15010209;//生成卡号出现问题
	public static Integer NEED_TO_DEL_THE_PRO_PLAN_MUST_BE_TO_DEL=15010301;//需要删除的采购计划必须为“任务已生成”状态，否则不允许删除
	public static Integer NEED_TO_EXP_THE_PLAN_ELSE_NOT_EXP=15010401;//需要导出的任务必须为‘任务生成’状态，否则不允许导出！
	public static Integer ALREADY_EXIST_ORGINFO=90100101;//已存在相同机构编号的机构信息
	public static Integer ALREADY_CANCELED_ORG_CANT_OPEN_ACC=90100102;//机构已经注销,不能开户
	public static Integer ALREADY_EXIST_ORGNAME=90100103;//已存在相同机构名称的机构信息
	public static Integer ALREADY_CANCELED_ORG=90100301;//机构已经注销
	public static Integer NOT_EXIST_ORGINFO=90100501;//不存在机构信息，请核对后再试
	public static Integer PROVORG_UNABLE_CREATE_BRCH=90110101;//省级机构不能建立网点
	public static Integer SAME_NUM_BRCH=90110102;//已存在该网点编号
	public static Integer ALREADY_CANCELED_BRCH_CANT_OPEN_ACC=90110103;//网点已经注销,不能开户
	public static Integer BRCH_LEVEL_CANT_OVER_THREE=90110104;//网点级别不能大于n级，n配置在sys_code中
	public static Integer ALREADY_CANCELED_BRCH=90110301;//网点已经注销
	public static Integer NO_SUCH_BRCHINFO=90110501;//不存在网点的网点信息，请核对后再试
	public static Integer ALREADY_EXIST_OPER=90120101;//已存在该柜员编号
	public static Integer ALREADY_CANCELED_OPER=90120301;//柜员已经注销，不能再次注销
	public static Integer ALREADY_OPEN_CASH_BOX=90120501;//所有正常状态柜员均已开现金尾箱
	public static Integer ALREADY_EXIST_CLRRATE=90150101;//已经存在相同的分成方法
	public static Integer ALREADY_CANCELED_CLRRATE=90150301;//分成方法已经注销
	public static Integer ALREADY_EXIST_CLRORG=90160101;//已经存在的分成机构
	public static Integer ALREADY_EXIST_CLRORG_BY_ID=90160102;//已经存在的分成机构
	public static Integer UNABLE_MODIFY_ORG=90160201;//机构9999不能修改
	public static Integer UNABLE_CANCEL_CLRORG=90160301;//分成机构不允许注销！
	public static Integer ALREADY_CANCELED_CLRORG=90160302;//分成机构【?】已经注销！
	public static Integer ALREADY_CANCELED_CLRORG_CANT_OPEN_ACC=90160401;//分成机构已注销,不能开户
	public static Integer NO_CLRORG_INFO=90160501;//不存在机构信息或该机构以注销，请核对后再试！
	public static Integer SAME_FEE_CONF=90250101;//已存在相同的配置
	public static Integer ALREADY_CANCELED_FEE_CONF=90250301;//费用配置已经注销
	public static Integer ALREADY_CANCELED_ACC_OPEN_CONF=90260301;//开户配置已经注销
	public static Integer NO_CARD_ACC_INFO=90290101;//没有该卡号的账户信息
	public static Integer ALREADY_EXIST_LIMITCONF=90300101;//代理网点已存在额度配置
	public static Integer PLEASE_CHOOSE_BRCH=90300102;//请选择代理网点
	public static Integer ALREADY_AUDITED_CONF=90300201;//代理网点额度配置已经审核通过不能修改
	public static Integer ALREADY_CANCELED_LIMITCONF=90300301;//网点额度配置已注销，不能再次注销
	public static Integer ALREADY_CANCELED_LIMIT_CONF=90300401;//网点限额配置已经注销，不能进行审核
	public static Integer ALREADY_AUDIT_LIMIT_CONF=90300402;//网点限额配置已审核，不能再次审核
	public static Integer SAME_TERM_CONF=90310101;//客户号/终端号【?】已存在配置,请返回编辑
	public static Integer ALREADY_CANCELED_UNABLE_ADDOREDIT=90310102;//网点/商户/终端已经注销，不能新增/编辑！
	public static Integer NOT_EXIST_THIS=90310103;//不存在该网点/商户/终端
	public static Integer ALREADY_CANCELED_TERM_CONF=90310301;//客户号/终端号的交易配置已经注销！
	public static Integer QUERY_RESULT_NULL=99990000;//没有符合条件的数据
	public static Integer OPERID_NULL=99990001;//柜员号不能为空
	public static Integer OPER_EXIST=99990002;//柜员号不能为空
	public static Integer CARDNO_NOT_NULL=99990003;//卡号不能为空
	public static Integer CARD_STATA_ERR=99990004;//卡状态不正常
	public static Integer CARD_NOT_EXIST=99990005;//卡信息不存在
	public static Integer PERSON_NOT_EXIST=99990006;//用户不存在
	public static Integer CARD_TYPE_NOT_NULL=99990007;//卡类型不能为空
	public static Integer PERSON_NOT_EXIST_CARD_INFO=99990008;//用户不存在卡片信息
	public static Integer CARD_PARA_NOT_EXIST=99990009;//卡参数不存在
	public static Integer NAMEDCARD_NO_DO_NONAMEDCARD=99990010;//记名卡不能进行非记名卡操作
	public static Integer NONAMEDCARD_NO_DO_NAMEDCARD=99990011;//非记名卡不能进行记名卡操作
	public static Integer MUST_PARAMETERS_CANNOT_BE_EMPTY=99990012;//必须参数不能为空
	public static Integer NOT_IN_QUERY_CUR_STK_CODE_CORR_STK_TYPE_INFOR=99990013;//未查询到当前库存代码对应库存类型信息
	public static Integer CUR_STK_TYPE_SENO_OR_TASK_ID_NEED_ONE_IS_NOT_NULL=99990014;//当前库存类型起止号码、任务编号必须有一项不能为空
	public static Integer CUR_STK_TYPE_STATE_END_NO_IS_NOT_NULL=99990015;//当前库存类型起止号码不能为空
	public static Integer CUR_STK_TYPE_NEED_STK_NUM_IN_STK=99990016;//当前库存类型必须按数量入库，页面输入数量不能为空
	public static Integer CANOT_FIND_FOPER_IDACC_INFOR=99990017;//未查询到付方柜员对应的账户信息,请到“库存账户”中开户
	public static Integer FOPER_ID_STK_GOODS_NUM_NOT_HAVE_=99990018;//付方库存类型对应的账户物品数量不够
	public static Integer CUR_FOPER_ID_STK_LIST_NUM_NOT_TASK_NUM=99990019;//当前付方库存明细数量与任务总数不一致
	public static Integer FOPER_ID_STK_NUM_NOT_HAVE_CHK_INPUT_SENOIS_HAVE=99990020;//付方库存可用数量不够，请检查输入的起止号码是否存在并且连续
	public static Integer CAN_NOT_QUERY_SOPER_ID_ACC_INFOR_OPER_ACC=99990021;//未查询到收方柜员对应的账户信息,请到“库存账户”中开户
	public static Integer SOPER_ID_HAVE_CUR_TASK_ID_STK_LIST_INFOR_=99990022;//收方账户已经存在当前任务号对应的库存明细信息
	public static Integer SOPER_ID_HAVE_SENO_GOODS_LIST_INFOR__=99990023;//收方账户已经存在起止号码段内的物品明细信息
	public static Integer STK_LIST_NUM_NOT_CUR_BIS_NUM=99990024;//库存明细数量与当前业务操作数量不一致
	public static Integer CARD_TYPE_NOT_EQUALS=99990025;//卡类型不一致
	public static Integer LEDGER_NOT_EXIST=99990026;//账户不存在
	public static Integer CARD_NOT_BELONG_OPERATOE=99990027;//卡片不属于当前操作员
	public static Integer STK_STATE_NOT_NORMAL=99990028;//库存状态不正常
	public static Integer CARD_EXIST_GREY_RECORD=99990029;//卡片存在灰记录
	public static Integer ENCRYPT_KEY_BIZID_NOT_NULL=99990031;//获取密钥商户不能为空
	public static Integer ENCRYPT_KEY_TERMID_NOT_NULL=99990032;//获取密钥商户不能为空
	public static Integer ENCRYPT_PIN_NOT_NULL=99990034;//密码不能为空
	public static Integer ENCRYPT_CREATE_CARD_ENCRYPTPIN_ERR=99990035;//生成卡密码异常
	public static Integer ENCRYPT_KEY_NULL=99990037;//密钥获取失败
	public static Integer ENCRYPT_KEY_SYS_ERR=99990038;//密钥系统返回异常
	public static Integer ENCRYPT_KEY_ERR=99990039;//密钥系统其它未知异常
	public static Integer TOO_MANY_PERSON=99990040;//人员信息过多,请输入详细信息
	public static Integer RULE_ERR=99990050;//调用规则接口异常
	public static Integer NO_RIGHT_OPERATE_CARD=99990051;//您无权操作此卡片

}
