package com.erp.service;

import com.erp.model.MerchantDiscount;

/**
 * 商户在折扣率
 * 
 * @author Yueh
 *
 */
public interface MerchantDiscountService extends BaseService {
	/**
	 * 新增折扣率
	 * 
	 * @param discount
	 */
	void addMerchantDiscount(MerchantDiscount discount);

	/**
	 * 修改折扣率
	 * 
	 * @param discount
	 */
	void modifyMerchantDiscount(MerchantDiscount discount);

	/**
	 * 审核折扣率
	 * 
	 * @param discount
	 */
	void saveCheckMerchantDiscount(MerchantDiscount discount);

	/**
	 * 注销折扣率
	 * 
	 * @param discount
	 */
	void saveCancelMerchantDiscount(MerchantDiscount discount);
}
