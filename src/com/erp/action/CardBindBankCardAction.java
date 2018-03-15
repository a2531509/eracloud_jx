/**
 * 
 */
package com.erp.action;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.shiro.SecurityUtils;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseBank;
import com.erp.model.BaseCity;
import com.erp.model.BaseComm;
import com.erp.model.BasePersonal;
import com.erp.model.BaseRegion;
import com.erp.model.BaseTown;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardBindBankCard;
import com.erp.model.CardBindBankCardId;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.service.CardBindBankCardService;
import com.erp.service.CardServiceService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.ExcelUtil;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

import net.sf.jasperreports.engine.JasperRunManager;

/**
 * @author Yueh
 *
 */
@Namespace("/cardService")
@Action("cardBindBankCardAction")
@Result(name = "cardBindBankCardIndex", location = "/jsp/cardService/cardBindBankCardIndex.jsp")
public class CardBindBankCardAction extends BaseAction {
	private static final long serialVersionUID = 1L;

	private static final String STATUS = "status";
	private static final Object STATUS_FAIL = "1";
	private static final Object STATUS_SUCCESS = "0";
	private static final String ERR_MSG = "errMsg";
	private static final String FAIL_LIST = "failList";
	private static final String PAGE_TOTAL = "total";
	private static final String PAGE_ROWS = "rows";
	private static final String MESSAGE = "message";

	@Resource
	private CardBindBankCardService cardBindBankCardService;
	@Autowired
	public CardServiceService cardServiceService;
	
	private CardBindBankCard bindInfo = new CardBindBankCard();
	private BasePersonal person = new BasePersonal();
	private CardBaseinfo card = new CardBaseinfo();
	private BaseCity city = new BaseCity();
	private BaseRegion region = new BaseRegion();
	private BaseTown town = new BaseTown();
	private BaseComm comm = new BaseComm();
	private TrServRec rec = new TrServRec();
	
	private String reqJsonData;
	private File uploadFile;
	private String startDate;
	private String endDate;
	private String sort;
	private String order;
	private boolean isBankCardUnbindApp = false;
	
	public CardBindBankCardAction() {
		// 
		jsonObject.put(STATUS, STATUS_SUCCESS);
		jsonObject.put(PAGE_TOTAL, 0);
		jsonObject.put(PAGE_ROWS, new JSONArray());
	}
	
