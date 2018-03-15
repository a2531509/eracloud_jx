package com.erp.model;

public class ExportCardApplyModel {

	private String name; // 客户姓名
	private String certNo; // 证件号
	private String cardNo; // 卡号
	private String subCardNo; // 社会保障卡号
	private String applyState; // 申请状态
	private String taskId; // 任务号
	private String corpId; // 申领单号
	private String buyPlanId; // 批次号
	private String corpName; // 申领单位名称
	private String cardType; // 卡类型

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getSubCardNo() {
		return subCardNo;
	}

	public void setSubCardNo(String subCardNo) {
		this.subCardNo = subCardNo;
	}

	public String getApplyState() {
		return applyState;
	}

	public void setApplyState(String applyState) {
		this.applyState = applyState;
	}

	public String getTaskId() {
		return taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}

	public String getCorpId() {
		return corpId;
	}

	public void setCorpId(String corpId) {
		this.corpId = corpId;
	}

	public String getBuyPlanId() {
		return buyPlanId;
	}

	public void setBuyPlanId(String buyPlanId) {
		this.buyPlanId = buyPlanId;
	}

	public String getCorpName() {
		return corpName;
	}

	public void setCorpName(String corpName) {
		this.corpName = corpName;
	}

	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

}
