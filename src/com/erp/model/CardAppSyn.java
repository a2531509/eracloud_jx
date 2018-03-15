package com.erp.model;

import java.math.BigDecimal;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * TrServRec entity.
 *
 * @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "Card_App_Syn")
public class CardAppSyn implements java.io.Serializable {

	// Fields

	private Long dealNo;


	private String name;

	@Column(name = "NAME", length = 100)
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	private String customerId;

	private String cardId;

	private String cardNo;

	private String cardType;

	private Date bizTime;

	private Long fee;


	@Column(name = "BIZ_TIME", length = 100)
	public Date getBizTime() {
		return bizTime;
	}

	public void setBizTime(Date bizTime) {
		this.bizTime = bizTime;
	}

	@Column(name = "FEE", length = 100)
	public Long getFee() {
		return fee;
	}

	public void setFee(Long fee) {
		this.fee = fee;
	}


	private String certNo;



	private String acptType;

	private String acptId;

	private String userId;

	private String dealType;

	private String clrDate;

	@Column(name = "CLR_DATE", length = 20)
	public String getClrDate() {
		return clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	@Column(name = "DEAL_TYPE", length = 10)
	public String getDealType() {
		return dealType;
	}

	public void setDealType(String dealType) {
		this.dealType = dealType;
	}

	@Column(name = "USER_ID", length = 10)
	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	// Constructors
	@Column(name = "ACPT_ID", length = 20)
	public String getAcptId() {
		return acptId;
	}

	public void setAcptId(String acptId) {
		this.acptId = acptId;
	}

	/** default constructor */
	public CardAppSyn() {
	}

	// Property accessors
	@Id
	@Column(name = "DEAL_NO", unique = true, nullable = false, precision = 22, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}


	public CardAppSyn(Long dealNo, String name, String customerId, String cardId, String cardNo, String cardType,
					  Long fee, String certNo, String acptType, Date bizTime, String acptId, String userId,String dealType, String clrDate) {
		super();
		this.dealNo = dealNo;
		this.name = name;
		this.customerId = customerId;
		this.cardId = cardId;
		this.cardNo = cardNo;
		this.cardType = cardType;
		this.fee = fee;
		this.certNo = certNo;
		this.acptType = acptType;
		this.bizTime = bizTime;
		this.acptId = acptId;
		this.userId = userId;
		this.dealType = dealType;
		this.clrDate = clrDate;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
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

	@Column(name = "CARD_NO", length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "CARD_TYPE", length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}


	@Column(name = "CERT_NO", length = 32)
	public String getCertNo() {
		return this.certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}


	/**
	 * @return the acptType
	 */
	@Column(name = "ACPT_TYPE", length = 1)
	public String getAcptType() {
		return acptType;
	}

	/**
	 * @param acptType the acptType to set
	 */
	public void setAcptType(String acptType) {
		this.acptType = acptType;
	}

}