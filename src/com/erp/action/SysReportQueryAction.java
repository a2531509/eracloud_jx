package com.erp.action;

import java.io.IOException;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.DataFormat;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.ss.util.RegionUtil;
import org.apache.shiro.SecurityUtils;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseMerchant;
import com.erp.model.SysBranch;
import com.erp.model.TrServRec;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

import jxl.format.Alignment;
import jxl.format.Border;
import jxl.format.BorderLineStyle;
import jxl.write.Label;
import jxl.write.WritableCellFormat;
import jxl.write.WritableFont;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;
import net.sf.json.JSONArray;


/**----------------------------------------------------	*
*@category                                             　　　　　　　　　　　　　			*
*系统营业报表查询，主要功能点                                                                			*
*1、系统财务报表                                                                                                		*
*2、系统业务报表                                                                                                 		*
*3、人员信息查询                                                                                                		*
*@author hujc                                  			*  
*@date 2015-09-18                                		*
*@email hujchen@126.com                 				*
*@version 1.0                                   		*
*------------------------------------------------------	*/
@Namespace("/sysReportQuery")
@Action(value = "sysReportQueryAction")
@Results({@Result(name="cardServiceIncomeStat",location="/jsp/sysStatReport/cardServiceIncomeStatMain.jsp")})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class SysReportQueryAction extends BaseAction {
	private static final String EXPORT_DATA = "export_data";
	private static final String EXPORT_FILE_NAME = "export_file_name";
	private static final String BRANCH_BRCH_ID = "brch_id";
	private static final String BRANCH_ID = "id";
	private static final String BRANCH_PARENT_ID = "branch_pid";
	private static final String BRANCH_NAME = "branch_name";
	private static final String BRANCH_LEVEL = "branch_level";
	private static final String MAX_BRANCH_LEVEL = "max_branch_level";
	// business
	private static final String BRANCH_BUSINESS_NUM = "business_num";
	private static final String BRANCH_BUSINESS_AMT = "business_amt";
	// account
	private static final String BRANCH_ACCOUNT_PER_NUM = "per_num";// 上期结余笔数
	private static final String BRANCH_ACCOUNT_PER_AMT = "per_amt";// 上期结余金额
	private static final String BRANCH_ACCOUNT_NUM = "num"; // 本期笔数
	private static final String BRANCH_ACCOUNT_AMT = "amt"; // 本期金额
	private static final String BRANCH_ACCOUNT_END_NUM = "end_num";// 本期结余笔数
	private static final String BRANCH_ACCOUNT_END_AMT = "end_amt";// 本期结余金额
	
	private String expid;
	private String acptType;//受理点类型
	private String queryType = "";//查询标志
	private String brch_Id = "";//网点编号
	private String org_Id ="";//机构编号
	private String user_Id = "";//柜员编号
	private String rec_Type = "";//受理点类型 1 自有网点  2 合作网点
	private String deal_Code = "";//交易代码
	private String startDate = "";//开始日期
	private String endDate ="";//结束日期
	private String sort="";
	private String order="";
	private String coOrgId="";
	private String cardType="";
	private String accKind = "";
	private String merchantId = "";
	private String merchantName = "";
	private String id = "";
	private TrServRec rec = new TrServRec();
	private String defaultErrMsg;
	private String exportFlag = "1";
	private String qyMonth="";
	private String qyMonthEnd="";
	private String region_Id="";
	private String merchantIds = "";
	private String coOrgIds = "";
	private String checkIds = "";
	private boolean cascadeBrch = false;
	private boolean statByDay = false;

	/**
	 * 查询系统业务表报
	 * @return
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public String queryBusinessRp(){
		jsonObject.put("rows",new JSONArray());
		JSONArray fotal = new JSONArray();
		JSONObject footer = new JSONObject();
		jsonObject.put("total","0");
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		try{
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				if(rec_Type.equals("1")){//网点业务，支持无限级别
					if(!Tools.processNull(id).equals("")){
						brch_Id = ((SysBranch)baseService.findOnlyRowByHql("from SysBranch where sysBranchId ='"+id+"'")).getBrchId();
					}
					//构造查询语句
					StringBuffer sb_org  = new StringBuffer();
					
					if(!"".equals(Tools.processNull(deal_Code))){
						sb_org.append(" and t1.deal_code = '"+deal_Code+"' ");
					}
					if(!"".equals(Tools.processNull(startDate))){
						sb_org.append(" and t1.clr_date >= '"+startDate+"' ");
					}
					if(!"".equals(Tools.processNull(endDate))){
						sb_org.append(" and t1.clr_date <= '"+endDate+"' ");
					}
					if(!"".equals(Tools.processNull(org_Id))){
						sb_org.append(" and t1.org_Id = '"+org_Id+"' ");
					}
					if(!"".equals(Tools.processNull(user_Id))&&!"erp2_erp2".equals(Tools.processNull(user_Id))){
						sb_org.append(" and t1.user_Id = '"+user_Id+"' ");
					}
					Page list = null;
					////统计网点业务信息
					String limitSql = "";
					String sql = "";
					String sumSql = "";
					if(!"".equals(Tools.processNull(brch_Id))){
						SysBranch brch = (SysBranch)baseService.findOnlyRowByHql("from SysBranch where brchId ='"+brch_Id+"'");
						if(!Tools.processNull(id).equals("")){
							limitSql = " and t2.brch_id in ((select a.brch_id from sys_branch a start with a.pid = '"+brch.getSysBranchId()+"' connect by prior a.sysbranch_id = a.pid)) ";
							sql  = "select t2.sysbranch_id id,t2.full_name name,'' codeName,'closed' state, t2.pid pid,"
									+ " (select sum(num) from stat_day_bal t3 where 1=1  "+sb_org.toString().replace("t1", "t3")+" and t3.user_id is null and t3.brch_id is not null and"
									+ " t3.brch_id in (select t.brch_id from sys_branch t start with t.sysbranch_id = t2.sysbranch_id connect by prior t.sysbranch_id = t.pid)) num, "
									+ " (select trim(to_char(sum(nvl(amt,0))/100,'99,999,999,999,990.99')) from stat_day_bal t3 where 1=1  "+sb_org.toString().replace("t1", "t3")+" and t3.user_id is not null and t3.brch_id is not null and"
									+ " t3.brch_id in (select t.brch_id from sys_branch t start with t.sysbranch_id = t2.sysbranch_id connect by prior t.sysbranch_id = t.pid)) amt  "
									+ " from stat_day_bal t1, sys_branch t2 where t1.brch_id = t2.brch_id and t1.brch_id is not null and t1.user_id is not null "+sb_org.toString() + limitSql 
									+ " group by t1.brch_id, t2.full_name, t2.sysbranch_id,t2.pid ";
							sumSql  = "select t2.sysbranch_id id,t2.full_name name,'' codeName,'closed' state, t2.pid pid,"
									+ " (select sum(num) from stat_day_bal t3 where 1=1 "+sb_org.toString().replace("t1", "t3")
									+ " and t3.user_id is null and t3.brch_id is not null and t3.brch_id in (select t.brch_id from sys_branch t start with t.sysbranch_id = t2.sysbranch_id connect by prior t.sysbranch_id = t.pid)) num, "
									+ " (select sum(nvl(amt,0)) from stat_day_bal t3 where 1=1 "+sb_org.toString().replace("t1", "t3")
									+ " and t3.user_id is null and t3.brch_id is not null and t3.brch_id in (select t.brch_id from sys_branch t start with t.sysbranch_id = t2.sysbranch_id connect by prior t.sysbranch_id = t.pid)) amt  "
									+ " from stat_day_bal t1, sys_branch t2 where t1.brch_id = t2.brch_id and t1.brch_id is not null and t1.user_id is not null "+sb_org.toString() + limitSql 
									+ " group by t1.brch_id, t2.full_name, t2.sysbranch_id,t2.pid ";
							list = baseService.pagingQuery(sql, page, 1000000);
						}else{
							limitSql = " and t2.brch_id in ((select a.brch_id from sys_branch a start with a.sysbranch_id = '"+brch.getSysBranchId()+"' connect by prior a.sysbranch_id = a.pid)) ";
							sql = "select t2.sysbranch_id id,t2.full_name name,'' codeName,'closed' state, t2.pid pid,"
									+ " (select sum(num) from stat_day_bal t3 where 1=1 "
									+ sb_org.toString().replace("t1", "t3") +" and t3.user_id is not null and t3.brch_id is not null and  t3.brch_id in (select t.brch_id from sys_branch t start with t.sysbranch_id = t2.sysbranch_id connect by prior t.sysbranch_id = t.pid)) num, "
									+ " (select trim(to_char(sum(nvl(amt,0))/100,'99,999,999,999,990.99')) from stat_day_bal t3 where 1=1 "
									+ sb_org.toString().replace("t1", "t3") +" and t3.user_id is not null and t3.brch_id is not null and t3.brch_id in (select t.brch_id from sys_branch t start with t.sysbranch_id = t2.sysbranch_id connect by prior t.sysbranch_id = t.pid)) amt  "
									+ " from stat_day_bal t1, sys_branch t2 where t1.brch_id = t2.brch_id and t1.brch_id is not null and t1.user_id is not null "+sb_org.toString() + limitSql 
									+ " group by t1.brch_id, t2.full_name, t2.sysbranch_id,t2.pid ";
							sumSql = "select t2.sysbranch_id id,t2.full_name name,'' codeName,'closed' state, t2.pid pid,"
									+ " (select sum(num) from stat_day_bal t3 where 1=1 "
									+ sb_org.toString().replace("t1", "t3") +" and t3.user_id is not null and t3.brch_id is not null and  t3.brch_id in (select t.brch_id from sys_branch t start with t.sysbranch_id = t2.sysbranch_id connect by prior t.sysbranch_id = t.pid)) num, "
									+ " (select sum(nvl(amt,0)) from stat_day_bal t3 where 1=1 "
									+ sb_org.toString().replace("t1", "t3") +" and t3.user_id is not null and t3.brch_id is not null and t3.brch_id in (select t.brch_id from sys_branch t start with t.sysbranch_id = t2.sysbranch_id connect by prior t.sysbranch_id = t.pid)) amt  "
									+ " from stat_day_bal t1, sys_branch t2 where t1.brch_id = t2.brch_id and t1.brch_id is not null and t1.user_id is not null "+sb_org.toString() + limitSql 
									+ " group by t1.brch_id, t2.full_name, t2.sysbranch_id,t2.pid ";
							list = baseService.pagingQuery("select * from ("+sql+")", page, 100000);
						}
					}else{//如果没有输入网点编号，则直接查询以及网点进行统计，不按照交易代码
						 sql = "select t2.sysbranch_id id,t2.full_name name,'' codeName,'closed' state,t2.pid pid,"
							+ " (select nvl(sum(num),0) from stat_day_bal t3 where 1=1 "
						    + sb_org.toString().replace("t1", "t3") +" and t3.user_id is not null and t3.brch_id is not null and t3.brch_id in "
							+ " (select t.brch_id from sys_branch t start with t.sysbranch_id = t2.sysbranch_id connect by prior t.sysbranch_id = t.pid)) num,"
						    + " (select trim(to_char(nvl(sum(nvl(amt, 0)),0) / 100, '99,999,999,999,990.99'))from stat_day_bal t3 where 1=1"
						    + sb_org.toString().replace("t1", "t3") +" and t3.user_id is not null and t3.brch_id is not null and t3.brch_id in "
							+ " (select t.brch_id from sys_branch t start with t.sysbranch_id = t2.sysbranch_id connect by prior t.sysbranch_id = t.pid)) amt "
							+ " from sys_branch t2 where t2.pid is null "
							+ " group by t2.brch_id, t2.full_name, t2.sysbranch_id,t2.pid order by t2.brch_id ";
						 sumSql = "select t2.sysbranch_id id,t2.full_name name,'' codeName,'closed' state,t2.pid pid,"
									+ " (select nvl(sum(num),0) from stat_day_bal t3 where 1=1 "
								    + sb_org.toString().replace("t1", "t3") +" and t3.user_id is not null and t3.brch_id is not null and t3.brch_id in "
									+ " (select t.brch_id from sys_branch t start with t.sysbranch_id = t2.sysbranch_id connect by prior t.sysbranch_id = t.pid)) num,"
								    + " (select nvl(sum(nvl(amt, 0)),0) from stat_day_bal t3 where 1=1"
								    + sb_org.toString().replace("t1", "t3") +" and t3.user_id is not null and t3.brch_id is not null and t3.brch_id in "
									+ " (select t.brch_id from sys_branch t start with t.sysbranch_id = t2.sysbranch_id connect by prior t.sysbranch_id = t.pid)) amt "
									+ " from sys_branch t2 where t2.pid is null "
									+ " group by t2.brch_id, t2.full_name, t2.sysbranch_id,t2.pid ";
						 list = baseService.pagingQuery(sql, page, 100000);
					}
					//计算总笔数总金额
					List totalMsg = baseService.findBySql("select sum(num) allNum , trim(to_char(sum(nvl(amt,0))/100,'99,999,999,999,990.99')) allAmt from ("+sumSql+")");
					if(totalMsg != null && totalMsg.size() > 0){
						footer.put("name","本页信息统计");
						if(((Object[])totalMsg.get(0))[0] == null){
							footer.put("num","总笔数："+0);
						}else{
							footer.put("num","总笔数："+((Object[])totalMsg.get(0))[0].toString());
						}
						if(((Object[])totalMsg.get(0))[1] == null){
							footer.put("amt","总金额："+"0.00");
						}else{
							footer.put("amt","总金额："+((Object[])totalMsg.get(0))[1].toString());
						}
						
					}
					if(list.getAllRs() == null || list.getAllRs().size() <= 0){
						throw new CommonException("未查询到对应的统计信息！");
					}else{
						jsonObject.put("rows", JSONArray.fromObject(list.getAllRs().toJSONString().toLowerCase()));
						jsonObject.put("total",list.getTotalCount());
					}
				}else{
					throw new CommonException("暂时不支持该类型的统计查询！");
				}
			}else{
				footer.put("name","本页信息统计");
				footer.put("num","总金额："+"0");
				footer.put("amt","0.00");
			}
		}catch(Exception e){
			footer.put("name","本页信息统计");
			footer.put("num","总金额：");
			footer.put("amt","0.00");
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		fotal.add(footer);
		jsonObject.put("footer",fotal);
		return this.JSONOBJ;
	}
	
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public  String  queryAccountRp(){
		jsonObject.put("rows",new JSONArray());
		JSONArray fotal = new JSONArray();
		JSONObject footer = new JSONObject();
		jsonObject.put("total","0");
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		try {
			this.initGrid();
			//由于需要统计期末期初值所以必须输入其实时间和结束时间
			if(Tools.processNull(this.queryType).equals("0")){
				if(rec_Type.equals("0")){//商户信息统计
					String sql = "";
					String sumsql = "";
					if(!Tools.processNull(id).equals("")){
						merchantId = ((BaseMerchant)baseService.findOnlyRowByHql("from BaseMerchant where merchantId ='"+id+"'")).getMerchantId();
					}
					//构造查询语句
					StringBuffer sb_org  = new StringBuffer();
					sb_org.append(" and t1.acpt_type = '0' ");
					if(!"".equals(Tools.processNull(deal_Code))){
						sb_org.append(" and t1.deal_code = '"+deal_Code+"' ");
					}
					if(!"".equals(Tools.processNull(startDate))){
						sb_org.append(" and t1.clr_date >= '"+startDate+"' ");
					}
					if(!"".equals(Tools.processNull(endDate))){
						sb_org.append(" and t1.clr_date <= '"+endDate+"' ");
					}
					if(!"".equals(Tools.processNull(cardType))){
						sb_org.append(" and t1.card_type='"+cardType+"' ");
					}
					if(!"".equals(Tools.processNull(accKind))){
						sb_org.append(" and t1.acc_kind='"+accKind+"' ");
					}
					StringBuffer pernumSQL = new StringBuffer();//统计期初笔数sql
					StringBuffer peramtSQL = new StringBuffer();//统计期初金额sql
					StringBuffer endnumSQL = new StringBuffer();//统计期末笔数sql
					StringBuffer endamtSQL = new StringBuffer();//统计期末金额sql
					StringBuffer pernumsumSQL = new StringBuffer();//统计期初笔数sql
					StringBuffer peramtsumSQL = new StringBuffer();//统计期初金额sql
					StringBuffer endnumsumSQL = new StringBuffer();//统计期末笔数sql
					StringBuffer endamtsumSQL = new StringBuffer();//统计期末金额sql 
					
					//组装期初值SQL
					String perSameSql = " (SELECT sum(end_num) OVER(partition by t1.deal_code, t1.acpt_id order by clr_date desc) per_num,"
							+"  sum(end_amt) OVER(partition by t1.deal_code, t1.acpt_id order by clr_date desc) per_amt,"
							+" acpt_id,rank() over(partition by t1.deal_code, t1.acpt_id order by clr_date desc) MM"
							+" from STAT_CARD_PAY t1 WHERE 1 = 1 and t1.clr_date <='"+startDate+"'";
					
					if(!"".equals(Tools.processNull(deal_Code))){
						perSameSql +=" and t1.deal_code = '"+deal_Code+"' ";
					}
					if(!"".equals(Tools.processNull(cardType))){
						perSameSql +=" and t1.card_type='"+cardType+"' ";
					}
					if(!"".equals(Tools.processNull(accKind))){
						perSameSql +=" and t1.acc_kind='"+accKind+"' ";
					}
					if(!"".equals(Tools.processNull(org_Id))){
						perSameSql +=" and t1.org_Id = '"+org_Id+"' ";
					}
					perSameSql += ")";
					pernumSQL.append("(select nvl(sum(per_num), 0) from " + perSameSql +" where 1=1 and mm = 1 and ");
					pernumSQL.append("acpt_id in (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id)) per_num,");
					peramtSQL.append("(select to_char(nvl(sum(per_amt), 0)/100,'99,999,999,999,990.99') from " + perSameSql +" where 1=1 and mm = 1 and ");
					peramtSQL.append("acpt_id in (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id)) per_amt,");
					
					pernumsumSQL.append("(select nvl(sum(per_num), 0) from " + perSameSql +" where 1=1 and mm = 1 and ");
					pernumsumSQL.append("acpt_id in (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id)) per_num,");
					peramtsumSQL.append("(select nvl(sum(per_amt), 0) from " + perSameSql +" where 1=1 and mm = 1 and ");
					peramtsumSQL.append("acpt_id in (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id)) per_amt,");
					//组装期末值SQL
					String endSameSql = " (SELECT sum(end_num) OVER(partition by t1.deal_code, t1.acpt_id order by clr_date desc) end_num,"
							+"  sum(end_amt) OVER(partition by t1.deal_code, t1.acpt_id order by clr_date desc) end_amt,"
							+" acpt_id,rank() over(partition by t1.deal_code, t1.acpt_id order by clr_date desc) MM"
							+" from STAT_CARD_PAY t1 WHERE 1 = 1 and t1.clr_date <='"+endDate+"'";
					
					if(!"".equals(Tools.processNull(deal_Code))){
						endSameSql +=" and t1.deal_code = '"+deal_Code+"' ";
					}
					if(!"".equals(Tools.processNull(cardType))){
						endSameSql +=" and t1.card_type='"+cardType+"' ";
					}
					if(!"".equals(Tools.processNull(accKind))){
						endSameSql +=" and t1.acc_kind='"+accKind+"' ";
					}
					if(!"".equals(Tools.processNull(org_Id))){
						endSameSql +=" and t1.org_Id = '"+org_Id+"' ";
					}		
					endSameSql +=")";
					endnumSQL.append("(select nvl(sum(end_num), 0) from " + endSameSql +" where 1=1 and mm = 1 and ");
					endnumSQL.append("acpt_id in (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id)) end_num,");
					endamtSQL.append("(select to_char(nvl(sum(end_amt), 0)/100,'99,999,999,999,990.99') from " + endSameSql +" where 1=1 and mm = 1 and ");
					endamtSQL.append("acpt_id in (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id)) end_amt ");
					
					endnumsumSQL.append("(select nvl(sum(end_num), 0) from " + endSameSql +" where 1=1 and mm = 1 and ");
					endnumsumSQL.append("acpt_id in (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id)) end_num,");
					endamtsumSQL.append("(select nvl(sum(end_amt), 0) from " + endSameSql +" where 1=1 and mm = 1 and ");
					endamtsumSQL.append("acpt_id in (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id)) end_amt ");
					
					Page list = null;
					if(!"".equals(Tools.processNull(merchantId))){
						BaseMerchant mer = (BaseMerchant)baseService.findOnlyRowByHql("from BaseMerchant where merchantId ='"+merchantId+"'");
						if(!Tools.processNull(id).equals("")){
							String limitSql = " and t2.merchant_id in ((select a.merchant_id from base_merchant a start with a.top_merchant_id = '"+mer.getMerchantId()+"' connect by prior a.merchant_id = a.top_merchant_id)) ";
							 sql = "select t2.merchant_id id,t2.merchant_name name,'' codeName,'closed' state,t2.top_merchant_id pid,"
										+ "(SELECT nvl(SUM(t1.num), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id) "+sb_org.toString()+") num,"
										+ "(SELECT to_char(nvl(SUM(t1.amt), 0)/100,'99,999,999,999,990.99') FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id) "+sb_org.toString()+") amt,"
										+ pernumSQL + peramtSQL + endnumSQL + endamtSQL 
										+ " from base_merchant t2 where 1=1  "+limitSql
										+ " group by t2.merchant_id, t2.merchant_id, t2.top_merchant_id, t2.merchant_name ";
							 sumsql = "select t2.merchant_id id,t2.merchant_name name,'' codeName,'closed' state,t2.top_merchant_id pid,"
										+ "(SELECT nvl(SUM(t1.num), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id) "+sb_org.toString()+") num,"
										+ "(SELECT nvl(SUM(t1.amt), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id) "+sb_org.toString()+") amt,"
										+ pernumsumSQL + peramtsumSQL + endnumsumSQL + endamtsumSQL 
										+ " from base_merchant t2 where 1=1  "+limitSql
										+ " group by t2.merchant_id, t2.merchant_id, t2.top_merchant_id, t2.merchant_name ";
							list = baseService.pagingQuery(sql, page, 10000);
						}else{
							String limitSql = " and t2.merchant_id in ((select a.merchant_id from base_merchant a start with a.merchant_id = '"+mer.getMerchantId()+"' connect by prior a.merchant_id = a.top_merchant_id)) ";
							 sql = "select t2.merchant_id id,t2.merchant_name name,'' codeName,'closed' state,t2.top_merchant_id pid,"
										+ "(SELECT nvl(SUM(t1.num), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id) "+sb_org.toString()+") num,"
										+ "(SELECT to_char(nvl(SUM(t1.amt), 0)/100,'99,999,999,999,990.99') FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id) "+sb_org.toString()+") amt,"
										+ pernumSQL + peramtSQL + endnumSQL + endamtSQL 
										+ " from base_merchant t2 where 1=1  "+limitSql
										+ " group by t2.merchant_id, t2.merchant_id, t2.top_merchant_id, t2.merchant_name ";
							 sumsql = "select t2.merchant_id id,t2.merchant_name name,'' codeName,'closed' state,t2.top_merchant_id pid,"
										+ "(SELECT nvl(SUM(t1.num), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id) "+sb_org.toString()+") num,"
										+ "(SELECT nvl(SUM(t1.amt), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id) "+sb_org.toString()+") amt,"
										+ pernumsumSQL + peramtsumSQL + endnumsumSQL + endamtsumSQL 
										+ " from base_merchant t2 where 1=1  "+limitSql
										+ " group by t2.merchant_id, t2.merchant_id, t2.top_merchant_id, t2.merchant_name ";
							list = baseService.pagingQuery("select * from ("+sql+") where id ='"+mer.getMerchantId()+"'", page, 10000);
						}
					}else{//没有输入商户编号的
						sql = "select t2.merchant_id id,t2.merchant_name name,'' codeName,'closed' state,t2.top_merchant_id pid,"
									+ "(SELECT nvl(SUM(t1.num), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id) "+sb_org.toString()+") num,"
									+ "(SELECT to_char(nvl(SUM(t1.amt), 0)/100,'99,999,999,999,990.99') FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.merchant_id from base_merchant h start with h.merchant_id = t2.merchant_id CONNECT by PRIOR h.merchant_id = h.top_merchant_id) "+sb_org.toString()+") amt,"
									+ pernumSQL + peramtSQL + endnumSQL + endamtSQL
									+ " from base_merchant t2 where t2.top_merchant_id is null " ;
						sumsql = "select t2.merchant_id id,t2.merchant_name name,'' codeName,'closed' state,t2.top_merchant_id pid,"
								+ "(SELECT nvl(SUM(t1.num), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") num,"
								+ "(SELECT nvl(SUM(t1.amt), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") amt,"
								+ pernumsumSQL + peramtsumSQL + endnumsumSQL + endamtsumSQL 
								+ " from base_merchant t2 where t2.top_merchant_id is null " ;
						list = baseService.pagingQuery(sql, page, 10000);
					}
					
					
					//计算总笔数总金额
					
					if(list.getAllRs() == null || list.getAllRs().size() <= 0){
						throw new CommonException("未查询到对应的统计信息！");
					}else{
						jsonObject.put("rows", JSONArray.fromObject(list.getAllRs().toJSONString().toLowerCase()));
						jsonObject.put("total",list.getTotalCount());
					}
				}else if(rec_Type.equals("1")){//自有网点
					String sql = "";
					String sumsql = "";
					if(!Tools.processNull(id).equals("")){
						brch_Id = ((SysBranch)baseService.findOnlyRowByHql("from SysBranch where sysBranchId ='"+id+"'")).getBrchId();
					}
					//构造限制条件语句
					StringBuffer sb_org  = new StringBuffer();
					sb_org.append(" and t1.acpt_type = '1' ");
					if(!"".equals(Tools.processNull(deal_Code))){
						sb_org.append(" and t1.deal_code = '"+deal_Code+"' ");
					}
					if(!"".equals(Tools.processNull(startDate))){
						sb_org.append(" and t1.clr_date > '"+startDate+"' ");
					}
					if(!"".equals(Tools.processNull(endDate))){
						sb_org.append(" and t1.clr_date <= '"+endDate+"' ");
					}
					if(!"".equals(Tools.processNull(cardType))){
						sb_org.append(" and t1.card_type='"+cardType+"' ");
					}
					if(!"".equals(Tools.processNull(accKind))){
						sb_org.append(" and t1.acc_kind='"+accKind+"' ");
					}
					if(!"".equals(Tools.processNull(org_Id))){
						sb_org.append(" and t1.org_Id = '"+org_Id+"' ");
					}
					
					StringBuffer pernumSQL = new StringBuffer();//统计期初笔数sql
					StringBuffer peramtSQL = new StringBuffer();//统计期初金额sql
					StringBuffer endnumSQL = new StringBuffer();//统计期末笔数sql
					StringBuffer endamtSQL = new StringBuffer();//统计期末金额sql
					StringBuffer pernumsumSQL = new StringBuffer();//统计期初笔数sql
					StringBuffer peramtsumSQL = new StringBuffer();//统计期初金额sql
					StringBuffer endnumsumSQL = new StringBuffer();//统计期末笔数sql
					StringBuffer endamtsumSQL = new StringBuffer();//统计期末金额sql 
					//组装期初值SQL
					String perSameSql = " (SELECT sum(end_num) OVER(partition by t1.deal_code, t1.acpt_id order by clr_date desc) per_num,"
							+"  sum(end_amt) OVER(partition by t1.deal_code, t1.acpt_id order by clr_date desc) per_amt,"
							+" acpt_id,rank() over(partition by t1.deal_code, t1.acpt_id order by clr_date desc) MM"
							+" from STAT_CARD_PAY t1 WHERE 1 = 1 and t1.clr_date <='"+startDate+"'";
					
					if(!"".equals(Tools.processNull(deal_Code))){
						perSameSql +=" and t1.deal_code = '"+deal_Code+"' ";
					}
					if(!"".equals(Tools.processNull(cardType))){
						perSameSql +=" and t1.card_type='"+cardType+"' ";
					}
					if(!"".equals(Tools.processNull(accKind))){
						perSameSql +=" and t1.acc_kind='"+accKind+"' ";
					}
					if(!"".equals(Tools.processNull(org_Id))){
						perSameSql +=" and t1.org_Id = '"+org_Id+"' ";
					}
					perSameSql += ")";
					pernumSQL.append("(select nvl(sum(per_num), 0) from " + perSameSql +" where 1=1 and mm = 1 and ");
					pernumSQL.append("acpt_id in (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id CONNECT by PRIOR h.sysbranch_id = h.pid)) per_num,");
					peramtSQL.append("(select to_char(nvl(sum(per_amt), 0)/100,'99,999,999,999,990.99') from " + perSameSql +" where 1=1 and mm = 1 and ");
					peramtSQL.append("acpt_id in (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id CONNECT by PRIOR h.sysbranch_id = h.pid)) per_amt,");
					
					pernumsumSQL.append("(select nvl(sum(per_num), 0) from " + perSameSql +" where 1=1 and mm = 1 and ");
					pernumsumSQL.append("acpt_id in (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id CONNECT by PRIOR h.sysbranch_id = h.pid)) per_num,");
					peramtsumSQL.append("(select nvl(sum(per_amt), 0) from " + perSameSql +" where 1=1 and mm = 1 and ");
					peramtsumSQL.append("acpt_id in (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id CONNECT by PRIOR h.sysbranch_id = h.pid)) per_amt,");
					//组装期末值SQL
					String endSameSql = " (SELECT sum(end_num) OVER(partition by t1.deal_code, t1.acpt_id order by clr_date desc) end_num,"
							+"  sum(end_amt) OVER(partition by t1.deal_code, t1.acpt_id order by clr_date desc) end_amt,"
							+" acpt_id,rank() over(partition by t1.deal_code, t1.acpt_id order by clr_date desc) MM"
							+" from STAT_CARD_PAY t1 WHERE 1 = 1 and t1.clr_date <='"+endDate+"'";
					
					if(!"".equals(Tools.processNull(deal_Code))){
						endSameSql +=" and t1.deal_code = '"+deal_Code+"' ";
					}
					if(!"".equals(Tools.processNull(cardType))){
						endSameSql +=" and t1.card_type='"+cardType+"' ";
					}
					if(!"".equals(Tools.processNull(accKind))){
						endSameSql +=" and t1.acc_kind='"+accKind+"' ";
					}
					if(!"".equals(Tools.processNull(org_Id))){
						endSameSql +=" and t1.org_Id = '"+org_Id+"' ";
					}		
					endSameSql +=")";
					endnumSQL.append("(select nvl(sum(end_num), 0) from " + endSameSql +" where 1=1 and mm = 1 and ");
					endnumSQL.append("acpt_id in (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id CONNECT by PRIOR h.sysbranch_id = h.pid)) end_num,");
					endamtSQL.append("(select to_char(nvl(sum(end_amt), 0)/100,'99,999,999,999,990.99') from " + endSameSql +" where 1=1 and mm = 1 and ");
					endamtSQL.append("acpt_id in (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id CONNECT by PRIOR h.sysbranch_id = h.pid)) end_amt ");
					
					endnumsumSQL.append("(select nvl(sum(end_num), 0) from " + endSameSql +" where 1=1 and mm = 1 and ");
					endnumsumSQL.append("acpt_id in (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id CONNECT by PRIOR h.sysbranch_id = h.pid)) end_num,");
					endamtsumSQL.append("(select nvl(sum(end_amt), 0) from " + endSameSql +" where 1=1 and mm = 1 and ");
					endamtsumSQL.append("acpt_id in (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id CONNECT by PRIOR h.sysbranch_id = h.pid)) end_amt ");
					
					Page list = null;
					if(!"".equals(Tools.processNull(brch_Id))){
						SysBranch brch = (SysBranch)baseService.findOnlyRowByHql("from SysBranch where brchId ='"+brch_Id+"'");
						if(!Tools.processNull(id).equals("")){
							String limitSql = " and t2.brch_id in ((select a.brch_id from sys_branch a start with a.pid = '"+brch.getSysBranchId()+"' connect by prior a.sysbranch_id = a.pid)) ";
							 sql = "select t2.sysbranch_id id,t2.full_name name,'' codeName,'closed' state,t2.pid pid,"
									+ "(SELECT nvl(SUM(t1.num), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") num,"
									+ "(SELECT to_char(nvl(SUM(t1.amt), 0)/100,'99,999,999,999,990.99') FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") amt,"
									+ pernumSQL + peramtSQL + endnumSQL + endamtSQL 
									+ " from sys_branch t2 where 1=1  "+limitSql
									+ " group by t2.brch_id, t2.sysbranch_id, t2.pid, t2.full_name ";
							 sumsql = "select t2.sysbranch_id id,t2.full_name name,'' codeName,'closed' state,t2.pid pid,"
										+ "(SELECT nvl(SUM(t1.num), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") num,"
										+ "(SELECT nvl(SUM(t1.amt), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") amt,"
										+ pernumsumSQL + peramtsumSQL + endnumsumSQL + endamtsumSQL 
										+ " from sys_branch t2 where 1=1  "+limitSql
										+ " group by t2.brch_id, t2.sysbranch_id, t2.pid, t2.full_name ";
							list = baseService.pagingQuery(sql, page, 10000);
						}else{
							String limitSql = " and t2.brch_id in ((select a.brch_id from sys_branch a start with a.pid = '"+brch.getSysBranchId()+"' connect by prior a.sysbranch_id = a.pid)) ";
							 sql = "select t2.sysbranch_id id,t2.full_name name,'' codeName,'closed' state,t2.pid pid,"
									+ "(SELECT nvl(SUM(t1.num), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") num,"
									+ "(SELECT to_char(nvl(SUM(t1.amt), 0)/100,'99,999,999,999,990.99') FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") amt,"
									+ pernumSQL + peramtSQL + endnumSQL + endamtSQL 
									+ " from sys_branch t2 where 1=1  "+limitSql
									+ " group by t2.brch_id, t2.sysbranch_id, t2.pid, t2.full_name ";
							 sumsql = "select t2.sysbranch_id id,t2.full_name name,'' codeName,'closed' state,t2.pid pid,"
										+ "(SELECT nvl(SUM(t1.num), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") num,"
										+ "(SELECT nvl(SUM(t1.amt), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") amt,"
										+ pernumsumSQL + peramtsumSQL + endnumsumSQL + endamtsumSQL 
										+ " from sys_branch t2 where 1=1  "+limitSql
										+ " group by t2.brch_id, t2.sysbranch_id, t2.pid, t2.full_name ";
							list = baseService.pagingQuery("select * from ("+sql+")", page, 10000);
						}
					}else{//没有输入网点编号的
						sql = "select t2.sysbranch_id id,t2.full_name name,'' codeName,'closed' state,t2.pid pid,"
									+ "(SELECT nvl(SUM(t1.num), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") num,"
									+ "(SELECT to_char(nvl(SUM(t1.amt), 0)/100,'99,999,999,999,990.99') FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") amt,"
									+ pernumSQL + peramtSQL + endnumSQL + endamtSQL
									+ " from sys_branch t2 where t2.pid is null " ;
						sumsql = "select t2.sysbranch_id id,t2.full_name name,'' codeName,'closed' state,t2.pid pid,"
								+ "(SELECT nvl(SUM(t1.num), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") num,"
								+ "(SELECT nvl(SUM(t1.amt), 0) FROM stat_card_pay t1 WHERE t1.acpt_id IN (SELECT h.brch_id from sys_branch h start with h.sysbranch_id = t2.sysbranch_id  connect by prior h.sysbranch_id = h.pid) "+sb_org.toString()+") amt,"
								+ pernumsumSQL + peramtsumSQL + endnumsumSQL + endamtsumSQL 
								+ " from sys_branch t2 where t2.pid is null " ;
						list = baseService.pagingQuery(sql, page, 10000);
					}
					//计算总笔数总金额
					List totalMsg = baseService.findBySql("select sum(t1.per_num) per_num , trim(to_char(sum(nvl(t1.per_amt,0))/100,'999,999,9999,9990.99')) per_amt,"
							+ " sum(t1.num) num , trim(to_char(sum(nvl(t1.amt,0))/100,'99,999,999,999,990.99')) amt,"
							+ " sum(t1.end_num) end_num , trim(to_char(sum(nvl(t1.end_amt,0))/100,'99,999,999,999,990.99')) end_amt from (" +sumsql+") t1");
					if(totalMsg != null && totalMsg.size() > 0){
						footer.put("name","本页信息统计");
						if(((Object[])totalMsg.get(0))[0] == null){
							footer.put("per_num","上结余总笔数："+0);
						}else{
							footer.put("per_num","上期结余总笔数："+((Object[])totalMsg.get(0))[0].toString());
						}
						if(((Object[])totalMsg.get(0))[1] == null){
							footer.put("per_amt","上期结余总金额："+"0.00");
						}else{
							footer.put("per_amt","上期结余总金额："+((Object[])totalMsg.get(0))[1].toString());
						}
						if(((Object[])totalMsg.get(0))[0] == null){
							footer.put("num","本期内总笔数："+0);
						}else{
							footer.put("num","本期内总笔数："+((Object[])totalMsg.get(0))[2].toString());
						}
						if(((Object[])totalMsg.get(0))[1] == null){
							footer.put("amt","本期内总金额："+"0.00");
						}else{
							footer.put("amt","本期内总金额："+((Object[])totalMsg.get(0))[3].toString());
						}
						if(((Object[])totalMsg.get(0))[0] == null){
							footer.put("end_num","本期结余总笔数："+0);
						}else{
							footer.put("end_num","本期结余总笔数："+((Object[])totalMsg.get(0))[4].toString());
						}
						if(((Object[])totalMsg.get(0))[1] == null){
							footer.put("end_amt","本期结余总金额："+"0.00");
						}else{
							footer.put("end_amt","本期结余总金额："+((Object[])totalMsg.get(0))[5].toString());
						}
					}
					if(list.getAllRs() == null || list.getAllRs().size() <= 0){
						throw new CommonException("未查询到对应的统计信息！");
					}else{
						jsonObject.put("rows", JSONArray.fromObject(list.getAllRs().toJSONString().toLowerCase()));
						jsonObject.put("total",list.getTotalCount());
					}
				}else if(rec_Type.equals("2")){
					
				}else{
					throw new CommonException("暂时不支持该类型的统计查询！");
				}
			}
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		fotal.add(footer);
		jsonObject.put("footer",fotal);
		return this.JSONOBJ;
	}
	
	
	/**
	 * 网点充值统计
	 * @return
	 */
	public String queryBrchRechargeMsg(){
		String dealCode = "'30101010','30101011','30101020','30101021','30302020','30302021','30302010','30302011','30601020','30601030','30601031','30601021','30101100'";
		//30101010;//现金→钱包  30101011;//现金→钱包_撤销 30101020;//现金→联机账户 30101021;//现金→联机账户_撤销 30302020;//银行卡→钱包
		//30302010;//银行卡→联机账户 
		jsonObject.put("rows",new JSONArray());
		JSONArray footer = new JSONArray();
		JSONObject ftotal = new JSONObject();
		jsonObject.put("total","0");
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		ftotal.put("ACPT_ID","本页信息统计：");
		ftotal.put("XJ_RECHARGE_LJ_NUM", "0");
		ftotal.put("XJ_RECHARGE_LJ_AMT","0.00");
		ftotal.put("XJ_RECHARGE_LJ_CX_NUM","0");
		ftotal.put("XJ_RECHARGE_LJ_CX_AMT","0.00");
		ftotal.put("BNAK_RECHARGE_LJ_NUM","0");
		ftotal.put("BNAK_RECHARGE_LJ_AMT","0.00");
		ftotal.put("BNAK_RECHARGE_LJ_CX_NUM","0");
		ftotal.put("BNAK_RECHARGE_LJ_CX_AMT","0.00");
		ftotal.put("XJ_RECHARGE_TJ_NUM","0");
		ftotal.put("XJ_RECHARGE_TJ_AMT","0.00");
		ftotal.put("XJ_RECHARGE_TJ_CX_NUM","0");
		ftotal.put("XJ_RECHARGE_TJ_CX_AMT","0.00");
		ftotal.put("BNAK_RECHARGE_TJ_NUM","0");
		ftotal.put("BNAK_RECHARGE_TJ_AMT","0.00");
		ftotal.put("BNAK_RECHARGE_TJ_CX_NUM","0");
		ftotal.put("BNAK_RECHARGE_TJ_CX_AMT","0.00");
		ftotal.put("CORP_RECHARGE_LJ_NUM","0");
		ftotal.put("CORP_RECHARGE_LJ_AMT","0.00");
		ftotal.put("TOTAL_NUM","0");
		ftotal.put("TOTAL_AMT","0.00");
		try{
			initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sql = new StringBuffer();
				sql.append("select t.brch_id||'|'||t1.card_type seq,t.full_name ACPT_ID,(select co.code_name from sys_code co where co.code_type = 'CARD_TYPE' and co.code_Value= t1.card_type) CARD_TYPE,");
				sql.append("sum(decode(t1.deal_code,'30101020',t1.num,'0'))  XJ_RECHARGE_LJ_NUM,");//联机现金充值笔数
				sql.append("sum(decode(t1.deal_code,'30101020',t1.amt,'0'))  XJ_RECHARGE_LJ_AMT,");//联机现金充值金额
				sql.append("sum(decode(t1.deal_code,'30101021',t1.num,'0'))  XJ_RECHARGE_LJ_CX_NUM,");//联机现金充值撤销笔数
				sql.append("sum(decode(t1.deal_code,'30101021',t1.amt,'0'))  XJ_RECHARGE_LJ_CX_AMT,");//联机现金充值撤销金额
				sql.append("sum(decode(t1.deal_code,'30302010',t1.num,'0'))  BNAK_RECHARGE_LJ_NUM,");//银行卡充值联机笔数
				sql.append("sum(decode(t1.deal_code,'30302010',t1.amt,'0'))  BNAK_RECHARGE_LJ_AMT,");//银行卡充值联机笔数
				sql.append("sum(decode(t1.deal_code,'30101100',t1.num,'0'))  BATCH_RECHARGE_UR_NUM,");//批量充值未登笔数
				sql.append("sum(decode(t1.deal_code,'30101100',t1.amt,'0'))  BATCH_RECHARGE_UR_AMT,");//批量充值未登金额
				sql.append("sum(decode(t1.deal_code,'30302011',t1.num,'0'))  BNAK_RECHARGE_LJ_CX_NUM,");//银行卡→联机充值撤销笔数
				sql.append("sum(decode(t1.deal_code,'30302011',t1.amt,'0'))  BNAK_RECHARGE_LJ_CX_AMT,");//银行卡→联机充值撤销笔数
				sql.append("sum(decode(t1.deal_code,'30101010',t1.num,'0'))  XJ_RECHARGE_TJ_NUM,");//电子钱包现金充值笔数
				sql.append("sum(decode(t1.deal_code,'30101010',t1.amt,'0'))  XJ_RECHARGE_TJ_AMT,");//电子钱包现金充值金额
				sql.append("sum(decode(t1.deal_code,'30101011',t1.num,'0'))  XJ_RECHARGE_TJ_CX_NUM,");//电子钱包现金充值撤销笔数
				sql.append("sum(decode(t1.deal_code,'30101011',t1.amt,'0'))  XJ_RECHARGE_TJ_CX_AMT,");//电子钱包现金充值撤销金额
				sql.append("sum(decode(t1.deal_code,'30302020',t1.num,'0'))  BNAK_RECHARGE_TJ_NUM,");//银行卡电子钱包充值笔数
				sql.append("sum(decode(t1.deal_code,'30302020',t1.amt,'0'))  BNAK_RECHARGE_TJ_AMT,");//银行卡电子钱包充值金额
				sql.append("sum(decode(t1.deal_code,'30302021',t1.num,'0'))  BNAK_RECHARGE_TJ_CX_NUM,");//银行卡电子钱包充值撤销笔数
				sql.append("sum(decode(t1.deal_code,'30302021',t1.amt,'0'))  BNAK_RECHARGE_TJ_CX_AMT,");//银行卡电子钱包充值撤销金额
				sql.append("sum(decode(t1.deal_code,'30601020',t1.num,'30601030',t1.num,'30601021',-t1.num,'30601031',-t1.num,0))  CORP_RECHARGE_LJ_NUM,");//单位充值笔数
				sql.append("sum(decode(t1.deal_code,'30601020',t1.amt,'30601030',t1.amt,'30601021',t1.amt,'30601031',t1.amt,0))  CORP_RECHARGE_LJ_AMT,");//单位充值金额
				sql.append("(sum(decode(t1.deal_code,'30101020',t1.num,'0'))+sum(decode(t1.deal_code,'30101021',-t1.num,'0'))+"
						+ "sum(decode(t1.deal_code,'30302010',t1.num,'0'))+sum(decode(t1.deal_code,'30302011',-t1.num,'0'))+"
						+ "sum(decode(t1.deal_code,'30101010',t1.num,'0'))+sum(decode(t1.deal_code,'30101011',-t1.num,'0'))+"
						+ "sum(decode(t1.deal_code,'30302020',t1.num,'0'))+sum(decode(t1.deal_code,'30302021',-t1.num,'0'))+"
				        + "sum(decode(t1.deal_code,'30601020',t1.num,'0')) + sum(decode(t1.deal_code,'30601030',t1.num,'0')) + sum(decode(t1.deal_code,'30601021',-t1.num,'0')) + sum(decode(t1.deal_code,'30601031',-t1.num,'0')) + sum(decode(t1.deal_code,'30101100',t1.num,'0'))) TOTAL_NUM,");//总计笔数
				sql.append("(sum(decode(t1.deal_code,'30101020',t1.amt,'0'))+sum(decode(t1.deal_code,'30101021',t1.amt,'0'))+"
						+ "sum(decode(t1.deal_code,'30302010',t1.amt,'0'))+sum(decode(t1.deal_code,'30302011',t1.amt,'0'))+"
						+ "sum(decode(t1.deal_code,'30101010',t1.amt,'0'))+sum(decode(t1.deal_code,'30101011',t1.amt,'0'))+"
						+ "sum(decode(t1.deal_code,'30302020',t1.amt,'0'))+sum(decode(t1.deal_code,'30302021',t1.amt,'0')) + "
				        +"sum(decode(t1.deal_code,'30601020',t1.amt,'0')) + sum(decode(t1.deal_code,'30601030',t1.amt,'0')) + sum(decode(t1.deal_code,'30601021',t1.amt,'0')) + sum(decode(t1.deal_code,'30601031',t1.amt,'0')) + sum(decode(t1.deal_code,'30101100',t1.amt,'0')) ) TOTAL_AMT ");//总计笔数
				sql.append(" from sys_branch t, stat_card_pay t1  where t.brch_id = t1.acpt_id(+)  and t.brch_type <> 3 and t1.deal_code in ( " + dealCode +")");
				if(!Tools.processNull(org_Id).equals("")){
					sql.append(" and t1.org_Id ='"+Tools.processNull(org_Id)+"'");
				}
				
				if(!Tools.processNull(brch_Id).equals("")){
					SysBranch brch = (SysBranch)baseService.findOnlyRowByHql("from SysBranch where brchId ='"+brch_Id+"'");
					sql.append(" and  t1.acpt_id in (select a.brch_id from sys_branch a start with a.sysbranch_id = '"+brch.getSysBranchId()+"' connect by prior a.sysbranch_id = a.pid)");
				}
				if(!Tools.processNull(region_Id).equals("")){
					sql.append(" and t.region_Id ='"+Tools.processNull(region_Id)+"'");
				}
				if(!Tools.processNull(startDate).equals("")){
					sql.append(" and t1.clr_Date >='"+Tools.processNull(startDate)+"'");
				}
				if(!Tools.processNull(endDate).equals("")){
					sql.append(" and t1.clr_Date <='"+Tools.processNull(endDate)+"'");
				}
				sql.append(" group by t.brch_id,t.full_name,t1.card_type order by t.brch_id");
				Page pages = baseService.pagingQuery(sql.toString(),page,rows);
				if(pages.getAllRs() == null || pages.getAllRs().size() <= 0){
					throw new CommonException("根据指定信息未查询到充值信息！");
				}else{
					jsonObject.put("rows",pages.getAllRs());
					jsonObject.put("total",pages.getTotalCount());
					footer.add(ftotal);
					jsonObject.put("footer",footer);
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 转账统计查询
	 */
	public String querytransferStatisticsMsg(){
		try{
			initBaseDataGrid();
			if (Tools.processNull(startDate).equals("")) {
				throw new CommonException("起始日期不能为空.");
			} else if (Tools.processNull(endDate).equals("")) {
				throw new CommonException("结束日期不能为空.");
			}
			
				String sql = "select acpt_id,nvl(max(b.co_org_name), max(s.full_name)) ACPT_NAME,  "
						+ "(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.card_type) card_type, "
						+ "(select code_name from sys_code where code_type = 'ACPT_TYPE' and code_value = t.acpt_type) acpt_type,"
						+ "sum(num) tot_num, sum(amt) tot_amt "
						+ "from stat_card_pay t left join sys_branch s on s.brch_id = t.acpt_id "
						+ "left join base_co_org b on b.co_org_id = t.acpt_id "
						+ "where "
						+ " clr_date >= '" + startDate + "' and clr_date <= '" + endDate + "' ";
				if (Tools.processNull(this.deal_Code).equals("")) {
						sql += " and deal_code in (30101040, 30105030,30101050,30105040)";
				}
				if (Tools.processNull(this.deal_Code).equals("1")) {
						sql += " and deal_code in (30101040, 30105030)";
				}
				if (Tools.processNull(this.deal_Code).equals("2")) {
					sql += " and deal_code = '30101050'";
				}
				if (Tools.processNull(this.deal_Code).equals("3")) {
					sql += " and deal_code = '30105040'";
				}
				if (Tools.processNull(acptType).equals("1")) {
					sql += " and acpt_type = '1' ";
					if(!Tools.processNull(brch_Id).equals("")){
						SysBranch brch = (SysBranch) baseService.findOnlyRowByHql("from SysBranch where brchId ='" + brch_Id + "'");
						sql += "and  t.acpt_id in (select a.brch_id from sys_branch a start with a.sysbranch_id = '" + brch.getSysBranchId() + "' connect by prior a.sysbranch_id = a.pid) ";
					}
				}
				if (Tools.processNull(acptType).equals("2")) {
					sql += " and acpt_type = '2' ";
					if(!Tools.processNull(org_Id).equals("")){
						sql += " and acpt_id = '" + org_Id + "' ";
					}
				}
			sql = sql + "  group by acpt_id, card_type, acpt_type";
			sql = sql + "  order by acpt_id asc";
			Page list = baseService.pagingQuery(sql.toString(), page, rows);
			if (list.getAllRs() == null || list.getAllRs().size() < 0) {
				throw new CommonException("未查询到记录信息");
			}
			jsonObject.put("rows", list.getAllRs());
			jsonObject.put("total", list.getTotalCount());
			
			
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	
	/**
	 * 导出转账统计
	 * @return
	 */
	public String exportquerytransferStatisticsMsg(){
		try {
			querytransferStatisticsMsg();
			String fileName = "转账统计";
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 6000);
			sheet.setColumnWidth(1, 6000);
			sheet.setColumnWidth(2, 6000);
			sheet.setColumnWidth(3, 6000);
			sheet.setColumnWidth(4, 6000);

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
			int maxColumn = 6;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			// second header
			sheet.getRow(1).getCell(0).setCellValue("业务时间：" + startDate + " ~ " + endDate + "    导出时间：" + DateUtils.getNowTime());
			
			// third header
			sheet.getRow(2).getCell(0).setCellValue("受理点编号");
			sheet.getRow(2).getCell(1).setCellValue("受理点名称");
			sheet.getRow(2).getCell(2).setCellValue("受理点类型");
			sheet.getRow(2).getCell(3).setCellValue("卡类型");
			sheet.getRow(2).getCell(4).setCellValue("笔数");
			sheet.getRow(2).getCell(5).setCellValue("金额");
			
			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(0, 3);
			int numSum = 0;
			double amtSum = 0;
			for (int i = 0; i < data.size(); i++) {
				JSONObject item = data.getJSONObject(i);
				
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j == 5) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				row.getCell(0).setCellValue(item.getString("ACPT_ID"));
				row.getCell(1).setCellValue(item.getString("ACPT_NAME"));
				row.getCell(2).setCellValue(item.getString("ACPT_TYPE"));
				row.getCell(3).setCellValue(item.getString("CARD_TYPE"));
				row.getCell(4).setCellValue(item.getIntValue("TOT_NUM"));
				row.getCell(5).setCellValue(item.getDoubleValue("TOT_AMT") / 100);
				
				numSum += item.getIntValue("TOT_NUM");
				amtSum += item.getDoubleValue("TOT_AMT");
			}
			
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if (j == 5) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(4).setCellValue("共 " + numSum + " 笔");
			row.getCell(5).setCellValue(amtSum / 100);
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
	
	
	/**
	 * 充值情况统计导出
	 * Description <p>TODO</p>
	 * @throws Exception
	 */
	public String exportToExcelRechargeMsg(){
		String dealCode = "'30101010','30101011','30101020','30101021','30302020','30302021','30302010','30302011','30601020','30601030','30601021','30601031','30101100'";
		try {
			HttpSession session = request.getSession();
			id = (String) session.getAttribute("exportParams");
			session.removeAttribute("exportParams");
			StringBuffer sql = new StringBuffer();
			sql.append("select t.brch_id||'|'||t1.card_type seq,t.full_name ACPT_ID,(select co.code_name from sys_code co where co.code_type = 'CARD_TYPE' and co.code_Value= t1.card_type) CARD_TYPE,");
			sql.append("sum(decode(t1.deal_code,'30101020',t1.num,'30101021',-t1.num,'30302010',t1.num,'30302011',-t1.num,'30601030',t1.num,'30601020',t1.num,'30601031',-t1.num,'30601021',-t1.num,0)) XJ_RECHARGE_LJ_NUM,");//联机现金充值笔数
			sql.append("trim(to_char(sum(decode(t1.deal_code,'30101020',t1.amt,'30101021',t1.amt,'30302010',t1.amt,'30302011',t1.amt,'30601020',t1.amt,'30601030',t1.amt,'30601031',t1.amt,'30601021',t1.amt,0)/100),'999,999,999,990.99'))  XJ_RECHARGE_LJ_AMT,");//联机现金充值金额
			sql.append("sum(decode(t1.deal_code,'30101010',t1.num,'30101011',-t1.num,'30302020',t1.num,'30302021',-t1.num,'0')) XJ_RECHARGE_TJ_NUM,");//电子钱包现金充值笔数
			sql.append("trim(to_char(sum(decode(t1.deal_code,'30101010',t1.amt,'30101011',t1.amt,'30302020',t1.amt,'30302021',t1.amt,'0')/100),'999,999,999,990.99'))  XJ_RECHARGE_TJ_AMT,");//电子钱包现金充值金额
			sql.append("sum(decode(t1.deal_code,'30101100',t1.num, '0')) XJ_RECHARGE_UR_NUM,");//未登充值笔数
			sql.append("trim(to_char(sum(decode(t1.deal_code,'30101100',t1.amt, '0')/100),'999,999,999,990.99'))  XJ_RECHARGE_UR_AMT,");//未登充值金额
			//sql.append("sum(decode(t1.deal_code,'90409040',t1.num,0)) CORP_RECHARGE_LJ_NUM,");//单位账户充值笔数
			//sql.append("trim(to_char(sum(decode(t1.deal_code,'90409040',t1.amt,0)/100),'999,999,999,990.99'))  CORP_RECHARGE_LJ_AMT,");//单位账户充值金额
			sql.append("(sum(decode(t1.deal_code,'30101020',t1.num,'0'))+sum(decode(t1.deal_code,'30101021',-t1.num,'0'))+"
					+ "sum(decode(t1.deal_code,'30302010',t1.num,'0'))+sum(decode(t1.deal_code,'30302011',-t1.num,'0'))+"
					+ "sum(decode(t1.deal_code,'30101010',t1.num,'0'))+sum(decode(t1.deal_code,'30101011',-t1.num,'0'))+"
					+ "sum(decode(t1.deal_code,'30302020',t1.num,'0'))+sum(decode(t1.deal_code,'30302021',-t1.num,'0')) + sum(decode(t1.deal_code,'30601020',t1.num,'0')) + sum(decode(t1.deal_code,'30601030',t1.num,'0')) + sum(decode(t1.deal_code,'30101100',t1.num,'0'))) TOTAL_NUM,");//总计笔数
			sql.append("trim(to_char((sum(decode(t1.deal_code,'30101020',t1.amt,'0'))+sum(decode(t1.deal_code,'30101021',t1.amt,'0'))+"
					+ "sum(decode(t1.deal_code,'30302010',t1.amt,'0'))+sum(decode(t1.deal_code,'30302011',t1.amt,'0'))+"
					+ "sum(decode(t1.deal_code,'30101010',t1.amt,'0'))+sum(decode(t1.deal_code,'30101011',t1.amt,'0'))+"
					+ "sum(decode(t1.deal_code,'30302020',t1.amt,'0'))+sum(decode(t1.deal_code,'30302021',t1.amt,'0')) + sum(decode(t1.deal_code,'30601020',t1.amt,0)) + sum(decode(t1.deal_code,'30601030',t1.amt,0)) + sum(decode(t1.deal_code,'30101100',t1.amt,0)))/100,'999,999,999,990.99')) TOTAL_AMT ");//总计笔数
			sql.append(" from sys_branch t, stat_card_pay t1  where t.brch_id = t1.acpt_id(+)  and t.brch_type <> 3 and t1.deal_code in ( "
					+ dealCode +")");
			if(!Tools.processNull(org_Id).equals("")){
				sql.append(" and t1.org_Id ='"+Tools.processNull(org_Id)+"'");
			}
			
			if(!Tools.processNull(brch_Id).equals("")){
				SysBranch brch = (SysBranch)baseService.findOnlyRowByHql("from SysBranch where brchId ='"+brch_Id+"'");
				sql.append(" and  t1.acpt_id in (select a.brch_id from sys_branch a start with a.sysbranch_id = '"+brch.getSysBranchId()+"' connect by prior a.sysbranch_id = a.pid)");
			}
			if(!Tools.processNull(region_Id).equals("")){
				sql.append(" and t.region_Id ='"+Tools.processNull(region_Id)+"'");
			}
			if(!Tools.processNull(startDate).equals("")){
				sql.append(" and t1.clr_Date >='"+Tools.processNull(startDate)+"'");
			}
			if(!Tools.processNull(endDate).equals("")){
				sql.append(" and t1.clr_Date <='"+Tools.processNull(endDate)+"'");
			}
			sql.append(" and t.brch_id || '|' || t1.card_type in (" + id + ")");
			sql.append(" group by t.brch_id,t.full_name,t1.card_type order by t.brch_id");
			List dataList = baseService.findBySql(sql.toString());
			
			String title = "充值情况统计报表";
			HSSFWorkbook workbook = new HSSFWorkbook();
			HSSFSheet sheet = workbook.createSheet(title);
			sheet.setFitToPage(true);
			
			HSSFCellStyle titleCellStyle = (HSSFCellStyle)this.getCellStyleOfTitle(workbook);
			
			HSSFCellStyle headerCellStyle = (HSSFCellStyle)this.getCellStyleOfHeader(workbook);
			headerCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);
			headerCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);
			headerCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);
			headerCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);
			HSSFCellStyle dateCellStyle = (HSSFCellStyle)this.getCellStyleOfDateColumn(workbook);
			dateCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);
			HSSFCellStyle dataCellStyle = (HSSFCellStyle)this.getCellStyleOfData(workbook);
			dataCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);
			dataCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);
			dataCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);
			dataCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);
			// 标题合并单元格
			sheet.createFreezePane(2,4);
			CellRangeAddress titleregion = new CellRangeAddress(0, 0, 0, 9);
			sheet.addMergedRegion(titleregion);
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, 9));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 1, 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 2, 3));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 4, 5));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 6, 7));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 8, 9));
			//标题数据
			HSSFRow titleRow = sheet.createRow(0);
			for(int c=0;c<10;c++){
				if (c == 0) {
					Cell cell = titleRow.createCell(c);
					cell.setCellStyle(titleCellStyle);
					cell.setCellValue(title);
				} else {
					titleRow.createCell(c).setCellStyle(titleCellStyle);
				}
			}
			
			
			HSSFRow dateRow = sheet.createRow(1);
			String startAndEndDate = "select max(clr_date), min(clr_date) from stat_card_pay t1 where t1.deal_code in ( "
					+ dealCode +") and t1.acpt_id||'|'||t1.card_type in("+id+")";
			if(!Tools.processNull(startDate).equals("")){
				startAndEndDate += " and t1.clr_Date >='"+Tools.processNull(startDate)+"'";
			}
			if(!Tools.processNull(endDate).equals("")){
				startAndEndDate += " and t1.clr_Date <='"+Tools.processNull(endDate)+"'";
			}
			List dateInfo = baseService.findBySql(startAndEndDate);
			Object[]  dataArray = (Object[])dateInfo.get(0);
			for(int c=0;c<8;c++){
				if (c == 0) {
					Cell cell = dateRow.createCell(c);
					cell.setCellStyle(dateCellStyle);
					cell.setCellValue("业务时间："+ Tools.processNull(dataArray[1])+ " ~ " + Tools.processNull(dataArray[0]) + "    导出时间：" + DateUtils.getNowTime());
				} else {
					dateRow.createCell(c).setCellStyle(dateCellStyle);
				}
			}
			
			HSSFRow titleTwo = sheet.createRow(2);
			Cell oneCell = titleTwo.createCell(0);
			oneCell.setCellValue("受理点");
			oneCell.setCellStyle(headerCellStyle);
			
			Cell twoCell = titleTwo.createCell(1);
			twoCell.setCellValue("卡类型");
			twoCell.setCellStyle(headerCellStyle);
			
			Cell threeCell = titleTwo.createCell(2);
			threeCell.setCellStyle(headerCellStyle);
			threeCell.setCellValue("联机账户");
			
			Cell fourCell = titleTwo.createCell(4);
			fourCell.setCellStyle(headerCellStyle);
			fourCell.setCellValue("电子钱包");
			
			Cell sixCell = titleTwo.createCell(6);
			sixCell.setCellStyle(headerCellStyle);
			sixCell.setCellValue("未登账户");
			
			Cell eightCell = titleTwo.createCell(8);
			eightCell.setCellStyle(headerCellStyle);
			eightCell.setCellValue("合计");
			
			Cell nineCell = titleTwo.createCell(9);
			nineCell.setCellStyle(headerCellStyle);
			
			HSSFRow titleThree = sheet.createRow(3);
			Cell cell30 = titleThree.createCell(0);
			Cell cell311 = titleThree.createCell(1);
			cell30.setCellStyle(headerCellStyle);
			cell311.setCellStyle(headerCellStyle);
			Cell cell31 = titleThree.createCell(2);
			cell31.setCellStyle(headerCellStyle);
			cell31.setCellValue("笔数");
			Cell cell32 = titleThree.createCell(3);
			cell32.setCellStyle(headerCellStyle);
			cell32.setCellValue("金额小计");
			Cell cell33 = titleThree.createCell(4);
			cell33.setCellStyle(headerCellStyle);
			cell33.setCellValue("笔数");
			Cell cell34 = titleThree.createCell(5);
			cell34.setCellStyle(headerCellStyle);
			cell34.setCellValue("金额小计");
			
			Cell cell36 = titleThree.createCell(6);
			cell36.setCellStyle(headerCellStyle);
			cell36.setCellValue("笔数");
			Cell cell37 = titleThree.createCell(7);
			cell37.setCellStyle(headerCellStyle);
			cell37.setCellValue("金额小计");
			
			Cell cell38 = titleThree.createCell(8);
			cell38.setCellStyle(headerCellStyle);
			cell38.setCellValue("合计笔数");
			Cell cell39 = titleThree.createCell(9);
			cell39.setCellStyle(headerCellStyle);
			cell39.setCellValue("合计金额");
			
			//开始进行数据的组装
			int dataRowIndex = 4;//第5行开始是数据行
			String fullNameTemp = "";
			for (int i = 0; i < dataList.size(); i++) {
				Object[] objdata  = (Object[])dataList.get(i);
				HSSFRow row = sheet.createRow(dataRowIndex);
				Cell fullNameCell = row.createCell(0);
				fullNameCell.setCellStyle(dataCellStyle);
				String fullName = Tools.processNull(objdata[1]);
				fullNameCell.setCellValue(fullName);
				Cell cardTypeCell = row.createCell(1);
				cardTypeCell.setCellStyle(dataCellStyle);
				String cardType = Tools.processNull(objdata[2]);
				cardTypeCell.setCellValue(cardType);
				if (fullNameTemp.equals(fullName)) {
					sheet.addMergedRegion(new CellRangeAddress(dataRowIndex - 1, dataRowIndex, 0, 0));
				}
				fullNameTemp = fullName;
				//开始处理数据
				for (int j = 2; j < 10; j++) {
					int k = j + 1;
					Cell name = row.createCell(j);
					name.setCellStyle(dataCellStyle);
					name.setCellValue(Tools.processNull(objdata[k]));
				}
				dataRowIndex++;
			}
			
			sheet.autoSizeColumn(0, true);
			sheet.autoSizeColumn(1, true);
			StringBuffer TotalSum = new StringBuffer();
			TotalSum.append("select sum(decode(t1.deal_code,'30101020',t1.num,'30101021',-t1.num,'30302010',t1.num,'30302011',-t1.num,'30601020',t1.num,'30601030',t1.num,'30601021',-t1.num,'30601031',-t1.num,'0')) XJ_RECHARGE_LJ_NUM,");//联机现金充值笔数
			TotalSum.append("trim(to_char(sum(decode(t1.deal_code,'30101020',t1.amt,'30101021',t1.amt,'30302010',t1.amt,'30302011',t1.amt,'30601020',t1.amt,'30601030',t1.amt,'30601021',t1.amt,'30601031',t1.amt,'0'))/100, '9,999,999,990.00'))  XJ_RECHARGE_LJ_AMT,");//联机现金充值金额
			TotalSum.append("sum(decode(t1.deal_code,'30101010',t1.num,'30101011',-t1.num,'30302020',t1.num,'30302021',-t1.num,'0')) XJ_RECHARGE_TJ_NUM,");//电子钱包现金充值笔数
			TotalSum.append("trim(to_char(sum(decode(t1.deal_code,'30101010',t1.amt,'30101011',t1.amt,'30302020',t1.amt,'30302021',t1.amt,'0'))/100, '9,999,999,990.00'))  XJ_RECHARGE_TJ_AMT,");//电子钱包现金充值金额
			//TotalSum.append("sum(decode(t1.deal_code,'90409040','0')) CORP_RECHARGE_LJ_NUM,");//单位充值笔数
			//TotalSum.append("trim(to_char(sum(decode(t1.deal_code,'90409040',t1.amt,0))/100, '9,999,999,990.00'))  CORP_RECHARGE_LJ_AMT,");//单位充值金额
			TotalSum.append("sum(decode(t1.deal_code,'30101100',t1.num, '0')) XJ_RECHARGE_UR_NUM,");//未登充值笔数
			TotalSum.append("trim(to_char(sum(decode(t1.deal_code,'30101100',t1.amt, '0')/100),'999,999,999,990.99'))  XJ_RECHARGE_UR_AMT,");//未登充值金额
			TotalSum.append("(sum(decode(t1.deal_code,'30101020',t1.num,'0'))+sum(decode(t1.deal_code,'30101021',-t1.num,'0'))+"
					+ "sum(decode(t1.deal_code,'30302010',t1.num,'0'))+sum(decode(t1.deal_code,'30302011',-t1.num,'0'))+"
					+ "sum(decode(t1.deal_code,'30101010',t1.num,'0'))+sum(decode(t1.deal_code,'30101011',-t1.num,'0'))+"
					+ "sum(decode(t1.deal_code,'30302020',t1.num,'0'))+sum(decode(t1.deal_code,'30302021',-t1.num,'0')) + sum(decode(t1.deal_code,'30601020',t1.num,'0')) + sum(decode(t1.deal_code,'30601030',t1.num,'0')) - sum(decode(t1.deal_code,'30601021',t1.num,'0')) - sum(decode(t1.deal_code,'30601031',t1.num,'0')) + sum(decode(t1.deal_code,'30101100',t1.num,'0'))) TOTAL_NUM,");//总计笔数
			TotalSum.append("trim(to_char((sum(decode(t1.deal_code,'30101020',t1.amt,'0')) + sum(decode(t1.deal_code,'30101021',t1.amt,'0')) + "
					+ "sum(decode(t1.deal_code,'30302010',t1.amt,'0'))+sum(decode(t1.deal_code,'30302011',t1.amt,'0'))+"
					+ "sum(decode(t1.deal_code,'30101010',t1.amt,'0'))+sum(decode(t1.deal_code,'30101011',t1.amt,'0'))+"
					+ "sum(decode(t1.deal_code,'30302020',t1.amt,'0'))+sum(decode(t1.deal_code,'30302021',t1.amt,'0')) + sum(decode(t1.deal_code,'30601020',t1.amt,'0'))+ sum(decode(t1.deal_code,'30601030',t1.amt,'0'))+ sum(decode(t1.deal_code,'30601021',t1.amt,'0'))+ sum(decode(t1.deal_code,'30601031',t1.amt,'0'))+ sum(decode(t1.deal_code,'30101100',t1.amt,'0')))/100, '9,999,999,990.00')) TOTAL_AMT ");//总计笔数
			TotalSum.append(" from sys_branch t, stat_card_pay t1  where t.brch_id = t1.acpt_id(+)  and t.brch_type <> 3 and t1.deal_code in ( "
					+ dealCode +")");
			TotalSum.append(" and t.brch_id||'|'||t1.card_type in("+id+")");
			if(!Tools.processNull(org_Id).equals("")){
				TotalSum.append(" and t1.org_Id ='"+Tools.processNull(org_Id)+"'");
			}
			if(!Tools.processNull(brch_Id).equals("")){
				SysBranch brch = (SysBranch)baseService.findOnlyRowByHql("from SysBranch where brchId ='"+brch_Id+"'");
				TotalSum.append(" and  t1.acpt_id in (select a.brch_id from sys_branch a start with a.sysbranch_id = '"+brch.getSysBranchId()+"' connect by prior a.sysbranch_id = a.pid)");
			}
			if(!Tools.processNull(region_Id).equals("")){
				TotalSum.append(" and t.region_Id ='"+Tools.processNull(region_Id)+"'");
			}
			if(!Tools.processNull(startDate).equals("")){
				TotalSum.append(" and t1.clr_Date >='"+Tools.processNull(startDate)+"'");
			}
			if(!Tools.processNull(endDate).equals("")){
				TotalSum.append(" and t1.clr_Date <='"+Tools.processNull(endDate)+"'");
			}
			List totalList = baseService.findBySql(TotalSum.toString());
			System.out.println(TotalSum);
			//创建合计列
			sheet.addMergedRegion(new CellRangeAddress(dataRowIndex, dataRowIndex, 0, 1));
			HSSFRow row = sheet.createRow(dataRowIndex);
			Cell totalCell  = row.createCell(0);
			totalCell.setCellStyle(dataCellStyle);
			totalCell.setCellValue("合计");
			row.createCell(1).setCellStyle(dataCellStyle);
			Object[] totalArray = (Object[])totalList.get(0);
			for(int h = 0; h< totalArray.length ; h++){
				int h1 = h + 2;
				Cell totalName = row.createCell(h1);
				totalName.setCellStyle(dataCellStyle);
				totalName.setCellValue(Tools.processNull(totalArray[h]));
			}
			
			
			HttpServletResponse response = ServletActionContext.getResponse();
			String fileName = "充值情况统计报表";
			response.setContentType("application/ms-excel;charset=utf-8");
		    response.setHeader("Content-disposition", "attachment; filename="+ URLEncoder.encode(fileName,"UTF8") + ".xls");
		    OutputStream out = response.getOutputStream();
		    workbook.write(out);
		    out.close();
		} catch (Exception e) {
			e.printStackTrace();
			this.saveErrLog(e);
		}
		return null;
	}
	
	public String RealTimeRechargeMsgSearch(){
		/*String dealCode = "'30101010','30101011','30101020','30101021','30302020','30302021','30302010','30302011','30601020','30601030','30601021','30601031','30101100'";
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total","0");
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");*/
		try {
			initGrid();
			HttpSession session = request.getSession();
			id = (String) session.getAttribute("exportParams");
			session.removeAttribute("exportParams");
			StringBuffer sql = new StringBuffer();
			sql.append("select t.brch_id || '|' || card_type seq, t.full_name ACPT_ID,");
			sql.append("(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t2.card_type) card_type, ");
			sql.append("nvl(sum(decode(t2.deal_code,'30101020',1,'0')), 0) XJ_RECHARGE_LJ_NUM, ");//联机现金充值笔数
			sql.append("nvl(sum(decode(t2.deal_code,'30101020',t2.amt,'0')), 0) XJ_RECHARGE_LJ_AMT, ");//联机现金充值金额
			sql.append("nvl(sum(decode(t2.deal_code,'30101021',1,'0')), 0) XJ_RECHARGE_LJ_CX_NUM, ");//联机现金充值撤销笔数
			sql.append("nvl(sum(decode(t2.deal_code,'30101021',t2.amt,'0')), 0) XJ_RECHARGE_LJ_CX_AMT, ");//联机现金充值撤销金额
			sql.append("nvl(sum(decode(t2.deal_code,'30302010',1,'0')), 0) BNAK_RECHARGE_LJ_NUM, ");//银行卡充值笔数
			sql.append("nvl(sum(decode(t2.deal_code,'30302010',t2.amt,'0')), 0) BNAK_RECHARGE_LJ_AMT, ");//银行卡充值金额
			sql.append("nvl(sum(decode(t2.deal_code,'30302011',1,'0')), 0) BNAK_RECHARGE_LJ_CX_NUM, ");//银行卡充值撤销笔数
			sql.append("nvl(sum(decode(t2.deal_code,'30302011',t2.amt,'0')), 0) BNAK_RECHARGE_LJ_CX_AMT, ");//银行卡充值撤销金额
			sql.append("nvl(sum(decode(t2.deal_code,'30101010',1,'0')), 0) XJ_RECHARGE_TJ_NUM, ");//电子钱包现金充值笔数
			sql.append("nvl(sum(decode(t2.deal_code,'30101010',t2.amt,'0')), 0) XJ_RECHARGE_TJ_AMT, ");//电子钱包现金充值金额
			sql.append("nvl(sum(decode(t2.deal_code,'30101011',1,'0')), 0) XJ_RECHARGE_TJ_CX_NUM, ");//电子钱包现金充值撤销笔数
			sql.append("nvl(sum(decode(t2.deal_code,'30101011',t2.amt,'0')), 0) XJ_RECHARGE_TJ_CX_AMT, ");//电子钱包现金充值撤销金额
			sql.append("nvl(sum(decode(t2.deal_code,'30302020',1,'0')), 0) BNAK_RECHARGE_TJ_NUM, ");//电子钱包银行充值笔数
			sql.append("nvl(sum(decode(t2.deal_code,'30302020',t2.amt,'0')), 0) BNAK_RECHARGE_TJ_AMT, ");//子钱包银行充值金额
			sql.append("nvl(sum(decode(t2.deal_code,'30302021',1,'0')), 0) BNAK_RECHARGE_TJ_CX_NUM, ");//电子钱包银行充值撤销笔数
			sql.append("nvl(sum(decode(t2.deal_code,'30302021',t2.amt,'0')), 0) BNAK_RECHARGE_TJ_CX_AMT, ");//电子钱包银行充值撤销金额
			sql.append("nvl(sum(decode(t2.deal_code,'30601020',1,'30601030',1,'30601021',-1,'30601031',-1,0)), 0) CORP_RECHARGE_LJ_NUM, ");//联机账户批量笔数
			sql.append("nvl(sum(decode(t2.deal_code,'30601020',t2.amt,'30601030',t2.amt,'30601021',t2.amt,'30601031',t2.amt,0)), 0) CORP_RECHARGE_LJ_AMT, ");//联机账户批量金额
			sql.append("nvl(sum(decode(t2.deal_code,'30101100',1,'0')), 0) BATCH_RECHARGE_UR_NUM, ");//未登账户批量笔数
			sql.append("nvl(sum(decode(t2.deal_code,'30101100',t2.amt,'0')), 0) BATCH_RECHARGE_UR_AMT ");//未登账户批量金额
			sql.append("from sys_branch t left join pay_card_deal_rec_" + DateUtil.formatDate(new Date(), "yyyyMM") + " t2 on t.brch_id = t2.acpt_id " + "where 1 = 1 ");
			if(!Tools.processNull(org_Id).equals("")){
				sql.append("and t2.org_Id ='" + org_Id + "' ");
			}
			
			if(!Tools.processNull(brch_Id).equals("")){
				SysBranch brch = (SysBranch)baseService.findOnlyRowByHql("from SysBranch where brchId ='" + brch_Id + "'");
				sql.append("and  t2.acpt_id in (select a.brch_id from sys_branch a start with a.sysbranch_id = '" + brch.getSysBranchId() + "' connect by prior a.sysbranch_id = a.pid) ");
			}
			
			if(!Tools.processNull(region_Id).equals("")){
				sql.append("and t.region_Id ='" + region_Id + "' ");
			}
			if(!Tools.processNull(startDate).equals("")){
				sql.append("and t2.deal_date >= to_date('" + startDate + "', 'yyyy-mm-dd hh24:mi:ss') ");
			}
			if(!Tools.processNull(endDate).equals("")){
				sql.append("and t2.deal_date <= to_date('" + endDate + "', 'yyyy-mm-dd hh24:mi:ss') ");
			}
			sql.append(" and t.brch_id || '|' || card_type in (" + id + ")");
			sql.append("group by t.brch_id, t.full_name, t2.card_type ");
			sql.append("order by t.brch_id");
			Page dataList = baseService.pagingQuery(sql.toString(),page,rows);
			jsonObject.put("rows",dataList.getAllRs());
			jsonObject.put("total",dataList.getTotalCount());
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	
	/**
	 * 网点充值实时情况统计导出
	 * Description <p>TODO</p>
	 * @throws Exception
	 */
	public String exportToExcelRealTimeRechargeMsg(){
		try {
			RealTimeRechargeMsgSearch();
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			String title = "实时充值情况统计报表";
			HSSFWorkbook workbook = new HSSFWorkbook();
			HSSFSheet sheet = workbook.createSheet(title);
			sheet.setColumnWidth(0, 6000);
			sheet.setColumnWidth(1, 6000);
			int maxColumn = 28;
			
			sheet.setColumnWidth(maxColumn - 26, 3000);
			sheet.setColumnWidth(maxColumn - 25, 3000);
			sheet.setColumnWidth(maxColumn - 24, 3000);
			sheet.setColumnWidth(maxColumn - 23, 3000);
			sheet.setColumnWidth(maxColumn - 22, 3000);
			sheet.setColumnWidth(maxColumn - 21, 3000);
			sheet.setColumnWidth(maxColumn - 20, 3000);
			sheet.setColumnWidth(maxColumn - 19, 3000);
			sheet.setColumnWidth(maxColumn - 18, 3000);
			sheet.setColumnWidth(maxColumn - 17, 3000);
			sheet.setColumnWidth(maxColumn - 16, 3000);
			sheet.setColumnWidth(maxColumn - 15, 3000);
			sheet.setColumnWidth(maxColumn - 14, 3000);
			sheet.setColumnWidth(maxColumn - 13, 3000);
			sheet.setColumnWidth(maxColumn - 12, 3000);
			sheet.setColumnWidth(maxColumn - 11, 3000);
			sheet.setColumnWidth(maxColumn - 10, 3000);
			sheet.setColumnWidth(maxColumn - 9, 3000);
			sheet.setColumnWidth(maxColumn - 8, 3000);
			sheet.setColumnWidth(maxColumn - 7, 3000);
			sheet.setColumnWidth(maxColumn - 6, 3000);
			sheet.setColumnWidth(maxColumn - 5, 3000);
			sheet.setColumnWidth(maxColumn - 4, 3000);
			sheet.setColumnWidth(maxColumn - 3, 3000);
			sheet.setColumnWidth(maxColumn - 2, 3000);
			sheet.setColumnWidth(maxColumn - 1, 3000);

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
			int headRows = 6;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue("实时充值情况统计报表");
			
			sheet.getRow(1).getCell(0).setCellValue("统计时间：" + startDate + " ~ " + endDate + "    导出时间：" + DateUtils.getNowTime());

			// second header
			sheet.getRow(2).getCell(0).setCellValue("受理点");
			sheet.getRow(2).getCell(1).setCellValue("卡类型");
			sheet.getRow(2).getCell(maxColumn - 2).setCellValue("总计");
			
			// third header
			sheet.getRow(2).getCell(maxColumn - 26).setCellValue("联机账户");
			sheet.getRow(2).getCell(maxColumn - 14).setCellValue("电子钱包");
			sheet.getRow(2).getCell(maxColumn - 4).setCellValue("未登账户");
			
			// fourth header
			sheet.getRow(4).getCell(maxColumn - 26).setCellValue("现金充值");
			sheet.getRow(4).getCell(maxColumn - 24).setCellValue("现金充值撤销");
			sheet.getRow(4).getCell(maxColumn - 22).setCellValue("银行卡");
			sheet.getRow(4).getCell(maxColumn - 20).setCellValue("银行卡充值撤销");
			sheet.getRow(4).getCell(maxColumn - 18).setCellValue("批量充值");
			sheet.getRow(4).getCell(maxColumn - 16).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 14).setCellValue("现金充值");
			sheet.getRow(4).getCell(maxColumn - 12).setCellValue("现金充值撤销");
			sheet.getRow(4).getCell(maxColumn - 10).setCellValue("银行卡");
			sheet.getRow(4).getCell(maxColumn - 8).setCellValue("银行卡充值撤销");
			sheet.getRow(4).getCell(maxColumn - 6).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 4).setCellValue("批量充值");
			sheet.getRow(4).getCell(maxColumn - 2).setCellValue("合计笔数");
			sheet.getRow(4).getCell(maxColumn - 1).setCellValue("合计金额");
			
			// fifth header
			//
			sheet.getRow(5).getCell(maxColumn - 26).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 25).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 24).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 23).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 22).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 21).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 20).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 19).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 18).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 17).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 16).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 15).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 14).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 13).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 12).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 11).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 10).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 9).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 8).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 7).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 6).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 5).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 4).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 3).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 2).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 1).setCellValue("金额");

			// Merge
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 0, 0));//受理点
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 1, 1));//卡类型
			sheet.addMergedRegion(new CellRangeAddress(2, 4, maxColumn - 2, maxColumn - 1));//总计
			sheet.addMergedRegion(new CellRangeAddress(2, 3, maxColumn - 26, maxColumn - 15));//联机账户
			sheet.addMergedRegion(new CellRangeAddress(2, 3, maxColumn - 14, maxColumn - 5));//电子钱包
			sheet.addMergedRegion(new CellRangeAddress(2, 3, maxColumn - 4, maxColumn - 3));//未登账户
			//
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 26, maxColumn - 25));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 24, maxColumn - 23));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 22, maxColumn - 21));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 20, maxColumn - 19));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 18, maxColumn - 17));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 16, maxColumn - 15));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 14, maxColumn - 13));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 12, maxColumn - 11));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 10, maxColumn - 9));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 8, maxColumn - 7));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 6, maxColumn - 5));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 4, maxColumn - 3));
			
			int numSum = 0;
			int XJ_RECHARGE_LJ_NUM = 0;
			double XJ_RECHARGE_LJ_AMT = 0;
			
			int XJ_RECHARGE_LJ_CX_NUM = 0;
			double XJ_RECHARGE_LJ_CX_AMT = 0;
			
			int BNAK_RECHARGE_LJ_NUM = 0;
			double BNAK_RECHARGE_LJ_AMT = 0;
			//
			int BNAK_RECHARGE_LJ_CX_NUM = 0;
			double BNAK_RECHARGE_LJ_CX_AMT = 0;
			
			int XJ_RECHARGE_TJ_NUM = 0;
			double XJ_RECHARGE_TJ_AMT = 0;
			
			int XJ_RECHARGE_TJ_CX_NUM = 0;
			double XJ_RECHARGE_TJ_CX_AMT = 0;
			//
			int BNAK_RECHARGE_TJ_NUM = 0;
			double BNAK_RECHARGE_TJ_AMT = 0;
			
			int BNAK_RECHARGE_TJ_CX_NUM = 0;
			double BNAK_RECHARGE_TJ_CX_AMT = 0;
			
			int CORP_RECHARGE_LJ_NUM = 0;
			double CORP_RECHARGE_LJ_AMT = 0;
			//
			int BATCH_RECHARGE_UR_NUM = 0;
			double BATCH_RECHARGE_UR_AMT = 0;
			//
			int TOTAL_NUM = 0;
			double TOTAL_AMT = 0;
			
			int LJ_TOT_NUM = 0;
			double LJ_TOT_AMT = 0;
			
			int TJ_TOT_NUM = 0;
			double TJ_TOT_AMT = 0;
			//
			for (int i = 0; i < data.size(); i++, numSum++) {
				JSONObject item = (JSONObject) data.get(i);
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j > 2 && j % 2 == 1) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				row.getCell(0).setCellValue(item.getString("ACPT_ID"));
				row.getCell(1).setCellValue(item.getString("CARD_TYPE"));
				
				
				row.getCell(maxColumn - 26).setCellValue(item.getIntValue("XJ_RECHARGE_LJ_NUM"));//现金充值笔数
				XJ_RECHARGE_LJ_NUM += item.getIntValue("XJ_RECHARGE_LJ_NUM");
				row.getCell(maxColumn - 25).setCellValue(item.getDoubleValue("XJ_RECHARGE_LJ_AMT") / 100);//现金充值金额
				System.out.println(item.getDoubleValue("XJ_RECHARGE_LJ_AMT"));
				XJ_RECHARGE_LJ_AMT += item.getDoubleValue("XJ_RECHARGE_LJ_AMT");
				
				row.getCell(maxColumn - 24).setCellValue(item.getIntValue("XJ_RECHARGE_LJ_CX_NUM"));//现金充值撤销笔数
				XJ_RECHARGE_LJ_CX_NUM += item.getIntValue("XJ_RECHARGE_LJ_CX_NUM");
				row.getCell(maxColumn - 23).setCellValue(item.getDoubleValue("XJ_RECHARGE_LJ_CX_AMT") / 100);//现金充值撤销金额
				XJ_RECHARGE_LJ_CX_AMT += item.getDoubleValue("XJ_RECHARGE_LJ_CX_AMT");
				
				row.getCell(maxColumn - 22).setCellValue(item.getIntValue("BNAK_RECHARGE_LJ_NUM"));//银行卡笔数
				BNAK_RECHARGE_LJ_NUM += item.getIntValue("BNAK_RECHARGE_LJ_NUM");
				row.getCell(maxColumn - 21).setCellValue(item.getDoubleValue("BNAK_RECHARGE_LJ_AMT") / 100);//银行卡金额
				BNAK_RECHARGE_LJ_AMT += item.getDoubleValue("BNAK_RECHARGE_LJ_AMT");
				
				row.getCell(maxColumn - 20).setCellValue(item.getIntValue("BNAK_RECHARGE_LJ_CX_NUM"));//银行卡撤销笔数
				BNAK_RECHARGE_LJ_CX_NUM += item.getIntValue("BNAK_RECHARGE_LJ_CX_NUM");
				row.getCell(maxColumn - 19).setCellValue(item.getDoubleValue("BNAK_RECHARGE_LJ_CX_AMT") / 100);//银行卡撤销金额
				BNAK_RECHARGE_LJ_CX_AMT += item.getDoubleValue("BNAK_RECHARGE_LJ_CX_AMT");
				
				row.getCell(maxColumn - 18).setCellValue(item.getIntValue("CORP_RECHARGE_LJ_NUM"));//批量充值笔数
				CORP_RECHARGE_LJ_NUM += item.getIntValue("CORP_RECHARGE_LJ_NUM");
				row.getCell(maxColumn - 17).setCellValue(item.getDoubleValue("CORP_RECHARGE_LJ_AMT") / 100);//批量充值金额
				CORP_RECHARGE_LJ_AMT += item.getDoubleValue("CORP_RECHARGE_LJ_AMT");
				//小计笔数
				row.getCell(maxColumn - 16).setCellValue(item.getIntValue("XJ_RECHARGE_LJ_NUM") - item.getIntValue("XJ_RECHARGE_LJ_CX_NUM") + item.getIntValue("BNAK_RECHARGE_LJ_NUM") - item.getIntValue("BNAK_RECHARGE_LJ_CX_NUM") + item.getIntValue("CORP_RECHARGE_LJ_NUM"));//小计笔数
				LJ_TOT_NUM += item.getIntValue("XJ_RECHARGE_LJ_NUM") - item.getIntValue("XJ_RECHARGE_LJ_CX_NUM") + item.getIntValue("BNAK_RECHARGE_LJ_NUM") - item.getIntValue("BNAK_RECHARGE_LJ_CX_NUM") + item.getIntValue("CORP_RECHARGE_LJ_NUM");
				//小计金额
				row.getCell(maxColumn - 15).setCellValue((item.getIntValue("XJ_RECHARGE_LJ_AMT") + item.getIntValue("XJ_RECHARGE_LJ_CX_AMT") + item.getIntValue("BNAK_RECHARGE_LJ_AMT") + item.getIntValue("BNAK_RECHARGE_LJ_CX_AMT") + item.getIntValue("CORP_RECHARGE_LJ_AMT")) / 100);//小计金额
				LJ_TOT_AMT += item.getIntValue("XJ_RECHARGE_LJ_AMT") + item.getIntValue("XJ_RECHARGE_LJ_CX_AMT") + item.getIntValue("BNAK_RECHARGE_LJ_AMT") + item.getIntValue("BNAK_RECHARGE_LJ_CX_AMT") + item.getIntValue("CORP_RECHARGE_LJ_AMT");
				
				row.getCell(maxColumn - 14).setCellValue(item.getIntValue("XJ_RECHARGE_TJ_NUM"));//电子钱包现金充值笔数
				XJ_RECHARGE_TJ_NUM += item.getIntValue("XJ_RECHARGE_TJ_NUM");
				row.getCell(maxColumn - 13).setCellValue(item.getDoubleValue("XJ_RECHARGE_TJ_AMT") / 100);//电子钱包现金充值金额
				XJ_RECHARGE_TJ_AMT += item.getDoubleValue("XJ_RECHARGE_TJ_AMT");
				
				row.getCell(maxColumn - 12).setCellValue(item.getIntValue("XJ_RECHARGE_TJ_CX_NUM"));//电子钱包充值撤销笔数
				XJ_RECHARGE_TJ_CX_NUM += item.getIntValue("XJ_RECHARGE_TJ_CX_NUM");
				row.getCell(maxColumn - 11).setCellValue(item.getDoubleValue("XJ_RECHARGE_TJ_CX_AMT") / 100);//电子钱包充值撤销金额
				XJ_RECHARGE_TJ_CX_AMT += item.getDoubleValue("XJ_RECHARGE_TJ_CX_AMT");
				
				row.getCell(maxColumn - 10).setCellValue(item.getIntValue("BNAK_RECHARGE_TJ_NUM"));//电子钱包银行卡笔数
				BNAK_RECHARGE_TJ_NUM += item.getIntValue("BNAK_RECHARGE_TJ_NUM");
				row.getCell(maxColumn - 9).setCellValue(item.getDoubleValue("BNAK_RECHARGE_TJ_AMT") / 100);//电子钱包银行卡金额
				BNAK_RECHARGE_TJ_AMT += item.getDoubleValue("BNAK_RECHARGE_TJ_AMT");
				
				row.getCell(maxColumn - 8).setCellValue(item.getIntValue("BNAK_RECHARGE_TJ_CX_NUM"));//电子钱包银行撤销笔数
				BNAK_RECHARGE_TJ_CX_NUM += item.getIntValue("BNAK_RECHARGE_TJ_CX_NUM");
				row.getCell(maxColumn - 7).setCellValue(item.getDoubleValue("BNAK_RECHARGE_TJ_CX_AMT") / 100);//电子钱包银行撤销金额
				BNAK_RECHARGE_TJ_CX_AMT += item.getDoubleValue("BNAK_RECHARGE_TJ_CX_AMT");
				
				row.getCell(maxColumn - 6).setCellValue(item.getIntValue("XJ_RECHARGE_TJ_NUM") - item.getIntValue("XJ_RECHARGE_TJ_CX_NUM") + item.getIntValue("BNAK_RECHARGE_TJ_NUM") - item.getIntValue("BNAK_RECHARGE_TJ_CX_NUM"));//电子钱包笔数小计
				TJ_TOT_NUM += item.getIntValue("XJ_RECHARGE_TJ_NUM") - item.getIntValue("XJ_RECHARGE_TJ_CX_NUM") + item.getIntValue("BNAK_RECHARGE_TJ_NUM") - item.getIntValue("BNAK_RECHARGE_TJ_CX_NUM");
				row.getCell(maxColumn - 5).setCellValue((item.getIntValue("XJ_RECHARGE_TJ_AMT") + item.getIntValue("XJ_RECHARGE_TJ_CX_AMT") + item.getIntValue("BNAK_RECHARGE_TJ_AMT") + item.getIntValue("BNAK_RECHARGE_TJ_CX_AMT")) / 100);//电子钱包金额小计
				TJ_TOT_AMT += item.getIntValue("XJ_RECHARGE_TJ_AMT") + item.getIntValue("XJ_RECHARGE_TJ_CX_AMT") + item.getIntValue("BNAK_RECHARGE_TJ_AMT") + item.getIntValue("BNAK_RECHARGE_TJ_CX_AMT");
				
				row.getCell(maxColumn - 4).setCellValue(item.getIntValue("BATCH_RECHARGE_UR_NUM"));//未登账户批量充值笔数
				BATCH_RECHARGE_UR_NUM += item.getIntValue("BATCH_RECHARGE_UR_NUM");
				row.getCell(maxColumn - 3).setCellValue(item.getDoubleValue("BATCH_RECHARGE_UR_AMT") / 100);//未登账户批量充值金额
				BATCH_RECHARGE_UR_AMT += item.getDoubleValue("BATCH_RECHARGE_UR_AMT");
				
				row.getCell(maxColumn - 2).setCellValue(item.getIntValue("XJ_RECHARGE_LJ_NUM") - item.getIntValue("XJ_RECHARGE_LJ_CX_NUM") + item.getIntValue("BNAK_RECHARGE_LJ_NUM") - item.getIntValue("BNAK_RECHARGE_LJ_CX_NUM") + item.getIntValue("CORP_RECHARGE_LJ_NUM")
														+ item.getIntValue("XJ_RECHARGE_TJ_NUM") - item.getIntValue("XJ_RECHARGE_TJ_CX_NUM") + item.getIntValue("BNAK_RECHARGE_TJ_NUM") - item.getIntValue("BNAK_RECHARGE_TJ_CX_NUM") + item.getIntValue("BATCH_RECHARGE_UR_NUM"));
				TOTAL_NUM += item.getIntValue("XJ_RECHARGE_LJ_NUM") - item.getIntValue("XJ_RECHARGE_LJ_CX_NUM") + item.getIntValue("BNAK_RECHARGE_LJ_NUM") - item.getIntValue("BNAK_RECHARGE_LJ_CX_NUM") + item.getIntValue("CORP_RECHARGE_LJ_NUM")
				+ item.getIntValue("XJ_RECHARGE_TJ_NUM") - item.getIntValue("XJ_RECHARGE_TJ_CX_NUM") + item.getIntValue("BNAK_RECHARGE_TJ_NUM") - item.getIntValue("BNAK_RECHARGE_TJ_CX_NUM") + item.getIntValue("BATCH_RECHARGE_UR_NUM");
				
				
				row.getCell(maxColumn - 1).setCellValue((item.getIntValue("XJ_RECHARGE_LJ_AMT") + item.getIntValue("XJ_RECHARGE_LJ_CX_AMT") + item.getIntValue("BNAK_RECHARGE_LJ_AMT") + item.getIntValue("BNAK_RECHARGE_LJ_CX_AMT") + item.getIntValue("CORP_RECHARGE_LJ_AMT")
				+ item.getIntValue("XJ_RECHARGE_TJ_AMT") + item.getIntValue("XJ_RECHARGE_TJ_CX_AMT") + item.getIntValue("BNAK_RECHARGE_TJ_AMT") - item.getIntValue("BNAK_RECHARGE_TJ_CX_AMT") + item.getIntValue("BATCH_RECHARGE_UR_AMT")) / 100);
				TOTAL_AMT += item.getIntValue("XJ_RECHARGE_LJ_AMT") + item.getIntValue("XJ_RECHARGE_LJ_CX_AMT") + item.getIntValue("BNAK_RECHARGE_LJ_AMT") + item.getIntValue("BNAK_RECHARGE_LJ_CX_AMT") + item.getIntValue("CORP_RECHARGE_LJ_AMT")
				+ item.getIntValue("XJ_RECHARGE_TJ_AMT") + item.getIntValue("XJ_RECHARGE_TJ_CX_AMT") + item.getIntValue("BNAK_RECHARGE_TJ_AMT") - item.getIntValue("BNAK_RECHARGE_TJ_CX_AMT") + item.getIntValue("BATCH_RECHARGE_UR_AMT");
				
				
			}
			
			// footer
			Row row = sheet.createRow(data.size() + headRows);
			for (int i = 0; i < maxColumn; i++) {
				Cell cell = row.createCell(i);
				if (i > 2 && i % 2 == 1) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			
			}
			row.getCell(0).setCellValue("统计");
			row.getCell(1).setCellValue("共 " + numSum + " 条记录");
			//
			row.getCell(maxColumn - 26).setCellValue(XJ_RECHARGE_LJ_NUM);
			row.getCell(maxColumn - 25).setCellValue(XJ_RECHARGE_LJ_AMT / 100);
			row.getCell(maxColumn - 24).setCellValue(XJ_RECHARGE_LJ_CX_NUM);
			row.getCell(maxColumn - 23).setCellValue(XJ_RECHARGE_LJ_CX_AMT / 100);
			row.getCell(maxColumn - 22).setCellValue(BNAK_RECHARGE_LJ_NUM);
			row.getCell(maxColumn - 21).setCellValue(BNAK_RECHARGE_LJ_AMT / 100);
			//
			row.getCell(maxColumn - 20).setCellValue(BNAK_RECHARGE_LJ_CX_NUM);
			row.getCell(maxColumn - 19).setCellValue(BNAK_RECHARGE_LJ_CX_AMT / 100);
			row.getCell(maxColumn - 18).setCellValue(CORP_RECHARGE_LJ_NUM);
			row.getCell(maxColumn - 17).setCellValue(CORP_RECHARGE_LJ_AMT / 100);
			row.getCell(maxColumn - 16).setCellValue(LJ_TOT_NUM);
			row.getCell(maxColumn - 15).setCellValue(LJ_TOT_AMT / 100);
			//
			row.getCell(maxColumn - 14).setCellValue(XJ_RECHARGE_TJ_NUM);
			row.getCell(maxColumn - 13).setCellValue(XJ_RECHARGE_TJ_AMT / 100);
			row.getCell(maxColumn - 12).setCellValue(XJ_RECHARGE_TJ_CX_NUM);
			row.getCell(maxColumn - 11).setCellValue(XJ_RECHARGE_TJ_CX_AMT / 100);
			row.getCell(maxColumn - 10).setCellValue(BNAK_RECHARGE_TJ_NUM);
			row.getCell(maxColumn - 9).setCellValue(BNAK_RECHARGE_TJ_AMT / 100);
			//
			row.getCell(maxColumn - 8).setCellValue(BNAK_RECHARGE_TJ_CX_NUM);
			row.getCell(maxColumn - 7).setCellValue(BNAK_RECHARGE_TJ_CX_AMT / 100);
			
			row.getCell(maxColumn - 6).setCellValue(TJ_TOT_NUM);
			row.getCell(maxColumn - 5).setCellValue(TJ_TOT_AMT / 100);
			
			row.getCell(maxColumn - 4).setCellValue(BATCH_RECHARGE_UR_NUM);
			row.getCell(maxColumn - 3).setCellValue(BATCH_RECHARGE_UR_AMT / 100);
			
			row.getCell(maxColumn - 2).setCellValue(TOTAL_NUM);
			row.getCell(maxColumn - 1).setCellValue(TOTAL_AMT / 100);
			//
			
			OutputStream os = response.getOutputStream();
			HttpServletResponse response = ServletActionContext.getResponse();
			String fileName = "实时充值情况统计报表";
			response.setContentType("application/ms-excel;charset=utf-8");
		    response.setHeader("Content-disposition", "attachment; filename="+ URLEncoder.encode(fileName,"UTF8") + ".xls");
			workbook.write(os);
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String queryBrchRechgStatRt(){
		try {
			initGrid();
			String sql = "select t.brch_id || '|' || card_type seq, t.full_name, "
					+ "(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t2.card_type) card_type, "
					+ "nvl(sum(decode(t2.deal_code,'30101020',1,'0')), 0) XJ_RECHARGE_LJ_NUM, "
					+ "nvl(sum(decode(t2.deal_code,'30101020',t2.amt,'0')), 0) XJ_RECHARGE_LJ_AMT, "
					+ "nvl(sum(decode(t2.deal_code,'30101021',1,'0')), 0) XJ_RECHARGE_LJ_CX_NUM, "
					+ "nvl(sum(decode(t2.deal_code,'30101021',t2.amt,'0')), 0) XJ_RECHARGE_LJ_CX_AMT, "
					+ "nvl(sum(decode(t2.deal_code,'30302010',1,'0')), 0) BNAK_RECHARGE_LJ_NUM, "
					+ "nvl(sum(decode(t2.deal_code,'30302010',t2.amt,'0')), 0) BNAK_RECHARGE_LJ_AMT, "
					+ "nvl(sum(decode(t2.deal_code,'30302011',1,'0')), 0) BNAK_RECHARGE_LJ_CX_NUM, "
					+ "nvl(sum(decode(t2.deal_code,'30302011',t2.amt,'0')), 0) BNAK_RECHARGE_LJ_CX_AMT, "
					+ "nvl(sum(decode(t2.deal_code,'30101010',1,'0')), 0) XJ_RECHARGE_TJ_NUM, "
					+ "nvl(sum(decode(t2.deal_code,'30101010',t2.amt,'0')), 0) XJ_RECHARGE_TJ_AMT, "
					+ "nvl(sum(decode(t2.deal_code,'30101011',1,'0')), 0) XJ_RECHARGE_TJ_CX_NUM, "
					+ "nvl(sum(decode(t2.deal_code,'30101011',t2.amt,'0')), 0) XJ_RECHARGE_TJ_CX_AMT, "
					+ "nvl(sum(decode(t2.deal_code,'30302020',1,'0')), 0) BNAK_RECHARGE_TJ_NUM, "
					+ "nvl(sum(decode(t2.deal_code,'30302020',t2.amt,'0')), 0) BNAK_RECHARGE_TJ_AMT, "
					+ "nvl(sum(decode(t2.deal_code,'30302021',1,'0')), 0) BNAK_RECHARGE_TJ_CX_NUM, "
					+ "nvl(sum(decode(t2.deal_code,'30302021',t2.amt,'0')), 0) BNAK_RECHARGE_TJ_CX_AMT, "
					+ "nvl(sum(decode(t2.deal_code,'30601020',1,'30601030',1,'30601021',-1,'30601031',-1,0)), 0) CORP_RECHARGE_LJ_NUM, "
					+ "nvl(sum(decode(t2.deal_code,'30601020',t2.amt,'30601030',t2.amt,'30601021',t2.amt,'30601031',t2.amt,0)), 0) CORP_RECHARGE_LJ_AMT, "
					+ "nvl(sum(decode(t2.deal_code,'30101100',1,'0')), 0) BATCH_RECHARGE_UR_NUM, "
					+ "nvl(sum(decode(t2.deal_code,'30101100',t2.amt,'0')), 0) BATCH_RECHARGE_UR_AMT "
					+ "from sys_branch t left join pay_card_deal_rec_" + DateUtil.formatDate(new Date(), "yyyyMM") + " t2 on t.brch_id = t2.acpt_id "
					+ "where 1 = 1 ";
			if (!Tools.processNull(org_Id).equals("")) {
				sql += "and t2.org_Id ='" + org_Id + "' ";
			}
			if (!Tools.processNull(brch_Id).equals("")) {
				SysBranch brch = (SysBranch) baseService.findOnlyRowByHql("from SysBranch where brchId ='" + brch_Id + "'");
				sql += "and  t2.acpt_id in (select a.brch_id from sys_branch a start with a.sysbranch_id = '" + brch.getSysBranchId() + "' connect by prior a.sysbranch_id = a.pid) ";
			}
			if (!Tools.processNull(region_Id).equals("")) {
				sql += "and t.region_Id ='" + region_Id + "' ";
			}
			if (!Tools.processNull(startDate).equals("")) {
				sql += "and t2.deal_date >= to_date('" + startDate + "', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			if (!Tools.processNull(endDate).equals("")) {
				sql += "and t2.deal_date <= to_date('" + endDate + "', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			sql += "group by t.brch_id, t.full_name, t2.card_type ";
			sql += "order by t.brch_id";
			Page pages = baseService.pagingQuery(sql, page, rows);
			if (pages.getAllRs() == null || pages.getAllRs().isEmpty()) {
				throw new CommonException("根据指定信息未查询到充值信息！");
			}
			jsonObject.put("rows", pages.getAllRs());
			jsonObject.put("total", pages.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	@SuppressWarnings("unchecked")
	public String validExportBusinessRp(){
		try {
			Map<String, Object> exp = new HashMap<String, Object>();
			List<Map<String, String>> branchDatas = new ArrayList<Map<String, String>>();// 导出数据
			int maxLevel = 0;// 最大网点级别
			
			String dataSql = "select nvl(sum(nvl(num, 0)), 0), to_char(nvl(sum(nvl(amt, 0))/100, 0), '9,999,999,990.00') "
					+ "from stat_day_bal t where t.user_id is not null and t.org_id = '1001' and t.brch_id is not null and"
					+ " t.brch_id in (select brch_id from sys_branch start with brch_id = 'BRCH_ID' connect by prior "
					+ "sysbranch_id = pid) ";
			
			if (!"".equals(Tools.processNull(deal_Code))) {
				dataSql += " and t.deal_code = '" + deal_Code + "' ";
			}
			if (!"".equals(Tools.processNull(startDate))) {
				dataSql += " and t.clr_date >= '" + startDate + "' ";
			}
			if (!"".equals(Tools.processNull(endDate))) {
				dataSql += " and t.clr_date <= '" + endDate + "' ";
			}
			if (!"".equals(Tools.processNull(org_Id))) {
				dataSql += " and t.org_Id = '" + org_Id + "' ";
			}
			if (!"".equals(Tools.processNull(user_Id)) && !"erp2_erp2".equals(Tools.processNull(user_Id))) {
				dataSql += " and t.user_Id = '" + user_Id + "' ";
			}
			
			// 
			List<Object[]> branchIds = null;
			SysBranch branch = null;
			if (brch_Id == null || brch_Id.trim().equals("")) {
				branchIds = baseService.findBySql("select brch_id, full_name, sysbranch_id, pid, level from sys_branch "
						+ "start with pid is null connect by prior sysbranch_id = pid");
			} else {
				branch = (SysBranch) baseService.findOnlyRowByHql("from SysBranch where brchId = '" + brch_Id + "'");
				branchIds = baseService.findBySql("select brch_id, full_name, sysbranch_id, pid, level from sys_branch "
						+ "start with brch_id = '" + brch_Id + "' connect by prior sysbranch_id = pid");
			}
			
			if(branchIds == null || branchIds.isEmpty()){
				throw new CommonException("网点为空.");
			}
			
			for (int i = 0; i < branchIds.size(); i++) {
				Object[] branchId = branchIds.get(i);
				String level = Tools.processNull(branchId[4]);
				
				maxLevel = Integer.parseInt(level) > maxLevel ? Integer.parseInt(level) : maxLevel;

				Object[] data = (Object[]) baseService.findOnlyRowBySql(dataSql.replaceFirst("BRCH_ID", Tools.processNull(branchId[0])));

				Map<String, String> branchData = new HashMap<String, String>();
				branchData.put(BRANCH_BRCH_ID, Tools.processNull(branchId[0]));
				branchData.put(BRANCH_NAME, Tools.processNull(branchId[1]));
				branchData.put(BRANCH_ID, Tools.processNull(branchId[2]));
				branchData.put(BRANCH_PARENT_ID, Tools.processNull(branchId[3]));
				branchData.put(BRANCH_LEVEL, level);
				branchData.put(BRANCH_BUSINESS_NUM, Tools.processNull(data[0]));
				branchData.put(BRANCH_BUSINESS_AMT, Tools.processNull(data[1]));

				branchDatas.add(branchData);
			}
			
			if(branchDatas == null || branchDatas.isEmpty()){
				throw new CommonException("导出数据为空.");
			}
			
			// fileName
			String fileName = "系统业务报表";
			if(branch != null){
				fileName = branch.getFullName() + "_" + fileName;
			}
			if (!Tools.processNull(startDate).equals("")) {
				fileName += "(" + startDate + " ~ ";

				if (!Tools.processNull(endDate).equals("")) {
					fileName += endDate;
				} else {
					fileName += DateUtil.formatDate(new Date(), "yyyy-MM-dd");
				}

				fileName += ")";
			}
			
			exp.put(EXPORT_FILE_NAME, fileName);
			exp.put(EXPORT_DATA, branchDatas);
			exp.put(MAX_BRANCH_LEVEL, maxLevel);
			
			// expid
			String expid = "exp" + new Date().getTime();
			
			HttpSession httpSession = request.getSession();
			httpSession.setAttribute(expid, exp);
			
			jsonObject.put("expid", expid);
			jsonObject.put("status", "0");
		} catch (CommonException e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", "导出失败, " + e.getMessage());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", "导出失败, 系统异常[" + e.getMessage() + "]");
		}
		
		return JSONOBJ;
	}
	
	
	
	
	
	
	
	
	@SuppressWarnings("unchecked")
	public String exportBusinessRp(){
		try {
			if (expid == null || expid.trim().equals("")) {
				throw new CommonException("expid is null.");
			}
			
			HttpSession httpSession = request.getSession();
			Map<String, Object> exp = (Map<String, Object>) httpSession.getAttribute(expid);
			httpSession.removeAttribute(expid);
			
			if(exp == null || exp.isEmpty()){
				throw new CommonException("exp is null.");
			}
			
			String fileName = (String) exp.get(EXPORT_FILE_NAME);
			List<Map<String, String>> branchDatas = (List<Map<String, String>>) exp.get(EXPORT_DATA);
			int maxLevel = (Integer) exp.get(MAX_BRANCH_LEVEL);
			
			// 导出 start
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			OutputStream output = response.getOutputStream();

			// build sheet、jxl.Workbook
			WritableWorkbook wwb = jxl.Workbook.createWorkbook(output);
			WritableSheet sheet1 = wwb.createSheet("Sheet0", 0);
			
			// set width
			for (int i = 0; i < maxLevel; i++) {
				sheet1.setColumnView(i, 20);
			}
			sheet1.setColumnView(maxLevel, 12);
			sheet1.setColumnView(maxLevel + 1, 18);

			// cell format define
			WritableCellFormat headCellFormat = new WritableCellFormat();
			WritableFont headFont = new WritableFont(WritableFont.ARIAL, 10, WritableFont.BOLD);
			headCellFormat.setAlignment(Alignment.CENTRE);
			headCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			headCellFormat.setFont(headFont);
			
			WritableCellFormat rowRightCellFormat = new WritableCellFormat();
			rowRightCellFormat.setAlignment(Alignment.RIGHT);
			rowRightCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			
			WritableCellFormat rowCellFormat = new WritableCellFormat();
			rowCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			
			WritableCellFormat rowCenterCellFormat = new WritableCellFormat();
			rowCenterCellFormat.setAlignment(Alignment.CENTRE);
			rowCenterCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			
			// title
			sheet1.mergeCells(0, 0, maxLevel + 1, 0); // 合并title
			Label titleLabel = new Label(0, 0, fileName);
			titleLabel.setCellFormat(headCellFormat);
			sheet1.addCell(titleLabel);

			// head
			sheet1.mergeCells(0, 1, maxLevel - 1, 1); // 合并head
			Label headLabel0 = new Label(0, 1, "网点");
			Label headLabel1 = new Label(maxLevel, 1, "本期内笔数");
			Label headLabel2 = new Label(maxLevel + 1, 1, "本期内金额");
			
			headLabel0.setCellFormat(headCellFormat);
			headLabel1.setCellFormat(headCellFormat);
			headLabel2.setCellFormat(headCellFormat);
			
			sheet1.addCell(headLabel0);
			sheet1.addCell(headLabel1);
			sheet1.addCell(headLabel2);

			// body
			for (int i = 0; i < branchDatas.size(); i++) {
				Map<String, String> branchData = branchDatas.get(i);//data
				
				int level = Integer.valueOf(branchData.get(BRANCH_LEVEL));
				
				// branch
				for (int j = 0; j < maxLevel; j++) {
					Label branchLabel = null;
					
					if (j + 1 == level) {
						branchLabel = new Label(level - 1, i + 2, branchData.get(BRANCH_NAME));
						branchLabel.setCellFormat(rowCellFormat);
					} else if (j + 2 == level) {
						branchLabel = new Label(j, i + 2, "+");
						branchLabel.setCellFormat(rowCenterCellFormat);
					} else {
						branchLabel = new Label(j, i + 2, "");
						branchLabel.setCellFormat(rowCenterCellFormat);
					}
					
					sheet1.addCell(branchLabel);
				}
				
				// data
				Label label3 = new Label(maxLevel, i + 2, branchData.get(BRANCH_BUSINESS_NUM));
				Label label4 = new Label(maxLevel + 1, i + 2, branchData.get(BRANCH_BUSINESS_AMT));
				label3.setCellFormat(rowRightCellFormat);
				label4.setCellFormat(rowRightCellFormat);
				sheet1.addCell(label3);
				sheet1.addCell(label4);
			}
			
			wwb.write();
			wwb.close();
			output.flush();
			output.close();
		} catch (CommonException e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", "导出失败, " + e.getMessage());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", "导出失败, 系统异常[" + e.getMessage() + "]");
		}
		return JSONOBJ;
	}
	
	@SuppressWarnings("unchecked")
	public String validExportAccountRp(){
		try {
			Map<String, Object> exp = new HashMap<String, Object>();
			List<Map<String, String>> branchDatas = new ArrayList<Map<String, String>>();// 导出数据
			int maxLevel = 0;// 最大网点级别
			
			// build sql
			String whereSql = "";

			if ("1".equals(rec_Type)) {
				whereSql += " and t.acpt_type = '1' ";
			} else {
				throw new CommonException("不支持的类型[rec_Type=" + rec_Type + "].");
			}
			if ("".equals(Tools.processNull(startDate))) {
				throw new CommonException("起始时间不能为空.");
			}
			if ("".equals(Tools.processNull(endDate))) {
				throw new CommonException("结束时间不能为空.");
			}
			
			if (!"".equals(Tools.processNull(deal_Code))) {
				whereSql += " and t.deal_code = '" + deal_Code + "' ";
			}
			if (!"".equals(Tools.processNull(cardType))) {
				whereSql += " and t.card_type='" + cardType + "' ";
			}
			if (!"".equals(Tools.processNull(accKind))) {
				whereSql += " and t.acc_kind='" + accKind + "' ";
			}
			if (!"".equals(Tools.processNull(org_Id))) {
				whereSql += " and t.org_Id = '" + org_Id + "' ";
			}
			
			// 本期
			String dataSql1 = "select nvl(sum(nvl(num, 0)), 0), to_char(nvl(sum(nvl(amt, 0)), 0)/100, '999,999,999,990.00') from "
					+ "stat_card_pay t where acpt_id in (select brch_id from sys_branch start with brch_id = 'BRCH_ID' connect by "
					+ "prior sysbranch_id = pid) and t.clr_date >= '" + startDate + "' and t.clr_date <= '" + endDate + "' " + whereSql;
			
			// 上期结余
			String dataSql2 = "select nvl(sum(nvl(end_num, 0)), 0), to_char(nvl(sum(nvl(end_amt, 0)), 0) / 100, '999,999,999,990.00')"
					+ " from (select rank() over(partition by t.acpt_id, t.deal_code order by t.clr_date desc) no, t.end_num, t.end_amt"
					+ " from stat_card_pay t where t.acpt_id in (select brch_id from sys_branch start with brch_id = 'BRCH_ID' connect "
					+ "by prior sysbranch_id = pid)  and t.clr_date < '" + startDate + "' " + whereSql + ") where no = 1";
			
			// 本期结余
			String dataSql3 = "select nvl(sum(nvl(end_num, 0)), 0), to_char(nvl(sum(nvl(end_amt, 0)), 0) / 100, '999,999,999,990.00')"
					+ " from (select rank() over(partition by t.acpt_id, t.deal_code order by t.clr_date desc) no, t.end_num, t.end_amt"
					+ " from stat_card_pay t where t.acpt_id in (select brch_id from sys_branch start with brch_id = 'BRCH_ID' connect "
					+ "by prior sysbranch_id = pid)  and t.clr_date < '" + endDate + "' " + whereSql + ") where no = 1";
			
			// 
			List<Object[]> branchIds = null;
			SysBranch branch = null;
			if (brch_Id == null || brch_Id.trim().equals("")) {
				branchIds = baseService.findBySql("select brch_id, full_name, sysbranch_id, pid, level from sys_branch "
						+ "start with pid is null connect by prior sysbranch_id = pid");
			} else {
				branch = (SysBranch) baseService.findOnlyRowByHql("from SysBranch where brchId = '" + brch_Id + "'");
				branchIds = baseService.findBySql("select brch_id, full_name, sysbranch_id, pid, level from sys_branch "
						+ "start with brch_id = '" + brch_Id + "' connect by prior sysbranch_id = pid");
			}
			
			if(branchIds == null || branchIds.isEmpty()){
				throw new CommonException("网点为空.");
			}
			
			for (int i = 0; i < branchIds.size(); i++) {
				Object[] branchId = branchIds.get(i);
				String level = Tools.processNull(branchId[4]);
				
				maxLevel = Integer.parseInt(level) > maxLevel ? Integer.parseInt(level) : maxLevel;

				Object[] data1 = (Object[]) baseService.findOnlyRowBySql(dataSql1.replaceFirst("BRCH_ID", Tools.processNull(branchId[0])));
				Object[] data2 = (Object[]) baseService.findOnlyRowBySql(dataSql2.replaceFirst("BRCH_ID", Tools.processNull(branchId[0])));
				Object[] data3 = (Object[]) baseService.findOnlyRowBySql(dataSql3.replaceFirst("BRCH_ID", Tools.processNull(branchId[0])));

				Map<String, String> branchData = new HashMap<String, String>();
				// branch info
				branchData.put(BRANCH_BRCH_ID, Tools.processNull(branchId[0]));
				branchData.put(BRANCH_NAME, Tools.processNull(branchId[1]));
				branchData.put(BRANCH_ID, Tools.processNull(branchId[2]));
				branchData.put(BRANCH_PARENT_ID, Tools.processNull(branchId[3]));
				branchData.put(BRANCH_LEVEL, level);
				// data
				branchData.put(BRANCH_ACCOUNT_PER_NUM, Tools.processNull(data2[0]));
				branchData.put(BRANCH_ACCOUNT_PER_AMT, Tools.processNull(data2[1]));
				branchData.put(BRANCH_ACCOUNT_NUM, Tools.processNull(data1[0]));
				branchData.put(BRANCH_ACCOUNT_AMT, Tools.processNull(data1[1]));
				branchData.put(BRANCH_ACCOUNT_END_NUM, Tools.processNull(data3[0]));
				branchData.put(BRANCH_ACCOUNT_END_AMT, Tools.processNull(data3[1]));

				branchDatas.add(branchData);
			}
			
			if(branchDatas == null || branchDatas.isEmpty()){
				throw new CommonException("导出数据为空.");
			}
			
			// fileName
			String fileName = "系统账务报表";
			if (branch != null) {
				fileName = branch.getFullName() + "_" + fileName;
			}
			fileName += "(" + startDate + " ~ " + endDate + ")";
			
			exp.put(EXPORT_FILE_NAME, fileName);
			exp.put(EXPORT_DATA, branchDatas);
			exp.put(MAX_BRANCH_LEVEL, maxLevel);
			
			// expid
			String expid = "exp" + new Date().getTime();
			
			HttpSession httpSession = request.getSession();
			httpSession.setAttribute(expid, exp);
			
			jsonObject.put("expid", expid);
			jsonObject.put("status", "0");
		} catch (CommonException e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", "导出失败, " + e.getMessage());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", "导出失败, 系统异常[" + e.getMessage() + "]");
		}
		
		return JSONOBJ;
	}
	
	@SuppressWarnings("unchecked")
	public String exportAccountRp(){
		try {
			if (expid == null || expid.trim().equals("")) {
				throw new CommonException("expid is null.");
			}
			
			HttpSession httpSession = request.getSession();
			Map<String, Object> exp = (Map<String, Object>) httpSession.getAttribute(expid);
			httpSession.removeAttribute(expid);
			
			if(exp == null || exp.isEmpty()){
				throw new CommonException("exp is null.");
			}
			
			String fileName = (String) exp.get(EXPORT_FILE_NAME);
			List<Map<String, String>> branchDatas = (List<Map<String, String>>) exp.get(EXPORT_DATA);
			int maxLevel = (Integer) exp.get(MAX_BRANCH_LEVEL);
			
			// 导出 start
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(),"iso8859-1") + ".xls");
			OutputStream output = response.getOutputStream();

			// build sheet
			WritableWorkbook wwb = jxl.Workbook.createWorkbook(output);
			WritableSheet sheet1 = wwb.createSheet("Sheet0", 0);
			
			// set width
			for (int i = 0; i < maxLevel; i++) {
				sheet1.setColumnView(i, 20);
			}
			sheet1.setColumnView(maxLevel, 12);
			sheet1.setColumnView(maxLevel + 1, 18);
			sheet1.setColumnView(maxLevel + 2, 12);
			sheet1.setColumnView(maxLevel + 3, 18);
			sheet1.setColumnView(maxLevel + 4, 12);
			sheet1.setColumnView(maxLevel + 5, 18);

			// cell format define
			WritableCellFormat headCellFormat = new WritableCellFormat();
			WritableFont headFont = new WritableFont(WritableFont.ARIAL, 10, WritableFont.BOLD);
			headCellFormat.setAlignment(Alignment.CENTRE);
			headCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			headCellFormat.setFont(headFont);
			
			WritableCellFormat rowRightCellFormat = new WritableCellFormat();
			rowRightCellFormat.setAlignment(Alignment.RIGHT);
			rowRightCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			
			WritableCellFormat rowCellFormat = new WritableCellFormat();
			rowCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			
			WritableCellFormat rowCenterCellFormat = new WritableCellFormat();
			rowCenterCellFormat.setAlignment(Alignment.CENTRE);
			rowCenterCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			
			// title
			sheet1.mergeCells(0, 0, maxLevel + 5, 0); // 合并title
			Label titleLabel = new Label(0, 0, fileName);
			titleLabel.setCellFormat(headCellFormat);
			sheet1.addCell(titleLabel);

			// head
			sheet1.mergeCells(0, 1, maxLevel - 1, 1); // 合并head
			Label headLabel0 = new Label(0, 1, "网点");
			Label headLabel1 = new Label(maxLevel, 1, "上期结余笔数");
			Label headLabel2 = new Label(maxLevel + 1, 1, "上期结余金额");
			Label headLabel3 = new Label(maxLevel + 2, 1, "本期内笔数");
			Label headLabel4 = new Label(maxLevel + 3, 1, "本期内金额");
			Label headLabel5 = new Label(maxLevel + 4, 1, "本期结余笔数");
			Label headLabel6 = new Label(maxLevel + 5, 1, "本期结余金额");
			
			headLabel0.setCellFormat(headCellFormat);
			headLabel1.setCellFormat(headCellFormat);
			headLabel2.setCellFormat(headCellFormat);
			headLabel3.setCellFormat(headCellFormat);
			headLabel4.setCellFormat(headCellFormat);
			headLabel5.setCellFormat(headCellFormat);
			headLabel6.setCellFormat(headCellFormat);
			
			sheet1.addCell(headLabel0);
			sheet1.addCell(headLabel1);
			sheet1.addCell(headLabel2);
			sheet1.addCell(headLabel3);
			sheet1.addCell(headLabel4);
			sheet1.addCell(headLabel5);
			sheet1.addCell(headLabel6);

			// body
			for (int i = 0; i < branchDatas.size(); i++) {
				Map<String, String> branchData = branchDatas.get(i);//data
				
				int level = Integer.valueOf(branchData.get(BRANCH_LEVEL));
				
				// branch
				for (int j = 0; j < maxLevel; j++) {
					Label branchLabel = null;
					
					if (j + 1 == level) {
						branchLabel = new Label(level - 1, i + 2, branchData.get(BRANCH_NAME));
						branchLabel.setCellFormat(rowCellFormat);
					} else if (j + 2 == level) {
						branchLabel = new Label(j, i + 2, "+");
						branchLabel.setCellFormat(rowCenterCellFormat);
					} else {
						branchLabel = new Label(j, i + 2, "");
						branchLabel.setCellFormat(rowCenterCellFormat);
					}
					
					sheet1.addCell(branchLabel);
				}
				
				// data
				Label label1 = new Label(maxLevel, i + 2, branchData.get(BRANCH_ACCOUNT_PER_NUM));
				Label label2 = new Label(maxLevel + 1, i + 2, branchData.get(BRANCH_ACCOUNT_PER_AMT));
				Label label3 = new Label(maxLevel + 2, i + 2, branchData.get(BRANCH_ACCOUNT_NUM));
				Label label4 = new Label(maxLevel + 3, i + 2, branchData.get(BRANCH_ACCOUNT_AMT));
				Label label5 = new Label(maxLevel + 4, i + 2, branchData.get(BRANCH_ACCOUNT_END_NUM));
				Label label6 = new Label(maxLevel + 5, i + 2, branchData.get(BRANCH_ACCOUNT_END_AMT));
				
				label1.setCellFormat(rowRightCellFormat);
				label2.setCellFormat(rowRightCellFormat);
				label3.setCellFormat(rowRightCellFormat);
				label4.setCellFormat(rowRightCellFormat);
				label5.setCellFormat(rowRightCellFormat);
				label6.setCellFormat(rowRightCellFormat);
				
				sheet1.addCell(label1);
				sheet1.addCell(label2);
				sheet1.addCell(label3);
				sheet1.addCell(label4);
				sheet1.addCell(label5);
				sheet1.addCell(label6);
			}
			
			wwb.write();
			wwb.close();
			output.flush();
			output.close();
		} catch (CommonException e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", "导出失败, " + e.getMessage());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", "导出失败, 系统异常[" + e.getMessage() + "]");
		}
		return JSONOBJ;
	}
	/**
	 * 卡服务相关收入汇总
	 * @return
	 */
	public String cardServiceIncomeStat(){
		try{
			this.initBaseDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			if(Tools.processNull(rec.getOrgId()).equals("")){
				//throw new CommonException("请选择所属机构信息！");
			}
			if(Tools.processNull(this.startDate).equals("")){
				throw new CommonException("开始日期不能为空！");
			}
			if(Tools.processNull(this.endDate).equals("")){
				throw new CommonException("结束日期不能为空！");
			}
			StringBuffer commSql = new StringBuffer();
			commSql.append("SELECT S.BRCH_ID,S.FULL_NAME,T.CARD_TYPE,(SELECT CODE_NAME FROM ");
			commSql.append("SYS_CODE WHERE CODE_TYPE = 'CARD_TYPE' AND CODE_VALUE = T.CARD_TYPE) CARDTYPE,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',1,0)) BKNUM,");//补卡总笔数
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',decode(t.COST_FEE, null, 0, 0, 0, 1),0)) BK_SF_NUM,");//补卡收费笔数
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',decode(t.COST_FEE, null, 1, 0, 1, 0),0)) BK_WSF_NUM,");//补卡未收费笔数
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',NVL(T.COST_FEE,0),0)) BKCOSTFEEAMT,");//补卡总工本费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',NVL(T.URGENT_FEE,0),0)) BKURGAMT,");//补卡总加急费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',NVL(T.RTN_FGFT,0),0)) BKYJAMT,");//补卡总押金
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',1,0)) BKCXNUM,");//补卡撤销总笔数
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',decode(t.COST_FEE, null, 0, 0, 0, 1),0)) BKCX_SF_NUM,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',decode(t.COST_FEE, null, 1, 0, 1, 0),0)) BKCX_WSF_NUM,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',NVL(T.COST_FEE,0),0)) BKCXCOSTFEEAMT,");//补卡撤销总工本费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',NVL(T.URGENT_FEE,0),0)) BKCXURGAMT,");//补卡撤销总加急费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',NVL(T.RTN_FGFT,0),0)) BKCXYJAMT,");//补卡撤销总押金
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG + "',1,0)) HKNUM,");//换卡总笔数
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG + "',decode(t.COST_FEE, null, 0, 0, 0, 1),0)) HK_SF_NUM,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG + "',decode(t.COST_FEE, null, 1, 0, 1, 0),0)) HK_WSF_NUM,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG + "',NVL(T.COST_FEE,0),0)) HKCOSTFEEAMT,");//换卡总工本费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG + "',NVL(T.URGENT_FEE,0))) HKURGAMT,");//换卡总加急费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG + "',NVL(T.RTN_FGFT,0),0)) HKYJAMT,");//换卡总押金
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG_UNDO + "',1,0)) HKCXNUM,");//换卡撤销总笔数
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG_UNDO + "',decode(t.COST_FEE, null, 0, 0, 0, 1),0)) HKCX_SF_NUM,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG_UNDO + "',decode(t.COST_FEE, null, 1, 0, 1, 0),0)) HKCX_WSF_NUM,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG_UNDO + "',-NVL(T.COST_FEE,0),0)) HKCXCOSTFEEAMT,");//换卡撤销总工本费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG_UNDO + "',NVL(T.URGENT_FEE,0),0)) HKCXURGAMT,");//换卡撤销总加急费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG_UNDO + "',NVL(T.RTN_FGFT,0),0)) HKCXYJAMT, ");//换卡撤销总押金
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',1,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',-1,'" + DealCode.NAMEDCARD_CHG + "',1,'" + DealCode.NAMEDCARD_CHG_UNDO + "',-1,0)) TOTNUM,");//总笔数
			commSql.append("SUM(NVL(T.AMT,0)) TOTAMT ");//总金额
			commSql.append("FROM SYS_BRANCH S,TR_SERV_REC T WHERE S.BRCH_ID = T.BRCH_ID(+) ");
			if(!Tools.processNull(this.startDate).equals("")){
				commSql.append("AND T.BIZ_TIME >= TO_DATE('" + this.startDate + " 0:0:0','YYYY-MM-DD HH24:MI:SS') ");
			}
			if(!Tools.processNull(this.endDate).equals("")){
				commSql.append("AND T.BIZ_TIME <= TO_DATE('" + this.endDate + " 23:59:59','YYYY-MM-DD HH24:MI:SS') ");
			}
			commSql.append("AND T.DEAL_CODE IN ('" + DealCode.NAMEDCARD_REISSUE + "','" + DealCode.NAMEDCARD_CHG + "','" + 
					DealCode.NAMEDCARD_REISSUE_UNDO + "','" + DealCode.NAMEDCARD_CHG_UNDO + "') ");
			if(!Tools.processNull(rec.getCardType()).equals("")){
				commSql.append("AND T.CARD_TYPE = '" + rec.getCardType() + "' ");
			}
			if(!Tools.processNull(rec.getOrgId()).equals("")){
				commSql.append("AND S.ORG_ID = '" + rec.getOrgId() + "' ");
			}
			if(!Tools.processNull(rec.getBrchId()).equals("")){
				if(cascadeBrch){
					commSql.append("AND T.BRCH_ID in (select brch_id from sys_branch start with brch_id = '" + rec.getBrchId() + "' connect by prior sysbranch_id = pid) ");
				} else {
					commSql.append("AND T.BRCH_ID = '" + rec.getBrchId() + "' ");
				}
			}
			if(!Tools.processNull(region_Id).equals("")){
				commSql.append("AND s.region_id = '" + region_Id + "' ");
			}
			commSql.append("GROUP BY S.BRCH_ID,S.FULL_NAME,T.CARD_TYPE ");
			if(Tools.processNull(this.sort).equals("")){
				commSql.append("ORDER BY S.BRCH_ID ASC ");
			}else{
				commSql.append("ORDER BY " + this.sort + " " + this.order);
			}
			Page list = baseService.pagingQuery(commSql.toString(), page, rows);
			if(list.getAllRs() != null && list.getTotalCount() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
				if(Tools.processNull(this.exportFlag).equals("0")){
					StringBuffer totStatSql  = new StringBuffer();
					totStatSql.append("SELECT '本页信息统计' CARDTYPE,SUM(BKNUM) BKNUM,SUM(BK_SF_NUM) BK_SF_NUM,SUM(BK_WSF_NUM) BK_WSF_NUM,SUM(BKCOSTFEEAMT) BKCOSTFEEAMT,SUM(BKURGAMT) BKURGAMT,SUM(BKYJAMT) BKYJAMT,");
					totStatSql.append("SUM(BKCXNUM) BKCXNUM,SUM(BKCX_SF_NUM) BKCX_SF_NUM,SUM(BKCX_WSF_NUM) BKCX_WSF_NUM,SUM(BKCXCOSTFEEAMT) BKCXCOSTFEEAMT,SUM(BKCXURGAMT) BKCXURGAMT,SUM(BKCXYJAMT) BKCXYJAMT,");
					totStatSql.append("SUM(HKNUM) HKNUM,SUM(HK_SF_NUM) HK_SF_NUM,SUM(HK_WSF_NUM) HK_WSF_NUM,SUM(HKCOSTFEEAMT) HKCOSTFEEAMT,SUM(HKURGAMT) HKURGAMT,SUM(HKYJAMT) HKYJAMT,");
					totStatSql.append("SUM(HKCXNUM) HKCXNUM,SUM(HKCX_SF_NUM) HKCX_SF_NUM,SUM(HKCX_WSF_NUM) HKCX_WSF_NUM,SUM(HKCXCOSTFEEAMT) HKCXCOSTFEEAMT,SUM(HKCXURGAMT)HKCXURGAMT,SUM(HKCXYJAMT) HKCXYJAMT,");
					totStatSql.append("SUM(TOTNUM) TOTNUM,SUM(TOTAMT) TOTAMT ");
					totStatSql.append("FROM ( " + commSql.toString());
					if(Tools.processNull(page).equals("") || page == 0){
						page = 1;
					}
					totStatSql.append(") WHERE ROWNUM <= " + 100000000);
					totStatSql.append(" AND ROWNUM >= " +  1);
					Page tot = baseService.pagingQuery(totStatSql.toString(),1, 10);
					jsonObject.put("footer", tot.getAllRs());
				}
			}else{
				throw new CommonException("根据条件未查询到记录信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String coOrgCardServiceIncomeStat(){
		try{
			this.initBaseDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			if(Tools.processNull(rec.getOrgId()).equals("")){
				//throw new CommonException("请选择所属机构信息！");
			}
			if(Tools.processNull(this.startDate).equals("")){
				throw new CommonException("开始日期不能为空！");
			}
			if(Tools.processNull(this.endDate).equals("")){
				throw new CommonException("结束日期不能为空！");
			}
			StringBuffer commSql = new StringBuffer();
			commSql.append("SELECT S.BRCH_ID,S.FULL_NAME,T.CARD_TYPE,(SELECT CODE_NAME FROM ");
			commSql.append("SYS_CODE WHERE CODE_TYPE = 'CARD_TYPE' AND CODE_VALUE = T.CARD_TYPE) CARDTYPE,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',1,0)) BKNUM,");//补卡总笔数
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',decode(t.COST_FEE, null, 0, 0, 0, 1),0)) BK_SF_NUM,");//补卡收费笔数
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',decode(t.COST_FEE, null, 1, 0, 1, 0),0)) BK_WSF_NUM,");//补卡未收费笔数
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',NVL(T.COST_FEE,0),0)) BKCOSTFEEAMT,");//补卡总工本费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',NVL(T.URGENT_FEE,0),0)) BKURGAMT,");//补卡总加急费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',NVL(T.RTN_FGFT,0),0)) BKYJAMT,");//补卡总押金
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',1,0)) BKCXNUM,");//补卡撤销总笔数
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',decode(t.COST_FEE, null, 0, 0, 0, 1),0)) BKCX_SF_NUM,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',decode(t.COST_FEE, null, 1, 0, 1, 0),0)) BKCX_WSF_NUM,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',NVL(T.COST_FEE,0),0)) BKCXCOSTFEEAMT,");//补卡撤销总工本费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',NVL(T.URGENT_FEE,0),0)) BKCXURGAMT,");//补卡撤销总加急费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',NVL(T.RTN_FGFT,0),0)) BKCXYJAMT,");//补卡撤销总押金
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG + "',1,0)) HKNUM,");//换卡总笔数
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG + "',decode(t.COST_FEE, null, 0, 0, 0, 1),0)) HK_SF_NUM,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG + "',decode(t.COST_FEE, null, 1, 0, 1, 0),0)) HK_WSF_NUM,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG + "',NVL(T.COST_FEE,0),0)) HKCOSTFEEAMT,");//换卡总工本费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG + "',NVL(T.URGENT_FEE,0))) HKURGAMT,");//换卡总加急费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG + "',NVL(T.RTN_FGFT,0),0)) HKYJAMT,");//换卡总押金
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG_UNDO + "',1,0)) HKCXNUM,");//换卡撤销总笔数
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG_UNDO + "',decode(t.COST_FEE, null, 0, 0, 0, 1),0)) HKCX_SF_NUM,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG_UNDO + "',decode(t.COST_FEE, null, 1, 0, 1, 0),0)) HKCX_WSF_NUM,");
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG_UNDO + "',-NVL(T.COST_FEE,0),0)) HKCXCOSTFEEAMT,");//换卡撤销总工本费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG_UNDO + "',NVL(T.URGENT_FEE,0),0)) HKCXURGAMT,");//换卡撤销总加急费
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_CHG_UNDO + "',NVL(T.RTN_FGFT,0),0)) HKCXYJAMT, ");//换卡撤销总押金
			commSql.append("SUM(DECODE(T.DEAL_CODE,'" + DealCode.NAMEDCARD_REISSUE + "',1,'" + DealCode.NAMEDCARD_REISSUE_UNDO + "',-1,'" + DealCode.NAMEDCARD_CHG + "',1,'" + DealCode.NAMEDCARD_CHG_UNDO + "',-1,0)) TOTNUM,");//总笔数
			commSql.append("SUM(NVL(T.AMT,0)) TOTAMT, t.co_org_id bank_id, (select bank_name from base_bank where bank_id = t.co_org_id) bank_name ");//总金额
			commSql.append("FROM SYS_BRANCH S,TR_SERV_REC T WHERE S.BRCH_ID = T.BRCH_ID(+) ");
			if(!Tools.processNull(this.startDate).equals("")){
				commSql.append("AND T.BIZ_TIME >= TO_DATE('" + this.startDate + " 0:0:0','YYYY-MM-DD HH24:MI:SS') ");
			}
			if(!Tools.processNull(this.endDate).equals("")){
				commSql.append("AND T.BIZ_TIME <= TO_DATE('" + this.endDate + " 23:59:59','YYYY-MM-DD HH24:MI:SS') ");
			}
			commSql.append("AND T.DEAL_CODE IN ('" + DealCode.NAMEDCARD_REISSUE + "','" + DealCode.NAMEDCARD_CHG + "','" + 
					DealCode.NAMEDCARD_REISSUE_UNDO + "','" + DealCode.NAMEDCARD_CHG_UNDO + "') ");
			if(!Tools.processNull(rec.getCardType()).equals("")){
				commSql.append("AND T.CARD_TYPE = '" + rec.getCardType() + "' ");
			}
			if(!Tools.processNull(rec.getOrgId()).equals("")){
				commSql.append("AND S.ORG_ID = '" + rec.getOrgId() + "' ");
			}
			if(!Tools.processNull(rec.getBrchId()).equals("")){
				if(cascadeBrch){
					commSql.append("AND T.BRCH_ID in (select brch_id from sys_branch start with brch_id = '" + rec.getBrchId() + "' connect by prior sysbranch_id = pid) ");
				} else {
					commSql.append("AND T.BRCH_ID = '" + rec.getBrchId() + "' ");
				}
			}
			if(!Tools.processNull(region_Id).equals("")){
				commSql.append("AND s.region_id = '" + region_Id + "' ");
			}
			if(!Tools.processNull(rec.getAcptType()).equals("")){
				commSql.append("AND t.acpt_type = '" + rec.getAcptType() + "' and co_org_id is not null ");
			}
			if(!Tools.processNull(rec.getCoOrgId()).equals("")){
				commSql.append("AND t.co_org_id = '" + rec.getCoOrgId() + "' ");
			}
			commSql.append("GROUP BY S.BRCH_ID,S.FULL_NAME,T.CARD_TYPE,t.co_org_id ");
			if(Tools.processNull(this.sort).equals("")){
				commSql.append("ORDER BY t.co_org_id ");
			}else{
				commSql.append("ORDER BY " + this.sort + " " + this.order);
			}
			Page list = baseService.pagingQuery(commSql.toString(), page, rows);
			if(list.getAllRs() == null || list.getAllRs().isEmpty()){
				throw new CommonException("根据条件未查询到记录信息！");
				
			}
			jsonObject.put("rows",list.getAllRs());
			jsonObject.put("total",list.getTotalCount());
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 卡服务相关收入导出
	 * @return
	 */
	public String cardServiceIncomeExport(){
		try{
			HSSFWorkbook book = new HSSFWorkbook();
			HSSFSheet sheet = book.createSheet();
			sheet.setFitToPage(true);
			sheet.createFreezePane(3,4);
			CellRangeAddress titleRegion = new CellRangeAddress(0,0,0,20);
			titleRegion.formatAsString();
			sheet.addMergedRegion(titleRegion);
			CellStyle titleStyle = this.getCellStyleOfTitle(book);
			HSSFRow firstRow = sheet.createRow(0);
			firstRow.setHeight((short)(firstRow.getHeight() * 2));
			HSSFCell cell = firstRow.createCell(0);
			cell.setCellValue(Constants.APP_REPORT_TITLE + "卡服务收入汇总表");
			cell.setCellStyle(titleStyle);
			CellRangeAddress region0 = new CellRangeAddress(2,2,0,1);
			region0.formatAsString();
			setBorder(CellStyle.BORDER_THIN,region0,sheet,book);
			CellRangeAddress region1 = new CellRangeAddress(2,3,2,2);
			region0.formatAsString();
			setBorder(CellStyle.BORDER_THIN,region1,sheet,book);
			CellRangeAddress region2 = new CellRangeAddress(2,2,3,6);
			region0.formatAsString();
			setBorder(CellStyle.BORDER_THIN,region2,sheet,book);
			CellRangeAddress region3 = new CellRangeAddress(2,2,7,10);
			region0.formatAsString();
			setBorder(CellStyle.BORDER_THIN,region3,sheet,book);
			CellRangeAddress region4 = new CellRangeAddress(2,2,11,14);
			region4.formatAsString();
			setBorder(CellStyle.BORDER_THIN,region4,sheet,book);
			CellRangeAddress region5 = new CellRangeAddress(2,2,15,18);
			region5.formatAsString();
			setBorder(CellStyle.BORDER_THIN,region5,sheet,book);
			CellRangeAddress region6 = new CellRangeAddress(2,2,19,20);
			region6.formatAsString();
			setBorder(CellStyle.BORDER_THIN,region6,sheet,book);
			sheet.addMergedRegion(region0);
			sheet.addMergedRegion(region1);
			sheet.addMergedRegion(region2);
			sheet.addMergedRegion(region3);
			sheet.addMergedRegion(region4);
			sheet.addMergedRegion(region5);
			sheet.addMergedRegion(region6);
			HSSFFont headerFont = book.createFont();
			headerFont.setFontName("微软雅黑");
			headerFont.setBoldweight((short)(headerFont.getBoldweight()*2));
			headerFont.setFontHeight((short)(headerFont.getFontHeight()*0.9));
			headerFont.setColor(HSSFColor.BLUE.index);
			HSSFCellStyle headStyle = book.createCellStyle();
			headStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headStyle.setBorderRight(CellStyle.BORDER_THIN);
			headStyle.setBorderTop(CellStyle.BORDER_THIN);
			headStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headStyle.setFont(headerFont);
			HSSFRow dateRow = sheet.createRow(1);
			CellRangeAddress region7 = new CellRangeAddress(1,1,0,20);
			region7.formatAsString();
			//setBorder(CellStyle.BORDER_THIN,region7,sheet,book);
			sheet.addMergedRegion(region7);
			HSSFCell dateRow0 = dateRow.createCell(0);
			dateRow0.setCellValue("汇总周期：" + this.startDate + " ~ " + this.endDate + "    导出时间：" + DateUtil.formatDate(baseService.getDateBaseTime(),"yyyy-MM-dd HH:mm:ss"));
			dateRow0.setCellStyle(this.getCellStyleOfDateColumn(book));
			HSSFRow secRow = sheet.createRow(2);
			for(int d = 0;d <= 20; d++){
				secRow.createCell(d).setCellStyle(headStyle);
			}
			HSSFCell secCell0 = secRow.createCell(0);
			secCell0.setCellValue("网点信息");
			secCell0.setCellStyle(headStyle);
			HSSFCell secCell1 = secRow.createCell(2);
			secCell1.setCellValue("卡类型");
			secCell1.setCellStyle(headStyle);
			HSSFCell secCell2 = secRow.createCell(3);
			secCell2.setCellValue("补卡");
			secCell2.setCellStyle(headStyle);
			HSSFCell secCell3 = secRow.createCell(7);
			secCell3.setCellValue("补卡撤销");
			secCell3.setCellStyle(headStyle);
			HSSFCell secCell4 = secRow.createCell(11);
			secCell4.setCellValue("换卡");
			secCell4.setCellStyle(headStyle);
			HSSFCell secCell5 = secRow.createCell(15);
			secCell5.setCellValue("换卡撤销");
			secCell5.setCellStyle(headStyle);
			HSSFCell secCell6 = secRow.createCell(19);
			secCell6.setCellValue("合计");
			secCell6.setCellStyle(headStyle);
			HSSFRow tidRow = sheet.createRow(3);
			HSSFCell tidCell0 = tidRow.createCell(0);
			tidCell0.setCellValue("网点编号");
			tidCell0.setCellStyle(headStyle);
			HSSFCell tidCell1 = tidRow.createCell(1);
			tidCell1.setCellValue("网点名称");
			tidCell1.setCellStyle(headStyle);
			HSSFCell tidCell2 = tidRow.createCell(2);
			tidCell2.setCellStyle(headStyle);
			for(int i = 3;i < 16;i+=4){
				HSSFCell tidTemp1 = tidRow.createCell(i);
				tidTemp1.setCellValue("笔数");
				tidTemp1.setCellStyle(headStyle);
				HSSFCell tidTemp2 = tidRow.createCell(i + 1);
				tidTemp2.setCellValue("收费笔数");
				tidTemp2.setCellStyle(headStyle);
				HSSFCell tidTemp3 = tidRow.createCell(i + 2);
				tidTemp3.setCellValue("未收费笔数");
				tidTemp3.setCellStyle(headStyle);
				HSSFCell tidTemp4 = tidRow.createCell(i + 3);
				tidTemp4.setCellValue("金额");
				tidTemp4.setCellStyle(headStyle);
			}
			HSSFCell tidCell5 = tidRow.createCell(19);
			tidCell5.setCellValue("总笔数");
			tidCell5.setCellStyle(headStyle);
			HSSFCell tidCell6 = tidRow.createCell(20);
			tidCell6.setCellValue("总金额");
			tidCell6.setCellStyle(headStyle);
			this.queryType = "0";
			this.exportFlag = "0";
			cardServiceIncomeStat();
			if(!Tools.processNull(this.jsonObject.getString("status")).equals("0")){
				throw new CommonException(Tools.processNull(this.getJsonObject().getString("errMsg")));
			}
			com.alibaba.fastjson.JSONArray rows = this.jsonObject.getJSONArray("rows");
			int rowNum = 4;
			CellStyle commonStyle = this.getCellStyleOfData(book);
			if(rows != null && rows.size() > 0){
				for (Object object : rows) {
					JSONObject tempRowData = (JSONObject) object;
					HSSFRow tempRow = sheet.createRow(rowNum);
					HSSFCell tempCell0 = tempRow.createCell(0);
					tempCell0.setCellValue(tempRowData.getString("BRCH_ID"));
					tempCell0.setCellStyle(commonStyle);
					HSSFCell tempCell1 = tempRow.createCell(1);
					tempCell1.setCellValue(tempRowData.getString("FULL_NAME"));
					tempCell1.setCellStyle(commonStyle);
					HSSFCell tempCell2 = tempRow.createCell(2);
					tempCell2.setCellStyle(commonStyle);
					tempCell2.setCellValue(tempRowData.getString("CARDTYPE"));
					HSSFCell tempCell3 = tempRow.createCell(3);
					tempCell3.setCellStyle(commonStyle);
					tempCell3.setCellValue(tempRowData.getString("BKNUM"));
					HSSFCell tempCell4 = tempRow.createCell(4);
					tempCell4.setCellStyle(commonStyle);
					tempCell4.setCellValue(tempRowData.getString("BK_SF_NUM"));
					HSSFCell tempCell5 = tempRow.createCell(5);
					tempCell5.setCellStyle(commonStyle);
					tempCell5.setCellValue(tempRowData.getString("BK_WSF_NUM"));
					HSSFCell tempCell6 = tempRow.createCell(6);
					tempCell6.setCellStyle(commonStyle);
					String add1 = Arith.add(tempRowData.getString("BKYJAMT"), tempRowData.getString("BKCOSTFEEAMT"));
					String add2 = Arith.add(add1, tempRowData.getString("BKURGAMT"));
					tempCell6.setCellValue(Arith.cardreportsmoneydiv(add2));
					HSSFCell tempCell7 = tempRow.createCell(7);
					tempCell7.setCellStyle(commonStyle);
					tempCell7.setCellValue(tempRowData.getString("BKCXNUM"));
					HSSFCell tempCell8 = tempRow.createCell(8);
					tempCell8.setCellStyle(commonStyle);
					tempCell8.setCellValue(tempRowData.getString("BKCX_SF_NUM"));
					HSSFCell tempCell9 = tempRow.createCell(9);
					tempCell9.setCellStyle(commonStyle);
					tempCell9.setCellValue(tempRowData.getString("BKCX_WSF_NUM"));
					HSSFCell tempCell10 = tempRow.createCell(10);
					tempCell10.setCellStyle(commonStyle);
					tempCell10.setCellValue(Arith.cardreportsmoneydiv(Arith.add(tempRowData.getString("BKCXCOSTFEEAMT"), tempRowData.getString("BKCXURGAMT"), tempRowData.getString("BKCXYJAMT"))));
					HSSFCell tempCell11 = tempRow.createCell(11);
					tempCell11.setCellStyle(commonStyle);
					tempCell11.setCellValue(tempRowData.getString("HKNUM"));
					HSSFCell tempCell12 = tempRow.createCell(12);
					tempCell12.setCellStyle(commonStyle);
					tempCell12.setCellValue(tempRowData.getString("HK_SF_NUM"));
					HSSFCell tempCell13 = tempRow.createCell(13);
					tempCell13.setCellStyle(commonStyle);
					tempCell13.setCellValue(tempRowData.getString("HK_WSF_NUM"));
					HSSFCell tempCell14 = tempRow.createCell(14);
					tempCell14.setCellStyle(commonStyle);
					tempCell14.setCellValue(Arith.cardreportsmoneydiv(Arith.add(tempRowData.getString("HKCOSTFEEAMT"), tempRowData.getString("HKURGAMT"), tempRowData.getString("HKURGAMT"))));
					HSSFCell tempCell15 = tempRow.createCell(15);
					tempCell15.setCellStyle(commonStyle);
					tempCell15.setCellValue(tempRowData.getString("HKCXNUM"));
					HSSFCell tempCell16 = tempRow.createCell(16);
					tempCell16.setCellStyle(commonStyle);
					tempCell16.setCellValue(tempRowData.getString("HKCX_SF_NUM"));
					HSSFCell tempCell17 = tempRow.createCell(17);
					tempCell17.setCellStyle(commonStyle);
					tempCell17.setCellValue(tempRowData.getString("HKCX_WSF_NUM"));
					HSSFCell tempCell18 = tempRow.createCell(18);
					tempCell18.setCellStyle(commonStyle);
					tempCell18.setCellValue(Arith.cardreportsmoneydiv(Arith.add(tempRowData.getString("HKCXCOSTFEEAMT"), tempRowData.getString("HKCXURGAMT"), tempRowData.getString("HKCXYJAMT"))));
					HSSFCell tempCell19 = tempRow.createCell(19);
					tempCell19.setCellStyle(commonStyle);
					tempCell19.setCellValue(tempRowData.getString("TOTNUM"));
					HSSFCell tempCell20 = tempRow.createCell(20);
					tempCell20.setCellStyle(commonStyle);
					tempCell20.setCellValue(Arith.cardreportsmoneydiv(tempRowData.getString("TOTAMT")));
					rowNum++;
				}
			}
			CellRangeAddress tailRegion = new CellRangeAddress(rowNum,rowNum,0,2);
	    	tailRegion.formatAsString();
			setBorder(CellStyle.BORDER_THIN,tailRegion,sheet,book);
			sheet.addMergedRegion(tailRegion);
			HSSFRow tailRow = sheet.createRow(rowNum);
			HSSFCell tailCell0 = tailRow.createCell(0);
			tailCell0.setCellValue("合计");
			tailCell0.setCellStyle(commonStyle);
			HSSFCell tailCell1 = tailRow.createCell(1);
			tailCell1.setCellStyle(commonStyle);
			HSSFCell tailCell2 = tailRow.createCell(2);
			tailCell2.setCellStyle(commonStyle);
			com.alibaba.fastjson.JSONArray tailRowDataArray = this.getJsonObject().getJSONArray("footer");
			if(tailRowDataArray != null && tailRowDataArray.size() > 0){
				JSONObject tailRowData = tailRowDataArray.getJSONObject(0);
				if(tailRowData != null){
					HSSFCell tailCell3 = tailRow.createCell(3);
					tailCell3.setCellStyle(commonStyle);
					tailCell3.setCellValue(tailRowData.getString("BKNUM"));
					HSSFCell tailCell4 = tailRow.createCell(4);
					tailCell4.setCellStyle(commonStyle);
					tailCell4.setCellValue(tailRowData.getString("BK_SF_NUM"));
					HSSFCell tailCell5 = tailRow.createCell(5);
					tailCell5.setCellStyle(commonStyle);
					tailCell5.setCellValue(tailRowData.getString("BK_WSF_NUM"));
					HSSFCell tailCell6 = tailRow.createCell(6);
					tailCell6.setCellStyle(commonStyle);
					tailCell6.setCellValue(Arith.cardreportsmoneydiv(Arith.add(tailRowData.getString("BKYJAMT"), tailRowData.getString("BKCOSTFEEAMT"), tailRowData.getString("BKURGAMT"))));
					HSSFCell tailCell7 = tailRow.createCell(7);
					tailCell7.setCellStyle(commonStyle);
					tailCell7.setCellValue(tailRowData.getString("BKCXNUM"));
					HSSFCell tailCell8 = tailRow.createCell(8);
					tailCell8.setCellStyle(commonStyle);
					tailCell8.setCellValue(tailRowData.getString("BKCX_SF_NUM"));
					HSSFCell tailCell9 = tailRow.createCell(9);
					tailCell9.setCellStyle(commonStyle);
					tailCell9.setCellValue(tailRowData.getString("BKCX_WSF_NUM"));
					HSSFCell tailCell10 = tailRow.createCell(10);
					tailCell10.setCellStyle(commonStyle);
					tailCell10.setCellValue(Arith.cardreportsmoneydiv(Arith.add(tailRowData.getString("BKCXCOSTFEEAMT"), tailRowData.getString("BKCXURGAMT"), tailRowData.getString("BKCXYJAMT"))));
					HSSFCell tailCell11 = tailRow.createCell(11);
					tailCell11.setCellStyle(commonStyle);
					tailCell11.setCellValue(tailRowData.getString("HKNUM"));
					HSSFCell tailCell12 = tailRow.createCell(12);
					tailCell12.setCellStyle(commonStyle);
					tailCell12.setCellValue(tailRowData.getString("HK_SF_NUM"));
					HSSFCell tailCell13 = tailRow.createCell(13);
					tailCell13.setCellStyle(commonStyle);
					tailCell13.setCellValue(tailRowData.getString("HK_WSF_NUM"));
					HSSFCell tailCell14 = tailRow.createCell(14);
					tailCell14.setCellStyle(commonStyle);
					tailCell14.setCellValue(Arith.cardreportsmoneydiv(Arith.add(tailRowData.getString("HKCOSTFEEAMT"), tailRowData.getString("HKURGAMT"), tailRowData.getString("HKYJAMT"))));
					HSSFCell tailCell15 = tailRow.createCell(15);
					tailCell15.setCellStyle(commonStyle);
					tailCell15.setCellValue(tailRowData.getString("HKCXNUM"));
					HSSFCell tailCell16 = tailRow.createCell(16);
					tailCell16.setCellStyle(commonStyle);
					tailCell16.setCellValue(tailRowData.getString("HKCX_SF_NUM"));
					HSSFCell tailCell17 = tailRow.createCell(17);
					tailCell17.setCellStyle(commonStyle);
					tailCell17.setCellValue(tailRowData.getString("HKCX_WSF_NUM"));
					HSSFCell tailCell18 = tailRow.createCell(18);
					tailCell18.setCellStyle(commonStyle);
					tailCell18.setCellValue(Arith.cardreportsmoneydiv(Arith.add(tailRowData.getString("HKCXCOSTFEEAMT"), tailRowData.getString("HKCXURGAMT"), tailRowData.getString("HKCXYJAMT"))));
					HSSFCell tailCell19 = tailRow.createCell(19);
					tailCell19.setCellStyle(commonStyle);
					tailCell19.setCellValue(tailRowData.getString("TOTNUM"));
					HSSFCell tailCell20 = tailRow.createCell(20);
					tailCell20.setCellStyle(commonStyle);
					tailCell20.setCellValue(Arith.cardreportsmoneydiv(tailRowData.getString("TOTAMT")));
				}
			}
			sheet.autoSizeColumn(1,true);
			OutputStream out = this.response.getOutputStream();
			this.response.setContentType("application/vnd.ms-excel");
			this.response.setCharacterEncoding("UTF-8");
			this.response.setHeader("Content-Disposition", "attachment; filename=\"" + URLEncoder.encode( Constants.APP_REPORT_TITLE + "卡服务收入汇总（" + this.startDate + "--" + this.endDate + "）", "UTF-8") + ".xls\"");
			book.write(out);
			SecurityUtils.getSubject().getSession().setAttribute("cardServiceIncomeExportDownloadSuc",Constants.YES_NO_YES);
			out.flush();
		}catch(Exception e){
			this.defaultErrMsg = e.getMessage();
			return "cardServiceIncomeStat";
		}
		return null;
	}
	/**
	 * 
	 * Description <p>TODO</p>
	 * @return
	 */
	public String querySysPayReadyRp(){
		initBaseDataGrid();
		try {
			StringBuffer payReadySql = new StringBuffer();
			payReadySql.append("select decode(t.STAT_IN_OUT_FLAG,1,'收入','2','支出','3','账户互转','4','其他') in_out_flag,");
			payReadySql.append("t1.stat_item_name deal_name,");
			
			payReadySql.append("(select nvl(sum(per_num), 0) from (SELECT sum(end_num) OVER(partition by t3.stat_deal_code "
					+ " order by t3.clr_date desc) per_num, t3.stat_deal_code stat_deal_code,rank() over(partition by "
					+ " t3.stat_deal_code order by t3.clr_date desc) MM from stat_readypayamt_data t3  WHERE 1 = 1 and "
					+ " t3.clr_date < '"+startDate+"') a where 1 = 1 and a.mm = 1 and a.stat_deal_code = t.stat_deal_code) per_num,");
			payReadySql.append("(select nvl(sum(per_amt), 0) from (SELECT sum(end_amt) OVER(partition by t3.stat_deal_code "
					+ " order by t3.clr_date desc) per_amt, t3.stat_deal_code stat_deal_code, rank() over(partition by "
					+ " t3.stat_deal_code order by t3.clr_date desc) MM from stat_readypayamt_data t3 WHERE 1 = 1 and "
					+ " t3.clr_date < '"+startDate+"') a  where 1 = 1 and a.mm = 1 and a.stat_deal_code = t.stat_deal_code) per_amt, ");
			
			payReadySql.append("sum(t.num) num,sum(t.amt) amt,");
			
			payReadySql.append("(select nvl(sum(end_num), 0) from (SELECT sum(end_num) OVER(partition by t3.stat_deal_code "
					+ " order by t3.clr_date desc) end_num, t3.stat_deal_code stat_deal_code,rank() over(partition by "
					+ " t3.stat_deal_code order by t3.clr_date desc) MM from stat_readypayamt_data t3  WHERE 1 = 1 and "
					+ " t3.clr_date <= '"+endDate+"') a where 1 = 1 and a.mm = 1 and a.stat_deal_code = t.stat_deal_code) end_num,");
			payReadySql.append("(select nvl(sum(end_amt), 0) from (SELECT sum(end_amt) OVER(partition by t3.stat_deal_code "
					+ " order by t3.clr_date desc) end_amt, t3.stat_deal_code stat_deal_code, rank() over(partition by "
					+ " t3.stat_deal_code order by t3.clr_date desc) MM from stat_readypayamt_data t3 WHERE 1 = 1 and "
					+ " t3.clr_date <= '"+endDate+"') a  where 1 = 1 and a.mm = 1 and a.stat_deal_code = t.stat_deal_code) end_amt ");
			payReadySql.append(" from stat_readypayamt_data t,stat_readypayamt_conf t1 where "
					+ " t.stat_deal_code = t1.stat_item(+) ");
			
			if(!Tools.processNull(startDate).equals("")){
				payReadySql.append(" and t.clr_date >= '"+startDate+"'");
			}
			
			if(!Tools.processNull(endDate).equals("")){
				payReadySql.append(" and t.clr_date <= '"+endDate+"'");
			}
			
			payReadySql.append("group by t.STAT_IN_OUT_FLAG,t.stat_deal_code,t1.stat_item_name,t1.order_number ");
			
			if(Tools.processNull(this.sort).equals("")){
				payReadySql.append("order by t1.order_number ");
			}else{
				payReadySql.append("ORDER BY " + this.sort + " " + this.order);
			}
			Page listview = baseService.pagingQuery(payReadySql.toString(), page, rows);
			if(listview.getAllRs() == null || listview.getAllRs().size() <= 0){
				throw new CommonException("未查询到对应卡信息，不能进行挂失！");
				}else{
					jsonObject.put("rows",listview.getAllRs());
					jsonObject.put("total",listview.getTotalCount());
				}
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 查询备付金报表
	 * Description <p>TODO</p>
	 * @return
	 */
	public String rechargeCompeareRp(){
		initBaseDataGrid();
		try {
			if(Tools.processNull(qyMonth).equals("")){
				throw new CommonException("起始月份不能为空.");
			} else if(Tools.processNull(qyMonthEnd).equals("")){
				throw new CommonException("结束月份不能为空.");
			}
			String merchantIdSql = "";
			if (!Tools.processNull(checkIds).equals("")) {
				String[] merchantIdArr = checkIds.split(",");
				for (String merchantId : merchantIdArr) {
					merchantIdSql += "'" + merchantId + "',";
				}
				merchantIdSql = merchantIdSql.substring(0, merchantIdSql.length()-1);
			}
			Date startDate = DateUtil.parse("yyyy-MM", qyMonth);
			Date endDate = DateUtil.parse("yyyy-MM", qyMonthEnd);
			Calendar endDateCal = Calendar.getInstance();
			endDateCal.setTime(endDate);
			// 本年 开始&结束
			String startDateMonth = qyMonth;
			String endDateMonth = qyMonthEnd;
			String nowYearStartDateMonth = qyMonthEnd.substring(0, 5) + "01"; // 本年1月份
			//上一年的开始月份
			Calendar lastStartDateCal = Calendar.getInstance();
			lastStartDateCal.setTime(startDate);
			lastStartDateCal.add(Calendar.YEAR, -1);
			String lastStartDateMonth = DateUtil.formatDate(lastStartDateCal.getTime(), "yyyy-MM");
			//上一年的结束月份
			Calendar lastEndDateCal = Calendar.getInstance();
			lastEndDateCal.setTime(endDate);
			lastEndDateCal.add(Calendar.YEAR, -1);
			String lastEndDateMonth = DateUtil.formatDate(lastEndDateCal.getTime(), "yyyy-MM");
			String lastYearstartDateMonth = lastEndDateMonth.substring(0, 5) + "01";// 上年1月份
			
			StringBuffer rechargeCompareSQL = new StringBuffer();
			rechargeCompareSQL.append("select merchant_id, merchant_name,fee_rate,cur_num,cur_amt,old_amt,decode(old_amt,0,'',trim(to_char(((cur_amt-old_amt)/old_amt)*100,'999990.99'))||'%') cur_cop_info,cur_fee,cur_tot_num,cur_tot_amt,old_tot_amt,");
			rechargeCompareSQL.append(" decode(old_tot_amt,0,'',trim(to_char(((cur_tot_amt-old_tot_amt)/old_tot_amt)*100,'999990.99'))||'%') tot_cop_info,cur_year_fee from ");
			rechargeCompareSQL.append(" (select t1.merchant_id, t1.merchant_name,(select '联机账户消费费率'||trim(to_char(aa/100,'99990.99'))||'%；'||'联机消费退货费率'||trim(to_char(bb/100,'99990.99'))||'；%'||'电子钱包消费费率'||trim(to_char(cc/100,'99990.99'))||'%' from (");
			rechargeCompareSQL.append(" (SELECT a.merchant_id ,sum(case a.deal_code when 40201010 then fee_rate else 0 end)  aa,sum(case a.deal_code  when 40201051 then fee_rate  else 0 end)  bb,sum(case a.deal_code when 40101010 then");
			rechargeCompareSQL.append(" fee_rate else 0 end) cc FROM pay_fee_rate a WHERE  a.begindate = (SELECT MAX(begindate) FROM pay_fee_rate WHERE merchant_id = a.merchant_id AND fee_state = '0' AND begindate <= to_date(to_char(sysdate,'yyyy-mm-dd'), 'yyyy-mm-dd'))");
			rechargeCompareSQL.append(" group by a.merchant_id)) c where c.merchant_id = t1.merchant_id) fee_rate,nvl((select sum(deal_num) from pay_clr_sum where merchant_id = t1.merchant_id and substr(clr_date,0,7) >= '" + startDateMonth + "' and substr(clr_date,0,7) <= '"+endDateMonth+"'),0) cur_num,");
			rechargeCompareSQL.append(" nvl((select sum(deal_amt) from pay_clr_sum where merchant_id = t1.merchant_id and substr(clr_date,0,7) >= '" + startDateMonth + "' and substr(clr_date,0,7) <= '"+endDateMonth+"'),0) cur_amt,nvl((select sum(deal_amt) from pay_clr_sum where merchant_id = t1.merchant_id and substr(clr_date,0,7) >= '" + lastStartDateMonth + "' and substr(clr_date,0,7) <= '"+lastEndDateMonth+"'),0) old_amt,");
			rechargeCompareSQL.append(" nvl((select sum(DEAL_FEE) from stl_deal_sum where merchant_id = t1.merchant_id and substr(stl_date,0,7) >= '" + startDateMonth + "' and substr(stl_date,0,7) <= '"+endDateMonth+"'),0) cur_fee,nvl((select sum(deal_num) from pay_clr_sum where merchant_id = t1.merchant_id and substr(clr_date,0,7)>= '"+nowYearStartDateMonth+"' and substr(clr_date,0,7)<= '"+endDateMonth+"'),0) cur_tot_num,");
			rechargeCompareSQL.append(" nvl((select sum(deal_amt) from pay_clr_sum where merchant_id = t1.merchant_id and substr(clr_date,0,7)>= '"+nowYearStartDateMonth+"' and substr(clr_date,0,7)<= '"+endDateMonth+"'),0) cur_tot_amt,nvl((select sum(deal_amt) from pay_clr_sum where merchant_id = t1.merchant_id and substr(clr_date,0,7)>= '"+lastYearstartDateMonth+"' and substr(clr_date,0,7)<= '"+lastEndDateMonth+"'),0) old_tot_amt,");
			rechargeCompareSQL.append(" nvl((select sum(DEAL_FEE) from stl_deal_sum where merchant_id = t1.merchant_id and substr(stl_date,0,7)>= '"+nowYearStartDateMonth+"' and substr(stl_date,0,7)<= '"+endDateMonth+"'),0) cur_year_fee from (select distinct t.merchant_id,t.merchant_name,");
			rechargeCompareSQL.append(" t.top_merchant_id,level, connect_by_isleaf from base_merchant t where 1 = 1 start with t.top_merchant_id is null connect by prior t.customer_id = t.top_merchant_id order by t.merchant_id asc) t1 ");
			rechargeCompareSQL.append(" start with t1.top_merchant_id is null connect by prior t1.merchant_id = t1.top_merchant_id) t where 1 = 1 ");
			if(!Tools.processNull(merchantId).equals("")){
				rechargeCompareSQL.append("and t.merchant_id = '" + merchantId + "' ");
			}
			if(!Tools.processNull(merchantIdSql).equals("")){
				rechargeCompareSQL.append("and t.merchant_id in (" + merchantIdSql + ") ");
			}
			if(Tools.processNull(this.sort).equals("")){
				rechargeCompareSQL.append("ORDER BY merchant_name  ASC ");
			}else{
				rechargeCompareSQL.append("ORDER BY " + this.sort + " " + this.order);
			}
			Page listview = baseService.pagingQuery(rechargeCompareSQL.toString(), page, rows);
			if(listview.getAllRs() == null || listview.getAllRs().size() <= 0){
				throw new CommonException("未查询到对应卡信息，不能进行挂失！");
			}else{
				jsonObject.put("rows",listview.getAllRs());
				jsonObject.put("total",listview.getTotalCount());
			}
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String exportMerchantConsumeCompareReport(){
		try {
			rechargeCompeareRp();
			String fileName = "商户交易同比对比_" + qyMonth + " ~ " + qyMonthEnd;
			if(!Tools.processNull(merchantId).equals("")){
				String brchName = (String) baseService.findOnlyFieldBySql("select merchant_name from base_merchant where merchant_id = '" + merchantId + "'");
				fileName = brchName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 12000);
			sheet.setColumnWidth(1, 16500);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 3000);
			sheet.setColumnWidth(4, 3000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 3000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 3000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 3000);
			sheet.setColumnWidth(11, 3000);

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

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);
			
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));

			// head row 1
			int maxColumn = 12;
			int headRows = 4;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			// second header
			String time = "导出时间：" + DateUtils.getNowTime();
			if (!Tools.processNull(startDate).equals("")) {
				time = "业务时间：" + startDate + " ~ " + endDate + "    " + time;
			}
			sheet.getRow(1).getCell(0).setCellValue(time);
			
			// third header
			sheet.getRow(2).getCell(0).setCellValue("商户名称");
			sheet.getRow(2).getCell(1).setCellValue("费率");
			sheet.getRow(2).getCell(2).setCellValue("本期交易");
			sheet.getRow(2).getCell(7).setCellValue("本年累计交易");
			// third header
			sheet.getRow(3).getCell(2).setCellValue("交易笔数");
			sheet.getRow(3).getCell(3).setCellValue("交易金额");
			sheet.getRow(3).getCell(4).setCellValue("去年同期");
			sheet.getRow(3).getCell(5).setCellValue("同比");
			sheet.getRow(3).getCell(6).setCellValue("手续费");
			sheet.getRow(3).getCell(7).setCellValue("交易笔数");
			sheet.getRow(3).getCell(8).setCellValue("交易金额");
			sheet.getRow(3).getCell(9).setCellValue("去年同期");
			sheet.getRow(3).getCell(10).setCellValue("同比");
			sheet.getRow(3).getCell(11).setCellValue("手续费");
			
			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 1, 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 2, 6));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 7, 11));
			sheet.createFreezePane(2, 4);
			
			double curPeriodNumSum = 0;
			double curPeriodAmtSum = 0;
			double lastPeriodAmtSum = 0;
			double curPeriodFeeAmtSum = 0;
			double curYearNumSum = 0;
			double curYearAmtSum = 0;
			double lastYearAmtSum = 0;
			double curYearFeeAmtSum = 0;
			int numSum = 0;
			for (int i = 0; i < data.size(); i++, numSum++) {
				JSONObject item = data.getJSONObject(i);
				
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j == 3 || j == 4 || j == 6 || j == 8 || j == 9 || j == 11) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				double curPeriodNum = Tools.processNull(item.getString("CUR_NUM")).equals("")?0:item.getDoubleValue("CUR_NUM");
				double curPeriodAmt = Tools.processNull(item.getString("CUR_AMT")).equals("")?0:item.getDoubleValue("CUR_AMT");
				double lastPeriodAmt = Tools.processNull(item.getString("OLD_AMT")).equals("")?0:item.getDoubleValue("OLD_AMT");
				double curPeriodFeeAmt = Tools.processNull(item.getString("CUR_FEE")).equals("")?0:item.getDoubleValue("CUR_FEE");
				double curYearNum = Tools.processNull(item.getString("CUR_TOT_NUM")).equals("")?0:item.getDoubleValue("CUR_TOT_NUM");
				double curYearAmt = Tools.processNull(item.getString("CUR_TOT_AMT")).equals("")?0:item.getDoubleValue("CUR_TOT_AMT");
				double lastYearAmt = Tools.processNull(item.getString("OLD_TOT_AMT")).equals("")?0:item.getDoubleValue("OLD_TOT_AMT");
				double curYearFeeAmt = Tools.processNull(item.getString("CUR_YEAR_FEE")).equals("")?0:item.getDoubleValue("CUR_YEAR_FEE");
				//
				curPeriodNumSum += curPeriodNum;
				curPeriodAmtSum += curPeriodAmt;
				lastPeriodAmtSum += lastPeriodAmt;
				curPeriodFeeAmtSum += curPeriodFeeAmt;
				curYearNumSum += curYearNum;
				curYearAmtSum += curYearAmt;
				lastYearAmtSum += lastYearAmt;
				curYearFeeAmtSum += curYearFeeAmt;
				//
				row.getCell(0).setCellValue(item.getString("MERCHANT_NAME"));
				row.getCell(1).setCellValue(item.getString("FEE_RATE"));
				row.getCell(2).setCellValue(curPeriodNum);
				row.getCell(3).setCellValue(curPeriodAmt / 100);
				row.getCell(4).setCellValue(lastPeriodAmt / 100);
				row.getCell(5).setCellValue(item.getString("CUR_COP_INFO"));
				row.getCell(6).setCellValue(curPeriodFeeAmt / 100);
				row.getCell(7).setCellValue(curYearNum);
				row.getCell(8).setCellValue(curYearAmt / 100);
				row.getCell(9).setCellValue(lastYearAmt / 100);
				row.getCell(10).setCellValue(item.getString("TOT_COP_INFO"));
				row.getCell(11).setCellValue(curYearFeeAmt / 100);
			}
			
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if(j == 3 || j == 4 || j == 6 || j == 8 || j == 9 || j == 11){
					cell.setCellStyle(moneyCellStyle);
				}else{
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(1).setCellValue("共 " + numSum + " 个商户");
			row.getCell(2).setCellValue(curPeriodNumSum);
			row.getCell(3).setCellValue(curPeriodAmtSum / 100);
			row.getCell(4).setCellValue(lastPeriodAmtSum / 100);
			if(lastPeriodAmtSum == 0){
				row.getCell(5).setCellValue("");
			} else {
				double d = ((curPeriodAmtSum - lastPeriodAmtSum) / lastPeriodAmtSum) * 100;
				row.getCell(5).setCellValue(Arith.round(d, 2) + "%");
			}
			row.getCell(6).setCellValue(curPeriodFeeAmtSum);
			row.getCell(7).setCellValue(curYearNumSum);
			row.getCell(8).setCellValue(curYearAmtSum / 100);
			row.getCell(9).setCellValue(lastYearAmtSum / 100);
			if(lastYearAmtSum == 0){
				row.getCell(10).setCellValue("");
			} else {
				double d = ((curYearAmtSum - lastYearAmtSum) / lastYearAmtSum) * 100;
				row.getCell(10).setCellValue(Arith.round(d, 2) + "%");
			}
			row.getCell(11).setCellValue(curYearFeeAmtSum / 100);
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	/**
	 * 查询商户消费比对信息
	 */
	public String queryConsumeCompareRp(){
		initBaseDataGrid();
		try {
			//统计年的当前月份
			String nowDateMonth = qyMonth;
			Date nowDate = DateUtil.parse("yyyy-MM", qyMonth);
			Calendar nowDateCal = Calendar.getInstance();
			nowDateCal.setTime(nowDate);
			int nowyear = nowDateCal.get(Calendar.YEAR);
			//统计年的1月份
			String nowyearstartMonth = nowyear + "-01"; 
			
			Calendar lastnowDateCal = Calendar.getInstance();
			lastnowDateCal.setTime(nowDate);
			lastnowDateCal.add(Calendar.DAY_OF_YEAR, -1);
			//上一年的当前月份
			String lastnowDateMonth = lastnowDateCal.get(Calendar.YEAR)+"-"+lastnowDateCal.get(Calendar.MONTH);
			//上一年的1月份
			String lastnowStartMonth = lastnowDateCal.get(Calendar.YEAR)+"-01";
			StringBuffer rechargeCompareSQL = new StringBuffer();
			rechargeCompareSQL.append("select BRCH_NAME,OFFLINE_CUR_AMT,ONLINE_CUR_AMT,(OFFLINE_CUR_AMT+ ONLINE_CUR_AMT) CUR_TOTAL,OLD_AMT,"
					+ " (decode(OLD_AMT,0,0,abs((OFFLINE_CUR_AMT + ONLINE_CUR_AMT) - OLD_AMT)/OLD_AMT)*100||'%') CUR_COMPARE_INFO,OFFLINE_CURALL_AMT,"
					+ " ONLINE_CURALL_AMT,(OFFLINE_CURALL_AMT+ONLINE_CURALL_AMT) ALL_TOTAL,OLDALL_AMT, (decode(OLDALL_AMT,0,0,abs((OFFLINE_CURALL_AMT + ONLINE_CURALL_AMT) - OLDALL_AMT )/OLDALL_AMT)*100||'%')  OLD_COMPARE_INFO "
					+ " from(");
			rechargeCompareSQL.append(" select LPAD('+',level*5-1,'+')||t.full_name BRCH_NAME,");
			rechargeCompareSQL.append(" (select nvl(sum(t1.amt),0) from stat_day_bal_data t1 where "
					+ " t1.own_type = '2' and substr(t1.clr_date,0,7) = '"+nowDateMonth+"' and t1.brch_id in "
					+ " (select c.brch_id from sys_branch c start with c.sysbranch_id  = t.sysbranch_id "
					+ " connect by prior c.sysbranch_id = c.pid) and t1.stat_key= 'offline_in' ) OFFLINE_CUR_AMT,");
			rechargeCompareSQL.append(" (select nvl(sum(t1.amt),0) from stat_day_bal_data t1 where t1.own_type = '2' "
					+ " and substr(t1.clr_date,0,7) = '"+nowDateMonth+"' and t1.brch_id in (select c.brch_id from sys_branch "
					+ " c start with c.sysbranch_id  = t.sysbranch_id connect by prior c.sysbranch_id = c.pid) and "
					+ " t1.stat_key= 'online_in') ONLINE_CUR_AMT,");
			
			rechargeCompareSQL.append(" ((select nvl(sum(t1.amt),0) from stat_day_bal_data t1 where t1.own_type = '2' and "
					+ " substr(t1.clr_date,0,7) = '"+lastnowDateMonth+"' and t1.brch_id in (select c.brch_id from sys_branch c start "
					+ " with c.sysbranch_id  = t.sysbranch_id connect by prior c.sysbranch_id = c.pid) and t1.stat_key= 'offline_in' )");
			rechargeCompareSQL.append(" +(select nvl(sum(t1.amt),0) from stat_day_bal_data t1 where t1.own_type = '2' "
					+ " and substr(t1.clr_date,0,7) = '"+lastnowDateMonth+"' and t1.brch_id in (select c.brch_id from sys_branch c "
					+ " start with c.sysbranch_id  = t.sysbranch_id connect by prior c.sysbranch_id = c.pid) and t1.stat_key= 'online_in')");
			rechargeCompareSQL.append(" ) OLD_AMT, ");
			rechargeCompareSQL.append(" (select nvl(sum(t1.amt),0) from stat_day_bal_data t1 where t1.own_type = '2' "
					+ " and substr(t1.clr_date,0,7) >= '"+nowyearstartMonth+"' and substr(t1.clr_date,0,7) <= '"+nowDateMonth+"'  and t1.brch_id "
					+ " in (select c.brch_id from sys_branch c start with c.sysbranch_id  = t.sysbranch_id connect by prior "
					+ " c.sysbranch_id = c.pid) and t1.stat_key= 'offline_in' ) OFFLINE_CURALL_AMT,");
			rechargeCompareSQL.append(" (select nvl(sum(t1.amt),0) from stat_day_bal_data t1 where t1.own_type = '2' "
					+ " and substr(t1.clr_date,0,7) >= '"+nowyearstartMonth+"' and substr(t1.clr_date,0,7) <= '"+nowDateMonth+"' and t1.brch_id "
					+ " in (select c.brch_id from sys_branch c start with c.sysbranch_id  = t.sysbranch_id connect by prior "
					+ " c.sysbranch_id = c.pid) and t1.stat_key= 'online_in') ONLINE_CURALL_AMT,");
			rechargeCompareSQL.append(" ((select nvl(sum(t1.amt),0) from stat_day_bal_data t1 where t1.own_type = '2' and  "
					+ " substr(t1.clr_date,0,7) >= '"+lastnowStartMonth+"' and substr(t1.clr_date,0,7) <= '"+lastnowDateMonth+"'  and t1.brch_id in "
					+ " (select c.brch_id from sys_branch c start with c.sysbranch_id  = t.sysbranch_id connect by prior "
					+ " c.sysbranch_id = c.pid) and t1.stat_key= 'offline_in' )");
			rechargeCompareSQL.append(" +(select nvl(sum(t1.amt),0) from stat_day_bal_data t1 where t1.own_type = '2' "
					+ " and substr(t1.clr_date,0,7) >= '"+lastnowStartMonth+"' and substr(t1.clr_date,0,7) <= '"+lastnowDateMonth+"' and "
					+ " t1.brch_id in (select c.brch_id from sys_branch c start with c.sysbranch_id  = t.sysbranch_id "
					+ " connect by prior c.sysbranch_id = c.pid) and t1.stat_key= 'online_in')");
			rechargeCompareSQL.append(" ) OLDALL_AMT from ( SELECT distinct t.sysbranch_id,t.brch_id,t.full_name, t.pid,level, "
					+ " connect_by_isleaf from SYS_BRANCH t where 1 = 1 START WITH pid is null CONNECT BY PRIOR "
					+ " t.sysbranch_id = t.pid order by t.brch_id asc) t start with t.pid  is null connect by prior t.sysbranch_id = t.pid)");
		
			Page listview = baseService.pagingQuery(rechargeCompareSQL.toString(), page, rows);
			if(listview.getAllRs() == null || listview.getAllRs().size() <= 0){
				throw new CommonException("未查询到对应卡信息，不能进行挂失！");
			}else{
				jsonObject.put("rows",listview.getAllRs());
				jsonObject.put("total",listview.getTotalCount());
			}
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	//初始化表格
	private void initGrid() throws Exception{
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg","");
	}
	public void setBorder(int num,CellRangeAddress region1,HSSFSheet sheet,HSSFWorkbook book){
		RegionUtil.setBorderBottom(CellStyle.BORDER_THIN,region1,sheet,book);
		RegionUtil.setBorderLeft(CellStyle.BORDER_THIN,region1,sheet,book);
		RegionUtil.setBorderRight(CellStyle.BORDER_THIN,region1,sheet,book);
		RegionUtil.setBorderTop(CellStyle.BORDER_THIN,region1,sheet,book);
	}

	@SuppressWarnings("unchecked")
	public String querySysPayReadyRp2() {
		initBaseDataGrid();
		try {
			String wSql = "";
			if (!Tools.processNull(startDate).equals("")) {
				wSql += " and t.clr_date >= '" + startDate + "'";
			}
			if (!Tools.processNull(endDate).equals("")) {
				wSql += " and t.clr_date <= '" + endDate + "'";
			}

			String sql1 = "select stat_deal_code, sum(nvl(num, 0)), sum(nvl(amt, 0)) from stat_readypayamt_data t where stat_deal_code in ('meronline_tot_out','zxzhfn_out_online','online_in','zhzz_tran','offline_to_online','online_in_cx','online_out_qt')";
			String sql2 = "select stat_deal_code, sum(nvl(num, 0)), sum(nvl(amt, 0)) from stat_readypayamt_data t where stat_deal_code in ('meroffline_tot_out', 'zxzhfn_out_offline', 'offline_in','zhzz_tran','offline_to_online','offline_in_cx', 'hk_zz_bz', 'unrec_to_offline')";
			String sql3 = "select stat_deal_code, sum(nvl(num, 0)), sum(nvl(amt, 0)) from stat_readypayamt_data t where stat_deal_code in ('unrec_in', 'unrec_in_cx', 'unrec_to_offline')";
			String sqlStart = "select * from (select row_number() over (partition by stat_deal_code order by clr_date) a, stat_deal_code, per_amt from stat_readypayamt_data t where 1 = 1 " + wSql + ") where a = 1";
			String sqlEnd = "select * from (select row_number() over (partition by stat_deal_code order by clr_date desc) a, stat_deal_code, end_amt from stat_readypayamt_data t where 1 = 1 " + wSql + ") where a = 1";
			
			List<Object[]> dataStart = (List<Object[]>) baseService.findBySql(sqlStart);
			BigDecimal startAmt1 = BigDecimal.ZERO;
			BigDecimal startAmt2 = BigDecimal.ZERO;
			BigDecimal startAmt3 = BigDecimal.ZERO;
			for (Object[] data : dataStart) {
				// 联机
				if ("online_in".equals(data[1])) {
					startAmt1 = startAmt1.add((BigDecimal) data[2]);
				} else if ("offline_to_online".equals(data[1])) {
					startAmt1 = startAmt1.add((BigDecimal) data[2]);
				} else if ("meronline_tot_out".equals(data[1])) {
					startAmt1 = startAmt1.subtract((BigDecimal) data[2]);
				} else if ("zhzz_tran".equals(data[1])) {
					startAmt1 = startAmt1.subtract((BigDecimal) data[2]);
				} else if ("zxzhfn_out_online".equals(data[1])) {
					startAmt1 = startAmt1.subtract((BigDecimal) data[2]);
				} else if ("online_in_cx".equals(data[1])) {
					startAmt1 = startAmt1.subtract((BigDecimal) data[2]);
				} else if ("online_out_qt".equals(data[1])) {
					startAmt1 = startAmt1.subtract((BigDecimal) data[2]);
				}
				
				// 脱机
			    if ("offline_in".equals(data[1])) {
					startAmt2 = startAmt2.add((BigDecimal) data[2]);
				} else if ("zhzz_tran".equals(data[1])) {
					startAmt2 = startAmt2.add((BigDecimal) data[2]);
				} else if ("meroffline_tot_out".equals(data[1])) {
					startAmt2 = startAmt2.subtract((BigDecimal) data[2]);
				} else if ("offline_to_online".equals(data[1])) {
					startAmt2 = startAmt2.subtract((BigDecimal) data[2]);
				} else if ("offline_in_cx".equals(data[1])) {
					startAmt2 = startAmt2.subtract((BigDecimal) data[2]);
				} else if ("hk_zz_bz".equals(data[1])) {
					startAmt2 = startAmt2.add((BigDecimal) data[2]);
				} else if ("zxzhfn_out_offline".equals(data[1])) {
					startAmt2 = startAmt2.subtract((BigDecimal) data[2]);
				} else if ("unrec_to_offline".equals(data[1])) {
					startAmt2 = startAmt2.add((BigDecimal) data[2]);
				}
			    
			    // 未登
			    if ("unrec_in".equals(data[1])) {
					startAmt3 = startAmt3.add((BigDecimal) data[2]);
				} else if ("unrec_in_cx".equals(data[1])) {
					startAmt3 = startAmt3.subtract((BigDecimal) data[2]);
				} else if ("unrec_to_offline".equals(data[1])) {
					startAmt3 = startAmt3.subtract((BigDecimal) data[2]);
				}
			}
			
			List<Object[]> dataEnd = (List<Object[]>) baseService.findBySql(sqlEnd);
			BigDecimal endAmt1 = BigDecimal.ZERO;
			BigDecimal endAmt2 = BigDecimal.ZERO;
			BigDecimal endAmt3 = BigDecimal.ZERO;
			for (Object[] data : dataEnd) {
				// 联机
				if ("online_in".equals(data[1])) {
					endAmt1 = endAmt1.add((BigDecimal) data[2]);
				} else if ("offline_to_online".equals(data[1])) {
					endAmt1 = endAmt1.add((BigDecimal) data[2]);
				} else if ("meronline_tot_out".equals(data[1])) {
					endAmt1 = endAmt1.subtract((BigDecimal) data[2]);
				} else if ("zhzz_tran".equals(data[1])) {
					endAmt1 = endAmt1.subtract((BigDecimal) data[2]);
				} else if ("zxzhfn_out_online".equals(data[1])) {
					endAmt1 = endAmt1.subtract((BigDecimal) data[2]);
				} else if ("online_in_cx".equals(data[1])) {
					endAmt1 = endAmt1.subtract((BigDecimal) data[2]);
				} else if ("online_out_qt".equals(data[1])) {
					endAmt1 = endAmt1.subtract((BigDecimal) data[2]);
				}
				
				// 脱机
			    if ("offline_in".equals(data[1])) {
					endAmt2 = endAmt2.add((BigDecimal) data[2]);
				} else if ("zhzz_tran".equals(data[1])) {
					endAmt2 = endAmt2.add((BigDecimal) data[2]);
				} else if ("meroffline_tot_out".equals(data[1])) {
					endAmt2 = endAmt2.subtract((BigDecimal) data[2]);
				} else if ("offline_to_online".equals(data[1])) {
					endAmt2 = endAmt2.subtract((BigDecimal) data[2]);
				} else if ("offline_in_cx".equals(data[1])) {
					endAmt2 = endAmt2.subtract((BigDecimal) data[2]);
				} else if ("hk_zz_bz".equals(data[1])) {
					endAmt2 = endAmt2.add((BigDecimal) data[2]);
				} else if ("zxzhfn_out_offline".equals(data[1])) {
					endAmt2 = endAmt2.subtract((BigDecimal) data[2]);
				} else if ("unrec_to_offline".equals(data[1])) {
					endAmt2 = endAmt2.add((BigDecimal) data[2]);
				}
			    
			    // 未登
			    if ("unrec_in".equals(data[1])) {
			    	endAmt3 = endAmt3.add((BigDecimal) data[2]);
				} else if ("unrec_in_cx".equals(data[1])) {
					endAmt3 = endAmt3.subtract((BigDecimal) data[2]);
				} else if ("unrec_to_offline".equals(data[1])) {
					endAmt3 = endAmt3.subtract((BigDecimal) data[2]);
				}
			}
			// 联机
			List<Object[]> data1 = (List<Object[]>) baseService.findBySql(sql1 + wSql + " group by stat_deal_code");
			JSONObject lj = new JSONObject();
			lj.put("accKind", "市民卡账户");
			lj.put("start_amt", startAmt1);
			lj.put("end_amt", endAmt1);
			for (Object[] objects : data1) {
				if ("online_in".equals(objects[0])) {
					lj.put("in_r_num", objects[1]);
					lj.put("in_r_amt", objects[2]);
				} else if ("offline_to_online".equals(objects[0])) {
					lj.put("in_t_num", objects[1]);
					lj.put("in_t_amt", objects[2]);
				} else if ("meronline_tot_out".equals(objects[0])) {
					lj.put("out_c_num", objects[1]);
					lj.put("out_c_amt", objects[2]);
				} else if ("zhzz_tran".equals(objects[0])) {
					lj.put("out_t_num", objects[1]);
					lj.put("out_t_amt", objects[2]);
				} else if ("zxzhfn_out_online".equals(objects[0])) {
					lj.put("out_b_num", objects[1]);
					lj.put("out_b_amt", objects[2]);
				} else if ("online_in_cx".equals(objects[0])) {
					lj.put("out_cx_num", objects[1]);
					lj.put("out_cx_amt", objects[2]);
				} else if ("online_out_qt".equals(objects[0])) {
					lj.put("out_qt_num", objects[1]);
					lj.put("out_qt_amt", objects[2]);
				}
			}

			// 脱机
			List<Object[]> data2 = (List<Object[]>) baseService.findBySql(sql2 + wSql + " group by stat_deal_code");
			JSONObject tj = new JSONObject();
			tj.put("accKind", "市民卡钱包");
			tj.put("end_amt", endAmt2);
			tj.put("start_amt", startAmt2);
			for (Object[] objects : data2) {
				if ("offline_in".equals(objects[0])) {
					tj.put("in_r_num", objects[1]);
					tj.put("in_r_amt", objects[2]);
				} else if ("zhzz_tran".equals(objects[0]) || "unrec_to_offline".equals(objects[0])) {
					if(tj.containsKey("in_t_num")){
						int inTNum = tj.getIntValue("in_t_num");
						tj.put("in_t_num", inTNum + ((BigDecimal)objects[1]).intValue());
					} else {
						tj.put("in_t_num", objects[1]);
					}
					if(tj.containsKey("in_t_amt")){
						double inTAmt = tj.getDoubleValue("in_t_amt");
						tj.put("in_t_amt", inTAmt + ((BigDecimal)objects[2]).doubleValue());
					} else {
						tj.put("in_t_amt", objects[2]);
					}
				} else if ("meroffline_tot_out".equals(objects[0])) {
					tj.put("out_c_num", objects[1]);
					tj.put("out_c_amt", objects[2]);
				} else if ("offline_to_online".equals(objects[0])) {
					tj.put("out_t_num", objects[1]);
					tj.put("out_t_amt", objects[2]);
				} else if ("offline_in_cx".equals(objects[0])) {
					tj.put("out_cx_num", objects[1]);
					tj.put("out_cx_amt", objects[2]);
				} else if ("hk_zz_bz".equals(objects[0])) {
					tj.put("in_r_bz_num", objects[1]);
					tj.put("in_r_bz_amt", objects[2]);
				} else if ("zxzhfn_out_offline".equals(objects[0])) {
					tj.put("out_b_num", objects[1]);
					tj.put("out_b_amt", objects[2]);
				}
			}
			
			// 未登
			List<Object[]> data3 = (List<Object[]>) baseService.findBySql(sql3 + wSql + " group by stat_deal_code");
			JSONObject ur = new JSONObject();
			ur.put("accKind", "未登账户");
			ur.put("end_amt", endAmt3);
			ur.put("start_amt", startAmt3);
			for (Object[] objects : data3) {
				if ("unrec_in".equals(objects[0])) {
					ur.put("in_r_num", objects[1]);
					ur.put("in_r_amt", objects[2]);
				} else if ("unrec_in_cx".equals(objects[0])) {
					ur.put("out_cx_num", objects[1]);
					ur.put("out_cx_amt", objects[2]);
				} else if ("unrec_to_offline".equals(objects[0])) {
					ur.put("out_t_num", objects[1]);
					ur.put("out_t_amt", objects[2]);
				}
			}

			com.alibaba.fastjson.JSONArray rows = new com.alibaba.fastjson.JSONArray();
			rows.add(lj);
			rows.add(tj);
			rows.add(ur);
			jsonObject.put("rows", rows);
			jsonObject.put("total", 3);
			jsonObject.put("status", "0");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String exportPayReady() {
		try {
			querySysPayReadyRp2();
			exportPayReadyData();
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return null;
	}

	private void exportPayReadyData() throws UnsupportedEncodingException, IOException {
		String fileName = "备付金报表";
		response.setContentType("application/ms-excel;charset=utf-8");
		String userAgent = request.getHeader("user-agent");
		if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
			response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
		} else {
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
		}
		//
		Workbook workbook = new HSSFWorkbook();

		Sheet sheet = workbook.createSheet();
		sheet.setColumnWidth(0, 3000);
		sheet.setColumnWidth(1, 3000);
		sheet.setColumnWidth(2, 3000);
		sheet.setColumnWidth(3, 3000);
		sheet.setColumnWidth(4, 3000);
		sheet.setColumnWidth(5, 3000);
		sheet.setColumnWidth(6, 3000);
		sheet.setColumnWidth(7, 3000);
		sheet.setColumnWidth(8, 3000);
		sheet.setColumnWidth(9, 3000);
		sheet.setColumnWidth(10, 3000);
		sheet.setColumnWidth(11, 3000);
		sheet.setColumnWidth(12, 3000);
		sheet.setColumnWidth(13, 3000);
		sheet.setColumnWidth(14, 3000);
		sheet.setColumnWidth(15, 3000);
		sheet.setColumnWidth(16, 3000);
		sheet.setColumnWidth(17, 3000);
		sheet.setColumnWidth(18, 3000);
		sheet.setColumnWidth(19, 4000);
		sheet.setColumnWidth(20, 4000);

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

		int maxColumnNum = 21;
		for (int i = 0; i < 2; i++) {
			Row row = sheet.createRow(i);
			for (int j = 0; j < maxColumnNum; j++) {
				Cell cell = row.createCell(j);
				cell.setCellStyle(headCellStyle);
			}
		}
		
		sheet.getRow(0).getCell(0).setCellValue(fileName);
		sheet.getRow(1).getCell(0).setCellValue("统计日期：" + startDate + " ~ " + endDate + "    导出时间：" + DateUtils.getNowTime());
		
		// head row 1
		Row headRowOne = sheet.createRow(2);

		Cell headOne0 = headRowOne.createCell(0);
		Cell headOne1 = headRowOne.createCell(1);
		Cell headOne2 = headRowOne.createCell(2);
		Cell headOne3 = headRowOne.createCell(3);
		Cell headOne4 = headRowOne.createCell(4);
		Cell headOne5 = headRowOne.createCell(5);
		Cell headOne6 = headRowOne.createCell(6);
		Cell headOne7 = headRowOne.createCell(7);
		Cell headOne8 = headRowOne.createCell(8);
		Cell headOne9 = headRowOne.createCell(9);
		Cell headOne10 = headRowOne.createCell(10);
		Cell headOne11 = headRowOne.createCell(11);
		Cell headOne12 = headRowOne.createCell(12);
		Cell headOne13 = headRowOne.createCell(13);
		Cell headOne14 = headRowOne.createCell(14);
		Cell headOne15 = headRowOne.createCell(15);
		Cell headOne16 = headRowOne.createCell(16);
		Cell headOne17 = headRowOne.createCell(17);
		Cell headOne18 = headRowOne.createCell(18);
		Cell headOne19 = headRowOne.createCell(19);
		Cell headOne20 = headRowOne.createCell(20);

		headOne0.setCellStyle(headCellStyle);
		headOne1.setCellStyle(headCellStyle);
		headOne2.setCellStyle(headCellStyle);
		headOne3.setCellStyle(headCellStyle);
		headOne4.setCellStyle(headCellStyle);
		headOne5.setCellStyle(headCellStyle);
		headOne6.setCellStyle(headCellStyle);
		headOne7.setCellStyle(headCellStyle);
		headOne8.setCellStyle(headCellStyle);
		headOne9.setCellStyle(headCellStyle);
		headOne10.setCellStyle(headCellStyle);
		headOne11.setCellStyle(headCellStyle);
		headOne12.setCellStyle(headCellStyle);
		headOne13.setCellStyle(headCellStyle);
		headOne14.setCellStyle(headCellStyle);
		headOne15.setCellStyle(headCellStyle);
		headOne16.setCellStyle(headCellStyle);
		headOne17.setCellStyle(headCellStyle);
		headOne18.setCellStyle(headCellStyle);
		headOne19.setCellStyle(headCellStyle);
		headOne20.setCellStyle(headCellStyle);

		headOne0.setCellValue("账户类型");
		headOne1.setCellValue("收入");
		headOne9.setCellValue("支出");
		headOne19.setCellValue("上期");
		headOne20.setCellValue("本期");
		
		// head row 2
		Row headRowTwo = sheet.createRow(3);

		Cell headTwo1 = headRowTwo.createCell(1);
		Cell headTwo2 = headRowTwo.createCell(2);
		Cell headTwo3 = headRowTwo.createCell(3);
		Cell headTwo4 = headRowTwo.createCell(4);
		Cell headTwo5 = headRowTwo.createCell(5);
		Cell headTwo6 = headRowTwo.createCell(6);
		Cell headTwo7 = headRowTwo.createCell(7);
		Cell headTwo8 = headRowTwo.createCell(8);
		Cell headTwo9 = headRowTwo.createCell(9);
		Cell headTwo10 = headRowTwo.createCell(10);
		Cell headTwo11 = headRowTwo.createCell(11);
		Cell headTwo12 = headRowTwo.createCell(12);
		Cell headTwo13 = headRowTwo.createCell(13);
		Cell headTwo14 = headRowTwo.createCell(14);
		Cell headTwo15 = headRowTwo.createCell(15);
		Cell headTwo16 = headRowTwo.createCell(16);
		Cell headTwo17 = headRowTwo.createCell(17);
		Cell headTwo18 = headRowTwo.createCell(18);
		Cell headTwo19 = headRowTwo.createCell(19);
		Cell headTwo20 = headRowTwo.createCell(20);

		headTwo1.setCellStyle(headCellStyle);
		headTwo2.setCellStyle(headCellStyle);
		headTwo3.setCellStyle(headCellStyle);
		headTwo4.setCellStyle(headCellStyle);
		headTwo5.setCellStyle(headCellStyle);
		headTwo6.setCellStyle(headCellStyle);
		headTwo7.setCellStyle(headCellStyle);
		headTwo8.setCellStyle(headCellStyle);
		headTwo9.setCellStyle(headCellStyle);
		headTwo10.setCellStyle(headCellStyle);
		headTwo11.setCellStyle(headCellStyle);
		headTwo12.setCellStyle(headCellStyle);
		headTwo13.setCellStyle(headCellStyle);
		headTwo14.setCellStyle(headCellStyle);
		headTwo15.setCellStyle(headCellStyle);
		headTwo16.setCellStyle(headCellStyle);
		headTwo17.setCellStyle(headCellStyle);
		headTwo18.setCellStyle(headCellStyle);
		headTwo19.setCellStyle(headCellStyle);
		headTwo20.setCellStyle(headCellStyle);

		headTwo1.setCellValue("充值收入");
		headTwo3.setCellValue("补账收入");
		headTwo5.setCellValue("转账收入");
		headTwo7.setCellValue("收入小计");
		headTwo9.setCellValue("消费支出");
		headTwo11.setCellValue("转账支出");
		headTwo13.setCellValue("余额返还支出");
		headTwo15.setCellValue("圈提支出");
		headTwo17.setCellValue("支出小计");

		// head row 3
		Row headRowThree = sheet.createRow(4);

		Cell headThree1 = headRowThree.createCell(1);
		Cell headThree2 = headRowThree.createCell(2);
		Cell headThree3 = headRowThree.createCell(3);
		Cell headThree4 = headRowThree.createCell(4);
		Cell headThree5 = headRowThree.createCell(5);
		Cell headThree6 = headRowThree.createCell(6);
		Cell headThree7 = headRowThree.createCell(7);
		Cell headThree8 = headRowThree.createCell(8);
		Cell headThree9 = headRowThree.createCell(9);
		Cell headThree10 = headRowThree.createCell(10);
		Cell headThree11 = headRowThree.createCell(11);
		Cell headThree12 = headRowThree.createCell(12);
		Cell headThree13 = headRowThree.createCell(13);
		Cell headThree14 = headRowThree.createCell(14);
		Cell headThree15 = headRowThree.createCell(15);
		Cell headThree16 = headRowThree.createCell(16);
		Cell headThree17 = headRowThree.createCell(17);
		Cell headThree18 = headRowThree.createCell(18);
		Cell headThree19 = headRowThree.createCell(19);
		Cell headThree20 = headRowThree.createCell(20);
		
		headThree1.setCellStyle(headCellStyle);
		headThree2.setCellStyle(headCellStyle);
		headThree3.setCellStyle(headCellStyle);
		headThree4.setCellStyle(headCellStyle);
		headThree5.setCellStyle(headCellStyle);
		headThree6.setCellStyle(headCellStyle);
		headThree7.setCellStyle(headCellStyle);
		headThree8.setCellStyle(headCellStyle);
		headThree9.setCellStyle(headCellStyle);
		headThree10.setCellStyle(headCellStyle);
		headThree11.setCellStyle(headCellStyle);
		headThree12.setCellStyle(headCellStyle);
		headThree13.setCellStyle(headCellStyle);
		headThree14.setCellStyle(headCellStyle);
		headThree15.setCellStyle(headCellStyle);
		headThree16.setCellStyle(headCellStyle);
		headThree17.setCellStyle(headCellStyle);
		headThree18.setCellStyle(headCellStyle);
		headThree19.setCellStyle(headCellStyle);
		headThree20.setCellStyle(headCellStyle);

		headThree2.setCellValue("金额");
		headThree3.setCellValue("笔数");
		headThree4.setCellValue("金额");
		headThree5.setCellValue("笔数");
		headThree6.setCellValue("金额");
		headThree7.setCellValue("笔数");
		headThree8.setCellValue("金额");
		headThree9.setCellValue("笔数");
		headThree10.setCellValue("金额");
		headThree11.setCellValue("笔数");
		headThree12.setCellValue("金额");
		headThree13.setCellValue("笔数");
		headThree14.setCellValue("金额");
		headThree15.setCellValue("笔数");
		headThree16.setCellValue("金额");
		headThree17.setCellValue("笔数");
		headThree18.setCellValue("金额");

		// Merge
		sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumnNum - 1));
		sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumnNum - 1));
		sheet.addMergedRegion(new CellRangeAddress(2, 4, 0, 0));
		sheet.addMergedRegion(new CellRangeAddress(2, 2, 1, 8));
		sheet.addMergedRegion(new CellRangeAddress(2, 2, 9, 18));
		sheet.addMergedRegion(new CellRangeAddress(2, 4, 19, 19));
		sheet.addMergedRegion(new CellRangeAddress(2, 4, maxColumnNum - 1, maxColumnNum - 1));
		sheet.addMergedRegion(new CellRangeAddress(3, 3, 1, 2));
		sheet.addMergedRegion(new CellRangeAddress(3, 3, 3, 4));
		sheet.addMergedRegion(new CellRangeAddress(3, 3, 5, 6));
		sheet.addMergedRegion(new CellRangeAddress(3, 3, 7, 8));
		sheet.addMergedRegion(new CellRangeAddress(3, 3, 9, 10));
		sheet.addMergedRegion(new CellRangeAddress(3, 3, 11, 12));
		sheet.addMergedRegion(new CellRangeAddress(3, 3, 13, 14));
		sheet.addMergedRegion(new CellRangeAddress(3, 3, 15, 16));
		sheet.addMergedRegion(new CellRangeAddress(3, 3, 17, 18));
		
		sheet.createFreezePane(1, 5);
		
		com.alibaba.fastjson.JSONArray arr = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
		int inRNumSum = 0;
		double inRAmtSum = 0;
		int inBzNumSum = 0;
		double inBzAmtSum = 0;
		int inTNumSum = 0;
		double inTAmtSum = 0;
		int inNumSum = 0;
		double inAmtSum = 0;
		int outCNumSum = 0;
		double outCAmtSum = 0;
		int outTNumSum = 0;
		double outTAmtSum = 0;
		int outBNumSum = 0;
		double outBAmtSum = 0;
		int outQtNumSum = 0;
		double outQtAmtSum = 0;
		int outNumSum = 0;
		double outAmtSum = 0;
		double startAmtSum = 0;
		double endAmtSum = 0;
		for (int i = 0; i < arr.size(); i++) {
			JSONObject data = (JSONObject) arr.get(i);

			Row row = sheet.createRow(i + 5);

			Cell cell0 = row.createCell(0);
			Cell cell1 = row.createCell(1);
			Cell cell2 = row.createCell(2);
			Cell cell3 = row.createCell(3);
			Cell cell4 = row.createCell(4);
			Cell cell5 = row.createCell(5);
			Cell cell6 = row.createCell(6);
			Cell cell7 = row.createCell(7);
			Cell cell8 = row.createCell(8);
			Cell cell9 = row.createCell(9);
			Cell cell10 = row.createCell(10);
			Cell cell11 = row.createCell(11);
			Cell cell12 = row.createCell(12);
			Cell cell13 = row.createCell(13);
			Cell cell14 = row.createCell(14);
			Cell cell15 = row.createCell(15);
			Cell cell16 = row.createCell(16);
			Cell cell17 = row.createCell(17);
			Cell cell18 = row.createCell(18);
			Cell cell19 = row.createCell(19);
			Cell cell20 = row.createCell(20);

			cell0.setCellStyle(cellStyle);
			cell1.setCellStyle(cellStyle);
			cell2.setCellStyle(moneyCellStyle);
			cell3.setCellStyle(cellStyle);
			cell4.setCellStyle(moneyCellStyle);
			cell5.setCellStyle(cellStyle);
			cell6.setCellStyle(moneyCellStyle);
			cell7.setCellStyle(cellStyle);
			cell8.setCellStyle(moneyCellStyle);
			cell9.setCellStyle(cellStyle);
			cell10.setCellStyle(moneyCellStyle);
			cell11.setCellStyle(cellStyle);
			cell12.setCellStyle(moneyCellStyle);
			cell13.setCellStyle(cellStyle);
			cell14.setCellStyle(moneyCellStyle);
			cell15.setCellStyle(cellStyle);
			cell16.setCellStyle(moneyCellStyle);
			cell17.setCellStyle(cellStyle);
			cell18.setCellStyle(moneyCellStyle);
			cell19.setCellStyle(moneyCellStyle);
			cell20.setCellStyle(moneyCellStyle);

			cell0.setCellValue(data.getString("accKind"));
			//
			int inRNum = data.getIntValue("in_r_num") - data.getIntValue("out_cx_num");
			cell1.setCellValue(inRNum);
			double inRAmt = BigDecimal.valueOf(data.getDoubleValue("in_r_amt") - data.getDoubleValue("out_cx_amt")).divide(BigDecimal.valueOf(100)).doubleValue();
			cell2.setCellValue(inRAmt);
			inRNumSum += inRNum;
			inRAmtSum += inRAmt;
			//
			int inBzNum = data.getIntValue("in_r_bz_num");
			cell3.setCellValue(inBzNum);
			double inBzAmt = BigDecimal.valueOf(data.getDoubleValue("in_r_bz_amt")).divide(BigDecimal.valueOf(100)).doubleValue();
			cell4.setCellValue(inBzAmt);
			inBzNumSum += inBzNum;
			inBzAmtSum += inBzAmt;
			//
			int inTNum = data.getIntValue("in_t_num");
			cell5.setCellValue(inTNum);
			BigDecimal inTAmt = data.getBigDecimal("in_t_amt");
			cell6.setCellValue(inTAmt == null ? 0 : inTAmt.divide(BigDecimal.valueOf(100)).doubleValue());
			inTNumSum += inTNum;
			inTAmtSum += inTAmt == null ? 0 : inTAmt.divide(BigDecimal.valueOf(100)).doubleValue();
			//
			int inNum = data.getIntValue("in_r_num") + inTNum - data.getIntValue("out_cx_num") + inBzNum;
			cell7.setCellValue(inNum);
			double inAmt = BigDecimal.valueOf(data.getDoubleValue("in_r_amt") + data.getDoubleValue("in_t_amt") - data.getDoubleValue("out_cx_amt") + data.getDoubleValue("in_r_bz_amt")).divide(BigDecimal.valueOf(100)).doubleValue();
			cell8.setCellValue(inAmt);
			inNumSum += inNum;
			inAmtSum += inAmt;
			//
			int outCNum = data.getIntValue("out_c_num");
			cell9.setCellValue(outCNum);
			BigDecimal outCAmt = data.getBigDecimal("out_c_amt");
			cell10.setCellValue(outCAmt == null ? 0 : outCAmt.divide(BigDecimal.valueOf(100)).doubleValue());
			outCNumSum += outCNum;
			outCAmtSum += outCAmt == null ? 0 : outCAmt.divide(BigDecimal.valueOf(100)).doubleValue();
			//
			int outTNum = data.getIntValue("out_t_num");
			cell11.setCellValue(outTNum);
			BigDecimal outTAmt = data.getBigDecimal("out_t_amt");
			cell12.setCellValue(outTAmt == null ? 0 : outTAmt.divide(BigDecimal.valueOf(100)).doubleValue());
			outTNumSum += outTNum;
			outTAmtSum += outTAmt == null ? 0 : outTAmt.divide(BigDecimal.valueOf(100)).doubleValue();
			//
			int outBNum = data.getIntValue("out_b_num");
			cell13.setCellValue(outBNum);
			BigDecimal outBAmt = data.getBigDecimal("out_b_amt");
			cell14.setCellValue(outBAmt == null ? 0 : outBAmt.divide(BigDecimal.valueOf(100)).doubleValue());
			outBNumSum += outBNum;
			outBAmtSum += outBAmt == null ? 0 : outBAmt.divide(BigDecimal.valueOf(100)).doubleValue();
			//
			int outQtNum = data.getIntValue("out_qt_num");
			cell15.setCellValue(outQtNum);
			BigDecimal outQtAmt = data.getBigDecimal("out_qt_amt");
			cell16.setCellValue(outQtAmt == null ? 0 : outQtAmt.divide(BigDecimal.valueOf(100)).doubleValue());
			outQtNumSum += outQtNum;
			outQtAmtSum += outQtAmt == null ? 0 : outQtAmt.divide(BigDecimal.valueOf(100)).doubleValue();
			//
			cell17.setCellValue(outCNum + outTNum + outBNum);
			double outAmt = BigDecimal.valueOf(data.getDoubleValue("out_c_amt") + data.getDoubleValue("out_t_amt") + data.getDoubleValue("out_b_amt") + data.getDoubleValue("out_qt_amt")).divide(BigDecimal.valueOf(100)).doubleValue();
			cell18.setCellValue(outAmt);
			outNumSum += outCNum + outTNum + outBNum + outQtNum;
			outAmtSum += outAmt;
			//
			BigDecimal startAmt = data.getBigDecimal("start_amt");
			cell19.setCellValue(startAmt == null ? 0 : startAmt.divide(BigDecimal.valueOf(100)).doubleValue());
			BigDecimal endAmt = data.getBigDecimal("end_amt");
			cell20.setCellValue(endAmt == null ? 0 : endAmt.divide(BigDecimal.valueOf(100)).doubleValue());
			startAmtSum += startAmt == null ? 0 : startAmt.divide(BigDecimal.valueOf(100)).doubleValue();
			endAmtSum += endAmt == null ? 0 : endAmt.divide(BigDecimal.valueOf(100)).doubleValue();
		}
		Row footer = sheet.createRow(arr.size() + 5);

		Cell footerCell0 = footer.createCell(0);
		Cell footerCell1 = footer.createCell(1);
		Cell footerCell2 = footer.createCell(2);
		Cell footerCell3 = footer.createCell(3);
		Cell footerCell4 = footer.createCell(4);
		Cell footerCell5 = footer.createCell(5);
		Cell footerCell6 = footer.createCell(6);
		Cell footerCell7 = footer.createCell(7);
		Cell footerCell8 = footer.createCell(8);
		Cell footerCell9 = footer.createCell(9);
		Cell footerCell10 = footer.createCell(10);
		Cell footerCell11 = footer.createCell(11);
		Cell footerCell12 = footer.createCell(12);
		Cell footerCell13 = footer.createCell(13);
		Cell footerCell14 = footer.createCell(14);
		Cell footerCell15 = footer.createCell(15);
		Cell footerCell16 = footer.createCell(16);
		Cell footerCell17 = footer.createCell(17);
		Cell footerCell18 = footer.createCell(18);
		Cell footerCell19 = footer.createCell(19);
		Cell footerCell20 = footer.createCell(20);

		footerCell0.setCellStyle(cellStyle);
		footerCell1.setCellStyle(cellStyle);
		footerCell2.setCellStyle(moneyCellStyle);
		footerCell3.setCellStyle(cellStyle);
		footerCell4.setCellStyle(moneyCellStyle);
		footerCell5.setCellStyle(cellStyle);
		footerCell6.setCellStyle(moneyCellStyle);
		footerCell7.setCellStyle(cellStyle);
		footerCell8.setCellStyle(moneyCellStyle);
		footerCell9.setCellStyle(cellStyle);
		footerCell10.setCellStyle(moneyCellStyle);
		footerCell11.setCellStyle(cellStyle);
		footerCell12.setCellStyle(moneyCellStyle);
		footerCell13.setCellStyle(cellStyle);
		footerCell14.setCellStyle(moneyCellStyle);
		footerCell15.setCellStyle(cellStyle);
		footerCell16.setCellStyle(moneyCellStyle);
		footerCell17.setCellStyle(cellStyle);
		footerCell18.setCellStyle(moneyCellStyle);
		footerCell19.setCellStyle(moneyCellStyle);
		footerCell20.setCellStyle(moneyCellStyle);
		
		footerCell0.setCellValue("统计：");
		footerCell1.setCellValue(inRNumSum);
		footerCell2.setCellValue(inRAmtSum);
		footerCell3.setCellValue(inBzNumSum);
		footerCell4.setCellValue(inBzAmtSum);
		footerCell5.setCellValue(inTNumSum);
		footerCell6.setCellValue(inTAmtSum);
		footerCell7.setCellValue(inNumSum);
		footerCell8.setCellValue(inAmtSum);
		footerCell9.setCellValue(outCNumSum);
		footerCell10.setCellValue(outCAmtSum);
		footerCell11.setCellValue(outTNumSum);
		footerCell12.setCellValue(outTAmtSum);
		footerCell13.setCellValue(outBNumSum);
		footerCell14.setCellValue(outBAmtSum);
		footerCell15.setCellValue(outQtNumSum);
		footerCell16.setCellValue(outQtAmtSum);
		footerCell17.setCellValue(outNumSum);
		footerCell18.setCellValue(outAmtSum);
		footerCell19.setCellValue(startAmtSum);
		footerCell20.setCellValue(endAmtSum);

		SecurityUtils.getSubject().getSession().setAttribute("exportBindInfoSucc", Constants.YES_NO_YES);

		OutputStream output = response.getOutputStream();

		workbook.write(output);
		workbook.close();

		output.flush();
		output.close();
	}
	
	@SuppressWarnings("unchecked")
	public String querySysPayReadyRpRt() {
		try {
			initGrid();
			String curClrDate = baseService.getClrDate();
			String sql = "select to_char(deal_code), count(1), sum(db_amt), db_acc_kind "
					+ "from acc_inout_detail_" + curClrDate.substring(0, 7).replaceAll("-", "") + " t "
					+ "where clr_date = '" + curClrDate + "' and deal_code in ('30105070','30101021','30105011','30601021','30601031','30101011','20501190','30101020','30105010','30601020','30601030','30105090','30101010','30105020','30101040','30105030','40201010','40201051','40101010','30101050','30101080') " 
					+ "group by deal_code, db_acc_kind";
			
			// 期初值 = 上期期末值 = 昨日期末值
			Calendar cal = Calendar.getInstance();
			cal.setTime(new Date());
			cal.add(Calendar.DAY_OF_MONTH, -1);
			String perClrDate = DateUtil.formatDate(cal.getTime(), "yyyy-MM-dd");
			String sqlPeriod = "select 1, stat_deal_code, end_amt from stat_readypayamt_data t where clr_date = '" + perClrDate  + "'";
			// 上期期末值
			List<Object[]> dataStart = (List<Object[]>) baseService.findBySql(sqlPeriod);
			BigDecimal startAmtOL = BigDecimal.ZERO;
			BigDecimal startAmtOFF = BigDecimal.ZERO;
			for (Object[] data : dataStart) {
				// 联机
				if ("online_in".equals(data[1])) {
					startAmtOL = startAmtOL.add((BigDecimal) data[2]);
				} else if ("offline_to_online".equals(data[1])) {
					startAmtOL = startAmtOL.add((BigDecimal) data[2]);
				} else if ("meronline_tot_out".equals(data[1])) {
					startAmtOL = startAmtOL.subtract((BigDecimal) data[2]);
				} else if ("zhzz_tran".equals(data[1])) {
					startAmtOL = startAmtOL.subtract((BigDecimal) data[2]);
				} else if ("zxzhfn_out_online".equals(data[1])) {
					startAmtOL = startAmtOL.subtract((BigDecimal) data[2]);
				} else if ("online_in_cx".equals(data[1])) {
					startAmtOL = startAmtOL.subtract((BigDecimal) data[2]);
				} else if ("online_out_qt".equals(data[1])) {
					startAmtOL = startAmtOL.subtract((BigDecimal) data[2]);
				}
				
				// 脱机
			    if ("offline_in".equals(data[1])) {
					startAmtOFF = startAmtOFF.add((BigDecimal) data[2]);
				} else if ("zhzz_tran".equals(data[1])) {
					startAmtOFF = startAmtOFF.add((BigDecimal) data[2]);
				} else if ("meroffline_tot_out".equals(data[1])) {
					startAmtOFF = startAmtOFF.subtract((BigDecimal) data[2]);
				} else if ("offline_to_online".equals(data[1])) {
					startAmtOFF = startAmtOFF.subtract((BigDecimal) data[2]);
				} else if ("offline_in_cx".equals(data[1])) {
					startAmtOFF = startAmtOFF.subtract((BigDecimal) data[2]);
				} else if ("hk_zz_bz".equals(data[1])) {
					startAmtOFF = startAmtOFF.add((BigDecimal) data[2]);
				} else if ("zxzhfn_out_offline".equals(data[1])) {
					startAmtOFF = startAmtOFF.subtract((BigDecimal) data[2]);
				}
			}
			
			// 期内联机
			List<Object[]> data = (List<Object[]>) baseService.findBySql(sql);
			JSONObject online = new JSONObject();
			online.put("accKind", "市民卡账户");
			online.put("start_amt", startAmtOL);
			// 期内脱机
			JSONObject offline = new JSONObject();
			offline.put("accKind", "市民卡钱包");
			offline.put("start_amt", startAmtOFF);
			// online
			int inRNumOL = 0;
			BigDecimal inRAmtOL = BigDecimal.ZERO;
			int inTNumOL = 0;
			BigDecimal inTAmtOL = BigDecimal.ZERO;
			int outCNumOL = 0;
			BigDecimal outCAmtOL = BigDecimal.ZERO;
			int outTNumOL = 0;
			BigDecimal outTAmtOL = BigDecimal.ZERO;
			int outBNumOL = 0;
			BigDecimal outBAmtOL = BigDecimal.ZERO;
			int outCxNumOL = 0;
			BigDecimal outCxAmtOL = BigDecimal.ZERO;
			int outQtNumOL = 0;
			BigDecimal outQtAmtOL = BigDecimal.ZERO;
			// offline
			int inRNumOFF = 0;
			BigDecimal inRAmtOFF = BigDecimal.ZERO;
			int inTNumOFF = 0;
			BigDecimal inTAmtOFF = BigDecimal.ZERO;
			int inRBzNumOFF = 0;
			BigDecimal inRBzAmtOFF = BigDecimal.ZERO;
			int outCNumOFF = 0;
			BigDecimal outCAmtOFF = BigDecimal.ZERO;
			int outTNumOFF = 0;
			BigDecimal outTAmtOFF = BigDecimal.ZERO;
			int outBNumOFF = 0;
			BigDecimal outBAmtOFF = BigDecimal.ZERO;
			int outCxNumOFF = 0;
			BigDecimal outCxAmtOFF = BigDecimal.ZERO;
			int outQtNumOFF = 0;
			BigDecimal outQtAmtOFF = BigDecimal.ZERO;
			// total
			BigDecimal endAmtOL = BigDecimal.ZERO.add(startAmtOL);
			BigDecimal endAmtOFF = BigDecimal.ZERO.add(startAmtOFF);
			for (Object[] objects : data) {
				// online
				if ("30101020".equals(objects[0]) || "30105010".equals(objects[0]) || "30601020".equals(objects[0]) || "30601030".equals(objects[0]) || "30105090".equals(objects[0])) {
					inRNumOL += ((BigDecimal) objects[1]).intValue();
					inRAmtOL = inRAmtOL.add((BigDecimal) objects[2]);
					endAmtOL = endAmtOL.add((BigDecimal) objects[2]);
				} else if ("30101050".equals(objects[0])) {
					inTNumOL += ((BigDecimal) objects[1]).intValue();
					inTAmtOL = inTAmtOL.add((BigDecimal) objects[2]);
					endAmtOL = endAmtOL.add((BigDecimal) objects[2]);
				} else if ("40201010".equals(objects[0]) || "40201051".equals(objects[0])) {
					outCNumOL += ((BigDecimal) objects[1]).intValue();
					outCAmtOL = outCAmtOL.add((BigDecimal) objects[2]);
					endAmtOL = endAmtOL.subtract((BigDecimal) objects[2]);
				} else if ("30101040".equals(objects[0]) ||  "30105030".equals(objects[0])) {
					outTNumOL += ((BigDecimal) objects[1]).intValue();
					outTAmtOL = outTAmtOL.add((BigDecimal) objects[2]);
					endAmtOL = endAmtOL.subtract((BigDecimal) objects[2]);
				} else if ("20501190".equals(objects[0]) && "02".equals(objects[3])) {
					outBNumOL += ((BigDecimal) objects[1]).intValue();
					outBAmtOL = outBAmtOL.add((BigDecimal) objects[2]);
					endAmtOL = endAmtOL.subtract((BigDecimal) objects[2]);
				} else if ("30101021".equals(objects[0]) || "30105011".equals(objects[0]) || "30601021".equals(objects[0]) || "30601031".equals(objects[0])) {
					outCxNumOL += ((BigDecimal) objects[1]).intValue();
					outCxAmtOL = outCxAmtOL.add((BigDecimal) objects[2]);
					endAmtOL = endAmtOL.add((BigDecimal) objects[2]);
				} else if ("30105070".equals(objects[0])) {
					outQtNumOL -= ((BigDecimal) objects[1]).intValue();
					outQtAmtOL = outQtAmtOL.add((BigDecimal) objects[2]);
					endAmtOL = endAmtOL.subtract((BigDecimal) objects[2]);
				}

				// offline
				if ("30101010".equals(objects[0]) || "30105020".equals(objects[0])) {
					inRNumOFF += ((BigDecimal) objects[1]).intValue();
					inRAmtOFF = inRAmtOFF.add((BigDecimal) objects[2]);
					endAmtOFF = endAmtOFF.add((BigDecimal) objects[2]);
				} else if ("30101040".equals(objects[0]) ||  "30105030".equals(objects[0])) {
					inTNumOFF += ((BigDecimal) objects[1]).intValue();
					inTAmtOFF = inTAmtOFF.add((BigDecimal) objects[2]);
					endAmtOFF = endAmtOFF.add((BigDecimal) objects[2]);
				} else if ("40101010".equals(objects[0])) {
					outCNumOFF += ((BigDecimal) objects[1]).intValue();
					outCAmtOFF = outCAmtOFF.add((BigDecimal) objects[2]);
					endAmtOFF = endAmtOFF.subtract((BigDecimal) objects[2]);
				} else if ("30101050".equals(objects[0])) {
					outTNumOFF += ((BigDecimal) objects[1]).intValue();
					outTAmtOFF = outTAmtOFF.add((BigDecimal) objects[2]);
					endAmtOFF = endAmtOFF.subtract((BigDecimal) objects[2]);
				} else if ("30101011".equals(objects[0])) {
					outCxNumOFF += ((BigDecimal) objects[1]).intValue();
					outCxAmtOFF = outCxAmtOFF.add((BigDecimal) objects[2]);
					endAmtOFF = endAmtOFF.add((BigDecimal) objects[2]);
				} else if ("30101080".equals(objects[0])) {
					inRBzNumOFF += ((BigDecimal) objects[1]).intValue();
					inRBzAmtOFF = inRBzAmtOFF.add((BigDecimal) objects[2]);
					endAmtOFF = endAmtOFF.add((BigDecimal) objects[2]);
				} else if ("20501190".equals(objects[0]) && "01".equals(objects[3])) {
					outBNumOFF += ((BigDecimal) objects[1]).intValue();
					outBAmtOFF = outBAmtOFF.add((BigDecimal) objects[2]);
					endAmtOFF = endAmtOFF.subtract((BigDecimal) objects[2]);
				}
			}
			// online
			online.put("in_r_num", inRNumOL);
			online.put("in_r_amt", inRAmtOL);
			online.put("in_t_num", inTNumOL);
			online.put("in_t_amt", inTAmtOL);
			online.put("out_c_num", outCNumOL);
			online.put("out_c_amt", outCAmtOL.abs());
			online.put("out_t_num", outTNumOL);
			online.put("out_t_amt", outTAmtOL.abs());
			online.put("out_b_num", outBNumOL);
			online.put("out_b_amt", outBAmtOL);
			online.put("out_cx_num", outCxNumOL);
			online.put("out_cx_amt", outCxAmtOL);
			online.put("out_qt_num", outQtNumOL);
			online.put("out_qt_amt", outQtAmtOL);
			online.put("end_amt", endAmtOL);
			// offline
			offline.put("in_r_num", inRNumOFF);
			offline.put("in_r_amt", inRAmtOFF);
			offline.put("in_t_num", inTNumOFF);
			offline.put("in_t_amt", inTAmtOFF);
			offline.put("in_r_bz_num", inRBzNumOFF);
			offline.put("in_r_bz_amt", inRBzAmtOFF);
			offline.put("out_c_num", outCNumOFF);
			offline.put("out_c_amt", outCAmtOFF.abs());
			offline.put("out_t_num", outTNumOFF);
			offline.put("out_t_amt", outTAmtOFF.abs());
			offline.put("out_b_num", outBNumOFF);
			offline.put("out_b_amt", outBAmtOFF);
			offline.put("out_cx_num", outCxNumOFF);
			offline.put("out_cx_amt", outCxAmtOFF);
			offline.put("out_qt_num", outQtNumOFF);
			offline.put("out_qt_amt", outQtAmtOFF);
			offline.put("end_amt", endAmtOFF);

			com.alibaba.fastjson.JSONArray rows = new com.alibaba.fastjson.JSONArray();
			rows.add(online);
			rows.add(offline);
			jsonObject.put("rows", rows);
			jsonObject.put("total", 2);
			jsonObject.put("status", "0");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String exportPayReadyRt() {
		try {
			querySysPayReadyRpRt();
			startDate = endDate = baseService.getClrDate();
			exportPayReadyData();
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return null;
	}
	
	/**
	 * @author Yueh
	 * @return
	 */
	public String rechargeCompeareRp2() {
		try {
			initBaseDataGrid();
			if(Tools.processNull(qyMonth).equals("")){
				throw new CommonException("起始月份不能为空.");
			} else if(Tools.processNull(qyMonthEnd).equals("")){
				throw new CommonException("结束月份不能为空.");
			}
			String brchIdSql = "";
			if (!Tools.processNull(checkIds).equals("")) {
				String[] brchIdArr = checkIds.split(",");
				for (String brchId : brchIdArr) {
					brchIdSql += "'" + brchId + "',";
				}
				brchIdSql = brchIdSql.substring(0, brchIdSql.length()-1);
			}
			
			// cur year period
			// start
			Date curYearStartMonth = DateUtil.parse("yyyy-MM", qyMonth);
			Calendar curYearStartMonthCal = Calendar.getInstance();
			curYearStartMonthCal.setTime(curYearStartMonth);
			curYearStartMonthCal.set(Calendar.DAY_OF_MONTH, 1);
			qyMonth = DateUtil.formatDate(curYearStartMonthCal.getTime(), "yyyy-MM-dd");
			// end
			Date curYearEndMonth = DateUtil.parse("yyyy-MM", qyMonthEnd);
			Calendar curYearEndMonthCal = Calendar.getInstance();
			curYearEndMonthCal.setTime(curYearEndMonth);
			curYearEndMonthCal.add(Calendar.MONTH, 1);
			curYearEndMonthCal.add(Calendar.DAY_OF_MONTH, -1);
			qyMonthEnd = DateUtil.formatDate(curYearEndMonthCal.getTime(), "yyyy-MM-dd");
			
			// last year period
			// start
			Calendar lastYearStartMonthCal = Calendar.getInstance();
			lastYearStartMonthCal.setTime(curYearStartMonth);
			lastYearStartMonthCal.add(Calendar.YEAR, -1);
			lastYearStartMonthCal.set(Calendar.DAY_OF_MONTH, 1);
			String lastYearStartMonth = DateUtil.formatDate(lastYearStartMonthCal.getTime(), "yyyy-MM-dd");
			// end
			Calendar lastYearEndMonthCal = Calendar.getInstance();
			lastYearEndMonthCal.setTime(curYearEndMonth);
			lastYearEndMonthCal.add(Calendar.YEAR, -1);
			lastYearEndMonthCal.add(Calendar.MONTH, 1);
			lastYearEndMonthCal.add(Calendar.DAY_OF_MONTH, -1);
			String lastYearEndMonth = DateUtil.formatDate(lastYearEndMonthCal.getTime(), "yyyy-MM-dd");
			
			// query
			String sql = "select t.brch_id, t.full_name, "
					+ "(select sum(decode(t2.deal_code, '30101020', t2.amt, '30101021', t2.amt, '30601030', t2.amt, '30601031', t2.amt, '30601020', t2.amt, '30601021', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date >= '" + qyMonth + "' and t2.clr_date <= '" + qyMonthEnd + "' and t2.acpt_id = t.brch_id) cur_period_lj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30101010', t2.amt, '30101011', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date >= '" + qyMonth + "' and t2.clr_date <= '" + qyMonthEnd + "' and t2.acpt_id = t.brch_id) cur_period_tj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30101020', t2.amt, '30302010', t2.amt, '30601030', t2.amt, '30601031', t2.amt, '30601020', t2.amt, '30601021', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date >= '" + lastYearStartMonth + "' and t2.clr_date <= '" + lastYearEndMonth + "' and t2.acpt_id = t.brch_id) last_period_lj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30101010', t2.amt, '30302020', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date >= '" + lastYearStartMonth + "' and t2.clr_date <= '" + lastYearEndMonth + "' and t2.acpt_id = t.brch_id) last_period_tj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30101020', t2.amt, '30302010', t2.amt, '30601030', t2.amt, '30601031', t2.amt, '30601020', t2.amt, '30601021', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date <= '" + qyMonthEnd + "' and t2.acpt_id = t.brch_id) cur_year_lj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30101010', t2.amt, '30302020', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date <= '" + qyMonthEnd + "' and t2.acpt_id = t.brch_id) cur_year_tj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30101020', t2.amt, '30302010', t2.amt, '30601030', t2.amt, '30601031', t2.amt, '30601020', t2.amt, '30601021', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date <= '" + lastYearEndMonth + "' and t2.acpt_id = t.brch_id) last_year_lj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30101010', t2.amt, '30302020', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date <= '" + lastYearEndMonth + "' and t2.acpt_id = t.brch_id) last_year_tj_recharge "
					+ "from sys_branch t where 1 = 1 ";
			if(!Tools.processNull(brch_Id).equals("")){
				sql += "and t.brch_id = '" + brch_Id + "' ";
			}
			if(!Tools.processNull(brchIdSql).equals("")){
				sql += "and t.brch_id in (" + brchIdSql + ") ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			} else {
				sql += "order by brch_id";
			}
			Page data = baseService.pagingQuery(sql, page, rows);
			if(data == null || data.getAllRs() == null || data.getAllRs().isEmpty()){
				throw new CommonException("没有数据.");
			}
			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportRechargeCompeareReport(){
		try {
			rechargeCompeareRp2();
			String fileName = "充值情况同比对比_" + qyMonth + " ~ " + qyMonthEnd;
			if(!Tools.processNull(brch_Id).equals("")){
				String brchName = (String) baseService.findOnlyFieldBySql("select full_name from sys_branch where brch_id = '" + brch_Id + "'");
				fileName = brchName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 6000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 3000);
			sheet.setColumnWidth(4, 3000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 3000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 3000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 3000);

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

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);
			
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));

			// head row 1
			int maxColumn = 11;
			int headRows = 4;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			// second header
			String time = "导出时间：" + DateUtils.getNowTime();
			if (!Tools.processNull(startDate).equals("")) {
				time = "业务时间：" + startDate + " ~ " + endDate + "    " + time;
			}
			sheet.getRow(1).getCell(0).setCellValue(time);
			
			// third header
			sheet.getRow(2).getCell(0).setCellValue("网点名称");
			sheet.getRow(2).getCell(1).setCellValue("本期充值金额");
			sheet.getRow(2).getCell(4).setCellValue("去年同期充值金额");
			sheet.getRow(2).getCell(6).setCellValue("本年累计充值金额");
			sheet.getRow(2).getCell(9).setCellValue("去年同期累计充值金额");
			// third header
			sheet.getRow(3).getCell(1).setCellValue("市民卡钱包");
			sheet.getRow(3).getCell(2).setCellValue("市民卡账户");
			sheet.getRow(3).getCell(3).setCellValue("合计");
			sheet.getRow(3).getCell(4).setCellValue("充值金额");
			sheet.getRow(3).getCell(5).setCellValue("同比");
			sheet.getRow(3).getCell(6).setCellValue("市民卡钱包");
			sheet.getRow(3).getCell(7).setCellValue("市民卡账户");
			sheet.getRow(3).getCell(8).setCellValue("合计");
			sheet.getRow(3).getCell(9).setCellValue("充值金额");
			sheet.getRow(3).getCell(10).setCellValue("同比");
			
			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 1, 3));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 4, 5));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 6, 8));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 9, 10));
			sheet.createFreezePane(1, 4);
			
			double curPeriodTjRechargeSum = 0;
			double curPeriodLjRechargeSum = 0;
			double lastPeriodTjRechargeSum = 0;
			double lastPeriodLjRechargeSum = 0;
			double curYearTjRechargeSum = 0;
			double curYearLjRechargeSum = 0;
			double lastYearTjRechargeSum = 0;
			double lastYearLjRechargeSum = 0;
			for (int i = 0; i < data.size(); i++) {
				JSONObject item = data.getJSONObject(i);
				
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if(j==0||j==5||j==10){
						cell.setCellStyle(cellStyle);
					}else{
						cell.setCellStyle(moneyCellStyle);
					}
				}
				
				double curPeriodTjRecharge = Tools.processNull(item.getString("CUR_PERIOD_TJ_RECHARGE")).equals("")?0:item.getDoubleValue("CUR_PERIOD_TJ_RECHARGE");
				double curPeriodLjRecharge = Tools.processNull(item.getString("CUR_PERIOD_LJ_RECHARGE")).equals("")?0:item.getDoubleValue("CUR_PERIOD_LJ_RECHARGE");
				double lastPeriodTjRecharge = Tools.processNull(item.getString("LAST_PERIOD_TJ_RECHARGE")).equals("")?0:item.getDoubleValue("LAST_PERIOD_TJ_RECHARGE");
				double lastPeriodLjRecharge = Tools.processNull(item.getString("LAST_PERIOD_LJ_RECHARGE")).equals("")?0:item.getDoubleValue("LAST_PERIOD_LJ_RECHARGE");
				double curYearTjRecharge = Tools.processNull(item.getString("CUR_YEAR_TJ_RECHARGE")).equals("")?0:item.getDoubleValue("CUR_YEAR_TJ_RECHARGE");
				double curYearLjRecharge = Tools.processNull(item.getString("CUR_YEAR_LJ_RECHARGE")).equals("")?0:item.getDoubleValue("CUR_YEAR_LJ_RECHARGE");
				double lastYearTjRecharge = Tools.processNull(item.getString("LAST_YEAR_TJ_RECHARGE")).equals("")?0:item.getDoubleValue("LAST_YEAR_TJ_RECHARGE");
				double lastYearLjRecharge = Tools.processNull(item.getString("LAST_YEAR_LJ_RECHARGE")).equals("")?0:item.getDoubleValue("LAST_YEAR_LJ_RECHARGE");
				//
				curPeriodTjRechargeSum += curPeriodTjRecharge;
				curPeriodLjRechargeSum += curPeriodLjRecharge;
				lastPeriodTjRechargeSum += lastPeriodTjRecharge;
				lastPeriodLjRechargeSum += lastPeriodLjRecharge;
				curYearTjRechargeSum += curYearTjRecharge;
				curYearLjRechargeSum += curYearLjRecharge;
				lastYearTjRechargeSum += lastYearTjRecharge;
				lastYearLjRechargeSum += lastYearLjRecharge;
				//
				row.getCell(0).setCellValue(item.getString("FULL_NAME"));
				row.getCell(1).setCellValue(curPeriodTjRecharge / 100);
				row.getCell(2).setCellValue(curPeriodLjRecharge / 100);
				row.getCell(3).setCellValue((curPeriodTjRecharge + curPeriodLjRecharge)/100);
				row.getCell(4).setCellValue((lastPeriodTjRecharge + lastPeriodLjRecharge) / 100);
				if (lastPeriodTjRecharge + lastPeriodLjRecharge == 0) {
					row.getCell(5).setCellValue("");
				} else {
					row.getCell(5).setCellValue((curPeriodTjRecharge + curPeriodLjRecharge - lastPeriodTjRecharge - lastPeriodLjRecharge) / (lastPeriodTjRecharge + lastPeriodLjRecharge) + "%");
				}
				row.getCell(6).setCellValue(curYearTjRecharge / 100);
				row.getCell(7).setCellValue(curYearLjRecharge / 100);
				row.getCell(8).setCellValue((curYearTjRecharge + curYearLjRecharge) / 100);
				row.getCell(9).setCellValue((lastYearTjRecharge + lastYearLjRecharge) / 100);
				if (lastYearTjRecharge + lastYearLjRecharge == 0) {
					row.getCell(10).setCellValue("");
				} else {
					row.getCell(10).setCellValue((curYearTjRecharge + curYearLjRecharge - lastYearTjRecharge - lastYearLjRecharge) / (lastYearTjRecharge + lastYearLjRecharge) + "%");
				}
			}
			
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if(j==0||j==5||j==10){
					cell.setCellStyle(cellStyle);
				}else{
					cell.setCellStyle(moneyCellStyle);
				}
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(1).setCellValue(curPeriodTjRechargeSum / 100);
			row.getCell(2).setCellValue(curPeriodLjRechargeSum / 100);
			row.getCell(3).setCellValue((curPeriodTjRechargeSum + curPeriodLjRechargeSum) / 100);
			row.getCell(4).setCellValue((lastPeriodTjRechargeSum + lastPeriodLjRechargeSum) / 100);
			if (lastPeriodTjRechargeSum + lastPeriodLjRechargeSum == 0) {
				row.getCell(5).setCellValue("");
			} else {
				row.getCell(5).setCellValue((curPeriodTjRechargeSum + curPeriodLjRechargeSum - lastPeriodTjRechargeSum - lastPeriodLjRechargeSum) / (lastPeriodTjRechargeSum + lastPeriodLjRechargeSum) + "%");
			}
			row.getCell(6).setCellValue(curYearTjRechargeSum / 100);
			row.getCell(7).setCellValue(curYearLjRechargeSum / 100);
			row.getCell(8).setCellValue((curYearTjRechargeSum + curYearLjRechargeSum) / 100);
			row.getCell(9).setCellValue((lastYearTjRechargeSum + lastYearLjRechargeSum) / 100);
			if (lastYearTjRechargeSum + lastYearLjRechargeSum == 0) {
				row.getCell(10).setCellValue("");
			} else {
				row.getCell(10).setCellValue((curYearTjRechargeSum + curYearLjRechargeSum - lastYearTjRechargeSum - lastYearLjRechargeSum) / (lastYearTjRechargeSum + lastYearLjRechargeSum) + "%");
			}
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String merchantSettleQuery(){
		try {
			initBaseDataGrid();
			
			if (Tools.processNull(startDate).equals("")) {
				throw new CommonException("结算起始时间不能为空.");
			} else if (Tools.processNull(endDate).equals("")) {
				throw new CommonException("结算结束时间不能为空.");
			} else if (startDate.compareTo(endDate) > 0) {
				throw new CommonException("结算起始时间不能大于清分结束时间.");
			}
			
			String querySql = "select t.merchant_id, t.merchant_name, "
					+ "sum(nvl(t2.tot_deal_amt, 0)) yjs, "
					+ "sum(nvl(t2.tot_deal_num, 0)) yjs_num, "
					+ "sum(decode(t2.stl_state, 9, nvl(t2.tot_deal_amt, 0), 0)) yzf, "
					+ "sum(decode(t2.stl_state, 9, nvl(t2.tot_deal_num, 0), 0)) yzf_num, "
					+ "sum(decode(t2.stl_state, 9, 0, nvl(t2.tot_deal_amt, 0))) wzf, "
					+ "sum(decode(t2.stl_state, 9, 0, nvl(t2.tot_deal_num, 0))) wzf_num, "
					+ "(select sum(nvl(deal_amt, 0)) from pay_clr_sum where merchant_id = t.merchant_id and stl_flag <> '0') wjs, "
					+ "(select sum(nvl(deal_num, 0)) from pay_clr_sum where merchant_id = t.merchant_id and stl_flag <> '0') wjs_num, "
					+ "sum(nvl(t2.tot_deal_amt, 0)) total, "
					+ "sum(nvl(t2.tot_deal_num, 0)) total_num "
					+ "from base_merchant t join stl_deal_sum t2 "
					+ "on t2.merchant_id = t.merchant_id where 1 = 1 ";
			if (!Tools.processNull(merchantId).equals("")) {
				querySql += "and t.merchant_id = '" + merchantId + "' ";
			}
			if (!Tools.processNull(merchantName).equals("")) {
				querySql += "and t.merchant_name like '%" + merchantName + "%' ";
			}
			if (!Tools.processNull(startDate).equals("")) {
				querySql += "and t2.stl_date >= '" + startDate + "' ";
			}
			if (!Tools.processNull(endDate).equals("")) {
				querySql += "and t2.stl_date <= '" + endDate + "' ";
			}
			querySql += "group by t.merchant_id, t.merchant_name";
			if(!Tools.processNull(sort).equals("")){
				querySql += " order by " + sort;
				
				if(!Tools.processNull(order).equals("")){
					querySql += " " + order + " ";
				}
			} else {
				querySql += " order by merchant_id";
			}
			
			Page pageData = baseService.pagingQuery(querySql, page, rows);
			
			if (pageData == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommonException("没有数据.");
			}
			
			jsonObject.put("total", pageData.getTotalCount());
			jsonObject.put("rows", pageData.getAllRs());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		
		return JSONOBJ;
	}
	
	public static List<String> getMonths(String startDateStr, String endDateStr){
		try {
			List<String> months = new ArrayList<String>();
			
			Calendar clrStartDate = Calendar.getInstance();
			clrStartDate.setTime(DateUtil.formatDate(startDateStr));
			clrStartDate.set(Calendar.DAY_OF_MONTH, 1);
			
			Calendar clrEndDate = Calendar.getInstance();
			clrEndDate.setTime(DateUtil.formatDate(endDateStr));
			clrEndDate.set(Calendar.DAY_OF_MONTH, 1);
			
			while(clrStartDate.compareTo(clrEndDate) <= 0){
				months.add(DateUtil.formatDate(clrStartDate.getTime(), "yyyyMM"));
				clrStartDate.add(Calendar.MONTH, 1);
			}
			
			if(months.isEmpty()){
				throw new CommonException("清分日期月份为空.");
			}
			
			return months;
		} catch (Exception e) {
			throw new CommonException("获取清分日期月份异常, " + e.getMessage());
		}
	}
	
	public String exportMerchantSettleInfo(){
		try {
			if(Tools.processNull(merchantIds).equals("")){
				throw new CommonException("选择导出记录为空！");
			}
			
			String querySql = "select t.merchant_id, t.merchant_name, "
					+ "sum(decode(t2.stl_flag, 0, nvl(t2.deal_amt, 0), 0)) yjs, "
					+ "sum(decode(t2.stl_flag, 0, nvl(t2.deal_num, 0), 0)) yjs_num, "
					+ "sum(decode(t2.stl_flag, 0, 0, nvl(t2.deal_amt, 0))) wjs, "
					+ "sum(decode(t2.stl_flag, 0, 0, nvl(t2.deal_num, 0))) wjs_num, "
					+ "sum(nvl(t2.deal_amt, 0)) total, "
					+ "sum(nvl(t2.deal_num, 0)) total_num, "
					+ "sum(decode((select stl_state from stl_deal_sum where stl_sum_no = t2.stl_sum_no and card_type = t2.card_type and acc_kind = t2.acc_kind), 9, t2.deal_amt, 0)) yzf, "
					+ "sum(decode((select stl_state from stl_deal_sum where stl_sum_no = t2.stl_sum_no and card_type = t2.card_type and acc_kind = t2.acc_kind), 9, t2.deal_num, 0)) yzf_num, "
					+ "sum(decode((select stl_state from stl_deal_sum where stl_sum_no = t2.stl_sum_no and card_type = t2.card_type and acc_kind = t2.acc_kind), 9, 0, null, 0, t2.deal_amt)) wzf, "
					+ "sum(decode((select stl_state from stl_deal_sum where stl_sum_no = t2.stl_sum_no and card_type = t2.card_type and acc_kind = t2.acc_kind), 9, 0, null, 0, t2.deal_num)) wzf_num "
					+ "from base_merchant t join pay_clr_sum t2 "
					+ "on t2.merchant_id = t.merchant_id where t.merchant_id in (" + merchantIds + ") ";
			if (!Tools.processNull(startDate).equals("")) {
				querySql += "and t2.stl_date >= '" + startDate + "' ";
			}
			if (!Tools.processNull(endDate).equals("")) {
				querySql += "and t2.stl_date <= '" + endDate + "' ";
			}
			querySql += "group by t.merchant_id, t.merchant_name";
			if(!Tools.processNull(sort).equals("")){
				querySql += " order by " + sort;
				
				if(!Tools.processNull(order).equals("")){
					querySql += " " + order + " ";
				}
			} else {
				querySql += " order by merchant_id";
			}
			
			List<Object[]> list = baseService.findBySql(querySql);
			
			if (list == null || list.isEmpty()) {
				throw new CommonException("没有数据.");
			}
			
			// 导出
			String fileName = "商户结算数据统计";
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");

			//
			Workbook workbook = new HSSFWorkbook();

			Sheet sheet = workbook.createSheet();
			sheet.setColumnWidth(0, 4000);
			sheet.setColumnWidth(1, 8000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 3000);
			sheet.setColumnWidth(4, 3000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 3000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 3000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 3000);
			sheet.setColumnWidth(11, 3000);

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
			headCellStyle.setVerticalAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setFont(headCellFont);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			for (int i = 0; i < 2; i++) {
				Row row = sheet.createRow(i);
				for (int j = 0; j < 12; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			sheet.getRow(1).getCell(0).setCellValue("结算时间：" + startDate + " ~ " + endDate + "    导出时间：" + DateUtils.getNowTime());
			
			// head row 3
			Row headRowThree = sheet.createRow(2);

			Cell headThree0 = headRowThree.createCell(0);
			Cell headThree1 = headRowThree.createCell(1);
			Cell headThree2 = headRowThree.createCell(2);
			Cell headThree3 = headRowThree.createCell(3);
			Cell headThree4 = headRowThree.createCell(4);
			Cell headThree5 = headRowThree.createCell(5);
			Cell headThree6 = headRowThree.createCell(6);
			Cell headThree7 = headRowThree.createCell(7);
			Cell headThree8 = headRowThree.createCell(8);
			Cell headThree9 = headRowThree.createCell(9);
			Cell headThree10 = headRowThree.createCell(10);
			Cell headThree11 = headRowThree.createCell(11);

			headThree0.setCellStyle(headCellStyle);
			headThree1.setCellStyle(headCellStyle);
			headThree2.setCellStyle(headCellStyle);
			headThree3.setCellStyle(headCellStyle);
			headThree4.setCellStyle(headCellStyle);
			headThree5.setCellStyle(headCellStyle);
			headThree6.setCellStyle(headCellStyle);
			headThree7.setCellStyle(headCellStyle);
			headThree8.setCellStyle(headCellStyle);
			headThree9.setCellStyle(headCellStyle);
			headThree10.setCellStyle(headCellStyle);
			headThree11.setCellStyle(headCellStyle);

			headThree0.setCellValue("商户编号");
			headThree1.setCellValue("商户名称");
			headThree2.setCellValue("已结算");
			headThree8.setCellValue("未结算");
			headThree10.setCellValue("总计");
			
			// 4
			Row headRowFour = sheet.createRow(3);

			Cell headFour0 = headRowFour.createCell(0);
			Cell headFour1 = headRowFour.createCell(1);
			Cell headFour2 = headRowFour.createCell(2);
			Cell headFour3 = headRowFour.createCell(3);
			Cell headFour4 = headRowFour.createCell(4);
			Cell headFour5 = headRowFour.createCell(5);
			Cell headFour6 = headRowFour.createCell(6);
			Cell headFour7 = headRowFour.createCell(7);
			Cell headFour8 = headRowFour.createCell(8);
			Cell headFour9 = headRowFour.createCell(9);
			Cell headFour10 = headRowFour.createCell(10);
			Cell headFour11 = headRowFour.createCell(11);

			headFour0.setCellStyle(headCellStyle);
			headFour1.setCellStyle(headCellStyle);
			headFour2.setCellStyle(headCellStyle);
			headFour3.setCellStyle(headCellStyle);
			headFour4.setCellStyle(headCellStyle);
			headFour5.setCellStyle(headCellStyle);
			headFour6.setCellStyle(headCellStyle);
			headFour7.setCellStyle(headCellStyle);
			headFour8.setCellStyle(headCellStyle);
			headFour9.setCellStyle(headCellStyle);
			headFour10.setCellStyle(headCellStyle);
			headFour11.setCellStyle(headCellStyle);
			
			headFour2.setCellValue("已支付");
			headFour4.setCellValue("未支付");
			headFour6.setCellValue("总计");
			
			// 5
			Row headRowFive = sheet.createRow(4);

			Cell headFive0 = headRowFive.createCell(0);
			Cell headFive1 = headRowFive.createCell(1);
			Cell headFive2 = headRowFive.createCell(2);
			Cell headFive3 = headRowFive.createCell(3);
			Cell headFive4 = headRowFive.createCell(4);
			Cell headFive5 = headRowFive.createCell(5);
			Cell headFive6 = headRowFive.createCell(6);
			Cell headFive7 = headRowFive.createCell(7);
			Cell headFive8 = headRowFive.createCell(8);
			Cell headFive9 = headRowFive.createCell(9);
			Cell headFive10 = headRowFive.createCell(10);
			Cell headFive11 = headRowFive.createCell(11);

			headFive0.setCellStyle(headCellStyle);
			headFive1.setCellStyle(headCellStyle);
			headFive2.setCellStyle(headCellStyle);
			headFive3.setCellStyle(headCellStyle);
			headFive4.setCellStyle(headCellStyle);
			headFive5.setCellStyle(headCellStyle);
			headFive6.setCellStyle(headCellStyle);
			headFive7.setCellStyle(headCellStyle);
			headFive8.setCellStyle(headCellStyle);
			headFive9.setCellStyle(headCellStyle);
			headFive10.setCellStyle(headCellStyle);
			headFive11.setCellStyle(headCellStyle);
			
			headFive2.setCellValue("笔数");
			headFive3.setCellValue("金额");
			headFive4.setCellValue("笔数");
			headFive5.setCellValue("金额");
			headFive6.setCellValue("笔数");
			headFive7.setCellValue("金额");
			headFive8.setCellValue("笔数");
			headFive9.setCellValue("金额");
			headFive10.setCellValue("笔数");
			headFive11.setCellValue("金额");
			
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 11));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, 11));
			sheet.addMergedRegion(new CellRangeAddress(2, 4, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(2, 4, 1, 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 2, 7));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 8, 9));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 10, 11));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, 2, 3));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, 4, 5));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, 6, 7));
			
			int num = 0;
			BigDecimal sumYjs = BigDecimal.ZERO;
			BigDecimal sumYjsNum = BigDecimal.ZERO;
			BigDecimal sumYzf = BigDecimal.ZERO;
			BigDecimal sumYzfNum = BigDecimal.ZERO;
			BigDecimal sumWzf = BigDecimal.ZERO;
			BigDecimal sumWzfNum = BigDecimal.ZERO;
			BigDecimal sumWjs = BigDecimal.ZERO;
			BigDecimal sumWjsNum = BigDecimal.ZERO;
			BigDecimal sumTot = BigDecimal.ZERO;
			BigDecimal sumTotNum = BigDecimal.ZERO;
			for (int i = 0; i < list.size(); i++) {
				Object[] data = (Object[]) list.get(i);
				BigDecimal yjs = (BigDecimal) data[2];
				BigDecimal yjsNum = (BigDecimal) data[3];
				BigDecimal wjs = (BigDecimal) data[4];
				BigDecimal wjsNum = (BigDecimal) data[5];
				BigDecimal tot = (BigDecimal) data[6];
				BigDecimal totNum = (BigDecimal) data[7];
				BigDecimal yzf = (BigDecimal) data[8];
				BigDecimal yzfNum = (BigDecimal) data[9];
				BigDecimal wzf = (BigDecimal) data[10];
				BigDecimal wzfNum = (BigDecimal) data[11];
				num++;
				sumYjs = sumYjs.add(yjs == null ? BigDecimal.ZERO : yjs);
				sumWjs = sumWjs.add(wjs == null ? BigDecimal.ZERO : wjs);
				sumTot = sumTot.add(tot == null ? BigDecimal.ZERO : tot);
				sumYzf = sumYzf.add(yzf == null ? BigDecimal.ZERO : yzf);
				sumWzf = sumWzf.add(wzf == null ? BigDecimal.ZERO : wzf);
				sumYjsNum = sumYjsNum.add(yjsNum == null ? BigDecimal.ZERO : yjsNum);
				sumWjsNum = sumWjsNum.add(wjsNum == null ? BigDecimal.ZERO : wjsNum);
				sumTotNum = sumTotNum.add(totNum == null ? BigDecimal.ZERO : totNum);
				sumYzfNum = sumYzfNum.add(yzfNum == null ? BigDecimal.ZERO : yzfNum);
				sumWzfNum = sumWzfNum.add(wzfNum == null ? BigDecimal.ZERO : wzfNum);

				//
				Row row = sheet.createRow(i + 5);
				Cell cell0 = row.createCell(0);
				Cell cell1 = row.createCell(1);
				Cell cell2 = row.createCell(2);
				Cell cell3 = row.createCell(3);
				Cell cell4 = row.createCell(4);
				Cell cell5 = row.createCell(5);
				Cell cell6 = row.createCell(6);
				Cell cell7 = row.createCell(7);
				Cell cell8 = row.createCell(8);
				Cell cell9 = row.createCell(9);
				Cell cell10 = row.createCell(10);
				Cell cell11 = row.createCell(11);

				cell0.setCellStyle(cellStyle);
				cell1.setCellStyle(cellStyle);
				cell2.setCellStyle(cellStyle);
				cell3.setCellStyle(moneyCellStyle);
				cell4.setCellStyle(cellStyle);
				cell5.setCellStyle(moneyCellStyle);
				cell6.setCellStyle(cellStyle);
				cell7.setCellStyle(moneyCellStyle);
				cell8.setCellStyle(cellStyle);
				cell9.setCellStyle(moneyCellStyle);
				cell10.setCellStyle(cellStyle);
				cell11.setCellStyle(moneyCellStyle);

				cell0.setCellValue(Tools.processNull(data[0]));
				cell1.setCellValue(Tools.processNull(data[1]));
				cell2.setCellValue(yzfNum == null ? 0 : yzfNum.intValue());
				cell3.setCellValue(yzf == null ? 0 : yzf.divide(BigDecimal.valueOf(100)).doubleValue());
				cell4.setCellValue(wzfNum == null ? 0 : wzfNum.intValue());
				cell5.setCellValue(wzf == null ? 0 : wzf.divide(BigDecimal.valueOf(100)).doubleValue());
				cell6.setCellValue(yjsNum == null ? 0 : yjsNum.intValue());
				cell7.setCellValue(yjs == null ? 0 : yjs.divide(BigDecimal.valueOf(100)).doubleValue());
				cell8.setCellValue(wjsNum == null ? 0 : wjsNum.intValue());
				cell9.setCellValue(wjs == null ? 0 : wjs.divide(BigDecimal.valueOf(100)).doubleValue());
				cell10.setCellValue(totNum == null ? 0 : totNum.intValue());
				cell11.setCellValue(tot == null ? 0 : tot.divide(BigDecimal.valueOf(100)).doubleValue());
			}
			
			Row row = sheet.createRow(list.size() + 5);
			Cell foot0 = row.createCell(0);
			Cell foot1 = row.createCell(1);
			Cell foot2 = row.createCell(2);
			Cell foot3 = row.createCell(3);
			Cell foot4 = row.createCell(4);
			Cell foot5 = row.createCell(5);
			Cell foot6 = row.createCell(6);
			Cell foot7 = row.createCell(7);
			Cell foot8 = row.createCell(8);
			Cell foot9 = row.createCell(9);
			Cell foot10 = row.createCell(10);
			Cell foot11 = row.createCell(11);

			foot0.setCellStyle(cellStyle);
			foot1.setCellStyle(cellStyle);
			foot2.setCellStyle(cellStyle);
			foot3.setCellStyle(moneyCellStyle);
			foot4.setCellStyle(cellStyle);
			foot5.setCellStyle(moneyCellStyle);
			foot6.setCellStyle(cellStyle);
			foot7.setCellStyle(moneyCellStyle);
			foot8.setCellStyle(cellStyle);
			foot9.setCellStyle(moneyCellStyle);
			foot10.setCellStyle(cellStyle);
			foot11.setCellStyle(moneyCellStyle);
			
			foot0.setCellValue("总计：");
			foot1.setCellValue("共 " + num + " 条记录");
			foot2.setCellValue(sumYzfNum.intValue());
			foot3.setCellValue(sumYzf.divide(BigDecimal.valueOf(100)).doubleValue());
			foot4.setCellValue(sumWzfNum.intValue());
			foot5.setCellValue(sumWzf.divide(BigDecimal.valueOf(100)).doubleValue());
			foot6.setCellValue(sumYjsNum.intValue());
			foot7.setCellValue(sumYjs.divide(BigDecimal.valueOf(100)).doubleValue());
			foot8.setCellValue(sumWjsNum.intValue());
			foot9.setCellValue(sumWjs.divide(BigDecimal.valueOf(100)).doubleValue());
			foot10.setCellValue(sumTotNum.intValue());
			foot11.setCellValue(sumTot.divide(BigDecimal.valueOf(100)).doubleValue());

			SecurityUtils.getSubject().getSession().setAttribute("exportBindInfoSucc", Constants.YES_NO_YES);

			OutputStream output = response.getOutputStream();

			workbook.write(output);
			workbook.close();

			output.flush();
			output.close();
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * 合作机构充值统计
	 * @return
	 */
	public String queryCoOrgRechargeMsg(){
		String dealCode = "'30105010','30105011','30105020','30105021'";
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total","0");
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		try{
			initGrid();
			String coOrgIdSql = "";
			if(!Tools.processNull(coOrgIds).equals("")){
				String[] coOrgIdArr = coOrgIds.split(",");
				if (coOrgIdArr != null && coOrgIdArr.length > 0) {
					for (String coOrgId : coOrgIdArr) {
						coOrgIdSql += "'" + coOrgId + "',";
					}
					coOrgIdSql = coOrgIdSql.substring(0, coOrgIdSql.length() - 1);
				}
			}
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sql = new StringBuffer();//decode(t1.acc_kind,'02',,0)
				sql.append("select t.co_org_id||'|'||t1.card_type seq,t.co_org_id, t.co_org_name,(select co.code_name from sys_code co where co.code_type = 'CARD_TYPE' and co.code_Value= t1.card_type) CARD_TYPE, min(t1.clr_date) clr_date, ");
				sql.append("sum(decode(t1.deal_code,'30105010',decode(t1.acc_kind,'02',decode(t1.notes, '1', '0', t1.num),0),'0'))  LJ_YDZ_CZ_NUM, ");//
				sql.append("sum(decode(t1.deal_code,'30105010',decode(t1.acc_kind,'02',decode(t1.notes, '1', '0', t1.amt),0),'0'))  LJ_YDZ_CZ_AMT, ");//
				sql.append("sum(decode(t1.deal_code,'30105011',decode(t1.acc_kind,'02',decode(t1.notes, '1', '0', t1.num),0),'0'))  LJ_YDZ_CZCX_NUM, ");//
				sql.append("sum(decode(t1.deal_code,'30105011',decode(t1.acc_kind,'02',decode(t1.notes, '1', '0', t1.amt),0),'0'))  LJ_YDZ_CZCX_AMT, ");//
				sql.append("sum(decode(t1.deal_code,'30105020',decode(t1.notes, '1', '0', t1.num),'0'))  QB_YDZ_CZ_NUM, ");
				sql.append("sum(decode(t1.deal_code,'30105020',decode(t1.notes, '1', '0', t1.amt),'0'))  QB_YDZ_CZ_AMT, ");
				sql.append("sum(decode(t1.deal_code,'30105021',decode(t1.notes, '1', '0', t1.num),'0'))  QB_YDZ_CZCX_NUM, ");
				sql.append("sum(decode(t1.deal_code,'30105021',decode(t1.notes, '1', '0', t1.amt),'0'))  QB_YDZ_CZCX_AMT, ");
				sql.append("sum(decode(t1.deal_code,'30105010',decode(t1.acc_kind,'99',decode(t1.notes, '1', '0', t1.num),0),'0'))  UR_YDZ_CZ_NUM, ");//
				sql.append("sum(decode(t1.deal_code,'30105010',decode(t1.acc_kind,'99',decode(t1.notes, '1', '0', t1.amt),0),'0'))  UR_YDZ_CZ_AMT, ");//
				sql.append("sum(decode(t1.deal_code,'30105011',decode(t1.acc_kind,'99',decode(t1.notes, '1', '0', t1.num),0),'0'))  UR_YDZ_CZCX_NUM, ");//
				sql.append("sum(decode(t1.deal_code,'30105011',decode(t1.acc_kind,'99',decode(t1.notes, '1', '0', t1.amt),0),'0'))  UR_YDZ_CZCX_AMT, ");//
				sql.append("sum(decode(t1.notes,'1', '0', decode(t1.deal_code, '30105010', decode(t1.acc_kind,'01',t1.num,'02',t1.num,'99',t1.num,0), '30105020', t1.num, '30105011', decode(t1.acc_kind,'01',-t1.num,'02',-t1.num,'99',-t1.num,0), '30105021', -t1.num, '0')))  YDZ_NUM, ");
				sql.append("sum(decode(t1.notes,'1', '0', decode(t1.acc_kind,'01',t1.amt,'02',t1.amt,'99',t1.amt,0)))  YDZ_AMT, ");
				//
				sql.append("sum(decode(t1.deal_code,'30105010',decode(t1.acc_kind,'02',decode(t1.notes, '1', t1.num, '0'),0),'0'))  LJ_WDZ_CZ_NUM, ");//
				sql.append("sum(decode(t1.deal_code,'30105010',decode(t1.acc_kind,'02',decode(t1.notes, '1', t1.amt, '0'),0),'0'))  LJ_WDZ_CZ_AMT, ");//
				sql.append("sum(decode(t1.deal_code,'30105011',decode(t1.acc_kind,'02',decode(t1.notes, '1', t1.num, '0'),0),'0'))  LJ_WDZ_CZCX_NUM, ");//
				sql.append("sum(decode(t1.deal_code,'30105011',decode(t1.acc_kind,'02',decode(t1.notes, '1', t1.amt, '0'),0),'0'))  LJ_WDZ_CZCX_AMT, ");//
				sql.append("sum(decode(t1.deal_code,'30105020',decode(t1.notes, '1', t1.num, '0'),'0'))  QB_WDZ_CZ_NUM, ");
				sql.append("sum(decode(t1.deal_code,'30105020',decode(t1.notes, '1', t1.amt, '0'),'0'))  QB_WDZ_CZ_AMT, ");
				sql.append("sum(decode(t1.deal_code,'30105021',decode(t1.notes, '1', t1.num, '0'),'0'))  QB_WDZ_CZCX_NUM, ");
				sql.append("sum(decode(t1.deal_code,'30105021',decode(t1.notes, '1', t1.amt, '0'),'0'))  QB_WDZ_CZCX_AMT, ");
				sql.append("sum(decode(t1.deal_code,'30105010',decode(t1.acc_kind,'99',decode(t1.notes, '1', t1.num, '0'),0),'0'))  UR_WDZ_CZ_NUM, ");//
				sql.append("sum(decode(t1.deal_code,'30105010',decode(t1.acc_kind,'99',decode(t1.notes, '1', t1.amt, '0'),0),'0'))  UR_WDZ_CZ_AMT, ");//
				sql.append("sum(decode(t1.deal_code,'30105011',decode(t1.acc_kind,'99',decode(t1.notes, '1', t1.num, '0'),0),'0'))  UR_WDZ_CZCX_NUM, ");//
				sql.append("sum(decode(t1.deal_code,'30105011',decode(t1.acc_kind,'99',decode(t1.notes, '1', t1.amt, '0'),0),'0'))  UR_WDZ_CZCX_AMT, ");//
				sql.append("sum(decode(t1.notes,'1', decode(t1.deal_code, '30105010', decode(t1.acc_kind,'01',t1.num,'02',t1.num,'99',t1.num,0), '30105020', t1.num, '30105011', decode(t1.acc_kind,'01',-t1.num,'02',-t1.num,'99',-t1.num,0), '30105021', -t1.num, '0'), '0'))  WDZ_NUM, ");
				sql.append("sum(decode(t1.notes,'1', decode(t1.acc_kind,'01',t1.amt,'02',t1.amt,'99',t1.amt,0), '0'))  WDZ_AMT, ");
				sql.append("sum(decode(t1.deal_code, '30105010', decode(t1.acc_kind,'01',t1.num,'02',t1.num,'99',t1.num,0), '30105020', t1.num, '30105011', decode(t1.acc_kind,'01',-t1.num,'02',-t1.num,'99',-t1.num,0), '30105021', -t1.num, '0'))  TOT_NUM, ");
				sql.append("sum(decode(t1.acc_kind,'01',t1.amt,'02',t1.amt,'99',t1.amt,0))  TOT_AMT ");
				//
				sql.append(" from base_co_org t, stat_card_pay t1  where t.co_org_id = t1.co_org_id(+)  and t1.deal_code in ( "
						+ dealCode +") and t1.acpt_type = '2' ");
				if(!Tools.processNull(coOrgId).equals("")){
					sql.append(" and t1.co_org_id ='"+Tools.processNull(coOrgId)+"'");
				}
				if(!Tools.processNull(coOrgIdSql).equals("")){
					sql.append(" and t1.co_org_id in (" + coOrgIdSql + ") ");
				}
				if(!Tools.processNull(startDate).equals("")){
					sql.append(" and t1.clr_Date >='"+Tools.processNull(startDate)+"'");
				}
				if(!Tools.processNull(endDate).equals("")){
					sql.append(" and t1.clr_Date <='"+Tools.processNull(endDate)+"'");
				}
				sql.append(" group by t.co_org_id,t.co_org_name,t1.card_type ");
				if(statByDay){
					sql.append(", t1.clr_date ");
				}
				sql.append("order by t.co_org_id ");
				if(statByDay){
					sql.append(", t1.clr_date");
				}
				Page pages = baseService.pagingQuery(sql.toString(),page,rows);
				if(pages.getAllRs() == null || pages.getAllRs().size() <= 0){
					throw new CommonException("根据指定信息未查询到充值信息！");
				}else{
					jsonObject.put("rows",pages.getAllRs());
					jsonObject.put("total",pages.getTotalCount());
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String queryCoOrgRechargeCWMsg(){
		String dealCode = "'30105010','30105011','30105020','30105021'";
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total","0");
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		try{
			initGrid();
			String coOrgIdSql = "";
			if(!Tools.processNull(coOrgIds).equals("")){
				String[] coOrgIdArr = coOrgIds.split(",");
				if (coOrgIdArr != null && coOrgIdArr.length > 0) {
					for (String coOrgId : coOrgIdArr) {
						coOrgIdSql += "'" + coOrgId + "',";
					}
					coOrgIdSql = coOrgIdSql.substring(0, coOrgIdSql.length() - 1);
				}
			}
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sql = new StringBuffer();//decode(t1.acc_kind,'02',,0)
				sql.append("select t.co_org_id||'|'||t1.card_type seq,t.co_org_id, t.co_org_name,(select co.code_name from sys_code co where co.code_type = 'CARD_TYPE' and co.code_Value= t1.card_type) CARD_TYPE, min(t1.clr_date) clr_date, ");
				sql.append("sum(decode(t1.deal_code,'30105010',decode(t1.acc_kind,'02',t1.num,0),'0'))  LJ_YDZ_CZ_NUM, ");//
				sql.append("sum(decode(t1.deal_code,'30105010',decode(t1.acc_kind,'02',t1.amt,0),'0'))  LJ_YDZ_CZ_AMT, ");//
				sql.append("sum(decode(t1.deal_code,'30105011',decode(t1.acc_kind,'02',t1.num,0),'0'))  LJ_YDZ_CZCX_NUM, ");//
				sql.append("sum(decode(t1.deal_code,'30105011',decode(t1.acc_kind,'02',t1.amt,0),'0'))  LJ_YDZ_CZCX_AMT, ");//
				sql.append("sum(decode(t1.deal_code,'30105020',t1.num,'0'))  QB_YDZ_CZ_NUM, ");
				sql.append("sum(decode(t1.deal_code,'30105020',t1.amt,'0'))  QB_YDZ_CZ_AMT, ");
				sql.append("sum(decode(t1.deal_code,'30105021',t1.num,'0'))  QB_YDZ_CZCX_NUM, ");
				sql.append("sum(decode(t1.deal_code,'30105021',t1.amt,'0'))  QB_YDZ_CZCX_AMT, ");
				sql.append("sum(decode(t1.deal_code,'30105010',decode(t1.acc_kind,'99',t1.num,0),'0'))  UR_YDZ_CZ_NUM, ");//
				sql.append("sum(decode(t1.deal_code,'30105010',decode(t1.acc_kind,'99',t1.amt,0),'0'))  UR_YDZ_CZ_AMT, ");//
				sql.append("sum(decode(t1.deal_code,'30105011',decode(t1.acc_kind,'99',t1.num,0),'0'))  UR_YDZ_CZCX_NUM, ");//
				sql.append("sum(decode(t1.deal_code,'30105011',decode(t1.acc_kind,'99',t1.amt,0),'0'))  UR_YDZ_CZCX_AMT, ");//
				sql.append("sum(decode(t1.deal_code, '30105010', decode(t1.acc_kind,'01',t1.num,'02',t1.num,'99',t1.num,'0'), '30105020', t1.num, '30105011', decode(t1.acc_kind,'01',-t1.num,'02',-t1.num,'99',-t1.num,'0'), '30105021', -t1.num, '0'))  YDZ_NUM, ");
				sql.append("sum(decode(t1.acc_kind,'01',t1.amt,'02',t1.amt,'99',t1.amt,'0'))  YDZ_AMT ");
				//sql.append("sum(decode(t1.deal_code, '30105010', t1.num, '30105020', t1.num, '30105011', -t1.num, '30105021', -t1.num, '0'))  TOT_NUM, ");
				//sql.append("sum(t1.amt)  TOT_AMT ");
				//
				sql.append(" from base_co_org t, stat_card_pay_co_org t1  where t.co_org_id = t1.co_org_id(+)  and t1.deal_code in ( "
						+ dealCode +") and t1.acpt_type = '2' ");
				if(!Tools.processNull(coOrgId).equals("")){
					sql.append(" and t1.co_org_id ='"+Tools.processNull(coOrgId)+"'");
				}
				if(!Tools.processNull(coOrgIdSql).equals("")){
					sql.append(" and t1.co_org_id in (" + coOrgIdSql + ") ");
				}
				if(!Tools.processNull(startDate).equals("")){
					sql.append(" and t1.clr_Date >='"+Tools.processNull(startDate)+"'");
				}
				if(!Tools.processNull(endDate).equals("")){
					sql.append(" and t1.clr_Date <='"+Tools.processNull(endDate)+"'");
				}
				sql.append(" group by t.co_org_id,t.co_org_name,t1.card_type ");
				if(statByDay){
					sql.append(", t1.clr_date ");
				}
				sql.append("order by t.co_org_id ");
				if(statByDay){
					sql.append(", t1.clr_date");
				}
				Page pages = baseService.pagingQuery(sql.toString(),page,rows);
				if(pages.getAllRs() == null || pages.getAllRs().size() <= 0){
					throw new CommonException("根据指定信息未查询到充值信息！");
				}else{
					jsonObject.put("rows",pages.getAllRs());
					jsonObject.put("total",pages.getTotalCount());
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	
	
	/**
	 * @author Yueh
	 * @return
	 */
	public String exportCoOrgRechargeMsg(){
		try {
			queryCoOrgRechargeMsg();
			String fileName = "合作机构充值情况统计";
			if(!Tools.processNull(coOrgId).equals("")){
				String coOrgName = (String) baseService.findOnlyFieldBySql("select co_org_name from base_co_org where co_org_id = '" + coOrgId + "'");
				fileName = coOrgName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 6000);
			sheet.setColumnWidth(1, 6000);
			sheet.setColumnWidth(2, 3000);
			int maxColumn = 45;
			if(statByDay){
				maxColumn = 46;
				sheet.setColumnWidth(3, 3000);
			}
			sheet.setColumnWidth(maxColumn - 42, 3000);
			sheet.setColumnWidth(maxColumn - 41, 3000);
			sheet.setColumnWidth(maxColumn - 40, 3000);
			sheet.setColumnWidth(maxColumn - 39, 3000);
			sheet.setColumnWidth(maxColumn - 38, 3000);
			sheet.setColumnWidth(maxColumn - 37, 3000);
			sheet.setColumnWidth(maxColumn - 36, 3000);
			sheet.setColumnWidth(maxColumn - 35, 3000);
			sheet.setColumnWidth(maxColumn - 34, 3000);
			sheet.setColumnWidth(maxColumn - 33, 3000);
			sheet.setColumnWidth(maxColumn - 32, 3000);
			sheet.setColumnWidth(maxColumn - 31, 3000);
			sheet.setColumnWidth(maxColumn - 30, 3000);
			sheet.setColumnWidth(maxColumn - 29, 3000);
			sheet.setColumnWidth(maxColumn - 28, 3000);
			sheet.setColumnWidth(maxColumn - 27, 3000);
			sheet.setColumnWidth(maxColumn - 26, 3000);
			sheet.setColumnWidth(maxColumn - 25, 3000);
			sheet.setColumnWidth(maxColumn - 24, 3000);
			sheet.setColumnWidth(maxColumn - 23, 3000);
			sheet.setColumnWidth(maxColumn - 22, 3000);
			sheet.setColumnWidth(maxColumn - 21, 3000);
			sheet.setColumnWidth(maxColumn - 20, 3000);
			sheet.setColumnWidth(maxColumn - 19, 3000);
			sheet.setColumnWidth(maxColumn - 18, 3000);
			sheet.setColumnWidth(maxColumn - 17, 3000);
			sheet.setColumnWidth(maxColumn - 16, 3000);
			sheet.setColumnWidth(maxColumn - 15, 3000);
			sheet.setColumnWidth(maxColumn - 14, 3000);
			sheet.setColumnWidth(maxColumn - 13, 3000);
			sheet.setColumnWidth(maxColumn - 12, 3000);
			sheet.setColumnWidth(maxColumn - 11, 3000);
			sheet.setColumnWidth(maxColumn - 10, 3000);
			sheet.setColumnWidth(maxColumn - 9, 3000);
			sheet.setColumnWidth(maxColumn - 8, 3000);
			sheet.setColumnWidth(maxColumn - 7, 3000);
			sheet.setColumnWidth(maxColumn - 6, 3000);
			sheet.setColumnWidth(maxColumn - 5, 3000);
			sheet.setColumnWidth(maxColumn - 4, 3000);
			sheet.setColumnWidth(maxColumn - 3, 3000);
			sheet.setColumnWidth(maxColumn - 2, 3000);
			sheet.setColumnWidth(maxColumn - 1, 3000);

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
			int headRows = 6;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			sheet.getRow(1).getCell(0).setCellValue("统计时间：" + startDate + " ~ " + endDate + "    导出时间：" + DateUtils.getNowTime());

			// second header
			sheet.getRow(2).getCell(0).setCellValue("合作机构编号");
			sheet.getRow(2).getCell(1).setCellValue("合作机构名称");
			sheet.getRow(2).getCell(2).setCellValue("卡类型");
			if (statByDay) {
				sheet.getRow(2).getCell(3).setCellValue("清分日期");
			}
			sheet.getRow(2).getCell(maxColumn - 42).setCellValue("已对账");
			sheet.getRow(2).getCell(maxColumn - 22).setCellValue("未对账");
			sheet.getRow(2).getCell(maxColumn - 2).setCellValue("总计");
			
			// third header
			sheet.getRow(3).getCell(maxColumn - 42).setCellValue("市民卡账户");
			sheet.getRow(3).getCell(maxColumn - 36).setCellValue("市民卡钱包");
			sheet.getRow(3).getCell(maxColumn - 30).setCellValue("未登账户");
			sheet.getRow(3).getCell(maxColumn - 24).setCellValue("已对账合计");
			sheet.getRow(3).getCell(maxColumn - 22).setCellValue("市民卡账户");
			sheet.getRow(3).getCell(maxColumn - 16).setCellValue("市民卡钱包");
			sheet.getRow(3).getCell(maxColumn - 10).setCellValue("未登账户");
			sheet.getRow(3).getCell(maxColumn - 4).setCellValue("未对账合计");
			
			// fourth header
			sheet.getRow(4).getCell(maxColumn - 42).setCellValue("充值");
			sheet.getRow(4).getCell(maxColumn - 40).setCellValue("充值撤销");
			sheet.getRow(4).getCell(maxColumn - 38).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 36).setCellValue("充值");
			sheet.getRow(4).getCell(maxColumn - 34).setCellValue("充值撤销");
			sheet.getRow(4).getCell(maxColumn - 32).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 30).setCellValue("充值");
			sheet.getRow(4).getCell(maxColumn - 28).setCellValue("充值撤销");
			sheet.getRow(4).getCell(maxColumn - 26).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 24).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 23).setCellValue("金额");
			sheet.getRow(4).getCell(maxColumn - 22).setCellValue("充值");
			sheet.getRow(4).getCell(maxColumn - 20).setCellValue("充值撤销");
			sheet.getRow(4).getCell(maxColumn - 18).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 16).setCellValue("充值");
			sheet.getRow(4).getCell(maxColumn - 14).setCellValue("充值撤销");
			sheet.getRow(4).getCell(maxColumn - 12).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 10).setCellValue("充值");
			sheet.getRow(4).getCell(maxColumn - 8).setCellValue("充值撤销");
			sheet.getRow(4).getCell(maxColumn - 6).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 4).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 3).setCellValue("金额");
			sheet.getRow(4).getCell(maxColumn - 2).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 1).setCellValue("金额");
			
			// fifth header
			sheet.getRow(5).getCell(maxColumn - 42).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 41).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 40).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 39).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 38).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 37).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 36).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 35).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 34).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 33).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 32).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 31).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 30).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 29).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 28).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 27).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 26).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 25).setCellValue("金额");
			//
			sheet.getRow(5).getCell(maxColumn - 22).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 21).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 20).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 19).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 18).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 17).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 16).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 15).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 14).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 13).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 12).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 11).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 10).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 9).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 8).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 7).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 6).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 5).setCellValue("金额");
			//
			sheet.getRow(5).getCell(maxColumn - 2).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 1).setCellValue("金额");

			// Merge
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 1, 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 2, 2));
			if (statByDay) {
				sheet.addMergedRegion(new CellRangeAddress(2, 5, 3, 3));
			}
			sheet.addMergedRegion(new CellRangeAddress(2, 2, maxColumn - 42, maxColumn - 23));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, maxColumn - 22, maxColumn - 3));
			sheet.addMergedRegion(new CellRangeAddress(2, 4, maxColumn - 2, maxColumn - 1));
			//
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 42, maxColumn - 37));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 36, maxColumn - 31));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 30, maxColumn - 25));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 24, maxColumn - 23));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 22, maxColumn - 17));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 16, maxColumn - 11));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 10, maxColumn - 5));
			sheet.addMergedRegion(new CellRangeAddress(3, 3, maxColumn - 4, maxColumn - 3));
			//
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 42, maxColumn - 41));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 40, maxColumn - 39));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 38, maxColumn - 37));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 36, maxColumn - 35));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 34, maxColumn - 33));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 32, maxColumn - 31));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 30, maxColumn - 29));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 28, maxColumn - 27));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 26, maxColumn - 25));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 22, maxColumn - 21));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 20, maxColumn - 19));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 18, maxColumn - 17));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 16, maxColumn - 15));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 14, maxColumn - 13));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 12, maxColumn - 11));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 10, maxColumn - 9));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 8, maxColumn - 7));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 6, maxColumn - 5));
			sheet.addMergedRegion(new CellRangeAddress(4, 5, maxColumn - 24, maxColumn - 24));
			sheet.addMergedRegion(new CellRangeAddress(4, 5, maxColumn - 23, maxColumn - 23));
			sheet.addMergedRegion(new CellRangeAddress(4, 5, maxColumn - 4, maxColumn - 4));
			sheet.addMergedRegion(new CellRangeAddress(4, 5, maxColumn - 3, maxColumn - 3));
			//
			sheet.createFreezePane(statByDay?4:3, 6);
			
			int numSum = 0;
			int ljYdzCzNumSum = 0;
			double ljYdzCzAmtSum = 0;
			int ljYdzCzCxNumSum = 0;
			double ljYdzCzCxAmtSum = 0;
			int ljYdzNumSum = 0;
			double ljYdzAmtSum = 0;
			//
			int qBYdzCzNumSum = 0;
			double qBYdzCzAmtSum = 0;
			int qBYdzCzCxNumSum = 0;
			double qBYdzCzCxAmtSum = 0;
			int qBYdzNumSum = 0;
			double qBYdzAmtSum = 0;
			//
			int uRYdzCzNumSum = 0;
			double uRYdzCzAmtSum = 0;
			int uRYdzCzCxNumSum = 0;
			double uRYdzCzCxAmtSum = 0;
			int uRYdzNumSum = 0;
			double uRYdzAmtSum = 0;
			//
			int ydzNumSum = 0;
			double ydzAmtSum = 0;
			//
			int ljWdzCzNumSum = 0;
			double ljWdzCzAmtSum = 0;
			int ljWdzCzCxNumSum = 0;
			double ljWdzCzCxAmtSum = 0;
			int ljWdzNumSum = 0;
			double ljWdzAmtSum = 0;
			//
			int qBWdzCzNumSum = 0;
			double qBWdzCzAmtSum = 0;
			int qBWdzCzCxNumSum = 0;
			double qBWdzCzCxAmtSum = 0;
			int qBWdzNumSum = 0;
			double qBWdzAmtSum = 0;
			//
			int uRWdzCzNumSum = 0;
			double uRWdzCzAmtSum = 0;
			int uRWdzCzCxNumSum = 0;
			double uRWdzCzCxAmtSum = 0;
			int uRWdzNumSum = 0;
			double uRWdzAmtSum = 0;
			//
			int WdzNumSum = 0;
			double WdzAmtSum = 0;
			//
			int totNumSum = 0;
			double totAmtSum = 0;
			for (int i = 0; i < data.size(); i++, numSum++) {
				JSONObject item = (JSONObject) data.get(i);
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j > 2 && j % 2 == (statByDay ? 1 : 0)) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				row.getCell(0).setCellValue(item.getString("CO_ORG_ID"));
				row.getCell(1).setCellValue(item.getString("CO_ORG_NAME"));
				row.getCell(2).setCellValue(item.getString("CARD_TYPE"));
				if (statByDay) {
					row.getCell(3).setCellValue(item.getString("CLR_DATE"));
				}
				// 已对账
				// 联机已对账
				// 充值
				row.getCell(maxColumn - 42).setCellValue(item.getIntValue("LJ_YDZ_CZ_NUM"));
				row.getCell(maxColumn - 41).setCellValue(item.getDoubleValue("LJ_YDZ_CZ_AMT") / 100);
				ljYdzCzNumSum += item.getIntValue("LJ_YDZ_CZ_NUM");
				ljYdzCzAmtSum += item.getDoubleValue("LJ_YDZ_CZ_AMT");
				// 充值撤销
				row.getCell(maxColumn - 40).setCellValue(item.getIntValue("LJ_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 39).setCellValue(item.getDoubleValue("LJ_YDZ_CZCX_AMT") / 100);
				ljYdzCzCxNumSum += item.getIntValue("LJ_YDZ_CZCX_NUM");
				ljYdzCzCxAmtSum += item.getDoubleValue("LJ_YDZ_CZCX_AMT");
				// 小计
				row.getCell(maxColumn - 38).setCellValue(item.getIntValue("LJ_YDZ_CZ_NUM") - item.getIntValue("LJ_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 37).setCellValue((item.getDoubleValue("LJ_YDZ_CZ_AMT") + item.getDoubleValue("LJ_YDZ_CZCX_AMT")) / 100);
				ljYdzNumSum += item.getIntValue("LJ_YDZ_CZ_NUM") - item.getIntValue("LJ_YDZ_CZCX_NUM");
				ljYdzAmtSum += item.getDoubleValue("LJ_YDZ_CZ_AMT") + item.getDoubleValue("LJ_YDZ_CZCX_AMT");
				
				// 钱包已对账
				// 充值
				row.getCell(maxColumn - 36).setCellValue(item.getIntValue("QB_YDZ_CZ_NUM"));
				row.getCell(maxColumn - 35).setCellValue(item.getDoubleValue("QB_YDZ_CZ_AMT") / 100);
				qBYdzCzNumSum += item.getIntValue("QB_YDZ_CZ_NUM");
				qBYdzCzAmtSum += item.getDoubleValue("QB_YDZ_CZ_AMT");
				// 充值撤销
				row.getCell(maxColumn - 34).setCellValue(item.getIntValue("QB_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 33).setCellValue(item.getDoubleValue("QB_YDZ_CZCX_AMT") / 100);
				qBYdzCzCxNumSum += item.getIntValue("QB_YDZ_CZCX_NUM");
				qBYdzCzCxAmtSum += item.getDoubleValue("QB_YDZ_CZCX_AMT");
				// 小计
				row.getCell(maxColumn - 32).setCellValue(item.getIntValue("QB_YDZ_CZ_NUM") - item.getIntValue("QB_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 31).setCellValue((item.getDoubleValue("QB_YDZ_CZ_AMT") + item.getDoubleValue("QB_YDZ_CZCX_AMT")) / 100);
				qBYdzNumSum += item.getIntValue("QB_YDZ_CZ_NUM") - item.getIntValue("QB_YDZ_CZCX_NUM");
				qBYdzAmtSum += item.getDoubleValue("QB_YDZ_CZ_AMT") + item.getDoubleValue("QB_YDZ_CZCX_AMT");
				
				// 未登已对账
				// 充值
				row.getCell(maxColumn - 30).setCellValue(item.getIntValue("UR_YDZ_CZ_NUM"));
				row.getCell(maxColumn - 29).setCellValue(item.getDoubleValue("UR_YDZ_CZ_AMT") / 100);
				uRYdzCzNumSum += item.getIntValue("UR_YDZ_CZ_NUM");
				uRYdzCzAmtSum += item.getDoubleValue("UR_YDZ_CZ_AMT");
				// 充值撤销
				row.getCell(maxColumn - 28).setCellValue(item.getIntValue("UR_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 27).setCellValue(item.getDoubleValue("UR_YDZ_CZCX_AMT") / 100);
				uRYdzCzCxNumSum += item.getIntValue("UR_YDZ_CZCX_NUM");
				uRYdzCzCxAmtSum += item.getDoubleValue("UR_YDZ_CZCX_AMT");
				// 小计
				row.getCell(maxColumn - 26).setCellValue(item.getIntValue("UR_YDZ_CZ_NUM") - item.getIntValue("UR_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 25).setCellValue((item.getDoubleValue("UR_YDZ_CZ_AMT") + item.getDoubleValue("UR_YDZ_CZCX_AMT")) / 100);
				uRYdzNumSum += item.getIntValue("UR_YDZ_CZ_NUM") - item.getIntValue("UR_YDZ_CZCX_NUM");
				uRYdzAmtSum += item.getDoubleValue("UR_YDZ_CZ_AMT") + item.getDoubleValue("UR_YDZ_CZCX_AMT");
				
				// 已对账总计
				row.getCell(maxColumn - 24).setCellValue(item.getIntValue("YDZ_NUM"));
				row.getCell(maxColumn - 23).setCellValue(item.getDoubleValue("YDZ_AMT") / 100);
				ydzNumSum += item.getIntValue("YDZ_NUM");
				ydzAmtSum += item.getDoubleValue("YDZ_AMT");
				
				// 未对账
				// 联机未对账
				// 充值
				row.getCell(maxColumn - 22).setCellValue(item.getIntValue("LJ_WDZ_CZ_NUM"));
				row.getCell(maxColumn - 21).setCellValue(item.getDoubleValue("LJ_WDZ_CZ_AMT") / 100);
				ljWdzCzNumSum += item.getIntValue("LJ_WDZ_CZ_NUM");
				ljWdzCzAmtSum += item.getDoubleValue("LJ_WDZ_CZ_AMT");
				// 充值撤销
				row.getCell(maxColumn - 20).setCellValue(item.getIntValue("LJ_WDZ_CZCX_NUM"));
				row.getCell(maxColumn - 19).setCellValue(item.getDoubleValue("LJ_WDZ_CZCX_AMT") / 100);
				ljWdzCzCxNumSum += item.getIntValue("LJ_WDZ_CZCX_NUM");
				ljWdzCzCxAmtSum += item.getDoubleValue("LJ_WDZ_CZCX_AMT");
				// 小计
				row.getCell(maxColumn - 18).setCellValue(item.getIntValue("LJ_WDZ_CZ_NUM") - item.getIntValue("LJ_WDZ_CZCX_NUM"));
				row.getCell(maxColumn - 17).setCellValue((item.getDoubleValue("LJ_WDZ_CZ_AMT") + item.getDoubleValue("LJ_WDZ_CZCX_AMT")) / 100);
				ljWdzNumSum += item.getIntValue("LJ_WDZ_CZ_NUM") - item.getIntValue("LJ_WDZ_CZCX_NUM");
				ljWdzAmtSum += item.getDoubleValue("LJ_WDZ_CZ_AMT") + item.getDoubleValue("LJ_WDZ_CZCX_AMT");
				
				// 钱包未对账
				// 充值
				row.getCell(maxColumn - 16).setCellValue(item.getIntValue("QB_WDZ_CZ_NUM"));
				row.getCell(maxColumn - 15).setCellValue(item.getDoubleValue("QB_WDZ_CZ_AMT") / 100);
				qBWdzCzNumSum += item.getIntValue("QB_WDZ_CZ_NUM");
				qBWdzCzAmtSum += item.getDoubleValue("QB_WDZ_CZ_AMT");
				// 充值撤销
				row.getCell(maxColumn - 14).setCellValue(item.getIntValue("QB_WDZ_CZCX_NUM"));
				row.getCell(maxColumn - 13).setCellValue(item.getDoubleValue("QB_WDZ_CZCX_AMT") / 100);
				qBWdzCzCxNumSum += item.getIntValue("QB_WDZ_CZCX_NUM");
				qBWdzCzCxAmtSum += item.getDoubleValue("QB_WDZ_CZCX_AMT");
				// 小计
				row.getCell(maxColumn - 12).setCellValue(item.getIntValue("QB_WDZ_CZ_NUM") - item.getIntValue("QB_WDZ_CZCX_NUM"));
				row.getCell(maxColumn - 11).setCellValue((item.getDoubleValue("QB_WDZ_CZ_AMT") + item.getDoubleValue("QB_WDZ_CZCX_AMT")) / 100);
				qBWdzNumSum += item.getIntValue("QB_WDZ_CZ_NUM") - item.getIntValue("QB_WDZ_CZCX_NUM");
				qBWdzAmtSum += item.getDoubleValue("QB_WDZ_CZ_AMT") + item.getDoubleValue("QB_WDZ_CZCX_AMT");
				
				// 未登未对账
				// 充值
				row.getCell(maxColumn - 10).setCellValue(item.getIntValue("UR_WDZ_CZ_NUM"));
				row.getCell(maxColumn - 9).setCellValue(item.getDoubleValue("UR_WDZ_CZ_AMT") / 100);
				uRWdzCzNumSum += item.getIntValue("UR_WDZ_CZ_NUM");
				uRWdzCzAmtSum += item.getDoubleValue("UR_WDZ_CZ_AMT");
				// 充值撤销
				row.getCell(maxColumn - 8).setCellValue(item.getIntValue("UR_WDZ_CZCX_NUM"));
				row.getCell(maxColumn - 7).setCellValue(item.getDoubleValue("UR_WDZ_CZCX_AMT") / 100);
				uRWdzCzCxNumSum += item.getIntValue("UR_WDZ_CZCX_NUM");
				uRWdzCzCxAmtSum += item.getDoubleValue("UR_WDZ_CZCX_AMT");
				// 小计
				row.getCell(maxColumn - 6).setCellValue(item.getIntValue("UR_WDZ_CZ_NUM") - item.getIntValue("UR_WDZ_CZCX_NUM"));
				row.getCell(maxColumn - 5).setCellValue((item.getDoubleValue("UR_WDZ_CZ_AMT") + item.getDoubleValue("UR_WDZ_CZCX_AMT")) / 100);
				uRWdzNumSum += item.getIntValue("UR_WDZ_CZ_NUM") - item.getIntValue("UR_WDZ_CZCX_NUM");
				uRWdzAmtSum += item.getDoubleValue("UR_WDZ_CZ_AMT") + item.getDoubleValue("UR_WDZ_CZCX_AMT");
				
				// 未对账总计
				row.getCell(maxColumn - 4).setCellValue(item.getIntValue("WDZ_NUM"));
				row.getCell(maxColumn - 3).setCellValue(item.getDoubleValue("WDZ_AMT") / 100);
				WdzNumSum += item.getIntValue("WDZ_NUM");
				WdzAmtSum += item.getDoubleValue("WDZ_AMT");
				//
				row.getCell(maxColumn - 2).setCellValue(item.getIntValue("TOT_NUM"));
				row.getCell(maxColumn - 1).setCellValue(item.getDoubleValue("TOT_AMT") / 100);
				totNumSum += item.getIntValue("TOT_NUM");
				totAmtSum += item.getDoubleValue("TOT_AMT");
			}
			
			// footer
			Row row = sheet.createRow(data.size() + headRows);
			for (int i = 0; i < maxColumn; i++) {
				Cell cell = row.createCell(i);
				if (i > 3 && i % 2 == (statByDay ? 1 : 0)) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(0).setCellValue("统计");
			row.getCell(1).setCellValue("共 " + numSum + " 条记录");
			//
			row.getCell(maxColumn - 42).setCellValue(ljYdzCzNumSum);
			row.getCell(maxColumn - 41).setCellValue(ljYdzCzAmtSum / 100);
			row.getCell(maxColumn - 40).setCellValue(ljYdzCzCxNumSum);
			row.getCell(maxColumn - 39).setCellValue(ljYdzCzCxAmtSum / 100);
			row.getCell(maxColumn - 38).setCellValue(ljYdzNumSum);
			row.getCell(maxColumn - 37).setCellValue(ljYdzAmtSum / 100);
			//
			row.getCell(maxColumn - 36).setCellValue(qBYdzCzNumSum);
			row.getCell(maxColumn - 35).setCellValue(qBYdzCzAmtSum / 100);
			row.getCell(maxColumn - 34).setCellValue(qBYdzCzCxNumSum);
			row.getCell(maxColumn - 33).setCellValue(qBYdzCzCxAmtSum / 100);
			row.getCell(maxColumn - 32).setCellValue(qBYdzNumSum);
			row.getCell(maxColumn - 31).setCellValue(qBYdzAmtSum / 100);
			//
			row.getCell(maxColumn - 30).setCellValue(uRYdzCzNumSum);
			row.getCell(maxColumn - 29).setCellValue(uRYdzCzAmtSum / 100);
			row.getCell(maxColumn - 28).setCellValue(uRYdzCzCxNumSum);
			row.getCell(maxColumn - 27).setCellValue(uRYdzCzCxAmtSum / 100);
			row.getCell(maxColumn - 26).setCellValue(uRYdzNumSum);
			row.getCell(maxColumn - 25).setCellValue(uRYdzAmtSum / 100);
			//
			row.getCell(maxColumn - 24).setCellValue(ydzNumSum);
			row.getCell(maxColumn - 23).setCellValue(ydzAmtSum / 100);
			//
			row.getCell(maxColumn - 22).setCellValue(ljWdzCzNumSum);
			row.getCell(maxColumn - 21).setCellValue(ljWdzCzAmtSum / 100);
			row.getCell(maxColumn - 20).setCellValue(ljWdzCzCxNumSum);
			row.getCell(maxColumn - 19).setCellValue(ljWdzCzCxAmtSum / 100);
			row.getCell(maxColumn - 18).setCellValue(ljWdzNumSum);
			row.getCell(maxColumn - 17).setCellValue(ljWdzAmtSum / 100);
			//
			row.getCell(maxColumn - 16).setCellValue(qBWdzCzNumSum);
			row.getCell(maxColumn - 15).setCellValue(qBWdzCzAmtSum / 100);
			row.getCell(maxColumn - 14).setCellValue(qBWdzCzCxNumSum);
			row.getCell(maxColumn - 13).setCellValue(qBWdzCzCxAmtSum / 100);
			row.getCell(maxColumn - 12).setCellValue(qBWdzNumSum);
			row.getCell(maxColumn - 11).setCellValue(qBWdzAmtSum / 100);
			//
			row.getCell(maxColumn - 10).setCellValue(uRWdzCzNumSum);
			row.getCell(maxColumn - 9).setCellValue(uRWdzCzAmtSum / 100);
			row.getCell(maxColumn - 8).setCellValue(uRWdzCzCxNumSum);
			row.getCell(maxColumn - 7).setCellValue(uRWdzCzCxAmtSum / 100);
			row.getCell(maxColumn - 6).setCellValue(uRWdzNumSum);
			row.getCell(maxColumn - 5).setCellValue(uRWdzAmtSum / 100);
			//
			row.getCell(maxColumn - 4).setCellValue(WdzNumSum);
			row.getCell(maxColumn - 3).setCellValue(WdzAmtSum / 100);
			//
			row.getCell(maxColumn - 2).setCellValue(totNumSum);
			row.getCell(maxColumn - 1).setCellValue(totAmtSum / 100);
			
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportCoOrgRechargeCWMsg(){
		try {
			queryCoOrgRechargeCWMsg();
			String fileName = "合作机构充值情况统计";
			if(!Tools.processNull(coOrgId).equals("")){
				String coOrgName = (String) baseService.findOnlyFieldBySql("select co_org_name from base_co_org where co_org_id = '" + coOrgId + "'");
				fileName = coOrgName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 6000);
			sheet.setColumnWidth(1, 6000);
			sheet.setColumnWidth(2, 3000);
			int maxColumn = 23;
			if(statByDay){
				maxColumn = 24;
				sheet.setColumnWidth(3, 3000);
			}
			
			sheet.setColumnWidth(maxColumn - 20, 3000);
			sheet.setColumnWidth(maxColumn - 19, 3000);
			sheet.setColumnWidth(maxColumn - 18, 3000);
			sheet.setColumnWidth(maxColumn - 17, 3000);
			sheet.setColumnWidth(maxColumn - 16, 3000);
			sheet.setColumnWidth(maxColumn - 15, 3000);
			sheet.setColumnWidth(maxColumn - 14, 3000);
			sheet.setColumnWidth(maxColumn - 13, 3000);
			sheet.setColumnWidth(maxColumn - 12, 3000);
			sheet.setColumnWidth(maxColumn - 11, 3000);
			sheet.setColumnWidth(maxColumn - 10, 3000);
			sheet.setColumnWidth(maxColumn - 9, 3000);
			sheet.setColumnWidth(maxColumn - 8, 3000);
			sheet.setColumnWidth(maxColumn - 7, 3000);
			sheet.setColumnWidth(maxColumn - 6, 3000);
			sheet.setColumnWidth(maxColumn - 5, 3000);
			sheet.setColumnWidth(maxColumn - 4, 3000);
			sheet.setColumnWidth(maxColumn - 3, 3000);
			sheet.setColumnWidth(maxColumn - 2, 3000);
			sheet.setColumnWidth(maxColumn - 1, 3000);

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
			int headRows = 6;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			sheet.getRow(1).getCell(0).setCellValue("统计时间：" + startDate + " ~ " + endDate + "    导出时间：" + DateUtils.getNowTime());

			// second header
			sheet.getRow(2).getCell(0).setCellValue("合作机构编号");
			sheet.getRow(2).getCell(1).setCellValue("合作机构名称");
			sheet.getRow(2).getCell(2).setCellValue("卡类型");
			if (statByDay) {
				sheet.getRow(2).getCell(3).setCellValue("清分日期");
			}
			sheet.getRow(2).getCell(maxColumn - 2).setCellValue("总计");
			
			// third header
			sheet.getRow(2).getCell(maxColumn - 20).setCellValue("市民卡账户");
			sheet.getRow(2).getCell(maxColumn - 14).setCellValue("市民卡钱包");
			sheet.getRow(2).getCell(maxColumn - 8).setCellValue("未登账户");
			
			// fourth header
			sheet.getRow(4).getCell(maxColumn - 20).setCellValue("充值");
			sheet.getRow(4).getCell(maxColumn - 18).setCellValue("充值撤销");
			sheet.getRow(4).getCell(maxColumn - 16).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 14).setCellValue("充值");
			sheet.getRow(4).getCell(maxColumn - 12).setCellValue("充值撤销");
			sheet.getRow(4).getCell(maxColumn - 10).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 8).setCellValue("充值");
			sheet.getRow(4).getCell(maxColumn - 6).setCellValue("充值撤销");
			sheet.getRow(4).getCell(maxColumn - 4).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 2).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 1).setCellValue("金额");
			
			// fifth header
			//
			sheet.getRow(5).getCell(maxColumn - 20).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 19).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 18).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 17).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 16).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 15).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 14).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 13).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 12).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 11).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 10).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 9).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 8).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 7).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 6).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 5).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 4).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 3).setCellValue("金额");
			//
			sheet.getRow(5).getCell(maxColumn - 2).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 1).setCellValue("金额");

			// Merge
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 1, 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 2, 2));
			if (statByDay) {
				sheet.addMergedRegion(new CellRangeAddress(2, 5, 3, 3));
			}
			//sheet.addMergedRegion(new CellRangeAddress(2, 2, maxColumn - 42, maxColumn - 23));
			//sheet.addMergedRegion(new CellRangeAddress(0, 0, maxColumn - 20, maxColumn - 3));
			sheet.addMergedRegion(new CellRangeAddress(2, 4, maxColumn - 2, maxColumn - 1));
			//
			sheet.addMergedRegion(new CellRangeAddress(2, 3, maxColumn - 20, maxColumn - 15));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, maxColumn - 14, maxColumn - 9));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, maxColumn - 8, maxColumn - 3));
			//
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 20, maxColumn - 19));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 18, maxColumn - 17));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 16, maxColumn - 15));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 14, maxColumn - 13));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 12, maxColumn - 11));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 10, maxColumn - 9));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 8, maxColumn - 7));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 6, maxColumn - 5));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 4, maxColumn - 3));
			//sheet.addMergedRegion(new CellRangeAddress(4, 5, maxColumn - 24, maxColumn - 24));
			//sheet.addMergedRegion(new CellRangeAddress(4, 5, maxColumn - 23, maxColumn - 23));
			//
			sheet.createFreezePane(statByDay?4:3, 6);
			
			int numSum = 0;
			int ljYdzCzNumSum = 0;
			double ljYdzCzAmtSum = 0;
			int ljYdzCzCxNumSum = 0;
			double ljYdzCzCxAmtSum = 0;
			int ljYdzNumSum = 0;
			double ljYdzAmtSum = 0;
			//
			int qBYdzCzNumSum = 0;
			double qBYdzCzAmtSum = 0;
			int qBYdzCzCxNumSum = 0;
			double qBYdzCzCxAmtSum = 0;
			int qBYdzNumSum = 0;
			double qBYdzAmtSum = 0;
			//
			int uRYdzCzNumSum = 0;
			double uRYdzCzAmtSum = 0;
			int uRYdzCzCxNumSum = 0;
			double uRYdzCzCxAmtSum = 0;
			int uRYdzNumSum = 0;
			double uRYdzAmtSum = 0;
			//
			int ydzNumSum = 0;
			double ydzAmtSum = 0;
			//
			int ljWdzCzNumSum = 0;
			double ljWdzCzAmtSum = 0;
			int ljWdzCzCxNumSum = 0;
			double ljWdzCzCxAmtSum = 0;
			int ljWdzNumSum = 0;
			double ljWdzAmtSum = 0;
			//
			int qBWdzCzNumSum = 0;
			double qBWdzCzAmtSum = 0;
			int qBWdzCzCxNumSum = 0;
			double qBWdzCzCxAmtSum = 0;
			int qBWdzNumSum = 0;
			double qBWdzAmtSum = 0;
			//
			int uRWdzCzNumSum = 0;
			double uRWdzCzAmtSum = 0;
			int uRWdzCzCxNumSum = 0;
			double uRWdzCzCxAmtSum = 0;
			int uRWdzNumSum = 0;
			double uRWdzAmtSum = 0;
			//
			int WdzNumSum = 0;
			double WdzAmtSum = 0;
			//
			int totNumSum = 0;
			double totAmtSum = 0;
			for (int i = 0; i < data.size(); i++, numSum++) {
				JSONObject item = (JSONObject) data.get(i);
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j > 2 && j % 2 == (statByDay ? 1 : 0)) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				row.getCell(0).setCellValue(item.getString("CO_ORG_ID"));
				row.getCell(1).setCellValue(item.getString("CO_ORG_NAME"));
				row.getCell(2).setCellValue(item.getString("CARD_TYPE"));
				if (statByDay) {
					row.getCell(3).setCellValue(item.getString("CLR_DATE"));
				}
				// 已对账
				// 联机已对账
				// 充值
				row.getCell(maxColumn - 20).setCellValue(item.getIntValue("LJ_YDZ_CZ_NUM"));
				row.getCell(maxColumn - 19).setCellValue(item.getDoubleValue("LJ_YDZ_CZ_AMT") / 100);
				System.out.println(item.getDoubleValue("LJ_YDZ_CZ_AMT"));
				ljYdzCzNumSum += item.getIntValue("LJ_YDZ_CZ_NUM");
				ljYdzCzAmtSum += item.getDoubleValue("LJ_YDZ_CZ_AMT");
				// 充值撤销
				row.getCell(maxColumn - 18).setCellValue(item.getIntValue("LJ_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 17).setCellValue(item.getDoubleValue("LJ_YDZ_CZCX_AMT") / 100);
				ljYdzCzCxNumSum += item.getIntValue("LJ_YDZ_CZCX_NUM");
				ljYdzCzCxAmtSum += item.getDoubleValue("LJ_YDZ_CZCX_AMT");
				// 小计
				row.getCell(maxColumn - 16).setCellValue(item.getIntValue("LJ_YDZ_CZ_NUM") - item.getIntValue("LJ_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 15).setCellValue((item.getDoubleValue("LJ_YDZ_CZ_AMT") + item.getDoubleValue("LJ_YDZ_CZCX_AMT")) / 100);
				ljYdzNumSum += item.getIntValue("LJ_YDZ_CZ_NUM") - item.getIntValue("LJ_YDZ_CZCX_NUM");
				ljYdzAmtSum += item.getDoubleValue("LJ_YDZ_CZ_AMT") + item.getDoubleValue("LJ_YDZ_CZCX_AMT");
				
				// 钱包已对账
				// 充值
				row.getCell(maxColumn - 14).setCellValue(item.getIntValue("QB_YDZ_CZ_NUM"));
				row.getCell(maxColumn - 13).setCellValue(item.getDoubleValue("QB_YDZ_CZ_AMT") / 100);
				qBYdzCzNumSum += item.getIntValue("QB_YDZ_CZ_NUM");
				qBYdzCzAmtSum += item.getDoubleValue("QB_YDZ_CZ_AMT");
				// 充值撤销
				row.getCell(maxColumn - 12).setCellValue(item.getIntValue("QB_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 11).setCellValue(item.getDoubleValue("QB_YDZ_CZCX_AMT") / 100);
				qBYdzCzCxNumSum += item.getIntValue("QB_YDZ_CZCX_NUM");
				qBYdzCzCxAmtSum += item.getDoubleValue("QB_YDZ_CZCX_AMT");
				// 小计
				row.getCell(maxColumn - 10).setCellValue(item.getIntValue("QB_YDZ_CZ_NUM") - item.getIntValue("QB_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 9).setCellValue((item.getDoubleValue("QB_YDZ_CZ_AMT") + item.getDoubleValue("QB_YDZ_CZCX_AMT")) / 100);
				qBYdzNumSum += item.getIntValue("QB_YDZ_CZ_NUM") - item.getIntValue("QB_YDZ_CZCX_NUM");
				qBYdzAmtSum += item.getDoubleValue("QB_YDZ_CZ_AMT") + item.getDoubleValue("QB_YDZ_CZCX_AMT");
				
				// 未登已对账
				// 充值
				row.getCell(maxColumn - 8).setCellValue(item.getIntValue("UR_YDZ_CZ_NUM"));
				row.getCell(maxColumn - 7).setCellValue(item.getDoubleValue("UR_YDZ_CZ_AMT") / 100);
				uRYdzCzNumSum += item.getIntValue("UR_YDZ_CZ_NUM");
				uRYdzCzAmtSum += item.getDoubleValue("UR_YDZ_CZ_AMT");
				// 充值撤销
				row.getCell(maxColumn - 6).setCellValue(item.getIntValue("UR_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 5).setCellValue(item.getDoubleValue("UR_YDZ_CZCX_AMT") / 100);
				uRYdzCzCxNumSum += item.getIntValue("UR_YDZ_CZCX_NUM");
				uRYdzCzCxAmtSum += item.getDoubleValue("UR_YDZ_CZCX_AMT");
				// 小计
				row.getCell(maxColumn - 4).setCellValue(item.getIntValue("UR_YDZ_CZ_NUM") - item.getIntValue("UR_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 3).setCellValue((item.getDoubleValue("UR_YDZ_CZ_AMT") + item.getDoubleValue("UR_YDZ_CZCX_AMT")) / 100);
				uRYdzNumSum += item.getIntValue("UR_YDZ_CZ_NUM") - item.getIntValue("UR_YDZ_CZCX_NUM");
				uRYdzAmtSum += item.getDoubleValue("UR_YDZ_CZ_AMT") + item.getDoubleValue("UR_YDZ_CZCX_AMT");
				
				// 已对账总计
				row.getCell(maxColumn - 2).setCellValue(item.getIntValue("YDZ_NUM"));
				row.getCell(maxColumn - 1).setCellValue(item.getDoubleValue("YDZ_AMT") / 100);
				ydzNumSum += item.getIntValue("YDZ_NUM");
				ydzAmtSum += item.getDoubleValue("YDZ_AMT");
				
				// 未对账
				// 联机未对账
				// 充值
				totNumSum += item.getIntValue("TOT_NUM");
				totAmtSum += item.getDoubleValue("TOT_AMT");
			}
			
			// footer
			Row row = sheet.createRow(data.size() + headRows);
			for (int i = 0; i < maxColumn; i++) {
				Cell cell = row.createCell(i);
				if (i > 3 && i % 2 == (statByDay ? 1 : 0)) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(0).setCellValue("统计");
			row.getCell(1).setCellValue("共 " + numSum + " 条记录");
			//
			row.getCell(maxColumn - 20).setCellValue(ljYdzCzNumSum);
			row.getCell(maxColumn - 19).setCellValue(ljYdzCzAmtSum / 100);
			row.getCell(maxColumn - 18).setCellValue(ljYdzCzCxNumSum);
			row.getCell(maxColumn - 17).setCellValue(ljYdzCzCxAmtSum / 100);
			row.getCell(maxColumn - 16).setCellValue(ljYdzNumSum);
			row.getCell(maxColumn - 15).setCellValue(ljYdzAmtSum / 100);
			//
			row.getCell(maxColumn - 14).setCellValue(qBYdzCzNumSum);
			row.getCell(maxColumn - 13).setCellValue(qBYdzCzAmtSum / 100);
			row.getCell(maxColumn - 12).setCellValue(qBYdzCzCxNumSum);
			row.getCell(maxColumn - 11).setCellValue(qBYdzCzCxAmtSum / 100);
			row.getCell(maxColumn - 10).setCellValue(qBYdzNumSum);
			row.getCell(maxColumn - 9).setCellValue(qBYdzAmtSum / 100);
			//
			row.getCell(maxColumn - 8).setCellValue(uRYdzCzNumSum);
			row.getCell(maxColumn - 7).setCellValue(uRYdzCzAmtSum / 100);
			row.getCell(maxColumn - 6).setCellValue(uRYdzCzCxNumSum);
			row.getCell(maxColumn - 5).setCellValue(uRYdzCzCxAmtSum / 100);
			row.getCell(maxColumn - 4).setCellValue(uRYdzNumSum);
			row.getCell(maxColumn - 3).setCellValue(uRYdzAmtSum / 100);
			//
			row.getCell(maxColumn - 2).setCellValue(ydzNumSum);
			row.getCell(maxColumn - 1).setCellValue(ydzAmtSum / 100);
			//
			
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	
	public String exportCoOrgRechargeRTMsg(){
		try {
			queryCoOrgRechargeStatRt();
			String fileName = "合作机构充值情况统计";
			
			if(!Tools.processNull(coOrgId).equals("")){
				String coOrgName = (String) baseService.findOnlyFieldBySql("select co_org_name from base_co_org where co_org_id = '" + coOrgId + "'");
				fileName = coOrgName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 6000);
			sheet.setColumnWidth(1, 6000);
			sheet.setColumnWidth(2, 3000);
			int maxColumn = 23;
			/*if(statByDay){
				maxColumn = 24;
				sheet.setColumnWidth(3, 3000);
			}*/
			
			sheet.setColumnWidth(maxColumn - 20, 3000);
			sheet.setColumnWidth(maxColumn - 19, 3000);
			sheet.setColumnWidth(maxColumn - 18, 3000);
			sheet.setColumnWidth(maxColumn - 17, 3000);
			sheet.setColumnWidth(maxColumn - 16, 3000);
			sheet.setColumnWidth(maxColumn - 15, 3000);
			sheet.setColumnWidth(maxColumn - 14, 3000);
			sheet.setColumnWidth(maxColumn - 13, 3000);
			sheet.setColumnWidth(maxColumn - 12, 3000);
			sheet.setColumnWidth(maxColumn - 11, 3000);
			sheet.setColumnWidth(maxColumn - 10, 3000);
			sheet.setColumnWidth(maxColumn - 9, 3000);
			sheet.setColumnWidth(maxColumn - 8, 3000);
			sheet.setColumnWidth(maxColumn - 7, 3000);
			sheet.setColumnWidth(maxColumn - 6, 3000);
			sheet.setColumnWidth(maxColumn - 5, 3000);
			sheet.setColumnWidth(maxColumn - 4, 3000);
			sheet.setColumnWidth(maxColumn - 3, 3000);
			sheet.setColumnWidth(maxColumn - 2, 3000);
			sheet.setColumnWidth(maxColumn - 1, 3000);

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
			int headRows = 6;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			sheet.getRow(1).getCell(0).setCellValue("统计时间：" + startDate + " ~ " + endDate + "    导出时间：" + DateUtils.getNowTime());

			// second header
			sheet.getRow(2).getCell(0).setCellValue("合作机构编号");
			sheet.getRow(2).getCell(1).setCellValue("合作机构名称");
			sheet.getRow(2).getCell(2).setCellValue("卡类型");
			
			sheet.getRow(2).getCell(maxColumn - 2).setCellValue("总计");
			
			// third header
			sheet.getRow(2).getCell(maxColumn - 20).setCellValue("市民卡账户");
			sheet.getRow(2).getCell(maxColumn - 14).setCellValue("市民卡钱包");
			sheet.getRow(2).getCell(maxColumn - 8).setCellValue("未登账户");
			
			// fourth header
			sheet.getRow(4).getCell(maxColumn - 20).setCellValue("充值");
			sheet.getRow(4).getCell(maxColumn - 18).setCellValue("充值撤销");
			sheet.getRow(4).getCell(maxColumn - 16).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 14).setCellValue("充值");
			sheet.getRow(4).getCell(maxColumn - 12).setCellValue("充值撤销");
			sheet.getRow(4).getCell(maxColumn - 10).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 8).setCellValue("充值");
			sheet.getRow(4).getCell(maxColumn - 6).setCellValue("充值撤销");
			sheet.getRow(4).getCell(maxColumn - 4).setCellValue("小计");
			sheet.getRow(4).getCell(maxColumn - 2).setCellValue("笔数");
			sheet.getRow(4).getCell(maxColumn - 1).setCellValue("金额");
			
			// fifth header
			//
			sheet.getRow(5).getCell(maxColumn - 20).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 19).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 18).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 17).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 16).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 15).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 14).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 13).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 12).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 11).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 10).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 9).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 8).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 7).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 6).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 5).setCellValue("金额");
			sheet.getRow(5).getCell(maxColumn - 4).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 3).setCellValue("金额");
			//
			sheet.getRow(5).getCell(maxColumn - 2).setCellValue("笔数");
			sheet.getRow(5).getCell(maxColumn - 1).setCellValue("金额");

			// Merge
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 1, 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 5, 2, 2));
			sheet.addMergedRegion(new CellRangeAddress(2, 4, maxColumn - 2, maxColumn - 1));
			//
			sheet.addMergedRegion(new CellRangeAddress(2, 3, maxColumn - 20, maxColumn - 15));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, maxColumn - 14, maxColumn - 9));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, maxColumn - 8, maxColumn - 3));
			//
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 20, maxColumn - 19));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 18, maxColumn - 17));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 16, maxColumn - 15));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 14, maxColumn - 13));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 12, maxColumn - 11));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 10, maxColumn - 9));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 8, maxColumn - 7));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 6, maxColumn - 5));
			sheet.addMergedRegion(new CellRangeAddress(4, 4, maxColumn - 4, maxColumn - 3));
			//
			sheet.createFreezePane(3, 6);
			
			int numSum = 0;
			int ljYdzCzNumSum = 0;
			double ljYdzCzAmtSum = 0;
			int ljYdzCzCxNumSum = 0;
			double ljYdzCzCxAmtSum = 0;
			int ljYdzNumSum = 0;
			double ljYdzAmtSum = 0;
			//
			int qBYdzCzNumSum = 0;
			double qBYdzCzAmtSum = 0;
			int qBYdzCzCxNumSum = 0;
			double qBYdzCzCxAmtSum = 0;
			int qBYdzNumSum = 0;
			double qBYdzAmtSum = 0;
			//
			int uRYdzCzNumSum = 0;
			double uRYdzCzAmtSum = 0;
			int uRYdzCzCxNumSum = 0;
			double uRYdzCzCxAmtSum = 0;
			int uRYdzNumSum = 0;
			double uRYdzAmtSum = 0;
			//
			int ydzNumSum = 0;
			double ydzAmtSum = 0;
			//
			int ljWdzCzNumSum = 0;
			double ljWdzCzAmtSum = 0;
			int ljWdzCzCxNumSum = 0;
			double ljWdzCzCxAmtSum = 0;
			int ljWdzNumSum = 0;
			double ljWdzAmtSum = 0;
			//
			int qBWdzCzNumSum = 0;
			double qBWdzCzAmtSum = 0;
			int qBWdzCzCxNumSum = 0;
			double qBWdzCzCxAmtSum = 0;
			int qBWdzNumSum = 0;
			double qBWdzAmtSum = 0;
			//
			int uRWdzCzNumSum = 0;
			double uRWdzCzAmtSum = 0;
			int uRWdzCzCxNumSum = 0;
			double uRWdzCzCxAmtSum = 0;
			int uRWdzNumSum = 0;
			double uRWdzAmtSum = 0;
			//
			int WdzNumSum = 0;
			double WdzAmtSum = 0;
			//
			int totNumSum = 0;
			double totAmtSum = 0;
			for (int i = 0; i < data.size(); i++, numSum++) {
				JSONObject item = (JSONObject) data.get(i);
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j > 2 && j % 2 == 0) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				
				row.getCell(0).setCellValue(item.getString("CO_ORG_ID"));
				row.getCell(1).setCellValue(item.getString("CO_ORG_NAME"));
				row.getCell(2).setCellValue(item.getString("CARD_TYPE"));
				// 已对账
				// 联机已对账
				// 充值
				row.getCell(maxColumn - 20).setCellValue(item.getIntValue("LJ_YDZ_CZ_NUM"));
				row.getCell(maxColumn - 19).setCellValue(item.getDoubleValue("LJ_YDZ_CZ_AMT") / 100);
				ljYdzCzNumSum += item.getIntValue("LJ_YDZ_CZ_NUM");
				ljYdzCzAmtSum += item.getDoubleValue("LJ_YDZ_CZ_AMT");
				// 充值撤销
				row.getCell(maxColumn - 18).setCellValue(item.getIntValue("LJ_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 17).setCellValue(item.getDoubleValue("LJ_YDZ_CZCX_AMT") / 100);
				ljYdzCzCxNumSum += item.getIntValue("LJ_YDZ_CZCX_NUM");
				ljYdzCzCxAmtSum += item.getDoubleValue("LJ_YDZ_CZCX_AMT");
				// 小计
				row.getCell(maxColumn - 16).setCellValue(item.getIntValue("LJ_YDZ_CZ_NUM") - item.getIntValue("LJ_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 15).setCellValue((item.getDoubleValue("LJ_YDZ_CZ_AMT") + item.getDoubleValue("LJ_YDZ_CZCX_AMT")) / 100);
				ljYdzNumSum += item.getIntValue("LJ_YDZ_CZ_NUM") - item.getIntValue("LJ_YDZ_CZCX_NUM");
				ljYdzAmtSum += item.getDoubleValue("LJ_YDZ_CZ_AMT") + item.getDoubleValue("LJ_YDZ_CZCX_AMT");
				
				// 钱包已对账
				// 充值
				row.getCell(maxColumn - 14).setCellValue(item.getIntValue("QB_YDZ_CZ_NUM"));
				row.getCell(maxColumn - 13).setCellValue(item.getDoubleValue("QB_YDZ_CZ_AMT") / 100);
				qBYdzCzNumSum += item.getIntValue("QB_YDZ_CZ_NUM");
				qBYdzCzAmtSum += item.getDoubleValue("QB_YDZ_CZ_AMT");
				// 充值撤销
				row.getCell(maxColumn - 12).setCellValue(item.getIntValue("QB_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 11).setCellValue(item.getDoubleValue("QB_YDZ_CZCX_AMT") / 100);
				qBYdzCzCxNumSum += item.getIntValue("QB_YDZ_CZCX_NUM");
				qBYdzCzCxAmtSum += item.getDoubleValue("QB_YDZ_CZCX_AMT");
				// 小计
				row.getCell(maxColumn - 10).setCellValue(item.getIntValue("QB_YDZ_CZ_NUM") - item.getIntValue("QB_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 9).setCellValue((item.getDoubleValue("QB_YDZ_CZ_AMT") + item.getDoubleValue("QB_YDZ_CZCX_AMT")) / 100);
				qBYdzNumSum += item.getIntValue("QB_YDZ_CZ_NUM") - item.getIntValue("QB_YDZ_CZCX_NUM");
				qBYdzAmtSum += item.getDoubleValue("QB_YDZ_CZ_AMT") + item.getDoubleValue("QB_YDZ_CZCX_AMT");
				
				// 未登已对账
				// 充值
				row.getCell(maxColumn - 8).setCellValue(item.getIntValue("UR_YDZ_CZ_NUM"));
				row.getCell(maxColumn - 7).setCellValue(item.getDoubleValue("UR_YDZ_CZ_AMT") / 100);
				uRYdzCzNumSum += item.getIntValue("UR_YDZ_CZ_NUM");
				uRYdzCzAmtSum += item.getDoubleValue("UR_YDZ_CZ_AMT");
				// 充值撤销
				row.getCell(maxColumn - 6).setCellValue(item.getIntValue("UR_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 5).setCellValue(item.getDoubleValue("UR_YDZ_CZCX_AMT") / 100);
				uRYdzCzCxNumSum += item.getIntValue("UR_YDZ_CZCX_NUM");
				uRYdzCzCxAmtSum += item.getDoubleValue("UR_YDZ_CZCX_AMT");
				// 小计
				row.getCell(maxColumn - 4).setCellValue(item.getIntValue("UR_YDZ_CZ_NUM") - item.getIntValue("UR_YDZ_CZCX_NUM"));
				row.getCell(maxColumn - 3).setCellValue((item.getDoubleValue("UR_YDZ_CZ_AMT") + item.getDoubleValue("UR_YDZ_CZCX_AMT")) / 100);
				uRYdzNumSum += item.getIntValue("UR_YDZ_CZ_NUM") - item.getIntValue("UR_YDZ_CZCX_NUM");
				uRYdzAmtSum += item.getDoubleValue("UR_YDZ_CZ_AMT") + item.getDoubleValue("UR_YDZ_CZCX_AMT");
				
				// 已对账总计
				row.getCell(maxColumn - 2).setCellValue(item.getIntValue("YDZ_NUM"));
				row.getCell(maxColumn - 1).setCellValue(item.getDoubleValue("YDZ_AMT") / 100);
				ydzNumSum += item.getIntValue("YDZ_NUM");
				ydzAmtSum += item.getDoubleValue("YDZ_AMT");
				
				// 未对账
				// 联机未对账
				// 充值
				totNumSum += item.getIntValue("TOT_NUM");
				totAmtSum += item.getDoubleValue("TOT_AMT");
			}
			
			// footer
			Row row = sheet.createRow(data.size() + headRows);
			for (int i = 0; i < maxColumn; i++) {
				Cell cell = row.createCell(i);
				if (i > 3 && i % 2 == 0) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(0).setCellValue("统计");
			row.getCell(1).setCellValue("共 " + numSum + " 条记录");
			//
			row.getCell(maxColumn - 20).setCellValue(ljYdzCzNumSum);
			row.getCell(maxColumn - 19).setCellValue(ljYdzCzAmtSum / 100);
			row.getCell(maxColumn - 18).setCellValue(ljYdzCzCxNumSum);
			row.getCell(maxColumn - 17).setCellValue(ljYdzCzCxAmtSum / 100);
			row.getCell(maxColumn - 16).setCellValue(ljYdzNumSum);
			row.getCell(maxColumn - 15).setCellValue(ljYdzAmtSum / 100);
			//
			row.getCell(maxColumn - 14).setCellValue(qBYdzCzNumSum);
			row.getCell(maxColumn - 13).setCellValue(qBYdzCzAmtSum / 100);
			row.getCell(maxColumn - 12).setCellValue(qBYdzCzCxNumSum);
			row.getCell(maxColumn - 11).setCellValue(qBYdzCzCxAmtSum / 100);
			row.getCell(maxColumn - 10).setCellValue(qBYdzNumSum);
			row.getCell(maxColumn - 9).setCellValue(qBYdzAmtSum / 100);
			//
			row.getCell(maxColumn - 8).setCellValue(uRYdzCzNumSum);
			row.getCell(maxColumn - 7).setCellValue(uRYdzCzAmtSum / 100);
			row.getCell(maxColumn - 6).setCellValue(uRYdzCzCxNumSum);
			row.getCell(maxColumn - 5).setCellValue(uRYdzCzCxAmtSum / 100);
			row.getCell(maxColumn - 4).setCellValue(uRYdzNumSum);
			row.getCell(maxColumn - 3).setCellValue(uRYdzAmtSum / 100);
			//
			row.getCell(maxColumn - 2).setCellValue(ydzNumSum);
			row.getCell(maxColumn - 1).setCellValue(ydzAmtSum / 100);
			//
			
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	
	
	public String queryCoOrgRechargeStatRt(){
		try {
			initGrid();
			String coOrgIdSql = "";
			if(!Tools.processNull(coOrgIds).equals("")){
				String[] coOrgIdArr = coOrgIds.split(",");
				if (coOrgIdArr != null && coOrgIdArr.length > 0) {
					for (String coOrgId : coOrgIdArr) {
						coOrgIdSql += "'" + coOrgId + "',";
					}
					coOrgIdSql = coOrgIdSql.substring(0, coOrgIdSql.length() - 1);
				}
			}
			String sql = "select t.co_org_id||'|'||card_type seq, t.co_org_id,t.CO_ORG_NAME,"
					+ "(select code_name from sys_code where code_type='CARD_TYPE'and code_value=t2.card_type) card_type,"
					+ "nvl(sum(decode(t2.deal_code,'30105010',decode(t2.acc_kind,02,1,0),0)),0) LJ_YDZ_CZ_NUM,"
					+ "nvl(sum(decode(t2.deal_code,'30105010',decode(t2.acc_kind,02,t2.amt,0),0)),0) LJ_YDZ_CZ_AMT,"
					+ "nvl(sum(decode(t2.deal_code,'30105011',decode(t2.acc_kind,02,1,0),0)),0) LJ_YDZ_CZCX_NUM,"
					+ "nvl(sum(decode(t2.deal_code,'30105011',decode(t2.acc_kind,02,t2.amt,0),0)),0) LJ_YDZ_CZCX_AMT,"
					+ "nvl(sum(decode(t2.deal_code,'30105020',1,0)),0) QB_YDZ_CZ_NUM,"
					+ "nvl(sum(decode(t2.deal_code,'30105020',t2.amt,0)),0) QB_YDZ_CZ_AMT,"
					+ "nvl(sum(decode(t2.deal_code,'30105021',1,0)),0) QB_YDZ_CZCX_NUM,"
					+ "nvl(sum(decode(t2.deal_code,'30105021',t2.amt,0)),0) QB_YDZ_CZCX_AMT,"
					+ "nvl(sum(decode(t2.deal_code,'30105010',decode(t2.acc_kind,99,1,0),0)),0) UR_YDZ_CZ_NUM,"
					+ "nvl(sum(decode(t2.deal_code,'30105010',decode(t2.acc_kind,99,t2.amt,0),0)), 0) UR_YDZ_CZ_AMT,"
					+ "nvl(sum(decode(t2.deal_code,'30105011',decode(t2.acc_kind,99,1,0),0)),0) UR_YDZ_CZCX_NUM,"
					+ "nvl(sum(decode(t2.deal_code,'30105011',decode(t2.acc_kind,99,t2.amt,0),0)), 0) UR_YDZ_CZCX_AMT, "
					+ "nvl(count(1), 0) YDZ_NUM, nvl(sum(amt), 0) YDZ_AMT "
					+ "from base_co_org t left join pay_card_deal_rec_" + DateUtil.formatDate(new Date(), "yyyyMM") + " t2 on t.co_org_id = t2.acpt_id "
					+ "where t2.deal_code in('30105010','30105011','30105020','30105021') and acc_kind <> '99' ";
			if (!Tools.processNull(coOrgId).equals("")) {
				sql += " and t.co_org_id='" + Tools.processNull(coOrgId) + "'";
			}
			if(!Tools.processNull(coOrgIdSql).equals("")){
				sql += " and t.co_org_id in (" + coOrgIdSql + ") ";
			}
			if (!Tools.processNull(startDate).equals("")) {
				sql += "and t2.deal_date >= to_date('" + startDate + "', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			if (!Tools.processNull(endDate).equals("")) {
				sql += "and t2.deal_date <= to_date('" + endDate + "', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			sql += " group by t.co_org_id,t.co_org_name,t2.card_type ";
			sql += "order by t.co_org_id ";
			Page pages = baseService.pagingQuery(sql, page, rows);
			if (pages.getAllRs() == null || pages.getAllRs().isEmpty()) {
				throw new CommonException("根据指定信息未查询到充值信息！");
			}
			jsonObject.put("rows", pages.getAllRs());
			jsonObject.put("total", pages.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String businessQuery(){
		try {
			initBaseDataGrid();
			if (Tools.processNull(queryType).equals("1") && Tools.processNull(brch_Id).equals("")) {// 查询网点营业报表
				throw new CommonException("请选择网点进行查询");
			} else if (Tools.processNull(queryType).equals("0") && Tools.processNull(brch_Id).equals("") && Tools.processNull(user_Id).equals("")) {// 查询柜员营业报表
				throw new CommonException("请选择网点，柜员进行查询");
			}
			//
			String checkIdSql = "";
			if (!Tools.processNull(checkIds).equals("")) {
				String[] brchIdArr = checkIds.split(",");
				for (String brchId : brchIdArr) {
					checkIdSql += "'" + brchId + "',";
				}
				checkIdSql = checkIdSql.substring(0, checkIdSql.length()-1);
			}
			//
			StringBuilder sqlBuffer = new StringBuilder();
			sqlBuffer.append("select t2.brch_id, min(t.clr_date) startDate, max(clr_date) endDate, t2.full_name brch_name, count(*) num, t1.name user_name, t1.user_id, ");
			sqlBuffer.append("nvl(sum(decode(t.stat_key, 'fwmmcz', abs(nvl(t.num, 0)))), 0) fwmmcz_num, "
					+ "nvl(sum(decode(t.stat_key, 'fwmmxg', abs(nvl(t.num, 0)))), 0) fwmmxg_num, "
					+ "nvl(sum(decode(t.stat_key, 'jymmcz', abs(nvl(t.num, 0)))), 0) jymmcz_num, "
					+ "nvl(sum(decode(t.stat_key, 'jymmxg', abs(nvl(t.num, 0)))), 0) jymmxg_num, "
					+ "nvl(sum(decode(t.stat_key, 'sbkmmcz', abs(nvl(t.num, 0)))), 0) sbmmcz_num, "
					+ "nvl(sum(decode(t.stat_key, 'sbkmmxg', abs(nvl(t.num, 0)))), 0) sbmmxg_num, "
					+ "nvl(sum(decode(t.stat_key, 'ygsyw', abs(nvl(t.num, 0)))), 0) ygsyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'gsyw', abs(nvl(t.num, 0)))), 0) gsyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'jgsyw', abs(nvl(t.num, 0)))), 0) jgsyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'bkyw', abs(nvl(t.num, 0)))), 0) bkyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'hkyw', abs(nvl(t.num, 0)))), 0) hkyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'zxyw', abs(nvl(t.num, 0)))), 0) zxyw_num, "
					+ "nvl(sum(decode(t.stat_key, 'card_issue', abs(nvl(t.num, 0)))), 0) card_issue_num, "
					+ "nvl(sum(decode(t.stat_key, 'tcqbg', abs(nvl(t.num, 0)))), 0) tcqbg_NUM, "
					+ "nvl(sum(decode(t.stat_key, 'hkzqb', abs(nvl(t.num, 0)))), 0) hkzqb_NUM, "
					+ "nvl(sum(decode(t.stat_key, 'grslyw', abs(nvl(t.num, 0)))), 0) gmgrsl_num, "
					+ "nvl(sum(decode(t.stat_key, 'yhkbdyw', abs(nvl(t.num, 0)))), 0) yhkbd_num, "
					+ "nvl(sum(decode(t.stat_key, 'yhkjbyw', abs(nvl(t.num, 0)))), 0) yhkjb_num, "
					+ "nvl(sum(decode(t.stat_key, 'kphs', abs(nvl(t.num, 0)))), 0) kphs_num "
					+ "from stat_day_bal_data t,sys_users t1,sys_branch t2  where t.user_id = t1.user_id(+) and t.brch_id = t2.brch_id(+) ");
			if (Tools.processNull(queryType).equals("1")){
				if(cascadeBrch){
					sqlBuffer.append("and t.user_id is null and t.brch_id in (select brch_id from sys_branch start with brch_id = '" 
							+ brch_Id + "' connect by  prior sysbranch_id = pid) ");
				} else {
					sqlBuffer.append("and t.user_id is null and t.brch_id is not null and t.brch_id ='" + brch_Id + "' ");
				}
			} else {
				if (!Tools.processNull(brch_Id).equals("")) {
					sqlBuffer.append("and t.brch_id = '" + brch_Id + "' ");
				}
				if (!Tools.processNull(user_Id).equals("")) {// 查询指定柜员
					sqlBuffer.append(" and t.user_id is not null and t.user_id ='" + user_Id + "' ");
				} else {// 查询所有柜员
					sqlBuffer.append(" and t.user_id is not null and t.user_id in (select h.user_id from sys_users h where h.brch_id ='" + brch_Id + "') ");
				}
			}
			if(!Tools.processNull(checkIdSql).equals("")){
				sqlBuffer.append("and t.brch_id||t.user_id in (" + checkIdSql + ") ");
			}
			if (!Tools.processNull(startDate).equals("")) {
				sqlBuffer.append("and t.clr_date >= '" + startDate + "' ");
			}
			if (!Tools.processNull(endDate).equals("")) {
				sqlBuffer.append("and t.clr_date <= '" + endDate + "' ");
			}
			sqlBuffer.append("group by t2.brch_id, t2.full_name, t1.user_id, t1.name ");
			if(!Tools.processNull(sort).equals("")){
				sqlBuffer.append("order by " + sort);
				
				if(!Tools.processNull(order).equals("")){
					sqlBuffer.append(" " + order);
				}
			} else {
				sqlBuffer.append( "order by t2.brch_id");
			}
			Page pageDate = baseService.pagingQuery(sqlBuffer.toString(), page, rows);
			if(pageDate == null || pageDate.getAllRs() == null || pageDate.getAllRs().isEmpty()){
				throw new CommonException("没有数据.");
			}
			jsonObject.put("total", pageDate.getTotalCount());
			jsonObject.put("rows", pageDate.getAllRs());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		
		return JSONOBJ;
	}
	
	public String exportBusinessStat(){
		try {
			businessQuery();
			String fileName = "";
			if(Tools.processNull(queryType).equals("1")){
				fileName = "网点柜面业务统计";
			} else {
				fileName = "柜员柜面业务统计";
			}
			if(!Tools.processNull(brch_Id).equals("")){
				String brchName = (String) baseService.findOnlyFieldBySql("select full_name from sys_branch where brch_id = '" + brch_Id + "'");
				fileName = brchName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 6000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 3000);
			sheet.setColumnWidth(4, 3000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 3000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 3000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 3000);
			sheet.setColumnWidth(11, 3000);
			sheet.setColumnWidth(12, 3000);
			sheet.setColumnWidth(13, 3000);
			sheet.setColumnWidth(14, 3000);
			sheet.setColumnWidth(15, 3000);
			sheet.setColumnWidth(16, 3000);
			sheet.setColumnWidth(17, 3000);
			sheet.setColumnWidth(18, 3000);
			sheet.setColumnWidth(19, 3000);
			sheet.setColumnWidth(20, 3000);
			sheet.setColumnWidth(21, 3000);

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
			int maxColumn = 21;
			if(Tools.processNull(queryType).equals("0")){
				maxColumn = 23;
			}
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			// second header
			String time = "导出时间：" + DateUtils.getNowTime();
			if (!Tools.processNull(startDate).equals("")) {
				time = "业务时间：" + startDate + " ~ " + endDate + "    " + time;
			}
			sheet.getRow(1).getCell(0).setCellValue(time);
			
			// third header
			sheet.getRow(2).getCell(0).setCellValue("网点编号");
			sheet.getRow(2).getCell(1).setCellValue("网点名称");
			if(Tools.processNull(queryType).equals("0")){
				sheet.getRow(2).getCell(2).setCellValue("柜员编号");
				sheet.getRow(2).getCell(3).setCellValue("柜员名称");
			}
			sheet.getRow(2).getCell(maxColumn - 19).setCellValue("服务密码重置");
			sheet.getRow(2).getCell(maxColumn - 18).setCellValue("服务密码修改");
			sheet.getRow(2).getCell(maxColumn - 17).setCellValue("交易密码重置");
			sheet.getRow(2).getCell(maxColumn - 16).setCellValue("交易密码修改");
			sheet.getRow(2).getCell(maxColumn - 15).setCellValue("社保密码重置");
			sheet.getRow(2).getCell(maxColumn - 14).setCellValue("社保密码修改");
			sheet.getRow(2).getCell(maxColumn - 13).setCellValue("零星申领");
			sheet.getRow(2).getCell(maxColumn - 12).setCellValue("卡发放");
			sheet.getRow(2).getCell(maxColumn - 11).setCellValue("临时挂失");
			sheet.getRow(2).getCell(maxColumn - 10).setCellValue("挂失");
			sheet.getRow(2).getCell(maxColumn - 9).setCellValue("解挂失");
			sheet.getRow(2).getCell(maxColumn - 8).setCellValue("补卡");
			sheet.getRow(2).getCell(maxColumn - 7).setCellValue("换卡");
			sheet.getRow(2).getCell(maxColumn - 6).setCellValue("注销");
			sheet.getRow(2).getCell(maxColumn - 5).setCellValue("换卡转钱包");
			sheet.getRow(2).getCell(maxColumn - 4).setCellValue("统筹区变更");
			sheet.getRow(2).getCell(maxColumn - 3).setCellValue("银行卡绑定");
			sheet.getRow(2).getCell(maxColumn - 2).setCellValue("银行卡解绑");
			sheet.getRow(2).getCell(maxColumn - 1).setCellValue("卡片回收");
			
			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			if(Tools.processNull(queryType).equals("1")){
				sheet.createFreezePane(2, 3);
			} else {
				sheet.createFreezePane(4, 3);
			}
			int numSum = 0;
			int fwmmcz = 0;
			int fwmmxg = 0;
			int jymmcz = 0;
			int jymmxg = 0;
			int sbmmcz = 0;
			int sbmmxg = 0;
			int apply = 0;
			int cardIssue = 0;
			int ygs = 0;
			int gs = 0;
			int jgs = 0;
			int bk = 0;
			int hk = 0;
			int zx = 0;
			int hkzqb = 0;
			int tcqbg = 0;
			int yhkbd = 0;
			int yhkjb = 0;
			int kphs = 0;
			for (int i = 0; i < data.size(); i++, numSum++) {
				JSONObject item = data.getJSONObject(i);
				
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(cellStyle);
				}
				
				row.getCell(0).setCellValue(item.getString("BRCH_ID"));
				row.getCell(1).setCellValue(item.getString("BRCH_NAME"));
				if(Tools.processNull(queryType).equals("0")){
					row.getCell(2).setCellValue(item.getString("USER_ID"));
					row.getCell(3).setCellValue(item.getString("USER_NAME"));
				}
				row.getCell(maxColumn - 19).setCellValue(item.getIntValue("FWMMCZ_NUM"));
				fwmmcz += item.getIntValue("FWMMCZ_NUM");
				row.getCell(maxColumn - 18).setCellValue(item.getIntValue("FWMMXG_NUM"));
				fwmmxg += item.getIntValue("FWMMXG_NUM");
				row.getCell(maxColumn - 17).setCellValue(item.getIntValue("JYMMCZ_NUM"));
				jymmcz += item.getIntValue("JYMMCZ_NUM");
				row.getCell(maxColumn - 16).setCellValue(item.getIntValue("JYMMXG_NUM"));
				jymmxg += item.getIntValue("JYMMXG_NUM");
				row.getCell(maxColumn - 15).setCellValue(item.getIntValue("SBMMCZ_NUM"));
				sbmmcz += item.getIntValue("SBMMCZ_NUM");
				row.getCell(maxColumn - 14).setCellValue(item.getIntValue("SBMMXG_NUM"));
				sbmmxg += item.getIntValue("SBMMXG_NUM");
				row.getCell(maxColumn - 13).setCellValue(item.getIntValue("GMGRSL_NUM"));
				apply += item.getIntValue("GMGRSL_NUM");
				row.getCell(maxColumn - 12).setCellValue(item.getIntValue("CARD_ISSUE_NUM"));
				cardIssue += item.getIntValue("CARD_ISSUE_NUM");
				row.getCell(maxColumn - 11).setCellValue(item.getIntValue("YGSYW_NUM"));
				ygs += item.getIntValue("YGSYW_NUM");
				row.getCell(maxColumn - 10).setCellValue(item.getIntValue("GSYW_NUM"));
				gs += item.getIntValue("GSYW_NUM");
				row.getCell(maxColumn - 9).setCellValue(item.getIntValue("JGSYW_NUM"));
				jgs += item.getIntValue("JGSYW_NUM");
				row.getCell(maxColumn - 8).setCellValue(item.getIntValue("BKYW_NUM"));
				bk += item.getIntValue("BKYW_NUM");
				row.getCell(maxColumn - 7).setCellValue(item.getIntValue("HKYW_NUM"));
				hk += item.getIntValue("HKYW_NUM");
				row.getCell(maxColumn - 6).setCellValue(item.getIntValue("ZXYW_NUM"));
				zx += item.getIntValue("ZXYW_NUM");
				row.getCell(maxColumn - 5).setCellValue(item.getIntValue("HKZQB_NUM"));
				hkzqb += item.getIntValue("HKZQB_NUM");
				row.getCell(maxColumn - 4).setCellValue(item.getIntValue("TCQBG_NUM"));
				tcqbg += item.getIntValue("TCQBG_NUM");
				row.getCell(maxColumn - 3).setCellValue(item.getIntValue("YHKBD_NUM"));
				yhkbd += item.getIntValue("YHKBD_NUM");
				row.getCell(maxColumn - 2).setCellValue(item.getIntValue("YHKJB_NUM"));
				yhkjb += item.getIntValue("YHKJB_NUM");
				row.getCell(maxColumn - 1).setCellValue(item.getIntValue("KPHS_NUM"));
				kphs += item.getIntValue("KPHS_NUM");
			}
			
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				cell.setCellStyle(cellStyle);
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(1).setCellValue("共 " + numSum + " 笔");
			row.getCell(maxColumn - 19).setCellValue(fwmmcz);
			row.getCell(maxColumn - 18).setCellValue(fwmmxg);
			row.getCell(maxColumn - 17).setCellValue(jymmcz);
			row.getCell(maxColumn - 16).setCellValue(jymmxg);
			row.getCell(maxColumn - 15).setCellValue(sbmmcz);
			row.getCell(maxColumn - 14).setCellValue(sbmmxg);
			row.getCell(maxColumn - 13).setCellValue(apply);
			row.getCell(maxColumn - 12).setCellValue(cardIssue);
			row.getCell(maxColumn - 11).setCellValue(ygs);
			row.getCell(maxColumn - 10).setCellValue(gs);
			row.getCell(maxColumn - 9).setCellValue(jgs);
			row.getCell(maxColumn - 8).setCellValue(bk);
			row.getCell(maxColumn - 7).setCellValue(hk);
			row.getCell(maxColumn - 6).setCellValue(zx);
			row.getCell(maxColumn - 5).setCellValue(hkzqb);
			row.getCell(maxColumn - 4).setCellValue(tcqbg);
			row.getCell(maxColumn - 3).setCellValue(yhkbd);
			row.getCell(maxColumn - 2).setCellValue(yhkjb);
			row.getCell(maxColumn - 1).setCellValue(kphs);
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
	
	/**
	 * 合作机构充值同比对比
	 * @return
	 */
	public String coCorgRechargeCompeare() {
		try {
			initBaseDataGrid();
			if(Tools.processNull(qyMonth).equals("")){
				throw new CommonException("起始月份不能为空.");
			} else if(Tools.processNull(qyMonthEnd).equals("")){
				throw new CommonException("结束月份不能为空.");
			}
			String coOrgIdSql = "";
			if (!Tools.processNull(checkIds).equals("")) {
				String[] coOrgIdArr = checkIds.split(",");
				for (String coOrgId : coOrgIdArr) {
					coOrgIdSql += "'" + coOrgId + "',";
				}
				coOrgIdSql = coOrgIdSql.substring(0, coOrgIdSql.length()-1);
			}
			
			// cur year period
			// start
			Date curYearStartMonth = DateUtil.parse("yyyy-MM", qyMonth);
			Calendar curYearStartMonthCal = Calendar.getInstance();
			curYearStartMonthCal.setTime(curYearStartMonth);
			curYearStartMonthCal.set(Calendar.DAY_OF_MONTH, 1);
			qyMonth = DateUtil.formatDate(curYearStartMonthCal.getTime(), "yyyy-MM-dd");
			// end
			Date curYearEndMonth = DateUtil.parse("yyyy-MM", qyMonthEnd);
			Calendar curYearEndMonthCal = Calendar.getInstance();
			curYearEndMonthCal.setTime(curYearEndMonth);
			curYearEndMonthCal.add(Calendar.MONTH, 1);
			curYearEndMonthCal.add(Calendar.DAY_OF_MONTH, -1);
			qyMonthEnd = DateUtil.formatDate(curYearEndMonthCal.getTime(), "yyyy-MM-dd");
			
			// last year period
			// start
			Calendar lastYearStartMonthCal = Calendar.getInstance();
			lastYearStartMonthCal.setTime(curYearStartMonth);
			lastYearStartMonthCal.add(Calendar.YEAR, -1);
			lastYearStartMonthCal.set(Calendar.DAY_OF_MONTH, 1);
			String lastYearStartMonth = DateUtil.formatDate(lastYearStartMonthCal.getTime(), "yyyy-MM-dd");
			// end
			Calendar lastYearEndMonthCal = Calendar.getInstance();
			lastYearEndMonthCal.setTime(curYearEndMonth);
			lastYearEndMonthCal.add(Calendar.YEAR, -1);
			lastYearEndMonthCal.add(Calendar.MONTH, 1);
			lastYearEndMonthCal.add(Calendar.DAY_OF_MONTH, -1);
			String lastYearEndMonth = DateUtil.formatDate(lastYearEndMonthCal.getTime(), "yyyy-MM-dd");
			
			// query
			String sql = "select t.co_org_id, t.co_org_name, "
					+ "(select sum(decode(t2.deal_code, '30105010', t2.amt, '30105011', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date >= '" + qyMonth + "' and t2.clr_date <= '" + qyMonthEnd + "' and t2.acpt_id = t.co_org_id) cur_period_lj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30105020', t2.amt, '30105021', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date >= '" + qyMonth + "' and t2.clr_date <= '" + qyMonthEnd + "' and t2.acpt_id = t.co_org_id) cur_period_tj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30105010', t2.amt, '30105011', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date >= '" + lastYearStartMonth + "' and t2.clr_date <= '" + lastYearEndMonth + "' and t2.acpt_id = t.co_org_id) last_period_lj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30105020', t2.amt, '30105021', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date >= '" + lastYearStartMonth + "' and t2.clr_date <= '" + lastYearEndMonth + "' and t2.acpt_id = t.co_org_id) last_period_tj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30105010', t2.amt, '30105011', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date <= '" + qyMonthEnd + "' and t2.acpt_id = t.co_org_id) cur_year_lj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30105020', t2.amt, '30105021', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date <= '" + qyMonthEnd + "' and t2.acpt_id = t.co_org_id) cur_year_tj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30105010', t2.amt, '30105011', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date <= '" + lastYearEndMonth + "' and t2.acpt_id = t.co_org_id) last_year_lj_recharge, "
					+ "(select sum(decode(t2.deal_code, '30105020', t2.amt, '30105021', t2.amt, 0)) from stat_card_pay t2 where t2.clr_date <= '" + lastYearEndMonth + "' and t2.acpt_id = t.co_org_id) last_year_tj_recharge "
					+ "from base_co_org t where 1 = 1 ";
			if(!Tools.processNull(coOrgId).equals("")){
				sql += "and t.co_org_id = '" + coOrgId + "' ";
			}
			if(!Tools.processNull(coOrgIdSql).equals("")){
				sql += "and t.co_org_id in (" + coOrgIdSql + ") ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			} else {
				sql += "order by co_org_id";
			}
			Page data = baseService.pagingQuery(sql, page, rows);
			if(data == null || data.getAllRs() == null || data.getAllRs().isEmpty()){
				throw new CommonException("没有数据.");
			}
			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportCoOrgRechargeCompeareReport(){
		try {
			coCorgRechargeCompeare();
			String fileName = "充值情况同比对比_" + qyMonth + " ~ " + qyMonthEnd;
			if(!Tools.processNull(coOrgId).equals("")){
				String coOrgName = (String) baseService.findOnlyFieldBySql("select co_org_name from base_co_org where co_org_id = '" + coOrgId + "'");
				fileName = coOrgName + "_" + fileName;
			}
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			com.alibaba.fastjson.JSONArray data = (com.alibaba.fastjson.JSONArray) jsonObject.get("rows");
			
			// workbook 
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);
			
			sheet.setColumnWidth(0, 6000);
			sheet.setColumnWidth(1, 3000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 3000);
			sheet.setColumnWidth(4, 3000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 3000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 3000);
			sheet.setColumnWidth(9, 3000);
			sheet.setColumnWidth(10, 3000);

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

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);
			
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));

			// head row 1
			int maxColumn = 11;
			int headRows = 4;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for(int j = 0; j<maxColumn; j++){
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			
			sheet.getRow(0).getCell(0).setCellValue(fileName);
			
			// second header
			String time = "导出时间：" + DateUtils.getNowTime();
			if (!Tools.processNull(startDate).equals("")) {
				time = "业务时间：" + startDate + " ~ " + endDate + "    " + time;
			}
			sheet.getRow(1).getCell(0).setCellValue(time);
			
			// third header
			sheet.getRow(2).getCell(0).setCellValue("合作机构名称");
			sheet.getRow(2).getCell(1).setCellValue("本期充值金额");
			sheet.getRow(2).getCell(4).setCellValue("去年同期充值金额");
			sheet.getRow(2).getCell(6).setCellValue("本年累计充值金额");
			sheet.getRow(2).getCell(9).setCellValue("去年同期累计充值金额");
			// third header
			sheet.getRow(3).getCell(1).setCellValue("市民卡钱包");
			sheet.getRow(3).getCell(2).setCellValue("市民卡账户");
			sheet.getRow(3).getCell(3).setCellValue("合计");
			sheet.getRow(3).getCell(4).setCellValue("充值金额");
			sheet.getRow(3).getCell(5).setCellValue("同比");
			sheet.getRow(3).getCell(6).setCellValue("市民卡钱包");
			sheet.getRow(3).getCell(7).setCellValue("市民卡账户");
			sheet.getRow(3).getCell(8).setCellValue("合计");
			sheet.getRow(3).getCell(9).setCellValue("充值金额");
			sheet.getRow(3).getCell(10).setCellValue("同比");
			
			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(2, 3, 0, 0));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 1, 3));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 4, 5));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 6, 8));
			sheet.addMergedRegion(new CellRangeAddress(2, 2, 9, 10));
			sheet.createFreezePane(1, 4);
			
			double curPeriodTjRechargeSum = 0;
			double curPeriodLjRechargeSum = 0;
			double lastPeriodTjRechargeSum = 0;
			double lastPeriodLjRechargeSum = 0;
			double curYearTjRechargeSum = 0;
			double curYearLjRechargeSum = 0;
			double lastYearTjRechargeSum = 0;
			double lastYearLjRechargeSum = 0;
			for (int i = 0; i < data.size(); i++) {
				JSONObject item = data.getJSONObject(i);
				
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if(j==0||j==5||j==10){
						cell.setCellStyle(cellStyle);
					}else{
						cell.setCellStyle(moneyCellStyle);
					}
				}
				
				double curPeriodTjRecharge = Tools.processNull(item.getString("CUR_PERIOD_TJ_RECHARGE")).equals("")?0:item.getDoubleValue("CUR_PERIOD_TJ_RECHARGE");
				double curPeriodLjRecharge = Tools.processNull(item.getString("CUR_PERIOD_LJ_RECHARGE")).equals("")?0:item.getDoubleValue("CUR_PERIOD_LJ_RECHARGE");
				double lastPeriodTjRecharge = Tools.processNull(item.getString("LAST_PERIOD_TJ_RECHARGE")).equals("")?0:item.getDoubleValue("LAST_PERIOD_TJ_RECHARGE");
				double lastPeriodLjRecharge = Tools.processNull(item.getString("LAST_PERIOD_LJ_RECHARGE")).equals("")?0:item.getDoubleValue("LAST_PERIOD_LJ_RECHARGE");
				double curYearTjRecharge = Tools.processNull(item.getString("CUR_YEAR_TJ_RECHARGE")).equals("")?0:item.getDoubleValue("CUR_YEAR_TJ_RECHARGE");
				double curYearLjRecharge = Tools.processNull(item.getString("CUR_YEAR_LJ_RECHARGE")).equals("")?0:item.getDoubleValue("CUR_YEAR_LJ_RECHARGE");
				double lastYearTjRecharge = Tools.processNull(item.getString("LAST_YEAR_TJ_RECHARGE")).equals("")?0:item.getDoubleValue("LAST_YEAR_TJ_RECHARGE");
				double lastYearLjRecharge = Tools.processNull(item.getString("LAST_YEAR_LJ_RECHARGE")).equals("")?0:item.getDoubleValue("LAST_YEAR_LJ_RECHARGE");
				//
				curPeriodTjRechargeSum += curPeriodTjRecharge;
				curPeriodLjRechargeSum += curPeriodLjRecharge;
				lastPeriodTjRechargeSum += lastPeriodTjRecharge;
				lastPeriodLjRechargeSum += lastPeriodLjRecharge;
				curYearTjRechargeSum += curYearTjRecharge;
				curYearLjRechargeSum += curYearLjRecharge;
				lastYearTjRechargeSum += lastYearTjRecharge;
				lastYearLjRechargeSum += lastYearLjRecharge;
				//
				row.getCell(0).setCellValue(item.getString("CO_ORG_NAME"));
				row.getCell(1).setCellValue(curPeriodTjRecharge / 100);
				row.getCell(2).setCellValue(curPeriodLjRecharge / 100);
				row.getCell(3).setCellValue((curPeriodTjRecharge + curPeriodLjRecharge)/100);
				row.getCell(4).setCellValue((lastPeriodTjRecharge + lastPeriodLjRecharge) / 100);
				if (lastPeriodTjRecharge + lastPeriodLjRecharge == 0) {
					row.getCell(5).setCellValue("");
				} else {
					row.getCell(5).setCellValue((curPeriodTjRecharge + curPeriodLjRecharge - lastPeriodTjRecharge - lastPeriodLjRecharge) / (lastPeriodTjRecharge + lastPeriodLjRecharge) + "%");
				}
				row.getCell(6).setCellValue(curYearTjRecharge / 100);
				row.getCell(7).setCellValue(curYearLjRecharge / 100);
				row.getCell(8).setCellValue((curYearTjRecharge + curYearLjRecharge) / 100);
				row.getCell(9).setCellValue((lastYearTjRecharge + lastYearLjRecharge) / 100);
				if (lastYearTjRecharge + lastYearLjRecharge == 0) {
					row.getCell(10).setCellValue("");
				} else {
					row.getCell(10).setCellValue((curYearTjRecharge + curYearLjRecharge - lastYearTjRecharge - lastYearLjRecharge) / (lastYearTjRecharge + lastYearLjRecharge) + "%");
				}
			}
			
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if(j==0||j==5||j==10){
					cell.setCellStyle(cellStyle);
				}else{
					cell.setCellStyle(moneyCellStyle);
				}
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(1).setCellValue(curPeriodTjRechargeSum / 100);
			row.getCell(2).setCellValue(curPeriodLjRechargeSum / 100);
			row.getCell(3).setCellValue((curPeriodTjRechargeSum + curPeriodLjRechargeSum) / 100);
			row.getCell(4).setCellValue((lastPeriodTjRechargeSum + lastPeriodLjRechargeSum) / 100);
			if (lastPeriodTjRechargeSum + lastPeriodLjRechargeSum == 0) {
				row.getCell(5).setCellValue("");
			} else {
				row.getCell(5).setCellValue((curPeriodTjRechargeSum + curPeriodLjRechargeSum - lastPeriodTjRechargeSum - lastPeriodLjRechargeSum) / (lastPeriodTjRechargeSum + lastPeriodLjRechargeSum) + "%");
			}
			row.getCell(6).setCellValue(curYearTjRechargeSum / 100);
			row.getCell(7).setCellValue(curYearLjRechargeSum / 100);
			row.getCell(8).setCellValue((curYearTjRechargeSum + curYearLjRechargeSum) / 100);
			row.getCell(9).setCellValue((lastYearTjRechargeSum + lastYearLjRechargeSum) / 100);
			if (lastYearTjRechargeSum + lastYearLjRechargeSum == 0) {
				row.getCell(10).setCellValue("");
			} else {
				row.getCell(10).setCellValue((curYearTjRechargeSum + curYearLjRechargeSum - lastYearTjRechargeSum - lastYearLjRechargeSum) / (lastYearTjRechargeSum + lastYearLjRechargeSum) + "%");
			}
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String cardServiceIncome(){
		try{
			initGrid();
			String dealNoSql = "";
			if(!Tools.processNull(checkIds).equals("")){
				String[] dealNoArr = checkIds.split(",");
				if (dealNoArr != null && dealNoArr.length > 0) {
					for (String dealNo : dealNoArr) {
						dealNoSql += "'" + dealNo + "',";
					}
					dealNoSql = dealNoSql.substring(0, dealNoSql.length() - 1);
				}
			}
			
			StringBuffer sb = new StringBuffer();
			sb.append("select t.deal_no deal_no1,t.deal_no,r.deal_code_name,t.customer_id,(select name from base_personal where customer_id = t.customer_id) customer_name,(select h.code_name from Sys_code h where h.code_type = 'CERT_TYPE' and h.code_value = t.cert_type) cert_type,t.cert_no,");
			sb.append("(select h.code_name from sys_code h where h.code_type = 'CARD_TYPE' and h.code_value = t.card_type) card_type,t.card_no,to_char(t.biz_time,'yyyy-mm-dd hh24:mi:ss') biz_time,");
			sb.append("nvl(c.full_name, t.brch_id) full_name,nvl(b.name, t.user_id) name,t.clr_date,decode(t.deal_state,'0','正常','1','撤销','9','灰记录','2','冲正','其他') deal_state,t.note,t.old_card_no,t.old_deal_no, nvl(t.prv_bal, 0) prv_bal, nvl(t.cost_fee, 0) cost_fee, ");
			sb.append("nvl(t.amt, 0) amt,t.card_tr_count,t.grt_user_id,t.grt_user_name,t.agt_cert_no,t.agt_name,t.agt_tel_no,decode(t.acpt_type,'0','商户','1','柜面','2','合作机构','3','自助','4','电话','5','网站','6','商场','柜面') acpttype,t.co_org_id,t.term_id,t.end_deal_no,");
			sb.append("(select f.co_org_name from base_co_org f where f.co_org_id = t.co_org_id) co_org_name,(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = t.agt_cert_type ) agt_cert_type,(select code_name from sys_code where code_type = 'ACC_KIND' and code_value = t.acc_kind ) acckind ");
			sb.append("from tr_serv_rec t,sys_users b,sys_branch c,sys_code_tr r ");
			sb.append("where t.brch_id = c.brch_id(+) and t.user_id = b.user_id(+) and t.deal_code = r.deal_code(+) ");
			sb.append("AND T.DEAL_CODE IN ('" + DealCode.NAMEDCARD_REISSUE + "','" + DealCode.NAMEDCARD_CHG + "','" + DealCode.NAMEDCARD_REISSUE_UNDO + "','" + DealCode.NAMEDCARD_CHG_UNDO + "') ");
			if (!Tools.processNull(rec.getCardType()).equals("")) {
				sb.append("and t.card_type = '" + rec.getCardType() + "' ");
			}
			if (!Tools.processNull(startDate).equals("")) {
				sb.append("and t.biz_time >= to_date('" + startDate + "', 'yyyy-mm-dd') ");
			}
			if (!Tools.processNull(endDate).equals("")) {
				sb.append("and t.biz_time <= to_date('" + endDate + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ");
			}
			if(!Tools.processNull(rec.getBrchId()).equals("")){
				if(cascadeBrch){
					sb.append("AND T.BRCH_ID in (select brch_id from sys_branch start with brch_id = '" + rec.getBrchId() + "' connect by prior sysbranch_id = pid) ");
				} else {
					sb.append("AND T.BRCH_ID = '" + rec.getBrchId() + "' ");
				}
			}
			if(!Tools.processNull(region_Id).equals("")){
				sb.append("AND b.region_id = '" + region_Id + "' ");
			}
			if (!Tools.processNull(dealNoSql).equals("")) {
				sb.append("and t.deal_no in (" + dealNoSql + ") ");
			}
			if (!Tools.processNull(sort).equals("")) {
				sb.append("order by " + sort + " ");
				if (!Tools.processNull(order).equals("")) {
					sb.append(order);
				}
			} else {
				sb.append(" order by t.deal_no desc");
			}
			Page pages = baseService.pagingQuery(sb.toString(), page, rows);
			if (pages.getAllRs() == null || pages.getAllRs().isEmpty()) {
				throw new CommonException("未找到符合条件的数据！");
			}
			jsonObject.put("rows", pages.getAllRs());
			jsonObject.put("total", pages.getTotalCount());
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String setExportParams(){
		try {
			request.getSession().setAttribute("exportParams", id);
			jsonObject.put("status", 0);
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String getQueryType(){
		return queryType;
	}
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	public String getBrch_Id() {
		return brch_Id;
	}
	public void setBrch_Id(String brch_Id) {
		this.brch_Id = brch_Id;
	}
	public String getOrg_Id() {
		return org_Id;
	}
	public void setOrg_Id(String org_Id) {
		this.org_Id = org_Id;
	}
	public String getRec_Type() {
		return rec_Type;
	}
	public void setRec_Type(String rec_Type) {
		this.rec_Type = rec_Type;
	}
	public String getDeal_Code() {
		return deal_Code;
	}
	public void setDeal_Code(String deal_Code) {
		this.deal_Code = deal_Code;
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
	public String getUser_Id() {
		return user_Id;
	}
	public void setUser_Id(String user_Id) {
		this.user_Id = user_Id;
	}
	public String getCoOrgId() {
		return coOrgId;
	}
	public void setCoOrgId(String coOrgId) {
		this.coOrgId = coOrgId;
	}
	public String getCardType() {
		return cardType;
	}
	public void setCardType(String cardType) {
		this.cardType = cardType;
	}
	public String getAccKind() {
		return accKind;
	}
	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}
	public String getMerchantId() {
		return merchantId;
	}
	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}
	
	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getMerchantName() {
		return merchantName;
	}
	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getExpid() {
		return expid;
	}

	public void setExpid(String expid) {
		this.expid = expid;
	}

	/**
	 * @return the rec
	 */
	public TrServRec getRec() {
		return rec;
	}
	/**
	 * @param rec the rec to set
	 */
	public void setRec(TrServRec rec) {
		this.rec = rec;
	}
	/**
	 * @return the defaultErrMsg
	 */
	public String getDefaultErrMsg() {
		return defaultErrMsg;
	}
	/**
	 * @param defaultErrMsg the defaultErrMsg to set
	 */
	public void setDefaultErrMsg(String defaultErrMsg) {
		this.defaultErrMsg = defaultErrMsg;
	}
	/**
	 * @return the exportFlag
	 */
	public String getExportFlag() {
		return exportFlag;
	}
	/**
	 * @param exportFlag the exportFlag to set
	 */
	public void setExportFlag(String exportFlag) {
		this.exportFlag = exportFlag;
	}

	/**
	 * @return the qyMonth
	 */
	public String getQyMonth() {
		return qyMonth;
	}

	/**
	 * @param qyMonth the qyMonth to set
	 */
	public void setQyMonth(String qyMonth) {
		this.qyMonth = qyMonth;
	}

	public String getQyMonthEnd() {
		return qyMonthEnd;
	}

	public void setQyMonthEnd(String qyMonthEnd) {
		this.qyMonthEnd = qyMonthEnd;
	}

	public String getRegion_Id() {
		return region_Id;
	}

	public void setRegion_Id(String region_Id) {
		this.region_Id = region_Id;
	}

	public String getMerchantIds() {
		return merchantIds;
	}

	public void setMerchantIds(String merchantIds) {
		this.merchantIds = merchantIds;
	}

	public String getCoOrgIds() {
		return coOrgIds;
	}

	public void setCoOrgIds(String coOrgIds) {
		this.coOrgIds = coOrgIds;
	}

	public String getCheckIds() {
		return checkIds;
	}

	public void setCheckIds(String checkIds) {
		this.checkIds = checkIds;
	}

	public boolean isCascadeBrch() {
		return cascadeBrch;
	}

	public void setCascadeBrch(boolean cascadeBrch) {
		this.cascadeBrch = cascadeBrch;
	}

	public boolean isStatByDay() {
		return statByDay;
	}

	public void setStatByDay(boolean statByDay) {
		this.statByDay = statByDay;
	}

	public String getAcptType() {
		return acptType;
	}

	public void setAcptType(String acptType) {
		this.acptType = acptType;
	}

	
}
