package com.erp.model;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * CardTaskFileHead entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_TASK_FILE_HEAD")
public class CardTaskFileHead implements java.io.Serializable {

	// Fields

	private CardTaskFileHeadId id;

	// Constructors

	/** default constructor */
	public CardTaskFileHead() {
	}

	/** full constructor */
	public CardTaskFileHead(CardTaskFileHeadId id) {
		this.id = id;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "cardTypeCatalog", column = @Column(name = "CARD_TYPE_CATALOG", nullable = false, length = 3)),
			@AttributeOverride(name = "flag", column = @Column(name = "FLAG", length = 1)),
			@AttributeOverride(name = "confValue", column = @Column(name = "CONF_VALUE", length = 4000)),
			@AttributeOverride(name = "dataConfValue", column = @Column(name = "DATA_CONF_VALUE", length = 4000)) })
	public CardTaskFileHeadId getId() {
		return this.id;
	}

	public void setId(CardTaskFileHeadId id) {
		this.id = id;
	}

}