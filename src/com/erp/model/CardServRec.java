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
 * CardServRec entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_SERV_REC")
public class CardServRec implements java.io.Serializable {

	// Fields

	private Long dealNo;
	private Integer dealCode;
	private String cardType;
	private String cardNo;
	private String accKind;
	private Long num;
	private Long num2;
	private Long num3;
	private Long amt;
	private Long amt2;
	private Long amt3;
	private Long amt4;
	private Long amt5;
	private String cardType2;
	private String cardNo2;
	private String accKind2;
	private String pwd;
	private String pwd2;
	private String merchantId;
	private String endId;
	private String stkCode;
	private String stkBatchId;
	private String stkTaskId;
	private String stkStartNo;
	private String stkEndNo;
	private String stkIsSure;
	private String orgIdIn;
	private String brchIdIn;
	private String userIdIn;
	private String goodsStateIn;
	private String orgIdOut;
	private String brchIdOut;
	private String userIdOut;
	private String goodsStateOut;
	private String customerId;
	private String customerName;
	private String certType;
	private String certNo;
	private String telNo;
	private String agtName;
	private String agtTelNo;
	private String agtCertType;
	private String agtCertNo;
	private String acptType;
	private Date dealTime;
	private String orgId;
	private String brchId;
	private String userId;
	private String marketId;
	private String marketRegNo;
	private String dealDate;
	private String endBatchNo;
	private String endDealNo;
	private Date endTime;
	private String cardId;
	private Long prvBal;
	private Long cardCounter;
	private String psamNo;
	private String grtUserId;
	private String grtUserName;
	private String reason;
	private BigDecimal oldActionNo;
	private String clrDate;
	private String dealState;
	private String rsvOne;
	private String rsvTwo;
	private String rsvThree;
	private String rsvFour;
	private String rsvFive;
	private String note;

	// Constructors

	/** default constructor */
	public CardServRec() {
	}

	/** minimal constructor */
	public CardServRec(Long dealNo, Date dealTime, String userId) {
		this.dealNo = dealNo;
		this.dealTime = dealTime;
		this.userId = userId;
	}

	/** full constructor */
	public CardServRec(Long dealNo, Integer dealCode, String cardType,
			String cardNo, String accKind, Long num, Long num2, Long num3,
			Long amt, Long amt2, Long amt3, Long amt4, Long amt5,
			String cardType2, String cardNo2, String accKind2, String pwd,
			String pwd2, String merchantId, String endId, String stkCode,
			String stkBatchId, String stkTaskId, String stkStartNo,
			String stkEndNo, String stkIsSure, String orgIdIn, String brchIdIn,
			String userIdIn, String goodsStateIn, String orgIdOut,
			String brchIdOut, String userIdOut, String goodsStateOut,
			String customerId, String customerName, String certType,
			String certNo, String telNo, String agtName, String agtTelNo,
			String agtCertType, String agtCertNo, String acptType,
			Date dealTime, String orgId, String brchId, String userId,
			String marketId, String marketRegNo, String dealDate,
			String endBatchNo, String endDealNo, Date endTime, String cardId,
			Long prvBal, Long cardCounter, String psamNo, String grtUserId,
			String grtUserName, String reason, BigDecimal oldActionNo,
			String clrDate, String dealState, String rsvOne, String rsvTwo,
			String rsvThree, String rsvFour, String rsvFive, String note) {
		this.dealNo = dealNo;
		this.dealCode = dealCode;
		this.cardType = cardType;
		this.cardNo = cardNo;
		this.accKind = accKind;
		this.num = num;
		this.num2 = num2;
		this.num3 = num3;
		this.amt = amt;
		this.amt2 = amt2;
		this.amt3 = amt3;
		this.amt4 = amt4;
		this.amt5 = amt5;
		this.cardType2 = cardType2;
		this.cardNo2 = cardNo2;
		this.accKind2 = accKind2;
		this.pwd = pwd;
		this.pwd2 = pwd2;
		this.merchantId = merchantId;
		this.endId = endId;
		this.stkCode = stkCode;
		this.stkBatchId = stkBatchId;
		this.stkTaskId = stkTaskId;
		this.stkStartNo = stkStartNo;
		this.stkEndNo = stkEndNo;
		this.stkIsSure = stkIsSure;
		this.orgIdIn = orgIdIn;
		this.brchIdIn = brchIdIn;
		this.userIdIn = userIdIn;
		this.goodsStateIn = goodsStateIn;
		this.orgIdOut = orgIdOut;
		this.brchIdOut = brchIdOut;
		this.userIdOut = userIdOut;
		this.goodsStateOut = goodsStateOut;
		this.customerId = customerId;
		this.customerName = customerName;
		this.certType = certType;
		this.certNo = certNo;
		this.telNo = telNo;
		this.agtName = agtName;
		this.agtTelNo = agtTelNo;
		this.agtCertType = agtCertType;
		this.agtCertNo = agtCertNo;
		this.acptType = acptType;
		this.dealTime = dealTime;
		this.orgId = orgId;
		this.brchId = brchId;
		this.userId = userId;
		this.marketId = marketId;
		this.marketRegNo = marketRegNo;
		this.dealDate = dealDate;
		this.endBatchNo = endBatchNo;
		this.endDealNo = endDealNo;
		this.endTime = endTime;
		this.cardId = cardId;
		this.prvBal = prvBal;
		this.cardCounter = cardCounter;
		this.psamNo = psamNo;
		this.grtUserId = grtUserId;
		this.grtUserName = grtUserName;
		this.reason = reason;
		this.oldActionNo = oldActionNo;
		this.clrDate = clrDate;
		this.dealState = dealState;
		this.rsvOne = rsvOne;
		this.rsvTwo = rsvTwo;
		this.rsvThree = rsvThree;
		this.rsvFour = rsvFour;
		this.rsvFive = rsvFive;
		this.note = note;
	}

