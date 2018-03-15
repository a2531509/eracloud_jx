/**   
* @Title: LoginServiceImpl.java TODO:
* @Package com.erp.serviceImpl
* @Description: TODO
* @author chenguang 
* @date 2015-4-1 下午03:21:57
* @version V1.0   
*/
package com.erp.serviceImpl;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.dao.PublicDao;
import com.erp.exception.CommonException;
import com.erp.model.SysLoginLog;
import com.erp.model.Users;
import com.erp.service.LoginService;
import com.erp.shiro.ShiroUser;
import com.erp.util.Constants;
import com.erp.viewModel.MenuModel;

/**
 * 类功能说明 TODO:
 * 类修改者	修改日期
 * 修改说明
 * <p>Title: LoginServiceImpl.java</p>
 * <p>Description:杰斯科技</p>
 * <p>Copyright: Copyright (c) 2012</p>
 * <p>Company:杰斯科技</p>
 * @author hujc 631410114@qq.com
 * @date 2015-4-1 下午03:21:57
 * @version V1.0
 */
@SuppressWarnings("rawtypes")
@Service("loginService")
public class LoginServiceImpl implements LoginService
{
	
	private PublicDao publicDaoSQL;
	@Autowired
	public void setPublicDaoSQL(PublicDao publicDaoSQL )
	{
		this.publicDaoSQL = publicDaoSQL;
	}
	
	/* (非 Javadoc) 
	* <p>Title: findMenuList</p> 
	* <p>Description:根据权限获取菜单 </p> 
	* @return 
	* @see com.erp.service.LoginService#findMenuList() 
	*/
	public List<MenuModel> findMenuList()
	{
		ShiroUser user = Constants.getCurrendUser();
		String sql=null;
		String sql1=null;//查询该用户具有的一级权限
		
		//超级管理员默认拥有所有功能权限
		if (Constants.SYSTEM_hujc.equals(user.getAccount()))
		{
			sql="SELECT p.PERMISSION_ID,p.PID,p.NAME,p.ICONCLS,p.URL FROM SYS_PERMISSION  p\n" +
					"where p.STATUS='A' and p.TYPE='F' and p.ISUSED='Y' and p.pid =(select PERMISSION_id from SYS_PERMISSION t1 where t1.pid is null and sort =(select min(t2.sort) from SYS_PERMISSION t2 where t2.pid is null)) order by p.sort ";
		}
		else 
		{
			sql1="SELECT p.permission_id,p.sort FROM \n" +
					"SYS_ROLE_PERMISSION  rp\n" +
					"INNER JOIN SYS_ROLE  r ON rp.ROLE_ID = r.ROLE_ID \n" +
					"INNER JOIN SYS_USER_ROLE  ur ON rp.ROLE_ID = ur.ROLE_ID \n" +
					"INNER JOIN SYS_USERS  u ON u.myid = ur.USER_ID \n" +
					"INNER JOIN SYS_PERMISSION  p ON rp.PERMISSION_ID = p.PERMISSION_ID \n" +
					"WHERE rp.STATUS='A' and r.STATUS='A' and ur.STATUS='A' and u.STATUS='A' and p.STATUS='A' and p.TYPE='F' and p.pid is null \n" +
					"and u.myid="+user.getUserId()+" GROUP BY p.permission_id,p.sort ORDER BY p.sort ";
			List listmenutop = publicDaoSQL.findBySQL(sql1);
			sql="SELECT DISTINCT p.PERMISSION_ID,p.PID,p.NAME,p.ICONCLS,p.URL,p.sort FROM \n" +
					"SYS_ROLE_PERMISSION  rp \n" +
					"INNER JOIN SYS_ROLE  r ON rp.ROLE_ID = r.ROLE_ID \n" +
					"INNER JOIN SYS_USER_ROLE  ur ON rp.ROLE_ID = ur.ROLE_ID \n" +
					"INNER JOIN SYS_USERS  u ON u.myid = ur.USER_ID \n" +
					"INNER JOIN SYS_PERMISSION  p ON rp.PERMISSION_ID = p.PERMISSION_ID \n" +
					"WHERE rp.STATUS='A' and r.STATUS='A' and ur.STATUS='A' and u.STATUS='A' and p.STATUS='A' and p.TYPE='F' and p.pid ='"+((Object[])listmenutop.get(0))[0]+"' and p.ISUSED='Y' \n" +
					"and u.myid='"+user.getUserId()+"' order by p.sort";
		}
		List listmenu = publicDaoSQL.findBySQL(sql);
		List<MenuModel> parentList=new ArrayList<MenuModel>();
		for (Object object : listmenu)
		{
			Object[] objs=(Object[])object;
			String id = String.valueOf(objs[0]);
			if (objs[1]!=null)
			{
				MenuModel menuModel=new MenuModel();
				menuModel.setName(String.valueOf(objs[2]));
				menuModel.setIconCls(String.valueOf(objs[3]));
				menuModel.setUrl(String.valueOf(objs[4]));
				if (Constants.SYSTEM_hujc.equals(user.getAccount()))
				{
					sql1="SELECT p.PERMISSION_ID,p.PID,p.NAME,p.ICONCLS,p.URL FROM SYS_PERMISSION  p\n" +
							"where p.STATUS='A' and p.TYPE='F' and p.ISUSED='Y' and p.pid ='"+String.valueOf(objs[0])+"' order by p.sort ";
				}
				else 
				{
					sql1="SELECT DISTINCT p.PERMISSION_ID,p.PID,p.NAME,p.ICONCLS,p.URL,p.sort FROM \n" +
							"SYS_ROLE_PERMISSION  rp \n" +
							"INNER JOIN SYS_ROLE  r ON rp.ROLE_ID = r.ROLE_ID \n" +
							"INNER JOIN SYS_USER_ROLE  ur ON rp.ROLE_ID = ur.ROLE_ID \n" +
							"INNER JOIN SYS_USERS  u ON u.myid = ur.USER_ID \n" +
							"INNER JOIN SYS_PERMISSION  p ON rp.PERMISSION_ID = p.PERMISSION_ID \n" +
							"WHERE rp.STATUS='A' and r.STATUS='A' and ur.STATUS='A' and u.STATUS='A' and p.STATUS='A' and p.TYPE='F' and p.pid ='"+String.valueOf(objs[0])+"' and p.ISUSED='Y' \n" +
							"and u.myid='"+user.getUserId()+"' order by p.sort";
				}
				List<MenuModel> listmenu1=publicDaoSQL.findBySQL(sql1);
				List<MenuModel> childList = new ArrayList<MenuModel>();
				for (Object obj2 : listmenu1)
				{
					MenuModel menuChildModel=new MenuModel();
					Object[] objs2=(Object[])obj2;
					String sid = String.valueOf(objs2[1]);
					if (sid.equals(id))
					{
						menuChildModel.setName(String.valueOf(objs2[2]));
						menuChildModel.setIconCls(String.valueOf(objs2[3]));
						menuChildModel.setUrl(String.valueOf(objs2[4]));
						childList.add(menuChildModel);
					}
				}
				menuModel.setChild(childList);
				parentList.add(menuModel);
			}
		}
		return parentList;
	}

