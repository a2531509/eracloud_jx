package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.DoWorkClientService;
import com.erp.service.PwdService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.ReceiptContants;
import com.erp.util.Tools;

@Service(value="pwdService")
public class PwdServiceImpl extends BaseServiceImpl implements PwdService {
	@Resource(name="doWorkClientService")
	private DoWorkClientService doWorkClient;
	
	
	/**
	 * <p>个人服务密码修改,重置/p>
	 * @param customerId 客户编号
	 */
	@SuppressWarnings("unchecked")
	@Override
	public Long saveServicePwdModify(Long customerId,String pwd,TrServRec rec,int type) throws CommonException {
		try{
			//1.条件判断
			if(type != 0 && type != 1){
				throw new Exception("服务密码操作类型不正确！");
			}
			BasePersonal bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + customerId + "'");
			if(bp == null){
				throw new Exception("根据客户编号未查询到对应的人员信息，无法" + (type == 0 ? "修改" : "重置") +"服务密码！");
			}
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.customerId = '" + bp.getCustomerId() + "'");
			//2.保存操作日志
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(type == 0 ? DealCode.PERSON_SERVICEPWD_MODIFY : DealCode.PERSON_SERVICEPWD_RESET);
			log.setMessage("服务密码" + (type == 0 ? "修改" : "重置") + ":用户编号customerId=" + customerId);
			publicDao.save(log);
			BigDecimal isCount = (BigDecimal) this.findOnlyFieldBySql("select count(1) from card_baseinfo t where t.customer_id = '" + customerId + "' and (t.card_type = '" + Constants.CARD_TYPE_SMZK + "' or t.card_type = '" + Constants.CARD_TYPE_QGN + "')");
			if(isCount.longValue() <= 0){
				throw new CommonException("该客户不存在卡片信息，无需进行服务密码" + (type == 0 ? "修改" : "重置"));
			}
			isCount = (BigDecimal) this.findOnlyFieldBySql("select count(1) from card_baseinfo t where t.card_state = '1' and t.customer_id = '" + customerId + "' and (t.card_type = '" + Constants.CARD_TYPE_SMZK + "' or t.card_type = '" + Constants.CARD_TYPE_QGN + "')");
			if(isCount.longValue() <= 0 ){
				throw new CommonException("卡状态不正常，不能进行服务密码" + (type == 0 ? "修改" : "重置"));
			}
			//3.更新密码
			int isUpdate = publicDao.doSql("update base_personal t set t.serv_pwd_err_num = 0, t.serv_pwd = '" + this.encrypt_des(pwd,bp.getCertNo()) + "' where t.cert_no = '" + bp.getCertNo() + "' and t.customer_id = '" + bp.getCustomerId() + "'");
			if(isUpdate < 1){
				throw new CommonException((type == 0 ? "修改" : "重置") +"服务失败！");
			}
			//4.记录业务日志
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setCustomerId(customerId + "");
			rec.setCustomerName(bp.getName());
			rec.setCertNo(bp.getCertNo());
			rec.setCertType(bp.getCertType());
			rec.setNewPwd(this.encrypt_des(pwd,bp.getCertNo()));//新密码
			rec.setDealState(Constants.STATE_ZC);
			rec.setNote(log.getMessage());
			publicDao.save(rec);
			//5.保存报表数据
			/*JSONObject report = new JSONObject();
			report.put("p_Action_No",rec.getDealNo() + "");
			report.put("p_Type",this.findTrCodeNameByCodeType(rec.getDealCode()));
			report.put("p_Print_Time",DateUtil.formatDate(rec.getBizTime(),"yyyy-MM-dd HH:mm:ss"));
			report.put("p_Client_Id",rec.getCustomerName());
			report.put("p_Cert_Type",this.getCodeNameBySYS_CODE("CERT_TYPE",rec.getCertType()));
			report.put("p_Cert_No",rec.getCertNo());
			report.put("p_Operid",rec.getUserId());
			report.put("p_Brchid",rec.getBrchId());
			report.put("p_Agtname",rec.getAgtName());
			report.put("p_Agtcerttype",this.getCodeNameBySYS_CODE("CERT_TYPE",rec.getAgtCertType()));
			report.put("p_Agtcertno",rec.getAgtCertNo());
			report.put("p_Agttelno",rec.getAgtTelNo());
			this.saveSysReport(log,report,"/reportfiles/XiuGaiPwd.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);*/
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "工本费：￥" + Arith.cardreportsmoneydiv("0"));
			json.put(ReceiptContants.FIELD.CARD_NO, rec.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, card != null ? card.getSubCardNo() : ""); // 社保卡号
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
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
		return rec.getDealNo();
	}
	/**
	 * <p>校验个人用户的服务密码</p>
	 * @param customerId 用户customerId
	 * @param pwd 用户密码
	 * @return 校验是否成功
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public Map<String,String> judgeCustomerServicePwd(Long customerId,String pwd) throws CommonException{
		Map<String,String> map = new HashMap<String,String>();
		map.put("isVerifyOk","1");
		map.put("msg","");
		try{
			BasePersonal bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + customerId + "'");
			if(bp == null){
				map.put("msg","用户信息不存在");
			}else if(Tools.processNull(bp.getCertNo()).replaceAll(" ", "").equals("")){
				map.put("msg","无效的证件号码");
			}else if(Tools.processNull(bp.getServPwd()).replaceAll(" ", "").equals("")){
				map.put("msg","密码信息不存在，请先重置服务密码");
			}else{
				String des3String = this.encrypt_des(pwd,bp.getCertNo().toUpperCase());
				List inParam = new ArrayList();
				inParam.add(bp.getCertNo());
				inParam.add(bp.getName());
				inParam.add(des3String);
				List outParam = new ArrayList();
				outParam.add(java.sql.Types.VARCHAR);
				outParam.add(java.sql.Types.VARCHAR);
				List out = publicDao.callProc("pk_public.p_judgeservicepwd",inParam,outParam);
				if(out != null && out.size() > 0){
					if(Integer.parseInt(out.get(0).toString()) != 0){
						throw new CommonException(out.get(1).toString());
					}
				}else{
					throw new CommonException("判断服务密码出现错误：返回null");
				}
				map.put("isVerifyOk","0");
			}
		}catch(Exception e){
			map.put("msg",e.getMessage());
		}
		return map;
	}
	/**
	 * 联机账户支付密码重置 
	 * @param para JSONObject 参数信息  para.cardNo 卡号,para.pwd 密码
	 * @param oper Users 操作柜员
	 * @param log SysActionLog 操作日志
	 * @return TrServRec 业务日志
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec savePayPwdReset(JSONObject para,Users oper,SysActionLog log) throws CommonException{
		try{
			//1.基本信息判断
			if(para == null){
				throw new CommonException("联机账户支付密码重置,传入参数信息不能为空！");
			}
			if(oper == null){
				throw new CommonException("联机账户支付密码重置,操作柜员不能为空！");
			}
			if(log == null){
				throw new CommonException("联机账户支付密码重置,操作日志不能为空！");
			}
			if(Tools.processNull(para.getString("cardNo")).trim().equals("")){
				throw new CommonException("联机账户支付密码重置,卡号不能为空！");
			}
			if(Tools.processNull(para.getString("pwd")).trim().equals("")){
				throw new CommonException("联机账户支付密码重置,新密码不能为空！");
			}
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + para.getString("cardNo") + "'");
			BasePersonal bp = new BasePersonal();
			if(card == null){
				throw new CommonException("卡片信息不存在，不能进行联机账户支付密码重置！");
			}else{
				if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZC)){
					throw new CommonException("卡状态不正常，不能进行支付密码重置！");
				}
				if(!Tools.processNull(card.getCustomerId()).equals("")){
					bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
					if(bp == null){
						bp = new BasePersonal();
					}
				}
			}
			if(!Tools.processNull(card.getPayPwd()).equals("")){
				//throw new CommonException("原密码信息已存在，请进行联机账户支付密码修改！");
			}
			//2.保存操作日志
			log.setDealCode(DealCode.PERSON_TRADEPWD_RESET);
			log.setMessage("个人联机支付密码重置");
			publicDao.save(log);
			TrServRec rec = para.getObject("rec",TrServRec.class);
			if( rec == null){
				rec = new TrServRec();
			}
			rec.setOldPwd(card.getPayPwd());//旧密码
			//TODO 目前在重置联机账户密码时不判断卡的状态
			//3.根据卡号、新密码进行加密得到密文
			String newPwd = doWorkClient.encrypt_PinPwd(card.getCardNo(),para.getString("pwd"));
			if(Tools.processNull(newPwd).equals("")){
				throw new CommonException("密文加密失败！");
			}
			int updaterows = publicDao.doSql("update CARD_BASEINFO t set t.pay_pwd_err_num = 0, t.pay_pwd = '" + newPwd + "' where t.card_no = '" + card.getCardNo() + "'");
			if(updaterows != 1){
				throw new CommonException("联机账户密码重置出现错误，更新0行！");
			}
			//4.保存业务操作日志
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setCardId(card.getCardId());
			rec.setNote(log.getMessage());
			rec.setCustomerName(bp.getName());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setCardAmt(1L);
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setNewPwd(newPwd);
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			rec.setAgtTelNo(Tools.processNull(rec.getAgtTelNo()).equals("") ? bp.getMobileNo() : rec.getAgtTelNo());
			publicDao.save(rec);
			//5.保存报表
			/*JSONObject report = new JSONObject();
			report.put("p_Action_No",rec.getDealNo() + "");
			report.put("p_Type",this.findTrCodeNameByCodeType(rec.getDealCode()));
			report.put("p_Print_Time",DateUtil.formatDate(rec.getBizTime(),"yyyy-MM-dd HH:mm:ss"));
			report.put("p_Client_Id",rec.getCustomerName());
			report.put("p_Cert_Type",this.getCodeNameBySYS_CODE("CERT_TYPE",rec.getCertType()));
			report.put("p_Cert_No",rec.getCertNo());
			report.put("p_Operid",rec.getUserId());
			report.put("p_Brchid",rec.getBrchId());
			report.put("p_Agtname",rec.getAgtName());
			report.put("p_Agtcerttype",this.getCodeNameBySYS_CODE("CERT_TYPE",rec.getAgtCertType()));
			report.put("p_Agtcertno",rec.getAgtCertNo());
			report.put("p_Agttelno",rec.getAgtTelNo());
			this.saveSysReport(log,report,"/reportfiles/XiuGaiPwd.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);*/
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
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 联机账户服务密码修改
	 * @param para JSONObject 参数信息  para.cardNo 卡号,para.pwd 密码,para.oldPwd 旧密码
	 * @param oper Users 操作柜员
	 * @param log SysActionLog 操作日志
	 * @return TrServRec 业务日志
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec savePayPwdModify(JSONObject para,Users oper,SysActionLog log) throws CommonException{
		try{
			//1.基本信息判断
			if(para == null){
				throw new CommonException("联机账户支付密码修改,传入参数信息不能为空！");
			}
			if(oper == null){
				throw new CommonException("联机账户支付密码修改,操作柜员不能为空！");
			}
			if(log == null){
				throw new CommonException("联机账户支付密码修改,操作日志不能为空！");
			}
			if(Tools.processNull(para.getString("cardNo")).trim().equals("")){
				throw new CommonException("联机账户支付密码修改,卡号不能为空！");
			}
			if(Tools.processNull(para.getString("pwd")).trim().equals("")){
				throw new CommonException("联机账户支付密码修改,新密码不能为空！");
			}
			if(Tools.processNull(para.getString("oldPwd")).trim().equals("")){
				throw new CommonException("联机账户支付密码修改,原密码不能为空！");
			}
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + para.getString("cardNo") + "'");
			BasePersonal bp = null;
			if(card == null){
				throw new CommonException("卡片信息不存在，不能进行联机账户支付密码修改！");
			}else{
				if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZC)){
					throw new CommonException("卡状态不正常，不能进行支付密码修改！");
				}
				if(!Tools.processNull(card.getCustomerId()).equals("")){
					bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
					if(bp == null){
						bp = new BasePersonal();
					}
				}
			}
			if(Tools.processNull(card.getPayPwd()).equals("")){
				throw new CommonException("原密码信息不存在，请先进行联机账户支付密码重置！");
			}
			//2.保存操作日志
			log.setDealCode(DealCode.PERSON_TRADEPWD_MODIFY);
			log.setMessage("个人联机支付密码修改");
			publicDao.save(log);
			TrServRec rec = para.getObject("rec",TrServRec.class);
			if( rec == null){
				rec = new TrServRec();
			}
			rec.setOldPwd(card.getPayPwd());//旧密码
			//TODO 目前在重置联机账户密码时不判断卡的状态
			//3.根据卡号、原密码判断原密码是否正确,如果正确新密码进行加密得到密文
			String oldPwd = doWorkClient.encrypt_PinPwd(card.getCardNo(),para.getString("oldPwd"));
			if(Tools.processNull(oldPwd).equals("")){
				throw new CommonException("原密码密文验证失败！");
			}
			List inParam = new ArrayList();
			inParam.add(card.getCardNo());
			inParam.add(oldPwd);
			List outParam = new ArrayList();
			outParam.add(java.sql.Types.VARCHAR);
			outParam.add(java.sql.Types.VARCHAR);
			List out = publicDao.callProc("pk_public.p_judgepaypwd",inParam,outParam);
			if(out != null && out.size() > 0){
				if(Integer.parseInt(out.get(0).toString()) != 0){
					throw new CommonException(out.get(1).toString());
				}
			}else{
				throw new CommonException("判断交易出现错误：返回null");
			}
			String newPwd = doWorkClient.encrypt_PinPwd(card.getCardNo(),para.getString("pwd"));
			if(Tools.processNull(newPwd).equals("")){
				throw new CommonException("密文加密失败！");
			}
			int updaterows = publicDao.doSql("update CARD_BASEINFO t set t.pay_pwd = '" + newPwd + "' where t.card_no = '" + card.getCardNo() + "'");
			if(updaterows != 1){
				throw new CommonException("联机账户密码修改出现错误，更新0行！");
			}
			//4.保存业务操作日志
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setCustomerName(bp.getName());
			rec.setCardId(card.getCardId());
			rec.setNote(log.getMessage());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setCardAmt(1L);
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setNewPwd(newPwd);
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			rec.setAgtTelNo(Tools.processNull(rec.getAgtTelNo()).equals("") ? bp.getMobileNo() : rec.getAgtTelNo());//如果代理电话为空,设置卡用户电话
			publicDao.save(rec);
			//5.保存报表
			/*JSONObject report = new JSONObject();
			report.put("p_Action_No",rec.getDealNo() + "");
			report.put("p_Type",this.findTrCodeNameByCodeType(rec.getDealCode()));
			report.put("p_Print_Time",DateUtil.formatDate(rec.getBizTime(),"yyyy-MM-dd HH:mm:ss"));
			report.put("p_Client_Id",rec.getCustomerName());
			report.put("p_Cert_Type",this.getCodeNameBySYS_CODE("CERT_TYPE",rec.getCertType()));
			report.put("p_Cert_No",rec.getCertNo());
			report.put("p_Operid",rec.getUserId());
			report.put("p_Brchid",rec.getBrchId());
			report.put("p_Agtname",rec.getAgtName());
			report.put("p_Agtcerttype",this.getCodeNameBySYS_CODE("CERT_TYPE",rec.getAgtCertType()));
			report.put("p_Agtcertno",rec.getAgtCertNo());
			report.put("p_Agttelno",rec.getAgtTelNo());
			this.saveSysReport(log,report,"/reportfiles/XiuGaiPwd.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);*/
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
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	public DoWorkClientService getDoWorkClient() {
		return doWorkClient;
	}
	public void setDoWorkClient(DoWorkClientService doWorkClient) {
		this.doWorkClient = doWorkClient;
	}
	
	
	@SuppressWarnings("unchecked")
	public Long saveSbPwd(String cardNo, String pwd, TrServRec rec)
			throws CommonException {
		try{

			CardBaseinfo tempcard = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
			BasePersonal bp = new BasePersonal();
			if(tempcard == null){
				throw new CommonException("卡片信息不存在，不能进行社保密码重置！");
			}else{
				if(!Tools.processNull(tempcard.getCustomerId()).equals("")){
					bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + tempcard.getCustomerId() + "'");
				}
			}
			//2.保存操作日志
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(DealCode.SB_PWD_MODIFY);
			log.setMessage("社保密码修改");
			publicDao.save(log);

			//3.记录业务日志
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setNote(log.getMessage());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setCardNo(cardNo);
			rec.setCustomerId(String.valueOf((bp.getCustomerId())));
			rec.setCustomerName(bp.getName());
			rec.setCertNo(bp.getCertNo());
			rec.setCertType(bp.getCertType());
			rec.setNewPwd(pwd);//新密码
			rec.setDealState(Constants.TR_STATE_ZC);
			publicDao.save(rec);
			
			// 记录业务凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "工本费：￥" + Arith.cardreportsmoneydiv("0"));
			json.put(ReceiptContants.FIELD.CARD_NO, rec.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, tempcard.getSubCardNo()); // 社保卡号
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
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
		return rec.getDealNo();
	}
	
	@SuppressWarnings("unchecked")
	public TrServRec sbPwdReset(JSONObject para, Users oper, SysActionLog log)
			throws CommonException {
		try{
			//1.基本信息判断
			if(para == null){
				throw new CommonException("社保密码重置,传入参数信息不能为空！");
			}
			if(oper == null){
				throw new CommonException("社保密码重置,操作柜员不能为空！");
			}
			if(log == null){
				throw new CommonException("社保密码重置,操作日志不能为空！");
			}
			if(Tools.processNull(para.getString("cardNo")).trim().equals("")){
				throw new CommonException("社保密码重置,卡号不能为空！");
			}
			if(Tools.processNull(para.getString("pwd")).trim().equals("")){
				throw new CommonException("社保密码重置,新密码不能为空！");
			}
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + para.getString("cardNo") + "'");
			BasePersonal bp = new BasePersonal();
			if(card == null){
				throw new CommonException("卡片信息不存在，不能进行社保密码重置！");
			}else{
				if(!Tools.processNull(card.getCustomerId()).equals("")){
					bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				}
			}
			//2.保存操作日志
			log.setDealCode(DealCode.SB_PWD_RESET);
			log.setMessage("社保密码重置");
			publicDao.save(log);
			TrServRec rec = para.getObject("rec",TrServRec.class);
			if( rec == null){
				rec = new TrServRec();
			}
			rec.setOldPwd(card.getPayPwd());//旧密码

			//3.保存业务操作日志
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setCardId(card.getCardId());
			rec.setNote(log.getMessage());
			rec.setCustomerName(bp.getName());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setCardAmt(1L);
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setNewPwd(para.getString("pwd"));
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			rec.setAgtTelNo(Tools.processNull(rec.getAgtTelNo()).equals("") ? bp.getMobileNo() : rec.getAgtTelNo());
			publicDao.save(rec);
			
			// 记录业务凭证
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

			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 服务密码错误次数重置
	 */
	@SuppressWarnings("unchecked")
	public TrServRec servpwdErrTimeReset(String certNo, Users oper, SysActionLog log)
			throws CommonException {
		try{
			//1.基本信息判断
			if(certNo == null){
				throw new CommonException("传入证件号不能为空");
			}
			BasePersonal bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.certNo = '" + certNo + "'");
			if(bp == null){
				throw new CommonException("无法查询到该人员信息");
			}
			publicDao.doSql("update BASE_PERSONAL t set t.serv_pwd_err_num ='0'  where t.cert_no ='"+certNo+"'");
			//2.保存操作日志
			log.setDealCode(DealCode.SPERSON_SERVICEPWD_RESET);
			log.setMessage("服务密码错误次数重置:用户身份证号=" + certNo);
			publicDao.save(log);
			TrServRec rec = new TrServRec();

			//3.保存业务操作日志
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage());
			rec.setCustomerName(bp.getName());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setCardAmt(1L);
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			publicDao.save(rec);

			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	
	/**
	 * 交易密码错误次数重置
	 */
	@SuppressWarnings("unchecked")
	public TrServRec dealpwdErrTimeReset(String cardNo, Users oper, SysActionLog log)
			throws CommonException {
		try{
			//1.基本信息判断
			if(cardNo == null){
				throw new CommonException("传入卡号不能为空");
			}
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
			BasePersonal bp = new BasePersonal();
			if(card == null){
				throw new CommonException("卡片信息不存在，不能进行社保密码重置！");
			}else{
				if(!Tools.processNull(card.getCustomerId()).equals("")){
					bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				}
			}
			String sql = "update CARD_BASEINFO t set t.PAY_PWD_ERR_NUM ='0'  where t.card_No ='"+cardNo+"'";
			publicDao.doSql(sql);
			//2.保存操作日志
			log.setDealCode(DealCode.SPERSON_SERVICEPWD_RESET);
			log.setMessage("交易密码错误次数重置:用户卡号=" + cardNo);
			publicDao.save(log);
			TrServRec rec = new TrServRec();

			//3.保存业务操作日志
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setCardId(card.getCardId());
			rec.setNote(log.getMessage());
			rec.setCustomerName(bp.getName());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setCardAmt(1L);
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			publicDao.save(rec);

			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
}
