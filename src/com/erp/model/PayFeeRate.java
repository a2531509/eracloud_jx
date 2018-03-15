package com.erp.model;

import java.math.BigDecimal;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * PayFeeRate entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "PAY_FEE_RATE")
@SequenceGenerator(name="SEQ_PayFeeRate",allocationSize=1,initialValue=1,sequenceName="SEQ_FEE_RATE_ID" )
public class PayFeeRate implements java.io.Serializable {

	// Fields

	private Long feeRateId;
	private String merchantId;
	private Integer dealCode;
	private Date begindate;
	private String feeType;
	private BigDecimal feeRate;
	private String feeState;
	private BigDecimal feeMax;
	private BigDecimal feeMin;
	private String haveSection;
	private String inOut;
	private Date insertDate;
	private String userId;
	private String chkUserId;
	private Date chkDate;
	private String chkState;
	private String note;

	// Constructors

	/** default constructor */
	public PayFeeRate() {
	}

	/** minimal constructor */
	public PayFeeRate(Long feeRateId, String merchantId,
			Integer dealCode, Date begindate) {
		this.feeRateId = feeRateId;
		this.merchantId = merchantId;
		this.dealCode = dealCode;
		this.begindate = begindate;
	}

	/** full constructor */
	public PayFeeRate(Long feeRateId, String merchantId,
			Integer dealCode, Date begindate, String feeType, BigDecimal feeRate,
			String feeState, BigDecimal feeMax, BigDecimal feeMin, String haveSection,
			String inOut, Date insertDate, String userId, String chkUserId,
			Date chkDate, String chkState, String note) {
		this.feeRateId = feeRateId;
		this.merchantId = merchantId;
		this.dealCode = dealCode;
		this.begindate = begindate;
		this.feeType = feeType;
		this.feeRate = feeRate;
		this.feeState = feeState;
		this.feeMax = feeMax;
		this.feeMin = feeMin;
		this.haveSection = haveSection;
		this.inOut = inOut;
		this.insertDate = insertDate;
		this.userId = userId;
		this.chkUserId = chkUserId;
		this.chkDate = chkDate;
		this.chkState = chkState;
		this.note = note;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_PayFeeRate")
	@Column(name = "FEE_RATE_ID", unique = true, nullable = false, precision = 22, scale = 0)
	public Long getFeeRateId() {
		return this.feeRateId;
	}

	public void setFeeRateId(Long feeRateId) {
		this.feeRateId = feeRateId;
	}

	@Column(name = "MERCHANT_ID", nullable = false, length = 16)
	public String getMerchantId() {
		return this.merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	@Column(name = "DEAL_CODE", nullable = false, precision = 6, scale = 0)
	public Integer getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(Integer dealCode) {
		this.dealCode = dealCode;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "BEGINDATE", nullable = false, length = 7)
	public Date getBegindate() {
		return this.begindate;
	}

	public void setBegindate(Date begindate) {
		this.begindate = begindate;
	}

	@Column(name = "FEE_TYPE", length = 1)
	public String getFeeType() {
		return this.feeType;
	}

	public void setFeeType(String feeType) {
		this.feeType = feeType;
	}

	@Column(name = "FEE_RATE", precision = 10, scale = 0)
	public BigDecimal getFeeRate() {
		return this.feeRate;
	}

	public void setFeeRate(BigDecimal feeRate) {
		this.feeRate = feeRate;
	}

	@Column(name = "FEE_STATE", length = 1)
	public String getFeeState() {
		return this.feeState;
	}

	public void setFeeState(String feeState) {
		this.feeState = feeState;
	}

	@Column(name = "FEE_MAX", precision = 16, scale = 0)
	public BigDecimal getFeeMax() {
		return this.feeMax;
	}

	public void setFeeMax(BigDecimal feeMax) {
		this.feeMax = feeMax;
	}

	@Column(name = "FEE_MIN", precision = 16, scale = 0)
	public BigDecimal getFeeMin() {
		return this.feeMin;
	}

	public void setFeeMin(BigDecimal feeMin) {
		this.feeMin = feeMin;
	}

	@Column(name = "HAVE_SECTION", length = 1)
	public String getHaveSection() {
		return this.haveSection;
	}

	public void setHaveSection(String haveSection) {
		this.haveSection = haveSection;
	}

	@Column(name = "IN_OUT", length = 1)
	public String getInOut() {
		return this.inOut;
	}

	public void setInOut(String inOut) {
		this.inOut = inOut;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "INSERT_DATE", length = 7)
	public Date getInsertDate() {
		return this.insertDate;
	}

	public void setInsertDate(Date insertDate) {
		this.insertDate = insertDate;
	}

	@Column(name = "USER_ID", length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "CHK_USER_ID", length = 10)
	public String getChkUserId() {
		return this.chkUserId;
	}

	public void setChkUserId(String chkUserId) {
		this.chkUserId = chkUserId;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "CHK_DATE", length = 7)
	public Date getChkDate() {
		return this.chkDate;
	}

	public void setChkDate(Date chkDate) {
		this.chkDate = chkDate;
	}

	@Column(name = "CHK_STATE", length = 1)
	public String getChkState() {
		return this.chkState;
	}

	public void setChkState(String chkState) {
		this.chkState = chkState;
	}

	@Column(name = "NOTE", length = 32)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}