package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * BaseKanwuPrint entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_KANWU_PRINT")
public class BaseKanwuPrint implements java.io.Serializable {

	// Fields

	private String customerId;
	private String certNo;
	private String name;
	private String twocodePath;
	private String photoPath;

	// Constructors

	/** default constructor */
	public BaseKanwuPrint() {
	}

	/** minimal constructor */
	public BaseKanwuPrint(String customerId) {
		this.customerId = customerId;
	}

	/** full constructor */
	public BaseKanwuPrint(String customerId, String certNo, String name,
			String twocodePath, String photoPath) {
		this.customerId = customerId;
		this.certNo = certNo;
		this.name = name;
		this.twocodePath = twocodePath;
		this.photoPath = photoPath;
	}

	// Property accessors
	@Id
	@Column(name = "CUSTOMER_ID", unique = true, nullable = false, length = 12)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	@Column(name = "CERT_NO", length = 20)
	public String getCertNo() {
		return this.certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	@Column(name = "NAME", length = 40)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "TWOCODE_PATH", length = 1000)
	public String getTwocodePath() {
		return this.twocodePath;
	}

	public void setTwocodePath(String twocodePath) {
		this.twocodePath = twocodePath;
	}

	@Column(name = "PHOTO_PATH", length = 1000)
	public String getPhotoPath() {
		return this.photoPath;
	}

	public void setPhotoPath(String photoPath) {
		this.photoPath = photoPath;
	}

}