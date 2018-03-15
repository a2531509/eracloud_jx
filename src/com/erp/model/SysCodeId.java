package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * SysCodeId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class SysCodeId implements java.io.Serializable {

	// Fields

	private String codeType;
	private String codeValue;

	// Constructors

	/** default constructor */
	public SysCodeId() {
	}

	/** full constructor */
	public SysCodeId(String codeType, String codeValue) {
		this.codeType = codeType;
		this.codeValue = codeValue;
	}

	// Property accessors

	@Column(name = "CODE_TYPE", nullable = false, length = 32)
	public String getCodeType() {
		return this.codeType;
	}

	public void setCodeType(String codeType) {
		this.codeType = codeType;
	}

	@Column(name = "CODE_VALUE", nullable = false, length = 32)
	public String getCodeValue() {
		return this.codeValue;
	}

	public void setCodeValue(String codeValue) {
		this.codeValue = codeValue;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof SysCodeId))
			return false;
		SysCodeId castOther = (SysCodeId) other;

		return ((this.getCodeType() == castOther.getCodeType()) || (this
				.getCodeType() != null && castOther.getCodeType() != null && this
				.getCodeType().equals(castOther.getCodeType())))
				&& ((this.getCodeValue() == castOther.getCodeValue()) || (this
						.getCodeValue() != null
						&& castOther.getCodeValue() != null && this
						.getCodeValue().equals(castOther.getCodeValue())));
	}

	public int hashCode() {
		int result = 17;

		result = 37 * result
				+ (getCodeType() == null ? 0 : this.getCodeType().hashCode());
		result = 37 * result
				+ (getCodeValue() == null ? 0 : this.getCodeValue().hashCode());
		return result;
	}

}