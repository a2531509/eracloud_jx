package com.erp.action;

import java.util.List;
import java.util.Map;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.service.FtpManagementService;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

import net.sf.jasperreports.web.commands.CommandException;

/**
 * @author Yueh
 */
@SuppressWarnings("serial")
@Namespace("/ftp")
@Action(value = "ftpAction")
public class FtpManagementAction extends BaseAction {
	@Autowired
	private FtpManagementService ftpManagementService;
	
	private String ftpUse;
	private Map<String, String> ftpConf;
	private Boolean isAdd;
	
	@SuppressWarnings("unchecked")
	public String findFtpConfList() {
		try {
			initBaseDataGrid();
			String sql = "select distinct ftp_use \"ftp_use\" from sys_ftp_conf t where 1 = 1 ";
			if (!Tools.processNull(ftpUse).equals("")) {
				sql += "and ftp_use like '%" + ftpUse + "%' ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort;
				if(!Tools.processNull(order).equals("")){
					sql += " " + order;
				}
			} else {
				sql += "order by ftp_use";
			}
			Page pageData = baseService.pagingQuery(sql, page, rows);
			if (pageData == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommandException("根据条件找不到对应数据！");
			}
			//
			JSONArray ftpConfList = pageData.getAllRs();
			for (int i = 0; i < ftpConfList.size(); i++) {
				JSONObject ftpConf = ftpConfList.getJSONObject(i);
				List<Object[]> list = baseService.findBySql("select ftp_para_name, ftp_para_value from sys_ftp_conf t where ftp_use = '" + ftpConf.getString("ftp_use") + "'");
				if (list == null || list.isEmpty()) {
					continue;
				}
				for (Object[] keyValuePair : list) {
					ftpConf.put((String) keyValuePair[0], (String) keyValuePair[1]);
				}
			}
			jsonObject.put("rows", ftpConfList);
			jsonObject.put("total", pageData.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String saveFtpConf() {
		try {
			ftpManagementService.saveFtpConf(ftpConf, isAdd, baseService.getCurrentActionLog());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String deleteFtpConf() {
		try {
			ftpManagementService.deleteFtpConf(ftpUse, baseService.getCurrentActionLog());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String getFtpUse() {
		return ftpUse;
	}

	public void setFtpUse(String ftpUse) {
		this.ftpUse = ftpUse;
	}

	public Map<String, String> getFtpConf() {
		return ftpConf;
	}

	public void setFtpConf(Map<String, String> ftpConf) {
		this.ftpConf = ftpConf;
	}

	public Boolean getIsAdd() {
		return isAdd;
	}

	public void setIsAdd(Boolean isAdd) {
		this.isAdd = isAdd;
	}
}
