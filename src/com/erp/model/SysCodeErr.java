package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

/**
 * SysCodeErr entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SYS_CODE_ERR", uniqueConstraints = @UniqueConstraint(columnNames = "FIELD_NAME"))
public class SysCodeErr implements java.io.Serializable {

	// Fields

	private Long errCode;
	private String message;
	private String fieldName;
	private String codedesc;
	private String state;

	// Constructors

	/** default constructor */
	public SysCodeErr() {
	}

	/** minimal constructor */
	public SysCodeErr(Long errCode, String message, String fieldName) {
		this.errCode = errCode;
		this.message = message;
		this.fieldName = fieldName;
	}

	/** full constructor */
	public SysCodeErr(Long errCode, String message, String fieldName,
			String codedesc, String state) {
		this.errCode = errCode;
		this.message = message;
		this.fieldName = fieldName;
		this.codedesc = codedesc;
		this.state = state;
	}

	// Property accessors
	@Id
	@Column(name = "ERR_CODE", unique = true, nullable = false, precision = 8, scale = 0)
	public Long getErrCode() {
		return this.errCode;
	}

	public void setErrCode(Long errCode) {
		this.errCode = errCode;
	}

	@Column(name = "MESSAGE", nullable = false, length = 100)
	public String getMessage() {
		return this.message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	@Column(name = "FIELD_NAME", unique = true, nullable = false, length = 50)
	public String getFieldName() {
		return this.fieldName;
	}

	public void setFieldName(String fieldName) {
		this.fieldName = fieldName;
	}

	@Column(name = "CODEDESC", length = 128)
	public String getCodedesc() {
		return this.codedesc;
	}

	public void setCodedesc(String codedesc) {
		this.codedesc = codedesc;
	}

	@Column(name = "STATE", length = 1)
	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

}