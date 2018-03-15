package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
@Table(name = "card_org_bind_section")
public class CardOrgBindSection {
	@Id
	@Column(name = "bind_section")
	private String bindSection;

	@Column(name = "card_org_id")
	private String cardOrgId;

	@Column(name = "card_org_name")
	private String cardOrgName;

	@Column(name = "org_id")
	private String orgId;

	@Column(name = "brch_id")
	private String brchId;

	@Column(name = "user_id")
	private String userId;

	@Column(name = "last_modify_date")
	@Temporal(TemporalType.TIMESTAMP)
	private Date lastModifyDate;

	@Column(name = "state")
	private String state;

	@Column(name = "note")
	private String note;

	@Column(name = "acpt_id")
	private String acptId;

	public CardOrgBindSection() {
		super();
	}

	public String getBindSection() {
		return bindSection;
	}

	public void setBindSection(String bindSection) {
		this.bindSection = bindSection;
	}

	public String getCardOrgId() {
		return cardOrgId;
	}

	public void setCardOrgId(String cardOrgId) {
		this.cardOrgId = cardOrgId;
	}

	public String getCardOrgName() {
		return cardOrgName;
	}

	public void setCardOrgName(String cardOrgName) {
		this.cardOrgName = cardOrgName;
	}

	public String getOrgId() {
		return orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	public String getBrchId() {
		return brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public Date getLastModifyDate() {
		return lastModifyDate;
	}

	public void setLastModifyDate(Date lastModifyDate) {
		this.lastModifyDate = lastModifyDate;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public String getAcptId() {
		return acptId;
	}

	public void setAcptId(String acptId) {
		this.acptId = acptId;
	}
}