	public List<MenuModel> findMenuTopList() {
		ShiroUser user = Constants.getCurrendUser();
		String sql=null;
		//超级管理员默认拥有所有功能权限
		if (Constants.SYSTEM_hujc.equals(user.getAccount()))
		{
			sql="SELECT p.PERMISSION_ID, p.myId,p.NAME FROM SYS_PERMISSION  p\n" +
					"where p.STATUS='A' and p.TYPE='F' and p.pid is null order by p.sort ";
		}
		else 
		{
			sql="SELECT DISTINCT p.PERMISSION_ID, p.myId,p.NAME,p.sort FROM \n" +
					"SYS_ROLE_PERMISSION  rp\n" +
					"INNER JOIN SYS_ROLE  r ON rp.ROLE_ID = r.ROLE_ID \n" +
					"INNER JOIN SYS_USER_ROLE  ur ON rp.ROLE_ID = ur.ROLE_ID \n" +
					"INNER JOIN sys_USERS  u ON u.myid = ur.USER_ID \n" +
					"INNER JOIN SYS_PERMISSION  p ON rp.PERMISSION_ID = p.PERMISSION_ID \n" +
					"WHERE rp.STATUS='A' and r.STATUS='A' and ur.STATUS='A' and u.STATUS='A' and p.STATUS='A' and p.TYPE='F' and p.pid is null \n" +
					"and u.myid="+user.getUserId()+" ORDER BY p.sort ";
		}
		List listmenu = publicDaoSQL.findBySQL(sql);
		List<MenuModel> parentList=new ArrayList<MenuModel>();
		for (Object object : listmenu)
		{
			Object[] objs=(Object[])object;
			if (objs[1]!=null)
			{
				MenuModel menuModel=new MenuModel();
				menuModel.setId(String.valueOf(objs[0]));
				menuModel.setMyId(String.valueOf(objs[1]));
				menuModel.setName(String.valueOf(objs[2]));
				parentList.add(menuModel);
			}
		}
		return parentList;
	}

