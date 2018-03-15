package com.erp.action;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.Tools;
import com.erp.viewModel.Page;
import org.apache.log4j.Logger;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.shiro.SecurityUtils;
import org.apache.struts2.convention.annotation.*;

import java.io.OutputStream;
import java.net.URLEncoder;

/**
 * Created by Administrator on 2016/12/29.
 */
@SuppressWarnings("serial")
@Namespace("/unionManage")
@Action("UnionManageAction")
@InterceptorRef("jsondefalut")
@Results({
    @Result(name = "queryYdkBdConsumeStat",location = "/jsp/statistics/ydkbdxftj.jsp"),
    @Result(name = "queryYdkBdConsumeShStat",location = "/jsp/statistics/ydkbdxfshtj.jsp"),
    @Result(name = "queryBdkYdConsumeStat",location = "/jsp/statistics/bdkydxftj.jsp"),
    @Result(name = "queryBdkYdConsumeShStat",location = "/jsp/statistics/bdkydxfshtj.jsp"),
    @Result(name = "queryBdkYdConsumeJfStat",location = "/jsp/statistics/bdkydxfJftj.jsp")
})
public class UnionManageAction extends BaseAction{
    public Logger log = Logger.getLogger(StatisticalAnalysisAction.class);
    private String sort;
    private String order;
    private String beginTime;
    private String endTime;
    private String clrBeginTime;
    private String clrEndTime;
    private String queryType;
    private String pageType;
    private String bizId;

