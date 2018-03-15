package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.BaseProvider;


public interface BaseProviderService extends BaseService {
    
	/**
	 * 保存供应商信息
	 * @param basePro
	 * @throws CommonException
	 */
	public  void  saveBaseProvider(BaseProvider basePro)throws CommonException;
	
    /**
     *  删除供应商信息
     * @param providerId
     * @throws CommonException
     */
	public void delBaseProvider(Long providerId)throws CommonException;
	/**
	 * 修改供应商信息
	 * @param basePro
	 * @throws CommonException
	 */
	
	public void updateBaseProvider(BaseProvider basePro)throws CommonException;
	/**
	 * 查找供应商信息
	 * @param basePro
	 * @throws CommonException
	 */
	
	
}
