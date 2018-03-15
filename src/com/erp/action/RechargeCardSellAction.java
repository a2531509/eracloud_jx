package com.erp.action;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardConfig;
import com.erp.model.CardSaleList;
import com.erp.model.CardSaleRec;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.RechargeCardService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.StringUtils;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

@Namespace(value = "/rechargeCard")
@Action(value = "RechargeCardSellAction")
@InterceptorRefs({ @InterceptorRef("jsondefalut") })
@SuppressWarnings("serial")
public class RechargeCardSellAction extends BaseAction {
	public Log log = LogFactory.getLog(RechargeCardSellAction.class);
	@Autowired
	private RechargeCardService rechargeCardService;
	private CardSaleList cardSaleList = new CardSaleList();
	private List<CardSaleList> salelist = new ArrayList<CardSaleList>();
	private CardSaleRec cardSaleRec = new CardSaleRec();
	private String queryType = "1";// 查询标志
	private String order;//排序 asc 升序 desc 降序
	private String sort;//排序列名
	private BasePersonal personal = new BasePersonal();
	private String certNo = "", cardNo = "", costFee = "", mobileNo = "",startDate ="",endDate = "",agtCertNo="",agtName="",agtTelNo="",dealNoStr="";
	//公交卡销售
	public String foregift;//押金
	public String cost_fee,costFees,totNum,totAmt;//工本费,累计数量

	//非记名畅通卡销售页面参数
	public Long dealNo=0L;//凭证使用
	//非记名卡（礼品卡）批量启用页面参数
	public String cardType; //卡类型
	public String startNum; //起始卡号
	public String endNum; //截至卡号
	public String saleDate;//销售日期

