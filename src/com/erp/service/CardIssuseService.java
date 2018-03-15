package com.erp.service;

import java.util.List;

import com.erp.exception.CommonException;
import com.erp.model.CardApply;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;



public interface CardIssuseService extends BaseService{
	
	/**
	 * 个人发放登记保存
	 * @param apply 申领实体
	 * @param card 卡片信息实体
	 * @param actionlog 日志实体
	 * @return TrServRec
	 * @throws CommonException
	 */
	public TrServRec saveOneCardIssuse(CardApply apply,CardBaseinfo card)throws CommonException;
	/**
	 * 规模发放登记保存
	 * @param customerIdList 申领实体
	 * @param actionlog 日志实体
	 * @param flag 规模发放标志0，全部发放，1部分发放
	 * @param actionlog 日志实体
	 * @param customerIdList 人员编号的数组
	 * @return TrServRec
	 * @throws CommonException
	 */
	@SuppressWarnings("rawtypes")
	public void saveBatchIssuse(String[] task_Ids,SysActionLog actionLog,TrServRec serv,String org_Id,String flag,List customerIdList)throws CommonException;
	
	public TrServRec saveBatchCardIssuse(String taskIdOrCardNo,String flag,Users oper,TrServRec rec,SysActionLog actionLog, boolean syncOldCard2Sb) throws CommonException;
    /**
     * 人个发放撤销
     * @param apply_Id
     * @param actionLog
     * @param serv
     * @return
     * @throws CommonException
     */
	@SuppressWarnings("rawtypes")
	public TrServRec saveUndoCardIssuse(String apply_Id,SysActionLog actionLog,TrServRec serv)throws CommonException;
	
		
}
