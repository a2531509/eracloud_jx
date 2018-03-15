package com.erp.webservice.server.bean;

import java.io.Serializable;
import java.util.Date;
@SuppressWarnings({"serial","static-access","unused","unchecked"})
public class Data implements Serializable {
	/**
	 * 手机号码
	 */
	public String telNo;
	
	/**
	 * 卡号
	 */
	public String cardNo;
	
	/**
	 * 卡类型
	 */
	public String cardType;
	
	/**
	 * 卡类型名称
	 */
	public String cardTypeName;
	
	/**
	 * 卡状态
	 */
	public String cardState;
	
	/**
	 * 卡状态名称
	 */
	public String cardStateName;
	
	/**
	 * 账户类型 0普通账户 1钱包账户，2联机账户，对于商户缺省为0，对于卡缺省为2
	 */
	public String accKind;
	
	/**
	 * 账户类型名称
	 */
	public String accKindName;
	
	/**
	 * 交易金额，格式化后的字符串，3.00
	 */
	public String amt;
	
	/**
	 * 账户余额，格式化后的字符串，3.00
	 */
	public String accBal;
	
	/**
	 * 交易前余额，格式化后的字符串，3.00
	 */
	public String accBalBef;
	
	/**
	 * 交易后余额，格式化后的字符串，3.00
	 */
	public String accBalAft;
	
	/**
	 * 可用余额，accBal-accUnUsableBal，格式化后的字符串，3.00
	 */
	public String accUsableBal;
	
	/**
	 * 不可用余额，相当于冻结金额，格式化后的字符串，3.00
	 */
	public String accUnUsableBal;
	
	/**
	 * 交易时间
	 */
	public String trDate;
	
	/**
	 * 返还方式
	 */
	public String retWay;
	
	/**
	 * 交易代码
	 */
	public String trCode;
	
	/**
	 * 交易代码名称
	 */
	public String trCodeName;
	
	/**
	 * 商户编号
	 */
	public String bizId;
	
	/**
	 * 商户名称
	 */
	public String bizName;
	/**
	 * 商户简称
	 */
	public String businessclientp;
	
	/**
	 * 受理点名称
	 */
	public String acptName;
	
	/**
	 * 受理点类型
	 */
	public String acptType;
	
	/**
	 * 受理点类型名称	
	 */
	public String acptTypeName;
	
	/**
	 * 业务流水号
	 */
	public Long trActionNo;
	
	/**
	 * 账户状态，0正常1注销
	 */
	public String accState;
	
	/**
	 * 账户状态名称
	 */
	public String accStateName;
	
	/**
	 * 挂失状态，0正常，1口头挂失，2书面挂失
	 */
	public String lssState;
	
	/**
	 * 挂失状态名称
	 */
	public String lssStateName;
	
	/**
	 * 卡号
	 */
	public String frzState;
	
	/**
	 * 冻结状态，0正常，1部分冻结，2全部冻结
	 */
	public String frzStateName;
	
	/**
	 * 账户编号
	 */
	public String accNo;
	
	/**
	 * 子账户编号
	 */
	public String subAccNo;
	
	/**
	 * 收入金额，格式化后的字符串如3.00
	 */
	public String amtIn;
	
	/**
	 * 付出金额，格式化后的字符串如3.00
	 */
	public String amtOut;
	
	/**
	 * 交易状态0-正常 1-撤销 2-冲正9-灰记录
	 */
	public String trState;
	
	/**
	 * 账户名称
	 */
	public String accName;
	
	/**
	 * 证件类型
	 */
	public String certType;
	
	/**
	 * 证件类型名称
	 */
	public String certTypeName;
	
	/**
	 * 证件号
	 */
	public String certNo;
	
	/**
	 * 社保编号
	 */
	public String personalId;	
	
	/**
	 * 商户/客户名称
	 */
	public String clientName;
	
	/**
	 * 商户类型
	 */
	public String bizType;
	
	/**
	 * 商户类型名称
	 */
	public String bizTypeName;
	
	/**
	 * 清分日期
	 */
	public String clrDate;
	
	/**
	 * 客户号
	 */
	public String clientId;
	
	/**
	 * 商户客户号
	 */
	public String bizClientId;
	
	/**
	 * 服务密码
	 */
	public String servPwd;
	
	/**
	 * 账户密码
	 */
	public String pwd;
	
	/**
	 * 社保卡号
	 */
	public String subCardNo;
	
	/**
	 * 学校账户ID
	 */
	public String accountId;
	
	/**
	 * 用户手机号
	 */
	public String mobileNo;
	
