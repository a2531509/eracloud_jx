package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * BaseSchool entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_SCHOOL")
public class BaseSchool implements java.io.Serializable {

	// Fields

	private String schoolId;
	private String schoolName;
	private String schoolAddress;
	private String schoolTel;
	private String schoolState;

	// Constructors

	/** default constructor */
	public BaseSchool() {
	}

	/** minimal constructor */
	public BaseSchool(String schoolId, String schoolTel) {
		this.schoolId = schoolId;
		this.schoolTel = schoolTel;
	}

	/** full constructor */
	public BaseSchool(String schoolId, String schoolName, String schoolAddress,
			String schoolTel, String schoolState) {
		this.schoolId = schoolId;
		this.schoolName = schoolName;
		this.schoolAddress = schoolAddress;
		this.schoolTel = schoolTel;
		this.schoolState = schoolState;
	}

	// Property accessors
	@Id
	@Column(name = "SCHOOL_ID", unique = true, nullable = false, length = 20)
	public String getSchoolId() {
		return this.schoolId;
	}

	public void setSchoolId(String schoolId) {
		this.schoolId = schoolId;
	}

	@Column(name = "SCHOOL_NAME", length = 100)
	public String getSchoolName() {
		return this.schoolName;
	}

	public void setSchoolName(String schoolName) {
		this.schoolName = schoolName;
	}

	@Column(name = "SCHOOL_ADDRESS", length = 100)
	public String getSchoolAddress() {
		return this.schoolAddress;
	}

	public void setSchoolAddress(String schoolAddress) {
		this.schoolAddress = schoolAddress;
	}

	@Column(name = "SCHOOL_TEL", nullable = false, length = 20)
	public String getSchoolTel() {
		return this.schoolTel;
	}

	public void setSchoolTel(String schoolTel) {
		this.schoolTel = schoolTel;
	}

	@Column(name = "SCHOOL_STATE", length = 1)
	public String getSchoolState() {
		return this.schoolState;
	}

	public void setSchoolState(String schoolState) {
		this.schoolState = schoolState;
	}

}