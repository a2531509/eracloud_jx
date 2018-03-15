package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.apache.struts2.ServletActionContext;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.CardRecharge;
import com.erp.model.StockList;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.service.AccAcountService;
import com.erp.service.RechargeCardSaleService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.SqlTools;

import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JRResultSetDataSource;
import net.sf.jasperreports.engine.JasperRunManager;

/**
 * 充值卡销售业务。
 * @author 钱佳明。
 *
 */
@SuppressWarnings("unchecked")
@Service("rechargeCardSaleService")
public class RechargeCardSaleServiceImpl extends BaseServiceImpl implements RechargeCardSaleService {

	@Resource(name = "accAcountService")
	private AccAcountService accAcountService;

	/**
	 * 保存充值卡销售记录。
	 * @param sysActionLog 业务日志信息。
	 * @param cardRecharge 充值卡信息。
	 */
	public TrServRec saveRechargeCard(SysActionLog sysActionLog, CardRecharge cardRecharge) throws CommonException {
		String note = "充值卡单张销售，卡号：" + cardRecharge.getCardNo();
		sysActionLog.setMessage(note);
		sysActionLog.setNote(note);
		sysActionLog.setDealCode(DealCode.RECHANGE_CARD_SELL);
		publicDao.save(sysActionLog);
		account(sysActionLog, null, new BigDecimal(Arith.cardmoneydiv(cardRecharge.getFaceVal().toString())), note, false);
		publicDao.doSql("update card_recharge set use_state = '" + Constants.CARD_RECHARGE_STATE_YJH + "',xs_deal_no = " + sysActionLog.getDealNo() + " where card_no = '" + cardRecharge.getCardNo() + "'");
		TrServRec trServRec = saveTrServRec(sysActionLog, cardRecharge, cardRecharge.getFaceVal().toString(), false);
		saveReport(sysActionLog, cardRecharge, false);
		publicDao.save(trServRec);
		return trServRec;
	}

	/**
	 * 批量保存充值卡销售记录。
	 * @param sysActionLog 业务日志信息。
	 * @param cardNos 充值卡卡号数据。
	 */
	public TrServRec saveBatchRechargeCard(SysActionLog sysActionLog, String cardNos) throws CommonException, JRException {
		String note = "充值卡批量销售";
		List<StockList> stockLists = findByHql("from StockList s where s.id.stkCode = '1" + Constants.CARD_TYPE_CZK + "'"
				+ " and s.goodsNo in (" + cardNos + ")"
				+ " and s.id.goodsState = '" + Constants.GOODS_STATE_ZC + "'"
				+ " and s.stkIsSure = '" + Constants.YES_NO_YES + "'"
				+ " and s.userId = '" + getSessionUser().getUserId() + "'");
		StringBuffer validCardNos = new StringBuffer();
		for (int index = 0; index < stockLists.size(); index++) {
			validCardNos.append("'" + stockLists.get(index).getGoodsNo() + "'");
			if (index != stockLists.size() - 1) {
				validCardNos.append(",");
			}
		}
		if ("".equals(validCardNos.toString())) {
			throw new CommonException("未传入符合条件的充值卡数据！");
		}
		List<CardRecharge> cardRecharges = findByHql("from CardRecharge c where c.cardNo in (" + validCardNos.toString() + ") and c.useState = '" + Constants.CARD_RECHARGE_STATE_WJH + "'");
		sysActionLog.setMessage(note);
		sysActionLog.setNote(note);
		sysActionLog.setDealCode(DealCode.RECHANGE_CARD_BATCHSELL);
		publicDao.save(sysActionLog);
		String totalFaceVal = "0";
		for (int index = 0; index < cardRecharges.size(); index++) {
			totalFaceVal = Arith.add(totalFaceVal, cardRecharges.get(index).getFaceVal().toString());
		}
		BigDecimal amount = new BigDecimal(Arith.cardmoneydiv(totalFaceVal));
		account(sysActionLog, null, amount, note, false);
		publicDao.doSql("update card_recharge set use_state = '" + Constants.CARD_RECHARGE_STATE_YJH + "',xs_deal_no = " + sysActionLog.getDealNo() + " where card_no in (" + cardNos + ") and use_state = '" + Constants.CARD_RECHARGE_STATE_WJH + "'");
		TrServRec trServRec = saveTrServRec(sysActionLog, null, totalFaceVal, false);
		publicDao.save(trServRec);
		saveBatchReport(cardRecharges, sysActionLog, Arith.cardreportsmoneydiv(totalFaceVal));
		return trServRec;
	}

