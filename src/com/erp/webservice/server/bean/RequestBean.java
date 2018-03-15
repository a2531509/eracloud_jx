package com.erp.webservice.server.bean;

import java.io.Serializable;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

import com.erp.util.Tools;

@SuppressWarnings({"serial","static-access","unused","unchecked"})
public class RequestBean implements Serializable{
	public String cardNo;//卡号

	public String telNo;//手机号码

	public String certType;//证件类型

	public String certNo;//证件号

	public String startDate;//开始日期

	public String endDate;//结束日期

	public String clientName;//客户性名/商户名称

	public String pwdType;//密码修改类型1服务密码，2交易密码，3支付密码

	public String modType;//修改类型 1修改，2重置

	public String oldPwd;//旧密码

	public String newPwd;//新密码
	
	public String lssFlag;//挂失标志 1口头挂失，2书面挂失。为空时缺省为2
	
	public String accKind;//账户类型 0普通账户 1钱包账户，2联机账户，对于商户缺省为0，对于卡缺省为2
	
	public Long amt=0L;//交易金额，如充值金额，以分为单位的整数，缺省为0
	
	public String trCode;//交易代码2170 资金账户银行卡充值	2160 资金账户充值卡充值 	其它有需要再加

	public String bankId;//银行编号	1001 招商银行	其它有需要再加
	
	public String trNum;//交易流水单号
	
	public String bizTime;//交易时间，精确到秒
	
	public String chargeCardNo;//充值卡卡号
	
	public Long pCount=10L;//每页显示条数，如每页显示10条
	
	public Long pageNo=1L;//第几页，从1开始，缺省为1
	
	public String clientType;//客户类型
	
	public String pwd;//密码，如登录时的登录密码，交易时的交易密码
	
	public String walletId;//钱包编号
	
	public Long amtBef;//交易前金额，用于钱包账户业务，以分为单位的整数，缺省为0
	
	public String terminalId;//终端编号
	
	public String trBatchNo;//交易批次号
	
	public String mac;//mac码
	
	public String note;//备注
	
	public String acptType;//受理点类型，1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场
	
	public String bankCardNo;//银行卡号，用于银行卡向客户账户充值时使用
	
	public String operId;//操作员编号
	
	public String actionNo ;//交易流水号
	
	public String trDate ;//交易时间 	
	
	public String bizId;//商户编号
	
	public String inLimitOneDay2;//修改后圈存限额
	
	public String qcamt;//圈存金额
	
	public String cardType;//卡类型
	public String isPhoto;//0不需要，1需要
	
	public String empId;//单位编号
	
	public String sex;//性别
	
	public String xmName;
	
	public String letterAddr;
	
	public String empName;
	
	public String sureFlag;
	
    private String photo;
    
    private byte[] photob;
	
	private String copyPhoto;
	
	public String applyState;
	
	public String companyId;
	
	public String regionId;
	
	public String data;
	
	public String name;
	
	public String getData() {
		return data;
	}

	public void setData(String data) {
		this.data = data;
	}

	public String getRegionId() {
		return regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	public String getCompanyId() {
		return companyId;
	}

	public void setCompanyId(String companyId) {
		this.companyId = companyId;
	}

	public String getApplyState() {
		return applyState;
	}

	public void setApplyState(String applyState) {
		this.applyState = applyState;
	}

	public String getCopyPhoto() {
		return copyPhoto;
	}

	public void setCopyPhoto(String copyPhoto) {
		this.copyPhoto = copyPhoto;
	}

	public String getPhoto() {
		return photo;
	}

	public void setPhoto(String photo) {
		this.photo = photo;
	}

	public String getSureFlag() {
		return sureFlag;
	}

	public void setSureFlag(String sureFlag) {
		this.sureFlag = sureFlag;
	}

	public String getEmpName() {
		return empName;
	}

	public void setEmpName(String empName) {
		this.empName = empName;
	}

	public String getLetterAddr() {
		return letterAddr;
	}

	public void setLetterAddr(String letterAddr) {
		this.letterAddr = letterAddr;
	}

	public String getXmName() {
		return xmName;
	}

	public void setXmName(String xmName) {
		this.xmName = xmName;
	}
	
	
	public String getSex() {
		return sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	public String getEmpId() {
		return empId;
	}

	public void setEmpId(String empId) {
		this.empId = empId;
	}

	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	public String getQcamt() {
		return qcamt;
	}

	public void setQcamt(String qcamt) {
		this.qcamt = qcamt;
	}
	
	public String getInLimitOneDay2() {
		return inLimitOneDay2;
	}

	public void setInLimitOneDay2(String inLimitOneDay2) {
		this.inLimitOneDay2 = inLimitOneDay2;
	}
	
	public RequestBean() {
		super();
	}

	public String getBankCardNo() {
		return bankCardNo;
	}

	public void setBankCardNo(String bankCardNo) {
		this.bankCardNo = bankCardNo;
	}
	
	public String getAcptType() {
		return acptType;
	}

	public void setAcptType(String acptType) {
		this.acptType = acptType;
	}
	public String getNewPwd() {
		return newPwd;
	}

	public void setNewPwd(String newPwd) {
		this.newPwd = newPwd;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		String s="";
		if(!Tools.processNull(certNo).equals("")){
			s=certNo.toUpperCase();
		}
		this.certNo = s;
	}

	public String getCertType() {
		return certType;
	}

	public void setCertType(String certType) {
		this.certType = certType;
	}

	public String getClientName() {
		return clientName;
	}

	public void setClientName(String clientName) {
		this.clientName = clientName;
	}

	public String getEndDate() {
		return endDate;
	}

	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}

	public String getModType() {
		return modType;
	}

	public void setModType(String modType) {
		this.modType = modType;
	}

	public String getOldPwd() {
		return oldPwd;
	}

	public void setOldPwd(String oldPwd) {
		this.oldPwd = oldPwd;
	}

	public String getPwdType() {
		return pwdType;
	}

	public void setPwdType(String pwdType) {
		this.pwdType = pwdType;
	}

	public String getStartDate() {
		return startDate;
	}

	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}

