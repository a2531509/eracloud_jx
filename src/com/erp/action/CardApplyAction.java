/**
 * 
 */
package com.erp.action;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.apache.shiro.SecurityUtils;
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
import com.erp.model.BaseCity;
import com.erp.model.BaseComm;
import com.erp.model.BaseCorp;
import com.erp.model.BaseGroup;
import com.erp.model.BasePersonal;
import com.erp.model.BaseRegion;
import com.erp.model.BaseSiinfo;
import com.erp.model.BaseTown;
import com.erp.model.CardApply;
import com.erp.model.CardApplyTask;
import com.erp.model.CardConfig;
import com.erp.model.ExportCardApplyModel;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.TrServRec;
import com.erp.service.CardApplyService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.ExportExcel;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

import net.sf.jasperreports.engine.JasperRunManager;
import sun.misc.BASE64Decoder;
/**
 * 规模申领
 * @author yangn
 * @version 1.0
 * @email yn_yangning@foxmail.com
 * @date  2015-06-09
 */
@Namespace(value="/cardapply")
@Action(value="cardApplyAction")
@Results({
	@Result(name="personlist",location="/jsp/cardApp/selectedpersonlist.jsp"),
	@Result(name="viewlist",location="/jsp/cardApp/viewlist.jsp"),
	@Result(name="toCardApplyByIdCard",location="/jsp/cardApp/cardApplyByIdCard.jsp"),
	@Result(name="toOneCardApplyIndex",location="/jsp/cardApp/oneCardApply.jsp"),
	@Result(name="jrsbkdataimportMain",location="/jsp/cardApp/jrsbkdataimportMain.jsp")
})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class CardApplyAction extends BaseAction {
	public static Logger logger = Logger.getLogger(CardApplyAction.class);
	private static final long serialVersionUID = 1L;
	private TrServRec rec = new TrServRec();
	@Resource(name="cardApplyService")
	private CardApplyService cardApplyService;
	public CardApply apply = new CardApply();
	public BasePersonal bp = new BasePersonal();
	private String branchId;//申领信息查询办理网点
	private String operId;
    private String taskId,apply_Id = "";
	private String cardType;
	private String applyWay;
	private String beginTime;
	private String endTime;
	private String regionId;//区域，城市里面的区，例如郑州的金水区
	private String corpRegionId;//单位所在区域
	private String townId;//村/镇/街道
	private String commId;
    private String groupId;
	private String queryType = "1";//查询类型
	private String companyNo;//单位编号
	private String companyName;//单位名称
	private String sort;//排序列名
	private String order;//排序 asc 升序 desc 降序
	private String makeCardWay;//制卡方式 0 本地制卡 1 外包制卡（需要生成卡号） 2 本地加急  3 外包加急
	private String isPhoto = "1";//是否判断照片
	private String corpType = "",certNo = "",clientName = "",bankId = "",bkvenId = "";//单位类型
	private String corpName;
	private String urgentFee = "0";
	private String costFee = "0";
	private String isUrgent = "";
	private String agtCertType = "";
	private String agtCertNo = "";
	private String agtName;
	private String customerId = "";
	private String agtTelNo;
	private String recvBrchId;
	private String selectedId;
    public String personPhotoContent = "";//读身份证得到的base64字符串
    public String bustype3;
    private String template;
    public String defaultErrMsg;
    private String customerName;
    private String applyIds;
    private String synGroupId;
	private File[] file;              
    private String[] fileFileName;    
    private String[] filePath;
    private String isJudgeSbState = "0";//申领时是否判断医保状态
    private String isBatchHf = "0";//是否批量换发业务 0 批量换卡  1 非批量换发
    private boolean onlyAppNewCard = false;
    private boolean onlyAppHFCard = false;
    private String batchNo;
	/**
	 * 申领信息查询
	 * @return
	 */
	public String toSearchApplyMsg(){
		try{
			this.initDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			JSONObject para = new JSONObject();
			para.put("taskId",Tools.processNull(apply.getTaskId()));
			para.put("buyPlanId",Tools.processNull(apply.getBuyPlanId()));
			para.put("applyWay",Tools.processNull(apply.getApplyWay()));
			para.put("applyId",Tools.processNull(apply.getApplyId()));
			para.put("certNo",Tools.processNull(bp.getCertNo()));
			para.put("name",Tools.processNull(bp.getName()));
			para.put("applyBrchId",Tools.processNull(apply.getApplyBrchId()));
			para.put("applyUserId",Tools.processNull(apply.getApplyUserId()));
			para.put("corpName",Tools.processNull(corpName));
			para.put("corpId",Tools.processNull(apply.getCorpId()));
			para.put("beginTime",Tools.processNull(this.beginTime));
			para.put("endTime",Tools.processNull(this.endTime));
			para.put("regionId",Tools.processNull(bp.getRegionId()));
			para.put("townId",Tools.processNull(bp.getTownId()));
			para.put("commId",Tools.processNull(bp.getCommId()));
			para.put("certType",Tools.processNull(bp.getCertType()));
			para.put("applyState",Tools.processNull(apply.getApplyState()));
            para.put("taskName",Tools.processNull(companyName));
			if(!Tools.processNull(this.sort).equals("")){
				para.put("sort",Tools.processNull(this.sort));
				para.put("order",Tools.processNull(this.order));
			}
			Page list = cardApplyService.toSearchApplyMsg(para,page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未找到相应申领信息");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
			logger.error(e);
		}
		return this.JSONOBJ;
	}
	
	public String toQueryBasePersonal(){
		return "";
	}
	
	/**
	 * 规模申领人员信息分组查询
	 * @return
	 */
	public String batchApplySearch(){
		try{
			this.initDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			String selectRs = "";
			String whereRs  = "";
			String groupRs  = "group by ";
			String orderby = " order by ";
			String selectId = "";
			if(Tools.processNull(applyWay).equals(Constants.APPLY_WAY_SQ)){
				if(Tools.processNull(this.regionId).equals("")){
					throw new CommonException("请选择所属区域！");
				}
				whereRs  += "and t.region_id = '" + this.regionId + "' "; 
				selectRs += "t.region_id,(select region_name from base_region where region_id = t.region_id) region_name ";
				groupRs  += "t.region_id";
				if(Tools.processNull(this.townId).equals("")){
					throw new CommonException("请选择所属乡镇（街道）！");
				}
				whereRs  += "and t.town_id = '" + this.townId + "' "; 
				selectRs += ",t.town_id,(select town_name from base_town where town_id = t.town_id) town_name ";
				groupRs  += ",t.town_id" ;
				selectId = "'" + this.applyWay + "' || '|' || t.region_id || '|' || t.town_id ";
				if(!Tools.processNull(this.commId).equals("")){
					whereRs += "and t.comm_id = '" + this.commId + "' ";
					selectRs += ",t.comm_id,(select comm_name from base_comm where comm_id = t.comm_id) comm_name ";
					groupRs += ",t.comm_id";
					selectId += "|| '|' || t.comm_id ";
					if(!Tools.processNull(this.groupId).equals("")){
						whereRs += "and t.group_id = '" + this.groupId + "' ";
						selectRs += ",t.group_id,(select group_name from base_group where group_id = t.group_id) group_name ";
						groupRs += ",t.group_id";
						selectId += "|| '|' || t.group_id ";
						orderby = "";
					}else{
						if(Tools.processNull(this.synGroupId).equals("0")){
							selectRs += ",t.group_id,(select group_name from base_group where group_id = t.group_id) group_name ";
							groupRs += ",t.group_id ";
							selectId += "|| '|' || t.group_id ";
							orderby += "t.region_id asc,t.town_id asc,t.comm_id asc,t.group_id asc";
						}else{
							selectId += "|| '|' ";
							orderby += "t.region_id asc,t.town_id asc,t.comm_id asc";
						}
					}
				}else{
					if(Tools.processNull(this.synGroupId).equals("0")){
						selectRs += ",t.comm_id,(select comm_name from base_comm where comm_id = t.comm_id) comm_name,t.group_id,(select group_name from base_group where group_id = t.group_id) group_name ";
						groupRs += ",t.comm_id,t.group_id ";
						selectId += "|| '|' || t.comm_id || '|' || t.group_id ";
						orderby += "t.region_id asc,t.town_id asc,t.comm_id asc,t.group_id asc";
					}else{
						selectRs += ",t.comm_id,(select comm_name from base_comm where comm_id = t.comm_id) comm_name ";
						groupRs += ",t.comm_id";
						selectId += "|| '|' || t.comm_id || '|' ";
						orderby += "t.region_id asc,t.town_id asc,t.comm_id asc";
					}
				}
				selectId += "|| '|' || '" + Tools.processNull(this.cardType) + "' || '|' || '" + Tools.processNull(this.beginTime) + "' || '|' || '" + Tools.processNull(this.endTime) + "' || '|' || '" + Tools.processNull(this.isPhoto) + "' || '|' || '" + this.isJudgeSbState + "' || '|' || '" + this.isBatchHf + "' selectId,";
				sb.append("select " + selectId);
				sb.append(selectRs);
				sb.append(",count(1) totNums from base_personal t,base_region r,base_town w,base_comm m ");
				sb.append("where t.region_id = r.region_id and t.town_id = w.town_id ");
				sb.append("and t.comm_id = m.comm_id and r.region_id = w.region_id and w.town_id = m.town_id and t.customer_state = '0' /*and t.sure_flag = '0'*/ ");
				if(Tools.processNull(this.isJudgeSbState).equals(Constants.YES_NO_YES)){
					sb.append("and exists (select 1 from base_siinfo f where f.cert_no = t.cert_no and f.med_state = '0' and f.name = t.name and f.med_whole_no = '" + baseService.getBrchRegion() + "') ");
				}
				sb.append("and not exists (select 1 from card_apply b where b.customer_id = t.customer_id and (b.apply_state < '" + Constants.APPLY_STATE_YZX + "' ");
				sb.append("and b.apply_state <> '" + Constants.APPLY_STATE_WJWSHBTG + "' and b.apply_state <> '" + Constants.APPLY_STATE_YHSHBTG + "' ");
				sb.append("and b.apply_state <> '" + Constants.APPLY_STATE_YTK + "' ");//and b.card_type = '" + this.cardType + "'
				if(Tools.processNull(this.isBatchHf).equals(Constants.YES_NO_YES)){
					sb.append("and b.card_type = '" + Constants.CARD_TYPE_SMZK + "'");
				}
				sb.append(")) ");
				if(Tools.processNull(this.isBatchHf).equals(Constants.YES_NO_YES)){
					sb.append("and exists (select 1 from card_baseinfo p where p.customer_id = t.customer_id and p.card_state < '9' and p.card_type = '" + Constants.CARD_TYPE_QGN + "') ");
				}
				sb.append(whereRs);
				if(Tools.processNull(this.isPhoto).equals("0")){
					sb.append("and exists (select 1 from base_photo p where p.customer_id = t.customer_id and p.photo_state = '0' and lengthb(p.photo) > 0) ");
				}
				if(!Tools.processNull(this.beginTime).equals("")){
					sb.append("and substr(t.cert_no,7,8) >= '" + this.beginTime.replaceAll("-","") + "' ");
				}
				if(!Tools.processNull(this.endTime).equals("")){
					sb.append("and substr(t.cert_no,7,8) <= '" + this.endTime.replaceAll("-","") + "' ");
				}
				sb.append(groupRs);
				sb.append(orderby);
			}else if(Tools.processNull(applyWay).equals(Constants.APPLY_WAY_DW)){
				if(Tools.processNull(this.companyNo).equals("") && Tools.processNull(this.companyName).equals("") && Tools.processNull(this.corpType).equals("") && Tools.processNull(this.corpRegionId).equals("")){
					throw new CommonException("请输入或选择查询参数信息！");
				}
				if(!Tools.processNull(this.companyNo).equals("")){
					whereRs += "and t.corp_customer_id in (" + Tools.getConcatStrFromArray(this.companyNo.split(","),"'",",") + ") ";
				}
				if(!Tools.processNull(this.companyName).equals("")){
					//whereRs += "and c.corp_name like '%" + this.companyName + "%' ";
				}
				if(!Tools.processNull(this.corpType).equals("")){
					whereRs += "and c.corp_type = '" + this.corpType + "' ";
				}
				if(!Tools.processNull(this.corpRegionId).equals("")){
					whereRs += "and c.region_id = '" + this.corpRegionId + "' ";
				}
				groupRs += "t.corp_customer_id ";
				selectId = "'" + Tools.processNull(applyWay) + "' || '|' || t.corp_customer_id " ;
				selectId += "|| '|' || '" + Tools.processNull(this.cardType) + "' || '|' || '" + Tools.processNull(this.beginTime) + "' || '|' || '" + Tools.processNull(this.endTime) + "' || '|' || '" + Tools.processNull(this.isPhoto) + "' || '|' || '" + this.isJudgeSbState + "' || '|' || '" + this.isBatchHf +"' selectId,";
				sb.append("select " + selectId + "t.corp_customer_id,(select t1.corp_name from base_corp t1 where t1.customer_id = t.corp_customer_id) corp_name,");
				sb.append("(select t2.abbr_name from base_corp t2 where t2.customer_id = t.corp_customer_id) abbr_name,(select code_name from sys_code where code_type = 'CORP_TYPE' and code_value = (select t3.corp_type from base_corp t3 where t3.customer_id = t.corp_customer_id)) corp_type,");
				sb.append("count(1) totNums, (select count(1) from base_personal ppp where ppp.corp_customer_id = t.corp_customer_id and not exists (select 1 from card_apply where customer_id = ppp.customer_id and apply_state < '90' and apply_state not in ('12', '15', '70'))) no_app_num from base_personal t,base_region r,base_corp c where t.region_id = r.region_id(+) and t.corp_customer_id = c.customer_id ");
				sb.append("and t.customer_state = '0'  /*and t.sure_flag = '0'*/ ");
				if(Tools.processNull(this.isJudgeSbState).equals(Constants.YES_NO_YES)){
					sb.append("and exists (select 1 from base_siinfo f where f.cert_no = t.cert_no and f.name = t.name and f.med_state = '0' and f.med_whole_no = '" + baseService.getBrchRegion() + "') ");
				}
				sb.append("and not exists (select 1 from card_apply b where b.customer_id = t.customer_id and (b.apply_state < '" + Constants.APPLY_STATE_YZX + "' ");
				sb.append("and b.apply_state <> '" + Constants.APPLY_STATE_WJWSHBTG + "' and b.apply_state <> '" + Constants.APPLY_STATE_YHSHBTG + "' ");
				sb.append("and b.apply_state <> '" + Constants.APPLY_STATE_YTK + "' ");
				if(Tools.processNull(this.isBatchHf).equals(Constants.YES_NO_YES)){
					sb.append("and b.card_type = '" + Constants.CARD_TYPE_SMZK + "'");
				}
				sb.append(")) ");
				if(Tools.processNull(this.isBatchHf).equals(Constants.YES_NO_YES)){
					sb.append("and exists (select 1 from card_baseinfo p where p.customer_id = t.customer_id and p.card_state < '9' and p.card_type = '" + Constants.CARD_TYPE_QGN + "') ");
				}
				sb.append(whereRs);
				if(Tools.processNull(this.isPhoto).equals("0")){
					sb.append("and exists (select 1 from base_photo p where p.customer_id = t.customer_id and p.photo_state = '0' and lengthb(p.photo) > 0) ");
				}
				if(!Tools.processNull(this.beginTime).equals("")){
					sb.append("and substr(t.cert_no,7,8) >= '" + this.beginTime.replaceAll("-","") + "' ");
				}
				if(!Tools.processNull(this.endTime).equals("")){
					sb.append("and substr(t.cert_no,7,8) <= '" + this.endTime.replaceAll("-","") + "' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					orderby += " " + sort;
					if(!Tools.processNull(this.order).equals("")){
						orderby += " " + order;
					}
				} else {
					orderby += " t.corp_customer_id";
				}
				sb.append(groupRs);
				sb.append(orderby);
			}else if(Tools.processNull(applyWay).equals(Constants.APPLY_WAY_XX)){
				
			}else{
				throw new CommonException("选择的申领方式不正确！");
			}
			Page list = cardApplyService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getTotalCount() > 0 ){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未查询到符合条件的信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String batchApplyImportSearch() {
		try {
			companyNo = "";
			queryType = "0";
			if (file == null || file.length == 0) {
				throw new CommonException("上传文件为空.");
			}
			Workbook workbook = new HSSFWorkbook(new FileInputStream(file[0]));
			Sheet sheet = workbook.getSheetAt(0);
			int lastRowNum = sheet.getLastRowNum();
			for (int i = 0; i <= lastRowNum; i++) {
				Row row = sheet.getRow(i);
				if (row == null) {
					continue;
				}
				Cell cell = row.getCell(0);
				if (cell == null) {
					continue;
				}
				String corpId = cell.getStringCellValue();
				if (corpId == null || !corpId.matches("[0-9]{10}")) {
					continue;
				}
				companyNo += corpId.trim() + ",";
			}
			workbook.close();
			if(!companyNo.equals("")){
				companyNo = companyNo.substring(0, companyNo.length() - 1);
			}
			batchApplySearch();
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * 人员信息预览
	 * @return
	 */
	public String viewPersonDetail(){
		try{
			this.initDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			if(Tools.processNull(this.selectedId).equals("")){
				throw new CommonException("查询条件不能为空！");
			}
			this.selectedId = URLDecoder.decode(this.selectedId,"UTF-8");
			parseInParams(this.selectedId);
			StringBuffer sb = new StringBuffer();
			sb.append("select t.customer_id num,t.customer_id,t.name,");
			sb.append("(select d.code_name from sys_code d where d.code_type = 'CERT_TYPE' and d.code_value = t.cert_type) certType,");
			sb.append("t.cert_no,(case when length(t.birthday) = 8 then to_char(to_date(t.birthday,'yyyymmdd'),'yyyy-mm-dd') else t.birthday end) birthday,");
			sb.append("(select d.code_name from sys_code d where d.code_type = 'SEX' and d.code_value = t.gender) gender,");
			sb.append("(select d.code_name from sys_code d where d.code_type = 'NATION' and d.code_value = t.nation) nation,");
			sb.append("(select r1.comm_name from base_comm r1 where r1.comm_id = t.comm_id) commName,");
			sb.append("(select r2.region_name from base_region r2 where r2.region_id = t.region_id) regionName,");
			sb.append("(select r3.town_name from base_town r3 where r3.region_id = t.region_id and r3.town_id = t.town_id) townName,");
			sb.append("t.letter_addr,t.reside_addr,t.mobile_No,t.corp_customer_id,decode(t.sure_flag,'0','是','否') sure_flag ");
			sb.append("from BASE_PERSONAL t,base_region r ");
			sb.append("where t.region_id = r.region_id(+) ");
			if(Tools.processNull(this.isJudgeSbState).equals(Constants.YES_NO_YES)){
				sb.append("and exists (select 1 from base_siinfo f where f.cert_no = t.cert_no and f.name = t.name and f.med_whole_no = '" + baseService.getBrchRegion() + "' and f.med_state = '0' ) ");
			}
			sb.append("and t.customer_state = '0' /*and t.sure_flag = '0'*/ and not exists (select 1 from card_apply c where c.customer_id = t.customer_id ");
			sb.append("and (c.apply_State < '" + Constants.APPLY_STATE_YZX + "' and c.apply_State <> '" + Constants.APPLY_STATE_WJWSHBTG + "' ");
			sb.append("and c.apply_State <> '" + Constants.APPLY_STATE_YHSHBTG  + "' and c.apply_state <> '" + Constants.APPLY_STATE_YTK + "' ");
			if(Tools.processNull(this.isBatchHf).equals(Constants.YES_NO_YES)){
				sb.append("and c.card_type = '" + Constants.CARD_TYPE_SMZK + "'");
			}
			sb.append(")) ");
			if(Tools.processNull(this.isBatchHf).equals(Constants.YES_NO_YES)){
				sb.append("and exists (select 1 from card_baseinfo p where p.customer_id = t.customer_id and p.card_state < '9' and p.card_type = '" + Constants.CARD_TYPE_QGN + "') ");
			}
			if(Tools.processNull(this.applyWay).equals(Constants.APPLY_WAY_SQ)){
				if(!Tools.processNull(this.regionId).equals("")){
					sb.append("and t.region_id = '" + this.regionId + "' ");
				}
				if(!Tools.processNull(this.townId).equals("")){
					sb.append("and t.town_Id = '" + this.townId + "' ");
				}
				if(!Tools.processNull(this.commId).equals("")){
					sb.append("and t.comm_id = '" + this.commId + "' ");
				}
				if(!Tools.processNull(this.groupId).equals("")){
					sb.append("and t.group_id = '" + this.groupId + "' ");
				}
			}else if(Tools.processNull(this.applyWay).equals(Constants.APPLY_WAY_DW)){
				sb.append("and t.corp_customer_id = '" + this.companyNo + "' ");
			}
			if(Tools.processNull(this.isPhoto).equals("0")){
				sb.append(" and exists (select 1 from base_photo p where p.customer_id = t.customer_id and p.photo_state = '0' and lengthb(p.photo) > 0) ");
			}
			if(!Tools.processNull(this.beginTime).equals("")){
				sb.append(" and substr(t.cert_no,7,8) >= '" + this.beginTime.replaceAll("-","") + "'");
			}
			if(!Tools.processNull(this.endTime).equals("")){
				sb.append(" and substr(t.cert_no,7,8) <= '" + this.endTime.replaceAll("-","") + "'");
			}
			if(Tools.processNull(sort).equals("")){
				sb.append(" order by t.name asc");
			}else{
				sb.append(" order by " + sort + " " + order);
			}
			Page list = baseService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据选择条件未找到符合条件的人员信息,人员状态信息不正确或已经申领不能重复再次申领，请仔细核对后重新进行申领！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String viewPersonDetail2() {
		try {
			initDataGrid();
			String params = URLDecoder.decode(this.selectedId,"UTF-8");
			parseInParams(params);
			String sql = "select psn.customer_id, psn.name, psn.cert_no, psn.birthday, "
					+ "(select code_name from sys_code where code_type = 'SEX' and code_value = psn.gender) gender, "
					+ "(select code_name from sys_code where code_type = 'NATION' and code_value = psn.nation) nation, "
					+ "(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = psn.cert_type) certtype, "
					+ "t.region_name, t2.town_name, t3.comm_name, t4.group_name, psn.mobile_no, t5.corp_name, "
					+ "decode(psn.customer_state, 0, decode('" + isJudgeSbState + "', '0', nvl2(x.customer_id, decode('" + isPhoto + "', '0', nvl2(pho.customer_id, '1', '4'), '1'), '3'), decode('" + isPhoto + "', '0', nvl2(pho.customer_id, '1', '4'), '1')), '2') SURE_FLAG "
					+ "from base_personal psn left join base_region t on psn.region_id = t.region_id "
					+ "left join base_town t2 on psn.town_id = t2.town_id "
					+ "left join base_comm t3 on psn.comm_id = t3.comm_id "
					+ "left join base_group t4 on psn.group_id = t4.group_id "
					+ "left join base_corp t5 on t5.customer_id = psn.corp_customer_id "
					+ "left join base_siinfo x on psn.customer_id = x.customer_id ";
			if (Tools.processNull(isJudgeSbState).equals(Constants.YES_NO_YES)) {
				sql += "and x.med_state = '0' and psn.name = x.name and psn.cert_no = x.cert_no ";
			}
			sql += "left join base_photo pho on psn.customer_id = pho.customer_id ";
			if (Tools.processNull(isPhoto).equals(Constants.YES_NO_YES)) {
				sql += "and pho.photo_state = '0' ";
			}
			sql += "where not exists (select 1 from card_apply where customer_id = psn.customer_id and apply_state < '90' and apply_state not in ('12', '15', '70'))";
			if (Tools.processNull(applyWay).equals(Constants.APPLY_WAY_SQ)) {
				if (!Tools.processNull(regionId).equals("")) {
					sql += "and psn.region_id = '" + regionId + "' ";
				}
				if (!Tools.processNull(townId).equals("")) {
					sql += "and psn.town_id = '" + townId + "' ";
				}
				if (!Tools.processNull(commId).equals("")) {
					sql += "and psn.comm_id = '" + commId + "' ";
				}
				if (!Tools.processNull(groupId).equals("")) {
					sql += "and psn.group_id = '" + groupId + "' ";
				}
			} else if (Tools.processNull(applyWay).equals(Constants.APPLY_WAY_DW)) {
				if (!Tools.processNull(companyNo).equals("")) {
					sql += "and t5.customer_id = '" + companyNo + "' ";
				}
			}
			if (!Tools.processNull(bp.getName()).equals("")) {
				sql += "and psn.name = '" + bp.getName() + "' ";
			}
			if (!Tools.processNull(bp.getCertNo()).equals("")) {
				sql += "and psn.cert_no = '" + bp.getCertNo() + "' ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			} else {
				sql += "order by sure_flag ";
			}
			//
			Page list = cardApplyService.pagingQuery(sql, page, rows);
			if (list.getAllRs() == null || list.getAllRs().isEmpty()) {
				throw new CommonException("根据查询条件未查询到符合条件的信息！");
			}
			jsonObject.put("rows", list.getAllRs());
			jsonObject.put("total", list.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportNoAppPerson() {
		try {
			rows = 65500;
			viewPersonDetail2();
			JSONArray data = (JSONArray) jsonObject.get("rows");
			
			//
			String fileName = "";
			JSONObject r = data.getJSONObject(0);
			String expDate = DateUtils.getNowTime();
			if (Tools.processNull(applyWay).equals(Constants.APPLY_WAY_SQ)) {
				fileName += r.getString("REGION_NAME") + r.getString("TOWN_NAME") + r.getString("COMM_NAME");
				if (!Tools.processNull(groupId).equals("")) {
					fileName += r.getString("GROUP_NAME");
				}
			} else if (Tools.processNull(applyWay).equals(Constants.APPLY_WAY_DW)) {
				fileName += r.getString("CORP_NAME");
			}
			fileName += "_批量申领未制卡人员（" + expDate + "）";
			//
			response.setContentType("application/ms-excel;charset=utf-8");
			String userAgent = request.getHeader("user-agent");
			if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
				response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
			} else {
				response.setHeader("Content-disposition", "attachment; filename=" + new String((fileName).getBytes(), "iso8859-1") + ".xls");
			}

			// workbook
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);

			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 6000);
			sheet.setColumnWidth(4, 5000);
			sheet.setColumnWidth(5, 2000);
			sheet.setColumnWidth(6, 3000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 5000);
			sheet.setColumnWidth(9, 5000);
			sheet.setColumnWidth(10, 4000);
			sheet.setColumnWidth(11, 8000);
			sheet.setColumnWidth(12, 8000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

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
			int maxColumn = 13;
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
			String string = "导出时间：" + expDate;
			sheet.getRow(1).getCell(0).setCellValue(string);

			// third header
			sheet.getRow(2).getCell(0).setCellValue("客户编号");
			sheet.getRow(2).getCell(1).setCellValue("姓名");
			sheet.getRow(2).getCell(2).setCellValue("证件类型");
			sheet.getRow(2).getCell(3).setCellValue("证件号码");
			sheet.getRow(2).getCell(4).setCellValue("生日");
			sheet.getRow(2).getCell(5).setCellValue("性别");
			sheet.getRow(2).getCell(6).setCellValue("民族");
			sheet.getRow(2).getCell(7).setCellValue("区域");
			sheet.getRow(2).getCell(8).setCellValue("乡镇（街道）");
			sheet.getRow(2).getCell(9).setCellValue("社区（村）");
			sheet.getRow(2).getCell(10).setCellValue("联系电话");
			sheet.getRow(2).getCell(11).setCellValue("单位");
			sheet.getRow(2).getCell(12).setCellValue("备注");

			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(4, headRows);
			
			// data
			int noAppNum = 0; // 未申领
			int canAppNum = 0; // 可申领
			int abNormalNum = 0; // 状态不正常
			int noSiinfoNum = 0; // 无参保
			int noPhotoNum = 0; // 无照片
			for (int i = 0; i < data.size(); i++, noAppNum++) {
				// cell
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(cellStyle);
				}
				// data
				JSONObject item = data.getJSONObject(i);
				row.getCell(0).setCellValue(item.getString("CUSTOMER_ID"));
				row.getCell(1).setCellValue(item.getString("NAME"));
				row.getCell(2).setCellValue(item.getString("CERTTYPE"));
				row.getCell(3).setCellValue(item.getString("CERT_NO"));
				row.getCell(4).setCellValue(item.getString("BIRTHDAY"));
				row.getCell(5).setCellValue(item.getString("GENDER"));
				row.getCell(6).setCellValue(item.getString("NATION"));
				row.getCell(7).setCellValue(item.getString("REGION_NAME"));
				row.getCell(8).setCellValue(item.getString("TOWN_NAME"));
				row.getCell(9).setCellValue(item.getString("COMM_NAME"));
				row.getCell(10).setCellValue(item.getString("MOBILE_NO"));
				row.getCell(11).setCellValue(item.getString("CORP_NAME"));
				String flag = item.getString("SURE_FLAG");
				if (flag.equals("1")) {
					flag = "可申领";
					canAppNum++;
				} else if (flag.equals("2")) {
					flag = "人员状态不正常";
					abNormalNum++;
				} else if (flag.equals("3")) {
					flag = "参保信息不存在或参保状态不正常";
					noSiinfoNum++;
				} else if (flag.equals("4")) {
					flag = "照片不存在或照片状态不正常";
					noPhotoNum++;
				}
				row.getCell(12).setCellValue(flag);
			}

			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				cell.setCellStyle(cellStyle);
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(1).setCellValue("共 " + noAppNum + " 人未制卡， 其中 " + canAppNum + " 人可制卡， " + abNormalNum + " 人【人员状态不正常】， " + noSiinfoNum + " 人【参保信息不存在或参保状态不正常】， " + noPhotoNum + " 人【照片不存在或照片状态不正常】");
			sheet.addMergedRegion(new CellRangeAddress(data.size() + headRows, data.size() + headRows, 1, maxColumn - 1));
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportNoAppPerson",Constants.YES_NO_YES);
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String batchApplySnapBatch() {
		try {
			initDataGrid();
			String sql = "select t.batch_no, count(1) corp_num, sum(t.no_app_num) no_app_num, sum(t.can_app_num) can_app_num, "
					+ "sum(t.app_num) app_num, max(t2.full_name) app_brch, max(t3.user_id) app_user "
					+ "from batch_apply_snap t left join sys_branch t2 on t.app_brch_id = t2.brch_id "
					+ "left join sys_users t3 on t.app_user_id = t3.user_id where t.is_batch_hf <> '0' ";
			if(!Tools.processNull(beginTime).equals("")){
				sql += "and t.apply_date >= to_date('" + beginTime + "', 'yyyy-mm-dd') ";
			}
			if(!Tools.processNull(endTime).equals("")){
				sql += "and t.apply_date <= to_date('" + endTime + " 23:59:50', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			sql += "group by t.batch_no ";
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			} else {
				sql += "order by t.batch_no desc";
			}
			Page list = cardApplyService.pagingQuery(sql, page, rows);
			if (list.getAllRs() == null || list.getAllRs().isEmpty()) {
				throw new CommonException("根据查询条件未查询到符合条件的信息！");
			}
			jsonObject.put("rows", list.getAllRs());
			jsonObject.put("total", list.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String batchHFSnapBatch() {
		try {
			initDataGrid();
			String sql = "select t.batch_no, count(1) corp_num, sum(t.no_app_num) no_app_num, sum(t.can_app_num) can_app_num, "
					+ "sum(t.app_num) app_num, max(t2.full_name) app_brch, max(t3.user_id) app_user "
					+ "from batch_apply_snap t left join sys_branch t2 on t.app_brch_id = t2.brch_id "
					+ "left join sys_users t3 on t.app_user_id = t3.user_id where t.is_batch_hf = '0' ";
			if(!Tools.processNull(beginTime).equals("")){
				sql += "and t.apply_date >= to_date('" + beginTime + "', 'yyyy-mm-dd') ";
			}
			if(!Tools.processNull(endTime).equals("")){
				sql += "and t.apply_date <= to_date('" + endTime + " 23:59:50', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			sql += "group by t.batch_no ";
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			} else {
				sql += "order by t.batch_no desc";
			}
			Page list = cardApplyService.pagingQuery(sql, page, rows);
			if (list.getAllRs() == null || list.getAllRs().isEmpty()) {
				throw new CommonException("根据查询条件未查询到符合条件的信息！");
			}
			jsonObject.put("rows", list.getAllRs());
			jsonObject.put("total", list.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String batchApplySnapSearch() {
		try {
			initDataGrid();
			String sql = "select t.*, t2.corp_name, t3.full_name apply_brch, t4.name apply_user,"
					+ "to_char(t.apply_date, 'yyyy-mm-dd hh24:mi:ss') applydate "
					+ "from batch_apply_snap t left join base_corp t2 on t.corp_id = t2.customer_id "
					+ "left join sys_branch t3 on t.app_brch_id = t3.brch_id "
					+ "left join sys_users t4 on t.app_user_id = t4.user_id "
					+ "where 1 = 1 ";
			if(!Tools.processNull(selectedId).equals("")){
				sql += "and t.batch_no = '" + selectedId + "' ";
			}
			if(!Tools.processNull(companyNo).equals("")){
				sql += "and t.corp_id = '" + companyNo + "' ";
			}
			if(!Tools.processNull(beginTime).equals("")){
				sql += "and t.apply_date >= to_date('" + beginTime + "', 'yyyy-mm-dd') ";
			}
			if(!Tools.processNull(endTime).equals("")){
				sql += "and t.apply_date <= to_date('" + endTime + " 23:59:50', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			} else {
				sql += "order by t.apply_date desc";
			}
			Page list = cardApplyService.pagingQuery(sql, page, rows);
			if (list.getAllRs() == null || list.getAllRs().isEmpty()) {
				throw new CommonException("根据查询条件未查询到符合条件的信息！");
			}
			jsonObject.put("rows", list.getAllRs());
			jsonObject.put("total", list.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String viewAppSnapDetail() {
		try {
			initDataGrid();
			String sql = "select t.customer_id, t.name, t.cert_type, t.cert_no, t2.apply_way, "
					+ "to_char(t2.apply_date, 'yyyy-mm-dd hh24:mi:ss') apply_date, t3.apply_state, "
					+ "(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = t.cert_type) certtype, "
					+ "t4.corp_name, t5.region_name, t6.town_name, t7.comm_name, t.sure_flag, "
					+ "(select code_name from sys_code where code_type = 'APPLY_STATE' and code_value = t3.apply_state) applystate "
					+ "from batch_apply_snap_detail t join batch_apply_snap t2 on t.deal_no = t2.deal_no "
					+ "left join card_apply t3 on t2.task_id = t3.task_id and t.customer_id = t3.customer_id "
					+ "left join base_corp t4 on t2.corp_id = t4.customer_id and t2.corp_id is not null "
					+ "left join base_region t5 on t2.region_id = t5.region_id and t2.region_id is not null "
					+ "left join base_town t6 on t2.town_id = t6.town_id and t2.town_id is not null "
					+ "left join base_comm t7 on t2.comm_id = t7.comm_id and t2.comm_id is not null "
					+ "where 1 = 1 ";
			if(!Tools.processNull(batchNo).equals("")){
				sql += "and t2.batch_no = '" + batchNo + "' ";
			}
			if(!Tools.processNull(rec.getDealNo()).equals("")){
				sql += "and t.deal_no = '" + rec.getDealNo() + "' ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			} else {
				sql += "order by t.sure_flag ";
			}
			Page list = cardApplyService.pagingQuery(sql, page, rows);
			if (list.getAllRs() == null || list.getAllRs().isEmpty()) {
				throw new CommonException("根据查询条件未查询到符合条件的信息！");
			}
			jsonObject.put("rows", list.getAllRs());
			jsonObject.put("total", list.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportAppSnapDetail() {
		try {
			viewAppSnapDetail();
			JSONArray data = (JSONArray) jsonObject.get("rows");
			
			//
			String fileName = "";
			JSONObject r = data.getJSONObject(0);
			if(r == null){
				throw new Exception("没有记录！");
			}
			if (rec.getDealNo() != null) {
				if (Constants.APPLY_WAY_DW.equals(r.getString("APPLY_WAY"))) {
					fileName += r.getString("CORP_NAME");
				} else if (r != null && Constants.APPLY_WAY_SQ.equals(r.getString("APPLY_WAY"))) {
					fileName += r.getString("REGION_NAME") + r.getString("TOWN_NAME") + r.getString("COMM_NAME");
					if (!Tools.processNull(groupId).equals("")) {
						fileName += r.getString("GROUP_NAME");
					}
				}
				fileName += "_";
			} else if (!Tools.processNull(batchNo).equals("")) {
				fileName += batchNo + "_";
			}
			fileName += "批量申领记录";
			//
			response.setContentType("application/ms-excel;charset=utf-8");
			String userAgent = request.getHeader("user-agent");
			if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
				response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
			} else {
				response.setHeader("Content-disposition", "attachment; filename=" + new String((fileName).getBytes(), "iso8859-1") + ".xls");
			}

			// workbook
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);

			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 6000);
			sheet.setColumnWidth(4, 8000);
			sheet.setColumnWidth(5, 8000);
			sheet.setColumnWidth(6, 8000);
			sheet.setColumnWidth(7, 8000);
			sheet.setColumnWidth(8, 5000);
			sheet.setColumnWidth(9, 5000);
			sheet.setColumnWidth(10, 4000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

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
			int maxColumn = 11;
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
			String string = "";
			String applyDate = r.getString("APPLY_DATE");
			if(!Tools.processNull(applyDate).equals("")){
				string += "申领时间：" + applyDate + "    ";
			}
			string += "导出时间：" + DateUtil.formatDate(new Date());
			sheet.getRow(1).getCell(0).setCellValue(string);

			// third header
			sheet.getRow(2).getCell(0).setCellValue("客户编号");
			sheet.getRow(2).getCell(1).setCellValue("姓名");
			sheet.getRow(2).getCell(2).setCellValue("证件类型");
			sheet.getRow(2).getCell(3).setCellValue("证件号码");
			sheet.getRow(2).getCell(4).setCellValue("单位");
			sheet.getRow(2).getCell(5).setCellValue("区域");
			sheet.getRow(2).getCell(6).setCellValue("乡镇（街道）");
			sheet.getRow(2).getCell(7).setCellValue("社区（村）");
			sheet.getRow(2).getCell(8).setCellValue("联系电话");
			sheet.getRow(2).getCell(9).setCellValue("备注");
			sheet.getRow(2).getCell(10).setCellValue("申领状态");

			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(4, headRows);
			
			// data
			int noAppNum = 0; // 未申领
			int canAppNum = 0; // 可申领
			int abNormalNum = 0; // 状态不正常
			int noSiinfoNum = 0; // 无参保
			int noPhotoNum = 0; // 无照片
			int appNum = 0; // 已申领
			for (int i = 0; i < data.size(); i++, noAppNum++) {
				// cell
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(cellStyle);
				}
				// data
				JSONObject item = data.getJSONObject(i);
				row.getCell(0).setCellValue(item.getString("CUSTOMER_ID"));
				row.getCell(1).setCellValue(item.getString("NAME"));
				row.getCell(2).setCellValue(item.getString("CERTTYPE"));
				row.getCell(3).setCellValue(item.getString("CERT_NO"));
				row.getCell(4).setCellValue(item.getString("CORP_NAME"));
				row.getCell(5).setCellValue(item.getString("REGION_NAME"));
				row.getCell(6).setCellValue(item.getString("TOWN_NAME"));
				row.getCell(7).setCellValue(item.getString("COMM_NAME"));
				row.getCell(8).setCellValue(item.getString("MOBILE_NO"));
				
				String flag = item.getString("SURE_FLAG");
				//
				String applyState = item.getString("APPLY_STATE");
				if(flag.equals("1") && Constants.APPLY_STATE_YSQ.compareTo(applyState) <= 0 && Constants.APPLY_STATE_YZX.compareTo(applyState) >= 0) {
					appNum++;
				}
				row.getCell(10).setCellValue(item.getString("APPLYSTATE"));
				//
				if (flag.equals("1")) {
					flag = "可申领";
					canAppNum++;
				} else if (flag.equals("2")) {
					flag = "人员状态不正常";
					abNormalNum++;
				} else if (flag.equals("3")) {
					flag = "参保信息不存在或参保状态不正常";
					noSiinfoNum++;
				} else if (flag.equals("4")) {
					flag = "照片不存在或照片状态不正常";
					noPhotoNum++;
				} else if (flag.equals("5")) {
					flag = "人员不属于该单位";
					noPhotoNum++;
				} else if (flag.equals("6")) {
					flag = "人员不存在";
					noPhotoNum++;
				} else if (flag.equals("7")) {
					flag = "人员已有金融市民卡";
					noPhotoNum++;
				} else if (flag.equals("8")) {
					flag = "人员没有全功能卡";
					noPhotoNum++;
				}
				row.getCell(9).setCellValue(flag);
			}

			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				cell.setCellStyle(cellStyle);
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(1).setCellValue("共 " + noAppNum + " 人未制卡， 其中 " + canAppNum + " 人可制卡， " + abNormalNum + " 人【人员状态不正常】， " + noSiinfoNum + " 人【参保信息不存在或参保状态不正常】， " + noPhotoNum + " 人【照片不存在或照片状态不正常】， 成功申领 " + appNum + " 张");
			sheet.addMergedRegion(new CellRangeAddress(data.size() + headRows, data.size() + headRows, 1, maxColumn - 1));
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportAppSnapDetail",Constants.YES_NO_YES);
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * 规模申领保存
	 * @return
	 */
	public String saveBatchApply(){
		int sucNum = 0;
		int totNum = 0;
		try{
			List<String> errList = new ArrayList<String>();
			if(Tools.processNull(this.selectedId).equals("")){
				throw new CommonException("请勾选需要进行申领的记录信息！");
			}
			if(Tools.processNull(cardType).equals("")){
				throw new CommonException("请选择申领的卡类型！");
			}
			String[] tempSelectIds = selectedId.split(",");
			totNum = tempSelectIds.length;
			CardConfig config = (CardConfig) baseService.findOnlyRowByHql("from CardConfig where cardType = '" + cardType + "'");
			String batchNo = DateUtil.formatDate(new Date(), "yyyyMMddHHmmss");
			for(int i = 0;i < tempSelectIds.length;i++){
				String[] conts = Tools.processNull(tempSelectIds[i]).split("\\|");
				try {
					String snapDealNo = cardApplyService.saveAppSnap(tempSelectIds[i], batchNo, isBatchHf, null); // 保存申领时的历史状态（包括总数和明细），一共多少人，哪些是不符合申领条件的 以及 哪些是符合的，以备日后查验。
					CardApplyTask tempTask = new CardApplyTask();
					if(Tools.processNull(conts[0]).equals(Constants.APPLY_WAY_SQ)){
						if(Tools.processNull(conts[1]).equals("")){
							throw new CommonException("区域编号不能为空！");
						}
						BaseRegion region = (BaseRegion) cardApplyService.findOnlyRowByHql("from BaseRegion where regionId = '" + conts[1] + "'");
						if(region == null){
							throw new CommonException("根据区域编号" + conts[1] + "找不到区域信息！");
						}
						BaseCity city = null;//(BaseCity) cardApplyService.findOnlyRowByHql("from BaseCity t where t.cityId = '" + region.getCityId() + "'");
						if(city == null){
							city = new BaseCity();
						}
						if(Tools.processNull(conts[2]).equals("")){
							throw new CommonException("乡镇（街道）编号不能为空！");
						}
						BaseTown town = (BaseTown) cardApplyService.findOnlyRowByHql("from BaseTown where townId = '" + conts[2] + "'");
						if(town == null){
							throw new CommonException("根据乡镇（街道）编号" + conts[2] + "找不到乡镇（街道）信息！");
						}
						if(Tools.processNull(conts[3]).equals("")){
							throw new CommonException("村镇（社区）编号不能为空！");
						}
						BaseComm comm = (BaseComm) cardApplyService.findOnlyRowByHql("from BaseComm where commId = '" + conts[3] + "'");
						if(comm == null){
							throw new CommonException("根据村镇（社区）编号" + conts[3] + "找不到村镇（社区）信息！");
						}
						BaseGroup group =  new BaseGroup();
						if(!Tools.processNull(conts[4]).equals("")){
							group = (BaseGroup) cardApplyService.findOnlyRowByHql("from BaseGroup where groupId = '" + conts[4] + "'");
							if(group == null){
								throw new CommonException("根据组编号" + conts[4] + "找不到组信息！");
							}
						}
						String taskName = Tools.processNull(city.getCityName()) + Tools.processNull(region.getRegionName());
						taskName = taskName + Tools.processNull(town.getTownName()) + Tools.processNull(comm.getCommName()) + Tools.processNull(group.getGroupName());
						tempTask.setTaskName(taskName);
						tempTask.setIsPhoto(Tools.processNull(this.isPhoto));
						tempTask.setTaskSrc(Constants.TASK_SRC_GMSL);
						tempTask.setIsUrgent(Tools.processNull(this.makeCardWay));
						tempTask.setCardType(Tools.processNull(cardType));
						tempTask.setTaskWay(Constants.TASK_WAY_SQ);
						tempTask.setIsList("0");
						tempTask.setIsBatchHf(this.isBatchHf);
						tempTask.setIsJudgeSbState(this.isJudgeSbState);
						if(Tools.processNull(this.recvBrchId).equals("")){
							//tempTask.setBrchId(baseService.getUser().getBrchId());
						}else{
							//tempTask.setBrchId(this.recvBrchId);
						}
						StringBuffer sb = new StringBuffer();
						if(!Tools.processNull(conts[1]).equals("")){
							tempTask.setRegionId(Tools.processNull(conts[1]));
							sb.append("and b.region_id = '" + conts[1] + "'");
						}
						if(!Tools.processNull(conts[2]).equals("")){
							tempTask.setTownId(Tools.processNull(conts[2]));
							sb.append("and b.town_id = '" + conts[2] + "'");
						}
						if(!Tools.processNull(conts[3]).equals("")){
							tempTask.setCommId(Tools.processNull(conts[3]));
							sb.append("and b.comm_id = '" + conts[3] + "'");
						}
						if(!Tools.processNull(conts[4]).equals("")){
							tempTask.setGroup_Id(Tools.processNull(conts[4]));
							sb.append("and b.group_id = '" + conts[4] + "'");
						}
						if(!Tools.processNull(this.beginTime).equals("")){
							sb.append("and substr(b.cert_no,7,8) >= '" + this.beginTime.replaceAll("-","") + "'");
						}
						if(!Tools.processNull(this.endTime).equals("")){
							sb.append("and substr(b.cert_no,7,8) <= '" + this.endTime.replaceAll("-","") + "'");
						}
						SysActionLog tempSysLog = (SysActionLog) BeanUtils.cloneBean(baseService.getCurrentActionLog());
						cardApplyService.saveBatchApply(sb,tempTask,config,tempSysLog,baseService.getUser());
					}else if(Tools.processNull(conts[0]).equals(Constants.APPLY_WAY_DW)){
						if(Tools.processNull(conts[1]).equals("")){
							throw new CommonException("单位编号不能为空！");
						}
						BaseCorp corp =  (BaseCorp) baseService.findOnlyRowByHql("from BaseCorp where customerId = '" + Tools.processNull(conts[1]) + "'");
						if(corp == null){
							throw new CommonException("根据单位编号" + conts[1] + "找不到单位信息！");
						}
						if(Tools.processNull(corp.getCorpName()).equals("")){
							throw new CommonException("单位编号为" + conts[1] + "的单位，单位名称为空！");
						}
						if(!Tools.processNull(corp.getCorpState()).equals("0")){
							throw new CommonException("单位编号为" + conts[1] + "的单位，单位状态不正常！");
						}
						if (cardType.equals(Constants.CARD_TYPE_SMZK) && Tools.processNull(corp.getLkBrchId()).equals("")) {
							throw new CommonException("单位编号为" + conts[1] + "的单位，金融市民卡领卡网点未设置！");
						}
						String taskName = corp.getCorpName();
						tempTask.setTaskName(taskName);
						tempTask.setIsPhoto(Tools.processNull(this.isPhoto));
						tempTask.setTaskSrc(Constants.TASK_SRC_GMSL);
						tempTask.setIsUrgent(Tools.processNull(this.makeCardWay));
						tempTask.setCardType(Tools.processNull(cardType));
						tempTask.setTaskWay(Constants.TASK_WAY_DW);
						tempTask.setIsList("0");
						tempTask.setCorpId(conts[1]);
						tempTask.setIsBatchHf(this.isBatchHf);
						tempTask.setIsJudgeSbState(this.isJudgeSbState);
						if(Tools.processNull(this.recvBrchId).equals("")){
							//tempTask.setBrchId(baseService.getUser().getBrchId());
						}else{
							//tempTask.setBrchId(this.recvBrchId);
						}
						StringBuffer sb = new StringBuffer();
						sb.append("and b.corp_customer_id = '" + conts[1] + "' ");
						if(!Tools.processNull(this.beginTime).equals("")){
							sb.append("and substr(b.cert_no,7,8) >= '" + this.beginTime.replaceAll("-","") + "'");
						}
						if(!Tools.processNull(this.endTime).equals("")){
							sb.append("and substr(b.cert_no,7,8) <= '" + this.endTime.replaceAll("-","") + "'");
						}
						SysActionLog tempSysLog = (SysActionLog) BeanUtils.cloneBean(baseService.getCurrentActionLog());
						cardApplyService.saveBatchApply(sb,tempTask,config,tempSysLog,baseService.getUser());
					}else if(Tools.processNull(conts[0]).equals(Constants.APPLY_WAY_XX)){
						
					}else{
						throw new CommonException("申领类型不正确！");
					}
					sucNum++;
					cardApplyService.updateAppSnap(snapDealNo, tempTask); // 更新申领历史状态
				} catch (Exception e) {
					errList.add(e.getMessage());
				}
			}
			jsonObject.put("status", "0");
			jsonObject.put("sucNum", sucNum);
			jsonObject.put("errMsg", "计划生成" + totNum + "个任务，已成功生成" + sucNum + "个任务！");
			jsonObject.put("errList", errList);
		}catch(Exception e){
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}	
	/**
	 * 规模申领单位信息查询
	 * @return
	 */
	public String toFindCorpMsg(){
		try{
			this.initDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			if(Tools.processNull(this.customerId).equals("")){
				return this.JSONOBJ;
			}
			StringBuffer sb =  new StringBuffer();
			sb.append("select customer_id,corp_name,(select code_name from sys_code where code_type = 'CORP_TYPE' and code_value = corp_type) corp_type,");
			sb.append("contact,con_phone,address,city_code from base_corp where 1 = 1 ");
			if(!Tools.processNull(this.customerId).equals("")){
				sb.append("and customer_id in (" + Tools.getConcatStrFromArray(this.customerId.split(","),"'",",") + ")");
			}
			Page list = cardApplyService.pagingQuery(sb.toString(),1,10000);
			if(list.getAllRs() != null && list.getTotalCount() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("status",list.getTotalCount());
			}else{
				jsonObject.put("status","1");
				jsonObject.put("errMsg","未找不到单位信息");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 到达个人申领首页
	 * @return
	 */
	public String toOneCardApplyIndex(){
		try{
			CardConfig cardConfig = (CardConfig)baseService.findOnlyRowByHql("from CardConfig c where c.cardType = '" + Constants.CARD_TYPE_SMZK + "'");
			if(cardConfig == null){
				throw new CommonException(baseService.getCodeNameBySYS_CODE("CARD_TYPE",Constants.CARD_TYPE_SMZK) + "参数信息未设置！");
			}
			costFee = Arith.cardreportsmoneydiv(Tools.processNull(cardConfig.getCostFee()).equals("") ? "0" : "0" + "");
			urgentFee = Arith.cardreportsmoneydiv(Tools.processNull(cardConfig.getUrgentFee()).equals("") ? "0" : cardConfig.getUrgentFee() + "");
			jsonObject.put("costFee",Arith.cardreportsmoneydiv(String.valueOf("0")) );
			jsonObject.put("urgentFee",Arith.cardreportsmoneydiv(String.valueOf(urgentFee)));
		}catch(Exception e){
			this.defaultErrMsg = e.getMessage();
		}
		return "toOneCardApplyIndex";
	}
	/**
    * 个人申领查询
    * @return
    */
	@SuppressWarnings("rawtypes")
	public String queryOneCardApply(){
		try{
			this.initDataGrid();
			jsonObject.put("person",new BasePersonal());
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			if(Tools.processNull(baseService.getSysConfigurationParameters("IS_JUDGE_SB")).equals("01")){
				baseService.judgeRegion(certNo);
			}
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT T.APPLY_ID IDS,T.CUSTOMER_ID,B.NAME,B.CERT_NO,T.TASK_ID,T.BUY_PLAN_ID,T.APPLY_ID,(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'APPLY_STATE' AND CODE_VALUE = T.APPLY_STATE) APPLYSTATE,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'APPLY_WAY' AND CODE_VALUE = T.APPLY_WAY) APPLYWAY,TO_CHAR(T.APPLY_DATE,'YYYY-MM-DD HH24:MI:SS') APPLYDATE,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CARD_TYPE' AND CODE_VALUE = T.CARD_TYPE) CARDTYPE,T.CARD_NO, (SELECT FULL_NAME FROM SYS_BRANCH WHERE BRCH_ID = T.RECV_BRCH_ID) LK_BRCH_NAME, ");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CERT_TYPE' AND CODE_VALUE = b.cert_type) CERTTYPE,W.TOWN_NAME,N.COMM_NAME,R.REGION_NAME,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CERT_TYPE' AND CODE_VALUE = T.AGT_CERT_TYPE) AGT_CERT_TYPE, T.AGT_CERT_NO, T.AGT_NAME, T.AGT_PHONE,");
			sb.append("DECODE(T.IS_URGENT,'0','本地制卡','1','外包制卡','其他') IS_URGENT,(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'APPLY_TYPE' AND CODE_VALUE = T.APPLY_TYPE) APPLYTYPE,");
			sb.append("(CASE WHEN T.APPLY_WAY = '1' THEN (SELECT A.CORP_NAME FROM BASE_CORP A WHERE A.CUSTOMER_ID = T.CORP_ID) ELSE '' END)  CORPNAME, ");
			sb.append("(SELECT FULL_NAME FROM SYS_BRANCH WHERE BRCH_ID = T.APPLY_BRCH_ID) BRCH_NAME, T.APPLY_USER_ID, T.APPLY_DATE,T.BANK_ID,F.BANK_NAME,T.BANK_CHECKREFUSE_REASON, T.IS_JUDGE_SB_STATE ");
			sb.append("FROM CARD_APPLY T,BASE_PERSONAL B,BASE_TOWN W,BASE_COMM N,BASE_REGION R,BASE_BANK F WHERE T.CUSTOMER_ID = B.CUSTOMER_ID AND T.TOWN_ID = W.TOWN_ID(+) AND T.COMM_ID = N.COMM_ID(+) AND W.REGION_ID = R.REGION_ID(+) AND T.BANK_ID = F.BANK_ID(+) ");
			if(!Tools.processNull(customerName).equals("")){
				sb.append("AND B.NAME LIKE '%" + customerName + "%' ");
			}
			if(!Tools.processNull(certNo).equals("")){
				Object tempcusid = baseService.findOnlyFieldBySql("select t.customer_id from base_personal t where t.cert_no = '" + this.certNo + "'");
				sb.append(" AND B.CERT_NO = '" + certNo + "' ");
				if(!Tools.processNull(tempcusid).equals("")){
					sb.append("and t.customer_id = '" + tempcusid.toString() + "' ");
				}
			}
			if(!Tools.processNull(beginTime).equals("")){
				sb.append(" AND TO_CHAR(T.APPLY_DATE,'YYYY-MM-DD') >= '" + beginTime + "' ");
			}
			if(!Tools.processNull(endTime).equals("")){
				sb.append(" AND TO_CHAR(T.APPLY_DATE,'YYYY-MM-DD') <= '" + endTime + "' ");
			}
			if(Tools.processNull(sort).equals("")){
				sb.append("ORDER BY T.APPLY_ID desc ");
			}else{
				sb.append("ORDER BY " + sort + " " + order);
			}
			Page list = cardApplyService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}
			String personHql = "from BasePersonal b where b.certNo = '" + certNo + "'";
			if (!Tools.processNull(customerName).equals("")) {
				personHql += " and name like '%" + customerName + "%'";
			}
			List<?> allPersons = baseService.findByHql(personHql);
			if(allPersons == null || allPersons.size() <= 0){
				throw new CommonException("客户信息不存在，无法进行个人申领，请先进行客户信息录入后再进行申领！");
			}
			if(allPersons.size() > 1){
				throw new CommonException("根据证件号码查询到多条客户信息，客户信息不唯一！");
			}
			BasePersonal person = (BasePersonal) allPersons.get(0);
			if(!Tools.processNull(person.getCorpCustomerId()).equals("")){
				BaseCorp baseCorp = (BaseCorp)baseService.findOnlyRowByHql("from BaseCorp c where c.customerId = '" + Tools.processNull(person.getCorpCustomerId()) + "'");
				if(baseCorp != null){
					person.setCorpName(baseCorp.getCorpName());
					jsonObject.put("corp", baseCorp);
				}
			}
			if(!Tools.processNull(person.getRegionId()).equals("")){
				BaseRegion baseRegion = (BaseRegion)baseService.findOnlyRowByHql("from BaseRegion c where c.regionId = '" + Tools.processNull(person.getRegionId()) + "'");
				if(baseRegion != null){
					person.setRegionName(baseRegion.getRegionName());
				}
			}
			if(!Tools.processNull(person.getTownId()).equals("")){
				BaseTown baseTown = (BaseTown)baseService.findOnlyRowByHql("from BaseTown c where c.townId = '" + Tools.processNull(person.getTownId()) + "'");
				if(baseTown != null){
					person.setTownName(baseTown.getTownName());
				}
			}
			if(!Tools.processNull(person.getCommId()).equals("")){
				BaseComm baseComm = (BaseComm)baseService.findOnlyRowByHql("from BaseComm c where c.commId = '" + Tools.processNull(person.getCommId()) + "'");
				if(baseComm != null){
					person.setCommName(baseComm.getCommName());
				}
			}
			person.setCertTypes(baseService.getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType()));
			BaseSiinfo baseSiinfo = (BaseSiinfo) baseService.findOnlyRowByHql("from BaseSiinfo b where b.customerId = '" + person.getCustomerId() + "'");
			jsonObject.put("gender",person.getGenderName());
			jsonObject.put("resideType",person.getResideTypeName());
			BigDecimal existPhoto = (BigDecimal) cardApplyService.findOnlyFieldBySql("select count(1) from base_photo where customer_id = '" + person.getCustomerId() + "' and lengthb(photo) > 0 and photo_state = '0'");
			isPhoto = existPhoto.toString();
			List li = (List)baseService.findBySql("SELECT 1 FROM CARD_APPLY C,BASE_PERSONAL B WHERE B.CUSTOMER_ID = C.CUSTOMER_ID AND B.CERT_NO = '" + this.certNo + "' and c.customer_id = '" + person.getCustomerId() +  "' AND (C.APPLY_STATE < '" + Constants.APPLY_STATE_YZX + "' AND C.APPLY_STATE <> '" + Constants.APPLY_STATE_WJWSHBTG + "' AND C.APPLY_STATE <> '" + Constants.APPLY_STATE_STSHBTG  + "' AND C.APPLY_STATE <> '" + Constants.APPLY_STATE_YHSHBTG + "' )" );
			if(li != null && li.size() > 0){
				jsonObject.put("applyFlag","0");
			}else{
				jsonObject.put("applyFlag","1");
			}
			jsonObject.put("person",person);
			jsonObject.put("baseSiinfo", baseSiinfo);
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	* 个人申领保存
	* @return
	*/
	public String saveOneCardApply(){
		try{
			jsonObject.put("status","1");
			jsonObject.put("msg","");
			jsonObject.put("dealNo", "");
			apply.setCostFee(Tools.processInt(Arith.cardmoneymun(Tools.processNull(costFee).equals("") ? "0" : costFee)));//工本费
			apply.setUrgentFee(Tools.processInt(Arith.cardmoneymun(Tools.processNull(urgentFee).equals("") ? "0" : urgentFee)));//加急费
			apply.setAgtCertNo(agtCertNo);
			apply.setAgtCertType(agtCertType);
			apply.setAgtName(agtName);
			apply.setAgtPhone(agtTelNo);
			apply.setCustomerId(customerId);
			if(Tools.processNull(apply.getCardType()).equals("")){
				throw new CommonException("请选择申领卡类型！");
			}
			//apply.setCardType(Constants.CARD_TYPE_SMZK); //嘉兴支持两种卡类型 注释掉原先写死的卡类型
			apply.setBankId(bankId);
			bp = (BasePersonal)baseService.findOnlyRowByHql("from BasePersonal b where b.customerId = '" + apply.getCustomerId() + "'");
			if(null == bp){
				throw new CommonException("人员基本信息不存在！");
			}
			if (!Tools.processNull(bp.getCustomerState()).equals(Constants.STATE_ZC)) {
				throw new CommonException("客户信息不是正常状态！");
			}
			if (!Tools.processNull(bp.getSureFlag()).equals(Constants.STATE_ZC)) {
				//throw new CommonException("客户信息未进行确认操作！");
			}
			if(Tools.processNull(baseService.getSysConfigurationParameters("IS_JUDGE_SB")).equals("01")){
				baseService.judgeRegion(bp.getCertNo());
			}
			if(Tools.processNull(baseService.getSysConfigurationParameters("IS_PHOTO")).equals("0")){
				BigDecimal existPhoto = (BigDecimal) cardApplyService.findOnlyFieldBySql("select count(1) from base_photo where customer_id = '" + apply.getCustomerId() + "' and lengthb(photo) > 0 and photo_state = '0'");
				if(existPhoto.intValue() <= 0){
					throw new CommonException("客户照片不存在！");
				}
			}
			rec.setCustomerId(apply.getCustomerId());
			SysActionLog log = (SysActionLog) BeanUtils.cloneBean(baseService.getCurrentActionLog());
			logger.debug("个人申领【" + bp.getCertNo() + "】");
			cardApplyService.saveOneCardApply(log,bp,apply,rec);
			logger.debug("个人申领【" + bp.getCertNo() + "】成功");
			jsonObject.put("msg","个人申领成功！");
			jsonObject.put("status","0");
			jsonObject.put("dealNo",log.getDealNo());
		}catch(Exception e){
			logger.error("个人申领【" + bp.getCertNo() + "】失败，" + e.getMessage());
			jsonObject.put("msg","个人申领保存失败：" + e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	* 个人申领  撤销
	* @return
	*/
	public String saveUndoCardApply(){
		jsonObject.put("status","1");
		jsonObject.put("dealNo", "");
		try{
			SysActionLog actionLog = baseService.getCurrentActionLog();
			Long dealNo = cardApplyService.saveUndoCardApply(actionLog,apply_Id);
			jsonObject.put("msg","撤销成功！");
			jsonObject.put("status","0");
			jsonObject.put("dealNo",dealNo);
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
    /**
    * 个人预览
    * @return
    */
	@SuppressWarnings("rawtypes")
	public String queryUndoOneCardApply(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		try{
			if(this.queryType.equals("0")){//0零星申领1单位规模申领2社区规模申领3学校规模申4网上零星申领5记名卡销售9其他规模申领
				String head="",htj="";
				head = "select y.APPLY_ID as APPLYNO,l.customer_Id,l.NAME,l.CERT_NO,y.APPLY_ID,(select code_name from sys_Code where code_type='APPLY_STATE' and code_value = y.apply_state) apply_state,"
						+ "decode(y.APPLY_WAY,'0','零星申领','1','单位规模申领','2','社区规模申领','3','学校规模申','4','网上零星申领','5','记名卡销售','其他规模申领') APPLY_WAY," +
						"to_char(y.apply_date,'yyyy-mm-dd hh24:mi:ss') apply_date,(select code_name from sys_Code where code_type='CARD_TYPE' and code_value = y.card_type) card_type, y.card_no,"
						+ "decode(y.is_urgent,'0','本地制卡','1','外包制卡','其他') is_urgent,(select code_name from sys_Code where code_type='APPLY_TYPE' and code_value = y.APPLY_TYPE) as APPLY_TYPE,y.APPLY_BRCH_ID,y.APPLY_USER_ID  ";
				htj = " from card_apply y,base_personal l where y.customer_Id=l.customer_Id  and y.apply_state='"+Constants.APPLY_STATE_YSQ+"'";
				
				if(!Tools.processNull(clientName).equals("")){
					htj+=" and l.name like '%"+clientName+"%'";
				}
				if(!Tools.processNull(certNo).equals("")){
					htj+=" and l.cert_No = '"+certNo+"'";
				}
				if(!Tools.processNull(apply_Id).equals("")){
					htj+=" and y.apply_Id = '"+apply_Id+"'";
				}
				if(!Tools.processNull(beginTime).equals("")){
					htj+=" and to_char(y.apply_date,'yyyy-MM-dd') >= '"+beginTime+"'";
				}
				if(!Tools.processNull(endTime).equals("")){
					htj+=" and to_char(y.apply_date,'yyyy-MM-dd') <= '"+endTime+"'";
				}
				if(Tools.processNull(sort).equals("")){
					htj+=" order by y.apply_id ";
				}else{
					htj+="  "+sort+" "+order;
				}
				Page list = cardApplyService.pagingQuery(head+htj.toString(),page,rows);
				if(list.getAllRs() != null){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	
	public String toCardApplyByIdCard(){
		try{
			//获取全功能卡类型参数信息,初始化补卡卡类型下拉框
			List allReason = baseService.findBySql("select code_name,code_value from sys_code where code_type = 'BUS_TYPE' and code_state = '0'");
			String tempstring = "";
			//判断是否有免费换卡的权限
			if(allReason != null && allReason.size() > 0){
				for(int i = 0;i < allReason.size() ;i++){
					Object[] o = (Object[]) allReason.get(i);
					if(o[1].toString().equals("21")){
						if(SecurityUtils.getSubject().isPermitted("busTypeChange")){
							tempstring += "{codeName:'" + o[0].toString() + "',codeValue:'" + o[1].toString() + "'},";
						}
					}else{
						tempstring += "{codeName:'" + o[0].toString() + "',codeValue:'" + o[1].toString() + "'},";
					}
				}
			}
			if(!Tools.processNull(tempstring).equals("")){
				tempstring = tempstring.substring(0,tempstring.length() - 1);
			}
			bustype3=tempstring;
			CardConfig cardConfig = (CardConfig)baseService.findOnlyRowByHql(" from CardConfig c where c.cardType='"+Constants.CARD_TYPE_SMZK+"'");
			if(cardConfig != null){
				Long querycostFee = cardConfig.getCostFee();//工本费
				Long queryurgentFee = cardConfig.getUrgentFee();//加急费
				costFee =Arith.cardreportsmoneydiv(String.valueOf("0"));
				urgentFee =Arith.cardreportsmoneydiv(String.valueOf(queryurgentFee));
			}
		}catch(Exception e){
			logger.error(e);
			this.defaultErrMsg = e.getMessage();
		}
		return "toCardApplyByIdCard";
	}
	
	 /**
	  * 通过身份证申领
	  * @return
	  */
	public String saveIdCardApply(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			Pattern idNumPattern = Pattern.compile("(\\d{17}[0-9a-zA-Z])");  
	        Matcher idNumMatcher = idNumPattern.matcher(bp.getCertNo().toString());  
	       if(idNumMatcher.matches()){  
                   String year = bp.getCertNo().toString().substring(6,10); 
                   String month = bp.getCertNo().toString().substring(10,12); 
                   String day = bp.getCertNo().toString().substring(12,14); 
               	Calendar cal = Calendar.getInstance();
               	int yearNow = cal.get(Calendar.YEAR);
               	int monthNow = cal.get(Calendar.MONTH) + 1;
               	int dayOfMonthNow = cal.get(Calendar.DAY_OF_MONTH);
               	int age = yearNow - Integer.parseInt(year);
               	if (monthNow <= Integer.parseInt(month)) {
               		if (monthNow == Integer.parseInt(month)) {
               			if (dayOfMonthNow < Integer.parseInt(day)) {
               				age--;
               			}
               		} else {
               			age--;
               		}
               	}
               	String busTypeCheck="0";
               	if (age<18){
               		busTypeCheck = "10";
               	}else if (18<age && age<60){
               		busTypeCheck = "01";
               	}else if (59<age && age<70){
               		busTypeCheck = "11";
               	}else if (69<age && age<200){
               		busTypeCheck = "20";
               	}
               	if(!apply.getBusType().toString().equals("21")){
               		if (!busTypeCheck.equals(apply.getBusType().toString())){
               			throw new CommonException("公交类型不正确");
               		}
               	}
           }else{  
               throw  new  CommonException("不是有效身份证");
           }  
			SysActionLog actionLog = baseService.getCurrentActionLog();
//			actionLog.setDealCode(DealCode.BASE_DATA_SJCJ_ADD);
			actionLog.setMessage("人员身份证申领:certNo:"+Tools.processNull(bp.getCertNo()));
			//actionLog.setInOutData("人员身份证申领:certNo:"+Tools.processNull(bp.getCertNo()));
			BasePersonal bp2 =(BasePersonal)baseService.findOnlyRowByHql("from BasePersonal b where b.certNo='"+bp.getCertNo()+"'"); 
			if(bp2 != null){
				BigDecimal bd=(BigDecimal)baseService.findOnlyFieldBySql("select count(1) from BASE_PHOTO p  where p.customer_id = '" + bp2.getCustomerId() +"' and p.photo_state = '0' and lengthb(p.photo) > 0 ");
				if (bd.intValue() > 0){
					throw new CommonException("该人员信息完整，请通过个人申领进行申领");
				}else{
					queryType = "1";
				}
			}else{
				queryType = "0";
			}
			BASE64Decoder decoder = new BASE64Decoder();
			byte[] filebyte = decoder.decodeBuffer(personPhotoContent);
			rec = cardApplyService.saveOneCardByIdCardApply(bp, filebyte, apply, rec, queryType, actionLog);
			jsonObject.put("msg","个人申领成功！");
			jsonObject.put("status","0");
			jsonObject.put("dealNo",rec.getDealNo());
		}catch(Exception e){
			jsonObject.put("msg","个人申领保存失败：" + e.getMessage());
		}
		return this.JSONOBJ;
		
	}
	/**
	 * 导出申领信息Excel表。
	 * @return
	 */
	public String exportCardApply() {
		try {
			if(!Tools.processNull(applyIds).equals("")) {
				String sql = "select b.name, b.cert_no, c.card_no, c.sub_card_no, c.task_id, c.corp_id, c.buy_plan_id,";
				sql += "(select t.corp_name from base_corp t where t.customer_id = c.corp_id) corp_name,";
				sql += "(select s1.code_name from sys_code s1 where s1.code_type = 'APPLY_STATE' and s1.code_value = c.apply_state) apply_state,";
				sql += "(select s2.code_name from sys_code s2 where s2.code_type = 'CARD_TYPE' and s2.code_value = c.card_type) card_type ";
				sql += "from base_personal b, card_apply c where b.customer_id = c.customer_id(+) and c.apply_id in (" + applyIds + ")";
				ResultSet resultSet = baseService.tofindResultSet(sql);
				List<ExportCardApplyModel> dataset = new ArrayList<ExportCardApplyModel>();
				while(resultSet.next()) {
					ExportCardApplyModel exportCardApplyModel = new ExportCardApplyModel();
					exportCardApplyModel.setName(Tools.processNull(resultSet.getString("name")));
					exportCardApplyModel.setCertNo(Tools.processNull(resultSet.getString("cert_no")));
					exportCardApplyModel.setCardNo(Tools.processNull(resultSet.getString("card_no")));
					exportCardApplyModel.setSubCardNo(Tools.processNull(resultSet.getString("sub_card_no")));
					exportCardApplyModel.setApplyState(Tools.processNull(resultSet.getString("apply_state")));
					exportCardApplyModel.setTaskId(Tools.processNull(resultSet.getString("task_id")));
					exportCardApplyModel.setCorpId(Tools.processNull(resultSet.getString("corp_id")));
					exportCardApplyModel.setBuyPlanId(Tools.processNull(resultSet.getString("buy_plan_id")));
					exportCardApplyModel.setCorpName(Tools.processNull(resultSet.getString("corp_name")));
					exportCardApplyModel.setCardType(Tools.processNull(resultSet.getString("card_type")));
					dataset.add(exportCardApplyModel);
				}
				String title = "申领信息表";
				String[] headers = {"客户姓名","证件号","卡号","社会保障卡号","申领状态","任务号","申领单号","批次号","申领单位名称","卡类型"};
				ExportExcel<ExportCardApplyModel> exportExcel = new ExportExcel<ExportCardApplyModel>();
				HttpServletResponse response = ServletActionContext.getResponse();
				response.setContentType("application/ms-excel;charset=utf-8");
			    response.setHeader("Content-disposition", "attachment; filename="+ URLEncoder.encode(title,"UTF8") + ".xls");
				OutputStream out = response.getOutputStream(); 
				exportExcel.exportExcel(title, headers, dataset, out, "yyyy-MM-dd");
				out.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
			logger.error(e);
		}
		return null;
	}
	 /**
	    * 导入预览查询
	    * @return
	    */
		@SuppressWarnings("rawtypes")
	public String findViewApply(){
			jsonObject.put("status","0");
			jsonObject.put("errMsg","");
			jsonObject.put("rows",new JSONArray());
			jsonObject.put("total",0);
			try{
				if(this.queryType.equals("0")){//1其他规模申领
					String head="",htj="";
					head = "select XH,CERT_NO,NAME,MED_WHOLE_NO,EMP_NAME,NOTE,deal_No ";
					htj += " from card_apply_person_temp t where t.oper_id='"+this.getUserId()+"' ";
					if(!Tools.processNull(clientName).equals("")){
						htj+=" and t.name like '%"+clientName+"%'";
					}
					if(!Tools.processNull(certNo).equals("")){
						htj+=" and t.cert_No = '"+certNo+"'";
					}
					if(Tools.processNull(sort).equals("")){
						htj+=" order by t.SEQ_ID ";
					}else{
						htj+="  "+sort+" "+order;
					}
					Page list = cardApplyService.pagingQuery(head+htj.toString(),page,rows);
					if(list.getAllRs() != null){
						jsonObject.put("rows",list.getAllRs());
						jsonObject.put("total",list.getTotalCount());
					}
					String dealno=(String)cardApplyService.findOnlyFieldBySql("select deal_no  from card_apply_person_temp t where t.oper_id='"+this.getUserId()+"' and rownum=1 ");
					jsonObject.put("applyIds", dealno);
				}
			}catch(Exception e){
				jsonObject.put("status","1");
				jsonObject.put("msg",e.getMessage());
			}
			return this.JSONOBJ;
		}
	/**
	 * 导出申领信息Excel表。
	 * @return
	 */
	public String exportImpViewApply() {
		OutputStream out=null;
		try {
			if(!Tools.processNull(applyIds).equals("")) {
				String sql = "select XH,CERT_NO,NAME,MED_WHOLE_NO,EMP_NAME,NOTE ";
				sql += " from card_apply_person_temp t where  t.deal_No="+applyIds;
				ResultSet resultSet = baseService.tofindResultSet(sql);
				List<ExportCardApplyModel> dataset = new ArrayList<ExportCardApplyModel>();
				while(resultSet.next()) {
					ExportCardApplyModel exportCardApplyModel = new ExportCardApplyModel();
					exportCardApplyModel.setName(Tools.processNull(resultSet.getString("XH")));
					exportCardApplyModel.setCertNo(Tools.processNull(resultSet.getString("CERT_NO")));
					exportCardApplyModel.setName(Tools.processNull(resultSet.getString("NAME")));
					exportCardApplyModel.setCardNo(Tools.processNull(resultSet.getString("MED_WHOLE_NO")));
					exportCardApplyModel.setTaskId(Tools.processNull(resultSet.getString("EMP_NAME")));
					exportCardApplyModel.setCorpId(Tools.processNull(resultSet.getString("NOTE")));
					dataset.add(exportCardApplyModel);
				}
				String title = "申领预览信息表";
				String[] headers = {"序列号","证件号","客户姓名","统筹区编码","组织任务名称","检验"};
				ExportExcel<ExportCardApplyModel> exportExcel = new ExportExcel<ExportCardApplyModel>();
				HttpServletResponse response = ServletActionContext.getResponse();
				response.setContentType("application/ms-excel;charset=utf-8");
			    response.setHeader("Content-disposition", "attachment; filename="+ URLEncoder.encode(title,"UTF8") + ".xls");
				out = response.getOutputStream(); 
				exportExcel.exportExcel(title, headers, dataset, out, "yyyy-MM-dd");
			}
		} catch (Exception e) {
			e.printStackTrace();
			logger.error(e);
		}finally{
			try{
				out.close();
			}catch(IOException oe){
				logger.error(oe.getMessage());
			}
		}
		return null;
	}
	/**
	 * 导入申领预览--保存到临时表
	 * @return
	 */
	public String toBatchViewSave(){
		jsonObject.put("status",0);
		jsonObject.put("errMsg","");
		jsonObject.put("title", "系统消息");
		try {
			SysActionLog actionLog = cardApplyService.getCurrentActionLog();
			actionLog.setDealCode(DealCode.APPLY_TYPE_IMPORT);
			actionLog.setUserId(this.getUserId());
			actionLog.setBrchId(this.getBranchId());
			actionLog.setMessage("EXECL批量导入");
			if (this.file != null) {
				File files = this.getFile()[0];
				TrServRec rec=cardApplyService.saveImpApplyView(files, fileFileName[0],actionLog);
				jsonObject.put("errMsg","共计有"+rec.getCardTrCount()+"条，导入成功！");
			}
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg","EXECL批量导入发生错误："+e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 * 导入申领保存
	 * @return
	 */
	public String saveImpApply(){
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		jsonObject.put("title", "系统消息");
		try {
			Object[] obj=null;
			java.math.BigDecimal cardTrCount=(java.math.BigDecimal)cardApplyService.findOnlyFieldBySql("select count(*) from  card_apply_person_temp t where t.oper_id='"+this.getUserId()+"' and t.note is null ");
			List list=(List)this.cardApplyService.findBySql(" select t.MED_WHOLE_NO,t.emp_name from card_apply_person_temp t where t.oper_id='"+this.getUserId()+"' and note is  null  group by t.MED_WHOLE_NO,t.emp_name ");
			for(int g=0;g<list.size();g++){
				obj=(Object[])list.get(g);
				SysActionLog tempSysLog = (SysActionLog) BeanUtils.cloneBean(baseService.getCurrentActionLog());
				tempSysLog.setDealCode(DealCode.APPLY_TYPE_IMPORT);
				tempSysLog.setUserId(this.getUserId());
				tempSysLog.setBrchId(this.getBranchId());
				tempSysLog.setMessage("确认导入申领");
			    cardApplyService.saveImpApply(applyIds,"100",baseService.getUser(),tempSysLog,obj);
			}
			jsonObject.put("errMsg","共计有"+cardTrCount+"条申领成功");
			
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg","确认导入申领发生错误："+e.getMessage());
		}
		return "jsonObj";
	}

	/**
	 * 输入参数解析
	 * @throws CommonException
	 */
	private void parseInParams(String inParams) throws CommonException{
		if(Tools.processNull(inParams).equals("")){
			throw new CommonException("参数字符串不能为空！");
		}
		String[] searchConts = inParams.split("\\|");
		this.applyWay = searchConts[0];
		if(Tools.processNull(applyWay).equals("2")){
			this.regionId = Tools.processNull(searchConts[1]);
			this.townId = Tools.processNull(searchConts[2]);
			this.commId = Tools.processNull(searchConts[3]);
			this.groupId = Tools.processNull(searchConts[4]);
			this.cardType = Tools.processNull(searchConts[5]);
			this.beginTime = Tools.processNull(searchConts[6]);
			this.endTime = Tools.processNull(searchConts[7]);
			this.isPhoto = Tools.processNull(searchConts[8]);
			this.isJudgeSbState = Tools.processNull(searchConts[9]);
			this.isBatchHf = Tools.processNull(searchConts[10]);
		}else if(Tools.processNull(this.applyWay).equals("1")){
			this.companyNo = Tools.processNull(searchConts[1]);
			this.cardType = Tools.processNull(searchConts[2]);
			this.beginTime = Tools.processNull(searchConts[3]);
			this.endTime = Tools.processNull(searchConts[4]);
			this.isPhoto = Tools.processNull(searchConts[5]);
			this.isJudgeSbState = Tools.processNull(searchConts[6]);
			this.isBatchHf = Tools.processNull(searchConts[7]);
		}else if(Tools.processNull(this.applyWay).equals("3")){
			
		}else{
			throw new CommonException("申领类型不正确！");
		}
	}
	
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

    /**
     * 金融市民卡申领人员数据导入
     * @return
     */
	public String toQueryJrsbkImportData(){
        try{
            this.initBaseDataGrid();
            if(!Tools.processNull(this.queryType).equals("0")){
                return this.JSONOBJ;
            }
            StringBuffer sb = new StringBuffer();
            sb.append("select t.deal_no,to_char(t.insert_date,'yyyy-mm-dd hh24:mi:ss') dealdate,");
            sb.append("t.tot_nums,t.suc_nums,t.new_apply_nums,t.hf_apply_nums,t.err_nums,t.state,t.apply_nums,t.not_apply_nums,");
            sb.append("decode(t.state,'0','初始导入','1','已比对','2','申领过程中','3','已申领','其他') statetype,");
            sb.append("(select a.full_name from sys_branch a where a.brch_id = t.brch_id) fullname,");
            sb.append("(select b.name from sys_users b where b.user_id = t.user_id) username ");
            sb.append("from base_personal_import_batch t where 1 = 1 ");
            if(!Tools.processNull(rec.getDealNo()).equals("")){
                sb.append("and t.deal_no = " + rec.getDealNo() + " ");
            }
            if(!Tools.processNull(rec.getBrchId()).equals("")){
                sb.append("and t.brch_id = '" + rec.getBrchId() + "' ");
            }
            if(!Tools.processNull(rec.getUserId()).equals("")){
                sb.append("and t.user_id = '" + rec.getUserId() + "' ");
            }
            if(!Tools.processNull(rec.getDealState()).equals("")){
                sb.append("and t.state = '" + rec.getDealState() + "' ");
            }
            if(!Tools.processNull(this.beginTime).equals("")){
                sb.append("and t.insert_date >= to_date('" + this.beginTime + " 00:00:00','yyyy-mm-dd hh24:mi:ss') ");
            }
            if(!Tools.processNull(this.endTime).equals("")){
                sb.append("and t.insert_date <= to_date('" + this.endTime + " 23:59:59','yyyy-mm-dd hh24:mi:ss') ");
            }
            if(Tools.processNull(sort).equals("")){
				sb.append("order by t.deal_no desc ");
			}else{
				sb.append("order by " + sort + " " + order);
			}
            Page list = cardApplyService.pagingQuery(sb.toString(),page,rows);
            if(list.getAllRs() != null){
                jsonObject.put("rows",list.getAllRs());
                jsonObject.put("total",list.getTotalCount());
            }else{
				throw new CommonException("根据查询条件未找到导入记录信息！");
			}
        }catch(Exception e){
            this.jsonObject.put("status",1);
            jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }
	/**
	 * 金融市民卡申领导入人员信息预览
	 * @return
	 */
	public String toViewJrsbkImportData(){
		try{
			this.initBaseDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select t.data_id,t.name,t.cert_no,t.region_id,t.task_name,t.deal_state,t.deal_msg,t.apply_type,decode(t.apply_type,'0','新申领','1','换发') applytype,");
			sb.append("decode(t.deal_state,'0','初始导入','2','比对成功','1','比对失败','3','已申领','4','未申领','5','制卡中','6','已制卡','7','已发卡','未知') statetype,");
			sb.append("t.task_id,t.apply_id,t.bank_id,t.recv_brch_id,r.region_name,b.bank_name,s.full_name ");
			sb.append("from base_personal_import t,sys_branch s,base_bank b,base_region r where t.region_id = r.region_id ");
			sb.append("and t.recv_brch_id = s.brch_id(+) and t.bank_id = b.bank_id(+) ");
			if(!Tools.processNull(rec.getDealNo()).equals("")){
                sb.append("and t.deal_no = " + rec.getDealNo() + " ");
            }
			if(!Tools.processNull(bp.getCertNo()).equals("")){
				sb.append("and t.cert_no = '" + bp.getCertNo() + "' ");
			}
			if(!Tools.processNull(bp.getName()).equals("")){
				sb.append("and t.name = '" + bp.getName() + "' ");
			}
			if(!Tools.processNull(apply.getRecvBrchId()).equals("")){
				sb.append("and t.recv_brch_id = '" + apply.getRecvBrchId() + "' ");
			}
			if(!Tools.processNull(apply.getTaskId()).equals("")){
				sb.append("and t.task_id = '" + apply.getTaskId() + "' ");
			}
			if(Tools.processNull(sort).equals("")){
				sb.append("order by t.data_id asc ");
			}else{
				sb.append("order by " + sort + " " + order);
			}
			Page list = cardApplyService.pagingQuery(sb.toString(),page,rows);
            if(list.getAllRs() != null){
                jsonObject.put("rows",list.getAllRs());
                jsonObject.put("total",list.getTotalCount());
                jsonObject.put("totPages_01",list.getTotalPages());
            }else{
				throw new CommonException("根据查询条件未找到相应人员信息！");
			}
		}catch(Exception e){
			this.jsonObject.put("status","1");
			this.jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 金融市民卡申领导入人员数据删除
	 * @return
	 */
	public String saveDeleteJrsbkImportData(){
		try{
            cardApplyService.saveDelJrsbkApplyImportData(rec.getDealNo(),cardApplyService.getUser(),cardApplyService.getCurrentActionLog());
            this.jsonObject.put("status","0");
		}catch(Exception e){
			logger.error(e);
			this.jsonObject.put("status","1");
			this.jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 金融市民卡申领导入人员数据申领
	 * @return
	 */
	public String saveJrsbkImportDataApply(){
		int taskNums = 0;
		int totApplyNums = 0;
		int totNotApplyNums = 0;
		try{
			if(Tools.processNull(this.selectedId).equals("")){
				throw new CommonException("请勾选需要进行申领的记录信息！");
			} else if (onlyAppNewCard && onlyAppHFCard){
				throw new CommonException("不能在仅申领新卡时申领换发卡");
			}
			SysActionLog ctsLog = cardApplyService.getCurrentActionLog();
			SysActionLog tempLog = (SysActionLog) BeanUtils.cloneBean(ctsLog);
			Map<String,String> tempRet = cardApplyService.saveJrsbkApplyImportDataApply(selectedId, cardApplyService.getUser(), tempLog, onlyAppNewCard, onlyAppHFCard);
			totApplyNums = totApplyNums + Integer.valueOf(tempRet.get("totApplyNums"));
			totNotApplyNums = totNotApplyNums + Integer.valueOf(tempRet.get("totNotApplyNums"));
			taskNums = taskNums + Integer.valueOf(tempRet.get("taskNums"));
			this.jsonObject.put("status","0");
		}catch(Exception e){
			logger.error(e);
			this.jsonObject.put("status","1");
			this.jsonObject.put("errMsg",e.getMessage());
			if(taskNums > 0){
				this.jsonObject.put("errMsg","处理流水编号为" + selectedId + "的文件数据过程中出现错误，已生成" + taskNums + "个任务，" + e.getMessage() + "，请继续进行操作！");
			}
		}
		this.jsonObject.put("taskNums",taskNums);
		return this.JSONOBJ;
	}
	/**
	 * 金融市民卡导入申领比对数据导出
	 * @return
	 * String
	 */
	public String saveJrsbkImportDataExport(){
		try{
			queryType = "0";
			this.page = 1;
			this.rows = 10000;
			this.toViewJrsbkImportData();
			if(!Tools.processNull(jsonObject.get("status")).equals("0")){
				throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
			}
			Workbook book = new SXSSFWorkbook(500);
			Sheet sheet = book.createSheet();
			sheet.setFitToPage(true);
			sheet.createFreezePane(1,1);
			CellRangeAddress titleRegion = new CellRangeAddress(0,0,0,8);
			titleRegion.formatAsString();
			sheet.addMergedRegion(titleRegion);
			CellStyle titleStyle = this.getCellStyleOfTitle(book);
			Row firstRow = sheet.createRow(0);
			firstRow.setHeight((short)(firstRow.getHeight() * 2));
			Cell cell = firstRow.createCell(0);
			cell.setCellValue(Constants.APP_REPORT_TITLE + "金融市民卡申领导入数据比对明细");
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
			Row secRow = sheet.createRow(1);
			Cell secCell0 = secRow.createCell(0);
			secCell0.setCellValue("姓名");
			secCell0.setCellStyle(headStyle);
			Cell secCell1 = secRow.createCell(1);
			secCell1.setCellValue("证件号码");
			secCell1.setCellStyle(headStyle);
			Cell secCell2 = secRow.createCell(2);
			secCell2.setCellValue("统筹区编码");
			secCell2.setCellStyle(headStyle);
			Cell secCell3 = secRow.createCell(3);
			secCell3.setCellValue("任务名称");
			secCell3.setCellStyle(headStyle);
			Cell secCell4 = secRow.createCell(4);
			secCell4.setCellValue("银行编码");
			secCell4.setCellStyle(headStyle);
			Cell secCell5 = secRow.createCell(5);
			secCell5.setCellValue("领卡网点编码");
			secCell5.setCellStyle(headStyle);
			Cell secCell6 = secRow.createCell(6);
			secCell6.setCellValue("申领类型");
			secCell6.setCellStyle(headStyle);
			Cell secCell7 = secRow.createCell(7);
			secCell7.setCellValue("状态");
			secCell7.setCellStyle(headStyle);
			Cell secCell8 = secRow.createCell(8);
			secCell8.setCellValue("备注");
			secCell8.setCellStyle(headStyle);
			JSONArray rows =  this.jsonObject.getJSONArray("rows");
			int totPages = this.jsonObject.getIntValue("totPages_01");
			int rowNum = 2;
			CellStyle commonStyle = this.getCellStyleOfData(book);
			while(this.page <= totPages){
				if(rows != null && rows.size() > 0){
					for (Object object : rows) {
						JSONObject tempRowData = (JSONObject) object;
						Row tempRow = sheet.createRow(rowNum);
						Cell tempCell0 = tempRow.createCell(0);
						tempCell0.setCellValue(tempRowData.getString("NAME"));
						tempCell0.setCellStyle(commonStyle);
						Cell tempCell1 = tempRow.createCell(1);
						tempCell1.setCellValue(tempRowData.getString("CERT_NO"));
						tempCell1.setCellStyle(commonStyle);
						Cell tempCell2 = tempRow.createCell(2);
						tempCell2.setCellStyle(commonStyle);
						tempCell2.setCellValue(tempRowData.getString("REGION_ID"));
						Cell tempCell3 = tempRow.createCell(3);
						tempCell3.setCellStyle(commonStyle);
						tempCell3.setCellValue(tempRowData.getString("TASK_NAME"));
						Cell tempCell4 = tempRow.createCell(4);
						tempCell4.setCellStyle(commonStyle);
						tempCell4.setCellValue(tempRowData.getString("BANK_ID"));
						Cell tempCell5 = tempRow.createCell(5);
						tempCell5.setCellStyle(commonStyle);
						tempCell5.setCellValue(tempRowData.getString("RECV_BRCH_ID"));
						Cell tempCell6 = tempRow.createCell(6);
						tempCell6.setCellStyle(commonStyle);
						tempCell6.setCellValue(tempRowData.getString("APPLYTYPE"));
						Cell tempCell7 = tempRow.createCell(7);
						tempCell7.setCellStyle(commonStyle);
						tempCell7.setCellValue(tempRowData.getString("STATETYPE"));
						Cell tempCell8 = tempRow.createCell(8);
						tempCell8.setCellStyle(commonStyle);
						tempCell8.setCellValue(tempRowData.getString("DEAL_MSG"));
						rowNum++;
						tempRowData = null;
					}
				}
				this.page += 1;
				if(this.page <= totPages){
					this.toViewJrsbkImportData();
					if(!Tools.processNull(jsonObject.get("status")).equals("0")){
						book = null;
						sheet = null;
						throw new CommonException(Tools.processNull(jsonObject.get("errMsg")));
					}
					rows =  this.jsonObject.getJSONArray("rows");
				}
			}
			sheet.autoSizeColumn(0,true);
			sheet.autoSizeColumn(1,true);
			sheet.autoSizeColumn(2,true);
			sheet.autoSizeColumn(3,true);
			sheet.autoSizeColumn(4,true);
			sheet.autoSizeColumn(5,true);
			sheet.autoSizeColumn(6,true);
			sheet.autoSizeColumn(7,true);
			sheet.autoSizeColumn(8,true);
			OutputStream out = this.response.getOutputStream();
			this.response.setContentType("application/vnd.ms-excel");
			this.response.setCharacterEncoding("UTF-8");
			this.response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode( Constants.APP_REPORT_TITLE + "金融市民卡申领导入数据比对明细" + "）", "UTF-8") + ".xlsx\"");
			book.write(out);
			SecurityUtils.getSubject().getSession().setAttribute("jrsbkdataimportmainexport",Constants.YES_NO_YES);
			out.flush();
		}catch (Exception e) {
			this.defaultErrorMsg = this.saveErrLog(e);
			return "jrsbkdataimportMain";
		}
		return null;
	}
	private void initDataGrid(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
	}
	
	public String yhFailPersonInfo() {
		try {
			initDataGrid();
			String sql = "select t.*, (select bank_name from base_bank where bank_id = t.bank_id) bank_name, "
					+ "(select corp_name from base_corp where customer_id = t2.corp_customer_id) corp_name, "
					+ "(select code_name from sys_code where code_type = 'APPLY_TYPE' and code_value = t.apply_type) applytype, "
					+ "(select code_name from sys_code where code_type = 'APPLY_WAY' and code_value = t.apply_way) applyway, "
					+ "(select full_name from sys_branch where brch_id = t.apply_brch_id) brch_name, "
					+ "(select name from sys_users where user_id = t.apply_user_id) user_name, "
					+ "(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.card_type) cardtype, "
					+ "to_char(t.apply_date, 'yyyy-mm-dd hh24:mi:ss') applydate, t2.cert_no, t2.name, t2.mobile_no "
					+ "from card_apply t join base_personal t2 on t.customer_id = t2.customer_id "
					+ "where t.apply_state = '" + Constants.APPLY_STATE_YHSHBTG + "' ";
			if (!Tools.processNull(selectedId).equals("")) {
				String applyIdSql = "";
				String[] applyIdArr = selectedId.split("\\|");
				for(String applyId:applyIdArr){
					applyIdSql += "'" + applyId + "',";
				}
				applyIdSql = applyIdSql.substring(0, applyIdSql.length() - 1);
				if (!Tools.processNull(applyIdSql).equals("")) {
					sql += "and t.apply_id in (" + applyIdSql + ") ";
				}
			}
			if (!Tools.processNull(apply.getTaskId()).equals("")) {
				sql += "and t.task_id = '" + apply.getTaskId() + "' ";
			}
			if (!Tools.processNull(bp.getCertNo()).equals("")) {
				sql += "and t2.cert_no = '" + bp.getCertNo() + "' ";
			}
			if (!Tools.processNull(bp.getName()).equals("")) {
				sql += "and t2.name = '" + bp.getName() + "' ";
			}
			if (!Tools.processNull(apply.getApplyBrchId()).equals("")) {
				sql += "and t.apply_brch_id = '" + apply.getApplyBrchId() + "' ";
			}
			if (!Tools.processNull(apply.getApplyUserId()).equals("")) {
				sql += "and t.apply_user_id = '" + apply.getApplyUserId() + "' ";
			}
			if (!Tools.processNull(beginTime).equals("")) {
				sql += "and t.apply_date >= to_date('" + beginTime + "', 'yyyy-mm-dd') ";
			}
			if (!Tools.processNull(endTime).equals("")) {
				sql += "and t.apply_date <= to_date('" + endTime + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			if (!Tools.processNull(apply.getCorpId()).equals("")) {
				sql += "and t.corp_id = '" + apply.getCorpId() + "' ";
			}
			if (!Tools.processNull(apply.getBuyPlanId()).equals("")) {
				sql += "and t.buy_plan_id = '" + apply.getBuyPlanId() + "' ";
			}
			if (!Tools.processNull(sort).equals("")) {
				sql += "order by " + sort;
				if (!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			} else {
				sql += "order by t.apply_date, t2.name";
			}

			Page pageData = baseService.pagingQuery(sql, page, rows);
			if (pageData.getAllRs() == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommonException("未查询到记录信息");
			}
			jsonObject.put("rows", pageData.getAllRs());
			jsonObject.put("total", pageData.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportYhFailPersonInfo() {
		try {
			yhFailPersonInfo();
			JSONArray data = (JSONArray) jsonObject.get("rows");
			
			//
			String fileName = "银行审核不通过人员";
			response.setContentType("application/ms-excel;charset=utf-8");
			String userAgent = request.getHeader("user-agent");
			if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
				response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
			} else {
				response.setHeader("Content-disposition", "attachment; filename=" + new String((fileName).getBytes("utf-8"), "iso8859-1") + ".xls");
			}

			// workbook
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);

			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 5500);
			sheet.setColumnWidth(2, 2500);
			sheet.setColumnWidth(3, 2500);
			sheet.setColumnWidth(4, 5500);
			sheet.setColumnWidth(5, 6000);
			sheet.setColumnWidth(6, 3000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 6000);
			sheet.setColumnWidth(9, 4000);
			sheet.setColumnWidth(10, 5500);
			sheet.setColumnWidth(11, 3000);
			sheet.setColumnWidth(12, 6000);
			sheet.setColumnWidth(13, 4000);
			sheet.setColumnWidth(14, 4000);
			sheet.setColumnWidth(15, 8000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

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
			int maxColumn = 16;
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
			String string = "";
			if (!Tools.processNull(beginTime).equals("") || !Tools.processNull(endTime).equals("")) {
				string += "申领时间： " + beginTime + " ~ " + endTime;
			}
			string += "    导出时间：" + DateUtils.getNowTime();
			sheet.getRow(1).getCell(0).setCellValue(string);

			// third header
			sheet.getRow(2).getCell(0).setCellValue("申领编号");
			sheet.getRow(2).getCell(1).setCellValue("任务编号");
			sheet.getRow(2).getCell(2).setCellValue("批次号");
			sheet.getRow(2).getCell(3).setCellValue("姓名");
			sheet.getRow(2).getCell(4).setCellValue("证件号码");
			sheet.getRow(2).getCell(5).setCellValue("所属单位");
			sheet.getRow(2).getCell(6).setCellValue("申领方式");
			sheet.getRow(2).getCell(7).setCellValue("申领类型");
			sheet.getRow(2).getCell(8).setCellValue("申领网点");
			sheet.getRow(2).getCell(9).setCellValue("申领柜员");
			sheet.getRow(2).getCell(10).setCellValue("申领时间");
			sheet.getRow(2).getCell(11).setCellValue("卡类型");
			sheet.getRow(2).getCell(12).setCellValue("卡号");
			sheet.getRow(2).getCell(13).setCellValue("银行编号");
			sheet.getRow(2).getCell(14).setCellValue("银行名称");
			sheet.getRow(2).getCell(15).setCellValue("审核失败原因");

			//
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(5, 3);
			int num = 0;
			for (int i = 0; i < data.size(); i++, num++) {
				JSONObject item = data.getJSONObject(i);

				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(cellStyle);
				}

				row.getCell(0).setCellValue(item.getString("APPLY_ID"));
				row.getCell(1).setCellValue(item.getString("TASK_ID"));
				row.getCell(2).setCellValue(item.getString("BUY_PLAN_ID"));
				row.getCell(3).setCellValue(item.getString("NAME"));
				row.getCell(4).setCellValue(item.getString("CERT_NO"));
				row.getCell(5).setCellValue(item.getString("CORP_NAME"));
				row.getCell(6).setCellValue(item.getString("APPLYWAY"));
				row.getCell(7).setCellValue(item.getString("APPLYTYPE"));
				row.getCell(8).setCellValue(item.getString("BRCH_NAME"));
				row.getCell(9).setCellValue(item.getString("USER_NAME"));
				row.getCell(10).setCellValue(item.getString("APPLYDATE"));
				row.getCell(11).setCellValue(item.getString("CARDTYPE"));
				row.getCell(12).setCellValue(item.getString("CARD_NO"));
				row.getCell(13).setCellValue(item.getString("BANK_ID"));
				row.getCell(14).setCellValue(item.getString("BANK_NAME"));
				row.getCell(15).setCellValue(item.getString("BANK_CHECKREFUSE_REASON"));
			}

			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				cell.setCellStyle(cellStyle);
			}
			row.getCell(1).setCellValue("统计：");
			row.getCell(2).setCellValue("共 " + num + " 条记录");
			sheet.addMergedRegion(new CellRangeAddress(data.size() + headRows, data.size() + headRows, 2, maxColumn - 1));
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportYhFailPersonInfo",Constants.YES_NO_YES);
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String saveImportBatchApply() {
		Workbook workbook = null;
		try {
			if (file == null || file.length == 0) {
				throw new CommonException("上传文件为空.");
			}
			//
			workbook = new HSSFWorkbook(new FileInputStream(file[0]));
			Sheet sheet = workbook.getSheetAt(0);
			int lastRowNum = sheet.getLastRowNum();
			Map<String, List<Row>> data = new HashMap<String, List<Row>>();
			for (int i = 1; i <= lastRowNum; i++) {
				Row row = sheet.getRow(i);
				if (row == null) {
					continue;
				}
				Cell corpIdCell = row.getCell(2);
				if (corpIdCell == null) {
					continue;
				}
				String corpId = corpIdCell.getStringCellValue().trim();
				if (corpId == null) {
					continue;
				}
				//
				if (data.containsKey(corpId)) {
					data.get(corpId).add(row);
				} else {
					ArrayList<Row> list = new ArrayList<Row>();
					list.add(row);
					data.put(corpId, list);
				}
			}
			//
			String batchNo = DateUtil.formatDate(new Date(), "yyyyMMddHHmmss");
			List<String> msgList = new ArrayList<String>();
			for (String corpId : data.keySet()) { // 每个单位
				List<String> certNoList = new ArrayList<String>();
				for (Row row : data.get(corpId)) {
					Cell certNoCell = row.getCell(1);
					if (certNoCell == null) {
						continue;
					}
					String certNo = certNoCell.getStringCellValue();
					if (certNo == null) {
						continue;
					}
					certNoList.add(certNo.trim());
					//
					Cell corpIdCell = row.getCell(2);
					if (corpIdCell == null) {
						continue;
					}
				}
				// 生成任务
				try {
					batchApplyByPerson(batchNo, corpId, certNoList);
				} catch (Exception e) {
					msgList.add("单位编号【" + corpId + "】申领失败，" + e.getMessage());
				}
			}
			jsonObject.put("status", "0");
			jsonObject.put("msgList", msgList);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		} finally {
			try {
				workbook.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return this.JSONOBJ;
	}
	
	private void batchApplyByPerson(String batchNo, String corpId, List<String> certNoList){
		try {
			if (Tools.processNull(corpId).equals("")) {
				throw new CommonException("单位编号为空！");
			} else if (certNoList.isEmpty()) {
				throw new CommonException("单位人员信息为空！");
			}
			BaseCorp corp = (BaseCorp) baseService.findOnlyRowByHql("from BaseCorp where customerId = '" + Tools.processNull(corpId) + "'");
			if (corp == null) {
				throw new CommonException("根据单位编号" + corpId + "找不到单位信息！");
			}
			if (Tools.processNull(corp.getCorpName()).equals("")) {
				throw new CommonException("单位编号为" + corpId + "的单位，单位名称为空！");
			}
			if (!Tools.processNull(corp.getCorpState()).equals("0")) {
				throw new CommonException("单位编号为" + corpId + "的单位，单位状态不正常！");
			}
			// 保存历史
			String snapDealNo = cardApplyService.saveAppSnap(Constants.APPLY_WAY_DW + "|" + corpId + "||||" + isPhoto + "|" + isJudgeSbState, batchNo, isBatchHf, certNoList); // 保存申领时的历史状态（包括总数和明细），一共多少人，哪些是不符合申领条件的 以及 哪些是符合的，以备日后查验。
			// 申领
			CardConfig config = (CardConfig) baseService.findOnlyRowByHql("from CardConfig where cardType = '" + cardType + "'");
			CardApplyTask tempTask = new CardApplyTask();
			tempTask.setTaskName(corp.getCorpName());
			tempTask.setIsPhoto(Tools.processNull(this.isPhoto));
			tempTask.setTaskSrc(Constants.TASK_SRC_GMSL);
			tempTask.setIsUrgent(Tools.processNull(this.makeCardWay));
			tempTask.setCardType(Tools.processNull(cardType));
			tempTask.setTaskWay(Constants.TASK_WAY_DW);
			tempTask.setIsList("0");
			tempTask.setCorpId(corpId);
			tempTask.setIsBatchHf(this.isBatchHf);
			tempTask.setIsJudgeSbState(this.isJudgeSbState);
			StringBuffer limitPersons = new StringBuffer();
			limitPersons.append("and b.corp_customer_id = '" + corpId + "' ");
			limitPersons.append("and b.cert_no in (select cert_no from batch_apply_snap_detail where deal_no = '" + snapDealNo + "') ");
			SysActionLog tempSysLog = (SysActionLog) BeanUtils.cloneBean(baseService.getCurrentActionLog());
			cardApplyService.saveBatchApply(limitPersons, tempTask, config, tempSysLog, baseService.getUser());
			// 更新申领历史状态
			cardApplyService.updateAppSnap(snapDealNo, tempTask); 
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	
	public String jrsbkHfPersonInfo() {
		try {
			initDataGrid();
			String sql = "select t.customer_id, t.name, (select town_name from base_town where town_id = t.town_id) town_name, "
					+ "(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = t.cert_type) certtype, "
					+ "t.cert_no, t2.customer_id corp_id, t2.corp_name, (select region_name from base_region where region_id = t.region_id) region_name, "
					+ "(select comm_name from base_comm where comm_id = t.comm_id) comm_name, t.mobile_no "
					+ "from base_personal t join base_corp t2 on t.corp_customer_id = t2.customer_id "
					+ "join card_baseinfo t3 on t.customer_id = t3.customer_id and t3.card_type = '100' and t3.card_state < '9' "
					+ "where customer_state = '0' and length(t.cert_no) = 18 and not exists (select 1 from card_apply where customer_id = t.customer_id and card_type = '120' and apply_state < '90' and apply_state <> '15' ) "
					+ "and not exists (select 1 from card_bind_bankcard where customer_id = t.customer_id and sub_card_no = t3.sub_card_no ) "
					+ "and exists (select 1 from base_photo where customer_id = t.customer_id and photo_state = '0' and lengthb(photo) > 0) ";
			if(!Tools.processNull(companyNo).equals("")){
				sql += "and t.corp_customer_id = '" + companyNo + "' ";
			}
			if (!Tools.processNull(sort).equals("")) {
				sql += "order by " + sort;
				if (!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			} else {
				sql += "order by t.name";
			}

			Page pageData = baseService.pagingQuery(sql, page, rows);
			if (pageData.getAllRs() == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommonException("未查询到记录信息");
			}
			jsonObject.put("rows", pageData.getAllRs());
			jsonObject.put("total", pageData.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String jrsbkHfPersonInfo2() {
		try {
			initDataGrid();
			String sql = "select t.*, (select bank_name from base_bank where bank_id = t2.bank_id) bank_name, t2.bank_card_no, decode(t.customer_state, 0, decode(length(t.cert_no), 18, nvl2(t2.customer_id, 3, 2), 1), 0) note from (select t.customer_id, t.name, (select town_name from base_town where town_id = t.town_id) town_name, "
					+ "(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = t.cert_type) certtype, "
					+ "t.cert_no, t2.customer_id corp_id, t2.corp_name, (select region_name from base_region where region_id = t.region_id) region_name, "
					+ "(select comm_name from base_comm where comm_id = t.comm_id) comm_name, t.mobile_no, t.customer_state, t3.sub_card_no "
					+ "from base_personal t join base_corp t2 on t.corp_customer_id = t2.customer_id "
					+ "join card_baseinfo t3 on t.customer_id = t3.customer_id and t3.card_type = '100' and t3.card_state < '9' "
					+ "where not exists (select 1 from card_apply where customer_id = t.customer_id and card_type = '120' and apply_state < '90' and apply_state <> '15' ) "
					+ "and (t.customer_state <> '0' or length(t.cert_no) <> '18' or exists (select 1 from card_bind_bankcard where t.customer_id = customer_id and sub_card_no = t3.sub_card_no))";
			if(!Tools.processNull(companyNo).equals("")){
				sql += "and t.corp_customer_id = '" + companyNo + "' ";
			}
			sql += ") t left join card_bind_bankcard t2 on t.sub_card_no = t2.sub_card_no and t.customer_id = t2.customer_id ";
			if (!Tools.processNull(sort).equals("")) {
				sql += "order by " + sort;
				if (!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			} else {
				sql += "order by t.name";
			}

			Page pageData = baseService.pagingQuery(sql, page, rows);
			if (pageData.getAllRs() == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommonException("未查询到记录信息");
			}
			jsonObject.put("rows", pageData.getAllRs());
			jsonObject.put("total", pageData.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportJrsbkHfPersonInfo() {
		try {
			rows = 65000;
			jrsbkHfPersonInfo();
			JSONArray data = jsonObject.getJSONArray("rows");
			jrsbkHfPersonInfo2();
			JSONArray data2 = jsonObject.getJSONArray("rows");
			data.addAll(data2);
			//
			String expDate = DateUtils.getNowTime();
			String fileName = "嘉兴金融市民卡批量换发人员信息表";
			//
			response.setContentType("application/ms-excel;charset=utf-8");
			String userAgent = request.getHeader("user-agent");
			if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
				response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
			} else {
				response.setHeader("Content-disposition", "attachment; filename=" + new String((fileName).getBytes(), "iso8859-1") + ".xls");
			}

			// workbook
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);

			sheet.setColumnWidth(0, 1500);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 6000);
			sheet.setColumnWidth(3, 3000);
			sheet.setColumnWidth(4, 8000);
			sheet.setColumnWidth(5, 2000);
			sheet.setColumnWidth(6, 2000);
			sheet.setColumnWidth(7, 6000);
			sheet.setColumnWidth(8, 6000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

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
			int maxColumn = 9;
			int headRows = 4;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			sheet.getRow(0).getCell(0).setCellValue(fileName);

			// second header
			String string = "导出时间：" + expDate;
			sheet.getRow(1).getCell(0).setCellValue(string);

			// third header
			sheet.getRow(2).getCell(0).setCellValue("序号");
			sheet.getRow(2).getCell(1).setCellValue("姓名");
			sheet.getRow(2).getCell(2).setCellValue("证件号码");
			sheet.getRow(2).getCell(3).setCellValue("单位编号");
			sheet.getRow(2).getCell(4).setCellValue("单位名称");
			sheet.getRow(2).getCell(5).setCellValue("是否换发");
			sheet.getRow(2).getCell(7).setCellValue("备注");
			sheet.getRow(2).getCell(8).setCellValue("绑定银行");
			sheet.getRow(3).getCell(5).setCellValue("是");
			sheet.getRow(3).getCell(6).setCellValue("否");

			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 5, 6));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 1, 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 2, 2));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 3, 3));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 4, 4));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 7, 7));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 8, 8));
			sheet.createFreezePane(0, headRows);
			
			// data
			for (int i = 0; i < data.size(); i++) {
				// cell
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(cellStyle);
				}
				// data
				JSONObject item = data.getJSONObject(i);
				row.getCell(0).setCellValue(i + 1);
				row.getCell(1).setCellValue(item.getString("NAME"));
				row.getCell(2).setCellValue(item.getString("CERT_NO"));
				row.getCell(3).setCellValue(item.getString("CORP_ID"));
				row.getCell(4).setCellValue(item.getString("CORP_NAME"));
				String value = item.getString("NOTE");
				if(value == null){
					value = "";
				} else if(value.equals("0")) {
					value = "人员状态不正常";
			 	} else if(value.equals("1")) {
			 		value = "证件类型不是身份证";
			 	} else if(value.equals("2")) {
			 		value = "照片不存在";
			 	} else if(value.equals("3")) {
			 		value = "全功能卡已绑定银行卡";
			 	}
				row.getCell(7).setCellValue(value);
				row.getCell(8).setCellValue(item.getString("BANK_NAME"));
			}

			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportJrsbkHfPersonInfo",Constants.YES_NO_YES);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String printExportJrsbkHfPersonInfo() {
		try {
			rows = 65000;
			jrsbkHfPersonInfo();
			JSONArray data = jsonObject.getJSONArray("rows");
			jrsbkHfPersonInfo2();
			JSONArray data2 = jsonObject.getJSONArray("rows");
			data.addAll(data2);
			String remark = "";
			for (int i = 0; i < data.size() && i < 3; i++) {
				JSONObject r = data.getJSONObject(i);
				remark += r.getString("NAME") + "， ";
			}
			remark = remark.substring(0, remark.length() - 2) + "等";
			//
			BaseCorp corp = (BaseCorp) baseService.findOnlyRowByHql("from BaseCorp where customerId = '" + companyNo + "'");
			Map<String, Object> reportsHashMap = new HashMap<String, Object>();
			reportsHashMap.put("client_Id", Tools.processNull(corp.getCustomerId()));
			reportsHashMap.put("emp_Name", Tools.processNull(corp.getCorpName()));
			reportsHashMap.put("contact", Tools.processNull(corp.getContact()));
			reportsHashMap.put("p_con_cert_no", Tools.processNull(corp.getConCertNo()));
			reportsHashMap.put("num", (Integer)(data == null ? 0 : data.size()));
			reportsHashMap.put("remark", remark);
			SysBranch lkBrch = (SysBranch) baseService.findOnlyRowByHql("from SysBranch where brchId = '" + corp.getLkBrchId() + "'");
			if (lkBrch == null) {
				throw new CommonException("领卡网点为空！");
//				reportsHashMap.put("lkBrchName", "");
			}
			reportsHashMap.put("lkBrchName", lkBrch.getFullName());
			List<String> brchIds = baseService.findBySql("select brch_id from sys_branch start with brch_id = '10000000' connect by prior sysbranch_id =  pid");
			brchIds.add("99999999");
			if(!brchIds.contains(getUsers().getBrchId())){
				String curBankId = (String) baseService.findOnlyFieldBySql("select bank_id from branch_bank where brch_id = '" + getUsers().getBrchId() + "'");
				String lkBankId = (String) baseService.findOnlyFieldBySql("select bank_id from branch_bank where brch_id = '" + lkBrch.getBrchId() + "'");
				if (curBankId == null || !curBankId.equals(lkBankId)) {
					throw new CommonException("单位所属领卡网点银行与当前网点所属银行不一致！");
				}
			}
			String path = ServletActionContext.getRequest().getRealPath("/reportfiles/JrsbkBatchHf.jasper");
			byte[] pdfContent = JasperRunManager.runReportToPdf(path, reportsHashMap);
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealCode(999999);
			actionLog.setInOutData("");
			SysActionLog log = cardApplyService.savePrintReport(actionLog, cardApplyService.getUser());
			cardApplyService.saveSysReport(log, new JSONObject(), "", Constants.APP_REPORT_TYPE_PDF2, 1L, "", pdfContent);
			jsonObject.put("status", "0");
			jsonObject.put("title", "");
			jsonObject.put("dealNo", log.getDealNo());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * @return the rec
	 */
	public TrServRec getRec() {
		return rec;
	}
	/**
	 * @return the cardApplyService
	 */
	public CardApplyService getCardApplyService() {
		return cardApplyService;
	}
	/**
	 * @return the apply
	 */
	public CardApply getApply() {
		return apply;
	}
	/**
	 * @return the bp
	 */
	public BasePersonal getBp() {
		return bp;
	}
	/**
	 * @return the branchId
	 */
	public String getBranchId() {
		return branchId;
	}
	/**
	 * @return the operId
	 */
	public String getOperId() {
		return operId;
	}
	/**
	 * @return the taskId
	 */
	public String getTaskId() {
		return taskId;
	}
	/**
	 * @return the apply_Id
	 */
	public String getApply_Id() {
		return apply_Id;
	}
	/**
	 * @return the cardType
	 */
	public String getCardType() {
		return cardType;
	}
	/**
	 * @return the applyWay
	 */
	public String getApplyWay() {
		return applyWay;
	}
	/**
	 * @return the beginTime
	 */
	public String getBeginTime() {
		return beginTime;
	}
	/**
	 * @return the endTime
	 */
	public String getEndTime() {
		return endTime;
	}
	/**
	 * @return the regionId
	 */
	public String getRegionId() {
		return regionId;
	}
	/**
	 * @return the corpRegionId
	 */
	public String getCorpRegionId() {
		return corpRegionId;
	}
	/**
	 * @return the townId
	 */
	public String getTownId() {
		return townId;
	}
	/**
	 * @return the commId
	 */
	public String getCommId() {
		return commId;
	}
	/**
	 * @return the groupId
	 */
	public String getGroupId() {
		return groupId;
	}
	/**
	 * @return the queryType
	 */
	public String getQueryType() {
		return queryType;
	}
	/**
	 * @return the companyNo
	 */
	public String getCompanyNo() {
		return companyNo;
	}
	/**
	 * @return the companyName
	 */
	public String getCompanyName() {
		return companyName;
	}
	/**
	 * @return the sort
	 */
	public String getSort() {
		return sort;
	}
	/**
	 * @return the order
	 */
	public String getOrder() {
		return order;
	}
	/**
	 * @return the makeCardWay
	 */
	public String getMakeCardWay() {
		return makeCardWay;
	}
	/**
	 * @return the isPhoto
	 */
	public String getIsPhoto() {
		return isPhoto;
	}
	/**
	 * @return the corpType
	 */
	public String getCorpType() {
		return corpType;
	}
	/**
	 * @return the certNo
	 */
	public String getCertNo() {
		return certNo;
	}
	/**
	 * @return the clientName
	 */
	public String getClientName() {
		return clientName;
	}
	/**
	 * @return the bankId
	 */
	public String getBankId() {
		return bankId;
	}
	/**
	 * @return the bkvenId
	 */
	public String getBkvenId() {
		return bkvenId;
	}
	/**
	 * @return the corpName
	 */
	public String getCorpName() {
		return corpName;
	}
	/**
	 * @return the urgentFee
	 */
	public String getUrgentFee() {
		return urgentFee;
	}
	/**
	 * @return the costFee
	 */
	public String getCostFee() {
		return costFee;
	}
	/**
	 * @return the isUrgent
	 */
	public String getIsUrgent() {
		return isUrgent;
	}
	/**
	 * @return the agtCertType
	 */
	public String getAgtCertType() {
		return agtCertType;
	}
	/**
	 * @return the agtCertNo
	 */
	public String getAgtCertNo() {
		return agtCertNo;
	}
	/**
	 * @return the agtName
	 */
	public String getAgtName() {
		return agtName;
	}
	/**
	 * @return the customerId
	 */
	public String getCustomerId() {
		return customerId;
	}
	/**
	 * @return the agtTelNo
	 */
	public String getAgtTelNo() {
		return agtTelNo;
	}
	/**
	 * @return the recvBrchId
	 */
	public String getRecvBrchId() {
		return recvBrchId;
	}
	/**
	 * @return the selectedId
	 */
	public String getSelectedId() {
		return selectedId;
	}
	/**
	 * @return the personPhotoContent
	 */
	public String getPersonPhotoContent() {
		return personPhotoContent;
	}
	/**
	 * @return the bustype3
	 */
	public String getBustype3() {
		return bustype3;
	}
	/**
	 * @return the defaultErrMsg
	 */
	public String getDefaultErrMsg() {
		return defaultErrMsg;
	}
	/**
	 * @return the customerName
	 */
	public String getCustomerName() {
		return customerName;
	}
	/**
	 * @param rec the rec to set
	 */
	public void setRec(TrServRec rec) {
		this.rec = rec;
	}
	/**
	 * @param cardApplyService the cardApplyService to set
	 */
	public void setCardApplyService(CardApplyService cardApplyService) {
		this.cardApplyService = cardApplyService;
	}
	/**
	 * @param apply the apply to set
	 */
	public void setApply(CardApply apply) {
		this.apply = apply;
	}
	/**
	 * @param bp the bp to set
	 */
	public void setBp(BasePersonal bp) {
		this.bp = bp;
	}
	/**
	 * @param branchId the branchId to set
	 */
	public void setBranchId(String branchId) {
		this.branchId = branchId;
	}
	/**
	 * @param operId the operId to set
	 */
	public void setOperId(String operId) {
		this.operId = operId;
	}
	/**
	 * @param taskId the taskId to set
	 */
	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}
	/**
	 * @param apply_Id the apply_Id to set
	 */
	public void setApply_Id(String apply_Id) {
		this.apply_Id = apply_Id;
	}
	/**
	 * @param cardType the cardType to set
	 */
	public void setCardType(String cardType) {
		this.cardType = cardType;
	}
	/**
	 * @param applyWay the applyWay to set
	 */
	public void setApplyWay(String applyWay) {
		this.applyWay = applyWay;
	}
	/**
	 * @param beginTime the beginTime to set
	 */
	public void setBeginTime(String beginTime) {
		this.beginTime = beginTime;
	}
	/**
	 * @param endTime the endTime to set
	 */
	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}
	/**
	 * @param regionId the regionId to set
	 */
	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}
	/**
	 * @param corpRegionId the corpRegionId to set
	 */
	public void setCorpRegionId(String corpRegionId) {
		this.corpRegionId = corpRegionId;
	}
	/**
	 * @param townId the townId to set
	 */
	public void setTownId(String townId) {
		this.townId = townId;
	}
	/**
	 * @param commId the commId to set
	 */
	public void setCommId(String commId) {
		this.commId = commId;
	}
	/**
	 * @param groupId the groupId to set
	 */
	public void setGroupId(String groupId) {
		this.groupId = groupId;
	}
	/**
	 * @param queryType the queryType to set
	 */
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	/**
	 * @param companyNo the companyNo to set
	 */
	public void setCompanyNo(String companyNo) {
		this.companyNo = companyNo;
	}
	/**
	 * @param companyName the companyName to set
	 */
	public void setCompanyName(String companyName) {
		this.companyName = companyName;
	}
	/**
	 * @param sort the sort to set
	 */
	public void setSort(String sort) {
		this.sort = sort;
	}
	/**
	 * @param order the order to set
	 */
	public void setOrder(String order) {
		this.order = order;
	}
	/**
	 * @param makeCardWay the makeCardWay to set
	 */
	public void setMakeCardWay(String makeCardWay) {
		this.makeCardWay = makeCardWay;
	}
	/**
	 * @param isPhoto the isPhoto to set
	 */
	public void setIsPhoto(String isPhoto) {
		this.isPhoto = isPhoto;
	}
	/**
	 * @param corpType the corpType to set
	 */
	public void setCorpType(String corpType) {
		this.corpType = corpType;
	}
	/**
	 * @param certNo the certNo to set
	 */
	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}
	/**
	 * @param clientName the clientName to set
	 */
	public void setClientName(String clientName) {
		this.clientName = clientName;
	}
	/**
	 * @param bankId the bankId to set
	 */
	public void setBankId(String bankId) {
		this.bankId = bankId;
	}
	/**
	 * @param bkvenId the bkvenId to set
	 */
	public void setBkvenId(String bkvenId) {
		this.bkvenId = bkvenId;
	}
	/**
	 * @param corpName the corpName to set
	 */
	public void setCorpName(String corpName) {
		this.corpName = corpName;
	}
	/**
	 * @param urgentFee the urgentFee to set
	 */
	public void setUrgentFee(String urgentFee) {
		this.urgentFee = urgentFee;
	}
	/**
	 * @param costFee the costFee to set
	 */
	public void setCostFee(String costFee) {
		this.costFee = costFee;
	}
	/**
	 * @param isUrgent the isUrgent to set
	 */
	public void setIsUrgent(String isUrgent) {
		this.isUrgent = isUrgent;
	}
	/**
	 * @param agtCertType the agtCertType to set
	 */
	public void setAgtCertType(String agtCertType) {
		this.agtCertType = agtCertType;
	}
	/**
	 * @param agtCertNo the agtCertNo to set
	 */
	public void setAgtCertNo(String agtCertNo) {
		this.agtCertNo = agtCertNo;
	}
	/**
	 * @param agtName the agtName to set
	 */
	public void setAgtName(String agtName) {
		this.agtName = agtName;
	}
	/**
	 * @param customerId the customerId to set
	 */
	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}
	/**
	 * @param agtTelNo the agtTelNo to set
	 */
	public void setAgtTelNo(String agtTelNo) {
		this.agtTelNo = agtTelNo;
	}
	/**
	 * @param recvBrchId the recvBrchId to set
	 */
	public void setRecvBrchId(String recvBrchId) {
		this.recvBrchId = recvBrchId;
	}
	/**
	 * @param selectedId the selectedId to set
	 */
	public void setSelectedId(String selectedId) {
		this.selectedId = selectedId;
	}
	/**
	 * @param personPhotoContent the personPhotoContent to set
	 */
	public void setPersonPhotoContent(String personPhotoContent) {
		this.personPhotoContent = personPhotoContent;
	}
	/**
	 * @param bustype3 the bustype3 to set
	 */
	public void setBustype3(String bustype3) {
		this.bustype3 = bustype3;
	}
	/**
	 * @param defaultErrMsg the defaultErrMsg to set
	 */
	public void setDefaultErrMsg(String defaultErrMsg) {
		this.defaultErrMsg = defaultErrMsg;
	}
	/**
	 * @param customerName the customerName to set
	 */
	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}
	/**
	 * @return the applyIds
	 */
	public String getApplyIds() {
		return applyIds;
	}
	/**
	 * @param applyIds the applyIds to set
	 */
	public void setApplyIds(String applyIds) {
		this.applyIds = applyIds;
	}
	/**
	 * @return the synGroupId
	 */
	public String getSynGroupId() {
		return synGroupId;
	}

	public void setSynGroupId(String synGroupId) {
		this.synGroupId = synGroupId;
	}
	public String[] getFilePath() {
		return filePath;
	}
	public void setFilePath(String[] filePath) {
		this.filePath = filePath;
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
	public String getTemplate() {
		return template;
	}
	public void setTemplate(String template) {
		this.template = template;
	}
	public String getIsJudgeSbState() {
		return isJudgeSbState;
	}
	public void setIsJudgeSbState(String isJudgeSbState) {
		this.isJudgeSbState = isJudgeSbState;
	}
	public String getIsBatchHf() {
		return isBatchHf;
	}
	public void setIsBatchHf(String isBatchHf) {
		this.isBatchHf = isBatchHf;
	}
	public boolean getOnlyAppNewCard() {
		return onlyAppNewCard;
	}
	public void setOnlyAppNewCard(boolean onlyAppNewCard) {
		this.onlyAppNewCard = onlyAppNewCard;
	}

	public boolean getOnlyAppHFCard() {
		return onlyAppHFCard;
	}

	public void setOnlyAppHFCard(boolean onlyAppHFCard) {
		this.onlyAppHFCard = onlyAppHFCard;
	}

	public String getBatchNo() {
		return batchNo;
	}

	public void setBatchNo(String batchNo) {
		this.batchNo = batchNo;
	}
}
