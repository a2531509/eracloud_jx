package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.MappedSuperclass;

/**
 * AbstractSysPara entity provides the base persistence definition of the
 * SysPara entity. @author MyEclipse Persistence Tools
 */
@MappedSuperclass
public abstract class AbstractSysPara implements java.io.Serializable {

	// Fields

	private String paraCode;
	private String paraValue;
	private String paraValue2;
	private String paraValue3;
	private String paraValue4;
	private String paraValue5;
	private String paraValue6;
	private String paraValue7;
	private String paraValue8;
	private String paraDesc;

	// Constructors

	/** default constructor */
	public AbstractSysPara() {
	}

	/** minimal constructor */
	public AbstractSysPara(String paraCode) {
		this.paraCode = paraCode;
	}

	/** full constructor */
	public AbstractSysPara(String paraCode, String paraValue,
			String paraValue2, String paraValue3, String paraValue4,
			String paraValue5, String paraValue6, String paraValue7,
			String paraValue8, String paraDesc) {
		this.paraCode = paraCode;
		this.paraValue = paraValue;
		this.paraValue2 = paraValue2;
		this.paraValue3 = paraValue3;
		this.paraValue4 = paraValue4;
		this.paraValue5 = paraValue5;
		this.paraValue6 = paraValue6;
		this.paraValue7 = paraValue7;
		this.paraValue8 = paraValue8;
		this.paraDesc = paraDesc;
	}

	// Property accessors
	@Id
	@Column(name = "PARA_CODE", unique = true, nullable = false, length = 32)
	public String getParaCode() {
		return this.paraCode;
	}

	public void setParaCode(String paraCode) {
		this.paraCode = paraCode;
	}

	@Column(name = "PARA_VALUE", length = 32)
	public String getParaValue() {
		return this.paraValue;
	}

	public void setParaValue(String paraValue) {
		this.paraValue = paraValue;
	}

	@Column(name = "PARA_VALUE2", length = 32)
	public String getParaValue2() {
		return this.paraValue2;
	}

	public void setParaValue2(String paraValue2) {
		this.paraValue2 = paraValue2;
	}

	@Column(name = "PARA_VALUE3", length = 32)
	public String getParaValue3() {
		return this.paraValue3;
	}

	public void setParaValue3(String paraValue3) {
		this.paraValue3 = paraValue3;
	}

	@Column(name = "PARA_VALUE4", length = 32)
	public String getParaValue4() {
		return this.paraValue4;
	}

	public void setParaValue4(String paraValue4) {
		this.paraValue4 = paraValue4;
	}

	@Column(name = "PARA_VALUE5", length = 32)
	public String getParaValue5() {
		return this.paraValue5;
	}

	public void setParaValue5(String paraValue5) {
		this.paraValue5 = paraValue5;
	}

	@Column(name = "PARA_VALUE6", length = 32)
	public String getParaValue6() {
		return this.paraValue6;
	}

	public void setParaValue6(String paraValue6) {
		this.paraValue6 = paraValue6;
	}

	@Column(name = "PARA_VALUE7", length = 32)
	public String getParaValue7() {
		return this.paraValue7;
	}

	public void setParaValue7(String paraValue7) {
		this.paraValue7 = paraValue7;
	}

	@Column(name = "PARA_VALUE8", length = 32)
	public String getParaValue8() {
		return this.paraValue8;
	}

	public void setParaValue8(String paraValue8) {
		this.paraValue8 = paraValue8;
	}

	@Column(name = "PARA_DESC", length = 156)
	public String getParaDesc() {
		return this.paraDesc;
	}

	public void setParaDesc(String paraDesc) {
		this.paraDesc = paraDesc;
	}

}