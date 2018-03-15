package com.erp.serviceImpl;

import java.io.OutputStream;

import java.net.URLEncoder;
import java.sql.ResultSet;
import java.util.HashMap;

import javax.servlet.http.HttpServletResponse;

import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.struts2.ServletActionContext;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONObject;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.service.MerchantSettlementService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.Tools;

import net.sf.jasperreports.engine.JRResultSetDataSource;
import net.sf.jasperreports.engine.JasperRunManager;

/**
 * 商户结算。
 * @author 钱佳明。
 *
 */
@Service("merchantSettlementService")
public class MerchantSettlementServiceImpl extends BaseServiceImpl implements MerchantSettlementService {

	/**
	 * 生成报表。
	 * @param merchantIds 商户编号。
	 * @param beginDate 起始日期。
	 * @param endDate 结束日期。
	 * @param cardType 卡类型。
	 * @param sysActionLog 操作日志。
	 * @return 业务日志。
	 */
	@Override
	@SuppressWarnings("unchecked")
	public TrServRec createReport(String merchantIds, String beginDate, String endDate, String cardType, SysActionLog sysActionLog) throws Exception {
		sysActionLog.setMessage("生成" + beginDate + "——" + endDate + "商户结算报表");
		sysActionLog.setNote("生成" + beginDate + "——" + endDate + "商户结算报表");
		publicDao.save(sysActionLog);
		String sql = generateSQL(merchantIds, beginDate, endDate, cardType);
		HashMap<String, Object> parameters = new HashMap<String, Object>();
		parameters.put("BEGIN_DATE", beginDate);
		parameters.put("END_DATE", endDate);
		String path = ServletActionContext.getRequest().getRealPath("/reportfiles/merchant_settlement_report.jasper");
		JRResultSetDataSource source = new JRResultSetDataSource(tofindResultSet(sql.toString()));
		byte[] pdfContent = JasperRunManager.runReportToPdf(path, parameters, source);
		saveSysReport(sysActionLog, new JSONObject(), "", Constants.APP_REPORT_TYPE_PDF2, 1L, "", pdfContent);
		TrServRec trServRec = new TrServRec();
		trServRec.setDealNo(sysActionLog.getDealNo());
		trServRec.setBizTime(sysActionLog.getDealTime());
		trServRec.setUserId(sysActionLog.getUserId());
		trServRec.setBrchId(getUser().getBrchId());
		trServRec.setOrgId(getUser().getOrgId());
		trServRec.setClrDate(getClrDate());
		trServRec.setNote(sysActionLog.getNote());
		publicDao.save(trServRec);
		return trServRec;
	}

