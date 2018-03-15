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

/**
 * CardApplySb entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_APPLY_SB")
@SequenceGenerator(name = "seqApplySb", sequenceName = "SEQ_SB_APPLY_ID")
public class CardApplySb implements java.io.Serializable {

	// Fields

	private String sbApplyId;
	private String companyid;
	private String empId;
	private String empName;
	private String certNo;
	private String name;
	private Date applyDate;
	private String applyName;
	private String recvBrchId;
	private String applyPici;
	private String sbApplyState;

	// Constructors

	/** default constructor */
	public CardApplySb() {
	}

	/** minimal constructor */
	public CardApplySb(String sbApplyId) {
		this.sbApplyId = sbApplyId;
	}

	/** full constructor */
	public CardApplySb(String sbApplyId, String companyid, String empId,
			String empName, String certNo, String name, Date applyDate,
			String applyName, String recvBrchId, String applyPici,
			String sbApplyState) {
		this.sbApplyId = sbApplyId;
		this.companyid = companyid;
		this.empId = empId;
		this.empName = empName;
		this.certNo = certNo;
		this.name = name;
		this.applyDate = applyDate;
		this.applyName = applyName;
		this.recvBrchId = recvBrchId;
		this.applyPici = applyPici;
		this.sbApplyState = sbApplyState;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seqApplySb")
	@Column(name = "SB_APPLY_ID", unique = true, nullable = false, length = 32)
	public String getSbApplyId() {
		return this.sbApplyId;
	}

	public void setSbApplyId(String sbApplyId) {
		this.sbApplyId = sbApplyId;
	}

	@Column(name = "COMPANYID", length = 32)
	public String getCompanyid() {
		return this.companyid;
	}

	public void setCompanyid(String companyid) {
		this.companyid = companyid;
	}

	@Column(name = "EMP_ID", length = 32)
	public String getEmpId() {
		return this.empId;
	}

	public void setEmpId(String empId) {
		this.empId = empId;
	}

	@Column(name = "EMP_NAME", length = 99)
	public String getEmpName() {
		return this.empName;
	}

	public void setEmpName(String empName) {
		this.empName = empName;
	}

	@Column(name = "CERT_NO", length = 32)
	public String getCertNo() {
		return this.certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	@Column(name = "NAME", length = 32)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "APPLY_DATE", length = 20)
	public Date getApplyDate() {
		return this.applyDate;
	}

	public void setApplyDate(Date applyDate) {
		this.applyDate = applyDate;
	}

	@Column(name = "APPLY_NAME", length = 32)
	public String getApplyName() {
		return this.applyName;
	}

	public void setApplyName(String applyName) {
		this.applyName = applyName;
	}

	@Column(name = "RECV_BRCH_ID", length = 32)
	public String getRecvBrchId() {
		return this.recvBrchId;
	}

	public void setRecvBrchId(String recvBrchId) {
		this.recvBrchId = recvBrchId;
	}

	@Column(name = "APPLY_PICI", length = 32)
	public String getApplyPici() {
		return this.applyPici;
	}

	public void setApplyPici(String applyPici) {
		this.applyPici = applyPici;
	}

	@Column(name = "SB_APPLY_STATE", length = 32)
	public String getSbApplyState() {
		return this.sbApplyState;
	}

	public void setSbApplyState(String sbApplyState) {
		this.sbApplyState = sbApplyState;
	}

}