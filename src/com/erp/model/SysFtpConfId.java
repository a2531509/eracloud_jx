package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * SysFtpConfId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class SysFtpConfId implements java.io.Serializable {

	// Fields

	private String ftpUse;
	private String ftpParaName;

	// Constructors

	/** default constructor */
	public SysFtpConfId() {
	}

	/** full constructor */
	public SysFtpConfId(String ftpUse, String ftpParaName) {
		this.ftpUse = ftpUse;
		this.ftpParaName = ftpParaName;
	}

	// Property accessors

	@Column(name = "FTP_USE", nullable = false, length = 100)
	public String getFtpUse() {
		return this.ftpUse;
	}

	public void setFtpUse(String ftpUse) {
		this.ftpUse = ftpUse;
	}

	@Column(name = "FTP_PARA_NAME", nullable = false, length = 100)
	public String getFtpParaName() {
		return this.ftpParaName;
	}

	public void setFtpParaName(String ftpParaName) {
		this.ftpParaName = ftpParaName;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof SysFtpConfId))
			return false;
		SysFtpConfId castOther = (SysFtpConfId) other;

		return ((this.getFtpUse() == castOther.getFtpUse()) || (this
				.getFtpUse() != null && castOther.getFtpUse() != null && this
				.getFtpUse().equals(castOther.getFtpUse())))
				&& ((this.getFtpParaName() == castOther.getFtpParaName()) || (this
						.getFtpParaName() != null
						&& castOther.getFtpParaName() != null && this
						.getFtpParaName().equals(castOther.getFtpParaName())));
	}

	public int hashCode() {
		int result = 17;

		result = 37 * result
				+ (getFtpUse() == null ? 0 : this.getFtpUse().hashCode());
		result = 37
				* result
				+ (getFtpParaName() == null ? 0 : this.getFtpParaName()
						.hashCode());
		return result;
	}

}