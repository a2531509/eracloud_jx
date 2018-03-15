package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * AccItemConfId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class AccItemConfId implements java.io.Serializable {

	// Fields

	private String subjectType;
	private String itemNo;

	// Constructors

	/** default constructor */
	public AccItemConfId() {
	}

	/** full constructor */
	public AccItemConfId(String subjectType, String itemNo) {
		this.subjectType = subjectType;
		this.itemNo = itemNo;
	}

	// Property accessors

	@Column(name = "SUBJECT_TYPE", nullable = false, length = 1)
	public String getSubjectType() {
		return this.subjectType;
	}

	public void setSubjectType(String subjectType) {
		this.subjectType = subjectType;
	}

	@Column(name = "ITEM_NO", nullable = false, length = 10)
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
		if (!(other instanceof AccItemConfId))
			return false;
		AccItemConfId castOther = (AccItemConfId) other;

		return ((this.getSubjectType() == castOther.getSubjectType()) || (this
				.getSubjectType() != null && castOther.getSubjectType() != null && this
				.getSubjectType().equals(castOther.getSubjectType())))
				&& ((this.getItemNo() == castOther.getItemNo()) || (this
						.getItemNo() != null && castOther.getItemNo() != null && this
						.getItemNo().equals(castOther.getItemNo())));
	}

	public int hashCode() {
		int result = 17;

		result = 37
				* result
				+ (getSubjectType() == null ? 0 : this.getSubjectType()
						.hashCode());
		result = 37 * result
				+ (getItemNo() == null ? 0 : this.getItemNo().hashCode());
		return result;
	}

}