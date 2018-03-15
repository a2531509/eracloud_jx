package com.erp.serviceImpl;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.SysFtpConf;
import com.erp.model.SysFtpConfId;
import com.erp.model.TrServRec;
import com.erp.service.FtpManagementService;
import com.erp.util.Constants;
import com.erp.util.DealCode;
import com.erp.util.Tools;

@Service("ftpManagementService")
public class FtpManagementServiceImpl extends BaseServiceImpl implements FtpManagementService {

	@SuppressWarnings("unchecked")
	@Override
	public void saveFtpConf(Map<String, String> ftpConf, Boolean isAdd, SysActionLog log) {
		try {
			if(ftpConf == null || ftpConf.isEmpty()){
				throw new CommonException("FTP 配置为空！");
			} else if (!ftpConf.containsKey("ftp_use")){
				throw new CommonException("FTP 配置缺失 关键配置项 【ftp_use】！");
			}
			log.setDealCode(DealCode.FTP_CONF_MANAGE);
			log.setMessage("保存 FTP 配置, " + ftpConf.toString());
			publicDao.save(log);
			//
			String ftpUse = ftpConf.remove("ftp_use");
			if(ftpConf.isEmpty()){
				throw new CommonException("除【ftp_use】外至少需要一个 配置项 ！");
			}
			//
			List<SysFtpConf> list = findByHql("from SysFtpConf where id.ftpUse = '" + ftpUse + "'");
			if (isAdd) { // add
				if (list != null && !list.isEmpty()) {
					throw new CommonException("已经存在FTP配置【" + ftpUse + "】 ！");
				}
				for (String fk : ftpConf.keySet()) {
					SysFtpConf sfc = new SysFtpConf(new SysFtpConfId(ftpUse, fk), ftpConf.get(fk));
					publicDao.save(sfc);
				}
			} else { // modify
				// 存在 更新，系统里多余的 删除
				for (SysFtpConf sfc : list) {
					String fk = sfc.getId().getFtpParaName();
					if(ftpConf.containsKey(fk)){
						sfc.setFtpParaValue(ftpConf.remove(fk));
					} else {
						publicDao.delete(sfc);
					}
				}
				// 不存在（剩下的） 新增
				for (String fk : ftpConf.keySet()) {
					SysFtpConf sfc = new SysFtpConf(new SysFtpConfId(ftpUse, fk), ftpConf.get(fk));
					publicDao.save(sfc);
				}
			}
			
			//
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setClrDate(getClrDate());
			rec.setDealState(Constants.STATE_ZC);
			rec.setNote(log.getMessage());
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException("保存 FTP 配置失败, " + e.getMessage());
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void deleteFtpConf(String ftpUse, SysActionLog log) {
		try {
			if(Tools.processNull(ftpUse).equals("")){
				throw new CommonException("FTP 配置为空！");
			}
			log.setDealCode(DealCode.FTP_CONF_MANAGE);
			log.setMessage("删除 FTP 配置, " + ftpUse);
			publicDao.save(log);
			//
			publicDao.doSql("delete from sys_ftp_conf where ftp_use = '" + ftpUse + "'");
			//
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setClrDate(getClrDate());
			rec.setDealState(Constants.STATE_ZC);
			rec.setNote(log.getMessage());
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException("删除 FTP 配置失败, " + e.getMessage());
		}
	}

}
