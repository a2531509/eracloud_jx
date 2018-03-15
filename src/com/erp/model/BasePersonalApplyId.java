package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * BasePersonalApplyId entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Embeddable
public class BasePersonalApplyId implements java.io.Serializable {

	// Fields

	private String customerId;
	private String userId;

	// Constructors

	/** default constructor */
	public BasePersonalApplyId() {
	}

	/** full constructor */
	public BasePersonalApplyId(String customerId, String userId) {
		this.customerId = customerId;
		this.userId = userId;
	}

	// Property accessors

	@Column(name = "CUSTOMER_ID", nullable = false, length = 18)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "USER_ID", nullable = false, length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof BasePersonalApplyId))
			return false;
		BasePersonalApplyId castOther = (BasePersonalApplyId) other;

		return ((this.getCustomerId() == castOther.getCustomerId()) || (this
				.getCustomerId() != null && castOther.getCustomerId() != null && this
				.getCustomerId().equals(castOther.getCustomerId())))
				&& ((this.getUserId() == castOther.getUserId()) || (this
						.getUserId() != null && castOther.getUserId() != null && this
						.getUserId().equals(castOther.getUserId())));
	}

	public int hashCode() {
		int result = 17;

		result = 37
				* result
				+ (getCustomerId() == null ? 0 : this.getCustomerId()
						.hashCode());
		result = 37 * result
				+ (getUserId() == null ? 0 : this.getUserId().hashCode());
		return result;
	}

}