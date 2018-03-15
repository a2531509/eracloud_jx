package com.erp.model;

import java.io.Serializable;

import javax.persistence.Column;

public class CardInsuranceInfoId implements Serializable {
	private static final long serialVersionUID = 1L;

	@Column(name = "card_no")
	private String cardNo;

	@Column(name = "insurance_no")
	private String insuranceNo;

	public CardInsuranceInfoId() {
		super();
	}

	public CardInsuranceInfoId(String cardNo, String insuranceNo) {
		super();
		this.cardNo = cardNo;
		this.insuranceNo = insuranceNo;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getInsuranceNo() {
		return insuranceNo;
	}

	public void setInsuranceNo(String insuranceNo) {
		this.insuranceNo = insuranceNo;
	}
}
