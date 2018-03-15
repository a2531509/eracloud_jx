package com.erp.action;

import javax.annotation.Resource;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.CardRecharge;
import com.erp.model.StockAcc;
import com.erp.model.StockList;
import com.erp.model.TrServRec;
import com.erp.service.RechargeCardSaleService;
import com.erp.util.Constants;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**
 * 充值卡销售。
 * 
 * @author 钱佳明。
 *
 */
@Namespace(value = "/rechargeCard")
@Action(value = "rechargeCardSaleAction")
public class RechargeCardSaleAction extends BaseAction {

	private static final long serialVersionUID = 1L;

	@Resource(name = "rechargeCardSaleService")
	private RechargeCardSaleService rechargeCardSaleService;

	private String taskId;
	private String cardType;
	private String cardNo;
	private String dealNo;
	private String bizTime;
	private String cardNos;

	private String queryType = "1";
	private String sort;
	private String order;
	private String defaultErrorMasg = "";

	/**
	 * 判断充值卡。
	 * @param cardNo 充值卡号。
	 * @param isUndo 是否撤销。
	 * @throws CommonException
	 */
	private CardRecharge judgementRechargeCard(String cardNo, boolean isUndo) throws CommonException {
		// 判断是否传入充值卡号
		if (Tools.processNull(cardNo).equals("")) {
			throw new CommonException("未传入卡号数据！");
		}
		CardRecharge cardRecharge = (CardRecharge) baseService.findOnlyRowByHql("from CardRecharge c where c.cardNo = '" + cardNo + "'");
		// 判断是否存在当前充值卡
		if (cardRecharge == null) {
			throw new CommonException("充值卡【" + cardNo + "】不存在！");
		}
		// 判断当前充值卡状态
		if (cardRecharge.getUseState().equals(Constants.CARD_RECHARGE_STATE_WSY)) {
			throw new CommonException("充值卡【" + cardNo + "】为【未使用】状态！");
		}
		if (cardRecharge.getUseState().equals(Constants.CARD_RECHARGE_STATE_WJH) && isUndo) {
			throw new CommonException("充值卡【" + cardNo + "】为【未激活】状态！");
		}
		if (cardRecharge.getUseState().equals(Constants.CARD_RECHARGE_STATE_YJH) && !isUndo) {
			throw new CommonException("充值卡【" + cardNo + "】为【已激活】状态！");
		}
		if (cardRecharge.getUseState().equals(Constants.CARD_RECHARGE_STATE_YSY)) {
			throw new CommonException("充值卡【" + cardNo + "】为【已使用】状态！");
		}
		if (cardRecharge.getUseState().equals(Constants.CARD_RECHARGE_STATE_YZX)) {
			throw new CommonException("充值卡【" + cardNo + "】为【已注销】状态！");
		}
		return cardRecharge;
	}