	/**
	 * 充值卡销售记录撤销。
	 * @param sysActionLog 业务日志信息。
	 * @param trServRec 综合业务信息。
	 * @param cardRecharge 充值卡信息。
	 */
	public TrServRec modifyRechargeCard(SysActionLog sysActionLog, TrServRec trServRec, CardRecharge cardRecharge) throws CommonException {
		String note = "充值卡销售撤销，卡号：" + cardRecharge.getCardNo();
		sysActionLog.setMessage(note);
		sysActionLog.setNote(note);
		sysActionLog.setDealCode(DealCode.RECHANGE_CARD_UNDO);
		publicDao.save(sysActionLog);
		account(sysActionLog, trServRec, new BigDecimal(Arith.cardmoneydiv(cardRecharge.getFaceVal().toString())), note, true);
		publicDao.doSql("update card_recharge set use_state = '" + Constants.CARD_RECHARGE_STATE_WJH + "',xs_deal_no = null where card_no = '" + cardRecharge.getCardNo() + "'");
		trServRec = saveTrServRec(sysActionLog, cardRecharge, cardRecharge.getFaceVal() + "", true);
		saveReport(sysActionLog, cardRecharge, true);
		publicDao.save(trServRec);
		return trServRec;
	}

	/**
	 * 调用存储过程account。
	 * @param sysActionLog 业务日志信息。
	 * @param trServRec 综合业务信息。
	 * @param amount 交易金额。
	 * @param note 备注。
	 * @param isUndo 是否撤销。
	 */
	private void account(SysActionLog sysActionLog, TrServRec trServRec, BigDecimal amount, String note, boolean isUndo) {
		String brchId = "";
		if (trServRec == null) {
			brchId = getSysBranchByUserId().getBrchId();
		} else {
			brchId = trServRec.getBrchId();
		}
		AccAccountSub accountDb = (AccAccountSub) findOnlyRowByHql("from AccAccountSub a where a.customerId = '" + brchId + "' and a.itemId = '" + Constants.ACC_ITEM_101101 + "'");
		String orgId = "";
		if (trServRec == null) {
			orgId = getUser().getOrgId();
		} else {
			orgId = trServRec.getOrgId();
		}
		String orgCustomerId = (String) findOnlyFieldBySql("select customer_id from sys_organ where org_id = '" + orgId + "'");
		AccAccountSub accountCr = (AccAccountSub) findOnlyRowByHql("from AccAccountSub a where a.customerId = '" + orgCustomerId + "' and a.itemId = '" + Constants.ACC_ITEM_201104 + "'");
		if (!isUndo) {
			accAcountService.account(accountDb, accountCr, amount, sysActionLog, "0", "", "", Constants.TR_STATE_ZC, note);
		} else {
			accAcountService.account(accountCr, accountDb, amount, sysActionLog, "0", "", "", Constants.TR_STATE_ZC, note);
		}
	}

	/**
	 * 返回综合业务信息。
	 * @param sysActionLog 业务日志信息。
	 * @param cardRecharge 充值卡信息。
	 * @param amount 交易金额。
	 * @param isUndo 是否撤销。
	 * @return 综合业务信息。
	 */
	private TrServRec saveTrServRec(SysActionLog sysActionLog, CardRecharge cardRecharge, String amount, boolean isUndo) {
		TrServRec trServRec = new TrServRec();
		trServRec.setDealNo(sysActionLog.getDealNo());
		trServRec.setDealCode(sysActionLog.getDealCode());
		if(cardRecharge != null) {
			trServRec.setCardNo(cardRecharge.getCardNo());
			trServRec.setCardType(cardRecharge.getCardType());
			trServRec.setCardAmt(Long.parseLong(cardRecharge.getFaceVal() + ""));
		}
		trServRec.setBizTime(sysActionLog.getDealTime());
		trServRec.setUserId(sysActionLog.getUserId());
		trServRec.setBrchId(getUser().getBrchId());
		trServRec.setOrgId(getUser().getOrgId());
		trServRec.setClrDate(this.getClrDate());
		trServRec.setAmt(new Long((isUndo ? "-" : "") + amount));
		trServRec.setNote(sysActionLog.getMessage());
		trServRec.setDealState(Constants.TR_STATE_ZC);
		return trServRec;
	}

