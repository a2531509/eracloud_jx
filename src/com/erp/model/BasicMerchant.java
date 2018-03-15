package com.erp.model;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * BasicMerchant entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASIC_MERCHANT")
public class BasicMerchant implements java.io.Serializable {

	// Fields

	private String clientId;
	private String orgId;
	private String bizId;
	private String bizName;
	private String bizShortName;
	private Long bizType;
	private String topBizId;
	private String indusCode;
	private String address;
	private String postCode;
	private String contact;
	private String CTelNo;
	private String CCertType;
	private String CCertNo;
	private String legName;
	private String legTelNo;
	private String legCertType;
	private String legCertNo;
	private String corporationphon;
	private String faxNum;
	private String email;
	private String hotline;
	private String taxRegNo;
	private String bizRegNo;
	private String bankId;
	private String bankBrch;
	private String bankAccName;
	private String bankAccNo;
	private String provCode;
	private String cityCode;
	private Date regDate;
	private String regOperId;
	private String contactNo;
	private String contactType;
	private String billAddr;
	private String billAddrPostcode;
	private String selfStl;
	private String privateKey;
	private String divId;
	private String servPwd;
	private Boolean servPwdErrNum;
	private String netLoginPwd;
	private Boolean netLoginPwdErrNum;
	private String note;

	// Constructors

	/** default constructor */
	public BasicMerchant() {
	}

	/** minimal constructor */
	public BasicMerchant(String clientId, String orgId, String bizId) {
		this.clientId = clientId;
		this.orgId = orgId;
		this.bizId = bizId;
	}

	/** full constructor */
	public BasicMerchant(String clientId, String orgId, String bizId,
			String bizName, String bizShortName, Long bizType, String topBizId,
			String indusCode, String address, String postCode, String contact,
			String CTelNo, String CCertType, String CCertNo, String legName,
			String legTelNo, String legCertType, String legCertNo,
			String corporationphon, String faxNum, String email,
			String hotline, String taxRegNo, String bizRegNo, String bankId,
			String bankBrch, String bankAccName, String bankAccNo,
			String provCode, String cityCode, Date regDate, String regOperId,
			String contactNo, String contactType, String billAddr,
			String billAddrPostcode, String selfStl, String privateKey,
			String divId, String servPwd, Boolean servPwdErrNum,
			String netLoginPwd, Boolean netLoginPwdErrNum, String note) {
		this.clientId = clientId;
		this.orgId = orgId;
		this.bizId = bizId;
		this.bizName = bizName;
		this.bizShortName = bizShortName;
		this.bizType = bizType;
		this.topBizId = topBizId;
		this.indusCode = indusCode;
		this.address = address;
		this.postCode = postCode;
		this.contact = contact;
		this.CTelNo = CTelNo;
		this.CCertType = CCertType;
		this.CCertNo = CCertNo;
		this.legName = legName;
		this.legTelNo = legTelNo;
		this.legCertType = legCertType;
		this.legCertNo = legCertNo;
		this.corporationphon = corporationphon;
		this.faxNum = faxNum;
		this.email = email;
		this.hotline = hotline;
		this.taxRegNo = taxRegNo;
		this.bizRegNo = bizRegNo;
		this.bankId = bankId;
		this.bankBrch = bankBrch;
		this.bankAccName = bankAccName;
		this.bankAccNo = bankAccNo;
		this.provCode = provCode;
		this.cityCode = cityCode;
		this.regDate = regDate;
		this.regOperId = regOperId;
		this.contactNo = contactNo;
		this.contactType = contactType;
		this.billAddr = billAddr;
		this.billAddrPostcode = billAddrPostcode;
		this.selfStl = selfStl;
		this.privateKey = privateKey;
		this.divId = divId;
		this.servPwd = servPwd;
		this.servPwdErrNum = servPwdErrNum;
		this.netLoginPwd = netLoginPwd;
		this.netLoginPwdErrNum = netLoginPwdErrNum;
		this.note = note;
	}

	// Property accessors
	@Id
	@Column(name = "CLIENT_ID", unique = true, nullable = false, length = 10)
	public String getClientId() {
		return this.clientId;
	}

	public void setClientId(String clientId) {
		this.clientId = clientId;
	}

