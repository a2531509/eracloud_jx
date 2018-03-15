package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * CardTaskBatch entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_TASK_BATCH")
public class CardTaskBatch implements java.io.Serializable {

	// Fields

	private String batchId;
	private String sendtowjwOrgId;
	private String sendtowjwBrchId;
	private String sendtowjwUserId;
	private Date sendtowjwDate;
	private String receivebywjwOrgId;
	private String receivebywjwBrchId;
	private String receivebywjwUserId;
	private Date receivebywjwDate;
	private String sendtobankOrgId;
	private String sendtobankBrchId;
	private String sendtobankUserId;
	private Date sendtobankDate;
	private String receivebybankOrgId;
	private String receivebybankBrchId;
	private String receivebybankUserId;
	private Date receivebybankDate;
	private String sendOrgId;
	private String sendBrchId;
	private String sendUserId;
	private Date sendDate;
	private String recvOrgId;
	private String recvBrchId;
	private String recvUserId;
	private Date recvTime;
	private String vendorId;
	private String makeWay;
	private String bankId;
	private String cardType;
	private Integer batchNum;
	private Integer dealNo;
	private Integer taskNum;
	private Integer yzkNum;
	private String exportBankState;

	// Constructors

	/** default constructor */
	public CardTaskBatch() {
	}

	/** minimal constructor */
	public CardTaskBatch(String batchId) {
		this.batchId = batchId;
	}

	/** full constructor */
	public CardTaskBatch(String batchId, String sendtowjwOrgId,
			String sendtowjwBrchId, String sendtowjwUserId,
			Date sendtowjwDate, String receivebywjwOrgId,
			String receivebywjwBrchId, String receivebywjwUserId,
			Date receivebywjwDate, String sendtobankOrgId,
			String sendtobankBrchId, String sendtobankUserId,
			Date sendtobankDate, String receivebybankOrgId,
			String receivebybankBrchId, String receivebybankUserId,
			Date receivebybankDate, String sendOrgId, String sendBrchId,
			String sendUserId, Date sendDate, String recvOrgId,
			String recvBrchId, String recvUserId, Date recvTime,
			String vendorId, String makeWay, String bankId, String cardType,
			Integer batchNum, Integer dealNo) {
		this.batchId = batchId;
		this.sendtowjwOrgId = sendtowjwOrgId;
		this.sendtowjwBrchId = sendtowjwBrchId;
		this.sendtowjwUserId = sendtowjwUserId;
		this.sendtowjwDate = sendtowjwDate;
		this.receivebywjwOrgId = receivebywjwOrgId;
		this.receivebywjwBrchId = receivebywjwBrchId;
		this.receivebywjwUserId = receivebywjwUserId;
		this.receivebywjwDate = receivebywjwDate;
		this.sendtobankOrgId = sendtobankOrgId;
		this.sendtobankBrchId = sendtobankBrchId;
		this.sendtobankUserId = sendtobankUserId;
		this.sendtobankDate = sendtobankDate;
		this.receivebybankOrgId = receivebybankOrgId;
		this.receivebybankBrchId = receivebybankBrchId;
		this.receivebybankUserId = receivebybankUserId;
		this.receivebybankDate = receivebybankDate;
		this.sendOrgId = sendOrgId;
		this.sendBrchId = sendBrchId;
		this.sendUserId = sendUserId;
		this.sendDate = sendDate;
		this.recvOrgId = recvOrgId;
		this.recvBrchId = recvBrchId;
		this.recvUserId = recvUserId;
		this.recvTime = recvTime;
		this.vendorId = vendorId;
		this.makeWay = makeWay;
		this.bankId = bankId;
		this.cardType = cardType;
		this.batchNum = batchNum;
		this.dealNo = dealNo;
	}

	// Property accessors
	@Id
	@Column(name = "BATCH_ID", unique = true, nullable = false, length = 10)
	public String getBatchId() {
		return this.batchId;
	}

	public void setBatchId(String batchId) {
		this.batchId = batchId;
	}

	@Column(name = "SENDTOWJW_ORG_ID", length = 20)
	public String getSendtowjwOrgId() {
		return this.sendtowjwOrgId;
	}

	public void setSendtowjwOrgId(String sendtowjwOrgId) {
		this.sendtowjwOrgId = sendtowjwOrgId;
	}

