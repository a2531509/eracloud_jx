package com.erp.action;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;

import com.alibaba.fastjson.JSONArray;
import com.erp.model.SysLoginLog;
import com.erp.service.LogManagerService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

@Namespace("/logs")
@Action("logManagerAction")
public class LogManagerAction extends BaseAction {
	private static final long serialVersionUID = 1L;

	private LogManagerService logManagerService;
	private SysLoginLog log;
	private String loginId;
	private String startDate;
	private String endDate;
	private String queryType;
	private String sort;
	private String order;

	public String getLoginLogs() {
		try {
			pageInit();
			
			if(!Tools.processNull(queryType).equals("0")){
				return JSONOBJ;
			}
			
			StringBuilder sql = new StringBuilder();

			sql.append("select LOGIN_NO,OPER_TERM_ID,TERM_ID,IP,LOGON_TIME,LOGOFF_TIME,"
					+ "(select code_name from sys_code where code_type='USER_TYPE' and code_value=user_type) USER_TYPE,"
					+ "(select code_name from sys_code where code_type='Log_Type' and code_value=log_type) LOG_TYPE "
					+ ",LOGIN_ERRO from SYS_LOGIN_LOG where 1=1 ");

			// 登录类型
			if (!Tools.processNull(log.getLogType()).equals("")) {
				sql.append("and log_type='" + log.getLogType() + "' ");
			}

			// 用户类型
			if (!Tools.processNull(log.getUserType()).equals("")) {
				sql.append("and user_type='" + log.getUserType() + "' ");

				if (!Tools.processNull(loginId).equals("")) {
					if (log.getUserType().equals(Constants.USER_TYPE_OPERATOR)) {// 用户
						sql.append("and oper_term_id like '%" + loginId + "%' ");
					} else if (log.getUserType().equals(
							Constants.USER_TYPE_TERM)) {// 终端
						sql.append("and term_id like '%" + loginId + "%' ");
					}
				}
			}

			if (!Tools.processNull(startDate).equals("")) {//起始时间
				sql.append("and (logon_time>=to_date('" + startDate + " 00:00:00','yyyy-mm-dd hh24:mi:ss') "
						+ "or logoff_time>=to_date('" + startDate + " 00:00:00','yyyy-mm-dd hh24:mi:ss')) ");
			}
			
			if (!Tools.processNull(endDate).equals("")) {//结束时间
				sql.append("and (logon_time<=to_date('" + endDate + " 23:59:59','yyyy-mm-dd hh24:mi:ss') "
						+ "or logoff_time<=to_date('" + endDate + " 23:59:59','yyyy-mm-dd hh24:mi:ss')) ");
			}
			
			if (!Tools.processNull(sort).equals("")) {
				sql.append("order by " + sort);
				
				if(!Tools.processNull(order).equals("")){
					sql.append(" " + order);
				}
			}else {
				sql.append("order by LOGON_TIME desc");
			}

			Page logs = logManagerService.pagingQuery(sql.toString(), page, rows);
			
			if (logs.getAllRs() == null) {
				throw new Exception("找不到记录");
			}
			
			jsonObject.put("rows", logs.getAllRs());
			jsonObject.put("total", logs.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return JSONOBJ;
	}

	private void pageInit() {
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status",0);
		jsonObject.put("errMsg","");
	}

	public LogManagerService getLogManagerService() {
		return logManagerService;
	}

	public void setLogManagerService(LogManagerService logManagerService) {
		this.logManagerService = logManagerService;
	}

	public SysLoginLog getLog() {
		return log;
	}

	public void setLog(SysLoginLog log) {
		this.log = log;
	}

	public String getLoginId() {
		return loginId;
	}

	public void setLoginId(String loginId) {
		this.loginId = loginId;
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
}
