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
 * PointsRule entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "POINTS_RULE")
@SequenceGenerator(name="SEQ_PointsRule",allocationSize=1,initialValue=10010089,sequenceName="seq_points_rule" )
public class PointsRule implements java.io.Serializable {

	// Fields

	private Long id;
	private String dealCode;
	private String pointType;
	private String pointGdValue;
	private String pointBlValue;
	private String pointMaxValue;
	private String pointMinValue;
	private String state;
	private String insertUser;
	private Date insertDate;

	// Constructors

	/** default constructor */
	public PointsRule() {
	}

	/** minimal constructor */
	public PointsRule(Long id) {
		this.id = id;
	}

	/** full constructor */
	public PointsRule(Long id, String dealCode, String pointType,
			String pointGdValue, String pointBlValue, String pointMaxValue,
			String pointMinValue, String state, String insertUser,
			Date insertDate) {
		this.id = id;
		this.dealCode = dealCode;
		this.pointType = pointType;
		this.pointGdValue = pointGdValue;
		this.pointBlValue = pointBlValue;
		this.pointMaxValue = pointMaxValue;
		this.pointMinValue = pointMinValue;
		this.state = state;
		this.insertUser = insertUser;
		this.insertDate = insertDate;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_PointsRule")
	@Column(name = "ID", unique = true, nullable = false, precision = 16, scale = 0)
	public Long getId() {
		return this.id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Column(name = "DEAL_CODE", length = 8)
	public String getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(String dealCode) {
		this.dealCode = dealCode;
	}

	@Column(name = "POINT_TYPE", length = 1)
	public String getPointType() {
		return this.pointType;
	}

	public void setPointType(String pointType) {
		this.pointType = pointType;
	}

	@Column(name = "POINT_GD_VALUE", length = 10)
	public String getPointGdValue() {
		return this.pointGdValue;
	}

	public void setPointGdValue(String pointGdValue) {
		this.pointGdValue = pointGdValue;
	}

	@Column(name = "POINT_BL_VALUE", length = 10)
	public String getPointBlValue() {
		return this.pointBlValue;
	}

	public void setPointBlValue(String pointBlValue) {
		this.pointBlValue = pointBlValue;
	}

	@Column(name = "POINT_MAX_VALUE", length = 10)
	public String getPointMaxValue() {
		return this.pointMaxValue;
	}

	public void setPointMaxValue(String pointMaxValue) {
		this.pointMaxValue = pointMaxValue;
	}

	@Column(name = "POINT_MIN_VALUE", length = 10)
	public String getPointMinValue() {
		return this.pointMinValue;
	}

	public void setPointMinValue(String pointMinValue) {
		this.pointMinValue = pointMinValue;
	}

	@Column(name = "STATE", length = 1)
	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

	@Column(name = "INSERT_USER", length = 12)
	public String getInsertUser() {
		return this.insertUser;
	}

	public void setInsertUser(String insertUser) {
		this.insertUser = insertUser;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "INSERT_DATE", length = 7)
	public Date getInsertDate() {
		return this.insertDate;
	}

	public void setInsertDate(Date insertDate) {
		this.insertDate = insertDate;
	}

}