	// Property accessors
	@Id
	@Column(name = "DEAL_NO", unique = true, nullable = false, precision = 22, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "DEAL_CODE", precision = 6, scale = 0)
	public Integer getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(Integer dealCode) {
		this.dealCode = dealCode;
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

	@Column(name = "ACC_KIND", length = 2)
	public String getAccKind() {
		return this.accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	@Column(name = "NUM", precision = 16, scale = 0)
	public Long getNum() {
		return this.num;
	}

	public void setNum(Long num) {
		this.num = num;
	}

	@Column(name = "NUM2", precision = 16, scale = 0)
	public Long getNum2() {
		return this.num2;
	}

	public void setNum2(Long num2) {
		this.num2 = num2;
	}

	@Column(name = "NUM3", precision = 16, scale = 0)
	public Long getNum3() {
		return this.num3;
	}

	public void setNum3(Long num3) {
		this.num3 = num3;
	}

	@Column(name = "AMT", precision = 16, scale = 0)
	public Long getAmt() {
		return this.amt;
	}

	public void setAmt(Long amt) {
		this.amt = amt;
	}

	@Column(name = "AMT2", precision = 16, scale = 0)
	public Long getAmt2() {
		return this.amt2;
	}

	public void setAmt2(Long amt2) {
		this.amt2 = amt2;
	}

	@Column(name = "AMT3", precision = 16, scale = 0)
	public Long getAmt3() {
		return this.amt3;
	}

	public void setAmt3(Long amt3) {
		this.amt3 = amt3;
	}

	@Column(name = "AMT4", precision = 16, scale = 0)
	public Long getAmt4() {
		return this.amt4;
	}

	public void setAmt4(Long amt4) {
		this.amt4 = amt4;
	}

	@Column(name = "AMT5", precision = 16, scale = 0)
	public Long getAmt5() {
		return this.amt5;
	}

	public void setAmt5(Long amt5) {
		this.amt5 = amt5;
	}

	@Column(name = "CARD_TYPE2", length = 3)
	public String getCardType2() {
		return this.cardType2;
	}

	public void setCardType2(String cardType2) {
		this.cardType2 = cardType2;
	}

	@Column(name = "CARD_NO2", length = 20)
	public String getCardNo2() {
		return this.cardNo2;
	}

	public void setCardNo2(String cardNo2) {
		this.cardNo2 = cardNo2;
	}

	@Column(name = "ACC_KIND2", length = 2)
	public String getAccKind2() {
		return this.accKind2;
	}

	public void setAccKind2(String accKind2) {
		this.accKind2 = accKind2;
	}

	@Column(name = "PWD", length = 16)
	public String getPwd() {
		return this.pwd;
	}

	public void setPwd(String pwd) {
		this.pwd = pwd;
	}

	@Column(name = "PWD2", length = 16)
	public String getPwd2() {
		return this.pwd2;
	}

	public void setPwd2(String pwd2) {
		this.pwd2 = pwd2;
	}

	@Column(name = "MERCHANT_ID", length = 16)
	public String getMerchantId() {
		return this.merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	@Column(name = "END_ID", length = 10)
	public String getEndId() {
		return this.endId;
	}

	public void setEndId(String endId) {
		this.endId = endId;
	}

	@Column(name = "STK_CODE", length = 4)
	public String getStkCode() {
		return this.stkCode;
	}

	public void setStkCode(String stkCode) {
		this.stkCode = stkCode;
	}

	@Column(name = "STK_BATCH_ID", length = 10)
	public String getStkBatchId() {
		return this.stkBatchId;
	}

	public void setStkBatchId(String stkBatchId) {
		this.stkBatchId = stkBatchId;
	}

	@Column(name = "STK_TASK_ID", length = 18)
	public String getStkTaskId() {
		return this.stkTaskId;
	}

	public void setStkTaskId(String stkTaskId) {
		this.stkTaskId = stkTaskId;
	}

	@Column(name = "STK_START_NO", length = 20)
	public String getStkStartNo() {
		return this.stkStartNo;
	}

	public void setStkStartNo(String stkStartNo) {
		this.stkStartNo = stkStartNo;
	}

	@Column(name = "STK_END_NO", length = 20)
	public String getStkEndNo() {
		return this.stkEndNo;
	}

	public void setStkEndNo(String stkEndNo) {
		this.stkEndNo = stkEndNo;
	}

	@Column(name = "STK_IS_SURE", length = 1)
	public String getStkIsSure() {
		return this.stkIsSure;
	}

	public void setStkIsSure(String stkIsSure) {
		this.stkIsSure = stkIsSure;
	}

	@Column(name = "ORG_ID_IN", length = 8)
	public String getOrgIdIn() {
		return this.orgIdIn;
	}

	public void setOrgIdIn(String orgIdIn) {
		this.orgIdIn = orgIdIn;
	}

	@Column(name = "BRCH_ID_IN", length = 16)
	public String getBrchIdIn() {
		return this.brchIdIn;
	}

	public void setBrchIdIn(String brchIdIn) {
		this.brchIdIn = brchIdIn;
	}

	@Column(name = "USER_ID_IN", length = 10)
	public String getUserIdIn() {
		return this.userIdIn;
	}

	public void setUserIdIn(String userIdIn) {
		this.userIdIn = userIdIn;
	}

	@Column(name = "GOODS_STATE_IN", length = 1)
	public String getGoodsStateIn() {
		return this.goodsStateIn;
	}

	public void setGoodsStateIn(String goodsStateIn) {
		this.goodsStateIn = goodsStateIn;
	}

	@Column(name = "ORG_ID_OUT", length = 8)
	public String getOrgIdOut() {
		return this.orgIdOut;
	}

	public void setOrgIdOut(String orgIdOut) {
		this.orgIdOut = orgIdOut;
	}

	@Column(name = "BRCH_ID_OUT", length = 16)
	public String getBrchIdOut() {
		return this.brchIdOut;
	}

	public void setBrchIdOut(String brchIdOut) {
		this.brchIdOut = brchIdOut;
	}

	@Column(name = "USER_ID_OUT", length = 10)
	public String getUserIdOut() {
		return this.userIdOut;
	}

	public void setUserIdOut(String userIdOut) {
		this.userIdOut = userIdOut;
	}

	@Column(name = "GOODS_STATE_OUT", length = 1)
	public String getGoodsStateOut() {
		return this.goodsStateOut;
	}

	public void setGoodsStateOut(String goodsStateOut) {
		this.goodsStateOut = goodsStateOut;
	}

	@Column(name = "CUSTOMER_ID", length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "CUSTOMER_NAME", length = 100)
	public String getCustomerName() {
		return this.customerName;
	}

	public void setCustomerName(String customerName) {
		this.customerName = customerName;
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

	@Column(name = "TEL_NO", length = 32)
	public String getTelNo() {
		return this.telNo;
	}

	public void setTelNo(String telNo) {
		this.telNo = telNo;
	}

	@Column(name = "AGT_NAME", length = 32)
	public String getAgtName() {
		return this.agtName;
	}

	public void setAgtName(String agtName) {
		this.agtName = agtName;
	}

	@Column(name = "AGT_TEL_NO", length = 32)
	public String getAgtTelNo() {
		return this.agtTelNo;
	}

	public void setAgtTelNo(String agtTelNo) {
		this.agtTelNo = agtTelNo;
	}

	@Column(name = "AGT_CERT_TYPE", length = 2)
	public String getAgtCertType() {
		return this.agtCertType;
	}

	public void setAgtCertType(String agtCertType) {
		this.agtCertType = agtCertType;
	}

	@Column(name = "AGT_CERT_NO", length = 36)
	public String getAgtCertNo() {
		return this.agtCertNo;
	}

	public void setAgtCertNo(String agtCertNo) {
		this.agtCertNo = agtCertNo;
	}

	@Column(name = "ACPT_TYPE", length = 1)
	public String getAcptType() {
		return this.acptType;
	}

	public void setAcptType(String acptType) {
		this.acptType = acptType;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "DEAL_TIME", nullable = false, length = 7)
	public Date getDealTime() {
		return this.dealTime;
	}

	public void setDealTime(Date dealTime) {
		this.dealTime = dealTime;
	}

	@Column(name = "ORG_ID", length = 8)
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

	@Column(name = "USER_ID", nullable = false, length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "MARKET_ID", length = 20)
	public String getMarketId() {
		return this.marketId;
	}

	public void setMarketId(String marketId) {
		this.marketId = marketId;
	}

	@Column(name = "MARKET_REG_NO", length = 20)
	public String getMarketRegNo() {
		return this.marketRegNo;
	}

	public void setMarketRegNo(String marketRegNo) {
		this.marketRegNo = marketRegNo;
	}

	@Column(name = "DEAL_DATE", length = 10)
	public String getDealDate() {
		return this.dealDate;
	}

	public void setDealDate(String dealDate) {
		this.dealDate = dealDate;
	}

	@Column(name = "END_BATCH_NO", length = 10)
	public String getEndBatchNo() {
		return this.endBatchNo;
	}

	public void setEndBatchNo(String endBatchNo) {
		this.endBatchNo = endBatchNo;
	}

	@Column(name = "END_DEAL_NO", length = 20)
	public String getEndDealNo() {
		return this.endDealNo;
	}

	public void setEndDealNo(String endDealNo) {
		this.endDealNo = endDealNo;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "END_TIME", length = 7)
	public Date getEndTime() {
		return this.endTime;
	}

	public void setEndTime(Date endTime) {
		this.endTime = endTime;
	}

	@Column(name = "CARD_ID", length = 32)
	public String getCardId() {
		return this.cardId;
	}

	public void setCardId(String cardId) {
		this.cardId = cardId;
	}

	@Column(name = "PRV_BAL", precision = 16, scale = 0)
	public Long getPrvBal() {
		return this.prvBal;
	}

	public void setPrvBal(Long prvBal) {
		this.prvBal = prvBal;
	}

	@Column(name = "CARD_COUNTER", precision = 16, scale = 0)
	public Long getCardCounter() {
		return this.cardCounter;
	}

	public void setCardCounter(Long cardCounter) {
		this.cardCounter = cardCounter;
	}

	@Column(name = "PSAM_NO", length = 20)
	public String getPsamNo() {
		return this.psamNo;
	}

	public void setPsamNo(String psamNo) {
		this.psamNo = psamNo;
	}

	@Column(name = "GRT_USER_ID", length = 10)
	public String getGrtUserId() {
		return this.grtUserId;
	}

	public void setGrtUserId(String grtUserId) {
		this.grtUserId = grtUserId;
	}

	@Column(name = "GRT_USER_NAME", length = 32)
	public String getGrtUserName() {
		return this.grtUserName;
	}

	public void setGrtUserName(String grtUserName) {
		this.grtUserName = grtUserName;
	}

	@Column(name = "REASON", length = 150)
	public String getReason() {
		return this.reason;
	}

	public void setReason(String reason) {
		this.reason = reason;
	}

	@Column(name = "OLD_ACTION_NO", precision = 22, scale = 0)
	public BigDecimal getOldActionNo() {
		return this.oldActionNo;
	}

	public void setOldActionNo(BigDecimal oldActionNo) {
		this.oldActionNo = oldActionNo;
	}

	@Column(name = "CLR_DATE", length = 10)
	public String getClrDate() {
		return this.clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	@Column(name = "DEAL_STATE", length = 1)
	public String getDealState() {
		return this.dealState;
	}

	public void setDealState(String dealState) {
		this.dealState = dealState;
	}

	@Column(name = "RSV_ONE", length = 32)
	public String getRsvOne() {
		return this.rsvOne;
	}

	public void setRsvOne(String rsvOne) {
		this.rsvOne = rsvOne;
	}

	@Column(name = "RSV_TWO", length = 36)
	public String getRsvTwo() {
		return this.rsvTwo;
	}

	public void setRsvTwo(String rsvTwo) {
		this.rsvTwo = rsvTwo;
	}

	@Column(name = "RSV_THREE", length = 32)
	public String getRsvThree() {
		return this.rsvThree;
	}

	public void setRsvThree(String rsvThree) {
		this.rsvThree = rsvThree;
	}

	@Column(name = "RSV_FOUR", length = 32)
	public String getRsvFour() {
		return this.rsvFour;
	}

	public void setRsvFour(String rsvFour) {
		this.rsvFour = rsvFour;
	}

	@Column(name = "RSV_FIVE", length = 32)
	public String getRsvFive() {
		return this.rsvFive;
	}

	public void setRsvFive(String rsvFive) {
		this.rsvFive = rsvFive;
	}

	@Column(name = "NOTE", length = 128)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}