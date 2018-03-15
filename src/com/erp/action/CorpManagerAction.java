package com.erp.action;

import java.io.File;
import java.io.FileInputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.BaseCorp;
import com.erp.model.BaseCorpRechargeInfo;
import com.erp.model.BaseCorpRechargeList;
import com.erp.model.BaseCorpRechargeListPK;
import com.erp.model.TrServRec;
import com.erp.service.CorpManagerService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.ExcelUtil;
import com.erp.util.JsonHelper;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

@Namespace("/corpManager")
@Action("corpManagerAction")
@Results({
		@Result(name = "corpAdd&Edit", location = "/jsp/corp/corpAdd&Edit.jsp"),
		@Result(name = "toCorpCashAccRecharge", location = "/jsp/corp/corpAccRechargePage.jsp") })
public class CorpManagerAction extends BaseAction {
	private static final long serialVersionUID = 1L;

	private CorpManagerService corpManagerService;

	private String customerId;
	private String corpName;
	private String corpType;
	private String checkFlag;
	private String state;
	private String sort;
	private String order;
	private String queryType;
	private String corpState;
	private BaseCorp corp;
	private Boolean checkSuccess;
	private Boolean enabled;
	private BigDecimal amount;
	private Boolean jugeCorp = false;

	private AccAccountSub corpAccount;

	private BaseCorpRechargeList list = new BaseCorpRechargeList(new BaseCorpRechargeListPK());
	private File file;
	private String selections;

	private BaseCorpRechargeInfo info = new BaseCorpRechargeInfo();

	/**
	 * 查询单位信息
	 * 
	 * @return
	 */
	public String queryCorpInfo() {
		try {
			initGrid();

			if (!"0".equals(queryType)) {
				return JSONOBJ;
			}

			StringBuilder sql = new StringBuilder();

			sql.append("SELECT CUSTOMER_ID, CORP_NAME, ABBR_NAME, "
					+ "(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE='CORP_TYPE' AND CODE_VALUE=C.CORP_TYPE)CORP_TYPE, "
					+ "ADDRESS, POST_CODE, CONTACT, CON_PHONE, CEO_NAME, CEO_PHONE, LEG_NAME, "
					+ "(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE='CERT_TYPE' AND CODE_VALUE=C.CERT_TYPE)CERT_TYPE, "
					+ "CERT_NO, LEG_PHONE, FAX_NO, EMAIL, PROV_CODE, "
					+ "(SELECT CITY_NAME FROM BASE_CITY WHERE CITY_ID=C.CITY_CODE)CITY_CODE, "
					+ "SERV_PWD_ERR_NUM, NET_PWD_ERR_NUM, OPEN_DATE, OPEN_USER_ID, CLS_USER_ID, CLS_DATE, MNG_USER_ID, LICENSE_NO, "
					+ "(SELECT REGION_NAME FROM BASE_REGION WHERE REGION_ID=C.REGION_ID) REGION_ID, AREA_CODE, "
					+ "(SELECT CORP_NAME FROM BASE_CORP WHERE CUSTOMER_ID=C.P_CUSTOMER_ID)P_CUSTOMER_ID, COMPANYID, "
					+ "CARREF_FLAG, CHK_FLAG, CHK_DATE,CHK_USER_ID, NOTE, CORP_STATE, "
					+ "(select 1 from acc_account_sub where customer_id = c.customer_id and acc_state != '" 
					+ Constants.ACC_STATE_ZX + "') open_flag FROM BASE_CORP C WHERE 1 = 1 ");

			if (!Tools.processNull(customerId).equals("")) {
				sql.append("and c.customer_id = '" + customerId + "'");
			}
			if (!Tools.processNull(corpName).equals("")) {
				sql.append("and c.corp_name = '" + corpName + "'");
			}
			if (!Tools.processNull(corpType).equals("")) {
				sql.append("and c.corp_type = '" + corpType + "'");
			}
			if (!Tools.processNull(checkFlag).equals("")) {
				sql.append("and c.chk_flag = '" + checkFlag + "'");
			}
			if (!Tools.processNull(state).equals("")) {
				sql.append("and c.corp_state = '" + state + "'");
			}

			if (!Tools.processNull(sort).equals("")) {
				sql.append(" order by " + sort);

				if (!Tools.processNull(order).equals("")) {
					sql.append(" " + order);
				}
			}

			Page data = corpManagerService.pagingQuery(sql.toString(), page,
					rows);

			if (data == null || data.getTotalCount() == 0) {
				throw new CommonException("找不到记录.");
			}

			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", "获取数据失败, " + e.getMessage());
		}
		return JSONOBJ;
	}

