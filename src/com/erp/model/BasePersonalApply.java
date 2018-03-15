package com.erp.model;

import java.math.BigDecimal;
import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * BasePersonalApply entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "BASE_PERSONAL_APPLY")
public class BasePersonalApply implements java.io.Serializable {

	// Fields

	private BasePersonalApplyId id;
	private String companyid;
	private String cityId;
	private String regionId;
	private String townId;
	private String commId;
	private Long wsId;
	private Long sbId;
	private String note;
	private String applyBankId;
	private String applyVenId;
	private String bankCardNo;
	private String bdFlag;
	private String orgId;
	private String yhFlag;

	// Constructors

	/** default constructor */
	public BasePersonalApply() {
	}

	/** minimal constructor */
	public BasePersonalApply(BasePersonalApplyId id) {
		this.id = id;
	}

	/** full constructor */
	public BasePersonalApply(BasePersonalApplyId id, String companyid,
			String cityId, String regionId, String townId, String commId,
			Long wsId, Long sbId, String note, String applyBankId,
			String applyVenId, String bankCardNo, String bdFlag, String orgId,
			String yhFlag) {
		this.id = id;
		this.companyid = companyid;
		this.cityId = cityId;
		this.regionId = regionId;
		this.townId = townId;
		this.commId = commId;
		this.wsId = wsId;
		this.sbId = sbId;
		this.note = note;
		this.applyBankId = applyBankId;
		this.applyVenId = applyVenId;
		this.bankCardNo = bankCardNo;
		this.bdFlag = bdFlag;
		this.orgId = orgId;
		this.yhFlag = yhFlag;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "customerId", column = @Column(name = "CUSTOMER_ID", nullable = false, length = 18)),
			@AttributeOverride(name = "userId", column = @Column(name = "USER_ID", nullable = false, length = 10)) })
	public BasePersonalApplyId getId() {
		return this.id;
	}

	public void setId(BasePersonalApplyId id) {
		this.id = id;
	}

	@Column(name = "COMPANYID", length = 20)
	public String getCompanyid() {
		return this.companyid;
	}

	public void setCompanyid(String companyid) {
		this.companyid = companyid;
	}

	@Column(name = "CITY_ID", length = 6)
	public String getCityId() {
		return this.cityId;
	}

	public void setCityId(String cityId) {
		this.cityId = cityId;
	}

	@Column(name = "REGION_ID", length = 6)
	public String getRegionId() {
		return this.regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	@Column(name = "TOWN_ID", length = 15)
	public String getTownId() {
		return this.townId;
	}

	public void setTownId(String townId) {
		this.townId = townId;
	}

	@Column(name = "COMM_ID", length = 15)
	public String getCommId() {
		return this.commId;
	}

	public void setCommId(String commId) {
		this.commId = commId;
	}

	@Column(name = "WS_ID", precision = 20, scale = 0)
	public Long getWsId() {
		return this.wsId;
	}

	public void setWsId(Long wsId) {
		this.wsId = wsId;
	}

	@Column(name = "SB_ID", precision = 20, scale = 0)
	public Long getSbId() {
		return this.sbId;
	}

	public void setSbId(Long sbId) {
		this.sbId = sbId;
	}

	@Column(name = "NOTE", length = 800)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "APPLY_BANK_ID", length = 8)
	public String getApplyBankId() {
		return this.applyBankId;
	}

	public void setApplyBankId(String applyBankId) {
		this.applyBankId = applyBankId;
	}

	@Column(name = "APPLY_VEN_ID", length = 8)
	public String getApplyVenId() {
		return this.applyVenId;
	}

	public void setApplyVenId(String applyVenId) {
		this.applyVenId = applyVenId;
	}

	@Column(name = "BANK_CARD_NO", length = 20)
	public String getBankCardNo() {
		return this.bankCardNo;
	}

	public void setBankCardNo(String bankCardNo) {
		this.bankCardNo = bankCardNo;
	}

	@Column(name = "BD_FLAG", length = 1)
	public String getBdFlag() {
		return this.bdFlag;
	}

	public void setBdFlag(String bdFlag) {
		this.bdFlag = bdFlag;
	}

	@Column(name = "ORG_ID", length = 10)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "YH_FLAG", length = 1)
	public String getYhFlag() {
		return this.yhFlag;
	}

	public void setYhFlag(String yhFlag) {
		this.yhFlag = yhFlag;
	}

}