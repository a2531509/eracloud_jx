package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.BasePsam;
import com.erp.model.BaseVendor;

public  interface  BaseVendorService  extends BaseService{

	/**
	 * 保存卡商管理信息
	 * @param baseVendor
	 * @throws CommonException
	 */
	public  void  saveBaseVendor(BaseVendor baseVendor)throws CommonException;
	
    /**
     * 删除卡商管理信息
     * @param baseVendor
     * @throws CommonException
     */
	public void delBaseVendor(String vendorId)throws CommonException;
	/**
	 * 修改卡商管理信息
	 * @param baseVendor
	 * @throws CommonException
	 */
	public void updateBaseVendor(BaseVendor baseVendor)throws CommonException;
	/**
	 * 注销卡商信息
	 * @param baseVendor
	 * @throws CommonException
	 */
	public void cancelBaseVendor(BaseVendor baseVendor)throws CommonException;
	/**
	 * 激活卡商信息
	 * @param baseVendor
	 * @throws CommonException
	 */
	public void activaBaseVendor(BaseVendor baseVendor)throws CommonException;




}
