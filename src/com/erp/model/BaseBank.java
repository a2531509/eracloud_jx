package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * BaseBank entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_BANK")
public class BaseBank implements java.io.Serializable {

	// Fields

	private String bankId;
	private String bankName;
	private String bankAddress;
	private String conPhone;
	private String bankState;
	private String merchantId;

	// Constructors

	/** default constructor */
	public BaseBank() {
	}

	/** minimal constructor */
	public BaseBank(String bankId) {
		this.bankId = bankId;
	}

	/** full constructor */
	public BaseBank(String bankId, String bankName, String bankAddress,
			String conPhone, String bankState, String merchantId) {
		this.bankId = bankId;
		this.bankName = bankName;
		this.bankAddress = bankAddress;
		this.conPhone = conPhone;
		this.bankState = bankState;
		this.merchantId = merchantId;
	}

	// Property accessors
	@Id
	@Column(name = "BANK_ID", unique = true, nullable = false, length = 4)
	public String getBankId() {
		return this.bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	@Column(name = "BANK_NAME", length = 64)
	public String getBankName() {
		return this.bankName;
	}

	public void setBankName(String bankName) {
		this.bankName = bankName;
	}

	@Column(name = "BANK_ADDRESS", length = 128)
	public String getBankAddress() {
		return this.bankAddress;
	}

	public void setBankAddress(String bankAddress) {
		this.bankAddress = bankAddress;
	}

	@Column(name = "CON_PHONE", length = 32)
	public String getConPhone() {
		return this.conPhone;
	}

	public void setConPhone(String conPhone) {
		this.conPhone = conPhone;
	}

	@Column(name = "BANK_STATE", length = 1)
	public String getBankState() {
		return this.bankState;
	}

	public void setBankState(String bankState) {
		this.bankState = bankState;
	}

	@Column(name = "MERCHANT_ID", length = 16)
	public String getMerchantId() {
		return this.merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

}