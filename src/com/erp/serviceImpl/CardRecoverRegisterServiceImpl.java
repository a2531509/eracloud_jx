package com.erp.serviceImpl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.BasePersonal;
import com.erp.model.CardApply;
import com.erp.model.CardApplyTask;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardRecoverReginfo;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.AccAcountService;
import com.erp.service.CardIssuseService;
import com.erp.service.CardRecoverRegisterService;
import com.erp.service.RechargeService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.ReceiptContants;
import com.erp.util.Tools;

/**
 * 卡片回收登记业务实现。
 * 
 * @author 钱佳明。
 * @date 2016-03-10。
 *
 */
@Service("cardRecoverRegisterService")
public class CardRecoverRegisterServiceImpl extends BaseServiceImpl implements CardRecoverRegisterService {
	@Resource(name="cardIssuseService")
	private CardIssuseService cardIssuseService;
	@Resource(name="accAcountService")
	private AccAcountService accService;
	@Resource(name="rechargeService")
	private RechargeService rechargeService;
	
	@Override
	@SuppressWarnings("unchecked")
	public void saveCardRecoverRegister(JSONObject jsonObject, String registerInfo) throws CommonException {
		try{
			SysActionLog sysActionLog = getCurrentActionLog();
			sysActionLog.setMessage("卡片回收登记" + registerInfo);
			sysActionLog.setDealCode(DealCode.CARD_RECOVERY_SAVE);
			publicDao.save(sysActionLog);
			JSONObject registerInfoObject = JSONObject.parseObject(registerInfo);
			JSONArray infoArray = registerInfoObject.getJSONArray("info");
			StringBuffer note = new StringBuffer();
			int success = 0;
			int failure = 0;
			for(int index = 0; index < infoArray.size(); index++) {
				JSONObject object = infoArray.getJSONObject(index);
				String boxNo = object.getString("boxNo");
				String cardNo = object.getString("cardNo");
				CardBaseinfo cardBaseinfo = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + cardNo + "'");
				if (cardBaseinfo == null) {
					note.append("卡号【" + cardNo + "】不存在<br/>");
					failure++;
					continue;
				}
				CardApply cardApply = (CardApply) findOnlyRowByHql("from CardApply c where c.cardNo = '" + cardNo + "' and c.customerId = '" + cardBaseinfo.getCustomerId() + "'");
				if (cardApply == null) {
					note.append("卡号【" + cardNo + "】没有对应的申领信息<br/>");
					failure++;
					continue;
				}
				CardApplyTask cardApplyTask = (CardApplyTask) findOnlyRowByHql("from CardApplyTask c where c.taskId = '" + cardApply.getTaskId() + "'");
				if (cardApplyTask == null) {
					note.append("卡号【" + cardNo + "】没有对应的任务信息<br/>");
					failure++;
					continue;
				}
				BasePersonal basePersonal = (BasePersonal) findOnlyRowByHql("from BasePersonal b where b.customerId = '" + cardApply.getCustomerId() + "'");
				if (basePersonal == null) {
					note.append("卡号【" + cardNo + "】的申领信息未找到相应的人员信息<br/>");
					failure++;
					continue;
				}
				if (!cardApplyTask.getTaskState().equals(Constants.TASK_STATE_YJS) && !cardApplyTask.getTaskState().equals(Constants.TASK_STATE_FFZ) && !cardApplyTask.getTaskState().equals(Constants.TASK_STATE_FFWC)) {
					note.append("卡号【" + cardNo + "】的任务信息状态不是已接收、发放中或发放完成状态<br/>");
					failure++;
					continue;
				}
				if (!cardApply.getApplyState().equals(Constants.APPLY_STATE_YJS) && !cardApply.getApplyState().equals(Constants.APPLY_STATE_YFF)) {
					note.append("卡号【" + cardNo + "】的申领信息状态不是已接收或已发放状态<br/>");
					failure++;
					continue;
				}
				CardRecoverReginfo cardRecoverReginfo = new CardRecoverReginfo();
				cardRecoverReginfo.setCardNo(cardApply.getCardNo());
				cardRecoverReginfo.setCertNo(basePersonal.getCertNo());
				cardRecoverReginfo.setName(basePersonal.getName());
				cardRecoverReginfo.setAppWay(cardApply.getApplyWay());
				cardRecoverReginfo.setAppType(cardApply.getApplyType());
				cardRecoverReginfo.setAppDate(cardApply.getApplyDate());
				cardRecoverReginfo.setAppAddr(basePersonal.getLetterAddr());
				cardRecoverReginfo.setStatus(Constants.RECOVER_STATUS_YHS);
				cardRecoverReginfo.setBoxNo(boxNo);
				cardRecoverReginfo.setBrchId(sysActionLog.getBrchId());
				cardRecoverReginfo.setUserId(sysActionLog.getUserId());
				cardRecoverReginfo.setRecTime(sysActionLog.getDealTime());
				cardRecoverReginfo.setDealNo(sysActionLog.getDealNo());
				cardRecoverReginfo.setInitialStatus(cardApply.getApplyState());
				publicDao.save(cardRecoverReginfo);
				cardApply.setApplyState(Constants.APPLY_STATE_YHS);
				publicDao.update(cardApply);
				success++;
			}
			jsonObject.put("success",success);
			jsonObject.put("failure",failure);
			jsonObject.put("note",note.toString());
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(sysActionLog.getDealNo());
			trServRec.setBrchId(sysActionLog.getBrchId());
			trServRec.setUserId(sysActionLog.getUserId());
			trServRec.setBizTime(sysActionLog.getDealTime());
			trServRec.setNote(sysActionLog.getNote());
			trServRec.setDealState(Constants.STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			publicDao.save(trServRec);
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}

	@Override
	@SuppressWarnings("unchecked")
	public TrServRec saveCardIssue(BasePersonal basePersonal, CardApply cardApply, CardRecoverReginfo cardRecoverReginfo, CardBaseinfo cardBaseinfo) throws CommonException {
		if (cardRecoverReginfo.getInitialStatus().equals(Constants.APPLY_STATE_YJS)) {
			cardApply.setApplyState(cardRecoverReginfo.getInitialStatus());
			return cardIssuseService.saveOneCardIssuse(cardApply, cardBaseinfo);
		} else if(cardRecoverReginfo.getInitialStatus().equals(Constants.APPLY_STATE_YFF)) {
			SysActionLog sysActionLog = getCurrentActionLog();
			sysActionLog.setDealCode(DealCode.ISSUSE_TYPE_PERSONAL);
			sysActionLog.setMessage("个人发放：" + cardApply.getCardNo());
			sysActionLog.setNote("个人发放：" + cardApply.getCardNo());
			publicDao.save(sysActionLog);

			cardRecoverReginfo.setFfDealNo(sysActionLog.getDealNo());
			cardRecoverReginfo.setFfBrchId(sysActionLog.getBrchId());
			cardRecoverReginfo.setFfUserId(sysActionLog.getUserId());
			cardRecoverReginfo.setFfDate(sysActionLog.getDealTime());
			cardRecoverReginfo.setStatus(Constants.RECOVER_STATUS_YFF);
			publicDao.update(cardRecoverReginfo);

			cardApply.setApplyState(Constants.APPLY_STATE_YFF);
			publicDao.update(cardRecoverReginfo);
			
			TrServRec trServRec = new TrServRec();
			trServRec.setDealCode(sysActionLog.getDealCode());
			trServRec.setDealNo(sysActionLog.getDealNo());
			trServRec.setBrchId(sysActionLog.getBrchId());
			trServRec.setUserId(sysActionLog.getUserId());
			trServRec.setBizTime(sysActionLog.getDealTime());
			trServRec.setNote(sysActionLog.getNote());
			trServRec.setCardType(cardBaseinfo.getCardType());
			trServRec.setCardNo(cardBaseinfo.getCardNo());
			trServRec.setCertType(basePersonal.getCertType());
			trServRec.setCertNo(basePersonal.getCertNo());
			trServRec.setCustomerId(String.valueOf(basePersonal.getCustomerId()));
			trServRec.setCustomerName(basePersonal.getName());
			trServRec.setAgtCertType(cardApply.getAgtCertType());
			trServRec.setAgtCertNo(cardApply.getAgtCertNo());
			trServRec.setAgtName(cardApply.getAgtName());
			publicDao.save(trServRec);

			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, sysActionLog.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(sysActionLog.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "工本费：￥" + Arith.cardreportsmoneydiv(Tools.processNull(cardApply.getCostFee())) + " / 其他费用：￥" + Arith.cardreportsmoneydiv(Tools.processNull(cardApply.getOtherFee())));
			json.put(ReceiptContants.FIELD.CARD_NO, cardApply.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, cardApply.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, trServRec.getCustomerName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", trServRec.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, trServRec.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, cardApply.getRecvName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", cardApply.getRecvCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, cardApply.getRecvCertNo()); // 代理人证件号码
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(sysActionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(sysActionLog, json, ReceiptContants.TYPE.COMMON, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			return trServRec;
		}
		throw new CommonException();
	}

	@Override
	public Long saveCardRecovery(String cardNo, String boxNo, String orderNo,Users oper) throws CommonException {
		try{
			if(Tools.processNull(cardNo).equals("")){
    			throw new CommonException("回收的卡号不能为空！");
    		}
    		if(Tools.processNull(boxNo).equals("")){
    			//throw new CommonException("存放盒号不能为空！");
    		}
    		StringBuffer sb = new StringBuffer();
    		sb.append(oper.getBrchId() + "|");
    		sb.append(Constants.ACPT_TYPE_GM + "|");
    		sb.append(oper.getUserId() + "|");
    		sb.append("" + "|");
    		sb.append(Tools.processNull(cardNo) + "|");
    		sb.append(Tools.processNull(boxNo) + "|");
    		sb.append(Tools.processNull(orderNo) + "|");
    		sb.append("0" + "|");
    		sb.append("" + "|");
    		List inParamList = new ArrayList();
    		inParamList.add(sb.toString());
    		List outParamList = new ArrayList();
    		outParamList.add(java.sql.Types.VARCHAR);
    		outParamList.add(java.sql.Types.VARCHAR);
    		outParamList.add(java.sql.Types.VARCHAR);
    		List resList = this.publicDao.callProc("PK_CARD_APPLY_ISSUSE.P_CARD_RECOVERY", inParamList, outParamList);
    		if(resList == null || resList.isEmpty()){
    			throw new CommonException("卡片回收调取过程出现错误！");
    		}
    		if(Integer.valueOf(resList.get(0).toString()) != 0){
    			throw new CommonException(resList.get(1).toString());
    		}
    		Long dealNo = Long.valueOf(resList.get(2).toString());
			return dealNo;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	public TrServRec saveCardRecoveryIssuse(CardApply apply, TrServRec agt)throws CommonException{
		try{
			SysActionLog actionLog = this.getCurrentActionLog();
			TrServRec rec = new TrServRec();
			StringBuffer sb = new StringBuffer();
			sb.append(Tools.processNull(actionLog.getBrchId()) + "|");
			sb.append(Constants.ACPT_TYPE_GM + "|");
			sb.append(Tools.processNull(actionLog.getUserId()) + "|");
			sb.append("" + "|");
			sb.append(Tools.processNull(apply.getCardNo()) + "|");
			sb.append("" + "|");
			sb.append("0" + "|");
			sb.append("0" + "|");
			sb.append(Tools.processNull(apply.getRecvCertType()) + "|");
			sb.append(Tools.processNull(apply.getRecvCertNo()) + "|");
			sb.append(Tools.processNull(apply.getRecvName()) + "|");
			sb.append(Tools.processNull(apply.getAgtPhone()) + "|");
			sb.append("回收卡_" + (Tools.processNull(apply.getApplyType()).equals(Constants.APPLY_TYPE_BK) ? "补卡发放" : Tools.processNull(apply.getApplyType()).equals(Constants.APPLY_TYPE_HK) ? "换卡发放" : "初次申领发放"));
			List inParam = new ArrayList();
			inParam.add(sb.toString());
			List<Integer> outParam = new java.util.ArrayList<Integer>();
			outParam.add(java.sql.Types.VARCHAR);
			outParam.add(java.sql.Types.VARCHAR);
			outParam.add(java.sql.Types.VARCHAR);
			List ret = publicDao.callProc("PK_CARD_APPLY_ISSUSE.p_smz_kff",inParam,outParam);
			if(!(ret == null || ret.size() == 0)){
				int res = Integer.parseInt(ret.get(0).toString());
				if(res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				}else{
					rec = (TrServRec)this.findOnlyRowByHql("from TrServRec where dealNo = " + ret.get(2).toString());
					rec.setAgtName(agt.getAgtName());
					rec.setAgtCertType(agt.getAgtCertType());
					rec.setAgtCertNo(agt.getAgtCertNo());
					rec.setAgtName(agt.getAgtName());
				}
			}else{
				throw new CommonException("调用存储过程出错！");
			}
			actionLog = (SysActionLog) this.findOnlyRowByHql("from SysActionLog where dealNo = " + rec.getDealNo());
			if(apply.getApplyType().equals(Constants.APPLY_TYPE_BK) || apply.getApplyType().equals(Constants.APPLY_TYPE_HK)){
				AccAccountSub oldAcc = (AccAccountSub)this.findOnlyRowByHql("from AccAccountSub t where acc_Kind = '" + Constants.ACC_KIND_ZJZH + "' and card_No = '" + apply.getOldCardNo() + "'");
				if(oldAcc != null && oldAcc.getBal() > 0){
					HashMap<String,String> accMap = new HashMap<String, String>();
					accMap.put("acpt_id",actionLog.getBrchId());//
					accMap.put("acpt_type",Constants.ACPT_TYPE_GM);//0商户  1网点  柜面的为网点,终端的为商户
					accMap.put("tr_batch_no","");
					accMap.put("term_tr_no","");
					accMap.put("card_no1",oldAcc.getCardNo());
					accMap.put("acc_kind1",oldAcc.getAccKind());//联机账户
					accMap.put("wallet_id1","00");
					accMap.put("card_no2",apply.getCardNo());
					accMap.put("acc_kind2",oldAcc.getAccKind());//联机账户
					accMap.put("wallet_id2","00");
					accMap.put("tr_amt",oldAcc.getBal() + "");
					accMap.put("tr_state",Constants.TR_STATE_ZC);
					accMap.put("pwd","");//转出卡账户密文密码
					accService.transfer(actionLog,accMap);
				}
			}
			//保存业务凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, actionLog.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(actionLog.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "工本费：￥" + Arith.cardreportsmoneydiv(Tools.processNull(apply.getCostFee())) + " / 其他费用：￥" + Arith.cardreportsmoneydiv(Tools.processNull(apply.getOtherFee())));
			json.put(ReceiptContants.FIELD.CARD_NO, apply.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, apply.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, rec.getCustomerName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, rec.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, rec.getAgtName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getAgtCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, rec.getAgtCertNo()); // 代理人证件号码
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(actionLog, json, ReceiptContants.TYPE.COMMON, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
}
