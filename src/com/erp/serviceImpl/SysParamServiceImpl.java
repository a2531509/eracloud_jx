package com.erp.serviceImpl;

import java.util.List;


import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.dao.PublicDao;
import com.erp.exception.CommonException;
import com.erp.model.AccItem;
import com.erp.model.CardConfig;
import com.erp.model.SysActionLog;
import com.erp.service.BaseService;
import com.erp.service.SysParamService;
import com.erp.util.Constants;
import com.erp.util.PageUtil;

@Service("sysParamService")
public class SysParamServiceImpl extends BaseServiceImpl implements SysParamService {

	@Override
	public void saveItem(SysActionLog log, String item_id, String item_name)
			throws CommonException {
		try {
			publicDao.save(log);
			publicDao.doSql("update acc_item t set t.item_name = '"+item_name+"' "
							+ "where t.item_id='"+item_id+"'");
		} catch (Exception e) {
			throw new CommonException("保存科目信息出错："+e.getMessage());
		}
		
	}

	@Override
	public void saveCardConfig(SysActionLog log, CardConfig config,String editOrAdd)
			throws CommonException {
		try {
			publicDao.merge(config);
		} catch (Exception e) {
			throw new CommonException("卡参数修改出错："+e.getMessage());
		}
	}

	@Override
	public void saveErrPwdPara(SysActionLog log, String servPwderr,
			String loginPwdErr, String tradePwdErr) throws CommonException {
		try {
			publicDao.save(log);
			publicDao.doSql("update sys_para set para_value ='"+servPwderr+"'  where para_code = 'SERV_PWD_ERR_NUM'");
			publicDao.doSql("update sys_para set para_value ='"+loginPwdErr+"' where para_code = 'SYS_LOGIN_PWD_ERR_NUM'");
			publicDao.doSql("update sys_para set para_value ='"+tradePwdErr+"'  where para_code = 'TRADE_PWD_ERR_NUM'");
		} catch (Exception e) {
			throw new CommonException("密码错误参数保存发生错误："+e.getMessage());
		}
	}

}
