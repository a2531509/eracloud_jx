package com.erp.service;

import java.util.List;
import java.util.Map;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.SysOrgan;
import com.erp.model.Users;
import com.erp.util.PageUtil;
import com.erp.viewModel.UserRoleModel;

public interface UserService{

	boolean persistenceUsers(Map<String, List<Users>> map );

	List<Users> findAllUserList(Map<String, Object> map, PageUtil pageUtil);

	Long getCount(Map<String, Object> map , PageUtil pageUtil);

	List<UserRoleModel> findUsersRolesList(Integer userId );

	boolean saveUserRoles(Integer userId, String isCheckedIds );

	boolean persistenceUsers(Users u ) throws CommonException;

	boolean delUsers(Integer userId );
	
	List<SysOrgan> findAllUserList() throws CommonException;
	
	public long disableUser(String operId,String status);
	
	public void saveundopwderr(String userId);

	void saveChangePwd(Users users, String oldPwd, String newPwd, SysActionLog currentActionLog);
	public void saveUserPwd(String brchId,String operId,String oldPwd,String newPwd)throws CommonException;
}
