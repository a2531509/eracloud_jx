package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * PayMerchantLim entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "PAY_MERCHANT_LIM")
public class PayMerchantLim implements java.io.Serializable {

	// Fields

	private String merchantId;
	private String merchantName;
	private Long lim01;
	private Long lim02;
	private Long lim03;
	private Long lim04;
	private Long lim05;
	private Long lim06;
	private Long lim07;
	private Long lim08;
	private Long lim09;
	private Long lim10;

	// Constructors

	/** default constructor */
	public PayMerchantLim() {
	}

	/** minimal constructor */
	public PayMerchantLim(String merchantId) {
		this.merchantId = merchantId;
	}

	/** full constructor */
	public PayMerchantLim(String merchantId, Long lim01, Long lim02,
			Long lim03, Long lim04, Long lim05, Long lim06, Long lim07,
			Long lim08, Long lim09, Long lim10) {
		this.merchantId = merchantId;
		this.lim01 = lim01;
		this.lim02 = lim02;
		this.lim03 = lim03;
		this.lim04 = lim04;
		this.lim05 = lim05;
		this.lim06 = lim06;
		this.lim07 = lim07;
		this.lim08 = lim08;
		this.lim09 = lim09;
		this.lim10 = lim10;
	}

	// Property accessors
	@Id
	@Column(name = "MERCHANT_ID", unique = true, nullable = false, length = 16)
	public String getMerchantId() {
		return this.merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	@Column(name = "LIM_01", precision = 16, scale = 0)
	public Long getLim01() {
		return this.lim01;
	}

	public void setLim01(Long lim01) {
		this.lim01 = lim01;
	}

	@Column(name = "LIM_02", precision = 16, scale = 0)
	public Long getLim02() {
		return this.lim02;
	}

	public void setLim02(Long lim02) {
		this.lim02 = lim02;
	}

	@Column(name = "LIM_03", precision = 16, scale = 0)
	public Long getLim03() {
		return this.lim03;
	}

	public void setLim03(Long lim03) {
		this.lim03 = lim03;
	}

	@Column(name = "LIM_04", precision = 16, scale = 0)
	public Long getLim04() {
		return this.lim04;
	}

	public void setLim04(Long lim04) {
		this.lim04 = lim04;
	}

	@Column(name = "LIM_05", precision = 16, scale = 0)
	public Long getLim05() {
		return this.lim05;
	}

	public void setLim05(Long lim05) {
		this.lim05 = lim05;
	}

	@Column(name = "LIM_06", precision = 16, scale = 0)
	public Long getLim06() {
		return this.lim06;
	}

	public void setLim06(Long lim06) {
		this.lim06 = lim06;
	}

	@Column(name = "LIM_07", precision = 16, scale = 0)
	public Long getLim07() {
		return this.lim07;
	}

	public void setLim07(Long lim07) {
		this.lim07 = lim07;
	}

	@Column(name = "LIM_08", precision = 16, scale = 0)
	public Long getLim08() {
		return this.lim08;
	}

	public void setLim08(Long lim08) {
		this.lim08 = lim08;
	}

	@Column(name = "LIM_09", precision = 16, scale = 0)
	public Long getLim09() {
		return this.lim09;
	}

	public void setLim09(Long lim09) {
		this.lim09 = lim09;
	}

	@Column(name = "LIM_10", precision = 16, scale = 0)
	public Long getLim10() {
		return this.lim10;
	}

	public void setLim10(Long lim10) {
		this.lim10 = lim10;
	}

	@Column(name = "MERCHANT_NAME", precision = 16, scale = 0)
	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}
	

}