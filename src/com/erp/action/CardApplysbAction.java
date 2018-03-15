package com.erp.action;

import javax.annotation.Resource;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.Users;
import com.erp.service.PersonInfoErrataService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**
 * 社保申领 --- 嘉兴特有功能Service类公用勘误业务处理类personInfoErrataService（由于勘误也是嘉兴的特有功能）
 * @author hujc
 * @version 1.0
 * @email hjc@eracloud.cn
 * 2015-12-09
 */
@SuppressWarnings("serial")
@Namespace(value="/cardApplysbAction")
@Action(value="cardApplysbAction")
@Results({
	/*@Result(name="personlist",location="/jsp/cardApp/selectedpersonlist.jsp")*/
})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class CardApplysbAction extends BaseAction {
	@Resource(name = "personInfoErrataService")
	private PersonInfoErrataService personInfoErrataService;
	private String sort;
	private String order;
	private String queryType = "1";//查询标志
	private String corpId;//单位编号
	private String corpName;//单位名称
	private String recvBrchId;//领卡网点
	private String selectedId;//勾选编号
	private String name;
	private String certNo;
	private String startDate;
	private String endDate;
	private String applyState;
	private String applyIds;
	private String cardType;
	
	/**
	 * Description <p>社保申领信息查询</p>
	 * @return
	 */
	public String toQuerySbApplyInfo(){
		try {
			this.initGrid();
			StringBuffer sqlHead = new StringBuffer("");
			sqlHead.append("SELECT T.EMP_ID EMP_ID1,T.EMP_ID EMP_ID,T.EMP_NAME EMP_NAME,T.COMPANYID COMPANYID,");
			sqlHead.append("(SELECT B.BRCH_ID FROM SYS_BRANCH B WHERE B.BRCH_ID = T1.LK_BRCH_ID ) RECV_BRCH_ID, ");
			sqlHead.append("(SELECT B.FULL_NAME FROM SYS_BRANCH B WHERE B.BRCH_ID = T1.LK_BRCH_ID ) RECV_BRCH_NAME,");
			sqlHead.append("COUNT(1) APPLY_NUM FROM CARD_APPLY_SB T, BASE_CORP T1 WHERE T.EMP_ID = T1.CUSTOMER_ID ");
			sqlHead.append("AND T.SB_APPLY_STATE = '" + Constants.CARD_APPLY_SB_STATE_DSL + "'");
			sqlHead.append("AND NOT EXISTS (SELECT 1 FROM CARD_APPLY A,BASE_PERSONAL B WHERE A.CUSTOMER_ID = B.CUSTOMER_ID AND B.CERT_NO = T.CERT_NO ");
			sqlHead.append("AND (A.APPLY_STATE < '" + Constants.APPLY_STATE_YZX + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_WJWSHBTG + "' ");
			sqlHead.append("AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_YHSHBTG  + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_STSHBTG + "'))");
			if(!Tools.processNull(corpId).equals("")){
				sqlHead.append(" and t.emp_id = '" + corpId + "' ");
			}
			if(!Tools.processNull(corpName).equals("")){
				sqlHead.append(" and t.emp_name = '" + corpName + "' ");
			}
			if(!Tools.processNull(recvBrchId).equals("")){
				sqlHead.append(" and t.RECV_BRCH_ID = '" + recvBrchId + "' ");
			}
			sqlHead.append("GROUP BY T.EMP_ID,T.EMP_NAME,T.COMPANYID,T1.LK_BRCH_ID ");
			Page list = personInfoErrataService.pagingQuery(sqlHead.toString(), page, rows);
			if (list.getAllRs() != null && list.getAllRs().size() > 0) {
				jsonObject.put("rows", list.getAllRs());
				jsonObject.put("total", list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未找到对应的社保申领信息！");
			}
		}catch(Exception e) {
			jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 
	 * Description <p>预览申领人员信息</p>
	 * @return
	 */
	public String viewSbApplyDetail(){
		try {
			this.initGrid();
			StringBuffer sqlHead = new StringBuffer("");
			StringBuffer sqlwhere = new StringBuffer("");
			sqlHead.append("select t.EMP_ID EMP_ID,t.EMP_NAME EMP_NAME,t.cert_no CERT_NO,t.name NAME, t.RECV_BRCH_ID RECV_BRCH_ID,"
					+ " t1.FULL_NAME RECV_BRCH_NAME,t.COMPANYID COMPANYID,to_char(t.apply_date,'yyyy-mm-dd hh24:mi:ss') APPLY_DATE "
					+ " from CARD_APPLY_SB t,SYS_BRANCH t1 where t.RECV_BRCH_ID=t1.brch_id(+) and t.SB_APPLY_STATE = '"
					+ Constants.CARD_APPLY_SB_STATE_DSL+"'");
			if(!Tools.processNull(selectedId).equals("")){
				sqlwhere.append(" and t.emp_id = '"+selectedId+"'");
			}
			Page list = personInfoErrataService.pagingQuery(sqlHead.toString()+sqlwhere.toString(), page, rows);
			
			if (list.getAllRs() != null && list.getAllRs().size() > 0) {
				jsonObject.put("rows", list.getAllRs());
				jsonObject.put("total", list.getTotalCount());
			} else {
				throw new CommonException("根据查询条件未找到对应的社保申领明细信息！");
			}
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 
	 * Description <p>保存社保申领数据</p>
	 * @return
	 */
	public String saveSbApplyInfo(){
		jsonObject.put("status", false);
		jsonObject.put("title", "错误信息");
		jsonObject.put("message", "");
		try {
			if(Tools.processNull(selectedId).equals("")){
				throw new CommonException("未选择任何申领信息");
			}
			SysActionLog actionLog = personInfoErrataService.getCurrentActionLog();
			Users user = personInfoErrataService.getUser();
			personInfoErrataService.saveSbApplyInfo(actionLog, user, selectedId);
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status", false);
			jsonObject.put("title", "错误信息");
			jsonObject.put("message", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String sbApplyQuery(){
		try {
			// 更新社保申领信息
			personInfoErrataService.updateSbApply();
			//
			initGrid();
			String sql = "select t.*, t2.full_name RECV_BRCH_NAME from CARD_APPLY_SB t left join sys_branch t2 on t.recv_brch_id = t2.brch_id where 1 = 1 ";
			if(!Tools.processNull(corpId).equals("")){
				sql += "and t.emp_id = '" + corpId + "' ";
			} else if(!Tools.processNull(corpName).equals("")){
				sql += "and t.emp_name like '%" + corpName + "%' ";
			}
			if(!Tools.processNull(certNo).equals("")){
				sql += "and t.cert_no = '" + certNo + "' ";
			} else if(!Tools.processNull(name).equals("")){
				sql += "and t.name = '" + name + "' ";
			}
			if(!Tools.processNull(startDate).equals("")){
				sql += "and t.apply_date >= to_date('" + startDate + "', 'yyyy-mm-dd') ";
			}
			if(!Tools.processNull(endDate).equals("")){
				sql += "and t.apply_date <= to_date('" + endDate + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			if(!Tools.processNull(applyState).equals("")){
				sql += "and t.sb_apply_state = '" + applyState + "' ";
			}
			if(!Tools.processNull(recvBrchId).equals("")){
				sql += "and t.recv_brch_id = '" + recvBrchId + "' ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			}
			
			Page data = baseService.pagingQuery(sql, page, rows);
			if(data == null || data.getAllRs() == null || data.getAllRs().isEmpty()){
				throw new CommonException("根据条件找不到数据");
			}
			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		
		return JSONOBJ;
	}
	
	public String doSbApply() {
		try {
			SysActionLog log = personInfoErrataService.getCurrentActionLog();
			personInfoErrataService.saveSbApply(applyIds, cardType, log);
			jsonObject.put("status", 0);
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * 初始化表格
	 * @throws Exception
	 */
	private void initGrid() throws Exception {
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		jsonObject.put("status", 0);
		jsonObject.put("errMsg", "");
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

	public String getCorpId() {
		return corpId;
	}

	public void setCorpId(String corpId) {
		this.corpId = corpId;
	}

	public String getCorpName() {
		return corpName;
	}

	public void setCorpName(String corpName) {
		this.corpName = corpName;
	}

	public String getRecvBrchId() {
		return recvBrchId;
	}

	public void setRecvBrchId(String recvBrchId) {
		this.recvBrchId = recvBrchId;
	}

	public String getSelectedId() {
		return selectedId;
	}

	public void setSelectedId(String selectedId) {
		this.selectedId = selectedId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
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

	public String getApplyState() {
		return applyState;
	}

	public void setApplyState(String applyState) {
		this.applyState = applyState;
	}

	public String getApplyIds() {
		return applyIds;
	}

	public void setApplyIds(String applyIds) {
		this.applyIds = applyIds;
	}

	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}
}
