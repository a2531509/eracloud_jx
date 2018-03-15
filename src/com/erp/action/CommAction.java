package com.erp.action;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.shiro.SecurityUtils;
import org.apache.struts2.ServletActionContext;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.SysReport;
import com.erp.model.Users;
import com.erp.service.BaseService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.util.XmlBeanUtil;
import com.erp.viewModel.Page;
import com.erp.webservice.client.SealServiceStub;
import com.erp.webservice.server.bean.Response;
import com.opensymphony.xwork2.Action;

@SuppressWarnings("serial")
public class CommAction extends BaseAction{
	private static final Log logger = LogFactory.getLog(CommAction.class);
	@Autowired
	private BaseService baseService;
	
	//保留老版打印报表开始
	private String reportFile;
    private Map<String,String> reportParameter = new HashMap<String,String>();
    private List<Object> reportDataList = new ArrayList<Object>();
    private Long actionNo;
    private String errMsg;
    private String innerReportFileName;
    private Map<String,String> innerReportParameter = new HashMap<String,String>();
    private List<Object> innerReportDataList = new ArrayList<Object>();
    private String brchId;
    private String orgId;
    private String codeType;
    private String codeValues;
    private Boolean isShowAll = false;
    private Boolean isShowDefaultOption = true;
    private Boolean isJudgePermission = true;
    private Boolean isOnlyDefault = false;
    private String isShowOrg = "1";
    private String branch_Id = "";
    private String org_Id = "";
    private String region_Id = "",town_Id = "",comm_Id="";
    private String tablename="",colvalue="",colname="",value="";
    private String school_Id,grade_Id,classes_Id;//学校，年级，班级
    
