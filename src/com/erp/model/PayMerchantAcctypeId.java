package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * PayMerchantAcctypeId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class PayMerchantAcctypeId implements java.io.Serializable {

	// Fields

	private String merchantId;
	private String accKind;

	// Constructors

	/** default constructor */
	public PayMerchantAcctypeId() {
	}

	/** full constructor */
	public PayMerchantAcctypeId(String merchantId, String accKind) {
		this.merchantId = merchantId;
		this.accKind = accKind;
	}

	// Property accessors

	@Column(name = "MERCHANT_ID", nullable = false, length = 16)
	public String getMerchantId() {
		return this.merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	@Column(name = "ACC_KIND", nullable = false, length = 2)
	public String getAccKind() {
		return this.accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof PayMerchantAcctypeId))
			return false;
		PayMerchantAcctypeId castOther = (PayMerchantAcctypeId) other;

		return ((this.getMerchantId() == castOther.getMerchantId()) || (this
				.getMerchantId() != null && castOther.getMerchantId() != null && this
				.getMerchantId().equals(castOther.getMerchantId())))
				&& ((this.getAccKind() == castOther.getAccKind()) || (this
						.getAccKind() != null && castOther.getAccKind() != null && this
						.getAccKind().equals(castOther.getAccKind())));
	}

	public int hashCode() {
		int result = 17;

		result = 37
				* result
				+ (getMerchantId() == null ? 0 : this.getMerchantId()
						.hashCode());
		result = 37 * result
				+ (getAccKind() == null ? 0 : this.getAccKind().hashCode());
		return result;
	}

}