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

@Entity
@Table(name = "BASE_MERCHANT_DISCOUNT")
@SequenceGenerator(name = "seq", sequenceName = "SEQ_BASE_MERCHANT_DISCOUNT")
public class MerchantDiscount {
	/** 待审核 */
	public static final String STATE_UNCHECKED = "0";
	/** 已审核 */
	public static final String STATE_CHECKED = "1";
	/** 待注销 */
	public static final String STATE_CANCEL = "3";

	@Id
	@Column(name = "id")
	@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "seq")
	private Long id;

	@Column(name = "merchant_id")
	private String merchantId;

	@Column(name = "acc_kind")
	private String accKind;

	@Column(name = "discount_type")
	private String discountType;

	@Column(name = "discount_txt")
	private String discountText;

	@Column(name = "discount")
	private Long discount;

	@Column(name = "startdate")
	private Date startDate;

	@Column(name = "insert_date")
	@Temporal(TemporalType.TIMESTAMP)
	private Date insertDate;

	@Column(name = "state")
	private String state;

	@Column(name = "insert_user_id")
	private String insertUserId;

	@Column(name = "note")
	private String note;

	public MerchantDiscount() {
		super();
	}

	@Override
	public String toString() {
		return "MerchantDiscount [id=" + id + "]";
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	public String getAccKind() {
		return accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	public String getDiscountType() {
		return discountType;
	}

	public void setDiscountType(String discountType) {
		this.discountType = discountType;
	}

	public String getDiscountText() {
		return discountText;
	}

	public void setDiscountText(String discountText) {
		this.discountText = discountText;
	}

	public Long getDiscount() {
		return discount;
	}

	public void setDiscount(Long discount) {
		this.discount = discount;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getInsertDate() {
		return insertDate;
	}

	public void setInsertDate(Date insertDate) {
		this.insertDate = insertDate;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getInsertUserId() {
		return insertUserId;
	}

	public void setInsertUserId(String insertUserId) {
		this.insertUserId = insertUserId;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}
