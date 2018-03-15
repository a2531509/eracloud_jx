package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * BasePasm entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "BASE_PASM")
public class BasePasm implements java.io.Serializable {

	// Fields

	private String psamNo;
	private String psamId;
	private String psamEndNo;
	private String psamIssuseDate;
	private String psamValidDate;
	private String psamUse;
	private String psamState;
	private String psamBrand;
	private String psamManufacturer;
	private Date operDate;
	private String operId;
	private Long providerId;
	private String note;
	
	private String psamReceive; //PSAM_RECEIVE;领用人
	private String psamReceiveDate;//PSAM_RECEIVE_DATE;领用日期
	private Date reveiveTime;//RECEIVE_TIME;领用操作时间
	private String receiveUserid;//RECEIVE_USERID;领用操作员编号
	private String cancelUserid;//CANCEL_USERID;注销操作员编号
	private Date cancelDate;//CANCEL_DATE	;注销时间
	private String cancelReason;//CANCEL_REASON;注销原因
	private String psamType;//类型（1-人社、2-住建）
	@Column(name = "PSAM_TYPE", length = 1)
	public String getPsamType() {
		return this.psamType;
	}

	public void setPsamType(String psamType) {
		this.psamType = psamType;
	}


	// Constructors
	@Column(name = "PSAM_RECEIVE", length = 32)
	public String getPsamReceive() {
		return psamReceive;
	}

	public void setPsamReceive(String psamReceive) {
		this.psamReceive = psamReceive;
	}
	@Column(name = "PSAM_RECEIVE_DATE", length = 10)
	public String getPsamReceiveDate() {
		return psamReceiveDate;
	}

	public void setPsamReceiveDate(String psamReceiveDate) {
		this.psamReceiveDate = psamReceiveDate;
	}
	@Temporal(TemporalType.DATE)
	@Column(name = "RECEIVE_TIME", length = 7)
	public Date getReveiveTime() {
		return reveiveTime;
	}

	public void setReveiveTime(Date reveiveTime) {
		this.reveiveTime = reveiveTime;
	}
	@Column(name = "RECEIVE_USERID", length = 32)
	public String getReceiveUserid() {
		return receiveUserid;
	}

	public void setReceiveUserid(String receiveUserid) {
		this.receiveUserid = receiveUserid;
	}
	@Column(name = "CANCEL_USERID", length = 32)
	public String getCancelUserid() {
		return cancelUserid;
	}

	public void setCancelUserid(String cancelUserid) {
		this.cancelUserid = cancelUserid;
	}
	@Temporal(TemporalType.DATE)
	@Column(name = "CANCEL_DATE", length = 7)
	public Date getCancelDate() {
		return cancelDate;
	}

	public void setCancelDate(Date cancelDate) {
		this.cancelDate = cancelDate;
	}
	@Column(name = "CANCEL_REASON", length = 32)
	public String getCancelReason() {
		return cancelReason;
	}

	public void setCancelReason(String cancelReason) {
		this.cancelReason = cancelReason;
	}

	/** default constructor */
	public BasePasm() {
	}

	/** minimal constructor */
	public BasePasm(String psamNo) {
		this.psamNo = psamNo;
	}

	/** full constructor */
	public BasePasm(String psamNo, String psamId, String psamEndNo,
			String psamIssuseDate, String psamValidDate, String psamUse,
			String psamState, String psamBrand, String psamManufacturer,
			Date operDate, String operId, Long providerId, String note) {
		this.psamNo = psamNo;
		this.psamId = psamId;
		this.psamEndNo = psamEndNo;
		this.psamIssuseDate = psamIssuseDate;
		this.psamValidDate = psamValidDate;
		this.psamUse = psamUse;
		this.psamState = psamState;
		this.psamBrand = psamBrand;
		this.psamManufacturer = psamManufacturer;
		this.operDate = operDate;
		this.operId = operId;
		this.providerId = providerId;
		this.note = note;
	}

	// Property accessors
	@Id
	@Column(name = "PSAM_NO", unique = true, nullable = false, length = 20)
	public String getPsamNo() {
		return this.psamNo;
	}

	public void setPsamNo(String psamNo) {
		this.psamNo = psamNo;
	}

	@Column(name = "PSAM_ID", length = 32)
	public String getPsamId() {
		return this.psamId;
	}

	public void setPsamId(String psamId) {
		this.psamId = psamId;
	}

	@Column(name = "PSAM_END_NO", length = 32)
	public String getPsamEndNo() {
		return this.psamEndNo;
	}

	public void setPsamEndNo(String psamEndNo) {
		this.psamEndNo = psamEndNo;
	}

	@Column(name = "PSAM_ISSUSE_DATE", length = 10)
	public String getPsamIssuseDate() {
		return this.psamIssuseDate;
	}

	public void setPsamIssuseDate(String psamIssuseDate) {
		this.psamIssuseDate = psamIssuseDate;
	}

	@Column(name = "PSAM_VALID_DATE", length = 10)
	public String getPsamValidDate() {
		return this.psamValidDate;
	}

	public void setPsamValidDate(String psamValidDate) {
		this.psamValidDate = psamValidDate;
	}

	@Column(name = "PSAM_USE", length = 100)
	public String getPsamUse() {
		return this.psamUse;
	}

	public void setPsamUse(String psamUse) {
		this.psamUse = psamUse;
	}

	@Column(name = "PSAM_STATE", length = 1)
	public String getPsamState() {
		return this.psamState;
	}

	public void setPsamState(String psamState) {
		this.psamState = psamState;
	}

	@Column(name = "PSAM_BRAND", length = 100)
	public String getPsamBrand() {
		return this.psamBrand;
	}

	public void setPsamBrand(String psamBrand) {
		this.psamBrand = psamBrand;
	}

	@Column(name = "PSAM_MANUFACTURER", length = 100)
	public String getPsamManufacturer() {
		return this.psamManufacturer;
	}

	public void setPsamManufacturer(String psamManufacturer) {
		this.psamManufacturer = psamManufacturer;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "OPER_DATE", length = 7)
	public Date getOperDate() {
		return this.operDate;
	}

	public void setOperDate(Date operDate) {
		this.operDate = operDate;
	}

	@Column(name = "OPER_ID", length = 10)
	public String getOperId() {
		return this.operId;
	}

	public void setOperId(String operId) {
		this.operId = operId;
	}

	@Column(name = "PROVIDER_ID", precision = 20, scale = 0)
	public Long getProviderId() {
		return this.providerId;
	}

	public void setProviderId(Long providerId) {
		this.providerId = providerId;
	}

	@Column(name = "NOTE", length = 100)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}