    /**
     * 根据页面请求类型到达不同页面
     * @return
     */
    public String commonToPageIndex(){
        try{
            this.beginTime = DateUtil.getNowDate().substring(0,8) + "01";
            this.endTime = DateUtil.getNowDate();
        }catch(Exception e){
            this.defaultErrorMsg = e.getMessage();
        }
        return pageType;
    }
    /**
     * 全国互联互通异地卡本地消费统计
     * @return
     */
    public String queryYdkBdConsumeStat(){
        try{
            this.initBaseDataGrid();
            if(!Tools.processNull(this.queryType).equals("0")){
                return this.JSONOBJ;
            }
            StringBuffer sb = new StringBuffer();
            sb.append("select t.settle_date,");
            sb.append("sum((case when t.card_org_id = '0000' and t.refuse_reason = '00' and t.settle_state = '000000' then 1 else 0 end)) qgzctotnum,\n");
            sb.append("sum((case when t.card_org_id = '0000' and t.refuse_reason = '00' and t.settle_state = '000000' then t.deal_amt else 0 end))/100 qgzctotamt,\n");
            sb.append("(select count(1) from pay_offline_union_dt b where b.card_org_id = '0000' and substr(b.send_file_name,3,6) = substr(replace(t.settle_date,'-',''),3,6) and b.settle_state <> '000000') qgjftotnum,\n");
            sb.append("nvl((select sum(b.deal_amt) from pay_offline_union_dt b where b.card_org_id = '0000' and substr(b.send_file_name,3,6) = substr(replace(t.settle_date,'-',''),3,6) and b.settle_state <> '000000'),0)/100 qgjftotamt,\n");
            sb.append("sum((case when t.card_org_id = '0000' and t.refuse_reason = '00' and t.settle_state <> '000000' then 1 else 0 end)) qgtztotnum,\n");
            sb.append("sum((case when t.card_org_id = '0000' and t.refuse_reason = '00' and t.settle_state <> '000000' then t.deal_amt else 0 end))/100 qgtztotamt,\n");
            sb.append("'######' 华丽的分割线,");
            sb.append("sum((case when t.card_org_id = '0001' and t.refuse_reason = '00' and t.settle_state = '000000' then 1 else 0 end)) shzctotnum,\n");
            sb.append("sum((case when t.card_org_id = '0001' and t.refuse_reason = '00' and t.settle_state = '000000' then t.deal_amt else 0 end))/100 shzctotamt,\n");
            sb.append("(select count(1) from pay_offline_union_dt b where b.card_org_id = '0001' and substr(b.send_file_name,3,6) = substr(replace(t.settle_date,'-',''),3,6) and b.settle_state <> '000000') shjftotnum,\n");
            sb.append("nvl((select sum(b.deal_amt) from pay_offline_union_dt b where b.card_org_id = '0001' and substr(b.send_file_name,3,6) = substr(replace(t.settle_date,'-',''),3,6) and b.settle_state <> '000000'),0)/100 shjftotamt,\n");
            sb.append("sum((case when t.card_org_id = '0001' and t.refuse_reason = '00' and t.settle_state <> '000000' then 1 else 0 end)) shtztotnum,\n");
            sb.append("sum((case when t.card_org_id = '0001' and t.refuse_reason = '00' and t.settle_state <> '000000' then t.deal_amt else 0 end))/100 shtztotamt\n");
            sb.append("from pay_offline_union_dt t ");
            sb.append("where 1 = 1 ");
            if(!Tools.processNull(this.beginTime).equals("")){
                sb.append("and t.settle_date >= '" + this.beginTime + "' ");
            }
            if(!Tools.processNull(this.endTime).equals("")){
                sb.append("and t.settle_date <= '" + this.endTime + "' ");
            }
            sb.append("group by t.settle_date ");
            if(!Tools.processNull(sort).equals("")){
                String[]tempSorts = sort.split(",");
                String[] tempOrders = order.split(",");
                sb.append("order by ");
                for(int i = 0;i < tempSorts.length;i++){
                    sb.append(tempSorts[i] + " " + tempOrders[i]);
                    if(i != (tempSorts.length - 1)){
                        sb.append(",");
                    }
                    sb.append(" ");
                }
            }else{
                sb.append("order by t.settle_date desc");
            }
            Page pages = baseService.pagingQuery(sb.toString(),page,rows);
            if(pages.getAllRs() == null || pages.getAllRs().size() <= 0){
                throw new CommonException("根据指定信息未查询到对应的结算数据！");
            }else{
                jsonObject.put("rows",pages.getAllRs());
                jsonObject.put("total",pages.getTotalCount());
                jsonObject.put("totPages_01",pages.getTotalPages());
            }
        }catch(Exception e){
            jsonObject.put("status","1");
            jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 全国互联互通异地卡本地消费统计导出
     * @return
     */
    public String queryYdkBdConsumeStatExport(){
        try{
            queryType = "0";
            this.page = 1;
            this.rows = 10000;
            this.queryYdkBdConsumeStat();
            if(!Tools.processNull(jsonObject.get("status")).equals("0")){
                throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
            }
            Workbook book = new SXSSFWorkbook(500);
            Sheet sheet = book.createSheet();
            sheet.setFitToPage(true);
            sheet.createFreezePane(1,5);
            CellRangeAddress titleRegion = new CellRangeAddress(0,0,0,18);
            titleRegion.formatAsString();
            sheet.addMergedRegion(titleRegion);
            CellStyle titleStyle = this.getCellStyleOfTitle(book);
            Row firstRow = sheet.createRow(0);
            firstRow.setHeight((short)(firstRow.getHeight() * 2));
            Cell cell = firstRow.createCell(0);
            cell.setCellValue(Constants.APP_REPORT_TITLE + "异地卡本地消费结算统计");
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
            CellRangeAddress region1 = new CellRangeAddress(1,1,0,18);
            region1.formatAsString();
            sheet.addMergedRegion(region1);
            Row dateRow = sheet.createRow(1);
            Cell dateRow0 = dateRow.createCell(0);
            dateRow0.setCellValue("汇总周期：" + this.beginTime + " —— " + this.endTime + "  制表时间：" + DateUtil.formatDate(baseService.getDateBaseTime(),"yyyy-MM-dd HH:mm:ss"));
            dateRow0.setCellStyle(this.getCellStyleOfDateColumn(book));
            CellRangeAddress titRegion1 = new CellRangeAddress(2,4,0,0);
            CellRangeAddress titRegion2 = new CellRangeAddress(2,2,1,8);
            CellRangeAddress titRegion3 = new CellRangeAddress(2,2,9,16);
            CellRangeAddress titRegion4 = new CellRangeAddress(2,3,17,18);
            CellRangeAddress titRegion5 = new CellRangeAddress(3,3,1,6);
            CellRangeAddress titRegion6 = new CellRangeAddress(3,3,7,8);
            CellRangeAddress titRegion7 = new CellRangeAddress(3,3,9,14);
            CellRangeAddress titRegion8 = new CellRangeAddress(3,3,15,16);
            sheet.addMergedRegion(titRegion1);
            sheet.addMergedRegion(titRegion2);
            sheet.addMergedRegion(titRegion3);
            sheet.addMergedRegion(titRegion4);
            sheet.addMergedRegion(titRegion5);
            sheet.addMergedRegion(titRegion6);
            sheet.addMergedRegion(titRegion7);
            sheet.addMergedRegion(titRegion8);
            Row secRow = sheet.createRow(2);
            for(int d = 0;d <= 18; d++){
                secRow.createCell(d).setCellStyle(headStyle);
            }
            Cell secCell0 = secRow.createCell(0);
            secCell0.setCellValue("结算日期");
            secCell0.setCellStyle(headStyle);
            Cell secCell1 = secRow.createCell(1);
            secCell1.setCellValue("全国");
            secCell1.setCellStyle(headStyle);
            Cell secCell2 = secRow.createCell(9);
            secCell2.setCellValue("上海");
            secCell2.setCellStyle(headStyle);
            Cell secCell3 = secRow.createCell(17);
            secCell3.setCellValue("总合计");
            secCell3.setCellStyle(headStyle);
            Row thiRow = sheet.createRow(3);
            Cell thiCell0 = thiRow.createCell(1);
            thiCell0.setCellValue("结算数据");
            thiCell0.setCellStyle(headStyle);
            Cell thiCell7 = thiRow.createCell(7);
            thiCell7.setCellValue("小计");
            thiCell7.setCellStyle(headStyle);
            Cell thiCell9 = thiRow.createCell(9);
            thiCell9.setCellValue("结算数据");
            thiCell9.setCellStyle(headStyle);
            Cell thiCell15 = thiRow.createCell(15);
            thiCell15.setCellValue("小计");
            thiCell15.setCellStyle(headStyle);
            Row forRow = sheet.createRow(4);
            thiRow.createCell(17).setCellStyle(headStyle);
            thiRow.createCell(18).setCellStyle(headStyle);
            int rm = 0;
            for(int i = 0;i < 2;i++){
                Cell forCell1 = forRow.createCell(1 + rm);
                forCell1.setCellValue("正常笔数");
                forCell1.setCellStyle(headStyle);
                Cell forCell2 = forRow.createCell(2 + rm);
                forCell2.setCellValue("正常金额");
                forCell2.setCellStyle(headStyle);
                Cell forCell3 = forRow.createCell(3 + rm);
                forCell3.setCellValue("拒付笔数");
                forCell3.setCellStyle(headStyle);
                Cell forCell4 = forRow.createCell(4 + rm);
                forCell4.setCellValue("拒付金额");
                forCell4.setCellStyle(headStyle);
                Cell forCell5 = forRow.createCell(5 + rm);
                forCell5.setCellValue("调整笔数");
                forCell5.setCellStyle(headStyle);
                Cell forCell6 = forRow.createCell(6 + rm);
                forCell6.setCellValue("调整金额");
                forCell6.setCellStyle(headStyle);
                Cell forCell7 = forRow.createCell(7 + rm);
                forCell7.setCellValue("结算笔数");
                forCell7.setCellStyle(headStyle);
                Cell forCell8 = forRow.createCell(8 + rm);
                forCell8.setCellValue("结算金额");
                forCell8.setCellStyle(headStyle);
                if(i == 1){
                    Cell forCell17 = forRow.createCell(17);
                    forCell17.setCellValue("结算笔数");
                    forCell17.setCellStyle(headStyle);
                    Cell forCell18 = forRow.createCell(18);
                    forCell18.setCellValue("结算金额");
                    forCell18.setCellStyle(headStyle);
                }
                rm = rm + 8;
            }
            JSONArray rows =  this.jsonObject.getJSONArray("rows");
            int totPages = this.jsonObject.getIntValue("totPages_01");
            int rowNum = 5;
            CellStyle commonStyle = this.getCellStyleOfData(book);
            String qgZcTotNum = "0";
            String qgZcTotAmt = "0";
            String qgJfTotNum = "0";
            String qgJfTotAmt = "0";
            String qgTzTotNum = "0";
            String qgTzTotAmt = "0";
            String qgJsTotNum = "0";
            String qgJsTotAmt = "0";
            String shZcTotNum = "0";
            String shZcTotAmt = "0";
            String shJfTotNum = "0";
            String shJfTotAmt = "0";
            String shTzTotNum = "0";
            String shTzTotAmt = "0";
            String shJsTotNum = "0";
            String shJsTotAmt = "0";
            while(this.page <= totPages){
                if(rows != null && rows.size() > 0){
                    for (Object object : rows) {
                        JSONObject tempRowData = (JSONObject) object;
                        Row tempRow = sheet.createRow(rowNum);
                        Cell tempCell0 = tempRow.createCell(0);
                        tempCell0.setCellValue(tempRowData.getString("SETTLE_DATE"));
                        tempCell0.setCellStyle(commonStyle);
                        Cell tempCell1 = tempRow.createCell(1);
                        tempCell1.setCellValue(tempRowData.getBigDecimal("QGZCTOTNUM").longValue());
                        tempCell1.setCellStyle(commonStyle);
                        qgZcTotNum = Arith.add(qgZcTotNum,tempRowData.getString("QGZCTOTNUM"));
                        Cell tempCell2 = tempRow.createCell(2);
                        tempCell2.setCellStyle(commonStyle);
                        tempCell2.setCellValue(tempRowData.getBigDecimal("QGZCTOTAMT").doubleValue());
                        qgZcTotAmt = Arith.add(qgZcTotAmt,tempRowData.getString("QGZCTOTAMT"));
                        Cell tempCell3 = tempRow.createCell(3);
                        tempCell3.setCellStyle(commonStyle);
                        tempCell3.setCellValue(tempRowData.getBigDecimal("QGJFTOTNUM").longValue());
                        qgJfTotNum = Arith.add(qgJfTotNum,tempRowData.getString("QGJFTOTNUM"));
                        Cell tempCell4 = tempRow.createCell(4);
                        tempCell4.setCellStyle(commonStyle);
                        tempCell4.setCellValue(tempRowData.getBigDecimal("QGJFTOTAMT").doubleValue());
                        qgJfTotAmt = Arith.add(qgJfTotAmt,tempRowData.getString("QGJFTOTAMT"));
                        Cell tempCell5 = tempRow.createCell(5);
                        tempCell5.setCellStyle(commonStyle);
                        tempCell5.setCellValue(tempRowData.getBigDecimal("QGTZTOTNUM").longValue());
                        qgTzTotNum = Arith.add(qgTzTotNum,tempRowData.getString("QGTZTOTNUM"));
                        Cell tempCell6 = tempRow.createCell(6);
                        tempCell6.setCellStyle(commonStyle);
                        tempCell6.setCellValue(tempRowData.getBigDecimal("QGTZTOTAMT").doubleValue());
                        qgTzTotAmt = Arith.add(qgTzTotAmt,tempRowData.getString("QGTZTOTAMT"));
                        Cell tempCell7 = tempRow.createCell(7);
                        tempCell7.setCellStyle(commonStyle);
                        tempCell7.setCellValue(Long.valueOf(Arith.add(tempRowData.getString("QGZCTOTNUM"),tempRowData.getString("QGTZTOTNUM"))));
                        qgJsTotNum = Arith.add(qgJsTotNum,Arith.add(tempRowData.getString("QGZCTOTNUM"),tempRowData.getString("QGTZTOTNUM")));
                        Cell tempCell8 = tempRow.createCell(8);
                        tempCell8.setCellStyle(commonStyle);
                        tempCell8.setCellValue(Double.valueOf(Arith.add(tempRowData.getString("QGZCTOTAMT"),tempRowData.getString("QGTZTOTAMT"))));
                        qgJsTotAmt = Arith.add(qgJsTotAmt,Arith.add(tempRowData.getString("QGZCTOTAMT"),tempRowData.getString("QGTZTOTAMT")));
                        Cell tempCell9 = tempRow.createCell(9);
                        tempCell9.setCellValue(tempRowData.getBigDecimal("SHZCTOTNUM").longValue());
                        shZcTotNum = Arith.add(shZcTotNum,tempRowData.getString("SHZCTOTNUM"));
                        tempCell9.setCellStyle(commonStyle);
                        Cell tempCell10 = tempRow.createCell(10);
                        tempCell10.setCellStyle(commonStyle);
                        tempCell10.setCellValue(tempRowData.getBigDecimal("SHZCTOTAMT").doubleValue());
                        shZcTotAmt = Arith.add(shZcTotAmt,tempRowData.getString("SHZCTOTAMT"));
                        Cell tempCell11 = tempRow.createCell(11);
                        tempCell11.setCellStyle(commonStyle);
                        tempCell11.setCellValue(tempRowData.getBigDecimal("SHJFTOTNUM").longValue());
                        shJfTotNum = Arith.add(shJfTotNum,tempRowData.getString("SHJFTOTNUM"));
                        Cell tempCell12 = tempRow.createCell(12);
                        tempCell12.setCellStyle(commonStyle);
                        tempCell12.setCellValue(tempRowData.getBigDecimal("SHJFTOTAMT").doubleValue());
                        shJfTotAmt = Arith.add(shJfTotAmt,tempRowData.getString("SHJFTOTAMT"));
                        Cell tempCell13 = tempRow.createCell(13);
                        tempCell13.setCellStyle(commonStyle);
                        tempCell13.setCellValue(tempRowData.getBigDecimal("SHTZTOTNUM").longValue());
                        shTzTotNum = Arith.add(shTzTotNum,tempRowData.getString("SHTZTOTNUM"));
                        Cell tempCell14 = tempRow.createCell(14);
                        tempCell14.setCellStyle(commonStyle);
                        tempCell14.setCellValue(tempRowData.getBigDecimal("SHTZTOTAMT").doubleValue());
                        shTzTotAmt = Arith.add(shTzTotAmt,tempRowData.getString("SHTZTOTAMT"));
                        Cell tempCell15 = tempRow.createCell(15);
                        tempCell15.setCellStyle(commonStyle);
                        tempCell15.setCellValue(Long.valueOf(Arith.add(tempRowData.getString("SHZCTOTNUM"),tempRowData.getString("SHTZTOTNUM"))));
                        shJsTotNum = Arith.add(shJsTotNum,Arith.add(tempRowData.getString("SHZCTOTNUM"),tempRowData.getString("SHTZTOTNUM")));
                        Cell tempCell16 = tempRow.createCell(16);
                        tempCell16.setCellStyle(commonStyle);
                        tempCell16.setCellValue(Double.valueOf(Arith.add(tempRowData.getString("SHZCTOTAMT"),tempRowData.getString("SHTZTOTAMT"))));
                        shJsTotAmt = Arith.add(shJsTotAmt,Arith.add(tempRowData.getString("SHZCTOTAMT"),tempRowData.getString("SHTZTOTAMT")));
                        Cell tempCell17 = tempRow.createCell(17);
                        tempCell17.setCellStyle(commonStyle);
                        tempCell17.setCellValue(Long.valueOf(Arith.add(Arith.add(tempRowData.getString("QGZCTOTNUM"),tempRowData.getString("QGTZTOTNUM")),Arith.add(tempRowData.getString("SHZCTOTNUM"),tempRowData.getString("SHTZTOTNUM")))));
                        Cell tempCell18 = tempRow.createCell(18);
                        tempCell18.setCellStyle(commonStyle);
                        tempCell18.setCellValue(Double.valueOf(Arith.add(Arith.add(tempRowData.getString("QGZCTOTAMT"),tempRowData.getString("QGTZTOTAMT")),Arith.add(tempRowData.getString("SHZCTOTAMT"),tempRowData.getString("SHTZTOTAMT")))));
                        rowNum++;
                        tempRowData = null;
                    }
                    rows = null;
                }
                this.page += 1;
                if(this.page <= totPages){
                    this.queryYdkBdConsumeStat();
                    if(!Tools.processNull(jsonObject.get("status")).equals("0")){
                        book = null;
                        sheet = null;
                        throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
                    }
                    rows =  this.jsonObject.getJSONArray("rows");
                }
            }
            Row tempRow = sheet.createRow(rowNum);
            Cell taiCell0 = tempRow.createCell(0);
            taiCell0.setCellValue("合计");
            taiCell0.setCellStyle(commonStyle);
            Cell taiCell1 = tempRow.createCell(1);
            taiCell1.setCellValue(Long.valueOf(qgZcTotNum));
            taiCell1.setCellStyle(commonStyle);
            Cell taiCell2 = tempRow.createCell(2);
            taiCell2.setCellValue(Double.valueOf(qgZcTotAmt));
            taiCell2.setCellStyle(commonStyle);
            Cell taiCell3 = tempRow.createCell(3);
            taiCell3.setCellValue(Long.valueOf(qgJfTotNum));
            taiCell3.setCellStyle(commonStyle);
            Cell taiCell4 = tempRow.createCell(4);
            taiCell4.setCellValue(Double.valueOf(qgJfTotAmt));
            taiCell4.setCellStyle(commonStyle);
            Cell taiCell5 = tempRow.createCell(5);
            taiCell5.setCellValue(Long.valueOf(qgTzTotNum));
            taiCell5.setCellStyle(commonStyle);
            Cell taiCell6 = tempRow.createCell(6);
            taiCell6.setCellValue(Double.valueOf(qgTzTotAmt));
            taiCell6.setCellStyle(commonStyle);
            Cell taiCell7 = tempRow.createCell(7);
            taiCell7.setCellStyle(commonStyle);
            taiCell7.setCellValue(Long.valueOf(qgJsTotNum));
            Cell taiCell8 = tempRow.createCell(8);
            taiCell8.setCellValue(Double.valueOf(qgJsTotAmt));
            taiCell8.setCellStyle(commonStyle);
            Cell taiCell9 = tempRow.createCell(9);
            taiCell9.setCellValue(Long.valueOf(shZcTotNum));
            taiCell9.setCellStyle(commonStyle);
            Cell taiCell10 = tempRow.createCell(10);
            taiCell10.setCellValue(Double.valueOf(shZcTotAmt));
            taiCell10.setCellStyle(commonStyle);
            Cell taiCell11 = tempRow.createCell(11);
            taiCell11.setCellValue(Long.valueOf(shJfTotNum));
            taiCell11.setCellStyle(commonStyle);
            Cell taiCell12 = tempRow.createCell(12);
            taiCell12.setCellValue(Double.valueOf(shJfTotAmt));
            taiCell12.setCellStyle(commonStyle);
            Cell taiCell13 = tempRow.createCell(13);
            taiCell13.setCellValue(Long.valueOf(shTzTotNum));
            taiCell13.setCellStyle(commonStyle);
            Cell taiCell14 = tempRow.createCell(14);
            taiCell14.setCellValue(Double.valueOf(shTzTotAmt));
            taiCell14.setCellStyle(commonStyle);
            Cell taiCell15 = tempRow.createCell(15);
            taiCell15.setCellValue(Long.valueOf(shJsTotNum));
            taiCell15.setCellStyle(commonStyle);
            Cell taiCell16 = tempRow.createCell(16);
            taiCell16.setCellValue(Double.valueOf(shJsTotAmt));
            taiCell16.setCellStyle(commonStyle);
            Cell taiCell17 = tempRow.createCell(17);
            taiCell17.setCellValue(Long.valueOf(Arith.add(qgJsTotNum,shJsTotNum)));
            taiCell17.setCellStyle(commonStyle);
            Cell taiCell18 = tempRow.createCell(18);
            taiCell18.setCellValue(Double.valueOf(Arith.add(qgJsTotAmt,shJsTotAmt)));
            taiCell18.setCellStyle(commonStyle);
            sheet.autoSizeColumn(0,true);
            OutputStream out = this.response.getOutputStream();
            this.response.setContentType("application/vnd.ms-excel");
            this.response.setCharacterEncoding("UTF-8");
            this.response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode( Constants.APP_REPORT_TITLE + "异地卡本地消费结算统计（" + this.beginTime + "--" + this.endTime + "）", "UTF-8") + ".xlsx\"");
            book.write(out);
            SecurityUtils.getSubject().getSession().setAttribute("queryYdkBdConsumeStatExport",Constants.YES_NO_YES);
            out.flush();
        }catch(Exception e){
            this.defaultErrorMsg = e.getMessage();
            return "queryYdkBdConsumeStat";
        }
        return null;
    }

    /**
     * 全国互联互通异地卡本地消费各商户刷卡消费情况统计
     * @return
     */
    public String queryYdkBdConsumeShStat(){
        try{
            this.initBaseDataGrid();
            if(!Tools.processNull(this.queryType).equals("0")){
                return this.JSONOBJ;
            }
            StringBuffer sb = new StringBuffer();
            sb.append("select t.acpt_id,(select m.merchant_name from base_merchant m where m.merchant_id = t.acpt_id) merchant_name,t.settle_date,");
            sb.append("sum((case when t.card_org_id = '0000' and t.refuse_reason = '00' and t.settle_state = '000000' then 1 else 0 end)) qgzctotnum,\n");
            sb.append("sum((case when t.card_org_id = '0000' and t.refuse_reason = '00' and t.settle_state = '000000' then t.deal_amt else 0 end))/100 qgzctotamt,\n");
            sb.append("(select count(1) from pay_offline_union_dt b where b.card_org_id = '0000' and b.acpt_id = t.acpt_id and substr(b.send_file_name,3,6) = substr(replace(t.settle_date,'-',''),3,6) and b.settle_state <> '000000') qgjftotnum,\n");
            sb.append("nvl((select sum(b.deal_amt) from pay_offline_union_dt b where b.card_org_id = '0000' and b.acpt_id = t.acpt_id and substr(b.send_file_name,3,6) = substr(replace(t.settle_date,'-',''),3,6) and b.settle_state <> '000000'),0)/100 qgjftotamt,\n");
            sb.append("sum((case when t.card_org_id = '0000' and t.refuse_reason = '00' and t.settle_state <> '000000' then 1 else 0 end)) qgtztotnum,\n");
            sb.append("sum((case when t.card_org_id = '0000' and t.refuse_reason = '00' and t.settle_state <> '000000' then t.deal_amt else 0 end))/100 qgtztotamt,\n");
            sb.append("'######' 华丽的分割线,");
            sb.append("sum((case when t.card_org_id = '0001' and t.refuse_reason = '00' and t.settle_state = '000000' then 1 else 0 end)) shzctotnum,\n");
            sb.append("sum((case when t.card_org_id = '0001' and t.refuse_reason = '00' and t.settle_state = '000000' then t.deal_amt else 0 end))/100 shzctotamt,\n");
            sb.append("(select count(1) from pay_offline_union_dt b where b.card_org_id = '0001' and b.acpt_id = t.acpt_id and substr(b.send_file_name,3,6) = substr(replace(t.settle_date,'-',''),3,6) and b.settle_state <> '000000') shjftotnum,\n");
            sb.append("nvl((select sum(b.deal_amt) from pay_offline_union_dt b where b.card_org_id = '0001' and b.acpt_id = t.acpt_id and substr(b.send_file_name,3,6) = substr(replace(t.settle_date,'-',''),3,6) and b.settle_state <> '000000'),0)/100 shjftotamt,\n");
            sb.append("sum((case when t.card_org_id = '0001' and t.refuse_reason = '00' and t.settle_state <> '000000' then 1 else 0 end)) shtztotnum,\n");
            sb.append("sum((case when t.card_org_id = '0001' and t.refuse_reason = '00' and t.settle_state <> '000000' then t.deal_amt else 0 end))/100 shtztotamt\n");
            sb.append("from pay_offline_union_dt t ");
            sb.append("where 1 = 1 ");
            if(!Tools.processNull(this.bizId).equals("")){
                sb.append("and t.acpt_id = '" + this.bizId + "' ");
            }
            if(!Tools.processNull(this.beginTime).equals("")){
                sb.append("and t.settle_date >= '" + this.beginTime + "' ");
            }
            if(!Tools.processNull(this.endTime).equals("")){
                sb.append("and t.settle_date <= '" + this.endTime + "' ");
            }
            sb.append("group by t.acpt_id,t.settle_date ");
            if(!Tools.processNull(sort).equals("")){
                String[]tempSorts = sort.split(",");
                String[] tempOrders = order.split(",");
                sb.append("order by ");
                for(int i = 0;i < tempSorts.length;i++){
                    sb.append(tempSorts[i] + " " + tempOrders[i]);
                    if(i != (tempSorts.length - 1)){
                        sb.append(",");
                    }
                    sb.append(" ");
                }
            }else{
                sb.append("order by t.settle_date desc");
            }
            Page pages = baseService.pagingQuery(sb.toString(),page,rows);
            if(pages.getAllRs() == null || pages.getAllRs().size() <= 0){
                throw new CommonException("根据指定信息未查询到对应的结算数据！");
            }else{
                jsonObject.put("rows",pages.getAllRs());
                jsonObject.put("total",pages.getTotalCount());
                jsonObject.put("totPages_01",pages.getTotalPages());
            }
        }catch(Exception e){
            jsonObject.put("status","1");
            jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 全国互联互通异地卡本地消费各商户刷卡消费情况统计导出
     * @return
     */
    public String queryYdkBdConsumeShStatExport(){
        try{
            queryType = "0";
            this.page = 1;
            this.rows = 10000;
            this.queryYdkBdConsumeShStat();
            if(!Tools.processNull(jsonObject.get("status")).equals("0")){
                throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
            }
            //<editor-fold desc="文件设置">
            Workbook book = new SXSSFWorkbook(500);
            Sheet sheet = book.createSheet();
            sheet.setFitToPage(true);
            sheet.createFreezePane(2,5);
            CellRangeAddress titleRegion = new CellRangeAddress(0,0,0,20);
            titleRegion.formatAsString();
            sheet.addMergedRegion(titleRegion);
            CellStyle titleStyle = this.getCellStyleOfTitle(book);
            Row firstRow = sheet.createRow(0);
            firstRow.setHeight((short)(firstRow.getHeight() * 2));
            Cell cell = firstRow.createCell(0);
            cell.setCellValue(Constants.APP_REPORT_TITLE + "异地卡本地消费商户统计");
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
            CellRangeAddress region1 = new CellRangeAddress(1,1,0,20);
            region1.formatAsString();
            sheet.addMergedRegion(region1);
            Row dateRow = sheet.createRow(1);
            Cell dateRow0 = dateRow.createCell(0);
            dateRow0.setCellValue("汇总周期：" + this.beginTime + " —— " + this.endTime + "  制表时间：" + DateUtil.formatDate(baseService.getDateBaseTime(),"yyyy-MM-dd HH:mm:ss"));
            dateRow0.setCellStyle(this.getCellStyleOfDateColumn(book));
            //</editor-fold>
            CellRangeAddress titRegion1 = new CellRangeAddress(2,2,0,1);
            CellRangeAddress titRegion2 = new CellRangeAddress(3,4,0,0);
            CellRangeAddress titRegion2_1 = new CellRangeAddress(3,4,1,1);
            CellRangeAddress titRegion3 = new CellRangeAddress(2,4,2,2);
            CellRangeAddress titRegion4 = new CellRangeAddress(2,2,3,10);
            CellRangeAddress titRegion5 = new CellRangeAddress(2,2,11,18);
            CellRangeAddress titRegion6 = new CellRangeAddress(2,3,19,20);
            CellRangeAddress titRegion7 = new CellRangeAddress(3,3,3,8);
            CellRangeAddress titRegion8 = new CellRangeAddress(3,3,9,10);
            CellRangeAddress titRegion9 = new CellRangeAddress(3,3,11,16);
            CellRangeAddress titRegion10 = new CellRangeAddress(3,3,17,18);
            sheet.addMergedRegion(titRegion1);
            sheet.addMergedRegion(titRegion2);
            sheet.addMergedRegion(titRegion2_1);
            sheet.addMergedRegion(titRegion3);
            sheet.addMergedRegion(titRegion4);
            sheet.addMergedRegion(titRegion5);
            sheet.addMergedRegion(titRegion6);
            sheet.addMergedRegion(titRegion7);
            sheet.addMergedRegion(titRegion8);
            sheet.addMergedRegion(titRegion9);
            sheet.addMergedRegion(titRegion10);
            //<editor-fold desc="设置头部">
            Row secRow = sheet.createRow(2);
            for(int d = 0;d <= 20; d++){
                secRow.createCell(d).setCellStyle(headStyle);
            }
            Cell secCell0 = secRow.createCell(0);
            secCell0.setCellValue("商户信息");
            secCell0.setCellStyle(headStyle);
            Cell secCell2 = secRow.createCell(2);
            secCell2.setCellValue("结算日期");
            secCell2.setCellStyle(headStyle);
            Cell secCell3 = secRow.createCell(3);
            secCell3.setCellValue("全国");
            secCell3.setCellStyle(headStyle);
            Cell secCell4 = secRow.createCell(11);
            secCell4.setCellValue("上海");
            secCell4.setCellStyle(headStyle);
            Cell secCell5 = secRow.createCell(19);
            secCell5.setCellValue("总合计");
            secCell5.setCellStyle(headStyle);
            Row thiRow = sheet.createRow(3);
            Cell thiCell_2 = thiRow.createCell(0);
            thiCell_2.setCellValue("商户编号");
            thiCell_2.setCellStyle(headStyle);
            Cell thiCell_1 = thiRow.createCell(1);
            thiCell_1.setCellValue("商户名称");
            thiCell_1.setCellStyle(headStyle);
            Cell thiCell0 = thiRow.createCell(3);
            thiCell0.setCellValue("结算数据");
            thiCell0.setCellStyle(headStyle);
            Cell thiCell7 = thiRow.createCell(9);
            thiCell7.setCellValue("小计");
            thiCell7.setCellStyle(headStyle);
            Cell thiCell9 = thiRow.createCell(11);
            thiCell9.setCellValue("结算数据");
            thiCell9.setCellStyle(headStyle);
            Cell thiCell15 = thiRow.createCell(17);
            thiCell15.setCellValue("小计");
            thiCell15.setCellStyle(headStyle);
            Row forRow = sheet.createRow(4);
            forRow.createCell(0).setCellStyle(headStyle);
            forRow.createCell(1).setCellStyle(headStyle);
            forRow.createCell(2).setCellStyle(headStyle);
            thiRow.createCell(19).setCellStyle(headStyle);
            thiRow.createCell(20).setCellStyle(headStyle);
            int rm = 2;
            for(int i = 0;i < 2;i++){
                Cell forCell1 = forRow.createCell(1 + rm);
                forCell1.setCellValue("正常笔数");
                forCell1.setCellStyle(headStyle);
                Cell forCell2 = forRow.createCell(2 + rm);
                forCell2.setCellValue("正常金额");
                forCell2.setCellStyle(headStyle);
                Cell forCell3 = forRow.createCell(3 + rm);
                forCell3.setCellValue("拒付笔数");
                forCell3.setCellStyle(headStyle);
                Cell forCell4 = forRow.createCell(4 + rm);
                forCell4.setCellValue("拒付金额");
                forCell4.setCellStyle(headStyle);
                Cell forCell5 = forRow.createCell(5 + rm);
                forCell5.setCellValue("调整笔数");
                forCell5.setCellStyle(headStyle);
                Cell forCell6 = forRow.createCell(6 + rm);
                forCell6.setCellValue("调整金额");
                forCell6.setCellStyle(headStyle);
                Cell forCell7 = forRow.createCell(7 + rm);
                forCell7.setCellValue("结算笔数");
                forCell7.setCellStyle(headStyle);
                Cell forCell8 = forRow.createCell(8 + rm);
                forCell8.setCellValue("结算金额");
                forCell8.setCellStyle(headStyle);
                if(i == 1){
                    Cell forCell17 = forRow.createCell(19);
                    forCell17.setCellValue("结算笔数");
                    forCell17.setCellStyle(headStyle);
                    Cell forCell18 = forRow.createCell(20);
                    forCell18.setCellValue("结算金额");
                    forCell18.setCellStyle(headStyle);
                }
                rm = rm + 8;
            }
            //</editor-fold>
            JSONArray rows =  this.jsonObject.getJSONArray("rows");
            int totPages = this.jsonObject.getIntValue("totPages_01");
            int rowNum = 5;
            CellStyle commonStyle = this.getCellStyleOfData(book);
            String qgZcTotNum = "0";
            String qgZcTotAmt = "0";
            String qgJfTotNum = "0";
            String qgJfTotAmt = "0";
            String qgTzTotNum = "0";
            String qgTzTotAmt = "0";
            String qgJsTotNum = "0";
            String qgJsTotAmt = "0";
            String shZcTotNum = "0";
            String shZcTotAmt = "0";
            String shJfTotNum = "0";
            String shJfTotAmt = "0";
            String shTzTotNum = "0";
            String shTzTotAmt = "0";
            String shJsTotNum = "0";
            String shJsTotAmt = "0";
            int tempHbNum = 0;
            String tempHbVal = "";
            while(this.page <= totPages){
                if(rows != null && rows.size() > 0){
                    JSONObject js = new JSONObject();
                    rows.add(js);
                    for (Object object : rows) {
                        JSONObject tempRowData = (JSONObject) object;
                        if(Tools.processNull(tempRowData.getString("SETTLE_DATE")).equals(tempHbVal)){
                            tempHbNum++;
                        }else{
                            if(tempHbNum > 0){
                                CellRangeAddress tempDataRegion = new CellRangeAddress(rowNum - 1 - tempHbNum, rowNum - 1, 2, 2);
                                sheet.addMergedRegion(tempDataRegion);
                            }
                            tempHbNum = 0;
                            tempHbVal = tempRowData.getString("SETTLE_DATE");
                        }
                        if(Tools.processNull(tempRowData.getString("SETTLE_DATE")).equals("")){
                            continue;
                        }
                        //<editor-fold desc="数据行设置">
                        Row tempRow = sheet.createRow(rowNum);
                        Cell tempCell_2 = tempRow.createCell(0);
                        tempCell_2.setCellValue(tempRowData.getString("ACPT_ID"));
                        tempCell_2.setCellStyle(commonStyle);
                        Cell tempCell_1 = tempRow.createCell(1);
                        tempCell_1.setCellValue(tempRowData.getString("MERCHANT_NAME"));
                        tempCell_1.setCellStyle(commonStyle);
                        Cell tempCell0 = tempRow.createCell(2);
                        tempCell0.setCellValue(tempRowData.getString("SETTLE_DATE"));
                        tempCell0.setCellStyle(commonStyle);
                        Cell tempCell1 = tempRow.createCell(3);
                        tempCell1.setCellValue(tempRowData.getBigDecimal("QGZCTOTNUM").longValue());
                        tempCell1.setCellStyle(commonStyle);
                        qgZcTotNum = Arith.add(qgZcTotNum,tempRowData.getString("QGZCTOTNUM"));
                        Cell tempCell2 = tempRow.createCell(4);
                        tempCell2.setCellStyle(commonStyle);
                        tempCell2.setCellValue(tempRowData.getBigDecimal("QGZCTOTAMT").doubleValue());
                        qgZcTotAmt = Arith.add(qgZcTotAmt,tempRowData.getString("QGZCTOTAMT"));
                        Cell tempCell3 = tempRow.createCell(5);
                        tempCell3.setCellStyle(commonStyle);
                        tempCell3.setCellValue(tempRowData.getBigDecimal("QGJFTOTNUM").longValue());
                        qgJfTotNum = Arith.add(qgJfTotNum,tempRowData.getString("QGJFTOTNUM"));
                        Cell tempCell4 = tempRow.createCell(6);
                        tempCell4.setCellStyle(commonStyle);
                        tempCell4.setCellValue(tempRowData.getBigDecimal("QGJFTOTAMT").doubleValue());
                        qgJfTotAmt = Arith.add(qgJfTotAmt,tempRowData.getString("QGJFTOTAMT"));
                        Cell tempCell5 = tempRow.createCell(7);
                        tempCell5.setCellStyle(commonStyle);
                        tempCell5.setCellValue(tempRowData.getBigDecimal("QGTZTOTNUM").longValue());
                        qgTzTotNum = Arith.add(qgTzTotNum,tempRowData.getString("QGTZTOTNUM"));
                        Cell tempCell6 = tempRow.createCell(8);
                        tempCell6.setCellStyle(commonStyle);
                        tempCell6.setCellValue(tempRowData.getBigDecimal("QGTZTOTAMT").doubleValue());
                        qgTzTotAmt = Arith.add(qgTzTotAmt,tempRowData.getString("QGTZTOTAMT"));
                        Cell tempCell7 = tempRow.createCell(9);
                        tempCell7.setCellStyle(commonStyle);
                        tempCell7.setCellValue(Long.valueOf(Arith.add(tempRowData.getString("QGZCTOTNUM"),tempRowData.getString("QGTZTOTNUM"))));
                        qgJsTotNum = Arith.add(qgJsTotNum,Arith.add(tempRowData.getString("QGZCTOTNUM"),tempRowData.getString("QGTZTOTNUM")));
                        Cell tempCell8 = tempRow.createCell(10);
                        tempCell8.setCellStyle(commonStyle);
                        tempCell8.setCellValue(Double.valueOf(Arith.add(tempRowData.getString("QGZCTOTAMT"),tempRowData.getString("QGTZTOTAMT"))));
                        qgJsTotAmt = Arith.add(qgJsTotAmt,Arith.add(tempRowData.getString("QGZCTOTAMT"),tempRowData.getString("QGTZTOTAMT")));
                        Cell tempCell9 = tempRow.createCell(11);
                        tempCell9.setCellValue(tempRowData.getBigDecimal("SHZCTOTNUM").longValue());
                        shZcTotNum = Arith.add(shZcTotNum,tempRowData.getString("SHZCTOTNUM"));
                        tempCell9.setCellStyle(commonStyle);
                        Cell tempCell10 = tempRow.createCell(12);
                        tempCell10.setCellStyle(commonStyle);
                        tempCell10.setCellValue(tempRowData.getBigDecimal("SHZCTOTAMT").doubleValue());
                        shZcTotAmt = Arith.add(shZcTotAmt,tempRowData.getString("SHZCTOTAMT"));
                        Cell tempCell11 = tempRow.createCell(13);
                        tempCell11.setCellStyle(commonStyle);
                        tempCell11.setCellValue(tempRowData.getBigDecimal("SHJFTOTNUM").longValue());
                        shJfTotNum = Arith.add(shJfTotNum,tempRowData.getString("SHJFTOTNUM"));
                        Cell tempCell12 = tempRow.createCell(14);
                        tempCell12.setCellStyle(commonStyle);
                        tempCell12.setCellValue(tempRowData.getBigDecimal("SHJFTOTAMT").doubleValue());
                        shJfTotAmt = Arith.add(shJfTotAmt,tempRowData.getString("SHJFTOTAMT"));
                        Cell tempCell13 = tempRow.createCell(15);
                        tempCell13.setCellStyle(commonStyle);
                        tempCell13.setCellValue(tempRowData.getBigDecimal("SHTZTOTNUM").longValue());
                        shTzTotNum = Arith.add(shTzTotNum,tempRowData.getString("SHTZTOTNUM"));
                        Cell tempCell14 = tempRow.createCell(16);
                        tempCell14.setCellStyle(commonStyle);
                        tempCell14.setCellValue(tempRowData.getBigDecimal("SHTZTOTAMT").doubleValue());
                        shTzTotAmt = Arith.add(shTzTotAmt,tempRowData.getString("SHTZTOTAMT"));
                        Cell tempCell15 = tempRow.createCell(17);
                        tempCell15.setCellStyle(commonStyle);
                        tempCell15.setCellValue(Long.valueOf(Arith.add(tempRowData.getString("SHZCTOTNUM"),tempRowData.getString("SHTZTOTNUM"))));
                        shJsTotNum = Arith.add(shJsTotNum,Arith.add(tempRowData.getString("SHZCTOTNUM"),tempRowData.getString("SHTZTOTNUM")));
                        Cell tempCell16 = tempRow.createCell(18);
                        tempCell16.setCellStyle(commonStyle);
                        tempCell16.setCellValue(Double.valueOf(Arith.add(tempRowData.getString("SHZCTOTAMT"),tempRowData.getString("SHTZTOTAMT"))));
                        shJsTotAmt = Arith.add(shJsTotAmt,Arith.add(tempRowData.getString("SHZCTOTAMT"),tempRowData.getString("SHTZTOTAMT")));
                        Cell tempCell17 = tempRow.createCell(19);
                        tempCell17.setCellStyle(commonStyle);
                        tempCell17.setCellValue(Long.valueOf(Arith.add(Arith.add(tempRowData.getString("QGZCTOTNUM"),tempRowData.getString("QGTZTOTNUM")),Arith.add(tempRowData.getString("SHZCTOTNUM"),tempRowData.getString("SHTZTOTNUM")))));
                        Cell tempCell18 = tempRow.createCell(20);
                        tempCell18.setCellStyle(commonStyle);
                        tempCell18.setCellValue(Double.valueOf(Arith.add(Arith.add(tempRowData.getString("QGZCTOTAMT"),tempRowData.getString("QGTZTOTAMT")),Arith.add(tempRowData.getString("SHZCTOTAMT"),tempRowData.getString("SHTZTOTAMT")))));
                        rowNum++;
                        tempRowData = null;
                        //</editor-fold>
                    }
                    rows = null;
                }
                //<editor-fold desc="分页设置">
                this.page += 1;
                if(this.page <= totPages){
                    this.queryYdkBdConsumeShStat();
                    if(!Tools.processNull(jsonObject.get("status")).equals("0")){
                        book = null;
                        sheet = null;
                        throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
                    }
                    rows =  this.jsonObject.getJSONArray("rows");
                }
                //</editor-fold>
            }
            //<editor-fold desc="尾行设置">
            CellRangeAddress taiRegion0 = new CellRangeAddress(rowNum,rowNum,0,2);
            sheet.addMergedRegion(taiRegion0);
            Row tempRow = sheet.createRow(rowNum);
            Cell taiCell0 = tempRow.createCell(0);
            taiCell0.setCellValue("合计");
            taiCell0.setCellStyle(commonStyle);
            tempRow.createCell(1).setCellStyle(commonStyle);
            tempRow.createCell(2).setCellStyle(commonStyle);
            Cell taiCell1 = tempRow.createCell(3);
            taiCell1.setCellValue(Long.valueOf(qgZcTotNum));
            taiCell1.setCellStyle(commonStyle);
            Cell taiCell2 = tempRow.createCell(4);
            taiCell2.setCellValue(Double.valueOf(qgZcTotAmt));
            taiCell2.setCellStyle(commonStyle);
            Cell taiCell3 = tempRow.createCell(5);
            taiCell3.setCellValue(Long.valueOf(qgJfTotNum));
            taiCell3.setCellStyle(commonStyle);
            Cell taiCell4 = tempRow.createCell(6);
            taiCell4.setCellValue(Double.valueOf(qgJfTotAmt));
            taiCell4.setCellStyle(commonStyle);
            Cell taiCell5 = tempRow.createCell(7);
            taiCell5.setCellValue(Long.valueOf(qgTzTotNum));
            taiCell5.setCellStyle(commonStyle);
            Cell taiCell6 = tempRow.createCell(8);
            taiCell6.setCellValue(Double.valueOf(qgTzTotAmt));
            taiCell6.setCellStyle(commonStyle);
            Cell taiCell7 = tempRow.createCell(9);
            taiCell7.setCellStyle(commonStyle);
            taiCell7.setCellValue(Long.valueOf(qgJsTotNum));
            Cell taiCell8 = tempRow.createCell(10);
            taiCell8.setCellValue(Double.valueOf(qgJsTotAmt));
            taiCell8.setCellStyle(commonStyle);
            Cell taiCell9 = tempRow.createCell(11);
            taiCell9.setCellValue(Long.valueOf(shZcTotNum));
            taiCell9.setCellStyle(commonStyle);
            Cell taiCell10 = tempRow.createCell(12);
            taiCell10.setCellValue(Double.valueOf(shZcTotAmt));
            taiCell10.setCellStyle(commonStyle);
            Cell taiCell11 = tempRow.createCell(13);
            taiCell11.setCellValue(Long.valueOf(shJfTotNum));
            taiCell11.setCellStyle(commonStyle);
            Cell taiCell12 = tempRow.createCell(14);
            taiCell12.setCellValue(Double.valueOf(shJfTotAmt));
            taiCell12.setCellStyle(commonStyle);
            Cell taiCell13 = tempRow.createCell(15);
            taiCell13.setCellValue(Long.valueOf(shTzTotNum));
            taiCell13.setCellStyle(commonStyle);
            Cell taiCell14 = tempRow.createCell(16);
            taiCell14.setCellValue(Double.valueOf(shTzTotAmt));
            taiCell14.setCellStyle(commonStyle);
            Cell taiCell15 = tempRow.createCell(17);
            taiCell15.setCellValue(Long.valueOf(shJsTotNum));
            taiCell15.setCellStyle(commonStyle);
            Cell taiCell16 = tempRow.createCell(18);
            taiCell16.setCellValue(Double.valueOf(shJsTotAmt));
            taiCell16.setCellStyle(commonStyle);
            Cell taiCell17 = tempRow.createCell(19);
            taiCell17.setCellValue(Long.valueOf(Arith.add(qgJsTotNum,shJsTotNum)));
            taiCell17.setCellStyle(commonStyle);
            Cell taiCell18 = tempRow.createCell(20);
            taiCell18.setCellValue(Double.valueOf(Arith.add(qgJsTotAmt,shJsTotAmt)));
            taiCell18.setCellStyle(commonStyle);
            sheet.autoSizeColumn(0,true);
            sheet.autoSizeColumn(1,true);
            //</editor-fold>
            OutputStream out = this.response.getOutputStream();
            this.response.setContentType("application/vnd.ms-excel");
            this.response.setCharacterEncoding("UTF-8");
            this.response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode( Constants.APP_REPORT_TITLE + "异地卡本地消费商户统计（" + this.beginTime + "--" + this.endTime + "）", "UTF-8") + ".xlsx\"");
            book.write(out);
            SecurityUtils.getSubject().getSession().setAttribute("queryYdkBdConsumeShStatExport",Constants.YES_NO_YES);
            out.flush();
        }catch(Exception e){
            this.defaultErrorMsg = e.getMessage();
            return "queryYdkBdConsumeShStat";
        }
        return null;
    }

    /**
     * 互联互通本地卡异地消费统计
     * @return
     */
    public String queryBdkYdConsumeStat(){
        try{
            this.initBaseDataGrid();
            if(!Tools.processNull(this.queryType).equals("0")){
                return this.JSONOBJ;
            }
            StringBuffer sb = new StringBuffer();
            sb.append("select t.settle_date settle_date,t.clr_date,");
            sb.append("sum(decode(t.trans_city_code,'2000',0,1)) qgzctotnum,");
            sb.append("sum(decode(t.trans_city_code,'2000',0,t.DEAL_AMT))/100 qgzctotamt,");
            sb.append("sum(decode(t.trans_city_code,'2000',1,0)) shzctotnum,");
            sb.append("sum(decode(t.trans_city_code,'2000',t.deal_amt,0))/100 shzctotamt ");
            //sb.append("count(1) 总笔数,sum(t.deal_amt) 总金额 ");
            sb.append("from pay_offline_union_df t where 1 = 1 ");
            if(!Tools.processNull(this.beginTime).equals("")){
                sb.append("and t.settle_date >= '" + this.beginTime + "' ");
            }
            if(!Tools.processNull(this.endTime).equals("")){
                sb.append("and t.settle_date <= '" + this.endTime + "' ");
            }
            if(!Tools.processNull(this.clrBeginTime).equals("")){
                sb.append("and t.clr_date >= '" + this.clrBeginTime + "' ");
            }
            if(!Tools.processNull(this.clrEndTime).equals("")){
                sb.append("and t.clr_date <= '" + this.clrEndTime + "' ");
            }
            sb.append("group by t.settle_date,t.clr_date ");
            if(!Tools.processNull(sort).equals("")){
                String[]tempSorts = sort.split(",");
                String[] tempOrders = order.split(",");
                sb.append("order by ");
                for(int i = 0;i < tempSorts.length;i++){
                    sb.append(tempSorts[i] + " " + tempOrders[i]);
                    if(i != (tempSorts.length - 1)){
                        sb.append(",");
                    }
                    sb.append(" ");
                }
            }else{
                sb.append("order by t.settle_date desc");
            }
            Page pages = baseService.pagingQuery(sb.toString(),page,rows);
            if(pages.getAllRs() == null || pages.getAllRs().size() <= 0){
                throw new CommonException("根据指定信息未查询到对应的结算数据！");
            }else{
                jsonObject.put("rows",pages.getAllRs());
                jsonObject.put("total",pages.getTotalCount());
                jsonObject.put("totPages_01",pages.getTotalPages());
            }
        }catch(Exception e){
            jsonObject.put("status","1");
            jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 互联互通本地卡异地消费统计导出
     * @return
     */
    public String queryBdkYdConsumeStatExport(){
        try{
            queryType = "0";
            this.page = 1;
            this.rows = 10000;
            this.queryBdkYdConsumeStat();
            if(!Tools.processNull(jsonObject.get("status")).equals("0")){
                throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
            }
            Workbook book = new SXSSFWorkbook(500);
            Sheet sheet = book.createSheet();
            sheet.setFitToPage(true);
            sheet.createFreezePane(0,4);
            CellRangeAddress titleRegion = new CellRangeAddress(0,0,0,7);
            titleRegion.formatAsString();
            sheet.addMergedRegion(titleRegion);
            CellStyle titleStyle = this.getCellStyleOfTitle(book);
            Row firstRow = sheet.createRow(0);
            firstRow.setHeight((short)(firstRow.getHeight() * 2));
            Cell cell = firstRow.createCell(0);
            cell.setCellValue(Constants.APP_REPORT_TITLE + "本地卡异地消费统计");
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
            CellRangeAddress region1 = new CellRangeAddress(1,1,0,7);
            region1.formatAsString();
            sheet.addMergedRegion(region1);
            Row dateRow = sheet.createRow(1);
            Cell dateRow0 = dateRow.createCell(0);
            String string = "";
            if(!Tools.processNull(this.beginTime).equals("") || !Tools.processNull(this.endTime).equals("")){
            	string += "结算日期：" + beginTime + " ~ " + endTime + "    ";
            }
            if(!Tools.processNull(this.clrBeginTime).equals("") || !Tools.processNull(this.clrEndTime).equals("")){
            	string += "清分日期：" + clrBeginTime + " ~ " + clrEndTime + "    ";
            }
			string += "制表时间：" + DateUtil.formatDate(baseService.getDateBaseTime(), "yyyy-MM-dd HH:mm:ss");
            dateRow0.setCellValue(string);
            dateRow0.setCellStyle(this.getCellStyleOfDateColumn(book));
            CellRangeAddress titRegion1 = new CellRangeAddress(2,3,0,0);
            CellRangeAddress titRegion2 = new CellRangeAddress(2,3,1,1);
            CellRangeAddress titRegion3 = new CellRangeAddress(2,2,2,3);
            CellRangeAddress titRegion4 = new CellRangeAddress(2,2,4,5);
            CellRangeAddress titRegion5 = new CellRangeAddress(2,2,6,7);
            sheet.addMergedRegion(titRegion1);
            sheet.addMergedRegion(titRegion2);
            sheet.addMergedRegion(titRegion3);
            sheet.addMergedRegion(titRegion4);
            sheet.addMergedRegion(titRegion5);
            Row secRow = sheet.createRow(2);
            for(int d = 0;d <= 7; d++){
                secRow.createCell(d).setCellStyle(headStyle);
            }
            Cell secCell0 = secRow.createCell(0);
            secCell0.setCellValue("结算日期");
            secCell0.setCellStyle(headStyle);
            Cell secCell2 = secRow.createCell(1);
            secCell2.setCellValue("清分日期");
            secCell2.setCellStyle(headStyle);
            Cell secCell3 = secRow.createCell(2);
            secCell3.setCellValue("全国");
            secCell3.setCellStyle(headStyle);
            Cell secCell4 = secRow.createCell(4);
            secCell4.setCellValue("上海");
            secCell4.setCellStyle(headStyle);
            Cell secCell5 = secRow.createCell(6);
            secCell5.setCellValue("总合计");
            secCell5.setCellStyle(headStyle);
            Row thiRow = sheet.createRow(3);
            thiRow.createCell(0).setCellStyle(headStyle);
            thiRow.createCell(1).setCellStyle(headStyle);
            Cell thiCell0 = thiRow.createCell(2);
            thiCell0.setCellValue("笔数");
            thiCell0.setCellStyle(headStyle);
            Cell thiCell1 = thiRow.createCell(3);
            thiCell1.setCellValue("金额");
            thiCell1.setCellStyle(headStyle);
            Cell thiCell4 = thiRow.createCell(4);
            thiCell4.setCellValue("笔数");
            thiCell4.setCellStyle(headStyle);
            Cell thiCell5 = thiRow.createCell(5);
            thiCell5.setCellValue("金额");
            thiCell5.setCellStyle(headStyle);
            Cell thiCell6 = thiRow.createCell(6);
            thiCell6.setCellValue("笔数");
            thiCell6.setCellStyle(headStyle);
            Cell thiCell7 = thiRow.createCell(7);
            thiCell7.setCellValue("金额");
            thiCell7.setCellStyle(headStyle);
            JSONArray rows =  this.jsonObject.getJSONArray("rows");
            int totPages = this.jsonObject.getIntValue("totPages_01");
            int rowNum = 4;
            CellStyle commonStyle = this.getCellStyleOfData(book);
            String qgTotNum = "0";
            String qgTotAmt = "0";
            String shTotNum = "0";
            String shTotAmt = "0";
            String jsTotNum = "0";
            String jsTotAmt = "0";
            while(this.page <= totPages){
                if(rows != null && rows.size() > 0){
                    for (Object object : rows) {
                        JSONObject tempRowData = (JSONObject) object;
                        Row tempRow = sheet.createRow(rowNum);
                        Cell tempCell0 = tempRow.createCell(0);
                        tempCell0.setCellValue(tempRowData.getString("SETTLE_DATE"));
                        tempCell0.setCellStyle(commonStyle);
                        Cell tempCell0_1 = tempRow.createCell(1);
                        tempCell0_1.setCellValue(tempRowData.getString("CLR_DATE"));
                        tempCell0_1.setCellStyle(commonStyle);
                        Cell tempCell1 = tempRow.createCell(2);
                        tempCell1.setCellValue(tempRowData.getBigDecimal("QGZCTOTNUM").longValue());
                        tempCell1.setCellStyle(commonStyle);
                        qgTotNum = Arith.add(qgTotNum,tempRowData.getString("QGZCTOTNUM"));
                        Cell tempCell2 = tempRow.createCell(3);
                        tempCell2.setCellStyle(commonStyle);
                        tempCell2.setCellValue(tempRowData.getBigDecimal("QGZCTOTAMT").doubleValue());
                        qgTotAmt = Arith.add(qgTotAmt,tempRowData.getString("QGZCTOTAMT"));
                        Cell tempCell9 = tempRow.createCell(4);
                        tempCell9.setCellValue(tempRowData.getBigDecimal("SHZCTOTNUM").longValue());
                        tempCell9.setCellStyle(commonStyle);
                        shTotNum = Arith.add(shTotNum,tempRowData.getString("SHZCTOTNUM"));
                        Cell tempCell10 = tempRow.createCell(5);
                        tempCell10.setCellValue(tempRowData.getBigDecimal("SHZCTOTAMT").doubleValue());
                        tempCell10.setCellStyle(commonStyle);
                        shTotAmt = Arith.add(shTotAmt,tempRowData.getString("SHZCTOTAMT"));
                        Cell tempCell15 = tempRow.createCell(6);
                        tempCell15.setCellStyle(commonStyle);
                        tempCell15.setCellValue(Long.valueOf(Arith.add(tempRowData.getString("QGZCTOTNUM"),tempRowData.getString("SHZCTOTNUM"))));
                        jsTotNum = Arith.add(jsTotNum,Arith.add(tempRowData.getString("QGZCTOTNUM"),tempRowData.getString("SHZCTOTNUM")));
                        Cell tempCell16 = tempRow.createCell(7);
                        tempCell16.setCellStyle(commonStyle);
                        tempCell16.setCellValue(Double.valueOf(Arith.add(tempRowData.getString("QGZCTOTAMT"),tempRowData.getString("SHZCTOTAMT"))));
                        jsTotAmt = Arith.add(jsTotAmt,Arith.add(tempRowData.getString("QGZCTOTAMT"),tempRowData.getString("SHZCTOTAMT")));
                        rowNum++;
                        tempRowData = null;
                    }
                    rows = null;
                }
                this.page += 1;
                if(this.page <= totPages){
                    this.queryBdkYdConsumeStat();
                    if(!Tools.processNull(jsonObject.get("status")).equals("0")){
                        book = null;
                        sheet = null;
                        throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
                    }
                    rows =  this.jsonObject.getJSONArray("rows");
                }
            }
            CellRangeAddress taiRegion0 = new CellRangeAddress(rowNum,rowNum,0,1);
            sheet.addMergedRegion(taiRegion0);
            Row tempRow = sheet.createRow(rowNum);
            Cell taiCell0 = tempRow.createCell(0);
            taiCell0.setCellValue("合计");
            taiCell0.setCellStyle(commonStyle);
            tempRow.createCell(1).setCellStyle(commonStyle);
            Cell taiCell1 = tempRow.createCell(2);
            taiCell1.setCellValue(Long.valueOf(qgTotNum));
            taiCell1.setCellStyle(commonStyle);
            Cell taiCell2 = tempRow.createCell(3);
            taiCell2.setCellValue(Double.valueOf(qgTotAmt));
            taiCell2.setCellStyle(commonStyle);
            Cell taiCell3 = tempRow.createCell(4);
            taiCell3.setCellValue(Long.valueOf(shTotNum));
            taiCell3.setCellStyle(commonStyle);
            Cell taiCell4 = tempRow.createCell(5);
            taiCell4.setCellValue(Double.valueOf(shTotAmt));
            taiCell4.setCellStyle(commonStyle);
            Cell taiCell5 = tempRow.createCell(6);
            taiCell5.setCellValue(Long.valueOf(jsTotNum));
            taiCell5.setCellStyle(commonStyle);
            Cell taiCell6 = tempRow.createCell(7);
            taiCell6.setCellValue(Double.valueOf(jsTotAmt));
            taiCell6.setCellStyle(commonStyle);
            OutputStream out = this.response.getOutputStream();
            this.response.setContentType("application/vnd.ms-excel");
            this.response.setCharacterEncoding("UTF-8");
            this.response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode( Constants.APP_REPORT_TITLE + "本地卡异地消费统计（" + this.beginTime + "--" + this.endTime + "）", "UTF-8") + ".xlsx\"");
            book.write(out);
            SecurityUtils.getSubject().getSession().setAttribute("queryBdkYdConsumeStatExport",Constants.YES_NO_YES);
            out.flush();
        }catch(Exception e){
            this.defaultErrorMsg = e.getMessage();
            return "queryBdkYdConsumeStat";
        }
        return null;
    }

    /**
     * 互联互通各发卡机构本地卡异地消费情况统计
     * @return
     */
    public String queryBdkYdConsumeShStat(){
        try{
            this.initBaseDataGrid();
            if(!Tools.processNull(this.queryType).equals("0")){
                return this.JSONOBJ;
            }
            StringBuffer sb = new StringBuffer();
            sb.append("select t.settle_date,t.clr_date,t.card_org_id,(select s.card_org_name from card_org_bind_section s where s.card_org_id = t.card_org_id and rownum = 1) card_org_name,");
            sb.append("sum(decode(t.trans_city_code,'2000',0,1)) qgzctotnum,");
            sb.append("sum(decode(t.trans_city_code,'2000',0,t.DEAL_AMT))/100 qgzctotamt,");
            sb.append("sum(decode(t.trans_city_code,'2000',1,0)) shzctotnum,");
            sb.append("sum(decode(t.trans_city_code,'2000',t.deal_amt,0))/100 shzctotamt ");
            //sb.append("count(1) 总笔数,sum(t.deal_amt) 总金额 ");
            sb.append("from pay_offline_union_df t where 1 = 1 ");
            if(!Tools.processNull(this.bizId).equals("")){
                sb.append("and t.card_org_id = '" + this.bizId + "' ");
            }
            if(!Tools.processNull(this.beginTime).equals("")){
                sb.append("and t.settle_date >= '" + this.beginTime + "' ");
            }
            if(!Tools.processNull(this.endTime).equals("")){
                sb.append("and t.settle_date <= '" + this.endTime + "' ");
            }
            if(!Tools.processNull(this.clrBeginTime).equals("")){
                sb.append("and t.clr_date >= '" + this.clrBeginTime + "' ");
            }
            if(!Tools.processNull(this.clrEndTime).equals("")){
                sb.append("and t.clr_date <= '" + this.clrEndTime + "' ");
            }
            sb.append("group by t.settle_date,t.clr_date,t.card_org_id ");
            if(!Tools.processNull(sort).equals("")){
                String[]tempSorts = sort.split(",");
                String[] tempOrders = order.split(",");
                sb.append("order by ");
                for(int i = 0;i < tempSorts.length;i++){
                    sb.append(tempSorts[i] + " " + tempOrders[i]);
                    if(i != (tempSorts.length - 1)){
                        sb.append(",");
                    }
                    sb.append(" ");
                }
            }else{
                sb.append("order by t.settle_date desc");
            }
            Page pages = baseService.pagingQuery(sb.toString(),page,rows);
            if(pages.getAllRs() == null || pages.getAllRs().size() <= 0){
                throw new CommonException("根据指定信息未查询到对应的结算数据！");
            }else{
                jsonObject.put("rows",pages.getAllRs());
                jsonObject.put("total",pages.getTotalCount());
                jsonObject.put("totPages_01",pages.getTotalPages());
            }
        }catch(Exception e){
            jsonObject.put("status","1");
            jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 互联互通各发卡机构本地卡异地消费情况统计导出
     * @return
     */
    public String queryBdkYdConsumeShStatExport(){
        try{
            queryType = "0";
            this.page = 1;
            this.rows = 10000;
            this.queryBdkYdConsumeShStat();
            if(!Tools.processNull(jsonObject.get("status")).equals("0")){
                throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
            }
            //<editor-fold desc="头部基本设置">
            Workbook book = new SXSSFWorkbook(500);
            Sheet sheet = book.createSheet();
            sheet.setFitToPage(true);
            sheet.createFreezePane(0, 4);
            CellRangeAddress titleRegion = new CellRangeAddress(0, 0, 0, 9);
            titleRegion.formatAsString();
            sheet.addMergedRegion(titleRegion);
            CellStyle titleStyle = this.getCellStyleOfTitle(book);
            Row firstRow = sheet.createRow(0);
            firstRow.setHeight((short) (firstRow.getHeight() * 2));
            Cell cell = firstRow.createCell(0);
            cell.setCellValue(Constants.APP_REPORT_TITLE + "本地卡异地消费商户统计");
            cell.setCellStyle(titleStyle);
            Font headerFont = book.createFont();
            headerFont.setFontName("微软雅黑");
            headerFont.setBoldweight((short) (headerFont.getBoldweight() * 2));
            headerFont.setFontHeight((short) (headerFont.getFontHeight() * 0.9));
            headerFont.setColor(HSSFColor.BLUE.index);
            CellStyle headStyle = book.createCellStyle();
            headStyle.setBorderBottom(CellStyle.BORDER_THIN);
            headStyle.setBorderLeft(CellStyle.BORDER_THIN);
            headStyle.setBorderRight(CellStyle.BORDER_THIN);
            headStyle.setBorderTop(CellStyle.BORDER_THIN);
            headStyle.setAlignment(CellStyle.ALIGN_CENTER);
            headStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
            headStyle.setFont(headerFont);
            CellRangeAddress region1 = new CellRangeAddress(1, 1, 0, 9);
            region1.formatAsString();
            sheet.addMergedRegion(region1);
            Row dateRow = sheet.createRow(1);
            Cell dateRow0 = dateRow.createCell(0);
            dateRow0.setCellValue("汇总周期：" + this.beginTime + " —— " + this.endTime + "  制表时间：" + DateUtil.formatDate(baseService.getDateBaseTime(), "yyyy-MM-dd HH:mm:ss"));
            dateRow0.setCellStyle(this.getCellStyleOfDateColumn(book));
            //</editor-fold>
            CellRangeAddress titRegion1 = new CellRangeAddress(2, 3, 0, 0);
            CellRangeAddress titRegion2 = new CellRangeAddress(2, 3, 1, 1);
            CellRangeAddress titRegion3 = new CellRangeAddress(2, 2, 2, 3);
            CellRangeAddress titRegion4 = new CellRangeAddress(2, 2, 4, 5);
            CellRangeAddress titRegion5 = new CellRangeAddress(2, 2, 6, 7);
            CellRangeAddress titRegion6 = new CellRangeAddress(2, 2, 8, 9);
            sheet.addMergedRegion(titRegion1);
            sheet.addMergedRegion(titRegion2);
            sheet.addMergedRegion(titRegion3);
            sheet.addMergedRegion(titRegion4);
            sheet.addMergedRegion(titRegion5);
            sheet.addMergedRegion(titRegion6);
            //<editor-fold desc="表格第三行设置">
            Row secRow = sheet.createRow(2);
            for(int d = 0; d <= 9; d++){
                secRow.createCell(d).setCellStyle(headStyle);
            }
            Cell secCell0 = secRow.createCell(0);
            secCell0.setCellValue("结算日期");
            secCell0.setCellStyle(headStyle);
            Cell secCell2 = secRow.createCell(1);
            secCell2.setCellValue("清分日期");
            secCell2.setCellStyle(headStyle);
            Cell secCell3 = secRow.createCell(2);
            secCell3.setCellValue("发卡机构");
            secCell3.setCellStyle(headStyle);
            Cell secCell4 = secRow.createCell(4);
            secCell4.setCellValue("全国");
            secCell4.setCellStyle(headStyle);
            Cell secCell5 = secRow.createCell(6);
            secCell5.setCellValue("上海");
            secCell5.setCellStyle(headStyle);
            Cell secCell6 = secRow.createCell(8);
            secCell6.setCellValue("总合计");
            secCell6.setCellStyle(headStyle);
            //</editor-fold>
            //<editor-fold desc="表格第四行设置">
            Row thiRow = sheet.createRow(3);
            thiRow.createCell(0).setCellStyle(headStyle);
            thiRow.createCell(1).setCellStyle(headStyle);
            Cell thiCell0 = thiRow.createCell(2);
            thiCell0.setCellValue("机构代码");
            thiCell0.setCellStyle(headStyle);
            Cell thiCell1 = thiRow.createCell(3);
            thiCell1.setCellValue("机构名称");
            thiCell1.setCellStyle(headStyle);
            Cell thiCell4 = thiRow.createCell(4);
            thiCell4.setCellValue("笔数");
            thiCell4.setCellStyle(headStyle);
            Cell thiCell5 = thiRow.createCell(5);
            thiCell5.setCellValue("金额");
            thiCell5.setCellStyle(headStyle);
            Cell thiCell6 = thiRow.createCell(6);
            thiCell6.setCellValue("笔数");
            thiCell6.setCellStyle(headStyle);
            Cell thiCell7 = thiRow.createCell(7);
            thiCell7.setCellValue("金额");
            thiCell7.setCellStyle(headStyle);
            Cell thiCell8 = thiRow.createCell(8);
            thiCell8.setCellValue("笔数");
            thiCell8.setCellStyle(headStyle);
            Cell thiCell9 = thiRow.createCell(9);
            thiCell9.setCellValue("金额");
            thiCell9.setCellStyle(headStyle);
            //</editor-fold>
            JSONArray rows = this.jsonObject.getJSONArray("rows");
            int totPages = this.jsonObject.getIntValue("totPages_01");
            int rowNum = 4;
            CellStyle commonStyle = this.getCellStyleOfData(book);
            String qgTotNum = "0";
            String qgTotAmt = "0";
            String shTotNum = "0";
            String shTotAmt = "0";
            String jsTotNum = "0";
            String jsTotAmt = "0";
            int tempHbNum = 0;
            String tempHbVal = "";
            while(this.page <= totPages){
                if(rows != null && rows.size() > 0){
                    JSONObject js = new JSONObject();
                    rows.add(js);
                    for(Object object : rows){
                        JSONObject tempRowData = (JSONObject) object;
                        //<editor-fold desc="数据设置">
                        if(Tools.processNull(tempRowData.getString("SETTLE_DATE")).equals(tempHbVal)){
                            tempHbNum++;
                        }else{
                            if(tempHbNum > 0){
                                CellRangeAddress tempDataRegion = new CellRangeAddress(rowNum - 1 - tempHbNum, rowNum - 1, 0, 0);
                                sheet.addMergedRegion(tempDataRegion);
                            }
                            tempHbNum = 0;
                            tempHbVal = tempRowData.getString("SETTLE_DATE");
                        }
                        if(Tools.processNull(tempRowData.getString("SETTLE_DATE")).equals("")){
                        	continue;
                        }
                        Row tempRow = sheet.createRow(rowNum);
                        Cell tempCell0 = tempRow.createCell(0);
                        tempCell0.setCellValue(tempRowData.getString("SETTLE_DATE"));
                        tempCell0.setCellStyle(commonStyle);
                        Cell tempCell0_1 = tempRow.createCell(1);
                        tempCell0_1.setCellValue(tempRowData.getString("CLR_DATE"));
                        tempCell0_1.setCellStyle(commonStyle);
                        Cell tempCell_2 = tempRow.createCell(2);
                        tempCell_2.setCellValue(tempRowData.getString("CARD_ORG_ID"));
                        tempCell_2.setCellStyle(commonStyle);
                        Cell tempCell0_3 = tempRow.createCell(3);
                        tempCell0_3.setCellValue(tempRowData.getString("CARD_ORG_NAME"));
                        tempCell0_3.setCellStyle(commonStyle);
                        Cell tempCell1 = tempRow.createCell(4);
                        tempCell1.setCellValue(tempRowData.getBigDecimal("QGZCTOTNUM").longValue());
                        tempCell1.setCellStyle(commonStyle);
                        qgTotNum = Arith.add(qgTotNum, tempRowData.getString("QGZCTOTNUM"));
                        Cell tempCell2 = tempRow.createCell(5);
                        tempCell2.setCellStyle(commonStyle);
                        tempCell2.setCellValue(tempRowData.getBigDecimal("QGZCTOTAMT").doubleValue());
                        qgTotAmt = Arith.add(qgTotAmt, tempRowData.getString("QGZCTOTAMT"));
                        Cell tempCell9 = tempRow.createCell(6);
                        tempCell9.setCellValue(tempRowData.getBigDecimal("SHZCTOTNUM").longValue());
                        tempCell9.setCellStyle(commonStyle);
                        shTotNum = Arith.add(shTotNum, tempRowData.getString("SHZCTOTNUM"));
                        Cell tempCell10 = tempRow.createCell(7);
                        tempCell10.setCellValue(tempRowData.getBigDecimal("SHZCTOTAMT").doubleValue());
                        tempCell10.setCellStyle(commonStyle);
                        shTotAmt = Arith.add(shTotAmt, tempRowData.getString("SHZCTOTAMT"));
                        Cell tempCell15 = tempRow.createCell(8);
                        tempCell15.setCellStyle(commonStyle);
                        tempCell15.setCellValue(Long.valueOf(Arith.add(tempRowData.getString("QGZCTOTNUM"), tempRowData.getString("SHZCTOTNUM"))));
                        jsTotNum = Arith.add(jsTotNum, Arith.add(tempRowData.getString("QGZCTOTNUM"), tempRowData.getString("SHZCTOTNUM")));
                        Cell tempCell16 = tempRow.createCell(9);
                        tempCell16.setCellStyle(commonStyle);
                        tempCell16.setCellValue(Double.valueOf(Arith.add(tempRowData.getString("QGZCTOTAMT"), tempRowData.getString("SHZCTOTAMT"))));
                        jsTotAmt = Arith.add(jsTotAmt, Arith.add(tempRowData.getString("QGZCTOTAMT"), tempRowData.getString("SHZCTOTAMT")));
                        rowNum++;
                        tempRowData = null;
                        //</editor-fold>
                    }
                    rows = null;
                }
                this.page += 1;
                if(this.page <= totPages){
                    this.queryBdkYdConsumeShStat();
                    if(!Tools.processNull(jsonObject.get("status")).equals("0")){
                        book = null;
                        sheet = null;
                        throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
                    }
                    rows = this.jsonObject.getJSONArray("rows");
                }
            }
            sheet.autoSizeColumn(3,true);
            CellRangeAddress taiRegion0 = new CellRangeAddress(rowNum, rowNum, 0, 3);
            sheet.addMergedRegion(taiRegion0);
            //<editor-fold desc="尾行设置">
            Row tempRow = sheet.createRow(rowNum);
            Cell taiCell0 = tempRow.createCell(0);
            taiCell0.setCellValue("合计");
            taiCell0.setCellStyle(commonStyle);
            tempRow.createCell(1).setCellStyle(commonStyle);
            tempRow.createCell(2).setCellStyle(commonStyle);
            tempRow.createCell(3).setCellStyle(commonStyle);
            Cell taiCell1 = tempRow.createCell(4);
            taiCell1.setCellValue(Long.valueOf(qgTotNum));
            taiCell1.setCellStyle(commonStyle);
            Cell taiCell2 = tempRow.createCell(5);
            taiCell2.setCellValue(Double.valueOf(qgTotAmt));
            taiCell2.setCellStyle(commonStyle);
            Cell taiCell3 = tempRow.createCell(6);
            taiCell3.setCellValue(Long.valueOf(shTotNum));
            taiCell3.setCellStyle(commonStyle);
            Cell taiCell4 = tempRow.createCell(7);
            taiCell4.setCellValue(Double.valueOf(shTotAmt));
            taiCell4.setCellStyle(commonStyle);
            Cell taiCell5 = tempRow.createCell(8);
            taiCell5.setCellValue(Long.valueOf(jsTotNum));
            taiCell5.setCellStyle(commonStyle);
            Cell taiCell6 = tempRow.createCell(9);
            taiCell6.setCellValue(Double.valueOf(jsTotAmt));
            taiCell6.setCellStyle(commonStyle);
            //</editor-fold>
            //<editor-fold desc="数据输出">
            OutputStream out = this.response.getOutputStream();
            this.response.setContentType("application/vnd.ms-excel");
            this.response.setCharacterEncoding("UTF-8");
            this.response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode(Constants.APP_REPORT_TITLE + "本地卡异地消费商户统计（" + this.beginTime + "--" + this.endTime + "）", "UTF-8") + ".xlsx\"");
            book.write(out);
            SecurityUtils.getSubject().getSession().setAttribute("queryBdkYdConsumeShStatExport", Constants.YES_NO_YES);
            out.flush();
            //</editor-fold>
        }catch(Exception e){
            this.defaultErrorMsg = e.getMessage();
            return "queryBdkYdConsumeShStat";
        }
        return null;
    }

    /**
     * 互联互通本地卡异地消费本地结算拒付统计
     * @return
     */
    public String queryBdkYdConsumeJfStat(){
        try{
            this.initBaseDataGrid();
            if(!Tools.processNull(this.queryType).equals("0")){
                return this.JSONOBJ;
            }
            StringBuffer sb = new StringBuffer();
            sb.append("select t.clr_date,");
            sb.append("sum(case when t.acpt_id = '100102100101042' then 1 else 0 end) qgjftotnum,");
            sb.append("sum(case when t.acpt_id = '100102100101042' then t.deal_amt else 0 end)/100 qgjftotamt,");
            sb.append("sum(case when t.acpt_id = '100102100101043' then 1 else 0 end) shjftotnum,");
            sb.append("sum(case when t.acpt_id = '100102100101043' then t.deal_amt else 0 end)/100 shjftotamt ");
            sb.append("from pay_offline_black t where t.acpt_id in ('100102100101043','100102100101042') ");
            if(!Tools.processNull(this.beginTime).equals("")){
                sb.append("and t.clr_date >= '" + this.beginTime + "' ");
            }
            if(!Tools.processNull(this.endTime).equals("")){
                sb.append("and t.clr_date <= '" + this.endTime + "' ");
            }
            sb.append("group by t.clr_date ");
            if(!Tools.processNull(sort).equals("")){
                String[]tempSorts = sort.split(",");
                String[] tempOrders = order.split(",");
                sb.append("order by ");
                for(int i = 0;i < tempSorts.length;i++){
                    sb.append(tempSorts[i] + " " + tempOrders[i]);
                    if(i != (tempSorts.length - 1)){
                        sb.append(",");
                    }
                    sb.append(" ");
                }
            }else{
                sb.append("order by t.clr_date desc");
            }
            Page pages = baseService.pagingQuery(sb.toString(),page,rows);
            if(pages.getAllRs() == null || pages.getAllRs().size() <= 0){
                throw new CommonException("根据指定信息未查询到对应的拒付数据！");
            }else{
                jsonObject.put("rows",pages.getAllRs());
                jsonObject.put("total",pages.getTotalCount());
                jsonObject.put("totPages_01",pages.getTotalPages());
            }
        }catch(Exception e){
            jsonObject.put("status","1");
            jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }
    /**
     * 互联互通本地卡异地消费本地结算拒付统计导出
     * @return
     */
    public String queryBdkYdConsumeJfStatExport(){
        try{
            queryType = "0";
            this.page = 1;
            this.rows = 10000;
            this.queryBdkYdConsumeJfStat();
            if(!Tools.processNull(jsonObject.get("status")).equals("0")){
                throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
            }
            //<editor-fold desc="头部基本设置">
            Workbook book = new SXSSFWorkbook(500);
            Sheet sheet = book.createSheet();
            sheet.setFitToPage(true);
            sheet.createFreezePane(0, 4);
            CellRangeAddress titleRegion = new CellRangeAddress(0, 0, 0, 6);
            titleRegion.formatAsString();
            sheet.addMergedRegion(titleRegion);
            CellStyle titleStyle = this.getCellStyleOfTitle(book);
            Row firstRow = sheet.createRow(0);
            firstRow.setHeight((short) (firstRow.getHeight() * 2));
            Cell cell = firstRow.createCell(0);
            cell.setCellValue(Constants.APP_REPORT_TITLE + "本地卡异地消费本地结算拒付统计");
            cell.setCellStyle(titleStyle);
            Font headerFont = book.createFont();
            headerFont.setFontName("微软雅黑");
            headerFont.setBoldweight((short) (headerFont.getBoldweight() * 2));
            headerFont.setFontHeight((short) (headerFont.getFontHeight() * 0.9));
            headerFont.setColor(HSSFColor.BLUE.index);
            CellStyle headStyle = book.createCellStyle();
            headStyle.setBorderBottom(CellStyle.BORDER_THIN);
            headStyle.setBorderLeft(CellStyle.BORDER_THIN);
            headStyle.setBorderRight(CellStyle.BORDER_THIN);
            headStyle.setBorderTop(CellStyle.BORDER_THIN);
            headStyle.setAlignment(CellStyle.ALIGN_CENTER);
            headStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
            headStyle.setFont(headerFont);
            CellRangeAddress region1 = new CellRangeAddress(1, 1, 0, 6);
            region1.formatAsString();
            sheet.addMergedRegion(region1);
            Row dateRow = sheet.createRow(1);
            Cell dateRow0 = dateRow.createCell(0);
            dateRow0.setCellValue("汇总周期：" + this.beginTime + " —— " + this.endTime + "  制表时间：" + DateUtil.formatDate(baseService.getDateBaseTime(), "yyyy-MM-dd HH:mm:ss"));
            dateRow0.setCellStyle(this.getCellStyleOfDateColumn(book));
            //</editor-fold>
            CellRangeAddress titRegion1 = new CellRangeAddress(2, 3, 0, 0);
            CellRangeAddress titRegion2 = new CellRangeAddress(2, 2, 1, 2);
            CellRangeAddress titRegion3 = new CellRangeAddress(2, 2, 3, 4);
            CellRangeAddress titRegion4 = new CellRangeAddress(2, 2, 5, 6);
            sheet.addMergedRegion(titRegion1);
            sheet.addMergedRegion(titRegion2);
            sheet.addMergedRegion(titRegion3);
            sheet.addMergedRegion(titRegion4);
            //<editor-fold desc="表格第三行设置">
            Row secRow = sheet.createRow(2);
            for(int d = 0; d <= 6; d++){
                secRow.createCell(d).setCellStyle(headStyle);
            }
            Cell secCell0 = secRow.createCell(0);
            secCell0.setCellValue("结算日期");
            secCell0.setCellStyle(headStyle);
            Cell secCell2 = secRow.createCell(1);
            secCell2.setCellValue("全国");
            secCell2.setCellStyle(headStyle);
            Cell secCell3 = secRow.createCell(3);
            secCell3.setCellValue("上海");
            secCell3.setCellStyle(headStyle);
            Cell secCell4 = secRow.createCell(5);
            secCell4.setCellValue("总合计");
            secCell4.setCellStyle(headStyle);
            //</editor-fold>
            //<editor-fold desc="表格第四行设置">
            Row thiRow = sheet.createRow(3);
            thiRow.createCell(0).setCellStyle(headStyle);
            Cell thiCell0 = thiRow.createCell(1);
            thiCell0.setCellValue("笔数");
            thiCell0.setCellStyle(headStyle);
            Cell thiCell1 = thiRow.createCell(2);
            thiCell1.setCellValue("金额");
            thiCell1.setCellStyle(headStyle);
            Cell thiCell4 = thiRow.createCell(3);
            thiCell4.setCellValue("笔数");
            thiCell4.setCellStyle(headStyle);
            Cell thiCell5 = thiRow.createCell(4);
            thiCell5.setCellValue("金额");
            thiCell5.setCellStyle(headStyle);
            Cell thiCell6 = thiRow.createCell(5);
            thiCell6.setCellValue("笔数");
            thiCell6.setCellStyle(headStyle);
            Cell thiCell7 = thiRow.createCell(6);
            thiCell7.setCellValue("金额");
            thiCell7.setCellStyle(headStyle);
            //</editor-fold>
            JSONArray rows = this.jsonObject.getJSONArray("rows");
            int totPages = this.jsonObject.getIntValue("totPages_01");
            int rowNum = 4;
            CellStyle commonStyle = this.getCellStyleOfData(book);
            String qgTotNum = "0";
            String qgTotAmt = "0";
            String shTotNum = "0";
            String shTotAmt = "0";
            String jsTotNum = "0";
            String jsTotAmt = "0";
            int tempHbNum = 0;
            String tempHbVal = "";
            while(this.page <= totPages){
                if(rows != null && rows.size() > 0){
                    JSONObject js = new JSONObject();
                    rows.add(js);
                    for(Object object : rows){
                        JSONObject tempRowData = (JSONObject) object;
                        //<editor-fold desc="数据设置">
                        if(Tools.processNull(tempRowData.getString("CLR_DATE")).equals(tempHbVal)){
                            tempHbNum++;
                        }else{
                            if(tempHbNum > 0){
                                CellRangeAddress tempDataRegion = new CellRangeAddress(rowNum - 1 - tempHbNum, rowNum - 1, 0, 0);
                                sheet.addMergedRegion(tempDataRegion);
                            }
                            if(Tools.processNull(tempRowData.getString("CLR_DATE")).equals("")){
                                continue;
                            }
                            tempHbNum = 0;
                            tempHbVal = tempRowData.getString("CLR_DATE");
                        }
                        Row tempRow = sheet.createRow(rowNum);
                        Cell tempCell0 = tempRow.createCell(0);
                        tempCell0.setCellValue(tempRowData.getString("CLR_DATE"));
                        tempCell0.setCellStyle(commonStyle);
                        Cell tempCell1 = tempRow.createCell(1);
                        tempCell1.setCellValue(tempRowData.getBigDecimal("QGJFTOTNUM").longValue());
                        tempCell1.setCellStyle(commonStyle);
                        qgTotNum = Arith.add(qgTotNum, tempRowData.getString("QGJFTOTNUM"));
                        Cell tempCell2 = tempRow.createCell(2);
                        tempCell2.setCellStyle(commonStyle);
                        tempCell2.setCellValue(tempRowData.getBigDecimal("QGJFTOTAMT").doubleValue());
                        qgTotAmt = Arith.add(qgTotAmt, tempRowData.getString("QGJFTOTAMT"));
                        Cell tempCell9 = tempRow.createCell(3);
                        tempCell9.setCellValue(tempRowData.getBigDecimal("SHJFTOTNUM").longValue());
                        tempCell9.setCellStyle(commonStyle);
                        shTotNum = Arith.add(shTotNum, tempRowData.getString("SHJFTOTNUM"));
                        Cell tempCell10 = tempRow.createCell(4);
                        tempCell10.setCellValue(tempRowData.getBigDecimal("SHJFTOTAMT").doubleValue());
                        tempCell10.setCellStyle(commonStyle);
                        shTotAmt = Arith.add(shTotAmt, tempRowData.getString("SHJFTOTAMT"));
                        Cell tempCell15 = tempRow.createCell(5);
                        tempCell15.setCellStyle(commonStyle);
                        tempCell15.setCellValue(Long.valueOf(Arith.add(tempRowData.getString("QGJFTOTNUM"), tempRowData.getString("SHJFTOTNUM"))));
                        jsTotNum = Arith.add(jsTotNum, Arith.add(tempRowData.getString("QGJFTOTNUM"), tempRowData.getString("SHJFTOTNUM")));
                        Cell tempCell16 = tempRow.createCell(6);
                        tempCell16.setCellStyle(commonStyle);
                        tempCell16.setCellValue(Double.valueOf(Arith.add(tempRowData.getString("QGJFTOTAMT"), tempRowData.getString("SHJFTOTAMT"))));
                        jsTotAmt = Arith.add(jsTotAmt, Arith.add(tempRowData.getString("QGJFTOTAMT"), tempRowData.getString("SHJFTOTAMT")));
                        rowNum++;
                        tempRowData = null;
                        //</editor-fold>
                    }
                    rows = null;
                }
                this.page += 1;
                if(this.page <= totPages){
                    this.queryBdkYdConsumeJfStat();
                    if(!Tools.processNull(jsonObject.get("status")).equals("0")){
                        book = null;
                        sheet = null;
                        throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
                    }
                    rows = this.jsonObject.getJSONArray("rows");
                }
            }
            //<editor-fold desc="尾行设置">
            Row tempRow = sheet.createRow(rowNum);
            Cell taiCell0 = tempRow.createCell(0);
            taiCell0.setCellValue("合计");
            taiCell0.setCellStyle(commonStyle);
            Cell taiCell1 = tempRow.createCell(1);
            taiCell1.setCellValue(Long.valueOf(qgTotNum));
            taiCell1.setCellStyle(commonStyle);
            Cell taiCell2 = tempRow.createCell(2);
            taiCell2.setCellValue(Double.valueOf(qgTotAmt));
            taiCell2.setCellStyle(commonStyle);
            Cell taiCell3 = tempRow.createCell(3);
            taiCell3.setCellValue(Long.valueOf(shTotNum));
            taiCell3.setCellStyle(commonStyle);
            Cell taiCell4 = tempRow.createCell(4);
            taiCell4.setCellValue(Double.valueOf(shTotAmt));
            taiCell4.setCellStyle(commonStyle);
            Cell taiCell5 = tempRow.createCell(5);
            taiCell5.setCellValue(Long.valueOf(jsTotNum));
            taiCell5.setCellStyle(commonStyle);
            Cell taiCell6 = tempRow.createCell(6);
            taiCell6.setCellValue(Double.valueOf(jsTotAmt));
            taiCell6.setCellStyle(commonStyle);
            //</editor-fold>
            //<editor-fold desc="数据输出">
            OutputStream out = this.response.getOutputStream();
            this.response.setContentType("application/vnd.ms-excel");
            this.response.setCharacterEncoding("UTF-8");
            this.response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode(Constants.APP_REPORT_TITLE + "本地卡异地消费本地结算拒付统计（" + this.beginTime + "--" + this.endTime + "）", "UTF-8") + ".xlsx\"");
            book.write(out);
            SecurityUtils.getSubject().getSession().setAttribute("queryBdkYdConsumeJfStatExport", Constants.YES_NO_YES);
            out.flush();
            //</editor-fold>
        }catch(Exception e){
            this.defaultErrorMsg = e.getMessage();
            return "queryBdkYdConsumeJfStat";
        }
        return null;
    }

    @Override
    public String getSort(){
        return sort;
    }
    @Override
    public void setSort(String sort){
        this.sort = sort;
    }
    @Override
    public String getOrder(){
        return order;
    }
    @Override
    public void setOrder(String order){
        this.order = order;
    }
    public String getBeginTime(){
        return beginTime;
    }
    public void setBeginTime(String beginTime){
        this.beginTime = beginTime;
    }
    public String getEndTime(){
        return endTime;
    }
    public void setEndTime(String endTime){
        this.endTime = endTime;
    }
    public String getQueryType(){
        return queryType;
    }
    public void setQueryType(String queryType){
        this.queryType = queryType;
    }
    public String getBizId(){
        return bizId;
    }
    public void setBizId(String bizId){
        this.bizId = bizId;
    }
    public String getPageType(){
        return pageType;
    }
    public void setPageType(String pageType){
        this.pageType = pageType;
    }
    public String getClrBeginTime(){
        return clrBeginTime;
    }
    public void setClrBeginTime(String clrBeginTime){
        this.clrBeginTime = clrBeginTime;
    }
    public String getClrEndTime(){
        return clrEndTime;
    }
    public void setClrEndTime(String clrEndTime){
        this.clrEndTime = clrEndTime;
    }
}
