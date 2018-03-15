
package com.erp.shiro;

import java.util.List;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.AuthenticationInfo;
import org.apache.shiro.authc.AuthenticationToken;
import org.apache.shiro.authc.LockedAccountException;
import org.apache.shiro.authc.SimpleAuthenticationInfo;
import org.apache.shiro.authc.UnknownAccountException;
import org.apache.shiro.authz.AuthorizationInfo;
import org.apache.shiro.authz.SimpleAuthorizationInfo;
import org.apache.shiro.cache.Cache;
import org.apache.shiro.realm.AuthorizingRealm;
import org.apache.shiro.subject.PrincipalCollection;
import org.apache.shiro.subject.SimplePrincipalCollection;
import org.apache.shiro.subject.Subject;
import org.hibernate.Session;
import org.hibernate.SessionFactory;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.Users;
import com.erp.util.Constants;
import com.erp.util.Tools;

/**
* 类功能说明 TODO:自定义Realm
* 类修改者
* 修改日期
* 修改说明
* <p>Title: MyShiroRealm.java</p>
* <p>Description:杰斯科技</p>
* <p>Copyright: Copyright (c) 2006</p>
* <p>Company:杰斯科技有限公司</p>
* @author hujc 631410114@qq.com
* @date 2013-5-29 上午11:32:29
* @version V1.0
*/

public class MyShiroRealm extends AuthorizingRealm
{
	 // 用于获取用户信息及用户权限信息的业务接口 
	private SessionFactory hibernateSessionFactory;

	public SessionFactory getSessionFactory() {
		return hibernateSessionFactory;
	}

	public void setHibernateSessionFactory(SessionFactory hibernateSessionFactory )
	{
		this.hibernateSessionFactory = hibernateSessionFactory;
	}
	@SuppressWarnings("unused")
	private Session getCurrentSession() {
		return hibernateSessionFactory.getCurrentSession();
	}

	@SuppressWarnings("rawtypes")
	protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals){
		//String username = (String) principals.fromRealm(getName()).iterator().next();
		 ShiroUser shiroUser = (ShiroUser) principals.fromRealm(getName()).iterator().next();
		 String username= shiroUser.getAccount();
		if(username != null){
			SimpleAuthorizationInfo info = new SimpleAuthorizationInfo();
			// 查询用户授权信息
			//info.addRole("admin");
			String sql = null;
			//超级管理员默认拥有所有操作权限
			if(Constants.SYSTEM_hujc.equals(username)){
				sql = "SELECT p.PERMISSION_ID,p.MYID FROM SYS_PERMISSION p\n" + "where p.STATUS='A' and p.TYPE='O' and p.ISUSED='Y'";
			}else{
			   sql = "select distinct rp.permission_id,p.myid from \n" +
					 "sys_role_permission  rp\n" +
					 "inner join sys_role  r on rp.role_id = r.role_id\n" +
					 "inner join sys_user_role  ur on rp.role_id = ur.role_id\n" +
					 "inner join sys_users  u on u.myid = ur.user_id\n" +
					 "inner join sys_permission  p on rp.permission_id = p.permission_id\n" +
					 "where rp.status = 'A' and r.status='A' and ur.status='A' and u.status='A' and p.status='A' and p.type='O' and p.isused='Y'\n" +
					 "and u.user_id ='" + username + "'";
			}
			List perList = this.getSessionFactory().getCurrentSession().createSQLQuery(sql).list();
			if(perList!=null&&perList.size() !=0 ){
				for (Object object : perList){
					 Object[] obj = (Object[])object;
					 info.addStringPermission(obj[1].toString());
				}
				return info;
			}
		}
		return null;
	}
	// 获取认证信息
	protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken authcToken)throws AuthenticationException{
		CaptchaUsernamePasswordToken token = (CaptchaUsernamePasswordToken) authcToken; 
		String username = token.getUsername(); 
		if(!Tools.processNull(username).replaceAll(" ","").equals("") && doCaptchaValidate(token)){
			SessionFactory s = this.getSessionFactory();
			String hql = "from Users t where t.userId = :userId";
			Users users = (Users)s.getCurrentSession().createQuery(hql).setParameter("userId",username).uniqueResult();
			if(users != null){
				if(!Tools.processSpace(users.getStatus()).equals("A")){
					throw new LockedAccountException("账号已被锁定，请与系统管理员联系！");
				}
				Subject subject = SecurityUtils.getSubject();
				subject.getSession().setAttribute(Constants.SHIRO_USER,new ShiroUser(users.getMyid(),users.getUserId()));
				try{
					subject.getSession().setAttribute(Constants.ACTIONLOG,doSysActionLog(users.getUserId(),s));
				}catch (Exception e){
					throw new AuthenticationException("创建日志错误");
				}
				return new SimpleAuthenticationInfo(new ShiroUser(users.getMyid(),users.getAccount()),users.getPassword(),getName());
			}else{
				throw new UnknownAccountException("用户或密码不正确！");
			}
		}
		return null;
	}    
	
	/**
	 * 业务日志记录
	 * @param request
	 * @param Oper_Id 操作员编号
	 * @param message 消息日志
	 * @return 业务ID
	 * @throws CommonException
	 */
	public SysActionLog doSysActionLog(String userId,SessionFactory s ) throws Exception {
		SysActionLog action = new SysActionLog();//业务日志表
		action.setUserId(Tools.processNull(userId));//柜员编号
		String sql1="select brch_id from sys_users t where t.user_id='"+userId+"'";
		String brchId= s.getCurrentSession().createSQLQuery(sql1).list().get(0).toString();
		action.setBrchId(brchId);
//		String sql="select to_char(sysdate,'yyyy-mm-dd HH24:mi:ss') from dual";
//		String datatime=s.getCurrentSession().createSQLQuery(sql).list().get(0).toString();
//		action.setDealTime(DateUtil.formatDateTime(datatime));//操作时间
		action.setLogType("0");//日志类型0-业务日志1-回退日志
		action.setMessage("");//日志信息
		action.setCanRoll("1");//可否回退0可回退1不可回退
		action.setRollFlag("0");//回退标志0未回退1已回退
		action.setOther("");//其他信息
		action.setNote("");//备注
		//dao.insert(action);
		return action;
	}
	
	/**
	 * 更新用户授权信息缓存.
	 */

	public void clearCachedAuthorizationInfo(String principal ){
		SimplePrincipalCollection principals = new SimplePrincipalCollection(
		principal, getName());
		clearCachedAuthorizationInfo(principals);
	}

	/**
	 * 清除所有用户授权信息缓存.
	 */

	public void clearAllCachedAuthorizationInfo(){
		Cache<Object, AuthorizationInfo> cache = getAuthorizationCache();
		if(cache != null){
			for (Object key : cache.keys())
			{
				cache.remove(key);
			}
		}
	}
	//验证码校验
	protected boolean doCaptchaValidate(CaptchaUsernamePasswordToken token){
		/*String captcha = (String) ServletActionContext.getRequest().getSession().getAttribute(com.google.code.kaptcha.Constants.KAPTCHA_SESSION_KEY);
		if(captcha != null &&!captcha.equalsIgnoreCase(token.getCaptcha())){
			throw new IncorrectCaptchaException("验证码错误！");
		}*/
		return true;
	}
}
