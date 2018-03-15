package com.erp.service;

import com.erp.model.PayCarTotal;
import com.erp.model.PayCarreform;
import com.erp.model.SysActionLog;

/**
 * 
 * @author Yueh
 *
 */
public interface PayCarreFormService extends BaseService {
	/**
	 * 修改充值信息
	 * 
	 * @param payCarreform
	 */
	void modifyPayCarreForm(PayCarreform oldPayCarreform, PayCarreform newPayCarreform);

	/**
	 * 充值信息按批次审核, 审核通过后充值到单位账户
	 * 
	 * @param payCarreform
	 * @return
	 */
	void saveBatchIdentify(PayCarTotal payCarTotal, SysActionLog log);

	/**
	 * 审核不通过
	 * 
	 * @param payCarTotal
	 */
	void saveInvalid(PayCarTotal payCarTotal);

	void saveRecharge(PayCarreform payCarreform, SysActionLog log);

	void updatePayCarreform(PayCarreform payCarreform);

	void updatePayCarTotal(PayCarTotal payCarTotal2);
}
