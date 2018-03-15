package com.erp.action;

import java.io.OutputStream;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.DataFormat;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.shiro.SecurityUtils;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseMerchant;
import com.erp.model.BaseMerchantMode;
import com.erp.model.BaseTagEnd;
import com.erp.model.PayAcctypeSqn;
import com.erp.model.PayMerchantLim;
import com.erp.model.StlMode;
import com.erp.model.StlModeId;
import com.erp.model.SysActionLog;
import com.erp.service.MerchantMangerService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.GridModel;
import com.erp.viewModel.Json;
import com.erp.viewModel.MerConsumeAccKindView;
import com.erp.viewModel.MerchantView;
import com.erp.viewModel.Page;

import jxl.Workbook;
import jxl.format.Alignment;
import jxl.format.Border;
import jxl.format.BorderLineStyle;
import jxl.format.Colour;
import jxl.write.Label;
import jxl.write.WritableCellFormat;
import jxl.write.WritableFont;
import jxl.write.WritableSheet;
import jxl.write.WritableWorkbook;

@SuppressWarnings("serial")
@Namespace("/merchantManage")
@Action("merchantManageAction")
@Results({@Result(type="json",name="json"),
	@Result(name="viewMerchant",location="/jsp/merchantManage/merchantViewInfo.jsp"),
	@Result(name="toAddMerchant",location="/jsp/merchantManage/merchantAdd.jsp"),
	@Result(name="toEidtMerchant",location="/jsp/merchant/merchantRegistEidtDlg.jsp")})
@InterceptorRef("jsondefalut")
public class MerchantManageAction extends BaseAction {
	private String sort="";
	private String order="";
	private MerchantMangerService merchantMangerService;
	private String merchantId="";
	private String merchantState="";
	private String queryType = "1";//查询类型 1 不进行查询,直接返回;0 进行查询,返回查询结果。
	private BaseMerchant merchant=null;
	private StlMode merchantStlMode=null;
	private BaseTagEnd  tagEnd=null;
	private PayMerchantLim  merLmt = null;
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
	
	// 商户交易查询
	private String merchantName;
	private String tagId;
	private String tagName;
	private String dealBatchNo;
	private String endDealNo;
	private String cardNo;
	private String dealNo;
	private String clrStartDateStr;
	private String clrEndDateStr;
	private String trStartDate;
	private String trEndDate;
	private String trName;
	
	private String expid;

