package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.beanutils.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.BaseCorp;
import com.erp.model.BaseCorpRechargeInfo;
import com.erp.model.BaseCorpRechargeList;
import com.erp.model.BaseCorpRechargeListPK;
import com.erp.model.BasePersonal;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.SysOrgan;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.CorpManagerService;
import com.erp.service.DoWorkClientService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.ReceiptContants;
import com.erp.util.Tools;

@Service("corpManagerService")
public class CorpManagerServiceImpl extends BaseServiceImpl implements CorpManagerService {
	@Autowired
	private DoWorkClientService doWorkService;
	@SuppressWarnings("unchecked")
	@Override
	public void saveCorpRegist(BaseCorp corp) {
		try {
			if (corp == null) {
				throw new CommonException("单位登记信息为空.");
			}
			validate(corp);
			build(corp);
			publicDao.save(corp);
			
			// 日志
			SysActionLog log = getCurrentActionLog();
			log.setMessage("单位入网登记" + corp.getCustomerId());
			log.setDealCode(DealCode.CORP_REGISTER);
			publicDao.save(log);
			
			//业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setNote(log.getMessage());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			trServRec.setCustomerId(corp.getCustomerId());
			trServRec.setCustomerName(corp.getCorpName());
			publicDao.save(trServRec);
		} catch (CommonException e) {
			throw new CommonException("单位登记保存失败, " + e.getMessage());
		}
	}

	private void build(BaseCorp corp) {
		if (Tools.processNull(corp.getAbbrName()).equals("")) {
			corp.setAbbrName(corp.getCorpName());
		}
		if (Tools.processNull(corp.getCarrefFlag()).equals("")) {
			corp.setCarrefFlag("1");// 是否车改-否
		}
		if (Tools.processNull(corp.getCorpState()).equals("")) {
			corp.setCorpState("0");// 状态-正常
		}
		if (Tools.processNull(corp.getChkFlag()).equals("")) {
			corp.setChkFlag("0");// 审核状态-未审核
		}
		if (Tools.processNull(corp.getChkFlag()).equals("")) {
			corp.setChkFlag("");
		}
		if (Tools.processNull(corp.getChkUserId()).equals("")) {
			corp.setChkUserId("");
		}
		if (Tools.processNull(corp.getServPwd()).equals("")) {
			corp.setServPwd("");
		}
		if (Tools.processNull(corp.getNetPwd()).equals("")) {
			corp.setNetPwd("");
		}
		if (Tools.processNull(corp.getCeoPhone()).equals("")) {
			corp.setCeoPhone("");
		}
		if (Tools.processNull(corp.getClsUserId()).equals("")) {
			corp.setClsUserId("");
		}
		if (Tools.processNull(corp.getServPwdErrNum()).equals("")) {
			corp.setServPwdErrNum(new BigDecimal(0));
		}
		if (Tools.processNull(corp.getNetPwdErrNum()).equals("")) {
			corp.setNetPwdErrNum(new BigDecimal(0));
		}
		if (Tools.processNull(corp.getCustomerId()).equals("")) {
			BigDecimal customerId = (BigDecimal) publicDao.findOnlyFieldBySql("select seq_client_id.nextval from dual");
			corp.setCustomerId(customerId.toString());
		}
	}

