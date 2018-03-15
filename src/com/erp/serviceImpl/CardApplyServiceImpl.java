/**
 * 
 */
package com.erp.serviceImpl;

import java.io.File;
import java.io.FileInputStream;
import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.BaseComm;
import com.erp.model.BaseCorp;
import com.erp.model.BasePersonal;
import com.erp.model.BasePersonalImportBatch;
import com.erp.model.BasePhoto;
import com.erp.model.BaseRegion;
import com.erp.model.CardApply;
import com.erp.model.CardApplyTask;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardConfig;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.SysPara;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.CardApplyService;
import com.erp.service.DoWorkClientService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.ReceiptContants;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**
 * 规模申领
 * @author yangn
 * @version 1.0
 * @email yn_yangning@foxmail.com
 * @date  2015-06-09
 */
@Service("cardApplyService")
@SuppressWarnings("unchecked")
public class CardApplyServiceImpl extends BaseServiceImpl implements CardApplyService  {
	public static boolean DEALCARDNO=false;//当前是否在处理卡号，true表示正在获取卡号，false表示已经获取卡号成功
	private Logger logger = Logger.getLogger(CardApplyServiceImpl.class);
	public static boolean DEAL_CARD_NO_WAIT = false;
	public static Long DEAL_CARD_NO_WAIT_TIMES = 1L;
    private DoWorkClientService doWorkClientService;
	/**
	 * 保存个人申领信息 
	 * @param actionLog
	 * @param person
	 * @param apply
	 * @param rec
	 * @param brch
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("rawtypes")
	public TrServRec saveOneCardApply(SysActionLog actionLog, BasePersonal person, CardApply apply, TrServRec serv) throws CommonException {
		try{
			logger.debug("个人申领【" + person.getCertNo() + "】");
			Users user = this.getUser();
			actionLog.setDealCode(DealCode.APPLY_TYPE_LXSL);
			actionLog.setMessage("申请制卡:网点:" + user.getBrchId() + ",证件号码:" + person.getCertNo());
			publicDao.save(actionLog);
			if(Tools.processNull(apply.getIsUrgent()).equals("1")){
				SysBranch tempBrch = this.getSysBranchByUserId();
				if(tempBrch == null){
					throw new CommonException("柜员网点信息不正确！");
				}
				List cardnoList = this.getCard_No(Tools.processNull(tempBrch.getRegionId()),null,Constants.CARD_TYPE_SMZK,actionLog.getDealNo(),1);
				apply.setCardNo(Tools.processNull(cardnoList.get(0)));
			}else if(Tools.processNull(apply.getIsUrgent()).equals("0")){
				apply.setCardNo("");
			}else{
				throw new CommonException("制卡方式不能为空！");
			}
			List<Object> in = new java.util.ArrayList<Object>();
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(user.getBrchId())).append("|");//1.受理点编号
			inpara.append(Tools.processNull(Constants.ACPT_TYPE_GM)).append("|");//2.受理点类型
			inpara.append(Tools.processNull(user.getUserId())).append("|");//3.操作员
			inpara.append(Tools.processNull(actionLog.getDealNo())).append("|");//4.操作流水
			inpara.append(Tools.processNull(person.getName())).append("|");//5.姓名
			inpara.append(Tools.processNull(person.getGender())).append("|");//6.性别
			inpara.append(Tools.processNull(person.getCertType())).append("|");//7.证件类型
			inpara.append(Tools.processNull(person.getCertNo())).append("|");//8.证件号码
			inpara.append(Tools.processNull(apply.getCardType())).append("|");//9.卡类型
			inpara.append(Tools.processNull(apply.getCardNo())).append("|");//10.卡号
			inpara.append(Tools.processNull(person.getNation())).append("|");//11.民族
			inpara.append(Tools.processNull(person.getResideType())).append("|");//12.户籍类型
			inpara.append(Tools.processNull(person.getRegionId())).append("|");//13.户籍所在城区
			inpara.append(Tools.processNull(person.getTownId())).append("|");//14.乡镇（街道）
			inpara.append(Tools.processNull(person.getCommId())).append("|");//15.社区（村）
			inpara.append(Tools.processNull(person.getResideAddr())).append("|");//16.居住地址
			inpara.append(Tools.processNull(person.getLetterAddr())).append("|");//17.通信地址
			inpara.append(Tools.processNull(person.getPostCode())).append("|");//18.邮政编码
			inpara.append(Tools.processNull(person.getTelNos())).append("|");//19.固定电话
			inpara.append(Tools.processNull(person.getMobileNo())).append("|");//20.手机号码
			inpara.append(Tools.processNull(person.getEmail())).append("|");//21.电子邮件
			inpara.append(Tools.processNull("")).append("|");//22.单位名称
			inpara.append(Tools.processNull("")).append("|");//23.备注
			inpara.append(Tools.processNull(apply.getCostFee())).append("|");//24.工本费
			inpara.append(Tools.processNull(apply.getUrgentFee())).append("|");//25.加急费
			inpara.append(Tools.processNull(apply.getAgtCertType())).append("|");//26.代理人证件类型
			inpara.append(Tools.processNull(apply.getAgtCertNo())).append("|");//27.代理人证件号码
			inpara.append(Tools.processNull(apply.getAgtName())).append("|");//28.代理人姓名
			inpara.append(Tools.processNull(apply.getAgtPhone())).append("|");//29.代理人电话
			inpara.append(Tools.processNull(this.getSysConfigurationParameters("IS_PHOTO")).equals("") ? "0" : this.getSysConfigurationParameters("IS_PHOTO")).append("|");//30.是否判断照片
			//inpara.append(Tools.processNull(this.getSysConfigurationParameters("IS_JUDGE_SB")).equals("") ? "0" : this.getSysConfigurationParameters("IS_JUDGE_SB")).append("|");//31.是否判断参保
			inpara.append(Tools.processNull(serv.getDealState()).equals("0") ? "0" : "1").append("|");//31.是否判断参保
			inpara.append(Tools.processNull(apply.getIsUrgent())).append("|");//32.制卡类型
			inpara.append(Tools.processNull(apply.getBusType())).append("|");//33.公交类型
			inpara.append(Tools.processNull(apply.getBankId())).append("|");//34.银行编号
			inpara.append(Tools.processNull(apply.getBankCardNo())).append("|");//35.银行卡卡号
			inpara.append(Tools.processNull(this.getBrchRegion())).append("|");//36.统筹区域编号
			inpara.append(Tools.processNull(actionLog.getMessage())).append("|");//37 备注
			inpara.append(Tools.processNull(apply.getRecvBrchId())).append("|");//38 领卡网点
			in.add(inpara.toString());
			in.add(1);
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			List ret = publicDao.callProc("pk_card_apply_issuse.p_applyCard",in,out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(1).toString());
				if (res != 0) {
					String outMsg = ret.get(2).toString();
					throw new CommonException(outMsg);
				}
			} else {
				throw new CommonException("申领出现错误信息！");
			}
			logger.debug("个人申领【" + person.getCertNo() + "】本地成功");
			String[] retOnePara = ret.get(0).toString().split("\\|");
			serv = (TrServRec)this.findOnlyRowByHql("from TrServRec c where c.dealNo = '" + retOnePara[0] + "'");// and c.certNo = '" + person.getCertNo() + "' and c.dealCode = " + DealCode.APPLY_TYPE_LXSL);
			if(serv == null){
				throw new CommonException("获取业务出现错误，根据流水" + retOnePara[0] + "找不到业务日志信息！");
			}
			SysBranch lkBrch = null;
			if(!Tools.processNull(apply.getRecvBrchId()).equals("")){
				lkBrch = (SysBranch) findOnlyRowByHql("from SysBranch where brchId = '" + apply.getRecvBrchId() + "'");
			} else {
				lkBrch = (SysBranch) findOnlyRowByHql("from SysBranch where brchId = '" + actionLog.getBrchId() + "'");
			}
			logger.debug("个人申领【" + person.getCertNo() + "】保存凭证");
			//保存业务凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, actionLog.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(actionLog.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "工本费：￥" + Arith.cardreportsmoneydiv(Tools.processNull(apply.getCostFee())) + " / 押金：￥" + Arith.cardreportsmoneydiv(Tools.processNull(apply.getForegift()).equals("") ? "0" : apply.getForegift() + ""));
			json.put(ReceiptContants.FIELD.CARD_NO, apply.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, apply.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, person.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, person.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, apply.getAgtName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", apply.getAgtCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, apply.getAgtCertNo()); // 代理人证件号码
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			json.put("p_lk_brch", lkBrch.getFullName());
			json.put("p_lk_brch_addr", lkBrch.getBrchAddress()); 
			this.saveSysReport(actionLog, json, "/reportfiles/CardApply.jasper", Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
			//调银行接口
			logger.debug("个人申领【" + person.getCertNo() + "】发银行审核");
            if(Tools.processNull(apply.getCardType()).equals(Constants.CARD_TYPE_SMZK) && Tools.processNull(apply.getIsUrgent()).equals(Constants.YES_NO_YES)){
                String certType = "10";
                if(Constants.CERT_TYPE_SFZ.equals(person.getCertType())){
                	certType = "01";
                } else if(Constants.CERT_TYPE_JGZ.equals(person.getCertType())){
                	certType = "02";
                } else if(Constants.CERT_TYPE_HZ.equals(person.getCertType())){
                	certType = "03";
                }
            	JSONArray array = new JSONArray();
                JSONObject one = new JSONObject();
                one.put("bizid",Tools.processNull(apply.getBankId()));
                one.put("termid",user.getUserId());
                one.put("termno",retOnePara[1]);
                one.put("name",person.getName());
                one.put("certtype",certType);
                one.put("certno",person.getCertNo());
                one.put("birthday",person.getBirthday());
                one.put("sex",person.getGender());
                one.put("phone",person.getMobileNo());
                one.put("trcode","B0712");
                one.put("cardno",retOnePara[2]);
                one.put("address",person.getLetterAddr());
                one.put("bankbrchid",lkBrch.getBrchId());
                array.add(one);
                JSONArray outs = this.doWorkClientService.invoke(array);
                if(outs == null || outs.size() < 1){
                    throw new CommonException("调取银行接口返回为空！");
                }
                JSONObject res = new JSONObject();
                res = (JSONObject) outs.get(0);
                if(!Tools.processNull(res.getString("errcode")).equals("00")){
                    throw new CommonException("调取银行接口出现错误，" + res.getString("errmessage"));
                }
            }
            logger.debug("个人申领【" + person.getCertNo() + "】成功");
			return serv;
		}catch(Exception e){
			logger.error("个人申领【" + person.getCertNo() + "】失败，" + e.getMessage());
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 规模制卡数据生成
	 * @param StringBuffer   sql   人员信息限制性语句
	 * @param CardApplyTask  task  本次申领任务
	 * @param SysActionLog   log   申领操作日志
	 * @param Users          oper  申领制卡操作员
	 */
	public TrServRec saveBatchApply(StringBuffer limitPersons,CardApplyTask task,CardConfig config,SysActionLog log,Users oper) throws CommonException {
		try{
			//1.基本条件判断
			String city_code = Tools.tensileString(this.findOnlyFieldBySql("SELECT T.PARA_VALUE FROM SYS_PARA T WHERE T.PARA_CODE = 'CITY_CODE'").toString(),4,true,"0");
			if(Tools.processNull(city_code).trim().equals("")){
				throw new CommonException("城市代码不能为空，SYS_PARA中找不到参数CITY_CODE");
			}
			Object[] branch_card_flag = (Object[])this.findOnlyRowBySql("SELECT B.CARD_FLAG,B.REGION_CODE FROM SYS_BRANCH S,BASE_REGION B WHERE S.REGION_ID = B.REGION_ID AND S.BRCH_ID = '" + oper.getBrchId() + "'");           
			if(branch_card_flag == null || branch_card_flag.length <= 0){
				throw new CommonException("网点所属区域或区域区编码设置不正确！");
			}
			if(Tools.processNull(branch_card_flag[0]).equals("")){
				throw new CommonException("网点所属区域的CARD_FLAG字段设置不正确！");
			}
			if(Tools.processNull(branch_card_flag[1]).equals("")){
				throw new CommonException("网点所属区域的REGION_CODE字段设置不正确！");
			}
			try{
				String lockId = "";
				if(Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_SQ)){
					lockId = city_code + Tools.processNull(task.getRegionId()) + Tools.processNull(task.getTownId()) + Tools.processNull(task.getCommId());
				}else if(Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_DW)){
					lockId = city_code + Tools.processNull(task.getCorpId());
				}else if(Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_XX)){
					
				}else{
					throw new CommonException("批量申领的任务组织方式不正确！");
				}
				BigDecimal lock = (BigDecimal) this.findOnlyFieldBySql("SELECT COUNT(1) FROM SYS_BUSI_LOCK T WHERE T.BUSI_KEY = '" + lockId + "'");
				if(lock.intValue() <= 0){
					int lockRows = publicDao.doSql("INSERT INTO SYS_BUSI_LOCK(BUSI_KEY,DEAL_CODE,ORG_ID,BRCH_ID,OPER_ID,INSERT_TIME) VALUES('" + lockId + "','" + DealCode.APPLY_TYPE_GMSL + "',"
					+ "'" + this.getUser().getOrgId() + "','" + this.getUser().getBrchId() + "','" + this.getUser().getUserId() + "',SYSDATE)");
					if(lockRows != 1){
						throw new CommonException("锁定本次申领信息时出现错误，请稍候进行重试！");
					}
					publicDao.doSql("commit");
				}
				publicDao.doSql("SELECT * FROM SYS_BUSI_LOCK T WHERE T.BUSI_KEY = '" + lockId + "' FOR UPDATE WAIT 30");
			}catch(Exception e){
				throw new CommonException("批量申领时获取业务锁出现错误" + e.getMessage());
			}
			//2.设置领卡网点
			String tip = this.getCodeNameBySYS_CODE("CARD_TYPE",task.getCardType());
			if(Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_DW)){
				SysBranch brch = null;
				BaseCorp corp = (BaseCorp) this.findOnlyRowByHql("from BaseCorp t where t.customerId = '" + task.getCorpId() + "'");
				if(corp == null){
					throw new CommonException("根据单位编号" + task.getCorpId() + "未找到申领单位信息！");
				}
				if(Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_SMZK)){
					if(Tools.processNull(corp.getLkBrchId()).equals("")){
						throw new CommonException("申领单位【" + corp.getCorpName() + "】的" + tip + "领卡网点信息未设置！");
					}
					brch =  (SysBranch) this.findOnlyRowByHql("from SysBranch t where t.brchId = '" + corp.getLkBrchId() + "'");
					if(brch == null){
						throw new CommonException("申领单位【" + corp.getCorpName() + "】设置的" + tip + "领卡网点不存在！");
					}
					task.setBrchId(corp.getLkBrchId());
				}else if(Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_QGN)){
					if(Tools.processNull(corp.getLkBrchId2()).equals("")){
						throw new CommonException("申领单位【" + corp.getCorpName() + "】的" + tip + "领卡网点信息未设置！");
					}
					brch =  (SysBranch) this.findOnlyRowByHql("from SysBranch t where t.brchId = '" + corp.getLkBrchId2() + "'");
					if(brch == null){
						throw new CommonException("申领单位【" + corp.getCorpName() + "】设置的" + tip + "领卡网点不存在！");
					}
					task.setBrchId(corp.getLkBrchId2());
				}else{
					throw new CommonException("申领卡类型设置不正确！");
				}
			}else if(Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_SQ)){
				BaseComm comm = (BaseComm) this.findOnlyRowByHql("from BaseComm t where t.commId = '" + task.getCommId() + "'");
				if(comm == null){
					throw new CommonException("根据社区（村）编号" + task.getCommId() + "未找到社区（村）信息");
				}
				if(Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_SMZK)){
					if(Tools.processNull(comm.getLkBrchId()).equals("")){
						throw new CommonException("【" + comm.getCommName() + "】社区（村）的" + tip + "领卡网点信息未设置！");
					}
					SysBranch brch =  (SysBranch) this.findOnlyRowByHql("from SysBranch t where t.brchId = '" + comm.getLkBrchId() + "'");
					if(brch == null){
						throw new CommonException("【" + comm.getCommName() + "】社区（村）设置的" + tip + "领卡网点不存在！");
					}
					task.setBrchId(comm.getLkBrchId());
				}else if(Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_QGN)){
					if(Tools.processNull(comm.getLkBrchId2()).equals("")){
						throw new CommonException("【" + comm.getCommName() + "】社区（村）的" + tip + "领卡网点信息未设置！");
					}
					SysBranch brch =  (SysBranch) this.findOnlyRowByHql("from SysBranch t where t.brchId = '" + comm.getLkBrchId2() + "'");
					if(brch == null){
						throw new CommonException("【" + comm.getCommName() + "】社区（村）设置的" + tip + "领卡网点不存在！");
					}
					task.setBrchId(comm.getLkBrchId2());
				}else{
					throw new CommonException("申领卡类型设置不正确！");
				}
			}else{
				throw new CommonException("其他申领方式暂未获得支持！");
			}
			if(Tools.processNull(task.getBrchId()).equals("")){
				throw new CommonException(task.getTaskName() + "设置的" + tip + "领卡网点不正确！");
			}
			if(Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_SMZK)){
				String shBankId = (String) this.findOnlyFieldBySql("select bank_id from branch_bank where brch_id = '" + task.getBrchId() + "'");
				if(Tools.processNull(shBankId).equals("")){
					throw new CommonException(task.getTaskName() + "设置的领卡网点未绑定银行！");
				}
				task.setBankId(shBankId);
				String bankName = (String) this.findOnlyFieldBySql("select co_org_name from base_co_org where co_org_id = '" + shBankId + "'");
				if(Tools.processNull(bankName).equals("")){
					throw new CommonException(task.getTaskName() + "领卡网点绑定的银行信息不存在！");
				}
			}
			//3.记录本次的操作日志信息
			log.setInOutData(log.getInOutData().length() > 500 ? log.getInOutData().substring(0, 500) + "...." : log.getInOutData());
			log.setDealCode(DealCode.APPLY_TYPE_GMSL);
			log.setMessage("规模申领 ," + task.getTaskName());
			task.setTaskDate(log.getDealTime());
			publicDao.save(log);	
			if(!Tools.processNull(task.getIsBatchHf()).equals("0") && !Tools.processNull(task.getIsBatchHf()).equals("1")){
				throw new CommonException("是否批量换发标志不正确！");
			}
			if(!Tools.processNull(task.getIsJudgeSbState()).equals("0") && !Tools.processNull(task.getIsJudgeSbState()).equals("1")){
				throw new CommonException("是否判断医保状态标志不正确！");
			}
			//4.删除临时表上次已过期申领信息
			publicDao.doSql("DELETE FROM CARD_APPLY_GMSL_TEMP T WHERE T.APPLY_USER_ID = '" + oper.getUserId() + "'");
			StringBuffer slsql = new StringBuffer();
			slsql.append("INSERT INTO CARD_APPLY_GMSL_TEMP (APPLY_ID,BAR_CODE,CUSTOMER_ID,CARD_NO,SUB_CARD_NO,CARD_TYPE,BANK_ID,VERSION,ORG_CODE,");
			slsql.append("CITY_CODE,INDUS_CODE,APPLY_WAY,APPLY_TYPE,MAKE_TYPE,APPLY_BRCH_ID,CORP_ID,COMM_ID,TOWN_ID,APPLY_STATE,APPLY_USER_ID,");
			slsql.append("APPLY_DATE,COST_FEE,FOREGIFT,IS_URGENT,URGENT_FEE,IS_PHOTO,RECV_BRCH_ID,BUS_TYPE, MAIN_FLAG, OTHER_FEE, WALLET_USE_FLAG,DEAL_NO,BKVEN_ID,GROUP_ID,MED_WHOLE_NO,IS_BATCH_HF,IS_JUDGE_SB_STATE) ");
			//5.符合本次申领条件的限制语句
			slsql.append("SELECT SEQ_APPLY_ID.NEXTVAL,LPAD(SEQ_BAR_CODE.NEXTVAL,9,'0'),B.CUSTOMER_ID,'");
			//slsql.append("(case when b.reside_Type = 0 then r.region_Code else '" + branch_card_flag[1].toString() + "' end),");
			slsql.append(Tools.processNull(branch_card_flag[1]) + "',");
			if(Tools.processNull(task.getIsBatchHf()).equals(Constants.YES_NO_YES)){
				slsql.append("(NVL(PK_CARD_APPLY_ISSUSE.P_GETLASTSUBCARDNO(B.CUSTOMER_ID),PK_PUBLIC.CREATESUBCARDNO('" + branch_card_flag[0] + "',LPAD(SEQ_SUB_CARD_NO.NEXTVAL,7,'0')))),'");
			}else{
				slsql.append("PK_PUBLIC.CREATESUBCARDNO('" + branch_card_flag[0] + "',LPAD(SEQ_SUB_CARD_NO.NEXTVAL,7,'0')),'");
			}
			slsql.append(task.getCardType() + "','" + Tools.processNull(task.getBankId()) + "','" + Constants.CARD_VERSION + "','" + Constants.INIT_ORG_ID + "','" + city_code + "','");
			slsql.append(Constants.INDUS_CODE + "','" + task.getTaskWay() + "','" + Constants.APPLY_TYPE_CCSL + "','" + "1" + "','");//是否加急
			slsql.append(oper.getBrchId() + "','" + Tools.processNull(task.getCorpId()) + "',B.COMM_ID,B.TOWN_ID,'");
			slsql.append(Constants.APPLY_STATE_RWYSC + "','" + oper.getUserId() + "',to_date('");
			slsql.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','yyyy-MM-dd HH24:mi:ss'),0,0,'" + task.getIsUrgent() + "',0,'" + Tools.processNull(task.getIsPhoto()) + "','" + Tools.processNull(task.getBrchId()) + "',");
			slsql.append("'00'");//公交类型
			//slsql.append("(CASE WHEN MONTHS_BETWEEN(SYSDATE,TO_DATE(SUBSTR(B.CERT_NO,7,8),'YYYYMMDD')) >= 840 THEN '20' ");
			//slsql.append("WHEN MONTHS_BETWEEN(SYSDATE,TO_DATE(SUBSTR(B.CERT_NO,7,8),'YYYYMMDD')) >= 720 THEN '11'  WHEN MONTHS_BETWEEN(SYSDATE,TO_DATE(SUBSTR(B.CERT_NO,7,8),'YYYYMMDD')) < 216 THEN '10' ELSE '01' END)");
			slsql.append(",'',0,'" + Constants.BUS_USE_FLAG_QB + "'," + log.getDealNo() + ",'" + Tools.processNull(task.getVendorId()) + "','" + Tools.processNull(task.getGroup_Id()) + "','" + this.getBrchRegion() + "','" + task.getIsBatchHf() + "','" + task.getIsJudgeSbState() + "' ");
			slsql.append("FROM BASE_PERSONAL B " );
			if(Tools.processNull(task.getIsJudgeSbState()).equals(Constants.YES_NO_YES)){
				slsql.append(",BASE_SIINFO F ");
			}
			if(Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_SQ)){
				slsql.append(",BASE_REGION R,BASE_TOWN W,BASE_COMM M ");
			}
			//slsql.append("WHERE B.SURE_FLAG = '0' AND B.CUSTOMER_STATE = '0' AND B.CERT_NO = F.CERT_NO AND B.NAME = F.NAME AND F.MED_STATE = '0' AND F.MED_WHOLE_NO = '" + this.getBrchRegion() + "' ");
			if(Tools.processNull(task.getIsJudgeSbState()).equals(Constants.YES_NO_YES)){
				slsql.append("WHERE /*B.SURE_FLAG = '0' AND*/ B.CUSTOMER_STATE = '0' AND B.CERT_NO = F.CERT_NO AND B.NAME = F.NAME AND F.MED_STATE = '0' AND F.MED_WHOLE_NO = '" + this.getBrchRegion() + "' ");
			}else{
				slsql.append("WHERE /*B.SURE_FLAG = '0' AND*/ B.CUSTOMER_STATE = '0' ");
			}
			if(Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_SQ)){
				slsql.append("AND B.REGION_ID = R.REGION_ID AND B.TOWN_ID = W.TOWN_ID AND B.COMM_ID = M.COMM_ID AND R.REGION_ID = W.REGION_ID AND W.TOWN_ID = M.TOWN_ID ");
			}
			slsql.append("AND NOT EXISTS(SELECT 1 FROM CARD_APPLY A WHERE A.CUSTOMER_ID = B.CUSTOMER_ID ");
			slsql.append("AND (A.APPLY_STATE < '" + Constants.APPLY_STATE_YZX + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_WJWSHBTG + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_YZX  + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_YHSHBTG + "' ");
			if(Tools.processNull(task.getIsBatchHf()).equals(Constants.YES_NO_YES)){
				slsql.append("and a.card_type = '" + Constants.CARD_TYPE_SMZK + "'");
			}
			slsql.append(")) ");
			if(Tools.processNull(task.getIsBatchHf()).equals(Constants.YES_NO_YES)){
				slsql.append("and exists (select 1 from card_baseinfo p where p.customer_id = b.customer_id and p.card_state < '9' and p.card_type = '" + Constants.CARD_TYPE_QGN + "') ");
			}
			if(Tools.processNull(task.getIsPhoto()).equals(Constants.YES_NO_YES)){
				slsql.append("AND EXISTS (SELECT 1 FROM BASE_PHOTO P WHERE P.CUSTOMER_ID = B.CUSTOMER_ID AND P.PHOTO_STATE = '0' AND LENGTHB(P.PHOTO) > 0) ");
			}
			slsql.append(limitPersons);//申领人员限制性语句
			//6.申领信息预处理
			int allCount = publicDao.doSql(slsql.toString());
			if(allCount == 0){
				throw new CommonException("共有 0 个人员符合申领条件，本次操作无效，请仔细核对后重新进行操作！");
			}
			int region_Code_Count = publicDao.findBySQL("SELECT 1 FROM CARD_APPLY_GMSL_TEMP WHERE LENGTH(CARD_NO) != 2 AND APPLY_USER_ID = '" + oper.getUserId() + "' AND DEAL_NO = " + log.getDealNo()).size();
			if(region_Code_Count != 0){
				throw new CommonException("当前申领人员中有\"" + region_Code_Count + "\"个人所在区县编号为空，请先设置城区编码");
			}
			//7.对规模申领临时表进行预处理
			task.setTaskSum(allCount);//更新本次任务符合条件申领的总人数 //生成任务编号  yyyymmdd+8位序列号
			task.setTaskId(DateUtil.formatDate(log.getDealTime(),"yyyyMMdd") + Tools.tensileString(this.getSequenceByName("SEQ_CM_CARD_TASK"),8,true,"0"));// //生成任务编号  yyyymmdd+8位序列号
			task.setTaskDate(log.getDealTime());//任务产生时间
			task.setDealNo(log.getDealNo());//取业务日志序列号（SEQ_ACTON_NO）
			task.setDealCode(log.getDealCode());
			//task.setBrchId(oper.getBrchId());
			task.setTaskState(Constants.TASK_STATE_YSC);
			task.setTaskBrchId(oper.getBrchId());
			task.setTaskOperId(oper.getUserId());
			task.setTaskOrgId(oper.getOrgId());
			//task.setBankId(Tools.processNull(this.findOnlyFieldBySql("SELECT BANK_ID FROM BRANCH_BANK WHERE BRCH_ID = '" + task.getBrchId() + "'")));
			task.setMedWholeNo(this.getBrchRegion());//任务所属的统筹区域
			publicDao.save(task);
			publicDao.doSql("UPDATE CARD_APPLY_GMSL_TEMP C SET C.TASK_ID = " + task.getTaskId() + " WHERE APPLY_USER_ID = '" + oper.getUserId() + "' AND DEAL_NO = " + log.getDealNo());
			//8.判断制卡方式 0 本地制卡不生成卡号  1 外包制卡 需要生成卡号
			if(Tools.processNull(task.getIsUrgent()).equals(Constants.URGENT_WB)){
				List<?> cardno = this.findBySql("SELECT CARD_TYPE,CARD_NO,COUNT(1) FROM CARD_APPLY_GMSL_TEMP t WHERE t.APPLY_USER_ID = '" + oper.getUserId() + "' and DEAL_NO = " + log.getDealNo() + " GROUP BY CARD_TYPE,CARD_NO ");
				for(int n = 0;n < cardno.size();n++){
					Object[] o = (Object[])cardno.get(n);
					try{
						this.createCardNo(Tools.processNull(o[0]),o[1].toString(),((BigDecimal)(o[2])).longValue(),log.getDealNo());
					}catch(Exception e){
						throw new CommonException(e.getMessage());
					}finally{
						DEAL_CARD_NO_WAIT = false;
					}
					String updatecardno = "MERGE INTO CARD_APPLY_GMSL_TEMP D USING (SELECT A.CARD_NO,B.APPLY_ID FROM (SELECT CARD_NO,ROWNUM RN " +
					"FROM CARD_NO WHERE USED = 0  AND DEAL_NO = " + log.getDealNo() +
					") A, (SELECT APPLY_ID,ROWNUM RN FROM CARD_APPLY_GMSL_TEMP WHERE  CARD_TYPE = '" + o[0] +
					"' AND DEAL_NO = " + log.getDealNo() + ") B WHERE A.RN = B.RN) C ON (D.APPLY_ID = C.APPLY_ID) WHEN MATCHED THEN UPDATE SET D.CARD_NO = C.CARD_NO";
					publicDao.doSql(updatecardno);
				}
			}else if(Tools.processNull(task.getIsUrgent()).equals(Constants.URGENT_BD)){
				publicDao.doSql("UPDATE CARD_APPLY_GMSL_TEMP T SET T.CARD_NO = '' WHERE T.TASK_ID = '" + task.getTaskId() + "' AND DEAL_NO = " + log.getDealNo());
			}
			//9.规模申领临时表数据移动到正式申领表 
			StringBuffer insertApplySql = new StringBuffer();
			insertApplySql.append("INSERT INTO CARD_APPLY (APPLY_ID, BAR_CODE, CUSTOMER_ID,CARD_NO,TASK_ID,SUB_CARD_NO,CARD_TYPE,SUB_CARD_TYPE, ");
			insertApplySql.append("BANK_ID, BANK_CARD_NO, VERSION, ORG_CODE, CITY_CODE, INDUS_CODE, APPLY_WAY, APPLY_TYPE, MAKE_TYPE, APPLY_BRCH_ID, CORP_ID,");
			insertApplySql.append("APPLY_STATE, APPLY_USER_ID, APPLY_DATE, COST_FEE, FOREGIFT, IS_URGENT, IS_PHOTO, RECV_BRCH_ID,");
			insertApplySql.append("RECV_CERT_TYPE, RECV_CERT_NO, RECV_NAME, RELS_BRCH_ID, RELS_USER_ID, RELS_DATE, AGT_CERT_TYPE, AGT_CERT_NO, AGT_NAME,");
			insertApplySql.append("AGT_PHONE, DEAL_NO, NOTE, BUS_TYPE, OLD_CARD_NO, OLD_SUB_CARD_NO, MESSAGE_FLAG, MOBILE_PHONE, MAIN_FLAG, MAIN_CARD_NO,");
			insertApplySql.append("OTHER_FEE, WALLET_USE_FLAG, MONTH_TYPE, MONTH_CHARGE_MODE,TOWN_ID,COMM_ID,GROUP_ID,BKVEN_ID,MED_WHOLE_NO,IS_BATCH_HF,IS_JUDGE_SB_STATE) ");
			// select 
			insertApplySql.append("SELECT T.APPLY_ID,T.BAR_CODE,T.CUSTOMER_ID,T.CARD_NO,T.TASK_ID,T.SUB_CARD_NO,");
			insertApplySql.append("T.CARD_TYPE,T.SUB_CARD_TYPE,T.BANK_ID,T.BANK_CARD_NO,T.VERSION,T.ORG_CODE,T.CITY_CODE,T.INDUS_CODE,T.APPLY_WAY,");
			insertApplySql.append("T.APPLY_TYPE,T.MAKE_TYPE,T.APPLY_BRCH_ID,T.CORP_ID,T.APPLY_STATE,T.APPLY_USER_ID,T.APPLY_DATE,");
			insertApplySql.append("T.COST_FEE,T.FOREGIFT,T.IS_URGENT,T.IS_PHOTO,T.RECV_BRCH_ID,T.RECV_CERT_TYPE,T.RECV_CERT_NO,T.RECV_NAME,T.RELS_BRCH_ID,");
			insertApplySql.append("T.RELS_USER_ID,T.RELS_DATE,T.AGT_CERT_TYPE,T.AGT_CERT_NO,T.AGT_NAME,T.AGT_PHONE,T.DEAL_NO,NULL,'00',");//嘉兴公交类型00
			insertApplySql.append("T.OLD_CARD_NO,T.OLD_SUB_CARD_NO,T.MESSAGE_FLAG,T.MOBILE_PHONE,T.MAIN_FLAG,T.MAIN_CARD_NO,T.OTHER_FEE,T.WALLET_USE_FLAG,T.MONTH_TYPE,");
			insertApplySql.append("T.MONTH_CHARGE_MODE,T.TOWN_ID,T.COMM_ID,T.GROUP_ID,T.BKVEN_ID,T.MED_WHOLE_NO,T.IS_BATCH_HF,T.IS_JUDGE_SB_STATE FROM CARD_APPLY_GMSL_TEMP T WHERE T.APPLY_USER_ID = '" + oper.getUserId() + "' AND T.DEAL_NO = " + log.getDealNo());
			publicDao.doSql(insertApplySql.toString());
			//10.生成制卡明细
			insertCardtasklist(task,config);
            if(this.getSysConfigurationParameters("madeCard_flag").equals("0")){//#申领数据是否导出0导出,1不导出
            	insertPersonalApply(task,oper);
			}
            //插入社保明细
            if(this.getSysConfigurationParameters("Apply_Sb_Flag").equals("01111")){//#申领数据是否导出给社保明细0导出,1不导出
            	insertCardtasklist_Sb(task);
			}
            //插入卫生明细
            if(this.getSysConfigurationParameters("Apply_Ws_Flag").equals("0")){//#申领数据是否导出给卫生明细0导出,1不导出
            	insertCardtasklist_Ws(task);
			}
			//11.更新补充任务相关信息
			Object[] o =(Object[])this.findOnlyRowBySql("select min(card_no),max(card_no)  from card_task_list l where l.task_id = '" + task.getTaskId() + "'");
			task.setStartCardNo(Tools.processNull(o[0]));
			task.setEndCardNo(Tools.processNull(o[1]));
			publicDao.update(task);
			//12.是否计算工本费；待定  
			
			//13.记录业务日志
			TrServRec rec = new  TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setNote(log.getMessage());
			rec.setCardType(task.getCardType());
			rec.setCardAmt(Long.valueOf(task.getTaskSum() + ""));
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Constants.TR_STATE_ZC);
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	
	/**
	 * <h3>根据任务号插入制卡数据明细表<h3>
	 * @param CardApplyTask task 当前任务
	 */
	public void insertCardtasklist(CardApplyTask task,CardConfig para)throws CommonException{
		try{
			//CardConfig para = (CardConfig) this.findOnlyRowByHql("from CardConfig t where t.cardType = '" + task.getCardType() + "'");
			if(para == null){
				throw new CommonException("该卡类型参数设置信息不存在！");
			}
			//1.获取指定卡类型相关的参数信息
			if(Tools.processNull(para.getCardValidityPeriod()).equals("")){
				throw new CommonException("该卡类型卡片有效期年数信息未设置！" + para.getCardType());
			}
			String city_code = Tools.tensileString(this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'CITY_CODE'").toString(),4,true,"0");
			if(Tools.processNull(city_code).trim().equals("")){
				throw new CommonException("城市代码不能为空，SYS_PARA中找不到参数CITY_CODE");
			}
			String month_Type = this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'MONTH_TYPE'").toString();
			if(Tools.processNull(month_Type).trim().equals("")){
				month_Type = "00";
			}
			String ndate = DateUtil.formatDate(task.getTaskDate(),"yyyyMMdd");//卡片发行日期,钱包应用启用日期
			String lsdate = DateUtil.processDateAddYear(DateUtil.formatDate(task.getTaskDate(),"yyyy-MM-dd"),para.getCardValidityPeriod()).replaceAll("-","");//根据设置参数计算卡片有效期限 格式:YYYYMMDD
			//密码规则   1随机生成;0默认固定密码
			String pwd_rule = this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'PWD_RULE'").toString();//开通交易密码规则，0常数，1随机
			if(Tools.processNull(pwd_rule).trim().equals("")){
				pwd_rule = "0";
			}
			//如果是固定密码,则获取固定的初始密码
			String initpwd = this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'INITPWD'").toString();
			if(Tools.processNull(initpwd).trim().equals("")){
				initpwd = "888888";
			}
			//2.定义生成制卡明细的sql语句
			StringBuffer exesql = new StringBuffer();
			exesql.append("insert into card_task_list(data_seq,task_id,customer_id,name,sex,cert_type,cert_no,");
			exesql.append("nation,birthplace,birthday,reside_type,reside_addr,letter_addr,post_code,mobile_no,education,");
			exesql.append("marr_state,card_type,card_no,version,init_org_id,city_code,indus_code,cardissuedate,validitydate,bursestartdate,");
			exesql.append("bursevaliddate,monthstartdate,monthvaliddate,struct_main_type,struct_child_type,face_val,pwd,");
			exesql.append("bar_code,comm_id,bursebalance,monthbalance,bank_id,bankcardno,banksection2,banksection3,photofilename,");
			exesql.append("useflag,department,classid,apply_id,month_type,hlht_flag,sub_card_no,touch_startdate,touch_validdate,group_id,bkven_id)");
			//select 
			exesql.append("(select seq_data_seq.nextval,a.task_Id,b.customer_id,b.name,b.gender,b.cert_Type,b.cert_No,b.nation,'',");
			//substr(b.cert_no,7,8)
			exesql.append("replace(b.birthday,'-',''),b.reside_type,replace(b.reside_addr,'|',''),replace(b.letter_addr,'|',''),b.post_code,b.mobile_no,b.education,");
			exesql.append("b.marr_state,a.card_type,a.card_No,a.version,a.org_code,a.city_code,a.indus_code,'");
			//cardissuedate  validitydate  bursestartdate  bursevaliddate monthstartdate  monthvaliddate
			//发卡日期、               卡片有效期、         钱包应用开始日期、钱包应用有效日期、月票开始日期、          月票有效期限
			exesql.append(ndate + "','" + lsdate + "','" + ndate + "','" + lsdate + "','" + ndate + "','" + ndate + "','" + Tools.processNull(para.getStructMainType()) + "','" + Tools.processNull(para.getStructChildType()) + "',nvl(");
			exesql.append(para.getFaceVal() + ",'0')," + (Tools.processNull(pwd_rule).equals("0") ? "'" + initpwd + "'" : "ceil(dbms_random.value(100000,999999))") + ",");
			exesql.append("a.bar_code,b.comm_id,'" + Constants.BURSEBALANCE+"','" + Constants.MONTHBALANCE + "',");
			exesql.append("a.bank_id,a.bank_card_no,'','',b.cert_No||'.jpg','" + Constants.USED_FLAG);
			exesql.append("',b.department,b.classid,a.apply_Id,'" + month_Type + "','" + city_code + "',a.Sub_Card_No,'" + ndate + "','" + lsdate+"',a.group_id,a.BKVEN_ID ");
			exesql.append(" from card_apply a ,base_personal b where b.customer_id = a.customer_id  ");
			exesql.append(" and a.apply_state = '" + Constants.APPLY_STATE_RWYSC + "' and a.task_id = '" + task.getTaskId() + "')");
			//3.生成制卡明细
			int c = publicDao.doSql(exesql.toString());
			//4.处理证件类型、婚姻状况
			publicDao.doSql("update card_task_list c set c.marr_State = (decode(c.marr_State,'10','1','20','2','21','2','22','2','23','2','30','3','40','4','10'))  where c.TASK_ID = '" + task.getTaskId() + "'");
			int ci = publicDao.doSql("update card_task_list c set c.cert_typed = (decode(c.cert_type,'1','00','2','05','3','01','4','02','5','04','6','05','05')) where c.TASK_ID = '" + task.getTaskId() + "'");
			//4.更新学生卡、敬老卡的应用期限
			//学生卡的钱包应用有效日期为18岁止//to_date(birthday,'yyyyMMdd')
			/**publicDao.doSql("update card_task_list c1 set c1.bursevaliddate = to_char(add_months(to_date(bursestartdate,'yyyymmdd'),(18 * 12 - months_between(sysdate,to_date(c1.birthday,'yyyymmdd')))),'yyyymmdd'), " +
		        "TOUCH_VALIDDATE = to_char(add_months(to_date(bursestartdate,'yyyymmdd'),(18 * 12 - months_between(sysdate,to_date(c1.birthday,'yyyymmdd')))),'yyyymmdd') "
		      + "where c1.struct_main_type = '10' and c1.TASK_ID = '" + task.getTaskId() + "'"); */
			//更新半价老年人卡的钱包应用有效日期为70岁止
			/**publicDao.doSql("update card_task_list c2 set c2.bursevaliddate = to_char(add_months(to_date(bursestartdate,'yyyymmdd'),(70 * 12 - months_between(sysdate,to_date(c2.birthday,'yyyymmdd')))),'yyyymmdd'), " +
		        " c2.TOUCH_VALIDDATE = to_char(add_months(to_date(bursestartdate,'yyyymmdd'),(70 * 12 - months_between(sysdate,to_date(c2.birthday,'yyyymmdd')))),'yyyymmdd')  "
		      + "where c2.struct_main_type = '11' and c2.TASK_ID = '" + task.getTaskId() + "'");*/
			if(c != task.getTaskSum() || ci != task.getTaskSum()){
				throw new CommonException("生成制卡明细数量跟制卡任务中定义的数量不一致");
			}
		}catch(Exception e){
			logger.error(e);
			throw new CommonException("生成制卡明细出错！" + e.getMessage());
		}
	}
	
	/**
	 * 个人申领信息查询
	 * @param taskId      任务编号
	 * @param applyId     申领编号
	 * @param customerId  客户I编号
	 * @param certType    证件类型
	 * @param certNo      证件号码
	 * @param beginTime   申领开始时间
	 * @param endTime     申领结束时间
	 * @param branchId    申领网点
	 * @param operId      申领柜员
	 * @return            查询数据结果 带分页
	 */
	public Page getApplyMsg(String taskId,Long applyId,String customerId,String certType,String certNo,String beginTime,String endTime,String branchId,String operId,String orderby,Integer pageNum,Integer row) throws CommonException{
		Page page = new Page();
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("select t.apply_id,t.task_id,t.customer_id,p.name,");
			sb.append("(select d3.code_name from sys_code d3 where d3.code_type = 'SEX' and d3.code_value = p.gender) gender,");
			sb.append("(select d4.code_name from sys_code d4 where d4.code_type = 'CERT_TYPE' and d4.code_value = p.cert_type) cert_type,");
			sb.append("p.cert_no,t.card_no,");
			sb.append("(select d.code_name from sys_code d where d.code_type = 'CARD_TYPE' and d.code_value = t.card_type) card_type,");
			sb.append("(select d1.code_name from sys_code d1 where d1.code_type = 'BUS_TYPE' and d1.code_value = t.bus_type) bus_type,");
			sb.append("decode(t.apply_way,'0','零星申领','1','单位申领','2','社区申领','其他申领') apply_way,");
			sb.append("(select d2.code_name from sys_code d2 where d2.code_type = 'APPLY_STATE' and d2.code_value = t.apply_state) apply_type,");
			sb.append("b.full_name,u.name operName ");
			sb.append("from card_apply t,base_personal p, sys_users u ,sys_branch b ");
			sb.append("where t.customer_id = p.customer_id and  t.apply_user_id = u.user_id and t.apply_brch_id = b.brch_id ");
			if(!Tools.processNull(taskId).equals("")){
				sb.append(" and t.task_id = '" + taskId + "' ");
			}
			if(!Tools.processNull(applyId).equals("")){
				sb.append(" and t.apply_id = " + applyId + " ");
			}
			if(!Tools.processNull(customerId).equals("")){
				sb.append(" and t.customer_id = '" + customerId + "' ");
			}
			if(!Tools.processNull(certType).equals("")){
				sb.append(" and p.cert_type = '" +  certType + "' ");
			}
			if(!Tools.processNull(certNo).equals("")){
				sb.append(" and p.cert_no = '" + certNo + "' ");
			}
			if(!Tools.processNull(beginTime).equals("")){
				sb.append(" and to_char(t.apply_date,'yyyy-mm-dd') >= '" + beginTime + "' ");
			}
			if(!Tools.processNull(endTime).equals("")){
				sb.append(" and to_char(t.apply_date,'yyyy-mm-dd') <= '" + endTime + "' ");
			}
			if(!Tools.processNull(branchId).equals("")){
				sb.append(" and t.apply_brch_id = '" + branchId + "' ");
			}
			if(!Tools.processNull(operId).equals("")){
				sb.append(" and t.apply_user_id = '" + operId + "' ");
			}
			sb.append(orderby);
			page = this.pagingQuery(sb.toString(),pageNum,row);
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
		return page;
	}
	/**
	 * 新版申领信息查询
	 * @param para  JSONObject 查询参数信息
	 * @param rows  每页多少条
	 * @param page  第几页
	 * @return
	 */
	public Page toSearchApplyMsg(JSONObject para,Integer pageNum,Integer pageSize) throws CommonException{
		try{
			Page list = new Page();
			StringBuffer sb = new StringBuffer();
			sb.append("select t.apply_id selectid,t.apply_id,t.task_id,c.make_batch_id make_batch_id,p.customer_id,p.name,p.cert_no,decode(t.card_no,'00','',t.card_no) card_no,'' task_state,");
			sb.append("(select s3.code_name from sys_code s3 where s3.code_type = 'SEX' and s3.code_value = p.gender) gender,");
			sb.append("(select code_name from sys_code where code_type = 'APPLY_WAY' and code_value = t.apply_way) applyway,");
			sb.append("(select code_name from sys_code where code_type = 'APPLY_TYPE' and code_value = t.apply_type) applytype,");
			sb.append("(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = p.cert_type) certtype,");
			sb.append("(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.card_type) cardtype,");
			sb.append("(select s1.code_name from sys_code s1 where s1.code_type = 'APPLY_STATE' and s1.code_value = t.apply_state ) applystate,t.bank_id,f.bank_name,t.bank_card_no,t.bank_checkrefuse_reason,");
			sb.append("b.full_name,s.name username,r.region_name,w.town_name,m.comm_name,to_char(t.apply_date,'yyyy-mm-dd hh24:mi:ss') applydate,t.apply_way,t.apply_state, ");
			sb.append("(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = t.agt_cert_type) agtcerttype,t.agt_cert_no,t.agt_name,t.agt_phone,");
			sb.append("(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = t.recv_cert_type) recv_cert_type,t.recv_cert_no,t.recv_name, ");
			sb.append("(select full_name from sys_branch where brch_id = t.rels_brch_id ) rels_brch_id,");
			sb.append("(select name from sys_users where user_id = t.rels_user_id) rels_user_id,");
			sb.append("to_char(t.rels_date,'yyyy-mm-dd hh24:mi:ss') rels_date,t.recv_phone,");
			sb.append("(case when t.apply_way = '1' then (select a.corp_name from base_corp a where a.customer_id = t.corp_id) else '' end)  CORP_NAME, t.is_judge_sb_state ");
			sb.append("from card_apply t,base_personal p,base_region r,base_town w,base_comm m,sys_branch b ,sys_users s,base_corp cp,base_bank f,card_apply_task c ");
			sb.append("where t.customer_id = p.customer_id and p.region_id = r.region_id(+) and ");
			sb.append("p.town_id = w.town_id(+) and p.comm_id = m.comm_id(+) and t.apply_brch_id = b.brch_id(+) and t.apply_user_id = s.user_id(+) and t.corp_id = cp.customer_id(+) and t.bank_id = f.bank_id(+) and t.task_id = c.task_id(+) ");
			if(!Tools.processNull(para.getString("applyBrchId")).equals("")){
				sb.append("and t.apply_brch_id = '" + para.getString("applyBrchId") + "' ");
			}
			if(!Tools.processNull(para.getString("applyUserId")).equals("")){
				sb.append("and t.apply_user_id = '" + para.getString("applyUserId") + "' ");
			}
			if(!Tools.processNull(para.getString("applyWay")).equals("")){
				sb.append("and t.apply_way = '" + para.getString("applyWay") + "' ");
			}
			if(!Tools.processNull(para.getString("taskId")).equals("")){
				sb.append("and t.task_id = '" + para.getString("taskId") + "' ");
			}
			if(!Tools.processNull(para.getString("buyPlanId")).equals("")){
				sb.append("and t.buy_plan_id = '" + para.getString("buyPlanId") + "' ");
			}
			if(!Tools.processNull(para.getString("applyId")).equals("")){
				sb.append("and t.apply_id = '" + para.getString("applyId") + "' ");
			}
			if(!Tools.processNull(para.getString("name")).equals("")){
				sb.append("and p.name like '%" + para.getString("name") + "%' ");
			}
			if(!Tools.processNull(para.getString("certNo")).equals("")){
				Object tempcusid = this.findOnlyFieldBySql("select t.customer_id from base_personal t where t.cert_no = '" + para.getString("certNo") + "'");
				sb.append("and p.cert_no = '" + para.getString("certNo") + "' ");
				if(!Tools.processNull(tempcusid).equals("")){
					sb.append("and t.customer_id = '" + tempcusid.toString() + "' ");
				}
			}
			if(!Tools.processNull(para.getString("certType")).equals("")){
				sb.append("and p.cert_type = '" + para.getString("certType") + "' ");
			}
			if(!Tools.processNull(para.getString("regionId")).equals("")){
				sb.append("and p.region_id = '" + para.getString("regionId") + "' ");
			}
			if(!Tools.processNull(para.getString("townId")).equals("")){
				sb.append("and p.town_id = '" + para.getString("townId") + "' ");
			}
			if(!Tools.processNull(para.getString("commId")).equals("")){
				sb.append("and p.comm_id = '" + para.getString("commId") + "' ");
			}
			if(!Tools.processNull(para.getString("applyState")).equals("")){
				sb.append("and t.apply_state = '" + para.getString("applyState") + "' ");
			}
			if(!Tools.processNull(para.getString("beginTime")).equals("")){
				sb.append("and t.apply_date >= to_date('" + para.getString("beginTime") + " 00:00:00','yyyy-mm-dd hh24:mi:ss') ");
			}
			if(!Tools.processNull(para.getString("endTime")).equals("")){
				sb.append("and t.apply_date <= to_date('" + para.getString("endTime") + " 23:59:59','yyyy-mm-dd hh24:mi:ss') ");
			}
			if(!Tools.processNull(para.getString("corpId")).equals("")){
				sb.append("and t.corp_id = '" + para.getString("corpId") + "' ");
			}
			if(!Tools.processNull(para.getString("corpName")).equals("")){
				//sb.append("and cp.corp_name like '%" + para.getString("corpName") + "%' ");
			}
            if(!Tools.processNull(para.getString("taskName")).equals("")){
                sb.append("and c.task_name like '" + para.getString("taskName") + "%' ");
            }
			if(!Tools.processNull(para.getString("sort")).equals("")){
				sb.append("order by " + para.getString("sort") + " " + para.getString("order"));
			}else{
				sb.append("order by t.apply_date desc");
			}
			list = this.pagingQuery(sb.toString(),pageNum,pageSize);
			return list;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}


	/**
	 * 插入到申领临时表中
	 * @param task
	 * @param oper
	 */
	public void insertPersonalApply(CardApplyTask task,Users oper){
		try{
			//先删除
		  publicDao.doSql("delete from Base_personal_apply y where y.bd_Flag='2' and y.user_id='"+oper.getUserId()+"'");
		  StringBuffer insertSql=new StringBuffer(512);
		  insertSql.append(" insert into base_personal_apply(CUSTOMER_ID,COMPANYID, CITY_ID,REGION_ID,TOWN_ID,COMM_ID, USER_ID,bd_Flag,TASK_ID) select b.customer_id,b.corp_customer_id,b.CITY_ID, b.REGION_ID,b.TOWN_ID,b.COMM_ID,'"+oper.getUserId()+"','2',a.task_id ");
		  insertSql.append(" from card_apply a ,base_personal b where b.customer_id = a.customer_id  ");
		  insertSql.append(" and a.apply_state = '" + Constants.APPLY_STATE_RWYSC + "' and a.task_id = '" + task.getTaskId() + "'");
		  publicDao.doSql(insertSql.toString());//插入到过渡人员表
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * <h3>根据任务号插入制卡数据明细表<h3>
	 * 插入社保信息
	 * @param CardApplyTask task 当前任务
	 */
	public void insertCardtasklist_Sb(CardApplyTask task)throws CommonException{
		try{
			//插入社保明细信息
			StringBuffer insertSql=new StringBuffer("insert into CARD_TASK_LIST_SB (TASK_ID, SSSEEF0701, SSSEEF0702, SSSEEF0703, SSSEEF0CF0, SSSEEF0CF1, DF01EF092E, DF01EF0930, DF01EF0931, DF01EF0932, DF01EF0A37, DF01EF0A38, DF01EF0A39, DF01EF0CF2, DF01EF0CF3, DF02EF055701, DF02EF055801, DF02EF055901, DF02EF055702, DF02EF055802, DF02EF055902, DF02EF0542, DF02EF055A01, DF02EF055B01, DF02EF055C01, DF02EF055D01, DF02EF055A02, DF02EF055B02, DF02EF055C02, DF02EF055D02, DF02EF064B, DF02EF064C, DF02EF0660, DF02EF064D, DF02EF064F, DF02EF0650, DF02EF063A, DF02EF070101, DF02EF070102, DF02EF070103, DF02EF070104, DF02EF070201, DF02EF070202, DF02EF070203, DF02EF070204, DF02EF070301, DF02EF070302, DF02EF070303, DF02EF070304, DF02EF070401, DF02EF070402, DF02EF070403, DF02EF070404, DF03EF0598, DF03EF0561, DF03EF0562, DF03EF0563, DF03EF0564, DF03EF0565, DF03EF0566, DF03EF0667, DF03EF0668, DF03EF0669, DF03EF066A, DF03EF066B, DF03EF076C, DF03EF076D, DF03EF076E, DF03EF076F, DF03EF0770, DF03EF0771, DF03EF0772, DF03EF0773, DF04EF0580, DF04EF0583, DF04EF058B, DF04EF058C, DF04EF058F, DF04EF05F4, DF04EF05F5, DF04EF05F6, DF04EF05F7, DF04EF05F8, DF04EF05F9, DF04EF05FA, DF04EF05FB, DF04EF05FC, DF04EF05FD, DF04EF0790, DF04EF0792, DF04EF0793, DF04EF0794, DF04EF0795, DF04EF0C0101, DF04EF0C0102, DF04EF0C0201, DF04EF0C0202, DF04EF0D0101, DF04EF0D0102, DF04EF0D0201, DF04EF0D0202, DF04EF0EE1, DF04EF0EE2, DF04EF0EE3, DF04EF0EE4, DF04EF10B0, DF04EF10B1, DF04EF10B2, DF04EF10B3, DF04EF10B4, DF04EF10B5, DF04EF10B6, DF04EF10B7, DF04EF10B8, DF04EF10B9, DF04EF10BA, DF04EF10BB, DF04EF10BC, DF04EF10BD, DF04EF10BE, DF04EF10BF, DF04EF10C0, DF04EF10C1, DF04EF10C2, DF04EF10C3, DF04EF10C4, DF0AEF05D0, DF0AEF05D1, DF0AEF05D2, DF0AEF05D3, DF0AEF05D4, DF0AEF05D5, DF0AEF05D6, DF0AEF05D7, DF0AEF05D8, DF0AEF05D9, DF0AEF05DA, DF0AEF05DB, DF0AEF05DC, DF0AEF05DD, DF0AEF05DE, DF0AEF05DF, DF0AEF06A0, DF0AEF06A1, DF0AEF06A2, DF0AEF06A3, DF0AEF06A4, DF0AEF06A5, DF0AEF06A6, DF0AEF06A7, DF0AEF06A8, DF0AEF06A9, DF0AEF06AA, DF0AEF06AB, CARD_ID, ATR, RFATR, NJ, DF02EF0852, DF02EF0853, DF02EF0854, DF02EF0955, DF02EF0956, DF02EF0996, DF02EF0997, DF03EF0560, DF04EF0581, DF04EF0584, DF04EF0586, DF04EF0587, DF04EF0589, DF04EF058A, DF04EF0690, DF04EF0692, DF04EF0693, DF04EF0CA0, SSSEEF0507, SSSEEF0506, SB_ID, SB_STATE, CUSTOMER_ID)");
			insertSql.append("select "+task.getTaskId()+",'',  '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', SEQ_SB_ID.NEXTVAL, '0', a.CUSTOMER_ID");
			insertSql.append(" from card_apply a ,base_personal b where b.customer_id = a.customer_id  and a.task_id = '" + task.getTaskId() + "'");
			publicDao.doSql(insertSql.toString());//插入到过渡人员表
			//更新人员base_personal_apply表中SB_ID
			publicDao.doSql("update base_personal_apply a  set a.sb_id =(select sb.sb_id   from card_task_list_sb sb where a.customer_id = sb.customer_id and sb.task_id = a.task_id)   where  exists (select 1  from card_task_list_sb b  where a.customer_id = b.customer_id  and b.task_id = a.task_id)");
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 卫生申领
	 * @param task
	 * @throws CommonException
	 */
	public void insertCardtasklist_Ws(CardApplyTask task)throws CommonException{
		try{
			StringBuffer insertSql=new StringBuffer(" insert into CARD_TASK_LIST_WS (TASK_ID, CUSTOMER_ID,WS_ID,DATA_SEQ) ");
			insertSql.append(" select a.task_id,a.customer_id,SEQ_WS_ID.NEXTVAL,l.DATA_SEQ  from card_apply a ,base_personal b,CARD_TASK_LIST l where  l.customer_id=a.customer_id and  b.customer_id = a.customer_id  and l.task_id=a.task_id  and a.task_id = '" + task.getTaskId() + "'");
			publicDao.doSql(insertSql.toString());//插入到过渡人员表
			//更新人员base_personal_apply表中SB_ID
			publicDao.doSql("update base_personal_apply a  set a.ws_id =(select w.ws_id  from card_task_list_ws w where a.customer_id = w.customer_id and w.task_id = a.task_id)   where  exists (select 1  from card_task_list_ws b  where a.customer_id = b.customer_id  and b.task_id = a.task_id)");
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}

	/**
	 * 撤销申领信息
	 * @param actionLog
	 * @param apply_Id
	 * @return
	 * @throws CommonException
	 */
	@Override
	public Long saveUndoCardApply(SysActionLog actionLog, String apply_Id) throws CommonException {
		try{
			//1.申领验证
			SysActionLog log = getCurrentActionLog();
			CardApply apply = (CardApply)this.findOnlyRowByHql("from CardApply c where c.applyId = " + Long.valueOf(apply_Id));
			if(apply == null){
				throw new CommonException("根据申领编号" + apply_Id + "找不到申领信息！");
			}
			if(!Tools.processNull(apply.getApplyWay()).equals(Constants.APPLY_WAY_LX)){
				throw new CommonException("申领方式不是【零星申领】，无法进行撤销！");
			}
			BasePersonal person = (BasePersonal)this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + apply.getCustomerId() + "'");
			if (person == null) {
				throw new CommonException("人员信息不存在.");
			}
			SysBranch branch = (SysBranch) findOnlyRowByHql("from SysBranch where brchId = '" + log.getBrchId() + "'");
			if (branch == null) {
				throw new CommonException("当前网点不存在.");
			}
			// 2.申领撤销
			List<String> inparams = new ArrayList<String>();
			StringBuffer param = new StringBuffer();
			param.append(branch.getBrchId()).append("|");
			param.append(Constants.ACPT_TYPE_GM).append("|");
			param.append(log.getUserId()).append("|");
			param.append("").append("|");
			param.append(apply.getApplyId()).append("|");
			param.append("").append("|");
			param.append("").append("|");
			param.append("").append("|");
			param.append("").append("|");
			param.append("");
			inparams.add(param.toString());
			List<Object> outTypes = new ArrayList<Object>();
			outTypes.add(Types.VARCHAR);
			outTypes.add(Types.VARCHAR);
			outTypes.add(Types.VARCHAR);
			List<Object> rets = publicDao.callProc("PK_CARD_APPLY_ISSUSE.P_APPLY_CANCEL",inparams,outTypes);
			if (rets == null || rets.isEmpty()) {
				throw new CommonException("调用系统撤销过程失败.");
			}
			if (Integer.parseInt(rets.get(0).toString()) != 0) {
				String errMsg = rets.get(1).toString().equals("null") ? "未知错误" : rets.get(1).toString();
				throw new CommonException("调用系统撤销过程失败, " + errMsg);
			}
			String avOut = rets.get(2) == null ? "" : rets.get(2).toString();
			if(!Tools.processNull(avOut).equals("")){
				String dealNo = avOut.split("\\|")[0];
				log = (SysActionLog) publicDao.get(SysActionLog.class, Long.valueOf(dealNo));
			} else {
				throw new CommonException("调用系统撤销过程失败, 返回流水为空.");
			}
			//3.报表
			/*JSONObject json = new JSONObject();
			json.put("p_Title", Constants.APP_REPORT_TITLE + this.findTrCodeNameByCodeType(log.getDealCode()) + " 凭证");
			json.put("p_Actionno",log.getDealNo());//交易流水
			json.put("p_Oper_Time",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));
			json.put("p_Client_Name",person.getName());//客户姓名
			json.put("p_Cert_Type",this.getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType()));
			json.put("p_Cert_No",person.getCertNo());//证件号
			json.put("p_Card_Type",this.getCodeNameBySYS_CODE("CARD_TYPE",apply.getCardType()));//证件类型
			json.put("p_Card_No",apply.getCardNo());//卡号
			json.put("p_Bus_Type",this.getCodeNameBySYS_CODE("BUS_TYPE",Tools.processNull(apply.getBusType())));//卡类型
			json.put("p_Agtname","");
			json.put("p_Agtcerttype","");
			json.put("p_Agtcertno", "");
			json.put("p_Agttelno","");
			json.put("p_Foregift",Arith.cardreportsmoneydiv(Tools.processNull(apply.getForegift())));//押金
			json.put("p_Costfee", Arith.cardreportsmoneydiv(Tools.processNull(apply.getCostFee())));//工本费
			json.put("p_Acpt_Branch",this.getSysBranchByUserId().getFullName());
			json.put("p_Oper_Id",log.getUserId());//操作员
            this.saveSysReport(log,json,"/reportfiles/applyIssusepz.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);*/
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, log.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(log.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "工本费：￥" + Arith.cardreportsmoneydiv(Tools.processNull(apply.getCostFee()).equals("") ? "0" : apply.getCostFee() + "") + " / 押金：￥" + Arith.cardreportsmoneydiv(Tools.processNull(apply.getForegift()).equals("") ? "0" : apply.getForegift() + ""));
			json.put(ReceiptContants.FIELD.CARD_NO, apply.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, apply.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, person.getName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, person.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, apply.getAgtName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", apply.getAgtCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, apply.getAgtCertNo()); // 代理人证件号码
			json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSysBranchByUserId().getFullName()); // 受理网点名称
			json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, getSessionUser().getUserId()); // 受理员工号
			json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, getSessionUser().getName()); // 受理员姓名
			json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
			this.saveSysReport(log, json, ReceiptContants.TYPE.COMMON, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
            return log.getDealNo();
		}catch(Exception e){
			throw new CommonException("撤销申领失败："+e.getMessage());
		}
	}
	
	/**
	 * 导入申领将文件导入临时表
	 * @param book     excel表格
	 * @param fileName 文件名称
	 * @param oper     操作员
	 * @param log      操作日志
	 * @return         业务日志
	 */
	public TrServRec saveImportFileApply(Workbook book,String fileName,Users oper,SysActionLog log)throws CommonException{
		try{
			log.setDealCode(0);
			log.setMessage("导入申领EXCEl文件导入临时表：文件名" + fileName);
			publicDao.save(log);
			TrServRec rec = new TrServRec();
		    Sheet sheet = book.getSheetAt(0);
		    if(sheet == null){
		    	throw new CommonException("导入的文件【" + fileName + "】内容为空！");
		    }
		    int lastRowNum = sheet.getLastRowNum();
		    if(lastRowNum <= 0){
		    	throw new CommonException("导入的文件【" + fileName + "】数据为空！");
		    }
		    StringBuffer sb =  new StringBuffer();
		    for(int i = 1; i <= lastRowNum; i++){
				Row tempRow = sheet.getRow(i);
				if(tempRow == null){
					throw new CommonException("数据内容为空。位置在第" + (i + 1) + "行！");
				}
				sb.append("insert into card_apply_person_temp(seq_id,xh,person_id,name,cert_no,companyid,reside_type,oper_id,note,emp_name,med_whole_no) values(");
				sb.append("seq_CARD_APPLY_PERSON_TEMP.Nextval,");
				int tempLastCellNum = tempRow.getLastCellNum();
				for(int j = 0;j < tempLastCellNum; j++){
					Cell tempCell = tempRow.getCell(j);
					String tempCellValue = "";
					if(tempCell.getCellType() == Cell.CELL_TYPE_BLANK){
						tempCellValue = "";
					}else if(tempCell.getCellType() == Cell.CELL_TYPE_STRING){
						tempCellValue = tempCell.getStringCellValue();
					}else if(tempCell.getCellType() == Cell.CELL_TYPE_NUMERIC){
						tempCellValue = tempCell.getNumericCellValue() + "";
					}else{
						throw new CommonException("解析单元格出现错误，位置在第" + (i + 1) + "行，第" + (j + 1) + "列！");
					}
					if(j == tempLastCellNum - 1){
						sb.append("''" + tempCellValue + "''");
					}else{
						sb.append("''" + tempCellValue + "'',");
					}
				}
				sb.append("),");
				if(i % 500 == 0){
					publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + sb.substring(0,sb.length() - 1) + "))");
					sb =  new StringBuffer();
				}
			}
		    if(!Tools.processNull(sb.toString()).equals("")){
		    	publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + sb.substring(0,sb.length() - 1) + "))");
		    }
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 生成卡号的定时任务
	 */
	@Override
	public synchronized void saveCardNoTask() throws CommonException {
		try{
			List<CardConfig> allCardTypes = (List<CardConfig>)this.findByHql("from CardConfig c where c.cardTypeState = '0' and c.cardNum > 0 ");
			for(CardConfig tempCardType : allCardTypes){
				if(Tools.processNull(tempCardType.getCardTypeCatalog()).trim().length() != 2){
					logger.error("预生成卡号出现错误：" + Tools.processNull(tempCardType.getCardType()) + " 的卡大类信息设置不正确！");
					continue;
				}
				List<?> allRegions = this.findByHql("from BaseRegion t where t.regionState = '0' and t.regionId <> '330400'");
				for(Object object : allRegions){
					BaseRegion tempRegion = (BaseRegion) object;
					BigDecimal notUsedCount = (BigDecimal) publicDao.findOnlyFieldBySql("select count(1) from card_no a where a.used = '1' and a.region_code = '" +
					tempRegion.getRegionCode() + "' and a.card_catalog = '" + tempCardType.getCardTypeCatalog() + "' and a.card_type = '" + tempCardType.getCardType() + "'");
					if(notUsedCount.longValue() < tempCardType.getCardNum()){
						createCard_No(tempCardType.getCardType(),tempRegion.getRegionCode(),Integer.valueOf((tempCardType.getCardNum() - notUsedCount.longValue()) + ""));
					}else{
						logger.error("当前不用预生成卡类型为：" + tempCardType.getCardType() + "的卡号段......" + DateUtil.getNowTime());
					}
				}
			}
		}catch(Exception e){
			logger.error(e.getMessage());
		}finally{
			logger.error("结束预生成卡号");
		}
	}
	/**
	 * 生成社保卡卡号
	 * @param cardnumseq
	 * @param prefix
	 * @return
	 */
	public static String createCardNumber(String cardnumseq, String prefix) {
		try {
			Integer.valueOf(cardnumseq);
		} catch (Exception e) {
			throw new CommonException("输入的卡序列号不是有效的数字！");
		}
		String center_cardnumber = Tools.tensileString(cardnumseq, 7, true, "0");
		int tempnum = 0;
		int totalnum = 0;
		String checknumber = "";
		if (prefix.equalsIgnoreCase("A"))
			totalnum = 10 * 3;// 首位字符对应的数值*权
		else if (prefix.equalsIgnoreCase("B"))
			totalnum = 11 * 3;
		else if (prefix.equalsIgnoreCase("C"))
			totalnum = 12 * 3;
		else if (prefix.equalsIgnoreCase("D"))
			totalnum = 13 * 3;
		else if (prefix.equalsIgnoreCase("E"))
			totalnum = 14 * 3;
		else if (prefix.equalsIgnoreCase("F"))
			totalnum = 15 * 3;
		else if (prefix.equalsIgnoreCase("G"))
			totalnum = 16 * 3;
		else if (prefix.equalsIgnoreCase("H"))
			totalnum = 17 * 3;
		else if (prefix.equalsIgnoreCase("I"))
			totalnum = 18 * 3;
		else
			totalnum = 10 * 3;
		for (int i = 0; i < 7; i++) {
			if (i == 0)
				tempnum = 7;
			if (i == 1)
				tempnum = 9;
			if (i == 2)
				tempnum = 10;
			if (i == 3)
				tempnum = 5;
			if (i == 4)
				tempnum = 8;
			if (i == 5)
				tempnum = 4;
			if (i == 6)
				tempnum = 2;
			totalnum = totalnum+ tempnum* Integer.valueOf(center_cardnumber.substring(i, i + 1)).intValue();
		}
		tempnum = 11 - (totalnum % 11);
		if (tempnum == 10) {
			checknumber = "X";
		} else if (tempnum == 11) {
			checknumber = "0";
		} else {
			checknumber = String.valueOf(tempnum);
		}
		return prefix + center_cardnumber + checknumber;
	}
	
	public TrServRec getTrServRec(TrServRec rec,BasePersonal bp,CardBaseinfo card,AccAccountSub acc,SysActionLog log){
		//1.基本条件判断
		if(bp == null){
			if(card != null && !Tools.processNull(card.getCustomerId()).equals("")){
				bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
			}
		}
		if(rec == null){
			rec = new TrServRec();
		}
		//2.设值SysActionLog相关
		rec.setDealNo(log.getDealNo());
		rec.setDealCode(log.getDealCode());
		rec.setBizTime(log.getDealTime());
		rec.setOrgId(log.getOrgId());
		rec.setNote(log.getMessage());
		//3.设值BasePersonal相关
		if(bp != null){
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			rec.setCustomerName(bp.getName());
			rec.setTelNo(bp.getMobileNo());
			if(Tools.processNull(rec.getCertType()).equals("")){
				rec.setAgtCertType(bp.getCertType());
			}
			if(Tools.processNull(rec.getAgtCertNo()).equals("")){
				rec.setAgtCertNo(bp.getCertNo());
			}
			if(Tools.processNull(rec.getAgtName()).equals("")){
				rec.setAgtName(bp.getName());
			}
			if(Tools.processNull(rec.getAgtTelNo()).equals("")){
				rec.setAgtTelNo(bp.getMobileNo());
			}
		}
		//4设值CardBaseinfo相关
		if(card != null){
			rec.setCardId(card.getCardId());
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setCardAmt(1L);
		}
		if(acc != null){
			rec.setAccKind(acc.getAccKind());
			rec.setAccNo(acc.getAccNo() + "");
		}
		//5通用
		rec.setClrDate(this.getClrDate());
		rec.setDealState(Constants.STATE_ZC);
		rec.setBrchId(this.getUser().getBrchId());
		rec.setUserId(this.getUser().getUserId());
		return rec;
	}
	@Override
	public TrServRec saveOneCardByIdCardApply(BasePersonal bp, byte[] filebyte,CardApply apply, TrServRec rec, String queryType,SysActionLog actionLog) throws CommonException {
		try {
			if(bp == null){
				throw new CommonException("发生错误：传入人员信息不能为空！");
			}
			if(actionLog == null){
				actionLog = this.getCurrentActionLog();
			}
			String logwithphoto = actionLog.getInOutData().substring(actionLog.getInOutData().indexOf("Params:") + 7) ;
			String loghead =actionLog.getInOutData().substring(0,actionLog.getInOutData().indexOf("Params:"));
			JSONObject zp = JSONObject.parseObject(logwithphoto);
			zp.remove("personPhotoContent");
			actionLog.setInOutData(loghead + "Params:" + zp.toJSONString());
			///报表 
			actionLog.setDealCode(DealCode.APPLY_TYPE_READ);
			publicDao.save(actionLog);
			SysPara res = this.getSysParaByParaCode("CITY_CODE");
			if(res == null || Tools.processNull(res.getParaCode()).equals("")){
				throw new CommonException("发生错误：SYS_PARA 城市代码未设置！");
			}
			if(Tools.processNull(queryType).equals("0")){
				bp.setOpenDate(this.getDateBaseTime());
				bp.setCustomerState("0");
				bp.setSureFlag("0");
				bp.setCityId(res.getParaValue());
				bp.setOpenDate(this.getDateBaseTime());
				bp.setName(Tools.processNull(bp.getName().trim()));
				bp.setCertNo(Tools.processNull(bp.getCertNo().trim().toUpperCase()));
				bp.setOpenUserId(this.getUser().getUserId());
				publicDao.save(bp);
			}else if(Tools.processNull(queryType).equals("1")){
				BasePersonal tempbp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.certNo = '" + bp.getCertNo() + "'");
				if(tempbp == null){
					throw new CommonException("发生错误：根据客户编号【" + bp.getCertNo() + "】未找到客户信息！");
				}
				tempbp.setName(bp.getName().trim());
				tempbp.setCertType(bp.getCertType());
				tempbp.setCertNo(Tools.processNull(bp.getCertNo()).toUpperCase().trim());
				tempbp.setBirthday(bp.getBirthday());
				tempbp.setGender(bp.getGender());
				tempbp.setNation(bp.getNation());
				tempbp.setEducation(bp.getEducation());
				tempbp.setMarrState(bp.getMarrState());
				tempbp.setResideType(bp.getResideType());
				tempbp.setEmail(bp.getEmail());
				tempbp.setPhoneNo(bp.getPhoneNo());
				tempbp.setMobileNo(bp.getMobileNo());
				tempbp.setRegionId(bp.getRegionId());
				tempbp.setTownId(bp.getTownId());
				tempbp.setCommId(bp.getCommId());
				tempbp.setCareer(bp.getCareer());
				tempbp.setCorpCustomerId(bp.getCorpCustomerId());
				tempbp.setResideAddr(bp.getResideAddr());
				tempbp.setLetterAddr(bp.getLetterAddr());
				tempbp.setCustomerState(bp.getCustomerState());
				tempbp.setPinying(bp.getPinying());
				tempbp.setPostCode(bp.getPostCode());
				tempbp.setCityId(res.getParaValue());
				bp.setRegionId(res.getParaCode());
				tempbp.setNote(bp.getNote());
				tempbp.setSureFlag(bp.getSureFlag());
				publicDao.update(tempbp);
			}
			
			BasePersonal person = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.certNo = '" + bp.getCertNo() + "'");
			BasePhoto photo = new BasePhoto();
			photo.setCustomerId(person.getCustomerId().toString());
			photo.setPhotoState("0");
			publicDao.savePhotoImg(photo,filebyte);
			Users user=this.getSessionUser();
			BigDecimal appid = (BigDecimal)this.findOnlyRowBySql("select  seq_apply_id.nextval  from dual");
			apply.setApplyId(appid.longValue());
			apply.setCustomerId(person.getCustomerId().toString());
			apply.setCommId(person.getCommId().toString());
			apply.setTownId(person.getTownId().toString());
			apply.setCommId(person.getCommId().toString());
			apply.setCityCode(person.getCityId().toString());
			apply.setApplyDate(actionLog.getDealTime());
			apply.setDealNo(actionLog.getDealNo());
			apply.setApplyBrchId(user.getBrchId());
			apply.setApplyUserId(user.getName().toString());
			apply.setApplyState(Constants.APPLY_STATE_YSQ);
			apply.setWalletUseFlag(Constants.USED_FLAG);
			apply.setCardType(Constants.CARD_TYPE_SMZK);
			apply.setApplyWay(Constants.APPLY_WAY_LX);
			apply.setApplyType(Constants.APPLY_TYPE_CCSL);
			publicDao.save(apply);
			rec = getTrServRec(rec,bp,null,null,actionLog);
			publicDao.save(rec);
			JSONObject json = new JSONObject();
			json.put("p_Title",Constants.APP_REPORT_TITLE + this.findTrCodeNameByCodeType(actionLog.getDealCode()) + "办理凭证");//挂失、解挂没用到
			json.put("p_Actionno",actionLog.getDealNo());//交易流水
			json.put("p_Oper_Time",DateUtil.formatDate(actionLog.getDealTime(),"yyyy-MM-dd HH:mm:ss"));//受理时间
			json.put("p_Client_Name",person.getName());//客户姓名
			json.put("p_Cert_Type",this.getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType()));//证件类型
			json.put("p_Cert_No",person.getCertNo());//证件号
			json.put("p_Card_Type",this.getCodeNameBySYS_CODE("CARD_TYPE", apply.getCardType()));//卡类型
			json.put("p_Yw_Type", this.findTrCodeNameByCodeType(actionLog.getDealCode()));//业务名称
			json.put("p_Agtname",apply.getAgtName());//代理人姓名
			json.put("p_Foregift","0.00");//押金
			json.put("p_Costfee",apply.getCostFee());//工本费
			json.put("p_Brch",user.getBrchName());//受理网点
			json.put("p_Agtcerttype",this.getCodeNameBySYS_CODE("CERT_TYPE",apply.getAgtCertType()));//代理人证件类型
			json.put("p_Agtcertno",apply.getAgtCertNo());//代理人证件号码
			json.put("p_Agttelno",apply.getAgtPhone());//代理人电话号码
			json.put("p_Bus_Type",this.getCodeNameBySYS_CODE("BUS_TYPE",apply.getBusType()));//公交类型
			json.put("p_Oper_Id",user.getUserId());//操作员
			this.saveSysReport(actionLog,json,"/reportfiles/applyIssusepz.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
            return rec;
		} catch (Exception e) {
			throw new CommonException("身份证申领出现错误：："+e.getMessage());
		}
	}
	///////////////////////导入申领/////////////////////////////////////
	/**
	 * 导入申领将文件导入确认生成申领数据
	 * @param file     excel表格
	 * @param log      操作日志
	 * @return         业务日志
	 */
	public void saveImpApply(String dealno,String card_type,Users user, SysActionLog log,Object[] obj) throws CommonException {
		String taskName="";
		String med_whole_no="";
		try {
			taskName=obj[1].toString();
			med_whole_no=obj[0].toString();
			log.setMessage("导入申领保存,任务名称："+taskName);
			publicDao.save(log);
			//先删除不能申领的，以免误事。
			publicDao.doSql("delete from card_apply_person_temp t where t.note is  not null");
			//1.基本条件判断
			String city_code = Tools.tensileString(this.findOnlyFieldBySql("SELECT T.PARA_VALUE FROM SYS_PARA T WHERE T.PARA_CODE = 'CITY_CODE'").toString(),4,true,"0");
			CardConfig config = (CardConfig) this.findOnlyRowByHql("from CardConfig where cardType = '" + card_type + "'");
			//Object[] branch_card_flag = (Object[])this.findOnlyRowBySql("SELECT B.CARD_FLAG,B.REGION_CODE FROM SYS_BRANCH S,BASE_REGION B WHERE S.REGION_ID = B.REGION_ID AND S.BRCH_ID = '" + user.getBrchId() + "'");
			Object[] branch_card_flag = (Object[])this.findOnlyRowBySql("SELECT B.CARD_FLAG,B.REGION_CODE FROM BASE_REGION B WHERE 1=1 AND b.region_id = '" + med_whole_no + "'");
			//3.对规模申领临时表进行预处理
			CardApplyTask tempTask = new CardApplyTask();
			tempTask.setTaskId(DateUtil.formatDate(log.getDealTime(),"yyyyMMdd") + Tools.tensileString(this.getSequenceByName("SEQ_TASK_ID"),8,true,"0"));// //生成任务编号  yyyymmdd+8位序列号
			tempTask.setTaskDate(log.getDealTime());//任务产生时间
			tempTask.setDealNo(log.getDealNo());//取业务日志序列号（SEQ_ACTON_NO）
			tempTask.setDealCode(log.getDealCode());
			//task.setBrchId(oper.getBrchId());
			tempTask.setTaskState(Constants.TASK_STATE_YSC);
			tempTask.setTaskBrchId(user.getBrchId());
			tempTask.setTaskOperId(user.getUserId());
			tempTask.setBrchId(user.getBrchId());//领卡网点
			tempTask.setTaskOrgId(user.getOrgId());
			tempTask.setTaskName(taskName);
			tempTask.setIsPhoto(Tools.processNull("0"));
			tempTask.setTaskSrc(Constants.TASK_SRC_DRSL);//任务来源_导入申领
			tempTask.setIsUrgent(Tools.processNull("1"));//制卡方式 0 本地制卡 1 外包制卡（需要生成卡号） 2 本地加急  3 外包加急
			tempTask.setCardType(Tools.processNull(card_type));
			tempTask.setTaskWay(Constants.TASK_WAY_DR);
			tempTask.setIsList("0");
			tempTask.setBankId(Tools.processNull(this.findOnlyFieldBySql("SELECT BANK_ID FROM card_apply_person_temp p WHERE p.emp_name = '" + taskName + "'")));
			tempTask.setMedWholeNo(med_whole_no);//任务所属的统筹区域
//				4.删除临时表上次已过期申领信息
			publicDao.doSql("DELETE FROM CARD_APPLY_GMSL_TEMP T WHERE T.APPLY_USER_ID = '" + user.getUserId() + "'");
			StringBuffer slsql = new StringBuffer(512);
			slsql.append("INSERT INTO CARD_APPLY_GMSL_TEMP (APPLY_ID,BAR_CODE,CUSTOMER_ID,CARD_NO,SUB_CARD_NO,CARD_TYPE,BANK_ID,VERSION,ORG_CODE,");
			slsql.append("CITY_CODE,INDUS_CODE,APPLY_WAY,APPLY_TYPE,MAKE_TYPE,APPLY_BRCH_ID,CORP_ID,COMM_ID,TOWN_ID,APPLY_STATE,APPLY_USER_ID,");
			slsql.append("APPLY_DATE,COST_FEE,FOREGIFT,IS_URGENT,URGENT_FEE,IS_PHOTO,RECV_BRCH_ID,BUS_TYPE, MAIN_FLAG, OTHER_FEE, WALLET_USE_FLAG,DEAL_NO,BKVEN_ID,GROUP_ID,MED_WHOLE_NO) ");
			//5.符合本次申领条件的限制语句
			slsql.append("SELECT SEQ_APPLY_ID.NEXTVAL,LPAD(SEQ_BAR_CODE.NEXTVAL,9,'0'),B.CUSTOMER_ID,'");
			slsql.append(Tools.processNull(branch_card_flag[1]) + "',");
			slsql.append("PK_PUBLIC.CREATESUBCARDNO('" + branch_card_flag[0] + "',LPAD(SEQ_SUB_CARD_NO.NEXTVAL,7,'0')),'");
			slsql.append(tempTask.getCardType() + "','" + Tools.processNull(tempTask.getBankId()) + "','" + Constants.CARD_VERSION + "','" + Constants.INIT_ORG_ID + "','" + city_code + "','");
			slsql.append(Constants.INDUS_CODE + "','" + tempTask.getTaskWay() + "','" + Constants.APPLY_TYPE_CCSL + "','" + "1" + "','");//是否加急
			slsql.append(user.getBrchId() + "','" + Tools.processNull(tempTask.getCorpId()) + "',B.COMM_ID,B.TOWN_ID,'");
			slsql.append(Constants.APPLY_STATE_RWYSC + "','" + user.getUserId() + "',to_date('");
			slsql.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','yyyy-MM-dd HH24:mi:ss'),0,0,'" + tempTask.getIsUrgent() + "',0,'" + Tools.processNull(tempTask.getIsPhoto()) + "','" + Tools.processNull(tempTask.getBrchId()) + "',");
			slsql.append("'00'");//公交类型
			slsql.append(",'',0,'" + Constants.BUS_USE_FLAG_QB + "'," + log.getDealNo() + ",'" + Tools.processNull(tempTask.getVendorId()) + "','" + Tools.processNull(tempTask.getGroup_Id()) + "',F.MED_WHOLE_NO ");
			slsql.append("FROM BASE_PERSONAL B,BASE_SIINFO F,card_apply_person_temp p " );
			slsql.append("WHERE B.CUSTOMER_STATE = '0' AND B.CERT_NO = F.CERT_NO AND B.NAME = F.NAME AND F.MED_STATE = '0' AND F.MED_WHOLE_NO =p.MED_WHOLE_NO and p.emp_name='"+taskName+"' and p.note is null and p.deal_no="+dealno);
			slsql.append(" and B.CERT_NO = p.CERT_NO and p.note is null  AND NOT EXISTS(SELECT 1 FROM CARD_APPLY A WHERE A.CUSTOMER_ID = B.CUSTOMER_ID ");
			slsql.append("AND (A.APPLY_STATE < '" + Constants.APPLY_STATE_YZX + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_WJWSHBTG + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_YZX  + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_YHSHBTG + "')) ");
			if(Tools.processNull(tempTask.getIsPhoto()).equals(Constants.YES_NO_YES)){
				slsql.append("AND EXISTS (SELECT 1 FROM BASE_PHOTO P WHERE P.CUSTOMER_ID = B.CUSTOMER_ID AND P.PHOTO_STATE = '0' AND LENGTHB(P.PHOTO) > 0) ");
			}
			//6.申领信息预处理
			
			int allCount = publicDao.doSql(slsql.toString());
			if(allCount == 0){
				throw new CommonException("根据本次条件申领0个人员，本次操作无效，请仔细核对后重新进行操作！");
			}
			int region_Code_Count = publicDao.findBySQL("SELECT 1 FROM CARD_APPLY_GMSL_TEMP WHERE LENGTH(CARD_NO)<>2 AND APPLY_USER_ID = '" + user.getUserId() + "' AND DEAL_NO = " + log.getDealNo()).size();
			if(region_Code_Count != 0){
				throw new CommonException("当前申领人员中有\"" + region_Code_Count + "\"个人所在区县编号为空，请先设置城区编码");
			}
			tempTask.setTaskSum(allCount);//更新本次任务符合条件申领的总人数 //生成任务编号  yyyymmdd+8位序列号
			
			publicDao.save(tempTask);
			publicDao.doSql("UPDATE CARD_APPLY_GMSL_TEMP C SET C.TASK_ID = " + tempTask.getTaskId() + " WHERE APPLY_USER_ID = '" + user.getUserId() + "' AND DEAL_NO = " + log.getDealNo());
			//8.判断制卡方式 0 本地制卡不生成卡号  1 外包制卡 需要生成卡号
			if(Tools.processNull(tempTask.getIsUrgent()).equals(Constants.URGENT_WB)){
				List<?> cardno = this.findBySql("SELECT CARD_TYPE,CARD_NO,COUNT(1) FROM CARD_APPLY_GMSL_TEMP t WHERE t.APPLY_USER_ID = '" + user.getUserId() + "' and DEAL_NO = " + log.getDealNo() + " GROUP BY CARD_TYPE,CARD_NO ");
				for(int n = 0;n < cardno.size();n++){
					Object[] o = (Object[])cardno.get(n);
					try{
						Thread.sleep(1000);
						this.createCardNo(Tools.processNull(o[0]),o[1].toString(),((BigDecimal)(o[2])).longValue(),log.getDealNo());
					}catch(Exception e){
						throw new CommonException(e.getMessage());
					}finally{
						DEAL_CARD_NO_WAIT = false;
					}
					String updatecardno = "MERGE INTO CARD_APPLY_GMSL_TEMP D USING (SELECT A.CARD_NO,B.APPLY_ID FROM (SELECT CARD_NO,ROWNUM RN " +
					"FROM CARD_NO WHERE USED = 0  AND DEAL_NO = " + log.getDealNo() +
					") A, (SELECT APPLY_ID,ROWNUM RN FROM CARD_APPLY_GMSL_TEMP WHERE  CARD_TYPE = '" + o[0] +
					"' AND DEAL_NO = " + log.getDealNo() + ") B WHERE A.RN = B.RN) C ON (D.APPLY_ID = C.APPLY_ID) WHEN MATCHED THEN UPDATE SET D.CARD_NO = C.CARD_NO";
					publicDao.doSql(updatecardno);
				}
			}else if(Tools.processNull(tempTask.getIsUrgent()).equals(Constants.URGENT_BD)){
				publicDao.doSql("UPDATE CARD_APPLY_GMSL_TEMP T SET T.CARD_NO = '' WHERE T.TASK_ID = '" + tempTask.getTaskId() + "' AND DEAL_NO = " + log.getDealNo());
			}
			//9.规模申领临时表数据移动到正式申领表 
			StringBuffer insertApplySql = new StringBuffer();
			insertApplySql.append("INSERT INTO CARD_APPLY (APPLY_ID, BAR_CODE, CUSTOMER_ID,CARD_NO,TASK_ID,SUB_CARD_NO,CARD_TYPE,SUB_CARD_TYPE, ");
			insertApplySql.append("BANK_ID, BANK_CARD_NO, VERSION, ORG_CODE, CITY_CODE, INDUS_CODE, APPLY_WAY, APPLY_TYPE, MAKE_TYPE, APPLY_BRCH_ID, CORP_ID,");
			insertApplySql.append("APPLY_STATE, APPLY_USER_ID, APPLY_DATE, COST_FEE, FOREGIFT, IS_URGENT, IS_PHOTO, RECV_BRCH_ID,");
			insertApplySql.append("RECV_CERT_TYPE, RECV_CERT_NO, RECV_NAME, RELS_BRCH_ID, RELS_USER_ID, RELS_DATE, AGT_CERT_TYPE, AGT_CERT_NO, AGT_NAME,");
			insertApplySql.append("AGT_PHONE, DEAL_NO, NOTE, BUS_TYPE, OLD_CARD_NO, OLD_SUB_CARD_NO, MESSAGE_FLAG, MOBILE_PHONE, MAIN_FLAG, MAIN_CARD_NO,");
			insertApplySql.append("OTHER_FEE, WALLET_USE_FLAG, MONTH_TYPE, MONTH_CHARGE_MODE,TOWN_ID,COMM_ID,GROUP_ID,BKVEN_ID,MED_WHOLE_NO) ");
			// select 
			insertApplySql.append("SELECT T.APPLY_ID,T.BAR_CODE,T.CUSTOMER_ID,T.CARD_NO,T.TASK_ID,T.SUB_CARD_NO,");
			insertApplySql.append("T.CARD_TYPE,T.SUB_CARD_TYPE,T.BANK_ID,T.BANK_CARD_NO,T.VERSION,T.ORG_CODE,T.CITY_CODE,T.INDUS_CODE,T.APPLY_WAY,");
			insertApplySql.append("T.APPLY_TYPE,T.MAKE_TYPE,T.APPLY_BRCH_ID,T.CORP_ID,T.APPLY_STATE,T.APPLY_USER_ID,T.APPLY_DATE,");
			insertApplySql.append("T.COST_FEE,T.FOREGIFT,T.IS_URGENT,T.IS_PHOTO,T.RECV_BRCH_ID,T.RECV_CERT_TYPE,T.RECV_CERT_NO,T.RECV_NAME,T.RELS_BRCH_ID,");
			insertApplySql.append("T.RELS_USER_ID,T.RELS_DATE,T.AGT_CERT_TYPE,T.AGT_CERT_NO,T.AGT_NAME,T.AGT_PHONE,T.DEAL_NO,NULL,'00',");//嘉兴公交类型00
			insertApplySql.append("T.OLD_CARD_NO,T.OLD_SUB_CARD_NO,T.MESSAGE_FLAG,T.MOBILE_PHONE,T.MAIN_FLAG,T.MAIN_CARD_NO,T.OTHER_FEE,T.WALLET_USE_FLAG,T.MONTH_TYPE,");
			insertApplySql.append("T.MONTH_CHARGE_MODE,T.TOWN_ID,T.COMM_ID,T.GROUP_ID,T.BKVEN_ID,T.MED_WHOLE_NO FROM CARD_APPLY_GMSL_TEMP T WHERE T.APPLY_USER_ID = '" + user.getUserId() + "' AND T.DEAL_NO = " + log.getDealNo());
			publicDao.doSql(insertApplySql.toString());
			//10.生成制卡明细
			insertCardtasklist(tempTask,config);
			//11.更新补充任务相关信息
			Object[] o =(Object[])this.findOnlyRowBySql("select min(card_no),max(card_no)  from card_task_list l where l.task_id = '" + tempTask.getTaskId() + "'");
			tempTask.setStartCardNo(Tools.processNull(o[0]));
			tempTask.setEndCardNo(Tools.processNull(o[1]));
			publicDao.update(tempTask);
			//12.记录业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setBrchId(user.getBrchId());
			trServRec.setUserId(user.getUserId());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setNote(log.getMessage());
			trServRec.setCardType(tempTask.getCardType());
			trServRec.setCardAmt(Long.valueOf(tempTask.getTaskSum() + ""));
			trServRec.setClrDate(this.getClrDate());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			publicDao.merge(trServRec);
			publicDao.doSql("DELETE FROM card_apply_person_temp T WHERE T.oper_id = '" + user.getUserId() + "' and T.note is null  and T.emp_Name = '" + taskName + "' and t.deal_no="+dealno);
		} catch (Exception e) {
			throw new CommonException("导入申领保存出现错误:"+e.getMessage());
		}
		
	}
	/**
	 * 导入申领将文件导入临时表
	 * @param file     excel表格
	 * @param log      操作日志
	 * @return         业务日志
	 */
	public TrServRec saveImpApplyView(File file,String fileFileName, SysActionLog log) throws CommonException {
		TrServRec rec = new TrServRec();
		try{
			log.setDealCode(0);
			log.setMessage("导入申领EXCEl文件导入临时表：文件名" + fileFileName);
			publicDao.save(log);
			  //先删除
		    publicDao.doSql("delete from card_apply_person_temp p where p.oper_id='"+log.getUserId()+"'");
			rec.setDealCode(log.getDealCode());
			rec.setDealNo(log.getDealNo());
			rec.setNote(log.getMessage());
			List entityList=new ArrayList();
			HSSFWorkbook workbook = new HSSFWorkbook(new FileInputStream(file));
			if (workbook.getSheetAt(0)!= null) {
				HSSFSheet aSheet = workbook.getSheetAt(0);
				if(aSheet.getLastRowNum()==0){
					throw new CommonException("申领失败，导入文件中没有数据!");
				}
				for (int rowNumOfSheet = 1; rowNumOfSheet <= aSheet.getPhysicalNumberOfRows(); rowNumOfSheet++) {
					if (aSheet.getRow(rowNumOfSheet)!=null) {
						HSSFRow aRow = aSheet.getRow(rowNumOfSheet);
						Object[] o = new Object[6];
						for (short cellNumOfRow = 0; cellNumOfRow < 5; cellNumOfRow++) {
							if (aRow.getCell(cellNumOfRow)!=null) {
								HSSFCell aCell = aRow.getCell(cellNumOfRow);
								aCell.setCellType(Cell.CELL_TYPE_STRING);
								o[cellNumOfRow] = (aCell.getStringCellValue().trim()).replace(" ", "");
							}
						}
						entityList.add(rowNumOfSheet-1,o);
					}
				}
			}
			for(int i=0;i<entityList.size();i++){
				Object[] o=(Object[])entityList.get(i);
				StringBuffer sb = new StringBuffer("");
				sb.append(",'"+o[0]+"'"); //序列号
				sb.append(",'"+o[1]+"'"); //身份证号
				sb.append(",'"+o[2]+"'"); //姓名
				sb.append(",'"+o[3]+"'"); //med_whole_no
				sb.append(",'"+o[4]+"'"); //emp_name
				sb.append(",'"+o[5]+"'"); //COMPANYID
				int n = publicDao.doSql("select 1 from card_apply_person_temp where cert_no = '" + o[1] + "' and oper_id = '" + log.getUserId() + "'");
				if (n > 0) {
					continue;
				}
				String sql="insert into card_apply_person_temp(SEQ_ID,XH,cert_no,name,med_whole_no,emp_name,COMPANYID,oper_id) values(seq_CARD_APPLY_PERSON_TEMP.Nextval"+
				sb.toString()+",'"+log.getUserId()+"')";
				publicDao.doSql(sql);//保存到零时表
			}
			//1.判断是否已经申领
		    publicDao.doSql("update card_apply_person_temp t set t.note=t.note||'用户已申领过，不能重复申领!' where oper_id='"+log.getUserId()+"' and exists(select 1 from card_apply a,base_personal b where a.apply_state <> '90' and a.customer_id=b.customer_id and b.cert_no=t.cert_no)");
			//2.判断参保状态
		    publicDao.doSql("update card_apply_person_temp t set t.note=t.note||'参保状态不正常,或统筹编码不正确!' where oper_id='"+log.getUserId()+"' and not exists(select 1 from base_siinfo e where MED_STATE='0' and  e.med_whole_no=t.med_whole_no and e.cert_no=t.cert_no  )");
            //3.判断身份证是否重复
		    publicDao.doSql("update card_apply_person_temp t set t.note=t.note||'库中或导入文件中此身份证号码重复!' where oper_id='"+log.getUserId()+"' and t.cert_no in (select a.cert_no from card_apply_person_temp a,bs_person p where a.cert_no=p.cert_no and a.oper_id='admin' group by a.cert_no having count(*)>1)");
			//4.判断是否有照片
		    publicDao.doSql("update card_apply_person_temp t set t.note=t.note||'无照片或者照片状态不正常!' where oper_id='"+log.getUserId()+"' and not exists(select 1 from base_photo p,base_personal b where p.customer_id=b.customer_id and   b.cert_no=t.cert_no and p.photo_state=0 and p.photo is not null )");
             //5.判断人员的确认标志
		    publicDao.doSql("update card_apply_person_temp t set t.note=t.note||'人员状态不正常，或身份证编号和姓名不匹配!' where oper_id='"+log.getUserId()+"' and not exists(select 1 from base_personal b where  b.cert_no=t.cert_no and b.customer_state='0' and t.name=b.name )");
		   //更新流水号
		    publicDao.doSql("update card_apply_person_temp t set t.deal_No="+log.getDealNo()+" where oper_id='"+log.getUserId()+"'");
		    rec.setCardTrCount(publicDao.findOnlyFieldBySql("select count(*) from card_apply_person_temp p where p.oper_id='"+log.getUserId()+"' and p.deal_No="+log.getDealNo()).toString());
		} catch (Exception e) {
			throw new CommonException("导入申领出现错误："+e.getMessage());
		}
		return rec;
	}
    /**
     * 金融市民卡申领数据导入操作
     * @param file excel文件
     * @param rec 业务日志
     * @param actionLog 操作日志
     * @return rec
     */
	public TrServRec saveImportJrsbkApplyData(Workbook file,TrServRec rec,SysActionLog actionLog) throws CommonException{
        try{
            //1.基本条件判断
            if(file == null){
                throw new CommonException("导入的文件不能为空！");
            }
            if(rec == null){
                rec = new TrServRec();
            }
            if(actionLog == null){
                actionLog = this.getCurrentActionLog();
            }
            actionLog.setDealCode(DealCode.APPLY_JRSBK_IMPORT);
            actionLog.setMessage("金融市民卡导入申领人员数据导入");
            this.publicDao.save(actionLog);
            //2.导入文件判断
            Sheet sheet = file.getSheetAt(0);
            if(sheet == null){
                throw new CommonException("导入的人员数据EXCEL不正确，请仔细核对后重新进行导入！");
            }
            Row firstRow =  sheet.getRow(0);
            if(firstRow == null) {
                throw new CommonException("导入文件中第1行说明字段不正确！");
            }
            //3.导入文件格式判断
            String[] fileDefinedTit = {"姓名","证件号码","统筹区编码","任务名称","银行编码","领卡网点编码"};
            for(int i = 0;i < fileDefinedTit.length;i++){
                if(!Tools.processNull(this.getCellValue(firstRow,i)).equals(fileDefinedTit[i])){
                    throw  new CommonException("导入文件中第一行说明字段，第" + (i + 1) + "列说明不正确！");
                }
            }
            //4.循环读取每一行人员数据
            int firstRowNum = 1;
            int lastRowNum = sheet.getLastRowNum();
            Row tempRow = null;
            StringBuffer tempSb = new StringBuffer();
            long totRowNums = 0;
            String ctsBrchId = "";
            String ctsBankId = "";
            String ctsRegionId = "";
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
                String tempRegionId = getCellValue(tempRow,2).trim();
                if(Tools.processNull(tempRegionId).equals("")) {
                	throw new CommonException("导入文件中，第" + (i + 1) + "行，第" + 3 + "列字段不正确！");
                }
                if(!Tools.processNull(tempRegionId).equals(ctsRegionId)){
                	String tempRegionName = (String) this.findOnlyFieldBySql("select t.region_name from base_region t where t.region_id = '" + tempRegionId + "'");
                	if(Tools.processNull(tempRegionName).equals("")){
                		throw new CommonException("导入文件中，第" + (i + 1) + "行，第" + 3 + "列字段设置的统筹区编码不存在！");
                	}else{
                		ctsRegionId = tempRegionId;
                	}
                }
                String tempTaskName = getCellValue(tempRow,3).trim();
                if(Tools.processNull(tempTaskName).equals("")) {
                	throw new CommonException("导入文件中，第" + (i + 1) + "行，第" + 4 + "列字段不正确！");
                }
                String tempBankId = getCellValue(tempRow,4).trim();
                if(Tools.processNull(tempBankId).equals("")) {
                    throw new CommonException("导入文件中，第" + (i + 1) + "行，第" + 5 + "列字段不正确！");
                }
                String tempRecvBrchId = getCellValue(tempRow,5).trim();
                if(Tools.processNull(tempRecvBrchId).equals("")) {
                    throw new CommonException("导入文件中，第" + (i + 1) + "行，第" + 6 + "列字段不正确！");
                }
                String tempIsJudgeSbState = getCellValue(tempRow,6).trim();
                if(Tools.processNull(tempIsJudgeSbState).equals("是")) {
                	tempIsJudgeSbState = Constants.YES_NO_YES;
                } else {
                	tempIsJudgeSbState = Constants.YES_NO_NO;
                }
                if(!Tools.processNull(tempRecvBrchId).equals(ctsBrchId)){
                	String tempRecvBrchName = (String) this.findOnlyFieldBySql("select t.full_name from sys_branch t where t.brch_id = '" + tempRecvBrchId + "'");
                	if(Tools.processNull(tempRecvBrchName).equals("")){
                		throw new CommonException("导入文件中，第" + (i + 1) + "行，第" + 6 + "列字段设置的领卡网点不存在！");
                	}
                	ctsBrchId = tempRecvBrchId;
                	String tempBindBankId = (String) this.findOnlyFieldBySql("select t.bank_id from branch_bank t where t.brch_id = '" + tempRecvBrchId + "'");
                	if(Tools.processNull(tempBindBankId).equals("")){
                		throw new CommonException("导入文件中，第" + (i + 1) + "行，第" + 6 + "列字段设置的领卡网点未绑定银行！");
                	}
                	if(!Tools.processNull(tempBankId).equals(tempBindBankId)){
            			throw new CommonException("导入文件中，第" + (i + 1) + "行，第" + 5 + "列字段设置的银行编码和领卡网点绑定的银行不一致！");
            		}
                	ctsBankId = tempBindBankId;
                }else{
            		if(!Tools.processNull(tempBankId).equals(ctsBankId)){
            			throw new CommonException("导入文件中，第" + (i + 1) + "行，同一个领卡网点对应多个银行编码！");
            		}
                }
                String tempGender = "9";
                String tempCertType = "6";
                try{
                    if(tempCertNo.length() == 18){
                        if(Integer.valueOf(Character.toString(tempCertNo.charAt(16))) % 2 == 0){
                        	tempGender = "2";
                        }else{
                        	tempGender = "1";
                        }
                        tempCertType = "1";
                    }
                }catch(Exception e){
                }
                tempSb.append("'INSERT INTO BASE_PERSONAL_IMPORT (DATA_ID,CUSTOMER_ID,NAME,GENDER,CERT_TYPE,CERT_NO,REGION_ID,COUNTRY,");
                tempSb.append("BANK_ID,INSERT_DATE,DEAL_STATE,DEAL_MSG,LINE_NUM,TASK_NAME,RECV_BRCH_ID,APPLY_TYPE,DEAL_NO,NOTE,IS_JUDGE_SB_STATE) values (");
                tempSb.append("SEQ_BASE_PERSONAL_TEMP.NEXTVAL,NULL,''" + tempName + "'',''" + tempGender + "'',''" + tempCertType + "'',");
                tempSb.append("''" + tempCertNo + "'',''" + tempRegionId + "'',''" + "142" + "'',''" + tempBankId + "'',to_date(''");
                tempSb.append(DateUtil.formatDate(actionLog.getDealTime()) + "'',''yyyy-mm-dd hh24:mi:ss''),''" + "0" + "'',''" + "" + "'',");
                tempSb.append(i + ",''" + tempTaskName + "'',''" + tempRecvBrchId + "'',''" + "0" + "''," + actionLog.getDealNo() + ",null,''" + tempIsJudgeSbState + "'')',");
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
            //5.记录导入总表
            BasePersonalImportBatch personalTempBatch = new BasePersonalImportBatch();
            personalTempBatch.setDealNo(actionLog.getDealNo());
            personalTempBatch.setInsertDate(actionLog.getDealTime());
            personalTempBatch.setTotNums(totRowNums);
            personalTempBatch.setErrNums(0L);
            personalTempBatch.setSucNums(0L);
            personalTempBatch.setNotApplyNums(0L);
            personalTempBatch.setApplyNums(0L);
            personalTempBatch.setOrgId(actionLog.getOrgId());
            personalTempBatch.setBrchId(actionLog.getBrchId());
            personalTempBatch.setUserId(actionLog.getUserId());
            personalTempBatch.setNote(actionLog.getMessage());
			personalTempBatch.setState("0");
            publicDao.save(personalTempBatch);
            //6.调取过程进行数据比较
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
            List<?> ret = publicDao.callProc("PK_CARD_APPLY_ISSUSE.P_PERSONAL_COMPARE",inParams,outParams);
            if(!(ret == null || ret.size() == 0)){
                int res = Integer.parseInt(ret.get(0).toString());
                if(res != 0){
                    String outMsg = ret.get(1).toString();
                    throw new CommonException(outMsg);
                }
            }else{
                throw new CommonException("导入人员数据比较出现错误，请重新进行操作！");
            }
            //7.记录业务日志
            rec.setDealNo(actionLog.getDealNo());
            rec.setDealCode(actionLog.getDealCode());
            rec.setDealCode(actionLog.getDealCode());
            rec.setNote(actionLog.getMessage());
            rec.setOrgId(actionLog.getOrgId());
            rec.setUserId(actionLog.getUserId());
            rec.setClrDate(this.getClrDate());
			rec.setBrchId(actionLog.getBrchId());
            rec.setDealState(Constants.STATE_ZC);
            rec.setCardAmt(totRowNums);
            rec.setBizTime(actionLog.getDealTime());
            rec.setNum(totRowNums);
            rec.setAmt(0L);
            publicDao.save(rec);
            return rec;
        }catch(Exception e){
            throw new CommonException(e.getMessage());
        }
    }
	/**
     * 金融市民卡申领导入人员数据删除
     * @param dealNo
     * @param oper
     * @param actionLog
     * @return
     * @throws CommonException
     * TrServRec
     */
	public TrServRec saveDelJrsbkApplyImportData(Long dealNo,Users oper,SysActionLog actionLog) throws CommonException{
		try{
            if(dealNo == null){
                throw new CommonException("导入的流水编号不能为空！");
            }
            if(oper == null){
                throw new CommonException("操作员不能为空！");
            }
            if(actionLog == null){
                actionLog = this.getCurrentActionLog();
            }
            actionLog.setDealCode(DealCode.APPLY_JRSBK_DEL);
            actionLog.setMessage("金融市民卡导入人员数据删除");
            this.publicDao.save(actionLog);
            BasePersonalImportBatch batch = (BasePersonalImportBatch) this.findOnlyRowByHql("from BasePersonalImportBatch t where t.dealNo = " + dealNo);
            if(batch == null){
            	throw new CommonException("根据流水编号" + dealNo + "找不到导入的文件信息！");
            }
            if(batch.getApplyNums() > 0){
            	throw new CommonException("该导入文件已有人员进行申领，无法进行删除！");
            }
            this.publicDao.doSql("DELETE FROM BASE_PERSONAL_IMPORT_BATCH WHERE DEAL_NO = " + dealNo);
            this.publicDao.doSql("DELETE FROM BASE_PERSONAL_IMPORT WHERE DEAL_NO = " + dealNo);
			TrServRec rec = new TrServRec();
            rec.setDealNo(actionLog.getDealNo());
            rec.setDealCode(actionLog.getDealCode());
            rec.setBrchId(oper.getBrchId());
            rec.setUserId(oper.getUserId());
            rec.setBizTime(actionLog.getDealTime());
            rec.setClrDate(this.getClrDate());
            rec.setDealState(Constants.STATE_ZC);
            rec.setOrgId(oper.getOrgId());
            rec.setOldDealNo(dealNo);
            rec.setNote(actionLog.getMessage());
			return rec;
		}catch(Exception e){
            throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 金融市民卡申领导入人员数据申领
	 * @param ids
	 * @param oper
	 * @param log
	 * @return
	 * @throws CommonException
	 */
	public Map<String,String> saveJrsbkApplyImportDataApply(String ids,Users oper,SysActionLog ctsLog, boolean onlyAppNewCard, boolean onlyAppHFCard) throws CommonException{
		try{
			Map<String,String> map = new HashMap<String,String>();
			if(Tools.processNull(ids).equals("")){
				throw new CommonException("请勾选需要进行申领的导入文件记录信息！");
			}
			if(oper == null || Tools.processNull(oper.getUserId()).equals("")){
				throw new CommonException("操作柜员不正确！");
			}
			if(ctsLog == null){
				ctsLog = this.getCurrentActionLog();
			}
			BasePersonalImportBatch batch = (BasePersonalImportBatch) this.findOnlyRowByHql("from BasePersonalImportBatch where dealNo = " + ids);
			if(batch == null){
				throw new CommonException("根据流水编号" + ids + "找不到导入文件记录信息！");
			}
			if(!Tools.processNull(batch.getState()).equals("1") && !Tools.processNull(batch.getState()).equals("2")){
				throw new CommonException("根据流水编号" + ids + "找到的导入文件记录不是【已比对】状态！");
			}
			if(batch.getSucNums() == null || batch.getSucNums() <= 0){
				throw new CommonException("勾选的流水编号为【" + ids + "】的记录，比对成功的数量不正确！");
			}
			String city_code = Tools.tensileString(this.findOnlyFieldBySql("SELECT PARA_VALUE FROM SYS_PARA WHERE PARA_CODE = 'CITY_CODE'").toString(),4,true,"0");
			if(Tools.processNull(city_code).trim().equals("")){
				throw new CommonException("城市代码不能为空，SYS_PARA中找不到参数CITY_CODE");
			}
			Object[] branch_card_flag = (Object[])this.findOnlyRowBySql("SELECT B.CARD_FLAG,B.REGION_CODE FROM SYS_BRANCH S,BASE_REGION B WHERE S.REGION_ID = B.REGION_ID AND S.BRCH_ID = '" + oper.getBrchId() + "'");
			if(branch_card_flag == null || branch_card_flag.length <= 0){
				throw new CommonException("网点所属区域或区域区编码设置不正确！");
			}
			if(Tools.processNull(branch_card_flag[0]).equals("") || Tools.processNull(branch_card_flag[0]).length() != 1){
				throw new CommonException("网点所属区域的CARD_FLAG字段设置不正确！");
			}
			if(Tools.processNull(branch_card_flag[1]).equals("") || Tools.processNull(branch_card_flag[1]).length() != 2){
				throw new CommonException("网点所属区域的REGION_CODE字段设置不正确！");
			}
			//
			CardApplyTask ctsTask = new CardApplyTask();
			ctsTask.setTaskDate(ctsLog.getDealTime());
			ctsTask.setTaskState(Constants.TASK_STATE_YSC);
			ctsTask.setTaskOrgId(oper.getOrgId());
			ctsTask.setTaskBrchId(oper.getBrchId());
			ctsTask.setTaskOperId(oper.getUserId());
			ctsTask.setIsPhoto(this.getSysConfigurationParameters("IS_PHOTO"));
			ctsTask.setTaskSrc(Constants.TASK_SRC_GMSL);
			ctsTask.setIsUrgent(Tools.processNull(Constants.URGENT_WB));
			ctsTask.setCardType(Constants.CARD_TYPE_SMZK);
			ctsTask.setTaskWay(Constants.TASK_WAY_DR);
			ctsTask.setIsList(Constants.YES_NO_YES);
			ctsTask.setIsBatchHf(Constants.YES_NO_NO);
			ctsTask.setIsJudgeSbState(Constants.YES_NO_YES);
			ctsLog.setDealCode(DealCode.APPLY_JRSBK_APPLY);
			ctsTask.setIsJrsbkDr(Constants.YES_NO_YES);
			ctsTask.setDealCode(ctsLog.getDealCode());
			ctsTask.setCardType(Constants.CARD_TYPE_SMZK);
			CardConfig config = (CardConfig) this.findOnlyRowByHql("from CardConfig where cardType = '" + ctsTask.getCardType() + "'");
			//
			String sql = "SELECT REGION_ID,RECV_BRCH_ID,TASK_NAME, max(is_judge_sb_state) FROM BASE_PERSONAL_IMPORT WHERE DEAL_STATE = '2' AND DEAL_NO = '" + ids + "' ";
			if (onlyAppNewCard) { // 仅申领新卡
				sql += "AND apply_type = '0' ";
			} else if (onlyAppHFCard) { // 仅申领换发卡
				sql += "AND apply_type = '1' ";
			}
			sql += "GROUP BY REGION_ID,RECV_BRCH_ID,TASK_NAME order by min(data_id)";
			List<?> cts  = this.findBySql(sql);
			if(cts == null || cts.isEmpty()){
				throw new CommonException("根据流水编号【" + ids + "】找不到区域、领卡网点、任务名称等信息！");
			}
			Long totNums = 0L;
			Long taskNums = 0L;
			Long totNotApplyNums = 0L;
			for(int i = 0;i < cts.size();i++){
				Object[] obj = (Object[]) cts.get(i);
				SysActionLog log = (SysActionLog) BeanUtils.cloneBean(ctsLog);
				log.setMessage("金融市民卡导入申领，文件流水deal_no=" + ids + ",区域region_id=" + Tools.processNull(obj[0]) + ",领卡网点recv_brch_id=" + Tools.processNull(obj[1]) + ",任务名称task_name=" + Tools.processNull(obj[2]));
				this.publicDao.save(log);
				CardApplyTask task = (CardApplyTask) BeanUtils.cloneBean(ctsTask);
				task.setMedWholeNo(Tools.processNull(obj[0]));
				task.setBrchId(Tools.processNull(obj[1]));
				task.setTaskId(DateUtil.formatDate(ctsLog.getDealTime(),"yyyyMMdd") + Tools.tensileString(this.getSequenceByName("seq_cm_card_task"),8,true,"0"));
				task.setTaskName(Tools.processNull(obj[2]));
				task.setIsJudgeSbState(Tools.processNull(obj[3]));
				if(onlyAppHFCard){
					task.setIsBatchHf("0");
				}
				if(Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_SMZK)){
					String shBankId = (String) this.findOnlyFieldBySql("select bank_id from branch_bank where brch_id = '" + task.getBrchId() + "'");
					if(Tools.processNull(shBankId).equals("")){
						throw new CommonException(task.getTaskName() + "设置的领卡网点未绑定银行！");
					}
					task.setBankId(shBankId);
					String bankName = (String) this.findOnlyFieldBySql("select co_org_name from base_co_org where co_org_id = '" + shBankId + "'");
					if(Tools.processNull(bankName).equals("")){
						throw new CommonException(task.getTaskName() + "领卡网点绑定的银行信息不存在！");
					}
				}
				StringBuffer slsql = new StringBuffer();
				publicDao.doSql("DELETE FROM CARD_APPLY_DRSL_TEMP T WHERE T.APPLY_USER_ID = '" + oper.getUserId() + "'");
				slsql.append("INSERT INTO CARD_APPLY_DRSL_TEMP(APPLY_ID,BAR_CODE,CUSTOMER_ID,CARD_NO,SUB_CARD_NO,CARD_TYPE,BANK_ID,VERSION,ORG_CODE,");
				slsql.append("CITY_CODE,INDUS_CODE,APPLY_WAY,APPLY_TYPE,MAKE_TYPE,APPLY_BRCH_ID,CORP_ID,COMM_ID,TOWN_ID,APPLY_STATE,APPLY_USER_ID,");
				slsql.append("APPLY_DATE,COST_FEE,FOREGIFT,IS_URGENT,URGENT_FEE,IS_PHOTO,RECV_BRCH_ID,BUS_TYPE, MAIN_FLAG,OTHER_FEE,WALLET_USE_FLAG,DEAL_NO,BKVEN_ID,GROUP_ID,MED_WHOLE_NO,IS_BATCH_HF,IS_JUDGE_SB_STATE,TASK_NAME,DATA_ID) ");
				slsql.append("SELECT SEQ_APPLY_ID.NEXTVAL,LPAD(SEQ_BAR_CODE.NEXTVAL,9,'0'),B.CUSTOMER_ID,NVL(H.REGION_CODE,'" + Tools.processNull(branch_card_flag[1]) + "'),");
				if(Tools.processNull(task.getIsBatchHf()).equals(Constants.YES_NO_YES)){
					slsql.append("(NVL(PK_CARD_APPLY_ISSUSE.P_GETLASTSUBCARDNO(B.CUSTOMER_ID),PK_PUBLIC.CREATESUBCARDNO(NVL(H.CARD_FLAG,'" + Tools.processNull(branch_card_flag[0]) + "'),LPAD(SEQ_SUB_CARD_NO.NEXTVAL,7,'0')))),'");
				}else{
					//slsql.append("PK_PUBLIC.CREATESUBCARDNO(NVL(H.CARD_FLAG,'" + Tools.processNull(branch_card_flag[0]) + "'),LPAD(SEQ_SUB_CARD_NO.NEXTVAL,7,'0')),'");
					slsql.append("(NVL(PK_CARD_APPLY_ISSUSE.P_GETLASTSUBCARDNO(B.CUSTOMER_ID),PK_PUBLIC.CREATESUBCARDNO(NVL(H.CARD_FLAG,'" + Tools.processNull(branch_card_flag[0]) + "'),LPAD(SEQ_SUB_CARD_NO.NEXTVAL,7,'0')))),'");
				}
				slsql.append(task.getCardType() + "','" + Tools.processNull(task.getBankId()) + "','" + Constants.CARD_VERSION + "','" + Constants.INIT_ORG_ID + "','" + city_code + "','");
				slsql.append(Constants.INDUS_CODE + "','" + task.getTaskWay() + "','" + Constants.APPLY_TYPE_CCSL + "','" + "1" + "','");
				slsql.append(oper.getBrchId() + "','" + Tools.processNull(task.getCorpId()) + "',/*B.COMM_ID*/NULL,/*B.TOWN_ID*/NULL,'");
				slsql.append(Constants.APPLY_STATE_RWYSC + "','" + oper.getUserId() + "',TO_DATE('");
				slsql.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','YYYY-MM-DD HH24:MI:SS'),0,0,'" + task.getIsUrgent() + "',0,'" + Tools.processNull(task.getIsPhoto()) + "','" + Tools.processNull(task.getBrchId()) + "',");
				slsql.append("'00','',0,'" + Constants.BUS_USE_FLAG_QB + "'," + log.getDealNo() + ",'" + Tools.processNull(task.getVendorId()) + "','" + Tools.processNull(task.getGroup_Id()) + "',NVL(B.REGION_ID,'" + this.getBrchRegion()  + "'),(CASE WHEN B.APPLY_TYPE = '0' THEN '1' WHEN B.APPLY_TYPE = '1' THEN '0' END),'" + task.getIsJudgeSbState() + "',B.TASK_NAME,B.DATA_ID ");
				slsql.append("FROM BASE_PERSONAL_IMPORT B " );
				if(Tools.processNull(task.getIsJudgeSbState()).equals(Constants.YES_NO_YES)){
					slsql.append("INNER JOIN ");
				}else if(Tools.processNull(task.getIsJudgeSbState()).equals(Constants.YES_NO_NO)){
					slsql.append("LEFT JOIN ");
				}else{
					throw new CommonException("是否判断医保参数不正确！");
				}
				slsql.append("BASE_SIINFO F ON (B.CERT_NO = F.CERT_NO AND B.CUSTOMER_ID = F.CUSTOMER_ID AND F.MED_STATE = '0' AND F.MED_WHOLE_NO = B.REGION_ID) ");
				if(Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_SQ)){
					slsql.append(",BASE_REGION R,BASE_TOWN W,BASE_COMM M ");
				}
				slsql.append("LEFT JOIN BASE_REGION H ON (B.REGION_ID = H.REGION_ID) ");
				slsql.append("WHERE B.DEAL_STATE = '2' AND B.DEAL_NO = " + batch.getDealNo() + " AND B.RECV_BRCH_ID = '" + task.getBrchId() + "' AND B.TASK_NAME = '" + task.getTaskName() + "' AND B.REGION_ID = '" + task.getMedWholeNo() + "' ");
				if(Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_SQ)){
					slsql.append("AND B.REGION_ID = R.REGION_ID AND B.TOWN_ID = W.TOWN_ID AND B.COMM_ID = M.COMM_ID AND R.REGION_ID = W.REGION_ID AND W.TOWN_ID = M.TOWN_ID ");
				}
				// 仅申领新卡 和 仅申领换发卡 判断
				if (onlyAppNewCard) { // 仅申领新卡
					slsql.append("AND b.apply_type = '0' ");
				} else if (onlyAppHFCard) { // 仅申领换发卡
					slsql.append("AND b.apply_type = '1' ");
				}
				slsql.append("AND NOT EXISTS (SELECT 1 FROM CARD_APPLY A WHERE A.CUSTOMER_ID = B.CUSTOMER_ID ");
				slsql.append("AND (A.APPLY_STATE < '" + Constants.APPLY_STATE_YZX + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_WJWSHBTG + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_YZX  + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_YHSHBTG + "' ");
				slsql.append("AND A.CARD_TYPE = '" + Constants.CARD_TYPE_SMZK + "')) ");
				if(Tools.processNull(task.getIsPhoto()).equals(Constants.YES_NO_YES)){
					slsql.append("AND EXISTS (SELECT 1 FROM BASE_PHOTO P WHERE P.CUSTOMER_ID = B.CUSTOMER_ID AND P.PHOTO_STATE = '0' AND LENGTHB(P.PHOTO) > 0) ");
				}
				int allCount = publicDao.doSql(slsql.toString());
				/*if(allCount == 0){
					throw new CommonException("共有 0 个人员符合申领条件，本次操作无效，请仔细核对后重新进行操作！");
				}*/
				int region_Code_Count = publicDao.findBySQL("SELECT 1 FROM CARD_APPLY_DRSL_TEMP WHERE LENGTH(CARD_NO) != 2 AND APPLY_USER_ID = '" + oper.getUserId() + "' AND DEAL_NO = " + log.getDealNo()).size();
				if(region_Code_Count != 0){
					throw new CommonException("当前申领人员中有\"" + region_Code_Count + "\"个人所在区县编号为空，请先设置城区编码");
				}
				task.setTaskSum(allCount);
                task.setDealNo(log.getDealNo());
				publicDao.save(task);
				publicDao.doSql("UPDATE CARD_APPLY_DRSL_TEMP C SET C.TASK_ID = " + task.getTaskId() + " WHERE APPLY_USER_ID = '" + oper.getUserId() + "' AND DEAL_NO = " + log.getDealNo());
				this.publicDao.doSql("UPDATE BASE_PERSONAL_IMPORT T SET (T.DEAL_STATE,T.TASK_ID,T.APPLY_ID) = (SELECT '3',B.TASK_ID,B.APPLY_ID FROM CARD_APPLY_DRSL_TEMP B WHERE B.DEAL_NO = " + log.getDealNo() + " AND B.DATA_ID = T.DATA_ID) WHERE T.DEAL_NO = " + ids + 
				" AND REGION_ID = '" + Tools.processNull(task.getMedWholeNo()) + "' AND T.RECV_BRCH_ID = '" + Tools.processNull(task.getBrchId()) + "' AND T.TASK_NAME = '" + task.getTaskName() + "' AND T.DEAL_STATE = '2'");
				if(Tools.processNull(task.getIsUrgent()).equals(Constants.URGENT_WB)){
					List<?> cardno = this.findBySql("SELECT CARD_TYPE,CARD_NO,COUNT(1) FROM CARD_APPLY_DRSL_TEMP T WHERE T.APPLY_USER_ID = '" + oper.getUserId() + "' AND DEAL_NO = " + log.getDealNo() + " GROUP BY CARD_TYPE,CARD_NO ");
					for(int n = 0;n < cardno.size();n++){
						Object[] o = (Object[])cardno.get(n);
						try{
							this.createCardNo(Tools.processNull(o[0]),o[1].toString(),((BigDecimal)(o[2])).longValue(),log.getDealNo());
						}catch(Exception e){
							throw new CommonException(e.getMessage());
						}finally{
							DEAL_CARD_NO_WAIT = false;
						}
						String updatecardno = "MERGE INTO CARD_APPLY_DRSL_TEMP D USING (SELECT A.CARD_NO,B.APPLY_ID FROM (SELECT CARD_NO,ROWNUM RN " +
						"FROM CARD_NO WHERE USED = 0 AND REGION_CODE = '" + Tools.processNull(o[1]) + "' AND DEAL_NO = " + log.getDealNo() +
						") A, (SELECT APPLY_ID,ROWNUM RN FROM CARD_APPLY_DRSL_TEMP WHERE CARD_TYPE = '" + Tools.processNull(o[0]) +
						"' AND CARD_NO = '" + Tools.processNull(o[1]) + "' AND DEAL_NO = " + log.getDealNo() + ") B WHERE A.RN = B.RN) C ON (D.APPLY_ID = C.APPLY_ID) WHEN MATCHED THEN UPDATE SET D.CARD_NO = C.CARD_NO";
						publicDao.doSql(updatecardno);
					}
				}else if(Tools.processNull(task.getIsUrgent()).equals(Constants.URGENT_BD)){
					publicDao.doSql("UPDATE CARD_APPLY_DRSL_TEMP T SET T.CARD_NO = '' WHERE T.TASK_ID = '" + task.getTaskId() + "' AND DEAL_NO = " + log.getDealNo());
				}else{
                    throw new CommonException("制卡方式不正确！");
                }
				//9.规模申领临时表数据移动到正式申领表
				StringBuffer insertApplySql = new StringBuffer();
				insertApplySql.append("INSERT INTO CARD_APPLY (APPLY_ID,BAR_CODE,CUSTOMER_ID,CARD_NO,TASK_ID,SUB_CARD_NO,CARD_TYPE,SUB_CARD_TYPE,");
				insertApplySql.append("BANK_ID,BANK_CARD_NO,VERSION,ORG_CODE,CITY_CODE,INDUS_CODE,APPLY_WAY,APPLY_TYPE,MAKE_TYPE,APPLY_BRCH_ID,CORP_ID,");
				insertApplySql.append("APPLY_STATE,APPLY_USER_ID,APPLY_DATE,COST_FEE,FOREGIFT,IS_URGENT,IS_PHOTO,RECV_BRCH_ID,");
				insertApplySql.append("RECV_CERT_TYPE,RECV_CERT_NO,RECV_NAME,RELS_BRCH_ID,RELS_USER_ID,RELS_DATE,AGT_CERT_TYPE,AGT_CERT_NO,AGT_NAME,");
				insertApplySql.append("AGT_PHONE,DEAL_NO,NOTE,BUS_TYPE,OLD_CARD_NO,OLD_SUB_CARD_NO,MESSAGE_FLAG,MOBILE_PHONE,MAIN_FLAG,MAIN_CARD_NO,");
				insertApplySql.append("OTHER_FEE,WALLET_USE_FLAG,MONTH_TYPE,MONTH_CHARGE_MODE,TOWN_ID,COMM_ID,GROUP_ID,BKVEN_ID,MED_WHOLE_NO,IS_BATCH_HF,IS_JUDGE_SB_STATE) ");
				insertApplySql.append("SELECT T.APPLY_ID,T.BAR_CODE,T.CUSTOMER_ID,T.CARD_NO,T.TASK_ID,T.SUB_CARD_NO,");
				insertApplySql.append("T.CARD_TYPE,T.SUB_CARD_TYPE,T.BANK_ID,T.BANK_CARD_NO,T.VERSION,T.ORG_CODE,T.CITY_CODE,T.INDUS_CODE,T.APPLY_WAY,");
				insertApplySql.append("T.APPLY_TYPE,T.MAKE_TYPE,T.APPLY_BRCH_ID,T.CORP_ID,T.APPLY_STATE,T.APPLY_USER_ID,T.APPLY_DATE,");
				insertApplySql.append("T.COST_FEE,T.FOREGIFT,T.IS_URGENT,T.IS_PHOTO,T.RECV_BRCH_ID,T.RECV_CERT_TYPE,T.RECV_CERT_NO,T.RECV_NAME,T.RELS_BRCH_ID,");
				insertApplySql.append("T.RELS_USER_ID,T.RELS_DATE,T.AGT_CERT_TYPE,T.AGT_CERT_NO,T.AGT_NAME,T.AGT_PHONE,T.DEAL_NO,NULL,'00',");//嘉兴公交类型00
				insertApplySql.append("T.OLD_CARD_NO,T.OLD_SUB_CARD_NO,T.MESSAGE_FLAG,T.MOBILE_PHONE,T.MAIN_FLAG,T.MAIN_CARD_NO,T.OTHER_FEE,T.WALLET_USE_FLAG,T.MONTH_TYPE,");
				insertApplySql.append("T.MONTH_CHARGE_MODE,T.TOWN_ID,T.COMM_ID,T.GROUP_ID,T.BKVEN_ID,T.MED_WHOLE_NO,T.IS_BATCH_HF,T.IS_JUDGE_SB_STATE FROM CARD_APPLY_DRSL_TEMP T WHERE T.APPLY_USER_ID = '" + oper.getUserId() + "' and t.deal_no = " + log.getDealNo());
				int cardapplycount = publicDao.doSql(insertApplySql.toString());
				if(cardapplycount != task.getTaskSum()){
					throw new CommonException("生成申领记录数量和临时申领处理数量不一致！");
				}
				insertCardtasklist(task,config);
				Object[] o =(Object[])this.findOnlyRowBySql("SELECT MIN(CARD_NO),MAX(CARD_NO) FROM CARD_TASK_LIST L WHERE L.TASK_ID = '" + task.getTaskId() + "'");
				task.setStartCardNo(Tools.processNull(o[0]));
				task.setEndCardNo(Tools.processNull(o[1]));
				publicDao.update(task);
				totNums += task.getTaskSum();
				TrServRec rec = new  TrServRec();
				rec.setDealNo(log.getDealNo());
				rec.setDealCode(log.getDealCode());
				rec.setBrchId(oper.getBrchId());
				rec.setUserId(oper.getUserId());
				rec.setBizTime(log.getDealTime());
				rec.setNote(log.getMessage());
				rec.setCardType(task.getCardType());
				rec.setCardAmt(Long.valueOf(task.getTaskSum() + ""));
				rec.setAmt(0L);
				rec.setNum(Long.valueOf(task.getTaskSum() + ""));
				rec.setClrDate(this.getClrDate());
				rec.setDealState(Constants.TR_STATE_ZC);
				this.publicDao.save(rec);
				taskNums++;
				//优化处
				int notApplyNums = this.publicDao.doSql("UPDATE BASE_PERSONAL_IMPORT T SET T.DEAL_STATE = '4' WHERE T.DEAL_NO = " + ids + " AND T.DEAL_STATE NOT IN ('1','3') AND T.RECV_BRCH_ID = '" + task.getBrchId() + "' AND T.TASK_NAME = '" + task.getTaskName() + "' AND T.REGION_ID = '" + task.getMedWholeNo() + "' ");
				if(batch.getApplyNums() == null || Tools.processNull(batch.getApplyNums()).equals("")){
					batch.setApplyNums(0L);
				}
				if(batch.getNotApplyNums() == null || Tools.processNull(batch.getNotApplyNums()).equals("")){
					batch.setNotApplyNums(0L);
				}
				batch.setApplyNums(task.getTaskSum() + batch.getApplyNums());
				batch.setNotApplyNums(Long.valueOf(notApplyNums + "") + batch.getNotApplyNums());
				totNotApplyNums += notApplyNums;
				if(i == (cts.size() - 1)){
					batch.setState("3");//3 全部申领
				}else{
					batch.setState("2");//3 全部申领
				}
				this.publicDao.update(batch);
				this.publicDao.doSql("commit");
			}
			batch.setState("3");//3 全部申领
			this.publicDao.update(batch);
            map.put("totApplyNums",totNums + "");
            map.put("totNotApplyNums",totNotApplyNums + "");
            map.put("taskNums",taskNums + "");//生成任务个数
			return map;
		}catch(Exception e){
			logger.error(e);
			throw new CommonException(e.getMessage());
		}
	}

    /**
     * 人员数据导入获取单元格数据
     * @param row 行信息
     * @param colIndex 单元格索引
     * @return 值信息
     */
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
    public DoWorkClientService getDoWorkClientService() {
        return doWorkClientService;
    }
    @Resource(name="doWorkClientService")
    public void setDoWorkClientService(DoWorkClientService doWorkClientService) {
        this.doWorkClientService = doWorkClientService;
    }
    
    @Override
	public String saveAppSnap(String selectId, String batchNo, String isBatchHf, List<String> certNoList) {
		try {
			if (Tools.processNull(selectId).equals("")) {
				throw new Exception("申领参数列表为空！");
			}
			//
			String[] conts = selectId.split("\\|");
			String applyWay = conts[0];
			String regionId = "";
			String townId = "";
			String commId = "";
			String groupId = "";
			String corpId = "";
			String isPhoto = "";
			String isJudgeSbState = "";
			//
			try {
				if (Constants.APPLY_WAY_SQ.equals(applyWay)) {
					regionId = conts[1];
					townId = conts[2];
					commId = conts[3];
					groupId = conts[4];
					isPhoto = conts[8];
					isJudgeSbState = conts[9];
				} else if (Constants.APPLY_WAY_DW.equals(applyWay)) {
					corpId = conts[1];
					isPhoto = conts[5];
					isJudgeSbState = conts[6];
				} else {
					throw new Exception("申领方式【" + applyWay + "】不正确！");
				}
			} catch (Exception e) {
				throw new Exception("解析申领参数异常，" + e.getMessage());
			}
			// 保存历史明细
			String dealNo = getSequenceByName("seq_action_no");
			if (certNoList != null && !certNoList.isEmpty()) { // 按人员（导入人员可能不是单位人员）
				//
				StringBuilder sql = new StringBuilder();
				for (int c = 0; c < certNoList.size(); c++) { // 人员太多不能用sql直接批量插入，只好分段了
					sql.append("'insert into batch_apply_snap_detail (deal_no, cert_no) values (" + dealNo + ", ''" + certNoList.get(c) + "'')',");
					//
					if ((c + 1) % 500 == 0) {
						publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + sql.substring(0, sql.length() - 1) + "))");
						sql.delete(0, sql.length());
					}
				}
				if (sql.length() > 0) {
					publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + sql.substring(0, sql.length() - 1) + "))");
					sql.delete(0, sql.length());
				}
				// 处理数据
				publicDao.doSql("update batch_apply_snap_detail t set sure_flag = '6' where deal_no = " + dealNo + " and not exists (select 1 from base_personal where cert_no = t.cert_no)");
				publicDao.doSql("update batch_apply_snap_detail t set customer_id = (select customer_id from base_personal where cert_no = t.cert_no), name = (select name from base_personal where cert_no = t.cert_no), cert_type = (select cert_type from base_personal where cert_no = t.cert_no) where deal_no = " + dealNo);
				publicDao.doSql("update batch_apply_snap_detail t set sure_flag = '2' where deal_no = " + dealNo + " and exists (select 1 from base_personal where customer_id = t.customer_id and customer_state <> '0')");
				publicDao.doSql("update batch_apply_snap_detail t set sure_flag = '3' where deal_no = " + dealNo + " and not exists (select 1 from base_siinfo where customer_id = t.customer_id and cert_no = t.cert_no and name = t.name and med_state = '0' and med_whole_no = '" + getBrchRegion() + "')");
				publicDao.doSql("update batch_apply_snap_detail t set sure_flag = '4' where deal_no = " + dealNo + " and not exists (select 1 from base_photo where customer_id = t.customer_id and photo_state = '0')");
				publicDao.doSql("update batch_apply_snap_detail t set sure_flag = '5' where deal_no = " + dealNo + " and not exists (select 1 from base_personal where customer_id = t.customer_id and corp_customer_id = '" + corpId + "')");
				publicDao.doSql("update batch_apply_snap_detail t set sure_flag = '7' where deal_no = " + dealNo + " and exists (select 1 from card_apply where customer_id = t.customer_id and card_type = '120' and apply_state < '90' and apply_state not in ('12', '15', '70'))");
				if(Tools.processNull(isBatchHf).equals("0")){
					publicDao.doSql("update batch_apply_snap_detail t set sure_flag = '8' where deal_no = " + dealNo + " and not exists (select 1 from card_baseinfo where customer_id = t.customer_id and card_type = '100' and card_state < '9')");
				} else {
					publicDao.doSql("update batch_apply_snap_detail t set sure_flag = '9' where deal_no = " + dealNo + " and exists (select 1 from card_baseinfo where customer_id = t.customer_id and card_type = '100' and card_state < '9')");
				}
			} else { // 直接按单位（或社区）
				String sql = getSql(isBatchHf, applyWay, regionId, dealNo, townId, commId, groupId, corpId, isPhoto, isJudgeSbState, null);
				publicDao.doSql("insert into batch_apply_snap_detail " + sql);
			}
			// 保存历史
			int r = publicDao.doSql("insert into batch_apply_snap(deal_no, apply_way, corp_id, region_id, town_id, comm_id, group_id, no_app_num, can_app_num, app_num, batch_no, is_batch_hf) "
					+ "values('" + dealNo  + "', '" + applyWay + "', '" + corpId + "', '" + regionId + "', '" + townId + "', '" + commId + "', '" + groupId + "', 0, 0, 0, '" + batchNo + "', '" + isBatchHf + "')");
			if(r != 1){
				throw new Exception("保存【batch_apply_snap】失败！");
			}
			String noAppNum = (String) findOnlyFieldBySql("select to_char(count(1)) from batch_apply_snap_detail where deal_no = '" + dealNo + "'");
			String canAppNum = (String) findOnlyFieldBySql("select to_char(count(1)) from batch_apply_snap_detail where deal_no = '" + dealNo + "' and sure_flag = '1'");
			r = publicDao.doSql("update batch_apply_snap set no_app_num = '" + noAppNum + "', can_app_num = '" + canAppNum + "' where deal_no = '" + dealNo + "'");
			if(r != 1){
				throw new Exception("更新【batch_apply_snap】失败！");
			}
			//
			return dealNo;
		} catch (Exception e) {
			throw new CommonException("保存申领历史状态失败, " + e.getMessage());
		}
	}
    
	private String getSql(String isBatchHf, String applyWay, String regionId, String dealNo, String townId, String commId, String groupId, String corpId, String isPhoto, String isJudgeSbState, String certNos) {
		String sql = "select '" + dealNo + "', psn.customer_id, psn.name, psn.cert_type, psn.cert_no, "
				+ "nvl2(t5.customer_id, decode(psn.customer_state, 0, decode('" + isJudgeSbState + "', '0', nvl2(x.customer_id, decode('" + isPhoto + "', '0', nvl2(pho.customer_id, '1', '4'), '1'), '3'), decode('" + isPhoto + "', '0', nvl2(pho.customer_id, '1', '4'), '1')), '2'), '5') SURE_FLAG "
				+ "from base_personal psn left join base_siinfo x on psn.customer_id = x.customer_id and x.cert_no = psn.cert_no and x.name = psn.name ";
		if (Tools.processNull(isJudgeSbState).equals(Constants.YES_NO_YES)) {
			sql += "and x.med_state = '0' and x.med_whole_no = '" + getBrchRegion() + "' ";
		}
		if (Tools.processNull(applyWay).equals(Constants.APPLY_WAY_SQ)) {
			sql += "left join base_region t on psn.region_id = t.region_id "
					+ "left join base_town t2 on psn.town_id = t2.town_id "
					+ "left join base_comm t3 on psn.comm_id = t3.comm_id "
					+ "left join base_group t4 on psn.group_id = t4.group_id ";
		}
		if (Tools.processNull(applyWay).equals(Constants.APPLY_WAY_DW)) {
			sql += "left join base_corp t5 on t5.customer_id = psn.corp_customer_id and t5.customer_id = '" + corpId + "' ";
		}
		sql += "left join base_photo pho on psn.customer_id = pho.customer_id ";
		if (Tools.processNull(isPhoto).equals(Constants.YES_NO_YES)) {
			sql += "and pho.photo_state = '0' ";
		}
		if ("0".equals(isBatchHf)) {
			sql += "where exists (select 1 from card_baseinfo where customer_id = psn.customer_id and card_state < '9' and card_type = '" + Constants.CARD_TYPE_QGN + "') "
					+ "and not exists (select 1 from card_apply where customer_id = psn.customer_id and card_type = '120' and apply_state < '90' and apply_state not in ('12', '15', '70')) ";
		} else {
			sql += "where not exists (select 1 from card_apply where customer_id = psn.customer_id and apply_state < '90' and apply_state not in ('12', '15', '70'))";
		}
		if (Tools.processNull(applyWay).equals(Constants.APPLY_WAY_SQ)) {
			if (!Tools.processNull(regionId).equals("")) {
				sql += "and psn.region_id = '" + regionId + "' ";
			}
			if (!Tools.processNull(townId).equals("")) {
				sql += "and psn.town_id = '" + townId + "' ";
			}
			if (!Tools.processNull(commId).equals("")) {
				sql += "and psn.comm_id = '" + commId + "' ";
			}
			if (!Tools.processNull(groupId).equals("")) {
				sql += "and psn.group_id = '" + groupId + "' ";
			}
		} else if (Tools.processNull(applyWay).equals(Constants.APPLY_WAY_DW)) {
			if (!Tools.processNull(certNos).equals("")) {
				sql += "and psn.cert_no in (" + certNos + ") ";
			} else {
				sql += "and t5.customer_id = '" + corpId + "' ";
			}
		}
		return sql;
	}
	
	@Override
	public void updateAppSnap(String snapDealNo, CardApplyTask task) {
		try {
			int r = publicDao.doSql("update batch_apply_snap set app_num = '" + task.getTaskSum() + "', apply_date = to_date('" + DateUtil.formatDate(task.getTaskDate()) + "', 'yyyy-mm-dd hh24:mi:ss'), "
					+ "app_brch_id = '" + task.getTaskBrchId() + "', app_user_id = '" + task.getTaskOperId() + "', task_id = '" + task.getTaskId() + "' where deal_no = '" + snapDealNo + "'");
			if(r != 1){
				throw new Exception("更新【batch_apply_snap】失败！");
			}
			publicDao.doSql("commit");
		} catch (Exception e) {
			throw new CommonException("更新申领历史状态失败, " + e.getMessage());
		}
	}
	
	@Override
	public SysActionLog savePrintReport(SysActionLog actionLog, Users user) {
		SysActionLog actionLognew = null;
		try {
			Serializable ser = publicDao.save(actionLog);
			actionLognew= (SysActionLog)this.findOnlyRowByHql("from SysActionLog where dealNo='"+ser.toString()+"'");
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
		return actionLognew;
	}
	
	@Override
	public TrServRec saveCorpNetAppData(String corpId, String regionId, List<Map<String, String>> persons, SysActionLog log) {
		try {
			log.setDealCode(DealCode.CORP_NET_APP_IMPORT);
			log.setMessage("社保申领导入单位人员");
			publicDao.save(log);
			long dealNo = log.getDealNo();
			// 保存明细
			StringBuilder sql = new StringBuilder();
			for (int c = 0; c < persons.size(); c++) {
				Map<String, String> person = persons.get(c);
				sql.append("'insert into corp_netapp_data_detail (deal_no, cert_no, name) values (" + dealNo + ", ''" + person.get("certNo") + "'', ''" + person.get("name") + "'')',");
				//
				if ((c + 1) % 500 == 0) {
					publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + sql.substring(0, sql.length() - 1) + "))");
					sql.delete(0, sql.length());
				}
			}
			if (sql.length() > 0) {
				publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + sql.substring(0, sql.length() - 1) + "))");
				sql.delete(0, sql.length());
			}
			// 处理明细
			publicDao.doSql("update corp_netapp_data_detail t set sure_flag = '6' where deal_no = " + dealNo + " and not exists (select 1 from base_personal where cert_no = t.cert_no)");
			publicDao.doSql("update corp_netapp_data_detail t set customer_id = (select customer_id from base_personal where cert_no = t.cert_no), name = (select name from base_personal where cert_no = t.cert_no), cert_type = (select cert_type from base_personal where cert_no = t.cert_no) where deal_no = " + dealNo);
			publicDao.doSql("update corp_netapp_data_detail t set sure_flag = '2' where deal_no = " + dealNo + " and exists (select 1 from base_personal where customer_id = t.customer_id and customer_state <> '0')");
			publicDao.doSql("update corp_netapp_data_detail t set sure_flag = '3' where deal_no = " + dealNo + " and not exists (select 1 from base_siinfo where customer_id = t.customer_id and cert_no = t.cert_no and name = t.name and med_state = '0' and med_whole_no = '" + regionId + "')");
			publicDao.doSql("update corp_netapp_data_detail t set sure_flag = '4' where deal_no = " + dealNo + " and not exists (select 1 from base_photo where customer_id = t.customer_id and photo_state = '0')");
			publicDao.doSql("update corp_netapp_data_detail t set sure_flag = '5' where deal_no = " + dealNo + " and not exists (select 1 from base_personal where customer_id = t.customer_id and corp_customer_id = '" + corpId + "')");
			publicDao.doSql("update corp_netapp_data_detail t set sure_flag = '7' where deal_no = " + dealNo + " and exists (select 1 from card_apply where customer_id = t.customer_id and card_type = '120' and apply_state < '90' and apply_state not in ('12', '15', '70'))");
			publicDao.doSql("update corp_netapp_data_detail t set sure_flag = '9' where deal_no = " + dealNo + " and exists (select 1 from card_baseinfo where customer_id = t.customer_id and card_type = '100' and card_state < '9')");
			// 保存汇总
			publicDao.doSql("insert into corp_netapp_data(deal_no, apply_way, corp_id, region_id, no_app_num, can_app_num, app_num, apply_date) values('" + dealNo  + "', '1', '" + corpId + "', '" + regionId + "', 0, 0, 0, to_date('" + DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss") + "', 'yyyy-mm-dd hh24:mi:ss'))");
			String noAppNum = (String) findOnlyFieldBySql("select to_char(count(1)) from batch_apply_snap_detail where deal_no = '" + dealNo + "'");
			String canAppNum = (String) findOnlyFieldBySql("select to_char(count(1)) from batch_apply_snap_detail where deal_no = '" + dealNo + "' and sure_flag = '1'");
			publicDao.doSql("update corp_netapp_data set no_app_num = '" + noAppNum + "', can_app_num = '" + canAppNum + "' where deal_no = '" + dealNo + "'");
			//
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setClrDate(getClrDate());
			rec.setDealState(Constants.STATE_ZC);
			publicDao.save(rec);
			return rec;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
}