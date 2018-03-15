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

/**
 * CardApply entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "CARD_APPLY")
@SequenceGenerator(name="SEQ_CARD_APPLY",allocationSize=1,initialValue=1,sequenceName="seq_apply_id" )
public class CardApply implements java.io.Serializable {

	// Fields

	private Long applyId;
	private String barCode;
	private String customerId;
	private String cardNo;
	private String cardType;
	private String buyPlanId;
	private String subCardNo;
	private String subCardType;
	private String bankId;
	private String bankCardNo;
	private String version;
	private String orgCode;
	private String cityCode;
	private String indusCode;
	private String applyWay;
	private String applyType;
	private String makeType;
	private String applyBrchId;
	private String corpId;
	private String commId;
	private String applyState;
	private String applyUserId;
	private Date applyDate;
	private Integer costFee;
	private Integer foregift;
	private String isUrgent;
	private Integer urgentFee;
	private String isPhoto;
	private String recvBrchId;
	private String recvCertType;
	private String recvCertNo;
	private String recvName;
	private String recvPhone;
	private String relsBrchId;
	private String relsUserId;
	private Date relsDate;
	private String agtCertType;
	private String agtCertNo;
	private String agtName;
	private String agtPhone;//代理人电话
	private Long dealNo;
	private String note;
	private String busType;
	private String oldCardNo;
	private String oldSubCardNo;
	private String messageFlag;
	private String mobilePhone;
	private String mainFlag;
	private String mainCardNo;
	private Integer otherFee;
	private String walletUseFlag;
	private String monthType;
	private String monthChargeMode;
	private String townId;
	private String taskId;
	private String wjwCheckrefuseReason;
	private String bankCheckrefuseReason;
	private String group_Id;
	private Long issuseDealNo;
	private String orgId;//发卡机构 
	private String coOrgId;//合 作机构
	private String endDealNo;//终端交易流水号
	private String isJudgeSbState;
	private String isBatchHf;
	private String oldSubCardId;

	// Constructors

	/** default constructor */
	public CardApply() {
	}

	/** minimal constructor */
	public CardApply(Long applyId, Long dealNo, String walletUseFlag) {
		this.applyId = applyId;
		this.dealNo = dealNo;
		this.walletUseFlag = walletUseFlag;
	}

	/** full constructor */
	public CardApply(Long applyId, String barCode, String customerId,
			String cardNo, String cardType, String buyPlanId, String subCardNo,
			String subCardType, String bankId, String bankCardNo,
			String version, String orgCode, String cityCode, String indusCode,
			String applyWay, String applyType, String makeType,
			String applyBrchId, String corpId, String commId,
			String applyState, String applyUserId, Date applyDate,
			Integer costFee, Integer foregift, String isUrgent,
			Integer urgentFee, String isPhoto, String recvBrchId,
			String recvCertType, String recvCertNo, String recvName,
			String relsBrchId, String relsUserId, Date relsDate,
			String agtCertType, String agtCertNo, String agtName,
			String agtPhone, Long dealNo, String note, String busType,
			String oldCardNo, String oldSubCardNo, String messageFlag,
			String mobilePhone, String mainFlag, String mainCardNo,
			Integer otherFee, String walletUseFlag, String monthType,
			String monthChargeMode, String townId,String taskId,String wjwCheckrefuseReason,
			String bankCheckrefuseReason,String group_Id) {
		this.applyId = applyId;
		this.barCode = barCode;
		this.customerId = customerId;
		this.cardNo = cardNo;
		this.cardType = cardType;
		this.buyPlanId = buyPlanId;
		this.subCardNo = subCardNo;
		this.subCardType = subCardType;
		this.bankId = bankId;
		this.bankCardNo = bankCardNo;
		this.version = version;
		this.orgCode = orgCode;
		this.cityCode = cityCode;
		this.indusCode = indusCode;
		this.applyWay = applyWay;
		this.applyType = applyType;
		this.makeType = makeType;
		this.applyBrchId = applyBrchId;
		this.corpId = corpId;
		this.commId = commId;
		this.applyState = applyState;
		this.applyUserId = applyUserId;
		this.applyDate = applyDate;
		this.costFee = costFee;
		this.foregift = foregift;
		this.isUrgent = isUrgent;
		this.urgentFee = urgentFee;
		this.isPhoto = isPhoto;
		this.recvBrchId = recvBrchId;
		this.recvCertType = recvCertType;
		this.recvCertNo = recvCertNo;
		this.recvName = recvName;
		this.relsBrchId = relsBrchId;
		this.relsUserId = relsUserId;
		this.relsDate = relsDate;
		this.agtCertType = agtCertType;
		this.agtCertNo = agtCertNo;
		this.agtName = agtName;
		this.agtPhone = agtPhone;
		this.dealNo = dealNo;
		this.note = note;
		this.busType = busType;
		this.oldCardNo = oldCardNo;
		this.oldSubCardNo = oldSubCardNo;
		this.messageFlag = messageFlag;
		this.mobilePhone = mobilePhone;
		this.mainFlag = mainFlag;
		this.mainCardNo = mainCardNo;
		this.otherFee = otherFee;
		this.walletUseFlag = walletUseFlag;
		this.monthType = monthType;
		this.monthChargeMode = monthChargeMode;
		this.townId = townId;
		this.taskId =taskId;
		this.wjwCheckrefuseReason = wjwCheckrefuseReason;
		this.bankCheckrefuseReason = bankCheckrefuseReason;
		this.group_Id = group_Id;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_CARD_APPLY")
	@Column(name = "APPLY_ID", unique = true, nullable = false, precision = 22, scale = 0)
	public Long getApplyId() {
		return this.applyId;
	}

	public void setApplyId(Long applyId) {
		this.applyId = applyId;
	}

	@Column(name = "BAR_CODE", length = 20)
	public String getBarCode() {
		return this.barCode;
	}

	public void setBarCode(String barCode) {
		this.barCode = barCode;
	}

	@Column(name = "CUSTOMER_ID", length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "CARD_NO", length = 20)
	public String getCardNo() {
		return this.cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	@Column(name = "CARD_TYPE", length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "BUY_PLAN_ID", length = 18)
	public String getBuyPlanId() {
		return this.buyPlanId;
	}

	public void setBuyPlanId(String buyPlanId) {
		this.buyPlanId = buyPlanId;
	}

	@Column(name = "SUB_CARD_NO", length = 20)
	public String getSubCardNo() {
		return this.subCardNo;
	}

	public void setSubCardNo(String subCardNo) {
		this.subCardNo = subCardNo;
	}

	@Column(name = "SUB_CARD_TYPE", length = 3)
	public String getSubCardType() {
		return this.subCardType;
	}

	public void setSubCardType(String subCardType) {
		this.subCardType = subCardType;
	}

	@Column(name = "BANK_ID", length = 4)
	public String getBankId() {
		return this.bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	@Column(name = "BANK_CARD_NO", length = 20)
	public String getBankCardNo() {
		return this.bankCardNo;
	}

	public void setBankCardNo(String bankCardNo) {
		this.bankCardNo = bankCardNo;
	}

	@Column(name = "VERSION", length = 4)
	public String getVersion() {
		return this.version;
	}

	public void setVersion(String version) {
		this.version = version;
	}

	@Column(name = "ORG_CODE", length = 128)
	public String getOrgCode() {
		return this.orgCode;
	}

	public void setOrgCode(String orgCode) {
		this.orgCode = orgCode;
	}

	@Column(name = "CITY_CODE", length = 10)
	public String getCityCode() {
		return this.cityCode;
	}

	public void setCityCode(String cityCode) {
		this.cityCode = cityCode;
	}

	@Column(name = "INDUS_CODE", length = 10)
	public String getIndusCode() {
		return this.indusCode;
	}

	public void setIndusCode(String indusCode) {
		this.indusCode = indusCode;
	}

	@Column(name = "APPLY_WAY", length = 1)
	public String getApplyWay() {
		return this.applyWay;
	}

	public void setApplyWay(String applyWay) {
		this.applyWay = applyWay;
	}

	@Column(name = "APPLY_TYPE", length = 2)
	public String getApplyType() {
		return this.applyType;
	}

	public void setApplyType(String applyType) {
		this.applyType = applyType;
	}

	@Column(name = "MAKE_TYPE", length = 1)
	public String getMakeType() {
		return this.makeType;
	}

	public void setMakeType(String makeType) {
		this.makeType = makeType;
	}

	@Column(name = "APPLY_BRCH_ID", length = 8)
	public String getApplyBrchId() {
		return this.applyBrchId;
	}

	public void setApplyBrchId(String applyBrchId) {
		this.applyBrchId = applyBrchId;
	}

	@Column(name = "CORP_ID", length = 10)
	public String getCorpId() {
		return this.corpId;
	}

	public void setCorpId(String corpId) {
		this.corpId = corpId;
	}

	@Column(name = "COMM_ID", length = 15)
	public String getCommId() {
		return this.commId;
	}

	public void setCommId(String commId) {
		this.commId = commId;
	}

	@Column(name = "APPLY_STATE", length = 1)
	public String getApplyState() {
		return this.applyState;
	}

	public void setApplyState(String applyState) {
		this.applyState = applyState;
	}

	@Column(name = "APPLY_USER_ID", length = 10)
	public String getApplyUserId() {
		return this.applyUserId;
	}

	public void setApplyUserId(String applyUserId) {
		this.applyUserId = applyUserId;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "APPLY_DATE", length = 7)
	public Date getApplyDate() {
		return this.applyDate;
	}

	public void setApplyDate(Date applyDate) {
		this.applyDate = applyDate;
	}

	@Column(name = "COST_FEE", precision = 8, scale = 0)
	public Integer getCostFee() {
		return this.costFee;
	}

	public void setCostFee(Integer costFee) {
		this.costFee = costFee;
	}

	@Column(name = "FOREGIFT", precision = 8, scale = 0)
	public Integer getForegift() {
		return this.foregift;
	}

	public void setForegift(Integer foregift) {
		this.foregift = foregift;
	}

	@Column(name = "IS_URGENT", length = 1)
	public String getIsUrgent() {
		return this.isUrgent;
	}

	public void setIsUrgent(String isUrgent) {
		this.isUrgent = isUrgent;
	}

	@Column(name = "URGENT_FEE", precision = 8, scale = 0)
	public Integer getUrgentFee() {
		return this.urgentFee;
	}

	public void setUrgentFee(Integer urgentFee) {
		this.urgentFee = urgentFee;
	}

	@Column(name = "IS_PHOTO", length = 1)
	public String getIsPhoto() {
		return this.isPhoto;
	}

	public void setIsPhoto(String isPhoto) {
		this.isPhoto = isPhoto;
	}

	@Column(name = "RECV_BRCH_ID", length = 8)
	public String getRecvBrchId() {
		return this.recvBrchId;
	}

	public void setRecvBrchId(String recvBrchId) {
		this.recvBrchId = recvBrchId;
	}

	@Column(name = "RECV_CERT_TYPE", length = 1)
	public String getRecvCertType() {
		return this.recvCertType;
	}

	public void setRecvCertType(String recvCertType) {
		this.recvCertType = recvCertType;
	}

	@Column(name = "RECV_CERT_NO", length = 36)
	public String getRecvCertNo() {
		return this.recvCertNo;
	}

	public void setRecvCertNo(String recvCertNo) {
		this.recvCertNo = recvCertNo;
	}

	@Column(name = "RECV_NAME", length = 32)
	public String getRecvName() {
		return this.recvName;
	}

	public void setRecvName(String recvName) {
		this.recvName = recvName;
	}

	@Column(name = "RELS_BRCH_ID", length = 8)
	public String getRelsBrchId() {
		return this.relsBrchId;
	}

	public void setRelsBrchId(String relsBrchId) {
		this.relsBrchId = relsBrchId;
	}

	@Column(name = "RELS_USER_ID", length = 10)
	public String getRelsUserId() {
		return this.relsUserId;
	}

	public void setRelsUserId(String relsUserId) {
		this.relsUserId = relsUserId;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "RELS_DATE", length = 7)
	public Date getRelsDate() {
		return this.relsDate;
	}

	public void setRelsDate(Date relsDate) {
		this.relsDate = relsDate;
	}

	@Column(name = "AGT_CERT_TYPE", length = 2)
	public String getAgtCertType() {
		return this.agtCertType;
	}

	public void setAgtCertType(String agtCertType) {
		this.agtCertType = agtCertType;
	}

	@Column(name = "AGT_CERT_NO", length = 36)
	public String getAgtCertNo() {
		return this.agtCertNo;
	}

	public void setAgtCertNo(String agtCertNo) {
		this.agtCertNo = agtCertNo;
	}

	@Column(name = "AGT_NAME", length = 32)
	public String getAgtName() {
		return this.agtName;
	}

	public void setAgtName(String agtName) {
		this.agtName = agtName;
	}

	@Column(name = "AGT_PHONE", length = 32)
	public String getAgtPhone() {
		return this.agtPhone;
	}

	public void setAgtPhone(String agtPhone) {
		this.agtPhone = agtPhone;
	}

	@Column(name = "DEAL_NO", nullable = false, precision = 22, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "NOTE", length = 128)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	@Column(name = "BUS_TYPE", length = 2)
	public String getBusType() {
		return this.busType;
	}

	public void setBusType(String busType) {
		this.busType = busType;
	}

	@Column(name = "OLD_CARD_NO", length = 20)
	public String getOldCardNo() {
		return this.oldCardNo;
	}

	public void setOldCardNo(String oldCardNo) {
		this.oldCardNo = oldCardNo;
	}

	@Column(name = "OLD_SUB_CARD_NO", length = 20)
	public String getOldSubCardNo() {
		return this.oldSubCardNo;
	}

	public void setOldSubCardNo(String oldSubCardNo) {
		this.oldSubCardNo = oldSubCardNo;
	}

	@Column(name = "MESSAGE_FLAG", length = 1)
	public String getMessageFlag() {
		return this.messageFlag;
	}

	public void setMessageFlag(String messageFlag) {
		this.messageFlag = messageFlag;
	}

	@Column(name = "MOBILE_PHONE", length = 32)
	public String getMobilePhone() {
		return this.mobilePhone;
	}

	public void setMobilePhone(String mobilePhone) {
		this.mobilePhone = mobilePhone;
	}

	@Column(name = "MAIN_FLAG", length = 1)
	public String getMainFlag() {
		return this.mainFlag;
	}

	public void setMainFlag(String mainFlag) {
		this.mainFlag = mainFlag;
	}

	@Column(name = "MAIN_CARD_NO", length = 20)
	public String getMainCardNo() {
		return this.mainCardNo;
	}

	public void setMainCardNo(String mainCardNo) {
		this.mainCardNo = mainCardNo;
	}

	@Column(name = "OTHER_FEE", precision = 8, scale = 0)
	public Integer getOtherFee() {
		return this.otherFee;
	}

	public void setOtherFee(Integer otherFee) {
		this.otherFee = otherFee;
	}

	@Column(name = "WALLET_USE_FLAG", nullable = false, length = 2)
	public String getWalletUseFlag() {
		return this.walletUseFlag;
	}

	public void setWalletUseFlag(String walletUseFlag) {
		this.walletUseFlag = walletUseFlag;
	}

	@Column(name = "MONTH_TYPE", length = 2)
	public String getMonthType() {
		return this.monthType;
	}

	public void setMonthType(String monthType) {
		this.monthType = monthType;
	}

	@Column(name = "MONTH_CHARGE_MODE", length = 2)
	public String getMonthChargeMode() {
		return this.monthChargeMode;
	}

	public void setMonthChargeMode(String monthChargeMode) {
		this.monthChargeMode = monthChargeMode;
	}

	@Column(name = "TOWN_ID", length = 15)
	public String getTownId() {
		return this.townId;
	}

	public void setTownId(String townId) {
		this.townId = townId;
	}

	@Column(name = "task_id", length = 15)
	public String getTaskId() {
		return taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}

	@Column(name = "WJW_CHECKREFUSE_REASON", length = 15)
	public String getWjwCheckrefuseReason() {
		return wjwCheckrefuseReason;
	}

	public void setWjwCheckrefuseReason(String wjwCheckrefuseReason) {
		this.wjwCheckrefuseReason = wjwCheckrefuseReason;
	}

	@Column(name = "BANK_CHECKREFUSE_REASON", length = 15)
	public String getBankCheckrefuseReason() {
		return bankCheckrefuseReason;
	}

	public void setBankCheckrefuseReason(String bankCheckrefuseReason) {
		this.bankCheckrefuseReason = bankCheckrefuseReason;
	}
	@Column(name = "GROUP_ID", length = 15)
	public String getGroup_Id() {
		return group_Id;
	}

	public void setGroup_Id(String group_Id) {
		this.group_Id = group_Id;
	}
	
	@Column(name = "ISSUSE_DEAL_NO", precision = 18, scale = 0)
	public Long getIssuseDealNo() {
		return issuseDealNo;
	}

	public void setIssuseDealNo(Long issuseDealNo) {
		this.issuseDealNo = issuseDealNo;
	}
	@Column(name = "ORG_ID", length = 4)
	public String getOrgId() {
		return orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}
	@Column(name = "CO_ORG_ID", length = 15)
	public String getCoOrgId() {
		return coOrgId;
	}

	public void setCoOrgId(String coOrgId) {
		this.coOrgId = coOrgId;
	}


	@Column(name = "END_DEAL_NO", length = 15)
	public String getEndDealNo() {
		return endDealNo;
	}

	public void setEndDealNo(String endDealNo) {
		this.endDealNo = endDealNo;
	}

	/**
	 * @return the recvPhone
	 */
	@Column(name = "RECV_PHONE", length = 15)
	public String getRecvPhone() {
		return recvPhone;
	}

	/**
	 * @param recvPhone the recvPhone to set
	 */
	public void setRecvPhone(String recvPhone) {
		this.recvPhone = recvPhone;
	}

	@Column(name = "IS_JUDGE_SB_STATE")
	public String getIsJudgeSbState() {
		return isJudgeSbState;
	}

	public void setIsJudgeSbState(String isJudgeSbState) {
		this.isJudgeSbState = isJudgeSbState;
	}

	@Column(name = "IS_BATCH_HF")
	public String getIsBatchHf() {
		return isBatchHf;
	}

	public void setIsBatchHf(String isBatchHf) {
		this.isBatchHf = isBatchHf;
	}

	@Column(name = "OLD_SUB_CARD_ID")
	public String getOldSubCardId() {
		return oldSubCardId;
	}

	public void setOldSubCardId(String oldSubCardId) {
		this.oldSubCardId = oldSubCardId;
	}
}