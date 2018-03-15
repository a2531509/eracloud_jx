package com.erp.action;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.subject.Subject;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.SysBranch;
import com.erp.model.Users;
import com.erp.service.UserService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.Tools;
import com.erp.viewModel.Json;
import com.erp.viewModel.Page;

@Namespace("/user")
@Action(value="userAction")
@InterceptorRefs({@InterceptorRef("jsondefalut")})
@Results({
	@Result(name="edit",location="/jsp/user/userEditDlg.jsp"),
	@Result(name="add",location="/jsp/user/userEditDlg.jsp"),
	@Result(name="changeUserPwdPage", location="/jsp/user/userPwdChange.jsp"),
	@Result(name="editPwdIndex",location="/jsp/user/updatepwd.jsp")
})
public class UserAction extends BaseAction{
	private static final long serialVersionUID = -8188592660918385632L;
	private UserService userService;
	private String isCheckedIds;
	private Users users = new Users();
	private String queryType = "1";//查询类型
	private String branchId;//下拉框网点编号
	private String operatorId;//下拉框柜员编号
	private SysBranch branch;
	private String userId;//查询柜员编号
	private String status;
	private String defaultErrorMsg;//错误信息
	private String editType = "1";//编辑类型
	private String state;//柜员状态
	private String operName;//柜员名称
	private String oldPwd;
	private String newPwd;
	private String pwd;
	
