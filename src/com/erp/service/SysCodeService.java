package com.erp.service;

import java.util.List;
import java.util.Map;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.SysCode;
import com.erp.model.SysCodeId;
import com.erp.model.Users;
import com.erp.util.PageUtil;

public interface SysCodeService extends BaseService {

	/**
	 * 查询数据字典(根据数据字典名)
	 */
	List<SysCode> findSysCodeListByTypeName(String typeName) throws CommonException;
	/**
	 * 查询数据字典(根据数据字典类型)
	 */
	List<SysCode> findSysCodeListByType(String type,String codeValues) throws CommonException;
	/**
	 * 查询数据字典的（根据id）
	 */
	SysCode findSysCodeById(SysCodeId id);
	
	/**
	 * 查询所有的数据字典值
	 */
	
	List<SysCode> findAllCodeList(Map<String, Object> map, PageUtil pageUtil) throws CommonException;
	
	/**
	 * 保存数据字典值
	 * @param actionLog
	 * @param user
	 * @param para
	 * @throws CommonException
	 */
	public void saveOrUpdateSysCode(SysCode sysCode,Users user,SysActionLog actioanLog ) throws CommonException;
	
	public void updateSysCode(SysCode sysCode,Users user,SysActionLog actioanLog ) throws CommonException;
	
	public void deleteSysCode(SysCode sysCode, Users users,SysActionLog actioanLog) throws CommonException;

	
	
}
