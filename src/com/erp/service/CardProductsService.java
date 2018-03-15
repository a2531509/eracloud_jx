package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.CardProducts;

public interface CardProductsService extends BaseService{
	/**
	 * 保存卡片信息
	 * @param cardPro
	 * @throws CommonException
	 */
	public  void  saveCardPro(CardProducts cardPro)throws CommonException;
	
    /**
     * 删除卡片信息
     * @param cardType
     * @throws CommonException
     */
	public void delCardPro(String cardType)throws CommonException;
	/**
	 * 修改卡片信息
	 * @param cardPro
	 * @throws CommonException
	 */
	public void updateCardPro(CardProducts cardPro)throws CommonException;
	/**
	 * 查找卡片信息
	 * @param cardPro
	 * @throws CommonException
	 */
	public void findCardPro(CardProducts cardPro)throws CommonException;
	
}