	@Column(name = "ORG_ID", nullable = false, length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "BIZ_ID", nullable = false, length = 16)
	public String getBizId() {
		return this.bizId;
	}

	public void setBizId(String bizId) {
		this.bizId = bizId;
	}

	@Column(name = "BIZ_NAME", length = 128)
	public String getBizName() {
		return this.bizName;
	}

	public void setBizName(String bizName) {
		this.bizName = bizName;
	}

	@Column(name = "BIZ_SHORT_NAME", length = 128)
	public String getBizShortName() {
		return this.bizShortName;
	}

	public void setBizShortName(String bizShortName) {
		this.bizShortName = bizShortName;
	}

	@Column(name = "BIZ_TYPE", precision = 16, scale = 0)
	public Long getBizType() {
		return this.bizType;
	}

	public void setBizType(Long bizType) {
		this.bizType = bizType;
	}

	@Column(name = "TOP_BIZ_ID", length = 16)
	public String getTopBizId() {
		return this.topBizId;
	}

	public void setTopBizId(String topBizId) {
		this.topBizId = topBizId;
	}

	@Column(name = "INDUS_CODE", length = 128)
	public String getIndusCode() {
		return this.indusCode;
	}

	public void setIndusCode(String indusCode) {
		this.indusCode = indusCode;
	}

