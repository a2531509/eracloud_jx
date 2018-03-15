package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Transient;

import org.hibernate.annotations.DynamicInsert;
import org.hibernate.annotations.DynamicUpdate;

import com.erp.util.ExcelVOAttribute;

@Entity
@Table(name = "card_insurance_info")
@DynamicInsert
@DynamicUpdate
public class CardInsuranceInfo {
	@EmbeddedId
	private CardInsuranceInfoId id;
	
	@ExcelVOAttribute(column = "C", name = "市民卡号")
	@Transient
	private String subCardNo;
	
	@ExcelVOAttribute(column = "E", name = "保单编号")
	@Transient
	private String insuranceNo;
	
	@Column(name="insurance_kind")
	private String insuranceKind = "市民卡资金账户安全保险";
	
	@Temporal(TemporalType.TIMESTAMP)
	@Column(name="insured_date")
	private Date insuredDate;
	
	@Temporal(TemporalType.TIMESTAMP)
	@Column(name="start_date")
	private Date startDate;
	
	@Temporal(TemporalType.TIMESTAMP)
	@Column(name="end_date")
	private Date endDate;
	
	@Column(name="deal_no")
	private Long dealNo;
	
	@Column(name="state")
	private String state;
	
	@Column(name="source")
	private String source;
	
	@Column(name="order_no")
	private String orderNo;
	
	@Column(name="amt")
	private String amt;
	
	@ExcelVOAttribute(column = "D", name = "证件号码")
	@Transient
	private String certNo;
	
	@ExcelVOAttribute(column = "A", name = "序号")
	@Transient
	private String seq;
	
	@ExcelVOAttribute(column = "B", name = "姓名")
	@Transient
	private String name;
	
	@Transient
	private String insuredDateStr;
	
	@ExcelVOAttribute(column = "F", name = "保险开始日期")
	@Transient
	private String startDateStr;
	
	@ExcelVOAttribute(column = "G", name = "保险结束日期")
	@Transient
	private String endDateStr;
	
	@ExcelVOAttribute(column = "H", name = "备注")
	@Column(name="note")
	private String note = "";

	public CardInsuranceInfo() {
		super();
	}

	public String getInsuranceNo() {
		return insuranceNo;
	}

	public void setInsuranceNo(String insuranceNo) {
		this.insuranceNo = insuranceNo;
	}

	public String getInsuranceKind() {
		return insuranceKind;
	}

	public void setInsuranceKind(String insuranceKind) {
		this.insuranceKind = insuranceKind;
	}

	public Date getInsuredDate() {
		return insuredDate;
	}

	public void setInsuredDate(Date insuredDate) {
		this.insuredDate = insuredDate;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getEndDate() {
		return endDate;
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	public Long getDealNo() {
		return dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getInsuredDateStr() {
		return insuredDateStr;
	}

	public void setInsuredDateStr(String insuredDateStr) {
		this.insuredDateStr = insuredDateStr;
	}

	public String getStartDateStr() {
		return startDateStr;
	}

	public void setStartDateStr(String startDateStr) {
		this.startDateStr = startDateStr;
	}

	public String getEndDateStr() {
		return endDateStr;
	}

	public void setEndDateStr(String endDateStr) {
		this.endDateStr = endDateStr;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public String getSubCardNo() {
		return subCardNo;
	}

	public void setSubCardNo(String subCardNo) {
		this.subCardNo = subCardNo;
	}

	public CardInsuranceInfoId getId() {
		return id;
	}

	public void setId(CardInsuranceInfoId id) {
		this.id = id;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getOrderNo() {
		return orderNo;
	}

	public void setOrderNo(String orderNo) {
		this.orderNo = orderNo;
	}

	public String getAmt() {
		return amt;
	}

	public void setAmt(String amt) {
		this.amt = amt;
	}

	public String getSeq() {
		return seq;
	}

	public void setSeq(String seq) {
		this.seq = seq;
	}
}
