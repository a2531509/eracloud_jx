package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

/**
 * AccStateTradingBan entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "ACC_STATE_TRADING_BAN", uniqueConstraints = @UniqueConstraint(columnNames = {
		"CARD_TYPE", "ACC_KIND", "ACC_STATE", "BAN_DEAL_CODE" }))
public class AccStateTradingBan implements java.io.Serializable {

	// Fields

	private Long id;
	private String accState;
	private String banDealCode;
	private String state;
	private String note;
	private String cardType;
	private String accKind;

	// Constructors

	/** default constructor */
	public AccStateTradingBan() {
	}

	/** minimal constructor */
	public AccStateTradingBan(String accState, String banDealCode, String state) {
		this.accState = accState;
		this.banDealCode = banDealCode;
		this.state = state;
	}

	/** full constructor */
	public AccStateTradingBan(String accState, String banDealCode,
			String state, String note, String cardType, String accKind) {
		this.accState = accState;
		this.banDealCode = banDealCode;
		this.state = state;
		this.note = note;
		this.cardType = cardType;
		this.accKind = accKind;
	}

	// Property accessors
	@Id
	@GeneratedValue
	@Column(name = "ID", unique = true, nullable = false, precision = 16, scale = 0)
	public Long getId() {
		return this.id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Column(name = "ACC_STATE", nullable = false, length = 1)
	public String getAccState() {
		return this.accState;
	}

	public void setAccState(String accState) {
		this.accState = accState;
	}

	@Column(name = "BAN_DEAL_CODE", nullable = false, length = 2000)
	public String getBanDealCode() {
		return this.banDealCode;
	}

	public void setBanDealCode(String banDealCode) {
		this.banDealCode = banDealCode;
	}

	@Column(name = "STATE", nullable = false, length = 1)
	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

	@Column(name = "NOTE", length = 2000)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "CARD_TYPE", length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "ACC_KIND", length = 2)
	public String getAccKind() {
		return this.accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

}