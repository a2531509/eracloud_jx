package com.erp.service;

import java.util.List;

import com.erp.exception.CommonException;
import com.erp.model.CardSaleList;
import com.erp.model.CardSaleRec;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;

public interface RechargeCardService  extends BaseService {
	
	
	/**
	 * 保存销售
	 * @param cardSaleRec
	 * @param cardSaleList
	 * @param rec
	 * @param actionLog
	 * @throws CommonException
	 */
	public void saveCardSell(CardSaleRec  cardSaleRec,List<CardSaleList> saleList,TrServRec rec,SysActionLog actionLog) throws CommonException;
	/**
	 * 非记名卡销售登记撤销
	 * @param dealNo 销售登记表
	 * @param actionlog 业务日志对象
	 * @throws CommonException
	 */
	public List deleteCardSell(Long dealNo,SysActionLog actionLog) throws CommonException;
	/**
	 * 非记名卡批量启用
	 * @param dealNoStr
	 * @param actionLog
	 * @return
	 * @throws CommonException
	 */
	public void saveCardSellUsed(String dealNoStr,SysActionLog actionLog) throws CommonException;
}
