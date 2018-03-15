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

@SuppressWarnings("serial")
@Entity
@Table(name = "CARD_APP_BIND")
@SequenceGenerator(name="seqBindId",allocationSize=1,initialValue=1,sequenceName="SEQ_BIND_ID" )
public class CardAppBind implements java.io.Serializable {

	private String bindId;

	@Column(name="APP_TYPE")
	private String appType;

	@Temporal(TemporalType.DATE)
	@Column(name="BIND_DATE")
	private Date bindDate;

	@Column(name="BIND_STATE")
	private String bindState;

	@Column(name="BRCH_ID")
	private String brchId;

	@Column(name="CARD_NO")
	private String cardNo;

	@Column(name="DEAL_NO")
	private Long dealNo;

	@Column(name="FAMILY_NO")
	private String familyNo;

	@Column(name="MERCHANT_ID")
	private String merchantId;
	@Column(name="NOTE")
	private String note;
	@Column(name="RESERVE2")
	private String reserve2;
	@Column(name="RESERVE3")
	private String reserve3;
	@Column(name="RESERVE4")
	private String reserve4;

	@Column(name="USER_ID")
	private String userId;

	public CardAppBind() {
	}
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="seqBindId")
	@Column(name = "BIND_ID", length = 20)
	public String getBindId() {
		return this.bindId;
	}

	public void setBindId(String bindId) {
		this.bindId = bindId;
	}

	public String getAppType() {
		return this.appType;
	}

	public void setAppType(String appType) {
		this.appType = appType;
	}

	public Date getBindDate() {
		return this.bindDate;
	}

	public void setBindDate(Date bindDate) {
		this.bindDate = bindDate;
	}

	public String getBindState() {
		return this.bindState;
	}

	public void setBindState(String bindState) {
		this.bindState = bindState;
	}

	public String getBrchId() {
		return this.brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}
	@Column(name="DEAL_NO")
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	public String getFamilyNo() {
		return this.familyNo;
	}

	public void setFamilyNo(String familyNo) {
		this.familyNo = familyNo;
	}

	public String getMerchantId() {
		return this.merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public String getReserve2() {
		return this.reserve2;
	}

	public void setReserve2(String reserve2) {
		this.reserve2 = reserve2;
	}

	public String getReserve3() {
		return this.reserve3;
	}

	public void setReserve3(String reserve3) {
		this.reserve3 = reserve3;
	}

	public String getReserve4() {
		return this.reserve4;
	}

	public void setReserve4(String reserve4) {
		this.reserve4 = reserve4;
	}

	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}


}
