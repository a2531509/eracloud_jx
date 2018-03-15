package com.erp.model;

import java.math.BigDecimal;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * CardTaskListWs entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_TASK_LIST_WS")
public class CardTaskListWs implements java.io.Serializable {

	// Fields

	private String  customerId;
	private String taskId;
	private String wsCardType;
	private String wsVersion;
	private String wsOrgname;
	private String wsOrgid;
	private String wsCertificate;
	private String wsOpertime;
	private String wsCertno1;
	private String wsSafetyCode;
	private String wsCardid;
	private String wsCitycode;
	private String wsName;
	private String wsSex;
	private String wsNation;
	private String wsBirthday;
	private String wsCertno2;
	private String wsPhoto;
	private String wsValatedate;
	private String wsMobino;
	private String wsTeleno;
	private String wsPaywayone;
	private String wsPaywaytwo;
	private String wsPaywaythree;
	private String wsAddresstypeone;
	private String wsAddressone;
	private String wsAddresstypetwo;
	private String wsAddressttwo;
	private String wsEducation;
	private String wsMarriage;
	private String wsOccupation;
	private String wsCerttype;
	private String wsCertno3;
	private String wsDomicileType;
	private String wsSgbcode;
	private String wsCity;
	private String wsArea;
	private String wsSteet;
	private String wsOrg;
	private String wsSbcardno;
	private BigDecimal wsId;
	private String wsState;
	private String wsAbono;
	private String wsRhno;
	private Long dataSeq;
	private String wsHealthno;

	// Constructors

	/** default constructor */
	public CardTaskListWs() {
	}

	

	/** full constructor */
	public CardTaskListWs(String customerId,String taskId, String wsCardType,
			String wsVersion, String wsOrgname, String wsOrgid,
			String wsCertificate, String wsOpertime, String wsCertno1,
			String wsSafetyCode, String wsCardid, String wsCitycode,
			String wsName, String wsSex, String wsNation, String wsBirthday,
			String wsCertno2, String wsPhoto, String wsValatedate,
			String wsMobino, String wsTeleno, String wsPaywayone,
			String wsPaywaytwo, String wsPaywaythree, String wsAddresstypeone,
			String wsAddressone, String wsAddresstypetwo, String wsAddressttwo,
			String wsEducation, String wsMarriage, String wsOccupation,
			String wsCerttype, String wsCertno3, String wsDomicileType,
			String wsSgbcode, String wsCity, String wsArea, String wsSteet,
			String wsOrg, String wsSbcardno, BigDecimal wsId, String wsState,
			String wsAbono, String wsRhno) {
		this.customerId = customerId;
		this.taskId = taskId;
		this.wsCardType = wsCardType;
		this.wsVersion = wsVersion;
		this.wsOrgname = wsOrgname;
		this.wsOrgid = wsOrgid;
		this.wsCertificate = wsCertificate;
		this.wsOpertime = wsOpertime;
		this.wsCertno1 = wsCertno1;
		this.wsSafetyCode = wsSafetyCode;
		this.wsCardid = wsCardid;
		this.wsCitycode = wsCitycode;
		this.wsName = wsName;
		this.wsSex = wsSex;
		this.wsNation = wsNation;
		this.wsBirthday = wsBirthday;
		this.wsCertno2 = wsCertno2;
		this.wsPhoto = wsPhoto;
		this.wsValatedate = wsValatedate;
		this.wsMobino = wsMobino;
		this.wsTeleno = wsTeleno;
		this.wsPaywayone = wsPaywayone;
		this.wsPaywaytwo = wsPaywaytwo;
		this.wsPaywaythree = wsPaywaythree;
		this.wsAddresstypeone = wsAddresstypeone;
		this.wsAddressone = wsAddressone;
		this.wsAddresstypetwo = wsAddresstypetwo;
		this.wsAddressttwo = wsAddressttwo;
		this.wsEducation = wsEducation;
		this.wsMarriage = wsMarriage;
		this.wsOccupation = wsOccupation;
		this.wsCerttype = wsCerttype;
		this.wsCertno3 = wsCertno3;
		this.wsDomicileType = wsDomicileType;
		this.wsSgbcode = wsSgbcode;
		this.wsCity = wsCity;
		this.wsArea = wsArea;
		this.wsSteet = wsSteet;
		this.wsOrg = wsOrg;
		this.wsSbcardno = wsSbcardno;
		this.wsId = wsId;
		this.wsState = wsState;
		this.wsAbono = wsAbono;
		this.wsRhno = wsRhno;
	}

	// Property accessors
	