	@Column(name = "ADDRESS", length = 128)
	public String getAddress() {
		return this.address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	@Column(name = "POST_CODE", length = 6)
	public String getPostCode() {
		return this.postCode;
	}

	public void setPostCode(String postCode) {
		this.postCode = postCode;
	}

	@Column(name = "CONTACT", length = 32)
	public String getContact() {
		return this.contact;
	}

	public void setContact(String contact) {
		this.contact = contact;
	}

	@Column(name = "C_TEL_NO", length = 32)
	public String getCTelNo() {
		return this.CTelNo;
	}

	public void setCTelNo(String CTelNo) {
		this.CTelNo = CTelNo;
	}

	@Column(name = "C_CERT_TYPE", length = 1)
	public String getCCertType() {
		return this.CCertType;
	}

	public void setCCertType(String CCertType) {
		this.CCertType = CCertType;
	}

	@Column(name = "C_CERT_NO", length = 36)
	public String getCCertNo() {
		return this.CCertNo;
	}

	public void setCCertNo(String CCertNo) {
		this.CCertNo = CCertNo;
	}

	@Column(name = "LEG_NAME", length = 32)
	public String getLegName() {
		return this.legName;
	}

	public void setLegName(String legName) {
		this.legName = legName;
	}

	@Column(name = "LEG_TEL_NO", length = 32)
	public String getLegTelNo() {
		return this.legTelNo;
	}

	public void setLegTelNo(String legTelNo) {
		this.legTelNo = legTelNo;
	}

	@Column(name = "LEG_CERT_TYPE", length = 1)
	public String getLegCertType() {
		return this.legCertType;
	}

	public void setLegCertType(String legCertType) {
		this.legCertType = legCertType;
	}

	@Column(name = "LEG_CERT_NO", length = 36)
	public String getLegCertNo() {
		return this.legCertNo;
	}

	public void setLegCertNo(String legCertNo) {
		this.legCertNo = legCertNo;
	}

	@Column(name = "CORPORATIONPHON", length = 32)
	public String getCorporationphon() {
		return this.corporationphon;
	}

	public void setCorporationphon(String corporationphon) {
		this.corporationphon = corporationphon;
	}

	@Column(name = "FAX_NUM", length = 32)
	public String getFaxNum() {
		return this.faxNum;
	}

	public void setFaxNum(String faxNum) {
		this.faxNum = faxNum;
	}

	@Column(name = "EMAIL", length = 64)
	public String getEmail() {
		return this.email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	@Column(name = "HOTLINE", length = 32)
	public String getHotline() {
		return this.hotline;
	}

	public void setHotline(String hotline) {
		this.hotline = hotline;
	}

	@Column(name = "TAX_REG_NO", length = 32)
	public String getTaxRegNo() {
		return this.taxRegNo;
	}

	public void setTaxRegNo(String taxRegNo) {
		this.taxRegNo = taxRegNo;
	}

	@Column(name = "BIZ_REG_NO", length = 32)
	public String getBizRegNo() {
		return this.bizRegNo;
	}

	public void setBizRegNo(String bizRegNo) {
		this.bizRegNo = bizRegNo;
	}

	@Column(name = "BANK_ID", length = 4)
	public String getBankId() {
		return this.bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	@Column(name = "BANK_BRCH", length = 128)
	public String getBankBrch() {
		return this.bankBrch;
	}

	public void setBankBrch(String bankBrch) {
		this.bankBrch = bankBrch;
	}

	@Column(name = "BANK_ACC_NAME", length = 128)
	public String getBankAccName() {
		return this.bankAccName;
	}

	public void setBankAccName(String bankAccName) {
		this.bankAccName = bankAccName;
	}

	@Column(name = "BANK_ACC_NO", length = 24)
	public String getBankAccNo() {
		return this.bankAccNo;
	}

	public void setBankAccNo(String bankAccNo) {
		this.bankAccNo = bankAccNo;
	}

	@Column(name = "PROV_CODE", length = 2)
	public String getProvCode() {
		return this.provCode;
	}

	public void setProvCode(String provCode) {
		this.provCode = provCode;
	}

	@Column(name = "CITY_CODE", length = 6)
	public String getCityCode() {
		return this.cityCode;
	}

	public void setCityCode(String cityCode) {
		this.cityCode = cityCode;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "REG_DATE", length = 7)
	public Date getRegDate() {
		return this.regDate;
	}

	public void setRegDate(Date regDate) {
		this.regDate = regDate;
	}

	@Column(name = "REG_OPER_ID", length = 10)
	public String getRegOperId() {
		return this.regOperId;
	}

	public void setRegOperId(String regOperId) {
		this.regOperId = regOperId;
	}

	@Column(name = "CONTACT_NO", length = 100)
	public String getContactNo() {
		return this.contactNo;
	}

	public void setContactNo(String contactNo) {
		this.contactNo = contactNo;
	}

	@Column(name = "CONTACT_TYPE", length = 100)
	public String getContactType() {
		return this.contactType;
	}

	public void setContactType(String contactType) {
		this.contactType = contactType;
	}

	@Column(name = "BILL_ADDR", length = 100)
	public String getBillAddr() {
		return this.billAddr;
	}

	public void setBillAddr(String billAddr) {
		this.billAddr = billAddr;
	}

	@Column(name = "BILL_ADDR_POSTCODE", length = 100)
	public String getBillAddrPostcode() {
		return this.billAddrPostcode;
	}

	public void setBillAddrPostcode(String billAddrPostcode) {
		this.billAddrPostcode = billAddrPostcode;
	}

	@Column(name = "SELF_STL", length = 1)
	public String getSelfStl() {
		return this.selfStl;
	}

	public void setSelfStl(String selfStl) {
		this.selfStl = selfStl;
	}

	@Column(name = "PRIVATE_KEY", length = 32)
	public String getPrivateKey() {
		return this.privateKey;
	}

	public void setPrivateKey(String privateKey) {
		this.privateKey = privateKey;
	}

	@Column(name = "DIV_ID", length = 16)
	public String getDivId() {
		return this.divId;
	}

	public void setDivId(String divId) {
		this.divId = divId;
	}

	@Column(name = "SERV_PWD", length = 128)
	public String getServPwd() {
		return this.servPwd;
	}

	public void setServPwd(String servPwd) {
		this.servPwd = servPwd;
	}

	@Column(name = "SERV_PWD_ERR_NUM", precision = 1, scale = 0)
	public Boolean getServPwdErrNum() {
		return this.servPwdErrNum;
	}

	public void setServPwdErrNum(Boolean servPwdErrNum) {
		this.servPwdErrNum = servPwdErrNum;
	}

	@Column(name = "NET_LOGIN_PWD", length = 128)
	public String getNetLoginPwd() {
		return this.netLoginPwd;
	}

	public void setNetLoginPwd(String netLoginPwd) {
		this.netLoginPwd = netLoginPwd;
	}

	@Column(name = "NET_LOGIN_PWD_ERR_NUM", precision = 1, scale = 0)
	public Boolean getNetLoginPwdErrNum() {
		return this.netLoginPwdErrNum;
	}

	public void setNetLoginPwdErrNum(Boolean netLoginPwdErrNum) {
		this.netLoginPwdErrNum = netLoginPwdErrNum;
	}

	@Column(name = "NOTE", length = 64)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}