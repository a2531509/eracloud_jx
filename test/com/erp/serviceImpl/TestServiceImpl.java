package com.erp.serviceImpl;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.CardApply;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.service.AccAcountService;
import com.erp.service.DoWorkClientService;
import com.erp.service.TaskManagementService;
import com.erp.service.TestService;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;

@Service("testService")
public class TestServiceImpl extends BaseServiceImpl implements TestService {
	@Autowired
	private DoWorkClientService doWorkClientService;

	@Autowired
	private AccAcountService accAcountService;

	@Autowired
	private TaskManagementService taskManagementService;

	@Override
	public void saveHandleExcel() {
		try {
			// 读取文件
			Workbook workbook = new XSSFWorkbook(new FileInputStream("tmp001.xls"));
			Sheet sheet = workbook.getSheetAt(0);

			int lastRowNum = sheet.getLastRowNum();
			for (int i = 0; i <= lastRowNum; i++) { // 读取数据，从第 0 行开始（根据文件不同而不同）
				// 获取行
				Row row = sheet.getRow(i);
				// 获取单元格
				Cell certCell = row.getCell(2);
				// 读取单元格数据
				/*String certNo = certCell == null ? null : certCell.getStringCellValue().trim();
				if (certNo == null) {
					continue;
				}*/
				String taskId = certCell.getStringCellValue().trim();
				publicDao.doSql("update card_apply_task set task_state = '99' where task_id = '" + taskId + "'");
				publicDao.doSql("update card_apply set apply_state = '99' where task_id = '" + taskId + "'");


				// 处理数据
				/*BasePersonal bp = (BasePersonal) findOnlyRowByHql("from BasePersonal where certNo = '" + certNo + "'");
				// Object[] bpData = findOnlyRowBySql("select name, birthday
				// from base_personal where cert_no = '" + certNo + "'");
				if (bp != null) {
					row.createCell(5).setCellValue("存在");
				} else {
					row.createCell(5).setCellValue("不存在");
				}*/
			}
			// 写入文件
			//workbook.write(new FileOutputStream("test/test_result.xls"));
			workbook.close();
			System.out.println("完成");
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}

	@Override
	public String encryptBal(String cardNo, String amt) {
		try {
			return doWorkClientService.money2EncryptCal(cardNo, amt, "0", "0");
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Override
	public void saveStatCoOrgRchgStat(String coOrgId, String startDate, String endDate) {
		try {
			Date start = DateUtils.parse(startDate, "yyyy-MM-dd");
			Calendar startCal = Calendar.getInstance();
			startCal.setTime(start);
			Date end = DateUtils.parse(endDate, "yyyy-MM-dd");

			while (startCal.getTime().compareTo(end) <= 0) {
				try {
					List<Object> in = new ArrayList<Object>();
					String clrDate = DateUtil.formatDate(startCal.getTime(), "yyyy-MM-dd");
					in.add(clrDate);
					in.add(coOrgId);
					in.add("1");
					List<Integer> out = new ArrayList<Integer>();
					out.add(java.sql.Types.VARCHAR);
					out.add(java.sql.Types.VARCHAR);
					List rets = publicDao.callProc("p_stat_charge_consume_co_org2", in, out);
					System.out.println(clrDate + ":" + Arrays.toString(rets.toArray()));
				} catch (Exception e) {
					e.printStackTrace();
					continue;
				}
				startCal.add(Calendar.DAY_OF_YEAR, 1);
			}
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Override
	public void saveStatBrchRchgStat(String startDate, String endDate) {
		try {
			Date start = DateUtils.parse(startDate, "yyyy-MM-dd");
			Calendar startCal = Calendar.getInstance();
			startCal.setTime(start);
			Date end = DateUtils.parse(endDate, "yyyy-MM-dd");

			while (startCal.getTime().compareTo(end) <= 0) {
				try {
					List<Object> in = new ArrayList<Object>();
					String clrDate = DateUtil.formatDate(startCal.getTime(), "yyyy-MM-dd");
					in.add(clrDate);
					in.add(clrDate);
					in.add("");
					in.add("1");
					List<Integer> out = new ArrayList<Integer>();
					out.add(java.sql.Types.VARCHAR);
					out.add(java.sql.Types.VARCHAR);
					List rets = publicDao.callProc("pk_statistic.p_batch_stat_charge_consume", in, out);
					System.out.println(clrDate + ":" + Arrays.toString(rets.toArray()));
				} catch (Exception e) {
					e.printStackTrace();
					continue;
				}
				startCal.add(Calendar.DAY_OF_YEAR, 1);
			}
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveCardUpateCardCancel(String certNo) {
		try {
			SysActionLog log = getCurrentActionLog();
			log.setMessage("发卡数据同步社保（手工）");
			log.setDealCode(DealCode.ISSUSE_OLD_ZZ_NEW);
			publicDao.save(log);

			CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo t where cardState = '9' and exists(select 1 from BasePersonal where customerId = t.customerId and certNo = '" + certNo + "') order by last_modify_date desc");
			if (card == null) {
				throw new CommonException("申领信息不存在");

			}
			BasePersonal person = (BasePersonal) findOnlyRowByHql("from BasePersonal where customerId = '" + card.getCustomerId() + "'");
			if (person == null) {
				throw new CommonException("人员信息不存在");
			}
			saveSynch2CardUpate(null, certNo, card.getCardNo(), null, log.getDealNo(), null);
		} catch (CommonException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveCardUpateCardIssue(String applyId) {
		if(applyId != null){
			try {
				SysActionLog log = getCurrentActionLog();
				log.setMessage("发卡数据同步社保（手工）");
				publicDao.save(log);

				CardApply apply = (CardApply) findOnlyRowByHql("from CardApply where applyId = '" + applyId + "'");
				if (apply == null) {
					throw new CommonException("申领信息不存在");
				}
				log.setDealCode(DealCode.ISSUSE_TYPE_PERSONAL);
				BasePersonal person = (BasePersonal) findOnlyRowByHql("from BasePersonal where customerId = '" + apply.getCustomerId() + "'");
				if (person == null) {
					throw new CommonException("人员信息不存在");
				}
				saveSynch2CardUpate(apply.getTaskId(), person.getCertNo(), apply.getCardNo(), apply.getOldCardNo(), log.getDealNo(), apply.getApplyType());


			} catch (Exception e) {
				e.printStackTrace();
				//throw new CommonException(e);
			}
		}
	}

	@Override
	public void saveCardUpateCardBankCardActive(String certNo) {
		try {
			CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo t where cardState in ('1','2','3') and exists (select 1 from BasePersonal where customerId = t.customerId and certNo = '" + certNo + "')");
			if(card == null){
				throw new CommonException("卡信息不存在或状态不正常.");
			} else if(!card.getCardType().equals("120")){
				throw new CommonException("卡片不是金融市民卡.");
			}


			// 如果银行卡没有激活
			if(!"01".equals(card.getBankActiveState())){
				throw new CommonException(certNo + "银行卡没有激活.");
			}
			// 申领信息
			CardApply apply = (CardApply) findOnlyRowByHql("from CardApply where cardNo = '" + card.getCardNo() + "'");
			publicDao.doSql("insert into card_update (cardupdateseq, clientid, sub_cardid, sub_cardnumber, name, certtype, certnumber, sex, cardbiztype, old_subcardid, "
					+ "old_subcardnumber, personalid, switchnode, updatetime, actionno, card_type, version, org_code, issue_date, valid_date, nation, birthday, "
					+ "reside_addr, med_whole_no, pro_org_code, pro_media_type, pro_version, pro_init_date, clbz, clsj, stclsj, note, bank_id, bank_card_no, jhzt) "
					// 字段值
					+ "select seq_card_update_xh.nextval, b.customer_id, d.sub_card_id, d.sub_card_no, b.name, b.cert_type, b.cert_no, b.gender, '9', '" + apply.getOldSubCardId() + "', "
					+ "'" + apply.getOldSubCardNo() + "', s.personal_id, '04', sysdate, seq_action_no.nextval, d.card_type, d.version, d.init_org_id, d.issue_date, d.valid_date, "
					+ "b.nation, b.birthday, b.letter_addr, s.med_whole_no, null, null, null, null, '0', null, null, null, d.bank_id, d.bank_card_no, '1' "
					// from
					+ "from card_baseinfo d, base_personal b, base_siinfo s "
					+ "where d.customer_id = b.customer_id and b.cert_no = s.cert_no and b.customer_id = s.customer_id and "
					+ "d.card_no = '" + card.getCardNo() + "' and b.cert_no = '" + certNo + "' and s.reserve_7 <> '1'");
		} catch (CommonException e) {
			e.printStackTrace();
			//throw new CommonException(e);
		}
	}

	@Override
	public SysActionLog getCurrentActionLog() throws CommonException {
		SysActionLog log = new SysActionLog();
		log.setBrchId("10010001");
		log.setUserId("admin");
		log.setDealCode(99999999);
		log.setOrgId("1001");
		log.setDealTime(new Date());

		return log;
	}

	@Override
	public void saveOpenAcc(String cardNo) {
		try {
			CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where cardNo = '" + cardNo + "'");
			saveOpenAcc(card);
		} catch (Exception e) {
			throw new CommonException("开户失败," + e.getMessage());
		}
	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	private void saveOpenAcc(CardBaseinfo card) {
		HashMap hm = new HashMap();
		hm.put("obj_type", "1");
		hm.put("sub_type", card.getCardType());
		hm.put("obj_id", card.getCardNo());
		hm.put("pwd", doWorkClientService.money2EncryptCal(card.getCardNo(), "0", "0", "0"));

		accAcountService.createAccount(getCurrentActionLog(), hm);
	}


	public void deleteTask (String taskid,SysActionLog log){
		try {
			taskManagementService.deleteTask(taskid,log);

		} catch (Exception e) {
			throw new CommonException("删除失败," + e.getMessage());
		}

	}
}
