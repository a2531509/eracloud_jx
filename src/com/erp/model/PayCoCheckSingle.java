package com.erp.model;

import java.math.BigDecimal;
import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * PayCoCheckSingle entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "PAY_CO_CHECK_SINGLE")
public class PayCoCheckSingle implements java.io.Serializable {

	// Fields

	private Long id;
	private String cardOrgId;
	private String coOrgId;
	private String acptId;
	private String fileType;
	private String fileName;
	private String checkDate;
	private String existDetail;
	private Long totalZcSum;
	private Long totalZcAmt;
	private Long totalCxSum;
	private Long totalCxAmt;
	private Long totalThSum;
	private Long totalThAmt;
	private Long totalZcfromaddSum;
	private Long totalZcfromaddAmt;
	private Long totalCxfromaddSum;
	private Long totalCxfromaddAmt;
	private Long totalThfromaddSum;
	private Long totalThfromaddAmt;
	private Long totalZctoaddNum;
	private Long totalZctoaddAmt;
	private Long totalCxtoaddNum;
	private Long totalCxtoaddAmt;
	private Long totalThtoaddNum;
	private Long totalThtoaddAmt;
	private Long sjTotalZcSum;
	private Long sjTotalZcAmt;
	private Long sjTotalCxSum;
	private Long sjTotalCxAmt;
	private Long sjTotalThSum;
	private Long sjTotalThAmt;
	private Date insertDate;
	private Date lastCheckTime;
	private String procState;
	private String jsState;
	private String remitNo;
	private String jsUserId;
	private Date jsDate;
	private Long dealNo;
	private String dzpzlx;

	// Constructors

	/** default constructor */
	public PayCoCheckSingle() {
	}

	/** minimal constructor */
	public PayCoCheckSingle(long id, String cardOrgId, String coOrgId,
			String acptId, String fileType, String fileName) {
		this.id = id;
		this.cardOrgId = cardOrgId;
		this.coOrgId = coOrgId;
		this.acptId = acptId;
		this.fileType = fileType;
		this.fileName = fileName;
	}

	/** full constructor */
	public PayCoCheckSingle(Long id, String cardOrgId, String coOrgId,
			String acptId, String fileType, String fileName, String checkDate,
			String existDetail, Long totalZcSum, Long totalZcAmt,
			Long totalCxSum, Long totalCxAmt, Long totalThSum, Long totalThAmt,
			Long totalZcfromaddSum, Long totalZcfromaddAmt,
			Long totalCxfromaddSum, Long totalCxfromaddAmt,
			Long totalThfromaddSum, Long totalThfromaddAmt,
			Long totalZctoaddNum, Long totalZctoaddAmt, Long totalCxtoaddNum,
			Long totalCxtoaddAmt, Long totalThtoaddNum, Long totalThtoaddAmt,
			Long sjTotalZcSum, Long sjTotalZcAmt, Long sjTotalCxSum,
			Long sjTotalCxAmt, Long sjTotalThSum, Long sjTotalThAmt,
			Date insertDate, Date lastCheckTime, String procState,
			String jsState, String remitNo, String jsUserId, Date jsDate,
			Long dealNo, String dzpzlx) {
		this.id = id;
		this.cardOrgId = cardOrgId;
		this.coOrgId = coOrgId;
		this.acptId = acptId;
		this.fileType = fileType;
		this.fileName = fileName;
		this.checkDate = checkDate;
		this.existDetail = existDetail;
		this.totalZcSum = totalZcSum;
		this.totalZcAmt = totalZcAmt;
		this.totalCxSum = totalCxSum;
		this.totalCxAmt = totalCxAmt;
		this.totalThSum = totalThSum;
		this.totalThAmt = totalThAmt;
		this.totalZcfromaddSum = totalZcfromaddSum;
		this.totalZcfromaddAmt = totalZcfromaddAmt;
		this.totalCxfromaddSum = totalCxfromaddSum;
		this.totalCxfromaddAmt = totalCxfromaddAmt;
		this.totalThfromaddSum = totalThfromaddSum;
		this.totalThfromaddAmt = totalThfromaddAmt;
		this.totalZctoaddNum = totalZctoaddNum;
		this.totalZctoaddAmt = totalZctoaddAmt;
		this.totalCxtoaddNum = totalCxtoaddNum;
		this.totalCxtoaddAmt = totalCxtoaddAmt;
		this.totalThtoaddNum = totalThtoaddNum;
		this.totalThtoaddAmt = totalThtoaddAmt;
		this.sjTotalZcSum = sjTotalZcSum;
		this.sjTotalZcAmt = sjTotalZcAmt;
		this.sjTotalCxSum = sjTotalCxSum;
		this.sjTotalCxAmt = sjTotalCxAmt;
		this.sjTotalThSum = sjTotalThSum;
		this.sjTotalThAmt = sjTotalThAmt;
		this.insertDate = insertDate;
		this.lastCheckTime = lastCheckTime;
		this.procState = procState;
		this.jsState = jsState;
		this.remitNo = remitNo;
		this.jsUserId = jsUserId;
		this.jsDate = jsDate;
		this.dealNo = dealNo;
		this.dzpzlx = dzpzlx;
	}

