package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * CardSaleBook entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "CARD_SALE_BOOK")
@SequenceGenerator(name="SEQ_PAY_BAT_ID",allocationSize=1,initialValue=1,sequenceName="SEQ_PAY_BAT_ID" )
public class CardSaleBook implements java.io.Serializable {

	// Fields

	private Long payBatId;
	private Date payDate;
	private Long payAmt;
	private String payWay;
	private String bankSheetNo;
	private String bankId;
	private String saveDate;
	private String stlDate;
	private String operId;
	private String payState;
	private String state;
	private Long dealNo;

	// Constructors

	/** default constructor */
	public CardSaleBook() {
	}

	/** minimal constructor */
	public CardSaleBook(Long payBatId) {
		this.payBatId = payBatId;
	}

	/** full constructor */
	public CardSaleBook(Long payBatId, Date payDate, Long payAmt,
			String payWay, String bankSheetNo, String bankId, String saveDate,
			String stlDate, String operId, String payState, String state,
			Long dealNo) {
		this.payBatId = payBatId;
		this.payDate = payDate;
		this.payAmt = payAmt;
		this.payWay = payWay;
		this.bankSheetNo = bankSheetNo;
		this.bankId = bankId;
		this.saveDate = saveDate;
		this.stlDate = stlDate;
		this.operId = operId;
		this.payState = payState;
		this.state = state;
		this.dealNo = dealNo;
	}

	// Property accessors
	
	
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_PAY_BAT_ID")
	@Column(name = "PAY_BAT_ID", unique = true, nullable = false, precision = 22, scale = 0)
	public Long getPayBatId() {
		return this.payBatId;
	}

	public void setPayBatId(Long payBatId) {
		this.payBatId = payBatId;
	}

	@Column(name = "PAY_DATE", length = 7)
	public Date getPayDate() {
		return this.payDate;
	}

	public void setPayDate(Date payDate) {
		this.payDate = payDate;
	}

	@Column(name = "PAY_AMT", precision = 16, scale = 0)
	public Long getPayAmt() {
		return this.payAmt;
	}

	public void setPayAmt(Long payAmt) {
		this.payAmt = payAmt;
	}

	@Column(name = "PAY_WAY", length = 1)
	public String getPayWay() {
		return this.payWay;
	}

	public void setPayWay(String payWay) {
		this.payWay = payWay;
	}

	@Column(name = "BANK_SHEET_NO", length = 10)
	public String getBankSheetNo() {
		return this.bankSheetNo;
	}

	public void setBankSheetNo(String bankSheetNo) {
		this.bankSheetNo = bankSheetNo;
	}

	@Column(name = "BANK_ID", length = 4)
	public String getBankId() {
		return this.bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	@Column(name = "SAVE_DATE", length = 10)
	public String getSaveDate() {
		return this.saveDate;
	}

	public void setSaveDate(String saveDate) {
		this.saveDate = saveDate;
	}

	@Column(name = "STL_DATE", length = 10)
	public String getStlDate() {
		return this.stlDate;
	}

	public void setStlDate(String stlDate) {
		this.stlDate = stlDate;
	}

	@Column(name = "OPER_ID", length = 8)
	public String getOperId() {
		return this.operId;
	}

	public void setOperId(String operId) {
		this.operId = operId;
	}

	@Column(name = "PAY_STATE", length = 1)
	public String getPayState() {
		return this.payState;
	}

	public void setPayState(String payState) {
		this.payState = payState;
	}

	@Column(name = "STATE", length = 1)
	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

	@Column(name = "DEAL_NO", precision = 16, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

}