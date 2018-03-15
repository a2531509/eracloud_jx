package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.BaseKanwuPrint;
import com.erp.model.SysActionLog;
import com.erp.model.Users;


public interface PersonInfoErrataService extends BaseService {

	public SysActionLog savePrintReport(SysActionLog actionLog, Users operator) throws CommonException;
	
	public void saveKanwuPrint(BaseKanwuPrint print) throws CommonException;
	
	public String saveSbApplyInfo(SysActionLog actionLog,Users oper,String selectIds) throws CommonException;

	public void saveSbApply(String applyIds, String cardType, SysActionLog log);

	/**
	 * 更新社保申领信息
	 */
	public void updateSbApply();
}
