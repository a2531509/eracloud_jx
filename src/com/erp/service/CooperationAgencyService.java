package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.BaseCoOrg;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;

public interface CooperationAgencyService extends BaseService {
	/**
	 * 新增或是编辑保存合作机构
	 * @param co
	 * @param users
	 * @param log
	 * @param type
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveOrUpdateBaseCoOrg(BaseCoOrg co,Users users,SysActionLog log,String type,String safeCode,String ipaAddress,String portAddress) throws CommonException;
	public TrServRec saveOrUpdateBaseCoOrg(BaseCoOrg co,Users users,SysActionLog log,String type,String safeCode) throws CommonException;
	/**
	 * 合作机构状态管理
	 * @param customerId  合作机构标识符
	 * @param users       操作柜员
	 * @param log         操作日志
	 * @param type        操作类型  0-审批通过，1-注销（退网）， 3 启用    9 审核不通过
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveDealBaseCoOrg(Long customerId,Users users,SysActionLog log,String type) throws CommonException;
}
