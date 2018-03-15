package com.erp.model;

import java.util.Date;
import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * StockAcc entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "STOCK_ACC")
public class StockAcc implements java.io.Serializable {

	// Fields

	private StockAccId id;
	private String orgId;
	private String brchId;
	private String accName;
	private Long totNum;
	private Long totFaceVal;
	private Date openDate;
	private String authUserId;
	private Date clsDate;
	private String clsUserId;
	private Date lastDealDate;
	private String accState;
	private String note;

	// Constructors

	/** default constructor */
	public StockAcc() {
	}

	/** minimal constructor */
	public StockAcc(StockAccId id) {
		this.id = id;
	}

	/** full constructor */
	public StockAcc(StockAccId id, String orgId, String brchId, String accName,
			Long totNum, Long totFaceVal, Date openDate,
			String authUserId, Date clsDate, String clsUserId,
			Date lastDealDate, String accState, String note) {
		this.id = id;
		this.orgId = orgId;
		this.brchId = brchId;
		this.accName = accName;
		this.totNum = totNum;
		this.totFaceVal = totFaceVal;
		this.openDate = openDate;
		this.authUserId = authUserId;
		this.clsDate = clsDate;
		this.clsUserId = clsUserId;
		this.lastDealDate = lastDealDate;
		this.accState = accState;
		this.note = note;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "userId", column = @Column(name = "USER_ID", nullable = false, length = 10)),
			@AttributeOverride(name = "stkCode", column = @Column(name = "STK_CODE", nullable = false, length = 4)),
			@AttributeOverride(name = "goodsState", column = @Column(name = "GOODS_STATE", nullable = false, length = 1)) })
	public StockAccId getId() {
		return this.id;
	}

	public void setId(StockAccId id) {
		this.id = id;
	}

	@Column(name = "ORG_ID", length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "BRCH_ID", length = 8)
	public String getBrchId() {
		return this.brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	@Column(name = "ACC_NAME", length = 100)
	public String getAccName() {
		return this.accName;
	}

	public void setAccName(String accName) {
		this.accName = accName;
	}

	@Column(name = "TOT_NUM", precision = 38, scale = 0)
	public Long getTotNum() {
		return this.totNum;
	}

	public void setTotNum(Long totNum) {
		this.totNum = totNum;
	}

	@Column(name = "TOT_FACE_VAL", precision = 16, scale = 0)
	public Long getTotFaceVal() {
		return this.totFaceVal;
	}

	public void setTotFaceVal(Long totFaceVal) {
		this.totFaceVal = totFaceVal;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "OPEN_DATE", length = 7)
	public Date getOpenDate() {
		return this.openDate;
	}

	public void setOpenDate(Date openDate) {
		this.openDate = openDate;
	}

	@Column(name = "AUTH_USER_ID", length = 10)
	public String getAuthUserId() {
		return this.authUserId;
	}

	public void setAuthUserId(String authUserId) {
		this.authUserId = authUserId;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "CLS_DATE", length = 7)
	public Date getClsDate() {
		return this.clsDate;
	}

	public void setClsDate(Date clsDate) {
		this.clsDate = clsDate;
	}

	@Column(name = "CLS_USER_ID", length = 10)
	public String getClsUserId() {
		return this.clsUserId;
	}

	public void setClsUserId(String clsUserId) {
		this.clsUserId = clsUserId;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "LAST_DEAL_DATE", length = 7)
	public Date getLastDealDate() {
		return this.lastDealDate;
	}

	public void setLastDealDate(Date lastDealDate) {
		this.lastDealDate = lastDealDate;
	}

	@Column(name = "ACC_STATE", length = 1)
	public String getAccState() {
		return this.accState;
	}

	public void setAccState(String accState) {
		this.accState = accState;
	}

	@Column(name = "NOTE", length = 64)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}