package com.erp.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * AccFreezeRec entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "ACC_FREEZE_REC")
public class AccFreezeRec implements java.io.Serializable {

	// Fields

	private BigDecimal dealNo;
	private String acptId;
	private String endId;
	private String dealBatchNo;
	private String endDealNo;
	private Timestamp dealDate;
	private Long dealAmt;
	private Long frzAmt;
	private Integer dealCode;
	private String frzType;
	private String accNo;
	private String cardNo;
	private String frzFlag;
	private Long accBal;
	private BigDecimal oldDealNo;
	private Timestamp insertDate;
	private String userId;
	private String recType;
	private String clrDate;
	private String cancelDealBatchNo;
	private String cancelEndDealNo;
	private String cancelReason;
	private String flag;
	private String endSignState;
	private String note;
	private String accKind;

	// Constructors

	/** default constructor */
	public AccFreezeRec() {
	}

	/** minimal constructor */
	public AccFreezeRec(BigDecimal dealNo, Long frzAmt, String accNo,
			String recType) {
		this.dealNo = dealNo;
		this.frzAmt = frzAmt;
		this.accNo = accNo;
		this.recType = recType;
	}

	/** full constructor */
	public AccFreezeRec(BigDecimal dealNo, String acptId, String endId,
			String dealBatchNo, String endDealNo, Timestamp dealDate,
			Long dealAmt, Long frzAmt, Integer dealCode, String frzType,
			String accNo, String cardNo, String frzFlag, Long accBal,
			BigDecimal oldDealNo, Timestamp insertDate, String userId,
			String recType, String clrDate, String cancelDealBatchNo,
			String cancelEndDealNo, String cancelReason, String flag,
			String endSignState, String note, String accKind) {
		this.dealNo = dealNo;
		this.acptId = acptId;
		this.endId = endId;
		this.dealBatchNo = dealBatchNo;
		this.endDealNo = endDealNo;
		this.dealDate = dealDate;
		this.dealAmt = dealAmt;
		this.frzAmt = frzAmt;
		this.dealCode = dealCode;
		this.frzType = frzType;
		this.accNo = accNo;
		this.cardNo = cardNo;
		this.frzFlag = frzFlag;
		this.accBal = accBal;
		this.oldDealNo = oldDealNo;
		this.insertDate = insertDate;
		this.userId = userId;
		this.recType = recType;
		this.clrDate = clrDate;
		this.cancelDealBatchNo = cancelDealBatchNo;
		this.cancelEndDealNo = cancelEndDealNo;
		this.cancelReason = cancelReason;
		this.flag = flag;
		this.endSignState = endSignState;
		this.note = note;
		this.accKind = accKind;
	}

	// Property accessors
	@Id
	@Column(name = "DEAL_NO", unique = true, nullable = false, precision = 38, scale = 0)
	public BigDecimal getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(BigDecimal dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "ACPT_ID", length = 20)
	public String getAcptId() {
		return this.acptId;
	}

	public void setAcptId(String acptId) {
		this.acptId = acptId;
	}

	@Column(name = "END_ID", length = 12)
	public String getEndId() {
		return this.endId;
	}

	public void setEndId(String endId) {
		this.endId = endId;
	}

	@Column(name = "DEAL_BATCH_NO", length = 20)
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

	@Column(name = "DEAL_DATE", length = 7)
	public Timestamp getDealDate() {
		return this.dealDate;
	}

	public void setDealDate(Timestamp dealDate) {
		this.dealDate = dealDate;
	}

	@Column(name = "DEAL_AMT", precision = 16, scale = 0)
	public Long getDealAmt() {
		return this.dealAmt;
	}

	public void setDealAmt(Long dealAmt) {
		this.dealAmt = dealAmt;
	}

	@Column(name = "FRZ_AMT", nullable = false, precision = 16, scale = 0)
	public Long getFrzAmt() {
		return this.frzAmt;
	}

	public void setFrzAmt(Long frzAmt) {
		this.frzAmt = frzAmt;
	}

	@Column(name = "DEAL_CODE", precision = 8, scale = 0)
	public Integer getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(Integer dealCode) {
		this.dealCode = dealCode;
	}

	@Column(name = "FRZ_TYPE", length = 2)
	public String getFrzType() {
		return this.frzType;
	}

	public void setFrzType(String frzType) {
		this.frzType = frzType;
	}

	@Column(name = "ACC_NO", nullable = false, length = 20)
	public String getAccNo() {
		return this.accNo;
	}

	public void setAccNo(String accNo) {
		this.accNo = accNo;
	}

	@Column(name = "CARD_NO", length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "FRZ_FLAG", length = 1)
	public String getFrzFlag() {
		return this.frzFlag;
	}

	public void setFrzFlag(String frzFlag) {
		this.frzFlag = frzFlag;
	}

	@Column(name = "ACC_BAL", precision = 16, scale = 0)
	public Long getAccBal() {
		return this.accBal;
	}

	public void setAccBal(Long accBal) {
		this.accBal = accBal;
	}

	@Column(name = "OLD_DEAL_NO", precision = 38, scale = 0)
	public BigDecimal getOldDealNo() {
		return this.oldDealNo;
	}

	public void setOldDealNo(BigDecimal oldDealNo) {
		this.oldDealNo = oldDealNo;
	}

	@Column(name = "INSERT_DATE", length = 7)
	public Timestamp getInsertDate() {
		return this.insertDate;
	}

	public void setInsertDate(Timestamp insertDate) {
		this.insertDate = insertDate;
	}

	@Column(name = "USER_ID", length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "REC_TYPE", nullable = false, length = 1)
	public String getRecType() {
		return this.recType;
	}

	public void setRecType(String recType) {
		this.recType = recType;
	}

	@Column(name = "CLR_DATE", length = 10)
	public String getClrDate() {
		return this.clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	@Column(name = "CANCEL_DEAL_BATCH_NO", length = 20)
	public String getCancelDealBatchNo() {
		return this.cancelDealBatchNo;
	}

	public void setCancelDealBatchNo(String cancelDealBatchNo) {
		this.cancelDealBatchNo = cancelDealBatchNo;
	}

	@Column(name = "CANCEL_END_DEAL_NO", length = 20)
	public String getCancelEndDealNo() {
		return this.cancelEndDealNo;
	}

	public void setCancelEndDealNo(String cancelEndDealNo) {
		this.cancelEndDealNo = cancelEndDealNo;
	}

	@Column(name = "CANCEL_REASON", length = 2)
	public String getCancelReason() {
		return this.cancelReason;
	}

	public void setCancelReason(String cancelReason) {
		this.cancelReason = cancelReason;
	}

	@Column(name = "FLAG", length = 1)
	public String getFlag() {
		return this.flag;
	}

	public void setFlag(String flag) {
		this.flag = flag;
	}

	@Column(name = "END_SIGN_STATE", length = 1)
	public String getEndSignState() {
		return this.endSignState;
	}

	public void setEndSignState(String endSignState) {
		this.endSignState = endSignState;
	}

	@Column(name = "NOTE", length = 32)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "ACC_KIND", length = 2)
	public String getAccKind() {
		return this.accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

}