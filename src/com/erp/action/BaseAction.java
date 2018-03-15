package com.erp.action;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.jasperreports.web.commands.CommandException;

import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.subject.Subject;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.ParentPackage;
import org.apache.struts2.interceptor.CookiesAware;
import org.apache.struts2.interceptor.ServletRequestAware;
import org.apache.struts2.interceptor.ServletResponseAware;
import org.apache.struts2.interceptor.SessionAware;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.SysBranch;
import com.erp.model.SysErrLog;
import com.erp.model.Users;
import com.erp.service.BaseService;
import com.erp.service.SysErrLogService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.viewModel.Json;
import com.opensymphony.xwork2.ActionSupport;

/**
 * 类功能说明 TODO:基类action
 * 类修改者	修改日期
 * 修改说明
 * <p>Title: BaseAction.java</p>
 * <p>Description:杰斯科技</p>
 * <p>Copyright: Copyright (c) 2012</p>
 * <p>Company:杰斯科技</p>
 * @author hujc 631410114@qq.com
 * @date 2015-4-1 上午08:18:21
 * @version V1.0
 */
@ParentPackage("default-package")
@Namespace("/")
public class BaseAction extends ActionSupport implements ServletResponseAware,ServletRequestAware,SessionAware,CookiesAware{
	private static final long	serialVersionUID = 7493364888065600947L;
	@Autowired
	public BaseService baseService;
	@Autowired
	public SysErrLogService sysErrLogService;
	public String JSONOBJ = "jsonObj";
	private String _query_type_ = "1";
	public String searchName;
	public String searchValue;
	public String inserted;
	public String updated;
	public String deleted;
	public Integer page = 0;
	public Integer rows = 0;
	public String sort;
	public String order;
	public String searchAnds;
	public String searchColumnNames;
	public String searchConditions;
	public String searchVals;
	public File uploadfile;
	public String uploadfileFileName;
	public HttpServletResponse response;
	public HttpServletRequest request;
	protected Map<String,Object> session;
	public InputStream excelStream; 
	public String  expFileName;
	public String jsonString = "";
	public JSONObject jsonObject = new JSONObject();
	public Json msgJson = new Json();
	public String defaultErrorMsg;
	
