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
import javax.persistence.Transient;

import com.erp.util.Constants;
import com.erp.util.ExcelVOAttribute;

/**
 * 卡片绑定银行卡
 * 
 * @author Yueh
 *
 */
@Entity
@Table(name = "card_bind_bankcard")
public class CardBindBankCard implements Serializable {
	private static final long serialVersionUID = 1L;

	@EmbeddedId
	private CardBindBankCardId id;

	@Column(name = "CUSTOMER_ID")
	private String customerId;

	@ExcelVOAttribute(column = "B", name = "证件号码")
	@Transient
	private String certNo;

	@Column(name = "CARD_NO")
	private String cardNo;

	@ExcelVOAttribute(column = "C", name = "市民卡号")
	@Transient
	private String subCardNo;

	@ExcelVOAttribute(column = "A", name = "姓名")
	@Column(name = "NAME")
	private String name;

	@ExcelVOAttribute(column = "D", name = "银行编号")
	@Column(name = "BANK_ID")
	private String bankId;

	@Transient
	private String bankName;

	@ExcelVOAttribute(column = "E", name = "银行卡号")
	@Column(name = "BANK_CARD_NO")
	private String bankCardNo;

	@Column(name = "BANK_CARD_TYPE")
	private String bankCardType;

	@ExcelVOAttribute(column = "I", name = "绑定状态")
	@Column(name = "STATE")
	private String state;

	@ExcelVOAttribute(column = "F", name = "手机号码")
	@Column(name = "MOBILE_NUM")
	private String mobileNum;

	@Column(name = "CITY_ID")
	private String cityId;

	@Column(name = "REGION_ID")
	private String regionId;

	@Column(name = "TOWN_ID")
	private String townId;

	@Column(name = "COMM_ID")
	private String commId;

	@ExcelVOAttribute(column = "H", name = "联系地址")
	@Column(name = "ADDRESS")
	private String address;

	@Column(name = "USER_ID")
	private String userId;

	@Column(name = "BRCH_ID")
	private String brchId;

	@Column(name = "BANK_ORG")
	private String bankOrg;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "ACTIVATE_DATE")
	private Date activateDate;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "MODIFY_DATE")
	private Date modifyDate;

	@ExcelVOAttribute(column = "G", name = "联行号")
	@Column(name = "LINE_NO")
	private Long lineNo;

	@Column(name = "SUB_CARD_ID")
	private String subCardId;

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "BIND_DATE")
	private Date bindDate;

	@Transient
	private String bindDateStr;

	@Transient
	private String failReason;
	
	@Column(name = "SBBH")
	private String sbbh;

	@Column(name = "TCQ")
	private String tcq;
	
	@Column(name = "BANK_ACTIVATE_STATE")
	private String bankActiveState;

	public CardBindBankCard() {
		super();
		id = new CardBindBankCardId();
	}

	public CardBindBankCard(String certNo, String cardNo, String subCardNo,
			String name, String bankName, String bankCardNo, String state,
			String bindDateStr) {
		super();
		this.certNo = certNo;
		this.cardNo = cardNo;
		this.subCardNo = subCardNo;
		this.name = name;
		this.bankName = bankName;
		this.bankCardNo = bankCardNo;
		this.state = state;
		this.bindDateStr = bindDateStr;
	}

	public CardBindBankCard(CardBindBankCardId id) {
		super();
		this.id = id;
	}

	public CardBindBankCard(CardBindBankCardId id, String customerId,
			String name, String bankId, String bankCardNo, String bankCardType,
			String state, String mobileNum, String cityId, String regionId,
			String townId, String commId, String address, String userId,
			String brchId, String bankOrg, Date activateDate, Date modifyDate,
			Long lineNo, String subCardId, Date bindDate) {
		super();
		this.id = id;
		this.customerId = customerId;
		this.name = name;
		this.bankId = bankId;
		this.bankCardNo = bankCardNo;
		this.bankCardType = bankCardType;
		this.state = state;
		this.mobileNum = mobileNum;
		this.cityId = cityId;
		this.regionId = regionId;
		this.townId = townId;
		this.commId = commId;
		this.address = address;
		this.userId = userId;
		this.brchId = brchId;
		this.bankOrg = bankOrg;
		this.activateDate = activateDate;
		this.modifyDate = modifyDate;
		this.lineNo = lineNo;
		this.subCardId = subCardId;
		this.bindDate = bindDate;
	}

	public CardBindBankCardId getId() {
		return id;
	}

	public void setId(CardBindBankCardId id) {
		this.id = id;
	}

	public String getCustomerId() {
		return customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
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

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getMobileNum() {
		return mobileNum;
	}

	public void setMobileNum(String mobileNum) {
		this.mobileNum = mobileNum;
	}

	public String getCityId() {
		return cityId;
	}

	public void setCityId(String cityId) {
		this.cityId = cityId;
	}

	public String getRegionId() {
		return regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	public String getTownId() {
		return townId;
	}

	public void setTownId(String townId) {
		this.townId = townId;
	}

	public String getCommId() {
		return commId;
	}

	public void setCommId(String commId) {
		this.commId = commId;
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

	public String getBankOrg() {
		return bankOrg;
	}

	public void setBankOrg(String bankOrg) {
		this.bankOrg = bankOrg;
	}

	public Date getActivateDate() {
		return activateDate;
	}

	public void setActivateDate(Date activateDate) {
		this.activateDate = activateDate;
	}

	public Date getModifyDate() {
		return modifyDate;
	}

	public void setModifyDate(Date modifyDate) {
		this.modifyDate = modifyDate;
	}

	public Long getLineNo() {
		return lineNo;
	}

	public void setLineNo(Long lineNo) {
		this.lineNo = lineNo;
	}

	public String getSubCardId() {
		return subCardId;
	}

	public void setSubCardId(String subCardId) {
		this.subCardId = subCardId;
	}

	public Date getBindDate() {
		return bindDate;
	}

	public void setBindDate(Date bindDate) {
		this.bindDate = bindDate;
	}

	public String getFailReason() {
		return failReason;
	}

	public void setFailReason(String failReason) {
		this.failReason = failReason;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getSubCardNo() {
		return subCardNo;
	}

	public void setSubCardNo(String subCardNo) {
		this.subCardNo = subCardNo;
	}

	public String getBankName() {
		return bankName;
	}

	public void setBankName(String bankName) {
		this.bankName = bankName;
	}

	public String getBindDateStr() {
		return bindDateStr;
	}

	public void setBindDateStr(String bindDateStr) {
		this.bindDateStr = bindDateStr;
	}
	
	public String getSbbh() {
		return sbbh;
	}

	public void setSbbh(String sbbh) {
		this.sbbh = sbbh;
	}

	public String getTcq() {
		return tcq;
	}

	public void setTcq(String tcq) {
		this.tcq = tcq;
	}

	/**
	 * @return
	 */
	public String getStateText() {
		if (Constants.CARD_BIND_BANKCARD_STATE_BIND.equals(state)) {
			return "已绑定未开通圈存";
		} else if (Constants.CARD_BIND_BANKCARD_STATE_BIND_AND_ZZQC.equals(state)) {
			return "自主圈存";
		} else if (Constants.CARD_BIND_BANKCARD_STATE_BIND_AND_ZZQC_AND_SSQC.equals(state)) {
			return "自主圈存 + 实时圈存";
		} else {
			return "未开通";
		}
	}

	public String getBankActiveState() {
		return bankActiveState;
	}

	public void setBankActiveState(String bankActiveState) {
		this.bankActiveState = bankActiveState;
	}
}
