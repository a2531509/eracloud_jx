package com.erp.model;

import java.math.BigDecimal;
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
import javax.persistence.UniqueConstraint;

/**
 * CardRecoverReginfoTemp entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_RECOVER_REGINFO_TEMP", uniqueConstraints = {
		@UniqueConstraint(columnNames = { "CERT_NO", "CARD_NO" }),
		@UniqueConstraint(columnNames = "CARD_NO") })
@SequenceGenerator(name="SEQ_CardRecoverReginfo_Tmp",allocationSize=1,initialValue=10010089,sequenceName="SEQ_REC_CARD_TEMP_INFO" )
public class CardRecoverReginfoTemp implements java.io.Serializable {

	// Fields

	private Long id;
	private String cardNo;
	private Date recTime;
	private String recEmp;
	private String tranName;
	private String certNo;
	private String name;
	private Date appDate;
	private String branch;
	private String operId;
	private String operName;
	private String status;
	private String isDead;
	private Date ffDate;
	private String ffOperName;
	private String boxXh;
	private String appWay;
	private String appAddr;
	private String initialStatus;
	private Long recSureDealNo;
	private Long orderNo;

	// Constructors

	/** default constructor */
	public CardRecoverReginfoTemp() {
	}

	/** minimal constructor */
	public CardRecoverReginfoTemp(Long id) {
		this.id = id;
	}

	/** full constructor */
	public CardRecoverReginfoTemp(Long id, String cardNo, Date recTime,
			String recEmp, String tranName, String certNo, String name,
			Date appDate, String branch, String operId, String operName,
			String status, String isDead, Date ffDate, String ffOperName,
			String boxXh, String appWay, String appAddr, String initialStatus,
			Long recSureDealNo, Long orderNo) {
		this.id = id;
		this.cardNo = cardNo;
		this.recTime = recTime;
		this.recEmp = recEmp;
		this.tranName = tranName;
		this.certNo = certNo;
		this.name = name;
		this.appDate = appDate;
		this.branch = branch;
		this.operId = operId;
		this.operName = operName;
		this.status = status;
		this.isDead = isDead;
		this.ffDate = ffDate;
		this.ffOperName = ffOperName;
		this.boxXh = boxXh;
		this.appWay = appWay;
		this.appAddr = appAddr;
		this.initialStatus = initialStatus;
		this.recSureDealNo = recSureDealNo;
		this.orderNo = orderNo;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_CardRecoverReginfo_Tmp")
	@Column(name = "ID", unique = true, nullable = false, precision = 38, scale = 0)
	public Long getId() {
		return this.id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Column(name = "CARD_NO", unique = true, length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "REC_TIME", length = 7)
	public Date getRecTime() {
		return this.recTime;
	}

	public void setRecTime(Date recTime) {
		this.recTime = recTime;
	}

	@Column(name = "REC_EMP", length = 100)
	public String getRecEmp() {
		return this.recEmp;
	}

	public void setRecEmp(String recEmp) {
		this.recEmp = recEmp;
	}

	@Column(name = "TRAN_NAME", length = 20)
	public String getTranName() {
		return this.tranName;
	}

	public void setTranName(String tranName) {
		this.tranName = tranName;
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

	@Temporal(TemporalType.DATE)
	@Column(name = "APP_DATE", length = 7)
	public Date getAppDate() {
		return this.appDate;
	}

	public void setAppDate(Date appDate) {
		this.appDate = appDate;
	}

	@Column(name = "BRANCH", length = 50)
	public String getBranch() {
		return this.branch;
	}

	public void setBranch(String branch) {
		this.branch = branch;
	}

	@Column(name = "USER_ID", length = 20)
	public String getOperId() {
		return this.operId;
	}

	public void setOperId(String operId) {
		this.operId = operId;
	}

	@Column(name = "USER_NAME", length = 50)
	public String getOperName() {
		return this.operName;
	}

	public void setOperName(String operName) {
		this.operName = operName;
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

	@Temporal(TemporalType.DATE)
	@Column(name = "FF_DATE", length = 7)
	public Date getFfDate() {
		return this.ffDate;
	}

	public void setFfDate(Date ffDate) {
		this.ffDate = ffDate;
	}

	@Column(name = "FF_OPER_NAME", length = 25)
	public String getFfOperName() {
		return this.ffOperName;
	}

	public void setFfOperName(String ffOperName) {
		this.ffOperName = ffOperName;
	}

	@Column(name = "BOX_XH", length = 10)
	public String getBoxXh() {
		return this.boxXh;
	}

	public void setBoxXh(String boxXh) {
		this.boxXh = boxXh;
	}

	@Column(name = "APP_WAY", length = 2)
	public String getAppWay() {
		return this.appWay;
	}

	public void setAppWay(String appWay) {
		this.appWay = appWay;
	}

	@Column(name = "APP_ADDR", length = 300)
	public String getAppAddr() {
		return this.appAddr;
	}

	public void setAppAddr(String appAddr) {
		this.appAddr = appAddr;
	}

	@Column(name = "INITIAL_STATUS", length = 2)
	public String getInitialStatus() {
		return this.initialStatus;
	}

	public void setInitialStatus(String initialStatus) {
		this.initialStatus = initialStatus;
	}

	@Column(name = "REC_SURE_DEAL_NO", precision = 38, scale = 0)
	public Long getRecSureDealNo() {
		return this.recSureDealNo;
	}

	public void setRecSureDealNo(Long recSureDealNo) {
		this.recSureDealNo = recSureDealNo;
	}

	@Column(name = "ORDER_NO", precision = 38, scale = 0)
	public Long getOrderNo() {
		return this.orderNo;
	}

	public void setOrderNo(Long orderNo) {
		this.orderNo = orderNo;
	}

}