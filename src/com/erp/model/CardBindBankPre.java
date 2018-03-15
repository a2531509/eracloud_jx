/**
 * 
 */
package com.erp.model;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * 卡片绑定银行卡
 * 
 * @author Yueh
 *
 */
@Entity
@Table(name = "card_bindbank_pre")
public class CardBindBankPre implements Serializable {
	private static final long serialVersionUID = 1L;

	@EmbeddedId
	private CardBindBankCardId id;

	@Column(name = "NAME")
	private String name;

	@Column(name = "CARD_NO")
	private String cardNo;

	@Column(name = "BANK_ID")
	private String bankId;

	@Column(name = "BANK_CARD_NO")
	private String bankCardNo;

	@Column(name = "BANK_CARD_TYPE")
	private String bankCardType;

	@Column(name = "MOBILE_NO")
	private String mobileNum;

	@Column(name = "ADDRESS")
	private String address;

	@Column(name = "USER_ID")
	private String userId;

	@Column(name = "BRCH_ID")
	private String brchId;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "DEAL_DATE")
	private Date modifyDate;

	public CardBindBankPre() {
		super();
	}

	public CardBindBankPre(CardBindBankCardId id) {
		super();
		this.id = id;
	}

	public CardBindBankPre(CardBindBankCardId id, String name, String cardNo, String bankId, String bankCardNo,
			String bankCardType, String mobileNum, String address, String userId, String brchId, Date modifyDate) {
		super();
		this.id = id;
		this.name = name;
		this.cardNo = cardNo;
		this.bankId = bankId;
		this.bankCardNo = bankCardNo;
		this.bankCardType = bankCardType;
		this.mobileNum = mobileNum;
		this.address = address;
		this.userId = userId;
		this.brchId = brchId;
		this.modifyDate = modifyDate;
	}

	public CardBindBankPre(CardBindBankCard bindInfo) {
		this.id = bindInfo.getId();
		this.name = bindInfo.getName();
		this.cardNo = bindInfo.getCardNo();
		this.bankId = bindInfo.getBankId();
		this.bankCardNo = bindInfo.getBankCardNo();
		this.bankCardType = bindInfo.getBankCardType();
		this.mobileNum = bindInfo.getMobileNum();
		this.address = bindInfo.getAddress();
		this.userId = bindInfo.getUserId();
		this.brchId = bindInfo.getBrchId();
		this.modifyDate = bindInfo.getModifyDate();
	}

	public CardBindBankCardId getId() {
		return id;
	}

	public void setId(CardBindBankCardId id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getBankId() {
		return bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	public String getBankCardNo() {
		return bankCardNo;
	}

	public void setBankCardNo(String bankCardNo) {
		this.bankCardNo = bankCardNo;
	}

	public String getBankCardType() {
		return bankCardType;
	}

	public void setBankCardType(String bankCardType) {
		this.bankCardType = bankCardType;
	}

	public String getMobileNum() {
		return mobileNum;
	}

	public void setMobileNum(String mobileNum) {
		this.mobileNum = mobileNum;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getBrchId() {
		return brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	public Date getModifyDate() {
		return modifyDate;
	}

	public void setModifyDate(Date modifyDate) {
		this.modifyDate = modifyDate;
	}
}
