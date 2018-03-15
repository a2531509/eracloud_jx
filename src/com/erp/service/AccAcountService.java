package com.erp.service;

import java.math.BigDecimal;
import java.util.HashMap;

import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.SysActionLog;

public interface AccAcountService extends BaseService {
	
	/**
	 * 建立账户  先保存cm_card,sys_branch等表后再调用
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			obj_type 类型（与账户主体类型一致，0-网点1-个人/卡 2-单位 3-商户4-机构）
	 * 			sub_type 子类型（可放卡类型，或者商户类型之类的信息）
	 * 			obj_id   账户主体类型是卡时，传入卡号，其它传入client_id，(多个卡号时，卡号之间以,分割 cardno1,cardno2)
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap createAccount(SysActionLog log,HashMap hm) throws CommonException;
	
	/**
	 * 建立账户撤销
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			obj_type 类型（与账户主体类型一致，0-网点1-个人/卡 2-单位 3-商户4-机构）
	 * 			sub_type 子类型（可放卡类型，或者商户类型之类的信息）
	 * 			obj_id   账户主体类型是卡时，传入卡号，其它传入client_id
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap createAccountCancel(SysActionLog log,HashMap hm) throws CommonException;
	
	/**
	 * 充值写灰记录（充值送、 收押金、更改信用额度 也调用这个）
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			acpt_id  		受理点编号(网点号或商户编号)
	 * 			oper_id  		操作员编号或终端号
	 * 			tr_batch_no 	批次号
	 * 			term_tr_no  	终端交易流水号
	 * 			card_no     	卡号
	 *			card_tr_count 	卡交易计数器
	 *			card_bal		钱包交易前金额
	 *			acc_kind 		账户类型
	 *			wallet_id		钱包编号 默认00
	 *			tr_amt			充值金额(更改信用额度时传入更改后的信用额度)
	 *			pay_source		充值资金来源0现金1转账2充值卡3促销4更改信用额度5网点预存款
	 *			sourcecard		充值卡卡号或银行卡卡号
	 *			rechg_pwd		充值卡密码
	 *			tr_state        9写灰记录0直接写正常记录
	 *			acpt_type		受理点分类，0商户1网点
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap recharge(SysActionLog log,HashMap hm) throws CommonException;
	
	/**
	 * 新版联机账户充值
	 * @param log
	 * @param hm
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings({"rawtypes" })
	public HashMap saveOnLineAccRecharge(SysActionLog log,HashMap hm)throws CommonException;
	/**
	 * 充值到网点预存款账户
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			acpt_id  		预存款的网点
	 *			tr_amt			充值金额(更改信用额度时传入更改后的信用额度)
	 *			pay_source		充值资金来源0现金1转账4更改信用额度
	 *			tr_state        9写灰记录0直接写正常记录
	 *			acpt_type		受理点分类，0商户1网点
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap recharge2Brch(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 充值确认
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		充值时的业务流水号
	 * 			clr_date		写灰记录时的清分日期
	 * 			card_no			卡号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap rechargeConfirm(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 充值撤销
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		充值时的业务流水号
	 * 			clr_date		撤销记录的清分日期
	 * 			card_no			卡号-----不用
	 * 			tr_state		原充值记录状态（ 灰记录或正常记录）, 对应的处理是冲正和撤销
	 *			card_tr_count 	卡交易计数器
	 *			card_bal		钱包交易前金额
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap rechargeCancel(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 充值冲正记录转成灰记录状态
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		充值时的业务流水号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap rechargeCancel2Ash(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 账户返现
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			acpt_id  		受理点编号(网点号或商户编号)
	 * 			oper_id  		操作员编号或终端号
	 * 			tr_batch_no 	批次号
	 * 			term_tr_no  	终端交易流水号
	 * 			card_no     	卡号
	 *			card_tr_count 	卡交易计数器
	 *			card_bal		钱包交易前金额
	 *			acc_kind 		账户类型
	 *			wallet_id		钱包编号 默认00
	 *			tr_amt			返现金额
	 *			acpt_type		受理点分类，0商户1网点
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap returnCash(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 转账写灰记录
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			acpt_id  		受理点编号(网点号或商户编号)
	 * 			oper_id  		操作员编号或终端号
	 * 			tr_batch_no 	批次号
	 * 			term_tr_no  	终端交易流水号
	 * 			card_no1     	转出卡号
	 *			card_tr_count1 	转出卡交易计数器
	 *			card_bal1		转出卡钱包交易前金额
	 *			acc_kind1 		转出卡账户类型
	 *			wallet_id1		转出卡钱包编号 默认00
	 * 			card_no2     	转入卡号
	 *			card_tr_count2 	转入卡交易计数器
	 *			card_bal2		转入卡钱包交易前金额
	 *			acc_kind2 		转入卡账户类型
	 *			wallet_id2		转入卡钱包编号 默认00
	 *			tr_amt			转账金额  null时转出所有金额
	 *			pwd				转账密码
	 * 			tr_state        9写灰记录0直接写正常记录
	 *			acpt_type		受理点分类，0商户1网点
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap transfer(SysActionLog log,HashMap<String,String> hm) throws CommonException;
	/**
	 * 转账确认
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		转账时的业务流水号
	 * 			clr_date		写灰记录时的清分日期
	 * 			card_no1		转出卡号
	 * 			card_no2		转入卡号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap transferConfirm(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 转账撤销
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		转账时的业务流水号
	 * 			clr_date		写灰记录时的清分日期
	 * 			tr_state		原转账记录状态  灰记录或正常记录允许撤销
	 * 			card_no1		转出卡号
	 * 			card_no2		转入卡号
	 *			card_tr_count1 	转出卡卡交易计数器
	 *			card_tr_count2 	转入卡卡交易计数器
	 *			card_bal1		转出卡钱包交易前金额
	 *			card_bal2		转入卡钱包交易前金额
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap transferCancel(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 记现金尾箱
	 * @param userId String 操作员
	 * @param amt Long 记账金额 单位:分           
	 * @param actionLog 业务操作日志
	 * @param flag 收付标志 Constants.IN_OUT_FLAG_SR 收;Constants.IN_OUT_FLAG_FC 付
	 * @param note 备注
	 * @throws CommonException
	 */
	public HashMap updateCashBox(String  userId,Long amt,SysActionLog actionLog,String flag) throws CommonException;
	/**
	 * 收取服务费、工本费等、销售充值卡、网点存款、网点取款也调用这个
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			item_no  	收费类型（用科目号，充值卡销售201104，网点存取款102100，工本费702101，其它收入709999等）
	 * 			amt			金额  正值现金收入 负值现金支出
	 *			acpt_type	受理点分类，0商户1网点
	 *			pay_source  0现金1非现金
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap cost(SysActionLog log,HashMap hm) throws CommonException;
	
	/**
	 * 押金记账接口
	 * @param acptType 受理点类型 Constants.ACPT_TYPE_SH = 0 商户   Constants.ACPT_TYPE_GM = 1 网点
	 * @param userId String 操作员
	 * @param amt Long 记账金额 单位:分     
	 * @param paySource 付款方式 0 现金 1 转账
	 * @param actionLog 业务操作日志
	 * @param note 备注
	 * @throws CommonException
	 */
	public HashMap yjjz(String acptType,String userId,Long amt,String paySource,SysActionLog actionLog);
	/**
	 * 工本费记账接口
	 * @param acptType 受理点类型 Constants.ACPT_TYPE_SH = 0 商户   Constants.ACPT_TYPE_GM = 1 网点
	 * @param userId String 操作员
	 * @param amt Long 记账金额 单位:分      
	 * @param paySource 付款方式 0 现金 1 转账     
	 * @param actionLog 业务操作日志
	 * @param note 备注
	 * @throws CommonException
	 */
	public HashMap gbfjz(String acptType,String userId,Long amt,String paySource,SysActionLog actionLog) throws CommonException;
	
