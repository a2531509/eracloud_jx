package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * CardBlackRecId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class CardBlackRecId implements java.io.Serializable {

	// Fields

	private Long dealNo;
	private String cardId;
	private String cardNo;

	// Constructors

	/** default constructor */
	public CardBlackRecId() {
	}

	/** full constructor */
	public CardBlackRecId(Long dealNo, String cardId, String cardNo) {
		this.dealNo = dealNo;
		this.cardId = cardId;
		this.cardNo = cardNo;
	}

	// Property accessors

	@Column(name = "DEAL_NO", nullable = false, precision = 16, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "CARD_ID", nullable = false, length = 50)
	public String getCardId() {
		return this.cardId;
	}

	public void setCardId(String cardId) {
		this.cardId = cardId;
	}

	@Column(name = "CARD_NO", nullable = false, length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof CardBlackRecId))
			return false;
		CardBlackRecId castOther = (CardBlackRecId) other;

		return ((this.getDealNo() == castOther.getDealNo()) || (this
				.getDealNo() != null && castOther.getDealNo() != null && this
				.getDealNo().equals(castOther.getDealNo())))
				&& ((this.getCardId() == castOther.getCardId()) || (this
						.getCardId() != null && castOther.getCardId() != null && this
						.getCardId().equals(castOther.getCardId())))
				&& ((this.getCardNo() == castOther.getCardNo()) || (this
						.getCardNo() != null && castOther.getCardNo() != null && this
						.getCardNo().equals(castOther.getCardNo())));
	}

	public int hashCode() {
		int result = 17;

		result = 37 * result
				+ (getDealNo() == null ? 0 : this.getDealNo().hashCode());
		result = 37 * result
				+ (getCardId() == null ? 0 : this.getCardId().hashCode());
		result = 37 * result
				+ (getCardNo() == null ? 0 : this.getCardNo().hashCode());
		return result;
	}

}