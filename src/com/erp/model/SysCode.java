package com.erp.model;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * SysCode entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SYS_CODE")
public class SysCode implements java.io.Serializable {

	// Fields

	private SysCodeId id;
	private String typeName;
	private String codeName;
	private String codeState;
	private Long ordNo;
	private String fieldName;

	// Constructors

	/** default constructor */
	public SysCode() {
	}

	/** minimal constructor */
	public SysCode(SysCodeId id) {
		this.id = id;
	}

	/** full constructor */
	public SysCode(SysCodeId id, String typeName, String codeName,
			String codeState, Long ordNo, String fieldName) {
		this.id = id;
		this.typeName = typeName;
		this.codeName = codeName;
		this.codeState = codeState;
		this.ordNo = ordNo;
		this.fieldName = fieldName;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "codeType", column = @Column(name = "CODE_TYPE", nullable = false, length = 32)),
			@AttributeOverride(name = "codeValue", column = @Column(name = "CODE_VALUE", nullable = false, length = 32)) })
	public SysCodeId getId() {
		return this.id;
	}

	public void setId(SysCodeId id) {
		this.id = id;
	}

	@Column(name = "TYPE_NAME", length = 32)
	public String getTypeName() {
		return this.typeName;
	}

	public void setTypeName(String typeName) {
		this.typeName = typeName;
	}

	@Column(name = "CODE_NAME", length = 128)
	public String getCodeName() {
		return this.codeName;
	}

	public void setCodeName(String codeName) {
		this.codeName = codeName;
	}

	@Column(name = "CODE_STATE", length = 1)
	public String getCodeState() {
		return this.codeState;
	}

	public void setCodeState(String codeState) {
		this.codeState = codeState;
	}

	@Column(name = "ORD_NO", precision = 22, scale = 0)
	public Long getOrdNo() {
		return this.ordNo;
	}

	public void setOrdNo(Long ordNo) {
		this.ordNo = ordNo;
	}

	@Column(name = "FIELD_NAME", length = 32)
	public String getFieldName() {
		return this.fieldName;
	}

	public void setFieldName(String fieldName) {
		this.fieldName = fieldName;
	}

}