package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.AccAdjustInfo;
import com.erp.model.PayOfflineBlack;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;

public interface AdjustSysAccService extends BaseService {
	
	/**
	 * 添加调账信息
	 * @param adjustInfo
	 * @param actionLog
	 * @param user
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveAddAdjustInfo(AccAdjustInfo adjustInfo,SysActionLog actionLog,Users user) throws CommonException;
	/**
	 * 审核调账信息
	 * @param ids
	 * @param actionLog
	 * @param user
	 * @throws CommonException
	 */
	public void saveCheckAdjustInfo(String ids,SysActionLog actionLog,Users user) throws CommonException;
	
	/**
	 * 删除调账信息
	 * @param ids
	 * @param actionLog
	 * @param user
	 * @throws CommonException
	 */
	public void saveDelAdjustInfo(String ids,SysActionLog actionLog,Users user) throws CommonException;
	
	/**
	 * 添加调账信息
	 * @param adjustInfo
	 * @param actionLog
	 * @param user
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveDealAdjustInfo(AccAdjustInfo adjustInfo,SysActionLog actionLog,Users user) throws CommonException;
	
	/**
	 * 电子钱包数据处理
	 * @param polb
	 * @param actionLog
	 * @param rec
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveProcessWallet(PayOfflineBlack polb,SysActionLog actionLog,TrServRec rec) throws CommonException;
	/**
	 * 
	 * @param actionLog
	 * @param oldDealNo
	 * @param amt
	 * @param cardNo
	 * @param accKind
	 * @param oldClrDate
	 * @param userId
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveDealCancel(SysActionLog actionLog,String oldDealNo,String amt,String cardNo,String accKind,String oldClrDate,String userId) throws CommonException;
}
