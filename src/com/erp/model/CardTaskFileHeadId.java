package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * CardTaskFileHeadId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class CardTaskFileHeadId implements java.io.Serializable {

	// Fields

	private String cardTypeCatalog;
	private String flag;
	private String confValue;
	private String dataConfValue;

	// Constructors

	/** default constructor */
	public CardTaskFileHeadId() {
	}

	/** minimal constructor */
	public CardTaskFileHeadId(String cardTypeCatalog) {
		this.cardTypeCatalog = cardTypeCatalog;
	}

	/** full constructor */
	public CardTaskFileHeadId(String cardTypeCatalog, String flag,
			String confValue, String dataConfValue) {
		this.cardTypeCatalog = cardTypeCatalog;
		this.flag = flag;
		this.confValue = confValue;
		this.dataConfValue = dataConfValue;
	}

	// Property accessors

	@Column(name = "CARD_TYPE_CATALOG", nullable = false, length = 3)
	public String getCardTypeCatalog() {
		return this.cardTypeCatalog;
	}

	public void setCardTypeCatalog(String cardTypeCatalog) {
		this.cardTypeCatalog = cardTypeCatalog;
	}

	@Column(name = "FLAG", length = 1)
	public String getFlag() {
		return this.flag;
	}

	public void setFlag(String flag) {
		this.flag = flag;
	}

	@Column(name = "CONF_VALUE", length = 4000)
	public String getConfValue() {
		return this.confValue;
	}

	public void setConfValue(String confValue) {
		this.confValue = confValue;
	}

	@Column(name = "DATA_CONF_VALUE", length = 4000)
	public String getDataConfValue() {
		return this.dataConfValue;
	}

	public void setDataConfValue(String dataConfValue) {
		this.dataConfValue = dataConfValue;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof CardTaskFileHeadId))
			return false;
		CardTaskFileHeadId castOther = (CardTaskFileHeadId) other;

		return ((this.getCardTypeCatalog() == castOther.getCardTypeCatalog()) || (this
				.getCardTypeCatalog() != null
				&& castOther.getCardTypeCatalog() != null && this
				.getCardTypeCatalog().equals(castOther.getCardTypeCatalog())))
				&& ((this.getFlag() == castOther.getFlag()) || (this.getFlag() != null
						&& castOther.getFlag() != null && this.getFlag()
						.equals(castOther.getFlag())))
				&& ((this.getConfValue() == castOther.getConfValue()) || (this
						.getConfValue() != null
						&& castOther.getConfValue() != null && this
						.getConfValue().equals(castOther.getConfValue())))
				&& ((this.getDataConfValue() == castOther.getDataConfValue()) || (this
						.getDataConfValue() != null
						&& castOther.getDataConfValue() != null && this
						.getDataConfValue()
						.equals(castOther.getDataConfValue())));
	}

	public int hashCode() {
		int result = 17;

		result = 37
				* result
				+ (getCardTypeCatalog() == null ? 0 : this.getCardTypeCatalog()
						.hashCode());
		result = 37 * result
				+ (getFlag() == null ? 0 : this.getFlag().hashCode());
		result = 37 * result
				+ (getConfValue() == null ? 0 : this.getConfValue().hashCode());
		result = 37
				* result
				+ (getDataConfValue() == null ? 0 : this.getDataConfValue()
						.hashCode());
		return result;
	}

}