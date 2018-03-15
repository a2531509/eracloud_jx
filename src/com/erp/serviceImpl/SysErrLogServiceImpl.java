package com.erp.serviceImpl;

import java.util.List;
import java.util.Map;

import net.sf.jasperreports.web.commands.CommandException;

import com.erp.util.DateUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.dao.PublicDao;
import com.erp.model.SysActionLog;
import com.erp.model.SysErrLog;
import com.erp.service.SysErrLogService;
import com.erp.util.Constants;
import com.erp.util.PageUtil;

@Service("sysErrLogService")
public class SysErrLogServiceImpl implements SysErrLogService {
	
	PublicDao<SysErrLog> publicDao;
	
	@Autowired
	public void setPublicDao(PublicDao<SysErrLog> publicDao) {
		this.publicDao = publicDao;
	}

	@Override
	public void saveSysErrLog(SysErrLog errLog) throws CommandException {
		try {
			Integer userId = Constants.getCurrendUser().getUserId();
			publicDao.save(errLog);
		} catch (Exception e) {
			throw new CommandException("保存业务日志出错");
		}
	}

	@Override
	public List<SysErrLog> findSysErrLogsAllList(Map<String, Object> map,
			PageUtil pageUtil) throws CommandException {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Long getCount(Map<String, Object> map, PageUtil pageUtil)
			throws CommandException {
		// TODO Auto-generated method stub
		return null;
	}

}
