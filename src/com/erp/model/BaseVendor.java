package com.erp.model;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * BaseVendor entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_VENDOR")
public class BaseVendor implements java.io.Serializable {

	// Fields

	private String vendorId;
	private String vendorName;
	private String makeWay;
	private String address;
	private String contact;
	private String CTelNo;
	private String ceoName;
	private String ceoTelNo;
	private String faxNo;
	private String email;
	private String postCode;
	private Date openDate;
	private String openUserId;
	private String clsUserId;
	private Date clsDate;
	private String state;

	// Constructors

	/** default constructor */
	public BaseVendor() {
	}

	/** minimal constructor */
	public BaseVendor(String vendorId, String vendorName) {
		this.vendorId = vendorId;
		this.vendorName = vendorName;
	}

	/** full constructor */
	public BaseVendor(String vendorId, String vendorName, String makeWay,
			String address, String contact, String CTelNo, String ceoName,
			String ceoTelNo, String faxNo, String email, String postCode,
			Date openDate, String openUserId, String clsUserId, Date clsDate,
			String state) {
		this.vendorId = vendorId;
		this.vendorName = vendorName;
		this.makeWay = makeWay;
		this.address = address;
		this.contact = contact;
		this.CTelNo = CTelNo;
		this.ceoName = ceoName;
		this.ceoTelNo = ceoTelNo;
		this.faxNo = faxNo;
		this.email = email;
		this.postCode = postCode;
		this.openDate = openDate;
		this.openUserId = openUserId;
		this.clsUserId = clsUserId;
		this.clsDate = clsDate;
		this.state = state;
	}

	// Property accessors
	@Id
	@Column(name = "VENDOR_ID", unique = true, nullable = false, length = 4)
	public String getVendorId() {
		return this.vendorId;
	}

	public void setVendorId(String vendorId) {
		this.vendorId = vendorId;
	}

	@Column(name = "VENDOR_NAME", nullable = false, length = 64)
	public String getVendorName() {
		return this.vendorName;
	}

	public void setVendorName(String vendorName) {
		this.vendorName = vendorName;
	}

	@Column(name = "MAKE_WAY", length = 1)
	public String getMakeWay() {
		return this.makeWay;
	}

	public void setMakeWay(String makeWay) {
		this.makeWay = makeWay;
	}

	@Column(name = "ADDRESS", length = 128)
	public String getAddress() {
		return this.address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	@Column(name = "CONTACT", length = 32)
	public String getContact() {
		return this.contact;
	}

	public void setContact(String contact) {
		this.contact = contact;
	}

	@Column(name = "C_TEL_NO", length = 32)
	public String getCTelNo() {
		return this.CTelNo;
	}

	public void setCTelNo(String CTelNo) {
		this.CTelNo = CTelNo;
	}

	@Column(name = "CEO_NAME", length = 32)
	public String getCeoName() {
		return this.ceoName;
	}

	public void setCeoName(String ceoName) {
		this.ceoName = ceoName;
	}

	@Column(name = "CEO_TEL_NO", length = 32)
	public String getCeoTelNo() {
		return this.ceoTelNo;
	}

	public void setCeoTelNo(String ceoTelNo) {
		this.ceoTelNo = ceoTelNo;
	}

	@Column(name = "FAX_NO", length = 32)
	public String getFaxNo() {
		return this.faxNo;
	}

	public void setFaxNo(String faxNo) {
		this.faxNo = faxNo;
	}

	@Column(name = "EMAIL", length = 64)
	public String getEmail() {
		return this.email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	@Column(name = "POST_CODE", length = 6)
	public String getPostCode() {
		return this.postCode;
	}

	public void setPostCode(String postCode) {
		this.postCode = postCode;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "OPEN_DATE", length = 7)
	public Date getOpenDate() {
		return this.openDate;
	}

	public void setOpenDate(Date openDate) {
		this.openDate = openDate;
	}

	@Column(name = "OPEN_USER_ID", length = 10)
	public String getOpenUserId() {
		return this.openUserId;
	}

	public void setOpenUserId(String openUserId) {
		this.openUserId = openUserId;
	}

	@Column(name = "CLS_USER_ID", length = 10)
	public String getClsUserId() {
		return this.clsUserId;
	}

	public void setClsUserId(String clsUserId) {
		this.clsUserId = clsUserId;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "CLS_DATE", length = 7)
	public Date getClsDate() {
		return this.clsDate;
	}

	public void setClsDate(Date clsDate) {
		this.clsDate = clsDate;
	}

	@Column(name = "STATE", length = 1)
	public String getState() {
		return this.state;
	}

	public void setState(String state) {
		this.state = state;
	}

}