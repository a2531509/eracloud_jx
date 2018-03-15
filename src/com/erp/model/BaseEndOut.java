package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * BaseEndOut entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "BASE_END_OUT")
@SequenceGenerator(name="seqEndOutId",allocationSize=1,sequenceName="SEQ_BASE_END_OUT" )
public class BaseEndOut implements java.io.Serializable {

	// Fields

	private Long endOutId;
	private String outId;
	private String outDate;
	private String sellerName;
	private String sellerMobile;
	private String sellerLinkman;
	private String outNo;
	private String outGoodsState;
	private String userId;
	private Date operTime;
	private String note;

	// Constructors

	/** default constructor */
	public BaseEndOut() {
	}

	/** minimal constructor */
	public BaseEndOut(Long endOutId) {
		this.endOutId = endOutId;
	}

	/** full constructor */
	public BaseEndOut(Long endOutId, String outId, String outDate,
			String sellerName, String sellerMobile, String sellerLinkman,
			String outNo, String outGoodsState, String userId, Date operTime,
			String note) {
		this.endOutId = endOutId;
		this.outId = outId;
		this.outDate = outDate;
		this.sellerName = sellerName;
		this.sellerMobile = sellerMobile;
		this.sellerLinkman = sellerLinkman;
		this.outNo = outNo;
		this.outGoodsState = outGoodsState;
		this.userId = userId;
		this.operTime = operTime;
		this.note = note;
	}

	// Property accessors
	@Id
	@Column(name = "END_OUT_ID", unique = true, nullable = false, precision = 20, scale = 0)
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="seqEndOutId")
	public Long getEndOutId() {
		return this.endOutId;
	}

	public void setEndOutId(Long endOutId) {
		this.endOutId = endOutId;
	}

	@Column(name = "OUT_ID", length = 10)
	public String getOutId() {
		return this.outId;
	}

	public void setOutId(String outId) {
		this.outId = outId;
	}

	@Column(name = "OUT_DATE", length = 10)
	public String getOutDate() {
		return this.outDate;
	}

	public void setOutDate(String outDate) {
		this.outDate = outDate;
	}

	@Column(name = "SELLER_NAME", length = 30)
	public String getSellerName() {
		return this.sellerName;
	}

	public void setSellerName(String sellerName) {
		this.sellerName = sellerName;
	}

	@Column(name = "SELLER_MOBILE", length = 11)
	public String getSellerMobile() {
		return this.sellerMobile;
	}

	public void setSellerMobile(String sellerMobile) {
		this.sellerMobile = sellerMobile;
	}

	@Column(name = "SELLER_LINKMAN", length = 10)
	public String getSellerLinkman() {
		return this.sellerLinkman;
	}

	public void setSellerLinkman(String sellerLinkman) {
		this.sellerLinkman = sellerLinkman;
	}

	@Column(name = "OUT_NO", length = 30)
	public String getOutNo() {
		return this.outNo;
	}

	public void setOutNo(String outNo) {
		this.outNo = outNo;
	}

	@Column(name = "OUT_GOODS_STATE", length = 1)
	public String getOutGoodsState() {
		return this.outGoodsState;
	}

	public void setOutGoodsState(String outGoodsState) {
		this.outGoodsState = outGoodsState;
	}

	@Column(name = "USER_ID", length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "OPER_TIME", length = 7)
	public Date getOperTime() {
		return this.operTime;
	}

	public void setOperTime(Date operTime) {
		this.operTime = operTime;
	}

	@Column(name = "NOTE", length = 100)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}