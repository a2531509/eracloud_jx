package com.erp.action;

import java.net.URLDecoder;
import java.util.List;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseCoOrg;
import com.erp.model.MerchantSafecode;
import com.erp.model.TrServRec;
import com.erp.service.CooperationAgencyService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**----------------------------------------------------*
*@category                                             *
*合作机构管理                                                                                                      *
*合作机构入网登记，合作机构信息审批，合作机构信息变更，                  *
*合作机构资格暂停                                                                                              *
*合作机构资格启用 ，合作机构退网登记                                                         *
*@author yangn                                         *  
*@date 2015-08-20                                      *
*@email yn_yangning@foxmail.com                        *
*@version 1.0                                          *
*------------------------------------------------------*/
@Namespace(value="/cooperationAgencyManager")
@Action(value="cooperationAgencyAction")
@Results({
	@Result(name="toAddOrEditIndex",location="/jsp/agentorg/cooperationagencyEditDlg.jsp"),
	@Result(name="accTypeEdit",location="/jsp/accManage/acctypeedit.jsp")
})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class CooperationAgencyAction extends BaseAction {
	private static final long serialVersionUID = 1L;
	public Logger log = Logger.getLogger(CooperationAgencyAction.class);
	@Resource(name="cooperationAgencyService")
	private CooperationAgencyService cooperationAgencyService;
	private TrServRec rec = new TrServRec();
	private BaseCoOrg co = new BaseCoOrg();
	private String queryType = "1";//查询类型 0 执行查询 1 不执行查询
	private String sort;//排序列名
	private String order;//升序、降序
	private String topCoOrgName;
	private String defaultErrorMasg;
	private String initCorpType;//1:表示电信和翼支付对账  2：表示新的合作机构对账
	private String safeCode;//安全码
	private String ipAddress;
	private String portAddress;
	private MerchantSafecode ms = new MerchantSafecode();
	
	/**
	 * 合作机构信息查询
	 * @return
	 */
	public String toFindAllCooperAgencyMsg(){
		System.out.println("======"+co.getStlType());
		try{
			initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();//,t.org_id
				sb.append("select t.customer_id,t.co_org_id,t.co_org_name,");
				sb.append("t.co_org_type,t.top_co_org_id,t.check_type,t.indus_code,t.address,t.co_abbr_name,t.hotline,");
				sb.append("(case when t.top_co_org_id is not null then (select c.co_org_name from base_co_org c where c.co_org_id = t.top_co_org_id) else '--------' end) top_org_name,");
				sb.append("t.contact,t.con_phone,to_char(t.sign_date,'yyyy-mm-dd hh24:mi:ss') sign_date ,t.sign_user_id,t.co_state,t.stl_type,");
				sb.append("t.note,c.org_id,c.org_name from BASE_CO_ORG t ,sys_organ c where t.org_id = c.org_id(+)");
				if(!Tools.processNull(co.getCoOrgId()).equals("")){
					sb.append("and t.co_org_id = '" + co.getCoOrgId() + "' ");
				}
				if(!Tools.processNull(co.getCoOrgName()).equals("")){
					sb.append("and t.co_org_name = '" + URLDecoder.decode(co.getCoOrgName(),"UTF-8") + "' ");
				}
				if(!Tools.processNull(co.getIndusCode()).equals("")){
					sb.append("and t.indus_code = '" + co.getIndusCode() + "' ");
				}
				if(!Tools.processNull(co.getCheckType()).equals("")){
					sb.append("and t.check_type = '" + co.getCheckType() + "' ");
				}
				if(!Tools.processNull(co.getStlType()).equals("")){
					sb.append("and t.stl_type = '" + co.getStlType() + "' ");
				}
				if(!Tools.processNull(co.getCoOrgType()).equals("")){
					sb.append("and t.co_org_type = '" + co.getCoOrgType() + "' ");
				}
				if(!Tools.processNull(co.getCoState()).equals("")){
					sb.append("and t.co_state = '" + co.getCoState() + "' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("order by t.customer_id asc");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("未查询到相应的合作机构信息");
				}
			}
		}catch(Exception e){
			log.error(e);
			this.jsonObject.put("status","1");
			this.jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 到达合作机构新增或是编辑页面
	 * @return
	 */
	public String toAddOrEditIndex(){
		try{
			if(Tools.processNull(this.queryType).equals("1")){
				co = (BaseCoOrg) baseService.findOnlyRowByHql("from BaseCoOrg t where t.customerId = " + co.getCoOrgId());
				if(!Tools.processNull(co.getTopCoOrgId()).equals("")){
					this.topCoOrgName = (String) baseService.findOnlyFieldBySql("select t.co_org_name from base_co_org t where t.co_org_id = '" + co.getTopCoOrgId() + "'");
				}
				ms = (MerchantSafecode)baseService.findOnlyRowByHql("from MerchantSafecode t where t.merchantId =" + co.getCoOrgId());
				if(ms != null){
					safeCode = "01";
				}
			}
		}catch(Exception e){
			this.defaultErrorMasg = e.getMessage();
		}
		return "toAddOrEditIndex";
	}
	/**
	 * 新增或是编辑保存
	 * @return
	 */
	public String saveOrUpdateBaseCoOrg(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			if(this.safeCode.equals("02")){
				cooperationAgencyService.saveOrUpdateBaseCoOrg(co,baseService.getUser(),baseService.getCurrentActionLog(),this.queryType,this.safeCode);
				jsonObject.put("status","0");
				jsonObject.put("msg",(Tools.processNull(this.queryType).equals("0") ? "新增" : "编辑") + "合作机构成功！");
			}else{
				cooperationAgencyService.saveOrUpdateBaseCoOrg(co,baseService.getUser(),baseService.getCurrentActionLog(),this.queryType,this.safeCode,this.ipAddress,this.portAddress);
				jsonObject.put("status","0");
				jsonObject.put("msg",(Tools.processNull(this.queryType).equals("0") ? "新增" : "编辑") + "合作机构成功！");
			}
			
		}catch(Exception e){
			jsonObject.put("msg",(Tools.processNull(this.queryType).equals("0") ? "新增" : "编辑") + "发生错误：" + e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 合作机构状态管理
	 * @return
	 */
	public String coOrgStateManager(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			cooperationAgencyService.saveDealBaseCoOrg(co.getCustomerId(),baseService.getUser(),baseService.getCurrentActionLog(),this.queryType);
			jsonObject.put("status","0");
			String string = "";
			if(Tools.processNull(queryType).equals("0")){
				string = "审核";
			}else if(Tools.processNull(queryType).equals("1")){
				string = "注销";
			}else if(Tools.processNull(queryType).equals("3")){
				string = "启用";
			}else if(Tools.processNull(queryType).equals("9")){
				string = "审核";
			}else{
			}
			//rec = cooperationAgencyService.saveDealBaseCoOrg(co.getCustomerId(),baseService.getUser(),baseService.getCurrentActionLog(),this.queryType);
			jsonObject.put("status","0");
			jsonObject.put("msg",string + "合作机构成功！");
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
	/**
	 * 自动完成
	 * @return
	 */
	@SuppressWarnings("rawtypes")
	public String initAutoComplete(){
		JSONArray array = new JSONArray();
		try{
			String where = "";
			if(Tools.processNull(this.queryType).equals("0")){
				where = "t.co_org_name like '%" + co.getCoOrgName() + "%'";
			}else{
				where = "t.co_org_id like '%" + co.getCoOrgId() + "%'";
			}
			if(!Tools.processNull(co.getCustomerId()).equals("")){
				where += " and t.customer_id <> " + co.getCustomerId();
			}
			if(Tools.processNull(initCorpType).equals("1")){
				where += " and t.co_org_id in (" + Constants.CORG_CHECK_OLD_ID + ")";
			}else if(Tools.processNull(initCorpType).equals("2")){
				where += " and t.co_org_id not in (" + Constants.CORG_CHECK_OLD_ID + ")";
			}
			
			List all = baseService.findBySql("select t.co_org_id,t.co_org_name from base_co_org t where " + where );
			for(Object row:all){
				Object[] temponerow = (Object[]) row;
				JSONObject o = new JSONObject();
				o.put("label",temponerow[0].toString());
				o.put("text",temponerow[1].toString());
				array.add(o);
			}
		}catch(Exception e){
			log.error(e);
		}
		jsonObject.put("rows",array);
		return this.JSONOBJ;
	}
	public String getQueryType() {
		return queryType;
	}
	public void setQueryType(String queryType) {
		this.queryType = queryType;
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
	public Logger getLog() {
		return log;
	}
	public void setLog(Logger log) {
		this.log = log;
	}
	public BaseCoOrg getCo() {
		return co;
	}
	public void setCo(BaseCoOrg co) {
		this.co = co;
	}
	public String getDefaultErrorMasg() {
		return defaultErrorMasg;
	}
	public void setDefaultErrorMasg(String defaultErrorMasg) {
		this.defaultErrorMasg = defaultErrorMasg;
	}
	public CooperationAgencyService getCooperationAgencyService() {
		return cooperationAgencyService;
	}
	public void setCooperationAgencyService(CooperationAgencyService cooperationAgencyService) {
		this.cooperationAgencyService = cooperationAgencyService;
	}
	public TrServRec getRec() {
		return rec;
	}
	public void setRec(TrServRec rec) {
		this.rec = rec;
	}

	public String getTopCoOrgName() {
		return topCoOrgName;
	}

	public void setTopCoOrgName(String topCoOrgName) {
		this.topCoOrgName = topCoOrgName;
	}

	public String getInitCorpType() {
		return initCorpType;
	}

	public void setInitCorpType(String initCorpType) {
		this.initCorpType = initCorpType;
	}

	public String getSafeCode() {
		return safeCode;
	}

	public void setSafeCode(String safeCode) {
		this.safeCode = safeCode;
	}

	public String getIpAddress() {
		return ipAddress;
	}

	public void setIpAddress(String ipAddress) {
		this.ipAddress = ipAddress;
	}

	public String getPortAddress() {
		return portAddress;
	}

	public void setPortAddress(String portAddress) {
		this.portAddress = portAddress;
	}

	public MerchantSafecode getMs() {
		return ms;
	}

	public void setMs(MerchantSafecode ms) {
		this.ms = ms;
	}
	
	
}
