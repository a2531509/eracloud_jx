package com.erp.action;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.BaseMerchant;
import com.erp.model.PayFeeRate;
import com.erp.model.PayFeeRateSection;
import com.erp.model.PayFeeRateSectionId;
import com.erp.model.StlMode;
import com.erp.model.StlModeId;
import com.erp.model.SysActionLog;
import com.erp.service.MerchantMangerService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.Sys_Code;
import com.erp.util.Tools;
import com.erp.util.DealCode;
import com.erp.viewModel.Json;
import com.erp.viewModel.Page;

@SuppressWarnings("serial")
@Namespace("/merchantRate")
@Action("merchantRateAction")
@Results({@Result(type="json",name="json"),
	@Result(name="viewMerchantRate",location="/jsp/merchant/merchantRateViewInfo.jsp"),
	@Result(name="toAddMerchantRate",location="/jsp/merchant/merchantRateAdd.jsp"),
	@Result(name="toEidtMerchantRate",location="/jsp/merchant/merchantRateEditDlg.jsp")})
@InterceptorRef("jsondefalut")
public class MerchantRateAction extends BaseAction {
	private String sort="";
	private String order="";
	private String selectRateid="";
	private String queryType="1";
	private String max="";
	private String min="";
	private String fee_Rate = "";
	private MerchantMangerService merchantMangerService;
	
	private String merchantId;
	private String trCode;
	private String chkState;
	
	private String merchantName;
	
	private String fee_State;
	private String fee_Type;
	private String in_Out;
	private String have_Section;
	private String tr_Code;
	private String fee_rate;
	
	private String section_Nums = "";
	private String  fee_Rates = "";
	
	private String dealType="";
	
	private PayFeeRate  payFeeRate;
	private BaseMerchant merchant;
	private PayFeeRateSection rateSection;
	private List<PayFeeRateSection> list = new ArrayList<PayFeeRateSection>();
	
	@Autowired
	public void setMerchantMangerService(MerchantMangerService merchantMangerService) {
		this.merchantMangerService = merchantMangerService;
	}
	
