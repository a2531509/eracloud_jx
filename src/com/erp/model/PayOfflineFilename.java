package com.erp.model;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * PayOfflineFilename entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "PAY_OFFLINE_FILENAME")
public class PayOfflineFilename implements java.io.Serializable {

	// Fields

	private String sendFileName;
	private String fileType;
	private Date sendDate;
	private String merchantId;
	private String dealBatchNo;
	private String state;
	private Long confirmNum;
	private Long confirmAmt;
	private Long refuseNum;
	private Long refuseAmt;
	private Long adjustNum;
	private Long adjustAmt;

	// Constructors

	/** default constructor */
	public PayOfflineFilename() {
	}

	/** minimal constructor */
	public PayOfflineFilename(String sendFileName, Date sendDate,
			String merchantId, String dealBatchNo, String state) {
		this.sendFileName = sendFileName;
		this.sendDate = sendDate;
		this.merchantId = merchantId;
		this.dealBatchNo = dealBatchNo;
		this.state = state;
	}

	/** full constructor */
	public PayOfflineFilename(String sendFileName, String fileType,
			Date sendDate, String merchantId, String dealBatchNo, String state,
			Long confirmNum, Long confirmAmt, Long refuseNum, Long refuseAmt,
			Long adjustNum, Long adjustAmt) {
		this.sendFileName = sendFileName;
		this.fileType = fileType;
		this.sendDate = sendDate;
		this.merchantId = merchantId;
		this.dealBatchNo = dealBatchNo;
		this.state = state;
		this.confirmNum = confirmNum;
		this.confirmAmt = confirmAmt;
		this.refuseNum = refuseNum;
		this.refuseAmt = refuseAmt;
		this.adjustNum = adjustNum;
		this.adjustAmt = adjustAmt;
	}

	// Property accessors
	@Id
	@Column(name = "SEND_FILE_NAME", unique = true, nullable = false, length = 64)
	public String getSendFileName() {
		return this.sendFileName;
	}

	public void setSendFileName(String sendFileName) {
		this.sendFileName = sendFileName;
	}

	@Column(name = "FILE_TYPE", length = 4)
	public String getFileType() {
		return this.fileType;
	}

	public void setFileType(String fileType) {
		this.fileType = fileType;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "SEND_DATE", nullable = false)
	public Date getSendDate() {
		return this.sendDate;
	}

	public void setSendDate(Date sendDate) {
		this.sendDate = sendDate;
	}

	@Column(name = "MERCHANT_ID", nullable = false, length = 16)
	public String getMerchantId() {
		return this.merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	@Column(name = "DEAL_BATCH_NO", nullable = false, length = 20)
	public String getDealBatchNo() {
		return this.dealBatchNo;
	}

	public void setDealBatchNo(String dealBatchNo) {
		this.dealBatchNo = dealBatchNo;
	}

	@Column(name = "STATE", nullable = false, length = 1)
	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

	@Column(name = "CONFIRM_NUM", precision = 16, scale = 0)
	public Long getConfirmNum() {
		return this.confirmNum;
	}

	public void setConfirmNum(Long confirmNum) {
		this.confirmNum = confirmNum;
	}

	@Column(name = "CONFIRM_AMT", precision = 16, scale = 0)
	public Long getConfirmAmt() {
		return this.confirmAmt;
	}

	public void setConfirmAmt(Long confirmAmt) {
		this.confirmAmt = confirmAmt;
	}

	@Column(name = "REFUSE_NUM", precision = 16, scale = 0)
	public Long getRefuseNum() {
		return this.refuseNum;
	}

	public void setRefuseNum(Long refuseNum) {
		this.refuseNum = refuseNum;
	}

	@Column(name = "REFUSE_AMT", precision = 16, scale = 0)
	public Long getRefuseAmt() {
		return this.refuseAmt;
	}

	public void setRefuseAmt(Long refuseAmt) {
		this.refuseAmt = refuseAmt;
	}

	@Column(name = "ADJUST_NUM", precision = 16, scale = 0)
	public Long getAdjustNum() {
		return this.adjustNum;
	}

	public void setAdjustNum(Long adjustNum) {
		this.adjustNum = adjustNum;
	}

	@Column(name = "ADJUST_AMT", precision = 16, scale = 0)
	public Long getAdjustAmt() {
		return this.adjustAmt;
	}

	public void setAdjustAmt(Long adjustAmt) {
		this.adjustAmt = adjustAmt;
	}

}