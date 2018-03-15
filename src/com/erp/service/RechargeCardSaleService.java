package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.CardRecharge;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;

import net.sf.jasperreports.engine.JRException;

public interface RechargeCardSaleService {

	public TrServRec saveRechargeCard(SysActionLog sysActionLog, CardRecharge cardRecharge) throws CommonException;

	public TrServRec saveBatchRechargeCard(SysActionLog sysActionLog, String cardNos) throws CommonException, JRException;

	public TrServRec modifyRechargeCard(SysActionLog sysActionLog, TrServRec trServRec, CardRecharge cardRecharge) throws CommonException;

}
