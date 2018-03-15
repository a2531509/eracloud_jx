package com.erp.model;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * PayFeeRateSection entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "PAY_FEE_RATE_SECTION")
public class PayFeeRateSection implements java.io.Serializable {

	// Fields

	private PayFeeRateSectionId id;
	private Long feeRate;

	// Constructors

	/** default constructor */
	public PayFeeRateSection() {
	}

	/** minimal constructor */
	public PayFeeRateSection(PayFeeRateSectionId id) {
		this.id = id;
	}

	/** full constructor */
	public PayFeeRateSection(PayFeeRateSectionId id, Long feeRate) {
		this.id = id;
		this.feeRate = feeRate;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "feeRateId", column = @Column(name = "FEE_RATE_ID", nullable = false, precision = 22, scale = 0)),
			@AttributeOverride(name = "sectionNum", column = @Column(name = "SECTION_NUM", nullable = false, precision = 16, scale = 0)) })
	public PayFeeRateSectionId getId() {
		return this.id;
	}

	public void setId(PayFeeRateSectionId id) {
		this.id = id;
	}

	@Column(name = "FEE_RATE", precision = 16, scale = 0 )
	public Long getFeeRate() {
		return this.feeRate;
	}

	public void setFeeRate(Long feeRate) {
		this.feeRate = feeRate;
	}

}