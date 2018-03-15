package com.erp.model;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * PayOffline entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "PAY_OFFLINE")
public class PayOffline implements java.io.Serializable {

	// Fields

	private Long dealNo;
	private String endDealNo;
	private String acptId;
	private String endId;
	private String cardNo;
	private String cardInType;
	private String cardInSubtype;
	private String cardValidDate;
	private String cardStartDate;
	private String appValidDate;
	private Long cardDealCount;
	private Long psamDealNo;
	private Long accBal;
	private Long dealAmt;
	private String dealDate;
	private String dealKind;
	private String psamNo;
	private String tac;
	private String ashFlag;
	private Long creditLimit;
	private String dealBatchNo;
	private String sendFileName;
	private Long fileLineNo;
	private Date sendDate;
	private Integer dealCode;
	private String dealState;
	private String clrDate;
	private String refuseReason;
	private String orgId;
	private Long cancelTrBatchId;
	private String cancelTermSerNo;
	private Long points;
	private String processingState;

	// Constructors

	/** default constructor */
	public PayOffline() {
	}

	/** minimal constructor */
	public PayOffline(Long dealNo, String endDealNo, String acptId,
			String endId, String cardNo, Long dealAmt, String dealBatchNo,
			String dealState,String processingState) {
		this.dealNo = dealNo;
		this.endDealNo = endDealNo;
		this.acptId = acptId;
		this.endId = endId;
		this.cardNo = cardNo;
		this.dealAmt = dealAmt;
		this.dealBatchNo = dealBatchNo;
		this.dealState = dealState;
		this.processingState = processingState;
	}

