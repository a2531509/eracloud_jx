package com.erp.action;

import javax.annotation.Resource;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.AccQcqfLimit;
import com.erp.model.BasePersonal;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardBindBankCard;
import com.erp.service.BasicPersonService;
import com.erp.util.Constants;
import com.erp.util.JsonHelper;
import com.erp.util.SqlTools;
import com.erp.util.Tools;
import com.erp.viewModel.Page;


@Namespace("/queryService")
@Action(value = "personBaseAllQueryAction")
@InterceptorRefs({@InterceptorRef("jsondefalut")})
@Results({@Result(name="querBaseMxInfo",location="/jsp/cardService/cardCompQuery.jsp")})
public class PersonBaseAllQueryAction extends BaseAction {
	
	private String certType="";
	private String certNo="";
	private String cardType="";
	private String cardNo="";
	private String queryType= "1"; // 查询类型  1 不查询 0 查询
	private String sort;
	private String order;
	private String beginTime ="";
	private String endTime ="";
	
	@Resource(name="basicPersonService")
	private BasicPersonService basicPersonService;
	
	private BasePersonal personview = new BasePersonal();

	
	/**
	 * 获取个人卡信息
	 * @return
	 */
	public String querCardInfo(){
		try {
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select t1.customer_id customer_id,t1.name name,(select s1.code_name from sys_code s1 where s1.code_type = 'CERT_TYPE' and s1.code_value = t1.cert_type ) certtype,");
				sb.append("t1.cert_type cert_type,t1.cert_no,(select s2.code_name from sys_code s2 where s2.code_type = 'SEX' and s2.code_value = t1.gender ) genders,t1.gender,");
				sb.append("(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_TYPE' and s3.code_value = t2.card_type) CARDTYPE,t2.card_type, t2.sub_card_no, t2.sub_card_id, ");
				sb.append("t2.card_no card_no,(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_STATE' and s3.code_value = t2.card_state) cardstate,t2.card_state ");
				sb.append("from base_personal t1,card_baseinfo t2 where t1.customer_id =t2.customer_id ");
				if(!Tools.processNull(certType).equals("")){
					sb.append("and t1.cert_type = '" + certType + "' ");
				}
				if(!Tools.processNull(certNo).equals("")){
					sb.append("and t1.cert_no = '" + certNo + "' ");
				}
				if(!Tools.processNull(cardType).equals("")){
					sb.append("and t2.card_type = '" + cardType + "' ");
				}
				if(!Tools.processNull(cardNo).equals("")){
					sb.append("and t2.card_No = '" + cardNo + "' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("order by t1.customer_id");
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
	 * 查询账户信息
	 * @return
	 */
	public String queryAccountInfo(){
		try {
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select t1.acc_no acc_no,t2.name name,(select s1.code_name from sys_code s1 where s1.code_type = 'CERT_TYPE' and s1.code_value = t2.cert_type ) certtype,");
				sb.append("t2.cert_type cert_type,t2.cert_no,(select s2.code_name from sys_code s2 where s2.code_type = 'SEX' and s2.code_value = t2.gender ) genders,t2.gender,");
				sb.append("(select s3.code_name from sys_code s3 where s3.code_type = 'ACC_KIND' and s3.code_value = t1.acc_kind) acckind,t1.acc_kind,");
				sb.append("(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_TYPE' and s3.code_value = t3.card_type) cardtype,t3.card_type,");
				sb.append(" t1.card_no card_no,(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_STATE' and s3.code_value = t1.ACC_STATE) ACCSTATE,t1.ACC_STATE, ");
				sb.append(SqlTools.divHundred("t1.bal")+" BAL from ACC_ACCOUNT_SUB t1,base_personal t2,card_baseinfo t3 where t1.card_no =t3.card_no and t2.customer_id = t3.customer_id ");
				if(!Tools.processNull(certType).equals("")){
					sb.append("and t2.cert_type = '" + certType + "' ");
				}
				if(!Tools.processNull(certNo).equals("")){
					sb.append("and t2.cert_no = '" + certNo + "' ");
				}
				if(!Tools.processNull(cardType).equals("")){
					sb.append("and t3.card_type = '" + cardType + "' ");
				}
				if(!Tools.processNull(cardNo).equals("")){
					sb.append("and t1.card_No = '" + cardNo + "' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("order by t1.customer_id");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应的人员信息！");
				}
			}
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String querservRecInfo(){
		try {
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT t1.deal_no DEAL_NO,t1.cert_no CERT_NO,t2.name NAME,t1.card_no CARD_NO,nvl(t4.full_name, t1.brch_id) BRCH_NAME,nvl(t5.name, t1.user_id) USER_NAME,t3.deal_code_name DEAL_CODE_NAME,");
				sb.append("t1.AGT_NAME, t1.AGT_TEL_NO, (select s.code_name from sys_code s where s.code_type = 'CERT_TYPE' and s.code_value = t1.AGT_CERT_TYPE) agt_cert_type, t1.AGT_CERT_NO,");
				sb.append("t1.biz_time DEAL_TIME, to_char(t1.amt/100,'99999990.00') DEAL_AMT , decode(t1.deal_state,'0','正常','1','撤销','2','冲正','未知') DEAL_STATE from tr_serv_rec t1,base_personal t2,");
				sb.append("Sys_Code_Tr t3,Sys_Branch t4,Sys_Users t5,base_co_org t6 WHERE t1.customer_id =t2.customer_id AND t1.deal_code = t3.deal_code(+) AND t1.brch_id = ");
				sb.append("t4.brch_id(+) AND t1.user_id = t5.user_id(+) AND t1.co_org_id = t6.co_org_id(+) ");
				if(!Tools.processNull(cardNo).equals("")){
					sb.append("and exists(select 1 from card_baseinfo where card_no = '" + cardNo + "' and customer_id = t1.customer_id) ");
				}
				if(!Tools.processNull(certNo).equals("")){
					sb.append("and t1.cert_No = '" + certNo + "' ");
				}
				
				if(!Tools.processNull(beginTime).equals("")){
					sb.append("and to_char(t1.biz_time,'yyyy-mm-dd') >= '" + beginTime + "' ");
				}
				
				if(!Tools.processNull(endTime).equals("")){
					sb.append("and to_char(t1.biz_time,'yyyy-mm-dd') <= '" + endTime + "' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("order by t1.biz_time desc");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应的业务信息！");
				}
			}
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	public String querBaseMxInfo(){
		personview = null;
		try {
			if(!Tools.processNull(certNo).equals("")||!Tools.processNull(cardNo).equals("")){
				if(!Tools.processNull(certNo).equals("")){
					personview = (BasePersonal)baseService.findOnlyRowByHql("from BasePersonal t where t.certNo = '" + certNo+"'");
				}else{
					if(!Tools.processNull(cardNo).equals("")){
						CardBaseinfo card = (CardBaseinfo)baseService.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo+"'");
						if(card !=null){
							personview = (BasePersonal)baseService.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId()+"'");
						}
					}
				}
				
				if(personview!=null){
					personview.setCertTypes(baseService.getCodeNameBySYS_CODE("CERT_TYPE", personview.getCertType()));
					personview.setEducations(baseService.getCodeNameBySYS_CODE("EDUCATION", personview.getEducation()));
					personview.setNations(baseService.getCodeNameBySYS_CODE("NATION", personview.getNation()));
					personview.setRegionName(Tools.processNull(baseService.findOnlyFieldBySql("SELECT t.region_name from base_region t WHERE t.region_id='"+Tools.processNull(personview.getRegionId())+"'")));
					personview.setTownName(Tools.processNull(baseService.findOnlyFieldBySql("SELECT t.town_name from base_town t WHERE t.town_id='"+Tools.processNull(personview.getTownId())+"'")));
					personview.setCommName(Tools.processNull(baseService.findOnlyFieldBySql("SELECT t.comm_name from base_comm t WHERE t.comm_id='"+Tools.processNull(personview.getCommId())+"'")));
					personview.setGenderName(personview.getGenderName());
					personview.setMarrStateName(personview.getMarrStateName());
					personview.setSureFlags(personview.getSureFlags());
					personview.setCustomerStates(personview.getCustomerStates());
					personview.setResideTypeName(Tools.processNull(personview.getResideTypeName()).equals("")?"":Tools.processNull(personview.getResideTypeName()).substring(2, 4));
					jsonObject.put("personview", JsonHelper.parse2JSON(personview));
				}else{
					personview = new BasePersonal();
				}
			}else{
				personview = new BasePersonal();
			}
		} catch (Exception e) {
			// TODO: handle exception
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 查询银行信息。
	 * @return
	 */
	public String queryBankInfo() {
		BasePersonal basePersonal = null;
		CardBaseinfo cardBaseInfo = null;
		try {
			if(!Tools.processNull(certNo).equals("")||!Tools.processNull(cardNo).equals("")){
				if(!Tools.processNull(certNo).equals("")){
					basePersonal = (BasePersonal)baseService.findOnlyRowByHql("from BasePersonal b where b.certNo = '" + certNo+"'");
					if(basePersonal != null) {
						cardBaseInfo = (CardBaseinfo)baseService.findOnlyRowByHql("from CardBaseinfo c where c.customerId = '" + basePersonal.getCustomerId() + "'");
					}
				}
				if(!Tools.processNull(cardNo).equals("")) {
					cardBaseInfo = (CardBaseinfo)baseService.findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + cardNo + "'");
					if(cardBaseInfo != null) {
						basePersonal = (BasePersonal)baseService.findOnlyRowByHql("from BasePersonal b where b.customerId = '" + cardBaseInfo.getCustomerId() + "'");
					}
				}
			}
			if(basePersonal != null) {
				jsonObject.put("name", basePersonal.getName());
				jsonObject.put("certNo", basePersonal.getCertNo());
				jsonObject.put("cardNo", cardBaseInfo.getCardNo());
				jsonObject.put("cardType", cardBaseInfo.getCardType());
				if(Constants.CARD_TYPE_QGN.equals(cardBaseInfo.getCardType())){
					CardBindBankCard bindInfo = (CardBindBankCard) baseService.findOnlyRowByHql("from CardBindBankCard where cardNo = '" + cardBaseInfo.getCardNo() + "'");
					jsonObject.put("bankCardNo", bindInfo.getBankCardNo());
					jsonObject.put("bankName", baseService.findOnlyFieldBySql("select b.bank_name from base_bank b where b.bank_id = '" + bindInfo.getBankId() + "'"));
					jsonObject.put("bindState", bindInfo.getBankActiveState());
					jsonObject.put("qcWay", bindInfo.getStateText());
				} else if(Constants.CARD_TYPE_SMZK.equals(cardBaseInfo.getCardType())){
					jsonObject.put("bankCardNo", cardBaseInfo.getBankCardNo());
					jsonObject.put("bankName", baseService.findOnlyFieldBySql("select b.bank_name from base_bank b where b.bank_id = '" + cardBaseInfo.getBankId() + "'"));
					jsonObject.put("bindState", cardBaseInfo.getBankActiveState());
					AccQcqfLimit limit = (AccQcqfLimit) baseService.findOnlyRowByHql("from AccQcqfLimit where subCardNo = '" + cardBaseInfo.getSubCardNo() + "' or cardNo = '" + cardBaseInfo.getCardNo() + "'");
					if(limit != null){
						jsonObject.put("qcWay", limit.getQcWayText());
					} else {
						jsonObject.put("qcWay", "未开通");
					}
				}
			}
		} catch (Exception e) {
			
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
		
		
	public String getCertType() {
		return certType;
	}

	public void setCertType(String certType) {
		this.certType = certType;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
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

	public BasePersonal getPersonview() {
		return personview;
	}

	public void setPersonview(BasePersonal personview) {
		this.personview = personview;
	}

	public String getBeginTime() {
		return beginTime;
	}

	public void setBeginTime(String beginTime) {
		this.beginTime = beginTime;
	}

	public String getEndTime() {
		return endTime;
	}

	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}

	
	
	
}
