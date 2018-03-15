package com.erp.model;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Version;

/**
 * CardTaskList entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_TASK_LIST")
@SequenceGenerator(name="SEQ_DATA_SEQ",allocationSize=1,initialValue=1,sequenceName="SEQ_DATA_SEQ" )
public class CardTaskList implements java.io.Serializable {

	// Fields

	private Long dataSeq;
	private String version;
	private String taskId;
	private String customerId;
	private String name;
	private String sex;
	private String nation;
	private String birthplace;
	private String birthday;
	private String resideType;
	private String resideAddr;
	private String letterAddr;
	private String postCode;
	private String mobileNo;
	private String education;
	private String marrState;
	private String certType;
	private String certNo;
	private String cardNo;
	private String structMainType;
	private String structChildType;
	private String cardissuedate;
	private String validitydate;
	private String bursestartdate;
	private String bursevaliddate;
	private String monthstartdate;
	private String monthvaliddate;
	private Long faceVal;
	private String pwd;
	private String barCode;
	private String commId;
	private String cardType;
	private String initOrgId;
	private String cityCode;
	private String indusCode;
	private String bursebalance;
	private String monthbalance;
	private String bankId;
	private String bankcardno;
	private String banksection2;
	private String banksection3;
	private String department;
	private String classid;
	private String photofilename;
	private Long applyId;
	private String useflag;
	private String certTyped;
	private String busUseFlag;
	private String burseValiddate;
	private String monthStartDate;
	private String monthValiddate;
	private String monthType;
	private String df01ef0729;
	private String burseBalance;
	private String monthBalance;
	private String hlhtFlag;
	private String subCardNo;
	private String touchStartdate;
	private String touchValiddate;
	private String groupId;
	private String bkvenId;

	// Constructors

	/** default constructor */
	public CardTaskList() {
	}

	/** minimal constructor */
	public CardTaskList(Long dataSeq, String taskId, String cardType) {
		this.dataSeq = dataSeq;
		this.taskId = taskId;
		this.cardType = cardType;
	}

	/** full constructor */
	public CardTaskList(Long dataSeq, String taskId, String customerId,
			String name, String sex, String nation, String birthplace,
			String birthday, String resideType, String resideAddr,
			String letterAddr, String postCode, String mobileNo,
			String education, String marrState, String certType, String certNo,
			String cardNo, String structMainType, String structChildType,
			String cardissuedate, String validitydate, String bursestartdate,
			String bursevaliddate, String monthstartdate,
			String monthvaliddate, Long faceVal, String pwd, String barCode,
			String commId, String cardType, String initOrgId, String cityCode,
			String indusCode, String bursebalance, String monthbalance,
			String bankId, String bankcardno, String banksection2,
			String banksection3, String department, String classid,
			String photofilename, Long applyId, String useflag,
			String certTyped, String busUseFlag, String burseValiddate,
			String monthStartDate, String monthValiddate, String monthType,
			String df01ef0729, String burseBalance, String monthBalance,
			String hlhtFlag, String subCardNo, String touchStartdate,
			String touchValiddate, String groupId, String bkvenId) {
		this.dataSeq = dataSeq;
		this.taskId = taskId;
		this.customerId = customerId;
		this.name = name;
		this.sex = sex;
		this.nation = nation;
		this.birthplace = birthplace;
		this.birthday = birthday;
		this.resideType = resideType;
		this.resideAddr = resideAddr;
		this.letterAddr = letterAddr;
		this.postCode = postCode;
		this.mobileNo = mobileNo;
		this.education = education;
		this.marrState = marrState;
		this.certType = certType;
		this.certNo = certNo;
		this.cardNo = cardNo;
		this.structMainType = structMainType;
		this.structChildType = structChildType;
		this.cardissuedate = cardissuedate;
		this.validitydate = validitydate;
		this.bursestartdate = bursestartdate;
		this.bursevaliddate = bursevaliddate;
		this.monthstartdate = monthstartdate;
		this.monthvaliddate = monthvaliddate;
		this.faceVal = faceVal;
		this.pwd = pwd;
		this.barCode = barCode;
		this.commId = commId;
		this.cardType = cardType;
		this.initOrgId = initOrgId;
		this.cityCode = cityCode;
		this.indusCode = indusCode;
		this.bursebalance = bursebalance;
		this.monthbalance = monthbalance;
		this.bankId = bankId;
		this.bankcardno = bankcardno;
		this.banksection2 = banksection2;
		this.banksection3 = banksection3;
		this.department = department;
		this.classid = classid;
		this.photofilename = photofilename;
		this.applyId = applyId;
		this.useflag = useflag;
		this.certTyped = certTyped;
		this.busUseFlag = busUseFlag;
		this.burseValiddate = burseValiddate;
		this.monthStartDate = monthStartDate;
		this.monthValiddate = monthValiddate;
		this.monthType = monthType;
		this.df01ef0729 = df01ef0729;
		this.burseBalance = burseBalance;
		this.monthBalance = monthBalance;
		this.hlhtFlag = hlhtFlag;
		this.subCardNo = subCardNo;
		this.touchStartdate = touchStartdate;
		this.touchValiddate = touchValiddate;
		this.groupId = groupId;
		this.bkvenId = bkvenId;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_DATA_SEQ")
	@Column(name = "DATA_SEQ", unique = true, nullable = false, precision = 38, scale = 0)
	public Long getDataSeq() {
		return this.dataSeq;
	}

	public void setDataSeq(Long dataSeq) {
		this.dataSeq = dataSeq;
	}

	@Column(name = "VERSION", length = 4)
	public String getVersion() {
		return this.version;
	}

	public void setVersion(String version) {
		this.version = version;
	}

	@Column(name = "TASK_ID", nullable = false, length = 18)
	public String getTaskId() {
		return this.taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}

	@Column(name = "CUSTOMER_ID", length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "NAME", length = 30)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "SEX", length = 1)
	public String getSex() {
		return this.sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	@Column(name = "NATION", length = 10)
	public String getNation() {
		return this.nation;
	}

	public void setNation(String nation) {
		this.nation = nation;
	}

	@Column(name = "BIRTHPLACE", length = 80)
	public String getBirthplace() {
		return this.birthplace;
	}

	public void setBirthplace(String birthplace) {
		this.birthplace = birthplace;
	}

	@Column(name = "BIRTHDAY", length = 8)
	public String getBirthday() {
		return this.birthday;
	}

	public void setBirthday(String birthday) {
		this.birthday = birthday;
	}

	@Column(name = "RESIDE_TYPE", length = 1)
	public String getResideType() {
		return this.resideType;
	}

	public void setResideType(String resideType) {
		this.resideType = resideType;
	}

	@Column(name = "RESIDE_ADDR", length = 80)
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

	@Column(name = "MOBILE_NO", length = 15)
	public String getMobileNo() {
		return this.mobileNo;
	}

	public void setMobileNo(String mobileNo) {
		this.mobileNo = mobileNo;
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

	@Column(name = "CARD_NO", length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "STRUCT_MAIN_TYPE", length = 2)
	public String getStructMainType() {
		return this.structMainType;
	}

	public void setStructMainType(String structMainType) {
		this.structMainType = structMainType;
	}

	@Column(name = "STRUCT_CHILD_TYPE", length = 2)
	public String getStructChildType() {
		return this.structChildType;
	}

	public void setStructChildType(String structChildType) {
		this.structChildType = structChildType;
	}

	@Column(name = "CARDISSUEDATE", length = 8)
	public String getCardissuedate() {
		return this.cardissuedate;
	}

	public void setCardissuedate(String cardissuedate) {
		this.cardissuedate = cardissuedate;
	}

	@Column(name = "VALIDITYDATE", length = 8)
	public String getValiditydate() {
		return this.validitydate;
	}

	public void setValiditydate(String validitydate) {
		this.validitydate = validitydate;
	}

	@Column(name = "BURSESTARTDATE", length = 8)
	public String getBursestartdate() {
		return this.bursestartdate;
	}

	public void setBursestartdate(String bursestartdate) {
		this.bursestartdate = bursestartdate;
	}

	@Column(name = "BURSEVALIDDATE", length = 8)
	public String getBursevaliddate() {
		return this.bursevaliddate;
	}

	public void setBursevaliddate(String bursevaliddate) {
		this.bursevaliddate = bursevaliddate;
	}

	@Column(name = "MONTHSTARTDATE", length = 8)
	public String getMonthstartdate() {
		return this.monthstartdate;
	}

	public void setMonthstartdate(String monthstartdate) {
		this.monthstartdate = monthstartdate;
	}

	@Column(name = "MONTHVALIDDATE", length = 8)
	public String getMonthvaliddate() {
		return this.monthvaliddate;
	}

	public void setMonthvaliddate(String monthvaliddate) {
		this.monthvaliddate = monthvaliddate;
	}

	@Column(name = "FACE_VAL", precision = 10, scale = 0)
	public Long getFaceVal() {
		return this.faceVal;
	}

	public void setFaceVal(Long faceVal) {
		this.faceVal = faceVal;
	}

	@Column(name = "PWD", length = 6)
	public String getPwd() {
		return this.pwd;
	}

	public void setPwd(String pwd) {
		this.pwd = pwd;
	}

	@Column(name = "BAR_CODE", length = 20)
	public String getBarCode() {
		return this.barCode;
	}

	public void setBarCode(String barCode) {
		this.barCode = barCode;
	}

	@Column(name = "COMM_ID", length = 15)
	public String getCommId() {
		return this.commId;
	}

	public void setCommId(String commId) {
		this.commId = commId;
	}

	@Column(name = "CARD_TYPE", nullable = false, length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "INIT_ORG_ID", length = 24)
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

	@Column(name = "BURSEBALANCE", length = 10)
	public String getBursebalance() {
		return this.bursebalance;
	}

	public void setBursebalance(String bursebalance) {
		this.bursebalance = bursebalance;
	}

	@Column(name = "MONTHBALANCE", length = 10)
	public String getMonthbalance() {
		return this.monthbalance;
	}

	public void setMonthbalance(String monthbalance) {
		this.monthbalance = monthbalance;
	}

	@Column(name = "BANK_ID", length = 4)
	public String getBankId() {
		return this.bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	@Column(name = "BANKCARDNO", length = 20)
	public String getBankcardno() {
		return this.bankcardno;
	}

	public void setBankcardno(String bankcardno) {
		this.bankcardno = bankcardno;
	}

	@Column(name = "BANKSECTION2", length = 110)
	public String getBanksection2() {
		return this.banksection2;
	}

	public void setBanksection2(String banksection2) {
		this.banksection2 = banksection2;
	}

	@Column(name = "BANKSECTION3", length = 110)
	public String getBanksection3() {
		return this.banksection3;
	}

	public void setBanksection3(String banksection3) {
		this.banksection3 = banksection3;
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

	@Column(name = "PHOTOFILENAME", length = 22)
	public String getPhotofilename() {
		return this.photofilename;
	}

	public void setPhotofilename(String photofilename) {
		this.photofilename = photofilename;
	}

	@Column(name = "APPLY_ID", precision = 38, scale = 0)
	public Long getApplyId() {
		return this.applyId;
	}

	public void setApplyId(Long applyId) {
		this.applyId = applyId;
	}

	@Column(name = "USEFLAG", length = 2)
	public String getUseflag() {
		return this.useflag;
	}

	public void setUseflag(String useflag) {
		this.useflag = useflag;
	}

	@Column(name = "CERT_TYPED", length = 2)
	public String getCertTyped() {
		return this.certTyped;
	}

	public void setCertTyped(String certTyped) {
		this.certTyped = certTyped;
	}

	@Column(name = "BUS_USE_FLAG", length = 2)
	public String getBusUseFlag() {
		return this.busUseFlag;
	}

	public void setBusUseFlag(String busUseFlag) {
		this.busUseFlag = busUseFlag;
	}

	@Column(name = "BURSE_VALIDDATE", length = 8)
	public String getBurseValiddate() {
		return this.burseValiddate;
	}

	public void setBurseValiddate(String burseValiddate) {
		this.burseValiddate = burseValiddate;
	}

	@Column(name = "MONTH_START_DATE", length = 8)
	public String getMonthStartDate() {
		return this.monthStartDate;
	}

	public void setMonthStartDate(String monthStartDate) {
		this.monthStartDate = monthStartDate;
	}

	@Column(name = "MONTH_VALIDDATE", length = 8)
	public String getMonthValiddate() {
		return this.monthValiddate;
	}

	public void setMonthValiddate(String monthValiddate) {
		this.monthValiddate = monthValiddate;
	}

	@Column(name = "MONTH_TYPE", length = 2)
	public String getMonthType() {
		return this.monthType;
	}

	public void setMonthType(String monthType) {
		this.monthType = monthType;
	}

	@Column(name = "DF01EF0729", length = 1)
	public String getDf01ef0729() {
		return this.df01ef0729;
	}

	public void setDf01ef0729(String df01ef0729) {
		this.df01ef0729 = df01ef0729;
	}

	@Column(name = "BURSE_BALANCE", length = 10)
	public String getBurseBalance() {
		return this.burseBalance;
	}

	public void setBurseBalance(String burseBalance) {
		this.burseBalance = burseBalance;
	}

	@Column(name = "MONTH_BALANCE", length = 10)
	public String getMonthBalance() {
		return this.monthBalance;
	}

	public void setMonthBalance(String monthBalance) {
		this.monthBalance = monthBalance;
	}

	@Column(name = "HLHT_FLAG", length = 10)
	public String getHlhtFlag() {
		return this.hlhtFlag;
	}

	public void setHlhtFlag(String hlhtFlag) {
		this.hlhtFlag = hlhtFlag;
	}

	@Column(name = "SUB_CARD_NO", length = 10)
	public String getSubCardNo() {
		return this.subCardNo;
	}

	public void setSubCardNo(String subCardNo) {
		this.subCardNo = subCardNo;
	}

	@Column(name = "TOUCH_STARTDATE", length = 10)
	public String getTouchStartdate() {
		return this.touchStartdate;
	}

	public void setTouchStartdate(String touchStartdate) {
		this.touchStartdate = touchStartdate;
	}

	@Column(name = "TOUCH_VALIDDATE", length = 10)
	public String getTouchValiddate() {
		return this.touchValiddate;
	}

	public void setTouchValiddate(String touchValiddate) {
		this.touchValiddate = touchValiddate;
	}

	@Column(name = "GROUP_ID", length = 20)
	public String getGroupId() {
		return this.groupId;
	}

	public void setGroupId(String groupId) {
		this.groupId = groupId;
	}

	@Column(name = "BKVEN_ID", length = 20)
	public String getBkvenId() {
		return this.bkvenId;
	}

	public void setBkvenId(String bkvenId) {
		this.bkvenId = bkvenId;
	}

}