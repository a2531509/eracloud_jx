package com.erp.service;

import java.util.Map;

import com.erp.model.SysActionLog;

public interface FtpManagementService extends BaseService {
	void saveFtpConf(Map<String, String> ftpConf, Boolean isAdd, SysActionLog currentActionLog);

	void deleteFtpConf(String ftpUse, SysActionLog currentActionLog);
}
