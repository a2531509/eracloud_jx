package com.erp.action;

import java.io.File;
import java.io.FileInputStream;
import java.util.List;

import javax.annotation.Resource;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseComm;
import com.erp.model.BaseCorp;
import com.erp.model.TrServRec;
import com.erp.service.LkBranchService;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**
 * 单位/社区（村）领卡网点查询和设置。
 * 
 * @author 钱佳明。
 * @date 2015-12-10。
 *
 */
@Namespace("/lkBranch")
@Action(value = "lkBranchAction")
@Results({@Result(name="getLkBranch",location="/jsp/lkBranchManage/lkBranchManageEdit.jsp")})
public class LkBranchAction extends BaseAction {

	private static final long serialVersionUID = 1L;

	@Resource(name = "lkBranchService")
	private LkBranchService lkBranchService;

	private String corpOrCommId;
	private String corpOrCommName;
	private String lkBranchId;
	private String isCorpOrComm;
	private String branchId;
	private String isSettings;
	private String corpCustomerId;
	private String corpName;
	private String regionId;
	private String townId;
	private String commId;
	private String lkBranchId2;
	private String lkOrgId;
	private String lkOrgId2;
	private String isBatchHf;
	private File[] file;

	private String queryType = "1";
	private String sort;
	private String order;
	private String defaultErrorMsg;

