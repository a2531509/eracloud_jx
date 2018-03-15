package com.erp.model;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Version;

import com.erp.util.ExcelVOAttribute;

@Entity
@Table(name = "base_corp_rechage_list")
public class BaseCorpRechargeList implements Serializable {
	private static final long serialVersionUID = 1L;

	private BaseCorpRechargeListPK pk;

	@ExcelVOAttribute(name = "name",column="A")
	protected String name;
	@ExcelVOAttribute(name = "certNo",column="B")
	protected String certNo;
	private String cardNo;
	private String accKind;
	@ExcelVOAttribute(name = "amt",column="C")
	protected Double amt;
	private String state;
	private String impUserId;
	private Date impDealDate;
	private String checkUserId;
	private Date checkDealDate;
	private String rechargeUserId;
	private Date rechargeDealDate;
	@ExcelVOAttribute(name = "note",column="D")
	protected String note;
	private Long version;

	public BaseCorpRechargeList() {
	}

	public BaseCorpRechargeList(BaseCorpRechargeListPK pk) {
		this.pk = pk;
	}

	public BaseCorpRechargeList(BaseCorpRechargeListPK pk, String name,
			String certNo, String cardNo, String accKind, Double amt,
			String state, String impUserId, Date impDealDate,
			String checkUserId, Date checkDealDate, String rechargeUserId,
			Date rechargeDealDate, String note) {
		super();
		this.pk = pk;
		this.name = name;
		this.certNo = certNo;
		this.cardNo = cardNo;
		this.accKind = accKind;
		this.amt = amt;
		this.state = state;
		this.impUserId = impUserId;
		this.impDealDate = impDealDate;
		this.checkUserId = checkUserId;
		this.checkDealDate = checkDealDate;
		this.rechargeUserId = rechargeUserId;
		this.rechargeDealDate = rechargeDealDate;
		this.note = note;
	}

	@EmbeddedId
	public BaseCorpRechargeListPK getPk() {
		return pk;
	}

	public void setPk(BaseCorpRechargeListPK pk) {
		this.pk = pk;
	}

	@Column(name = "name")
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "cert_no")
	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	@Column(name = "card_no")
	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "acc_kind")
	public String getAccKind() {
		return accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	@Column(name = "amt")
	public Double getAmt() {
		return amt;
	}

	public void setAmt(Double amt) {
		this.amt = amt;
	}

	@Column(name = "state")
	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
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

	@Column(name = "note")
	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Version
	@Column(name = "version")
	public Long getVersion() {
		return version;
	}

	public void setVersion(Long version) {
		this.version = version;
	}
}