	/**
	 * 分页查询卡片绑定信息
	 * @return
	 */
	public String getCardBindBankCardInfos(){
		try {
			String sql = "SELECT P.NAME, P.CERT_TYPE, P.CERT_NO, C.CARD_NO, NVL(B.BANK_ID, PRE.BANK_ID) BANK_ID, "
					+ "(SELECT BANK_NAME FROM BASE_BANK WHERE BANK_ID = NVL(B.BANK_ID, PRE.BANK_ID)) BANK_NAME, "
					+ "TO_CHAR(NVL(B.BIND_DATE, PRE.DEAL_DATE), 'YYYY-MM-DD HH24:MI:SS') BIND_DATE, C.CARD_TYPE, "
					+ "NVL(B.BRCH_ID, PRE.BRCH_ID) BRCH_ID, NVL(B.USER_ID, PRE.USER_ID) USER_ID, C.CARD_STATE, "
					+ "(SELECT FULL_NAME FROM SYS_BRANCH WHERE BRCH_ID = NVL(B.BRCH_ID, PRE.BRCH_ID)) BRCH_NAME, "
					+ "B.BANK_CARD_NO, NVL(B.STATE, NVL2(PRE.CERT_NO, '0', '')) STATE, C.SUB_CARD_NO, P.MOBILE_NO "
					+ "FROM CARD_BASEINFO C JOIN BASE_PERSONAL P ON C.CUSTOMER_ID = P.CUSTOMER_ID "
					+ "LEFT JOIN CARD_BIND_BANKCARD B ON C.SUB_CARD_NO = B.SUB_CARD_NO "
					+ "LEFT JOIN CARD_BINDBANK_PRE PRE ON C.SUB_CARD_NO = PRE.SUB_CARD_NO "
					+ "WHERE (C.CARD_STATE = '" + Constants.CARD_STATE_ZC + "' or C.CARD_STATE = '" 
					+ Constants.CARD_STATE_GS + "' or C.CARD_STATE = '" + Constants.CARD_STATE_YGS + "') "
					//+ "AND (B.BANK_ID in (" + getCurrentBankId() + ") OR B.BANK_ID IS NULL) "// 如果(1不是当前网点对应银行绑定的,2其他银行已绑定的)过滤掉
					+ "AND C.card_type in ('" + Constants.CARD_TYPE_QGN + "', '" + Constants.CARD_TYPE_SMZK + "') ";// 旧卡
			
			if(!Tools.processNull(bindInfo.getName()).equals("")){
				sql += "and p.name like '%" + bindInfo.getName() + "%' ";
			}
			if(!Tools.processNull(bindInfo.getId().getCertNo()).equals("")){
				sql += "and p.cert_no = '" + bindInfo.getId().getCertNo() + "' ";
				Object tempcusid = baseService.findOnlyFieldBySql("select t.customer_id from base_personal t where t.cert_no = '" + bindInfo.getId().getCertNo() + "'");
				if(!Tools.processNull(tempcusid).equals("")){
					sql += "and p.customer_id = '" + tempcusid.toString() + "' ";
				}
			}
			if(!Tools.processNull(person.getCorpCustomerId()).equals("")){
				sql += "and p.corp_customer_id = '" + person.getCorpCustomerId() + "' ";
			}
			if(!Tools.processNull(bindInfo.getBankId()).equals("")){
				sql += "and b.bank_id = '" + bindInfo.getBankId() + "' ";
			}
			if(!Tools.processNull(bindInfo.getBrchId()).equals("")){
				sql += "and b.brch_id = '" + bindInfo.getBrchId() + "' ";
			}
			if (Tools.processNull(bindInfo.getState()).equals("")) { // 所有
				//
			} else if (bindInfo.getState().equals(Constants.CARD_BIND_BANKCARD_STATE_UNBIND)) { // 未绑定
				sql += "and b.state is null ";
			} else { // 已绑定
				sql += "and b.state = '" + bindInfo.getState() + "' ";
			}
			if(!Tools.processNull(card.getCardNo()).equals("")){
				sql += "and c.card_no = '" + card.getCardNo() + "' ";
			}
			if(!Tools.processNull(startDate).equals("")){
				sql += "and b.bind_date >= to_date('" + startDate + "', 'yyyy-mm-dd') ";
			}
			if(!Tools.processNull(endDate).equals("")){
				sql += "and b.bind_date <= to_date('" + endDate + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			
			if (!Tools.processNull(sort).equals("")) {
				sql += " order by " + sort;
				
				if(!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			}
			
			Page pageData = cardBindBankCardService.pagingQuery(sql, page, rows);
			
			if (pageData == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()) {
				throw new CommonException("没有数据.");
			}
			// 如果是别的银行绑定的, 隐藏银行卡号中间8位
			JSONArray row = pageData.getAllRs();
			String curBankIdStr = getCurrentBankId();
			List<String> curBankIds = Arrays.asList(curBankIdStr.substring(1, curBankIdStr.length() - 1).split("','"));
			if (curBankIds != null && !curBankIds.isEmpty()) {
				for (Object obj : row) {
					JSONObject r = (JSONObject) obj;
					if (r.getString("BANK_ID") != null && !curBankIds.contains(r.getString("BANK_ID"))) {
						String bankCardNo = r.getString("BANK_CARD_NO");
						if (!Tools.processNull(bankCardNo).equals("")) {
							r.put("BANK_CARD_NO", bankCardNo.substring(0, bankCardNo.length() - 4).replaceAll("\\d", "*") + bankCardNo.substring(bankCardNo.length() - 4));
						}
					}
				}
			}
			jsonObject.put(PAGE_TOTAL, pageData.getTotalCount());
			jsonObject.put(PAGE_ROWS, row);
			
			//
			if (isBankCardUnbindApp) {
				saveBankCardUnbindAppCer();
			}
		} catch (Exception e) {
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, e.getMessage());
		}
		
		return JSONOBJ;
	}

	private void saveBankCardUnbindAppCer() {
		 try {
			SysActionLog log = cardServiceService.getCurrentActionLog();
			log.setDealNo(Long.valueOf(cardServiceService.getSequenceByName("SEQ_ACTION_NO")));
			log.setDealTime(new Date());
			log.setDealCode(0);
			//
			JSONArray jsArr = jsonObject.getJSONArray(PAGE_ROWS);
			JSONObject data = jsArr.getJSONObject(0);
			String path = ServletActionContext.getRequest().getRealPath("/reportfiles/bankCardUnbindAppCer.jasper");
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("p_Title", "嘉兴社会保障市民卡解除银行绑定申请书");
			map.put("p_Accept_Time", DateUtil.formatDate(log.getDealTime()));
			map.put("p_sub_card_no", data.getString("SUB_CARD_NO"));
			map.put("p_name", data.getString("NAME"));
			map.put("p_cert_no", data.getString("CERT_NO"));
			map.put("p_bank_name", cardServiceService.findOnlyFieldBySql("select bank_name from base_bank where bank_id = '" + data.getString("BANK_ID") + "'"));
			map.put("p_bank_card_no", data.getString("BANK_CARD_NO"));
			map.put("p_Mobile_No", data.getString("MOBILE_NO"));
			byte[] pdfContent = JasperRunManager.runReportToPdf(path, map);
			cardServiceService.saveSysReport(log, new JSONObject(), "", Constants.APP_REPORT_TYPE_PDF2, 1l, "", pdfContent);
			jsonObject.put("dealNo", log.getDealNo());
		} catch (Exception e) {
			throw new CommonException("保存凭证失败!");
		}
	}

	/**
	 * 卡片绑定银行卡验证
	 */
	public String validCardBindBankCard() {
		try {
			if (!cardBindBankCardService.validCardBindBankCard(bindInfo)) {
				jsonObject.put(STATUS, STATUS_FAIL);
				jsonObject.put(ERR_MSG, "验证不通过.");
			}
		} catch (Exception e) {
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * 卡片绑定银行卡
	 */
	public String cardBindBankCard() {
		try {
			cardBindBankCardService.saveCardBindBankCard(bindInfo);
		} catch (Exception e) {
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * 卡片批量导入绑定银行卡
	 */
	public String batchCardBindBankCard() {
		try {
			if (uploadFile == null) {
				throw new CommonException("导入文件为空.");
			}
			
			ExcelUtil<CardBindBankCard> excelUtil = new ExcelUtil<CardBindBankCard>(CardBindBankCard.class);
			
			List<CardBindBankCard> bindInfos = excelUtil.importExcel("sheet0", new FileInputStream(uploadFile));

			if (bindInfos == null || bindInfos.isEmpty()) {
				throw new CommonException("导入数据为空.");
			}
			
			for(CardBindBankCard bindInfo:bindInfos){
				bindInfo.setId(new CardBindBankCardId(bindInfo.getCertNo(), bindInfo.getSubCardNo()));
			}
			
			List<CardBindBankCard> failList = cardBindBankCardService.saveCardBindBankCard(bindInfos);
			
			if (failList != null && !failList.isEmpty()) {
				jsonObject.put(FAIL_LIST, JSON.toJSON(failList));
				jsonObject.put(MESSAGE, "共导入" + bindInfos.size() + "条数据, 失败" + failList.size() + "条");
			}
		} catch (Exception e) {
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * 卡片绑定银行卡解绑
	 */
	public String cardUnBindBankCard() {
		try {
			cardBindBankCardService.saveCardUnBindBankCard(rec, bindInfo);
			jsonObject.put("dealNo", rec.getDealNo());
		} catch (Exception e) {
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String toCardBindBankCardIndex(){
		card = (CardBaseinfo)cardBindBankCardService.findOnlyRowByHql("from CardBaseinfo where cardNo = '" + card.getCardNo() + "'");
		
		if (card != null) {
			person = (BasePersonal) cardBindBankCardService.findOnlyRowByHql("from BasePersonal where customerId = '" + card.getCustomerId() + "'");
			try {
				Object[] data = (Object[]) cardBindBankCardService.findOnlyRowBySql("select "
						+ "(select city_name from base_city where city_id = t.city_id), "
						+ "(select region_name from base_region where region_id = t.region_id), "
						+ "(select town_name from base_town where town_id = t.town_id), "
						+ "(select comm_name from base_comm where comm_id = t.comm_id) "
						+ "from base_personal t where t.customer_id = '" + card.getCustomerId() + "'");
				
				if (data != null && data.length > 0) {
					city.setCityName(data[0] == null ? "" : data[0].toString());
					region.setRegionName(data[1] == null ? "" : data[1].toString());
					town.setTownName(data[2] == null ? "" : data[2].toString());
					comm.setCommName(data[3] == null ? "" : data[3].toString());
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		return "cardBindBankCardIndex";
	}
	
	public String exportBindInfo(){
		try {
			if(Tools.processNull(reqJsonData).equals("")){
				throw new CommonException("导出数据参数为空.");
			}
			
			List<CardBindBankCard> bindInfos = null;
			
			try {
				bindInfos = JSON.parseArray(reqJsonData, CardBindBankCard.class);
				
				if (bindInfos == null || bindInfos.isEmpty()) {
					throw new CommonException("导出数据为空.");
				}
			} catch (Exception e) {
				throw new CommonException("导出数据参数格式不正确");
			}
			
			// 预绑定
			cardBindBankCardService.savePreBind(bindInfos);
			
			// 导出
			String fileName = "卡片绑定银行卡信息";
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename="
					+ new String(fileName.getBytes(), "iso8859-1") + ".xls");
			
			//
			Workbook workbook = new HSSFWorkbook();

			Sheet sheet = workbook.createSheet();
			
			sheet.setColumnWidth(0, 2000);
			sheet.setColumnWidth(1, 5000);
			sheet.setColumnWidth(2, 3000);
			sheet.setColumnWidth(3, 5000);
			sheet.setColumnWidth(4, 8000);
			sheet.setColumnWidth(5, 4000);
			sheet.setColumnWidth(6, 4000);
			sheet.setColumnWidth(7, 5000);
			sheet.setColumnWidth(8, 4000);
			sheet.setColumnWidth(9, 4000);
			
			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);
			
			// cellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setFont(headCellFont);
			
			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);
			
			// head
			Row headRow = sheet.createRow(0);
			
			Cell head0 = headRow.createCell(0);
			Cell head1 = headRow.createCell(1);
			Cell head2 = headRow.createCell(2);
			Cell head3 = headRow.createCell(3);
			Cell head4 = headRow.createCell(4);
			Cell head5 = headRow.createCell(5);
			Cell head6 = headRow.createCell(6);
			Cell head7 = headRow.createCell(7);
			Cell head8 = headRow.createCell(8);
			Cell head9 = headRow.createCell(9);
			
			head0.setCellStyle(headCellStyle);
			head1.setCellStyle(headCellStyle);
			head2.setCellStyle(headCellStyle);
			head3.setCellStyle(headCellStyle);
			head4.setCellStyle(headCellStyle);
			head5.setCellStyle(headCellStyle);
			head6.setCellStyle(headCellStyle);
			head7.setCellStyle(headCellStyle);
			head8.setCellStyle(headCellStyle);
			head9.setCellStyle(headCellStyle);
			
			head0.setCellValue("姓名");
			head1.setCellValue("证件号码");
			head2.setCellValue("市民卡号");
			head3.setCellValue("银行编号");
			head4.setCellValue("银行卡号");
			head5.setCellValue("手机号码");
			head6.setCellValue("联行号");
			head7.setCellValue("联系地址");
			head8.setCellValue("绑定状态");
			head9.setCellValue("签名");

			for (int i = 0; i < bindInfos.size(); i++) {
				CardBindBankCard bindInfo = bindInfos.get(i);
				
				Row row = sheet.createRow(i + 1);

				Cell cell0 = row.createCell(0);
				Cell cell1 = row.createCell(1);
				Cell cell2 = row.createCell(2);
				Cell cell3 = row.createCell(3);
				Cell cell4 = row.createCell(4);
				Cell cell5 = row.createCell(5);
				Cell cell6 = row.createCell(6);
				Cell cell7 = row.createCell(7);
				Cell cell8 = row.createCell(8);
				Cell cell9 = row.createCell(9);
				
				cell0.setCellStyle(cellStyle);
				cell1.setCellStyle(cellStyle);
				cell2.setCellStyle(cellStyle);
				cell3.setCellStyle(cellStyle);
				cell4.setCellStyle(cellStyle);
				cell5.setCellStyle(cellStyle);
				cell6.setCellStyle(cellStyle);
				cell7.setCellStyle(cellStyle);
				cell8.setCellStyle(cellStyle);
				cell9.setCellStyle(cellStyle);

				cell0.setCellValue(bindInfo.getName());
				cell1.setCellValue(bindInfo.getId().getCertNo());
				cell2.setCellValue(bindInfo.getId().getSubCardNo());
				cell3.setCellValue(bindInfo.getBankId());
				cell4.setCellValue(bindInfo.getBankCardNo());
				cell5.setCellValue(bindInfo.getMobileNum());
				cell6.setCellValue(Tools.processNull(bindInfo.getLineNo()));
				cell7.setCellValue(bindInfo.getAddress());
				cell8.setCellValue(bindInfo.getStateText());
			}
			
			SecurityUtils.getSubject().getSession().setAttribute("exportBindInfoSucc",Constants.YES_NO_YES);
			
			OutputStream output = response.getOutputStream();
			
			workbook.write(output);
			workbook.close();
			
			output.flush();
			output.close();
		} catch (Exception e) {
			SecurityUtils.getSubject().getSession().setAttribute("exportBindInfoFail",Constants.YES_NO_YES);
			throw new CommonException("导出数据失败, " + e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * 获取当前网点银行编号
	 * @return
	 */
	@SuppressWarnings("unchecked")
	private String getCurrentBankId() {
		String bankIds = "";
		try {
			List<String> bankIdList = null;
			String brchId = getUsers().getBrchId();
			// 获取自有网点编号
			List<String> brchIds = cardBindBankCardService.findBySql("select brch_id from sys_branch start with brch_id = '10000000' connect by prior sysbranch_id =  pid");
			brchIds.add("99999999");
			if(brchIds.contains(brchId)){ // 自有网点
				bankIdList = cardBindBankCardService.findBySql("select bank_id from base_bank where bank_state = '" + Constants.STATE_ZC + "'");
			} else { // 非自有网点
				bankIdList = cardBindBankCardService.findBySql("select t.bank_id from base_bank t join branch_bank t2 on t.bank_id = t2.bank_id and t2.brch_id = '" 
						+ brchId + "' and t.bank_state = '" + Constants.STATE_ZC + "'");
			}
			
			if (bankIdList == null || bankIdList.isEmpty()) {
				throw new CommonException();
			}
			
			for (String bankId : bankIdList) {
				bankIds += ",'" + bankId + "'";
			}
			
			bankIds = bankIds.substring(1);
		} catch (Exception e) {
			e.printStackTrace();
			bankIds = "''";
		}
		return bankIds;
	}
	
	public String batchCardUnBindBankCard(){
		try {
			if (uploadFile == null) {
				throw new CommonException("导入文件为空.");
			}
			ExcelUtil<CardBindBankCard> excelUtil = new ExcelUtil<CardBindBankCard>(CardBindBankCard.class);
			List<CardBindBankCard> bindInfos = excelUtil.importExcel("sheet0", new FileInputStream(uploadFile));
			if (bindInfos == null || bindInfos.isEmpty()) {
				throw new CommonException("导入数据为空.");
			}
			for(CardBindBankCard bindInfo:bindInfos){
				bindInfo.setId(new CardBindBankCardId(bindInfo.getCertNo(), bindInfo.getSubCardNo()));
			}
			//
			List<CardBindBankCard> failList = new ArrayList<CardBindBankCard>();
			for (CardBindBankCard bindInfo : bindInfos) {
				try {
					cardBindBankCardService.saveCardUnBindBankCard(new TrServRec(), bindInfo);
				} catch (Exception e) {
					bindInfo.setFailReason(e.getMessage());
					failList.add(bindInfo);
				}
			}
			//
			if (failList != null && !failList.isEmpty()) {
				jsonObject.put(FAIL_LIST, JSON.toJSON(failList));
				jsonObject.put(MESSAGE, "共导入" + bindInfos.size() + "条数据, 失败" + failList.size() + "条");
			}
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * 获取当前网点银行
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public String getCurrentBrchBanks() {
		try {
			List<BaseBank> banks = cardBindBankCardService.findByHql("from BaseBank where bankId in(" + getCurrentBankId() + ")");
			banks.add(0, new BaseBank("", "请选择", null, null, null, null));
			jsonObject.put(PAGE_ROWS, JSON.toJSON(banks));
		} catch (Exception e) {
			jsonObject.put(STATUS, STATUS_FAIL);
			jsonObject.put(ERR_MSG, e.getMessage());
		}
		return JSONOBJ;
	}
	
	//TODO

	public CardBindBankCard getBindInfo() {
		return bindInfo;
	}

	public void setBindInfo(CardBindBankCard bindInfo) {
		this.bindInfo = bindInfo;
	}

	public String getReqJsonData() {
		return reqJsonData;
	}

	public void setReqJsonData(String reqJsonData) {
		this.reqJsonData = reqJsonData;
	}

	public File getUploadFile() {
		return uploadFile;
	}

	public void setUploadFile(File uploadFile) {
		this.uploadFile = uploadFile;
	}

	public BasePersonal getPerson() {
		return person;
	}

	public void setPerson(BasePersonal person) {
		this.person = person;
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

	public CardBaseinfo getCard() {
		return card;
	}

	public void setCard(CardBaseinfo card) {
		this.card = card;
	}

	public BaseCity getCity() {
		return city;
	}

	public void setCity(BaseCity city) {
		this.city = city;
	}

	public BaseRegion getRegion() {
		return region;
	}

	public void setRegion(BaseRegion region) {
		this.region = region;
	}

	public BaseTown getTown() {
		return town;
	}

	public void setTown(BaseTown town) {
		this.town = town;
	}

	public BaseComm getComm() {
		return comm;
	}

	public void setComm(BaseComm comm) {
		this.comm = comm;
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

	public TrServRec getRec() {
		return rec;
	}

	public void setRec(TrServRec rec) {
		this.rec = rec;
	}

	public boolean getIsBankCardUnbindApp() {
		return isBankCardUnbindApp;
	}

	public void setIsBankCardUnbindApp(boolean isBankCardUnbindApp) {
		this.isBankCardUnbindApp = isBankCardUnbindApp;
	}
}
