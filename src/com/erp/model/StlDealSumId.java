package com.erp.model;

import java.math.BigDecimal;
import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * StlDealSumId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class StlDealSumId implements java.io.Serializable {

	// Fields

	private String stlSumNo;
	private String cardType;
	private String accKind;

	// Constructors

	/** default constructor */
	public StlDealSumId() {
	}

	/** full constructor */
	public StlDealSumId(String stlSumNo, String cardType, String accKind) {
		this.stlSumNo = stlSumNo;
		this.cardType = cardType;
		this.accKind = accKind;
	}

	// Property accessors

	@Column(name = "STL_SUM_NO", nullable = false, precision = 22, scale = 0)
	public String getStlSumNo() {
		return this.stlSumNo;
	}

	public void setStlSumNo(String stlSumNo) {
		this.stlSumNo = stlSumNo;
	}

	@Column(name = "CARD_TYPE", nullable = false, length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "ACC_KIND", nullable = false, length = 2)
	public String getAccKind() {
		return this.accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof StlDealSumId))
			return false;
		StlDealSumId castOther = (StlDealSumId) other;

		return ((this.getStlSumNo() == castOther.getStlSumNo()) || (this
				.getStlSumNo() != null && castOther.getStlSumNo() != null && this
				.getStlSumNo().equals(castOther.getStlSumNo())))
				&& ((this.getCardType() == castOther.getCardType()) || (this
						.getCardType() != null
						&& castOther.getCardType() != null && this
						.getCardType().equals(castOther.getCardType())))
				&& ((this.getAccKind() == castOther.getAccKind()) || (this
						.getAccKind() != null && castOther.getAccKind() != null && this
						.getAccKind().equals(castOther.getAccKind())));
	}

	public int hashCode() {
		int result = 17;

		result = 37 * result
				+ (getStlSumNo() == null ? 0 : this.getStlSumNo().hashCode());
		result = 37 * result
				+ (getCardType() == null ? 0 : this.getCardType().hashCode());
		result = 37 * result
				+ (getAccKind() == null ? 0 : this.getAccKind().hashCode());
		return result;
	}

}