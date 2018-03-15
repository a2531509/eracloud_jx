package com.erp.action;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.IncorrectCredentialsException;
import org.apache.shiro.authc.LockedAccountException;
import org.apache.shiro.authc.UnknownAccountException;
import org.apache.shiro.session.UnknownSessionException;
import org.apache.shiro.subject.Subject;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.SysLoginLog;
import com.erp.model.Users;
import com.erp.service.DoWorkClientService;
import com.erp.service.LoginService;
import com.erp.shiro.CaptchaUsernamePasswordToken;
import com.erp.shiro.IncorrectCaptchaException;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.Tools;
import com.erp.viewModel.Json;

/**
 * 类功能说明 TODO:
 * 类修改者	修改日期
 * 修改说明
 * <p>Title: LoginAction.java</p>
 * <p>Description:杰斯科技</p>
 * <p>Copyright: Copyright (c) 2012</p>
 * <p>Company:杰斯科技</p>
 * @author hujc 631410114@qq.com
 * @date 2015-4-1 上午10:13:47
 * @version V1.0
 */
@Namespace("/")
@Action(value="systemAction",results={@Result(name=Constants.LOGIN_SUCCESS_URL,location="/index.jsp"),
@Result(name=Constants.LOGIN_URL,location="/login.jsp"),
@Result(name=Constants.LOGIN_LOGIN_OUT_URL,type="chain",location="systemAction!loginInit.action")})
public class LoginAction extends BaseAction{	
	private static final Logger logger = Logger.getLogger(LoginAction.class);
	private static final long	serialVersionUID	= -6019556530071263499L;
	
	@Resource(name="doWorkClientService")
	private DoWorkClientService doWorkClientService;
	
	private String userName;
	private String password;
	private String captcha;
	private String userMacAddr;
	private String userKey;
	
	
	public String getUserKey()
	{
		return userKey;
	}
	public void setUserKey(String userKey )
	{
		this.userKey = userKey;
	}
	public String getUserMacAddr()
	{
		return userMacAddr;
	}
	public void setUserMacAddr(String userMacAddr )
	{
		this.userMacAddr = userMacAddr;
	}
	private LoginService loginService;
	
	public String getCaptcha()
	{
		return captcha;
	}
	public void setCaptcha(String captcha )
	{
		this.captcha = captcha;
	}
	public LoginService getLoginService()
	{
		return loginService;
	}
	@Autowired
	public void setLoginService(LoginService loginService)
	{
		this.loginService = loginService;
	}
	public String getUserName()
	{
		return userName;
	}
	public void setUserName(String userName)
	{
		this.userName = userName;
	}
		
