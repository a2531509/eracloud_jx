package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * AccKindConfig entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "ACC_KIND_CONFIG")
public class AccKindConfig implements java.io.Serializable {
	// Fields
	private String accKind;
	private String accName;
	private String accKindState;
	private String openUserId;
	private Date openDate;
	private String stopUserId;
	private Date stopDate;
	private String note;
	private String aloneActivateFlag;
	private Long ordNo;

	// Constructors

	/** default constructor */
	public AccKindConfig() {
	}

	/** minimal constructor */
	public AccKindConfig(String accKind, String accName, String accKindState) {
		this.accKind = accKind;
		this.accName = accName;
		this.accKindState = accKindState;
	}

	/** full constructor */
	public AccKindConfig(String accKind, String accName, String accKindState,
			String openUserId, Date openDate, String stopUserId,
			Date stopDate, String note, String aloneActivateFlag) {
		this.accKind = accKind;
		this.accName = accName;
		this.accKindState = accKindState;
		this.openUserId = openUserId;
		this.openDate = openDate;
		this.stopUserId = stopUserId;
		this.stopDate = stopDate;
		this.note = note;
		this.aloneActivateFlag = aloneActivateFlag;
	}

	// Property accessors
	@Id
	@Column(name = "ACC_KIND", unique = true, nullable = false, length = 2)
	public String getAccKind() {
		return this.accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	@Column(name = "ACC_NAME", nullable = false, length = 50)
	public String getAccName() {
		return this.accName;
	}

	public void setAccName(String accName) {
		this.accName = accName;
	}

	@Column(name = "ACC_KIND_STATE", nullable = false, length = 1)
	public String getAccKindState() {
		return this.accKindState;
	}

	public void setAccKindState(String accKindState) {
		this.accKindState = accKindState;
	}

	@Column(name = "OPEN_USER_ID", length = 20)
	public String getOpenUserId() {
		return this.openUserId;
	}

	public void setOpenUserId(String openUserId) {
		this.openUserId = openUserId;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "OPEN_DATE", length = 7)
	public Date getOpenDate() {
		return this.openDate;
	}

	public void setOpenDate(Date openDate) {
		this.openDate = openDate;
	}

	@Column(name = "STOP_USER_ID", length = 20)
	public String getStopUserId() {
		return this.stopUserId;
	}

	public void setStopUserId(String stopUserId) {
		this.stopUserId = stopUserId;
	}
	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "STOP_DATE", length = 7)
	public Date getStopDate() {
		return this.stopDate;
	}

	public void setStopDate(Date stopDate) {
		this.stopDate = stopDate;
	}

	@Column(name = "NOTE", length = 1000)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "ALONE_ACTIVATE_FLAG", length = 2)
	public String getAloneActivateFlag() {
		return this.aloneActivateFlag;
	}

	public void setAloneActivateFlag(String aloneActivateFlag) {
		this.aloneActivateFlag = aloneActivateFlag;
	}
	@Column(name = "ORD_NO", length = 3)
	public Long getOrdNo() {
		return ordNo;
	}

	public void setOrdNo(Long ordNo) {
		this.ordNo = ordNo;
	}
	
	

}