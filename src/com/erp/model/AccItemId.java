package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * BasicAccItemId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class AccItemId implements java.io.Serializable {

	// Fields

	private String orgId;
	private String itemNo;

	// Constructors

	/** default constructor */
	public AccItemId() {
	}

	/** full constructor */
	public AccItemId(String orgId, String itemNo) {
		this.orgId = orgId;
		this.itemNo = itemNo;
	}

	// Property accessors

	@Column(name = "ORG_ID", nullable = false, length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "ITEM_NO", nullable = false, length = 6)
	public String getItemNo() {
		return this.itemNo;
	}

	public void setItemNo(String itemNo) {
		this.itemNo = itemNo;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof AccItemId))
			return false;
		AccItemId castOther = (AccItemId) other;

		return ((this.getOrgId() == castOther.getOrgId()) || (this.getOrgId() != null
				&& castOther.getOrgId() != null && this.getOrgId().equals(
				castOther.getOrgId())))
				&& ((this.getItemNo() == castOther.getItemNo()) || (this
						.getItemNo() != null && castOther.getItemNo() != null && this
						.getItemNo().equals(castOther.getItemNo())));
	}

	public int hashCode() {
		int result = 17;

		result = 37 * result
				+ (getOrgId() == null ? 0 : this.getOrgId().hashCode());
		result = 37 * result
				+ (getItemNo() == null ? 0 : this.getItemNo().hashCode());
		return result;
	}

}