package com.erp.model;

import java.sql.Blob;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Lob;
import javax.persistence.Table;

/**
 * BasePhoto entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_PHOTO")
public class BasePhoto implements java.io.Serializable {

	// Fields

	private String customerId;
	private Blob photo;
	private String photoState;

	// Constructors

	/** default constructor */
	public BasePhoto() {
	}

	/** minimal constructor */
	public BasePhoto(String customerId) {
		this.customerId = customerId;
	}

	/** full constructor */
	public BasePhoto(String customerId, Blob photo, String photoState) {
		this.customerId = customerId;
		this.photo = photo;
		this.photoState = photoState;
	}

	// Property accessors
	@Id
	@Column(name = "CUSTOMER_ID", unique = true, nullable = false, length = 20)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}
	
	@Lob
	@Column(name = "PHOTO")
	public Blob getPhoto() {
		return this.photo;
	}

	public void setPhoto(Blob photo) {
		this.photo = photo;
	}

	@Column(name = "PHOTO_STATE", length = 1)
	public String getPhotoState() {
		return this.photoState;
	}

	public void setPhotoState(String photoState) {
		this.photoState = photoState;
	}

}