	/**
	 * 判断当前柜员是否存在充值卡库存账户。
	 * 当物品编号不为空时，判断当前物品编号是否属于当前柜员充值卡库存账户。
	 * @param goodsNo 物品编号。
	 * @throws CommonException
	 */
	private void judgementStockAcc(String goodsNo) throws CommonException {
		// 判断当前柜员是否存在充值卡账户
		StockAcc stockAcc = (StockAcc) baseService.findOnlyRowByHql("from StockAcc s where s.id.userId = '" + getUsers().getUserId() + "' and s.id.stkCode = '1" + Constants.CARD_TYPE_CZK + "' and s.id.goodsState = '" + Constants.GOODS_STATE_ZC + "'");
		if (stockAcc == null) {
			throw new CommonException("柜员【" + getUsers().getName() + "】不存在充值卡库存账户！");
		}
		// 判断当前柜员充值卡账户状态
		if (!stockAcc.getAccState().equals(Constants.STATE_ZC)) {
			throw new CommonException("柜员【" + getUsers().getName() + "】充值卡库存账户为【注销】状态！");
		}
		// 判断是否传入物品编号
		if (goodsNo != null) {
			StockList stockList = (StockList) baseService.findOnlyRowByHql("from StockList s where s.id.stkCode = '1" + Constants.CARD_TYPE_CZK + "' and s.goodsNo = '" + goodsNo + "' and userId = '" + getUsers().getUserId() + "'");
			// 判断当前柜员充值卡账户是否存在当前物品编号
			if (stockList == null) {
				throw new CommonException("柜员【" + getUsers().getName() + "】充值卡库存账户中不存在编号为【" + goodsNo + "】物品！");
			}
			// 判断当前柜员充值卡账户对当前物品编号是否进行确认库存
			if (!stockList.getStkIsSure().equals(Constants.YES_NO_YES)) {
				throw new CommonException("柜员【" + getUsers().getName() + "】充值卡库存账户中物品编号【" + goodsNo + "】未进行库存确认！");
			}
			// 判断当前柜员充值卡账户中当前物品的状态
			if (stockList.getId().getGoodsState().equals(Constants.GOODS_STATE_HSDCL)) {
				throw new CommonException("柜员【" + getUsers().getName() + "】充值卡库存账户中物品编号【" + goodsNo + "】为【回收待处理】状态！");
			}
			if (stockList.getId().getGoodsState().equals(Constants.GOODS_STATE_ZLTKDCL)) {
				throw new CommonException("柜员【" + getUsers().getName() + "】充值卡库存账户中物品编号【" + goodsNo + "】为【质量问题待处理】状态！");
			}
			if (stockList.getId().getGoodsState().equals(Constants.GOODS_STATE_WFFFDCL)) {
				throw new CommonException("柜员【" + getUsers().getName() + "】充值卡库存账户中物品编号【" + goodsNo + "】为【注销待处理】状态！");
			}
			if (stockList.getId().getGoodsState().equals(Constants.GOODS_STATE_BF)) {
				throw new CommonException("柜员【" + getUsers().getName() + "】充值卡库存账户中物品编号【" + goodsNo + "】为【报废】状态！");
			}
		}
	}

	/**
	 * 判断业务日志。
	 * @param dealNo 业务流水号。
	 * @return
	 */
	private TrServRec judgementTrServRec(String dealNo, CardRecharge cardRecharge) throws CommonException {
		// 判断是否传入业务流水号
		if (Tools.processNull(dealNo).equals("")) {
			throw new CommonException("未传入业务流水号！");
		}
		// 判断是否存在当前业务记录
		TrServRec trServRec = (TrServRec) baseService.findOnlyRowByHql("from TrServRec t where t.dealNo = " + dealNo);
		if (trServRec == null) {
			throw new CommonException("业务流水号【" + dealNo + "】记录信息不存在！");
		}
		// 判断当前业务记录状态是否为正常
		if (!trServRec.getDealState().equals(Constants.TR_STATE_ZC)) {
			throw new CommonException("业务流水号【" + dealNo + "】为【撤销】状态！");
		}
		// 判断当前充值卡号的销售业务流水号是否对应
		if (cardRecharge.getXsDealNo().compareTo(trServRec.getDealNo()) != 0) {
			throw new CommonException("业务流水号【" + dealNo + "】与充值卡【" + cardRecharge.getCardNo() + "】销售业务流水号异常！");
		}
		return trServRec;
	}

