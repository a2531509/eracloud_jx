package com.erp.action;

import com.alibaba.fastjson.JSONObject;
import com.erp.util.DateUtils;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;

import com.erp.exception.CommonException;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

import java.io.OutputStream;

/**
 *
 */
@Namespace("/cardInfoCount")
@Action("cardInfoCountAction")
public class CardInfoCountAction extends BaseAction{
	private static final long serialVersionUID = 1L;
	private String beginTime;
	private String endTime;
	private String bankId;
	private String regionId;
	private String applyState = "20";
	private String bankName;
	private String certNo;
	private String cardNo;
	private String queryType = "1";
	private String applyBatchNo;

	
	public String cardInfoQuery(){
		try {
			initBaseDataGrid();
			String sql = "select t.med_whole_no, (select region_name from base_region where region_id = t.med_whole_no) region_name, "
					+ "t.bank_id, (select bank_name from base_bank where bank_id = t.bank_id) bank_name, count(1) tot_num, "
					+ "sum(decode(t.card_type, '100', 1, 0)) card_qgn, sum(decode(t.card_type, '120', 1, 0)) card_jrk "
					+ "from card_apply t where card_type in ('100', '120') and t.apply_state between '" + applyState + "' and '60' "
					+ "and (t.card_type = '100' or not exists (select 1 from card_apply where customer_id = t.customer_id and card_type = '100' and apply_state = '60')) ";
			if (!Tools.processNull(beginTime).equals("")) {
				sql += "and t.apply_date >= to_date('" + beginTime + "','yyyy-mm-dd') ";
			}
			if (!Tools.processNull(endTime).equals("")) {
				sql += "and t.apply_date <= to_date('" + endTime + "','yyyy-mm-dd') ";
			}

			if (!Tools.processNull(bankId).equals("")) {
				sql += "and t.bank_id = '" + bankId + "' ";
			}
			if (!Tools.processNull(regionId).equals("")) {
				sql += "and t.med_whole_no = '" + regionId + "' ";
			}
			sql += "group by t.med_whole_no,t.bank_id ";
			if (!Tools.processNull(sort).equals("")) {
				sql += "order by " + sort;
				if (!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			} else {
				sql += "order by t.med_whole_no,t.bank_id";
			}
			
			Page list = baseService.pagingQuery(sql, page, rows);
			if (list.getAllRs() == null && list.getAllRs().isEmpty()) {
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
	
	
	 //省社保工本费统计
    public String querySBFeeCount(){
        try{
        	
            this.initBaseDataGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select t.apply_batch_no,t.bank_id,b.bank_name,sum(decode(t.cost_fee,'0',1,'0')) free,sum(decode(t.cost_fee,'2000',1,'0')) cost,count(1) tot_num,sum(t.cost_fee) tot_amt ");
				sb.append("from card_apply_cost t,base_bank b ");
				sb.append("where t.bank_id = b.bank_id");

				if(!Tools.processNull(this.bankId).equals("")){
					sb.append(" and t.bank_id = '" + this.bankId + "' ");
				}
				if(!Tools.processNull(beginTime).equals("")){
					sb.append(" and t.apply_batch_no >='"+Tools.processNull(beginTime)+"'");
				}
				if(!Tools.processNull(endTime).equals("")){
					sb.append(" and t.apply_batch_no <='"+Tools.processNull(endTime)+"'");
				}
				sb.append(" group by t.apply_batch_no,t.bank_id,b.bank_name");
				sb.append(" order by t.apply_batch_no desc");
				Page list = baseService.pagingQuery(sb.toString(), page, rows);
				if(list.getAllRs() == null || list.getAllRs().size() <= 0){
					throw new CommonException("根据指定条件未查询到对应信息！");
				}else{
					jsonObject.put("rows", list.getAllRs());
					jsonObject.put("total", list.getTotalCount());
				}
			}

        }catch(Exception e){
            this.jsonObject.put("status","1");
            this.jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }


	//预览省社保工本费统计明细
	public String querySBFeeCountList(){
		try{
			this.initBaseDataGrid();

				StringBuffer sb = new StringBuffer();
				sb.append("select t.apply_id,t.customer_id,t.cert_no,b.name,decode(t.card_type,'120','金融市民卡','100','全功能卡') card_type, ");
				sb.append("t.card_no,decode(t.apply_type,'0','初次申领','1','换卡','2','补卡')apply_type,t.cost_fee / 100 cost_fee, ");
				sb.append("t.bank_id,t.bank_card_no,t.apply_batch_no ");
				sb.append("from card_apply_cost t, base_personal b ");
				sb.append("where t.cert_no = b.cert_no");

				if(!Tools.processNull(this.bankId).equals("")){
					sb.append(" and t.bank_id = '" + this.bankId + "' ");
				}
				if(!Tools.processNull(this.applyBatchNo).equals("")){
					sb.append(" and t.apply_batch_no = '" + this.applyBatchNo + "' ");
				}


				if(!Tools.processNull(certNo).equals("")){
					sb.append(" and t.cert_no = '" + certNo + "' ");
				}
				if(!Tools.processNull(cardNo).equals("")){
					sb.append(" and t.card_no = '" + cardNo + "' ");
				}

				Page list = baseService.pagingQuery(sb.toString(), page, rows);
				if(list.getAllRs() == null || list.getAllRs().size() <= 0){
					throw new CommonException("根据指定条件未查询到对应信息！");
				}else{
					jsonObject.put("rows", list.getAllRs());
					jsonObject.put("total", list.getTotalCount());
				}


		}catch(Exception e){
			this.jsonObject.put("status","1");
			this.jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}


	public String export() {
		try {

			querySBFeeCount();

			String fileName = "省社保工本费统计";

			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");

			// workbook
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);

			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 2000);
			sheet.setColumnWidth(4, 2000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 3000);


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
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}

			sheet.getRow(0).getCell(0).setCellValue(fileName);

			sheet.getRow(1).getCell(0).setCellValue( " 导出时间：" + DateUtils.getNowTime());

			// second header
			sheet.getRow(2).getCell(0).setCellValue("日期");
			sheet.getRow(2).getCell(1).setCellValue("银行编号");
			sheet.getRow(2).getCell(2).setCellValue("银行名称");
			sheet.getRow(2).getCell(3).setCellValue("免费笔数");
			sheet.getRow(2).getCell(4).setCellValue("收费笔数");
			sheet.getRow(2).getCell(5).setCellValue("总笔数");
			sheet.getRow(2).getCell(6).setCellValue("总金额");


			//
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 6));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, 6));

