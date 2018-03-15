package com.erp.action;

import javax.annotation.Resource;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.TrServRec;
import com.erp.service.MerchantSettlementService;
import com.erp.util.Constants;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**
 * 商户结算报表。
 * @author 钱佳明。
 *
 */
@Namespace(value = "/merchantSettlement")
@Action(value = "merchantSettlementAction")
public class MerchantSettlementAction extends BaseAction {

	private static final long serialVersionUID = 1L;

	@Resource(name = "merchantSettlementService")
	private MerchantSettlementService merchantSettlementService;

	private String merchantIds;
	private String merchantId;
	private String merchantName;
	private String cardType;
	private String beginDate;
	private String endDate;

	private String queryType = "1";
	private String sort;
	private String order;
	private String defaultErrorMasg = "";

	/**
	 * 查询商户结算信息。
	 * @return
	 */
	public String queryMerchantSettlement() {
		try {
			initGrid();
			if (Tools.processNull(queryType).equals("0")) {
				validateDate();
				StringBuffer sql = new StringBuffer();
				String dateRange = " and to_date(sds.begin_date, 'yyyy-MM-dd') between to_date('" + beginDate + "', 'yyyy-MM-dd') and to_date('" + endDate + "', 'yyyy-MM-dd')";
				sql.append("select sdst.merchant_id, sdst.merchant_name, sdst.card_type, ");
				sql.append("(select sc.code_name from sys_code sc where sc.code_type = 'CARD_TYPE' and sc.code_value = sdst.card_type) card_name, ");
				sql.append("(select nvl(sum(sds.deal_num), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind = '" + Constants.ACC_KIND_ZJZH + "'" + dateRange + ") ol_deal_num, ");
				sql.append("(select nvl(sum(sds.deal_amt), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind = '" + Constants.ACC_KIND_ZJZH + "'" + dateRange + ") ol_deal_amt, ");
				sql.append("(select nvl(sum(sdl.fee_amt), 0) from stl_deal_list sdl where sdl.stl_sum_no in ");
				sql.append("(select sds.stl_sum_no from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind = '" + Constants.ACC_KIND_ZJZH + "'" + dateRange + ") and sdl.deal_code = '" + DealCode.ONLINE_CONSUME + "') ol_fee_amt, ");
				sql.append("(select nvl(sum(sds.deal_num), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind = '" + Constants.ACC_KIND_QBZH + "'" + dateRange + ") ofl_deal_num, ");
				sql.append("(select nvl(sum(sds.deal_amt), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind = '" + Constants.ACC_KIND_QBZH + "'" + dateRange + ") ofl_deal_amt, ");
				sql.append("(select nvl(sum(sdl.fee_amt), 0) from stl_deal_list sdl where sdl.stl_sum_no in ");
				sql.append("(select sds.stl_sum_no from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind = '" + Constants.ACC_KIND_QBZH + "'" + dateRange + ") and sdl.deal_code = '" + DealCode.OFFLINE_CONSUME + "') ofl_fee_amt, ");
				sql.append("(select nvl(sum(sds.th_num), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and acc_kind in ('" + Constants.ACC_KIND_QBZH + "','" + Constants.ACC_KIND_ZJZH + "')" + dateRange + ") th_num, ");
				sql.append("(select nvl(sum(sds.th_amt), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and acc_kind in ('" + Constants.ACC_KIND_QBZH + "','" + Constants.ACC_KIND_ZJZH + "')" + dateRange + ") th_amt, ");
				sql.append("(select nvl(sum(sdl.fee_amt), 0) from stl_deal_list sdl where sdl.stl_sum_no in ");
				sql.append("(select sds.stl_sum_no from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind in ('" + Constants.ACC_KIND_QBZH + "','" + Constants.ACC_KIND_ZJZH + "')" + dateRange + ") and sdl.deal_code in ('" + DealCode.OFFLINE_CONSUME_RETURN + "','" + DealCode.ONLINE_CONSUME_RETURN + "')) th_fee_amt, ");
				sql.append("(select nvl(sum(sds.stl_amt), 0) from stl_deal_sum sds where sds.merchant_id = sdst.merchant_id and sds.card_type = sdst.card_type and sds.acc_kind in ('" + Constants.ACC_KIND_QBZH + "','" + Constants.ACC_KIND_ZJZH + "')" + dateRange + ") stl_amt ");
				sql.append("from (select sds.merchant_id, t.merchant_name, sds.card_type from stl_deal_sum sds,base_merchant t where 1 = 1 and sds.merchant_id = t.merchant_id(+) " + dateRange);
				sql.append(" group by sds.merchant_id, t.merchant_name, sds.card_type) sdst where 1 = 1 ");
				if(!Tools.processNull(merchantId).equals("")) {
					sql.append(" and sdst.merchant_id = '" + merchantId + "'");
				}
				if(!Tools.processNull(merchantName).equals("")) {
					sql.append(" and sdst.merchant_name like '%" + merchantName + "%'");
				}
				if(!Tools.processNull(cardType).equals("")) {
					sql.append(" and sdst.card_type = '" + cardType + "'");
				}
				if (!Tools.processNull(sort).equals("")) {
					sql.append(" order by " + sort + " " + order);
				} else {
					sql.append(" order by sdst.merchant_id");
				}
				Page list = baseService.pagingQuery(sql.toString(), page, rows);
				if (list.getAllRs() != null && list.getAllRs().size() > 0) {
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				} else {
					throw new CommonException("根据查询条件未找到对应的商户结算信息！");
				}
			}
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 生成报表。
	 * @return
	 */
	public String createReport() {
		jsonObject.put("status", "1");
		jsonObject.put("errMsg", "");
		try {
			if (Tools.processNull(merchantIds).equals("")) {
				throw new CommonException("未传入商户编号数据！");
			}
			validateDate();
			TrServRec trServRec = merchantSettlementService.createReport(merchantIds, beginDate, endDate, cardType, baseService.getCurrentActionLog());
			jsonObject.put("status", "0");
			jsonObject.put("title", beginDate + "——" + endDate + "商户结算报表");
			jsonObject.put("dealNo", trServRec.getDealNo());
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 导出Excel格式。
	 * @return
	 */
	public String exportExcel() {
		try {
			if (Tools.processNull(merchantIds).equals("")) {
				throw new CommonException("未传入商户编号数据！");
			}
			validateDate();
			merchantSettlementService.exportExcel(merchantIds, beginDate, endDate, cardType);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	private void validateDate() throws Exception {
		if (Tools.processNull(beginDate).equals("")) {
			throw new CommonException("未传入起始日期！");
		}
		if (Tools.processNull(endDate).equals("")) {
			throw new CommonException("未传入结束日期！");
		}
		if (DateUtils.parse(beginDate, DateUtils.DATE_SMALL_STR).after(DateUtils.parse(endDate, DateUtils.DATE_SMALL_STR))) {
			throw new CommonException("起始日期不能大于结束日期！");
		}
	}

	private void initGrid() throws Exception {
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		jsonObject.put("status", 0);
		jsonObject.put("errMsg", "");
	}

	public String getMerchantIds() {
		return merchantIds;
	}

	public void setMerchantIds(String merchantIds) {
		this.merchantIds = merchantIds;
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

	public String getBeginDate() {
		return beginDate;
	}

	public void setBeginDate(String beginDate) {
		this.beginDate = beginDate;
	}

	public String getEndDate() {
		return endDate;
	}

	public void setEndDate(String endDate) {
		this.endDate = endDate;
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

	public String getDefaultErrorMasg() {
		return defaultErrorMasg;
	}

	public void setDefaultErrorMasg(String defaultErrorMasg) {
		this.defaultErrorMasg = defaultErrorMasg;
	}
	
}
