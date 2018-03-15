package com.erp.service;

import java.math.BigDecimal;
import java.util.List;

import com.erp.model.AccAccountSub;
import com.erp.model.BaseCorp;
import com.erp.model.BaseCorpRechargeInfo;
import com.erp.model.BaseCorpRechargeList;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;

/**
 * 单位管理服务接口
 * 
 * @author Yueh
 */
public interface CorpManagerService extends BaseService {

	void saveCorpRegist(BaseCorp corp);

	void saveCorpModify(BaseCorp corp);

	void saveRegistCheck(String customerId, Boolean checkSuccess, Users users);

	void saveCorpEnable(String customerId, Boolean enbaled, Users users);

	void createCorpAcc(String customerId);

	/**
	 * 单位现金账户充值
	 * 
	 * @param customerId
	 * @param amount
	 * @return 
	 */
	TrServRec saveCashAccRecharge(String customerId, BigDecimal amount);

	/**
	 * 单位批量充值数据导入, 用于导入单位批量充值数据, 返回导入失败的记录
	 * 
	 * @param batchRechargeInfos
	 *            单位批量充值数据
	 * @param customerId
	 *            单位customerId
	 * @param jugeCorp 
	 * @return 导入失败的记录
	 */
	List<BaseCorpRechargeList> saveImportBatchRechargeInfo(List<BaseCorpRechargeList> batchRechargeInfos, String customerId, Boolean jugeCorp);

	/**
	 * 单位批量充值导入数据审核通过, 审核导入单位批量充值数据, 返回审核失败的记录
	 * 
	 * @param batchRechargeInfos
	 *            单位批量充值数据
	 * @param customerId
	 *            单位customerId
	 * @return 审核失败的记录
	 */
	List<BaseCorpRechargeList> saveCheckPassImportBatchRechargeInfo(List<BaseCorpRechargeList> batchRechargeInfos, String customerId);

	/**
	 * 对已审核的批量充值数据, 对相应的账户(全功能卡联机账户)进行充值处理
	 * 
	 * @param batchRechargeInfos
	 *            已审核的单位批量充值数据
	 * @param corpId
	 *            单位customerId
	 * @return 充值失败的记录
	 */
	List<BaseCorpRechargeList> saveRechargeBatchRechargeInfo(List<BaseCorpRechargeList> batchRechargeInfos, String corpId);

	/**
	 * 删除导入的批量充值数据, 返回删除失败的记录
	 * 
	 * @param batchRechargeInfos
	 * @param customerId
	 */
	List<BaseCorpRechargeList> deleteBatchRechargeInfo(List<BaseCorpRechargeList> batchRechargeInfos, String customerId);

	public void accouting_ghk(AccAccountSub paramAccAccountSub1, AccAccountSub paramAccAccountSub2, BigDecimal paramBigDecimal, SysActionLog paramSysActionLog, String paramString1, String paramString2, String paramString3, String paramString4, String paramString5);

	void deleteBatchRechargeInfo(BaseCorpRechargeInfo info);
}
