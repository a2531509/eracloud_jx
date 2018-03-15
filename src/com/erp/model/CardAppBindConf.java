package com.erp.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.NamedQuery;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
@Entity
@Table(name="CARD_APP_BIND_CONF")
@NamedQuery(name="CardAppBindConf.findAll", query="SELECT c FROM CardAppBindConf c")
public class CardAppBindConf implements Serializable {
	@Id
	@Column(name="APP_ID")
	private String appId;

	@Column(name="APP_NAME")
	private String appName;

	@Column(name="APP_STATE")
	private String appState;

	@Temporal(TemporalType.DATE)
	@Column(name="APP_VALID_DATE")
	private Date appValidDate;

	@Column(name="CARDREP_APP_FLAG")
	private String cardrepAppFlag;

	@Column(name="DEBIT_AMT")
	private BigDecimal debitAmt;

	@Column(name="DEBIT_FLAG")
	private String debitFlag;

	@Column(name="LOSS_DEAL_FLAG")
	private String lossDealFlag;

	private String note;

	@Column(name="USER_ID")
	private String userId;

	public CardAppBindConf() {
	}

	public String getAppId() {
		return this.appId;
	}

	public void setAppId(String appId) {
		this.appId = appId;
	}

	public String getAppName() {
		return this.appName;
	}

	public void setAppName(String appName) {
		this.appName = appName;
	}

	public String getAppState() {
		return this.appState;
	}

	public void setAppState(String appState) {
		this.appState = appState;
	}

	public Date getAppValidDate() {
		return this.appValidDate;
	}

	public void setAppValidDate(Date appValidDate) {
		this.appValidDate = appValidDate;
	}

	public String getCardrepAppFlag() {
		return this.cardrepAppFlag;
	}

	public void setCardrepAppFlag(String cardrepAppFlag) {
		this.cardrepAppFlag = cardrepAppFlag;
	}

	public BigDecimal getDebitAmt() {
		return this.debitAmt;
	}

	public void setDebitAmt(BigDecimal debitAmt) {
		this.debitAmt = debitAmt;
	}

	public String getDebitFlag() {
		return this.debitFlag;
	}

	public void setDebitFlag(String debitFlag) {
		this.debitFlag = debitFlag;
	}

	public String getLossDealFlag() {
		return this.lossDealFlag;
	}

	public void setLossDealFlag(String lossDealFlag) {
		this.lossDealFlag = lossDealFlag;
	}

	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}


}
