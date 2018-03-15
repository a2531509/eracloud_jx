package com.erp.model;

import java.sql.Timestamp;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * CardSaleRec entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "CARD_SALE_REC")
public class CardSaleRec implements java.io.Serializable {

	// Fields

	private Long dealNo;
	private String orgId;
	private String brchId;
	private Date saleDate;
	private String userId;
	private String customerId;
	private String customerType;
	private String cardTypeCatalog;
	private String startCardNo;
	private String endCardNo;
	private Long totNum;
	private Long totAmt;
	private String drwFlag;
	private String sndFlag;
	private String payWay;
	private String payFlag;
	private Long payBatId;
	private String invFlag;
	private Long invBatNo;
	private String vrfFlag;
	private String mngOperId;
	private String saleState;
	private String clrDate;
	private Long foregiftAmt;
	private Integer dealCode;
	private Long otherFee;
	private Long costFeeAmt;
	private String agtName;
	private String agtCertNo;
	private String agtTelNo;

	// Constructors

	/** default constructor */
	public CardSaleRec() {
	}

	/** minimal constructor */
	public CardSaleRec(Long dealNo) {
		this.dealNo = dealNo;
	}

	/** full constructor */
	public CardSaleRec(Long dealNo, String orgId, String brchId,
			Timestamp saleDate, String userId, String customerId,
			String customerType, String cardTypeCatalog, String startCardNo,
			String endCardNo, Long totNum, Long totAmt, String drwFlag,
			String sndFlag, String payWay, String payFlag, Long payBatId,
			String invFlag, Long invBatNo, String vrfFlag,
			String mngOperId, String saleState, String clrDate,
			Long foregiftAmt, Integer dealCode, Long otherFee, Long costFeeAmt) {
		this.dealNo = dealNo;
		this.orgId = orgId;
		this.brchId = brchId;
		this.saleDate = saleDate;
		this.userId = userId;
		this.customerId = customerId;
		this.customerType = customerType;
		this.cardTypeCatalog = cardTypeCatalog;
		this.startCardNo = startCardNo;
		this.endCardNo = endCardNo;
		this.totNum = totNum;
		this.totAmt = totAmt;
		this.drwFlag = drwFlag;
		this.sndFlag = sndFlag;
		this.payWay = payWay;
		this.payFlag = payFlag;
		this.payBatId = payBatId;
		this.invFlag = invFlag;
		this.invBatNo = invBatNo;
		this.vrfFlag = vrfFlag;
		this.mngOperId = mngOperId;
		this.saleState = saleState;
		this.clrDate = clrDate;
		this.foregiftAmt = foregiftAmt;
		this.dealCode = dealCode;
		this.otherFee = otherFee;
		this.costFeeAmt = costFeeAmt;
	}

