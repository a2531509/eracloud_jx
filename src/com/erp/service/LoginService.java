package com.erp.service;

import java.util.List;

import com.erp.exception.CommonException;
import com.erp.model.SysLoginLog;
import com.erp.model.Users;
import com.erp.viewModel.MenuModel;


/**
 * 类功能说明 TODO:
 * 类修改者	修改日期
 * 修改说明
 * <p>Title: LoginService.java</p>
 * <p>Description:杰斯科技</p>
 * <p>Copyright: Copyright (c) 2012</p>
 * <p>Company:杰斯科技</p>
 * @author hujc 631410114@qq.com
 * @date 2015-4-1 下午03:20:49
 * @version V1.0
 */
public interface LoginService 
{
	List<MenuModel> findMenuList();
	List<MenuModel> findMenuTopList();
	List<MenuModel> findMenuByPidList(String pid);
	
	public void saveLoginLog(SysLoginLog loginLog,Users user,String type) throws CommonException;
	public void saveerrpwd(String userid) throws CommonException;
	public void savechangenorpwd(String userid)throws CommonException;
	
}


