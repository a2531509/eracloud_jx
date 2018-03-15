package com.erp.service;

import java.util.List;
import java.util.Map;

public interface Switchservice extends BaseService {
	/**
	 * 卡信息查询1
	 */
	Map<String, String> getCard(String certNo);
	
	/**
	 * 卡信息查询2
	 */
	Map<String, String> getCard(String subCardNo, String regionId, String subCardId);
	
	/**
	 * 卡信息查询3
	 */
	Map<String, String> getCard(String certNo, String subCardNo, String substring, String subCardId);
	
	/**
	 * 卡状态变更
	 */
	void updateCardState(String cardNo, String cardStateBeforeChange, String cardStateAfterChange);
	
	/**
	 * 统筹区变更
	 */
	void updateMedWholeNo(String cardNo, String oldRegionId, String newRegionId);
	
	void sendPersonData(String certNo);

	void sendCardData(String certNo);
	
	/**
	 * 新增卡信息上传
	 */
	public void saveAddCardInfo();

	/**
	 * 新增人员信息上传
	 */
	public void savePersonInfo();

	void updateCardState(List<String> oldCardNos, String cardState, String cardState2);

	void sync2ST(String taskId);
	
	/**
	 * 发送卡片对账信息到省厅
	 * @param startDate yyyyMMdd 
	 * @param endDate   yyyyMMdd
	 */
	void sendCardNum2ST(String regionId, String date);
	
	/**
	 * 省厅对账数据下载
	 * @param date
	 * @param regionId
	 * @param pv 下载进度
	 * @return 下载进度
	 */
	void downLoadSTCardData(String date, String regionId, long pv);

	void sendPersonPhoto(String certNo);

	void saveSendPhoto();

	void updatePerson(String certNo);
}
