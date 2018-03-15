package com.erp.model;

import java.math.BigDecimal;
import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * CardTaskImpTmpId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class CardTaskImpTmpId implements java.io.Serializable {

	// Fields

	private String userId;
	private String batchId;
	private String taskId;
	private BigDecimal dataSeq;
	private String customerId;
	private String name;
	private String sex;
	private String certType;
	private String certNo;
	private String cardType;
	private String cardNo;
	private String cardTableName;
	private String structMainType;
	private String structChildType;
	private String bankcardno;
	private String cardId;
	private String statusid;
	private String statustext;
	private String cityCode;
	private String indusCode;
	private String ssseef0507;
	private String barCode;
	private String atr;
	private String rfatr;

	// Constructors

	/** default constructor */
	public CardTaskImpTmpId() {
	}

	/** minimal constructor */
	public CardTaskImpTmpId(String userId, String batchId, String taskId,
			BigDecimal dataSeq, String cardId) {
		this.userId = userId;
		this.batchId = batchId;
		this.taskId = taskId;
		this.dataSeq = dataSeq;
		this.cardId = cardId;
	}

	/** full constructor */
	public CardTaskImpTmpId(String userId, String batchId, String taskId,
			BigDecimal dataSeq, String customerId, String name, String sex,
			String certType, String certNo, String cardType, String cardNo,
			String cardTableName, String structMainType,
			String structChildType, String bankcardno, String cardId,
			String statusid, String statustext, String cityCode,
			String indusCode, String ssseef0507, String barCode, String atr,
			String rfatr) {
		this.userId = userId;
		this.batchId = batchId;
		this.taskId = taskId;
		this.dataSeq = dataSeq;
		this.customerId = customerId;
		this.name = name;
		this.sex = sex;
		this.certType = certType;
		this.certNo = certNo;
		this.cardType = cardType;
		this.cardNo = cardNo;
		this.cardTableName = cardTableName;
		this.structMainType = structMainType;
		this.structChildType = structChildType;
		this.bankcardno = bankcardno;
		this.cardId = cardId;
		this.statusid = statusid;
		this.statustext = statustext;
		this.cityCode = cityCode;
		this.indusCode = indusCode;
		this.ssseef0507 = ssseef0507;
		this.barCode = barCode;
		this.atr = atr;
		this.rfatr = rfatr;
	}

	// Property accessors

	@Column(name = "USER_ID", nullable = false, length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "BATCH_ID", nullable = false, length = 14)
	public String getBatchId() {
		return this.batchId;
	}

	public void setBatchId(String batchId) {
		this.batchId = batchId;
	}

	@Column(name = "TASK_ID", nullable = false, length = 19)
	public String getTaskId() {
		return this.taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}

	@Column(name = "DATA_SEQ", nullable = false, precision = 22, scale = 0)
	public BigDecimal getDataSeq() {
		return this.dataSeq;
	}

	public void setDataSeq(BigDecimal dataSeq) {
		this.dataSeq = dataSeq;
	}

	@Column(name = "CUSTOMER_ID", length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "NAME", length = 30)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "SEX", length = 1)
	public String getSex() {
		return this.sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	@Column(name = "CERT_TYPE", length = 2)
	public String getCertType() {
		return this.certType;
	}

	public void setCertType(String certType) {
		this.certType = certType;
	}

	@Column(name = "CERT_NO", length = 36)
	public String getCertNo() {
		return this.certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	@Column(name = "CARD_TYPE", length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "CARD_NO", length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "CARD_TABLE_NAME", length = 20)
	public String getCardTableName() {
		return this.cardTableName;
	}

	public void setCardTableName(String cardTableName) {
		this.cardTableName = cardTableName;
	}

	@Column(name = "STRUCT_MAIN_TYPE", length = 2)
	public String getStructMainType() {
		return this.structMainType;
	}

	public void setStructMainType(String structMainType) {
		this.structMainType = structMainType;
	}

	@Column(name = "STRUCT_CHILD_TYPE", length = 2)
	public String getStructChildType() {
		return this.structChildType;
	}

	public void setStructChildType(String structChildType) {
		this.structChildType = structChildType;
	}

	@Column(name = "BANKCARDNO", length = 20)
	public String getBankcardno() {
		return this.bankcardno;
	}

	public void setBankcardno(String bankcardno) {
		this.bankcardno = bankcardno;
	}

	@Column(name = "CARD_ID", nullable = false, length = 50)
	public String getCardId() {
		return this.cardId;
	}

	public void setCardId(String cardId) {
		this.cardId = cardId;
	}

	@Column(name = "STATUSID", length = 1)
	public String getStatusid() {
		return this.statusid;
	}

	public void setStatusid(String statusid) {
		this.statusid = statusid;
	}

	@Column(name = "STATUSTEXT", length = 512)
	public String getStatustext() {
		return this.statustext;
	}

	public void setStatustext(String statustext) {
		this.statustext = statustext;
	}

	@Column(name = "CITY_CODE", length = 10)
	public String getCityCode() {
		return this.cityCode;
	}

	public void setCityCode(String cityCode) {
		this.cityCode = cityCode;
	}

	@Column(name = "INDUS_CODE", length = 10)
	public String getIndusCode() {
		return this.indusCode;
	}

	public void setIndusCode(String indusCode) {
		this.indusCode = indusCode;
	}

	@Column(name = "SSSEEF0507", length = 20)
	public String getSsseef0507() {
		return this.ssseef0507;
	}

	public void setSsseef0507(String ssseef0507) {
		this.ssseef0507 = ssseef0507;
	}

	@Column(name = "BAR_CODE", length = 20)
	public String getBarCode() {
		return this.barCode;
	}

	public void setBarCode(String barCode) {
		this.barCode = barCode;
	}

	@Column(name = "ATR", length = 34)
	public String getAtr() {
		return this.atr;
	}

	public void setAtr(String atr) {
		this.atr = atr;
	}

	@Column(name = "RFATR", length = 50)
	public String getRfatr() {
		return this.rfatr;
	}

	public void setRfatr(String rfatr) {
		this.rfatr = rfatr;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof CardTaskImpTmpId))
			return false;
		CardTaskImpTmpId castOther = (CardTaskImpTmpId) other;

		return ((this.getUserId() == castOther.getUserId()) || (this
				.getUserId() != null && castOther.getUserId() != null && this
				.getUserId().equals(castOther.getUserId())))
				&& ((this.getBatchId() == castOther.getBatchId()) || (this
						.getBatchId() != null && castOther.getBatchId() != null && this
						.getBatchId().equals(castOther.getBatchId())))
				&& ((this.getTaskId() == castOther.getTaskId()) || (this
						.getTaskId() != null && castOther.getTaskId() != null && this
						.getTaskId().equals(castOther.getTaskId())))
				&& ((this.getDataSeq() == castOther.getDataSeq()) || (this
						.getDataSeq() != null && castOther.getDataSeq() != null && this
						.getDataSeq().equals(castOther.getDataSeq())))
				&& ((this.getCustomerId() == castOther.getCustomerId()) || (this
						.getCustomerId() != null
						&& castOther.getCustomerId() != null && this
						.getCustomerId().equals(castOther.getCustomerId())))
				&& ((this.getName() == castOther.getName()) || (this.getName() != null
						&& castOther.getName() != null && this.getName()
						.equals(castOther.getName())))
				&& ((this.getSex() == castOther.getSex()) || (this.getSex() != null
						&& castOther.getSex() != null && this.getSex().equals(
						castOther.getSex())))
				&& ((this.getCertType() == castOther.getCertType()) || (this
						.getCertType() != null
						&& castOther.getCertType() != null && this
						.getCertType().equals(castOther.getCertType())))
				&& ((this.getCertNo() == castOther.getCertNo()) || (this
						.getCertNo() != null && castOther.getCertNo() != null && this
						.getCertNo().equals(castOther.getCertNo())))
				&& ((this.getCardType() == castOther.getCardType()) || (this
						.getCardType() != null
						&& castOther.getCardType() != null && this
						.getCardType().equals(castOther.getCardType())))
				&& ((this.getCardNo() == castOther.getCardNo()) || (this
						.getCardNo() != null && castOther.getCardNo() != null && this
						.getCardNo().equals(castOther.getCardNo())))
				&& ((this.getCardTableName() == castOther.getCardTableName()) || (this
						.getCardTableName() != null
						&& castOther.getCardTableName() != null && this
						.getCardTableName()
						.equals(castOther.getCardTableName())))
				&& ((this.getStructMainType() == castOther.getStructMainType()) || (this
						.getStructMainType() != null
						&& castOther.getStructMainType() != null && this
						.getStructMainType().equals(
								castOther.getStructMainType())))
				&& ((this.getStructChildType() == castOther
						.getStructChildType()) || (this.getStructChildType() != null
						&& castOther.getStructChildType() != null && this
						.getStructChildType().equals(
								castOther.getStructChildType())))
				&& ((this.getBankcardno() == castOther.getBankcardno()) || (this
						.getBankcardno() != null
						&& castOther.getBankcardno() != null && this
						.getBankcardno().equals(castOther.getBankcardno())))
				&& ((this.getCardId() == castOther.getCardId()) || (this
						.getCardId() != null && castOther.getCardId() != null && this
						.getCardId().equals(castOther.getCardId())))
				&& ((this.getStatusid() == castOther.getStatusid()) || (this
						.getStatusid() != null
						&& castOther.getStatusid() != null && this
						.getStatusid().equals(castOther.getStatusid())))
				&& ((this.getStatustext() == castOther.getStatustext()) || (this
						.getStatustext() != null
						&& castOther.getStatustext() != null && this
						.getStatustext().equals(castOther.getStatustext())))
				&& ((this.getCityCode() == castOther.getCityCode()) || (this
						.getCityCode() != null
						&& castOther.getCityCode() != null && this
						.getCityCode().equals(castOther.getCityCode())))
				&& ((this.getIndusCode() == castOther.getIndusCode()) || (this
						.getIndusCode() != null
						&& castOther.getIndusCode() != null && this
						.getIndusCode().equals(castOther.getIndusCode())))
				&& ((this.getSsseef0507() == castOther.getSsseef0507()) || (this
						.getSsseef0507() != null
						&& castOther.getSsseef0507() != null && this
						.getSsseef0507().equals(castOther.getSsseef0507())))
				&& ((this.getBarCode() == castOther.getBarCode()) || (this
						.getBarCode() != null && castOther.getBarCode() != null && this
						.getBarCode().equals(castOther.getBarCode())))
				&& ((this.getAtr() == castOther.getAtr()) || (this.getAtr() != null
						&& castOther.getAtr() != null && this.getAtr().equals(
						castOther.getAtr())))
				&& ((this.getRfatr() == castOther.getRfatr()) || (this
						.getRfatr() != null && castOther.getRfatr() != null && this
						.getRfatr().equals(castOther.getRfatr())));
	}

	public int hashCode() {
		int result = 17;

		result = 37 * result
				+ (getUserId() == null ? 0 : this.getUserId().hashCode());
		result = 37 * result
				+ (getBatchId() == null ? 0 : this.getBatchId().hashCode());
		result = 37 * result
				+ (getTaskId() == null ? 0 : this.getTaskId().hashCode());
		result = 37 * result
				+ (getDataSeq() == null ? 0 : this.getDataSeq().hashCode());
		result = 37
				* result
				+ (getCustomerId() == null ? 0 : this.getCustomerId()
						.hashCode());
		result = 37 * result
				+ (getName() == null ? 0 : this.getName().hashCode());
		result = 37 * result
				+ (getSex() == null ? 0 : this.getSex().hashCode());
		result = 37 * result
				+ (getCertType() == null ? 0 : this.getCertType().hashCode());
		result = 37 * result
				+ (getCertNo() == null ? 0 : this.getCertNo().hashCode());
		result = 37 * result
				+ (getCardType() == null ? 0 : this.getCardType().hashCode());
		result = 37 * result
				+ (getCardNo() == null ? 0 : this.getCardNo().hashCode());
		result = 37
				* result
				+ (getCardTableName() == null ? 0 : this.getCardTableName()
						.hashCode());
		result = 37
				* result
				+ (getStructMainType() == null ? 0 : this.getStructMainType()
						.hashCode());
		result = 37
				* result
				+ (getStructChildType() == null ? 0 : this.getStructChildType()
						.hashCode());
		result = 37
				* result
				+ (getBankcardno() == null ? 0 : this.getBankcardno()
						.hashCode());
		result = 37 * result
				+ (getCardId() == null ? 0 : this.getCardId().hashCode());
		result = 37 * result
				+ (getStatusid() == null ? 0 : this.getStatusid().hashCode());
		result = 37
				* result
				+ (getStatustext() == null ? 0 : this.getStatustext()
						.hashCode());
		result = 37 * result
				+ (getCityCode() == null ? 0 : this.getCityCode().hashCode());
		result = 37 * result
				+ (getIndusCode() == null ? 0 : this.getIndusCode().hashCode());
		result = 37
				* result
				+ (getSsseef0507() == null ? 0 : this.getSsseef0507()
						.hashCode());
		result = 37 * result
				+ (getBarCode() == null ? 0 : this.getBarCode().hashCode());
		result = 37 * result
				+ (getAtr() == null ? 0 : this.getAtr().hashCode());
		result = 37 * result
				+ (getRfatr() == null ? 0 : this.getRfatr().hashCode());
		return result;
	}

}