	/**
	 * 客户所在单位名称
	 * @return
	 */
	public String empName;
	
	/**
	 * 单位编号
	 */
	public String empId;
	/**
	 * 性别
	 */
	public String sexName;
	
	/**
	 * 出生日期
	 */
	public String birthday;
	
	/**
	 * 民族
	 */
	public String nationName;
	
	/**
	 * 联系地址
	 */
	public String letterAddr;
		
	/**
	 * 照片
	 */
	public String photo;
	
	/**
	 * 性别
	 */
	public String sex;
	
	/**
	 * 交易状态名称
	 */
	public String trStateName;

	/**
	 * 圈存限额
	 */
	public String inLimitOneDay;
	
	/**
	 * 银行编号
	 * 
	 */
	public String bank_Id;
	
	/**
	 * 银行名称
	 * @return
	 */
	public String bank_Name;
	/**
	 * 银行卡号
	 * @return
	 */
	public String bank_Card_No;
	/**
	 * 商户联系地址
	 * @return
	 */
    private String address;
    /**
	 * 商户联系电话
	 * @return
	 */
    private String c_Tel_No;
    /**
	 * 户籍类型
	 * @return
	 */
    private String reside_Type;
    
    /**
     * 姓名
     * @return
     */
    private String xmName;
    
  
    /**
     * 申领状态
     */
    private String applyState;
    
    /**
     * 联系人
     */
    private String contact;
    
    /**
     * 单位负责人
     */
    private String ceoName;
    
    /**
     * 负责人电话
     */
    private String ceoTelNo;
    
    /**
     * 勘误操作员
     */
    private String kwName;
    
    /**
     * 勘误时间
     */
    private String kwDate;
    
    /**
     * 勘误标志位
     */
    private String kwFlag;
    
    /**
     * 确认标志位
     */
    private String sureFlag;
    
    /**
     * 备注：不通过原因
     */
    private String note;
    
    /**
     * 短信开通标志位
     */
    private String smsFlag;
    
    /**
     * 社保申报统计查询总条数
     */
    private Long sbqueryCount;
    
    
    private String taskDate;//时间
    private String taskSum;//数量
    private String makeBatchId;//批次
    private String taskId;//任务号
    private String photoExist;//是否有照片
    private String applyDate;
    private String lkBrchName;//领卡网点
    
	private String fileName;
	
	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public String getApplyDate() {
		return applyDate;
	}

	public void setApplyDate(String applyDate) {
		this.applyDate = applyDate;
	}

	public String getPhotoExist() {
		return photoExist;
	}

	public void setPhotoExist(String photoExist) {
		this.photoExist = photoExist;
	}

	public String getTaskDate() {
		return taskDate;
	}

	public void setTaskDate(String taskDate) {
		this.taskDate = taskDate;
	}

	public String getTaskSum() {
		return taskSum;
	}

	public void setTaskSum(String taskSum) {
		this.taskSum = taskSum;
	}

	public String getMakeBatchId() {
		return makeBatchId;
	}

	public void setMakeBatchId(String makeBatchId) {
		this.makeBatchId = makeBatchId;
	}

	public String getTaskId() {
		return taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}

	public Long getSbqueryCount() {
		return sbqueryCount;
	}

	public void setSbqueryCount(Long sbqueryCount) {
		this.sbqueryCount = sbqueryCount;
	}

	public String getSmsFlag() {
		return smsFlag;
	}

