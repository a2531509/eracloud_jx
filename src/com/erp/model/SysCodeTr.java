package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * SysCodeTr entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SYS_CODE_TR")
public class SysCodeTr implements java.io.Serializable {

	// Fields

	private Integer trCode;
	private String trCodeName;
	private String trCodeType;
	private String fieldName;
	private String num;
	private String num2;
	private String num3;
	private String amt;
	private String amt2;
	private String amt3;
	private String amt4;
	private String amt5;
	private String betweenFlag;
	private String isTosum;
	private String state;
	private String codedesc;
	private Short ordNo;
	private String voucherTitle;

	// Constructors

	/** default constructor */
	public SysCodeTr() {
	}

	/** minimal constructor */
	public SysCodeTr(Integer trCode, String trCodeName, String trCodeType,
			String fieldName) {
		this.trCode = trCode;
		this.trCodeName = trCodeName;
		this.trCodeType = trCodeType;
		this.fieldName = fieldName;
	}

	/** full constructor */
	public SysCodeTr(Integer trCode, String trCodeName, String trCodeType,
			String fieldName, String num, String num2, String num3, String amt,
			String amt2, String amt3, String amt4, String amt5,
			String betweenFlag, String isTosum, String state, String codedesc,
			Short ordNo, String voucherTitle) {
		this.trCode = trCode;
		this.trCodeName = trCodeName;
		this.trCodeType = trCodeType;
		this.fieldName = fieldName;
		this.num = num;
		this.num2 = num2;
		this.num3 = num3;
		this.amt = amt;
		this.amt2 = amt2;
		this.amt3 = amt3;
		this.amt4 = amt4;
		this.amt5 = amt5;
		this.betweenFlag = betweenFlag;
		this.isTosum = isTosum;
		this.state = state;
		this.codedesc = codedesc;
		this.ordNo = ordNo;
		this.voucherTitle = voucherTitle;
	}

	// Property accessors
	@Id
	@Column(name = "TR_CODE", unique = true, nullable = false, precision = 6, scale = 0)
	public Integer getDealCode() {
		return this.trCode;
	}

	public void setDealCode(Integer trCode) {
		this.trCode = trCode;
	}

	@Column(name = "TR_CODE_NAME", nullable = false, length = 32)
	public String getDealCodeName() {
		return this.trCodeName;
	}

	public void setDealCodeName(String trCodeName) {
		this.trCodeName = trCodeName;
	}

	@Column(name = "TR_CODE_TYPE", nullable = false, length = 2)
	public String getDealCodeType() {
		return this.trCodeType;
	}

	public void setDealCodeType(String trCodeType) {
		this.trCodeType = trCodeType;
	}

	@Column(name = "FIELD_NAME", nullable = false, length = 32)
	public String getFieldName() {
		return this.fieldName;
	}

	public void setFieldName(String fieldName) {
		this.fieldName = fieldName;
	}

	@Column(name = "NUM", length = 32)
	public String getNum() {
		return this.num;
	}

	public void setNum(String num) {
		this.num = num;
	}

	@Column(name = "NUM2", length = 32)
	public String getNum2() {
		return this.num2;
	}

	public void setNum2(String num2) {
		this.num2 = num2;
	}

	@Column(name = "NUM3", length = 32)
	public String getNum3() {
		return this.num3;
	}

	public void setNum3(String num3) {
		this.num3 = num3;
	}

	@Column(name = "AMT", length = 32)
	public String getAmt() {
		return this.amt;
	}

	public void setAmt(String amt) {
		this.amt = amt;
	}

	@Column(name = "AMT2", length = 32)
	public String getAmt2() {
		return this.amt2;
	}

	public void setAmt2(String amt2) {
		this.amt2 = amt2;
	}

	@Column(name = "AMT3", length = 32)
	public String getAmt3() {
		return this.amt3;
	}

	public void setAmt3(String amt3) {
		this.amt3 = amt3;
	}

	@Column(name = "AMT4", length = 32)
	public String getAmt4() {
		return this.amt4;
	}

	public void setAmt4(String amt4) {
		this.amt4 = amt4;
	}

	@Column(name = "AMT5", length = 32)
	public String getAmt5() {
		return this.amt5;
	}

	public void setAmt5(String amt5) {
		this.amt5 = amt5;
	}

	@Column(name = "BETWEEN_FLAG", length = 1)
	public String getBetweenFlag() {
		return this.betweenFlag;
	}

	public void setBetweenFlag(String betweenFlag) {
		this.betweenFlag = betweenFlag;
	}

	@Column(name = "IS_TOSUM", length = 1)
	public String getIsTosum() {
		return this.isTosum;
	}

	public void setIsTosum(String isTosum) {
		this.isTosum = isTosum;
	}

	@Column(name = "STATE", length = 1)
	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

	@Column(name = "CODEDESC", length = 128)
	public String getCodedesc() {
		return this.codedesc;
	}

	public void setCodedesc(String codedesc) {
		this.codedesc = codedesc;
	}

	@Column(name = "ORD_NO", precision = 4, scale = 0)
	public Short getOrdNo() {
		return this.ordNo;
	}

	public void setOrdNo(Short ordNo) {
		this.ordNo = ordNo;
	}

	@Column(name = "VOUCHER_TITLE", length = 2)
	public String getVoucherTitle() {
		return this.voucherTitle;
	}

	public void setVoucherTitle(String voucherTitle) {
		this.voucherTitle = voucherTitle;
	}

}