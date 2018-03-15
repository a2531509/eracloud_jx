package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * PayAcctypeSqn entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "PAY_ACCTYPE_SQN")
public class PayAcctypeSqn implements java.io.Serializable {

	// Fields

	private String modeId;
	private String modeName;
	private String accSqn;
	private String reaccType;
	private String reaccTypeBak;
	private String modeState;
	private String note;

	// Constructors

	/** default constructor */
	public PayAcctypeSqn() {
	}

	/** minimal constructor */
	public PayAcctypeSqn(String modeId, String accSqn) {
		this.modeId = modeId;
		this.accSqn = accSqn;
	}

	/** full constructor */
	public PayAcctypeSqn(String modeId, String modeName, String accSqn,
			String reaccType, String reaccTypeBak, String modeState, String note) {
		this.modeId = modeId;
		this.modeName = modeName;
		this.accSqn = accSqn;
		this.reaccType = reaccType;
		this.reaccTypeBak = reaccTypeBak;
		this.modeState = modeState;
		this.note = note;
	}

	// Property accessors
	@Id
	@Column(name = "MODE_ID", unique = true, nullable = false, length = 2)
	public String getModeId() {
		return this.modeId;
	}

	public void setModeId(String modeId) {
		this.modeId = modeId;
	}

	@Column(name = "MODE_NAME", length = 128)
	public String getModeName() {
		return this.modeName;
	}

	public void setModeName(String modeName) {
		this.modeName = modeName;
	}

	@Column(name = "ACC_SQN", nullable = false, length = 128)
	public String getAccSqn() {
		return this.accSqn;
	}

	public void setAccSqn(String accSqn) {
		this.accSqn = accSqn;
	}

	@Column(name = "REACC_TYPE", length = 128)
	public String getReaccType() {
		return this.reaccType;
	}

	public void setReaccType(String reaccType) {
		this.reaccType = reaccType;
	}

	@Column(name = "REACC_TYPE_BAK", length = 2)
	public String getReaccTypeBak() {
		return this.reaccTypeBak;
	}

	public void setReaccTypeBak(String reaccTypeBak) {
		this.reaccTypeBak = reaccTypeBak;
	}

	@Column(name = "MODE_STATE", length = 1)
	public String getModeState() {
		return this.modeState;
	}

	public void setModeState(String modeState) {
		this.modeState = modeState;
	}

	@Column(name = "NOTE", length = 256)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}