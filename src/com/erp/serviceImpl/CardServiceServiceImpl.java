package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.http.Consts;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.AccQcqfLimit;
import com.erp.model.BasePersonal;
import com.erp.model.BaseSiinfo;
import com.erp.model.BhkZzRegister;
import com.erp.model.CardAppSyn;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardBindBankCard;
import com.erp.model.CardBlack;
import com.erp.model.CardBlackRec;
import com.erp.model.CardBlackRecId;
import com.erp.model.CardConfig;
import com.erp.model.CardFjmkSaleList;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.AccAcountService;
import com.erp.service.CardServiceService;
import com.erp.service.DoWorkClientService;
import com.erp.service.ZxcService;
import com.erp.util.AesPlus;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.MD5Util;
import com.erp.util.PageUtil;
import com.erp.util.ReceiptContants;
import com.erp.util.ResourceUtil;
import com.erp.util.SqlTools;
import com.erp.util.Tools;
import com.erp.viewModel.ZxcModel;

@Service("cardServiceService")
public class CardServiceServiceImpl extends BaseServiceImpl implements CardServiceService {
	private static final String WS_ID_ACC_QCQF_LIMIT_SET = "B0063";
	private static final String WS_FIELD_TRCODE = "trcode";
	private static final String WS_FIELD_BANK_ID = "bizid";
	private static final String WS_FIELD_USER_ID = "operid";
	private static final String WS_FIELD_TERM_NO = "termno";
	private static final String WS_FIELD_SUB_CARD_NO = "cardno";
	private static final String WS_FIELD_CERT_NO = "sfz";
	private static final String WS_FIELD_NAME = "name";
	private static final String WS_FIELD_BANK_CARD_NO = "bankcardno";
	private static final String WS_FIELD_DATE = "date";
	private static final String WS_FIELD_TIME = "time";
	private static final String WS_FIELD_AMT = "amt";
	private static final String WS_DATE_FORMAT = "yyyyMMdd";
	private static final String WS_TIME_FORMAT = "HHmmss";

	private static Logger logger = Logger.getLogger(CardServiceServiceImpl.class);
	@Autowired
	private AccAcountService accService;
	@Autowired
	private ZxcService zxcService;
	@Autowired
	private DoWorkClientService doWorkService;

