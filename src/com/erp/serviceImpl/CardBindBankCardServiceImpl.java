/**
 * 
 */
package com.erp.serviceImpl;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.beanutils.BeanUtils;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseBank;
import com.erp.model.BasePersonal;
import com.erp.model.BaseSiinfo;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardBindBankCard;
import com.erp.model.CardBindBankCardId;
import com.erp.model.CardBindBankPre;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.CardBindBankCardService;
import com.erp.service.DoWorkClientService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.ReceiptContants;
import com.erp.util.Tools;

/**
 * @author Yueh
 */
@Service("cardBindBankCardService")
public class CardBindBankCardServiceImpl extends BaseServiceImpl implements CardBindBankCardService {
	// 接口参数
	private static final String SERVICE_BIND_BANKCARD_BIND = "B0056";
	private static final String SERVICE_BIND_BANKCARD_UNBIND = "B0057";
	private static final String SERVICE_BIND_BANKCARD_VALID = "B0058";
	private static final String TIME_FORMAT = "HHmmss";
	private static final String DATE_FORMAT = "yyyyMMdd";
	private static final String TIME = "time";
	private static final String DATE = "date";
	private static final String BANK_CARD_NO = "bankcardno";
	private static final String NAME = "name";
	private static final String CERT_NO = "sfz";
	private static final String SUB_CARD_NO = "cardno";
	private static final String USER_ID = "operid";
	private static final String TERM_NO = "termno";
	private static final String TERM_ID = "termid";
	private static final String BANK_ID = "bizid";
	private static final String TRCODE = "trcode";
	
	@Resource
	private DoWorkClientService doWorkClientService;
	
	// 当前网点可受理银行网点
	private List<String> bankIds = null;

	/*
	 * @see
	 * com.erp.service.CardBindBankCardService#validCardBindBankCard(com.erp
	 * .model.CardBindBankCard)
	 */
	@SuppressWarnings({ "unchecked" })
	@Override
	public Boolean validCardBindBankCard(CardBindBankCard bindInfo) {
		try {
			// 1.参数验证, 操作日志
			validCardBindBankCardInfo(bindInfo);

			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.CARD_BIND_BANKCARD_VALID);
			log.setMessage("卡片绑定银行卡验证:[身份证号:" + bindInfo.getId().getCertNo()
					+ ", 卡号:" + bindInfo.getId().getSubCardNo() 
					+ ", 银行卡号:" + bindInfo.getBankCardNo() + "]");
			publicDao.save(log);
			
			// 2.绑定验证
			CardBindBankCard bindInfo2 = (CardBindBankCard) publicDao.get(CardBindBankCard.class, bindInfo.getId());
			if (bindInfo2 != null) {
				throw new CommonException("卡片[" + bindInfo2.getId().getSubCardNo() + "]已经绑定银行卡[" + bindInfo2.getBankCardNo() + "].");
			}
			
			// 验证预绑定信息
			CardBindBankPre preBindInfo = (CardBindBankPre) findOnlyRowByHql("from CardBindBankPre where id.certNo = '"
					+ bindInfo.getId().getCertNo() + "' and id.subCardNo = '" + bindInfo.getId().getSubCardNo() + "'");
			if (preBindInfo != null) {
				String perBindBankName = (String) findOnlyFieldBySql("select bank_name from base_bank where bank_id = '" + preBindInfo.getBankId() + "'");
				throw new CommonException("卡片 [" + bindInfo.getId().getSubCardNo() + "] 已经预绑定银行 [" + perBindBankName + "], 只能到该银行办理绑定.");
			}

			// 3.验证卡片信息
			CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where subCardNo = '"
					+ bindInfo.getId().getSubCardNo() + "' and cardState = '" + Constants.CARD_STATE_ZC + "'");
			if (card == null) {
				throw new CommonException("卡片信息不存在.");
			} else if (!Constants.CARD_STATE_ZC.equals(card.getCardState())) {
				throw new CommonException("卡片状态不正常.");
			}

