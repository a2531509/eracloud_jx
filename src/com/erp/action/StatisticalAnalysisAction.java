package com.erp.action;

import java.io.OutputStream;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.DataFormat;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.ss.util.RegionUtil;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.shiro.SecurityUtils;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseCorp;
import com.erp.model.CardBlack;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.service.BaseService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

@SuppressWarnings("serial")
@Namespace("/statistical")
@Action("statisticalAnalysisAction")
@InterceptorRef("jsondefalut")
@Results({
	@Result(name="bankBindQueryMain",location="/jsp/statistics/bankBindStatMain.jsp"),
	@Result(name="bankBindDetailMain",location="/jsp/statistics/bankBindDetailMain.jsp")
})
public class StatisticalAnalysisAction extends BaseAction{
	public Logger log = Logger.getLogger(StatisticalAnalysisAction.class);
	private TrServRec rec = new TrServRec();
	private CardBlack cardBlaack = new CardBlack();
	private SysActionLog sysLog = new SysActionLog();
	private BaseCorp baseCorp =  new BaseCorp();
	private String queryType;
	private String beginTime;
	private String endTime;
	private String branchId;
	private String userId;
	private String reportTitle;
	private String sort;
	private String order;
	private String timeRange = "0";// 0 当日,1本周,2本月,3本年
	private String accKind;
	private String cardNo;
	private String cardType;
	private String dealNo;
	private String acptType;
	private String coOrgId;
	private String endSerNo;
	private String dealCode;
	private String bankIds;
	private boolean cascadeBrch;
	private String branchIds;
	private String bankId;
	private String clrStartDate;
	private String clrEndDate;
	private String applyState = "20";
	
