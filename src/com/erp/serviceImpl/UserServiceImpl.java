package com.erp.serviceImpl;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.dao.PublicDao;
import com.erp.exception.CommonException;
import com.erp.model.CashBox;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.SysOrgan;
import com.erp.model.SysRole;
import com.erp.model.SysUserRole;
import com.erp.model.Users;
import com.erp.service.LoginService;
import com.erp.service.UserService;
import com.erp.shiro.ShiroUser;
import com.erp.util.Constants;
import com.erp.util.DealCode;
import com.erp.util.PageUtil;
import com.erp.util.Tools;
import com.erp.viewModel.UserRoleModel;

@Service("userService")
@SuppressWarnings("rawtypes")
public class UserServiceImpl extends BaseServiceImpl implements UserService{
	@Resource(name="loginService")
	private LoginService loginService;
	private PublicDao publicDaoSQL;
	@Autowired
	public void setPublicDaoSQL(PublicDao publicDaoSQL ){
		this.publicDaoSQL = publicDaoSQL;
	}
	/**
	 * 柜员信息新增或是编辑
	 */
	@SuppressWarnings("unchecked")
	public boolean persistenceUsers(Users oper) throws CommonException {
		try{
			Users currentOper = this.getUser();//当前柜员信息
			SysBranch branch = (SysBranch) this.findOnlyRowByHql("from SysBranch t where t.sysBranchId = " + oper.getBrchId());//新增柜员所属网点信息
			if(Tools.processNull(oper.getMyid()).equals("")){
				List exists = this.findByHql("from Users t where t.userId = '" + oper.getUserId() + "'");
				if(exists != null && exists.size() > 0){
					throw new CommonException("当前柜员编号已经存在！");
				}
				//新建尾箱信息
				
				CashBox box = new CashBox();
				box.setOrgId(branch.getOrgId().toString());
				box.setBrchId(branch.getBrchId());
				box.setCoinKind(Constants.COIN_TYPE);
				box.setUserId(oper.getUserId());
				box.setTdBlc(0L);
				box.setTdInAmt(0L);
				box.setTdInNum(0L);
				box.setTdOutAmt(0L);
				box.setTdOutNum(0L);
				box.setYdBlc(0L);
				box.setFrzAmt(0L);
				publicDao.save(box);
				oper.setPassword(this.encrypt_des(oper.getPassword(),Constants.APP_DES3_DEFAULT));
				oper.setCreated(this.getDateBaseTime());
				oper.setAccount(oper.getUserId());
				oper.setLastmod(this.getDateBaseTime());
				oper.setCreater(currentOper.getUserId());
				oper.setModifyer(currentOper.getUserId());
				oper.setStatus(Constants.PERSISTENCE_STATUS);
				oper.setBrchName(branch.getFullName());
				oper.setBrchId(branch.getBrchId());
				oper.setOrgId(branch.getOrgId() + "");
				publicDao.save(oper);
			}else {
				Users oldOper = (Users) this.findOnlyRowByHql("from Users t where t.myid = " + oper.getMyid());
				oldOper.setName(oper.getName());
				oldOper.setPassword(oper.getPassword());
				oldOper.setEmail(oper.getEmail());
				oldOper.setTel(oper.getTel());
				oldOper.setDutyId(oper.getDutyId());
				oldOper.setTitleId(oper.getTitleId());
				oldOper.setLastmod(this.getDateBaseTime());
				oldOper.setModifyer(currentOper.getUserId());
				oldOper.setBrchName(branch.getFullName());
				oldOper.setDescription(oper.getDescription());
				oldOper.setPassword(this.encrypt_des(oper.getPassword(),Constants.APP_DES3_DEFAULT));
				oldOper.setPasswordValidity(oper.getPasswordValidity());
				publicDao.update(oldOper);
			}
			return true;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 注销或是激活柜员状态
	 */
	public long disableUser(String operId,String status){
		try{
			if(Tools.processNull(status).equals("")){
				throw new CommonException("柜员操作状态类型不能为空！");
			}
			String string = Tools.processNull(status).equals("A") ? "激活" : "注销";
			if(Tools.processNull(operId).equals("")){
				throw new CommonException(string + "柜员用户编号不能为空！");
			}
			Users oper = (Users) this.findOnlyRowByHql("from Users t where t.userId = '" + operId + "'");
			if(oper == null){
				throw new CommonException("根据柜员编号" + operId + "未找到柜员信息，无法进行" + string + "！");
			}
			int updarecount = publicDao.doSql("update SYS_USERS t set t.status = '" + status + "' where t.user_id = '" + operId + "'");
			if(updarecount != 1){
				throw new CommonException("根据柜员编号" + operId + string + "柜员更新" + updarecount + "行！");
			}
			return updarecount;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	public void saveUserPwd(String brchId,String operId,String oldPwd,String newPwd)throws CommonException{
		try{
			if(Tools.processNull(brchId).equals("")){
				throw new CommonException("网点编号为空！");
			}
			if(Tools.processNull(operId).equals("")){
				throw new CommonException("柜员编号为空！");
			}
			if(Tools.processNull(oldPwd).equals("")){
				throw new CommonException("请输入原密码！");
			}
			if(Tools.processNull(newPwd).equals("")){
				throw new CommonException("请输入新密码！");
			}
			Users oper = (Users) this.findOnlyRowByHql("from Users t where t.brchId = '" + brchId + "' and t.userId = '" + operId + "'");
			if(oper == null){
				throw new CommonException("根据网点编号" + brchId + "，柜员编号" + operId + "找不到柜员信息！");
			}
			String errnum = (String)this.findOnlyFieldBySql("select para_value from sys_para where para_code = 'SYS_LOGIN_PWD_ERR_NUM'");
			if(Tools.processNull(errnum).equals("")){
				errnum = "6";
			}
			if(oper.getLoginCount() == null){
				oper.setLoginCount(0);
			}
			if(Integer.valueOf(errnum) <= oper.getLoginCount()){
				throw new CommonException("当前柜员输入的密码错误次数超限，请联系系统管理员进行解锁！");
			}
			if(!Tools.processNull(this.encrypt_des(oldPwd,Constants.APP_DES3_DEFAULT)).equals(oper.getPassword())){
				loginService.saveerrpwd(oper.getUserId());
				this.publicDao.doSql("commit");
				throw new CommonException("原密码不正确！");
            }else{
            	loginService.savechangenorpwd(oper.getUserId());
            	this.publicDao.doSql("commit");
            }
			int ii = this.publicDao.doSql("update sys_users set lastmod = sysdate,password = '" + this.encrypt_des(newPwd,Constants.APP_DES3_DEFAULT) + "' where brch_id = '" + brchId + "' and user_id = '" + operId + "'");
			if(ii != 1){
				throw new CommonException("密码修改出现错误，请重试！");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	public boolean persistenceUsers(Map<String, List<Users>> map)
	{
		this.addUsers(map.get("addList"));
		this.updUsers(map.get("updList"));
		this.delUsers(map.get("delList"));
		return true;
	}
	
	public List<Users> findAllUserList(Map<String, Object> map,PageUtil pageUtil)
	{
		String hql="from Users u where u.status='A' ";
		hql+=Constants.getSearchConditionsHQL("u", map);
		hql+=Constants.getGradeSearchConditionsHQL("u", pageUtil);
		List<Users> list = publicDao.find(hql, map, pageUtil.getPage(), pageUtil.getRows());
		for (Users users : list)
		{
			users.setUserRoles(null);
		}
		return list;
	}
	
	public Long getCount(Map<String, Object> map,PageUtil pageUtil)
	{
		String hql="select count(*) from Users  u where u.status='A' ";
		hql+=Constants.getSearchConditionsHQL("u", map);
		hql+=Constants.getGradeSearchConditionsHQL("u", pageUtil);
		return publicDao.count(hql, map);
	}
	
	private boolean addUsers(List<Users> addList)
	{
		if (addList!=null&&addList.size()!=0)
		{
			Users user = this.getUser();
			for (Users users : addList)
			{
				users.setCreated(new Date());
				users.setLastmod(new Date());
				users.setLastVisits(new Date());
				users.setCreater(user.getUserId());
				users.setModifyer(user.getUserId()+"");
				users.setStatus(Constants.PERSISTENCE_STATUS);
				publicDao.save(users);
			}
		}
		return true;
	}
	
	private boolean updUsers(List<Users> updList)
	{	
		if (updList!=null&&updList.size()!=0)
		{
			ShiroUser user = Constants.getCurrendUser();
			for (Users users : updList)
			{
				users.setLastmod(new Date());
				users.setModifyer(user.getUserId()+"");
				publicDao.update(users);
			}
		}
		return true;
	}
	
	private boolean delUsers(List<Users> delList)
	{
		ShiroUser user = Constants.getCurrendUser();
		if (delList!=null&&delList.size()!=0)
		{
			for (Users users : delList)
			{
				users.setLastmod(new Date());
				users.setStatus(Constants.PERSISTENCE_DELETE_STATUS);
				users.setModifyer(user.getUserId()+"");
				publicDao.update(users);
			}
		}
		return true;
	}
	
	public boolean delUsers(Integer userId)
	{
		Users users = (Users) publicDao.get(Users.class, userId);
		users.setStatus(Constants.PERSISTENCE_DELETE_STATUS);
		users.setLastmod(new Date());
		users.setModifyer(Constants.getCurrendUser().getUserId()+"");
		publicDao.deleteToUpdate(users);
		return true;
	}
	
	public List<UserRoleModel> findUsersRolesList(Integer myid)
	{
		String sql="SELECT ur.USER_ID,ur.ROLE_ID FROM\n" +
				"sys_USER_ROLE  ur where ur.STATUS ='A' and ur.USER_ID="+myid;
		List list = publicDaoSQL.findBySQL(sql);
		List<UserRoleModel> listm = getUserRoleModelList(myid, list);
		return listm;
	}
	
	private List<UserRoleModel> getUserRoleModelList(Integer userId, List list )
	{
		List<UserRoleModel> listm=new ArrayList<UserRoleModel>();
		for (Object object : list)
		{
			Object[] obj=(Object[])object;
			UserRoleModel userRoleModel=new UserRoleModel();
			userRoleModel.setUserId(userId);
			userRoleModel.setRoleId(obj[1]==null?null:Integer.valueOf(obj[1].toString()));
			listm.add(userRoleModel);
		}
		return listm;
	}
	
	@SuppressWarnings("unchecked")
	public boolean saveUserRoles(Integer myid,String isCheckedIds)
	{ 
		Users user = (Users) publicDao.get(Users.class, myid);
		Set<SysUserRole> set = user.getUserRoles();
		Map<Integer, SysUserRole> map=new HashMap<Integer, SysUserRole>(); 
		for (SysUserRole userRole : set)
		{
			map.put(userRole.getRole().getRoleId(), userRole);
			userRole.setLastmod(new Date());
			userRole.setStatus(Constants.PERSISTENCE_DELETE_STATUS);
			publicDaoSQL.deleteToUpdate(userRole);
		}
		if (!"".equals(isCheckedIds)&&isCheckedIds.length()!=0)
		{
			String[] ids=isCheckedIds.split(",");
			ShiroUser currUser = Constants.getCurrendUser();
			for (String id : ids)
			{
			    Integer tempId = Integer.valueOf(id);
				SysRole role = (SysRole)publicDaoSQL.get(SysRole.class, Integer.valueOf(id));
				SysUserRole userRole=null;
				if (map.containsKey(tempId))
				{
					userRole=map.get(tempId);
					userRole.setStatus(Constants.PERSISTENCE_STATUS);
					userRole.setCreater(currUser.getUserId());
					userRole.setModifyer(currUser.getUserId());
					publicDaoSQL.update(userRole);
				}else {
					userRole=new SysUserRole();
					userRole.setCreated(new Date());
					userRole.setLastmod(new Date());
					userRole.setRole(role);
					userRole.setUsers(user);
					userRole.setCreater(currUser.getUserId());
					userRole.setModifyer(currUser.getUserId());
					userRole.setStatus(Constants.PERSISTENCE_STATUS);
					publicDaoSQL.save(userRole);
				}
			}
		}
		return true;
	}
	@Override
	public List<SysOrgan> findAllUserList() throws CommonException {
		return (List<SysOrgan>)publicDaoSQL.find("from SysOrgan where 1=1");
	}
	@Override
	public void saveundopwderr(String userId) {
		publicDaoSQL.doSql("update sys_users set login_count = '0' where user_id ='"+userId+"'");
	}
	/**
	 * @return the loginService
	 */
	public LoginService getLoginService() {
		return loginService;
	}
	/**
	 * @param loginService the loginService to set
	 */
	public void setLoginService(LoginService loginService) {
		this.loginService = loginService;
	}
	@SuppressWarnings("unchecked")
	@Override
	public void saveChangePwd(Users curUser, String oldPwd, String newPwd, SysActionLog log) {
		try {
			if (curUser == null) {
				throw new CommonException("柜员为空！");
			} else if (Tools.processNull(oldPwd).equals("")) {
				throw new CommonException("旧密码为空！");
			} else if (Tools.processNull(newPwd).equals("")) {
				throw new CommonException("新密码为空！");
			}
			
			log.setDealCode(DealCode.USER_PWD_CHG);
			log.setMessage("柜员[" + curUser.getUserId() + "]密码修改");
			publicDao.save(log);
			
			//
			Users user = (Users) findOnlyRowByHql("from Users where userId = '" + curUser.getUserId() + "'");
			if (user == null) {
				throw new CommonException("柜员【" + curUser.getUserId() + "】不存在！");
			}
			
			String encryptOldPwd = this.encrypt_des(oldPwd,Constants.APP_DES3_DEFAULT);
			if (!encryptOldPwd.equals(user.getPassword())) {
				throw new CommonException("旧密码不一致！");
			}
			
			user.setPassword(this.encrypt_des(newPwd,Constants.APP_DES3_DEFAULT));
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
}
