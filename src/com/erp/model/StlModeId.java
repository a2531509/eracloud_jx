package com.erp.model;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Embeddable;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * StlModeId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class StlModeId implements java.io.Serializable {

	// Fields

	private String merchantId;
	private Date validDate;

	// Constructors

	/** default constructor */
	public StlModeId() {
	}

	/** full constructor */
	public StlModeId(String merchantId, Date validDate) {
		this.merchantId = merchantId;
		this.validDate = validDate;
	}

	// Property accessors

	@Column(name = "MERCHANT_ID", nullable = false, length = 16)
	public String getMerchantId() {
		return this.merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "VALID_DATE", nullable = false, length = 7)
	public Date getValidDate() {
		return this.validDate;
	}

	public void setValidDate(Date validDate) {
		this.validDate = validDate;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof StlModeId))
			return false;
		StlModeId castOther = (StlModeId) other;

		return ((this.getMerchantId() == castOther.getMerchantId()) || (this
				.getMerchantId() != null && castOther.getMerchantId() != null && this
				.getMerchantId().equals(castOther.getMerchantId())))
				&& ((this.getValidDate() == castOther.getValidDate()) || (this
						.getValidDate() != null
						&& castOther.getValidDate() != null && this
						.getValidDate().equals(castOther.getValidDate())));
	}

	public int hashCode() {
		int result = 17;

		result = 37
				* result
				+ (getMerchantId() == null ? 0 : this.getMerchantId()
						.hashCode());
		result = 37 * result
				+ (getValidDate() == null ? 0 : this.getValidDate().hashCode());
		return result;
	}

}