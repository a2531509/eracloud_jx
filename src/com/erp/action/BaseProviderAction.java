package com.erp.action;

import java.net.URLDecoder;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.erp.model.BaseProvider;
import com.erp.model.CardProducts;
import com.erp.service.BaseProviderService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.viewModel.Json;
import com.erp.viewModel.Page;

@Namespace("/BaseProvider")
@Action(value = "baseProviderAction")
@Results({@Result(type="json",name="json"),
			@Result(name="toAddBaseProvider",location="/jsp/baseProvider/baseProviderAdd.jsp"),
			@Result(name="toEditBaseProvider",location="/jsp/baseProvider/baseProviderAdd.jsp")
			})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class BaseProviderAction extends BaseAction{
	private BaseProvider basePro=null;
	private Long providerId; 
	public Long getProviderId() {
		return providerId;
	}

	public void setProviderId(Long providerId) {
		this.providerId = providerId;
	}

	private BaseProviderService baseProviderService;
	private String providerName="";
	private String providerState="";
	private String providerType="";
	public String getProviderState() {
		return providerState;
	}

	public void setProviderState(String providerState) {
		this.providerState = providerState;
	}

	public String getProviderType() {
		return providerType;
	}

	public void setProviderType(String providerType) {
		this.providerType = providerType;
	}

	public String getProviderName() {
		return providerName;
	}

	public void setProviderName(String providerName) {
		this.providerName = providerName;
	}

	
	/**
	 * 跳转到编辑页面
	 * @return
	 */
	
	public String toEditBaseProvider(){
		try {

			basePro = (BaseProvider)baseProviderService.findOnlyRowByHql("from BaseProvider where providerId ='"+this.getProviderId()+"'");
			
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toEditBaseProvider";
	}
	/**
	 * 跳转到新增页面
	 * @return
	 */
	public String toAddBaseProvider(){
		
		try {
			basePro = new BaseProvider();
		} catch (Exception e) {
		    this.saveErrLog(e);
		}
		return "toAddBaseProvider";
	}
	
	public BaseProvider getBasePro() {
		return basePro;
	}

	public void setBasePro(BaseProvider basePro) {
		this.basePro = basePro;
	}

	public BaseProviderService getBaseProviderService() {
		return baseProviderService;
	}

	public void setBaseProviderService(BaseProviderService baseProviderService) {
		this.baseProviderService = baseProviderService;
	}
	/**
	 * 保存供应商信息
	 */

	public void saveBaseProvider(){
		Json json = new Json();
		try {
               if(!Tools.processNull(basePro.getProviderId()).equals("")){
            	   baseProviderService.updateBaseProvider(basePro);
            	            	             	   
               }else{           	  
            	 
            	   baseProviderService.saveBaseProvider(basePro);
               }
			

			json.setStatus(true);
			json.setTitle("成功提示");
			json.setMessage("供应商信息保存成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
	}
	
	/**
	 * 查询供应商信息
	 */
	public String queryBaseProvider(){
		try{
			initGrid();
			String sql="select t.provider_id, t.provider_name,(select s.code_name from sys_code s where "
					+ "s.code_type='PROVIODER_STATE'and s.code_value=t.provider_state) as provider_state,"
					+ "t.provider_contract,(select s.code_name from sys_code s where "
					+ "s.code_type='PROVIODER_TYPE'and s.code_value=t.provider_type) as provider_type,t.provider_address,"
					+ "t.provider_tel_no,t.provider_linkman,t.provider_post,to_char(t.oper_date,'yyyy-MM-dd hh24:mi:ss') as oper_date,"
					+ "t.oper_id from BASE_PROVIDER t where 1=1";
			 if(!Tools.processNull(this.providerName).equals("")){
				 sql+=" and t.provider_name like '%" + URLDecoder.decode(this.providerName,"UTF-8") + "%' ";
				}
			  if(!Tools.processNull(this.providerState).equals("")){
				  sql+=" and t.provider_state = '" + this.providerState + "' ";
				}
			  if(!Tools.processNull(this.providerType).equals("")){
				  sql+="and t.provider_type = '" + this.providerType + "' ";
				}
			 Page p = baseService.pagingQuery(sql.toString(),page,rows);
			 if(p.getAllRs() != null){
					jsonObject.put("rows",p.getAllRs());
					jsonObject.put("total",p.getTotalCount());
			  }
			
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
		
	}
	
	/**
	 * 删除供应商信息
	 * @return
	 */
	public String deleteBaseProvider(){
	   
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			baseProviderService.delBaseProvider(providerId);
			jsonObject.put("msg","删除账户类型成功！");
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
		
	}
	//初始化表格
			private void initGrid() throws Exception{
				jsonObject.put("rows",new JSONArray());//记录行数
				jsonObject.put("total",0);//总条数
				jsonObject.put("status",0);//查询状态
				jsonObject.put("errMsg","");//错误信息
			}


	public BaseProviderAction() {
		// TODO Auto-generated constructor stub
	}

}
