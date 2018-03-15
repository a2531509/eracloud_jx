package com.erp.action;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.DataFormat;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.shiro.SecurityUtils;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.ctc.wstx.util.DataUtil;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.CardAppBind;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardInsuranceInfo;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.service.ZxcService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.ExcelUtil;
import com.erp.util.JsonHelper;
import com.erp.util.Tools;
import com.erp.viewModel.Page;
import com.erp.viewModel.ZxcModel;

@SuppressWarnings("serial")
@Namespace("/zxcApp")
@Action(value = "ZxcAppAction")
@Results({@Result(type="json",name="json"),
@Result(name="viewTask",location="/jsp/zxcApp/viewzxc.jsp")})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class ZxcAppAction extends BaseAction {
	private ZxcService zxcService;
	private String queryType="1";//查询标志
	private String startDate="";
	private String endDate="";
	private BasePersonal personal=new BasePersonal();
	private ZxcModel zxcModel=new ZxcModel();
	private CardAppBind cardAppBind=new CardAppBind();
	private String certNo="",cardNo="",costFee="",mobileNo="",cancle_reason="",customerId;
	private String name = "";
	private String insuranceNo = "";
	private File file = null;
	private String dealNo;
	private String state;
	private String source;
	private String selectId;
	private boolean statByDay = false;
	
	/**
	 * 查询任务信息
	 * @return
	 */
	public String queryZxc(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		BasePersonal person=new BasePersonal();
		try{//0网点1社区2单位3学校
			if(this.queryType.equals("0")){
				String head="",htj="";
				head = " select r.customer_id,r.customer_name,r.cert_no,r.card_no,r.card_type, (select s.deal_code_name from sys_code_tr s where s.deal_code=r.deal_code) app_name,t.bind_date,t.brch_id,t.user_id ";
				htj = " from CARD_APP_BIND t,tr_serv_rec r where t.deal_no=r.deal_no and t.bind_state='0' ";
		
				if(!Tools.processNull(cardNo).equals("")){
					htj+=" and r.card_No = '"+cardNo+"'";
					person=(BasePersonal)baseService.findOnlyRowByHql("select b from BasePersonal b,CardBaseinfo c  where c.customerId=b.customerId and  c.cardNo = '" + cardNo + "'");
				}
				if(!Tools.processNull(certNo).equals("")){
					htj+=" and r.cert_No = '"+certNo+"'";
					person=(BasePersonal)baseService.findOnlyRowByHql("from BasePersonal b where   b.certNo = '" + certNo + "'");
				}
				htj+=" order by t.bind_date desc, r.biz_time desc ";
				Page list = zxcService.pagingQuery(head+htj.toString(),page,rows);
				//获取人员基本信息
				
				if(null != person){
					jsonObject.put("certNo",person.getCertNo());
					jsonObject.put("certType",baseService.getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType()));
					jsonObject.put("name",person.getName());
					jsonObject.put("gender",person.getGenderName());
					jsonObject.put("mobileNo",person.getMobileNo());
					jsonObject.put("resideType",person.getResideTypeName());
					jsonObject.put("letterAddr", Tools.processNull(person.getLetterAddr()).equals("")?person.getResideAddr():person.getLetterAddr());
					jsonObject.put("customerId",person.getCustomerId());
				}
				String costFeeStr=(String)zxcService.findOnlyFieldBySql("select to_char(nvl(t.debit_amt,0)) as debit_amt from CARD_APP_BIND_CONF t where t.app_id='05' and t.debit_flag='0' ");
				jsonObject.put("costFee",Arith.cardreportsmoneydiv(Tools.processNull(costFeeStr).equals("")?"0":Tools.processNull(costFeeStr)) );
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
	/**
	 * 自行车应用开通
	 * @return
	 */
	public String saveZxcOpen(){
		jsonObject.put("status","0");
		jsonObject.put("msg","开通成功");
		jsonObject.put("title","开通成功信息");
		try {
			personal=(BasePersonal)baseService.findOnlyRowByHql("from BasePersonal b where   b.customerId = '" + customerId + "'");
			CardBaseinfo card=(CardBaseinfo)baseService.findOnlyRowByHql("from CardBaseinfo c where   c.customerId = '" + customerId + "'");
			zxcModel.setAmt(costFee);
			zxcModel.setCardno(card.getCardNo());
			zxcModel.setCancle_reason(cancle_reason);
			//查询客户选中任务列表
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(zxcService.getSysBranchByUserId().getBrchId());
			zxcModel.setOperid(actionLog.getUserId());
			TrServRec trServRec = zxcService.saveZxcOpen(personal, actionLog, zxcModel);
			jsonObject.put("dealNo", trServRec.getDealNo());
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
			jsonObject.put("title","开通失败");
		}
		OutputJson(jsonObject,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	/**
	 * 自行车应用取消
	 * @return
	 */
	public String saveZxcCancel(){
		jsonObject.put("status","0");
		jsonObject.put("msg","取消保存成功");
		jsonObject.put("title","取消保存信息");
		try {
			personal=(BasePersonal)baseService.findOnlyRowByHql("from BasePersonal b where   b.customerId = '" + customerId + "'");
			CardBaseinfo card=(CardBaseinfo)baseService.findOnlyRowByHql("from CardBaseinfo c where   c.customerId = '" + customerId + "'");
			zxcModel.setAmt(costFee);
			zxcModel.setCardno(card.getCardNo());
			zxcModel.setCancle_reason(cancle_reason);
			//查询客户选中任务列表
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(zxcService.getSysBranchByUserId().getBrchId());
			zxcModel.setAmt(costFee);
			zxcModel.setCancle_reason(cancle_reason);
			zxcService.saveZxcCancel(personal, actionLog, zxcModel);
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
			jsonObject.put("title","取消保存失败信息");
		}
		OutputJson(jsonObject,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	/**
	 * 应用绑定查询
	 * @return
	 */
	public String queryAllAppBind(){
		try{
			this.initBaseDataGrid();
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT T.DEAL_NO,b.CUSTOMER_ID,b.NAME,(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'SEX' AND CODE_VALUE = B.GENDER) SEX,M.FULL_NAME,N.NAME OPERNAME,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CERT_TYPE' AND CODE_VALUE = b.CERT_TYPE) certtype,b.CERT_NO,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CARD_TYPE' AND CODE_VALUE = c.CARD_TYPE) cardtype,c.CARD_NO,");
			sb.append("to_char(t.BIND_DATE,'yyyy-mm-dd hh24:mi:ss') binddate,");
			sb.append("(CASE t.APP_TYPE WHEN '01' THEN '广电' WHEN '02' THEN '自来水' WHEN '03' THEN '电力' WHEN '04' THEN '过路过桥' ");
			sb.append("WHEN '05' THEN '自行车' WHEN '06' THEN '移动' END) BINDTYPE,DECODE(Bind_State,'0','绑定','1','未绑定') BINDSTATE ");
			sb.append("FROM CARD_APP_BIND t,CARD_BASEINFO C,BASE_PERSONAL B,SYS_BRANCH M,SYS_USERS N ");
			sb.append("WHERE T.CARD_NO = C.CARD_NO AND C.CUSTOMER_ID = B.CUSTOMER_ID AND T.BRCH_ID = M.BRCH_ID ");
			sb.append("AND t.USER_ID = N.USER_ID ");
			if(!Tools.processNull(cardAppBind.getBrchId()).equals("")){
				sb.append("and t.brch_id = '" + cardAppBind.getBrchId() + "' ");
			}
			if(!Tools.processNull(cardAppBind.getUserId()).equals("")){
				sb.append("and t.user_id = '" + cardAppBind.getUserId() + "' ");
			}
			if(!Tools.processNull(cardAppBind.getAppType()).equals("")){
				sb.append("and t.app_type = '" + cardAppBind.getAppType() + "' ");
			}
			if(!Tools.processNull(cardAppBind.getMerchantId()).equals("")){
				sb.append("and t.merchant_id = '" + cardAppBind.getMerchantId() + "' ");
			}
			if(!Tools.processNull(cardAppBind.getBindState()).equals("")){
				sb.append("and t.Bind_State = '" + cardAppBind.getBindState() + "' ");
			}
			if(!Tools.processNull(cardAppBind.getCardNo()).equals("")){
				sb.append("and t.card_no = '" + cardAppBind.getCardNo() + "' ");
			}
			if(!Tools.processNull(personal.getCertNo()).equals("")){
				sb.append("and b.cert_no = '" + personal.getCertNo() + "' ");
			}
			if(!Tools.processNull(cardAppBind.getDealNo()).equals("")){
				sb.append("and t.deal_no = '" + cardAppBind.getDealNo() + "' ");
			}
			if(!Tools.processNull(this.startDate).equals("")){
				sb.append("and to_char(t.BIND_DATE,'yyyy-mm-dd') >= '" + this.startDate + "' ");
			}
			if(!Tools.processNull(this.endDate).equals("")){
				sb.append("and to_char(t.BIND_DATE,'yyyy-mm-dd') <= '" + this.endDate + "' ");
			}
			Page list = baseService.pagingQuery(sb.toString(), page, rows);
			if(list.getAllRs() != null && list.getTotalCount() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据条件未找到记录信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String queryCardInsurance(){
		try {
			initBaseDataGrid();
			String selectSql = "";
			if (!Tools.processNull(selectId).equals("")) {
				String[] selectArr = selectId.split(",");
				for (String select : selectArr) {
					selectSql += "'" + select + "',";
				}
				if(!selectSql.equals("")){
					selectSql = selectSql.substring(0, selectSql.length() - 1);
				}
			}
			String sql = "select t3.customer_id, t3.name, t3.cert_no, t2.card_no, t2.card_type, t.deal_no, t.state, amt, t2.sub_card_no, "
					+ "t.insurance_no, t.insurance_kind, to_char(t.insured_date, 'yyyy-mm-dd hh24:mi:ss') insured_date, t3.mobile_no, t.note, "
					+ "to_char(t.start_date, 'yyyy-mm-dd') start_date, to_char(t.end_date, 'yyyy-mm-dd') end_date, t.order_no, t.source "
					+ "from card_insurance_info t join card_baseinfo t2 on t.card_no = t2.card_no "
					+ "join base_personal t3 on t2.customer_id = t3.customer_id where 1 = 1 ";
			if(!Tools.processNull(certNo).equals("")) {
				sql += "and t3.cert_no = '" + certNo + "' ";
			}
			if(!Tools.processNull(name).equals("")) {
				sql += "and t3.name = '" + name + "' ";
			}
			if(!Tools.processNull(cardNo).equals("")) {
				sql += "and t2.card_no = '" + cardNo + "' ";
			}
			if(!Tools.processNull(insuranceNo).equals("")) {
				sql += "and t.insurance_no = '" + insuranceNo + "' ";
			}
			if(!Tools.processNull(source).equals("")) {
				sql += "and t.source = '" + source + "' ";
			}
			if(!Tools.processNull(startDate).equals("")) {
				sql += "and t.insured_date >= to_date('" + startDate + "', 'yyyy-mm-dd') ";
			}
			if(!Tools.processNull(endDate).equals("")) {
				sql += "and t.insured_date <= to_date('" + endDate + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			if(!Tools.processNull(state).equals("")) {
				sql += "and t.state = '" + state + "' ";
			}
			if(!Tools.processNull(selectSql).equals("")) {
				sql += "and t.card_no||t.insurance_no in (" + selectSql + ") ";
			}
			if(!Tools.processNull(sort).equals("")) {
				sql += "order by '" + sort + "' ";
				if(!Tools.processNull(order).equals("")) {
					sql += order;
				}
			} else {
				sql += "order by insured_date desc";
			}
			Page list = baseService.pagingQuery(sql, page, rows);
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
	
	public String importCardInsurance(){
		try {
			jsonObject.put("status", "0");
			if (file == null) {
				throw new CommonException("上传文件为空.");
			}
			ExcelUtil<CardInsuranceInfo> excelUtil = new ExcelUtil<CardInsuranceInfo>(CardInsuranceInfo.class);
			List<CardInsuranceInfo> list = excelUtil.importExcel("sheet1", new FileInputStream(file));
			if (list == null || list.isEmpty()) {
				throw new CommonException("导入数据为空.");
			}

			List<CardInsuranceInfo> failList = zxcService.saveCardInsurance(list);
			if (failList != null && !failList.isEmpty()) {
				jsonObject.put("msg", "共" + list.size() + "条记录, 成功" + (list.size() - failList.size()) + "条, 失败" + failList.size() + "条.");
				jsonObject.put("failList", JsonHelper.parse2JSON(failList));
			}
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}

		return JSONOBJ;
	}
	
	public String deleteCardInsurance(){
		try {
			jsonObject.put("status", "0");
			if (Tools.processNull(dealNo).equals("")) {
				throw new CommonException("请选择一条记录！");
			}
			zxcService.deleteCardInsurance(dealNo);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}

		return JSONOBJ;
	}
	
	public String exportCardInsurance() {
		try {
			rows = 65500;
			queryCardInsurance();
			JSONArray data = (JSONArray) jsonObject.get("rows");
			
			//
			JSONObject r = data.getJSONObject(0);
			if(r == null){
				throw new Exception("没有记录！");
			}
			String fileName = "保险数据";
			//
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

			sheet.setColumnWidth(0, 1500);
			sheet.setColumnWidth(1, 2500);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 5500);
			sheet.setColumnWidth(4, 3500);
//			sheet.setColumnWidth(5, 6000);
//			sheet.setColumnWidth(6, 4000);
			sheet.setColumnWidth(5, 3000);
//			sheet.setColumnWidth(8, 4000);

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
			int maxColumn = 6;
			int headRows = 1;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}

			// third header
			sheet.getRow(0).getCell(0).setCellValue("序号");
			sheet.getRow(0).getCell(1).setCellValue("姓名");
			sheet.getRow(0).getCell(2).setCellValue("市民卡号");
			sheet.getRow(0).getCell(3).setCellValue("证件号码");
			sheet.getRow(0).getCell(4).setCellValue("电话号码");
//			sheet.getRow(0).getCell(5).setCellValue("参保 / 购买日期");
//			sheet.getRow(0).getCell(6).setCellValue("参保状态");
			sheet.getRow(0).getCell(5).setCellValue("来源");
//			sheet.getRow(0).getCell(8).setCellValue("备注");

			// 
			sheet.createFreezePane(4, headRows);
			
			// data
			for (int i = 0; i < data.size(); i++) {
				// cell
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(cellStyle);
				}
				// data
				JSONObject item = data.getJSONObject(i);
				row.getCell(0).setCellValue(i+1);
				row.getCell(1).setCellValue(item.getString("NAME"));
				row.getCell(2).setCellValue(item.getString("SUB_CARD_NO"));
				row.getCell(3).setCellValue(item.getString("CERT_NO"));
				row.getCell(4).setCellValue(item.getString("MOBILE_NO"));
//				row.getCell(5).setCellValue(item.getString("INSURED_DATE"));
//				String insureState = item.getString("STATE");
//				if (insureState.equals("0")) {
//					insureState = "已购买未生效";
//				} else if (insureState.equals("1")) {
//					insureState = "已购买已生效";
//				}
//				row.getCell(6).setCellValue(insureState);
				String source = item.getString("SOURCE");
				if (source.equals("0")) {
					source = "微信购买";
				} else {
					source = "其它渠道【" + source + "】";
				}
				row.getCell(5).setCellValue(source);
//				row.getCell(8).setCellValue(item.getString("NOTE"));
			}

			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportCardInsurance",Constants.YES_NO_YES);
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String queryCardInsuranceStat() {
		try {
			initBaseDataGrid();
			String sql = "select nvl(to_char(min(insured_date), 'yyyy-mm-dd'), '" + startDate + "') startdate, nvl(to_char(max(insured_date), 'yyyy-mm-dd'), '" + endDate + "') enddate, count(1) count, sum(amt) sumamt, source "
					+ "from (select i.*, to_char(insured_date, 'yyyy-mm-dd') insured_day from card_insurance_info i where source = '0' ";
			if (!Tools.processNull(startDate).equals("")) {
				sql += "and i.insured_date >= to_date('" + startDate + "', 'yyyy-mm-dd') ";
			}
			if (!Tools.processNull(endDate).equals("")) {
				sql += "and i.insured_date <= to_date('" + endDate + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			sql += ") t where 1 = 1 ";
			sql += "group by source ";
			if(statByDay) {
				sql += ", insured_day ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			} else {
				sql += "order by startdate desc";
			}
			Page list = baseService.pagingQuery(sql, page, rows);
			if (list.getAllRs() == null || list.getAllRs().isEmpty()) {
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
	
	public String exportCardInsDataStat(){
		try {
			queryCardInsurance();
			JSONArray data = (JSONArray) jsonObject.get("rows");
			
			//
			String fileName = "微信购买保险数据";
			//
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

			sheet.setColumnWidth(0, 1000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 6000);
			sheet.setColumnWidth(4, 4000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 6000);
			sheet.setColumnWidth(7, 8000);
			sheet.setColumnWidth(8, 3000);

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
			
			// moneyCellStyle
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));

			// head row 1
			int maxColumn = 9;
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
			String string = "参保 / 购买时间：" + startDate + " ~ " + endDate;
			string += "    导出时间：" + DateUtil.formatDate(new Date());
			sheet.getRow(1).getCell(0).setCellValue(string);

			// third header
			sheet.getRow(2).getCell(0).setCellValue("序号");
			sheet.getRow(2).getCell(1).setCellValue("姓名");
			sheet.getRow(2).getCell(2).setCellValue("市民卡号");
			sheet.getRow(2).getCell(3).setCellValue("证件号码");
			sheet.getRow(2).getCell(4).setCellValue("电话号码");
			sheet.getRow(2).getCell(5).setCellValue("金额");
			sheet.getRow(2).getCell(6).setCellValue("参保 / 购买日期");
			sheet.getRow(2).getCell(7).setCellValue("商户订单号");
			sheet.getRow(2).getCell(8).setCellValue("来源");

			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			
			// data
			double sumAmt = 0;
			int count = 0;
			for (int i = 0; i < data.size(); i++, count++) {
				// cell
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if(j == 5){
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				// data
				JSONObject item = data.getJSONObject(i);
				row.getCell(0).setCellValue(i + 1);
				row.getCell(1).setCellValue(item.getString("NAME"));
				row.getCell(2).setCellValue(item.getString("SUB_CARD_NO"));
				row.getCell(3).setCellValue(item.getString("CERT_NO"));
				row.getCell(4).setCellValue(item.getString("MOBILE_NO"));
				//
				double amt = item.getDoubleValue("AMT");
				row.getCell(5).setCellValue(amt / 100);
				sumAmt += amt;
				//
				row.getCell(6).setCellValue(item.getString("INSURED_DATE"));
				row.getCell(7).setCellValue(item.getString("ORDER_NO"));
				//
				String source = item.getString("SOURCE");
				if(source.equals("0")){
					source = "微信购买";
				} else {
					source = "其它渠道【" + source + "】";
				}
				row.getCell(8).setCellValue(source);
			}

			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if(j == 5){
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(1).setCellValue("共 " + count + " 条记录");
			row.getCell(5).setCellValue(sumAmt / 100);
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportCardInsDataStat",Constants.YES_NO_YES);
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportCardInsDataStat2(){
		try {
			// day list
			List<String> dayList = new ArrayList<String>();
			String start = startDate;
			String end = endDate;
			while (start.compareTo(end) <= 0) {
				dayList.add(start);
				start = DateUtil.processDateAddDay(start, 1);
			}
			//
			String fileName = startDate + " ~ " + endDate + " 保险业务汇总表";
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

			sheet.setColumnWidth(0, 4000);
			sheet.setColumnWidth(1, 4000);
			sheet.setColumnWidth(2, 4000);

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
			
			// moneyCellStyle
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));

			// head row 1
			int maxColumn = 3;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				row.setHeight((short) 300);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			sheet.getRow(0).getCell(0).setCellValue(fileName);

			// second header
			sheet.getRow(1).getCell(0).setCellValue("交易日期");
			sheet.getRow(1).getCell(1).setCellValue("保险业务");

			// third header
			sheet.getRow(2).getCell(1).setCellValue("交易量（笔）");
			sheet.getRow(2).getCell(2).setCellValue("交易金额（元）");

			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 2, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 1, 2));
			
			// data
			double sumAmt = 0;
			int count = 0;
			for (int i = 0; i < dayList.size(); i++) {
				// cell
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if(j == 2){
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				// get data
				startDate = dayList.get(i);
				endDate = dayList.get(i);
				try {
					sort = "startdate";
					queryCardInsuranceStat();
					JSONArray data = (JSONArray) jsonObject.get("rows");
					
					// data
					JSONObject item = data.getJSONObject(0);
					row.getCell(0).setCellValue(item.getString("STARTDATE").equals(item.getString("ENDDATE"))?item.getString("STARTDATE"):item.getString("STARTDATE") + " ~ " + item.getString("ENDDATE"));
					//
					int c = item.getIntValue("COUNT");
					count+=c;
					row.getCell(1).setCellValue(c);
					//
					double amt = item.getDoubleValue("SUMAMT");
					sumAmt += amt;
					row.getCell(2).setCellValue(amt/100);
				} catch (Exception e) {
					row.getCell(0).setCellValue(startDate);
					row.getCell(1).setCellValue(0);
					row.getCell(2).setCellValue(0);
				}
			}

			Row row = sheet.createRow(dayList.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if(j == 2){
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(headCellStyle);
				}
			}
			row.getCell(0).setCellValue("合计");
			row.getCell(1).setCellValue(count);
			row.getCell(2).setCellValue(sumAmt / 100);
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportCardInsDataStat",Constants.YES_NO_YES);
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String getCustomerId() {
		return customerId;
	}
	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}
	@Autowired
	public void setZxcService(ZxcService zxcService) {
		this.zxcService = zxcService;
	}
	public String getQueryType() {
		return queryType;
	}
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	public BasePersonal getPersonal() {
		return personal;
	}
	public void setPersonal(BasePersonal personal) {
		this.personal = personal;
	}
	public ZxcModel getZxcModel() {
		return zxcModel;
	}
	public void setZxcModel(ZxcModel zxcModel) {
		this.zxcModel = zxcModel;
	}
	public CardAppBind getCardAppBind() {
		return cardAppBind;
	}
	public void setCardAppBind(CardAppBind cardAppBind) {
		this.cardAppBind = cardAppBind;
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
	public String getCostFee() {
		return costFee;
	}
	public void setCostFee(String costFee) {
		this.costFee = costFee;
	}
	public String getMobileNo() {
		return mobileNo;
	}
	public void setMobileNo(String mobileNo) {
		this.mobileNo = mobileNo;
	}
	public String getCancle_reason() {
		return cancle_reason;
	}
	public void setCancle_reason(String cancle_reason) {
		this.cancle_reason = cancle_reason;
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
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getInsuranceNo() {
		return insuranceNo;
	}
	public void setInsuranceNo(String insuranceNo) {
		this.insuranceNo = insuranceNo;
	}
	public File getFile() {
		return file;
	}
	public void setFile(File file) {
		this.file = file;
	}
	public String getDealNo() {
		return dealNo;
	}
	public void setDealNo(String dealNo) {
		this.dealNo = dealNo;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	public String getSource() {
		return source;
	}
	public void setSource(String source) {
		this.source = source;
	}
	public String getSelectId() {
		return selectId;
	}
	public void setSelectId(String selectId) {
		this.selectId = selectId;
	}
	public boolean getStatByDay() {
		return statByDay;
	}
	public void setStatByDay(boolean statByDay) {
		this.statByDay = statByDay;
	}
}
