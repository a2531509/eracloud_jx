package com.erp.service;

import java.util.List;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;

public interface CashManageService extends BaseService{
	/**
	 * 查询柜员尾箱信息
	 * @param sql    查询sql
	 * @param page   第几页
	 * @param rows   每页多少条
	 * @return       list 列表柜员尾箱信息
	 * @throws CommonException
	 */
	public List<?> toQueryCashBox(String sql,Integer page,Integer rows) throws CommonException;
	
	/**
	 * 柜员调剂，当前柜员向其他柜员调剂现金尾箱
	 * @param currentUser  当前调剂柜员
	 * @param inUser       接收柜员
	 * @param amt          调剂金额  @单位：分
	 * @return             业务操作日志
	 * @throws CommonException
	 */
	public Long saveTellerTransfer(Users currentUser,Users inUser,long amt) throws CommonException;
	
	/**
	 * 网点存款确认
	 * @param oper  操作员
	 * @param amt   网点存款金额  单位：分
	 * @param bankNo网点存款银行存款凭证号
	 * @return      业务操作流水
	 */
	public Long saveCertainDeposit(Users oper,Long amt,String bankNo) throws CommonException;
	
	/**
	 * 网点预存款（新版）只记录存款灰记录不进行实际转账
	 * @param oper    操作员
	 * @param amt     预存款金额
	 * @param bankNo  银行存款编号
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveCertainDepositPre(Users oper,Long amt,String bankNo) throws CommonException;
	
	/**
	 * 网点预存款确认（新版）
	 * @param oper   操作员
	 * @param dealNo 确认流水
	 * @return
	 * @throws CommonException
	 */
	public Long saveCertainDepositConfirm(Users oper,Long dealNo) throws CommonException;

	public SysActionLog saveLog(SysActionLog log);
	
}
