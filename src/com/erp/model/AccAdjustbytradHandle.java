package com.erp.model;

import java.io.Serializable;
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

@Entity
@Table(name = "ACC_ADJUSTBYTRAD_HANDLE")
@SequenceGenerator(name = "SEQ_ACC_ADJUSTBYTRAD_HANDLE", allocationSize = 1, initialValue = 1, sequenceName = "SEQ_ACC_ADJUSTBYTRAD_HANDLE")
public class AccAdjustbytradHandle implements Serializable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private String oldDealNo;
	private String cardNo;
	private String cardType;
	private String tradAmt;
	private Date tradTime;
	private String tradBatchNo;
	private String tradAcptId;
	private String tradEndId;
	private String tradEndDealNo;
	private String tradState;
	private String tradUserId;
	private String tradHandleUserId;
	private Date tradHandleTime;
	private String clrDate;

	public AccAdjustbytradHandle() {
	}

	public AccAdjustbytradHandle(Long id) {
		this.id = id;
	}

	public AccAdjustbytradHandle(Long id, String oldDealNo, String cardNo,
			String cardType, String tradAmt, Date tradTime, String tradBatchNo,
			String tradAcptId, String tradEndId, String tradEndDealNo,
			String tradState, String tradUserId, String tradHandleUserId,
			Date tradHandleTime) {
		super();
		this.id = id;
		this.oldDealNo = oldDealNo;
		this.cardNo = cardNo;
		this.cardType = cardType;
		this.tradAmt = tradAmt;
		this.tradTime = tradTime;
		this.tradBatchNo = tradBatchNo;
		this.tradAcptId = tradAcptId;
		this.tradEndId = tradEndId;
		this.tradEndDealNo = tradEndDealNo;
		this.tradState = tradState;
		this.tradUserId = tradUserId;
		this.tradHandleUserId = tradHandleUserId;
		this.tradHandleTime = tradHandleTime;
	}

	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_ACC_ADJUSTBYTRAD_HANDLE")
	@Column(name = "ID", unique = true, nullable = false, precision = 38, scale = 0)
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Column(name = "OLD_DEAL_NO", length = 20)
	public String getOldDealNo() {
		return oldDealNo;
	}

	public void setOldDealNo(String oldDealNo) {
		this.oldDealNo = oldDealNo;
	}

	@Column(name = "CARD_NO", length = 20)
	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "CARD_TYPE", length = 3)
	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "TRAD_AMT", length = 20)
	public String getTradAmt() {
		return tradAmt;
	}

	public void setTradAmt(String tradAmt) {
		this.tradAmt = tradAmt;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "TRAD_TIME", length = 7)
	public Date getTradTime() {
		return tradTime;
	}

	public void setTradTime(Date tradTime) {
		this.tradTime = tradTime;
	}

	@Column(name = "TRAD_BATCH_NO", length = 20)
	public String getTradBatchNo() {
		return tradBatchNo;
	}

	public void setTradBatchNo(String tradBatchNo) {
		this.tradBatchNo = tradBatchNo;
	}

	@Column(name = "TRAD_ACPT_ID", length = 15)
	public String getTradAcptId() {
		return tradAcptId;
	}

	public void setTradAcptId(String tradAcptId) {
		this.tradAcptId = tradAcptId;
	}

	@Column(name = "TRAD_END_ID", length = 20)
	public String getTradEndId() {
		return tradEndId;
	}

	public void setTradEndId(String tradEndId) {
		this.tradEndId = tradEndId;
	}

	@Column(name = "TRAD_END_DEAL_NO", length = 20)
	public String getTradEndDealNo() {
		return tradEndDealNo;
	}

	public void setTradEndDealNo(String tradEndDealNo) {
		this.tradEndDealNo = tradEndDealNo;
	}

	@Column(name = "TRAD_STATE", length = 1)
	public String getTradState() {
		return tradState;
	}

	public void setTradState(String tradState) {
		this.tradState = tradState;
	}

	@Column(name = "TRAD_USER_ID", length = 20)
	public String getTradUserId() {
		return tradUserId;
	}

	public void setTradUserId(String tradUserId) {
		this.tradUserId = tradUserId;
	}

	@Column(name = "TRAD_HANDLE_USER_ID", length = 20)
	public String getTradHandleUserId() {
		return tradHandleUserId;
	}

	public void setTradHandleUserId(String tradHandleUserId) {
		this.tradHandleUserId = tradHandleUserId;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "TRAD_HANDLE_TIME", length = 7)
	public Date getTradHandleTime() {
		return tradHandleTime;
	}

	public void setTradHandleTime(Date tradHandleTime) {
		this.tradHandleTime = tradHandleTime;
	}

	@Column(name = "TRAD_CLR_DATE", length = 10)
	public String getClrDate() {
		return clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}
}
