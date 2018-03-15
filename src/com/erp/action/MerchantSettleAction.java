package com.erp.action;

import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFPrintSetup;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.Region;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseMerchant;
import com.erp.model.CardOrgBindSection;
import com.erp.model.StlReceiptReg;
import com.erp.model.SysActionLog;
import com.erp.model.Users;
import com.erp.service.MerchantMangerService;
import com.erp.util.ChangeRMB;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.ExportExcel;
import com.erp.util.ReportUtil;
import com.erp.util.SqlTools;
import com.erp.util.Tools;
import com.erp.viewModel.ExecelView;
import com.erp.viewModel.Json;
import com.erp.viewModel.Page;

import jxl.Workbook;
import jxl.format.Alignment;
import jxl.format.Border;
import jxl.format.BorderLineStyle;
import jxl.format.Colour;
import jxl.write.Label;
import jxl.write.WritableCellFormat;
import jxl.write.WritableFont;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;
import net.sf.jasperreports.engine.JRResultSetDataSource;
import net.sf.jasperreports.engine.JasperRunManager;

@Namespace("/merchantSettle")
@Action(value = "merchantSettleAction")
@Results({@Result(type="json",name="json"),
	@Result(name="toSettlementAudit",location="/jsp/merchant/merSettleCKMain.jsp"),
	@Result(name="viewSettlementAudit",location="/jsp/merchant/merSettleView.jsp"),
	@Result(name="cardOrgBindSectionManage", location="/jsp/cardOrgBindSection/cardOrgBindSectionManage.jsp")})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class MerchantSettleAction extends BaseAction {
	private MerchantMangerService merchantMangerService;
	private String sort="";
	private String order="";
	private String htj;
	public String merchantId="";
	public String startDate="";
	public String endDate="";
	public String stlState="";
	public String stlWay="";
	public String accKind="";
	public String cardType="";
	private String merchantName = "";
	private String dealCode = "";
	private String expid = "";
	private String queryType = "1";//查询类型 1 不进行查询,直接返回;0 进行查询,返回查询结果。
	private String stlSumNo;
	private String type="";//结算报表打印参数
	private String bankSheetNo="";//银行回单编号
	private String month="";//月报月份
	private String year="";//结算年份
	private String sectionData = "";
	private CardOrgBindSection bindSection = new CardOrgBindSection();
	
	/**
	 * 组装查询语句供本类查询和打印方法调用
	 * @return
	 */
	public String makeSql(){
		String sql="select t.stl_sum_no SETTLEID ,t.stl_date stl_date,t.merchant_id merchant_id,"+
				"(select a.merchant_name from base_merchant a where a.merchant_id = t.merchant_id) merchant_name,"+
				 "sum(t.deal_num) deal_num ,"+SqlTools.divHundred("sum(t.deal_amt)")  +" deal_amt,"+
				 SqlTools.divHundred("sum(t.deal_fee)") + " deal_fee,sum(t.th_num)  th_num,"+
				 SqlTools.divHundred("sum(t.th_amt)") +" th_amt,"+SqlTools.divHundred("sum(t.stl_amt)") +" stl_amt,min(t.begin_date) begin_date,max(t.end_date) end_date,"+
				"(select b.bank_name from base_merchant a,base_bank b where a.bank_id = b.bank_id(+) and a.merchant_id = t.merchant_id) bank_id,"+
				"(select a.bank_acc_name from base_merchant a where a.merchant_id = t.merchant_id) bank_acc_name,"+
				"(select a.bank_acc_no from base_merchant a where a.merchant_id = t.merchant_id) bank_acc_no, "+
				"(select c.code_name from sys_code c where c.code_type ='STL_STATE' and c.code_value = t.stl_state) STL_STATE "+
				" from stl_deal_sum t where 1=1 ";
	
		if (!Tools.processNull(merchantId).equals("")) {
			sql += " and  (t.merchant_id in (select h.merchant_id from base_merchant h start with h.top_merchant_id ='"+ merchantId+"' connect by prior " +
					"h.merchant_id = h.top_merchant_id) or t.merchant_id ='"+merchantId+"')";
		}
		if (!Tools.processNull(startDate).equals("")) {
			sql += " and t.stl_date>='" + startDate + "'";
		}
		if (!Tools.processNull(endDate).equals("")) {
			sql += " and t.stl_date<='" + endDate + "'";
		}
		//0 未审核 1 已审核 2已导出 9 已支付
		if(!Tools.processNull(stlState).equals("")) {
			sql += " and t.stl_State = '" + stlState + "'";
		}
		sql+=" group by t.stl_sum_no, t.merchant_id, t.stl_date,t.stl_state";
		if(Tools.processNull(this.getSort()).equals("")&&Tools.processNull(this.getOrder()).equals("")){
			sql +=" order by t.stl_date desc ";
		}
		return sql;
	}
	
	/**
	 * 商户结算审核查询
	 * @return
	 */
	public String toSettlementAudit(){
		JSONArray footer = new JSONArray();
		JSONObject ftotal = new JSONObject();
		ftotal.put("DEAL_NUM","0");
		ftotal.put("TH_NUM","0");
		ftotal.put("STL_AMT","0.00");
		ftotal.put("DEAL_AMT","0.00");
		ftotal.put("TH_AMT","0.00");
		ftotal.put("DEAL_FEE","0.00");
		ftotal.put("MERCHANT_NAME","本页信息统计：");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		try {
			if(Tools.processNull(queryType).equals("0")){
				if(!Tools.processNull(endDate).equals("")&&!Tools.processNull(startDate).equals("")){
					if(DateUtil.formatDate(endDate).before(DateUtil.formatDate(startDate)))
						throw new CommonException("起始日期不能大于结束日期");
				}
				String sql = makeSql();
				// 组装分页对象
				Page pages = merchantMangerService.pagingQuery(sql,page,rows);
				if(pages.getAllRs() != null){
					footer.add(ftotal);
					jsonObject.put("rows",pages.getAllRs());
					jsonObject.put("footer",footer);
					jsonObject.put("total", pages.getTotalCount());
				}
			}
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	
	/**
	 * 商户结算-结算审核-显示明细
	 */
	public String viewSettlementAudit(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		try {
			String[] stlSumNos = stlSumNo.split(",");
			String head = " select (select code_name from sys_code a where a.code_type='CARD_TYPE' and a.code_value=t.card_type) card_type,"
					+ "(select deal_CODE_NAME from SYS_CODE_TR s where t.deal_CODE=s.deal_code) tr_Code,"
					+ "(select t2.acc_name from acc_kind_config t2 WHERE t2.acc_kind = t.acc_kind) acc_kind_name,"
					+ "deal_num tr_Num," + SqlTools.divHundred("deal_Amt") + " as tr_Amt,"
					+ " decode(nvl(t1.fee_type,'-1'),'1',trim(to_char(nvl(t1.fee_rate/10000,0),'999990.99'))||'元/笔','2',trim(to_char(nvl(t1.fee_rate/100,0),'999990.99'))||'%',0||'.00%') fee_rate,"
					+ "trim(to_char(nvl(t.fee_amt,0)/100,'99990.99')) fee_amt," + SqlTools.divHundred("nvl(oth_Fee,0)") + " as oth_Fee";
			String sql = head + " from stl_deal_list t,pay_fee_rate t1  where 1 = 1 and t.fee_rate_id = t1.fee_rate_id(+) ";
			sql += " and t.stl_sum_no = '" + stlSumNos[0] + "'";
			if(stlSumNos.length>1){
				sql += " and t.card_Type = '" + stlSumNos[1] + "' and t.acc_kind = '"+stlSumNos[2]+"'";
			}
			if(!Tools.processNull(endDate).equals("")&&!Tools.processNull(startDate).equals("")){
				if(DateUtil.formatDate(endDate).before(DateUtil.formatDate(startDate)))
					throw new CommonException("起始日期不能大于结束日期");
			}
			// 组装分页对象
			Page pages = merchantMangerService.pagingQuery(sql,0,10000);
			if(pages.getAllRs() != null){
				jsonObject.put("rows",pages.getAllRs());
				jsonObject.put("total", pages.getTotalCount());
			}
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	
	/**
	 * 结算审核保存
	 */
	public String saveSettlementAudit(){
		Json json = new Json();
		String messages="";
		try{
			//页面返回字符串1|2格式
			String ids[] = stlSumNo.split("\\|");
			merchantMangerService.savesettlementAudit(baseService.getCurrentActionLog(),merchantMangerService.getUser(),ids);
			//查询
			messages = "审核完成";
			json.setStatus(true);
			json.setTitle("");
			json.setMessage(messages);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setTitle("");
			json.setMessage(e.getMessage());
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	/**
	 * 商户结算回退
	 * @return
	 */
	public String rollBackSettle(){
		Json json = new Json();
		String messages="";
		try {
			String ids[] = stlSumNo.split("\\|");
			SysActionLog  actionLog = baseService.getCurrentActionLog();
			Users user = merchantMangerService.getUser();
			merchantMangerService.saverollback(actionLog,user,ids[0]);
			messages = "回退完成";
			json.setStatus(true);
			json.setTitle("");
			json.setMessage(messages);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setTitle("错误信息");
			json.setMessage(e.getMessage());
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	/**
	 * 结算支付文件打印
	 * @return
	 */
	public String printSettle(){
		jsonObject.put("status", false);
		jsonObject.put("title", "错误信息");
		jsonObject.put("message", "");
		try{
			String title = "";
			String sql="";
			String BackUrl = "";
			
			String[] id = Tools.processNull(stlSumNo).split("\\|");//STL_SUM_NO, CARD_TYPE, ACC_KIND
			String head = "select ";
			head += " ROW_NUMBER() over(order by merchant_id, stl_date) seq,min(start_date) start_date,max(end_date) end_date, bank_id,merchant_name,merchant_id,stl_date,stl_way, " + 
					"nvl(bank_acc_no,'') bank_acc_no,sum(deal_num) tr_num," + 
					SqlTools.divHundred("sum(deal_amt)") + "tr_amt," +
					SqlTools.divHundred("sum(deal_fee)") + " fee_amt," +
					SqlTools.divHundred("sum(stl_amt)") + " stl_amt" + 
					" from(select t.stl_date stl_date , begin_date start_date, end_date end_date,t1.bank_acc_no bank_acc_no,t.deal_num deal_num,t.deal_amt deal_amt,t.deal_fee deal_fee,"+
					"t.stl_amt stl_amt,t.merchant_id merchant_id,t.stl_sum_no stl_sum_no,t1.merchant_name merchant_name,"+
					"(select h1.bank_name from base_bank h1 where h1.bank_id = t1.bank_id) bank_id,"+
					"(select a from (select stl_days || '（' || decode(stl_way, '01', '日结', '02', '限额接', '03', '周结', '04', '月结', '05', '日结 + 月结', '06', '限额结 + 月结', '') || '）' a, merchant_id from stl_mode order by valid_date desc) where t.merchant_id = merchant_id and rownum = 1) stl_way ";
			htj = " from stl_deal_sum t, base_merchant t1 where t.merchant_id = t1.merchant_id(+)  ";
			String temp = "'";
			if(stlSumNo != null && id.length > 0){
				for (String string : id) {
					String[] sm = string.split(",");
					temp += sm[0] + "','";
				}
				temp = temp.substring(0,temp.length() - 2);
				htj += " and t.stl_Sum_No in (" + temp + ")";
			}
			sql = head + htj + " ) h group by merchant_name,merchant_id,stl_date,stl_way,bank_acc_no,bank_id";
			title = "商户清算支付申请单";
			
			//计算总金额,总笔数
			Object []onerow= (Object[]) merchantMangerService.findOnlyRowBySql("select sum(deal_num),"
														+SqlTools.divHundred("sum(deal_amt)")+","
														+SqlTools.divHundred("sum(stl_amt)")+","
														+SqlTools.divHundred("sum(deal_fee)")+htj);
			Map reprortParam = new HashMap();
			reprortParam.put("p_Tr_Num", Tools.processNull(onerow[0]));
			reprortParam.put("p_Tr_Amt", Tools.processNull(onerow[1]));
			reprortParam.put("p_Stl_Amt",Tools.processNull(onerow[2]));
			reprortParam.put("p_fee_Amt",Tools.processNull(onerow[3]));
			reprortParam.put("p_Rmb",ChangeRMB.praseUpcaseRMB(Tools.processNull(onerow[2])));
			reprortParam.put("p_Title", title);
			reprortParam.put("p_TotalCount", merchantMangerService.findOnlyFieldBySql("select count(1) from ("+sql+")"));
			reprortParam.put("p_Print_Name", Tools.processNull(merchantMangerService.getUser().getUserId()));
			reprortParam.put("p_Print_Time", merchantMangerService.getDateBaseDateStr());
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setMessage(title+"报表");
			actionLog.setDealCode(999999);
			SysActionLog log = merchantMangerService.savePrintReport(actionLog, merchantMangerService.getUser(),temp);
			log.setDealCode(DealCode.MERCHANT_SETTLEMENT_PRINTPAY);
			String path = ServletActionContext.getRequest().getRealPath("/reportfiles/ShangHuJieSuanPZ.jasper");
			JRResultSetDataSource source = new JRResultSetDataSource(merchantMangerService.tofindResultSet(sql));
			byte[] pdfContent = JasperRunManager.runReportToPdf(path, reprortParam,source);
			merchantMangerService.saveSysReport(log, new JSONObject(), "",Constants.APP_REPORT_TYPE_PDF2,1l, "", pdfContent);
			pdfContent=null;
			jsonObject.put("status", true);
			jsonObject.put("title", "");
			jsonObject.put("actionNo", log.getDealNo());
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status", false);
			jsonObject.put("title", "错误信息");
			jsonObject.put("message", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 商户结算支付保存
	 */
	public String saveSettlementPayment(){
		Json json = new Json();
		String messages="";
		try{
			if(bankSheetNo.equals("")){
				throw new CommonException("请输入银行回单编号！");
			}
			//调用存储过程结算
			String ids[] = Tools.processNull(stlSumNo).split("\\|");
			String temp = "'";
			if(stlSumNo != null && ids.length > 0){
				for (String string : ids) {
					String[] sm = string.split(",");
					temp += sm[0] + "','";
				}
				temp = temp.substring(0,temp.length() - 2);
			}
			List<String> stl_sums = merchantMangerService.findBySql("select t.merchant_id from Stl_Deal_sum t where  t.stl_sum_no in (" + temp + ") group by t.merchant_id ");
			if(stl_sums != null && stl_sums.size() > 1){
				throw new CommonException("请对同一商户进行结算支付");
			}
			//判断当前的银行回单号以前结算的商户
			List<StlReceiptReg> books = merchantMangerService.findByHql("from StlReceiptReg t where t.bankSheetNo = '"+bankSheetNo+"'");
			for(int j=0;j<books.size();j++){
				//if(!books.get(j).getMerchantId().equals(stl_sums.get(0).toString()))throw new CommonException("回单号只能用于同一商户！"); 
			}  
			messages = Tools.strtoUTF8("商户结算支付完成！");
			/**
			 * 要支付的结算记录  STL_SUM_NO$CARD_TYPE$ACC_KIND,STL_SUM_NO$CARD_TYPE$ACC_KIND
			 */
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealCode(DealCode.MERCHANT_SETTLEMENT_PAYMENT);
			actionLog.setMessage("商户结算支付");
			actionLog.setBrchId(merchantMangerService.getSysBranchByUserId().getBrchId());
			actionLog.setDealTime(merchantMangerService.getDateBaseTime());
			merchantMangerService.savesettlementPayment(actionLog,merchantMangerService.getUser(),temp,bankSheetNo);
			messages = "支付完成";
			json.setStatus(true);
			json.setTitle("");
			json.setMessage(messages);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setTitle("错误信息");
			json.setMessage(e.getMessage());
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	/**
	 * 导出结算数据为excel形式
	 * @return
	 */
	public String exportMerSettleExcel(){
		try {
			
			String sql="";
			String[] id = Tools.processNull(stlSumNo).split("\\|");//STL_SUM_NO, CARD_TYPE, ACC_KIND
			String head = "select ";
			head += "ROW_NUMBER() over(order by t.merchant_id, t.stl_date) seq,t.stl_date stl_date ,t.merchant_id merchant_id,t.merchant_name merchant_name,sum(t.deal_num) as tr_num, " + 
					SqlTools.divHundred("sum(t.deal_amt)") + "  tr_amt," + SqlTools.divHundred("sum(t.deal_fee)") + "  tr_fee," +
					SqlTools.divHundred("sum(t.th_amt)") +" th_amt,"+SqlTools.divHundred("sum(t.stl_amt)") + "  stl_amt,"+
					" b.bank_acc_name,b.bank_id,b.bank_acc_no";
			htj = " from stl_deal_sum t, base_merchant b where t.merchant_id = b.merchant_id ";
			String temp = "'";
			if(stlSumNo != null && id.length > 0){
				for (String string : id) {
					String[] sm = string.split(",");
					temp += sm[0] + "','";
				}
				temp = temp.substring(0,temp.length() - 2);
				htj += " and t.stl_Sum_No in (" + temp + ")";
			}
			String[] headers = { "序号", "结算日期", "商户编号", "商户名称", "交易笔数",
		            "交易金额", "服务费" , "退货金额", "结算金额"};
			sql = head + htj + " group by t.merchant_id,t.stl_date,t.merchant_name,b.BANK_ACC_NAME,b.BANK_ACC_NO,b.BANK_ID";
			List<ExecelView> excelList = new ArrayList<ExecelView>();
			List entityList = merchantMangerService.findBySql(sql
					+ " order by merchant_id,stl_date");
			for(int i=0;i<entityList.size();i++){
				ExecelView view = new ExecelView();
				Object[] obj = (Object[])entityList.get(i);
				view.setSeq(Tools.processNull(obj[0]));
				view.setStlDate(Tools.processNull(obj[1]));
				view.setMerchantId(Tools.processNull(obj[2]));
				view.setMerchantName(Tools.processNull(obj[3]));
				view.setTotalSum(Tools.processNull(obj[4]));
				view.setTotalAmt(Tools.processNull(obj[5]));
				view.setFreeAmt(Tools.processNull(obj[6]));
				view.setThAmt(Tools.processNull(obj[7]));
				view.setStlAmt(Tools.processNull(obj[8]));
				excelList.add(view);
			}
			//计算总金额,总笔数
			Object []onerow= (Object[]) merchantMangerService.findOnlyRowBySql("select sum(deal_num),"
														+SqlTools.divHundred("sum(deal_amt)")+","
														+SqlTools.divHundred("sum(stl_amt)")+htj);
			ExecelView view_total = new ExecelView();
			view_total.setSeq(Tools.processNull("合计："));
			view_total.setStlDate(Tools.processNull(""));
			view_total.setMerchantId(Tools.processNull(""));
			view_total.setMerchantName(Tools.processNull(""));
			view_total.setTotalSum(Tools.processNull(onerow[0]));
			view_total.setTotalAmt(Tools.processNull(onerow[1]));
			view_total.setFreeAmt(Tools.processNull(""));
			view_total.setThAmt(Tools.processNull(""));
			view_total.setStlAmt(Tools.processNull(onerow[2]));
			excelList.add(view_total);
			
			ExportExcel<ExecelView> ex = new ExportExcel<ExecelView>();
			HttpServletResponse response = ServletActionContext.getResponse();
			String fileName = "商户结算数据导出";
			response.setContentType("application/ms-excel;charset=utf-8");
		    response.setHeader("Content-disposition", "attachment; filename="+ URLEncoder.encode(fileName,"UTF8") + ".xls");
		    OutputStream out = response.getOutputStream();
	        ex.exportExcel("商户结算数据",headers, excelList, out,"");
	        out.close();
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return null;
	}
	
	/**
	 * 商户结算导出商户结算明细
	 * @return
	 */
	@SuppressWarnings({ "unused", "rawtypes", "unchecked" })
	public String execelSettleMx(){
		try {
			String stl_Sum_No = "";
			String htj = "";
			String[] stl_sum_nos = Tools.processNull(stlSumNo).split("\\|");
			String temp = "'";
			if(stlSumNo != null && stl_sum_nos.length > 0){
				for (String string : stl_sum_nos) {
					String[] sm = string.split(",");
					temp += sm[0] + "','";
				}
				temp = temp.substring(0,temp.length() - 2);
				htj += " and t.stl_Sum_No in (" + temp + ")";
			}
			String mxtitle[] = { "交易时间", "商户编号", "商户名称", "批次号", "流水号",
					"终端号", "交易名称", "卡号", "交易金额"};/*, "记录状态" */
			List shhztoexcellist = new ArrayList();// 定义商户汇总list，一个值代表一个循环
			// 组装stl_Sum_No
			List shhzlist = null;
			shhzlist = merchantMangerService.findBySql("select min(begin_date),max(end_date),merchant_name,merchant_id,"
					+ "sum(TOT_DEAL_NUM),trim(to_char(sum(nvl(DEAL_AMT,0)) / 100, '99999999999990.99')) as tr_amt,"
					+ "trim(to_char(sum(nvl(DEAL_FEE, 0)) / 100, '99999999999990.99')) as tr_fee,"
					+ "trim(to_char(sum(nvl(stl_amt, 0)) / 100, '99999999999990.99')) as stl_amt,stl_date "
					+ "from stl_deal_sum t where  stl_sum_no in ("
					+ temp + ") group by merchant_id,merchant_name,stl_date");

			for (int j = 0; j < shhzlist.size(); j++) {
				List dgshhzlist = new ArrayList();
				// 一个商户 一个值商户名称+结算时间 第二个值是抬头（固定） 第三个是消费明细（list）
				// 第四行是正常总笔数 第五行是正常总金额 ，第六行是手续费费率 第七行是手续费 第八行是应付金额
				Object o[] = (Object[]) shhzlist.get(j);
				// 第一行
				dgshhzlist.add(Tools.processNull(o[2]) + Tools.processNull(o[0]) + "--" + Tools.processNull(o[1]) + "交易明细");// 中石化第二发卡网点（斜西街环城路口）5月5日—5月5日交易明细
				// 第二行
				dgshhzlist.add(mxtitle);
				
				//获取清分汇总序号
				List clrSum = merchantMangerService.findBySql("select clr_no from pay_clr_sum t where t.stl_sum_no in (select a.stl_sum_no from "
						+ " stl_deal_sum a where a.merchant_id ='"+Tools.processNull(o[3])+"' and a.stl_date ='"+Tools.processNull(o[8])+"')");
				String clrNo = "";
				for (int s = 0; s < clrSum.size(); s++) {
					clrNo += "," +  clrSum.get(s);
					if (!clrNo.equals(""))
						clrNo = "0"+clrNo;
				}
				//获取交易明细
				String maxClrDate = (String)merchantMangerService.findOnlyFieldBySql("select max(t.clr_date) from pay_clr_sum t where t.stl_sum_no in (select a.stl_sum_no from "
						+ " stl_deal_sum a where a.merchant_id ='"+Tools.processNull(o[3])+"' and a.stl_date ='"+Tools.processNull(o[8])+"')");
				String minClrDate = (String)merchantMangerService.findOnlyFieldBySql("select min(t.clr_date) from pay_clr_sum t where t.stl_sum_no in (select a.stl_sum_no from "
						+ " stl_deal_sum a where a.merchant_id ='"+Tools.processNull(o[3])+"' and a.stl_date ='"+Tools.processNull(o[8])+"')");
				
				String table_pre = "ACC_INOUT_DETAIL_";
				List<String> allTabs = baseService.findBySql("select t.table_name from user_tables t where t.table_name between '" + table_pre + minClrDate.substring(0,7).replaceAll("-","") + "' and '" + table_pre + maxClrDate.substring(0,7).replaceAll("-","") + "'");
				if(allTabs == null || allTabs.size() <= 0){
					throw new CommonException("记录信息不存在！");
				}
				StringBuffer initsql = new StringBuffer();
				for (int i = 0; i < allTabs.size(); i++) {
					initsql.append("(select * from ");initsql.append(allTabs.get(i));
					if(i != allTabs.size() -1 ){
						initsql.append(" union ");
					}else{
						initsql.append(" ) ");
					}
				}
				
				
				String sql = "select to_char(t.deal_date, 'yyyy-mm-dd hh24:mi:ss') deal_date,"
						+ "t.acpt_id, m.merchant_name, t.DEAL_BATCH_NO,t.END_DEAL_NO, t2.user_id,tr.deal_code_name,t.db_card_no,"
						+ "to_char(t.db_amt/100, '9999999990.00') db_amt "
						/*+ " decode(t.deal_state,'0','正常','1','撤销','2','冲正','3','退货','9','灰记录','未知') "*/
						+ " from " + initsql + " t, base_merchant m,BASE_TAG_END t2,sys_code_tr tr "
						+ "  where t.acpt_id = m.merchant_id(+) and t.user_id = t2.end_id(+) and t.deal_code = tr.deal_code(+) and t.acpt_type = '0' and t.clr_date >= '" + Tools.processNull(o[0])
						+ "' and t.clr_date <= '" + Tools.processNull(o[1]) + "'  and t.clr_no in("+clrNo+")";
				
				
				String querySql = sql;
				
				
				List mxlist = null;
				if(!Tools.processNull(clrNo).equals("")){
					mxlist = merchantMangerService.findBySql(querySql);
				}
				
				// 第三行
				dgshhzlist.add(mxlist);
				// 第四行
				dgshhzlist.add(Tools.processNull(o[4]));// 总笔数
				// 第五行
				dgshhzlist.add(Tools.processNull(o[5]));// 总金额
				String feeSQL = "" ;
				String head = "select ";
				head += " ROW_NUMBER() over(order by merchant_id, stl_date) seq,merchant_name,merchant_id,stl_date,stl_way, " + 
						"nvl(bank_acc_no,'') bank_acc_no,sum(tot_deal_num) tr_num," + 
						SqlTools.divHundred("sum(tot_deal_amt)")+"tr_amt,"+
						SqlTools.divHundred("sum(deal_fee)")+" fee_amt,"+
						SqlTools.divHundred("sum(stl_amt)")+" stl_amt"+ 
						" from(select t.stl_date stl_date ,t1.bank_acc_no bank_acc_no,t.deal_num tot_deal_num,t.tot_deal_amt tot_deal_amt,t.deal_fee deal_fee,"+
						"t.stl_amt stl_amt,t.merchant_id merchant_id,t.stl_sum_no stl_sum_no,t1.merchant_name merchant_name,"+
						"(select decode(b1.fee_type,'1',trim(to_char(b1.fee_rate/10000,'99990.99'))||'元/笔','2',trim(to_char(b1.fee_rate/100,'99990.99'))||'%',to_char(0,'0.99')||'%') from pay_fee_rate b1,stl_deal_list b2 where b1.fee_rate_id (+) = b2.fee_rate_id  and b2.deal_code = '40201010' and b2.stl_sum_no = t.stl_sum_no and rownum<2)"+
						" stl_way ";
				htj = " from stl_deal_sum t, base_merchant t1,stl_mode t4 where t.merchant_id = t1.merchant_id(+) and t.merchant_id = t4.merchant_id  ";
				String mxtemp = "'";
				if(stlSumNo != null && stl_sum_nos.length > 0){
					for (String string : stl_sum_nos) {
						String[] sm = string.split(",");
						mxtemp += sm[0] + "','";
					}
					mxtemp = mxtemp.substring(0,mxtemp.length() - 2);
					htj += " and t.stl_Sum_No in (" + mxtemp + ")";
				}
				htj += " and t.merchant_id = '"+Tools.processNull(o[3])+"' and t.stl_date = '"+Tools.processNull(o[8])+"'";
				feeSQL = head + htj + " ) h group by merchant_name,merchant_id,stl_date,stl_way,bank_acc_no";
				List feeList = merchantMangerService.findBySql(feeSQL);
				Object[] aa =  null ;
				if(feeList != null && feeList.size() >0 ){
					Object[] bb = (Object[])feeList.get(0);
					aa = new Object[]{Tools.processNull(bb[4])};
				}else{
					aa = new Object[]{"0.00%"};
				}
				// 第六行
				dgshhzlist.add(Tools.processNull(aa[0]));// 费率
				// 第七行
				dgshhzlist.add(Tools.processNull(o[6]));// 手续费
				// 第八行
				dgshhzlist.add(Tools.processNull(o[7]));// 结算金额

				shhztoexcellist.add(dgshhzlist);
			}
			/**
			 * excel为标准格式 : 第一行为：商户名称+结算时间 合并10个空格，居中 11号宋体，加粗
			 * 第二行为："交易时间","商户编号"
			 * ,"商户名称","交易批次号","交易流水号","终端号","交易名称","卡号","交易金额","记录状态"， 居中10号宋体
			 * 第三行为：交易明细 居中10号宋体 第四行为：正常总笔数居中10号宋体 第五行为：正常总金额居中10号宋体
			 * 第六行为：手续费费率居中10号宋体 第七行为：手续费居中10号宋体 第八行为：应付金额居中10号宋体
			 */
			HSSFWorkbook workbook = new HSSFWorkbook();
			HSSFSheet sheet = workbook.createSheet();
			sheet.setFitToPage(true);
			// 设置宽度
			/*sheet.setColumnWidth((short) 0, (short) 3000);
			sheet.setColumnWidth((short) 1, (short) 3000);
			sheet.setColumnWidth((short) 2, (short) 5000);
			sheet.setColumnWidth((short) 3, (short) 2200);
			sheet.setColumnWidth((short) 4, (short) 2200);
			sheet.setColumnWidth((short) 5, (short) 2000);
			sheet.setColumnWidth((short) 6, (short) 2000);
			sheet.setColumnWidth((short) 7, (short) 2000);
			sheet.setColumnWidth((short) 8, (short) 2000);
			sheet.setColumnWidth((short) 9, (short) 2000);*/
			// 设置title样式
			HSSFFont font = workbook.createFont();// 字体
			font.setFontName("宋体");
			font.setFontHeightInPoints((short) 11);// 设置字体大小
			font.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD); // 字体加粗

			HSSFCellStyle setBorder = workbook.createCellStyle();// 样式
			setBorder.setAlignment(HSSFCellStyle.ALIGN_CENTER); // 居中
			setBorder.setFont(font);
			// 设置其他样式
			HSSFFont font2 = workbook.createFont();
			font2.setFontName("微软雅黑");
			font2.setFontHeightInPoints((short) 8);// 设置字体大小

			HSSFCellStyle setBorder2 = workbook.createCellStyle();// 样式
			setBorder2.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			setBorder2.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			setBorder2.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			setBorder2.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			setBorder2.setAlignment(HSSFCellStyle.ALIGN_CENTER); // 居中
			setBorder2.setVerticalAlignment(HSSFCellStyle.ALIGN_CENTER);
			setBorder2.setFont(font2);
			workbook.setSheetName(0, "商户结算报表");
			short i = 0;// 设置excel行数
			for (int t = 0; t < shhztoexcellist.size(); t++) {
				List o = (ArrayList) shhztoexcellist.get(t);
				for (int m = 0; m < o.size(); m++) {
					if (m == 0) {// 第一行为：商户名称+结算时间 合并10个空格，居中 11号宋体，加粗
						sheet.addMergedRegion(new Region(i, (short) 0, i,
								(short) 8));// 参数1：行号 参数2：起始列号 参数3：行号 参数4：终止列号
						HSSFRow row = sheet.createRow(i);
						i++;
						HSSFCell cell = row.createCell(0);
						cell.setCellStyle(setBorder);
						cell.setCellValue((String) o.get(m));
					} else if (m == 1) {// 第二行为："交易时间","商户编号","商户名称","交易批次号","交易流水号","终端号","交易名称","卡号","交易金额","记录状态"，
										// 居中10号宋体
						HSSFRow row = sheet.createRow(i);
						i++;
						String tt[] = (String[]) o.get(m);
						for (int dm = 0; dm < tt.length; dm++) {
							HSSFCell cell = row.createCell((short) dm);
							cell.setCellStyle(setBorder2);
							cell.setCellValue(tt[dm]);
						}
					} else if (m == 2) {
						List yy = (ArrayList) o.get(m);
						if(yy!=null){
							for (int dm = 0; dm < yy.size(); dm++) {
								HSSFRow row = sheet.createRow(i);
								i++;
								Object tt[] = (Object[]) yy.get(dm);
								for (int dmm = 0; dmm < tt.length; dmm++) {
									HSSFCell cell = row.createCell((short) dmm);
									cell.setCellStyle(setBorder2);
									cell.setCellValue(Tools.processNull(tt[dmm]));
								}
							}
						}
					} else if (m == 3) {
						String sm = (String) o.get(m);
						HSSFRow row = sheet.createRow(i);
						i++;
						HSSFCell cell = row.createCell((short) 0);
						createnullcell(workbook, row, cell);
						cell.setCellStyle(setBorder2);
						cell.setCellValue("正常总笔数:");
						HSSFCell cell2 = row.createCell((short) 8);
						cell2.setCellStyle(setBorder2);
						cell2.setCellValue(sm);

					} else if (m == 4) {
						String sm = (String) o.get(m);
						HSSFRow row = sheet.createRow(i);
						i++;
						HSSFCell cell = row.createCell((short) 0);
						createnullcell(workbook, row, cell);
						cell.setCellStyle(setBorder2);
						cell.setCellValue("正常总金额");
						HSSFCell cell2 = row.createCell((short) 8);
						cell2.setCellStyle(setBorder2);
						cell2.setCellValue(sm);
					} else if (m == 5) {
						String sm = (String) o.get(m);
						HSSFRow row = sheet.createRow(i);
						i++;
						HSSFCell cell = row.createCell((short) 0);
						createnullcell(workbook, row, cell);
						cell.setCellStyle(setBorder2);
						cell.setCellValue("手续费费率");
						HSSFCell cell2 = row.createCell((short) 8);
						cell2.setCellStyle(setBorder2);
						cell2.setCellValue(sm);
					} else if (m == 6) {
						String sm = (String) o.get(m);
						HSSFRow row = sheet.createRow(i);
						i++;
						HSSFCell cell = row.createCell((short) 0);
						createnullcell(workbook, row, cell);
						cell.setCellStyle(setBorder2);
						cell.setCellValue("手续费");
						HSSFCell cell2 = row.createCell((short) 8);
						cell2.setCellStyle(setBorder2);
						cell2.setCellValue(sm);
					} else if (m == 7) {
						String sm = (String) o.get(m);
						HSSFRow row = sheet.createRow(i);
						i++;
						HSSFCell cell = row.createCell((short) 0);
						createnullcell(workbook, row, cell);
						cell.setCellStyle(setBorder2);
						cell.setCellValue("应付金额");
						HSSFCell cell2 = row.createCell((short) 8);
						cell2.setCellStyle(setBorder2);
						cell2.setCellValue(sm);
					}
				}
			}
			sheet.autoSizeColumn(0,true);
			sheet.autoSizeColumn(1,true);
			sheet.autoSizeColumn(2,true);
			sheet.autoSizeColumn(3,true);
			sheet.autoSizeColumn(4,true);
			sheet.autoSizeColumn(5,true);
			sheet.autoSizeColumn(6,true);
			sheet.autoSizeColumn(7,true);
			HSSFPrintSetup ps = sheet.getPrintSetup();
		    workbook.setRepeatingRowsAndColumns(0,-1,-1,0,1);
	        ps.setLandscape(true); //打印方向，true:横向，false:纵向
	        ps.setPaperSize(HSSFPrintSetup.A4_PAPERSIZE); //纸张
	        ps.setScale((short)100);//缩放比例
	        sheet.setPrintGridlines(true);
	        // sheet.setDisplayGridlines(false);
	        sheet.setMargin(HSSFSheet.BottomMargin, (double)0.3); //页边距（下）
	        sheet.setMargin(HSSFSheet.LeftMargin, (double)0.3); //页边距（左）
	        sheet.setMargin(HSSFSheet.RightMargin, (double)0.3); //页边距（右）
	        sheet.setMargin(HSSFSheet.TopMargin, (double)0.3); //页边距（上）
	        // workbook.setPrintArea(0, "$A$1:$G$102");//设置打印区域
	        // sheet.setAutobreaks(true);  
	        sheet.setHorizontallyCenter(true); //设置打印页面为水平居中
//		        sheet.setVerticallyCenter(true); //设置打印页面为垂直居中
			HttpServletResponse response = ServletActionContext.getResponse();
			String fileName = "商户结算明细";
			response.setContentType("application/ms-excel;charset=utf-8");
		    response.setHeader("Content-disposition", "attachment; filename="+ URLEncoder.encode(fileName,"UTF8") + ".xls");
		    OutputStream out = response.getOutputStream();
		    workbook.write(out);
		    out.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
	
	/**
	 * 商户结算月报和年报查询
	 * @return
	 */
	public String toSettlementReport(){
		JSONArray footer = new JSONArray();
		JSONObject ftotal = new JSONObject();
		ftotal.put("TOT_DEAL_NUM","0");
		ftotal.put("STL_AMT","0.00");
		ftotal.put("TOT_DEAL_AMT","0.00");
		ftotal.put("TH_AMT","0.00");
		ftotal.put("DEAL_FEE","0.00");
		ftotal.put("MERCHANT_NAME","本页信息统计：");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		try {
			if(Tools.processNull(queryType).equals("0")){
				String sql = makeTjSql();
				// 组装分页对象
				Page pages = merchantMangerService.pagingQuery(sql,page, rows);
				if(pages.getAllRs() != null){
					footer.add(ftotal);
					jsonObject.put("rows",pages.getAllRs());
					jsonObject.put("footer",footer);
					jsonObject.put("total", pages.getTotalCount());
				}
			}
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	
	/**
	 * 商户结算月报，日报查询
	 * @return
	 */
	public String printReport(){
		jsonObject.put("status", false);
		jsonObject.put("title", "错误信息");
		jsonObject.put("message", "");
		try{
			String title = "";
			String[] id = Tools.processNull(stlSumNo).split("\\|");//STL_SUM_NO, CARD_TYPE, ACC_KIND
/*			String sql = makeTjPrintSql();*/
			String sql="select t.stl_sum_no SETTLEID ,t.merchant_id merchant_id,"+
					"(select a.merchant_name from base_merchant a where a.merchant_id = t.merchant_id) merchant_name,"
					+ "(select code_name from sys_code b where b.code_type = 'STL_WAY' and b.code_value=t.stl_way) stl_way,t.stl_days stl_days,"+
					 "nvl(sum(t.tot_deal_num),0) tot_deal_num ,"+SqlTools.divHundred("nvl(sum(t.tot_deal_amt),0)")  +" tot_deal_amt,"+
					 SqlTools.divHundred("nvl(sum(t.deal_fee),0)") +","+ SqlTools.divHundred("sum(nvl(deal_fee,0))") +" deal_fee ,"+
					 SqlTools.divHundred("nvl(sum(t.th_amt),0)") +" th_amt,"+SqlTools.divHundred("nvl(sum(t.stl_amt),0) ") +
					" stl_amt "+
					" from stl_deal_sum t where 1=1 ";
			String tempSql="'";
			if(stlSumNo != null && id.length > 0){
				for (String string : id) {
					String[] sm = string.split(",");
					tempSql += sm[0] + "','";
				}
				tempSql = tempSql.substring(0,tempSql.length() - 2);
				sql += " and t.stl_Sum_No in (" + tempSql + ")";
			}
			sql+=" group by t.stl_sum_no, t.merchant_id, t.stl_date,t.stl_state,t.stl_way ,t.stl_days";
			if(Tools.processNull(this.getSort()).equals("")&&Tools.processNull(this.getOrder()).equals("")){
				sql +=" order by t.stl_date desc ";
			}
			String temp = "";
			
			if(!Tools.processNull(month).equals("")){
				title = "商户结算"+month+"月月报";
				temp = title;
			}else if(!Tools.processNull(year).equals("")){
				title = "商户结算"+year+"年年报";
				temp = title;
			}else{
				throw new CommonException("商户结算报表打印参数错误！");
			}
			BigDecimal count  = (BigDecimal)merchantMangerService.findOnlyFieldBySql("select count(1) from ("+sql+")");
			if(count.intValue()<=0){
				throw new CommonException("没有查询到商户结算数据，无法导出报表！");
			}
			//计算总金额,总笔数
			Object[] onerow= (Object[]) merchantMangerService.findOnlyRowBySql("select trim(nvl(sum(tot_deal_num),0)),"
														+"trim(to_char(nvl(sum(tot_deal_amt),0),'99999990.00'))"+","
														+"trim(to_char(nvl(sum(deal_fee),0),'99999990.00'))"+","
														+"trim(to_char(nvl(sum(th_amt),0),'99999990.00'))"+","
														+"trim(to_char(nvl(sum(stl_amt),0),'99999990.00')) "+" from ("+sql+")");
			Map reprortParam = new HashMap();
			reprortParam.put("p_Tr_Num", Tools.processNull(onerow[0]));
			reprortParam.put("p_Tr_Amt", ChangeRMB.praseUpcaseRMB(((Tools.processNull(onerow[1]).equals("0"))?"0.00":Tools.processNull(onerow[1]))));
			reprortParam.put("p_Tr_Fee", ChangeRMB.praseUpcaseRMB(((Tools.processNull(onerow[2]).equals("0"))?"0.00":Tools.processNull(onerow[2]))));
			reprortParam.put("p_Th_Amt", ChangeRMB.praseUpcaseRMB(((Tools.processNull(onerow[3]).equals("0"))?"0.00":Tools.processNull(onerow[3]))));
			reprortParam.put("p_Stl_Amt",ChangeRMB.praseUpcaseRMB(((Tools.processNull(onerow[4]).equals("0"))?"0.00":Tools.processNull(onerow[4]))));
			reprortParam.put("p_Title", title);
			reprortParam.put("p_Print_Time", DateUtil.formatDate(merchantMangerService.getDateBaseTime(),"yyyy-MM-dd HH:mm:ss") );
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setMessage(title+"报表");
			actionLog.setDealCode(999999);
			SysActionLog log = merchantMangerService.savePrintReport(actionLog, merchantMangerService.getUser(),null);
			ReportUtil rputil = new ReportUtil( ServletActionContext.getRequest(),ServletActionContext.getResponse());
            
			JRResultSetDataSource source = new JRResultSetDataSource(merchantMangerService.tofindResultSet(sql));
			byte[] pdfContent = rputil.exportPDFBYJRResset("", "/reportfiles/ShangHuJieSuanYB.jasper", reprortParam, source);
			merchantMangerService.saveSysReport(log, new JSONObject(), "",Constants.APP_REPORT_TYPE_PDF2,1l, "", pdfContent);
			jsonObject.put("status", true);
			jsonObject.put("title", "");
			jsonObject.put("actionNo", log.getDealNo());
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status", false);
			jsonObject.put("title", "错误信息");
			jsonObject.put("message", e.getMessage());
		}
		return this.JSONOBJ;
	}
	public String  makeTjSql(){
		String sql="select t.stl_sum_no SETTLEID,t.merchant_id merchant_id,"+
				"(select a.merchant_name from base_merchant a where a.merchant_id = t.merchant_id) merchant_name,"
				+ "(select code_name from sys_code b where b.code_type = 'STL_MODE' and b.code_value=t.stl_mode) stl_mode,"+
				 "sum(t.deal_num) tot_deal_num ,"+SqlTools.divHundred("sum(t.deal_amt)")  +" tot_deal_amt,"+
				 SqlTools.divHundred("sum(t.deal_fee)") + " deal_fee,"+
				 SqlTools.divHundred("sum(t.th_amt)") +" th_amt,"+SqlTools.divHundred("sum(t.stl_amt)") +
				" stl_amt,(select c.code_name from sys_code c where c.code_type ='STL_STATE' and c.code_value = t.stl_state) STL_STATE "+
				" from stl_deal_sum t where 1=1 ";
	
		if (!Tools.processNull(merchantId).equals("")) {
			sql += " and  (t.merchant_id in (select h.merchant_id from base_merchant h start with h.top_merchant_id ='"+ merchantId+"' connect by prior " +
					"h.merchant_id = h.top_merchant_id) or t.merchant_id ='"+merchantId+"')";
		}
		if (!Tools.processNull(month).equals("")) {
			sql += " and substr(t.stl_date,0,7)='" + month + "'";
		}
		if (!Tools.processNull(year).equals("")) {
			sql += " and substr(t.stl_date,0,4)='" + year + "'";
		}
		//0 未审核 1 已审核 2已导出 9 已支付
		if(!Tools.processNull(stlState).equals("")) {
			sql += " and t.stl_State = '" + stlState + "'";
		}
		sql+=" group by t.stl_sum_no, t.merchant_id, t.stl_date,t.stl_state,t.stl_way ,t.stl_mode,t.stl_days";
		if(Tools.processNull(this.getSort()).equals("")&&Tools.processNull(this.getOrder()).equals("")){
			sql +=" order by t.stl_date desc ";
		}
		return sql;
	}
	
	public String  makeTjPrintSql(){
		String sql="select t.stl_sum_no SETTLEID ,t.merchant_id merchant_id,"+
				"(select a.merchant_name from base_merchant a where a.merchant_id = t.merchant_id) merchant_name,"
				+ "(select code_name from sys_code b where b.code_type = 'STL_WAY' and b.code_value=t.stl_way) stl_way,t.stl_days stl_days,"+
				 "nvl(sum(t.tot_deal_num),0) tot_deal_num ,"+SqlTools.divHundred("nvl(sum(t.tot_deal_amt),0)")  +" tot_deal_amt,"+
				 SqlTools.divHundred("nvl(sum(t.deal_fee),0)") +","+ SqlTools.divHundred("sum(nvl(deal_fee,0))") +" deal_fee ,"+
				 SqlTools.divHundred("nvl(sum(t.th_amt),0)") +" th_amt,"+SqlTools.divHundred("nvl(sum(t.stl_amt),0) ") +
				" stl_amt "+
				" from stl_deal_sum t where 1=1 ";
	
		if (!Tools.processNull(merchantId).equals("")) {
			sql += " and  (t.merchant_id in (select h.merchant_id from base_merchant h start with h.top_merchant_id ='"+ merchantId+"' connect by prior " +
					"h.merchant_id = h.top_merchant_id) or t.merchant_id ='"+merchantId+"')";
		}
		if (!Tools.processNull(month).equals("")) {
			sql += " and substr(t.stl_date,0,7)='" + month + "'";
		}
		if (!Tools.processNull(year).equals("")) {
			sql += " and substr(t.stl_date,0,4)='" + year + "'";
		}
		//0 未审核 1 已审核 2已导出 9 已支付
		if(!Tools.processNull(stlState).equals("")) {
			sql += " and t.stl_State = '" + stlState + "'";
		}
		sql+=" group by t.stl_sum_no, t.merchant_id, t.stl_date,t.stl_state,t.stl_way ,t.stl_days";
		if(Tools.processNull(this.getSort()).equals("")&&Tools.processNull(this.getOrder()).equals("")){
			sql +=" order by t.stl_date desc ";
		}
		return sql;
	}

	public String merSettleImmediate(){
		try {
			jsonObject.put("status",0);

			if(Tools.processNull(merchantId).equals("")){
				throw new CommonException("没有选择商户.");
			}
			
			merchantMangerService.saveMerSettleImmediate(merchantId, getUsers());
			
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String queryMerchantClrSumData(){
		try {
			jsonObject.put("rows",new JSONArray());
			jsonObject.put("total",0);
			jsonObject.put("status",0);
			jsonObject.put("errMsg",0);
			
			if (Tools.processNull(startDate).equals("")) {
				throw new CommonException("清分起始日期不能为空.");
			} else if (Tools.processNull(endDate).equals("")) {
				throw new CommonException("清分结束日期不能为空.");
			}
			
			String sql = "select t2.merchant_name, t3.deal_code_name, "
					+ "(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.card_type) card_type_name, "
					+ "(select code_name from sys_code where code_type = 'ACC_KIND' and code_value = t.acc_kind) acc_kind_name, t.* "
					+ "from pay_clr_sum t "
					+ "join base_merchant t2 on t.merchant_id = t2.merchant_id ";
			
			if(!Tools.processNull(merchantId).equals("")){
				sql += "and t2.merchant_id = '" + merchantId + "' ";
			}
			if(!Tools.processNull(merchantName).equals("")){
				sql += "and t2.merchant_name like '%" + merchantName + "%' ";
			}
			if(!Tools.processNull(startDate).equals("")){
				sql += "and t.clr_date >= '" + startDate + "' ";
			}
			if(!Tools.processNull(endDate).equals("")){
				sql += "and t.clr_date <= '" + endDate + "' ";
			}
			if(!Tools.processNull(dealCode).equals("")){
				sql += "and t.deal_code = '" + dealCode + "' ";
			}
			if(!Tools.processNull(cardType).equals("")){
				sql += "and t.card_type = '" + cardType + "' ";
			}
			if(!Tools.processNull(accKind).equals("")){
				sql += "and t.acc_kind = '" + accKind + "' ";
			}
			if("0".equals(stlState)){
				sql += "and t.stl_flag = '0' ";
			} else if("1".equals(stlState)){
				sql += "and (t.stl_flag is null or t.stl_flag <> '0') ";
			}
			
			sql += "join sys_code_tr t3 on t.deal_code = t3.deal_code ";
			
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort;
				
				if(!Tools.processNull(order).equals("")){
					sql += " " + order;
				}
			} else {
				sql += "order by t.clr_no desc";
			}
			
			Page pageData = merchantMangerService.pagingQuery(sql, page, rows);
			
			if (pageData == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommonException("没有数据.");
			}
			
			jsonObject.put("total", pageData.getTotalCount());
			jsonObject.put("rows", pageData.getAllRs());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		
		return JSONOBJ;
	}
	
	
	public String validExportMerchantClrSumData(){
		try {
			if (Tools.processNull(startDate).equals("")) {
				throw new CommonException("清分起始时间不能为空.");
			} else if (Tools.processNull(endDate).equals("")) {
				throw new CommonException("清分结束时间不能为空.");
			} else if (startDate.compareTo(endDate) > 0) {
				throw new CommonException("清分起始时间不能大于清分结束时间.");
			}
			
			BaseMerchant merchant = null;
			if (!Tools.processNull(merchantId).equals("")) {
				merchant = (BaseMerchant) merchantMangerService.findOnlyRowByHql("from BaseMerchant where merchantId = '" + merchantId + "'");
				
				if(merchant == null){
					throw new CommonException("商户不存在.");
				}
			}
			
			String sql = "select t.clr_no, t2.merchant_id, t2.merchant_name, t3.deal_code_name, "
					+ "(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.card_type) card_type_name, "
					+ "(select code_name from sys_code where code_type = 'ACC_KIND' and code_value = t.acc_kind) acc_kind_name, trim(t.deal_num) deal_num,"
					+ "trim(to_char(t.deal_amt/100, '9999999990.00')) deal_amt,t.clr_date,decode(t.stl_flag,'0','是','否'),t.stl_date "
					+ "from pay_clr_sum t "
					+ "join base_merchant t2 on t.merchant_id = t2.merchant_id ";
			
			if(!Tools.processNull(merchantId).equals("")){
				sql += "and t2.merchant_id = '" + merchantId + "' ";
			}
			if(!Tools.processNull(merchantName).equals("")){
				sql += "and t2.merchant_name like '%" + merchantName + "%' ";
			}
			if(!Tools.processNull(startDate).equals("")){
				sql += "and t.clr_date >= '" + startDate + "' ";
			}
			if(!Tools.processNull(endDate).equals("")){
				sql += "and t.clr_date <= '" + endDate + "' ";
			}
			if(!Tools.processNull(dealCode).equals("")){
				sql += "and t.deal_code = '" + dealCode + "' ";
			}
			if(!Tools.processNull(cardType).equals("")){
				sql += "and t.card_type = '" + cardType + "' ";
			}
			if(!Tools.processNull(accKind).equals("")){
				sql += "and t.acc_kind = '" + accKind + "' ";
			}
			if("0".equals(stlState)){
				sql += "and t.stl_flag = '0' ";
			} else if("1".equals(stlState)){
				sql += "and (t.stl_flag is null or t.stl_flag <> '0') ";
			}
			
			sql += "join sys_code_tr t3 on t.deal_code = t3.deal_code ";
			
			String countSql = "select sum(deal_num),to_char(sum(deal_amt), '9999999990.00') from (" + sql + ") ";
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort;
				
				if(!Tools.processNull(order).equals("")){
					sql += " " + order;
				}
			} else {
				sql += "order by t.clr_no desc";
			}
			
			Page pageData = merchantMangerService.pagingQuery(sql, page, rows);
			
			if (pageData == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommonException("没有数据.");
			}
			
			Map<String, String> exp = new HashMap<String, String>();
			String fileName = (merchant != null && merchant.getMerchantName() != null ? merchant.getMerchantName() + "_" : "") 
					+ "商户交易清分汇总数据_(" + startDate + " ~ " + endDate + ")";

			String expid = "exp" + new Date().getTime();
			
			exp.put("fileName", fileName);
			exp.put("sql", sql);
			exp.put("countSql", countSql);
			exp.put("startDate", startDate);
			exp.put("endDate", endDate);
			
			HttpSession httpSession = request.getSession();
			httpSession.setAttribute(expid, exp);
			
			jsonObject.put("expid", expid);
			jsonObject.put("status", "0");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	
	@SuppressWarnings("unchecked")
	public String exportMerchantClrSumData(){
		try {
			if (expid == null || expid.trim().equals("")) {
				throw new CommonException("expid is null.");
			}
			
			HttpSession httpSession = request.getSession();
			Map<String, String> exp = (Map<String, String>) httpSession.getAttribute(expid);
			String sql = exp.get("sql");
			String sqlTotal = exp.get("countSql");
			String fileName = exp.get("fileName");
			startDate = exp.get("startDate");
			endDate = exp.get("endDate");
			httpSession.removeAttribute(expid);
			
			if (sql == null) {
				throw new CommonException("sql is null.");
			}
			
			List<Object[]> records = merchantMangerService.findBySql(sql);
			if (records == null || records.isEmpty()) {
				throw new CommonException("records is null.");
			}
			
			// 导出
			response.setContentType("application/ms-excel;charset=utf-8");
			String userAgent = request.getHeader("user-agent");
			if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
				response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
			} else {
				response.setHeader("Content-disposition", "attachment; filename=" + new String((fileName).getBytes("utf-8"), "iso8859-1") + ".xls");
			}
			OutputStream output = response.getOutputStream();

			WritableWorkbook wwb = Workbook.createWorkbook(output);
			WritableSheet sheet1 = wwb.createSheet("Sheet0", 0);
			sheet1.setColumnView(0, 6);
			sheet1.setColumnView(1, 10);
			sheet1.setColumnView(2, 18);
			sheet1.setColumnView(3, 18);
			sheet1.setColumnView(4, 18);
			sheet1.setColumnView(5, 10);
			sheet1.setColumnView(6, 12);
			sheet1.setColumnView(7, 10);
			sheet1.setColumnView(8, 10);
			sheet1.setColumnView(9, 12);
			sheet1.setColumnView(10, 12);
			sheet1.setColumnView(11, 12);

			// title
			WritableCellFormat titleCellFormat = new WritableCellFormat();
			titleCellFormat.setAlignment(Alignment.CENTRE);
			titleCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			WritableFont titleFontRecord = new WritableFont(WritableFont.ARIAL, 10, WritableFont.BOLD);
			titleCellFormat.setFont(titleFontRecord);
			titleCellFormat.setBackground(Colour.GRAY_25);
			
			sheet1.mergeCells(0, 0, 11, 0);
			Label labelHead = new Label(0, 0, fileName);
			labelHead.setCellFormat(titleCellFormat);
			sheet1.addCell(labelHead);
			
			sheet1.mergeCells(0, 1, 11, 1);
			Label labelHead01 = new Label(0, 1, "清分时间：" + startDate + " ~ " + endDate + "    导出时间：" + DateUtils.getNowTime());
			labelHead01.setCellFormat(titleCellFormat);
			sheet1.addCell(labelHead01);

			// head
			WritableCellFormat headCellFormat = new WritableCellFormat();
			headCellFormat.setAlignment(Alignment.CENTRE);
			headCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			WritableFont fontRecord = new WritableFont(WritableFont.ARIAL, 10, WritableFont.BOLD);
			headCellFormat.setFont(fontRecord);
			
			Label labelHead0 = new Label(0, 2, "");
			Label labelHead1 = new Label(1, 2, "清分编号");
			Label labelHead2 = new Label(2, 2, "商户编号");
			Label labelHead3 = new Label(3, 2, "商户名称");
			Label labelHead4 = new Label(4, 2, "交易名称");
			Label labelHead5 = new Label(5, 2, "卡类型");
			Label labelHead6 = new Label(6, 2, "账户种类");
			Label labelHead7 = new Label(7, 2, "笔数");
			Label labelHead8 = new Label(8, 2, "金额");
			Label labelHead9 = new Label(9, 2, "清分日期");
			Label labelHead10 = new Label(10, 2, "结算状态");
			Label labelHead11 = new Label(11, 2, "结算日期");
			
			labelHead0.setCellFormat(titleCellFormat);
			labelHead1.setCellFormat(titleCellFormat);
			labelHead2.setCellFormat(titleCellFormat);
			labelHead3.setCellFormat(titleCellFormat);
			labelHead4.setCellFormat(titleCellFormat);
			labelHead5.setCellFormat(titleCellFormat);
			labelHead6.setCellFormat(titleCellFormat);
			labelHead7.setCellFormat(titleCellFormat);
			labelHead8.setCellFormat(titleCellFormat);
			labelHead9.setCellFormat(titleCellFormat);
			labelHead10.setCellFormat(titleCellFormat);
			labelHead11.setCellFormat(titleCellFormat);
			
			sheet1.addCell(labelHead0);
			sheet1.addCell(labelHead1);
			sheet1.addCell(labelHead2);
			sheet1.addCell(labelHead3);
			sheet1.addCell(labelHead4);
			sheet1.addCell(labelHead5);
			sheet1.addCell(labelHead6);
			sheet1.addCell(labelHead7);
			sheet1.addCell(labelHead8);
			sheet1.addCell(labelHead9);
			sheet1.addCell(labelHead10);
			sheet1.addCell(labelHead11);

			// body
			WritableCellFormat whiteCellFormat = new WritableCellFormat();
			whiteCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			WritableCellFormat stripedCellFormat = new WritableCellFormat();
			stripedCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			stripedCellFormat.setBackground(Colour.GRAY_25);
			
			WritableCellFormat whiteAmtCellFormat = new WritableCellFormat();
			whiteAmtCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			whiteAmtCellFormat.setAlignment(Alignment.RIGHT);
			WritableCellFormat stripedAmtCellFormat = new WritableCellFormat();
			stripedAmtCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			stripedAmtCellFormat.setAlignment(Alignment.RIGHT);
			stripedAmtCellFormat.setBackground(Colour.GRAY_25);
			
			for (int i = 0; i < records.size(); i++) {
				WritableCellFormat rowCellFormat = whiteCellFormat;
				WritableCellFormat rowAmtCellFormat = whiteAmtCellFormat;
//				if (i % 2 == 0) {
//					rowCellFormat = WhiteCellFormat;
//				} else {
//					rowCellFormat = new WritableCellFormat();
//					rowCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
//					rowCellFormat.setBackground(Colour.GRAY_25);
//				}
				
				Label label0 = new Label(0, i + 3, i + 1 + "");
				Label label1 = new Label(1, i + 3, Tools.processNull(records.get(i)[0]).trim());
				Label label2 = new Label(2, i + 3, Tools.processNull(records.get(i)[1]).trim());
				Label label3 = new Label(3, i + 3, Tools.processNull(records.get(i)[2]).trim());
				Label label4 = new Label(4, i + 3, Tools.processNull(records.get(i)[3]).trim());
				Label label5 = new Label(5, i + 3, Tools.processNull(records.get(i)[4]).trim());
				Label label6 = new Label(6, i + 3, Tools.processNull(records.get(i)[5]).trim());
				Label label7 = new Label(7, i + 3, Tools.processNull(records.get(i)[6]).trim());
				Label label8 = new Label(8, i + 3, Tools.processNull(records.get(i)[7]).trim());
				Label label9 = new Label(9, i + 3, Tools.processNull(records.get(i)[8]).trim());
				Label label10 = new Label(10, i + 3, Tools.processNull(records.get(i)[9]).trim());
				Label label11 = new Label(11, i + 3, Tools.processNull(records.get(i)[10]).trim());
				

				label0.setCellFormat(rowCellFormat);
				label1.setCellFormat(rowCellFormat);
				label2.setCellFormat(rowCellFormat);
				label3.setCellFormat(rowCellFormat);
				label4.setCellFormat(rowCellFormat);
				label5.setCellFormat(rowCellFormat);
				label6.setCellFormat(rowAmtCellFormat);
				label7.setCellFormat(rowCellFormat);
				label8.setCellFormat(rowAmtCellFormat);
				label9.setCellFormat(rowCellFormat);
				label10.setCellFormat(rowCellFormat);
				label11.setCellFormat(rowCellFormat);

				sheet1.addCell(label0);
				sheet1.addCell(label1);
				sheet1.addCell(label2);
				sheet1.addCell(label3);
				sheet1.addCell(label4);
				sheet1.addCell(label5);
				sheet1.addCell(label6);
				sheet1.addCell(label7);
				sheet1.addCell(label8);
				sheet1.addCell(label9);
				sheet1.addCell(label10);
				sheet1.addCell(label11);
			}
			List<Object[]> recordtotlals = merchantMangerService.findBySql(sqlTotal);
			if (records == null || records.isEmpty()) {
				throw new CommonException("records is null.");
			}
			int totalnum = records.size() + 3;
			Label labet0 = new Label(0, totalnum, "合计：");
			Label labet1 = new Label(1, totalnum, "");
			Label labet2 = new Label(2, totalnum, "");
			Label labet3 = new Label(3, totalnum, "");
			Label labet4 = new Label(4, totalnum, "");
			Label labet5 = new Label(5, totalnum, "");
			Label labet6 = new Label(6, totalnum, "");
			Label labet7 = new Label(7, totalnum, Tools.processNull(recordtotlals.get(0)[0]));
			Label labet8 = new Label(8, totalnum, Tools.processNull(recordtotlals.get(0)[1]));
			Label labet9 = new Label(9, totalnum, "");
			Label labet10 = new Label(10, totalnum, "");
			Label labet11 = new Label(11, totalnum, "");
			WritableCellFormat rowCellFormat = whiteCellFormat;
			WritableCellFormat rowAmtCellFormat = whiteAmtCellFormat;
			labet0.setCellFormat(rowCellFormat);
			labet1.setCellFormat(rowCellFormat);
			labet2.setCellFormat(rowCellFormat);
			labet3.setCellFormat(rowCellFormat);
			labet4.setCellFormat(rowCellFormat);
			labet5.setCellFormat(rowCellFormat);
			labet6.setCellFormat(rowAmtCellFormat);
			labet7.setCellFormat(rowCellFormat);
			labet8.setCellFormat(rowAmtCellFormat);
			labet9.setCellFormat(rowCellFormat);
			labet10.setCellFormat(rowCellFormat);
			labet11.setCellFormat(rowCellFormat);
			
			sheet1.addCell(labet0);
			sheet1.addCell(labet1);
			sheet1.addCell(labet2);
			sheet1.addCell(labet3);
			sheet1.addCell(labet4);
			sheet1.addCell(labet5);
			sheet1.addCell(labet6);
			sheet1.addCell(labet7);
			sheet1.addCell(labet8);
			sheet1.addCell(labet9);
			sheet1.addCell(labet10);
			sheet1.addCell(labet11);

			wwb.write();
			wwb.close();
			output.flush();
			output.close();
		} catch (CommonException e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", "导出失败, " + e.getMessage());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", "导出失败, 系统异常[" + e.getMessage() + "]");
		}
		
		return JSONOBJ;
	}
	public static List<String> getMonths(String startDateStr, String endDateStr){
		try {
			List<String> months = new ArrayList<String>();
			
			Calendar clrStartDate = Calendar.getInstance();
			clrStartDate.setTime(DateUtil.formatDate(startDateStr));
			
			Calendar clrEndDate = Calendar.getInstance();
			clrEndDate.setTime(DateUtil.formatDate(endDateStr));
			
			while(clrStartDate.compareTo(clrEndDate)<=0){
				months.add(DateUtil.formatDate(clrStartDate.getTime(), "yyyyMM"));
				clrStartDate.add(Calendar.MONTH, 1);
			}
			
			if(months.isEmpty()){
				throw new CommonException("清分日期月份为空.");
			}
			
			return months;
		} catch (Exception e) {
			throw new CommonException("获取清分日期月份异常, " + e.getMessage());
		}
	}
	
	public void createnullcell(HSSFWorkbook workbook, HSSFRow row, HSSFCell cell) {
		// 设置其他样式
		HSSFFont font2 = workbook.createFont();// 字体
		font2.setFontName("宋体");
		font2.setFontHeightInPoints((short) 10);// 设置字体大小

		HSSFCellStyle setBorder2 = workbook.createCellStyle();// 样式
		setBorder2.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
		setBorder2.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
		setBorder2.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
		setBorder2.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
		setBorder2.setAlignment(HSSFCellStyle.ALIGN_CENTER); // 居中
		setBorder2.setFont(font2);

		cell = row.createCell((short) 1);
		cell.setCellStyle(setBorder2);
		cell = row.createCell((short) 2);
		cell.setCellStyle(setBorder2);
		cell = row.createCell((short) 3);
		cell.setCellStyle(setBorder2);
		cell = row.createCell((short) 4);
		cell.setCellStyle(setBorder2);
		cell = row.createCell((short) 5);
		cell.setCellStyle(setBorder2);
		cell = row.createCell((short) 6);
		cell.setCellStyle(setBorder2);
		cell = row.createCell((short) 7);
		cell.setCellStyle(setBorder2);
		cell = row.createCell((short) 8);
		cell.setCellStyle(setBorder2);
	}
	
	public String toCardOrgBindSectionManage(){
		try {
			Page data = merchantMangerService.pagingQuery("select distinct bind_section \"value\", bind_section \"text\" from card_org_bind_section", rows, page);
			sectionData = data.getAllRs().toJSONString();
		} catch (Exception e) {
			sectionData = "[]";
		}
		return "cardOrgBindSectionManage";
	}
	
	/**
	 * @author Yueh
	 * @return
	 */
	public String queryOrgBindSection(){
		try {
			initBaseDataGrid();
			String sql = "select t.*, t2.merchant_name from card_org_bind_section t left join base_merchant t2 on t.acpt_id = t2.merchant_id where 1 = 1 ";
			if(!Tools.processNull(bindSection.getCardOrgId()).equals("")){
				sql +="and t.card_org_id = '" + bindSection.getCardOrgId() + "' ";
			}
			if(!Tools.processNull(bindSection.getBindSection()).equals("")){
				sql +="and t.bind_section = '" + bindSection.getBindSection() + "' ";
			}
			if(!Tools.processNull(bindSection.getState()).equals("")){
				sql +="and t.state = '" + bindSection.getState() + "' ";
			}
			if (!Tools.processNull(sort).equals("")) {
				sql += "order by " + sort + " ";
				if (!Tools.processNull(order).equals("")) {
					sql += order;
				}
			}
			Page data = merchantMangerService.pagingQuery(sql, page, rows);
			if (data == null || data.getAllRs() == null || data.getAllRs().isEmpty()) {
				throw new CommonException("根据条件找不到发卡方信息！");
			}
			System.out.println(data.getAllRs().size());
			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String addCardOrgBindSection(){
		try {
			merchantMangerService.saveAddCardOrgBindSection(bindSection, merchantMangerService.getCurrentActionLog());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String merSettlePayInfo(){
		try {
			initBaseDataGrid();
			String sql = "select merchant_id, merchant_name, sum(tot_deal_num) yjs_num, sum(tot_deal_amt) yjs_amt, "
					+ "sum(decode(stl_state, 9, tot_deal_num, 0)) yzf_num, sum(decode(stl_state, 9, tot_deal_amt, 0)) yzf_amt, "
					+ "sum(decode(stl_state, 9, 0, tot_deal_num)) wzf_num, sum(decode(stl_state, 9, 0, tot_deal_amt)) wzf_amt, "
					+ "max(decode(stl_state, 9, vrf_date)) last_pay_time from stl_deal_sum where 1 = 1 ";
			if (!Tools.processNull(merchantId).equals("")) {
				sql += "and merchant_id = '" + merchantId + "' ";
			}
			if (!Tools.processNull(startDate).equals("")) {
				sql += "and stl_date >= '" + startDate + "' ";
			}
			if (!Tools.processNull(endDate).equals("")) {
				sql += "and stl_date <= '" + endDate + "' ";
			}
			sql += "group by merchant_id, merchant_name ";
			if (!Tools.processNull(sort).equals("")) {
				sql += "order by " + sort;
				if (!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			} else {
				sql += "order by merchant_id";
			}
			Page data = baseService.pagingQuery(sql, page, rows);
			if (data == null || data.getAllRs() == null || data.getAllRs().isEmpty()) {
				throw new CommonException("根据条件查询不到数据！");
			}
			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	@Autowired
	public void setMerchantMangerService(MerchantMangerService merchantMangerService) {
		this.merchantMangerService = merchantMangerService;
	}
	
	public String getMerchantId() {
		return merchantId;
	}
	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}
	
	public String getStartDate() {
		return startDate;
	}

	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}

	public String getEndDate() {
		return endDate;
	}

	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}

	public String getAccKind() {
		return accKind;
	}

	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}

	public String getStlState() {
		return stlState;
	}
	public void setStlState(String stlState) {
		this.stlState = stlState;
	}
	public String getStlWay() {
		return stlWay;
	}
	public void setStlWay(String stlWay) {
		this.stlWay = stlWay;
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

	public String getStlSumNo() {
		return stlSumNo;
	}

	public void setStlSumNo(String stlSumNo) {
		this.stlSumNo = stlSumNo;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	public String getBankSheetNo() {
		return bankSheetNo;
	}

	public void setBankSheetNo(String bankSheetNo) {
		this.bankSheetNo = bankSheetNo;
	}

	public String getMonth() {
		return month;
	}

	public void setMonth(String month) {
		this.month = month;
	}

	public String getYear() {
		return year;
	}

	public void setYear(String year) {
		this.year = year;
	}

	public String getExpid() {
		return expid;
	}

	public void setExpid(String expid) {
		this.expid = expid;
	}

	public String getSectionData() {
		return sectionData;
	}

	public void setSectionData(String sectionData) {
		this.sectionData = sectionData;
	}

	public CardOrgBindSection getBindSection() {
		return bindSection;
	}

	public void setBindSection(CardOrgBindSection bindSection) {
		this.bindSection = bindSection;
	}
}
