package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Embeddable;

/**
 * StockAccId entity. @author MyEclipse Persistence Tools
 */
@Embeddable
public class StockAccId implements java.io.Serializable {

	// Fields

	private String userId;
	private String stkCode;
	private String goodsState;

	// Constructors

	/** default constructor */
	public StockAccId() {
	}

	/** full constructor */
	public StockAccId(String userId, String stkCode, String goodsState) {
		this.userId = userId;
		this.stkCode = stkCode;
		this.goodsState = goodsState;
	}

	// Property accessors

	@Column(name = "USER_ID", nullable = false, length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "STK_CODE", nullable = false, length = 4)
	public String getStkCode() {
		return this.stkCode;
	}

	public void setStkCode(String stkCode) {
		this.stkCode = stkCode;
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
		if (!(other instanceof StockAccId))
			return false;
		StockAccId castOther = (StockAccId) other;

		return ((this.getUserId() == castOther.getUserId()) || (this
				.getUserId() != null && castOther.getUserId() != null && this
				.getUserId().equals(castOther.getUserId())))
				&& ((this.getStkCode() == castOther.getStkCode()) || (this
						.getStkCode() != null && castOther.getStkCode() != null && this
						.getStkCode().equals(castOther.getStkCode())))
				&& ((this.getGoodsState() == castOther.getGoodsState()) || (this
						.getGoodsState() != null
						&& castOther.getGoodsState() != null && this
						.getGoodsState().equals(castOther.getGoodsState())));
	}

	public int hashCode() {
		int result = 17;

		result = 37 * result
				+ (getUserId() == null ? 0 : this.getUserId().hashCode());
		result = 37 * result
				+ (getStkCode() == null ? 0 : this.getStkCode().hashCode());
		result = 37
				* result
				+ (getGoodsState() == null ? 0 : this.getGoodsState()
						.hashCode());
		return result;
	}

}