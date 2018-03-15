package com.erp.util;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.lang.reflect.Method;
import java.net.URLEncoder;
import java.util.Collection;
import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import net.sf.jasperreports.engine.JRAbstractExporter;
import net.sf.jasperreports.engine.JRDataSource;
import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JRExporter;
import net.sf.jasperreports.engine.JRExporterParameter;
import net.sf.jasperreports.engine.JRField;
import net.sf.jasperreports.engine.JRResultSetDataSource;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.engine.JasperRunManager;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;
import net.sf.jasperreports.engine.export.JRCsvExporter;
import net.sf.jasperreports.engine.export.JRHtmlExporter;
import net.sf.jasperreports.engine.export.JRHtmlExporterParameter;
import net.sf.jasperreports.engine.export.JRPdfExporter;
import net.sf.jasperreports.engine.export.JRPdfExporterParameter;
import net.sf.jasperreports.engine.export.JRRtfExporter;
import net.sf.jasperreports.engine.export.JRTextExporter;
import net.sf.jasperreports.engine.export.JRXlsExporter;
import net.sf.jasperreports.engine.export.JRXlsExporterParameter;
import net.sf.jasperreports.engine.export.JRXmlExporter;
import net.sf.jasperreports.engine.util.JRLoader;
import net.sf.json.JSONArray;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;

/**
 * @author yangning
 * @describle 报表工具
 * @email yangn@ingsigmacc.com
 * @version 1.0
 */
