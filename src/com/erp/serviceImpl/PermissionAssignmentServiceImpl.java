package com.erp.serviceImpl;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.dao.PublicDao;
import com.erp.model.SysPermission;
import com.erp.model.SysRole;
import com.erp.model.SysRolePermission;
import com.erp.service.PermissionAssignmentService;
import com.erp.shiro.ShiroUser;
import com.erp.util.Constants;
import com.erp.viewModel.TreeGrid;

/**
 * 类功能说明 TODO:
 * 类修改者
 * 修改日期
 * 修改说明
 * <p>Title: PermissionAssignmentServiceImpl.java</p>
 * <p>Description:杰斯科技</p>
 * <p>Copyright: Copyright (c) 2006</p>
 * <p>Company:杰斯科技有限公司</p>
 * @author hujc 631410114@qq.com
 * @date 2013-5-17 下午2:50:43
 * @version V1.0
 */
@SuppressWarnings("unchecked")
@Service("permissionAssignmentService")
public class PermissionAssignmentServiceImpl implements PermissionAssignmentService
{
	@SuppressWarnings("rawtypes")
	public PublicDao publicDao;
	@SuppressWarnings("rawtypes")
	@Autowired
	public void setPublicDao(PublicDao publicDao )
	{
		this.publicDao = publicDao;
	}

	public SysPermission getFunction(Integer id)
	{
		return (SysPermission)publicDao.get(SysPermission.class, id);
	}
	
	
	public SysRole getRole(Integer roleId)
	{
		return (SysRole)publicDao.get(SysRole.class, roleId);
	}
	public List<TreeGrid> findAllFunctionsList(Integer pid )
	{	
		
		String hql="from SysPermission t where t.status='A' order by t.sort  ";
		List<SysPermission> list = publicDao.find(hql);
		List<TreeGrid> tempList=new ArrayList<TreeGrid>();
		for (SysPermission function : list)
		{
			TreeGrid treeGridModel=new TreeGrid();
			treeGridModel.setId(function.getPermissionId()+"");
			if (function.getPid()!=null)
			{
				treeGridModel.setState("open");
			}
			treeGridModel.setPid(function.getPid()==null?null:function.getPid().toString());
			treeGridModel.setIconCls(function.getIconCls());
			treeGridModel.setName(function.getName());
			treeGridModel.setPath(function.getUrl());
			treeGridModel.setMyid(function.getMyid());
			treeGridModel.setPName(function.getPname());
			treeGridModel.setSort(function.getSort()+"");
			treeGridModel.setIsused(function.getIsused());
			treeGridModel.setType(function.getType());
			treeGridModel.setDescription(function.getDescription());
			tempList.add(treeGridModel);
		}
		return  tempList;
	}
	
	@SuppressWarnings("rawtypes")
	public List<SysPermission> getRolePermission(Integer roleId)
	{
		String sql="SELECT t.PERMISSION_ID FROM sys_ROLE_PERMISSION t WHERE t.STATUS = 'A' and t.ROLE_ID="+roleId;
		List list = publicDao.findBySQL(sql);
		List<SysPermission> list2=new ArrayList<SysPermission>();
		if (list.size()!=0)
		{
			for (Object object : list)
			{
				SysPermission p=new SysPermission();
				p.setPermissionId(Integer.valueOf(object.toString()));
				list2.add(p);
			}
		}
		return list2;
	}
	
	public List<SysRole>  findAllRoleList(Map<String, Object> param,Integer page,Integer rows,boolean isPage) 
	{
		String hql="from SysRole t where t.status='A' ";
		hql+=Constants.getSearchConditionsHQL("t", param);
		List<SysRole> tempList=null;
		if (isPage)
		{
			tempList=publicDao.find(hql, param, page, rows);
		}else {
			tempList=publicDao.find(hql, param);
		}
		for (SysRole role : tempList)
		{
			role.setRolePermissions(null);
			role.setUserRoles(null);
		}
		return tempList;
	}
	
	public Long getCount(Map<String, Object> param)
	{
		String hql="select count(*) from SysRole t where t.status='A' ";
		hql+=Constants.getSearchConditionsHQL("t", param);
		return publicDao.count(hql, param);
	}
	
