package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
@Table(name = "BHK_ZZ_REGISTER")
public class BhkZzRegister {
	@Column(name="card_no")
	private String cardNo;
	
	@Column(name="register_date")
	@Temporal(TemporalType.TIMESTAMP)
	private Date registerDate;
	
	@Column(name="register_org_id")
	private String registerOrgId;
	
	@Column(name="register_brch_id")
	private String registerBrchId;
	
	@Column(name="register_user_id")
	private String registerUserId;
	
	@Id
	@Column(name="deal_no")
	private Long dealNo;
	
	@Column(name="state")
	private String state;

	public BhkZzRegister() {
		super();
	}

	public BhkZzRegister(String cardNo, Date registerDate, String registerOrgId, String registerBrchId,
			String registerUserId, Long dealNo, String state) {
		super();
		this.cardNo = cardNo;
		this.registerDate = registerDate;
		this.registerOrgId = registerOrgId;
		this.registerBrchId = registerBrchId;
		this.registerUserId = registerUserId;
		this.dealNo = dealNo;
		this.state = state;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public Date getRegisterDate() {
		return registerDate;
	}

	public void setRegisterDate(Date registerDate) {
		this.registerDate = registerDate;
	}

	public String getRegisterOrgId() {
		return registerOrgId;
	}

	public void setRegisterOrgId(String registerOrgId) {
		this.registerOrgId = registerOrgId;
	}

	public String getRegisterBrchId() {
		return registerBrchId;
	}

	public void setRegisterBrchId(String registerBrchId) {
		this.registerBrchId = registerBrchId;
	}

	public String getRegisterUserId() {
		return registerUserId;
	}

	public void setRegisterUserId(String registerUserId) {
		this.registerUserId = registerUserId;
	}

	public Long getDealNo() {
		return dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}
}
