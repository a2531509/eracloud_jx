package com.erp.task;

import java.util.List;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Component;

import com.erp.exception.CommonException;
import com.erp.model.BaseBank;
import com.erp.model.BaseCoOrg;
import com.erp.service.ClrDealService;
import com.erp.service.CorpCheckAccountService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.NumberUtil;

@Component(value = "coOrgAutoCheckFileTask")
public class CoOrgAutoCheckFileTask {
	private static Logger logger = Logger.getLogger(CoOrgAutoCheckFileTask.class);
	@Resource(name = "clrDealService")
	private ClrDealService clrDealService;
	@Resource(name = "corpCheckAccountService")
	private CorpCheckAccountService corpCheckAccountService;

	/**
	 * 自动取Ftp文件对账
	 * 
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public void execute() {
		String starttime = System.currentTimeMillis() + "";
		String endtime="";
		try {
			logger.error("自动获取ftp对账文件开始...");
			// 老对账
			logger.error("老合作机构开始获取对账文件...");
			try {
				clrDealService.saveAutoFtpCheckFile("100101100100893");
			} catch (Exception e) {
				logger.error("100101100100893, " + e.getMessage());
			}
			try {
				clrDealService.saveAutoFtpCheckFile("330402012003001");
			} catch (Exception e) {
				logger.error("330402012003001, " + e.getMessage());
			}
			logger.error("老合作机构获取对账文件完成");
			// 新对账
			logger.error("新合作机构开始获取对账文件...");
			List<String> bankIds =  clrDealService.findBySql("select bank_id from Base_Bank t where bank_State = '" + Constants.STATE_ZC + "'");
			List<BaseCoOrg> orgs =  clrDealService.findByHql("from BaseCoOrg t where coState = '" + Constants.STATE_ZC + "' and coOrgId not in (" + Constants.CORG_CHECK_OLD_ID + ")");
			if (orgs == null || orgs.isEmpty()) {
				throw new CommonException("当前系统没有正常合作机构，无需对账");
			}
			int succ = 0;
			for (BaseCoOrg coOrg : orgs) {
				if (bankIds.contains(coOrg.getCoOrgId())) { // 银行, T+2
					try {
						corpCheckAccountService.saveAutoFtpCheckFile(coOrg.getCoOrgId(), "CZ", -2);
						succ++;
					} catch (Exception e) {
						logger.error(coOrg.getCoOrgId() + ", CZ, " + e.getMessage());
					}
					try {
						corpCheckAccountService.saveAutoFtpCheckFile(coOrg.getCoOrgId(), "QF", -2);
						succ++;
					} catch (Exception e) {
						logger.error(coOrg.getCoOrgId() + ", QF, " + e.getMessage());
					}
					try {
						corpCheckAccountService.saveAutoFtpCheckFile(coOrg.getCoOrgId(), "QT", -2);
						succ++;
					} catch (Exception e) {
						logger.error(coOrg.getCoOrgId() + ", QT, " + e.getMessage());
					}
				} else {
					try {
						corpCheckAccountService.saveAutoFtpCheckFile(coOrg.getCoOrgId(), "CZ", -1);
						succ++;
					} catch (Exception e) {
						logger.error(coOrg.getCoOrgId() + ", CZ, " + e.getMessage());
					}
				}
			}
			logger.fatal("共 " + orgs.size() + " 个合作机构，成功获取 " + succ + " 个对账文件");
			logger.error("新合作机构获取对账文件完成");
		} catch (Exception e) {
			logger.error("新合作机构获取对账文件失败，详细信息：" + e.getMessage());
		} finally {
			endtime = System.currentTimeMillis() + "";
			logger.fatal("自动取Ftp文件对账处理耗费了"+ NumberUtil.scale(Arith.div(Arith.sub(endtime, starttime),1000 * 60 + ""), 3) + "分钟.");
		}
	}
}
