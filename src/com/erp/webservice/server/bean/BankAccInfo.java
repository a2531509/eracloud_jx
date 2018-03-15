package com.erp.webservice.server.bean;

import java.io.Serializable;

public class BankAccInfo implements Serializable {
	private static final long serialVersionUID = 1L;
	private String AAE354;
	private String certNo;
	private String name;
	private String bankAccName;
	private String bankCardNo;
	private String bankId;
	private String bankClrNo;

	public BankAccInfo() {
		super();
	}

	public BankAccInfo(String aAE354, String certNo, String name, String bankAccName, String bankCardNo, String bankId,
			String bankClrNo) {
		super();
		AAE354 = aAE354;
		this.certNo = certNo;
		this.name = name;
		this.bankAccName = bankAccName;
		this.bankCardNo = bankCardNo;
		this.bankId = bankId;
		this.bankClrNo = bankClrNo;
	}

	public String getAAE354() {
		return AAE354;
	}

	public void setAAE354(String aAE354) {
		AAE354 = aAE354;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getBankAccName() {
		return bankAccName;
	}

	public void setBankAccName(String bankAccName) {
		this.bankAccName = bankAccName;
	}

	public String getBankCardNo() {
		return bankCardNo;
	}

	public void setBankCardNo(String bankCardNo) {
		this.bankCardNo = bankCardNo;
	}

	public String getBankId() {
		return bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	public String getBankClrNo() {
		return bankClrNo;
	}

	public void setBankClrNo(String bankClrNo) {
		this.bankClrNo = bankClrNo;
	}

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
}
