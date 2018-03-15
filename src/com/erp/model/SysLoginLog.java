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
 * SysLoginLog entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SYS_LOGIN_LOG")
@SequenceGenerator(name="SEQ_SYS_LOGIN_LOG",allocationSize=1,initialValue=10010089,sequenceName="SEQ_LOGIN_NO" )
public class SysLoginLog implements java.io.Serializable {

	// Fields

	private Long loginNo;
	private String termId;
	private String operTermId;
	private String pwd;
	private String ip;
	private Date logonTime;
	private Date logoffTime;
	private String userType;
	private String logType;
	private String loginBatchNo;
	private String loginClrDate;
	private String loginErro;

	// Constructors



	/** default constructor */
	public SysLoginLog() {
	}

	/** minimal constructor */
	public SysLoginLog(Long loginNo) {
		this.loginNo = loginNo;
	}

	/** full constructor */
	public SysLoginLog(Long loginNo, String termId, String operTermId,
			String pwd, String ip, Date logonTime, Date logoffTime,
			String userType, String logType, String loginBatchNo,
			String loginClrDate,String loginErro) {
		this.loginNo = loginNo;
		this.termId = termId;
		this.operTermId = operTermId;
		this.pwd = pwd;
		this.ip = ip;
		this.logonTime = logonTime;
		this.logoffTime = logoffTime;
		this.userType = userType;
		this.logType = logType;
		this.loginBatchNo = loginBatchNo;
		this.loginClrDate = loginClrDate;
		this.loginErro = loginErro;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_SYS_LOGIN_LOG")
	@Column(name = "LOGIN_NO", unique = true, nullable = false, precision = 38, scale = 0)
	public Long getLoginNo() {
		return this.loginNo;
	}

	public void setLoginNo(Long loginNo) {
		this.loginNo = loginNo;
	}

	@Column(name = "TERM_ID", length = 10)
	public String getTermId() {
		return this.termId;
	}

	public void setTermId(String termId) {
		this.termId = termId;
	}

	@Column(name = "OPER_TERM_ID", length = 10)
	public String getOperTermId() {
		return this.operTermId;
	}

	public void setOperTermId(String operTermId) {
		this.operTermId = operTermId;
	}

	@Column(name = "PWD", length = 128)
	public String getPwd() {
		return this.pwd;
	}

	public void setPwd(String pwd) {
		this.pwd = pwd;
	}

	@Column(name = "IP", length = 32)
	public String getIp() {
		return this.ip;
	}

	public void setIp(String ip) {
		this.ip = ip;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "LOGON_TIME", length = 20)
	public Date getLogonTime() {
		return this.logonTime;
	}

	public void setLogonTime(Date logonTime) {
		this.logonTime = logonTime;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "LOGOFF_TIME", length = 20)
	public Date getLogoffTime() {
		return this.logoffTime;
	}

	public void setLogoffTime(Date logoffTime) {
		this.logoffTime = logoffTime;
	}

	@Column(name = "USER_TYPE", length = 1)
	public String getUserType() {
		return this.userType;
	}

	public void setUserType(String userType) {
		this.userType = userType;
	}

	@Column(name = "LOG_TYPE", length = 1)
	public String getLogType() {
		return this.logType;
	}

	public void setLogType(String logType) {
		this.logType = logType;
	}

	@Column(name = "LOGIN_BATCH_NO", length = 30)
	public String getLoginBatchNo() {
		return this.loginBatchNo;
	}

	public void setLoginBatchNo(String loginBatchNo) {
		this.loginBatchNo = loginBatchNo;
	}

	@Column(name = "LOGIN_CLR_DATE", length = 10)
	public String getLoginClrDate() {
		return this.loginClrDate;
	}

	public void setLoginClrDate(String loginClrDate) {
		this.loginClrDate = loginClrDate;
	}
	
	@Column(name = "LOGIN_ERRO", length = 100)
	public String getLoginErro() {
		return loginErro;
	}

	public void setLoginErro(String loginErro) {
		this.loginErro = loginErro;
	}

}