public class ReportUtil<T> {
	private HttpServletRequest request;
	private HttpServletResponse response;
	private HttpSession session;
	private final Log log = LogFactory.getLog(getClass());
	public ReportUtil(){
		
	}
	public ReportUtil(HttpServletRequest request,HttpServletResponse response){
		this.request = request;
		this.session = request.getSession();
		this.response = response;
	}
	/*request,response,session的setter/getter方法*/
	public HttpServletRequest getRequest() {
		return request;
	}
	public void setRequest(HttpServletRequest request) {
		this.request = request;
	}
	public HttpServletResponse getResponse() {
		return response;
	}
	public void setResponse(HttpServletResponse response) {
		this.response = response;
	}
	public HttpSession getSession() {
		return session;
	}
	public void setSession(HttpSession session) {
		this.session = session;
	}
	/**
	 * 枚举类型,本工具类支持的报表类型
	 * PDF,HTML,EXCEL,XML,RTF,CSV,TXT
	 */
	public static enum JasperType{
		PDF,HTML,EXCEL,XML,RTF,CSV,TXT
	}
	/**
	 * 根据生成报表类型,获得不同的返回的类型,用于设定response数据类型.
	 * @param JasperType jasperType
	 * @return  response的contentType类型
	 */
	@SuppressWarnings("incomplete-switch")
	public String getContentType(JasperType jasperType){   
		String contentType="text/html";   
        switch(jasperType){   
        case PDF:   
            contentType = "application/pdf";   
            break;   
        case EXCEL:   
            contentType = "application/vnd.ms-excel";   
            break;   
        case XML:   
            contentType = "text/xml";   
            break;   
        case RTF:   
            contentType = "application/rtf";   
            break;   
        case CSV:   
            contentType = "text/plain";   
            break;   
        }   
        return contentType;   
	}
	/**
	 * 导出报表的文件类型
	 * @param type 报表类型
	 * @return 对应报表类型的 JRExporter对象
	 */
	public JRAbstractExporter getExporter(JasperType type){
		JRAbstractExporter exporter = null;
		switch (type) {
		case PDF:
			exporter = new JRPdfExporter();
			break;
		case HTML:
			exporter = new JRHtmlExporter();
			break;
		case EXCEL:
			exporter = new JRXlsExporter();
			break;
		case XML:   
			exporter = new JRXmlExporter();   
			break;   
		case RTF:   
			exporter = new JRRtfExporter();   
			break;   
		case CSV:   
			exporter = new JRCsvExporter();   
			break;   
		case TXT:   
			exporter = new JRTextExporter();   
			break;   
		}
		return exporter;
	}
	/**
	 * 创建JasperPrint对象
	 * @param reportFile String 报表的.jasper文件的路径
	 * @param parameters Map 报表需要传入的参数
	 * @param dataSource Collection 填充报表的数据集合
	 * @return JasperRint JasperPrint对象 
	 */
	@SuppressWarnings("rawtypes")
	public JasperPrint getJasperPrint(String reportFile,Map parameters,Collection<?> dataSource){
		String url = request.getRealPath(reportFile);
		File file = new File(url);
	    JRDataSource data = new JRBeanCollectionDataSource(dataSource);
		JasperReport jasperReport;
		try {
			jasperReport = (JasperReport) JRLoader.loadObject(file);
			JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport,parameters,data);
			return jasperPrint;
		} catch (JRException e){
			log.error("the method getJasperPrint() in class ReportUtil occur error 生成报表时,创建JasperPrint对象出错：" + e.getMessage());
			return null;
		}
	}
	/**
	 * 创建JasperPrint对象
	 * @param reportFile String 报表的.jasper文件的路径
	 * @param parameters Map 报表需要传入的参数
	 * @param dataSource Collection 填充报表的数据集合
	 * @return JasperRint JasperPrint对象 
	 */
	@SuppressWarnings("rawtypes")
	public JasperPrint getJasperPrintBYJRset(String reportFile,Map parameters,JRResultSetDataSource dataSource){
		String url = request.getRealPath(reportFile);
		File file = new File(url);
		JasperReport jasperReport;
		try {
			jasperReport = (JasperReport) JRLoader.loadObject(file);
			JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport,parameters,dataSource);
			return jasperPrint;
		} catch (Exception e){
			log.error("the method getJasperPrint() in class ReportUtil occur error 生成报表时,创建JasperPrint对象出错：" + e.getMessage());
			return null;
		}
	}
	/**
	 * 报表工具,导出HTML格式的报表
	 * @param reportFile String 报表文件.jasper文件的路径
	 * @param parameters Map 报表需要的参数
	 * @param dataSource Collection 填充报表的数据集合
	 */
	@SuppressWarnings("rawtypes")
	public void exportHTML(String reportFile,Map parameters,Collection dataSource){
		try {
			response.setContentType("text/html");   //response.setContentType("text/html;charset=GB2312");
		    response.setCharacterEncoding("UTF-8");
			PrintWriter out = this.response.getWriter();
			JasperPrint jasperPrint = this.getJasperPrint(reportFile,parameters, dataSource);
			JRExporter exporter = this.getExporter(JasperType.HTML);
			exporter.setParameter(JRHtmlExporterParameter.JASPER_PRINT,jasperPrint);
			exporter.setParameter(JRHtmlExporterParameter.IS_REMOVE_EMPTY_SPACE_BETWEEN_ROWS,true);
			exporter.setParameter(JRHtmlExporterParameter.IS_USING_IMAGES_TO_ALIGN,false);
			exporter.setParameter(JRHtmlExporterParameter.BETWEEN_PAGES_HTML,"<div style=\"page-break-after:always;width:0px;height:0px;margin:0px;padding:0px;\">&nbsp;</div>");
			exporter.setParameter(JRHtmlExporterParameter.OUTPUT_WRITER,out);
			exporter.exportReport();
			out.close();
		} catch (JRException e) {
			log.error("导出HTML格式的报表时出现错误：" + e.getMessage());
			e.printStackTrace();
		} catch (IOException e) {
			log.error("导出HTML格式的报表时出现错误：" + e.getMessage());
			e.printStackTrace();
		}
	}
	/**
	 * 报表工具,导出PDF格式的报表.
	 * @param reportFile String 报表文件.jasper文件的路径
	 * @param parameters Map 报表需要的参数
	 * @param dataSource Collection 填充报表的数据
	 */
	
	@SuppressWarnings("rawtypes")
	public byte[] exportPDF(String fileName,String reportFile,Map parameters,Collection dataSource){
		byte[] prints=null;
		try {
			JasperPrint jasperPrint;
			response.setContentType("application/pdf");
			response.setCharacterEncoding("UTF-8");
			OutputStream out = this.response.getOutputStream();
			//response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode(fileName, "UTF-8") + ".pdf\"");
			jasperPrint = this.getJasperPrint(reportFile, parameters, dataSource);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			JRExporter exporter = this.getExporter(JasperType.PDF);
			exporter.setParameter(JRPdfExporterParameter.JASPER_PRINT,jasperPrint);
			exporter.setParameter(JRPdfExporterParameter.OUTPUT_STREAM,baos);
			//exporter.setParameter(JRPdfExporterParameter.OUTPUT_FILE,"out");
			exporter.setParameter(JRPdfExporterParameter.IGNORE_PAGE_MARGINS,true);
			exporter.setParameter(JRPdfExporterParameter.IS_COMPRESSED,true);
			
			exporter.exportReport();
			prints = baos.toByteArray();//字节数组
			response.setContentLength(prints.length);
			out.write(prints);
			out.flush();
			baos.close();
			out.close();
		} catch (IOException e) {
			log.error("导出PDF格式的报表时出现错误：" + e.getMessage());
			e.printStackTrace();
		} catch (JRException e) {
			log.error("导出PDF格式的报表时出现错误：" + e.getMessage());
			e.printStackTrace();
		}
		return prints;
	}
	/**
	 * 报表工具,导出PDF格式的报表.
	 * @param reportFile String 报表文件.jasper文件的路径
	 * @param parameters Map 报表需要的参数
	 * @param dataSource Collection 填充报表的数据
	 */
	
	@SuppressWarnings("rawtypes")
	public byte[] exportPDFBYJRResset(String fileName,String reportFile,Map parameters,JRResultSetDataSource dataSource){
		byte[] prints=null;
		try {
			JasperPrint jasperPrint;
			jasperPrint = this.getJasperPrintBYJRset(reportFile, parameters, dataSource);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			JRExporter exporter = this.getExporter(JasperType.PDF);
			exporter.setParameter(JRPdfExporterParameter.JASPER_PRINT,jasperPrint);
			exporter.setParameter(JRPdfExporterParameter.OUTPUT_STREAM,baos);
			exporter.setParameter(JRPdfExporterParameter.IS_COMPRESSED,true);
			exporter.exportReport();
     		prints = baos.toByteArray();//字节数组
		} catch (JRException e) {
			log.error("导出PDF格式的报表时出现错误：" + e.getMessage());
			e.printStackTrace();
		}
		return prints;
	}
	/**
	 * 报表工具,导出Excel格式的报表.
	 * @param reportFile String 报表文件.jasper文件的路径
	 * @param parameters Map 报表需要的参数
	 * @param dataSource Collection 填充报表的数据
	 */
	
	@SuppressWarnings("rawtypes")
	public void exportExcel(String reportFile,Map parameters,Collection dataSource){
		OutputStream out = null;
		try {
			response.setContentType("application/vnd.ms-excel");
			response.setCharacterEncoding("UTF-8");
			response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode("yangn", "UTF-8") + ".xls\"");
			out = this.response.getOutputStream();
			JasperPrint jasperPrint = this.getJasperPrint(reportFile, parameters, dataSource);
			JRExporter exporter = this.getExporter(JasperType.EXCEL);
			exporter.setParameter(JRExporterParameter.JASPER_PRINT,jasperPrint);
			exporter.setParameter(JRExporterParameter.OUTPUT_STREAM,out);
			exporter.setParameter(JRPdfExporterParameter.OUTPUT_FILE,"out");
			exporter.setParameter(JRExporterParameter.IGNORE_PAGE_MARGINS,true);
			exporter.setParameter(JRExporterParameter.IGNORE_PAGE_MARGINS,true);
			exporter.setParameter(JRXlsExporterParameter.IS_REMOVE_EMPTY_SPACE_BETWEEN_ROWS,false);
			exporter.setParameter(JRXlsExporterParameter.IS_WHITE_PAGE_BACKGROUND,true);
			exporter.setParameter(JRXlsExporterParameter.IS_COLLAPSE_ROW_SPAN,false);
			exporter.setParameter(JRXlsExporterParameter.IS_IGNORE_CELL_BORDER,false);
			exporter.setParameter(JRXlsExporterParameter.IS_REMOVE_EMPTY_SPACE_BETWEEN_COLUMNS,false);//是否删除列之间空余的列
			exporter.setParameter(JRXlsExporterParameter.IS_IGNORE_GRAPHICS,true);//是否忽略图像
			exporter.setParameter(JRXlsExporterParameter.IS_DETECT_CELL_TYPE,true);//是否设置单元格的类型
			exporter.setParameter(JRXlsExporterParameter.IS_FONT_SIZE_FIX_ENABLED,true);//设置excel高度适应字体的高度
			exporter.exportReport();
			out.close();
		} catch (IOException e) {
			log.error("导出Excel格式的报表时出现错误：" + e.getMessage());
			e.printStackTrace();
		} catch (JRException e) {
			log.error("导出Excel格式的报表时出现错误：" + e.getMessage());
			e.printStackTrace();
		}finally{
			try {out.close();} catch (IOException e) {e.printStackTrace();}
		}
	}
	/**
	 * PDF格式报表打印
	 * @param reportFile String 报表文件的.jasper文件
	 * @param parameters Map 参数组成的Map
	 * @param dataSource Collection 数据源集合
	 */
	
	@SuppressWarnings("rawtypes")
	public void print(String reportFile,Map parameters,Collection dataSource){
		response.setCharacterEncoding("UTF-8");
		response.setContentType("application/pdf");
		String url = this.session.getServletContext().getRealPath(reportFile);
		File file = new File(url);
		try {
			//ServletOutputStream out = response.getOutputStream();
			JasperReport jasperReport = (JasperReport) JRLoader.loadObject(file);
			JRDataSource data = new JRBeanCollectionDataSource(dataSource);
			byte[] outs = JasperRunManager.runReportToPdf(jasperReport,parameters,data);
			//response.setContentLength(outs.length);
			//out.write(outs);
			//out.flush();
			//out.close();
			this.session.setAttribute("bytes",outs);
		} catch (JRException e) {
			e.printStackTrace();
		} 
		
	}
	
	/**
	 * 运用apache的POI将数据集合导出Excel.
	 * @param header String[] 导出Excel的表头.
	 * @param attrs String[] 操作对象取值的属性集合.
	 * @param list Collection 将被导出数据的集合.
	 * @param excelName String 导出Excel文件的文件名.
	 * @throws Exception 
	 */
	
	@SuppressWarnings("unchecked")
	public void exportExcelByPOI(String[] header,String[] attrs,Collection<T> list,String excelName) throws Exception{
		OutputStream out = this.response.getOutputStream();
		response.setContentType("application/vnd.ms-excel");
		response.setCharacterEncoding("UTF-8");
		response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode(excelName, "UTF-8") + ".xls\"");
		try {
			if(attrs == null || list == null){
				throw new Exception("attrs为空，或list数据列表为空");
			}
			HSSFWorkbook workBook = new HSSFWorkbook();
			//设置表格的默认的格式
			HSSFCellStyle style = workBook.createCellStyle();
			style.setAlignment(CellStyle.ALIGN_CENTER);
			style.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			style.setWrapText(true);//设置换行
			style.setBorderTop(CellStyle.BORDER_THIN);//上边框
			style.setBorderRight(CellStyle.BORDER_THIN);//右边框
			style.setBorderBottom(CellStyle.BORDER_THIN);//下边框
			style.setBorderLeft(CellStyle.BORDER_THIN);//左边框
			//创建一个工作薄sheet
			HSSFSheet sheet = workBook.createSheet(excelName);//创建一个sheet
			sheet.setDefaultRowHeight((short)(1*sheet.getDefaultRowHeight()));//设置默认列高
			int rowNum = 0;//行
			//设置Excel的表头
			if(header != null && header.length > 0){
				HSSFRow row = sheet.createRow(0);
				HSSFCell xuhao = row.createCell(0);
				xuhao.setCellValue("序号");
				HSSFCellStyle headerStyle = workBook.createCellStyle();
				HSSFFont font = workBook.createFont();
				font.setFontName("楷体");//设置首行的字体名称
				font.setFontHeightInPoints((short)10);//首行字体大小
				font.setBoldweight(HSSFFont.BOLDWEIGHT_NORMAL);//首行字体的加粗
				headerStyle.setFont(font);
				headerStyle.setAlignment(CellStyle.ALIGN_CENTER);
				headerStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
				//headerStyle.setWrapText(true);//设置换行
				headerStyle.setBorderTop(CellStyle.BORDER_THIN);//上边框
				headerStyle.setBorderRight(CellStyle.BORDER_THIN);//右边框
				headerStyle.setBorderBottom(CellStyle.BORDER_THIN);//下边框
				headerStyle.setBorderLeft(CellStyle.BORDER_THIN);//左边框
				xuhao.setCellStyle(headerStyle);
				int temp = 1;
				for (String string : header) {
					HSSFCell cell = row.createCell(temp);
					cell.setCellValue(string);
					cell.setCellStyle(headerStyle);
					temp++;
				}
				rowNum++;//当表头的时候,循环数据集合从第二行开始.
			}
			int colNum = 0;//列
			Iterator<T> it = list.iterator();
			while (it.hasNext()) {
				HSSFRow row = sheet.createRow(rowNum);
				T t =  (T)it.next();
				if(header != null && header.length > 0){
					HSSFCell firstCell = row.createCell(colNum);//第一列,序号.
					firstCell.setCellValue(rowNum);
					firstCell.setCellStyle(style);
					colNum++;//加1,第二个单元格.
				}
				Class<T> clazz = (Class<T>) t.getClass();
				for (String attr : attrs){
					String getter = getter(attr);
					Method method = clazz.getMethod(getter);
					String string = " ";
					string = (String) method.invoke(t);
					string = string == null ? "" : string;
					HSSFCell cell = row.createCell(colNum);
					cell.setCellType(Cell.CELL_TYPE_STRING);
					cell.setCellValue(string.trim());
					cell.setCellStyle(style);
					colNum++;
				}
				colNum = 0;
				rowNum++;
			}// end while
			for (int m = 0;m < attrs.length;m++) {
				sheet.autoSizeColumn(m);
			}
			workBook.write(out);
		} catch (Exception e){
			e.printStackTrace();
		} finally{
			out.flush();
			out.close();
		}
	}
	/**
	 * 根据给定的属性,获取该属性对应的getter方法名.
	 * @param attr 属性
	 * @return getter方法名
	 */
	public static String getter(String attr){
		char str = attr.charAt(0);
		String string = "get" + String.valueOf(Character.toUpperCase(str));
		string += attr.substring(1);
		return string;
	}
	/**
	 * 根据给定的属性,获取该属性对应的setter方法名.
	 * @param attr 属性
	 * @return setter方法名
	 */
	public static String setter(String attr){
		char str = attr.charAt(0);
		String string = "set" + String.valueOf(Character.toUpperCase(str));
		string += attr.substring(1);
		return string;
	}
	public static void main(String[] args) {
		/*String[] str = {"subAccNo","acptName","accNo"};
		ReportUtil<Data> report = new ReportUtil<Data>();
		File file = new File("e:\\yangn.xls");
		System.out.println(file.getName());
		Data data = new Data();
		Class<Data> c = Data.class;
		String json = "[{name:\"frzState\"},{name:\"personalId\"},{name:\"clientName\",align:\"left\"},{name:\"inLimitOneDay\"},{name:\"struct_main_type\"},{name:\"bank_Name\"},{name:\"accBalBef\"},{name:\"month_type\"}," +
	              " {name:\"bursebalance\"},{name:\"amtStr\"},{name:\"retWayStr\"},{name:\"trStateNameStr\"},{name:\"businessclientpStr\"},{name:\"accUsableBal\"},{name:\"lssState\"},{name:\"bizType\"}]";
		//List<Data> list = report.importExcel(file,str,);*/
		//System.out.println(list.size());
		//String String
		//Long Long
		//Integer Integer
		//Booean Boolean
		//Date Date
		System.out.println(setter("yangn"));
	}
}
