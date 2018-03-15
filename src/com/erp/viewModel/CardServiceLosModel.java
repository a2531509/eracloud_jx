package com.erp.viewModel;


public class CardServiceLosModel {
	
//	hql.append("select c.card_Id id,b.name,b.cert_no,c.card_No,c.sub_Card_id");
//	hql.append(",c.card_Type,c.card_State,"+SqlTools.divHundred("c.foregift")+","
//	+ SqlTools.divHundred("c.foregift_Bal")+","+SqlTools.divHundred("c.cost_fee")+",p.lss_flag ");
	public String id;
	public String name;
	public String certType;//新增证件类型  2015-05-22
	public String certNo;
	public String cardNo;
	public String subCardId;
	public String cardType;
	public String cardState;
	private String busType;
	public String foregift;
	public String foregiftBal;
	public String costFee;
	public String lssFlag;
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getCertNo() {
		return certNo;
	}
	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}
	public String getCardNo() {
		return cardNo;
	}
	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}
	public String getSubCardId() {
		return subCardId;
	}
	public void setSubCardId(String subCardId) {
		this.subCardId = subCardId;
	}
	public String getCardType() {
		return cardType;
	}
	public void setCardType(String cardType) {
		this.cardType = cardType;
	}
	public String getCardState() {
		return cardState;
	}
	public void setCardState(String cardState) {
		this.cardState = cardState;
	}
	public String getForegift() {
		return foregift;
	}
	public void setForegift(String foregift) {
		this.foregift = foregift;
	}
	public String getForegiftBal() {
		return foregiftBal;
	}
	public void setForegiftBal(String foregiftBal) {
		this.foregiftBal = foregiftBal;
	}
	public String getCostFee() {
		return costFee;
	}
	public void setCostFee(String costFee) {
		this.costFee = costFee;
	}
	public String getLssFlag() {
		return lssFlag;
	}
	public void setLssFlag(String lssFlag) {
		this.lssFlag = lssFlag;
	}
	public String getCertType() {
		return certType;
	}
	public void setCertType(String certType) {
		this.certType = certType;
	}
	public String getBusType() {
		return busType;
	}
	public void setBusType(String busType) {
		this.busType = busType;
	}
}
