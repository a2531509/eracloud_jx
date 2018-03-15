package com.erp.action;


import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.erp.model.BaseVendor;
import com.erp.service.BaseVendorService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.viewModel.Json;
import com.erp.viewModel.Page;
@Namespace("/baseVendor")
@Action(value = "baseVendorAction")
@Results({@Result(type="json",name="json"),
			@Result(name="toAddBaseVendor",location="/jsp/baseVendor/baseVendorAdd.jsp"),
			@Result(name="toEditBaseVendor",location="/jsp/baseVendor/baseVendorAdd.jsp")
			})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class BaseVendorAction extends BaseAction {
	private BaseVendorService baseVendorService;
	private BaseVendor baseVendor;
	private String vendorId;
	private String vendorName;
	private String makeWay;
	private String state;
	private String queryType;
	public BaseVendorService getBaseVendorService() {
		return baseVendorService;
	}

	public void setBaseVendorService(BaseVendorService baseVendorService) {
		this.baseVendorService = baseVendorService;
	}

	public BaseVendor getBaseVendor() {
		return baseVendor;
	}

	public void setBaseVendor(BaseVendor baseVendor) {
		this.baseVendor = baseVendor;
	}

	public String getVendorId() {
		return vendorId;
	}

	public void setVendorId(String vendorId) {
		this.vendorId = vendorId;
	}
	public String getVendorName() {
		return vendorName;
	}

	public void setVendorName(String vendorName) {
		this.vendorName = vendorName;
	}

	public String getMakeWay() {
		return makeWay;
	}

	public void setMakeWay(String makeWay) {
		this.makeWay = makeWay;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}
	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}


	/**
	 * 跳转到新增页面
	 * @return
	 */
	public String toAddBaseVendor(){
		
		try {
			baseVendor = new BaseVendor();
		} catch (Exception e) {
		    this.saveErrLog(e);
		}
		return "toAddBaseVendor";
	}
	
	/**
	 * 跳转到编辑页面
	 * @return
	 */
	
	public String toEditBaseVendor(){
		try {
			
			baseVendor = (BaseVendor)baseVendorService.findOnlyRowByHql("from BaseVendor where vendorId ='"+this.vendorId+"'");
			
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toEditBaseVendor";
	}
	/**
	 * 保存新增数据
	 */
	public void saveBaseVendor(){
		Json json = new Json();
		try {  
			Object baseVen= baseVendorService.findOnlyRowByHql("from BaseVendor where vendorId ='"+baseVendor.getVendorId()+"'");
               if(!Tools.processNull(baseVen).equals("")){
            	   baseVendorService.updateBaseVendor(baseVendor);      	            	             	   
               }else{           	             	 
            	   baseVendorService.saveBaseVendor(baseVendor);
               }
			json.setStatus(true);
			json.setTitle("成功提示");
			json.setMessage("卡商信息保存成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
	}
	
	
	/**
	 * 查询卡商信息
	 */
	public String queryBaseVendor(){
		try{
		    clearGrid();
			String sql="select t.vendor_id,t.vendor_name,(select s.code_name from sys_code s where "
		    +"s.code_type='VENDOR_MAKE_WAY' and s.code_value=t.make_way) as make_way,"
			+"t.address,t.contact,t.c_tel_no,t.ceo_name,t.ceo_tel_no,t.fax_no,t.email,t.post_code,"
		    +"to_char(t.open_date,'yyyy-MM-dd') as open_date,t.open_user_id,t.cls_user_id,t.cls_date,"
			+"(select s.code_name from sys_code s where s.code_type='STATE' and s.code_value=t.state) "
		    +" as state from BASE_VENDOR t where 1=1";
			if(!Tools.processNull(vendorName).equals("")){
				sql+="and t.vendor_name like'%"+this.vendorName+"%'";
			}
			if(!Tools.processNull(makeWay).equals("")){
				sql+="and t.make_way='"+this.makeWay+"'";
			}
			if(!Tools.processNull(state).equals("")){
				sql+="and t.state='"+this.state+"'";
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
	 * 删除卡商信息
	 * @return
	 */
	public String deleteBaseVendor(){
	   
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			baseVendorService.delBaseVendor(vendorId);
			jsonObject.put("msg","卡商信息删除成功！");
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
		
	}
	
	/**
	 * 注销卡商信息
	 * @return
	 */
	public String cancelBaseVendor(){
	   
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			baseVendor = (BaseVendor)baseVendorService.findOnlyRowByHql("from BaseVendor where vendorId ='"+this.vendorId+"'");
			if(Tools.processNull(this.queryType).equals("1")){
				baseVendorService.cancelBaseVendor(baseVendor);			
			}else if(Tools.processNull(this.queryType).equals("0")){
				baseVendorService.activaBaseVendor(baseVendor);
			}			
			jsonObject.put("msg",(this.queryType.equals("0") ? "激活卡商成功！" : "注销卡商成功！"));
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
		
	}
	
			//初始化表格
			private void clearGrid() throws Exception{
				jsonObject.put("rows",new JSONArray());//记录行数
				jsonObject.put("total",0);//总条数
				jsonObject.put("status",0);//查询状态
				jsonObject.put("errMsg","");//错误信息
			}

}
