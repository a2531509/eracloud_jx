package com.erp.model;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * CardTaskImpTmp entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_TASK_IMP_TMP")
public class CardTaskImpTmp implements java.io.Serializable {

	// Fields

	private CardTaskImpTmpId id;

	// Constructors

	/** default constructor */
	public CardTaskImpTmp() {
	}

	/** full constructor */
	public CardTaskImpTmp(CardTaskImpTmpId id) {
		this.id = id;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "userId", column = @Column(name = "USER_ID", nullable = false, length = 10)),
			@AttributeOverride(name = "batchId", column = @Column(name = "BATCH_ID", nullable = false, length = 14)),
			@AttributeOverride(name = "taskId", column = @Column(name = "TASK_ID", nullable = false, length = 19)),
			@AttributeOverride(name = "dataSeq", column = @Column(name = "DATA_SEQ", nullable = false, precision = 22, scale = 0)),
			@AttributeOverride(name = "customerId", column = @Column(name = "CUSTOMER_ID", length = 10)),
			@AttributeOverride(name = "name", column = @Column(name = "NAME", length = 30)),
			@AttributeOverride(name = "sex", column = @Column(name = "SEX", length = 1)),
			@AttributeOverride(name = "certType", column = @Column(name = "CERT_TYPE", length = 2)),
			@AttributeOverride(name = "certNo", column = @Column(name = "CERT_NO", length = 36)),
			@AttributeOverride(name = "cardType", column = @Column(name = "CARD_TYPE", length = 3)),
			@AttributeOverride(name = "cardNo", column = @Column(name = "CARD_NO", length = 20)),
			@AttributeOverride(name = "cardTableName", column = @Column(name = "CARD_TABLE_NAME", length = 20)),
			@AttributeOverride(name = "structMainType", column = @Column(name = "STRUCT_MAIN_TYPE", length = 2)),
			@AttributeOverride(name = "structChildType", column = @Column(name = "STRUCT_CHILD_TYPE", length = 2)),
			@AttributeOverride(name = "bankcardno", column = @Column(name = "BANKCARDNO", length = 20)),
			@AttributeOverride(name = "cardId", column = @Column(name = "CARD_ID", nullable = false, length = 50)),
			@AttributeOverride(name = "statusid", column = @Column(name = "STATUSID", length = 1)),
			@AttributeOverride(name = "statustext", column = @Column(name = "STATUSTEXT", length = 512)),
			@AttributeOverride(name = "cityCode", column = @Column(name = "CITY_CODE", length = 10)),
			@AttributeOverride(name = "indusCode", column = @Column(name = "INDUS_CODE", length = 10)),
			@AttributeOverride(name = "ssseef0507", column = @Column(name = "SSSEEF0507", length = 20)),
			@AttributeOverride(name = "barCode", column = @Column(name = "BAR_CODE", length = 20)),
			@AttributeOverride(name = "atr", column = @Column(name = "ATR", length = 34)),
			@AttributeOverride(name = "rfatr", column = @Column(name = "RFATR", length = 50)) })
	public CardTaskImpTmpId getId() {
		return this.id;
	}

	public void setId(CardTaskImpTmpId id) {
		this.id = id;
	}

}