	private void validate(BaseCorp corp) {
		if (Tools.processNull(corp.getCorpName()).equals("")) {
			throw new CommonException("单位名称为空.");
		}
		if (Tools.processNull(corp.getContact()).equals("")) {
			throw new CommonException("联系人为空.");
		}
		if (Tools.processNull(corp.getConPhone()).equals("")) {
			throw new CommonException("联系人电话为空.");
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveCorpModify(BaseCorp corp) {
		try {
			if (corp == null || corp.getCustomerId() == null || corp.getCustomerId().equals("")) {
				throw new CommonException("单位信息为空.");
			}
			validate(corp);
			BaseCorp corp2 = (BaseCorp) findOnlyRowByHql("from BaseCorp where customerId='" + corp.getCustomerId() + "'");
			if (corp2 == null) {
				throw new CommonException("单位信息不存在.");
			}
			saveCorp(corp, corp2);
			
			// 日志
			SysActionLog log = getCurrentActionLog();
			log.setMessage("单位信息修改" + corp.getCustomerId());
			log.setDealCode(DealCode.CORP_REGISTER);
			publicDao.save(log);
			
			//业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setNote(log.getMessage());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			trServRec.setCustomerId(corp.getCustomerId());
			trServRec.setCustomerName(corp.getCorpName());
			publicDao.save(trServRec);
		} catch (CommonException e) {
			throw new CommonException("单位登记保存失败, " + e.getMessage());
		}
	}

	private void saveCorp(BaseCorp newCorp, BaseCorp corp) {
		if (!Tools.processNull(newCorp.getCorpName()).equals("")) {
			corp.setCorpName(newCorp.getCorpName());
		}
		if (!Tools.processNull(newCorp.getAbbrName()).equals("")) {
			corp.setAbbrName(newCorp.getAbbrName());
		}
		if (!Tools.processNull(newCorp.getCorpType()).equals("")) {
			corp.setCorpType(newCorp.getCorpType());
		}
		if (!Tools.processNull(newCorp.getLicenseNo()).equals("")) {
			corp.setLicenseNo(newCorp.getLicenseNo());
		}
		if (!Tools.processNull(newCorp.getPCustomerId()).equals("")) {
			corp.setPCustomerId(newCorp.getPCustomerId());
		}
		if (!Tools.processNull(newCorp.getAddress()).equals("")) {
			corp.setAddress(newCorp.getAddress());
		}
		if (!Tools.processNull(newCorp.getPostCode()).equals("")) {
			corp.setPostCode(newCorp.getPostCode());
		}
		if (!Tools.processNull(newCorp.getFaxNo()).equals("")) {
			corp.setFaxNo(newCorp.getFaxNo());
		}
		if (!Tools.processNull(newCorp.getEmail()).equals("")) {
			corp.setEmail(newCorp.getEmail());
		}
		if (!Tools.processNull(newCorp.getMngUserId()).equals("")) {
			corp.setMngUserId(newCorp.getMngUserId());
		}
		if (!Tools.processNull(newCorp.getContact()).equals("")) {
			corp.setContact(newCorp.getContact());
		}
		if (!Tools.processNull(newCorp.getConCertNo()).equals("")) {
			corp.setConCertNo(newCorp.getConCertNo());
		}
		if (!Tools.processNull(newCorp.getConPhone()).equals("")) {
			corp.setConPhone(newCorp.getConPhone());
		}
		if (!Tools.processNull(newCorp.getCeoName()).equals("")) {
			corp.setCeoName(newCorp.getCeoName());
		}
		if (!Tools.processNull(newCorp.getCeoPhone()).equals("")) {
			corp.setCeoPhone(newCorp.getCeoPhone());
		}
		if (!Tools.processNull(newCorp.getLegName()).equals("")) {
			corp.setLegName(newCorp.getLegName());
		}
		if (!Tools.processNull(newCorp.getLegPhone()).equals("")) {
			corp.setLegPhone(newCorp.getLegPhone());
		}
		if (!Tools.processNull(newCorp.getCertType()).equals("")) {
			corp.setCertType(newCorp.getCertType());
		}
		if (!Tools.processNull(newCorp.getCertNo()).equals("")) {
			corp.setCertNo(newCorp.getCertNo());
		}
		if (!Tools.processNull(newCorp.getRegionId()).equals("")) {
			corp.setRegionId(newCorp.getRegionId());
		}
		if (!Tools.processNull(newCorp.getCompanyid()).equals("")) {
			corp.setCompanyid(newCorp.getCompanyid());
		}
		if (!Tools.processNull(newCorp.getCarrefFlag()).equals("")) {
			corp.setCarrefFlag(newCorp.getCarrefFlag());
		}
		if (!Tools.processNull(newCorp.getNote()).equals("")) {
			corp.setNote(newCorp.getNote());
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveRegistCheck(String customerId, Boolean checkSuccess, Users user) {
		try {
			BaseCorp corp = (BaseCorp) findOnlyRowByHql("from BaseCorp where customerId='" + customerId + "'");
			if (corp == null) {
				throw new CommonException("单位信息不存在.");
			}
			if (checkSuccess) {
				if ("1".equals(corp.getChkFlag())) {
					throw new CommonException("单位已审核通过.");
				}
				corp.setChkFlag("1");
			} else {
				if ("2".equals(corp.getChkFlag())) {
					throw new CommonException("单位已经审核未通过.");
				}
				corp.setChkFlag("2");
			}
			corp.setChkDate(new Date());
			corp.setChkUserId(user.getUserId());

			publicDao.update(corp);
			
			// 日志
			SysActionLog log = getCurrentActionLog();
			log.setMessage("单位信息审核" + (checkSuccess ? "通过" : "不通过") + corp.getCustomerId());
			log.setDealCode(DealCode.CORP_CHECK);
			publicDao.save(log);
			
			//业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setNote(log.getMessage());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			trServRec.setCustomerId(corp.getCustomerId());
			trServRec.setCustomerName(corp.getCorpName());
			publicDao.save(trServRec);
		} catch (CommonException e) {
			throw new CommonException("单位审核失败, " + e.getMessage());
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveCorpEnable(String customerId, Boolean enbaled, Users user) {
		try {
			BaseCorp corp = (BaseCorp) findOnlyRowByHql("from BaseCorp where customerId='" + customerId + "'");
			if (corp == null) {
				throw new CommonException("单位信息不存在.");
			}

			if (enbaled) {
				if ("0".equals(corp.getCorpState())) {
					throw new CommonException("单位已经启用.");
				}
				corp.setClsDate(null);
				corp.setClsUserId("");
				corp.setCorpState("0");
			} else {
				if ("1".equals(corp.getCorpState())) {
					throw new CommonException("单位已经注销.");
				}
				corp.setCorpState("1");
				corp.setClsDate(new Date());
				corp.setClsUserId(user.getUserId());
			}

			publicDao.update(corp);
			
			// 日志
			SysActionLog log = getCurrentActionLog();
			log.setMessage("单位信息" + (enbaled ? "启用" : "注销") + corp.getCustomerId());
			log.setDealCode(DealCode.CORP_ENABLED);
			publicDao.save(log);
			
			//业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setNote(log.getMessage());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			trServRec.setCustomerId(corp.getCustomerId());
			trServRec.setCustomerName(corp.getCorpName());
			publicDao.save(trServRec);
		} catch (CommonException e) {
			throw new CommonException("单位" + (enbaled ? "启用" : "注销") + "失败, " + e.getMessage());
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void createCorpAcc(String customerId) {
		try {
			SysActionLog log = getCurrentActionLog();
			log.setMessage("单位开户");
			log.setDealCode(DealCode.CORP_OPEN_ACC);
			publicDao.save(log);

			// 1.验证单位信息
			BaseCorp corp = (BaseCorp) findOnlyRowByHql("from BaseCorp where customerId = '" + customerId + "'");
			if (corp == null) {
				throw new CommonException("单位不存在.");
			} else if (Constants.STATE_ZX.equals(corp.getCorpState())) {
				throw new CommonException("单位已注销.");
			} else if (!"1".equals(corp.getChkFlag())) {
				throw new CommonException("单位未审核.");
			}

			// 2.验证单位账户信息
			AccAccountSub accountSub = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where customerId = '" + customerId + "' and accState != '9'");
			if (accountSub != null) {
				throw new CommonException("单位已经开户.");
			}

			List<Object> inParams = new ArrayList<Object>();
			String param = log.getDealNo() + "|"// dealno
					+ log.getDealCode() + "|"// dealcode
					+ log.getUserId() + "|"// userid
					+ log.getDealTime() + "|"// dealtime
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
			}
			if (!rets.get(0).equals("00000000")) {
				throw new CommonException(rets.get(1).toString());
			}
			
			//业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setNote(log.getMessage());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			trServRec.setCustomerId(corp.getCustomerId());
			trServRec.setCustomerName(corp.getCorpName());
			publicDao.save(trServRec);
		} catch (CommonException e) {
			throw new CommonException("单位开户失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("单位开户失败.");
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public TrServRec saveCashAccRecharge(String customerId, BigDecimal amount) {
		try {
			if (amount.compareTo(BigDecimal.valueOf(0)) <= 0) {
				throw new CommonException("充值金额必须大于0.");
			}

			BaseCorp corp = (BaseCorp) this.findOnlyRowByHql("from BaseCorp where customerId = '" + customerId + "'");
			if (corp == null) {
				throw new CommonException("单位不存在.");
			} else if (!corp.getCorpState().equals("0")) {
				throw new CommonException("单位状态为" + getCodeNameBySYS_CODE("CORP_STATE", corp.getCorpState()) + ", 不能充值.");
			}

			// 日志
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.CORP_RECHARGE);
			log.setMessage("单位账户充值, 金额:" + amount + "元");
			publicDao.save(log);

			// 当前机构网点
			SysOrgan currentOrg = (SysOrgan) findOnlyRowByHql("from SysOrgan where orgId = '" + getUser().getOrgId() + "'");
			if (currentOrg == null) {
				throw new CommonException("当前机构不存在.");
			}

			// 验证借贷账户
			AccAccountSub accountDb = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where customerId = '"
					+ currentOrg.getCustomerId() + "' and itemId = '" + Constants.ACC_ITEM_102100 + "' " 
					+ " and accKind = '" + Constants.ACC_KIND_PTZH + "' and accState = '1'");
			AccAccountSub accountCr = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where customerId = '"
					+ customerId + "' and itemId='" + Constants.ACC_ITEM_101101 + "' and accKind = '" 
					+ Constants.ACC_KIND_PTZH + "' and accState = '1'");
			if (accountDb == null) {
				throw new CommonException("借方账户[当前机构往来款账户]不存在.");
			} else if (!accountDb.getAccState().equals("1")) {
				throw new CommonException("借方账户[当前机构往来款账户]状态为[" + getCodeNameBySYS_CODE("ACC_STATE", accountDb.getAccState()) + "], 不能充值.");
			}

			if (accountCr == null) {
				throw new CommonException("贷方账户[单位现金账户]不存在.");
			} else if (!accountCr.getAccState().equals("1")) {
				throw new CommonException("贷方账户[单位现金账户]状态为[" + getCodeNameBySYS_CODE("ACC_STATE", accountCr.getAccState()) + "], 不能充值.");
			}

			// 调用充值过程
			accouting(accountDb, accountCr, amount, log, "0", "", "", "0", "单位账户充值");
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setAccNo(accountCr.getAccNo() + "");
			trServRec.setNote(log.getMessage());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setAmt(amount.multiply(BigDecimal.valueOf(100)).longValue());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			trServRec.setCustomerId(corp.getCustomerId());
			trServRec.setCustomerName(corp.getCorpName());
			publicDao.save(trServRec);
			
			// 保存业务凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportstomoney(amount.toString())); // 交易金额
			json.put(ReceiptContants.FIELD.COMPANY_ID, trServRec.getCustomerId()); // 单位编号
			json.put(ReceiptContants.FIELD.COMPANY_NAME, trServRec.getCustomerName()); // 单位名称
			json.put(ReceiptContants.FIELD.ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv((accountCr.getBal() + amount.multiply(BigDecimal.valueOf(100)).longValue()) + "")); // 账户余额
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工编号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员工姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			saveSysReport(log, json, ReceiptContants.TYPE.COMPANY_RECHARGE, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			return trServRec;
		} catch (Exception e) {
			throw new CommonException("单位充值失败, " + e.getMessage());
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public List<BaseCorpRechargeList> saveImportBatchRechargeInfo(List<BaseCorpRechargeList> batchRechargeInfo, String corpId, Boolean jugeCorp) {
		try {
			List<BaseCorpRechargeList> failList = new ArrayList<BaseCorpRechargeList>();

			// 参数验证
			if (batchRechargeInfo == null || batchRechargeInfo.isEmpty()) {
				throw new CommonException("导入充值记录为空.");
			} else if (corpId == null || corpId.trim().equals("")) {
				throw new CommonException("批量充值单位为空.");
			}

			// 日志记录
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.CORP_BATCH_RECHARGE_IMPORT);
			log.setMessage("单位批量充值数据导入.");
			publicDao.save(log);

			// 1.获取状态正常单位信息(失败会抛出异常)
			BaseCorp corp = getValidateCorp(corpId);

			// 2.保存批量导入信息-BaseCorpRechargeInfo
			BaseCorpRechargeInfo info = new BaseCorpRechargeInfo();
			info.setCustomerId(corp.getCustomerId());
			info.setRechargeType("00");// 普通充值
			info.setImpUserId(log.getUserId());
			info.setImpDealDate(log.getDealTime());
			info.setState("0");// 待审核
			info.setNote("批量充值导入[" + DateUtil.formatDate(log.getDealTime()) + ", " + log.getUserId() + "]");
			publicDao.save(info);

			// 3.循环处理每条记录
			BigDecimal amt = new BigDecimal(0);// -总金额
			Long num = 0l;// -人数
			for (BaseCorpRechargeList item : batchRechargeInfo) {
				item.setCertNo(item.getCertNo().trim().toUpperCase());
				// 1.验证员工信息
				List<BasePersonal> persons = findByHql("from BasePersonal where certNo = '" + item.getCertNo() + "'");

				if (persons == null || persons.isEmpty()) {
					item.setNote("人员信息不存在");
					failList.add(item);
					continue;
				} 
				BasePersonal person = persons.get(0);
				if(persons.size() >1){
					item.setNote("同一身份证号码有多个人");
					failList.add(item);
					continue;
				} else if (!"0".equals(person.getCustomerState())) {
					item.setNote("人员状态为【" + getCodeNameBySYS_CODE("CUSTOMER_STATE", person.getCustomerState()) + "】, 不能进行充值.");
					failList.add(item);
					continue;
				} else if(jugeCorp && !Tools.processNull(person.getCorpCustomerId()).equals(corpId)){
					item.setNote("人员信息不属于该单位");
					failList.add(item);
					continue;
				}
				item.setPk(new BaseCorpRechargeListPK(info.getId(), person.getCustomerId().toString()));

				// 2.验证卡
				List<CardBaseinfo> cards = findByHql("from CardBaseinfo where customerId = '" + item.getPk().getCustomerId() 
						+ "' and cardType in ('" + Constants.CARD_TYPE_QGN + "', '" + Constants.CARD_TYPE_SMZK + "') and cardState = '" + Constants.CARD_STATE_ZC + "'");
				if (cards == null || cards.isEmpty()) {
					item.setNote("客户不存在正常的卡片！");
					failList.add(item);
					continue;
				} else if (cards.size() > 1) {
					item.setNote("客户存在多张正常的卡片！");
					failList.add(item);
					continue;
				}
				CardBaseinfo card = cards.get(0);

				// 3.验证联机账户信息
				AccAccountSub account = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where customerId = '"
						+ item.getPk().getCustomerId() + "' and accKind = '" + Constants.ACC_KIND_ZJZH + "' and cardNo = '"
						+ card.getCardNo() + "' and accState = '" + Constants.ACC_STATE_ZC + "'");

				if (account == null) {
					item.setNote("联机账户不存在.");
					failList.add(item);
					continue;
				} else if (!account.getAccState().equals(Constants.ACC_STATE_ZC)) {
					item.setNote("人员联机账户状态为[" + getCodeNameBySYS_CODE("ACC_STATE", account.getAccState()) + "], 不能进行充值.");
					failList.add(item);
					continue;
				}

				// 4.保存充值数据
				item.setCardNo(account.getCardNo());
				item.setAccKind(account.getAccKind());
				item.setState("0");// 待审核
				item.setImpUserId(info.getImpUserId());
				item.setImpDealDate(info.getImpDealDate());
				item.setNote("批量充值数据导入[柜员 :" + log.getUserId() + ", 时间 : " + DateUtil.formatDate(log.getDealTime()) + "]");

				publicDao.save(item);

				amt = amt.add(BigDecimal.valueOf(item.getAmt()));
				num++;
			}

			// 4. 更新导入批次信息
			if (failList.size() == batchRechargeInfo.size()) {
				publicDao.delete(info);
			} else {
				info.setAmt(amt);
				info.setNum(num);
			}
			
			//业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setNote(log.getMessage());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			trServRec.setCustomerId(corp.getCustomerId());
			trServRec.setCustomerName(corp.getCorpName());
			publicDao.save(trServRec);

			// 5. 返回导入失败的记录
			return failList;
		} catch (CommonException e) {
			throw new CommonException("导入充值数据失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("导入充值数据失败, 系统异常.");
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public List<BaseCorpRechargeList> saveCheckPassImportBatchRechargeInfo(List<BaseCorpRechargeList> batchRechargeInfos, String corpId) {
		try {
			List<BaseCorpRechargeList> failList = new ArrayList<BaseCorpRechargeList>();

			// 参数验证
			if (batchRechargeInfos == null || batchRechargeInfos.isEmpty()) {
				throw new CommonException("审核充值记录为空.");
			} else if (corpId == null || corpId.trim().equals("")) {
				throw new CommonException("单位为空.");
			}

			// 日志记录
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.CORP_BATCH_RECHARGE_CHECK);
			log.setMessage("单位批量充值导入数据审核.");
			publicDao.save(log);

			// 1.验证并获取正常单位信息
			getValidateCorp(corpId);

			// 2.循环处理每条数据
			for (BaseCorpRechargeList item : batchRechargeInfos) {
				// 1.验证审核数据
				BaseCorpRechargeList list = (BaseCorpRechargeList) findOnlyRowByHql("from BaseCorpRechargeList where pk.customerId = '"
						+ item.getPk().getCustomerId() + "' and pk.rcgInfoId = " + item.getPk().getRcgInfoId());
				if (list == null) {
					item.setNote("充值数据不存在.");
					failList.add(item);
					continue;
				} else if (!list.getState().equals("0")) {// 0-待审核
					item.setNote("充值数据不是待审核状态, 不能进行审核.");
					failList.add(item);
					continue;
				}

				// 2.更新批量充值数据
				list.setState("1");// 1-已审核
				list.setCheckDealDate(log.getDealTime());
				list.setCheckUserId(log.getUserId());
				list.setNote(list.getNote() + "; 审核通过[柜员 : " + log.getUserId() + ", 时间 : " + DateUtil.formatDate(log.getDealTime()) + "]");
				publicDao.update(list);
			}
			
			// 3.更新导入批次信息
			BaseCorpRechargeInfo info = (BaseCorpRechargeInfo) findOnlyRowByHql("from BaseCorpRechargeInfo where id = '" + batchRechargeInfos.get(0).getPk().getRcgInfoId() + "'");
			info.setCheckUserId(log.getUserId());
			info.setCheckDealDate(log.getDealTime());
			
			// 未审核记录条数
			Object object = publicDao.findOnlyFieldBySql("select to_char(count(*)) from base_corp_rechage_list "
					+ "where state != '1' and rcg_info_id = '" + info.getId() + "'");
			if (object.toString().equals("0")) {// 2-已审核通过
				info.setState("2");
				info.setNote(info.getNote() + "; 已审核[柜员 : " + log.getUserId() + ", 日期 : " + DateUtil.formatDate(log.getDealTime()) + "]");
			} else {// 1-部分审核通过
				info.setNote(info.getNote() + "; 部分审核[柜员 : " + log.getUserId() + ", 日期 : " + DateUtil.formatDate(log.getDealTime()) + "]");
				info.setState("1");
			}
			
			//业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setNote(log.getMessage());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			publicDao.save(trServRec);

			return failList;
		} catch (CommonException e) {
			throw new CommonException("审核失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("审核失败, 系统异常");
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public List<BaseCorpRechargeList> saveRechargeBatchRechargeInfo(List<BaseCorpRechargeList> batchRechargeInfos, String corpId) {
		try {
			List<BaseCorpRechargeList> failList = new ArrayList<BaseCorpRechargeList>();
			// 参数验证
			if (batchRechargeInfos == null || batchRechargeInfos.isEmpty()) {
				throw new CommonException("记录为空.");
			} else if (corpId == null || corpId.trim().equals("")) {
				throw new CommonException("单位为空.");
			}

			// 1.验证单位信息
			getValidateCorp(corpId);

			// 2.循环处理每条数据
			BaseCorpRechargeInfo info = (BaseCorpRechargeInfo) findOnlyRowByHql("from BaseCorpRechargeInfo where id = '" + batchRechargeInfos.get(0).getPk().getRcgInfoId() + "'");
			SysActionLog log = getCurrentActionLog();
			for (BaseCorpRechargeList item : batchRechargeInfos) {
				// 1.验证审核数据
				BaseCorpRechargeList list = (BaseCorpRechargeList) findOnlyRowByHql("from BaseCorpRechargeList where pk.customerId = '"
						+ item.getPk().getCustomerId() + "' and pk.rcgInfoId = " + item.getPk().getRcgInfoId());

				if (list == null) {
					item.setNote("批量充值数据不存在.");
					failList.add(item);
					continue;
				} else if (!list.getState().equals("1")) {// 1-已审核
					item.setNote("充值数据不是已审核状态, 不能进行充值处理.");
					failList.add(item);
					continue;
				}

				try {
					// 2.充值到人员账户
					SysActionLog log2 = (SysActionLog) BeanUtils.cloneBean(log);
					log2.setDealCode(DealCode.CORP_BATCH_RECHARGE);
					log2.setMessage("单位批量充值数据充值到账户[卡号：" + list.getCardNo() + "，金额：" + list.getAmt()/100 + "]");
					publicDao.save(log2);
					rechargeToAccount(info, list, log2);
					// 更新状态
					list.setState("3");// 3-已发放
					list.setRechargeDealDate(log2.getDealTime());
					list.setRechargeUserId(log2.getUserId());
					list.setNote(list.getNote() + "; 发放成功[柜员 : " + log2.getUserId() + ", 时间 : " + DateUtil.formatDate(log2.getDealTime()) + "]");
					publicDao.update(list);
					
					//业务日志
					TrServRec trServRec = new TrServRec();
					trServRec.setDealNo(log2.getDealNo());
					trServRec.setDealCode(log2.getDealCode());
					trServRec.setNote(log2.getMessage());
					trServRec.setBizTime(log2.getDealTime());
					trServRec.setUserId(log2.getUserId());
					trServRec.setBrchId(getUser().getBrchId());
					trServRec.setOrgId(getUser().getOrgId());
					trServRec.setDealState(Constants.TR_STATE_ZC);
					trServRec.setClrDate(this.getClrDate());
					publicDao.save(trServRec);
				} catch (Exception e) {
					throw new CommonException("批量充值失败【导入批次：" + info.getId() + "，身份证号：" + list.getCertNo() + "，卡号:" + list.getCardNo() + "】" + e.getMessage());
				}

			}
			// 4.更新导入批次信息
			info.setRechargeUserId(log.getUserId());
			info.setRechargeDealDate(log.getDealTime());
			
			// 未发放记录条数
			Object object = publicDao.findOnlyFieldBySql("select to_char(count(*)) from base_corp_rechage_list where state != '3' and rcg_info_id = '" + info.getId() + "'");
			
			if (object.toString().equals("0")) {// 4-全部发放
				info.setState("4");
				info.setNote(info.getNote() + "; 已发放[柜员 : " + log.getUserId() + ", 日期 : " + DateUtil.formatDate(log.getDealTime()) + "]");
			} else {// 3-部分发放
				info.setState("3");
				info.setNote(info.getNote() + "; 部分发放[柜员 : " + log.getUserId() + ", 日期 : " + DateUtil.formatDate(log.getDealTime()) + "]");
			}
			
			return failList;
		} catch (Exception e) {
			throw new CommonException("充值失败, " + e.getMessage());
		}
	}

	/**
	 * 批量充值记录充值到人员全功能卡联机账户
	 * 
	 * @param info
	 * 
	 * @param list
	 * @param log
	 */
	private void rechargeToAccount(BaseCorpRechargeInfo info, BaseCorpRechargeList list, SysActionLog log) {
		// 借贷账户验证
		AccAccountSub accountDb = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where customerId = '"
				+ info.getCustomerId() + "' and itemId = '" + Constants.ACC_ITEM_101101 + "' and accKind = '" 
				+ Constants.ACC_KIND_PTZH + "' and accState = '1'");

		AccAccountSub accountCr = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where customerId = '"
				+ list.getPk().getCustomerId() + "' and accKind = '" + Constants.ACC_KIND_ZJZH + "' and cardNo = '"
				+ list.getCardNo() + "' and accState = '1'");

		if (accountDb == null) {
			throw new CommonException("借方账户[单位现金账户]不存在.");
		} else if (!accountDb.getAccState().equals("1")) {
			throw new CommonException("借方账户[单位现金账户]状态为[" + getCodeNameBySYS_CODE("ACC_STATE", accountDb.getAccState()) + "], 不能充值.");
		}

		if (accountCr == null) {
			throw new CommonException("贷方账户[人员联机账户]不存在.");
		} else if (!accountCr.getAccState().equals("1")) {
			throw new CommonException("贷方账户[人员联机账户]状态为[" + getCodeNameBySYS_CODE("ACC_STATE", accountCr.getAccState()) + "], 不能充值.");
		}
		
		// 验证单位余额
		if (accountDb.getBal().compareTo(BigDecimal.valueOf(list.getAmt()).multiply(BigDecimal.valueOf(100)).longValue()) < 0) {
			throw new CommonException("单位余额不足");
		}

		// 调用充值过程
		accouting(accountDb, accountCr, BigDecimal.valueOf(list.getAmt()), log, "0", "", "", "0", "单位批量充值.");
	}

	private BaseCorp getValidateCorp(String customerId) {
		BaseCorp corp = (BaseCorp) findOnlyRowByHql("from BaseCorp where customerId = '" + customerId + "'");
		if (corp == null) {
			throw new CommonException("单位信息不存在.");
		} else if (!Constants.CORP_STATE_ZC.equals(corp.getCorpState())) {
			throw new CommonException("单位状态不正常, 不能进行充值.");
		}
		return corp;
	}

	/**
	 * 账务处理
	 * 
	 * @param accountDb
	 *            借方账户
	 * @param accountCr
	 *            贷方账户
	 * @param amount
	 *            金额
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
	 * @param note
	 *            备注
	 */
	@SuppressWarnings("unchecked")
	private void accouting(AccAccountSub accountDb, AccAccountSub accountCr, BigDecimal amount, SysActionLog log, String credit, String batchNo, String termNo, String state, String note) {
		SysBranch currentBranch = (SysBranch) findOnlyRowByHql("from SysBranch where brchId = '" + log.getBrchId() + "'");
		BigDecimal amt = amount.multiply(BigDecimal.valueOf(100));

		List<Object> inparams = new ArrayList<Object>();
		inparams.add(accountDb.getAccNo());// 借方
		inparams.add(accountCr.getAccNo());// 贷方
		inparams.add(accountDb.getBal());// 借方交易前卡面金额
		inparams.add(accountCr.getBal());// 贷方交易前卡面金额
		inparams.add("");// 借方交易计数器
		inparams.add("");// 贷方交易计数器
		inparams.add("");// 借方金额密文
		inparams.add(Tools.processNull(accountCr.getCardNo()).equals("")?"":doWorkService.money2EncryptCal(accountCr.getCardNo(), accountCr.getBal().toString(), amt.longValue() + "", Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD));// 贷方金额密文
		inparams.add(amt);// 交易金额，单位-分
		inparams.add(credit);// 信用发生额
		inparams.add(getSequenceByName("seq_acc_book_no"));// 记账流水号
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
		inparams.add(note);// 备注
		inparams.add(getClrDate());// 清分日期
		inparams.add("");// 其它传入参数 退货时传入原acc_book_no
		inparams.add("");// 1调试

		List<Object> outTypes = new ArrayList<Object>();
		outTypes.add(Types.VARCHAR);
		outTypes.add(Types.VARCHAR);
		List<Object> rets = publicDao.callProc("pk_business.p_account2", inparams, outTypes);
		if (rets == null || rets.isEmpty()) {
			throw new CommonException("调用充值过程失败.");
		}
		if (!rets.get(0).equals("00000000")) {
			throw new CommonException(rets.get(1).toString().equals("null") ? "" : rets.get(1).toString());
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public List<BaseCorpRechargeList> deleteBatchRechargeInfo(List<BaseCorpRechargeList> batchRechargeInfos, String customerId) {
		try {
			List<BaseCorpRechargeList> failList = new ArrayList<BaseCorpRechargeList>();

			// 参数验证
			if (batchRechargeInfos == null || batchRechargeInfos.isEmpty()) {
				throw new CommonException("记录为空.");
			} else if (customerId == null || customerId.trim().equals("")) {
				throw new CommonException("单位为空.");
			}

			// 日志记录
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.CORP_BATCH_RECHARGE_DELETE);
			log.setMessage("删除批量充值数据.");

			publicDao.save(log);

			// 1.验证单位信息
			getValidateCorp(customerId);

			// 2.循环处理每条数据
			for (BaseCorpRechargeList item : batchRechargeInfos) {
				// 1.验证审核数据
				BaseCorpRechargeList list = (BaseCorpRechargeList) findOnlyRowByHql("from BaseCorpRechargeList where pk.customerId = '"
						+ item.getPk().getCustomerId() + "' and pk.rcgInfoId = " + item.getPk().getRcgInfoId());

				if (list == null) {
					item.setNote("批量充值数据不存在.");
					failList.add(item);
					continue;
				} else if (list.getState().equals("3")) {// 3-已发放
					item.setNote("充值记录已发放, 不能删除.");
					failList.add(item);
					continue;
				} else if (list.getState().equals("4")) {// 4-已删除
					item.setNote("充值记录已删除.");
					failList.add(item);
					continue;
				}

				// 2.更新批量充值数据
				list.setState("4");// 4-已删除
				list.setCheckDealDate(log.getDealTime());
				list.setCheckUserId(log.getUserId());
				list.setNote(list.getNote() + "; 删除成功[柜员 : " + log.getUserId() + ", 时间 : " + DateUtil.formatDate(log.getDealTime()) + "]");
				publicDao.update(list);
			}
			// 3.更新导入批次信息
			BaseCorpRechargeInfo info = (BaseCorpRechargeInfo) findOnlyRowByHql("from BaseCorpRechargeInfo where id = '" 
					+ batchRechargeInfos.get(0).getPk().getRcgInfoId() + "'");
			Object object = publicDao.findOnlyFieldBySql("select to_char(count(*)) from base_corp_rechage_list "
					+ "where state != '4' and rcg_info_id = '" + info.getId() + "'");
			if(object.equals("0")){
				info.setState("5");
				info.setNote(info.getNote() + "; 已删除[柜员 : " + log.getUserId() + ", 日期 : " + DateUtil.formatDate(log.getDealTime()) + "]");
			}
			
			//业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setNote(log.getMessage());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			publicDao.save(trServRec);

			return failList;
		} catch (CommonException e) {
			throw new CommonException("删除失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("删除失败, 系统异常.");
		}
	}
	
	public void accouting_ghk(AccAccountSub accountDb, AccAccountSub accountCr, BigDecimal amount, SysActionLog log, String credit, String batchNo, String termNo, String state, String note)
	  {
		try {
			SysBranch currentBranch = (SysBranch)findOnlyRowByHql("from SysBranch where brchId = '" + log.getBrchId() + "'");
		    List inparams = new ArrayList();
		    inparams.add(accountDb.getAccNo());
		    inparams.add(accountCr.getAccNo());
		    inparams.add(accountDb.getBal());
		    inparams.add(accountCr.getBal());
		    inparams.add("");
		    inparams.add("");
		    inparams.add(accountDb.getBalCrypt() == null ? "" : accountDb.getBalCrypt());
		    inparams.add(accountCr.getBalCrypt() == null ? "" : accountCr.getBalCrypt());
		    inparams.add(amount.multiply(BigDecimal.valueOf(100L)));
		    inparams.add(credit);
		    inparams.add(getSequenceByName("SEQ_ACC_INOUT_NO"));
		    inparams.add(log.getDealCode());
		    inparams.add(accountCr.getOrgId());
		    inparams.add(currentBranch.getOrgId());
		    inparams.add(currentBranch.getBrchType());
		    inparams.add(log.getBrchId());
		    inparams.add(log.getUserId());
		    inparams.add(batchNo);
		    inparams.add(termNo);
		    inparams.add(DateUtil.formatDate(log.getDealTime()));
		    inparams.add(state);
		    inparams.add(log.getDealNo());
		    inparams.add(note);
		    inparams.add(getClrDate());
		    inparams.add("");
		    inparams.add("");

		    List outTypes = new ArrayList();
		    outTypes.add(Integer.valueOf(12));
		    outTypes.add(Integer.valueOf(12));

		    List rets = this.publicDao.callProc("pk_business.p_account2", inparams, outTypes);

		    if ((rets == null) || (rets.isEmpty())) {
		      throw new CommonException("调用充值过程失败.");
		    }

		    if (!rets.get(0).equals("00000000")){
		    	throw new CommonException(rets.get(1).toString().equals("null") ? "" : rets.get(1).toString());
		    }
		} catch (Exception e) {
		}
	 }

	@SuppressWarnings("unchecked")
	@Override
	public void deleteBatchRechargeInfo(BaseCorpRechargeInfo info) {
		try {
			// 日志记录
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.CORP_BATCH_RECHARGE_DELETE);
			log.setMessage("删除批量充值数据.");
			publicDao.save(log);

			//
			info = (BaseCorpRechargeInfo) findOnlyRowByHql("from BaseCorpRechargeInfo where id = '" + info.getId() + "'");
			if(info == null){
				throw new CommonException("批量充值数据不存在");
			} else if(!info.getState().equals("0")){
				throw new CommonException("批量充值数据不是【待审核】状态, 不能删除.");
			}
			
			//
			List<BaseCorpRechargeList> list = findByHql("from BaseCorpRechargeList where pk.rcgInfoId = '" + info.getId() + "'");
			if(list == null || list.isEmpty()){
				throw new CommonException("批量充值数据不是【待审核】状态, 不能删除.");
			}
			
			for (BaseCorpRechargeList item : list) {
				if (!item.getState().equals("0")) {// 3-已发放
					throw new CommonException("充值记录【" + item.getName() + ", " + item.getCertNo() + "】不是待审核, 不能删除.");
				}

				// 2.更新批量充值数据
				item.setState("4");// 4-已删除
				item.setCheckDealDate(log.getDealTime());
				item.setCheckUserId(log.getUserId());
				item.setNote(item.getNote() + "; 删除成功[柜员 : " + log.getUserId() + ", 时间 : " + DateUtil.formatDate(log.getDealTime()) + "]");
			}
				
			info.setState("5");
			info.setNote(info.getNote() + "; 已删除[柜员 : " + log.getUserId() + ", 日期 : " + DateUtil.formatDate(log.getDealTime()) + "]");
			
			//业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setNote(log.getMessage());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			publicDao.save(trServRec);
		} catch (CommonException e) {
			throw new CommonException("删除失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("删除失败, 系统异常.");
		}
	}   

}
