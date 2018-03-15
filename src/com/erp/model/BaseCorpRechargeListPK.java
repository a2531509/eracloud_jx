package com.erp.model;

import java.io.Serializable;

import javax.persistence.Column;

public class BaseCorpRechargeListPK implements Serializable {
	private static final long serialVersionUID = 1L;

	private Long rcgInfoId;
	private String customerId;

	public BaseCorpRechargeListPK() {

	}

	public BaseCorpRechargeListPK(Long rcgInfoId, String customerId) {
		this.rcgInfoId = rcgInfoId;
		this.customerId = customerId;
	}

	@Column(name = "rcg_info_id", nullable = false, length = 38)
	public Long getRcgInfoId() {
		return rcgInfoId;
	}

	public void setRcgInfoId(Long rcgInfoId) {
		this.rcgInfoId = rcgInfoId;
	}

	@Column(name = "customer_id")
	public String getCustomerId() {
		return customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result
				+ ((customerId == null) ? 0 : customerId.hashCode());
		result = prime * result
				+ ((rcgInfoId == null) ? 0 : rcgInfoId.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		BaseCorpRechargeListPK other = (BaseCorpRechargeListPK) obj;
		if (customerId == null) {
			if (other.customerId != null)
				return false;
		} else if (!customerId.equals(other.customerId))
			return false;
		if (rcgInfoId == null) {
			if (other.rcgInfoId != null)
				return false;
		} else if (!rcgInfoId.equals(other.rcgInfoId))
			return false;
		return true;
	}
}
