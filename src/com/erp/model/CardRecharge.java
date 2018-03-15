package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "CARD_RECHARGE")
public class CardRecharge {

	private Long dataSeq;
	private String taskId;
	private String orgId;
	private String cardType;
	private Long faceVal;
	private String cardNo;
	private String pwd;
	private String useState;
	private Long xsDealNo;

	public CardRecharge() {
	}

	public CardRecharge(Long dataSeq, String taskId, String orgId,
			String cardType, Long faceVal, String cardNo, String pwd,
			String useState, Long xsDealNo) {
		this.dataSeq = dataSeq;
		this.taskId = taskId;
		this.orgId = orgId;
		this.cardType = cardType;
		this.faceVal = faceVal;
		this.cardNo = cardNo;
		this.pwd = pwd;
		this.useState = useState;
		this.xsDealNo = xsDealNo;
	}

	@Id
	@Column(name = "DATA_SEQ")
	public Long getDataSeq() {
		return dataSeq;
	}

	public void setDataSeq(Long dataSeq) {
		this.dataSeq = dataSeq;
	}

	@Column(name = "TASK_ID", length = 18)
	public String getTaskId() {
		return taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}

	@Column(name = "ORG_ID", length = 4)
	public String getOrgId() {
		return orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "CARD_TYPE", length = 3)
	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "FACE_VAL")
	public Long getFaceVal() {
		return faceVal;
	}

	public void setFaceVal(Long faceVal) {
		this.faceVal = faceVal;
	}

	@Column(name = "CARD_NO", length = 20)
	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "PWD", length = 64)
	public String getPwd() {
		return pwd;
	}

	public void setPwd(String pwd) {
		this.pwd = pwd;
	}

	@Column(name = "USE_STATE", length = 1)
	public String getUseState() {
		return useState;
	}

	public void setUseState(String useState) {
		this.useState = useState;
	}

	@Column(name = "XS_DEAL_NO")
	public Long getXsDealNo() {
		return xsDealNo;
	}

	public void setXsDealNo(Long xsDealNo) {
		this.xsDealNo = xsDealNo;
	}
}
