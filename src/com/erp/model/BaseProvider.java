package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * BaseProvider entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_PROVIDER")
@SequenceGenerator(name="SEQ_BASIC_PROVIDER_PK",allocationSize=1,initialValue=10010089,sequenceName="SEQ_BASIC_PROVIDER" )
public class BaseProvider implements java.io.Serializable {

	// Fields

	private Long providerId;
	private String providerName;
	private String providerState;
	private String providerContract;
	private String providerType;
	private String providerAddress;
	private String providerTelNo;
	private String providerLinkman;
	private String providerPost;
	private Date operDate;
	private String operId;

	// Constructors

	/** default constructor */
	public BaseProvider() {
	}

	/** minimal constructor */
	public BaseProvider(Long providerId) {
		this.providerId = providerId;
	}

	/** full constructor */
	public BaseProvider(Long providerId, String providerName,
			String providerState, String providerContract, String providerType,
			String providerAddress, String providerTelNo,
			String providerLinkman, String providerPost, Date operDate,
			String operId) {
		this.providerId = providerId;
		this.providerName = providerName;
		this.providerState = providerState;
		this.providerContract = providerContract;
		this.providerType = providerType;
		this.providerAddress = providerAddress;
		this.providerTelNo = providerTelNo;
		this.providerLinkman = providerLinkman;
		this.providerPost = providerPost;
		this.operDate = operDate;
		this.operId = operId;
	}

	// Property accessors
	@Id
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_BASIC_PROVIDER_PK")
	@Column(name = "PROVIDER_ID", unique = true, nullable = false, precision = 20, scale = 0)
	public Long getProviderId() {
		return this.providerId;
	}

	public void setProviderId(Long providerId) {
		this.providerId = providerId;
	}

	@Column(name = "PROVIDER_NAME", length = 100)
	public String getProviderName() {
		return this.providerName;
	}

	public void setProviderName(String providerName) {
		this.providerName = providerName;
	}

	@Column(name = "PROVIDER_STATE", length = 1)
	public String getProviderState() {
		return this.providerState;
	}

	public void setProviderState(String providerState) {
		this.providerState = providerState;
	}

	@Column(name = "PROVIDER_CONTRACT", length = 100)
	public String getProviderContract() {
		return this.providerContract;
	}

	public void setProviderContract(String providerContract) {
		this.providerContract = providerContract;
	}

	@Column(name = "PROVIDER_TYPE", length = 1)
	public String getProviderType() {
		return this.providerType;
	}

	public void setProviderType(String providerType) {
		this.providerType = providerType;
	}

	@Column(name = "PROVIDER_ADDRESS", length = 100)
	public String getProviderAddress() {
		return this.providerAddress;
	}

	public void setProviderAddress(String providerAddress) {
		this.providerAddress = providerAddress;
	}

	@Column(name = "PROVIDER_TEL_NO", length = 20)
	public String getProviderTelNo() {
		return this.providerTelNo;
	}

	public void setProviderTelNo(String providerTelNo) {
		this.providerTelNo = providerTelNo;
	}

	@Column(name = "PROVIDER_LINKMAN", length = 20)
	public String getProviderLinkman() {
		return this.providerLinkman;
	}

	public void setProviderLinkman(String providerLinkman) {
		this.providerLinkman = providerLinkman;
	}

	@Column(name = "PROVIDER_POST", length = 20)
	public String getProviderPost() {
		return this.providerPost;
	}

	public void setProviderPost(String providerPost) {
		this.providerPost = providerPost;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "OPER_DATE", length = 7)
	public Date getOperDate() {
		return this.operDate;
	}

	public void setOperDate(Date operDate) {
		this.operDate = operDate;
	}

	@Column(name = "OPER_ID", length = 10)
	public String getOperId() {
		return this.operId;
	}

	public void setOperId(String operId) {
		this.operId = operId;
	}

}