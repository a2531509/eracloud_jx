package com.erp.action;

import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.AccCreditLimit;
import com.erp.model.AccItemConf;
import com.erp.model.AccKindConfig;
import com.erp.model.AccOpenConf;
import com.erp.model.AccStateTradingBan;
import com.erp.model.BasePersonal;
import com.erp.model.CardBaseinfo;
import com.erp.model.TrServRec;
import com.erp.service.AccountManagementService;
import com.erp.util.Arith;
import com.erp.util.Tools;
import com.erp.viewModel.Page;
/**----------------------------------------------------*
*@category                                             *
*账户管理相关操作，账户状态和禁止交易码关联，账户消费额度限制      *
*账户金额冻结，账户锁定与解锁，账户激活                                                  *
*@author yangn                                         *  
*@date 2015-07-25                                      *
*@email yn_yangning@foxmail.com                        *
*@version 1.0                                          *
*------------------------------------------------------*/
@Namespace(value="/accountManager")
@Action(value="accountManagerAction")
@Results({
	@Result(name="accTypeIndex",location="/jsp/accManage/acctypeindex.jsp"),
	@Result(name="accTypeEdit",location="/jsp/accManage/acctypeedit.jsp"),
	@Result(name="openAccRuleEdit",location="/jsp/accManage/openaccruleedit.jsp"),
	@Result(name="openAccRuleAdd",location="/jsp/accManage/openaccruleadd.jsp"),
	@Result(name="toAccStateBanDealCodeEdit",location="/jsp/accManage/accstatebandealcodeedit.jsp"),
	@Result(name="accLimitAdd",location="/jsp/accManage/acccreditsadd.jsp"),
	@Result(name="accLimitEdit",location="/jsp/accManage/acccreditsedit.jsp"),
	@Result(name="accFreezeAdd",location="/jsp/accManage/accfreezeadd.jsp")
})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class AccountManagementSystemAction extends BaseAction{
	private static final long serialVersionUID = 1L;
	@Resource(name="accountManagementService") 
	private AccountManagementService accountManagementService;
	private String queryType = "1";//默认不进行查询
	private AccKindConfig accKindConfig;//账户类型
	private String accKindState;
	private String defaultErrorMsg;
	private String accKind = "";
	private String accKindName;
	private String accState;
	private String sort;
	private String order;
	//开户规则
	private AccOpenConf accOpenConf = new AccOpenConf();
	private String mainType;
	private String subType;
	private String subjectType;
	private List<AccItemConf> allAccItemConfs = new ArrayList<AccItemConf>();
	private List<AccOpenConf> unSelectedAccOpenConf = new ArrayList<AccOpenConf>();
	private List<AccOpenConf> selectedAccOpenConf = new ArrayList<AccOpenConf>();
	private Long ruleId;
	//账户禁止交易的交易码关联
	private AccStateTradingBan ban = new AccStateTradingBan();
	private AccCreditLimit limit = new AccCreditLimit();
	private BasePersonal bp = new BasePersonal();
	private CardBaseinfo card = new CardBaseinfo();
	private AccAccountSub acc = new AccAccountSub();
	private TrServRec rec = new TrServRec();
	private String minAmt;
	private String amt;
	private String maxAmt;
	private String maxNum;
	private String pwd;
	private String startTime;
	private String endTime;
	/**
	 * 到达账户类型管理界面
	 * @return
	 */
	public String accTypeIndex(){
		return "accTypeIndex";
	}
	/**
	 * 获取所有账户信息
	 * @return
	 */
	public String findAllAccKind(){
		try{
			Page l = baseService.pagingQuery("select code_value,code_name || '[' || code_value || ']'"
			+ " code_name from sys_code t where code_type = 'ACC_KIND' order by ord_No asc",1,1000);
		    JSONArray j = new JSONArray();
		    JSONObject de = new JSONObject();
		    de.put("CODE_VALUE","");
		    de.put("CODE_NAME","请选择");
		    j.add(de);
			if(l.getAllRs() != null && l.getAllRs().size() > 0){
				j.addAll(l.getAllRs());
			}
			PrintWriter p = this.response.getWriter();
			p.write(j.toString());
			p.flush();
			p.close();
		}catch(Exception e){
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 账户类型查询界面
	 * @return
	 */
	public String accTypeQuery(){
		try{
			initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select t.acc_kind,t.acc_name,decode(t.acc_kind_state,'0','在用','注销') acc_kind_state,");
				sb.append("t.open_user_id,to_char(t.open_date,'yyyy-mm-dd hh24:mi:ss') open_date,");
				sb.append("t.stop_user_id,to_char(t.stop_date,'yyyy-mm-dd hh24:mi:ss') stop_date,t.note,");
				sb.append("decode(t.alone_activate_flag,'0','是','否') alone_activate_flag,t.ord_no ");
				sb.append("from acc_kind_config t where 1 = 1 ");
				if(!Tools.processNull(this.accKindState).equals("")){
					sb.append("and t.acc_kind_state = '" + this.accKindState + "' ");
				}
				if(!Tools.processNull(this.accKind).equals("")){
					sb.append("and t.acc_kind = '" + this.accKind + "' ");
				}
				if(!Tools.processNull(this.accKindName).equals("")){
					sb.append("and t.acc_name like '%" + this.accKindName + "%' ");
				}
				if(Tools.processNull(this.sort).equals("")){
					sb.append("order by t.acc_kind asc , t.ord_no asc");
				}else{
					sb.append("order by " + this.sort + " " + this.order);
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("未找到账户类型信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 账户类型编辑或是新增界面
	 * @return
	 */
	public String accTypeEdit(){
		try{
			if(Tools.processNull(this.queryType).equals("1")){
				accKindConfig = (AccKindConfig) baseService.findOnlyRowByHql("from AccKindConfig t where t.accKind = '" + accKind + "'");
				if(accKindConfig == null){
					throw new CommonException("编辑账户类型出现错误，根据账户类型编号ACC_KIND=" + accKind + "未找到账户类型！");
				}
			}
		}catch(Exception e){
			defaultErrorMsg = e.getMessage();
		}
		return "accTypeEdit";
	}
	/**
	 * 账户类型编辑或是新增保存
	 * @return
	 */
	public String accTypeSave(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			if(!Tools.processNull(this.accKind).equals("")){
				accKindConfig.setAccKind(accKind);
			}
			if(!Tools.processNull(this.accState).equals("")){
				accKindConfig.setAccKindState(accState);
			}
			accountManagementService.saveOrUpdateAccKindConfig(accKindConfig,this.queryType);
			jsonObject.put("msg",(this.queryType.equals("0") ? "新增账户类型成功！" : "编辑账户类型成功！"));
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 账户类型启用或是注销
	 * @return
	 */
	public String enableOrDisableAccKind(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			accKindConfig = new AccKindConfig();
			accKindConfig.setAccKind(accKind);
			accountManagementService.saveEnableOrDisable(accKindConfig,this.queryType);
			jsonObject.put("msg",(this.queryType.equals("0") ? "启用账户类型成功！" : "禁用账户类型成功！"));
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 删除账户类型
	 * @return
	 */
	public String deleteAccKind(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		
		try{
			accountManagementService.saveAccKindConfigDelete(this.accKind);
			jsonObject.put("msg","删除账户类型成功！");
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 获取账户类型的操作日志
	 * @return
	 */
	public String queryAccKindLog(){
		try{
			initGrid();
			StringBuffer sb = new StringBuffer();
			sb.append("select t.deal_no,r.deal_code_name,t.acc_kind,b.full_name,u.name,to_char(t.biz_time,'yyyy-mm-dd hh24:mi:ss') bizTime,t.note,t.clr_date ");
			sb.append("from tr_serv_rec t,sys_code_tr r,sys_users u,sys_branch b ");
			sb.append("where t.deal_code = r.deal_code(+) and t.deal_code in ('50101010','50101020','50101031','50101040','50201051') ");
			sb.append("and t.user_id = u.user_id and u.brch_id = b.brch_id ");
			if(Tools.processNull(this.sort).equals("")){
				sb.append("order by t.biz_time desc ");
			}else{
				sb.append("order by " + this.sort + " " + this.order);
			}
			sb.append("");
			Page list = baseService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("未获取到账户类型操作日志！");
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	//++++++++++++++++++以下为开户规则维护++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	/**
	 * 开户规则查询
	 * @return
	 */
	public String openAccRuleQuery(){
		try{
			initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select (select w.code_name  from sys_code w where w.code_type = 'MAIN_TYPE' and w.code_value = t.main_type) main_type,");
				sb.append("t.sub_type,(select v.code_name from sys_code v where v.code_type='CARD_TYPE' and v.code_value = t.sub_type) cardName,t.item_id,");
				sb.append("a.item_name,t.acc_kind,g.acc_name,decode(t.conf_state,'0','正常','1','注销','注销') conf_state,t.id,decode(t.acc_init_state,'1','未激活','0','正常','未知') acc_init_state ");
				sb.append("from acc_open_conf t,acc_item a,acc_kind_config g  where t.item_id = a.item_id and t.acc_kind = g.acc_kind ");
				if(!Tools.processNull(this.mainType).equals("")){
					sb.append("and main_type = '" + this.mainType + "' ");
				}
				if(!Tools.processNull(accOpenConf.getSubType()).equals("")){
					sb.append("and sub_type = '" + accOpenConf.getSubType() + "' ");
				}
				if(!Tools.processNull(accOpenConf.getConfState()).equals("")){
					sb.append("and conf_state = '" + accOpenConf.getConfState() + "' ");
				}
				if(Tools.processNull(this.sort).equals("")){
					sb.append("order by t.main_type asc ,t.sub_type asc,t.acc_kind asc");
				}else{
					sb.append(" order by " + this.sort + " " + this.order);
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("未获取账户开户规则信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 根据账户主体类型查询可以开通的科目
	 * @return
	 */
	public String itemTypeQuery(){
		try{
			JSONArray j = new JSONArray();
			JSONObject de = new JSONObject();
			de.put("ITEM_NO","");
			de.put("ITEM_NAME","请选择");
			j.add(de);
			if(!Tools.processNull(subjectType).equals("")){
				Page l = baseService.pagingQuery("select t.item_No,t.item_Name||'['||t.item_no||']' item_Name from Acc_Item_Conf t,acc_item b where t.item_no = b.item_id and t.subject_Type = '" + this.subjectType + "'",1,1000);
				if(l.getAllRs() != null && l.getAllRs().size() > 0){
					j.addAll(l.getAllRs());
				}
			}
			PrintWriter p = this.response.getWriter();
			p.write(j.toString());
			p.flush();
			p.close();
		}catch(Exception e){
			
		}
		return this.JSONOBJ;
	}
	/**
	 * 开户规则编辑或是新增
	 * @return
	 */
	public String openAccRuleEdit(){
		try{
			//queryType == 1 编辑  查询开户规则进行编辑页面的初始化
			if(Tools.processNull(this.queryType).equals("1")){
				accOpenConf = (AccOpenConf) baseService.findOnlyRowByHql("from AccOpenConf t where t.id = " + this.ruleId);
				if(accOpenConf == null){
					throw new CommonException("编辑开户规则出现错误，根据规则编号ID=" + ruleId + "未找到规则信息！");
				}
			}else{
				accOpenConf = new AccOpenConf();
			}
		}catch(Exception e){
			defaultErrorMsg = e.getMessage();
		}
		return "openAccRuleEdit";
	}
	/**
	 * 新增保存或是编辑保存账户开户规则
	 * @return
	 */
	public String saveOpenRuleConf(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			if(!Tools.processNull(this.ruleId).equals("")){
				accOpenConf.setId(this.ruleId);
			}
			accountManagementService.saveOrUpdateAccOpenConf(accOpenConf,this.queryType);
			jsonObject.put("msg",(this.queryType.equals("0") ? "新增账户开户规则成功！" : "编辑账户开户规则成功！"));
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 删除账户开户规则
	 * @return
	 */
	public String saveAccOpenConfDelete(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			accountManagementService.saveAccOpenConfDelete(ruleId);
			jsonObject.put("msg","删除账户开户规则成功！");
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 启用或是禁用账户开户规则
	 * @return
	 */
	public String saveEnableOrDisaableAccOpenConf(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			accountManagementService.saveDisableOrEnableAccOpenConf(ruleId, queryType);
			jsonObject.put("msg",(this.queryType.equals("0") ? "启用账户开户规则成功！" : "禁用账户开户规则成功！"));
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	//+++++++++++++++++++++++++++++++++++++++++++账户状态和交易码关联++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	public String findAllDealCode(){
		try{
			JSONArray j = new JSONArray();
			JSONObject de = new JSONObject();
			de.put("DEAL_CODE","");
			de.put("DEAL_CODE_NAME","请选择");
			j.add(de);
			Page l = baseService.pagingQuery("select t.deal_code,t.deal_code_name || '[' || t.deal_code ||  ']' deal_code_name from sys_code_tr t",1,50000);
			if(l.getAllRs() != null && l.getAllRs().size() > 0){
				j.addAll(l.getAllRs());
			}
			PrintWriter p = this.response.getWriter();
			p.write(j.toString());
			p.flush();
			p.close();
		}catch(Exception e){
			
		}
		return this.JSONOBJ;
	}
	/**
	 * 查询账户状态禁止交易的交易码
	 * @return
	 */
	public String toAccStateBanDealCodeQuery(){
		try{
			initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select t.id, t.card_type,(select s1.code_name from sys_code s1 where s1.code_type = 'CARD_TYPE' and s1.code_value = t.card_type) cardName,");
				sb.append("t.acc_kind,(select s2.code_name from sys_code s2 where s2.code_type = 'ACC_KIND' and s2.code_value = t.acc_kind) accName,");
				sb.append("t.acc_state,(select s3.code_name from sys_code s3 where s3.code_type = 'ACC_STATE' and s3.code_value = t.acc_state) accState,");
				sb.append("t.ban_deal_code,b.deal_code_name,decode(t.state,'0','正常','注销' )state ,t.note from ACC_STATE_TRADING_BAN t,sys_code_tr b ");
				sb.append("where t.ban_deal_code = b.deal_code ");
				if(!Tools.processNull(ban.getCardType()).equals("")){
					sb.append("and t.card_type = '" + ban.getCardType() + "' ");
				}
				if(!Tools.processNull(ban.getAccKind()).equals("")){
					sb.append("and t.acc_kind = '" + ban.getAccKind() + "' ");
				}
				if(!Tools.processNull(ban.getAccState()).equals("")){
					sb.append("and t.acc_state = '" + ban.getAccState() + "' ");
				}
				if(!Tools.processNull(ban.getBanDealCode()).equals("")){
					sb.append("and t.ban_deal_code = '" + ban.getBanDealCode() + "' ");
				}
				if(Tools.processNull(this.sort).equals("")){
					sb.append("order by t.card_type asc ,t.acc_kind asc,t.acc_state asc");
				}else{
					sb.append(" order by " + this.sort + " " + this.order);
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("未获取到账户状态和禁止交易代码的关联信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 到达账户状态禁止交易编辑页面或是新增页面
	 * @return
	 */
	public String toAccStateBanDealCodeEdit(){
		try{
			if(Tools.processNull(this.queryType).equals("1")){
				ban = (AccStateTradingBan) baseService.findOnlyRowByHql("from AccStateTradingBan t where t.id = " + this.ruleId);
			}
		}catch(Exception e){
			this.defaultErrorMsg = e.getMessage();
		}
		return "toAccStateBanDealCodeEdit";
	}
	/**
	 * 新增保存或是编辑保存账户状态禁止交易的交易码
	 * @return
	 */
	public String saveStateBanDealCode(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			if(!Tools.processNull(this.ruleId).equals("")){
				ban.setId(this.ruleId);
			}
			accountManagementService.saveOrUpdateAccStateTradingBan(ban,this.queryType);
			jsonObject.put("status","0");
			jsonObject.put("msg",(this.queryType.equals("0") ? "新增账户状态禁止交易代码成功！" : "编辑账户状态禁止交易代码成功！"));
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 删除账户状态和禁止交易代码关联
	 * @return
	 */
	public String saveAccStateTradingBanDelete(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			accountManagementService.saveAccStateTradingBanDelete(this.ruleId);
			jsonObject.put("status","0");
			jsonObject.put("msg","删除账户状态禁止交易代码成功！");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 启用或是禁用账户状态和禁止交易代码关联
	 * @return
	 */
	public String saveDisableOrEnableStateBanDealCode(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			if(!Tools.processNull(this.ruleId).equals("")){
				ban.setId(this.ruleId);
			}
			accountManagementService.saveDisableOrEnableAccStateTradingBan(this.ruleId,this.queryType);
			jsonObject.put("status","0");
			jsonObject.put("msg",(this.queryType.equals("0") ? "启用账户状态禁止交易代码成功！" : "禁用账户状态禁止交易代码成功！"));
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	//+++++++++++++++++++++++一下是账户单笔（单日）消费额度限制++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	//账户额度限制账户信息查询
	public String toAccLimitAccMsgQuery(){
		try{
			initGrid();
			if(queryType.equals("0")){
				if(Tools.processNull(bp.getCertNo()).equals("") && Tools.processNull(card.getCardNo()).equals("")){
					throw new CommonException("请输入证件号码或卡号以进行查询！");
				}
				StringBuffer sb = new StringBuffer();
				sb.append("select t.customer_id,b.name,b.cert_no,t.card_no,");
				sb.append("(select s.code_name from sys_code s where s.code_type = 'CERT_TYPE' and s.code_value = b.cert_type) cert_type,");
				sb.append("(select s.code_name from sys_code s where s.code_type = 'CARD_TYPE' and s.code_value = t.card_type) card_type,");
				sb.append("(select s.code_name from sys_code s where s.code_type = 'CARD_STATE' and s.code_value = t.card_state) card_state,");
				sb.append("(select s.code_name from sys_code s where s.code_type = 'BUS_TYPE' and s.code_value = t.bus_type) bus_type,");
				sb.append("decode(g.redeem_flag,'0','是','否') redeem_flag ");//是否允许注销
				sb.append("from card_baseinfo t ,Base_Personal b,card_config g ");
				sb.append("where t.customer_id = b.customer_id(+) and t.card_type = g.card_type ");
				if(!Tools.processNull(bp.getCertType()).equals("")){
					sb.append("and b.cert_type = '" + bp.getCertType() +"' ");
				}
				if(!Tools.processNull(bp.getCertNo()).equals("")){
					sb.append("and b.cert_no = '" + bp.getCertNo() +"' ");
				}
				if(!Tools.processNull(card.getCardType()).equals("")){
					sb.append("and t.card_type = '" + card.getCardType() +"' ");
				}
				if(!Tools.processNull(card.getCardNo()).equals("")){
					sb.append("and t.card_no = '" + card.getCardNo() +"' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("order by t.last_modify_date desc ");
				}
				Page list = baseService.pagingQuery(sb.toString(),1,1000);
				if(list == null || list.getAllRs() == null){
					throw new CommonException("根据指定信息未查询到对应账户信息！");
				}else{
					jsonObject.put("rows",list.getAllRs());
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 * 查询账户额度限制信息列表
	 * @return
	 */
	public String toAccLimitIndex(){
		try{
			initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select t.deal_no,t.customer_id,(select s2.code_name from sys_code s2 where s2.code_type = 'CARD_TYPE' and  s2.code_value = t.card_type) card_type,");
				sb.append("t.card_no,t.acc_no,(select s3.code_name from sys_code s3 where s3.code_type = 'ACC_KIND' and  s3.code_value = t.acc_kind) acc_kind,t.item_no,c.name opername,");
				sb.append("trim(to_char(nvl(t.amt,0)/100,'999,990.99')) amt,t.clr_date,to_char(t.biz_time,'yyyy-mm-dd hh24:mi:ss') biz_time,t.org_id,t.brch_id,t.user_id,s.full_name,t.note,decode(t.state,'0','正常','注销') state,");
				sb.append("trim(to_char(nvl(t.min_amt,0)/100,'999,990.99')) min_amt,t.max_num,trim(to_char(nvl(t.max_amt,0)/100,'999,990.99')) max_amt,");
				sb.append("b.name,(select s1.code_name from sys_code s1 where s1.code_type = 'CERT_TYPE' and  s1.code_value = b.cert_type) cert_type,b.cert_no ");
				sb.append("from ACC_CREDIT_LIMIT t,base_personal b,sys_branch s,sys_users c where t.customer_id = b.customer_id(+) and t.brch_id = s.brch_id and t.user_id = c.user_id ");
				if(!Tools.processNull(bp.getCertType()).equals("")){
					sb.append("and b.cert_Type = '" + bp.getCertType() + "' ");
				}
				if(!Tools.processNull(bp.getCertNo()).equals("")){
					sb.append("and b.cert_No = '" + bp.getCertNo() + "' ");
				}
				if(!Tools.processNull(card.getCardType()).equals("")){
					sb.append("and t.card_Type = '" + card.getCardType() + "' ");
				}
				if(!Tools.processNull(card.getCardNo()).equals("")){
					sb.append("and t.card_no = '" + card.getCardNo() + "' ");
				}
				if(!Tools.processNull(acc.getAccKind()).equals("")){
					sb.append("and t.acc_kind = '" + acc.getAccKind() + "' ");
				}
				if(!Tools.processNull(limit.getState()).equals("")){
					sb.append("and t.state = '" + limit.getState() + "' ");
				}
				if(Tools.processNull(this.sort).equals("")){
					sb.append("order by t.biz_time desc");
				}else{
					sb.append("order by " + this.sort + " " + this.order );
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list == null || list.getAllRs() == null){
					throw new CommonException("根据指定信息未查询到对应账户信息！");
				}else{
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 新增或是编辑账户额度限制页面
	 * @return
	 */
	public String toAccLimitEdit(){
		String string = "accLimitAdd";
		try{
			if(Tools.processNull(this.queryType).equals("1")){
				string = "accLimitEdit";
				if(Tools.processNull(this.ruleId).equals("")){
					throw new CommonException("编辑账户限额信息出现错误，限额编号不能为空！");
				}
				limit = (AccCreditLimit) baseService.findOnlyRowByHql("from AccCreditLimit t where t.dealNo = " + this.ruleId);
				if(limit == null){
					limit = new AccCreditLimit();
					throw new CommonException("编辑账户限额信息出现错误，根据账户额度限制编号" + this.ruleId + "未查询到账户限制信息！");
				}
				this.minAmt = Arith.cardreportsmoneydiv(limit.getMinAmt() + "");
				this.amt = Arith.cardreportsmoneydiv(limit.getAmt() + "");
				this.maxAmt = Arith.cardreportsmoneydiv(limit.getMaxAmt() + "");
				this.maxNum = limit.getMaxNum().toString();
				if(!Tools.processNull(limit.getCustomerId()).equals("")){
					bp = (BasePersonal) baseService.findOnlyRowByHql("from BasePersonal t where t.customerId = " + limit.getCustomerId());
					if(bp == null){
						bp = new BasePersonal();
					}
				}
			}
		}catch(Exception e){
			this.defaultErrorMsg = e.getMessage();
		}
		return string;
	}
	/**
	 * 新增保存或是编辑保存账户限额设置信息
	 * @return
	 */
	public String saveOrUpdateAccLimit(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			if(!Tools.processNull(amt).equals("")){
				limit.setAmt(Long.valueOf(Arith.cardmoneymun(amt)));
			}
			if(!Tools.processNull(this.minAmt).equals("")){
				limit.setMinAmt(Long.valueOf(Arith.cardmoneymun(minAmt)));
			}
			if(!Tools.processNull(this.maxAmt).equals("")){
				limit.setMaxAmt(Long.valueOf(Arith.cardmoneymun(maxAmt)));
			}
			if(!Tools.processNull(this.maxNum).equals("")){
				limit.setMaxNum(Long.valueOf(maxNum));
			}
			accountManagementService.saveOrUpdateAccLimit(limit,rec,this.queryType);
			jsonObject.put("status","0");
			jsonObject.put("msg",(this.queryType.equals("0") ? "新增账户限额设置信息成功！" : "编辑账户限额设置信息成功！"));
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 删除账户限额设置信息
	 * @return
	 */
	public String saveAccLimitDelete(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			accountManagementService.saveAccLimitDelete(this.ruleId);
			jsonObject.put("msg","删除账户限额设置信息成功！");
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 启用或是禁用账户限额设置信息
	 * @return
	 */
	public String saveDisableOrEnableAccLimit(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			accountManagementService.saveDisableOrEnableAccLimit(this.ruleId,this.queryType);
			jsonObject.put("msg",(this.queryType.equals("0") ? "启用账户限额设置信息成功！" : "禁止账户限额设置信息成功！"));
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 账户锁定与解锁
	 * @return
	 */
	public String saveAccountLockOrUnlock(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			accountManagementService.saveAccountLockOrUnlock(this.card.getCardNo(),this.accKind,this.queryType);
			jsonObject.put("msg",(this.queryType.equals("0") ? "账户锁定成功！" : "账户解锁成功！"));
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 账户激活管理，信息查询
	 * @return
	 */
	public String accEnableQuery(){
		try{
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select c.customer_id,b.name,");
				sb.append("(select s0.code_name from sys_code s0 where s0.code_type = 'SEX' and s0.code_value = b.gender) gender,");
				sb.append("(select s1.code_name from sys_code s1 where s1.code_type = 'CERT_TYPE' and s1.code_value = b.cert_type) cert_type,");
				sb.append("b.cert_no,c.card_no,");
				sb.append("(select s2.code_name from sys_code s2 where s2.code_type = 'CARD_TYPE' and s2.code_value = c.card_type) card_type,");
				sb.append("(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_STATE' and s3.code_value = c.card_state) card_state,");
				sb.append("(select s4.code_name from sys_code s4 where s4.code_type = 'CARD_STATE' and s4.code_value = c.bus_type) bus_type,");
				sb.append("(case when c.start_date is not null then to_char(to_date(c.start_date,'yyyymmdd'),'yyyy-mm-dd') else '' end) start_date ");
				sb.append("from card_baseinfo c ,base_personal b ");
				sb.append("where c.customer_id = b.customer_id(+) ");
				if(!Tools.processNull(card.getCardNo()).trim().equals("")){
					sb.append("and c.card_no = '" + card.getCardNo() + "' ");
				}
				if(!Tools.processNull(card.getCardType()).trim().equals("")){
					sb.append("and c.card_type = '" + this.card.getCardType() + "' ");
				}
				if(!Tools.processNull(bp.getCertNo()).trim().equals("")){
					sb.append("and b.cert_no = '" + bp.getCertNo() + "'");
				}
				if(!Tools.processNull(bp.getCertType()).trim().equals("")){
					sb.append("and b.cert_type = '" + bp.getCertType() + "'");
				}
				Page list = baseService.pagingQuery(sb.toString(),1,100);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到卡片信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 保存账户激活
	 * @return
	 */
	public String saveAccEnable(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			accountManagementService.saveAccEnableQuery(this.card.getCardNo(),this.accKind,pwd,rec,baseService.getCurrentActionLog());
			jsonObject.put("msg","账户激活成功！");
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 账户冻结信息查询
	 * @return
	 */
	public String accFreezeQuery(){
		try{
			this.initGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select t.deal_no,b.customer_id,b.name,(select s1.code_name from sys_code s1 where s1.code_type = 'CERT_TYPE' and s1.code_value = b.cert_type) certtype,");
				sb.append("b.cert_no,(select s1.code_name from sys_code s1 where s1.code_type = 'CARD_TYPE' and s1.code_value = c.card_type) card_type,t.card_no,(select s1.code_name from sys_code s1 where s1.code_type = 'ACC_KIND' and s1.code_value = t.acc_kind) acckind,");
				sb.append("t.acc_kind,trim(to_char(nvl(t.frz_amt,0)/100,'999,990.99')) frz_amt,t.frz_type,decode(t.rec_type,'0','正常','撤销') state,t.rec_type,s.full_name,t.user_id,u.name username,to_char(t.insert_date,'yyyy-mm-dd hh24:mi:ss') insert_date, ");
				sb.append("t.old_deal_no parentId ");
				sb.append("from (select * from acc_freeze_rec union all select * from acc_freeze_his) t ,card_baseinfo c ,base_personal b,sys_branch s,sys_users u ");
				sb.append("where t.card_no = c.card_no and c.customer_id = b.customer_id(+) and t.acpt_id = s.brch_id(+) and t.user_id = u.user_id(+) and t.deal_code = 50601010 ");
				if(!Tools.processNull(card.getCardNo()).trim().equals("")){
					sb.append("and t.card_no = '" + card.getCardNo() + "' ");
				}
				if(!Tools.processNull(card.getCardType()).trim().equals("")){
					sb.append("and c.card_type = '" + this.card.getCardType() + "' ");
				}
				if(!Tools.processNull(bp.getCertNo()).trim().equals("")){
					sb.append("and b.cert_no = '" + bp.getCertNo() + "' ");
				}
				if(!Tools.processNull(bp.getCertType()).trim().equals("")){
					sb.append("and b.cert_type = '" + bp.getCertType() + "' ");
				}
				if(!Tools.processNull(acc.getAccKind()).trim().equals("")){
					sb.append("and t.acc_kind = '" + acc.getAccKind() + "' ");
				}
				if(!Tools.processNull(acc.getAccState()).trim().equals("")){
					sb.append("and t.rec_type = '" + acc.getAccState() + "' ");
				}
				if(!Tools.processNull(this.startTime).equals("")){
					sb.append("and to_char(t.insert_date,'yyyy-mm-dd') >= '" + this.startTime + "' ");
				}
				if(!Tools.processNull(this.endTime).equals("")){
					sb.append("and to_char(t.insert_date,'yyyy-mm-dd') <= '" + this.endTime + "' ");
				}
				if(Tools.processNull(this.sort).equals("")){
					sb.append("order by t.insert_date desc");
				}else{
					sb.append("order by " + this.sort + " " + this.order );
				}
				Page list = baseService.pagingQuery(sb.toString(), page, rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到记录信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 *到达账户冻结新增页面
	 * @return
	 */
	public String toAccFreezeAdd(){
		return "accFreezeAdd";
	}
	/**
	 * 保存账户冻结信息
	 * @return
	 */
	public String saveAccFreeze(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			rec = accountManagementService.saveAccFreeze(card.getCardNo(),accKind,Long.valueOf(Arith.cardmoneymun(minAmt)),pwd,baseService.getUser(),rec,baseService.getCurrentActionLog());
			jsonObject.put("status","0");
			jsonObject.put("msg","账户金额冻结成功！");
			jsonObject.put("dealNo",rec.getDealNo());
		}catch(Exception e){
			jsonObject.put("msg","冻结账户金额发生错误：" + e.getMessage() + "！");
		}
		return this.JSONOBJ;
	}
	/**
	 * 保存账户解冻信息
	 * @return
	 */
	public String saveAccUnFreeze(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			rec = accountManagementService.saveAccUnFreeze(this.ruleId,pwd,baseService.getUser(),rec,baseService.getCurrentActionLog());
			jsonObject.put("status","0");
			jsonObject.put("msg","解冻账户冻结金额成功！");
			jsonObject.put("dealNo",rec.getDealNo());
		}catch(Exception e){
			jsonObject.put("msg","解冻账户冻结金额发生错误：" + e.getMessage() + "！");
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
	public String getQueryType() {
		return queryType;
	}
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	public AccKindConfig getAccKindConfig() {
		return accKindConfig;
	}
	public void setAccKindConfig(AccKindConfig accKindConfig) {
		this.accKindConfig = accKindConfig;
	}
	public String getAccKindState() {
		return accKindState;
	}
	public void setAccKindState(String accKindState) {
		this.accKindState = accKindState;
	}
	public String getDefaultErrorMsg() {
		return defaultErrorMsg;
	}
	public void setDefaultErrorMsg(String defaultErrorMsg) {
		this.defaultErrorMsg = defaultErrorMsg;
	}
	public String getAccKind() {
		return accKind;
	}
	public void setAccKind(String accKind) {
		this.accKind = accKind;
	}
	public AccountManagementService getAccountManagementService() {
		return accountManagementService;
	}
	public void setAccountManagementService(AccountManagementService accountManagementService) {
		this.accountManagementService = accountManagementService;
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
	public String getAccKindName() {
		return accKindName;
	}
	public void setAccKindName(String accKindName) {
		this.accKindName = accKindName;
	}
	public String getAccState() {
		return accState;
	}
	public void setAccState(String accState) {
		this.accState = accState;
	}
	/**
	 * @return the mainType
	 */
	public String getMainType() {
		return mainType;
	}
	/**
	 * @param mainType the mainType to set
	 */
	public void setMainType(String mainType) {
		this.mainType = mainType;
	}
	/**
	 * @return the subType
	 */
	public String getSubType() {
		return subType;
	}
	/**
	 * @param subType the subType to set
	 */
	public void setSubType(String subType) {
		this.subType = subType;
	}
	/**
	 * @return the accOpenConf
	 */
	public AccOpenConf getAccOpenConf() {
		return accOpenConf;
	}
	/**
	 * @param accOpenConf the accOpenConf to set
	 */
	public void setAccOpenConf(AccOpenConf accOpenConf) {
		this.accOpenConf = accOpenConf;
	}
	/**
	 * @return the unSelectedAccOpenConf
	 */
	public List<AccOpenConf> getUnSelectedAccOpenConf() {
		return unSelectedAccOpenConf;
	}
	/**
	 * @param unSelectedAccOpenConf the unSelectedAccOpenConf to set
	 */
	public void setUnSelectedAccOpenConf(List<AccOpenConf> unSelectedAccOpenConf) {
		this.unSelectedAccOpenConf = unSelectedAccOpenConf;
	}
	/**
	 * @return the selectedAccOpenConf
	 */
	public List<AccOpenConf> getSelectedAccOpenConf() {
		return selectedAccOpenConf;
	}
	/**
	 * @param selectedAccOpenConf the selectedAccOpenConf to set
	 */
	public void setSelectedAccOpenConf(List<AccOpenConf> selectedAccOpenConf) {
		this.selectedAccOpenConf = selectedAccOpenConf;
	}
	/**
	 * @return the subjectType
	 */
	public String getSubjectType() {
		return subjectType;
	}
	/**
	 * @param subjectType the subjectType to set
	 */
	public void setSubjectType(String subjectType) {
		this.subjectType = subjectType;
	}
	/**
	 * @return the allAccItemConfs
	 */
	public List<AccItemConf> getAllAccItemConfs() {
		return allAccItemConfs;
	}
	/**
	 * @param allAccItemConfs the allAccItemConfs to set
	 */
	public void setAllAccItemConfs(List<AccItemConf> allAccItemConfs) {
		this.allAccItemConfs = allAccItemConfs;
	}
	/**
	 * @return the ruleId
	 */
	public Long getRuleId() {
		return ruleId;
	}
	/**
	 * @param ruleId the ruleId to set
	 */
	public void setRuleId(Long ruleId) {
		this.ruleId = ruleId;
	}
	/**
	 * @return the ban
	 */
	public AccStateTradingBan getBan() {
		return ban;
	}
	/**
	 * @param ban the ban to set
	 */
	public void setBan(AccStateTradingBan ban) {
		this.ban = ban;
	}
	/**
	 * @return the limit
	 */
	public AccCreditLimit getLimit() {
		return limit;
	}
	/**
	 * @param limit the limit to set
	 */
	public void setLimit(AccCreditLimit limit) {
		this.limit = limit;
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
	 * @return the card
	 */
	public CardBaseinfo getCard() {
		return card;
	}
	/**
	 * @param card the card to set
	 */
	public void setCard(CardBaseinfo card) {
		this.card = card;
	}
	/**
	 * @return the acc
	 */
	public AccAccountSub getAcc() {
		return acc;
	}
	/**
	 * @param acc the acc to set
	 */
	public void setAcc(AccAccountSub acc) {
		this.acc = acc;
	}
	/**
	 * @return the minAmt
	 */
	public String getMinAmt() {
		return minAmt;
	}
	/**
	 * @param minAmt the minAmt to set
	 */
	public void setMinAmt(String minAmt) {
		this.minAmt = minAmt;
	}
	/**
	 * @return the amt
	 */
	public String getAmt() {
		return amt;
	}
	/**
	 * @param amt the amt to set
	 */
	public void setAmt(String amt) {
		this.amt = amt;
	}
	/**
	 * @return the maxAmt
	 */
	public String getMaxAmt() {
		return maxAmt;
	}
	/**
	 * @param maxAmt the maxAmt to set
	 */
	public void setMaxAmt(String maxAmt) {
		this.maxAmt = maxAmt;
	}
	/**
	 * @return the pwd
	 */
	public String getPwd() {
		return pwd;
	}
	/**
	 * @param pwd the pwd to set
	 */
	public void setPwd(String pwd) {
		this.pwd = pwd;
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
	 * @return the startTime
	 */
	public String getStartTime() {
		return startTime;
	}
	/**
	 * @param startTime the startTime to set
	 */
	public void setStartTime(String startTime) {
		this.startTime = startTime;
	}
	/**
	 * @return the endTime
	 */
	public String getEndTime() {
		return endTime;
	}
	/**
	 * @param endTime the endTime to set
	 */
	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}
	public String getMaxNum() {
		return maxNum;
	}
	public void setMaxNum(String maxNum) {
		this.maxNum = maxNum;
	}	
	
}
