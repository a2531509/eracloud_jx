package com.erp.model;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * AccItem entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "ACC_ITEM")
public class AccItem implements java.io.Serializable {

	// Fields

	private String itemId;
	private String itemName;
	private String itemLvl;
	private String balType;
	private String topItemId;
	private String codeName;
	private Date openDate;
	private String openUserId;
	private String itemState;
	private String note;

	// Constructors

	/** default constructor */
	public AccItem() {
	}

	/** minimal constructor */
	public AccItem(String itemId, String balType) {
		this.itemId = itemId;
		this.balType = balType;
	}

	/** full constructor */
	public AccItem(String itemId, String itemName, String itemLvl,
			String balType, String topItemId, String codeName, Date openDate,
			String openUserId, String itemState, String note) {
		this.itemId = itemId;
		this.itemName = itemName;
		this.itemLvl = itemLvl;
		this.balType = balType;
		this.topItemId = topItemId;
		this.codeName = codeName;
		this.openDate = openDate;
		this.openUserId = openUserId;
		this.itemState = itemState;
		this.note = note;
	}

	// Property accessors
	@Id
	@Column(name = "ITEM_ID", unique = true, nullable = false, length = 6)
	public String getItemId() {
		return this.itemId;
	}

	public void setItemId(String itemId) {
		this.itemId = itemId;
	}

	@Column(name = "ITEM_NAME", length = 64)
	public String getItemName() {
		return this.itemName;
	}

	public void setItemName(String itemName) {
		this.itemName = itemName;
	}

	@Column(name = "ITEM_LVL", length = 1)
	public String getItemLvl() {
		return this.itemLvl;
	}

	public void setItemLvl(String itemLvl) {
		this.itemLvl = itemLvl;
	}

	@Column(name = "BAL_TYPE", nullable = false, length = 1)
	public String getBalType() {
		return this.balType;
	}

	public void setBalType(String balType) {
		this.balType = balType;
	}

	@Column(name = "TOP_ITEM_ID", length = 6)
	public String getTopItemId() {
		return this.topItemId;
	}

	public void setTopItemId(String topItemId) {
		this.topItemId = topItemId;
	}

	@Column(name = "CODE_NAME", length = 32)
	public String getCodeName() {
		return this.codeName;
	}

	public void setCodeName(String codeName) {
		this.codeName = codeName;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "OPEN_DATE", length = 7)
	public Date getOpenDate() {
		return this.openDate;
	}

	public void setOpenDate(Date openDate) {
		this.openDate = openDate;
	}

	@Column(name = "OPEN_USER_ID", length = 10)
	public String getOpenUserId() {
		return this.openUserId;
	}

	public void setOpenUserId(String openUserId) {
		this.openUserId = openUserId;
	}

	@Column(name = "ITEM_STATE", length = 1)
	public String getItemState() {
		return this.itemState;
	}

	public void setItemState(String itemState) {
		this.itemState = itemState;
	}

	@Column(name = "NOTE", length = 128)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}