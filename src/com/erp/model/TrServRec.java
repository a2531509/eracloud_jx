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
@Table(name = "Tr_SERV_REC")
public class TrServRec implements java.io.Serializable {

	// Fields

	private Long dealNo;

	private Integer dealCode;

	private String customerId;

	private String cardId;

	private String cardNo;

	private String cardType;

	private Long cardAmt;

	private String accNo;

	private String accKind;// 账户类型

	private String subAccNo;

	private String customerName;

	private String certType;

	private String certNo;

	private String telNo;

	private String agtName;

	private String agtTelNo;

	private String agtCertType;

	private String agtCertNo;

	private Date bizTime;

	private String brchId;

	private String userId;

	private String grtUserId;

	private String grtUserName;

	private String cancelReason;

	private Long rtnFgft;

	private String chgCardReason;

	private String oldCardId;

	private String oldCardNo;

	private String balRtnWay;

	private Long balRtnAmt;

	private String inCardNo;

	private String inAccNo;

	private Long amt;// 业务发生金额

	private BigDecimal inAccSubNo;

	private String oldPwd;

	private String newPwd;

	private String clrDate;

	private String dealState;

	private String termId;// 终端号

	private String note;

	private Long urgentFee;

	private Long costFee;

	private String rsvOne;

	private String rsvTwo;

	private String rsvThree;

	private String rsvFour;

	private String rsvFive;

	private Long otherFee;

	private String cardTrCount;// 卡充值计数器

	private Long oldDealNo;// 历史流水

	private Long prvBal;// 卡片业务发生前原始金额

	private String orgIdIn;

	private String brchIdIn;

	private String userIdIn;

	private String orgIdOut;

	private String brchIdOut;

	private String userIdOut;

	private String orgId;
	
	private String coOrgId;
	private String acptType;
    private Long num = 1l;

	// Constructors

	/** default constructor */
	public TrServRec() {
	}

	/** minimal constructor */
	public TrServRec(Long dealNo, Date bizTime, String userId) {
		this.dealNo = dealNo;
		this.bizTime = bizTime;
		this.userId = userId;
	}

