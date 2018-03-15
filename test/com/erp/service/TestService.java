package com.erp.service;


import com.erp.model.SysActionLog;
public interface TestService extends BaseService {
	void saveHandleExcel();
	
	/**
	 * 计算金额密文
	 * @param cardNo 卡号
	 * @param amt 金额(分)
	 * @return 金额密文
	 */
	String encryptBal(String cardNo, String amt);
	
	/**
	 * 合作机构充值统计
	 * @param coOrgId 合作机构编号
	 * @param startDate 起始日期 (yyyy-MM-dd)
	 * @param endDate 结束日期 (yyyy-MM-dd)
	 */
	void saveStatCoOrgRchgStat(String coOrgId, String startDate, String endDate);
	
	/**
	 * 网点充值消费统计
	 * @param startDate 起始日期 (yyyy-MM-dd)
	 * @param endDate 结束日期 (yyyy-MM-dd)
	 */
	void saveStatBrchRchgStat(String startDate, String endDate);

	/**
	 * 卡注销同步到 card_update
	 * @param object 证件号码
	 */
	void saveCardUpateCardCancel(String object);

	/**
	 * 卡发放同步到 card_update
	 * @param applyId 申领编号
	 */
	void saveCardUpateCardIssue(String applyId);
	
	/**
	 * 卡激活同步到 card_update
	 * @param certNo 证件号码
	 */
	void saveCardUpateCardBankCardActive(String certNo);

	/**
	 * 卡片开户
	 * @param cardNo 卡号
	 */
	void saveOpenAcc(String cardNo);
	
	void deleteTask (String taskid,SysActionLog log);
}