	public boolean savePermission(Integer roleId,String checkedIds)
	{
		Integer userId = Constants.getCurrendUser().getUserId();
		SysRole role = this.getRole(roleId);
		Map<String, SysRolePermission> map=new HashMap<String, SysRolePermission>();
		Set<SysRolePermission> rolePermissions = role.getRolePermissions();
		for (SysRolePermission rolePermission : rolePermissions)
		{
			Integer permissionId = rolePermission.getPermission().getPermissionId();
			map.put(permissionId.toString(), rolePermission);
			updRolePermission(userId, rolePermission,Constants.PERSISTENCE_DELETE_STATUS);
		}
		if (null!=checkedIds&&!"".equals(checkedIds))
		{
			String[] ids=checkedIds.split(",");
			for (String id : ids)
			{
				SysRolePermission rolePermission = map.get(id);
				if (rolePermission!=null)
				{
					updRolePermission(userId, rolePermission,Constants.PERSISTENCE_STATUS);
				}else {
					SysPermission function = this.getFunction(Integer.valueOf(id));
					Date date=new Date();
					rolePermission=new SysRolePermission();
					rolePermission.setCreated(date);
					rolePermission.setLastmod(date);
					rolePermission.setStatus(Constants.PERSISTENCE_STATUS);
					rolePermission.setCreater(userId);
					rolePermission.setModifyer(userId);
					rolePermission.setPermission(function);
					rolePermission.setRole(role);
					publicDao.save(rolePermission);
				}
			}
		}
		return true;
	}
	
	private void updRolePermission(Integer userId, SysRolePermission rolePermission,String satus)
	{
		rolePermission.setLastmod(new Date());
		rolePermission.setCreater(userId);
		rolePermission.setModifyer(userId);
		rolePermission.setStatus(satus);
		publicDao.update(rolePermission);
	}
	
	public boolean persistenceRole(Map<String, List<SysRole>> map)
	{
		this.addRole(map.get("addList"));
		this.updRole(map.get("updList"));
		this.delRole(map.get("delList"));
		return true;
	}
	
	private boolean addRole(List<SysRole> addList)
	{
		if (addList!=null&&addList.size()!=0)
		{
			ShiroUser users = Constants.getCurrendUser();
			for (SysRole role : addList)
			{
				role.setCreated(new Date());
				role.setLastmod(new Date());
				role.setStatus(Constants.PERSISTENCE_STATUS);
				role.setCreater(users.getUserId());
				role.setModifyer(users.getUserId());
				publicDao.save(role);
			}
		}
		return  true;
	}
	private boolean delRole(List<SysRole> delList){
		if (delList!=null&&delList.size()!=0){
			ShiroUser users = Constants.getCurrendUser();
			for (SysRole role : delList)
			{
				role.setLastmod(new Date());
				role.setModifyer(users.getUserId());
				role.setStatus(Constants.PERSISTENCE_DELETE_STATUS);
				publicDao.deleteToUpdate(role);
			}
		}
		return true;
	}
	
	private boolean updRole(List<SysRole> updList){
		if (updList!=null&&updList.size()!=0){
			ShiroUser users = Constants.getCurrendUser();
			for (SysRole role : updList)
			{
				role.setLastmod(new Date());
				role.setModifyer(users.getUserId());
				publicDao.update(role);
			}
		}
		return true;
	}
	
	/* (非 Javadoc) 
	* <p>Title: persistenceRole</p> 
	* <p>Description: 弹窗持久化角色</p> 
	* @param r
	* @return 
	* @see com.erp.service.PermissionAssignmentService#persistenceRole(com.erp.model.Role) 
	*/
	public boolean persistenceRole(SysRole r ) {
		Integer userId = Constants.getCurrendUser().getUserId();
		if (null==r.getRoleId()||"".equals(r.getRoleId()))
		{
			r.setCreated(new Date());
			r.setLastmod(new Date());
			r.setCreater(userId);
			r.setModifyer(userId);
			r.setStatus(Constants.PERSISTENCE_STATUS);
			publicDao.save(r);
		}else {
			r.setLastmod(new Date());
			r.setModifyer(userId);
			publicDao.update(r);
		}
		
		return true;
	}
	
	public boolean persistenceRole(Integer roleId) {
		Integer userId = Constants.getCurrendUser().getUserId();
		SysRole role = (SysRole)publicDao.get(SysRole.class, roleId);
		role.setLastmod(new Date());
		role.setModifyer(userId);
		role.setStatus(Constants.PERSISTENCE_DELETE_STATUS);
		publicDao.deleteToUpdate(role);
		return true;
	}
	
}