	public TrServRec(Long dealNo, Integer dealCode, String customerId, String cardId, String cardNo, String cardType,
			Long cardAmt, String accNo, String accKind, String subAccNo, String customerName, String certType,
			String certNo, String telNo, String agtName, String agtTelNo, String agtCertType, String agtCertNo,
			Date bizTime, String brchId, String userId, String grtUserId, String grtUserName, String cancelReason,
			Long rtnFgft, String chgCardReason, String oldCardId, String oldCardNo, String balRtnWay, Long balRtnAmt,
			String inCardNo, String inAccNo, Long amt, BigDecimal inAccSubNo, String oldPwd, String newPwd,
			String clrDate, String dealState, String termId, String note, Long urgentFee, Long costFee, String rsvOne,
			String rsvTwo, String rsvThree, String rsvFour, String rsvFive, Long otherFee, String cardTrCount,
			Long oldDealNo, Long prvBal, String orgIdIn, String brchIdIn, String userIdIn, String orgIdOut,
			String brchIdOut, String userIdOut, String orgId, String coOrgId, String acptType, Long num) {
		super();
		this.dealNo = dealNo;
		this.dealCode = dealCode;
		this.customerId = customerId;
		this.cardId = cardId;
		this.cardNo = cardNo;
		this.cardType = cardType;
		this.cardAmt = cardAmt;
		this.accNo = accNo;
		this.accKind = accKind;
		this.subAccNo = subAccNo;
		this.customerName = customerName;
		this.certType = certType;
		this.certNo = certNo;
		this.telNo = telNo;
		this.agtName = agtName;
		this.agtTelNo = agtTelNo;
		this.agtCertType = agtCertType;
		this.agtCertNo = agtCertNo;
		this.bizTime = bizTime;
		this.brchId = brchId;
		this.userId = userId;
		this.grtUserId = grtUserId;
		this.grtUserName = grtUserName;
		this.cancelReason = cancelReason;
		this.rtnFgft = rtnFgft;
		this.chgCardReason = chgCardReason;
		this.oldCardId = oldCardId;
		this.oldCardNo = oldCardNo;
		this.balRtnWay = balRtnWay;
		this.balRtnAmt = balRtnAmt;
		this.inCardNo = inCardNo;
		this.inAccNo = inAccNo;
		this.amt = amt;
		this.inAccSubNo = inAccSubNo;
		this.oldPwd = oldPwd;
		this.newPwd = newPwd;
		this.clrDate = clrDate;
		this.dealState = dealState;
		this.termId = termId;
		this.note = note;
		this.urgentFee = urgentFee;
		this.costFee = costFee;
		this.rsvOne = rsvOne;
		this.rsvTwo = rsvTwo;
		this.rsvThree = rsvThree;
		this.rsvFour = rsvFour;
		this.rsvFive = rsvFive;
		this.otherFee = otherFee;
		this.cardTrCount = cardTrCount;
		this.oldDealNo = oldDealNo;
		this.prvBal = prvBal;
		this.orgIdIn = orgIdIn;
		this.brchIdIn = brchIdIn;
		this.userIdIn = userIdIn;
		this.orgIdOut = orgIdOut;
		this.brchIdOut = brchIdOut;
		this.userIdOut = userIdOut;
		this.orgId = orgId;
		this.coOrgId = coOrgId;
		this.acptType = acptType;
		this.num = num;
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

	@Column(name = "DEAL_CODE", length = 8)
	public Integer getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(Integer dealCode) {
		this.dealCode = dealCode;
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
	
	@Column(name = "CARD_AMT", precision = 22, scale = 0)
	public Long getCardAmt() {
		return this.cardAmt;
	}

	public void setCardAmt(Long cardAmt) {
		this.cardAmt = cardAmt;
	}

	@Column(name = "ACC_NO", length = 20)
	public String getAccNo() {
		return this.accNo;
	}

	public void setAccNo(String accNo) {
		this.accNo = accNo;
	}

	@Column(name = "SUB_ACC_NO", precision = 22, scale = 0)
	public String getSubAccNo() {
		return this.subAccNo;
	}

	public void setSubAccNo(String subAccNo) {
		this.subAccNo = subAccNo;
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

	@Column(name = "CERT_NO", length = 32)
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

	@Column(name = "AGT_CERT_NO", length = 22)
	public String getAgtCertNo() {
		return this.agtCertNo;
	}

	public void setAgtCertNo(String agtCertNo) {
		this.agtCertNo = agtCertNo;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "BIZ_TIME", nullable = false, length = 7)
	public Date getBizTime() {
		return this.bizTime;
	}

	public void setBizTime(Date bizTime) {
		this.bizTime = bizTime;
	}

	@Column(name = "BRCH_ID", length = 16)
	public String getBrchId() {
		return this.brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	@Column(name = "USER_ID", nullable = false, length = 8)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "GRT_USER_ID", length = 8)
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

	@Column(name = "CANCEL_REASON", length = 1)
	public String getCancelReason() {
		return this.cancelReason;
	}

	public void setCancelReason(String cancelReason) {
		this.cancelReason = cancelReason;
	}

	@Column(name = "RTN_FGFT", precision = 16, scale = 0)
	public Long getRtnFgft() {
		return this.rtnFgft;
	}

	public void setRtnFgft(Long rtnFgft) {
		this.rtnFgft = rtnFgft;
	}

	@Column(name = "CHG_CARD_REASON", length = 2)
	public String getChgCardReason() {
		return this.chgCardReason;
	}

	public void setChgCardReason(String chgCardReason) {
		this.chgCardReason = chgCardReason;
	}

	@Column(name = "OLD_CARD_ID", length = 50)
	public String getOldCardId() {
		return this.oldCardId;
	}

	public void setOldCardId(String oldCardId) {
		this.oldCardId = oldCardId;
	}

	@Column(name = "OLD_CARD_NO", length = 20)
	public String getOldCardNo() {
		return this.oldCardNo;
	}

	public void setOldCardNo(String oldCardNo) {
		this.oldCardNo = oldCardNo;
	}

	@Column(name = "BAL_RTN_WAY", length = 1)
	public String getBalRtnWay() {
		return this.balRtnWay;
	}

	public void setBalRtnWay(String balRtnWay) {
		this.balRtnWay = balRtnWay;
	}

	@Column(name = "BAL_RTN_AMT", precision = 16, scale = 0)
	public Long getBalRtnAmt() {
		return this.balRtnAmt;
	}

	public void setBalRtnAmt(Long balRtnAmt) {
		this.balRtnAmt = balRtnAmt;
	}

	@Column(name = "IN_CARD_NO", length = 20)
	public String getInCardNo() {
		return this.inCardNo;
	}

	public void setInCardNo(String inCardNo) {
		this.inCardNo = inCardNo;
	}

	@Column(name = "IN_ACC_NO", length = 20)
	public String getInAccNo() {
		return this.inAccNo;
	}

	public void setInAccNo(String inAccNo) {
		this.inAccNo = inAccNo;
	}

	@Column(name = "IN_ACC_SUB_NO", precision = 22, scale = 0)
	public BigDecimal getInAccSubNo() {
		return this.inAccSubNo;
	}

	public void setInAccSubNo(BigDecimal inAccSubNo) {
		this.inAccSubNo = inAccSubNo;
	}

	@Column(name = "OLD_PWD", length = 128)
	public String getOldPwd() {
		return this.oldPwd;
	}

	public void setOldPwd(String oldPwd) {
		this.oldPwd = oldPwd;
	}

	@Column(name = "NEW_PWD", length = 128)
	public String getNewPwd() {
		return this.newPwd;
	}

	public void setNewPwd(String newPwd) {
		this.newPwd = newPwd;
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

	@Column(name = "NOTE", length = 1024)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "URGENT_FEE", precision = 16, scale = 0)
	public Long getUrgentFee() {
		return this.urgentFee;
	}

	public void setUrgentFee(Long urgentFee) {
		this.urgentFee = urgentFee;
	}

	@Column(name = "COST_FEE", precision = 16, scale = 0)
	public Long getCostFee() {
		return this.costFee;
	}

	public void setCostFee(Long costFee) {
		this.costFee = costFee;
	}

	@Column(name = "RSV_ONE", length = 16)
	public String getRsvOne() {
		return this.rsvOne;
	}

	public void setRsvOne(String rsvOne) {
		this.rsvOne = rsvOne;
	}

	@Column(name = "RSV_TWO", length = 50)
	public String getRsvTwo() {
		return this.rsvTwo;
	}

	public void setRsvTwo(String rsvTwo) {
		this.rsvTwo = rsvTwo;
	}

	@Column(name = "RSV_THREE", length = 16)
	public String getRsvThree() {
		return this.rsvThree;
	}

	public void setRsvThree(String rsvThree) {
		this.rsvThree = rsvThree;
	}

	@Column(name = "RSV_FOUR", length = 16)
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

	@Column(name = "OTHER_FEE", precision = 16, scale = 0)
	public Long getOtherFee() {
		return this.otherFee;
	}

	public void setOtherFee(Long otherFee) {
		this.otherFee = otherFee;
	}

	@Column(name = "ACC_KIND", length = 2)
	public String getAccKind() {
		return accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	@Column(name = "AMT", precision = 16, scale = 0)
	public Long getAmt() {
		return amt;
	}

	public void setAmt(Long amt) {
		this.amt = amt;
	}

	@Column(name = "TERM_ID", length = 16)
	public String getTermId() {
		return termId;
	}

	public void setTermId(String termId) {
		this.termId = termId;
	}

	@Column(name = "CARD_TR_COUNT", length = 16)
	public String getCardTrCount() {
		return cardTrCount;
	}

	public void setCardTrCount(String cardTrCount) {
		this.cardTrCount = cardTrCount;
	}

	@Column(name = "OLD_DEAL_NO", precision = 22, scale = 0)
	public Long getOldDealNo() {
		return oldDealNo;
	}

	public void setOldDealNo(Long oldDealNo) {
		this.oldDealNo = oldDealNo;
	}

	@Column(name = "PRV_BAL", precision = 16, scale = 0)
	public Long getPrvBal() {
		return prvBal;
	}

	public void setPrvBal(Long prv_Bal) {
		this.prvBal = prv_Bal;
	}

	@Column(name = "ORG_ID_IN", length = 16)
	public String getOrgIdIn() {
		return orgIdIn;
	}

	public void setOrgIdIn(String orgIdIn) {
		this.orgIdIn = orgIdIn;
	}

	@Column(name = "BRCH_ID_IN", length = 16)
	public String getBrchIdIn() {
		return brchIdIn;
	}

	public void setBrchIdIn(String brchIdIn) {
		this.brchIdIn = brchIdIn;
	}

	@Column(name = "USER_ID_IN", length = 16)
	public String getUserIdIn() {
		return userIdIn;
	}

	public void setUserIdIn(String userIdIn) {
		this.userIdIn = userIdIn;
	}

	@Column(name = "ORG_ID_OUT", length = 16)
	public String getOrgIdOut() {
		return orgIdOut;
	}

	public void setOrgIdOut(String orgIdOut) {
		this.orgIdOut = orgIdOut;
	}

	@Column(name = "BRCH_ID_OUT", length = 16)
	public String getBrchIdOut() {
		return brchIdOut;
	}

	public void setBrchIdOut(String brchIdOut) {
		this.brchIdOut = brchIdOut;
	}

	@Column(name = "USER_ID_OUT", length = 16)
	public String getUserIdOut() {
		return userIdOut;
	}

	public void setUserIdOut(String userIdOut) {
		this.userIdOut = userIdOut;
	}

	@Column(name = "ORG_ID", length = 16)
	public String getOrgId() {
		return orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}
	
	@Column(name = "co_org_id", length = 128)
	public String getCoOrgId() {
		return coOrgId;
	}

	public void setCoOrgId(String coOrgId) {
		this.coOrgId = coOrgId;
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

    @Column(name = "NUM",precision = 16, scale = 0)
    public Long getNum() {
        return num;
    }

    public void setNum(Long num) {
        this.num = num;
    }
}