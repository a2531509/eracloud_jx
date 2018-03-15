package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * StockListId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class StockListId implements java.io.Serializable {

	// Fields

	private String stkCode;
	private String goodsId;
	private String goodsState;

	// Constructors

	/** default constructor */
	public StockListId() {
	}

	/** full constructor */
	public StockListId(String stkCode, String goodsId, String goodsState) {
		this.stkCode = stkCode;
		this.goodsId = goodsId;
		this.goodsState = goodsState;
	}

	// Property accessors

	@Column(name = "STK_CODE", nullable = false, length = 4)
	public String getStkCode() {
		return this.stkCode;
	}

	public void setStkCode(String stkCode) {
		this.stkCode = stkCode;
	}

	@Column(name = "GOODS_ID", nullable = false, length = 50)
	public String getGoodsId() {
		return this.goodsId;
	}

	public void setGoodsId(String goodsId) {
		this.goodsId = goodsId;
	}

	@Column(name = "GOODS_STATE", nullable = false, length = 1)
	public String getGoodsState() {
		return this.goodsState;
	}

	public void setGoodsState(String goodsState) {
		this.goodsState = goodsState;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof StockListId))
			return false;
		StockListId castOther = (StockListId) other;

		return ((this.getStkCode() == castOther.getStkCode()) || (this
				.getStkCode() != null && castOther.getStkCode() != null && this
				.getStkCode().equals(castOther.getStkCode())))
				&& ((this.getGoodsId() == castOther.getGoodsId()) || (this
						.getGoodsId() != null && castOther.getGoodsId() != null && this
						.getGoodsId().equals(castOther.getGoodsId())))
				&& ((this.getGoodsState() == castOther.getGoodsState()) || (this
						.getGoodsState() != null
						&& castOther.getGoodsState() != null && this
						.getGoodsState().equals(castOther.getGoodsState())));
	}

	public int hashCode() {
		int result = 17;

		result = 37 * result
				+ (getStkCode() == null ? 0 : this.getStkCode().hashCode());
		result = 37 * result
				+ (getGoodsId() == null ? 0 : this.getGoodsId().hashCode());
		result = 37
				* result
				+ (getGoodsState() == null ? 0 : this.getGoodsState()
						.hashCode());
		return result;
	}

}