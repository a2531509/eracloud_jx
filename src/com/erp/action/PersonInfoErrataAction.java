package com.erp.action;

import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.sql.Blob;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;
import javax.imageio.ImageIO;
import javax.servlet.http.HttpServletResponse;

import org.apache.shiro.SecurityUtils;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseBank;
import com.erp.model.BaseComm;
import com.erp.model.BaseCorp;
import com.erp.model.BaseKanwuPrint;
import com.erp.model.BasePersonal;
import com.erp.model.BasePhoto;
import com.erp.model.BaseRegion;
import com.erp.model.BaseTown;
import com.erp.model.PersonBean;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.service.PersonInfoErrataService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.ExportExcel;
import com.erp.util.GenerateQRCode;
import com.erp.util.PdfConbineUtil;
import com.erp.util.Tools;
import com.erp.viewModel.KanwuExecelView;
import com.erp.viewModel.Page;

import net.sf.jasperreports.engine.JRResultSetDataSource;
import net.sf.jasperreports.engine.JasperRunManager;

/**
 * 待申领人员信息勘误   
 * 
 * @author hujc
 * @version 1.0
 * @date 2015-12-04
 * 
 */
@SuppressWarnings("serial")
@Namespace("/personInfoErrata")
@Action(value = "personInfoErrataAction")
@Results({
	@Result(name="addOrEditBaseSiinfo",location="/jsp/cgManagement/baseSiinfoManagementEdit.jsp"),
	@Result(name="expPersonErrata",location="/jsp/cardApp/baseSiinfoCheckMain.jsp")
})
public class PersonInfoErrataAction extends BaseAction {
	@Resource(name = "personInfoErrataService")
	private PersonInfoErrataService personInfoErrataService;
	private String sort;
	private String order;
	private String queryType = "1";//查询标志
	private String slfs = "";//申领方式  1 单位申领  2社区申领
	private String corpId = "";//单位编号
	private String corpName = "";//单位名称
	private String regionId = "";//区县
	private String townId = "";//乡镇信息
	private String commId = "";//街道信息
	private String beginDate = "";//开始时间 (是指出生日期)
	private String endDate = "";//结束时间 (是指出生日期)
	private String customerIds = "";//选中导出和打印时进行的操作
	private String hasPhoto;
	