	/**
	 * 保存充值卡销售记录凭证
	 * @param sysActionLog 业务日志信息。
	 * @param cardRecharge 充值卡信息。
	 * @param isUndo 是否撤销。
	 */
	private void saveReport(SysActionLog sysActionLog, CardRecharge cardRecharge, boolean isUndo) {
		JSONObject jsonobject = new JSONObject();
		jsonobject.put("p_Print_Time1", DateUtil.formatDate(sysActionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss"));
		jsonobject.put("p_Actionno", sysActionLog.getDealNo());
		jsonobject.put("p_Cardno", cardRecharge.getCardNo());
		jsonobject.put("p_Rechg_Amt", (isUndo ? "-" : "") + Arith.cardreportsmoneydiv(cardRecharge.getFaceVal() + ""));
		jsonobject.put("p_Yw_Type",findTrCodeNameByCodeType(sysActionLog.getDealCode()));
		jsonobject.put("p_Oper_Id", getUser().getName());
		jsonobject.put("p_Acpt_Branch", getSysBranchByUserId().getFullName());
		jsonobject.put("p_Rechg_Time", DateUtil.formatDate(sysActionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss"));
		this.saveSysReport(sysActionLog, jsonobject, "/reportfiles/rechargecardsale.jasper", Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
	}

	/**
	 * 保存批量充值卡销售记录凭证。
	 * @param cardRecharges 充值卡信息集合。
	 * @param sysActionLog 业务日志信息。
	 * @param amount 交易金额。
	 * @throws JRException
	 */
	private void saveBatchReport(List<CardRecharge> cardRecharges, SysActionLog sysActionLog, String amount) throws JRException {
		StringBuffer rechargeCardNos = new StringBuffer();
		for (int index = 0; index < cardRecharges.size(); index++){
			rechargeCardNos.append("'" + cardRecharges.get(index).getCardNo() + "'");
			if (index != cardRecharges.size() - 1) {
				rechargeCardNos.append(",");
			}
		}
		StringBuffer sql = new StringBuffer();
		sql.append("select ROW_NUMBER() over(order by c.data_seq) seq, ");
		sql.append("(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = c.card_type) card_type, ");
		sql.append("c.card_no, " + SqlTools.divHundred("c.face_val") + " as face_val from card_recharge c where c.card_no in (" + rechargeCardNos.toString() + ")");
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("p_Title", Constants.APP_REPORT_TITLE + findTrCodeNameByCodeType(DealCode.RECHANGE_CARD_BATCHSELL) + "凭证");
		map.put("p_Actionno", sysActionLog.getDealNo() + "");
		map.put("p_Oper_Id", getUser().getName());
		map.put("p_Acpt_Branch", getSysBranchByUserId().getFullName());
		map.put("p_Rechg_Time", DateUtil.formatDate(sysActionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss"));
		map.put("p_Print_Time", DateUtil.formatDate(sysActionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss"));
		map.put("p_Total_Count", cardRecharges.size() + "");
		map.put("p_Total_Amt", amount);
		String path = ServletActionContext.getRequest().getRealPath("/reportfiles/rechargecardbatchsale.jasper");
		JRResultSetDataSource source = new JRResultSetDataSource(tofindResultSet(sql.toString()));
		byte[] pdfContent = JasperRunManager.runReportToPdf(path, map, source);
		saveSysReport(sysActionLog, new JSONObject(), "", Constants.APP_REPORT_TYPE_PDF2, 1L, "", pdfContent);
	}

}
