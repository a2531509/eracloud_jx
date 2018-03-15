package com.erp.model;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * StockType entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "STOCK_TYPE")
public class StockType implements java.io.Serializable {

	// Fields

	private String stkCode;
	private String orgId;
	private String stkType;
	private String stkName;
	private String lstFlag;
	private String outFlag;
	private Date openDate;
	private String openUserId;
	private Date clsDate;
	private String clsUserId;
	private String stkCodeState;
	private String note;

	// Constructors

	/** default constructor */
	public StockType() {
	}

	/** minimal constructor */
	public StockType(String stkCode) {
		this.stkCode = stkCode;
	}

	/** full constructor */
	public StockType(String stkCode, String orgId, String stkType,
			String stkName, String lstFlag, String outFlag, Date openDate,
			String openUserId, Date clsDate, String clsUserId,
			String stkCodeState, String note) {
		this.stkCode = stkCode;
		this.orgId = orgId;
		this.stkType = stkType;
		this.stkName = stkName;
		this.lstFlag = lstFlag;
		this.outFlag = outFlag;
		this.openDate = openDate;
		this.openUserId = openUserId;
		this.clsDate = clsDate;
		this.clsUserId = clsUserId;
		this.stkCodeState = stkCodeState;
		this.note = note;
	}

	// Property accessors
	@Id
	@Column(name = "STK_CODE", unique = true, nullable = false, length = 4)
	public String getStkCode() {
		return this.stkCode;
	}

	public void setStkCode(String stkCode) {
		this.stkCode = stkCode;
	}

	@Column(name = "ORG_ID", length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "STK_TYPE", length = 1)
	public String getStkType() {
		return this.stkType;
	}

	public void setStkType(String stkType) {
		this.stkType = stkType;
	}

	@Column(name = "STK_NAME", length = 32)
	public String getStkName() {
		return this.stkName;
	}

	public void setStkName(String stkName) {
		this.stkName = stkName;
	}

	@Column(name = "LST_FLAG", length = 1)
	public String getLstFlag() {
		return this.lstFlag;
	}

	public void setLstFlag(String lstFlag) {
		this.lstFlag = lstFlag;
	}

	@Column(name = "OUT_FLAG", length = 1)
	public String getOutFlag() {
		return this.outFlag;
	}

	public void setOutFlag(String outFlag) {
		this.outFlag = outFlag;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "OPEN_DATE", length = 7)
	public Date getOpenDate() {
		return this.openDate;
	}

	public void setOpenDate(Date openDate) {
		this.openDate = openDate;
	}

	@Column(name = "OPEN_USER_ID", length = 10)
	public String getOpenUserId() {
		return this.openUserId;
	}

	public void setOpenUserId(String openUserId) {
		this.openUserId = openUserId;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "CLS_DATE", length = 7)
	public Date getClsDate() {
		return this.clsDate;
	}

	public void setClsDate(Date clsDate) {
		this.clsDate = clsDate;
	}

	@Column(name = "CLS_USER_ID", length = 10)
	public String getClsUserId() {
		return this.clsUserId;
	}

	public void setClsUserId(String clsUserId) {
		this.clsUserId = clsUserId;
	}

	@Column(name = "STK_CODE_STATE", length = 1)
	public String getStkCodeState() {
		return this.stkCodeState;
	}

	public void setStkCodeState(String stkCodeState) {
		this.stkCodeState = stkCodeState;
	}

	@Column(name = "NOTE", length = 64)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}