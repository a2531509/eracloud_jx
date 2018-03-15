package com.erp.action;

import java.io.PrintWriter;
import java.math.BigDecimal;
import java.util.List;

import javax.annotation.Resource;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.AccKindConfig;
import com.erp.model.PointsRule;
import com.erp.service.PointManageService;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

@Namespace("/pointManage")
@Action(value = "pointManageAction")
@InterceptorRefs({@InterceptorRef("jsondefalut")})
@Results({
	@Result(name="pointParaEdit",location="/jsp/pointManger/pointParaEdit.jsp")
	})
public class PointManageAction extends BaseAction {
	
	@Resource(name="pointManageService")
	private PointManageService pointManageService;
	private String queryType = "1";//默认不进行查询
	private String pointState;
	private String dealCode;
	private String pointType;
	private String sort;
	private String order;
	private PointsRule pointpara;
	private String pointId ="";
	private String defaultErrorMsg;
	private String checkeIds;
	private String certNo;
	private String cardNo;
	private String beginTime;
	private String endTime;
	
	
	public String pointParaQuery(){
		try{
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT t1.id ID,t1.deal_code DEAL_CODE,t2.deal_code_name DEAL_CODE_NAME,t1.point_type POINT_TYPE,");
				sb.append("t1.point_gd_value POINT_GD_VALUE,t1.point_bl_value POINT_BL_VALUE,t1.point_max_value POINT_MAX_VALUE,");
				sb.append("t1.state STATE,(SELECT t3.name FROM Sys_Users t3 WHERE t3.user_id = t1.insert_user) USER_ID,t1.INSERT_DATE ");
				sb.append("INSERT_DATE  FROM points_rule t1 , sys_code_tr t2 WHERE t1.deal_code =  t2.deal_code(+) ");
				if(!Tools.processNull(pointState).trim().equals("")){
					sb.append("and t1.state = '" + pointState + "' ");
				}
				if(!Tools.processNull(dealCode).trim().equals("")){
					sb.append("and t1.deal_code = '" + dealCode + "' ");
				}
				if(!Tools.processNull(pointType).trim().equals("")){
					sb.append("and t1.point_type = '" + pointType + "' ");
				}
				if(Tools.processNull(this.sort).equals("")){
					sb.append("order by t1.INSERT_DATE desc");
				}else{
					sb.append("order by " + this.sort + " " + this.order );
				}
				Page list = baseService.pagingQuery(sb.toString(), page, rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到记录信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 积分参数编辑或是新增界面
	 * @return
	 */
	public String pointParaEdit(){
		try{
			if(Tools.processNull(this.queryType).equals("1")){
				pointpara = (PointsRule) baseService.findOnlyRowByHql("from PointsRule t where t.id = '" + pointId + "'");
				if(pointpara == null){
					throw new CommonException("编辑积分参数出现错误，根据积分编号编号ID=" + pointId + "未找到账户类型！");
				}
			}
		}catch(Exception e){
			defaultErrorMsg = e.getMessage();
		}
		return "pointParaEdit";
	}
	
	/**
	 * 积分参数保存
	 * @return
	 */
	public String pointParaSave(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			if(Tools.processNull(this.queryType).equals("0")){
				BigDecimal count = (BigDecimal)pointManageService.findOnlyFieldBySql("select count(1) from Points_Rule where deal_code='"+pointpara.getDealCode().toString()+"'");
				if(count.intValue()>0){
					throw new CommonException("此交易类型的积分参数已经存在！");
				}
			}
			pointManageService.saveOrUpdatePointPara(pointManageService.getCurrentActionLog(),this.getUsers(),pointpara);
			jsonObject.put("msg",(this.queryType.equals("0") ? "新增积分参数成功！" : "编辑积分参数成功！"));
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 积分激活或注销
	 * @return
	 */
	public String enableOrDisablePointPara(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			String checkStr = Tools.getConcatStrFromArray(checkeIds.split("\\|"), "'", ",");
			if(Tools.processNull(this.queryType).equals("0")){
				pointManageService.saveActivePointPara(pointManageService.getCurrentActionLog(),this.getUsers(),checkStr);
			}
			if(Tools.processNull(this.queryType).equals("1")){
				pointManageService.saveCancelPointPara(pointManageService.getCurrentActionLog(),this.getUsers(),checkStr);
			}
			jsonObject.put("msg",(this.queryType.equals("0") ? "激活积分参数成功！" : "注销积分参数成功！"));
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 删除积分参数
	 * @return
	 */
	public String deletePointPara(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			String checkStr = Tools.getConcatStrFromArray(checkeIds.split("\\|"), "'", ",");
			BigDecimal count = (BigDecimal)pointManageService.findOnlyFieldBySql("select count(1) from Points_Rule where state = '0' and id in("+checkStr+")");
			if(count.intValue()>0){
				throw new CommonException("存在状态为【正常】的积分参数，不可删除，请重新选择！");
			}
			pointManageService.deletePointPara(pointManageService.getCurrentActionLog(),this.getUsers(),checkStr);
			jsonObject.put("msg", "删除积分参数成功！" );
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 查询积分余额
	 * @return
	 */
	public String queryPointBal(){
		try{
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT t1.customer_id CUSTOMER_ID,t1.card_no CARD_NO,t3.name NAME,t3.cert_no CERT_NO,t1.POINTS_SUM ");
				sb.append("POINTS_SUM,t1.points_used POINTS_USED,t1.invalid_date INVALID_DATE,t1.period_id PERIOD_ID");
				sb.append(" from Points_Book t1,acc_account_sub t2, base_personal t3 WHERE t1.customer_id = t2.customer_id ");
				sb.append("AND t1.customer_id = t3.customer_id AND t2.customer_id = t3.customer_id  AND t2.acc_kind = '03' ");
				if(!Tools.processNull(certNo).trim().equals("")){
					sb.append("and t3.cert_no = '" + certNo + "' ");
				}
				if(!Tools.processNull(cardNo).trim().equals("")){
					sb.append("and t1.card_no = '" + cardNo + "' ");
				}
				if(Tools.processNull(this.sort).equals("")){
					sb.append("order by t1.INSERT_time desc");
				}else{
					sb.append("order by " + this.sort + " " + this.order );
				}
				Page list = baseService.pagingQuery(sb.toString(), page, rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到记录信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 查询积分明细
	 * @return
	 */
	public String queryPointDetail(){
		try{
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				//1.条件判断
				StringBuffer head = new StringBuffer();
				head.append("select t.deal_no,t.deal_batch_no,r.deal_code_name deal_code,t.customer_id,t.acc_name,"
						+ "(select s1.code_name from sys_code s1 where s1.code_type = 'SEX' and s1.code_value = b.gender ) gender,"
						+ "(select s2.code_name from sys_code s2 where s2.code_type = 'CERT_TYPE' and s2.code_value = b.cert_type ) cert_type,"
						+ "b.cert_no,"
						+ "(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_TYPE' and s3.code_value = t.card_type ) card_type,"
						+ "t.card_no,t.acc_no,"
						+ "(select s4.code_name from sys_code s4 where s4.code_type = 'ACC_KIND' and s4.code_value = t.acc_kind ) acc_kind,"
						+ "to_char(t.deal_date,'yyyy-mm-dd hh24:mm:ss') deal_Date,trim(to_char(t.card_bal/100,'999,990.99')) card_bal,trim(to_char(t.amt/100,'999,990.99')) amt,t.end_deal_no,t.card_counter,t.rev_time,t.credit,decode(t.deal_state,'0','正常','1','撤销','2','冲正','其他') deal_state,t.insert_time,t.clr_date,t.note ");
				if(Tools.processNull(this.beginTime).equals("")){
					throw new CommonException("查询起始日期不能空！");
				}
				if(!Tools.processNull(this.beginTime).matches("20[0-9]{2}-[0,1]{1}[0-9]{1}-[0,1,2,3]{1}[0-9]{1}")){
					throw new CommonException("查询起始日期格式不正确！正确格式为：YYYY-MM-DD");
				}
				if(Tools.processNull(this.endTime).equals("")){
					throw new CommonException("查询截止日期不能空！");
				}
				if(!Tools.processNull(this.endTime).matches("20[0-9]{2}-[0,1]{1}[0-9]{1}-[0,1,2,3]{1}[0-9]{1}")){
					throw new CommonException("查询截止日期格式不正确！正确格式为：YYYY-MM-DD");
				}
				String table_pre = "PAY_CARD_DEAL_REC_";
				List<String> allTabs = baseService.findBySql("select t.table_name from user_tables t where t.table_name between '" + table_pre + beginTime.substring(0,7).replaceAll("-","") + "' and '" + table_pre + endTime.substring(0,7).replaceAll("-","") + "'");
				if(allTabs == null || allTabs.size() <= 0){
					throw new CommonException("记录信息不存在！");
				}
				StringBuffer initsql = new StringBuffer();
				for (int i = 0; i < allTabs.size(); i++) {
					initsql.append("select * from ");initsql.append(allTabs.get(i));initsql.append(" union ");
				}
				StringBuffer finalsql = new StringBuffer();
				finalsql.append(head);
				finalsql.append("from (");
				finalsql.append(initsql.substring(0,initsql.length() - 6));
				finalsql.append(") t ,base_personal b , sys_code_tr r where t.customer_id = b.customer_id(+) and t.deal_code = r.deal_code  and t.acc_kind = '03' ");
				if(!Tools.processNull(this.cardNo).equals("")){
					finalsql.append(" and t.card_no = '" + this.cardNo + "' ");
				}
				
				//2.排序
				if(Tools.processNull(this.sort).equals("")){
					finalsql.append(" order by t.card_no desc , t.card_counter desc ");
				}else{
					finalsql.append(" order by t.card_no desc , " + this.sort + " " + this.order);
				}
				Page list = baseService.pagingQuery(finalsql.toString(),page,rows);
				if(list.getAllRs() == null || list.getAllRs().size() < 0){
					throw new CommonException("未查询到记录信息");
				}
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
		
	}
	
	//+++++++++++++++++++++++++++++++++++++++++++账户状态和交易码关联++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public String findAllDealCode(){
		try{
			JSONArray j = new JSONArray();
			JSONObject de = new JSONObject();
			de.put("DEAL_CODE","");
			de.put("DEAL_CODE_NAME","请选择");
			j.add(de);
			Page l = baseService.pagingQuery("select t.deal_code,t.deal_code_name || '[' || t.deal_code ||  ']' deal_code_name from sys_code_tr t where t.deal_code < 40300000 and t.deal_code >40100000",1,50000);
			if(l.getAllRs() != null && l.getAllRs().size() > 0){
				j.addAll(l.getAllRs());
			}
			PrintWriter p = this.response.getWriter();
			p.write(j.toString());
			p.flush();
			p.close();
		}catch(Exception e){
			
		}
		return this.JSONOBJ;
	}
	
	//初始化表格
	private void initGrid() throws Exception{
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg","");
	}
	public String getQueryType() {
		return queryType;
	}
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	public String getPointState() {
		return pointState;
	}
	public void setPointState(String pointState) {
		this.pointState = pointState;
	}
	public String getDealCode() {
		return dealCode;
	}
	public void setDealCode(String dealCode) {
		this.dealCode = dealCode;
	}
	public String getPointType() {
		return pointType;
	}
	public void setPointType(String pointType) {
		this.pointType = pointType;
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

	public PointsRule getPointpara() {
		return pointpara;
	}

	public void setPointpara(PointsRule pointpara) {
		this.pointpara = pointpara;
	}


	public String getPointId() {
		return pointId;
	}

	public void setPointId(String pointId) {
		this.pointId = pointId;
	}

	public String getDefaultErrorMsg() {
		return defaultErrorMsg;
	}

	public void setDefaultErrorMsg(String defaultErrorMsg) {
		this.defaultErrorMsg = defaultErrorMsg;
	}

	public String getCheckeIds() {
		return checkeIds;
	}

	public void setCheckeIds(String checkeIds) {
		this.checkeIds = checkeIds;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getBeginTime() {
		return beginTime;
	}

	public void setBeginTime(String beginTime) {
		this.beginTime = beginTime;
	}

	public String getEndTime() {
		return endTime;
	}

	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}
    
}
