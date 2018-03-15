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
 * SysActionLog entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "SYS_ACTION_LOG")
@SequenceGenerator(name="SEQ_SYSDealNo",allocationSize=1,initialValue=1,sequenceName="seq_action_no" )
public class SysActionLog implements java.io.Serializable {

	// Fields

	private Long dealNo;
	private Integer dealCode;
	private String orgId;
	private String brchId;
	private String userId;
	private Date dealTime;
	private String logType;
	private String funcUrl;
	private String funcName;
	private String message;
	private String ip;
	private String inOutData;
	private String canRoll;
	private String rollFlag;
	private String other;
	private String note;
	private String coOrgId;

	// Constructors

	/** default constructor */
	public SysActionLog(){
	}

	/** minimal constructor */
	public SysActionLog(Long dealNo){
		this.dealNo = dealNo;
	}

	/** full constructor */
	public SysActionLog(Long dealNo, Integer trCode, String orgId,
			String brchId, String userId, Date dealTime, String logType,
			String funcUrl, String funcName, String message, String ip,
			String inOutData, String canRoll, String rollFlag, String other,
			String note,String coOrgId) {
		this.dealNo = dealNo;
		this.dealCode = trCode;
		this.orgId = orgId;
		this.brchId = brchId;
		this.userId = userId;
		this.dealTime = dealTime;
		this.logType = logType;
		this.funcUrl = funcUrl;
		this.funcName = funcName;
		this.message = message;
		this.ip = ip;
		this.inOutData = inOutData;
		this.canRoll = canRoll;
		this.rollFlag = rollFlag;
		this.other = other;
		this.note = note;
		this.coOrgId = coOrgId;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_SYSDealNo")
	@Column(name = "DEAL_NO", unique = true, nullable = false, precision = 22, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "DEAL_CODE", precision = 8, scale = 0)
	public Integer getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(Integer trCode) {
		this.dealCode = trCode;
	}

	@Column(name = "ORG_ID", length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "BRCH_ID", length = 8)
	public String getBrchId() {
		return this.brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	@Column(name = "USER_ID", length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "DEAL_TIME", length = 7)
	public Date getDealTime() {
		return this.dealTime;
	}

	public void setDealTime(Date dealTime) {
		this.dealTime = dealTime;
	}

	@Column(name = "LOG_TYPE", length = 1)
	public String getLogType() {
		return this.logType;
	}

	public void setLogType(String logType) {
		this.logType = logType;
	}

	@Column(name = "FUNC_URL", length = 128)
	public String getFuncUrl() {
		return this.funcUrl;
	}

	public void setFuncUrl(String funcUrl) {
		this.funcUrl = funcUrl;
	}

	@Column(name = "FUNC_NAME", length = 128)
	public String getFuncName() {
		return this.funcName;
	}

	public void setFuncName(String funcName) {
		this.funcName = funcName;
	}

	@Column(name = "MESSAGE", length = 556)
	public String getMessage() {
		return this.message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	@Column(name = "IP", length = 32)
	public String getIp() {
		return this.ip;
	}

	public void setIp(String ip) {
		this.ip = ip;
	}

	@Column(name = "IN_OUT_DATA", length = 2000)
	public String getInOutData() {
		return this.inOutData;
	}

	public void setInOutData(String inOutData) {
		this.inOutData = inOutData;
	}

	@Column(name = "CAN_ROLL", length = 1)
	public String getCanRoll() {
		return this.canRoll;
	}

	public void setCanRoll(String canRoll) {
		this.canRoll = canRoll;
	}

	@Column(name = "ROLL_FLAG", length = 1)
	public String getRollFlag() {
		return this.rollFlag;
	}

	public void setRollFlag(String rollFlag) {
		this.rollFlag = rollFlag;
	}

	@Column(name = "OTHER", length = 128)
	public String getOther() {
		return this.other;
	}

	public void setOther(String other) {
		this.other = other;
	}

	@Column(name = "NOTE", length = 128)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "co_org_id", length = 128)
	public String getCoOrgId() {
		return coOrgId;
	}

	public void setCoOrgId(String coOrgId) {
		this.coOrgId = coOrgId;
	}
	
	
	
}