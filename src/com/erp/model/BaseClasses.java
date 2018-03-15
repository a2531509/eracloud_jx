package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * BaseClasses entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_CLASSES")
public class BaseClasses implements java.io.Serializable {

	// Fields

	private String classesId;
	private String classesName;
	private String classesState;
	private String gradeId;

	// Constructors

	/** default constructor */
	public BaseClasses() {
	}

	/** minimal constructor */
	public BaseClasses(String classesId) {
		this.classesId = classesId;
	}

	/** full constructor */
	public BaseClasses(String classesId, String classesName,
			String classesState, String gradeId) {
		this.classesId = classesId;
		this.classesName = classesName;
		this.classesState = classesState;
		this.gradeId = gradeId;
	}

	// Property accessors
	@Id
	@Column(name = "CLASSES_ID", unique = true, nullable = false, length = 20)
	public String getClassesId() {
		return this.classesId;
	}

	public void setClassesId(String classesId) {
		this.classesId = classesId;
	}

	@Column(name = "CLASSES_NAME", length = 100)
	public String getClassesName() {
		return this.classesName;
	}

	public void setClassesName(String classesName) {
		this.classesName = classesName;
	}

	@Column(name = "CLASSES_STATE", length = 1)
	public String getClassesState() {
		return this.classesState;
	}

	public void setClassesState(String classesState) {
		this.classesState = classesState;
	}

	@Column(name = "GRADE_ID", length = 20)
	public String getGradeId() {
		return this.gradeId;
	}

	public void setGradeId(String gradeId) {
		this.gradeId = gradeId;
	}

}