			int numSum = 0;
			int feeSum = 0;
			int costSum = 0;
			int totSum = 0;
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

				row.getCell(0).setCellValue(item.getString("APPLY_BATCH_NO"));
				row.getCell(1).setCellValue(item.getString("BANK_ID"));
				row.getCell(2).setCellValue(item.getString("BANK_NAME"));
				row.getCell(3).setCellValue(item.getString("FREE"));
				row.getCell(4).setCellValue(item.getString("COST"));
				row.getCell(5).setCellValue(item.getString("TOT_NUM"));
				row.getCell(6).setCellValue(item.getDoubleValue("TOT_AMT") / 100);


				amtSum += item.getDoubleValue("TOT_AMT");
				feeSum += item.getDoubleValue("FREE");
				costSum += item.getDoubleValue("COST");
				totSum += item.getDoubleValue("TOT_NUM");
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
			row.getCell(3).setCellValue("共 " + feeSum + " 笔");
			row.getCell(4).setCellValue("共 " + costSum + " 笔");
			row.getCell(5).setCellValue("共 " + totSum + " 笔");
			row.getCell(6).setCellValue(amtSum / 100);
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

	public String getBankId() {
		return bankId;
	}

	public void setBankId(String bankId) {
		this.bankId = bankId;
	}

	public String getRegionId() {
		return regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	public String getApplyState() {
		return applyState;
	}

	public void setApplyState(String applyState) {
		this.applyState = applyState;
	}


	public String getBankName() {
		return bankName;
	}


	public void setBankName(String bankName) {
		this.bankName = bankName;
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

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}

	public String getApplyBatchNo() {
		return applyBatchNo;
	}

	public void setApplyBatchNo(String applyBatchNo) {
		this.applyBatchNo = applyBatchNo;
	}
}