    /**
     * 单张销售查询
     * @return
     */
	public String toOneCardSell() {
		jsonObject.put("status", "0");
		jsonObject.put("errMsg", "");
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		try {
			CardBaseinfo cardBaseinfo=(CardBaseinfo)this.baseService.findOnlyRowByHql(" from Card_Baseinfo t where t.cardNo='"+cardNo+"'");
			jsonObject.put("cardType", cardBaseinfo.getCardType());
			
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
    /**
     * 保存单张销售
     * @return
     */
	public String saveOneCardSell() {
		jsonObject.put("status", "0");
		jsonObject.put("errMsg", "");
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		try {
			Users users=this.baseService.getSessionUser();
			cardSaleRec.setSaleDate(DateUtil.formatDate(saleDate));
			cardSaleRec.setDealCode(DealCode.RECHANGE_CARD_SELL);
			cardSaleRec.setOrgId(users.getOrgId());//机构号
			cardSaleRec.setBrchId(users.getBrchId());//网点号
			cardSaleRec.setUserId(users.getUserId());//操作柜员
			cardSaleRec.setOtherFee(0l);
			cardSaleRec.setTotNum(new Long(totNum==null?"0":totNum));//总数量
			cardSaleRec.setTotAmt(new Long(new BigDecimal(totAmt==null?"0":totAmt).intValue()+""));//总金额
			cardSaleRec.setSndFlag(Constants.SND_FLAG_YSD);//送货标志  0-不送 1-待送 2-正在送 3-已送达
			cardSaleRec.setDrwFlag(Constants.DRW_FLAG_YQ);//取货标志(0-未取 1-已取)\
			cardSaleRec.setPayFlag(Constants.PAY_FLAG_WF);//付款标志  0-未付1-已支付4-已缴款,4-已入帐，8-部分支付，9-完全支付
			cardSaleRec.setSaleState(Constants.STATE_ZC);//状态   0-正常 1-撤销
			cardSaleRec.setVrfFlag(Constants.VRY_FLAG_YP);//审批标志  0-不批 1-待批 2-已批
			cardSaleRec.setCardTypeCatalog(Constants.CARD_TYPE_CATALOG8);
			cardSaleRec.setCustomerType("1");//客户类型1个人2单位，code表中的CLIENT_TYPE_SALE
			cardSaleRec.setStartCardNo(cardNo);//开始卡号
			cardSaleRec.setEndCardNo(cardNo);//结束卡号
			cardSaleRec.setAgtCertNo(agtCertNo);//身份证号
			cardSaleRec.setAgtName(agtName);//姓名
			cardSaleRec.setAgtTelNo(agtTelNo);
			String cardTypes=(String)this.baseService.findOnlyFieldBySql("select card_type from card_task_list l where l.card_no='"+cardNo+"'");
			CardConfig config=(CardConfig)this.baseService.getCardConfigByCardType(Tools.processNull(cardTypes));
			//登记cardSaleList销售登记明细表，记录柜员库存卡的出入流水（Stock）
			cardSaleList.setCardNo(cardNo);//卡号
			cardSaleList.setCardType(cardTypes);//卡类型
			cardSaleList.setFaceVal(config.getFaceVal());//面额---工本费
			cardSaleList.setSaleAmt(config.getFaceVal());//金额(折扣后)--工本费累计
			cardSaleList.setForegift(0l);//押金
			cardSaleList.setOtherFee(0L);//其他金额
			cardSaleList.setListState("0");//明细的状态
			cardSaleList.setCostFee(0L);//工本费
			salelist.add(cardSaleList);
			TrServRec rec=new TrServRec();
			rec.setCardNo(cardNo);//卡号
			rec.setAgtTelNo(agtTelNo);//手机号
			rec.setAgtName(agtName);//姓名
			rec.setAgtCertNo(agtCertNo);//身份证号
			rec.setTelNo(agtTelNo);//联系人电话
			rec.setCardTrCount("1");
			rec.setOrgId(users.getOrgId());//机构编号
			rec.setUserId(users.getUserId());//操作员编号
			rec.setBrchId(users.getBrchId());//网点编号
			SysActionLog actionLog=this.baseService.getCurrentActionLog();
			actionLog.setMessage("充值卡单张销售,卡号："+cardNo);
			rechargeCardService.saveCardSell(cardSaleRec, salelist, rec, actionLog);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
     * 销售撤销
     * @return
     */
	public String saveOneCardUndo() {
		jsonObject.put("status", "0");
		jsonObject.put("errMsg", "");
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		try {
			SysActionLog actionLog=this.baseService.getCurrentActionLog();
			actionLog.setMessage("销售撤销");
			rechargeCardService.deleteCardSell(dealNo, actionLog);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
     * 批量销售
     * @return
     */
	public String toBatchCardSell() {
		jsonObject.put("rows",new JSONArray());//表格数据
		jsonObject.put("status","0");//查询状态
		jsonObject.put("errMsg","");//错误信息
		jsonObject.put("total",0);//总共多少条
		StringBuffer sb=new StringBuffer(512);
		try{
			if(Tools.processNull(this.queryType).equals("0")){
				if(!Tools.processNull(startDate).equals("")){
					sb.append("and to_char(z.deal_time,'yyyy-MM-dd') >='" + this.startDate+"'");
				}
				if(!Tools.processNull(endDate).equals("")){
					sb.append(" and to_char(z.deal_time,'yyyy-MM-dd') <= '" + this.endDate+"'");
				}
				String orderby = "";
				if(!Tools.processNull(this.sort).equals("")){
					orderby += " order by " + this.sort + " " + this.order;
				}
				if(!Tools.processNull(orderby).equals("")){
					sb.append(  orderby );
				}else{
					sb.append(" order by  z.mak_Num desc ");
				}
				Page p = baseService.pagingQuery(sb.toString(),page,rows);
				if(p.getAllRs() != null){
					jsonObject.put("rows",p.getAllRs());
					jsonObject.put("total",p.getTotalCount());
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
			//logger.error(e);
		}
		return this.JSONOBJ;
	}
	/**
     * 保存批量销售
     * @return
     */
	@SuppressWarnings("unchecked")
	public String saveBatchCardSell() {
		jsonObject.put("status", "0");
		jsonObject.put("errMsg", "");
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		try {
			Users users=this.baseService.getSessionUser();
			//登记cardSaleRec销售登记表 
			CardSaleRec cardSaleRec = new CardSaleRec();
			cardSaleRec.setSaleDate(DateUtil.formatDate(saleDate));
			cardSaleRec.setDealCode(DealCode.RECHANGE_CARD_BATCHSELL);
			cardSaleRec.setOrgId(users.getOrgId());//机构号
			cardSaleRec.setBrchId(users.getBrchId());//网点号
			cardSaleRec.setUserId(users.getUserId());//操作柜员
			cardSaleRec.setOtherFee(0l);
			cardSaleRec.setTotNum(Tools.processLong(totNum));//总数量
			cardSaleRec.setTotAmt(Tools.processLong(totAmt));//总金额
			cardSaleRec.setSndFlag(Constants.SND_FLAG_YSD);//送货标志  0-不送 1-待送 2-正在送 3-已送达
			cardSaleRec.setDrwFlag(Constants.DRW_FLAG_YQ);//取货标志(0-未取 1-已取)\
			cardSaleRec.setPayFlag(Constants.PAY_FLAG_YZF);//付款标志  0-未付1-已付支票未确认 2-已进帐
			cardSaleRec.setSaleState(Constants.STATE_ZC);//状态   0-正常 1-撤销
			cardSaleRec.setVrfFlag(Constants.VRY_FLAG_YP);//审批标志  0-不批 1-待批 2-已批
			CardConfig config=(CardConfig)this.baseService.getCardConfigByCardType(cardType);
			//登记TR_SALE_LIST销售登记明细表，记录柜员库存卡的出入流水（STK_DAY_BOOK）
			List<CardSaleList> salelist = new ArrayList<CardSaleList>();
			String cardList="";
			Long gjMoney=0l;
			CardSaleList cardSaleList = new CardSaleList();
			cardSaleList.setCardType(cardType);//卡类型
			cardSaleRec.setStartCardNo(startNum);//开始卡号
			cardSaleRec.setEndCardNo(endNum);//结束卡号
			cardSaleList.setFaceVal(config.getFaceVal());//面额
			cardSaleList.setSaleAmt(config.getFaceVal());//金额
			
			gjMoney=gjMoney+cardSaleList.getFaceVal();
			cardList+=" "+config.getFaceVal()/100+"元卡类型: "+cardSaleRec.getStartCardNo()+"  ---  "+cardSaleRec.getEndCardNo()+" ,  小计数量："+cardSaleRec.getTotNum()+",  小计面额："+cardSaleRec.getTotAmt()/100+"  元;";
			
			salelist.add(cardSaleList);
			/** 非记名卡销售保存 */
			cardSaleRec.setForegiftAmt(new Long(0));
			TrServRec rec=new TrServRec();
			rec.setCardNo(cardNo);//卡号
			rec.setAgtTelNo(agtTelNo);//手机号
			rec.setAgtName(agtName);//姓名
			rec.setAgtCertNo(agtCertNo);//身份证号
			rec.setTelNo(agtTelNo);//电话
			rec.setCardTrCount("1");
			rec.setOrgId(users.getOrgId());//机构编号
			rec.setUserId(users.getUserId());//操作员编号
			rec.setBrchId(users.getBrchId());//网点编号
			rec.setAmt(Tools.processLong(totAmt));
			rec.setCardType(cardType);
			SysActionLog actionLog=this.baseService.getCurrentActionLog();
			actionLog.setMessage("批量充值卡销售,"+cardList);
			rechargeCardService.saveCardSell(cardSaleRec, salelist, rec, actionLog);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
     * 批量启用
     * @return
     */
	public String toBatchCardUsedQuery() {
		jsonObject.put("rows",new JSONArray());//表格数据
		jsonObject.put("status","0");//查询状态
		jsonObject.put("errMsg","");//错误信息
		jsonObject.put("total",0);//总共多少条
		StringBuffer sb=new StringBuffer(512);
		try{
			if(Tools.processNull(this.queryType).equals("0")){
				sb.append("select DEAL_NO,DEAL_NO as DEALNOS,to_char(y.SALE_DATE,'yyyy-mm-dd hh24:mi:ss') SALE_DATE ,(select code_name from sys_Code where code_type='CARD_TYPE_CATALOG' and code_value = y.CARD_TYPE_CATALOG) CARD_TYPE_CATALOG,"
						+ "START_CARD_NO,END_CARD_NO,TOT_NUM,TOT_AMT,(select code_name from sys_Code where code_type='PAY_WAY' and code_value = y.PAY_WAY) PAY_WAY,(select code_name from sys_Code where code_type='INV_FLAG' and code_value = y.INV_FLAG) INV_FLAG,"
						+ "(select code_name from sys_Code where code_type='VRF_FLAG' and code_value = y.VRF_FLAG) VRF_FLAG, y.AGT_NAME,AGT_CERT_NO,AGT_TEL_NO, "
						+ " decode(y.SALE_STATE,'0','正常','1','撤销','') SALE_STATE,USER_ID from  Card_Sale_Rec y where 1=1 ");
				if(!Tools.processNull(startDate).equals("")){
					sb.append("and to_char(y.SALE_DATE,'yyyy-MM-dd') >='" + this.startDate+"'");
				}
				if(!Tools.processNull(endDate).equals("")){
					sb.append(" and to_char(y.SALE_DATE,'yyyy-MM-dd') <= '" + this.endDate+"'");
				}
				String orderby = "";
				if(!Tools.processNull(this.sort).equals("")){
					orderby += " order by " + this.sort + " " + this.order;
				}
				if(!Tools.processNull(orderby).equals("")){
					sb.append(  orderby );
				}else{
					sb.append(" order by  y.SALE_DATE desc ");
				}
				Page p = baseService.pagingQuery(sb.toString(),page,rows);
				if(p.getAllRs() != null){
					jsonObject.put("rows",p.getAllRs());
					jsonObject.put("total",p.getTotalCount());
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
			//logger.error(e);
		}
		return this.JSONOBJ;
	}
	/**
     * 批量启用保存
     * @return
     */
	public String saveBatchCardUsed() {
		jsonObject.put("status", "0");
		jsonObject.put("errMsg", "");
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		try {
			if(Tools.processNull(dealNoStr).equals("")){
				throw new CommonException("请选择记录");
			}
			rechargeCardService.saveCardSellUsed(dealNoStr,this.baseService.getCurrentActionLog());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
     * 销售回款查询
     * @return
     */
	public String sellCardQuery() {
		jsonObject.put("status", "0");
		jsonObject.put("errMsg", "");
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		try {
		
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
     * 销售回款保存
     * @return
     */
	public String saveSellCardBack() {
		jsonObject.put("status", "0");
		jsonObject.put("errMsg", "");
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		try {
		
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}


	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
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

	public BasePersonal getPersonal() {
		return personal;
	}

	public void setPersonal(BasePersonal personal) {
		this.personal = personal;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getCostFee() {
		return costFee;
	}

	public void setCostFee(String costFee) {
		this.costFee = costFee;
	}

	public String getMobileNo() {
		return mobileNo;
	}

	public void setMobileNo(String mobileNo) {
		this.mobileNo = mobileNo;
	}

	public CardSaleList getCardSaleList() {
		return cardSaleList;
	}

	public void setCardSaleList(CardSaleList cardSaleList) {
		this.cardSaleList = cardSaleList;
	}

	public CardSaleRec getCardSaleRec() {
		return cardSaleRec;
	}

	public void setCardSaleRec(CardSaleRec cardSaleRec) {
		this.cardSaleRec = cardSaleRec;
	}

	public void setRechargeCardService(RechargeCardService rechargeCardService) {
		this.rechargeCardService = rechargeCardService;
	}
	public Long getDealNo() {
		return dealNo;
	}
	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}

	public String getAgtName() {
		return agtName;
	}
	public void setAgtName(String agtName) {
		this.agtName = agtName;
	}
	public String getAgtCertNo() {
		return agtCertNo;
	}
	public void setAgtCertNo(String agtCertNo) {
		this.agtCertNo = agtCertNo;
	}
	public String getAgtTelNo() {
		return agtTelNo;
	}
	public void setAgtTelNo(String agtTelNo) {
		this.agtTelNo = agtTelNo;
	}

	public String getCost_fee() {
		return cost_fee;
	}
	public void setCost_fee(String cost_fee) {
		this.cost_fee = cost_fee;
	}

	public String getCardType() {
		return cardType;
	}
	public void setCardType(String cardType) {
		this.cardType = cardType;
	}
	public String getEndNum() {
		return endNum;
	}
	public void setEndNum(String endNum) {
		this.endNum = endNum;
	}
	public String getSaleDate() {
		return saleDate;
	}
	public void setSaleDate(String saleDate) {
		this.saleDate = saleDate;
	}
	public List<CardSaleList> getSalelist() {
		return salelist;
	}
	public void setSalelist(List<CardSaleList> salelist) {
		this.salelist = salelist;
	}
	public String getDealNoStr() {
		return dealNoStr;
	}
	public void setDealNoStr(String dealNoStr) {
		this.dealNoStr = dealNoStr;
	}
	public String getForegift() {
		return foregift;
	}
	public void setForegift(String foregift) {
		this.foregift = foregift;
	}
	public String getCostFees() {
		return costFees;
	}
	public void setCostFees(String costFees) {
		this.costFees = costFees;
	}
	public String getStartNum() {
		return startNum;
	}
	public void setStartNum(String startNum) {
		this.startNum = startNum;
	}
	public String getOrder() {
		return order;
	}
	public void setOrder(String order) {
		this.order = order;
	}
	public String getSort() {
		return sort;
	}
	public void setSort(String sort) {
		this.sort = sort;
	}
	public String getTotNum() {
		return totNum;
	}
	public void setTotNum(String totNum) {
		this.totNum = totNum;
	}
	public String getTotAmt() {
		return totAmt;
	}
	public void setTotAmt(String totAmt) {
		this.totAmt = totAmt;
	}


}
