package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Lob;
import javax.persistence.Table;

/**
 * SignBasePhoto entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SIGN_BASE_PHOTO")

public class SignBasePhoto implements java.io.Serializable {

	// Fields

	private String clientId;
	private byte[] photo;
	private String state;

	// Constructors

	/** default constructor */
	public SignBasePhoto() {
	}

	/** minimal constructor */
	public SignBasePhoto(String clientId) {
		this.clientId = clientId;
	}

	/** full constructor */
	public SignBasePhoto(String clientId, byte[] photo, String state) {
		this.clientId = clientId;
		this.photo = photo;
		this.state = state;
	}

	// Property accessors
	@Id

	@Column(name = "CLIENT_ID", unique = true, nullable = false, length = 10)

	public String getClientId() {
		return this.clientId;
	}

	public void setClientId(String clientId) {
		this.clientId = clientId;
	}

	@Lob
	@Column(name = "PHOTO")

	public byte[] getPhoto() {
		return this.photo;
	}

	public void setPhoto(byte[] photo) {
		this.photo = photo;
	}

	@Column(name = "STATE", length = 1)

	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

}