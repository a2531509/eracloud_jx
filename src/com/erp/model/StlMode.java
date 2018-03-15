package com.erp.model;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * StlMode entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "STL_MODE")
public class StlMode implements java.io.Serializable {

	// Fields

	private StlModeId id;
	private String stlMode;
	private String stlWay;
	private String stlDays;
	private Long stlLim;
	private String stlWayRet;
	private String stlDaysRet;
	private Long stlLimRet;
	private String stlWayFee;
	private String stlDaysFee;
	private Long stlLimFee;

	// Constructors

	/** default constructor */
	public StlMode() {
	}

	/** minimal constructor */
	public StlMode(StlModeId id) {
		this.id = id;
	}

	/** full constructor */
	public StlMode(StlModeId id, String stlMode, String stlWay, String stlDays,
			Long stlLim, String stlWayRet, String stlDaysRet, Long stlLimRet,
			String stlWayFee, String stlDaysFee, Long stlLimFee) {
		this.id = id;
		this.stlMode = stlMode;
		this.stlWay = stlWay;
		this.stlDays = stlDays;
		this.stlLim = stlLim;
		this.stlWayRet = stlWayRet;
		this.stlDaysRet = stlDaysRet;
		this.stlLimRet = stlLimRet;
		this.stlWayFee = stlWayFee;
		this.stlDaysFee = stlDaysFee;
		this.stlLimFee = stlLimFee;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "merchantId", column = @Column(name = "MERCHANT_ID", nullable = false, length = 16)),
			@AttributeOverride(name = "validDate", column = @Column(name = "VALID_DATE", nullable = false, length = 7)) })
	public StlModeId getId() {
		return this.id;
	}

	public void setId(StlModeId id) {
		this.id = id;
	}

	@Column(name = "STL_MODE", length = 2)
	public String getStlMode() {
		return this.stlMode;
	}

	public void setStlMode(String stlMode) {
		this.stlMode = stlMode;
	}

	@Column(name = "STL_WAY", length = 12)
	public String getStlWay() {
		return this.stlWay;
	}

	public void setStlWay(String stlWay) {
		this.stlWay = stlWay;
	}

	@Column(name = "STL_DAYS", length = 20)
	public String getStlDays() {
		return this.stlDays;
	}

	public void setStlDays(String stlDays) {
		this.stlDays = stlDays;
	}

	@Column(name = "STL_LIM", precision = 16, scale = 0)
	public Long getStlLim() {
		return this.stlLim;
	}

	public void setStlLim(Long stlLim) {
		this.stlLim = stlLim;
	}

	@Column(name = "STL_WAY_RET", length = 12)
	public String getStlWayRet() {
		return this.stlWayRet;
	}

	public void setStlWayRet(String stlWayRet) {
		this.stlWayRet = stlWayRet;
	}

	@Column(name = "STL_DAYS_RET", length = 20)
	public String getStlDaysRet() {
		return this.stlDaysRet;
	}

	public void setStlDaysRet(String stlDaysRet) {
		this.stlDaysRet = stlDaysRet;
	}

	@Column(name = "STL_LIM_RET", precision = 16, scale = 0)
	public Long getStlLimRet() {
		return this.stlLimRet;
	}

	public void setStlLimRet(Long stlLimRet) {
		this.stlLimRet = stlLimRet;
	}

	@Column(name = "STL_WAY_FEE", length = 12)
	public String getStlWayFee() {
		return this.stlWayFee;
	}

	public void setStlWayFee(String stlWayFee) {
		this.stlWayFee = stlWayFee;
	}

	@Column(name = "STL_DAYS_FEE", length = 20)
	public String getStlDaysFee() {
		return this.stlDaysFee;
	}

	public void setStlDaysFee(String stlDaysFee) {
		this.stlDaysFee = stlDaysFee;
	}

	@Column(name = "STL_LIM_FEE", precision = 16, scale = 0)
	public Long getStlLimFee() {
		return this.stlLimFee;
	}

	public void setStlLimFee(Long stlLimFee) {
		this.stlLimFee = stlLimFee;
	}

}