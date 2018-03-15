package com.erp.action;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import com.erp.model.SysActionLog;
import com.erp.model.SysOrgan;
import com.erp.service.SysOrgService;
import com.erp.util.Constants;
import com.erp.util.ToolSQLTRANSBEAN;
import com.erp.util.Tools;
import com.erp.util.DealCode;
import com.erp.viewModel.GridModel;
import com.erp.viewModel.Json;
import com.erp.viewModel.OrgAndOrgView;
import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ModelDriven;

@Namespace("/sysOrgan")
@Action(value = "sysOrganAction")
public class SysOrgAction extends BaseAction implements ModelDriven<SysOrgan>{
	
	private SysOrgan sysOrg;
	
	private String queryType = "1";//查询类型 1 不进行查询,直接返回;0 进行查询,返回查询结果。
	
	private String sort="";
	private String order="";
	
	private SysOrgService sysOrgService;
	
	private String orgType="";//机构类型
	
	private String orgId="";//机构号
	
	private String orgName="";//机构名称
	
	private String accNo="";//账号

	
	public String findAllOrgan(){
		try {
			List<SysOrgan> orgs = (List<SysOrgan>)sysOrgService.findByHql("from SysOrgan where orgState ='0'");
			OutputJson(orgs);
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return null;
	}

	public String findAllSysOrgan(){
		try {
			String noworgId = (String)ServletActionContext.getRequest().getAttribute("orgId");
			String noworgName = (String)ServletActionContext.getRequest().getAttribute("orgName");
			Map<String, Object> map = new HashMap<String, Object>();
			if(null != noworgId && !"".equals(noworgId)){
				map.put("orgId", noworgId);
			}
			if(null != noworgName && !"".equals(noworgName)){
				map.put("orgName", noworgName);
			}
			if (null != sort && !"".equals(sort)) {
				map.put("sortName", sort);
			}
			if (null != order && !"".equals(order)) {
				map.put("orderBy", order);
			}
			GridModel gridModel = new GridModel();
			gridModel.setRows(sysOrgService.findOrganList(map));
			OutputJson(gridModel);
		} catch (Exception e) {
			e.printStackTrace();
			this.saveErrLog(e);
			Json json =new Json();
			json.setStatus(false);
			json.setTitle("出错了！");
			json.setMessage("错误信息："+e.getMessage());
			OutputJson(json, Constants.TEXT_TYPE_PLAIN);
		}
		return null;
	}
	
	public String findItemInfo(){
		GridModel model = new GridModel();
		try{
			//1.组装查询语句
			String hql = "from AccItem where 1=1 ";
			//2.查询结果
			List<?> o = new ArrayList();
			o = sysOrgService.findByHql(hql);
			OutputJson(o);
			//3.封装查询结果
		}catch(Exception e){
			model.setStatus(1);
			model.setErrMsg(e.getMessage());
			OutputJson(model);
		}
		
		return null;
	}
	
	public String findOrgAndAccInfo(){
		GridModel model = new GridModel();
		try{
			//1.组装查询语句
			String head = "select c.item_Id,(select item_name from acc_item a where a.item_id = c.item_id) item_Name,c.acc_No,c.acc_name ,c.ACC_STATE ";
			String sql = "from Sys_Organ t, Acc_Account_Sub c where t.client_Id = c.customer_Id ";
			if(!Tools.processNull(this.orgType).equals("")){
				sql += " and t.org_Type = '" + this.orgType + "'";
			}
			if(!Tools.processNull(this.orgId).equals("")){
				sql += " and t.org_Id = '" + this.orgId + "'";
			}
			if(!Tools.processNull(this.orgName).equals("")){
				sql += " and t.org_Name = '" + this.orgName + "'";
			}
			if(!Tools.processNull(this.accNo).equals("")){
				sql += " and c.acc_No = '" + this.accNo + "'";
			}
			//2.查询结果
			List<?> o = new ArrayList();
			if(Tools.processNull(this.queryType).equals("0")){
				o = sysOrgService.findBySql(head + sql);
			}
			List<OrgAndOrgView> orgAndOrgViews = new ArrayList();
			//3.封装查询结果
			if(o != null && o.size() > 0){
				orgAndOrgViews =ToolSQLTRANSBEAN.toListBySqlResultSet(OrgAndOrgView.class,o,"itemId,itemName,accNo,accName,accState");
			}
			model.setRows(orgAndOrgViews);
		}catch(Exception e){
			model.setStatus(1);
			model.setErrMsg(e.getMessage());
		}
		OutputJson(model);
		return null;
	}
	
	/**
	 * 机构账户开户保存
	 */
	public String openOrgAcc() {
		try {
			SysActionLog action_Log = baseService.getCurrentActionLog();
			action_Log.setDealCode(DealCode.ORG_OPEN_ACC);
			action_Log.setBrchId(sysOrgService.getSysBranchByUserId().getBrchId());
			action_Log.setMessage(sysOrgService.findTrCodeNameByCodeType(action_Log.getDealCode()));
			//开户
			orgId = (String)ServletActionContext.getRequest().getAttribute("orgId");
			sysOrgService.saveOpenOrgAcc((List<SysOrgan>)sysOrgService.findByHql("from SysOrgan  where orgId='"+orgId+"'"),action_Log);
			Json json =new Json();
			json.setStatus(true);
			json.setTitle("提示信息");
			json.setMessage("开户成功");
			OutputJson(json, Constants.TEXT_TYPE_PLAIN);
		}catch (Exception e) {
			this.saveErrLog(e);
			Json json =new Json();
			json.setStatus(false);
			json.setTitle("提示信息");
			json.setMessage("错误信息："+e.getMessage());
			OutputJson(json, Constants.TEXT_TYPE_PLAIN);
		}
		return SUCCESS;
	}
	
	/**
	 * 机构注销
	 */
	public String zxOrgan(){
		Json json = new Json();
		try{
			SysActionLog action_Log = baseService.getCurrentActionLog();
			action_Log.setDealCode(DealCode.ORG_DEL);
			action_Log.setMessage(sysOrgService.findTrCodeNameByCodeType(action_Log.getDealCode()));
			orgId = (String)ServletActionContext.getRequest().getAttribute("orgId");
			sysOrgService.savezxSys_OrganByOrgan(action_Log,orgId);
			json.setTitle("注销信息");
			json.setMessage("注销成功！");
			json.setStatus(true);
		}catch(Exception e){
			this.saveErrLog(e);
			json.setTitle("注销信息");
			json.setMessage("注销失败！"+e.getMessage());
			json.setStatus(false);
		}
		OutputJson(json);
		return null;
	}
	
	public String findAllSysOrganTree(){
		OutputJson(sysOrgService.findAllSysOrgan());
		return null;
	}
	
	public String persistenceSysOrgan(){
		OutputJson(getMessage(sysOrgService.persistenceSysOrgan(getModel())), Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	
	
	
	@Autowired
	public void setSysOrgService(SysOrgService sysOrgService )
	{
		this.sysOrgService = sysOrgService;
	}
	
	public String getSort() {
		return sort;
	}

	public void setSort(String sort) {
		this.sort = sort;
	}

	public String getOrder() {
		return order;
	}

	public void setOrder(String order) {
		this.order = order;
	}

	public SysOrgan getSysOrg() {
		return sysOrg;
	}

	public void setSysOrg(SysOrgan sysOrg) {
		this.sysOrg = sysOrg;
	}

	public SysOrgan getModel() {
		if (null==sysOrg)
		{
			sysOrg=new SysOrgan();
		}
		return sysOrg;
	}

	public String getOrgType() {
		return orgType;
	}

	public void setOrgType(String orgType) {
		this.orgType = orgType;
	}

	public String getOrgId() {
		return orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}

	public String getOrgName() {
		return orgName;
	}

	public void setOrgName(String orgName) {
		this.orgName = orgName;
	}

	public String getAccNo() {
		return accNo;
	}

	public void setAccNo(String accNo) {
		this.accNo = accNo;
	}
	
	
}
