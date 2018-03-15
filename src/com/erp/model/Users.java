package com.erp.model;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Transient;

import org.hibernate.annotations.DynamicInsert;
import org.hibernate.annotations.DynamicUpdate;

/**
 * Users entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "sys_users")
@DynamicUpdate(true)
@DynamicInsert(true)
public class Users implements java.io.Serializable
{
	private static final long serialVersionUID = 3091722681204768199L;
	private Integer myid;
	private String userId;
	private String account;
	private String name;
	private String brchId;
	private String brchName;
	private Integer dutyId;
	private Integer titleId;
	private String password;
	private String email;
	private String lang;
	private String theme;
	private Date firstVisit;
	private Date previousVisit;
	private Date lastVisits;
	private Integer loginCount;
	private Integer isemployee;
	private String status;
	private String ip;
	private String description;
	private String orgId;
	private Long cashLmt;
	private Integer isonline;
	private Date created;
	private Date lastmod;
	private String creater;
	private String modifyer;
	private String tel;
	private String passwordValidity;
	


	private String fullName;//网点名称
	private Set<SysUserRole> userRoles = new HashSet<SysUserRole>(0);

	// Constructors

	/** default constructor */
	public Users()
	{
	}

	/** full constructor */
	public Users(String userId, String account, String name, String brchId, String brchName,
			Integer dutyId, Integer titleId, String password, String email, String lang,
			String theme, Date firstVisit, Date previousVisit, Date lastVisits, Integer loginCount,
			Integer isemployee, String status, String ip, String description, String orgId,
			Long cashLmt, Integer isonline, Date created, Date lastmod, String creater,
			String modifyer, String tel,String passwordValidity, Set<SysUserRole> userRoles)
	{
		this.userId = userId;
		this.account = account;
		this.name = name;
		this.brchId = brchId;
		this.brchName = brchName;
		this.dutyId = dutyId;
		this.titleId = titleId;
		this.password = password;
		this.email = email;
		this.lang = lang;
		this.theme = theme;
		this.firstVisit = firstVisit;
		this.previousVisit = previousVisit;
		this.lastVisits = lastVisits;
		this.loginCount = loginCount;
		this.isemployee = isemployee;
		this.status = status;
		this.ip = ip;
		this.description = description;
		this.orgId = orgId;
		this.cashLmt = cashLmt;
		this.isonline = isonline;
		this.created = created;
		this.lastmod = lastmod;
		this.creater = creater;
		this.modifyer = modifyer;
		this.tel = tel;
		this.passwordValidity = passwordValidity;
		this.userRoles = userRoles;
	}

	// Property accessors
	@Column(name = "USER_ID", length = 50)
	public String getUserId()
	{
		return this.userId;
	}

	public void setUserId(String userId )
	{
		this.userId = userId;
	}

	
	@Id
	@GeneratedValue
	@Column(name = "MYID", unique = true, nullable = false)
	public Integer getMyid()
	{
		return this.myid;
	}

	public void setMyid(Integer myid )
	{
		this.myid = myid;
	}

	@Column(name = "ACCOUNT", length = 50)
	public String getAccount()
	{
		return this.account;
	}

	public void setAccount(String account )
	{
		this.account = account;
	}

	@Column(name = "NAME", length = 50)
	public String getName()
	{
		return this.name;
	}

	public void setName(String name )
	{
		this.name = name;
	}

	@Column(name = "brch_id")
	public String getBrchId()
	{
		return this.brchId;
	}

	public void setBrchId(String brchId )
	{
		this.brchId = brchId;
	}

	@Column(name = "brch_NAME")
	public String getBrchName()
	{
		return this.brchName;
	}

	public void setBrchName(String brchName )
	{
		this.brchName = brchName;
	}

	@Column(name = "DUTY_ID")
	public Integer getDutyId()
	{
		return this.dutyId;
	}

	public void setDutyId(Integer dutyId )
	{
		this.dutyId = dutyId;
	}

	@Column(name = "TITLE_ID")
	public Integer getTitleId()
	{
		return this.titleId;
	}

	public void setTitleId(Integer titleId )
	{
		this.titleId = titleId;
	}

	@Column(name = "PASSWORD", length = 128)
	public String getPassword()
	{
		return this.password;
	}

	public void setPassword(String password )
	{
		this.password = password;
	}

	@Column(name = "EMAIL", length = 200)
	public String getEmail()
	{
		return this.email;
	}

	public void setEmail(String email )
	{
		this.email = email;
	}

	@Column(name = "LANG", length = 20)
	public String getLang()
	{
		return this.lang;
	}

	public void setLang(String lang )
	{
		this.lang = lang;
	}

	@Column(name = "THEME", length = 20)
	public String getTheme()
	{
		return this.theme;
	}

	public void setTheme(String theme )
	{
		this.theme = theme;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "FIRST_VISIT", length = 10)
	public Date getFirstVisit()
	{
		return this.firstVisit;
	}

	public void setFirstVisit(Date firstVisit )
	{
		this.firstVisit = firstVisit;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "PREVIOUS_VISIT", length = 10)
	public Date getPreviousVisit()
	{
		return this.previousVisit;
	}

	public void setPreviousVisit(Date previousVisit )
	{
		this.previousVisit = previousVisit;
	}

	@Temporal(TemporalType.TIMESTAMP)
	@Column(name = "LAST_VISITS", length = 10)
	public Date getLastVisits()
	{
		return this.lastVisits;
	}

	public void setLastVisits(Date lastVisits )
	{
		this.lastVisits = lastVisits;
	}

	@Column(name = "LOGIN_COUNT")
	public Integer getLoginCount()
	{
		return this.loginCount;
	}

	public void setLoginCount(Integer loginCount )
	{
		this.loginCount = loginCount;
	}

	@Column(name = "ISEMPLOYEE")
	public Integer getIsemployee()
	{
		return this.isemployee;
	}

	public void setIsemployee(Integer isemployee )
	{
		this.isemployee = isemployee;
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

	@Column(name = "IP", length = 20)
	public String getIp()
	{
		return this.ip;
	}

	public void setIp(String ip )
	{
		this.ip = ip;
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

	@Column(name = "org_id")
	public String getOrgId()
	{
		return this.orgId;
	}

	public void setOrgId(String orgId )
	{
		this.orgId = orgId;
	}

	@Column(name = "cash_lmt", length = 100)
	public Long getCashLmt()
	{
		return this.cashLmt;
	}

	public void setCashLmt(Long cashLmt )
	{
		this.cashLmt = cashLmt;
	}

	@Column(name = "ISONLINE")
	public Integer getIsonline()
	{
		return this.isonline;
	}

	public void setIsonline(Integer isonline )
	{
		this.isonline = isonline;
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

	@Column(name = "CREATER")
	public String getCreater()
	{
		return this.creater;
	}

	public void setCreater(String creater )
	{
		this.creater = creater;
	}

	@Column(name = "MODIFYER")
	public String getModifyer()
	{
		return this.modifyer;
	}

	public void setModifyer(String modifyer )
	{
		this.modifyer = modifyer;
	}

	@Column(name = "TEL", length = 30)
	public String getTel()
	{
		return this.tel;
	}

	public void setTel(String tel )
	{
		this.tel = tel;
	}
	
	@Column(name = "PASSWORD_VALIDITY", length = 10)
	public String getPasswordValidity() {
		return passwordValidity;
	}

	public void setPasswordValidity(String passwordValidity) {
		this.passwordValidity = passwordValidity;
	}

	@OneToMany(cascade = CascadeType.ALL, fetch = FetchType.LAZY, mappedBy = "users")
	public Set<SysUserRole> getUserRoles()
	{
		return this.userRoles;
	}

	public void setUserRoles(Set<SysUserRole> userRoles )
	{
		this.userRoles = userRoles;
	}
	@Transient
	public String getFullName() {
		return fullName;
	}

	public void setFullName(String fullName) {
		this.fullName = fullName;
	}

}