package com.erp.action;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.log4j.Logger;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.orm.hibernate4.HibernateOptimisticLockingFailureException;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.PayCarTotal;
import com.erp.model.PayCarreform;
import com.erp.model.SysActionLog;
import com.erp.service.PayCarreFormService;
import com.erp.util.Constants;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**
 * @author Yueh
 */
@Namespace("/payCarreForm")
@Action("payCarreFormAction")
@Results({
		@Result(name = "batchDetailIndex", location = "/jsp/carreForm/batchDetailIndex.jsp"),
		@Result(name = "editPayCarreFormPage", location = "/jsp/carreForm/editPayCarreFormPage.jsp") })
public class PayCarreFormAction extends BaseAction {
	private static final long serialVersionUID = 1L;
	public Logger log = Logger.getLogger(PayCarreFormAction.class);
	//
	public static final String STATUS = "status";
	public static final String STATUS_SUCCESS = "0";
	public static final String STATUS_FAIL = "1";
	public static final String ERR_MSG = "errMsg";
	//
	public static final String PAGE_TOTAL = "total";
	public static final String PAGE_ROWS = "rows";
	//private static final String FAIL_LIST = "failList";

	@Resource
	private PayCarreFormService payCarreFormService;

	//
	private PayCarreform payCarreform = new PayCarreform();
	private PayCarTotal payCarTotal = new PayCarTotal();
	private PayCarreform newPayCarreform = new PayCarreform();
	
	private String reqData = "";

	//
	private String startDate;
	private String endDate;
	private String sort;
	private String order;

	public String queryBatchInfos() {
		try {
			initGrid();

			String sql = "select t.batch_number, t.provide_year, t.provide_month, t.provide_day, "
					+ "t.emp_name, num, t.amt, t.recharge_num, t.recharge_amt, t.fail_num, "
					+ "t.state from pay_car_total t where 1 = 1 ";

			if (!Tools.processNull(payCarTotal.getBatchNumber()).equals("")) {
				sql += "and t.batch_number = '" + payCarTotal.getBatchNumber() + "' ";
			}

			if (!Tools.processNull(payCarTotal.getEmpName()).equals("")) {
				sql += "and t.emp_name like '%" + payCarTotal.getEmpName()
						+ "%' ";
			}

			if (!Tools.processNull(payCarTotal.getState()).equals("")) {
				sql += "and t.state = '" + payCarTotal.getState() + "' ";
			}

			if (!Tools.processNull(startDate).equals("")) {
				sql += "and t.provide_year||'-'||t.provide_month >= '" + startDate + "' ";

				if (!Tools.processNull(endDate).equals("")) {
					sql += "and t.provide_year||'-'||t.provide_month <= '" + endDate + "' ";
				}
			}

			if (!Tools.processNull(sort).equals("")) {
				sql += " order by " + sort;

				if (!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			} else {
				sql += " order by t.batch_number desc";
			}

			Page pageData = payCarreFormService.pagingQuery(sql, page, rows);

			buildJson4Page(pageData);
		} catch (Exception e) {
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, e.getMessage());
		}
		return JSONOBJ;
	}