	public String getPassword()
	{
		return password;
	}
	public void setPassword(String password )
	{
		this.password = password;
	}
	public String load() throws Exception{
		String messages = "";
		Subject subject = SecurityUtils.getSubject();
		Json json = new Json();
		json.setTitle("系统消息");
		CaptchaUsernamePasswordToken token = new CaptchaUsernamePasswordToken();
		token.setUsername(userName);
		token.setPassword(baseService.encrypt_des(password,Constants.APP_DES3_DEFAULT).toCharArray());
		token.setCaptcha(captcha);
		token.setRememberMe(true);
		Users user = (Users)baseService.findOnlyRowByHql("from Users where userId = '" + userName + "'");
		try{
            if(user == null){
            	messages = "该柜员未在系统登记，不能登入系统";
            	throw new UnknownAccountException(messages);
            }
            if(Tools.processNull(user.getIsemployee()).equals("0")){
            	messages = Constants.DAY_BAL_IS_EXECUTE_EXCEPTION;
            	throw new CommonException(messages);
            }
            if(Tools.processNull(user.getOrgId()).equals("")){
            	messages = "当前柜员没有所属机构，不能登入系统";
            	throw new CommonException(messages);
            }
            if(Tools.processNull(user.getBrchId()).equals("")){
            	messages = "当前柜员没有所属网点，不能登入系统";
            	throw new CommonException(messages);
            }
            Date lastDate = user.getLastmod();//最后修改日期
            if(lastDate == null){
            	logger.error("柜员密码最后修改时间不正确！");
            	throw new CommonException("柜员密码最后修改时间不正确！");
            }
       	    SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd");
       	    String date = format.format(lastDate);
       	    Calendar ca = Calendar.getInstance();
       	    ca.setTime(lastDate);
            ca.add(Calendar.DATE, Integer.parseInt(user.getPasswordValidity()));// 
       	    String pawDate = format.format(ca.getTime());
            if(format.parse(pawDate).before(Calendar.getInstance().getTime())){
            	messages=Constants.PASSWORD_EXPIRATION;
            	throw new CommonException(messages);
            }
            String errnum = (String)baseService.findOnlyFieldBySql("select para_value from sys_para where para_code = 'SYS_LOGIN_PWD_ERR_NUM'");
            int olderrnum =  user.getLoginCount() == null ? 0 : Integer.parseInt(user.getLoginCount().toString());
            if(olderrnum >=Integer.parseInt(errnum)){
            	messages="当前柜员输入的密码错误次数超限，请联系系统管理员进行解锁！";
            	throw new CommonException(messages);
            }
            if(!Tools.processNull(baseService.encrypt_des(password,Constants.APP_DES3_DEFAULT)).equals(user.getPassword())){
            	loginService.saveerrpwd(user.getUserId());
            }else{
            	loginService.savechangenorpwd(user.getUserId());
            }
            subject.login(token);
            json.setStatus(true);
            this.request.getSession().setAttribute("curUsers_",user);
            //
            this.request.getSession().setAttribute("curUsersPassValid_", Integer.parseInt(user.getPasswordValidity()) - DateUtil.getDaysFromTwoDate(lastDate, new Date()));
            subject.getSession().setAttribute(Constants.LOGIN_SESSION_DATANAME, user);
            loginLog("", user);
        }catch (UnknownSessionException use) {
            subject = new Subject.Builder().buildSubject();
            subject.login(token);
            logger.error(Constants.UNKNOWN_SESSION_EXCEPTION);
            loginLog(Constants.UNKNOWN_SESSION_EXCEPTION,user);
            json.setMessage(Constants.UNKNOWN_SESSION_EXCEPTION);
        }catch(UnknownAccountException ex){
			logger.error(Constants.UNKNOWN_ACCOUNT_EXCEPTION);
			if(user != null){
				loginLog(Constants.UNKNOWN_ACCOUNT_EXCEPTION,user);
			}
			json.setMessage(Constants.UNKNOWN_ACCOUNT_EXCEPTION);
		}catch (IncorrectCredentialsException ice) {
			logger.error(ice.getMessage());
			loginLog(Constants.INCORRECT_CREDENTIALS_EXCEPTION,user);
            json.setMessage(Constants.INCORRECT_CREDENTIALS_EXCEPTION);
        } catch (LockedAccountException lae) {
        	logger.error(lae.getMessage());
        	loginLog(Constants.LOCKED_ACCOUNT_EXCEPTION,user);
            json.setMessage(Constants.LOCKED_ACCOUNT_EXCEPTION);
        }catch (IncorrectCaptchaException e) {
        	logger.error(e.getMessage());
        	loginLog(Constants.INCORRECT_CAPTCHA_EXCEPTION,user);
        	json.setMessage(Constants.INCORRECT_CAPTCHA_EXCEPTION);
		}catch (AuthenticationException ae) {
			logger.error(ae.getMessage());
			loginLog(Constants.AUTHENTICATION_EXCEPTION,user);
            json.setMessage(Constants.AUTHENTICATION_EXCEPTION);
        }catch(Exception e){
        	logger.error(e.getMessage());
        	if(!messages.equals("")){
        		loginLog(messages,user);
        		json.setMessage(messages);
        	}else{
         		loginLog(Constants.UNKNOWN_EXCEPTION,user);
        		json.setMessage(Constants.UNKNOWN_EXCEPTION);
        	}
        }
        OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	public void loginLog(String message,Users user){
		  //记录登录日志
        SysLoginLog loginLog  = new SysLoginLog();
        loginLog.setLoginErro(message);
        loginLog.setIp(this.request.getRemoteAddr());
        loginService.saveLoginLog(loginLog,user,"0");
	}
	/**  
	* 函数功能说明 TODO:用户登出
	* hujc修改者名字
	* 2013-5-9修改日期
	* 修改内容
	* @Title: logout 
	* @Description:
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String cclogout() throws Exception
	{
		jsonObject.put("status","0");
		jsonObject.put("errMsg","保存系统退出成功");
		 try {
			//记录登录日志
            SysLoginLog loginLog  = new SysLoginLog();
            loginLog.setIp(this.request.getRemoteAddr());
            Users user = (Users)SecurityUtils.getSubject().getSession().getAttribute(Constants.LOGIN_SESSION_DATANAME);
            loginService.saveLoginLog(loginLog,user,"1");
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg","保存系统退出成功："+e.getMessage());
		}
		return this.JSONOBJ;
	
	}
	/**  
	* 函数功能说明 TODO:查询用户所有权限菜单
	* hujc修改者名字
	* 2013-5-9修改日期
	* 修改内容
	* @Title: findAllFunctionList 
	* @Description: 
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String findAllFunctionList() throws Exception
	{
		OutputJson(loginService.findMenuList());
		return null;
	}
	
	/**  
	* 函数功能说明 TODO:查询用户所有权限菜单
	* hujc修改者名字
	* 2013-5-9修改日期
	* 修改内容
	* @Title: findAllTopFunctionList 
	* @Description: 
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String findAllTopFunctionList() throws Exception
	{
		OutputJson(loginService.findMenuTopList());
		return null;
	}
	
	/**  
	* 函数功能说明 TODO:查询用户所有权限菜单
	* hujc修改者名字
	* 2013-5-9修改日期
	* 修改内容
	* @Title: findFunctionByPidList 
	* @Description: 
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String findFunctionByPidList() throws Exception
	{
		String  pid = ServletActionContext.getRequest().getParameter("ppid");
		OutputJson(loginService.findMenuByPidList(pid));
		return null;
	}
	
	/**
	 * 到达首页
	 * @return
	 */
	public String toIndex(){
		return Constants.LOGIN_URL;
	}
	
	public String getMainkeyandWorkKey(){//getMainkeyandWorkKey
		jsonObject.put("status","1");
		jsonObject.put("workkey","");
		jsonObject.put("msg","");
		try {
			JSONArray returnstr = doWorkClientService.getPosWorkKey("999999999999999","9999999999");
			if(returnstr == null || returnstr.isEmpty()){
				throw new CommonException("获取工作密钥发生错误，返回值为null");
			}
			JSONObject return_first = returnstr.getJSONObject(0);
			if(returnstr == null || returnstr.isEmpty()){
				throw new CommonException("获取工作钥发生错误，返回值为null");
			}
			jsonObject.put("status","0");
			jsonObject.put("workkey", return_first.get("workkey"));
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
		}
		return "jsonObj";
	}
	
}
