package com.erp.model;

import java.sql.Timestamp;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "BASE_BILL")
public class BaseBill implements java.io.Serializable {

	// Fields

	private String billNo;
	private String billName;
	private String billType;
	private String startNo;
	private String endNo;
	private Long billNum;
	private String amtFlag;
	private Long billAmt;
	private String validityDate;
	private String note;
	private Date operDate;
	private String operId;
	private String orgId;

	// Constructors

	/** default constructor */
	public BaseBill() {
	}

	/** minimal constructor */
	public BaseBill(String billNo) {
		this.billNo = billNo;
	}

	/** full constructor */
	public BaseBill(String billNo, String billName, String billType,
			String startNo, String endNo, Long billNum, String amtFlag,
			Long billAmt, String validityDate, String note,
			Timestamp operDate, String operId, String orgId) {
		this.billNo = billNo;
		this.billName = billName;
		this.billType = billType;
		this.startNo = startNo;
		this.endNo = endNo;
		this.billNum = billNum;
		this.amtFlag = amtFlag;
		this.billAmt = billAmt;
		this.validityDate = validityDate;
		this.note = note;
		this.operDate = operDate;
		this.operId = operId;
		this.orgId = orgId;
	}

	// Property accessors
	@Id
	@Column(name = "BILL_NO", unique = true, nullable = false, length = 20)
	public String getBillNo() {
		return this.billNo;
	}

	public void setBillNo(String billNo) {
		this.billNo = billNo;
	}

	@Column(name = "BILL_NAME", length = 20)
	public String getBillName() {
		return this.billName;
	}

	public void setBillName(String billName) {
		this.billName = billName;
	}

	@Column(name = "BILL_TYPE", length = 2)
	public String getBillType() {
		return this.billType;
	}

	public void setBillType(String billType) {
		this.billType = billType;
	}

	@Column(name = "START_NO", length = 20)
	public String getStartNo() {
		return this.startNo;
	}

	public void setStartNo(String startNo) {
		this.startNo = startNo;
	}

	@Column(name = "END_NO", length = 20)
	public String getEndNo() {
		return this.endNo;
	}

	public void setEndNo(String endNo) {
		this.endNo = endNo;
	}

	@Column(name = "BILL_NUM", precision = 20, scale = 0)
	public Long getBillNum() {
		return this.billNum;
	}

	public void setBillNum(Long billNum) {
		this.billNum = billNum;
	}

	@Column(name = "AMT_FLAG", length = 1)
	public String getAmtFlag() {
		return this.amtFlag;
	}

	public void setAmtFlag(String amtFlag) {
		this.amtFlag = amtFlag;
	}

	@Column(name = "BILL_AMT", precision = 20, scale = 0)
	public Long getBillAmt() {
		return this.billAmt;
	}

	public void setBillAmt(Long billAmt) {
		this.billAmt = billAmt;
	}

	@Column(name = "VALIDITY_DATE", length = 10)
	public String getValidityDate() {
		return this.validityDate;
	}

	public void setValidityDate(String validityDate) {
		this.validityDate = validityDate;
	}

	@Column(name = "NOTE", length = 200)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "OPER_DATE", length = 7)
	public Date getOperDate() {
		return this.operDate;
	}

	public void setOperDate(Timestamp operDate) {
		this.operDate = operDate;
	}

	@Column(name = "OPER_ID", length = 20)
	public String getOperId() {
		return this.operId;
	}

	public void setOperId(String operId) {
		this.operId = operId;
	}

	@Column(name = "ORG_ID", length = 20)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

}