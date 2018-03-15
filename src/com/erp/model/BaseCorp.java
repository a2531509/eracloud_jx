package com.erp.model;

import java.math.BigDecimal;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * BaseCorp entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_CORP")
@SequenceGenerator(name="SEQ_CUSTOMER_ID", sequenceName="SEQ_CLIENT_ID")
public class BaseCorp implements java.io.Serializable {

	// Fields

	private String customerId;
	private String corpName;
	private String abbrName;
	private String corpType;
	private String address;
	private String postCode;
	private String contact;
	private String conPhone;
	private String ceoName;
	private String ceoPhone;
	private String legName;
	private String certType;
	private String certNo;
	private String legPhone;
	private String faxNo;
	private String email;
	private String provCode;
	private String cityCode;
	private String servPwd;
	private BigDecimal servPwdErrNum;
	private String netPwd;
	private BigDecimal netPwdErrNum;
	private Date openDate;
	private String openUserId;
	private String clsUserId;
	private Date clsDate;
	private String mngUserId;
	private String licenseNo;
	private String regionId;
	private String areaCode;
	private String PCustomerId;
	private String companyid;
	private String carrefFlag;
	private String chkFlag;
	private Date chkDate;
	private String chkUserId;
	private String note;
	private String corpState;
	private String lkBrchId;
	private String lkBrchId2;
	private String conCertNo;
	private String isBatchHf;
	private String dealNo;

	// Constructors

	/** default constructor */
	public BaseCorp() {
	}

	/** minimal constructor */
	public BaseCorp(String customerId) {
		this.customerId = customerId;
	}

	/** full constructor */
	public BaseCorp(String customerId, String corpName, String abbrName,
			String corpType, String address, String postCode, String contact,
			String conPhone, String ceoName, String ceoPhone, String legName,
			String certType, String certNo, String legPhone, String faxNo,
			String email, String provCode, String cityCode, String servPwd,
			BigDecimal servPwdErrNum, String netPwd, BigDecimal netPwdErrNum,
			Date openDate, String openUserId, String clsUserId, Date clsDate,
			String mngUserId, String licenseNo, String regionId,
			String areaCode, String PCustomerId, String companyid,
			String carrefFlag, String chkFlag, Date chkDate, String chkUserId,
			String note, String corpState, String conCertNo) {
		this.customerId = customerId;
		this.corpName = corpName;
		this.abbrName = abbrName;
		this.corpType = corpType;
		this.address = address;
		this.postCode = postCode;
		this.contact = contact;
		this.conPhone = conPhone;
		this.ceoName = ceoName;
		this.ceoPhone = ceoPhone;
		this.legName = legName;
		this.certType = certType;
		this.certNo = certNo;
		this.legPhone = legPhone;
		this.faxNo = faxNo;
		this.email = email;
		this.provCode = provCode;
		this.cityCode = cityCode;
		this.servPwd = servPwd;
		this.servPwdErrNum = servPwdErrNum;
		this.netPwd = netPwd;
		this.netPwdErrNum = netPwdErrNum;
		this.openDate = openDate;
		this.openUserId = openUserId;
		this.clsUserId = clsUserId;
		this.clsDate = clsDate;
		this.mngUserId = mngUserId;
		this.licenseNo = licenseNo;
		this.regionId = regionId;
		this.areaCode = areaCode;
		this.PCustomerId = PCustomerId;
		this.companyid = companyid;
		this.carrefFlag = carrefFlag;
		this.chkFlag = chkFlag;
		this.chkDate = chkDate;
		this.chkUserId = chkUserId;
		this.note = note;
		this.corpState = corpState;
		this.conCertNo = conCertNo;
	}

	// Property accessors
	@Id
	@Column(name = "CUSTOMER_ID", unique = true, nullable = false, length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "CORP_NAME", length = 100)
	public String getCorpName() {
		return this.corpName;
	}

	public void setCorpName(String corpName) {
		this.corpName = corpName;
	}

	@Column(name = "ABBR_NAME", length = 100)
	public String getAbbrName() {
		return this.abbrName;
	}

	public void setAbbrName(String abbrName) {
		this.abbrName = abbrName;
	}

	@Column(name = "CORP_TYPE", length = 1)
	public String getCorpType() {
		return this.corpType;
	}

