package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * SysReport entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "SYS_REPORT")
public class SysReport implements java.io.Serializable {

	// Fields

	private Long dealNo;
	private String rpTitile;
	private String content;
	private String format;
	private String fileName;
	private String returnUrl;
	private String userId;
	private Date dealDate;
	private Long printTimes;
	private byte[] pdfContent;

	// Constructors

	/** default constructor */
	public SysReport() {
	}

	/** minimal constructor */
	public SysReport(Long dealNo) {
		this.dealNo = dealNo;
	}

	/** full constructor */
	public SysReport(Long dealNo, String rpTitile, String content,
			String format, String fileName, String returnUrl, String userId,
			Date dealDate, Long printTimes) {
		this.dealNo = dealNo;
		this.rpTitile = rpTitile;
		this.content = content;
		this.format = format;
		this.fileName = fileName;
		this.returnUrl = returnUrl;
		this.userId = userId;
		this.dealDate = dealDate;
		this.printTimes = printTimes;
	}

	// Property accessors
	@Id
	@Column(name = "DEAL_NO", unique = true, nullable = false, precision = 22, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "RP_TITILE", length = 100)
	public String getRpTitile() {
		return this.rpTitile;
	}

	public void setRpTitile(String rpTitile) {
		this.rpTitile = rpTitile;
	}

	@Column(name = "CONTENT", length = 1024)
	public String getContent() {
		return this.content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	@Column(name = "FORMAT", length = 1)
	public String getFormat() {
		return this.format;
	}

	public void setFormat(String format) {
		this.format = format;
	}

	@Column(name = "FILENAME", length = 128)
	public String getFileName() {
		return this.fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	@Column(name = "RETURN_URL", length = 128)
	public String getReturnUrl() {
		return this.returnUrl;
	}

	public void setReturnUrl(String returnUrl) {
		this.returnUrl = returnUrl;
	}

	@Column(name = "USER_ID", length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "DEAL_DATE")
	public Date getDealDate() {
		return this.dealDate;
	}

	public void setDealDate(Date dealDate) {
		this.dealDate = dealDate;
	}

	@Column(name = "PRINT_TIMES", precision = 10, scale = 0)
	public Long getPrintTimes() {
		return this.printTimes;
	}

	public void setPrintTimes(Long printTimes) {
		this.printTimes = printTimes;
	}

	@Column(name = "pdf_Content", precision = 10, scale = 0)
	public byte[] getPdfContent() {
		return pdfContent;
	}

	public void setPdfContent(byte[] pdfContent) {
		this.pdfContent = pdfContent;
	}

	
}