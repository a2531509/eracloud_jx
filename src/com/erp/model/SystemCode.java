package com.erp.model;

import java.math.BigDecimal;
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
 * SystemCode entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SYS_CODE")
@SequenceGenerator(name="SEQ_SYSTEM_CODE",allocationSize=1,initialValue=1,sequenceName="SEQ_SYSTEM_CODE_ID")
public class SystemCode implements java.io.Serializable {

	// Fields

	private Long codeId;
	private String codeMyid;
	private String name;
	private Integer sort;
	private String codeType;
	private String iconCls;
	private String state;
	private Integer permissionId;
	private Integer parentId;
	private String description;
	private String status;
	private Date created;
	private Date lastmod;
	private Integer creater;
	private Integer modifyer;

	// Constructors

	/** default constructor */
	public SystemCode() {
	}

	/** minimal constructor */
	public SystemCode(Long codeId, String codeMyid, String name,
			Integer sort, String type) {
		this.codeId = codeId;
		this.codeMyid = codeMyid;
		this.name = name;
		this.sort = sort;
		this.codeType = type;
	}

	/** full constructor */
	public SystemCode(Long codeId, String codeMyid, String name,
			Integer sort, String type, String iconcls, String state,
			Integer permissionid, Integer parentId, String description,
			String status, Date created, Date lastmod, Integer creater,
			Integer modifyer) {
		this.codeId = codeId;
		this.codeMyid = codeMyid;
		this.name = name;
		this.sort = sort;
		this.codeType = type;
		this.iconCls = iconcls;
		this.state = state;
		this.permissionId = permissionid;
		this.parentId = parentId;
		this.description = description;
		this.status = status;
		this.created = created;
		this.lastmod = lastmod;
		this.creater = creater;
		this.modifyer = modifyer;
	}

	// Property accessors
	@Id
	@Column(name = "CODE_ID", unique = true, nullable = false, precision = 22, scale = 0)
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_SYSTEM_CODE")
	public Long getCodeId() {
		return codeId;
	}

	public void setCodeId(Long codeId) {
		this.codeId = codeId;
	}

	@Column(name = "CODE_MYID", nullable = false, length = 100)
	public String getCodeMyid() {
		return this.codeMyid;
	}


	public void setCodeMyid(String codeMyid) {
		this.codeMyid = codeMyid;
	}

	@Column(name = "NAME", nullable = false)
	public String getName() {
		return this.name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Column(name = "SORT", nullable = false, precision = 22, scale = 0)
	public Integer getSort() {
		return sort;
	}

	public void setSort(Integer sort) {
		this.sort = sort;
	}

	@Column(name = "TYPE", nullable = false, length = 10)
	public String getCodeType() {
		return codeType;
	}

	public void setCodeType(String codeType) {
		this.codeType = codeType;
	}

	@Column(name = "ICONCLS", length = 100)
	public String getIconCls() {
		return iconCls;
	}

	

	public void setIconCls(String iconCls) {
		this.iconCls = iconCls;
	}

	@Column(name = "STATE", length = 20)
	public String getState() {
		return this.state;
	}

	

	public void setState(String state) {
		this.state = state;
	}

	@Column(name = "PERMISSIONID", precision = 22, scale = 0)
	public Integer getPermissionId() {
		return permissionId;
	}

	public void setPermissionId(Integer permissionId) {
		this.permissionId = permissionId;
	}

	@Column(name = "PID", precision = 22, scale = 0)
	public Integer getParentId() {
		return parentId;
	}

	public void setParentId(Integer parentId) {
		this.parentId = parentId;
	}

	@Column(name = "DESCRIPTION", length = 2000)
	public String getDescription() {
		return this.description;
	}

	

	public void setDescription(String description) {
		this.description = description;
	}

	@Column(name = "STATUS", length = 1)
	public String getStatus() {
		return this.status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "CREATED", length = 7)
	public Date getCreated() {
		return this.created;
	}

	public void setCreated(Date created) {
		this.created = created;
	}

	@Temporal(TemporalType.DATE)
	@Column(name = "LASTMOD", length = 7)
	public Date getLastmod() {
		return this.lastmod;
	}

	public void setLastmod(Date lastmod) {
		this.lastmod = lastmod;
	}

	@Column(name = "CREATER", precision = 22, scale = 0)
	public Integer getCreater() {
		return creater;
	}

	public void setCreater(Integer creater) {
		this.creater = creater;
	}

	

	@Column(name = "MODIFYER", precision = 22, scale = 0)
	public Integer getModifyer() {
		return modifyer;
	}

	public void setModifyer(Integer modifyer) {
		this.modifyer = modifyer;
	}

}