package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

@Entity
@Table(name = "merchant_safecode")
public class MerchantSafecode implements java.io.Serializable {
	private String merchantId;
	private String safeCode;
	private Date updateTime;
	private String ipAddress;
	private String portAddress;
	
	
	public MerchantSafecode() {
	}

	

	public MerchantSafecode(String merchantId, String safeCode, Date updateTime, String ipAddress, String portAddress) {
		this.merchantId = merchantId;
		this.safeCode = safeCode;
		this.updateTime = updateTime;
		this.ipAddress = ipAddress;
		this.portAddress = portAddress;
	}


	@Column(name = "ip", length = 20)
	public String getIpAddress() {
		return ipAddress;
	}
	public void setIpAddress(String ipAddress) {
		this.ipAddress = ipAddress;
	}
	@Column(name = "port", length = 5)
	public String getPortAddress() {
		return portAddress;
	}
	public void setPortAddress(String portAddress) {
		this.portAddress = portAddress;
	}
	@Id
	@Column(name = "merchant_id", length = 20)
	public String getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}
	@Column(name = "safecode", length = 50)
	public String getSafeCode() {
		return safeCode;
	}

	public void setSafeCode(String safeCode) {
		this.safeCode = safeCode;
	}


	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "update_time")
	public Date getUpdateTime() {
		return updateTime;
	}

	public void setUpdateTime(Date updateTime) {
		this.updateTime = updateTime;
	}

	
}