	public Long getCount(Map<String, Object> map, PageUtil pageUtil) throws CommonException{
		Long l =0L;
		try {
			StringBuffer hql = new StringBuffer();
			hql.append("select count(*) from (");
			hql.append("select c.card_Id id,b.name name ,b.cert_no certNo,c.card_No cardNo,c.sub_Card_id subCardId");
			hql.append(",c.card_Type cardType,c.card_State cardState,"
					+ SqlTools.divHundred("c.foregift") + " foregift ,"
					+ SqlTools.divHundred("c.foregift_Bal") + " foregiftBal,"
					+ SqlTools.divHundred("c.cost_fee")
					+ " costFee ,p.lss_flag  lssFlag");
			hql.append(" from card_baseinfo c left outer join base_personal b on c.CUSTOMER_ID = b.CUSTOMER_ID,Cm_Card_Para p where  c.card_Type=p.card_Type ");
			hql.append(") u where 1=1 ");
			hql.append(Constants.getSearchConditionsSQL("u", map));
			hql.append(Constants.getGradeSearchConditionsHQL("u", pageUtil));
			l= publicDao.countSql(hql.toString());
		} catch (Exception e) {
			throw new CommonException("发生错误", e);
		}
		return l;
	}
	/**
	 * 挂失保存
	 * @param card 挂失卡信息
	 * @param rec 挂失业务日志
	 * @param lss_Flag 挂失类型
	 * @param actionLog 挂失操作日志
	 */
	@SuppressWarnings("unchecked")
	@Override
	public Long savegs(CardBaseinfo card, TrServRec rec, String lss_Flag,SysActionLog actionLog) throws CommonException {
		String acc_state = "";
		try{
			//1.记录操作日志
			if(actionLog == null){
				actionLog = this.getCurrentActionLog();
			}
			actionLog.setMessage("挂失成功，卡号：" + card.getCardNo());
			BasePersonal person = (BasePersonal)this.findOnlyRowByHql("from BasePersonal b where b.customerId = '" + card.getCustomerId() + "'");
			//2.判断挂失类型 口头挂失、书面挂失
			if(lss_Flag.equals(Constants.LSS_FLAG_KTGS)) {//口头挂失
				acc_state = "2";
				if (Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_YGS) || card.getCardState().equals(Constants.CARD_STATE_GS)) {
					throw new CommonException("卡片状态已是" + super.getCodeNameBySYS_CODE("CARD_STATE", card.getCardState()) + "状态，不允许" + super.getCodeNameBySYS_CODE("LSS_FLAG", Constants.LSS_FLAG_KTGS+"") + "！");
				}
				rec.setDealCode(DealCode.CARD_LOSS_PRE);// 交易代码
			}else if(lss_Flag.equals(Constants.LSS_FLAG_SMGS)) {//正式挂失
				acc_state = "3";
				if (!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZC) && !Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_YGS)) {
					throw new CommonException("卡片状态不是正常或临时挂失状态，不允许" + super.getCodeNameBySYS_CODE("LSS_FLAG", Constants.LSS_FLAG_SMGS) + "！");
				}
				rec.setDealCode(DealCode.CARD_LOSS);//交易代码
				if(this.getSysConfigurationParameters("IS_ZXC").equals("0")){//#是否加载调用自行车接口业务0调用，1不调用
					try{
						ZxcModel zxcModel = new ZxcModel();
						zxcModel.setCardno(card.getCardNo());
						zxcModel.setOperid(actionLog.getUserId());
						zxcModel.setAmt("");
						//zxcService.saveZxcCancel(person, actionLog, zxcModel);
					} catch (Exception ee) {
						logger.debug("自行车取消应用失败："+ee.getMessage());
					}
				}
				if(!Tools.processNull(rec.getCertNo()).equals("")){
				}
			} else {
				throw new CommonException("挂失类型选择错误！");
			}
			actionLog.setDealCode(rec.getDealCode());
			publicDao.save(actionLog);
			if(Tools.processNull(card.getCardType()).equals(Constants.CARD_TYPE_QGN) || Tools.processNull(card.getCardType()).equals(Constants.CARD_TYPE_SMZK)){
				this.saveSynch2CardUpate(null,rec.getCertNo(),rec.getCardNo(),null,actionLog.getDealNo(),null);
			}
			//判断是否开通自行车且开通状态是否正常
			Object obj = (Object)this.findOnlyRowBySql("select count(*) from card_app_bind where card_no = '" + rec.getCardNo() + "'" + "and app_type = '10' and bind_state = '0'");
			Integer count = Integer.parseInt(String.valueOf(obj));
			if(count > 0) {
				//同步状态到自行车
				StringBuffer sb = new StringBuffer();
				sb.append("02" + "|");
				sb.append(rec.getCardNo() + "|");
				sb.append(actionLog.getDealNo() + "|");
				sb.append(rec.getBrchId() + "|");
				sb.append(rec.getUserId() + "|");
				sb.append("0" + "|");
				sb.append(Constants.ACPT_TYPE_GM + "|");
				sb.append("" + "|");
				List<String> inParamList = new ArrayList<String>();
				inParamList.add(sb.toString());
				List outParamList = new ArrayList();
				outParamList.add(java.sql.Types.VARCHAR);
				outParamList.add(java.sql.Types.VARCHAR);
				outParamList.add(java.sql.Types.VARCHAR);
				List res = publicDao.callProc("pk_service_outer.p_zxcApply_handle",inParamList,outParamList);
				if(res != null && res.size() > 0){
					if (Integer.parseInt(res.get(0).toString()) != 00000000) {
						throw new CommonException("自行车同步挂失失败!");
					}
				}else{
					throw new CommonException("调取过程返回为空！");
				}
			}
			//3.记录业务日志
			rec.setDealNo(actionLog.getDealNo());
			rec.setBizTime(actionLog.getDealTime());// 业务办理时间
			rec.setDealNo(actionLog.getDealNo());
			rec.setNote("挂失卡物理号：" + card.getCardId() + ",卡号：" + card.getCardNo());
			publicDao.save(rec);// 保存综合业务日志表
			//4.更新卡状态、账户状态
			publicDao.doSql("update card_baseinfo set card_State = '" + acc_state + "',last_modify_date = sysdate where card_no = '" + card.getCardNo() + "'");
			publicDao.doSql("update ACC_ACCOUNT_SUB set ACC_STATE = '" + acc_state + "',lss_date = sysdate where card_no = '" + card.getCardNo() + "'");
			//5.保存黑名单
			//if(card.getCardType().equals(Constants.CARD_TYPE_SMZK)){
			this.saveOrUpdateCardBlack(card,rec,Constants.BLK_STATE_YX,(lss_Flag.equals(Constants.LSS_FLAG_KTGS) ? Constants.BLK_TYPE_KTGS : Constants.BLK_TYPE_GS));
			//}
			//6.保存报表信息
			//保存业务凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, actionLog.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(actionLog.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "工本费：￥" + Arith.cardreportsmoneydiv("0"));
			json.put(ReceiptContants.FIELD.CARD_NO, rec.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
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
			//this.saveSysReport(actionLog,reportSetValue(rec),"/reportfiles/GuaShiJieGuaZhuXiaoPZ.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
			return actionLog.getDealNo();
		} catch (Exception e) {
			e.printStackTrace();
			throw new CommonException(e.getMessage());
		}
	}
	@SuppressWarnings("unchecked")
	public Long saveGj(CardBaseinfo card, TrServRec rec)throws CommonException {
		try{
			//1.记录操作日志
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(DealCode.CARD_RELOSS);
			log.setMessage("卡片解挂,卡号：" + card.getCardNo());
			publicDao.save(log);
			//2.修改卡状态、账户状态
			publicDao.doSql("update card_baseinfo set card_State = '" + Constants.CARD_STATE_ZC + "',last_modify_date = sysdate where card_No = '" + card.getCardNo() + "'");
			publicDao.doSql("update ACC_ACCOUNT_SUB set ACC_STATE = '" + Constants.ACC_STATE_ZC + "',lss_date = '' where card_no = '" + card.getCardNo() + "'");
			//3.记录业务日志
			BasePersonal bp = null;
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
			}
			bp = bp == null ? new BasePersonal() : bp;
			if(Tools.processNull(card.getCardType()).equals(Constants.CARD_TYPE_QGN) || Tools.processNull(card.getCardType()).equals(Constants.CARD_TYPE_SMZK)){
				this.saveSynch2CardUpate(null,bp.getCertNo(),card.getCardNo(),null,log.getDealNo(),null);
			}
			rec.setDealNo(log.getDealNo());
			rec.setCardNo(card.getCardNo());
			rec.setCardId(card.getCardId());
			rec.setCardAmt(1L);
			rec.setCustomerName(bp.getName());
			rec.setCertNo(bp.getCertNo());
			rec.setCertType(bp.getCertType());
			rec.setTelNo(bp.getMobileNo());
			rec.setDealCode(log.getDealCode());
			rec.setCustomerId(card.getCustomerId());
			rec.setBizTime(log.getDealTime());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setClrDate(this.getClrDate());
			rec.setCardType(card.getCardType());
			rec.setDealState("0");
			rec.setNote(log.getMessage());
			publicDao.save(rec);
			//4.处理黑名单
			//if(card.getCardType().equals("120")){
			saveOrUpdateCardBlack(card,rec,Constants.BLK_STATE_WX,"");
			//}
			//判断是否开通自行车且开通状态是否正常
			Object obj = (Object)this.findOnlyRowBySql("select count(*) from card_app_bind where card_no = '" + rec.getCardNo() + "'" + "and app_type = '10' and bind_state = '0'");
			Integer count = Integer.parseInt(String.valueOf(obj));
			if(count > 0) {
				//同步状态到自行车
				StringBuffer sb = new StringBuffer();
				sb.append("03" + "|");
				sb.append(rec.getCardNo() + "|");
				sb.append(log.getDealNo() + "|");
				sb.append(rec.getBrchId() + "|");
				sb.append(rec.getUserId() + "|");
				sb.append("0" + "|");
				sb.append(Constants.ACPT_TYPE_GM + "|");
				sb.append("" + "|");
				List<String> inParamList = new ArrayList<String>();
				inParamList.add(sb.toString());
				List outParamList = new ArrayList();
				outParamList.add(java.sql.Types.VARCHAR);
				outParamList.add(java.sql.Types.VARCHAR);
				outParamList.add(java.sql.Types.VARCHAR);
				List res = publicDao.callProc("pk_service_outer.p_zxcApply_handle",inParamList,outParamList);
				if(res != null && res.size() > 0){
					if (Integer.parseInt(res.get(0).toString()) != 00000000) {
						throw new CommonException("自行车同步解挂失败!");
					}
				}else{
					throw new CommonException("调取过程返回为空！");
				}
			}


			//5.保存报表信息
			//保存业务凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "工本费：￥" + Arith.cardreportsmoneydiv("0"));
			json.put(ReceiptContants.FIELD.CARD_NO, rec.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, rec.getCustomerName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, rec.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, rec.getAgtName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getAgtCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, rec.getAgtCertNo()); // 代理人证件号码
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(log, json, ReceiptContants.TYPE.COMMON, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			//this.saveSysReport(log,reportSetValue(rec),"/reportfiles/GuaShiJieGuaZhuXiaoPZ.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
		return rec.getDealNo();
	}
	/**
	 * 注销
	 * @param rec        业务日志
	 * @param card       注销卡
	 * @param isGoodCard 是否好卡
	 * @param cardAmt    卡内余额  分
	 * @param zxreason   注销原因
	 * @return
	 * @throws Exception
	 */
	@SuppressWarnings({ "unchecked"})
	public TrServRec saveZx(Users oper,SysActionLog log,TrServRec rec,CardBaseinfo card,String isGoodCard,String cardAmt,String zxreason) throws CommonException{
		try{
			//1.判断卡状态,记录日志信息
//			if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_GS)){
//				throw new CommonException("当前卡片不是书面挂失状态，不能进行注销，当前卡状态：" + this.getCodeNameBySYS_CODE("CARD_STATE",card.getCardState()));
//			}
			if(rec == null){
				rec = new TrServRec();
			}
			log.setDealCode(DealCode.NAMEDCARD_REDEEM);//注销
			log.setMessage("注销,卡号:" + card.getCardNo() + ",钱包账户返回方式," + (Tools.processNull(isGoodCard).equals("0") ? "卡面":"账户") + ",金额：");
			log.setMessage(log.getMessage() + (Tools.processNull(isGoodCard).equals("0") ? Arith.cardreportsmoneydiv(cardAmt) : "以账户为准"));
			publicDao.save(log);
			AccAccountSub acc = (AccAccountSub) this.findOnlyRowByHql("from AccAccountSub t where t.cardNo = '" + card.getCardNo() + "' and t.accKind = '" + Constants.ACC_KIND_QBZH + "'");
			if(acc == null){
				throw new CommonException("该卡未查询到钱包账户，不能进行注销，请仔细核对后重试！");
			} else if(!"0".equals(acc.getFrzFlag()) || acc.getFrzAmt() > 0){
				throw new CommonException("脱机账户有冻结金额，请先解冻！");
			}
			// 2.如果是好卡且有卡面金额则记录卡面金额
			rec.setCancelReason(zxreason);
			if (Tools.processNull(isGoodCard).equals("0")) { // 好卡
				rec.setRsvOne("0");
				rec.setPrvBal(getLong(Long.valueOf(cardAmt)));
			} else if (Tools.processNull(isGoodCard).equals("1")) { // 坏卡
				rec.setRsvOne("1");
				rec.setPrvBal(0L);
			} else if (Tools.processNull(isGoodCard).equals("2")) { // 无卡
				rec.setRsvOne("2");
				rec.setPrvBal(0L);
			}
			AccAccountSub onlineAcc = (AccAccountSub) findOnlyRowByHql("from AccAccountSub t where t.cardNo = '" + card.getCardNo() + "' and t.accKind = '" + Constants.ACC_KIND_ZJZH + "'");
			if(onlineAcc == null){
				throw new CommonException("该卡未查询到联机账户，不能进行注销，请仔细核对后重试！");
			} else if(!"0".equals(onlineAcc.getFrzFlag()) || onlineAcc.getFrzAmt() > 0){
				throw new CommonException("联机账户有冻结金额，请先解冻！");
			}
			//3.更新卡状态,账户状态
			publicDao.doSql("update card_baseinfo t set t.last_modify_date = to_date('" + DateUtil.formatDate(log.getDealTime(),"yyyyMMddHHmmss") +
					"','yyyymmddhh24miss'),t.card_state = '" + Constants.CARD_STATE_ZX + "',t.cancel_date = to_date('" +
					DateUtil.formatDate(log.getDealTime(),"yyyyMMddHHmmss") + "','yyyymmddhh24miss'),t.cancel_reason = '" + zxreason +
					"',t.RECOVER_FLAG = '" + (Tools.processNull(isGoodCard).equals("0") ? "0" : "1") +"' where t.card_no = '" + card.getCardNo() + "'"
			);
			publicDao.doSql("update acc_account_sub t set t.cls_date = to_date('" + DateUtil.formatDate(log.getDealTime(),"yyyyMMddHHmmss") +
					"','yyyymmddhh24miss'),t.cls_user_id = '" + oper.getUserId() + "',t.acc_state = '" + Constants.ACC_STATE_ZX +
					"' where t.card_no = '" + card.getCardNo() + "'");
			BasePersonal person = new BasePersonal();
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				person = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(person == null){
					person = new BasePersonal();
				}
			}
			if(Tools.processNull(card.getCardType()).equals(Constants.CARD_TYPE_QGN) || Tools.processNull(card.getCardType()).equals(Constants.CARD_TYPE_SMZK)){
				this.saveSynch2CardUpate(null,person.getCertNo(),card.getCardNo(),null,log.getDealNo(),null);
			}
			if(Tools.processNull(card.getCardType()).equals(Constants.CARD_TYPE_QGN) && Tools.processNull(isGoodCard).equals("0")){
				List<String> inPara = new ArrayList<String>();
				StringBuffer execpro = new StringBuffer();
				execpro.append(log.getBrchId() + "|");
				execpro.append(Constants.ACPT_TYPE_GM + "|");
				execpro.append(log.getUserId() + "|");
				execpro.append(log.getDealNo() + "|");
				execpro.append(log.getDealCode() + "|");
				execpro.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "|");
				execpro.append(card.getCardNo() + "|");
				execpro.append("" + "|");
				execpro.append("2" + "|");
				execpro.append(log.getMessage() + "|");
				inPara.add(execpro.toString());
				List outPara = new ArrayList();
				outPara.add(java.sql.Types.VARCHAR);
				outPara.add(java.sql.Types.VARCHAR);
				List outMsg = publicDao.callProc("pk_card_Stock.P_BHK", inPara, outPara);
				if(outMsg != null && outMsg.size() > 0){
					if(Integer.valueOf(outMsg.get(0).toString()) != 0){
						throw new CommonException(outMsg.get(1).toString());
					}
				}else{
					throw new CommonException("调取过程出现错误");
				}
			}
			publicDao.doSql("update card_apply set apply_state = '" + Constants.APPLY_STATE_YZX + "' where card_no = '" + card.getCardNo() + "'");
			//4.记录综合业务日志信息
			rec.setCustomerName(person.getName());
			rec.setCustomerId(person.getCustomerId() + "");
			//如果代理人电话号码为空,设置客户电话号码
			if(Tools.processNull(rec.getAgtTelNo()).equals("")){
				rec.setAgtTelNo(person.getMobileNo());
			}
			rec.setCertType(person.getCertType());
			rec.setCertNo(person.getCertNo());
			rec.setCardId(card.getCardId());
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setCardAmt(1L);
			rec.setDealNo(log.getDealNo());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setDealCode(log.getDealCode());
			rec.setTelNo(person.getMobileNo());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setNote(log.getMessage());
			rec.setClrDate(this.getClrDate());
			publicDao.save(rec);
			//5.记录报表
			//this.saveSysReport(log,reportSetValue(rec),"/reportfiles/GuaShiJieGuaZhuXiaoPZ.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.CARD_NO, card.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, person.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, person.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, rec.getAgtName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getAgtCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, rec.getAgtCertNo()); // 代理人证件号码
			json.put(ReceiptContants.FIELD.CANCEL_REASON, String.valueOf(findOnlyFieldBySql("select code_name from sys_code where code_value = '" + zxreason + "' and code_type = 'CANCEL_REASON'"))); // 注销原因
			json.put(ReceiptContants.FIELD.CARD_STATUS, isGoodCard); // 卡状态（好卡0，坏卡1，无卡2）
			json.put(ReceiptContants.FIELD.ONLINE_ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(onlineAcc.getBal() + "")); // 联机账户余额
			json.put(ReceiptContants.FIELD.OFFLINE_ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(acc.getBal() + "")); // 脱机账户余额
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSessionSysBranch().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(log, json, ReceiptContants.TYPE.CARD_CANCEL, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 账户返还保存
	 * @param oper      操作员
	 * @param actionLog 操作日志
	 * @param cardNo    账户卡号
	 * @param totalAmt  账户返还总金额
	 * @return          业务日志
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveReturnCash(String cardNo, String bankCardNo, Long totalAmt) {
		try{
			SysActionLog actionLog = getCurrentActionLog();

			String isExamine = getSysConfigurationParameters("IS_EXAMINE_CASH_BACK");//0是 1否
			//1.操作柜员信息验证,条件判断
			Long inTotalAmt = 0L;
			Users oper = validUsers(actionLog.getUserId());
			if(Tools.processNull(cardNo).equals("")){
				throw new CommonException("余额返现卡号不能为空！");
			}
			if(!(actionLog instanceof SysActionLog) || actionLog == null){
				throw new CommonException("余额返现操作日志不能为空！");
			}
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
			if(card == null){
				throw new CommonException("卡片信息不存在，不能进行余额返现！");
			}
			if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZX)){
				throw new CommonException("卡状态不是注销状态，不能进行余额返现！");
			}
			//判断是否登记
			TrServRec oldRec = (TrServRec) findOnlyRowByHql("from TrServRec where cardNo = '" + cardNo + "' and dealCode ='" + DealCode.BALANCE_RESTORE + "' and dealState = '" + Constants.TR_STATE_ZC + "'");
			if(oldRec != null) {
				throw new CommonException("余额返还已登记.");
			}

			//2.查找原始注销记录,并记录日志信息
			Object[]  zxrec = (Object[])this.findOnlyRowBySql("select r1.deal_No, r1.prv_Bal,r1.rsv_one from (select r.* from tr_serv_rec r where r.deal_code in('" + DealCode.NAMEDCARD_REDEEM + "','" + DealCode.NAMEDCARD_REISSUE + "','" +
					DealCode.NAMEDCARD_CHG + "') and r.card_no = '" + cardNo + "' order by r.biz_time desc) r1 where rownum = 1");
			if(zxrec == null){
				throw new CommonException("余额返现发生错误，未找到原始注销或补换卡记录信息！");
			}
			actionLog.setDealCode(DealCode.BALANCE_RESTORE);
			actionLog.setMessage("余额返现登记, 卡号:" + cardNo + ",返还总金额" + Arith.cardmoneydiv(totalAmt + ""));
			publicDao.save(actionLog);
			//3.获取卡片所有未进行余额发现操作的账户
			List<AccAccountSub> allAccs = this.findByHql("from AccAccountSub t where t.cardNo = '" + cardNo + "' and t.balRslt = '0'");
			if(allAccs == null){
				throw new CommonException("该卡不存在未返还的账户！");
			}
			for(AccAccountSub accAccountSub : allAccs) {
				// 如果需要财务审核，不更改账户余额处理结果
				if(isExamine.equals("1")) {
					publicDao.doSql("update ACC_ACCOUNT_SUB t set t.bal_rslt = '1'  where t.card_no = '" + card.getCardNo() + "' and t.acc_kind = '" + accAccountSub.getAccKind() + "'");
				}
				if(accAccountSub.getBal() <= 0){
					continue;
				}
				HashMap hm = new HashMap();
				hm.put("acpt_id",oper.getBrchId());
				hm.put("oper_id",oper.getUserId());
				hm.put("tr_batch_no", null);
				hm.put("term_tr_no", null);
				hm.put("card_no", card.getCardNo());
				hm.put("card_tr_count1", null);
				hm.put("card_bal", null);
				hm.put("acc_kind",accAccountSub.getAccKind());
				hm.put("wallet_id","00");
				long temoFrzAmt = 0L;
				if(accAccountSub.getFrzAmt() == null){
					temoFrzAmt = 0L;
				} else {
					temoFrzAmt = accAccountSub.getFrzAmt();
				}
				if (Tools.processNull(accAccountSub.getAccKind()).equals(Constants.ACC_KIND_QBZH)) { // 钱包
					if (Tools.processNull(zxrec[2].toString()).equals("0")) { // 好卡
						hm.put("tr_amt", Long.valueOf(zxrec[1].toString()) - temoFrzAmt);
						inTotalAmt += Long.valueOf(zxrec[1].toString()) - temoFrzAmt;
					} else if (Tools.processNull(zxrec[2].toString()).equals("1")) { // 坏卡
						Date lssDate = accAccountSub.getLssDate();
						Calendar fhrq = Calendar.getInstance();
						fhrq.setTime(lssDate);
						fhrq.set(Calendar.HOUR_OF_DAY, 0);
						fhrq.set(Calendar.MINUTE, 0);
						fhrq.set(Calendar.SECOND, 0);
						fhrq.add(Calendar.DAY_OF_MONTH, 7); // 不知道是否有配置
						if (fhrq.getTime().compareTo(new Date()) > 0) { // 未到指定返还日期
							throw new CommonException("坏卡未到返还日期.");
						}

						hm.put("tr_amt", accAccountSub.getBal() - temoFrzAmt);
						inTotalAmt += accAccountSub.getBal() - temoFrzAmt;
					} else if (Tools.processNull(zxrec[2].toString()).equals("2")) { // 无卡
						hm.put("tr_amt", 0l);
					}
				} else { // 非钱包
					hm.put("tr_amt", accAccountSub.getBal() - temoFrzAmt);
					inTotalAmt += accAccountSub.getBal() - temoFrzAmt;
				}
				hm.put("acpt_type",Constants.ACPT_TYPE_GM);
				// 如果需要财务审核，不调用账户返现存储过程
				if(isExamine.equals("1")) {
					accService.returnCash(actionLog,hm);
				}
			}
			if(!totalAmt.equals(inTotalAmt)){
				throw new CommonException("金额计算不一致！");
			}
			//4.记录综合业务日志
			BasePersonal person = new BasePersonal();
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				person = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(person == null){
					person = new BasePersonal();
				}
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealCode(actionLog.getDealCode());
			rec.setOldDealNo(Long.valueOf(zxrec[0].toString()));
			rec.setBizTime(actionLog.getDealTime());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setCustomerId(card.getCustomerId());
			rec.setCustomerName(person.getName());
			rec.setClrDate(this.getClrDate());
			rec.setCardId(card.getCardId());
			rec.setCardNo(card.getCardNo());
			rec.setPrvBal(zxrec[1] == null ? 0l : Long.valueOf(Tools.processNull(zxrec[1])));// 卡面余额, 若是好卡
			rec.setRsvOne(zxrec[2].toString()); // 好/坏/无卡标志
			rec.setRsvTwo(bankCardNo); // 银行卡号
			rec.setAmt(inTotalAmt);
			rec.setRsvFive("1"); // 0-已返还, 1-未返还
			rec.setCardType(card.getCardType());
			rec.setCertNo(person.getCertNo());
			rec.setCertType(person.getCertType());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setNote(actionLog.getMessage());

			publicDao.save(rec);
			//5.记录报表信息
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, actionLog.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(actionLog.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.CARD_NO, card.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, person.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, person.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, rec.getAgtName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getAgtCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, rec.getAgtCertNo()); // 代理人证件号码
			for (AccAccountSub accAccountSub : allAccs) {
				if (accAccountSub.getAccKind().equals(Constants.ACC_KIND_ZJZH)) {
					json.put(ReceiptContants.FIELD.ONLINE_ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.sub(accAccountSub.getBal() + "", accAccountSub.getFrzAmt() + ""))); // 联机账户余额
					continue;
				} else if (accAccountSub.getAccKind().equals(Constants.ACC_KIND_QBZH)) { // 钱包

					if (Tools.processNull(zxrec[2].toString()).equals("0")) { //好卡
						json.put(ReceiptContants.FIELD.OFFLINE_ACCOUNT_BALANCE, ""); // 脱机账户余额
					} else if (Tools.processNull(zxrec[2].toString()).equals("1")) { // 坏卡
						json.put(ReceiptContants.FIELD.OFFLINE_ACCOUNT_BALANCE, "￥" + Arith.cardreportsmoneydiv(Arith.sub(accAccountSub.getBal() + "", accAccountSub.getFrzAmt() + ""))); // 脱机账户余额
					} else if (Tools.processNull(zxrec[2].toString()).equals("2")) { // 无卡
						json.put(ReceiptContants.FIELD.OFFLINE_ACCOUNT_BALANCE, ""); // 脱机账户余额
					}

					continue;
				}
			}
			if (Tools.processNull(zxrec[2].toString()).equals("0")) { // 好卡卡面金额
				json.put(ReceiptContants.FIELD.READ_CARD_BALANCE, "￥" + Arith.cardreportsmoneydiv(zxrec[1].toString()));
			} else {
				json.put(ReceiptContants.FIELD.READ_CARD_BALANCE, "");
			}
			json.put(ReceiptContants.FIELD.ACCOUNT_NAME, person.getName()); // 账户名。
			json.put(ReceiptContants.FIELD.TOTAL_BALANCE, "￥" + Arith.cardreportsmoneydiv(totalAmt + "")); // 总余额
			json.put(ReceiptContants.FIELD.BANK_CARD_NO, bankCardNo); // 银行卡号
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSessionSysBranch().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(actionLog, json, ReceiptContants.TYPE.CARD_CANCEL_BALANCE_RETURN, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			return rec;
		}catch(Exception e){
			logger.error(e);
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 补换卡保存
	 * @param rec
	 * @param uers
	 * @param log
	 * @return
	 */
	public TrServRec saveBhk(TrServRec rec,Users users,SysActionLog log,String type) throws CommonException{
		try{
			//1.基本条件判断
			if(rec == null){
				throw new CommonException("操作日志不能为空！");
			}
			if(Tools.processNull(rec.getCardNo()).equals("")){
				throw new CommonException("卡号不能为空！");
			}
			String string = "0".equals(rec.getRsvOne()) ? "好卡" : "坏卡";
			BasePersonal bp = new BasePersonal();
			CardBaseinfo card = new CardBaseinfo();
			if(Tools.processNull(type).equals("0")){
				string += "补卡";
			}else if(Tools.processNull(type).equals("1")){
				string += "换卡";
			}else{
				throw new CommonException("补卡或是换卡操作类型错误！");
			}
			bp = (BasePersonal) this.findOnlyRowByHql("select t from BasePersonal t,CardBaseinfo c where t.customerId = c.customerId and c.cardNo = '" + rec.getCardNo() + "'");
			if(bp == null){
				throw new CommonException("未找到卡片持卡人信息！");
			}
			// 若没有参保信息则不判断参保区域及状态
			BaseSiinfo siinfo = (BaseSiinfo) findOnlyRowByHql("from BaseSiinfo where customerId = '" + bp.getCustomerId() + "'");
			if (siinfo != null && Constants.STATE_ZC.equals(siinfo.getMedState())) {
				this.judgeRegion(bp.getCertNo());
			}
			card = (CardBaseinfo) this.findOnlyRowByHql("select c from CardBaseinfo c where c.customerId = '" + bp.getCustomerId() + "' and cardNo = '" + rec.getCardNo() + "'");
			//2.业务处理,定义请求参数
			StringBuffer sb = new StringBuffer();
			sb.append(Tools.processNull(users.getBrchId())).append("|");//3.受卡方的标识码
			sb.append(Constants.ACPT_TYPE_GM + "|");//2.受理点类型
			sb.append(Tools.processNull(users.getUserId())).append("|");//4.柜员号
			sb.append("").append("|");//1.流水
			sb.append(Tools.processNull(rec.getCardNo())).append("|");//5.老卡号
			sb.append("").append("|");//6.新卡号
			sb.append(Tools.processNull("")).append("|");//7.银行卡卡号
			sb.append(Tools.processNull(bp.getName())).append("|");//8.姓名
			sb.append(Tools.processNull(bp.getCertType())).append("|");//9.证件类型
			sb.append(Tools.processNull(bp.getCertNo())).append("|");//10.证件号码
			if(Tools.processNull(type).equals("0")){//11.是否好卡
				sb.append(Tools.processNull("1")).append("|");//0好卡1坏卡
			}else{
				sb.append(Tools.processNull(rec.getRsvOne())).append("|");//0好卡1坏卡
			}
			sb.append(Tools.processNull(rec.getPrvBal())).append("|");//12.卡面金额
			if(Tools.processNull(type).equals("0")){//13.回收状态
				sb.append(Tools.processNull("1")).append("|");//回收标志,回收：0 未回收：1
			}else{
				sb.append(Tools.processNull("0")).append("|");//回收标志,回收：0 未回收：1
			}
			sb.append(Tools.processNull(type)).append("|");//14.补换卡标志
			if(Tools.processNull(type).equals("0")){
				sb.append(Tools.processNull(Constants.CHG_CARD_REASON_QT)).append("|");//补卡原因
			}else{
				sb.append(Tools.processNull(rec.getChgCardReason())).append("|");//15.换卡原因
			}
			sb.append(Tools.processNull(rec.getAmt())).append("|");//16.工本费
			sb.append(Tools.processNull(rec.getAgtCertType())).append("|");//17.代理人证件类型
			sb.append(Tools.processNull(rec.getAgtCertNo())).append("|");//18.代理人证件类型
			sb.append(Tools.processNull(rec.getAgtName())).append("|");//19.代理人证件类型
			sb.append(Tools.processNull(rec.getAgtTelNo())).append("|");//20.代理人证件类型
			sb.append(Tools.processNull(string + ",老卡号" + rec.getCardNo())).append("|");//21.备注
			sb.append(this.getBrchRegion() + "|");
			List<String> inParamList = new ArrayList<String>();
			inParamList.add(sb.toString());
			inParamList.add("1");
			List outParamList = new ArrayList();
			outParamList.add(java.sql.Types.VARCHAR);
			outParamList.add(java.sql.Types.VARCHAR);
			outParamList.add(java.sql.Types.VARCHAR);
			List res = publicDao.callProc("pk_service_outer.p_cardtrans",inParamList,outParamList);
			String outString = "";
			if(res != null && res.size() > 0){
				if(Integer.parseInt(res.get(1).toString()) != 0){
					throw new CommonException(res.get(2).toString());
				}else{
					outString = res.get(0).toString();
				}
			}else{
				throw new CommonException("调取过程返回为空！");
			}
			//3.更新业务日志信息
			String[] pa = outString.split("\\|");
			TrServRec oldRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = '" + pa[pa.length -1] + "'");
			if(oldRec == null){
				throw new CommonException("找不到业务日志信息！");
			}
			//4.保存报表信
			SysActionLog actionLog = (SysActionLog) this.findOnlyRowByHql("from SysActionLog t where t.dealNo = " + oldRec.getDealNo());
			if(actionLog == null){
				throw new CommonException("生成报表错误，找不到操作日志信息！");
			}
			this.saveSynch2CardUpate(null, bp.getCertNo(), rec.getCardNo(), null, actionLog.getDealNo(), null);
			//保存业务凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, actionLog.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(actionLog.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "工本费：￥" + Arith.cardreportsmoneydiv(Tools.processNull(oldRec.getCostFee())));
			json.put(ReceiptContants.FIELD.CARD_NO, oldRec.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, bp.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", bp.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, bp.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, oldRec.getAgtName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", oldRec.getAgtCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, oldRec.getAgtCertNo()); // 代理人证件号码
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			json.put("p_OldCardState", "1".equals(rec.getRsvOne())?"坏卡":"好卡");
			this.saveSysReport(actionLog, json, "/reportfiles/BHkReceipt.jasper", Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			return oldRec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 换卡转钱包写灰记录
	 * @param rec   业务日志信息
	 * @param oper  操作员
	 * @param log   操作日志
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public TrServRec saveBhkZzTjHjl(TrServRec rec,Users oper) throws CommonException{
		try{
			StringBuffer sb = new StringBuffer();
			sb.append(oper.getBrchId() + "|");//网点编号
			sb.append(Constants.ACPT_TYPE_GM + "|");//受理点类型
			sb.append(oper.getUserId() + "|");//柜员编号/终端编号
			sb.append("|");//终端流水
			sb.append("|");//批次号
			sb.append(rec.getCardNo() + "|");//新卡卡号
			sb.append(rec.getPrvBal() + "|");//新卡交易前金额
			sb.append(rec.getCardTrCount() + "|");//新卡交易序列号
			sb.append(rec.getAmt() + "|");//转账金额
			sb.append(Tools.processNull(rec.getAgtCertType()) + "|");//代理人证件类型
			sb.append(Tools.processNull(rec.getAgtCertNo()) + "|");//代理人证件号码
			sb.append(Tools.processNull(rec.getAgtName()) + "|");//代理人姓名
			sb.append(Tools.processNull(rec.getAgtTelNo()) + "|");//代理人联系方式
			List<String> inParameters = new ArrayList<String>();
			inParameters.add(sb.toString());
			List<Integer> outParameters = new ArrayList<Integer>();
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List outMsg = publicDao.callProc("pk_service_outer.p_bhk_zz_tj",inParameters,outParameters);
			if(outMsg != null && outMsg.size() > 0){
				if(Integer.valueOf(outMsg.get(1).toString()) != 0){
					throw new CommonException(outMsg.get(2).toString());
				}
				String return_string = outMsg.get(0).toString();
				rec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + return_string.split("\\|")[0]);
			}else{
				throw new CommonException("调取过程出现错误");
			}
			//报表信息
			JSONObject report = new JSONObject();
			report.put("p_Title",Constants.APP_REPORT_TITLE + findTrCodeNameByCodeType(rec.getDealCode()) + "凭证");
			report.put("yewuleixing", findTrCodeNameByCodeType(rec.getDealCode()));
			report.put("p_DealNo",rec.getDealNo());
			report.put("p_CardNo1",rec.getOldCardNo());
			String certNo1 = (String) findOnlyFieldBySql("select cert_no from base_personal where customer_id = '" + rec.getCustomerId() + "'");
			report.put("p_CertNo1",certNo1 );
			report.put("p_CustomerName1",rec.getCustomerName());
			report.put("p_Brch",getSessionSysBranch().getFullName());
			report.put("p_CardNo2",rec.getCardNo());
			report.put("p_CustomerName2",rec.getCustomerName());
			report.put("p_PrintTime",DateUtil.formatDate(rec.getBizTime(),"yyyy-MM-dd HH:mm:ss"));
			report.put("p_DbBalance","0");
			report.put("p_CrBalance",Arith.cardreportsmoneydiv(Arith.add(rec.getPrvBal() + "",rec.getAmt() + "")));
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
	 * 换卡转钱包写灰记录(新)
	 * @param rec   业务日志信息
	 * @param oper  操作员
	 * @param log   操作日志
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public TrServRec saveBhkZzTjHjl2(TrServRec rec,Users oper) throws CommonException{
		try{
			StringBuffer sb = new StringBuffer();
			sb.append(oper.getBrchId() + "|");//网点编号
			sb.append(Constants.ACPT_TYPE_GM + "|");//受理点类型
			sb.append(oper.getUserId() + "|");//柜员编号/终端编号
			sb.append("|");//终端流水
			sb.append("|");//批次号
			sb.append(rec.getCardNo() + "|");//新卡卡号
			sb.append(rec.getPrvBal() + "|");//新卡交易前金额
			sb.append(rec.getCardTrCount() + "|");//新卡交易序列号
			sb.append(rec.getAmt() + "|");//转账金额
			sb.append(Tools.processNull(rec.getAgtCertType()) + "|");//代理人证件类型
			sb.append(Tools.processNull(rec.getAgtCertNo()) + "|");//代理人证件号码
			sb.append(Tools.processNull(rec.getAgtName()) + "|");//代理人姓名
			sb.append(Tools.processNull(rec.getAgtTelNo()) + "|");//代理人联系方式
			List<String> inParameters = new ArrayList<String>();
			inParameters.add(sb.toString());
			List<Integer> outParameters = new ArrayList<Integer>();
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List outMsg = publicDao.callProc("pk_service_outer.p_bhk_zz_tj2",inParameters,outParameters);
			if(outMsg != null && outMsg.size() > 0){
				if(Integer.valueOf(outMsg.get(1).toString()) != 0){
					throw new CommonException(outMsg.get(2).toString());
				}
				String return_string = outMsg.get(0).toString();
				rec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + return_string.split("\\|")[0]);
			}else{
				throw new CommonException("调取过程出现错误");
			}
			//报表信息
			JSONObject report = new JSONObject();
			report.put("p_Title",Constants.APP_REPORT_TITLE + findTrCodeNameByCodeType(rec.getDealCode()) + "凭证");
			report.put("yewuleixing", findTrCodeNameByCodeType(rec.getDealCode()));
			report.put("p_DealNo",rec.getDealNo());
			report.put("p_CardNo1",rec.getOldCardNo());
			String certNo1 = (String) findOnlyFieldBySql("select cert_no from base_personal where customer_id = '" + rec.getCustomerId() + "'");
			report.put("p_CertNo1",certNo1 );
			report.put("p_CustomerName1",rec.getCustomerName());
			report.put("p_Brch",getSessionSysBranch().getFullName());
			report.put("p_CardNo2",rec.getCardNo());
			report.put("p_CustomerName2",rec.getCustomerName());
			report.put("p_PrintTime",DateUtil.formatDate(rec.getBizTime(),"yyyy-MM-dd HH:mm:ss"));
			report.put("p_DbBalance","0");
			report.put("p_CrBalance",Arith.cardreportsmoneydiv(Arith.add(rec.getPrvBal() + "",rec.getAmt() + "")));
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
	 * --补换卡转钱包灰记录确认
	 * --1.受理点编号/网点编号
	 * --2.受理点类型   1 柜面  2 代理
	 * --3.受理点终端编号/操作员
	 * --4.终端操作流水 受理点类型为 1的时候可为空
	 * --5.确认流水号
	 * --6.清分日期
	 * @param inParameters
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public TrServRec saveBhkZzTjConfirm(Map inParams) throws CommonException{
		try{
			if(Tools.processNull(inParams.get("acptId")).equals("")){
				throw new CommonException("受理点编号不能为空！");
			}
			if(Tools.processNull(inParams.get("acptType")).equals("")){
				throw new CommonException("受理点类型不能为空！");
			}
			if(Tools.processNull(inParams.get("userId")).equals("")){
				throw new CommonException("操作员不能为空！");
			}
			if(Tools.processNull(inParams.get("dealNo")).equals("")){
				throw new CommonException("确认流水不能为空！");
			}

			// 更新登记状态
			publicDao.doSql("update bhk_zz_register set state = '1' where deal_no = '" + Tools.processNull(inParams.get("dealNo2")) + "'");

			StringBuffer sb = new StringBuffer();
			sb.append(Tools.processNull(inParams.get("acptId")) + "|");//1.受理点编号/网点编号
			sb.append(Tools.processNull(inParams.get("acptType")) + "|");//2.受理点类型   1 柜面  2 代理
			sb.append(Tools.processNull(inParams.get("userId")) + "|");//3.受理点终端编号/操作员
			sb.append(Tools.processNull(inParams.get("endDealNo")) + "|");//4.终端操作流水 受理点类型为 1的时候可为空
			sb.append(Tools.processNull(inParams.get("dealNo")) + "|");//5.确认流水号
			sb.append(Tools.processNull(this.getClrDate()) + "|");//6.清分日期
			List<String> inParameters = new ArrayList<String>();
			inParameters.add(sb.toString());
			List<Integer> outParameters = new ArrayList<Integer>();
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List<?> outMsg = publicDao.callProc("pk_service_outer.p_bhk_zz_tj_confirm",inParameters,outParameters);
			if(outMsg != null && outMsg.size() > 0){
				if(Integer.valueOf(outMsg.get(0).toString()) != 0){
					throw new CommonException(outMsg.get(1).toString());
				}
			}else{
				throw new CommonException("调取过程出现错误");
			}
			return null;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 补换卡转钱包灰记录冲正
	 * @param oldDealNo 原始流水号
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveBhkZzTjCz(Long oldDealNo) throws CommonException{
		try{
			if(Tools.processNull(oldDealNo).equals("")){
				throw new CommonException("冲正，原始流水不能为空！");
			}
			List<String> inParameters = new ArrayList<String>();
			inParameters.add(oldDealNo + "");
			List<Integer> outParameters = new ArrayList<Integer>();
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List<?> outMsg = publicDao.callProc("pk_service_outer.p_bhkzz_tj_cancel",inParameters,outParameters);
			if(outMsg != null && outMsg.size() > 0){
				if(Integer.valueOf(outMsg.get(0).toString()) != 0){
					throw new CommonException(outMsg.get(1).toString());
				}
			}else{
				throw new CommonException("调取过程出现错误");
			}
			publicDao.doSql("delete from sys_report t where t.deal_no = " + oldDealNo);
			return null;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 卡应用锁定记录灰记录
	 * @param rec   业务日志
	 * @param user  操作员
	 * @param log   操作日志
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveAppLockHjl(TrServRec rec,Users user,SysActionLog log)throws CommonException{
		try{
			//1.基本条件判断
			if(rec == null){
				throw new CommonException("业务日志不能为空！");
			}
			if(Tools.processNull(rec.getCardNo()).equals("")){
				throw new CommonException("卡号不能为空！");
			}
			if(user == null || Tools.processNull(user.getUserId()).equals("")){
				throw new CommonException("操作员不能为空！");
			}
			if(log == null){
				throw new CommonException("操作日志不能为空！");
			}
			//2.记录操作日志
			log.setDealCode(DealCode.CARD_APP_LOCK);
			log.setMessage("卡号应用锁定,卡号" + rec.getCardNo());
			publicDao.save(log);
			//3.业务处理
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + rec.getCardNo() + "'");
			if(card == null){
				throw new CommonException("卡片信息不存在！");
			}
			if(Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_SD)){
				throw new CommonException("卡片已锁定无需重复锁定！");
			}
			/*if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZC)){
				throw new CommonException("卡片状态不正常无法进行锁定！");
			}*/
			BasePersonal bp = new BasePersonal();
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(bp == null){
					bp = new BasePersonal();
				}
			}
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(user.getBrchId());
			rec.setUserId(user.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setDealState(Constants.TR_STATE_HJL);
			rec.setCardAmt(1L);
			rec.setCardType(card.getCardType());
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCustomerName(bp.getName());
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 卡应用锁定灰记录确认
	 * @param rec   业务日志
	 * @param user  操作员
	 * @param log   操作日志
	 * @return
	 */
	public TrServRec saveAppLockHjlConfirm(TrServRec rec,Users user)throws CommonException{
		try{
			if(rec == null || Tools.processNull(rec.getDealNo()).equals("")){
				throw new CommonException("确认锁定流水不能为空！");
			}
			if(user == null || Tools.processNull(user.getUserId()).equals("")){
				throw new CommonException("操作员不能为空！");
			}
			TrServRec oldRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + rec.getDealNo() + " and t.dealState = '" + Constants.TR_STATE_HJL + "'");
			if(oldRec == null){
				throw new CommonException("根据流水" + rec.getDealNo() + "未找到卡片锁定未确认的记录！");
			}
			publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_ZC + "' where t.deal_no = " + rec.getDealNo());
			return oldRec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 卡应用锁定灰记录取消
	 * @param rec   业务日志
	 * @param user  操作员
	 * @param log   操作日志
	 * @return
	 */
	public TrServRec saveAppLockHjlCancel(TrServRec rec,Users user,SysActionLog log)throws CommonException{
		try{
			//1.基本条件判断
			if(rec == null || Tools.processNull(rec.getDealNo()).equals("")){
				throw new CommonException("冲正锁定流水不能为空！");
			}
			if(user == null || Tools.processNull(user.getUserId()).equals("")){
				throw new CommonException("操作员不能为空！！");
			}
			TrServRec oldRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + rec.getDealNo()
					+ " and t.dealState = '" + Constants.TR_STATE_HJL + "'");
			if(oldRec == null){
				throw new CommonException("根据流水" + rec.getDealNo() + "未找到卡片锁定的灰记录！");
			}
			publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CZ + "' where t.deal_no = " + rec.getDealNo());
			return oldRec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 卡片应用解锁
	 * @param rec
	 * @param user
	 * @param log
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveAppUnlockHjl(TrServRec rec,Users user,SysActionLog log)throws CommonException{
		try{
			//1.基本条件判断
			if(rec == null){
				throw new CommonException("业务日志不能为空！");
			}
			if(Tools.processNull(rec.getCardNo()).equals("")){
				throw new CommonException("卡号不能为空！");
			}
			if(user == null || Tools.processNull(user.getUserId()).equals("")){
				throw new CommonException("操作员不能为空！");
			}
			if(log == null){
				throw new CommonException("操作日志不能为空！");
			}
			//2.记录操作日志
			log.setDealCode(DealCode.CARD_APP_UNLOCK);
			log.setMessage("卡号应用解锁,卡号" + rec.getCardNo());
			publicDao.save(log);
			//3.业务处理
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + rec.getCardNo() + "'");
			if(card == null){
				throw new CommonException("卡片信息不存在！");
			}
			if(Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZX)){
				throw new CommonException("卡片已经注销，不能进行应用解锁！");
			}
			BasePersonal bp = new BasePersonal();
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(bp == null){
					bp = new BasePersonal();
				}
			}
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(user.getBrchId());
			rec.setUserId(user.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setDealState(Constants.TR_STATE_HJL);
			rec.setCardAmt(1L);
			rec.setCardType(card.getCardType());
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCustomerName(bp.getName());
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	public TrServRec saveAppUnlockHjlConfirm(TrServRec rec,Users user)throws CommonException{
		try{
			if(rec == null || Tools.processNull(rec.getDealNo()).equals("")){
				throw new CommonException("确认解锁流水不能为空！");
			}
			if(user == null || Tools.processNull(user.getUserId()).equals("")){
				throw new CommonException("操作员不能为空！");
			}
			TrServRec oldRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + rec.getDealNo() + " and t.dealState = '" + Constants.TR_STATE_HJL + "'");
			if(oldRec == null){
				throw new CommonException("根据流水" + rec.getDealNo() + "未找到卡片解锁未确认的记录！");
			}
			publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_ZC + "' where t.deal_no = " + rec.getDealNo());
			return oldRec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	public TrServRec saveAppUnlockHjlCancel(TrServRec rec,Users user,SysActionLog log)throws CommonException{
		try{
			//1.基本条件判断
			if(rec == null || Tools.processNull(rec.getDealNo()).equals("")){
				throw new CommonException("冲正解锁流水不能为空！");
			}
			if(user == null || Tools.processNull(user.getUserId()).equals("")){
				throw new CommonException("操作员不能为空！");
			}
			TrServRec oldRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + rec.getDealNo()
					+ " and t.dealState = '" + Constants.TR_STATE_HJL + "'");
			if(oldRec == null){
				throw new CommonException("根据流水" + rec.getDealNo() + "未找到卡片解锁的灰记录！");
			}
			publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CZ + "' where t.deal_no = " + rec.getDealNo());
			return oldRec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/** 卡黑名单处理的公用方法
	 * @param card      待处理黑名单的卡
	 * @param rec       业务操作日志
	 * @param blk_State 黑名单操作类型 0 新增黑名单, 1减去黑名单
	 * @param blk_Type
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public boolean saveOrUpdateCardBlack(CardBaseinfo card,TrServRec rec,String blkState,String blkType){
		boolean isSaveOk = false;
		try{
			//1.条件判断
			if(!Tools.processNull(blkState).equals("0") && !Tools.processNull(blkState).equals("1")){
				throw new CommonException("黑名单操作类型不正确！ blkState = 0 增加黑名单  blkState = 1 减去黑名单，传入无效值blkState = " + blkState);
			}
			if(card == null || rec == null){
				throw new CommonException("黑名单操作失败，传入无效值。");
			}
			if(Tools.processNull(card.getCardId()).replaceAll(" ","").equals("") || Tools.processNull(card.getCardNo()).replaceAll(" ","").equals("") || Tools.processNull(rec.getBizTime()).replaceAll(" ","").equals("")){
				throw new CommonException("黑名单操作失败，传入无效值。");
			}
			if(blkState.equals("0") && Tools.processNull(blkType).replaceAll(" ","").equals("")){
				throw new CommonException("黑名单操作失败，增加黑名单，传入无效黑名单类型。");
			}
			//2.根据参数判断，是增加黑名单 还是 减去黑名单 blkState = 0 增加黑名单  blkState = 1 减去黑名单
			CardBlack black = (CardBlack) this.findOnlyRowByHql("from CardBlack t where t.cardNo = '" + card.getCardNo() + "' and t.cardId = '" + card.getCardId() + "'");
			if(black == null){
				black = new CardBlack();
				black.setCardId(card.getCardId());
				black.setCardNo(card.getCardNo());
				black.setOrgId(card.getCardNo().substring(0,4));
			}
			black.setBlkType((Tools.processNull(blkState).equals(Constants.BLK_STATE_YX) ? blkType : black.getBlkType()));
			black.setBlkState(blkState);
			black.setLastDate(rec.getBizTime());
			black.setVersion(new Long(super.getSequenceByName("seq_black_vision")));//黑名单操作版本
			publicDao.saveOrUpdate(black);
			//3.记录黑名单明细
			CardBlackRecId cardBlackRecId = new  CardBlackRecId();
			cardBlackRecId.setDealNo(rec.getDealNo());
			cardBlackRecId.setCardId(card.getCardId());
			cardBlackRecId.setCardNo(card.getCardNo());
			CardBlackRec blackrec = new CardBlackRec();
			blackrec.setNotes((Tools.processNull(blkState).equals("0") ? "增加黑名单" : "减去黑名单"));
			blackrec.setVersion(Integer.valueOf(black.getVersion() + ""));
			blackrec.setId(cardBlackRecId);
			publicDao.save(blackrec);
			isSaveOk = true;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
		return isSaveOk;
	}
	/**
	 * 设置挂失、解挂、注销、卡信息重写、余额返现等凭证参数，本类调用
	 * @return
	 */
	private JSONObject reportSetValue(TrServRec tsr)throws CommonException{
		try{
			JSONObject json = new JSONObject();
			String ywlx = "";
			//根据交易代码获取业务操作类型
			if(!Tools.processNull(tsr.getDealCode()).equals("")){
				ywlx = this.findTrCodeNameByCodeType(tsr.getDealCode());
			}
			String dlrzjlx = ""; //代理人证件类型
			if(!Tools.processNull(tsr.getAgtCertType()).equals("")){
				dlrzjlx = this.getCodeNameBySYS_CODE("CERT_TYPE",tsr.getAgtCertType());
			}
			String zjlx = "";   //本人人证件类型
			if(!Tools.processNull(tsr.getCertType()).equals("")){
				zjlx = this.getCodeNameBySYS_CODE("CERT_TYPE",tsr.getCertType());
			}
			json.put("p_Title",Constants.APP_REPORT_TITLE + ywlx + "办理凭证");//挂失、解挂没用到
			json.put("p_Actionno", Tools.processNull(tsr.getDealNo()));//流水
			json.put("p_Print_Time", DateUtil.formatDate(tsr.getBizTime(), "yyyy-MM-dd HH:mm:ss"));//业务办理时间
			json.put("p_Print_Name", Tools.processNull(this.getUser().getAccount()));
			json.put("p_ywlx",ywlx);//业务办理类型  挂失、解挂
			json.put("p_Cardno", Tools.processNull(tsr.getCardNo()));//业务办理的卡号
			json.put("p_Cardtype",this.getCodeNameBySYS_CODE("CARD_TYPE",tsr.getCardType()));//卡类型
			json.put("p_Clientname", Tools.processNull(tsr.getCustomerName()));
			json.put("p_Certtype", Tools.processNull(zjlx));
			json.put("p_Certno", Tools.processNull(tsr.getCertNo()));
			//reportsHashMap.put("p_Subcardno",cardServiceService.getCodeNameBySYS_CODE("CARD_TYPE",tsr.getCardType()));//为空时，表格线不显示，因此写上“无”
			//String subcardno = Tools.processNull(cardServiceService.findOnlyFieldBySql(" select sub_card_no from card_baseInfo where card_no = '"+tsr.getCardNo()+"'"));
			//reportsHashMap.put("p_Trcode", Tools.processNull(ywlx));
			if(!Tools.processNull(tsr.getAgtName()).equals("")){//根据姓名判断如果代理人不为空，办理人为代理人
				json.put("p_Agtname", Tools.processNull(tsr.getAgtName()));
			}else{
				json.put("p_Agtname", Tools.processNull(tsr.getCustomerName()));
			}
			if(!Tools.processNull(dlrzjlx).equals("")){
				json.put("p_Agtcerttype", Tools.processNull(dlrzjlx));
			}else{
				json.put("p_Agtcerttype", Tools.processNull(zjlx));
			}
			if(!Tools.processNull(tsr.getAgtCertNo()).equals("")){
				json.put("p_Agtcertno", Tools.processNull(tsr.getAgtCertNo()));
			}else{
				json.put("p_Agtcertno", Tools.processNull(tsr.getCertNo()));
			}
			if(!Tools.processNull(tsr.getAgtTelNo()).equals("")){
				json.put("p_Agttelno", Tools.processNull(tsr.getAgtTelNo()));
			}else{
				json.put("p_Agttelno", Tools.processNull(tsr.getTelNo()));
			}
			json.put("p_Brchid", Tools.processNull(this.getSysBranchByUserId().getFullName()));
			json.put("p_Biztime", DateUtil.formatDate(tsr.getBizTime(), "yyyy-MM-dd HH:mm:ss"));
			json.put("p_Operid", Tools.processNull(tsr.getUserId()));
			json.put("p_bal_rtn_amt",  Arith.cardreportsmoneydiv(Arith.add(String.valueOf((Tools.processNull(tsr.getRtnFgft()).equals("")?"0":tsr.getRtnFgft())),String.valueOf((Tools.processNull(tsr.getBalRtnAmt()).equals("")?"0":tsr.getBalRtnAmt())))));
			//reportsHashMap.put("p_Title_Logo", ServletActionContext.getServletContext().getRealPath("/")+"/images/reportimage/logo_jx.gif");//logo图
			return json;
		}catch(Exception e){
			throw new CommonException("生成报表数据错误：" + e.getMessage());
		}
	}
	/**
	 * 通过操作日志获得业务日志
	 * @param rec  业务日志
	 * @param log  操作日志
	 * @return
	 */
	public TrServRec getTrServRec(TrServRec rec,SysActionLog log){
		if(rec == null){
			rec = new TrServRec();
		}
		rec.setDealNo(log.getDealNo());
		rec.setDealCode(log.getDealCode());
		rec.setNote(log.getMessage());
		rec.setDealState(Constants.TR_STATE_ZC);//默认正常状态
		rec.setClrDate(this.getClrDate());
		return rec;
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
	 * 去掉后面两位小数保留整数
	 * 陶都通注销退余额
	 */
	public  long getLong(Long mon){
		if(Tools.processNull(mon).equals("") || mon == 0){
			return 0L;
		}
		String temp = Arith.cardmoneydiv(mon + "");
		BigDecimal bg = new BigDecimal(temp);
		bg = bg.setScale(1,BigDecimal.ROUND_HALF_UP);
		long dc = bg.longValue();
		BigDecimal bd = new BigDecimal(Arith.cardmoneymun(dc + ""));
		return bd.longValue();
	}
	public AccAcountService getAccService() {
		return accService;
	}
	public void setAccService(AccAcountService accService) {
		this.accService = accService;
	}
	public ZxcService getZxcService() {
		return zxcService;
	}
	public void setZxcService(ZxcService zxcService) {
		this.zxcService = zxcService;
	}
	@Override
	public void saveundoServPwdorTradePwd(SysActionLog actionLog,String dealType, String certNo, String cardNo)throws CommonException {
		try {
			if(dealType.equals("1")){//服务密码
				actionLog.setMessage("服务密码输入错误次数重置");
				actionLog.setDealCode(DealCode.SERV_PWD_NUM_UNDO_SET);
				publicDao.save(actionLog);
				publicDao.doSql("UPDATE base_personal t SET t.serv_pwd_err_num = 0  WHERE t.cert_no ='"+certNo+"'");
			}else if(dealType.equals("2")){//交易密码
				actionLog.setMessage("交易密码输入错误次数重置");
				actionLog.setDealCode(DealCode.TRADE_PWD_NUM_UNDO_SET);
				publicDao.save(actionLog);
				publicDao.doSql("UPDATE card_baseinfo b SET b.Pay_Pwd_Err_Num = 0 WHERE b.card_no ='"+cardNo+"'");
			}else{
				throw new CommonException("输入的参数错误");
			}
		} catch (Exception e) {
			throw new CommonException("保存密码解锁出错："+e.getMessage());
		}
	}
	/**
	 * 修改卡片有效日期
	 * @param actionLog
	 * @param vdate
	 * @param cardNo
	 * @throws CommonException
	 */
	@Override
	public void saveCardDate(SysActionLog actionLog, String vdate, String cardNo)
			throws CommonException {
		try {
			actionLog.setMessage("修改卡片有效日期");
			actionLog.setDealCode(DealCode.UPDATE_CARDINFO);
			publicDao.save(actionLog);
			publicDao.doSql("UPDATE card_baseinfo t SET t.valid_Date = '"+vdate.replaceAll("-", "")+"',last_Modify_Date=sysdate  WHERE t.card_no ='"+cardNo+"'");
		} catch (Exception e) {
			throw new CommonException("修改卡片有效日期出错："+e.getMessage());
		}

	}
	/**
	 * 公交子类型修改记灰记录
	 * @param tarBusType  目标公交子类型
	 * @param validDate   新的应用有效期
	 * @param card        卡片信息
	 * @param bp          人员信息
	 * @param oper        操作员信息
	 * @param log         操作日志信息
	 * @return            业务日志信息
	 * @throws CommonException
	 */
	public TrServRec saveBusTypeModifyHjl(String tarBusType,String validDate,CardBaseinfo card,BasePersonal bp,Users oper,SysActionLog log) throws CommonException{
		try{
			log.setDealCode(DealCode.CARD_BUS_TYPE_MOD);
			log.setMessage("公交子类型修改,卡号" + card.getCardNo());
			publicDao.save(log);
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage());
			rec.setBrchId(log.getBrchId());
			rec.setUserId(log.getUserId());
			rec.setClrDate(this.getClrDate());
			rec.setOrgId(log.getOrgId());
			rec.setCardId(card.getCardId());
			rec.setCardNo(card.getCardNo());
			rec.setCardAmt(1L);
			rec.setCardType(card.getCardType());
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCustomerName(bp.getName());
			rec.setDealState(Constants.TR_STATE_HJL);
			rec.setCertNo(bp.getCertNo());
			rec.setCertType(bp.getCertType());
			rec.setRsvOne(tarBusType);
			rec.setRsvTwo(validDate);
			rec.setBizTime(log.getDealTime());
			publicDao.save(rec);
			JSONObject report = new JSONObject();
			HashMap<String,String> reportsHashMap = new HashMap<String,String>();
			report.put("p_Title",Constants.APP_REPORT_TITLE + "公交子类型修改办理凭证");
			report.put("p_Action_No",Tools.processNull(rec.getDealNo()));
			report.put("p_Print_Time",Tools.processNull(DateUtil.formatDate(rec.getBizTime(), "yyyy-MM-dd HH:mm:ss")));
			report.put("p_Print_Name",Tools.processNull(oper.getName()));
			report.put("p_Cart_Type",Tools.processNull(rec.getCustomerName()));
			report.put("p_Cart_Name",Tools.processNull(rec.getCardNo()));
			report.put("p_Acpt_Type","公交子类型修改");
			report.put("p_Cart_Duan",this.getCodeNameBySYS_CODE("CARD_TYPE",rec.getCardType()));//卡类型
			report.put("p_Cert_Type",this.getCodeNameBySYS_CODE("CERT_TYPE",rec.getCertType()));//证件类型
			report.put("p_Cert_No", Tools.processNull(rec.getCertNo()));//证件号码
			report.put("p_Task_Id", Tools.processNull(this.getCodeNameBySYS_CODE("BUS_TYPE",card.getBusType())));//原公交类型
			report.put("p_Cart_Num", Tools.processNull(this.getCodeNameBySYS_CODE("BUS_TYPE",tarBusType)));//修改后公交类型
			report.put("p_Acept_Branch",oper.getBrchName());
			report.put("p_Acept_Time",DateUtil.formatDate(rec.getBizTime(), "yyyy-MM-dd HH:mm:ss"));
			report.put("p_Oper_Id",oper.getUserId());
			this.saveSysReport(log,report, "/reportfiles/ZLX.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 公交子类型修改灰记录确认
	 * @param dealNo  原流水
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveBusTypeModifyConfirm(Long dealNo)throws CommonException{
		try{
			if(dealNo == null || Tools.processNull(dealNo).equals("")){
				throw new CommonException("确认流水不能为空！");
			}
			TrServRec oldRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + dealNo +
					" and t.dealState = '" + Constants.TR_STATE_HJL + "'");
			if(oldRec == null){
				throw new CommonException("根据流水" + dealNo + "未找到对应的需要确认的记录信息！");
			}
			int updateCount = publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_ZC + "' where t.deal_no = " + dealNo);
			if(updateCount != 1){
				throw new CommonException("确定业务时，更新业务流水" + updateCount + "条！");
			}
			updateCount = 0;
			updateCount = publicDao.doSql("update card_baseinfo t set t.bus_type = '" + oldRec.getRsvOne() + "',t.app1_valid_date = '" +
					oldRec.getRsvTwo() + "',last_modify_date = to_date('" + DateUtil.formatDate(oldRec.getBizTime(),"yyyy-MM-dd HH:mm:ss") +
					"','yyyy-mm-dd hh24:mi:ss') where card_no = '" + oldRec.getCardNo() + "'" );
			if(updateCount != 1){
				throw new CommonException("确定业务时，更新卡信息" + updateCount + "条！");
			}
			return oldRec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 公交子类型修改灰记录取消
	 * @param dealNo 原流水
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveBusTypeModifyCancel(Long dealNo)throws CommonException{
		try{
			//1.基本条件判断
			if(dealNo == null || Tools.processNull(dealNo).equals("")){
				throw new CommonException("取消原流水不能为空！");
			}
			TrServRec oldRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + dealNo +
					" and t.dealState = '" + Constants.TR_STATE_HJL + "'");
			if(oldRec == null){
				throw new CommonException("根据流水" + dealNo + "未找到对应需要取消的记录信息！");
			}
			int updateCount = publicDao.doSql("update tr_serv_rec t set t.deal_state = '" + Constants.TR_STATE_CZ + "' where t.deal_no = " + dealNo);
			if(updateCount != 1){
				throw new CommonException("取消业务时，更新业务流水" + updateCount + "条！");
			}
			updateCount = 0;
			updateCount = publicDao.doSql("delete from sys_report t where t.deal_no = " + updateCount);
			if(updateCount != 1){
				throw new CommonException("取消业务时，处理报表更新" + updateCount + "条！");
			}
			return oldRec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	@SuppressWarnings({ "unchecked", "rawtypes" })
	@Override
	public void saveConfirmReturnCash(Long dealNo) {
		try {
			if (dealNo == null) {
				throw new CommonException("业务流水为空.");
			}

			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.BALANCE_RESTORE_CONFIRM);
			log.setMessage("余额返还确认, 业务流水" + dealNo);
			publicDao.save(log);

			// 2
			TrServRec rec = (TrServRec) findOnlyRowByHql("from TrServRec where dealNo = " + dealNo);
			if (rec == null) {
				throw new CommonException("余额返现登记信息不存在.");
			} else if (rec.getRsvFive().equals(Constants.YES_NO_YES)) { // 已返还
				throw new CommonException("余额返现登记信息已确认.");
			} else if (rec.getDealState().equals(Constants.TR_STATE_CX)) { // 已撤销
				throw new CommonException("余额返现登记信息已撤销.");
			}
			rec.setRsvFive(Constants.YES_NO_YES); // 已返还

			//3.返还账户
			List<AccAccountSub> allAccs = this.findByHql("from AccAccountSub t where t.cardNo = '" + rec.getCardNo() + "' and t.balRslt = '0'");
			if (allAccs == null) {
				throw new CommonException("该卡不存在未返还的账户！");
			}
			Long inTotalAmt = 0l;
			for(AccAccountSub accAccountSub : allAccs) {
				//更改账户余额处理结果
				publicDao.doSql("update ACC_ACCOUNT_SUB t set t.bal_rslt = '1'  where t.card_no = '" + rec.getCardNo() + "' and t.acc_kind = '" + accAccountSub.getAccKind() + "'");

				if(accAccountSub.getBal() <= 0){
					continue;
				}

				HashMap hm = new HashMap();
				hm.put("acpt_id",log.getBrchId());
				hm.put("oper_id",log.getUserId());
				hm.put("tr_batch_no", null);
				hm.put("term_tr_no", null);
				hm.put("card_no", rec.getCardNo());
				hm.put("card_tr_count1", null);
				hm.put("card_bal", null);
				hm.put("acc_kind",accAccountSub.getAccKind());
				hm.put("wallet_id","00");
				long temoFrzAmt = 0L;
				if(accAccountSub.getFrzAmt() == null){
					temoFrzAmt = 0L;
				} else {
					temoFrzAmt = accAccountSub.getFrzAmt();
				}

				if (Tools.processNull(accAccountSub.getAccKind()).equals(Constants.ACC_KIND_QBZH)) { // 钱包
					if (Tools.processNull(rec.getRsvOne()).equals("0")) { // 好卡
						hm.put("tr_amt", rec.getPrvBal() - temoFrzAmt); // 卡面 - 冻结
						inTotalAmt += rec.getPrvBal() - temoFrzAmt;
					} else if (Tools.processNull(rec.getRsvOne()).equals("1")) { // 坏卡
						hm.put("tr_amt", accAccountSub.getBal() - temoFrzAmt); //账户余额 - 冻结
						inTotalAmt += accAccountSub.getBal() - temoFrzAmt;
					} else if (Tools.processNull(rec.getRsvOne()).equals("2")) { // 无卡
						hm.put("tr_amt", 0l);
					}
				} else { // 非钱包
					hm.put("tr_amt", accAccountSub.getBal() - temoFrzAmt);
					inTotalAmt += accAccountSub.getBal() - temoFrzAmt;
				}
				hm.put("acpt_type",Constants.ACPT_TYPE_GM);

				accService.returnCash(log, hm);
			}

			// 验证金额
			if (!inTotalAmt.equals(rec.getAmt())) {
				throw new CommonException("余额返现登记金额与计算金额不一致.");
			}

			// 业务日志
			TrServRec newRec = new TrServRec();
			newRec.setDealNo(log.getDealNo());
			newRec.setDealCode(log.getDealCode());
			newRec.setOldDealNo(rec.getDealNo());
			newRec.setBizTime(log.getDealTime());
			newRec.setBrchId(log.getBrchId());
			newRec.setUserId(log.getUserId());
			newRec.setCustomerId(rec.getCustomerId());
			newRec.setCustomerName(rec.getCustomerName());
			newRec.setClrDate(this.getClrDate());
			newRec.setCardId(rec.getCardId());
			newRec.setCardNo(rec.getCardNo());
			newRec.setAmt(rec.getAmt());
			newRec.setCardType(rec.getCardType());
			newRec.setCertNo(rec.getCertNo());
			newRec.setCertType(rec.getCertType());
			newRec.setDealState(Constants.TR_STATE_ZC);
			newRec.setNote(log.getMessage());

			publicDao.save(newRec);
		} catch (Exception e) {
			throw new CommonException("余额返现确认失败.", e);
		}
	}
	@SuppressWarnings("unchecked")
	@Override
	public void saveAccQcLimitInfo(final AccQcqfLimit limit, SysActionLog log) {
		try {
			log.setDealCode(DealCode.ACC_QCQF_LIMIT_SET);
			log.setMessage("圈存限额设置，卡号：" + limit.getCardNo() + "，圈存限额：" + limit.getQcLimitAmt());
			publicDao.save(log);
			// 卡片信息
			CardBaseinfo cardInfo = null;
			if (limit.getCardNo().length() == 9) {
				cardInfo = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where subCardNo = '" + limit.getCardNo() + "' and cardState = '" + Constants.CARD_STATE_ZC + "'");
			} else if (limit.getCardNo().length() == 20) {
				cardInfo = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where cardNo = '" + limit.getCardNo() + "'");
			}
			if (cardInfo == null) {
				throw new CommonException("卡片信息不存在！");
			} else if (!Constants.CARD_STATE_ZC.equals(cardInfo.getCardState())){
				throw new CommonException("卡片状态不正常！");
			}
			// 人员信息
			BasePersonal person = (BasePersonal) findOnlyRowByHql("from BasePersonal where customerId = '" + cardInfo.getCustomerId() + "'");
			if (person == null) {
				throw new CommonException("人员信息不存在！");
			}
			// 银行卡信息
			String bankId, bankCardNo = "";
			if(Constants.CARD_TYPE_QGN.equals(cardInfo.getCardType())){
				CardBindBankCard bindInfo = (CardBindBankCard) findOnlyRowByHql("from CardBindBankCard where id.certNo = '" + person.getCertNo() + "' and id.subCardNo = '" + cardInfo.getSubCardNo() + "'");
				if (bindInfo == null) {
					throw new CommonException("卡片未绑定银行卡！");
				}
				bankId = bindInfo.getBankId();
				bankCardNo = bindInfo.getBankCardNo();
			} else {
				if (Tools.processNull(cardInfo.getBankId()).equals("")) {
					throw new CommonException("卡片所属银行为空！");
				} else if (Tools.processNull(cardInfo.getBankCardNo()).equals("")) {
					throw new CommonException("卡片银行卡号为空！");
				}
				bankId = cardInfo.getBankId();
				bankCardNo = cardInfo.getBankCardNo();
			}
			// 圈存限额信息
			CardConfig config = (CardConfig) findOnlyRowByHql("from CardConfig where cardType = '" + cardInfo.getCardType() + "'");
			AccQcqfLimit limit2 = (AccQcqfLimit) findOnlyRowByHql("from AccQcqfLimit where cardNo = '"
					+ cardInfo.getCardNo() + "' or subCardNo = '" + cardInfo.getSubCardNo() + "'");
			if (limit2 != null) {
				limit.setCardNo(cardInfo.getCardNo());
				limit2.setState(Constants.STATE_ZC);
				limit2.setQcLimitAmt(limit.getQcLimitAmt());
				limit2.setQtLimitAmt(config.getBankRechgQtLmtMax());
				limit2.setQfLimitAmt(limit.getQcLimitAmt());
				limit2.setSetDate(log.getDealTime());
				limit2.setOrgId(log.getOrgId());
				limit2.setBrchId(log.getBrchId());
				limit2.setUserId(log.getUserId());
				limit2.setDealNo(log.getDealNo());
				limit2.setState(Constants.STATE_ZC);
				limit2.setNote(log.getMessage());
				limit2.setIsSetLimit("0");
				publicDao.update(limit2);
			} else {
				limit.setCardNo(cardInfo.getCardNo());
				limit.setCardType(cardInfo.getCardType());
				limit.setSubCardNo(cardInfo.getSubCardNo());
				limit.setAccKind(Constants.ACC_KIND_ZJZH);
				limit.setQcLimitAmt(limit.getQcLimitAmt());
				limit.setQtLimitAmt(config.getBankRechgQtLmtMax());
				limit.setQfLimitAmt(limit.getQcLimitAmt());
				limit.setSetDate(log.getDealTime());
				limit.setOrgId(log.getOrgId());
				limit.setBrchId(log.getBrchId());
				limit.setUserId(log.getUserId());
				limit.setDealNo(log.getDealNo());
				limit.setState(Constants.STATE_ZC);
				limit.setNote(log.getMessage());
				limit.setIsSetLimit("0");
				publicDao.save(limit);
			}
			// 业务日志
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(getClrDate());
			rec.setCardNo(cardInfo.getCardNo());
			rec.setCertType(person.getCertType());
			rec.setCertNo(person.getCertNo());
			rec.setCardType(cardInfo.getCardType());
			rec.setCustomerId(person.getCustomerId().toString());
			rec.setCustomerName(person.getName());
			// 调前置接口
			JSONArray list = new JSONArray();
			JSONObject params = new JSONObject();
			params.put(WS_FIELD_TRCODE, WS_ID_ACC_QCQF_LIMIT_SET);
			params.put(WS_FIELD_BANK_ID, bankId);
			params.put(WS_FIELD_USER_ID, log.getUserId());// 操作员(柜员)
			params.put(WS_FIELD_TERM_NO, log.getDealNo());// 终端业务流水
			params.put(WS_FIELD_SUB_CARD_NO, cardInfo.getSubCardNo());// 市民卡卡号(9位)
			params.put(WS_FIELD_AMT, limit.getQcLimitAmt());// 市民卡卡号(9位)
			params.put(WS_FIELD_CERT_NO, person.getCertNo());// 身份证
			params.put(WS_FIELD_NAME, person.getName());// 姓名
			params.put(WS_FIELD_BANK_CARD_NO, bankCardNo);// 银行卡号
			params.put(WS_FIELD_DATE, DateUtil.formatDate(log.getDealTime(), WS_DATE_FORMAT));// 交易日期
			params.put(WS_FIELD_TIME, DateUtil.formatDate(log.getDealTime(), WS_TIME_FORMAT));// 交易时间
			list.add(params);
			JSONArray returnList = doWorkService.invoke(list);
			// 失败则抛出异常
			if (returnList == null || returnList.isEmpty()) {
				throw new CommonException("前置接口返回为空。");
			}
			JSONObject returns = returnList.getJSONObject(0);
			String errCode = returns.getString("errcode");
			if (!Tools.processNull(errCode).equals("00")) {
				String errMesg = returns.getString("errmessage");
				throw new CommonException("调用前置接口返回失败，详细信息：" + errMesg);
			}
			String bankTradeNo = returns.getString("banktradeno");
			if(bankTradeNo != null){
				rec.setRsvOne(bankTradeNo);
			}
			publicDao.save(rec);
		} catch (Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	@SuppressWarnings("unchecked")
	@Override
	public void saveBhkzzRegister(String cardNo, SysActionLog log) {
		try {
			if (Tools.processNull(cardNo).equals("")) {
				throw new CommonException("卡号不能为空！");
			}
			log.setDealCode(DealCode.BHK_QB_ZZ_DJ);
			log.setMessage("换卡转钱包登记（坏卡），卡号：" + cardNo);
			publicDao.save(log);

			// 卡信息
			CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where cardNo = '" + cardNo + "'");
			if (card == null) {
				throw new CommonException("卡片不存在！");
			} else if (!card.getCardState().equals(Constants.CARD_STATE_ZX)){
				throw new CommonException("卡片不是已注销状态！");
			}

			// 申领信息判断老卡是否是 换卡 or 换发
			Object hkApply = findOnlyFieldBySql("select 1 from card_apply where customer_id = '" + card.getCustomerId()
					+ "' and old_card_no = '" + cardNo + "'  and apply_type = '" + Constants.APPLY_TYPE_HK + "'");
			if (hkApply == null) {
				hkApply = findOnlyFieldBySql("select 1 from tr_serv_rec where card_no = '" + cardNo + "' and deal_code = '" + DealCode.ISSUSE_OLD_ZZ_NEW + "'");
				if (hkApply == null) {
					throw new CommonException("卡片不是换卡/换发注销，不能进行换卡转钱包登记！");
				}
			}

			// 钱包账户信息
			AccAccountSub qb = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where cardNo = '" + cardNo + "' and accKind = '" + Constants.ACC_KIND_QBZH + "'");
			if(qb == null){
				throw new CommonException("钱包账户不存在！");
			} else if(qb.getBal() == 0){
				throw new CommonException("钱包账户余额为0！");
			} else if(!qb.getBalRslt().equals("0")){
				throw new CommonException("钱包账户余额处理状态为【已处理】，不能登记！");
			}

			// 保存登记信息
			BhkZzRegister register = new BhkZzRegister(cardNo, log.getDealTime(), log.getOrgId(), log.getBrchId(), log.getUserId(), log.getDealNo(), "0");
			publicDao.save(register);

			// 业务日志
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(getClrDate());
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setCustomerId(card.getCustomerId());
			rec.setAccKind(qb.getAccKind());
			rec.setAccNo(qb.getAccNo().toString());
			rec.setPrvBal(qb.getBal());
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	@SuppressWarnings({ "unchecked", "rawtypes" })
	@Override
	public TrServRec saveBhkZzBadCardHjl(TrServRec rec, Users oper) {
		try{
			// 获取登记信息
			BhkZzRegister register = (BhkZzRegister) findOnlyRowByHql("from BhkZzRegister where cardNo = '" + rec.getOldCardNo() + "'");
			if(register == null){
				throw new CommonException("卡片未登记，请先登记，并在 7 天后再进行转钱包操作！");
			} else if(register.getState().equals("1")){
				throw new CommonException("余额已返还，不能重复返还！");
			}
			Date now = new Date();
			Calendar backCal = Calendar.getInstance();
			backCal.setTime(register.getRegisterDate());
			backCal.add(Calendar.DAY_OF_YEAR, 7);
			backCal.set(Calendar.HOUR, 0);
			backCal.set(Calendar.MINUTE, 0);
			backCal.set(Calendar.SECOND, 0);
			Date backDate = backCal.getTime();
			if (backDate.compareTo(now) > 0) {
				throw new CommonException("未到返还日期，请在 7 天后再进行转钱包操作！");
			}
			// 验证卡片信息
			validCard(rec.getCardNo(), true);

			// 调存储过程
			StringBuffer sb = new StringBuffer();
			sb.append(oper.getBrchId() + "|");// 1.网点编号
			sb.append(Constants.ACPT_TYPE_GM + "|");// 2.受理点类型
			sb.append(oper.getUserId() + "|");// 3.柜员编号/终端编号
			sb.append("|");// 4.终端流水
			sb.append("|");// 5.批次号
			sb.append(rec.getCardNo() + "|");// 6.新卡卡号
			sb.append(rec.getPrvBal() + "|");// 7.新卡交易前金额
			sb.append(rec.getCardTrCount() + "|");// 8.新卡交易序列号
			sb.append(rec.getOldCardNo() + "|");// 9.老卡卡号
			sb.append("|");// 10.补换卡转账金额 单位：分  为空则全部转
			sb.append(Tools.processNull(rec.getAgtCertType()) + "|");// 11.代理人证件类型
			sb.append(Tools.processNull(rec.getAgtCertNo()) + "|");// 12.代理人证件号码
			sb.append(Tools.processNull(rec.getAgtName()) + "|");// 13.代理人姓名
			sb.append(Tools.processNull(rec.getAgtTelNo()) + "|");// 14.代理人联系方式
			List<String> inParameters = new ArrayList<String>();
			inParameters.add(sb.toString());
			List<Integer> outParameters = new ArrayList<Integer>();
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List outMsg = publicDao.callProc("pk_service_outer.p_bhk_zz_tj2",inParameters,outParameters);
			if(outMsg != null && outMsg.size() > 0){
				if(Integer.valueOf(outMsg.get(1).toString()) != 0){
					throw new CommonException(outMsg.get(2).toString());
				}
				String return_string = outMsg.get(0).toString();
				rec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + return_string.split("\\|")[0]);
			}else{
				throw new CommonException("调取过程出现错误");
			}

			// 凭证
			JSONObject report = new JSONObject();
			report.put("p_Title",Constants.APP_REPORT_TITLE + findTrCodeNameByCodeType(rec.getDealCode()) + "凭证");
			report.put("yewuleixing", findTrCodeNameByCodeType(rec.getDealCode()));
			report.put("p_DealNo",rec.getDealNo());
			report.put("p_CardNo1",rec.getOldCardNo());
			String certNo1 = (String) findOnlyFieldBySql("select cert_no from base_personal where customer_id = '" + rec.getCustomerId() + "'");
			report.put("p_CertNo1",certNo1 );
			report.put("p_CustomerName1",rec.getCustomerName());
			report.put("p_Brch",getSessionSysBranch().getFullName());
			report.put("p_CardNo2",rec.getCardNo());
			report.put("p_CustomerName2",rec.getCustomerName());
			report.put("p_PrintTime",DateUtil.formatDate(rec.getBizTime(),"yyyy-MM-dd HH:mm:ss"));
			report.put("p_DbBalance","0");
			report.put("p_CrBalance",Arith.cardreportsmoneydiv(Arith.add(rec.getPrvBal() + "",rec.getAmt() + "")));
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
	@SuppressWarnings("unchecked")
	@Override
	public void saveCancelReturnCash(Long dealNo) {
		try {
			if (dealNo == null) {
				throw new CommonException("业务流水为空.");
			}
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.BALANCE_RESTORE_CANCEL);
			log.setMessage("余额返还撤销, 业务流水" + dealNo);
			publicDao.save(log);

			// 2
			TrServRec rec = (TrServRec) findOnlyRowByHql("from TrServRec where dealNo = " + dealNo);
			if (rec == null) {
				throw new CommonException("余额返现登记信息不存在.");
			} else if (rec.getRsvFive().equals(Constants.YES_NO_YES)) { // 已返还
				throw new CommonException("余额返现登记信息已确认.");
			} else if (rec.getDealState().equals(Constants.TR_STATE_CX)) { // 已撤销
				throw new CommonException("余额返现登记信息已撤销.");
			}

			//3.撤销
			rec.setDealState(Constants.TR_STATE_CX);

			// 业务日志
			TrServRec newRec = new TrServRec();
			newRec.setDealNo(log.getDealNo());
			newRec.setDealCode(log.getDealCode());
			newRec.setOldDealNo(rec.getDealNo());
			newRec.setBizTime(log.getDealTime());
			newRec.setBrchId(log.getBrchId());
			newRec.setUserId(log.getUserId());
			newRec.setCustomerId(rec.getCustomerId());
			newRec.setCustomerName(rec.getCustomerName());
			newRec.setClrDate(this.getClrDate());
			newRec.setCardId(rec.getCardId());
			newRec.setCardNo(rec.getCardNo());
			newRec.setAmt(rec.getAmt());
			newRec.setCardType(rec.getCardType());
			newRec.setCertNo(rec.getCertNo());
			newRec.setCertType(rec.getCertType());
			newRec.setDealState(Constants.TR_STATE_ZC);
			newRec.setNote(log.getMessage());
			publicDao.save(newRec);
		} catch (Exception e) {
			throw new CommonException("余额返现确认失败.", e);
		}
	}

	/**
	 * 保存非个性化卡销售
	 * @param inpara
	 * saleCardNo 销售卡号
	 * saleCostFee 销售工本费
	 * saleForegiftfee 销售押金
	 * saleManager 客户经理
	 * corpId 销售单位编号
	 * corpName 销售单位名称
	 * note 备注
	 * @param log
	 * @param oper
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveFjmkSell(Map inpara,TrServRec rec,SysActionLog log,Users oper) throws CommonException{
		try{
			if(inpara == null || inpara.isEmpty()){
				throw new CommonException("销售参数信息不正确！");
			}
			if(log == null){
				log = this.getCurrentActionLog();
			}
			if(oper == null){
				oper = this.getUser();
			}
			String saleCardNo = (String) inpara.get("saleCardNo");
			String saleCostFee = (String) inpara.get("saleCostFee");
			String saleForegiftfee = (String) inpara.get("saleForegiftfee");
			if(Tools.processNull(saleCardNo).equals("")){
				throw new CommonException("销售卡号不正确！");
			}
			if(Tools.processNull(saleCostFee).equals("")){
				throw new CommonException("销售工本费不正确!");
			}
			if(Tools.processNull(saleForegiftfee).equals("")){
				throw new CommonException("销售押金不正确!");
			}
			CardFjmkSaleList list = (CardFjmkSaleList) this.findOnlyRowByHql("from CardFjmkSaleList t where t.cardNo = '" + saleCardNo + "'");
			if(list == null){
				throw new CommonException("根据卡号" + saleCardNo + "找不到非个性化卡信息！");
			}
			if(!Tools.processNull(list.getSaleState()).equals(Constants.SALE_STATE.WXS)){
				throw new CommonException("根据销售卡号" + saleCardNo + "找到的非个性化卡信息不是未销售状态！");
			}
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + list.getCardNo() + "'");
			if(card != null){
				throw new CommonException("卡号：" + saleCardNo + "，在卡信息表中已存在！");
			}
			CardConfig config = (CardConfig) this.findOnlyRowByHql("from CardConfig t where t.cardType = '" + list.getCardType() + "'");
			if(config == null){
				throw new CommonException("卡类型：" + list.getCardType() + "，卡参数信息未设置！");
			}
			if(Tools.processNull(config.getCardValidityPeriod()).equals("")){
				throw new CommonException("卡类型：" + list.getCardType() + "，卡有效期参数信息未设置！");
			}
			List inpatameters = new ArrayList();
			List outparameters = new ArrayList();
			StringBuffer sb =  new StringBuffer();
			sb.append(Tools.processNull(oper.getBrchId()) + "|");
			sb.append(Tools.processNull(Constants.ACPT_TYPE_GM) + "|");
			sb.append(Tools.processNull(oper.getUserId()) + "|");
			sb.append(Tools.processNull("") + "|");
			sb.append(Tools.processNull(list.getCardNo()) + "|");
			sb.append(Tools.processNull(saleCostFee) + "|");
			sb.append(Tools.processNull(saleForegiftfee) + "|");
			sb.append(Tools.processNull(rec.getCertNo()) + "|");
			sb.append(Tools.processNull(rec.getCustomerName()) + "|");
			sb.append(Tools.processNull(inpara.get("saleManager")) + "|");
			sb.append(Tools.processNull(inpara.get("corpId")) + "|");
			sb.append(Tools.processNull(inpara.get("corpName")) + "|");
			sb.append(Tools.processNull(rec.getAgtCertType()) + "|");
			sb.append(Tools.processNull(rec.getAgtCertNo()) + "|");
			sb.append(Tools.processNull(rec.getAgtName()) + "|");
			sb.append(Tools.processNull(rec.getAgtTelNo()) + "|");
			sb.append(Tools.processNull(inpara.get("note")) + "|");
			inpatameters.add(sb.toString());
			outparameters.add(0,Types.VARCHAR);
			outparameters.add(1,Types.VARCHAR);
			outparameters.add(2,Types.VARCHAR);
			List outMsg = publicDao.callProc("pk_card_apply_issuse.p_fjmk_sell",inpatameters,outparameters);
			if(outMsg != null && outMsg.size() > 0){
				if(Integer.valueOf(outMsg.get(0).toString()) != 0){
					throw new CommonException(outMsg.get(1).toString() + "！");
				}
				String dealNo = outMsg.get(2).toString();
				rec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + dealNo);
				log.setDealCode(rec.getDealCode());
				log.setDealTime(rec.getBizTime());
				log.setDealNo(rec.getDealNo());
			}else{
				throw new CommonException("调取过程出现错误");
			}
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE,ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE,"工本费：￥" + Arith.cardreportsmoneydiv(Tools.processNull(rec.getCostFee())) + " / 押金：￥" + Arith.cardreportsmoneydiv(Tools.processNull(rec.getRtnFgft()).equals("") ? "0" : rec.getRtnFgft() + ""));
			json.put(ReceiptContants.FIELD.CARD_NO,list.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.CARD_TYPE, getCodeNameBySYS_CODE("CARD_TYPE",rec.getCardType())); // 卡号类型
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME,rec.getCustomerName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE",rec.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO,rec.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, rec.getAgtName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getAgtCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, rec.getAgtCertNo()); // 代理人证件号码
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点地址
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_TELEPHONE, getSysBranchByUserId().getTel()); // 受理网点电话
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID,oper.getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME,oper.getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.DEAL_FEE_TYPE,"工本费");//交易费用类型
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			json.put(ReceiptContants.FIELD.AGENT_PHONE_NO, Tools.processNull(rec.getAgtTelNo())); // 代理人联系电话
			this.saveSysReport(log,json,ReceiptContants.TYPE.COMMON, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Override
	public TrServRec saveFjmkHk(TrServRec rec, Users user, SysActionLog log) {
		try {
			if(rec == null){
				throw new CommonException("业务日志为空！");
			} else if(Tools.processNull(rec.getCardNo()).equals("")){
				throw new CommonException("新卡卡号为空！");
			} else if(Tools.processNull(rec.getOldCardNo()).equals("")){
				throw new CommonException("老卡卡号为空！");
			}
			//
			CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("select c from CardBaseinfo c where cardNo = '" + rec.getOldCardNo() + "'");
			if (card == null) {
				throw new CommonException("老卡片信息不存在！");
			} else if (!card.getCardState().equals(Constants.CARD_STATE_ZC)) {
				throw new CommonException("老卡片状态不正常！");
			}
			CardFjmkSaleList list = (CardFjmkSaleList) this.findOnlyRowByHql("from CardFjmkSaleList t where t.cardNo = '" + rec.getCardNo() + "'");
			if(list == null){
				throw new CommonException("根据卡号" + rec.getCardNo() + "找不到非个性化卡信息！");
			} else if(!Tools.processNull(list.getSaleState()).equals(Constants.SALE_STATE.WXS)){
				throw new CommonException("根据销售卡号" + rec.getCardNo() + "找到的非个性化卡信息不是未销售状态！");
			}
			BasePersonal person = (BasePersonal) findOnlyRowByHql("select t from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
			if(person == null){
				throw new CommonException("未找到卡片持卡人信息！");
			}
			//
			//2.业务处理,定义请求参数
			StringBuffer sb = new StringBuffer();
			sb.append(Tools.processNull(user.getBrchId())).append("|");
			sb.append(Constants.ACPT_TYPE_GM + "|");// 2.受理点类型
			sb.append(Tools.processNull(user.getUserId())).append("|");// 3.柜员号
			sb.append("").append("|");// 4.流水
			sb.append(Tools.processNull(rec.getOldCardNo())).append("|");// 5.老卡号
			sb.append(Tools.processNull(rec.getCardNo())).append("|");// 6.新卡号
			sb.append(Tools.processNull(person.getName())).append("|");// 7.姓名
			sb.append(Tools.processNull(person.getCertType())).append("|");// 8.证件类型
			sb.append(Tools.processNull(person.getCertNo())).append("|");// 9.证件号码
			sb.append(Tools.processNull(rec.getRsvOne())).append("|");// 10.0好卡1坏卡
			sb.append(Tools.processNull(rec.getPrvBal())).append("|");// 11.卡面金额
			sb.append(Tools.processNull("0")).append("|");// 12 回收标志,回收：0 未回收：1
			sb.append(Tools.processNull("1")).append("|");// 13.补换卡标志
			sb.append(Tools.processNull(rec.getChgCardReason())).append("|");// 14.换卡原因
			sb.append(Tools.processNull(rec.getAmt())).append("|");// 15.工本费
			sb.append("0").append("|");// 16.换卡维护费
			sb.append(Tools.processNull(rec.getAgtCertType())).append("|");// 17.代理人证件类型
			sb.append(Tools.processNull(rec.getAgtCertNo())).append("|");// 18.代理人证件类型
			sb.append(Tools.processNull(rec.getAgtName())).append("|");// 19.代理人证件类型
			sb.append(Tools.processNull(rec.getAgtTelNo())).append("|");// 20.代理人证件类型
			sb.append("单芯片卡换卡，老卡卡号：" + rec.getOldCardNo() + "，新卡卡号：" + rec.getCardNo()).append("|");// 21.备注
			//
			List<String> inParamList = new ArrayList<String>();
			inParamList.add(sb.toString());
			List outParamList = new ArrayList();
			outParamList.add(java.sql.Types.VARCHAR);
			outParamList.add(java.sql.Types.VARCHAR);
			outParamList.add(java.sql.Types.VARCHAR);
			List res = publicDao.callProc("pk_card_apply_issuse.p_fjmkcardtrans", inParamList, outParamList);
			String outString = "";
			if (res != null && res.size() > 0) {
				if (Integer.parseInt(res.get(0).toString()) != 0) {
					throw new CommonException(res.get(1).toString());
				} else {
					outString = res.get(2).toString();
				}
			} else {
				throw new CommonException("调取过程返回为空！");
			}
			//3.更新业务日志信息
			String[] pa = outString.split("\\|");
			TrServRec oldRec = (TrServRec) findOnlyRowByHql("from TrServRec t where t.dealNo = '" + pa[pa.length - 1] + "'");
			if (oldRec == null) {
				throw new CommonException("找不到业务日志信息！");
			}
			//4.保存报表信
			SysActionLog actionLog = (SysActionLog) findOnlyRowByHql("from SysActionLog t where t.dealNo = " + oldRec.getDealNo());
			if (actionLog == null) {
				throw new CommonException("生成报表错误，找不到操作日志信息！");
			}
			//保存业务凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, actionLog.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(actionLog.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "工本费：￥" + Arith.cardreportsmoneydiv(Tools.processNull(oldRec.getCostFee())));
			json.put(ReceiptContants.FIELD.CARD_NO, oldRec.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, person.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, person.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, oldRec.getAgtName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", oldRec.getAgtCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, oldRec.getAgtCertNo()); // 代理人证件号码
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			json.put("p_OldCardState", "1".equals(rec.getRsvOne())?"坏卡":"好卡");
			this.saveSysReport(actionLog, json, "/reportfiles/BHkReceipt.jasper", Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			return oldRec;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}

	/**
	 * 应用开通与终止记录灰记录（开通与终止需写卡类应用）
	 * @param inpara 应用开通参数信息
	 * @param oper 操作员信息
	 * @param rec 业务日志信息
	 * @param log 操作日志信息
	 * @return 业务日志信息
	 * @others appType 暂定  01 广电，02 自来水，03 电力，04 过路过桥，05 自行车，06 移动，07 公园年卡，08 积分宝，09 新自行车
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveCardAppOpenOrCloseHjl(Map<String,String> inpara, Users oper, TrServRec rec,SysActionLog log) throws CommonException{
		try {
			//1.基本参数和操作类型判断
			String operString = "";
			if(log == null){
				log = this.getCurrentActionLog();
			}
			if(inpara == null || inpara.isEmpty()){
				throw new CommonException("参数信息不能为空！");
			}
			String cardNo = Tools.processNull(inpara.get("cardNo"));
			String appType = Tools.processNull(inpara.get("appType"));
			String operType = Tools.processNull(inpara.get("operType"));
			long fee = Tools.processLong(inpara.get("fee"));
			if(Tools.processNull(operType).equals("0")){
				operString = "卡应用开通";
			}else if(Tools.processNull(operType).equals("1")){
				operString = "卡应用取消";
			}else{
				throw new CommonException("应用操作类型不正确！");
			}
			if(Tools.processNull(cardNo).equals("")){
				throw new CommonException(operString + "，卡号不能为空！");
			}
			if(Tools.processNull(appType).equals("")){
				throw new CommonException(operString + "，类型不能为空！");
			}
			CardBaseinfo card = (CardBaseinfo)this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
			if(card == null){
				throw new CommonException("根据卡号" + cardNo + "找不到卡片信息,无法进行应用" + operString + "操作！");
			}
			//2.开通时判断卡状态,取消时不进行判断
			if(Tools.processNull(operType).equals("0")){
				if(fee < 0){
					throw new CommonException(operString + "，费用不能为空！");
				}
				if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZC)){
					throw new CommonException("卡状态不正确不能进行" + operString + "！");
				}
			}
			//3.持卡人信息判断
			if(Tools.processNull(card.getCustomerId()).equals("")){
				throw new CommonException("卡片持卡人信息不存在！");
			}
			BasePersonal person = (BasePersonal)this.findOnlyRowByHql("from BasePersonal b where b.customerId = '" + card.getCustomerId() + "'");
			if(person == null){
				throw new CommonException("卡片持卡人信息不存在！");
			}
			//4.应用信息判断
			BigDecimal isHasOpened = (BigDecimal) this.findOnlyFieldBySql("select count(1) from card_app_open t where t.card_no = '" + card.getCardNo() + "' and t.app_type = '" + rec.getRsvTwo() + "' and t.state = '0'");
			if(Tools.processNull(operType).equals("0")){
				if(isHasOpened.intValue() != 0){
					throw new CommonException("该卡已开通当前应用！");
				}
				BigDecimal qbAccAmt = (BigDecimal) this.findOnlyFieldBySql("select (nvl(t.bal,0) - nvl(t.frz_amt,0)) from acc_account_sub t where t.card_no = '" +
						card.getCardNo() + "' and t.acc_kind = '" + Constants.ACC_KIND_QBZH + "' and t.wallet_no = '00'");
				if(qbAccAmt == null){
					throw new CommonException("账户信息不存在！");
				}
				if((qbAccAmt.longValue() - fee) < 0){
					throw new CommonException("账户余额不足！");
				}
			}else if(Tools.processNull(operType).equals("1")){
				if(isHasOpened.intValue() == 0){
					throw new CommonException("该卡未开通当前应用，无需进行应用终止！");
				}
			}else{
				throw new CommonException("应用操作类型不正确！");
			}
			//5.记录操作日志信息
			if(Tools.processNull(operType).equals("0")){
				log.setDealCode(DealCode.ZXC_APP_OPEN);//应用开通交易代码
			}else if(Tools.processNull(operType).equals("1")){
				log.setDealCode(DealCode.ZXC_APP_CANCEL);//应用终止交易代码
			}else{
				throw new CommonException("应用操作类型不正确！");
			}
			log.setMessage(operString + "，卡号" + card.getCardNo() + ",类型" + appType);
			publicDao.save(log);
			//6.特定应用开通处理
			String writeCardData = "";
			if(Tools.processNull(operType).equals("0")){
				if(Tools.processNull(appType).equals("09")){
					String camt = String.format("%010d",fee);
					String ctime = DateUtil.formatDate(log.getDealTime(),"yyyyMMddHHmmss");
            		/*00  未开通租车功能 01  已租车02  开通租车功能04  已还车08  欠费还车*/
					String tempDealType = "02";
					String tempReginCode = "03";
					String yjFlag = "";
            		/*00 押金200元01 押金 100元02 押金  0元03 押金 300元FF  业务注销 （无押金）*/
					if(Tools.processNull(rec.getAmt()).equals("20000")){
						yjFlag = "00";
					}else if(Tools.processNull(rec.getAmt()).equals("10000")){
						yjFlag = "01";
					}else if(Tools.processNull(rec.getAmt()).equals("0")){
						yjFlag = "02";
					}else if(Tools.processNull(rec.getAmt()).equals("30000")){
						yjFlag = "03";
					}else{
						throw new CommonException("押金标志不正确！");
					}
					writeCardData = camt + ctime + tempDealType + tempReginCode + yjFlag;
				}else{
					throw new CommonException("未处理的开通写卡应用类型！");
				}
			}else if(Tools.processNull(operType).equals("1")){
				if(Tools.processNull(appType).equals("09")){
					String tempDealType = "00";
					String tempReginCode = "03";
					String yjFlag = "FF";
					writeCardData = tempDealType + tempReginCode + yjFlag;
				}else{
					throw new CommonException("未处理的终止写卡应用类型！");
				}
			}else{
				throw new CommonException("操作类型不正确！");
			}
			rec.setRsvFour(writeCardData);//写卡的串同一写入rsvFour
			//7.记录业务凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			if(Tools.processNull(operType).equals("0")){
				json.put(ReceiptContants.FIELD.DEAL_FEE, "押金：￥" + Arith.cardreportsmoneydiv(rec.getAmt() + ""));
			}else{
				json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportsmoneydiv(rec.getAmt() + ""));
			}
			json.put(ReceiptContants.FIELD.CARD_NO, rec.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, rec.getCustomerName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, rec.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, rec.getAgtName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getAgtCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, rec.getAgtCertNo()); // 代理人证件号码
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(log,json, ReceiptContants.TYPE.COMMON, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			//8.记录业务日志
			rec.setCustomerId(person.getCustomerId().toString());
			rec.setCustomerName(person.getName());
			rec.setAcptType(Constants.ACPT_TYPE_GM);
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setDealState(Constants.TR_STATE_HJL);
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setClrDate(this.getClrDate());
			rec.setAmt(-fee);//开通扣钱写负,终止退钱写正
			rec.setNum(1L);
			rec.setCardId(card.getCardId());
			rec.setCardNo(card.getCardNo());
			rec.setCardAmt(1L);
			rec.setCardType(card.getCardType());
			rec.setCertNo(person.getCertNo());
			rec.setCertType(person.getCertType());
			rec.setNote(log.getMessage());
			this.publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}

	/**
	 * 应用开通与终止灰记录确认
	 * @param dealNo 确认流水
	 * @param type 确认类型 0 自动确认 1 手工确认(手工确认会记录日志信息)
	 * @param ywlx 开通与取消  0 应用开通   1 应用取消
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public void saveCardAppOpenOrCloseHjlConfirm(long dealNo,String type,String ywlx) throws CommonException{
		try{
			SysActionLog log = null;
			String ywlxstring = "";
			if(Tools.processNull(ywlx).equals("0")){
				ywlxstring = "开通";
			}else if(Tools.processNull(ywlx).equals("1")) {
				ywlxstring = "终止";
			}else{
				throw new CommonException("业务操作类型不正确！");
			}
			if(Tools.processLong(dealNo + "") == -1){
				throw new CommonException(ywlxstring + "流水编号不正确！");
			}
			if(Tools.processNull(type).equals("")){
				throw new CommonException(ywlxstring + "类型不正确！");
			}else if(!Tools.processNull(type).equals("0") && !Tools.processNull(type).equals("1")){
				throw new CommonException(ywlxstring + "类型不正确！");
			}
			TrServRec rec = (TrServRec) this.findOnlyRowByHql("from TrServRec where dealNo = " + dealNo);
			if(rec == null){
				throw new CommonException("根据流水编号" + dealNo + "找不到待确认应用" + ywlxstring + "信息！");
			}
			if(!Tools.processNull(rec.getDealState()).equals(Constants.TR_STATE_HJL)){
				throw new CommonException("根据流水编号" + dealNo + "找到的" + ywlxstring + "记录不是【灰记录】状态！");
			}
			CardBaseinfo cardBaseinfo = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + rec.getCardNo() + "'");
			if(cardBaseinfo == null){
				throw new CommonException(ywlxstring + "应用的卡信息不存在！");
			}
			BigDecimal isHasOpened = (BigDecimal) this.findOnlyFieldBySql("select count(1) from card_app_open t where t.card_no = '" + cardBaseinfo.getCardNo() + "' and t.app_type = '" + rec.getRsvTwo() + "' and t.state = '0'");
			if(Tools.processNull(ywlx).equals("0")){
				if(isHasOpened.intValue() != 0){
					throw new CommonException("该卡当前应用已开通！");
				}
			}else if(Tools.processNull(ywlx).equals("1")) {
				if(isHasOpened.intValue() == 0){
					throw new CommonException("该卡当前应用未开通！");
				}
			}
			if(!Tools.processNull(type).equals("0")){
				log = this.getCurrentActionLog();
				if(Tools.processNull(ywlx).equals("0")) {
					log.setDealCode(DealCode.ZXC_APP_OPEN_HJL_CONFIRM);//开通灰记录确认
				}else{
					log.setDealCode(DealCode.ZXC_APP_CANCEL_HJL_CONFIRM);//终止灰记录确认
				}
				log.setMessage("应用" + ywlxstring + "灰记录确认，原流水=" + dealNo);
				this.publicDao.save(log);
			}
			Users oper = this.getUser();
			BasePersonal person = new BasePersonal();
			if(!Tools.processNull(rec.getCertNo()).equals("")){
				person = (BasePersonal) this.findOnlyRowByHql("from BasePersonal where certNo = '" + rec.getCertNo() + "'");
				if(person == null){
					person = new BasePersonal();
				}
			}
			StringBuffer sb = new StringBuffer();
			sb.append(oper.getOrgId() + "|");//1.机构编号
			sb.append(Constants.ACPT_TYPE_GM + "|");//2.受理点类型
			sb.append(oper.getBrchId() + "|");//3.受理网点
			sb.append(oper.getUserId() + "|");//4.受理柜员
			if(Tools.processNull(rec.getRsvTwo()).equals("09")){
				sb.append(Tools.processNull(rec.getDealNo()) + "|"); //5.业务流水
			}else{
				sb.append("" + "|");
			}
			sb.append(person.getCertNo() + "|");//6.证件号码
			sb.append(person.getName() + "|");//7.姓名
			sb.append(rec.getCardNo() + "|");//8.卡号
			sb.append(rec.getRsvTwo() + "|");//9.应用类型
			sb.append(ywlx + "|");//10.操作类型
			sb.append(rec.getAmt() + "|");//11.金额
			sb.append("" + "|");//12.有效期
			sb.append("" + "|");//13.关联商户
			sb.append("" + "|");//14.关联唯一号
			sb.append("1" + "|");//15.保留1 收费方式 0 现金 1 卡账户转账
			sb.append("" + "|");//16.保留2 收费方式为转账时 扣费账户类型
			if(Tools.processNull(rec.getRsvTwo()).equals("09")){
				sb.append("0" + "|");//17.保留3 是否不记录日志 0 不记
				sb.append(Tools.processNull(rec.getDealCode()) + "|");//18.保留4 交易代码
				if(Tools.processNull(type).equals("0")){
					sb.append(DateUtil.formatDate(rec.getBizTime(),"yyyy-MM-dd HH:mm:ss") + "|");//19.保留5 时间 yyyy-mm-dd hh24:mi:ss
				}else{
					sb.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "|");//19.保留5 时间 yyyy-mm-dd hh24:mi:ss
				}
			}else{
				sb.append("" + "|");
				sb.append("" + "|");
				sb.append("" + "|");
			}
			sb.append(Tools.processNull(rec.getAgtCertType()) + "|");
			sb.append(Tools.processNull(rec.getAgtCertNo()) + "|");
			sb.append(Tools.processNull(rec.getAgtName()) + "|");
			sb.append(Tools.processNull(rec.getAgtTelNo())+ "|");
			sb.append("" + "|");
			List<String> inParamList = new ArrayList<String>();
			inParamList.add(sb.toString());
			List<Integer> outParamList = new ArrayList<Integer>();
			outParamList.add(java.sql.Types.VARCHAR);
			outParamList.add(java.sql.Types.VARCHAR);
			outParamList.add(java.sql.Types.VARCHAR);
			List res = publicDao.callProc("pk_service_outer.p_cardapp_openorclose",inParamList,outParamList);
			String outString = "";
			if(res != null && res.size() > 0) {
				if(Integer.parseInt(res.get(0).toString()) != 0) {
					throw new CommonException(res.get(1).toString());
				}else{
					outString = (String)res.get(2);
				}
			}else{
				throw new CommonException("调取过程返回为空！");
			}
			if(!Tools.processNull(type).equals("0")){
				TrServRec newRec = (TrServRec) BeanUtils.cloneBean(rec);
				newRec.setDealNo(log.getDealNo());
				newRec.setDealCode(log.getDealCode());
				newRec.setBizTime(log.getDealTime());
				newRec.setBrchId(oper.getBrchId());
				newRec.setUserId(oper.getUserId());
				newRec.setNote(rec.getNote());
				newRec.setDealState(Constants.TR_STATE_ZC);
				newRec.setOldDealNo(rec.getDealNo());
				newRec.setClrDate(this.getClrDate());
				this.publicDao.save(newRec);
			}
			String updateOldRec = "update tr_serv_rec set deal_state = '" + Constants.TR_STATE_ZC + "' , clr_date = '" + this.getClrDate() + "' ";
			if(!Tools.processNull(type).equals("0")){
				updateOldRec += ",note = note || '_' || '已确认' ";
			}
			updateOldRec += "where deal_no = " + rec.getDealNo();
			int updateSum = this.publicDao.doSql(updateOldRec);
			if(updateSum != 1){
				throw new CommonException("确认灰记录出现错误！");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}

	/**
	 * 应用开通与终止灰记录取消
	 * @param dealNo 取消灰记录流水
	 * @param type 取消类型 0 自动撤销的 1 手动撤销(手动取消会记录日志信息)
	 * @throws CommonException
	 */
	public void saveCardAppOpenOrCloseHjlCancel(long dealNo,String type,String ywlx) throws CommonException{
		try{
			SysActionLog log = null;
			String ywlxstring = "";
			if(Tools.processNull(ywlx).equals("0")){
				ywlxstring = "开通";
			}else if(Tools.processNull(ywlx).equals("1")) {
				ywlxstring = "终止";
			}else{
				throw new CommonException("业务操作类型不正确！");
			}
			if(Tools.processLong(dealNo + "") == -1){
				throw new CommonException("应用" + ywlxstring + "灰记录取消流水不正确！");
			}
			if(Tools.processNull(type).equals("")){
				throw new CommonException("应用" + ywlxstring +"灰记录取消类型不正确！");
			}else if(!Tools.processNull(type).equals("0") && !Tools.processNull(type).equals("1")){
				throw new CommonException("应用" + ywlxstring + "灰记录取消类型不正确！");
			}
			if(!Tools.processNull(type).equals("0")){
				log = (SysActionLog) BeanUtils.cloneBean(this.getCurrentActionLog());
				if(Tools.processNull(ywlx).equals("0")) {
					log.setDealCode(DealCode.ZXC_APP_OPEN_HJL_CANCEL);
				}else{
					log.setDealCode(DealCode.ZXC_APP_CANCEL_HJL_CANCEL);
				}
				log.setMessage("应用" + ywlxstring + "灰记录取消，原流水=" + dealNo);
				this.publicDao.save(log);
			}
			TrServRec rec = (TrServRec) this.findOnlyRowByHql("from TrServRec where dealNo = " + dealNo);
			if(rec == null){
				throw new CommonException("根据流水编号" + dealNo + "找不到待撤销应用" + ywlxstring + "信息！");
			}
			if(!Tools.processNull(rec.getDealState()).equals(Constants.TR_STATE_HJL)){
				throw new CommonException("根据流水编号" + dealNo + "找到的" + ywlxstring + "记录不是【灰记录】状态！");
			}
			String updateOldRec = "update tr_serv_rec set deal_state = '" + Constants.TR_STATE_CX + "' , clr_date = '" + this.getClrDate() + "' ";
			if(!Tools.processNull(type).equals("0")){
				updateOldRec += ",note = note || '_' || '已撤销' ";
			}
			updateOldRec += "where deal_no = " + dealNo;
			int updateSum = this.publicDao.doSql(updateOldRec);
			if(updateSum != 1) {
				//
			}
			this.publicDao.doSql("delete from sys_report t where t.deal_no = " + dealNo);
			if(!Tools.processNull(type).equals("0")){
				TrServRec newRec = null;
				Users oper = this.getUser();
				if(rec != null){
					newRec = (TrServRec) BeanUtils.cloneBean(rec);
					newRec.setDealNo(log.getDealNo());
					newRec.setBrchId(oper.getBrchId());
					newRec.setUserId(oper.getUserId());
					newRec.setDealState(Constants.TR_STATE_ZC);
					newRec.setClrDate(this.getClrDate());
					newRec.setOldDealNo(rec.getDealNo());
					newRec.setBizTime(log.getDealTime());
					newRec.setClrDate(this.getClrDate());
					newRec.setDealCode(log.getDealCode());
					newRec.setNote(log.getMessage());
					this.publicDao.save(newRec);
				}
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}

	/**
	 * 卡应用开通与终止(无需写卡类)
	 * @param inpara 参数信息
	 * @param oper 操作员
	 * @param rec 业务日志
	 * @param log 操作日志
	 * @return 业务日志
	 */
	public TrServRec saveCardAppOpenOrClose(Map inpara, Users oper, TrServRec rec,SysActionLog log) throws CommonException{
		try{
			//1.基本参数和操作类型判断
			String operString = "";
			if(inpara == null || inpara.isEmpty()){
				throw new CommonException("参数信息不能为空！");
			}
			String cardNo = Tools.processNull(inpara.get("cardNo"));
			String appType = Tools.processNull(inpara.get("appType"));
			String operType = Tools.processNull(inpara.get("operType"));
			long fee = Tools.processLong(inpara.get("fee") + "");
			if(Tools.processNull(operType).equals("0")){
				operString = "卡应用开通";
			}else if(Tools.processNull(operType).equals("1")){
				operString = "卡应用终止";
			}else{
				throw new CommonException("应用操作类型不正确！");
			}
			if(Tools.processNull(cardNo).equals("")){
				throw new CommonException(operString + "，卡号不能为空！");
			}
			if(Tools.processNull(appType).equals("")){
				throw new CommonException(operString + "，类型不能为空！");
			}
			CardBaseinfo card = (CardBaseinfo)this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
			if(card == null){
				throw new CommonException("根据卡号" + cardNo + "找不到卡片信息！");
			}
			//2.开通时判断卡状态,取消时不进行判断
			if(Tools.processNull(operType).equals("0")){
				if(fee < 0){
					throw new CommonException(operString + "，费用不能为空！");
				}
				if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZC)){
					throw new CommonException("卡状态不正确不能进行" + operString + "！");
				}
			}
			//3.持卡人信息判断
			if(Tools.processNull(card.getCustomerId()).equals("")){
				throw new CommonException("卡片持卡人信息不存在！");
			}
			BasePersonal person = (BasePersonal)this.findOnlyRowByHql("from BasePersonal b where b.customerId = '" + card.getCustomerId() + "'");
			if(person == null){
				throw new CommonException("卡片持卡人信息不存在！");
			}
			//4.调取过程
			StringBuffer sb = new StringBuffer();
			sb.append(oper.getOrgId() + "|");
			sb.append(Constants.ACPT_TYPE_GM + "|");
			sb.append(oper.getBrchId() + "|");
			sb.append(oper.getUserId() + "|");
			sb.append("" + "|");
			sb.append(person.getCertNo() + "|");
			sb.append(person.getName() + "|");
			sb.append(card.getCardNo() + "|");
			sb.append(appType + "|");
			sb.append(operType + "|");
			sb.append(fee + "|");
			sb.append("" + "|");
			sb.append("" + "|");
			sb.append(Tools.processNull(inpara.get("theOnlyOne")) + "|");
			sb.append("1" + "|");
			sb.append("" + "|");
			sb.append("" + "|");
			sb.append("" + "|");
			sb.append("" + "|");
			sb.append(Tools.processNull(rec.getAgtCertType()) + "|");
			sb.append(Tools.processNull(rec.getAgtCertNo()) + "|");
			sb.append(Tools.processNull(rec.getAgtName()) + "|");
			sb.append(Tools.processNull(rec.getAgtTelNo())+ "|");
			sb.append("" + "|");
			List<String> inParamList = new ArrayList<String>();
			inParamList.add(sb.toString());
			List outParamList = new ArrayList();
			outParamList.add(java.sql.Types.VARCHAR);
			outParamList.add(java.sql.Types.VARCHAR);
			outParamList.add(java.sql.Types.VARCHAR);
			List res = publicDao.callProc("pk_service_outer.p_cardapp_openorclose",inParamList,outParamList);
			String outString = "";
			if(res != null && res.size() > 0){
				if (Integer.parseInt(res.get(0).toString()) != 0) {
					throw new CommonException(res.get(1).toString());
				} else {
					outString = res.get(2).toString();
				}
			}else{
				throw new CommonException("调取过程返回为空！");
			}
			log = (SysActionLog) this.findOnlyRowByHql("from SysActionLog where dealNo = " + outString);
			rec = (TrServRec) this.findOnlyRowByHql("from TrServRec where dealNo = " + outString);
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			if(Tools.processNull(operType).equals("0")){
				json.put(ReceiptContants.FIELD.DEAL_FEE, "押金：￥" + Arith.cardreportsmoneydiv(rec.getAmt() + ""));
			}else{
				json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportsmoneydiv(rec.getAmt() + ""));
			}
			json.put(ReceiptContants.FIELD.CARD_NO, rec.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, rec.getCustomerName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, rec.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, rec.getAgtName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getAgtCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, rec.getAgtCertNo()); // 代理人证件号码
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(log,json, ReceiptContants.TYPE.COMMON, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			//调积分宝接口
			if (Tools.processNull(operType).equals("0") && Tools.processNull(appType).equals("08")) {// 积分宝
				//
				String certType = "0";// 证件类型0身份证（默认）
				if (!"1".equals(person.getCertType())) {
					certType = "1";
				}
				String birth = person.getBirthday().replaceAll("-", "");
				String gender = "";
				if("1".equals(person.getGender())){
					gender = "1";
				} else if("2".equals(person.getGender())){
					gender = "0";
				}
				//
				openJFBMember(card.getSubCardNo(), "", person.getName(), "000000", person.getMobileNo(), certType, person.getCertNo(), person.getEmail(), "", birth, gender, rec.getBizTime());
			}
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}


	/**
	 * 自行车开通与终止
	 * @param inpara 参数信息
	 * @param oper 操作员
	 * @param rec 业务日志
	 * @param log 操作日志
	 * @return
	 */
	public CardAppSyn saveZXCAppOpenOrClose(Map inpara, Users oper, TrServRec rec,SysActionLog log) throws CommonException{
		try{
			//1.基本参数和操作类型判断
			String operString = "";
			if(log == null){
				log = this.getCurrentActionLog();
			}
			if(inpara == null || inpara.isEmpty()){
				throw new CommonException("参数信息不能为空！");
			}
			String cardNo = Tools.processNull(inpara.get("cardNo"));
			String appType = Tools.processNull(inpara.get("appType"));
			String operType = Tools.processNull(inpara.get("operType"));
			long fee = Tools.processLong(inpara.get("fee") + "");
			if(Tools.processNull(operType).equals("0")){
				operString = "卡应用开通";
			}else if(Tools.processNull(operType).equals("1")){
				operString = "卡应用终止";
			}else{
				throw new CommonException("应用操作类型不正确！");
			}
			if(Tools.processNull(cardNo).equals("")){
				throw new CommonException(operString + "，卡号不能为空！");
			}
			if(Tools.processNull(appType).equals("")){
				throw new CommonException(operString + "，类型不能为空！");
			}
			CardBaseinfo card = (CardBaseinfo)this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
			if(card == null){
				throw new CommonException("根据卡号" + cardNo + "找不到卡片信息！");
			}
			//2.开通时判断卡状态,取消时不进行判断
			if(Tools.processNull(operType).equals("0")){
				if(fee < 0){
					throw new CommonException(operString + "，费用不能为空！");
				}
				if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZC)){
					throw new CommonException("卡状态不正确不能进行" + operString + "！");
				}
			}
			//3.持卡人信息判断
			if(Tools.processNull(card.getCustomerId()).equals("")){
				throw new CommonException("卡片持卡人信息不存在！");
			}
			BasePersonal person = (BasePersonal)this.findOnlyRowByHql("from BasePersonal b where b.customerId = '" + card.getCustomerId() + "'");
			if(person == null){
				throw new CommonException("卡片持卡人信息不存在！");
			}
			//5.记录操作日志信息
			if(Tools.processNull(operType).equals("0")){
				log.setDealCode(80010001);//应用开通交易代码
			}else if(Tools.processNull(operType).equals("1")){
				log.setDealCode(80010004);//应用终止交易代码
			}else{
				throw new CommonException("应用操作类型不正确！");
			}
			log.setMessage(operString + "，卡号" + card.getCardNo() + ",类型" + appType);
			publicDao.save(log);
			//4.调取过程
			StringBuffer sb = new StringBuffer();
			//1.业务类型(01 - 开通 02 -挂失 03-解挂失 04 关闭 对应交易代码  开通 80010001 挂失 80010002 解挂失 80010003 关闭 80010004)
			sb.append(rec.getRsvFive() + "|");
			//2.卡号
			sb.append(card.getCardNo() + "|");
			//3.业务流水号
			sb.append(log.getDealNo() + "|");
			//4受理点编号或网点编号
			sb.append(oper.getBrchId()+ "|");
			//5受理终端号或柜员编号
			sb.append(oper.getUserId()+ "|");
			//6冻结金额
			sb.append("20000" + "|");
			//7受理点类型
			sb.append(Constants.ACPT_TYPE_GM + "|");
			//8备注
			sb.append("" + "|");
			//04|31400010001104183343|98087537|99999999|adminge|20000|1|55555|
			List<String> inParamList = new ArrayList<String>();
			inParamList.add(sb.toString());
			List outParamList = new ArrayList();
			outParamList.add(java.sql.Types.VARCHAR);
			outParamList.add(java.sql.Types.VARCHAR);
			outParamList.add(java.sql.Types.VARCHAR);
			List res = publicDao.callProc("pk_service_outer.p_zxcApply_handle",inParamList,outParamList);
			String outString = "";
			if(res != null && res.size() > 0){
				if (Integer.parseInt(res.get(0).toString()) != 0) {
					throw new CommonException(res.get(1).toString());
				} else {
					outString = res.get(2).toString();
				}
			}else{
				throw new CommonException("调取过程返回为空！");
			}
			CardAppSyn cay = new CardAppSyn();
			log = (SysActionLog) this.findOnlyRowByHql("from SysActionLog where dealNo = " + outString);
			cay = (CardAppSyn) this.findOnlyRowByHql("from CardAppSyn where dealNo = " + outString);
			//记录业务日志
			rec.setDealNo(cay.getDealNo());
			if(Tools.processNull(operType).equals("0")){
				rec.setDealCode(80010001);//应用开通交易代码
			}else if(Tools.processNull(operType).equals("1")){
				rec.setDealCode(80010004);//应用终止交易代码
			}
			rec.setCustomerId(cay.getCustomerId());
			rec.setCardId(cay.getCardId());
			rec.setCardNo(cay.getCardNo());
			rec.setCardType(cay.getCardType());
			rec.setCustomerName(cay.getName());
			rec.setCertNo(cay.getCertNo());
			rec.setBizTime(cay.getBizTime());
			rec.setBrchId(cay.getAcptId());
			rec.setUserId(cay.getUserId());
			rec.setRsvOne(cay.getDealType());
			rec.setClrDate(cay.getClrDate());
			rec.setRtnFgft(cay.getFee());
			rec.setAmt(cay.getFee());

			publicDao.save(rec);
			//记录打印日志
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			if(Tools.processNull(operType).equals("0")){
				json.put(ReceiptContants.FIELD.DEAL_FEE, "押金：￥" + Arith.cardreportsmoneydiv(cay.getFee() + ""));
			}else{
				json.put(ReceiptContants.FIELD.DEAL_FEE, "￥" + Arith.cardreportsmoneydiv(cay.getFee() + ""));
			}
			json.put(ReceiptContants.FIELD.CARD_NO, cay.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, cay.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, cay.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(log,json, ReceiptContants.TYPE.COMMON, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			return cay;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}



	//挂失与解挂失
	public void saveZXCAppReportOrLoss(TrServRec rec,Long dealNo) throws CommonException{
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("02" + "|");
			sb.append(rec.getCardNo() + "|");
			sb.append(dealNo + "|");
			sb.append(rec.getBrchId() + "|");
			sb.append(rec.getUserId() + "|");
			sb.append("0" + "|");
			sb.append(Constants.ACPT_TYPE_GM + "|");
			sb.append("" + "|");
			List<String> inParamList = new ArrayList<String>();
			inParamList.add(sb.toString());
			List outParamList = new ArrayList();
			outParamList.add(java.sql.Types.VARCHAR);
			outParamList.add(java.sql.Types.VARCHAR);
			outParamList.add(java.sql.Types.VARCHAR);
			List res = publicDao.callProc("pk_service_outer.p_zxcApply_handle",inParamList,outParamList);

		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}

	/**
	 * 开通积分宝会员
	 * @param subCardNo 积分宝卡号/市民卡号，如果没有积分宝系统会自动生成一个
	 * @param bankNo 市民卡的银行卡号类型的信息可以共享（借记卡3-8可以是星号）（不传）
	 * @param memberName 会员名
	 * @param code 卡背后校验码（6位），没有用000000填补
	 * @param phoneNo 手机号（11位）
	 * @param certType 证件类型0身份证（默认）
	 * @param certNo 证件号
	 * @param email 邮箱
	 * @param oId 商户登录号（合作伙伴固定编号，由积分宝提供,测试用10000）
	 * @param certCode 短信验证，非移动端激活为空
	 * @param birth 生日 （YYYYMMSS）
	 * @param gender 性别(女0，男1)
	 * @param time 提交时间
	 */
	private void openJFBMember(String subCardNo, String bankNo, String memberName, String code, String phoneNo, String certType, String certNo, String email, String certCode, String birth, String gender, Date time) {
		try {
			String path = ResourceUtil.getJfbHttpInterfacePath(); // 接口地址
			String iType = "10050"; // 接口 type
			String oId = "10000"; // 测试
			String key = "1234567890123456"; // 测试 AES key
			String salt = "12345678901234567890123456789012"; // 测试 md5 key
			String subtime = DateUtil.formatDate(time, "yyyyMMddHHmmssSSS"); // 提交时间, 格式：yyyyMMddHHmmssSSS
			String checkValue = MD5Util.crypt(subtime + iType + salt);
			//
			ArrayList<NameValuePair> params = new ArrayList<NameValuePair>();
			params.add(new BasicNameValuePair("type", AesPlus.Encrypt(iType, key)));
			params.add(new BasicNameValuePair("cardId", subCardNo));
			params.add(new BasicNameValuePair("bankId", bankNo));
			params.add(new BasicNameValuePair("memberName", memberName));
			params.add(new BasicNameValuePair("code", code));
			params.add(new BasicNameValuePair("phoneNo", phoneNo));
			params.add(new BasicNameValuePair("idType", certType));
			params.add(new BasicNameValuePair("identityId", AesPlus.Encrypt(certNo, key)));
			params.add(new BasicNameValuePair("email", email));
			params.add(new BasicNameValuePair("oId", oId));
			params.add(new BasicNameValuePair("certCode", certCode));
			params.add(new BasicNameValuePair("birth", birth));
			params.add(new BasicNameValuePair("gender", gender));
			params.add(new BasicNameValuePair("subtime", subtime));
			params.add(new BasicNameValuePair("chkValue", checkValue));
			String paramStr = EntityUtils.toString(new UrlEncodedFormEntity(params, Consts.UTF_8));
			//
			HttpClient client = HttpClients.createDefault();
			HttpGet req = new HttpGet(path + "?" + paramStr);
			HttpResponse resp = client.execute(req);
			HttpEntity entity = resp.getEntity();
			String result = EntityUtils.toString(entity);
			if (result == null || result.equals("")) {
				throw new CommonException("返回数据为空！");
			}
			try {
				JSONObject jsb = JSONObject.parseObject(result);
				if (!"1".equals(jsb.getString("status"))){
					throw new CommonException(jsb.getString("message"));
				}
			} catch (Exception e) {
				throw new CommonException("返回数据格式错误！");
			}
		} catch (Exception e) {
			throw new CommonException("调用积分宝接口失败，" + e.getMessage());
		}
	}
}