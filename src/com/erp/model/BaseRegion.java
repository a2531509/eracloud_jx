package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * BaseRegion entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_REGION")
public class BaseRegion implements java.io.Serializable {

	// Fields

	private String regionId;
	private String regionName;
	private String cityId;
	private String regionState;
	private String cardFlag;
	private String regionCode;
	private String note;

	// Constructors

	/** default constructor */
	public BaseRegion() {
	}

	/** minimal constructor */
	public BaseRegion(String regionId) {
		this.regionId = regionId;
	}

	/** full constructor */
	public BaseRegion(String regionId, String regionName, String cityId,
			String regionState, String cardFlag, String regionCode, String note) {
		this.regionId = regionId;
		this.regionName = regionName;
		this.cityId = cityId;
		this.regionState = regionState;
		this.cardFlag = cardFlag;
		this.regionCode = regionCode;
		this.note = note;
	}

	// Property accessors
	@Id
	@Column(name = "REGION_ID", unique = true, nullable = false, length = 6)
	public String getRegionId() {
		return this.regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	@Column(name = "REGION_NAME", length = 32)
	public String getRegionName() {
		return this.regionName;
	}

	public void setRegionName(String regionName) {
		this.regionName = regionName;
	}

	@Column(name = "CITY_ID", length = 6)
	public String getCityId() {
		return this.cityId;
	}

	public void setCityId(String cityId) {
		this.cityId = cityId;
	}

	@Column(name = "REGION_STATE", length = 1)
	public String getRegionState() {
		return this.regionState;
	}

	public void setRegionState(String regionState) {
		this.regionState = regionState;
	}

	@Column(name = "CARD_FLAG", length = 1)
	public String getCardFlag() {
		return this.cardFlag;
	}

	public void setCardFlag(String cardFlag) {
		this.cardFlag = cardFlag;
	}

	@Column(name = "REGION_CODE", length = 6)
	public String getRegionCode() {
		return this.regionCode;
	}

	public void setRegionCode(String regionCode) {
		this.regionCode = regionCode;
	}

	@Column(name = "NOTE", length = 32)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}