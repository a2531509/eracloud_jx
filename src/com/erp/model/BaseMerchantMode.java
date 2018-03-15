package com.erp.model;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * BaseMerchantMode entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_MERCHANT_MODE")
public class BaseMerchantMode implements java.io.Serializable {

	// Fields

	private BaseMerchantModeId id;
	private String note;
	private String modeState;

	// Constructors

	/** default constructor */
	public BaseMerchantMode() {
	}

	/** minimal constructor */
	public BaseMerchantMode(BaseMerchantModeId id) {
		this.id = id;
	}

	/** full constructor */
	public BaseMerchantMode(BaseMerchantModeId id, String note) {
		this.id = id;
		this.note = note;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "merchantId", column = @Column(name = "MERCHANT_ID", nullable = false, length = 20)),
			@AttributeOverride(name = "modeId", column = @Column(name = "MODE_ID", nullable = false, length = 20)),
			@AttributeOverride(name = "modeType", column = @Column(name = "MODE_TYPE", nullable = false, length = 1)) })
	public BaseMerchantModeId getId() {
		return this.id;
	}

	public void setId(BaseMerchantModeId id) {
		this.id = id;
	}

	@Column(name = "NOTE", length = 2000)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "MODE_STATE", length = 1)
	public String getModeState() {
		return modeState;
	}

	public void setModeState(String modeState) {
		this.modeState = modeState;
	}

	
}