	// Property accessors
	@Id
	@Column(name = "ID", unique = true, nullable = false, precision = 38, scale = 0)
	public Long getId() {
		return this.id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Column(name = "CARD_ORG_ID", nullable = false, length = 4)
	public String getCardOrgId() {
		return this.cardOrgId;
	}

	public void setCardOrgId(String cardOrgId) {
		this.cardOrgId = cardOrgId;
	}

	@Column(name = "CO_ORG_ID", nullable = false, length = 15)
	public String getCoOrgId() {
		return this.coOrgId;
	}

	public void setCoOrgId(String coOrgId) {
		this.coOrgId = coOrgId;
	}

	@Column(name = "ACPT_ID", nullable = false, length = 15)
	public String getAcptId() {
		return this.acptId;
	}

	public void setAcptId(String acptId) {
		this.acptId = acptId;
	}

	@Column(name = "FILE_TYPE", nullable = false, length = 2)
	public String getFileType() {
		return this.fileType;
	}

	public void setFileType(String fileType) {
		this.fileType = fileType;
	}

	@Column(name = "FILE_NAME", nullable = false, length = 100)
	public String getFileName() {
		return this.fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	@Column(name = "CHECK_DATE", length = 8)
	public String getCheckDate() {
		return this.checkDate;
	}

	public void setCheckDate(String checkDate) {
		this.checkDate = checkDate;
	}

	@Column(name = "EXIST_DETAIL", length = 1)
	public String getExistDetail() {
		return this.existDetail;
	}

	public void setExistDetail(String existDetail) {
		this.existDetail = existDetail;
	}

	@Column(name = "TOTAL_ZC_SUM", precision = 16, scale = 0)
	public Long getTotalZcSum() {
		return this.totalZcSum;
	}

	public void setTotalZcSum(Long totalZcSum) {
		this.totalZcSum = totalZcSum;
	}

	@Column(name = "TOTAL_ZC_AMT", precision = 16, scale = 0)
	public Long getTotalZcAmt() {
		return this.totalZcAmt;
	}

	public void setTotalZcAmt(Long totalZcAmt) {
		this.totalZcAmt = totalZcAmt;
	}

	@Column(name = "TOTAL_CX_SUM", precision = 16, scale = 0)
	public Long getTotalCxSum() {
		return this.totalCxSum;
	}

	public void setTotalCxSum(Long totalCxSum) {
		this.totalCxSum = totalCxSum;
	}

	@Column(name = "TOTAL_CX_AMT", precision = 16, scale = 0)
	public Long getTotalCxAmt() {
		return this.totalCxAmt;
	}

	public void setTotalCxAmt(Long totalCxAmt) {
		this.totalCxAmt = totalCxAmt;
	}

	@Column(name = "TOTAL_TH_SUM", precision = 16, scale = 0)
	public Long getTotalThSum() {
		return this.totalThSum;
	}

	public void setTotalThSum(Long totalThSum) {
		this.totalThSum = totalThSum;
	}

	@Column(name = "TOTAL_TH_AMT", precision = 16, scale = 0)
	public Long getTotalThAmt() {
		return this.totalThAmt;
	}

	public void setTotalThAmt(Long totalThAmt) {
		this.totalThAmt = totalThAmt;
	}

	@Column(name = "TOTAL_ZCFROMADD_SUM", precision = 16, scale = 0)
	public Long getTotalZcfromaddSum() {
		return this.totalZcfromaddSum;
	}

	public void setTotalZcfromaddSum(Long totalZcfromaddSum) {
		this.totalZcfromaddSum = totalZcfromaddSum;
	}

	@Column(name = "TOTAL_ZCFROMADD_AMT", precision = 16, scale = 0)
	public Long getTotalZcfromaddAmt() {
		return this.totalZcfromaddAmt;
	}

	public void setTotalZcfromaddAmt(Long totalZcfromaddAmt) {
		this.totalZcfromaddAmt = totalZcfromaddAmt;
	}

	@Column(name = "TOTAL_CXFROMADD_SUM", precision = 16, scale = 0)
	public Long getTotalCxfromaddSum() {
		return this.totalCxfromaddSum;
	}

	public void setTotalCxfromaddSum(Long totalCxfromaddSum) {
		this.totalCxfromaddSum = totalCxfromaddSum;
	}

	@Column(name = "TOTAL_CXFROMADD_AMT", precision = 16, scale = 0)
	public Long getTotalCxfromaddAmt() {
		return this.totalCxfromaddAmt;
	}

	public void setTotalCxfromaddAmt(Long totalCxfromaddAmt) {
		this.totalCxfromaddAmt = totalCxfromaddAmt;
	}

	@Column(name = "TOTAL_THFROMADD_SUM", precision = 16, scale = 0)
	public Long getTotalThfromaddSum() {
		return this.totalThfromaddSum;
	}

	public void setTotalThfromaddSum(Long totalThfromaddSum) {
		this.totalThfromaddSum = totalThfromaddSum;
	}

	@Column(name = "TOTAL_THFROMADD_AMT", precision = 16, scale = 0)
	public Long getTotalThfromaddAmt() {
		return this.totalThfromaddAmt;
	}

	public void setTotalThfromaddAmt(Long totalThfromaddAmt) {
		this.totalThfromaddAmt = totalThfromaddAmt;
	}

	@Column(name = "TOTAL_ZCTOADD_NUM", precision = 16, scale = 0)
	public Long getTotalZctoaddNum() {
		return this.totalZctoaddNum;
	}

	public void setTotalZctoaddNum(Long totalZctoaddNum) {
		this.totalZctoaddNum = totalZctoaddNum;
	}

	@Column(name = "TOTAL_ZCTOADD_AMT", precision = 16, scale = 0)
	public Long getTotalZctoaddAmt() {
		return this.totalZctoaddAmt;
	}

	public void setTotalZctoaddAmt(Long totalZctoaddAmt) {
		this.totalZctoaddAmt = totalZctoaddAmt;
	}

	@Column(name = "TOTAL_CXTOADD_NUM", precision = 16, scale = 0)
	public Long getTotalCxtoaddNum() {
		return this.totalCxtoaddNum;
	}

	public void setTotalCxtoaddNum(Long totalCxtoaddNum) {
		this.totalCxtoaddNum = totalCxtoaddNum;
	}

	@Column(name = "TOTAL_CXTOADD_AMT", precision = 16, scale = 0)
	public Long getTotalCxtoaddAmt() {
		return this.totalCxtoaddAmt;
	}

	public void setTotalCxtoaddAmt(Long totalCxtoaddAmt) {
		this.totalCxtoaddAmt = totalCxtoaddAmt;
	}

	@Column(name = "TOTAL_THTOADD_NUM", precision = 16, scale = 0)
	public Long getTotalThtoaddNum() {
		return this.totalThtoaddNum;
	}

	public void setTotalThtoaddNum(Long totalThtoaddNum) {
		this.totalThtoaddNum = totalThtoaddNum;
	}

	@Column(name = "TOTAL_THTOADD_AMT", precision = 16, scale = 0)
	public Long getTotalThtoaddAmt() {
		return this.totalThtoaddAmt;
	}

	public void setTotalThtoaddAmt(Long totalThtoaddAmt) {
		this.totalThtoaddAmt = totalThtoaddAmt;
	}

	@Column(name = "SJ_TOTAL_ZC_SUM", precision = 16, scale = 0)
	public Long getSjTotalZcSum() {
		return this.sjTotalZcSum;
	}

	public void setSjTotalZcSum(Long sjTotalZcSum) {
		this.sjTotalZcSum = sjTotalZcSum;
	}

	@Column(name = "SJ_TOTAL_ZC_AMT", precision = 16, scale = 0)
	public Long getSjTotalZcAmt() {
		return this.sjTotalZcAmt;
	}

	public void setSjTotalZcAmt(Long sjTotalZcAmt) {
		this.sjTotalZcAmt = sjTotalZcAmt;
	}

	@Column(name = "SJ_TOTAL_CX_SUM", precision = 16, scale = 0)
	public Long getSjTotalCxSum() {
		return this.sjTotalCxSum;
	}

	public void setSjTotalCxSum(Long sjTotalCxSum) {
		this.sjTotalCxSum = sjTotalCxSum;
	}

	@Column(name = "SJ_TOTAL_CX_AMT", precision = 16, scale = 0)
	public Long getSjTotalCxAmt() {
		return this.sjTotalCxAmt;
	}

	public void setSjTotalCxAmt(Long sjTotalCxAmt) {
		this.sjTotalCxAmt = sjTotalCxAmt;
	}

	@Column(name = "SJ_TOTAL_TH_SUM", precision = 16, scale = 0)
	public Long getSjTotalThSum() {
		return this.sjTotalThSum;
	}

	public void setSjTotalThSum(Long sjTotalThSum) {
		this.sjTotalThSum = sjTotalThSum;
	}

	@Column(name = "SJ_TOTAL_TH_AMT", precision = 16, scale = 0)
	public Long getSjTotalThAmt() {
		return this.sjTotalThAmt;
	}

	public void setSjTotalThAmt(Long sjTotalThAmt) {
		this.sjTotalThAmt = sjTotalThAmt;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "INSERT_DATE", length = 7)
	public Date getInsertDate() {
		return this.insertDate;
	}

	public void setInsertDate(Date insertDate) {
		this.insertDate = insertDate;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "LAST_CHECK_TIME", length = 7)
	public Date getLastCheckTime() {
		return this.lastCheckTime;
	}

	public void setLastCheckTime(Date lastCheckTime) {
		this.lastCheckTime = lastCheckTime;
	}

	@Column(name = "PROC_STATE", length = 1)
	public String getProcState() {
		return this.procState;
	}

	public void setProcState(String procState) {
		this.procState = procState;
	}

	@Column(name = "JS_STATE", length = 1)
	public String getJsState() {
		return this.jsState;
	}

	public void setJsState(String jsState) {
		this.jsState = jsState;
	}

	@Column(name = "REMIT_NO", length = 100)
	public String getRemitNo() {
		return this.remitNo;
	}

	public void setRemitNo(String remitNo) {
		this.remitNo = remitNo;
	}

	@Column(name = "JS_USER_ID", length = 8)
	public String getJsUserId() {
		return this.jsUserId;
	}

	public void setJsUserId(String jsUserId) {
		this.jsUserId = jsUserId;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "JS_DATE", length = 7)
	public Date getJsDate() {
		return this.jsDate;
	}

	public void setJsDate(Date jsDate) {
		this.jsDate = jsDate;
	}

	@Column(name = "DEAL_NO", precision = 38, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "DZPZLX", length = 2)
	public String getDzpzlx() {
		return this.dzpzlx;
	}

	public void setDzpzlx(String dzpzlx) {
		this.dzpzlx = dzpzlx;
	}

}