package com.erp.action;


import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.CardConfig;
import com.erp.model.SysActionLog;
import com.erp.service.SysParamService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.util.DealCode;
import com.erp.viewModel.Json;
import com.erp.viewModel.Page;

@Namespace("/cardParaManage")
@Action(value = "cardConfigAction")
@Results({@Result(type="json",name="json"),
	@Result(name="toViewCardConfig",location="/jsp/paraManage/cardParaEditDlg.jsp"),
	@Result(name="toErrParaManage",location="/jsp/paraManage/pwdParaManage.jsp")
	})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class CardConfigAction extends BaseAction {
	
	private CardConfig config;
	private String sort="";
	private String order="";
	private String queryType = "1";//查询类型 1 不进行查询,直接返回;0 进行查询,返回查询结果。
	//查询条件字段
	private String cardType="";
	
	private String selectCartType="";
	
	private SysParamService sysParamService;
	
	//新增和修改标志
	private String editOrAddFlag="";//1 新增  2 编辑
	
	private String sys_Login_Pwd_Err_Num = "";
	private String trade_Pwd_Err_Num = "";
	private String serv_Pwd_Err_Num = "";

	@Autowired
	public void setSysParamService(SysParamService sysParamService )
	{
		this.sysParamService = sysParamService;
	}

	
	/**
	 * 查询卡参数信息
	 * @return
	 */
	public String findCardParaInfo(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		try{//0网点1社区2单位3学校
			if(this.queryType.equals("0")){
				String head="",htj="";
				head = "select a.CARD_TYPE,a.ONLY,a.NAMED_FLAG,a.FACE_PERSONAL,a.IN_PERSONAL,a.LSS_FLAG,"
						+ "a.REISSUE_FLAG,a.RE_CARDNO_FLAG,a.CHG_FLAG,a.CHG_CARDNO_FLAG,a.STRUCT_MAIN_TYPE,"
						+ "a.STRUCT_CHILD_TYPE,a.CARD_VALIDITY_PERIOD,a.WALLET_CASE_RECHG_LMT,"
						+ "a.ACC_CASE_RECHG_LMT,a.BANK_RECHG_LMT,a.CASH_RECHG_LOW,a.CARD_TYPE_STATE ";
				htj = " from CARD_CONFIG a where a.CARD_TYPE_STATE = '0' ";
				if(!Tools.processNull(cardType).equals("")){
					htj+=" and a.CARD_TYPE = '"+cardType+"'";
				}
				
				if(Tools.processNull(sort).equals("")){
					htj+=" order by a.CARD_TYPE ";
				}else{
					htj+=" order by  "+sort+" "+order;
				}
				Page list = sysParamService.pagingQuery(head+htj.toString(),page,rows);
				if(list.getAllRs() != null){
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
	 * 到达卡参数编辑首页 
	 * @return
	 */
	public String toViewCardConfig(){
		try {
			editOrAddFlag="2";
			config=(CardConfig)sysParamService.findOnlyRowByHql("from CardConfig 	t where t.cardType='"+selectCartType+"'");
		} catch (Exception e) {
			// TODO: handle exception
		}
		return "toViewCardConfig";
	}
	
	/**
	 * 保存卡参数信息
	 * @return
	 */
	public String saveCardParaConfig(){
		Json json = new Json();
		try {
			SysActionLog actionLog =sysParamService.getCurrentActionLog(); 
			if(editOrAddFlag.equals("1")){//添加
				actionLog.setDealCode(DealCode.CARD_PARA_ADD);
				actionLog.setMessage("卡参数新增"+config.getCardType());
			}else if(editOrAddFlag.equals("2")){//修改
				actionLog.setDealCode(DealCode.CARD_PARA_EDIT);
				actionLog.setMessage("卡参数新增"+config.getCardType());
			}else{
				throw new CommonException("参数错误");
			}
			sysParamService.saveCardConfig(actionLog, config, editOrAddFlag);
			config = null;
			json.setTitle("卡参数修改");
			json.setStatus(true);
			json.setMessage("修改成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setTitle("卡参数修改");
			json.setStatus(false);
			json.setMessage("修改出错");
		}
		OutputJson(json, Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	/**
	 * 到达密码错误次数修改页面
	 * @return
	 */
	
	public String toErrParaManage(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		try {
			sys_Login_Pwd_Err_Num = (String)sysParamService.findOnlyFieldBySql("select para_value from Sys_Para where para_code = 'SYS_LOGIN_PWD_ERR_NUM'");
			trade_Pwd_Err_Num = (String)sysParamService.findOnlyFieldBySql("select para_value from Sys_Para where para_code = 'TRADE_PWD_ERR_NUM'");
			serv_Pwd_Err_Num = (String)sysParamService.findOnlyFieldBySql("select para_value from Sys_Para where para_code = 'SERV_PWD_ERR_NUM'");

		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg","达到首页发生错误："+e.getMessage());
		}
		return "toErrParaManage";
	}
	
	/**
	 * 保存密码错误次数限制
	 * @return
	 */
	public String saveErrPwdPara(){
		jsonObject.put("status",1);
		jsonObject.put("msg","");
		try {
			SysActionLog log  = sysParamService.getCurrentActionLog();
			log.setDealCode(DealCode.PWD_ERR_NUM_PARA_SET);
			log.setMessage("密码错误参数控制修改保存");
			sysParamService.saveErrPwdPara(log, serv_Pwd_Err_Num, sys_Login_Pwd_Err_Num, trade_Pwd_Err_Num);
			jsonObject.put("dealNo",log.getDealNo());
			jsonObject.put("status","0");
			jsonObject.put("msg","保存成功");//写卡字符串
		} catch (Exception e) {
			jsonObject.put("msg","钱包账户充值记录灰记录发生错误：" + e.getMessage());
		}
		
		return "jsonObj";
	}
	
	public CardConfig getConfig() {
		return config;
	}
	public void setConfig(CardConfig config) {
		this.config = config;
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
	public String getQueryType() {
		return queryType;
	}
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	public String getCardType() {
		return cardType;
	}
	public void setCardType(String cardType) {
		this.cardType = cardType;
	}
	public String getSelectCartType() {
		return selectCartType;
	}
	public void setSelectCartType(String selectCartType) {
		this.selectCartType = selectCartType;
	}
	public String getEditOrAddFlag() {
		return editOrAddFlag;
	}
	public void setEditOrAddFlag(String editOrAddFlag) {
		this.editOrAddFlag = editOrAddFlag;
	}


	public String getSys_Login_Pwd_Err_Num() {
		return sys_Login_Pwd_Err_Num;
	}


	public void setSys_Login_Pwd_Err_Num(String sys_Login_Pwd_Err_Num) {
		this.sys_Login_Pwd_Err_Num = sys_Login_Pwd_Err_Num;
	}


	public String getTrade_Pwd_Err_Num() {
		return trade_Pwd_Err_Num;
	}


	public void setTrade_Pwd_Err_Num(String trade_Pwd_Err_Num) {
		this.trade_Pwd_Err_Num = trade_Pwd_Err_Num;
	}


	public String getServ_Pwd_Err_Num() {
		return serv_Pwd_Err_Num;
	}


	public void setServ_Pwd_Err_Num(String serv_Pwd_Err_Num) {
		this.serv_Pwd_Err_Num = serv_Pwd_Err_Num;
	}
	
	
}