	@Column(name = "SENDTOWJW_BRCH_ID", length = 20)
	public String getSendtowjwBrchId() {
		return this.sendtowjwBrchId;
	}

	public void setSendtowjwBrchId(String sendtowjwBrchId) {
		this.sendtowjwBrchId = sendtowjwBrchId;
	}

	@Column(name = "SENDTOWJW_USER_ID", length = 20)
	public String getSendtowjwUserId() {
		return this.sendtowjwUserId;
	}

	public void setSendtowjwUserId(String sendtowjwUserId) {
		this.sendtowjwUserId = sendtowjwUserId;
	}

	@Column(name = "SENDTOWJW_DATE")
	@Temporal(TemporalType.TIMESTAMP)
	public Date getSendtowjwDate() {
		return this.sendtowjwDate;
	}

	public void setSendtowjwDate(Date sendtowjwDate) {
		this.sendtowjwDate = sendtowjwDate;
	}

	@Column(name = "RECEIVEBYWJW_ORG_ID", length = 20)
	public String getReceivebywjwOrgId() {
		return this.receivebywjwOrgId;
	}

	public void setReceivebywjwOrgId(String receivebywjwOrgId) {
		this.receivebywjwOrgId = receivebywjwOrgId;
	}

	@Column(name = "RECEIVEBYWJW_BRCH_ID", length = 20)
	public String getReceivebywjwBrchId() {
		return this.receivebywjwBrchId;
	}

	public void setReceivebywjwBrchId(String receivebywjwBrchId) {
		this.receivebywjwBrchId = receivebywjwBrchId;
	}

	@Column(name = "RECEIVEBYWJW_USER_ID", length = 20)
	public String getReceivebywjwUserId() {
		return this.receivebywjwUserId;
	}

	public void setReceivebywjwUserId(String receivebywjwUserId) {
		this.receivebywjwUserId = receivebywjwUserId;
	}

	@Column(name = "RECEIVEBYWJW_DATE")
	@Temporal(TemporalType.TIMESTAMP)
	public Date getReceivebywjwDate() {
		return this.receivebywjwDate;
	}

	public void setReceivebywjwDate(Date receivebywjwDate) {
		this.receivebywjwDate = receivebywjwDate;
	}

	@Column(name = "SENDTOBANK_ORG_ID", length = 20)
	public String getSendtobankOrgId() {
		return this.sendtobankOrgId;
	}

	public void setSendtobankOrgId(String sendtobankOrgId) {
		this.sendtobankOrgId = sendtobankOrgId;
	}

	@Column(name = "SENDTOBANK_BRCH_ID", length = 10)
	public String getSendtobankBrchId() {
		return this.sendtobankBrchId;
	}

	public void setSendtobankBrchId(String sendtobankBrchId) {
		this.sendtobankBrchId = sendtobankBrchId;
	}

	@Column(name = "SENDTOBANK_USER_ID", length = 10)
	public String getSendtobankUserId() {
		return this.sendtobankUserId;
	}

	public void setSendtobankUserId(String sendtobankUserId) {
		this.sendtobankUserId = sendtobankUserId;
	}

	@Column(name = "SENDTOBANK_DATE")
	@Temporal(TemporalType.TIMESTAMP)
	public Date getSendtobankDate() {
		return this.sendtobankDate;
	}

	public void setSendtobankDate(Date sendtobankDate) {
		this.sendtobankDate = sendtobankDate;
	}

	@Column(name = "RECEIVEBYBANK_ORG_ID", length = 20)
	public String getReceivebybankOrgId() {
		return this.receivebybankOrgId;
	}

	public void setReceivebybankOrgId(String receivebybankOrgId) {
		this.receivebybankOrgId = receivebybankOrgId;
	}

	@Column(name = "RECEIVEBYBANK_BRCH_ID", length = 10)
	public String getReceivebybankBrchId() {
		return this.receivebybankBrchId;
	}

	public void setReceivebybankBrchId(String receivebybankBrchId) {
		this.receivebybankBrchId = receivebybankBrchId;
	}

	@Column(name = "RECEIVEBYBANK_USER_ID", length = 10)
	public String getReceivebybankUserId() {
		return this.receivebybankUserId;
	}

	public void setReceivebybankUserId(String receivebybankUserId) {
		this.receivebybankUserId = receivebybankUserId;
	}

