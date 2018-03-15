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
import javax.persistence.UniqueConstraint;

import org.hibernate.annotations.GenericGenerator;

/**
 * BaseBankFile entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_BANK_FILE", uniqueConstraints = @UniqueConstraint(columnNames = "FILE_NAME"))
@SequenceGenerator(name="SEQ_BASE_BANK_FILE",sequenceName="SEQ_BASE_BANK_FILE",initialValue=1,allocationSize=1)
public class BaseBankFile implements java.io.Serializable {

	// Fields

	private Long seqId;
	private String batchId;
	private String cardType;
	private Long batchNum;
	private String bankId;
	private String fileName;
	private Long fileSize;
	private String transPatch;
	private String fileType;
	private String dealState;
	private Date outDate;
	private Date inDate;
	private String note;

	// Constructors

	/** default constructor */
	public BaseBankFile() {
	}

	/** minimal constructor */
	public BaseBankFile(Long seqId) {
		this.seqId = seqId;
	}

	/** full constructor */
	public BaseBankFile(Long seqId, String batchId, String cardType,
			Long batchNum, String bankId, String fileName, Long fileSize,
			String transPatch, String fileType, String dealState,
			Date outDate, Date inDate, String note) {
		this.seqId = seqId;
		this.batchId = batchId;
		this.cardType = cardType;
		this.batchNum = batchNum;
		this.bankId = bankId;
		this.fileName = fileName;
		this.fileSize = fileSize;
		this.transPatch = transPatch;
		this.fileType = fileType;
		this.dealState = dealState;
		this.outDate = outDate;
		this.inDate = inDate;
		this.note = note;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_BASE_BANK_FILE")
	@Column(name = "SEQ_ID", unique = true, nullable = false, length = 10)
	public Long getSeqId() {
		return this.seqId;
	}

	public void setSeqId(Long seqId) {
		this.seqId = seqId;
	}

	@Column(name = "BATCH_ID", length = 10)
	public String getBatchId() {
		return this.batchId;
	}

	public void setBatchId(String batchId) {
		this.batchId = batchId;
	}

	@Column(name = "CARD_TYPE", length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "BATCH_NUM", precision = 10, scale = 0)
	public Long getBatchNum() {
		return this.batchNum;
	}

	public void setBatchNum(Long batchNum) {
		this.batchNum = batchNum;
	}

	@Column(name = "BANK_ID", length = 15)
	public String getBankId() {
		return this.bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	@Column(name = "FILE_NAME", unique = true, length = 50)
	public String getFileName() {
		return this.fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	@Column(name = "FILE_SIZE", precision = 10, scale = 0)
	public Long getFileSize() {
		return this.fileSize;
	}

	public void setFileSize(Long fileSize) {
		this.fileSize = fileSize;
	}

	@Column(name = "TRANS_PATCH", length = 6)
	public String getTransPatch() {
		return this.transPatch;
	}

	public void setTransPatch(String transPatch) {
		this.transPatch = transPatch;
	}

	@Column(name = "FILE_TYPE", length = 6)
	public String getFileType() {
		return this.fileType;
	}

	public void setFileType(String fileType) {
		this.fileType = fileType;
	}

	@Column(name = "DEAL_STATE", length = 1)
	public String getDealState() {
		return this.dealState;
	}

	public void setDealState(String dealState) {
		this.dealState = dealState;
	}

	@Column(name = "OUT_DATE")
	@Temporal(TemporalType.TIMESTAMP)
	public Date getOutDate() {
		return this.outDate;
	}

	public void setOutDate(Date outDate) {
		this.outDate = outDate;
	}

	@Column(name = "IN_DATE")
	@Temporal(TemporalType.TIMESTAMP)
	public Date getInDate() {
		return this.inDate;
	}

	public void setInDate(Date inDate) {
		this.inDate = inDate;
	}

	@Column(name = "NOTE", length = 500)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}