	public String queryBatchDetails() {
		try {
			initGrid();

			String sql = "select t.batch_number, t.provide_year, t.provide_month, "
					+ "t.cert_no, t.name, t.emp_name, t.card_no, to_char(t.provide_amt/100,'9999999990.00')amt, "
					+ "t.state, to_char(t.rechg_date, 'yyyy-mm-dd') rechg_date, t.rechg_action_no, t.failure_reason "
					+ "from pay_carreform t where 1 = 1 ";

			if (payCarreform.getId() != null && !Tools.processNull(payCarreform.getId().getBatchNumber()).equals("")) {
				sql += "and t.batch_number = '"
						+ payCarreform.getId().getBatchNumber() + "' ";
			}

			if (payCarreform.getId() != null && !Tools.processNull(payCarreform.getId().getCertNo()).equals("")) {
				sql += "and t.cert_no like '%" + payCarreform.getId().getCertNo() + "%' ";
			}

			if (!Tools.processNull(payCarreform.getEmpName()).equals("")) {
				sql += "and t.emp_name like '%" + payCarreform.getEmpName() + "%' ";
			}

			if (!Tools.processNull(payCarreform.getState()).equals("")) {
				sql += "and t.state = '" + payCarreform.getState() + "' ";
			}

			if (!Tools.processNull(payCarreform.getName()).equals("")) {
				sql += "and t.name like '%" + payCarreform.getName() + "%' ";
			}

			if (!Tools.processNull(payCarreform.getCardNo()).equals("")) {
				sql += "and t.card_no like '%" + payCarreform.getCardNo() + "%' ";
			}

			if (!Tools.processNull(startDate).equals("")) {
				sql += "and to_date(t.provide_year||'-'||t.provide_month,'yyyy-mm')>=to_date('"
						+ startDate + "', 'yyyy-mm-dd') ";

				if (!Tools.processNull(endDate).equals("")) {
					sql += "and to_date(t.provide_year||'-'||t.provide_month,'yyyy-mm')<=to_date('"
							+ endDate + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ";
				}
			}

			sql = build4Sort(sql);

			Page pageData = payCarreFormService.pagingQuery(sql, page, rows);

			buildJson4Page(pageData);
		} catch (Exception e) {
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, e.getMessage());
		}
		return JSONOBJ;
	}

	public String toBatchDetailIndex() {
		return "batchDetailIndex";
	}

	public String modifyPayCarreForm() {
		try {
			payCarreFormService.modifyPayCarreForm(payCarreform, newPayCarreform);
		} catch (Exception e) {
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, e.getMessage());
		}
		return JSONOBJ;
	}

	public String editPayCarreFormPage() {
		if (payCarreform.getId() != null && payCarreform.getId().getBatchNumber() != null && payCarreform.getId().getCertNo() != null) {
			payCarreform = (PayCarreform) payCarreFormService.findOnlyRowByHql("from PayCarreform where id.batchNumber = '"
							+ payCarreform.getId().getBatchNumber() + "' and id.certNo = '" + payCarreform.getId().getCertNo() + "'");
		}

		return "editPayCarreFormPage";
	}

	public String batchIdentify() {
		try {
			if(reqData.equals("")){
				throw new CommonException("充值数据为空.");
			}
			
			List<PayCarTotal> carTotals = new ArrayList<PayCarTotal>();
			for(String batchNumber:reqData.split(",")){
				PayCarTotal payCarTotal = new PayCarTotal(Long.valueOf(batchNumber));
				carTotals.add(payCarTotal);
			}
			
			String errMsg = "";
			if(!carTotals.isEmpty()){
				for(PayCarTotal payCarTotal:carTotals){
					try {
						SysActionLog log = (SysActionLog) BeanUtils.cloneBean(payCarreFormService.getCurrentActionLog());
						payCarreFormService.saveBatchIdentify(payCarTotal, log);
					} catch (Exception e) {
						log.error(e);
						errMsg += "【" + payCarTotal.getBatchNumber() + "】" + e.getMessage() + "<br>";
						continue;
					}
				}
			}

			if(!errMsg.equals("")){
				jsonObject.put(ERR_MSG, errMsg);
			}
			jsonObject.put(STATUS, STATUS_SUCCESS);
		} catch (HibernateOptimisticLockingFailureException e) {// 乐观锁异常
			log.error(e);
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, "系统忙, 请重试.");
		} catch (Exception e) {
			log.error(e);
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, e.getMessage());
		}
		return JSONOBJ;
	}

	@SuppressWarnings("unchecked")
	public String batchRecharge() {
		try {
			if(reqData.equals("")){
				throw new CommonException("充值数据为空.");
			}
			
			String errMsg = "";
			SysActionLog currentActionLog = payCarreFormService.getCurrentActionLog();
			for (String batchNumber : reqData.split(",")) {// 每个批次
				// 批次
				PayCarTotal payCarTotal2 = (PayCarTotal) payCarreFormService.findOnlyRowByHql("from PayCarTotal where batchNumber = '" + batchNumber + "'");
				if (payCarTotal2 == null) {
					throw new CommonException("批量充值数据[" + batchNumber + "]不存在.");
				} else if (!Constants.PAY_CAR_TOTAL_STATE_CHECKED.equals(payCarTotal2.getState())
						&& !Constants.PAY_CAR_TOTAL_STATE_RECHARGE_FAILED.equals(payCarTotal2.getState())
						&& !Constants.PAY_CAR_TOTAL_STATE_PART_RECHARGE.equals(payCarTotal2.getState())) {
					throw new CommonException("批量充值数据[" + payCarTotal2.getBatchNumber() + "]不是[已确认, 充值失败, 部分充值]状态, 不能充值.");
				}
				
				// 明细
				List<PayCarreform> payCarreforms = payCarreFormService.findByHql("from PayCarreform where id.batchNumber = " + payCarTotal2.getBatchNumber());
				if (payCarreforms == null || payCarreforms.isEmpty()) {
					throw new CommonException("批量充值数据[" + payCarTotal2.getBatchNumber() + "]充值明细数据不存在.");
				}
				for (PayCarreform payCarreform : payCarreforms) {// 每个人
					try {
						if(!Constants.PAY_CARREFOEM_STATE_CHECKED.equals(payCarreform.getState())&&!Constants.PAY_CARREFOEM_STATE_RECHARGE_FAILED.equals(payCarreform.getState())){
							continue;
						}
						SysActionLog log = (SysActionLog) BeanUtils.cloneBean(currentActionLog);
						payCarreFormService.saveRecharge(payCarreform, log);
					} catch (Exception e) { // 失败更新状态
						payCarreform.setState(Constants.PAY_CARREFOEM_STATE_RECHARGE_FAILED);// 失败
						payCarreform.setFailureReason(e.getMessage());
						payCarreFormService.updatePayCarreform(payCarreform);
						errMsg += "【姓名：" + payCarreform.getName() + "，卡号：" + payCarreform.getCardNo() + "】" + e.getMessage() + "<br>";
					}
				}

				payCarreFormService.updatePayCarTotal(payCarTotal2);
			}
			
			if(!errMsg.equals("")){
				jsonObject.put(ERR_MSG, errMsg);
			}
			jsonObject.put(STATUS, STATUS_SUCCESS);
		} catch (HibernateOptimisticLockingFailureException e) {// 乐观锁异常
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, "系统忙, 请重试.");
		} catch (Exception e) {
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, e.getMessage());
		}
		
		return JSONOBJ;
	}
	
	public String invalidPayCarreForm(){
		try {
			if(reqData.equals("")){
				throw new CommonException("充值数据为空.");
			}
			
			List<PayCarTotal> carTotals = new ArrayList<PayCarTotal>();
			
			for(String batchNumber:reqData.split(",")){
				PayCarTotal payCarTotal = new PayCarTotal(Long.valueOf(batchNumber));
				carTotals.add(payCarTotal);
			}
			
			String errMsg = "";
			
			if (!carTotals.isEmpty()) {
				for (PayCarTotal payCarTotal : carTotals) {
					try {
						payCarreFormService.saveInvalid(payCarTotal);
					} catch (Exception e) {
						errMsg += e.getMessage();
						continue;
					}
				}
			}
			
			if(!errMsg.equals("")){
				throw new CommonException(errMsg);
			}

			jsonObject.put(STATUS, STATUS_SUCCESS);
		} catch (HibernateOptimisticLockingFailureException e) {// 乐观锁异常
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, "系统忙, 请重试.");
		} catch (Exception e) {
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String carreFormDetail(){
		try{
			if(Tools.processNull(this.startDate).equals("")){
				throw new CommonException("请选择起始日期！");
			}
			if(Tools.processNull(this.endDate).equals("")){
				throw new CommonException("请选择结束日期！");
			}
			List<?> allTables = baseService.findBySql("select t.table_name from user_tables t where t.table_name >= 'ACC_INOUT_DETAIL_" + 
				Tools.processNull(this.startDate).replaceAll("-","").substring(0,6) + "' and t.table_name <= 'ACC_INOUT_DETAIL_" + 
				Tools.processNull(this.endDate).replaceAll("-","").substring(0,6) + "' and t.table_name like 'ACC_INOUT_DETAIL_______' "
			);
			if(allTables == null || allTables.size() <= 0){
				throw new CommonException("查询日期范围超过期限，相关表信息不存在！");
			}
			String tables = "(";
			for(int i = 0;i < allTables.size();i++){
				tables += "select * from " + allTables.get(i) + " where deal_code = '" + DealCode.CG_CORP_ACC_BATCH_RECHARGE + 
				"' and clr_date >= '" + this.startDate  + "' and clr_date <= '" + this.endDate + "' ";
				if(i != allTables.size() - 1){
					tables += "union all ";
				}
			}
			tables += ") t ";
			this.initBaseDataGrid();
			StringBuffer sb = new StringBuffer();
			sb.append("select t.acc_inout_no,b.name,b.cert_no,c.card_no,nvl(t.cr_amt,0)/100 amt,");
			sb.append("(select code_name from sys_code where code_type = 'ACC_KIND' and code_value = t.cr_acc_kind) accname,");
			sb.append("to_char(t.deal_date,'yyyy-mm-dd hh24:mi:ss') dealdate,t.acpt_id,s.full_name,t.user_id,u.name username,p.corp_name ");
			sb.append("from " + tables + ",card_baseinfo c,base_personal b,base_corp p,sys_branch s,sys_users u ");
			sb.append("where t.cr_card_no = c.card_no and c.customer_id = b.customer_id(+) and t.db_customer_id = p.customer_id ");
			sb.append("and t.deal_code = '" + DealCode.CG_CORP_ACC_BATCH_RECHARGE + "' and t.acpt_id = s.brch_id(+) and t.user_id = u.user_id(+) and t.deal_state = '0' ");
			if(!Tools.processNull(payCarreform.getCardNo()).equals("")){
				sb.append("and t.cr_card_no = '" + payCarreform.getCardNo() + "' ");
			}
			if(!Tools.processNull(payCarreform.getCorpId()).equals("")){
				sb.append("and b.cert_no = '" + payCarreform.getCorpId() + "' ");
			}
			if(!Tools.processNull(this.sort).equals("")){
				sb.append("order by " + this.sort + " " + this.order);
			}else{
				sb.append("order by t.deal_date desc");
			}
			Page list = baseService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("未查询到车改充值信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	// TODO

	private void initGrid() {
		jsonObject.put(PAGE_ROWS, new JSONArray());// 记录行数
		jsonObject.put(PAGE_TOTAL, 0);// 总条数
		jsonObject.put(STATUS, 0);// 查询状态
		jsonObject.put(ERR_MSG, "");// 错误信息
	}

	private void buildJson4Page(Page pageData) {
		if (pageData == null || pageData.getAllRs() == null
				|| pageData.getAllRs().isEmpty()) {
			throw new CommonException("没有数据.");
		}

		jsonObject.put(PAGE_ROWS, pageData.getAllRs());
		jsonObject.put(PAGE_TOTAL, pageData.getTotalCount());
	}

	private String build4Sort(String sql) {
		if (!Tools.processNull(sort).equals("")) {
			sql += " order by " + sort;

			if (!Tools.processNull(order).equals("")) {
				sql += " " + order;
			}
		}
		return sql;
	}

	public PayCarreform getPayCarreform() {
		return payCarreform;
	}

	public void setPayCarreform(PayCarreform payCarreform) {
		this.payCarreform = payCarreform;
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

	public PayCarTotal getPayCarTotal() {
		return payCarTotal;
	}

	public void setPayCarTotal(PayCarTotal payCarTotal) {
		this.payCarTotal = payCarTotal;
	}

	public PayCarreform getNewPayCarreform() {
		return newPayCarreform;
	}

	public void setNewPayCarreform(PayCarreform newPayCarreform) {
		this.newPayCarreform = newPayCarreform;
	}

	public String getReqData() {
		return reqData;
	}

	public void setReqData(String reqData) {
		this.reqData = reqData;
	}
}
