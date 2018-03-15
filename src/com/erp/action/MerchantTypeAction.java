package com.erp.action;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.BaseMerchantType;
import com.erp.model.SysActionLog;
import com.erp.service.MerchantMangerService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.util.DealCode;
import com.erp.viewModel.GridModel;
import com.erp.viewModel.Json;
import com.erp.viewModel.MerchantView;
import com.erp.viewModel.Page;


@Namespace("/merchantType")
@Action(value = "merchantTypeAction")
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class MerchantTypeAction extends BaseAction {
	
	
	
	private String queryType = "1";//查询类型 1 不进行查询,直接返回;0 进行查询,返回查询结果。
	
	private String typeName="";
	
	private String typeState="";
	
	private String typeId="";
	
	private String id="";
	private BaseMerchantType mtype = new BaseMerchantType();
	
	private MerchantMangerService merchantMangerService;
	
	@Autowired
	public void setMerchantMangerService(MerchantMangerService merchantMangerService) {
		this.merchantMangerService = merchantMangerService;
	}

	public String queryMerType(){
		try{
			this.initDataGrid();
			StringBuffer sb = new StringBuffer();
			sb.append("select t.id,t.type_Name,t.lev,t.ord_No,t.parent_Id,t.type_State,nvl(count(m.customer_id),0) ownMerchants, ");
			sb.append("(select f.type_name from base_merchant_type f where f.id = t.parent_id) parentTypeName ");
			sb.append("from base_merchant_type t,base_merchant m ");
			sb.append("where t.id = m.merchant_type(+) ");
			
			sb.append("group by t.id,t.type_Name,t.lev,t.ord_No,t.parent_Id,t.type_State ");
			if(!Tools.processNull(this.sort).equals("")){
				sb.append(" order by " + this.sort);
				if(!Tools.processNull(this.order).equals("")){
					sb.append(" " + this.order);
				}
			}
			Page list = merchantMangerService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("未找到符合条件的申领信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 构造树对象
	 */
	public String findMerchantTypeListTreeGrid(){
		OutputJson(merchantMangerService.findByHql("from BaseMerchantType where typeState='0' "));
		return null;
	}
	/**
	 * 保存行业名称
	 */
	public String saveMerchantType(){
		Json json = new Json();
		json.setTitle("商户行业类型保存");
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealCode(DealCode.MERCHANTTYPE_SAVE);
			mtype.setTypeState("0");
			merchantMangerService.saveMerType(actionLog, mtype);
			json.setStatus(true);
			json.setMessage("新增成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	/**
	 * 注销行业类型；注销行业类型的
	 * @return
	 * MERCHANTTYPE_SAVE 交易代码
	 * 注销有子行业的行业，子行业也会被注销，即向下级联；
	 * 如果有商户还属于改类型，提示不让其删除
	 */
	
	public String cancelMerType(){
		try {
			// 判断是不是还有商户属于该行业；如果该行业有子行业，也需要循环去判断他的子行业
			BigDecimal mercount = (BigDecimal) merchantMangerService
					.findOnlyFieldBySql("select nvl(count(1),0) from base_merchant where merchant_type='"
							+ typeId + "'");
			if (mercount.intValue() > 0) {
				throw new CommonException("还有商户属于该行业，不能被注销，请先处理商户信息！");
			}
			
		} catch (Exception e) {
			
		}
		return null;
	}
	
	
	
	
	
	public String getTypeName() {
		return typeName;
	}

	public void setTypeName(String typeName) {
		this.typeName = typeName;
	}

	public String getTypeState() {
		return typeState;
	}

	public void setTypeState(String typeState) {
		this.typeState = typeState;
	}

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}

	public String getTypeId() {
		return typeId;
	}

	public void setTypeId(String typeId) {
		this.typeId = typeId;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public BaseMerchantType getMtype() {
		return mtype;
	}

	public void setMtype(BaseMerchantType mtype) {
		this.mtype = mtype;
	}
	/**
	 * 》》初始化表格信息
	 */
	private void initDataGrid(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
	}
	/**
	 * @return the merchantMangerService
	 */
	public MerchantMangerService getMerchantMangerService() {
		return merchantMangerService;
	}
	
}
