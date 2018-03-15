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
 * StlReceiptReg entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "STL_RECEIPT_REG")
@SequenceGenerator(name="SEQ_StlReceiptReg",allocationSize=1,initialValue=1,sequenceName="seq_remit_book_no" )
public class StlReceiptReg implements java.io.Serializable {

	// Fields

	private Integer regNo;
	private String note;
	private String orgId;
	private String merchantId;
	private Long stlAmt;
	private Date payDate;
	private String payUserId;
	private String payBankId;
	private String payAccName;
	private String payAccNo;
	private String rcvBankId;
	private String rcvAccName;
	private String rcvAccNo;
	private Long vrfAmt;
	private Date vrfDate;
	private String vrfUserId;
	private String errMsg;
	private String payState;
	private String bankSheetNo;

	// Constructors

	/** default constructor */
	public StlReceiptReg() {
	}

	/** minimal constructor */
	public StlReceiptReg(Integer regNo) {
		this.regNo = regNo;
	}

	/** full constructor */
	public StlReceiptReg(Integer regNo, String note, String orgId,
			String merchantId, Long stlAmt, Date payDate, String payUserId,
			String payBankId, String payAccName, String payAccNo,
			String rcvBankId, String rcvAccName, String rcvAccNo, Long vrfAmt,
			Date vrfDate, String vrfUserId, String errMsg, String payState,
			String bankSheetNo) {
		this.regNo = regNo;
		this.note = note;
		this.orgId = orgId;
		this.merchantId = merchantId;
		this.stlAmt = stlAmt;
		this.payDate = payDate;
		this.payUserId = payUserId;
		this.payBankId = payBankId;
		this.payAccName = payAccName;
		this.payAccNo = payAccNo;
		this.rcvBankId = rcvBankId;
		this.rcvAccName = rcvAccName;
		this.rcvAccNo = rcvAccNo;
		this.vrfAmt = vrfAmt;
		this.vrfDate = vrfDate;
		this.vrfUserId = vrfUserId;
		this.errMsg = errMsg;
		this.payState = payState;
		this.bankSheetNo = bankSheetNo;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_StlReceiptReg")
	@Column(name = "REG_NO", unique = true, nullable = false, precision = 22, scale = 0)
	public Integer getRegNo() {
		return this.regNo;
	}

	public void setRegNo(Integer regNo) {
		this.regNo = regNo;
	}

	@Column(name = "NOTE", length = 128)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "ORG_ID", length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "MERCHANT_ID", length = 16)
	public String getMerchantId() {
		return this.merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	@Column(name = "STL_AMT", precision = 16, scale = 0)
	public Long getStlAmt() {
		return this.stlAmt;
	}

	public void setStlAmt(Long stlAmt) {
		this.stlAmt = stlAmt;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "PAY_DATE", length = 7)
	public Date getPayDate() {
		return this.payDate;
	}

	public void setPayDate(Date payDate) {
		this.payDate = payDate;
	}

	@Column(name = "PAY_USER_ID", length = 10)
	public String getPayUserId() {
		return this.payUserId;
	}

	public void setPayUserId(String payUserId) {
		this.payUserId = payUserId;
	}

	@Column(name = "PAY_BANK_ID", length = 4)
	public String getPayBankId() {
		return this.payBankId;
	}

	public void setPayBankId(String payBankId) {
		this.payBankId = payBankId;
	}

	@Column(name = "PAY_ACC_NAME", length = 64)
	public String getPayAccName() {
		return this.payAccName;
	}

	public void setPayAccName(String payAccName) {
		this.payAccName = payAccName;
	}

	@Column(name = "PAY_ACC_NO", length = 64)
	public String getPayAccNo() {
		return this.payAccNo;
	}

	public void setPayAccNo(String payAccNo) {
		this.payAccNo = payAccNo;
	}

	@Column(name = "RCV_BANK_ID", length = 4)
	public String getRcvBankId() {
		return this.rcvBankId;
	}

	public void setRcvBankId(String rcvBankId) {
		this.rcvBankId = rcvBankId;
	}

	@Column(name = "RCV_ACC_NAME", length = 64)
	public String getRcvAccName() {
		return this.rcvAccName;
	}

	public void setRcvAccName(String rcvAccName) {
		this.rcvAccName = rcvAccName;
	}

	@Column(name = "RCV_ACC_NO", length = 64)
	public String getRcvAccNo() {
		return this.rcvAccNo;
	}

	public void setRcvAccNo(String rcvAccNo) {
		this.rcvAccNo = rcvAccNo;
	}

	@Column(name = "VRF_AMT", precision = 16, scale = 0)
	public Long getVrfAmt() {
		return this.vrfAmt;
	}

	public void setVrfAmt(Long vrfAmt) {
		this.vrfAmt = vrfAmt;
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

	@Column(name = "ERR_MSG", length = 128)
	public String getErrMsg() {
		return this.errMsg;
	}

	public void setErrMsg(String errMsg) {
		this.errMsg = errMsg;
	}

	@Column(name = "PAY_STATE", length = 1)
	public String getPayState() {
		return this.payState;
	}

	public void setPayState(String payState) {
		this.payState = payState;
	}

	@Column(name = "BANK_SHEET_NO", length = 32)
	public String getBankSheetNo() {
		return this.bankSheetNo;
	}

	public void setBankSheetNo(String bankSheetNo) {
		this.bankSheetNo = bankSheetNo;
	}

}