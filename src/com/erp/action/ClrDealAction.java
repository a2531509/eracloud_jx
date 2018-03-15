package com.erp.action;

import java.math.BigDecimal;
import java.util.Calendar;
import java.util.Date;
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
import com.erp.model.PayCoCheckList;
import com.erp.model.PayCoCheckSingle;
import com.erp.model.PayOffline;
import com.erp.model.PayOfflineBlack;
import com.erp.model.SysActionLog;
import com.erp.service.ClrDealService;
import com.erp.util.Constants;
import com.erp.util.SqlTools;
import com.erp.util.Tools;
import com.erp.viewModel.Page;


@SuppressWarnings("serial")
@Namespace("/clrDeal")
@Action(value = "clrDealAction")
@InterceptorRefs({@InterceptorRef("jsondefalut")})
@Results({@Result(name="toAddOrUpdateBasePersonal",location="/jsp/dataAcount/dataAcountEditDlg.jsp")})
public class ClrDealAction extends BaseAction {

	private PayCoCheckSingle sign = new PayCoCheckSingle();
	private PayCoCheckList signList = new PayCoCheckList();
	public Logger log = Logger.getLogger(DataAcountAction.class);
	@Resource(name="clrDealService")
	private ClrDealService clrDealService;
	private String coOrgName;
	private String queryType = "1";
	private String sort;
	private String order;
	private String checkSignId="";
	private String checkListId="";
	private String merchantId="";
	private String merchantName="";
	private String startClrDate="";
	private String endClrDate="";
	private PayOffline pof = new PayOffline();
	private String dealNo;
	private String checkStartDate;
	private String checkEndDate;
	private String coOrgId;
	private String checkDate;
	private String fileType;
	private String clrDate;
	private String cardType;
	private String accKind;
	private String reqData = "";

