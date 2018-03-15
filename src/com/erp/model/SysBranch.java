package com.erp.model;

import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

import org.hibernate.annotations.DynamicInsert;
import org.hibernate.annotations.DynamicUpdate;

/**
 * SysBranch entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "sys_branch")
@DynamicUpdate(true)
@DynamicInsert(true)
public class SysBranch implements java.io.Serializable
{
	private static final long serialVersionUID = -3560252981789957584L;
	private Integer sysBranchId;
	private Integer orgId;
	private String brchId;
	private Integer pid;
	private String fullName;
	private String ename;
	private Integer manager;
	private String iconCls;
	private Integer assistantManager;
	private String brchType;
	private String status;
	private Date created;
	private Date lastmod;
	private String shortName;
	private String tel;
	private String fax;
	private String description;
	private Integer creater;
	private Integer modifyer;
	private String state="closed";
	private String regionId;
	private String townId;
	private String commId;
	private String brchAddress;
	private String isLkBrch;
	private String isLkBrch2;

	// Constructors

	/** default constructor */
	public SysBranch()
	{
	}

	/** full constructor */
	public SysBranch(Integer orgId, String brchId, Integer pid, String fullName, String ename,
			Integer manager, String iconCls, Integer assistantManager, String brchType,
			String status, Date created, Date lastmod, String shortName, String tel, String fax,
			String description, Integer creater, Integer modifyer, String state)
	{
		this.orgId = orgId;
		this.brchId = brchId;
		this.pid = pid;
		this.fullName = fullName;
		this.ename = ename;
		this.manager = manager;
		this.iconCls = iconCls;
		this.assistantManager = assistantManager;
		this.brchType = brchType;
		this.status = status;
		this.created = created;
		this.lastmod = lastmod;
		this.shortName = shortName;
		this.tel = tel;
		this.fax = fax;
		this.description = description;
		this.creater = creater;
		this.modifyer = modifyer;
		this.state = state;
	}

	// Property accessors
	@Id
	@GeneratedValue
	@Column(name = "SysBranch_ID", unique = true, nullable = false)
	public Integer getSysBranchId()
	{
		return this.sysBranchId;
	}

	public void setSysBranchId(Integer sysBranchId )
	{
		this.sysBranchId = sysBranchId;
	}

	@Column(name = "org_Id")
	public Integer getOrgId()
	{
		return this.orgId;
	}

	public void setOrgId(Integer orgId )
	{
		this.orgId = orgId;
	}

	@Column(name = "brch_Id", length = 25)
	public String getBrchId()
	{
		return this.brchId;
	}

	public void setBrchId(String brchId )
	{
		this.brchId = brchId;
	}

	@Column(name = "PID")
	public Integer getPid()
	{
		return this.pid;
	}

	public void setPid(Integer pid )
	{
		this.pid = pid;
	}

	@Column(name = "FULL_NAME")
	public String getFullName()
	{
		return this.fullName;
	}

	public void setFullName(String fullName )
	{
		this.fullName = fullName;
	}

	@Column(name = "ENAME", length = 100)
	public String getEname()
	{
		return this.ename;
	}

	public void setEname(String ename )
	{
		this.ename = ename;
	}

	@Column(name = "MANAGER")
	public Integer getManager()
	{
		return this.manager;
	}

	public void setManager(Integer manager )
	{
		this.manager = manager;
	}

	@Column(name = "ICONCLS", length = 100)
	public String getIconCls()
	{
		return iconCls;
	}

	public void setIconCls(String iconCls )
	{
		this.iconCls = iconCls;
	}

	@Column(name = "ASSISTANT_MANAGER")
	public Integer getAssistantManager()
	{
		return this.assistantManager;
	}

	public void setAssistantManager(Integer assistantManager )
	{
		this.assistantManager = assistantManager;
	}

	@Column(name = "brch_type")
	public String getBrchType()
	{
		return this.brchType;
	}

	public void setBrchType(String brchType )
	{
		this.brchType = brchType;
	}

	@Column(name = "STATUS", length = 1)
	public String getStatus()
	{
		return this.status;
	}

	public void setStatus(String status )
	{
		this.status = status;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "CREATED", length = 10)
	public Date getCreated()
	{
		return this.created;
	}

	public void setCreated(Date created )
	{
		this.created = created;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "LASTMOD", length = 10)
	public Date getLastmod()
	{
		return this.lastmod;
	}

	public void setLastmod(Date lastmod )
	{
		this.lastmod = lastmod;
	}

	@Column(name = "SHORT_NAME", length = 50)
	public String getShortName()
	{
		return this.shortName;
	}

	public void setShortName(String shortName )
	{
		this.shortName = shortName;
	}

	@Column(name = "TEL", length = 50)
	public String getTel()
	{
		return this.tel;
	}

	public void setTel(String tel )
	{
		this.tel = tel;
	}

	@Column(name = "FAX", length = 50)
	public String getFax()
	{
		return this.fax;
	}

	public void setFax(String fax )
	{
		this.fax = fax;
	}

	@Column(name = "DESCRIPTION", length = 2000)
	public String getDescription()
	{
		return this.description;
	}

	public void setDescription(String description )
	{
		this.description = description;
	}

	@Column(name = "CREATER")
	public Integer getCreater()
	{
		return this.creater;
	}

	public void setCreater(Integer creater )
	{
		this.creater = creater;
	}

	@Column(name = "MODIFYER")
	public Integer getModifyer()
	{
		return this.modifyer;
	}

	public void setModifyer(Integer modifyer )
	{
		this.modifyer = modifyer;
	}

	@Column(name = "STATE",length = 20)
	public String getState()
	{
		return this.state;
	}

	public void setState(String state )
	{
		this.state = state;
	}

	@Column(name = "region_id",length = 20)
	public String getRegionId() {
		return regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	@Column(name = "town_id",length = 20)
	public String getTownId() {
		return townId;
	}

	public void setTownId(String townId) {
		this.townId = townId;
	}

	@Column(name = "comm_id",length = 20)
	public String getCommId() {
		return commId;
	}

	public void setCommId(String commId) {
		this.commId = commId;
	}

	@Column(name = "BRCH_ADDRESS",length = 50)
	public String getBrchAddress() {
		return brchAddress;
	}

	public void setBrchAddress(String brchAddress) {
		this.brchAddress = brchAddress;
	}

	@Column(name = "IS_LK_BRCH")
	public String getIsLkBrch() {
		return isLkBrch;
	}

	public void setIsLkBrch(String isLkBrch) {
		this.isLkBrch = isLkBrch;
	}

	@Column(name = "IS_LK_BRCH2")
	public String getIsLkBrch2() {
		return isLkBrch2;
	}

	public void setIsLkBrch2(String isLkBrch2) {
		this.isLkBrch2 = isLkBrch2;
	}
}