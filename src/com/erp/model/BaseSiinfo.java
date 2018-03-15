package com.erp.model;

import java.util.Date;
import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * 统筹区域信息。
 */
@Entity
@Table(name = "BASE_SIINFO")
public class BaseSiinfo implements java.io.Serializable {

	private static final long serialVersionUID = 1L;

	private BaseSiinfoId id;
	private String companyId;
	private String customerId;
	private String name;
	private String certType;
	private String certNo;
	private Date birthday;
	private String gender;
	private String endowState;
	private String medState;
	private String injuryState;
	private String bearState;
	private String unempState;
	private String medCertNo;
	private String reserve1;
	private String reserve2;
	private String reserve3;
	private String reserve4;
	private String reserve5;
	private String reserve6;
	private String reserve7;
	private String reserve8;
	private String reserve9;
	private String reserve10;
	private String reserve11;
	private String reserve12;
	private String reserve13;
	private String reserve14;
	private String reserve15;
	private String reserve16;
	private String reserve17;
	private String reserve18;
	private String reserve19;
	private String reserve20;

	public BaseSiinfo() {
	}

	public BaseSiinfo(BaseSiinfoId id, String customerId) {
		this.id = id;
		this.customerId = customerId;
	}

	public BaseSiinfo(BaseSiinfoId id, String companyId, String customerId, String name, String certType, String certNo,
			Date birthday, String gender, String endowState, String medState, String injuryState, String bearState,
			String unempState, String medCertNo, String reserve1, String reserve2, String reserve3, String reserve4,
			String reserve5, String reserve6, String reserve7, String reserve8, String reserve9, String reserve10,
			String reserve11, String reserve12, String reserve13, String reserve14, String reserve15, String reserve16,
			String reserve17, String reserve18, String reserve19, String reserve20) {
		this.id = id;
		this.companyId = companyId;
		this.customerId = customerId;
		this.name = name;
		this.certType = certType;
		this.certNo = certNo;
		this.birthday = birthday;
		this.gender = gender;
		this.endowState = endowState;
		this.medState = medState;
		this.injuryState = injuryState;
		this.bearState = bearState;
		this.unempState = unempState;
		this.medCertNo = medCertNo;
		this.reserve1 = reserve1;
		this.reserve2 = reserve2;
		this.reserve3 = reserve3;
		this.reserve4 = reserve4;
		this.reserve5 = reserve5;
		this.reserve6 = reserve6;
		this.reserve7 = reserve7;
		this.reserve8 = reserve8;
		this.reserve9 = reserve9;
		this.reserve10 = reserve10;
		this.reserve11 = reserve11;
		this.reserve12 = reserve12;
		this.reserve13 = reserve13;
		this.reserve14 = reserve14;
		this.reserve15 = reserve15;
		this.reserve16 = reserve16;
		this.reserve17 = reserve17;
		this.reserve18 = reserve18;
		this.reserve19 = reserve19;
		this.reserve20 = reserve20;
	}

	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "personalId", column = @Column(name = "PERSONAL_ID", nullable = false, length = 18) ),
			@AttributeOverride(name = "medWholeNo", column = @Column(name = "MED_WHOLE_NO", nullable = false, length = 32) ) })
	public BaseSiinfoId getId() {
		return this.id;
	}

	public void setId(BaseSiinfoId id) {
		this.id = id;
	}

	@Column(name = "COMPANY_ID", length = 20)
	public String getCompanyId() {
		return this.companyId;
	}

	public void setCompanyId(String companyId) {
		this.companyId = companyId;
	}

	@Column(name = "CUSTOMER_ID", nullable = false, length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "NAME", length = 60)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "CERT_TYPE", length = 1)
	public String getCertType() {
		return this.certType;
	}

	public void setCertType(String certType) {
		this.certType = certType;
	}

	@Column(name = "CERT_NO", length = 32)
	public String getCertNo() {
		return this.certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	@Column(name = "BIRTHDAY", length = 7)
	public Date getBirthday() {
		return this.birthday;
	}

	public void setBirthday(Date birthday) {
		this.birthday = birthday;
	}

	@Column(name = "GENDER", length = 1)
	public String getGender() {
		return this.gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	@Column(name = "ENDOW_STATE", length = 2)
	public String getEndowState() {
		return this.endowState;
	}

	public void setEndowState(String endowState) {
		this.endowState = endowState;
	}

	@Column(name = "MED_STATE", length = 2)
	public String getMedState() {
		return this.medState;
	}

	public void setMedState(String medState) {
		this.medState = medState;
	}

	@Column(name = "INJURY_STATE", length = 2)
	public String getInjuryState() {
		return this.injuryState;
	}

	public void setInjuryState(String injuryState) {
		this.injuryState = injuryState;
	}

	@Column(name = "BEAR_STATE", length = 2)
	public String getBearState() {
		return this.bearState;
	}

	public void setBearState(String bearState) {
		this.bearState = bearState;
	}

	@Column(name = "UNEMP_STATE", length = 2)
	public String getUnempState() {
		return this.unempState;
	}

	public void setUnempState(String unempState) {
		this.unempState = unempState;
	}

	@Column(name = "MED_CERT_NO", length = 32)
	public String getMedCertNo() {
		return this.medCertNo;
	}

	public void setMedCertNo(String medCertNo) {
		this.medCertNo = medCertNo;
	}

	@Column(name = "RESERVE_1", length = 200)
	public String getReserve1() {
		return this.reserve1;
	}

	public void setReserve1(String reserve1) {
		this.reserve1 = reserve1;
	}

	@Column(name = "RESERVE_2", length = 200)
	public String getReserve2() {
		return this.reserve2;
	}

	public void setReserve2(String reserve2) {
		this.reserve2 = reserve2;
	}

	@Column(name = "RESERVE_3", length = 200)
	public String getReserve3() {
		return this.reserve3;
	}

	public void setReserve3(String reserve3) {
		this.reserve3 = reserve3;
	}

	@Column(name = "RESERVE_4", length = 200)
	public String getReserve4() {
		return this.reserve4;
	}

	public void setReserve4(String reserve4) {
		this.reserve4 = reserve4;
	}

	@Column(name = "RESERVE_5", length = 200)
	public String getReserve5() {
		return this.reserve5;
	}

	public void setReserve5(String reserve5) {
		this.reserve5 = reserve5;
	}

	@Column(name = "RESERVE_6", length = 200)
	public String getReserve6() {
		return this.reserve6;
	}

	public void setReserve6(String reserve6) {
		this.reserve6 = reserve6;
	}

	@Column(name = "RESERVE_7", length = 200)
	public String getReserve7() {
		return this.reserve7;
	}

	public void setReserve7(String reserve7) {
		this.reserve7 = reserve7;
	}

	@Column(name = "RESERVE_8", length = 200)
	public String getReserve8() {
		return this.reserve8;
	}

	public void setReserve8(String reserve8) {
		this.reserve8 = reserve8;
	}

	@Column(name = "RESERVE_9", length = 200)
	public String getReserve9() {
		return this.reserve9;
	}

	public void setReserve9(String reserve9) {
		this.reserve9 = reserve9;
	}

	@Column(name = "RESERVE_10", length = 200)
	public String getReserve10() {
		return this.reserve10;
	}

	public void setReserve10(String reserve10) {
		this.reserve10 = reserve10;
	}

	@Column(name = "RESERVE_11", length = 200)
	public String getReserve11() {
		return this.reserve11;
	}

	public void setReserve11(String reserve11) {
		this.reserve11 = reserve11;
	}

	@Column(name = "RESERVE_12", length = 200)
	public String getReserve12() {
		return this.reserve12;
	}

	public void setReserve12(String reserve12) {
		this.reserve12 = reserve12;
	}

	@Column(name = "RESERVE_13", length = 200)
	public String getReserve13() {
		return this.reserve13;
	}

	public void setReserve13(String reserve13) {
		this.reserve13 = reserve13;
	}

	@Column(name = "RESERVE_14", length = 200)
	public String getReserve14() {
		return this.reserve14;
	}

	public void setReserve14(String reserve14) {
		this.reserve14 = reserve14;
	}

	@Column(name = "RESERVE_15", length = 200)
	public String getReserve15() {
		return this.reserve15;
	}

	public void setReserve15(String reserve15) {
		this.reserve15 = reserve15;
	}

	@Column(name = "RESERVE_16", length = 200)
	public String getReserve16() {
		return this.reserve16;
	}

	public void setReserve16(String reserve16) {
		this.reserve16 = reserve16;
	}

	@Column(name = "RESERVE_17", length = 200)
	public String getReserve17() {
		return this.reserve17;
	}

	public void setReserve17(String reserve17) {
		this.reserve17 = reserve17;
	}

	@Column(name = "RESERVE_18", length = 200)
	public String getReserve18() {
		return this.reserve18;
	}

	public void setReserve18(String reserve18) {
		this.reserve18 = reserve18;
	}

	@Column(name = "RESERVE_19", length = 200)
	public String getReserve19() {
		return this.reserve19;
	}

	public void setReserve19(String reserve19) {
		this.reserve19 = reserve19;
	}

	@Column(name = "RESERVE_20", length = 4000)
	public String getReserve20() {
		return this.reserve20;
	}

	public void setReserve20(String reserve20) {
		this.reserve20 = reserve20;
	}

}