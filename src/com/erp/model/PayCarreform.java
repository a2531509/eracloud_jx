package com.erp.model;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.Date;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Version;

/**
 * PayCarreform entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "PAY_CARREFORM")
public class PayCarreform implements java.io.Serializable {
	private static final long serialVersionUID = 1L;
	// Fields

	private PayCarreformId id;
	private String provideYear;
	private String provideMonth;
	private String provideDay;
	private String name;
	private String empName;
	private String cardNo;
	private BigDecimal provideAmt;
	private String state;
	private Date rechgDate;
	private BigDecimal rechgActionNo;
	private String failureReason;
	private String balanceEncrypt;
	private String corpId;
	private Long version;

	// Constructors

	/** default constructor */
	public PayCarreform() {
	}

	/** minimal constructor */
	public PayCarreform(PayCarreformId id, String provideYear,
			String provideMonth, String name, BigDecimal provideAmt,
			String state) {
		this.id = id;
		this.provideYear = provideYear;
		this.provideMonth = provideMonth;
		this.name = name;
		this.provideAmt = provideAmt;
		this.state = state;
	}

	/** full constructor */
	public PayCarreform(PayCarreformId id, String provideYear,
			String provideMonth, String name, String empName, String cardNo,
			BigDecimal provideAmt, String state, Timestamp rechgDate,
			BigDecimal rechgActionNo, String failureReason,
			String balanceEncrypt) {
		this.id = id;
		this.provideYear = provideYear;
		this.provideMonth = provideMonth;
		this.name = name;
		this.empName = empName;
		this.cardNo = cardNo;
		this.provideAmt = provideAmt;
		this.state = state;
		this.rechgDate = rechgDate;
		this.rechgActionNo = rechgActionNo;
		this.failureReason = failureReason;
		this.balanceEncrypt = balanceEncrypt;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "batchNumber", column = @Column(name = "BATCH_NUMBER", nullable = false, length = 15)),
			@AttributeOverride(name = "certNo", column = @Column(name = "CERT_NO", nullable = false, length = 18)) })
	public PayCarreformId getId() {
		return this.id;
	}

	public void setId(PayCarreformId id) {
		this.id = id;
	}

	@Column(name = "PROVIDE_YEAR", nullable = false, length = 4)
	public String getProvideYear() {
		return this.provideYear;
	}

	public void setProvideYear(String provideYear) {
		this.provideYear = provideYear;
	}

	@Column(name = "PROVIDE_MONTH", nullable = false, length = 2)
	public String getProvideMonth() {
		return this.provideMonth;
	}

	public void setProvideMonth(String provideMonth) {
		this.provideMonth = provideMonth;
	}

	@Column(name="provide_day")
	public String getProvideDay() {
		return provideDay;
	}

	public void setProvideDay(String provideDay) {
		this.provideDay = provideDay;
	}

	@Column(name = "NAME", nullable = false, length = 32)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "EMP_NAME", length = 64)
	public String getEmpName() {
		return this.empName;
	}

	public void setEmpName(String empName) {
		this.empName = empName;
	}

	@Column(name = "CARD_NO", length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "PROVIDE_AMT", nullable = false, precision = 22, scale = 0)
	public BigDecimal getProvideAmt() {
		return this.provideAmt;
	}

	public void setProvideAmt(BigDecimal provideAmt) {
		this.provideAmt = provideAmt;
	}

	@Column(name = "STATE", nullable = false, length = 1)
	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "RECHG_DATE", length = 7)
	public Date getRechgDate() {
		return this.rechgDate;
	}

	public void setRechgDate(Date rechgDate) {
		this.rechgDate = rechgDate;
	}

	@Column(name = "RECHG_ACTION_NO", precision = 22, scale = 0)
	public BigDecimal getRechgActionNo() {
		return this.rechgActionNo;
	}

	public void setRechgActionNo(BigDecimal rechgActionNo) {
		this.rechgActionNo = rechgActionNo;
	}

	@Column(name = "FAILURE_REASON", length = 80)
	public String getFailureReason() {
		return this.failureReason;
	}

	public void setFailureReason(String failureReason) {
		this.failureReason = failureReason;
	}

	@Column(name = "BALANCE_ENCRYPT", length = 128)
	public String getBalanceEncrypt() {
		return this.balanceEncrypt;
	}

	public void setBalanceEncrypt(String balanceEncrypt) {
		this.balanceEncrypt = balanceEncrypt;
	}

	@Column(name = "corp_id")
	public String getCorpId() {
		return corpId;
	}

	public void setCorpId(String corpId) {
		this.corpId = corpId;
	}

	@Version
	@Column(name = "version")
	public Long getVersion() {
		return version;
	}

	public void setVersion(Long version) {
		this.version = version;
	}

}