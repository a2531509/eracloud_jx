package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.BaseBill;
import com.erp.model.SysActionLog;

public interface BillManageService extends BaseService{
    /**
     * 
     * @param baseBill
     * @param log
     * @param flag
     * @throws CommonException
     */
	public  void  saveBaseBill(BaseBill baseBill,SysActionLog log,String flag)throws CommonException;
	
    /**
     * 删除卡片信息
     * @param cardType
     * @throws CommonException
     */
	public void delBaseBill(String billNo)throws CommonException;

}
