package com.erp.model;

import java.math.BigDecimal;
import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.UniqueConstraint;


/**
 * CardBlack entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_BLACK", uniqueConstraints = @UniqueConstraint(columnNames = "CARD_NO"))
public class CardBlack implements java.io.Serializable {

	// Fields

	private String cardId;
	private Long version;
	private String cardNo;
	private String orgId;
	private String blkType;
	private String blkState;
	private Date lastDate;

	// Constructors

	/** default constructor */
	public CardBlack() {
	}

	/** minimal constructor */
	public CardBlack(String cardId, String cardNo, String orgId) {
		this.cardId = cardId;
		this.cardNo = cardNo;
		this.orgId = orgId;
	}

	/** full constructor */
	public CardBlack(String cardId, String cardNo, String orgId,
			String blkType, String blkState, Date lastDate) {
		this.cardId = cardId;
		this.cardNo = cardNo;
		this.orgId = orgId;
		this.blkType = blkType;
		this.blkState = blkState;
		this.lastDate = lastDate;
	}

	// Property accessors
	@Id
	@Column(name = "CARD_ID", unique = true, nullable = false, length = 50)
	public String getCardId() {
		return this.cardId;
	}

	public void setCardId(String cardId) {
		this.cardId = cardId;
	}

	@Column(name = "VERSION", nullable = false, precision = 22, scale = 0)
	public Long getVersion() {
		return this.version;
	}

	public void setVersion(Long version) {
		this.version = version;
	}

	@Column(name = "CARD_NO", unique = true, nullable = false, length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "ORG_ID", nullable = false, length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "BLK_TYPE", length = 2)
	public String getBlkType() {
		return this.blkType;
	}

	public void setBlkType(String blkType) {
		this.blkType = blkType;
	}

	@Column(name = "BLK_STATE", length = 1)
	public String getBlkState() {
		return this.blkState;
	}

	public void setBlkState(String blkState) {
		this.blkState = blkState;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "LAST_DATE", length = 7)
	public Date getLastDate() {
		return this.lastDate;
	}

	public void setLastDate(Date lastDate) {
		this.lastDate = lastDate;
	}

}