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
 * CardRecoverReginfo entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_RECOVER_REGINFO")
@SequenceGenerator(name="SEQ_RECOVER_ID",allocationSize=1,initialValue=1,sequenceName="SEQ_CARD_RECOVER_REGINFO_ID" )
public class CardRecoverReginfo implements java.io.Serializable {

	// Fields

	private Long id;
	private String cardNo;
	private String certNo;
	private String name;
	private String appWay;
	private String appType;
	private Date appDate;
	private String appAddr;
	private String status;
	private String isDead;
	private Long orderNo;
	private String boxNo;
	private String brchId;
	private String userId;
	private Date recTime;
	private Long dealNo;
	private String ffBrchId;
	private String ffUserId;
	private Date ffDate;
	private Long ffDealNo;
	private String initialStatus;

	// Constructors

	/** default constructor */
	public CardRecoverReginfo() {
	}

	/** minimal constructor */
	public CardRecoverReginfo(Long id) {
		this.id = id;
	}

	/** full constructor */
	public CardRecoverReginfo(Long id, String cardNo, String certNo,
			String name, String appWay, String appType, Date appDate,
			String appAddr, String status, String isDead, Long orderNo,
			String boxNo, String brchId, String userId, Date recTime,
			Long dealNo, String ffBrchId, String ffUserId,
			Date ffDate, Long ffDealNo, String initialStatus) {
		this.id = id;
		this.cardNo = cardNo;
		this.certNo = certNo;
		this.name = name;
		this.appWay = appWay;
		this.appType = appType;
		this.appDate = appDate;
		this.appAddr = appAddr;
		this.status = status;
		this.isDead = isDead;
		this.orderNo = orderNo;
		this.boxNo = boxNo;
		this.brchId = brchId;
		this.userId = userId;
		this.recTime = recTime;
		this.dealNo = dealNo;
		this.ffBrchId = ffBrchId;
		this.ffUserId = ffUserId;
		this.ffDate = ffDate;
		this.ffDealNo = ffDealNo;
		this.initialStatus = initialStatus;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE, generator="SEQ_RECOVER_ID")
	@Column(name = "ID", unique = true, nullable = false, precision = 38, scale = 0)
	public Long getId() {
		return this.id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Column(name = "CARD_NO", length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "CERT_NO", length = 20)
	public String getCertNo() {
		return this.certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	@Column(name = "NAME", length = 10)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "APP_WAY", length = 2)
	public String getAppWay() {
		return this.appWay;
	}

	public void setAppWay(String appWay) {
		this.appWay = appWay;
	}

	@Column(name = "APP_TYPE", length = 2)
	public String getAppType() {
		return this.appType;
	}

	public void setAppType(String appType) {
		this.appType = appType;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "APP_DATE", length = 7)
	public Date getAppDate() {
		return this.appDate;
	}

	public void setAppDate(Date appDate) {
		this.appDate = appDate;
	}

	@Column(name = "APP_ADDR", length = 300)
	public String getAppAddr() {
		return this.appAddr;
	}

	public void setAppAddr(String appAddr) {
		this.appAddr = appAddr;
	}

	@Column(name = "STATUS", length = 1)
	public String getStatus() {
		return this.status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	@Column(name = "IS_DEAD", length = 1)
	public String getIsDead() {
		return this.isDead;
	}

	public void setIsDead(String isDead) {
		this.isDead = isDead;
	}

	@Column(name = "ORDER_NO", precision = 38, scale = 0)
	public Long getOrderNo() {
		return this.orderNo;
	}

	public void setOrderNo(Long orderNo) {
		this.orderNo = orderNo;
	}

	@Column(name = "BOX_NO", length = 10)
	public String getBoxNo() {
		return this.boxNo;
	}

	public void setBoxNo(String boxNo) {
		this.boxNo = boxNo;
	}

	@Column(name = "BRCH_ID", length = 50)
	public String getBrchId() {
		return this.brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	@Column(name = "USER_ID", length = 20)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "REC_TIME", length = 7)
	public Date getRecTime() {
		return this.recTime;
	}

	public void setRecTime(Date recTime) {
		this.recTime = recTime;
	}

	@Column(name = "DEAL_NO", precision = 38, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "FF_BRCH_ID", length = 50)
	public String getFfBrchId() {
		return this.ffBrchId;
	}

	public void setFfBrchId(String ffBrchId) {
		this.ffBrchId = ffBrchId;
	}

	@Column(name = "FF_USER_ID", length = 20)
	public String getFfUserId() {
		return this.ffUserId;
	}

	public void setFfUserId(String ffUserId) {
		this.ffUserId = ffUserId;
	}

	@Column(name = "FF_DATE", length = 7)
	public Date getFfDate() {
		return this.ffDate;
	}

	public void setFfDate(Date ffDate) {
		this.ffDate = ffDate;
	}

	@Column(name = "FF_DEAL_NO", precision = 38, scale = 0)
	public Long getFfDealNo() {
		return this.ffDealNo;
	}

	public void setFfDealNo(Long ffDealNo) {
		this.ffDealNo = ffDealNo;
	}

	@Column(name = "INITIAL_STATUS", length = 2)
	public String getInitialStatus() {
		return this.initialStatus;
	}

	public void setInitialStatus(String initialStatus) {
		this.initialStatus = initialStatus;
	}

}