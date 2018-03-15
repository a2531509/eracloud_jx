package com.erp.service;

import java.util.List;

import java.util.Map;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.SysOrgan;
import com.erp.viewModel.TreeModel;

public interface SysOrgService extends BaseService {
	
	List<TreeModel> findAllSysOrgan();
	
	List<SysOrgan> findOrganList(Map<String, Object> map);

	List<SysOrgan> findOrganListByClientId(Integer id );

	boolean persistenceSysOrgan(SysOrgan o );
	
	/**
	 * 机构开户
	 * @param org 开户的机构
	 * @param actionLog 系统日志信息
	 * @throws CommonException
	 */
	public void saveOpenOrgAcc(List<SysOrgan> orges,SysActionLog actionLog) throws CommonException;
	/**
	 * 机构注销
	 * @param id
	 * @return
	 */
	boolean savezxSys_OrganByOrgan(SysActionLog actionLog,String  orgId )throws CommonException;
	
	

}
