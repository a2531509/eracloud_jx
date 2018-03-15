package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "CARD_NO")
public class CardNo implements java.io.Serializable {
	private String cardNo;
	private String city;
	private String cardType;
	private String pwd;
	private Long dealNo;

	private String used;
	private String cardCatalog;
	private String balCrypt;
	private String regionCode;
	private String pwdCrypt;

	@Id
	@Column(name = "CARD_NO", nullable = false, length = 32)
	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "CITY", nullable = false, length = 32)
	public String getCity() {
		return city;
	}

	public void setCity(String city) {
		this.city = city;
	}

	@Column(name = "CARD_TYPE", nullable = false, length = 32)
	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "PWD", nullable = false, length = 32)
	public String getPwd() {
		return pwd;
	}

	public void setPwd(String pwd) {
		this.pwd = pwd;
	}

	@Column(name = "USED", nullable = false, length = 32)
	public String getUsed() {
		return used;
	}

	public void setUsed(String used) {
		this.used = used;
	}

	@Column(name = "CARD_CATALOG", nullable = false, length = 32)
	public String getCardCatalog() {
		return cardCatalog;
	}

	public void setCardCatalog(String cardCatalog) {
		this.cardCatalog = cardCatalog;
	}

	@Column(name = "BAL_CRYPT", nullable = false, length = 32)
	public String getBalCrypt() {
		return balCrypt;
	}

	public void setBalCrypt(String balCrypt) {
		this.balCrypt = balCrypt;
	}

	@Column(name = "REGION_CODE", nullable = false, length = 32)
	public String getRegionCode() {
		return regionCode;
	}

	public void setRegionCode(String regionCode) {
		this.regionCode = regionCode;
	}

	@Column(name = "PWD_CRYPT", nullable = false, length = 32)
	public String getPwdCrypt() {
		return pwdCrypt;
	}

	public void setPwdCrypt(String pwdCrypt) {
		this.pwdCrypt = pwdCrypt;
	}

	@Column(name = "DEAL_NO", precision = 10, scale = 0)
	public Long getDealNo() {
		return dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	public CardNo(String cardNo, String city, String cardType, String pwd,
			Long dealNo, String used, String cardCatalog, String balCrypt,
			String regionCode, String pwdCrypt) {
		super();
		this.cardNo = cardNo;
		this.city = city;
		this.cardType = cardType;
		this.pwd = pwd;
		this.dealNo = dealNo;
		this.used = used;
		this.cardCatalog = cardCatalog;
		this.balCrypt = balCrypt;
		this.regionCode = regionCode;
		this.pwdCrypt = pwdCrypt;
	}

}