	public BaseAction(){
		super();
	}
	/**
	 * <p>运用HttpServletResponse直接将对象转换成json字符串进行输出</p>
	 * @param object
	 */
	public void OutputJson(Object object){
		PrintWriter out = null;
		String json = null;
		try{
			HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
			httpServletResponse.setContentType("application/json");
			httpServletResponse.setCharacterEncoding("utf-8");
			out = httpServletResponse.getWriter();
			json = JSON.toJSONStringWithDateFormat(object, "yyyy-MM-dd HH:mm:ss");
		} catch (IOException e){
			e.printStackTrace();
		}
		out.print(json);
		out.close();
	}
	/**
	 * <p>
     * 	运用HttpServletResponse直接将对象转换成json字符串进行输出
     * 	并指定输出流的类型
	 * </p>
	 * @param object
	 */
	public void OutputJson(Object object,String type){
		try{
			PrintWriter out = null;
			String json = null;
			HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
			httpServletResponse.setContentType(type);
			httpServletResponse.setCharacterEncoding("utf-8");
			out = httpServletResponse.getWriter();
			json = JSON.toJSONStringWithDateFormat(object, "yyyy-MM-dd HH:mm:ss");
			out.print(json);
			out.close();
		} catch (IOException e){
			e.printStackTrace();
		}
	}
	/**
	 * <p>设置当前报表参数map</p>
	 * @param map 设置报表参数的
	 */
	public void setReportHashMap(Map<String,String> map){
		Subject subject = SecurityUtils.getSubject();
		subject.getSession().setAttribute("_CURRENT_REPORT_PARAMETERS",map);
	}
	/**
	 * <p>设置报表文件(.jasper)的路径信息</p>
	 * @param filepath .jasper 文件的相对路径/
	 */
	public void setReportFilePathAndName(String filepath){
		Subject subject = SecurityUtils.getSubject();
		subject.getSession().setAttribute("_CURRENT_REPORT_FILENAME",filepath);
	}
	/**
	 * <p>设置报表数据源</p>
	 * @param dataList List 设置报表循环的列表,数据源datasource
	 */
	public void setReportDataList(List<?> dataList){
		Subject subject = SecurityUtils.getSubject();
		subject.getSession().setAttribute("_CURRENT_REPORT_DATALIST",dataList);
	}
	/**
	 * <P>设置报表参数,单独设置.</P>
	 * @param paraName  参数名称
	 * @param paraValue 参数值
	 */
	@SuppressWarnings("unchecked")
	public void setReportParameter(String paraName,String paraValue){
		Subject subject = SecurityUtils.getSubject();
		Map<String,String> map = (Map<String,String>) subject.getSession().getAttribute("_CURRENT_REPORT_PARAMETERS");
		map = (map == null) ? new HashMap<String,String>() : map;
		map.put(paraName,paraValue);
		setReportHashMap(map);
	}
	/**
	 * <P>获取EXCEL表格的标题格式</p>
	 * @param book Workbook 表格实体
	 * @return CellStyle 标题通用样式
	 * @throws CommonException
	 */
	public CellStyle getCellStyleOfTitle(org.apache.poi.ss.usermodel.Workbook book) throws CommonException{
		try{
			if(book == null){
				throw new CommonException("Parameter book can not be empty");
			}
			Font titleFont = book.createFont();
			titleFont.setFontName("幼圆");
			titleFont.setColor(HSSFFont.COLOR_NORMAL);
			titleFont.setBoldweight((short)(titleFont.getBoldweight() * 6));
			CellStyle titleStyle = book.createCellStyle();
			titleStyle.setAlignment(CellStyle.ALIGN_CENTER);
			titleStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			titleStyle.setFont(titleFont);
			return titleStyle;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * <P>获取EXCEL表格的数据列标题格式</p>
	 * @param book Workbook 表格实体
	 * @return CellStyle 数据列标题通用样式
	 * @throws CommonException
	 */
	public CellStyle getCellStyleOfHeader(org.apache.poi.ss.usermodel.Workbook book) throws CommonException{
		try{
			if(book == null){
				throw new CommonException("Parameter book can not be empty");
			}
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
			return headStyle;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * <P>获取EXCEL表格的数据列格式</p>
	 * @param book Workbook 表格实体
	 * @return CellStyle 数据列通用样式
	 * @throws CommonException
	 */
	public CellStyle getCellStyleOfData(org.apache.poi.ss.usermodel.Workbook book) throws CommonException{
		try{
			if(book == null){
				throw new CommonException("Parameter book can not be empty");
			}
			Font commonFont = book.createFont();
			commonFont.setFontName("微软雅黑");
			commonFont.setFontHeight((short)(commonFont.getFontHeight() * 0.8));
			CellStyle commonStyle = book.createCellStyle();
			commonStyle.setBorderBottom(CellStyle.BORDER_THIN);
			commonStyle.setBorderLeft(CellStyle.BORDER_THIN);
			commonStyle.setBorderRight(CellStyle.BORDER_THIN);
			commonStyle.setBorderTop(CellStyle.BORDER_THIN);
			commonStyle.setAlignment(CellStyle.ALIGN_CENTER);
			commonStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			commonStyle.setFont(commonFont);
			return commonStyle;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * <P>获取EXCEL表格的日期列格式</p>
	 * @param book Workbook 表格实体
	 * @return CellStyle 日期列通用样式
	 * @throws CommonException
	 */
	public CellStyle getCellStyleOfDateColumn(org.apache.poi.ss.usermodel.Workbook book) throws CommonException{
		try{
			if(book == null){
				throw new CommonException("Parameter book can not be empty");
			}
			Font commonFont = book.createFont();
			commonFont.setFontName("微软雅黑");
			commonFont.setFontHeight((short)(commonFont.getFontHeight() * 0.8));
			CellStyle commonStyle = book.createCellStyle();
			commonStyle.setBorderBottom(CellStyle.BORDER_NONE);
			commonStyle.setBorderLeft(CellStyle.BORDER_NONE);
			commonStyle.setBorderRight(CellStyle.BORDER_NONE);
			commonStyle.setBorderTop(CellStyle.BORDER_NONE);
			commonStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			commonStyle.setVerticalAlignment(CellStyle.VERTICAL_BOTTOM);
			commonStyle.setFont(commonFont);
			return commonStyle;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * <P>action 层异常处理</p>
	 * @param e Exception 异常
	 * @return String 异常详细信息
	 */
	public String saveErrLog(Exception e){
		try{
			SysErrLog err = new SysErrLog();
	        err.setUserId(Constants.getCurrendUser().getAccount());
	        if(Tools.processNull(e.getMessage()).length() > 255){
	            err.setMessage(Tools.processNull(e.getMessage()).substring(0, 255));
	        }else{
	            err.setMessage(e.getMessage());
	        }
	        err.setErrTime(new Date());
	        err.setIp(Constants.getIpAddr());
	        err.setErrType("0");
			sysErrLogService.saveSysErrLog(err);
		}catch(CommandException e1){
			e1.printStackTrace();
		}
		return e.getMessage();
	}
	/**
     * 登入者编号
     */
    public String getUserId(){
    	Subject subject=SecurityUtils.getSubject();
    	com.erp.model.Users user=(com.erp.model.Users)subject.getSession().getAttribute(Constants.LOGIN_SESSION_DATANAME);
		return Tools.processNull(user.getUserId());
    }
    /**
     * 登入者姓名
     */
    public String getOperName(){
    	Subject subject=SecurityUtils.getSubject();
    	com.erp.model.Users user=(com.erp.model.Users)subject.getSession().getAttribute(Constants.LOGIN_SESSION_DATANAME);
		return Tools.processNull(user.getUserId());
    }
    /**
     * 登录操作员的对象信息
     */
    public com.erp.model.Users getUsers(){
    	Subject subject=SecurityUtils.getSubject();
        return (Users)subject.getSession().getAttribute(Constants.LOGIN_SESSION_DATANAME);
    }
    /**
     * 登入者网点实体
     */
    public SysBranch getSysBranch(){
    	Subject subject = SecurityUtils.getSubject();
    	return (SysBranch)subject.getSession().getAttribute(Constants.LOGIN_SESSION_DATANAME);
    }
    /**
    * 初始化数据表格
    * @return
    */
    public JSONObject initBaseDataGrid() throws CommonException{
		this.jsonObject.put("rows",new JSONArray());
		this.jsonObject.put("total",0);
		this.jsonObject.put("status",0);
		this.jsonObject.put("errMsg","");
		return this.jsonObject;
    }
    public Json getMessage(boolean flag){
		Json json = new Json();
		if(flag){
			json.setStatus(true);
			json.setMessage("数据更新成功！");
		}else{
			json.setMessage("提交失败了！");
		}
		return json;
	}
    
	public void downLoadFile(String path, String filename) {
		ServletOutputStream servletOS = null;
		InputStream inStream = null;
		try {
			filename = URLEncoder.encode(filename, "UTF-8");
			File file = new File(path);
			/* 如果文件存在 */
			if (file.exists()) {
				response.reset();
				response.setContentType("file");
				response.addHeader("Content-Disposition",
						"attachment; filename=\"" + filename + "\"");
				int fileLength = (int) file.length();
				/* 如果文件长度大于0 */
				if (fileLength != 0) {
					/* 创建输入流 */
					inStream = new FileInputStream(file);
					byte[] buf = new byte[4096];
					/* 创建输出流 */
					servletOS = response.getOutputStream();
					int readLength;
					while (((readLength = inStream.read(buf)) != -1)) {
						servletOS.write(buf, 0, readLength);
					}
					servletOS.flush();
				}
			}
		} catch (Exception e) {
		} finally {
			if (null != servletOS) {
				try {
					inStream.close();
					servletOS.close();
				} catch (IOException e) {
				}
			}
		}
	}
    public void setSysErrLogService(SysErrLogService sysErrLogService){
		this.sysErrLogService = sysErrLogService;
	}
    public void setCookiesMap(Map<String, String> arg0){
	}
	public void setSession(Map<String, Object> arg0){
	}
	public void setServletRequest(HttpServletRequest arg0){
		this.request = arg0;
	}
	public void setServletResponse(HttpServletResponse arg0){
		this.response =arg0;
	}
	public String getJsonString(){
		return jsonString;
	}
	public void setJsonString(String jsonString){
		this.jsonString = jsonString;
	}
	public JSONObject getJsonObject(){
		return jsonObject;
	}
	public void setJsonObject(JSONObject jsonObject){
		this.jsonObject = jsonObject;
	}
	public BaseService getBaseService(){
		return baseService;
	}
	public void setBaseService(BaseService baseService){
		this.baseService = baseService;
	}
	public InputStream getExcelStream(){
		return excelStream;
	}
	public void setExcelStream(InputStream excelStream){
		this.excelStream = excelStream;
	}
	public String getExpFileName(){
		return expFileName;
	}
	public void setExpFileName(String expFileName){
		this.expFileName = expFileName;
	}
	public SysErrLogService getSysErrLogService(){
		return sysErrLogService;
	}
	public String getSearchName(){
		return searchName;
	}
	public void setSearchName(String searchName ){
		this.searchName = searchName;
	}
	public String getSearchValue(){
		return searchValue;
	}
	public void setSearchValue(String searchValue ){
		this.searchValue = searchValue;
	}
	public String getInserted(){
		return inserted;
	}
	public void setInserted(String inserted ){
		this.inserted = inserted;
	}
	public String getUpdated(){
		return updated;
	}
	public void setUpdated(String updated ){
		this.updated = updated;
	}
	public String getDeleted(){
		return deleted;
	}
	public void setDeleted(String deleted ){
		this.deleted = deleted;
	}
	public Integer getPage(){
		return page;
	}
	public void setPage(Integer page ){
		this.page = page;
	}
	public Integer getRows(){
		return rows;
	}
	public void setRows(Integer rows ){
		this.rows = rows;
	}
	public String getSearchAnds(){
		return searchAnds;
	}
	public void setSearchAnds(String searchAnds ){
		this.searchAnds = searchAnds;
	}
	public String getSearchColumnNames(){
		return searchColumnNames;
	}
	public void setSearchColumnNames(String searchColumnNames ){
		this.searchColumnNames = searchColumnNames;
	}
	public String getSearchConditions(){
		return searchConditions;
	}
	public void setSearchConditions(String searchConditions ){
		this.searchConditions = searchConditions;
	}
	public String getSearchVals(){
		return searchVals;
	}
	public void setSearchVals(String searchVals ){
		this.searchVals = searchVals;
	}
	public File getUploadfile(){
		return uploadfile;
	}
	public void setUploadfile(File uploadfile){
		this.uploadfile = uploadfile;
	}
	public String getUploadfileFileName(){
		return uploadfileFileName;
	}
	public void setUploadfileFileName(String uploadfileFileName){
		this.uploadfileFileName = uploadfileFileName;
	}
	public String get_query_type_() {
		return _query_type_;
	}
	public void set_query_type_(String _query_type_) {
		this._query_type_ = _query_type_;
	}
	/**
	 * @return the sort
	 */
	public String getSort() {
		return sort;
	}
	/**
	 * @param sort the sort to set
	 */
	public void setSort(String sort) {
		this.sort = sort;
	}
	/**
	 * @return the order
	 */
	public String getOrder() {
		return order;
	}
	/**
	 * @param order the order to set
	 */
	public void setOrder(String order) {
		this.order = order;
	}
	/**
	 * @return the defaultErrorMsg
	 */
	public String getDefaultErrorMsg() {
		return defaultErrorMsg;
	}
	/**
	 * @param defaultErrorMsg the defaultErrorMsg to set
	 */
	public void setDefaultErrorMsg(String defaultErrorMsg) {
		this.defaultErrorMsg = defaultErrorMsg;
	}
}
