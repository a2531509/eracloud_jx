package com.erp.action;

import java.net.URLDecoder;
import java.util.List;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.erp.model.BaseBill;

import com.erp.service.BaseBillService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.viewModel.Json;
import com.erp.viewModel.Page;

@Namespace("/baseBill")
@Action(value = "baseBillAction")
@Results({@Result(type="json",name="json"),
			@Result(name="toAddBaseBill",location="/jsp/baseBill/baseBillAdd.jsp"),
			@Result(name="toEditBaseBill",location="/jsp/baseBill/baseBillAdd.jsp")
			})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class BaseBillAction extends BaseAction {
	private BaseBillService baseBillService;
	private BaseBill baseBill;
	private String billNo;
	private String billName;
	private String billType;
	public String getBillType() {
		return billType;
	}

	public void setBillType(String billType) {
		this.billType = billType;
	}

	public String getBillName() {
		return billName;
	}

	public void setBillName(String billName) {
		this.billName = billName;
	}

	public BaseBill getBaseBill() {
		return baseBill;
	}

	public BaseBillService getBaseBillService() {
		return baseBillService;
	}

	public void setBaseBillService(BaseBillService baseBillService) {
		this.baseBillService = baseBillService;
	}

	public void setBaseBill(BaseBill baseBill) {
		this.baseBill = baseBill;
	}

	public String getBillNo() {
		return billNo;
	}

	public void setBillNo(String billNo) {
		this.billNo = billNo;
	}


	
	/**
	 * 跳转到新增页面
	 * @return
	 */
	public String toAddBaseBill(){
		
		try {
			baseBill = new BaseBill();
		} catch (Exception e) {
		    this.saveErrLog(e);
		}
		return "toAddBaseBill";
	}
	
	/**
	 * 跳转到编辑页面
	 * @return
	 */
	
	public String toEditBaseBill(){
		try {
			
			baseBill = (BaseBill)baseBillService.findOnlyRowByHql("from BaseBill where billNo ='"+this.billNo+"'");
			
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toEditBaseBill";
	}
	/**
	 * 保存新增数据
	 */
	public void saveBaseBill(){
		Json json = new Json();
		try {  
			Object billN= baseBillService.findOnlyRowByHql("from BaseBill where billNo ='"+baseBill.getBillNo()+"'");
               if(!Tools.processNull(billN).equals("")){
            	   baseBillService.updateBaseBill(baseBill);      	            	             	   
               }else{           	             	 
            	   baseBillService.saveBaseBill(baseBill);
               }
			json.setStatus(true);
			json.setTitle("成功提示");
			json.setMessage("票据信息保存成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
	}
	
	
	/**
	 * 查询Bill卡信息
	 */
	public String queryBaseBill(){
		try{
		    clearGrid();
			String sql="select t.bill_no,t.bill_name,(select s.code_name from sys_code s where "
					+ "s.code_type='BILL_TYPE'and s.code_value=t.bill_type) as bill_type,"
					+ "t.start_no,t.end_no,t.bill_num,t.amt_flag,t.bill_amt,t.validity_date,"
					+ "t.note,to_char(t.oper_date,'yyyy-MM-dd hh24:mi:ss') as oper_date,"
					+ "t.oper_id,t.org_id from BASE_BILL t where 1=1";
			if(!Tools.processNull(billName).equals("")){
				sql+="and t.bill_name like'%"+this.billName+"%'";
			}
			if(!Tools.processNull(billType).equals("")){
				sql+="and t.Bill_Type='"+this.billType+"'";
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
	public String deleteBaseBill(){
	   
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			baseBill = (BaseBill)baseBillService.findOnlyRowByHql("from BaseBill where billNo ='"+this.billNo+"'");
			baseBillService.delBaseBill(baseBill);
			jsonObject.put("msg","删除票据信息成功！");
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
