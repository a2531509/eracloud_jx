package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * BaseComm entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_COMM")
public class BaseComm implements java.io.Serializable {

	// Fields

	private String commId;
	private String commName;
	private String townId;
	private String commState;
	private String lkBrchId;
	private String lkBrchId2;

	// Constructors

	/** default constructor */
	public BaseComm() {
	}

	/** minimal constructor */
	public BaseComm(String commId) {
		this.commId = commId;
	}

	/** full constructor */
	public BaseComm(String commId, String commName, String townId,
			String commState) {
		this.commId = commId;
		this.commName = commName;
		this.townId = townId;
		this.commState = commState;
	}

	// Property accessors
	@Id
	@Column(name = "COMM_ID", unique = true, nullable = false, length = 15)
	public String getCommId() {
		return this.commId;
	}

	public void setCommId(String commId) {
		this.commId = commId;
	}

	@Column(name = "COMM_NAME", length = 32)
	public String getCommName() {
		return this.commName;
	}

	public void setCommName(String commName) {
		this.commName = commName;
	}

	@Column(name = "TOWN_ID", length = 15)
	public String getTownId() {
		return this.townId;
	}

	public void setTownId(String townId) {
		this.townId = townId;
	}

	@Column(name = "COMM_STATE", length = 1)
	public String getCommState() {
		return this.commState;
	}

	public void setCommState(String commState) {
		this.commState = commState;
	}

	@Column(name = "LK_BRCH_ID", length = 20)
	public String getLkBrchId() {
		return lkBrchId;
	}

	public void setLkBrchId(String lkBrchId) {
		this.lkBrchId = lkBrchId;
	}

	/**
	 * @return the lkBrchId2
	 */
	@Column(name = "LK_BRCH_ID2", length = 20)
	public String getLkBrchId2() {
		return lkBrchId2;
	}

	/**
	 * @param lkBrchId2 the lkBrchId2 to set
	 */
	public void setLkBrchId2(String lkBrchId2) {
		this.lkBrchId2 = lkBrchId2;
	}
}