	/**
	 * 导出Excel表格。
	 * @param merchantIds 商户编号。
	 * @param beginDate 起始日期。
	 * @param endDate 结束日期。
	 * @param cardType 卡类型。
	 */
	@Override
	@SuppressWarnings("resource")
	public void exportExcel(String merchantIds, String beginDate, String endDate, String cardType) throws Exception {
		String title = "商户结算报表";
		HSSFWorkbook workbook = new HSSFWorkbook();
		HSSFSheet sheet = workbook.createSheet(title);
		// 标题字体样式
		HSSFCellStyle titleCellStyle = workbook.createCellStyle();
		titleCellStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		titleCellStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
		titleCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);
		titleCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);
		titleCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);
		titleCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);
		HSSFFont titleFontStyle = workbook.createFont();
		titleFontStyle.setBold(true);
		titleFontStyle.setFontName("宋体");
		titleFontStyle.setFontHeightInPoints((short)24);
		titleCellStyle.setFont(titleFontStyle);
		// 单元格对齐样式
		HSSFCellStyle cellStyle = workbook.createCellStyle();
		cellStyle.setAlignment(HSSFCellStyle.ALIGN_CENTER);
		cellStyle.setVerticalAlignment(HSSFCellStyle.VERTICAL_CENTER);
		cellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);
		cellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);
		cellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);
		cellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);
		HSSFFont cellFontStyle = workbook.createFont();
		cellFontStyle.setFontName("宋体");
		cellStyle.setFont(cellFontStyle);
		// 设置列宽
		for (int i = 0; i<= 15; i++) {
			if (i <= 2) {
				sheet.setColumnWidth(i, 5000);
			} else {
				sheet.setColumnWidth(i, 4000);
			}
		}
		// 标题合并单元格
		sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, 15));
		sheet.addMergedRegion(new CellRangeAddress(2, 3, 0, 0));
		sheet.addMergedRegion(new CellRangeAddress(2, 3, 1, 1));
		sheet.addMergedRegion(new CellRangeAddress(2, 3, 2, 2));
		sheet.addMergedRegion(new CellRangeAddress(2, 2, 3, 6));
		sheet.addMergedRegion(new CellRangeAddress(2, 2, 7, 10));
		sheet.addMergedRegion(new CellRangeAddress(2, 2, 11, 14));
		sheet.addMergedRegion(new CellRangeAddress(2, 3, 15, 15));
		// 标题
		HSSFRow dateRow = sheet.createRow(0);
		dateRow.setHeight((short) 500);
		dateRow.createCell(11).setCellValue("起止日期：" + beginDate + " ~ " + endDate);
		dateRow.createCell(12);
		dateRow.createCell(13);
		dateRow.createCell(14).setCellValue("导出时间：" + DateUtils.getNowTime());
		dateRow.createCell(15);
		sheet.addMergedRegion(new CellRangeAddress(dateRow.getRowNum(), dateRow.getRowNum(), 11, 13));
		sheet.addMergedRegion(new CellRangeAddress(dateRow.getRowNum(), dateRow.getRowNum(), 14, 15));
		HSSFRow titleRow = sheet.createRow(1);
		titleRow.setHeight((short) 800);
		for (int i = 0; i <= 15; i++) {
			if (i == 0) {
				Cell cell = titleRow.createCell(i);
				cell.setCellStyle(titleCellStyle);
				cell.setCellValue(title);
			} else {
				titleRow.createCell(i).setCellStyle(cellStyle);
			}
		}
		HSSFRow fieldRow1 = sheet.createRow(2);
		fieldRow1.setHeight((short) 500);
		Cell idFieldCell = fieldRow1.createCell(0);
		idFieldCell.setCellValue("商户编号");
		idFieldCell.setCellStyle(cellStyle);
		Cell nameFieldCell = fieldRow1.createCell(1);
		nameFieldCell.setCellValue("商户名称");
		nameFieldCell.setCellStyle(cellStyle);
		Cell cardFieldCell = fieldRow1.createCell(2);
		cardFieldCell.setCellValue("卡类型");
		cardFieldCell.setCellStyle(cellStyle);
		Cell olFieldCell = fieldRow1.createCell(3);
		olFieldCell.setCellStyle(cellStyle);
		olFieldCell.setCellValue("联机账户");
		fieldRow1.createCell(4).setCellStyle(cellStyle);
		fieldRow1.createCell(5).setCellStyle(cellStyle);
		fieldRow1.createCell(6).setCellStyle(cellStyle);
		Cell oflFieldCell = fieldRow1.createCell(7);
		oflFieldCell.setCellStyle(cellStyle);
		oflFieldCell.setCellValue("钱包账户");
		fieldRow1.createCell(8).setCellStyle(cellStyle);
		fieldRow1.createCell(9).setCellStyle(cellStyle);
		fieldRow1.createCell(10).setCellStyle(cellStyle);
		Cell thFieldCell = fieldRow1.createCell(11);
		thFieldCell.setCellStyle(cellStyle);
		thFieldCell.setCellValue("退货");
		fieldRow1.createCell(12).setCellStyle(cellStyle);
		fieldRow1.createCell(13).setCellStyle(cellStyle);
		fieldRow1.createCell(14).setCellStyle(cellStyle);
		Cell totalFieldCell = fieldRow1.createCell(15);
		totalFieldCell.setCellStyle(cellStyle);
		totalFieldCell.setCellValue("合计");
		HSSFRow fieldRow2 = sheet.createRow(3);
		fieldRow2.setHeight((short) 500);
		fieldRow2.createCell(0).setCellStyle(cellStyle);
		fieldRow2.createCell(1).setCellStyle(cellStyle);
		fieldRow2.createCell(2).setCellStyle(cellStyle);
		for (int i = 1; i <= 3; i++) {
			String[] titles = { "交易笔数", "交易金额", "结算金额", "手续费" };
			int count = titles.length * i - 1;
			for (int j = 0; j < titles.length; j++) {
				Cell cell = fieldRow2.createCell(count++);
				cell.setCellStyle(cellStyle);
				cell.setCellValue(titles[j]);
			}
		}
		fieldRow2.createCell(15).setCellStyle(cellStyle);
		String sql = generateSQL(merchantIds, beginDate, endDate, cardType);
		ResultSet resultSet = tofindResultSet(sql);
		int rowIndex = 4;
		String temp = "";
		String olDealNumSum = "0";
		String olDealAmtSum = "0";
		String olStlAmtSum = "0";
		String olFeeAmtSum = "0";
		String oflDealNumSum = "0";
		String oflDealAmtSum = "0";
		String oflStlAmtSum = "0";
		String oflFeeAmtSum = "0";
		String thNumSum = "0";
		String thAmtSum = "0";
		String thStlAmtSum = "0";
		String thFeeAmtSum = "0";
		String stlAmtSum = "0";
		while (resultSet.next()) {
			HSSFRow row = sheet.createRow(rowIndex);
			row.setHeight((short) 500);
			// 商户编号
			Cell idCell = row.createCell(0);
			idCell.setCellStyle(cellStyle);
			String id = resultSet.getString("merchant_id");
			idCell.setCellValue(resultSet.getString("merchant_id"));
			// 商户名称
			Cell nameCell = row.createCell(1);
			nameCell.setCellStyle(cellStyle);
			nameCell.setCellValue(resultSet.getString("merchant_name"));
			if (temp.equals(id)) {
				sheet.addMergedRegion(new CellRangeAddress(rowIndex - 1, rowIndex, 0, 0));
				sheet.addMergedRegion(new CellRangeAddress(rowIndex - 1, rowIndex, 1, 1));
			}
			temp = id;
			// 卡类型
			Cell cardCell = row.createCell(2);
			cardCell.setCellStyle(cellStyle);
			cardCell.setCellValue(resultSet.getString("card_name"));
			// 联机账户（交易笔数）
			Cell olDealNumCell = row.createCell(3);
			olDealNumCell.setCellStyle(cellStyle);
			String olDealNum = resultSet.getString("ol_deal_num");
			olDealNumCell.setCellValue(olDealNum);
			olDealNumSum = Arith.add(olDealNumSum, olDealNum);
			// 联机账户（交易金额）
			Cell olDealAmtCell = row.createCell(4);
			olDealAmtCell.setCellStyle(cellStyle);
			String olDealAmt = resultSet.getString("ol_deal_amt");
			olDealAmtCell.setCellValue(Arith.cardreportsmoneydiv(olDealAmt));
			olDealAmtSum = Arith.add(olDealAmtSum, olDealAmt);
			// 联机账户（手续费）
			Cell olFeeAmtCell = row.createCell(6);
			olFeeAmtCell.setCellStyle(cellStyle);
			String olFeeAmt = resultSet.getString("ol_fee_amt");
			olFeeAmtCell.setCellValue(Arith.cardreportsmoneydiv(olFeeAmt));
			olFeeAmtSum = Arith.add(olFeeAmtSum, olFeeAmt);
			// 联机账户（结算金额）
			Cell olStlAmtCell = row.createCell(5);
			olStlAmtCell.setCellStyle(cellStyle);
			String olStlAmt = Arith.sub(olDealAmt, olFeeAmt);
			olStlAmtCell.setCellValue(Arith.cardreportsmoneydiv(olStlAmt));
			olStlAmtSum = Arith.add(olStlAmtSum, olStlAmt);
			// 电子钱包（交易笔数）
			Cell oflDealNumCell = row.createCell(7);
			oflDealNumCell.setCellStyle(cellStyle);
			String oflDealNum = resultSet.getString("ofl_deal_num");
			oflDealNumCell.setCellValue(oflDealNum);
			oflDealNumSum = Arith.add(oflDealNumSum, oflDealNum);
			// 电子钱包（交易金额）
			Cell oflDealAmtCell = row.createCell(8);
			oflDealAmtCell.setCellStyle(cellStyle);
			String oflDealAmt = resultSet.getString("ofl_deal_amt");
			oflDealAmtCell.setCellValue(Arith.cardreportsmoneydiv(oflDealAmt));
			oflDealAmtSum = Arith.add(oflDealAmtSum, oflDealAmt);
			// 电子钱包（手续费）
			Cell oflFeeAmtCell = row.createCell(10);
			oflFeeAmtCell.setCellStyle(cellStyle);
			String oflFeeAmt = resultSet.getString("ofl_fee_amt");
			oflFeeAmtCell.setCellValue(Arith.cardreportsmoneydiv(oflFeeAmt));
			oflFeeAmtSum = Arith.add(oflFeeAmtSum, oflFeeAmt);
			// 电子钱包（结算金额）
			Cell oflStlAmtCell = row.createCell(9);
			oflStlAmtCell.setCellStyle(cellStyle);
			String oflStlAmt = Arith.sub(oflDealAmt, oflFeeAmt);
			oflStlAmtCell.setCellValue(Arith.cardreportsmoneydiv(oflStlAmt));
			oflStlAmtSum = Arith.add(oflStlAmtSum, oflStlAmt);
			// 退货（交易笔数）
			Cell thNumCell = row.createCell(11);
			thNumCell.setCellStyle(cellStyle);
			String thNum = resultSet.getString("th_num");
			thNumCell.setCellValue(thNum);
			thNumSum = Arith.add(thNumSum, thNum);
			// 退货（交易金额）
			Cell thAmtCell = row.createCell(12);
			thAmtCell.setCellStyle(cellStyle);
			String thAmt = resultSet.getString("th_amt");
			thAmtCell.setCellValue(Arith.cardreportsmoneydiv(thAmt));
			thAmtSum = Arith.add(thAmtSum, thAmt);
			// 退货（手续费）
			Cell thFeeAmtCell = row.createCell(14);
			thFeeAmtCell.setCellStyle(cellStyle);
			String thFeeAmt = resultSet.getString("th_fee_amt");
			thFeeAmtCell.setCellValue(Arith.cardreportsmoneydiv(thFeeAmt));
			thFeeAmtSum = Arith.add(thFeeAmtSum, thFeeAmt);
			// 退货（结算金额）
			Cell thStlAmtCell = row.createCell(13);
			thStlAmtCell.setCellStyle(cellStyle);
			String thStlAmt = Arith.sub(thAmt, thFeeAmt);
			thStlAmtCell.setCellValue(Arith.cardreportsmoneydiv(thStlAmt));
			thStlAmtSum = Arith.add(thStlAmtSum, thStlAmt);
			// 合计结算金额
			Cell stlAmtCell = row.createCell(15);
			stlAmtCell.setCellStyle(cellStyle);
			String stlAmt = resultSet.getString("stl_amt");
			stlAmtCell.setCellValue(Arith.cardreportsmoneydiv(stlAmt));
			stlAmtSum = Arith.add(stlAmtSum, stlAmt);
			rowIndex++;
		}
		sheet.addMergedRegion(new CellRangeAddress(rowIndex, rowIndex, 0, 2));
		HSSFRow row = sheet.createRow(rowIndex);
		row.setHeight((short) 500);
		Cell totalCell = row.createCell(0);
		totalCell.setCellStyle(cellStyle);
		totalCell.setCellValue("合计");
		row.createCell(1).setCellStyle(cellStyle);
		row.createCell(2).setCellStyle(cellStyle);
		// 联机账户（交易笔数）
		Cell olDealNumSumCell = row.createCell(3);
		olDealNumSumCell.setCellStyle(cellStyle);
		olDealNumSumCell.setCellValue(olDealNumSum);
		// 联机账户（交易金额）
		Cell olDealAmtSumCell = row.createCell(4);
		olDealAmtSumCell.setCellStyle(cellStyle);
		olDealAmtSumCell.setCellValue(Arith.cardreportsmoneydiv(olDealAmtSum));
		// 联机账户（结算金额）
		Cell olStlAmtSumCell = row.createCell(5);
		olStlAmtSumCell.setCellStyle(cellStyle);
		olStlAmtSumCell.setCellValue(Arith.cardreportsmoneydiv(olStlAmtSum));
		// 联机账户（手续费）
		Cell olFeeAmtSumCell = row.createCell(6);
		olFeeAmtSumCell.setCellStyle(cellStyle);
		olFeeAmtSumCell.setCellValue(Arith.cardreportsmoneydiv(olFeeAmtSum));
		// 电子钱包（交易笔数）
		Cell oflDealNumSumCell = row.createCell(7);
		oflDealNumSumCell.setCellStyle(cellStyle);
		oflDealNumSumCell.setCellValue(oflDealNumSum);
		// 电子钱包（交易金额）
		Cell oflDealAmtSumCell = row.createCell(8);
		oflDealAmtSumCell.setCellStyle(cellStyle);
		oflDealAmtSumCell.setCellValue(Arith.cardreportsmoneydiv(oflDealAmtSum));
		// 电子钱包（结算金额）
		Cell oflStlAmtSumCell = row.createCell(9);
		oflStlAmtSumCell.setCellStyle(cellStyle);
		oflStlAmtSumCell.setCellValue(Arith.cardreportsmoneydiv(oflStlAmtSum));
		// 电子钱包（手续费）
		Cell oflFeeAmtSumCell = row.createCell(10);
		oflFeeAmtSumCell.setCellStyle(cellStyle);
		oflFeeAmtSumCell.setCellValue(Arith.cardreportsmoneydiv(oflFeeAmtSum));
		// 退货（交易笔数）
		Cell thNumSumCell = row.createCell(11);
		thNumSumCell.setCellStyle(cellStyle);
		thNumSumCell.setCellValue(thNumSum);
		// 退货（交易金额）
		Cell thAmtSumCell = row.createCell(12);
		thAmtSumCell.setCellStyle(cellStyle);
		thAmtSumCell.setCellValue(Arith.cardreportsmoneydiv(thAmtSum));
		// 退货（结算金额）
		Cell thStlAmtSumCell = row.createCell(13);
		thStlAmtSumCell.setCellStyle(cellStyle);
		thStlAmtSumCell.setCellValue(Arith.cardreportsmoneydiv(thStlAmtSum));
		// 退货（手续费）
		Cell thFeeAmtSumCell = row.createCell(14);
		thFeeAmtSumCell.setCellStyle(cellStyle);
		thFeeAmtSumCell.setCellValue(Arith.cardreportsmoneydiv(thFeeAmtSum));
		// 合计结算金额
		Cell stlAmtSumCell = row.createCell(15);
		stlAmtSumCell.setCellStyle(cellStyle);
		stlAmtSumCell.setCellValue(Arith.cardreportsmoneydiv(stlAmtSum));
		// 冻结
		sheet.createFreezePane(3, 4, 3, 4);
		// 输出
		HttpServletResponse response = ServletActionContext.getResponse();
		response.setContentType("application/ms-excel;charset=utf-8");
	    response.setHeader("Content-disposition", "attachment; filename="+ URLEncoder.encode(title,"UTF8") + ".xls");
		OutputStream out = response.getOutputStream();
		workbook.write(out);
		out.close();
	}

	/**
	 * 创建SQL语句。
	 * @param merchantIds 商户编号。
	 * @param beginDate 起始日期。
	 * @param endDate 结束日期。
	 * @param cardType 卡类型。
	 * @return SQL语句。
	 */
	private String generateSQL(String merchantIds, String beginDate, String endDate, String cardType) {
		StringBuffer sql = new StringBuffer();
		String dateRange = " and to_date(sds.begin_date, 'yyyy-MM-dd') between to_date('" + beginDate + "', 'yyyy-MM-dd') and to_date('" + endDate + "', 'yyyy-MM-dd')";
		sql.append("select sdst.merchant_id, sdst.merchant_name, sdst.card_type, ");
		sql.append("(select sc.code_name from sys_code sc where sc.code_type = 'CARD_TYPE' and sc.code_value = sdst.card_type) card_name, ");
		sql.append("(select nvl(sum(sds.deal_num), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind = '" + Constants.ACC_KIND_ZJZH + "'" + dateRange + ") ol_deal_num, ");
		sql.append("(select nvl(sum(sds.deal_amt), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind = '" + Constants.ACC_KIND_ZJZH + "'" + dateRange + ") ol_deal_amt, ");
		sql.append("(select nvl(sum(sdl.fee_amt), 0) from stl_deal_list sdl where sdl.stl_sum_no in ");
		sql.append("(select sds.stl_sum_no from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind = '" + Constants.ACC_KIND_ZJZH + "'" + dateRange + ") and sdl.deal_code = '" + DealCode.ONLINE_CONSUME + "') ol_fee_amt, ");
		sql.append("(select nvl(sum(sds.deal_num), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind = '" + Constants.ACC_KIND_QBZH + "'" + dateRange + ") ofl_deal_num, ");
		sql.append("(select nvl(sum(sds.deal_amt), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind = '" + Constants.ACC_KIND_QBZH + "'" + dateRange + ") ofl_deal_amt, ");
		sql.append("(select nvl(sum(sdl.fee_amt), 0) from stl_deal_list sdl where sdl.stl_sum_no in ");
		sql.append("(select sds.stl_sum_no from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind = '" + Constants.ACC_KIND_QBZH + "'" + dateRange + ") and sdl.deal_code = '" + DealCode.OFFLINE_CONSUME + "') ofl_fee_amt, ");
		sql.append("(select nvl(sum(sds.th_num), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and acc_kind in ('" + Constants.ACC_KIND_QBZH + "','" + Constants.ACC_KIND_ZJZH + "')" + dateRange + ") th_num, ");
		sql.append("(select nvl(sum(sds.th_amt), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and acc_kind in ('" + Constants.ACC_KIND_QBZH + "','" + Constants.ACC_KIND_ZJZH + "')" + dateRange + ") th_amt, ");
		sql.append("(select nvl(sum(sdl.fee_amt), 0) from stl_deal_list sdl where sdl.stl_sum_no in ");
		sql.append("(select sds.stl_sum_no from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind in ('" + Constants.ACC_KIND_QBZH + "','" + Constants.ACC_KIND_ZJZH + "')" + dateRange + ") and sdl.deal_code in ('" + DealCode.OFFLINE_CONSUME_RETURN + "','" + DealCode.ONLINE_CONSUME_RETURN + "')) th_fee_amt, ");
		sql.append("(select nvl(sum(sds.stl_amt), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind in ('" + Constants.ACC_KIND_QBZH + "','" + Constants.ACC_KIND_ZJZH + "')" + dateRange + ") stl_amt ");
		sql.append("from (select sds.merchant_id, t.merchant_name, sds.card_type from stl_deal_sum sds,base_merchant t where 1 = 1 and sds.merchant_id = t.merchant_id(+) " + dateRange);
		sql.append(" group by sds.merchant_id, t.merchant_name, sds.card_type order by sds.merchant_id asc) sdst where sdst.merchant_id in (" + merchantIds + ") ");
		if(!Tools.processNull(cardType).equals("")) {
			sql.append(" and sdst.card_type = '" + cardType + "'");
		}
		return sql.toString();
	}
}
