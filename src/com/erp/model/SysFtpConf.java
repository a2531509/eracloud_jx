package com.erp.model;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * SysFtpConf entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SYS_FTP_CONF")
public class SysFtpConf implements java.io.Serializable {

	// Fields

	private SysFtpConfId id;
	private String ftpParaValue;

	// Constructors

	/** default constructor */
	public SysFtpConf() {
	}

	/** minimal constructor */
	public SysFtpConf(SysFtpConfId id) {
		this.id = id;
	}

	/** full constructor */
	public SysFtpConf(SysFtpConfId id, String ftpParaValue) {
		this.id = id;
		this.ftpParaValue = ftpParaValue;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "ftpUse", column = @Column(name = "FTP_USE", nullable = false, length = 100)),
			@AttributeOverride(name = "ftpParaName", column = @Column(name = "FTP_PARA_NAME", nullable = false, length = 100)) })
	public SysFtpConfId getId() {
		return this.id;
	}

	public void setId(SysFtpConfId id) {
		this.id = id;
	}

	@Column(name = "FTP_PARA_VALUE", length = 100)
	public String getFtpParaValue() {
		return this.ftpParaValue;
	}

	public void setFtpParaValue(String ftpParaValue) {
		this.ftpParaValue = ftpParaValue;
	}

}