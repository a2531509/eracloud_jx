/**
 * 
 */
package com.erp.action;

import java.math.BigDecimal;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.erp.exception.CommonException;
import com.erp.model.PayCoCheckList;
import com.erp.model.PayCoCheckSingle;
import com.erp.model.PayOffline;
import com.erp.model.SysActionLog;
import com.erp.service.CorpCheckAccountService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**----------------------------------------------------*
*@category                                             *
*合作机构对账管理 新版                                                                                                   	       *
*合作机构入网登记，合作机构信息审批，合作机构信息变更，                                                      *
*合作机构资格暂停                                                                                                                                  *
*合作机构资格启用 ，合作机构退网登记                                                                                             *
*@author hujchen                                         *  
*@date 2016-10-08                                      *
*@email hujchen@126.com                        *
*@version 1.0                                          *
*------------------------------------------------------*/
@Namespace(value="/corpCheckAccount")
@Action(value="corpCheckAccountAction")
@Results({
	@Result(name="toAddOrEditIndex",location="/jsp/agentorg/cooperationagencyEditDlg.jsp"),
	@Result(name="accTypeEdit",location="/jsp/accManage/acctypeedit.jsp")
})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class CorpCheckAccountAction extends BaseAction{
	
	
	public Logger log = Logger.getLogger(CorpCheckAccountAction.class);
	@Resource(name="corpCheckAccountService")
	private CorpCheckAccountService corpCheckAccountService;
	
	private PayCoCheckSingle sign = new PayCoCheckSingle();
	private PayCoCheckList signList = new PayCoCheckList();
	private String coOrgName;
	private String queryType = "1";
	private String sort;
	private String order;	
	private String checkSignId="";
	private String checkListId="";
	private String merchantId="";
	private String merchantName="";
	private String startClrDate="";
	private String endClrDate="";
	private PayOffline pof = new PayOffline();
	private String dealNo;
	private String checkStartDate;
	private String checkEndDate;
	private String coOrgId;
	private String checkDate;
	private String fileType;
	private String clrDate;
	private String cardType;
	private String accKind;
	
	
	/**
	 * Description <p>获取对账文件</p>
	 * @return
	 */
	public String getCheckFile(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","获取对账文件成功");
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			BigDecimal bg = (BigDecimal)baseService.findOnlyFieldBySql("select count(1) from base_co_org t where t .co_org_id = '"+coOrgId+"' and co_state = '0'");
			if(bg.intValue() == 0){
				throw new CommonException("选择的合作机构在系统内未登记或登记信息不正常！请重新选择。");
			}
			if("".equals(Tools.processNull(coOrgId))){
				throw new CommonException("请输入合作机构编号！");
			}
			if("".equals(Tools.processNull(checkDate))){
				throw new CommonException("请输入对账日期！");
			}
			if("".equals(Tools.processNull(fileType))){
				throw new CommonException("请选择对账类型！");
			}
			corpCheckAccountService.saveGetCheckFile(actionLog, baseService.getUser(), coOrgId, checkDate,fileType);
			
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 获取对账信息
	 * @return
	 */
	public String findAllCheckBill(){
		try{
			this.initBaseDataGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT  t1.ID ID, t1.co_org_id CO_ORG_ID,t2.co_org_name CO_ORG_NAME,t1.check_date CHECK_DATE,decode(t1.file_type,'01','充值','02','消费','03','圈提','04','圈付','未知') file_type,");
				sb.append("decode(t1.proc_state,'0','对账平','1','平账中','2','对账不平明细未上传','3','对账不平明细已上传','其他') PROC_STATE,decode(t1.exist_detail,'0','有','1','无','未知') EXIST_DETAIL,");
				sb.append("decode(t1.dzpzlx,'01','系统平账','02','人工平账','03','未平账','未知') DZPZLX,decode(t1.js_state,'0','未生成','1','已生成','未知') JS_STATE,t1.TOTAL_ZC_SUM TOTAL_ZC_SUM,t1.TOTAL_ZC_AMT TOTAL_ZC_AMT,");
				sb.append("t1.TOTAL_TH_SUM TOTAL_TH_SUM, t1.TOTAL_TH_AMT TOTAL_TH_AMT,t1.TOTAL_CX_SUM TOTAL_CX_SUM,t1.TOTAL_CX_AMT TOTAL_CX_AMT,");
				sb.append("t1.TOTAL_ZCFROMADD_SUM TOTAL_ZCFROMADD_SUM,t1.TOTAL_ZCFROMADD_AMT TOTAL_ZCFROMADD_AMT,t1.TOTAL_THFROMADD_SUM TOTAL_THFROMADD_SUM,");
				sb.append("t1.TOTAL_THFROMADD_AMT TOTAL_THFROMADD_AMT,t1.TOTAL_CXFROMADD_SUM TOTAL_CXFROMADD_SUM,t1.TOTAL_CXFROMADD_AMT TOTAL_CXFROMADD_AMT,");
				sb.append("t1.TOTAL_ZCTOADD_NUM TOTAL_ZCTOADD_NUM,t1.TOTAL_ZCTOADD_AMT TOTAL_ZCTOADD_AMT,t1.TOTAL_THTOADD_NUM TOTAL_THTOADD_NUM,");
				sb.append("t1.TOTAL_THTOADD_AMT TOTAL_THTOADD_AMT,t1.TOTAL_CXTOADD_NUM TOTAL_CXTOADD_NUM,t1.TOTAL_CXTOADD_AMT TOTAL_CXTOADD_AMT,");
				sb.append("t1.SJ_TOTAL_ZC_SUM,t1.SJ_TOTAL_ZC_AMT,t1.TOTAL_THTOADD_NUM SJ_TOTAL_CX_SUM,");
				sb.append("t1.TOTAL_THTOADD_AMT SJ_TOTAL_CX_AMT,t1.TOTAL_CXTOADD_NUM SJ_TOTAL_TH_SUM,t1.TOTAL_CXTOADD_AMT SJ_TOTAL_TH_AMT");
				sb.append(" FROM pay_co_check_single t1,base_co_org t2 WHERE t1.co_org_id = t2.co_org_id(+) and t1.co_org_id not in ("+Constants.CORG_CHECK_OLD_ID+")");
				if(!Tools.processNull(sign.getCoOrgId()).equals("")){
					sb.append("and t1.co_org_id = '" + sign.getCoOrgId() + "' ");
				}
				if(!Tools.processNull(coOrgName).equals("")){
					sb.append("and t2.co_org_name = '" + coOrgName.trim() + "' ");
				}
				if(!Tools.processNull(checkStartDate).equals("")){
					sb.append("and t1.check_date >='" + checkStartDate + "' ");
				}
				if(!Tools.processNull(checkEndDate).equals("")){
					sb.append("and t1.check_date <='" + checkEndDate + "' ");
				}
				if(!Tools.processNull(sign.getProcState()).equals("")){
					sb.append("and t1.proc_State <='" + sign.getProcState() + "' ");
				}
				if(!Tools.processNull(sign.getFileType()).equals("")){
					sb.append("and t1.file_type = '" + sign.getFileType() + "' ");
				}
				if(!Tools.processNull(sign.getExistDetail()).equals("")){
					sb.append("and t1.exist_detail = '" + sign.getExistDetail() + "' ");				
				}
				if(!Tools.processNull(sign.getJsState()).equals("")){
					sb.append("and t1.js_state = '" + sign.getJsState() + "' ");
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("order by t1.check_date desc");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应的结算单信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * Description <p>获取合作机构对账明细</p>
	 * @return
	 */
	public String findAllCheckBillList(){
		try{
			this.initBaseDataGrid();
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("SELECT t1.ID ID,t1.FILEID FILEID, t1.CO_ORG_ID CO_ORG_ID,t2.CO_ORG_NAME CO_ORG_NAME,t1.DEAL_CODE DEAL_CODE,");
				sb.append("(SELECT t3.deal_code_name FROM sys_code_tr t3 WHERE t3.deal_code = t1.deal_code) DEAL_CODE_NAME,");
				sb.append("t1.END_ID END_ID,t1.DEAL_BATCH_NO DEAL_BATCH_NO,t1.END_DEAL_NO END_DEAL_NO,t1.CARD_NO CARD_NO,");
				sb.append("t1.STATE,t1.CARD_NO2 CARD_NO2,");
				sb.append("to_char(t1.DEAL_DATE,'yyyy-mm-dd hh24:mi:ss') DEAL_DATE,t1.BANK_ID BANK_ID,t1.BANK_ACC,t1.user_id USER_ID,");
				sb.append("(SELECT t4.code_name FROM sys_code t4 WHERE t4.code_type = 'ACC_KIND' AND t4.code_value =t1.acc_kind) ACC_KIND_NAME,");
				sb.append("(SELECT t4.code_name FROM sys_code t4 WHERE t4.code_type = 'ACC_KIND' AND t4.code_value =t1.acc_kind2) ACC_KIND2_NAME,");
				sb.append("t1.AMTBEF ,t1.AMT,t1.OLD_ACTION_NO OLD_ACTION_NO,");
				sb.append("DECODE(t1.OPER_STATE,'0','待处理','1','已处理','未知') OPER_STATE,");
				sb.append("DECODE(t1.OPER_TYPE,'01','运营机构确认','02','运营机构撤销','03','合作机构补交易','04','合作机构撤销交易','05','日终自动处理','待处理') OPER_TYPE ");
				sb.append("FROM pay_co_check_list t1,base_co_org t2 WHERE t1.co_org_id =t2.co_org_id(+) and t1.co_org_id not in ("+Constants.CORG_CHECK_OLD_ID+")");
				if(!Tools.processNull(checkSignId).equals("")){
					sb.append("and t1.fileid ='"+checkSignId+"' ");
				}
				if(!Tools.processNull(signList.getCoOrgId()).equals("")){
					sb.append("and t1.co_org_id = '" + signList.getCoOrgId() + "' ");
				}
				if(!Tools.processNull(signList.getEndId()).equals("")){
					sb.append("and t1.end_id '=" + signList.getEndId() + "' ");
				}
				if(!Tools.processNull(signList.getDealBatchNo()).equals("")){
					sb.append("and t1.deal_batch_no = '" + signList.getDealBatchNo() + "' ");
				}
				if(!Tools.processNull(signList.getEndDealNo()).equals("")){
					sb.append("and t1.end_deal_no = '" + signList.getEndDealNo() + "' ");				
				}
				if(!Tools.processNull(signList.getCardNo()).equals("")){
					sb.append("and t1.card_No = '" + signList.getCardNo() + "' ");
				}
				if(!Tools.processNull(signList.getState()).equals("")){
					sb.append("and t1.state = '" + signList.getState() + "' ");
				}
				if(!Tools.processNull(signList.getOperState()).equals("")){
					sb.append("and t1.oper_state = '" + signList.getOperState() + "' ");
				}
				
				if(!Tools.processNull(this.sort).equals("")){
					sb.append("order by " + this.sort + " " + this.order);
				}else{
					sb.append("order by t1.end_deal_no desc, t1.deal_date desc");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应的结算单信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 合作机构补交易
	 * @return
	 */
	public String dealdzcorepair(){
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			corpCheckAccountService.saveDealdzcorepair(checkListId, baseService.getUser(), actionLog);
			jsonObject.put("status",0);
			jsonObject.put("errMsg","合作机构补交易成功");
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 运营机构撤销
	 * @return
	 */
	public String dealdzorgcancel(){
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			corpCheckAccountService.saveDealdzorgcancel(checkListId, baseService.getUser(), actionLog);
			jsonObject.put("status",0);
			jsonObject.put("errMsg","运营机构撤销");
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 运营机构补交易
	 * @return
	 */
	public String dealdzorgadd(){
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			corpCheckAccountService.saveDealdzorgadd(checkListId, baseService.getUser(), actionLog);
			jsonObject.put("status",0);
			jsonObject.put("errMsg","运营机构补交易");
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 合作机构删除
	 * @return
	 */
	public String dealdzdeletemx(){
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			corpCheckAccountService.saveDealdzdeletemx(checkListId, baseService.getUser(), actionLog);
			jsonObject.put("status",0);
			jsonObject.put("errMsg","合作机构删除成功");
		} catch (Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	
	public PayCoCheckSingle getSign() {
		return sign;
	}

	public void setSign(PayCoCheckSingle sign) {
		this.sign = sign;
	}

	public PayCoCheckList getSignList() {
		return signList;
	}

	public void setSignList(PayCoCheckList signList) {
		this.signList = signList;
	}

	public String getCoOrgName() {
		return coOrgName;
	}

	public void setCoOrgName(String coOrgName) {
		this.coOrgName = coOrgName;
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

	public String getCheckSignId() {
		return checkSignId;
	}

	public void setCheckSignId(String checkSignId) {
		this.checkSignId = checkSignId;
	}

	public String getCheckListId() {
		return checkListId;
	}

	public void setCheckListId(String checkListId) {
		this.checkListId = checkListId;
	}

	public String getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getStartClrDate() {
		return startClrDate;
	}

	public void setStartClrDate(String startClrDate) {
		this.startClrDate = startClrDate;
	}

	public String getEndClrDate() {
		return endClrDate;
	}

	public void setEndClrDate(String endClrDate) {
		this.endClrDate = endClrDate;
	}

	public PayOffline getPof() {
		return pof;
	}

	public void setPof(PayOffline pof) {
		this.pof = pof;
	}

	public String getDealNo() {
		return dealNo;
	}

	public void setDealNo(String dealNo) {
		this.dealNo = dealNo;
	}

	public String getCheckStartDate() {
		return checkStartDate;
	}

	public void setCheckStartDate(String checkStartDate) {
		this.checkStartDate = checkStartDate;
	}

	public String getCheckEndDate() {
		return checkEndDate;
	}

	public void setCheckEndDate(String checkEndDate) {
		this.checkEndDate = checkEndDate;
	}

	public String getCoOrgId() {
		return coOrgId;
	}

	public void setCoOrgId(String coOrgId) {
		this.coOrgId = coOrgId;
	}

	public String getCheckDate() {
		return checkDate;
	}

	public void setCheckDate(String checkDate) {
		this.checkDate = checkDate;
	}

	public String getFileType() {
		return fileType;
	}

	public void setFileType(String fileType) {
		this.fileType = fileType;
	}

	public String getClrDate() {
		return clrDate;
	}

	public void setClrDate(String clrDate) {
		this.clrDate = clrDate;
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

	
}
