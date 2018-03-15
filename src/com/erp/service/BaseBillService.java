package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.BaseBill;

public interface BaseBillService extends BaseService {

	/**
	 * 票据信息保存
	 * @param baseBill
	 * @throws CommonException
	 */
	public  void  saveBaseBill(BaseBill baseBill)throws CommonException;
	
    /**
     * 票据信息删除
     * @param baseBill
     * @throws CommonException
     */
	public void delBaseBill(BaseBill baseBill)throws CommonException;
	/**
	 * 票据信息修改
	 * @param baseBill
	 * @throws CommonException
	 */
	
	public void updateBaseBill(BaseBill baseBill)throws CommonException;


}