	// Property accessors
	@Id
	@Column(name = "DEAL_NO", unique = true, nullable = false, precision = 38, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "ORG_ID", length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "BRCH_ID", length = 8)
	public String getBrchId() {
		return this.brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	@Column(name = "SALE_DATE", length = 7)
	public Date getSaleDate() {
		return this.saleDate;
	}

	public void setSaleDate(Date saleDate) {
		this.saleDate = saleDate;
	}

	@Column(name = "USER_ID", length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "CUSTOMER_ID", length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "CUSTOMER_TYPE", length = 1)
	public String getCustomerType() {
		return this.customerType;
	}

	public void setCustomerType(String customerType) {
		this.customerType = customerType;
	}

	@Column(name = "CARD_TYPE_CATALOG", length = 1)
	public String getCardTypeCatalog() {
		return this.cardTypeCatalog;
	}

	public void setCardTypeCatalog(String cardTypeCatalog) {
		this.cardTypeCatalog = cardTypeCatalog;
	}

	@Column(name = "START_CARD_NO", length = 20)
	public String getStartCardNo() {
		return this.startCardNo;
	}

	public void setStartCardNo(String startCardNo) {
		this.startCardNo = startCardNo;
	}

	@Column(name = "END_CARD_NO", length = 20)
	public String getEndCardNo() {
		return this.endCardNo;
	}

	public void setEndCardNo(String endCardNo) {
		this.endCardNo = endCardNo;
	}

	@Column(name = "TOT_NUM", precision = 12, scale = 0)
	public Long getTotNum() {
		return this.totNum;
	}

	public void setTotNum(Long totNum) {
		this.totNum = totNum;
	}

	@Column(name = "TOT_AMT", precision = 16, scale = 0)
	public Long getTotAmt() {
		return this.totAmt;
	}

	public void setTotAmt(Long totAmt) {
		this.totAmt = totAmt;
	}

	@Column(name = "DRW_FLAG", length = 1)
	public String getDrwFlag() {
		return this.drwFlag;
	}

	public void setDrwFlag(String drwFlag) {
		this.drwFlag = drwFlag;
	}

	@Column(name = "SND_FLAG", length = 1)
	public String getSndFlag() {
		return this.sndFlag;
	}

	public void setSndFlag(String sndFlag) {
		this.sndFlag = sndFlag;
	}

	@Column(name = "PAY_WAY", length = 1)
	public String getPayWay() {
		return this.payWay;
	}

	public void setPayWay(String payWay) {
		this.payWay = payWay;
	}

	@Column(name = "PAY_FLAG", length = 1)
	public String getPayFlag() {
		return this.payFlag;
	}

	public void setPayFlag(String payFlag) {
		this.payFlag = payFlag;
	}

	@Column(name = "PAY_BAT_ID", precision = 38, scale = 0)
	public Long getPayBatId() {
		return this.payBatId;
	}

	public void setPayBatId(Long payBatId) {
		this.payBatId = payBatId;
	}

	@Column(name = "INV_FLAG", length = 1)
	public String getInvFlag() {
		return this.invFlag;
	}

	public void setInvFlag(String invFlag) {
		this.invFlag = invFlag;
	}

	@Column(name = "INV_BAT_NO", precision = 38, scale = 0)
	public Long getInvBatNo() {
		return this.invBatNo;
	}

	public void setInvBatNo(Long invBatNo) {
		this.invBatNo = invBatNo;
	}

	@Column(name = "VRF_FLAG", length = 1)
	public String getVrfFlag() {
		return this.vrfFlag;
	}

	public void setVrfFlag(String vrfFlag) {
		this.vrfFlag = vrfFlag;
	}

	@Column(name = "MNG_OPER_ID", length = 10)
	public String getMngOperId() {
		return this.mngOperId;
	}

	public void setMngOperId(String mngOperId) {
		this.mngOperId = mngOperId;
	}

	@Column(name = "SALE_STATE", length = 1)
	public String getSaleState() {
		return this.saleState;
	}

	public void setSaleState(String saleState) {
		this.saleState = saleState;
	}

	@Column(name = "CLR_DATE", length = 10)
	public String getClrDate() {
		return this.clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	@Column(name = "FOREGIFT_AMT", precision = 16, scale = 0)
	public Long getForegiftAmt() {
		return this.foregiftAmt;
	}

	public void setForegiftAmt(Long foregiftAmt) {
		this.foregiftAmt = foregiftAmt;
	}

	@Column(name = "DEAL_CODE", precision = 8, scale = 0)
	public Integer getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(Integer dealCode) {
		this.dealCode = dealCode;
	}

	@Column(name = "OTHER_FEE", precision = 16, scale = 0)
	public Long getOtherFee() {
		return this.otherFee;
	}

	public void setOtherFee(Long otherFee) {
		this.otherFee = otherFee;
	}

	@Column(name = "COST_FEE_AMT", precision = 16, scale = 0)
	public Long getCostFeeAmt() {
		return this.costFeeAmt;
	}

	public void setCostFeeAmt(Long costFeeAmt) {
		this.costFeeAmt = costFeeAmt;
	}
	@Column(name = "AGT_NAME", length = 20)
	public String getAgtName() {
		return agtName;
	}

	public void setAgtName(String agtName) {
		this.agtName = agtName;
	}
	@Column(name = "AGT_CERT_NO", length = 18)
	public String getAgtCertNo() {
		return agtCertNo;
	}

	public void setAgtCertNo(String agtCertNo) {
		this.agtCertNo = agtCertNo;
	}
	@Column(name = "AGT_TEL_NO", length = 11)
	public String getAgtTelNo() {
		return agtTelNo;
	}

	public void setAgtTelNo(String agtTelNo) {
		this.agtTelNo = agtTelNo;
	}

}