	public String getAllDealCodes(){
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("select (");
			sb.append("case substr(t.deal_code,1,4) ");
			sb.append("when '1010' then '客户管理服务类' ");
			sb.append("when '1020' then '商户管理服务类' ");
			sb.append("when '1030' then '合作机构管理服务类' ");
			sb.append("when '1040' then '设备管理类' ");
			sb.append("when '1050' then '库房类' ");
			sb.append("when '1060' then '现金类' ");
			sb.append("when '1080' then '信息发布类' ");
			sb.append("when '1090' then '其他' ");
			sb.append("when '2010' then '产品规划类' ");
			sb.append("when '2020' then '采购类' ");
			sb.append("when '2030' then '生产类' ");
			sb.append("when '2040' then '申领发放类' ");
			sb.append("when '2050' then '服务类' ");
			sb.append("when '2060' then 'Psam卡管理类' ");
			sb.append("when '2090' then '其他' ");
			sb.append("when '3010' then '现金充值类' ");
			sb.append("when '3020' then '支票充值类' ");
			sb.append("when '3030' then '银行卡充值类' ");
			sb.append("when '3040' then '第三方账户充值类' ");
			sb.append("when '3050' then '充值卡充值类' ");
			sb.append("when '3090' then '其他' ");
			sb.append("when '4010' then '脱机账户消费类' ");
			sb.append("when '4020' then '联机账户消费类' ");
			sb.append("when '4030' then '终端管理类' ");
			sb.append("when '4090' then '其他' ");
			sb.append("when '5010' then '账户信息管理类' ");
			sb.append("when '5020' then '账户状态管理类' ");
			sb.append("when '5030' then '账户调整类' ");
			sb.append("when '5040' then '账户消费额度' ");
			sb.append("when '5050' then '账户状态管理类' ");
			sb.append("when '5080' then '柜员现金管理类' ");
			sb.append("when '5090' then '其他' ");
			sb.append("when '6010' then '日终扎帐类' ");
			sb.append("when '6020' then '商户清分对账类' ");
			sb.append("when '6030' then '商户结算类' ");
			sb.append("when '6040' then '合作机构清分对账类' ");
			sb.append("when '6050' then '合作机构结算类' ");
			sb.append("when '6060' then '差错及争议处理类' ");
			sb.append("when '6070' then '积分管理类' ");
			sb.append("else '其他' ");
			sb.append("end) GCODE,t.deal_code CODE_VALUE,");
			sb.append("t.deal_code_name || '【' || t.deal_code || '】' CODE_NAME ");
			sb.append("from SYS_CODE_TR t WHERE t.state = '0' order by t.deal_code asc");
			Page l = baseService.pagingQuery(sb.toString(),1,1000);
		    JSONArray j = new JSONArray();
		    JSONObject de = new JSONObject();
		    de.put("CODE_VALUE","");
		    de.put("CODE_NAME","请选择");
		    j.add(de);
			if(l.getAllRs() != null && l.getAllRs().size() > 0){
				j.addAll(l.getAllRs());
			}
			response.setCharacterEncoding("UTF-8");
			response.setContentType("text/html");
			PrintWriter p = this.response.getWriter();
			p.write(j.toString());
			p.flush();
			p.close();
		}catch(Exception e){
			log.error(e);
		}
		return null;
	}
	/**
	 * 柜面业务凭证查询
	 */
	public String voucherQuery(){
		try{
			this.initBaseDataGrid();
			if(!Tools.processNull(queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select t.deal_no,t.rp_titile,decode(t.format,'0','PDF','2','文件','未知') format,");
			sb.append("c.brch_id,c.full_name,b.user_id,b.name,");
			sb.append("to_char(t.deal_date,'yyyy-mm-dd hh24:mi:ss') dealTime ");
			sb.append("from sys_report t,sys_users b,sys_branch c ");
			sb.append("where t.user_id = b.user_id and b.brch_id = c.brch_id ");
			if(!Tools.processNull(beginTime).equals("")){
				sb.append(" and to_char(t.deal_date,'yyyy-mm-dd hh24:mi:ss') >= '" + beginTime + "' ");
			}
			if(!Tools.processNull(endTime).equals("")){
				sb.append(" and to_char(t.deal_date,'yyyy-mm-dd hh24:mi:ss') <= '" + endTime + "' ");
			}
			if(!Tools.processNull(this.dealNo).equals("")){
				sb.append(" and t.deal_no = " + dealNo + " ");
			}
			if(!Tools.processNull(reportTitle).equals("")){
				sb.append(" and t.rp_titile like '%" + reportTitle + "%' ");
			}
			if(!Tools.processNull(branchId).equals("")){
				sb.append(" and c.brch_id = '" + branchId + "' ");
			}
			if(!Tools.processNull(userId).equals("")){
				sb.append(" and b.user_Id = '" + userId + "' ");
			}
			sb.append(baseService.getLimitQueryData("c.brch_id","t.user_id"));
			if(!Tools.processNull(sort).equals("")){
				sb.append(" order by " + sort + " " + order + " ");
			}else{
				sb.append(" order by t.deal_no  desc");
			}
			Page pages = baseService.pagingQuery(sb.toString(),page,rows);
			if(pages.getAllRs() == null || pages.getAllRs().size() <= 0){
				throw new CommonException("根据指定信息未查询到对应的凭证信息！");
			}else{
				jsonObject.put("rows",pages.getAllRs());
				jsonObject.put("total",pages.getTotalCount());
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 柜面业务查询
	 * @return
	 */
	public String businessQuery(){
		try{
			this.initBaseDataGrid();
			if(!Tools.processNull(queryType).equals("0")){
				return this.JSONOBJ;
			}
			String dealNoSql = "";
			if(!Tools.processNull(bankIds).equals("")){
				String[] dealNoArr = bankIds.split(",");
				if (dealNoArr != null && dealNoArr.length > 0) {
					for (String dealNo : dealNoArr) {
						dealNoSql += "'" + dealNo + "',";
					}
					dealNoSql = dealNoSql.substring(0, dealNoSql.length() - 1);
				}
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select t.deal_no deal_no1,t.deal_no,r.deal_code_name,t.customer_id,nvl((select name from base_personal where customer_id = t.customer_id),(select corp_name from base_corp where customer_id = t.customer_id)) customer_name,(select h.code_name from Sys_code h where h.code_type = 'CERT_TYPE' and h.code_value = t.cert_type) cert_type,t.cert_no,");
			sb.append("(select h.code_name from sys_code h where h.code_type = 'CARD_TYPE' and h.code_value = t.card_type) card_type,t.card_no,to_char(t.biz_time,'yyyy-mm-dd hh24:mi:ss') biz_time,");
			sb.append("nvl(c.full_name, t.brch_id) full_name,nvl(b.name, t.user_id) name,t.clr_date,decode(t.deal_state,'0','正常','1','撤销','9','灰记录','2','冲正','其他') deal_state,t.note,t.old_card_no,t.old_deal_no, nvl(t.prv_bal, 0) prv_bal,  ");
			sb.append("nvl(t.amt, 0) amt,t.card_tr_count,t.grt_user_id,t.grt_user_name,t.agt_cert_no,t.agt_name,t.agt_tel_no,decode(t.acpt_type,'0','商户','1','柜面','2','合作机构','3','自助','4','电话','5','网站','6','商场','柜面') acpttype,t.co_org_id,t.term_id,t.end_deal_no,");
			sb.append("(select f.co_org_name from base_co_org f where f.co_org_id = t.co_org_id) co_org_name,(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = t.agt_cert_type ) agt_cert_type,(select code_name from sys_code where code_type = 'ACC_KIND' and code_value = t.acc_kind ) acckind ");
			sb.append("from tr_serv_rec t,sys_users b,sys_branch c,sys_code_tr r ");
			sb.append("where t.brch_id = c.brch_id(+) and t.user_id = b.user_id(+) and t.deal_code = r.deal_code(+) ");
			//01
			if(!Tools.processNull(rec.getCardNo()).equals("")){
				sb.append(" and t.card_no = '" + rec.getCardNo() + "' ");
			}
			if(!Tools.processNull(rec.getCardType()).equals("")){
				sb.append(" and t.card_type = '" + rec.getCardType() + "' ");
			}
			if(!Tools.processNull(rec.getCertNo()).equals("")){
				sb.append(" and t.cert_no = '" + rec.getCertNo() + "' ");
			}
			if(!Tools.processNull(rec.getCertType()).equals("")){
				sb.append(" and t.cert_type = '" + rec.getCertType() + "' ");
			}
			//02
			if(!Tools.processNull(rec.getOldCardNo()).equals("")){
				sb.append(" and t.old_card_no = '" + rec.getOldCardNo() + "' ");
			}
			if(!Tools.processNull(rec.getOldDealNo()).equals("")){
				sb.append(" and t.old_deal_no = '" + rec.getOldDealNo() + "' ");
			}
			if(!Tools.processNull(beginTime).equals("")){
				sb.append(" and to_char(t.biz_time,'yyyymmddhh24miss') >= '" + beginTime + "' ");
			}
			if(!Tools.processNull(endTime).equals("")){
				sb.append(" and to_char(t.biz_time,'yyyymmddhh24miss') <= '" + endTime + "' ");
			}
			//03
			if(!Tools.processNull(branchId).equals("")){
				sb.append(" and c.brch_id = '" + branchId + "' ");
			}
			if(!Tools.processNull(this.userId).equals("")){
				sb.append(" and b.user_Id = '" + userId + "' ");
			}
			if(!Tools.processNull(rec.getCoOrgId()).equals("")){
				sb.append(" and t.co_org_id = '" + rec.getCoOrgId() + "' ");
			}
			//04
			if(!Tools.processNull(rec.getDealCode()).equals("")){
				sb.append(" and t.deal_code = '" + rec.getDealCode() + "' ");
			}
			if(!Tools.processNull(rec.getDealNo()).equals("")){
				sb.append(" and t.deal_no = " + rec.getDealNo() + " ");
			} else if(!Tools.processNull(dealNoSql).equals("")){
				sb.append(" and t.deal_no in (" + dealNoSql + ") ");
			}
			if(!Tools.processNull(rec.getDealState()).equals("")){
				sb.append(" and t.deal_state = '" + rec.getDealState() + "' ");
			}
			sb.append(baseService.getLimitQueryData("t.brch_id","t.user_id"));
			if(!Tools.processNull(sort).equals("")){
				sb.append(" order by " + sort + " " + order + " ");
			}else{
				sb.append(" order by t.deal_no desc");
			}
			Page pages = baseService.pagingQuery(sb.toString(),page,rows);
			if(pages.getAllRs() == null || pages.getAllRs().size() <= 0){
				throw new CommonException("根据指定条件未查询到对应记录！");
			}else{
				jsonObject.put("rows",pages.getAllRs());
				jsonObject.put("total",pages.getTotalCount());
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String exportBusinessInfo(){
		try {
			businessQuery();
			String fileName = "业务日志导出";
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");

			// workbook
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);

			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 6000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 3000);
			sheet.setColumnWidth(4, 3000);
			sheet.setColumnWidth(5, 6000);
			sheet.setColumnWidth(6, 3000);
			sheet.setColumnWidth(7, 6000);
			sheet.setColumnWidth(8, 4000);
			sheet.setColumnWidth(9, 4000);
			sheet.setColumnWidth(10, 4000);
			sheet.setColumnWidth(11, 3000);
			sheet.setColumnWidth(12, 6000);
			sheet.setColumnWidth(13, 6000);
			sheet.setColumnWidth(14, 3000);
			sheet.setColumnWidth(15, 3000);
			sheet.setColumnWidth(16, 3000);
			sheet.setColumnWidth(17, 3000);
			sheet.setColumnWidth(18, 3000);
			sheet.setColumnWidth(19, 3000);
			sheet.setColumnWidth(21, 3000);
			sheet.setColumnWidth(22, 6000);
			sheet.setColumnWidth(26, 6000);
			sheet.setColumnWidth(29, 10000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

			// moneyCellStyle
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));

			// cellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);
			// headCellStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
			// headCellStyle.setFillForegroundColor(HSSFColor.LEMON_CHIFFON.index);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			// head row 1
			int maxColumn = 30;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}

			sheet.getRow(0).getCell(0).setCellValue(fileName);

			// second header
			sheet.getRow(1).getCell(0).setCellValue("业务时间：" + DateUtil.formatDate(beginTime, "yyyy-MM-dd HH:mm:ss") + " ~ " + DateUtil.formatDate(endTime, "yyyy-MM-dd HH:mm:ss") + "    导出时间：" + DateUtils.getNowTime());

			// third header
			sheet.getRow(2).getCell(0).setCellValue("流水号");
			sheet.getRow(2).getCell(1).setCellValue("业务名称");
			sheet.getRow(2).getCell(2).setCellValue("客户编号");
			sheet.getRow(2).getCell(3).setCellValue("客户姓名");
			sheet.getRow(2).getCell(4).setCellValue("证件类型");
			sheet.getRow(2).getCell(5).setCellValue("证件号码");
			sheet.getRow(2).getCell(6).setCellValue("卡号");
			sheet.getRow(2).getCell(7).setCellValue("卡号");
			sheet.getRow(2).getCell(8).setCellValue("账户类型");
			sheet.getRow(2).getCell(9).setCellValue("交易序列号");
			sheet.getRow(2).getCell(10).setCellValue("交易前金额");
			sheet.getRow(2).getCell(11).setCellValue("交易金额");
			sheet.getRow(2).getCell(12).setCellValue("办理时间");//
			sheet.getRow(2).getCell(13).setCellValue("办理网点");
			sheet.getRow(2).getCell(14).setCellValue("柜员");
			sheet.getRow(2).getCell(15).setCellValue("合作机构编号");
			sheet.getRow(2).getCell(16).setCellValue("合作机构名称");
			sheet.getRow(2).getCell(17).setCellValue("终端编号");
			sheet.getRow(2).getCell(18).setCellValue("终端流水");
			sheet.getRow(2).getCell(19).setCellValue("业务授权人编号");
			sheet.getRow(2).getCell(20).setCellValue("业务授权人");
			sheet.getRow(2).getCell(21).setCellValue("清分日起");
			sheet.getRow(2).getCell(22).setCellValue("老卡卡号");//
			sheet.getRow(2).getCell(23).setCellValue("原始流水");
			sheet.getRow(2).getCell(24).setCellValue("状态");
			sheet.getRow(2).getCell(25).setCellValue("代理人证件类型");
			sheet.getRow(2).getCell(26).setCellValue("代理人证件号码");
			sheet.getRow(2).getCell(27).setCellValue("代理人姓名");
			sheet.getRow(2).getCell(28).setCellValue("代理人联系方式");
			sheet.getRow(2).getCell(29).setCellValue("备注");

			//
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(6, 3);
			int numSum = 0;
			double amtSum = 0;
			for (int i = 0; i < data.size(); i++, numSum++) {
				JSONObject item = data.getJSONObject(i);

				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j == 10 || j == 9) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}

				row.getCell(0).setCellValue(item.getString("DEAL_NO"));
				row.getCell(1).setCellValue(item.getString("DEAL_CODE_NAME"));
				row.getCell(2).setCellValue(item.getString("CUSTOMER_ID"));
				row.getCell(3).setCellValue(item.getString("CUSTOMER_NAME"));
				row.getCell(4).setCellValue(item.getString("CERT_TYPE"));
				row.getCell(5).setCellValue(item.getString("CERT_NO"));
				row.getCell(6).setCellValue(item.getString("CARD_TYPE"));
				row.getCell(7).setCellValue(item.getString("CARD_NO"));
				row.getCell(8).setCellValue(item.getString("ACCKIND"));
				row.getCell(9).setCellValue(item.getString("CARD_TR_COUNT"));
				row.getCell(10).setCellValue(item.getDoubleValue("PRV_BAL") / 100);
				row.getCell(11).setCellValue(item.getDoubleValue("AMT") / 100);
				row.getCell(12).setCellValue(item.getString("BIZ_TIME"));
				row.getCell(13).setCellValue(item.getString("FULL_NAME"));
				row.getCell(14).setCellValue(item.getString("NAME"));
				row.getCell(15).setCellValue(item.getString("CO_ORG_ID"));
				row.getCell(16).setCellValue(item.getString("CO_ORG_NAME"));
				row.getCell(17).setCellValue(item.getString("TERM_ID"));
				row.getCell(18).setCellValue(item.getString("END_DEAL_NO"));
				row.getCell(19).setCellValue(item.getString("GRT_USER_ID"));
				row.getCell(20).setCellValue(item.getString("GRT_USER_NAME"));
				row.getCell(21).setCellValue(item.getString("CLR_DATE"));
				row.getCell(22).setCellValue(item.getString("OLD_CARD_NO"));
				row.getCell(23).setCellValue(item.getString("OLD_DEAL_NO"));
				row.getCell(24).setCellValue(item.getString("DEAL_STATE"));
				row.getCell(25).setCellValue(item.getString("AGT_CERT_TYPE"));
				row.getCell(26).setCellValue(item.getString("AGT_CERT_NO"));
				row.getCell(27).setCellValue(item.getString("AGT_NAME"));
				row.getCell(28).setCellValue(item.getString("AGT_TEL_NO"));
				row.getCell(29).setCellValue(item.getString("NOTE"));

				amtSum += item.getDoubleValue("AMT");
			}

			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if (j == 10 || j == 11) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(2).setCellValue("统计：");
			row.getCell(3).setCellValue("共 " + numSum + " 笔");
			row.getCell(11).setCellValue(amtSum / 100);
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * 柜面业务量统计
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public String businessAmount(){
		jsonObject.put("status","0");
		jsonObject.put("msg","");
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("select t.deal_code,(select d.deal_code_name from sys_code_tr d where d.deal_code = t.deal_code) codeName,");
			sb.append("count(1) totNum,trim(to_char(sum(nvl(c.amt,0))/100,'999,9999,999,999,990.99')) totAmt ");
			sb.append("from tr_serv_rec t,sys_code_tr s,cash_box_rec c ");
			sb.append("where t.deal_code = s.deal_code and t.deal_no = c.deal_no(+) ");
			//本日
			if(Tools.processNull(this.timeRange).equals("0")){
				sb.append(" and t.clr_date = '" + baseService.getClrDate() + "' ");
			}
			//本周
			if(Tools.processNull(this.timeRange).equals("1")){
				sb.append(" and t.clr_date >= '" + getFirstDayOfWeek(DateUtil.parse("yyyy-MM-dd",baseService.getClrDate())) + "' ");
				sb.append(" and t.clr_date <= '" + getLastDayOfWeek(DateUtil.parse("yyyy-MM-dd",baseService.getClrDate())) + "' ");
			}
			//本月
			if(Tools.processNull(this.timeRange).equals("2")){
				sb.append(" and t.clr_date >= '" + getFirstDayOfMonth(DateUtil.parse("yyyy-MM-dd",baseService.getClrDate())) + "' ");
				sb.append(" and t.clr_date <= '" + getLastDayOfMonth(DateUtil.parse("yyyy-MM-dd",baseService.getClrDate())) + "' ");
			}
			//本年
			if(Tools.processNull(this.timeRange).equals("3")){
				sb.append(" and t.clr_date >= '" + baseService.getClrDate().substring(0,4) + "-01-01" + "' ");
				sb.append(" and t.clr_date <= '" + baseService.getClrDate() + "' ");
			}
			sb.append(baseService.getLimitQueryData("t.brch_id","t.user_id"));
			sb.append("group by t.deal_code order by count(1) desc");
			List<Object[]> allDatas = baseService.findBySql(sb.toString());
			if(allDatas != null && allDatas.size() > 0){
				JSONArray dataList = new JSONArray();
				Long allNum = 0L;
				for (Object object : allDatas) {
					JSONObject temprow = new JSONObject();
					Object[] onerow = (Object[]) object;
					temprow.put("label",onerow[1]);
					//temprow.put("vLine","true");
					temprow.put("value",onerow[2]);
					allNum += ((BigDecimal)onerow[2]).longValue();
					dataList.add(temprow);
				}
				String titleName = "";
				if(Tools.processNull(this.timeRange).equals("0")){
					titleName = "（当日）";
				}else if(Tools.processNull(this.timeRange).equals("1")){
					titleName = "（本周）";
				} else if(Tools.processNull(this.timeRange).equals("2")){
					titleName = "（本月）";
				}else if(Tools.processNull(this.timeRange).equals("3")){
					titleName = "（本年）";
				}
				JSONObject captions = new JSONObject();
				captions.put("caption",Constants.APP_REPORT_TITLE + titleName + "业务量汇总");
				captions.put("xAxisName","业务类型");//"subCaption": "Last month",
				//captions.put("baseFontColor","blue");
				captions.put("formatNumber","1");//value 数字格式化 999,999,990.99
				captions.put("numberSuffix"," 笔");//value 参数的后缀
				captions.put("formatNumberScale","1");//数字1,100 将会显示为 1.1K  "theme": "fint"
				captions.put("theme","fint");
				captions.put("showAxisLines","1");
				captions.put("showBorder","0");
				captions.put("bgColor","#FFFFFF");
				captions.put("canvasBgAlpha",0);
				//设置tooltip部分
				captions.put("toolTipBgColor","#000000");
				captions.put("toolTipColor","#ffffff");
				captions.put("toolTipBorderThickness","0");
				captions.put("toolTipBgAlpha","80");
				captions.put("toolTipBorderRadius","2");
				captions.put("toolTipPadding","5");
				captions.put("captionAlignment","center");// "captionAlignment":"left",
				captions.put("yAxisName","业务类型量：" + allDatas.size() + " , 业务总量：" + allNum + "（单位：笔）");
				JSONArray dataSet = new JSONArray();
				JSONObject dataItem = new JSONObject();
				dataItem.put("seriesname","当日");
				dataItem.put("data",dataList);
				dataSet.add(dataItem);
				jsonObject.put("chart",captions);
				jsonObject.put("dataset",dataSet);
			}
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 充值消费统计
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public String rechargeAndConsumeStatistics(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg","");
		JSONObject ftotal = new JSONObject();
		ftotal.put("ACC_KIND","笔数");
		ftotal.put("DEAL_DATE","0");
		ftotal.put("CARD_BAL","金额");
		ftotal.put("AMT","0.00");
		ftotal.put("DEAL_CODE","本页信息统计：");
		try{
			if(Tools.processNull(this.queryType).equals("0")){
				String dealNoSql = "";
				if(!Tools.processNull(bankIds).equals("")){
					String[] dealNoArr = bankIds.split(",");
					if (dealNoArr != null && dealNoArr.length > 0) {
						for (String dealNo : dealNoArr) {
							dealNoSql += "'" + dealNo + "',";
						}
						dealNoSql = dealNoSql.substring(0, dealNoSql.length() - 1);
					}
				}
				StringBuffer head = new StringBuffer();
				head.append("select t.deal_no deal_no1, t.deal_no,t.deal_batch_no,r.deal_code_name deal_code,t.customer_id,t.acc_name,"
						+ "(select s1.code_name from sys_code s1 where s1.code_type = 'SEX' and s1.code_value = b.gender ) gender,"
						+ "(select s2.code_name from sys_code s2 where s2.code_type = 'CERT_TYPE' and s2.code_value = b.cert_type ) cert_type,"
						+ "b.cert_no,"
						+ "(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_TYPE' and s3.code_value = t.card_type ) card_type,"
						+ "t.card_no,t.acc_no, t.acpt_id ACPT_ID,"
						+ "decode(t.acpt_type,'1',(select t1.full_name from Sys_Branch t1 WHERE t1.brch_id = t.acpt_id),'0',"
						+ "(SELECT t2.merchant_name from base_merchant t2 WHERE t2.merchant_id = t.acpt_id),'2',(SELECT CO_ORG_NAME from base_co_org WHERE co_org_id = t.acpt_id)) full_name,"
						+ "t.user_id USER_ID,decode(t.acpt_type,'1',(select t1.name from Sys_Users t1 WHERE t1.user_id =t.user_id),'0',"
						+ "(SELECT t2.end_name FROM base_tag_end t2 WHERE t2.end_id =t.user_id),t.user_id) NAME,"
						+ "(select s4.code_name from sys_code s4 where s4.code_type = 'ACC_KIND' and s4.code_value = t.acc_kind ) acc_kind,"
						+ "to_char(t.deal_date,'yyyy-mm-dd hh24:mi:ss') deal_Date,nvl(t.acc_bal, 0) card_bal,t.amt amt,t.end_deal_no,t.card_counter,t.rev_time,t.credit,decode(t.deal_state,'0','正常','1','撤销','2','冲正','3','退货','9','灰记录','其他') deal_state,t.insert_time,t.clr_date,t.note,t.posp_proc_state ");
				if(Tools.processNull(this.beginTime).equals("") && Tools.processNull(clrStartDate).equals("")){
					throw new CommonException("查询起始日期不能空！");
				}
				if(!Tools.processNull(this.beginTime).equals("") && !Tools.processNull(this.beginTime).matches("20[0-9]{2}-[0,1]{1}[0-9]{1}-[0,1,2,3]{1}[0-9]{1}")){
					throw new CommonException("查询起始日期格式不正确！正确格式为：YYYY-MM-DD");
				}
				if(Tools.processNull(this.endTime).equals("") && Tools.processNull(clrEndDate).equals("")){
					throw new CommonException("查询截止日期不能空！");
				}
				if(!Tools.processNull(this.endTime).equals("") && !Tools.processNull(this.endTime).matches("20[0-9]{2}-[0,1]{1}[0-9]{1}-[0,1,2,3]{1}[0-9]{1}")){
					throw new CommonException("查询截止日期格式不正确！正确格式为：YYYY-MM-DD");
				}
				String table_pre = "PAY_CARD_DEAL_REC_";
				List<String> allTabs = null;
				if(!Tools.processNull(this.beginTime).equals("") && !Tools.processNull(this.endTime).equals("")){
					allTabs = baseService.findBySql("select t.table_name from user_tables t where t.table_name between '" + table_pre + beginTime.substring(0,7).replaceAll("-","") + "' and '" + table_pre + endTime.substring(0,7).replaceAll("-","") + "'");
				} else if(!Tools.processNull(clrStartDate).equals("") && !Tools.processNull(clrEndDate).equals("")){
					allTabs = baseService.findBySql("select t.table_name from user_tables t where t.table_name between '" + table_pre + clrStartDate.substring(0,7).replaceAll("-","") + "' and '" + table_pre + clrEndDate.substring(0,7).replaceAll("-","") + "'");
				}
				if(allTabs == null || allTabs.size() <= 0){
					throw new CommonException("记录信息不存在！");
				}
				StringBuffer initsql = new StringBuffer();
				for (int i = 0; i < allTabs.size(); i++) {
					initsql.append("select * from ");
					initsql.append(allTabs.get(i));
					initsql.append(" union ");
				}
				StringBuffer finalsql = new StringBuffer();
				finalsql.append(head);
				finalsql.append("from (");
				finalsql.append(initsql.substring(0,initsql.length() - 6));
				finalsql.append(") t ,base_personal b , sys_code_tr r where t.customer_id = b.customer_id(+) and t.deal_code = r.deal_code(+) ");
				if(!Tools.processNull(this.acptType).equals("")){
					finalsql.append(" and t.acpt_type = '" + this.acptType + "' ");
				}
				if(Tools.processNull(acptType).equals("1")){
					finalsql.append(" and t.deal_code in ('30101010','30101011','30101020','30101021','30601020','30601021','30601030','30601031','30101100') ");
				} else if(Tools.processNull(acptType).equals("2")){
					finalsql.append(" and t.deal_code in ('30105010','30105011','30105020','30105021','30105030','30105040') ");
					finalsql.append(" and exists (select 1 from base_co_org where co_org_id = t.acpt_id) ");
				}
				if(!Tools.processNull(this.coOrgId).equals("")){
					finalsql.append(" and t.acpt_id = '" + this.coOrgId + "' ");
				}
				if(!Tools.processNull(this.cardNo).equals("")){
					finalsql.append(" and t.card_no = '" + this.cardNo + "' ");
				}
				if(!Tools.processNull(this.cardType).equals("")){
					finalsql.append(" and t.card_type = '" + this.cardType + "' ");
				}
				if(!Tools.processNull(this.accKind).equals("")){
					finalsql.append(" and t.acc_kind = '" + this.accKind + "' ");
				}
				if(!Tools.processNull(this.dealNo).equals("")){
					finalsql.append(" and t.deal_no = " + this.dealNo + " ");
				}
				if(!Tools.processNull(this.branchId).equals("")){
					if(cascadeBrch){
						finalsql.append("and t.acpt_id in (select brch_id from sys_branch start with brch_id = '" 
								+ branchId + "' connect by  prior sysbranch_id = pid) ");
					} else {
						finalsql.append(" and t.acpt_id = '" + this.branchId + "' ");
					}
				}
				if(!Tools.processNull(this.userId).equals("")){
					finalsql.append(" and t.user_id = '" + this.userId + "' ");
				}
				if(!Tools.processNull(this.beginTime).equals("")){
					finalsql.append(" and t.deal_date >= to_date('" + this.beginTime + "', 'yyyy-mm-dd') ");
				}
				if(!Tools.processNull(this.endTime).equals("")){
					finalsql.append(" and t.deal_date <= to_date('" + this.endTime + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ");
				}
				if(!Tools.processNull(clrStartDate).equals("")){
					finalsql.append(" and t.clr_date >= '" + clrStartDate + "' ");
				}
				if(!Tools.processNull(clrEndDate).equals("")){
					finalsql.append(" and t.clr_date <= '" + clrEndDate + "' ");
				}
				if(!Tools.processNull(endSerNo).equals("")){
					finalsql.append(" and t.end_deal_no = '" + endSerNo + "' ");
				}
				if(!Tools.processNull(dealCode).equals("")){
					finalsql.append(" and t.deal_code = '" + dealCode + "' ");
				}
				if(!Tools.processNull(dealNoSql).equals("")){
					finalsql.append(" and t.deal_no in (" + dealNoSql + ") ");
				}
				//2.排序
				if(Tools.processNull(this.sort).equals("")){
					finalsql.append(" order by t.deal_no desc");
				} else {
					finalsql.append(" order by " + this.sort + " " + this.order);
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
	
	
	
	
	
	public String exportCoOrgRechargeStatistics() {
		try {
			
			rechargeAndConsumeStatistics();
			
			String fileName = "合作机构充值明细";
			if(!Tools.processNull(coOrgId).equals("")){
				String coOrgName = (String) baseService.findOnlyFieldBySql("select co_org_name from base_co_org where co_org_id = '" + coOrgId + "'");
				fileName = coOrgName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 6000);
			sheet.setColumnWidth(3, 6000);
			sheet.setColumnWidth(4, 8000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 6000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 6000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 3000);
			sheet.setColumnWidth(11, 3000);
			sheet.setColumnWidth(12, 6000);
			sheet.setColumnWidth(13, 6000);
			sheet.setColumnWidth(14, 3000);
			sheet.setColumnWidth(15, 3000);
			sheet.setColumnWidth(16, 3000);
			sheet.setColumnWidth(17, 3000);
			sheet.setColumnWidth(18, 3000);
			sheet.setColumnWidth(19, 3000);
			sheet.setColumnWidth(20, 6000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

			// moneyCellStyle
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));
			
			// cellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			// head row 1
			int maxColumn = 21;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			sheet.getRow(1).getCell(0).setCellValue("业务时间：" + beginTime + " ~ " + endTime + "    导出时间：" + DateUtils.getNowTime());

			// second header
			sheet.getRow(2).getCell(0).setCellValue("流水号");
			sheet.getRow(2).getCell(1).setCellValue("批次号");
			sheet.getRow(2).getCell(2).setCellValue("业务名称");
			sheet.getRow(2).getCell(3).setCellValue("合作机构编号");
			sheet.getRow(2).getCell(4).setCellValue("合作机构名称");
			sheet.getRow(2).getCell(5).setCellValue("客户姓名");
			sheet.getRow(2).getCell(6).setCellValue("证件号码");
			sheet.getRow(2).getCell(7).setCellValue("卡类型");
			sheet.getRow(2).getCell(8).setCellValue("卡号");
			sheet.getRow(2).getCell(9).setCellValue("账户类型");
			sheet.getRow(2).getCell(10).setCellValue("交易前金额");
			sheet.getRow(2).getCell(11).setCellValue("交易金额");//
			sheet.getRow(2).getCell(12).setCellValue("交易时间");
			sheet.getRow(2).getCell(13).setCellValue("终端交易流水");
			sheet.getRow(2).getCell(14).setCellValue("卡交易序列号");
			sheet.getRow(2).getCell(15).setCellValue("柜员/终端编号");
			sheet.getRow(2).getCell(16).setCellValue("柜员/终端名称");
			sheet.getRow(2).getCell(17).setCellValue("清分日期");
			sheet.getRow(2).getCell(18).setCellValue("状态");
			sheet.getRow(2).getCell(19).setCellValue("对账状态");
			sheet.getRow(2).getCell(20).setCellValue("备注");
			
			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 20));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, 20));
			sheet.createFreezePane(5, 3);
			int numSum = 0;
			double amtSum = 0;
			for (int i = 0; i < data.size(); i++, numSum++) {
				JSONObject item = data.getJSONObject(i);
				
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j == 10 || j == 11) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				row.getCell(0).setCellValue(item.getString("DEAL_NO"));
				row.getCell(1).setCellValue(item.getString("DEAL_BATCH_NO"));
				row.getCell(2).setCellValue(item.getString("DEAL_CODE"));
				row.getCell(3).setCellValue(item.getString("ACPT_ID"));
				row.getCell(4).setCellValue(item.getString("FULL_NAME"));
				row.getCell(5).setCellValue(item.getString("ACC_NAME"));
				row.getCell(6).setCellValue(item.getString("CERT_NO"));
				row.getCell(7).setCellValue(item.getString("CARD_TYPE"));
				row.getCell(8).setCellValue(item.getString("CARD_NO"));
				row.getCell(9).setCellValue(item.getString("ACC_KIND"));
				row.getCell(10).setCellValue(item.getDoubleValue("CARD_BAL") / 100);
				row.getCell(11).setCellValue(item.getDoubleValue("AMT") / 100);
				row.getCell(12).setCellValue(item.getString("DEAL_DATE"));
				row.getCell(13).setCellValue(item.getString("END_DEAL_NO"));
				row.getCell(14).setCellValue(item.getString("CARD_COUNTER"));
				row.getCell(15).setCellValue(item.getString("USER_ID"));
				row.getCell(16).setCellValue(item.getString("NAME"));
				row.getCell(17).setCellValue(item.getString("CLR_DATE"));
				row.getCell(18).setCellValue(item.getString("DEAL_STATE"));
				row.getCell(19).setCellValue("0".equals(item.getString("POSP_PROC_STATE")) ? "对账平" : "对账不平");
				row.getCell(20).setCellValue(item.getString("NOTE"));
				
				amtSum += item.getDoubleValue("AMT");
			}
			
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if (j == 10 || j == 11) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(2).setCellValue("统计：");
			row.getCell(3).setCellValue("共 " + numSum + " 笔");
			row.getCell(11).setCellValue(amtSum / 100);
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportBrchRechargeStatistics() {
		try {
			if(cascadeBrch){
				cascadeBrch = false;
			}
			if(!cascadeBrch){
				cascadeBrch = true;
			}
			rechargeAndConsumeStatistics();
			
			String fileName = "";
			if(Tools.processNull(acptType).equals("1")){
				fileName = "网点充值明细";
			} else {
				fileName = "充值消费明细";
			}
			if(!Tools.processNull(branchId).equals("")){
				String brchName = (String) baseService.findOnlyFieldBySql("select full_name from sys_branch where brch_id = '" + branchId + "'");
				fileName = brchName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			String userAgent = request.getHeader("user-agent");
			if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
				response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
			} else {
				response.setHeader("Content-disposition", "attachment; filename=" + new String((fileName).getBytes("utf-8"), "iso8859-1") + ".xls");
			}
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 6000);
			sheet.setColumnWidth(3, 3000);
			sheet.setColumnWidth(4, 5000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 6000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 6000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 3000);
			sheet.setColumnWidth(11, 3000);
			sheet.setColumnWidth(12, 6000);
			sheet.setColumnWidth(13, 6000);
			sheet.setColumnWidth(14, 3000);
			sheet.setColumnWidth(15, 3000);
			sheet.setColumnWidth(16, 3000);
			sheet.setColumnWidth(17, 3000);
			sheet.setColumnWidth(18, 3000);
			sheet.setColumnWidth(19, 12000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

			// moneyCellStyle
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));
			
			// cellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);
			// headCellStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
			// headCellStyle.setFillForegroundColor(HSSFColor.LEMON_CHIFFON.index);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			// head row 1
			int maxColumn = 20;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			// second header
			sheet.getRow(1).getCell(0).setCellValue("业务时间：" + beginTime + " ~ " + endTime + "    导出时间：" + DateUtils.getNowTime());
			
			// third header
			sheet.getRow(2).getCell(0).setCellValue("流水号");
			sheet.getRow(2).getCell(1).setCellValue("批次号");
			sheet.getRow(2).getCell(2).setCellValue("业务名称");
			if(Tools.processNull(acptType).equals("1")){
				sheet.getRow(2).getCell(3).setCellValue("网点编号");
				sheet.getRow(2).getCell(4).setCellValue("网点名称");
			} else {
				sheet.getRow(2).getCell(3).setCellValue("受理点编号");
				sheet.getRow(2).getCell(4).setCellValue("受理点名称");
			}
			sheet.getRow(2).getCell(5).setCellValue("客户姓名");
			sheet.getRow(2).getCell(6).setCellValue("证件号码");
			sheet.getRow(2).getCell(7).setCellValue("卡类型");
			sheet.getRow(2).getCell(8).setCellValue("卡号");
			sheet.getRow(2).getCell(9).setCellValue("账户类型");
			sheet.getRow(2).getCell(10).setCellValue("交易前金额");
			sheet.getRow(2).getCell(11).setCellValue("交易金额");//
			sheet.getRow(2).getCell(12).setCellValue("交易时间");
			sheet.getRow(2).getCell(13).setCellValue("终端交易流水");
			sheet.getRow(2).getCell(14).setCellValue("卡交易序列号");
			sheet.getRow(2).getCell(15).setCellValue("柜员/终端编号");
			sheet.getRow(2).getCell(16).setCellValue("柜员/终端名称");
			sheet.getRow(2).getCell(17).setCellValue("清分日期");
			sheet.getRow(2).getCell(18).setCellValue("状态");
			sheet.getRow(2).getCell(19).setCellValue("备注");
			
			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(5, 3);
			int numSum = 0;
			double amtSum = 0;
			for (int i = 0; i < data.size(); i++, numSum++) {
				JSONObject item = data.getJSONObject(i);
				
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j == 10 || j == 11) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				row.getCell(0).setCellValue(item.getString("DEAL_NO"));
				row.getCell(1).setCellValue(item.getString("DEAL_BATCH_NO"));
				row.getCell(2).setCellValue(item.getString("DEAL_CODE"));
				row.getCell(3).setCellValue(item.getString("ACPT_ID"));
				row.getCell(4).setCellValue(item.getString("FULL_NAME"));
				row.getCell(5).setCellValue(item.getString("ACC_NAME"));
				row.getCell(6).setCellValue(item.getString("CERT_NO"));
				row.getCell(7).setCellValue(item.getString("CARD_TYPE"));
				row.getCell(8).setCellValue(item.getString("CARD_NO"));
				row.getCell(9).setCellValue(item.getString("ACC_KIND"));
				row.getCell(10).setCellValue(item.getDoubleValue("CARD_BAL") / 100);
				row.getCell(11).setCellValue(item.getDoubleValue("AMT") / 100);
				row.getCell(12).setCellValue(item.getString("DEAL_DATE"));
				row.getCell(13).setCellValue(item.getString("END_DEAL_NO"));
				row.getCell(14).setCellValue(item.getString("CARD_COUNTER"));
				row.getCell(15).setCellValue(item.getString("USER_ID"));
				row.getCell(16).setCellValue(item.getString("NAME"));
				row.getCell(17).setCellValue(item.getString("CLR_DATE"));
				row.getCell(18).setCellValue(item.getString("DEAL_STATE"));
				row.getCell(19).setCellValue(item.getString("NOTE"));
				
				amtSum += item.getDoubleValue("AMT");
			}
			
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if (j == 10 || j == 11) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(2).setCellValue("统计：");
			row.getCell(3).setCellValue("共 " + numSum + " 笔");
			row.getCell(11).setCellValue(amtSum / 100);
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * 黑名单查询
	 * @return
	 */
	public String cardBlackQuery(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg","");
		try{
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select r.deal_no,b.customer_id,b.name,b.cert_no,");
				sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CERT_TYPE' AND CODE_VALUE = b.cert_type) certtype,");
				sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CARD_TYPE' AND CODE_VALUE = a.card_type) cardtype,");
				sb.append("a.card_no,(CASE t.blk_state WHEN '0' THEN '有效' WHEN '1' THEN '无效' ELSE '未知' END) blkstate,");
				sb.append("(CASE t.blk_type WHEN '01' THEN '死亡' WHEN '02' THEN '挂失' WHEN '03' THEN '临时挂失' WHEN '04' THEN '应用锁定' WHEN '05' THEN '应用解锁' WHEN '99' THEN '注销' ELSE '未知' end) blktype,");
				sb.append("to_char(t.last_date,'yyyy-mm-dd hh24:mi:ss') lastdata,k.deal_code_name,");
				sb.append("(SELECT full_name from sys_branch where brch_id = c.brch_id) full_name,");
				sb.append("(SELECT name from sys_users where user_id = c.user_id) oname,c.clr_date,r.notes ");
				sb.append("from CARD_BLACK t,card_black_rec r,tr_serv_rec c,card_baseinfo a, base_personal b,sys_code_tr k ");
				sb.append("WHERE t.version = r.version AND r.deal_no = c.deal_no and c.deal_code = k.deal_code ");
				sb.append("AND t.card_no = a.card_no AND a.customer_id = b.customer_id(+) ");
				//01
				if(!Tools.processNull(rec.getCardNo()).equals("")){
					sb.append("and t.card_no = '" + rec.getCardNo() + "' ");
				}
				if(!Tools.processNull(rec.getCardType()).equals("")){
					sb.append("and a.card_type = '" + rec.getCardType() + "' ");
				}
				if(!Tools.processNull(cardBlaack.getBlkType()).equals("")){
					sb.append("and t.blk_type = '" + cardBlaack.getBlkType() + "' ");
				}
				//02
				if(!Tools.processNull(rec.getCertNo()).equals("")){
					sb.append("and b.cert_no = '" + rec.getCertNo() + "' ");
				}
				if(!Tools.processNull(rec.getCertType()).equals("")){
					sb.append("and b.cert_type = '" + rec.getCertType() + "' ");
				}
				if(!Tools.processNull(cardBlaack.getBlkState()).equals("")){
					sb.append("and t.blk_state = '" + cardBlaack.getBlkState() + "' ");
				}
				//03
				if(!Tools.processNull(this.beginTime).equals("")){
					sb.append("and t.last_date >= to_date('" + beginTime + "','yyyymmddhh24miss') ");
				}
				if(!Tools.processNull(this.endTime).equals("")){
					sb.append("and t.last_date <= to_date('" + endTime + "','yyyymmddhh24miss') ");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("未查询到记录信息");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 操作日志
	 * @return
	 */
	public String operLogQuery(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		try{
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT t.deal_no,t.deal_code,r.deal_code_name,t.org_id,o.org_name,t.co_org_id,");
				sb.append("c.co_org_name,t.brch_id,t.user_id,to_char(t.deal_time,'yyyy-mm-dd hh24:mi:ss') dealtime,");
				sb.append("t.func_url,t.func_name,t.message,t.ip,t.in_out_data,t.note,b.full_name,u.name ");
				sb.append("FROM SYS_ACTION_LOG t,Sys_Code_Tr r,base_co_org c,Sys_Organ o,sys_branch  b ,sys_users u ");
				sb.append("WHERE t.deal_code = r.deal_code(+) AND t.co_org_id = c.co_org_id(+) ");
				sb.append("AND t.org_id = o.org_id(+) and t.brch_id = b.brch_id and t.user_id = u.user_id ");
				if(!Tools.processNull(sysLog.getDealNo()).equals("")){
					sb.append("and t.deal_no = " + sysLog.getDealNo() + " ");
				}
				if(!Tools.processNull(sysLog.getDealCode()).equals("")){
					sb.append("and t.deal_code = '" + sysLog.getDealCode() + "' ");
				}
				if(!Tools.processNull(sysLog.getBrchId()).equals("")){
					sb.append("and t.brch_id = '" + sysLog.getBrchId() + "' ");
				}
				if(!Tools.processNull(sysLog.getUserId()).equals("")){
					sb.append("and t.user_id = '" + sysLog.getUserId() + "' ");
				}
				if(!Tools.processNull(sysLog.getCoOrgId()).equals("")){
					sb.append("and t.co_org_id = '" + sysLog.getCoOrgId() + "' ");
				}
				if(!Tools.processNull(this.accKind).equals("")){
					sb.append("and c.co_org_name like '%" + accKind + "%' ");
				}
				if(!Tools.processNull(this.beginTime).equals("")){
					sb.append("and t.deal_time >= to_date('" + beginTime + "','yyyymmddhh24miss') ");
				}
				if(!Tools.processNull(this.endTime).equals("")){
					sb.append("and t.deal_time <= to_date('" + endTime + "','yyyymmddhh24miss') ");
				}
				if(!Tools.processNull(sysLog.getIp()).equals("")){
					sb.append("and regexp_replace(t.ip,'\\D','') = '" + sysLog.getIp() + "' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("ORDER BY t.deal_no DESC ");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("未查询到对应操作日志信息");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 错误日志
	 * @return
	 */
	public String errLogQuery(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		try{
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select t.err_no,c.full_name,b.name,t.message messages,");
				sb.append("to_char(t.err_time,'yyyy-mm-dd hh24:mi:ss') errtime,t.ip ");
				sb.append("from SYS_ERR_LOG t,sys_users b,Sys_Branch c WHERE t.user_id = b.user_id ");
				sb.append("AND b.brch_id = c.brch_id ");
				if(!Tools.processNull(sysLog.getBrchId()).equals("")){
					sb.append("and c.brch_id = '" + sysLog.getBrchId() + "' ");
				}
				if(!Tools.processNull(sysLog.getUserId()).equals("")){
					sb.append("and t.user_id = '" + sysLog.getUserId() + "' ");
				}
				if(!Tools.processNull(this.beginTime).equals("")){
					sb.append("and t.err_time >= to_date('" + beginTime + "','yyyymmddhh24miss') ");
				}
				if(!Tools.processNull(this.endTime).equals("")){
					sb.append("and t.err_time <= to_date('" + endTime + "','yyyymmddhh24miss') ");
				}
				if(!Tools.processNull(sysLog.getIp()).equals("")){
					sb.append("and regexp_replace(t.ip,'\\D','') = '" + sysLog.getIp() + "' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("ORDER BY t.err_no DESC ");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("未查询到对应错误日志信息");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	public String bankBindQueryMain(){
		try{
			this.initBaseDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sql = new StringBuffer();
			sql.append("select b.bank_id,b.bank_name, nvl(t.bindnum,0) totbindnum,nvl(t7.bindnum,0) bindnum,nvl(t7.unbindnum,0) unbindnum ");
			sql.append("from base_bank b,");
			sql.append("    (select t3.bank_id,count(1) bindnum,sum(decode(t3.trcode,'unbind',1,0)) unbindnum from (");
			sql.append("         select t1.bank_id,'bind' trcode,t1.bind_date trdate from card_bind_bankcard t1 ");
			sql.append("         where 1  = 1");
			if(!Tools.processNull(rec.getRsvOne()).equals("")){
				sql.append("     and t1.bank_id = '" + rec.getRsvOne() + "' ");
			}
			sql.append("         union all ");
			sql.append("         select t2.bank_id,'unbind' trcode,t2.unbind_date trdate from card_unbind_bankcard t2 ");
			sql.append("         where 1 = 1 ");
			if(!Tools.processNull(rec.getRsvOne()).equals("")){
				sql.append("     and t2.bank_id = '" + rec.getRsvOne() + "' ");
			}
			sql.append("      ) t3 group by t3.bank_id) t,");
			sql.append("    (select t6.bank_id,sum(decode(t6.trcode,'bind',1,0)) bindnum,sum(decode(t6.trcode,'unbind',1,0)) unbindnum from (");
			sql.append("         select t4.bank_id,'bind' trcode,t4.bind_date trdate from card_bind_bankcard t4 ");
			sql.append("         where 1 = 1 ");
			if(!Tools.processNull(rec.getRsvOne()).equals("")){
				sql.append("     and t4.bank_id = '" + rec.getRsvOne() + "' ");
			}
			if(!Tools.processNull(this.beginTime).equals("")){
				sql.append("     and to_char(t4.bind_date,'yyyy-mm-dd') >= '" + this.beginTime + "' ");
			}
			if(!Tools.processNull(this.endTime).equals("")){
				sql.append("     and to_char(t4.bind_date,'yyyy-mm-dd') <= '" + this.endTime + "' ");
			}
			sql.append("         union all ");
			sql.append("         select t5.bank_id,'unbind' trcode,t5.unbind_date trdate from card_unbind_bankcard t5 ");
			sql.append("         where 1 = 1 ");
			if(!Tools.processNull(rec.getRsvOne()).equals("")){
				sql.append("     and t5.bank_id = '" + rec.getRsvOne() + "' ");
			}
			if(!Tools.processNull(this.beginTime).equals("")){
				sql.append("     and to_char(t5.unbind_date,'yyyy-mm-dd') >= '" + this.beginTime + "' ");
			}
			if(!Tools.processNull(this.endTime).equals("")){
				sql.append("     and to_char(t5.unbind_date,'yyyy-mm-dd') <= '" + this.endTime + "' ");
			}
			sql.append("  ) t6 group by t6.bank_id) t7 ");
			sql.append("where b.bank_id = t.bank_id(+) and b.bank_id = t7.bank_id(+) ");
			if(!Tools.processNull(rec.getRsvOne()).equals("")){
				sql.append("     and b.bank_id = '" + rec.getRsvOne() + "' ");
			}
			if(!Tools.processNull(this.sort).equals("")){
				sql.append("order by " + this.sort + " " + this.order);
			}else{
				sql.append("order by b.bank_id asc");
			}
			Page list = baseService.pagingQuery(sql.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("未查询到对应的绑定信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	public String bankBindQueryExport(){
		try{
			queryType = "0";
			this.page = 1;
			this.rows = 100000;
			this.bankBindQueryMain();
			if(!Tools.processNull(jsonObject.get("status")).equals("0")){
				throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
			}
			HSSFWorkbook book = new HSSFWorkbook();
			HSSFSheet sheet = book.createSheet();
			sheet.setFitToPage(true);
			//sheet.createFreezePane(3,4);
			CellRangeAddress titleRegion = new CellRangeAddress(0,0,0,5);
			titleRegion.formatAsString();
			sheet.addMergedRegion(titleRegion);
			CellStyle titleStyle = this.getCellStyleOfTitle(book);
			HSSFRow firstRow = sheet.createRow(0);
			firstRow.setHeight((short)(firstRow.getHeight() * 2));
			HSSFCell cell = firstRow.createCell(0);
			cell.setCellValue(Constants.APP_REPORT_TITLE + "银行卡绑定情况统计");
			cell.setCellStyle(titleStyle);
			HSSFFont headerFont = book.createFont();
			headerFont.setFontName("微软雅黑");
			headerFont.setBoldweight((short)(headerFont.getBoldweight()*2));
			headerFont.setFontHeight((short)(headerFont.getFontHeight()*0.9));
			headerFont.setColor(HSSFColor.BLUE.index);
			HSSFCellStyle headStyle = book.createCellStyle();
			headStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headStyle.setBorderRight(CellStyle.BORDER_THIN);
			headStyle.setBorderTop(CellStyle.BORDER_THIN);
			headStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headStyle.setFont(headerFont);
			CellRangeAddress region1 = new CellRangeAddress(1,1,0,5);
			region1.formatAsString();
			sheet.addMergedRegion(region1);
			HSSFRow dateRow = sheet.createRow(1);
			HSSFCell dateRow0 = dateRow.createCell(0);
			dateRow0.setCellValue("汇总周期：" + this.beginTime + " —— " + this.endTime + "  制表时间：" + DateUtil.formatDate(baseService.getDateBaseTime(),"yyyy-MM-dd HH:mm:ss"));
			dateRow0.setCellStyle(this.getCellStyleOfDateColumn(book));
			HSSFRow secRow = sheet.createRow(2);
			for(int d = 0;d <= 5; d++){
				secRow.createCell(d).setCellStyle(headStyle);
			}
			HSSFCell secCell0 = secRow.createCell(0);
			secCell0.setCellValue("序号");
			secCell0.setCellStyle(headStyle);
			HSSFCell secCell1 = secRow.createCell(1);
			secCell1.setCellValue("银行编号");
			secCell1.setCellStyle(headStyle);
			HSSFCell secCell2 = secRow.createCell(2);
			secCell2.setCellValue("银行名称");
			secCell2.setCellStyle(headStyle);
			HSSFCell secCell3 = secRow.createCell(3);
			secCell3.setCellValue("本周期内绑定数量");
			secCell3.setCellStyle(headStyle);
			HSSFCell secCell4 = secRow.createCell(4);
			secCell4.setCellValue("本周期内解绑数量");
			secCell4.setCellStyle(headStyle);
			HSSFCell secCell5 = secRow.createCell(5);
			secCell5.setCellValue("合计");
			secCell5.setCellStyle(headStyle);
			JSONArray rows =  this.jsonObject.getJSONArray("rows");
			int rowNum = 3;
			long totBindNum = 0L;
			long totUnBindNum = 0L;
			long totNum = 0L;
			CellStyle commonStyle = this.getCellStyleOfData(book);
			if(rows != null && rows.size() > 0){
				for (Object object : rows) {
					JSONObject tempRowData = (JSONObject) object;
					HSSFRow tempRow = sheet.createRow(rowNum);
					HSSFCell tempCell0 = tempRow.createCell(0);
					tempCell0.setCellValue(tempRowData.getString("V_V"));
					tempCell0.setCellStyle(commonStyle);
					HSSFCell tempCell1 = tempRow.createCell(1);
					tempCell1.setCellValue(tempRowData.getString("BANK_ID"));
					tempCell1.setCellStyle(commonStyle);
					HSSFCell tempCell2 = tempRow.createCell(2);
					tempCell2.setCellStyle(commonStyle);
					tempCell2.setCellValue(tempRowData.getString("BANK_NAME"));
					HSSFCell tempCell3 = tempRow.createCell(3);
					tempCell3.setCellStyle(commonStyle);
					tempCell3.setCellValue(tempRowData.getString("BINDNUM"));
					HSSFCell tempCell4 = tempRow.createCell(4);
					tempCell4.setCellStyle(commonStyle);
					tempCell4.setCellValue(tempRowData.getString("UNBINDNUM"));
					HSSFCell tempCell5 = tempRow.createCell(5);
					tempCell5.setCellStyle(commonStyle);
					tempCell5.setCellValue(tempRowData.getString("TOTBINDNUM"));
					totBindNum += Long.valueOf(tempRowData.getString("BINDNUM"));
					totUnBindNum += Long.valueOf(tempRowData.getString("UNBINDNUM"));
					totNum += Long.valueOf(tempRowData.getString("TOTBINDNUM"));
					rowNum++;
				}
			}
			CellRangeAddress tailRegion = new CellRangeAddress(rowNum,rowNum,0,2);
			tailRegion.formatAsString();
			setBorder(CellStyle.BORDER_THIN,tailRegion,sheet,book);
			sheet.addMergedRegion(tailRegion);
			HSSFRow tailRow = sheet.createRow(rowNum);
			HSSFCell tailCell0 = tailRow.createCell(0);
			tailCell0.setCellValue("总合计");
			tailCell0.setCellStyle(commonStyle);
			HSSFCell tailCell1 = tailRow.createCell(3);
			tailCell1.setCellStyle(commonStyle);
			tailCell1.setCellValue(totBindNum + "");
			HSSFCell tailCell2 = tailRow.createCell(4);
			tailCell2.setCellStyle(commonStyle);
			tailCell2.setCellValue(totUnBindNum + "");
			HSSFCell tailCell3 = tailRow.createCell(5);
			tailCell3.setCellStyle(commonStyle);
			tailCell3.setCellValue(totNum + "");
			HSSFCell tailCell4 = tailRow.createCell(1);
			tailCell4.setCellStyle(commonStyle);
			HSSFCell tailCell5 = tailRow.createCell(2);
			tailCell5.setCellStyle(commonStyle);
			sheet.autoSizeColumn(0,true);
			sheet.autoSizeColumn(1,true);
			sheet.autoSizeColumn(2,true);
			sheet.autoSizeColumn(3,true);
			sheet.autoSizeColumn(4,true);
			sheet.autoSizeColumn(5,true);
			OutputStream out = this.response.getOutputStream();
			this.response.setContentType("application/vnd.ms-excel");
			this.response.setCharacterEncoding("UTF-8");
			this.response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode( Constants.APP_REPORT_TITLE + "银行卡绑定情况统计（" + this.beginTime + "--" + this.endTime + "）", "UTF-8") + ".xls\"");
			book.write(out);
			SecurityUtils.getSubject().getSession().setAttribute("bankBindStatMain",Constants.YES_NO_YES);
			out.flush();
		}catch(Exception e){
			this.defaultErrorMsg = this.saveErrLog(e);
			return "bankBindQueryMain";
		}
		return null;
	}
	public String bankBindDetailQuery(){
		try{
			this.initBaseDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			String tempLimitSql = "";
			if(Tools.processNull(rec.getDealState()).equals("0") && !Tools.processNull(rec.getBrchId()).equals("")){
				//String limitBrchId = baseService.getNextLimitBrch(Tools.processNull(rec.getBrchId()));
				tempLimitSql = " and t.brch_id in (select q.brch_id from sys_branch q start with q.brch_id = '" + rec.getBrchId() + "' connect by prior q.sysbranch_id  =  q.pid) ";
				if(!Tools.processNull(rec.getUserId()).equals("") && !Tools.processNull(rec.getUserId()).equals("erp2_erp2")){
					if(Tools.processNull(baseService.getUser().getDutyId()).equals(Constants.SYS_OPERATOR_LEVEL_COMMON)){
						tempLimitSql += " and t.user_Id = '"  + Tools.processNull(rec.getUserId()) + "' ";
					}
				}
			}else{
				if(!Tools.processNull(rec.getBrchId()).equals("")){
					tempLimitSql += " and t.brch_Id = '"  + Tools.processNull(rec.getBrchId()) + "' ";
				}
				if(!Tools.processNull(rec.getUserId()).equals("") && !Tools.processNull(rec.getUserId()).equals("erp2_erp2")){
					tempLimitSql += " and t.user_Id = '"  + Tools.processNull(rec.getUserId()) + "' ";
				}
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select t.sub_card_id,t.name,t.cert_no,t.card_no,t.bank_id,b.bank_name, t.bank_card_no,");
			sb.append("to_char(t.bind_date,'yyyy-mm-dd hh24:mi:ss') binddate,t.brch_id,s.full_name,");
			sb.append("t.user_id,u.name username from card_bind_bankcard t,base_bank b,sys_branch s,sys_users u ");
			sb.append("where t.bank_id = b.bank_id(+) and t.brch_id = s.brch_id(+) and t.user_id = u.user_id(+) ");
			if(!Tools.processNull(rec.getCardNo()).equals("")){
				sb.append("and t.card_no = '" + rec.getCardNo() + "' ");
			}
			if(!Tools.processNull(rec.getCertNo()).equals("")){
				sb.append("and b.cert_no = '" + rec.getCertNo() + "' ");
			}
			if(!Tools.processNull(this.beginTime).equals("")){
				sb.append("and to_char(t.bind_date,'yyyy-mm-dd') >= '" + beginTime + "' ");
			}
			if(!Tools.processNull(this.endTime).equals("")){
				sb.append("and to_char(t.bind_date,'yyyy-mm-dd') <= '" + endTime + "' ");
			}
			if(!Tools.processNull(bankId).equals("")){
				sb.append("and t.bank_id = '" + bankId + "' ");
			}
			if(!Tools.processNull(tempLimitSql).equals("")){
				sb.append(tempLimitSql);
			}
			if(!Tools.processNull(this.sort).equals("")){
				sb.append("order by " + this.sort + " " + this.order);
			}else{
				sb.append("order by t.bind_date desc ");
			}
			Page list = baseService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
				jsonObject.put("totPages_01",list.getTotalPages());
			}else{
				throw new CommonException("未查询到对应的绑定信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	public String bankBindDetailExport(){
		try{
			queryType = "0";
			this.page = 1;
			this.rows = 10000;
			this.bankBindDetailQuery();
			if(!Tools.processNull(jsonObject.get("status")).equals("0")){
				throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
			}
			Workbook book = new SXSSFWorkbook(500);
			Sheet sheet = book.createSheet();
			sheet.setFitToPage(true);
			sheet.createFreezePane(1,3);
			CellRangeAddress titleRegion = new CellRangeAddress(0,0,0,8);
			titleRegion.formatAsString();
			sheet.addMergedRegion(titleRegion);
			CellStyle titleStyle = this.getCellStyleOfTitle(book);
			Row firstRow = sheet.createRow(0);
			firstRow.setHeight((short)(firstRow.getHeight() * 2));
			Cell cell = firstRow.createCell(0);
			cell.setCellValue(Constants.APP_REPORT_TITLE + "银行卡绑定业务明细");
			cell.setCellStyle(titleStyle);
			Font headerFont = book.createFont();
			headerFont.setFontName("微软雅黑");
			headerFont.setBoldweight((short)(headerFont.getBoldweight() * 2));
			headerFont.setFontHeight((short)(headerFont.getFontHeight() * 0.9));
			headerFont.setColor(HSSFColor.BLUE.index);
			CellStyle headStyle = book.createCellStyle();
			headStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headStyle.setBorderRight(CellStyle.BORDER_THIN);
			headStyle.setBorderTop(CellStyle.BORDER_THIN);
			headStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headStyle.setFont(headerFont);
			CellRangeAddress region1 = new CellRangeAddress(1,1,0,8);
			region1.formatAsString();
			sheet.addMergedRegion(region1);
			Row dateRow = sheet.createRow(1);
			Cell dateRow0 = dateRow.createCell(0);
			dateRow0.setCellValue("汇总周期：" + this.beginTime + " —— " + this.endTime + "  制表时间：" + DateUtil.formatDate(baseService.getDateBaseTime(),"yyyy-MM-dd HH:mm:ss"));
			dateRow0.setCellStyle(this.getCellStyleOfDateColumn(book));
			Row secRow = sheet.createRow(2);
			for(int d = 0;d <= 8; d++){
				secRow.createCell(d).setCellStyle(headStyle);
			}
			Cell secCell0 = secRow.createCell(0);
			secCell0.setCellValue("序号");
			secCell0.setCellStyle(headStyle);
			Cell secCell1 = secRow.createCell(1);
			secCell1.setCellValue("姓名");
			secCell1.setCellStyle(headStyle);
			Cell secCell2 = secRow.createCell(2);
			secCell2.setCellValue("证件号码");
			secCell2.setCellStyle(headStyle);
			Cell secCell3 = secRow.createCell(3);
			secCell3.setCellValue("市民卡卡号");
			secCell3.setCellStyle(headStyle);
			Cell secCell4 = secRow.createCell(4);
			secCell4.setCellValue("绑定银行");
			secCell4.setCellStyle(headStyle);
			Cell secCell5 = secRow.createCell(5);
			secCell5.setCellValue("银行账号");
			secCell5.setCellStyle(headStyle);
			Cell secCell6 = secRow.createCell(6);
			secCell6.setCellValue("绑定日期");
			secCell6.setCellStyle(headStyle);
			Cell secCell7 = secRow.createCell(7);
			secCell7.setCellValue("办理网点");
			secCell7.setCellStyle(headStyle);
			Cell secCell8 = secRow.createCell(8);
			secCell8.setCellValue("办理柜员");
			secCell8.setCellStyle(headStyle);
			JSONArray rows =  this.jsonObject.getJSONArray("rows");
			int totPages = this.jsonObject.getIntValue("totPages_01");
			int rowNum = 3;
			CellStyle commonStyle = this.getCellStyleOfData(book);
			while(this.page <= totPages){
				if(rows != null && rows.size() > 0){
					for (Object object : rows) {
						JSONObject tempRowData = (JSONObject) object;
						Row tempRow = sheet.createRow(rowNum);
						Cell tempCell0 = tempRow.createCell(0);
						tempCell0.setCellValue(tempRowData.getString("V_V"));
						tempCell0.setCellStyle(commonStyle);
						Cell tempCell1 = tempRow.createCell(1);
						tempCell1.setCellValue(tempRowData.getString("NAME"));
						tempCell1.setCellStyle(commonStyle);
						Cell tempCell2 = tempRow.createCell(2);
						tempCell2.setCellStyle(commonStyle);
						tempCell2.setCellValue(tempRowData.getString("CERT_NO"));
						Cell tempCell3 = tempRow.createCell(3);
						tempCell3.setCellStyle(commonStyle);
						tempCell3.setCellValue(tempRowData.getString("CARD_NO"));
						Cell tempCell4 = tempRow.createCell(4);
						tempCell4.setCellStyle(commonStyle);
						tempCell4.setCellValue(tempRowData.getString("BANK_NAME"));
						Cell tempCell5 = tempRow.createCell(5);
						tempCell5.setCellStyle(commonStyle);
						tempCell5.setCellValue(tempRowData.getString("BANK_CARD_NO"));
						Cell tempCell6 = tempRow.createCell(6);
						tempCell6.setCellStyle(commonStyle);
						tempCell6.setCellValue(tempRowData.getString("BINDDATE"));
						Cell tempCell7 = tempRow.createCell(7);
						tempCell7.setCellStyle(commonStyle);
						tempCell7.setCellValue(tempRowData.getString("FULL_NAME"));
						Cell tempCell8 = tempRow.createCell(8);
						tempCell8.setCellStyle(commonStyle);
						tempCell8.setCellValue(tempRowData.getString("USERNAME"));
						rowNum++;
						tempRowData = null;
					}
					rows = null;
				}
				this.page += 1;
				if(this.page <= totPages){
					this.bankBindDetailQuery();
					if(!Tools.processNull(jsonObject.get("status")).equals("0")){
						book = null;
						sheet = null;
						throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
					}
					rows =  this.jsonObject.getJSONArray("rows");
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
			sheet.autoSizeColumn(8,true);
			OutputStream out = this.response.getOutputStream();
			this.response.setContentType("application/vnd.ms-excel");
			this.response.setCharacterEncoding("UTF-8");
			this.response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode( Constants.APP_REPORT_TITLE + "银行卡绑定业务明细（" + this.beginTime + "--" + this.endTime + "）", "UTF-8") + ".xlsx\"");
			book.write(out);
			SecurityUtils.getSubject().getSession().setAttribute("bankBindDetailMain",Constants.YES_NO_YES);
			out.flush();
		}catch(Exception e){
			this.defaultErrorMsg = this.saveErrLog(e);
			return "bankBindDetailMain";
		}
		return null;
	}
	public String corpRechargeQuery(){
		try{
			if(Tools.processNull(this.beginTime).equals("")){
				throw new CommonException("请选择起始日期！");
			}
			if(Tools.processNull(this.endTime).equals("")){
				throw new CommonException("请选择结束日期！");
			}
			List<?> allTables = baseService.findBySql("select t.table_name from user_tables t where t.table_name >= 'ACC_INOUT_DETAIL_" + 
				Tools.processNull(this.beginTime).replaceAll("-","").substring(0,6) + "' and t.table_name <= 'ACC_INOUT_DETAIL_" + 
				Tools.processNull(this.endTime).replaceAll("-","").substring(0,6) + "' and t.table_name like 'ACC_INOUT_DETAIL_______' "
			);
			if(allTables == null || allTables.size() <= 0){
				throw new CommonException("查询日期范围超过期限，相关表信息不存在！");
			}
			String tables = "(";
			for(int i = 0;i < allTables.size();i++){
				tables += "select * from " + allTables.get(i) + " where deal_code = '" + DealCode.CORP_RECHARGE + 
				"' and clr_date >= '" + this.beginTime  + "' and clr_date <= '" + this.endTime + "' ";
				if(i != allTables.size() - 1){
					tables += "union all ";
				}
			}
			tables += ") t ";
			this.initBaseDataGrid();
			StringBuffer sb = new StringBuffer();
			sb.append("select t.acc_inout_no,t.cr_customer_id,nvl(t.cr_amt,0) amt,");
			sb.append("(select code_name from sys_code where code_type = 'ACC_KIND' and code_value = t.cr_acc_kind) accname,");
			sb.append("to_char(t.deal_date,'yyyy-mm-dd hh24:mi:ss') dealdate,t.acpt_id,s.full_name,t.user_id,u.name username,p.corp_name ");
			sb.append("from " + tables + ",base_corp p,sys_branch s,sys_users u ");
			sb.append("where t.cr_customer_id = p.customer_id ");
			sb.append("and t.deal_code = '" + DealCode.CORP_RECHARGE + "' and t.acpt_id = s.brch_id(+) and t.user_id = u.user_id(+) and t.deal_state = '0' ");
			if(!Tools.processNull(baseCorp.getCustomerId()).equals("")){
				sb.append("and t.cr_customer_id = '" + baseCorp.getCustomerId() + "' ");
			}
			if(!Tools.processNull(baseCorp.getCorpName()).equals("")){
				sb.append("and p.corp_name like '%" + baseCorp.getCorpName() + "%' ");
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
				throw new CommonException("未查询到单位充值信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	public String corpRechargeDetails(){
		try{
			if(Tools.processNull(this.beginTime).equals("")){
				throw new CommonException("请选择起始日期！");
			}
			if(Tools.processNull(this.endTime).equals("")){
				throw new CommonException("请选择结束日期！");
			}
			List<?> allTables = baseService.findBySql("select t.table_name from user_tables t where t.table_name >= 'ACC_INOUT_DETAIL_" + 
				Tools.processNull(this.beginTime).replaceAll("-","").substring(0,6) + "' and t.table_name <= 'ACC_INOUT_DETAIL_" + 
				Tools.processNull(this.endTime).replaceAll("-","").substring(0,6) + "' and t.table_name like 'ACC_INOUT_DETAIL_______' "
			);
			if(allTables == null || allTables.size() <= 0){
				throw new CommonException("查询日期范围超过期限，相关表信息不存在！");
			}
			String tables = "(";
			for(int i = 0;i < allTables.size();i++){
				tables += "select * from " + allTables.get(i) + " where deal_code = '" + DealCode.CORP_BATCH_RECHARGE + 
				"' and clr_date >= '" + this.beginTime  + "' and clr_date <= '" + this.endTime + "' ";
				if(i != allTables.size() - 1){
					tables += "union all ";
				}
			}
			tables += ") t ";
			this.initBaseDataGrid();
			StringBuffer sb = new StringBuffer();
			sb.append("select t.acc_inout_no,b.name,b.cert_no,c.card_no,nvl(t.cr_amt,0) amt,");
			sb.append("(select code_name from sys_code where code_type = 'ACC_KIND' and code_value = t.cr_acc_kind) accname,");
			sb.append("to_char(t.deal_date,'yyyy-mm-dd hh24:mi:ss') dealdate,t.acpt_id,s.full_name,t.user_id,u.name username,p.corp_name ");
			sb.append("from " + tables + ",card_baseinfo c,base_personal b,base_corp p,sys_branch s,sys_users u ");
			sb.append("where t.cr_card_no = c.card_no and c.customer_id = b.customer_id(+) and t.db_customer_id = p.customer_id ");
			sb.append("and t.deal_code = '" + DealCode.CORP_BATCH_RECHARGE + "' and t.acpt_id = s.brch_id(+) and t.user_id = u.user_id(+) and t.deal_state = '0' ");
			if(!Tools.processNull(rec.getCardNo()).equals("")){
				sb.append("and t.cr_card_no = '" + rec.getCardNo() + "' ");
			}
			if(!Tools.processNull(rec.getCertNo()).equals("")){
				sb.append("and b.cert_no = '" + rec.getCertNo() + "' ");
			}
			if(!Tools.processNull(baseCorp.getCustomerId()).equals("")){
				sb.append("and t.db_customer_id = '" + baseCorp.getCustomerId() + "' ");
			}
			if(!Tools.processNull(baseCorp.getCorpName()).equals("")){
				sb.append("and p.corp_name like '%" + baseCorp.getCorpName() + "%' ");
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
				throw new CommonException("未查询到单位充值明细信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	public String jrsbkFkStat(){
	    try{
	        this.initBaseDataGrid();
            String sql = "select t.bank_id, (select bank_name from base_bank where bank_id = t.bank_id) bank_name, "
            		+ "t.recv_brch_id, (select full_name from sys_branch where brch_id = t.recv_brch_id) recv_brch_name, count(1) tot_num, "
            		+ "sum(decode(t.is_urgent, '0', decode(t.apply_type, '0', 1, 0), 0)) bd_xfk, "
            		+ "sum(decode(t.is_urgent, '0', decode(t.apply_type, '0', 0, 1), 0)) bd_hfk, "
            		+ "sum(decode(t.is_urgent, '1', decode(t.apply_type, '0', decode(t.is_batch_hf, '0', 0, 1), 0), 0)) wb_xfk, "
            		+ "sum(decode(t.is_urgent, '1', decode(t.apply_type, '0', decode(t.is_batch_hf, '0', 1, 0), 1), 0)) wb_hfk "
            		+ "from card_apply t join card_apply_task t2 on t.task_id = t2.task_id left join card_task_batch t3 on t2.make_batch_id = t3.batch_id "
            		+ "where t.card_type = '120' "
            		+ "and (t.apply_type = '0' or not exists (select 1 from card_apply where card_no = (select card_no\n" +
					"                   from card_baseinfo\n" +
					"                  where customer_id = t.customer_id\n" +
					"                    and card_state = '9'\n" +
					"                    and last_modify_date =\n" +
					"                        (select max(last_modify_date)\n" +
					"                           from card_baseinfo\n" +
					"                          where customer_id = t.customer_id\n" +
					"                            and card_state = '9')) and bank_id = t.bank_id and card_type = '120')) ";
            if(applyState.equals("20") ){
            	sql += "and t.apply_state = '20'";
			}
			if(applyState.equals("60")){
				sql += "and t.apply_state in ('60','90')";
			}
			if(applyState.equals("00")){
				sql += "and t.apply_state in ('20','30','40','50','60','90')";
			}
			if (!Tools.processNull(beginTime).equals("")) {
				sql += "and (t.is_urgent = '1' or t2.task_date >= to_date('" + beginTime + "','yyyy-mm-dd')) ";
				sql += "and (t.is_urgent = '0' or t3.receivebybank_date >= to_date('" + beginTime + "','yyyy-mm-dd')) ";
			} else {
				sql += "and (t.is_urgent = '1' or t2.task_date >= to_date('2016-07-01','yyyy-mm-dd')) ";
				sql += "and (t.is_urgent = '0' or t3.receivebybank_date >= to_date('2016-07-01','yyyy-mm-dd')) ";
			}
			if (!Tools.processNull(endTime).equals("")) {
				sql += "and (t.is_urgent = '1' or t2.task_date <= to_date('" + endTime + " 23:59:59','yyyy-mm-dd hh24:mi:ss')) ";
				sql += "and (t.is_urgent = '0' or t3.receivebybank_date <= to_date('" + endTime + " 23:59:59','yyyy-mm-dd hh24:mi:ss')) ";
			}
			if (!Tools.processNull(bankId).equals("")) {
				sql += "and t.bank_id = '" + bankId + "' ";
			}
			if (!Tools.processNull(branchId).equals("")) {
				if (cascadeBrch) {
					sql += "and t.recv_brch_id in (select q1.brch_id from sys_branch q1 start with q1.brch_id = '" + branchId + "' connect by prior q1.sysbranch_id  =  q1.pid) ";
				} else {
					sql += "and t.recv_brch_id = '" + branchId + "' ";
				}
			}
			sql += "group by t.bank_id, t.recv_brch_id ";
			if (!Tools.processNull(sort).equals("")) {
				sql += "order by " + sort;
				if (!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			} else {
				sql += "order by t.bank_id, t.recv_brch_id";
			}
			Page list = baseService.pagingQuery(sql, page, rows);
			if (list.getAllRs() != null && list.getAllRs().size() > 0) {
				jsonObject.put("rows", list.getAllRs());
				jsonObject.put("total", list.getTotalCount());
			} else {
				throw new CommonException("根据查询条件未查询到发卡量信息！");
			}
        }catch(Exception e){
            this.defaultErrorMsg = e.getMessage();
            jsonObject.put("status","1");
            jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }


	public String jrsbkFkStat2(){
		try{
			this.initBaseDataGrid();
			String sql = "select t.bank_id, (select bank_name from base_bank where bank_id = t.bank_id) bank_name, "
					+ "t.recv_brch_id, (select full_name from sys_branch where brch_id = t.recv_brch_id) recv_brch_name, count(1) tot_num, "
					+ "sum(decode(t.is_urgent, '0', decode(t.apply_type, '0', 1, 0), 0)) bd_xfk, "
					+ "sum(decode(t.is_urgent, '0', decode(t.apply_type, '0', 0, 1), 0)) bd_hfk, "
					+ "sum(decode(t.is_urgent, '1', decode(t.apply_type, '0', decode(t.is_batch_hf, '0', 0, 1), 0), 0)) wb_xfk, "
					+ "sum(decode(t.is_urgent, '1', decode(t.apply_type, '0', decode(t.is_batch_hf, '0', 1, 0), 1), 0)) wb_hfk "
					+ "from card_apply t join card_apply_task t2 on t.task_id = t2.task_id left join card_task_batch t3 on t2.make_batch_id = t3.batch_id "
					+ "where t.card_type = '120' and t.apply_state between '" + applyState + "' and '90' "
					+ "and (t.apply_type = '0' or not exists (select 1 from card_apply where card_no = t.old_card_no and bank_id = t.bank_id and card_type = '120')) ";
			if (!Tools.processNull(beginTime).equals("")) {
				sql += "and (t.is_urgent = '1' or t2.task_date >= to_date('" + beginTime + "','yyyy-mm-dd')) ";
				sql += "and (t.is_urgent = '0' or t3.receivebybank_date >= to_date('" + beginTime + "','yyyy-mm-dd')) ";
			} else {
				sql += "and (t.is_urgent = '1' or t2.task_date >= to_date('2016-07-01','yyyy-mm-dd')) ";
				sql += "and (t.is_urgent = '0' or t3.receivebybank_date >= to_date('2016-07-01','yyyy-mm-dd')) ";
			}
			if (!Tools.processNull(endTime).equals("")) {
				sql += "and (t.is_urgent = '1' or t2.task_date <= to_date('" + endTime + " 23:59:59','yyyy-mm-dd hh24:mi:ss')) ";
				sql += "and (t.is_urgent = '0' or t3.receivebybank_date <= to_date('" + endTime + " 23:59:59','yyyy-mm-dd hh24:mi:ss')) ";
			}
			if (!Tools.processNull(bankId).equals("")) {
				sql += "and t.bank_id = '" + bankId + "' ";
			}
			if (!Tools.processNull(branchId).equals("")) {
				if (cascadeBrch) {
					sql += "and t.recv_brch_id in (select q1.brch_id from sys_branch q1 start with q1.brch_id = '" + branchId + "' connect by prior q1.sysbranch_id  =  q1.pid) ";
				} else {
					sql += "and t.recv_brch_id = '" + branchId + "' ";
				}
			}
			sql += "group by t.bank_id, t.recv_brch_id ";
			if (!Tools.processNull(sort).equals("")) {
				sql += "order by " + sort;
				if (!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			} else {
				sql += "order by t.bank_id, t.recv_brch_id";
			}
			Page list = baseService.pagingQuery(sql, page, rows);
			if (list.getAllRs() != null && list.getAllRs().size() > 0) {
				jsonObject.put("rows", list.getAllRs());
				jsonObject.put("total", list.getTotalCount());
			} else {
				throw new CommonException("根据查询条件未查询到发卡量信息！");
			}
		}catch(Exception e){
			this.defaultErrorMsg = e.getMessage();
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String jrsbkFkDetailQuery() {
		try {
			initBaseDataGrid();
			String sql = "select t.apply_id, t.card_no, t.bank_id, t.recv_brch_id, t.apply_type, t.is_urgent, nvl(t.is_batch_hf, 1) is_batch_hf, t2.name, t2.cert_no, "
					+ "(select code_name from sys_code where code_type = 'APPLY_STATE' and code_value = t.apply_state) apply_state, "
					+ "(select bank_name from base_bank where bank_id = t.bank_id) bank_name, (select full_name from sys_branch where brch_id = t.recv_brch_id) recv_brch_name "
					+ "from card_apply t join base_personal t2 on t.customer_id = t2.customer_id join card_apply_task t3 on t.task_id = t3.task_id "
					+ "where t.card_type = '120' and apply_state between '" + applyState + "' and '90' "
            		+ "and (t.apply_type = '0' or not exists (select 1 from card_apply where card_no = (select card_no\n" +
					"                             from card_baseinfo\n" +
					"                            where customer_id = t.customer_id\n" +
					"                              and card_state = '9'\n" +
					"                              and last_modify_date =\n" +
					"                                  (select max(last_modify_date)\n" +
					"                                     from card_baseinfo\n" +
					"                                    where customer_id = t.customer_id\n" +
					"                                      and card_state = '9')) and bank_id = t.bank_id and card_type = '120')) ";
			if (!Tools.processNull(bankId).equals("")) {
				sql += "and t.bank_id = '" + bankId + "' ";
			}
			if (!Tools.processNull(branchId).equals("")) {
				sql += "and t.recv_brch_id = '" + branchId + "' ";
			}
			if (!Tools.processNull(beginTime).equals("")) {
				sql += "and t3.task_date >= to_date('" + beginTime + "','yyyy-mm-dd') ";
				//sql += "and (t.is_urgent = '0' or t4.receivebybank_date >= to_date('" + beginTime + "','yyyy-mm-dd')) ";
			} else {
				sql += "and (t.is_urgent = '1' or t3.task_date >= to_date('2016-07-01','yyyy-mm-dd')) ";
				sql += "and (t.is_urgent = '0' or t4.receivebybank_date >= to_date('2016-07-01','yyyy-mm-dd')) ";
			}
			if (!Tools.processNull(endTime).equals("")) {
				sql += "and t3.task_date <= to_date('" + endTime + " 23:59:59','yyyy-mm-dd hh24:mi:ss') ";
				//sql += "and (t.is_urgent = '0' or t4.receivebybank_date <= to_date('" + endTime + " 23:59:59','yyyy-mm-dd hh24:mi:ss')) ";
			}
			if (!Tools.processNull(sort).equals("")) {
				sql += "order by " + sort;
				if (!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			} else {
				sql += "order by t2.name";
			}
			Page list = baseService.pagingQuery(sql, page, rows);
			if (list.getAllRs() == null || list.getAllRs().isEmpty()) {
				throw new CommonException("根据查询条件未查询到发卡量信息！");
			}
			jsonObject.put("rows", list.getAllRs());
			jsonObject.put("total", list.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportJrsbkFkDetail() {
		try {
			jrsbkFkDetailQuery();
			JSONArray data = (JSONArray) jsonObject.get("rows");
			
			//
			String fileName = data.getJSONObject(0).getString("BANK_NAME") + "金融市民卡发卡明细";
			response.setContentType("application/ms-excel;charset=utf-8");
			String userAgent = request.getHeader("user-agent");
			if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
				response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
			} else {
				response.setHeader("Content-disposition", "attachment; filename=" + new String((fileName).getBytes("utf-8"), "iso8859-1") + ".xls");
			}

			// workbook
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);

			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 6000);
			sheet.setColumnWidth(3, 6000);
			sheet.setColumnWidth(4, 3000);
			sheet.setColumnWidth(5, 6000);
			sheet.setColumnWidth(6, 6000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 6000);
			sheet.setColumnWidth(9, 3000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

			// cellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);
			// headCellStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
			// headCellStyle.setFillForegroundColor(HSSFColor.LEMON_CHIFFON.index);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			// head row 1
			int maxColumn = 10;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			sheet.getRow(0).getCell(0).setCellValue(fileName);

			// second header
			String string = "";
			if (!Tools.processNull(beginTime).equals("") || !Tools.processNull(endTime).equals("")) {
				string += "申领时间： " + beginTime + " ~ " + endTime;
			}
			string += "    领卡网点：" + data.getJSONObject(0).getString("RECV_BRCH_NAME");
			string += "    导出时间：" + DateUtils.getNowTime();
			sheet.getRow(1).getCell(0).setCellValue(string);

			// third header
			sheet.getRow(2).getCell(0).setCellValue("申领编号");
			sheet.getRow(2).getCell(1).setCellValue("姓名");
			sheet.getRow(2).getCell(2).setCellValue("证件号码");
			sheet.getRow(2).getCell(3).setCellValue("卡号");
			sheet.getRow(2).getCell(4).setCellValue("申领状态");
			sheet.getRow(2).getCell(5).setCellValue("银行编号");
			sheet.getRow(2).getCell(6).setCellValue("银行名称");
			sheet.getRow(2).getCell(7).setCellValue("领卡网点编号");
			sheet.getRow(2).getCell(8).setCellValue("领卡网点");
			sheet.getRow(2).getCell(9).setCellValue("发卡类型");

			//
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(0, 3);
			int num = 0;
			for (int i = 0; i < data.size(); i++, num++) {
				JSONObject item = data.getJSONObject(i);

				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(cellStyle);
				}

				row.getCell(0).setCellValue(item.getString("APPLY_ID"));
				row.getCell(1).setCellValue(item.getString("NAME"));
				row.getCell(2).setCellValue(item.getString("CERT_NO"));
				row.getCell(3).setCellValue(item.getString("CARD_NO"));
				row.getCell(4).setCellValue(item.getString("APPLY_STATE"));
				row.getCell(5).setCellValue(item.getString("BANK_ID"));
				row.getCell(6).setCellValue(item.getString("BANK_NAME"));
				row.getCell(7).setCellValue(item.getString("RECV_BRCH_ID"));
				row.getCell(8).setCellValue(item.getString("RECV_BRCH_NAME"));
				
				String cardType = "";
           		if("1".equals(item.getString("IS_URGENT"))) {
           			cardType += "外包";
           		} else {
           			cardType += "本地";
           		}
				if ("0".equals(item.getString("APPLY_TYPE"))) {
					if ("1".equals(item.getString("IS_BATCH_HF"))) {
						cardType += "新发卡";
					} else {
						cardType += "换发卡";
					}
				} else {
					cardType += "换发卡";
				}
				row.getCell(9).setCellValue(cardType);
			}

			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				cell.setCellStyle(cellStyle);
			}
			row.getCell(1).setCellValue("统计：");
			row.getCell(2).setCellValue("共 " + num + " 条记录");
			sheet.addMergedRegion(new CellRangeAddress(data.size() + headRows, data.size() + headRows, 2, maxColumn - 1));
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportJrsbkFkDetail",Constants.YES_NO_YES);
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportJrsbkFkStat() {
		try {
			jrsbkFkStat();
			JSONArray data = (JSONArray) jsonObject.get("rows");
			
			//
			String fileName = "金融市民卡量统计";
			if (!Tools.processNull(bankId).equals("")) {
				fileName = data.getJSONObject(0).getString("BANK_NAME") + fileName;
			}
			if (!Tools.processNull(beginTime).equals("") || !Tools.processNull(endTime).equals("")) {
				fileName += " (" + beginTime + " ~ " + endTime + ")";
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			String userAgent = request.getHeader("user-agent");
			if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
				response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
			} else {
				response.setHeader("Content-disposition", "attachment; filename=" + new String((fileName).getBytes(), "iso8859-1") + ".xls");
			}

			// workbook
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);

			sheet.setColumnWidth(0, 4500);
			sheet.setColumnWidth(1, 5000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 6000);
			sheet.setColumnWidth(4, 3000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 3000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 3000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 3000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

			// cellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);
			// headCellStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
			// headCellStyle.setFillForegroundColor(HSSFColor.LEMON_CHIFFON.index);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			// head row 1
			int maxColumn = 11;
			int headRows = 4;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			sheet.getRow(0).getCell(0).setCellValue(fileName);

			// second header
			String string = "";
			if (!Tools.processNull(beginTime).equals("") || !Tools.processNull(endTime).equals("")) {
				string += "申领时间： " + beginTime + " ~ " + endTime;
			}
			if (!Tools.processNull(bankId).equals("")) {
				string += "    银行：" + data.getJSONObject(0).getString("BANK_NAME");
			}
			string += "    导出时间：" + DateUtils.getNowTime();
			sheet.getRow(1).getCell(0).setCellValue(string);

			// third header
			sheet.getRow(2).getCell(0).setCellValue("银行信息");
			sheet.getRow(2).getCell(2).setCellValue("网点信息");
			sheet.getRow(2).getCell(4).setCellValue("本地");
			sheet.getRow(2).getCell(7).setCellValue("外包");
			sheet.getRow(2).getCell(10).setCellValue("总计");
			
			// fourth header
			sheet.getRow(3).getCell(0).setCellValue("银行编号");
			sheet.getRow(3).getCell(1).setCellValue("银行名称");
			sheet.getRow(3).getCell(2).setCellValue("网点编号");
			sheet.getRow(3).getCell(3).setCellValue("网点名称");
			sheet.getRow(3).getCell(4).setCellValue("新发卡");
			sheet.getRow(3).getCell(5).setCellValue("换发卡");
			sheet.getRow(3).getCell(6).setCellValue("小计");
			sheet.getRow(3).getCell(7).setCellValue("新发卡");
			sheet.getRow(3).getCell(8).setCellValue("换发卡");
			sheet.getRow(3).getCell(9).setCellValue("小计");

			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 0, 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 2, 3));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 4, 6));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 7, 9));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 10, 10));
			sheet.createFreezePane(2, 4);
			
			// data
			int num = 0;
			int sumBdXfk = 0;
			int sumBdHfk = 0;
			int sumWbXfk = 0;
			int sumWbHfk = 0;
			int sumTot = 0;
			for (int i = 0; i < data.size(); i++, num++) {
				JSONObject item = data.getJSONObject(i);

				// cell data
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(cellStyle);
				}
				row.getCell(0).setCellValue(item.getString("BANK_ID"));
				row.getCell(1).setCellValue(item.getString("BANK_NAME"));
				row.getCell(2).setCellValue(item.getString("RECV_BRCH_ID"));
				row.getCell(3).setCellValue(item.getString("RECV_BRCH_NAME"));
				//
				int bdXfk = item.getIntValue("BD_XFK");
				int bdHfk = item.getIntValue("BD_HFK");
				row.getCell(4).setCellValue(bdXfk);
				row.getCell(5).setCellValue(bdHfk);
				row.getCell(6).setCellValue(bdXfk + bdHfk);
				sumBdXfk += bdXfk;
				sumBdHfk += bdHfk;
				//
				int wbXfk = item.getIntValue("WB_XFK");
				int wbHfk = item.getIntValue("WB_HFK");
				row.getCell(7).setCellValue(wbXfk);
				row.getCell(8).setCellValue(wbHfk);
				row.getCell(9).setCellValue(wbXfk + wbHfk);
				sumWbXfk += wbXfk;
				sumWbHfk += wbHfk;
				//
				int tot = item.getIntValue("WB_TOT");
				row.getCell(10).setCellValue(tot);
				sumTot += tot;
			}

			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				cell.setCellStyle(cellStyle);
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(1).setCellValue("共 " + num + " 条记录");
			row.getCell(4).setCellValue(sumBdXfk);
			row.getCell(5).setCellValue(sumBdHfk);
			row.getCell(6).setCellValue(sumBdXfk + sumBdHfk);
			row.getCell(7).setCellValue(sumWbXfk);
			row.getCell(8).setCellValue(sumWbHfk);
			row.getCell(9).setCellValue(sumWbXfk + sumWbHfk);
			row.getCell(10).setCellValue(sumTot);
			sheet.addMergedRegion(new CellRangeAddress(data.size() + headRows, data.size() + headRows, 1, 3));
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportJrsbkFkDetail",Constants.YES_NO_YES);
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
    public String jrsbkFkStatExport(){
	    try{
            queryType = "0";
            this.page = 1;
            this.rows = 1000000;
            this.bankBindDetailQuery();
            if(!Tools.processNull(jsonObject.get("status")).equals("0")){
                throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
            }
            Workbook book = new SXSSFWorkbook(500);
            Sheet sheet = book.createSheet();
            sheet.setFitToPage(true);
            sheet.createFreezePane(1,3);
            CellRangeAddress titleRegion = new CellRangeAddress(0,0,0,8);
            titleRegion.formatAsString();
            sheet.addMergedRegion(titleRegion);
            CellStyle titleStyle = this.getCellStyleOfTitle(book);
            Row firstRow = sheet.createRow(0);
            firstRow.setHeight((short)(firstRow.getHeight() * 2));
            Cell cell = firstRow.createCell(0);
            cell.setCellValue(Constants.APP_REPORT_TITLE + "银行卡绑定业务明细");
            cell.setCellStyle(titleStyle);
            Font headerFont = book.createFont();
            headerFont.setFontName("微软雅黑");
            headerFont.setBoldweight((short)(headerFont.getBoldweight() * 2));
            headerFont.setFontHeight((short)(headerFont.getFontHeight() * 0.9));
            headerFont.setColor(HSSFColor.BLUE.index);
            CellStyle headStyle = book.createCellStyle();
            headStyle.setBorderBottom(CellStyle.BORDER_THIN);
            headStyle.setBorderLeft(CellStyle.BORDER_THIN);
            headStyle.setBorderRight(CellStyle.BORDER_THIN);
            headStyle.setBorderTop(CellStyle.BORDER_THIN);
            headStyle.setAlignment(CellStyle.ALIGN_CENTER);
            headStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
            headStyle.setFont(headerFont);
            CellRangeAddress region1 = new CellRangeAddress(1,1,0,8);
            region1.formatAsString();
            sheet.addMergedRegion(region1);
            Row dateRow = sheet.createRow(1);
            Cell dateRow0 = dateRow.createCell(0);
            dateRow0.setCellValue("汇总周期：" + this.beginTime + " —— " + this.endTime + "  制表时间：" + DateUtil.formatDate(baseService.getDateBaseTime(),"yyyy-MM-dd HH:mm:ss"));
            dateRow0.setCellStyle(this.getCellStyleOfDateColumn(book));
            Row secRow = sheet.createRow(2);
            for(int d = 0;d <= 8; d++){
                secRow.createCell(d).setCellStyle(headStyle);
            }
            Cell secCell0 = secRow.createCell(0);
            secCell0.setCellValue("序号");
            secCell0.setCellStyle(headStyle);
            Cell secCell1 = secRow.createCell(1);
            secCell1.setCellValue("姓名");
            secCell1.setCellStyle(headStyle);
            Cell secCell2 = secRow.createCell(2);
            secCell2.setCellValue("证件号码");
            secCell2.setCellStyle(headStyle);
            Cell secCell3 = secRow.createCell(3);
            secCell3.setCellValue("市民卡卡号");
            secCell3.setCellStyle(headStyle);
            Cell secCell4 = secRow.createCell(4);
            secCell4.setCellValue("绑定银行");
            secCell4.setCellStyle(headStyle);
            Cell secCell5 = secRow.createCell(5);
            secCell5.setCellValue("银行账号");
            secCell5.setCellStyle(headStyle);
            Cell secCell6 = secRow.createCell(6);
            secCell6.setCellValue("绑定日期");
            secCell6.setCellStyle(headStyle);
            Cell secCell7 = secRow.createCell(7);
            secCell7.setCellValue("办理网点");
            secCell7.setCellStyle(headStyle);
            Cell secCell8 = secRow.createCell(8);
            secCell8.setCellValue("办理柜员");
            secCell8.setCellStyle(headStyle);
            JSONArray rows =  this.jsonObject.getJSONArray("rows");
            int totPages = this.jsonObject.getIntValue("totPages_01");
            int rowNum = 3;
            CellStyle commonStyle = this.getCellStyleOfData(book);
            while(this.page <= totPages){
                if(rows != null && rows.size() > 0){
                    for (Object object : rows) {
                        JSONObject tempRowData = (JSONObject) object;
                        Row tempRow = sheet.createRow(rowNum);
                        Cell tempCell0 = tempRow.createCell(0);
                        tempCell0.setCellValue(tempRowData.getString("V_V"));
                        tempCell0.setCellStyle(commonStyle);
                        Cell tempCell1 = tempRow.createCell(1);
                        tempCell1.setCellValue(tempRowData.getString("NAME"));
                        tempCell1.setCellStyle(commonStyle);
                        Cell tempCell2 = tempRow.createCell(2);
                        tempCell2.setCellStyle(commonStyle);
                        tempCell2.setCellValue(tempRowData.getString("CERT_NO"));
                        Cell tempCell3 = tempRow.createCell(3);
                        tempCell3.setCellStyle(commonStyle);
                        tempCell3.setCellValue(tempRowData.getString("CARD_NO"));
                        Cell tempCell4 = tempRow.createCell(4);
                        tempCell4.setCellStyle(commonStyle);
                        tempCell4.setCellValue(tempRowData.getString("BANK_NAME"));
                        Cell tempCell5 = tempRow.createCell(5);
                        tempCell5.setCellStyle(commonStyle);
                        tempCell5.setCellValue(tempRowData.getString("BANK_CARD_NO"));
                        Cell tempCell6 = tempRow.createCell(6);
                        tempCell6.setCellStyle(commonStyle);
                        tempCell6.setCellValue(tempRowData.getString("BINDDATE"));
                        Cell tempCell7 = tempRow.createCell(7);
                        tempCell7.setCellStyle(commonStyle);
                        tempCell7.setCellValue(tempRowData.getString("FULL_NAME"));
                        Cell tempCell8 = tempRow.createCell(8);
                        tempCell8.setCellStyle(commonStyle);
                        tempCell8.setCellValue(tempRowData.getString("USERNAME"));
                        rowNum++;
                        tempRowData = null;
                    }
                    rows = null;
                }
                this.page += 1;
                if(this.page <= totPages){
                    this.bankBindDetailQuery();
                    if(!Tools.processNull(jsonObject.get("status")).equals("0")){
                        book = null;
                        sheet = null;
                        throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
                    }
                    rows =  this.jsonObject.getJSONArray("rows");
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
            sheet.autoSizeColumn(8,true);
            OutputStream out = this.response.getOutputStream();
            this.response.setContentType("application/vnd.ms-excel");
            this.response.setCharacterEncoding("UTF-8");
            this.response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode( Constants.APP_REPORT_TITLE + "银行卡绑定业务明细（" + this.beginTime + "--" + this.endTime + "）", "UTF-8") + ".xlsx\"");
            book.write(out);
            SecurityUtils.getSubject().getSession().setAttribute("bankBindDetailMain",Constants.YES_NO_YES);
            out.flush();
        }catch(Exception e){
            this.defaultErrorMsg = e.getMessage();
            log.error(e);
            return "jrsbkFkStat";
        }
        return null;
    }

	public void setBorder(int num,CellRangeAddress region1,HSSFSheet sheet,HSSFWorkbook book){
		RegionUtil.setBorderBottom(CellStyle.BORDER_THIN,region1,sheet,book);
		RegionUtil.setBorderLeft(CellStyle.BORDER_THIN,region1,sheet,book);
		RegionUtil.setBorderRight(CellStyle.BORDER_THIN,region1,sheet,book);
		RegionUtil.setBorderTop(CellStyle.BORDER_THIN,region1,sheet,book);
	}
	
	public String hkzzRechargeQuery() {
		try{
			initBaseDataGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				String dealNoSql = "";
				if(!Tools.processNull(bankIds).equals("")){
					String[] dealNoArr = bankIds.split(",");
					if (dealNoArr != null && dealNoArr.length > 0) {
						for (String dealNo : dealNoArr) {
							dealNoSql += "'" + dealNo + "',";
						}
						dealNoSql = dealNoSql.substring(0, dealNoSql.length() - 1);
					}
				}
				StringBuffer head = new StringBuffer();
				head.append("select t.deal_no deal_no1, t.deal_no,t.deal_batch_no,r.deal_code_name deal_code,t.customer_id,t.acc_name,"
						+ "(select s1.code_name from sys_code s1 where s1.code_type = 'SEX' and s1.code_value = b.gender ) gender,"
						+ "(select s2.code_name from sys_code s2 where s2.code_type = 'CERT_TYPE' and s2.code_value = b.cert_type ) cert_type,"
						+ "b.cert_no,"
						+ "(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_TYPE' and s3.code_value = t.card_type ) card_type,"
						+ "t.card_no,t.acc_no, t.acpt_id ACPT_ID,"
						+ "decode(t.acpt_type,'1',(select t1.full_name from Sys_Branch t1 WHERE t1.brch_id = t.acpt_id),'0',"
						+ "(SELECT t2.merchant_name from base_merchant t2 WHERE t2.merchant_id = t.acpt_id),'2',(SELECT CO_ORG_NAME from base_co_org WHERE co_org_id = t.acpt_id)) full_name,"
						+ "t.user_id USER_ID,decode(t.acpt_type,'1',(select t1.name from Sys_Users t1 WHERE t1.user_id =t.user_id),'0',"
						+ "(SELECT t2.end_name FROM base_tag_end t2 WHERE t2.end_id =t.user_id),t.user_id) NAME,"
						+ "(select s4.code_name from sys_code s4 where s4.code_type = 'ACC_KIND' and s4.code_value = t.acc_kind ) acc_kind,"
						+ "to_char(t.deal_date,'yyyy-mm-dd hh24:mi:ss') deal_Date,t.acc_bal card_bal,t.amt amt,t.end_deal_no,t.card_counter,t.rev_time,t.credit,decode(t.deal_state,'0','正常','1','撤销','2','冲正','3','退货','9','灰记录','其他') deal_state,t.insert_time,t.clr_date,t.note,t.posp_proc_state ");
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
					initsql.append("select * from ");
					initsql.append(allTabs.get(i));
					initsql.append(" union ");
				}
				StringBuffer finalsql = new StringBuffer();
				finalsql.append(head);
				finalsql.append("from (");
				finalsql.append(initsql.substring(0,initsql.length() - 6));
				finalsql.append(") t ,base_personal b , sys_code_tr r where t.customer_id = b.customer_id(+) and t.deal_code = r.deal_code(+) and t.deal_code = '" + DealCode.BHK_QB_ZZ_BZ + "' ");
				if(!Tools.processNull(this.cardNo).equals("")){
					finalsql.append(" and t.card_no = '" + this.cardNo + "' ");
				}
				if(!Tools.processNull(this.cardType).equals("")){
					finalsql.append(" and t.card_type = '" + this.cardType + "' ");
				}
				if(!Tools.processNull(this.accKind).equals("")){
					finalsql.append(" and t.acc_kind = '" + this.accKind + "' ");
				}
				if(!Tools.processNull(this.dealNo).equals("")){
					finalsql.append(" and t.deal_no = " + this.dealNo + " ");
				}
				if(!Tools.processNull(this.branchId).equals("")){
					if(cascadeBrch){
						finalsql.append("and t.acpt_id in (select brch_id from sys_branch start with brch_id = '" 
								+ branchId + "' connect by  prior sysbranch_id = pid) ");
					} else {
						finalsql.append(" and t.acpt_id = '" + this.branchId + "' ");
					}
				}
				if(!Tools.processNull(this.beginTime).equals("")){
					finalsql.append(" and t.deal_date >= to_date('" + this.beginTime + "', 'yyyy-mm-dd') ");
				}
				if(!Tools.processNull(this.endTime).equals("")){
					finalsql.append(" and t.deal_date <= to_date('" + this.endTime + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ");
				}
				if(!Tools.processNull(dealNoSql).equals("")){
					finalsql.append(" and t.deal_no in (" + dealNoSql + ") ");
				}
				//2.排序
				if(Tools.processNull(this.sort).equals("")){
					finalsql.append(" order by t.deal_no desc");
				} else {
					finalsql.append(" order by " + this.sort + " " + this.order);
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
	
	public String hkzzRechargeStat() {
		try{
			initBaseDataGrid();
			if (Tools.processNull(beginTime).equals("")) {
				throw new CommonException("起始日期不能为空.");
			} else if (Tools.processNull(endTime).equals("")) {
				throw new CommonException("结束日期不能为空.");
			}
			String brchSql = "";
			if(!Tools.processNull(branchIds).equals("")){
				String[] brchIdArr = branchIds.split(",");
				if (brchIdArr != null && brchIdArr.length > 0) {
					for (String brchId : brchIdArr) {
						brchSql += "'" + brchId + "',";
					}
					brchSql = brchSql.substring(0, brchSql.length() - 1);
				}
			}
			String sql = "select acpt_id, (select full_name from sys_branch where brch_id = t.acpt_id) acpt_name, "
					+ "(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.card_type) card_type, "
					+ "count(*) tot_num, sum(amt) tot_amt from (";
			String sql2 = "select * from pay_card_deal_rec t where deal_code = '" + DealCode.BHK_QB_ZZ_BZ 
					+ "' and clr_date >= '" + beginTime + "' and clr_date <= '" + endTime + "' ";
			if (!Tools.processNull(this.branchId).equals("")) {
				if (cascadeBrch) {
					sql2 += "and t.acpt_id in (select brch_id from sys_branch start with brch_id = '" + branchId
							+ "' connect by  prior sysbranch_id = pid) ";
				} else {
					sql2 += " and t.acpt_id = '" + this.branchId + "' ";
				}
			}
			if (!Tools.processNull(brchSql).equals("")) {
				sql2 += "and t.acpt_id in (" + brchSql + ") ";
			}
			List<String> months = getMonths(beginTime, endTime);
			for (String month : months) {
				sql += sql2.replaceFirst("pay_card_deal_rec", "pay_card_deal_rec_" + month) + " union ";
			}
			sql = sql.substring(0, sql.length() - 6) + ") t group by acpt_id, card_type";
			if (!Tools.processNull(sort).equals("")) {
				sql += " order by " + sort;
				if(!Tools.processNull(order).equals("")){
					 sql += " " + order;
				}
			}
			Page list = baseService.pagingQuery(sql.toString(), page, rows);
			if (list.getAllRs() == null || list.getAllRs().size() < 0) {
				throw new CommonException("未查询到记录信息");
			}
			jsonObject.put("rows", list.getAllRs());
			jsonObject.put("total", list.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportHkzzRechargeInfo() {
		try {
			hkzzRechargeQuery();
			String fileName = "换卡转钱包补充值明细";
			if(!Tools.processNull(branchId).equals("")){
				String brchName = (String) baseService.findOnlyFieldBySql("select full_name from sys_branch where brch_id = '" + branchId + "'");
				fileName = brchName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 6000);
			sheet.setColumnWidth(3, 3000);
			sheet.setColumnWidth(4, 5000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 6000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 6000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 3000);
			sheet.setColumnWidth(11, 3000);
			sheet.setColumnWidth(12, 6000);
			sheet.setColumnWidth(13, 6000);
			sheet.setColumnWidth(14, 3000);
			sheet.setColumnWidth(15, 3000);
			sheet.setColumnWidth(16, 3000);
			sheet.setColumnWidth(17, 3000);
			sheet.setColumnWidth(18, 3000);
			sheet.setColumnWidth(19, 12000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

			// moneyCellStyle
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));
			
			// cellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);
			// headCellStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
			// headCellStyle.setFillForegroundColor(HSSFColor.LEMON_CHIFFON.index);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			// head row 1
			int maxColumn = 20;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			// second header
			sheet.getRow(1).getCell(0).setCellValue("业务时间：" + beginTime + " ~ " + endTime + "    导出时间：" + DateUtils.getNowTime());
			
			// third header
			sheet.getRow(2).getCell(0).setCellValue("流水号");
			sheet.getRow(2).getCell(1).setCellValue("批次号");
			sheet.getRow(2).getCell(2).setCellValue("业务名称");
			if(Tools.processNull(acptType).equals("1")){
				sheet.getRow(2).getCell(3).setCellValue("网点编号");
				sheet.getRow(2).getCell(4).setCellValue("网点名称");
			} else {
				sheet.getRow(2).getCell(3).setCellValue("受理点编号");
				sheet.getRow(2).getCell(4).setCellValue("受理点名称");
			}
			sheet.getRow(2).getCell(5).setCellValue("客户姓名");
			sheet.getRow(2).getCell(6).setCellValue("证件号码");
			sheet.getRow(2).getCell(7).setCellValue("卡类型");
			sheet.getRow(2).getCell(8).setCellValue("卡号");
			sheet.getRow(2).getCell(9).setCellValue("账户类型");
			sheet.getRow(2).getCell(10).setCellValue("交易前金额");
			sheet.getRow(2).getCell(11).setCellValue("交易金额");//
			sheet.getRow(2).getCell(12).setCellValue("交易时间");
			sheet.getRow(2).getCell(13).setCellValue("终端交易流水");
			sheet.getRow(2).getCell(14).setCellValue("卡交易序列号");
			sheet.getRow(2).getCell(15).setCellValue("柜员/终端编号");
			sheet.getRow(2).getCell(16).setCellValue("柜员/终端名称");
			sheet.getRow(2).getCell(17).setCellValue("清分日期");
			sheet.getRow(2).getCell(18).setCellValue("状态");
			sheet.getRow(2).getCell(19).setCellValue("备注");
			
			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(5, 3);
			int numSum = 0;
			double amtSum = 0;
			for (int i = 0; i < data.size(); i++, numSum++) {
				JSONObject item = data.getJSONObject(i);
				
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j == 10 || j == 11) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				row.getCell(0).setCellValue(item.getString("DEAL_NO"));
				row.getCell(1).setCellValue(item.getString("DEAL_BATCH_NO"));
				row.getCell(2).setCellValue(item.getString("DEAL_CODE"));
				row.getCell(3).setCellValue(item.getString("ACPT_ID"));
				row.getCell(4).setCellValue(item.getString("FULL_NAME"));
				row.getCell(5).setCellValue(item.getString("ACC_NAME"));
				row.getCell(6).setCellValue(item.getString("CERT_NO"));
				row.getCell(7).setCellValue(item.getString("CARD_TYPE"));
				row.getCell(8).setCellValue(item.getString("CARD_NO"));
				row.getCell(9).setCellValue(item.getString("ACC_KIND"));
				row.getCell(10).setCellValue(item.getDoubleValue("CARD_BAL") / 100);
				row.getCell(11).setCellValue(item.getDoubleValue("AMT") / 100);
				row.getCell(12).setCellValue(item.getString("DEAL_DATE"));
				row.getCell(13).setCellValue(item.getString("END_DEAL_NO"));
				row.getCell(14).setCellValue(item.getString("CARD_COUNTER"));
				row.getCell(15).setCellValue(item.getString("USER_ID"));
				row.getCell(16).setCellValue(item.getString("NAME"));
				row.getCell(17).setCellValue(item.getString("CLR_DATE"));
				row.getCell(18).setCellValue(item.getString("DEAL_STATE"));
				row.getCell(19).setCellValue(item.getString("NOTE"));
				
				amtSum += item.getDoubleValue("AMT");
			}
			
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if (j == 10 || j == 11) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(2).setCellValue("统计：");
			row.getCell(3).setCellValue("共 " + numSum + " 笔");
			row.getCell(11).setCellValue(amtSum / 100);
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportqbRechgByClrInfo() {
		try {
			qbRechgByClr();
			JSONArray data = (JSONArray) jsonObject.get("rows");
			
			String fileName = "钱包充值明细查询";
			if(!Tools.processNull(branchId).equals("")){
				String brchName = (String) baseService.findOnlyFieldBySql("select full_name from sys_branch where brch_id = '" + branchId + "'");
				fileName = brchName + "_" + fileName;
			}
			
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			//com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 6000);
			sheet.setColumnWidth(3, 3000);
			sheet.setColumnWidth(4, 7000);
			sheet.setColumnWidth(5, 5000);
			sheet.setColumnWidth(6, 6000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 3000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 3000);
			sheet.setColumnWidth(11, 7000);
			sheet.setColumnWidth(12, 3000);
			sheet.setColumnWidth(13, 3000);
			sheet.setColumnWidth(14, 3000);
			sheet.setColumnWidth(15, 5000);
			sheet.setColumnWidth(16, 6000);
			sheet.setColumnWidth(17, 3000);
			sheet.setColumnWidth(18, 3000);
			sheet.setColumnWidth(19, 3000);
			sheet.setColumnWidth(20, 3000);
			sheet.setColumnWidth(21, 7000);
			sheet.setColumnWidth(22, 3000);
			sheet.setColumnWidth(23, 3000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);
			
			Font font2 = workbook.createFont();
			font2.setColor(HSSFColor.RED.index);
			font2.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
			

			// moneyCellStyle
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));
			
			// cellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);
			
			CellStyle cellStyle2 = workbook.createCellStyle();
			cellStyle2.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle2.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle2.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle2.setBorderRight(CellStyle.BORDER_THIN);
			cellStyle2.setFont(font2);

			// head row 1
			int maxColumn = 24;
			int headRows = 4;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(1).getCell(0).setCellValue(fileName);
			
			// third header
			sheet.getRow(2).getCell(0).setCellValue("交易流水");
			sheet.getRow(2).getCell(1).setCellValue("客户姓名");
			sheet.getRow(2).getCell(2).setCellValue("证件号码");
			sheet.getRow(2).getCell(3).setCellValue("清分数据（统计）");
			sheet.getRow(2).getCell(14).setCellValue("交易数据（查询）");
			// third header
			if(Tools.processNull(acptType).equals("1")){
				sheet.getRow(3).getCell(3).setCellValue("网点编号");
				sheet.getRow(3).getCell(4).setCellValue("网点名称");
			} else {
				sheet.getRow(3).getCell(3).setCellValue("受理点编号");
				sheet.getRow(3).getCell(4).setCellValue("受理点名称");
			}
			sheet.getRow(3).getCell(5).setCellValue("业务类型");
			sheet.getRow(3).getCell(6).setCellValue("卡号");
			sheet.getRow(3).getCell(7).setCellValue("卡类型");
			sheet.getRow(3).getCell(8).setCellValue("账户类型");
			sheet.getRow(3).getCell(9).setCellValue("交易前金额");
			sheet.getRow(3).getCell(10).setCellValue("交易金额");
			sheet.getRow(3).getCell(11).setCellValue("交易时间");//
			sheet.getRow(3).getCell(12).setCellValue("清分时间");
			sheet.getRow(3).getCell(13).setCellValue("交易状态");
			sheet.getRow(3).getCell(14).setCellValue("受理点编号");
			sheet.getRow(3).getCell(15).setCellValue("受理点");
			sheet.getRow(3).getCell(16).setCellValue("卡号");
			sheet.getRow(3).getCell(17).setCellValue("卡类型");
			sheet.getRow(3).getCell(18).setCellValue("账户类型");
			sheet.getRow(3).getCell(19).setCellValue("交易前金额");
			sheet.getRow(3).getCell(20).setCellValue("交易金额");
			sheet.getRow(3).getCell(21).setCellValue("交易时间");
			sheet.getRow(3).getCell(22).setCellValue("清分时间");
			sheet.getRow(3).getCell(23).setCellValue("交易状态");
			
			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 1, 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 2, 2));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 3, 13));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 14, 23));
			sheet.createFreezePane(3,0,5,0);
			int numSum = 0;
			for (int i = 0; i < data.size(); i++, numSum++) {
				JSONObject item = data.getJSONObject(i);
				
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (item.getString("ACPT_ID2")=="") {
						cell.setCellStyle(cellStyle2);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				row.getCell(0).setCellValue(item.getString("DEAL_NO"));//1
				row.getCell(1).setCellValue(item.getString("NAME"));//2
				row.getCell(2).setCellValue(item.getString("CERT_NO"));//3
				/*if(item.getString("ACPT_ID")==""){
					HSSFFont font=(HSSFFont) workbook.createFont();
					font.setColor(HSSFColor.RED.index);
					row.getCell(3).setCellValue(item.getString("ACPT_ID"));//4
				}else{
					row.getCell(3).setCellValue(item.getString("ACPT_ID"));
				}*/
				row.getCell(3).setCellValue(item.getString("ACPT_ID"));
				row.getCell(4).setCellValue(item.getString("ACPT_NAME"));//5
				row.getCell(5).setCellValue(item.getString("DEAL_CODE_NAME"));//6
				row.getCell(6).setCellValue(item.getString("CARD_NO"));//7
				row.getCell(7).setCellValue(item.getString("CARD_TYPE"));//8
				row.getCell(8).setCellValue(item.getString("ACC_KIND"));//9
				row.getCell(9).setCellValue(item.getDoubleValue("CR_ACC_BAL") / 100);//10
				row.getCell(10).setCellValue(item.getDoubleValue("CR_AMT") / 100);//11
				row.getCell(11).setCellValue(item.getString("DEAL_DATE"));//12
				row.getCell(12).setCellValue(item.getString("CLR_DATE"));//13
				row.getCell(13).setCellValue(item.getString("DEAL_STATE"));//14
				/*if(item.getString("ACPT_ID2")==""){
					cellStyle.setFont(font2);
					row.getCell(14).setCellValue(item.getString("ACPT_ID2"));//15
				}else{*/
				row.getCell(14).setCellValue(item.getString("ACPT_ID2"));
				/*}*/
				row.getCell(14).setCellValue(item.getString("ACPT_ID2"));
				row.getCell(15).setCellValue(item.getString("ACPT_NAME2"));//16
				row.getCell(16).setCellValue(item.getString("CARD_NO2"));//17
				row.getCell(17).setCellValue(item.getString("CARD_TYPE2"));//18
				row.getCell(18).setCellValue(item.getString("ACC_KIND2"));//19
				if(item.getString("ACC_BAL2")!=""){
					row.getCell(19).setCellValue(item.getDoubleValue("ACC_BAL2") / 100);//20
				}else{
					row.getCell(19).setCellValue("0");
				}
				if(item.getString("AMT2")!=""){
					row.getCell(20).setCellValue(item.getDoubleValue("AMT2") / 100);
				}else{
					row.getCell(20).setCellValue("0");
				}
				row.getCell(21).setCellValue(item.getString("DEAL_DATE2"));//22
				row.getCell(22).setCellValue(item.getString("CLR_DATE2"));//23
				row.getCell(23).setCellValue(item.getString("DEAL_STATE2"));//24
				
			}
			
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if (j == 10 || j == 11) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(2).setCellValue("统计：" + "共 " + numSum + " 笔");
			//row.getCell(3).setCellValue("共 " + numSum + " 笔");
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportqbRechgByClrInfo",Constants.YES_NO_YES);
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return JSONOBJ;
	}
	
	
	public String exportHkzzRechargeStat(){
		try {
			hkzzRechargeStat();
			String fileName = "换卡转钱包补充值统计";
			if(!Tools.processNull(branchId).equals("")){
				String brchName = (String) baseService.findOnlyFieldBySql("select full_name from sys_branch where brch_id = '" + branchId + "'");
				fileName = brchName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 6000);
			sheet.setColumnWidth(1, 6000);
			sheet.setColumnWidth(2, 6000);
			sheet.setColumnWidth(3, 6000);
			sheet.setColumnWidth(4, 6000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

			// moneyCellStyle
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));
			
			// cellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);
			// headCellStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
			// headCellStyle.setFillForegroundColor(HSSFColor.LEMON_CHIFFON.index);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			// head row 1
			int maxColumn = 5;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			// second header
			sheet.getRow(1).getCell(0).setCellValue("业务时间：" + beginTime + " ~ " + endTime + "    导出时间：" + DateUtils.getNowTime());
			
			// third header
			sheet.getRow(2).getCell(0).setCellValue("网点编号");
			sheet.getRow(2).getCell(1).setCellValue("网点名称");
			sheet.getRow(2).getCell(2).setCellValue("卡类型");
			sheet.getRow(2).getCell(3).setCellValue("笔数");
			sheet.getRow(2).getCell(4).setCellValue("金额");
			
			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(0, 3);
			int numSum = 0;
			double amtSum = 0;
			for (int i = 0; i < data.size(); i++) {
				JSONObject item = data.getJSONObject(i);
				
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j == 4) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				row.getCell(0).setCellValue(item.getString("ACPT_ID"));
				row.getCell(1).setCellValue(item.getString("ACPT_NAME"));
				row.getCell(2).setCellValue(item.getString("CARD_TYPE"));
				row.getCell(3).setCellValue(item.getIntValue("TOT_NUM"));
				row.getCell(4).setCellValue(item.getDoubleValue("TOT_AMT") / 100);
				
				numSum += item.getIntValue("TOT_NUM");
				amtSum += item.getDoubleValue("TOT_AMT");
			}
			
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if (j == 4) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(3).setCellValue("共 " + numSum + " 笔");
			row.getCell(4).setCellValue(amtSum / 100);
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String bankQcQtQfInfo() {
		try {
			initBaseDataGrid();
			String dealNoSql = "";
			if(!Tools.processNull(bankIds).equals("")){
				String[] dealNoArr = bankIds.split(",");
				if (dealNoArr != null && dealNoArr.length > 0) {
					for (String dealNo : dealNoArr) {
						dealNoSql += "'" + dealNo + "',";
					}
					dealNoSql = dealNoSql.substring(0, dealNoSql.length() - 1);
				}
			}
			String sql = "select t.deal_no, t.deal_batch_no, (select deal_code_name from sys_code_tr where deal_code = t.deal_code) deal_code, "
					+ "t.dz_acpt_id bank_id, (select bank_name from base_bank where bank_id = t.dz_acpt_id) bank_name, "
					+ "t3.name, t3.cert_no, t2.card_type, t2.card_no, t.acc_kind, t.acpt_id, decode(t.deal_code, '" 
					+ DealCode.COSERVICE_LJ2YH + "', -t.amt, t.amt) amt, t.order_time, t.end_deal_no, "
					+ "t.user_id, (select name from sys_users where user_id = t.user_id) user_name, t.clr_date, t.deal_state "
					+ "from pay_co_deal_rec t join card_baseinfo t2 on t.card_no = t2.card_no "
					+ "join base_personal t3 on t2.customer_id = t3.customer_id where exists (select 1 from base_bank where bank_id = t.dz_acpt_id) "
					+ "and t.deal_code in ('" + DealCode.RECHARGE_ACC_CASH + "', '" + DealCode.COSERVICE_LJ2YH + "', '" + DealCode.CORECHAGE_QF_ZJZH + "') ";
			if (!Tools.processNull(dealNo).equals("")) {
				sql += "and t.deal_no = '" + dealNo + "' ";
			} else if (!Tools.processNull(dealNoSql).equals("")) {
				sql += "and t.deal_no in (" + dealNoSql + ") ";
			}
			if (!Tools.processNull(endSerNo).equals("")) {
				sql += "and t.end_deal_no = '" + endSerNo + "' ";
			}
			if (!Tools.processNull(bankId).equals("")) {
				sql += "and t.dz_acpt_id = '" + bankId + "' ";
			}
			if (!Tools.processNull(cardType).equals("")) {
				sql += "and t2.card_type = '" + cardType + "' ";
			}
			if (!Tools.processNull(accKind).equals("")) {
				sql += "and t.acc_kind = '" + accKind + "' ";
			}
			if (!Tools.processNull(clrStartDate).equals("")) {
				sql += "and t.clr_date >= '" + clrStartDate + "' ";
			}
			if (!Tools.processNull(clrEndDate).equals("")) {
				sql += "and t.clr_date <= '" + clrEndDate + "' ";
			}
			if (!Tools.processNull(cardNo).equals("")) {
				sql += "and t.card_no <= '" + cardNo + "' ";
			}
			if (!Tools.processNull(dealCode).equals("")) {
				sql += "and t.deal_code = '" + dealCode + "' ";
			}
			if (!Tools.processNull(sort).equals("")) {
				sql += "rder by " + sort;
				if(!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			} else {
				sql += " order by deal_no desc";
			}
			//
			Page pageData = baseService.pagingQuery(sql, page, rows);
			if (pageData.getAllRs() == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommonException("未查询到记录信息");
			}
			jsonObject.put("rows", pageData.getAllRs());
			jsonObject.put("total", pageData.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportBankQcQtQfInfo() {
		try {
			bankQcQtQfInfo();
			String fileName = "银行圈存圈提圈付明细";
			if(!Tools.processNull(bankId).equals("")){
				String bankName = (String) baseService.findOnlyFieldBySql("select bank_name from base_bank where bank_id = '" + bankId + "'");
				fileName = bankName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 5000);
			sheet.setColumnWidth(3, 5000);
			sheet.setColumnWidth(4, 5000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 5500);
			sheet.setColumnWidth(7, 4000);
			sheet.setColumnWidth(8, 6000);
			sheet.setColumnWidth(9, 4000);
			sheet.setColumnWidth(10, 3000);
			sheet.setColumnWidth(11, 5000);
			sheet.setColumnWidth(12, 4000);
			sheet.setColumnWidth(13, 4000);
			sheet.setColumnWidth(14, 4000);
			sheet.setColumnWidth(15, 3000);
			sheet.setColumnWidth(16, 3000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);
			
			// headCellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);

			// moneyCellStyle
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));
			
			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			// head row 1
			int maxColumn = 17;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			// second header
			sheet.getRow(1).getCell(0).setCellValue("统计时间：" + clrStartDate + " ~ " + clrEndDate + "    导出时间：" + DateUtils.getNowTime());
			
			// third header
			sheet.getRow(2).getCell(0).setCellValue("流水号");
			sheet.getRow(2).getCell(1).setCellValue("批次号");
			sheet.getRow(2).getCell(2).setCellValue("业务名称");
			sheet.getRow(2).getCell(3).setCellValue("银行编号");
			sheet.getRow(2).getCell(4).setCellValue("银行名称");
			sheet.getRow(2).getCell(5).setCellValue("客户姓名");
			sheet.getRow(2).getCell(6).setCellValue("证件号码");
			sheet.getRow(2).getCell(7).setCellValue("卡类型");
			sheet.getRow(2).getCell(8).setCellValue("卡号");
			sheet.getRow(2).getCell(9).setCellValue("账户类型");
			sheet.getRow(2).getCell(10).setCellValue("交易金额");
			sheet.getRow(2).getCell(11).setCellValue("交易时间");
			sheet.getRow(2).getCell(12).setCellValue("终端/柜员编号");
			sheet.getRow(2).getCell(13).setCellValue("终端/柜员名称");
			sheet.getRow(2).getCell(14).setCellValue("终端交易流水");
			sheet.getRow(2).getCell(15).setCellValue("清分日期");
			sheet.getRow(2).getCell(16).setCellValue("状态");
			
			//
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(5, 3);
			
			int numSum = 0;
			double amtSum = 0;
			for (int i = 0; i < data.size(); i++) {
				JSONObject item = data.getJSONObject(i);
				
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j == 10) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				row.getCell(0).setCellValue(item.getString("DEAL_NO"));
				row.getCell(1).setCellValue(item.getString("DEAL_BATCH_NO"));
				row.getCell(2).setCellValue(item.getString("DEAL_CODE"));
				row.getCell(3).setCellValue(item.getString("BANK_ID"));
				row.getCell(4).setCellValue(item.getString("BANK_NAME"));
				row.getCell(5).setCellValue(item.getString("NAME"));
				row.getCell(6).setCellValue(item.getString("CERT_NO"));
				//
				String cardType = item.getString("CARD_TYPE");
				if (Constants.CARD_TYPE_QGN.equals(cardType)) {
					row.getCell(7).setCellValue("全功能卡");
				} else if (Constants.CARD_TYPE_SMZK.equals(cardType)) {
					row.getCell(7).setCellValue("金融市民卡");
				} else {
					row.getCell(7).setCellValue(cardType);
				}
				//
				row.getCell(8).setCellValue(item.getString("CARD_NO"));
				//
				String accKind = item.getString("ACC_KIND");
				if (Constants.ACC_KIND_QBZH.equals(accKind)) {
					row.getCell(9).setCellValue("市民卡钱包");
				} else if (Constants.ACC_KIND_ZJZH.equals(accKind)) {
					row.getCell(9).setCellValue("市民卡账户");
				} else {
					row.getCell(9).setCellValue(accKind);
				}
				//
				row.getCell(10).setCellValue(item.getDoubleValue("AMT") / 100);
				row.getCell(11).setCellValue(item.getString("ORDER_TIME"));
				row.getCell(12).setCellValue(item.getString("USER_ID"));
				row.getCell(13).setCellValue(item.getString("USER_NAME"));
				row.getCell(14).setCellValue(item.getString("END_DEAL_NO"));
				row.getCell(15).setCellValue(item.getString("CLR_DATE"));
				//
				String dealState = item.getString("DEAL_STATE");
				if ("01".equals(dealState)) {
					row.getCell(16).setCellValue("初始生成");
				} else if ("02".equals(dealState)) {
					row.getCell(16).setCellValue("已取消");
				} else if ("03".equals(dealState)) {
					row.getCell(16).setCellValue("待确认");
				} else if ("04".equals(dealState)) {
					row.getCell(16).setCellValue("正常");
				} else if ("05".equals(dealState)) {
					row.getCell(16).setCellValue("已对账");
				} else if ("06".equals(dealState)) {
					row.getCell(16).setCellValue("已撤销");
				} else if ("07".equals(dealState)) {
					row.getCell(16).setCellValue("未登项");
				} else if ("98".equals(dealState)) {
					row.getCell(16).setCellValue("可疑账");
				} else if ("99".equals(dealState)) {
					row.getCell(16).setCellValue("已删除");
				} else {
					row.getCell(16).setCellValue(dealState);
				}
				
				numSum += 1;
				amtSum += item.getDoubleValue("AMT");
			}
			
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if (j == 10) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(1).setCellValue("共 " + numSum + " 笔");
			row.getCell(10).setCellValue(amtSum / 100);
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String bankQcQtQfStat() {
		try {
			initBaseDataGrid();
			String bankIdSql = "";
			if(!Tools.processNull(bankIds).equals("")){
				String[] bankIdArr = bankIds.split(",");
				if (bankIdArr != null && bankIdArr.length > 0) {
					for (String bankId : bankIdArr) {
						bankIdSql += "'" + bankId + "',";
					}
					bankIdSql = bankIdSql.substring(0, bankIdSql.length() - 1);
				}
			}
			String sql = "select t.bank_id, min(t.bank_name) bank_name, t3.card_type, "
					+ "nvl(sum(decode(t2.deal_code, '30105010', decode(t2.deal_state, '05', 1), 0)), 0) ydz_qc_num, " // 已对账_圈存_笔数
					+ "nvl(sum(decode(t2.deal_code, '30105010', decode(t2.deal_state, '05', amt), 0)), 0) ydz_qc_amt, "
					+ "nvl(sum(decode(t2.deal_code, '30105090', decode(t2.deal_state, '05', 1), 0)), 0) ydz_qf_num, "
					+ "nvl(sum(decode(t2.deal_code, '30105090', decode(t2.deal_state, '05', amt), 0)), 0) ydz_qf_amt, "
					+ "nvl(sum(decode(t2.deal_code, '30105070', decode(t2.deal_state, '05', 1), 0)), 0) ydz_qt_num, "
					+ "nvl(sum(decode(t2.deal_code, '30105070', decode(t2.deal_state, '05', -amt), 0)), 0) ydz_qt_amt, "
					+ "nvl(sum(decode(t2.deal_code, '30105010', decode(t2.deal_state, '05', 0, 1), 0)), 0) wdz_qc_num, "
					+ "nvl(sum(decode(t2.deal_code, '30105010', decode(t2.deal_state, '05', 0, amt), 0)), 0) wdz_qc_amt, "
					+ "nvl(sum(decode(t2.deal_code, '30105090', decode(t2.deal_state, '05', 0, 1), 0)), 0) wdz_qf_num, "
					+ "nvl(sum(decode(t2.deal_code, '30105090', decode(t2.deal_state, '05', 0, amt), 0)), 0) wdz_qf_amt, "
					+ "nvl(sum(decode(t2.deal_code, '30105070', decode(t2.deal_state, '05', 0, 1), 0)), 0) wdz_qt_num, "
					+ "nvl(sum(decode(t2.deal_code, '30105070', decode(t2.deal_state, '05', 0, -amt), 0)), 0) wdz_qt_amt "
					+ "from base_bank t join pay_co_deal_rec t2 on t.bank_id = t2.dz_acpt_id "
					+ "join card_baseinfo t3 on t2.card_no = t3.card_no where 1 = 1 ";
			if(!Tools.processNull(bankId).equals("")){
				sql += "and t.bank_id = '" + bankId + "' ";
			}
			if(!Tools.processNull(bankIdSql).equals("")){
				sql += "and t.bank_id in (" + bankIdSql + ") ";
			}
			if(!Tools.processNull(beginTime).equals("")){
				sql += "and t2.clr_date >= '" + beginTime + "' ";
			}
			if(!Tools.processNull(endTime).equals("")){
				sql += "and t2.clr_date <= '" + endTime + "' ";
			}
			sql += "group by t.bank_id, t3.card_type ";
			if (!Tools.processNull(sort).equals("")) {
				sql += "order by " + sort;
				if (!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			} else {
				sql += "order by t.bank_id, t3.card_type";
			}
			
			Page pageData = baseService.pagingQuery(sql, page, rows);
			if (pageData.getAllRs() == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommonException("未查询到记录信息");
			}
			jsonObject.put("rows", pageData.getAllRs());
			jsonObject.put("total", pageData.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportBankQcQtQfStat() {
		try {
			bankQcQtQfStat();
			String fileName = "银行圈存圈提圈付统计";
			if(!Tools.processNull(bankId).equals("")){
				String brchName = (String) baseService.findOnlyFieldBySql("select bank_name from base_bank where bank_id = '" + bankId + "'");
				fileName = brchName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			String userAgent = request.getHeader("user-agent");
			if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
				response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
			} else {
				response.setHeader("Content-disposition", "attachment; filename=" + new String((fileName).getBytes("utf-8"), "iso8859-1") + ".xls");
			}
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 4000);
			sheet.setColumnWidth(1, 6000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(19, 3000);
			sheet.setColumnWidth(20, 3000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);
			
			// headCellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);

			// moneyCellStyle
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));
			
			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			// head row 1
			int maxColumn = 21;
			int headRows = 6;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			// second header
			sheet.getRow(1).getCell(0).setCellValue("统计时间：" + beginTime + " ~ " + endTime + "    导出时间：" + DateUtils.getNowTime());
			
			// third header
			sheet.getRow(2).getCell(0).setCellValue("银行编号");
			sheet.getRow(2).getCell(1).setCellValue("银行名称");
			sheet.getRow(2).getCell(2).setCellValue("卡类型");
			sheet.getRow(2).getCell(3).setCellValue("已对账");
			sheet.getRow(2).getCell(11).setCellValue("未对账");
			sheet.getRow(2).getCell(19).setCellValue("总计");
			
			//
			sheet.getRow(3).getCell(3).setCellValue("市民卡账户");
			sheet.getRow(3).getCell(9).setCellValue("已对账合计");
			sheet.getRow(3).getCell(11).setCellValue("市民卡账户");
			sheet.getRow(3).getCell(17).setCellValue("未对账合计");
			
			//
			sheet.getRow(4).getCell(3).setCellValue("圈存");
			sheet.getRow(4).getCell(5).setCellValue("圈付");
			sheet.getRow(4).getCell(7).setCellValue("圈提");
			sheet.getRow(4).getCell(9).setCellValue("笔数");
			sheet.getRow(4).getCell(10).setCellValue("金额");
			sheet.getRow(4).getCell(11).setCellValue("圈存");
			sheet.getRow(4).getCell(13).setCellValue("圈付");
			sheet.getRow(4).getCell(15).setCellValue("圈提");
			sheet.getRow(4).getCell(17).setCellValue("笔数");
			sheet.getRow(4).getCell(18).setCellValue("金额");
			
			//
			sheet.getRow(5).getCell(3).setCellValue("笔数");
			sheet.getRow(5).getCell(4).setCellValue("金额");
			sheet.getRow(5).getCell(5).setCellValue("笔数");
			sheet.getRow(5).getCell(6).setCellValue("金额");
			sheet.getRow(5).getCell(7).setCellValue("笔数");
			sheet.getRow(5).getCell(8).setCellValue("金额");
			sheet.getRow(5).getCell(11).setCellValue("笔数");
			sheet.getRow(5).getCell(12).setCellValue("金额");
			sheet.getRow(5).getCell(13).setCellValue("笔数");
			sheet.getRow(5).getCell(14).setCellValue("金额");
			sheet.getRow(5).getCell(15).setCellValue("笔数");
			sheet.getRow(5).getCell(16).setCellValue("金额");
			sheet.getRow(5).getCell(19).setCellValue("笔数");
			sheet.getRow(5).getCell(20).setCellValue("金额");
			
			// 第一行
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			// 第二行
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			// 第三行
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 1, 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 2, 2));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 3, 10));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 11, 18));
			sheet.addMergedRegion(new CellRangeAddress(2, 4, 19, 20));
			// 第四行
			sheet.addMergedRegion(new CellRangeAddress(3, 3, 3, 8));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, 9, 10));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, 11, 16));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, 17, 18));
			// 第五行
			sheet.addMergedRegion(new CellRangeAddress(4, 4, 3, 4));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, 5, 6));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, 7, 8));
			sheet.addMergedRegion(new CellRangeAddress(4, 5, 9, 9));
			sheet.addMergedRegion(new CellRangeAddress(4, 5, 10, 10));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, 11, 12));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, 13, 14));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, 15, 16));
			sheet.addMergedRegion(new CellRangeAddress(4, 5, 17, 17));
			sheet.addMergedRegion(new CellRangeAddress(4, 5, 18, 18));
			//
			sheet.createFreezePane(3, 6);
			int ydzQcNumSum = 0;
			double ydzQcAmtSum = 0;
			int ydzQfNumSum = 0;
			double ydzQfAmtSum = 0;
			int ydzQtNumSum = 0;
			double ydzQtAmtSum = 0;
			int wdzQcNumSum = 0;
			double wdzQcAmtSum = 0;
			int wdzQfNumSum = 0;
			double wdzQfAmtSum = 0;
			int wdzQtNumSum = 0;
			double wdzQtAmtSum = 0;
			for (int i = 0; i < data.size(); i++) {
				JSONObject item = data.getJSONObject(i);
				
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j > 3 && j % 2 == 0) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				row.getCell(0).setCellValue(item.getString("BANK_ID"));
				row.getCell(1).setCellValue(item.getString("BANK_NAME"));
				if(Constants.CARD_TYPE_QGN.equals(item.getString("CARD_TYPE"))){
					row.getCell(2).setCellValue("全功能卡");
				} else if(Constants.CARD_TYPE_SMZK.equals(item.getString("CARD_TYPE"))){
					row.getCell(2).setCellValue("金融市民卡");
				} else {
					row.getCell(2).setCellValue(item.getString("CARD_TYPE"));
				}
				
				int ydzQcNum = item.getIntValue("YDZ_QC_NUM");
				double ydzQcAmt = item.getDoubleValue("YDZ_QC_AMT");
				row.getCell(3).setCellValue(ydzQcNum);
				row.getCell(4).setCellValue(ydzQcAmt / 100);
				ydzQcNumSum += ydzQcNum;
				ydzQcAmtSum += ydzQcAmt;
				//
				int ydzQfNum = item.getIntValue("YDZ_QF_NUM");
				double ydzQfAmt = item.getDoubleValue("YDZ_QF_AMT");
				row.getCell(5).setCellValue(ydzQfNum);
				row.getCell(6).setCellValue(ydzQfAmt / 100);
				ydzQfNumSum += ydzQfNum;
				ydzQfAmtSum += ydzQfAmt;
				//
				int ydzQtNum = item.getIntValue("YDZ_QT_NUM");
				double ydzQtAmt = item.getDoubleValue("YDZ_QT_AMT");
				row.getCell(7).setCellValue(ydzQtNum);
				row.getCell(8).setCellValue(ydzQtAmt / 100);
				ydzQtNumSum += ydzQtNum;
				ydzQtAmtSum += ydzQtAmt;
				//
				row.getCell(9).setCellValue(ydzQcNum + ydzQfNum + ydzQtNum);
				row.getCell(10).setCellValue((ydzQcAmt + ydzQfAmt + ydzQtAmt) / 100);
				//
				int wdzQcNum = item.getIntValue("WDZ_QC_NUM");
				double wdzQcAmt = item.getDoubleValue("WDZ_QC_AMT");
				row.getCell(11).setCellValue(wdzQcNum);
				row.getCell(12).setCellValue(wdzQcAmt / 100);
				wdzQcNumSum += wdzQcNum;
				wdzQcAmtSum += wdzQcAmt;
				//
				int wdzQfNum = item.getIntValue("WDZ_QF_NUM");
				double wdzQfAmt = item.getDoubleValue("WDZ_QF_AMT");
				row.getCell(13).setCellValue(wdzQfNum);
				row.getCell(14).setCellValue(wdzQfAmt / 100);
				wdzQfNumSum += wdzQfNum;
				wdzQfAmtSum += wdzQfAmt;
				//
				int wdzQtNum = item.getIntValue("WDZ_QT_NUM");
				double wdzQtAmt = item.getDoubleValue("WDZ_QT_AMT");
				row.getCell(15).setCellValue(wdzQtNum);
				row.getCell(16).setCellValue(wdzQtAmt / 100);
				wdzQtNumSum += wdzQtNum;
				wdzQtAmtSum += wdzQtAmt;
				//
				row.getCell(17).setCellValue(wdzQcNum + wdzQfNum + wdzQtNum);
				row.getCell(18).setCellValue((wdzQcAmt + wdzQfAmt + wdzQtAmt) / 100);
				//
				row.getCell(19).setCellValue(ydzQcNum + ydzQfNum + ydzQtNum + wdzQcNum + wdzQfNum + wdzQtNum);
				row.getCell(20).setCellValue((ydzQcAmt + ydzQfAmt + ydzQtAmt + wdzQcAmt + wdzQfAmt + wdzQtAmt) / 100);
			}
			
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if (j > 3 && j % 2 == 0) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(3).setCellValue(ydzQcNumSum);
			row.getCell(4).setCellValue(ydzQcAmtSum / 100);
			row.getCell(5).setCellValue(ydzQfNumSum);
			row.getCell(6).setCellValue(ydzQfAmtSum / 100);
			row.getCell(7).setCellValue(ydzQtNumSum);
			row.getCell(8).setCellValue(ydzQtAmtSum / 100);
			row.getCell(9).setCellValue(ydzQcNumSum + ydzQfNumSum + ydzQtNumSum);
			row.getCell(10).setCellValue((ydzQcAmtSum + ydzQfAmtSum + ydzQtAmtSum) / 100);
			row.getCell(11).setCellValue(wdzQcNumSum);
			row.getCell(12).setCellValue(wdzQcAmtSum / 100);
			row.getCell(13).setCellValue(wdzQfNumSum);
			row.getCell(14).setCellValue(wdzQfAmtSum / 100);
			row.getCell(15).setCellValue(wdzQtNumSum);
			row.getCell(16).setCellValue(wdzQtAmtSum / 100);
			row.getCell(17).setCellValue(wdzQcNumSum + wdzQfNumSum + wdzQtNumSum);
			row.getCell(18).setCellValue((wdzQcAmtSum + wdzQfAmtSum + wdzQtAmtSum) / 100);
			row.getCell(19).setCellValue(ydzQcNumSum + ydzQfNumSum + ydzQtNumSum + wdzQcNumSum + wdzQfNumSum + wdzQtNumSum);
			row.getCell(20).setCellValue((ydzQcAmtSum + ydzQfAmtSum + ydzQtAmtSum + wdzQcAmtSum + wdzQfAmtSum + wdzQtAmtSum) / 100);
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String qbRechgByClr(){
		try {
			initBaseDataGrid();
			if(!this.queryType.equals("0")){
				return this.JSONOBJ;
			}
			String dealNoSql = "";
			if(!Tools.processNull(dealNo).equals("")){
				String[] dealNoArr = dealNo.split(",");
				for (String dealNos : dealNoArr) {
					dealNoSql += "'" + dealNos + "',";
				}
				dealNoSql = dealNoSql.substring(0, dealNoSql.length() - 1);
			}
			
			String sql = "select t.deal_no, t.cr_customer_id, t3.name, t3.cert_no, t.acpt_id, t.cr_acc_kind, t2.card_no card_no2, "
					+ "decode(t.acpt_type, '1', (select full_name from sys_branch where brch_id = t.acpt_id), '2', (select co_org_name from base_co_org where co_org_id = t.acpt_id), t.acpt_id) acpt_name, "
					+ "t.deal_code, t4.deal_code_name, t.cr_card_no card_no, t.cr_card_type, "
					+ "(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.cr_card_type) card_type, "
					+ "(select code_name from sys_code where code_type = 'ACC_KIND' and code_value = t.cr_acc_kind) acc_kind, "
					+ "t.cr_acc_bal, t.cr_amt, t.deal_date, t.clr_date, t.deal_state, t2.acpt_id acpt_id2, "
					+ "decode(t2.acpt_type, '1', (select full_name from sys_branch where brch_id = t2.acpt_id), '2', (select co_org_name from base_co_org where co_org_id = t2.acpt_id), t2.acpt_id) acpt_name2, "
					+ "(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t2.card_type) card_type2, "
					+ "(select code_name from sys_code where code_type = 'ACC_KIND' and code_value = t2.acc_kind) acc_kind2, "
					+ "t2.acc_bal acc_bal2, t2.amt amt2, t2.deal_date deal_date2, t2.clr_date clr_date2, t2.deal_state deal_state2 "
					+ "from acc_inout_detail_" + clrStartDate.replaceAll("-", "") + " t left join pay_card_deal_rec_" + clrStartDate.replaceAll("-", "") + " t2 on t.acc_inout_no = t2.acc_inout_no "
					+ "join base_personal t3 on t.cr_customer_id = t3.customer_id "
					+ "join sys_code_tr t4 on t.deal_code = t4.deal_code "
					+ "where t.deal_code in ('30105020', '30105021', '30101010', '30101011') ";
			if(!Tools.processNull(acptType).equals("")){
				sql += "and t.acpt_type = '" + acptType + "' ";
			}
			if(!Tools.processNull(branchId).equals("")){
				sql += "and t.acpt_id = '" + branchId + "' ";
			}
			if(!Tools.processNull(dealNoSql).equals("")){
				sql += "and t.deal_no in (" + dealNoSql + ") ";
			}
			if(!Tools.processNull(coOrgId).equals("")){
				sql += "and t.acpt_id = '" + coOrgId + "' ";
			}
			sql += "order by t2.id desc, t.acc_inout_no desc";
			Page pageData = baseService.pagingQuery(sql, page, rows);
			if (pageData.getAllRs() == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommonException("未查询到记录信息");
			}
			jsonObject.put("rows", pageData.getAllRs());
			jsonObject.put("total", pageData.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public static List<String> getMonths(String startDateStr, String endDateStr){
		try {
			List<String> months = new ArrayList<String>();
			
			Calendar clrStartDate = Calendar.getInstance();
			clrStartDate.setTime(DateUtil.formatDate(startDateStr));
			clrStartDate.set(Calendar.DAY_OF_MONTH, 1);
			
			Calendar clrEndDate = Calendar.getInstance();
			clrEndDate.setTime(DateUtil.formatDate(endDateStr));
			clrEndDate.set(Calendar.DAY_OF_MONTH, 1);
			
			while(clrStartDate.compareTo(clrEndDate) <= 0){
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
	
	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
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

	public String getReportTitle() {
		return reportTitle;
	}

	public void setReportTitle(String reportTitle) {
		this.reportTitle = reportTitle;
	}

	public BaseService getBaseService() {
		return baseService;
	}

	public void setBaseService(BaseService baseService) {
		this.baseService = baseService;
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
	public String getTimeRange() {
		return timeRange;
	}
	public void setTimeRange(String timeRange) {
		this.timeRange = timeRange;
	}
	public String getAccKind() {
		return accKind;
	}
	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}
	public String getCardNo() {
		return cardNo;
	}
	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}
	public String getCardType() {
		return cardType;
	}
	public void setCardType(String cardType) {
		this.cardType = cardType;
	}
	public String getDealNo() {
		return dealNo;
	}
	public void setDealNo(String dealNo) {
		this.dealNo = dealNo;
	}
	public TrServRec getRec() {
		return rec;
	}
	public void setRec(TrServRec rec) {
		this.rec = rec;
	}
	public CardBlack getCardBlaack() {
		return cardBlaack;
	}
	public void setCardBlaack(CardBlack cardBlaack) {
		this.cardBlaack = cardBlaack;
	}
	public SysActionLog getSysLog() {
		return sysLog;
	}
	public void setSysLog(SysActionLog sysLog) {
		this.sysLog = sysLog;
	}
	public static void main(String[] args) throws Exception {
		/*String datestring = "2015-06-09";
		Date date = DateUtil.parse("yyyy-MM-dd",datestring);
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
		int cz = 0;
		switch(cal.get(Calendar.DAY_OF_WEEK)){
			case 1 : cz = 6;break;//7
			case 2 : cz = 0;break;//1
			case 3 : cz = 1;break;//2
			case 4 : cz = 2;break;//3
			case 5 : cz = 3;break;//4
			case 6 : cz = 4;break;//5
			default: cz = 6;//6
		}
		System.out.println(cal.get(Calendar.DAY_OF_WEEK));
		System.out.println(cz);
		cal.add(Calendar.DAY_OF_YEAR, -cz);
		System.out.println(DateUtil.formatDate(cal.getTime(),"yyyy-MM-dd"));*/
		System.out.println(getLastDayOfMonth(DateUtil.parse("yyyyMMdd","20160201")));
		//System.out.println(StatisticalAnalysisAction.getFirstDayOfWeek(new Date()));
	}
	/**
	 * 获取本周第一天
	 * @param date
	 * @return
	 */
	public static String getFirstDayOfWeek(Date date) throws Exception{
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
		int cz = 0;
		switch(cal.get(Calendar.DAY_OF_WEEK)){
			case 1 : cz = 6;break;//7
			case 2 : cz = 0;break;//1
			case 3 : cz = 1;break;//2
			case 4 : cz = 2;break;//3
			case 5 : cz = 3;break;//4
			case 6 : cz = 4;break;//5
			case 7 : cz = 5;break;//6
			default: cz = 6;//6
		}
		cal.add(Calendar.DAY_OF_YEAR, -cz);
		SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd");
		return f.format(cal.getTime());
	}
	/**
	 * 获取本周最后一天
	 * @param date
	 * @return
	 */
	public static String getLastDayOfWeek(Date date) throws Exception{
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
		int cz = 0;
		switch(cal.get(Calendar.DAY_OF_WEEK)){
			case 1 : cz = 0;break;//7
			case 2 : cz = 6;break;//1
			case 3 : cz = 5;break;//2
			case 4 : cz = 4;break;//3
			case 5 : cz = 3;break;//4
			case 6 : cz = 2;break;//5
			case 7 : cz = 1;break;//6
			default: cz = 6;//6
		}
		cal.add(Calendar.DAY_OF_YEAR,cz);
		SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd");
		return f.format(cal.getTime());
	}
	/**
	 * 获取本月最后一天
	 * @param date
	 * @return
	 */
	public static String getLastDayOfMonth(Date date) throws Exception{
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
		cal.add(Calendar.MONTH,1);
		cal.add(Calendar.DAY_OF_YEAR,-cal.get(Calendar.DAY_OF_MONTH));
		SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd");
		return f.format(cal.getTime());
	}
	/**
	 * 获取本月第一天
	 * @param date
	 * @return
	 */
	public static String getFirstDayOfMonth(Date date) throws Exception{
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
		cal.add(Calendar.DAY_OF_YEAR,-cal.get(Calendar.DAY_OF_MONTH));
		cal.add(Calendar.DAY_OF_YEAR,1);
		SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd");
		return f.format(cal.getTime());
	}
	public String getAcptType() {
		return acptType;
	}
	public void setAcptType(String acptType) {
		this.acptType = acptType;
	}
	public String getCoOrgId() {
		return coOrgId;
	}
	public void setCoOrgId(String coOrgId) {
		this.coOrgId = coOrgId;
	}
	public String getEndSerNo() {
		return endSerNo;
	}
	public void setEndSerNo(String endSerNo) {
		this.endSerNo = endSerNo;
	}
	public String getDealCode() {
		return dealCode;
	}
	public void setDealCode(String dealCode) {
		this.dealCode = dealCode;
	}
	public String getDealNos() {
		return bankIds;
	}
	public void setDealNos(String dealNos) {
		this.bankIds = dealNos;
	}
	public BaseCorp getBaseCorp() {
		return baseCorp;
	}
	public void setBaseCorp(BaseCorp baseCorp) {
		this.baseCorp = baseCorp;
	}
	public boolean isCascadeBrch() {
		return cascadeBrch;
	}
	
	public void setCascadeBrch(boolean cascadeBrch) {
		this.cascadeBrch = cascadeBrch;
	}
	public String getBranchIds() {
		return branchIds;
	}
	public void setBranchIds(String branchIds) {
		this.branchIds = branchIds;
	}
	public String getBankId() {
		return bankId;
	}
	public void setBankId(String bankId) {
		this.bankId = bankId;
	}
	public String getClrStartDate() {
		return clrStartDate;
	}
	public void setClrStartDate(String clrStartDate) {
		this.clrStartDate = clrStartDate;
	}
	public String getClrEndDate() {
		return clrEndDate;
	}
	public void setClrEndDate(String clrEndDate) {
		this.clrEndDate = clrEndDate;
	}
	public String getBankIds() {
		return bankIds;
	}
	public void setBankIds(String bankIds) {
		this.bankIds = bankIds;
	}
	public String getApplyState() {
		return applyState;
	}
	public void setApplyState(String applyState) {
		this.applyState = applyState;
	}
}
