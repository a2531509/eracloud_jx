package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.PointsRule;
import com.erp.model.SysActionLog;
import com.erp.model.Users;


/**
 * 积分管理
 * @author Hujc
 *
 */
public interface PointManageService extends BaseService {
	
	/**
	 * 保存积分管理参数
	 * @param actionLog
	 * @param user
	 * @param para
	 * @throws CommonException
	 */
	public void saveOrUpdatePointPara(SysActionLog actionLog,Users user,PointsRule para) throws CommonException;
	
	/**
	 * 删除积分参数
	 * @param actionLog
	 * @param user
	 * @param paraIds
	 * @throws CommonException
	 */
	public void deletePointPara(SysActionLog actionLog,Users user,String paraIds) throws CommonException;
	
	/**
	 * 删除积分注销
	 * @param actionLog
	 * @param user
	 * @param paraIds
	 * @throws CommonException
	 */
	public void saveCancelPointPara(SysActionLog actionLog,Users user,String paraIds) throws CommonException;
	
	/**
	 * 激活积分注销
	 * @param actionLog
	 * @param user
	 * @param paraIds
	 * @throws CommonException
	 */
	public void saveActivePointPara(SysActionLog actionLog,Users user,String paraIds) throws CommonException;
}
