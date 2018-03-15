package com.erp.action;

import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
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
import com.erp.exception.CommonException;
import com.erp.model.CardApply;
import com.erp.model.CardApplyTask;
import com.erp.model.CardTaskBatch;
import com.erp.model.CardTaskList;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.service.TaskManagementService;
import com.erp.task.DefaultFTPClient;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

@SuppressWarnings("serial")
@Namespace("/taskManagement")
@Action(value="taskManagementAction")
@Results({@Result(name="viewTask",location="/jsp/taskManage/viewWsTaskMx.jsp")})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
/**
 * @desc 任务管理相关的操作方法
 * @author yangn
 * @date 2015-12-01 22:21:20
 * @Msg 制卡任务管理
 */
public class TaskManagementAction extends BaseAction{
	private Logger logger = Logger.getLogger(TaskManagementAction.class);
	@Autowired
	private TaskManagementService taskManagementService;
	private CardApplyTask task = new CardApplyTask();
	private CardTaskList taskList = new CardTaskList();
	private CardTaskBatch batch = new CardTaskBatch();
	private CardApply apply = new CardApply();
	private String queryType = "1";
	private String customerIds;
	private String taskStartDate = "";
	private String taskEndDate = "";
	private String sort = "";
	private String order = "";
	private String taskIds;
	private String dataSeqs = "";
	private String selectIds;
	private String url = "";
	private String port = "";
	private String userName = "";
	private String pwd = "";
	private String host_upload_path = "";
	private String host_download_path = "";
	private String host_history_path = "";
	private TrServRec rec;
	private String beginTime = "";
	private String endTime = "";
	
