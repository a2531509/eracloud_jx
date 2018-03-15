package com.erp.model;

import java.math.BigDecimal;
import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * CardTaskImpId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class CardTaskImpId implements java.io.Serializable {

	// Fields

	private String batchId;
	private Long dataSeq;

	// Constructors

	/** default constructor */
	public CardTaskImpId() {
	}

	/** full constructor */
	public CardTaskImpId(String batchId, Long dataSeq) {
		this.batchId = batchId;
		this.dataSeq = dataSeq;
	}

	// Property accessors

	@Column(name = "BATCH_ID", nullable = false, length = 14)
	public String getBatchId() {
		return this.batchId;
	}

	public void setBatchId(String batchId) {
		this.batchId = batchId;
	}

	@Column(name = "DATA_SEQ", nullable = false, precision = 22, scale = 0)
	public Long getDataSeq() {
		return this.dataSeq;
	}

	public void setDataSeq(Long dataSeq) {
		this.dataSeq = dataSeq;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof CardTaskImpId))
			return false;
		CardTaskImpId castOther = (CardTaskImpId) other;

		return ((this.getBatchId() == castOther.getBatchId()) || (this
				.getBatchId() != null && castOther.getBatchId() != null && this
				.getBatchId().equals(castOther.getBatchId())))
				&& ((this.getDataSeq() == castOther.getDataSeq()) || (this
						.getDataSeq() != null && castOther.getDataSeq() != null && this
						.getDataSeq().equals(castOther.getDataSeq())));
	}

	public int hashCode() {
		int result = 17;

		result = 37 * result
				+ (getBatchId() == null ? 0 : this.getBatchId().hashCode());
		result = 37 * result
				+ (getDataSeq() == null ? 0 : this.getDataSeq().hashCode());
		return result;
	}

}