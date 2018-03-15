package com.erp.service;

import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;

/**
 * 商户结算。
 * @author 钱佳明。
 *
 */
public interface MerchantSettlementService {

	/**
	 * 生成报表。
	 * @param merchantIds 商户编号。
	 * @param beginDate 起始日期。
	 * @param endDate 结束日期。
	 * @param cardType 卡类型。
	 * @param sysActionLog 操作日志。
	 * @return 业务日志。
	 */
	public TrServRec createReport(String merchantIds, String beginDate, String endDate, String cardType, SysActionLog sysActionLog) throws Exception;

	/**
	 * 导出Excel表格。
	 * @param merchantIds 商户编号。
	 * @param beginDate 起始日期。
	 * @param endDate 结束日期。
	 * @param cardType 卡类型。
	 */
	public void exportExcel(String merchantIds, String beginDate, String endDate, String cardType) throws Exception;

}
