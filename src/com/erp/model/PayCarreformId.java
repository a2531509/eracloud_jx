package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * PayCarreformId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class PayCarreformId implements java.io.Serializable {

	// Fields

	private Long batchNumber;
	private String certNo;

	// Constructors

	/** default constructor */
	public PayCarreformId() {
	}

	/** full constructor */
	public PayCarreformId(Long batchNumber, String certNo) {
		this.batchNumber = batchNumber;
		this.certNo = certNo;
	}

	// Property accessors

	@Column(name = "BATCH_NUMBER", nullable = false, length = 15)
	public Long getBatchNumber() {
		return this.batchNumber;
	}

	public void setBatchNumber(Long batchNumber) {
		this.batchNumber = batchNumber;
	}

	@Column(name = "CERT_NO", nullable = false, length = 18)
	public String getCertNo() {
		return this.certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof PayCarreformId))
			return false;
		PayCarreformId castOther = (PayCarreformId) other;

		return ((this.getBatchNumber() == castOther.getBatchNumber()) || (this
				.getBatchNumber() != null && castOther.getBatchNumber() != null && this
				.getBatchNumber().equals(castOther.getBatchNumber())))
				&& ((this.getCertNo() == castOther.getCertNo()) || (this
						.getCertNo() != null && castOther.getCertNo() != null && this
						.getCertNo().equals(castOther.getCertNo())));
	}

	public int hashCode() {
		int result = 17;

		result = 37
				* result
				+ (getBatchNumber() == null ? 0 : this.getBatchNumber()
						.hashCode());
		result = 37 * result
				+ (getCertNo() == null ? 0 : this.getCertNo().hashCode());
		return result;
	}

}