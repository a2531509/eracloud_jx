package com.erp.model;

import com.erp.util.ExcelVOAttribute;

public class CardRecoverRegCardNo {
	@ExcelVOAttribute(name = "cardNo",column="A")
	private String cardNo;

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}
}