	public String getTelNo() {
		return telNo;
	}

	public void setTelNo(String telNo) {
		this.telNo = telNo;
	}

	public Long getPCount() {
		return pCount;
	}

	public String getAccKind() {
		/*String s="00";
		if(!Tools.processNull(getAccKind()).equals("")){
			if(getAccKind().equals("0")){
				s="00";
			}else if(getAccKind().equals("1")){
				s="01";
			}else if(getAccKind().equals("2")){
				s="02";
			}else if(getAccKind().equals("3")){
				s="03";
			}else if(getAccKind().equals("4")){
				s="04";
			}else if(getAccKind().equals("5")){
				s="05";
			}else if(getAccKind().equals("6")){
				s="06";
			}else if(getAccKind().equals("7")){
				s="07";
			}else if(getAccKind().equals("8")){
				s="08";
			}else if(getAccKind().equals("9")){
				s="09";
			}
			accKind=s;
			setAccKind(s);
		}
		*/
		return accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	public Long getAmt() {
		return amt;
	}

	public void setAmt(Long amt) {
		this.amt = amt;
	}

	public Long getAmtBef() {
		return amtBef;
	}

	public void setAmtBef(Long amtBef) {
		this.amtBef = amtBef;
	}

	public String getBankId() {
		return bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	public String getBizTime() {
		return bizTime;
	}

	public void setBizTime(String bizTime) {
		this.bizTime = bizTime;
	}

	public String getChargeCardNo() {
		return chargeCardNo;
	}

	public void setChargeCardNo(String chargeCardNo) {
		this.chargeCardNo = chargeCardNo;
	}

	public String getClientType() {
		return clientType;
	}

	public void setClientType(String clientType) {
		this.clientType = clientType;
	}

	public String getLssFlag() {
		return lssFlag;
	}

	public void setLssFlag(String lssFlag) {
		this.lssFlag = lssFlag;
	}

	public String getMac() {
		return mac;
	}

	public void setMac(String mac) {
		this.mac = mac;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public Long getPageNo() {
		return pageNo;
	}

	public void setPageNo(Long pageNo) {
		this.pageNo = pageNo;
	}

	public String getPwd() {
		return pwd;
	}

	public void setPwd(String pwd) {
		this.pwd = pwd;
	}

	public String getTerminalId() {
		return terminalId;
	}

	public void setTerminalId(String terminalId) {
		this.terminalId = terminalId;
	}

	public String getTrBatchNo() {
		return trBatchNo;
	}

	public void setTrBatchNo(String trBatchNo) {
		this.trBatchNo = trBatchNo;
	}

	public String getTrCode() {
		return trCode;
	}

	public void setTrCode(String trCode) {
		this.trCode = trCode;
	}

	public String getTrNum() {
		return trNum;
	}

	public void setTrNum(String trNum) {
		this.trNum = trNum;
	}

	public String getWalletId() {
		return walletId;
	}

	public void setWalletId(String walletId) {
		this.walletId = walletId;
	}

	public void setPCount(Long count) {
		pCount = count;
	}

	public String getActionNo() {
		return actionNo;
	}

	public void setActionNo(String actionNo) {
		this.actionNo = actionNo;
	}

	public String getTrDate() {
		return trDate;
	}

	public void setTrDate(String trDate) {
		this.trDate = trDate;
	}

	public String getOperId() {
		return operId;
	}

	public void setOperId(String operId) {
		this.operId = operId;
	}
	
	public String getBizId() {
		return bizId;
	}

	public void setBizId(String bizId) {
		this.bizId = bizId;
	}
	@Override
	public String toString() {
		try {
			StringBuffer retstr=new StringBuffer();
			Field fields[]=this.getClass().getFields();
			for(int k=0;k< fields.length; k++){
				Field onefield=fields[k];
				Method ms = this.getClass().getMethod("get"+onefield.getName().substring(0, 1).toUpperCase()+onefield.getName().substring(1));
				Object value=Tools.processNull(ms.invoke(this,new Object[0]));
				retstr.append(onefield.getName()+"="+value+",");
			}
			return retstr.toString();
		} catch (Exception e) {
			e.printStackTrace();
			return "";
		}
	}

	public String getIsPhoto() {
		return isPhoto;
	}

	public void setIsPhoto(String isPhoto) {
		this.isPhoto = isPhoto;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
}
