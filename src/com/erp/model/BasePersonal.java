package com.erp.model;

import javax.persistence.Entity;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.hibernate.annotations.DynamicUpdate;

import com.erp.util.StringUtils;

/**
 * BasePersonal entity. @author MyEclipse Persistence Tools
 */

@SuppressWarnings("serial")
@Entity
@Table(name = "BASE_PERSONAL")
@DynamicUpdate(true)
@SequenceGenerator(name="SEQ_BASIC_PERSON",allocationSize=1,initialValue=10010089,sequenceName="SEQ_CLIENT_ID" )
public class BasePersonal extends AbstractBasePersonal implements java.io.Serializable {

	

	public BasePersonal() {
	}

	private String corpName;
	private String regionName;
	private String townName;
	private String commName;
	private String genderName;//性别
	private String marrStateName;//婚姻状况
	private String resideTypeName;//户籍类型
	private String certTypes;//证件类型
	private String educations;//文化程度
	private String nations;//名族
	private String customerStates;
	private String sureFlags;

	
	// Constructors

	@Transient
	public String getResideTypeName() {
		String s="";
		if(StringUtils.isNotBlank(getResideType())){
			if("0".equals(getResideType())){//0本地1外地
				s= "0-本地";
			}else if("1".equals(getResideType())){
				s= "1-外地";
			}
		}
		setResideTypeName(s);
		return resideTypeName;
	}

	public void setResideTypeName(String resideTypeName) {
		this.resideTypeName = resideTypeName;
	}

	@Transient
	public String getMarrStateName() {
		String s="";
		if(StringUtils.isNotBlank(getMarrState())){
			if("10".equals(getMarrState())){//婚姻状况(10未婚,20已婚,21初婚,22再婚,23复婚,30丧偶,40离婚)
				s= "未婚";
			}else if("20".equals(getMarrState())){
				s= "已婚";
			}else if("21".equals(getMarrState())){
				s= "初婚";
			}else if("22".equals(getMarrState())){
				s= "再婚";
			}else if("23".equals(getMarrState())){
				s= "复婚";
			}else if("30".equals(getMarrState())){
				s= "丧偶";
			}else if("40".equals(getMarrState())){
				s= "离婚";
			}
		}
		setMarrStateName(s);
		return marrStateName;
	}

	public void setMarrStateName(String marrStateName) {
		this.marrStateName = marrStateName;
	}

	@Transient
	public String getGenderName() {
		String s="";
		if(StringUtils.isNotBlank(getGender())){
			if("0".equals(getGender())){
				s= "未知";
			}else if("1".equals(getGender())){
				s= "男";
			}else if("2".equals(getGender())){
				s= "女";
			}else if("9".equals(getGender())){
				s= "未说明";
			}else{
				s= "未说明";
			}
		}
		setGenderName(s);
		return genderName;
	}

	public void setGenderName(String genderName) {
		this.genderName = genderName;
	}

	@Transient
	public String getCommName() {
		return commName;
	}

	public void setCommName(String commName) {
		this.commName = commName;
	}

	@Transient
	public String getCorpName() {
		return corpName;
	}

	public void setCorpName(String corpName) {
		this.corpName = corpName;
	}

	@Transient
	public String getRegionName() {
		return regionName;
	}

	public void setRegionName(String regionName) {
		this.regionName = regionName;
	}

	@Transient
	public String getTownName() {
		return townName;
	}

	public void setTownName(String townName) {
		this.townName = townName;
	}

	@Transient
	public String getCertTypes() {
		return certTypes;
	}

	public void setCertTypes(String certTypes) {
		this.certTypes = certTypes;
	}

	@Transient
	public String getEducations() {
		return educations;
	}

	public void setEducations(String educations) {
		this.educations = educations;
	}
	
	@Transient
	public String getNations() {
		return nations;
	}

	public void setNations(String nations) {
		this.nations = nations;
	}

	@Transient
	public String getCustomerStates() {
		String s="";
		if(StringUtils.isNotBlank(getCustomerState())){
			if("0".equals(getCustomerState())){
				s= "正常";
			}else if("1".equals(getCustomerState())){
				s= "注销";
			}else{
				s= "未说明";
			}
		}
		setCustomerStates(s);
		return customerStates;
	}

	public void setCustomerStates(String customerStates) {
		this.customerStates = customerStates;
	}

	@Transient
	public String getSureFlags() {
		String s="";
		if(StringUtils.isNotBlank(getSureFlag())){
			if("0".equals(getSureFlag())){
				s= "已确认";
			}else if("1".equals(getSureFlag())){
				s= "未确认";
			}else{
				s= "未说明";
			}
		}
		setSureFlags(s);
		return sureFlags;
	}

	public void setSureFlags(String sureFlags) {
		this.sureFlags = sureFlags;
	}
	
	
	
	
	
}