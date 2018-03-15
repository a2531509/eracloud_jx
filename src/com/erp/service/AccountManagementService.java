package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.AccCreditLimit;
import com.erp.model.AccKindConfig;
import com.erp.model.AccOpenConf;
import com.erp.model.AccStateTradingBan;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;

public interface AccountManagementService extends BaseService{
	/**
	 * 账户类型新增保存，编辑保存
	 * @param config   账户类型信息
	 * @param otype    操作类型 otype == 0 新增  otype == 1 编辑
	 * @return         操作日志
	 * @throws CommonException
	 */
	public TrServRec saveOrUpdateAccKindConfig(AccKindConfig config,String otype) throws CommonException;
	/**
	 * 
	 * @param config
	 * @param type
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveEnableOrDisable(AccKindConfig config,String type) throws CommonException;
	/**
	 * 
	 * @param accKind
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveAccKindConfigDelete(String accKind) throws CommonException;
	/**
	 * 
	 * @param conf
	 * @param type
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveOrUpdateAccOpenConf(AccOpenConf conf,String type) throws CommonException;
	/**
	 * 
	 * @param id
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveAccOpenConfDelete(Long id) throws CommonException;
	/**
	 * 
	 * @param id
	 * @param type
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveDisableOrEnableAccOpenConf(Long id,String type) throws CommonException;
	/**
	 * 
	 * @param ban
	 * @param type
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveOrUpdateAccStateTradingBan(AccStateTradingBan ban,String type) throws CommonException;
	/**
	 * 
	 * @param id
	 * @return
	 * @throws CommonException
	 */
	public TrServRec  saveAccStateTradingBanDelete(Long id)throws CommonException;
	/**
	 * 
	 * @param id
	 * @param type
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveDisableOrEnableAccStateTradingBan(Long id,String type) throws CommonException;
	
	/**
	 * 
	 * @param acc
	 * @param limit
	 * @param rec
	 * @param type
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveOrUpdateAccLimit(AccCreditLimit limit,TrServRec rec,String type) throws CommonException;
	/**
	 * 
	 * @param dealNo
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveAccLimitDelete(Long dealNo) throws CommonException;
	/**
	 * 
	 * @param dealNo
	 * @param type
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveDisableOrEnableAccLimit(Long dealNo,String type) throws CommonException;
	
	/**
	 * 账户锁定与解锁
	 * @param cardNo  锁定/解锁的卡号
	 * @param accKind 锁定/解锁的账户类型
	 * @param type    type == 0 锁定  type == 1 解锁
	 * @return  操作业务日志
	 */
	public TrServRec saveAccountLockOrUnlock(String cardNo,String accKind,String type)throws CommonException;
	/**
	 * 账户状态激活（未激活状态的账户进行激活）
	 * @param cardNo  卡号
	 * @param accKind 账户类型
	 * @param log     操作日志
	 * @return
	 */
	public TrServRec saveAccEnableQuery(String cardNo,String accKind,String pwd,TrServRec rec,SysActionLog log) throws CommonException;
	/**
	 * 账户金额冻结
	 * @param cardNo     冻结卡号
	 * @param accKind    冻结账户类型
	 * @param freezeAmt  冻结金额
	 * @param users      操作用户
	 * @param rec        操作业务日志
	 * @param log        操作日志
	 * @return           操作业务日志
	 * @throws CommonException
	 */
	public TrServRec  saveAccFreeze(String cardNo,String accKind,Long freezeAmt,String pwd,Users users,TrServRec rec,SysActionLog log) throws CommonException;
	/**
	 * 账户金额解冻
	 * @param dealNo  原始冻结流水
	 * @param pwd     账户密码
	 * @param users   操作员
	 * @param rec     业务日志
	 * @param log     操作日志
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveAccUnFreeze(long dealNo,String pwd,Users users,TrServRec rec,SysActionLog log) throws CommonException;
}
