package com.erp.model;
import java.io.Serializable;
import javax.persistence.*;


/**
 * The persistent class for the PAY_CO_DEAL_REC database table.
 * 
 */
@Entity
@Table(name="PAY_CO_DEAL_REC")
public class PayCoDealRec implements Serializable {
	private static final long serialVersionUID = 1L;

	@Id
	@Column(name="DEAL_NO")
	private long dealNo;

	@Column(name="ACC_KIND")
	private String accKind;

	@Column(name="ACC_TIME")
	private String accTime;

	@Column(name="ACPT_ID")
	private String acptId;

	@Column(name="ACPT_TYPE")
	private String acptType;

	private String amt;

	@Column(name="CANCEL_TIME")
	private String cancelTime;

	@Column(name="CARD_NO")
	private String cardNo;

	@Column(name="CHECK_TIME")
	private String checkTime;

	@Column(name="CHECK_USER_ID")
	private String checkUserId;

	@Column(name="CLR_DATE")
	private String clrDate;

	@Column(name="CONFIRM_TIME")
	private String confirmTime;

	@Column(name="DEAL_BATCH_NO")
	private String dealBatchNo;

	@Column(name="DEAL_CODE")
	private String dealCode;

	@Column(name="DEAL_STATE")
	private String dealState;

	@Column(name="DEAL_TYPE")
	private String dealType;

	@Column(name="DELETE_TIME")
	private String deleteTime;

	@Column(name="DZ_ACPT_ID")
	private String dzAcptId;

	@Column(name="END_DEAL_NO")
	private String endDealNo;

	@Column(name="ORDER_TIME")
	private String orderTime;

	@Column(name="RSV_FIVE")
	private String rsvFive;

	@Column(name="RSV_FOUR")
	private String rsvFour;

	@Column(name="RSV_ONE")
	private String rsvOne;

	@Column(name="RSV_THREE")
	private String rsvThree;

	@Column(name="RSV_TWO")
	private String rsvTwo;

	private String source;

	@Column(name="SOURCE_DESCRIPTION")
	private String sourceDescription;

	@Column(name="SOURCE_ID")
	private String sourceId;

	@Column(name="SOURCE_NAME")
	private String sourceName;

	@Column(name="USER_ID")
	private String userId;

	public PayCoDealRec() {
	}

	public long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(long dealNo) {
		this.dealNo = dealNo;
	}

	public String getAccKind() {
		return this.accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	public String getAccTime() {
		return this.accTime;
	}

	public void setAccTime(String accTime) {
		this.accTime = accTime;
	}

	public String getAcptId() {
		return this.acptId;
	}

	public void setAcptId(String acptId) {
		this.acptId = acptId;
	}

	public String getAcptType() {
		return this.acptType;
	}

	public void setAcptType(String acptType) {
		this.acptType = acptType;
	}

	public String getAmt() {
		return this.amt;
	}

	public void setAmt(String amt) {
		this.amt = amt;
	}

	public String getCancelTime() {
		return this.cancelTime;
	}

	public void setCancelTime(String cancelTime) {
		this.cancelTime = cancelTime;
	}

	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getCheckTime() {
		return this.checkTime;
	}

	public void setCheckTime(String checkTime) {
		this.checkTime = checkTime;
	}

	public String getCheckUserId() {
		return this.checkUserId;
	}

	public void setCheckUserId(String checkUserId) {
		this.checkUserId = checkUserId;
	}

	public String getClrDate() {
		return this.clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	public String getConfirmTime() {
		return this.confirmTime;
	}

	public void setConfirmTime(String confirmTime) {
		this.confirmTime = confirmTime;
	}

	public String getDealBatchNo() {
		return this.dealBatchNo;
	}

	public void setDealBatchNo(String dealBatchNo) {
		this.dealBatchNo = dealBatchNo;
	}

	public String getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(String dealCode) {
		this.dealCode = dealCode;
	}

	public String getDealState() {
		return this.dealState;
	}

	public void setDealState(String dealState) {
		this.dealState = dealState;
	}

	public String getDealType() {
		return this.dealType;
	}

	public void setDealType(String dealType) {
		this.dealType = dealType;
	}

	public String getDeleteTime() {
		return this.deleteTime;
	}

	public void setDeleteTime(String deleteTime) {
		this.deleteTime = deleteTime;
	}

	public String getDzAcptId() {
		return this.dzAcptId;
	}

	public void setDzAcptId(String dzAcptId) {
		this.dzAcptId = dzAcptId;
	}

	public String getEndDealNo() {
		return this.endDealNo;
	}

	public void setEndDealNo(String endDealNo) {
		this.endDealNo = endDealNo;
	}

	public String getOrderTime() {
		return this.orderTime;
	}

	public void setOrderTime(String orderTime) {
		this.orderTime = orderTime;
	}

	public String getRsvFive() {
		return this.rsvFive;
	}

	public void setRsvFive(String rsvFive) {
		this.rsvFive = rsvFive;
	}

	public String getRsvFour() {
		return this.rsvFour;
	}

	public void setRsvFour(String rsvFour) {
		this.rsvFour = rsvFour;
	}

	public String getRsvOne() {
		return this.rsvOne;
	}

	public void setRsvOne(String rsvOne) {
		this.rsvOne = rsvOne;
	}

	public String getRsvThree() {
		return this.rsvThree;
	}

	public void setRsvThree(String rsvThree) {
		this.rsvThree = rsvThree;
	}

	public String getRsvTwo() {
		return this.rsvTwo;
	}

	public void setRsvTwo(String rsvTwo) {
		this.rsvTwo = rsvTwo;
	}

	public String getSource() {
		return this.source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getSourceDescription() {
		return this.sourceDescription;
	}

	public void setSourceDescription(String sourceDescription) {
		this.sourceDescription = sourceDescription;
	}

	public String getSourceId() {
		return this.sourceId;
	}

	public void setSourceId(String sourceId) {
		this.sourceId = sourceId;
	}

	public String getSourceName() {
		return this.sourceName;
	}

	public void setSourceName(String sourceName) {
		this.sourceName = sourceName;
	}

	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

}