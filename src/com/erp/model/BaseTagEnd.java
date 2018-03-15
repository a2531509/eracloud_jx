package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Transient;

import com.erp.util.ExcelVOAttribute;

/**
 * BaseTagEnd entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "BASE_TAG_END")
public class BaseTagEnd implements java.io.Serializable {
	
	@ExcelVOAttribute(column="A", name="终端编号")
	private Long endId;
	@ExcelVOAttribute(column="B", name="终端名称")
	private String endName;
	@ExcelVOAttribute(column="G", name="终端类型")
	private String endType;
	@ExcelVOAttribute(column="F", name="终端用途")
	private String usage;
	@ExcelVOAttribute(column="E", name="终端来源")
	private String endSrc;
	@ExcelVOAttribute(column="D", name="终端型号")
	private String model;
	@ExcelVOAttribute(column="C", name="设备号")
	private String devNo;
	@ExcelVOAttribute(column="J", name="人社PSAM卡号")
	private String psamNo;
	@ExcelVOAttribute(column="K", name="住建PSAM卡号")
	private String psamNo2;
	@ExcelVOAttribute(column="L", name="SIM卡号")
	private String simNo;
	private String orgId;
	@ExcelVOAttribute(column="I", name="商户类型")
	private String acptType;
	@ExcelVOAttribute(column="M", name="所属商户")
	private String ownId;
	@ExcelVOAttribute(column="N", name="所属商户")
	private String ownName;
	private String loginFlag;
	private String userId;
	private Date loginTime;
	private Date lastTime;
	private String dealBatchNo;
	private Long endDealNo;
	@ExcelVOAttribute(column="H", name="角色权限编号")
	private String roleId;
	@ExcelVOAttribute(column="O", name="联系人")
	private String mngUserId;
	@ExcelVOAttribute(column="S", name="生产厂家")
	private String producer;
	@ExcelVOAttribute(column="T", name="出厂日期")
	private String standbyDateStr;
	private Date standbyDate;
	@ExcelVOAttribute(column="U", name="合同号")
	private String contractNo;
	@ExcelVOAttribute(column="V", name="采购日期")
	private String buyDateStr;
	private Date buyDate;
	@ExcelVOAttribute(column="W", name="采购单价")
	private Long price;
	private Date maintPeriod;
	@ExcelVOAttribute(column="X", name="保修厂家")
	private String maintCorp;
	@ExcelVOAttribute(column="Y", name="保修电话")
	private String maintPhone;
	@ExcelVOAttribute(column="Z", name="保修截止日期")
	private String endState;
	private Date regDate;
	private String regUserId;
	private String clsUserId;
	private Date clsDate;
	@ExcelVOAttribute(column="AA", name="备注")
	private String note;
	private String recycleDate;
	private Date recycleTime;
	private String recycleUserId;
	@ExcelVOAttribute(column="P", name="联系电话")
	private String mngUserPhone;
	@ExcelVOAttribute(column="Q", name="安装位置")
	private String insLocation;
	@ExcelVOAttribute(column="R", name="安装日期")
	private String insDateStr;
	private Date insDate;

	// Constructors

	/** default constructor */
	public BaseTagEnd() {
	}

	/** minimal constructor */
	public BaseTagEnd(Long endId) {
		this.endId = endId;
	}

	public BaseTagEnd(Long endId, String endName, String endType, String usage, String endSrc, String model,
			String devNo, String psamNo, String psamNo2, String simNo, String orgId, String acptType, String ownId,
			String loginFlag, String userId, Date loginTime, Date lastTime, String dealBatchNo, Long endDealNo,
			String roleId, String mngUserId, String producer, Date standbyDate, String contractNo, Date buyDate,
			Long price, Date maintPeriod, String maintCorp, String maintPhone, String endState, Date regDate,
			String regUserId, String clsUserId, Date clsDate, String note, String recycleDate, Date recycleTime,
			String recycleUserId, String mngUserPhone, String insLocation, Date insDate) {
		super();
		this.endId = endId;
		this.endName = endName;
		this.endType = endType;
		this.usage = usage;
		this.endSrc = endSrc;
		this.model = model;
		this.devNo = devNo;
		this.psamNo = psamNo;
		this.psamNo2 = psamNo2;
		this.simNo = simNo;
		this.orgId = orgId;
		this.acptType = acptType;
		this.ownId = ownId;
		this.loginFlag = loginFlag;
		this.userId = userId;
		this.loginTime = loginTime;
		this.lastTime = lastTime;
		this.dealBatchNo = dealBatchNo;
		this.endDealNo = endDealNo;
		this.roleId = roleId;
		this.mngUserId = mngUserId;
		this.producer = producer;
		this.standbyDate = standbyDate;
		this.contractNo = contractNo;
		this.buyDate = buyDate;
		this.price = price;
		this.maintPeriod = maintPeriod;
		this.maintCorp = maintCorp;
		this.maintPhone = maintPhone;
		this.endState = endState;
		this.regDate = regDate;
		this.regUserId = regUserId;
		this.clsUserId = clsUserId;
		this.clsDate = clsDate;
		this.note = note;
		this.recycleDate = recycleDate;
		this.recycleTime = recycleTime;
		this.recycleUserId = recycleUserId;
		this.mngUserPhone = mngUserPhone;
		this.insLocation = insLocation;
		this.insDate = insDate;
	}

	// Property accessors
	@Id
	@Column(name = "END_ID", unique = true, nullable = false, length = 10)
	public Long getEndId() {
		return this.endId;
	}

	public void setEndId(Long endId) {
		this.endId = endId;
	}

	@Column(name = "END_NAME", length = 30)
	public String getEndName() {
		return this.endName;
	}

	public void setEndName(String endName) {
		this.endName = endName;
	}

	@Column(name = "END_TYPE", length = 1)
	public String getEndType() {
		return this.endType;
	}

	public void setEndType(String endType) {
		this.endType = endType;
	}

	@Column(name = "USAGE", length = 1)
	public String getUsage() {
		return this.usage;
	}

	public void setUsage(String usage) {
		this.usage = usage;
	}

	@Column(name = "END_SRC", length = 1)
	public String getEndSrc() {
		return this.endSrc;
	}

	public void setEndSrc(String endSrc) {
		this.endSrc = endSrc;
	}

	@Column(name = "MODEL", length = 64)
	public String getModel() {
		return this.model;
	}

	public void setModel(String model) {
		this.model = model;
	}

	@Column(name = "DEV_NO", length = 30)
	public String getDevNo() {
		return this.devNo;
	}

	public void setDevNo(String devNo) {
		this.devNo = devNo;
	}

	@Column(name = "PSAM_NO", length = 20)
	public String getPsamNo() {
		return this.psamNo;
	}

	public void setPsamNo(String psamNo) {
		this.psamNo = psamNo;
	}
	
	@Column(name = "PSAM_NO2", length = 20)
	public String getPsamNo2() {
		return this.psamNo2;
	}

	public void setPsamNo2(String psamNo2) {
		this.psamNo2 = psamNo2;
	}

	@Column(name = "SIM_NO", length = 30)
	public String getSimNo() {
		return this.simNo;
	}

	public void setSimNo(String simNo) {
		this.simNo = simNo;
	}

	@Column(name = "ORG_ID", length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "ACPT_TYPE", length = 1)
	public String getAcptType() {
		return this.acptType;
	}

	public void setAcptType(String acptType) {
		this.acptType = acptType;
	}

	@Column(name = "OWN_ID", length = 16)
	public String getOwnId() {
		return this.ownId;
	}

	public void setOwnId(String ownId) {
		this.ownId = ownId;
	}

	@Column(name = "LOGIN_FLAG", length = 1)
	public String getLoginFlag() {
		return this.loginFlag;
	}

	public void setLoginFlag(String loginFlag) {
		this.loginFlag = loginFlag;
	}

	@Column(name = "USER_ID", length = 20)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "LOGIN_TIME", length = 7)
	public Date getLoginTime() {
		return this.loginTime;
	}

	public void setLoginTime(Date loginTime) {
		this.loginTime = loginTime;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "LAST_TIME", length = 7)
	public Date getLastTime() {
		return this.lastTime;
	}

	public void setLastTime(Date lastTime) {
		this.lastTime = lastTime;
	}

	@Column(name = "DEAL_BATCH_NO", length = 20)
	public String getDealBatchNo() {
		return this.dealBatchNo;
	}

	public void setDealBatchNo(String dealBatchNo) {
		this.dealBatchNo = dealBatchNo;
	}

	@Column(name = "END_DEAL_NO", precision = 22, scale = 0)
	public Long getEndDealNo() {
		return this.endDealNo;
	}

	public void setEndDealNo(Long endDealNo) {
		this.endDealNo = endDealNo;
	}

	@Column(name = "ROLE_ID", length = 6)
	public String getRoleId() {
		return this.roleId;
	}

	public void setRoleId(String roleId) {
		this.roleId = roleId;
	}

	@Column(name = "MNG_USER_ID", length = 10)
	public String getMngUserId() {
		return this.mngUserId;
	}

	public void setMngUserId(String mngUserId) {
		this.mngUserId = mngUserId;
	}

	@Column(name = "PRODUCER", length = 64)
	public String getProducer() {
		return this.producer;
	}

	public void setProducer(String producer) {
		this.producer = producer;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "STANDBY_DATE", length = 7)
	public Date getStandbyDate() {
		return this.standbyDate;
	}

	public void setStandbyDate(Date standbyDate) {
		this.standbyDate = standbyDate;
	}

	@Column(name = "CONTRACT_NO", length = 64)
	public String getContractNo() {
		return this.contractNo;
	}

	public void setContractNo(String contractNo) {
		this.contractNo = contractNo;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "BUY_DATE", length = 7)
	public Date getBuyDate() {
		return this.buyDate;
	}

	public void setBuyDate(Date buyDate) {
		this.buyDate = buyDate;
	}

	@Column(name = "PRICE", precision = 12, scale = 0)
	public Long getPrice() {
		return this.price;
	}

	public void setPrice(Long price) {
		this.price = price;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "MAINT_PERIOD", length = 7)
	public Date getMaintPeriod() {
		return this.maintPeriod;
	}

	public void setMaintPeriod(Date maintPeriod) {
		this.maintPeriod = maintPeriod;
	}

	@Column(name = "MAINT_CORP", length = 64)
	public String getMaintCorp() {
		return this.maintCorp;
	}

	public void setMaintCorp(String maintCorp) {
		this.maintCorp = maintCorp;
	}

	@Column(name = "MAINT_PHONE", length = 32)
	public String getMaintPhone() {
		return this.maintPhone;
	}

	public void setMaintPhone(String maintPhone) {
		this.maintPhone = maintPhone;
	}

	@Column(name = "END_STATE", length = 1)
	public String getEndState() {
		return this.endState;
	}

	public void setEndState(String endState) {
		this.endState = endState;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "REG_DATE", length = 7)
	public Date getRegDate() {
		return this.regDate;
	}

	public void setRegDate(Date regDate) {
		this.regDate = regDate;
	}

	@Column(name = "REG_USER_ID", length = 10)
	public String getRegUserId() {
		return this.regUserId;
	}

	public void setRegUserId(String regUserId) {
		this.regUserId = regUserId;
	}

	@Column(name = "CLS_USER_ID", length = 10)
	public String getClsUserId() {
		return this.clsUserId;
	}

	public void setClsUserId(String clsUserId) {
		this.clsUserId = clsUserId;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "CLS_DATE", length = 7)
	public Date getClsDate() {
		return this.clsDate;
	}

	public void setClsDate(Date clsDate) {
		this.clsDate = clsDate;
	}

	@Column(name = "NOTE", length = 64)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}
	
	@Column(name = "RECYCLE_DATE", length = 10)
	public String getRecycleDate() {
		return this.recycleDate;
	}

	public void setRecycleDate(String recycleDate) {
		this.recycleDate = recycleDate;
	}

	@Column(name = "RECYCLE_TIME", length = 7)
	public Date getRecycleTime() {
		return this.recycleTime;
	}

	public void setRecycleTime(Date recycleTime) {
		this.recycleTime = recycleTime;
	}

	@Column(name = "RECYCLE_USER_ID", length = 10)
	public String getRecycleUserId() {
		return this.recycleUserId;
	}

	public void setRecycleUserId(String recycleUserId) {
		this.recycleUserId = recycleUserId;
	}

	@Column(name = "MNG_USR_PHONE")
	public String getMngUserPhone() {
		return mngUserPhone;
	}

	public void setMngUserPhone(String mngUserPhone) {
		this.mngUserPhone = mngUserPhone;
	}

	@Column(name = "INS_LOCATION")
	public String getInsLocation() {
		return insLocation;
	}

	public void setInsLocation(String insLocation) {
		this.insLocation = insLocation;
	}

	@Column(name = "INS_DATE")
	@Temporal(TemporalType.TIMESTAMP)
	public Date getInsDate() {
		return insDate;
	}

	public void setInsDate(Date insDate) {
		this.insDate = insDate;
	}

	@Transient
	public String getStandbyDateStr() {
		return standbyDateStr;
	}

	public void setStandbyDateStr(String standbyDateStr) {
		this.standbyDateStr = standbyDateStr;
	}

	@Transient
	public String getBuyDateStr() {
		return buyDateStr;
	}

	public void setBuyDateStr(String buyDateStr) {
		this.buyDateStr = buyDateStr;
	}

	@Transient
	public String getInsDateStr() {
		return insDateStr;
	}

	public void setInsDateStr(String insDateStr) {
		this.insDateStr = insDateStr;
	}
	
	@Transient
	public String getOwnName() {
		return ownName;
	}

	public void setOwnName(String ownName) {
		this.ownName = ownName;
	}
}