	/**
	 * 获取对账信息
	 * @return
	 */
	public String findAllCheckBill(){
		try{
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT  t1.ID ID, t1.co_org_id CO_ORG_ID,t2.co_org_name CO_ORG_NAME,t1.check_date CHECK_DATE,");
				sb.append("decode(t1.proc_state,'0','对账平','1','平账中','2','对账不平明细未上传','3','对账不平明细已上传','其他') PROC_STATE,decode(t1.exist_detail,'0','有','1','无','未知') EXIST_DETAIL,");
				sb.append("decode(t1.dzpzlx,'01','系统平账','02','人工平账','03','未平账','未知') DZPZLX,decode(t1.js_state,'0','未生成','1','已生成','未知') JS_STATE,t1.TOTAL_ZC_SUM TOTAL_ZC_SUM,t1.TOTAL_ZC_AMT TOTAL_ZC_AMT,");
				sb.append("t1.TOTAL_TH_SUM TOTAL_TH_SUM, t1.TOTAL_TH_AMT TOTAL_TH_AMT,t1.TOTAL_CX_SUM TOTAL_CX_SUM,t1.TOTAL_CX_AMT TOTAL_CX_AMT,");
				sb.append("t1.TOTAL_ZCFROMADD_SUM TOTAL_ZCFROMADD_SUM,t1.TOTAL_ZCFROMADD_AMT TOTAL_ZCFROMADD_AMT,t1.TOTAL_THFROMADD_SUM TOTAL_THFROMADD_SUM,");
				sb.append("t1.TOTAL_THFROMADD_AMT TOTAL_THFROMADD_AMT,t1.TOTAL_CXFROMADD_SUM TOTAL_CXFROMADD_SUM,t1.TOTAL_CXFROMADD_AMT TOTAL_CXFROMADD_AMT,");
				sb.append("t1.TOTAL_ZCTOADD_NUM TOTAL_ZCTOADD_NUM,t1.TOTAL_ZCTOADD_AMT TOTAL_ZCTOADD_AMT,t1.TOTAL_THTOADD_NUM TOTAL_THTOADD_NUM,");
				sb.append("t1.TOTAL_THTOADD_AMT TOTAL_THTOADD_AMT,t1.TOTAL_CXTOADD_NUM TOTAL_CXTOADD_NUM,t1.TOTAL_CXTOADD_AMT TOTAL_CXTOADD_AMT,");
				sb.append("t1.SJ_TOTAL_ZC_SUM,t1.SJ_TOTAL_ZC_AMT,t1.TOTAL_THTOADD_NUM SJ_TOTAL_CX_SUM,");
				sb.append("t1.TOTAL_THTOADD_AMT SJ_TOTAL_CX_AMT,t1.TOTAL_CXTOADD_NUM SJ_TOTAL_TH_SUM,t1.TOTAL_CXTOADD_AMT SJ_TOTAL_TH_AMT");
				sb.append(" FROM pay_co_check_single t1,base_co_org t2 WHERE t1.co_org_id = t2.co_org_id(+) and t1.co_org_id in ("+Constants.CORG_CHECK_OLD_ID+")");
				if(!Tools.processNull(sign.getCoOrgId()).equals("")){
					sb.append("and t1.co_org_id = '" + sign.getCoOrgId() + "' ");
				}
				if(!Tools.processNull(coOrgName).equals("")){
					sb.append("and t2.co_org_name = '" + coOrgName.trim() + "' ");
				}
				if(!Tools.processNull(checkStartDate).equals("")){
					sb.append("and t1.check_date >='" + checkStartDate + "' ");
				}
				if(!Tools.processNull(checkEndDate).equals("")){
					sb.append("and t1.check_date <='" + checkEndDate + "' ");
				}
				if(!Tools.processNull(sign.getProcState()).equals("")){
					sb.append("and t1.proc_State <='" + sign.getProcState() + "' ");
				}
				if(!Tools.processNull(sign.getFileType()).equals("")){
					sb.append("and t1.file_type = '" + sign.getFileType() + "' ");
				}
				if(!Tools.processNull(sign.getExistDetail()).equals("")){
					sb.append("and t1.exist_detail = '" + sign.getExistDetail() + "' ");
				}
				if(!Tools.processNull(sign.getJsState()).equals("")){
					sb.append("and t1.js_state = '" + sign.getJsState() + "' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("order by t1.check_date desc");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应的结算单信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	public String findAllCheckBillList(){
		try{
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT t1.ID ID,t1.FILEID FILEID, t1.ACPT_ID CO_ORG_ID,t2.CO_ORG_NAME CO_ORG_NAME,t1.DEAL_CODE DEAL_CODE,");
				sb.append("(SELECT t3.deal_code_name FROM sys_code_tr t3 WHERE t3.deal_code = t1.deal_code) DEAL_CODE_NAME,");
				sb.append("t1.END_ID END_ID,t1.DEAL_BATCH_NO DEAL_BATCH_NO,t1.END_DEAL_NO END_DEAL_NO,t1.CARD_NO CARD_NO,");
				sb.append("t1.STATE,t1.CARD_NO2 CARD_NO2,");
				sb.append("to_char(t1.DEAL_DATE,'yyyy-mm-dd hh24:mi:ss') DEAL_DATE,t1.BANK_ID BANK_ID,t1.BANK_ACC,t1.user_id USER_ID,");
				sb.append("(SELECT t4.code_name FROM sys_code t4 WHERE t4.code_type = 'ACC_KIND' AND t4.code_value =t1.acc_kind) ACC_KIND_NAME,");
				sb.append("(SELECT t4.code_name FROM sys_code t4 WHERE t4.code_type = 'ACC_KIND' AND t4.code_value =t1.acc_kind2) ACC_KIND2_NAME,");
				sb.append("t1.AMTBEF ,t1.AMT,t1.OLD_ACTION_NO OLD_ACTION_NO,");
				sb.append("DECODE(t1.OPER_STATE,'0','待处理','1','已处理','未知') OPER_STATE,");
				sb.append("DECODE(t1.OPER_TYPE,'01','运营机构确认','02','运营机构撤销','03','合作机构补交易','04','合作机构撤销交易','05','日终自动处理','待处理') OPER_TYPE ");
				sb.append("FROM pay_co_check_list t1,base_co_org t2 WHERE t1.acpt_id =t2.co_org_id(+) and t1.acpt_id in ("+Constants.CORG_CHECK_OLD_ID+")");
				if(!Tools.processNull(checkSignId).equals("")){
					sb.append("and t1.fileid ='"+checkSignId+"' ");
				}
				if(!Tools.processNull(signList.getCoOrgId()).equals("")){
					sb.append("and t1.co_org_id = '" + signList.getCoOrgId() + "' ");
				}
				if(!Tools.processNull(signList.getEndId()).equals("")){
					sb.append("and t1.end_id '=" + signList.getEndId() + "' ");
				}
				if(!Tools.processNull(signList.getDealBatchNo()).equals("")){
					sb.append("and t1.deal_batch_no = '" + signList.getDealBatchNo() + "' ");
				}
				if(!Tools.processNull(signList.getEndDealNo()).equals("")){
					sb.append("and t1.end_deal_no = '" + signList.getEndDealNo() + "' ");
				}
				if(!Tools.processNull(signList.getCardNo()).equals("")){
					sb.append("and t1.card_No = '" + signList.getCardNo() + "' ");
				}
				if(!Tools.processNull(signList.getState()).equals("")){
					sb.append("and t1.state = '" + signList.getState() + "' ");
				}
				if(!Tools.processNull(signList.getOperState()).equals("")){
					sb.append("and t1.oper_state = '" + signList.getOperState() + "' ");
				}

				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("order by t1.end_deal_no desc, t1.deal_date desc");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应的结算单信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 合作机构补交易
	 * @return
	 */
	public String dealdzcorepair(){
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			clrDealService.saveDealdzcorepair(checkListId, baseService.getUser(), actionLog);
			jsonObject.put("status",0);
			jsonObject.put("errMsg","合作机构补交易成功");
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 运营机构撤销
	 * @return
	 */
	public String dealdzorgcancel(){
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			clrDealService.saveDealdzorgcancel(checkListId, baseService.getUser(), actionLog);
			jsonObject.put("status",0);
			jsonObject.put("errMsg","运营机构撤销");
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 运营机构补交易
	 * @return
	 */
	public String dealdzorgadd(){
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			clrDealService.saveDealdzorgadd(checkListId, baseService.getUser(), actionLog);
			jsonObject.put("status",0);
			jsonObject.put("errMsg","运营机构补交易");
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 合作机构删除
	 * @return
	 */
	public String dealdzdeletemx(){
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			clrDealService.saveDealdzdeletemx(checkListId, baseService.getUser(), actionLog);
			jsonObject.put("status",0);
			jsonObject.put("errMsg","合作机构删除成功");
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	/***
	 * 保存
	 * @throws Exception
	 */

	//初始化表格
	private void initGrid() throws Exception{
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg","");
	}

	public String findOfflineList(){
		try{
			this.initGrid();
			JSONArray footer = new JSONArray();
			JSONObject ftotal = new JSONObject();
			ftotal.put("NORMOL_NUM","0");
			ftotal.put("NORMOL_AMT","0.00");
			ftotal.put("REFUSE_NUM","0");
			ftotal.put("REFUSE_AMT","0.00");
			ftotal.put("DEAL_NUM","0");
			ftotal.put("DEAL_AMT","0.00");
			ftotal.put("MERCHANT_NAME","本页信息统计：");
			jsonObject.put("rows",new JSONArray());
			jsonObject.put("total",0);
			jsonObject.put("status",0);
			jsonObject.put("errMsg",0);
			if(Tools.processNull(this.queryType).equals("0")){
				//判断输入的商户号是否正确
				/*if(!Tools.processNull(merchantId).equals(clrDealService.getSysConfigurationParameters("BIZ_ID_GJ0"))){
					throw new CommonException("输入的商户号不是电子钱包消费商户，请重新选择！");
				}*/
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT t.merchant_id||'|'||t.clr_date ID, t.merchant_id,(SELECT t1.merchant_name FROM base_merchant t1 WHERE t1.merchant_id = t.merchant_id) MERCHANT_NAME,");
				sb.append("t.clr_date CLR_DATE,"+SqlTools.divHundred("t.normol_amt")+" NORMOL_AMT,t.normol_num NORMOL_NUM,t.refuse_num REFUSE_NUM,"+SqlTools.divHundred("t.refuse_amt")+
						" REFUSE_AMT,t.deal_num DEAL_NUM,"+SqlTools.divHundred("t.deal_amt")+" DEAL_AMT from pay_offline_clr_sum t  where 1=1 ");
				if(!Tools.processNull(merchantId).equals("")){
					sb.append("and t.merchant_id = '" + merchantId + "' ");
				}
				if(!Tools.processNull(startClrDate).equals("")){
					sb.append("and t.clr_date >='" + startClrDate + "' ");
				}
				if(!Tools.processNull(endClrDate).equals("")){
					sb.append("and t.clr_date <= '" + endClrDate + "' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("order by t.clr_date desc");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null){
					footer.add(ftotal);
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("footer",footer);
					jsonObject.put("total", list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应的公交对账信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	public String findAllOfflineMxList(){
		try{
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				String[] ids = checkSignId.split("\\|");
				String dealBathId = ids[1].replace("-","");
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT t.deal_no ID,T.ACPT_ID ACPT_ID ,T3.MERCHANT_NAME MERCHANT_NAME,T.END_ID END_ID,T.DEAL_BATCH_NO DEAL_BATCH_NO,");
				sb.append("T.END_DEAL_NO END_DEAL_NO,to_char(TO_DATE(T.DEAL_DATE, 'yyyy-mm-dd hh24:mi:ss'),'yyyy-mm-dd hh24:mi:ss') DEAL_DATE,"+SqlTools.divHundred("T.DEAL_AMT")+" DEAL_AMT,");
				sb.append("(SELECT a.code_name from sys_code a WHERE a.code_type ='REFUSE_REASON' and a.code_value = T.REFUSE_REASON) REFUSE_REASON,T.CLR_DATE");
				sb.append(" CLR_DATE,T.SEND_FILE_NAME SEND_FILE_NAME,T.PROCESSING_STATE FROM (SELECT * FROM ");
				sb.append("PAY_OFFLINE_BLACK T1 UNION ALL SELECT * FROM PAY_OFFLINE_LIST T2) T,BASE_MERCHANT T3 WHERE ");
				sb.append("T.ACPT_ID = T3.MERCHANT_ID(+) AND T.ACPT_ID = '"+ids[0]+"' AND T.CLR_DATE = '"+ids[1]+"'");
				//sb.append("AND T.REFUSE_REASON not in ('10','64')");
				//sb.append(" and t.refuse_reason not in ('10','64') and t.deal_batch_no = '"+dealBathId+"' ");
				if(!Tools.processNull(pof.getEndId()).equals("")){
					sb.append("and t.END_ID = '" + pof.getEndId() + "' ");
				}
				if(!Tools.processNull(pof.getProcessingState()).equals("")){
					sb.append("and t.PROCESSING_STATE = '" + pof.getProcessingState() + "' ");
				}
				if(!Tools.processNull(pof.getDealBatchNo()).equals("")){
					sb.append("and t.DEAL_BATCH_NO '=" + pof.getDealBatchNo() + "' ");
				}
				if(!Tools.processNull(pof.getEndDealNo()).equals("")){
					sb.append("and t.end_deal_no = '" + pof.getEndDealNo() + "' ");
				}
				if(!Tools.processNull(pof.getCardNo() ).equals("")){
					sb.append("and t.card_no = '" + pof.getCardNo() + "' ");
				}
				if(!Tools.processNull(pof.getRefuseReason()).equals("")){
					sb.append("and t.refuse_Reason = '" + pof.getRefuseReason() + "' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("order by t.deal_date desc");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应的电子钱包交易明细信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 *
	 * @return
	 */
	public String offlineDeal(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","脱机数据入账成功");
		try {
			reqData = reqData.substring(1,reqData.length()-1);
			for(String dealNo : reqData.split(",")) {
				//1.判断该数据该卡的交易序号是否重复
				PayOfflineBlack offline = (PayOfflineBlack)clrDealService.findOnlyRowByHql("from PayOfflineBlack where dealNo='"+dealNo+"'");
				//只能操作tac码
				if(!offline.getRefuseReason().equals("01")){
					throw new CommonException("暂时不支持此操作！");
				}
				if(offline == null){
					throw new CommonException("您选择的记录不正确，无需要处理，请重新选择！");
				}
				if(offline.getRefuseReason().equals("01")){
					BigDecimal lncount =  (BigDecimal)clrDealService.findOnlyFieldBySql("select nvl(count(*),0) from pay_offline_list t where t.card_deal_count ='"+offline.getCardDealCount()+"'" + "and t.refuse_reason = '01'");
					if(lncount.intValue() > 0){
						throw new CommonException("卡内交易序号重复，不能进行脱机数据的人工入账，请核对交易信息！");
					}
				}else {
					BigDecimal lncount =  (BigDecimal)clrDealService.findOnlyFieldBySql("select nvl(count(*),0) from pay_offline_list t where t.card_deal_count ='"+offline.getCardDealCount()+"'");
					if(lncount.intValue() > 0){
						throw new CommonException("卡内交易序号重复，不能进行脱机数据的人工入账，请核对交易信息！");
					}
				}


				//2.脱机数据入账户
				SysActionLog actionLog = baseService.getCurrentActionLog();
				clrDealService.saveDealOffilne(actionLog, baseService.getUser(), dealNo);
			}

		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg","脱机数据入账失败："+e.getMessage());
		}
		return this.JSONOBJ;
	}

	public String getCheckFile(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","获取对账文件成功");
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			BigDecimal bg = (BigDecimal)baseService.findOnlyFieldBySql("select count(1) from base_co_org t where t .co_org_id = '"+coOrgId+"' and co_state = '0'");
			if(bg.intValue() == 0){
				throw new CommonException("选择的合作机构在系统内未登记或登记信息不正常！请重新选择。");
			}
			if("".equals(Tools.processNull(coOrgId))){
				throw new CommonException("请输入合作机构编号！");
			}
			if("".equals(Tools.processNull(checkDate))){
				throw new CommonException("请输入对账日期！");
			}
			if("".equals(Tools.processNull(fileType))){
				throw new CommonException("请选择对账类型！");
			}
			clrDealService.saveGetCheckFile(actionLog, baseService.getUser(), coOrgId, checkDate,fileType);
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	public String merClrSumQuery(){
		try {
			initGrid();
			if(!queryType.equals("0")){
				return JSONOBJ;
			}

			StringBuilder sql = new StringBuilder();

			sql.append("SELECT PCS.CLR_NO,PCS.CLR_DATE,PCS.MERCHANT_ID,MER.MERCHANT_NAME,"
					+ "(SELECT DEAL_CODE_NAME FROM SYS_CODE_TR WHERE DEAL_CODE = PCS.DEAL_CODE) DEAL_NAME,"
					+ "(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CARD_TYPE' AND CODE_VALUE = PCS.CARD_TYPE) CARD_TYPE,"
					+ "(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'ACC_KIND' AND CODE_VALUE = PCS.ACC_KIND) ACC_KIND,"
					+ "PCS.DEAL_NUM,TO_CHAR(PCS.DEAL_AMT/100, 'FM9999990.00') DEAL_AMT,PCS.STL_SUM_NO,PCS.STL_DATE,PCS.FEE_STL_SUM_NO,PCS.FEE_STL_DATE,PCS.STL_FLAG,PCS.FEE_STL_FLAG "
					+ "FROM PAY_CLR_SUM PCS JOIN BASE_MERCHANT MER ON PCS.MERCHANT_ID = MER.MERCHANT_ID WHERE 1=1 ");

			if (!Tools.processNull(merchantId).equals("")) {
				sql.append("AND PCS.MERCHANT_ID='" + merchantId + "' ");
			}

			if (!Tools.processNull(merchantName).equals("")) {
				sql.append("AND MER.MERCHANT_NAME='" + merchantName + "' ");
			}

			if (!Tools.processNull(clrDate).equals("")) {
				sql.append("AND PCS.CLR_DATE='" + clrDate + "' ");
			}

			if (!Tools.processNull(cardType).equals("")) {
				sql.append("AND PCS.CARD_TYPE='" + cardType + "' ");
			}

			if (!Tools.processNull(accKind).equals("")) {
				sql.append("AND PCS.ACC_KIND='" + accKind + "' ");
			}

			if (!Tools.processNull(sort).equals("")) {
				sql.append("order by " + sort);

				if (!Tools.processNull(order).equals("")) {
					sql.append(" " + order);
				}
			}

			Page data = clrDealService.pagingQuery(sql.toString(), page, rows);

			if (data.getAllRs() == null) {
				throw new CommonException("找不到记录");
			}

			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String updateCoOrgStat(){
		try {
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(new Date());
			calendar.set(Calendar.DAY_OF_MONTH, 1);
			calendar.set(Calendar.HOUR_OF_DAY, 0);
			calendar.set(Calendar.MINUTE, 0);
			calendar.set(Calendar.SECOND, 0);
			List<BaseCoOrg> orgs = clrDealService.findByHql("from BaseCoOrg t where coState = '" + Constants.STATE_ZC + "' and indusCode <> '1'");
			for(BaseCoOrg org:orgs){
				try {
					clrDealService.saveCoOrgStat(org.getCoOrgId(), calendar.getTime());
				} catch (Exception e) {
					continue;
				}
			}
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("msg", e.getMessage());
		}
		return JSONOBJ;
	}

	public PayCoCheckSingle getSign() {
		return sign;
	}

	public void setSign(PayCoCheckSingle sign) {
		this.sign = sign;
	}

	public String getCoOrgName() {
		return coOrgName;
	}

	public void setCoOrgName(String coOrgName) {
		this.coOrgName = coOrgName;
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

	public PayCoCheckList getSignList() {
		return signList;
	}

	public void setSignList(PayCoCheckList signList) {
		this.signList = signList;
	}

	public String getCheckSignId() {
		return checkSignId;
	}

	public void setCheckSignId(String checkSignId) {
		this.checkSignId = checkSignId;
	}

	public String getCheckListId() {
		return checkListId;
	}

	public void setCheckListId(String checkListId) {
		this.checkListId = checkListId;
	}

	public String getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getStartClrDate() {
		return startClrDate;
	}

	public void setStartClrDate(String startClrDate) {
		this.startClrDate = startClrDate;
	}

	public String getEndClrDate() {
		return endClrDate;
	}

	public void setEndClrDate(String endClrDate) {
		this.endClrDate = endClrDate;
	}

	public PayOffline getPof() {
		return pof;
	}

	public void setPof(PayOffline pof) {
		this.pof = pof;
	}

	public String getDealNo() {
		return dealNo;
	}

	public void setDealNo(String dealNo) {
		this.dealNo = dealNo;
	}

	public String getCheckStartDate() {
		return checkStartDate;
	}

	public void setCheckStartDate(String checkStartDate) {
		this.checkStartDate = checkStartDate;
	}

	public String getCheckEndDate() {
		return checkEndDate;
	}

	public void setCheckEndDate(String checkEndDate) {
		this.checkEndDate = checkEndDate;
	}

	public String getCoOrgId() {
		return coOrgId;
	}

	public void setCoOrgId(String coOrgId) {
		this.coOrgId = coOrgId;
	}

	public String getCheckDate() {
		return checkDate;
	}

	public void setCheckDate(String checkDate) {
		this.checkDate = checkDate;
	}

	public String getFileType() {
		return fileType;
	}

	public void setFileType(String fileType) {
		this.fileType = fileType;
	}

	public String getClrDate() {
		return clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	public String getAccKind() {
		return accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	public String getReqData() {
		return reqData;
	}

	public void setReqData(String reqData) {
		this.reqData = reqData;
	}
}
