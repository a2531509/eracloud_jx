package com.erp.service;

import java.util.List;
import java.util.Map;

import net.sf.jasperreports.web.commands.CommandException;

import com.erp.model.SysErrLog;
import com.erp.util.PageUtil;

public interface SysErrLogService {
	
	void saveSysErrLog(SysErrLog errLog) throws CommandException;
	
	List<SysErrLog> findSysErrLogsAllList(Map<String, Object> map,PageUtil pageUtil)throws CommandException;

	Long getCount(Map<String, Object> map, PageUtil pageUtil )throws CommandException;

}
