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
 * StockList entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "STOCK_LIST")
public class StockList implements java.io.Serializable {

	// Fields

	private StockListId id;
	private String goodsNo;
	private Long batchId;
	private String taskId;
	private String stkIsSure;
	private Date inDate;
	private String inBrchId;
	private String inUserId;
	private Long inDealNo;
	private Date outDate;
	private String outUserId;
	private String outBrchId;
	private Long outDealNo;
	private String ownType;
	private String orgId;
	private String brchId;
	private String userId;
	private String customerId;
	private String customerName;
	private String note;

	// Constructors

	/** default constructor */
	public StockList() {
	}

	/** minimal constructor */
	public StockList(StockListId id) {
		this.id = id;
	}

	/** full constructor */
	public StockList(StockListId id, String goodsNo, Long batchId,
			String taskId, String stkIsSure, Date inDate, String inUserId,
			Long inDealNo, Date outDate, String outUserId,
			Long outDealNo, String ownType, String orgId, String brchId,
			String userId, String customerId, String customerName, String note) {
		this.id = id;
		this.goodsNo = goodsNo;
		this.batchId = batchId;
		this.taskId = taskId;
		this.stkIsSure = stkIsSure;
		this.inDate = inDate;
		this.inUserId = inUserId;
		this.inDealNo = inDealNo;
		this.outDate = outDate;
		this.outUserId = outUserId;
		this.outDealNo = outDealNo;
		this.ownType = ownType;
		this.orgId = orgId;
		this.brchId = brchId;
		this.userId = userId;
		this.customerId = customerId;
		this.customerName = customerName;
		this.note = note;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "stkCode", column = @Column(name = "STK_CODE", nullable = false, length = 4)),
			@AttributeOverride(name = "goodsId", column = @Column(name = "GOODS_ID", nullable = false, length = 50)),
			@AttributeOverride(name = "goodsState", column = @Column(name = "GOODS_STATE", nullable = false, length = 1)) })
	public StockListId getId() {
		return this.id;
	}

	public void setId(StockListId id) {
		this.id = id;
	}

	@Column(name = "GOODS_NO", length = 20)
	public String getGoodsNo() {
		return this.goodsNo;
	}

	public void setGoodsNo(String goodsNo) {
		this.goodsNo = goodsNo;
	}

	@Column(name = "BATCH_ID", precision = 38, scale = 0)
	public Long getBatchId() {
		return this.batchId;
	}

	public void setBatchId(Long batchId) {
		this.batchId = batchId;
	}

	@Column(name = "TASK_ID", length = 18)
	public String getTaskId() {
		return this.taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}

	@Column(name = "STK_IS_SURE", length = 1)
	public String getStkIsSure() {
		return this.stkIsSure;
	}

	public void setStkIsSure(String stkIsSure) {
		this.stkIsSure = stkIsSure;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "IN_DATE", length = 7)
	public Date getInDate() {
		return this.inDate;
	}

	public void setInDate(Date inDate) {
		this.inDate = inDate;
	}

	@Column(name = "IN_USER_ID", length = 10)
	public String getInUserId() {
		return this.inUserId;
	}

	public void setInUserId(String inUserId) {
		this.inUserId = inUserId;
	}

	@Column(name = "IN_DEAL_NO", precision = 38, scale = 0)
	public Long getInDealNo() {
		return this.inDealNo;
	}

	public void setInDealNo(Long inDealNo) {
		this.inDealNo = inDealNo;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "OUT_DATE", length = 7)
	public Date getOutDate() {
		return this.outDate;
	}

	public void setOutDate(Date outDate) {
		this.outDate = outDate;
	}

	@Column(name = "OUT_USER_ID", length = 10)
	public String getOutUserId() {
		return this.outUserId;
	}

	public void setOutUserId(String outUserId) {
		this.outUserId = outUserId;
	}

	@Column(name = "OUT_DEAL_NO", precision = 38, scale = 0)
	public Long getOutDealNo() {
		return this.outDealNo;
	}

	public void setOutDealNo(Long outDealNo) {
		this.outDealNo = outDealNo;
	}

	@Column(name = "OWN_TYPE", length = 1)
	public String getOwnType() {
		return this.ownType;
	}

	public void setOwnType(String ownType) {
		this.ownType = ownType;
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

	@Column(name = "USER_ID", length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "CUSTOMER_ID", length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "CUSTOMER_NAME", length = 32)
	public String getCustomerName() {
		return this.customerName;
	}

	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}

	@Column(name = "NOTE", length = 128)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}
	@Column(name = "IN_BRCH_ID", length = 8)
	public String getInBrchId() {
		return inBrchId;
	}

	public void setInBrchId(String inBrchId) {
		this.inBrchId = inBrchId;
	}
	@Column(name = "OUT_BRCH_ID", length = 8)
	public String getOutBrchId() {
		return outBrchId;
	}

	public void setOutBrchId(String outBrchId) {
		this.outBrchId = outBrchId;
	}
}