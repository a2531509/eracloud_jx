package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * CardApplyTask entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "CARD_APPLY_TASK")
public class CardApplyTask implements java.io.Serializable {

	// Fields

	private String taskId;
	private String makeBatchId;
	private Integer dealCode;
	private String taskName;
	private Integer taskSum;
	private String taskSrc;
	private Date taskDate;
	private String taskOrgId;
	private String taskBrchId;
	private String taskOperId;
	private String cardType;
	private String bankId;
	private String brchId;
	private String corpId;
	private String regionId;
	private String townId;
	private String commId;
	private String isPhoto;
	private String startCardNo;
	private String endCardNo;
	private String isList;
	private Long dealNo;
	private String taskWay;
	private String isUrgent;
	private String vendorId;
	private String orgId;
	private String taskState;
	private String note;
	private String group_Id;
	private String schoolId;
	private String gradeId;
	private String classesId;
	private Long issuseNum;
	private Long yhNum;
	private Long wsNum;
	private Long endNum;
	private String medWholeNo;
	private String isBatchHf;
	private String isJudgeSbState;
	private String isJrsbkDr;
	

	// Constructors

	/** default constructor */
	public CardApplyTask() {
	}

	/** minimal constructor */
	public CardApplyTask(String taskId, Long dealNo) {
		this.taskId = taskId;
		this.dealNo = dealNo;
	}

	/** full constructor */
	public CardApplyTask(String taskId, String makeBatchId, Integer dealCode,
			String taskName, Integer taskSum, String taskSrc, Date taskDate,
			String taskOrgId, String taskBrchId, String taskOperId,
			String cardType, String bankId, String brchId, String corpId,
			String regionId, String townId, String commId, String isPhoto,
			String startCardNo, String endCardNo, String isList,
			Long dealNo, String taskWay, String isUrgent,
			String vendorId, String orgId, String taskState, String note) {
		this.taskId = taskId;
		this.makeBatchId = makeBatchId;
		this.dealCode = dealCode;
		this.taskName = taskName;
		this.taskSum = taskSum;
		this.taskSrc = taskSrc;
		this.taskDate = taskDate;
		this.taskOrgId = taskOrgId;
		this.taskBrchId = taskBrchId;
		this.taskOperId = taskOperId;
		this.cardType = cardType;
		this.bankId = bankId;
		this.brchId = brchId;
		this.corpId = corpId;
		this.regionId = regionId;
		this.townId = townId;
		this.commId = commId;
		this.isPhoto = isPhoto;
		this.startCardNo = startCardNo;
		this.endCardNo = endCardNo;
		this.isList = isList;
		this.dealNo = dealNo;
		this.taskWay = taskWay;
		this.isUrgent = isUrgent;
		this.vendorId = vendorId;
		this.orgId = orgId;
		this.taskState = taskState;
		this.note = note;
	}

	// Property accessors
	@Id
	@Column(name = "TASK_ID", unique = true, nullable = false, length = 18)
	public String getTaskId() {
		return this.taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}

	@Column(name = "MAKE_BATCH_ID", length = 10)
	public String getMakeBatchId() {
		return this.makeBatchId;
	}

	public void setMakeBatchId(String makeBatchId) {
		this.makeBatchId = makeBatchId;
	}

	@Column(name = "DEAL_CODE", precision = 6, scale = 0)
	public Integer getDealCode() {
		return this.dealCode;
	}

	public void setDealCode(Integer dealCode) {
		this.dealCode = dealCode;
	}

	@Column(name = "TASK_NAME", length = 128)
	public String getTaskName() {
		return this.taskName;
	}

	public void setTaskName(String taskName) {
		this.taskName = taskName;
	}

	@Column(name = "TASK_SUM", precision = 8, scale = 0)
	public Integer getTaskSum() {
		return this.taskSum;
	}

	public void setTaskSum(Integer taskSum) {
		this.taskSum = taskSum;
	}

	@Column(name = "TASK_SRC", length = 1)
	public String getTaskSrc() {
		return this.taskSrc;
	}

	public void setTaskSrc(String taskSrc) {
		this.taskSrc = taskSrc;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "TASK_DATE")
	public Date getTaskDate() {
		return this.taskDate;
	}

	public void setTaskDate(Date taskDate) {
		this.taskDate = taskDate;
	}

	@Column(name = "TASK_ORG_ID", length = 4)
	public String getTaskOrgId() {
		return this.taskOrgId;
	}

	public void setTaskOrgId(String taskOrgId) {
		this.taskOrgId = taskOrgId;
	}

	@Column(name = "TASK_BRCH_ID", length = 8)
	public String getTaskBrchId() {
		return this.taskBrchId;
	}

	public void setTaskBrchId(String taskBrchId) {
		this.taskBrchId = taskBrchId;
	}

	@Column(name = "TASK_OPER_ID", length = 10)
	public String getTaskOperId() {
		return this.taskOperId;
	}

	public void setTaskOperId(String taskOperId) {
		this.taskOperId = taskOperId;
	}

