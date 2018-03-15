package com.erp.model;

import java.math.BigDecimal;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * AccAccountSub entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "ACC_ACCOUNT_SUB")
@SequenceGenerator(name="SEQ_ACCOUNT_SUB",sequenceName="seq_acc_sub_ledger" )
public class AccAccountSub implements java.io.Serializable {

	// Fields

	private Long accNo;
	private String customerId;
	private String customerType;
	private String cardNo;
	private String cardType;
	private String accName;
	private Long bal;
	private String balCrypt;
	private Long creditLmt;
	private String balRslt;
	private String itemId;
	private String balType;
	private String accKind;
	private Long frzAmt;
	private Date lssDate;
	private String frzFlag;
	private Date frzDate;
	private String lastDealDate;
	private String orgId;
	private String openBrchId;
	private String openUserId;
	private Date openDate;
	private Date clsDate;
	private String clsUserId;
	private String accState;
	private String walletNo;

	// Constructors

	/** default constructor */
	public AccAccountSub() {
	}

	/** minimal constructor */
	public AccAccountSub(Long accNo, String balType, String accKind,
			String frzFlag, String accState) {
		this.accNo = accNo;
		this.balType = balType;
		this.accKind = accKind;
		this.frzFlag = frzFlag;
		this.accState = accState;
	}

	/** full constructor */
	public AccAccountSub(Long accNo, String customerId,
			String customerType, String cardNo, String cardType,
			String accName, Long bal, String balCrypt, Long creditLmt,
			String balRslt, String itemId, String balType, String accKind,
			Long frzAmt, Date lssDate, String frzFlag, Date frzDate,
			String lastDealDate, String orgId, String openBrchId,
			String openUserId, Date openDate, Date clsDate, String clsUserId,
			String accState, String walletNo) {
		this.accNo = accNo;
		this.customerId = customerId;
		this.customerType = customerType;
		this.cardNo = cardNo;
		this.cardType = cardType;
		this.accName = accName;
		this.bal = bal;
		this.balCrypt = balCrypt;
		this.creditLmt = creditLmt;
		this.balRslt = balRslt;
		this.itemId = itemId;
		this.balType = balType;
		this.accKind = accKind;
		this.frzAmt = frzAmt;
		this.lssDate = lssDate;
		this.frzFlag = frzFlag;
		this.frzDate = frzDate;
		this.lastDealDate = lastDealDate;
		this.orgId = orgId;
		this.openBrchId = openBrchId;
		this.openUserId = openUserId;
		this.openDate = openDate;
		this.clsDate = clsDate;
		this.clsUserId = clsUserId;
		this.accState = accState;
		this.walletNo = walletNo;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_ACCOUNT_SUB")
	@Column(name = "ACC_NO", unique = true, nullable = false, precision = 22, scale = 0)
	public Long getAccNo() {
		return this.accNo;
	}

	public void setAccNo(Long accNo) {
		this.accNo = accNo;
	}

	@Column(name = "CUSTOMER_ID", length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "CUSTOMER_TYPE", length = 1)
	public String getCustomerType() {
		return this.customerType;
	}

	public void setCustomerType(String customerType) {
		this.customerType = customerType;
	}

	@Column(name = "CARD_NO", length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "CARD_TYPE", length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "ACC_NAME", length = 128)
	public String getAccName() {
		return this.accName;
	}

	public void setAccName(String accName) {
		this.accName = accName;
	}

	@Column(name = "BAL", precision = 16, scale = 0)
	public Long getBal() {
		return this.bal;
	}

	public void setBal(Long bal) {
		this.bal = bal;
	}

	@Column(name = "BAL_CRYPT", length = 128)
	public String getBalCrypt() {
		return this.balCrypt;
	}

	public void setBalCrypt(String balCrypt) {
		this.balCrypt = balCrypt;
	}

	@Column(name = "CREDIT_LMT", precision = 16, scale = 0)
	public Long getCreditLmt() {
		return this.creditLmt;
	}

	public void setCreditLmt(Long creditLmt) {
		this.creditLmt = creditLmt;
	}

	@Column(name = "BAL_RSLT", length = 1)
	public String getBalRslt() {
		return this.balRslt;
	}

	public void setBalRslt(String balRslt) {
		this.balRslt = balRslt;
	}

	@Column(name = "ITEM_ID", length = 6)
	public String getItemId() {
		return this.itemId;
	}

	public void setItemId(String itemId) {
		this.itemId = itemId;
	}

	@Column(name = "BAL_TYPE", nullable = false, length = 1)
	public String getBalType() {
		return this.balType;
	}

	public void setBalType(String balType) {
		this.balType = balType;
	}

	@Column(name = "ACC_KIND", nullable = false, length = 2)
	public String getAccKind() {
		return this.accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	@Column(name = "FRZ_AMT", precision = 16, scale = 0)
	public Long getFrzAmt() {
		return this.frzAmt;
	}

	public void setFrzAmt(Long frzAmt) {
		this.frzAmt = frzAmt;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "LSS_DATE", length = 7)
	public Date getLssDate() {
		return this.lssDate;
	}

	public void setLssDate(Date lssDate) {
		this.lssDate = lssDate;
	}

	@Column(name = "FRZ_FLAG", nullable = false, length = 1)
	public String getFrzFlag() {
		return this.frzFlag;
	}

	public void setFrzFlag(String frzFlag) {
		this.frzFlag = frzFlag;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "FRZ_DATE", length = 7)
	public Date getFrzDate() {
		return this.frzDate;
	}

	public void setFrzDate(Date frzDate) {
		this.frzDate = frzDate;
	}

	@Column(name = "LAST_DEAL_DATE", length = 20)
	public String getLastDealDate() {
		return this.lastDealDate;
	}

	public void setLastDealDate(String lastDealDate) {
		this.lastDealDate = lastDealDate;
	}

	@Column(name = "ORG_ID", length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "OPEN_BRCH_ID", length = 8)
	public String getOpenBrchId() {
		return this.openBrchId;
	}

	public void setOpenBrchId(String openBrchId) {
		this.openBrchId = openBrchId;
	}

	@Column(name = "OPEN_USER_ID", length = 10)
	public String getOpenUserId() {
		return this.openUserId;
	}

	public void setOpenUserId(String openUserId) {
		this.openUserId = openUserId;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "OPEN_DATE", length = 7)
	public Date getOpenDate() {
		return this.openDate;
	}

	public void setOpenDate(Date openDate) {
		this.openDate = openDate;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "CLS_DATE", length = 7)
	public Date getClsDate() {
		return this.clsDate;
	}

	public void setClsDate(Date clsDate) {
		this.clsDate = clsDate;
	}

	@Column(name = "CLS_USER_ID", length = 10)
	public String getClsUserId() {
		return this.clsUserId;
	}

	public void setClsUserId(String clsUserId) {
		this.clsUserId = clsUserId;
	}

	@Column(name = "ACC_STATE", nullable = false, length = 1)
	public String getAccState() {
		return this.accState;
	}

	public void setAccState(String accState) {
		this.accState = accState;
	}

	@Column(name = "WALLET_NO", length = 2)
	public String getWalletNo() {
		return this.walletNo;
	}

	public void setWalletNo(String walletNo) {
		this.walletNo = walletNo;
	}

}