	/**
	 * 查询勘误人员信息
	 * @return
	 */
	public String queryErrataPerson(){
		try {
			this.initGrid();
			StringBuffer sqlHead = new StringBuffer("");
			StringBuffer sqlwhere = new StringBuffer("");
			if(Tools.processNull(slfs).equals("1")){
				sqlHead.append("SELECT TO_CHAR(P.CUSTOMER_ID) CUSTOMER_ID1,P.CUSTOMER_ID,P.NAME,P.CERT_NO,DECODE(P.RESIDE_TYPE, '0', '嘉兴', '1', '外地') RESIDE_TYPE,");
				sqlHead.append("P.CORP_CUSTOMER_ID,S.Corp_Name,decode(p.sure_Flag,'0','成功','1','失败') Sure_Flag,decode(decode (dbms_lob.getchunksize(photo),null,1,0),'0','是','1','否')  PHOTO");
				sqlwhere.append(" FROM BASE_PERSONAL P, BASE_CORP S, BASE_PHOTO E, Base_Siinfo x WHERE p.CORP_CUSTOMER_ID  = S.CUSTOMER_ID(+) AND P.CUSTOMER_ID = E.CUSTOMER_ID(+) ");
				sqlwhere.append(" AND NOT EXISTS(SELECT C.CUSTOMER_ID FROM card_apply C WHERE C.CUSTOMER_ID = P.CUSTOMER_ID) AND p.customer_id = x.customer_id");
				sqlwhere.append(" and x.med_State='0' ");
				if (!"99999999".equals(baseService.getSessionSysBranch().getBrchId())) {
					sqlwhere.append(" and s.region_id = '" + baseService.getBrchRegion() + "' ");
				}
				if (Tools.processNull(hasPhoto).equals("0")) {
					sqlwhere.append(" and decode(dbms_lob.getchunksize(photo), null, 1, 0) = '0' and e.photo_state = '0' ");
				} else if (Tools.processNull(hasPhoto).equals("1")) {
					sqlwhere.append(" and (decode(dbms_lob.getchunksize(photo), null, 1, 0) <> '0' or e.photo_state <> '0') ");
				}
				if(!Tools.processNull(corpId).equals("")){
					sqlwhere.append(" and s.CUSTOMER_ID ='"+Tools.processNull(corpId)+"'");
				}
//				if(!Tools.processNull(corpName).equals("")){
//					sqlwhere.append(" and s.corp_name ='"+Tools.processNull(corpName)+"'");
//				}
				if(!Tools.processNull(beginDate).equals("")){
					
					sqlwhere.append(" and substr(p.cert_No,7,8) >='"+Tools.processNull(beginDate)+"'");
				}
				if(!Tools.processNull(endDate).equals("")){
					sqlwhere.append(" and substr(p.cert_No,7,8) <='"+Tools.processNull(endDate)+"'");
				}
			}else if(Tools.processNull(slfs).equals("2")){
				sqlHead.append("select to_char(p.customer_id) customer_id1,p.customer_id,p.name,p.cert_No,decode(p.reside_type,'0','嘉兴','1','外地') RESIDE_TYPE,");
				sqlHead.append("p.corp_customer_id,s.corp_name,decode(p.sure_Flag,'0','成功','1','失败') sure_Flag,decode(decode (dbms_lob.getchunksize(photo),null,1,0),'0','是','1','否')  PHOTO ");
				sqlwhere.append(" from Base_Personal p,Base_Corp s,base_photo e ,Base_Siinfo x where p.corp_customer_id=s.customer_id(+) ");
				sqlwhere.append(" and p.customer_id = e.customer_id(+) AND not exists (select c.customer_id from card_apply c where ");
				sqlwhere.append(" c.customer_id = p.customer_id) AND p.customer_id = x.customer_id and x.med_State='0' ");
				if (Tools.processNull(hasPhoto).equals("0")) {
					sqlwhere.append(" and decode(dbms_lob.getchunksize(photo), null, 1, 0) = '0' and e.photo_state = '0' ");
				} else if (Tools.processNull(hasPhoto).equals("1")) {
					sqlwhere.append(" and (decode(dbms_lob.getchunksize(photo), null, 1, 0) <> '0' or e.photo_state <> '0') ");
				}
				if(!Tools.processNull(regionId).equals("")){
					sqlwhere.append(" and p.region_id = '"+regionId.trim()+"' ");
				}
				if(!Tools.processNull(townId).equals("")){
					sqlwhere.append(" and p.town_id = '"+townId.trim()+"' ");
				}
				if(!Tools.processNull(commId).equals("")){
					sqlwhere.append(" and p.comm_id = '"+commId.trim()+"' ");
				}
				if(!Tools.processNull(beginDate).equals("")){
					sqlwhere.append(" and substr(p.cert_No,7,8) >='"+Tools.processNull(beginDate)+"'");
				}
				
				if(!Tools.processNull(endDate).equals("")){
					sqlwhere.append(" and substr(p.cert_No,7,8) <='"+Tools.processNull(endDate)+"'");
				}
			}
			
			Page list = personInfoErrataService.pagingQuery(sqlHead.toString()+sqlwhere.toString(), page, rows);
			if (list.getAllRs() != null && list.getAllRs().size() > 0) {
				jsonObject.put("rows", list.getAllRs());
				jsonObject.put("total", list.getTotalCount());
			} else {
				throw new CommonException("根据查询条件未找到对应的勘误人员信息！");
			}
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 导出勘误人员信息
	 * @return
	 */
	@SuppressWarnings("rawtypes")
	public String expPersonErrata(){
		try {
			StringBuffer sb = new StringBuffer("");
			String fileName = "勘误人员信息列表";
			if(Tools.processNull(slfs).equals("1")){
				BaseCorp corp = (BaseCorp)personInfoErrataService.findOnlyRowByHql("from BaseCorp t where t.customerId = '" + Tools.processNull(corpId) + "'");
				fileName += Tools.processNull(corp.getCorpName());
				sb.append("SELECT P.CUSTOMER_ID,P.NAME,P.CERT_NO,DECODE(P.RESIDE_TYPE,'0','嘉兴','1','外地') RESIDE_TYPE ,P.CORP_CUSTOMER_ID,S.CORP_NAME,");
				sb.append("DECODE(P.SURE_FLAG,'0','成功','1','失败') SURE_FLAG,DECODE(DECODE(DBMS_LOB.GETCHUNKSIZE(PHOTO),NULL,1,0),'0','是','1','否')  PHOTO ");
				sb.append("FROM BASE_PERSONAL P, BASE_CORP S, BASE_PHOTO E, base_siinfo x WHERE P.CORP_CUSTOMER_ID  = S.CUSTOMER_ID AND P.CUSTOMER_ID = E.CUSTOMER_ID(+) and p.customer_id = x.customer_id ");
				sb.append("AND NOT EXISTS(SELECT C.CUSTOMER_ID FROM CARD_APPLY C WHERE C.CUSTOMER_ID = P.CUSTOMER_ID) and x.med_State='0' ");
				if(!Tools.processNull(customerIds).equals("")){
					sb.append("AND P.CUSTOMER_ID IN (" + customerIds + ") ");
				}
				if(!Tools.processNull(corpId).equals("")){
					sb.append("AND S.CUSTOMER_ID = '" + Tools.processNull(corpId) + "' ");
				}
				if(!Tools.processNull(corpName).equals("")){
					sb.append("AND S.CORP_NAME = '" + Tools.processNull(corpName) + "' ");
				}
				if(!Tools.processNull(beginDate).equals("")){
					sb.append("AND SUBSTR(P.CERT_NO,7,8) >= '" + Tools.processNull(beginDate) + "' ");
				}
				if(!Tools.processNull(endDate).equals("")){
					sb.append("AND SUBSTR(P.CERT_NO,7,8) <= '" + Tools.processNull(endDate) + "' ");
				}
				sb.append("ORDER BY P.NAME ");
			}else if(Tools.processNull(slfs).equals("2")){
				BaseComm comm = (BaseComm)personInfoErrataService.findOnlyRowByHql("from BaseComm t where t.commId = '" + Tools.processNull(commId) + "'");
				fileName += Tools.processNull(comm.getCommName());
				sb.append("SELECT P.CUSTOMER_ID,P.NAME,P.CERT_NO,DECODE(P.RESIDE_TYPE,'0','嘉兴','1','外地') RESIDE_TYPE ,P.COMM_ID,M.COMM_NAME,");
				sb.append("DECODE(P.SURE_FLAG,'0','成功','1','失败'),DECODE(DECODE (DBMS_LOB.GETCHUNKSIZE(PHOTO),NULL,1,0),'0','是','1','否') AS PHOTO ");
				sb.append("FROM BASE_PERSONAL P,BASE_PHOTO E ,BASE_SIINFO X ,BASE_COMM M WHERE ");
				sb.append("P.CUSTOMER_ID = E.CUSTOMER_ID(+) AND P.COMM_ID = M.COMM_ID(+) AND NOT EXISTS (SELECT C.CUSTOMER_ID FROM CARD_APPLY C WHERE ");
				sb.append("C.CUSTOMER_ID = P.CUSTOMER_ID) AND P.CUSTOMER_ID = X.CUSTOMER_ID and (decode(dbms_lob.getchunksize(e.photo), null, 1, 0) <> '0' or e.photo_state <> '0') AND X.MED_STATE = '0' ");
				if(!Tools.processNull(customerIds).equals("")){
					sb.append("AND P.CUSTOMER_ID IN (" + customerIds + ") ");
				}
				if(!Tools.processNull(regionId).equals("")){
					sb.append("AND P.REGION_ID = '" + regionId.trim() + "' ");
				}
				if(!Tools.processNull(townId).equals("")){
					sb.append("AND P.TOWN_ID = '" + townId.trim() + "' ");
				}
				if(!Tools.processNull(commId).equals("")){
					sb.append("AND P.COMM_ID = '" + commId.trim() + "' ");
				}
				if(!Tools.processNull(beginDate).equals("")){
					sb.append("AND SUBSTR(P.CERT_NO,7,8) >= '" + Tools.processNull(beginDate) + "' ");
				}
				
				if(!Tools.processNull(endDate).equals("")){
					sb.append("AND SUBSTR(P.CERT_NO,7,8) <= '" + Tools.processNull(endDate) + "' ");
				}
				sb.append("ORDER BY P.NAME ");
			}
			String[] headers = {"市民卡人员编号","姓名","公民身份证号","户籍","单位/社区编号","单位/社区名称","照片标志位"};
			List<KanwuExecelView> excelList = new ArrayList<KanwuExecelView>();
			List entityList = personInfoErrataService.findBySql(sb.toString());
			for(int i=0;i<entityList.size();i++){
				KanwuExecelView view = new KanwuExecelView();
				Object[] obj = (Object[])entityList.get(i);
				view.setCustomerId(Tools.processNull(obj[0]));
				view.setName(Tools.processNull(obj[1]));
				view.setCertNo(Tools.processNull(obj[2]));
				view.setRegionAdd(Tools.processNull(obj[3]));
				view.setRegionId(Tools.processNull(obj[4]));
				view.setRegionName(Tools.processNull(obj[5]));
				view.setCheckPhoto(Tools.processNull(obj[7]));
				excelList.add(view);
			}
			ExportExcel<KanwuExecelView> ex = new ExportExcel<KanwuExecelView>();
			HttpServletResponse response = ServletActionContext.getResponse();
			response.setContentType("application/ms-excel;charset=utf-8");
		    response.setHeader("Content-disposition", "attachment; filename="+ URLEncoder.encode(fileName,"UTF8") + ".xls");
		    OutputStream out = response.getOutputStream();
	        ex.exportExcel(fileName,headers, excelList, out,"");
	        SecurityUtils.getSubject().getSession().setAttribute("expPersonErrataDownloadSuc",Constants.YES_NO_YES);
	        out.close();
		} catch (Exception e) {
			this.saveErrLog(e);
			this.defaultErrorMsg = e.getMessage();
			return "expPersonErrata";
		}
		return null;
	}
	/**
	 * 勘误数据汇总单信息打印
	 */
	/*@SuppressWarnings("unchecked")
	public String printTotalPerErrata(){
		jsonObject.put("status", false);
		jsonObject.put("title", "错误信息");
		jsonObject.put("message", "");
		try{
			String remark = "";
			BaseCorp corp = new BaseCorp();
			HashMap reportsHashMap = new HashMap();
			if(Tools.processNull(slfs).equals("1")){//单位
				if(Tools.processNull(corpId).equals("")){
					throw new CommonException("单位编号不能为空！");
				}
				String hql="select p from BasePersonal p,BaseCorp s where p.corpCustomerId=s.customerId and   not exists (select c.customerId from CardApply c where c.customerId = p.customerId) "
						+ "and (p.sureFlag='1' or not exists (select 1 from BasePhoto ee where p.customerId=ee.customerId and decode(dbms_lob.getchunksize(photo),null,1,0)='0' and ee.photoState='0')) ";
				
				if(!Tools.processNull(customerIds).equals("")){
					hql+=" and p.customerId in ("+customerIds+")";
				}
				if(!Tools.processNull(corpId).equals(""))hql+=" and s.customerId = '"+Tools.processNull(corpId).trim()+"' ";
				//if(!Tools.processNull(corpName).equals(""))hql+=" and s.corpName = '"+Tools.processNull(corpName).trim()+"' ";
				if(!Tools.processNull(beginDate).equals(""))hql+=" and substr(p.certNo,7,8) >= '"+Tools.processNull(beginDate).trim()+"' ";
				if(!Tools.processNull(endDate).equals(""))hql+=" and substr(p.certNo,7,8) <= '"+Tools.processNull(endDate).trim()+"' ";
				hql+=" order by p.name asc";
				List<BasePersonal> list=(List<BasePersonal>)personInfoErrataService.findByHql(hql);
				if(list!=null&& list.size()>0){
					for(int i=0;i<list.size();i++){
						if(i==0){
							remark+=((BasePersonal)list.get(i)).getName()+"、";
						}else if(i==1){
							remark+=((BasePersonal)list.get(i)).getName()+"等";
						}
					}
				}
				corp=(BaseCorp)personInfoErrataService.findOnlyRowByHql(" from BaseCorp b where b.customerId='"+corpId.trim()+"'");
				reportsHashMap.put("client_Id", Tools.processNull(corp.getCustomerId()));
				reportsHashMap.put("emp_Name", Tools.processNull(corp.getCorpName()));
				reportsHashMap.put("client_date", DateUtil.formatDate(new Date(), "yyyy-MM-dd hh:mm:ss"));
				reportsHashMap.put("contact", Tools.processNull(corp.getContact()));
				reportsHashMap.put("c_tel_no", Tools.processNull(corp.getConPhone()));
				reportsHashMap.put("num", Tools.processNull(list.size()+""));
				reportsHashMap.put("remark", remark);	
			}else if(Tools.processNull(slfs).equals("2")){
				if(Tools.processNull(regionId).equals("")){
					throw new CommonException("城区不能为空");
				}
				if(Tools.processNull(townId).equals("")){
					throw new CommonException("乡镇不能为空");
				}
				if(Tools.processNull(commId).equals("")){
					throw new CommonException("社区不能为空");
				}
				String hql="select p from BasePersonal p, BaseRegion r,BaseTown t,BaseComm m,BaseSiinfo s where p.regionId = r.regionId "
						+ " and p.townId = t.townId and p.commId = m.commId and p.customerId = s.customerId and s.reserve7='1' and m.commState='0' "
						+ " and s.medState='0' and not exists (select c.customerId from CardApply c where c.customerId = p.customerId) and "
						+ " (p.sureFlag='1' or not exists (select 1 from BasePhoto ee where p.customerId=ee.customerId and decode(dbms_lob.getchunksize(photo),null,1,0)='0' and ee.photoState='0')) ";
				
				if(!Tools.processNull(customerIds).equals("")){
					hql+=" and p.customerId in ("+customerIds+")";
				}
				if(!Tools.processNull(regionId).equals(""))hql+=" and p.regionId='"+regionId+"'";
				if(!Tools.processNull(townId).equals(""))hql+=" and p.townId='"+townId+"'";
				if(!Tools.processNull(commId).equals(""))hql+=" and p.commId='"+commId+"'";
				if(!Tools.processNull(beginDate).equals("")){
					hql+=" and substr(p.certNo,7,8) >='"+Tools.processNull(beginDate)+"'";
				}
				
				if(!Tools.processNull(endDate).equals("")){
					hql+=" and substr(p.certNo,7,8) <='"+Tools.processNull(endDate)+"'";
				}
				
				hql+=" order by p.name asc";
				List<BasePersonal> list=(List<BasePersonal>)personInfoErrataService.findByHql(hql);
				if(list!=null&& list.size()>0){//用户想在申领人那儿，取前二个姓名+等就可以
					for(int i=0;i<list.size();i++){
						if(i==0){
							remark+=((BasePersonal)list.get(i)).getName()+"、";
						}else if(i==1){
							remark+=((BasePersonal)list.get(i)).getName()+"等";
						}
					}
				}
				
				BaseRegion region=(BaseRegion) personInfoErrataService.findOnlyRowByHql("from BaseRegion r where r.regionId ='"+regionId+"' ");
				BaseTown town=(BaseTown) personInfoErrataService.findOnlyRowByHql("from BaseTown t where t.townId ='"+townId+"' ");
				BaseComm comm=(BaseComm) personInfoErrataService.findOnlyRowByHql("from BaseComm t where t.commId ='"+commId+"' ");
				reportsHashMap.put("client_Id", Tools.processNull(comm.getCommId()));
				reportsHashMap.put("emp_Name", Tools.processNull(comm.getCommName()));
				reportsHashMap.put("client_date", DateUtil.formatDate(new Date(), "yyyy-MM-dd hh:mm:ss"));
				reportsHashMap.put("contact", Tools.processNull(""));
				reportsHashMap.put("c_tel_no", Tools.processNull(""));
				reportsHashMap.put("num", Tools.processNull(list.size()+""));
				reportsHashMap.put("remark", remark);	
			}
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setMessage("勘误信息汇总报表");
			actionLog.setDealCode(999999);
			SysActionLog log = personInfoErrataService.savePrintReport(actionLog, personInfoErrataService.getUser());
			String path = ServletActionContext.getRequest().getRealPath("/reportfiles/kwPZ1.jasper");
			byte[] pdfContent = JasperRunManager.runReportToPdf(path, reportsHashMap);
			personInfoErrataService.saveSysReport(log, new JSONObject(), "",Constants.APP_REPORT_TYPE_PDF2,1l, "", pdfContent);
			pdfContent=null;
			jsonObject.put("status", true);
			jsonObject.put("title", "");
			jsonObject.put("actionNo", log.getDealNo());
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status", false);
			jsonObject.put("title", "错误信息");
			jsonObject.put("message", e.getMessage());
		}
		return this.JSONOBJ;
	}*/
	
	/**
	 * 达到勘误数据首页(相片生成)
	 */
	/*@SuppressWarnings("deprecation")
	public String expPhotTwoCodeInfo(){
			HashMap reportsHashMap1 = new HashMap();
			String filepathname="";
			String appPath="";
			String appPath2="";
			String dwvirtualPath="";
			BaseCorp employer  = null;
			List<HashMap> maplist=new ArrayList<HashMap>();
			try{
				String hql="";
				if(Tools.processNull(slfs).equals("1")){
					if(Tools.processNull(corpId).equals("")){
						throw new CommonException("单位编号不能为空！");
					}
					employer=(BaseCorp)personInfoErrataService.findOnlyRowByHql(" from BaseCorp b where b.customerId='"+corpId.trim()+"'");
					if(employer==null){
						throw new CommonException("单位不存在！");
					}
					hql="select p from BasePersonal p,BaseCorp s where p.corpCustomerId=s.customerId and "
							+ " (p.sureFlag='1' or not exists (select 1 from BasePhoto ee where p.customerId=ee.customerId"
							+ " and decode(dbms_lob.getchunksize(photo),null,1,0)='0' and ee.photoState='0')) "
							+ " and  not exists (select c.customerId from CardApply c where c.customerId = p.customerId) ";
					if(!Tools.processNull(customerIds).equals("")){
						hql+=" and p.customerId in ("+customerIds+")";
					}
					if(!Tools.processNull(corpId).equals(""))hql+=" and s.customerId = '"+Tools.processNull(corpId).trim()+"' ";
					if(!Tools.processNull(beginDate).equals(""))hql+=" and substr(p.certNo,7,8) >= '"+Tools.processNull(beginDate).trim()+"' ";
					if(!Tools.processNull(endDate).equals(""))hql+=" and substr(p.certNo,7,8) <= '"+Tools.processNull(endDate).trim()+"' ";
				
					hql+=" order by p.name asc";
					List<BasePersonal> list=(List<BasePersonal>)personInfoErrataService.findByHql(hql);
					int no=0;
					if(list!=null&& list.size()>0){
						if(list.size()%10>0){//计算页码
						no=list.size()/10+1;
						}else{
							no=list.size()/10;//页码共计多少页
						}
					}
					if(list!=null&& list.size()>0){
						for(BasePersonal person:list){
							HashMap reportsHashMap = new HashMap();
							PersonBean pBean=new PersonBean();
							BaseKanwuPrint kanwup =new BaseKanwuPrint();
							pBean.setCert_No(person.getCertNo());//身份证号
							pBean.setClient_Id(person.getCustomerId().toString());//客户号
							pBean.setReside_Type(person.getResideType());//户籍类型
							pBean.setName(person.getName());//姓名
							if(this.isWindowsOS()){//windows系统
								//appPath=ServletActionContext.getRequest().getSession().getServletContext().getRealPath("\\twocode");
								appPath= this.request.getRealPath("\\twocode");
								filepathname = appPath+"\\"+person.getCustomerId()+".bmp";
								String imageFileName=filepathname.substring(filepathname.lastIndexOf('\\')+1,filepathname.lastIndexOf('.'))+"."+filepathname.substring(filepathname.lastIndexOf(".")+1);//取虚拟文件名称
								String virtualPath ="twocode\\"+ imageFileName;//虚拟路径
								pBean.setTwocodePath(filepathname);//二维码图像路径
								//写入二维码数据
								BufferedImage image = GenerateQRCode.createQRCode(person.getCustomerId().toString(), 90, 90);
								if(image != null){
									File c = new File(filepathname);
									if(!c.exists()){
										c.createNewFile();
									}
									ImageIO.write(image,"bmp",c);
								}
							}else{//其他系统
								//appPath=ServletActionContext.getRequest().getSession().getServletContext().getRealPath("/twocode");
								appPath= this.request.getRealPath("/twocode");
								filepathname = appPath+"/"+person.getCustomerId()+".bmp";
								String imageFileName=filepathname.substring(filepathname.lastIndexOf('/')+1,filepathname.lastIndexOf('.'))+"."+filepathname.substring(filepathname.lastIndexOf(".")+1);//取虚拟文件名称
								String virtualPath ="twocode/"+ imageFileName;//虚拟路径
								pBean.setTwocodePath(filepathname);//二维码图像路径
								BufferedImage image = GenerateQRCode.createQRCode(person.getCustomerId().toString(), 90, 90);
								if(image != null){
									File c = new File(filepathname);
									if(!c.exists()){
										c.createNewFile();
									}
									ImageIO.write(image,"bmp",c);
								}
							}
							BasePhoto photo=(BasePhoto)personInfoErrataService.findOnlyRowByHql("from BasePhoto e where e.customerId='"+person.getCustomerId()+"'");
							File file=null;
							if(photo!=null){
								if(photo.getPhoto()!=null){
									if(this.isWindowsOS()){//windows系统
										appPath2=this.request.getRealPath("\\photo\\"+person.getCustomerId()+".jpg");
										file= new File(appPath2);
									}else{
										appPath2=this.request.getRealPath("/photo/"+person.getCustomerId()+".jpg");
										file= new File(appPath2);
									}
									InputStream in = new ByteArrayInputStream(blobToBytes(photo.getPhoto()));
									BufferedImage input = javax.imageio.ImageIO.read(in);
									OutputStream out1 = new FileOutputStream(file);
									javax.imageio.ImageIO.write(input, "jpg", out1);
									in.close();
								}else{
									if(this.isWindowsOS()){
										appPath2=this.request.getRealPath("\\images")+"\\noperson.gif";//logo图
									}else{
										appPath2=this.request.getRealPath("/images")+"/noperson.gif";//logo图
									}
								}
							}else{
								if(this.isWindowsOS()){
									appPath2=this.request.getRealPath("\\images")+"\\noperson.gif";//logo图
								}else{
									appPath2=this.request.getRealPath("/images")+"/noperson.gif";//logo图
								}
							}
							kanwup.setCertNo(person.getCertNo());
							kanwup.setCustomerId(person.getCustomerId().toString());
							kanwup.setName(person.getName());
							kanwup.setTwocodePath(pBean.getTwocodePath());
							kanwup.setPhotoPath(appPath2);
							personInfoErrataService.saveKanwuPrint(kanwup);
						}
					}
					//dao.insert(this.getSys_Action_Log());
					String sql="";
					sql="select c.Customer_Id client_id,c.name name,c.cert_no cert_no,c.twocode_path twocode_path,c.photo_path photo_path from Base_Personal a,Base_Corp b,base_kanwu_print c "
							+ " where a.customer_Id=c.customer_Id and a.corp_Customer_Id=b.Customer_Id and b.Customer_Id = '"+corpId.trim()+"' "
							+ " and not exists (select 1 from Card_Apply cc where cc.Customer_Id = a.Customer_Id) and "
							+ " (a.sure_Flag='1' or not exists (select 1 from Base_Photo ee where a.Customer_Id=ee.Customer_Id "
							+ " and decode(dbms_lob.getchunksize(photo),null,1,0)='0' and ee.photo_State='0')) ";
					
					if(!Tools.processNull(customerIds).equals("")){
						sql+=" and a.customer_Id in ("+customerIds+")";
					}
					if(!Tools.processNull(corpId).equals(""))sql+=" and b.customer_Id = '"+Tools.processNull(corpId).trim()+"' ";
					//if(!Tools.processNull(corpName).equals(""))hql+=" and s.corpName = '"+Tools.processNull(corpName).trim()+"' ";
					if(!Tools.processNull(beginDate).equals(""))sql+=" and substr(a.cert_No,7,8) >= '"+Tools.processNull(beginDate).trim()+"' ";
					if(!Tools.processNull(endDate).equals(""))sql+=" and substr(a.cert_No,7,8) <= '"+Tools.processNull(endDate).trim()+"' ";
				
					sql+=" order by c.name";
					SysActionLog actionLog = baseService.getCurrentActionLog();
					actionLog.setMessage("勘误数据明细报表");
					actionLog.setDealCode(999999);
					SysActionLog log = personInfoErrataService.savePrintReport(actionLog, personInfoErrataService.getUser());
					String path = ServletActionContext.getRequest().getRealPath("/reportfiles/kwPZ2.jasper");
					//reportsHashMap1.put("dwtwocode",corpId);
					reportsHashMap1.put("dw",employer.getCorpName());
					JRResultSetDataSource source = new JRResultSetDataSource(personInfoErrataService.tofindResultSet(sql));
					byte[] pdfContent = JasperRunManager.runReportToPdf(path, reportsHashMap1,source);
					personInfoErrataService.saveSysReport(log, new JSONObject(), "",Constants.APP_REPORT_TYPE_PDF2,1l, "", pdfContent);
					pdfContent=null;
					jsonObject.put("status", true);
					jsonObject.put("title", "");
					jsonObject.put("actionNo", log.getDealNo());
				}else if (Tools.processNull(slfs).equals("2")){
					if(Tools.processNull(regionId).equals("")){
						throw new CommonException("城区不能为空");
					}
					if(Tools.processNull(townId).equals("")){
						throw new CommonException("乡镇不能为空");
					}
					if(Tools.processNull(commId).equals("")){
						throw new CommonException("社区不能为空");
					}
					BaseRegion region=(BaseRegion) personInfoErrataService.findOnlyRowByHql("from BaseRegion r where r.regionId ='"+regionId+"' ");
					BaseTown town=(BaseTown) personInfoErrataService.findOnlyRowByHql("from BaseTown t where t.townId ='"+townId+"' ");
					BaseComm comm=(BaseComm) personInfoErrataService.findOnlyRowByHql("from BaseComm t where t.commId ='"+commId+"' ");
					hql="select p from BasePersonal p, BaseRegion r,BaseTown t,BaseComm m ,BaseSiinfo s where p.regionId = r.regionId and p.customerId = s.customerId  and p.townId = t.townId and p.commId = m.commId and m.commState='0' and s.reserve7 = '1' and s.medState='0' and  (p.sureFlag = '1' or not exists(select 1 from BasePhoto ee where p.customerId = ee.customerId and decode(dbms_lob.getchunksize(photo), null, 1, 0) = '0' and ee.photoState = '0')) and not exists (select c.customerId from CardApply c where c.customerId = p.customerId)";
					
					if(!Tools.processNull(customerIds).equals("")){
						hql+=" and p.customerId in ("+customerIds+")";
					}
					if(!Tools.processNull(regionId).equals(""))hql+=" and r.regionId='"+regionId+"'";
					if(!Tools.processNull(townId).equals(""))hql+=" and t.townId='"+townId+"'";
					if(!Tools.processNull(townId).equals(""))hql+=" and m.commId='"+commId+"'";
				
					if(!Tools.processNull(beginDate).equals("")){
						hql+=" and substr(p.certNo,7,8) >='"+Tools.processNull(beginDate)+"'";
					}
					
					if(!Tools.processNull(endDate).equals("")){
						hql+=" and substr(p.certNo,7,8) <='"+Tools.processNull(endDate)+"'";
					}
					hql+=" order by p.name asc";
					System.out.println(hql);
					List<BasePersonal> list=(List<BasePersonal>)personInfoErrataService.findByHql(hql);
					int no=0;
					if(list!=null&& list.size()>0){
						if(list.size()%10>0){//计算页码
							no=list.size()/10+1;
						}else{
							no=list.size()/10;//页码共计多少页
						}
					}
					if(list!=null&& list.size()>0){
						for(BasePersonal person:list){
							HashMap reportsHashMap = new HashMap();
							PersonBean pBean=new PersonBean();
							BaseKanwuPrint kanwup =new BaseKanwuPrint();
							pBean.setCert_No(person.getCertNo());//身份证号
							pBean.setClient_Id(person.getCustomerId().toString());//客户号
							pBean.setReside_Type(person.getResideType());//户籍类型
							pBean.setName(person.getName());//姓名
							if(this.isWindowsOS()){//windows系统
								//appPath=ServletActionContext.getRequest().getSession().getServletContext().getRealPath("\\twocode");
								appPath= this.request.getRealPath("\\twocode");
								filepathname = appPath+"\\"+person.getCustomerId()+".bmp";
								String imageFileName=filepathname.substring(filepathname.lastIndexOf('\\')+1,filepathname.lastIndexOf('.'))+"."+filepathname.substring(filepathname.lastIndexOf(".")+1);//取虚拟文件名称
								String virtualPath ="twocode\\"+ imageFileName;//虚拟路径
								pBean.setTwocodePath(filepathname);//二维码图像路径
								//写入二维码数据
								BufferedImage image = GenerateQRCode.createQRCode(person.getCustomerId().toString(), 90, 90);
								if(image != null){
									File c = new File(filepathname);
									if(!c.exists()){
										c.createNewFile();
									}
									ImageIO.write(image,"bmp",c);
								}
							}else{//其他系统
								//appPath=ServletActionContext.getRequest().getSession().getServletContext().getRealPath("/twocode");
								appPath= this.request.getRealPath("/twocode");
								filepathname = appPath+"/"+person.getCustomerId()+".bmp";
								String imageFileName=filepathname.substring(filepathname.lastIndexOf('/')+1,filepathname.lastIndexOf('.'))+"."+filepathname.substring(filepathname.lastIndexOf(".")+1);//取虚拟文件名称
								String virtualPath ="twocode/"+ imageFileName;//虚拟路径
								pBean.setTwocodePath(filepathname);//二维码图像路径
								BufferedImage image = GenerateQRCode.createQRCode(person.getCustomerId().toString(), 90, 90);
								if(image != null){
									File c = new File(filepathname);
									if(!c.exists()){
										c.createNewFile();
									}
									ImageIO.write(image,"bmp",c);
								}
							}
							BasePhoto photo=(BasePhoto)personInfoErrataService.findOnlyRowByHql("from BasePhoto e where e.customerId='"+person.getCustomerId()+"'");
							File file=null;
							if(photo!=null){
								if(photo.getPhoto()!=null){
									if(this.isWindowsOS()){//windows系统
										appPath2=this.request.getRealPath("\\photo\\"+person.getCustomerId()+".jpg");
										file= new File(appPath2);
									}else{
										appPath2=this.request.getRealPath("/photo/"+person.getCustomerId()+".jpg");
										file= new File(appPath2);
									}
									InputStream in = new ByteArrayInputStream(blobToBytes(photo.getPhoto()));
									BufferedImage input = javax.imageio.ImageIO.read(in);
									OutputStream out1 = new FileOutputStream(file);
									javax.imageio.ImageIO.write(input, "jpg", out1);
									in.close();
								}else{
									if(this.isWindowsOS()){
										appPath2=this.request.getRealPath("\\images")+"\\noperson.gif";//logo图
									}else{
										appPath2=this.request.getRealPath("/images")+"/noperson.gif";//logo图
									}
								}
							}else{
								if(this.isWindowsOS()){
									appPath2=this.request.getRealPath("\\images")+"\\noperson.gif";//logo图
								}else{
									appPath2=this.request.getRealPath("/images")+"/noperson.gif";//logo图
								}
							}
							kanwup.setCertNo(person.getCertNo());
							kanwup.setCustomerId(person.getCustomerId().toString());
							kanwup.setName(person.getName());
							kanwup.setTwocodePath(pBean.getTwocodePath());
							kanwup.setPhotoPath(appPath2);
							personInfoErrataService.saveKanwuPrint(kanwup);
					}
					String sql="";
					comm = (BaseComm) personInfoErrataService.findOnlyRowByHql("from BaseComm t where t.commId ='"+commId+"' ");
					sql="select c.Customer_Id client_id,c.name,c.cert_no,c.twocode_path,c.photo_path from Base_Personal a,Base_Corp b,base_kanwu_print c where a.customer_Id=c.customer_Id and a.corp_Customer_Id=b.Customer_Id and b.Customer_Id = '"+corpId.trim()+"' and not exists (select 1 from Card_Apply cc where cc.Customer_Id = a.Customer_Id) and (a.sure_Flag='1' or not exists (select 1 from Base_Photo ee where a.Customer_Id=ee.Customer_Id and decode(dbms_lob.getchunksize(photo),null,1,0)='0' and ee.photo_State='0')) ";
					
					
					if(!Tools.processNull(customerIds).equals("")){
						sql+=" and a.customer_Id in ("+customerIds+")";
					}
					if(!Tools.processNull(regionId).equals(""))sql+=" and a.region_id='"+regionId+"'";
					if(!Tools.processNull(townId).equals(""))sql+=" and a.town_id='"+townId+"'";
					if(!Tools.processNull(commId).equals(""))sql+=" and a.comm_id='"+commId+"'";
					if(!Tools.processNull(beginDate).equals("")){
						sql+=" and substr(a.cert_No,7,8) >='"+Tools.processNull(beginDate)+"'";
					}
					
					if(!Tools.processNull(endDate).equals("")){
						sql+=" and substr(a.cert_No,7,8) <='"+Tools.processNull(endDate)+"'";
					}
					
					sql+=" order by c.name asc";
					SysActionLog actionLog = baseService.getCurrentActionLog();
					actionLog.setMessage("勘误数据明细报表");
					actionLog.setDealCode(999999);
					SysActionLog log = personInfoErrataService.savePrintReport(actionLog, personInfoErrataService.getUser());
					String path = ServletActionContext.getRequest().getRealPath("/reportfiles/kwPZ2.jasper");
					JRResultSetDataSource source = new JRResultSetDataSource(personInfoErrataService.tofindResultSet(sql));
					byte[] pdfContent = JasperRunManager.runReportToPdf(path, reportsHashMap1,source);
					personInfoErrataService.saveSysReport(log, new JSONObject(), "",Constants.APP_REPORT_TYPE_PDF2,1l, "", pdfContent);
					pdfContent=null;
					jsonObject.put("status", true);
					jsonObject.put("title", "");
					jsonObject.put("actionNo", log.getDealNo());
				}
			}
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status", false);
			jsonObject.put("title", "错误信息");
			jsonObject.put("message", e.getMessage());
		}
		return this.JSONOBJ;
	}*/

	/**
	 * 打印勘误数据。包含勘误汇总和勘误明细
	 * @return
	 */
	public String printTotalCorrigendumData() {
		try {
			PdfConbineUtil pdfConbineUtil = new PdfConbineUtil();
			pdfConbineUtil.add(getTotalPerErrata());
			pdfConbineUtil.add(getPhotTwoCodeInfo());
			byte[] pdfContent = pdfConbineUtil.conbine();
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setMessage("勘误数据汇总明细报表");
			actionLog.setDealCode(999999);
			actionLog.setInOutData("");
			SysActionLog log = personInfoErrataService.savePrintReport(actionLog, personInfoErrataService.getUser());
			personInfoErrataService.saveSysReport(log, new JSONObject(), "", Constants.APP_REPORT_TYPE_PDF2, 1L, "", pdfContent);
			jsonObject.put("status", true);
			jsonObject.put("title", "");
			jsonObject.put("actionNo", log.getDealNo());
		} catch (Exception e) {
			jsonObject.put("status", false);
			jsonObject.put("title", "错误信息");
			jsonObject.put("message", e.getMessage());
		}
		return this.JSONOBJ;
	}

	private byte[] getTotalPerErrata() throws Exception {
		String remark = "";
		BaseCorp corp = new BaseCorp();
		HashMap reportsHashMap = new HashMap();
		if(Tools.processNull(slfs).equals("1")){//单位
			if(Tools.processNull(corpId).equals("")){
				throw new CommonException("单位编号不能为空！");
			}
			String hql="select p from BasePersonal p, BaseCorp s, BaseSiinfo x where p.corpCustomerId=s.customerId and p.customerId = x.customerId and not exists (select c.customerId from CardApply c where c.customerId = p.customerId) "
					+ "and x.medState = '0'";
			if(!Tools.processNull(customerIds).equals("")){
				hql+=" and p.customerId in ("+customerIds+")";
			}
			if(!Tools.processNull(corpId).equals(""))hql+=" and s.customerId = '"+Tools.processNull(corpId).trim()+"' ";
			if(!Tools.processNull(beginDate).equals(""))hql+=" and substr(p.certNo,7,8) >= '"+Tools.processNull(beginDate).trim()+"' ";
			if(!Tools.processNull(endDate).equals(""))hql+=" and substr(p.certNo,7,8) <= '"+Tools.processNull(endDate).trim()+"' ";
			hql+=" order by p.name asc";
			List<BasePersonal> list=(List<BasePersonal>)personInfoErrataService.findByHql(hql);
			if(list!=null&& list.size()>0){
				for(int i=0;i<list.size();i++){
					if(i==0){
						remark+=((BasePersonal)list.get(i)).getName();
						if(list.size() == i+1){
							remark += "。";
						} else {
							remark += "、";
						}
					}else if(i==1){
						remark+=((BasePersonal)list.get(i)).getName()+"等";
					}
				}
			}
			
			String hql2 = "select p from BasePersonal p,BaseCorp s, BaseSiinfo x where p.corpCustomerId=s.customerId and p.customerId = x.customerId and not exists (select c.customerId from CardApply c where c.customerId = p.customerId) "
					+ "and x.medState = '0'";
			if (!Tools.processNull(corpId).equals(""))
				hql2 += " and s.customerId = '" + Tools.processNull(corpId).trim() + "' ";
			hql2+=" order by p.name asc";
			List<BasePersonal> list2=(List<BasePersonal>)personInfoErrataService.findByHql(hql2);
			String remark2 = "";
			if (list2 != null && list2.size() > 0) {
				for (int i = 0; i < list2.size(); i++) {
					if (i == 1) {
						remark2 += ((BasePersonal) list2.get(i)).getName() + "等";
					} else if(i==0) {
						remark2 += ((BasePersonal) list2.get(i)).getName() + "、";
					}
				}
			}
			
			corp=(BaseCorp)personInfoErrataService.findOnlyRowByHql(" from BaseCorp b where b.customerId='"+corpId.trim()+"'");
//			if(Tools.processNull(corp.getContact()).equals("")){
//				throw new CommonException("单位联系人（经办人）信息为空，请添加联系人信息！");
//			}
			reportsHashMap.put("client_Id", Tools.processNull(corp.getCustomerId()));
			reportsHashMap.put("emp_Name", Tools.processNull(corp.getCorpName()));
			reportsHashMap.put("client_date", DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss"));
			if(Tools.processNull(corp.getContact()).equals("")){
				throw new CommonException("单位经办人信息为空！");
			}
			reportsHashMap.put("contact", Tools.processNull(corp.getContact()));
			reportsHashMap.put("p_con_cert_no", Tools.processNull(corp.getConCertNo()));
			reportsHashMap.put("c_tel_no", Tools.processNull(corp.getConPhone()));
			reportsHashMap.put("num", (Integer)(list == null ? 0 : list.size()));
			reportsHashMap.put("remark", remark);
			reportsHashMap.put("num2", (Integer)(list == null ? 0 : list.size()));
			reportsHashMap.put("remark2", remark2);
			SysBranch lkBrch = (SysBranch) personInfoErrataService.findOnlyRowByHql("from SysBranch where brchId = '" + corp.getLkBrchId() + "'");
			if (lkBrch == null) {
				throw new CommonException("单位未设置领卡网点！");
			} else {
				reportsHashMap.put("lkBrchName", lkBrch.getFullName());
				String bankId = (String) personInfoErrataService.findOnlyFieldBySql("select bank_id from branch_bank where brch_id = '" + lkBrch.getBrchId() + "'");
				BaseBank bank = (BaseBank) personInfoErrataService.findOnlyRowByHql("from BaseBank where bankId = '" + bankId + "'");
				if(bank == null){
					reportsHashMap.put("bankName", "");
				} else {
					reportsHashMap.put("bankName", bank.getBankName());
				}
			}
		}else if(Tools.processNull(slfs).equals("2")){
			if(Tools.processNull(regionId).equals("")){
				throw new CommonException("城区不能为空");
			}
			if(Tools.processNull(townId).equals("")){
				throw new CommonException("乡镇不能为空");
			}
			if(Tools.processNull(commId).equals("")){
				throw new CommonException("社区不能为空");
			}
			String hql="select p from BasePersonal p, BaseRegion r,BaseTown t,BaseComm m,BaseSiinfo s where p.regionId = r.regionId "
					+ "and p.townId = t.townId and p.commId = m.commId and p.customerId = s.customerId and m.commState='0' and s.medState='0' "
					+ "and not exists (select c.customerId from CardApply c where c.customerId = p.customerId)";
			if(!Tools.processNull(customerIds).equals("")){
				hql+=" and p.customerId in ("+customerIds+")";
			}
			if(!Tools.processNull(regionId).equals(""))hql+=" and p.regionId='"+regionId+"'";
			if(!Tools.processNull(townId).equals(""))hql+=" and p.townId='"+townId+"'";
			if(!Tools.processNull(commId).equals(""))hql+=" and p.commId='"+commId+"'";
			if(!Tools.processNull(beginDate).equals("")){
				hql+=" and substr(p.certNo,7,8) >='"+Tools.processNull(beginDate)+"'";
			}
			if(!Tools.processNull(endDate).equals("")){
				hql+=" and substr(p.certNo,7,8) <='"+Tools.processNull(endDate)+"'";
			}
			hql+=" order by p.name asc";
			List<BasePersonal> list=(List<BasePersonal>)personInfoErrataService.findByHql(hql);
			if(list!=null&& list.size()>0){//用户想在申领人那儿，取前二个姓名+等就可以
				for(int i=0;i<list.size();i++){
					if(i==0){
						remark+=((BasePersonal)list.get(i)).getName()+"、";
					}else if(i==1){
						remark+=((BasePersonal)list.get(i)).getName()+"等";
					}
				}
			}
			
			String hql2 = "select p from BasePersonal p, BaseRegion r,BaseTown t,BaseComm m,BaseSiinfo s where p.regionId = r.regionId "
					+ "and p.townId = t.townId and p.commId = m.commId and p.customerId = s.customerId and m.commState='0' "
					+ "and s.medState='0' and not exists (select c.customerId from CardApply c where c.customerId = p.customerId)";
			if (!Tools.processNull(regionId).equals(""))
				hql2 += " and p.regionId='" + regionId + "'";
			if (!Tools.processNull(townId).equals(""))
				hql2 += " and p.townId='" + townId + "'";
			if (!Tools.processNull(commId).equals(""))
				hql2 += " and p.commId='" + commId + "'";
			hql2+=" order by p.name asc";
			List<BasePersonal> list2 = (List<BasePersonal>) personInfoErrataService.findByHql(hql2);
			String remark2 = "";
			if (list2 != null && list2.size() > 0) {// 用户想在申领人那儿，取前二个姓名+等就可以
				for (int i = 0; i < list2.size(); i++) {
					if (i == 1) {
						remark2 += ((BasePersonal) list2.get(i)).getName() + "等";
					} else if(i == 0) {
						remark2 += ((BasePersonal) list2.get(i)).getName() + "、";
					}
				}
			}
			
			BaseRegion region=(BaseRegion) personInfoErrataService.findOnlyRowByHql("from BaseRegion r where r.regionId ='"+regionId+"' ");
			BaseTown town=(BaseTown) personInfoErrataService.findOnlyRowByHql("from BaseTown t where t.townId ='"+townId+"' ");
			BaseComm comm=(BaseComm) personInfoErrataService.findOnlyRowByHql("from BaseComm t where t.commId ='"+commId+"' ");
			reportsHashMap.put("client_Id", Tools.processNull(comm.getCommId()));
			reportsHashMap.put("emp_Name", Tools.processNull(comm.getCommName()));
			reportsHashMap.put("client_date", DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss"));
			reportsHashMap.put("contact", Tools.processNull(""));
			reportsHashMap.put("p_con_cert_no", "");
			reportsHashMap.put("c_tel_no", Tools.processNull(""));
			reportsHashMap.put("num", (Integer)(list == null ? 0 : list.size()));
			reportsHashMap.put("remark", remark);
			reportsHashMap.put("num2", (Integer)(list == null ? 0 : list.size()));
			reportsHashMap.put("remark2", remark2);
			SysBranch lkBrch = (SysBranch) personInfoErrataService.findOnlyRowByHql("from SysBranch where brchId = '" + comm.getLkBrchId() + "'");
			if (lkBrch == null) {
				reportsHashMap.put("lkBrchName", "");
				reportsHashMap.put("bankName", "");
			} else {
				reportsHashMap.put("lkBrchName", lkBrch.getFullName());
				String bankId = (String) personInfoErrataService.findOnlyFieldBySql("select bank_id from branch_bank where brch_id = '" + lkBrch.getBrchId() + "'");
				BaseBank bank = (BaseBank) personInfoErrataService.findOnlyRowByHql("from BaseBank where bankId = '" + bankId + "'");
				if(bank == null){
					reportsHashMap.put("bankName", "");
				} else {
					reportsHashMap.put("bankName", bank.getBankName());
				}
			}
		}
		String path = ServletActionContext.getRequest().getRealPath("/reportfiles/kwPZ1.jasper");
		byte[] pdfContent = JasperRunManager.runReportToPdf(path, reportsHashMap);
		return pdfContent;
	}

	private byte[] getPhotTwoCodeInfo() throws Exception {
		HashMap reportsHashMap1 = new HashMap();
		String filepathname="";
		String appPath="";
		String appPath2="";
		String dwvirtualPath="";
		BaseCorp employer  = null;
		List<HashMap> maplist=new ArrayList<HashMap>();
		String hql="";
		if(Tools.processNull(slfs).equals("1")){
			if(Tools.processNull(corpId).equals("")){
				throw new CommonException("单位编号不能为空！");
			}
			employer=(BaseCorp)personInfoErrataService.findOnlyRowByHql(" from BaseCorp b where b.customerId='"+corpId.trim()+"'");
			if(employer==null){
				throw new CommonException("单位不存在！");
			}
			hql="select p from BasePersonal p,BaseCorp s, BaseSiinfo x where p.corpCustomerId=s.customerId and p.customerId = x.customerId "
					+ " and not exists (select c.customerId from CardApply c where c.customerId = p.customerId) and x.medState = '0' ";
			if(!Tools.processNull(customerIds).equals("")){
				hql+=" and p.customerId in ("+customerIds+")";
			}
			if(!Tools.processNull(corpId).equals(""))hql+=" and s.customerId = '"+Tools.processNull(corpId).trim()+"' ";
			if(!Tools.processNull(beginDate).equals(""))hql+=" and substr(p.certNo,7,8) >= '"+Tools.processNull(beginDate).trim()+"' ";
			if(!Tools.processNull(endDate).equals(""))hql+=" and substr(p.certNo,7,8) <= '"+Tools.processNull(endDate).trim()+"' ";
		
			hql+=" order by p.name asc";
			List<BasePersonal> list=(List<BasePersonal>)personInfoErrataService.findByHql(hql);
			int no=0;
			if(list!=null&& list.size()>0){
				if(list.size()%10>0){//计算页码
				no=list.size()/10+1;
				}else{
					no=list.size()/10;//页码共计多少页
				}
			} else {
				return null;
			}
			if(list!=null&& list.size()>0){
				for(BasePersonal person:list){
					HashMap reportsHashMap = new HashMap();
					PersonBean pBean=new PersonBean();
					BaseKanwuPrint kanwup =new BaseKanwuPrint();
					pBean.setCert_No(person.getCertNo());//身份证号
					pBean.setClient_Id(person.getCustomerId().toString());//客户号
					pBean.setReside_Type(person.getResideType());//户籍类型
					pBean.setName(person.getName());//姓名
					if(this.isWindowsOS()){//windows系统
						//appPath=ServletActionContext.getRequest().getSession().getServletContext().getRealPath("\\twocode");
						appPath= this.request.getRealPath("\\twocode");
						filepathname = appPath+"\\"+person.getCustomerId()+".bmp";
						String imageFileName=filepathname.substring(filepathname.lastIndexOf('\\')+1,filepathname.lastIndexOf('.'))+"."+filepathname.substring(filepathname.lastIndexOf(".")+1);//取虚拟文件名称
						String virtualPath ="twocode\\"+ imageFileName;//虚拟路径
						pBean.setTwocodePath(filepathname);//二维码图像路径
						//写入二维码数据
						BufferedImage image = GenerateQRCode.createQRCode(person.getCustomerId().toString(), 42, 42);
						if(image != null){
							File c = new File(filepathname);
							if(!c.exists()){
								c.createNewFile();
							}
							ImageIO.write(image,"bmp",c);
						}
					}else{//其他系统
						//appPath=ServletActionContext.getRequest().getSession().getServletContext().getRealPath("/twocode");
						appPath= this.request.getRealPath("/twocode");
						filepathname = appPath+"/"+person.getCustomerId()+".bmp";
						String imageFileName=filepathname.substring(filepathname.lastIndexOf('/')+1,filepathname.lastIndexOf('.'))+"."+filepathname.substring(filepathname.lastIndexOf(".")+1);//取虚拟文件名称
						String virtualPath ="twocode/"+ imageFileName;//虚拟路径
						pBean.setTwocodePath(filepathname);//二维码图像路径
						BufferedImage image = GenerateQRCode.createQRCode(person.getCustomerId().toString(), 42, 42);
						if(image != null){
							File c = new File(filepathname);
							if(!c.exists()){
								c.createNewFile();
							}
							ImageIO.write(image,"bmp",c);
						}
					}
					BasePhoto photo=(BasePhoto)personInfoErrataService.findOnlyRowByHql("from BasePhoto e where e.customerId='"+person.getCustomerId()+"'");
					File file=null;
					if(photo!=null){
						if(photo.getPhoto()!=null){
							if(this.isWindowsOS()){//windows系统
								appPath2=this.request.getRealPath("\\photo\\"+person.getCustomerId()+".jpg");
								file= new File(appPath2);
							}else{
								appPath2=this.request.getRealPath("/photo/"+person.getCustomerId()+".jpg");
								file= new File(appPath2);
							}
							InputStream in = new ByteArrayInputStream(blobToBytes(photo.getPhoto()));
							BufferedImage input = javax.imageio.ImageIO.read(in);
							OutputStream out1 = new FileOutputStream(file);
							javax.imageio.ImageIO.write(input, "jpg", out1);
							in.close();
						}else{
							if(this.isWindowsOS()){
								appPath2=this.request.getRealPath("\\images")+"\\noperson.gif";//logo图
							}else{
								appPath2=this.request.getRealPath("/images")+"/noperson.gif";//logo图
							}
						}
					}else{
						if(this.isWindowsOS()){
							appPath2=this.request.getRealPath("\\images")+"\\noperson.gif";//logo图
						}else{
							appPath2=this.request.getRealPath("/images")+"/noperson.gif";//logo图
						}
					}
					kanwup.setCertNo(person.getCertNo());
					kanwup.setCustomerId(person.getCustomerId().toString());
					kanwup.setName(person.getName());
					kanwup.setTwocodePath(pBean.getTwocodePath());
					kanwup.setPhotoPath(appPath2);
					personInfoErrataService.saveKanwuPrint(kanwup);
				}
			}
			//dao.insert(this.getSys_Action_Log());
			String sql="";
			sql="select c.Customer_Id client_id,c.name name,c.cert_no cert_no,c.twocode_path twocode_path,c.photo_path photo_path, nvl(a.mobile_no, ' ') mobile_num, nvl(a.letter_addr, ' ') addr from Base_Personal a,Base_Corp b,base_kanwu_print c "
					+ " where a.customer_Id=c.customer_Id and a.corp_Customer_Id=b.Customer_Id and b.Customer_Id = '"+corpId.trim()+"' "
					+ " and not exists (select 1 from Card_Apply cc where cc.Customer_Id = a.Customer_Id)";
			
			if(!Tools.processNull(customerIds).equals("")){
				sql+=" and a.customer_Id in ("+customerIds+")";
			}
			if(!Tools.processNull(corpId).equals(""))sql+=" and b.customer_Id = '"+Tools.processNull(corpId).trim()+"' ";
			//if(!Tools.processNull(corpName).equals(""))hql+=" and s.corpName = '"+Tools.processNull(corpName).trim()+"' ";
			if(!Tools.processNull(beginDate).equals(""))sql+=" and substr(a.cert_No,7,8) >= '"+Tools.processNull(beginDate).trim()+"' ";
			if(!Tools.processNull(endDate).equals(""))sql+=" and substr(a.cert_No,7,8) <= '"+Tools.processNull(endDate).trim()+"' ";
		
			sql+=" order by c.name";
			String path = ServletActionContext.getRequest().getRealPath("/reportfiles/kwPZ2.jasper");
			//reportsHashMap1.put("dwtwocode",corpId);
			reportsHashMap1.put("dw",employer.getCorpName());
			reportsHashMap1.put("corpId",employer.getCustomerId());
			int page = list.size()%8==0?list.size()/8:list.size()/8 + 1;
			reportsHashMap1.put("num",page + "");
			JRResultSetDataSource source = new JRResultSetDataSource(personInfoErrataService.tofindResultSet(sql));
			byte[] pdfContent = JasperRunManager.runReportToPdf(path, reportsHashMap1,source);
			return pdfContent;
		}else if (Tools.processNull(slfs).equals("2")){
			if(Tools.processNull(regionId).equals("")){
				throw new CommonException("城区不能为空");
			}
			if(Tools.processNull(townId).equals("")){
				throw new CommonException("乡镇不能为空");
			}
			if(Tools.processNull(commId).equals("")){
				throw new CommonException("社区不能为空");
			}
			BaseRegion region=(BaseRegion) personInfoErrataService.findOnlyRowByHql("from BaseRegion r where r.regionId ='"+regionId+"' ");
			BaseTown town=(BaseTown) personInfoErrataService.findOnlyRowByHql("from BaseTown t where t.townId ='"+townId+"' ");
			BaseComm comm=(BaseComm) personInfoErrataService.findOnlyRowByHql("from BaseComm t where t.commId ='"+commId+"' ");
			hql="select p from BasePersonal p, BaseRegion r,BaseTown t,BaseComm m ,BaseSiinfo s where p.regionId = r.regionId "
					+ "and p.customerId = s.customerId  and p.townId = t.townId and p.commId = m.commId and m.commState='0' "
					+ "and s.medState='0' "
					+ "and not exists (select c.customerId from CardApply c where c.customerId = p.customerId)";
			
			if(!Tools.processNull(customerIds).equals("")){
				hql+=" and p.customerId in ("+customerIds+")";
			}
			if(!Tools.processNull(regionId).equals(""))hql+=" and r.regionId='"+regionId+"'";
			if(!Tools.processNull(townId).equals(""))hql+=" and t.townId='"+townId+"'";
			if(!Tools.processNull(townId).equals(""))hql+=" and m.commId='"+commId+"'";
		
			if(!Tools.processNull(beginDate).equals("")){
				hql+=" and substr(p.certNo,7,8) >='"+Tools.processNull(beginDate)+"'";
			}
			
			if(!Tools.processNull(endDate).equals("")){
				hql+=" and substr(p.certNo,7,8) <='"+Tools.processNull(endDate)+"'";
			}
			hql+=" order by p.name asc";
			System.out.println(hql);
			List<BasePersonal> list=(List<BasePersonal>)personInfoErrataService.findByHql(hql);
			int no=0;
			if(list!=null&& list.size()>0){
				if(list.size()%10>0){//计算页码
					no=list.size()/10+1;
				}else{
					no=list.size()/10;//页码共计多少页
				}
			} else {
				return null;
			}
			if(list!=null&& list.size()>0){
				for(BasePersonal person:list){
					HashMap reportsHashMap = new HashMap();
					PersonBean pBean=new PersonBean();
					BaseKanwuPrint kanwup =new BaseKanwuPrint();
					pBean.setCert_No(person.getCertNo());//身份证号
					pBean.setClient_Id(person.getCustomerId().toString());//客户号
					pBean.setReside_Type(person.getResideType());//户籍类型
					pBean.setName(person.getName());//姓名
					if(this.isWindowsOS()){//windows系统
						//appPath=ServletActionContext.getRequest().getSession().getServletContext().getRealPath("\\twocode");
						appPath= this.request.getRealPath("\\twocode");
						filepathname = appPath+"\\"+person.getCustomerId()+".bmp";
						String imageFileName=filepathname.substring(filepathname.lastIndexOf('\\')+1,filepathname.lastIndexOf('.'))+"."+filepathname.substring(filepathname.lastIndexOf(".")+1);//取虚拟文件名称
						String virtualPath ="twocode\\"+ imageFileName;//虚拟路径
						pBean.setTwocodePath(filepathname);//二维码图像路径
						//写入二维码数据
						BufferedImage image = GenerateQRCode.createQRCode(person.getCustomerId().toString(), 42, 42);
						if(image != null){
							File c = new File(filepathname);
							if(!c.exists()){
								c.createNewFile();
							}
							ImageIO.write(image,"bmp",c);
						}
					}else{//其他系统
						//appPath=ServletActionContext.getRequest().getSession().getServletContext().getRealPath("/twocode");
						appPath= this.request.getRealPath("/twocode");
						filepathname = appPath+"/"+person.getCustomerId()+".bmp";
						String imageFileName=filepathname.substring(filepathname.lastIndexOf('/')+1,filepathname.lastIndexOf('.'))+"."+filepathname.substring(filepathname.lastIndexOf(".")+1);//取虚拟文件名称
						String virtualPath ="twocode/"+ imageFileName;//虚拟路径
						pBean.setTwocodePath(filepathname);//二维码图像路径
						BufferedImage image = GenerateQRCode.createQRCode(person.getCustomerId().toString(), 42, 42);
						if(image != null){
							File c = new File(filepathname);
							if(!c.exists()){
								c.createNewFile();
							}
							ImageIO.write(image,"bmp",c);
						}
					}
					BasePhoto photo=(BasePhoto)personInfoErrataService.findOnlyRowByHql("from BasePhoto e where e.customerId='"+person.getCustomerId()+"'");
					File file=null;
					if(photo!=null){
						if(photo.getPhoto()!=null){
							if(this.isWindowsOS()){//windows系统
								appPath2=this.request.getRealPath("\\photo\\"+person.getCustomerId()+".jpg");
								file= new File(appPath2);
							}else{
								appPath2=this.request.getRealPath("/photo/"+person.getCustomerId()+".jpg");
								file= new File(appPath2);
							}
							InputStream in = new ByteArrayInputStream(blobToBytes(photo.getPhoto()));
							BufferedImage input = javax.imageio.ImageIO.read(in);
							OutputStream out1 = new FileOutputStream(file);
							javax.imageio.ImageIO.write(input, "jpg", out1);
							in.close();
						}else{
							if(this.isWindowsOS()){
								appPath2=this.request.getRealPath("\\images")+"\\noperson.gif";//logo图
							}else{
								appPath2=this.request.getRealPath("/images")+"/noperson.gif";//logo图
							}
						}
					}else{
						if(this.isWindowsOS()){
							appPath2=this.request.getRealPath("\\images")+"\\noperson.gif";//logo图
						}else{
							appPath2=this.request.getRealPath("/images")+"/noperson.gif";//logo图
						}
					}
					kanwup.setCertNo(person.getCertNo());
					kanwup.setCustomerId(person.getCustomerId().toString());
					kanwup.setName(person.getName());
					kanwup.setTwocodePath(pBean.getTwocodePath());
					kanwup.setPhotoPath(appPath2);
					personInfoErrataService.saveKanwuPrint(kanwup);
			}
			String sql="";
			comm = (BaseComm) personInfoErrataService.findOnlyRowByHql("from BaseComm t where t.commId ='"+commId+"' ");
			sql="select c.Customer_Id client_id,c.name,c.cert_no,c.twocode_path,c.photo_path, nvl(a.mobile_no, ' ') mobile_num, "
					+ "nvl(a.letter_addr, ' ') addr from Base_Personal a,Base_region b, base_town t, base_comm cc, base_siinfo x, base_kanwu_print c "
					+ "where a.customer_Id=c.customer_Id and a.region_id=b.region_id and t.town_id = a.town_id and a.comm_id = cc.comm_id and a.customer_id = x.customer_id "
					+ "and not exists (select 1 from Card_Apply cc where cc.Customer_Id = a.Customer_Id) and x.med_State = '0' ";
			
			if(!Tools.processNull(customerIds).equals("")){
				sql+=" and a.customer_Id in ("+customerIds+")";
			}
			if(!Tools.processNull(regionId).equals(""))sql+=" and a.region_id='"+regionId+"'";
			if(!Tools.processNull(townId).equals(""))sql+=" and a.town_id='"+townId+"'";
			if(!Tools.processNull(commId).equals(""))sql+=" and a.comm_id='"+commId+"'";
			if(!Tools.processNull(beginDate).equals("")){
				sql+=" and substr(a.cert_No,7,8) >='"+Tools.processNull(beginDate)+"'";
			}
			
			if(!Tools.processNull(endDate).equals("")){
				sql+=" and substr(a.cert_No,7,8) <='"+Tools.processNull(endDate)+"'";
			}
			
			sql+=" order by c.name asc";
			String path = ServletActionContext.getRequest().getRealPath("/reportfiles/kwPZ2.jasper");
			Object commName = personInfoErrataService.findOnlyFieldBySql("select t.region_name || '（区域） ' || t2.town_name || '乡镇（街道） ' || t3.comm_name || '（社区）' from base_region t join base_town t2 on t.region_id = t2.region_id join base_comm t3 on t2.town_id = t3.town_id where t3.comm_id = '" + commId + "'");
			reportsHashMap1.put("dw",commName);
			reportsHashMap1.put("corpId",commId);
			int page = list.size()%8==0?list.size()/8:list.size()/8 + 1;
			reportsHashMap1.put("num",page + "");
			JRResultSetDataSource source = new JRResultSetDataSource(personInfoErrataService.tofindResultSet(sql));
			byte[] pdfContent = JasperRunManager.runReportToPdf(path, reportsHashMap1,source);
			return pdfContent;
			}
		}
		return null;
	}

	/**
     * 判断是否windows系统
     * @return
     */
	private static boolean isWindowsOS() {
		boolean isWindowsOS = false;
		String osName = System.getProperty("os.name");
		if (osName.toLowerCase().indexOf("windows") > -1) {
			isWindowsOS = true;
		}
		return isWindowsOS;
	}
	
	 private  byte[] blobToBytes(Blob blob) {
	        BufferedInputStream is = null;
	        byte[] bytes = null;
	        try {
	            is = new BufferedInputStream(blob.getBinaryStream());
	            bytes = new byte[(int) blob.length()];
	            int len = bytes.length;
	            int offset = 0;
	            int read = 0;
	 
	            while (offset < len
	                    && (read = is.read(bytes, offset, len - offset)) >= 0) {
	                offset += read;
	            }
	 
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	        return bytes;
	 
	    }
	
	/**
	 * 初始化表格
	 * @throws Exception
	 */
	@SuppressWarnings("unused")
	private void initGrid() throws Exception {
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		jsonObject.put("status", 0);
		jsonObject.put("errMsg", "");
	}

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}

	public String getSlfs() {
		return slfs;
	}

	public void setSlfs(String slfs) {
		this.slfs = slfs;
	}

	public String getCorpId() {
		return corpId;
	}

	public void setCorpId(String corpId) {
		this.corpId = corpId;
	}

	public String getCorpName() {
		return corpName;
	}

	public void setCorpName(String corpName) {
		this.corpName = corpName;
	}

	public String getRegionId() {
		return regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	public String getTownId() {
		return townId;
	}

	public void setTownId(String townId) {
		this.townId = townId;
	}

	public String getCommId() {
		return commId;
	}

	public void setCommId(String comnId) {
		this.commId = comnId;
	}

	public String getBeginDate() {
		return beginDate;
	}

	public void setBeginDate(String beginDate) {
		this.beginDate = beginDate;
	}

	public String getEndDate() {
		return endDate;
	}

	public void setEndDate(String endDate) {
		this.endDate = endDate;
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

	public String getCustomerIds() {
		return customerIds;
	}

	public void setCustomerIds(String customerIds) {
		this.customerIds = customerIds;
	}

	public String getHasPhoto() {
		return hasPhoto;
	}

	public void setHasPhoto(String hasPhoto) {
		this.hasPhoto = hasPhoto;
	}
}