	private Boolean twoinput=true;
	@SuppressWarnings("unchecked")
	public Map<String,String> getReportParameter() {
		if(reportParameter == null || reportParameter.size() <= 0){
			reportParameter = (Map<String,String>) SecurityUtils.getSubject().getSession().getAttribute("_CURRENT_REPORT_PARAMETERS");
		}
		return reportParameter;
	}
	public String getReportFile() {
		if(Tools.processNull(reportFile).replaceAll("/\\s/g","").equals("")){
			this.reportFile = (String) SecurityUtils.getSubject().getSession().getAttribute("_CURRENT_REPORT_FILENAME");
		}
		return reportFile;
	}
	@SuppressWarnings("unchecked")
	public List<Object> getReportDataList() {
		reportDataList = (List<Object>) SecurityUtils.getSubject().getSession().getAttribute("_CURRENT_REPORT_DATALIST");
		return reportDataList;
	}
	public CommAction() {
		super();
	}
	public String execute(){
		try{
			//1.条件判断
			if(Tools.processNull(actionNo).equals("")){
				throw new CommonException("打印报表，流水actionNo不能为空！");
			}
			SysReport report = (SysReport) baseService.findOnlyRowByHql("from SysReport t where t.dealNo = " + actionNo);
			if(report == null){
				throw new CommonException("根据流水号:" + actionNo + " ,未获取到报表信息,该流水未保存报表信息或传入流水错误。");
			}
			//判断报表类型
			if(report.getFormat().equals(Constants.APP_REPORT_TYPE_PDF2)){
				ServletOutputStream outs = this.response.getOutputStream();
				response.setCharacterEncoding("UTF-8");
				response.setContentType("application/pdf");
				byte[] tempcontent = report.getPdfContent();
				response.setContentLength(tempcontent.length);
				outs.write(tempcontent);
				outs.flush();
				outs.close();
				return null;
			}else if(report.getFormat().equals(Constants.APP_REPORT_TYPE_PDF)){
				//2.获取报表参数
				JSONObject jsonreport = JSONObject.parseObject(report.getContent());
				Set<?> set = jsonreport.keySet();
				Iterator<?> it = set.iterator();
				Map<String,String> tempMap = new HashMap<String, String>();
				while(it.hasNext()){
					String key = it.next().toString();
					tempMap.put(key,jsonreport.get(key).toString());
				}
				//重设打印时间
				tempMap.put("p_printTime",com.erp.util.DateUtil.formatDate(baseService.getDateBaseTime(),"yyyy-MM-dd HH:mm:ss"));
				setInnerReportParameter(tempMap);//设置报表参数
				setInnerReportFileName(report.getFileName());
				//throw new Exception("根据流水号actionNo=" + actionNo + " ,未获取到报表信息,该流水未保存报表信息或传入流水错误。");
				return "innerPdfreport";
			}else{
				throw new CommonException("未处理的报表类型");
			}
		}catch(Exception e){
			errMsg = e.getMessage();
			return Action.INPUT;
		}
	}
	
	
	public String viewQm(){
		try{
			//1.条件判断
			if(Tools.processNull(actionNo).equals("")){
				throw new CommonException("打印报表，流水actionNo不能为空！");
			}
			SysReport report = (SysReport) baseService.findOnlyRowByHql("from SysReport t where t.dealNo = " + actionNo);
			if(report == null){
				throw new CommonException("根据流水号dealNo=" + actionNo + " ,未获取到报表信息,该流水未保存报表信息或传入流水错误。");
			}
			Response responseBean=new Response();
			SealServiceStub stub=new SealServiceStub();
			SealServiceStub.ModelAutoMerger modelAutoMerger=new SealServiceStub.ModelAutoMerger();
			String actionNos=actionNo+"";
			String smlStr="<?xml version='1.0' encoding='utf-8' ?><Request><LSH>"+actionNos+"</LSH></Request>";
			modelAutoMerger.setXmlStr(smlStr);
			String xmls=stub.modelAutoMerger(modelAutoMerger).get_return();
			//System.out.println(xmls);
			responseBean = (Response) XmlBeanUtil.xml2java(xmls, "Response", Response.class);
			if (!Tools.processNull(responseBean.getRET_CODE()).equals("0")){
				throw new CommonException("根据流水号:" + actionNo + " ,未获取到报表信息");
			}
			if (Tools.processNull(responseBean.getPDFBASE64()).equals("")){
				throw new CommonException("根据流水号:" + actionNo + " ,未获取到报表信息");
			}
			ServletOutputStream outs = this.response.getOutputStream();
			response.setCharacterEncoding("UTF-8");
			response.setContentType("application/pdf");
			//byte[] tempcontent = report.getPdfContent();
			byte[] tempcontent =com.erp.webservice.client.Base64.decode(responseBean.getPDFBASE64());
			response.setContentLength(tempcontent.length);
			outs.write(tempcontent);
			outs.flush();
			outs.close();
			return null;
			
		}catch(Exception e){
			logger.error(e);
			errMsg = e.getMessage();
			return Action.INPUT;
		}
	}
	//获取当前报表
	public String showPDF(){
	    return Action.SUCCESS;
	}
	//获取所有机构下拉框
	public String getAllOrgId(){
		JSONArray array = new JSONArray();
		try{
			List orgs = baseService.findBySql("select t.org_id,t.org_name,t.ORG_CLASS  from sys_organ t where t.ORG_STATE = '0' " + baseService.getLimitSysOrganQueryData("t.org_id"));
			if(orgs != null && orgs.size() > 0){
				if(orgs.size() > 1){
					JSONObject defaultRow = new JSONObject();
					defaultRow.put("org_Id","");
					defaultRow.put("org_Name","请选择");
					array.add(defaultRow);
				}
				for (Object object : orgs) {
					JSONObject j = new JSONObject();
					Object[] row = (Object[]) object;
					j.put("org_Id",row[0]);
					j.put("org_Name",row[1]);
					j.put("leval",row[2]);
					array.add(j);
				}
			}else{
				JSONObject j = new JSONObject();
				j.put("org_Id","erp2_erp2");
				j.put("org_Name","请选择");
				array.add(j);
			}
		}catch(Exception e){
			JSONObject j = new JSONObject();
			j.put("org_Id","0");
			j.put("org_Name","网点加载失败");
			array.add(j);
		}
		String json = array.toJSONString();
		PrintWriter out = null;
		HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
		httpServletResponse.setContentType("application/json");
		httpServletResponse.setCharacterEncoding("utf-8");
		try {
			out = httpServletResponse.getWriter();
		} catch (IOException e) {
			e.printStackTrace();
		}
		out.print(json);
		out.close();
		return null;
	}
	//下拉框获取所有网点
	@SuppressWarnings("rawtypes")
	public String getAllBranchs(){
		JSONArray array = new JSONArray();
		try{
			String sql = "select t.brch_id,t.full_name,t.assistant_manager  from SYS_BRANCH t where t.status = 'A' ";
			if(!"".equals(Tools.processNull(org_Id))){
				sql+="and t.org_Id ='"+org_Id+"'";
			}
			sql+= baseService.getLimitSysBranchQueryData("t.brch_id");
			List branchs = baseService.findBySql(sql);
			if(branchs != null && branchs.size() > 0){
				if(branchs.size() > 1){
					JSONObject defaultRow = new JSONObject();
					defaultRow.put("branch_Id","");
					defaultRow.put("branch_Name","请选择");
					array.add(defaultRow);
				}
				for (Object object : branchs) {
					JSONObject j = new JSONObject();
					Object[] row = (Object[]) object;
					j.put("branch_Id",row[0]);
					j.put("branch_Name",row[1]);
					j.put("leval",row[2]);
					array.add(j);
				}
			}else{
				JSONObject j = new JSONObject();
				j.put("branch_Id","erp2_erp2");
				j.put("branch_Name","请选择");
				array.add(j);
			}
		}catch(Exception e){
			JSONObject j = new JSONObject();
			j.put("branch_Id","0");
			j.put("branch_Name","网点加载失败");
			array.add(j);
		}
		findAllSysBranch();
		String json = array.toJSONString();
		PrintWriter out = null;
		HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
		httpServletResponse.setContentType("application/json");
		httpServletResponse.setCharacterEncoding("utf-8");
		try {
			out = httpServletResponse.getWriter();
		} catch (IOException e) {
			e.printStackTrace();
		}
		out.print(json);
		out.close();
		return null;
	}
	/**
	 * 获取机构下拉框
	 * @version 2.0
	 * @return
	 */
	public String findAllSysOrg(){
		jsonObject.put("status","0");
		jsonObject.put("msg","");
		JSONArray allOptions = new JSONArray();
		try{
			String where = "";
			String startwith = "";
			if(isJudgePermission){
				Users user = baseService.getUser();
				if(Constants.SYS_OPERATOR_LEVEL_ADMIN == user.getDutyId()){
					startwith = " t.parent_org_id is null ";
				}else if(Constants.SYS_OPERATOR_LEVEL_ORGAN == user.getDutyId()){
					startwith = " t.org_id = '" + user.getOrgId() + "' ";
					where = " and t.org_id = '" + user.getOrgId() + "' ";
				}else if(Constants.SYS_OPERATOR_LEVEL_ORGANALL == user.getDutyId()){
					startwith = " t.org_id = '" + user.getOrgId() + "' ";
				}else{
					startwith = " t.org_id = '" + user.getOrgId() + "' ";
					where = " and t.org_id = '" + user.getOrgId() + "' ";
				}
			}else{
				startwith = " t.parent_org_id is null ";
			}
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT distinct t.org_id,t.org_name,t.parent_org_id,level,connect_by_isleaf ");
			sb.append("from SYS_ORGAN t where 1 = 1 " + where);
			sb.append("START WITH " + startwith + " CONNECT BY PRIOR t.org_id =  t.parent_org_id ");
			List<?> allOrgs = baseService.findBySql(sb.toString());
			if(allOrgs != null && allOrgs.size() > 0){
				if(allOrgs.size() > 1){
					isShowDefaultOption = true;
				}
				Iterator<?> it = allOrgs.iterator();
				int isFirstOptionIndex = 0;
				while(it.hasNext()){
					Object[] tempRow = (Object[]) it.next();
					if(Tools.processNull(tempRow[3]).equals("1")){
						JSONObject tempObj = new JSONObject();
						tempObj.put("id",Tools.processNull(tempRow[0]));
						tempObj.put("text",Tools.processNull(tempRow[1]));
						tempObj.put("pid",Tools.processNull(tempRow[2]));
						tempObj.put("leval",Tools.processNull(tempRow[3]));
						tempObj.put("iconCls","icon-blank");
						if(isFirstOptionIndex >= 1 && Tools.processNull(tempRow[4]).equals("0")){
							tempObj.put("state","closed");
						}
						allOptions.add(tempObj);
						it.remove();
					}
					isFirstOptionIndex++;
				}
				getSysOrgJsonTree(allOptions,allOrgs,0);
			}else{
				isShowDefaultOption = false;
				JSONObject limitOption = new JSONObject();
				limitOption.put("id","erp2_erp2");
				limitOption.put("text","请选择");
				limitOption.put("iconCls","icon-blank");
				allOptions.add(limitOption);
			}
			if(isShowDefaultOption){
				JSONObject defaultOption = new JSONObject();
				defaultOption.put("id","");
				defaultOption.put("text","请选择");
				defaultOption.put("iconCls","icon-blank");
				allOptions.add(0,defaultOption);
			}
			//throw new CommonException("dee");
		}catch(Exception e){
			JSONObject errOption = new JSONObject();
			errOption.put("id","erp2_erp2");
			errOption.put("text","机构加载失败，请在刷新页面后重试！");
			errOption.put("iconCls","icon-blank");
			allOptions.add(0,errOption);
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
			this.saveErrLog(e);
		}
		jsonObject.put("rows",allOptions);
		return this.JSONOBJ;
	}
	/**
	 * 构建机构tree
	 * @param allOptions
	 * @param allBranchs
	 * @param index
	 * @throws CommonException
	 */
	public void getSysOrgJsonTree(JSONArray allOptions,List<?> allOrgs,int index) throws CommonException{
		try{
			if(allOptions == null || allOptions.size() <= 0){
				return;
			}
			if(allOrgs == null || allOrgs.size() <= 0){
				return;
			}
			Iterator<?> it = allOptions.iterator();
			while(it.hasNext()){
				JSONObject tempOption = (JSONObject) it.next();
				JSONArray oneChilds = new JSONArray();
				Iterator<?> allRowsIt = allOrgs.iterator();
				while(allRowsIt.hasNext()){
					Object[] tempRow = (Object[]) allRowsIt.next();
					if(Tools.processNull(tempRow[2]).equals(tempOption.getString("id"))){
						JSONObject tempObj = new JSONObject();
						tempObj.put("id",Tools.processNull(tempRow[0]));
						tempObj.put("text",Tools.processNull(tempRow[1]));
						tempObj.put("pid",Tools.processNull(tempRow[2]));
						tempObj.put("leval",Tools.processNull(tempRow[3]));
						tempObj.put("iconCls","icon-blank");
						if(index > 0 && Tools.processNull(tempRow[4]).equals("0")){
							tempObj.put("state","closed");
						}
						oneChilds.add(tempObj);
						allRowsIt.remove();
					}
				}
				if(oneChilds != null && oneChilds.size() > 0){
					getSysOrgJsonTree(oneChilds,allOrgs,index);
				}
				tempOption.put("children",oneChilds);
				index++;
			}
		}catch(Exception e){
			throw new CommonException(e);
		}
	}
	/**
	 * 获取网点下拉框
	 * @version 2.0
	 * @return
	 */
	public String findAllSysBranch(){
		jsonObject.put("status","0");
		jsonObject.put("msg","");
		JSONArray allOptions = new JSONArray();
		boolean isShowDefaultOption = false;
		try{
			if(!Tools.processNull(isShowOrg).equals("0") || !Tools.processNull(orgId).equals("")){
				String where = " t.status = 'A' ";
				if(!Tools.processNull(orgId).equals("")){
					where = "t.org_id = '" + orgId + "'";
				}
				String startwith = "";
				if(isJudgePermission){
					Users user = baseService.getUser();
					if(Constants.SYS_OPERATOR_LEVEL_COMMON == user.getDutyId()){
						startwith += "brch_id = '" + user.getBrchId() + "' ";
						where += "and brch_id = '" + user.getBrchId() + "' ";
					}else if(Constants.SYS_OPERATOR_LEVEL_BRANCH == user.getDutyId()){
						startwith += "brch_id = '" + user.getBrchId() + "' ";
						where += "and brch_id = '" + user.getBrchId() + "' ";
					}else if(Constants.SYS_OPERATOR_LEVEL_BRANCHALL == user.getDutyId()){
						startwith += "brch_id = '" + user.getBrchId() + "' ";
					}else if(Constants.SYS_OPERATOR_LEVEL_ORGAN == user.getDutyId()){
						startwith += "pid is null and t.org_id = '" + user.getOrgId() + "' ";
					}else if(Constants.SYS_OPERATOR_LEVEL_ORGANALL == user.getDutyId()){
						startwith += "pid is null ";
						where = baseService.getLimitSysBranchQueryData("brch_id");
					}else if(Constants.SYS_OPERATOR_LEVEL_ADMIN == user.getDutyId()){
						startwith += "pid is null ";
					}else{
						startwith = "brch_id = 'erp2_erp2' ";
					}
				}else{
					startwith += "pid is null ";
				}
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT distinct t.sysbranch_id,t.brch_id,t.full_name,t.pid,level,connect_by_isleaf,nvl(is_lk_brch, 1) ");
				sb.append("from SYS_BRANCH t where ").append(where).append("START WITH ").append(startwith);
				sb.append(" CONNECT BY PRIOR t.sysbranch_id =  t.pid order by t.brch_id asc ");
				List<?> allBranchs = baseService.findBySql(sb.toString());
				if(allBranchs != null && allBranchs.size() > 0){
					if(allBranchs.size() > 1){
						isShowDefaultOption = true;
					}
					Iterator<?> it = allBranchs.iterator();
					int isFirstOptionIndex = 0;
					while(it.hasNext()){
						Object[] tempRow = (Object[]) it.next();
						if(Tools.processNull(tempRow[4]).equals("1")){
							JSONObject tempObj = new JSONObject();
							tempObj.put("sysbranchId",Tools.processNull(tempRow[0]));
							tempObj.put("id",Tools.processNull(tempRow[1]));
							tempObj.put("text",Tools.processNull(tempRow[2]));
							tempObj.put("pid",Tools.processNull(tempRow[3]));
							tempObj.put("leval",Tools.processNull(tempRow[4]));
							tempObj.put("iconCls","icon-blank");
							if(isFirstOptionIndex >= 1 && Tools.processNull(tempRow[5]).equals("0")){
								tempObj.put("state","closed");
							}
							allOptions.add(tempObj);
							it.remove();
							isFirstOptionIndex++;
						}
					}
					getSysBranchJsonTree(allOptions,allBranchs,0);
				}else{
					isShowDefaultOption = false;
					JSONObject limitOption = new JSONObject();
					limitOption.put("id","erp2_erp2");
					limitOption.put("text","请选择");
					limitOption.put("iconCls","icon-blank");
					allOptions.add(limitOption);
				}
			}else{
				isShowDefaultOption = true;
			}
			if(isShowDefaultOption){
				JSONObject defaultOption = new JSONObject();
				defaultOption.put("id","");
				defaultOption.put("text","请选择");
				defaultOption.put("iconCls","icon-blank");
				allOptions.add(0,defaultOption);
			}
		}catch(Exception e){
			JSONObject errOption = new JSONObject();
			errOption.put("id","erp2_erp2");
			errOption.put("text","网点加载失败，请在刷新页面后重试！");
			errOption.put("iconCls","icon-blank");
			allOptions.add(0,errOption);
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
			this.saveErrLog(e);
		}
		jsonObject.put("rows",allOptions);
		return this.JSONOBJ;
	}
	/**
	 * 获取领卡网点下拉框
	 * @version 2.0
	 * @return
	 */
	public String findAllRecvBranch(){
		jsonObject.put("status","0");
		jsonObject.put("msg","");
		JSONArray allOptions = new JSONArray();
		boolean isShowDefaultOption = false;
		try{
			String bankId_ = this.request.getParameter("bankId");
			String brchId_ = this.request.getParameter("brchId");
			String where = "";
			String startwith = " 1 = 1 ";
			if(!Tools.processNull(bankId_).equals("")){
				if(Tools.processNull(bankId_).equals("100003000000001")){
					startwith += "and s.brch_id = '20200000' ";
				}else if(Tools.processNull(bankId_).equals("100003000000002")){
					startwith += "and s.brch_id = '20700000' ";
				}else if(Tools.processNull(bankId_).equals("100003000000003")){
					startwith += "and s.brch_id = '20600000' ";
				}else if(Tools.processNull(bankId_).equals("100003000000004")){
					startwith += "and s.brch_id = '20300000' ";
				}else if(Tools.processNull(bankId_).equals("100003000000005")){
					startwith += "and s.brch_id = '20500000' ";
				}else if(Tools.processNull(bankId_).equals("100003000000006")){
					startwith += "and s.brch_id = '20400000' ";
				}else if(Tools.processNull(bankId_).equals("100003000000007")){
					startwith += "and s.brch_id = '20000000' ";
				}else if(Tools.processNull(bankId_).equals("100003000000008")){
					startwith += "and s.brch_id = '20010100' ";
				}else if(Tools.processNull(bankId_).equals("100003000000009")){
					startwith += "and s.brch_id = '20060100' ";
				}else if(Tools.processNull(bankId_).equals("100003000000010")){
					startwith += "and s.brch_id = '20020100' ";
				}else if(Tools.processNull(bankId_).equals("100003000000011")){
					startwith += "and s.brch_id = '20050100' ";
				}else if(Tools.processNull(bankId_).equals("100003000000012")){
					startwith += "and s.brch_id = '20040100' ";
				}else if(Tools.processNull(bankId_).equals("100003000000013")){
					startwith += "and s.brch_id = '20030100' ";
				}else if(Tools.processNull(bankId_).equals("100101100100936")){
					startwith += "and s.brch_id = '20800000' ";
				}else if(Tools.processNull(bankId_).equals("100101100100939")){
					startwith += "and s.brch_id = '21000000' ";
				}else if(Tools.processNull(bankId_).equals("100101100100933")){
					startwith += "and s.brch_id = '20900000' ";
				}
			}else{
				if(!Tools.processNull(brchId_).equals("")){
					startwith += "and s.brch_id = '" + brchId_ + "' ";
				}else{
					startwith += "and s.brch_id = '20000000' ";
				}
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select distinct s.sysbranch_id,s.brch_id,s.full_name,s.pid,level,connect_by_isleaf, nvl(is_lk_brch, 1) ");
			sb.append("from sys_branch s where 1 = 1  ").append(where).append("start with ").append(startwith);
			sb.append("connect by prior s.sysbranch_id =  s.pid order by s.brch_id asc ");
			List<?> allBranchs = baseService.findBySql(sb.toString());
			if(allBranchs != null && allBranchs.size() > 0){
				if(allBranchs.size() > 1){
					isShowDefaultOption = true;
				}
				Iterator<?> it = allBranchs.iterator();
				int isFirstOptionIndex = 0;
				while(it.hasNext()){
					Object[] tempRow = (Object[]) it.next();
					if(Tools.processNull(tempRow[4]).equals("1")){
						JSONObject tempObj = new JSONObject();
						tempObj.put("sysbranchId",Tools.processNull(tempRow[0]));
						tempObj.put("id",Tools.processNull(tempRow[1]));
						tempObj.put("text",Tools.processNull(tempRow[2]));
						tempObj.put("pid",Tools.processNull(tempRow[3]));
						tempObj.put("leval",Tools.processNull(tempRow[4]));
						tempObj.put("iconCls","icon-blank");
						if(isFirstOptionIndex >= 1 && Tools.processNull(tempRow[5]).equals("0")){
							tempObj.put("state","closed");
						}
						allOptions.add(tempObj);
						it.remove();
						isFirstOptionIndex++;
					}
				}
				getSysBranchJsonTree(allOptions,allBranchs,0);
			}else{
				isShowDefaultOption = false;
				JSONObject limitOption = new JSONObject();
				limitOption.put("id","erp2_erp2");
				limitOption.put("text","请选择");
				limitOption.put("iconCls","icon-blank");
				allOptions.add(limitOption);
			}
			if(isShowDefaultOption){
				JSONObject defaultOption = new JSONObject();
				defaultOption.put("id","");
				defaultOption.put("text","请选择");
				defaultOption.put("iconCls","icon-blank");
				allOptions.add(0,defaultOption);
			}
			jsonObject.put("brchId",baseService.getUser().getBrchId());
			jsonObject.put("bankId",bankId_);
		}catch(Exception e){
			JSONObject errOption = new JSONObject();
			errOption.put("id","erp2_erp2");
			errOption.put("text","领卡网点加载失败，请在刷新页面后重试！");
			errOption.put("iconCls","icon-blank");
			allOptions.add(0,errOption);
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
			this.saveErrLog(e);
		}
		jsonObject.put("rows",allOptions);
		return this.JSONOBJ;
	}
	/**
	 * 构建网点tree
	 * @param allOptions
	 * @param allBranchs
	 * @param index
	 * @throws CommonException
	 */
	public void getSysBranchJsonTree(JSONArray allOptions,List<?> allBranchs,int index) throws CommonException{
		try{
			if(allOptions == null || allOptions.size() <= 0){
				return;
			}
			if(allBranchs == null || allBranchs.size() <= 0){
				return;
			}
			Iterator<?> it = allOptions.iterator();
			while(it.hasNext()){
				JSONObject tempOption = (JSONObject) it.next();
				JSONArray oneChilds = new JSONArray();
				Iterator<?> allRowsIt = allBranchs.iterator();
				while(allRowsIt.hasNext()){
					Object[] tempRow = (Object[]) allRowsIt.next();
					if(Tools.processNull(tempRow[3]).equals(tempOption.getString("sysbranchId"))){
						JSONObject tempObj = new JSONObject();
						tempObj.put("sysbranchId",Tools.processNull(tempRow[0]));
						tempObj.put("id",Tools.processNull(tempRow[1]));
						tempObj.put("text",Tools.processNull(tempRow[2]));
						tempObj.put("pid",Tools.processNull(tempRow[3]));
						tempObj.put("leval",Tools.processNull(tempRow[4]));
						tempObj.put("iconCls","icon-blank");
						if(index > 0 && Tools.processNull(tempRow[5]).equals("0")){
							tempObj.put("state","closed");
						}
						if(tempRow.length > 6){
							tempObj.put("isLkBrch",Tools.processNull(tempRow[6]));
						}
						oneChilds.add(tempObj);
						allRowsIt.remove();
					}
				}
				if(oneChilds != null && oneChilds.size() > 0){
					getSysBranchJsonTree(oneChilds,allBranchs,index);
				}
				tempOption.put("children",oneChilds);
				index++;
			}
		}catch(Exception e){
			throw new CommonException(e);
		}
	}
	/**
	 * 构建SYS_CODE下拉框
	 * @return
	 */
	public String findSysCodeByCodeType(){
		jsonObject.put("status","0");
		jsonObject.put("msg","");
		JSONArray allOptions = new JSONArray();
		try{
			if(!Tools.processNull(this.codeType).trim().equals("")){
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT CODE_NAME TEXT,CODE_VALUE VALUE FROM SYS_CODE WHERE CODE_TYPE = '" + this.codeType + "' ");
				String initvalues = "";
				if(!Tools.processNull(this.codeValues).trim().equals("")){
					String[] vs = this.codeValues.split(",");
					for (String string : vs) {
						initvalues += "'" + string + "',";
					}
					initvalues = initvalues.substring(0,initvalues.length() - 1);
				}
				if(!Tools.processNull(initvalues).equals("")){
					sb.append("AND CODE_VALUE IN (" + initvalues + ") ");
				}
				if(!isShowAll){
					sb.append("AND CODE_STATE = '0' ");
				}
				sb.append("ORDER BY ORD_NO ASC ");
				Page list = baseService.pagingQuery(sb.toString(),1,500);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					allOptions.addAll(list.getAllRs());
				}else{
					isShowDefaultOption = true;
				}
			}else{
				isShowDefaultOption = true;
			}
			if(isShowDefaultOption){
				JSONObject defaultOption = new JSONObject();
				defaultOption.put("VALUE","");
				defaultOption.put("TEXT","请选择");
				allOptions.add(0,defaultOption);
			}
		}catch(Exception e){
			JSONObject errOption = new JSONObject();
			errOption.put("VALUE","erp2_erp2");
			errOption.put("TEXT","加载失败，请进行刷新！");
			allOptions.add(0,errOption);
			jsonObject.put("status","1");
			jsonObject.put("msg","初始化下拉框出现错误，请刷新页面重试！");
			this.saveErrLog(e);
		}
		jsonObject.put("rows",allOptions);
		return this.JSONOBJ;
	}
	/**
	 * 自定义下拉框
	 * @return
	 */
	public String findAllCustomCodeType(){
		jsonObject.put("status","0");
		jsonObject.put("msg","");
		JSONArray allOptions = new JSONArray();
		try{
			String value_ = this.request.getParameter("value");
			String text_ = this.request.getParameter("text");
			String table_ = this.request.getParameter("table");
			String where_ =  this.request.getParameter("where");
			String orderby_ = this.request.getParameter("orderby");
			String from_ = this.request.getParameter("from");
			String to_ = this.request.getParameter("to");
			if(!isOnlyDefault && !Tools.processNull(value_).equals("") && !Tools.processNull(text_).equals("") && !Tools.processNull(table_).equals("")){
				StringBuffer sb  = new StringBuffer();
				sb.append("select ").append(value_).append(" value,");
				sb.append(text_).append(" text").append(" from ");
				sb.append(table_ + " ");
				if(!Tools.processNull(where_).equals("")){
					sb.append("where " + where_ + " ");
				}
				if(!Tools.processNull(orderby_).equals("")){
					sb.append("order by " + orderby_);
				}
				if(Tools.processNull(from_).equals("")){
					from_ = "0";
				}
				if(Tools.processNull(to_).equals("")){
					to_ = "1000";
				}
				Page list = baseService.pagingQuery(sb.toString(),Integer.valueOf(from_),Integer.valueOf(to_));
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					allOptions.addAll(list.getAllRs());
				}else{
					isShowDefaultOption = true;
				}
			}else{
				isShowDefaultOption = true;
			}
			if(isShowDefaultOption){
				JSONObject defaultOption = new JSONObject();
				defaultOption.put("VALUE","");
				defaultOption.put("TEXT","请选择");
				allOptions.add(0,defaultOption);
			}
		}catch(Exception e){
			JSONObject errOption = new JSONObject();
			errOption.put("VALUE","erp2_erp2");
			errOption.put("TEXT","加载失败，请进行刷新！");
			allOptions.add(0,errOption);
			jsonObject.put("status","1");
			jsonObject.put("msg","初始化下拉框出现错误，请刷新页面重试！");
			this.saveErrLog(e);
		}
		jsonObject.put("rows",allOptions);
		return this.JSONOBJ;
	}
	/**
	 * 自定义下拉框
	 * @return
	 */
	public String findAllCustomAuto(){
		jsonObject.put("status","0");
		jsonObject.put("msg","");
		JSONArray allOptions = new JSONArray();
		try{
			String value_ = this.request.getParameter("value");
			String text_ = this.request.getParameter("text");
			String table_ = this.request.getParameter("table");
			String keyColumn_ =  this.request.getParameter("keyColumn");
			String keyValue_ =  this.request.getParameter("keyValue");
			String where_ =  this.request.getParameter("where");
			String orderby_ = this.request.getParameter("orderby");
			String from_ = this.request.getParameter("from");
			String to_ = this.request.getParameter("to");
			boolean optimize_ = false;
			if(!Tools.processNull(this.request.getParameter("optimize")).equals("")){
				optimize_ = Boolean.valueOf(this.request.getParameter("optimize"));
			}
			keyColumn_ = Tools.processNull(keyColumn_).replace("['\"]","");
			keyValue_ = Tools.processNull(keyValue_).replace("['\"]","");
			if(!Tools.processNull(text_).equals("") && !Tools.processNull(table_).equals("") && 
			   !Tools.processNull(keyColumn_).equals("") && !Tools.processNull(keyValue_).equals("")){
				StringBuffer sb  = new StringBuffer();
				sb.append("select ").append(text_).append(" text_,");
				if(Tools.processNull(value_).equals("")){
					value_ = text_;
				}
				sb.append(value_).append(" value_").append(" ");
				sb.append("from " + table_ + " where 1 = 1 ");
				if(!Tools.processNull(where_).equals("")){
					sb.append("and " + where_ + " ");
				}
				if(Tools.processNull(table_).toLowerCase().equals("base_corp")){
					sb.append(" and corp_state = '0'");
				}
				if(!Tools.processNull(keyColumn_).equals("") && !Tools.processNull(keyValue_).equals("")){
					String[] keyColumn_Arr = keyColumn_.split(",");
					String likeSql = "and (";
					for (int i = 0; i < keyColumn_Arr.length; i++) {
						if(optimize_ || Tools.processNull(table_).toLowerCase().equals("base_personal")){
							likeSql += keyColumn_Arr[i] + " like '" + keyValue_ + "%'";
						}else{
							likeSql += "instr(" + keyColumn_Arr[i] + ",'" + keyValue_ + "',1,1) > 0";
						}
						if(i != keyColumn_Arr.length - 1){
							likeSql += " or ";
						}
					}
					likeSql += ") ";
					sb.append(likeSql);
				}
				if(!Tools.processNull(orderby_).equals("")){
					sb.append("order by " + orderby_);
				}
				if(Tools.processNull(from_).equals("")){
					from_ = "0";
				}
				if(Tools.processNull(to_).equals("")){
					to_ = "30";
				}
				Page list = baseService.pagingQuery(sb.toString(),Integer.valueOf(from_),Integer.valueOf(to_));
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					allOptions.addAll(list.getAllRs());
				}
			}
		}catch(Exception e){
			this.saveErrLog(e);
		}
		jsonObject.put("rows",allOptions);
		return this.JSONOBJ;
	}
	/**
	 * 获取所有的交易代码
	 * @return
	 */
	public String findAllDealCodes(){
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("select (");
			sb.append("case substr(t.deal_code,1,4) ");
			sb.append("when '1010' then '客户管理服务类' ");
			sb.append("when '1020' then '商户管理服务类' ");
			sb.append("when '1030' then '合作机构管理服务类' ");
			sb.append("when '1040' then '设备管理类' ");
			sb.append("when '1050' then '库房类' ");
			sb.append("when '1060' then '现金类' ");
			sb.append("when '1080' then '信息发布类' ");
			sb.append("when '1090' then '其他' ");
			sb.append("when '2010' then '产品规划类' ");
			sb.append("when '2020' then '采购类' ");
			sb.append("when '2030' then '生产类' ");
			sb.append("when '2040' then '申领发放类' ");
			sb.append("when '2050' then '服务类' ");
			sb.append("when '2060' then 'Psam卡管理类' ");
			sb.append("when '2090' then '其他' ");
			sb.append("when '3010' then '现金充值类' ");
			sb.append("when '3020' then '支票充值类' ");
			sb.append("when '3030' then '银行卡充值类' ");
			sb.append("when '3040' then '第三方账户充值类' ");
			sb.append("when '3050' then '充值卡充值类' ");
			sb.append("when '3090' then '其他' ");
			sb.append("when '4010' then '脱机账户消费类' ");
			sb.append("when '4020' then '联机账户消费类' ");
			sb.append("when '4030' then '终端管理类' ");
			sb.append("when '4090' then '其他' ");
			sb.append("when '5010' then '账户信息管理类' ");
			sb.append("when '5020' then '账户状态管理类' ");
			sb.append("when '5030' then '账户调整类' ");
			sb.append("when '5040' then '账户消费额度' ");
			sb.append("when '5050' then '账户状态管理类' ");
			sb.append("when '5080' then '柜员现金管理类' ");
			sb.append("when '5090' then '其他' ");
			sb.append("when '6010' then '日终扎帐类' ");
			sb.append("when '6020' then '商户清分对账类' ");
			sb.append("when '6030' then '商户结算类' ");
			sb.append("when '6040' then '合作机构清分对账类' ");
			sb.append("when '6050' then '合作机构结算类' ");
			sb.append("when '6060' then '差错及争议处理类' ");
			sb.append("when '6070' then '积分管理类' ");
			sb.append("else '其他' ");
			sb.append("end) GCODE,t.deal_code CODE_VALUE,");
			sb.append("t.deal_code_name || '【' || t.deal_code || '】' CODE_NAME ");
			sb.append("from SYS_CODE_TR t WHERE t.state = '0' order by t.deal_code asc");
			Page l = baseService.pagingQuery(sb.toString(),1,1000);
		    JSONArray j = new JSONArray();
		    JSONObject de = new JSONObject();
		    de.put("CODE_VALUE","");
		    de.put("CODE_NAME","请选择");
		    j.add(de);
			if(l.getAllRs() != null && l.getAllRs().size() > 0){
				j.addAll(l.getAllRs());
			}
			response.setCharacterEncoding("UTF-8");
			response.setContentType("text/html");
			PrintWriter p = this.response.getWriter();
			p.write(j.toString());
			p.flush();
			p.close();
		}catch(Exception e){
			e.printStackTrace();
		}
		return null;
	}
	/**
	 * 下拉框获取所有柜员
	 * @return
	 */
	@SuppressWarnings("rawtypes")
	public String getAllOperators(){
		JSONArray array = new JSONArray();
		try{
			Users ff = baseService.getUser();
			String where = "";
			if(isJudgePermission){
				if(ff.getDutyId() == Constants.SYS_OPERATOR_LEVEL_COMMON){
					where += " and t.user_id = '" + ff.getUserId() + "'";
				}
			}
			if(!Tools.processNull(branch_Id).equals("")){
				where += " and t.brch_Id = '" + branch_Id + "'";
				List branchs = baseService.findBySql("select t.user_id,t.name from SYS_USERS t where t.status = 'A'" + where);
				if(branchs != null && branchs.size() > 0){
					if(branchs.size() > 1){
						JSONObject defaultRow = new JSONObject();
						defaultRow.put("user_Id","");
						defaultRow.put("user_Name","请选择");
						array.add(defaultRow);
					}
					for (Object object : branchs) {
						JSONObject j = new JSONObject();
						Object[] row = (Object[]) object;
						j.put("user_Id",row[0]);
						j.put("user_Name",row[1]);
						array.add(j);
					}
				}else{
					JSONObject j = new JSONObject();
					j.put("user_Id","erp2_erp2");
					j.put("user_Name","请选择");
					array.add(j);
				}
			}else{
				JSONObject j = new JSONObject();
				j.put("user_Id","");
				j.put("user_Name","请选择");
				array.add(j);
			}
		}catch(Exception e){
			JSONObject j = new JSONObject();
			j.put("user_Id","0");
			j.put("user_Name","柜员加载失败");
			array.add(j);
		}
		String json = array.toJSONString();
		PrintWriter out = null;
		HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
		httpServletResponse.setContentType("application/json");
		httpServletResponse.setCharacterEncoding("utf-8");
		try {
			out = httpServletResponse.getWriter();
		} catch (IOException e) {
			e.printStackTrace();
		}
		out.print(json);
		out.close();
		return null;
	}
	//构造城区，乡镇，社区三级下拉框
	//下拉框获取城区
	@SuppressWarnings("rawtypes")
	public String getAllRegion(){
		JSONArray array = new JSONArray();
		try{
			List regions = baseService.findBySql("select t.region_Id,t.region_Name  from base_region t where 1 = 1 " + (isShowAll ? " " : "and region_state = '0'" ) + " order by region_Id desc ");
			if(regions != null && regions.size() > 0){
				//如果只有一个下拉，请默认选中，没有必要选了，有锁多个下拉则显示--请选择--
				if(regions.size() > 0){
					JSONObject defaultRow = new JSONObject();
					defaultRow.put("region_Id","");
					defaultRow.put("region_Name","请选择");
					array.add(defaultRow);
				}
				for (Object object : regions) {
					JSONObject j = new JSONObject();
					Object[] row = (Object[]) object;
					j.put("region_Id",row[0]);
					j.put("region_Name",row[1]);
					array.add(j);
				}
			}else{
				JSONObject j = new JSONObject();
				j.put("region_Id","erp2_erp2");
				j.put("region_Name","请选择");
				array.add(j);
			}
		}catch(Exception e){
			JSONObject j = new JSONObject();
			j.put("region_Id","0");
			j.put("region_Name","城区加载失败");
			array.add(j);
		}
		String json = array.toJSONString();
		PrintWriter out = null;
		HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
		httpServletResponse.setContentType("application/json");
		httpServletResponse.setCharacterEncoding("utf-8");
		try {
			out = httpServletResponse.getWriter();
		} catch (IOException e) {
			e.printStackTrace();
		}
		out.print(json);
		out.close();
		return null;
	}
	//下拉框获取乡镇
	@SuppressWarnings("rawtypes")
	public String getAllTown(){
		JSONArray array = new JSONArray();
		try{
			String where = "";
			if(!Tools.processNull(region_Id).equals("")){
				where += " and t.region_Id = '" + region_Id + "'";
				List twons = baseService.findBySql("select t.town_Id,t.town_Name from base_town t where t.town_state = '0'" + where +" order by town_id ");
				if(twons != null && twons.size() > 0){
					//如果只有一个下拉，请默认选中，没有必要选了，有锁多个下拉则显示--请选择--
					if(twons.size() > 1){
						JSONObject defaultRow = new JSONObject();
						defaultRow.put("town_Id","");
						defaultRow.put("town_Name","请选择");
						array.add(defaultRow);
					}
					for (Object object : twons) {
						JSONObject j = new JSONObject();
						Object[] row = (Object[]) object;
						j.put("town_Id",row[0]);
						j.put("town_Name",row[1]);
						array.add(j);
					}
				}else{
					JSONObject j = new JSONObject();
					j.put("town_Id","");
					j.put("town_Name","请选择");
					array.add(j);
				}
			}else{
				JSONObject j = new JSONObject();
				j.put("town_Id","");
				j.put("town_Name","请选择");
				array.add(j);
			}
		}catch(Exception e){
			JSONObject j = new JSONObject();
			j.put("town_Id","0");
			j.put("town_Name","乡镇加载失败");
			array.add(j);
		}
		String json = array.toJSONString();
		PrintWriter out = null;
		HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
		httpServletResponse.setContentType("application/json");
		httpServletResponse.setCharacterEncoding("utf-8");
		try {
			out = httpServletResponse.getWriter();
		} catch (IOException e) {
			e.printStackTrace();
		}
		out.print(json);
		out.close();
		return null;
	}
	//下拉框获取社区
	@SuppressWarnings("rawtypes")
	public String getAllComm(){
		JSONArray array = new JSONArray();
		try{
			String where = "";
			if(!Tools.processNull(town_Id).equals("")){
				where += " and t.town_Id = '" + town_Id + "'";
				List twons = baseService.findBySql("select t.comm_Id,t.comm_Name from base_comm t where t.comm_state = '0'" + where +" order by comm_Id ");
				if(twons != null && twons.size() > 0){
					//如果只有一个下拉，请默认选中，没有必要选了，有锁多个下拉则显示--请选择--
					if(twons.size() > 1){
						JSONObject defaultRow = new JSONObject();
						defaultRow.put("comm_Id","");
						defaultRow.put("comm_Name","请选择");
						array.add(defaultRow);
					}
					for (Object object : twons) {
						JSONObject j = new JSONObject();
						Object[] row = (Object[]) object;
						j.put("comm_Id",row[0]);
						j.put("comm_Name",row[1]);
						array.add(j);
					}
				}else{
					JSONObject j = new JSONObject();
					j.put("comm_Id","");
					j.put("comm_Name","请选择");
					array.add(j);
				}
			}else{
				JSONObject j = new JSONObject();
				j.put("comm_Id","");
				j.put("comm_Name","请选择");
				array.add(j);
			}
		}catch(Exception e){
			JSONObject j = new JSONObject();
			j.put("comm_Id","0");
			j.put("comm_Name","社区加载失败");
			array.add(j);
		}
		String json = array.toJSONString();
		PrintWriter out = null;
		HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
		httpServletResponse.setContentType("application/json");
		httpServletResponse.setCharacterEncoding("utf-8");
		try {
			out = httpServletResponse.getWriter();
		} catch (IOException e) {
			e.printStackTrace();
		}
		out.print(json);
		out.close();
		return null;
	}
	//下拉框获取社区
		@SuppressWarnings("rawtypes")
		public String getAllGroup(){
			JSONArray array = new JSONArray();
			try{
				String where = "";
				if(!Tools.processNull(comm_Id).equals("")){
					where += " and t.comm_Id = '" + comm_Id + "'";
					List twons = baseService.findBySql("select t.group_Id,t.group_Name from base_group t where t.group_state = '0'" + where +" order by group_Id ");
					if(twons != null && twons.size() > 0){
						//如果只有一个下拉，请默认选中，没有必要选了，有锁多个下拉则显示--请选择--
						if(twons.size() > 1){
							JSONObject defaultRow = new JSONObject();
							defaultRow.put("group_Id","");
							defaultRow.put("group_Name","请选择");
							array.add(defaultRow);
						}
						for (Object object : twons) {
							JSONObject j = new JSONObject();
							Object[] row = (Object[]) object;
							j.put("group_Id",row[0]);
							j.put("group_Name",row[1]);
							array.add(j);
						}
					}else{
						JSONObject j = new JSONObject();
						j.put("group_Id","");
						j.put("group_Name","请选择");
						array.add(j);
					}
				}else{
					JSONObject j = new JSONObject();
					j.put("group_Id","");
					j.put("group_Name","请选择");
					array.add(j);
				}
			}catch(Exception e){
				JSONObject j = new JSONObject();
				j.put("group_Id","0");
				j.put("group_Name","组加载失败");
				array.add(j);
			}
			String json = array.toJSONString();
			PrintWriter out = null;
			HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
			httpServletResponse.setContentType("application/json");
			httpServletResponse.setCharacterEncoding("utf-8");
			try {
				out = httpServletResponse.getWriter();
			} catch (IOException e) {
				e.printStackTrace();
			}
			out.print(json);
			out.close();
			return null;
		}
	
    //下拉框获取银行信息
	@SuppressWarnings("rawtypes")
	public String getAllBanks(){
		JSONArray array = new JSONArray();
		try{
			List banks = baseService.findBySql("select t.bank_id,t.bank_name from base_bank t  where t.bank_state='0'");
			//判断当前柜员角色
			if(banks != null && banks.size() > 0){
				//如果只有一个下拉，请默认选中，没有必要选了，有锁多个下拉则显示--请选择--
				if(banks.size() > 1){
					JSONObject defaultRow = new JSONObject();
					defaultRow.put("branch_Id","");
					defaultRow.put("branch_Name","请选择");
					array.add(defaultRow);
				}
				for (Object object : banks) {
					JSONObject j = new JSONObject();
					Object[] row = (Object[]) object;
					j.put("bank_id",row[0]);
					j.put("bank_name",row[1]);
					array.add(j);
				}
			}else{
				JSONObject j = new JSONObject();
				j.put("bank_id","erp2_erp2");
				j.put("bank_name","请选择");
				array.add(j);
			}
		}catch(Exception e){
			JSONObject j = new JSONObject();
			j.put("bank_id","0");
			j.put("bank_name","银行加载失败");
			array.add(j);
		}
		String json = array.toJSONString();
		PrintWriter out = null;
		HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
		httpServletResponse.setContentType("application/json");
		httpServletResponse.setCharacterEncoding("utf-8");
		try {
			out = httpServletResponse.getWriter();
		} catch (IOException e) {
			e.printStackTrace();
		}
		out.print(json);
		out.close();
		return null;
	}
	//下拉框获取城区
		@SuppressWarnings("rawtypes")
		public String getSearchInputData(){
			JSONArray array = new JSONArray();
			try{
				//根据tablename表，查询条件colvalue列，查找显示结果colname
				List list =new ArrayList();
				if(!Tools.processNull(colname).equals(colvalue)){
					list=baseService.findBySql("select "+colname+","+colvalue+" from "+tablename+" where "+ (twoinput?colname:colvalue)+" like '%"+value+"%' and "+colname+" is not null and rownum <50 group by "+colname+","+colvalue);
				}else{
					list=baseService.findBySql("select "+colname+" from "+tablename+" where "+ (twoinput?colname:colvalue)+" like '%"+value+"%' and "+colname+" is not null and rownum <50 group by "+colname);
					
				}
				if(list != null && list.size() > 0){
					//如果只有一个下拉，请默认选中，没有必要选了，有锁多个下拉则显示--请选择--
					if(list.size() > 1){
						JSONObject defaultRow = new JSONObject();
						defaultRow.put(colname,"");
						defaultRow.put(colvalue,"请选择");
						array.add(defaultRow);
					}
					for (Object object : list) {
						JSONObject j = new JSONObject();
						Object[] row = (Object[]) object;
						j.put(colname,row[0]);
						j.put(colvalue,row[1]);
						array.add(j);
					}
				}else{
					JSONObject j = new JSONObject();
					j.put(colname,"");
					j.put(colvalue,"请选择");
					array.add(j);
				}
			}catch(Exception e){
				JSONObject j = new JSONObject();
				j.put(colname,"");
				j.put(colvalue,"请选择");
				array.add(j);
			}
			String json = array.toJSONString();
			PrintWriter out = null;
			HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
			httpServletResponse.setContentType("application/json");
			httpServletResponse.setCharacterEncoding("utf-8");
			try {
				out = httpServletResponse.getWriter();
			} catch (IOException e) {
				e.printStackTrace();
			}
			out.print(json);
			out.close();
			return null;
		}
		
		//下拉框获取城区
		@SuppressWarnings("rawtypes")
		public String getAllSchool(){
			JSONArray array = new JSONArray();
			try{
				List regions = baseService.findBySql("select t.school_Id,t.school_Name  from base_school t where t.school_state = '0' order by school_Id ");
				if(regions != null && regions.size() > 0){
					//如果只有一个下拉，请默认选中，没有必要选了，有锁多个下拉则显示--请选择--
					if(regions.size() > 1){
						JSONObject defaultRow = new JSONObject();
						defaultRow.put("school_Id","");
						defaultRow.put("school_Name","请选择");
						array.add(defaultRow);
					}
					for (Object object : regions) {
						JSONObject j = new JSONObject();
						Object[] row = (Object[]) object;
						j.put("school_Id",row[0]);
						j.put("school_Name",row[1]);
						array.add(j);
					}
				}else{
					JSONObject j = new JSONObject();
					j.put("school_Id","erp2_erp2");
					j.put("school_Name","请选择");
					array.add(j);
				}
			}catch(Exception e){
				JSONObject j = new JSONObject();
				j.put("school_Id","0");
				j.put("school_Name","学校加载失败");
				array.add(j);
			}
			String json = array.toJSONString();
			PrintWriter out = null;
			HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
			httpServletResponse.setContentType("application/json");
			httpServletResponse.setCharacterEncoding("utf-8");
			try {
				out = httpServletResponse.getWriter();
			} catch (IOException e) {
				e.printStackTrace();
			}
			out.print(json);
			out.close();
			return null;
		}
		//下拉框获取乡镇
		@SuppressWarnings("rawtypes")
		public String getAllGrade(){
			JSONArray array = new JSONArray();
			try{
				String where = "";
				if(!Tools.processNull(school_Id).equals("")){
					where += " and t.school_Id = '" + school_Id + "'";
					List twons = baseService.findBySql("select t.grade_Id,t.grade_Name from base_grade t where t.grade_state = '0'" + where +" order by grade_id ");
					if(twons != null && twons.size() > 0){
						//如果只有一个下拉，请默认选中，没有必要选了，有锁多个下拉则显示--请选择--
						if(twons.size() > 1){
							JSONObject defaultRow = new JSONObject();
							defaultRow.put("grade_Id","");
							defaultRow.put("grade_Name","请选择");
							array.add(defaultRow);
						}
						for (Object object : twons) {
							JSONObject j = new JSONObject();
							Object[] row = (Object[]) object;
							j.put("grade_Id",row[0]);
							j.put("grade_Name",row[1]);
							array.add(j);
						}
					}else{
						JSONObject j = new JSONObject();
						j.put("grade_Id","erp2_erp2");
						j.put("grade_Name","请选择");
						array.add(j);
					}
				}else{
					JSONObject j = new JSONObject();
					j.put("grade_Id","");
					j.put("grade_Name","请选择");
					array.add(j);
				}
			}catch(Exception e){
				JSONObject j = new JSONObject();
				j.put("grade_Id","0");
				j.put("grade_Name","年级加载失败");
				array.add(j);
			}
			String json = array.toJSONString();
			PrintWriter out = null;
			HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
			httpServletResponse.setContentType("application/json");
			httpServletResponse.setCharacterEncoding("utf-8");
			try {
				out = httpServletResponse.getWriter();
			} catch (IOException e) {
				e.printStackTrace();
			}
			out.print(json);
			out.close();
			return null;
		}
		//下拉框获取社区
		@SuppressWarnings("rawtypes")
		public String getAllClasses(){
			JSONArray array = new JSONArray();
			try{
				String where = "";
				if(!Tools.processNull(grade_Id).equals("")){
					where += " and t.grade_Id = '" + grade_Id + "'";
					List twons = baseService.findBySql("select t.classes_Id,t.classes_Name from base_classes t where t.classes_state = '0'" + where +" order by classes_Id ");
					if(twons != null && twons.size() > 0){
						//如果只有一个下拉，请默认选中，没有必要选了，有锁多个下拉则显示--请选择--
						if(twons.size() > 1){
							JSONObject defaultRow = new JSONObject();
							defaultRow.put("classes_Id","");
							defaultRow.put("classes_Name","请选择");
							array.add(defaultRow);
						}
						for (Object object : twons) {
							JSONObject j = new JSONObject();
							Object[] row = (Object[]) object;
							j.put("classes_Id",row[0]);
							j.put("classes_Name",row[1]);
							array.add(j);
						}
					}else{
						JSONObject j = new JSONObject();
						j.put("classes_Id","erp2_erp2");
						j.put("classes_Name","请选择");
						array.add(j);
					}
				}else{
					JSONObject j = new JSONObject();
					j.put("classes_Id","");
					j.put("classes_Name","请选择");
					array.add(j);
				}
			}catch(Exception e){
				JSONObject j = new JSONObject();
				j.put("classes_Id","0");
				j.put("classes_Name","班级加载失败");
				array.add(j);
			}
			String json = array.toJSONString();
			PrintWriter out = null;
			HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
			httpServletResponse.setContentType("application/json");
			httpServletResponse.setCharacterEncoding("utf-8");
			try {
				out = httpServletResponse.getWriter();
			} catch (IOException e) {
				e.printStackTrace();
			}
			out.print(json);
			out.close();
			return null;
	}
		
	public BaseService getBaseService() {
		return baseService;
	}
	public void setBaseService(BaseService baseService) {
		this.baseService = baseService;
	}
	public String getBranch_Id() {
		return branch_Id;
	}
	public void setBranch_Id(String branch_Id) {
		this.branch_Id = branch_Id;
	}
	public Long getDealNo() {
		return actionNo;
	}
	public void setActionNo(Long actionNo) {
		this.actionNo = actionNo;
	}
	public String getInnerReportFileName() {
		return innerReportFileName;
	}
	public void setInnerReportFileName(String innerReportFileName) {
		this.innerReportFileName = innerReportFileName;
	}
	public Map<String, String> getInnerReportParameter() {
		return innerReportParameter;
	}
	public void setInnerReportParameter(Map<String, String> innerReportParameter) {
		this.innerReportParameter = innerReportParameter;
	}
	public List<Object> getInnerReportDataList() {
		return innerReportDataList;
	}
	public void setInnerReportDataList(List<Object> innerReportDataList) {
		this.innerReportDataList = innerReportDataList;
	}
	public String getErrMsg() {
		return errMsg;
	}
	public void setErrMsg(String errMsg) {
		this.errMsg = errMsg;
	}
	public String getRegion_Id() {
		return region_Id;
	}
	public void setRegion_Id(String region_Id) {
		this.region_Id = region_Id;
	}
	public String getTown_Id() {
		return town_Id;
	}
	public void setTown_Id(String town_Id) {
		this.town_Id = town_Id;
	}
	public String getTablename() {
		return tablename;
	}
	public void setTablename(String tablename) {
		this.tablename = tablename;
	}
	public String getColvalue() {
		return colvalue;
	}
	public void setColvalue(String colvalue) {
		this.colvalue = colvalue;
	}
	public String getColname() {
		return colname;
	}
	public void setColname(String colname) {
		this.colname = colname;
	}
	public String getValue() {
		return value;
	}
	public void setValue(String value) {
		this.value = value;
	}
	public Boolean getTwoinput() {
		return twoinput;
	}
	public void setTwoinput(Boolean twoinput) {
		this.twoinput = twoinput;
	}
	public String getSchool_Id() {
		return school_Id;
	}
	public void setSchool_Id(String school_Id) {
		this.school_Id = school_Id;
	}
	public String getGrade_Id() {
		return grade_Id;
	}
	public void setGrade_Id(String grade_Id) {
		this.grade_Id = grade_Id;
	}
	public String getClasses_Id() {
		return classes_Id;
	}
	public void setClasses_Id(String classes_Id) {
		this.classes_Id = classes_Id;
	}
	public String getComm_Id() {
		return comm_Id;
	}
	public void setComm_Id(String comm_Id) {
		this.comm_Id = comm_Id;
	}
	public String getBrchId() {
		return brchId;
	}
	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}
	public String getOrgId() {
		return orgId;
	}
	public void setOrgId(String orgId) {
		this.orgId = orgId;
	}
	public String getIsShowOrg() {
		return isShowOrg;
	}
	public void setIsShowOrg(String isShowOrg) {
		this.isShowOrg = isShowOrg;
	}
	public String getCodeType() {
		return codeType;
	}
	public void setCodeType(String codeType) {
		this.codeType = codeType;
	}
	public String getCodeValues() {
		return codeValues;
	}
	public void setCodeValues(String codeValues) {
		this.codeValues = codeValues;
	}
	public Boolean getIsShowAll() {
		return isShowAll;
	}
	public void setIsShowAll(Boolean isShowAll) {
		this.isShowAll = isShowAll;
	}
	public Boolean getIsShowDefaultOption() {
		return isShowDefaultOption;
	}
	public void setIsShowDefaultOption(Boolean isShowDefaultOption) {
		this.isShowDefaultOption = isShowDefaultOption;
	}
	public Boolean getIsOnlyDefault() {
		return isOnlyDefault;
	}
	public void setIsOnlyDefault(Boolean isOnlyDefault) {
		this.isOnlyDefault = isOnlyDefault;
	}
	public Boolean getIsJudgePermission() {
		return isJudgePermission;
	}
	public void setIsJudgePermission(Boolean isJudgePermission) {
		this.isJudgePermission = isJudgePermission;
	}
}