	/** full constructor */
	public PayOffline(Long dealNo, String endDealNo, String acptId,
			String endId, String cardNo, String cardInType,
			String cardInSubtype, String cardValidDate, String cardStartDate,
			String appValidDate, Long cardDealCount,
			Long psamDealNo, Long accBal, Long dealAmt, String dealDate,
			String dealKind, String psamNo, String tac, String ashFlag,
			Long creditLimit, String dealBatchNo, String sendFileName,
			Long fileLineNo, Date sendDate, Integer dealCode,
			String dealState, String clrDate, String refuseReason,
			String orgId, Long cancelTrBatchId, String cancelTermSerNo,
			Long points,String processingState) {
		this.dealNo = dealNo;
		this.endDealNo = endDealNo;
		this.acptId = acptId;
		this.endId = endId;
		this.cardNo = cardNo;
		this.cardInType = cardInType;
		this.cardInSubtype = cardInSubtype;
		this.cardValidDate = cardValidDate;
		this.cardStartDate = cardStartDate;
		this.appValidDate = appValidDate;
		this.cardDealCount = cardDealCount;
		this.psamDealNo = psamDealNo;
		this.accBal = accBal;
		this.dealAmt = dealAmt;
		this.dealDate = dealDate;
		this.dealKind = dealKind;
		this.psamNo = psamNo;
		this.tac = tac;
		this.ashFlag = ashFlag;
		this.creditLimit = creditLimit;
		this.dealBatchNo = dealBatchNo;
		this.sendFileName = sendFileName;
		this.fileLineNo = fileLineNo;
		this.sendDate = sendDate;
		this.dealCode = dealCode;
		this.dealState = dealState;
		this.clrDate = clrDate;
		this.refuseReason = refuseReason;
		this.orgId = orgId;
		this.cancelTrBatchId = cancelTrBatchId;
		this.cancelTermSerNo = cancelTermSerNo;
		this.points = points;
		this.processingState = processingState;
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
	@Column(name = "PROCESSING_STATE", length = 2)
	public String getProcessingState() {
		return processingState;
	}

	public void setProcessingState(String processingState) {
		this.processingState = processingState;
	}

	@Column(name = "END_DEAL_NO", nullable = false, length = 20)
	public String getEndDealNo() {
		return this.endDealNo;
	}

	public void setEndDealNo(String endDealNo) {
		this.endDealNo = endDealNo;
	}

	@Column(name = "ACPT_ID", nullable = false, length = 20)
	public String getAcptId() {
		return this.acptId;
	}

	public void setAcptId(String acptId) {
		this.acptId = acptId;
	}

	@Column(name = "END_ID", nullable = false, length = 10)
	public String getEndId() {
		return this.endId;
	}

	public void setEndId(String endId) {
		this.endId = endId;
	}

	@Column(name = "CARD_NO", nullable = false, length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "CARD_IN_TYPE", length = 3)
	public String getCardInType() {
		return this.cardInType;
	}

	public void setCardInType(String cardInType) {
		this.cardInType = cardInType;
	}

	@Column(name = "CARD_IN_SUBTYPE", length = 3)
	public String getCardInSubtype() {
		return this.cardInSubtype;
	}

	public void setCardInSubtype(String cardInSubtype) {
		this.cardInSubtype = cardInSubtype;
	}

	@Column(name = "CARD_VALID_DATE", length = 10)
	public String getCardValidDate() {
		return this.cardValidDate;
	}

	public void setCardValidDate(String cardValidDate) {
		this.cardValidDate = cardValidDate;
	}

	@Column(name = "CARD_START_DATE", length = 10)
	public String getCardStartDate() {
		return this.cardStartDate;
	}

	public void setCardStartDate(String cardStartDate) {
		this.cardStartDate = cardStartDate;
	}

	@Column(name = "APP_VALID_DATE", length = 10)
	public String getAppValidDate() {
		return this.appValidDate;
	}

	public void setAppValidDate(String appValidDate) {
		this.appValidDate = appValidDate;
	}

	@Column(name = "CARD_DEAL_COUNT", precision = 22, scale = 0)
	public Long getCardDealCount() {
		return this.cardDealCount;
	}

	public void setCardDealCount(Long cardDealCount) {
		this.cardDealCount = cardDealCount;
	}

	@Column(name = "PSAM_DEAL_NO", precision = 22, scale = 0)
	public Long getPsamDealNo() {
		return this.psamDealNo;
	}

	public void setPsamDealNo(Long psamDealNo) {
		this.psamDealNo = psamDealNo;
	}

	@Column(name = "ACC_BAL", precision = 16, scale = 0)
	public Long getAccBal() {
		return this.accBal;
	}

	public void setAccBal(Long accBal) {
		this.accBal = accBal;
	}

	@Column(name = "DEAL_AMT", nullable = false, precision = 16, scale = 0)
	public Long getDealAmt() {
		return this.dealAmt;
	}

	public void setDealAmt(Long dealAmt) {
		this.dealAmt = dealAmt;
	}

	@Column(name = "DEAL_DATE", length = 14)
	public String getDealDate() {
		return this.dealDate;
	}

	public void setDealDate(String dealDate) {
		this.dealDate = dealDate;
	}

	@Column(name = "DEAL_KIND", length = 2)
	public String getDealKind() {
		return this.dealKind;
	}

	public void setDealKind(String dealKind) {
		this.dealKind = dealKind;
	}

	@Column(name = "PSAM_NO", length = 20)
	public String getPsamNo() {
		return this.psamNo;
	}

	public void setPsamNo(String psamNo) {
		this.psamNo = psamNo;
	}

	@Column(name = "TAC", length = 10)
	public String getTac() {
		return this.tac;
	}

	public void setTac(String tac) {
		this.tac = tac;
	}

	@Column(name = "ASH_FLAG", length = 2)
	public String getAshFlag() {
		return this.ashFlag;
	}

	public void setAshFlag(String ashFlag) {
		this.ashFlag = ashFlag;
	}

	@Column(name = "CREDIT_LIMIT", precision = 16, scale = 0)
	public Long getCreditLimit() {
		return this.creditLimit;
	}

	public void setCreditLimit(Long creditLimit) {
		this.creditLimit = creditLimit;
	}

	@Column(name = "DEAL_BATCH_NO", nullable = false, length = 20)
	public String getDealBatchNo() {
		return this.dealBatchNo;
	}

	public void setDealBatchNo(String dealBatchNo) {
		this.dealBatchNo = dealBatchNo;
	}

	@Column(name = "SEND_FILE_NAME", length = 64)
	public String getSendFileName() {
		return this.sendFileName;
	}

	public void setSendFileName(String sendFileName) {
		this.sendFileName = sendFileName;
	}

	@Column(name = "FILE_LINE_NO", precision = 22, scale = 0)
	public Long getFileLineNo() {
		return this.fileLineNo;
	}

	public void setFileLineNo(Long fileLineNo) {
		this.fileLineNo = fileLineNo;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "SEND_DATE", length = 7)
	public Date getSendDate() {
		return this.sendDate;
	}

	public void setSendDate(Date sendDate) {
		this.sendDate = sendDate;
	}

	@Column(name = "DEAL_CODE", precision = 6, scale = 0)
	public Integer getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(Integer dealCode) {
		this.dealCode = dealCode;
	}

	@Column(name = "DEAL_STATE", nullable = false, length = 1)
	public String getDealState() {
		return this.dealState;
	}

	public void setDealState(String dealState) {
		this.dealState = dealState;
	}

	@Column(name = "CLR_DATE", length = 10)
	public String getClrDate() {
		return this.clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	@Column(name = "REFUSE_REASON", length = 2)
	public String getRefuseReason() {
		return this.refuseReason;
	}

	public void setRefuseReason(String refuseReason) {
		this.refuseReason = refuseReason;
	}

	@Column(name = "ORG_ID", length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "CANCEL_DEAL_BATCH_ID", precision = 22, scale = 0)
	public Long getCancelTrBatchId() {
		return this.cancelTrBatchId;
	}

	public void setCancelTrBatchId(Long cancelTrBatchId) {
		this.cancelTrBatchId = cancelTrBatchId;
	}

	@Column(name = "CANCEL_END_DEAL_NO", length = 20)
	public String getCancelTermSerNo() {
		return this.cancelTermSerNo;
	}

	public void setCancelTermSerNo(String cancelTermSerNo) {
		this.cancelTermSerNo = cancelTermSerNo;
	}

	@Column(name = "POINTS", precision = 22, scale = 0)
	public Long getPoints() {
		return this.points;
	}

	public void setPoints(Long points) {
		this.points = points;
	}

}