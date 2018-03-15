package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.BaseCorp;
import com.erp.model.PayCarTotal;
import com.erp.model.PayCarreform;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.SysOrgan;
import com.erp.model.TrServRec;
import com.erp.service.DoWorkClientService;
import com.erp.service.PayCarreFormService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;

/**
 * 车改充值Service
 * 
 * @author Yueh
 */
@Service("payCarreFormService")
public class PayCarreFormServiceImpl extends BaseServiceImpl implements PayCarreFormService {
	@Autowired
	private DoWorkClientService doWorkService;
	@SuppressWarnings("unchecked")
	@Override
	public void modifyPayCarreForm(PayCarreform oldPayCarreform, PayCarreform newPayCarreform) {
		try {
			// 1.验证参数,日志
			if (oldPayCarreform == null || oldPayCarreform.getId() == null
					|| oldPayCarreform.getId().getBatchNumber() == null
					|| oldPayCarreform.getId().getCertNo() == null) {
				throw new CommonException("充值数据为空.");
			}
			
			if (newPayCarreform == null || newPayCarreform.getId() == null) {
				throw new CommonException("充值数据为空.");
			} else if (newPayCarreform.getId().getCertNo() == null) {
				throw new CommonException("充值数据[身份证号]为空.");
			} else if (newPayCarreform.getCardNo() == null) {
				throw new CommonException("充值数据[卡号]为空.");
			} else if (newPayCarreform.getName() == null) {
				throw new CommonException("充值数据[姓名]为空.");
			}

			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.PAY_CARRE_FORM_MANAGER);

			// 2.验证充值信息
			PayCarreform payCarreform2 = (PayCarreform) publicDao.get(PayCarreform.class, oldPayCarreform.getId());
			if (payCarreform2 == null) {
				throw new CommonException("充值信息不存在.");
			} else if (Constants.PAY_CARREFOEM_STATE_RECHARGE.equals(payCarreform2.getState()) || Constants.PAY_CARREFOEM_STATE_REDO_RECHARGE.equals(payCarreform2.getState())) {
				throw new CommonException("充值信息不是[已充值]状态, 不能修改.");
			}

			// 3.更新
			publicDao.doSql("update pay_carreform set name = '"
					+ newPayCarreform.getName() + "', cert_no = '"
					+ newPayCarreform.getId().getCertNo() + "', card_no = '"
					+ newPayCarreform.getCardNo() + "' where batch_number = '"
					+ payCarreform2.getId().getBatchNumber()
					+ "' and cert_no = '" + payCarreform2.getId().getCertNo()
					+ "'");

			// 4.日志
			log.setMessage("修改车改充值信息[批次号:"
					+ payCarreform2.getId().getBatchNumber() + ", 年份:"
					+ payCarreform2.getProvideYear() + ", 月份:"
					+ payCarreform2.getProvideMonth() + "]");
			
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(getClrDate());
		} catch (CommonException e) {
			throw new CommonException("修改车改充值信息失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("修改车改充值信息失败, 系统异常[" + e.getMessage() + "]");
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveBatchIdentify(PayCarTotal payCarTotal, SysActionLog log) {
		try {
			// 1.验证参数,日志
			if (payCarTotal == null) {
				throw new CommonException("批量充值数据为空.");
			} else if (payCarTotal.getBatchNumber() == null) {
				throw new CommonException("批量充值数据[批次号]为空.");
			}
			log.setDealCode(DealCode.PAY_CARRE_FORM_CORP_RECHARGE);// 单位账户充值
			publicDao.save(log);

			// 2.验证批量充值信息
			PayCarTotal payCarTotal2 = (PayCarTotal) publicDao.get(PayCarTotal.class, payCarTotal.getBatchNumber());
			if (payCarTotal2 == null) {
				throw new CommonException("批量充值数据[" + payCarTotal.getBatchNumber() + "]不存在.");
			} else if (!Constants.PAY_CAR_TOTAL_STATE_UNCHECKED.equals(payCarTotal2.getState())) {
				throw new CommonException("批量充值数据[" + payCarTotal.getBatchNumber() + "]不是[待确认]状态, 不能审核确认.");
			}
			log.setMessage("车改批量审核单位充值[批次号:" + payCarTotal2.getBatchNumber() + ", 金额:" + payCarTotal2.getAmt().divide(BigDecimal.valueOf(100)) + "]");

			// 3.验证单位, 若单位不存在就新增单位并开户
			BaseCorp corp = getPayCarreformCorp(payCarTotal2, log);

			// 3.循环审核明细
			BigDecimal totalAmt = new BigDecimal(0);
			Long totalNum = 0l;
			List<PayCarreform> payCarreforms = publicDao.find("from PayCarreform where id.batchNumber = " + payCarTotal2.getBatchNumber());
			if (payCarreforms == null || payCarreforms.isEmpty()) {
				throw new CommonException("批量充值数据[" + payCarTotal2.getBatchNumber() + "][明细数据]不存在.");
			}

			for (PayCarreform payCarreform2 : payCarreforms) {//不验证人员信息，只检查金额是否对得上
				// identifyPayCarreform(payCarreform2); 
				payCarreform2.setCorpId(corp.getCustomerId());
				payCarreform2.setState(Constants.PAY_CARREFOEM_STATE_CHECKED);// 已审核

				totalAmt = totalAmt.add(payCarreform2.getProvideAmt());
				totalNum++;
			}

			// 4.验证金额, 人数
			if (!payCarTotal2.getNumber().equals(totalNum)) {
				throw new CommonException("批量充值数据[人数:" + payCarTotal2.getNumber() + "]与充值明细人数统计[人数:" + totalNum + "]不一致.");
			} else if (!payCarTotal2.getAmt().equals(totalAmt)) {
				throw new CommonException("批量充值数据[金额:" + payCarTotal2.getAmt().divide(BigDecimal.valueOf(100)) + "]与充值明细金额统计[金额:" + totalAmt.divide(BigDecimal.valueOf(100)) + "]不一致.");
			}

			// 5.单位账户充值
			corpAccRecharge(corp, payCarTotal2.getAmt(), log);
			
			// 6.更新状态
			payCarTotal2.setState(Constants.PAY_CAR_TOTAL_STATE_CHECKED);
			
			// 7.业务日志
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setAmt(payCarTotal2.getAmt().longValue());
			rec.setCustomerId(corp.getCustomerId());
			rec.setCustomerName(corp.getCorpName());
			rec.setClrDate(getClrDate());
			publicDao.save(rec);
		} catch (CommonException e) {
			throw new CommonException("审核批量车改充值信息失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("审核批量车改充值信息失败, 系统异常[" + e.getMessage() + "]");
		}
	}


	/**
	 * 账务处理
	 * 
	 * @param accountDb
	 *            借方账户
	 * @param accountCr
	 *            贷方账户
	 * @param amount
	 *            金额(单位:分)
	 * @param log
	 *            操作日志
	 * @param credit
	 *            信用发生额
	 * @param batchNo
	 *            交易批次号
	 * @param termNo
	 *            终端流水号
	 * @param state
	 *            交易流水状态: 0-正常 1-撤销 2-冲正3退货9-灰记录
	 * @return 记账流水
	 */
	@SuppressWarnings("unchecked")
	private String accouting(AccAccountSub accountDb, AccAccountSub accountCr, BigDecimal amount, SysActionLog log, String credit, String batchNo, String termNo, String state) {
		SysBranch currentBranch = (SysBranch) findOnlyRowByHql("from SysBranch where brchId = '" + log.getBrchId() + "'");
		if (currentBranch == null) {
			throw new CommonException("获取当前网点失败.");
		}

		String accountSeq = getSequenceByName("seq_acc_book_no");
		if (accountSeq == null || accountSeq.trim().equals("")) {
			throw new CommonException("获取记账流水失败.");
		}

		List<Object> inparams = new ArrayList<Object>();
		inparams.add(accountDb.getAccNo());// 借方
		inparams.add(accountCr.getAccNo());// 贷方
		inparams.add(accountDb.getBal());// 借方交易前卡面金额
		inparams.add(accountCr.getBal());// 贷方交易前卡面金额
		inparams.add("");// 借方交易计数器
		inparams.add("");// 贷方交易计数器
		inparams.add("");// 借方金额密文
		String balEncrypt = "";
		if (Constants.ACC_KIND_ZJZH.equals(accountCr.getAccKind()) && "1".equals(accountCr.getCustomerType())) { //如果是卡片资金帐户，则获取金额密文
			balEncrypt = doWorkService.money2EncryptCal(accountCr.getCardNo(), accountCr.getBal().toString(), amount.longValue() + "", Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD);
		}
		inparams.add(balEncrypt);// 贷方金额密文
		inparams.add(amount);// 交易金额，单位-分
		inparams.add(credit);// 信用发生额
		inparams.add(accountSeq);// 记账流水号
		inparams.add(log.getDealCode());// 交易代码
		inparams.add(accountCr.getOrgId());// 发卡机构
		inparams.add(currentBranch.getOrgId());// 受理机构
		inparams.add(currentBranch.getBrchType());// 受理点分类
		inparams.add(log.getBrchId());// 受理点编码(网点号/商户号)
		inparams.add(log.getUserId());// 操作柜员/终端号
		inparams.add(batchNo);// 交易批次号
		inparams.add(termNo);// 终端交易流水号
		inparams.add(DateUtil.formatDate(log.getDealTime()));// 交易时间
		inparams.add(state);// 交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
		inparams.add(log.getDealNo());// 业务流水号
		inparams.add(log.getMessage());// 备注
		inparams.add(getClrDate());// 清分日期
		inparams.add("");// 其它传入参数 退货时传入原acc_book_no
		inparams.add("");// 1调试

		List<Object> outTypes = new ArrayList<Object>();
		outTypes.add(Types.VARCHAR);
		outTypes.add(Types.VARCHAR);
		
		List<Object> rets = publicDao.callProc("pk_business.p_account2", inparams, outTypes);
		if (rets == null || rets.isEmpty()) {
			throw new CommonException("调用充值过程失败.");
		} else if (!rets.get(0).equals("00000000")) {
			throw new CommonException(rets.get(1).toString().equals("null") ? "" : rets.get(1).toString());
		}

		return accountSeq;
	}

	/**
	 * 单位不存在则新建单位并开户, 否则更新充值信息单位编号
	 * 
	 * @param payCarTotal
	 * @return
	 */
	@SuppressWarnings("unchecked")
	private BaseCorp getPayCarreformCorp(PayCarTotal payCarTotal, SysActionLog log) {
		try {
			if (payCarTotal.getEmpName() == null || payCarTotal.getEmpName().trim().equals("")) {
				throw new CommonException("充值信息[单位名称]为空.");
			}

			BaseCorp corp = (BaseCorp) findOnlyRowByHql("from BaseCorp where corpName = '" + payCarTotal.getEmpName().trim() + "'");
			// 单位不存在则新建单位并开户, 否则更新充值信息单位编号
			if (corp == null) {
				// 新建单位
				BaseCorp corp2 = new BaseCorp();
				corp2.setCorpName(payCarTotal.getEmpName());
				corp2.setCorpState(Constants.CORP_STATE_ZC);// 启用
				corp2.setChkFlag("1");// 已审核

				BigDecimal customerId = (BigDecimal) publicDao.findOnlyFieldBySql("select seq_client_id.nextval from dual");
				corp2.setCustomerId(customerId.toString());
				publicDao.save(corp2);

				// 开户
				corpOpenAcc(corp2, log);

				return corp2;
			} else {
				return corp;
			}
		} catch (Exception e) {
			throw new CommonException("验证单位信息失败, " + e.getMessage());
		}
	}

	@SuppressWarnings("unchecked")
	private void corpOpenAcc(BaseCorp corp, SysActionLog log) {
		try {
			if (corp == null) {
				throw new CommonException("单位不存在.");
			} else if (corp.getCorpState().equals(Constants.CORP_STATE_ZX)) {
				throw new CommonException("单位已注销.");
			} else if (!corp.getChkFlag().equals("1")) {
				throw new CommonException("单位" + getCodeNameBySYS_CODE("CHK_FLAG", corp.getChkFlag()));
			}

			// 2.验证单位账户信息
			AccAccountSub accountSub = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where customerId = '"
					+ corp.getCustomerId() + "' and accState != '" + Constants.ACC_STATE_ZX + "'");
			if (accountSub != null) {
				throw new CommonException("单位已经开户.");
			}

			List<Object> inParams = new ArrayList<Object>();
			String param = log.getDealNo()
					+ "|"// dealno
					+ log.getDealCode()
					+ "|"// dealcode
					+ log.getUserId()
					+ "|"// userid
					+ DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd hh:mm:ss") + "|"// dealtime
					+ "2|"// 类型-单位
					+ "|"// 卡类型-不用
					+ corp.getCustomerId() + "|"// client_id
					+ "|"// pwd
					+ "";// 卡账户金额密文
			inParams.add(param);

			List<Object> outTypes = new ArrayList<Object>();
			outTypes.add(Types.VARCHAR);
			outTypes.add(Types.VARCHAR);
			List<Object> rets = publicDao.callProc("pk_business.p_createaccount", inParams, outTypes);

			if (rets == null || rets.isEmpty()) {
				throw new CommonException("调用开户过程没有返回处理信息.");
			} else if (!rets.get(0).equals("00000000")) {
				throw new CommonException(rets.get(1).toString());
			}
		} catch (CommonException e) {
			throw new CommonException("单位开户失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("单位开户失败, 系统异常[" + e.getMessage() + "]");
		}
	}

	/**
	 * 单位账户充值
	 * 
	 * @param corp
	 * @param amount
	 */
	private void corpAccRecharge(BaseCorp corp, BigDecimal amount, SysActionLog log) {
		try {
			// 1.参数验证
			if (corp == null) {
				throw new CommonException("单位不存在.");
			} else if (!corp.getCorpState().equals(Constants.CORP_STATE_ZC)) {
				throw new CommonException("单位状态为" + getCodeNameBySYS_CODE("CORP_STATE", corp.getCorpState()) + ", 不能充值.");
			}

			// 当前机构
			SysOrgan currentOrg = (SysOrgan) findOnlyRowByHql("from SysOrgan where orgId = '" + getUser().getOrgId() + "'");
			if (currentOrg == null) {
				throw new CommonException("当前机构不存在.");
			}

			// 验证借贷账户
			AccAccountSub accountDb = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where "
					+ "customerId = '" + currentOrg.getCustomerId()
					+ "' and itemId = '" + Constants.ACC_ITEM_102100 + "' "
					+ " and accKind = '" + Constants.ACC_KIND_PTZH + "'");
			AccAccountSub accountCr = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where "
					+ "customerId = '" + corp.getCustomerId()
					+ "' and itemId='" + Constants.ACC_ITEM_101101
					+ "' and accKind = '" + Constants.ACC_KIND_PTZH + "'");
			
			if (accountDb == null) {
				throw new CommonException("借方账户[当前机构往来款账户]不存在.");
			} else if (!accountDb.getAccState().equals(Constants.ACC_STATE_ZC)) {
				throw new CommonException("借方账户[当前机构往来款账户]状态为[" + getCodeNameBySYS_CODE("ACC_STATE", accountDb.getAccState()) + "], 不能充值.");
			}
			if (accountCr == null) {
				throw new CommonException("贷方账户[单位现金账户]不存在.");
			} else if (!accountCr.getAccState().equals(Constants.ACC_STATE_ZC)) {
				throw new CommonException("贷方账户[单位现金账户]状态为[" + getCodeNameBySYS_CODE("ACC_STATE", accountCr.getAccState()) + "], 不能充值.");
			}
			// 调用充值过程
			accouting(accountDb, accountCr, amount, log, "0", "", "", "0");
		} catch (CommonException e) {
			throw new CommonException("单位充值失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("单位充值失败, 系统异常[" + e.getMessage() + "]");
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveInvalid(PayCarTotal payCarTotal) {
		try {
			// 1.验证参数,日志
			if (payCarTotal == null) {
				throw new CommonException("批量充值数据为空.");
			} else if (payCarTotal.getBatchNumber() == null) {
				throw new CommonException("批量充值数据[批次号]为空.");
			}

			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.PAY_CARRE_FORM_MANAGER);
			publicDao.save(log);

			// 2.验证批量充值信息
			PayCarTotal payCarTotal2 = (PayCarTotal) publicDao.get(PayCarTotal.class, payCarTotal.getBatchNumber());

			if (payCarTotal2 == null) {
				throw new CommonException("批量充值数据[" + payCarTotal.getBatchNumber() + "]不存在.");
			} else if (!Constants.PAY_CAR_TOTAL_STATE_UNCHECKED.equals(payCarTotal2.getState())) {
				throw new CommonException("批量充值数据[" + payCarTotal.getBatchNumber() + "]不是[待确认]状态, 不能审核确认.");
			}

			// 3.循环
			List<PayCarreform> payCarreforms = publicDao.find("from PayCarreform where id.batchNumber = " + payCarTotal2.getBatchNumber());
			if (payCarreforms == null || payCarreforms.isEmpty()) {
				throw new CommonException("批量充值数据[" + payCarTotal2.getBatchNumber() + "][明细数据]不存在.");
			}
			for (PayCarreform payCarreform2 : payCarreforms) {
				payCarreform2.setState(Constants.PAY_CARREFOEM_STATE_CHECK_FAILED);// 审核不通过
			}

			// 4.日志
			log.setMessage("审核不通过车改批量充值[批次号:" + payCarTotal2.getBatchNumber() + "]");

			// 7.更新状态
			payCarTotal2.setState(Constants.PAY_CAR_TOTAL_STATE_CHECK_FAILED);
		} catch (CommonException e) {
			throw new CommonException("审核批量车改充值信息失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("审核批量车改充值信息失败, 系统异常[" + e.getMessage() + "]");
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveRecharge(PayCarreform payCarreform, SysActionLog log) {
		try {
			PayCarreform payCarreform2 = (PayCarreform) findOnlyRowByHql("from PayCarreform where id.batchNumber = '" 
					+ payCarreform.getId().getBatchNumber() + "' and id.certNo = '" + payCarreform.getId().getCertNo() + "'");
			// 1.验证参数, 日志
			if (payCarreform2 == null) {
				throw new CommonException("充值数据不存在.");
			} else if (payCarreform2.getCorpId() == null) {
				throw new CommonException("充值数据[单位信息]为空.");
			} else if (payCarreform2.getCardNo() == null) {
				throw new CommonException("充值数据[人员卡号]为空.");
			} else if (payCarreform2.getProvideAmt() == null) {
				throw new CommonException("充值数据[充值金额]为空.");
			} else if (payCarreform2.getId().getBatchNumber() == null) {
				throw new CommonException("充值数据[批次号]为空.");
			} else if (!Constants.PAY_CARREFOEM_STATE_CHECKED.equals(payCarreform2.getState())
					&& !Constants.PAY_CARREFOEM_STATE_RECHARGE_FAILED.equals(payCarreform2.getState())) {
				throw new CommonException("充值数据状态不是[已确认, 充值失败], 不能充值.");
			}
			
			log.setDealCode(DealCode.CG_CORP_ACC_BATCH_RECHARGE);
			log.setMessage("车改批量充值【批次号：，姓名：" + payCarreform2.getName() + "，身份证号：" + payCarreform2.getId().getCertNo() 
					+ "，卡号：" + payCarreform2.getCardNo() + "，金额：" + payCarreform2.getProvideAmt().multiply(BigDecimal.valueOf(100)) + "】");
			publicDao.save(log);

			// 2.借贷账户验证
			AccAccountSub accountDb = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where customerId = '"
					+ payCarreform2.getCorpId() + "' and itemId = '" + Constants.ACC_ITEM_101101 + "' and accKind = '"
					+ Constants.ACC_KIND_PTZH + "' and accState = '" + Constants.ACC_STATE_ZC + "'");

			AccAccountSub accountCr = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where itemId='"
					+ Constants.ACC_ITEM_201101 + "' and accKind = '" + Constants.ACC_KIND_ZJZH + "' and cardNo = '"
					+ payCarreform2.getCardNo() + "' and accState = '" + Constants.ACC_STATE_ZC + "'");

			if (accountDb == null) {
				throw new CommonException("借方账户[单位现金账户]不存在.");
			} else if (!accountDb.getAccState().equals("1")) {
				throw new CommonException("借方账户[单位现金账户]状态为[" + getCodeNameBySYS_CODE("ACC_STATE", accountDb.getAccState()) + "], 不能充值.");
			} else if (accountDb.getBal().compareTo(payCarreform2.getProvideAmt().longValue()) < 0) {
				throw new CommonException("借方账户[单位现金账户]余额不足.");
			}

			if (accountCr == null) {
				throw new CommonException("贷方账户[人员联机账户]不存在.");
			} else if (!accountCr.getAccState().equals("1")) {
				throw new CommonException("贷方账户[人员联机账户]状态为[" + getCodeNameBySYS_CODE("ACC_STATE", accountCr.getAccState()) + "], 不能充值.");
			}

			// 3.充值
			String accountSeq = accouting(accountDb, accountCr, payCarreform2.getProvideAmt(), log, "0", payCarreform2.getId().getBatchNumber().toString(), "", "0");

			// 充值成功
			if (Constants.PAY_CARREFOEM_STATE_RECHARGE_FAILED.equals(payCarreform2.getState())) {// 补充值
				payCarreform2.setState(Constants.PAY_CARREFOEM_STATE_REDO_RECHARGE);
			} else {// 新充值
				payCarreform2.setState(Constants.PAY_CARREFOEM_STATE_RECHARGE);
			}
			payCarreform2.setRechgActionNo(new BigDecimal(accountSeq));
			payCarreform2.setRechgDate(log.getDealTime());

			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(getClrDate());
			rec.setCardNo(payCarreform2.getCardNo());
			rec.setAmt(payCarreform2.getProvideAmt().longValue());
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException("车改批量充值失败, " + e.getMessage());
		}
	}



	@SuppressWarnings("unchecked")
	@Override
	public void updatePayCarreform(PayCarreform payCarreform) {
		publicDao.update(payCarreform);
	}



	@Override
	public void updatePayCarTotal(PayCarTotal payCarTotal) {
		try {
			PayCarTotal payCarTotal2 = (PayCarTotal) findOnlyRowByHql("from PayCarTotal where batchNumber = '" + payCarTotal.getBatchNumber() + "'");
			
			Object[] yff = (Object[]) findOnlyRowBySql("select sum(decode(state, '" + Constants.PAY_CARREFOEM_STATE_RECHARGE 
					+ "', 1, '" + Constants.PAY_CARREFOEM_STATE_REDO_RECHARGE + "', 1, 0)), sum(decode(state, '" 
					+ Constants.PAY_CARREFOEM_STATE_RECHARGE + "', provide_amt, '" + Constants.PAY_CARREFOEM_STATE_REDO_RECHARGE 
					+ "', provide_amt, 0)), sum(decode(state, '" + Constants.PAY_CARREFOEM_STATE_RECHARGE_FAILED 
					+ "', 1, 0)) from pay_carreform where BATCH_NUMBER = '" + payCarTotal2.getBatchNumber() + "'");
			if (yff == null || yff.length == 0) {
				throw new CommonException("统计已发放信息失败.");
			}
			BigDecimal rechargeNum = (BigDecimal) yff[0];
			BigDecimal rechargeAmt = (BigDecimal) yff[1];
			BigDecimal failNum = (BigDecimal) yff[2];
			
			if(rechargeNum.longValue() == payCarTotal2.getNumber()){
				payCarTotal2.setState(Constants.PAY_CAR_TOTAL_STATE_RECHARGE);
			} else if(rechargeNum.longValue() == 0){
				payCarTotal2.setState(Constants.PAY_CAR_TOTAL_STATE_RECHARGE_FAILED);
			} else {
				payCarTotal2.setState(Constants.PAY_CAR_TOTAL_STATE_PART_RECHARGE);
			}
			payCarTotal2.setRechargeNum(rechargeNum.longValue());
			payCarTotal2.setRechargeAmt(rechargeAmt);
			payCarTotal2.setFailNum(failNum.longValue());
		} catch (Exception e) {
			throw new CommonException("更新车改批次状态失败, 请联系系统人员");
		}
	}
}