	/**
	 * 获取所有的柜员信息
	 */
	public String findAllUserList() throws Exception{
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		try{
			if(Tools.processNull(this.queryType).equals("0")){
	            String errnum = (String)baseService.findOnlyFieldBySql("select para_value from sys_para where para_code = 'SYS_LOGIN_PWD_ERR_NUM'");
				StringBuffer sb = new StringBuffer("");
				sb.append("select t.myid,t.user_id,t.name,t.org_id,o.org_name,t.brch_id,b.full_name,t.duty_id,decode(t.title_id,'0','是','否') title_id,");
				sb.append("t.password,t.email,t.account,");
				sb.append("decode(t.status,'A','正常','注销') status,t.description,t.cash_lmt,t.isonline,");
				sb.append("to_char(t.created,'yyyy-mm-dd') created,t.creater,to_char(t.lastmod,'yyyy-mm-dd') lastmod,t.modifyer,t.tel ");
				sb.append(",(case when nvl(t.login_count,0)>="+errnum+" then '是' else '否' end)  ISLOCKPWD,t.password_validity from sys_users t,sys_branch b,sys_organ o where t.brch_id = b.brch_id(+) and b.org_id = o.org_id(+) ");
				if(!Tools.processNull(userId).equals("")){
					sb.append("and t.user_id = '" + userId + "' ");
				}
				if(!Tools.processNull(this.branchId).equals("")){
					sb.append("and t.brch_id = '" + branchId + "' ");
				}
				if(!Tools.processNull(this.operatorId).equals("")){
					sb.append("and t.user_id = '" + operatorId + "' ");
				}
				if(Tools.processNull(this.state).equals("0")){
					sb.append("and t.status = 'A' ");
				}
				if(Tools.processNull(this.state).equals("1")){
					sb.append("and t.status = 'I' ");
				}
				if(!Tools.processNull(this.operName).equals("")){
					sb.append("and t.name like '%" + this.operName + "%'");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("未查询到柜员信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 保存新增或编辑保存柜员信息
	 * @return
	 * @throws Exception
	 */
	public String persistenceUsersDig() throws Exception{
		jsonObject.put("statsus","1");
		jsonObject.put("msg","");
		String type = Tools.processNull(this.users.getMyid()).equals("") ? "新增柜员信息" : "编辑柜员信息";
		try{
			userService.persistenceUsers(this.getUsers());
			jsonObject.put("status","0");
			jsonObject.put("msg",type + "成功！");
		}catch(Exception e){
			jsonObject.put("msg",type + "失败！" + e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 柜员编辑页面
	 * @return
	 */
	public String editUsers(){
		try{
			//1.根据柜员编号获取柜员信息
			users = (Users) baseService.findOnlyRowByHql("from Users t where t.userId = '" + this.userId + "'");
			//2.获取网点信息
			SysBranch brch = (SysBranch) baseService.findOnlyRowByHql("from SysBranch t where t.brchId = '" + users.getBrchId() + "'");
			users.setBrchId(brch.getSysBranchId() + "");//重设网点ID
			users.setPassword(baseService.decrypt_des(users.getPassword(),Constants.APP_DES3_DEFAULT));
			this.editType = "0";
			//3.如果柜员信息不存在,提示错误信息
			if(users == null){
				users = new Users();
				throw new CommonException("柜员信息不存在，不能进行编辑！");
			}
		}catch(Exception e){
			this.defaultErrorMsg = e.getMessage();
		}
		return "edit";
	}
	public String editPwdIndex(){
		try{
			users = (Users) baseService.findOnlyRowByHql("from Users t where t.userId = '" + this.userId + "'");
			if(users == null){
				throw new CommonException("柜员信息不存在！");
			}
			if(users.getLastmod() == null){
				users.setLastmod(baseService.getDateBaseDate());
			}
			if(Tools.processNull(users.getPasswordValidity()).equals("")){
				users.setPasswordValidity("0");
			}
			users.setFullName(DateUtil.processDateAddDay(DateUtil.formatDate(users.getLastmod(),"yyyy-MM-dd"),Integer.valueOf(users.getPasswordValidity())));
			SysBranch brch = (SysBranch) baseService.findOnlyRowByHql("from SysBranch t where t.brchId = '" + users.getBrchId() + "'");
			state = Tools.processNull(brch.getFullName());
			this.editType = "0";
			if(users == null){
				users = new Users();
				throw new CommonException("柜员信息不存在，不能进行密码修改！");
			}
		}catch(Exception e){
			this.defaultErrorMsg = e.getMessage();
		}
		return "editPwdIndex";
	}
	public String saveUserPwd() throws Exception{
		try{
			jsonObject.put("statsus","1");
			jsonObject.put("msg","");
			userService.saveUserPwd(users.getBrchId(),users.getUserId(),oldPwd,pwd);
			jsonObject.put("status","0");
			jsonObject.put("msg","密码修改成功！");
		}catch(Exception e){
			jsonObject.put("msg","密码修改失败：" + e.getMessage());
		}
		return this.JSONOBJ;
	}
	public String addUsers(){
		return "add";
	}
	public String findOrgLsit(){
		OutputJson(userService.findAllUserList());
		return null;
	}
	public String persistenceUsers() throws Exception{
		Map<String, List<Users>> map=new HashMap<String, List<Users>>();
		map.put("addList", JSON.parseArray(inserted, Users.class));
		map.put("updList", JSON.parseArray(updated, Users.class));
		map.put("delList", JSON.parseArray(deleted, Users.class));
		Json json=new Json();
		if (userService.persistenceUsers(map)) {
			json.setStatus(true);
			json.setMessage("数据更新成功！");
		}else {
			json.setMessage("提交失败了！");
		}
		OutputJson(json);
		return null;
	}
	public String delUsers() throws Exception{
		OutputJson(getMessage(userService.delUsers(getModel().getMyid())));
		return null;
	}
	public String disableUser(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			userService.disableUser(userId,this.status);
			jsonObject.put("status","0");
			jsonObject.put("msg",(Tools.processNull(this.status).equals("A") ? "激活" : "注销") + "成功！");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	
	public String undopwderr(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			userService.saveundopwderr(userId);
			jsonObject.put("status","0");
			jsonObject.put("msg","密码解锁成功");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String findUsersRolesList() throws Exception{
		OutputJson(userService.findUsersRolesList(Integer.parseInt(this.getUserId())));
		return null;
	}
	public String saveUserRoles() throws Exception{
		Json json=new Json();
		if (userService.saveUserRoles(Integer.valueOf(this.userId), isCheckedIds)) {
			json.setStatus(true);
			json.setMessage("数据更新成功！");
		}else {
			json.setMessage("提交失败了！");
		}
		OutputJson(json);
		return null;
	}
	public void showUserInfo()throws Exception{
		HttpServletResponse response = ServletActionContext.getResponse();
		Subject subject=SecurityUtils.getSubject();
		response.getWriter().write("当前用户信息：" + subject.getSession().getAttribute("shiroUser"));
	}
	
	public String toChangeUserPwd(){
		userId = baseService.getUser().getUserId();
		return "changeUserPwdPage";
	}
	
	public String changeUserPwd(){
		try {
			userService.saveChangePwd(baseService.getUser(), oldPwd, newPwd, baseService.getCurrentActionLog());
			jsonObject.put("status", "0");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public Users getModel(){ 
		if (null == users){
			users = new Users();
		}
		return users;
	}
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public Users getUsers(){
		return users;
	}
	public void setUsers(Users users){
		this.users = users;
	}
	@Autowired
	public void setUserService(UserService userService){
		this.userService = userService;
	}
	public String getIsCheckedIds(){
		return isCheckedIds;
	}
	public void setIsCheckedIds(String isCheckedIds){
		this.isCheckedIds = isCheckedIds;
	}
	public String getQueryType(){
		return queryType;
	}
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	public UserService getUserService() {
		return userService;
	}
	public String getBranchId() {
		return branchId;
	}
	public void setBranchId(String branchId) {
		this.branchId = branchId;
	}
	public String getOperatorId() {
		return operatorId;
	}
	public void setOperatorId(String operatorId) {
		this.operatorId = operatorId;
	}
	public SysBranch getBranch() {
		return branch;
	}
	public void setBranch(SysBranch branch) {
		this.branch = branch;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public String getDefaultErrorMsg() {
		return defaultErrorMsg;
	}
	public void setDefaultErrorMsg(String defaultErrorMsg) {
		this.defaultErrorMsg = defaultErrorMsg;
	}
	public String getEditType() {
		return editType;
	}
	public void setEditType(String editType) {
		this.editType = editType;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	public String getOperName() {
		return operName;
	}
	public void setOperName(String operName) {
		this.operName = operName;
	}
	
	
	public static void main(String[] args) {
		//System.out.println(base.encrypt_des("admin","erp2","",""));
	}
	public String getOldPwd() {
		return oldPwd;
	}
	public void setOldPwd(String oldPwd) {
		this.oldPwd = oldPwd;
	}
	public String getNewPwd() {
		return newPwd;
	}
	public void setNewPwd(String newPwd) {
		this.newPwd = newPwd;
	}
	/**
	 * @return the pwd
	 */
	public String getPwd() {
		return pwd;
	}
	/**
	 * @param pwd the pwd to set
	 */
	public void setPwd(String pwd) {
		this.pwd = pwd;
	}
}
