package com.erp.action;

import java.io.OutputStream;
import java.net.URLEncoder;

import javax.annotation.Resource;

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
import org.apache.struts2.convention.annotation.Namespace;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.CardApply;
import com.erp.model.CardApplyTask;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardRecoverReginfo;
import com.erp.model.TrServRec;
import com.erp.service.CardRecoverRegisterService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**
 * 卡片回收登记。
 * 
 * @author 钱佳明。
 * @date 2016-03-10。
 *
 */
@Namespace(value = "/cardRecoverRegister")
@Action(value = "cardRecoverRegisterAction")
public class CardRecoverRegisterAction extends BaseAction {
	private static final long serialVersionUID = 1L;
	@Resource(name = "cardRecoverRegisterService")
	private CardRecoverRegisterService cardRecoverRegisterService;
	private String recoverId;
	private String certNo;
	private String name;
	private String cardNo;
	private String boxNo;
	private String recoverBranch;
	private String recoverUser;
	private String recoverBeginDate;
	private String recoverEndDate;
	private String recoverStatus;
	private String registerInfo;
	private String queryType = "1";
	private String sort;
	private String order;
	private String defaultErrorMsg = "";
	private TrServRec rec;
	private String ids;

	public String queryCardRecoverRegisterInfo(){
		try {
			this.initBaseDataGrid();
			if(!Tools.processNull(queryType).equals("0")) {
				return this.JSONOBJ;
			}
			String idSql = "";
			if (!Tools.processNull(ids).equals("")) {
				String[] idArr = ids.split(",");
				for (String id : idArr) {
					idSql += "'" + id + "',";
				}
				idSql = idSql.substring(0, idSql.length() - 1);
			}
			StringBuffer sql = new StringBuffer();
			sql.append("select t.id, t.deal_no, t.box_no, t.name, t.cert_no, t.card_no, t.status recover_status, b.corp_customer_id corp_id, ");
			sql.append("(select s.code_name from sys_code s where s.code_type = 'SEX' and s.code_value = b.gender) sex, ");
			sql.append("(select s.code_name from sys_code s where s.code_type = 'CERT_TYPE' and s.code_value = b.cert_type) cert_type, ");
			sql.append("(select s.code_name from sys_code s where s.code_type = 'CARD_TYPE' and s.code_value = c.card_type) card_type, ");
			sql.append("(select s.code_name from sys_code s where s.code_type = 'APPLY_WAY' and s.code_value = t.app_way) apply_way, ");
			sql.append("(select s.code_name from sys_code s where s.code_type = 'APPLY_TYPE' and s.code_value = t.app_type) apply_type, ");
			sql.append("to_char(t.app_date, 'yyyy-mm-dd hh24:mi:ss') apply_date, ");
			sql.append("(select s.full_name from sys_branch s where s.brch_id = c.apply_brch_id) apply_branch, ");
			sql.append("(select s.name from sys_users s where s.user_id = c.apply_user_id) apply_user, ");
			sql.append("(select s.full_name from sys_branch s where s.brch_id = c.rels_brch_id) issue_branch, ");
			sql.append("(select s.name from sys_users s where s.user_id = c.rels_user_id) issue_user, ");
			sql.append("to_char(c.rels_date, 'yyyy-mm-dd') issue_date, ");
			sql.append("(select s.full_name from sys_branch s where s.brch_id = t.brch_id) rec_branch, ");
			sql.append("(select s.name from sys_users s where s.user_id = t.user_id) rec_user, ");
			sql.append("to_char(t.rec_time, 'yyyy-mm-dd') rec_date, ");
			sql.append("(select s.full_name from sys_branch s where s.brch_id = t.FF_BRCH_ID) re_issue_branch, ");
			sql.append("(select s.name from sys_users s where s.user_id = t.FF_USER_ID) re_issue_user, ");
			sql.append("to_char(t.FF_DATE, 'yyyy-mm-dd') re_issue_date, ");
			sql.append("(select s.region_name from base_region s where s.region_id = b.region_id) region_name, ");
			sql.append("(select s.town_name from base_town s where s.town_id = b.town_id) town_name, ");
			sql.append("(select s.comm_name from base_comm s where s.comm_id = b.comm_id) community_name, ");
			sql.append("(select s.corp_name from base_corp s where s.customer_id = b.corp_customer_id) corp_name ");
			sql.append("from card_recover_reginfo t, base_personal b, card_apply c ");
			sql.append("where t.name = b.name and t.cert_no = b.cert_no and t.card_no = c.card_no");
			if (!Tools.processNull(idSql).equals("")) {
				sql.append(" and t.id in (" + idSql + ")");
			}
			if (!Tools.processNull(certNo).equals("")) {
				sql.append(" and t.cert_no = '" + certNo + "'");
			}
			if (!Tools.processNull(name).equals("")) {
				sql.append(" and t.name = '" + name + "'");
			}
			if (!Tools.processNull(cardNo).equals("")) {
				sql.append(" and t.card_no = '" + cardNo + "'");
			}
			if (!Tools.processNull(boxNo).equals("")) {
				sql.append(" and t.box_no = '" + boxNo + "'");
			}
			if (!Tools.processNull(recoverBranch).equals("")) {
				sql.append(" and t.brch_id = '" + recoverBranch + "'");
			}
			if (!Tools.processNull(recoverUser).equals("")) {
				sql.append(" and t.user_id = '" + recoverUser + "'");
			}
			if (!Tools.processNull(recoverBeginDate).equals("")) {
				sql.append(" and t.rec_time >= to_date('" + recoverBeginDate + " 00:00:00', 'yyyy-mm-dd hh24:mi:ss')");
			}
			if (!Tools.processNull(recoverEndDate).equals("")) {
				sql.append(" and t.rec_time <= to_date('" + recoverEndDate + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss')");
			}
			if (!Tools.processNull(recoverStatus).equals("")) {
				sql.append(" and t.status = '" + recoverStatus + "'");
			}
			if (!Tools.processNull(sort).equals("")) {
				sql.append(" order by " + sort + " " + order);
			} else {
				sql.append(" order by t.id");
			}
			Page list = baseService.pagingQuery(sql.toString(), page, rows);
			if (list.getAllRs() != null && list.getAllRs().size() > 0) {
				jsonObject.put("rows", list.getAllRs());
				jsonObject.put("total", list.getTotalCount());
			} else {
				throw new CommonException("根据查询条件未找到对应的卡片回收登记信息！");
			}
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String exportCardRecoverRegisterInfo(){
		try {
			queryCardRecoverRegisterInfo();
			JSONArray data = jsonObject.getJSONArray("rows");
			//
			String expDate = DateUtils.getNowTime();
			String fileName = "卡片回收信息";
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

			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 2000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 6000);
			sheet.setColumnWidth(4, 6000);
			sheet.setColumnWidth(5, 5000);
			sheet.setColumnWidth(6, 2500);
			sheet.setColumnWidth(7, 6000);
			sheet.setColumnWidth(8, 3000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 6000);
			sheet.setColumnWidth(11, 3000);
			sheet.setColumnWidth(12, 3000);
			sheet.setColumnWidth(13, 3000);
			sheet.setColumnWidth(14, 3000);
			sheet.setColumnWidth(15, 6000);
			sheet.setColumnWidth(16, 3000);
			sheet.setColumnWidth(17, 3000);
			sheet.setColumnWidth(18, 6000);
			sheet.setColumnWidth(19, 3000);
			sheet.setColumnWidth(20, 3000);
			sheet.setColumnWidth(21, 3000);
			sheet.setColumnWidth(22, 3000);
			sheet.setColumnWidth(23, 6000);
			sheet.setColumnWidth(24, 3000);
			sheet.setColumnWidth(25, 6000);

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
			int maxColumn = 26;
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
			String string = "导出时间：" + expDate;
			sheet.getRow(1).getCell(0).setCellValue(string);

			// third header
			sheet.getRow(2).getCell(0).setCellValue("流水号");
			sheet.getRow(2).getCell(1).setCellValue("盒号");
			sheet.getRow(2).getCell(2).setCellValue("姓名");
			sheet.getRow(2).getCell(3).setCellValue("证件号码");
			sheet.getRow(2).getCell(4).setCellValue("卡号");
			sheet.getRow(2).getCell(5).setCellValue("卡类型");
			sheet.getRow(2).getCell(6).setCellValue("回收状态");
			sheet.getRow(2).getCell(7).setCellValue("回收网点");
			sheet.getRow(2).getCell(8).setCellValue("回收柜员");
			sheet.getRow(2).getCell(9).setCellValue("回收时间");
			sheet.getRow(2).getCell(10).setCellValue("重新发放网点");
			sheet.getRow(2).getCell(11).setCellValue("重新发放柜员");
			sheet.getRow(2).getCell(12).setCellValue("重新发放时间");
			sheet.getRow(2).getCell(13).setCellValue("申领方式");
			sheet.getRow(2).getCell(14).setCellValue("申领类型");
			sheet.getRow(2).getCell(15).setCellValue("申领网点");
			sheet.getRow(2).getCell(16).setCellValue("申领柜员");
			sheet.getRow(2).getCell(17).setCellValue("申领时间");
			sheet.getRow(2).getCell(18).setCellValue("发放网点");
			sheet.getRow(2).getCell(19).setCellValue("发放柜员");
			sheet.getRow(2).getCell(20).setCellValue("发放时间");
			sheet.getRow(2).getCell(21).setCellValue("区域");
			sheet.getRow(2).getCell(22).setCellValue("乡镇");
			sheet.getRow(2).getCell(23).setCellValue("社区");
			sheet.getRow(2).getCell(24).setCellValue("单位编号");
			sheet.getRow(2).getCell(25).setCellValue("单位名称");

			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(0, headRows);
			
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
				row.getCell(0).setCellValue(item.getString("DEAL_NO"));
				row.getCell(1).setCellValue(item.getString("BOX_NO"));
				row.getCell(2).setCellValue(item.getString("NAME"));
				row.getCell(3).setCellValue(item.getString("CERT_NO"));
				row.getCell(4).setCellValue(item.getString("CARD_NO"));
				row.getCell(5).setCellValue(item.getString("CARD_TYPE"));
				String status = item.getString("RECOVER_STATUS");
				if (status.equals("0")) {
					status = "已回收";
				} else if (status.equals("1")) {
					status = "已发放";
				}
				row.getCell(6).setCellValue(status);
				row.getCell(7).setCellValue(item.getString("REC_BRANCH"));
				row.getCell(8).setCellValue(item.getString("REC_USER"));
				row.getCell(9).setCellValue(item.getString("REC_DATE"));
				row.getCell(10).setCellValue(item.getString("RE_ISSUE_BRANCH"));
				row.getCell(11).setCellValue(item.getString("RE_ISSUE_USER"));
				row.getCell(12).setCellValue(item.getString("RE_ISSUE_DATE"));
				row.getCell(13).setCellValue(item.getString("APPLY_WAY"));
				row.getCell(14).setCellValue(item.getString("APPLY_TYPE"));
				row.getCell(15).setCellValue(item.getString("APPLY_BRANCH"));
				row.getCell(16).setCellValue(item.getString("APPLY_USER"));
				row.getCell(17).setCellValue(item.getString("APPLY_DATE"));
				row.getCell(18).setCellValue(item.getString("ISSUE_BRANCH"));
				row.getCell(19).setCellValue(item.getString("ISSUE_USER"));
				row.getCell(20).setCellValue(item.getString("ISSUE_DATE"));
				row.getCell(21).setCellValue(item.getString("REGION_NAME"));
				row.getCell(22).setCellValue(item.getString("TOWN_NAME"));
				row.getCell(23).setCellValue(item.getString("COMM_NAME"));
				row.getCell(24).setCellValue(item.getString("CORP_ID"));
				row.getCell(25).setCellValue(item.getString("CORP_NAME"));
			}

			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportCardRecoverRegisterInfo",Constants.YES_NO_YES);
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String queryCardApplyInfo() {
		try {
			jsonObject.put("status", 0);
			jsonObject.put("errMsg", "");
			if (Tools.processNull(cardNo).equals("")) {
				throw new CommonException("卡号不能为空！");
			}
			CardBaseinfo cardBaseinfo = (CardBaseinfo) baseService.findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + cardNo + "'");
			if (cardBaseinfo == null) {
				throw new CommonException("根据卡号" + cardNo + "找不到卡片信息！");
			}
			CardApply cardApply = (CardApply) baseService.findOnlyRowByHql("from CardApply c where c.cardNo = '" + cardNo + "' and c.customerId = '" + cardBaseinfo.getCustomerId() + "'");
			if(cardApply == null) {
				throw new CommonException("根据卡号数据未找到相应的申领信息！");
			}
			CardApplyTask cardApplyTask = (CardApplyTask) baseService.findOnlyRowByHql("from CardApplyTask c where c.taskId = '" + cardApply.getTaskId() + "'");
			if (cardApplyTask == null) {
				throw new CommonException("根据申领信息未找到相应的任务信息！");
			}
			BasePersonal basePersonal = (BasePersonal) baseService.findOnlyRowByHql("from BasePersonal b where b.customerId = '" + cardApply.getCustomerId() + "'");
			if (basePersonal == null) {
				throw new CommonException("根据申领信息未找到相应的人员信息！");
			}
			if (!cardApply.getApplyState().equals(Constants.APPLY_STATE_YJS) && !cardApply.getApplyState().equals(Constants.APPLY_STATE_YFF)) {
				throw new CommonException("申领信息状态不是已接收或已发放状态，不能进行卡片回收操作！");
			}
			if (!cardApplyTask.getTaskState().equals(Constants.TASK_STATE_YJS) && !cardApplyTask.getTaskState().equals(Constants.TASK_STATE_FFZ) && !cardApplyTask.getTaskState().equals(Constants.TASK_STATE_FFWC)) {
				throw new CommonException("任务信息状态不是已接收、发放中或发放完成状态，不能进行卡片回收操作！");
			}
			jsonObject.put("name", basePersonal.getName());
			jsonObject.put("certNo", basePersonal.getCertNo());
			jsonObject.put("cardNo", cardNo);
			jsonObject.put("cardType", baseService.getCodeNameBySYS_CODE("CARD_TYPE", cardApply.getCardType()));
			jsonObject.put("applyWay", baseService.getCodeNameBySYS_CODE("APPLY_WAY", cardApply.getApplyWay()));
			jsonObject.put("applyType", baseService.getCodeNameBySYS_CODE("APPLY_TYPE", cardApply.getApplyType()));
			jsonObject.put("applyDate", DateUtil.formatDate(cardApply.getApplyDate(), "yyyy-MM-dd HH:mm:ss"));
			jsonObject.put("regionName", baseService.findOnlyFieldBySql("select region_name from base_region where region_id = '" + basePersonal.getRegionId() + "'"));
			jsonObject.put("townName", baseService.findOnlyFieldBySql("select town_name from base_town where town_id = '" + basePersonal.getTownId() + "'"));
			jsonObject.put("communityName", baseService.findOnlyFieldBySql("select comm_name from base_comm where comm_id = '" + basePersonal.getCommId() + "'"));
			jsonObject.put("corpId", basePersonal.getCorpCustomerId());
			jsonObject.put("corpName", baseService.findOnlyFieldBySql("select corp_name from base_corp where customer_id = '" + basePersonal.getCorpCustomerId() + "'"));
			jsonObject.put("concatAddress", basePersonal.getLetterAddr());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	public String saveCardRecoverRegister() {
		try {
			jsonObject.put("status", 0);
			jsonObject.put("errMsg", "");
			if (Tools.processNull(registerInfo).equals("")) {
				throw new CommonException("未传入卡片回收登记信息！");
			}
			cardRecoverRegisterService.saveCardRecoverRegister(jsonObject, registerInfo);
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
    public String saveCardRecovery(){
    	try{
    		if(Tools.processNull(this.cardNo).equals("")){
    			throw new CommonException("回收的卡号不能为空！");
    		}
    		if(Tools.processNull(this.boxNo).equals("")){
    			//throw new CommonException("存放盒号不能为空！");
    		}
    		Long dealNo = cardRecoverRegisterService.saveCardRecovery(cardNo, boxNo,null,baseService.getUser());
    		jsonObject.put("status","0");
    		jsonObject.put("dealNo",dealNo);
    	}catch(Exception e){
    		jsonObject.put("status","1");
    		jsonObject.put("errMsg",this.saveErrLog(e));
    	}
    	return this.JSONOBJ;
    }
    public String saveCardRecoveryIssuse(){
    	try{
    		if(Tools.processNull(this.cardNo).equals("")){
    			throw new CommonException("回收的卡号不能为空！");
    		}
    		CardApply apply = (CardApply) baseService.findOnlyRowByHql("from CardApply t where t.cardNo = '" + cardNo + "'");
    		if(apply == null){
    			throw new CommonException("根据卡号" + cardNo + "找不到申领记录信息！");
    		}
    		if(!Tools.processNull(apply.getApplyState()).equals(Constants.APPLY_STATE_YHS )){
    			throw new CommonException("卡号为" + cardNo + "的卡信息不是已回收状态，不能进行发放！");
    		}
    		TrServRec rec2 = cardRecoverRegisterService.saveCardRecoveryIssuse(apply, rec);
    		jsonObject.put("status","0");
    		jsonObject.put("dealNo",rec2.getDealNo());
    	}catch(Exception e){
    		jsonObject.put("status","1");
    		jsonObject.put("errMsg",this.saveErrLog(e));
    	}
    	return this.JSONOBJ;
    }
	public String saveCardIssue() {
		try {
			jsonObject.put("status", 0);
			jsonObject.put("errMsg", "");
			if (Tools.processNull(recoverId).equals("")) {
				throw new CommonException("未传入回收流水编号数据！");
			}
			CardRecoverReginfo cardRecoverReginfo = (CardRecoverReginfo) baseService.findOnlyRowByHql("from CardRecoverReginfo c where c.id = " + recoverId);
			if (cardRecoverReginfo == null) {
				throw new CommonException("根据回收流水编号未找到相应的卡片回收登记信息！");
			}
			CardBaseinfo cardBaseinfo = (CardBaseinfo) baseService.findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + cardRecoverReginfo.getCardNo() + "'");
			if (cardBaseinfo == null) {
				throw new CommonException("根据卡片回收登记信息未找到相应的卡片数据！");
			}
			CardApply cardApply = (CardApply) baseService.findOnlyRowByHql("from CardApply c where c.cardNo = '" + cardRecoverReginfo.getCardNo() + "'");
			if (cardApply == null) {
				throw new CommonException("根据卡号数据未找到相应的申领信息！");
			}
			CardApplyTask cardApplyTask = (CardApplyTask) baseService.findOnlyRowByHql("from CardApplyTask c where c.taskId = '" + cardApply.getTaskId() + "'");
			if (cardApplyTask == null) {
				throw new CommonException("根据申领信息未找到相应的任务信息！");
			}
			BasePersonal basePersonal = (BasePersonal) baseService.findOnlyRowByHql("from BasePersonal b where b.customerId = '" + cardApply.getCustomerId() + "'");
			if (basePersonal == null) {
				throw new CommonException("根据申领信息未找到相应的人员信息！");
			}
			if (!cardApplyTask.getTaskState().equals(Constants.TASK_STATE_YJS) && !cardApplyTask.getTaskState().equals(Constants.TASK_STATE_FFZ) && !cardApplyTask.getTaskState().equals(Constants.TASK_STATE_FFWC)) {
				throw new CommonException("任务信息状态不是已接收、发放中或发放完成状态，不能进行发放操作！");
			}
			if (!cardApply.getApplyState().equals(Constants.APPLY_STATE_YHS)) {
				throw new CommonException("申领信息状态不是已回收状态，不能进行发放操作！");
			}
			TrServRec trServRec = cardRecoverRegisterService.saveCardIssue(basePersonal, cardApply, cardRecoverReginfo, cardBaseinfo);
			jsonObject.put("dealNo", trServRec.getDealNo());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	public String getRecoverId() {
		return recoverId;
	}
	public void setRecoverId(String recoverId) {
		this.recoverId = recoverId;
	}
	public String getCertNo() {
		return certNo;
	}
	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getCardNo() {
		return cardNo;
	}
	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}
	public String getBoxNo() {
		return boxNo;
	}
	public void setBoxNo(String boxNo) {
		this.boxNo = boxNo;
	}
	public String getRecoverBranch() {
		return recoverBranch;
	}
	public void setRecoverBranch(String recoverBranch) {
		this.recoverBranch = recoverBranch;
	}
	public String getRecoverUser() {
		return recoverUser;
	}
	public void setRecoverUser(String recoverUser) {
		this.recoverUser = recoverUser;
	}
	public String getRecoverBeginDate() {
		return recoverBeginDate;
	}
	public void setRecoverBeginDate(String recoverBeginDate) {
		this.recoverBeginDate = recoverBeginDate;
	}
	public String getRecoverEndDate() {
		return recoverEndDate;
	}
	public void setRecoverEndDate(String recoverEndDate) {
		this.recoverEndDate = recoverEndDate;
	}
	public String getRecoverStatus() {
		return recoverStatus;
	}
	public void setRecoverStatus(String recoverStatus) {
		this.recoverStatus = recoverStatus;
	}
	public String getRegisterInfo() {
		return registerInfo;
	}
	public void setRegisterInfo(String registerInfo) {
		this.registerInfo = registerInfo;
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
	public String getDefaultErrorMsg() {
		return defaultErrorMsg;
	}
	public void setDefaultErrorMsg(String defaultErrorMsg) {
		this.defaultErrorMsg = defaultErrorMsg;
	}
	public TrServRec getRec() {
		return rec;
	}
	public void setRec(TrServRec rec) {
		this.rec = rec;
	}

	public String getIds() {
		return ids;
	}

	public void setIds(String ids) {
		this.ids = ids;
	}
}
