package com.erp.model;

import java.math.BigDecimal;
import java.util.Date;
import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * StlDealSum entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "STL_DEAL_SUM")
public class StlDealSum implements java.io.Serializable {

	// Fields

	private StlDealSumId id;
	private String merchantId;
	private String merchantName;
	private String beginDate;
	private String endDate;
	private String stlMode;
	private String stlDays;
	private String stlWay;
	private Long stlLimit;
	private Long totDealNum;
	private Long totDealAmt;
	private Long dealNum;
	private Long dealAmt;
	private Long thNum;
	private Long thAmt;
	private Long dealFee;
	private String stlDate;
	private Long stlAmt;
	private String userId;
	private Date operDate;
	private Date chkDate;
	private String chkUserId;
	private Date vrfDate;
	private String vrfUserId;
	private BigDecimal regNo;
	private String stlState;
	private Date expDate;
	private String expUserId;
	private String note;

	// Constructors

	/** default constructor */
	public StlDealSum() {
	}

	/** minimal constructor */
	public StlDealSum(StlDealSumId id) {
		this.id = id;
	}

	/** full constructor */
	public StlDealSum(StlDealSumId id, String merchantId, String merchantName,
			String beginDate, String endDate, String stlMode, String stlDays,
			String stlWay, Long stlLimit, Long totDealNum, Long totDealAmt,
			Long dealNum, Long dealAmt, Long thNum, Long thAmt, Long dealFee,
			String stlDate, Long stlAmt, String userId, Date operDate,
			Date chkDate, String chkUserId, Date vrfDate, String vrfUserId,
			BigDecimal regNo, String stlState, Date expDate, String expUserId,
			String note) {
		this.id = id;
		this.merchantId = merchantId;
		this.merchantName = merchantName;
		this.beginDate = beginDate;
		this.endDate = endDate;
		this.stlMode = stlMode;
		this.stlDays = stlDays;
		this.stlWay = stlWay;
		this.stlLimit = stlLimit;
		this.totDealNum = totDealNum;
		this.totDealAmt = totDealAmt;
		this.dealNum = dealNum;
		this.dealAmt = dealAmt;
		this.thNum = thNum;
		this.thAmt = thAmt;
		this.dealFee = dealFee;
		this.stlDate = stlDate;
		this.stlAmt = stlAmt;
		this.userId = userId;
		this.operDate = operDate;
		this.chkDate = chkDate;
		this.chkUserId = chkUserId;
		this.vrfDate = vrfDate;
		this.vrfUserId = vrfUserId;
		this.regNo = regNo;
		this.stlState = stlState;
		this.expDate = expDate;
		this.expUserId = expUserId;
		this.note = note;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "stlSumNo", column = @Column(name = "STL_SUM_NO", nullable = false, precision = 22, scale = 0)),
			@AttributeOverride(name = "cardType", column = @Column(name = "CARD_TYPE", nullable = false, length = 3)),
			@AttributeOverride(name = "accKind", column = @Column(name = "ACC_KIND", nullable = false, length = 2)) })
	public StlDealSumId getId() {
		return this.id;
	}

	public void setId(StlDealSumId id) {
		this.id = id;
	}

	@Column(name = "MERCHANT_ID", length = 16)
	public String getMerchantId() {
		return this.merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	@Column(name = "MERCHANT_NAME", length = 64)
	public String getMerchantName() {
		return this.merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	@Column(name = "BEGIN_DATE", length = 10)
	public String getBeginDate() {
		return this.beginDate;
	}

	public void setBeginDate(String beginDate) {
		this.beginDate = beginDate;
	}

	@Column(name = "END_DATE", length = 10)
	public String getEndDate() {
		return this.endDate;
	}

	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}

	@Column(name = "STL_MODE", length = 2)
	public String getStlMode() {
		return this.stlMode;
	}

	public void setStlMode(String stlMode) {
		this.stlMode = stlMode;
	}

	@Column(name = "STL_DAYS", length = 20)
	public String getStlDays() {
		return this.stlDays;
	}

	public void setStlDays(String stlDays) {
		this.stlDays = stlDays;
	}

	@Column(name = "STL_WAY", length = 12)
	public String getStlWay() {
		return this.stlWay;
	}

	public void setStlWay(String stlWay) {
		this.stlWay = stlWay;
	}

	@Column(name = "STL_LIMIT", precision = 16, scale = 0)
	public Long getStlLimit() {
		return this.stlLimit;
	}

	public void setStlLimit(Long stlLimit) {
		this.stlLimit = stlLimit;
	}

	@Column(name = "TOT_DEAL_NUM", precision = 12, scale = 0)
	public Long getTotDealNum() {
		return this.totDealNum;
	}

	public void setTotDealNum(Long totDealNum) {
		this.totDealNum = totDealNum;
	}

	@Column(name = "TOT_DEAL_AMT", precision = 16, scale = 0)
	public Long getTotDealAmt() {
		return this.totDealAmt;
	}

	public void setTotDealAmt(Long totDealAmt) {
		this.totDealAmt = totDealAmt;
	}

	@Column(name = "DEAL_NUM", precision = 12, scale = 0)
	public Long getDealNum() {
		return this.dealNum;
	}

	public void setDealNum(Long dealNum) {
		this.dealNum = dealNum;
	}

	@Column(name = "DEAL_AMT", precision = 16, scale = 0)
	public Long getDealAmt() {
		return this.dealAmt;
	}

	public void setDealAmt(Long dealAmt) {
		this.dealAmt = dealAmt;
	}

	@Column(name = "TH_NUM", precision = 12, scale = 0)
	public Long getThNum() {
		return this.thNum;
	}

	public void setThNum(Long thNum) {
		this.thNum = thNum;
	}

	@Column(name = "TH_AMT", precision = 16, scale = 0)
	public Long getThAmt() {
		return this.thAmt;
	}

	public void setThAmt(Long thAmt) {
		this.thAmt = thAmt;
	}

	@Column(name = "DEAL_FEE", precision = 16, scale = 0)
	public Long getDealFee() {
		return this.dealFee;
	}

	public void setDealFee(Long dealFee) {
		this.dealFee = dealFee;
	}

	@Column(name = "STL_DATE", length = 10)
	public String getStlDate() {
		return this.stlDate;
	}

	public void setStlDate(String stlDate) {
		this.stlDate = stlDate;
	}

	@Column(name = "STL_AMT", precision = 16, scale = 0)
	public Long getStlAmt() {
		return this.stlAmt;
	}

	public void setStlAmt(Long stlAmt) {
		this.stlAmt = stlAmt;
	}

	@Column(name = "USER_ID", length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "OPER_DATE", length = 7)
	public Date getOperDate() {
		return this.operDate;
	}

	public void setOperDate(Date operDate) {
		this.operDate = operDate;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "CHK_DATE", length = 7)
	public Date getChkDate() {
		return this.chkDate;
	}

	public void setChkDate(Date chkDate) {
		this.chkDate = chkDate;
	}

	@Column(name = "CHK_USER_ID", length = 10)
	public String getChkUserId() {
		return this.chkUserId;
	}

	public void setChkUserId(String chkUserId) {
		this.chkUserId = chkUserId;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "VRF_DATE", length = 7)
	public Date getVrfDate() {
		return this.vrfDate;
	}

	public void setVrfDate(Date vrfDate) {
		this.vrfDate = vrfDate;
	}

	@Column(name = "VRF_USER_ID", length = 10)
	public String getVrfUserId() {
		return this.vrfUserId;
	}

	public void setVrfUserId(String vrfUserId) {
		this.vrfUserId = vrfUserId;
	}

	@Column(name = "REG_NO", precision = 22, scale = 0)
	public BigDecimal getRegNo() {
		return this.regNo;
	}

	public void setRegNo(BigDecimal regNo) {
		this.regNo = regNo;
	}

	@Column(name = "STL_STATE", length = 1)
	public String getStlState() {
		return this.stlState;
	}

	public void setStlState(String stlState) {
		this.stlState = stlState;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "EXP_DATE", length = 7)
	public Date getExpDate() {
		return this.expDate;
	}

	public void setExpDate(Date expDate) {
		this.expDate = expDate;
	}

	@Column(name = "EXP_USER_ID", length = 10)
	public String getExpUserId() {
		return this.expUserId;
	}

	public void setExpUserId(String expUserId) {
		this.expUserId = expUserId;
	}

	@Column(name = "NOTE", length = 64)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}