	/**
	 * 其他收入记账接口
	 * @param acptType 受理点类型 Constants.ACPT_TYPE_SH = 0 商户   Constants.ACPT_TYPE_GM = 1 网点
	 * @param userId String 操作员
	 * @param amt Long 记账金额 单位:分           
	 * @param paySource 付款方式 0 现金 1 转账
	 * @param actionLog 业务操作日志
	 * @param note 备注
	 * @throws CommonException
	 */
	public HashMap qtsr(String acptType,String userId,Long amt,String paySource,SysActionLog actionLog) throws CommonException;
	/**
	 * 自行车押金记账接口
	 * @param acptType 受理点类型 Constants.ACPT_TYPE_SH = 0 商户   Constants.ACPT_TYPE_GM = 1 网点
	 * @param userId String 操作员
	 * @param amt Long 记账金额 单位:分         金额   正金额    =  收押金   ; 负数   =  付押金  
	 * @param paySource 付款方式 0 现金 1 转账
	 * @param actionLog 业务操作日志
	 * @param note 备注
	 * @throws CommonException
	 */
	public HashMap zxcjz(String acptType,String userId,Long amt,String paySource,SysActionLog actionLog) throws CommonException;
	/**
	 * 现金交接
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			oper_id1  	付出方柜员
	 * 			oper_id2	收入方柜员
	 * 			amt			金额
	 *			acpt_type	受理点分类，0商户1网点
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap cashHandOver(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 轧账
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			oper_id  	要轧账的操作员，传入空的话对log中的操作员轧账
	 * 			clr_date    要轧账的日期，传入空的话对当日轧账
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap daybal(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 商户结算
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			biz_id  	商户号  传入空的时候表示对所有商户结算
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap merchantSettle(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 商户即时结算
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			biz_id  	商户号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap merchantSettleImmeidate(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 商户结算回退
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			stl_sum_no  	商户结算汇总序号(回退之后的结算记录)
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap merchantSettleRollback(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 商户结算支付
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			stlsumnos  要支付的结算记录  STL_SUM_NO$CARD_TYPE$ACC_KIND,STL_SUM_NO$CARD_TYPE$ACC_KIND
	 * 			bank_sheet_no 银行回单号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap merchantSettlePay(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 积分兑换
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			card_no     	卡号
	 *			tr_amt			兑换的积分数
	 *			type		         兑换类型 1兑换到未圈存账户2兑换礼品
	 *			acpt_type		受理点分类，0商户1网点
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap pointsExchange(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 积分兑换撤销
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no		被撤销记录的action_no
	 * 			clr_date		被撤销记录的清分日期
	 * 			card_no     	卡号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap pointsExchangeCancel(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 脱机消费灰记录确认
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		消费的业务流水号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap offlineConsumeConfirm(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 脱机消费退货
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		消费的业务流水号
	 * 			clr_date 		消费记录的清分日期
	 *			card_tr_count 	卡交易计数器
	 *			card_bal		钱包交易前金额
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap offlineConsumeReturn(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 脱机消费灰记录冲正
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		消费的业务流水号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap offlineConsumeCancel(SysActionLog log,HashMap hm) throws CommonException;
	/**
	 * 脱机消费拒付改成正常
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		消费的业务流水号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap offlineConsumeBlack2Normal(SysActionLog log,HashMap hm) throws CommonException;
	
	/**
	 * 根据科目号和客户号(网点号)查询分户账
	 * 
	 * @param item_No
	 * @param client_Id
	 * @param sub_Acc_No
	 * @return
	 * @throws CommonException
	 */
	public AccAccountSub getAccSubLedgerByItemNoAndClientid(String item_No, String client_Id, Long sub_Acc_No) throws CommonException;
	/**
	 * 根据卡号和账户种类、钱包编号查询分户账
	 * 
	 * @param card_No
	 * @param acc_Kind
	 * @param wallet_Id
	 * @return
	 * @throws CommonException
	 */
	public AccAccountSub getAccSubLedgerByCardNoAndAccKind(String card_No, String acc_Kind, String wallet_Id) throws CommonException;
	
	/**
	 * 记账流水撤销
	 * Description <p>TODO</p>
	 * @param paramSysActionLog
	 * @param paramString
	 * @throws CommonException
	 */
	public void saveCancelDayBook(SysActionLog paramSysActionLog, String paramString)throws CommonException;
	
	/**
	 * 
	 * Description <p>TODO</p>
	 * @param accountDb
	 * @param accountCr
	 * @param amount
	 * @param log
	 * @param credit
	 * @param batchNo
	 * @param termNo
	 * @param state
	 * @param note
	 * @throws CommonException
	 */
	public void account(AccAccountSub accountDb, AccAccountSub accountCr, BigDecimal amount, SysActionLog log, String credit, String batchNo, String termNo, String state, String note)
		    throws CommonException;
	

}
