package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * SysSmessages entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "SYS_SMESSAGES")
@SequenceGenerator(name="SEQ_SMS_NO",allocationSize=1,initialValue=1,sequenceName="SEQ_SYS_SMESSAGES")
public class SysSmessages implements java.io.Serializable {

	// Fields

	private Long smsNo;
	private String smsType;
	private String customerId;
	private String cardNo;
	private String mobileNo;
	private String content;
	private String rtnState;
	private String smsState;
	private String sendTime;
	private String userId;
	private Integer dealCode;
	private Long dealNo;
	private String createTime;
	private String mid;
	private String note;

	// Constructors

	/** default constructor */
	public SysSmessages() {
	}

	/** minimal constructor */
	public SysSmessages(Long smsNo, String smsType, String mobileNo,
			String content) {
		this.smsNo = smsNo;
		this.smsType = smsType;
		this.mobileNo = mobileNo;
		this.content = content;
	}

	/** full constructor */
	public SysSmessages(Long smsNo, String smsType, String customerId,
			String cardNo, String mobileNo, String content, String rtnState,
			String smsState, String sendTime, String operId, Integer dealCode,
			Long dealNo, String createTime, String mid, String note) {
		this.smsNo = smsNo;
		this.smsType = smsType;
		this.customerId = customerId;
		this.cardNo = cardNo;
		this.mobileNo = mobileNo;
		this.content = content;
		this.rtnState = rtnState;
		this.smsState = smsState;
		this.sendTime = sendTime;
		this.userId = operId;
		this.dealCode = dealCode;
		this.dealNo = dealNo;
		this.createTime = createTime;
		this.mid = mid;
		this.note = note;
	}

	// Property accessors
	@Id
	@Column(name = "SMS_NO", unique = true, nullable = false, precision = 38, scale = 0)
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_SMS_NO")
	public Long getSmsNo() {
		return this.smsNo;
	}

	public void setSmsNo(Long smsNo) {
		this.smsNo = smsNo;
	}

	@Column(name = "SMS_TYPE", nullable = false, length = 2)
	public String getSmsType() {
		return this.smsType;
	}

	public void setSmsType(String smsType) {
		this.smsType = smsType;
	}

	@Column(name = "CUSTOMER_ID", length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "CARD_NO", length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "MOBILE_NO", nullable = false, length = 20)
	public String getMobileNo() {
		return this.mobileNo;
	}

	public void setMobileNo(String mobileNo) {
		this.mobileNo = mobileNo;
	}

	@Column(name = "CONTENT", nullable = false, length = 512)
	public String getContent() {
		return this.content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	@Column(name = "RTN_STATE", length = 10)
	public String getRtnState() {
		return this.rtnState;
	}

	public void setRtnState(String rtnState) {
		this.rtnState = rtnState;
	}

	@Column(name = "SMS_STATE", length = 1)
	public String getSmsState() {
		return this.smsState;
	}

	public void setSmsState(String smsState) {
		this.smsState = smsState;
	}

	@Column(name = "SEND_TIME", length = 20)
	public String getSendTime() {
		return this.sendTime;
	}

	public void setSendTime(String sendTime) {
		this.sendTime = sendTime;
	}

	@Column(name = "USER_ID", length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "DEAL_CODE", precision = 8, scale = 8)
	public Integer getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(Integer dealCode) {
		this.dealCode = dealCode;
	}

	@Column(name = "DEAL_NO", precision = 38, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "CREATE_TIME", length = 20)
	public String getCreateTime() {
		return this.createTime;
	}

	public void setCreateTime(String createTime) {
		this.createTime = createTime;
	}

	@Column(name = "MID", length = 256)
	public String getMid() {
		return this.mid;
	}

	public void setMid(String mid) {
		this.mid = mid;
	}

	@Column(name = "NOTE", length = 512)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}