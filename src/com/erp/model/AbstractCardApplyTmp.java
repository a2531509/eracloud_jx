package com.erp.model;

import java.sql.Timestamp;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@SuppressWarnings("serial")
@Entity
@Table(name = "CARD_APPLY_TMP")
public class AbstractCardApplyTmp  implements java.io.Serializable {

	// Fields

	private Long catId;
	private String customerId;
	private String corpName;
	private String cityId;
	private String regionId;
	private String townId;
	private String commId;
	private String catFlag;
	private String cardType;
	private String makeType;
	private Long makNum;
	private String dealFlag;
	private Date dealTime;
	private String userId;
	private String brchId;

	// Constructors

	/** default constructor */
	public AbstractCardApplyTmp() {
	}

	/** minimal constructor */
	public AbstractCardApplyTmp(Long catId) {
		this.catId = catId;
	}

	/** full constructor */
	public AbstractCardApplyTmp(Long catId, String customerId, String corpName,
			String cityId, String regionId, String townId, String commId,
			String catFlag, String makeType, Long makNum,
			String dealFlag, java.util.Date dealTime, String userId, String brchId, String cardType) {
		this.catId = catId;
		this.customerId = customerId;
		this.corpName = corpName;
		this.cityId = cityId;
		this.regionId = regionId;
		this.townId = townId;
		this.commId = commId;
		this.catFlag = catFlag;
		this.makeType = makeType;
		this.makNum = makNum;
		this.dealFlag = dealFlag;
		this.dealTime = dealTime;
		this.userId = userId;
		this.brchId = brchId;
		this.cardType = cardType;
	}

	// Property accessors
	@Id
	@Column(name = "CAT_ID", unique = true, nullable = false, precision = 20, scale = 0)
	public Long getCatId() {
		return this.catId;
	}

	public void setCatId(Long catId) {
		this.catId = catId;
	}

	@Column(name = "CUSTOMER_ID", length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "CORP_NAME", length = 100)
	public String getCorpName() {
		return this.corpName;
	}

	public void setCorpName(String corpName) {
		this.corpName = corpName;
	}

	@Column(name = "CITY_ID", length = 12)
	public String getCityId() {
		return this.cityId;
	}

	public void setCityId(String cityId) {
		this.cityId = cityId;
	}

	@Column(name = "REGION_ID", length = 15)
	public String getRegionId() {
		return this.regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	@Column(name = "TOWN_ID", length = 20)
	public String getTownId() {
		return this.townId;
	}

	public void setTownId(String townId) {
		this.townId = townId;
	}

	@Column(name = "COMM_ID", length = 20)
	public String getCommId() {
		return this.commId;
	}

	public void setCommId(String commId) {
		this.commId = commId;
	}

	@Column(name = "CAT_FLAG", length = 1)
	public String getCatFlag() {
		return this.catFlag;
	}

	public void setCatFlag(String catFlag) {
		this.catFlag = catFlag;
	}

	@Column(name = "MAKE_TYPE", length = 1)
	public String getMakeType() {
		return this.makeType;
	}

	public void setMakeType(String makeType) {
		this.makeType = makeType;
	}

	@Column(name = "MAK_NUM", precision = 22, scale = 0)
	public Long getMakNum() {
		return this.makNum;
	}

	public void setMakNum(Long makNum) {
		this.makNum = makNum;
	}

	@Column(name = "DEAL_FLAG", length = 1)
	public String getDealFlag() {
		return this.dealFlag;
	}

	public void setDealFlag(String dealFlag) {
		this.dealFlag = dealFlag;
	}

	@Column(name = "DEAL_TIME", length = 7)
	public java.util.Date getDealTime() {
		return this.dealTime;
	}

	public void setDealTime(Date dealTime) {
		this.dealTime = dealTime;
	}
	
	@Column(name = "USER_ID", length = 10)
	public String getUserId() {
		return this.userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	@Column(name = "BRCH_ID", length = 8)
	public String getBrchId() {
		return this.brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}
	
	@Column(name = "CARD_TYPE", length = 20)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}


	
	
}
