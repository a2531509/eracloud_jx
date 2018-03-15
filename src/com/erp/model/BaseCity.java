package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * BaseCity entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_CITY")
public class BaseCity implements java.io.Serializable {

	// Fields

	private String cityId;
	private String cityName;
	private String cityType;
	private String pcityId;
	private String cityDesc;

	// Constructors

	/** default constructor */
	public BaseCity() {
	}

	/** minimal constructor */
	public BaseCity(String cityId) {
		this.cityId = cityId;
	}

	/** full constructor */
	public BaseCity(String cityId, String cityName, String cityType,
			String pcityId, String cityDesc) {
		this.cityId = cityId;
		this.cityName = cityName;
		this.cityType = cityType;
		this.pcityId = pcityId;
		this.cityDesc = cityDesc;
	}

	// Property accessors
	@Id
	@Column(name = "CITY_ID", unique = true, nullable = false, length = 6)
	public String getCityId() {
		return this.cityId;
	}

	public void setCityId(String cityId) {
		this.cityId = cityId;
	}

	@Column(name = "CITY_NAME", length = 50)
	public String getCityName() {
		return this.cityName;
	}

	public void setCityName(String cityName) {
		this.cityName = cityName;
	}

	@Column(name = "CITY_TYPE", length = 1)
	public String getCityType() {
		return this.cityType;
	}

	public void setCityType(String cityType) {
		this.cityType = cityType;
	}

	@Column(name = "PCITY_ID", length = 6)
	public String getPcityId() {
		return this.pcityId;
	}

	public void setPcityId(String pcityId) {
		this.pcityId = pcityId;
	}

	@Column(name = "CITY_DESC", length = 80)
	public String getCityDesc() {
		return this.cityDesc;
	}

	public void setCityDesc(String cityDesc) {
		this.cityDesc = cityDesc;
	}

}