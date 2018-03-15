package com.erp.model;

import java.math.BigDecimal;
import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * PayFeeRateSectionId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class PayFeeRateSectionId implements java.io.Serializable {

	// Fields

	private Long feeRateId;
	private Long sectionNum;

	// Constructors

	/** default constructor */
	public PayFeeRateSectionId() {
	}

	/** full constructor */
	public PayFeeRateSectionId(Long feeRateId, Long sectionNum) {
		this.feeRateId = feeRateId;
		this.sectionNum = sectionNum;
	}

	// Property accessors

	@Column(name = "FEE_RATE_ID", nullable = false, precision = 22, scale = 0)
	public Long getFeeRateId() {
		return this.feeRateId;
	}

	public void setFeeRateId(Long feeRateId) {
		this.feeRateId = feeRateId;
	}

	@Column(name = "SECTION_NUM", nullable = false, precision = 16, scale = 0)
	public Long getSectionNum() {
		return this.sectionNum;
	}

	public void setSectionNum(Long sectionNum) {
		this.sectionNum = sectionNum;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof PayFeeRateSectionId))
			return false;
		PayFeeRateSectionId castOther = (PayFeeRateSectionId) other;

		return ((this.getFeeRateId() == castOther.getFeeRateId()) || (this
				.getFeeRateId() != null && castOther.getFeeRateId() != null && this
				.getFeeRateId().equals(castOther.getFeeRateId())))
				&& ((this.getSectionNum() == castOther.getSectionNum()) || (this
						.getSectionNum() != null
						&& castOther.getSectionNum() != null && this
						.getSectionNum().equals(castOther.getSectionNum())));
	}

	public int hashCode() {
		int result = 17;

		result = 37 * result
				+ (getFeeRateId() == null ? 0 : this.getFeeRateId().hashCode());
		result = 37
				* result
				+ (getSectionNum() == null ? 0 : this.getSectionNum()
						.hashCode());
		return result;
	}

}