package com.erp.service;

import java.io.File;
import java.util.Map;

import net.sf.jasperreports.web.commands.CommandException;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import org.apache.poi.ss.usermodel.Workbook;


public interface RechargeService extends BaseService {
	/**
	 * 钱包充值记录灰记录
	 * @param map     充值参数信息
	 * @param trCode  充值交易码
	 * @return        记录灰记录流水
	 * @throws CommandException
	 */
	public TrServRec saveHjlWallet(Map<String,Object> map,Integer trCode) throws CommandException;
	/**
	 * 钱包充值灰记录自动处理
	 * @param inpara
	 * cardNo 充值卡号
	 * cardAmt 卡面金额
	 * cardTrCount 交易计数器
	 * 需要特殊处理可加参数
	 * @return
	 */
	public Long saveAutoWalletAshDeal(Map inpara,Users oper,SysActionLog log) throws CommonException;
	/**
	 * 钱包充值灰记录确认
	 * @param map  钱包充值灰记录确认参数信息
	 * @return     灰记录原始流水
	 * @throws CommonException
	 */
	public Long saveWalletAshConfirm(Map<String,Object> map) throws CommonException;
	/**
	 * 钱包充值灰记录冲正
	 * @param map  冲正参数信息
	 * @return     冲正结果
	 * @throws CommonException
	 */
	public JSONObject saveWalletAshCancel(Map map) throws CommonException;
	
	/**
	 * 现金联机账户充值
	 * @param hm     现金联机充值参数信息
	 * @param trCode 交易码
	 * @return
	 */
	public TrServRec saveOnlineAccRecharge(Map hm,Integer trCode)throws CommonException;
	
	/**
	 * 充值撤销
	 * @param hm
	 * @param trCode
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveAccRechargeRevoke(Map hm,Integer trCode) throws CommonException;
	
	/**
	 * 钱包账户充值撤销
	 * @param map    撤销相关的参数信息
	 * @param trCode 撤销交易码
	 * @return       撤销业务日志信息
	 * @throws CommonException
	 */
	//public TrServRec saveOfflineAccRechargeCancel(Map<String,Object> map,Integer trCode) throws CommonException;
	
	public TrServRec saveTransferOnlineAcc2OnlineAcc(Map<String,Object> initparameters) throws CommonException;
	
	/**
	 * 联机账户转钱包账户
	 * @param initparameters
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveTransferOnlineAcc2OfflineAcc(Map<String,Object> initparameters) throws CommonException;
	
	/**
	 * 联机转脱机灰记录确认
	 * @param map
	 * @throws CommonException
	 */
	public void saveTransferToWalletConfirm(Map map) throws CommonException;
	/**
	 * 联机转脱机灰记录取消
	 * @param map
	 * @throws CommonException
	 */

	public void saveTransferToWalletCancel(Map map) throws CommonException;
	/**
	 * 脱机账户转联机账户
	 * @param map
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveTransferOfflineAcc2OnlineAcc(Map<String, Object> map) throws CommonException;
	/**
	 * 脱机转联机灰记录确认
	 * @param map
	 * @throws CommonException
	 */
	public void saveTransferToOnlineConfirm(Map<String, Object> map) throws CommonException;
	/**
	 * 脱机转联机灰记录取消
	 * @param map
	 * @throws CommonException
	 */
	public void saveTransferToOnlineCancel(Map<String, Object> map) throws CommonException;
	public TrServRec saveDealAshRecordConfrim(Map map) throws CommonException;
	public TrServRec saveDealAshRecordCancel(Map map) throws CommonException;
	/**
	 * 充值卡充值
	 * @param cardNo
	 * @param rechargeCardNo
	 * @param rechargeCardPassword
	 * @throws CommonException
	 * @return
	 */
	public TrServRec saveRechargeCardAccount(String cardNo, String rechargeCardNo, String rechargeCardPassword) throws CommonException;
	
	/**
	 * 》》新版账户转账公用方法
	 * @param hm HashMap
     * userId    	        操作员编号
     * trBatchNo 	         批次号
     * termTrNo  	         终端交易流水号
	 * outCardNo     	转出卡号
	 * outAccKind       转出卡转出账户类型
	 * outCardTrCount 	转出卡交易计数器
	 * outCardAmt		转出卡钱包交易前金额
	 * isJudgeOutCardHjl是否判断转出卡有灰记录
	 * inCardNo     	转入卡号
	 * inAccKind 		转入卡账户类型
	 * inCardTrCount 	转入卡交易计数器
	 * inCardAmt		转入卡钱包交易前金额
	 * isJudgeInCardHjl 是否判断转入卡有灰记录
	 * dealCode         交易代码
	 * amt  			转账金额  null时转出所有金额
	 * isJudgeOutAccPwd 是否判断转出卡密码 0 判断
	 * pwd				转账密码
	 * dealState        9写灰记录0直接写正常记录
	*/
	public TrServRec saveAccTransfer(Map<String, Object> inParameters) throws CommonException;
	/**
	 * 脱机转联机灰记录确认
	 * @param map
	 * @throws CommonException
	 */
	public void saveAccTransferConfirm(Map<String, Object> map) throws CommonException;
	/**
	 * 脱机转联机灰记录取消
	 * @param map
	 * @throws CommonException
	 */
	public void saveAccTransferCancel(Map<String, Object> map) throws CommonException;
	
	/**
	 * 好卡换卡转钱包
	 * @param inParameters
	 * @return
	 */
	public TrServRec saveHkzzGoodCard(Map<String, Object> inParameters);
	/**
	 * 根据卡号获取银行卡绑定信息及圈存限额信息
	 * @param cardNo卡号
	 * @return
	 * @throws CommonException
	 */
	public Map getCardBindBankInfo(String cardNo,String type) throws CommonException;
	
	/**
	 * 银行圈存到联机账户
	 * @param inParameters
	 * @return
	 */
	public TrServRec saveOnAccRecharge(Map hm,Integer trCode)throws CommonException;
	
	/**
	 * 联机账户圈提到银行卡 
	 * @param inParameters
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveOnAccRechargeToBank(Map hm,Integer trCode)throws CommonException;
	public long saveImportAccBalReturnData(File file);
	public void saveProcessAccBalReturnData(long dealNo);
	public void saveReturn(Long dealNo);
	public void saveReturn(String string, Long dealNo);
	public void deleteAccBalReturnData(Long dealNo);
	/**
	 * 批量充值导入
	 * @param file
	 * @param accKind
	 * @param isAudit
	 * @param rec
	 * @param actionLog
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveImportBatchRechargeData(Workbook file,String accKind,String isAudit,TrServRec rec,SysActionLog actionLog) throws CommonException;

	public int saveBatchRecharge(long dataSeq,Users oper,SysActionLog actionLog) throws CommonException;
	public void saveBatchRechargeStateChanged(long dataSeqOrdataId,String operType,String changedState,Users oper,TrServRec rec,SysActionLog actionLog) throws CommonException;
}