	@Column(name = "CUSTOMER_ID", nullable = false, length = 24)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "TASK_ID", nullable = false, length = 24)
	public String getTaskId() {
		return this.taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}
	
	@Column(name = "WS_CARD_TYPE", length = 12)
	public String getWsCardType() {
		return this.wsCardType;
	}

	public void setWsCardType(String wsCardType) {
		this.wsCardType = wsCardType;
	}

	@Column(name = "WS_VERSION", length = 12)
	public String getWsVersion() {
		return this.wsVersion;
	}

	public void setWsVersion(String wsVersion) {
		this.wsVersion = wsVersion;
	}

	@Column(name = "WS_ORGNAME", length = 64)
	public String getWsOrgname() {
		return this.wsOrgname;
	}

	public void setWsOrgname(String wsOrgname) {
		this.wsOrgname = wsOrgname;
	}

	@Column(name = "WS_ORGID", length = 12)
	public String getWsOrgid() {
		return this.wsOrgid;
	}

	public void setWsOrgid(String wsOrgid) {
		this.wsOrgid = wsOrgid;
	}

	@Column(name = "WS_CERTIFICATE", length = 360)
	public String getWsCertificate() {
		return this.wsCertificate;
	}

	public void setWsCertificate(String wsCertificate) {
		this.wsCertificate = wsCertificate;
	}

	@Column(name = "WS_OPERTIME", length = 18)
	public String getWsOpertime() {
		return this.wsOpertime;
	}

	public void setWsOpertime(String wsOpertime) {
		this.wsOpertime = wsOpertime;
	}

	@Column(name = "WS_CERTNO1", length = 18)
	public String getWsCertno1() {
		return this.wsCertno1;
	}

	public void setWsCertno1(String wsCertno1) {
		this.wsCertno1 = wsCertno1;
	}

	@Column(name = "WS_SAFETY_CODE", length = 12)
	public String getWsSafetyCode() {
		return this.wsSafetyCode;
	}

	public void setWsSafetyCode(String wsSafetyCode) {
		this.wsSafetyCode = wsSafetyCode;
	}

	@Column(name = "WS_CARDID", length = 18)
	public String getWsCardid() {
		return this.wsCardid;
	}

	public void setWsCardid(String wsCardid) {
		this.wsCardid = wsCardid;
	}

	@Column(name = "WS_CITYCODE", length = 12)
	public String getWsCitycode() {
		return this.wsCitycode;
	}

	public void setWsCitycode(String wsCitycode) {
		this.wsCitycode = wsCitycode;
	}

	@Column(name = "WS_NAME", length = 64)
	public String getWsName() {
		return this.wsName;
	}

	public void setWsName(String wsName) {
		this.wsName = wsName;
	}

	@Column(name = "WS_SEX", length = 2)
	public String getWsSex() {
		return this.wsSex;
	}

	public void setWsSex(String wsSex) {
		this.wsSex = wsSex;
	}

	@Column(name = "WS_NATION", length = 2)
	public String getWsNation() {
		return this.wsNation;
	}

	public void setWsNation(String wsNation) {
		this.wsNation = wsNation;
	}

	@Column(name = "WS_BIRTHDAY", length = 12)
	public String getWsBirthday() {
		return this.wsBirthday;
	}

	public void setWsBirthday(String wsBirthday) {
		this.wsBirthday = wsBirthday;
	}

	@Column(name = "WS_CERTNO2", length = 18)
	public String getWsCertno2() {
		return this.wsCertno2;
	}

	public void setWsCertno2(String wsCertno2) {
		this.wsCertno2 = wsCertno2;
	}

	@Column(name = "WS_PHOTO", length = 64)
	public String getWsPhoto() {
		return this.wsPhoto;
	}

	public void setWsPhoto(String wsPhoto) {
		this.wsPhoto = wsPhoto;
	}

	@Column(name = "WS_VALATEDATE", length = 12)
	public String getWsValatedate() {
		return this.wsValatedate;
	}

	public void setWsValatedate(String wsValatedate) {
		this.wsValatedate = wsValatedate;
	}

	@Column(name = "WS_MOBINO", length = 12)
	public String getWsMobino() {
		return this.wsMobino;
	}

	public void setWsMobino(String wsMobino) {
		this.wsMobino = wsMobino;
	}

	@Column(name = "WS_TELENO", length = 16)
	public String getWsTeleno() {
		return this.wsTeleno;
	}

	public void setWsTeleno(String wsTeleno) {
		this.wsTeleno = wsTeleno;
	}

	@Column(name = "WS_PAYWAYONE", length = 2)
	public String getWsPaywayone() {
		return this.wsPaywayone;
	}

	public void setWsPaywayone(String wsPaywayone) {
		this.wsPaywayone = wsPaywayone;
	}

	@Column(name = "WS_PAYWAYTWO", length = 2)
	public String getWsPaywaytwo() {
		return this.wsPaywaytwo;
	}

	public void setWsPaywaytwo(String wsPaywaytwo) {
		this.wsPaywaytwo = wsPaywaytwo;
	}

	@Column(name = "WS_PAYWAYTHREE", length = 2)
	public String getWsPaywaythree() {
		return this.wsPaywaythree;
	}

	public void setWsPaywaythree(String wsPaywaythree) {
		this.wsPaywaythree = wsPaywaythree;
	}

	@Column(name = "WS_ADDRESSTYPEONE", length = 2)
	public String getWsAddresstypeone() {
		return this.wsAddresstypeone;
	}

	public void setWsAddresstypeone(String wsAddresstypeone) {
		this.wsAddresstypeone = wsAddresstypeone;
	}

	@Column(name = "WS_ADDRESSONE", length = 128)
	public String getWsAddressone() {
		return this.wsAddressone;
	}

	public void setWsAddressone(String wsAddressone) {
		this.wsAddressone = wsAddressone;
	}

	@Column(name = "WS_ADDRESSTYPETWO", length = 2)
	public String getWsAddresstypetwo() {
		return this.wsAddresstypetwo;
	}

	public void setWsAddresstypetwo(String wsAddresstypetwo) {
		this.wsAddresstypetwo = wsAddresstypetwo;
	}

	@Column(name = "WS_ADDRESSTTWO", length = 128)
	public String getWsAddressttwo() {
		return this.wsAddressttwo;
	}

	public void setWsAddressttwo(String wsAddressttwo) {
		this.wsAddressttwo = wsAddressttwo;
	}

	@Column(name = "WS_EDUCATION", length = 2)
	public String getWsEducation() {
		return this.wsEducation;
	}

	public void setWsEducation(String wsEducation) {
		this.wsEducation = wsEducation;
	}

	@Column(name = "WS_MARRIAGE", length = 2)
	public String getWsMarriage() {
		return this.wsMarriage;
	}

	public void setWsMarriage(String wsMarriage) {
		this.wsMarriage = wsMarriage;
	}

	@Column(name = "WS_OCCUPATION", length = 2)
	public String getWsOccupation() {
		return this.wsOccupation;
	}

	public void setWsOccupation(String wsOccupation) {
		this.wsOccupation = wsOccupation;
	}

	@Column(name = "WS_CERTTYPE", length = 2)
	public String getWsCerttype() {
		return this.wsCerttype;
	}

	public void setWsCerttype(String wsCerttype) {
		this.wsCerttype = wsCerttype;
	}

	@Column(name = "WS_CERTNO3", length = 18)
	public String getWsCertno3() {
		return this.wsCertno3;
	}

	public void setWsCertno3(String wsCertno3) {
		this.wsCertno3 = wsCertno3;
	}

	@Column(name = "WS_DOMICILE_TYPE", length = 2)
	public String getWsDomicileType() {
		return this.wsDomicileType;
	}

	public void setWsDomicileType(String wsDomicileType) {
		this.wsDomicileType = wsDomicileType;
	}

	@Column(name = "WS_SGBCODE", length = 12)
	public String getWsSgbcode() {
		return this.wsSgbcode;
	}

	public void setWsSgbcode(String wsSgbcode) {
		this.wsSgbcode = wsSgbcode;
	}

	@Column(name = "WS_CITY", length = 12)
	public String getWsCity() {
		return this.wsCity;
	}

	public void setWsCity(String wsCity) {
		this.wsCity = wsCity;
	}

	@Column(name = "WS_AREA", length = 12)
	public String getWsArea() {
		return this.wsArea;
	}

	public void setWsArea(String wsArea) {
		this.wsArea = wsArea;
	}

	@Column(name = "WS_STEET", length = 12)
	public String getWsSteet() {
		return this.wsSteet;
	}

	public void setWsSteet(String wsSteet) {
		this.wsSteet = wsSteet;
	}

	@Column(name = "WS_ORG", length = 64)
	public String getWsOrg() {
		return this.wsOrg;
	}

	public void setWsOrg(String wsOrg) {
		this.wsOrg = wsOrg;
	}

	@Column(name = "WS_SBCARDNO", length = 12)
	public String getWsSbcardno() {
		return this.wsSbcardno;
	}

	public void setWsSbcardno(String wsSbcardno) {
		this.wsSbcardno = wsSbcardno;
	}

	@Column(name = "WS_ID", precision = 20, scale = 0)
	public BigDecimal getWsId() {
		return this.wsId;
	}

	public void setWsId(BigDecimal wsId) {
		this.wsId = wsId;
	}

	@Column(name = "WS_STATE", length = 1)
	public String getWsState() {
		return this.wsState;
	}

	public void setWsState(String wsState) {
		this.wsState = wsState;
	}

	@Column(name = "WS_ABONO", length = 50)
	public String getWsAbono() {
		return this.wsAbono;
	}

	public void setWsAbono(String wsAbono) {
		this.wsAbono = wsAbono;
	}

	@Column(name = "WS_RHNO", length = 50)
	public String getWsRhno() {
		return this.wsRhno;
	}

	public void setWsRhno(String wsRhno) {
		this.wsRhno = wsRhno;
	}

	@Id
	@Column(name = "DATA_SEQ", length = 50)
	public Long getDataSeq() {
		return dataSeq;
	}

	public void setDataSeq(Long dataSeq) {
		this.dataSeq = dataSeq;
	}

	@Column(name = "WS_HEALTHNO", length = 50)
	public String getWsHealthno() {
		return wsHealthno;
	}

	public void setWsHealthno(String wsHealthno) {
		this.wsHealthno = wsHealthno;
	}

	
	
}