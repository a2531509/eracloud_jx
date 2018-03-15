package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * BaseGrade entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_GRADE")
public class BaseGrade implements java.io.Serializable {

	// Fields

	private String gradeId;
	private String gradeName;
	private String gradeState;
	private String schoolId;

	// Constructors

	/** default constructor */
	public BaseGrade() {
	}

	/** minimal constructor */
	public BaseGrade(String gradeId) {
		this.gradeId = gradeId;
	}

	/** full constructor */
	public BaseGrade(String gradeId, String gradeName, String gradeState,
			String schoolId) {
		this.gradeId = gradeId;
		this.gradeName = gradeName;
		this.gradeState = gradeState;
		this.schoolId = schoolId;
	}

	// Property accessors
	@Id
	@Column(name = "GRADE_ID", unique = true, nullable = false, length = 20)
	public String getGradeId() {
		return this.gradeId;
	}

	public void setGradeId(String gradeId) {
		this.gradeId = gradeId;
	}

	@Column(name = "GRADE_NAME", length = 200)
	public String getGradeName() {
		return this.gradeName;
	}

	public void setGradeName(String gradeName) {
		this.gradeName = gradeName;
	}

	@Column(name = "GRADE_STATE", length = 1)
	public String getGradeState() {
		return this.gradeState;
	}

	public void setGradeState(String gradeState) {
		this.gradeState = gradeState;
	}

	@Column(name = "SCHOOL_ID", length = 20)
	public String getSchoolId() {
		return this.schoolId;
	}

	public void setSchoolId(String schoolId) {
		this.schoolId = schoolId;
	}

}