	public void setSmsFlag(String smsFlag) {
		this.smsFlag = smsFlag;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public String getSureFlag() {
		return sureFlag;
	}

	public void setSureFlag(String sureFlag) {
		this.sureFlag = sureFlag;
	}

	public String getKwName() {
		return kwName;
	}

	public void setKwName(String kwName) {
		this.kwName = kwName;
	}

	public String getKwDate() {
		return kwDate;
	}

	public void setKwDate(String kwDate) {
		this.kwDate = kwDate;
	}

	public String getKwFlag() {
		return kwFlag;
	}

	public void setKwFlag(String kwFlag) {
		this.kwFlag = kwFlag;
	}

	public String getCeoTelNo() {
		return ceoTelNo;
	}

	public void setCeoTelNo(String ceoTelNo) {
		this.ceoTelNo = ceoTelNo;
	}

	public String getCeoName() {
		return ceoName;
	}

	public void setCeoName(String ceoName) {
		this.ceoName = ceoName;
	}

	public String getContact() {
		return contact;
	}

	public void setContact(String contact) {
		this.contact = contact;
	}

	public String getApplyState() {
		return applyState;
	}

	public void setApplyState(String applyState) {
		this.applyState = applyState;
	}

	public String getXmName() {
		return xmName;
	}

	public void setXmName(String xmName) {
		this.xmName = xmName;
	}

	public String getBank_Id() {
		return bank_Id;
	}

	public void setBank_Id(String bank_Id) {
		this.bank_Id = bank_Id;
	}

	public String getBank_Name() {
		return bank_Name;
	}

	public void setBank_Name(String bank_Name) {
		this.bank_Name = bank_Name;
	}

	public String getBank_Card_No() {
		return bank_Card_No;
	}

	public void setBank_Card_No(String bank_Card_No) {
		this.bank_Card_No = bank_Card_No;
	}

	public String getInLimitOneDay() {
		return inLimitOneDay;
	}

	public void setInLimitOneDay(String inLimitOneDay) {
		this.inLimitOneDay = inLimitOneDay;
	}

	public String getEmpName() {
		return empName;
	}

	public void setEmpName(String empName) {
		this.empName = empName;
	}

	public String getMobileNo() {
		return mobileNo;
	}

	public void setMobileNo(String mobileNo) {
		this.mobileNo = mobileNo;
	}
	
	public Data() {
		super();
	}

	public String getAccBal() {
		return accBal;
	}

	public void setAccBal(String accBal) {
		this.accBal = accBal;
	}

	public String getAccBalAft() {
		return accBalAft;
	}

	public void setAccBalAft(String accBalAft) {
		this.accBalAft = accBalAft;
	}

	public String getAccBalBef() {
		return accBalBef;
	}

	public void setAccBalBef(String accBalBef) {
		this.accBalBef = accBalBef;
	}

	public String getAccKind() {
		return accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	public String getAccKindName() {
		return accKindName;
	}

	public void setAccKindName(String accKindName) {
		this.accKindName = accKindName;
	}

	public String getAccUnUsableBal() {
		return accUnUsableBal;
	}

	public void setAccUnUsableBal(String accUnUsableBal) {
		this.accUnUsableBal = accUnUsableBal;
	}

	public String getAccUsableBal() {
		return accUsableBal;
	}

	public void setAccUsableBal(String accUsableBal) {
		this.accUsableBal = accUsableBal;
	}

	public String getAcptName() {
		return acptName;
	}

	public void setAcptName(String acptName) {
		this.acptName = acptName;
	}

	public String getAcptType() {
		return acptType;
	}

	public void setAcptType(String acptType) {
		this.acptType = acptType;
	}

	public String getAcptTypeName() {
		return acptTypeName;
	}

	public void setAcptTypeName(String acptTypeName) {
		this.acptTypeName = acptTypeName;
	}

	public String getAmt() {
		return amt;
	}

	public void setAmt(String amt) {
		this.amt = amt;
	}

	public String getBizId() {
		return bizId;
	}

	public void setBizId(String bizId) {
		this.bizId = bizId;
	}

	public String getBizName() {
		return bizName;
	}

	public void setBizName(String bizName) {
		this.bizName = bizName;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getCardState() {
		return cardState;
	}

	public void setCardState(String cardState) {
		this.cardState = cardState;
	}

	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	public String getRetWay() {
		return retWay;
	}

	public void setRetWay(String retWay) {
		this.retWay = retWay;
	}

	public String getTelNo() {
		return telNo;
	}

	public void setTelNo(String telNo) {
		this.telNo = telNo;
	}

	public String getTrCode() {
		return trCode;
	}

	public void setTrCode(String trCode) {
		this.trCode = trCode;
	}

	public String getTrCodeName() {
		return trCodeName;
	}

	public void setTrCodeName(String trCodeName) {
		this.trCodeName = trCodeName;
	}

	public String getTrDate() {
		return trDate;
	}

	public void setTrDate(String trDate) {
		this.trDate = trDate;
	}

	public Long getTrActionNo() {
		return trActionNo;
	}

	public void setTrActionNo(Long trActionNo) {
		this.trActionNo = trActionNo;
	}

	public String getCardStateName() {
		return cardStateName;
	}

	public void setCardStateName(String cardStateName) {
		this.cardStateName = cardStateName;
	}

	public String getCardTypeName() {
		return cardTypeName;
	}

	public void setCardTypeName(String cardTypeName) {
		this.cardTypeName = cardTypeName;
	}

	public String getAccState() {
		return accState;
	}

	public void setAccState(String accState) {
		this.accState = accState;
	}

	public String getFrzState() {
		return frzState;
	}

	public void setFrzState(String frzState) {
		this.frzState = frzState;
	}

	public String getFrzStateName() {
		return frzStateName;
	}

	public void setFrzStateName(String frzStateName) {
		this.frzStateName = frzStateName;
	}

	public String getLssState() {
		return lssState;
	}

	public void setLssState(String lssState) {
		this.lssState = lssState;
	}

	public String getLssStateName() {
		return lssStateName;
	}

	public void setLssStateName(String lssStateName) {
		this.lssStateName = lssStateName;
	}

	public String getAccountId() {
		return accountId;
	}

	public void setAccountId(String accountId) {
		this.accountId = accountId;
	}

	public String getAccName() {
		return accName;
	}

	public void setAccName(String accName) {
		this.accName = accName;
	}

	public String getAccNo() {
		return accNo;
	}

	public void setAccNo(String accNo) {
		this.accNo = accNo;
	}

	public String getAmtIn() {
		return amtIn;
	}

	public void setAmtIn(String amtIn) {
		this.amtIn = amtIn;
	}

	public String getAmtOut() {
		return amtOut;
	}

	public void setAmtOut(String amtOut) {
		this.amtOut = amtOut;
	}

	public String getSubAccNo() {
		return subAccNo;
	}

	public void setSubAccNo(String subAccNo) {
		this.subAccNo = subAccNo;
	}

	public String getTrState() {
		return trState;
	}

	public void setTrState(String trState) {
		this.trState = trState;
	}

	public String getBizClientId() {
		return bizClientId;
	}

	public void setBizClientId(String bizClientId) {
		this.bizClientId = bizClientId;
	}

	public String getBizType() {
		return bizType;
	}

	public void setBizType(String bizType) {
		this.bizType = bizType;
	}

	public String getBizTypeName() {
		return bizTypeName;
	}

	public void setBizTypeName(String bizTypeName) {
		this.bizTypeName = bizTypeName;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public String getCertType() {
		return certType;
	}

	public void setCertType(String certType) {
		this.certType = certType;
	}

	public String getCertTypeName() {
		return certTypeName;
	}

	public void setCertTypeName(String certTypeName) {
		this.certTypeName = certTypeName;
	}

	public String getClientId() {
		return clientId;
	}

	public void setClientId(String clientId) {
		this.clientId = clientId;
	}

	public String getClientName() {
		return clientName;
	}

	public void setClientName(String clientName) {
		this.clientName = clientName;
	}

	public String getClrDate() {
		return clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	public String getPersonalId() {
		return personalId;
	}

	public void setPersonalId(String personalId) {
		this.personalId = personalId;
	}

	public String getPwd() {
		return pwd;
	}

	public void setPwd(String pwd) {
		this.pwd = pwd;
	}

	public String getServPwd() {
		return servPwd;
	}

	public void setServPwd(String servPwd) {
		this.servPwd = servPwd;
	}

	public String getSubCardNo() {
		return subCardNo;
	}

	public void setSubCardNo(String subCardNo) {
		this.subCardNo = subCardNo;
	}

	public String getAccStateName() {
		return accStateName;
	}

	public void setAccStateName(String accStateName) {
		this.accStateName = accStateName;
	}

	public String getSexName() {
		return sexName;
	}

	public void setSexName(String sexName) {
		this.sexName = sexName;
	}

	public String getBirthday() {
		return birthday;
	}

	public void setBirthday(String birthday) {
		this.birthday = birthday;
	}

	public String getNationName() {
		return nationName;
	}

	public void setNationName(String nationName) {
		this.nationName = nationName;
	}

	public String getLetterAddr() {
		return letterAddr;
	}

	public void setLetterAddr(String letterAddr) {
		this.letterAddr = letterAddr;
	}

	public String getPhoto() {
		return photo;
	}

	public void setPhoto(String photo) {
		this.photo = photo;
	}

	public String getTrStateName() {
		return trStateName;
	}

	public void setTrStateName(String trStateName) {
		this.trStateName = trStateName;
	}

	public String getBusinessclientp() {
		return businessclientp;
	}

	public void setBusinessclientp(String businessclientp) {
		this.businessclientp = businessclientp;
	}

	public String getSex() {
		return sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getC_Tel_No() {
		return c_Tel_No;
	}

	public void setC_Tel_No(String tel_No) {
		c_Tel_No = tel_No;
	}

	public String getEmpId() {
		return empId;
	}

	public void setEmpId(String empId) {
		this.empId = empId;
	}

	public String getLkBrchName() {
		return lkBrchName;
	}

	public void setLkBrchName(String lkBrchName) {
		this.lkBrchName = lkBrchName;
	}
}