	public void setCorpType(String corpType) {
		this.corpType = corpType;
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

	@Column(name = "CON_PHONE", length = 32)
	public String getConPhone() {
		return this.conPhone;
	}

	public void setConPhone(String conPhone) {
		this.conPhone = conPhone;
	}

	@Column(name = "CEO_NAME", length = 32)
	public String getCeoName() {
		return this.ceoName;
	}

	public void setCeoName(String ceoName) {
		this.ceoName = ceoName;
	}

	@Column(name = "CEO_PHONE", length = 32)
	public String getCeoPhone() {
		return this.ceoPhone;
	}

	public void setCeoPhone(String ceoPhone) {
		this.ceoPhone = ceoPhone;
	}

	@Column(name = "LEG_NAME", length = 32)
	public String getLegName() {
		return this.legName;
	}

	public void setLegName(String legName) {
		this.legName = legName;
	}

	@Column(name = "CERT_TYPE", length = 1)
	public String getCertType() {
		return this.certType;
	}

	public void setCertType(String certType) {
		this.certType = certType;
	}

	@Column(name = "CERT_NO", length = 36)
	public String getCertNo() {
		return this.certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	@Column(name = "LEG_PHONE", length = 32)
	public String getLegPhone() {
		return this.legPhone;
	}

	public void setLegPhone(String legPhone) {
		this.legPhone = legPhone;
	}

	@Column(name = "FAX_NO", length = 32)
	public String getFaxNo() {
		return this.faxNo;
	}

	public void setFaxNo(String faxNo) {
		this.faxNo = faxNo;
	}

	@Column(name = "EMAIL", length = 64)
	public String getEmail() {
		return this.email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	@Column(name = "PROV_CODE", length = 1)
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

	@Column(name = "SERV_PWD", length = 8)
	public String getServPwd() {
		return this.servPwd;
	}

	public void setServPwd(String servPwd) {
		this.servPwd = servPwd;
	}

	@Column(name = "SERV_PWD_ERR_NUM", precision = 22, scale = 0)
	public BigDecimal getServPwdErrNum() {
		return this.servPwdErrNum;
	}

	public void setServPwdErrNum(BigDecimal servPwdErrNum) {
		this.servPwdErrNum = servPwdErrNum;
	}

	@Column(name = "NET_PWD", length = 128)
	public String getNetPwd() {
		return this.netPwd;
	}

	public void setNetPwd(String netPwd) {
		this.netPwd = netPwd;
	}

	@Column(name = "NET_PWD_ERR_NUM", precision = 1, scale = 0)
	public BigDecimal getNetPwdErrNum() {
		return this.netPwdErrNum;
	}

	public void setNetPwdErrNum(BigDecimal netPwdErrNum) {
		this.netPwdErrNum = netPwdErrNum;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "OPEN_DATE", length = 7)
	public Date getOpenDate() {
		return this.openDate;
	}

	public void setOpenDate(Date openDate) {
		this.openDate = openDate;
	}

	@Column(name = "OPEN_USER_ID", length = 10)
	public String getOpenUserId() {
		return this.openUserId;
	}

	public void setOpenUserId(String openUserId) {
		this.openUserId = openUserId;
	}

	@Column(name = "CLS_USER_ID", length = 10)
	public String getClsUserId() {
		return this.clsUserId;
	}

	public void setClsUserId(String clsUserId) {
		this.clsUserId = clsUserId;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "CLS_DATE", length = 7)
	public Date getClsDate() {
		return this.clsDate;
	}

	public void setClsDate(Date clsDate) {
		this.clsDate = clsDate;
	}

	@Column(name = "MNG_USER_ID", length = 10)
	public String getMngUserId() {
		return this.mngUserId;
	}

	public void setMngUserId(String mngUserId) {
		this.mngUserId = mngUserId;
	}

	@Column(name = "LICENSE_NO", length = 64)
	public String getLicenseNo() {
		return this.licenseNo;
	}

	public void setLicenseNo(String licenseNo) {
		this.licenseNo = licenseNo;
	}

	@Column(name = "REGION_ID", length = 6)
	public String getRegionId() {
		return this.regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	@Column(name = "AREA_CODE", length = 2)
	public String getAreaCode() {
		return this.areaCode;
	}

	public void setAreaCode(String areaCode) {
		this.areaCode = areaCode;
	}

	@Column(name = "P_CUSTOMER_ID", length = 10)
	public String getPCustomerId() {
		return this.PCustomerId;
	}

	public void setPCustomerId(String PCustomerId) {
		this.PCustomerId = PCustomerId;
	}

	@Column(name = "COMPANYID", length = 20)
	public String getCompanyid() {
		return this.companyid;
	}

	public void setCompanyid(String companyid) {
		this.companyid = companyid;
	}

	@Column(name = "CARREF_FLAG", length = 1)
	public String getCarrefFlag() {
		return this.carrefFlag;
	}

	public void setCarrefFlag(String carrefFlag) {
		this.carrefFlag = carrefFlag;
	}

	@Column(name = "CHK_FLAG", length = 1)
	public String getChkFlag() {
		return this.chkFlag;
	}

	public void setChkFlag(String chkFlag) {
		this.chkFlag = chkFlag;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "CHK_DATE", length = 7)
	public Date getChkDate() {
		return this.chkDate;
	}

	public void setChkDate(Date chkDate) {
		this.chkDate = chkDate;
	}

	@Column(name = "CHK_USER_ID", length = 10)
	public String getChkUserId() {
		return this.chkUserId;
	}

	public void setChkUserId(String chkUserId) {
		this.chkUserId = chkUserId;
	}

	@Column(name = "NOTE", length = 64)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "CORP_STATE", length = 1)
	public String getCorpState() {
		return this.corpState;
	}

	public void setCorpState(String corpState) {
		this.corpState = corpState;
	}

	@Column(name = "LK_BRCH_ID", length = 20)
	public String getLkBrchId() {
		return lkBrchId;
	}

	public void setLkBrchId(String lkBrchId) {
		this.lkBrchId = lkBrchId;
	}

	/**
	 * @return the lkBrchId2
	 */
	@Column(name = "LK_BRCH_ID2", length = 20)
	public String getLkBrchId2() {
		return lkBrchId2;
	}

	/**
	 * @param lkBrchId2 the lkBrchId2 to set
	 */
	public void setLkBrchId2(String lkBrchId2) {
		this.lkBrchId2 = lkBrchId2;
	}

	@Column(name = "Con_cert_no", length = 20)
	public String getConCertNo() {
		return conCertNo;
	}

	public void setConCertNo(String conCertNo) {
		this.conCertNo = conCertNo;
	}

	@Column(name = "is_batch_hf")
	public String getIsBatchHf() {
		return isBatchHf;
	}

	public void setIsBatchHf(String isBatchHf) {
		this.isBatchHf = isBatchHf;
	}

	@Column(name = "deal_no")
	public String getDealNo() {
		return dealNo;
	}

	public void setDealNo(String dealNo) {
		this.dealNo = dealNo;
	}
}