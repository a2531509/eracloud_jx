package com.erp.model;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * AccItemConf entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "ACC_ITEM_CONF")
public class AccItemConf implements java.io.Serializable {

	// Fields

	private AccItemConfId id;
	private String itemName;
	private Short ordNo;

	// Constructors

	/** default constructor */
	public AccItemConf() {
	}

	/** minimal constructor */
	public AccItemConf(AccItemConfId id) {
		this.id = id;
	}

	/** full constructor */
	public AccItemConf(AccItemConfId id, String itemName, Short ordNo) {
		this.id = id;
		this.itemName = itemName;
		this.ordNo = ordNo;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "subjectType", column = @Column(name = "SUBJECT_TYPE", nullable = false, length = 1)),
			@AttributeOverride(name = "itemNo", column = @Column(name = "ITEM_NO", nullable = false, length = 10)) })
	public AccItemConfId getId() {
		return this.id;
	}

	public void setId(AccItemConfId id) {
		this.id = id;
	}

	@Column(name = "ITEM_NAME", length = 50)
	public String getItemName() {
		return this.itemName;
	}

	public void setItemName(String itemName) {
		this.itemName = itemName;
	}

	@Column(name = "ORD_NO", precision = 3, scale = 0)
	public Short getOrdNo() {
		return this.ordNo;
	}

	public void setOrdNo(Short ordNo) {
		this.ordNo = ordNo;
	}

}