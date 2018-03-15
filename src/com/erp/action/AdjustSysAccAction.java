package com.erp.action;


import java.math.BigDecimal;

import javax.annotation.Resource;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.AccAdjustInfo;
import com.erp.model.PayOfflineBlack;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.service.AdjustSysAccService;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.Page;


/**----------------------------------------------------*
*@category                                             *
*系统调账模块action						          	   *
*@author hujc                                          *  
*@date 2015-10-09                                      *
*@email hujc@eracloud.cn	                           *
*@version 1.0                                          *
*------------------------------------------------------*/
@Namespace(value="/adjustSysAccAction")
@Action(value="adjustSysAccAction")
@Results({
	@Result(name="accFreezeAdd",location="/jsp/accManage/accfreezeadd.jsp")
})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class AdjustSysAccAction extends BaseAction {
	
	@Resource(name="adjustSysAccService")
	private AdjustSysAccService adjustSysAccService;
	private PayOfflineBlack pay = new PayOfflineBlack();
	public TrServRec rec = new TrServRec();
	private String queryType = "1";//默认不进行查询
	private String defaultErrorMsg;
	private String sort;
	private String order;
	
	private String recType;//受理点类型
	private String startTime;//开始时间
	private String endTime;//结束时间
	private String orgId;//机构id
	private String branchId;//网点id
	private String userId;//柜员id
	private String coorgId;//合作机构id
	private String coorgName;//合作机构名称
	private String endId;//终端id
	private String dealNo;//业务流水号
	private String dealState;//处理状态
	private String dealCode;
	private String clrDate;//清分日期
	private String acptId;//受理点编号
	private String batchId;//批次号
	private String endDealNo;//终端流水号
	private String cardNo;//卡号
	private String trAmt;//交易金额
	private String adjustType;//调账类型
	private String note;//备注
	
	private String checkIds;//选择ids
	private String cardType;//卡类型
	private String payStartDate = "";//交易起始时间
	private String payEndDate = "";//交易结束时间
	private String selectId;
	/**
	 * 查询调账信息
	 * @return
	 */
	public String queryAdjustInfo(){
		try{
			if(Tools.processNull(this.queryType).equals("0")){
				jsonObject.put("rows",new JSONArray());
				jsonObject.put("status","0");
				jsonObject.put("total",0);
				jsonObject.put("errMsg","");
				StringBuffer sb = new StringBuffer();
				if(recType.equals("1")){
					sb.append("SELECT t1.id ID,t2.org_name ORGN_NAME,t3.full_name BRCH_NAME,t4.name USER_NAME,t1.deal_type DEAL_TYPE,");
				}else{
					sb.append("SELECT t2.co_org_name ORGN_NAME,t3.full_name BRCH_NAME,t4.name USER_NAME,t1.deal_type DEAL_TYPE,");
				}
				sb.append("t1.adjust_type ADJUST_TYPE,t1.acpt_id ACPT_ID,t1.end_id END_ID,t1.batch_id BATCH_ID,");
				sb.append("t1.end_deal_no END_DEAL_NO,t1.card_in_no CARDIN_DEALNO,t1.deal_no DEAL_NO,t1.deal_no DEAL_NO,");
				sb.append("t1.clr_date CLR_DATE,t1.amt AMT,t1.bal_amt BAL_AMT,t1.DEAL_DATE DEAL_DATE,t1.note NOTE ");
				if(recType.equals("1")){
					sb.append("FROM acc_adjust_info t1,Sys_Organ t2,sys_branch t3,Sys_Users t4 WHERE t1.card_org_id = t2.org_id(+) ");
				}else{
					sb.append("FROM acc_adjust_info t1,base_co_org t2,sys_branch t3,Sys_Users t4 WHERE t1.acpt_id = t2.co_org_id(+) ");
				}
				sb.append("AND t1.brch_id = t3.brch_id(+) AND t1.user_id = t4.user_id(+) ");
				
				if(!"".equals(orgId)){
					sb.append("and t1.card_org_id ='"+orgId+"'");
				}
				if(!"".equals(branchId)){
					sb.append("and t1.acpt_id ='"+branchId+"'");
				}
				if(!"".equals(userId)){
					sb.append("and t1.end_id ='"+userId+"'");
				}
				if(!"".equals(endId)){
					sb.append("and t1.end_id ='"+endId+"'");
				}
				if(!"".equals(coorgId)){
					sb.append("and t1.acpt_id ='"+coorgId+"'");
				}
				if(!"".equals(dealNo)){
					sb.append("and t1.dealNo ='"+dealNo+"'");
				}
				if(!"".equals(dealState)){
					sb.append("and t1.DEAL_STATE ='"+dealState+"'");
				}
				
				if(Tools.processNull(this.sort).equals("")){
					sb.append("order by t1.deal_date asc ");
				}else{
					sb.append("order by " + this.sort + " " + this.order);
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("未找到需要处理的调账信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 根据流水号查询交易信息
	 * @return
	 */
	public String queryOldTradeInfo(){
		jsonObject.put("acptId","");
		jsonObject.put("endId","");
		jsonObject.put("batchId","");
		jsonObject.put("endDealNo","");
		jsonObject.put("cardNo","");
		jsonObject.put("trAmt","");
		jsonObject.put("status","0");
		try{
			if(!Tools.processNull(dealNo).equals("")){
				Object[] obj = (Object[])baseService.findOnlyRowBySql("select ACPT_ID,user_id,DEAL_BATCH_NO,END_DEAL_NO,CARD_NO,amt from "
						+ " pay_card_deal_rec_"+clrDate.substring(0, 4)+clrDate.substring(5,7) +" where deal_no = '"+dealNo+"'"
						+ " and clr_Date = '"+clrDate+"'");
				if(obj == null){
					throw new CommonException("查询交易明细出错，不存在该交易明细！");
				}
				jsonObject.put("acptId", obj[0]);
				jsonObject.put("endId", obj[1]);
				jsonObject.put("batchId", obj[2]);
				jsonObject.put("endDealNo", obj[3]);
				jsonObject.put("cardNo", obj[4]);
				jsonObject.put("trAmt", obj[5]);
			    
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			throw  new CommonException("获取交易信息出错！");
		}
		return "jsonObj";
	}
	/**
	 * 保存添加的轧账信息
	 * @return
	 */
	public String toSaveAddOrUpdateAdjustInfo(){
		jsonObject.put("errMsg","");
		jsonObject.put("status","0");
		try {
			AccAdjustInfo adjustinfo = new AccAdjustInfo();
			if("".equals(clrDate)){
				throw new CommonException("请输入调账数据所属的原清分日期");
			}
			//判断该交易是否存在
			if(!"".equals(Tools.processNull(dealNo))){
				Object[] obj = (Object[])baseService.findOnlyRowBySql("select ACPT_ID,user_id,DEAL_BATCH_NO,END_DEAL_NO,CARD_NO,amt from "
						+ " pay_card_deal_rec_"+clrDate.substring(0, 4)+clrDate.substring(5,7) +" where deal_no = '"+dealNo+"'"
						+ " and clr_Date = '"+clrDate+"'");
				if(obj != null){
					adjustinfo.setAcptId(Tools.processNull(obj[0]));
					adjustinfo.setEndId(Tools.processNull(obj[1]));
					adjustinfo.setBatchId(Tools.processNull(obj[2]));
					adjustinfo.setEndDealNo(Tools.processNull(obj[3]));
					adjustinfo.setCardNo(Tools.processNull(obj[4]));
					adjustinfo.setAmt(Tools.processLong(obj[5].toString()));
					adjustinfo.setOldDealNo(Tools.processLong(dealNo));
					adjustinfo.setClrDate(clrDate);
				}else{
					adjustinfo.setAcptId(Tools.processNull(acptId));
					adjustinfo.setEndId(Tools.processNull(endId));
					adjustinfo.setBatchId(Tools.processNull(batchId));
					adjustinfo.setEndDealNo(Tools.processNull(endDealNo));
					adjustinfo.setCardNo(Tools.processNull(cardNo));
					adjustinfo.setAmt(Long.valueOf(Tools.processNull(trAmt)));
					adjustinfo.setOldDealNo(Tools.processLong(dealNo));
				}
				
			}else{
				adjustinfo.setAcptId(Tools.processNull(acptId));
				adjustinfo.setEndId(Tools.processNull(endId));
				adjustinfo.setBatchId(Tools.processNull(batchId));
				adjustinfo.setEndDealNo(Tools.processNull(endDealNo));
				adjustinfo.setCardNo(Tools.processNull(cardNo));
				adjustinfo.setAmt(Long.valueOf(Tools.processNull(trAmt)));
				adjustinfo.setClrDate(clrDate);
			}
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealCode(DealCode.ADD_ADJUST_INFO);
			actionLog.setMessage("添加调账信息");
			actionLog.setOrgId(baseService.getUser().getOrgId());
			adjustSysAccService.saveAddAdjustInfo(adjustinfo, actionLog, baseService.getUser());
		} catch (Exception e) {
			jsonObject.put("errMsg","保存新增调账信息出错："+e.getMessage());
			jsonObject.put("status","1");
		}
		return this.JSONOBJ;
	}
	/**
	 * 审核调账信息
	 * @return
	 */
	public String checkAdjustInfo(){
		jsonObject.put("errMsg","");
		jsonObject.put("status","0");
		try {
			String[] ags = checkIds.split("\\|");
			String inwhere = Tools.getConcatStrFromArray(ags, "'", ",");
			BigDecimal bg = (BigDecimal)baseService.findOnlyFieldBySql("select count(1) from acc_adjust_info where ID in("+inwhere
					+") and DEAL_STATE<> '01'");
			if(bg!=null&&bg.intValue() > 0){
				throw new CommonException("选择的数据含有已审核过的数据，请重新选择！");
			}
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealCode(DealCode.CHCEK_ADJUST_INFO);
			actionLog.setMessage("审核扎帐信息,ids:"+inwhere);
			adjustSysAccService.saveCheckAdjustInfo(inwhere, actionLog, baseService.getUser());
			jsonObject.put("errMsg","审核完成");
		} catch (Exception e) {
			jsonObject.put("errMsg","审核调账信息发生错误："+e.getMessage());
			jsonObject.put("status","1");
		}
		return this.JSONOBJ;
	}
	/**
	 * 删除调账信息
	 * @return
	 */
	public String delAdjustInfo(){
		jsonObject.put("errMsg","");
		jsonObject.put("status","0");
		try {
			String[] ags = checkIds.split("\\|");
			String inwhere = Tools.getConcatStrFromArray(ags, "'", ",");
			BigDecimal bg = (BigDecimal)baseService.findOnlyFieldBySql("select count(1) from acc_adjust_info where ID in("+inwhere
					+") and DEAL_STATE<> '04'");
			if(bg!=null&&bg.intValue() > 0){
				throw new CommonException("选择的数据含有已处理过的数据，请重新选择！");
			}
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealCode(DealCode.DEL_ADJUST_INFO);
			actionLog.setMessage("删除扎帐信息,ids:"+inwhere);
			adjustSysAccService.saveDelAdjustInfo(inwhere, actionLog, baseService.getUser());
			jsonObject.put("errMsg","删除完成");
		} catch (Exception e) {
			jsonObject.put("errMsg","删除调账信息发生错误："+e.getMessage());
			jsonObject.put("status","1");
		}
		return this.JSONOBJ;
	}
	/**
	 * 处理调账信息
	 * @return
	 */
	public String saveAdjustAccInfo(){
		jsonObject.put("errMsg","");
		jsonObject.put("status","0");
		try {
			
			
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("errMsg","处理调账信息发生错误："+e.getMessage());
			jsonObject.put("status","0");
		}
		return this.JSONOBJ;
	}
	/**
	 * 查询电子钱包信息
	 * @return
	 */
	public String queryWalletInfo(){
		this.initBaseDataGrid();
		try {
			if(!Tools.processNull(queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select t.deal_no as SETTLEID,t.acpt_id,t.end_id,t.deal_no,t.card_no,t.acc_bal,t.deal_date,t.refuse_reason,t.clr_date ");
			sb.append(" from pay_offline_black t,card_baseinfo c ");
			sb.append(" where t.card_no=c.card_no  ");
			if(!Tools.processNull(this.cardType).equals("")){
				sb.append(" and c.card_type=" + this.cardType);
			}
			if(!Tools.processNull(pay.getCardNo()).equals("")){
				sb.append(" and t.card_no=" + pay.getCardNo());
			}
			if(!Tools.processNull(pay.getDealNo()).equals("")){
				sb.append(" and t.deal_no=" + pay.getDealNo());
			}
			if(!Tools.processNull(this.payStartDate).equals("")){
				sb.append(" and t.deal_date>='" +this.payStartDate+ "'" );
			}
			if(!Tools.processNull(this.payEndDate).equals("")){
				sb.append(" and t.deal_date<='" +this.payEndDate+ "'");
			}
			if(!Tools.processNull(this.sort).equals("")){
				sb.append(" order by " + this.sort);
				if(!Tools.processNull(this.order).equals("")){
					sb.append(" " + this.order);
				}
			}
			
			Page list = adjustSysAccService.pagingQuery(sb.toString(), page, rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("未找到符合条件的电子钱包信息！");
			}
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 电子钱包数据处理
	 * @return
	 */
	public String processWalletInfo(){
		this.initBaseDataGrid();
		if(Tools.processNull(selectId).equals("")){
			throw new CommonException("至少选择一条记录操作！");
		}
		PayOfflineBlack polb = (PayOfflineBlack) adjustSysAccService.findOnlyRowByHql("from PayOfflineBlack p where p.dealNo = " + selectId);
		if(polb == null){
			throw new CommonException("未找到电子钱包数据信息");
		}
		adjustSysAccService.saveProcessWallet(polb,adjustSysAccService.getCurrentActionLog(),rec);
		return this.JSONOBJ;
	}
	
	/**
	 * 查询交易流水
	 * Description <p>TODO</p>
	 * @return
	 */
	public String dealNoInfoQuery(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		try{
			if(this.queryType.equals("0")){
				if(Tools.processNull(clrDate).equals("")||Tools.processNull(dealNo).equals("")){
					throw new CommonException("清分日期和交易流水号不能为空");
				}
				String table_name = "acc_inout_detail_"+clrDate.replace("-", "").substring(0, 6);
				StringBuffer sb = new StringBuffer();
				sb.append("select t.deal_no dealno,t.user_id USER_ID,t.cr_acc_no accno,(select t1.ACC_NAME from acc_kind_config t1 where t1.acc_kind = t.cr_acc_kind) acckind,");
				sb.append("t.CR_CARD_BAL accbal,t.cr_amt amt,to_char(t.deal_date,'yyyy-mm-dd hh24:mi:ss') dealdate,decode(t.DEAL_STATE,'0','正常','1','撤销',"
						+ "'2','冲正','3','退货','9','灰记录','未知') dealstate,t.clr_date clr_date,t.deal_code dealcode");
				sb.append(" from "+ table_name + " t where  1=1 ");
				sb.append(" and t.clr_date ='"+clrDate+"'");
				sb.append(" and t.deal_No='"+dealNo+"' and t.deal_state = '0'");
				Page list = adjustSysAccService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("查询交易流水发生错误<span style='color:red'>未查询到交易流水</span>");
				}
			}
		}catch(Exception e){
			this.saveErrLog(e);
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String saveDealCancel(){
		jsonObject.put("errMsg","撤销交易流水成功");
		jsonObject.put("status","0");
		try {
			if(Tools.processNull(userId).equals("")){
				userId = "admin";
			}
			String table_name = "acc_inout_detail_"+clrDate.replace("-", "").substring(0, 6);
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealCode(Integer.valueOf(dealCode.substring(0, dealCode.length()-1)+"1"));
			actionLog.setMessage("处理撤销流水");
			String cr_acc_no = (String)adjustSysAccService.findOnlyFieldBySql("select cr_acc_no from "+table_name +" t where 1=1 and t.deal_No='"+dealNo+"'");
			if(Tools.processNull(cr_acc_no).equals("")){
				throw new CommonException("处理撤销流水发生错误");
			}
			String cardNo = (String)adjustSysAccService.findOnlyFieldBySql("select cr_card_no from "+table_name +" t where 1=1 and t.deal_No='"+dealNo+"'");
			String accKind = (String)adjustSysAccService.findOnlyFieldBySql("select cr_acc_kind from "+table_name +" t where 1=1 and t.deal_No='"+dealNo+"'");
			adjustSysAccService.saveDealCancel(actionLog, dealNo,trAmt,cardNo, accKind,clrDate,userId);
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("errMsg","处理撤销流水发生错误"+e.getMessage());
			jsonObject.put("status","1");
		}
		return this.JSONOBJ;
	}
	public String getQueryType() {
		return queryType;
	}
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	public String getDefaultErrorMsg() {
		return defaultErrorMsg;
	}
	public void setDefaultErrorMsg(String defaultErrorMsg) {
		this.defaultErrorMsg = defaultErrorMsg;
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

	public String getRecType() {
		return recType;
	}

	public void setRecType(String recType) {
		this.recType = recType;
	}

	public String getStartTime() {
		return startTime;
	}

	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}

	public String getEndTime() {
		return endTime;
	}

	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}

	public String getOrgId() {
		return orgId;
	}

	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}

	public String getBranchId() {
		return branchId;
	}

	public void setBranchId(String branchId) {
		this.branchId = branchId;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getCoorgId() {
		return coorgId;
	}

	public void setCoorgId(String coorgId) {
		this.coorgId = coorgId;
	}

	public String getCoorgName() {
		return coorgName;
	}

	public void setCoorgName(String coorgName) {
		this.coorgName = coorgName;
	}

	public String getEndId() {
		return endId;
	}

	public void setEndId(String endId) {
		this.endId = endId;
	}

	public String getDealNo() {
		return dealNo;
	}

	public void setDealNo(String dealNo) {
		this.dealNo = dealNo;
	}

	public String getDealState() {
		return dealState;
	}

	public void setDealState(String dealState) {
		this.dealState = dealState;
	}

	public String getClrDate() {
		return clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	public String getAcptId() {
		return acptId;
	}

	public void setAcptId(String acptId) {
		this.acptId = acptId;
	}

	public String getBatchId() {
		return batchId;
	}

	public void setBatchId(String batchId) {
		this.batchId = batchId;
	}

	public String getEndDealNo() {
		return endDealNo;
	}

	public void setEndDealNo(String endDealNo) {
		this.endDealNo = endDealNo;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getTrAmt() {
		return trAmt;
	}

	public void setTrAmt(String trAmt) {
		this.trAmt = trAmt;
	}

	public String getAdjustType() {
		return adjustType;
	}

	public void setAdjustType(String adjustType) {
		this.adjustType = adjustType;
	}

	public String getNote() {
		return note;
	}

	public void setNote(String note) {
		this.note = note;
	}

	public String getCheckIds() {
		return checkIds;
	}

	public void setCheckIds(String checkIds) {
		this.checkIds = checkIds;
	}

	public PayOfflineBlack getPay() {
		return pay;
	}

	public void setPay(PayOfflineBlack pay) {
		this.pay = pay;
	}

	public String getPayStartDate() {
		return payStartDate;
	}

	public void setPayStartDate(String payStartDate) {
		this.payStartDate = payStartDate;
	}

	public String getPayEndDate() {
		return payEndDate;
	}

	public void setPayEndDate(String payEndDate) {
		this.payEndDate = payEndDate;
	}

	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	public String getSelectId() {
		return selectId;
	}

	public void setSelectId(String selectId) {
		this.selectId = selectId;
	}

	public TrServRec getRec() {
		return rec;
	}

	public void setRec(TrServRec rec) {
		this.rec = rec;
	}

	public String getDealCode() {
		return dealCode;
	}

	public void setDealCode(String dealCode) {
		this.dealCode = dealCode;
	}

}
