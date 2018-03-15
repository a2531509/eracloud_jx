package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * CardSaleList entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "CARD_SALE_LIST")
@SequenceGenerator(name="SEQ_CARD_SALE_LIST",allocationSize=1,initialValue=1,sequenceName="SEQ_CARD_SALE_LIST" )
public class CardSaleList implements java.io.Serializable {

	// Fields

	private Long saleListId;
	private Long dealNo;
	private String cardType;
	private String cardNo;
	private Long faceVal;
	private Long saleAmt;
	private Long foregift;
	private Long otherFee;
	private String listState;
	private Long costFee;

	// Constructors

	/** default constructor */
	public CardSaleList() {
	}

	/** minimal constructor */
	public CardSaleList(Long saleListId, Long dealNo) {
		this.saleListId = saleListId;
		this.dealNo = dealNo;
	}

	/** full constructor */
	public CardSaleList(Long saleListId, Long dealNo, String cardType,
			String cardNo, Long faceVal, Long saleAmt, Long foregift,
			Long otherFee, String listState, Long costFee) {
		this.saleListId = saleListId;
		this.dealNo = dealNo;
		this.cardType = cardType;
		this.cardNo = cardNo;
		this.faceVal = faceVal;
		this.saleAmt = saleAmt;
		this.foregift = foregift;
		this.otherFee = otherFee;
		this.listState = listState;
		this.costFee = costFee;
	}

	// Property accessors
	@Id
	@Column(name = "SALE_LIST_ID", unique = true, nullable = false, precision = 22, scale = 0)
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_CARD_SALE_LIST")
	public Long getSaleListId() {
		return this.saleListId;
	}

	public void setSaleListId(Long saleListId) {
		this.saleListId = saleListId;
	}

	@Column(name = "DEAL_NO", nullable = false, precision = 38, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "CARD_TYPE", length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "CARD_NO", length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "FACE_VAL", precision = 16, scale = 0)
	public Long getFaceVal() {
		return this.faceVal;
	}

	public void setFaceVal(Long faceVal) {
		this.faceVal = faceVal;
	}

	@Column(name = "SALE_AMT", precision = 16, scale = 0)
	public Long getSaleAmt() {
		return this.saleAmt;
	}

	public void setSaleAmt(Long saleAmt) {
		this.saleAmt = saleAmt;
	}

	@Column(name = "FOREGIFT", precision = 16, scale = 0)
	public Long getForegift() {
		return this.foregift;
	}

	public void setForegift(Long foregift) {
		this.foregift = foregift;
	}

	@Column(name = "OTHER_FEE", precision = 16, scale = 0)
	public Long getOtherFee() {
		return this.otherFee;
	}

	public void setOtherFee(Long otherFee) {
		this.otherFee = otherFee;
	}

	@Column(name = "LIST_STATE", length = 1)
	public String getListState() {
		return this.listState;
	}

	public void setListState(String listState) {
		this.listState = listState;
	}

	@Column(name = "COST_FEE", precision = 16, scale = 0)
	public Long getCostFee() {
		return this.costFee;
	}

	public void setCostFee(Long costFee) {
		this.costFee = costFee;
	}

}