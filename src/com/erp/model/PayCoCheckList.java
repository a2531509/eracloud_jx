package com.erp.model;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * PayCoCheckList entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "PAY_CO_CHECK_LIST")
public class PayCoCheckList implements java.io.Serializable {

	// Fields

	private Long id;
	private Long fileid;
	private Long fileLineNo;
	private String orgId;
	private String coOrgId;
	private String acptId;
	private String endId;
	private String dealBatchNo;
	private String endDealNo;
	private String bankId;
	private String bankAcc;
	private String cardNo;
	private String accKind;
	private String mobileNo;
	private String cardNo2;
	private String accKind2;
	private Long amt;
	private Long amtbef;
	private Long purseserial;
	private Long oldActionNo;
	private String state;
	private String operState;
	private String userId;
	private String bz;
	private Long dealNo;
	private String operType;
	private Date dealDate;
	private String dealUserId;
	private String dealIp;
	private String clrDate;
	private String coClrDate;
	private Date operDate;
	private Integer dealCode;

	// Constructors

	/** default constructor */
	public PayCoCheckList() {
	}

	/** minimal constructor */
	public PayCoCheckList(Long id, Long fileid,
			Long fileLineNo, String orgId, String coOrgId, String acptId) {
		this.id = id;
		this.fileid = fileid;
		this.fileLineNo = fileLineNo;
		this.orgId = orgId;
		this.coOrgId = coOrgId;
		this.acptId = acptId;
	}

	/** full constructor */
	public PayCoCheckList(Long id, Long fileid,
			Long fileLineNo, String orgId, String coOrgId, String acptId,
			String endId, String dealBatchNo, String endDealNo, String bankId,
			String bankAcc, String cardNo, String accKind, String mobileNo,
			String cardNo2, String accKind2, Long amt, Long amtbef,
			Long purseserial, Long oldActionNo, String state,
			String operState, String userId, String bz, Long dealNo,
			String operType, Date dealDate, String dealUserId, String dealIp,
			String clrDate, String coClrDate, Date operDate, Integer dealCode) {
		this.id = id;
		this.fileid = fileid;
		this.fileLineNo = fileLineNo;
		this.orgId = orgId;
		this.coOrgId = coOrgId;
		this.acptId = acptId;
		this.endId = endId;
		this.dealBatchNo = dealBatchNo;
		this.endDealNo = endDealNo;
		this.bankId = bankId;
		this.bankAcc = bankAcc;
		this.cardNo = cardNo;
		this.accKind = accKind;
		this.mobileNo = mobileNo;
		this.cardNo2 = cardNo2;
		this.accKind2 = accKind2;
		this.amt = amt;
		this.amtbef = amtbef;
		this.purseserial = purseserial;
		this.oldActionNo = oldActionNo;
		this.state = state;
		this.operState = operState;
		this.userId = userId;
		this.bz = bz;
		this.dealNo = dealNo;
		this.operType = operType;
		this.dealDate = dealDate;
		this.dealUserId = dealUserId;
		this.dealIp = dealIp;
		this.clrDate = clrDate;
		this.coClrDate = coClrDate;
		this.operDate = operDate;
		this.dealCode = dealCode;
	}

