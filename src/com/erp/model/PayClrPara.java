package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Embeddable;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

import org.hibernate.annotations.DynamicInsert;
import org.hibernate.annotations.DynamicUpdate;

/**
 * PayClrParaId entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "Pay_Clr_Para")
public class PayClrPara implements java.io.Serializable {

	// Fields

	private String clrDate;
	private String accSwitch;
	private String batchProcNo;
	private String batchProcState;
	private Date lastModiTime;

	
	/** default constructor */
	public PayClrPara()
	{
	}
	/** full constructor */
	public PayClrPara(String clrDate, String accSwitch, String batchProcNo,
			String batchProcState, Date lastModiTime) {
		this.clrDate = clrDate;
		this.accSwitch = accSwitch;
		this.batchProcNo = batchProcNo;
		this.batchProcState = batchProcState;
		this.lastModiTime = lastModiTime;
	}

	@Id
	@Column(name = "CLR_DATE", length = 10)
	public String getClrDate() {
		return this.clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	@Column(name = "ACC_SWITCH", length = 1)
	public String getAccSwitch() {
		return this.accSwitch;
	}

	public void setAccSwitch(String accSwitch) {
		this.accSwitch = accSwitch;
	}

	@Column(name = "BATCH_PROC_NO", length = 14)
	public String getBatchProcNo() {
		return this.batchProcNo;
	}

	public void setBatchProcNo(String batchProcNo) {
		this.batchProcNo = batchProcNo;
	}

	@Column(name = "BATCH_PROC_STATE", length = 1)
	public String getBatchProcState() {
		return this.batchProcState;
	}

	public void setBatchProcState(String batchProcState) {
		this.batchProcState = batchProcState;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "LAST_MODI_TIME", length = 7)
	public Date getLastModiTime() {
		return this.lastModiTime;
	}

	public void setLastModiTime(Date lastModiTime) {
		this.lastModiTime = lastModiTime;
	}

	public boolean equals(Object other) {
		if ((this == other))
			return true;
		if ((other == null))
			return false;
		if (!(other instanceof PayClrPara))
			return false;
		PayClrPara castOther = (PayClrPara) other;

		return ((this.getClrDate() == castOther.getClrDate()) || (this
				.getClrDate() != null && castOther.getClrDate() != null && this
				.getClrDate().equals(castOther.getClrDate())))
				&& ((this.getAccSwitch() == castOther.getAccSwitch()) || (this
						.getAccSwitch() != null
						&& castOther.getAccSwitch() != null && this
						.getAccSwitch().equals(castOther.getAccSwitch())))
				&& ((this.getBatchProcNo() == castOther.getBatchProcNo()) || (this
						.getBatchProcNo() != null
						&& castOther.getBatchProcNo() != null && this
						.getBatchProcNo().equals(castOther.getBatchProcNo())))
				&& ((this.getBatchProcState() == castOther.getBatchProcState()) || (this
						.getBatchProcState() != null
						&& castOther.getBatchProcState() != null && this
						.getBatchProcState().equals(
								castOther.getBatchProcState())))
				&& ((this.getLastModiTime() == castOther.getLastModiTime()) || (this
						.getLastModiTime() != null
						&& castOther.getLastModiTime() != null && this
						.getLastModiTime().equals(castOther.getLastModiTime())));
	}

	public int hashCode() {
		int result = 17;

		result = 37 * result
				+ (getClrDate() == null ? 0 : this.getClrDate().hashCode());
		result = 37 * result
				+ (getAccSwitch() == null ? 0 : this.getAccSwitch().hashCode());
		result = 37
				* result
				+ (getBatchProcNo() == null ? 0 : this.getBatchProcNo()
						.hashCode());
		result = 37
				* result
				+ (getBatchProcState() == null ? 0 : this.getBatchProcState()
						.hashCode());
		result = 37
				* result
				+ (getLastModiTime() == null ? 0 : this.getLastModiTime()
						.hashCode());
		return result;
	}

}