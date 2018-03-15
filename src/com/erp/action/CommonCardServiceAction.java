package com.erp.action;

import java.rmi.RemoteException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.axis2.AxisFault;
import org.apache.log4j.Logger;
import org.apache.shiro.SecurityUtils;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseCorp;
import com.erp.model.BasePersonal;
import com.erp.model.BaseSiinfo;
import com.erp.model.CardApply;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardConfig;
import com.erp.model.TrServRec;
import com.erp.service.CardApplyService;
import com.erp.service.CardIssuseService;
import com.erp.service.CardServiceService;
import com.erp.service.PwdService;
import com.erp.service.RechargeService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.viewModel.Page;
import com.erp.webservice.client.SbcxWebserviceStub;
import com.erp.webservice.client.SbcxWebserviceStub.GetSbinfo;
import com.erp.webservice.client.SbcxWebserviceStub.GetSbinfoResponse;

/**----------------------------------------------------*
*@category                                             *
*柜面常用服务操作                                                                                              *
*@author yangn                                         *  
*@date 2016-03-08                                      *
*@email yn_yangning@foxmail.com                        *
*@version 1.0                                          *
*------------------------------------------------------*/
@Namespace(value="/commonCardService")
@Action(value="commonCardServiceAction")
@Results({
	@Result(name="bkIndex",location="/jsp/commonCardService/bkInfo.jsp"),
	@Result(name="hkIndex",location="/jsp/commonCardService/hkInfo.jsp")
})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class CommonCardServiceAction extends BaseAction {
	public Logger log = Logger.getLogger(CommonCardServiceAction.class);
	private static final long serialVersionUID = 1L;
	private BasePersonal bp = new BasePersonal();
	private CardBaseinfo card = new CardBaseinfo();
	private TrServRec rec = new TrServRec();
	private CardApply apply = new CardApply();
	@Resource(name="cardServiceService")
	private CardServiceService cardServiceService;
	@Resource(name="rechargeService")
	private RechargeService rechargeService;
	@Resource(name="pwdService")
	private PwdService pwdService;
	@Resource(name="cardApplyService")
	private CardApplyService cardApplyService;
	@Resource(name="cardIssuseService")
	private CardIssuseService cardIssuseService;
	private String costFeeSelect;
	private String costFee;
	private String isGoodCard;
	
	public String queryCommonMsg(){
		JSONArray cardRows = new JSONArray();
		String costFee = "0.00";
		String urgentFee = "0.00";
		try{
			if(Tools.processNull(bp.getCertNo()).equals("") && 
			   Tools.processNull(card.getSubCardNo()).equals("") && 
			   Tools.processNull(card.getCardNo()).equals("")){
				bp = new BasePersonal();
				throw new CommonException("证件号码或卡号不能全部为空！");
			}
			if(!Tools.processNull(bp.getCertNo()).equals("")){
				bp = (BasePersonal) baseService.findOnlyRowByHql("from BasePersonal t where t.certNo = '" + bp.getCertNo() + "'");
				if(bp == null){
					bp = new BasePersonal();
				}
			}
			if(Tools.processNull(bp.getCertNo()).equals("") && 
			   Tools.processNull(card.getSubCardNo()).equals("") && 
			   Tools.processNull(card.getCardNo()).equals("")){
				bp = new BasePersonal();
				throw new CommonException("根据证件号码未找到人员信息！");
			}
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT T.CARD_ID,T.CARD_NO,T.SUB_CARD_NO,T.CUSTOMER_ID,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CARD_TYPE' AND CODE_VALUE = t.CARD_TYPE) CARDTYPE,");
			sb.append("t.CARD_STATE,NVL2(t.PAY_PWD,0,1) pwd,NVL2(t.PAY_PWD,'已设置','未设置') PWDSET,NVL(t.PAY_PWD_ERR_NUM,0) pwderrnum, ");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CARD_STATE' AND CODE_VALUE = t.CARD_STATE ) CARDSTATE, ");
			sb.append("G.CHG_FLAG,G.REISSUE_FLAG,NVL2(t2.SERV_PWD,'已设置','未设置') PWDSET2 ");
			sb.append("FROM CARD_BASEINFO T join base_personal t2 on t.customer_id = t2.customer_id join CARD_CONFIG G on T.CARD_TYPE = G.CARD_TYPE where 1 = 1 ");
			if(!Tools.processNull(bp.getCustomerId()).equals("")){
				sb.append("AND T.CUSTOMER_ID = '" + bp.getCustomerId() + "' ");
			}
			if(!Tools.processNull(card.getSubCardNo()).equals("")){
				sb.append("AND T.SUB_CARD_NO = '" + card.getSubCardNo() + "' ");
			}
			if(!Tools.processNull(card.getCardNo()).equals("")){
				sb.append("AND T.CARD_NO = '" + card.getCardNo() + "' ");
			}
			sb.append("order by t.card_type asc,t.card_state asc ");
			Page list = baseService.pagingQuery(sb.toString(), page, rows);
			if(list != null && list.getTotalCount() > 0){
				cardRows = list.getAllRs();
				jsonObject.put("cardFlag","0");
			}else{
				jsonObject.put("cardFlag","1");
			}
			JSONObject oneRow = new JSONObject();
			if(Tools.processNull(bp.getCustomerId()).equals("") && cardRows != null && cardRows.size() > 0){
				oneRow = cardRows.getJSONObject(0);
				if(!Tools.processNull(oneRow.getString("CUSTOMER_ID")).equals("")){
					bp = (BasePersonal) baseService.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + oneRow.getString("CUSTOMER_ID") + "'");
					if(bp == null){
						bp = new BasePersonal();
					}
				}
			}else{
				if(cardRows == null || cardRows.size() <= 0){
					//throw new CommonException("根据查询条件未找到卡片信息！");
				}
			}
			if(!Tools.processNull(bp.getCorpCustomerId()).equals("")){
				String corpName = (String) baseService.findOnlyFieldBySql("select corp_name from base_corp where customer_id = '" + bp.getCorpCustomerId() + "'");
				bp.setRegionName(corpName);//借用regionName 字段把单位名称传到页面
			}
			if(Tools.processNull(bp.getCustomerId()).equals("")){
				jsonObject.put("personFlag","1");
			}else{
				jsonObject.put("personFlag","0");
			}
			CardConfig config = (CardConfig) baseService.findOnlyRowByHql("from CardConfig t where t.cardType = '" + Constants.CARD_TYPE_SMZK + "'");
			if(config != null){
				if(!Tools.processNull(config.getCostFee()).equals("")){
					//costFee = Arith.cardreportsmoneydiv(config.getCostFee() + "");
				}
				if(!Tools.processNull(config.getUrgentFee()).equals("")){
					//urgentFee = Arith.cardreportsmoneydiv(config.getUrgentFee() + "");
				}
			}
			if (bp.getCustomerId() == null) {
				throw new CommonException("客户信息不存在.");
			}
			BaseSiinfo baseSiinfo = null;
			if(!Tools.processNull(bp.getCustomerId()).equals("")){
				baseSiinfo = (BaseSiinfo) baseService.findOnlyRowByHql("from BaseSiinfo b where b.customerId = '" + bp.getCustomerId() + "'");
			}
			if (baseSiinfo == null) {
				baseSiinfo = new BaseSiinfo();
				jsonObject.put("sbInfoFlag", "1");
			}else{
				jsonObject.put("sbInfoFlag", "0");
			}
			BaseCorp baseCorp = null;
			if(!Tools.processNull(bp.getCorpCustomerId()).equals("")){
				baseCorp = (BaseCorp) baseService.findOnlyRowByHql("from BaseCorp b where b.customerId = '" + bp.getCorpCustomerId() + "'");
			}
			JSONObject phQuery = (JSONObject) phQuery();
			jsonObject.put("phQuery", phQuery);
			jsonObject.put("corp", baseCorp);
			jsonObject.put("sbInfo", baseSiinfo);
			jsonObject.put("costFee",costFee);
			jsonObject.put("urgentFee",urgentFee);
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		jsonObject.put("rows",cardRows);
		jsonObject.put("person",bp);
		return this.JSONOBJ;
	}
	
	public Object phQuery(){
		JSONObject parse1 = null;
		JSONObject parse2 = null;
		JSONObject parse3 = null;
		try {
			SbcxWebserviceStub stub = new SbcxWebserviceStub();
			GetSbinfo getSbinfo = new GetSbinfo();
			JSONObject params = new JSONObject();
			//交换节点
			params.put("jhjd", "330482");
			//交易类型
			params.put("jylx", "1000");
			//身份证号
			params.put("sfzh", bp.getCertNo());
			//姓名
			params.put("xm", bp.getName());
			
			getSbinfo.setInteractXml(params.toJSONString());
			GetSbinfoResponse res = stub.GetSbinfo(getSbinfo);
			parse1 = JSONObject.parseObject(res.get_return());
			String sbbh = parse1.get("sbbh").toString();
			
			params.clear();
			//交换节点
			params.put("jhjd", "330482");
			//交易类型
			params.put("jylx", "1023");
			//社保编号
			params.put("sbbh", sbbh);
			//身份证号
			params.put("sfzh", bp.getCertNo());
			//姓名
			params.put("xm", bp.getName());
			
			
			getSbinfo.setInteractXml(params.toJSONString());
			GetSbinfoResponse res1 = stub.GetSbinfo(getSbinfo);
			parse2 = JSONObject.parseObject(res1.get_return());
			
			params.clear();
			//交换节点
			params.put("jhjd", "330482");
			//交易类型
			params.put("jylx", "1025");
			//社保编号
			params.put("sbbh", sbbh);
			//身份证号
			params.put("sfzh", bp.getCertNo());
			//姓名
			params.put("xm", bp.getName());
			
			
			getSbinfo.setInteractXml(params.toJSONString());
			GetSbinfoResponse res2 = stub.GetSbinfo(getSbinfo);
			parse3 = JSONObject.parseObject(res2.get_return());
			parse3.put("cpname", "海森堡");
			parse3.putAll(parse1);
			parse3.putAll(parse2);
			
			
		}  catch (Exception e) {
			e.printStackTrace();
		}
		return parse3;
	}
	
	
	
	
	public String bkCardIndex(){
		try{
			CardConfig cfg = (CardConfig) baseService.findOnlyRowByHql("from CardConfig t where t.cardType = '" + Constants.CARD_TYPE_SMZK + "'");
			if(cfg == null){
				throw new CommonException("未找到全功能卡卡类型参数设置信息！");
			}
			costFee = Arith.cardreportsmoneydiv(Tools.processNull(cfg.getCostFee()).equals("") ? "0" : cfg.getCostFee() + "");
			costFeeSelect = "[";
			costFeeSelect += "{value:'0',text:'0.00'},";
			costFeeSelect += "{value:'" + costFee + "',text:'" + costFee + "','selected':true}]";
		}catch(Exception e){
			log.error(e);
			this.defaultErrorMsg = e.getMessage();
		}
		return "bkIndex";
	}
	public String hkCardIndex(){
		try{
			CardConfig cfg = (CardConfig) baseService.findOnlyRowByHql("from CardConfig t where t.cardType = '" + Constants.CARD_TYPE_SMZK + "'");
			if(cfg == null){
				throw new CommonException("未找到全功能卡卡类型参数设置信息！");
			}
			List<?> allReason = baseService.findBySql("select code_name,code_value from sys_code where code_type = 'CHG_CARD_REASON' and code_state = '0'");
			String tempstring = "";
			if(allReason != null && allReason.size() > 0){
				for(int i = 0;i < allReason.size() ;i++){
					Object[] o = (Object[]) allReason.get(i);
					if(o[1].toString().equals(Constants.CHG_CARD_REASON_ZLWT)){
						if(SecurityUtils.getSubject().isPermitted("chgCardNoMoney")){
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
			isGoodCard = tempstring;
			costFee = Arith.cardreportsmoneydiv(Tools.processNull(cfg.getCostFee()).equals("") ? "0" : cfg.getCostFee() + "");
		}catch(Exception e){
			log.error(e);
			this.defaultErrorMsg = e.getMessage();
		}
		return "hkIndex";
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
	 * @return the apply
	 */
	public CardApply getApply() {
		return apply;
	}
	/**
	 * @param apply the apply to set
	 */
	public void setApply(CardApply apply) {
		this.apply = apply;
	}
	/**
	 * @return the cardServiceService
	 */
	public CardServiceService getCardServiceService() {
		return cardServiceService;
	}
	/**
	 * @param cardServiceService the cardServiceService to set
	 */
	public void setCardServiceService(CardServiceService cardServiceService) {
		this.cardServiceService = cardServiceService;
	}
	/**
	 * @return the rechargeService
	 */
	public RechargeService getRechargeService() {
		return rechargeService;
	}
	/**
	 * @param rechargeService the rechargeService to set
	 */
	public void setRechargeService(RechargeService rechargeService) {
		this.rechargeService = rechargeService;
	}
	/**
	 * @return the pwdService
	 */
	public PwdService getPwdService() {
		return pwdService;
	}
	/**
	 * @param pwdService the pwdService to set
	 */
	public void setPwdService(PwdService pwdService) {
		this.pwdService = pwdService;
	}
	/**
	 * @return the cardApplyService
	 */
	public CardApplyService getCardApplyService() {
		return cardApplyService;
	}
	/**
	 * @param cardApplyService the cardApplyService to set
	 */
	public void setCardApplyService(CardApplyService cardApplyService) {
		this.cardApplyService = cardApplyService;
	}
	/**
	 * @return the cardIssuseService
	 */
	public CardIssuseService getCardIssuseService() {
		return cardIssuseService;
	}
	/**
	 * @param cardIssuseService the cardIssuseService to set
	 */
	public void setCardIssuseService(CardIssuseService cardIssuseService) {
		this.cardIssuseService = cardIssuseService;
	}
	/**
	 * @return the costFeeSelect
	 */
	public String getCostFeeSelect() {
		return costFeeSelect;
	}
	/**
	 * @param costFeeSelect the costFeeSelect to set
	 */
	public void setCostFeeSelect(String costFeeSelect) {
		this.costFeeSelect = costFeeSelect;
	}
	/**
	 * @return the costFee
	 */
	public String getCostFee() {
		return costFee;
	}
	/**
	 * @param costFee the costFee to set
	 */
	public void setCostFee(String costFee) {
		this.costFee = costFee;
	}
	/**
	 * @return the isGoodCard
	 */
	public String getIsGoodCard() {
		return isGoodCard;
	}
	/**
	 * @param isGoodCard the isGoodCard to set
	 */
	public void setIsGoodCard(String isGoodCard) {
		this.isGoodCard = isGoodCard;
	}
}