	public String findAllLkBranch() {
		try {
			initGrid();
			if (!Tools.processNull(queryType).equals("")) {
				StringBuffer sb = new StringBuffer();
				if (Tools.processNull(isCorpOrComm).equals("0")) {
					sb.append("select b.customer_id as corp_or_comm_id, b.corp_name as corp_or_comm_name, b.lk_brch_id as lk_branch_id,");
					sb.append("(select s.full_name from sys_branch s where s.brch_id = b.lk_brch_id) as lk_branch_name, lk_brch_id2, "
							+ "(select s.full_name from sys_branch s where s.brch_id = b.lk_brch_id2) as lk_branch_name2, b.is_batch_hf, ");
					sb.append("to_char(tr.biz_time, 'yyyy-mm-dd hh24:mi:ss') biz_time, (select full_name from sys_branch where brch_id = tr.brch_id) brch_name, (select name from sys_users where user_id = tr.user_id) user_name ");
					sb.append(" from base_corp b left join tr_serv_rec tr on b.deal_no = tr.deal_no where 1 = 1 ");
					if (!"99999999".equals(baseService.getSessionSysBranch().getBrchId())) {
						sb.append(" and b.region_id = '" + baseService.getBrchRegion() + "' ");
					}
					if (!Tools.processNull(isSettings).equals("")) {
						sb.append(" and b.lk_brch_id is " + (isSettings.equals("0") ? "not" : "") + " null");
					}
					if (!Tools.processNull(branchId).equals("") && !isSettings.equals("1")) {
						sb.append(" and b.lk_brch_id = '" + branchId + "'");
					}
					if (!Tools.processNull(corpCustomerId).equals("")) {
						sb.append(" and b.customer_id = '" + corpCustomerId + "'");
					}
				} else if (Tools.processNull(isCorpOrComm).equals("1")) {
					sb.append("select b.comm_id as corp_or_comm_id, b.comm_name as corp_or_comm_name, b.lk_brch_id as lk_branch_id,");
					sb.append("(select s.full_name from sys_branch s where s.brch_id = b.lk_brch_id) as lk_branch_name,  lk_brch_id2, "
							+ "(select s.full_name from sys_branch s where s.brch_id = b.lk_brch_id2) as lk_branch_name2 ");
					sb.append(" from base_comm b where 1 = 1");
					if (!Tools.processNull(isSettings).equals("")) {
						sb.append(" and b.lk_brch_id is " + (isSettings.equals("0") ? "not" : "") + " null");
					}
					if (!Tools.processNull(branchId).equals("") && !isSettings.equals("1")) {
						sb.append(" and b.lk_brch_id = '" + branchId + "'");
					}
					if (!Tools.processNull(regionId).equals("") && Tools.processNull(townId).equals("")) {
						List<String> lists = baseService.findBySql("select town_id from base_town where region_id = '" + regionId + "'");
						if(lists.size() != 0) {
							StringBuffer townIds = new StringBuffer();
							for(int i=0;i<lists.size();i++){
								townIds.append("'" + lists.get(i) + "'");
								if(lists.size() - 1 != i) {
									townIds.append(",");
								}
							}
							sb.append(" and b.town_id in (" + townIds + ")");
						}
					}
					if (!Tools.processNull(townId).equals("")) {
						sb.append(" and b.town_id = '" + townId + "'");
					}
					if (!Tools.processNull(commId).equals("")) {
						sb.append(" and b.comm_id = '" + commId + "'");
					}
				}
				if(!Tools.processNull(this.sort).equals("")){
					sb.append(" order by " + this.sort + " " + this.order);
				}else{
					sb.append(" order by corp_or_comm_id");
				}
				Page list = baseService.pagingQuery(sb.toString(), page, rows);
				if (list.getAllRs() != null && list.getAllRs().size() > 0) {
					jsonObject.put("rows", list.getAllRs());
					jsonObject.put("total", list.getTotalCount());
				} else {
					throw new CommonException("根据查询条件未找到对应的单位领卡网点信息！");
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String getLkBranch() {
		try {
			if(!Tools.processNull(isCorpOrComm).equals("") && !Tools.processNull(corpOrCommId).equals("")) {
				if(Tools.processNull(isCorpOrComm).equals("0")) {
					BaseCorp baseCorp = (BaseCorp) baseService.findOnlyRowByHql("from BaseCorp b where b.customerId = '" + corpOrCommId + "'");
					if(baseCorp != null) {
						setIsCorpOrComm(isCorpOrComm);
						setCorpOrCommId(baseCorp.getCustomerId());
						setCorpOrCommName(baseCorp.getCorpName());
						setLkBranchId(baseCorp.getLkBrchId());
						setLkBranchId2(baseCorp.getLkBrchId2());
						setLkOrgId((String) baseService.findOnlyFieldBySql("select org_id from sys_branch where brch_id = '" + baseCorp.getLkBrchId() + "'"));
						setLkOrgId2((String) baseService.findOnlyFieldBySql("select org_id from sys_branch where brch_id = '" + baseCorp.getLkBrchId2() + "'"));
						isBatchHf = baseCorp.getIsBatchHf();
					}
				} else if(Tools.processNull(isCorpOrComm).equals("1")) {
					BaseComm baseComm = (BaseComm) baseService.findOnlyRowByHql("from BaseComm b where b.commId = '" + corpOrCommId + "'");
					if(baseComm != null) {
						setIsCorpOrComm(isCorpOrComm);
						setCorpOrCommId(baseComm.getCommId());
						setCorpOrCommName(baseComm.getCommName());
						setLkBranchId(baseComm.getLkBrchId());
						setLkBranchId2(baseComm.getLkBrchId2());
						setLkOrgId((String) baseService.findOnlyFieldBySql("select org_id from sys_branch where brch_id = '" + baseComm.getLkBrchId() + "'"));
						setLkOrgId2((String) baseService.findOnlyFieldBySql("select org_id from sys_branch where brch_id = '" + baseComm.getLkBrchId2() + "'"));
					}
				}
			}
		} catch (Exception e){
			e.printStackTrace();
		}
		return "getLkBranch";
	}
	
	public String settingLkBranch() {
		jsonObject.put("status", "1");
		jsonObject.put("msg", "");
		try {
			TrServRec rec = lkBranchService.saveLkBranch(isCorpOrComm, corpOrCommId, lkBranchId, lkBranchId2, isBatchHf, false);
			jsonObject.put("dealNo", rec.getDealNo());
			jsonObject.put("status", "0");
			jsonObject.put("msg", "设置单位/社区（村）领卡网点信息成功！");
		} catch (Exception e) {
			jsonObject.put("msg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String importCorpSetting(){
		try {
			queryType = "0";
			if (file == null || file.length == 0) {
				throw new CommonException("上传文件为空.");
			}
			Workbook workbook = new HSSFWorkbook(new FileInputStream(file[0]));
			Sheet sheet = workbook.getSheetAt(0);
			int lastRowNum = sheet.getLastRowNum();
			JSONArray msgList = new JSONArray();
			int succNum = 0;
			int count = 0;
			for (int i = 1; i <= lastRowNum; i++) {
				String corpId = "";
				String lkBranchId = "";
				try {
					Row row = sheet.getRow(i);
					if (row == null) {
						continue;
					}
					//
					Cell cell = row.getCell(0);
					if (cell == null) {
						continue;
					}
					count++;
					corpId = cell.getStringCellValue();
					if (corpId == null || !corpId.matches("[0-9]{10}")) {
						throw new CommonException("单位编号不正确！");
					}
					//
					Cell cell2 = row.getCell(2);
					if (cell2 != null && cell2.getStringCellValue() != null) {
						lkBranchId = cell2.getStringCellValue().trim();
					}
					//
					String isBatchHf = "1";
					Cell cell4 = row.getCell(3);
					if (cell4 != null && cell4.getStringCellValue() != null) {
						isBatchHf = cell4.getStringCellValue().trim();
						if(isBatchHf.equals("是")){
							isBatchHf = "0";
						} else {
							isBatchHf = "1";
						}
					}
					lkBranchService.saveLkBranch("0", corpId, lkBranchId, null, isBatchHf, true);
					succNum++;
				} catch (Exception e) {
					JSONObject item = new JSONObject();
					item.put("corpId", corpId);
					item.put("lkBrchId", lkBranchId);
					item.put("failMsg", e.getMessage());
					msgList .add(item);
				}
			}
			workbook.close();
			jsonObject.put("status", "0");
			jsonObject.put("msgList", msgList);
			jsonObject.put("succNum", succNum);
			jsonObject.put("count", count);
		} catch (Exception e) {
			jsonObject.put("status", "1");
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

	public String getCorpOrCommId() {
		return corpOrCommId;
	}

	public void setCorpOrCommId(String corpOrCommId) {
		this.corpOrCommId = corpOrCommId;
	}

	public String getCorpOrCommName() {
		return corpOrCommName;
	}

	public void setCorpOrCommName(String corpOrCommName) {
		this.corpOrCommName = corpOrCommName;
	}

	public String getLkBranchId() {
		return lkBranchId;
	}

	public void setLkBranchId(String lkBranchId) {
		this.lkBranchId = lkBranchId;
	}

	public String getBranchId() {
		return branchId;
	}

	public void setBranchId(String branchId) {
		this.branchId = branchId;
	}

	public String getIsCorpOrComm() {
		return isCorpOrComm;
	}

	public void setCorpCustomerId(String corpCustomerId) {
		this.corpCustomerId = corpCustomerId;
	}

	public String getIsSettings() {
		return isSettings;
	}

	public void setIsSettings(String isSettings) {
		this.isSettings = isSettings;
	}

	public String getCorpCustomerId() {
		return corpCustomerId;
	}

	public void setIsCorpOrComm(String isCorpOrComm) {
		this.isCorpOrComm = isCorpOrComm;
	}

	public String getCorpName() {
		return corpName;
	}

	public void setCorpName(String corpName) {
		this.corpName = corpName;
	}
	
	public String getRegionId() {
		return regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	public String getTownId() {
		return townId;
	}

	public void setTownId(String townId) {
		this.townId = townId;
	}

	public String getCommId() {
		return commId;
	}

	public void setCommId(String commId) {
		this.commId = commId;
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

	public String getLkBranchId2() {
		return lkBranchId2;
	}

	public void setLkBranchId2(String lkBranchId2) {
		this.lkBranchId2 = lkBranchId2;
	}

	public String getLkOrgId() {
		return lkOrgId;
	}

	public void setLkOrgId(String lkOrgId) {
		this.lkOrgId = lkOrgId;
	}

	public String getLkOrgId2() {
		return lkOrgId2;
	}

	public void setLkOrgId2(String lkOrgId2) {
		this.lkOrgId2 = lkOrgId2;
	}

	public String getIsBatchHf() {
		return isBatchHf;
	}

	public void setIsBatchHf(String isBatchHf) {
		this.isBatchHf = isBatchHf;
	}

	public File[] getFile() {
		return file;
	}

	public void setFile(File[] file) {
		this.file = file;
	}
}
