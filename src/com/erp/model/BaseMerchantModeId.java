package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * BaseMerchantModeId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class BaseMerchantModeId implements java.io.Serializable {

	// Fields

	private String merchantId;
	private String modeId;
	private String modeType;

	// Constructors

	/** default constructor */
	public BaseMerchantModeId() {
	}

	/** full constructor */
	public BaseMerchantModeId(String merchantId, String modeId, String modeType) {
		this.merchantId = merchantId;
		this.modeId = modeId;
		this.modeType = modeType;
	}

	// Property accessors

	@Column(name = "MERCHANT_ID", nullable = false, length = 20)
	public String getMerchantId() {
		return this.merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	@Column(name = "MODE_ID", nullable = false, length = 20)
	public String getModeId() {
		return this.modeId;
	}

	public void setModeId(String modeId) {
		this.modeId = modeId;
	}

	@Column(name = "MODE_TYPE", nullable = false, length = 1)
	public String getModeType() {
		return this.modeType;
	}

	public void setModeType(String modeType) {
		this.modeType = modeType;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof BaseMerchantModeId))
			return false;
		BaseMerchantModeId castOther = (BaseMerchantModeId) other;

		return ((this.getMerchantId() == castOther.getMerchantId()) || (this
				.getMerchantId() != null && castOther.getMerchantId() != null && this
				.getMerchantId().equals(castOther.getMerchantId())))
				&& ((this.getModeId() == castOther.getModeId()) || (this
						.getModeId() != null && castOther.getModeId() != null && this
						.getModeId().equals(castOther.getModeId())))
				&& ((this.getModeType() == castOther.getModeType()) || (this
						.getModeType() != null
						&& castOther.getModeType() != null && this
						.getModeType().equals(castOther.getModeType())));
	}

	public int hashCode() {
		int result = 17;

		result = 37
				* result
				+ (getMerchantId() == null ? 0 : this.getMerchantId()
						.hashCode());
		result = 37 * result
				+ (getModeId() == null ? 0 : this.getModeId().hashCode());
		result = 37 * result
				+ (getModeType() == null ? 0 : this.getModeType().hashCode());
		return result;
	}

}