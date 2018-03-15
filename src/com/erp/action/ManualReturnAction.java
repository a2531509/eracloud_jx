package com.erp.action;

import java.sql.ResultSet;

import javax.annotation.Resource;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.AccAdjustbytradHandle;
import com.erp.model.CardBaseinfo;
import com.erp.service.ManualReturnService;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**
 * 手工退货。
 * 
 * @author 钱佳明。
 * @date 2016-03-14。
 *
 */
@Namespace(value = "/manualReturn")
@Action(value = "manualReturnAction")
public class ManualReturnAction extends BaseAction {

	private static final long serialVersionUID = 1L;

	@Resource(name = "manualReturnService")
	private ManualReturnService manualReturnService;

	private String id;
	private String merchantId;
	private String merchantName;
	private String cardType;
	private String cardNo;
	private String returnBeginDate;
	private String returnEndDate;
	private String oldDealNo;
	private String oldDealClearingDate;
	private String returnAmount;

	private String queryType = "1";
	private String sort;
	private String order;
	private String defaultErrorMsg = "";
	private String state = "";

	public String query() {
		try {
			initGrid();
			if (Tools.processNull(queryType).equals("0")) {
				StringBuffer sql = new StringBuffer("");
				sql.append("select t.id, t.trad_acpt_id, b.merchant_name, t.trad_end_id, t.trad_batch_no, trad_state, ");
				sql.append("(select s.code_name from sys_code s where s.code_value = t.card_type and s.code_type = 'CARD_TYPE') card_type, ");
				sql.append("t.trad_end_deal_no, t.card_no, t.trad_amt, t.old_deal_no ");
				sql.append("from acc_adjustbytrad_handle t, base_merchant b ");
				sql.append("where t.trad_acpt_id = b.merchant_id ");
				if (!Tools.processNull(state).equals("")) {
					sql.append(" and t.trad_state = '" + state + "'");
				}
				if (!Tools.processNull(merchantId).equals("")) {
					sql.append(" and t.trad_acpt_id = '" + merchantId + "'");
				}
				if (!Tools.processNull(merchantName).equals("")) {
					sql.append(" and b.merchant_name like '%" + merchantName + "%'");
				}
				if (!Tools.processNull(cardType).equals("")) {
					sql.append(" and t.card_type = '" + cardType + "'");
				}
				if (!Tools.processNull(cardNo).equals("")) {
					sql.append(" and t.card_no = '" + cardNo + "'");
				}
				if (!Tools.processNull(returnBeginDate).equals("")) {
					sql.append(" and t.trad_time >= to_date('" + returnBeginDate + " 00:00:00', 'yyyy-mm-dd hh24:mi:ss')");
				}
				if (!Tools.processNull(returnEndDate).equals("")) {
					sql.append(" and t.trad_time <= to_date('" + returnEndDate + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss')");
				}
				if (!Tools.processNull(sort).equals("")) {
					sql.append(" order by " + sort + " " + order);
				} else {
					sql.append(" order by t.id");
				}
				Page list = baseService.pagingQuery(sql.toString(), page, rows);
				if (list.getAllRs() != null && list.getAllRs().size() > 0) {
					jsonObject.put("rows", list.getAllRs());
					jsonObject.put("total", list.getTotalCount());
				} else {
					throw new CommonException("根据查询条件未找到对应的手工退货信息！");
				}
			}
		} catch(Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	public String saveManualReturn() {
		jsonObject.put("status", 0);
		jsonObject.put("errMsg", "");
		try {
			if (Tools.processNull(cardType).equals("")) {
				throw new CommonException("未传入卡类型数据！");
			}
			if (Tools.processNull(cardNo).equals("")) {
				throw new CommonException("未传入卡号数据！");
			}
			if (Tools.processNull(oldDealNo).equals("")) {
				throw new CommonException("未传入原交易流水号数据！");
			}
			if (Tools.processNull(oldDealClearingDate).equals("")) {
				throw new CommonException("未传入原交易的清分日期数据！");
			}
			if (Tools.processNull(returnAmount).equals("")) {
				throw new CommonException("未传入退货金额数据！");
			}
			CardBaseinfo cardBaseinfo = (CardBaseinfo) baseService.findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + cardNo + "'");
			if (cardBaseinfo == null) {
				throw new CommonException("卡号信息不存在！");
			}
			if (!cardBaseinfo.getCardType().equals(cardType)) {
				throw new CommonException("卡类型与当前卡号类型不一致！");
			}
//			AccAdjustbytradHandle accAdjustbytradHandle = (AccAdjustbytradHandle) baseService.findOnlyRowByHql("from AccAdjustbytradHandle a where a.oldDealNo = '" + oldDealNo + "'");
//			if (accAdjustbytradHandle != null) {
//				throw new CommonException("当前原交易流水号数据已登记！");
//			}
			String clearingDate = oldDealClearingDate.substring(0, oldDealClearingDate.lastIndexOf("-")).replace("-", "");
			ResultSet resultSet = baseService.tofindResultSet("select * from acc_inout_detail_" + clearingDate + " t" + 
					" where t.deal_no = '" + oldDealNo + "' and t.acpt_type = '0'" +
					" and t.db_card_type = '" + cardType + "' and t.db_card_no = '" + cardNo + "'" +
					" and t.clr_date = '" + oldDealClearingDate + "'");
			if (resultSet.next()) {
				manualReturnService.saveManualReturn(cardBaseinfo, returnAmount, clearingDate, resultSet);
			} else {
				throw new CommonException("账户进出流水账信息不存在！");
			}
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	public String saveManaulReturnExecute() {
		jsonObject.put("status", 0);
		jsonObject.put("errMsg", "");
		try {
			if (Tools.processNull(id).equals("")) {
				throw new CommonException("未传入编号数据！");
			}
			AccAdjustbytradHandle accAdjustbytradHandle = (AccAdjustbytradHandle) baseService.findOnlyRowByHql("from AccAdjustbytradHandle a where a.id = " + id);
			if (accAdjustbytradHandle == null) {
				throw new CommonException("根据编号未找到手工退货数据信息！");
			}
			if (!accAdjustbytradHandle.getTradState().equals("0")) {
				throw new CommonException("当前记录不是【待处理】状态！");
			}
			manualReturnService.saveManaulReturnExecute(accAdjustbytradHandle);
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String deleteManaulReturnInfo(){
		try {
			if (Tools.processNull(id).equals("")) {
				throw new CommonException("未传入编号数据！");
			}
			AccAdjustbytradHandle accAdjustbytradHandle = (AccAdjustbytradHandle) baseService.findOnlyRowByHql("from AccAdjustbytradHandle a where a.id = " + id);
			if (accAdjustbytradHandle == null) {
				throw new CommonException("根据编号未找到手工退货数据信息！");
			}
			if (!accAdjustbytradHandle.getTradState().equals("0")) {
				throw new CommonException("当前记录不是【待处理】状态！");
			}
			manualReturnService.deleteManaulReturnInfo(accAdjustbytradHandle);
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	private void initGrid() throws Exception {
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		jsonObject.put("status", 0);
		jsonObject.put("errMsg", "");
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getReturnBeginDate() {
		return returnBeginDate;
	}

	public void setReturnBeginDate(String returnBeginDate) {
		this.returnBeginDate = returnBeginDate;
	}

	public String getReturnEndDate() {
		return returnEndDate;
	}

	public void setReturnEndDate(String returnEndDate) {
		this.returnEndDate = returnEndDate;
	}

	public String getOldDealNo() {
		return oldDealNo;
	}

	public void setOldDealNo(String oldDealNo) {
		this.oldDealNo = oldDealNo;
	}

	public String getOldDealClearingDate() {
		return oldDealClearingDate;
	}

	public void setOldDealClearingDate(String oldDealClearingDate) {
		this.oldDealClearingDate = oldDealClearingDate;
	}

	public String getReturnAmount() {
		return returnAmount;
	}

	public void setReturnAmount(String returnAmount) {
		this.returnAmount = returnAmount;
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

	public String getDefaultErrorMsg() {
		return defaultErrorMsg;
	}

	public void setDefaultErrorMsg(String defaultErrorMsg) {
		this.defaultErrorMsg = defaultErrorMsg;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}
}
