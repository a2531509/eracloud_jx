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
 * AccCreditLimit entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "ACC_CREDIT_LIMIT", uniqueConstraints = @UniqueConstraint(columnNames = {
		"CARD_NO", "ACC_KIND" }))
public class AccCreditLimit implements java.io.Serializable {

	// Fields

	private Long dealNo;
	private String customerId;
	private String cardType;
	private String cardNo;
	private Long accNo;
	private String accKind;
	private String itemNo;
	private Long amt;
	private Long maxAmt;
	private String clrDate;
	private Date bizTime;
	private String orgId;
	private String brchId;
	private String userId;
	private String note;
	private String state;
	private Long minAmt;
	private Long maxNum;

	// Constructors

	/** default constructor */
	public AccCreditLimit() {
	}

	/** minimal constructor */
	public AccCreditLimit(Long dealNo) {
		this.dealNo = dealNo;
	}

	/** full constructor */
	public AccCreditLimit(Long dealNo, String customerId, String cardType,
			String cardNo, Long accNo, String accKind, String itemNo,
			Long amt, Long maxAmt, String clrDate, Date bizTime,
			String orgId, String brchId, String userId, String note,
			String state, Long minAmt) {
		this.dealNo = dealNo;
		this.customerId = customerId;
		this.cardType = cardType;
		this.cardNo = cardNo;
		this.accNo = accNo;
		this.accKind = accKind;
		this.itemNo = itemNo;
		this.amt = amt;
		this.maxAmt = maxAmt;
		this.clrDate = clrDate;
		this.bizTime = bizTime;
		this.orgId = orgId;
		this.brchId = brchId;
		this.userId = userId;
		this.note = note;
		this.state = state;
		this.minAmt = minAmt;
	}

	// Property accessors
	@Id
	@Column(name = "DEAL_NO", unique = true, nullable = false, precision = 16, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
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

	@Column(name = "ACC_NO", precision = 38, scale = 0)
	public Long getAccNo() {
		return this.accNo;
	}

	public void setAccNo(Long accNo) {
		this.accNo = accNo;
	}

	@Column(name = "ACC_KIND", length = 2)
	public String getAccKind() {
		return this.accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	@Column(name = "ITEM_NO", length = 6)
	public String getItemNo() {
		return this.itemNo;
	}

	public void setItemNo(String itemNo) {
		this.itemNo = itemNo;
	}

	@Column(name = "AMT", precision = 16, scale = 0)
	public Long getAmt() {
		return this.amt;
	}

	public void setAmt(Long amt) {
		this.amt = amt;
	}

	@Column(name = "MAX_AMT", precision = 16, scale = 0)
	public Long getMaxAmt() {
		return this.maxAmt;
	}

	public void setMaxAmt(Long maxAmt) {
		this.maxAmt = maxAmt;
	}

	@Column(name = "CLR_DATE", length = 10)
	public String getClrDate() {
		return this.clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}
	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "BIZ_TIME", length = 7)
	public Date getBizTime() {
		return this.bizTime;
	}

	public void setBizTime(Date bizTime) {
		this.bizTime = bizTime;
	}

	@Column(name = "ORG_ID", length = 15)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "BRCH_ID", length = 16)
	public String getBrchId() {
		return this.brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	@Column(name = "USER_ID", length = 8)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "NOTE", length = 500)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "STATE", length = 1)
	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

	@Column(name = "MIN_AMT", precision = 16, scale = 0)
	public Long getMinAmt() {
		return this.minAmt;
	}

	public void setMinAmt(Long minAmt) {
		this.minAmt = minAmt;
	}

	@Column(name = "MAX_NUM", precision = 16, scale = 0)
	public Long getMaxNum() {
		return maxNum;
	}

	public void setMaxNum(Long maxNum) {
		this.maxNum = maxNum;
	}
	
	
}