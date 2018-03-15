package com.erp.model;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * StockRec entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "STOCK_REC")
public class StockRec implements java.io.Serializable {

	// Fields

	private Long stkSerNo;
	private Integer dealCode;
	private String stkCode;
	private String batchId;
	private String taskId;
	private String inOrgId;
	private String inBrchId;
	private String inUserId;
	private String inGoodsState;
	private String outOrgId;
	private String outBrchId;
	private String outUserId;
	private String outGoodsState;
	private String goodsId;
	private String goodsNo;
	private Integer goodsNums;
	private String inOutFlag;
	private Date trDate;
	private String orgId;
	private String brchId;
	private String userId;
	private String authOperId;
	private String bookState;
	private String clrDate;
	private Long dealNo;
	private String note;
	private String isSure;
	private String startNo;
	private String endNo;

	// Constructors

	/** default constructor */
	public StockRec() {
	}

	/** minimal constructor */
	public StockRec(Long stkSerNo, String stkCode, String goodsId,
			String userId, String clrDate, Long dealNo) {
		this.stkSerNo = stkSerNo;
		this.stkCode = stkCode;
		this.goodsId = goodsId;
		this.userId = userId;
		this.clrDate = clrDate;
		this.dealNo = dealNo;
	}

	/** full constructor */
	public StockRec(Long stkSerNo, Integer dealCode, String stkCode,
			String batchId, String taskId, String inOrgId, String inBrchId,
			String inUserId, String inGoodsState, String outOrgId,
			String outBrchId, String outUserId, String outGoodsState,
			String goodsId, String goodsNo, Integer goodsNums,
			String inOutFlag, Date trDate, String orgId, String brchId,
			String userId, String authOperId, String bookState, String clrDate,
			Long dealNo, String note, String isSure, String startNo,
			String endNo) {
		this.stkSerNo = stkSerNo;
		this.dealCode = dealCode;
		this.stkCode = stkCode;
		this.batchId = batchId;
		this.taskId = taskId;
		this.inOrgId = inOrgId;
		this.inBrchId = inBrchId;
		this.inUserId = inUserId;
		this.inGoodsState = inGoodsState;
		this.outOrgId = outOrgId;
		this.outBrchId = outBrchId;
		this.outUserId = outUserId;
		this.outGoodsState = outGoodsState;
		this.goodsId = goodsId;
		this.goodsNo = goodsNo;
		this.goodsNums = goodsNums;
		this.inOutFlag = inOutFlag;
		this.trDate = trDate;
		this.orgId = orgId;
		this.brchId = brchId;
		this.userId = userId;
		this.authOperId = authOperId;
		this.bookState = bookState;
		this.clrDate = clrDate;
		this.dealNo = dealNo;
		this.note = note;
		this.isSure = isSure;
		this.startNo = startNo;
		this.endNo = endNo;
	}

	// Property accessors
	@Id
	@Column(name = "STK_SER_NO", unique = true, nullable = false, precision = 38, scale = 0)
	public Long getStkSerNo() {
		return this.stkSerNo;
	}

	public void setStkSerNo(Long stkSerNo) {
		this.stkSerNo = stkSerNo;
	}

	@Column(name = "DEAL_CODE", precision = 8, scale = 0)
	public Integer getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(Integer dealCode) {
		this.dealCode = dealCode;
	}

	@Column(name = "STK_CODE", nullable = false, length = 4)
	public String getStkCode() {
		return this.stkCode;
	}

	public void setStkCode(String stkCode) {
		this.stkCode = stkCode;
	}

	@Column(name = "BATCH_ID", length = 10)
	public String getBatchId() {
		return this.batchId;
	}

	public void setBatchId(String batchId) {
		this.batchId = batchId;
	}

	@Column(name = "TASK_ID", length = 18)
	public String getTaskId() {
		return this.taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}

	@Column(name = "IN_ORG_ID", length = 4)
	public String getInOrgId() {
		return this.inOrgId;
	}

