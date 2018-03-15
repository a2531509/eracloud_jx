package com.erp.model;

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
import javax.persistence.UniqueConstraint;

/**
 * SysOrgan entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SYS_ORGAN", uniqueConstraints = @UniqueConstraint(columnNames = "ORG_ID"))
@SequenceGenerator(name="SEQ_SysOrgan",allocationSize=1,initialValue=10010001,sequenceName="SEQ_CLIENT_ID" )
public class SysOrgan implements java.io.Serializable {

	// Fields

	private Long customerId;
	private String orgId;
	private String orgType;
	private String orgClass;
	private String orgName;
	private String orgCode;
	private String contact;
	private String CTelNo;
	private String address;
	private String postCode;
	private String email;
	private String bankId;
	private String accNo;
	private String openOperId;
	private String note;
	private String clsOperId;
	private String openDate;
	private Date clsDate;
	private String parentOrgId;
	private String orgState;

	// Constructors

	/** default constructor */
	public SysOrgan() {
	}

	/** minimal constructor */
	public SysOrgan(Long customerId, String orgId, String orgType,
			String orgName, String bankId, String accNo, String orgState) {
		this.customerId = customerId;
		this.orgId = orgId;
		this.orgType = orgType;
		this.orgName = orgName;
		this.bankId = bankId;
		this.accNo = accNo;
		this.orgState = orgState;
	}

	/** full constructor */
	public SysOrgan(Long customerId, String orgId, String orgType,
			String orgClass, String orgName, String orgCode, String contact,
			String CTelNo, String address, String postCode, String email,
			String bankId, String accNo, String openOperId, String note,
			String clsOperId, String openDate, Date clsDate,
			String parentOrgId, String orgState) {
		this.customerId = customerId;
		this.orgId = orgId;
		this.orgType = orgType;
		this.orgClass = orgClass;
		this.orgName = orgName;
		this.orgCode = orgCode;
		this.contact = contact;
		this.CTelNo = CTelNo;
		this.address = address;
		this.postCode = postCode;
		this.email = email;
		this.bankId = bankId;
		this.accNo = accNo;
		this.openOperId = openOperId;
		this.note = note;
		this.clsOperId = clsOperId;
		this.openDate = openDate;
		this.clsDate = clsDate;
		this.parentOrgId = parentOrgId;
		this.orgState = orgState;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_SysOrgan")
	@Column(name = "CUSTOMER_ID", unique = true, nullable = false, length = 10)
	public Long getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}

	@Column(name = "ORG_ID", unique = true, nullable = false, length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "ORG_TYPE", nullable = false, length = 2)
	public String getOrgType() {
		return this.orgType;
	}

	public void setOrgType(String orgType) {
		this.orgType = orgType;
	}

	@Column(name = "ORG_CLASS", length = 1)
	public String getOrgClass() {
		return this.orgClass;
	}

	public void setOrgClass(String orgClass) {
		this.orgClass = orgClass;
	}

	@Column(name = "ORG_NAME", nullable = false, length = 128)
	public String getOrgName() {
		return this.orgName;
	}

	public void setOrgName(String orgName) {
		this.orgName = orgName;
	}

	@Column(name = "ORG_CODE", length = 128)
	public String getOrgCode() {
		return this.orgCode;
	}

	public void setOrgCode(String orgCode) {
		this.orgCode = orgCode;
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

	@Column(name = "EMAIL", length = 64)
	public String getEmail() {
		return this.email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	@Column(name = "BANK_ID", nullable = false, length = 4)
	public String getBankId() {
		return this.bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	@Column(name = "ACC_NO", nullable = false, length = 32)
	public String getAccNo() {
		return this.accNo;
	}

	public void setAccNo(String accNo) {
		this.accNo = accNo;
	}

	@Column(name = "OPEN_OPER_ID", length = 10)
	public String getOpenOperId() {
		return this.openOperId;
	}

	public void setOpenOperId(String openOperId) {
		this.openOperId = openOperId;
	}

	@Column(name = "NOTE", length = 256)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "CLS_OPER_ID", length = 10)
	public String getClsOperId() {
		return this.clsOperId;
	}

	public void setClsOperId(String clsOperId) {
		this.clsOperId = clsOperId;
	}

	@Column(name = "OPEN_DATE", length = 10)
	public String getOpenDate() {
		return this.openDate;
	}

	public void setOpenDate(String openDate) {
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

	@Column(name = "PARENT_ORG_ID", length = 4)
	public String getParentOrgId() {
		return this.parentOrgId;
	}

	public void setParentOrgId(String parentOrgId) {
		this.parentOrgId = parentOrgId;
	}

	@Column(name = "ORG_STATE", nullable = false, length = 1)
	public String getOrgState() {
		return this.orgState;
	}

	public void setOrgState(String orgState) {
		this.orgState = orgState;
	}

}