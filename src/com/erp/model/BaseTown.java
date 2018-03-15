package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * BaseTown entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_TOWN")
public class BaseTown implements java.io.Serializable {

	// Fields

	private String townId;
	private String townName;
	private String regionId;
	private String townState;

	// Constructors

	/** default constructor */
	public BaseTown() {
	}

	/** minimal constructor */
	public BaseTown(String townId) {
		this.townId = townId;
	}

	/** full constructor */
	public BaseTown(String townId, String townName, String regionId,
			String townState) {
		this.townId = townId;
		this.townName = townName;
		this.regionId = regionId;
		this.townState = townState;
	}

	// Property accessors
	@Id
	@Column(name = "TOWN_ID", unique = true, nullable = false, length = 15)
	public String getTownId() {
		return this.townId;
	}

	public void setTownId(String townId) {
		this.townId = townId;
	}

	@Column(name = "TOWN_NAME", length = 32)
	public String getTownName() {
		return this.townName;
	}

	public void setTownName(String townName) {
		this.townName = townName;
	}

	@Column(name = "REGION_ID", length = 6)
	public String getRegionId() {
		return this.regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	@Column(name = "TOWN_STATE", length = 1)
	public String getTownState() {
		return this.townState;
	}

	public void setTownState(String townState) {
		this.townState = townState;
	}

}