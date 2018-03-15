package com.erp.model;

import java.math.BigDecimal;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Version;

/**
 * CardBlackRec entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_BLACK_REC")
public class CardBlackRec implements java.io.Serializable {

	// Fields

	private CardBlackRecId id;
	private Integer version;
	private String notes;

	// Constructors

	/** default constructor */
	public CardBlackRec() {
	}

	/** minimal constructor */
	public CardBlackRec(CardBlackRecId id) {
		this.id = id;
	}

	/** full constructor */
	public CardBlackRec(CardBlackRecId id, String notes) {
		this.id = id;
		this.notes = notes;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "dealNo", column = @Column(name = "DEAL_NO", nullable = false, precision = 16, scale = 0)),
			@AttributeOverride(name = "cardId", column = @Column(name = "CARD_ID", nullable = false, length = 50)),
			@AttributeOverride(name = "cardNo", column = @Column(name = "CARD_NO", nullable = false, length = 20)) })
	public CardBlackRecId getId() {
		return this.id;
	}

	public void setId(CardBlackRecId id) {
		this.id = id;
	}

	@Version
	@Column(name = "VERSION", precision = 22, scale = 0)
	public Integer getVersion() {
		return this.version;
	}

	public void setVersion(Integer version) {
		this.version = version;
	}

	@Column(name = "NOTES", length = 128)
	public String getNotes() {
		return this.notes;
	}

	public void setNotes(String notes) {
		this.notes = notes;
	}

}