	public String initAutoComplete() {
		try {
			jsonObject.put("status", "0");

			StringBuilder sql = new StringBuilder();
			sql.append("select customer_id label, corp_name text from base_corp where 1=1 ");
			if (jugeCorp) {
				sql.append("and region_id = '" + baseService.getBrchRegion() + "'");
			}
			if (!Tools.processNull(customerId).equals("")) {
				sql.append("and customer_id like '%" + customerId + "%'");
			} else if (!Tools.processNull(corpName).equals("")) {
				sql.append("and corp_name like '%" + corpName + "%'");
			}
			Page data = corpManagerService.pagingQuery(sql.toString(), page, rows);
			jsonObject.put("rows", data.getAllRs());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}

		return JSONOBJ;
	}

	public String getCorpTree() {
		try {
			jsonObject.put("status", "0");

			String hql = "from BaseCorp where 1=1 ";

			if (!Tools.processNull(corpState).equals("")) {
				hql += " and corpState='" + corpState + "'";
			}

			OutputJson(corpManagerService.findByHql(hql));

		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}

		return JSONOBJ;
	}

	public String saveCorpInfo() {
		try {
			jsonObject.put("status", "0");
			corp.setOpenDate(new Date());
			corp.setOpenUserId(getUserId());
			corpManagerService.saveCorpRegist(corp);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String editCorp() {
		try {
			if (Tools.processNull(customerId).equals("")) {
				throw new CommonException("单位编号为空.");
			}

			corp = (BaseCorp) corpManagerService.findOnlyRowByHql("from BaseCorp where customerId='" + customerId + "'");

			if (corp == null) {
				throw new CommonException("单位信息不存在.");
			}

		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
		return "corpAdd&Edit";
	}

	public String modifyCorpInfo() {
		try {
			jsonObject.put("status", "0");
			if (!"99999999".equals(baseService.getSessionSysBranch().getBrchId()) && !corp.getRegionId().equals(baseService.getBrchRegion())) {
				throw new CommonException("单位不属于本区域！");
			}
			corpManagerService.saveCorpModify(corp);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String corpAdd() {
		return "corpAdd&Edit";
	}

	public String registCheck() {
		try {
			jsonObject.put("status", "0");

			if (Tools.processNull(customerId).equals("")) {
				throw new CommonException("审核单位为空.");
			}

			if (Tools.processNull(checkSuccess).equals("")) {
				throw new CommonException("审核状态为空.");
			}

			corpManagerService.saveRegistCheck(customerId, checkSuccess, getUsers());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}

		return JSONOBJ;
	}

	public String corpEnable() {
		try {
			jsonObject.put("status", "0");

			if (Tools.processNull(customerId).equals("")) {
				throw new CommonException("启用单位为空.");
			}

			if (Tools.processNull(enabled).equals("")) {
				throw new CommonException("启用/注销状态为空.");
			}

			corpManagerService.saveCorpEnable(customerId, enabled, getUsers());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}

		return JSONOBJ;
	}

	public String corpOpenAcc() {
		try {
			jsonObject.put("status", "0");

			if (Tools.processNull(customerId).equals("")) {
				throw new CommonException("请选择入网单位.");
			}

			corpManagerService.createCorpAcc(customerId);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}

		return JSONOBJ;
	}

	/**
	 * 单位现金账户充值
	 * 
	 * @return
	 */
	public String corpCashAccRecharge() {
		try {
			jsonObject.put("status", "0");

			if (Tools.processNull(customerId).equals("")) {
				throw new CommonException("请选择充值单位.");
			}

			if (amount.compareTo(BigDecimal.valueOf(0)) <= 0) {
				throw new CommonException("充值金额必须大于0.");
			}

			TrServRec trServRec = corpManagerService.saveCashAccRecharge(customerId, amount);
			jsonObject.put("dealNo", trServRec.getDealNo());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}

		return JSONOBJ;
	}

	public String toCorpCashAccRecharge() {
		try {
			if (Tools.processNull(customerId).equals("")) {
				throw new CommonException("请选择充值单位.");
			}

			corpName = (String) corpManagerService.findOnlyFieldBySql("select corp_name from base_corp where customer_id = '" + customerId + "'");

			corpAccount = (AccAccountSub) corpManagerService.findOnlyRowByHql("from AccAccountSub where customerId = '"
							+ customerId + "' and itemId = '101101' and accState = '1'");

			if (corpAccount == null) {
				throw new CommonException("单位账户不存在.");
			}

			return "toCorpCashAccRecharge";
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}

	// 1-导入数据查询, 2-导入批量充值数据, 3-审核导入批量充值数据, 4-导入数据充值, 5-删除导入数据
	public String queryImportCorpBatchRechargeInfo() {
		try {
			initGrid();

			if (Tools.processNull(customerId).equals("")) {
				throw new CommonException("单位编号为空, 请选择单位.");
			}

			StringBuilder sql = new StringBuilder(
					"SELECT RCG_INFO_ID, t.CUSTOMER_ID, t.RECHAGE_USER_ID, t.CERT_NO, "
							+ "(SELECT ACC_NAME FROM ACC_KIND_CONFIG WHERE ACC_KIND = T.ACC_KIND) ACC_KIND, "
							+ "to_char(t.AMT, '99990.00') AMT, t.STATE, t.IMP_UERS_ID, TO_CHAR(t.IMP_DEAL_DATE, 'yyyy-mm-dd hh24:mi:ss') IMP_DEAL_DATE, "
							+ "t.CHECK_USER_ID, TO_CHAR(t.CHECK_DEAL_DATE, 'yyyy-mm-dd hh24:mi:ss') CHECK_DEAL_DATE, t.NAME, "
							+ "t.CARD_NO, TO_CHAR(t.RECHAGE_DEAL_DATE, 'yyyy-mm-dd hh24:mi:ss') RECHAGE_DEAL_DATE, t.NOTE "
							+ "FROM base_corp_rechage_list t join base_corp_rechage_info t2 on t.rcg_info_id = t2.id "
							+ "WHERE t2.customer_id = '" + customerId + "'");

			if (!Tools.processNull(list.getCertNo()).equals("")) {
				sql.append("and t.cert_no = '" + list.getCertNo() + "'");
			}
			if (!Tools.processNull(list.getPk().getRcgInfoId()).equals("")) {
				sql.append("and t.rcg_info_id = '"
						+ list.getPk().getRcgInfoId() + "'");
			}
			if (!Tools.processNull(list.getState()).equals("")) {
				sql.append("and t.state = '" + list.getState() + "'");
			}

			if (!Tools.processNull(sort).equals("")) {
				sql.append(" order by " + sort);

				if (!Tools.processNull(order).equals("")) {
					sql.append(" " + order);
				}
			}

			Page data = corpManagerService.pagingQuery(sql.toString(), page, rows);

			if (data == null || data.getTotalCount() == 0) {
				throw new CommonException("找不到记录.");
			}

			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", "获取数据失败, " + e.getMessage());
		}
		return JSONOBJ;
	}

	public String queryImportBatchInfo() {
		try {
			initGrid();

			if (Tools.processNull(customerId).equals("")) {
				throw new CommonException("单位编号为空, 请选择单位.");
			}

			StringBuilder sql = new StringBuilder("SELECT ID, CUSTOMER_ID, RECHAGE_TYPE, NUM, to_char(t.AMT, '99990.00') AMT, t.NOTE, "
							+ "t.STATE, t.IMP_UERS_ID, TO_CHAR(t.IMP_DEAL_DATE, 'yyyy-mm-dd hh24:mi:ss') IMP_DEAL_DATE, "
							+ "t.CHECK_USER_ID, TO_CHAR(t.CHECK_DEAL_DATE, 'yyyy-mm-dd hh24:mi:ss') CHECK_DEAL_DATE, "
							+ "TO_CHAR(t.RECHAGE_DEAL_DATE, 'yyyy-mm-dd hh24:mi:ss') RECHAGE_DEAL_DATE, RECHAGE_USER_ID "
							+ "FROM base_corp_rechage_info t WHERE customer_id = '" + customerId + "'");

			if (!Tools.processNull(info.getId()).equals("")) {
				sql.append("and t.id = '" + info.getId() + "'");
			}
			if (!Tools.processNull(info.getImpDealDate()).equals("")) {
				sql.append("and t.imp_deal_date <= to_date('" + DateUtil.formatDate(info.getImpDealDate(), "yyyy-MM-dd") + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss')");
			}
			if (!Tools.processNull(info.getState()).equals("")) {
				sql.append("and t.state = '" + info.getState() + "'");
			}

			if (!Tools.processNull(sort).equals("")) {
				sql.append(" order by " + sort);

				if (!Tools.processNull(order).equals("")) {
					sql.append(" " + order);
				}
			} else {
				sql.append(" order by id desc");
			}

			Page data = corpManagerService.pagingQuery(sql.toString(), page, rows);
			if (data == null || data.getTotalCount() == 0) {
				throw new CommonException("该单位目前没有批量充值记录.");
			}
			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", "获取数据失败, " + e.getMessage());
		}
		return JSONOBJ;
	}

	public String importCorpBatchRechargeInfo() {
		try {
			jsonObject.put("status", "0");

			if (file == null) {
				throw new CommonException("上传文件为空.");
			} else if (Tools.processNull(customerId).equals("")) {
				throw new CommonException("单位编号为空, 请选择单位.");
			}

			ExcelUtil<BaseCorpRechargeList> excelUtil = new ExcelUtil<BaseCorpRechargeList>(BaseCorpRechargeList.class);
			List<BaseCorpRechargeList> list = excelUtil.importExcel("sheet1", new FileInputStream(file));
			if (list == null || list.isEmpty()) {
				throw new CommonException("导入批量充值数据为空.");
			}

			List<BaseCorpRechargeList> failList = corpManagerService.saveImportBatchRechargeInfo(list, customerId, jugeCorp);
			if (failList != null && !failList.isEmpty()) {
				jsonObject.put("msg", "共" + list.size() + "条记录, 成功" + (list.size() - failList.size()) + "条, 失败" + failList.size() + "条.");
				jsonObject.put("failList", JsonHelper.parse2JSON(failList));
			}
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}

		return JSONOBJ;
	}

	public String checkPassCorpBatchRechargeInfo() {
		try {
			if (Tools.processNull(customerId).equals("")) {
				throw new CommonException("单位编号为空, 请选择单位.");
			} else if (Tools.processNull(selections).equals("")) {
				throw new CommonException("选择记录为空.");
			}

			List<BaseCorpRechargeList> rechargeList = new ArrayList<BaseCorpRechargeList>();
			String[] selections2 = selections.split(",");
			for (String select : selections2) {
				String[] item = select.split("\\|");

				BaseCorpRechargeListPK pk = new BaseCorpRechargeListPK();
				pk.setRcgInfoId(Long.valueOf(item[0]));
				pk.setCustomerId(item[1]);

				rechargeList.add(new BaseCorpRechargeList(pk));
			}

			List<BaseCorpRechargeList> failList = corpManagerService.saveCheckPassImportBatchRechargeInfo(rechargeList, customerId);

			if (failList != null && !failList.isEmpty()) {
				jsonObject.put("msg", "共" + rechargeList.size() + "条记录, 成功" + (rechargeList.size() - failList.size()) + "条, 失败" + failList.size() + "条.");
				jsonObject.put("failList", JsonHelper.parse2JSON(failList));
			}
			jsonObject.put("status", "0");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}

		return JSONOBJ;
	}

	public String rechargeFromCorpBatchRechargeInfo() {
		try {
			if (Tools.processNull(customerId).equals("")) {
				throw new CommonException("单位编号为空, 请选择单位.");
			} else if (Tools.processNull(selections).equals("")) {
				throw new CommonException("选择记录为空.");
			}

			List<BaseCorpRechargeList> checkPassList = new ArrayList<BaseCorpRechargeList>();
			String[] selections2 = selections.split(",");
			for (String select : selections2) {
				String[] item = select.split("\\|");
				BaseCorpRechargeListPK pk = new BaseCorpRechargeListPK();
				pk.setRcgInfoId(Long.valueOf(item[0]));
				pk.setCustomerId(item[1]);
				checkPassList.add(new BaseCorpRechargeList(pk));
			}
			if (checkPassList.isEmpty()) {
				throw new CommonException("导入批量充值数据为空.");
			}
			List<BaseCorpRechargeList> failList = corpManagerService.saveRechargeBatchRechargeInfo(checkPassList, customerId);
			if (failList != null && !failList.isEmpty()) {
				jsonObject.put("msg", "共" + checkPassList.size() + "条记录, 成功" + (checkPassList.size() - failList.size()) + "条, 失败" + failList.size() + "条.");
				jsonObject.put("failList", JsonHelper.parse2JSON(failList));
			}
			jsonObject.put("status", "0");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String deleteCorpBatchRechargeInfo() {
		try {
			jsonObject.put("status", "0");

			if (Tools.processNull(customerId).equals("")) {
				throw new CommonException("单位编号为空, 请选择单位.");
			}

			if (Tools.processNull(selections).equals("")) {
				throw new CommonException("选择记录为空.");
			}

			String[] selections2 = selections.split(",");

			List<BaseCorpRechargeList> selectList = new ArrayList<BaseCorpRechargeList>();

			for (String select : selections2) {
				String[] item = select.split("\\|");

				BaseCorpRechargeListPK pk = new BaseCorpRechargeListPK();
				pk.setRcgInfoId(Long.valueOf(item[0]));
				pk.setCustomerId(item[1]);

				selectList.add(new BaseCorpRechargeList(pk));
			}

			if (selectList == null || selectList.isEmpty()) {
				throw new CommonException("导入批量充值数据为空.");
			}

			List<BaseCorpRechargeList> failList = corpManagerService.deleteBatchRechargeInfo(selectList, customerId);

			if (failList != null && !failList.isEmpty()) {
				jsonObject.put("msg", "共" + selectList.size() + "条记录, 成功"
						+ (selectList.size() - failList.size()) + "条, 失败"
						+ failList.size() + "条.");
				jsonObject.put("failList", JsonHelper.parse2JSON(failList));
			}
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}

		return JSONOBJ;
	}
	
	public String deleteBatchInfo() {
		try {
			if (info == null || info.getId() == null) {
				throw new CommonException("请选择记录!");
			}
			corpManagerService.deleteBatchRechargeInfo(info);
			jsonObject.put("status", "0");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	private void validate(BaseCorp corp2) {

	}

	private void initGrid() {
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		jsonObject.put("status", "0");
		jsonObject.put("errMsg", "");
	}

	public CorpManagerService getCorpManagerService() {
		return corpManagerService;
	}

	public void setCorpManagerService(CorpManagerService corpManagerService) {
		this.corpManagerService = corpManagerService;
	}

	public String getCustomerId() {
		return customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

	public String getCorpName() {
		return corpName;
	}

	public void setCorpName(String corpName) {
		this.corpName = corpName;
	}

	public String getCorpType() {
		return corpType;
	}

	public void setCorpType(String corpType) {
		this.corpType = corpType;
	}

	public String getCheckFlag() {
		return checkFlag;
	}

	public void setCheckFlag(String checkFlag) {
		this.checkFlag = checkFlag;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
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

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}

	public String getCorpState() {
		return corpState;
	}

	public void setCorpState(String corpState) {
		this.corpState = corpState;
	}

	public BaseCorp getCorp() {
		return corp;
	}

	public void setCorp(BaseCorp corp) {
		this.corp = corp;
	}

	public Boolean getCheckSuccess() {
		return checkSuccess;
	}

	public void setCheckSuccess(Boolean checkSuccess) {
		this.checkSuccess = checkSuccess;
	}

	public Boolean getEnabled() {
		return enabled;
	}

	public void setEnabled(Boolean enabled) {
		this.enabled = enabled;
	}

	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	public AccAccountSub getCorpAccount() {
		return corpAccount;
	}

	public void setCorpAccount(AccAccountSub corpAccount) {
		this.corpAccount = corpAccount;
	}

	public BaseCorpRechargeList getList() {
		return list;
	}

	public void setList(BaseCorpRechargeList list) {
		this.list = list;
	}

	public File getFile() {
		return file;
	}

	public void setFile(File file) {
		this.file = file;
	}

	public String getSelections() {
		return selections;
	}

	public void setSelections(String selections) {
		this.selections = selections;
	}

	public BaseCorpRechargeInfo getInfo() {
		return info;
	}

	public void setInfo(BaseCorpRechargeInfo info) {
		this.info = info;
	}

	public Boolean getJugeCorp() {
		return jugeCorp;
	}

	public void setJugeCorp(Boolean jugeCorp) {
		this.jugeCorp = jugeCorp;
	}
}
