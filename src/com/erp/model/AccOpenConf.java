package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;
import org.hibernate.annotations.GenericGenerator;

/**
 * AccOpenConf entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "ACC_OPEN_CONF")
public class AccOpenConf implements java.io.Serializable {

	// Fields

	private Long id;
	private String mainType;
	private String subType;
	private String itemId;
	private String accKind;
	private String confState;
	private String accInitState;

	// Constructors

	/** default constructor */
	public AccOpenConf() {
	}

	/** minimal constructor */
	public AccOpenConf(String mainType, String itemId, String accKind,
			String confState) {
		this.mainType = mainType;
		this.itemId = itemId;
		this.accKind = accKind;
		this.confState = confState;
	}

	/** full constructor */
	public AccOpenConf(String mainType, String subType, String itemId,
			String accKind, String confState, String accInitState) {
		this.mainType = mainType;
		this.subType = subType;
		this.itemId = itemId;
		this.accKind = accKind;
		this.confState = confState;
		this.accInitState = accInitState;
	}

	// Property accessors
	@GenericGenerator(name = "generator", strategy = "increment")
	@Id
	@GeneratedValue(generator = "generator")
	@Column(name = "ID", unique = true, nullable = false, precision = 16, scale = 0)
	public Long getId() {
		return this.id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Column(name = "MAIN_TYPE", nullable = false, length = 1)
	public String getMainType() {
		return this.mainType;
	}

	public void setMainType(String mainType) {
		this.mainType = mainType;
	}

	@Column(name = "SUB_TYPE", length = 3)
	public String getSubType() {
		return this.subType;
	}

	public void setSubType(String subType) {
		this.subType = subType;
	}

	@Column(name = "ITEM_ID", nullable = false, length = 6)
	public String getItemId() {
		return this.itemId;
	}

	public void setItemId(String itemId) {
		this.itemId = itemId;
	}

	@Column(name = "ACC_KIND", nullable = false, length = 2)
	public String getAccKind() {
		return this.accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	@Column(name = "CONF_STATE", nullable = false, length = 1)
	public String getConfState() {
		return this.confState;
	}

	public void setConfState(String confState) {
		this.confState = confState;
	}

	@Column(name = "ACC_INIT_STATE", length = 1)
	public String getAccInitState() {
		return this.accInitState;
	}

	public void setAccInitState(String accInitState) {
		this.accInitState = accInitState;
	}

}