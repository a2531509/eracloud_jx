package com.erp.action;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Map;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.service.PgDataService;
import com.erp.service.Switchservice;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**
 * @author Yueh
 */
@Action("pgDataAction")
@Namespace("/pgData")
public class PgDataAction extends BaseAction{
	private static final long serialVersionUID = 1L;
	@Autowired
	private Switchservice switchservice;
	@Autowired
	PgDataService pgDataService;
	private String certNo;
	private String cardNo;
	private String state;
	private String cardStateBeforeChange = Constants.CARD_STATE_ZC;
	private String cardStateAfterChange;
	private String oldRegionId;
	private String newRegionId;
	private String subCardNo;
	private String regionId;
	private String subCardId = "";
	private String startDate;
	private String endDate;
	private File[] file;
	
	/**
	 * @return
	 */
	public String getAllPgData() {
		try {
			initBaseDataGrid();
			String sql = "select * from (select t.customer_id, t2.st_person_id, t.name, t.cert_no, t3.card_no, "
					+ "(select code_name from sys_code where code_type = 'CARD_STATE' and code_value = t3.card_state) card_state, "
					+ "decode(t2.clbz, null, 0, '1', 1, 0, decode(t2.card_clbz, '1', 2, '0', 3, 9), '8') state, t2.note,"
					+ "to_char(t2.clsj, 'yyyy-mm-dd hh24:mi:ss') clsj "
					+ "from base_personal t left join base_st t2 on t.customer_id = t2.customer_id "
					+ "left join card_baseinfo t3 on t2.customer_id = t3.customer_id and t3.card_state not in ('0', '9') and t3.card_type in ('100', '120') "
					+ "where 1 = 1 ";
			if(!Tools.processNull(certNo).equals("")){
				sql += "and t.cert_no = '" + certNo + "' ";
			}
			if(!Tools.processNull(cardNo).equals("")){
				sql += "and t3.card_no = '" + cardNo + "' ";
			}
			if(!Tools.processNull(startDate).equals("")){
				sql += "and t2.clsj >= to_date('" + startDate + "', 'yyyy-mm-dd') ";
			}
			if(!Tools.processNull(endDate).equals("")){
				sql += "and t2.clsj <= to_date('" + endDate + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			sql += ") where 1 = 1 ";
			if(!Tools.processNull(state).equals("")){
				sql += "and state = '" + state + "' ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			} else {
				sql += "order by customer_id";
			}
			//
			Page data = baseService.pagingQuery(sql, page, rows);
			if (data == null || data.getAllRs() == null || data.getAllRs().isEmpty()) {
				throw new CommonException("根据条件未找到对应数据！");
			}
			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String sendPerson() {
		try {
			switchservice.sendPersonData(certNo);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String sendCard() {
		try {
			switchservice.sendCardData(certNo);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String batchImportSendCard() {
		Workbook workbook = null;
		try {
			if (file == null || file.length == 0) {
				throw new CommonException("上传文件为空.");
			}
			certNo = "";
			workbook = new HSSFWorkbook(new FileInputStream(file[0]));
			Sheet sheet = workbook.getSheetAt(0);
			int lastRowNum = sheet.getLastRowNum();
			for (int i = 1; i <= lastRowNum; i++) {
				try {
					Row row = sheet.getRow(i);
					if (row == null) {
						continue;
					}
					//
					Cell cell = row.getCell(1);
					if (cell == null) {
						continue;
					}
					String certNo2 = cell.getStringCellValue();
					if (Tools.processNull(certNo2).equals("")) {
						throw new CommonException("证件号码为空！");
					}
					//
					certNo += certNo2 + "|";
				} catch (Exception e) {
					throw new CommonException(e.getMessage());
				}
			}
			batchSendCard();
		} catch (Exception e) {
			//
		} finally {
			if(workbook != null){
				try {
					workbook.close();
				} catch (IOException e) {
				}
			}
		}
		return JSONOBJ;
	}
	
	public String batchSendCard() {
		try {
			if (Tools.processNull(certNo).equals("")) {
				throw new CommonException("发送省厅数据为空！");
			}
			String[] certNoArr = certNo.split("\\|");
			if (certNoArr.length == 0) {
				throw new CommonException("发送省厅数据为空！");
			}
			int succNum = 0;
			JSONArray faliList = new JSONArray();
			for (String certNo : certNoArr) {
				try {
					pgDataService.reSendCard(certNo);
					succNum++;
				} catch (Exception e) {
					JSONObject item = new JSONObject();
					item.put("certNo", certNo);
					item.put("failMsg", e.getMessage());
					faliList.add(item);
				}
			}
			jsonObject.put("status", "0");
			jsonObject.put("count", certNoArr.length);
			jsonObject.put("succNum", succNum);
			jsonObject.put("msgList", faliList);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String getPgCardData() {
		try {
			String regionId = "";
			try {
				regionId = subCardId.substring(0, 6);
			} catch (Exception e) {
				//
			}
			// 查询方式：人 + 卡
			Map<String, String> cardData = switchservice.getCard(certNo, subCardNo, regionId, subCardId);
			jsonObject.put("card", JSONObject.toJSON(cardData));
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String updateCardState() {
		try {
			if(Tools.processNull(cardNo).equals("") && !Tools.processNull(subCardId).equals("")){
				cardNo = (String) switchservice.findOnlyFieldBySql("select card_no from card_baseinfo where sub_card_id like '%" + subCardId.substring(6) + "'");
			}
			switchservice.updateCardState(cardNo, cardStateBeforeChange, cardStateAfterChange);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String updateMedWholeNo() {
		try {
			switchservice.updateMedWholeNo(cardNo, oldRegionId, newRegionId);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String getCardDzData() {
		try {
			initBaseDataGrid();
			String sql = "select t.*, (select region_name from base_region where region_id = t.region_id) region_name "
					+ "from base_st_dz t where 1 = 1 ";
			if(!Tools.processNull(regionId).equals("")){
				sql += "and t.region_id = '" + regionId + "' ";
			}
			if(!Tools.processNull(startDate).equals("")){
				sql += "and t.dz_date >= '" + startDate + "' ";
			}
			if(!Tools.processNull(endDate).equals("")){
				sql += "and t.dz_date <= '" + endDate + "' ";
			}
			if(!Tools.processNull(state).equals("")){
				sql += "and t.dz_state = '" + state + "' ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			} else {
				sql += "order by dz_state desc, region_id";
			}
			//
			Page data = baseService.pagingQuery(sql, page, rows);
			if (data == null || data.getAllRs() == null || data.getAllRs().isEmpty()) {
				throw new CommonException("根据条件未找到对应数据！");
			}
			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String getCardDzDataDetail(){
		try {
			initBaseDataGrid();
			String sql = "select nvl(t.st_person_id, t2.st_person_id) st_person_id, nvl(t.name, t2.name) name, "
					+ "nvl(t.cert_no, t2.cert_no) cert_no, nvl(t.sub_card_no, t2.sub_card_no) sub_card_no, "
					+ "nvl(t.sub_card_id, t2.sub_card_id) sub_card_id, nvl(t.card_state, t2.card_state) card_state, "
					+ "nvl2(t.send_date, nvl2(t2.send_date, 0, 1), 2) state "
					+ "from base_st_upload t full join base_st_download t2 on t.region_id = t2.region_id and t.send_date = t2.send_date "
					+ "where (t.send_type = '1' or (t.send_type = '2' and t.card_state in ('2', '3'))) ";
			if(!Tools.processNull(regionId).equals("")){
				sql += "and (t.region_id = '" + regionId + "' or t2.region_id = '" + regionId + "') ";
			}
			if(!Tools.processNull(startDate).equals("")){
				sql += "and (t.send_date = '" + startDate + "' or t2.send_date = '" + startDate + "') ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			} else {
				sql += "order by t.name, t2.name";
			}
			//
			Page data = baseService.pagingQuery(sql, page, rows);
			if (data == null || data.getAllRs() == null || data.getAllRs().isEmpty()) {
				throw new CommonException("根据条件未找到对应数据！");
			}
			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String updatePerson() {
		try {
			switchservice.updatePerson(certNo);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public String getCardNo() {
		return cardNo;
	}

	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getCardStateBeforeChange() {
		return cardStateBeforeChange;
	}

	public void setCardStateBeforeChange(String cardStateBeforeChange) {
		this.cardStateBeforeChange = cardStateBeforeChange;
	}

	public String getCardStateAfterChange() {
		return cardStateAfterChange;
	}

	public void setCardStateAfterChange(String cardStateAfterChange) {
		this.cardStateAfterChange = cardStateAfterChange;
	}

	public String getOldRegionId() {
		return oldRegionId;
	}

	public void setOldRegionId(String oldRegionId) {
		this.oldRegionId = oldRegionId;
	}

	public String getNewRegionId() {
		return newRegionId;
	}

	public void setNewRegionId(String newRegionId) {
		this.newRegionId = newRegionId;
	}

	public String getSubCardNo() {
		return subCardNo;
	}

	public void setSubCardNo(String subCardNo) {
		this.subCardNo = subCardNo;
	}

	public String getRegionId() {
		return regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	public String getSubCardId() {
		return subCardId;
	}

	public void setSubCardId(String subCardId) {
		this.subCardId = subCardId;
	}

	public String getStartDate() {
		return startDate;
	}

	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}

	public String getEndDate() {
		return endDate;
	}

	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}

	public File[] getFile() {
		return file;
	}

	public void setFile(File[] file) {
		this.file = file;
	}
}