	/**
	 * 查询单张充值卡。
	 * @return
	 */
	public String getRechargeCardInfo(){
		jsonObject.put("cardRecharge",new CardRecharge());
		try{
			CardRecharge cardRecharge = judgementRechargeCard(cardNo, false);
			judgementStockAcc(cardNo);
			String cardType = (String) baseService.findOnlyFieldBySql("select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = '" + cardRecharge.getCardType() + "'");
			String useState = (String) baseService.findOnlyFieldBySql("select code_name from sys_code where code_type = 'RECHG_STATE' and code_value = '" + cardRecharge.getUseState() + "'");
			cardRecharge.setCardType(cardType);
			cardRecharge.setUseState(useState);
			jsonObject.put("cardRecharge", cardRecharge);
		}catch(Exception e){
			jsonObject.put("errorMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 查询充值卡。
	 * @return
	 */
	public String queryRechargeCard() {
		try {
			this.initGrid();
			if (Tools.processNull(queryType).equals("0")) {
				judgementStockAcc(null);
				StringBuffer sb = new StringBuffer();
				sb.append("select c.task_id, c.org_id, c.card_no, c.face_val, ");
				sb.append("(select s1.code_name from sys_code s1 where s1.code_type = 'CARD_TYPE' and s1.code_value = c.card_type) card_type, ");
				sb.append("(select s2.code_name from sys_code s2 where s2.code_type = 'RECHG_STATE' and s2.code_value = c.use_state) use_state ");
				sb.append(" from card_recharge c, stock_list s where 1 = 1 and c.card_no = s.goods_no(+)");
				sb.append(" and s.stk_code = '1" + Constants.CARD_TYPE_CZK + "' and s.goods_state = '" + Constants.GOODS_STATE_ZC + "'");
				sb.append(" and s.stk_is_sure = '" + Constants.YES_NO_YES + "' and s.user_id = '" + getUsers().getUserId() + "'");
				if (!Tools.processNull(taskId).equals("")) {
					sb.append(" and c.task_id = '" + taskId + "'");
				}
				if (!Tools.processNull(cardType).equals("")) {
					sb.append(" and c.card_type = '" + cardType + "'");
				}
				if (!Tools.processNull(cardNo).equals("")) {
					sb.append(" and c.card_no = '" + cardNo + "'");
				}
				if (!Tools.processNull(sort).equals("")) {
					sb.append(" order by " + sort + " " + order);
				} else {
					sb.append(" order by c.task_id");
				}
				Page list = baseService.pagingQuery(sb.toString(), page, rows);
				if (list.getAllRs() != null && list.getAllRs().size() > 0) {
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				} else {
					throw new CommonException("根据查询条件未找到对应的充值卡信息！");
				}
			}
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 查询充值卡销售记录。
	 * @return
	 */
	public String queryRechargeCardSaleRecord() {
		try {
			this.initGrid();
			if (Tools.processNull(queryType).equals("0")) {
				judgementStockAcc(null);
				StringBuffer sb = new StringBuffer();
				sb.append("select t.deal_no, t.deal_code, c.card_no, c.face_val, t.user_id, t.note, ");
				sb.append("(select s1.code_name from sys_code s1 where s1.code_type = 'CARD_TYPE' and s1.code_value = c.card_type) card_type, ");
				sb.append("(select s2.code_name from sys_code s2 where s2.code_type = 'RECHG_STATE' and s2.code_value = c.use_state) use_state, ");
				sb.append("(select s3.code_name from sys_code s3 where s3.code_type = 'TR_STATE' and s3.code_value = t.deal_state) deal_state, ");
				sb.append("(select s4.full_name from sys_branch s4 where s4.brch_id = t.brch_id) brch_id, ");
				sb.append("to_char(t.biz_time,'yyyy-MM-dd hh24:mi:ss') biz_time, t.clr_date ");
				sb.append(" from card_recharge c, stock_list s, tr_serv_rec t where 1 = 1 and s.user_id = t.user_id and s.goods_no = c.card_no and c.xs_deal_no = t.deal_no");
				sb.append(" and s.user_id = '" + getUsers().getUserId() + "'");
				sb.append(" and t.deal_code in (" + DealCode.RECHANGE_CARD_SELL + "," + DealCode.RECHANGE_CARD_BATCHSELL + ")");
				sb.append(" and t.deal_state = '" + Constants.TR_STATE_ZC + "' and c.use_state = '" + Constants.CARD_RECHARGE_STATE_YJH + "'");
				if (!Tools.processNull(dealNo).equals("")) {
					sb.append(" and t.deal_no = " + dealNo);
				}
				if (!Tools.processNull(cardType).equals("")) {
					sb.append(" and c.card_type = '" + cardType + "'");
				}
				if (!Tools.processNull(cardNo).equals("")) {
					sb.append(" and c.card_no = '" + cardNo + "'");
				}
				if (!Tools.processNull(bizTime).equals("")) {
					sb.append(" and to_char(t.biz_time, 'yyyy-MM-dd') = '" + bizTime + "'");
				}
				if (!Tools.processNull(sort).equals("")) {
					sb.append(" order by " + sort + " " + order);
				} else {
					sb.append(" order by t.deal_no");
				}
				Page list = baseService.pagingQuery(sb.toString(), page, rows);
				if (list.getAllRs() != null && list.getAllRs().size() > 0) {
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				} else {
					throw new CommonException("根据查询条件未找到对应的充值卡销售记录信息！");
				}
			}
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 保存充值卡销售记录。
	 * @return
	 */
	public String saveRechargeCard() {
		jsonObject.put("status", "1");
		jsonObject.put("errMsg", "");
		try {
			CardRecharge cardRecharge = judgementRechargeCard(cardNo, false);
			judgementStockAcc(cardNo);
			TrServRec trServRec = rechargeCardSaleService.saveRechargeCard(baseService.getCurrentActionLog(), cardRecharge);
			jsonObject.put("status", "0");
			jsonObject.put("title", Constants.APP_REPORT_TITLE + baseService.findTrCodeNameByCodeType(trServRec.getDealCode()) + "凭证");
			jsonObject.put("dealNo", trServRec.getDealNo());
		} catch (Exception e){
			e.printStackTrace();
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 批量保存充值卡销售记录。
	 * @return
	 */
	public String batchSaveRechargeCard() {
		jsonObject.put("status", "1");
		jsonObject.put("errMsg", "");
		try {
			if (Tools.processNull(cardNos).equals("")) {
				throw new CommonException("未传入卡号数据！");
			}
			judgementStockAcc(null);
			TrServRec trServRec = rechargeCardSaleService.saveBatchRechargeCard(baseService.getCurrentActionLog(), cardNos);
			jsonObject.put("status", "0");
			jsonObject.put("title", Constants.APP_REPORT_TITLE + baseService.findTrCodeNameByCodeType(trServRec.getDealCode()) + "凭证");
			jsonObject.put("dealNo", trServRec.getDealNo());
		} catch (Exception e) {
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 撤销充值卡销售记录。
	 * @return
	 */
	public String undoRechargeCard() {
		jsonObject.put("status", "1");
		jsonObject.put("errMsg", "");
		try {
			judgementStockAcc(cardNo);
			CardRecharge cardRecharge = judgementRechargeCard(cardNo, true);
			TrServRec trServRec = judgementTrServRec(dealNo, cardRecharge);
			trServRec = rechargeCardSaleService.modifyRechargeCard(baseService.getCurrentActionLog(), trServRec, cardRecharge);
			jsonObject.put("status", "0");
			jsonObject.put("title", Constants.APP_REPORT_TITLE + baseService.findTrCodeNameByCodeType(trServRec.getDealCode()) + "凭证");
			jsonObject.put("dealNo", trServRec.getDealNo());
		} catch (Exception e) {
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	private void initGrid() throws Exception {
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		jsonObject.put("status", 0);
		jsonObject.put("errMsg", "");
	}

	public String getTaskId() {
		return taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
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

	public String getDealNo() {
		return dealNo;
	}

	public void setDealNo(String dealNo) {
		this.dealNo = dealNo;
	}

	public String getBizTime() {
		return bizTime;
	}

	public void setBizTime(String bizTime) {
		this.bizTime = bizTime;
	}

	public void setCardNos(String cardNos) {
		this.cardNos = cardNos;
	}

	public String getCardNos() {
		return cardNos;
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
