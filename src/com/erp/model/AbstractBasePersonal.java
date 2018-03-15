package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.MappedSuperclass;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
@SuppressWarnings("serial")
@MappedSuperclass
public abstract class AbstractBasePersonal implements java.io.Serializable {
//	 Fields

	private Long customerId;
	private String name;
	private String certType;
	private String certNo;
	private String birthday;
	private String gender;
	private String nation;
	private String country;
	private String resideType;
	private String cityId;
	private String regionId;
	private String townId;
	private String commId;
	private String resideAddr;
	private String letterAddr;
	private String postCode;
	private String phoneNo;
	private String telNos;
	private String mobileNo;
	private String mobileNos;
	private String email;
	private String corpCustomerId;
	private String education;
	private String marrState;
	private String career;
	private String income;
	private String customerState;
	private String servPwd;
	private String servPwdErrNum;
	private String netPwd;
	private String netPwdErrNum;
	private String openUserId;
	private Date openDate;
	private String clsUserId;
	private Date clsDate;
	private String dataSrc;
	private String sureFlag;
	private String mngUserId;
	private String department;
	private String classid;
	private Long datacenterId;
	private String memberClass;
	private String note;
	private String pinying;
	private String certValdate;//CERT_VALDATE
	private String group_Id;
	/** minimal constructor */
	public AbstractBasePersonal(Long customerId) {
		this.customerId = customerId;
	}
	
	public AbstractBasePersonal() {
		super();
	}

	/** full constructor */
	public AbstractBasePersonal(Long customerId, String name, String certType,
			String certNo, String birthday, String gender, String nation,
			String country, String resideType, String cityId, String regionId,
			String townId, String commId, String resideAddr, String letterAddr,
			String postCode, String phoneNo, String mobileNo, String email,
			String corpCustomerId, String education, String marrState,
			String career, String income, String customerState, String servPwd,
			String servPwdErrNum, String netPwd, String netPwdErrNum,
			String openUserId, Date openDate, String clsUserId, Date clsDate,
			String dataSrc, String sureFlag, String mngUserId,
			String department, String classid, Long datacenterId,
			String memberClass, String note,String pinying,String certValdate) {
		this.pinying = pinying;
		this.certValdate = certValdate;
		this.customerId = customerId;
		this.name = name;
		this.certType = certType;
		this.certNo = certNo;
		this.birthday = birthday;
		this.gender = gender;
		this.nation = nation;
		this.country = country;
		this.resideType = resideType;
		this.cityId = cityId;
		this.regionId = regionId;
		this.townId = townId;
		this.commId = commId;
		this.resideAddr = resideAddr;
		this.letterAddr = letterAddr;
		this.postCode = postCode;
		this.phoneNo = phoneNo;
		this.mobileNo = mobileNo;
		this.email = email;
		this.corpCustomerId = corpCustomerId;
		this.education = education;
		this.marrState = marrState;
		this.career = career;
		this.income = income;
		this.customerState = customerState;
		this.servPwd = servPwd;
		this.servPwdErrNum = servPwdErrNum;
		this.netPwd = netPwd;
		this.netPwdErrNum = netPwdErrNum;
		this.openUserId = openUserId;
		this.openDate = openDate;
		this.clsUserId = clsUserId;
		this.clsDate = clsDate;
		this.dataSrc = dataSrc;
		this.sureFlag = sureFlag;
		this.mngUserId = mngUserId;
		this.department = department;
		this.classid = classid;
		this.datacenterId = datacenterId;
		this.memberClass = memberClass;
		this.note = note;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_BASIC_PERSON")
	@Column(name = "CUSTOMER_ID", unique = true, nullable = false, length = 10)
	public Long getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}

	@Column(name = "NAME", length = 32)
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

