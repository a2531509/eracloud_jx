package com.erp.model;

import java.math.BigDecimal;
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
 * SysErrLog entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SYS_ERR_LOG")
@SequenceGenerator(name="SEQ_ERR_LOG_ID",allocationSize=1,initialValue=10010001,sequenceName="SEQ_ERR_NO" )
public class SysErrLog implements java.io.Serializable {

	// Fields

	private Long errNo;
	private String userId;
	private String message;
	private Date errTime;
	private String ip;
	private String errType;

	// Constructors

	/** default constructor */
	public SysErrLog() {
	}

	/** minimal constructor */
	public SysErrLog(Long errNo) {
		this.errNo = errNo;
	}

	/** full constructor */
	public SysErrLog(Long errNo, String userId, String message,
			Date errTime, String ip, String errType) {
		this.errNo = errNo;
		this.userId = userId;
		this.message = message;
		this.errTime = errTime;
		this.ip = ip;
		this.errType = errType;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_ERR_LOG_ID")
	@Column(name = "ERR_NO", unique = true, nullable = false, precision = 22, scale = 0)
	public Long getErrNo() {
		return this.errNo;
	}

	public void setErrNo(Long errNo) {
		this.errNo = errNo;
	}

	@Column(name = "User_ID", length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "MESSAGE", length = 2000)
	public String getMessage() {
		return this.message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "ERR_TIME", length = 20)
	public Date getErrTime() {
		return this.errTime;
	}

	public void setErrTime(Date errTime) {
		this.errTime = errTime;
	}

	@Column(name = "IP", length = 32)
	public String getIp() {
		return this.ip;
	}

	public void setIp(String ip) {
		this.ip = ip;
	}

	@Column(name = "ERR_TYPE", length = 8)
	public String getErrType() {
		return this.errType;
	}

	public void setErrType(String errType) {
		this.errType = errType;
	}

}