	public void setInOrgId(String inOrgId) {
		this.inOrgId = inOrgId;
	}

	@Column(name = "IN_BRCH_ID", length = 8)
	public String getInBrchId() {
		return this.inBrchId;
	}

	public void setInBrchId(String inBrchId) {
		this.inBrchId = inBrchId;
	}

	@Column(name = "IN_USER_ID", length = 10)
	public String getInUserId() {
		return this.inUserId;
	}

	public void setInUserId(String inUserId) {
		this.inUserId = inUserId;
	}

	@Column(name = "IN_GOODS_STATE", length = 1)
	public String getInGoodsState() {
		return this.inGoodsState;
	}

	public void setInGoodsState(String inGoodsState) {
		this.inGoodsState = inGoodsState;
	}

	@Column(name = "OUT_ORG_ID", length = 4)
	public String getOutOrgId() {
		return this.outOrgId;
	}

	public void setOutOrgId(String outOrgId) {
		this.outOrgId = outOrgId;
	}

	@Column(name = "OUT_BRCH_ID", length = 8)
	public String getOutBrchId() {
		return this.outBrchId;
	}

	public void setOutBrchId(String outBrchId) {
		this.outBrchId = outBrchId;
	}

	@Column(name = "OUT_USER_ID", length = 10)
	public String getOutUserId() {
		return this.outUserId;
	}

	public void setOutUserId(String outUserId) {
		this.outUserId = outUserId;
	}

	@Column(name = "OUT_GOODS_STATE", length = 1)
	public String getOutGoodsState() {
		return this.outGoodsState;
	}

	public void setOutGoodsState(String outGoodsState) {
		this.outGoodsState = outGoodsState;
	}

	@Column(name = "GOODS_ID", nullable = false, length = 50)
	public String getGoodsId() {
		return this.goodsId;
	}

	public void setGoodsId(String goodsId) {
		this.goodsId = goodsId;
	}

	@Column(name = "GOODS_NO", length = 20)
	public String getGoodsNo() {
		return this.goodsNo;
	}

	public void setGoodsNo(String goodsNo) {
		this.goodsNo = goodsNo;
	}

	@Column(name = "GOODS_NUMS", precision = 6, scale = 0)
	public Integer getGoodsNums() {
		return this.goodsNums;
	}

	public void setGoodsNums(Integer goodsNums) {
		this.goodsNums = goodsNums;
	}

	@Column(name = "IN_OUT_FLAG", length = 1)
	public String getInOutFlag() {
		return this.inOutFlag;
	}

	public void setInOutFlag(String inOutFlag) {
		this.inOutFlag = inOutFlag;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "TR_DATE", length = 7)
	public Date getTrDate() {
		return this.trDate;
	}

	public void setTrDate(Date trDate) {
		this.trDate = trDate;
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

	@Column(name = "USER_ID", nullable = false, length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "AUTH_OPER_ID", length = 10)
	public String getAuthOperId() {
		return this.authOperId;
	}

	public void setAuthOperId(String authOperId) {
		this.authOperId = authOperId;
	}

	@Column(name = "BOOK_STATE", length = 1)
	public String getBookState() {
		return this.bookState;
	}

	public void setBookState(String bookState) {
		this.bookState = bookState;
	}

	@Column(name = "CLR_DATE", nullable = false, length = 10)
	public String getClrDate() {
		return this.clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	@Column(name = "DEAL_NO", nullable = false, precision = 38, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "NOTE", length = 128)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "IS_SURE", length = 1)
	public String getIsSure() {
		return this.isSure;
	}

	public void setIsSure(String isSure) {
		this.isSure = isSure;
	}

	@Column(name = "START_NO", length = 20)
	public String getStartNo() {
		return this.startNo;
	}

	public void setStartNo(String startNo) {
		this.startNo = startNo;
	}

	@Column(name = "END_NO", length = 20)
	public String getEndNo() {
		return this.endNo;
	}

	public void setEndNo(String endNo) {
		this.endNo = endNo;
	}

}