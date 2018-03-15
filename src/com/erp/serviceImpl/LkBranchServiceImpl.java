package com.erp.serviceImpl;

import java.math.BigDecimal;

import org.apache.commons.beanutils.BeanUtils;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseCorp;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.TrServRec;
import com.erp.service.LkBranchService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.ReceiptContants;
import com.erp.util.Tools;

/**
 * 单位/社区（村）领卡网点设置业务实现类。
 * 
 * @author 钱佳明。
 * @date 2015-12-10。
 *
 */
@Service("lkBranchService")
public class LkBranchServiceImpl extends BaseServiceImpl implements LkBranchService {

	@SuppressWarnings("unchecked")
	@Override
	public TrServRec saveLkBranch(String isCorpOrComm, String corpOrCommId, String lkBranchId, String lkBranchId2, String isBatchHf, boolean isBatchSetting) throws CommonException {
		try {
			if (Tools.processNull(isCorpOrComm).equals("")) {
				throw new CommonException("操作类型为空！");
			}
			if (!isCorpOrComm.equals("0") && !isCorpOrComm.equals("1")) {
				throw new CommonException("操作类型错误！");
			}
			if (Tools.processNull(corpOrCommId).equals("")) {
				throw new CommonException("领卡网点信息为空！");
			}
			if (isBatchSetting && Tools.processNull(lkBranchId).equals("")) {
				throw new CommonException("领卡网点信息为空！");
			}
			SysBranch lkBrch = (SysBranch) findOnlyRowByHql("from SysBranch s where s.brchId = '" + lkBranchId + "'");
			if (isBatchSetting && lkBrch == null) {
				throw new CommonException("领卡网点信息不存在！");
			}
			if (lkBrch != null && !Tools.processNull(lkBrch.getIsLkBrch()).equals("0") && !Tools.processNull(lkBrch.getIsLkBrch2()).equals("0")){
				throw new CommonException("该网点不是领卡网点！");
			}
			//
			SysActionLog log = (SysActionLog) BeanUtils.cloneBean(getCurrentActionLog());
			log.setDealCode(DealCode.LK_BRCH_SET);
			log.setMessage("领卡网点设置， 单位/社区编号：" + corpOrCommId + "，金融市民卡领卡网点编号：" + lkBranchId + ", 全功能卡领卡网点：" + lkBranchId2);
			publicDao.save(log);
			//
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			String sql = "";
			if (isCorpOrComm.equals("0")) {
				BaseCorp corp = (BaseCorp) findOnlyRowByHql("from BaseCorp where customerId = '" + corpOrCommId + "'");
				if (corp == null) {
					throw new CommonException("单位不存在！");
				} else if (!corp.getRegionId().equals(getBrchRegion())) {
					throw new CommonException("单位不属于本区域！");
				} else if(isBatchSetting && !Tools.processNull(corp.getLkBrchId()).equals("")){
					BigDecimal count = (BigDecimal) findOnlyRowBySql("select count(1) from branch_bank t where t.brch_id = '" + lkBranchId + "' and exists (select 1 from branch_bank where brch_id = '" + corp.getLkBrchId() + "' and bank_id = t.bank_id)");
					if(count.intValue() == 0){
						throw new CommonException("单位已经设置了其它银行的领卡网点！");
					}
				}
				rec.setRsvOne(Tools.processNull(corp.getLkBrchId()));
				rec.setRsvTwo(Tools.processNull(corp.getLkBrchId2()));
				rec.setRsvThree(Tools.processNull(corp.getIsBatchHf()));
				rec.setCustomerId(Tools.processNull(corp.getCustomerId()));
				//
				corp.setLkBrchId(Tools.processNull(lkBranchId));
				if (!Tools.processNull(lkBranchId2).equals("")) {
					corp.setLkBrchId2(lkBranchId2);
				}
				corp.setIsBatchHf(isBatchHf);
				corp.setDealNo(log.getDealNo().toString());
			} else if (isCorpOrComm.equals("1")) {
				sql = "update base_comm set lk_brch_id = '" + lkBranchId + "', lk_brch_id2 = '" + lkBranchId2 + "' where comm_id = '" + corpOrCommId + "'";
				publicDao.doSql(sql);
			}
			//
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(getClrDate());
			publicDao.save(rec);
			//
			if(isCorpOrComm.equals("0")) {
				String bankName = (String) findOnlyFieldBySql("select bank_name from base_bank t where exists "
						+ "(select 1 from branch_bank where brch_id = '" + lkBranchId + "' and bank_id = t.bank_id)");
				BaseCorp corp = (BaseCorp) findOnlyRowByHql("from BaseCorp where customerId = '" + corpOrCommId + "'");
				JSONObject json = new JSONObject();
				json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
				json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
				json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
				json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
				json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
				json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
				json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
				json.put("p_corp_id", corp.getCustomerId());
				json.put("p_corp_name", corp.getCorpName());
				json.put("p_con_name", corp.getContact());
				json.put("p_con_cert_type", getCodeNameBySYS_CODE("CERT_TYPE", "1"));
				json.put("p_con_cert_no", corp.getConCertNo());
				json.put("p_bank_name", Tools.processNull(bankName));
				json.put("p_lk_brch", lkBrch == null ? "":lkBrch.getFullName());
				this.saveSysReport(log, json, "/reportfiles/lkBrchSet.jasper", Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			}
			
			return rec;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}

}