	/**
	 * 》》零星申领查询确认生成任务
	 * @return json
	 */
	public String queryCardApply(){
		try{
			this.initDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select d.brch_id || '%' || d.full_name || '%' || a.card_type || '%' || a.is_urgent || '%' || count(a.apply_id) || '%' || '" + taskStartDate);
			sb.append("' || '%' || '" + taskEndDate + "' || '%' || a.apply_Way || '%' || '" + Tools.processNull(apply.getApplyUserId()) +  "' || '%' || '");
			sb.append(Tools.processNull(apply.getApplyBrchId()) + "' || '%erp2%' as SETTLEID,d.brch_id,d.full_name,decode(a.is_urgent,'0','本地制卡','1','外包制卡',");
			sb.append("'其他') is_urgent,(select code_name from sys_Code where code_type = 'APPLY_WAY' and code_value = a.apply_Way) apply_Way, ");
			sb.append("(select code_name from sys_Code where code_type = 'CARD_TYPE' and code_value = a.card_type) card_type,count(a.apply_id) as task_sum ");
			sb.append("from card_apply a,sys_branch c,sys_branch d ");
			sb.append("where a.apply_brch_id = c.brch_id and a.apply_state = '" + Constants.APPLY_STATE_YSQ +  "' ");
			sb.append("and a.recv_brch_id = d.brch_id and a.task_id is null "); 
			if(!Tools.processNull(apply.getCardType()).equals("")){
				sb.append("and a.card_type = '" + apply.getCardType() + "' ");
			}
			if(!Tools.processNull(apply.getApplyBrchId()).equals("")){
				sb.append("and a.apply_brch_id = '" + apply.getApplyBrchId() + "' ");
			}
			if(!Tools.processNull(apply.getApplyUserId()).equals("")){
				sb.append("and a.apply_user_id = '" + apply.getApplyUserId() + "' ");
			}
			if(!Tools.processNull(taskStartDate).equals("")){
				sb.append("and a.apply_date >= to_date('" + taskStartDate + "','yyyymmddhh24miss') ");
			}
			if(!Tools.processNull(taskEndDate).equals("")){
				sb.append("and a.apply_date <= to_date('" + taskEndDate + "','yyyymmddhh24miss') ");
			}
			if(!Tools.processNull(apply.getRecvBrchId()).equals("")){
				sb.append("and a.recv_brch_id = '" + apply.getRecvBrchId() + "' ");
			}
			sb.append("group by d.brch_id,d.full_name,a.is_urgent,a.card_type,a.apply_way ");
			Page list = taskManagementService.pagingQuery(sb.toString(),page,rows);
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
	 * 》》零星申领生成任务预览
	 * @return json
	 */
	public String viewCardApply(){
		try{
			this.initDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			if(Tools.processNull(this.selectIds).equals("")){
				throw new CommonException("请选择一条记录信息进行预览！");
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select t.apply_id selectId,t.customer_id,b.name,");
			sb.append("(select code_name from sys_code where code_type = 'SEX' and code_value = b.gender) gender,b.cert_no,");
			sb.append("(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = b.cert_type) cert_type,");
			sb.append("t.card_no,t.sub_card_no,(select code_name from sys_code where code_type = 'APPLY_WAY' and code_value = t.apply_way) applyway,");
			sb.append("(select code_name from sys_code where code_type = 'APPLY_TYPE' and code_value = t.apply_type) applytype,to_char(t.apply_date,'yyyy-mm-dd hh24:mi:ss') applydate ");
			sb.append("from card_apply t ,base_personal b where t.customer_id = b.customer_id and t.task_id is null and t.apply_state = '" + Constants.APPLY_STATE_YSQ + "' ");
			String[] searchConts  = this.selectIds.split("\\|");
			if(!Tools.processNull(searchConts[0]).equals("")){
				sb.append("and t.recv_brch_id = '" + searchConts[0] + "' ");
			}
			if(!Tools.processNull(searchConts[2]).equals("")){
				sb.append("and t.card_type = '" + searchConts[2] + "' ");
			}
			if(!Tools.processNull(searchConts[3]).equals("")){
				sb.append("and t.is_urgent = '" + searchConts[3] + "' ");
			}
			if(!Tools.processNull(searchConts[5]).equals("")){
				sb.append("and t.apply_date >= to_date('" + searchConts[5] + "','yyyymmddhh24miss') ");
			}
			if(!Tools.processNull(searchConts[6]).equals("")){
				sb.append("and t.apply_date <= to_date('" + searchConts[6] + "','yyyymmddhh24miss') ");
			}
			if(!Tools.processNull(searchConts[7]).equals("")){
				sb.append("and t.apply_way = '" + searchConts[7] + "' ");
			}
			if(!Tools.processNull(searchConts[8]).equals("")){
				sb.append("and t.apply_user_id = '" + searchConts[8] + "' ");
			}
			if(!Tools.processNull(searchConts[9]).equals("")){
				sb.append("and t.apply_brch_id = '" + searchConts[9] + "' ");
			}
			/*if(!Tools.processNull(searchConts[10]).equals("")){
				sb.append("and t.apply_brch_id = '" + searchConts[10] + "' ");
			}*/
			if(!Tools.processNull(this.taskList.getCertNo()).equals("")){
				sb.append("and b.cert_no = '" + this.taskList.getCertNo() + "' ");
			}
			if(!Tools.processNull(this.taskList.getName()).equals("")){
				sb.append("and b.name = '" + this.taskList.getName() + "' ");
			}
			if(!Tools.processNull(this.taskList.getCardNo()).equals("")){
				sb.append("and t.card_no = '" + this.taskList.getCardNo() + "' ");
			}
			Page list = taskManagementService.pagingQuery(sb.toString(),page,rows);
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
	 * 》》保存任务生成
	 * @return
	 */
	public String saveTaskCreate(){
		try{
			jsonObject.put("status","0");
			jsonObject.put("errMsg","");
			if(Tools.processNull(selectIds).equals("")){
				throw new CommonException("至少选择一条记录操作！");
			}
			String[] selectIdsStr = (String[])selectIds.split(",");
			taskManagementService.saveTaskCreate(selectIdsStr,taskManagementService.getCurrentActionLog(),apply.getApplyUserId());
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 》》任务信息查询
	 */
	public String cardTaskQuery(){
		try{
			this.initDataGrid();
			if(!this.queryType.equals("0")){
				return this.JSONOBJ;
			}
			String taskIdSql = "";
			if(!Tools.processNull(taskIds).equals("")){
				String[] taskIdArr = taskIds.split(",");
				for (String taskId : taskIdArr) {
					taskIdSql += "'" + taskId + "',";
				}
				taskIdSql = taskIdSql.substring(0, taskIdSql.length() - 1);
			}
			String head = "",htj = "";
			head = "select a.task_id settleid,a.task_id,a.make_batch_id,(select code_name from sys_Code where code_type='TASK_STATE' and code_value = a.task_state) taskstate,"
					+ "(select corp_name from base_corp where customer_id = a.corp_id) corp_name, a.is_batch_hf, "
					+ "decode(a.task_way,'0','网点','2','社区','1','单位','3','学校','4','导入','其他') taskway,a.task_way,a.task_name task_name ," 
					+ "to_char(a.task_date,'yyyy-mm-dd hh24:mi:ss') task_date,(select code_name from sys_Code where code_type = 'CARD_TYPE' and code_value = a.card_type) card_type,"
					+ "decode(a.is_urgent,'0','本地制卡','1','外包制卡','其他') is_urgent,a.task_sum,a.TASK_STATE as task_state,a.task_src,b.bank_id,b.bank_name,a.yh_num,";
			head += "a.brch_id,(select full_name from sys_branch where brch_id = a.brch_id) lkbrchname ";
			htj = "from card_apply_task a,branch_bank c,base_bank b where a.brch_id = c.brch_id(+) and c.bank_id = b.bank_id(+) and a.task_src <> '" + Constants.TASK_SRC_FGXHCG + "'";
			if(!Tools.processNull(task.getMakeBatchId()).equals("")){
				htj += "and a.make_batch_id = '" + task.getMakeBatchId() + "' ";
			}
			if(!Tools.processNull(task.getTaskId()).equals("")){
				htj += "and a.task_id = '" + task.getTaskId() + "' ";
			}
			if(!Tools.processNull(taskIdSql).equals("")){
				htj += "and a.task_id in (" + taskIdSql + ") ";
			}
			if(!Tools.processNull(task.getTaskWay()).equals("")){
				htj += "and a.task_way = '" + task.getTaskWay() + "' ";
			}
			if(!Tools.processNull(task.getTaskState()).equals("")){
				htj += "and a.task_state = '" + task.getTaskState() + "' ";
			}
			if(!Tools.processNull(task.getCorpId()).equals("")){
				htj += "and a.corp_id = '" + task.getCorpId() + "' ";
			}
			if(!Tools.processNull(task.getCardType()).equals("")){
				htj += "and a.card_Type = '" + task.getCardType() + "' ";
			}
			if(!Tools.processNull(task.getTaskOperId()).equals("")){
				htj += "and a.task_oper_id = '" + task.getTaskOperId() + "' ";
			}
			if(!Tools.processNull(task.getIsBatchHf()).equals("")){
				htj += "and a.is_batch_hf = '" + task.getIsBatchHf() + "' ";
			}
			if(!Tools.processNull(taskStartDate).equals("")){
				htj += "and a.task_date >= to_date('" + taskStartDate + " 00:00:00','yyyy-mm-dd hh24:mi:ss') ";
			}
			if(!Tools.processNull(taskEndDate).equals("")){
				htj += "and a.task_date <= to_date('" + taskEndDate + " 23:59:59','yyyy-mm-dd hh24:mi:ss') ";
			}
			if(!Tools.processNull(task.getRegionId()).equals("")){
				htj += "and a.region_id = '" + task.getRegionId() + "' ";
			}
			if(!Tools.processNull(task.getTownId()).equals("")){
				htj += "and a.town_id = '" + task.getTownId() + "' ";
			}
			if(!Tools.processNull(task.getCommId()).equals("")){
				htj += "and a.comm_id = '" + task.getCommId() + "' ";
			}
			if(!Tools.processNull(task.getTaskBrchId()).equals("")){
				htj += "and a.task_brch_id = '" + task.getTaskBrchId() + "' ";
			}
            if(!Tools.processNull(task.getBrchId()).equals("")){
                htj += "and a.brch_id = '" + task.getBrchId() + "' ";
            }
            if(!Tools.processNull(task.getTaskWay()).equals("")){
                htj += "and a.task_way in (" + Tools.getConcatStrFromArray(task.getTaskWay().split(","),"'",",") + ") ";
            }
			if(!Tools.processNull(task.getBankId()).equals("")){
				List<?> allBindBrchsList =  baseService.findBySql("select brch_id from branch_bank where bank_id = '" + task.getBankId() + "'");
				if(allBindBrchsList == null || allBindBrchsList.isEmpty()){
					htj += "and a.brch_id = 'erp2' ";
				}else{
					htj += "and a.brch_id in (" + Tools.getConcatStrFromList(allBindBrchsList,"'",",") + ")";
				}
			}
			if(Tools.processNull(sort).equals("")){
				htj += "order by a.task_id  desc ";
			}else{
				htj += "order by  " + sort + " " + order;
			}
			Page list = taskManagementService.pagingQuery(head + htj.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未找到对应的任务信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String exportTask(){
		try {
			cardTaskQuery();
			JSONArray data = (JSONArray) jsonObject.get("rows");

			//
			String fileName = "制卡任务导出";
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
			sheet.setColumnWidth(1, 2500);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 1200);
			sheet.setColumnWidth(4, 5000);
			sheet.setColumnWidth(5, 6000);
			sheet.setColumnWidth(6, 5000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 3000);
			sheet.setColumnWidth(9, 3200);
			sheet.setColumnWidth(10, 4000);
			sheet.setColumnWidth(11, 5000);
			sheet.setColumnWidth(12, 4000);
			sheet.setColumnWidth(13, 5000);

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
			int maxColumn = 14;
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
			String string = "导出时间：" + DateUtils.getNowTime();
			sheet.getRow(1).getCell(0).setCellValue(string);

			// third header
			sheet.getRow(2).getCell(0).setCellValue("任务编号");
			sheet.getRow(2).getCell(1).setCellValue("批次号");
			sheet.getRow(2).getCell(2).setCellValue("任务状态");
			sheet.getRow(2).getCell(3).setCellValue("任务组织方式");
			sheet.getRow(2).getCell(4).setCellValue("单位名称");
			sheet.getRow(2).getCell(5).setCellValue("任务名称");
			sheet.getRow(2).getCell(6).setCellValue("任务时间");
			sheet.getRow(2).getCell(7).setCellValue("卡类型");
			sheet.getRow(2).getCell(8).setCellValue("制卡方式");
			sheet.getRow(2).getCell(9).setCellValue("任务初始数量");
			sheet.getRow(2).getCell(10).setCellValue("审核银行编号");
			sheet.getRow(2).getCell(11).setCellValue("审核银行名称");
			sheet.getRow(2).getCell(12).setCellValue("审核成功数量");
			sheet.getRow(2).getCell(13).setCellValue("领卡网点");

			//
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(8, 3);

			// data
			int taskNum = 0;
			int taskSumNum = 0;
			for (int i = 0; i < data.size(); i++, taskNum++) {
				JSONObject item = data.getJSONObject(i);

				// cell data
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(cellStyle);
				}
				row.getCell(0).setCellValue(item.getString("TASK_ID"));
				row.getCell(1).setCellValue(item.getString("MAKE_BATCH_ID"));
				row.getCell(2).setCellValue(item.getString("TASKSTATE"));
				row.getCell(3).setCellValue(item.getString("TASKWAY"));
				Object corpName = item.get("CORP_NAME");
				if(corpName != null){
					row.getCell(4).setCellValue((String)corpName);
				}
				row.getCell(5).setCellValue(item.getString("TASK_NAME"));
				row.getCell(6).setCellValue(item.getString("TASK_DATE"));
				row.getCell(7).setCellValue(item.getString("CARD_TYPE"));
				row.getCell(8).setCellValue(item.getString("IS_URGENT"));
				//
				int taskSum = item.getIntValue("TASK_SUM");
				row.getCell(9).setCellValue(taskSum);
				taskSumNum += taskSum;
				//
				row.getCell(10).setCellValue(item.getString("BANK_ID"));
				row.getCell(11).setCellValue(item.getString("BANK_NAME"));
				int yhNum = item.getString("YH_NUM").equals("") ? 0 : Integer.parseInt(item.getString("YH_NUM"));
				row.getCell(12).setCellValue(yhNum);
				row.getCell(13).setCellValue(item.getString("LKBRCHNAME"));
			}

			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				cell.setCellStyle(cellStyle);
			}
			row.getCell(0).setCellValue("统计：共 " + taskNum + " 个任务");
			row.getCell(9).setCellValue(taskSumNum);
			sheet.addMergedRegion(new CellRangeAddress(data.size() + headRows, data.size() + headRows, 0, 7));
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportTask",Constants.YES_NO_YES);
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	/**
	 * 》》任务明细查询
	 */
	public String queryCardTaskList(){
		try{
			this.initDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb =  new StringBuffer();
			sb.append("select a.data_seq,a.task_id,a.customer_id,a.name,a.cert_no,(select code_name from sys_code ");
			sb.append("where code_type = 'SEX' and code_value = a.sex) as genders,b.card_no,a.reside_addr,");
			sb.append("a.card_type,(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = b.card_type) cardtype,");
			sb.append("b.apply_state,(select code_name from sys_code where code_type = 'APPLY_STATE' and code_value = b.apply_state) applystate, ");
			sb.append("nvl(c.bank_id,'') bank_id,c.bank_name,b.bank_checkrefuse_reason,b.bank_card_no ");
			sb.append("from card_task_list a,card_apply b,base_bank c where a.apply_id = b.apply_id and a.task_id = '" + taskList.getTaskId() + "' ");
			sb.append("and b.bank_id = c.bank_id(+) ");
			if(!Tools.processNull(taskList.getName()).equals("")){
				sb.append(" and a.name = '" + taskList.getName() + "'");
			}
			if(!Tools.processNull(taskList.getCertNo()).equals("")){
				sb.append(" and a.cert_No = '" + taskList.getCertNo() + "'");
			}
			if(!Tools.processNull(taskList.getCardNo()).equals("")){
				sb.append(" and a.card_no = '" + taskList.getCardNo() + "'");
			}
			if(Tools.processNull(sort).equals("")){
				//sb.append(" order by a.data_seq asc");
			}else{
				//sb.append(" order by " + sort + " " + order);
			}
			Page list = taskManagementService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 *》》删除制卡明细信息
	 * @return
	 */
	public String deleteTaskDetails(){
		try {
			if(Tools.processNull(task.getTaskId()).equals("")){
				throw new CommonException("任务编号不能为空！");
			}
			CardApplyTask tempTask = (CardApplyTask)taskManagementService.findOnlyRowByHql("from CardApplyTask where taskId = '" + task.getTaskId()+ "'");
			if(tempTask == null){
				throw new CommonException("根据任务编号【" + task.getTaskId() + "】 未找到任务信息，请确认任务信息是否存在！");
			}
			if(!Tools.processNull(tempTask.getTaskState()).equals(Constants.TASK_STATE_YSC)){
				throw new CommonException("任务状态已是【" + taskManagementService.getCodeNameBySYS_CODE("TASK_STATE",tempTask.getTaskState()) + "】，无法进行删除！");
			}
			if(Tools.processNull(dataSeqs).equals("")){
				throw new CommonException("请勾选需要进行删除的制卡明细信息！");
			}
			SysActionLog actionLog = taskManagementService.getCurrentActionLog();
			taskManagementService.deleteTaskMx(task.getTaskId(),dataSeqs,customerIds,actionLog);
			jsonObject.put("status","0");
			jsonObject.put("errMsg","");
		}catch(Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》查询任务可以添加的人员信息
	 * @return
	 */
	public String findNoInsertPerson(){
		try{
			this.initDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select a.customer_id person_id,a.customer_id customer_id,a.cert_no cert_no,a.name name,");
			sb.append("(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = a.cert_type) certtype,");
			sb.append("(select code_name from sys_code where code_type = 'SEX' and code_value = a.gender) gender ");
			sb.append("from base_personal a,base_region r where a.region_id = r.region_id and a.sure_Flag = '0' and a.customer_state = '0' ");
			sb.append("and not exists(select 1 from card_apply b where a.customer_id = b.customer_id and ");
			sb.append("b.apply_state <> '" + Constants.APPLY_STATE_WJWSHBTG + "' and b.apply_state <> '" + Constants.APPLY_STATE_YHSHBTG );
			sb.append("'and b.apply_state < '" + Constants.APPLY_STATE_YZX + "') ");
			if(Tools.processNull(task.getTaskId()).equals("")){
				throw new CommonException("任务编号不能为空！");
			}
			CardApplyTask tempTask = (CardApplyTask)taskManagementService.findOnlyRowByHql("from CardApplyTask a where a.taskId = '" + task.getTaskId() + "'");
			if(tempTask == null){
				throw new CommonException("根据任务编号【" + task.getTaskId() + "】找不到任务信息，无法进行人员增加！");
			}
			if(tempTask.getTaskWay().equals(Constants.TASK_WAY_WD)){//网点方式申领
				throw new CommonException("网点申领方式不支持添加！");
			}
			if(Tools.processNull(baseService.getSysConfigurationParameters("IS_JUDGE_SB")).equals("0")){
				sb.append("and exists (select 1 from base_siinfo f where f.customer_id = a.customer_id and f.med_state = '0' and f.med_whole_no = '" + tempTask.getMedWholeNo() + "') ");
			}
			if(!Tools.processNull(tempTask.getTaskState()).equals(Constants.TASK_STATE_YSC)){
				throw new CommonException("任务状态为【" + taskManagementService.getCodeNameBySYS_CODE("TASK_STATE",tempTask.getTaskState()) + "】，无法进行人员增加！");
			}
			if(Tools.processNull(tempTask.getTaskWay()).equals(Constants.TASK_WAY_SQ)){
				if(!Tools.processNull(tempTask.getRegionId()).equals("")){
					sb.append("and a.region_id = '" + Tools.processNull(tempTask.getRegionId()) + "' ");
				}
				if(!Tools.processNull(tempTask.getTownId()).equals("")){
					sb.append("and a.town_id = '" + Tools.processNull(tempTask.getTownId()) + "' ");
				}
				if(!Tools.processNull(tempTask.getCommId()).equals("")){
					sb.append("and a.comm_id = '" + Tools.processNull(tempTask.getCommId()) + "' ");
				}
				if(!Tools.processNull(tempTask.getGroup_Id()).equals("")){
					sb.append("and a.group_id = '" + Tools.processNull(tempTask.getGroup_Id()) + "' ");
				}
			}else if(Tools.processNull(tempTask.getTaskWay()).equals(Constants.TASK_WAY_DW)){//单位
				if(!Tools.processNull(tempTask.getCorpId()).equals("")){
					sb.append(" and a.corp_customer_id = '" + tempTask.getCorpId() + "' ");
				}
			}else if(Tools.processNull(tempTask.getTaskWay()).equals("3")){//学校
				throw new CommonException("学校申领方式不支持添加！");
			}else{
				throw new CommonException("任务的组织方式不正确！");
			}
			if(Tools.processNull(tempTask.getIsPhoto()).equals(Constants.YES_NO_YES)){
				sb.append(" and exists (select 1 from base_photo p where p.customer_id = a.customer_id and p.photo_state = '0' and dbms_lob.getlength(p.photo) > 0) ");
			}
			Page list = taskManagementService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("未找到符合申领条件的人员信息，无法进行添加！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》添加任务明细信息
	 */
	public String addTaskList(){
		try {
			if(Tools.processNull(task.getTaskId()).equals("")){
				throw new CommonException("任务编号不能为空！");
			}
			CardApplyTask tempTask = (CardApplyTask)taskManagementService.findOnlyRowByHql("from CardApplyTask where taskId = '" + task.getTaskId() + "'");
			if(tempTask == null){
				throw new CommonException("未找到任务信息，请确认任务信息是否存在！");
			}
			if(!Tools.processNull(tempTask.getTaskState()).equals(Constants.TASK_STATE_YSC)){
				throw new CommonException("任务已经确认，不能进行人员明细的添加！");
			}
			SysActionLog actionLog = taskManagementService.getCurrentActionLog();
			taskManagementService.saveAddTaskMx(actionLog,customerIds,task.getTaskId());
			jsonObject.put("status","0");
			jsonObject.put("errMsg","");
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg","新增人员出现错误：" + e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 》》制卡任务回退,批量申领时删除申领记录,否则更新申领状态为已申请
	 * @return
	 */
	public String deleteTask(){
		try{
			if(Tools.processNull(this.taskIds).equals("")){
				throw new CommonException("请勾选将要进行删除的任务信息！");
			}
			String[] tempTaskIds = this.taskIds.split("\\|");
			for (String string : tempTaskIds) {
				CardApplyTask tempTask = (CardApplyTask)taskManagementService.findOnlyRowByHql("from CardApplyTask where taskId = '" + string + "'");
				if(tempTask == null){
					throw new CommonException("任务编号为【" + string + "】的任务无法进行删除，根据编号找不到任务信息！");
				}
				if(!Tools.processNull(tempTask.getTaskState()).equals(Constants.TASK_STATE_YSC)){
					throw new CommonException("任务编号为【" + string + "】的任务的任务状态已是【" + taskManagementService.getCodeNameBySYS_CODE(tempTask.getTaskState(),"TASK_STATE") + "】无法进行删除！");
				}
				SysActionLog tt = (SysActionLog)BeanUtils.cloneBean(taskManagementService.getCurrentActionLog());
				taskManagementService.deleteTask(tempTask.getTaskId(),tt);
			}
			jsonObject.put("status","0");
			jsonObject.put("errMsg","");
		}catch(Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}	
	/**
	 * 》》导出任务信息生成批次到银行审核
	 * @return
	 */
	@SuppressWarnings({"unchecked","unused"})
	public String exportFtpFileToBank(){
		try {
			String isExportWsFlag = baseService.getSysConfigurationParameters("Apply_Ws_Flag");//是否导出卫生标志 0导出，1不导出
			if(Tools.processNull(isExportWsFlag).equals("0")){
				isExportWsFlag = "0";
			}else if(Tools.processNull(isExportWsFlag).equals("1")){
				isExportWsFlag = "1";
			}else{
				throw new CommonException("是否导出给卫生标志不存在！");
			}
			String jAlertString = "";
			if(Tools.processNull(isExportWsFlag).equals("1")){
				jAlertString = "请选择同一种卡类型，同一种制卡方式的任务信息进行导出！";
			}else{
				jAlertString = "请选择同一批次，同一卡类型的任务信息进行进行导出！";
			}
			SysActionLog actionLog = baseService.getCurrentActionLog();
			String[] taskIdArrr = taskIds.split("\\|");
			BigDecimal count = (BigDecimal)taskManagementService.findOnlyRowBySql("select count(1) from card_apply_task t where t.task_state <> '"  +
			(isExportWsFlag.equals("0") ? Constants.TASK_STATE_WJWYSH : Constants.TASK_STATE_YSC) + "' and task_id in (" + Tools.getConcatStrFromArray(taskIdArrr,"'", ",") + ")");
			if(count != null && count.intValue() > 0){
				throw new CommonException("请选择任务状态为" + (Tools.processNull(isExportWsFlag).equals("0") ? "《卫生审核通过》" : "《任务已生成》") + "的任务信息进行导出！");
			}
			List<Object[]> list = taskManagementService.findBySql("select nvl(make_Batch_Id,'') make_Batch_Id,nvl(card_type,'') card_type,nvl(is_urgent,'1') urgent "
			+ "from card_apply_task where task_id in (" + Tools.getConcatStrFromArray(taskIdArrr,"'",",") + ") group by make_Batch_Id,card_type,is_urgent");
			if(list == null || list.size() != 1){
				throw new CommonException(jAlertString);
			}
			List medWholeNoList = baseService.findBySql("SELECT NVL(MED_WHOLE_NO,'') FROM CARD_APPLY_TASK WHERE TASK_ID IN (" + Tools.getConcatStrFromArray(taskIdArrr,"'",",") + ") GROUP BY MED_WHOLE_NO");
			if(medWholeNoList == null || medWholeNoList.isEmpty()){
				throw new CommonException("勾选任务的所属统筹区域编码为空！");
			}
			if(medWholeNoList.size() > 1){
				throw new CommonException("勾选的任务属于不同的区域，请选择属于同一区域的任务进行银行审核！");
			}
			if(Tools.processNull(medWholeNoList.get(0)).equals("")){
				throw new CommonException("勾选任务的所属统筹区域编码为空！");
			}
			//批次号,卡类型,制卡方式
			Object[] batchAndCardType = (Object[]) list.get(0);
			String makeTaskBatch = Tools.processNull(batchAndCardType[0]).toString();//制卡批次
			String taskCardType  = Tools.processNull(batchAndCardType[1]).toString();//制卡类型
			String urgent  = Tools.processNull(batchAndCardType[2]).toString();//制卡方式
			//获取领卡网点绑定的银行
			List lkBrchBindBankList = baseService.findBySql("select distinct b.bank_id from card_apply_task t,branch_bank b where t.brch_id = b.brch_id(+) and task_id in (" + Tools.getConcatStrFromArray(taskIdArrr,"'",",") + ")");
			if(lkBrchBindBankList == null || lkBrchBindBankList.isEmpty()){
				throw new CommonException("勾选的任务未设置领卡网点或设置的领卡网点未绑定银行！");
			}
			if(lkBrchBindBankList.size() > 1){
				throw new CommonException("勾选的任务分属于多家银行，请勾选同一家银行的任务信息进行导出审核！");
			}
			if(Tools.processNull(lkBrchBindBankList.get(0)).equals("")){
				throw new CommonException("勾选的任务未设置领卡网点或设置的领卡网点未绑定银行！");
			}
			if(Tools.processNull(task.getIsList()).equals(Constants.YES_NO_YES)){
                List recvBechIds = baseService.findBySql("select t.brch_id from card_apply_task t where t.task_id in (" + Tools.getConcatStrFromArray(taskIdArrr,"'",",") + ") group by t.brch_id");
                if(recvBechIds == null || recvBechIds.isEmpty()){
                    throw new CommonException("勾选的任务中找不到设置的领卡网点信息！");
                }
                if(recvBechIds.size() > 1){
                    throw new CommonException("勾选的任务属于多个领卡网点，请选择同一领卡网点的任务信息进行导出！");
                }
                if(Tools.processNull(recvBechIds.get(0)).equals("")){
                    throw new CommonException("勾选的任务中找不到设置的领卡网点信息！");
                }
            }
			task.setBankId(lkBrchBindBankList.get(0).toString());
			if(isExportWsFlag.equals("0")){
				//taskManagementService.saveexportTaskToBank(actionLog, taskManagementService.getUser(),test,makeTaskBatch,task.getBankId(),task.getVendorId());
			}else{
				taskManagementService.saveExportTaskToBank(taskIdArrr,taskCardType,urgent,task.getBankId(),task.getVendorId(),baseService.getUser(),actionLog);
			}
			jsonObject.put("status","0");
			jsonObject.put("msg","任务导出成功！");
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》导入银行审核返回文件
	 * @return
	 */
	public String saveImportTaskRhFile(){
		DefaultFTPClient ftpClient = new DefaultFTPClient();
		int totNums = 0;
		int sucNums = 0;
		try{
			logger.error("...............................");
			logger.error("#开始导入银行审核结果文件");
			logger.error("#正在检查FTP配置信息");
			Map<String,String> ftpOptions = taskManagementService.initFtpOptions("make_card_task_to_bank_" + task.getBankId());
			ftpClient = taskManagementService.checkFtp(ftpOptions);
			if(Tools.processNull(ftpOptions.get("host_upload_path")).equals("")){
				throw new CommonException("获取ftp配置出错，ftp上传文件路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_upload_path:" + ftpOptions.get("host_upload_path"));
			}
			if(Tools.processNull(ftpOptions.get("host_history_path")).equals("")){
				throw new CommonException("获取ftp配置出错，ftp历史文件路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_history_path:" + ftpOptions.get("host_history_path"));
			}
			if(!(ftpClient.changeWorkingDirectory("/") && ftpClient.changeWorkingDirectory(ftpOptions.get("host_history_path"))
				&& ftpClient.changeWorkingDirectory(ftpOptions.get("host_upload_path")) )
			){
				throw new CommonException("FTP切换目录失败，请检查FTP路径设置信息！");
			}else{
				logger.error("当前工作目录" + ftpClient.printWorkingDirectory());
			}
			logger.error("正在检查是否存在银行审核返回文件");
			List<String> list = ftpClient.listNames(ftpOptions.get("host_upload_path") + "RH_*_" + task.getBankId() + "_*",100);
			if(list == null || list.size() <= 0){
				throw new CommonException("未查询到需要处理的银行返回文件！");
			}
			totNums = list.size();
			logger.error("检测到需要处理的文件个数" + list.size());
			for (int i = 0; i < list.size(); i++) {
				logger.error("开始处理第" + (i + 1) + "个文件,文件名" + list.get(i).toString());
				SysActionLog tempLog = (SysActionLog) BeanUtils.cloneBean(taskManagementService.getCurrentActionLog());
				taskManagementService.saveImportTaskRhFile(ftpClient,list.get(i).toString(),task.getBankId(),ftpOptions,taskManagementService.getUser(),tempLog);
				sucNums++;
			}
			jsonObject.put("status","0");
			jsonObject.put("msg","银行文件处理成功！");
		}catch(Exception e){
			logger.error(e.getMessage());
			if(totNums > 0){
				jsonObject.put("msg","检查到" + totNums + "个文件待处理，已成功处理" + sucNums + "个文件,其中在处理第" + (sucNums + 1) + "个文件时出现错误：" + e.getMessage());
			}else{
				jsonObject.put("msg",e.getMessage());
			}
		}finally{
			if(ftpClient.isAvailable()){
				try {
					ftpClient.logout();
					ftpClient.disconnect();
				} catch (IOException e) {
					logger.error(e.getMessage());
				}
			}else{
				ftpClient = null;
			}
			logger.error("结束处理银行审核结果文件");
		}
		return this.JSONOBJ;
	}
	/**
	 * 制卡批次查询  查询批次表
	 * @return
	 */
	public String cardBatchQuery(){
		try{
			this.initDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select t.batch_id settleid, t.batch_id,t.sendtobank_org_id,t.sendtobank_brch_id,t.sendtobank_user_id,to_char(t.sendtobank_date,'yyyy-mm-dd hh24:mi:ss') sendtobank_date,");
			sb.append("t.receivebybank_org_id,t.receivebybank_brch_id,t.receivebybank_user_id,t.receivebybank_date,");
			sb.append("t.send_org_id,t.send_brch_id,t.send_user_id,t.send_date,t.recv_org_id,t.recv_brch_id,t.recv_user_id,t.recv_time,");
			sb.append("(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.card_type) cardtype,");
			sb.append("decode(t.make_way,'0'，'本地制卡','1','外包制卡','其他') makeway,m.full_name,n.name,b.bank_name,");
			//sb.append("(case when t.)");
			sb.append("t.vendor_id,t.make_way,t.bank_id,t.card_type,t.batch_num,t.deal_no from card_task_batch t,base_bank b,sys_branch m,sys_users n " );
			sb.append("where t.bank_id = b.bank_id and t.sendtobank_brch_id = m.brch_id(+) and t.sendtobank_user_id = n.user_id(+) ");
			if(!Tools.processNull(batch.getBatchId()).equals("")){
				sb.append("and t.batch_id = '" + batch.getBatchId() + "' ");
			}
			if(!Tools.processNull(batch.getCardType()).equals("")){
				sb.append("and t.card_type = '" + batch.getCardType() + "' ");
			}
			if(!Tools.processNull(batch.getBankId()).equals("")){
				sb.append("and t.bank_id = '" + batch.getBankId() + "' ");
			}
			//发送到银行信息
			if(!Tools.processNull(batch.getSendtobankOrgId()).equals("")){
				sb.append("and t.sendtobank_org_id = '" + batch.getSendtobankOrgId() + "' ");
			}
			if(!Tools.processNull(batch.getSendtobankBrchId()).equals("")){
				sb.append("and t.sendtobank_brch_id = '" + batch.getSendtobankBrchId() + "' ");
			}
			if(!Tools.processNull(batch.getSendtobankUserId()).equals("")){
				sb.append("and t.sendtobank_user_id = '" + batch.getSendtobankUserId() + "' ");
			}
			if(!Tools.processNull(this.taskStartDate).equals("")){
				sb.append("and to_char(t.sendtobank_date,'yyyy-mm-dd') >= '" + this.taskStartDate + "' ");
			}
			if(!Tools.processNull(this.taskEndDate).equals("")){
				sb.append("and to_char(t.sendtobank_date,'yyyy-mm-dd') <= '" + this.taskEndDate + "' ");
			}
		    //接收银行信息
			if(!Tools.processNull(batch.getReceivebybankOrgId()).equals("")){
				sb.append("and t.receivebybank_org_id = '" + batch.getReceivebybankOrgId() + "' ");
			}
			if(!Tools.processNull(batch.getReceivebybankBrchId()).equals("")){
				sb.append("and t.receivebybank_brch_id = '" + batch.getReceivebybankBrchId() + "' ");
			}
			if(!Tools.processNull(batch.getReceivebybankUserId()).equals("")){
				sb.append("and t.receivebybank_user_id = '" + batch.getReceivebybankUserId() + "' ");
			}
			if(!Tools.processNull(batch.getReceivebybankDate()).equals("")){
				sb.append("and to_char(t.receivebybank_date,'yyyy-mm-dd') >= '" + batch.getReceivebybankDate() + "' ");
			}
			/*if(!Tools.processNull(this.taskEndDate).equals("")){
				sb.append("and to_char(t.receivebybank_date,'yyyy-mm-dd') <= '" + this.taskEndDate + "' ");
			}*/			
			if(Tools.processNull(this.sort).equals("")){
				sb.append("order by t.batch_id desc ");
			}else{
				sb.append("order by " + this.sort + " " + this.order);
			}
			Page list = taskManagementService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getTotalCount() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未查询到到对应批次信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》制卡数据导出查询
	 * @return
	 */
	public String exportMadeCardDataQuery(){
		try{
			this.initDataGrid();
			if(!Tools.processNull(queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT  T.MAKE_BATCH_ID SETTLEID, T.MAKE_BATCH_ID ,COUNT(1) TASK_NUM,SUM(T.YH_NUM) TASK_SUM,");
			sb.append("MAX(T.CARD_TYPE) CARD_TYPE,MAX(S.CODE_NAME) CARDTYPE,");
			sb.append("MAX(T.IS_URGENT)  IS_URGENT,");
			sb.append("(DECODE(MAX(T.IS_URGENT),'0','本地制卡','1','外包制卡','未知')) ISURGENT,");
			sb.append("MAX(T.BANK_ID) BANK_ID,MAX(B.BANK_NAME) BANK_NAME, sum(yh_num) yhshtg_num ");
			sb.append("FROM CARD_APPLY_TASK T,BASE_BANK B,SYS_CODE S ");
			sb.append("WHERE T.TASK_STATE = '" + Constants.TASK_STATE_YHYSH +  "' AND T.BANK_ID = B.BANK_ID AND S.CODE_TYPE = 'CARD_TYPE' ");
			sb.append("AND T.CARD_TYPE = S.CODE_VALUE and T.IS_URGENT <> '0' ");
			if(!Tools.processNull(batch.getBatchId()).equals("")){
				sb.append("AND T.MAKE_BATCH_ID = '" + batch.getBatchId() + "' ");
			}
			if(!Tools.processNull(batch.getCardType()).equals("")){
				sb.append("AND T.CARD_TYPE = '" + batch.getCardType() + "' ");
			}
			if(!Tools.processNull(batch.getBankId()).equals("")){
				sb.append("AND T.BANK_ID = '" + batch.getBankId() + "' ");
			}
			sb.append("GROUP BY T.MAKE_BATCH_ID ");
			Page list = taskManagementService.pagingQuery(sb.toString(), page, rows);
			if(list.getAllRs() != null && list.getTotalCount() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未查询到到对应批次信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》导出制卡文件数据
	 * @return
	 */
	public String exportMadeCardData(){
		try{
			if(Tools.processNull(this.taskIds).equals("")){
				throw new CommonException("请勾选需要导出的批次信息！");
			}
			String[] taskIdArrr = taskIds.split("\\|");
			String taskIdString = Tools.getConcatStrFromArray(taskIdArrr,"'", ",");
			List<?> batchIdNums = taskManagementService.findBySql("select make_batch_id,sum(nvl(task_sum,0)) totNums from card_apply_task "
			+ "where task_id in (" + taskIdString + ") and task_state = '" + Constants.TASK_STATE_YSC + "' group by make_batch_id");
			if(batchIdNums == null || batchIdNums.size() == 0){
				throw new CommonException("勾选的任务信息不存在或任务状态不为【任务已生成】");
			}
			if(batchIdNums.size() > 1){
				throw new CommonException("勾选的任务中包含多个批次，请勾选同一个批次的制卡任务！");
			}
			Object[] svalues = (Object[]) batchIdNums.get(0);
			if(((BigDecimal)svalues[1]).intValue() <= 0){
				throw new CommonException("勾选的任务的任务总数量为0，请仔细核对后重新进行操作！");
			}
			taskManagementService.saveExportMadeCardDataFromTask(taskIds,task.getVendorId(),baseService.getUser(),baseService.getCurrentActionLog());
			jsonObject.put("status","0");
			jsonObject.put("errMsg","导出制卡文件成功！");
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》导出制卡文件数据,根据批次号导出
	 * @return
	 */
	public String exportMadeCardDataByBatchNo(){
		int sucNum = 0;
		int totNum = 0;
		try{
			String batchIds = (String) this.request.getParameter("batchIds");
			if(Tools.processNull(batchIds).equals("")){
				throw new CommonException("请勾选需要导出的批次信息！");
			}
			String[] batchIdArrr = batchIds.split(",");
			totNum = batchIdArrr.length;
			for(String string : batchIdArrr){
				BigDecimal bigNum = (BigDecimal) taskManagementService.findOnlyFieldBySql("select count(1) from card_apply_task t where " + 
				"t.make_batch_id = '" + string + "' and t.task_state <> '" + Constants.TASK_STATE_YHYSH + "'"
				);
				if(bigNum.intValue() > 0){
					throw new CommonException("批次编号为" + string + "的批次下，含有任务状态不是【银行已审核】的任务信息！");
				}
				SysActionLog tempLog = (SysActionLog) BeanUtils.cloneBean(baseService.getCurrentActionLog());
				taskManagementService.saveExportMadeCardData(string,task.getVendorId(),baseService.getUser(),tempLog);
				sucNum++;
			}
			jsonObject.put("status","0");
			jsonObject.put("errMsg","计划导出" + totNum + "批次，成功完成" + sucNum + "个批次，全部导出成功！");
		}catch(Exception e){
			logger.error(e.getMessage());
			jsonObject.put("status","1");
			if(totNum > 0 ){
				jsonObject.put("errMsg","计划完成" + totNum + "个批次，成功导出" + sucNum + "个批次，其中在导出第" + (sucNum + 1) + "个批次时发生错误：" + e.getMessage());
			}else{
				jsonObject.put("errMsg",e.getMessage());
			}
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》查询FTP上的文件信息
	 * @return
	 */
	public String queryFileMsgFromFtp(){
		DefaultFTPClient client = null;
		try{
			this.initDataGrid();
			//初始化制卡返回的FTP配置信息
			logger.error("---------------------------------------------------------");
			logger.error("初始化制卡返回的FTP配置信息");
			initFtpPara("make_card_task_back_admin");
			if(Tools.processNull(this.url).equals("")){
				throw new CommonException("获取ftp配置出错，ftp地址未配置，请联系系统管理员！");
			}else{
				logger.error("ip:" + this.url);
			}
			if(Tools.processNull(this.port).equals("")){
				throw new CommonException("获取ftp配置出错，ftp端口未配置，请联系系统管理员！");
			}else{
				logger.error("port:" + this.port);
			}
			if(Tools.processNull(this.userName).equals("")){
				throw new CommonException("获取ftp配置出错，ftp用户名未配置，请联系系统管理员！");
			}else{
				logger.error("name:" + this.userName);
			}
			if(Tools.processNull(this.pwd).equals("")){
				throw new CommonException("获取ftp配置出错，ftp密码未配置，请联系系统管理员！");
			}else{
				logger.error("pwd:" + this.pwd);
			}
			if(Tools.processNull(this.host_download_path).equals("")){
				throw new CommonException("获取ftp配置出错，ftp文件下载路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_download_path:" + this.host_download_path);
			}
			if(Tools.processNull(this.host_history_path).equals("")){
				throw new CommonException("获取ftp配置出错，ftp文件下载历史路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_download_path:" + this.host_history_path);
			}
			client = new DefaultFTPClient();
			if(!client.toConnect(url,Integer.valueOf(port))){
				throw new CommonException("FTP连接失败！");
			}else{
				logger.error("连接正常");
			}
			client.setControlEncoding("GBK");
			client.setFileType(DefaultFTPClient.BINARY_FILE_TYPE);
			if(!client.toLogin(userName,pwd)){
				throw new CommonException("FTP登录失败！");
			}else{
				logger.error("登录正常");
			}
			host_download_path = "/makecarddata/downfile";
			if(!client.changeWorkingDirectory("/") || !client.changeWorkingDirectory(host_download_path)){
				throw new CommonException("FTP切换到目录" + host_download_path + "失败，请检查ftp配置信息！");
			}else{
				logger.error("目录切换正常");
			}
			List<String> ftpFileMsg = client.listFtpFileMsg(host_download_path);
			if(ftpFileMsg == null || ftpFileMsg.size() <= 0){
				throw new CommonException("FTP目前下未找到制卡返回数据！");
			}
			JSONArray rows = new JSONArray();
			for (int i = 0; i < ftpFileMsg.size(); i++) {
				String tempRow = ftpFileMsg.get(i);
				tempRow = tempRow.replaceAll("\\s{2,}"," ");
				String[] tempColumns = tempRow.split(" ");
				JSONObject o = new JSONObject();
				o.put("fileType",tempColumns[0].charAt(0));
				o.put("modifyDate",tempColumns[5] + " " + tempColumns[6] + " " + tempColumns[7]);
				o.put("fileSize",tempColumns[4]);
				o.put("fileName",tempColumns[tempColumns.length - 1]);
				o.put("selectId",tempColumns[tempColumns.length - 1]);
				rows.add(o);
			}
			jsonObject.put("rows",rows);
			jsonObject.put("total",ftpFileMsg.size());
		}catch(Exception e){
			logger.error(e.getMessage());
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}finally{
			try {
				if(client != null && client.isAvailable()){
					client.logout();
					client.disconnect();
				}else{
					client = null;
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
			logger.error("结束FTP文件查询操作");
		}
		return this.JSONOBJ;
	}
	/**
	 * 批量制卡文件导入
	 * @return
	 */
	public String saveBatchImportMakeCardData(){
		try{
			DefaultFTPClient client = null;
			String[] allFileNames = null;
			//初始化制卡返回的FTP配置信息
			Map<String,String> ftpOptions = new HashMap<String, String>();
			logger.error("---------------------------------------------------------------");
			logger.error("初始化制卡返回的FTP配置信息");
			ftpOptions = initFtpOptions("make_card_task_back_admin");
			if(Tools.processNull(ftpOptions.get("url")).equals("")){
				throw new CommonException("获取ftp配置出错，ftp地址未配置，请联系系统管理员！");
			}else{
				logger.error("ip:" + ftpOptions.get("url"));
			}
			if(Tools.processNull(ftpOptions.get("port")).equals("")){
				throw new CommonException("获取ftp配置出错，ftp端口未配置，请联系系统管理员！");
			}else{
				logger.error("port:" + ftpOptions.get("port"));
			}
			if(Tools.processNull(ftpOptions.get("userName")).equals("")){
				throw new CommonException("获取ftp配置出错，ftp用户名未配置，请联系系统管理员！");
			}else{
				logger.error("name:" + ftpOptions.get("userName"));
			}
			if(Tools.processNull(ftpOptions.get("pwd")).equals("")){
				throw new CommonException("获取ftp配置出错，ftp密码未配置，请联系系统管理员！");
			}else{
				logger.error("pwd:" + ftpOptions.get("pwd"));
			}
			if(Tools.processNull(ftpOptions.get("host_download_path")).equals("")){
				throw new CommonException("获取ftp配置出错，ftp文件下载路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_download_path:" + ftpOptions.get("host_download_path"));
			}
			if(Tools.processNull(ftpOptions.get("host_history_path")).equals("")){
				throw new CommonException("获取ftp配置出错，ftp文件下载历史路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_history_path:" + ftpOptions.get("host_history_path"));
			}
			if(Tools.processNull(queryType).equals("0")){
				if(Tools.processNull(this.selectIds).equals("")){
					throw new CommonException("请勾选将要进行导入的文件信息！");
				}
				allFileNames = this.selectIds.split(",");
			}else if(Tools.processNull(queryType).equals("1")){
				client = new DefaultFTPClient();
				if(!client.toConnect(ftpOptions.get("url"),Integer.valueOf(ftpOptions.get("port")))){
					throw new CommonException("FTP连接失败！");
				}else{
					logger.error("连接正常");
				}
				client.setControlEncoding("GBK");
				client.setFileType(DefaultFTPClient.BINARY_FILE_TYPE);
				if(!client.toLogin(ftpOptions.get("userName"),ftpOptions.get("pwd"))){
					throw new CommonException("FTP登录失败！");
				}else{
					logger.error("登录正常");
				}
				if(!client.changeWorkingDirectory("/") || !client.changeWorkingDirectory(ftpOptions.get("host_download_path"))){
					throw new CommonException("FTP切换到目录" + ftpOptions.get("host_download_path") + "失败，请检查ftp配置信息！");
				}else{
					logger.error("目录切换正常");
				}
				List<String> ftpFileNames = client.listNames(ftpOptions.get("host_download_path"),500);
				if(ftpFileNames == null || ftpFileNames.size() <= 0){
					throw new CommonException("FTP" + ftpOptions.get("host_download_path") + "目录下没有找到制卡返回文件！");
				}
				allFileNames =  new String[ftpFileNames.size()];
				allFileNames = ftpFileNames.toArray(allFileNames);
				client.logout();
				client.disconnect();
			}else{
				throw new CommonException("选择的导入类型不正确！");
			}
			logger.error("扫描需要处理的文件个数," + allFileNames.length + "个");
			for(int i = 0; i < allFileNames.length; i++) {
				logger.error("开始处理第" + (i + 1) + "个文件," + allFileNames[i]);
				SysActionLog tempLog =  (SysActionLog) BeanUtils.cloneBean(taskManagementService.getCurrentActionLog());
				taskManagementService.saveBatchImportMakeCardData(allFileNames[i],ftpOptions,tempLog);
				logger.error("文件" + allFileNames[i] + "处理成功");
			}
			logger.error("文件全部处理成功");
			jsonObject.put("status","0");
			jsonObject.put("errMsg","导入成功！");
		}catch(Exception e){
			logger.error(e.getMessage());
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}finally{
			logger.error("结束制卡文件的导入操作");
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》导出市民卡银行卡号对应关系文件
	 * @return
	 */
	public String exportBankBkFileQuery(){
		try{
			this.initDataGrid();
			if(!Tools.processNull(queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT T.MAKE_BATCH_ID SETTLEID,T.MAKE_BATCH_ID,COUNT(1) TASK_NUM,SUM(T.TASK_SUM) TASK_SUM,");
			sb.append("MAX(T.CARD_TYPE) CARD_TYPE,MAX(S.CODE_NAME) CARDTYPE,");
			sb.append("MAX(T.IS_URGENT)  IS_URGENT, sum(t.end_num) end_sum, ");
			sb.append("(DECODE(MAX(T.IS_URGENT),'0','本地制卡','1','外包制卡','未知')) ISURGENT,");
			sb.append("MAX(T.BANK_ID) BANK_ID,MAX(B.BANK_NAME) BANK_NAME ");
			sb.append("FROM CARD_APPLY_TASK T,BASE_BANK B,SYS_CODE S,CARD_TASK_BATCH H ");
			sb.append("WHERE T.TASK_STATE >= '" + Constants.TASK_STATE_YZK +  "' AND T.BANK_ID = B.BANK_ID AND S.CODE_TYPE = 'CARD_TYPE' AND T.MAKE_BATCH_ID = H.BATCH_ID ");
			sb.append("AND T.CARD_TYPE = S.CODE_VALUE AND  ( H.EXPORT_BANK_STATE IS NULL OR h.EXPORT_BANK_STATE <> '0') ");
			if(!Tools.processNull(batch.getBatchId()).equals("")){
				sb.append("AND T.MAKE_BATCH_ID = '" + batch.getBatchId() + "' ");
			}
			if(!Tools.processNull(batch.getCardType()).equals("")){
				sb.append("AND T.CARD_TYPE = '" + batch.getCardType() + "' ");
			}
			if(!Tools.processNull(batch.getBankId()).equals("")){
				sb.append("AND T.BANK_ID = '" + batch.getBankId() + "' ");
			}
			sb.append("GROUP BY T.MAKE_BATCH_ID ");
			Page list = taskManagementService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getTotalCount() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未查询到到对应批次信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》保存导出市民卡银行卡号对应关系数据
	 * @return
	 */
	public String saveExportBankBkFile(){
		int sucNum = 0;
		int totNum = 0;
		try{
			String batchIds = (String) this.request.getParameter("batchIds");
			if(Tools.processNull(batchIds).equals("")){
				throw new CommonException("请勾选需要导出的批次信息！");
			}
			String[] batchIdArrr = batchIds.split(",");
			totNum = batchIdArrr.length;
			for(String string : batchIdArrr){
				String[] batchAndBankId = string.split("\\|");
				BigDecimal bigNum = (BigDecimal) taskManagementService.findOnlyFieldBySql("select count(1) from card_apply_task t where " + 
				"t.make_batch_id = '" + batchAndBankId[0] + "' and t.task_state < '" + Constants.TASK_STATE_YZK + "' and task_sum > 0"
				);
				if(bigNum.intValue() > 0){
					throw new CommonException("批次编号为" + batchAndBankId[0] + "的批次下，含有任务状态不是【已制卡】的任务信息，无法进行导出卡号对应关系！");
				}
				SysActionLog tempLog = (SysActionLog) BeanUtils.cloneBean(baseService.getCurrentActionLog());
				taskManagementService.saveExportBankBkFile(batchAndBankId[0] ,batchAndBankId[1],baseService.getUser(),tempLog);
				sucNum++;
			}
			jsonObject.put("status","0");
			jsonObject.put("errMsg","计划导出" + totNum + "批次，成功完成" + sucNum + "个批次，全部导出成功！");
		}catch(Exception e){
			logger.error(e.getMessage());
			jsonObject.put("status","1");
			if(totNum > 0 ){
				jsonObject.put("errMsg","计划完成" + totNum + "个批次，成功导出" + sucNum + "个批次，其中在导出第" + (sucNum + 1) + "个批次时发生错误：" + e.getMessage());
			}else{
				jsonObject.put("errMsg",e.getMessage());
			}
		}
		return this.JSONOBJ;
	}
	/**
	 * 非个性化采购任务查询
	 * @return
	 */
	public String fgxhcgQuery(){
		try{
			this.initDataGrid();
			if(!this.queryType.equals("0")){
				return this.JSONOBJ;
			}
			String head = "",htj = "";
			head = "select a.task_id settleid,a.task_id,a.make_batch_id,(select code_name from sys_Code where code_type='TASK_STATE' and code_value = a.task_state) taskstate,"
			+ "decode(a.task_way,'0','网点','2','社区','1','单位','3','学校','其他') taskway,a.task_way,case when a.task_name is null then a.note else a.task_name end task_name ," +
			"to_char(a.task_date,'yyyy-mm-dd hh24:mi:ss') task_date,(select code_name from sys_Code where code_type = 'CARD_TYPE' and code_value = a.card_type) card_type,a.card_type cardtype,"
			+ "decode(a.is_urgent,'0','本地制卡','1','外包制卡','其他') is_urgent,a.task_sum,a.TASK_STATE as task_state,a.task_src,a.bank_id,b.bank_name,r.region_name ";
			htj = "from card_apply_task a,base_bank b,base_region r where a.bank_id = b.bank_id(+) and a.region_id = r.region_id(+) and a.task_src = '" + Constants.TASK_SRC_FGXHCG + "'";
			if(!Tools.processNull(task.getMakeBatchId()).equals("")){
				htj += "and a.make_batch_id = '" + task.getMakeBatchId() + "' ";
			}
			if(!Tools.processNull(task.getTaskId()).equals("")){
				htj += "and a.task_id = '" + task.getTaskId() + "' ";
			}
			if(!Tools.processNull(task.getBankId()).equals("")){
				htj += "and a.bank_id = '" + task.getBankId() + "' ";
			}
			if(!Tools.processNull(task.getTaskState()).equals("")){
				htj += "and a.task_state = '" + task.getTaskState() + "' ";
			}
			if(!Tools.processNull(task.getCorpId()).equals("")){
				htj += "and a.corp_id = '" + task.getCorpId() + "' ";
			}
			if(!Tools.processNull(task.getCardType()).equals("")){
				htj += "and a.card_Type = '" + task.getCardType() + "' ";
			}
			if(!Tools.processNull(taskStartDate).equals("")){
				htj += "and a.task_date >= to_date('" + taskStartDate + " 00:00:00','yyyy-mm-dd hh24:mi:ss') ";
			}
			if(!Tools.processNull(taskEndDate).equals("")){
				htj += "and a.task_date <= to_date('" + taskEndDate + " 23:59:59','yyyy-mm-dd hh24:mi:ss') ";
			}
			if(!Tools.processNull(task.getRegionId()).equals("")){
				htj += "and a.region_id = '" + task.getRegionId() + "' ";
			}
			if(!Tools.processNull(task.getTownId()).equals("")){
				htj += "and a.town_id = '" + task.getTownId() + "' ";
			}
			if(!Tools.processNull(task.getCommId()).equals("")){
				htj += "and a.comm_id = '" + task.getCommId() + "' ";
			}
			if(Tools.processNull(sort).equals("")){
				htj += "order by a.task_id  desc ";
			}else{
				htj += "order by  " + sort + " " + order;
			}
			Page list = taskManagementService.pagingQuery(head + htj.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未找到对应的任务信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 保存非个性化采购
	 * @return
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public String saveFgxhCg(){
		int totNum = 0;
		int sucNum = 0;
		try{
			List allRegionIds = new ArrayList();
			if(Tools.processNull(task.getCardType()).equals("")){
				throw new CommonException("非个性化采购卡类型不能为空！");
			}
			if(Tools.processNull(task.getTaskSum()).equals("")){
				throw new CommonException("非个性化采购数量不能为空！");
			}
			if(!(task.getTaskSum() + "").matches("^[1-9]+[0-9]*$")){
				throw new CommonException("非个性化采购数量格式不正确！");
			}
			if(Tools.processNull(task.getBankId()).equals("")){
				throw new CommonException("银行不能为空！");
			}
			if(!Tools.processNull(task.getRegionId()).equals("")){
				allRegionIds.add(task.getRegionId());
			}else{
				allRegionIds = taskManagementService.findBySql("select region_id from base_region where region_state = '0' order by region_id asc");
			}
			if(allRegionIds == null || allRegionIds.size() < 1){
				throw new CommonException("获取的区域编号为空，无法进行采购！");
			}
			sucNum = allRegionIds.size();
			for (int i = 0; i < allRegionIds.size(); i++) {
				SysActionLog log = (SysActionLog) BeanUtils.cloneBean(taskManagementService.getCurrentActionLog());
				taskManagementService.saveFgxhCg(task.getCardType(),task.getBankId(),Tools.processNull(allRegionIds.get(i)),Long.valueOf(task.getTaskSum() + ""), taskManagementService.getUser(),log);
				sucNum++;
			}
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("status","1");
			if(totNum <= 0){
				jsonObject.put("errMsg",e.getMessage());
			}else{
				jsonObject.put("errMsg","计划生成" + totNum + "个任务信息，成功完成" + sucNum + "个任务，其中在生成第" + (sucNum + 1) + "个任务时出现错误：" + e.getMessage());
			}
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》删除非个性化采购
	 * @return
	 */
	public String deleteFgxhCg(){
		int totNum = 0;
		int sucNum = 0;
		try{
			if(Tools.processNull(this.taskIds).equals("")){
				throw new CommonException("请勾选需要进行删除的非个性化制卡任务信息！");
			}
			String[] taskIdArr = this.taskIds.split(",");
			totNum = taskIdArr.length;
			for (int i = 0; i < taskIdArr.length; i++) {
				SysActionLog tempLog = (SysActionLog) BeanUtils.cloneBean(taskManagementService.getCurrentActionLog());
				taskManagementService.saveDeleteFgxhCg(taskIdArr[i],taskManagementService.getUser(),tempLog);
				sucNum++;
			}
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("status","1");
			if(totNum <= 0){
				jsonObject.put("errMsg",e.getMessage());
			}else{
				jsonObject.put("errMsg","计划删除" + totNum + "个任务信息，成功完成" + sucNum + "个任务，其中在删除第" + (sucNum + 1) + "个任务时出现错误：" + e.getMessage());
			}
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》预览非个性化采购信息
	 * @return
	 */
	public String viewFgxhCg(){
		try{
			this.initDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select  t.data_seq id,t.data_seq,t.task_id,t.card_no,t.card_type,");
			sb.append("(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.card_type) cardtype,");
			sb.append("(select code_name from sys_code where code_type = 'BUS_TYPE' and code_value = t.struct_child_type) bustype,");
			sb.append("t.struct_main_type,t.bursestartdate,t.bursevaliddate,");
			sb.append("t.hlht_flag,t.touch_startdate,t.touch_validdate ");
			sb.append("from card_task_list t where 1 = 1 ");
			if(!Tools.processNull(taskList.getTaskId()).equals("")){
				sb.append("and t.task_id = '" + taskList.getTaskId() + "' ");
			}
			if(!Tools.processNull(taskList.getCardNo()).equals("")){
				sb.append("and t.card_no = '" + taskList.getCardNo() + "' ");
			}
			if(!Tools.processNull(taskList.getDataSeq()).equals("")){
				sb.append("and t.data_seq = '" + taskList.getDataSeq() + "' ");
			}
			if(!Tools.processNull(sort).equals("")){
				sb.append("order by " + sort + " " + order);
			}else{
				sb.append("order by t.data_seq asc ");
			}
			Page list = taskManagementService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("未查询到制卡明细信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》导出非个性化制卡数据
	 * @return
	 */
	public String exportFgxhCg(){
		try{
			if(Tools.processNull(this.taskIds).equals("")){
				throw new CommonException("请勾选需要进行导出的非个性化制卡任务信息！");
			}
			String[] taskIdArr = this.taskIds.split(",");
			taskManagementService.saveExportFgxhCg(task.getBankId(),taskIdArr,task.getVendorId(),taskManagementService.getUser(),taskManagementService.getCurrentActionLog());
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String getTaskReceiveRegistInfo() {
		try {
			initDataGrid();
			String taskSql = "";
			if (!Tools.processNull(selectIds).equals("")) {
				String[] taskIdArr = selectIds.split(",");
				if (taskIdArr != null && taskIdArr.length > 0) {
					for (String taskId : taskIdArr) {
						taskSql += "'" + taskId + "',";
					}
					if (taskSql.length() > 0) {
						taskSql = taskSql.substring(0, taskSql.length() - 1);
					}
				}
			}
			String sql = "select t.task_id, t.make_batch_id, t.task_name, to_char(t.task_date,'yyyy-mm-dd hh24:mi:ss') task_date, "
					+ "(select code_name from sys_Code where code_type='TASK_STATE' and code_value = t.task_state) task_state, t.task_state state, "
					+ "nvl2(t2.deal_no, 1, 0) regist_state, decode(t.task_way,'0','网点','2','社区','1','单位','3','学校','4','导入','其他') task_way, "
					+ "t3.corp_name, t3.contact, t3.con_cert_no, t3.con_phone, (select full_name from sys_branch where brch_id = t2.brch_id) oper_brch_name, "
					+ "(select name from sys_users where user_id = t2.user_id) user_name, to_char(t2.biz_time, 'yyyy-mm-dd hh24:mi:ss') biz_time, "
					+ "decode(t.is_urgent,'0','本地制卡','1','外包制卡','其他') is_urgent, t.task_sum, t.bank_id, "
					+ "(select bank_name from base_bank where bank_id = t.bank_id) bank_name, t.yh_num, "
					+ "(select full_name from sys_branch where brch_id = t.brch_id) brch_name, t2.agt_name, t2.agt_cert_no "
					+ "from card_apply_task t left join tr_serv_rec t2 on t.task_id = t2.rsv_five and t2.deal_code = '" + DealCode.CARD_RECEIVE_REGIST + "' "
					+ "left join base_corp t3 on t.corp_id = t3.customer_id "
					+ "where t.task_state >= '" + Constants.TASK_STATE_YJS + "' and t.is_urgent = '1' ";
			if (!Tools.processNull(task.getMakeBatchId()).equals("")) {
				sql += "and t.make_batch_id = '" + task.getMakeBatchId() + "' ";
			}
			if (!Tools.processNull(taskSql).equals("")) {
				sql += "and t.task_id in (" + taskSql + ") ";
			}
			if (!Tools.processNull(task.getTaskId()).equals("")) {
				sql += "and t.task_id = '" + task.getTaskId() + "' ";
			}
			if (!Tools.processNull(task.getBankId()).equals("")) {
				sql += "and t.bank_id = '" + task.getBankId() + "' ";
			}
			if (!Tools.processNull(beginTime).equals("")) {
				sql += "and t2.biz_time >= to_date('" + beginTime + "', 'yyyy-mm-dd') ";
			}
			if (!Tools.processNull(endTime).equals("")) {
				sql += "and t2.biz_time <= to_date('" + endTime + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			if (!Tools.processNull(sort).equals("")) {
				sql += "order by " + sort + " ";
				if (!Tools.processNull(order).equals("")) {
					sql += order;
				}
			} else {
				sql += "order by task_id desc";
			}
			Page list = taskManagementService.pagingQuery(sql, page, rows);
			if (list == null || list.getAllRs() == null || list.getAllRs().isEmpty()) {
				throw new CommonException("未查询到对应任务信息！");
			}
			jsonObject.put("rows", list.getAllRs());
			jsonObject.put("total", list.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String exportReceiveRegistData() {
		try {
			rows = 65500;
			getTaskReceiveRegistInfo();
			//
			String status = jsonObject.getString("status");
			if ("1".equals(status)) {
				return JSONOBJ;
			}
			JSONArray data = (JSONArray) jsonObject.get("rows");
			String fileName = "领卡登记数据";
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

			sheet.setColumnWidth(0, 5000);
			sheet.setColumnWidth(1, 6000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 3000);
			sheet.setColumnWidth(4, 3500);
			sheet.setColumnWidth(5, 6000);
			sheet.setColumnWidth(6, 6000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 6000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 4000);
			sheet.setColumnWidth(11, 6000);
			sheet.setColumnWidth(12, 6000);
			sheet.setColumnWidth(13, 3000);
			sheet.setColumnWidth(14, 3500);
			sheet.setColumnWidth(15, 5000);
			sheet.setColumnWidth(16, 4000);
			sheet.setColumnWidth(17, 4000);
			sheet.setColumnWidth(18, 8000);

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
			int maxColumn = 19;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}

			sheet.getRow(0).getCell(0).setCellValue(fileName);
			//
			String string = "";
			if(!Tools.processNull(beginTime).equals("") || !Tools.processNull(endTime).equals("")){
				string += "办理时间：" + beginTime + " ~ " + endTime + "    ";
			}
			string += "导出时间：" + DateUtil.formatDate(new Date());
			sheet.getRow(1).getCell(0).setCellValue(string);
			// third header
			sheet.getRow(2).getCell(0).setCellValue("任务编号");
			sheet.getRow(2).getCell(1).setCellValue("任务名称");
			sheet.getRow(2).getCell(2).setCellValue("任务状态");
			sheet.getRow(2).getCell(3).setCellValue("登记状态");
			sheet.getRow(2).getCell(4).setCellValue("领卡人");
			sheet.getRow(2).getCell(5).setCellValue("领卡人证件号码");
			sheet.getRow(2).getCell(6).setCellValue("办理网点");
			sheet.getRow(2).getCell(7).setCellValue("办理柜员");
			sheet.getRow(2).getCell(8).setCellValue("办理时间");
			sheet.getRow(2).getCell(9).setCellValue("批次号");
			sheet.getRow(2).getCell(10).setCellValue("任务组织方式");
			sheet.getRow(2).getCell(11).setCellValue("单位名称");
			sheet.getRow(2).getCell(12).setCellValue("任务时间");
			sheet.getRow(2).getCell(13).setCellValue("制卡方式");
			sheet.getRow(2).getCell(14).setCellValue("任务初始数量");
			sheet.getRow(2).getCell(15).setCellValue("审核银行编号");
			sheet.getRow(2).getCell(16).setCellValue("审核银行名称");
			sheet.getRow(2).getCell(17).setCellValue("审核成功数量");
			sheet.getRow(2).getCell(18).setCellValue("领卡网点");

			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
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
				row.getCell(0).setCellValue(item.getString("TASK_ID"));
				row.getCell(1).setCellValue(item.getString("TASK_NAME"));
				row.getCell(2).setCellValue(item.getString("TASK_STATE"));
				//
				String registState = item.getString("REGIST_STATE");
				if ("1".equals(registState)) {
					registState = "已登记";
				} else {
					registState = "未登记";
				}
				row.getCell(3).setCellValue(registState);
				//
				row.getCell(4).setCellValue(item.getString("AGT_NAME"));
				row.getCell(5).setCellValue(item.getString("AGT_CERT_NO"));
				row.getCell(6).setCellValue(item.getString("OPER_BRCH_NAME"));
				row.getCell(7).setCellValue(item.getString("USER_NAME"));
				row.getCell(8).setCellValue(item.getString("BIZ_TIME"));
				row.getCell(9).setCellValue(item.getString("MAKE_BATCH_ID"));
				row.getCell(10).setCellValue(item.getString("TASK_WAY"));
				row.getCell(11).setCellValue(item.getString("CORP_NAME"));
				row.getCell(12).setCellValue(item.getString("TASK_DATE"));
				row.getCell(13).setCellValue(item.getString("IS_URGENT"));
				row.getCell(14).setCellValue(item.getString("TASK_SUM"));
				row.getCell(15).setCellValue(item.getString("BANK_ID"));
				row.getCell(16).setCellValue(item.getString("BANK_NAME"));
				row.getCell(17).setCellValue(item.getString("YH_NUM"));
				row.getCell(18).setCellValue(item.getString("BRCH_NAME"));
			}

			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportReceiveRegistData",Constants.YES_NO_YES);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String taskReceiveRegist() {
		try {
			if (Tools.processNull(taskIds).equals("")) {
				throw new CommonException("任务编号为空！");
			} else if (Tools.processNull(rec.getAgtName()).equals("")) {
				throw new CommonException("领卡人姓名为空！");
			}
			taskManagementService.saveTaskReceiveRegist(taskIds, rec);
			jsonObject.put("status", "0");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
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
	 * FTP参数初始化
	 * @param ftp_use
	 * @throws CommonException
	 */
	@SuppressWarnings("rawtypes")
	public void initFtpPara(String ftp_use) throws CommonException{
		List ftpPara = taskManagementService.findBySql("select t.ftp_para_name,t.ftp_para_value from SYS_FTP_CONF t "
		+ "where t.ftp_use = '" + ftp_use + "'");
		if(ftpPara == null || ftpPara.size() <= 0){
			throw new CommonException("获取ftp配置出错，请联系系统管理员！");
		}
		for(int k = 0;k < ftpPara.size();k++){
			Object[] objs = (Object[])ftpPara.get(k);
			if(Tools.processNull(objs[0]).equals("host_ip")){
				url = Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("host_upload_path")){
				host_upload_path = Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("host_download_path")){
				host_download_path = Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("host_history_path")){
				host_history_path = Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("host_port")){
				port = Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("pwd")){
				pwd = Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("user_name")){
				userName = Tools.processNull(objs[1]);
			}
		}
	}
	/**
	 * 获取FTP配置信息
	 * @param ftp_use
	 * @return map 参数信息
	 * host_ip 主机地址
	 * host_port 端口号
	 * host_upload_path 上传路径
	 * host_download_path 下载路径
	 * host_history_path 历史目录
	 * user_name 用户名
	 * pwd 密码
	 */
	public Map<String,String> initFtpOptions(String ftp_use){
		try{
			Map<String,String> res = new HashMap<String, String>();
			List<?> ftpPara = taskManagementService.findBySql("select t.ftp_para_name,t.ftp_para_value from SYS_FTP_CONF t "
			+ "where t.ftp_use = '" + ftp_use + "'");
			if(ftpPara == null || ftpPara.size() <= 0){
				throw new CommonException("获取ftp配置出错，请联系系统管理员！");
			}
			for(int k = 0;k < ftpPara.size();k++){
				Object[] objs = (Object[])ftpPara.get(k);
				if(Tools.processNull(objs[0]).equals("host_ip")){
					res.put("url",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_upload_path")){
					res.put("host_upload_path",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_download_path")){
					res.put("host_download_path",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_history_path")){
					res.put("host_history_path",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_port")){
					res.put("port",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("pwd")){
					res.put("pwd",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("user_name")){
					res.put("userName",Tools.processNull(objs[1]));
				}
			}
			return res;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * @return the task
	 */
	public CardApplyTask getTask() {
		return task;
	}
	/**
	 * @return the taskList
	 */
	public CardTaskList getTaskList() {
		return taskList;
	}
	/**
	 * @return the apply
	 */
	public CardApply getApply() {
		return apply;
	}
	/**
	 * @return the queryType
	 */
	public String getQueryType() {
		return queryType;
	}
	/**
	 * @return the customerIds
	 */
	public String getCustomerIds() {
		return customerIds;
	}
	/**
	 * @return the taskStartDate
	 */
	public String getTaskStartDate() {
		return taskStartDate;
	}
	/**
	 * @return the taskEndDate
	 */
	public String getTaskEndDate() {
		return taskEndDate;
	}
	/**
	 * @return the sort
	 */
	public String getSort() {
		return sort;
	}
	/**
	 * @return the order
	 */
	public String getOrder() {
		return order;
	}
	/**
	 * @return the taskIds
	 */
	public String getTaskIds() {
		return taskIds;
	}
	/**
	 * @return the dataSeqs
	 */
	public String getDataSeqs() {
		return dataSeqs;
	}
	/**
	 * @return the selectIds
	 */
	public String getSelectIds() {
		return selectIds;
	}
	/**
	 * @param task the task to set
	 */
	public void setTask(CardApplyTask task) {
		this.task = task;
	}
	/**
	 * @param taskList the taskList to set
	 */
	public void setTaskList(CardTaskList taskList) {
		this.taskList = taskList;
	}
	/**
	 * @param apply the apply to set
	 */
	public void setApply(CardApply apply) {
		this.apply = apply;
	}
	/**
	 * @param queryType the queryType to set
	 */
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	/**
	 * @param customerIds the customerIds to set
	 */
	public void setCustomerIds(String customerIds) {
		this.customerIds = customerIds;
	}
	/**
	 * @param taskStartDate the taskStartDate to set
	 */
	public void setTaskStartDate(String taskStartDate) {
		this.taskStartDate = taskStartDate;
	}
	/**
	 * @param taskEndDate the taskEndDate to set
	 */
	public void setTaskEndDate(String taskEndDate) {
		this.taskEndDate = taskEndDate;
	}
	/**
	 * @param sort the sort to set
	 */
	public void setSort(String sort) {
		this.sort = sort;
	}
	/**
	 * @param order the order to set
	 */
	public void setOrder(String order) {
		this.order = order;
	}
	/**
	 * @param taskIds the taskIds to set
	 */
	public void setTaskIds(String taskIds) {
		this.taskIds = taskIds;
	}
	/**
	 * @param dataSeqs the dataSeqs to set
	 */
	public void setDataSeqs(String dataSeqs) {
		this.dataSeqs = dataSeqs;
	}
	/**
	 * @param selectIds the selectIds to set
	 */
	public void setSelectIds(String selectIds) {
		this.selectIds = selectIds;
	}
	/**
	 * @return the taskManagementService
	 */
	public TaskManagementService getTaskManagementService() {
		return taskManagementService;
	}
	/**
	 * @param taskManagementService the taskManagementService to set
	 */
	public void setTaskManagementService(TaskManagementService taskManagementService) {
		this.taskManagementService = taskManagementService;
	}
	/**
	 * @return the logger
	 */
	public Logger getLogger() {
		return logger;
	}
	/**
	 * @return the url
	 */
	public String getUrl() {
		return url;
	}
	/**
	 * @return the port
	 */
	public String getPort() {
		return port;
	}
	/**
	 * @return the userName
	 */
	public String getUserName() {
		return userName;
	}
	/**
	 * @return the pwd
	 */
	public String getPwd() {
		return pwd;
	}
	/**
	 * @return the host_upload_path
	 */
	public String getHost_upload_path() {
		return host_upload_path;
	}
	/**
	 * @return the host_download_path
	 */
	public String getHost_download_path() {
		return host_download_path;
	}
	/**
	 * @return the host_history_path
	 */
	public String getHost_history_path() {
		return host_history_path;
	}
	/**
	 * @param logger the logger to set
	 */
	public void setLogger(Logger logger) {
		this.logger = logger;
	}
	/**
	 * @param url the url to set
	 */
	public void setUrl(String url) {
		this.url = url;
	}
	/**
	 * @param port the port to set
	 */
	public void setPort(String port) {
		this.port = port;
	}
	/**
	 * @param userName the userName to set
	 */
	public void setUserName(String userName) {
		this.userName = userName;
	}
	/**
	 * @param pwd the pwd to set
	 */
	public void setPwd(String pwd) {
		this.pwd = pwd;
	}
	/**
	 * @param host_upload_path the host_upload_path to set
	 */
	public void setHost_upload_path(String host_upload_path) {
		this.host_upload_path = host_upload_path;
	}
	/**
	 * @param host_download_path the host_download_path to set
	 */
	public void setHost_download_path(String host_download_path) {
		this.host_download_path = host_download_path;
	}
	/**
	 * @param host_history_path the host_history_path to set
	 */
	public void setHost_history_path(String host_history_path) {
		this.host_history_path = host_history_path;
	}
	/**
	 * @return the batch
	 */
	public CardTaskBatch getBatch() {
		return batch;
	}
	/**
	 * @param batch the batch to set
	 */
	public void setBatch(CardTaskBatch batch) {
		this.batch = batch;
	}
	public TrServRec getRec() {
		return rec;
	}
	public void setRec(TrServRec rec) {
		this.rec = rec;
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
