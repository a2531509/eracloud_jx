package com.erp.model;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * SignMeetingDetails entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SIGN_MEETING_DETAILS")

public class SignMeetingDetails implements java.io.Serializable {

	// Fields

	private String signId;
	private String meetingId;
	private String name;
	private String sex;
	private String certNo;
	private String title;
	private Date signInTime;
	private Date signOutTime;
	private String signType;
	private String signState;
	private String note;

	// Constructors

	/** default constructor */
	public SignMeetingDetails() {
	}

	/** minimal constructor */
	public SignMeetingDetails(String signId) {
		this.signId = signId;
	}

	/** full constructor */
	public SignMeetingDetails(String signId, String meetingId, String name, String sex, String certNo, String title,
			Date signInTime, Date signOutTime, String signType, String signState, String note) {
		this.signId = signId;
		this.meetingId = meetingId;
		this.name = name;
		this.sex = sex;
		this.certNo = certNo;
		this.title = title;
		this.signInTime = signInTime;
		this.signOutTime = signOutTime;
		this.signType = signType;
		this.signState = signState;
		this.note = note;
	}

	// Property accessors
	@Id

	@Column(name = "SIGN_ID", unique = true, nullable = false, length = 10)

	public String getSignId() {
		return this.signId;
	}

	public void setSignId(String signId) {
		this.signId = signId;
	}

	@Column(name = "MEETING_ID", length = 10)

	public String getMeetingId() {
		return this.meetingId;
	}

	public void setMeetingId(String meetingId) {
		this.meetingId = meetingId;
	}

	@Column(name = "NAME", length = 20)

	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "SEX", length = 1)

	public String getSex() {
		return this.sex;
	}

	public void setSex(String sex) {
		this.sex = sex;
	}

	@Column(name = "CERT_NO", length = 20)

	public String getCertNo() {
		return this.certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	@Column(name = "TITLE", length = 100)

	public String getTitle() {
		return this.title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "SIGN_IN_TIME", length = 7)

	public Date getSignInTime() {
		return this.signInTime;
	}

	public void setSignInTime(Date signInTime) {
		this.signInTime = signInTime;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "SIGN_OUT_TIME", length = 7)

	public Date getSignOutTime() {
		return this.signOutTime;
	}

	public void setSignOutTime(Date signOutTime) {
		this.signOutTime = signOutTime;
	}

	@Column(name = "SIGN_TYPE", length = 1)

	public String getSignType() {
		return this.signType;
	}

	public void setSignType(String signType) {
		this.signType = signType;
	}

	@Column(name = "SIGN_STATE", length = 1)

	public String getSignState() {
		return this.signState;
	}

	public void setSignState(String signState) {
		this.signState = signState;
	}

	@Column(name = "NOTE", length = 500)

	public String getNote() {
		return this.note;
	}

	public void setNote(String note) {
		this.note = note;
	}

}