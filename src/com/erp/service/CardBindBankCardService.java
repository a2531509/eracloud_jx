/**
 * 
 */
package com.erp.service;

import java.util.List;

import com.erp.exception.CommonException;
import com.erp.model.CardBindBankCard;
import com.erp.model.TrServRec;

/**
 * 卡片绑定银行卡Service
 * 
 * @author Yueh
 *
 */
public interface CardBindBankCardService extends BaseService {
	/**
	 * <b>卡片绑定银行卡验证 :</b> <br>
	 * 验证卡片是否可以绑定银行卡(调用银行接口，检查姓名，身份证，银行卡号，银行卡类型信息是否正确)
	 * 
	 * @param bindInfo
	 *            卡片绑定银行卡信息
	 * @return <br>
	 *         <b>true</b> 可绑定<br>
	 * 
	 * @throws CommonException
	 *             验证不通过抛出异常
	 */
	Boolean validCardBindBankCard(CardBindBankCard bindInfo);

	/**
	 * <b>保存卡片绑定银行卡信息:</b> <br>
	 * 
	 * @param bindInfo
	 *            卡片绑定银行卡信息
	 * @throws CommonException
	 *             when fail
	 */
	void saveCardBindBankCard(CardBindBankCard bindInfo);

	/**
	 * <b>卡片批量绑定银行卡:</b> <br>
	 * 
	 * @param bindInfos
	 *            卡片绑定银行卡信息
	 * @return 失败的记录
	 * 
	 * @throws CommonException
	 *             when fail
	 */
	List<CardBindBankCard> saveCardBindBankCard(List<CardBindBankCard> bindInfos);

	/**
	 * <b>卡片绑定银行卡解绑:</b> <br>
	 * @param rec 
	 * 
	 * @param unBindInfo
	 *            卡片绑定银行卡信息
	 * @return 
	 * @throws CommonException
	 *             when fail
	 */
	Long saveCardUnBindBankCard(TrServRec rec, CardBindBankCard unBindInfo);

	/**
	 * 保存预绑定信息
	 * @param bindInfos
	 */
	void savePreBind(List<CardBindBankCard> bindInfos);
}
