package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;



/**
 * CardBaseinfo entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_BASEINFO")
public class CardBaseinfo implements java.io.Serializable {

	// Fields

	private String cardNo;
	private String version;
	private String cardId;
	private String customerId;
	private String cardType;
	private String issueOrgId;
	private String initOrgId;
	private String cityCode;
	private String indusCode;
	private String issueDate;
	private String startDate;
	private String validDate;
	private String app1ValidDate;
	private String app2ValidDate;
	private String payPwd;
	private Long payPwdErrNum;
	private String netPayPwd;
	private Long netPayPwdErrNum;
	private String cardState;
	private Date lastModifyDate;
	private Long costFee;
	private Long foregift;
	private Long foregiftBal;
	private Long rentForegift;
	private String subCardId;
	private String subCardNo;
	private String subCardType;
	private String bankId;
	private String bankCardNo;
	private String barCode;
	private Date cancelDate;
	private String cancelReason;
	private String note;
	private String foregiftDate;
	private String atr;
	private String rfatr;
	private String mobilePhone;
	private String mainFlag;
	private String mainCardNo;
	private String busType;
	private String busUseFlag;
	private String monthType;
	private String monthChargeMode;
	private String proOrgCode;
	private String proMediaType;
	private String proVersion;
	private String proInitDate;
	private String recoverFlag;
	private String vipClass;
	private String bankActiveState;

	// Constructors

	/** default constructor */
	public CardBaseinfo() {
	}

	/** minimal constructor */
	public CardBaseinfo(String cardNo, String cardId) {
		this.cardNo = cardNo;
		this.cardId = cardId;
	}

	/** full constructor */
	public CardBaseinfo(String cardNo, String cardId, String customerId,
			String cardType, String issueOrgId, String initOrgId,
			String cityCode, String indusCode, String issueDate,
			String startDate, String validDate, String app1ValidDate,
			String app2ValidDate, String payPwd, Long payPwdErrNum,
			String netPayPwd, Long netPayPwdErrNum, String cardState,
			Date lastModifyDate, Long costFee, Long foregift, Long foregiftBal,
			Long rentForegift, String subCardId, String subCardNo,
			String subCardType, String bankId, String bankCardNo,
			String barCode, Date cancelDate, String cancelReason, String note,
			String foregiftDate, String atr, String rfatr, String mobilePhone,
			String mainFlag, String mainCardNo, String busType,
			String busUseFlag, String monthType, String monthChargeMode,
			String proOrgCode, String proMediaType, String proVersion,
			String proInitDate, String recoverFlag, String vipClass) {
		this.cardNo = cardNo;
		this.cardId = cardId;
		this.customerId = customerId;
		this.cardType = cardType;
		this.issueOrgId = issueOrgId;
		this.initOrgId = initOrgId;
		this.cityCode = cityCode;
		this.indusCode = indusCode;
		this.issueDate = issueDate;
		this.startDate = startDate;
		this.validDate = validDate;
		this.app1ValidDate = app1ValidDate;
		this.app2ValidDate = app2ValidDate;
		this.payPwd = payPwd;
		this.payPwdErrNum = payPwdErrNum;
		this.netPayPwd = netPayPwd;
		this.netPayPwdErrNum = netPayPwdErrNum;
		this.cardState = cardState;
		this.lastModifyDate = lastModifyDate;
		this.costFee = costFee;
		this.foregift = foregift;
		this.foregiftBal = foregiftBal;
		this.rentForegift = rentForegift;
		this.subCardId = subCardId;
		this.subCardNo = subCardNo;
		this.subCardType = subCardType;
		this.bankId = bankId;
		this.bankCardNo = bankCardNo;
		this.barCode = barCode;
		this.cancelDate = cancelDate;
		this.cancelReason = cancelReason;
		this.note = note;
		this.foregiftDate = foregiftDate;
		this.atr = atr;
		this.rfatr = rfatr;
		this.mobilePhone = mobilePhone;
		this.mainFlag = mainFlag;
		this.mainCardNo = mainCardNo;
		this.busType = busType;
		this.busUseFlag = busUseFlag;
		this.monthType = monthType;
		this.monthChargeMode = monthChargeMode;
		this.proOrgCode = proOrgCode;
		this.proMediaType = proMediaType;
		this.proVersion = proVersion;
		this.proInitDate = proInitDate;
		this.recoverFlag = recoverFlag;
		this.vipClass = vipClass;
	}

	// Property accessors
	@Id
	@Column(name = "CARD_NO", unique = true, nullable = false, length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "VERSION", length = 4)
	public String getVersion() {
		return this.version;
	}

	public void setVersion(String version) {
		this.version = version;
	}

	@Column(name = "CARD_ID", nullable = false, length = 50)
	public String getCardId() {
		return this.cardId;
	}

	public void setCardId(String cardId) {
		this.cardId = cardId;
	}

	@Column(name = "CUSTOMER_ID", length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "CARD_TYPE", length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "ISSUE_ORG_ID", length = 4)
	public String getIssueOrgId() {
		return this.issueOrgId;
	}

	public void setIssueOrgId(String issueOrgId) {
		this.issueOrgId = issueOrgId;
	}

	@Column(name = "INIT_ORG_ID", length = 128)
	public String getInitOrgId() {
		return this.initOrgId;
	}

	public void setInitOrgId(String initOrgId) {
		this.initOrgId = initOrgId;
	}

	@Column(name = "CITY_CODE", length = 10)
	public String getCityCode() {
		return this.cityCode;
	}

	public void setCityCode(String cityCode) {
		this.cityCode = cityCode;
	}

	@Column(name = "INDUS_CODE", length = 10)
	public String getIndusCode() {
		return this.indusCode;
	}

	public void setIndusCode(String indusCode) {
		this.indusCode = indusCode;
	}

	@Column(name = "ISSUE_DATE", length = 8)
	public String getIssueDate() {
		return this.issueDate;
	}

	public void setIssueDate(String issueDate) {
		this.issueDate = issueDate;
	}

	@Column(name = "START_DATE", length = 20)
	public String getStartDate() {
		return this.startDate;
	}

	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}

	@Column(name = "VALID_DATE", length = 8)
	public String getValidDate() {
		return this.validDate;
	}

	public void setValidDate(String validDate) {
		this.validDate = validDate;
	}

	@Column(name = "APP1_VALID_DATE", length = 10)
	public String getApp1ValidDate() {
		return this.app1ValidDate;
	}

	public void setApp1ValidDate(String app1ValidDate) {
		this.app1ValidDate = app1ValidDate;
	}

	@Column(name = "APP2_VALID_DATE", length = 10)
	public String getApp2ValidDate() {
		return this.app2ValidDate;
	}

	public void setApp2ValidDate(String app2ValidDate) {
		this.app2ValidDate = app2ValidDate;
	}

	@Column(name = "PAY_PWD", length = 128)
	public String getPayPwd() {
		return this.payPwd;
	}

	public void setPayPwd(String payPwd) {
		this.payPwd = payPwd;
	}

	@Column(name = "PAY_PWD_ERR_NUM", precision = 1, scale = 0)
	public Long getPayPwdErrNum() {
		return this.payPwdErrNum;
	}

	public void setPayPwdErrNum(Long payPwdErrNum) {
		this.payPwdErrNum = payPwdErrNum;
	}

	@Column(name = "NET_PAY_PWD", length = 128)
	public String getNetPayPwd() {
		return this.netPayPwd;
	}

	public void setNetPayPwd(String netPayPwd) {
		this.netPayPwd = netPayPwd;
	}

	@Column(name = "NET_PAY_PWD_ERR_NUM", precision = 1, scale = 0)
	public Long getNetPayPwdErrNum() {
		return this.netPayPwdErrNum;
	}

	public void setNetPayPwdErrNum(Long netPayPwdErrNum) {
		this.netPayPwdErrNum = netPayPwdErrNum;
	}

	@Column(name = "CARD_STATE", length = 1)
	public String getCardState() {
		return this.cardState;
	}

	public void setCardState(String cardState) {
		this.cardState = cardState;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "LAST_MODIFY_DATE", length = 7)
	public Date getLastModifyDate() {
		return this.lastModifyDate;
	}

	public void setLastModifyDate(Date lastModifyDate) {
		this.lastModifyDate = lastModifyDate;
	}

	@Column(name = "COST_FEE", precision = 16, scale = 0)
	public Long getCostFee() {
		return this.costFee;
	}

	public void setCostFee(Long costFee) {
		this.costFee = costFee;
	}

	@Column(name = "FOREGIFT", precision = 16, scale = 0)
	public Long getForegift() {
		return this.foregift;
	}

	public void setForegift(Long foregift) {
		this.foregift = foregift;
	}

	@Column(name = "FOREGIFT_BAL", precision = 16, scale = 0)
	public Long getForegiftBal() {
		return this.foregiftBal;
	}

	public void setForegiftBal(Long foregiftBal) {
		this.foregiftBal = foregiftBal;
	}

	@Column(name = "RENT_FOREGIFT", precision = 16, scale = 0)
	public Long getRentForegift() {
		return this.rentForegift;
	}

	public void setRentForegift(Long rentForegift) {
		this.rentForegift = rentForegift;
	}

	@Column(name = "SUB_CARD_ID", length = 32)
	public String getSubCardId() {
		return this.subCardId;
	}

	public void setSubCardId(String subCardId) {
		this.subCardId = subCardId;
	}

	@Column(name = "SUB_CARD_NO", length = 20)
	public String getSubCardNo() {
		return this.subCardNo;
	}

	public void setSubCardNo(String subCardNo) {
		this.subCardNo = subCardNo;
	}

	@Column(name = "SUB_CARD_TYPE", length = 3)
	public String getSubCardType() {
		return this.subCardType;
	}

	public void setSubCardType(String subCardType) {
		this.subCardType = subCardType;
	}

	@Column(name = "BANK_ID", length = 4)
	public String getBankId() {
		return this.bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	@Column(name = "BANK_CARD_NO", length = 20)
	public String getBankCardNo() {
		return this.bankCardNo;
	}

	public void setBankCardNo(String bankCardNo) {
		this.bankCardNo = bankCardNo;
	}

	@Column(name = "BAR_CODE", length = 20)
	public String getBarCode() {
		return this.barCode;
	}

	public void setBarCode(String barCode) {
		this.barCode = barCode;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "CANCEL_DATE", length = 7)
	public Date getCancelDate() {
		return this.cancelDate;
	}

	public void setCancelDate(Date cancelDate) {
		this.cancelDate = cancelDate;
	}

	@Column(name = "CANCEL_REASON", length = 1)
	public String getCancelReason() {
		return this.cancelReason;
	}

	public void setCancelReason(String cancelReason) {
		this.cancelReason = cancelReason;
	}

	@Column(name = "NOTE", length = 128)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "FOREGIFT_DATE", length = 10)
	public String getForegiftDate() {
		return this.foregiftDate;
	}

	public void setForegiftDate(String foregiftDate) {
		this.foregiftDate = foregiftDate;
	}

	@Column(name = "ATR", length = 34)
	public String getAtr() {
		return this.atr;
	}

	public void setAtr(String atr) {
		this.atr = atr;
	}

	@Column(name = "RFATR", length = 50)
	public String getRfatr() {
		return this.rfatr;
	}

	public void setRfatr(String rfatr) {
		this.rfatr = rfatr;
	}

	@Column(name = "MOBILE_PHONE", length = 32)
	public String getMobilePhone() {
		return this.mobilePhone;
	}

	public void setMobilePhone(String mobilePhone) {
		this.mobilePhone = mobilePhone;
	}

	@Column(name = "MAIN_FLAG", length = 1)
	public String getMainFlag() {
		return this.mainFlag;
	}

	public void setMainFlag(String mainFlag) {
		this.mainFlag = mainFlag;
	}

	@Column(name = "MAIN_CARD_NO", length = 20)
	public String getMainCardNo() {
		return this.mainCardNo;
	}

	public void setMainCardNo(String mainCardNo) {
		this.mainCardNo = mainCardNo;
	}

	@Column(name = "BUS_TYPE", length = 2)
	public String getBusType() {
		return this.busType;
	}

	public void setBusType(String busType) {
		this.busType = busType;
	}

	@Column(name = "BUS_USE_FLAG", length = 2)
	public String getBusUseFlag() {
		return this.busUseFlag;
	}

	public void setBusUseFlag(String busUseFlag) {
		this.busUseFlag = busUseFlag;
	}

	@Column(name = "MONTH_TYPE", length = 2)
	public String getMonthType() {
		return this.monthType;
	}

	public void setMonthType(String monthType) {
		this.monthType = monthType;
	}

	@Column(name = "MONTH_CHARGE_MODE", length = 2)
	public String getMonthChargeMode() {
		return this.monthChargeMode;
	}

	public void setMonthChargeMode(String monthChargeMode) {
		this.monthChargeMode = monthChargeMode;
	}

	@Column(name = "PRO_ORG_CODE", length = 32)
	public String getProOrgCode() {
		return this.proOrgCode;
	}

	public void setProOrgCode(String proOrgCode) {
		this.proOrgCode = proOrgCode;
	}

	@Column(name = "PRO_MEDIA_TYPE", length = 1)
	public String getProMediaType() {
		return this.proMediaType;
	}

	public void setProMediaType(String proMediaType) {
		this.proMediaType = proMediaType;
	}

	@Column(name = "PRO_VERSION", length = 4)
	public String getProVersion() {
		return this.proVersion;
	}

	public void setProVersion(String proVersion) {
		this.proVersion = proVersion;
	}

	@Column(name = "PRO_INIT_DATE", length = 8)
	public String getProInitDate() {
		return this.proInitDate;
	}

	public void setProInitDate(String proInitDate) {
		this.proInitDate = proInitDate;
	}

	@Column(name = "RECOVER_FLAG", length = 1)
	public String getRecoverFlag() {
		return this.recoverFlag;
	}

	public void setRecoverFlag(String recoverFlag) {
		this.recoverFlag = recoverFlag;
	}

	@Column(name = "VIP_CLASS", length = 1)
	public String getVipClass() {
		return this.vipClass;
	}

	public void setVipClass(String vipClass) {
		this.vipClass = vipClass;
	}

	@Column(name = "BANK_ACTIVATE_STATE")
	public String getBankActiveState() {
		return bankActiveState;
	}

	public void setBankActiveState(String bankActiveState) {
		this.bankActiveState = bankActiveState;
	}
}