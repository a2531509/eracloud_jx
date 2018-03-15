package com.erp.model;

import java.util.Date;
import javax.persistence.*;

/**
 * SignMeeting entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SIGN_MEETING")
@SequenceGenerator(name="SEQ_SIGN_MEETING_ID",allocationSize=1,initialValue=100000,sequenceName="SEQ_SIGN_MEETING_ID" )
public class SignMeeting implements java.io.Serializable {

	// Fields

	private Long meetingId;
	private String meetingSubject;
	private String meetingAddress;
	private Date meetingStartTime;
	private Date meetingEndTime;
	private String meetingState;
	private Long meetingInitSum;
	private Long meetingActuSum;
	private Long meetingTempSum;
	private Long meetingFinalSum;
	private String meetingCreatorUserId;
	private Date meetingCreatorDate;
	private String meetingClsUserId;
	private Date meetingClsDate;
	private String meetingOrganizer;
    private String meetingCoOrganizer;
    private String meetingUnOrganizer;
	private String note;

	// Constructors

	/** default constructor */
	public SignMeeting() {
	}

	/** minimal constructor */
	public SignMeeting(Long meetingId, Long meetingInitSum, Long meetingActuSum,
			Long meetingTempSum, Long meetingFinalSum) {
		this.meetingId = meetingId;
		this.meetingInitSum = meetingInitSum;
		this.meetingActuSum = meetingActuSum;
		this.meetingTempSum = meetingTempSum;
		this.meetingFinalSum = meetingFinalSum;
	}

	/** full constructor */
	public SignMeeting(Long meetingId, String meetingSubject, String meetingAddress, Date meetingStartTime,
			Date meetingEndTime, String meetingState, Long meetingInitSum, Long meetingActuSum,
			Long meetingTempSum, Long meetingFinalSum, String meetingCreatorUserId, Date meetingCreatorDate,
			String meetingClsUserId, Date meetingClsDate, String note) {
		this.meetingId = meetingId;
		this.meetingSubject = meetingSubject;
		this.meetingAddress = meetingAddress;
		this.meetingStartTime = meetingStartTime;
		this.meetingEndTime = meetingEndTime;
		this.meetingState = meetingState;
		this.meetingInitSum = meetingInitSum;
		this.meetingActuSum = meetingActuSum;
		this.meetingTempSum = meetingTempSum;
		this.meetingFinalSum = meetingFinalSum;
		this.meetingCreatorUserId = meetingCreatorUserId;
		this.meetingCreatorDate = meetingCreatorDate;
		this.meetingClsUserId = meetingClsUserId;
		this.meetingClsDate = meetingClsDate;
		this.note = note;
	}
	// Property accessors
	@Id
    @GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_SIGN_MEETING_ID")
	@Column(name = "MEETING_ID", unique = true, nullable = false, length = 10)
	public Long getMeetingId() {
		return this.meetingId;
	}
	public void setMeetingId(Long meetingId) {
		this.meetingId = meetingId;
	}
	@Column(name = "MEETING_SUBJECT", length = 500)
	public String getMeetingSubject() {
		return this.meetingSubject;
	}
	public void setMeetingSubject(String meetingSubject) {
		this.meetingSubject = meetingSubject;
	}
	@Column(name = "MEETING_ADDRESS", length = 300)
	public String getMeetingAddress() {
		return this.meetingAddress;
	}
	public void setMeetingAddress(String meetingAddress) {
		this.meetingAddress = meetingAddress;
	}
	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "MEETING_START_TIME", length = 7)
	public Date getMeetingStartTime() {
		return this.meetingStartTime;
	}
	public void setMeetingStartTime(Date meetingStartTime) {
		this.meetingStartTime = meetingStartTime;
	}
	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "MEETING_END_TIME", length = 7)
	public Date getMeetingEndTime() {
		return this.meetingEndTime;
	}
	public void setMeetingEndTime(Date meetingEndTime) {
		this.meetingEndTime = meetingEndTime;
	}
	@Column(name = "MEETING_STATE", length = 1)
	public String getMeetingState() {
		return this.meetingState;
	}
	public void setMeetingState(String meetingState) {
		this.meetingState = meetingState;
	}
	@Column(name = "MEETING_INIT_SUM", nullable = false, precision = 22, scale = 0)
	public Long getMeetingInitSum() {
		return this.meetingInitSum;
	}
	public void setMeetingInitSum(Long meetingInitSum) {
		this.meetingInitSum = meetingInitSum;
	}
	@Column(name = "MEETING_ACTU_SUM", nullable = false, precision = 22, scale = 0)
	public Long getMeetingActuSum() {
		return this.meetingActuSum;
	}
	public void setMeetingActuSum(Long meetingActuSum) {
		this.meetingActuSum = meetingActuSum;
	}
	@Column(name = "MEETING_TEMP_SUM", nullable = false, precision = 22, scale = 0)
	public Long getMeetingTempSum() {
		return this.meetingTempSum;
	}
	public void setMeetingTempSum(Long meetingTempSum) {
		this.meetingTempSum = meetingTempSum;
	}
	@Column(name = "MEETING_FINAL_SUM", nullable = false, precision = 22, scale = 0)
	public Long getMeetingFinalSum() {
		return this.meetingFinalSum;
	}
	public void setMeetingFinalSum(Long meetingFinalSum) {
		this.meetingFinalSum = meetingFinalSum;
	}
	@Column(name = "MEETING_CREATOR_USER_ID", length = 20)
	public String getMeetingCreatorUserId() {
		return this.meetingCreatorUserId;
	}
	public void setMeetingCreatorUserId(String meetingCreatorUserId) {
		this.meetingCreatorUserId = meetingCreatorUserId;
	}
	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "MEETING_CREATOR_DATE", length = 7)
	public Date getMeetingCreatorDate() {
		return this.meetingCreatorDate;
	}
	public void setMeetingCreatorDate(Date meetingCreatorDate) {
		this.meetingCreatorDate = meetingCreatorDate;
	}
	@Column(name = "MEETING_CLS_USER_ID", length = 20)
	public String getMeetingClsUserId() {
		return this.meetingClsUserId;
	}
	public void setMeetingClsUserId(String meetingClsUserId) {
		this.meetingClsUserId = meetingClsUserId;
	}
	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "MEETING_CLS_DATE", length = 7)
	public Date getMeetingClsDate() {
		return this.meetingClsDate;
	}
	public void setMeetingClsDate(Date meetingClsDate) {
		this.meetingClsDate = meetingClsDate;
	}
	@Column(name = "NOTE", length = 200)
	public String getNote() {
		return this.note;
	}
	public void setNote(String note) {
		this.note = note;
	}
    @Column(name = "MEETING_ORGANIZER", length = 300)
    public String getMeetingOrganizer(){
        return meetingOrganizer;
    }
    public void setMeetingOrganizer(String meetingOrganizer){
        this.meetingOrganizer = meetingOrganizer;
    }
    @Column(name = "MEETING_CO_ORGANIZER", length = 300)
    public String getMeetingCoOrganizer(){
        return meetingCoOrganizer;
    }
    public void setMeetingCoOrganizer(String meetingCoOrganizer){
        this.meetingCoOrganizer = meetingCoOrganizer;
    }
    @Column(name = "MEETING_UN_ORGANIZER", length = 300)
    public String getMeetingUnOrganizer(){
        return meetingUnOrganizer;
    }
    public void setMeetingUnOrganizer(String meetingUnOrganizer){
        this.meetingUnOrganizer = meetingUnOrganizer;
    }

}