			// 4.验证人员信息
			BasePersonal person = (BasePersonal) publicDao.get(BasePersonal.class, Long.valueOf(card.getCustomerId()));
			if (person == null) {
				throw new CommonException("人员信息不存在.");
			} else if (!Constants.STATE_ZC.equals(person.getCustomerState())) {
				throw new CommonException("人员状态不正常.");
			}

			// 5.验证银行
			BaseBank bank = (BaseBank) publicDao.get(BaseBank.class, bindInfo.getBankId());
			if (bank == null) {
				throw new CommonException("银行不存在.");
			}

			//6.验证
			JSONArray paramList = new JSONArray();
			JSONObject params = new JSONObject();
			
			params.put(TRCODE, SERVICE_BIND_BANKCARD_VALID);// 
			params.put(BANK_ID, bindInfo.getBankId());// 银行编码
			params.put(TERM_ID, "");// 终端号
			params.put(TERM_NO, log.getDealNo());// 终端流水
			params.put(USER_ID, log.getUserId());// 柜员
			params.put(CERT_NO, bindInfo.getId().getCertNo());// 身份证
			params.put(NAME, bindInfo.getName());// 姓名
			params.put(BANK_CARD_NO, bindInfo.getBankCardNo());// 银行卡号
			
			paramList.add(params);
			JSONArray returnList = null;
			try {
				returnList = doWorkClientService.invoke(paramList);
			} catch (Exception e) {
				throw new CommonException("调用远程接口失败, " + e.getMessage());
			}

			// when fail throw exception with messages
			if (returnList == null || returnList.isEmpty()) {
				throw new CommonException("远程接口返回为空.");
			}
			
			JSONObject returns = returnList.getJSONObject(0);
			String errCode=returns.getString("errcode");
			String errMesg=returns.getString("errmessage");
			
			if (!Tools.processNull(errCode).equals("00")) {
				throw new CommonException("调用远程接口返回失败信息, " + errMesg);
			}
			
