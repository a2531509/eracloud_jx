package com.erp.model;

import java.io.Serializable;
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

@Entity
@Table(name = "base_corp_rechage_info")
@SequenceGenerator(name = "seq", sequenceName = "SEQ_CORP_RECHAGE_INFO")
public class BaseCorpRechargeInfo implements Serializable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private String customerId;
	private String rechargeType;
	private Long num;
	private BigDecimal amt;
	private String impUserId;
	private Date impDealDate;
	private String checkUserId;
	private Date checkDealDate;
	private String rechargeUserId;
	private Date rechargeDealDate;
	private String state;
	private String note;

	public BaseCorpRechargeInfo() {
		super();
	}

	public BaseCorpRechargeInfo(Long id) {
		super();
		this.id = id;
	}

	public BaseCorpRechargeInfo(Long id, String customerId,
			String rechargeType, Long num, BigDecimal amt, String impUserId,
			Date impDealDate, String checkUserId, Date checkDealDate,
			String rechargeUserId, Date rechargeDealDate, String state,
			String note) {
		super();
		this.id = id;
		this.customerId = customerId;
		this.rechargeType = rechargeType;
		this.num = num;
		this.amt = amt;
		this.impUserId = impUserId;
		this.impDealDate = impDealDate;
		this.checkUserId = checkUserId;
		this.checkDealDate = checkDealDate;
		this.rechargeUserId = rechargeUserId;
		this.rechargeDealDate = rechargeDealDate;
		this.state = state;
		this.note = note;
	}

	@Id
	@Column(name = "id", unique = true, nullable = false)
	@GeneratedValue(generator = "seq", strategy = GenerationType.SEQUENCE)
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Column(name = "customer_id")
	public String getCustomerId() {
		return customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "rechage_type")
	public String getRechargeType() {
		return rechargeType;
	}

	public void setRechargeType(String rechargeType) {
		this.rechargeType = rechargeType;
	}

	@Column(name = "num")
	public Long getNum() {
		return num;
	}

	public void setNum(Long num) {
		this.num = num;
	}

	@Column(name = "amt")
	public BigDecimal getAmt() {
		return amt;
	}

	public void setAmt(BigDecimal amt) {
		this.amt = amt;
	}

	@Column(name = "imp_uers_id")
	public String getImpUserId() {
		return impUserId;
	}

	public void setImpUserId(String impUserId) {
		this.impUserId = impUserId;
	}

	@Column(name = "imp_deal_date")
	@Temporal(TemporalType.TIMESTAMP)
	public Date getImpDealDate() {
		return impDealDate;
	}

	public void setImpDealDate(Date impDealDate) {
		this.impDealDate = impDealDate;
	}

	@Column(name = "check_user_id")
	public String getCheckUserId() {
		return checkUserId;
	}

	public void setCheckUserId(String checkUserId) {
		this.checkUserId = checkUserId;
	}

	@Column(name = "check_deal_date")
	@Temporal(TemporalType.TIMESTAMP)
	public Date getCheckDealDate() {
		return checkDealDate;
	}

	public void setCheckDealDate(Date checkDealDate) {
		this.checkDealDate = checkDealDate;
	}

	@Column(name = "rechage_user_id")
	public String getRechargeUserId() {
		return rechargeUserId;
	}

	public void setRechargeUserId(String rechargeUserId) {
		this.rechargeUserId = rechargeUserId;
	}

	@Column(name = "rechage_deal_date")
	@Temporal(TemporalType.TIMESTAMP)
	public Date getRechargeDealDate() {
		return rechargeDealDate;
	}

	public void setRechargeDealDate(Date rechargeDealDate) {
		this.rechargeDealDate = rechargeDealDate;
	}

	@Column(name = "state")
	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	@Column(name = "note")
	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}
}
