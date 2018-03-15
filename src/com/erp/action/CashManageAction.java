package com.erp.action;

import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

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
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.CashBox;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.CashManageService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.GridModel;
import com.erp.viewModel.Page;

import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JasperRunManager;
import net.sf.jasperreports.engine.data.JRMapCollectionDataSource;

/**
 * @category 现金管理action：查询柜员尾箱、柜员调剂、网点存款、柜员缴现
 * @author yangn
 * @version 1.0
 */
@Namespace("/cashManage")
@Action("cashManageAction")
@Results({@Result(type="json",name="json"),
		  @Result(name="tellerTransfer",location="/jsp/cashmanage/tellertransfer.jsp"),
		  @Result(name="toBranchDeposit",location="/jsp/cashmanage/depositoutlets.jsp")
})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class CashManageAction extends BaseAction {
	private static final long serialVersionUID = 1L;
	@Resource(name="cashManageService")
	private CashManageService cashManageService;
	private GridModel grid = new GridModel();
	private String branchId;//尾箱查询时选择网点
	private String operatorId;//尾箱查询时选择柜员编号
	private String isZero;//查询是否包含0选项
	private String queryType = "1";//查询类型 0 执行查询   1  不执行查询直接返回到页面
	private String sort;//表格排序字段
	private String order;//表格排序 asc  desc
	private String currentBranchId;//当前柜员所属网点ID
	private String currentOperatorId;//当前柜员ID
	private String currentBranchName;//当前柜员所属网点名称
	private String currentOperatorName;//当前柜员名称
	private String td_blc;//当前柜员尾箱今日结余
	private String defaultErrorMsg = "";//页面错误信息
	private String out_blc;//柜员、网点间流转金额
	private String inTellerPwd;//柜员调剂 收方密码
	private String totalAmt;//网点存款 存款金额
	private String bankNo;//网点存款  银行存款凭证号
	private String frzAmt;//尾箱冻结金额
	private String availableAmt;//柜员可操作最大金额
	private SysBranch brch;
	private String beginTime;
	private String endTime;
	private String dealState;
	private Long dealNo;
	private String dealNos;
	private String userId;
	private String coinKind;
	private String inOutFlag;
	private String startDate;
	private String endDate;
	private String operId;
	private String serNos;
	/**
	 * 尾箱查询
	 * @return
	 */
	public String toQueryCashBox(){
		JSONArray array = new JSONArray();
		jsonObject.put("status","0");
		jsonObject.put("total","0");
		try{
			if(Tools.processNull(queryType).equals("0")){
				StringBuffer head = new StringBuffer();
				StringBuffer where = new StringBuffer();
				head.append("select t.brch_id,c.full_name,t.user_id,b.name,decode(t.coin_kind,'1','人民币','其他') coin_kind,t.yd_blc,");
				head.append("t.td_in_num,t.td_in_amt,t.td_out_num,t.td_out_amt,");
				head.append("t.td_blc, t.frz_amt ");
				where.append("from CASH_BOX t, sys_users b, sys_branch c ");
				where.append("where t.brch_id = c.brch_id(+) and t.user_id = b.user_id(+)");
				if(!Tools.processNull(branchId).equals("")){
					where.append(" and t.brch_id = '" + branchId + "'");
				}
				if(!Tools.processNull(operatorId).equals("")){
					where.append(" and t.user_id = '" + operatorId + "'");
				}
				if(Tools.processNull(isZero).equals("0")){
					where.append(" and t.td_blc = 0");
				}
				if(Tools.processNull(isZero).equals("1")){
					where.append(" and t.td_blc > 0");
				}
				//默认排序
				if(!Tools.processNull(this.sort).equals("") && !Tools.processNull(this.order).equals("")){
					where.append(" order by " + this.sort + " " + this.order);
				}else{
					where.append(" order by t.user_id asc");
				}
				//查询分页
				List<?> list = cashManageService.toQueryCashBox(head.append(where).toString(),page,rows);
				//查询总页码
				BigDecimal totalCount = (BigDecimal) cashManageService.findOnlyFieldBySql("select count(1) " + where.toString());
				if(list != null && list.size() > 0){
					jsonObject.put("total",totalCount.intValue());//总页码
					for (Object object : list) {
						Object[] temprow = (Object[]) object;
						JSONObject obj = new JSONObject();
						obj.put("brch_id",temprow[0]);
						obj.put("full_name",temprow[1]);
						obj.put("user_id",temprow[2]);
						obj.put("name",temprow[3]);
						obj.put("coin_kind",temprow[4]);
						obj.put("yd_blc",temprow[5]);
						obj.put("td_in_num",temprow[6]);
						obj.put("td_in_amt",temprow[7]);
						obj.put("td_out_num",temprow[8]);
						obj.put("td_out_amt",temprow[9]);
						obj.put("td_blc",temprow[10]);
						obj.put("frz_bal",temprow[11]);
						array.add(obj);
					}
				}else{
					throw new CommonException("未查询到柜员尾箱信息！");
				}
			}
			jsonObject.put("rows",array);
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 * 到达柜员调剂页面
	 * @return
	 */
	public String toTellerTransferIndex(){
		try{
			this.brch = (SysBranch) cashManageService.findOnlyRowByHql("from SysBranch t where t.brchId = '" + this.getUsers().getBrchId() + "'");
			currentBranchId = this.brch.getBrchId();
			currentBranchName = brch.getFullName();//网点名称
			currentOperatorId = cashManageService.getUser().getUserId();
			currentOperatorName = cashManageService.getUser().getName();//柜员名称
			CashBox box = (CashBox) cashManageService.findOnlyRowByHql("from CashBox t where t.brchId = '" + currentBranchId + "' and t.userId = '" + currentOperatorId + "'");
			if(box == null){
				this.td_blc = "0.00";
				this.totalAmt = "0.00";//尾箱当日结余总金额
				this.frzAmt = "0.00";//尾箱冻结金额
				this.availableAmt = "0.00";//尾箱可用余额
				throw new CommonException("柜员尾箱信息不存在，不能进行网点存款！");
			}
			td_blc = Arith.cardreportsmoneydiv(box.getTdBlc() + "");//今日结余
			frzAmt = Arith.cardreportsmoneydiv(box.getFrzAmt() + "");//冻结金额
			availableAmt = Arith.cardreportsmoneydiv(Arith.sub(box.getTdBlc() + "",box.getFrzAmt() + ""));//可用金额
		}catch(Exception e){
			this.defaultErrorMsg = e.getMessage();
		}
		return "tellerTransfer";
	}
	/**
	 * 保存柜员调剂
	 * @return
	 */
	public String toSaveTellerTransfer(){
		jsonObject.put("status","1");
		jsonObject.put("message","111");
		jsonObject.put("isreload","1");//是否重新加载页面
		try{
			//1.验证收方柜员密码
			String ciphertext = baseService.encrypt_des(inTellerPwd,Constants.APP_DES3_DEFAULT);
			Users inUser = (Users) cashManageService.findOnlyRowByHql("from Users t where t.userId = '" + this.operatorId + "'");
			if(inUser == null){
				throw new CommonException("收方柜员信息不存在，请仔细核对后，再进行调剂！");
			}
			if(inUser.getPassword().trim().equals("")){
				throw new CommonException("收方柜员密码信息不存在，请仔细核对后，再进行调剂！");
			} 
			if(!inUser.getPassword().equals(ciphertext)){
				throw new CommonException("收方柜员密码不正确，请仔细核对后，再进行调剂！");
			}
			//2.重新验证柜员尾箱的今日结余
			BigDecimal td_blc_next = (BigDecimal) cashManageService.findOnlyFieldBySql("SELECT T.TD_BLC FROM CASH_BOX t WHERE T.BRCH_ID = '" + cashManageService.getUser().getBrchId() + "' AND T.USER_ID = '" + cashManageService.getUser().getUserId() + "'");
			if(td_blc_next.subtract(new BigDecimal(Arith.cardmoneymun(out_blc))).intValue() < 0){
				jsonObject.put("isreload","0");
				throw new CommonException("当前柜员尾箱【今日结余】有变动，请刷新页面仔细核对后，再进行调剂！");
			}
			//进入service
			Long dealNo = cashManageService.saveTellerTransfer(cashManageService.getUser(),inUser,Long.valueOf(Arith.cardmoneymun(out_blc)));
			jsonObject.put("dealNo",dealNo);//业务流水
			jsonObject.put("message","调剂成功！调剂金额：" + out_blc);
			jsonObject.put("status","0");//成功返回
			jsonObject.put("isreload","0");//刷新页面
		}catch(Exception e){
			jsonObject.put("message",e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 * 网点存款首页
	 * @return
	 */
	public String toBranchDeposit(){
		try{
			this.brch = (SysBranch) cashManageService.findOnlyRowByHql("from SysBranch t where t.brchId = '" + this.getUsers().getBrchId() + "'");
			currentBranchId = brch.getBrchId();//网点编号
			currentBranchName = brch.getFullName();//网点名称
			currentOperatorId = cashManageService.getUser().getUserId();//柜员编号
			currentOperatorName = cashManageService.getUser().getName();//柜员名称
			CashBox box = (CashBox) cashManageService.findOnlyRowByHql("from CashBox t where t.brchId = '" + currentBranchId + "' and t.userId = '" + currentOperatorId + "'");
			if(box == null){
				this.totalAmt = "0.00";//尾箱当日结余总金额
				this.frzAmt = "0.00";//尾箱冻结金额
				this.availableAmt = "0.00";//尾箱可用余额
				throw new CommonException("柜员尾箱信息不存在，不能进行网点存款！");
			}
			totalAmt = Arith.cardreportsmoneydiv(box.getTdBlc() + "");
			frzAmt = Arith.cardreportsmoneydiv(box.getFrzAmt() + "");
			availableAmt = Arith.cardreportsmoneydiv(Arith.sub(box.getTdBlc() + "",box.getFrzAmt() + ""));
		}catch(Exception e){
			this.defaultErrorMsg = e.getMessage();
		}
		return "toBranchDeposit";
	}
	/**
	 * 网点存款
	 * @return
	 */
	public String certainDeposit(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			Long dealNo = cashManageService.saveCertainDeposit(cashManageService.getUser(),Long.valueOf(Arith.cardmoneymun(totalAmt)),bankNo);
			jsonObject.put("status","0");
			jsonObject.put("msg","网点存款成功！");
			jsonObject.put("dealNo",dealNo);
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 * 网点预存款
	 * @return
	 */
	public String certainDepositPre(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			TrServRec rec = cashManageService.saveCertainDepositPre(cashManageService.getUser(),Long.valueOf(Arith.cardmoneymun(totalAmt)),bankNo);
			jsonObject.put("status","0");
			jsonObject.put("msg","网点存款成功！");
			jsonObject.put("dealNo",rec.getDealNo());
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 * 查询网点存款待确认记录
	 * @return
	 */
	public String certainDepositIndex(){
		try{
			this.initBaseDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer header = new StringBuffer();
			header.append("SELECT t.deal_no,s.deal_code_name,t.brch_id,b.full_name,t.user_id,c.name,to_char(t.biz_time,'yyyy-mm-dd hh24:mi:ss') biztime,t.deal_state,");
			header.append("nvl(t.amt, 0) amt,decode(t.deal_state,'0','已确认','9','待确认','未知')  dealstate,t.Rsv_One ");
			StringBuffer sb = new StringBuffer();
			sb.append("FROM tr_serv_rec t,Sys_Code_Tr s,sys_branch b,sys_users c WHERE t.brch_id = b.brch_id and t.user_id = c.user_id and t.deal_code = s.deal_code(+) AND  t.deal_code = '" + DealCode.BRANCH_DEPOSIT + "' ");
			String tempLimitSql = "";
			if(!Tools.processNull(branchId).equals("")){
				tempLimitSql = " and t.brch_id in (select q.brch_id from sys_branch q start with q.brch_id = '" + branchId + "' connect by prior q.sysbranch_id  =  q.pid) ";
				if(!Tools.processNull(operatorId).equals("") && !Tools.processNull(operatorId).equals("erp2_erp2")){
					tempLimitSql += " and t.user_Id = '"  + Tools.processNull(operatorId) + "' ";
				}
			}
			if(!Tools.processNull(beginTime).equals("")){
				sb.append("and t.clr_date >= '" + this.beginTime + "' ");
			}
			if(!Tools.processNull(endTime).equals("")){
				sb.append("and t.clr_date <= '" + this.endTime + "' ");
			}
			/*if(!Tools.processNull(branchId).equals("")){
				sb.append("and t.brch_id = '" + this.branchId + "' ");
			}
			if(!Tools.processNull(this.operatorId).equals("")){
				sb.append("and t.user_id = '" + this.operatorId + "' ");
			}*/
			if(!Tools.processNull(tempLimitSql).equals("")){
				sb.append(tempLimitSql);
			}
			if(!Tools.processNull(this.dealState).equals("")){
				sb.append("and t.deal_state = '" + this.dealState + "' ");
			}
			if(!Tools.processNull(this.dealNo).equals("")){
				sb.append("and t.deal_no = '" + this.dealNo + "' ");
			}
			if(Tools.processNull(sort).equals("")){
				sb.append("order by t.deal_no desc ");
			}else{
				sb.append("order by " + this.sort + " " + order);
			}
			Page list = cashManageService.pagingQuery(header.append(sb).toString(),page,rows);
			if(list.getAllRs() == null || list.getAllRs().size() <= 0){
				throw new CommonException("根据条件未找到网点存款信息！");
			}else{
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
	 * 网点预存款确认
	 * @return
	 */
	public String certainDepositConfirm(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			if(Tools.processNull(dealNos).equals("")){
				throw new CommonException("确认流水为空");
			}
			
			String[] dealNoArr = dealNos.split(",");
			JSONArray failList = new JSONArray();
			for (String dealNo : dealNoArr) {
				try {
					cashManageService.saveCertainDepositConfirm(cashManageService.getUser(), Long.valueOf(dealNo));
				} catch (Exception e) {
					JSONObject failItem = new JSONObject();
					failItem.put("dealNo", dealNo);
					failItem.put("msg", e.getMessage());
					failList.add(failItem);
					continue;
				}
			}
			
			jsonObject.put("status","0");
			jsonObject.put("msg","网点存款确认成功！");
			jsonObject.put("failList", failList);
			jsonObject.put("dealNo",dealNo);
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
		}
		return "jsonObj";
	}
	
	public String queryCashBoxRec(){
		try {
			jsonObject.put("rows", new JSONArray());// 记录行数
			jsonObject.put("total", 0);// 总条数
			jsonObject.put("status", 0);// 查询状态
			jsonObject.put("errMsg", "");// 错误信息
			
			if(Tools.processNull(userId).equals("")){
				throw new CommonException("柜员编号为空.");
			}
			String cashSerNoSql = "";
			if(!Tools.processNull(serNos).equals("")){
				String[] cashSerNoArr = serNos.split(",");
				if (cashSerNoArr != null && cashSerNoArr.length > 0) {
					for (String cashSerNo : cashSerNoArr) {
						cashSerNoSql += "'" + cashSerNo + "',";
					}
					cashSerNoSql = cashSerNoSql.substring(0, cashSerNoSql.length() - 1);
				}
			}
			String sql = "select t.cash_ser_no, t.user_id, u.name, t.org_id, t.brch_id, b.full_name, t.summary, t.amt, "
					+ "(select code_name from sys_code where code_type = 'COIN_TYPE' and code_value = t.coin_kind) coin_kind, "
					+ "to_char(t.in_out_date, 'yyyy-mm-dd hh24:mi:ss') in_out_date, "
					+ "t.in_out_flag, t.cs_bal, t.deal_code, c.deal_code_name, t.deal_no, "
					+ "t.clr_date, t.other_org_id, t.other_brch_id, t.other_user_id ";
			
			String where = "from cash_box_rec t join sys_users u on t.user_id=u.user_id "
					+ "left join sys_branch b on t.brch_id = b.brch_id join sys_code_tr c on t.deal_code = c.deal_code "
					+ "where t.user_id = '" + userId + "' ";
			
			if(!Tools.processNull(coinKind).equals("")){
				where += "and t.coin_kind = '" + coinKind + "' ";
			}
			if(!Tools.processNull(inOutFlag).equals("")){
				where += "and t.in_out_flag = '" + inOutFlag + "' ";
			}
			if(!Tools.processNull(beginTime).equals("")){
				where += "and t.in_out_date >= to_date('" + beginTime + "', 'yyyy-mm-dd') ";
			}
			if(!Tools.processNull(endTime).equals("")){
				where += "and t.in_out_date <= to_date('" + endTime + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			if(!Tools.processNull(cashSerNoSql).equals("")){
				where += "and t.cash_ser_no in (" + cashSerNoSql + ") ";
			}
			if(!Tools.processNull(sort).equals("")){
				where += "order by " + sort;
				
				if(!Tools.processNull(order).equals("")){
					where += " " + order;
				}
			} else {
				where += "order by in_out_date desc, t.cash_ser_no desc";
			}
			
			Page pageData = cashManageService.pagingQuery(sql + where, page, rows);
			
			if (pageData == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommonException("没有数据.");
			}

			jsonObject.put("rows", pageData.getAllRs());
			jsonObject.put("total", pageData.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		
		return JSONOBJ;
	}
	
	public String exportCashBoxRec() {
		try {
			queryCashBoxRec();
			String userName = (String) cashManageService.findOnlyFieldBySql("select name from sys_users where user_id = '" + userId + "'");
			String fileName = userName + "尾箱流水";
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
			sheet.setColumnWidth(4, 3000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 3000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 3000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 3000);
			sheet.setColumnWidth(11, 6000);
			sheet.setColumnWidth(12, 3000);
			sheet.setColumnWidth(13, 10000);

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
			sheet.getRow(1).getCell(0).setCellValue("业务时间：" + data.getJSONObject(data.size() - 1).getString("IN_OUT_DATE") + " ~ " + data.getJSONObject(0).getString("IN_OUT_DATE") + "    导出时间：" + DateUtils.getNowTime());

			// third header
			sheet.getRow(2).getCell(0).setCellValue("流水号");
			sheet.getRow(2).getCell(1).setCellValue("网点编号");
			sheet.getRow(2).getCell(2).setCellValue("网点名称");
			sheet.getRow(2).getCell(3).setCellValue("柜员编号");
			sheet.getRow(2).getCell(4).setCellValue("柜员名称");
			sheet.getRow(2).getCell(5).setCellValue("币种");
			sheet.getRow(2).getCell(6).setCellValue("收付标志");
			sheet.getRow(2).getCell(7).setCellValue("金额");
			sheet.getRow(2).getCell(8).setCellValue("现金结存");
			sheet.getRow(2).getCell(9).setCellValue("交易名称");
			sheet.getRow(2).getCell(10).setCellValue("业务流水");
			sheet.getRow(2).getCell(11).setCellValue("发生日期");
			sheet.getRow(2).getCell(12).setCellValue("清分日期");
			sheet.getRow(2).getCell(13).setCellValue("备注");//

			//
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(5, 3);
			int num = 0;
			double sAmtSum = 0;
			double fAmtSum = 0;
			for (int i = 0; i < data.size(); i++, num++) {
				JSONObject item = data.getJSONObject(i);

				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j == 7 || j == 8) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}

				row.getCell(0).setCellValue(item.getString("CASH_SER_NO"));
				row.getCell(1).setCellValue(item.getString("BRCH_ID"));
				row.getCell(2).setCellValue(item.getString("FULL_NAME"));
				row.getCell(3).setCellValue(item.getString("USER_ID"));
				row.getCell(4).setCellValue(item.getString("NAME"));
				row.getCell(5).setCellValue(item.getString("COIN_KIND"));
				row.getCell(6).setCellValue("1".equals(item.getString("IN_OUT_FLAG"))?"收":"付");
				row.getCell(7).setCellValue(item.getDoubleValue("AMT") / 100);
				row.getCell(8).setCellValue(item.getDoubleValue("CS_BAL") / 100);
				row.getCell(9).setCellValue(item.getString("DEAL_CODE_NAME"));
				row.getCell(10).setCellValue(item.getString("DEAL_NO"));
				row.getCell(11).setCellValue(item.getString("IN_OUT_DATE"));
				row.getCell(12).setCellValue(item.getString("CLR_DATE"));
				row.getCell(13).setCellValue(item.getString("SUMMARY"));

				if("1".equals(item.getString("IN_OUT_FLAG"))){
					sAmtSum += item.getDoubleValue("AMT");
				} else {
					fAmtSum += item.getDoubleValue("AMT");
				}
			}

			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if (j == 8 || j == 9) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(1).setCellValue("统计：");
			row.getCell(2).setCellValue("共 " + num + " 条记录");
			row.getCell(7).setCellValue("收：" + Arith.insertComma(sAmtSum / 100 + "", 2)  + " 付：" + Arith.insertComma(fAmtSum / 100 + "", 2));
			sheet.addMergedRegion(new CellRangeAddress(data.size() + headRows, data.size() + headRows, 7, 8));
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
	
	@SuppressWarnings("unchecked")
	public String queryCashBoxDetail() {
		try {
			String userId = getUsers().getUserId();
			
			// 当前柜员 充值，补换
			String startNo = (String) cashManageService.findOnlyFieldBySql("select to_char(max(cash_ser_no)) from cash_box_rec where user_id = '" 
					+ userId + "' and deal_code in ('" + DealCode.TELLER_SWAP + "', '" + DealCode.BRANCH_DEPOSIT_CONFIRM + "') and in_out_flag = '" 
					+ Constants.IN_OUT_FLAG_FC + "'");
			if (startNo == null) {
				startNo = (String) cashManageService.findOnlyFieldBySql("select to_char(min(cash_ser_no)) from cash_box_rec where user_id = '" + userId + "'");
			}
			String endNo = (String) cashManageService.findOnlyFieldBySql("select to_char(nvl(max(cash_ser_no), 0)) from cash_box_rec where user_id = '" 
					+ userId + "'");
			
			List<BigDecimal> curOperCash = getOperCashDetailBetween(userId, Long.valueOf(startNo), Long.valueOf(endNo));
			JSONObject curOperCashInfo = new JSONObject();
			curOperCashInfo.put("userId", userId);
			curOperCashInfo.put("name", getUsers().getName());
			curOperCashInfo.put("rcAmt", curOperCash.get(0));
			curOperCashInfo.put("bkAmt", curOperCash.get(1));
			curOperCashInfo.put("hkAmt", curOperCash.get(2));
			curOperCashInfo.put("tlAmt", curOperCash.get(0).add(curOperCash.get(1)).add(curOperCash.get(2)));
			
			// 上次 存款/调剂 剩余
			JSONObject curOperTotal = new JSONObject();
			BigDecimal surplus = (BigDecimal) cashManageService.findOnlyFieldBySql("select nvl(cs_bal, 0) from cash_box_rec where cash_ser_no = '" + startNo + "'");
			curOperTotal.put("surplus", surplus);
			curOperTotal.put("userId", userId);
			curOperTotal.put("name", getUsers().getName());
			
			// 当前余额
			BigDecimal curBal = (BigDecimal) cashManageService.findOnlyFieldBySql("select nvl(td_blc, 0) from cash_box where user_id = '" + userId + "'");
			curOperTotal.put("tlAmt", curBal);
			
			// 其他柜员调剂
			String sql2 = "select cash_ser_no, amt, other_user_id, to_char(deal_no) from cash_box_rec where user_id = '" 
					+ userId + "' and deal_code = '" + DealCode.TELLER_SWAP + "' and in_out_flag = '" + Constants.IN_OUT_FLAG_SR 
					+ "' and cash_ser_no >= " + startNo + " and cash_ser_no <= " + endNo;
			
			List<Object[]> otherOperCashs = cashManageService.findBySql(sql2);
			
			JSONArray array = new JSONArray();
			
			if (otherOperCashs != null && !otherOperCashs.isEmpty()) {
				for (Object[] otherOper : otherOperCashs) {
					JSONObject otherOperCashInfo = new JSONObject();
					
					String userId2 = otherOper[2].toString();
					String name2 = (String) cashManageService.findOnlyFieldBySql("select name from sys_users where user_id = '" + userId2 + "'");
					String endNo2 = (String) cashManageService.findOnlyFieldBySql("select to_char(cash_ser_no) from cash_box_rec where user_id = '" 
							+ userId2 + "' and deal_no = '" + otherOper[3] + "'");
					String startNo2 = (String) cashManageService.findOnlyFieldBySql("select to_char(max(cash_ser_no)) from cash_box_rec where user_id = '" 
							+ userId2 + "' and deal_code in ('" + DealCode.TELLER_SWAP + "', '" + DealCode.BRANCH_DEPOSIT_CONFIRM + "') and in_out_flag = '" 
							+ Constants.IN_OUT_FLAG_FC + "' and cash_ser_no < " + endNo2);
					if (startNo2 == null) {
						startNo2 = (String) cashManageService.findOnlyFieldBySql("select to_char(min(cash_ser_no)) from cash_box_rec where user_id = '" + userId2 + "'");
					}
					
					List<BigDecimal> otherOperCash = getOperCashDetailBetween(userId2, Long.valueOf(startNo2), Long.valueOf(endNo2));
					
					otherOperCashInfo.put("userId", userId2);
					otherOperCashInfo.put("name", name2);
					otherOperCashInfo.put("rcAmt", otherOperCash.get(0));
					otherOperCashInfo.put("bkAmt", otherOperCash.get(1));
					otherOperCashInfo.put("hkAmt", otherOperCash.get(2));
					otherOperCashInfo.put("tlAmt", otherOper[1]);
					
					if(array.isEmpty()){
						array.add(otherOperCashInfo);
						continue;
					}
					
					boolean contain = false;
					for (int i = 0;i<array.size();i++) {
						JSONObject operCash = (JSONObject) array.get(i);
						if (operCash.getString("userId").equals(userId2)) {
							operCash.put("rcAmt", ((BigDecimal)operCash.get("rcAmt")).add((BigDecimal)otherOperCashInfo.get("rcAmt")));
							operCash.put("bkAmt", ((BigDecimal)operCash.get("bkAmt")).add((BigDecimal)otherOperCashInfo.get("bkAmt")));
							operCash.put("hkAmt", ((BigDecimal)operCash.get("hkAmt")).add((BigDecimal)otherOperCashInfo.get("hkAmt")));
							operCash.put("tlAmt", ((BigDecimal)operCash.get("tlAmt")).add((BigDecimal)otherOperCashInfo.get("tlAmt")));
							contain = true;
							break;
						}
					}
					
					if(!contain){
						array.add(otherOperCashInfo);
					}
				}
			}
			
			jsonObject.put("status", 0);
			jsonObject.put("curOper", curOperCashInfo);
			jsonObject.put("otherOper", array);
			jsonObject.put("curOperTotal", curOperTotal);
		} catch (Exception e) {
			jsonObject.put("status", 0);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	private List<BigDecimal> getOperCashDetailBetween(String userId, Long startNo, Long endNo){
		try {
			List<BigDecimal> amt = new ArrayList<BigDecimal>();
			
			BigDecimal rcAmt = BigDecimal.valueOf(0);// 充值金额
			BigDecimal bkAmt = BigDecimal.valueOf(0);// 补卡金额
			BigDecimal hkAmt = BigDecimal.valueOf(0);// 换卡金额
			
			// 1. (当前柜员)充值/补卡/换卡
			String sql = "select nvl(sum(decode(deal_code, '" + DealCode.RECHARGE_CASH_WALLET + "', amt, '"
					+ DealCode.RECHARGE_CASH_WALLET_REV + "', amt, '" + DealCode.RECHARGE_CASH_ACC 
					+ "', amt, '" + DealCode.RECHARGE_CASH_ACC_REV + "', amt, 0)), 0) cz, nvl(sum(decode(deal_code, '"
					+ DealCode.NAMEDCARD_REISSUE + "', amt, '" + DealCode.NAMEDCARD_REISSUE_UNDO
					+ "', amt, 0)), 0) bk, nvl(sum(decode(deal_code, '" + DealCode.NAMEDCARD_CHG + "', amt, '"
					+ DealCode.NAMEDCARD_CHG_UNDO + "', amt, '" + DealCode.NONAMEDCARD_CHG
					+ "', amt, 0)), 0) hk from cash_box_rec where user_id = '" + userId + "' and cash_ser_no >= " 
					+ startNo + " and cash_ser_no <= " + endNo;
			
			Object[] curOper = (Object[]) cashManageService.findOnlyRowBySql(sql);
			
			rcAmt = rcAmt.add((BigDecimal) curOper[0]);
			bkAmt = bkAmt.add((BigDecimal) curOper[1]);
			hkAmt = hkAmt.add((BigDecimal) curOper[2]);
			
			// 2. 其他柜员(调剂)
/*			String sql2 = "select cash_ser_no, amt, other_user_id, to_char(deal_no) from cash_box_rec where user_id = '" 
					+ userId + "' and deal_code = '" + DealCode.TELLER_SWAP + "' and in_out_flag = '" + Constants.IN_OUT_FLAG_SR 
					+ "' and cash_ser_no > " + startNo + " and cash_ser_no <= " + endNo;
			
			List<Object[]> otherOperSer = cashManageService.findBySql(sql2);
			
			if (otherOperSer != null && !otherOperSer.isEmpty()) {
				for (Object[] otherOper : otherOperSer) {
					String userId2 = otherOper[2].toString();
					String endNo2 = (String) cashManageService.findOnlyFieldBySql("select to_char(cash_ser_no) from cash_box_rec where user_id = '" 
							+ userId2 + "' and deal_no = '" + otherOper[3] + "'");
					String startNo2 = (String) cashManageService.findOnlyFieldBySql("select to_char(nvl(max(cash_ser_no), 0)) from cash_box_rec where user_id = '" 
							+ userId2 + "' and deal_code in ('" + DealCode.TELLER_SWAP + "', '" + DealCode.BRANCH_DEPOSIT_CONFIRM + "') and in_out_flag = '" 
							+ Constants.IN_OUT_FLAG_FC + "' and cash_ser_no <= " + endNo2);
					
					List<BigDecimal> otherOperCash = getOperCashDetailBetween(userId2, Long.valueOf(startNo2), Long.valueOf(endNo2));
					
					rcAmt.add(otherOperCash.get(0));
					bkAmt.add(otherOperCash.get(1));
					hkAmt.add(otherOperCash.get(2));
				}
			}*/
			
			// end
			amt.add(rcAmt);
			amt.add(bkAmt);
			amt.add(hkAmt);
			
			return amt;
		} catch (Exception e) {
			throw new CommonException("计算柜员[" + userId + "]尾箱明细在[" + startNo + ", " + endNo + "]之间发生错误", e);
		}
	}
	
	@SuppressWarnings({ "rawtypes", "unchecked", "deprecation" })
	public String printCashBoxDetail() {
		try {
			queryCashBoxDetail();
			SysActionLog log = cashManageService.getCurrentActionLog();
			log.setDealCode(DealCode.OPER_CASH_BOX_DETAIL_PRINT);
			log.setMessage("柜员现金尾箱明细凭证打印.");
			cashManageService.saveLog(log);
			
			// 当前柜员 - 总
			JSONObject curOperTotal = jsonObject.getJSONObject("curOperTotal");
			
			BigDecimal rcAmtTl = BigDecimal.valueOf(0);
			BigDecimal bhkAmtTl = BigDecimal.valueOf(0);
			
			
			Map<String, Object> reprortParam = new HashMap<String, Object>();
			reprortParam.put("title", "柜员 " + curOperTotal.getString("name") + " " + DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd") + " 尾箱明细");
			reprortParam.put("curUserId", curOperTotal.getString("userId"));
			reprortParam.put("curUserName", curOperTotal.getString("name"));
			reprortParam.put("curTlAmt", String.format("%,.2f", ((BigDecimal)curOperTotal.get("tlAmt")).divide(BigDecimal.valueOf(100))));
			
			// oper
			List allOperInfo= new ArrayList<Map<String, Object>>();
			
			Map<String, Object> curOper = jsonObject.getJSONObject("curOper");
			BigDecimal rcAmt = (BigDecimal) curOper.get("rcAmt");
			BigDecimal bkAmt = (BigDecimal) curOper.get("bkAmt");
			BigDecimal hkAmt = (BigDecimal) curOper.get("hkAmt");
			BigDecimal tlAmt = (BigDecimal) curOper.get("tlAmt");
			
			rcAmtTl = rcAmtTl.add(rcAmt);
			bhkAmtTl = bhkAmtTl.add(bkAmt.add(hkAmt));
			
			curOper.put("userName", curOper.get("name"));
			curOper.put("rcAmt", String.format("%,.2f", rcAmt.divide(BigDecimal.valueOf(100))));
			curOper.put("bhkAmt", String.format("%,.2f", bkAmt.add(hkAmt).divide(BigDecimal.valueOf(100))));
			curOper.put("tlAmt", String.format("%,.2f", tlAmt.divide(BigDecimal.valueOf(100))));
			
			allOperInfo.add(curOper);

			// other oper
			JSONArray otherOpers = jsonObject.getJSONArray("otherOper");
			if (otherOpers != null && !otherOpers.isEmpty()) {
				for (int i = 0; i < otherOpers.size(); i++) {
					Map<String, Object> otherOper = (Map<String, Object>) otherOpers.get(i);

					BigDecimal rcAmt2 = (BigDecimal) otherOper.get("rcAmt");
					BigDecimal bkAmt2 = (BigDecimal) otherOper.get("bkAmt");
					BigDecimal hkAmt2 = (BigDecimal) otherOper.get("hkAmt");
					BigDecimal tlAmt2 = (BigDecimal) otherOper.get("tlAmt");
					
					rcAmtTl = rcAmtTl.add(rcAmt2);
					bhkAmtTl = bhkAmtTl.add(bkAmt2.add(hkAmt2));
					
					otherOper.put("userName", otherOper.get("name"));
					otherOper.put("rcAmt", String.format("%,.2f", rcAmt2.divide(BigDecimal.valueOf(100))));
					otherOper.put("bhkAmt", String.format("%,.2f", bkAmt2.add(hkAmt2).divide(BigDecimal.valueOf(100))));
					otherOper.put("tlAmt", String.format("%,.2f", tlAmt2.divide(BigDecimal.valueOf(100))));
					
					allOperInfo.add(otherOper);
				}
			}
			
			reprortParam.put("curRcAmt", String.format("%,.2f", rcAmtTl.divide(BigDecimal.valueOf(100))));
			reprortParam.put("curBhkAmt", String.format("%,.2f", bhkAmtTl.divide(BigDecimal.valueOf(100))));
			
			JRDataSource source = new JRMapCollectionDataSource(allOperInfo);
			String path = ServletActionContext.getRequest().getRealPath("/reportfiles/UserCashBoxDetail.jasper");
			byte[] pdfContent = JasperRunManager.runReportToPdf(path, reprortParam,source);
			cashManageService.saveSysReport(log, new JSONObject(), "", Constants.APP_REPORT_TYPE_PDF2, 1l, "", pdfContent );
			jsonObject.put("dealNo", log.getDealNo());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		
		return JSONOBJ;
	}
	
	public String getTellerTransferInfo() {
		try {
			initBaseDataGrid();
			String sql = "select cash_ser_no, user_id, (select name from sys_users where user_id = t.user_id) user_name, "
					+ "abs(amt) total_amt, other_user_id oper_id, (select name from sys_users where user_id = t.other_user_id) oper_name, "
					+ "to_char(in_out_date, 'yyyy-mm-dd') transfer_date, to_char(in_out_date, 'hh24:mi:ss') transfer_time "
					+ "from cash_box_rec t where deal_code = '" + DealCode.TELLER_SWAP + "' and in_out_flag = '" + Constants.IN_OUT_FLAG_FC + "' ";
			if (!Tools.processNull(serNos).equals("")) {
				sql += "and t.cash_ser_no in (" + serNos + ") ";
			}
			if (!Tools.processNull(branchId).equals("")) {
				sql += "and t.brch_id = '" + branchId + "' ";
			}
			if (!Tools.processNull(userId).equals("")) {
				sql += "and t.user_id = '" + userId + "' ";
			}
			if (!Tools.processNull(operId).equals("")) {
				sql += "and t.other_user_id = '" + operId + "' ";
			}
			if (!Tools.processNull(startDate).equals("")) {
				sql += "and t.clr_date >= '" + startDate + "' ";
			}
			if (!Tools.processNull(endDate).equals("")) {
				sql += "and t.clr_date <= '" + endDate + "' ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort;
				
				if(!Tools.processNull(order).equals("")){
					sql += " " + order;
				}
			} else {
				sql += "order by t.in_out_date desc";
			}
			
			Page data = cashManageService.pagingQuery(sql, page, rows);
			if (data == null || data.getAllRs() == null || data.getAllRs().isEmpty()) {
				throw new CommonException("没有数据！");
			}
			
			JSONArray rows = data.getAllRs();
			for(Object obj : rows){
				JSONObject row = (JSONObject) obj;
				
				String userId = row.getString("USER_ID");
				String endNo = row.getString("CASH_SER_NO");
				String startNo = (String) cashManageService.findOnlyFieldBySql("select to_char(max(cash_ser_no)) "
						+ "from cash_box_rec where user_id = '" + userId + "' and cash_ser_no < '" + endNo 
						+ "' and deal_code = '" + DealCode.TELLER_SWAP + "' and in_out_flag = '" + Constants.IN_OUT_FLAG_FC + "'");
				
				if(startNo == null){
					startNo = (String) cashManageService.findOnlyFieldBySql("select to_char(min(cash_ser_no)) "
							+ "from cash_box_rec where user_id = '" + userId + "'");
				}
				
				List<BigDecimal> amts = getOperCashDetailBetween(userId, Long.valueOf(startNo), Long.valueOf(endNo));
				
				row.put("RECHARGE_AMT", amts.get(0));
				row.put("BHK_AMT", amts.get(1).add(amts.get(2)));
			}
			
			// 如果是主管
			Users user = getUsers();
			if (user.getDutyId() >= 1) {
				BigDecimal rcAmt = BigDecimal.ZERO;
				BigDecimal bhkAmt = BigDecimal.ZERO;
				BigDecimal tlAmt = BigDecimal.ZERO;
				
				// 自己充值，补换
				String sql2 = "select min(cash_ser_no), max(cash_ser_no) from cash_box_rec t where 1 = 1 ";
				if (!Tools.processNull(startDate).equals("")) {
					sql2 += "and t.clr_date >= '" + startDate + "' ";
				}
				if (!Tools.processNull(endDate).equals("")) {
					sql2 += "and t.clr_date <= '" + endDate + "' ";
				}
				Object[] serNo = (Object[]) cashManageService.findOnlyRowBySql(sql2);
				String startNo = serNo[0].toString();
				String endNo = serNo[1].toString();
				
				List<BigDecimal> curOperCash = getOperCashDetailBetween(user.getUserId(), Long.valueOf(startNo), Long.valueOf(endNo));
				JSONObject curOperCashInfo = new JSONObject();
				rcAmt = rcAmt.add(curOperCash.get(0));
				bhkAmt = bhkAmt.add(curOperCash.get(1).add(curOperCash.get(2)));
				tlAmt = tlAmt.add(rcAmt).add(bhkAmt);
				
				curOperCashInfo.put("isFooter", true);
				curOperCashInfo.put("OPER_NAME", user.getName());
				curOperCashInfo.put("RECHARGE_AMT", rcAmt);
				curOperCashInfo.put("BHK_AMT", bhkAmt);
				curOperCashInfo.put("TOTAL_AMT", tlAmt);
				
				JSONArray footer = new JSONArray();
				footer.add(curOperCashInfo);
				jsonObject.put("footer", footer);
			}
			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
			jsonObject.put("status", "0");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	@SuppressWarnings({ "rawtypes", "unchecked", "deprecation" })
	public String printTellerTransferDetail() {
		try {
			if (Tools.processNull(serNos).equals("")) {
				throw new CommonException("没有记录");
			}
			
			String sql = "select cash_ser_no, user_id, (select name from sys_users where user_id = t.user_id) \"userName\", "
					+ "abs(amt) \"tlAmt\", other_user_id oper_id, (select name from sys_users where user_id = t.other_user_id) \"operName\", "
					+ "to_char(in_out_date, 'yyyy-mm-dd') \"transferDate\", to_char(in_out_date, 'hh24:mi:ss') \"transferTime\" ";
			
			String whereSql = "from cash_box_rec t where cash_ser_no in (" + serNos + ") ";
			if(!Tools.processNull(sort).equals("")){
				whereSql += "order by " + sort;
				
				if(!Tools.processNull(order).equals("")){
					whereSql += " " + order;
				}
			} else {
				whereSql += "order by t.in_out_date desc";
			}
			
			Page list = cashManageService.pagingQuery(sql + whereSql, 0, 1000);
			if (list == null || list.getAllRs() == null || list.getAllRs().isEmpty()) {
				throw new CommonException("没有数据！");
			}
			
			JSONArray rows = list.getAllRs();
			BigDecimal sumRcAmt = BigDecimal.ZERO;
			BigDecimal sumBhkAmt = BigDecimal.ZERO;
			BigDecimal sumTlAmt = BigDecimal.ZERO;
			for(Object obj : rows){
				JSONObject row = (JSONObject) obj;
				BigDecimal tlAmt = row.getBigDecimal("tlAmt");
				
				String userId = row.getString("USER_ID");
				String endNo = row.getString("CASH_SER_NO");
				String startNo = (String) cashManageService.findOnlyFieldBySql("select to_char(max(cash_ser_no)) "
						+ "from cash_box_rec where user_id = '" + userId + "' and cash_ser_no < '" + endNo 
						+ "' and deal_code = '" + DealCode.TELLER_SWAP + "' and in_out_flag = '" + Constants.IN_OUT_FLAG_FC + "'");
				
				if(startNo == null){
					startNo = (String) cashManageService.findOnlyFieldBySql("select to_char(min(cash_ser_no)) "
							+ "from cash_box_rec where user_id = '" + userId + "'");
				}
				
				List<BigDecimal> amts = getOperCashDetailBetween(userId, Long.valueOf(startNo), Long.valueOf(endNo));
				
				sumRcAmt = sumRcAmt.add(amts.get(0));
				sumBhkAmt = sumBhkAmt.add(amts.get(1).add(amts.get(2)));
				sumTlAmt = sumTlAmt.add(tlAmt);
				
				row.put("rcAmt", Arith.insertComma(amts.get(0).divide(BigDecimal.valueOf(100)).toString(), 2));
				row.put("bhkAmt", Arith.insertComma(amts.get(1).add(amts.get(2)).divide(BigDecimal.valueOf(100)).toString(), 2));
				row.put("tlAmt", Arith.insertComma(tlAmt.divide(BigDecimal.valueOf(100)).toString(), 2));
			}
			
			SysActionLog log = cashManageService.getCurrentActionLog();
			log.setDealCode(DealCode.OPER_TRANSFER_DETAIL_PRINT);
			log.setMessage("柜员调剂明细打印");
			cashManageService.saveLog(log);
			
			Map<String, Object> reprortParam = new HashMap<String, Object>();
			reprortParam.put("title", "柜员调剂详细信息");
			reprortParam.put("printTime", DateUtil.formatDate(log.getDealTime()));
			reprortParam.put("curTlAmt", Arith.insertComma(sumTlAmt.divide(BigDecimal.valueOf(100)).toString(), 2));
			reprortParam.put("curRcAmt", Arith.insertComma(sumRcAmt.divide(BigDecimal.valueOf(100)).toString(), 2));
			reprortParam.put("curBhkAmt", Arith.insertComma(sumBhkAmt.divide(BigDecimal.valueOf(100)).toString(), 2));
			
			Users user = getUsers();
			if (user.getDutyId() >= 1) {
				reprortParam.put("isOper", true);
				BigDecimal rcAmt = BigDecimal.ZERO;
				BigDecimal bhkAmt = BigDecimal.ZERO;
				BigDecimal tlAmt = BigDecimal.ZERO;
				
				// 自己充值，补换
				String sql2 = "select min(cash_ser_no), max(cash_ser_no) from cash_box_rec t where 1 = 1 ";
				if (!Tools.processNull(startDate).equals("")) {
					sql2 += "and t.clr_date >= '" + startDate + "' ";
				}
				if (!Tools.processNull(endDate).equals("")) {
					sql2 += "and t.clr_date <= '" + endDate + "' ";
				}
				Object[] serNo = (Object[]) cashManageService.findOnlyRowBySql(sql2);
				String startNo = serNo[0].toString();
				String endNo = serNo[1].toString();
				
				List<BigDecimal> curOperCash = getOperCashDetailBetween(user.getUserId(), Long.valueOf(startNo), Long.valueOf(endNo));
				rcAmt = rcAmt.add(curOperCash.get(0));
				bhkAmt = bhkAmt.add(curOperCash.get(1).add(curOperCash.get(2)));
				tlAmt = tlAmt.add(rcAmt).add(bhkAmt);
				
				reprortParam.put("operName", "主管（" + user.getName() + "）");
				reprortParam.put("operRcAmt", Arith.insertComma(rcAmt.divide(BigDecimal.valueOf(100)).toString(), 2));
				reprortParam.put("operBhkAmt", Arith.insertComma(bhkAmt.divide(BigDecimal.valueOf(100)).toString(), 2));
				reprortParam.put("operTlAmt", Arith.insertComma(tlAmt.divide(BigDecimal.valueOf(100)).toString(), 2));
				//sum
				reprortParam.put("sumRcAmt", Arith.insertComma(rcAmt.add(sumRcAmt).divide(BigDecimal.valueOf(100)).toString(), 2));
				reprortParam.put("sumBhkAmt", Arith.insertComma(bhkAmt.add(sumBhkAmt).divide(BigDecimal.valueOf(100)).toString(), 2));
				reprortParam.put("sumTlAmt", Arith.insertComma(tlAmt.add(sumTlAmt).divide(BigDecimal.valueOf(100)).toString(), 2));
			} else {
				reprortParam.put("operName", "");
				reprortParam.put("operRcAmt", "");
				reprortParam.put("operBhkAmt", "");
				reprortParam.put("operTlAmt", "");
			}
			
			JRDataSource source = new JRMapCollectionDataSource((List)rows);
			String path = ServletActionContext.getRequest().getRealPath("/reportfiles/tellerTransferDetail.jasper");
			byte[] pdfContent = JasperRunManager.runReportToPdf(path, reprortParam,source);
			cashManageService.saveSysReport(log, new JSONObject(), "", Constants.APP_REPORT_TYPE_PDF2, 1l, "", pdfContent );
			
			jsonObject.put("dealNo", log.getDealNo());
			jsonObject.put("status", "0");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportTellerTransferDetail() {
		try {
			getTellerTransferInfo();
			String fileName = "柜员调剂统计";
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			com.alibaba.fastjson.JSONArray operData = (com.alibaba.fastjson.JSONArray) jsonObject.get("footer");

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
			int maxColumn = 7;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}

			sheet.getRow(0).getCell(0).setCellValue(fileName);
			sheet.getRow(1).getCell(0).setCellValue("调剂时间：" + data.getJSONObject(data.size() - 1).getString("TRANSFER_DATE") + " ~ " + data.getJSONObject(0).getString("TRANSFER_DATE")  + "    导出时间：" + DateUtils.getNowTime());

			// second header
			sheet.getRow(2).getCell(0).setCellValue("调剂日期");
			sheet.getRow(2).getCell(1).setCellValue("调剂时间");
			sheet.getRow(2).getCell(2).setCellValue("柜员姓名");
			sheet.getRow(2).getCell(3).setCellValue("主管姓名");
			sheet.getRow(2).getCell(4).setCellValue("充值金额");
			sheet.getRow(2).getCell(5).setCellValue("补换卡金额");
			sheet.getRow(2).getCell(6).setCellValue("总计");

			//
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			int numSum = 0;
			double rAmtSum = 0;
			double bhkAmtSum = 0;
			double totAmtSum = 0;
			for (int i = 0; i < data.size(); i++, numSum++) {
				JSONObject item = data.getJSONObject(i);

				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j > 3) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}

				row.getCell(0).setCellValue(item.getString("TRANSFER_DATE"));
				row.getCell(1).setCellValue(item.getString("TRANSFER_TIME"));
				row.getCell(2).setCellValue(item.getString("USER_NAME"));
				row.getCell(3).setCellValue(item.getString("OPER_NAME"));
				row.getCell(4).setCellValue(item.getDoubleValue("RECHARGE_AMT") / 100);
				row.getCell(5).setCellValue(item.getDoubleValue("BHK_AMT") / 100);
				row.getCell(6).setCellValue(item.getDoubleValue("TOTAL_AMT") / 100);

				rAmtSum += item.getDoubleValue("RECHARGE_AMT");
				bhkAmtSum += item.getDoubleValue("BHK_AMT");
				totAmtSum += item.getDoubleValue("TOTAL_AMT");
			}
			// oper
			if(operData != null && !operData.isEmpty()){
				JSONObject item = operData.getJSONObject(0);
				Row operRow = sheet.createRow(data.size() + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = operRow.createCell(j);
					if (j > 3) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				operRow.getCell(0).setCellValue("（主管）" + item.getString("OPER_NAME"));
				operRow.getCell(3).setCellValue(item.getString("OPER_NAME"));
				operRow.getCell(4).setCellValue(item.getDoubleValue("RECHARGE_AMT") / 100);
				operRow.getCell(5).setCellValue(item.getDoubleValue("BHK_AMT") / 100);
				operRow.getCell(6).setCellValue(item.getDoubleValue("TOTAL_AMT") / 100);
				sheet.addMergedRegion(new CellRangeAddress(data.size() + headRows, data.size() + headRows, 0, 2));
			}
			// user sum
			Row usersRow = sheet.createRow(sheet.getLastRowNum() + 1);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = usersRow.createCell(j);
				if (j > 3) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			usersRow.getCell(0).setCellValue("柜员调剂总计");
			usersRow.getCell(3).setCellValue("共 " + numSum + " 条记录");
			usersRow.getCell(4).setCellValue(rAmtSum / 100);
			usersRow.getCell(5).setCellValue(bhkAmtSum / 100);
			usersRow.getCell(6).setCellValue(totAmtSum / 100);
			sheet.addMergedRegion(new CellRangeAddress(sheet.getLastRowNum(), sheet.getLastRowNum(), 0, 2));
			//total
			if(operData != null && !operData.isEmpty()){
				JSONObject item = operData.getJSONObject(0);
				Row operRow = sheet.createRow(sheet.getLastRowNum() + 1);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = operRow.createCell(j);
					if (j > 3) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				operRow.getCell(0).setCellValue("总计");
				operRow.getCell(4).setCellValue((rAmtSum + item.getDoubleValue("RECHARGE_AMT")) / 100);
				operRow.getCell(5).setCellValue((bhkAmtSum + item.getDoubleValue("BHK_AMT")) / 100);
				operRow.getCell(6).setCellValue((totAmtSum + item.getDoubleValue("TOTAL_AMT")) / 100);
				sheet.addMergedRegion(new CellRangeAddress(sheet.getLastRowNum(), sheet.getLastRowNum(), 0, 2));
			}
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String getBranchId() {
		return branchId;
	}
	public void setBranchId(String branchId) {
		this.branchId = branchId;
	}
	public String getOperatorId() {
		return operatorId;
	}
	public void setOperatorId(String operatorId) {
		this.operatorId = operatorId;
	}
	public String getIsZero() {
		return isZero;
	}
	public void setIsZero(String isZero) {
		this.isZero = isZero;
	}
	public String getQueryType() {
		return queryType;
	}
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	public CashManageService getCashManageService() {
		return cashManageService;
	}
	public void setCashManageService(CashManageService cashManageService) {
		this.cashManageService = cashManageService;
	}
	public GridModel getGrid() {
		return grid;
	}
	public void setGrid(GridModel grid) {
		this.grid = grid;
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
	public String getCurrentBranchId() {
		return currentBranchId;
	}
	public void setCurrentBranchId(String currentBranchId) {
		this.currentBranchId = currentBranchId;
	}
	public String getCurrentOperatorId() {
		return currentOperatorId;
	}
	public void setCurrentOperatorId(String currentOperatorId) {
		this.currentOperatorId = currentOperatorId;
	}
	public String getTd_blc() {
		return td_blc;
	}
	public void setTd_blc(String td_blc) {
		this.td_blc = td_blc;
	}
	public String getCurrentBranchName() {
		return currentBranchName;
	}
	public void setCurrentBranchName(String currentBranchName) {
		this.currentBranchName = currentBranchName;
	}
	public String getCurrentOperatorName() {
		return currentOperatorName;
	}
	public void setCurrentOperatorName(String currentOperatorName) {
		this.currentOperatorName = currentOperatorName;
	}
	public String getDefaultErrorMsg() {
		return defaultErrorMsg;
	}
	public void setDefaultErrorMsg(String defaultErrorMsg) {
		this.defaultErrorMsg = defaultErrorMsg;
	}
	public String getOut_blc() {
		return out_blc;
	}
	public void setOut_blc(String out_blc) {
		this.out_blc = out_blc;
	}
	public String getInTellerPwd() {
		return inTellerPwd;
	}
	public void setInTellerPwd(String inTellerPwd) {
		this.inTellerPwd = inTellerPwd;
	}
	public String getTotalAmt() {
		return totalAmt;
	}
	public void setTotalAmt(String totalAmt) {
		this.totalAmt = totalAmt;
	}
	public String getBankNo() {
		return bankNo;
	}
	public void setBankNo(String bankNo) {
		this.bankNo = bankNo;
	}
	public String getFrzAmt() {
		return frzAmt;
	}
	public void setFrzAmt(String frzAmt) {
		this.frzAmt = frzAmt;
	}
	public String getAvailableAmt() {
		return availableAmt;
	}
	public void setAvailableAmt(String availableAmt) {
		this.availableAmt = availableAmt;
	}
	public SysBranch getBrch() {
		return brch;
	}
	public void setBrch(SysBranch brch) {
		this.brch = brch;
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
	public String getDealState() {
		return dealState;
	}
	public void setDealState(String dealState) {
		this.dealState = dealState;
	}
	public Long getDealNo() {
		return dealNo;
	}
	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public String getCoinKind() {
		return coinKind;
	}
	public void setCoinKind(String coinKind) {
		this.coinKind = coinKind;
	}
	public String getInOutFlag() {
		return inOutFlag;
	}
	public void setInOutFlag(String inOutFlag) {
		this.inOutFlag = inOutFlag;
	}
	public String getDealNos() {
		return dealNos;
	}
	public void setDealNos(String dealNos) {
		this.dealNos = dealNos;
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
	public String getOperId() {
		return operId;
	}
	public void setOperId(String operId) {
		this.operId = operId;
	}
	public String getSerNos() {
		return serNos;
	}
	public void setSerNos(String serNos) {
		this.serNos = serNos;
	}
}
