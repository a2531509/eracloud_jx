package com.erp.model;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.UniqueConstraint;

/**
 * CardAppOpen entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_APP_OPEN", uniqueConstraints = {
		@UniqueConstraint(columnNames = { "SUB_CARD_NO", "APP_TYPE" }),
		@UniqueConstraint(columnNames = { "CARD_NO", "APP_TYPE" }) })

public class CardAppOpen implements java.io.Serializable {

	// Fields

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Long dataId;
	private String customerId;
	private String cardId;
	private String cardNo;
	private String subCardNo;
	private String cardType;
	private String appType;
	private String state;
	private String openDate;
	private String validDate;
	private Long openFee;
	private String merchantId;
	private String theOnlyNo;
	private String clrDate;
	private String acptOrgId;
	private String acptType;
	private String acptId;
	private String userId;
	private String endDealNo;
	private Date lastModifyDate;
	private Long dealNo;
	private String note;

	// Constructors

	/** default constructor */
	public CardAppOpen() {
	}

	/** minimal constructor */
	public CardAppOpen(Long dataId, String cardNo, String cardType, String appType, String state, String openDate,
			String validDate, Long openFee, String clrDate, String acptOrgId, String acptType, String userId) {
		this.dataId = dataId;
		this.cardNo = cardNo;
		this.cardType = cardType;
		this.appType = appType;
		this.state = state;
		this.openDate = openDate;
		this.validDate = validDate;
		this.openFee = openFee;
		this.clrDate = clrDate;
		this.acptOrgId = acptOrgId;
		this.acptType = acptType;
		this.userId = userId;
	}

	/** full constructor */
	public CardAppOpen(Long dataId, String customerId, String cardId, String cardNo, String subCardNo,
			String cardType, String appType, String state, String openDate, String validDate, Long openFee,
			String merchantId, String theOnlyNo, String clrDate, String acptOrgId, String acptType, String acptId,
			String userId, String endDealNo, Date lastModifyDate, Long dealNo, String note) {
		this.dataId = dataId;
		this.customerId = customerId;
		this.cardId = cardId;
		this.cardNo = cardNo;
		this.subCardNo = subCardNo;
		this.cardType = cardType;
		this.appType = appType;
		this.state = state;
		this.openDate = openDate;
		this.validDate = validDate;
		this.openFee = openFee;
		this.merchantId = merchantId;
		this.theOnlyNo = theOnlyNo;
		this.clrDate = clrDate;
		this.acptOrgId = acptOrgId;
		this.acptType = acptType;
		this.acptId = acptId;
		this.userId = userId;
		this.endDealNo = endDealNo;
		this.lastModifyDate = lastModifyDate;
		this.dealNo = dealNo;
		this.note = note;
	}

	// Property accessors
	@Id

	@Column(name = "DATA_ID", unique = true, nullable = false, precision = 38, scale = 0)

	public Long getDataId() {
		return this.dataId;
	}

	public void setDataId(Long dataId) {
		this.dataId = dataId;
	}

	@Column(name = "CUSTOMER_ID", length = 10)

	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "CARD_ID", length = 50)

	public String getCardId() {
		return this.cardId;
	}

	public void setCardId(String cardId) {
		this.cardId = cardId;
	}

	@Column(name = "CARD_NO", nullable = false, length = 20)

	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "SUB_CARD_NO", length = 9)

	public String getSubCardNo() {
		return this.subCardNo;
	}

	public void setSubCardNo(String subCardNo) {
		this.subCardNo = subCardNo;
	}

	@Column(name = "CARD_TYPE", nullable = false, length = 3)

	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "APP_TYPE", nullable = false, length = 2)

	public String getAppType() {
		return this.appType;
	}

	public void setAppType(String appType) {
		this.appType = appType;
	}

	@Column(name = "STATE", nullable = false, length = 2)

	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

	@Column(name = "OPEN_DATE", nullable = false, length = 10)

	public String getOpenDate() {
		return this.openDate;
	}

	public void setOpenDate(String openDate) {
		this.openDate = openDate;
	}

	@Column(name = "VALID_DATE", nullable = false, length = 10)

	public String getValidDate() {
		return this.validDate;
	}

	public void setValidDate(String validDate) {
		this.validDate = validDate;
	}

	@Column(name = "OPEN_FEE", nullable = false, precision = 10, scale = 0)

	public Long getOpenFee() {
		return this.openFee;
	}

	public void setOpenFee(Long openFee) {
		this.openFee = openFee;
	}

	@Column(name = "MERCHANT_ID", length = 15)

	public String getMerchantId() {
		return this.merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	@Column(name = "THE_ONLY_NO", length = 15)

	public String getTheOnlyNo() {
		return this.theOnlyNo;
	}

	public void setTheOnlyNo(String theOnlyNo) {
		this.theOnlyNo = theOnlyNo;
	}

	@Column(name = "CLR_DATE", nullable = false, length = 10)

	public String getClrDate() {
		return this.clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	@Column(name = "ACPT_ORG_ID", nullable = false, length = 15)

	public String getAcptOrgId() {
		return this.acptOrgId;
	}

	public void setAcptOrgId(String acptOrgId) {
		this.acptOrgId = acptOrgId;
	}

	@Column(name = "ACPT_TYPE", nullable = false, length = 1)

	public String getAcptType() {
		return this.acptType;
	}

	public void setAcptType(String acptType) {
		this.acptType = acptType;
	}

	@Column(name = "ACPT_ID", length = 15)

	public String getAcptId() {
		return this.acptId;
	}

	public void setAcptId(String acptId) {
		this.acptId = acptId;
	}

	@Column(name = "USER_ID", nullable = false, length = 50)

	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "END_DEAL_NO", length = 20)

	public String getEndDealNo() {
		return this.endDealNo;
	}

	public void setEndDealNo(String endDealNo) {
		this.endDealNo = endDealNo;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "LAST_MODIFY_DATE", length = 7)

	public Date getLastModifyDate() {
		return this.lastModifyDate;
	}

	public void setLastModifyDate(Date lastModifyDate) {
		this.lastModifyDate = lastModifyDate;
	}

	@Column(name = "DEAL_NO", precision = 38, scale = 0)

	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "NOTE", length = 200)

	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}