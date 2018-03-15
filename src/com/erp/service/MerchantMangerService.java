package com.erp.service;

import java.util.Date;
import java.util.List;

import com.erp.exception.CommonException;
import com.erp.model.BaseEndOut;
import com.erp.model.BaseMerchant;
import com.erp.model.BaseMerchantType;
import com.erp.model.BaseTagEnd;
import com.erp.model.CardOrgBindSection;
import com.erp.model.PayAcctypeSqn;
import com.erp.model.PayFeeRate;
import com.erp.model.PayMerchantLim;
import com.erp.model.StlMode;
import com.erp.model.SysActionLog;
import com.erp.model.Users;

/**
 * 
 * @author thinkpad
 *
 */
public interface MerchantMangerService extends BaseService {
	
	public List cancelMerType(String merTypeId) throws CommonException;
	
	public void saveMerType(SysActionLog actionLog,BaseMerchantType mtype)throws CommonException;
	
	/**
	 * 判断是否已经存在相同的商户名
	 */
	public boolean checkBiz_Name(String Biz_Name) throws CommonException;
	
	/**
	 *保存商户信息
	 */
	public  String  saveMer(BaseMerchant merchant,SysActionLog actionLog,Users user,BaseMerchant mer_old,StlMode merchantStlMode)throws CommonException;
	
	/**
	 * 保存商户限额参数
	 * @param merLmt
	 * @param actionLog
	 * @param user
	 * @throws CommonException
	 */
	public void saveMerchantQuota(PayMerchantLim merLmt,SysActionLog actionLog, Users user)throws CommonException;
	
	/**
	 * 保存商户消费账户控制
	 * @param acckinds
	 * @param merchantId
	 * @param actionLog
	 * @throws CommonException
	 */
	public void saveMerchantConsLmt(String acckinds,String merchantId,SysActionLog actionLog)throws CommonException;
	
	/**
	 * 商户结算模式保存
	 * @param mode
	 * @param actionLog
	 * @throws CommonException
	 */
	public void saveMerchantStlMode(StlMode mode ,SysActionLog actionLog) throws CommonException;
	/**
	 * 删除商户结算模式
	 * @param merchantId
	 * @param valilDate
	 * @throws CommonException
	 */
	public void delMerMode(String merchantId,String valilDate,SysActionLog actionLog)throws CommonException;
	/**
	 * 保存商户费率信息
	 * @param payFeeRate
	 * @param actionLog
	 * @param users
	 * @param dealType
	 * @param list
	 * @throws CommonException
	 */
	public void saveClr_Fee_Rate(PayFeeRate payFeeRate,SysActionLog actionLog,Users users, String dealType,List list) throws CommonException;
	/**
	 * 审核商户费率信息
	 * @param payFeeRate
	 * @param actionLog
	 * @param users
	 * @throws CommonException
	 */
	public void chkRate(PayFeeRate payFeeRate,SysActionLog actionLog,Users users)throws CommonException;
	/***
	 * 删除费率
	 * @param payFeeRate
	 * @param actionLog
	 * @param users
	 * @throws CommonException
	 */
	public void delRate(PayFeeRate payFeeRate,SysActionLog actionLog,Users users)throws CommonException;
	/**
	 * 商户终端保存
	 * @param tagEnd
	 * @param actionLog
	 * @param users
	 * @throws CommonException
	 */
	public void saveMerTerm(BaseTagEnd tagEnd,SysActionLog actionLog,Users users)throws CommonException;
	/**
	 * 商户终端启用或注销
	 * @param endId
	 * @param type
	 * @throws CommonException
	 */
	public void saveDisableOrEnableMerTer(String endId,String type)throws CommonException;
	/**
	 * 终端信息报废
	 * @param endid
	 * @param actionLog
	 * @throws CommonException
	 */
	public void delTermInfo(String endid,SysActionLog actionLog)throws CommonException;
    /**
	 * 终端信息报修
     * @param endid
     * @param maintCorp
     * @param maintPhone
     * @param actionLog
     * @throws CommonException
     */
	public void updateTermRepairs(String endid,String maintCorp,String maintPhone,String note,Date maintPeriod,SysActionLog actionLog)throws CommonException;
	/**
	 * 保存终端出库信息
	 * @param baseEndOut
	 * @throws CommonException
	 */
	public void saveOutbound(BaseEndOut baseEndOut,String endid)throws CommonException;
	/**
	 * 终端回收
	 * @param endid
	 * @param recycleDate
	 * @param recycleUserId
	 * @param recycleTime
	 * @param actionLog
	 * @throws CommonException
	 */
	public void updateRecycle(String endid,String recycleDate,String recycleUserId,Date recycleTime,SysActionLog actionLog)throws CommonException;
	/**
	 * 结算审核保存
	 * @param operator
	 * @param ids
	 */
	
	public void savesettlementAudit(SysActionLog actionLog,Users operator, String[] ids)throws CommonException;
	/**
	 * 回退商户结算
	 * @param actionLog
	 * @param operator
	 * @param stlNo
	 * @throws CommonException
	 */
	public void saverollback(SysActionLog actionLog,Users operator,String stlNo)throws CommonException;
	/**
	 * 商户结算报表打印
	 */
	public SysActionLog savePrintReport(SysActionLog actionLog,Users operator,String stlNos)throws CommonException;

	/**
	 * 商户结算支付
	 * @param actionLog
	 * @param operator
	 * @param ids
	 * @param bankSheetNo
	 * @throws CommonException
	 */
	public void savesettlementPayment(SysActionLog actionLog,Users operator, String ids, String bankSheetNo)throws CommonException;
	/**
	 * 商户结算模式修改保存
	 * @param actionLog
	 * @param operator
	 * @param paySqn
	 * @param dealType
	 * @throws CommonException
	 */
	public void saveConsumeMode(SysActionLog actionLog,Users operator,PayAcctypeSqn paySqn)throws CommonException;
	/**
	 * 保存商户消费模式设置
	 * @param actionLog
	 * @param operator
	 * @param merchantId
	 * @param modeIds
	 * @throws CommonException
	 */
	public void saveMerGetCosMode(SysActionLog actionLog,Users operator,String merchantId,String modeIds) throws CommonException;
	/**
	 * 保存商户消费模式设置
	 * @param actionLog
	 * @param operator
	 * @param merchantId
	 * @param modeIds
	 * @throws CommonException
	 */
	public void saveMerGetCosModeEdit(SysActionLog actionLog,Users operator,String merchantId,String modeId,String modeState) throws CommonException;

	/**
	 * 更新商户状态信息
	 * @param customerId
	 * @param user
	 * @param actionLog
	 * @param queryType
	 * @throws CommonException
	 */
	public void updateState(Long  customerId,Users user,SysActionLog actionLog, String queryType)throws CommonException;

	/**
	 * 商户即时结算
	 * @param merchantId
	 * @param users
	 */
	public void saveMerSettleImmediate(String merchantId, Users users);

	void saveMerTerm(BaseTagEnd tagEnd, String type);

	public void saveOutboundCancel(String endId);

	public List<BaseTagEnd> saveMerTerm(List<BaseTagEnd> terminals);

	public void saveAddCardOrgBindSection(CardOrgBindSection bindSection, SysActionLog currentActionLog);
}
