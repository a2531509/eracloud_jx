package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * BaseSiinfoId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class BaseSiinfoId implements java.io.Serializable {

	private static final long serialVersionUID = 1L;

	private String personalId;
	private String medWholeNo;

	// Constructors

	/** default constructor */
	public BaseSiinfoId() {
	}

	/** full constructor */
	public BaseSiinfoId(String personalId, String medWholeNo) {
		this.personalId = personalId;
		this.medWholeNo = medWholeNo;
	}

	// Property accessors

	@Column(name = "PERSONAL_ID", nullable = false, length = 18)
	public String getPersonalId() {
		return this.personalId;
	}

	public void setPersonalId(String personalId) {
		this.personalId = personalId;
	}

	@Column(name = "MED_WHOLE_NO", nullable = false, length = 32)
	public String getMedWholeNo() {
		return this.medWholeNo;
	}

	public void setMedWholeNo(String medWholeNo) {
		this.medWholeNo = medWholeNo;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof BaseSiinfoId))
			return false;
		BaseSiinfoId castOther = (BaseSiinfoId) other;

		return ((this.getPersonalId() == castOther.getPersonalId()) || (this.getPersonalId() != null
				&& castOther.getPersonalId() != null && this.getPersonalId().equals(castOther.getPersonalId())))
				&& ((this.getMedWholeNo() == castOther.getMedWholeNo())
						|| (this.getMedWholeNo() != null && castOther.getMedWholeNo() != null
								&& this.getMedWholeNo().equals(castOther.getMedWholeNo())));
	}

	public int hashCode() {
		int result = 17;

		result = 37 * result + (getPersonalId() == null ? 0 : this.getPersonalId().hashCode());
		result = 37 * result + (getMedWholeNo() == null ? 0 : this.getMedWholeNo().hashCode());
		return result;
	}

}