	// Property accessors
	@Id
	@Column(name = "ID", unique = true, nullable = false, precision = 38, scale = 0)
	public Long getId() {
		return this.id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Column(name = "FILEID", nullable = false, precision = 38, scale = 0)
	public Long getFileid() {
		return this.fileid;
	}

	public void setFileid(Long fileid) {
		this.fileid = fileid;
	}

	@Column(name = "FILE_LINE_NO", nullable = false, precision = 38, scale = 0)
	public Long getFileLineNo() {
		return this.fileLineNo;
	}

	public void setFileLineNo(Long fileLineNo) {
		this.fileLineNo = fileLineNo;
	}

	@Column(name = "ORG_ID", nullable = false, length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "CO_ORG_ID", nullable = false, length = 15)
	public String getCoOrgId() {
		return this.coOrgId;
	}

	public void setCoOrgId(String coOrgId) {
		this.coOrgId = coOrgId;
	}

	@Column(name = "ACPT_ID", nullable = false, length = 15)
	public String getAcptId() {
		return this.acptId;
	}

	public void setAcptId(String acptId) {
		this.acptId = acptId;
	}

	@Column(name = "END_ID", length = 8)
	public String getEndId() {
		return this.endId;
	}

	public void setEndId(String endId) {
		this.endId = endId;
	}

	@Column(name = "DEAL_BATCH_NO", length = 10)
	public String getDealBatchNo() {
		return this.dealBatchNo;
	}

	public void setDealBatchNo(String dealBatchNo) {
		this.dealBatchNo = dealBatchNo;
	}

	@Column(name = "END_DEAL_NO", length = 20)
	public String getEndDealNo() {
		return this.endDealNo;
	}

	public void setEndDealNo(String endDealNo) {
		this.endDealNo = endDealNo;
	}

	@Column(name = "BANK_ID", length = 40)
	public String getBankId() {
		return this.bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	@Column(name = "BANK_ACC", length = 64)
	public String getBankAcc() {
		return this.bankAcc;
	}

	public void setBankAcc(String bankAcc) {
		this.bankAcc = bankAcc;
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

	@Column(name = "MOBILE_NO", length = 11)
	public String getMobileNo() {
		return this.mobileNo;
	}

	public void setMobileNo(String mobileNo) {
		this.mobileNo = mobileNo;
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

	@Column(name = "AMT", precision = 16, scale = 0)
	public Long getAmt() {
		return this.amt;
	}

	public void setAmt(Long amt) {
		this.amt = amt;
	}

	@Column(name = "AMTBEF", precision = 16, scale = 0)
	public Long getAmtbef() {
		return this.amtbef;
	}

	public void setAmtbef(Long amtbef) {
		this.amtbef = amtbef;
	}

	@Column(name = "PURSESERIAL", precision = 38, scale = 0)
	public Long getPurseserial() {
		return this.purseserial;
	}

	public void setPurseserial(Long purseserial) {
		this.purseserial = purseserial;
	}

	@Column(name = "OLD_ACTION_NO", precision = 38, scale = 0)
	public Long getOldActionNo() {
		return this.oldActionNo;
	}

	public void setOldActionNo(Long oldActionNo) {
		this.oldActionNo = oldActionNo;
	}

	@Column(name = "STATE", length = 1)
	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

	@Column(name = "OPER_STATE", length = 1)
	public String getOperState() {
		return this.operState;
	}

	public void setOperState(String operState) {
		this.operState = operState;
	}

	@Column(name = "USER_ID", length = 8)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "BZ", length = 100)
	public String getBz() {
		return this.bz;
	}

	public void setBz(String bz) {
		this.bz = bz;
	}

	@Column(name = "DEAL_NO", precision = 38, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "OPER_TYPE", length = 32)
	public String getOperType() {
		return this.operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "DEAL_DATE", length = 7)
	public Date getDealDate() {
		return this.dealDate;
	}

	public void setDealDate(Date dealDate) {
		this.dealDate = dealDate;
	}

	@Column(name = "DEAL_USER_ID", length = 20)
	public String getDealUserId() {
		return this.dealUserId;
	}

	public void setDealUserId(String dealUserId) {
		this.dealUserId = dealUserId;
	}

	@Column(name = "DEAL_IP", length = 40)
	public String getDealIp() {
		return this.dealIp;
	}

	public void setDealIp(String dealIp) {
		this.dealIp = dealIp;
	}

	@Column(name = "CLR_DATE", length = 14)
	public String getClrDate() {
		return this.clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	@Column(name = "CO_CLR_DATE", length = 14)
	public String getCoClrDate() {
		return this.coClrDate;
	}

	public void setCoClrDate(String coClrDate) {
		this.coClrDate = coClrDate;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "OPER_DATE", length = 7)
	public Date getOperDate() {
		return this.operDate;
	}

	public void setOperDate(Date operDate) {
		this.operDate = operDate;
	}

	@Column(name = "DEAL_CODE", precision = 8, scale = 0)
	public Integer getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(Integer dealCode) {
		this.dealCode = dealCode;
	}

}