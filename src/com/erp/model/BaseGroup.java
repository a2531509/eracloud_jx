package com.erp.model;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * BaseGroup entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "BASE_GROUP")
public class BaseGroup implements java.io.Serializable {

	// Fields

	private String groupId;
	private String groupName;
	private String groupState;
	private String commId;

	// Constructors

	/** default constructor */
	public BaseGroup() {
	}

	/** minimal constructor */
	public BaseGroup(String groupId) {
		this.groupId = groupId;
	}

	/** full constructor */
	public BaseGroup(String groupId, String groupName, String groupState,
			String commId) {
		this.groupId = groupId;
		this.groupName = groupName;
		this.groupState = groupState;
		this.commId = commId;
	}

	// Property accessors
	@Id
	@Column(name = "GROUP_ID", unique = true, nullable = false, length = 20)
	public String getGroupId() {
		return this.groupId;
	}

	public void setGroupId(String groupId) {
		this.groupId = groupId;
	}

	@Column(name = "GROUP_NAME", length = 50)
	public String getGroupName() {
		return this.groupName;
	}

	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}

	@Column(name = "GROUP_STATE", length = 1)
	public String getGroupState() {
		return this.groupState;
	}

	public void setGroupState(String groupState) {
		this.groupState = groupState;
	}

	@Column(name = "COMM_ID", length = 20)
	public String getCommId() {
		return this.commId;
	}

	public void setCommId(String commId) {
		this.commId = commId;
	}

}