	@Column(name = "CERT_NO", length = 36)
	public String getCertNo() {
		return this.certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	@Column(name = "BIRTHDAY", length = 10)
	public String getBirthday() {
		return this.birthday;
	}

	public void setBirthday(String birthday) {
		this.birthday = birthday;
	}

	@Column(name = "GENDER", length = 1)
	public String getGender() {
		return this.gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	@Column(name = "NATION", length = 2)
	public String getNation() {
		return this.nation;
	}

	public void setNation(String nation) {
		this.nation = nation;
	}

	@Column(name = "COUNTRY", length = 3)
	public String getCountry() {
		return this.country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	@Column(name = "RESIDE_TYPE", length = 1)
	public String getResideType() {
		return this.resideType;
	}

	public void setResideType(String resideType) {
		this.resideType = resideType;
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

	@Column(name = "RESIDE_ADDR", length = 200)
	public String getResideAddr() {
		return this.resideAddr;
	}

	public void setResideAddr(String resideAddr) {
		this.resideAddr = resideAddr;
	}

	@Column(name = "LETTER_ADDR", length = 200)
	public String getLetterAddr() {
		return this.letterAddr;
	}

	public void setLetterAddr(String letterAddr) {
		this.letterAddr = letterAddr;
	}

	@Column(name = "POST_CODE", length = 6)
	public String getPostCode() {
		return this.postCode;
	}

	public void setPostCode(String postCode) {
		this.postCode = postCode;
	}

	@Column(name = "PHONE_NO", length = 22)
	public String getPhoneNo() {
		return this.phoneNo;
	}

	public void setPhoneNo(String phoneNo) {
		this.phoneNo = phoneNo;
	}
	
	@Column(name = "TEL_NOS", length = 20)
	public String getTelNos() {
		return telNos;
	}

	public void setTelNos(String telNos) {
		this.telNos = telNos;
	}

	@Column(name = "MOBILE_NO", length = 11)
	public String getMobileNo() {
		return this.mobileNo;
	}

	public void setMobileNo(String mobileNo) {
		this.mobileNo = mobileNo;
	}
	
	@Column(name = "MOBILE_NOS", length = 20)
	public String getMobileNos() {
		return mobileNos;
	}

	public void setMobileNos(String mobileNos) {
		this.mobileNos = mobileNos;
	}

	@Column(name = "EMAIL", length = 32)
	public String getEmail() {
		return this.email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	@Column(name = "CORP_CUSTOMER_ID", length = 10)
	public String getCorpCustomerId() {
		return this.corpCustomerId;
	}

	public void setCorpCustomerId(String corpCustomerId) {
		this.corpCustomerId = corpCustomerId;
	}

	@Column(name = "EDUCATION", length = 2)
	public String getEducation() {
		return this.education;
	}

	public void setEducation(String education) {
		this.education = education;
	}

	@Column(name = "MARR_STATE", length = 2)
	public String getMarrState() {
		return this.marrState;
	}

	public void setMarrState(String marrState) {
		this.marrState = marrState;
	}

	@Column(name = "CAREER", length = 20)
	public String getCareer() {
		return this.career;
	}

	public void setCareer(String career) {
		this.career = career;
	}

	@Column(name = "INCOME", length = 1)
	public String getIncome() {
		return this.income;
	}

	public void setIncome(String income) {
		this.income = income;
	}

	@Column(name = "CUSTOMER_STATE", length = 1)
	public String getCustomerState() {
		return this.customerState;
	}

	public void setCustomerState(String customerState) {
		this.customerState = customerState;
	}

	@Column(name = "SERV_PWD", length = 128)
	public String getServPwd() {
		return this.servPwd;
	}

	public void setServPwd(String servPwd) {
		this.servPwd = servPwd;
	}

	@Column(name = "SERV_PWD_ERR_NUM", precision = 1, scale = 0)
	public String getServPwdErrNum() {
		return this.servPwdErrNum;
	}

	public void setServPwdErrNum(String servPwdErrNum) {
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
	public String getNetPwdErrNum() {
		return this.netPwdErrNum;
	}

	public void setNetPwdErrNum(String netPwdErrNum) {
		this.netPwdErrNum = netPwdErrNum;
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

	@Column(name = "CLS_USER_ID", length = 10)
	public String getClsUserId() {
		return this.clsUserId;
	}

	public void setClsUserId(String clsUserId) {
		this.clsUserId = clsUserId;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "CLS_DATE", length = 7)
	public Date getClsDate() {
		return this.clsDate;
	}

	public void setClsDate(Date clsDate) {
		this.clsDate = clsDate;
	}

	@Column(name = "DATA_SRC", length = 1)
	public String getDataSrc() {
		return this.dataSrc;
	}

	public void setDataSrc(String dataSrc) {
		this.dataSrc = dataSrc;
	}

	@Column(name = "SURE_FLAG", length = 1)
	public String getSureFlag() {
		return this.sureFlag;
	}

	public void setSureFlag(String sureFlag) {
		this.sureFlag = sureFlag;
	}

	@Column(name = "MNG_USER_ID", length = 10)
	public String getMngUserId() {
		return this.mngUserId;
	}

	public void setMngUserId(String mngUserId) {
		this.mngUserId = mngUserId;
	}

	@Column(name = "DEPARTMENT", length = 100)
	public String getDepartment() {
		return this.department;
	}

	public void setDepartment(String department) {
		this.department = department;
	}

	@Column(name = "CLASSID", length = 100)
	public String getClassid() {
		return this.classid;
	}

	public void setClassid(String classid) {
		this.classid = classid;
	}

	@Column(name = "DATACENTER_ID", precision = 22, scale = 0)
	public Long getDatacenterId() {
		return this.datacenterId;
	}

	public void setDatacenterId(Long datacenterId) {
		this.datacenterId = datacenterId;
	}

	@Column(name = "MEMBER_CLASS", length = 1)
	public String getMemberClass() {
		return this.memberClass;
	}

	public void setMemberClass(String memberClass) {
		this.memberClass = memberClass;
	}

	@Column(name = "NOTE", length = 256)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}
	@Column(name = "PINYING", length = 100)
	public String getPinying() {
		return this.pinying;
	}

	public void setPinying(String pinying) {
		this.pinying = pinying;
	}
	@Column(name = "CERT_VALDATE", length = 10)
	public String getCertValdate() {
		return this.certValdate;
	}

	public void setCertValdate(String certValdate) {
		this.certValdate = certValdate;
	}
	@Column(name = "GROUP_ID", length = 10)
	public String getGroup_Id() {
		return this.group_Id;
	}

	public void setGroup_Id(String group_Id) {
		this.group_Id = group_Id;
	}
}
