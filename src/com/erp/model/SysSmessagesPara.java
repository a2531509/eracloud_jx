package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * SysSmessagesPara entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SYS_SMESSAGES_PARA")
public class SysSmessagesPara implements java.io.Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -4228435574734803762L;
	// Fields

	private Integer dealCode;
	private String isfixed;
	private String content;
	private String state;

	// Constructors

	/** default constructor */
	public SysSmessagesPara() {
	}

	/** minimal constructor */
	public SysSmessagesPara(Integer dealCode) {
		this.dealCode = dealCode;
	}

	/** full constructor */
	public SysSmessagesPara(Integer dealCode, String isfixed, String content,
			String state) {
		this.dealCode = dealCode;
		this.isfixed = isfixed;
		this.content = content;
		this.state = state;
	}

	// Property accessors
	@Id
	@Column(name = "DEAL_CODE", unique = true, nullable = false, precision = 6, scale = 0)
	public Integer getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(Integer dealCode) {
		this.dealCode = dealCode;
	}

	@Column(name = "ISFIXED", length = 1)
	public String getIsfixed() {
		return this.isfixed;
	}

	public void setIsfixed(String isfixed) {
		this.isfixed = isfixed;
	}

	@Column(name = "CONTENT", length = 512)
	public String getContent() {
		return this.content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	@Column(name = "STATE", length = 1)
	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

}