			return true;
		} catch (CommonException e) {
			throw new CommonException("验证不通过, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("验证不通过, 系统异常[" + e.getMessage() + "]");
		}
	}

	/*
	 * @see
	 * com.erp.service.CardBindBankCardService#saveCardBindBankCard(com.erp.
	 * model.CardBindBankCard)
	 */
	@Override
	public void saveCardBindBankCard(CardBindBankCard bindInfo) {
		try {
			//2.绑定(保存)
			SysActionLog log = getCurrentActionLog();
			saveBindBankCard(bindInfo, log);
			
			// 3.调用绑定接口
			JSONArray list = new JSONArray();
			JSONObject params = new JSONObject();
			params.put(TRCODE, SERVICE_BIND_BANKCARD_BIND);
			params.put(BANK_ID, bindInfo.getBankId());// 商户号(银行编号)
			params.put(TERM_ID, "");// 终端号
			params.put(TERM_NO, log.getDealNo());// 终端业务流水
			params.put(USER_ID, log.getUserId());// 操作员(柜员)
			params.put(SUB_CARD_NO, bindInfo.getId().getSubCardNo());// 市民卡卡号(9位)
			params.put(CERT_NO, bindInfo.getId().getCertNo());// 身份证
			params.put(NAME, bindInfo.getName());// 姓名
			params.put(BANK_CARD_NO, bindInfo.getBankCardNo());// 银行卡号
			params.put(DATE, DateUtil.formatDate(log.getDealTime(), DATE_FORMAT));// 交易日期
			params.put(TIME, DateUtil.formatDate(log.getDealTime(), TIME_FORMAT));// 交易时间

			list.add(params);
			JSONArray returnList = doWorkClientService.invoke(list);

			// 失败则抛出异常
			if (returnList == null || returnList.isEmpty()) {
				throw new CommonException("远程接口返回为空.");
			}

			JSONObject returns = returnList.getJSONObject(0);

			String errCode = returns.getString("errcode");
			String errMesg = returns.getString("errmessage");

			if (!Tools.processNull(errCode).equals("00")) {
				throw new CommonException("调用远程接口返回失败信息, " + errMesg);
			}
		} catch (CommonException e) {
			throw new CommonException("绑定失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("绑定失败, 系统异常[" + e.getMessage() + "]");
		}
	}

	/*
	 * @see
	 * com.erp.service.CardBindBankCardService#saveCardBindBankCard(java.util
	 * .List)
	 */
	@SuppressWarnings("unchecked")
	@Override
	public List<CardBindBankCard> saveCardBindBankCard(List<CardBindBankCard> bindInfos) {
		try {
			List<CardBindBankCard> failList = new ArrayList<CardBindBankCard>();
			
			//1.参数验证, 操作日志
			if(bindInfos == null || bindInfos.isEmpty()){
				throw new CommonException("批量卡片绑定银行卡信息为空.");
			}
			SysActionLog currentActionLog = getCurrentActionLog();
			
			SysActionLog log = (SysActionLog) BeanUtils.cloneBean(currentActionLog);
			log.setDealCode(DealCode.CARD_BIND_BANKCARD_BIND_BATCH);
			publicDao.save(log);

			// 2.循环验证保存
			
			JSONArray list = new JSONArray();
			for (CardBindBankCard bindInfo : bindInfos) {
				try {
					// 验证预绑定信息
					validPreBindInfo(bindInfo);
					
					// 保存
					SysActionLog log2 = (SysActionLog) BeanUtils.cloneBean(currentActionLog);
					TrServRec recItem = saveBindBankCard(bindInfo, log2);// 绑定
					recItem.setOldDealNo(log.getDealNo());
					
					// 构造参数
					JSONObject params = new JSONObject();
					params.put(TRCODE, SERVICE_BIND_BANKCARD_BIND);//
					params.put(BANK_ID, bindInfo.getBankId());// 商户号(银行编号)
					params.put(TERM_ID, "");// 终端号
					params.put(TERM_NO, log2.getDealNo());// 终端业务流水
					params.put(USER_ID, log2.getUserId());// 操作员(柜员)
					params.put(SUB_CARD_NO, bindInfo.getId().getSubCardNo());// 市民卡卡号(9位)
					params.put(CERT_NO, bindInfo.getId().getCertNo());// 身份证
					params.put(NAME, bindInfo.getName());// 姓名
					params.put(BANK_CARD_NO, bindInfo.getBankCardNo());// 银行卡号
					params.put(DATE, DateUtil.formatDate(log2.getDealTime(), DATE_FORMAT));// 交易日期
					params.put(TIME, DateUtil.formatDate(log2.getDealTime(), TIME_FORMAT));// 交易时间
					
					list.add(params);
				} catch (Exception e) {
					bindInfo.setFailReason(e.getMessage());
					failList.add(bindInfo);
					continue;
				}
			}
			if(list.isEmpty()) {
				return failList;
			}
			
			// 3.调用绑定接口 失败则抛出异常
			JSONArray returnList = doWorkClientService.invoke(list);
			if (returnList == null || returnList.isEmpty()) {
				throw new CommonException("远程接口返回为空.");
			}
			for (int i = 0; i < returnList.size(); i++) {
				JSONObject returns = returnList.getJSONObject(i);

				String errCode = returns.getString("errcode");
				String errMesg = returns.getString("errmessage");

				String certNo = returns.getString(CERT_NO);
				String subCardNo = returns.getString(SUB_CARD_NO);
				if (!Tools.processNull(errCode).equals("00")) {// 有失败记录
					// 删除已保存的
					CardBindBankCard failItem = (CardBindBankCard) publicDao.get(CardBindBankCard.class, new CardBindBankCardId(certNo, subCardNo));
					publicDao.delete(failItem);
					
					failItem.setFailReason("银行返回失败, " + errMesg);
					failList.add(failItem);
					continue;
				}
			}
			
			// 4.日志
			log.setMessage("卡片绑定银行卡(批量):[绑定数量:" + bindInfos.size() + ", 失败数量:" + failList.size() + "]");
			
			// 业务日志
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(getClrDate());
			publicDao.save(rec);
			
			// return
			return failList;
		} catch (CommonException e) {
			throw new CommonException("批量绑定失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("批量绑定失败, 系统异常[" + e.getMessage() + "]");
		}
	}

	/*
	 * @see
	 * com.erp.service.CardBindBankCardService#saveCardUnBindBankCard(com.erp
	 * .model.CardBindBankCard)
	 */
	@SuppressWarnings({ "unchecked" })
	@Override
	public Long saveCardUnBindBankCard(TrServRec rec, CardBindBankCard unBindInfo) {
		try {
			//1.参数验证, 操作日志
			if (unBindInfo == null || unBindInfo.getId() == null) {
				throw new CommonException("卡片绑定银行卡信息为空.");
			} else if (unBindInfo.getId().getCertNo() == null) {
				throw new CommonException("卡片绑定银行卡信息[身份证号]为空.");
			}
			
			SysActionLog log = (SysActionLog) BeanUtils.cloneBean(getCurrentActionLog());
			log.setDealCode(DealCode.CARD_BIND_BANKCARD_UNBIND);
			publicDao.save(log);			
			//2.验证绑定信息
			CardBindBankCard bindInfo = (CardBindBankCard) findOnlyRowByHql("from CardBindBankCard t where exists (select 1 from BasePersonal where customerId = t.customerId and certNo = '" + unBindInfo.getId().getCertNo() + "')");
					
			if (bindInfo == null) {
				throw new CommonException("卡片没有绑定银行卡.");
			}
			
			BasePersonal person = (BasePersonal) findOnlyRowByHql("from BasePersonal where customerId = '" + bindInfo.getCustomerId() + "'");
			if (person == null) {
				throw new CommonException("客户信息不存在！");
			}
			
			BaseBank bank = (BaseBank) publicDao.get(BaseBank.class, bindInfo.getBankId());
			if (bank == null) {
				throw new CommonException("绑定银行不存在.");
			}
			
			//判断是否有权限解绑
			String tempBrchId = log.getBrchId();
			List<String> brchIds = this.findBySql("select brch_id from sys_branch start with brch_id = '10000000' connect by prior sysbranch_id =  pid");
			brchIds.add("99999999");
			if(!brchIds.contains(tempBrchId)){
				String curBankId = (String) this.findOnlyFieldBySql("select t.bank_id from base_bank t,branch_bank t2 where t.bank_id = t2.bank_id and t2.brch_id = '" + tempBrchId + "'");
				if(!Tools.processNull(curBankId).equals(bindInfo.getBankId())){
					throw new CommonException("当前网点无权限解绑该银行卡绑定关系！");
				}
			}
			
			//3.删除
			publicDao.delete(bindInfo);
			
			try {
				//4.调用解绑接口
				JSONArray list = new JSONArray();
				JSONObject params = new JSONObject();
				params.put(TRCODE, SERVICE_BIND_BANKCARD_UNBIND);
				params.put(BANK_ID, bindInfo.getBankId());// 商户号(银行编号)
				params.put(TERM_ID, "");// 终端号
				params.put(TERM_NO, log.getDealNo());// 终端业务流水
				params.put(USER_ID, log.getUserId());// 操作员(柜员)
				params.put(SUB_CARD_NO, bindInfo.getId().getSubCardNo());// 市民卡卡号(9位)
				params.put(CERT_NO, bindInfo.getId().getCertNo());// 身份证
				params.put(NAME, bindInfo.getName());// 姓名
				params.put(BANK_CARD_NO, bindInfo.getBankCardNo());// 银行卡号
				params.put(DATE, DateUtil.formatDate(log.getDealTime(), DATE_FORMAT));// 交易日期
				params.put(TIME, DateUtil.formatDate(log.getDealTime(), TIME_FORMAT));// 交易时间
				
				list.add(params);
				doWorkClientService.invoke(list);
			} catch (Exception e) {
				// do nothing
			}

			//5.保存解绑信息
			String insertSql = "insert into CARD_UNBIND_BANKCARD "
					+ "(NAME, CERT_NO, SUB_CARD_ID, SUB_CARD_NO, "
					+ "BANK_ID, BANK_CARD_NO, BANK_CARD_TYPE, "
					+ "OPER_ID, UNBIND_DATE, RECEIPT, LINE_NO) "
					+ "values ('" + bindInfo.getName() + "', '" 
					+ bindInfo.getId().getCertNo() + "', '" 
					+ bindInfo.getSubCardId() + "', '" 
					+ bindInfo.getId().getSubCardNo() + "', '" 
					+ bindInfo.getBankId() + "', '" 
					+ bindInfo.getBankCardNo() + "', '" 
					+ bindInfo.getBankCardType() + "', '" 
					+ log.getUserId() + "', "
					+ "to_date('" + DateUtil.formatDate(log.getDealTime()) + "', 'yyyy-mm-dd hh24:mi:ss'), "
					+ "'1', '"
					+ Tools.processNull(bindInfo.getLineNo()) + "')";
			
			publicDao.doSql(insertSql);
			
			log.setMessage("卡片绑定银行卡解绑:[身份证号:" + bindInfo.getId().getCertNo()
					+ ", 卡号:" + bindInfo.getId().getSubCardNo() 
					+ ", 银行卡号:" + bindInfo.getBankCardNo() + "]");
			
			//业务日志
			rec.setDealNo(log.getDealNo());
			rec.setBizTime(log.getDealTime());
			rec.setUserId(log.getUserId());
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(getClrDate());
			rec.setCardNo(bindInfo.getCardNo());
			rec.setCertType(person.getCertType());
			rec.setCertNo(person.getCertNo());
			rec.setCustomerId(person.getCustomerId().toString());
			rec.setCustomerName(person.getName());
			rec.setRsvOne(bindInfo.getBankId());
			rec.setRsvFour(bindInfo.getBankCardNo());
			rec.setRsvFive(bank.getBankName());
			publicDao.save(rec);
			
			// report
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.CARD_NO, bindInfo.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, bindInfo.getId().getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, person.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, person.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, rec.getAgtName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getAgtCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, rec.getAgtCertNo()); // 代理人证件号码
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, log.getBrchId()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, log.getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, log.getUserId()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			json.put("bank_name", bank.getBankName());
			json.put("bank_card_no", bindInfo.getBankCardNo());
			this.saveSysReport(log, json, "/reportfiles/UnBindBankCard.jasper", Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			
			return rec.getDealNo();
		} catch (CommonException e) {
			throw new CommonException("卡片绑定银行卡解绑失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("卡片绑定银行卡解绑失败, 系统异常[" + e.getMessage() + "]");
		}
	}
	
	private void validCardBindBankCardInfo(CardBindBankCard bindInfo) {
		if (bindInfo == null || bindInfo.getId() == null) {
			throw new CommonException("卡片绑定银行卡信息为空.");
		} else if (bindInfo.getName() == null) {
			throw new CommonException("卡片绑定银行卡信息[姓名]为空.");
		} else if (bindInfo.getId().getCertNo() == null) {
			throw new CommonException("卡片绑定银行卡信息[身份证号]为空.");
		} else if (bindInfo.getId().getSubCardNo() == null) {
			throw new CommonException("卡片绑定银行卡信息[社保卡号]为空.");
		} else if (bindInfo.getBankId() == null) {
			throw new CommonException("卡片绑定银行卡信息[银行编号]为空.");
		} else if (bindInfo.getBankCardNo() == null) {
			throw new CommonException("卡片绑定银行卡信息[银行卡号]为空.");
		}
	}

	@SuppressWarnings({ "unchecked" })
	public TrServRec saveBindBankCard(CardBindBankCard bindInfo, SysActionLog log) {
		try {
			// 日志
			log.setDealCode(DealCode.CARD_BIND_BANKCARD_BIND);
			log.setMessage("卡片绑定银行卡:[身份证号:" + bindInfo.getId().getCertNo() + ", 卡号:" + bindInfo.getId().getSubCardNo()
					+ ", 银行卡号:" + bindInfo.getBankCardNo() + "]");
			publicDao.save(log);
			
			// 1.参数验证
			validCardBindBankCardInfo(bindInfo);
			
			// 2.绑定验证
			CardBindBankCard bindInfo2 = (CardBindBankCard) publicDao.get(CardBindBankCard.class, bindInfo.getId());
			if (bindInfo2 != null) {
				throw new CommonException("卡片 [" + bindInfo2.getId().getSubCardNo() + "] 已经绑定银行卡 [" + bindInfo2.getBankCardNo() + "].");
			}
			
			// 验证预绑定信息
			CardBindBankPre preBindInfo = (CardBindBankPre) findOnlyRowByHql("from CardBindBankPre where id.certNo = '" 
					+ bindInfo.getId().getCertNo() + "' and id.subCardNo = '" + bindInfo.getId().getSubCardNo() + "'");
			if (preBindInfo != null && preBindInfo.getBankId().equals(bindInfo.getBankId())) { // 如果预绑定是当前银行-可以绑定
				// 删除预绑定信息
				publicDao.delete(preBindInfo);
			} else if (preBindInfo != null) { // 如果预绑定不是当前银行-提示
				String perBindBankName = (String) findOnlyFieldBySql("select bank_name from base_bank where bank_id = '" + preBindInfo.getBankId() + "'");
				throw new CommonException("卡片 [" + bindInfo.getId().getSubCardNo() + "] 已经预绑定银行 [" + perBindBankName + "], 只能到该银行办理绑定.");
			}
			
			// 3.验证卡片信息
			CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where subCardNo = '" + bindInfo.getId().getSubCardNo() + "' and cardState = '" + Constants.CARD_STATE_ZC + "'");
			if (card == null) {
				throw new CommonException("卡片[" + bindInfo.getId().getSubCardNo() + "]不存在或状态不正常.");
			}
			
			// 4.验证人员信息
			BasePersonal person = (BasePersonal) findOnlyRowByHql("from BasePersonal where customerId = '" + card.getCustomerId() + "'");
			if(person == null){
				throw new CommonException("人员信息不存在.");
			} else if(!Constants.STATE_ZC.equals(person.getCustomerState())){
				throw new CommonException("人员状态不正常.");
			}
			
			// 获取统筹区信息
			BaseSiinfo siinfo = (BaseSiinfo) findOnlyRowByHql("from BaseSiinfo where customerId = '" + card.getCustomerId() + "'");
			if(siinfo == null){
				throw new CommonException("人员参保信息不存在.");
			}
			
			// 5.验证银行
			BaseBank bank = (BaseBank) publicDao.get(BaseBank.class, bindInfo.getBankId());
			if (bank == null) {
				throw new CommonException("银行不存在.");
			}
			
			// 更新人员信息 (客户需求)
			if (!Tools.processNull(bindInfo.getMobileNum()).equals("")) {
				person.setMobileNo(bindInfo.getMobileNum());
			}
			if (!Tools.processNull(bindInfo.getAddress()).equals("")) {
				person.setLetterAddr(bindInfo.getAddress());
			}
			
			// 6.保存
			bindInfo.setCustomerId(person.getCustomerId().toString());
			bindInfo.setName(person.getName());
			bindInfo.getId().setCertNo(person.getCertNo());;
			bindInfo.setBankCardType("0");//原系统就是怎么写的
			bindInfo.setState(Constants.CARD_BIND_BANKCARD_STATE_BIND);
			bindInfo.setRegionId(person.getRegionId());
			bindInfo.setCityId(person.getCityId());
			bindInfo.setTownId(person.getTownId());
			bindInfo.setCommId(person.getCommId());
			bindInfo.setAddress(person.getLetterAddr());
			bindInfo.setUserId(log.getUserId());
			bindInfo.setBrchId(log.getBrchId());
			bindInfo.setActivateDate(log.getDealTime());
			bindInfo.setModifyDate(log.getDealTime());
			bindInfo.setSubCardId(card.getSubCardId());
			bindInfo.setBindDate(log.getDealTime());
			bindInfo.setCardNo(card.getCardNo());
			bindInfo.setMobileNum(person.getMobileNo());
			bindInfo.setSbbh(siinfo.getId().getPersonalId());
			bindInfo.setTcq(siinfo.getId().getMedWholeNo());
			
			publicDao.save(bindInfo);
			
			// 业务日志
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(getClrDate());
			rec.setCardNo(bindInfo.getCardNo());
			rec.setCertType(person.getCertType());
			rec.setCertNo(person.getCertNo());
			rec.setCardType(card.getCardType());
			rec.setCustomerId(person.getCustomerId().toString());
			rec.setCustomerName(person.getName());
			rec.setRsvOne(bank.getBankId());
			rec.setRsvFour(bindInfo.getBankCardNo());
			rec.setRsvFive(bank.getBankName());
			publicDao.save(rec);
			
			return rec;
		}  catch (Exception e) {
			throw new CommonException("市民卡绑定银行失败, " + e.getMessage());
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void savePreBind(List<CardBindBankCard> preBindInfos) {
		try {
			// 1.日志,
			if(preBindInfos==null||preBindInfos.isEmpty()){
				throw new CommonException("导出预绑定数据为空.");
			}
			
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.CARD_BIND_BANKCARD_PREBIND);
			log.setMessage("市民卡绑定银行卡预绑定，预绑定人数：" + preBindInfos.size());
			publicDao.save(log);
			
			// 预绑定
			for (CardBindBankCard preBindInfo : preBindInfos) {
				// 查询已绑定信息
				CardBindBankCard alBindInfo = (CardBindBankCard) findOnlyRowByHql("from CardBindBankCard where id.certNo = '" 
						+ preBindInfo.getId().getCertNo() + "' and id.subCardNo = '" + preBindInfo.getId().getSubCardNo() + "'");
				if (alBindInfo != null) {// 已绑定
					preBindInfo.setName(alBindInfo.getName());
					preBindInfo.setBankId(alBindInfo.getBankId());
					String bankCardNo = alBindInfo.getBankCardNo();
					preBindInfo.setBankCardNo(bankCardNo.substring(0, bankCardNo.length() - 4).replaceAll("\\d", "*") + bankCardNo.substring(bankCardNo.length() - 4));
					preBindInfo.setMobileNum(alBindInfo.getMobileNum());
					preBindInfo.setLineNo(alBindInfo.getLineNo());
					preBindInfo.setAddress(alBindInfo.getAddress());
					preBindInfo.setState(alBindInfo.getState());
				} else {// 预绑定
					CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where subCardNo = '"
							+ preBindInfo.getId().getSubCardNo() + "' and cardState = '" + Constants.CARD_STATE_ZC + "'");
					if (card == null) {
						throw new CommonException("卡片 [" + preBindInfo.getId().getSubCardNo() + "] 状态不正常.");
					}
					
					BasePersonal person = (BasePersonal) findOnlyRowByHql("from BasePersonal where customerId = '" + card.getCustomerId() + "'");
					if(!person.getCustomerState().equals(Constants.STATE_ZC)){
						throw new CommonException("人员 [" + person.getName() + "] 状态不正常.");
					}
					
					BaseBank bank = (BaseBank) findOnlyRowByHql("from BaseBank where bankId = '" + preBindInfo.getBankId() + "'");
					if(bank==null){
						throw new CommonException("银行[" + preBindInfo.getBankId() + "]不存在.");
					}
					
					preBindInfo.setName(person.getName());
					preBindInfo.setCardNo(card.getCardNo());
					preBindInfo.setBankName(bank.getBankName());
					preBindInfo.setBrchId(log.getBrchId());
					preBindInfo.setUserId(log.getUserId());
					preBindInfo.setMobileNum(person.getMobileNo());
					preBindInfo.setAddress(person.getLetterAddr());
					preBindInfo.setModifyDate(log.getDealTime());
					preBindInfo.setState(Constants.CARD_BIND_BANKCARD_STATE_UNBIND);
					
					CardBindBankPre cardBindBankPre = new CardBindBankPre(preBindInfo);
					publicDao.saveOrUpdate(cardBindBankPre);
				}
			}
			
			// 业务日志
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(getClrDate());

			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException("批量预绑定失败.", e);
		}
	}
	
	@SuppressWarnings("unchecked")
	private void validPreBindInfo(CardBindBankCard bindInfo) {
		// 当前网点可受理的银行
		bankIds = getCurBrchBankIds();
		
		if (!bankIds.contains(bindInfo.getBankId())) {
			throw new CommonException("批量绑定数据包含当前网点不能受理的银行 [" + bindInfo.getBankId() + "].");
		}
		// 绑定信息
		CardBindBankCard alBindInfo = (CardBindBankCard) findOnlyRowByHql("from CardBindBankCard where id.certNo = '"
				+ bindInfo.getId().getCertNo() + "' and id.subCardNo = '" + bindInfo.getId().getSubCardNo() + "'");
		if (alBindInfo != null) {
			throw new CommonException("卡片 [" + bindInfo.getId().getSubCardNo() + "] 已绑定银行 [" + alBindInfo.getBankId() + "].");
		}
		
		// 预绑定信息是否匹配
		CardBindBankPre preBindInfo = (CardBindBankPre) findOnlyRowByHql("from CardBindBankPre where id.certNo = '"
				+ bindInfo.getId().getCertNo() + "' and id.subCardNo = '" + bindInfo.getId().getSubCardNo() + "'");

		if (preBindInfo == null) {
			throw new CommonException("批量绑定数据包含与未导出记录.");
		} else if (!preBindInfo.getBankId().equals(bindInfo.getBankId())) {
			throw new CommonException("批量绑定数据包含与导出银行不匹配的记录 [" + bindInfo.getBankId() + "].");
		}
		publicDao.delete(preBindInfo);
	}

	@SuppressWarnings("unchecked")
	private List<String> getCurBrchBankIds() {
		if (bankIds != null) {
			return bankIds;
		}
		SysBranch curBrch = getSessionSysBranch();
		// 获取自有网点编号
		List<String> zyBrchIds = findBySql("select brch_id from sys_branch start with brch_id = '10000000' connect by prior sysbranch_id =  pid");
		zyBrchIds.add("99999999");
		if(zyBrchIds.contains(curBrch.getBrchId())){ // 自有网点
			bankIds = findBySql("select bank_id from base_bank where bank_state = '" + Constants.STATE_ZC + "'");
		} else { // 非自有网点
			bankIds = findBySql("select t.bank_id from base_bank t join branch_bank t2 on t.bank_id = t2.bank_id and t2.brch_id = '" 
					+ curBrch.getBrchId() + "' and t.bank_state = '" + Constants.STATE_ZC + "'");
			if(bankIds == null || bankIds.isEmpty()){
				throw new CommonException("当前网点不能办理银行绑定业务，请咨询市民卡工作人员【详细信息：非市民卡自有网点且无所属银行】");
			}
		}
		
		return bankIds;
	}
}
