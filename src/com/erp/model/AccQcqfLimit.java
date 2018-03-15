package com.erp.model;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Transient;

import org.hibernate.annotations.DynamicInsert;
import org.hibernate.annotations.DynamicUpdate;

@Table(name = "ACC_QCQF_LIMIT")
@Entity
@DynamicInsert(true)
@DynamicUpdate(true)
public class AccQcqfLimit implements Serializable{
	private static final long serialVersionUID = 1L;

	@Id
	@Column(name = "card_no")
	private String cardNo;
	
	@Column(name = "card_type")
	private String cardType;
	
	@Column(name = "sub_card_no")
	private String subCardNo;
	
	@Column(name = "acc_kind")
	private String accKind;
	
	@Column(name = "qc_limit_amt")
	private Long qcLimitAmt;
	
	@Column(name = "qt_limit_amt")
	private Long qtLimitAmt;
	
	@Column(name = "qf_limit_amt")
	private Long qfLimitAmt;
	
	@Column(name = "set_date")
	@Temporal(TemporalType.TIMESTAMP)
	private Date setDate;
	
	@Column(name = "org_id")
	private String orgId;
	
	@Column(name = "brch_id")
	private String brchId;
	
	@Column(name = "user_id")
	private String userId;
	
	@Column(name = "deal_no")
	private Long dealNo;
	
	@Column(name = "state")
	private String state;
	
	@Column(name = "note")
	private String note;
	
	@Column(name = "qc_way")
	private String qcWay;

    @Column(name = "IS_SET_LIMIT")
    private String isSetLimit;
	
	@Transient
	private String cardState;
	
	@Transient
	private String name;
	
	@Transient
	private String certNo;

	public AccQcqfLimit() {
	}

	public AccQcqfLimit(String cardNo, String cardType, String subCardNo, String accKind, Long qcLimitAmt,
			Long qtLimitAmt, Long qfLimitAmt, Date setDate, String orgId, String brchId, String userId, Long dealNo,
			String state, String note, String qcWay) {
		super();
		this.cardNo = cardNo;
		this.cardType = cardType;
		this.subCardNo = subCardNo;
		this.accKind = accKind;
		this.qcLimitAmt = qcLimitAmt;
		this.qtLimitAmt = qtLimitAmt;
		this.qfLimitAmt = qfLimitAmt;
		this.setDate = setDate;
		this.orgId = orgId;
		this.brchId = brchId;
		this.userId = userId;
		this.dealNo = dealNo;
		this.state = state;
		this.note = note;
		this.qcWay = qcWay;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	public String getSubCardNo() {
		return subCardNo;
	}

	public void setSubCardNo(String subCardNo) {
		this.subCardNo = subCardNo;
	}

	public String getAccKind() {
		return accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	public Long getQcLimitAmt() {
		return qcLimitAmt;
	}

	public void setQcLimitAmt(Long qcLimitAmt) {
		this.qcLimitAmt = qcLimitAmt;
	}

	public Long getQtLimitAmt() {
		return qtLimitAmt;
	}

	public void setQtLimitAmt(Long qtLimitAmt) {
		this.qtLimitAmt = qtLimitAmt;
	}

	public Long getQfLimitAmt() {
		return qfLimitAmt;
	}

	public void setQfLimitAmt(Long qfLimitAmt) {
		this.qfLimitAmt = qfLimitAmt;
	}

	public Date getSetDate() {
		return setDate;
	}

	public void setSetDate(Date setDate) {
		this.setDate = setDate;
	}

	public String getOrgId() {
		return orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	public String getBrchId() {
		return brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public Long getDealNo() {
		return dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public String getCardState() {
		return cardState;
	}

	public void setCardState(String cardState) {
		this.cardState = cardState;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public String getQcWay() {
		return qcWay;
	}

	public void setQcWay(String qcWay) {
		this.qcWay = qcWay;
	}

    public String getIsSetLimit(){
        return isSetLimit;
    }

    public void setIsSetLimit(String isSetLimit){
        this.isSetLimit = isSetLimit;
    }

    public Object getQcWayText() {
		if ("0".equals(qcWay)) {
			return "自主圈存";
		} else if ("1".equals(qcWay)) {
			return "自主圈存 +　实时圈存";
		} else {
			return "不开通";
		}
	}
}
