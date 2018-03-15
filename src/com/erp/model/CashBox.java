package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * CashBox entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CASH_BOX")
public class CashBox implements java.io.Serializable {

	// Fields

	private String userId;
	private String orgId;
	private String brchId;
	private String coinKind;
	private Long ydBlc;
	private Long tdInNum;
	private Long tdInAmt;
	private Long tdOutNum;
	private Long tdOutAmt;
	private Long tdBlc;
	private Long frzAmt;

	// Constructors

	/** default constructor */
	public CashBox() {
	}

	/** minimal constructor */
	public CashBox(String userId, String brchId, String coinKind, Long ydBlc,
			Long tdInNum, Long tdInAmt, Long tdOutNum,
			Long tdOutAmt, Long tdBlc) {
		this.userId = userId;
		this.brchId = brchId;
		this.coinKind = coinKind;
		this.ydBlc = ydBlc;
		this.tdInNum = tdInNum;
		this.tdInAmt = tdInAmt;
		this.tdOutNum = tdOutNum;
		this.tdOutAmt = tdOutAmt;
		this.tdBlc = tdBlc;
	}

	/** full constructor */
	public CashBox(String userId, String orgId, String brchId, String coinKind,
			Long ydBlc, Long tdInNum, Long tdInAmt, Long tdOutNum,
			Long tdOutAmt, Long tdBlc) {
		this.userId = userId;
		this.orgId = orgId;
		this.brchId = brchId;
		this.coinKind = coinKind;
		this.ydBlc = ydBlc;
		this.tdInNum = tdInNum;
		this.tdInAmt = tdInAmt;
		this.tdOutNum = tdOutNum;
		this.tdOutAmt = tdOutAmt;
		this.tdBlc = tdBlc;
	}

	// Property accessors
	@Id
	@Column(name = "USER_ID", unique = true, nullable = false, length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "ORG_ID", length = 8)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "BRCH_ID", nullable = false, length = 8)
	public String getBrchId() {
		return this.brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	@Column(name = "COIN_KIND", nullable = false, length = 2)
	public String getCoinKind() {
		return this.coinKind;
	}

	public void setCoinKind(String coinKind) {
		this.coinKind = coinKind;
	}

	@Column(name = "YD_BLC", nullable = false, precision = 12, scale = 0)
	public Long getYdBlc() {
		return this.ydBlc;
	}

	public void setYdBlc(Long ydBlc) {
		this.ydBlc = ydBlc;
	}

	@Column(name = "TD_IN_NUM", nullable = false, precision = 38, scale = 0)
	public Long getTdInNum() {
		return this.tdInNum;
	}

	public void setTdInNum(Long tdInNum) {
		this.tdInNum = tdInNum;
	}

	@Column(name = "TD_IN_AMT", nullable = false, precision = 12, scale = 0)
	public Long getTdInAmt() {
		return this.tdInAmt;
	}

	public void setTdInAmt(Long tdInAmt) {
		this.tdInAmt = tdInAmt;
	}

	@Column(name = "TD_OUT_NUM", nullable = false, precision = 38, scale = 0)
	public Long getTdOutNum() {
		return this.tdOutNum;
	}

	public void setTdOutNum(Long tdOutNum) {
		this.tdOutNum = tdOutNum;
	}

	@Column(name = "TD_OUT_AMT", nullable = false, precision = 12, scale = 0)
	public Long getTdOutAmt() {
		return this.tdOutAmt;
	}

	public void setTdOutAmt(Long tdOutAmt) {
		this.tdOutAmt = tdOutAmt;
	}

	@Column(name = "TD_BLC", nullable = false, precision = 12, scale = 0)
	public Long getTdBlc() {
		return this.tdBlc;
	}

	public void setTdBlc(Long tdBlc) {
		this.tdBlc = tdBlc;
	}
	@Column(name = "FRZ_AMT", nullable = false, precision = 12, scale = 0)
	public Long getFrzAmt() {
		return frzAmt;
	}

	public void setFrzAmt(Long frzAmt) {
		this.frzAmt = frzAmt;
	}

}