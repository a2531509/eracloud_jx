package com.erp.action;

import java.io.OutputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.commons.beanutils.BeanUtils;
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

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.SysReport;
import com.erp.model.Users;
import com.erp.service.CuteDayService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.PdfConbineUtil;
import com.erp.util.Tools;
import com.erp.viewModel.Page;


@SuppressWarnings("serial")
@Namespace("/cuteDayManage")
@Action(value = "cuteDayAction")
@Results({@Result(type="json",name="json"),
		@Result(name="toIndexUserCuteDayBal",location="/jsp/cuteDayManage/userCuteDayBal.jsp"),
		@Result(name="toIndexBrchCuteDayBal",location="/jsp/cuteDayManage/brchCuteDayBal.jsp")})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class CuteDayAction extends BaseAction {
	
	@Resource(name="cuteDayService")
	private CuteDayService cuteDayService;
	private Users user = null;
	private SysBranch brch = null;
	private String clrDate = "";
	private String msg = "";//返回错误信息
	private String checkIds = "";//强制柜员扎帐列表
	private String branchId = "";
	private String userId = "";
	private String startDate = "";
	private String endDate = "";
	private String queryRpType = "";
	private Boolean cascadeBrch = false;
	
	/**
	 * 初始化userInfo
	 * @return
	 */
	public String initUserInfo(){
		
		try {
 			user = cuteDayService.getUser();
			clrDate = cuteDayService.getClrDate();
		} catch (Exception e) {
			msg = "获取柜员信息发生错误："+e.getMessage();
			this.saveErrLog(e);
		}
		return "toIndexUserCuteDayBal";
	}
	/**
	 * 初始化网点信息
	 * Description <p>TODO</p>
	 * @return
	 */
	public String  initBrchInfo(){
		try {
			brch = (SysBranch)cuteDayService.findOnlyRowByHql("from SysBranch where brchId='"+cuteDayService.getUser().getBrchId()+"'");
			clrDate = cuteDayService.getClrDate();
			if(brch == null){
				throw new CommonException("查询网点信息出错");
			}
		} catch (Exception e) {
			msg = "获取网点信息发生错误："+e.getMessage();
			this.saveErrLog(e);
		}
		return "toIndexBrchCuteDayBal";
	}
	
	/**
	 * 柜员扎帐
	 * @return
	 */
	public String userDayBal(){
		String status = "0";
		String msg = "";
		String title = "操作返回信息";
		String actionNo = "";
		try {
			SysActionLog actionlog = cuteDayService.getCurrentActionLog();
			//1,调用存储过程汇总扎帐明细表 按照业务数据自己组合形成报表
			Users user = cuteDayService.getUser();
			if(Tools.processNull(user.getIsemployee()).equals("0")){
				throw new CommonException("已扎帐不能重复扎帐");
			}
			cuteDayService.saveUserDayBal(actionlog,user, "1");
			status = "0";
			msg = "扎帐成功";
			actionNo = actionlog.getDealNo().toString();
		} catch (Exception e) {
			status = "1";
			msg = "柜员扎帐发生错误："+e.getMessage();
			this.saveErrLog(e);
		}
		jsonObject.put("status", status);
		jsonObject.put("msg", msg);
		jsonObject.put("title", title);
		jsonObject.put("actionNo", Tools.processNull(actionNo));
		return "jsonObj";
	}
	
	
	/**
	 * 查询网点下柜员信息
	 * @return
	 */
	public String findAllUsers(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		try {
		    String head = "select t1.USER_ID ID,t1.USER_ID USER_ID,t1.NAME USER_NAME,t1.ISEMPLOYEE ISEMPLOYEE";
			StringBuffer sql = new StringBuffer(" from SYS_USERS t1 where " +
						" 1=1 and brch_id ='"+cuteDayService.getUser().getBrchId()+"'" );		
			Page pages = cuteDayService.pagingQuery(head+sql.toString(),page,10000);
			if(pages.getAllRs() != null){
				jsonObject.put("rows",pages.getAllRs());
				jsonObject.put("total", pages.getTotalCount());
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 * 强制柜员扎帐
	 */
	public String reforceUserDayBal(){
			String status = "0";
			String msg = "";
			String title = "操作返回信息";
			try {
				System.out.println(checkIds);
				
				SysActionLog actionlog = cuteDayService.getCurrentActionLog();
				Users user  = cuteDayService.getUser();
				//1，判断当前柜员是不是网点主管，不是则不可以进行柜员的强制扎帐
				if(user.getDutyId() == 0 ){
					throw new CommonException("当前柜员是普通柜员，不能进行网点柜员的强制扎帐！");
				}
				
				if(Tools.processNull(checkIds).equals("")){
					throw new CommonException("未选择扎帐柜员，请选择柜员进行强制扎帐！");
				}
				String[] checkIdArray = checkIds.split("\\|");
				String brchId = branchId;
				List<Users> users = new ArrayList<Users>();
				users = cuteDayService.findByHql("from Users where brchId='"+brchId+"'");
				cuteDayService.saveReforceUserDayBal(actionlog, user, checkIdArray);
				msg ="强制柜员扎帐成功";
			} catch (Exception e) {
				status = "1";
				msg = "强制柜员扎帐发生错误："+e.getMessage();
				this.saveErrLog(e);
			}
			
			jsonObject.put("status", status);
			jsonObject.put("msg", msg);
			jsonObject.put("title", title);
			return "jsonObj";
	}
	
	/**
	 * 网点扎帐
	 * @return
	 */
	public String brchDayBal(){
		String status = "0";
		String msg = "";
		String title = "操作返回信息";
		String actionNo = "";
		try {
			setClrDate(cuteDayService.getClrDate());
			SysActionLog actionlog = cuteDayService.getCurrentActionLog();
			Users user  = cuteDayService.getUser();
			String brchId = branchId;
			List<Users> users = new ArrayList<Users>();
			users = cuteDayService.findByHql("from Users where brchId='"+brchId+"'");
			for (int i = 0; i < users.size(); i++) {
				Users checkUSer = users.get(i);
				if(Tools.processNull(checkUSer.getIsemployee()).equals("1")||Tools.processNull(checkUSer.getIsemployee()).equals("")){
					throw new CommonException("该网点下还有柜员未进行扎帐，请先对该网点下的所有柜员进行扎帐后再进行网点扎帐！");
				}
			}
			SysActionLog operLog = (SysActionLog) BeanUtils.cloneBean(actionlog);
			SysActionLog brchLog = (SysActionLog) BeanUtils.cloneBean(actionlog);
			cuteDayService.saveUserDayBal(operLog, user, "1"); // 个人
			cuteDayService.saveBrchDayBal(brchLog, user, "2"); // 网点
			//
			SysReport brchReport = (SysReport) baseService.findOnlyRowByHql("from SysReport t where t.dealNo = '" + brchLog.getDealNo() + "'");
			byte[] brchReportContent = brchReport.getPdfContent();
			//
			SysReport operReport = (SysReport) baseService.findOnlyRowByHql("from SysReport t where t.dealNo = '" + operLog.getDealNo() + "'");
			byte[] operReportContent = operReport.getPdfContent();
			//
			PdfConbineUtil pdfConbineUtil = new PdfConbineUtil();
			pdfConbineUtil.add(operReportContent);
			pdfConbineUtil.add(brchReportContent);
			byte[] pdfContent = pdfConbineUtil.conbine(800f, 1000f);
			//
			response.setCharacterEncoding("UTF-8");
			response.setContentType("application/pdf");
			response.setContentLength(pdfContent.length);
			response.getOutputStream().write(pdfContent);
			response.getOutputStream().flush();
			response.getOutputStream().close();
			// 登出
			SecurityUtils.getSubject().logout();
		} catch (Exception e) {
			status = "1";
			msg = "网点扎帐发生错误："+e.getMessage();
			this.saveErrLog(e);
		}
		jsonObject.put("status", status);
		jsonObject.put("msg", msg);
		jsonObject.put("title", title);
		jsonObject.put("actionNo", Tools.processNull(actionNo));
		return "jsonObj";
	}

	/**
	 * 查询营业报表
	 * @return
	 */
	public String queryDayBal(){
		String status = "0";
		String msg = "";
		String title = "操作返回信息";
		String actionNo = "";
		String rptilte = "";
		try {
			if (("".equals(this.branchId)) && ("".equals(this.userId))) {
		        throw new CommonException("请选择网点号或柜员号进行查询！");
		      }
		      if ("".equals(this.clrDate)) {
		        throw new CommonException("请选择要查询的清分日期！");
		      }
		      if ("".equals(this.userId)||"erp2_erp2".equals(this.userId)){
			        SysBranch obranch = (SysBranch)this.cuteDayService.findOnlyRowByHql("from SysBranch where brchId='" + this.branchId + "'");
			        BigDecimal brcount = (BigDecimal)this.cuteDayService.findOnlyFieldBySql("select count(1) from stat_day_bal_data t where t.user_id is  null and t.brch_id is not null and t.brch_id='" + this.branchId + "' and t.clr_date='" + this.clrDate + "'");
			        if (brcount.intValue() == 0) {
			        	throw new CommonException(obranch.getFullName() + "网点" + "（" + this.clrDate + "）无扎帐数据！");
			        }
			        Map reportPara = new HashMap();
			        reportPara.put("p_Title", Constants.APP_REPORT_TITLE + obranch.getFullName() + this.cuteDayService.findTrCodeNameByCodeType(DealCode.CUTE_BRCH_DAY_BAL) + "凭证");
			        reportPara.put("p_Yrbzw", "日");
			        reportPara.put("p_Oper_Name", this.cuteDayService.getUser().getName());
			        reportPara.put("p_Date", DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss"));
			        reportPara.put("p_ClrDate", clrDate);
			        Users user = new Users();
			        setReportHashMap(cuteDayService.setReportPara(reportPara, "2", user, obranch,clrDate));
			        setReportFilePathAndName("/reportfiles/YCYingYeBaoBiao2.jasper");
			        rptilte = Constants.APP_REPORT_TITLE + obranch.getFullName() + this.cuteDayService.findTrCodeNameByCodeType(DealCode.CUTE_BRCH_DAY_BAL) + "凭证";
		      }else{
		    	  	Users user = (Users)this.cuteDayService.findOnlyRowByHql("from Users where userId='" + this.userId + "'");
			        BigDecimal brcount = (BigDecimal)this.cuteDayService.findOnlyFieldBySql("select count(1) from stat_day_bal_data t where t.user_id is not null and t.user_id='" + this.userId + "' and t.clr_date='" + this.clrDate + "'");
			        if (brcount.intValue() == 0) {
			        	throw new CommonException(user.getName() + "柜员" + "（" + this.clrDate + "）无扎帐数据！");
			        }
			        Map reportPara = new HashMap();
			        reportPara.put("p_Title", Constants.APP_REPORT_TITLE + user.getName() + this.cuteDayService.findTrCodeNameByCodeType(DealCode.CUTE_USER_DAY_BAL) + "凭证");
			        reportPara.put("p_Yrbzw", "日");
			        reportPara.put("p_Oper_Name", this.cuteDayService.getUser().getName());
			        reportPara.put("p_Date", DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss"));
			        reportPara.put("p_ClrDate", clrDate);
			        SysBranch brch = new SysBranch();
			        setReportHashMap(cuteDayService.setReportPara(reportPara, "1", user, brch,clrDate));
			        setReportFilePathAndName("/reportfiles/YCYingYeBaoBiao.jasper");
			        rptilte = Constants.APP_REPORT_TITLE + user.getName() + this.cuteDayService.findTrCodeNameByCodeType(DealCode.CUTE_USER_DAY_BAL) + "凭证";
		      }
		}catch (Exception e) {
			status = "1";
			msg = "查询发生错误："+e.getMessage();
			this.saveErrLog(e);
		}
		jsonObject.put("status", status);
		jsonObject.put("msg", msg);
		jsonObject.put("title", title);
		jsonObject.put("rptilte", rptilte);
		jsonObject.put("actionNo", Tools.processNull(actionNo));
		return "jsonObj";
	}
	
	public String queryDayBals(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		try {
			if (Tools.processNull(queryRpType).equals("1") && Tools.processNull(branchId).equals("")) {// 查询网点营业报表
				throw new CommonException("请选择网点进行查询");
			} else if (Tools.processNull(queryRpType).equals("0") && Tools.processNull(branchId).equals("") && Tools.processNull(userId).equals("")) {// 查询柜员营业报表
				throw new CommonException("请选择网点，柜员进行查询");
			}
			//
			String checkIdSql = "";
			if (!Tools.processNull(checkIds).equals("")) {
				String[] brchIdArr = checkIds.split(",");
				for (String brchId : brchIdArr) {
					checkIdSql += "'" + brchId + "',";
				}
				checkIdSql = checkIdSql.substring(0, checkIdSql.length()-1);
			}
			//
			StringBuilder sqlBuffer = new StringBuilder();
			sqlBuffer.append("select t.clr_date, count(*) num,t2.brch_id BRCH_ID,t2.full_name brch_name,t1.name user_name, t1.user_id user_id,");
			sqlBuffer.append("nvl(sum(decode(t.stat_key, 'online_in', t.num, 0)), 0) zhxjcz_num, "
					+ "nvl(sum(decode(t.stat_key, 'offline_in', t.num, 0)), 0) qbxjcz_num, "
					+ "nvl(sum(decode(t.stat_key, 'in_out', nvl(t.pre_amt, 0))), 0) per_amt, "
					+ "nvl(sum(decode(t.stat_key, 'in_out', nvl(t.cur_amt, 0))), 0) cur_amt, "
					+ "nvl(sum(decode(t.stat_key, 'in_out', nvl(t.cur_in_num, 0))), 0)DAY_IN_NUM, "
					+ "nvl(sum(decode(t.stat_key, 'in_out', nvl(t.cur_in_amt, 0))), 0)DAY_IN_AMT, "
					+ "nvl(sum(decode(t.stat_key, 'in_out', nvl(t.cur_out_num, 0))), 0)DAY_out_NUM, "
					+ "nvl(sum(decode(t.stat_key, 'in_out', abs(nvl(t.cur_out_amt, 0)))), 0)DAY_out_AMT, "
					+ "nvl(sum(decode(t.stat_key, 'online_in', nvl(t.amt, 0), 0)), 0) zhxjcz_amt, "
					+ "nvl(sum(decode(t.stat_key, 'offline_in', nvl(t.amt, 0), 0)), 0) qbxjcz_amt, "
					+ "nvl(sum(decode(t.stat_key, 'gytj', abs(nvl(t.num, 0)))), 0)gytj_num, "
					+ "nvl(sum(decode(t.stat_key, 'gytj', abs(nvl(t.amt, 0)))), 0)gytj_amt, "
					+ "nvl(sum(decode(t.stat_key, 'online_out', nvl(t.num, 0))),0) zhczcx_num, "
					+ "nvl(sum(decode(t.stat_key, 'online_out', abs(nvl(t.amt, 0)))), 0)zhczcx_amt, "
					+ "nvl(sum(decode(t.stat_key, 'offline_out', nvl(t.num, 0))),0) qbczcx_num, "
					+ "nvl(sum(decode(t.stat_key, 'offline_out', abs(nvl(t.amt, 0)))), 0)qbczcx_amt, "
					+ "nvl(sum(decode(t.stat_key, 'zxzhfh_out', abs(nvl(t.num, 0)))), 0)zxfh_num, "
					+ "nvl(sum(decode(t.stat_key, 'zxzhfh_out', abs(nvl(t.amt, 0)))), 0)zxfh_amt, "
					+ "nvl(sum(decode(t.stat_key, 'wdck_out', abs(nvl(t.num, 0)))), 0)wdck_num, "
					+ "nvl(sum(decode(t.stat_key, 'wdck_out', abs(nvl(t.amt, 0)))), 0)wdck_amt, "
					+ "nvl(sum(decode(t.stat_key, 'fwmmcz', abs(nvl(t.num, 0)))), 0)fwmmcz_num, "
					+ "nvl(sum(decode(t.stat_key, 'fwmmxg', abs(nvl(t.num, 0)))), 0)fwmmxg_num, "
					+ "nvl(sum(decode(t.stat_key, 'jymmcz', abs(nvl(t.num, 0)))), 0)jymmcz_num, "
					+ "nvl(sum(decode(t.stat_key, 'jymmxg', abs(nvl(t.num, 0)))), 0)jymmxg_num, "
					+ "nvl(sum(decode(t.stat_key, 'sbkmmcz', abs(nvl(t.num, 0)))), 0)sbmmcz_num, "
					+ "nvl(sum(decode(t.stat_key, 'sbkmmxg', abs(nvl(t.num, 0)))), 0)sbmmxg_num, "
					+ "nvl(sum(decode(t.stat_key, 'kpsdyw', abs(nvl(t.num, 0)))), 0)kpsdyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'kpjsyw', abs(nvl(t.num, 0)))), 0)kpjsyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'ygsyw', abs(nvl(t.num, 0)))), 0)ygsyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'gsyw', abs(nvl(t.num, 0)))), 0)gsyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'jgsyw', abs(nvl(t.num, 0)))), 0)jgsyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'bkyw', abs(nvl(t.num, 0)), 'yhbkyw', abs(nvl(t.num, 0)))), 0)bkyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'hkyw', abs(nvl(t.num, 0)), 'yhhkyw', abs(nvl(t.num, 0)))), 0)hkyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'bkyw', abs(nvl(t.amt, 0)), 'hkyw', abs(nvl(t.amt, 0)))), 0) bhkyw_amt, "
					+ "nvl(sum(decode(t.stat_key, 'bkcxyw', abs(nvl(t.num, 0)), 'hkcxyw', abs(nvl(t.num, 0)))), 0) bhkcxyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'bkcxyw', abs(nvl(t.amt, 0)), 'hkcxyw', abs(nvl(t.amt, 0)))), 0) bhkcxyw_amt, "
					+ "nvl(sum(decode(t.stat_key, 'zxyw', abs(nvl(t.num, 0)))), 0)zxyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'hjl_qr_in', abs(nvl(t.num, 0)))), 0) hjlqr_num, "//hjl_qr_in
					+ "nvl(sum(decode(t.stat_key, 'hjl_qr_in', abs(nvl(t.amt, 0)))), 0) hjlqr_amt, "//hjl_qr_in
					+ "nvl(sum(decode(t.stat_key, 'card_issue', abs(nvl(t.num, 0)))), 0) CARD_ISSUE_NUM, "
					+ "nvl(sum(decode(t.stat_key, 'tcqbg', abs(nvl(t.num, 0)))), 0) tcqbg_NUM, "
					+ "nvl(sum(decode(t.stat_key, 'hkzqb', abs(nvl(t.num, 0)))), 0) hkzqb_NUM, "
					+ "nvl(sum(decode(t.stat_key, 'grslyw', abs(nvl(t.num, 0)))), 0)gmgrsl_num "
					+ "from stat_day_bal_data t,sys_users t1,sys_branch t2  where t.user_id = t1.user_id(+) and t.brch_id = t2.brch_id(+) ");
			if (Tools.processNull(queryRpType).equals("1")){
				if(cascadeBrch){
					sqlBuffer.append("and t.user_id is null and t.brch_id in (select brch_id from sys_branch start with brch_id = '" 
							+ branchId + "' connect by  prior sysbranch_id = pid) ");
				} else {
					sqlBuffer.append("and t.user_id is null and t.brch_id is not null and t.brch_id ='"+branchId+"' ");
				}
			} else {
				if (!Tools.processNull(branchId).equals("")) {
					sqlBuffer.append("and t.brch_id = '" + branchId + "' ");
				}
				if (!Tools.processNull(userId).equals("")) {// 查询指定柜员
					sqlBuffer.append(" and t.user_id is not null and t.user_id ='" + userId + "' ");
				} else {// 查询所有柜员
					sqlBuffer.append(" and t.user_id is not null and t.user_id in (select h.user_id from sys_users h where h.brch_id ='" + branchId + "') ");
				}
			}
			if(!Tools.processNull(checkIdSql).equals("")){
				sqlBuffer.append("and t.brch_id||t.user_id||t.clr_date in (" + checkIdSql + ") ");
			}
			if (!Tools.processNull(startDate).equals("")) {
				sqlBuffer.append("and t.clr_date >= '" + startDate + "' ");
			}
			if (!Tools.processNull(endDate).equals("")) {
				sqlBuffer.append("and t.clr_date <= '" + endDate + "' ");
			}
			sqlBuffer.append("group by t.brch_id, t.clr_date,t1.name,t2.full_name,t2.brch_id,t1.user_id ");
			if(!Tools.processNull(sort).equals("")){
				sqlBuffer.append("order by " + sort);
				
				if(!Tools.processNull(order).equals("")){
					sqlBuffer.append(" " + order);
				}
			} else {
				sqlBuffer.append( "order by t.clr_date desc");
			}
			Page pageDate = cuteDayService.pagingQuery(sqlBuffer.toString(), page, rows);
			if(pageDate == null || pageDate.getAllRs() == null || pageDate.getAllRs().isEmpty()){
				throw new CommonException("没有数据.");
			}
			jsonObject.put("total", pageDate.getTotalCount());
			jsonObject.put("rows", pageDate.getAllRs());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		
		return JSONOBJ;
	}
	
	/**
	 * @author Yueh
	 * @return
	 */
	public String exportDayBals(){
		try {
			queryDayBals();
			JSONArray data = jsonObject.getJSONArray("rows");
			String typeName = queryRpType.equals("1") ?"网点":"柜员";
			String fileName = typeName + "营业日报";
			
			// workbook
			Workbook workbook = new HSSFWorkbook();
			int maxColumn = queryRpType.equals("1") ? 44 : 45;
			int headRow = 5;
			Sheet sheet = workbook.createSheet(fileName);
			for (int i = 0; i < maxColumn; i++) {
				sheet.setColumnWidth(i, 4000);
			}

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
			// headCellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);
			// cellStyle
			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);
			
			// header
			for (int i = 0; i < headRow; i++) {
				Row row = sheet.createRow(i);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			sheet.getRow(1).getCell(0).setCellValue("导出时间：" + DateUtils.getNowTime());
			
			// header 2
			sheet.getRow(2).getCell(0).setCellValue("网点编号");
			sheet.getRow(2).getCell(1).setCellValue("网点名称");
			if (queryRpType.equals("0")) {
				sheet.getRow(2).getCell(2).setCellValue("柜员");
			}
			sheet.getRow(2).getCell(maxColumn - 42).setCellValue("清分日期");
			sheet.getRow(2).getCell(maxColumn - 41).setCellValue("收入");
			sheet.getRow(2).getCell(maxColumn - 33).setCellValue("支出");
			sheet.getRow(2).getCell(maxColumn - 21).setCellValue("现金汇总");
			sheet.getRow(2).getCell(maxColumn - 18).setCellValue("业务统计");
			
			// header 3
			sheet.getRow(3).getCell(maxColumn - 41).setCellValue("市民卡账户充值");
			sheet.getRow(3).getCell(maxColumn - 39).setCellValue("市民卡钱包充值");
			sheet.getRow(3).getCell(maxColumn - 37).setCellValue("补换卡金额");
			sheet.getRow(3).getCell(maxColumn - 35).setCellValue("本日收入汇总");
			// 支出
			sheet.getRow(3).getCell(maxColumn - 33).setCellValue("市民卡账户充值撤销");
			sheet.getRow(3).getCell(maxColumn - 31).setCellValue("市民卡钱包充值撤销");
			sheet.getRow(3).getCell(maxColumn - 29).setCellValue("补换卡撤销金额");
			sheet.getRow(3).getCell(maxColumn - 27).setCellValue("注销账户返还余额");
			sheet.getRow(3).getCell(maxColumn - 25).setCellValue("网点存款");
			sheet.getRow(3).getCell(maxColumn - 23).setCellValue("本日支出汇总");
			// 业务统计
			sheet.getRow(3).getCell(maxColumn - 18).setCellValue("灰记录处理");
			sheet.getRow(3).getCell(maxColumn - 16).setCellValue("服务密码重置");
			sheet.getRow(3).getCell(maxColumn - 15).setCellValue("服务密码修改");
			sheet.getRow(3).getCell(maxColumn - 14).setCellValue("交易密码重置");
			sheet.getRow(3).getCell(maxColumn - 13).setCellValue("交易密码修改");
			sheet.getRow(3).getCell(maxColumn - 12).setCellValue("社保密码重置");
			sheet.getRow(3).getCell(maxColumn - 11).setCellValue("社保密码修改");
			sheet.getRow(3).getCell(maxColumn - 10).setCellValue("零星申领");
			sheet.getRow(3).getCell(maxColumn - 9).setCellValue("卡发放");
			sheet.getRow(3).getCell(maxColumn - 8).setCellValue("临时挂失");
			sheet.getRow(3).getCell(maxColumn - 7).setCellValue("挂失");
			sheet.getRow(3).getCell(maxColumn - 6).setCellValue("解挂失");
			sheet.getRow(3).getCell(maxColumn - 5).setCellValue("补卡");
			sheet.getRow(3).getCell(maxColumn - 4).setCellValue("换卡");
			sheet.getRow(3).getCell(maxColumn - 3).setCellValue("注销");
			sheet.getRow(3).getCell(maxColumn - 2).setCellValue("换卡转钱包");
			sheet.getRow(3).getCell(maxColumn - 1).setCellValue("统筹区变更");
			
			// header 4
			sheet.getRow(4).getCell(maxColumn - 41).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 40).setCellValue("金额");
			sheet.getRow(4).getCell(maxColumn - 39).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 38).setCellValue("金额");
			sheet.getRow(4).getCell(maxColumn - 37).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 36).setCellValue("金额");
			sheet.getRow(4).getCell(maxColumn - 35).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 34).setCellValue("金额");
			sheet.getRow(4).getCell(maxColumn - 33).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 32).setCellValue("金额");
			sheet.getRow(4).getCell(maxColumn - 31).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 30).setCellValue("金额");
			sheet.getRow(4).getCell(maxColumn - 29).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 28).setCellValue("金额");
			sheet.getRow(4).getCell(maxColumn - 27).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 26).setCellValue("金额");
			sheet.getRow(4).getCell(maxColumn - 25).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 24).setCellValue("金额");
			sheet.getRow(4).getCell(maxColumn - 23).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 22).setCellValue("金额");
			sheet.getRow(4).getCell(maxColumn - 21).setCellValue("本期发生金额");
			sheet.getRow(4).getCell(maxColumn - 20).setCellValue("上期结余");
			sheet.getRow(4).getCell(maxColumn - 19).setCellValue("本期结余");
			sheet.getRow(4).getCell(maxColumn - 18).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 17).setCellValue("金额");
			
			// Merge
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			// 2
			sheet.addMergedRegion(new CellRangeAddress(2, 4, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(2, 4, 1, 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 4, 2, 2));
			if (queryRpType.equals("0")) {
				sheet.addMergedRegion(new CellRangeAddress(2, 4, 3, 3));
			}
			sheet.addMergedRegion(new CellRangeAddress(2, 2, maxColumn - 41, maxColumn - 34));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, maxColumn - 33, maxColumn - 24));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, maxColumn - 33, maxColumn - 22));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, maxColumn - 21, maxColumn - 19));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, maxColumn - 18, maxColumn - 1));
			// 3
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 41, maxColumn - 40));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 39, maxColumn - 38));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 37, maxColumn - 36));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 35, maxColumn - 34));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 33, maxColumn - 32));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 31, maxColumn - 30));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 29, maxColumn - 28));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 27, maxColumn - 26));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 25, maxColumn - 24));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 23, maxColumn - 22));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 18, maxColumn - 17));//
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 16, maxColumn - 16));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 15, maxColumn - 15));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 14, maxColumn - 14));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 13, maxColumn - 13));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 12, maxColumn - 12));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 11, maxColumn - 11));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 10, maxColumn - 10));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 9, maxColumn - 9));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 8, maxColumn - 8));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 7, maxColumn - 7));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 6, maxColumn - 6));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 5, maxColumn - 5));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 4, maxColumn - 4));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 3, maxColumn - 3));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 2, maxColumn - 2));
			sheet.addMergedRegion(new CellRangeAddress(3, 4, maxColumn - 1, maxColumn - 1));
			
			//
			sheet.createFreezePane(queryRpType.equals("0") ? 4 : 3, headRow);
			
			//
			int zhczNum = 0;
			double zhczAmt = 0;
			int qbczNum = 0;
			double qbczAmt = 0;
			int bhkNum = 0;
			double bhkAmt = 0;
			int gytjInNum = 0;
			double gytjInAmt = 0;
			int dayInNum = 0;
			double dayInAmt = 0;
			//
			int zhczcxNum = 0;
			double zhczcxAmt = 0;
			int qbczcxNum = 0;
			double qbczcxAmt = 0;
			int bhkcxNum = 0;
			double bhkcxAmt = 0;
			int zxfhNum = 0;
			double zxfhAmt = 0;
			int wdckNum = 0;
			double wdckAmt = 0;
			int gytjOutNum = 0;
			double gytjOutAmt = 0;
			int dayOutNum = 0;
			double dayOutAmt = 0;
			//
			double dayAmt = 0;
			//
			int hjlqrNum = 0;
			double hjlqrAmt = 0;
			//
			int fwmmcz = 0;
			int fwmmxg = 0;
			int jymmcz = 0;
			int jymmxg = 0;
			int sbmmcz = 0;
			int sbmmxg = 0;
			int apply = 0;
			int cardIssue = 0;
			int ygs = 0;
			int gs = 0;
			int jgs = 0;
			int bk = 0;
			int hk = 0;
			int zx = 0;
			int hkzqb = 0;
			int tcqbg = 0;
			// body
			for (int i = 0; i < data.size(); i++) {
				Row row = sheet.createRow(i + headRow);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(cellStyle);
				}
				
				JSONObject item = data.getJSONObject(i);
				row.getCell(0).setCellValue(item.getString("BRCH_ID"));
				row.getCell(1).setCellValue(item.getString("BRCH_NAME"));
				if (queryRpType.equals("0")) {
					row.getCell(2).setCellValue(item.getString("USER_NAME"));
				}
				row.getCell(maxColumn - 42).setCellValue(item.getString("CLR_DATE"));
				row.getCell(maxColumn - 41).setCellValue(item.getIntValue("ZHXJCZ_NUM"));
				row.getCell(maxColumn - 40).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 40).setCellValue(item.getDoubleValue("ZHXJCZ_AMT") / 100);
				zhczNum += item.getIntValue("ZHXJCZ_NUM");
				zhczAmt += item.getDoubleValue("ZHXJCZ_AMT");
				//
				row.getCell(maxColumn - 39).setCellValue(item.getIntValue("QBXJCZ_NUM"));
				row.getCell(maxColumn - 38).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 38).setCellValue(item.getDoubleValue("QBXJCZ_AMT") / 100);
				qbczNum += item.getIntValue("QBXJCZ_NUM");
				qbczAmt += item.getDoubleValue("QBXJCZ_AMT");
				//
				row.getCell(maxColumn - 37).setCellValue(item.getIntValue("BKYW_NUM") + item.getIntValue("HKYW_NUM"));
				row.getCell(maxColumn - 36).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 36).setCellValue(item.getDoubleValue("BHKYW_AMT") / 100);
				bhkNum += item.getIntValue("BKYW_NUM") + item.getIntValue("HKYW_NUM");
				bhkAmt += item.getDoubleValue("BHKYW_AMT");
				//
				row.getCell(maxColumn - 35).setCellValue(item.getIntValue("DAY_IN_NUM"));
				row.getCell(maxColumn - 34).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 34).setCellValue(item.getDoubleValue("DAY_IN_AMT") / 100);
				dayInNum += item.getIntValue("DAY_IN_NUM");
				dayInAmt += item.getDoubleValue("DAY_IN_AMT");
				//
				row.getCell(maxColumn - 33).setCellValue(item.getIntValue("ZHCZCX_NUM"));
				row.getCell(maxColumn - 32).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 32).setCellValue(item.getDoubleValue("ZHCZCX_AMT") / 100);
				zhczcxNum += item.getIntValue("ZHCZCX_NUM");
				zhczcxAmt += item.getDoubleValue("ZHCZCX_AMT");
				//
				row.getCell(maxColumn - 31).setCellValue(item.getIntValue("QBCZCX_NUM"));
				row.getCell(maxColumn - 30).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 30).setCellValue(item.getDoubleValue("QBCZCX_AMT") / 100);
				qbczcxNum += item.getIntValue("QBCZCX_NUM");
				qbczcxAmt += item.getDoubleValue("QBCZCX_AMT");
				//
				row.getCell(maxColumn - 29).setCellValue(item.getIntValue("BHKCXYW_NUM"));
				row.getCell(maxColumn - 28).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 28).setCellValue(item.getDoubleValue("BHKCXYW_AMT") / 100);
				bhkcxNum += item.getIntValue("BHKCXYW_NUM");
				bhkcxAmt += item.getDoubleValue("BHKCXYW_AMT");
				//
				row.getCell(maxColumn - 27).setCellValue(item.getIntValue("ZXFH_NUM"));
				row.getCell(maxColumn - 26).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 26).setCellValue(item.getDoubleValue("ZXFH_AMT") / 100);
				zxfhNum += item.getIntValue("ZXFH_NUM");
				zxfhAmt += item.getDoubleValue("ZXFH_AMT");
				//
				row.getCell(maxColumn - 25).setCellValue(item.getIntValue("WDCK_NUM"));
				row.getCell(maxColumn - 24).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 24).setCellValue(item.getDoubleValue("WDCK_AMT") / 100);
				wdckNum += item.getIntValue("WDCK_NUM");
				wdckAmt += item.getDoubleValue("WDCK_AMT");
				//
				row.getCell(maxColumn - 23).setCellValue(item.getIntValue("DAY_OUT_NUM"));
				row.getCell(maxColumn - 22).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 22).setCellValue(item.getDoubleValue("DAY_OUT_AMT") / 100);
				dayOutNum += item.getIntValue("DAY_OUT_NUM");
				dayOutAmt += item.getDoubleValue("DAY_OUT_AMT");
				//
				row.getCell(maxColumn - 21).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 21).setCellValue((item.getDoubleValue("DAY_IN_AMT") - item.getDoubleValue("DAY_OUT_AMT")) / 100);
				row.getCell(maxColumn - 20).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 20).setCellValue(item.getDoubleValue("PER_AMT") / 100);
				row.getCell(maxColumn - 19).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 19).setCellValue(item.getDoubleValue("CUR_AMT") / 100);
				dayAmt += item.getDoubleValue("DAY_IN_AMT") - item.getDoubleValue("DAY_OUT_AMT");
				//
				row.getCell(maxColumn - 18).setCellValue(item.getIntValue("HJLQR_NUM"));
				row.getCell(maxColumn - 17).setCellStyle(moneyCellStyle);
				row.getCell(maxColumn - 17).setCellValue(item.getDoubleValue("HJLQR_AMT") / 100);
				hjlqrNum += item.getIntValue("HJLQR_NUM");
				hjlqrAmt += item.getDoubleValue("HJLQR_AMT");
				//
				row.getCell(maxColumn - 16).setCellValue(item.getIntValue("FWMMCZ_NUM"));//FWMMCZ_NUM
				fwmmcz += item.getIntValue("FWMMCZ_NUM");
				row.getCell(maxColumn - 15).setCellValue(item.getIntValue("FWMMXG_NUM"));
				fwmmxg += item.getIntValue("FWMMXG_NUM");
				row.getCell(maxColumn - 14).setCellValue(item.getIntValue("JYMMCZ_NUM"));
				jymmcz += item.getIntValue("JYMMCZ_NUM");
				row.getCell(maxColumn - 13).setCellValue(item.getIntValue("JYMMXG_NUM"));
				jymmxg += item.getIntValue("JYMMXG_NUM");
				row.getCell(maxColumn - 12).setCellValue(item.getIntValue("SBMMCZ_NUM"));
				sbmmcz += item.getIntValue("SBMMCZ_NUM");
				row.getCell(maxColumn - 11).setCellValue(item.getIntValue("SBMMXG_NUM"));
				sbmmxg += item.getIntValue("SBMMXG_NUM");
				row.getCell(maxColumn - 10).setCellValue(item.getIntValue("GMGRSL_NUM"));
				apply += item.getIntValue("GMGRSL_NUM");
				row.getCell(maxColumn - 9).setCellValue(item.getIntValue("CARD_ISSUE_NUM"));
				cardIssue += item.getIntValue("CARD_ISSUE_NUM");
				row.getCell(maxColumn - 8).setCellValue(item.getIntValue("YGSYW_NUM"));
				ygs += item.getIntValue("YGSYW_NUM");
				row.getCell(maxColumn - 7).setCellValue(item.getIntValue("GSYW_NUM"));
				gs += item.getIntValue("GSYW_NUM");
				row.getCell(maxColumn - 6).setCellValue(item.getIntValue("JGSYW_NUM"));
				jgs += item.getIntValue("JGSYW_NUM");
				row.getCell(maxColumn - 5).setCellValue(item.getIntValue("BKYW_NUM"));
				bk += item.getIntValue("BKYW_NUM");
				row.getCell(maxColumn - 4).setCellValue(item.getIntValue("HKYW_NUM"));
				hk += item.getIntValue("HKYW_NUM");
				row.getCell(maxColumn - 3).setCellValue(item.getIntValue("ZXYW_NUM"));
				zx += item.getIntValue("ZXYW_NUM");
				row.getCell(maxColumn - 2).setCellValue(item.getIntValue("HKZQB_NUM"));
				hkzqb += item.getIntValue("HKZQB_NUM");
				row.getCell(maxColumn - 1).setCellValue(item.getIntValue("TCQBG_NUM"));
				tcqbg += item.getIntValue("TCQBG_NUM");
			}
			
			// footer
			Row footer = sheet.createRow(headRow + data.size());
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = footer.createCell(j);
				cell.setCellStyle(cellStyle);
			}
			footer.getCell(0).setCellValue("统计：");
			footer.getCell(1).setCellValue("共 " + data.size() + " 条记录");
			footer.getCell(maxColumn - 41).setCellValue(zhczNum);
			footer.getCell(maxColumn - 40).setCellStyle(moneyCellStyle);
			footer.getCell(maxColumn - 40).setCellValue(zhczAmt / 100);
			footer.getCell(maxColumn - 39).setCellValue(qbczNum);
			footer.getCell(maxColumn - 38).setCellStyle(moneyCellStyle);
			footer.getCell(maxColumn - 38).setCellValue(qbczAmt / 100);
			footer.getCell(maxColumn - 37).setCellValue(bhkNum);
			footer.getCell(maxColumn - 36).setCellStyle(moneyCellStyle);
			footer.getCell(maxColumn - 36).setCellValue(bhkAmt / 100);
			footer.getCell(maxColumn - 35).setCellValue(dayInNum);
			footer.getCell(maxColumn - 34).setCellStyle(moneyCellStyle);
			footer.getCell(maxColumn - 34).setCellValue(dayInAmt / 100);
			footer.getCell(maxColumn - 33).setCellValue(zhczcxNum);
			footer.getCell(maxColumn - 32).setCellStyle(moneyCellStyle);
			footer.getCell(maxColumn - 32).setCellValue(zhczcxAmt / 100);
			footer.getCell(maxColumn - 31).setCellValue(qbczcxNum);
			footer.getCell(maxColumn - 30).setCellStyle(moneyCellStyle);
			footer.getCell(maxColumn - 30).setCellValue(qbczcxAmt / 100);
			footer.getCell(maxColumn - 29).setCellValue(bhkcxNum);
			footer.getCell(maxColumn - 28).setCellStyle(moneyCellStyle);
			footer.getCell(maxColumn - 28).setCellValue(bhkcxAmt / 100);
			footer.getCell(maxColumn - 27).setCellValue(zxfhNum);
			footer.getCell(maxColumn - 26).setCellStyle(moneyCellStyle);
			footer.getCell(maxColumn - 26).setCellValue(zxfhAmt / 100);
			footer.getCell(maxColumn - 25).setCellValue(wdckNum);
			footer.getCell(maxColumn - 24).setCellStyle(moneyCellStyle);
			footer.getCell(maxColumn - 24).setCellValue(wdckAmt / 100);
			footer.getCell(maxColumn - 23).setCellValue(dayOutNum);
			footer.getCell(maxColumn - 22).setCellStyle(moneyCellStyle);
			footer.getCell(maxColumn - 22).setCellValue(dayOutAmt / 100);
			//
			footer.getCell(maxColumn - 21).setCellStyle(moneyCellStyle);
			footer.getCell(maxColumn - 21).setCellValue(dayAmt / 100);
			//
			footer.getCell(maxColumn - 18).setCellValue(hjlqrNum);
			footer.getCell(maxColumn - 17).setCellStyle(moneyCellStyle);
			footer.getCell(maxColumn - 17).setCellValue(hjlqrAmt / 100);
			footer.getCell(maxColumn - 16).setCellValue(fwmmcz);//FWMMCZ_NUM
			footer.getCell(maxColumn - 15).setCellValue(fwmmxg);
			footer.getCell(maxColumn - 14).setCellValue(jymmcz);
			footer.getCell(maxColumn - 13).setCellValue(jymmxg);
			footer.getCell(maxColumn - 12).setCellValue(sbmmcz);//
			footer.getCell(maxColumn - 11).setCellValue(sbmmxg);
			footer.getCell(maxColumn - 10).setCellValue(apply);
			footer.getCell(maxColumn - 9).setCellValue(cardIssue);
			footer.getCell(maxColumn - 8).setCellValue(ygs);
			footer.getCell(maxColumn - 7).setCellValue(gs);
			footer.getCell(maxColumn - 6).setCellValue(jgs);
			footer.getCell(maxColumn - 5).setCellValue(bk);
			footer.getCell(maxColumn - 4).setCellValue(hk);
			footer.getCell(maxColumn - 3).setCellValue(zx);
			footer.getCell(maxColumn - 2).setCellValue(hkzqb);
			footer.getCell(maxColumn - 1).setCellValue(tcqbg);
			
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			OutputStream output = response.getOutputStream();
			workbook.write(output);
			workbook.close();
			output.flush();
			output.close();
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	//TODO
	public Users getUser() {
		return user;
	}

	public void setUser(Users user) {
		this.user = user;
	}

	public String getClrDate() {
		return clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
	}

	public SysBranch getBrch() {
		return brch;
	}

	public void setBrch(SysBranch brch) {
		this.brch = brch;
	}

	public String getMsg() {
		return msg;
	}

	public void setMsg(String msg) {
		this.msg = msg;
	}

	public String getCheckIds() {
		return checkIds;
	}

	public void setCheckIds(String checkIds) {
		this.checkIds = checkIds;
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
	
	public String getQueryRpType() {
		return queryRpType;
	}
	
	public void setQueryRpType(String queryRpType) {
		this.queryRpType = queryRpType;
	}
	public Boolean getCascadeBrch() {
		return cascadeBrch;
	}
	public void setCascadeBrch(Boolean cascadeBrch) {
		this.cascadeBrch = cascadeBrch;
	}
}