	private String stlSumNo;
	private String clrSumMessage = "";
	/**
	 * 
	 * @return
	 */
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
		GridModel model = new GridModel();
		try{
			//1.组装查询语句
			String head = "select t1.CUSTOMER_ID,t1.merchant_Id merchantId,t1.merchant_Name merchantName,t2.type_Name typeName,t2.id ID ,nvl(t1.contact,'') CONTACT,t1.CON_PHONE conPhone,"
					+ "t1.CON_CERT_NO conCertNo,t1.merchant_state merchantState,t1.note";
			String hql = " from Base_Merchant t1,Base_Merchant_Type t2 where t1.merchant_type=t2.id(+) ";
			if(!Tools.processNull(this.merchantId).equals("")){
				hql += " and t1.merchant_id = '" + this.merchantId + "'";
			}
			if(!Tools.processNull(this.merchantState).equals("")){
				hql += " and t1.merchant_State = '" + this.merchantState + "'";
			}
			if(!Tools.processNull(sort).equals("")){
				hql += " order by " + sort;
				
				if(!Tools.processNull(order).equals("")){
					hql += " " + order;
				}
			}
			//2.查询结果
			JSONArray o = new JSONArray();
			if(Tools.processNull(queryType).equals("0")){
				o = merchantMangerService.pagingQuery(head+hql,page, rows).getAllRs();
			}
			List result = new ArrayList();
			//3.封装查询结果
			if(o != null && o.size() > 0){
				Iterator<?> it =  o.iterator();
				while(it.hasNext()){
					JSONObject onerow = (JSONObject) it.next();
					MerchantView vo = new MerchantView();
					vo.setCustomerId(Tools.processNull(onerow.get("CUSTOMER_ID"))+"");
					vo.setMerchantId(Tools.processNull(onerow.get("MERCHANTID"))+"");
					vo.setMerchantName(Tools.processNull(onerow.get("MERCHANTNAME"))+"");
					vo.setTypeName(Tools.processNull(onerow.get("TYPENAME")));
					if(!Tools.processNull(onerow.get("ID")).equals("")){
						vo.setId(Integer.parseInt(Tools.processNull(onerow.get("ID"))+""));
					}
					vo.setContact(Tools.processNull(onerow.get("CONTACT"))+"");
					vo.setConPhone(Tools.processNull(onerow.get("CONPHONE"))+"");
					vo.setContactNo(Tools.processNull(onerow.get("CONCERTNO"))+"");
					vo.setMerchantState(Tools.processNull(onerow.get("MERCHANTSTATE"))+"");
					vo.setNote(Tools.processNull(onerow.get("NOTE")));
					result.add(vo);
				}
			}
			model.setRows(result);
			model.setTotal(Long.valueOf(merchantMangerService.findOnlyFieldBySql("select count(1)"+hql)+""));
			OutputJson(model);
			
		}catch(Exception e){
			model.setStatus(1);
			model.setErrMsg(e.getMessage());
			OutputJson(model);

		}
		return null;
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
				StlModeId id = new StlModeId();
				id.setValidDate(DateUtil.formatDate(validDate));
				merchantStlMode.setId(id);
				merchant.setMerchantState("0");
				if(!merchantStlMode.getId().getValidDate().after(DateUtil.formatDate(merchantMangerService.getClrDate()))){
					throw new CommonException("生效日期必须在当前日期之后");
				}
				if(!merchantMangerService.checkBiz_Name(merchant.getMerchantName().trim())){//不存在同名的商户则进行新增
					actionLog.setMessage("添加商户");
					actionLog.setDealCode(DealCode.MERCHANT_ACC_ADD);
					String returnMsg = merchantMangerService.saveMer(merchant,actionLog,merchantMangerService.getUser(),mer_old,merchantStlMode);
					merchant = new BaseMerchant();
					merchantStlMode = new StlMode();
					messages = "新增商户信息成功";
					if(returnMsg.indexOf("addsuccess")==-1){
						messages = messages + "，但是建立ftp目录出错,请检查!";
					}
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
					merchant.setMerchantState("0");
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
			json.setMessage(messages);
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
	public String toQueryMerComsumeKind(){
		GridModel model = new GridModel();
		try{
			//1.组装查询语句
			String sql = " select t.merchant_id, "+
					     " decode(sum(decode(t.acc_kind, '01', acc_kind, null)),1,'01','')  qbzh, "+
					     " decode(sum(decode(t.acc_kind, '02', acc_kind, null)),2,'02','')  ljzh, "+
					     " decode(sum(decode(t.acc_kind, '06', acc_kind, null)),6,'06','')  zyzh"+ 
					     " from pay_merchant_acctype t ";
			if(!Tools.processNull(this.merchantId).equals("")){
				sql += " and t.merchant_id = '" + this.merchantId + "'";
			}
			sql+=" group by t.merchant_id order by t.merchant_id ";
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
					MerConsumeAccKindView vo = new MerConsumeAccKindView();
					vo.setMerchantId(onerow[0]+"");
					vo.setMerchantName((String)merchantMangerService.findOnlyFieldBySql("select merchant_name from base_merchant where merchant_id='"+(onerow[0]+"")+"'"));
					vo.setAcc_kindQB(Tools.processNull(onerow[1]));
					vo.setAcc_kindLJ(Tools.processNull(onerow[2]));
					vo.setAcc_kindZY(Tools.processNull(onerow[3]));
					String acckids ="";
					if(!Tools.processNull(onerow[1]).equals("")){
						acckids+=merchantMangerService.getCodeNameBySYS_CODE("ACC_KIND", onerow[1]+"")+",";
					}
					if(!Tools.processNull(onerow[2]).equals("")){
						acckids+=merchantMangerService.getCodeNameBySYS_CODE("ACC_KIND", onerow[2]+"")+",";
					}
					if(!Tools.processNull(onerow[3]).equals("")){
						acckids+=merchantMangerService.getCodeNameBySYS_CODE("ACC_KIND", onerow[3]+"");
					}
					if(acckids.endsWith(",")){
						acckids = acckids.substring(0, acckids.length()-1);
					}
					vo.setAcc_kindName(acckids);
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
	/**
	 * 商户关联保存
	 * @return
	 */
	public String saveMerchantConAccKind(){
		Json json = new Json();
		String messages="";
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(merchantMangerService.getSysBranchByUserId().getBrchId());
			if(typeDeal.equals("0")){
				actionLog.setMessage("新增商户账户关联");
			}else{
				actionLog.setMessage("编辑商户账户关联");
			}
			String accKinds ="";
			if(!acc_kindQB.equals("")){
				accKinds+=acc_kindQB+",";
			}
			if(!acc_kindLJ.equals("")){
				accKinds+=acc_kindLJ+",";
			}
			if(!acc_kindZY.equals("")){
				accKinds+=acc_kindZY;
			}
			if(accKinds.endsWith(",")){
				accKinds  = accKinds.substring(0, accKinds.length()-1);
			}
			merchantMangerService.saveMerchantConsLmt(accKinds, merchantId,
					actionLog);
			typeDeal="0";
			messages = "商户账户关联成功";
			json.setStatus(true);
			json.setTitle("商户账户关联设置");
			json.setMessage(messages);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setTitle("商户账户关联设置");
			json.setMessage(messages);
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
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
			if(this.queryType.equals("0")){
			  String head = "select t1.end_id,t1.end_name,t1.end_type,t1.end_state,t1.psam_no,"+
					  		"t1.login_flag,t1.login_time,t2.merchant_name ";
				StringBuffer sql = new StringBuffer(" from base_tag_end t1,base_merchant t2 where " +
							" t1.own_id  = t2.merchant_id(+)" );		
				if(!Tools.processNull(endId).equals("")){
					sql.append(" and t1.end_Id = '").append(endId.trim()).append("'");
				}
				if(!Tools.processNull(merchantId).equals("")){
					sql.append(" and t1.own_Id = '").append(merchantId).append("' ");
				}
				if(!Tools.processNull(endState).equals("")){
					sql.append(" and t1.end_State = '").append(endState.trim()).append("' ");
				}
				if(!Tools.processNull(sort).equals("")){
					sql.append(" order by " + sort + " " + order + " ");
				}else{
					sql.append(" order by t1.end_id  desc");
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
	
	public String toAddMerTerm(){
		try {
			tagEnd = new BaseTagEnd();
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toAddMerTerm";
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
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealTime(merchantMangerService.getDateBaseTime());
			if(Tools.processNull(tagEnd.getEndId()).equals("")){
				actionLog.setDealCode(DealCode.TERMINAL_ADD);
				tagEnd.setRegUserId( merchantMangerService.getUser().getUserId());
				tagEnd.setRegDate(merchantMangerService.getDateBaseDate());
				tagEnd.setLoginFlag("0");
			}else{
				actionLog.setDealCode(DealCode.TERMINAL_EDIT);
			}
			merchantMangerService.saveMerTerm(tagEnd,actionLog,merchantMangerService.getUser());
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
					throw new CommonException("根据指定信息未查询到对应商户结算模式信息！");
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
	 * 状态管理
	 * @return
	 */
	public String updateState(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			merchantMangerService.updateState(merchant.getCustomerId(),baseService.getUser(),baseService.getCurrentActionLog(),queryType);
			jsonObject.put("status","0");
			String string = "";
			if(Tools.processNull(queryType).equals("0")){
				string = "审核";
			}else if(Tools.processNull(queryType).equals("1")){
				string = "注销";
			}else if(Tools.processNull(queryType).equals("2")){
				string = "待审核";
			}else if(Tools.processNull(queryType).equals("3")){
				string = "暂停";
			}else if(Tools.processNull(queryType).equals("9")){
				string = "审核不通过";
			}else{
			}
			jsonObject.put("status","0");
			jsonObject.put("msg",string + "商户信息成功！");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String viewMerchantConsumeInfos(){
		try {
			jsonObject.put("rows",new JSONArray());
			jsonObject.put("total",0);
			jsonObject.put("status",0);
			jsonObject.put("errMsg",0);
			//根据结算编号查询出清分的开始时间和结束
			List clrNolist = merchantMangerService.findBySql("select min(clr_date) ,max(clr_date) from pay_clr_sum t "
					+ " where t.stl_sum_no ='"+stlSumNo+"'");
			//查询clrNo
			List clrNoListinfo = merchantMangerService.findBySql("select clr_no from pay_clr_sum t where t.stl_sum_no ='"+stlSumNo+"'");
			if(clrNolist == null){
				throw new CommonException("未查询到清分信息.");
			}
			Object[] objclr = (Object[])clrNolist.get(0);
			String tableName = "acc_inout_detail";
			String sql = "select t.acpt_id, m.merchant_name, t.user_id, t2.end_name, "
					+ "to_char(t.db_acc_bal/100, '9999999990.00') db_acc_bal, "
					+ "(select code_name from sys_code where code_type = 'ACC_KIND' "
					+ "and code_value = t.db_acc_kind) acc_kind_name, "
					+ "to_char(t.db_amt/100, '9999999990.00') db_amt, t.db_card_no, "
					+ "to_char(t.deal_date, 'yyyy-mm-dd hh24:mi:ss') deal_date, t.clr_date, "
					+ "t.deal_code, tr.deal_code_name, t.end_deal_no, t.deal_no, t.clr_no "
					+ "from " + tableName + " t "
					+ "join base_merchant m on t.acpt_id = m.merchant_id "
					+ "join BASE_TAG_END t2 on t.user_id = t2.end_id "
					+ "join sys_code_tr tr on t.deal_code = tr.deal_code "
					+ "where t.acpt_type = '0' and t.clr_date >= '" + objclr[0] 
					+ "' and t.clr_date <= '" + objclr[1] + "' and t.deal_state in ('0','3') ";
			
			List<String> months = getMonths(Tools.processNull(objclr[0]), Tools.processNull(objclr[1]));
			String querySql = "";
			String union = " union all ";
			for (String month : months) {
				querySql += union + sql.replaceFirst(tableName, tableName + "_" + month);
			}
			querySql = "select * from (" + querySql.substring(union.length()) + ") ";
			if(clrNoListinfo != null){
				querySql += " where clr_no in ("+Tools.getConcatStrFromList(clrNoListinfo, "'", ",")+")";
			}
			if(!Tools.processNull(sort).equals("")){
				querySql += " order by " + sort;
				if(!Tools.processNull(order).equals("")){
					querySql += " " + order;
				}
			}
			Page pageData = merchantMangerService.pagingQuery(querySql, page, rows);
			Object[] normolMsg = (Object[])merchantMangerService.findOnlyRowBySql("select count(1),nvl(sum(to_number(db_amt,'9999999990.00')),0) from ("+ querySql +") where deal_code<>'"
					+DealCode.ONLINE_CONSUME_RETURN+"'");
			Object[] returnMsg = (Object[])merchantMangerService.findOnlyRowBySql("select count(1),nvl(sum(to_number(db_amt,'9999999990.00')),0) from ("+ querySql +") where deal_code='"
					+DealCode.ONLINE_CONSUME_RETURN+"'");
			
			if(normolMsg != null){
				clrSumMessage += "正常交易笔数："+normolMsg[0]+",正常交易金额："+normolMsg[1]; 
			}else{
				clrSumMessage += "正常交易笔数："+0+",正常交易金额："+0.00;
			}
			if(returnMsg != null){
				clrSumMessage += ",退货交易笔数："+returnMsg[0]+",退货交易金额："+returnMsg[1];
			}else{
				clrSumMessage += ",退货交易笔数："+0+",退货交易金额："+0.00;
			}
			if (pageData == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommonException("没有数据.");
			}
			jsonObject.put("total", pageData.getTotalCount());
			jsonObject.put("rows", pageData.getAllRs());
			jsonObject.put("clrSumMessage", clrSumMessage);
		} catch (Exception e) {
			throw new CommonException("预览商户交易明细出错："+e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 查询商户交易明细
	 * Description <p>TODO</p>
	 * @return
	 */
	public String queryMerchantTradeInfos() {
		try {
			jsonObject.put("rows",new JSONArray());
			jsonObject.put("total",0);
			jsonObject.put("status",0);
			jsonObject.put("errMsg",0);
			
			if (Tools.processNull(clrStartDateStr).equals("")) {
				throw new CommonException("清分起始时间不能为空.");
			} else if (Tools.processNull(clrEndDateStr).equals("")) {
				throw new CommonException("清分结束时间不能为空.");
			} else if (clrStartDateStr.compareTo(clrEndDateStr) > 0) {
				throw new CommonException("清分起始时间不能大于清分结束时间.");
			}
			
			String tableName = "acc_inout_detail";
			
			String sqlHead = "select t.acpt_id, m.merchant_name, t.user_id, t2.end_name, "
					+ "to_char(t.db_acc_bal/100, '9999999990.00') db_acc_bal, "
					+ "(select code_name from sys_code where code_type = 'ACC_KIND' "
					+ "and code_value = t.db_acc_kind) acc_kind_name, "
					+ "to_char(t.db_amt/100, '9999999990.00') db_amt, t.db_card_no, "
					+ "to_char(t.deal_date, 'yyyy-mm-dd hh24:mi:ss') deal_date, t.clr_date, "
					+ "t.deal_code, tr.deal_code_name, t.end_deal_no, t.deal_no, t.clr_no ";
			String sql = "select * from " + tableName + " ";
			
			String sqlWhere = "BASE_TAG_END t2,base_merchant m,sys_code_tr tr "
					+ " where t.user_id =  t2.end_id(+)  and t.acpt_id =  m.merchant_id(+) and t.deal_code = tr.deal_code(+)  and t.acpt_type = '0' and t.clr_date >= '" + clrStartDateStr 
					+ "' and t.clr_date <= '" + clrEndDateStr + "' and t.deal_code <> '10202130' ";
			if (!Tools.processNull(merchantId).equals("")) {
				sqlWhere += "and t.acpt_id like '" + merchantId + "' ";
			}
			if (!Tools.processNull(tagId).equals("")) {
				sqlWhere += "and t.user_id = '" + tagId + "' ";
			}
			if (!Tools.processNull(dealBatchNo).equals("")) {
				sqlWhere += "and t.deal_batch_no = '" + dealBatchNo + "' ";
			}
			if (!Tools.processNull(endDealNo).equals("")) {
				sqlWhere += "and t.end_deal_no = '" + endDealNo + "' ";
			}
			if (!Tools.processNull(cardNo).equals("")) {
				sqlWhere += "and t.db_card_no = '" + cardNo + "' ";
			}
			if (!Tools.processNull(dealNo).equals("")) {
				sqlWhere += "and t.deal_no = '" + dealNo + "' ";
			}
			if (!Tools.processNull(trStartDate).equals("")) {
				sqlWhere += "and t.deal_date >= to_date('" + trStartDate + "', 'yyyy-mm-dd') ";
			}
			if (!Tools.processNull(trEndDate).equals("")) {
				sqlWhere += "and t.deal_date <= to_date('" + trEndDate + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			if (!Tools.processNull(trName).equals("")) {
				sqlWhere += "and tr.deal_code = '" + trName + "'";
			}
			
			List<String> months = getMonths(clrStartDateStr, clrEndDateStr);
			
			String querySql = "";
			
			String union = " union all ";
			
			for (String month : months) {
				querySql += union + sql.replaceFirst(tableName, tableName + "_" + month);
			}
			
			querySql = sqlHead + " from (" + querySql.substring(union.length()) + ") t, " + sqlWhere;
			
			if(!Tools.processNull(sort).equals("")){
				querySql += " order by " + sort;
				
				if(!Tools.processNull(order).equals("")){
					querySql += " " + order;
				}
			}
			
			Page pageData = merchantMangerService.pagingQuery(querySql, page, rows);
			
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
	
	//
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
	
	public String exportMerchantTradeInfos(){
		try {
			queryMerchantTradeInfos();
			JSONArray list = jsonObject.getJSONArray("rows");
			
			// 导出
			String fileName = (merchant != null && merchant.getMerchantName() != null ? merchant.getMerchantName() + "_" : "") + "商户交易明细_(" + clrStartDateStr + " ~ " + clrEndDateStr + ")";
			response.setContentType("application/ms-excel;charset=utf-8");
			String userAgent = request.getHeader("user-agent");
			if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
				response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
			} else {
				response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			}
			OutputStream output = response.getOutputStream();

			WritableWorkbook wwb = Workbook.createWorkbook(output);
			WritableSheet sheet1 = wwb.createSheet("Sheet0", 0);
			sheet1.setColumnView(0, 6);
			sheet1.setColumnView(1, 17);
			sheet1.setColumnView(2, 30);
			sheet1.setColumnView(3, 10);
			sheet1.setColumnView(4, 15);
			sheet1.setColumnView(5, 22);
			sheet1.setColumnView(6, 10);
			sheet1.setColumnView(7, 22);
			sheet1.setColumnView(8, 10);
			sheet1.setColumnView(9, 12);
			sheet1.setColumnView(10, 20);
			sheet1.setColumnView(11, 12);
			sheet1.setColumnView(12, 10);
			sheet1.setColumnView(13, 13);

			// title
			WritableCellFormat titleCellFormat = new WritableCellFormat();
			titleCellFormat.setAlignment(Alignment.CENTRE);
			titleCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			WritableFont titleFontRecord = new WritableFont(WritableFont.ARIAL, 10, WritableFont.BOLD);
			titleCellFormat.setFont(titleFontRecord);
			titleCellFormat.setBackground(Colour.GREY_25_PERCENT);
			
			sheet1.mergeCells(0, 0, 13, 0);
			sheet1.mergeCells(0, 1, 13, 1);
			Label labelHead = new Label(0, 0, fileName);
			labelHead.setCellFormat(titleCellFormat);
			sheet1.addCell(labelHead);

			// head
			WritableCellFormat headCellFormat = new WritableCellFormat();
			headCellFormat.setAlignment(Alignment.CENTRE);
			headCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			WritableFont fontRecord = new WritableFont(WritableFont.ARIAL, 10, WritableFont.BOLD);
			headCellFormat.setFont(fontRecord);
			
			Label labelHead01 = new Label(0, 1, "清分时间：" + clrStartDateStr + " ~ " + clrEndDateStr + "    导出时间：" + DateUtils.getNowTime());
			labelHead01.setCellFormat(titleCellFormat);
			sheet1.addCell(labelHead01);
			
			Label labelHead0 = new Label(0, 2, "");
			Label labelHead1 = new Label(1, 2, "商户号");
			Label labelHead2 = new Label(2, 2, "商户名称");
			Label labelHead3 = new Label(3, 2, "终端号");
			Label labelHead4 = new Label(4, 2, "终端名称");
			Label labelHead5 = new Label(5, 2, "卡号");
			Label labelHead6 = new Label(6, 2, "交易前金额");
			Label labelHead7 = new Label(7, 2, "交易时间");
			Label labelHead8 = new Label(8, 2, "交易金额");
			Label labelHead9 = new Label(9, 2, "清分日期");
			Label labelHead10 = new Label(10, 2, "交易名称");
			Label labelHead11 = new Label(11, 2, "终端交易流水");
			Label labelHead12 = new Label(12, 2, "中心流水");
			Label labelHead13 = new Label(13, 2, "是否结算标志");
			
			labelHead0.setCellFormat(titleCellFormat);
			labelHead1.setCellFormat(titleCellFormat);
			labelHead2.setCellFormat(titleCellFormat);
			labelHead3.setCellFormat(titleCellFormat);
			labelHead4.setCellFormat(titleCellFormat);
			labelHead5.setCellFormat(titleCellFormat);
			labelHead6.setCellFormat(titleCellFormat);
			labelHead7.setCellFormat(titleCellFormat);
			labelHead8.setCellFormat(titleCellFormat);
			labelHead9.setCellFormat(titleCellFormat);
			labelHead10.setCellFormat(titleCellFormat);
			labelHead11.setCellFormat(titleCellFormat);
			labelHead12.setCellFormat(titleCellFormat);
			labelHead13.setCellFormat(titleCellFormat);
			
			sheet1.addCell(labelHead0);
			sheet1.addCell(labelHead1);
			sheet1.addCell(labelHead2);
			sheet1.addCell(labelHead3);
			sheet1.addCell(labelHead4);
			sheet1.addCell(labelHead5);
			sheet1.addCell(labelHead6);
			sheet1.addCell(labelHead7);
			sheet1.addCell(labelHead8);
			sheet1.addCell(labelHead9);
			sheet1.addCell(labelHead10);
			sheet1.addCell(labelHead11);
			sheet1.addCell(labelHead12);
			sheet1.addCell(labelHead13);

			// body
			WritableCellFormat whiteCellFormat = new WritableCellFormat();
			whiteCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			WritableCellFormat stripedCellFormat = new WritableCellFormat();
			stripedCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			stripedCellFormat.setBackground(Colour.GRAY_25);
			
			WritableCellFormat whiteAmtCellFormat = new WritableCellFormat();
			whiteAmtCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			whiteAmtCellFormat.setAlignment(Alignment.RIGHT);
			WritableCellFormat stripedAmtCellFormat = new WritableCellFormat();
			stripedAmtCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
			stripedAmtCellFormat.setAlignment(Alignment.RIGHT);
			stripedAmtCellFormat.setBackground(Colour.GRAY_25);
			
			for (int i = 0; i < list.size(); i++) {
				WritableCellFormat rowCellFormat = whiteCellFormat;
				WritableCellFormat rowAmtCellFormat = whiteAmtCellFormat;
//				if (i % 2 == 0) {
//					rowCellFormat = WhiteCellFormat;
//				} else {
//					rowCellFormat = new WritableCellFormat();
//					rowCellFormat.setBorder(Border.ALL, BorderLineStyle.THIN);
//					rowCellFormat.setBackground(Colour.GRAY_25);
//				}
				JSONObject records = list.getJSONObject(i);
				
				Label label0 = new Label(0, i + 3, i + 1 + "");
				Label label1 = new Label(1, i + 3, Tools.processNull(records.getString("ACPT_ID")));
				Label label2 = new Label(2, i + 3, Tools.processNull(records.getString("MERCHANT_NAME")));
				Label label3 = new Label(3, i + 3, Tools.processNull(records.getString("USER_ID")));
				Label label4 = new Label(4, i + 3, Tools.processNull(records.getString("END_NAME")));
				Label label5 = new Label(5, i + 3, Tools.processNull(records.getString("DB_CARD_NO")));
				Label label6 = new Label(6, i + 3, Tools.processNull(records.getString("DB_ACC_BAL")));
				Label label7 = new Label(7, i + 3, Tools.processNull(records.getString("DEAL_DATE")));
				Label label8 = new Label(8, i + 3, Tools.processNull(records.getString("DB_AMT")));
				Label label9 = new Label(9, i + 3, Tools.processNull(records.getString("CLR_DATE")));
				Label label10 = new Label(10, i + 3, Tools.processNull(records.getString("DEAL_CODE_NAME")));
				Label label11 = new Label(11, i + 3, Tools.processNull(records.getString("END_DEAL_NO")));
				Label label12 = new Label(12, i + 3, Tools.processNull(records.getString("DEAL_NO")));
				Label label13 = new Label(13, i + 3, Tools.processNull(records.getString("CLR_NO")).equals("")?"否":"是");
				

				label0.setCellFormat(rowCellFormat);
				label1.setCellFormat(rowCellFormat);
				label2.setCellFormat(rowCellFormat);
				label3.setCellFormat(rowCellFormat);
				label4.setCellFormat(rowCellFormat);
				label5.setCellFormat(rowCellFormat);
				label6.setCellFormat(rowAmtCellFormat);
				label7.setCellFormat(rowCellFormat);
				label8.setCellFormat(rowAmtCellFormat);
				label9.setCellFormat(rowCellFormat);
				label10.setCellFormat(rowCellFormat);
				label11.setCellFormat(rowCellFormat);
				label12.setCellFormat(rowCellFormat);
				label13.setCellFormat(rowCellFormat);

				sheet1.addCell(label0);
				sheet1.addCell(label1);
				sheet1.addCell(label2);
				sheet1.addCell(label3);
				sheet1.addCell(label4);
				sheet1.addCell(label5);
				sheet1.addCell(label6);
				sheet1.addCell(label7);
				sheet1.addCell(label8);
				sheet1.addCell(label9);
				sheet1.addCell(label10);
				sheet1.addCell(label11);
				sheet1.addCell(label12);
				sheet1.addCell(label13);
			}

			wwb.write();
			wwb.close();
			output.flush();
			output.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportMerchantTradeInfos",Constants.YES_NO_YES);
		} catch (CommonException e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", "导出失败, " + e.getMessage());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", "导出失败, 系统异常[" + e.getMessage() + "]");
		}
		
		return JSONOBJ;
	}
	
	public String queryMerOffLineRefData(){
		try {
			initBaseDataGrid();
			String dealNoSql = "";
			if(!Tools.processNull(expid).equals("")){
				String[] dealNoArr = expid.split("\\|");
				if(dealNoArr.length > 0){
					for(String dealNo:dealNoArr){
						dealNoSql += "'" + dealNo + "',";
					}
				}
				if(dealNoSql.length() > 0) {
					dealNoSql = dealNoSql.substring(0, dealNoSql.length() - 1);
				}
			}
			String sql = "select t.acpt_id, t2.merchant_name, t.card_no, '01' acc_kind, t.acc_bal, t.deal_amt, t.deal_date, "
					+ "(select deal_code_name from sys_code_tr where deal_code = t.deal_code) deal_code_name, t.end_id, t.deal_no, "
					+ "t.end_deal_no, t.refuse_reason  from pay_offline_black t join base_merchant t2 on t.acpt_id = t2.merchant_id "
					+ "where 1 = 1 ";
			if(!Tools.processNull(dealNoSql).equals("")){
				sql += "and t.deal_no in (" + dealNoSql + ") ";
			}
			if (!Tools.processNull(merchantId).equals("")) {
				sql += "and t.acpt_id = '" + merchantId + "' ";
			}
			if (!Tools.processNull(tagId).equals("")) {
				sql += "and t.end_id = '" + tagId + "' ";
			}
			if (!Tools.processNull(endDealNo).equals("")) {
				sql += "and t.end_deal_no = '" + endDealNo + "' ";
			}
			if (!Tools.processNull(cardNo).equals("")) {
				sql += "and t.card_no = '" + cardNo + "' ";
			}
			if (!Tools.processNull(trStartDate).equals("")) {
				sql += "and t.deal_date >= '" + trStartDate.replaceAll("-", "") + "000000' ";
			}
			if (!Tools.processNull(trEndDate).equals("")) {
				sql += "and t.deal_date <= '" + trEndDate.replaceAll("-", "") + "235959' ";
			}
			if (!Tools.processNull(trName).equals("")) {
				sql += "and tr.deal_code = '" + trName + "' ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort;
				
				if(!Tools.processNull(order).equals("")){
					sql += " " + order;
				}
			} else {
				sql += "order by t.deal_date desc";
			}
			Page pageData = merchantMangerService.pagingQuery(sql, page, rows);
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
	
	public String exportMerOffLineRefData() {
		try {
			rows = 65500;
			queryMerOffLineRefData();
			JSONArray data = (JSONArray) jsonObject.get("rows");
			
			//
			String fileName = "商户消费拒付数据";
			response.setContentType("application/ms-excel;charset=utf-8");
			String userAgent = request.getHeader("user-agent");
			if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
				response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
			} else {
				response.setHeader("Content-disposition", "attachment; filename=" + new String((fileName).getBytes(), "iso8859-1") + ".xls");
			}

			// workbook
			org.apache.poi.ss.usermodel.Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);

			sheet.setColumnWidth(0, 5500);
			sheet.setColumnWidth(1, 7500);
			sheet.setColumnWidth(2, 6000);
			sheet.setColumnWidth(3, 3500);
			sheet.setColumnWidth(4, 3500);
			sheet.setColumnWidth(5, 6000);
			sheet.setColumnWidth(6, 5000);
			sheet.setColumnWidth(7, 3000);
			sheet.setColumnWidth(8, 4000);
			sheet.setColumnWidth(9, 4000);

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
			// headCellStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
			// headCellStyle.setFillForegroundColor(HSSFColor.LEMON_CHIFFON.index);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);

			// head row 1
			int maxColumn = 10;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}

			sheet.getRow(0).getCell(0).setCellValue(fileName);
			sheet.getRow(1).getCell(0).setCellValue("交易时间：" + trStartDate + " ~ " + trEndDate + "    导出时间：" + DateUtil.formatDate(new Date()));
			// third header
			sheet.getRow(2).getCell(0).setCellValue("商户号");
			sheet.getRow(2).getCell(1).setCellValue("商户名称");
			sheet.getRow(2).getCell(2).setCellValue("卡号");
			sheet.getRow(2).getCell(3).setCellValue("交易前金额");
			sheet.getRow(2).getCell(4).setCellValue("交易金额");
			sheet.getRow(2).getCell(5).setCellValue("交易时间");
			sheet.getRow(2).getCell(6).setCellValue("交易类型");
			sheet.getRow(2).getCell(7).setCellValue("终端编号");
			sheet.getRow(2).getCell(8).setCellValue("终端交易流水");
			sheet.getRow(2).getCell(9).setCellValue("拒付原因");

			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(2, headRows);
			
			// data
			double sumAmt = 0;
			for (int i = 0; i < data.size(); i++) {
				// cell
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if(j == 3 || j == 4) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				// data
				JSONObject item = data.getJSONObject(i);
				row.getCell(0).setCellValue(item.getString("ACPT_ID"));
				row.getCell(1).setCellValue(item.getString("MERCHANT_NAME"));
				row.getCell(2).setCellValue(item.getString("CARD_NO"));
				//
				double accBal = item.getDoubleValue("ACC_BAL");
				row.getCell(3).setCellValue(accBal / 100);
				//
				double dealAmt = item.getDoubleValue("DEAL_AMT");
				sumAmt += dealAmt;
				row.getCell(4).setCellValue(dealAmt / 100);
				//
				String dealDate = item.getString("DEAL_DATE");
				row.getCell(5).setCellValue(dealDate.substring(0,4) + "-" + dealDate.substring(4,6) + "-" + dealDate.substring(6,8) + " " + dealDate.substring(8,10) + ":" + dealDate.substring(10,12) + ":" + dealDate.substring(12,14));
				//
				row.getCell(6).setCellValue(item.getString("DEAL_CODE_NAME"));
				row.getCell(7).setCellValue(item.getString("END_ID"));
				row.getCell(8).setCellValue(item.getString("END_DEAL_NO"));
				//
				String refuseReason = item.getString("REFUSE_REASON");
				if (refuseReason.equals("00")) {
					refuseReason = "卡片发行方调整";
				} else if (refuseReason.equals("01")) {
					refuseReason = "TAC码错误";
				} else if (refuseReason.equals("02")) {
					refuseReason = "数据非法";
				} else if (refuseReason.equals("03")) {
					refuseReason = "数据重复";
				} else if (refuseReason.equals("04")) {
					refuseReason = "灰记录";
				} else if (refuseReason.equals("05")) {
					refuseReason = "金额不足";
				} else if (refuseReason.equals("06")) {
					refuseReason = "测试数据";
				} else if (refuseReason.equals("07")) {
					refuseReason = "交易时间不正确";
				} else if (refuseReason.equals("09")) {
					refuseReason = "拒付调整";
				} else if (refuseReason.equals("64")) {
					refuseReason = "异地卡消费数据";
				} else {
					refuseReason = "其它【" + refuseReason + "】";
				}
				row.getCell(9).setCellValue(refuseReason);
			}
			
			//
			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				if (j == 3 || j == 4) {
					cell.setCellStyle(moneyCellStyle);
				} else {
					cell.setCellStyle(cellStyle);
				}
			}
			row.getCell(1).setCellValue("统计：");
			row.getCell(2).setCellValue("共 " + data.size() + " 条记录");
			row.getCell(4).setCellValue(sumAmt / 100);

			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportMerOffLineRefData",Constants.YES_NO_YES);
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	//TODO
	
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
	

	
	@Autowired
	public void setMerchantMangerService(MerchantMangerService merchantMangerService) {
		this.merchantMangerService = merchantMangerService;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getTagId() {
		return tagId;
	}

	public void setTagId(String tagId) {
		this.tagId = tagId;
	}

	public String getTagName() {
		return tagName;
	}

	public void setTagName(String tagName) {
		this.tagName = tagName;
	}

	public String getDealBatchNo() {
		return dealBatchNo;
	}

	public void setDealBatchNo(String dealBatchNo) {
		this.dealBatchNo = dealBatchNo;
	}

	public String getEndDealNo() {
		return endDealNo;
	}

	public void setEndDealNo(String endDealNo) {
		this.endDealNo = endDealNo;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getDealNo() {
		return dealNo;
	}

	public void setDealNo(String dealNo) {
		this.dealNo = dealNo;
	}

	public String getTrStartDate() {
		return trStartDate;
	}

	public void setTrStartDate(String trStartDate) {
		this.trStartDate = trStartDate;
	}

	public String getTrEndDate() {
		return trEndDate;
	}

	public void setTrEndDate(String trEndDate) {
		this.trEndDate = trEndDate;
	}

	public String getTrName() {
		return trName;
	}

	public void setTrName(String trName) {
		this.trName = trName;
	}

	public MerchantMangerService getMerchantMangerService() {
		return merchantMangerService;
	}

	public String getClrStartDateStr() {
		return clrStartDateStr;
	}

	public void setClrStartDateStr(String clrStartDateStr) {
		this.clrStartDateStr = clrStartDateStr;
	}

	public String getClrEndDateStr() {
		return clrEndDateStr;
	}

	public void setClrEndDateStr(String clrEndDateStr) {
		this.clrEndDateStr = clrEndDateStr;
	}

	public String getExpid() {
		return expid;
	}

	public void setExpid(String expid) {
		this.expid = expid;
	}

	public String getStlSumNo() {
		return stlSumNo;
	}

	public void setStlSumNo(String stlSumNo) {
		this.stlSumNo = stlSumNo;
	}

	/**
	 * @return the clrSumMessage
	 */
	public String getClrSumMessage() {
		return clrSumMessage;
	}

	/**
	 * @param clrSumMessage the clrSumMessage to set
	 */
	public void setClrSumMessage(String clrSumMessage) {
		this.clrSumMessage = clrSumMessage;
	}
	
	
}
