package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * AccAdjustInfo entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "ACC_ADJUST_INFO", schema = "YRYF_01")
@SequenceGenerator(name="SEQ_ACC_ADJUST_INFO",allocationSize=1,initialValue=1,sequenceName="SEQ_ACC_ADJUST_INFO" )
public class AccAdjustInfo implements java.io.Serializable {

	// Fields

	private Long id;
	private String acptId;
	private String endId;
	private String batchId;
	private String endDealNo;
	private Long dealNo;
	private Long oldDealNo;
	private String cardInNo;
	private String clrDate;
	private Date trDate;
	private Long amt;
	private Long balAmt;
	private String userId;
	private String brchId;
	private String orgId;
	private String dealType;
	private String adjustType;
	private String note;
	private Date dealDate;
	private String cardOrgId;
	private String dealState;
	private String cardNo;



	// Constructors

	/** default constructor */
	public AccAdjustInfo() {
	}

	/** minimal constructor */
	public AccAdjustInfo(Long id) {
		this.id = id;
	}

	/** full constructor */
	public AccAdjustInfo(Long id, String acptId, String endId,
			String batchId, String endDealNo, Long dealNo,
			Long oldDealNo, String cardInNo, String clrDate, Date trDate,
			Long amt, Long balAmt, String userId, String brchId,
			String orgId, String dealType, String adjustType, String note,Date dealDate,String cardOrgId,String dealState,String cardNo) {
		this.id = id;
		this.acptId = acptId;
		this.endId = endId;
		this.batchId = batchId;
		this.endDealNo = endDealNo;
		this.dealNo = dealNo;
		this.oldDealNo = oldDealNo;
		this.cardInNo = cardInNo;
		this.clrDate = clrDate;
		this.trDate = trDate;
		this.amt = amt;
		this.balAmt = balAmt;
		this.userId = userId;
		this.brchId = brchId;
		this.orgId = orgId;
		this.dealType = dealType;
		this.adjustType = adjustType;
		this.note = note;
		this.dealDate = dealDate;
		this.cardOrgId = cardOrgId;
		this.dealState = dealState;
		this.cardNo = cardNo;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_ACC_ADJUST_INFO")
	@Column(name = "ID", unique = true, nullable = false, precision = 38, scale = 0)
	public Long getId() {
		return this.id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Column(name = "ACPT_ID", length = 15)
	public String getAcptId() {
		return this.acptId;
	}

	public void setAcptId(String acptId) {
		this.acptId = acptId;
	}

	@Column(name = "END_ID", length = 15)
	public String getEndId() {
		return this.endId;
	}

	public void setEndId(String endId) {
		this.endId = endId;
	}

	@Column(name = "BATCH_ID", length = 20)
	public String getBatchId() {
		return this.batchId;
	}

	public void setBatchId(String batchId) {
		this.batchId = batchId;
	}

	@Column(name = "END_DEAL_NO", length = 10)
	public String getEndDealNo() {
		return this.endDealNo;
	}

	public void setEndDealNo(String endDealNo) {
		this.endDealNo = endDealNo;
	}

	@Column(name = "DEAL_NO", precision = 38, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "OLD_DEAL_NO", precision = 38, scale = 0)
	public Long getOldDealNo() {
		return this.oldDealNo;
	}

	public void setOldDealNo(Long oldDealNo) {
		this.oldDealNo = oldDealNo;
	}

	@Column(name = "CARD_IN_NO", length = 30)
	public String getCardInNo() {
		return this.cardInNo;
	}

	public void setCardInNo(String cardInNo) {
		this.cardInNo = cardInNo;
	}

	@Column(name = "CLR_DATE", length = 10)
	public String getClrDate() {
		return this.clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "TR_DATE", length = 7)
	public Date getTrDate() {
		return this.trDate;
	}

	public void setTrDate(Date trDate) {
		this.trDate = trDate;
	}

	@Column(name = "AMT", precision = 38, scale = 0)
	public Long getAmt() {
		return this.amt;
	}

	public void setAmt(Long amt) {
		this.amt = amt;
	}

	@Column(name = "BAL_AMT", precision = 38, scale = 0)
	public Long getBalAmt() {
		return this.balAmt;
	}

	public void setBalAmt(Long balAmt) {
		this.balAmt = balAmt;
	}

	@Column(name = "USER_ID", length = 15)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "BRCH_ID", length = 15)
	public String getBrchId() {
		return this.brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	@Column(name = "ORG_ID", length = 15)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "DEAL_TYPE", length = 15)
	public String getDealType() {
		return this.dealType;
	}

	public void setDealType(String dealType) {
		this.dealType = dealType;
	}

	@Column(name = "ADJUST_TYPE", length = 2)
	public String getAdjustType() {
		return this.adjustType;
	}

	public void setAdjustType(String adjustType) {
		this.adjustType = adjustType;
	}

	@Column(name = "NOTE", length = 1000)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public Date getDealDate() {
		return dealDate;
	}

	public void setDealDate(Date dealDate) {
		this.dealDate = dealDate;
	}

	public String getCardOrgId() {
		return cardOrgId;
	}

	public void setCardOrgId(String cardOrgId) {
		this.cardOrgId = cardOrgId;
	}

	public String getDealState() {
		return dealState;
	}

	public void setDealState(String dealState) {
		this.dealState = dealState;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	
}