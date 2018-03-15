package com.erp.model;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * CardTaskImp entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_TASK_IMP")
public class CardTaskImp implements java.io.Serializable {

	// Fields

	private CardTaskImpId id;
	private String userId;
	private String taskId;
	private String custoerId;
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
	public CardTaskImp() {
	}

	/** minimal constructor */
	public CardTaskImp(CardTaskImpId id, String userId, String taskId,
			String cardId) {
		this.id = id;
		this.userId = userId;
		this.taskId = taskId;
		this.cardId = cardId;
	}

	/** full constructor */
	public CardTaskImp(CardTaskImpId id, String userId, String taskId,
			String custoerId, String name, String sex, String certType,
			String certNo, String cardType, String cardNo,
			String cardTableName, String structMainType,
			String structChildType, String bankcardno, String cardId,
			String statusid, String statustext, String cityCode,
			String indusCode, String ssseef0507, String barCode, String atr,
			String rfatr) {
		this.id = id;
		this.userId = userId;
		this.taskId = taskId;
		this.custoerId = custoerId;
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
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "batchId", column = @Column(name = "BATCH_ID", nullable = false, length = 14)),
			@AttributeOverride(name = "dataSeq", column = @Column(name = "DATA_SEQ", nullable = false, precision = 22, scale = 0)) })
	public CardTaskImpId getId() {
		return this.id;
	}

	public void setId(CardTaskImpId id) {
		this.id = id;
	}

	@Column(name = "USER_ID", nullable = false, length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "TASK_ID", nullable = false, length = 19)
	public String getTaskId() {
		return this.taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}

	@Column(name = "CUSTOER_ID", length = 10)
	public String getCustoerId() {
		return this.custoerId;
	}

	public void setCustoerId(String custoerId) {
		this.custoerId = custoerId;
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

}