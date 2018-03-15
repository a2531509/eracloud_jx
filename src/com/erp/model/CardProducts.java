package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "CARD_PRODUCTS")
public class CardProducts {
	private String cardType;
	private String chipType;
	private String card1Volumen;
	private String card1Version;
	private String card1CosVender;
	private String card2Volumen;
	private String card2Version;
	private String card2CosVender;
	private String isBankstripe;
	private String mediType;
	private String cardReversePhoto;
	private String proState;
	private String brchId;
	private String operId;
	private String orgId;

	public CardProducts(String cardType, String chipType, String card1Volumen, String card1Version,
			String card1CosVender, String card2Volumen, String card2Version, String card2CosVender,
			String isBankstripe, String mediType, String cardReversePhoto,String proState, 
			String brchId,String operId, String orgId) {
		this.cardType=cardType;
		this.chipType=chipType;
		this.card1Volumen=card1Volumen;
		this.card1Version=card1Version;
		this.card1CosVender=card1CosVender;
		this.card2Volumen=card2Volumen;
		this.card2Version=card2Version;
		this.card2CosVender=card2CosVender;
		this.isBankstripe=isBankstripe;
		this.mediType=mediType;
		this.cardReversePhoto=cardReversePhoto;
		this.proState=proState;
		this.brchId=brchId;
		this.operId=operId;
		this.orgId=orgId;
	}
	
	public CardProducts() {
		// TODO Auto-generated constructor stub
	}
	@Id
	@Column(name="CARD_TYPE",length=3)
	public String getCardType() {
		return cardType;
	}



	public void setCardType(String cardType) {
		this.cardType = cardType;
	}


	@Column(name="CHIP_TYPE",length=1)
	public String getChipType() {
		return chipType;
	}



	public void setChipType(String chipType) {
		this.chipType = chipType;
	}


	@Column(name="CARD1_VOLUMEN",length=10)
	public String getCard1Volumen() {
		return card1Volumen;
	}



	public void setCard1Volumen(String card1Volumen) {
		this.card1Volumen = card1Volumen;
	}


	@Column(name="CARD1_VERSION",length=10)
	public String getCard1Version() {
		return card1Version;
	}



	public void setCard1Version(String card1Version) {
		this.card1Version = card1Version;
	}


	@Column(name="CARD1_COS_VENDER",length=10)
	public String getCard1CosVender() {
		return card1CosVender;
	}



	public void setCard1CosVender(String card1CosVender) {
		this.card1CosVender = card1CosVender;
	}


	@Column(name="CARD2_VOLUMEN",length=10)
	public String getCard2Volumen() {
		return card2Volumen;
	}



	public void setCard2Volumen(String card2Volumen) {
		this.card2Volumen = card2Volumen;
	}


	@Column(name="CARD2_VERSION",length=10)
	public String getCard2Version() {
		return card2Version;
	}



	public void setCard2Version(String card2Version) {
		this.card2Version = card2Version;
	}


	@Column(name="CARD2_COS_VENDER",length=10)
	public String getCard2CosVender() {
		return card2CosVender;
	}



	public void setCard2CosVender(String card2CosVender) {
		this.card2CosVender = card2CosVender;
	}


	@Column(name="IS_BANKSTRIPE",length=1)
	public String getIsBankstripe() {
		return isBankstripe;
	}



	public void setIsBankstripe(String isBankstripe) {
		this.isBankstripe = isBankstripe;
	}


	@Column(name="MEDIA_TYPE",length=1)
	public String getMediType() {
		return mediType;
	}



	public void setMediType(String mediType) {
		this.mediType = mediType;
	}


	@Column(name="CARD_REVERSE_PHOTO",length=1)
	public String getCardReversePhoto() {
		return cardReversePhoto;
	}



	public void setCardReversePhoto(String cardReversePhoto) {
		this.cardReversePhoto = cardReversePhoto;
	}


	@Column(name="PRO_STATE",length=1)
	public String getProState() {
		return proState;
	}



	public void setProState(String proState) {
		this.proState = proState;
	}


	@Column(name="BRCH_ID",length=10)
	public String getBrchId() {
		return brchId;
	}



	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	
	@Column(name="OPER_ID",length=10)
	public String getOperId() {
		return operId;
	}



	public void setOperId(String operId) {
		this.operId = operId;
	}


	@Column(name="ORG_ID",length=10)
	public String getOrgId() {
		return orgId;
	}



	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

}
