package com.erp.action;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.erp.model.AccItem;
import com.erp.model.SysActionLog;
import com.erp.service.SysParamService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.util.DealCode;
import com.erp.viewModel.Json;
import com.erp.viewModel.Page;
/**
 * 类功能说明 TODO: 科目维护action
 * 类修改者
 * 修改日期
 * 修改说明
 * <p>Title: FunctionAction.java</p>
 * <p>Description:杰斯科技</p>
 * <p>Copyright: Copyright (c) 2006</p>
 * <p>Company:杰斯科技有限公司</p>
 * @author hujc 631410114@qq.com
 * @date 2013-5-9 下午1:50:56
 * @version V1.0
 */
@Namespace("/paraManage")
@Action(value = "itemManageAction")
@Results({@Result(type="json",name="json"),
	@Result(name="toViewItem",location="/jsp/paraManage/itemEditMain.jsp")})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class ItemManageAction extends BaseAction{
	
	private AccItem item;
	private String sort="";
	private String order="";
	private String queryType = "1";//查询类型 1 不进行查询,直接返回;0 进行查询,返回查询结果。
	private String item_id;
	private String item_name;
	private SysParamService sysParamService;

	@Autowired
	public void setSysParamService(SysParamService sysParamService )
	{
		this.sysParamService = sysParamService;
	}


	public String findBaiscItemAllList(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		try{//0网点1社区2单位3学校
			if(this.queryType.equals("0")){
				String head="",htj="";
				head = "select a.item_id,a.item_name,a.item_lvl,a.bal_type,"
						+ "(select item_name from acc_item where item_id =a.top_item_id) top_item_no,"
						+ " to_char(a.open_date,'yyyy-mm-dd') open_date ";
				htj = " from acc_item a where a.item_state = '0' ";
				
				if(!Tools.processNull(item_id).equals("")){
					htj+=" and a.item_id = '"+item_id+"'";
				}
				if(!Tools.processNull(item_name).equals("")){
					htj+=" and a.item_name = '"+item_name+"'";
				}
				
				if(Tools.processNull(sort).equals("")){
					htj+=" order by a.item_id ";
				}else{
					htj+=" order by  "+sort+" "+order;
				}
				Page list = sysParamService.pagingQuery(head+htj.toString(),page,rows);
				if(list.getAllRs() != null){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
		
	}
	
	public String toViewItem(){
		try {
			item_name = (String)sysParamService.findOnlyFieldBySql("select item_name from acc_item where item_id='"
					+ item_id+"'");
		} catch (Exception e) {
			e.printStackTrace();
		}
		return "toViewItem";
	}

	public String saveBasicItem(){
		Json json = new Json();
		try {
			SysActionLog log = sysParamService.getCurrentActionLog();
			log.setDealCode(DealCode.ACC_ITEM_EDIT);
			log.setMessage("科目修改名称，客户号为："+item_id);
			sysParamService.saveItem(log, item_id, item_name);
			json.setMessage("修改成功");
			json.setStatus(true);
			json.setTitle("科目编辑");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setMessage("修改失败"+e.getMessage());
			json.setStatus(true);
			json.setTitle("科目编辑");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	public AccItem getItem() {
		return item;
	}

	public void setItem(AccItem item) {
		this.item = item;
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

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}


	public String getItem_id() {
		return item_id;
	}

	public void setItem_id(String item_id) {
		this.item_id = item_id;
	}

	public String getItem_name() {
		return item_name;
	}

	public void setItem_name(String item_name) {
		this.item_name = item_name;
	}

}