	public List<MenuModel> findMenuByPidList(String pid) {
		ShiroUser user = Constants.getCurrendUser();
		String sql=null;
		//超级管理员默认拥有所有功能权限
		if (Constants.SYSTEM_hujc.equals(user.getAccount()))
		{
			sql="SELECT p.PERMISSION_ID,p.PID,p.NAME,p.ICONCLS,p.URL FROM SYS_PERMISSION  p\n" +
					"where p.STATUS='A' and p.TYPE='F' and p.ISUSED='Y' and p.pid ='"+pid+"' order by p.sort ";
		}
		else 
		{
			sql="SELECT DISTINCT p.PERMISSION_ID,p.PID,p.NAME,p.ICONCLS,p.URL,p.sort FROM \n" +
					"SYS_ROLE_PERMISSION  rp\n" +
					"INNER JOIN SYS_ROLE  r ON rp.ROLE_ID = r.ROLE_ID \n" +
					"INNER JOIN SYS_USER_ROLE  ur ON rp.ROLE_ID = ur.ROLE_ID \n" +
					"INNER JOIN SYS_USERS  u ON u.myid = ur.USER_ID \n" +
					"INNER JOIN SYS_PERMISSION  p ON rp.PERMISSION_ID = p.PERMISSION_ID \n" +
					"WHERE rp.STATUS='A' and r.STATUS='A' and ur.STATUS='A' and u.STATUS='A' and p.STATUS='A' and p.TYPE='F' and p.pid ='"+pid+"' and p.ISUSED='Y' \n" +
					"and u.myid="+user.getUserId()+" order by p.sort";
		}
		List listmenu = publicDaoSQL.findBySQL(sql);
		List<MenuModel> parentList=new ArrayList<MenuModel>();
		for (Object object : listmenu)
		{
			Object[] objs=(Object[])object;
			String id = String.valueOf(objs[0]);
			if (objs[1]!=null)
			{
				MenuModel menuModel=new MenuModel();
				menuModel.setName(String.valueOf(objs[2]));
				menuModel.setIconCls(String.valueOf(objs[3]));
				menuModel.setUrl(String.valueOf(objs[4]));
				String sql1="";
				if (Constants.SYSTEM_hujc.equals(user.getAccount()))
				{
					sql1="SELECT p.PERMISSION_ID,p.PID,p.NAME,p.ICONCLS,p.URL FROM SYS_PERMISSION  p\n" +
							"where p.STATUS='A' and p.TYPE='F' and p.ISUSED='Y' and p.pid ='"+String.valueOf(objs[0])+"' order by p.sort ";
				}
				else 
				{
					sql1="SELECT DISTINCT p.PERMISSION_ID,p.PID,p.NAME,p.ICONCLS,p.URL,p.sort FROM \n" +
							"SYS_ROLE_PERMISSION  rp \n" +
							"INNER JOIN SYS_ROLE  r ON rp.ROLE_ID = r.ROLE_ID \n" +
							"INNER JOIN SYS_USER_ROLE  ur ON rp.ROLE_ID = ur.ROLE_ID \n" +
							"INNER JOIN sys_USERS  u ON u.myid = ur.USER_ID \n" +
							"INNER JOIN SYS_PERMISSION  p ON rp.PERMISSION_ID = p.PERMISSION_ID \n" +
							"WHERE rp.STATUS='A' and r.STATUS='A' and ur.STATUS='A' and u.STATUS='A' and p.STATUS='A' and p.TYPE='F' and p.pid ='"+String.valueOf(objs[0])+"' and p.ISUSED='Y' \n" +
							"and u.myid="+user.getUserId()+" order by p.sort";
				}
				List<MenuModel> listmenu1=publicDaoSQL.findBySQL(sql1);
				List<MenuModel> childList = new ArrayList<MenuModel>();
				for (Object obj2 : listmenu1)
				{
					MenuModel menuChildModel=new MenuModel();
					Object[] objs2=(Object[])obj2;
					String sid = String.valueOf(objs2[1]);
					if (sid.equals(id))
					{
						menuChildModel.setName(String.valueOf(objs2[2]));
						menuChildModel.setIconCls(String.valueOf(objs2[3]));
						menuChildModel.setUrl(String.valueOf(objs2[4]));
						childList.add(menuChildModel);
					}
				}
				menuModel.setChild(childList);
				parentList.add(menuModel);
			}
		}
		return parentList;
	}

	@Override
	public void saveLoginLog(SysLoginLog loginLog,Users user,String type) throws CommonException {
		try {
			loginLog.setLogType("0");
			if("0".equals(type)){
				loginLog.setUserType(type);
				loginLog.setLogonTime(publicDaoSQL.getDateBaseTime());
			}else{
				loginLog.setUserType(type);
				loginLog.setLogoffTime(publicDaoSQL.getDateBaseTime());
			}
			loginLog.setOperTermId(user.getUserId());
			publicDaoSQL.save(loginLog);
		} catch (Exception e) {
			throw new CommonException("保存登录日志出错，登录失败！");
		}
	}

	@Override
	public void saveerrpwd(String userid) throws CommonException {
		try {
			this.publicDaoSQL.doSql("update sys_users set login_count = nvl(login_count,0)+1 where user_id = '"+userid+"'");
		} catch (Exception e) {
		}
	}

	@Override
	public void savechangenorpwd(String userid) throws CommonException {
		try {
			this.publicDaoSQL.doSql("update sys_users set login_count = '0' where user_id = '"+userid+"'");
		} catch (Exception e) {
		}
		
	}
}
