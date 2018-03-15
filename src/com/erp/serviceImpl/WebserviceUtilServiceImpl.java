package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.beanutils.BeanUtils;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.BaseCoOrg;
import com.erp.model.BasePersonal;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardConfig;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.SysOrgan;
import com.erp.model.SysPara;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.AccAcountService;
import com.erp.service.CorpManagerService;
import com.erp.service.DoWorkClientService;
import com.erp.service.WebserviceUtilService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.Sys_Code;
import com.erp.util.Tools;
import com.erp.viewModel.Page;


@Service("webserviceUtilService")
public class WebserviceUtilServiceImpl extends BaseServiceImpl implements
		WebserviceUtilService {

	 @Resource(name="accAcountService")
	  private AccAcountService accAcountService;

	  @Resource(name="corpManagerService")
	  private CorpManagerService corpManagerService;

	  @Resource(name="doWorkClientService")
	  private DoWorkClientService doWorkClient;

	  public JSONArray findAllBizInfo(String bizId, String bizName)
	    throws CommonException
	  {
	    JSONArray jsonarray = null;
	    try {
	      String where = "";
	      if (!Tools.processNull(bizId).equals("")) {
	        where = where + " and merchant_Id like '%" + bizId + "%'";
	      }
	      if (!Tools.processNull(bizName).equals("")) {
	        where = where + " and merchant_Name like '%" + bizName + "%'";
	      }
	      Page data = pagingQuery("select merchant_id,merchant_name from Base_Merchant where 1=1 " + where, Integer.valueOf(10000), Integer.valueOf(10000));
	      jsonarray = data.getAllRs();
	    } catch (Exception e) {
	      throw new CommonException("查询商户信息出错:" + e.getMessage());
	    }
	    return jsonarray;
	  }

	  public JSONArray findAllAccLKindList() throws CommonException
	  {
	    JSONArray jsonarray = null;
	    try {
	      String sql = "select t2.acc_kind acc_kind,t2.acc_name acc_name from ACC_OPEN_CONF  t1,acc_kind_config t2 WHERE t1.main_type = '1' AND t2.acc_kind NOT IN ('02','06','01') AND t1.acc_kind = t2.acc_kind";

	      Page data = pagingQuery(sql, Integer.valueOf(10000), Integer.valueOf(10000));
	      jsonarray = data.getAllRs();
	    } catch (Exception e) {
	      throw new CommonException("查询账户列表出错：" + e.getMessage());
	    }
	    return jsonarray;
	  }

	  public void saveUnionInfo(String union_id, String union_name) throws CommonException
	  {
	    try
	    {
	      SysActionLog actionLog = getActionLog();
	      actionLog.setDealCode(DealCode.UNION_BRCH_ID);
	      actionLog.setMessage("工会信息登记保存，工会编号为 ：" + union_id);
	      this.publicDao.save(actionLog);
	      SysBranch brch_union = new SysBranch();
	      brch_union.setOrgId(Integer.valueOf(1001));
	      brch_union.setBrchId(union_id);
	      brch_union.setFullName(union_name);
	      brch_union.setIconCls("icon-role");
	      brch_union.setAssistantManager(Integer.valueOf(1));
	      brch_union.setBrchType("3");
	      brch_union.setStatus("A");
	      this.publicDao.save(brch_union);
	    } catch (Exception e) {
	      throw new CommonException("保存工会信息出错：" + e.getMessage());
	    }
	  }

	  public void saveopenUnionAcc(String union_id) throws CommonException
	  {
	    try {
	      SysActionLog actionLog = getActionLog();
	      actionLog.setDealCode(DealCode.UNION_BRCH_OPENACC);
	      actionLog.setMessage("工会信息登记保存，工会编号为 ：" + union_id);
	      this.publicDao.save(actionLog);
	      SysBranch branch = (SysBranch)findOnlyRowByHql("from SysBranch where brchId ='" + union_id + "'");
	      if (branch == null) {
	        throw new CommonException("未查询到工会信息");
	      }
	      HashMap hm = new HashMap();
	      hm.put("obj_type", Sys_Code.CLIENT_TYPE_WD);
	      hm.put("sub_type", branch.getBrchType());
	      hm.put("pwd", null);
	      hm.put("obj_id", branch.getBrchId());
	      this.accAcountService.createAccount(actionLog, hm);
	    } catch (Exception e) {
	      throw new CommonException("工会开户发生错误：" + e.getMessage());
	    }
	  }

	  public SysActionLog saveCheckUnion(String union_id, String amt, String uniondkdid, String dealtype, String actionno) throws CommonException
	  {
	    SysActionLog log = null;
	    try {
	      log = getActionLog();
	      log.setBrchId(union_id);
	      if (Tools.processNull(dealtype).equals("1")) {
	        log.setDealCode(DealCode.UNION_DKD_SQQR);
	        log.setMessage("打款单收款确认，打款单id为：" + uniondkdid);
	      } else if (Tools.processNull(dealtype).equals("2")) {
	        log.setDealCode(DealCode.UNION_DKD_SQQR_CANCEL);
	        log.setMessage("打款单收款确认撤销，打款单id为：" + uniondkdid + "打款单收款确认时流水号：" + actionno);
	      } else {
	        throw new CommonException("请选择是确认还是取消收款确认");
	      }
	      this.publicDao.save(log);

	      if (Tools.processNull(dealtype).equals("1"))
	      {
	        SysOrgan currentOrg = (SysOrgan)findOnlyRowByHql("from SysOrgan where orgId = '1001'");

	        AccAccountSub accountDb = (AccAccountSub)findOnlyRowByHql("from AccAccountSub where customerId = '" + 
	          currentOrg.getCustomerId() + 
	          "' and itemId = '102100' " + 
	          " and accKind = '00' and accState = '1'");
	        AccAccountSub accountCr = (AccAccountSub)findOnlyRowByHql("from AccAccountSub where customerId = '" + 
	          union_id + 
	          "' and itemId='101101' and accKind = '00' and accState = '1'");
	        if (accountDb == null)
	          throw new CommonException("借方账户[当前机构往来款账户]不存在.");
	        if (!accountDb.getAccState().equals("1")) {
	          throw new CommonException("借方账户[当前机构往来款账户]状态为[" + 
	            getCodeNameBySYS_CODE("ACC_STATE", 
	            accountDb.getAccState()) + "], 不能充值.");
	        }

	        if (accountCr == null)
	          throw new CommonException("贷方账户[工会现金账户]不存在.");
	        if (!accountCr.getAccState().equals("1")) {
	          throw new CommonException("贷方账户[工会现金账户]状态为[" + 
	            getCodeNameBySYS_CODE("ACC_STATE", 
	            accountCr.getAccState()) + "], 不能充值.");
	        }

	        this.corpManagerService.accouting_ghk(accountDb, accountCr, new BigDecimal(Arith.cardmoneydiv(amt)), log, "0", "", "", "0", 
	          "打款单收款确认");
	      } else if (Tools.processNull(dealtype).equals("2")) {
	        this.accAcountService.saveCancelDayBook(log, actionno);
	      } else {
	        throw new CommonException("请选择是确认还是取消收款确认");
	      }
	    }
	    catch (Exception e) {
	      throw new CommonException("收款确认或撤销发生错误：" + e.getMessage());
	    }
	    return log;
	  }

	  public SysActionLog getActionLog() {
	    SysActionLog actionLog = new SysActionLog();
	    actionLog.setBrchId("99999999");
	    actionLog.setUserId("admin");
	    actionLog.setDealTime(new Date());
	    actionLog.setFuncName("工会卡调用业务日志");
	    return actionLog;
	  }

	  public SysActionLog saveIssueAmt(String union_id, String uniondkdid, String cardNo, String acckind, String amt, String dealtype, String actionno) throws CommonException
	  {
	    SysActionLog log = null;
	    try {
	      log = getActionLog();
	      if (Tools.processNull(dealtype).equals("1")) {
	        log.setDealCode(DealCode.UNION_DKD_FF);
	        log.setMessage("工会资金发放：" + cardNo);
	        this.publicDao.save(log);
	        CardBaseinfo card = (CardBaseinfo)findOnlyRowByHql("from CardBaseinfo where cardNo='" + cardNo + "' and cardState = '" + Constants.CARD_STATE_ZC + "'");
	        if (card == null) {
	          throw new CommonException("发放发生错误：卡号为《" + cardNo + "》的卡不存在或卡状态不正常");
	        }
	        AccAccountSub account = (AccAccountSub)findOnlyRowByHql("from AccAccountSub where cardNo='" + cardNo + "' and accKind='" + acckind + "' and accState ='" + Constants.ACC_STATE_ZC + "'");
	        if (account == null) {
	          throw new CommonException("发放发生错误：卡号为《" + cardNo + "》,账户类行为《" + acckind + "》账户不存在或卡状态不正常");
	        }
	        HashMap accMap = new HashMap();
	        accMap.put("acpt_id", union_id);
	        accMap.put("acpt_type", "1");
	        accMap.put("card_no", cardNo);
	        accMap.put("card_tr_count", "");
	        accMap.put("card_bal", "");
	        accMap.put("acc_kind", acckind);
	        accMap.put("wallet_id", "00");
	        accMap.put("tr_amt", amt);
	        accMap.put("deal_state", Constants.TR_STATE_ZC);
	        accMap.put("pay_source", Tools.processNull("0"));
	        accMap.put("sourcecard", Tools.processNull(""));
	        accMap.put("rechg_pwd", Tools.processNull(""));
	        accMap.put("client_id", card.getCustomerId());
	        accMap.put("card_type", card.getCardType());
	        accMap.put("acc_bal", account.getBal());
	        this.accAcountService.recharge(log, accMap);
	        TrServRec serv = new TrServRec();
	        serv.setDealNo(log.getDealNo());
	        serv.setDealCode(log.getDealCode());
	        serv.setCardNo(card.getCardNo());
	        serv.setCardType(card.getCardType());
	        serv.setAccKind(acckind);
	        serv.setBizTime(log.getDealTime());
	        serv.setUserId(log.getUserId());
	        serv.setBrchId(union_id);
	        serv.setAccNo(Tools.processNull(account.getAccNo()));
	        serv.setCardAmt(Long.valueOf(1L));
	        serv.setCardId(card.getCardId());
	        serv.setDealState(Constants.TR_STATE_ZC);
	        serv.setClrDate(getClrDate());
	        serv.setPrvBal(account.getBal());

	        serv.setAmt(new Long(amt));
	        serv.setNote(log.getMessage());
	        this.publicDao.save(serv);
	      } else if (Tools.processNull(dealtype).equals("2"))
	      {
	        log.setDealCode(DealCode.UNION_DKD_FF_CANCEL);
	        log.setMessage("工会福利发放撤销");
	        this.publicDao.save(log);
	        TrServRec oldRec = (TrServRec)findOnlyRowByHql("from TrServRec t where t.dealNo = '" + actionno + "'");
	        TrServRec rec = (TrServRec)BeanUtils.cloneBean(oldRec);
	        if (rec == null) {
	          throw new CommonException("根据传入的充值流水:" + actionno + "未找到有效的充值日志信息，无法进行撤销！");
	        }
	        AccAccountSub account = (AccAccountSub)findOnlyRowByHql("from AccAccountSub where cardNo='" + rec.getCardNo() + "' and accKind='" + rec.getAccKind() + "' and accState ='" + Constants.ACC_STATE_ZC + "'");
	        if (account == null) {
	          throw new CommonException("发放发生错误：卡号为《" + cardNo + "》,账户类行为《" + acckind + "》账户不存在或卡状态不正常");
	        }

	        HashMap accMap = new HashMap();
	        accMap.put("deal_no", actionno);
	        accMap.put("clr_date", rec.getClrDate());
	        accMap.put("card_no", rec.getCardNo());
	        accMap.put("deal_state", rec.getDealState());
	        accMap.put("card_tr_count", "");
	        accMap.put("card_bal", account.getBal().toString());
	        this.accAcountService.rechargeCancel(log, accMap);

	        int updatecount = this.publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CX + "' where t.deal_no = " + actionno);
	        if (updatecount != 1)
	          throw new CommonException("撤销失败，撤销业务日志时更新" + updatecount + "行！");
	      }
	      else {
	        throw new CommonException("请选择是发放还是取消发放");
	      }
	    }
	    catch (Exception e) {
	      throw new CommonException("工会人员发放：" + e.getMessage());
	    }
	    return log;
	  }

	  public String findBankNoandCardNo(String name, String certNo)
	    throws CommonException
	  {
	    String returnJsonstr = "";
	    try {
	      List list = findBySql("select t.card_no,t.bank_card_no from card_baseinfo t,base_personal t1 WHERE  t1.customer_id = t.customer_id AND t.card_type = '100' AND t.card_state = '" + 
	        Constants.CARD_STATE_ZC + "'" + 
	        " and t1.cert_no = '" + certNo + "' AND t1.name = '" + name + "'");
	      if ((list == null) || (list.size() <= 0)) {
	        throw new CommonException("根据姓名：" + Tools.processNull(name) + " ，证件号：" + Tools.processNull(certNo) + "未查询到对应的记录！");
	      }
	      for (int i = 0; i < list.size(); i++) {
	        Object[] o = (Object[])list.get(i);
	        returnJsonstr = returnJsonstr + "\"cardNo\":\"" + o[0] + "\",\"bankNo\":\"" + Tools.processNull(o[1]) + "\"";
	      }
	    } catch (Exception e) {
	      throw new CommonException("获取工会人员的卡号和银行卡号出错：" + e.getMessage());
	    }
	    return returnJsonstr;
	  }

	  public String saveJysmkIssue(String certType, String certNo, String cardType, String cardNo, BaseCoOrg coOrg, String subCardNo, String bankCardNo)
	    throws CommonException
	  {
	    try
	    {
	      SysActionLog actionLog = getActionLog();
	      actionLog.setDealCode(DealCode.ISSUSE_TYPE_PERSONAL);
	      actionLog.setMessage("个人发放，发放人员证件号为 ：" + certNo);
	      this.publicDao.save(actionLog);

	      BasePersonal person = (BasePersonal)findOnlyRowByHql("from BasePersonal where certNo = '" + certNo + "' and certType = '" + certType + "'");
	      if (person == null) {
	        throw new CommonException("根据身份证件号和证件类型未找到任何人员信息！");
	      }

	      CardBaseinfo card = (CardBaseinfo)findOnlyRowByHql("from CardBaseinfo where cardNo = '" + cardNo + "'");
	      if (card != null) {
	        throw new CommonException("该卡在市民卡系统中已经存在！");
	      }
	      CardConfig cardConfig = (CardConfig)findOnlyRowByHql("from CardConfig t where t.cardType ='" + cardType + "'");
	      if (cardConfig == null) {
	        throw new CommonException("当前卡参数未配置，无法进行发放！");
	      }
	      SysPara sysPara = (SysPara)findOnlyRowByHql("from SysPara where 1=1 and paraCode = 'TRADE_PWD_DEFAULT'");

	      this.publicDao.doSql("insert into card_baseinfo (Customer_Id,Card_No,card_state,version,card_type,Issue_Org_Id,init_org_id,city_code,start_date,valid_date,bus_use_flag,bus_type,card_id,Last_Modify_Date,sub_Card_no,bank_card_no,PAY_PWD) values('" + 
	        person.getCustomerId() + "','" + card.getCardNo() + "','1','" + 
	        Constants.CARD_VERSION + "','" + cardType + "','" + coOrg.getOrgId() + "'" + 
	        ",'" + coOrg.getOrgId() + "','" + card.getCardNo().substring(0, 4) + "','" + DateUtil.formatDate(new Date(), "yyyy-MM-dd") + "'" + 
	        ",'" + DateUtil.processDateAddYear(DateUtil.formatDate(new Date(), "yyyy-MM-dd"), cardConfig.getCardValidityPeriod().shortValue()) + 
	        "','" + "01" + "','" + "01" + "'" + 
	        ",'" + card.getCardNo() + "',to_date('" + DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss") + "','yyyy-mm-dd hh24:mi:ss')" + 
	        ",'" + Tools.processNull(subCardNo) + "','" + Tools.processNull(bankCardNo) + "'," + this.doWorkClient.encrypt_MwPwd(cardNo, Tools.processNull(sysPara.getParaValue())) + ")");

	      HashMap hm = new HashMap();
	      hm.put("obj_type", Sys_Code.CLIENT_TYPE_SALE_GR);
	      hm.put("sub_type", cardType);
	      hm.put("obj_id", Tools.processNull(cardNo));
	      this.accAcountService.createAccount(actionLog, hm);
	    } catch (Exception e) {
	      throw new CommonException("卡发放发生错误：" + e.getMessage());
	    }
	    return "发放成功";
	  }

	  public String saveSynCardState(String certType, String certNo, String cardType, String cardNo, String oldCardState, String newCardState, BaseCoOrg coOrg)
	    throws CommonException
	  {
	    try
	    {
	      SysActionLog actionLog = getActionLog();
	      actionLog.setDealCode(DealCode.CARD_STATE_SYNCHRONIZE);
	      actionLog.setMessage("卡状态变更，原来的卡状态为：" + oldCardState + ",新的卡状态为：" + newCardState);
	      this.publicDao.save(actionLog);

	      BasePersonal person = (BasePersonal)findOnlyRowByHql("from BasePersonal where certNo = '" + certNo + "' and certType = '" + certType + "'");
	      if (person == null) {
	        throw new CommonException("根据身份证件号和证件类型未找到任何人员信息！");
	      }

	      CardBaseinfo card = (CardBaseinfo)findOnlyRowByHql("from CardBaseinfo where cardNo = '" + cardNo + "'");
	      if (card == null) {
	        throw new CommonException("未找到任何卡信息！");
	      }

	      if (!card.getCardState().equals(oldCardState)) {
	        throw new CommonException("传入的卡状态和系统卡状态不一致，不能进行卡状态的变更");
	      }

	      Users user = (Users)findOnlyRowByHql("from Users where userId='admin'");
	      this.publicDao.doSql("update card_baseInfo set card_state ='" + newCardState + "',Last_Modify_Date=" + actionLog.getDealTime() + " where card_no = '" + cardNo + "'");
	      if (newCardState.equals("3"))
	        this.publicDao.doSql("update acc_account_sub set acc_state='" + newCardState + "',LSS_DATE ='" + getClrDate() + "' where card_no ='" + cardNo + "'");
	      else if (newCardState.equals("9"))
	        this.publicDao.doSql("update acc_account_sub set acc_state='" + newCardState + "',CLS_DATE ='" + getClrDate() + "',CLS_USER_ID='" + user.getUserId() + "' where card_no ='" + cardNo + "'");
	      else {
	        this.publicDao.doSql("update acc_account_sub set acc_state='" + newCardState + "' where card_no ='" + cardNo + "'");
	      }

	      TrServRec serv = new TrServRec();
	      serv.setDealNo(actionLog.getDealNo());
	      serv.setDealCode(actionLog.getDealCode());
	      serv.setCardNo(card.getCardNo());
	      serv.setCardType(card.getCardType());
	      serv.setBizTime(actionLog.getDealTime());
	      serv.setUserId(actionLog.getUserId());
	      serv.setBrchId(user.getBrchId());
	      serv.setCardAmt(Long.valueOf(0L));
	      serv.setCardId(card.getCardId());
	      serv.setOrgId(user.getOrgId());
	      serv.setDealState(Constants.TR_STATE_ZC);
	      serv.setClrDate(getClrDate());
	      serv.setCustomerId(person.getCustomerId().toString());
	      serv.setCustomerName(person.getName());
	      serv.setCertType(person.getCertType());
	      serv.setCertNo(person.getCertNo());
	      serv.setTelNo(person.getMobileNo());
	      serv.setRsvOne(oldCardState);
	      serv.setRsvTwo(newCardState);
	      serv.setNote(actionLog.getMessage());
	      this.publicDao.save(serv);
	    } catch (Exception e) {
	      throw new CommonException("卡状态同步发生错误：" + e.getMessage());
	    }
	    return null;
	  }
	  
	  @SuppressWarnings({ "unchecked", "rawtypes" })
	public void accouting_ghk(AccAccountSub accountDb, AccAccountSub accountCr, BigDecimal amount, SysActionLog log, String credit, String batchNo, String termNo, String state, String note)
	  {
	    SysBranch currentBranch = (SysBranch)findOnlyRowByHql("from SysBranch where brchId = '" + 
	      log.getBrchId() + "'");

	    List inparams = new ArrayList();
	    inparams.add(accountDb.getAccNo());
	    inparams.add(accountCr.getAccNo());
	    inparams.add(accountDb.getBal());
	    inparams.add(accountCr.getBal());
	    inparams.add("");
	    inparams.add("");
	    inparams.add(accountDb.getBalCrypt() == null ? "" : accountDb
	      .getBalCrypt());
	    inparams.add(accountCr.getBalCrypt() == null ? "" : accountCr
	      .getBalCrypt());
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

	    List rets = this.publicDao.callProc("pk_business.p_account2", 
	      inparams, outTypes);

	    if ((rets == null) || (rets.isEmpty())) {
	      throw new CommonException("调用充值过程失败.");
	    }

	    if (!rets.get(0).equals("00000000"))
	      throw new CommonException(
	        rets.get(1).toString().equals("null") ? "" : rets.get(1)
	        .toString());
	  }


}
