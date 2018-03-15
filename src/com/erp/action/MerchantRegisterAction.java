package com.erp.action;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
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
import org.directwebremoting.json.types.JsonArray;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseEndOut;
import com.erp.model.BaseMerchant;
import com.erp.model.BaseMerchantMode;
import com.erp.model.BaseTagEnd;
import com.erp.model.PayAcctypeSqn;
import com.erp.model.PayMerchantLim;
import com.erp.model.StlMode;
import com.erp.model.StlModeId;
import com.erp.model.SysActionLog;
import com.erp.service.MerchantMangerService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.ExcelUtil;
import com.erp.util.Tools;
import com.erp.viewModel.GridModel;
import com.erp.viewModel.Json;
import com.erp.viewModel.MerConsumeAccKindView;
import com.erp.viewModel.MerchantView;
import com.erp.viewModel.Page;


@Namespace("/merchantRegister")
@Action(value = "merchantRegisterAction")
@Results({@Result(type="json",name="json"),@Result(name="viewMerchant",location="/jsp/merchant/merchantBaseInfo.jsp"),
			@Result(name="toEidtMerchant",location="/jsp/merchant/merchantRegistEidtDlg.jsp"),
			@Result(name="toEidtMerchantLmt",location="/jsp/merchant/merchantQuotaAddDlg.jsp"),
			@Result(name="toAddMerchantLmt",location="/jsp/merchant/merchantQuotaAddDlg.jsp"),
			@Result(name="toEidtMerSettleMode",location="/jsp/merchant/merSettleModeDlg.jsp"),
			@Result(name="toAddMerTerm",location="/jsp/merchant/merTermAddDlg.jsp"),
			@Result(name="toEditTerm",location="/jsp/merchant/merTermAddDlg.jsp"),
			@Result(name="toTermRepairs",location="/jsp/merchant/merTermRepairs.jsp"),
			@Result(name="toRecycle",location="/jsp/merchant/merRecycle.jsp"),
			@Result(name="toOutbound",location="/jsp/merchant/merTermOutbound.jsp"),
			@Result(name="toEditConsumeModeView",location="/jsp/merchant/merConsumeModeView.jsp"),
			@Result(name="toEditMerGetCosMode",location="/jsp/merchant/merGetCosModeEditDlg.jsp")})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class MerchantRegisterAction extends BaseAction {
	
	private String sort="";
	private String order="";
	private MerchantMangerService merchantMangerService;
	public Logger log = Logger.getLogger(MerchantRegisterAction.class);
	private String merchantId="";
	private String merchantState="";
	private String queryType = "1";//查询类型 1 不进行查询,直接返回;0 进行查询,返回查询结果。
	private BaseMerchant merchant=new BaseMerchant();
	private StlMode merchantStlMode=new StlMode();
	private BaseTagEnd  tagEnd=new BaseTagEnd();
	private BaseEndOut  endOut=new BaseEndOut();
	private PayMerchantLim  merLmt = new PayMerchantLim();
	private String validDate="";
	private String typeDeal="0";
	private String acckinds="";
	private String acc_kindQB="";
	private String acc_kindLJ="";
	private String acc_kindZY="";
	private String endId="";
	private String endState="";
	private String modeName="";
	private String modeState="";
	private String modeId="";
	private PayAcctypeSqn paySqn;
	private String consumeMode="";
	private String merchantType = "";
	private String merchantName = "";
	private String accName = "";
	private String type = "";
	private File file;
	private String endName;
	private String merchantIds;
	private String template;
	private String expid;
	
	@Autowired
	public void setMerchantMangerService(MerchantMangerService merchantMangerService) {
		this.merchantMangerService = merchantMangerService;
	}
	
	
	public String findALLMerchant(){
		try {
			String hql = "from BaseMerchant where merchantState='0' and 1=1 ";
			List list = merchantMangerService.findByHql(hql);
			OutputJson(list);
		} catch (Exception e) {
			
		}
		return null;
	}
	
	public String getBizName(){
		Json json = new Json();
		try {
			String hql = "from BaseMerchant where merchantState='0' and 1=1 ";
			String objStr  = ServletActionContext.getRequest().getParameter("objStr");
			if(!Tools.processNull(objStr).equals("")){
				hql+=" and merchantName like '%"+objStr+"%'";
			}			List<BaseMerchant> merlists = (List<BaseMerchant>)merchantMangerService.findByHql(hql);
			OutputJson(merlists);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		return null;
	}
	
	public String getTermName(){
		Json json = new Json();
		try {
			String hql = "from BaseTagEnd where endState='1' and 1=1 ";
			String objStr  = ServletActionContext.getRequest().getParameter("objStrTrem");
			if(!Tools.processNull(objStr).equals("")){
				hql+=" and endName like '%"+objStr+"%'";
			}			List<BaseMerchant> merlists = (List<BaseMerchant>)merchantMangerService.findByHql(hql);
			OutputJson(merlists);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		return null;
	}
	
	public String merchantInfoQuery(){
		try{
			initGrid();

			String head = "select t1.CUSTOMER_ID \"customerId\", t1.merchant_Id \"merchantId\", t1.merchant_Name \"merchantName\", "
					+ "t2.type_Name \"typeName\", nvl(t2.id, '0') \"id\" ,nvl(t1.contact,'') \"contact\",t1.CON_PHONE \"conPhone\", "
					+ "t1.CON_CERT_NO \"conCertNo\", t1.merchant_state \"merchantState\", t1.note \"note\", "
					+ "to_char(t1.sign_date, 'yyyy-mm-dd hh24:mi:ss') \"signDate\", t1.sign_user_id \"signUserId\", t1.stl_type, "
					+ "(select org_name from sys_organ where org_id = t1.org_id) org_name, t1.BIZ_REG_NO, "
					+ "(select code_name from sys_code where code_type = 'INDUS_CODE' and code_value = t1.INDUS_CODE) indus_name,"
					+ "(select bank_name from base_bank where bank_id=t1.bank_id) bank_name, t1.bank_acc_name, t1.bank_acc_no, "
					+ "t1.bank_brch, t1.address ";
			String hql = " from Base_Merchant t1,Base_Merchant_Type t2 where t1.merchant_type=t2.id(+) ";
			if(!Tools.processNull(this.merchantId).equals("")){
				hql += " and t1.merchant_id = '" + this.merchantId + "'";
			}
			if(!Tools.processNull(this.merchantState).equals("")){
				hql += " and t1.merchant_State = '" + this.merchantState + "'";
			}
			if(!Tools.processNull(merchantType).equals("")){
				hql += " and t1.merchant_Type = '" + merchantType + "'";
			}
			if(!Tools.processNull(merchantName).equals("")){
				hql += " and t1.merchant_name like '%" + merchantName + "%'";
			}
			if(!Tools.processNull(sort).equals("")){
				hql += " order by \"" + sort + "\"";
				
				if(!Tools.processNull(order).equals("")){
					hql += " " + order;
				}
			} else {
				hql += " order by t1.customer_id desc";
			}
			
			Page pageData = merchantMangerService.pagingQuery(head+hql,page, rows);
			
			if(pageData == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()){
				throw new CommonException("没有数据.");
			}
			
			jsonObject.put("total", pageData.getTotalCount());
			jsonObject.put("rows", pageData.getAllRs());
		}catch(Exception e){
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());

		}
		return JSONOBJ;
	}
	
	private void initGrid() {
		jsonObject.put("status", 0);
		jsonObject.put("total", 0);
		jsonObject.put("rows", new JsonArray());
	}


	public String viewMerchant(){
		try {
			merchant =(BaseMerchant)merchantMangerService.findOnlyRowByHql("from BaseMerchant t where t.merchantId = '"+merchantId+"'");
			merchantStlMode = (StlMode)merchantMangerService.findOnlyRowByHql("from StlMode  where id.merchantId = '"+merchantId+"'");
		} catch (CommonException e) {
			e.printStackTrace();
		}
		return "viewMerchant";
	} 
	
	public String toEidtMerchant(){
		try {
			merchant =(BaseMerchant)merchantMangerService.findOnlyRowByHql("from BaseMerchant t where t.merchantId = '"+merchantId+"'");
		} catch (CommonException e) {
			e.printStackTrace();
		}
		return "toEidtMerchant";
	}
	
	public String toEidtMerSettleMode(){
		try {
			merchantStlMode = (StlMode)merchantMangerService.findOnlyRowByHql("from StlMode  where id.merchantId = '"+merchantId+"' and to_char(id.validDate,'yyyy-mm-dd hh24:mi:ss')='"+validDate+"'");
		} catch (CommonException e) {
			e.printStackTrace();
		}
		return "toEidtMerSettleMode";
		
	}
	
	public String saveRegistMer(){
		Json json = new Json();
		String messages="";
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(merchantMangerService.getSysBranchByUserId().getBrchId());
			BaseMerchant mer_old = (BaseMerchant)merchantMangerService.findOnlyRowByHql("from BaseMerchant t where t.merchantId = '"+merchant.getMerchantId()+"'");
			if(mer_old==null){
				mer_old = new BaseMerchant();
			}
			if (Tools.processNull(merchant.getCustomerId()).equals("")) {//新增保存
				// 将 七天结 转换为月结
				if("05".equals(merchantStlMode.getStlWay())){
					merchantStlMode.setStlWay("04");
				}
				
				StlModeId id = new StlModeId();
				id.setValidDate(DateUtil.formatDate(validDate));
				merchantStlMode.setId(id);
				merchant.setMerchantState("2");
				
				/*if(!merchantStlMode.getId().getValidDate().after(DateUtil.formatDate(merchantMangerService.getClrDate()))){
					throw new CommonException("生效日期必须在当前日期之后");
				}*/
				
				if(!merchantMangerService.checkBiz_Name(merchant.getMerchantName().trim())){//不存在同名的商户则进行新增
					actionLog.setMessage("添加商户");
					actionLog.setDealCode(DealCode.MERCHANT_ADD);
					String returnMsg = merchantMangerService.saveMer(merchant,actionLog,merchantMangerService.getUser(),mer_old,merchantStlMode);
					merchant = new BaseMerchant();
					merchantStlMode = new StlMode();
					messages = "新增商户信息成功";
				}else{
					merchantStlMode = new StlMode();
					messages="已存在相同的商户名称或商户编号，请再次输入";
				}
				
			} else {//编辑保存
				BaseMerchant chant=(BaseMerchant)merchantMangerService.findOnlyRowByHql(" from BaseMerchant chant where" +" chant.customerId='"+merchant.getCustomerId()+"'");
				List list = merchantMangerService.findByHql("from BaseMerchant t where t.customerId<> '"+merchant.getCustomerId()+"' and t.merchantName ='"+merchant.getMerchantName()+"'");
				//在修改商户的时候，进行商户名称检测，是否存在相同的
				if(list!=null&&list.size()>0){
					messages="已存在相同的商户名称，请再次输入";
				}else{
					merchant.setServPwd(Tools.processNull(chant.getServPwd()));
					merchant.setMerchantState("2");
					actionLog.setMessage("编辑商户");
					actionLog.setDealCode(DealCode.MERCHANT_EDIT);
					merchantMangerService.saveMer(merchant,actionLog,merchantMangerService.getUser(),mer_old,merchantStlMode);
					messages ="编辑成功，你可以继续编辑该商户信息！";
				}
			}
			
			json.setStatus(true);
			json.setTitle("商户注册");
			json.setMessage(messages);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setTitle("商户注册");
			json.setMessage(e.getMessage());
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	/**
	 * 查询商户信息
	 * @return
	 */
	public String merchantLmtInfoQuery(){
		GridModel model = new GridModel();
		try{
			//1.组装查询语句
			String hql = " from PayMerchantLim t where 1=1  ";
			if(!Tools.processNull(this.merchantId).equals("")){
				hql += " and t.merchantId = '" + this.merchantId + "'";
			}
			if(!Tools.processNull(this.merchantName).equals("")){
				hql += " and t.merchantName = '" + this.merchantName + "'";
			}
			//2.查询结果
			List<?> o = new ArrayList();
			if(Tools.processNull(queryType).equals("0")){
				o = merchantMangerService.findByHql(hql);
			}
			model.setRows(o);
			model.setTotal(Long.valueOf(o.size()+""));
			OutputJson(model);
		}catch(Exception e){
			model.setStatus(1);
			model.setErrMsg(e.getMessage());
			OutputJson(model);

		}
		return null;
	}
	
	public String toAddMerchantLmt(){
		try {
			typeDeal="0";
		} catch (CommonException e) {
			e.printStackTrace();
		}
		return "toAddMerchantLmt";
	}
	
	
	public String toEidtMerchantLmt(){
		try {
			typeDeal="1";
			merLmt =(PayMerchantLim)merchantMangerService.findOnlyRowByHql("from PayMerchantLim t where t.merchantId = '"+merchantId+"'");
		} catch (CommonException e) {
			e.printStackTrace();
		}
		return "toEidtMerchantLmt";
	}
	
	public String saveMerLmt(){
		Json json = new Json();
		String messages="";
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(merchantMangerService.getSysBranchByUserId().getBrchId());
			if(typeDeal.equals("0")||Tools.processNull(typeDeal).equals("")){
				actionLog.setMessage("新增商户消费参数");
				BigDecimal bgcount = (BigDecimal) merchantMangerService.findOnlyFieldBySql("select nvl(count(1),0) from pay_merchant_lim a where a.merchant_id = '"+merLmt.getMerchantId()+"'");
				if(bgcount.intValue()>0){
					throw new CommonException("存在相同的商户消费限制参数，若要修改请选择编辑进行相关操作！");
				}
			}else{
				actionLog.setMessage("编辑商户消费参数");
			}
			merchantMangerService.saveMerchantQuota(merLmt,actionLog,merchantMangerService.getUser());
			typeDeal="0";
			messages = "商户限额配置成功";
			json.setStatus(true);
			json.setTitle("商户消费参数设置");
			json.setMessage(messages);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setTitle("商户消费参数设置");
			json.setMessage(e.getMessage());
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	
	
	/**
	 * 商户关联查询 
	 * @return
	 */
	public String toQueryMerComsumeKind()
	  {
	    GridModel model = new GridModel();
	    try
	    {
	      String sql = " SELECT t1.merchant_id merchant_id,  (SELECT merchant_name FROM base_merchant WHERE merchant_id= t1.merchant_id ) merchant_name  from pay_merchant_acctype t1  WHERE 1=1 ";

	      if (!Tools.processNull(this.merchantId).equals("")) {
	        sql = sql + " and t1.merchant_id = '" + this.merchantId + "'";
	      }
	      sql = sql + "group by t1.merchant_id";

	      List o = new ArrayList();
	      if (Tools.processNull(this.queryType).equals("0")) {
	        o = this.merchantMangerService.findBySql(sql);
	      }
	      List result = new ArrayList();

	      if ((o != null) && (o.size() > 0)) {
	        Iterator it = o.iterator();
	        while (it.hasNext()) {
	          Object[] onerow = (Object[])it.next();
	          MerConsumeAccKindView vo = new MerConsumeAccKindView();
	          vo.setMerchantId(onerow[0]+"");
	          vo.setMerchantName(onerow[1]+"");
	          List acc = this.merchantMangerService.findBySql("select (select acc_name from acc_kind_config where acc_kind =t2.acc_kind) acc_name   from pay_merchant_acctype t2 where t2.merchant_id='" + 
	            onerow[0] + "'");
	          String acckids = "";
	          for (int i = 0; i < acc.size(); i++) {
	            Object tworow = acc.get(i);
	            if (i == acc.size() - 1)
	              acckids = acckids + Tools.processNull(tworow);
	            else {
	              acckids = acckids + Tools.processNull(tworow) + "，";
	            }
	          }
	          vo.setAcc_kindName(acckids);
	          result.add(vo);
	        }
	      }
	      model.setRows(result);
	      model.setTotal(Long.valueOf(result.size()));
	      OutputJson(model);
	    } catch (Exception e) {
	      model.setStatus(1);
	      model.setErrMsg(e.getMessage());
	      OutputJson(model);
	    }

	    return null;
	 }
	/**
	 * 商户关联保存
	 * @return
	 */
	public String saveMerchantConAccKind(){
		Json json = new Json();
	    String messages = "";
	    try {
		    SysActionLog actionLog = this.baseService.getCurrentActionLog();
		    actionLog.setBrchId(this.merchantMangerService.getSysBranchByUserId().getBrchId());
		    if (this.typeDeal.equals("0")){
		       actionLog.setMessage("新增商户账户关联");
		    }else{
		        actionLog.setMessage("编辑商户账户关联");
		    }
		    this.merchantMangerService.saveMerchantConsLmt(this.accName, this.merchantId,actionLog);
		    this.typeDeal = "0";
		    messages = "商户账户关联成功";
		    json.setStatus(true);
		    json.setTitle("商户账户关联设置");
		    json.setMessage(messages);
	    } catch (Exception e) {
	    	saveErrLog(e);
	    	json.setStatus(false);
	    	json.setTitle("商户账户关联设置");
	    	json.setMessage(messages);
	    }
	    OutputJson(json, "text/plain");
	    return null;
	}
	
	public String queryMerModeInfo(){
		GridModel model = new GridModel();
		try{
			//1.组装查询语句
			String sql = "select t.merchant_id,t.stl_mode,to_char(t.VALID_DATE,'yyyy-mm-dd'),t.stl_way,t.stl_days,"
					+ "t.stl_lim,t.STL_WAY_RET,"
					+ "t.STL_DAYS_RET,t.STL_LIM_RET,t.STL_WAY_FEE,t.STL_DAYS_FEE,t.STL_LIM_FEE from stl_mode t where 1=1 ";
			if(!Tools.processNull(this.merchantId).equals("")){
				sql += " and t.merchant_id = '" + this.merchantId + "'";
			}
			//2.查询结果
			List<?> o = new ArrayList();
			if(Tools.processNull(queryType).equals("0")){
				o = merchantMangerService.findBySql(sql);
			}
			List result = new ArrayList();
			//3.封装查询结果
			if(o != null && o.size() > 0){
				Iterator<?> it =  o.iterator();
				while(it.hasNext()){
					Object[] onerow = (Object[]) it.next();
					MerchantView vo = new MerchantView();
					vo.setMerchantId(Tools.processNull(onerow[0]));
					vo.setMerchantName((String)merchantMangerService.findOnlyFieldBySql("select merchant_name from base_merchant where merchant_id='"+(onerow[0]+"")+"'"));
					vo.setStlMode(Tools.processNull(onerow[1]));
					vo.setValidDate(DateUtil.formatDate(onerow[2]+""));
					vo.setStlWay(Tools.processNull(onerow[3]));
					vo.setStlDays(Tools.processNull(onerow[4]));
					vo.setStlLim(Long.parseLong(Tools.processNull(onerow[5]).equals("")?"0":Tools.processNull(onerow[5])));
					vo.setStlWayRet(Tools.processNull(onerow[6]));
					vo.setStlDaysRet(Tools.processNull(onerow[7]));
					vo.setStlLimRet(Long.parseLong(Tools.processNull(onerow[8]).equals("")?"0":Tools.processNull(onerow[8])));
					vo.setStlWayFee(Tools.processNull(onerow[9]));
					vo.setStlDaysFee(Tools.processNull(onerow[10]));
					vo.setStlLimFee(Long.parseLong(Tools.processNull(onerow[11]).equals("")?"0":Tools.processNull(onerow[11])));
					result.add(vo);
				}
			}
			model.setRows(result);
			model.setTotal(Long.valueOf(result.size()+""));
			OutputJson(model);
		}catch(Exception e){
			model.setStatus(1);
			model.setErrMsg(e.getMessage());
			OutputJson(model);

		}
		return null;
	}
	
	public String saveMerSettleMode(){
		Json json = new Json();
		String messages="";
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(merchantMangerService.getSysBranchByUserId().getBrchId());
			actionLog.setMessage("编辑商户结算模式");
			merchantMangerService.saveMerchantStlMode(merchantStlMode,actionLog);
			typeDeal="0";
			messages = "商户结算模式修改成功";
			json.setStatus(true);
			json.setTitle("商户结算模式设置");
			json.setMessage(messages);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setTitle("商户结算模式设置");
			json.setMessage(messages);
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	public String delMerMode(){
		Json json = new Json();
		String messages="";
		try {
			merchantMangerService.delMerMode(merchantId,DateUtil.formatDate(DateUtil.formatDate(validDate),"yyyy-MM-dd"),baseService.getCurrentActionLog());
			messages = "商户结算模式删除成功";
			json.setStatus(true);
			json.setTitle("商户结算模式设置");
			json.setMessage(messages);
			OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setTitle("商户结算模式设置");
			json.setMessage(e.getMessage());
			OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		}
		return null;
	}
	
	/**
	 * 查询终端信息
	 * @return
	 */
	public String queryTermInfo(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		try {
			
			StringBuffer sql = new StringBuffer( "select t1.end_id as id,t1.end_id,t1.end_name,"
					+ "t1.end_type, t1.ins_location, (select s.code_name from sys_code s where "
					+ "s.code_type='END_STATE' and s.code_value=t1.end_state) as end_state ,"
					+ "t1.psam_no, t1.psam_no2, t1.login_flag,t1.login_time,t2.merchant_name, "
					+ "t1.USAGE,t1.END_SRC,t1.MODEL,t1.DEV_NO,t1.SIM_NO,t1.ACPT_TYPE,"
					+ "t1.DEAL_BATCH_NO,t1.MNG_USER_ID,t1.PRODUCER,t1.CONTRACT_NO, t2.merchant_id, "
					+ "t1.BUY_DATE,t1.PRICE,to_char(t1.MAINT_PERIOD,'yyyy-MM-dd') as MAINT_PERIOD,t1.MAINT_CORP,t1.MAINT_PHONE,"
					+ "to_char(t1.REG_DATE,'yyyy-MM-dd hh24:mi:ss') as REG_DATE,"
					+ "t1.REG_USER_ID,t1.CLS_USER_ID,to_char(t1.CLS_DATE,'yyyy-MM-dd hh24:mi:ss') as CLS_DATE,"
					+ "t1.RECYCLE_DATE,to_char(t1.RECYCLE_TIME,'yyyy-MM-dd hh24:mi:ss') as RECYCLE_TIME,t1.RECYCLE_USER_ID,t1.NOTE ");
			sql.append(" from base_tag_end t1 left join base_merchant t2 on t1.own_id  = t2.merchant_id where 1 = 1 " );		
			
			if(!Tools.processNull(this.merchantId).equals("")){
				sql.append(" and t2.merchant_id = '" + this.merchantId + "'");
			}
			if(!Tools.processNull(this.endName).equals("")){
				sql.append(" and t1.end_Name like '%" + this.endName + "%'");
			}
			if(!Tools.processNull(this.endId).equals("")){
				sql.append(" and t1.end_id = '" + this.endId + "'");
			}
			if(!Tools.processNull(this.endState).equals("")){
				sql.append(" and t1.end_State = '" + this.endState + "'");
			}else{
				sql.append(" order by t1.end_id  desc");
			}
			Page pages = merchantMangerService.pagingQuery(sql.toString(),page,rows);
			if(pages.getAllRs() != null){
				jsonObject.put("rows",pages.getAllRs());
				jsonObject.put("total", pages.getTotalCount());
			}
			
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 * 查询商户终端出库信息
	 * @return
	 */
	public String queryTerOutBoundInfo(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		try {
			
			StringBuffer sql = new StringBuffer( "select t1.end_id ,t1.end_name,"
					+ "(select s.code_name from sys_code s where s.code_type='END_STATE' "
					+ "and s.code_value=t1.end_state)  end_state ,t2.out_date,"
					+ "t2.seller_name,t2.seller_mobIle,t2.seller_linkman,t2.out_no,"
					+ "(select s.code_name from sys_code s where s.code_type='OUT_GOODS_STATE' "
					+ "and s.code_value=t2.out_goods_state) as out_goods_state,t2.user_id,"
					+ "to_char(t2.oper_time,'yyyy-MM-dd hh24:mi:ss') as oper_time, t2.note");
			sql.append(" from base_tag_end t1 join base_end_out t2 on t1.end_id=t2.out_id "
					+ "join base_merchant t3 on t1.own_id = t3.merchant_id where  1=1 ");		
			if(!Tools.processNull(tagEnd.getEndId()).equals("")){
				sql.append(" and t1.end_id = '" + tagEnd.getEndId() + "'");
			}
			if(!Tools.processNull(tagEnd.getEndName()).equals("")){
				sql.append(" and t1.end_Name like '%" + tagEnd.getEndName() + "%'");
			}
			if(!Tools.processNull(merchantId).equals("")){
				sql.append(" and t1.own_id = '" + merchantId + "'");
			}
			if(!Tools.processNull(merchantName).equals("")){
				sql.append(" and t3.merchant_name like '%" + merchantName + "%'");
			}
			Page pages = merchantMangerService.pagingQuery(sql.toString(),page,rows);
			if(pages.getAllRs() != null){
				jsonObject.put("rows",pages.getAllRs());
				jsonObject.put("total", pages.getTotalCount());
			}
			
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	public String toAddMerTerm(){
		try {
			tagEnd = new BaseTagEnd();
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toAddMerTerm";
	}
	/**
	 * 终端报修
	 * @return
	 */
	public String toTermRepairs(){
		try {
			tagEnd = (BaseTagEnd)merchantMangerService.findOnlyRowByHql("from BaseTagEnd where endId='"+endId+"'");
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toTermRepairs";
	}
	/**
	 * 到达回收页面
	 * @return
	 */
	public String toRecycle(){
		try {
			tagEnd = (BaseTagEnd)merchantMangerService.findOnlyRowByHql("from BaseTagEnd where endId='"+endId+"'");
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toRecycle";
	}
	/**
	 * 到达出库编辑页面
	 * @return
	 */
	public String toOutbound(){
		try {
			tagEnd = (BaseTagEnd)merchantMangerService.findOnlyRowByHql("from BaseTagEnd where endId='"+endId+"'");
			endOut = (BaseEndOut)merchantMangerService.findOnlyRowByHql("from BaseEndOut where outId='"+endId+"'");
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toOutbound";
	}
	/**
	 * 保存商户终端出库信息
	 * @return
	 */
	public void saveOutbound(){
		Json json = new Json();
		try {  
                   endId=Long.toString(tagEnd.getEndId());
            	   merchantMangerService.saveOutbound(endOut,endId);  
            	   json.setStatus(true);
       			   json.setTitle("成功提示");
       			   json.setMessage("商户终端出库信息保存成功");
			
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
	}
	/**
	 * 到达编辑页面
	 * @return
	 */
	public String toEditTerm(){
		try {
			tagEnd = (BaseTagEnd)merchantMangerService.findOnlyRowByHql("from BaseTagEnd where endId='"+endId+"'");
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toEditTerm";
	}
	/**
	 * 终端信息保存
	 * @return
	 */
	public String saveTerm(){
		Json json = new Json();
		try {
			merchantMangerService.saveMerTerm(tagEnd, type);
			json.setStatus(true);
			json.setTitle("成功提示");
			json.setMessage("商户终端信息保存成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}

	/**
	 *终端信息报废
	 * @return
	 */
	public String delTermInfo(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealTime(merchantMangerService.getDateBaseTime());
			merchantMangerService.delTermInfo(endId, actionLog);
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 *终端信息报修
	 * @return
	 */
	public String updateTermRepairs(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);//查询状态
		jsonObject.put("errMsg",0);
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealTime(merchantMangerService.getDateBaseTime());
             endId=Long.toString(tagEnd.getEndId());
			merchantMangerService.updateTermRepairs(endId,tagEnd.getMaintCorp(),tagEnd.getMaintPhone(),tagEnd.getNote(),tagEnd.getMaintPeriod(), actionLog);
			jsonObject.put("status","1");
		}catch(Exception e){
			jsonObject.put("status","0");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 * 启用或是注销商户终端
	 * @return
	 */
	public String saveDisableOrEnableMerTer(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			String[] endIds = endId.split(",");
			for (String endId : endIds) {
				merchantMangerService.saveDisableOrEnableMerTer(endId, this.queryType);
			}
			jsonObject.put("msg",(this.queryType.equals("1") ? "启用商户终端成功！" : "注销商户终端成功！"));
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 终端回收编辑
	 * @return
	 */
	public String updateRecycle(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("errMsg",0);
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealTime(merchantMangerService.getDateBaseTime());
             endId=Long.toString(tagEnd.getEndId());
			merchantMangerService.updateRecycle(endId, tagEnd.getRecycleDate(), actionLog.getUserId(), actionLog.getDealTime(), actionLog);
			jsonObject.put("status","1");
		}catch(Exception e){
			jsonObject.put("status","0");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 * 查询商户消费模式
	 * @return
	 */
	public String merCsmModeInfoQuery(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		try {
			if(this.queryType.equals("0")){
			  String head = "select t1.MODE_ID,t1.MODE_NAME,t1.ACC_SQN,t1.REACC_TYPE,t1.REACC_TYPE_BAK,"+
					  		"t1.MODE_STATE,t1.NOTE  ";
				StringBuffer sql = new StringBuffer(" from PAY_ACCTYPE_SQN t1 where " +
							" 1=1 " );		
				if(!Tools.processNull(modeName).equals("")){
					sql.append(" and t1.mode_name = '").append(modeName.trim()).append("'");
				}
				if(!Tools.processNull(modeState).equals("")){
					sql.append(" and t1.mode_state = '").append(modeState).append("' ");
				}
				if(!Tools.processNull(sort).equals("")){
					sql.append(" order by " + sort + " " + order + " ");
				}else{
					sql.append(" order by t1.MODE_ID  desc");
				}
				Page pages = merchantMangerService.pagingQuery(head+sql.toString(),page,rows);
				if(pages.getAllRs() != null){
					jsonObject.put("rows",pages.getAllRs());
					jsonObject.put("total", pages.getTotalCount());
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	
	/**
	 * 到达商户消费模式编辑页面
	 * @return
	 */
	public String toEditConsumeModeView(){
		try {
			paySqn = (PayAcctypeSqn)merchantMangerService.findOnlyRowByHql("from PayAcctypeSqn where modeId='"+modeId+"'");
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toEditConsumeModeView";
	}
	
	/**
	 * 保存商户消费模式 新增和编辑
	 * @return
	 */
	public String saveConsumeMode(){
		Json json = new Json();
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealTime(merchantMangerService.getDateBaseTime());
			if(Tools.processNull(paySqn.getModeId()).equals("")){
				actionLog.setDealCode(DealCode.CONSUMEMODE_ADD);
			}else{
				actionLog.setDealCode(DealCode.CONSUMEMODE_EDIT);
			}
			merchantMangerService.saveConsumeMode(actionLog,merchantMangerService.getUser(),paySqn);
			json.setStatus(true);
			json.setTitle("成功提示");
			json.setMessage("商户消费模式保存成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	/**
	 * 获取消费模式下拉列表
	 * @return
	 */
	public String getConsumeModeSqn(){
		Json json = new Json();
		try {
			String hql = "from PayAcctypeSqn where  1=1 and modeState ='0'";
			if(!Tools.processNull(modeId).equals("")){
				hql+=" and modeId='"+modeId+"'";
			}
			List<PayAcctypeSqn> payAcctypeSqnlists = (List<PayAcctypeSqn>)merchantMangerService.findByHql(hql);
			OutputJson(payAcctypeSqnlists);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		return null;
	}
	/**
	 * 获取商户消费模式信息
	 * @return
	 */
	public String merGetCosModeInfo(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		Long total=0l;
		try {
			if(this.queryType.equals("0")){
			  String head = "SELECT T1.MERCHANT_ID || '|' || T1.MODE_ID || '|' || T1.MODE_TYPE SELECT_ID,"+
				       		"T1.MERCHANT_ID MERCHANT_ID,T2.MERCHANT_NAME MERCHANT_NAME,"+
				       		"decode(T1.MODE_TYPE,0,'单账户消费',1,'多账户消费') MODE_TYPE,"+
				       		"(SELECT MODE_NAME FROM PAY_ACCTYPE_SQN WHERE MODE_ID = T1.MODE_ID) MODE_NAME,"+
				       		"DECODE(T1.MODE_STATE, 0, '在用', 1, '停用', '未知') STATE ";
				StringBuffer sql = new StringBuffer(" FROM BASE_MERCHANT_MODE T1, BASE_MERCHANT T2 WHERE T1.MERCHANT_ID = T2.MERCHANT_ID ");		
				if(!Tools.processNull(merchantId).equals("")){
					sql.append(" and t1.merchant_id = '").append(merchantId.trim()).append("' ");
				}
				if(!Tools.processNull(modeState).equals("")){
					sql.append(" and t1.mode_state = '").append(modeState.trim()).append("' ");
				}
				if(!Tools.processNull(sort).equals("")){
					sql.append(" order by " + sort + " " + this.getOrder());
				}
				Page pages = merchantMangerService.pagingQuery(head+sql.toString(),page, rows);
				
				
				if(pages.getAllRs() == null){
					throw new CommonException("根据指定信息未查询到对应商户消费模式信息！");
				}else{
					jsonObject.put("rows",pages.getAllRs());
					jsonObject.put("total", pages.getTotalCount());
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 * 到达商户消费模式编辑主页
	 * @return
	 */
	public String toEditMerGetCosMode(){
		try {
			String[] modeIds= modeId.split("\\|");
			merchantId = modeIds[0];
			BaseMerchantMode mode = (BaseMerchantMode)merchantMangerService.findOnlyRowByHql("from BaseMerchantMode where id.merchantId ='"+
									modeIds[0].toString().trim()+"' and id.modeId='"+modeIds[1].toString().trim()+"'");
			if(mode==null){
				throw new CommonException("选择的商户结算模式不存在");
			}
			modeState =  mode.getModeState();
			modeId = modeIds[1].toString().trim();
		} catch (Exception e) {
			
		}
		return "toEditMerGetCosMode";
	}
	/**
	 * 保存商户结算消费模式
	 * @return
	 */
	public String saveMerGetCosMode(){
		Json json = new Json();
		try {
			if(Tools.processNull(merchantId).equals("")){
				throw new CommonException("商户编号为空，不能进行商户消费模式的保存");
			}
			if(Tools.processNull(consumeMode).equals("")){
				throw new CommonException("未选择消费模式，不能进行商户消费模式的保存");
			}
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealTime(merchantMangerService.getDateBaseTime());
			actionLog.setDealCode(DealCode.MERCHANT_ARCHIVES_CONSUME_MODE_ADD);
			actionLog.setMessage("新增商户消费模式，商户编号为："+merchantId+"消费模式为："+consumeMode);
			merchantMangerService.saveMerGetCosMode(actionLog,merchantMangerService.getUser(),merchantId,consumeMode);
			json.setStatus(true);
			json.setTitle("成功提示");
			json.setMessage("商户消费模式保存成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	/**
	 * 保存商户消费模式
	 * @return
	 */
	public String saveMerGetCosModeEdit(){
		Json json = new Json();
		try {
			if(Tools.processNull(merchantId).equals("")){
				throw new CommonException("商户编号为空，不能进行商户消费模式的保存");
			}
			if(Tools.processNull(modeId).equals("")){
				throw new CommonException("未选择消费模式，不能进行商户消费模式的保存");
			}
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealTime(merchantMangerService.getDateBaseTime());
			actionLog.setDealCode(DealCode.MERCHANT_ARCHIVES_CONSUME_MODE_EDIT);
			actionLog.setMessage("编辑商户消费模式，商户编号为："+merchantId+"消费模式为："+consumeMode);
			merchantMangerService.saveMerGetCosModeEdit(actionLog,merchantMangerService.getUser(),merchantId,modeId,modeState);
			json.setStatus(true);
			json.setTitle("成功提示");
			json.setMessage("商户消费模式保存成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	/**
	 * 自动完成
	 * @return
	 */
	@SuppressWarnings("rawtypes")
	public String initAutoComplete(){
		JSONArray array = new JSONArray();
		try{
			String where = "";
			if(Tools.processNull(this.queryType).equals("0")){
				where = "t.merchant_name like '%" + merchant.getMerchantName() + "%'";
			}else{
				where = "t.merchant_id like '%" + merchant.getMerchantId() + "%'";
			}
			List all = baseService.findBySql("select  t.merchant_id,t.merchant_name from base_merchant t where " + where );
			for(Object row:all){
				Object[] temponerow = (Object[]) row;
				JSONObject o = new JSONObject();
				o.put("label",temponerow[0].toString());
				o.put("text",temponerow[1].toString());
				array.add(o);
			}
		}catch(Exception e){
			log.error(e);
		}
		jsonObject.put("rows",array);
		return this.JSONOBJ;
	}
	
	public String getAllAccCheckBox(){
	    JSONArray array = new JSONArray();
	    try {
	      String sql = "SELECT t1.acc_kind acc_kind,t2.acc_name acc_name from acc_open_conf t1, acc_kind_config t2 ";

	      sql = sql + "WHERE t1.acc_kind =  t2.acc_kind AND t1.main_type = '1' and sub_type = '100' ";
	      List all = this.baseService.findBySql(sql);
	      for (Iterator localIterator = all.iterator(); localIterator.hasNext(); ) { Object row = localIterator.next();
	        Object[] temponerow = (Object[])row;
	        JSONObject o = new JSONObject();
	        o.put("accKind", temponerow[0].toString());
	        o.put("accName", temponerow[1].toString());
	        array.add(o); }
	    }
	    catch (Exception e) {
	      this.log.error(e);
	    }
	    this.jsonObject.put("rows", array);
	    return this.JSONOBJ;
	 }

	 public String getAllEditAccCheckBox(){
	    JSONArray array = new JSONArray();
	    try {
	      String sql = "SELECT t1.acc_kind acc_kind,t2.acc_name acc_name from acc_open_conf t1, acc_kind_config t2 ";

	      sql = sql + "WHERE t1.acc_kind =  t2.acc_kind AND t1.main_type = '1' and sub_type = '100' ";
	      List all = this.baseService.findBySql(sql);
	      for (Iterator localIterator = all.iterator(); localIterator.hasNext(); ) { Object row = localIterator.next();
	        Object[] temponerow = (Object[])row;
	        JSONObject o = new JSONObject();
	        o.put("accKind", temponerow[0].toString());
	        o.put("accName", temponerow[1].toString());
	        BigDecimal bg = (BigDecimal)this.baseService.findOnlyFieldBySql("select nvl(count(1),0) from pay_merchant_acctype where merchant_id='" + this.merchantId + "' and acc_kind='" + temponerow[0].toString().trim() + "'");
	        o.put("checkTypeValue", bg.toString());
	        array.add(o); }
	    }
	    catch (Exception e) {
	      this.log.error(e);
	    }
	    this.jsonObject.put("rows", array);
	    return this.JSONOBJ;
	}
	 
	public String importBatchTerminals() {
		try {
			if (file == null) {
				throw new CommonException("导入文件为空.");
			}
			
			ExcelUtil<BaseTagEnd> excelUtil = new ExcelUtil<BaseTagEnd>(BaseTagEnd.class);
			List<BaseTagEnd> terminals = excelUtil.importExcel("", new FileInputStream(file));
			
			// build terminal
			for (BaseTagEnd terminal : terminals) {
				// endsrc
				if ("自购".equals(terminal.getEndSrc())) {
					terminal.setEndSrc("1");
				} else if ("租用".equals(terminal.getEndSrc())) {
					terminal.setEndSrc("2");
				} else {
					terminal.setEndSrc(null);
				}
				
				// usage
				if ("支付终端".equals(terminal.getUsage())) {
					terminal.setUsage("1");
				} else if ("非支付终端".equals(terminal.getUsage())) {
					terminal.setUsage("2");
				} else {
					terminal.setUsage(null);
				}
				
				// endtype
				if ("人工".equals(terminal.getEndType())) {
					terminal.setEndType("1");
				} else if ("自助".equals(terminal.getEndType())) {
					terminal.setEndType("2");
				} else if ("虚拟终端".equals(terminal.getEndType())) {
					terminal.setEndType("9");
				} else {
					terminal.setEndType(null);
				}
				
				// roleid
				if ("一般柜员".equals(terminal.getRoleId())) {
					terminal.setRoleId("0");
				} else if ("网点主管".equals(terminal.getRoleId())) {
					terminal.setRoleId("1");
				} else if ("网点及子网点".equals(terminal.getRoleId())) {
					terminal.setRoleId("2");
				} else if ("当前机构".equals(terminal.getRoleId())) {
					terminal.setRoleId("3");
				} else if ("机构及子机构".equals(terminal.getRoleId())) {
					terminal.setRoleId("4");
				} else if ("所有数据权限".equals(terminal.getRoleId())) {
					terminal.setRoleId("5");
				} else {
					terminal.setRoleId(null);
				}
				
				// acpttype
				if ("商户".equals(terminal.getAcptType())) {
					terminal.setAcptType("0");
				} else if ("网点".equals(terminal.getAcptType())) {
					terminal.setAcptType("1");
				} else {
					terminal.setAcptType(null);
				}
				
				// ownId
				if (terminal.getOwnId() != null) {
					BaseMerchant merchant = (BaseMerchant) baseService.findOnlyRowByHql("from BaseMerchant where merchantId = '" + terminal.getOwnId() + "'");
					if (merchant != null) {
						terminal.setOwnId(merchant.getMerchantId());
					} else {
						terminal.setOwnId(null);
					}
				} else {
					terminal.setOwnId(null);
				}
				
				// standbyDate
				if (terminal.getStandbyDateStr() != null) {
					terminal.setStandbyDate(DateUtils.parse(terminal.getStandbyDateStr(), "yyyyMMdd"));
				}

				// buyDateStr
				if (terminal.getBuyDateStr() != null) {
					terminal.setBuyDate(DateUtils.parse(terminal.getBuyDateStr(), "yyyyMMdd"));
				}

				// insDateStr
				if (terminal.getInsDateStr() != null) {
					terminal.setInsDate(DateUtils.parse(terminal.getInsDateStr(), "yyyyMMdd"));
				}
			}
			
			// add terminal
			List<BaseTagEnd> failList = merchantMangerService.saveMerTerm(terminals);
			
			if (!failList.isEmpty()) {
				String expid = "exp" + new Date().getTime();
				request.getSession().setAttribute(expid, failList);
				jsonObject.put("hasFail", true);
				jsonObject.put("expid", expid);
			}
			
			jsonObject.put("status", "0");
			jsonObject.put("msg", "共" + terminals.size() + "条记录, 成功" + (terminals.size() - failList.size()) + "条, 失败" + failList.size() + "条.");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportBatchTerminalsFaliList() {
		try {
			String fileName = "商户终端批量导入失败数据";
			if(expid == null){
				throw new CommonException("expid is null.");
			}
			HttpSession session = request.getSession();
			List<BaseTagEnd> failList = (List<BaseTagEnd>) session.getAttribute(expid);
			session.removeAttribute(expid);
			if (failList == null || failList.isEmpty()) {
				throw new CommonException("数据为空.");
			}
			for (BaseTagEnd terminal : failList) {
				// endsrc
				if ("1".equals(terminal.getEndSrc())) {
					terminal.setEndSrc("自购");
				} else if ("2".equals(terminal.getEndSrc())) {
					terminal.setEndSrc("租用");
				} else {
					terminal.setEndSrc(null);
				}
				
				// usage
				if ("1".equals(terminal.getUsage())) {
					terminal.setUsage("支付终端");
				} else if ("2".equals(terminal.getUsage())) {
					terminal.setUsage("非支付终端");
				} else {
					terminal.setUsage(null);
				}
				
				// endtype
				if ("1".equals(terminal.getEndType())) {
					terminal.setEndType("人工");
				} else if ("2".equals(terminal.getEndType())) {
					terminal.setEndType("自助");
				} else if ("9".equals(terminal.getEndType())) {
					terminal.setEndType("虚拟终端");
				} else {
					terminal.setEndType(null);
				}
				
				// roleid
				if ("0".equals(terminal.getRoleId())) {
					terminal.setRoleId("一般柜员");
				} else if ("1".equals(terminal.getRoleId())) {
					terminal.setRoleId("网点主管");
				} else if ("2".equals(terminal.getRoleId())) {
					terminal.setRoleId("网点及子网点");
				} else if ("3".equals(terminal.getRoleId())) {
					terminal.setRoleId("当前机构");
				} else if ("4".equals(terminal.getRoleId())) {
					terminal.setRoleId("机构及子机构");
				} else if ("5".equals(terminal.getRoleId())) {
					terminal.setRoleId("所有数据权限");
				} else {
					terminal.setRoleId(null);
				}
				
				// acpttype
				if ("0".equals(terminal.getAcptType())) {
					terminal.setAcptType("商户");
				} else if ("1".equals(terminal.getAcptType())) {
					terminal.setAcptType("网点");
				} else {
					terminal.setAcptType(null);
				}
			}
			ExcelUtil<BaseTagEnd> excelUtil = new ExcelUtil<BaseTagEnd>(BaseTagEnd.class);
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			OutputStream output = response.getOutputStream();
			excelUtil.exportExcel(failList, fileName, 0, output);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String saveOutboundCancel() {
		try {
			merchantMangerService.saveOutboundCancel(endId);
			jsonObject.put("status", "0");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportMerchantInfoFile() {
		try {
			List<Object[]> data = null;
			if (!Tools.processNull(merchantIds).equals("")) {// 导出选中
				String[] arr = merchantIds.split(",");
				String where = "";
				for (String merchantId : arr) {
					where += ",'" + merchantId + "'";
				}
				String head = "select t1.CUSTOMER_ID \"customerId\", t1.merchant_Id \"merchantId\", t1.merchant_Name \"merchantName\", "
						+ "t2.type_Name \"typeName\", nvl(t2.id, '0') \"id\" ,nvl(t1.contact,'') \"contact\",t1.CON_PHONE \"conPhone\", "
						+ "t1.CON_CERT_NO \"conCertNo\", t1.merchant_state \"merchantState\", t1.note \"note\", "
						+ "to_char(t1.sign_date, 'yyyy-mm-dd hh24:mi:ss') \"signDate\", t1.sign_user_id \"signUserId\" ";
				String hql = " from Base_Merchant t1,Base_Merchant_Type t2 where t1.merchant_type=t2.id(+) ";
				hql += "and t1.merchant_id in(" + where.substring(1) + ")";
				data = merchantMangerService.findBySql(head + hql);
			} else {// 按条件导出
				String head = "select t1.CUSTOMER_ID \"customerId\", t1.merchant_Id \"merchantId\", t1.merchant_Name \"merchantName\", "
						+ "t2.type_Name \"typeName\", nvl(t2.id, '0') \"id\" ,nvl(t1.contact,'') \"contact\",t1.CON_PHONE \"conPhone\", "
						+ "t1.CON_CERT_NO \"conCertNo\", t1.merchant_state \"merchantState\", t1.note \"note\", "
						+ "to_char(t1.sign_date, 'yyyy-mm-dd hh24:mi:ss') \"signDate\", t1.sign_user_id \"signUserId\" ";
				String hql = " from Base_Merchant t1,Base_Merchant_Type t2 where t1.merchant_type=t2.id(+) ";
				if (!Tools.processNull(this.merchantId).equals("")) {
					hql += " and t1.merchant_id = '" + this.merchantId + "'";
				}
				if (!Tools.processNull(this.merchantState).equals("")) {
					hql += " and t1.merchant_State = '" + this.merchantState + "'";
				}
				if (!Tools.processNull(merchantType).equals("")) {
					hql += " and t1.merchant_Type = '" + merchantType + "'";
				}
				if (!Tools.processNull(merchantName).equals("")) {
					hql += " and t1.merchant_name like '%" + merchantName + "%'";
				}

				data = merchantMangerService.findBySql(head + hql);
			}
			
			// 导出
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String("商户数据导出".getBytes(), "iso8859-1") + ".xls");
			OutputStream output = response.getOutputStream();
			
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet("商户数据");
			sheet.setColumnWidth(0, 5000);
			sheet.setColumnWidth(1, 8000);
			sheet.setColumnWidth(2, 4000);
			sheet.setColumnWidth(3, 3000);
			sheet.setColumnWidth(4, 5000);
			sheet.setColumnWidth(5, 8000);
			sheet.setColumnWidth(6, 2000);
			sheet.setColumnWidth(7, 5000);
			sheet.setColumnWidth(8, 4000);
			sheet.setColumnWidth(9, 9000);
			
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
			headCellStyle.setFont(headCellFont);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			// head
			Row headRow = sheet.createRow(0);
			Cell headCell0 = headRow.createCell(0);
			Cell headCell1 = headRow.createCell(1);
			Cell headCell2 = headRow.createCell(2);
			Cell headCell3 = headRow.createCell(3);
			Cell headCell4 = headRow.createCell(4);
			Cell headCell5 = headRow.createCell(5);
			Cell headCell6 = headRow.createCell(6);
			Cell headCell7 = headRow.createCell(7);
			Cell headCell8 = headRow.createCell(8);
			Cell headCell9 = headRow.createCell(9);
			
			headCell0.setCellStyle(headCellStyle);
			headCell1.setCellStyle(headCellStyle);
			headCell2.setCellStyle(headCellStyle);
			headCell3.setCellStyle(headCellStyle);
			headCell4.setCellStyle(headCellStyle);
			headCell5.setCellStyle(headCellStyle);
			headCell6.setCellStyle(headCellStyle);
			headCell7.setCellStyle(headCellStyle);
			headCell8.setCellStyle(headCellStyle);
			headCell9.setCellStyle(headCellStyle);
			
			headCell0.setCellValue("商户编号");
			headCell1.setCellValue("商户名称");
			headCell2.setCellValue("商户类型");
			headCell3.setCellValue("联系人");
			headCell4.setCellValue("联系人电话");
			headCell5.setCellValue("联系人证件号码");
			headCell6.setCellValue("状态");
			headCell7.setCellValue("录入时间");
			headCell8.setCellValue("录入人");
			headCell9.setCellValue("备注");
			
			for (int i = 0; i < data.size(); i++) {
				Object[] merchant = data.get(i);
				
				Row row = sheet.createRow(i+1);
				
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
				
				cell0.setCellStyle(cellStyle);
				cell1.setCellStyle(cellStyle);
				cell2.setCellStyle(cellStyle);
				cell3.setCellStyle(cellStyle);
				cell4.setCellStyle(cellStyle);
				cell5.setCellStyle(cellStyle);
				cell6.setCellStyle(cellStyle);
				cell7.setCellStyle(cellStyle);
				cell8.setCellStyle(cellStyle);
				cell9.setCellStyle(cellStyle);
				
				cell0.setCellValue(Tools.processNull(merchant[1]));
				cell1.setCellValue(Tools.processNull(merchant[2]));
				cell2.setCellValue(Tools.processNull(merchant[3]));
				cell3.setCellValue(Tools.processNull(merchant[5]));
				cell4.setCellValue(Tools.processNull(merchant[6]));
				cell5.setCellValue(Tools.processNull(merchant[7]));
				String state = "";
				if (Tools.processNull(merchant[8]).equals("0")) {
					state = "正常";
				} else if (Tools.processNull(merchant[8]).equals("1")) {
					state = "注销";
				} else {
					state = "未审核";
				}
				cell6.setCellValue(state);
				cell7.setCellValue(Tools.processNull(merchant[10]));
				cell8.setCellValue(Tools.processNull(merchant[7]));
				cell9.setCellValue(Tools.processNull(merchant[11]));
			}
			
			workbook.write(response.getOutputStream());
			workbook.close();
			response.getOutputStream().flush();
			response.getOutputStream().close();
			request.getSession().setAttribute("expMerDownloadSuc", Constants.YES_NO_YES);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
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
			Date d1 = new Date();
			while ((b = bis.read()) != -1) {
				bos.write(b);
			}
			Date d2 = new Date();
			System.out.println(d2.getTime()-d1.getTime());
			bos.flush();
			bos.close();
		} catch (Exception e) {
			jsonObject.put("status", "1");
		}
		return JSONOBJ;
	}
	 
	public String getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	public String getMerchantState() {
		return merchantState;
	}

	public void setMerchantState(String merchantState) {
		this.merchantState = merchantState;
	}

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}

	public BaseMerchant getMerchant() {
		return merchant;
	}

	public void setMerchant(BaseMerchant merchant) {
		this.merchant = merchant;
	}

	public StlMode getMerchantStlMode() {
		return merchantStlMode;
	}

	public void setMerchantStlMode(StlMode merchantStlMode) {
		this.merchantStlMode = merchantStlMode;
	}

	public String getValidDate() {
		return validDate;
	}

	public void setValidDate(String validDate) {
		this.validDate = validDate;
	}

	public PayMerchantLim getMerLmt() {
		return merLmt;
	}

	public void setMerLmt(PayMerchantLim merLmt) {
		this.merLmt = merLmt;
	}

	public String getTypeDeal() {
		return typeDeal;
	}

	public void setTypeDeal(String typeDeal) {
		this.typeDeal = typeDeal;
	}


	public String getAcckinds() {
		return acckinds;
	}


	public void setAcckinds(String acckinds) {
		this.acckinds = acckinds;
	}

	public String getAcc_kindQB() {
		return acc_kindQB;
	}

	public void setAcc_kindQB(String acc_kindQB) {
		this.acc_kindQB = acc_kindQB;
	}

	public String getAcc_kindLJ() {
		return acc_kindLJ;
	}

	public void setAcc_kindLJ(String acc_kindLJ) {
		this.acc_kindLJ = acc_kindLJ;
	}

	public String getAcc_kindZY() {
		return acc_kindZY;
	}

	public void setAcc_kindZY(String acc_kindZY) {
		this.acc_kindZY = acc_kindZY;
	}

	public String getEndId() {
		return endId;
	}

	public void setEndId(String endId) {
		this.endId = endId;
	}

	public String getEndState() {
		return endState;
	}

	public void setEndState(String endState) {
		this.endState = endState;
	}

	public BaseTagEnd getTagEnd() {
		return tagEnd;
	}

	public void setTagEnd(BaseTagEnd tagEnd) {
		this.tagEnd = tagEnd;
	}
	
	public BaseEndOut getEndOut() {
		return endOut;
	}

	public void setEndOut(BaseEndOut endOut) {
		this.endOut = endOut;
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

	public String getModeName() {
		return modeName;
	}

	public void setModeName(String modeName) {
		this.modeName = modeName;
	}

	public String getModeState() {
		return modeState;
	}

	public void setModeState(String modeState) {
		this.modeState = modeState;
	}

	public PayAcctypeSqn getPaySqn() {
		return paySqn;
	}

	public void setPaySqn(PayAcctypeSqn paySqn) {
		this.paySqn = paySqn;
	}

	public String getModeId() {
		return modeId;
	}

	public void setModeId(String modeId) {
		this.modeId = modeId;
	}

	public String getConsumeMode() {
		return consumeMode;
	}

	public void setConsumeMode(String consumeMode) {
		this.consumeMode = consumeMode;
	}

	public String getMerchantType() {
		return merchantType;
	}

	public void setMerchantType(String merchantType) {
		this.merchantType = merchantType;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getAccName() {
		return accName;
	}

	public void setAccName(String accName) {
		this.accName = accName;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public File getFile() {
		return file;
	}

	public void setFile(File file) {
		this.file = file;
	}

	public String getEndName() {
		return endName;
	}

	public void setEndName(String endName) {
		this.endName = endName;
	}

	public String getMerchantIds() {
		return merchantIds;
	}

	public void setMerchantIds(String merchantIds) {
		this.merchantIds = merchantIds;
	}

	public String getTemplate() {
		return template;
	}

	public void setTemplate(String template) {
		this.template = template;
	}

	public String getExpid() {
		return expid;
	}

	public void setExpid(String expid) {
		this.expid = expid;
	}
}
