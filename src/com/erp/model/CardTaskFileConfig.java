package com.erp.model;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * CardTaskFileConfig entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_TASK_FILE_CONFIG")
@SequenceGenerator(name="SEQ_TASK_FILE_CONFIG",allocationSize=1,initialValue=1,sequenceName="seq_cm_cardtask_list_select_id" )
public class CardTaskFileConfig implements java.io.Serializable {

	// Fields

	private Long id;
	private String cardTypeCatalog;
	private String flag;
	private String name;
	private Integer ordNo;
	private String note;

	// Constructors

	/** default constructor */
	public CardTaskFileConfig() {
	}

	/** minimal constructor */
	public CardTaskFileConfig(Long id, String cardTypeCatalog, String name) {
		this.id = id;
		this.cardTypeCatalog = cardTypeCatalog;
		this.name = name;
	}

	/** full constructor */
	public CardTaskFileConfig(Long id, String cardTypeCatalog,
			String flag, String name, Integer ordNo, String note) {
		this.id = id;
		this.cardTypeCatalog = cardTypeCatalog;
		this.flag = flag;
		this.name = name;
		this.ordNo = ordNo;
		this.note = note;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_TASK_FILE_CONFIG")
	@Column(name = "ID", unique = true, nullable = false, precision = 22, scale = 0)
	public Long getId() {
		return this.id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	@Column(name = "CARD_TYPE_CATALOG", nullable = false, length = 3)
	public String getCardTypeCatalog() {
		return this.cardTypeCatalog;
	}

	public void setCardTypeCatalog(String cardTypeCatalog) {
		this.cardTypeCatalog = cardTypeCatalog;
	}

	@Column(name = "FLAG", length = 1)
	public String getFlag() {
		return this.flag;
	}

	public void setFlag(String flag) {
		this.flag = flag;
	}

	@Column(name = "NAME", nullable = false, length = 30)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "ORD_NO", precision = 22, scale = 0)
	public Integer getOrdNo() {
		return this.ordNo;
	}

	public void setOrdNo(Integer ordNo) {
		this.ordNo = ordNo;
	}

	@Column(name = "NOTE", length = 120)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}