	/**
	 * 查询商户费率信息
	 * @return
	 */
	public String queryMerRateInfo(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg",0);
		Long total=0l;
		try {
			if(this.queryType.equals("0")){
			  String head = "SELECT c.FEE_RATE_ID RateID,m.merchant_id,"+
							"m.merchant_name,c.deal_code||'-'||d.deal_code_Name tr_code," +
							"c.fee_type,c.fee_state,c.have_section,nvl(c.fee_rate/10000,0) feerate," +
							"to_char(c.insert_date,'yyyy-mm-dd hh24:mi:ss') insert_date,(select name from Sys_users where user_id=c.user_id ) oper," + 
							"to_char(c.beginDate,'yyyy-mm-dd') beginDate,c.chk_State,(select name from Sys_users where user_id=c.chk_user_id ) sh_Oper," + 
							"to_char(c.chk_Date,'yyyy-mm-dd hh24:mi:ss') chk_Date,c.note"; 
				
				StringBuffer sql = new StringBuffer(" from base_merchant m,pay_fee_rate c,sys_code_tr d where " +
						" m.merchant_id(+) = c.merchant_id and c.deal_code=d.deal_code(+) and m.merchant_state="+Sys_Code.MERCHANT_STATE_ZC );		
				if(!Tools.processNull(merchantId).equals("")){
					sql.append(" and m.merchant_id = '").append(merchantId.trim()).append("' ");
				}
				if(!Tools.processNull(trCode).equals("")){
					sql.append(" and c.deal_Code = '").append(trCode).append("' ");
				}
				if(!Tools.processNull(chkState).equals("")){
					sql.append(" and c.chk_State = '").append(chkState.trim()).append("' ");
				}
				if(!Tools.processNull(sort).equals("")){
					sql.append(" order by " + sort + " " + this.getOrder());
				}
				Page pages = merchantMangerService.pagingQuery(head+sql.toString(),page, rows);
				
				
				if(pages.getAllRs() == null){
					throw new CommonException("根据指定信息未查询到指定的商户费率信息！");
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
	 * 商户费率预览
	 */
	public String viewMerchantRate(){
		try {
			payFeeRate = (PayFeeRate)merchantMangerService.findOnlyRowByHql(" from PayFeeRate c where c.feeRateId = '" + Tools.processNull(selectRateid) + "'");
			max = Arith.cardmoneydiv(payFeeRate.getFeeMax().toString());
			min = Arith.cardmoneydiv(payFeeRate.getFeeMin().toString());
			
			if(!Tools.processNull(payFeeRate.getMerchantId()).equals(""))
				merchant = (BaseMerchant) merchantMangerService.findOnlyRowByHql(" from BaseMerchant t where t.merchantId='"+ payFeeRate.getMerchantId() + "'");
				merchantName = Tools.processNull(merchant.getMerchantName());
			if(payFeeRate.getHaveSection().equals(Sys_Code.HAVE_SECTION_S)){
				list = merchantMangerService.findByHql("from PayFeeRateSection where id.feeRateId="+payFeeRate.getFeeRateId()+"");
				for (PayFeeRateSection section : list) {
					Long temp = null ;
					if(payFeeRate.getFeeType().equals(Sys_Code.FEE_RATE_TYPE_JEFL)){
						temp = section.getId().getSectionNum()/100;
					}else{
						temp = section.getId().getSectionNum();
					}
					section.getId().setSectionNum(temp);
				}
			}else{
				if(payFeeRate.getFeeType().equals("1")){
					fee_Rate =Arith.cardmoneymun(Long.parseLong(Tools.processNull(payFeeRate.getFeeRate()).equals("")?"0":Tools.processNull(payFeeRate.getFeeRate()))/100+"")+"分/笔";
				}else if(payFeeRate.getFeeType().equals("2")){
					fee_Rate =Arith.cardmoneymun(Long.parseLong(Tools.processNull(payFeeRate.getFeeRate()).equals("")?"0":Tools.processNull(payFeeRate.getFeeRate()))/100+"")+"%";
				}
//				if(!Tools.processNull(payFeeRate.getFeeRate()).equals(""))fee_Rate = Double.valueOf(payFeeRate.getFeeRate())/10000 + "";
			}
			tr_Code = payFeeRate.getDealCode()+"";
			fee_State = merchantMangerService.getCodeNameBySYS_CODE("FEE_STATE", payFeeRate.getFeeState());
			fee_Type = merchantMangerService.getCodeNameBySYS_CODE("FEE_RATE_TYPE", payFeeRate.getFeeType());
			in_Out = merchantMangerService.getCodeNameBySYS_CODE("IN_OUT_FLAG",payFeeRate.getInOut());
			have_Section = merchantMangerService.getCodeNameBySYS_CODE("HAVE_SECTION",payFeeRate.getHaveSection());
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "viewMerchantRate";
	}
	
	/**
	 * 到达商户新增
	 * @return
	 */
	public String toAddMerchantRate(){
		try {
			if(Tools.processNull(selectRateid).equals("")){
				payFeeRate = new PayFeeRate();
				merchant = new BaseMerchant();
				rateSection = new PayFeeRateSection();
			}
			// 默认最大服务费
			max = "99999999";
			// 默认最小服务费
			min = "0";
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toAddMerchantRate";
	}
	/**
	 * 到达商户编辑页面
	 * @return
	 */
	public String toEidtMerchantRate(){
		try {
			if(!Tools.processNull(selectRateid).equals("")){
				payFeeRate =(PayFeeRate)merchantMangerService.findOnlyRowByHql(" from PayFeeRate c where c.feeRateId = '" + Tools.processNull(selectRateid) + "'");
				max=Arith.cardmoneydiv(payFeeRate.getFeeMax()+"");
				min=Arith.cardmoneydiv(payFeeRate.getFeeMin()+"");
				merchant = (BaseMerchant)merchantMangerService.findOnlyRowByHql("from BaseMerchant a where a.merchantId='"+payFeeRate.getMerchantId()+"'");
				merchantName = Tools.processNull(merchant.getMerchantName());
				tr_Code = payFeeRate.getDealCode()+"";
				in_Out =payFeeRate.getInOut();
				list = merchantMangerService.findByHql("from PayFeeRateSection where id.feeRateId="+payFeeRate.getFeeRateId()+"");
			}
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toEidtMerchantRate";
	}
	/**
	 * 商户费率保存
	 * @return
	 */
	public String saveMerchantRate(){
		jsonObject.put("status","0");
		jsonObject.put("msg","");
		String messages="";
		try {
			
			SysActionLog actionLog=baseService.getCurrentActionLog();
			actionLog.setDealTime(merchantMangerService.getDateBaseTime());
			actionLog.setBrchId(merchantMangerService.getSysBranchByUserId().getBrchId());
			Long fee_Rate_Id = null;
			
			if(Tools.processNull(dealType).equals("1")){//新增
				fee_Rate_Id = Long.parseLong(merchantMangerService.getSequenceByName("SEQ_FEE_RATE_ID"));
				//payFeeRate.setFeeState(Sys_Code.FEE_STATE_TY);
				payFeeRate.setFeeRateId(Long.valueOf(fee_Rate_Id+""));
			}else{//编辑
				fee_Rate_Id =Long.parseLong(payFeeRate.getFeeRateId()+"");
				String insert_Date = DateUtil.formatDate(actionLog.getDealTime(),"yyyy-MM-dd HH:mm:ss");
				payFeeRate.setInsertDate(DateUtil.parseSqlDate("yyyy-MM-dd HH:mm:ss",insert_Date));
				payFeeRate.setUserId(merchantMangerService.getUser().getUserId());
			}
			//设置分段信息
			if(Tools.processNull(payFeeRate.getHaveSection()).equals(Sys_Code.HAVE_SECTION_S)){
				payFeeRate.setFeeRate(null);
				String[] genPara = section_Nums.split("\\,");
				String[] genValue = fee_Rates.split("\\,"); 
				int a = 0;//用来判断分段金额/笔数是否从0/1开始
				for(int i=0;i<genPara.length;i++){
					PayFeeRateSection clr_Fee_Rate_Section = new PayFeeRateSection();
					Long temp = null;
					if(!Tools.processNull(section_Nums.split(",")[i]).equals("") &&
							!Tools.processNull(fee_Rates.split(",")[i]).equals("")){
						if(payFeeRate.getFeeType().equals(Sys_Code.FEE_RATE_TYPE_JEFL)){
							temp = new Long(section_Nums.split(",")[i]);
							if(temp==0){
								a++;
							}
						}else{
							temp = new Long(section_Nums.split(",")[i])*100;
							if(temp==1){
								a++;
							}
						}
						clr_Fee_Rate_Section.setFeeRate(Long.valueOf(Arith.cardmoneymun(fee_Rates.split(",")[i])));
						PayFeeRateSectionId  id = new PayFeeRateSectionId();
						id.setFeeRateId(Long.parseLong(fee_Rate_Id+""));
						id.setSectionNum(temp);
						clr_Fee_Rate_Section.setId(id);
						list.add(clr_Fee_Rate_Section);
					}
				}
				if(a==0){
					throw new CommonException("分段费率设置必须从0或1开始");
				}
			}else{
				if(payFeeRate.getFeeType().equals(Sys_Code.FEE_RATE_TYPE_JEFL)){
					payFeeRate.setFeeRate(BigDecimal.valueOf(Long.valueOf(Arith.cardmoneymun(payFeeRate.getFeeRate().toString()))));
				}else{
					payFeeRate.setFeeRate(BigDecimal.valueOf(Long.valueOf(Arith.cardmoneymun(Arith.cardmoneymun(payFeeRate.getFeeRate().toString())))));
				}
				
			}
			payFeeRate.setInOut(in_Out);
			payFeeRate.setFeeMax(BigDecimal.valueOf(Long.valueOf(Arith.cardmoneymun(max))));
			payFeeRate.setFeeMin(BigDecimal.valueOf(Long.valueOf(Arith.cardmoneymun(min))));
			payFeeRate.setDealCode(Integer.valueOf(tr_Code));
			//payFeeRate.setFeeRate(payFeeRate.getFeeRate()/10000);
			
			if(Tools.processNull(dealType).equals("1")){//新增
				actionLog.setMessage("新增商户费率预设信息");
				actionLog.setDealCode(DealCode.MERCHANT_RATE_PREINSTALL_ADD);
				merchantMangerService.saveClr_Fee_Rate(payFeeRate,actionLog,merchantMangerService.getUser(),dealType,list);
				messages="新增商户费率预设信息成功，你可以继续新增商户费率预设信息";
				//feerate = new Clr_Fee_Rate();
			}else if(Tools.processNull(dealType).equals("2")){//编辑
				
				actionLog.setMessage("编辑商户费率信息");
				actionLog.setDealCode(DealCode.MERCHANT_RATE_PREINSTALL_EDIT);
				if(payFeeRate.getChkState().equals(Sys_Code.SH_STATE_ZCYSH)){
					throw new CommonException("商户预设费率已经审核通过不能修改！");
				}
				merchantMangerService.saveClr_Fee_Rate(payFeeRate,actionLog,merchantMangerService.getUser(),dealType,list);
				messages="编辑商户费率预设信息成功";
			}else{
				throw new  CommonException("参数错误");
			}
			
			jsonObject.put("msg", messages);
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("msg", e.getMessage());
			jsonObject.put("status", "1");
		}
		return this.JSONOBJ;
	}
	/**
	 * 费率审核
	 * @return
	 */
	public String chkMerRate(){
		Json json = new Json();
		String messages="";
		try {
			//selectRateid
			PayFeeRate rate = (PayFeeRate)merchantMangerService.findOnlyRowByHql("from PayFeeRate where feeState='0' and chkState='9' and feeRateId='"+selectRateid+"'");
			if(rate==null){
				throw new CommonException("没有需要审核的费率信息，请重新选择！");
			}
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealTime(merchantMangerService.getDateBaseTime());
			actionLog.setBrchId(merchantMangerService.getSysBranchByUserId().getBrchId());
			actionLog.setDealCode(DealCode.MERCHANT_RATE_PREINSTALL_AUDIT);
			merchantMangerService.chkRate(rate, actionLog, merchantMangerService.getUser());
			json.setStatus(true);
			json.setTitle("商户费率审核");
			messages="商户费率审核成功";
			json.setMessage(messages);
			OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setTitle("商户费率审核");
			json.setMessage(e.getMessage());
			OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		}
		return null;
	}
	
	public String delRate(){
		Json json = new Json();
		String messages="";
		try {
			//selectRateid
			PayFeeRate rate = (PayFeeRate)merchantMangerService.findOnlyRowByHql("from PayFeeRate where feeState='0' and feeRateId='"+selectRateid+"'");
			if(rate==null){
				throw new CommonException("你选择商户费率信息已被删除，请重新选择！");
			}
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setDealTime(merchantMangerService.getDateBaseTime());
			actionLog.setBrchId(merchantMangerService.getSysBranchByUserId().getBrchId());
			actionLog.setDealCode(DealCode.MERCHANT_RATE_PREINSTALL_DELETE);
			merchantMangerService.delRate(rate, actionLog, merchantMangerService.getUser());
			json.setStatus(true);
			json.setTitle("商户费率删除");
			messages="商户费率删除成功";
			json.setMessage(messages);
			OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setTitle("商户费率删除");
			json.setMessage(e.getMessage());
			OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		}
		return null;
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
	public String getSelectRateid() {
		return selectRateid;
	}
	public void setSelectRateid(String selectRateid) {
		this.selectRateid = selectRateid;
	}

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}

	public String getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	public String getDealCode() {
		return trCode;
	}

	public void setDealCode(String trCode) {
		this.trCode = trCode;
	}

	public String getChkState() {
		return chkState;
	}

	public void setChkState(String chkState) {
		this.chkState = chkState;
	}

	public PayFeeRate getPayFeeRate() {
		return payFeeRate;
	}

	public void setPayFeeRate(PayFeeRate payFeeRate) {
		this.payFeeRate = payFeeRate;
	}

	public PayFeeRateSection getRateSection() {
		return rateSection;
	}

	public void setRateSection(PayFeeRateSection rateSection) {
		this.rateSection = rateSection;
	}

	public String getMax() {
		return max;
	}

	public void setMax(String max) {
		this.max = max;
	}

	public String getMin() {
		return min;
	}

	public void setMin(String min) {
		this.min = min;
	}

	public BaseMerchant getMerchant() {
		return merchant;
	}

	public void setMerchant(BaseMerchant merchant) {
		this.merchant = merchant;
	}

	public String getFee_Rate() {
		return fee_Rate;
	}

	public void setFee_Rate(String fee_Rate) {
		this.fee_Rate = fee_Rate;
	}

	public List<PayFeeRateSection> getList() {
		return list;
	}

	public void setList(List<PayFeeRateSection> list) {
		this.list = list;
	}

	public String getFee_State() {
		return fee_State;
	}

	public void setFee_State(String fee_State) {
		this.fee_State = fee_State;
	}

	public String getFee_Type() {
		return fee_Type;
	}

	public void setFee_Type(String fee_Type) {
		this.fee_Type = fee_Type;
	}

	public String getIn_Out() {
		return in_Out;
	}

	public void setIn_Out(String in_Out) {
		this.in_Out = in_Out;
	}

	public String getHave_Section() {
		return have_Section;
	}

	public void setHave_Section(String have_Section) {
		this.have_Section = have_Section;
	}

	public String getTr_Code() {
		return tr_Code;
	}

	public void setTr_Code(String tr_Code) {
		this.tr_Code = tr_Code;
	}

	public String getFee_rate() {
		return fee_rate;
	}

	public void setFee_rate(String fee_rate) {
		this.fee_rate = fee_rate;
	}

	public String getSection_Nums() {
		return section_Nums;
	}

	public void setSection_Nums(String section_Nums) {
		this.section_Nums = section_Nums;
	}

	public String getFee_Rates() {
		return fee_Rates;
	}

	public void setFee_Rates(String fee_Rates) {
		this.fee_Rates = fee_Rates;
	}

	public String getDealType() {
		return dealType;
	}

	public void setDealType(String dealType) {
		this.dealType = dealType;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}
	
	
}