	@Column(name = "RECEIVEBYBANK_DATE")
	@Temporal(TemporalType.TIMESTAMP)
	public Date getReceivebybankDate() {
		return this.receivebybankDate;
	}

	public void setReceivebybankDate(Date receivebybankDate) {
		this.receivebybankDate = receivebybankDate;
	}

	@Column(name = "SEND_ORG_ID", length = 20)
	public String getSendOrgId() {
		return this.sendOrgId;
	}

	public void setSendOrgId(String sendOrgId) {
		this.sendOrgId = sendOrgId;
	}

	@Column(name = "SEND_BRCH_ID", length = 10)
	public String getSendBrchId() {
		return this.sendBrchId;
	}

	public void setSendBrchId(String sendBrchId) {
		this.sendBrchId = sendBrchId;
	}

	@Column(name = "SEND_USER_ID", length = 10)
	public String getSendUserId() {
		return this.sendUserId;
	}

	public void setSendUserId(String sendUserId) {
		this.sendUserId = sendUserId;
	}

	@Column(name = "SEND_DATE")
	@Temporal(TemporalType.TIMESTAMP)
	public Date getSendDate() {
		return this.sendDate;
	}

	public void setSendDate(Date sendDate) {
		this.sendDate = sendDate;
	}

	@Column(name = "RECV_ORG_ID", length = 20)
	public String getRecvOrgId() {
		return this.recvOrgId;
	}

	public void setRecvOrgId(String recvOrgId) {
		this.recvOrgId = recvOrgId;
	}

	@Column(name = "RECV_BRCH_ID", length = 10)
	public String getRecvBrchId() {
		return this.recvBrchId;
	}

	public void setRecvBrchId(String recvBrchId) {
		this.recvBrchId = recvBrchId;
	}

	@Column(name = "RECV_USER_ID", length = 10)
	public String getRecvUserId() {
		return this.recvUserId;
	}

	public void setRecvUserId(String recvUserId) {
		this.recvUserId = recvUserId;
	}

	@Column(name = "RECV_TIME")
	@Temporal(TemporalType.TIMESTAMP)
	public Date getRecvTime() {
		return this.recvTime;
	}

	public void setRecvTime(Date recvTime) {
		this.recvTime = recvTime;
	}

	@Column(name = "VENDOR_ID", length = 4)
	public String getVendorId() {
		return this.vendorId;
	}

	public void setVendorId(String vendorId) {
		this.vendorId = vendorId;
	}

	@Column(name = "MAKE_WAY", length = 1)
	public String getMakeWay() {
		return this.makeWay;
	}

	public void setMakeWay(String makeWay) {
		this.makeWay = makeWay;
	}

	@Column(name = "BANK_ID", length = 15)
	public String getBankId() {
		return this.bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	@Column(name = "CARD_TYPE", length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "BATCH_NUM", precision = 22, scale = 0)
	public Integer getBatchNum() {
		return this.batchNum;
	}

	public void setBatchNum(Integer batchNum) {
		this.batchNum = batchNum;
	}

	@Column(name = "DEAL_NO", precision = 38, scale = 0)
	public Integer getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Integer dealNo) {
		this.dealNo = dealNo;
	}

	/**
	 * @return the taskNum
	 */
	@Column(name = "TASK_NUM", precision = 3, scale = 0)
	public Integer getTaskNum() {
		return taskNum;
	}

	/**
	 * @param taskNum the taskNum to set
	 */
	public void setTaskNum(Integer taskNum) {
		this.taskNum = taskNum;
	}

	/**
	 * @return the yzkNum
	 */
	@Column(name = "YZK_NUM", precision = 3, scale = 0)
	public Integer getYzkNum() {
		return yzkNum;
	}

	/**
	 * @param yzkNum the yzkNum to set
	 */
	public void setYzkNum(Integer yzkNum) {
		this.yzkNum = yzkNum;
	}

	/**
	 * @return the exportBankState
	 */
	@Column(name = "EXPORT_BANK_STATE",length=1)
	public String getExportBankState() {
		return exportBankState;
	}

	/**
	 * @param exportBankState the exportBankState to set
	 */
	public void setExportBankState(String exportBankState) {
		this.exportBankState = exportBankState;
	}
}