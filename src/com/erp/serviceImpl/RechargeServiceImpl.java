package com.erp.serviceImpl;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import com.erp.model.*;
import org.apache.commons.beanutils.BeanUtils;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.service.AccAcountService;
import com.erp.service.DoWorkClientService;
import com.erp.service.RechargeService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.ReceiptContants;
import com.erp.util.Sys_Code;
import com.erp.util.Tools;

@Service("rechargeService")
public class RechargeServiceImpl extends BaseServiceImpl implements RechargeService {
	@Resource(name="accAcountService")
	private AccAcountService acc;
	@Resource(name="doWorkClientService")
	private DoWorkClientService doWorkClientService;
	/**
	 * 》》钱包账户现金充值记录灰记录
	 * @param map 充值参数信息
	 *        userId：操作员信息
	 *        userId：充值卡号
	 *        amt   ：充值金额
	 *        accBalBef：充值钱卡面余额
	 * @param trCode 交易码
	 */
	@SuppressWarnings("unchecked")
	@Override
	public TrServRec saveHjlWallet(Map<String,Object> map,Integer trCode) throws CommonException{
		try{
			//1.验证充值柜员
			String userId = Tools.processNull(map.get("userId"));
			Users users = validUsers(userId);
			SysBranch branch = (SysBranch) this.findOnlyRowByHql("from SysBranch t where t.brchId = '" + users.getBrchId() + "'");
			//2.验证充值卡号
			String cardNo = Tools.processNull(map.get("cardNo"));
			BasePersonal person = new BasePersonal();
			CardBaseinfo card = validCard(cardNo,true);
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				person = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(person == null){
					person = new BasePersonal();
				}
			}
			AccAccountSub account = acc.getAccSubLedgerByCardNoAndAccKind(card.getCardNo(),Constants.ACC_KIND_QBZH,"00");
			if(account == null){
				throw new CommonException("根据卡号" + card.getCardNo() + ",账户类型" + Constants.ACC_KIND_QBZH + "未找到账户信息！");
			}
			//3.获取充值金额和充值前金额验证充值是否超限
			String cardTypeString = this.getCodeNameBySYS_CODE("CARD_TYPE",card.getCardType());
			String amt = Tools.processNull(map.get("amt"));//充值金额
			String cardAmt = Tools.processNull(map.get("cardAmt"));//充值前卡面余额
			CardConfig cfg = (CardConfig) this.findOnlyRowByHql("from CardConfig t where t.cardType = '" + card.getCardType() + "'");
			if(cfg == null){
				throw new CommonException("该卡类型参数信息未配置，卡类型：" + cardTypeString);
			}
			if(Tools.processNull(cfg.getCashRechgLow()).equals("")){
				throw new CommonException("该卡类型充值最低限额参数未配置，卡类型：" + cardTypeString);
			}
			if(Tools.processNull(cfg.getWalletCaseRechgLmt()).equals("")){
				throw new CommonException("该卡类型充值最高限额参数未配置，卡类型：" + cardTypeString);
			}
			if(cfg.getCashRechgLow() > Long.valueOf(amt)){
				throw new CommonException("充值金额不能小于最低充值金额限制！<span style=\"color:red;\"><br>提示：最小充值金额 " +  Arith.cardreportsmoneydiv(cfg.getCashRechgLow() + "")   + "</span>");
			}
			if(cfg.getWalletCaseRechgLmt() < Long.valueOf(Arith.add(cardAmt,amt))){
				String temperrormsg = "";
				if(Long.valueOf(cardAmt) > cfg.getWalletCaseRechgLmt()){
					temperrormsg = "0.00";
				}else{
					temperrormsg = Arith.cardreportsmoneydiv((cfg.getWalletCaseRechgLmt() - Long.valueOf(cardAmt)) + "");
				}
				throw new CommonException("充值金额不能大于最高充值金额限制！<span style=\"color:red;\"><br>提示：当前最大可充值金额 " + temperrormsg + "</span>");
			}
			if(Long.parseLong(amt)>(cfg.getWalletOneAllowMax()==null ? 0 :cfg.getWalletOneAllowMax())){
				throw new CommonException("单笔充值金额超过最大限制！<span style=\"color:red;\"><br>提示：单笔最大充值金额 " +  Arith.cardreportsmoneydiv(cfg.getWalletOneAllowMax() + "")   + "</span>");
			}
			//4.记录操作日志
			SysActionLog log = (SysActionLog) map.get("actionlog");
			if(log == null){
				throw new CommonException("记录灰记录操作日志不能为空！");
			}
			if(!(log instanceof SysActionLog)){
				throw new CommonException("记录灰记录操作日志不能为空！");
			}
			log.setDealCode(trCode);
			log.setMessage(this.findTrCodeNameByCodeType(trCode) + ",卡号:" + card.getCardNo());
			log.setNote(log.getMessage());
			publicDao.save(log);
			//5.定义充值参数
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("acpt_id",users.getBrchId());//受理网点号
			accMap.put("acpt_type",Constants.ACPT_TYPE_GM);//受理点类型
			accMap.put("tr_batch_no",Tools.processNull(map.get("tr_batch_no")));//终端号编号
			accMap.put("term_tr_no",Tools.processNull(map.get("tr_ser_no")));//终端流水号
			accMap.put("card_no",cardNo);
			accMap.put("card_tr_count",Tools.processNull(map.get("cardTrCount")));
			accMap.put("card_bal",cardAmt);//充值前卡面余额
			accMap.put("acc_kind",Constants.ACC_KIND_QBZH);//钱包账户
			accMap.put("wallet_id","00");
			accMap.put("tr_amt",amt);
			accMap.put("pay_source",Tools.processNull(map.get("paySource")));//充值资金来源0现金1转账2充值卡
			accMap.put("sourcecard",Tools.processNull(map.get("rechargeCardNo")));//充值卡卡号或银行卡卡号或商户clientid
			accMap.put("rechg_pwd",Tools.processNull(map.get("rechargeCardPwd")));
			accMap.put("deal_state",Constants.TR_STATE_HJL);
			accMap.put("customer_id",card.getCustomerId());//客户号
			accMap.put("card_type",card.getCardType());//卡类型
			//6.调用接口记录交易灰记录
            acc.recharge(log,accMap);
            //String rechargegive = Tools.processNull(map.get("rechargegive"));
            //7.记录业务日志
			TrServRec serv = new TrServRec();
			serv.setDealNo(log.getDealNo());//业务流水号
			serv.setDealCode(log.getDealCode());//交易代码
			serv.setCardId(card.getCardId());
			serv.setCardNo(card.getCardNo());//交易主体卡号
			serv.setCardType(card.getCardType());//卡类型
			serv.setCardAmt(1L);
			serv.setAccNo(account.getAccNo().toString());
			serv.setAccKind(Constants.ACC_KIND_QBZH);//交易码就可以识别
			serv.setBizTime(log.getDealTime());//业务办理时间
			serv.setUserId(log.getUserId());//办理操作员编号
			serv.setBrchId(users.getBrchId());//办理业务网点
			serv.setOrgId(users.getOrgId());//办理机构
			serv.setDealState(Constants.TR_STATE_HJL);//业务状态("0"正常 ,"1"撤消",2"冲正"3"退货,"9"灰记录)
			serv.setClrDate(this.getClrDate());//清分日期(YYYY-MM-DD)
			serv.setCustomerId(person.getCustomerId() + "");//客户编号
			serv.setCustomerName(person.getName());//客户姓名
			serv.setCertType(person.getCertType());//证件类型
			serv.setCertNo(person.getCertNo());//证件号码
			serv.setTelNo(person.getMobileNo());//联系方式
			serv.setTermId(Tools.processNull(map.get("term_id")));//终端使用
            if(!Tools.processNull(map.get("cardTrCount")).equals("")){
                serv.setCardTrCount(Tools.processNull(map.get("cardTrCount")));
            }else{
            	serv.setCardTrCount("0");
            }
			serv.setAmt(new Long(amt));//发生金额
			serv.setPrvBal(Long.valueOf(cardAmt));//充值前金额
			serv.setNote(log.getMessage());//备注
			serv.setNum(1l);
			publicDao.save(serv);
			//8.保存凭证
			/*JSONObject json = new JSONObject();
			json.put("p_Actionno",log.getDealNo());//交易流水
			json.put("p_Print_Time1",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd"));
			json.put("p_Rechg_Time",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));
			json.put("p_Yw_Type", this.findTrCodeNameByCodeType(log.getDealCode()));//业务名称
			json.put("p_Client_Name",person.getName());//客户姓名
			json.put("certType",this.getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType()));//证件类型
			json.put("p_Cert_No",person.getCertNo());//证件号
			json.put("cardType",this.getCodeNameBySYS_CODE("CARD_TYPE",serv.getCardType()));//卡类型
			json.put("p_Subcardno",cardNo);
			json.put("p_Cardno",cardNo);
			json.put("p_Prv_Bal",Arith.cardreportsmoneydiv(cardAmt));//充值前金额
			json.put("p_Rechg_Amt",Arith.cardreportsmoneydiv(Tools.processNull(serv.getAmt())));//交易金额
			//json.put("donationAmount",Arith.cardreportsmoneydiv(Tools.processNull(serv.getAmt2())));//送的金额
			json.put("accBalAfter",Arith.cardreportsmoneydiv(Arith.add(cardAmt,amt)));//充值后金额
			//json.put("rechargeCardNo",Tools.processNull(serv.getCard_No2()));//充值卡号
			json.put("p_Acpt_Branch",branch.getFullName());
			json.put("p_Oper_Id",users.getUserId());//操作员
            this.saveSysReport(log,json,"/reportfiles/cashrecharge.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);*/
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportsmoneydiv(Tools.processNull(serv.getAmt() + "")));
			json.put(ReceiptContants.FIELD.CARD_NO, cardNo); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, person.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, person.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.add(cardAmt,amt))); // 充值后账户余额
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(log, json, ReceiptContants.TYPE.CASH_RECHARGE, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
            return serv;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 钱包充值灰记录自动处理
	 * @param inpara
	 * cardNo 充值卡号
	 * cardAmt 卡面金额
	 * cardTrCount 交易计数器
	 * 需要特殊处理可加参数
	 * @return
	 */
	public Long saveAutoWalletAshDeal(Map inpara,Users oper,SysActionLog log) throws CommonException{
		try{
			//1.基本参数判断
			String cardNo = Tools.processNull(inpara.get("cardNo"));
			Long cardAmt = Tools.processLong(inpara.get("cardAmt").toString());
			Long cardTrCount = Tools.processLong(inpara.get("cardTrCount").toString());
			if(Tools.processNull(cardNo).equals("")){
				throw new CommonException("卡号不正确！");
			}
			if(cardAmt == -1){
				throw new CommonException("卡面金额不正确！");
			}
			if(cardTrCount == -1){
				throw new CommonException("卡交易计数器不正确！");
			}
			if(log == null){
				log = this.getCurrentActionLog();
			}
			if(oper == null){
				oper = this.getUser();
			}
			//2.获取需要取消的灰记录
			List allCzHjl = this.findBySql("select t.deal_no from acc_inout_detail t where t.cr_card_no = '" + cardNo + "' and t.deal_state = '" + Constants.TR_STATE_HJL + "' " +
			    "and t.cr_card_bal = " + cardAmt + " and t.cr_card_counter = " + cardTrCount + " and t.deal_code = " + DealCode.RECHARGE_CASH_WALLET
			);
			if(allCzHjl != null && allCzHjl.size() > 0){
				for(int i = 0;i < allCzHjl.size();i++){
					try{
						BigDecimal tempDealNo = (BigDecimal) allCzHjl.get(i);
						Map tempCzMap = new HashMap();
						SysActionLog tempCzLog = (SysActionLog) BeanUtils.cloneBean(log);
						tempCzMap.put("dealNo",tempDealNo.longValue());
						tempCzMap.put("userId",oper.getUserId());
						tempCzMap.put("actionlog",tempCzLog);
						this.saveWalletAshCancel(tempCzMap);
						this.publicDao.doSql("commit");
					}catch(Exception e){
						throw new CommonException(e.getMessage() + "请重新进行查询或手动进行灰记录操作！");
					}
				}
			}
			//3.获取需要确认的灰记录
			BigDecimal qrDealNo = (BigDecimal) this.findOnlyFieldBySql("select t.deal_no from acc_inout_detail t where t.cr_card_no = '" + cardNo + "' and t.deal_state = '" + Constants.TR_STATE_HJL + "' and t.clr_date = '" + getClrDate() + "' " +
			    "and t.cr_card_bal = " + cardAmt + " - t.cr_amt and t.cr_card_counter = " + (cardTrCount - 1) + " and t.deal_code = " + DealCode.RECHARGE_CASH_WALLET + " and t.acpt_id = '" + oper.getBrchId() + "' and t.user_id = '" + oper.getUserId() + "' "
			);
			if(qrDealNo != null){
				Map<String,Object> map = new HashMap<String, Object>();
				map.put("dealNo",qrDealNo.longValue());
				map.put("userId",oper.getUserId());
				SysActionLog tempQrLog = (SysActionLog) BeanUtils.cloneBean(log);
				map.put("actionlog",tempQrLog);
				this.saveWalletAshConfirm(map);
				this.publicDao.doSql("commit");
				return qrDealNo.longValue();
			}else{
				return -1L;
			}
		}catch(Exception e){
			this.publicDao.doSql("rollback");
			throw new CommonException("自动冲正灰记录失败：" + e.getMessage());
		}
	}
	/**
	 * 》》钱包账户现金充值灰记录确认
	 * 》》钱包账户现金充值（撤销）灰记录确认
	 * @param map 参数信息
	 */
	public Long saveWalletAshConfirm(Map<String, Object> map)throws CommonException {
		try{
			//1.验证柜员信息是否正常
			String userId = Tools.processNull(map.get("userId"));
			validUsers(userId);
			//2.根据确认流水获取待确认的记录信息
			String dealNo = Tools.processNull(map.get("dealNo"));
			TrServRec rec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = '" + dealNo + "'");
			if(rec == null){
				throw new CommonException("确认灰记录发生错误：根据流水：" + dealNo + "，未查询到对应待确认的记录信息！");
			}
			if(!Tools.processNull(rec.getDealState()).equals(Constants.TR_STATE_HJL)){
				throw new CommonException("确认灰记录发生错误：该流水：" + dealNo + "，不是未确认状态！");
			}
			//3.记录确认的操作日志信息
			SysActionLog actionLog = (SysActionLog) map.get("actionlog");
			if(actionLog == null){
				throw new CommonException("确认灰记录发生错误：操作日志不能为空！");
			}
			if(!(actionLog instanceof SysActionLog)){
				throw new CommonException("确认灰记录发生错误：操作日志不能为空！");
			}
			//4.构建参数信息,调取存储过程 p_rechargeconfirm_onerow
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("deal_no",dealNo);//原来交易序列
			accMap.put("clr_date",rec.getClrDate());//原来分清日期
			accMap.put("card_no",rec.getCardNo());//原交易卡号
			acc.rechargeConfirm(actionLog,accMap);
			//5.撤销类的确认确认,需要进行一下处理,电子钱包充值撤销灰记录确认
			if(!Tools.processNull(rec.getOldDealNo()).equals("")){
				//记录灰记录的时候已经撤销
			}
			//6.更新待确认的灰记录，改为”正确“状态
			int updatecount = publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_ZC + "' ,t.clr_date = '" + this.getClrDate() + "' where t.deal_no = " + dealNo);
			if(updatecount != 1){
				throw new CommonException("确认灰记录发生错误：确认业务日志时更新" + updatecount + "行");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
		return null;
	}
	/**
	 * 》》钱包账户现金充值灰记录冲正
	 * 》》钱包账户现金充值（撤销）灰记录冲正
	 */
	@SuppressWarnings("rawtypes")
	public JSONObject saveWalletAshCancel(Map map) throws CommonException {
		try {
			//1.验证柜员信息是否正常
			String userId = Tools.processNull(map.get("userId"));
			validUsers(userId);
			//2.根据流水获取待冲正记录信息
			String dealNo = Tools.processNull(map.get("dealNo"));
			TrServRec rec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = '" + dealNo + "'");
			if(rec == null){
				throw new CommonException("冲正发生错误：根据流水：" + dealNo + "，未查询到对应记录，不能进行冲正！");
			}
			//3.构建参数信息,调取存储过程
			SysActionLog actionLog = (SysActionLog) map.get("actionlog");
			if(actionLog == null){
				throw new CommonException("冲正发生错误：操作日志不能为空！");
			}
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("deal_no",dealNo);//原来交易序列
			accMap.put("clr_date",rec.getClrDate());//原来分清日期
			accMap.put("card_no",rec.getCardNo());//原交易卡号
			accMap.put("deal_state",Constants.TR_STATE_HJL);//原充值记录状态
			accMap.put("card_tr_count",Tools.processNull(rec.getCardTrCount()));
			accMap.put("card_bal",Tools.processNull(rec.getPrvBal()));  
			acc.rechargeCancel(actionLog,accMap);
			//4.将原记录改为冲正状态
			int updatecount = publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CZ+ "' ,t.clr_date = '" + this.getClrDate() + "' where t.deal_no = " + dealNo);
			if(updatecount != 1){
				throw new CommonException("冲正发生错误：冲正业务日志时更新" + updatecount + "行！");
			}
			//5.如果是撤销类撤销需要修改原记录的状态
			if(!Tools.processNull(rec.getOldDealNo()).equals("")){
				updatecount = 0;
				updatecount = publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_ZC + "' where t.deal_no = " + rec.getOldDealNo());
				if(updatecount != 1){
					throw new CommonException("冲正发生错误：冲正业务日志时更新" + updatecount + "行！");
				}
			}
			//6.删除记录灰记录时记录的凭证
			publicDao.doSql("delete from sys_report t where t.deal_no = " + dealNo);
		} catch (Exception e) {
			throw new CommonException(e);
		}
		return null;
	}
	/**
	 * 》》钱包账户现金充值撤销（写灰记录）
	 * 》》联机账户现金充值撤销（直接确认）
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public TrServRec saveAccRechargeRevoke(Map hm,Integer trCode) throws CommonException{
		try{
			//1.验证柜员是否存在
			String userId = Tools.processNull(hm.get("userId"));
			Users users = validUsers(userId);
			SysBranch branch = (SysBranch) this.findOnlyRowByHql("from SysBranch t where t.brchId = '" + users.getBrchId() + "'");
            //2.根据撤销流水获取待撤销记录信息
            String dealNo = Tools.processNull(hm.get("dealNo"));
			TrServRec oldRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = '" + dealNo + "'");
			TrServRec rec = (TrServRec) BeanUtils.cloneBean(oldRec);
			if(rec == null){
				throw new CommonException("根据传入的充值流水:" + dealNo + "未找到有效的充值日志信息，无法进行撤销！");
			}
			if(!Tools.processNull(rec.getDealState()).equals("0")){
				throw new CommonException("记录不是正常状态，无法进行撤销！");
			}
			
			// 验尾箱
			CashBox box = (CashBox) findOnlyRowByHql("from CashBox where userId = '" + userId + "'");
			if (box == null) {
				throw new CommonException("柜员【" + userId + "】尾箱不存在！");
			} else {
				long bal = box.getTdBlc() - box.getFrzAmt();
				if (bal < rec.getAmt()) {
					throw new CommonException("柜员【" + userId + "】尾箱不足！");
				}
			}
			
			//3.获取待撤销记录的账户信息
			AccAccountSub account = acc.getAccSubLedgerByCardNoAndAccKind(rec.getCardNo(),rec.getAccKind(),"00");
			if(account == null){
				throw new CommonException("撤销记录出现错误，账户信息不存在！");
			}
			if(rec.getDealNo() == null){
				throw new CommonException("根据传入的充值流水:" + dealNo + "未找到有效的充值日志信息，无法进行撤销！");
			}
			if(!(trCode.intValue() == DealCode.RECHARGE_CASH_PRESTORE.intValue() || trCode.intValue() == DealCode.RECHARGE_BANK_PRESTORE.intValue())){
				//验证卡状态是否正常
				//validCard(rec.getCardNo(),false);
			}
			if(account.getBal() < rec.getAmt()){
				throw new CommonException("账户余额不足！");
			}
			//4.记录撤销的操作日志信息
			SysActionLog log = (SysActionLog) hm.get("actionlog");
			if(log == null){
				throw new CommonException("充值撤销操作日志不能为空！");
			}
			if(!(log instanceof SysActionLog)){
				throw new CommonException("充值撤销操作日志不能为空！");
			}
			log.setDealCode(trCode);
			log.setMessage(findTrCodeNameByCodeType(log.getDealCode()) + ",原交易流水:" + dealNo);
			publicDao.save(log);
			//5.构建撤销的参数信息，调取存储过程
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("deal_no",dealNo);//原来交易序列
			accMap.put("clr_date",rec.getClrDate());//原来分清日期
			accMap.put("card_no",rec.getCardNo());//原交易卡号
			accMap.put("deal_state",rec.getDealState());//原来交易状态
			accMap.put("card_tr_count",Tools.processNull(hm.get("cardTrCount")));//撤销前计数器
			accMap.put("card_bal",(rec.getAccKind().equals(Constants.ACC_KIND_ZJZH) ? account.getBal() + "" : Tools.processNull((hm.get("cardAmt")))));//撤销前金额
			acc.rechargeCancel(log,accMap);//进行撤销
			//4.修改原记录状态为“撤销”,充值记录撤销,在记录灰记录的时候就会把原记录撤销掉,但是如果撤销失败,在冲正时也要记得在把原记录修改掉
			int updatecount = publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CX + "' where t.deal_no = " + dealNo);
			if(updatecount != 1){
				throw new CommonException("撤销失败，撤销业务日志时更新" + updatecount + "行！");
			}
			//5.记录业务日志信息
			rec.setDealNo(log.getDealNo());//新的撤销流水
			rec.setCardAmt(1L);
			rec.setDealCode(trCode);//交易代码
			rec.setBizTime(log.getDealTime());//业务办理时间
			rec.setUserId(log.getUserId());//办理操作员编号
			rec.setBrchId(users.getBrchId());
			rec.setOldDealNo(Tools.processLong(dealNo));
            if(!Tools.processNull(hm.get("cardTrCount")).equals("")){
            	rec.setCardTrCount(Tools.processNull(hm.get("cardTrCount")));
            }else{
            	rec.setCardTrCount("0");
            }
            Long amt = rec.getAmt() == null ? 0 : rec.getAmt();//发生额
            rec.setAmt(new Long(Arith.sub("0",Tools.processNull(amt))));//发生金额
            rec.setDealState(Constants.TR_STATE_HJL);//记录撤销灰记录
            rec.setNote(log.getMessage());//备注
            if((oldRec.getDealCode() + "").equals(DealCode.RECHARGE_CASH_ACC + "")){//联机撤销
            	rec.setPrvBal(account.getBal());
            }else{//脱机撤销取卡片余额
            	Long prv_bal = hm.get("cardAmt") == null ? 0 : Tools.processLong((String)hm.get("cardAmt")) ;
            	rec.setPrvBal(prv_bal);
            }
            rec.setClrDate(this.getClrDate());
            if(!Tools.processNull(hm.get("zgOperId")).equals("")){
            	Users zg = (Users) this.findOnlyRowByHql("from Users t where t.userId = '" + hm.get("zgOperId").toString() + "' and t.status = 'A'");
    			if(zg == null){
    				throw new CommonException("业务授权人信息不存在或已注销！");
    			}
            	rec.setGrtUserId(hm.get("zgOperId").toString());//撤销业务授权人
            	rec.setGrtUserName(zg.getName());//撤销业务授权人
            }
            JSONObject jsonobject = new JSONObject();
            jsonobject.put("p_Title",Constants.APP_REPORT_TITLE + this.findTrCodeNameByCodeType(rec.getDealCode()) + "凭证");//交易流水
            jsonobject.put("p_Deal_No",log.getDealNo());
            jsonobject.put("p_Accept_Time",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));
            jsonobject.put("p_Card_No",rec.getCardNo());
            String subCardNo = (String) findOnlyFieldBySql("select sub_card_no from card_baseinfo where card_no = '" + rec.getCardNo() + "'");
			jsonobject.put("p_Social_Security_Card_No",subCardNo );
            jsonobject.put("p_Deal_Type", this.findTrCodeNameByCodeType(log.getDealCode()));//业务名称
            jsonobject.put("p_Customer_Name",rec.getCustomerName());
            jsonobject.put("p_Customer_Certificate_Type", getCodeNameBySYS_CODE("CERT_TYPE", rec.getCertType()));
            jsonobject.put("p_Customer_Certificate_No", rec.getCertNo());
            jsonobject.put("p_Cancel_Amt",Arith.cardreportsmoneydiv(Tools.processNull(Math.abs(rec.getAmt()))));//撤销金额
            jsonobject.put("p_Acc_bal",Arith.cardreportsmoneydiv(Arith.sub(Tools.processLong(rec.getPrvBal()),Tools.processLong(Math.abs(rec.getAmt())))));//充值后金额
            jsonobject.put("p_Accept_Branch_Name",branch.getFullName());
            jsonobject.put("p_Accept_User_Id",users.getUserId());
            jsonobject.put("p_Accept_User_Name",users.getName());
            this.saveSysReport(log,jsonobject,"/reportfiles/cashrechargecancel.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
            if(!Constants.ACC_KIND_QBZH.equals(Tools.processNull(rec.getAccKind()))){
            	accMap.clear();
            	accMap.put("deal_no", Tools.processNull(log.getDealNo()));//原来交易序列
    			accMap.put("clr_date",rec.getClrDate());//原来分清日期
    			accMap.put("card_no",rec.getCardNo());//原交易卡号
            	acc.rechargeConfirm(log,accMap);
				//修改新的撤销记录为正常模式
				rec.setDealState(Constants.TR_STATE_ZC);
            }
            //this.saveTr_Serv_Rec(rec);
            publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 》》联机账户现金充值
	 * @param hm     现金联机充值参数信息
	 * @param trCode 交易码
	 * @return
	 */
	@SuppressWarnings({ "unchecked","rawtypes" })
	@Override
	public TrServRec saveOnlineAccRecharge(Map hm, Integer trCode)throws CommonException {
		try {
			//1.验证柜员是否存在
			String userId = Tools.processNull(hm.get("userId"));
			Users users = validUsers(userId);
			SysBranch branch = (SysBranch) this.findOnlyRowByHql("from SysBranch t where t.brchId = '" + users.getBrchId() + "'");
			//2.卡状态验证
			String cardNo = Tools.processNull(hm.get("cardNo"));
			CardBaseinfo card = validCard(cardNo,false);
			BasePersonal person = new BasePersonal();
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				person = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(person == null){
					person = new BasePersonal();
				}
			}
			//3.获取充值金额和充值前金额验证充值是否超限
			String cardTypeString = this.getCodeNameBySYS_CODE("CARD_TYPE",card.getCardType());
			String amt = Tools.processNull(hm.get("amt"));//充值金额
			CardConfig cfg = (CardConfig) this.findOnlyRowByHql("from CardConfig t where t.cardType = '" + card.getCardType() + "'");
			if(cfg == null){
				throw new CommonException("该卡类型参数信息未配置，卡类型：" + cardTypeString);
			}
			if(Tools.processNull(cfg.getCashRechgLow()).equals("")){
				throw new CommonException("该卡类型联机账户充值最低限额参数未配置，卡类型：" + cardTypeString);
			}
			if(Tools.processNull(cfg.getAccCaseRechgLmt()).equals("")){
				throw new CommonException("该卡类型联机账户充值最高限额参数未配置，卡类型：" + cardTypeString);
			}
			if(cfg.getCashRechgLow() > Long.valueOf(amt)){
				throw new CommonException("充值金额不能小于最低充值金额限制！<span style=\"color:red;\"><br>提示：最小充值金额 " +  Arith.cardreportsmoneydiv(cfg.getCashRechgLow() + "")   + "</span>");
			}
			AccAccountSub account = acc.getAccSubLedgerByCardNoAndAccKind(card.getCardNo(),Constants.ACC_KIND_ZJZH,"00");
			if(account == null){
				throw new CommonException("根据卡号" + card.getCardNo() + ",账户类型" + Constants.ACC_KIND_ZJZH + "未找到账户信息！");
			}
			if(cfg.getAccCaseRechgLmt() < (account.getBal() + Long.valueOf(amt))){
				throw new CommonException("充值金额不能大于最高充值金额限制！<br><span style=\"color:red;\">提示：当前最大可充值金额 " +  Arith.cardreportsmoneydiv((cfg.getAccCaseRechgLmt() - account.getBal()) + "")   + "</span>");
			}
			if(Long.parseLong(amt)>(cfg.getAccOneAllowMax()==null?0:cfg.getAccOneAllowMax())){
				throw new CommonException("单笔充值金额超过最大限制！<span style=\"color:red;\"><br>提示：单笔最大充值金额 " +  Arith.cardreportsmoneydiv(cfg.getAccOneAllowMax() + "")   + "</span>");
			}
			//4.记录操作日志
			SysActionLog log = (SysActionLog) hm.get("actionlog");
			if(log == null){
				throw new CommonException("记录灰记录操作日志不能为空！");
			}
			if(!(log instanceof SysActionLog)){
				throw new CommonException("记录灰记录操作日志不能为空！");
			}
			log.setDealCode(trCode);
			log.setMessage(this.findTrCodeNameByCodeType(trCode) + ",卡号:" + card.getCardNo());
			log.setNote(log.getMessage());
			publicDao.save(log);
			//5.调接口记录交易
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("acpt_id",users.getBrchId());//受理网点号
			accMap.put("acpt_type",Constants.ACPT_TYPE_GM);//1网点
			accMap.put("card_no",cardNo);
			accMap.put("card_tr_count","");
			accMap.put("card_bal","");
			accMap.put("acc_kind",Constants.ACC_KIND_ZJZH);//联机账户
			accMap.put("wallet_id","00");
			accMap.put("tr_amt",amt);
			accMap.put("deal_state",Constants.TR_STATE_ZC);
			accMap.put("pay_source",Tools.processNull(hm.get("paySource")));//充值资金来源0现金1转账2充值卡
			accMap.put("sourcecard",Tools.processNull(hm.get("rechargeCardNo")));
			accMap.put("rechg_pwd",Tools.processNull(hm.get("rechargeCardPwd")));
			accMap.put("client_id",card.getCustomerId());//客户号
			accMap.put("card_type",card.getCardType());//卡类型
			accMap.put("acc_bal",account.getBal() + "");//卡类型
            acc.recharge(log,accMap);
            //String rechargegive = Tools.processNull(map.get("rechargegive"));
			//6.登记业务信息（TR_SERV_REC）
			TrServRec serv = new TrServRec();
			serv.setDealNo(log.getDealNo());//业务流水号
			serv.setDealCode(trCode.intValue());//交易代码
			serv.setCardNo(card.getCardNo());//交易主体卡号
			serv.setCardType(card.getCardType());//卡类型
			serv.setAccKind(Constants.ACC_KIND_ZJZH);//账户类型
			serv.setBizTime(log.getDealTime());//业务办理时间
			serv.setUserId(log.getUserId());//办理操作员编号
			serv.setBrchId(users.getBrchId());
			serv.setAccNo(account.getAccNo() + "");
			serv.setCardAmt(1L);
			serv.setCardId(card.getCardId());
			serv.setNum(1l);
			//serv.setOrg_Id(users.getOrgId());
			serv.setDealState(Constants.TR_STATE_ZC);//业务状态("0"正常 ,"1"撤消",2"冲正"3"退货,"9"灰记录)
			serv.setClrDate(this.getClrDate());//清分日期(YYYY-MM-DD)
			if(!Tools.processNull(hm.get("rechargeCardNo")).equals("")){
				//serv.setCard_No2(rechargecard.getCard_No());//充值卡卡号
				//serv.setCard_Type2(rechargecard.getCard_Type());//充值卡类型
			}
			serv.setCustomerId(person.getCustomerId() + "");
			serv.setCustomerName(person.getName());
			serv.setCertType(person.getCertType());
			serv.setCertNo(person.getCertNo());
			serv.setTelNo(person.getMobileNo());
			serv.setPrvBal(account.getBal());
			//serv.setAcptType(Constants.ACPT_TYPE_GM);
			serv.setAmt(new Long(amt));//发生金额
			serv.setNote(log.getMessage());//备注
			//7.保存凭证	
			/*JSONObject json=new JSONObject();
			json.put("p_Actionno",log.getDealNo());
			json.put("p_Print_Time1",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd"));
			json.put("p_Rechg_Time",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));
			json.put("p_Yw_Type", this.findTrCodeNameByCodeType(trCode));//业务名称
			json.put("p_Client_Name", serv.getCustomerName());
			json.put("certType", this.getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType()));//证件类型
			json.put("p_Cert_No", person.getCertNo());//证件号
			json.put("cardType",this.getCodeNameBySYS_CODE("CARD_TYPE", serv.getCardType()));
			json.put("p_Subcardno", cardNo);
			json.put("p_Cardno", cardNo);
			json.put("p_Prv_Bal",Arith.cardreportsmoneydiv(account.getBal() + ""));
			json.put("p_Rechg_Amt",Arith.cardreportsmoneydiv(Tools.processNull(serv.getAmt())));
			//json.put("donationAmount",Arith.cardreportsmoneydiv(Tools.processNull(serv.getAmt2())));//送的金额
			json.put("accBalAfter",Arith.cardreportsmoneydiv(Arith.add(account.getBal() + "",amt)));
			//json.put("rechargeCardNo",Tools.processNull(serv.getCard_No2()));//充值卡号
			json.put("p_Acpt_Branch", branch.getFullName());
			json.put("p_Oper_Id",userId);
			this.saveSysReport(log,json,"/reportfiles/cashrecharge.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);*/
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportsmoneydiv(serv.getAmt() + ""));
			json.put(ReceiptContants.FIELD.CARD_NO, cardNo); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, person.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, person.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.add(account.getBal() + "", amt))); // 充值后账户余额
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(log, json, ReceiptContants.TYPE.CASH_RECHARGE, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			publicDao.save(serv);
			return serv;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	
	/**
	 * 》》联机账户转联机账户
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveTransferOnlineAcc2OnlineAcc(Map<String,Object> initparameters) throws CommonException{
		try{
			//1.转账：转出卡、转入卡判断
			if(Tools.processNull(initparameters.get("outCardNo")).equals(Tools.processNull(initparameters.get("inCardNo")))){
				throw new CommonException("转出卡和转入卡不能是同一卡号！");
			}
			//2.判断转出卡信息
			String outCardNo = initparameters.get("outCardNo").toString();
			CardBaseinfo outCard = null;
			if(Tools.processNull(outCardNo).trim().equals("")){
				throw new CommonException("转出卡号不能空！");
			}else{
				outCard = validCard(outCardNo,false);
			}
			BasePersonal outPerson = null;
			if(!Tools.processNull(outCard.getCustomerId()).equals("")){
				outPerson = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + outCard.getCustomerId() + "'");
				if(outPerson == null){
					outPerson = new BasePersonal();
				}
			}
			//3.判断转入卡信息
			String inCardNo = initparameters.get("inCardNo").toString();
			CardBaseinfo inCard = null;
			if(Tools.processNull(inCardNo).trim().equals("")){
				throw new CommonException("转入卡号不能空！");
			}else{
				inCard = validCard(inCardNo,false);
			}
			BasePersonal inPerson = null;
			if(!Tools.processNull(inCard.getCustomerId()).equals("")){
				inPerson = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + inCard.getCustomerId() + "'");
				if(inPerson == null){
					inPerson = new BasePersonal();
				}
			}
			//4.操作员判断
			Users oper = (Users) initparameters.get("oper");
			if(oper == null || !(oper instanceof Users)){
				throw new CommonException("账户转账操作柜员不能为空！");
			}
			oper = validUsers(oper.getUserId());
			//5.转账金额判断
			Long amt = (Tools.processNull(initparameters.get("amt")).trim().equals("") ? 0L : Long.valueOf(initparameters.get("amt").toString().trim()));
			if(amt == 0L){
				throw new CommonException("转账金额不能为空或是0");
			}
			if(Tools.processNull(initparameters.get("outAccKind")).equals("")){
				throw new CommonException("转出卡转出账户类型不能为空！");
			}
			//6.转账转出卡密码判断
			/*if(Tools.processNull(initparameters.get("pwd")).trim().equals("")){
				throw new CommonException("转出卡转出账户密码不能为空！");
				}
			if(Tools.processNull(outCard.getPayPwd()).equals("")){
				throw new CommonException("转出卡转出账户密码信息不存在，请先设置联机账户密码信息！");
			}*/
			//String ecrpwd = doWorkClientService.encrypt_PinPwd(outCard.getCardNo(),initparameters.get("pwd").toString());
			//4.判断转账金额是否大于转出卡账户余额
			AccAccountSub outAcc = acc.getAccSubLedgerByCardNoAndAccKind(outCardNo,initparameters.get("outAccKind").toString(),"00");
			if(outAcc == null){
				throw new CommonException("转出卡转出账户信息不存在！");
			}
			if(amt > outAcc.getBal()){
				throw new CommonException("转出卡转出账户余额不足！");
			}
			//5.转账转入卡账户判断
			AccAccountSub inAcc = acc.getAccSubLedgerByCardNoAndAccKind(inCardNo,initparameters.get("inAccKind").toString(),"00");
			if(inAcc == null){
				throw new CommonException("转入卡转入账户信息不存在！");
			}
			//6.判断转入卡转账后是否大于账户限额
			CardConfig cfg = (CardConfig) this.findOnlyRowByHql("from CardConfig t where t.cardType = '" + inCard.getCardType() + "'");
			if(cfg == null){
				throw new CommonException("转入卡卡类型参数信息不存在！");
			}
			if(Tools.processNull(cfg.getAccCaseRechgLmt()).equals("")){
				throw new CommonException("转入卡卡类型账户限额信息不存在！");
			}
			if(Long.valueOf(Arith.add(inAcc.getBal() + "",amt + "")) > cfg.getAccCaseRechgLmt()){
				throw new CommonException("转入卡转账后账户余额大于该卡类型账户限额！");
			}
			//7.插入操作日志信息
			SysActionLog actionlog = (SysActionLog) initparameters.get("actionlog");
			if(actionlog == null || !(actionlog instanceof SysActionLog)){
				throw new CommonException("账户转账操作日志不能为空！");
			}
			actionlog.setDealCode(DealCode.RECHARGE_ACC_ACC);
			actionlog.setMessage("联机账户转账,转出卡:" + outCardNo + " , 转入卡:" + inCardNo + " , 转账金额:" + Arith.cardmoneydiv(initparameters.get("amt").toString()));
			publicDao.save(actionlog);
			//8.调存储过程
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("acpt_id",oper.getBrchId());//
			accMap.put("acpt_type",Constants.ACPT_TYPE_GM);//0商户  1网点  柜面的为网点,终端的为商户
			accMap.put("tr_batch_no","");
			accMap.put("term_tr_no","");
			accMap.put("card_no1",outCardNo);
			accMap.put("acc_kind1",initparameters.get("outAccKind").toString());//联机账户
			accMap.put("wallet_id1","00");
			accMap.put("card_no2",inCardNo);
			accMap.put("acc_kind2",initparameters.get("inAccKind").toString());//联机账户
			accMap.put("wallet_id2","00");
			accMap.put("tr_amt",amt +"");
			accMap.put("tr_state",Constants.TR_STATE_ZC);
			//accMap.put("pwd",ecrpwd);//转出卡账户密文密码
			acc.transfer(actionlog,accMap);
			//9.转账记录综合业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionlog.getDealNo());
			rec.setDealCode(actionlog.getDealCode());
			rec.setAmt(amt);
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(actionlog.getDealTime());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setCardNo(outCard.getCardNo());
			rec.setCardAmt(1L);
			rec.setCardId(outCard.getCardId());
			rec.setCardType(outCard.getCardType());
			rec.setClrDate(this.getClrDate());
			rec.setAccKind(initparameters.get("outAccKind").toString());
			rec.setAccNo(outAcc.getAccNo() + "");
			rec.setCustomerId(outPerson.getCustomerId() + "");
			rec.setCustomerName(outPerson.getName());
			rec.setPrvBal(outAcc.getBal());
			rec.setTelNo(outPerson.getMobileNo());
			rec.setInCardNo(inCardNo);
			rec.setInAccNo(inAcc.getAccNo() + "");
			rec.setAgtTelNo(outPerson.getMobileNo());
			rec.setNote(actionlog.getMessage());
			publicDao.save(rec);
			//10.记录报表信息
			//SysBranch branch = (SysBranch) this.findOnlyRowByHql("from SysBranch t where t.brchId = '" + oper.getBrchId() + "'");
			/*JSONObject report = new JSONObject();
			report.put("p_Actionno",rec.getDealNo());
			report.put("p_Title",Constants.APP_REPORT_TITLE + this.findTrCodeNameByCodeType(rec.getDealCode()) + "凭证");
			report.put("p_Card_No1",outCardNo);//转出卡卡号
			report.put("p_Emp_Name1",outPerson.getName());
			report.put("p_Brch",branch.getFullName());//受理网点
			report.put("p_Card_No2",inCardNo);//转入卡卡号
			report.put("p_Emp_Name2",inPerson.getName());
			report.put("p_Oper_Time",DateUtil.formatDate(rec.getBizTime(),"yyyy-MM-dd HH:mm:ss"));
			report.put("tel",Arith.cardreportsmoneydiv(Arith.sub(outAcc.getBal() + "",amt + "")));//转出卡余额
			report.put("agtTel","0.00");
			report.put("p_Amt",Arith.cardreportsmoneydiv(amt +""));
			report.put("p_Oper_Id",oper.getUserId());
			this.saveSysReport(actionlog,report,"/reportfiles/transferonlineacc.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);*/
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, rec.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(rec.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportsmoneydiv(amt + "")); // 交易金额
			json.put(ReceiptContants.FIELD.IN_CARD_NO, inCardNo); // 转入卡号
			json.put(ReceiptContants.FIELD.IN_CUSTOMER_NAME, inPerson.getName()); // 转入客户姓名
			json.put(ReceiptContants.FIELD.OUT_CARD_NO, outCard.getCardNo()); // 转出卡号
			json.put(ReceiptContants.FIELD.OUT_CUSTOMER_NAME, outPerson.getName()); // 转出客户姓名
			json.put(ReceiptContants.FIELD.OUT_CUSTOMER_CERTIFICATE_NO, outPerson.getCertNo()); // 转出客户证件号码
			json.put(ReceiptContants.FIELD.IN_ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.add(inAcc.getBal() + "", amt + ""))); // 转入卡余额
			json.put(ReceiptContants.FIELD.OUT_ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.sub(outAcc.getBal() + "", amt + ""))); // 转出卡余额
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员工姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(actionlog.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(actionlog, json, ReceiptContants.TYPE.TRANSFER_ACCOUNTS, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 联机账户转钱包账户写灰记录
	 * @param initparameters
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveTransferOnlineAcc2OfflineAcc(Map<String,Object> initparameters) throws CommonException{
		try{
			//1.转账卡号是否相同
			/*if(Tools.processNull(initparameters.get("outCardNo")).equals(Tools.processNull(initparameters.get("inCardNo")))){
				throw new CommonException("转出卡和转入卡不能是同一卡号！");
			}*/
			//2.验证转出卡信息
			String outCardNo = initparameters.get("outCardNo").toString();
			CardBaseinfo outCard = null;
			if(Tools.processNull(outCardNo).trim().equals("")){
				throw new CommonException("转出卡号不能空！");
			}else{
				outCard = validCard(outCardNo,false);
			}
			BasePersonal outPerson = null;
			if(!Tools.processNull(outCard.getCustomerId()).equals("")){
				outPerson = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + outCard.getCustomerId() + "'");
				if(outPerson == null){
					outPerson = new BasePersonal();
				}
			}
			//3.验证转入卡信息
			String inCardNo = initparameters.get("inCardNo").toString();
			CardBaseinfo inCard = null;
			if(Tools.processNull(inCardNo).trim().equals("")){
				throw new CommonException("转入卡号不能空！");
			}else{
				inCard = validCard(inCardNo, true);
			}
			BasePersonal inPerson = null;
			if(!Tools.processNull(inCard.getCustomerId()).equals("")){
				inPerson = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + inCard.getCustomerId() + "'");
				if(inPerson == null){
					inPerson = new BasePersonal();
				}
			}
			//4.验证操作柜员信息
			Users oper = (Users) initparameters.get("oper");
			if(oper == null || !(oper instanceof Users)){
				throw new CommonException("账户转账操作柜员不能为空！");
			}
			oper = validUsers(oper.getUserId());
			//5.转账金额判断
			Long amt = (Tools.processNull(initparameters.get("amt")).trim().equals("") ? 0L : Long.valueOf(initparameters.get("amt").toString().trim()));
			if(amt == 0L){
				throw new CommonException("转账金额不能为空或是0");
			}
			if(Tools.processNull(initparameters.get("outAccKind")).equals("")){
				throw new CommonException("转出卡转出账户类型不能为空！");
			}
			if(Tools.processNull(initparameters.get("inAccKind")).equals("")){
				throw new CommonException("转入卡转入账户类型不能为空！");
			}
			//6.转账转出卡密码判断
			if(Tools.processNull(initparameters.get("pwd")).trim().equals("")){
				throw new CommonException("转出卡转出账户密码不能为空！");
			}
			if(Tools.processNull(outCard.getPayPwd()).equals("")){
				throw new CommonException("转出卡转出账户密码信息不存在，请先设置联机账户密码信息！");
			}
			String ecrpwd = doWorkClientService.encrypt_PinPwd(outCard.getCardNo(),initparameters.get("pwd").toString());
			//7.判断转账金额是否大于转出卡账户余额
			AccAccountSub outAcc = acc.getAccSubLedgerByCardNoAndAccKind(outCardNo,initparameters.get("outAccKind").toString(),"00");
			if(outAcc == null){
				throw new CommonException("转出卡转出账户信息不存在！");
			}
			if(amt > outAcc.getBal()){
				throw new CommonException("转出卡转出账户余额不足！");
			}
			//8.转账转入卡账户判断
			AccAccountSub inAcc = acc.getAccSubLedgerByCardNoAndAccKind(inCardNo,initparameters.get("inAccKind").toString(),"00");
			if(inAcc == null){
				throw new CommonException("转入卡转入账户信息不存在！");
			}
			//9.判断转入卡转账后是否大于账户限额
			CardConfig cfg = (CardConfig) this.findOnlyRowByHql("from CardConfig t where t.cardType = '" + inCard.getCardType() + "'");
			if(cfg == null){
				throw new CommonException("转入卡卡类型参数信息不存在！");
			}
			if(Tools.processNull(cfg.getWalletCaseRechgLmt()).equals("")){
				throw new CommonException("转入卡卡类型账户限额信息不存在！");
			}
			if(Long.valueOf(Arith.add(initparameters.get("inAccBal").toString(),amt + "")) > cfg.getWalletCaseRechgLmt()){
				throw new CommonException("转入卡转账后账户余额大于该卡类型账户限额！");
			}
			//10.插入操作日志信息
			SysActionLog actionlog = (SysActionLog) initparameters.get("actionlog");
			if(actionlog == null || !(actionlog instanceof SysActionLog)){
				throw new CommonException("账户转账操作日志不能为空！");
			}
			actionlog.setDealCode(DealCode.RECHARGE_ACC_WALLET);
			actionlog.setMessage("联机转脱机,转出卡:" + outCardNo + " , 转入卡:" + inCardNo + " , 转账金额:" + Arith.cardmoneydiv(initparameters.get("amt").toString()));
			publicDao.save(actionlog);
			//11.调存储过程
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("acpt_id",oper.getBrchId());//
			accMap.put("acpt_type",Constants.ACPT_TYPE_GM);//0商户  1网点  柜面的为网点,终端的为商户
			accMap.put("tr_batch_no","");
			accMap.put("term_tr_no","");
			accMap.put("card_no1",outCardNo);//转出卡卡号
			accMap.put("card_tr_count1","");//转出卡卡交易序列号
			accMap.put("card_bal1","");//转出卡卡面金额
			accMap.put("acc_kind1",initparameters.get("outAccKind").toString());//转出卡账户类型,联机账户
			accMap.put("wallet_id1","00");
			accMap.put("card_no2",inCardNo);
			accMap.put("card_bal2",initparameters.get("inAccBal").toString());//转账前转入卡卡片金额
			accMap.put("acc_kind2",initparameters.get("inAccKind").toString());//转入账户类型
			accMap.put("tr_amt",amt +"");
			accMap.put("wallet_id2","00");
			accMap.put("tr_state",Constants.TR_STATE_HJL);
			accMap.put("pwd",ecrpwd);//转出卡账户密文密码
			acc.transfer(actionlog,accMap);
			//12.转账记录综合业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionlog.getDealNo());
			rec.setDealCode(actionlog.getDealCode());
			rec.setAmt(amt);
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(actionlog.getDealTime());
			rec.setDealState(Constants.TR_STATE_HJL);
			rec.setCardNo(outCard.getCardNo());
			rec.setCardAmt(1L);
			rec.setCardId(outCard.getCardId());
			rec.setCardType(outCard.getCardType());
			rec.setClrDate(this.getClrDate());
			rec.setAccKind(initparameters.get("outAccKind").toString());
			rec.setAccNo(outAcc.getAccNo() + "");
			rec.setCustomerId(outPerson.getCustomerId() + "");
			rec.setCustomerName(outPerson.getName());
			rec.setPrvBal(Long.valueOf(initparameters.get("inAccBal").toString()));//TODO 记录转出卡联机账户转账前金额 难呀,怎么改下呢
			rec.setTelNo(outPerson.getMobileNo());
			rec.setInCardNo(inCardNo);
			rec.setInAccNo(inAcc.getAccNo() + "");
			rec.setAgtTelNo(outPerson.getMobileNo());
			rec.setNote(actionlog.getMessage());
			publicDao.save(rec);
			//13.记录报表信息
			/*SysBranch branch = (SysBranch) this.findOnlyRowByHql("from SysBranch t where t.brchId = '" + oper.getBrchId() + "'");
			JSONObject report = new JSONObject();
			report.put("p_Actionno",rec.getDealNo());
			report.put("p_Title",Constants.APP_REPORT_TITLE + this.findTrCodeNameByCodeType(rec.getDealCode()) + "凭证");
			report.put("p_Card_No1",outCardNo);//转出卡卡号
			report.put("p_Emp_Name1",outPerson.getName());
			report.put("p_Brch",branch.getFullName());//受理网点
			report.put("p_Card_No2",inCardNo);//转入卡卡号
			report.put("p_Emp_Name2",inPerson.getName());
			report.put("p_Oper_Time",DateUtil.formatDate(rec.getBizTime(),"yyyy-MM-dd HH:mm:ss"));
			report.put("tel",Arith.cardreportsmoneydiv(Arith.sub(outAcc.getBal() + "",amt + "")));//转出卡余额
			report.put("agtTel","0.00");
			report.put("p_Amt",Arith.cardreportsmoneydiv(amt +""));
			report.put("p_Oper_Id",oper.getUserId());
			this.saveSysReport(actionlog,report,"/reportfiles/transferonlineacc.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);*/
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, rec.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(rec.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportsmoneydiv(amt + "")); // 交易金额
			json.put(ReceiptContants.FIELD.IN_CARD_NO, inCardNo); // 转入卡号
			json.put(ReceiptContants.FIELD.IN_CUSTOMER_NAME, inPerson.getName()); // 转入客户姓名
			json.put(ReceiptContants.FIELD.OUT_CARD_NO, outCard.getCardNo()); // 转出卡号
			json.put(ReceiptContants.FIELD.OUT_CUSTOMER_NAME, outPerson.getName()); // 转出客户姓名
			json.put(ReceiptContants.FIELD.OUT_CUSTOMER_CERTIFICATE_NO, outPerson.getCertNo()); // 转出客户证件号码
			json.put(ReceiptContants.FIELD.IN_ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.add(initparameters.get("inAccBal").toString(), amt + ""))); // 转入卡余额
			json.put(ReceiptContants.FIELD.OUT_ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.sub(outAcc.getBal() + "", amt + ""))); // 转出卡余额
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员工姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(actionlog.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(actionlog, json, ReceiptContants.TYPE.TRANSFER_ACCOUNTS, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 》》联机转脱机灰记录确认
	 * @param map
	 * @throws CommonException
	 */
	public void saveTransferToWalletConfirm(Map map) throws CommonException{
		try {
			//验证柜员信息是否正常
			String operId = Tools.processNull(map.get("operid"));
			validUsers(operId);
			String dealNo = Tools.processNull(map.get("dealNo"));
			TrServRec rec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + dealNo);
			if(rec == null){
				throw new CommonException("不存在需要确认的转账灰记录");
			}
			SysActionLog actionLog = (SysActionLog) this.findOnlyRowByHql(" from SysActionLog t where t.dealNo = " + dealNo);
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("deal_no",dealNo);//原来交易序列
			accMap.put("clr_date",getClrDate());
			accMap.put("card_no1",rec.getCardNo());//借方账户
			accMap.put("card_no2",rec.getInCardNo());//贷方账户
			acc.transferConfirm(actionLog,accMap);
			if(!Tools.processNull(rec.getOldDealNo()).equals("")){//如果为撤销，需要对原纪录状态也进行撤销
				publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CX +  "' where t.deal_no = " + rec.getOldDealNo());
			}
			int iscount = publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_ZC +  "' where t.deal_no = " + rec.getDealNo());
			if(iscount != 1){
				throw new CommonException("转账确认出现错误,更新转账记录" + iscount + "行！");
			}
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	/**
	 * 》》联机转脱机灰记录取消
	 * @param map
	 * @throws CommonException
	 */
	public void saveTransferToWalletCancel(Map map) throws CommonException{
		JSONObject object = new JSONObject();
		try {
			object.put("iSuc", false);
			//验证柜员信息是否正常
			String operId = Tools.processNull(map.get("operid"));
			validUsers(operId);
			
			String dealNo = Tools.processNull(map.get("dealNo"));
			TrServRec rec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + dealNo);
			if(rec == null){
				throw new CommonException("根据流水未获取到需要冲正的转账灰记录");
			}
			SysActionLog actionLog = (SysActionLog) this.findOnlyRowByHql(" from SysActionLog t where t.dealNo = " + dealNo);
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("action_no",dealNo);//原来交易序列
			accMap.put("clr_date",rec.getClrDate());//原来分清日期
			accMap.put("card_no2",rec.getInCardNo());//转入卡号
			accMap.put("card_no1",rec.getCardNo());//转出卡号
			accMap.put("card_bal","");//转出卡钱包交易前金额
			accMap.put("card_tr_count2",Tools.processNull(rec.getCardTrCount()));//转入卡卡交易计数器
			accMap.put("card_bal2",Tools.processNull(rec.getPrvBal()));//转入卡钱包交易前金额
			accMap.put("tr_state",Sys_Code.TR_STATE_HJL);
			acc.transferCancel(actionLog,accMap);
			rec.setDealState(Sys_Code.TR_STATE_CZ);
			publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CZ +  "' where t.deal_no = " + rec.getDealNo());
			object.put("iSuc", true);
		} catch (Exception e) {
			object.put("messages", e.getMessage());
		}
	}

	/**
	 * 脱机账户转联机账户，写灰记录
	 * @param map
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveTransferOfflineAcc2OnlineAcc(Map<String, Object> map) throws CommonException {
		try {
			String outCardNo = (String) map.get("outCardNo");
			String inCardNo = (String) map.get("inCardNo");
			Long amt = Tools.processNull(map.get("amt")).trim().equals("") ? 0L : Long.valueOf(map.get("amt").toString().trim());
			// 判断卡号
			if (Tools.processNull(outCardNo).equals("")) {
				throw new CommonException("转出卡号不能为空！");
			}
			if (Tools.processNull(inCardNo).equals("")) {
				throw new CommonException("转入卡号不能为空！");
			}
			if (!outCardNo.equals(inCardNo)) {
				throw new CommonException("转出卡号和转入卡号必须为同一卡号！");
			}
			// 判断卡信息
			CardBaseinfo cardBaseinfo = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + outCardNo + "'");
			if (cardBaseinfo == null) {
				throw new CommonException("根据卡号未找到卡信息！");
			}
			// 判断人员信息
			BasePersonal basePersonal = (BasePersonal) findOnlyRowByHql("from BasePersonal b where b.customerId = '" + cardBaseinfo.getCustomerId() + "'");
			if (basePersonal == null) {
				throw new CommonException("根据卡信息未找到人员信息！");
			}
			// 判断账户信息
			AccAccountSub offlineAcc = (AccAccountSub) findOnlyRowByHql("from AccAccountSub a where a.customerId = '" + basePersonal.getCustomerId() + "' and a.accKind = '" + Constants.ACC_KIND_QBZH + "'");
			if (offlineAcc == null) {
				throw new CommonException("转出卡号" + Constants.ACC_KIND_NAME_QB + "账户不存在！");
			}
			AccAccountSub onlineAcc = (AccAccountSub) findOnlyRowByHql("from AccAccountSub a where a.customerId = '" + basePersonal.getCustomerId() + "' and a.accKind = '" + Constants.ACC_KIND_ZJZH + "'");
			if (onlineAcc == null) {
				throw new CommonException("转入卡号" + Constants.ACC_KIND_NAME_LJ + "不存在！");
			}
			if (amt == 0L) {
				throw new CommonException("转账金额不能为空或0！");
			}
			if (amt > offlineAcc.getBal()) {
				throw new CommonException("转存卡号电子钱包余额不足！");
			}
			// 判断卡参数信息
			CardConfig cardConfig = (CardConfig) findOnlyRowByHql("from CardConfig t where t.cardType = '" + cardBaseinfo.getCardType() + "'");
			if (cardConfig == null) {
				throw new CommonException("转入卡卡类型参数信息不存在！");
			}
			if (Tools.processNull(cardConfig.getWalletCaseRechgLmt()).equals("")) {
				throw new CommonException("转入卡卡类型账户限额信息不存在！");
			}
			if (Long.valueOf(Arith.add(onlineAcc.getBal() + "", Arith.cardmoneymun(amt + ""))) > cardConfig.getAccCaseRechgLmt()){
				throw new CommonException("转入卡转账后账户余额大于该卡类型账户限额！");
			}
			SysActionLog sysActionLog = getCurrentActionLog();
			sysActionLog.setDealCode(DealCode.RECHARGE_WALLET_ACC);
			sysActionLog.setMessage("脱机转联机[卡号:" + outCardNo + ",转账金额:" + Arith.cardreportstomoney(amt.toString()) + "]");
			publicDao.save(sysActionLog);
			// 调用存储过程
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("acpt_id", sysActionLog.getBrchId()); // 受理点编号
			accMap.put("acpt_type", Constants.ACPT_TYPE_GM); // 受理点分类
			accMap.put("tr_batch_no", ""); // 批次号
			accMap.put("term_tr_no", ""); // 终端交易流水号
			accMap.put("card_no1", outCardNo); // 转出卡号
			accMap.put("card_tr_count1", map.get("card_Tr_Count").toString()); // 转出卡交易计数器 
			accMap.put("card_bal1", offlineAcc.getBal().toString()); // 转出卡钱包交易前金额
			accMap.put("acc_kind1", Constants.ACC_KIND_QBZH); // 转出卡账户类型
			accMap.put("wallet_id1", "00"); // 转出卡钱包编号 默认00
			accMap.put("card_no2", inCardNo); // 转入卡号
			accMap.put("card_tr_count2", ""); // 转入卡交易计数器
			accMap.put("card_bal2", onlineAcc.getBal().toString()); // 转入卡钱包交易前金额
			accMap.put("acc_kind2", Constants.ACC_KIND_ZJZH); // 转入卡账户类型
			accMap.put("tr_amt", Arith.cardmoneymun(amt + "")); // 转账金额
			accMap.put("wallet_id2", "00"); // 转入卡钱包编号 默认00
			accMap.put("tr_state", Constants.TR_STATE_HJL);
			accMap.put("pwd", ""); // 转账密码
			acc.transfer(sysActionLog, accMap);
			// 记录业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(sysActionLog.getDealNo());
			trServRec.setDealCode(sysActionLog.getDealCode());
			trServRec.setAmt(Long.valueOf(Arith.cardmoneymun(amt.toString())));
			trServRec.setBrchId(sysActionLog.getBrchId());
			trServRec.setUserId(sysActionLog.getUserId());
			trServRec.setBizTime(sysActionLog.getDealTime());
			trServRec.setDealState(Constants.TR_STATE_HJL);
			trServRec.setCardNo(cardBaseinfo.getCardNo());
			trServRec.setCardAmt(1L);
			trServRec.setCardId(cardBaseinfo.getCardId());
			trServRec.setCardType(cardBaseinfo.getCardType());
			trServRec.setCardTrCount(map.get("card_Tr_Count").toString());
			trServRec.setClrDate(this.getClrDate());
			trServRec.setAccKind(Constants.ACC_KIND_QBZH);
			trServRec.setAccNo(offlineAcc.getAccNo() + "");
			trServRec.setCustomerId(basePersonal.getCustomerId() + "");
			trServRec.setCustomerName(basePersonal.getName());
			trServRec.setCertNo(basePersonal.getCertNo());
			trServRec.setCertType(basePersonal.getCertType());
			trServRec.setPrvBal(offlineAcc.getBal());
			trServRec.setTelNo(basePersonal.getMobileNo());
			trServRec.setInCardNo(cardBaseinfo.getCardNo());
			trServRec.setInAccNo(onlineAcc.getAccNo() + "");
			trServRec.setNote(sysActionLog.getMessage());
			publicDao.save(trServRec);
			// 打印凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, trServRec.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(trServRec.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportstomoney(amt + "")); // 交易金额
			json.put(ReceiptContants.FIELD.IN_CARD_NO, inCardNo); // 转入卡号
			json.put(ReceiptContants.FIELD.IN_CUSTOMER_NAME, basePersonal.getName()); // 转入客户姓名
			json.put(ReceiptContants.FIELD.OUT_CARD_NO, cardBaseinfo.getCardNo()); // 转出卡号
			json.put(ReceiptContants.FIELD.OUT_CUSTOMER_NAME, basePersonal.getName()); // 转出客户姓名
			json.put(ReceiptContants.FIELD.OUT_CUSTOMER_CERTIFICATE_NO, basePersonal.getCertNo()); // 转出客户证件号码
			json.put(ReceiptContants.FIELD.IN_ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.add(onlineAcc.getBal() + "", Arith.cardmoneymun(amt + "")))); // 转入卡余额
			json.put(ReceiptContants.FIELD.OUT_ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.sub(offlineAcc.getBal() + "", Arith.cardmoneymun(amt + "")))); // 转出卡余额
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员工姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(sysActionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(sysActionLog, json, ReceiptContants.TYPE.TRANSFER_ACCOUNTS, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			return trServRec;
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}

	/**
	 * 脱机转联机灰记录确认
	 * @param map
	 * @throws CommonException
	 */
	public void saveTransferToOnlineConfirm(Map<String, Object> map) throws CommonException {
		try {
			String dealNo = Tools.processNull(map.get("dealNo"));
			TrServRec trServRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + dealNo);
			if (trServRec == null) {
				throw new CommonException("不存在需要确认的转账灰记录");
			}
			SysActionLog sysActionLog = (SysActionLog) this.findOnlyRowByHql("from SysActionLog t where t.dealNo = " + dealNo);
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("deal_no", dealNo); // 交易流水号
			accMap.put("clr_date", trServRec.getClrDate()); // 清分日期
			accMap.put("card_no1", trServRec.getCardNo()); // 转出卡号
			accMap.put("card_no2", trServRec.getInCardNo()); // 转入卡号
			acc.transferConfirm(sysActionLog, accMap);
			if (!Tools.processNull(trServRec.getOldDealNo()).equals("")) {
				publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CX +  "' where t.deal_no = " + trServRec.getOldDealNo());
			}
			int iscount = publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_ZC +  "' where t.deal_no = " + trServRec.getDealNo());
			if(iscount != 1){
				throw new CommonException("转账确认出现错误,更新转账记录" + iscount + "行！");
			}
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}

	/**
	 * 脱机转联机灰记录取消
	 * @param map
	 * @throws CommonException
	 */
	public void saveTransferToOnlineCancel(Map<String, Object> map) throws CommonException {
		JSONObject object = new JSONObject();
		try {
			String dealNo = Tools.processNull(map.get("dealNo"));
			TrServRec trServRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + dealNo);
			if(trServRec == null){
				throw new CommonException("根据流水未获取到需要冲正的转账灰记录");
			}
			SysActionLog actionLog = (SysActionLog) this.findOnlyRowByHql("from SysActionLog t where t.dealNo = " + dealNo);
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("action_no", dealNo);
			accMap.put("clr_date", trServRec.getClrDate());
			accMap.put("card_no2", trServRec.getInCardNo());
			accMap.put("card_no1", trServRec.getCardNo());
			accMap.put("card_bal", "");
			accMap.put("card_tr_count1", Tools.processNull(trServRec.getCardTrCount()));
			accMap.put("card_bal2", Tools.processNull(trServRec.getPrvBal()));
			accMap.put("tr_state",Sys_Code.TR_STATE_HJL);
			acc.transferCancel(actionLog, accMap);
			trServRec.setDealState(Sys_Code.TR_STATE_CZ);
			publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CZ +  "' where t.deal_no = " + trServRec.getDealNo());
			object.put("iSuc", true);
		} catch (Exception e) {
			object.put("messages", e.getMessage());
		}
	}
	/**
	 * 》》新版账户转账公用方法
	 * @param hm HashMap
     * userId    	        操作员编号
     * trBatchNo 	         批次号
     * termTrNo  	         终端交易流水号
	 * outCardNo     	转出卡号
	 * outAccKind       转出卡转出账户类型
	 * outCardTrCount 	转出卡交易计数器
	 * outCardAmt		转出卡钱包交易前金额
	 * isJudgeOutCardHjl是否判断转出卡有灰记录
	 * inCardNo     	转入卡号
	 * inAccKind 		转入卡账户类型
	 * inCardTrCount 	转入卡交易计数器
	 * inCardAmt		转入卡钱包交易前金额
	 * isJudgeInCardHjl 是否判断转入卡有灰记录
	 * dealCode         交易代码
	 * amt  			转账金额  null时转出所有金额
	 * isJudgeOutAccPwd 是否判断转出卡密码 0 判断
	 * pwd				转账密码
	 * dealState        9写灰记录0直接写正常记录
	*/
	@SuppressWarnings("unchecked")
	public TrServRec saveAccTransfer(Map<String, Object> inParameters) throws CommonException {
		try{
			//1.转出卡信息判断
			String operId = Tools.processNull(inParameters.get("userId"));
			String outCardNo = (String) inParameters.get("outCardNo");
			String outAccKind = (String) inParameters.get("outAccKind");
			Long amt = Tools.processNull(inParameters.get("amt")).trim().equals("") ? 0L : Long.valueOf(inParameters.get("amt").toString().trim());
			if(Tools.processNull(operId).equals("")){
				throw new CommonException("柜员编号不能为空！");
			}
			Users oper = this.validUsers(operId);
			if(Tools.processNull(inParameters.get("dealCode")).equals("")){
				throw new CommonException("交易代码不能为空！");
			}
			if(!Tools.processNull(inParameters.get("dealState")).equals(Constants.TR_STATE_ZC) && !Tools.processNull(inParameters.get("dealState")).equals(Constants.TR_STATE_HJL)){
				throw new CommonException("转账记录状态只能是0或9！");
			}
			if(Tools.processNull(outCardNo).equals("")){
				throw new CommonException("转出卡卡号不能为空！");
			}
			if(Tools.processNull(outAccKind).equals("")){
				throw new CommonException("转出卡转出账户类型不能为空！");
			}
			CardBaseinfo outCardBaseinfo = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + outCardNo + "'");
			if(outCardBaseinfo == null) {
				throw new CommonException("根据转出卡卡号未找到卡信息！");
			}
			if(!Tools.processNull(outCardBaseinfo.getCardState()).equals(Constants.CARD_STATE_ZC)){
				throw new CommonException("转出卡卡状态不是正常状态！");
			}
			if(Tools.processNull(inParameters.get("isJudgeOutCardHjl")).equals(Constants.STATE_ZC)){
				List<?> hjlList = this.findBySql("SELECT t.deal_no from ACC_INOUT_DETAIL t WHERE t.cr_card_no = '" + outCardBaseinfo.getCardNo() + "' AND t.deal_state = '" + Constants.TR_STATE_HJL + "'");
				if(hjlList != null && hjlList.size() > 0){
					throw new CommonException("转出卡有未处理的灰记录，请先处理灰记录！");
				}
			}
			BasePersonal outBasePersonal = (BasePersonal) findOnlyRowByHql("from BasePersonal b where b.customerId = '" + outCardBaseinfo.getCustomerId() + "'");
			if(outBasePersonal == null) {
				outBasePersonal = new BasePersonal();
			}
			String ecrpwd = "";
			if(Tools.processNull(inParameters.get("isJudgeOutAccPwd")).equals(Constants.STATE_ZC)){
				if(Tools.processNull(inParameters.get("pwd")).equals("")){
					throw new CommonException("请输入转出卡转出账户密码！");
				}
				ecrpwd = doWorkClientService.encrypt_PinPwd(outCardBaseinfo.getCardNo(),inParameters.get("pwd").toString());
				if(Tools.processNull(outCardBaseinfo.getPayPwd()).equals(ecrpwd)){
					throw new CommonException("转出卡转出账户密码不正确！");
				}
			}
			AccAccountSub outAcc = acc.getAccSubLedgerByCardNoAndAccKind(outCardBaseinfo.getCardNo(),outAccKind,"00");
			if(outAcc == null){
				throw new CommonException("转出卡号" + this.getCodeNameBySYS_CODE("ACC_KIND",outAccKind) + "账户不存在！");
			}
			if(amt == 0L){
				throw new CommonException("转账金额不能为空或0！");
			}
			if(outAcc.getBal() < amt){
				throw new CommonException("转出卡转出账户余额不足！");
			}
			//2.转入卡信息判断
			String inCardNo = (String) inParameters.get("inCardNo");
			if(Tools.processNull(inCardNo).equals("")) {
				throw new CommonException("转入卡卡号不能为空！");
			}
			String inAccKind = (String) inParameters.get("inAccKind");
			if(Tools.processNull(outAccKind).equals("")) {
				throw new CommonException("转入卡转入账户类型不能为空！");
			}
			CardBaseinfo inCardBaseinfo = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + inCardNo + "'");
			if(inCardBaseinfo == null) {
				throw new CommonException("根据转入卡卡号未找到卡信息！");
			}
			if(!Tools.processNull(inCardBaseinfo.getCardState()).equals(Constants.CARD_STATE_ZC)){
				throw new CommonException("转入卡卡状态不是正常状态！");
			}
			if(Tools.processNull(inParameters.get("isJudgeInCardHjl")).equals(Constants.STATE_ZC)){
				List<?> hjlList = this.findBySql("SELECT t.deal_no from ACC_INOUT_DETAIL t WHERE t.cr_card_no = '" + inCardBaseinfo.getCardNo() + "' AND t.deal_state = '" + Constants.TR_STATE_HJL + "'");
				if(hjlList != null && hjlList.size() > 0){
					throw new CommonException("转入卡有未处理的灰记录，请先处理灰记录！");
				}
			}
			BasePersonal inBasePersonal = (BasePersonal) findOnlyRowByHql("from BasePersonal b where b.customerId = '" + inCardBaseinfo.getCustomerId() + "'");
			if(inBasePersonal == null) {
				inBasePersonal = new BasePersonal();
			}
			AccAccountSub inAcc = acc.getAccSubLedgerByCardNoAndAccKind(inCardBaseinfo.getCardNo(),inAccKind,"00");
			if(inAcc == null) {
				throw new CommonException("转入卡号" + this.getCodeNameBySYS_CODE("ACC_KIND",inAccKind) + "不存在！");
			}
			//3.转账信息判断
			CardConfig cardConfig = (CardConfig) findOnlyRowByHql("from CardConfig t where t.cardType = '" + outCardBaseinfo.getCardType() + "'");
			if(cardConfig == null) {
				throw new CommonException("转入卡卡类型配置参数信息不存在！");
			}
			if(Tools.processNull(inAccKind).equals(Constants.ACC_KIND_QBZH)){
				if(Tools.processNull(cardConfig.getWalletCaseRechgLmt()).equals("")){
					throw new CommonException("转入卡卡类型账户限额信息不存在！");
				}
				if(Long.valueOf(Arith.add(inAcc.getBal() + "",amt + "")) > cardConfig.getWalletCaseRechgLmt()){
					throw new CommonException("转入卡转账后账户余额大于该卡类型账户限额！");
				}
			}else{
				if(Tools.processNull(cardConfig.getAccCaseRechgLmt()).equals("")){
					throw new CommonException("转入卡卡类型账户限额信息不存在！");
				}
				if(Long.valueOf(Arith.add(inAcc.getBal() + "",amt + "")) > cardConfig.getAccCaseRechgLmt()){
					throw new CommonException("转入卡转账后账户余额大于该卡类型账户限额！");
				}
			}
			//4.记录操作日志
			SysActionLog sysActionLog = getCurrentActionLog();
			sysActionLog.setDealCode(Integer.valueOf(Tools.processNull(inParameters.get("dealCode"))));
			sysActionLog.setMessage(this.findTrCodeNameByCodeType(sysActionLog.getDealCode()) +  "[转出卡号:" + outCardNo + ",转入卡号:" + inCardNo + "转账金额:" + Arith.cardreportsmoneydiv(amt.toString()) + "]");
			publicDao.save(sysActionLog);
			//5.调用存储过程
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("acpt_id",oper.getBrchId());//受理点编号
			accMap.put("acpt_type",Constants.ACPT_TYPE_GM);//受理点分类
			accMap.put("tr_batch_no",Tools.processNull(inParameters.get("trBatchNo")));//批次号
			accMap.put("term_tr_no",Tools.processNull(inParameters.get("termTrNo")));//终端交易流水号
			accMap.put("card_no1",outCardNo);//转出卡号
			accMap.put("card_tr_count1",Tools.processNull(inParameters.get("outCardTrCount")));//转出卡交易计数器 
			accMap.put("card_bal1",Tools.processNull(inParameters.get("outCardAmt")));//转出卡钱包交易前金额
			accMap.put("acc_kind1",outAccKind); // 转出卡账户类型
			accMap.put("wallet_id1","00");//转出卡钱包编号 默认00
			accMap.put("card_no2",inCardNo);//转入卡号
			accMap.put("card_tr_count2",Tools.processNull(inParameters.get("inCardTrCount")));//转入卡交易计数器
			accMap.put("card_bal2",Tools.processNull(inParameters.get("inCardAmt")));//转入卡钱包交易前金额
			accMap.put("acc_kind2",inAccKind);//转入卡账户类型
			accMap.put("tr_amt",amt + "");//转账金额
			accMap.put("wallet_id2","00");//转入卡钱包编号 默认00
			accMap.put("tr_state",Tools.processNull(inParameters.get("dealState")));
			accMap.put("pwd","");//转账密码
			acc.transfer(sysActionLog,accMap);
			//6.记录业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(sysActionLog.getDealNo());
			rec.setDealCode(sysActionLog.getDealCode());
			rec.setAmt(amt);
			rec.setBrchId(sysActionLog.getBrchId());
			rec.setUserId(sysActionLog.getUserId());
			rec.setBizTime(sysActionLog.getDealTime());
			rec.setDealState(Tools.processNull(inParameters.get("dealState")));
			rec.setCardNo(outCardNo);
			rec.setCardAmt(1L);
			rec.setCardId(outCardBaseinfo.getCardId());
			rec.setCardType(outCardBaseinfo.getCardType());
			rec.setCardTrCount(inParameters.get("outCardTrCount").toString());
			rec.setClrDate(this.getClrDate());
			rec.setAccKind(outAccKind);
			rec.setAccNo(outAcc.getAccNo() + "");
			rec.setCustomerId(outBasePersonal.getCustomerId() + "");
			rec.setCustomerName(outBasePersonal.getName());
			rec.setCertNo(outBasePersonal.getCertNo());
			rec.setCertType(outBasePersonal.getCertType());
			if(!Tools.processNull(inParameters.get("outCardAmt")).equals("")){
				rec.setPrvBal(Long.valueOf(Tools.processNull(inParameters.get("outCardAmt"))));
			}else{
				rec.setPrvBal(outAcc.getBal());
			}
			rec.setTelNo(outBasePersonal.getMobileNo());
			rec.setInCardNo(inCardBaseinfo.getCardNo());
			rec.setInAccNo(inAcc.getAccNo() + "");
			rec.setNote(sysActionLog.getMessage());
			publicDao.save(rec);
			//7.打印凭证
			//报表信息
			JSONObject report = new JSONObject();
			report.put("p_Title",Constants.APP_REPORT_TITLE + findTrCodeNameByCodeType(rec.getDealCode()) + "凭证");
			report.put("yewuleixing", findTrCodeNameByCodeType(rec.getDealCode()));
			report.put("p_DealNo",rec.getDealNo());
			report.put("p_CardNo1",rec.getInCardNo());
			String certNo1 = (String) findOnlyFieldBySql("select cert_no from base_personal where customer_id = '" + rec.getCustomerId() + "'");
			report.put("p_CertNo1",certNo1 );
			report.put("p_CustomerName1",rec.getCustomerName());
			report.put("p_Brch",getSessionSysBranch().getFullName());
			report.put("p_CardNo2",rec.getCardNo());
			report.put("p_CustomerName2",rec.getCustomerName());
			report.put("p_PrintTime",DateUtil.formatDate(rec.getBizTime(),"yyyy-MM-dd HH:mm:ss"));
			report.put("p_DbBalance",Arith.cardreportsmoneydiv(outAcc.getBal() + ""));
			report.put("p_CrBalance",Arith.cardreportsmoneydiv(Arith.add(inAcc.getBal() + "",rec.getAmt() + "")));
			report.put("p_Amt",Arith.cardreportsmoneydiv(rec.getAmt() + ""));
			report.put("tel",rec.getAgtTelNo());
			report.put("agtTel",rec.getAgtTelNo());
			report.put("p_UserId",oper.getUserId());
			report.put("p_UserName",oper.getName());
			SysActionLog log = (SysActionLog) this.findOnlyRowByHql("from SysActionLog where dealNo = " + rec.getDealNo());
			this.saveSysReport(log,report,"/reportfiles/BhkQianBZZ.jasper",Constants.APP_REPORT_TYPE_PDF,0L,"",null);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 》》新版账户转账灰记录确认
	 * @param map
	 * dealNo 确认转账流水
	 * @throws CommonException
	 */
	public void saveAccTransferConfirm(Map<String, Object> map) throws CommonException {
		try {
			String dealNo = Tools.processNull(map.get("dealNo"));
			if(Tools.processNull(dealNo).equals("")){
				throw new CommonException("确认转账流水编号不能为空！");
			}
			TrServRec trServRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + dealNo);
			if(trServRec == null) {
				throw new CommonException("根据转账流水" + dealNo + "找不到需要确认的转账灰记录信息！");
			}
			SysActionLog sysActionLog = (SysActionLog) this.findOnlyRowByHql("from SysActionLog t where t.dealNo = " + dealNo);
			if(sysActionLog == null) {
				throw new CommonException("根据转账流水" + dealNo + "找不到转账操作日志信息！");
			}
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("deal_no",dealNo);//交易流水号
			accMap.put("clr_date",trServRec.getClrDate());//清分日期
			accMap.put("card_no1",trServRec.getCardNo());//转出卡号
			accMap.put("card_no2",trServRec.getInCardNo());//转入卡号
			acc.transferConfirm(sysActionLog,accMap);
			if (!Tools.processNull(trServRec.getOldDealNo()).equals("")) {
				publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CX +  "' where t.deal_no = " + trServRec.getOldDealNo());
			}
			int iscount = publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_ZC +  "' where t.deal_no = " + trServRec.getDealNo());
			if(iscount != 1){
				throw new CommonException("转账确认出现错误,更新转账记录" + iscount + "行！");
			}
			// 如果是好卡换卡转钱包，更新老卡钱包账户余额处理状态
			if (DealCode.BHK_QB_ZZ.equals(trServRec.getDealCode())) {
				publicDao.doSql("update acc_account_sub t set t.bal_rslt = '2' where card_no = '" + trServRec.getOldCardNo() + "' and acc_kind = '" + Constants.ACC_KIND_QBZH + "'");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 》》新版账户转账灰记录取消
	 * dealNo   	         转账时的业务流水号
	 * outCardTrCount 	转出卡卡交易计数器
	 * inCardTrCount 	转入卡卡交易计数器
	 * outCardAmt		转出卡钱包交易前金额
	 * inCardAmt		转入卡钱包交易前金额
	 */
	public void saveAccTransferCancel(Map<String, Object> map) throws CommonException {
		try {
			String dealNo = Tools.processNull(map.get("dealNo"));
			if(Tools.processNull(dealNo).equals("")){
				throw new CommonException("确认转账流水编号不能为空！");
			}
			TrServRec trServRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + dealNo);
			if(trServRec == null){
				throw new CommonException("根据流水未获取到需要冲正的转账灰记录");
			}
			/*action_no 		转账时的业务流水号
			 * 			clr_date		写灰记录时的清分日期
			 * 			tr_state		原转账记录状态  灰记录或正常记录允许撤销
			 * 			card_no1		转出卡号
			 * 			card_no2		转入卡号
			 *			card_tr_count1 	转出卡卡交易计数器
			 *			card_tr_count2 	转入卡卡交易计数器
			 *			card_bal1		转出卡钱包交易前金额
			 *			card_bal2		转入卡钱包交易前金额*/
			SysActionLog actionLog = (SysActionLog) this.findOnlyRowByHql("from SysActionLog t where t.dealNo = " + dealNo);
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("action_no",dealNo);
			accMap.put("clr_date",trServRec.getClrDate());
			accMap.put("card_no1",trServRec.getCardNo());
			accMap.put("card_no2",trServRec.getInCardNo());
			accMap.put("card_tr_count1",Tools.processNull(map.get("outCardTrCount")));
			accMap.put("card_tr_count2",Tools.processNull(map.get("inCardTrCount")));
			accMap.put("card_bal1",Tools.processNull("outCardAmt"));
			accMap.put("card_bal2",Tools.processNull("inCardAmt"));
			accMap.put("tr_state",Tools.processNull(trServRec.getDealState()));
			acc.transferCancel(actionLog,accMap);
			trServRec.setDealState(Sys_Code.TR_STATE_CZ);
			int i = publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CZ +  "' where t.deal_no = " + trServRec.getDealNo());
			if(i != 1){
				throw new CommonException("冲正转账记录更新0行！");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 》》灰记录处理,灰记录确认
	 * @param actionNo
	 * @param map
	 * @return
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public TrServRec saveDealAshRecordConfrim(Map map){
		try{
			//1.判断灰记录条件
			Long dealNo = (Long) map.get("dealNo");
			if(Tools.processNull(dealNo).equals("")){
				throw new CommonException("灰记录处理确认发生错误：请至少选一条记录");
			}
			Users oper = (Users) map.get("oper");
			if(oper == null || !(oper instanceof Users)){
				throw new CommonException("灰记录处理确认发生错误：传入操作柜员不能为空！");
			}
			SysActionLog actionlog = (SysActionLog) map.get("actionlog");
			if(actionlog == null || !(actionlog instanceof SysActionLog)){
				throw new CommonException("灰记录处理确认发生错误：传入操作日志不能为空！");
			}
			//2.记录操作日志
			actionlog.setDealCode(DealCode.RECHARGE_WALLET_HJL_QR);
			actionlog.setMessage("灰记录处理确认：原业务流水:" + dealNo);
			publicDao.save(actionlog);
			TrServRec oldrec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = '" + dealNo + "'");
			if(oldrec == null){
				//throw new CommonException("灰记录处理确认发生错误：根据业务流水未找到对应记录信息！");
			}
			//4.调存存储过程
			HashMap hm = new HashMap();
			hm.put("deal_no",dealNo);//处理流水
			hm.put("clr_date",this.getClrDate());//清分日期
			hm.put("card_no", oldrec == null ? "" : oldrec.getCardNo());// 卡号
			acc.rechargeConfirm(actionlog,hm);
			int updatecount = publicDao.doSql("update tr_serv_rec t set t.deal_state = '0' , t.clr_date = '" + this.getClrDate() + "' where t.deal_no = " + dealNo);
			if(updatecount != 1 && oldrec != null){
				throw new CommonException("灰记录处理确认发生错误：更新原记录" + updatecount + "行！");
			}
			if(oldrec != null && !Tools.processNull(oldrec.getOldDealNo()).equals("")){
				publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CX + "' where t.deal_No = " + oldrec.getOldDealNo());
			}
            TrServRec rec = null;
			//5.记录新业务日志
            if(oldrec != null){
                rec = (TrServRec) BeanUtils.cloneBean(oldrec);
            }else{
                rec = new TrServRec();
            }
			rec.setDealNo(actionlog.getDealNo());
			rec.setDealCode(actionlog.getDealCode());
			rec.setNote(actionlog.getMessage());
			rec.setBizTime(actionlog.getDealTime());
			rec.setBrchId(actionlog.getBrchId());
			rec.setUserId(actionlog.getUserId());
			rec.setClrDate(this.getClrDate());
			rec.setOldDealNo(dealNo);
			rec.setDealState(Constants.TR_STATE_ZC);
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 》》灰记录取消
	 */
	public TrServRec saveDealAshRecordCancel(Map map) throws CommonException{
		try{
			//1.判断灰记录条件
			Long dealNo = (Long) map.get("dealNo");
			if(Tools.processNull(dealNo).equals("")){
				throw new CommonException("灰记录处理取消，请至少选一条记录");
			}
			Object[] hjl = (Object[]) findOnlyFieldBySql("select t2.customer_id, t2.name, t2.cert_type, t2.cert_no, t.cr_card_no, t.cr_card_type, t.cr_acc_kind, t.cr_acc_bal, t.cr_amt from acc_inout_detail t join base_personal t2 on t.cr_customer_id = t2.customer_id where t.deal_no = '" + dealNo + "'");
			Users oper = (Users) map.get("oper");
			if(oper == null || !(oper instanceof Users)){
				throw new CommonException("灰记录处理取消，传入操作柜员不能为空！");
			}
			SysActionLog actionlog = (SysActionLog) map.get("actionlog");
			if(actionlog == null || !(actionlog instanceof SysActionLog)){
				throw new CommonException("灰记录处理取消，传入操作日志不能为空！");
			}
			//2.记录操作日志
			actionlog.setDealCode(DealCode.RECHARGE_WALLET_HJL_QX);
			actionlog.setMessage("灰记录取消,原业务流水:" + dealNo);
			publicDao.save(actionlog);
			TrServRec oldrec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = '" + dealNo + "'");
//			if(oldrec == null){
//				throw new CommonException("根据业务流水未找到需要取消的综合业务日志！");
//			}
			//4.调存存储过程
			HashMap hm = new HashMap();
			hm.put("deal_no", dealNo);// 原来交易序列
			hm.put("deal_state", Constants.TR_STATE_HJL);// 原充值记录状态
			if (oldrec == null) {
				hm.put("card_no", "");// 原交易卡号
				hm.put("card_tr_count", "");// 卡交易计数器
				hm.put("card_bal", "");// 钱包交易前金额
			} else {
				hm.put("card_no", oldrec.getCardNo());// 原交易卡号
				hm.put("card_tr_count", oldrec.getCardTrCount());// 卡交易计数器
				hm.put("card_bal", oldrec.getPrvBal());// 钱包交易前金额
			}
			acc.rechargeCancel(actionlog,hm);
			int updatecount = publicDao.doSql("update tr_serv_rec t set t.deal_state = '2' , t.clr_date = '" + this.getClrDate() + "' where t.deal_no = " + dealNo);
			if(updatecount != 1 && oldrec != null){
				throw new CommonException("灰记录取消，更新原记录" + updatecount + "行！");
			}
			//如果是充值撤销的灰记录冲正，需要将原来的充值记录变成正常记录
			if(oldrec != null && !Tools.processNull(oldrec.getOldDealNo()).equals("")){
				publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_ZC + "' where t.deal_No = " + oldrec.getOldDealNo());
			}
			//5.记录新业务日志
			TrServRec rec = oldrec == null ? new TrServRec() : (TrServRec) BeanUtils.cloneBean(oldrec);
			rec.setCustomerId((String) hjl[0]);
			rec.setCustomerName((String) hjl[1]);
			rec.setCertType((String) hjl[2]);
			rec.setCertNo((String) hjl[3]);
			rec.setCardNo((String) hjl[4]);
			rec.setCardType((String) hjl[5]);
			rec.setAccKind((String) hjl[6]);
			rec.setPrvBal(((BigDecimal) hjl[7]).longValue());
			rec.setAmt(((BigDecimal) hjl[8]).longValue());
			rec.setDealNo(actionlog.getDealNo());
			rec.setDealCode(actionlog.getDealCode());
			rec.setNote(actionlog.getMessage());
			rec.setBizTime(actionlog.getDealTime());
			rec.setBrchId(actionlog.getBrchId());
			rec.setUserId(actionlog.getUserId());
			rec.setClrDate(this.getClrDate());
			rec.setOldDealNo(dealNo);
			rec.setDealState(Constants.TR_STATE_ZC);
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public TrServRec saveRechargeCardAccount(String cardNo, String rechargeCardNo, String rechargeCardPassword) throws CommonException {
		if (Tools.processNull(cardNo).equals("")) {
			throw new CommonException("未传入卡号数据！");
		}
		CardBaseinfo cardBaseinfo = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + cardNo + "'");
		if (cardBaseinfo == null) {
			throw new CommonException("当前卡信息不存在！");
		}
		if (!cardBaseinfo.getCardState().equals(Constants.CARD_STATE_ZC)) {
			throw new CommonException("当前卡状态不是正常状态！");
		}
		BasePersonal basePersonal = (BasePersonal) findOnlyRowByHql("from BasePersonal b where b.customerId = '" + cardBaseinfo.getCustomerId() + "'");
		if (basePersonal == null) {
			throw new CommonException("当前卡无效！");
		}
		AccAccountSub accountDb = (AccAccountSub) findOnlyRowByHql("from AccAccountSub a where a.customerId = '" + basePersonal.getCustomerId() + "' and a.accKind = '" + Constants.ACC_KIND_ZJZH + "'");
		if (accountDb == null) {
			throw new CommonException("账户不存在" + Constants.ACC_KIND_NAME_LJ + "！");
		}
		if (!accountDb.getAccState().equals(Constants.ACC_STATE_ZC)) {
			throw new CommonException("该" + Constants.ACC_KIND_NAME_LJ + "不是正常状态！");
		}
		if (Tools.processNull(rechargeCardNo).equals("")) {
			throw new CommonException("未传入充值卡号数据！");
		}
		CardRecharge cardRecharge = (CardRecharge) findOnlyRowByHql("from CardRecharge c where c.cardNo = '" + rechargeCardNo + "'");
		if (cardRecharge == null) {
			throw new CommonException("当前充值卡信息不存在！");
		}
		if (!cardRecharge.getUseState().equals(Constants.CARD_RECHARGE_STATE_YJH)) {
			throw new CommonException("当前充值卡不是已激活状态！");
		}
		if (Tools.processNull(rechargeCardPassword).equals("")) {
			throw new CommonException("充值卡密码不能为空！");
		}
		String pin = doWorkClientService.getRechargeCardPwd(rechargeCardNo, 10).getJSONObject(0).getString("pin");
		if(!rechargeCardPassword.equals(pin)) {
			throw new CommonException("充值卡密码输入错误！");
		}

		String note = findTrCodeNameByCodeType(DealCode.RECHARGE_RECHARGECARD_ACC) + "，卡号：" + cardNo + "，充值卡号：" + rechargeCardNo;
		SysActionLog sysActionLog = getCurrentActionLog();
		sysActionLog.setDealCode(DealCode.RECHARGE_RECHARGECARD_ACC);
		sysActionLog.setMessage(note);
		sysActionLog.setNote(note);
		publicDao.save(sysActionLog);

		String encryMoney = Arith.cardmoneydiv(accountDb.getBal() + "");
		String orgId = getUser().getOrgId();
		String orgCustomerId = (String) findOnlyFieldBySql("select customer_id from sys_organ where org_id = '" + orgId + "'");
		AccAccountSub accountCr = (AccAccountSub) findOnlyRowByHql("from AccAccountSub a where a.customerId = '" + orgCustomerId + "' and a.itemId = '" + Constants.ACC_ITEM_201104 + "'");
		BigDecimal amount = new BigDecimal(Arith.cardmoneydiv(cardRecharge.getFaceVal().toString()));
		acc.account(accountCr, accountDb, amount, sysActionLog, "0", "", "", Constants.TR_STATE_ZC, note);
		String money = doWorkClientService.money2EncryptCal(cardNo, encryMoney, Arith.cardmoneydiv(cardRecharge.getFaceVal() + ""), "0");
		publicDao.doSql("update acc_account_sub set bal_crypt = '" + money + "' where customer_id = '" + accountDb.getCustomerId() + "' and acc_kind = '" + accountDb.getAccKind() + "'");
		publicDao.doSql("update card_recharge set use_state = '" + Constants.CARD_RECHARGE_STATE_YSY + "' where card_no = '" + cardRecharge.getCardNo() + "'");

		TrServRec trServRec = new TrServRec();
		trServRec.setDealNo(sysActionLog.getDealNo());
		trServRec.setDealCode(sysActionLog.getDealCode());
		trServRec.setCardNo(cardRecharge.getCardNo());
		trServRec.setCardType(cardRecharge.getCardType());
		trServRec.setCardAmt(Long.parseLong(cardRecharge.getFaceVal() + ""));
		trServRec.setBizTime(sysActionLog.getDealTime());
		trServRec.setUserId(sysActionLog.getUserId());
		trServRec.setBrchId(getUser().getBrchId());
		trServRec.setOrgId(getUser().getOrgId());
		trServRec.setClrDate(this.getClrDate());
		trServRec.setAmt(new Long(cardRecharge.getFaceVal()));
		trServRec.setNote(sysActionLog.getMessage());
		trServRec.setDealState(Constants.TR_STATE_ZC);
		publicDao.save(trServRec);
		
		/*JSONObject jsonobject = new JSONObject();
		jsonobject.put("p_Print_Time1", DateUtil.formatDate(sysActionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss"));
		jsonobject.put("p_Actionno", sysActionLog.getDealNo());
		jsonobject.put("p_Cardno", cardRecharge.getCardNo());
		jsonobject.put("p_Rechg_Amt", Arith.cardreportsmoneydiv(cardRecharge.getFaceVal() + ""));
		jsonobject.put("p_Yw_Type",findTrCodeNameByCodeType(sysActionLog.getDealCode()));
		jsonobject.put("p_Oper_Id", getUser().getUserId());
		jsonobject.put("p_Acpt_Branch", getSysBranchByUserId().getFullName());
		jsonobject.put("p_Rechg_Time", DateUtil.formatDate(sysActionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss"));*/
		//saveSysReport(sysActionLog, jsonobject, "/reportfiles/rechargecardsale.jasper", Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
		
		JSONObject json = new JSONObject();
		json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
		json.put(ReceiptContants.FIELD.DEAL_NO, sysActionLog.getDealNo()); // 交易流水号
		json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(sysActionLog.getDealCode())); // 交易类型
		json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportsmoneydiv(trServRec.getAmt() + "")); // 交易金额
		json.put(ReceiptContants.FIELD.IN_CARD_NO, cardBaseinfo.getCardNo()); // 转入卡号
		json.put(ReceiptContants.FIELD.IN_CUSTOMER_NAME, basePersonal.getName()); // 转入客户姓名
		json.put(ReceiptContants.FIELD.OUT_CARD_NO, cardRecharge.getCardNo()); // 转出卡号
		json.put(ReceiptContants.FIELD.IN_ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.add(accountDb.getBal() + "", cardRecharge.getFaceVal() + ""))); // 转入卡余额
		json.put(ReceiptContants.FIELD.OUT_ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv("0")); // 转出卡余额
		json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
		json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
		json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员工姓名
		json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(sysActionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
		this.saveSysReport(sysActionLog, json, ReceiptContants.TYPE.TRANSFER_ACCOUNTS, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);

		return trServRec;
	}

	/**
	 * 验证操作柜员信息
	 * @param userId
	 * @return
	 */
	public Users validUsers(String userId) throws CommonException{
		try{
			Users users = null;
			if(Tools.processNull(userId).replaceAll(" ","").equals("")){
				throw new CommonException("柜员编号不能为空！");
			}
			users = (Users) this.findOnlyRowByHql("from Users t where t.userId = '" + userId + "' and t.status = 'A'");
			if(users == null){
				throw new CommonException("柜员信息不存在或已注销！");
			}
			return users;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 验证卡片信息
	 * @param cardNo 验证卡号
	 * @param isExistHjl 是否验证灰记录信息
	 * @return
	 */
	public CardBaseinfo validCard(String cardNo,boolean isExistHjl) throws CommonException{
		try{
			CardBaseinfo card = null;
			if(Tools.processNull(cardNo).replaceAll(" ","").equals("")){
				throw new CommonException("卡号不能为空！");
			}
			card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
			if(card == null){
				throw new CommonException("卡片信息不存在！");
			}
			if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZC)){
				throw new CommonException("卡片状态不正常！当前状态：" + this.getCodeNameBySYS_CODE("CARD_STATE",card.getCardState()));
			}
			if(isExistHjl){
				List<?> list = this.findBySql("SELECT t.deal_no from ACC_INOUT_DETAIL t WHERE t.cr_card_no = '" + cardNo + "' AND t.deal_state = '" + Constants.TR_STATE_HJL + "'");
				if(list != null &&list.size() > 0){
					throw new CommonException("当前卡号存在灰记录，请先处理灰记录！");
				}
			}
			return card;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 根据卡号获取银行卡绑定信息及圈存限额信息
	 * @param cardNo卡号
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public Map getCardBindBankInfo(String cardNo,String type) throws CommonException{
		try{
			Map map = new HashMap();
			if(Tools.processNull(cardNo).equals("")){
				throw new CommonException("卡号不能为空！");
			}
			if(Tools.processNull(type).equals("")){
				throw new CommonException("限额类型不正确！");
			}
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo where cardNo = '" + cardNo + "'");
			if(card == null){
				throw new CommonException("根据卡号" + cardNo + "找不到卡信息！");
			}
			BasePersonal bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where customerId = '" + card.getCustomerId() + "'");
			if(bp == null){
				throw new CommonException("根据卡号" + cardNo + "找不到持卡客户信息！");
			}
			if(Constants.CARD_TYPE_QGN.equals(card.getCardType())){
				CardBindBankCard bind = (CardBindBankCard) this.findOnlyRowByHql("from CardBindBankCard where id.certNo = '" + bp.getCertNo() + "' and id.subCardNo = '" + card.getSubCardNo() + "'");
				if(bind == null){
					throw new CommonException("根据卡号" + cardNo + "找不到银行卡绑定信息！");
				} else if(Tools.processNull(bind.getBankId()).equals("")){
					throw new CommonException("绑定信息银行编号为空！");
				} else if(Tools.processNull(bind.getBankCardNo()).equals("")){
					throw new CommonException("绑定信息银行卡号为空！");
				}
				map.put("bankCardNo", bind.getBankCardNo());
				map.put("bankName", findOnlyFieldBySql("select t.bank_name from base_bank t where t.bank_id = '" + bind.getBankId() + "'"));
			} else if(Constants.CARD_TYPE_SMZK.equals(card.getCardType())) {
				if(Tools.processNull(card.getBankId()).equals("")){
					throw new CommonException("金融市民卡银行编号为空！");
				} else if(Tools.processNull(card.getBankCardNo()).equals("")){
					throw new CommonException("金融市民卡银行卡号为空！");
				}
				map.put("bankCardNo", card.getBankCardNo());
				map.put("bankName", findOnlyFieldBySql("select t.bank_name from base_bank t where t.bank_id = '" + card.getBankId() + "'"));
			} else {
				throw new CommonException("不支持的卡类型！");
			}
			AccQcqfLimit limit = (AccQcqfLimit) findOnlyRowByHql("from AccQcqfLimit where subCardNo = '" + card.getSubCardNo() + "'");
			if(limit == null){
				throw new CommonException("该卡未开通圈存！");
			} else if(!"0".equals(limit.getQcWay()) && !"1".equals(limit.getQcWay())){
				throw new CommonException("该卡未开通自主圈存或实时圈存！");
			}
			map.put("state", limit.getQcWay());
			List inParameters = new ArrayList();
			inParameters.add(card.getSubCardNo());
			inParameters.add(type);
			List outParameters = new ArrayList();
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List ret = this.publicDao.callProc("pk_service_outer.p_get_qcqf_limit",inParameters,outParameters);
			if(!(ret == null || ret.size() == 0)){
				int res = Integer.parseInt(ret.get(0).toString());
				if(res != 0){
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				}else{
					String[] limitAddr = Tools.processNull(ret.get(2)).split("\\$");
					map.put("qcLimitAmt",Arith.cardmoneydiv(limitAddr[0]));
					map.put("qcTodayNum",limitAddr[1]);
					map.put("qcTodayAmt",Arith.cardmoneydiv(limitAddr[2]));
					map.put("qcAvaiAmt",Arith.cardmoneydiv(limitAddr[3]));
					map.put("isSetLimit",Arith.cardmoneydiv(limitAddr[4]));
				}
			}else{
				throw new CommonException("查询圈存可用额度信息出现错误信息！");
			}
			return map;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 银行圈存到联机账户
	 * @param inParameters
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveOnAccRecharge(Map hm,Integer trCode)throws CommonException{
		try{
			//1.验证柜员是否存在
			String userId = Tools.processNull(hm.get("userId"));
			Users users = validUsers(userId);
			//2.卡状态验证
			String cardNo = Tools.processNull(hm.get("cardNo"));
			CardBaseinfo card = validCard(cardNo,false);
			BasePersonal person = new BasePersonal();
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				person = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(person == null){
					person = new BasePersonal();
				}
			}
			String bankCardNo, bankId;
			if(Constants.CARD_TYPE_QGN.equals(card.getCardType())){
				CardBindBankCard bind = (CardBindBankCard) this.findOnlyRowByHql("from CardBindBankCard where id.certNo = '" + person.getCertNo() + "' and id.subCardNo = '" + card.getSubCardNo() + "'");
				if(bind == null){
					throw new CommonException("根据卡号" + card.getCardNo() + "找不到银行卡绑定信息！");
				}
				if(Tools.processNull(bind.getBankId()).equals("")){
					throw new CommonException("银行卡绑定信息中银行编号不正确！");
				}
				if(Tools.processNull(bind.getBankCardNo()).equals("")){
					throw new CommonException("银行卡绑定信息中银行卡号不正确！");
				}
				bankCardNo = bind.getBankCardNo();
				bankId = bind.getBankId();
			} else if(Constants.CARD_TYPE_SMZK.equals(card.getCardType())) {
				bankCardNo = card.getBankCardNo();
				bankId = card.getBankId();
			} else {
				throw new CommonException("不支持的卡类型！");
			}
			if (Tools.processNull(bankId).equals("") || Tools.processNull(bankCardNo).equals("")) {
				throw new CommonException("银行编号和银行卡号为空！");
			}
			AccQcqfLimit limit = (AccQcqfLimit) findOnlyRowByHql("from AccQcqfLimit where subCardNo = '" + card.getSubCardNo() + "'");
			if(limit == null){
				throw new CommonException("该卡未开通圈存！");
			} else if(!"0".equals(limit.getQcWay()) && !"1".equals(limit.getQcWay())){
				throw new CommonException("该卡未开通自主圈存或实时圈存！");
			}
			// 验证交易密码
			String pwd = Tools.processNull(hm.get("pwd"));
			if (pwd.equals("")) {
				throw new CommonException("交易密码为空！");
			}
			pwd = doWorkClientService.encrypt_PinPwd(cardNo, pwd);
			if (!pwd.equals(card.getPayPwd())) {
				throw new CommonException("交易密码不正确！");
			}
			//3.获取充值金额和充值前金额验证充值是否超限
			String cardTypeString = this.getCodeNameBySYS_CODE("CARD_TYPE",card.getCardType());
			String amt = Tools.processNull(hm.get("amt"));//充值金额
			CardConfig cfg = (CardConfig) this.findOnlyRowByHql("from CardConfig t where t.cardType = '" + card.getCardType() + "'");
			if(cfg == null){
				throw new CommonException("该卡类型参数信息未配置，卡类型：" + cardTypeString);
			}
			if(Tools.processNull(cfg.getCashRechgLow()).equals("")){
				throw new CommonException("该卡类型联机账户充值最低限额参数未配置，卡类型：" + cardTypeString);
			}
			if(Tools.processNull(cfg.getAccCaseRechgLmt()).equals("")){
				throw new CommonException("该卡类型联机账户充值最高限额参数未配置，卡类型：" + cardTypeString);
			}
			if(cfg.getCashRechgLow() > Long.valueOf(amt)){
				throw new CommonException("圈存金额不能小于最低充值金额限制！<span style=\"color:red;\"><br>提示：最小充值金额 " +  Arith.cardreportsmoneydiv(cfg.getCashRechgLow() + "")   + "</span>");
			}
			AccAccountSub account = acc.getAccSubLedgerByCardNoAndAccKind(card.getCardNo(),Constants.ACC_KIND_ZJZH,"00");
			if(account == null){
				throw new CommonException("根据卡号" + card.getCardNo() + ",账户类型" + Constants.ACC_KIND_ZJZH + "未找到账户信息！");
			}
			if(cfg.getAccCaseRechgLmt() < (account.getBal() + Long.valueOf(amt))){
				throw new CommonException("圈存金额不能大于最高充值金额限制！<br><span style=\"color:red;\">提示：当前最大可充值金额 " +  Arith.cardreportsmoneydiv((cfg.getAccCaseRechgLmt() - account.getBal()) + "")   + "</span>");
			}
			if(Long.parseLong(amt)>(cfg.getAccOneAllowMax() == null ? 0 : cfg.getAccOneAllowMax())){
				throw new CommonException("单笔充值金额超过最大限制！<span style=\"color:red;\"><br>提示：单笔最大充值金额 " +  Arith.cardreportsmoneydiv(cfg.getAccOneAllowMax() + "")   + "</span>");
			}
			//4.记录操作日志
			SysActionLog log = (SysActionLog) hm.get("actionlog");
			if(log == null){
				throw new CommonException("圈存记录操作日志不能为空！");
			}
			if(!(log instanceof SysActionLog)){
				throw new CommonException("圈存记录操作日志不能为空！");
			}
			log.setDealCode(trCode);
			log.setMessage(this.findTrCodeNameByCodeType(trCode) + ",卡号:" + card.getCardNo() + ",银行卡卡号:" + bankCardNo);
			log.setNote(log.getMessage());
			publicDao.save(log);
			//6.登记业务信息（TR_SERV_REC）
			TrServRec serv = new TrServRec();
			serv.setDealNo(log.getDealNo());
			serv.setDealCode(trCode.intValue());
			serv.setCardNo(card.getCardNo());
			serv.setCardType(card.getCardType());
			serv.setAccKind(Constants.ACC_KIND_ZJZH);
			serv.setBizTime(log.getDealTime());
			serv.setUserId(log.getUserId());
			serv.setBrchId(users.getBrchId());
			serv.setAccNo(account.getAccNo() + "");
			serv.setCardAmt(1L);
			serv.setCardId(card.getCardId());
			serv.setOrgId(users.getOrgId());
			serv.setDealState(Constants.TR_STATE_ZC);
			serv.setClrDate(this.getClrDate());
			if(!Tools.processNull(hm.get("rechargeCardNo")).equals("")){
				//serv.setCard_No2(rechargecard.getCard_No());//充值卡卡号
				//serv.setCard_Type2(rechargecard.getCard_Type());//充值卡类型
			}
			serv.setCustomerId(person.getCustomerId() + "");
			serv.setCustomerName(person.getName());
			serv.setCertType(person.getCertType());
			serv.setCertNo(person.getCertNo());
			serv.setTelNo(person.getMobileNo());
			serv.setPrvBal(account.getBal());
			serv.setAcptType(Constants.ACPT_TYPE_GM);
			serv.setAmt(new Long(amt));//发生金额
			serv.setRsvOne(bankId);
			serv.setRsvTwo(bankCardNo);
			serv.setRsvThree("03");
			serv.setNote(log.getMessage());//备注
			publicDao.save(serv);
			//5.调接口记录交易
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("acptId",users.getBrchId());
			accMap.put("acptType","00");
			accMap.put("itemType","0001");
			accMap.put("cardNo",cardNo);
			accMap.put("accKind",Constants.ACC_KIND_ZJZH);
			accMap.put("amt",amt);
			accMap.put("source","03");
			accMap.put("sourceId",Tools.processNull(bankCardNo));
			accMap.put("sourceName","");
			accMap.put("sourceDesc",Tools.processNull(this.findOnlyFieldBySql("select bank_name from base_bank where bank_id = '" + bankId + "'")));
			accMap.put("dzAcptId",bankId);
			accMap.put("trBatchNo","");
			accMap.put("termTrNo",log.getDealNo() + "");
            acc.saveOnLineAccRecharge(log,accMap);            
			//7.保存凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE,"银行卡圈存"); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportsmoneydiv(serv.getAmt() + ""));
			json.put(ReceiptContants.FIELD.CARD_NO, cardNo); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, person.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, person.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.add(account.getBal() + "", amt))); // 充值后账户余额
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(log,json,ReceiptContants.TYPE.CASH_RECHARGE, Constants.APP_REPORT_TYPE_PDF, 1L,"",null);
			//8.调前置接口通知银行
            JSONArray list = new JSONArray();
            JSONObject firstObj = new JSONObject();
            firstObj.put("trcode","B0059");
            firstObj.put("bizid",Tools.processNull(bankId));
            firstObj.put("operid",Tools.processNull(log.getUserId()));
            firstObj.put("termno",Tools.processNull(log.getDealNo()));
            firstObj.put("cardno",Tools.processNull(card.getSubCardNo()));
            firstObj.put("amt",Tools.processNull(amt));
            firstObj.put("balance",Tools.processNull(account.getBal()));
            firstObj.put("sfz",Tools.processNull(person.getCertNo()));
            firstObj.put("name",Tools.processNull(person.getName()));
            firstObj.put("bankcardno",Tools.processNull(bankCardNo));
            firstObj.put("date",Tools.processNull(DateUtil.formatDate(log.getDealTime(),"yyyyMMdd")));
            firstObj.put("time",Tools.processNull(DateUtil.formatDate(log.getDealTime(),"HHmmss")));
            firstObj.put("banktradeno","");
            firstObj.put("clrdate","");
            list.add(firstObj);
            JSONArray return_parameters = doWorkClientService.invoke(list);
            if(return_parameters == null || return_parameters.isEmpty()){
				throw new CommonException("调银行接口返回null");
			}
			JSONObject return_first = return_parameters.getJSONObject(0);
			if(return_first == null || return_first.isEmpty()){
				throw new CommonException("调银行接口节点为空！");
			}
			if(!Tools.processNull(return_first.getString("errcode")).equals("00")){
				throw new CommonException("银行返回失败【" + Tools.processNull(return_first.getString("errmessage")) + "】");
			}
			return serv;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 联机账户圈提到银行卡 
	 * @param inParameters
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveOnAccRechargeToBank(Map hm,Integer trCode)throws CommonException{
		try{
			//1.验证柜员是否存在
			String userId = Tools.processNull(hm.get("userId"));
			Users users = validUsers(userId);
			//2.卡状态验证
			String cardNo = Tools.processNull(hm.get("cardNo"));
			CardBaseinfo card = validCard(cardNo,false);
			BasePersonal person = new BasePersonal();
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				person = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(person == null){
					person = new BasePersonal();
				}
			}
			String bankId, bankCardNo;
			if (card.getCardType().equals(Constants.CARD_TYPE_QGN)) {
				CardBindBankCard bind = (CardBindBankCard) findOnlyRowByHql("from CardBindBankCard where id.certNo = '" 
						+ person.getCertNo() + "' and id.subCardNo = '" + card.getSubCardNo() + "'");
				if (bind == null) {
					throw new CommonException("根据卡号" + card.getCardNo() + "找不到银行卡绑定信息！");
				}
				if (Tools.processNull(bind.getBankId()).equals("")) {
					throw new CommonException("银行卡绑定信息中银行编号不正确！");
				}
				if (Tools.processNull(bind.getBankCardNo()).equals("")) {
					throw new CommonException("银行卡绑定信息中银行卡号不正确！");
				}
				bankCardNo = bind.getBankCardNo();
				bankId = bind.getBankId();
			} else if (Constants.CARD_TYPE_SMZK.equals(card.getCardType())) {
				bankCardNo = card.getBankCardNo();
				bankId = card.getBankId();
			} else {
				throw new CommonException("不支持的卡类型！");
			}
			if (Tools.processNull(bankId).equals("") || Tools.processNull(bankCardNo).equals("")) {
				throw new CommonException("银行编号和银行卡号为空！");
			}
			// 验证交易密码
			String pwd = Tools.processNull(hm.get("pwd"));
			if (pwd.equals("")) {
				throw new CommonException("交易密码为空！");
			}
			pwd = doWorkClientService.encrypt_PinPwd(cardNo, pwd);
			if (!pwd.equals(card.getPayPwd())) {
				throw new CommonException("交易密码不正确！");
			}
			//3.判断圈提金额是否大于账户余额
			String amt = Tools.processNull(hm.get("amt"));//充值金额
			AccAccountSub account = acc.getAccSubLedgerByCardNoAndAccKind(card.getCardNo(),Constants.ACC_KIND_ZJZH,"00");
			if(account == null){
				throw new CommonException("根据卡号" + card.getCardNo() + ",账户类型" + Constants.ACC_KIND_ZJZH + "未找到账户信息！");
			}
			if(account.getBal() < Long.valueOf(amt)){
				throw new CommonException("圈提金额不能大于账户金额！<span style=\"color:red;\"><br>提示：账户最大可圈提金额 " +  Arith.cardreportsmoneydiv(account.getBal() + "")   + "</span>");
			}
			//4.记录操作日志
			SysActionLog log = (SysActionLog) hm.get("actionlog");
			if(log == null){
				throw new CommonException("圈提记录操作日志不能为空！");
			}
			if(!(log instanceof SysActionLog)){
				throw new CommonException("圈提记录操作日志不能为空！");
			}
			log.setDealCode(trCode);
			log.setMessage("银行卡圈提" + ",卡号:" + card.getCardNo() + ",银行卡卡号:" + bankCardNo);
			log.setNote(log.getMessage());
			publicDao.save(log);
			//6.登记业务信息（TR_SERV_REC）
			TrServRec serv = new TrServRec();
			serv.setDealNo(log.getDealNo());
			serv.setDealCode(trCode.intValue());
			serv.setCardNo(card.getCardNo());
			serv.setCardType(card.getCardType());
			serv.setAccKind(Constants.ACC_KIND_ZJZH);
			serv.setBizTime(log.getDealTime());
			serv.setUserId(log.getUserId());
			serv.setBrchId(users.getBrchId());
			serv.setAccNo(account.getAccNo() + "");
			serv.setCardAmt(1L);
			serv.setCardId(card.getCardId());
			serv.setOrgId(users.getOrgId());
			serv.setDealState(Constants.TR_STATE_ZC);
			serv.setClrDate(this.getClrDate());
			serv.setCustomerId(person.getCustomerId() + "");
			serv.setCustomerName(person.getName());
			serv.setCertType(person.getCertType());
			serv.setCertNo(person.getCertNo());
			serv.setTelNo(person.getMobileNo());
			serv.setPrvBal(account.getBal());
			serv.setAcptType(Constants.ACPT_TYPE_GM);
			serv.setAmt(new Long(Arith.add("0", amt)));//发生金额
			serv.setRsvOne(bankId);
			serv.setRsvTwo(bankCardNo);
			serv.setRsvThree("04");
			serv.setNote(log.getMessage());//备注
			publicDao.save(serv);
			//5.调接口记录交易
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(log.getDealNo())).append("|");//1.流水号
			inpara.append(Tools.processNull("30105070")).append("|");//2.交易代码 交易代码为30105010或30105090，不可传入其他交易码
			inpara.append(Tools.processNull("0002")).append("|");//3.交易类型 0001 充值  0002 消费  0003 未登项圈提到电子钱包
			inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime()))).append("|");//4.操作时间
			inpara.append(Tools.processNull("00")).append("|");//5.受理点分类 ---》2合作机构
			inpara.append(Tools.processNull(log.getBrchId())).append("|");;//6.受理点编号
			inpara.append(Tools.processNull(log.getUserId())).append("|");//7.操作员
			inpara.append(Tools.processNull(hm.get("trBatchNo"))).append("|");;//8.批次号
			inpara.append(Tools.processNull(log.getDealNo())).append("|");//9.终端交易流水号
			inpara.append(Tools.processNull("03")).append("|");//10.来源 00：柜面 01：支付宝 02 微信 03 银行 04待定   99其他
			inpara.append(Tools.processNull(bankCardNo)).append("|");//11.卡号充值方id（if source = 01 then 支付宝账号 elsif source = 02 微信账号 elsif 银行账号...else ... end if）
			inpara.append(Tools.processNull(hm.get("sourceName"))).append("|");//12.充值方名称 （if source = 01 then 支付宝户名 elsif source = 02 微信名 elsif 银行户名...else ... end if）
			inpara.append(Tools.processNull(this.findOnlyFieldBySql("select bank_name from base_bank where bank_id = '" + bankId + "'"))).append("|");//13.自定义字段（比如说银行充值时，可以用中文描叙银行名称）
			inpara.append(Tools.processNull(account.getAccKind())).append("|");//14.账户类型
			inpara.append("" + Tools.processNull(amt)).append("|");//15.充值金额
			inpara.append(Tools.processNull(account.getBal())).append("|");//16.账户交易前金额
			if(!Tools.processNull(account.getAccKind()).equals(Constants.ACC_KIND_QBZH) && !Tools.processNull(account.getAccKind()).equals(Constants.ACC_KIND_JFZH)){
				if(!doWorkClientService.money2EncryptCal(Tools.processNull(hm.get("cardNo")),Tools.processNull(account.getBal()),"0",Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB).equals(account.getBalCrypt())){
					throw new CommonException("账户交易的明文和密文不一致！");
				}
				inpara.append(doWorkClientService.money2EncryptCal(Tools.processNull(card.getCardNo()),Tools.processNull(account.getBal()),Tools.processNull(amt),Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB)); 
				inpara.append("|");
			}else{
				inpara.append("").append("|");
			}
			inpara.append(Tools.processNull(card.getCardNo())).append("|");//18.卡号
			inpara.append(Tools.processNull(bankId)).append("|");//20.对账主体编号 必须输入
			List<Object> in = new java.util.ArrayList<Object>();
			in.add(inpara.toString());
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			List ret = publicDao.callProc("pk_co_service.online_qt_handle",in,out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(1).toString());
				if (res != 0) {
					String outMsg = ret.get(2).toString();
					throw new CommonException(outMsg);
				} 
			} else {
				throw new CommonException("圈提记录出错！");
			}        
			//7.保存凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE,"银行卡圈提"); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportsmoneydiv(amt + ""));
			json.put(ReceiptContants.FIELD.CARD_NO, cardNo); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, person.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, person.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.sub(account.getBal() + "", amt))); // 充值后账户余额
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(log,json,ReceiptContants.TYPE.CASH_RECHARGE, Constants.APP_REPORT_TYPE_PDF, 1L,"",null);
			//8.调前置接口通知银行
            JSONArray list = new JSONArray();
            JSONObject firstObj = new JSONObject();
            firstObj.put("trcode","B0061");
            firstObj.put("bizid",Tools.processNull(bankId));
            firstObj.put("operid",Tools.processNull(log.getUserId()));
            firstObj.put("termno",Tools.processNull(log.getDealNo()));
            firstObj.put("cardno",Tools.processNull(card.getSubCardNo()));
            firstObj.put("amt",Tools.processNull(amt));
            firstObj.put("balance",Tools.processNull(account.getBal()));
            firstObj.put("sfz",Tools.processNull(person.getCertNo()));
            firstObj.put("name",Tools.processNull(person.getName()));
            firstObj.put("bankcardno",Tools.processNull(bankCardNo));
            firstObj.put("date",Tools.processNull(DateUtil.formatDate(log.getDealTime(),"yyyyMMdd")));
            firstObj.put("time",Tools.processNull(DateUtil.formatDate(log.getDealTime(),"HHmmss")));
            firstObj.put("banktradeno","");
            firstObj.put("clrdate","");
            list.add(firstObj);
            JSONArray return_parameters = doWorkClientService.invoke(list);
            if(return_parameters == null || return_parameters.isEmpty()){
				throw new CommonException("调银行接口返回null");
			}
			JSONObject return_first = return_parameters.getJSONObject(0);
			if(return_first == null || return_first.isEmpty()){
				throw new CommonException("调银行接口节点为空！");
			}
			if(!Tools.processNull(return_first.getString("errcode")).equals("00")){
				throw new CommonException(Tools.processNull(return_first.getString("errmessage")));
			}
			return serv;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	public AccAcountService getAcc() {
		return acc;
	}
	public void setAcc(AccAcountService acc) {
		this.acc = acc;
	}
	public DoWorkClientService getDoWorkClientService() {
		return doWorkClientService;
	}
	public void setDoWorkClientService(DoWorkClientService doWorkClientService) {
		this.doWorkClientService = doWorkClientService;
	}

	@SuppressWarnings("unchecked")
	@Override
	public TrServRec saveHkzzGoodCard(Map<String, Object> inParameters) {
		try {
			// 1.转出卡信息判断
			String operId = Tools.processNull(inParameters.get("userId"));
			String outCardNo = (String) inParameters.get("outCardNo");
			String outAccKind = (String) inParameters.get("outAccKind");
			Long amt = Tools.processNull(inParameters.get("amt")).trim().equals("") ? 0L : Long.valueOf(inParameters.get("amt").toString().trim());
			if (Tools.processNull(operId).equals("")) {
				throw new CommonException("柜员编号不能为空！");
			}
			Users oper = this.validUsers(operId);
			if (Tools.processNull(inParameters.get("dealCode")).equals("")) {
				throw new CommonException("交易代码不能为空！");
			}
			if (!Tools.processNull(inParameters.get("dealState")).equals(Constants.TR_STATE_ZC) && !Tools.processNull(inParameters.get("dealState")).equals(Constants.TR_STATE_HJL)) {
				throw new CommonException("转账记录状态只能是0或9！");
			}
			if (Tools.processNull(outCardNo).equals("")) {
				throw new CommonException("转出卡卡号不能为空！");
			}
			if (Tools.processNull(outAccKind).equals("")) {
				throw new CommonException("转出卡转出账户类型不能为空！");
			}
			CardBaseinfo outCardBaseinfo = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + outCardNo + "'");
			if (outCardBaseinfo == null) {
				throw new CommonException("根据转出卡卡号未找到卡信息！");
			}
			if (!Tools.processNull(outCardBaseinfo.getCardState()).equals(Constants.CARD_STATE_ZX)) {
				throw new CommonException("转出卡卡状态不是注销状态！");
			}
			if (Tools.processNull(inParameters.get("isJudgeOutCardHjl")).equals(Constants.STATE_ZC)) {
				List<?> hjlList = this.findBySql("SELECT t.deal_no from ACC_INOUT_DETAIL t WHERE t.cr_card_no = '" + outCardBaseinfo.getCardNo() + "' AND t.deal_state = '" + Constants.TR_STATE_HJL + "'");
				if (hjlList != null && hjlList.size() > 0) {
					throw new CommonException("转出卡有未处理的灰记录，请先处理灰记录！");
				}
			}
			BasePersonal outBasePersonal = (BasePersonal) findOnlyRowByHql("from BasePersonal b where b.customerId = '" + outCardBaseinfo.getCustomerId() + "'");
			if (outBasePersonal == null) {
				outBasePersonal = new BasePersonal();
			}
			String ecrpwd = "";
			if (Tools.processNull(inParameters.get("isJudgeOutAccPwd")).equals(Constants.STATE_ZC)) {
				if (Tools.processNull(inParameters.get("pwd")).equals("")) {
					throw new CommonException("请输入转出卡转出账户密码！");
				}
				ecrpwd = doWorkClientService.encrypt_PinPwd(outCardBaseinfo.getCardNo(), inParameters.get("pwd").toString());
				if (Tools.processNull(outCardBaseinfo.getPayPwd()).equals(ecrpwd)) {
					throw new CommonException("转出卡转出账户密码不正确！");
				}
			}
			AccAccountSub outAcc = acc.getAccSubLedgerByCardNoAndAccKind(outCardBaseinfo.getCardNo(), outAccKind, "00");
			if (outAcc == null) {
				throw new CommonException("转出卡号" + this.getCodeNameBySYS_CODE("ACC_KIND", outAccKind) + "账户不存在！");
			} else if (!"0".equals(outAcc.getBalRslt())) { // 判断余额处理状态
				throw new CommonException("转出卡号" + this.getCodeNameBySYS_CODE("ACC_KIND", outAccKind) + "【账户余额状态】为【已处理】，不能进行转账！");
			}
			if (amt == 0L) {
				throw new CommonException("转账金额不能为空或0！");
			}
			
			// 2.转入卡信息判断
			String inCardNo = (String) inParameters.get("inCardNo");
			if (Tools.processNull(inCardNo).equals("")) {
				throw new CommonException("转入卡卡号不能为空！");
			}
			String inAccKind = (String) inParameters.get("inAccKind");
			if (Tools.processNull(outAccKind).equals("")) {
				throw new CommonException("转入卡转入账户类型不能为空！");
			}
			CardBaseinfo inCardBaseinfo = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + inCardNo + "'");
			if (inCardBaseinfo == null) {
				throw new CommonException("根据转入卡卡号未找到卡信息！");
			}
			if (!Tools.processNull(inCardBaseinfo.getCardState()).equals(Constants.CARD_STATE_ZC)) {
				throw new CommonException("转入卡卡状态不是正常状态！");
			}
			if (Tools.processNull(inParameters.get("isJudgeInCardHjl")).equals(Constants.STATE_ZC)) {
				List<?> hjlList = this.findBySql("SELECT t.deal_no from ACC_INOUT_DETAIL t WHERE t.cr_card_no = '" + inCardBaseinfo.getCardNo() + "' AND t.deal_state = '" + Constants.TR_STATE_HJL + "'");
				if (hjlList != null && hjlList.size() > 0) {
					throw new CommonException("转入卡有未处理的灰记录，请先处理灰记录！");
				}
			}
			BasePersonal inBasePersonal = (BasePersonal) findOnlyRowByHql("from BasePersonal b where b.customerId = '" + outCardBaseinfo.getCustomerId() + "'");
			if (inBasePersonal == null) {
				inBasePersonal = new BasePersonal();
			}
			AccAccountSub inAcc = acc.getAccSubLedgerByCardNoAndAccKind(inCardBaseinfo.getCardNo(), inAccKind, "00");
			if (inAcc == null) {
				throw new CommonException("转入卡号" + this.getCodeNameBySYS_CODE("ACC_KIND", inAccKind) + "不存在！");
			}
			
			// 3.转账信息判断
			CardConfig cardConfig = (CardConfig) findOnlyRowByHql("from CardConfig t where t.cardType = '" + outCardBaseinfo.getCardType() + "'");
			if (cardConfig == null) {
				throw new CommonException("转入卡卡类型配置参数信息不存在！");
			}
			if (Tools.processNull(inAccKind).equals(Constants.ACC_KIND_QBZH)) {
				if (Tools.processNull(cardConfig.getWalletCaseRechgLmt()).equals("")) {
					throw new CommonException("转入卡卡类型账户限额信息不存在！");
				}
				if (Long.valueOf(Arith.add(inAcc.getBal() + "", amt + "")) > cardConfig.getWalletCaseRechgLmt()) {
					throw new CommonException("转入卡转账后账户余额大于该卡类型账户限额！");
				}
			} else {
				if (Tools.processNull(cardConfig.getAccCaseRechgLmt()).equals("")) {
					throw new CommonException("转入卡卡类型账户限额信息不存在！");
				}
				if (Long.valueOf(Arith.add(inAcc.getBal() + "", amt + "")) > cardConfig.getAccCaseRechgLmt()) {
					throw new CommonException("转入卡转账后账户余额大于该卡类型账户限额！");
				}
			}
			
			// 4.记录操作日志
			SysActionLog sysActionLog = getCurrentActionLog();
			sysActionLog.setDealCode(Integer.valueOf(Tools.processNull(inParameters.get("dealCode"))));
			sysActionLog.setMessage(this.findTrCodeNameByCodeType(sysActionLog.getDealCode()) + "[转出卡号:" + outCardNo + ",转入卡号:" + inCardNo + "转账金额:" + Arith.cardreportsmoneydiv(amt.toString()) + "]");
			publicDao.save(sysActionLog);
			
			// 5.账户余额小于卡面余额，补账
			if (outAcc.getBal() < amt) { 
				List<Object> in = new java.util.ArrayList<Object>();
				StringBuffer inpara = new StringBuffer();
				inpara.append(sysActionLog.getBrchId()).append("|"); // 1.网点编号
				inpara.append(sysActionLog.getUserId()).append("|"); // 2.柜员编号
				inpara.append(sysActionLog.getDealNo()).append("|"); // 3.业务流水
				inpara.append(DealCode.BHK_QB_ZZ_BZ).append("|"); // 4.交易代码
				inpara.append(outCardBaseinfo.getCardNo()).append("|"); // 5.卡号
				inpara.append(Constants.ACC_KIND_QBZH).append("|"); // 6.账户类型
				inpara.append(amt).append("|"); // 7.卡面金额
				inpara.append(Tools.processNull(inParameters.get("outCardTrCount"))).append("|"); // 8.卡计数器
				inpara.append(DateUtil.formatDate(sysActionLog.getDealTime())).append("|"); // 9.业务时间
				inpara.append("好卡换卡转钱包补账交易，卡面金额：" + amt / 100); // 10.备注
				in.add(inpara.toString());
				List<Integer> out = new java.util.ArrayList<Integer>();
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				try {
					List ret = publicDao.callProc("PK_SERVICE_OUTER.P_BHZ_ZZ_BZ", in,out);
					if (!(ret == null || ret.size() == 0)) {
						int res = Integer.parseInt(ret.get(0).toString());
						if (res != 0) {
							String outMsg = ret.get(1).toString();
							throw new CommonException(outMsg);
						}
					} else {
						throw new CommonException("换卡转钱包补账出错！");
					}
				} catch (Exception ex) {
					throw new CommonException(ex.getMessage());
				}
			}
			
			// 5.调用转账存储过程
			HashMap<String, String> accMap = new HashMap<String, String>();
			accMap.put("acpt_id", oper.getBrchId());// 受理点编号
			accMap.put("acpt_type", Constants.ACPT_TYPE_GM);// 受理点分类
			accMap.put("tr_batch_no", Tools.processNull(inParameters.get("trBatchNo")));// 批次号
			accMap.put("term_tr_no", Tools.processNull(inParameters.get("termTrNo")));// 终端交易流水号
			accMap.put("card_no1", outCardNo);// 转出卡号
			accMap.put("card_tr_count1", Tools.processNull(inParameters.get("outCardTrCount")));// 转出卡交易计数器
			accMap.put("card_bal1", Tools.processNull(inParameters.get("outCardAmt")));// 转出卡钱包交易前金额
			accMap.put("acc_kind1", outAccKind); // 转出卡账户类型
			accMap.put("wallet_id1", "00");// 转出卡钱包编号 默认00
			accMap.put("card_no2", inCardNo);// 转入卡号
			accMap.put("card_tr_count2", Tools.processNull(inParameters.get("inCardTrCount")));// 转入卡交易计数器
			accMap.put("card_bal2", Tools.processNull(inParameters.get("inCardAmt")));// 转入卡钱包交易前金额
			accMap.put("acc_kind2", inAccKind);// 转入卡账户类型
			accMap.put("tr_amt", amt + "");// 转账金额
			accMap.put("wallet_id2", "00");// 转入卡钱包编号 默认00
			accMap.put("tr_state", Tools.processNull(inParameters.get("dealState")));
			accMap.put("pwd", "");// 转账密码
			acc.transfer(sysActionLog, accMap);
			
			// 6.记录业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(sysActionLog.getDealNo());
			trServRec.setDealCode(sysActionLog.getDealCode());
			trServRec.setCardId(inCardBaseinfo.getCardId());
			trServRec.setCardNo(inCardBaseinfo.getCardNo());
			trServRec.setCardType(inCardBaseinfo.getCardType());
			trServRec.setCertType(inBasePersonal.getCertType());
			trServRec.setCertNo(inBasePersonal.getCertNo());
			trServRec.setCustomerId(inBasePersonal.getCustomerId().toString());
			trServRec.setCustomerName(inBasePersonal.getName());
			trServRec.setBizTime(sysActionLog.getDealTime());
			trServRec.setPrvBal(Long.valueOf(inParameters.get("inCardAmt").toString()));
			trServRec.setCardTrCount(inParameters.get("inCardTrCount").toString());
			trServRec.setOldCardNo(outCardBaseinfo.getCardNo());
			trServRec.setAmt(amt);
			trServRec.setCardAmt(1l);
			trServRec.setDealState("9");
			trServRec.setClrDate(getClrDate());
			trServRec.setBrchId(sysActionLog.getBrchId());
			trServRec.setUserId(sysActionLog.getUserId());
			trServRec.setAccNo(inAcc.getAccNo().toString());
			trServRec.setAccKind(inAcc.getAccKind());
			trServRec.setNote(sysActionLog.getMessage());
			trServRec.setAgtCertType(Tools.processNull(inParameters.get("agtCertType")));
			trServRec.setAgtCertNo(Tools.processNull(inParameters.get("agtCertNo")));
			trServRec.setAgtName(Tools.processNull(inParameters.get("agtName")));
			trServRec.setAgtTelNo(Tools.processNull(inParameters.get("agtTelNo")));
			publicDao.save(trServRec);
			
			// 7.打印凭证（换卡转钱包凭证）
			JSONObject report = new JSONObject();
			report.put("p_Title",Constants.APP_REPORT_TITLE + findTrCodeNameByCodeType(trServRec.getDealCode()) + "凭证");
			report.put("yewuleixing", findTrCodeNameByCodeType(trServRec.getDealCode()));
			report.put("p_DealNo",trServRec.getDealNo());
			report.put("p_CardNo1",trServRec.getOldCardNo());
			report.put("p_CertNo1",outBasePersonal.getCertNo() );
			report.put("p_CustomerName1",trServRec.getCustomerName());
			report.put("p_Brch",getSessionSysBranch().getFullName());
			report.put("p_CardNo2",trServRec.getCardNo());
			report.put("p_CustomerName2",trServRec.getCustomerName());
			report.put("p_PrintTime",DateUtil.formatDate(trServRec.getBizTime(),"yyyy-MM-dd HH:mm:ss"));
			report.put("p_DbBalance","0");
			report.put("p_CrBalance",Arith.cardreportsmoneydiv(Arith.add(trServRec.getPrvBal() + "",trServRec.getAmt() + "")));
			report.put("p_Amt",Arith.cardreportsmoneydiv(trServRec.getAmt() + ""));
			report.put("tel",trServRec.getAgtTelNo());
			report.put("agtTel",trServRec.getAgtTelNo());
			report.put("p_UserId",oper.getUserId());
			report.put("p_UserName",oper.getName());
			this.saveSysReport(sysActionLog,report,"/reportfiles/BhkQianBZZ.jasper",Constants.APP_REPORT_TYPE_PDF,0L,"",null);
			return trServRec;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	@Override
	public long saveImportAccBalReturnData(File file) {
		Workbook workbook = null;
		try {
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.BALANCE_RESTORE_IMPORT);
			log.setMessage("车改回退导入");
			publicDao.save(log);
			//
			workbook = new HSSFWorkbook(new FileInputStream(file));
			Sheet sheet = workbook.getSheetAt(0);
			Date now = new Date();

			int lastRowNum = sheet.getLastRowNum();
			for (int i = 1; i <= lastRowNum; i++) {
				Row row = sheet.getRow(i);
				if (row == null) {
					continue;
				}
				Cell nameCell = row.getCell(2);
				nameCell.setCellType(Cell.CELL_TYPE_STRING);
				Cell certNoCell = row.getCell(3);
				certNoCell.setCellType(Cell.CELL_TYPE_STRING);
				Cell subCardNoCell = row.getCell(4);
				subCardNoCell.setCellType(Cell.CELL_TYPE_STRING);
				Cell bankCell = row.getCell(5);
				bankCell.setCellType(Cell.CELL_TYPE_STRING);
				Cell bankCardNoCell = row.getCell(6);
				bankCardNoCell.setCellType(Cell.CELL_TYPE_STRING);
				Cell bankAddrCell = row.getCell(7);
				bankAddrCell.setCellType(Cell.CELL_TYPE_STRING);
				Cell remainBalCell = row.getCell(8);
				remainBalCell.setCellType(Cell.CELL_TYPE_STRING);

				String name = nameCell.getStringCellValue().trim();
				String certNo = certNoCell.getStringCellValue().trim().toUpperCase();
				String subCardNo = subCardNoCell.getStringCellValue().trim().toUpperCase();
				String bankCardNo = bankCardNoCell.getStringCellValue().replace(" ", "").trim();
				String bankName = bankCell.getStringCellValue().replace(" ", "").trim();
				String bankAddr = bankAddrCell.getStringCellValue().trim();
				if (name.equals("") || certNo.equals("") || subCardNo.equals("") || bankCardNo.equals("")) {
					continue;
				}
				long remainBal = (long) (Double.valueOf(remainBalCell.getStringCellValue().trim()) * 100);

				publicDao.doSql("insert into acc_bal_return (deal_no, name, cert_no, sub_card_no, bank_card_no, remain_bal, state, return_date, brch_id, user_id, bank_name, bank_addr) "
								+ "values ('" + log.getDealNo() + "', '" + name + "','" + certNo + "','" + subCardNo
								+ "','" + bankCardNo + "','" + remainBal + "','1',to_date('"
								+ DateUtil.formatDate(now, "yyyy-MM-dd HH:mm:ss") + "','yyyy-mm-dd hh24:mi:ss'), '"
								+ log.getBrchId() + "', '" + log.getUserId() + "', '" + bankName + "', '" + bankAddr + "')");
			}
			return log.getDealNo();
		} catch (Exception e) {
			throw new CommonException("导入文件失败，" + e.getMessage());
		} finally {
			try {
				workbook.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	@Override
	public void saveProcessAccBalReturnData(long dealNo) {
		try {
			List<Object[]> list = findBySql("select name, cert_no, sub_card_no, remain_bal from acc_bal_return where deal_no = '" + dealNo + "'");
			for (Object[] item : list) {
				BasePersonal person = (BasePersonal) findOnlyRowByHql("from BasePersonal where name = '" + item[0] + "' and cert_no = '" + item[1] + "'");
				if (person == null) {
					int n = publicDao.doSql("update acc_bal_return set note = '人员信息不存在' where cert_no = '" + item[1] + "' and deal_no = '" + dealNo + "'");
					if (n != 1) {
						throw new CommonException("【" + person.getName() + "】有多条回退信息1");
					}
					continue;
				}
				//
				CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where customerId = '" + person.getCustomerId() + "' and subCardNo = '" + item[2] + "' and cardState = '1'");
				if (card == null) {
					int n = publicDao.doSql("update acc_bal_return set note = '卡片信息不存在' where cert_no = '" + item[1]
							+ "' and deal_no = '" + dealNo + "'");
					if (n != 1) {
						throw new CommonException("【" + person.getName() + "】有多条回退信息2");
					}
					continue;
				}
				//
				AccAccountSub acc = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where cardNo = '" + card.getCardNo() + "' and accKind = '" + Constants.ACC_KIND_ZJZH + "'");
				if (acc == null) {
					int n = publicDao.doSql("update acc_bal_return set note = '联机账户信息不存在' where cert_no = '" + item[1]
							+ "' and deal_no = '" + dealNo + "'");
					if (n != 1) {
						throw new CommonException("【" + person.getName() + "】有多条回退信息3");
					}
					continue;
				}
				long returnBal = acc.getBal() - ((BigDecimal) item[3]).longValue();
				if(returnBal < 0){
					int n = publicDao.doSql("update acc_bal_return set note = '返还金额大于账户余额' where cert_no = '" + item[1]
							+ "' and deal_no = '" + dealNo + "'");
					if (n != 1) {
						throw new CommonException("【" + person.getName() + "】有多条回退信息4");
					}
				}
				int n = publicDao.doSql("update acc_bal_return set card_no = '" + card.getCardNo() + "', acc_bal = '"
						+ acc.getBal() + "', return_bal = '" + returnBal + "' where cert_no = '" + item[1]
						+ "' and deal_no = '" + dealNo + "'");
				if (n != 1) {
					throw new CommonException("【" + person.getName() + "】有多条回退信息5");
				}
				continue;
			}
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	@Override
	public void saveReturn(Long dealNo) {
		// TODO Auto-generated method stub
		
	}
	@Override
	public void saveReturn(String certNo, Long dealNo) {
		try {
			Object[] item = (Object[]) findOnlyRowBySql("select card_no, return_bal, remain_bal from acc_bal_return where cert_no = '" + certNo + "' and deal_no = '" + dealNo + "'");
			try {
				saveConfirmReturnCash((String) item[0], ((BigDecimal) item[1]).longValue());
			} catch (Exception e) {
				if(e instanceof CommonException && ((CommonException) e).getErrorCode() == 9){ // 余额不足
					int n = publicDao.doSql("update acc_bal_return set state = '0', note = '返还成功' where cert_no = '" + certNo + "' and deal_no = '" + dealNo + "'");
				} else {
					throw e;
				}
			}
			BigDecimal acc = (BigDecimal) findOnlyRowBySql("select bal from Acc_Account_Sub where card_No = '" + item[0]
					+ "' and acc_Kind = '" + Constants.ACC_KIND_ZJZH + "'");
			int n = publicDao.doSql("update acc_bal_return set state = '0', after_acc_bal = '" + acc.longValue()
					+ "', note = '返还成功' where cert_no = '" + certNo + "' and deal_no = '" + dealNo + "'");
			if (n != 1) {
				throw new CommonException("return n1 != 1");
			}

			long remianBal = ((BigDecimal) item[2]).longValue();
			long accBal = acc.longValue();
			if (accBal != remianBal) {
				throw new CommonException("余额不对");
			}
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	
	public void saveConfirmReturnCash(String cardNo, Long amt) {
		try {
			SysActionLog log = (SysActionLog) BeanUtils.cloneBean(getCurrentActionLog());
			log.setDealCode(DealCode.BALANCE_RESTORE_CONFIRM);
			log.setMessage("手工余额返还, 返还金额：" + (float) amt / 100);
			publicDao.save(log);

			CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where cardNo = '" + cardNo + "'");
			if (card == null) {
				throw new CommonException("卡片信息不存在！");
			} else if (!card.getCardState().equals(Constants.CARD_STATE_ZC)) {
				throw new CommonException("卡片状态不正常！");
			}

			// 3.返还联机账户
			AccAccountSub accAccountSub = (AccAccountSub) findOnlyRowByHql("from AccAccountSub t where t.cardNo = '"
					+ cardNo + "' and accKind = '" + Constants.ACC_KIND_ZJZH + "'");
			if (accAccountSub == null) {
				throw new CommonException("联机账户不存在！");
			} else if (accAccountSub.getBal() <= 0) {
				throw new CommonException(9, "联机账户余额不足！");
			} else if (!accAccountSub.getBalRslt().equals("0")) {
				throw new CommonException("联机账户余额状态为【已处理】！");
			}
			long temoFrzAmt = 0L;
			if (accAccountSub.getFrzAmt() == null) {
				temoFrzAmt = 0L;
			} else {
				temoFrzAmt = accAccountSub.getFrzAmt();
			}
			if (accAccountSub.getBal() - temoFrzAmt < amt) {
				throw new CommonException("联机账户余额不足！");
			}

			// 返还
			HashMap hm = new HashMap();
			hm.put("acpt_id", log.getBrchId());
			hm.put("oper_id", log.getUserId());
			hm.put("tr_batch_no", null);
			hm.put("term_tr_no", null);
			hm.put("card_no", cardNo);
			hm.put("card_tr_count1", null);
			hm.put("card_bal", null);
			hm.put("acc_kind", accAccountSub.getAccKind());
			hm.put("wallet_id", "00");
			hm.put("tr_amt", amt);
			hm.put("acpt_type", Constants.ACPT_TYPE_GM);
			acc.returnCash(log, hm);

			// 业务日志
			TrServRec newRec = new TrServRec();
			newRec.setDealNo(log.getDealNo());
			newRec.setDealCode(log.getDealCode());
			newRec.setBizTime(log.getDealTime());
			newRec.setBrchId(log.getBrchId());
			newRec.setUserId(log.getUserId());
			newRec.setCustomerId(accAccountSub.getCustomerId());
			newRec.setCustomerName(accAccountSub.getAccName());
			newRec.setClrDate(this.getClrDate());
			newRec.setCardNo(cardNo);
			newRec.setAmt(amt);
			newRec.setCardType(card.getCardType());
			newRec.setDealState(Constants.TR_STATE_ZC);
			newRec.setNote(log.getMessage());

			publicDao.save(newRec);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	@Override
	public void deleteAccBalReturnData(Long dealNo) {
		publicDao.doSql("delete from acc_bal_return t where deal_no = '" + dealNo + "' and not exists (select 1 from acc_bal_return where deal_no = t.deal_no and state = '0')");
	}
    /**
     * 批量充值导入
     * @param file
     * @param accKind
     * @param isAudit
     * @param rec
     * @param actionLog
     * @return
     * @throws CommonException
     */
	public TrServRec saveImportBatchRechargeData(Workbook file,String accKind,String isAudit,TrServRec rec,SysActionLog actionLog) throws CommonException{
		try{
			if(file == null){
				throw new CommonException("导入的文件不能为空！");
			}
			if(rec == null){
				rec = new TrServRec();
			}
			if(actionLog == null){
				actionLog = this.getCurrentActionLog();
			}
			if(Tools.processNull(accKind).equals("")){
			    throw new CommonException("充值账户类型不正确！");
            }
            if(Tools.processNull(isAudit).equals("")){
                isAudit = "1";
            }
            if(!Tools.processNull(isAudit).equals("0") && !Tools.processNull(isAudit).equals("1")){
                throw new CommonException("是否审核标志不正确！");
            }
			actionLog.setDealCode(DealCode.APPLY_JRSBK_IMPORT);
			actionLog.setMessage("批量充值数据导入,账户类型:" + accKind + ",审核标志:" + isAudit);
			this.publicDao.save(actionLog);
			Sheet sheet = file.getSheetAt(0);
			if(sheet == null){
				throw new CommonException("导入的人员数据EXCEL不正确，请仔细核对后重新进行导入！");
			}
			Row firstRow =  sheet.getRow(0);
			if(firstRow == null) {
				throw new CommonException("导入文件中第1行说明字段不正确！");
			}
			String[] fileDefinedTit = {"姓名","证件号码","金额"};
			for(int i = 0;i < fileDefinedTit.length;i++){
				if(!Tools.processNull(this.getCellValue(firstRow,i)).equals(fileDefinedTit[i])){
					throw  new CommonException("导入文件中第一行说明字段，第" + (i + 1) + "列说明不正确！");
				}
			}
			int firstRowNum = 1;
			int lastRowNum = sheet.getLastRowNum();
			Row tempRow = null;
			StringBuffer tempSb = new StringBuffer();
			long totRowNums = 0L;
			String totAmt = "0";
			for(int i = firstRowNum;i <= lastRowNum;i++){
				tempRow = sheet.getRow(i);
				if(tempRow == null){
					continue;
				}
				if(Tools.processNull(this.getCellValue(tempRow,0)).equals("")){
					continue;
				}
				totRowNums++;
				String tempName = getCellValue(tempRow,0).trim();
				if(Tools.processNull(tempName).equals("")) {
					throw new CommonException("导入文件中，第" + (i + 1) + "行，第" + 1 + "列字段不正确！");
				}
				String tempCertNo = getCellValue(tempRow,1).trim();
				if(Tools.processNull(tempCertNo).equals("")) {
					throw new CommonException("导入文件中，第" + (i + 1) + "行，第" + 2 + "列字段不正确！");
				}
				String tempCellAmt = getCellValue(tempRow,2);
				Float tempCellAmtFloat = Tools.processFloat(tempCellAmt);
				if(tempCellAmtFloat == 0F){
                    throw new CommonException("导入文件中，第" + (i + 1) + "行，第" + 3 + "列字段不正确！");
                }
				String tempAmt = Arith.cardmoneymun(tempCellAmt);
                totAmt = Arith.add(totAmt,tempAmt);
                tempSb.append("'insert into base_batch_recharge_details (data_id,data_seq,customer_id,name,cert_no,card_type,card_no,acc_kind,amt,state,brch_id,user_id,line_num,note) ");
				tempSb.append("values (");
				tempSb.append("seq_base_personal_temp.nextval," + actionLog.getDealNo() + ",null,''" + tempName + "'',''" + tempCertNo + "'',''" + "" + "'',");
				tempSb.append("''" + "" + "'',''" + accKind + "''," + tempAmt + ",''" + "0" + "'',null,null," + i + ",null)',");
				if(i % 500 == 0){
					publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + tempSb.substring(0,tempSb.length() - 1).toString() + "))");
					tempSb = new StringBuffer();
				}
				tempRow = null;
			}
			if(tempSb.length() > 0){
				publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + tempSb.substring(0,tempSb.length() - 1).toString() + "))");
				tempSb = null;
			}
			if(totRowNums == 0){
				throw new CommonException("导入的文件数据内容为空！");
			}
			BaseBatchRechargeBills bills = new BaseBatchRechargeBills();
            bills.setDataSeq(actionLog.getDealNo());
            bills.setAccKind(accKind);
            bills.setIsAudit(isAudit);
            bills.setState("0");
            bills.setTotNum(totRowNums);
            bills.setTotAmt(Long.valueOf(totAmt));
            bills.setUseableNum(0L);
            bills.setUseableAmt(0L);
            bills.setSucNum(0L);
            bills.setSucAmt(0L);
            bills.setImpBrchId(actionLog.getBrchId());
            bills.setImpUserId(actionLog.getUserId());
            bills.setImpDate(actionLog.getDealTime());
			publicDao.save(bills);
			List<Object> inParams = new ArrayList<Object>();
			StringBuffer inPatametes = new StringBuffer();
			inPatametes.append(actionLog.getBrchId()).append("|");
			inPatametes.append(Constants.ACPT_TYPE_GM).append("|");
			inPatametes.append(actionLog.getUserId()).append("|");
			inPatametes.append(actionLog.getDealNo()).append("|");
			inPatametes.append(actionLog.getDealNo()).append("|");
			inParams.add(inPatametes);
			List<Object> outParams = new ArrayList<Object>();
			outParams.add(Types.VARCHAR);
			outParams.add(Types.VARCHAR);
			outParams.add(Types.VARCHAR);
			List<?> ret = publicDao.callProc("pk_card_apply_issuse.p_batch_recharge_compare",inParams,outParams);
			if(!(ret == null || ret.size() == 0)){
				int res = Integer.parseInt(ret.get(0).toString());
				if(res != 0){
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				}
			}else{
				throw new CommonException("导入人员数据比较出现错误，请重新进行操作！");
			}
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealCode(actionLog.getDealCode());
			rec.setOrgId(actionLog.getOrgId());
            rec.setUserId(actionLog.getUserId());
            rec.setClrDate(this.getClrDate());
            rec.setBrchId(actionLog.getBrchId());
            rec.setAccKind(accKind);
            rec.setDealState(Constants.STATE_ZC);
            rec.setCardAmt(totRowNums);
            rec.setBizTime(actionLog.getDealTime());
            rec.setNum(totRowNums);
            rec.setAmt(Long.valueOf(totAmt));
            rec.setNote(actionLog.getMessage());
            publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
    /**
     * 批量充值
     * @param dataSeq long 记录流水
     * @param oper Users 操作员
     * @param actionLog SysActionLog 操作日志
     * @return 成功充值条数
     * @throws CommonException
     */
	public int saveBatchRecharge(long dataSeq,Users oper,SysActionLog actionLog) throws CommonException{
        int rechargeSucNum = 0;
        try{
            if(Tools.processNull(dataSeq).equals("")){
                throw new CommonException("充值记录流水不正确！");
            }
            BaseBatchRechargeBills bills = (BaseBatchRechargeBills) this.findOnlyRowByHql("from BaseBatchRechargeBills t where t.dataSeq = " + dataSeq);
            if(bills == null){
                throw new CommonException("根据流水编号【" + dataSeq + "】找不到充值记录信息！");
            }
            //单据充值状态: 0 初始导入;1 未审核 2 审核失败;3 审核成功;4 充值全部失败; 5：部分充值 9 充值完成;
            if(Tools.processNull(bills.getState()).equals("9")){
                throw new CommonException("该充值记录已完成充值！");
            }
            if(Tools.processNull(bills.getState()).equals("2")){
                throw new CommonException("该充值信息未审核通过！");
            }
            if(Tools.processNull(bills.getIsAudit()).equals("0")){
                if(!Tools.processNull(bills.getState()).equals("3") && !Tools.processNull(bills.getState()).equals("4") && !Tools.processNull(bills.getState()).equals("5")){
                    throw new CommonException("该充值记录信息未审核通过！");
                }
            }
            String canRechargeState = "";
            if(Tools.processNull(bills.getIsAudit()).equals("0")){
                canRechargeState = "('4','5')";
            }else{
                canRechargeState = "('2','5')";
            }
            BigDecimal canRechargeCount = (BigDecimal) this.findOnlyFieldBySql("select count(1) from base_batch_recharge_details t where t.state in " + canRechargeState + " and t.data_seq = " + bills.getDataSeq());
            if(canRechargeCount.intValue() == 0){
                throw new CommonException("该充值记录下未找到可充值明细信息！");
            }
            List allCanRechargeData = this.findByHql("from BaseBatchRechargeDetails t where t.dataSeq = " + bills.getDataSeq() + " and t.state in " + canRechargeState);
            if(allCanRechargeData == null || allCanRechargeData.isEmpty()){
                throw new CommonException("该充值记录下未找到可充值明细信息！");
            }
            int allCanRechargeLen = allCanRechargeData.size();
            for(int i = 0;i < allCanRechargeLen;i++){
                BaseBatchRechargeDetails details = (BaseBatchRechargeDetails) allCanRechargeData.get(i);
                Map<String,Object> map = new HashMap<String, Object>();
                map.put("userId",oper.getUserId());
                map.put("cardNo",details.getCardNo());
                map.put("accKind",details.getAccKind());
                map.put("amt",details.getAmt());
                map.put("paySource","0");
                SysActionLog tempaActionLog = (SysActionLog) BeanUtils.cloneBean(actionLog);
                actionLog.setDealNo(null);
                actionLog.setDealTime(this.getDateBaseTime());
                map.put("actionlog",tempaActionLog);
                boolean isChargeSuc = false;
                String rechargeMsg = "";
                //充值状态 0 初始导入;1 比对失败;2 比对成功;3 审核失败;4 审核成功;5 充值失败; 9 充值完成;
                String rechargeReslutState = "5";
                try{
                    this.saveOnlineAccRecharge2(map,DealCode.REISSUE_CASH_WD);
                    isChargeSuc = true;
                    rechargeReslutState = "9";
					rechargeSucNum++;
                }catch(Exception e){
                    rechargeReslutState = "5";
                    rechargeMsg = e.getMessage();
                }
                int upcount = this.publicDao.doSql("update base_batch_recharge_details t set t.state = '" + rechargeReslutState + "' ,t.brch_id = '" + oper.getBrchId() + "',t.user_id = '" +
                oper.getUserId() + "',t.recharge_time = to_date('" + DateUtil.formatDate(tempaActionLog.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','yyyy-mm-dd hh24:mi:ss'),t.note = '" + rechargeMsg + "'" +
                "where t.data_id = " + details.getDataId() + " and t.state in " + canRechargeState);
                if(upcount != 1){
                    throw new CommonException("更新卡号【" + details.getCardNo() + "'的充值状态时数量不一致！");
                }
                if(rechargeReslutState.equals("9")){
                    this.publicDao.doSql("update base_batch_recharge_bills t set t.suc_num = nvl(t.suc_num,0) + 1,t.suc_amt = nvl(t.suc_amt,0) + " + details.getAmt() + " where t.data_seq = " + details.getDataSeq());
                }
                if(i == (allCanRechargeLen - 1)){
                    Object[] tempRows = (Object[]) this.findOnlyRowBySql("select t.useable_num,t.suc_num from base_batch_recharge_bills t where t.data_seq = " + details.getDataSeq());
                    if(((BigDecimal)(tempRows[1])).intValue() == 0){
                        this.publicDao.doSql("update base_batch_recharge_bills t set t.state = '4' where t.data_seq = " + details.getDataSeq());
                    }else if(((BigDecimal)(tempRows[0])).intValue() == ((BigDecimal)(tempRows[1])).intValue()){
                        this.publicDao.doSql("update base_batch_recharge_bills t set t.state = '9' where t.data_seq = " + details.getDataSeq());
                    }else{
                        this.publicDao.doSql("update base_batch_recharge_bills t set t.state = '5' where t.data_seq = " + details.getDataSeq());
                    }
                    if(upcount != 1){
                        throw new CommonException("更新充值记录【" + details.getDataSeq() + "'的成功充值金额时数量不一致！");
                    }
                }
                this.publicDao.doSql("commit");
            }
            return rechargeSucNum;
        }catch(Exception e){
            throw new CommonException(rechargeSucNum,"充值过程中发生错误：" + e.getMessage());
        }
    }
	@SuppressWarnings("unchecked")
	public TrServRec saveOnlineAccRecharge2(Map hm, Integer trCode)throws CommonException {
		try {
			//1.验证柜员是否存在
			String userId = Tools.processNull(hm.get("userId"));
			Users users = validUsers(userId);
			//2.卡状态验证
			String cardNo = Tools.processNull(hm.get("cardNo"));
			CardBaseinfo card = validCard(cardNo,false);
			BasePersonal person = new BasePersonal();
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				person = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(person == null){
					person = new BasePersonal();
				}
			}
			String accKind = Tools.processNull(hm.get("accKind"));
			if(accKind.equals("")){
                throw new CommonException("账户类型不正确！");
            }
			//3.获取充值金额和充值前金额验证充值是否超限
			String cardTypeString = this.getCodeNameBySYS_CODE("CARD_TYPE",card.getCardType());
			String amt = Tools.processNull(hm.get("amt"));
			CardConfig cfg = (CardConfig) this.findOnlyRowByHql("from CardConfig t where t.cardType = '" + card.getCardType() + "'");
			if(cfg == null){
				throw new CommonException("该卡类型参数信息未配置，卡类型：" + cardTypeString);
			}
			AccAccountSub account = acc.getAccSubLedgerByCardNoAndAccKind(card.getCardNo(),accKind,"00");
			if(account == null){
				throw new CommonException("根据卡号" + card.getCardNo() + ",账户类型" + accKind + "未找到账户信息！");
			}
			//4.记录操作日志
			SysActionLog log = (SysActionLog) hm.get("actionlog");
			if(log == null){
				throw new CommonException("记录灰记录操作日志不能为空！");
			}
			if(!(log instanceof SysActionLog)){
				throw new CommonException("记录灰记录操作日志不能为空！");
			}
			log.setDealCode(trCode);
			log.setMessage(this.findTrCodeNameByCodeType(trCode) + ",卡号:" + card.getCardNo());
			log.setNote(log.getMessage());
			publicDao.save(log);
			//5.调接口记录交易
			HashMap<String,String> accMap = new HashMap<String, String>();
			accMap.put("acpt_id",users.getBrchId());
			accMap.put("acpt_type",Constants.ACPT_TYPE_GM);
			accMap.put("card_no",cardNo);
			accMap.put("card_tr_count","");
			accMap.put("card_bal","");
			accMap.put("acc_kind",accKind);
			accMap.put("wallet_id","00");
			accMap.put("tr_amt",amt);
			accMap.put("deal_state",Constants.TR_STATE_ZC);
			accMap.put("pay_source",Tools.processNull(hm.get("paySource")));
			accMap.put("sourcecard",Tools.processNull(hm.get("rechargeCardNo")));
			accMap.put("rechg_pwd",Tools.processNull(hm.get("rechargeCardPwd")));
			accMap.put("client_id",card.getCustomerId());
			accMap.put("card_type",card.getCardType());
			accMap.put("acc_bal",account.getBal() + "");
			acc.recharge(log,accMap);
			//6.登记业务信息（TR_SERV_REC）
			TrServRec serv = new TrServRec();
			serv.setDealNo(log.getDealNo());
			serv.setDealCode(trCode.intValue());
			serv.setCardNo(card.getCardNo());
			serv.setCardType(card.getCardType());
			serv.setAccKind(accKind);
			serv.setBizTime(log.getDealTime());
			serv.setUserId(log.getUserId());
			serv.setBrchId(users.getBrchId());
			serv.setAccNo(account.getAccNo() + "");
			serv.setCardAmt(1L);
			serv.setCardId(card.getCardId());
			serv.setNum(1l);
			serv.setOrgId(log.getOrgId());
			serv.setDealState(Constants.TR_STATE_ZC);
			serv.setClrDate(this.getClrDate());
			serv.setCustomerId(person.getCustomerId() + "");
			serv.setCustomerName(person.getName());
			serv.setCertType(person.getCertType());
			serv.setCertNo(person.getCertNo());
			serv.setTelNo(person.getMobileNo());
			serv.setPrvBal(account.getBal());
			serv.setAcptType(Constants.ACPT_TYPE_GM);
			serv.setAmt(Long.valueOf(amt));
			serv.setNote(log.getMessage());
			//7.保存凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportsmoneydiv(serv.getAmt() + ""));
			json.put(ReceiptContants.FIELD.CARD_NO, cardNo); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, person.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, person.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.add(account.getBal() + "", amt))); // 充值后账户余额
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(log, json, ReceiptContants.TYPE.CASH_RECHARGE, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			publicDao.save(serv);
			return serv;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	public void saveBatchRechargeStateChanged(long dataSeqOrdataId,String operType,String changedState,Users oper,TrServRec rec,SysActionLog actionLog) throws CommonException{
		try{
		    if(Tools.processNull(dataSeqOrdataId).equals("")){
				throw new CommonException("操作流水编号不正确！");
			}
		    if(rec == null){
				rec = new TrServRec();
			}
			if(actionLog == null){
				actionLog = this.getCurrentActionLog();
			}
			String tip = "";
			//0 删除,1 文件整体全部审核,2 明细单条记录审核
			if(Tools.processNull(operType).equals("")){
				throw new CommonException("操作类型不正确");
			}
			if(Tools.processNull(operType).equals("0")){
				tip = "文件删除";
				actionLog.setDealCode(DealCode.REISSUE_CASH_WD_DEL);
			}else if(Tools.processNull(operType).equals("1")){
				tip = "文件审核";
				if(Tools.processNull(changedState).equals("")){
					throw new CommonException("审核状态不正确！");
				}else if(Tools.processNull(changedState).equals("0")){
					tip += "通过";
				}else if(Tools.processNull(changedState).equals("1")){
					tip += "不通过";
				}else{
					throw new CommonException("文件审核状态不正确！");
				}
			}else if(Tools.processNull(operType).equals("2")){
				tip = "记录审核";
				if(Tools.processNull(changedState).equals("")){
					throw new CommonException("审核状态不正确！");
				}else if(Tools.processNull(changedState).equals("0")){
					tip += "通过";
				}else if(Tools.processNull(changedState).equals("1")){
					tip += "不通过";
				}else{
					throw new CommonException("记录审核状态不正确！");
				}
			}else{
				throw new CommonException("操作类型不正确！");
			}
			actionLog.setMessage(tip + ",流水=" + dataSeqOrdataId);
			this.publicDao.save(actionLog);
			if(Tools.processNull(operType).equals("0")){
				BaseBatchRechargeBills bills = (BaseBatchRechargeBills) this.findOnlyRowByHql("from BaseBatchRechargeBills t where t.dataSeq = " + dataSeqOrdataId);
				if(bills == null){
					throw new CommonException("根据流水【" + dataSeqOrdataId + "】找不到充值记录信息！");
				}
				if(Tools.processNull(bills.getState()).equals("5")){
					throw new CommonException("该条记录已有部分充值，无法进行删除！");
				}else if(Tools.processNull(bills.getState()).equals("9")){
					throw new CommonException("该条记录已全部充值，无法进行删除！");
				}
				this.publicDao.doSql("delete from base_batch_recharge_bills   t where t.data_seq = " + bills.getDataSeq());
				this.publicDao.doSql("delete from base_batch_recharge_details t where t.data_seq = " + bills.getDataSeq());
			}else if(Tools.processNull(operType).equals("1")){
				BaseBatchRechargeBills bills = (BaseBatchRechargeBills) this.findOnlyRowByHql("from BaseBatchRechargeBills t where t.dataSeq = " + dataSeqOrdataId);
				if(bills == null){
					throw new CommonException("根据流水【" + dataSeqOrdataId + "】找不到充值记录信息！");
				}
				if(Tools.processNull(bills.getState()).equals("5")){
					throw new CommonException("该条记录已有部分充值，无需进行审核！");
				}else if(Tools.processNull(bills.getState()).equals("9")){
					throw new CommonException("该条记录已全部充值，无需进行审核！");
				}else if(Tools.processNull(bills.getState()).equals("3")){
					throw new CommonException("该条记录已审核完成，无需重复进行审核！");
				}
				if(!Tools.processNull(bills.getIsAudit()).equals("0")){
					throw new CommonException("该条记录无需进行审核处理！");
				}
				String billsTargetState = "2";
				String detailsTargetState = "3";
				if(Tools.processNull(changedState).equals("0")){
					billsTargetState = "3";
					detailsTargetState = "3";
				}else if(Tools.processNull(changedState).equals("1")){
					billsTargetState = "2";
					detailsTargetState = "4";
				}
				this.publicDao.doSql("update base_batch_recharge_bills t set t.state = '" + billsTargetState + "'  where t.data_seq = " + bills.getDataSeq());
				this.publicDao.doSql("update base_batch_recharge_details t set t.state = '" + detailsTargetState + "'  where t.data_seq = " + bills.getDataSeq() + " and t.state in ('2','3','4','5')");
			}else if(Tools.processNull(operType).equals("2")){
                BaseBatchRechargeDetails details = (BaseBatchRechargeDetails) this.findOnlyRowByHql("from BaseBatchRechargeDetails t where t.dataId = " + dataSeqOrdataId);
                BaseBatchRechargeBills bills = (BaseBatchRechargeBills) this.findOnlyRowByHql("from BaseBatchRechargeBills t where t.dataSeq = " + details.getDataSeq());
                if(bills == null){
                    throw new CommonException("根据流水【" + dataSeqOrdataId + "】找不到关联充值记录信息！");
                }
                if(!Tools.processNull(bills.getIsAudit()).equals("0")){
                    throw new CommonException("该条记录无需进行审核处理！");
                }
                if(details == null){
                    throw new CommonException("根据流水【" + dataSeqOrdataId + "】找不到充值明细信息！");
                }
                if(Tools.processNull(details.getState()).equals("1")){
                    throw new CommonException("该充值记录未比对成功，不能进行审核！");
                }
                if(Tools.processNull(changedState).equals("0")){
                    if(Tools.processNull(details.getState()).equals("5") || Tools.processNull(details.getState()).equals("9")){
                        throw new CommonException("该记录已是可充值状态，无需进行审核！");
                    }
                    if(Tools.processNull(details.getState()).equals("4")){
                        throw new CommonException("该记录已审核成功，无需重复进行审核！");
                    }
                }else if(Tools.processNull(changedState).equals("1")){
                    if(Tools.processNull(details.getState()).equals("9")){
                        throw new CommonException("该记录已充值完成，不能进行审核失败处理！");
                    }
                    if(Tools.processNull(details.getState()).equals("3")){
                        throw new CommonException("该记录已是审核失败状态，无需重复进行审核失败！");
                    }
                }
                //0 初始导入;1 未审核 2 审核失败;3 审核成功;4 充值全部失败; 5：部分充值 9 充值完成;
                //充值状态 0 初始导入;1 比对失败;2 比对成功;3 审核失败;4 审核成功;5 充值失败; 9 充值完成;
                String billsTargetState = "2";
                String detailsTargetState = "3";
                if(Tools.processNull(changedState).equals("0")){
                    billsTargetState = "3";
                    detailsTargetState = "3";
                }else if(Tools.processNull(changedState).equals("1")){
                    billsTargetState = "2";
                    detailsTargetState = "4";
                }
                this.publicDao.doSql("update base_batch_recharge_details t set t.state = '" + detailsTargetState + "'  where t.data_id = " + details.getDataId() + " and t.state in ('2','3','4','5')");
                if(Tools.processNull(changedState).equals("0")){
                    this.publicDao.doSql("update base_batch_recharge_bills t set t.useable_num = nvl(t.useable_num,0) + 1,t.useable_amt = nvl(t.useable_amt,0) + " + details.getAmt() + " where t.data_seq = " + details.getDataSeq());
                }else if(Tools.processNull(changedState).equals("1")){
                    this.publicDao.doSql("update base_batch_recharge_bills t set t.useable_num = nvl(t.useable_num,0) - 1,t.useable_amt = nvl(t.useable_amt,0) - " + details.getAmt() + " where t.data_seq = " + details.getDataSeq());
                }
                Object[] o = (Object[]) this.findOnlyFieldBySql("select t.useable_num,t.suc_num from base_batch_recharge_bills t where t.data_seq = " + details.getDataSeq());
                if(((BigDecimal)o[0]).intValue() == 0){
                    this.publicDao.doSql("update base_batch_recharge_bills t set t.state = '2'  where t.data_seq = " + details.getDataSeq());
                }else if(((BigDecimal)o[0]).intValue() == ((BigDecimal)o[1]).intValue()){
                    this.publicDao.doSql("update base_batch_recharge_bills t set t.state = '9'  where t.data_seq = " + details.getDataSeq());
                }
            }else{
				throw new CommonException("操作类型不正确！");
			}
			rec.setDealNo(actionLog.getDealNo());
            rec.setDealCode(actionLog.getDealCode());
            rec.setBrchId(actionLog.getBrchId());
            rec.setUserId(actionLog.getUserId());
            rec.setBizTime(actionLog.getDealTime());
            rec.setCardAmt(1L);
            rec.setDealState(Constants.STATE_ZC);
            rec.setClrDate(this.getClrDate());
            rec.setNote(actionLog.getMessage());
            rec.setAcptType(Constants.ACPT_TYPE_GM);
            rec.setOrgId(actionLog.getOrgId());
            rec.setOldDealNo(dataSeqOrdataId);
            this.publicDao.save(rec);
		}catch(Exception e){
		    throw new CommonException(e.getMessage());
		}
	}

    public String getCellValue(Row row,int colIndex) throws CommonException{
        try{
            String ret = "";
            if(row == null){
                throw new CommonException("表格行信息不存在！");
            }
            Cell tempCell = row.getCell(colIndex);
            if(tempCell == null){
                throw new CommonException("单元格信息不存在！");
            }
            int cellType = tempCell.getCellType();
            switch(cellType){
                case Cell.CELL_TYPE_BLANK:
                    ret = "";
                    break;
                case Cell.CELL_TYPE_BOOLEAN:
                    ret = Boolean.toString(tempCell.getBooleanCellValue());
                    break;
                case Cell.CELL_TYPE_ERROR:
                    ret = "";
                    break;
                case Cell.CELL_TYPE_FORMULA:
                    ret = tempCell.getCellFormula();
                    break;
                case Cell.CELL_TYPE_NUMERIC:
                    ret = (int) tempCell.getNumericCellValue() + "";
                    break;
                case Cell.CELL_TYPE_STRING:
                    ret =  tempCell.getStringCellValue();
                    break;
                default:
                    ret = "";
            }
            return ret.trim().replaceAll(" ","");
        }catch(Exception e){
            throw new CommonException(e.getMessage());
        }
    }
}