	@Column(name = "CARD_TYPE", length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "BANK_ID", length = 4)
	public String getBankId() {
		return this.bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	@Column(name = "BRCH_ID", length = 8)
	public String getBrchId() {
		return this.brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	@Column(name = "CORP_ID", length = 10)
	public String getCorpId() {
		return this.corpId;
	}

	public void setCorpId(String corpId) {
		this.corpId = corpId;
	}

	@Column(name = "REGION_ID", length = 6)
	public String getRegionId() {
		return this.regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	@Column(name = "TOWN_ID", length = 15)
	public String getTownId() {
		return this.townId;
	}

	public void setTownId(String townId) {
		this.townId = townId;
	}

	@Column(name = "COMM_ID", length = 15)
	public String getCommId() {
		return this.commId;
	}

	public void setCommId(String commId) {
		this.commId = commId;
	}

	@Column(name = "IS_PHOTO", length = 1)
	public String getIsPhoto() {
		return this.isPhoto;
	}

	public void setIsPhoto(String isPhoto) {
		this.isPhoto = isPhoto;
	}

	@Column(name = "START_CARD_NO", length = 20)
	public String getStartCardNo() {
		return this.startCardNo;
	}

	public void setStartCardNo(String startCardNo) {
		this.startCardNo = startCardNo;
	}

	@Column(name = "END_CARD_NO", length = 20)
	public String getEndCardNo() {
		return this.endCardNo;
	}

	public void setEndCardNo(String endCardNo) {
		this.endCardNo = endCardNo;
	}

	@Column(name = "IS_LIST", length = 1)
	public String getIsList() {
		return this.isList;
	}

	public void setIsList(String isList) {
		this.isList = isList;
	}

	@Column(name = "DEAL_NO", nullable = false, precision = 22, scale = 0)
	public Long getDealNo() {
		return this.dealNo;
	}

	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	@Column(name = "TASK_WAY", length = 1)
	public String getTaskWay() {
		return this.taskWay;
	}

	public void setTaskWay(String taskWay) {
		this.taskWay = taskWay;
	}

	@Column(name = "IS_URGENT", length = 1)
	public String getIsUrgent() {
		return this.isUrgent;
	}

	public void setIsUrgent(String isUrgent) {
		this.isUrgent = isUrgent;
	}

	@Column(name = "VENDOR_ID", length = 4)
	public String getVendorId() {
		return this.vendorId;
	}

	public void setVendorId(String vendorId) {
		this.vendorId = vendorId;
	}

	@Column(name = "ORG_ID", length = 4)
	public String getOrgId() {
		return this.orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	@Column(name = "TASK_STATE", length = 1)
	public String getTaskState() {
		return this.taskState;
	}

	public void setTaskState(String taskState) {
		this.taskState = taskState;
	}

	@Column(name = "NOTE", length = 64)
	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}
	@Column(name = "GROUP_ID", length = 15)
	public String getGroup_Id() {
		return group_Id;
	}

	public void setGroup_Id(String group_Id) {
		this.group_Id = group_Id;
	}
	@Column(name = "SCHOOL_ID", length = 15)
	public String getSchoolId() {
		return schoolId;
	}

	public void setSchoolId(String schoolId) {
		this.schoolId = schoolId;
	}
	@Column(name = "GRADE_ID", length = 15)
	public String getGradeId() {
		return gradeId;
	}

	public void setGradeId(String gradeId) {
		this.gradeId = gradeId;
	}
	@Column(name = "CLASSES_ID", length = 15)
	public String getClassesId() {
		return classesId;
	}

	public void setClassesId(String classesId) {
		this.classesId = classesId;
	}
	@Column(name = "ISSUSE_NUM", precision = 8, scale = 0)
	public Long getIssuseNum() {
		return issuseNum;
	}

	public void setIssuseNum(Long issuseNum) {
		this.issuseNum = issuseNum;
	}
	@Column(name = "YH_NUM", precision = 8, scale = 0)
	public Long getYhNum() {
		return yhNum;
	}

	public void setYhNum(Long yhNum) {
		this.yhNum = yhNum;
	}
	@Column(name = "WS_NUM", precision = 8, scale = 0)
	public Long getWsNum() {
		return wsNum;
	}

	public void setWsNum(Long wsNum) {
		this.wsNum = wsNum;
	}
	@Column(name = "END_NUM", precision = 8, scale = 0)
	public Long getEndNum() {
		return endNum;
	}

	public void setEndNum(Long endNum) {
		this.endNum = endNum;
	}

	/**
	 * @return the medWholeNo
	 */
	@Column(name = "MED_WHOLE_NO", length = 15)
	public String getMedWholeNo() {
		return medWholeNo;
	}

	/**
	 * @param medWholeNo the medWholeNo to set
	 */
	public void setMedWholeNo(String medWholeNo) {
		this.medWholeNo = medWholeNo;
	}
	@Column(name = "IS_BATCH_HF", length = 1)
	public String getIsBatchHf() {
		return isBatchHf;
	}
	public void setIsBatchHf(String isBatchHf) {
		this.isBatchHf = isBatchHf;
	}
	@Column(name = "IS_JUDGE_SB_STATE", length = 1)
	public String getIsJudgeSbState() {
		return isJudgeSbState;
	}
	public void setIsJudgeSbState(String isJudgeSbState) {
		this.isJudgeSbState = isJudgeSbState;
	}

	/**
	 * @return the isJrsbkDr
	 */
	@Column(name = "IS_JRSBK_DR", length = 1)
	public String getIsJrsbkDr() {
		return isJrsbkDr;
	}

	/**
	 * @param isJrsbkDr the isJrsbkDr to set
	 */
	public void setIsJrsbkDr(String isJrsbkDr) {
		this.isJrsbkDr = isJrsbkDr;
	}
}