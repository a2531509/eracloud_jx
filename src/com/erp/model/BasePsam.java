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

import com.erp.util.ExcelVOAttribute;

/**
 * BasePasm entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_PASM")
public class BasePsam implements java.io.Serializable {

	// Fields

	@ExcelVOAttribute(column = "A", name = "PSAM卡序列号")
	private String psamNo;
	@ExcelVOAttribute(column = "B", name = "PSAM卡物理卡号")
	private String psamId;
	@ExcelVOAttribute(column = "C", name = "psam卡终端编号")
	private String psamEndNo;
	@ExcelVOAttribute(column = "D", name = "卡发行日期")
	private String psamIssuseDate;
	@ExcelVOAttribute(column = "E", name = "卡有效日期")
	private String psamValidDate;
	@ExcelVOAttribute(column = "F", name = "卡片用途")
	private String psamUse;
	private String psamState;
	@ExcelVOAttribute(column = "G", name = "品牌分类")
	private String psamBrand;
	@ExcelVOAttribute(column = "H", name = "生产厂家")
	private String psamManufacturer;
	private Date operDate;
	private String operId;
	private Long providerId;
	@ExcelVOAttribute(column = "I", name = "备注")
	private String note;
	private String psamRreceive;
	private String psamRreceiveDate;
	private Date receiveTime;
	private String receiveUserId;
	private String cancleUserId;
	private Date cancleDate;
	private String cancleReason;
	@ExcelVOAttribute(column = "J", name = "PSAM卡类型")
	private String psamType;

	// Constructors

	/** default constructor */
	public BasePsam() {
	}

	/** minimal constructor */
	public BasePsam(String psamNo) {
		this.psamNo = psamNo;
	}

	/** full constructor */
	public BasePsam(String psamNo, String psamId, String psamEndNo,
			String psamIssuseDate, String psamValidDate, String psamUse,
			String psamState, String psamBrand, String psamManufacturer,
			Date operDate, String operId, Long providerId, String note,
			String psamRreceive,String psamRreceiveDate,Date receiveTime,
			String receiveUserId,String cancleUserId,Date cancleDate,
			String cancleReason,String psamType) {
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
		this.psamRreceive = psamRreceive;
		this.psamRreceiveDate = psamRreceiveDate;
		this.receiveTime = receiveTime;
		this.receiveUserId = receiveUserId;
		this.cancleUserId = cancleUserId;
		this.cancleDate = cancleDate;
		this.cancleReason = cancleReason;
		this.psamType = psamType;
	}

	// Property accessors
	@Column(name = "PSAM_RECEIVE", length = 50)
	public String getPsamRreceive() {
		return this.psamRreceive;
	}

	public void setPsamRreceive(String psamRreceive) {
		this.psamRreceive = psamRreceive;
	}
	
	@Column(name = "PSAM_RECEIVE_DATE", length = 10)
	public String getPsamRreceiveDate() {
		return this.psamRreceiveDate;
	}

	public void setPsamRreceiveDate(String psamRreceiveDate) {
		this.psamRreceiveDate = psamRreceiveDate;
	}
	
	@Column(name = "RECEIVE_TIME", length = 7)
	public Date getReceiveTime() {
		return this.receiveTime;
	}

	public void setReceiveTime(Date receiveTime) {
		this.receiveTime = receiveTime;
	}
	
	@Column(name = "RECEIVE_USERID", length = 10)
	public String getReceiveUserId() {
		return this.receiveUserId;
	}

	public void setReceiveUserId(String receiveUserId) {
		this.receiveUserId = receiveUserId;
	}
	
	@Column(name = "CANCEL_USERID", length = 10)
	public String getCancleUserId() {
		return this.cancleUserId;
	}

	public void setCancleUserId(String cancleUserId) {
		this.cancleUserId = cancleUserId;
	}
	
	@Column(name = "CANCEL_DATE", length = 7)
	public Date getCancleDate() {
		return this.cancleDate;
	}

	public void setCancleDate(Date cancleDate) {
		this.cancleDate = cancleDate;
	}

	@Column(name = "CANCEL_REASON", length = 100)
	public String getCancleReason() {
		return cancleReason;
	}

	public void setCancleReason(String cancleReason) {
		this.cancleReason = cancleReason;
	}

	@Column(name = "PSAM_TYPE", length = 1)
	public String getPsamType() {
		return psamType;
	}

	public void setPsamType(String psamType) {
		this.psamType = psamType;
	}

	@Id
	@Column(name = "PSAM_NO", unique = true, nullable = false, precision = 20, scale = 0)
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

	@Temporal(TemporalType.TIMESTAMP)
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