package com.erp.action;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.PrintWriter;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
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
import com.erp.model.BasePersonal;
import com.erp.model.SysActionLog;
import com.erp.service.BasicPersonService;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**----------------------------------------------------*
*@category                                             *
*人员基础信息管理，主要功能点                                                                      *
*1、人员信息新增                                                                                                *
*2、人员信息编辑                                                                                                *
*3、人员信息查询                                                                                                *
*@author yangn                                         *  
*@date 2015-08-10                                      *
*@email yn_yangning@foxmail.com                        *
*@version 1.0                                          *
*------------------------------------------------------*/
@Namespace("/dataAcount")
@Action(value = "dataAcountAction")
@InterceptorRefs({@InterceptorRef("jsondefalut")})
@Results({@Result(name="toAddOrUpdateBasePersonal",location="/jsp/dataAcount/dataAcountEditDlg.jsp")})
public class DataAcountAction extends BaseAction{
	private static final long serialVersionUID = 1L;
	public Logger log = Logger.getLogger(DataAcountAction.class);
	@Resource(name="basicPersonService")
	private BasicPersonService basicPersonService;
	private BasePersonal bp = new BasePersonal();
	private String queryType = "1";
	private String sort;
	private String order;
	private String defaultErrorMasg = "";
	private String regionId;
	private String townId;
	private String commId;
	private String isPhoto;
	private String corpName;
	private String certNo1;
	private String certNo2;
	private String name1;
	private String name2;
	private String personalId1;
	private String personalId2;
	private String photoCertNo;
	private File[] file; 
    private String template;
    private String[] fileFileName;
	private String perid;
	/**
	 * 获取人员信息
	 * @return
	 */
	public String findAllBasePersonal(){
		try{
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select t.customer_id,t.name,(select s1.code_name from sys_code s1 where s1.code_type = 'CERT_TYPE' and s1.code_value = t.cert_type ) certtype,");
				sb.append("t.cert_type,t.cert_no,t.birthday,(select s2.code_name from sys_code s2 where s2.code_type = 'SEX' and s2.code_value = t.gender ) genders,t.gender,");
				sb.append("(select s3.code_name from sys_code s3 where s3.code_type = 'NATION' and s3.code_value = t.nation ) nation,");
				sb.append("t.country,decode(t.reside_type,'0','本地','外地') residetype,t.city_id,t.pinying,p.corp_name,");
				sb.append("t.region_id,r.region_name,t.town_id, n.town_name,t.comm_id,m.comm_name,t.reside_addr,t.letter_addr,t.post_code,");
				sb.append("t.phone_no,t.tel_nos,t.mobile_no,t.mobile_nos,t.email,t.corp_customer_id,");
				sb.append("(select s4.code_name from sys_code s4 where s4.code_type = 'EDUCATION' and s4.code_value = t.education) education,");
				sb.append("(select s5.code_name from sys_code s5 where s5.code_type = 'MARR_STATE' and s5.code_value = t.marr_state) marr_state,");
				sb.append("t.career,t.income,decode(t.customer_state,'0','正常','注销') customer_state,");
				sb.append("t.open_date,t.cls_user_id,t.cls_date,decode(t.data_src,'0','部门交换','1','手工采集','其他来源') data_src,decode(t.sure_flag,'0','是','否') sure_flag, t.note ");
				sb.append("from base_personal t,base_region r,base_comm m,base_town n,base_corp p ");
				sb.append("where t.region_id = r.region_id(+) and t.comm_id = m.comm_id(+) and t.town_id = n.town_id(+) and t.corp_customer_id = p.customer_id(+) ");
				if(!Tools.processNull(bp.getCertType()).equals("")){
					sb.append(" and t.cert_type = '" + this.bp.getCertType() + "' ");
				}
				if(!Tools.processNull(bp.getCertNo()).equals("")){
					sb.append(" and t.cert_no = '" + this.bp.getCertNo() + "' ");
				}
				if(!Tools.processNull(bp.getName()).equals("")){
					sb.append(" and t.name like '%" + this.bp.getName() + "%' ");
				}
				if(!Tools.processNull(this.regionId).equals("")){
					sb.append(" and t.region_Id = '" + regionId + "' ");
				}
				if(!Tools.processNull(this.townId).equals("")){
					sb.append(" and t.town_Id = '" + this.townId + "' ");				
				}
				if(!Tools.processNull(this.commId).equals("")){
					sb.append(" and t.comm_Id = '" + this.commId + "' ");
				}
				if(!Tools.processNull(bp.getCorpCustomerId()).equals("")){
					sb.append(" and t.corp_customer_id = '" + bp.getCorpCustomerId() + "' ");
				}
				if(!Tools.processNull(bp.getMobileNo()).equals("")){
					sb.append(" and (t.mobile_no = '" + bp.getMobileNo() + "' or t.MOBILE_NOS = '" + bp.getMobileNo() + "' or phone_no = '" + bp.getMobileNo() + "') ");
				}
				if(!Tools.processNull(bp.getCustomerState()).equals("")){
					sb.append(" and t.customer_state = '" + bp.getCustomerState() + "' ");
				}
				if(!Tools.processNull(this.isPhoto).equals("")){
					sb.append(" and " + (isPhoto.equals("0") ? "" : " not "));
					sb.append(" exists (select 1 from base_photo hh where hh.customer_id = t.customer_id and hh.photo_state = '0' and dbms_lob.getlength(hh.photo) > 0) ");
				}
				if(!Tools.processNull(this.corpName).equals("")){
					sb.append(" and p.corp_name like '%" + this.corpName + "%' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append(" order by " + this.sort + " " + this.order);
				}else{
					sb.append(" order by t.customer_id");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应的人员信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 人员合并
	 * @return
	 */
	public String personMerge(){
		try {
			basicPersonService.savePersonMerge(certNo1, certNo2, name1, name2, personalId1, personalId2, photoCertNo);
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return JSONOBJ;
	}
	/**
	 * 人员基本信息新增或是编辑页面
	 * @return
	 */
	public String toAddOrUpdateBasePersonal(){
		try{
			if(Tools.processNull(this.queryType).equals("1")){
				if(Tools.processNull(bp.getCustomerId()).equals("")){
					throw new CommonException("编辑客户信息发生错误：传入客户编号不为空！" );
				}
				bp = (BasePersonal)baseService.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + bp.getCustomerId() + "'");
				if(bp == null){
					throw new CommonException("编辑客户信息发生错误：根据客户编号未找到客户信息！");
				}else{
					corpName = (String) baseService.findOnlyFieldBySql("select t.corp_name from base_corp t where t.customer_id = '" + bp.getCorpCustomerId() + "'");
				}
			}
		}catch(Exception e){
			this.defaultErrorMasg = e.getMessage();
		}
		return "toAddOrUpdateBasePersonal";
	}
	/**
	 * 人员基本信息保存
	 * @return
	 */
	public String toSaveAddOrUpdateBasePersonal(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			basicPersonService.saveAddOrUpdateBasePersonal(bp,corpName,null,baseService.getCurrentActionLog(),this.queryType);
			jsonObject.put("status","0");
			jsonObject.put("msg",(Tools.processNull(this.queryType).equals("0") ? "新增" : "编辑") + "人员基本信息成功！");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 自动输入框
	 * @return
	 */
	@SuppressWarnings("rawtypes")
	public String toSearchInput(){
		try{
			JSONArray array = new JSONArray();
			List list = new ArrayList();
			StringBuffer sb = new StringBuffer();
			sb.append("select t.customer_id,t.corp_name from base_corp t ");
			sb.append(" where t.corp_name is not null and  ");
			if(Tools.processNull(this.queryType).equals("0")){
				sb.append(" t.corp_name like ");
			}else{
				sb.append(" t.customer_id like ");
			}
			sb.append("'%" + corpName.replaceAll("'","") + "%' and rownum < 10 group by t.customer_id,t.corp_name ");
			list = baseService.findBySql(sb.toString());
			if(list != null && list.size() > 0){
				for (int i = 0;i < list.size(); i++){
					JSONObject j = new JSONObject();
					Object[] row = (Object[]) list.get(i);
					j.put("value",row[1].toString());
					j.put("text",row[0].toString());
					array.add(j);
				}
			}
			String json = array.toJSONString();
			HttpServletResponse httpServletResponse = ServletActionContext.getResponse();
			httpServletResponse.setContentType("application/json");
			httpServletResponse.setCharacterEncoding("utf-8");
			PrintWriter out = httpServletResponse.getWriter();
			out.print(json);
			out.close();
		}catch(Exception e){
			log.error(e);
		}
		return null;
		
	}
	
	/**
	 * 导入人员信息
	 * @return
	 */
	public String importPerson() {
		try {
			if (file == null) {
				throw new CommonException("导入文件为空.");
			}
			List<Map> list = new ArrayList<Map>();
			try {
				Workbook workbook = new HSSFWorkbook(new FileInputStream(file[0]));
				Sheet sheet = workbook.getSheetAt(0);
				int lastRowNum = sheet.getLastRowNum();
				for (int i = 1; i <= lastRowNum; i++) {
					BasePersonal bp = new BasePersonal();
					Map<String, Object> pm = new HashMap();
					Row row = sheet.getRow(i);
					if (row == null) {
						continue;
					}
					//获取姓名
					Cell cell = row.getCell(0);
					if (cell == null) {
						throw new CommonException("姓名不能为空.");
					}
					bp.setName(cell.getStringCellValue());
					//获取证件类型
					Cell cell1 = row.getCell(1);
	
					if("身份证".equals(cell1.getStringCellValue())){
						bp.setCertType("1");
					}else if("户口簿".equals(cell1.getStringCellValue())){
						bp.setCertType("2");
					}else if("军官证".equals(cell1.getStringCellValue())){
						bp.setCertType("3");
					}else if("护照".equals(cell1.getStringCellValue())){
						bp.setCertType("4");
					}else if("户籍证明".equals(cell1.getStringCellValue())){
						bp.setCertType("5");
					}else if("其他".equals(cell1.getStringCellValue())){
						bp.setCertType("6");
					}
					//获取证件号码
					Cell cell2 = row.getCell(2);
					if (cell2 == null) {
						throw new CommonException("证件号码不能为空.");
					}
					bp.setCertNo(cell2.getStringCellValue());
					//获取手机编号
					Cell cell3 = row.getCell(3);
					if (cell3 != null) {
						bp.setMobileNo(cell3.getStringCellValue());
					}
					
					//获取联系地址
					Cell cell4 = row.getCell(4);
					if (cell4 != null) {
						bp.setLetterAddr(cell4.getStringCellValue());
					}
					
					//获取单位编号
					Cell cell5 = row.getCell(5);
					if (cell5 != null) {
						bp.setCorpCustomerId(cell5.getStringCellValue());
					}
					
					//获取单位名称
					Cell cell6 = row.getCell(6);
					if (cell6 != null) {
						bp.setCorpName(cell6.getStringCellValue());
					}
					
					String certNo = cell2.getStringCellValue();
					String name = cell.getStringCellValue();
					
					pm.put("bp",bp);
					pm.put("name", name);
					pm.put("certNo", certNo);
					list.add(pm);
					}
			} catch (Exception e1) {
				throw new CommonException(e1.getMessage());
			}
			List<Map> failList = saveBasePerson(list);
			
			if (!failList.isEmpty()) {
				jsonObject.put("hasFail", true);
				jsonObject.put("failList", failList);
				
			}
			
			jsonObject.put("status", "0");
			jsonObject.put("msg", "共 " + list.size() + " 条数据记录, 成功导入 " + (list.size() - failList.size()) + " 条, 失败 " + failList.size() + " 条");
		} catch (Exception e) {
			
			System.out.println(e);
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public List<Map> saveBasePerson(List<Map> list) {
		try {
			if (list == null || list.isEmpty()) {
				throw new CommonException("信息不完整");
			}
			List<Map> failList = new ArrayList<Map>();
			for (Map basePerson : list) {
				try {
					basicPersonService.saveAddOrUpdateBasePersonal((BasePersonal)basePerson.get("bp"),null,null,(SysActionLog)BeanUtils.cloneBean(baseService.getCurrentActionLog()),"0");
				} catch (Exception e) {
					JSONObject item = new JSONObject();
					item.put("name", basePerson.get("name"));
					item.put("certNo", basePerson.get("certNo"));
					item.put("failMsg", e.getMessage());
					failList.add(item);
				}
			}
			
			return failList;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	
	
	
	
	
	//模板
	public String downloadTemplate(){
		try {
			if (Tools.processNull(template).equals("")) {
				throw new CommonException("下载模版为空");
			}
			
			String path = request.getRealPath("/template/" + template + ".xls");
			File file = new File(path);
			if(!file.exists()){
				throw new CommonException("下载模版文件不存在");
			}
			
			response.setContentType("application/vnd.ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(file.getName().getBytes(), "iso8859-1"));
			BufferedOutputStream bos = new BufferedOutputStream(response.getOutputStream());
			BufferedInputStream bis = new BufferedInputStream(new FileInputStream(path));
			int b = 0;
			while ((b = bis.read()) != -1) {
				bos.write(b);
			}
			bos.flush();
			bos.close();
		} catch (Exception e) {
			jsonObject.put("status", "1");
		}
		return JSONOBJ;
	}
		
	
	//初始化表格
	private void initGrid() throws Exception{
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg","");
	}
	/**
	 * @return the bp
	 */
	public BasePersonal getBp() {
		return bp;
	}
	/**
	 * @param bp the bp to set
	 */
	public void setBp(BasePersonal bp) {
		this.bp = bp;
	}
	/**
	 * @return the queryType
	 */
	public String getQueryType() {
		return queryType;
	}
	/**
	 * @param queryType the queryType to set
	 */
	public void setQueryType(String queryType) {
		this.queryType = queryType;
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
	 * @return the defaultErrorMasg
	 */
	public String getDefaultErrorMasg() {
		return defaultErrorMasg;
	}
	/**
	 * @param defaultErrorMasg the defaultErrorMasg to set
	 */
	public void setDefaultErrorMasg(String defaultErrorMasg) {
		this.defaultErrorMasg = defaultErrorMasg;
	}
	/**
	 * @return the basicPersonService
	 */
	public BasicPersonService getBasicPersonService() {
		return basicPersonService;
	}
	/**
	 * @param basicPersonService the basicPersonService to set
	 */
	public void setBasicPersonService(BasicPersonService basicPersonService) {
		this.basicPersonService = basicPersonService;
	}
	/**
	 * @return the regionId
	 */
	public String getRegionId() {
		return regionId;
	}
	/**
	 * @param regionId the regionId to set
	 */
	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}
	/**
	 * @return the townId
	 */
	public String getTownId() {
		return townId;
	}
	/**
	 * @param townId the townId to set
	 */
	public void setTownId(String townId) {
		this.townId = townId;
	}
	/**
	 * @return the commId
	 */
	public String getCommId() {
		return commId;
	}
	/**
	 * @param commId the commId to set
	 */
	public void setCommId(String commId) {
		this.commId = commId;
	}
	/**
	 * @return the isPhoto
	 */
	public String getIsPhoto() {
		return isPhoto;
	}
	/**
	 * @param isPhoto the isPhoto to set
	 */
	public void setIsPhoto(String isPhoto) {
		this.isPhoto = isPhoto;
	}
	/**
	 * @return the corpName
	 */
	public String getCorpName() {
		return corpName;
	}
	/**
	 * @param corpName the corpName to set
	 */
	public void setCorpName(String corpName) {
		this.corpName = corpName;
	}

	public String getCertNo1() {
		return certNo1;
	}

	public void setCertNo1(String certNo1) {
		this.certNo1 = certNo1;
	}

	public String getCertNo2() {
		return certNo2;
	}

	public void setCertNo2(String certNo2) {
		this.certNo2 = certNo2;
	}

	public String getName1() {
		return name1;
	}

	public void setName1(String name1) {
		this.name1 = name1;
	}

	public String getName2() {
		return name2;
	}

	public void setName2(String name2) {
		this.name2 = name2;
	}

	public String getPersonalId1() {
		return personalId1;
	}

	public void setPersonalId1(String personalId1) {
		this.personalId1 = personalId1;
	}

	public String getPersonalId2() {
		return personalId2;
	}

	public void setPersonalId2(String personalId2) {
		this.personalId2 = personalId2;
	}

	public String getPhotoCertNo() {
		return photoCertNo;
	}

	public void setPhotoCertNo(String photoCertNo) {
		this.photoCertNo = photoCertNo;
	}

	public String getTemplate() {
		return template;
	}

	public void setTemplate(String template) {
		this.template = template;
	}

	public File[] getFile() {
		return file;
	}

	public void setFile(File[] file) {
		this.file = file;
	}

	public String[] getFileFileName() {
		return fileFileName;
	}

	public void setFileFileName(String[] fileFileName) {
		this.fileFileName = fileFileName;
	}


	
	
}
