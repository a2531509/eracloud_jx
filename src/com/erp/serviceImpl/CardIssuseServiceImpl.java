package com.erp.serviceImpl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.math.BigDecimal;

import javax.annotation.Resource;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.CardApply;
import com.erp.model.CardApplyTask;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardConfig;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.AccAcountService;
import com.erp.service.CardIssuseService;
import com.erp.service.RechargeService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.ReceiptContants;
import com.erp.util.Tools;
@Service("cardIssuseService")
public class CardIssuseServiceImpl extends BaseServiceImpl implements CardIssuseService {
    Logger logger = Logger.getLogger(CardIssuseServiceImpl.class);
	@Resource(name="accAcountService")
	private AccAcountService accService;
	@Resource(name="rechargeService")
	private RechargeService rechargeService;
	
	@SuppressWarnings({"unchecked","rawtypes"})
	public TrServRec saveOneCardIssuse(CardApply apply,CardBaseinfo card) throws CommonException {
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
			sb.append("1" + "|");
			sb.append("0" + "|");
			sb.append(Tools.processNull(apply.getRecvCertType()) + "|");
			sb.append(Tools.processNull(apply.getRecvCertNo()) + "|");
			sb.append(Tools.processNull(apply.getRecvName()) + "|");
			sb.append(Tools.processNull(apply.getAgtPhone()) + "|");
			sb.append(Tools.processNull(apply.getApplyType()).equals(Constants.APPLY_TYPE_BK) ? "补卡发放" : Tools.processNull(apply.getApplyType()).equals(Constants.APPLY_TYPE_HK) ? "换卡发放" : "初次申领发放");
			sb.append("|");
			List inParam = new ArrayList();
			inParam.add(sb.toString());
			List<Integer> outParam = new java.util.ArrayList<Integer>();
			outParam.add(java.sql.Types.VARCHAR);
			outParam.add(java.sql.Types.VARCHAR);
			outParam.add(java.sql.Types.VARCHAR);
			List ret = publicDao.callProc("pk_card_apply_issuse.p_smz_kff",inParam,outParam);
			if(!(ret == null || ret.size() == 0)){
				int res = Integer.parseInt(ret.get(0).toString());
				if(res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				}else{
					rec = (TrServRec)this.findOnlyRowByHql("from TrServRec where dealNo = " + ret.get(2).toString());
				}
			}else{
				throw new CommonException("调用存储过程出错！");
			}
			actionLog = (SysActionLog) this.findOnlyRowByHql("from SysActionLog where dealNo = " + rec.getDealNo());
			List allOldCardNos = new ArrayList();
			if((apply.getApplyType().equals(Constants.APPLY_TYPE_BK) || apply.getApplyType().equals(Constants.APPLY_TYPE_HK)) && !Tools.processNull(apply.getOldCardNo()).equals("")){
				allOldCardNos.add(apply.getOldCardNo());
			}else{
				//批量换发时转账
                if(Tools.processNull(apply.getCardType()).equals(Constants.CARD_TYPE_SMZK)){
                    allOldCardNos = this.findBySql("select card_no from (select a.card_no from card_baseinfo a,card_apply c where a.card_no = c.card_no and a.customer_id = '" + apply.getCustomerId() + "' and a.card_no <> '" + apply.getCardNo() + "' "
                    + "order by c.apply_date desc) where rownum = 1 ");
                }
			}
			if(allOldCardNos != null && allOldCardNos.size() > 0){
				for (int i = 0; i < allOldCardNos.size(); i++) {
					String tempCardNo = Tools.processNull(allOldCardNos.get(i));
					if(Tools.processNull(tempCardNo).equals("") || Tools.processNull(tempCardNo).equals(apply.getCardNo())){
						continue;
					}
					List tempAccList = this.findBySql("select card_no,acc_kind,bal from acc_account_sub where bal >= 0 and acc_kind <> '" + Constants.ACC_KIND_QBZH + "' and card_no = '" + tempCardNo + "'");
					if(tempAccList != null && tempAccList.size() > 0){
						for (int j = 0; j < tempAccList.size(); j++){
							Object[] oldAcc = (Object[]) tempAccList.get(j);
							if(oldAcc != null){
								SysActionLog tmpLog = saveZxRec(apply.getCardNo(),Tools.processNull(oldAcc[0]),actionLog,rec, true);
								if(((BigDecimal)oldAcc[2]).longValue() > 0){
									HashMap<String,String> accMap = new HashMap<String, String>();
									accMap.put("acpt_id",actionLog.getBrchId());//
									accMap.put("acpt_type",Constants.ACPT_TYPE_GM);//0商户  1网点  柜面的为网点,终端的为商户
									accMap.put("tr_batch_no","");
									accMap.put("term_tr_no","");
									accMap.put("card_no1",Tools.processNull(oldAcc[0]));
									accMap.put("acc_kind1",Tools.processNull(oldAcc[1]));//联机账户
									accMap.put("wallet_id1","00");
									accMap.put("card_no2",apply.getCardNo());
									accMap.put("acc_kind2",Tools.processNull(oldAcc[1]));//联机账户
									accMap.put("wallet_id2","00");
									accMap.put("tr_amt",Tools.processNull(oldAcc[2]));
									accMap.put("tr_state",Constants.TR_STATE_ZC);
									accMap.put("pwd","");//转出卡账户密文密码
									SysActionLog ltlog = (SysActionLog) BeanUtils.cloneBean(tmpLog);
									ltlog.setDealCode(DealCode.RECHARGE_ACC_ACC);
									ltlog.setMessage(ltlog.getMessage() + ",老卡转新卡");
									accService.transfer(ltlog,accMap);
								}
							}
						}
					}
				}
			}
			//保存业务凭证
			JSONObject json = new JSONObject();
			json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
			json.put(ReceiptContants.FIELD.DEAL_NO, actionLog.getDealNo()); // 交易流水号
			json.put(ReceiptContants.FIELD.DEAL_TYPE, findTrCodeNameByCodeType(actionLog.getDealCode())); // 交易类型
			json.put(ReceiptContants.FIELD.DEAL_FEE, "工本费：￥00 / 其他费用：￥00");
			json.put(ReceiptContants.FIELD.CARD_NO, apply.getCardNo()); // 卡号
			json.put(ReceiptContants.FIELD.SOCIAL_SECURITY_CARD_NO, apply.getSubCardNo()); // 社保卡号
			json.put(ReceiptContants.FIELD.CUSTOMER_NAME, rec.getCustomerName()); // 客户姓名
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getCertType())); // 客户证件类型
			json.put(ReceiptContants.FIELD.CUSTOMER_CERTIFICATE_NO, rec.getCertNo()); // 客户证件号码
			json.put(ReceiptContants.FIELD.AGENT_NAME, apply.getRecvName()); // 代理人姓名
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", apply.getRecvCertType())); // 代理人证件类型
			json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, apply.getRecvCertNo()); // 代理人证件号码
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
	/**
	 * 规模发放登记保存
	 * @param apply 申领实体
	 * @param card 卡片信息实体
	 * @param actionlog 日志实体
	 * @param flag 规模发放标志0，全部发放，1部分发放
	 * @param customerIdList 人员编号的数组
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public void saveBatchIssuse(String[] taskIds, SysActionLog actionLog,TrServRec serv, String org_Id,String flag,@SuppressWarnings("rawtypes") List customerIdList) throws CommonException {
		try{
			CardApplyTask task = new CardApplyTask();
			CardConfig para = null;
			actionLog.setMessage("规模发放登记，任务号为:");
			publicDao.save(actionLog);
			CardApply apply = null;
			CardBaseinfo card = null;
			SysActionLog log = null;
		    if(null!=customerIdList && customerIdList.size()>0){//一个任务且拆包发放
		    	for(int i=0;i<customerIdList.size();i++){
		    		String customerId=(String)customerIdList.get(i);
		    		log=new SysActionLog();
			    	log.setDealTime(publicDao.getDateBaseDate());
			    	log.setMessage("");
			    	card = (CardBaseinfo)this.findOnlyRowByHql("from CardBaseinfo c where c.cardState='"+Constants.CARD_STATE_WQY + "' and c.card_No='"+apply.getCardNo()+"'");
			    	card.setCardState("1");
					card.setIssueOrgId(Tools.processNull(this.getSessionSysBranch().getOrgId()));//发卡机构代码，默认为操作员所属机构
			    	apply=(CardApply)this.findOnlyRowByHql("from CardApply c where customerId='"+customerId+"' and c.taskId='"+taskIds[0].toString()+"'");
			    	apply.setRelsBrchId(this.getSessionUser().getBrchId());//发放网点
					apply.setRelsUserId(this.getSessionUser().getUserId());//发放操作员
					if(apply.getAgtCertType().equals(Constants.CERT_TYPE_SFZ)&&apply.getAgtCertNo().length()==15){
						apply.setAgtCertNo(serv.getAgtCertNo());
					}
					apply.setAgtCertType(serv.getAgtCertType());
					apply.setAgtCertNo(serv.getAgtCertNo());
					apply.setAgtName(serv.getAgtName());//如果是代理人来领取卡片，需要记录下代理人的信息，可选条件
					apply.setAgtPhone(serv.getAgtTelNo());
					apply.setApplyState(Constants.APPLY_STATE_YFF);//修改CM_CARD_APPLY中的申领状态为已发放
			    	saveOneCardIssuse(apply,card);
			    	publicDao.doSql(" update card_apply_task t set t.task_num= task_num-1,issuse_num=issuse_num+1  where t.task_id='"+taskIds[0]+"'");
			    	//更新任务中数量
			    	
		    	}
		    }else{
		    	for (int i = 0;i < taskIds.length;i++){
					String task_Id = taskIds[i].toString();
					task = (CardApplyTask)this.findOnlyRowByHql("from CardApplyTask t where t.taskId = '" + task_Id + "'");
					if(task == null){
						throw new CommonException("根据任务编号" + task_Id + "找不到任务信息");
					}
					if(!Tools.processNull(task.getTaskState()).equals(Constants.TASK_STATE_YJS)){
						throw new CommonException("当前制卡任务状态不允许规模发放");
					}
					task.setTaskState(Constants.TASK_STATE_FFWC);
					publicDao.update(task);
					//kfgl.releaseCard(null,task,actionLog);
					para = this.getCardConfigByCardType(task.getCardType());
					serv.setDealNo(actionLog.getDealNo());
					serv.setDealCode(actionLog.getDealCode());
					serv.setBizTime(actionLog.getDealTime());
					serv.setDealState("0");
					serv.setClrDate(this.getClrDate());
					serv.setNote("规模发放，任务号为：" + taskIds);
					serv.setRtnFgft(0L);
					serv.setCardType(para.getCardType());
					//List list=publicDao.findBySQL("from Card_Apply a, Card_baseinfo c  where a.card_Type = c.card_Type and a.card_No = c.card_No and a.task_Id = '"+task_Id+"'"); 
					List<Object> in = new java.util.ArrayList<Object>();
					in.add(DealCode.ISSUSE_TYPE_BATCH);
					in.add(task_Id);
					in.add(task.getCardType());
					in.add(actionLog.getDealNo());
					List<Integer> out = new java.util.ArrayList<Integer>();
					out.add(java.sql.Types.VARCHAR);
					out.add(java.sql.Types.VARCHAR);
					//out.add(java.sql.Types.VARCHAR);
					List<?> ret = publicDao.callProc("PK_CARD_APPLY_ISSUSE.P_BATCH_ISSUSE",in,out);
					if (!(ret == null || ret.size() == 0)) {
						int res = Integer.parseInt(ret.get(1).toString());
						if (res != 0) {
							String outMsg = ret.get(0).toString();
							throw new CommonException(outMsg);
						} else {
							//return;
						}
					} else {
						throw new CommonException("建卡账户出错！");
					}
					
					/** 更新申领信息的发放网点，发放操作员，代理人证件类型，代理人证件号码，代理人姓名，申领状态，业务日志序列号，发放时间  卡片基本信息的卡状态，最后更新时间*/
					int upa=publicDao.doSql("update Card_Apply a set a.rels_Brch_Id='"+serv.getBrchId()+"',a.rels_user_id='"+actionLog.getUserId()+
							"',a.agt_Cert_Type='"+serv.getAgtCertType()+"',a.agt_Cert_No='"+serv.getAgtCertNo()+"',a.agt_Name='"+
							serv.getAgtName()+"',a.apply_State='"+Constants.APPLY_STATE_YFF+"',a.deal_No="+actionLog.getDealNo()+
							",rels_Date=to_date('"+DateUtil.formatDate(actionLog.getDealTime(),"yyyy-MM-dd hh:mm:ss")+
							"','yyyy-MM-dd HH24:mi:ss'),issuse_deal_no="+actionLog.getDealNo()+" where a.task_id='"+task.getTaskId()+"' ");

					//更新批量申领统计表
					publicDao.doSql("update card_apply_task s set s.issuse_num = (select count(1) from card_apply a where a.task_id = s.task_id and a.apply_state = '60')  where exists(select 1 from card_apply a where a.task_id = s.task_id and a.apply_state = '60' and a.task_id='"+task.getTaskId()+"')");
					if(upa!=task.getTaskSum()){
						throw new CommonException("该任务 "+task.getTaskId()+" 对应的卡发放数量不一致");
					}
					serv.setCardAmt(new Long(upa));//卡数量码
					//autoSynAppOpenStateByTask(serv,task);
					publicDao.save(serv);
			  }
				
		    }
		}catch(CommonException e){
			throw new CommonException("规模发放登记保存发生错误:",e);
		}
	}
	/**
	 * 批量发放 新版
	 * @param taskIdsOrCardNos
	 * @param flag
	 * @param oper
	 * @param rec
	 * @param actionLog
	 * @return
	 * @author yangn
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public TrServRec saveBatchCardIssuse(String taskIdOrCardNo,String flag,Users oper,TrServRec rec,SysActionLog actionLog, boolean syncOldCard2Sb) throws CommonException{
		try{
			if(Tools.processNull(flag).equals("0")){
				if(Tools.processNull(taskIdOrCardNo).equals("")){
					throw new CommonException("发放任务编号或是卡号不能为空！");
				}
				CardApplyTask cardApplyTask = (CardApplyTask) findOnlyRowByHql("from CardApplyTask c where c.taskId = '" + taskIdOrCardNo + "'");
				actionLog.setDealCode(DealCode.ISSUSE_TYPE_BATCH);
				actionLog.setMessage("规模发放,任务编号" + taskIdOrCardNo);
				publicDao.save(actionLog);
				StringBuffer sb = new StringBuffer();
				sb.append(actionLog.getBrchId() + "|");//受理点编号
				sb.append(Constants.ACPT_TYPE_GM + "|");//受理点类型
				sb.append(actionLog.getUserId() + "|");//终端编号
				sb.append("" + "|");//终端流水
				sb.append(actionLog.getDealNo() + "|");//业务流水
				sb.append(taskIdOrCardNo + "|");//任务编号
				sb.append("0" + "|");//是否更新库存
				sb.append("0" + "|");//是否同步前置
				sb.append(rec.getAgtCertType() + "|");//代理人证件类型
				sb.append(rec.getAgtCertNo() + "|");//代理人证件号码
				sb.append(rec.getAgtName() + "|");//代理人姓名
				sb.append(rec.getAgtTelNo() + "|");//代理人联系方式
				sb.append(actionLog.getMessage() + "|");//备注
				List inParam = new ArrayList();
				inParam.add(sb.toString());
				List<Integer> outParam = new java.util.ArrayList<Integer>();
				outParam.add(java.sql.Types.VARCHAR);
				outParam.add(java.sql.Types.VARCHAR);
				List ret = publicDao.callProc("pk_card_apply_issuse.p_batch_kff",inParam,outParam);
				if(!(ret == null || ret.size() == 0)){
					int res = Integer.parseInt(ret.get(0).toString());
					if(res != 0) {
						String outMsg = ret.get(1).toString();
						throw new CommonException(outMsg);
					}
				}else{
					throw new CommonException("调用存储过程出错！");
				}
				rec.setDealNo(actionLog.getDealNo());
                //转账户
                try{
                    rec.setClrDate(this.getClrDate());
                    StringBuffer zzAccSb = new StringBuffer();
                    zzAccSb.append("select t.card_no card_no1,");
                    zzAccSb.append("( ");
                    zzAccSb.append("   select a.card_no from card_baseinfo a where a.customer_id = t.customer_id and a.card_type in ('" + Constants.CARD_TYPE_QGN + "','" + Constants.CARD_TYPE_SMZK + "') and a.card_no <> t.card_no");
                    zzAccSb.append("   and a.last_modify_date = (");
                    zzAccSb.append("       select max(b.last_modify_date) from card_baseinfo b where b.customer_id = t.customer_id and b.card_type in ('" + Constants.CARD_TYPE_QGN + "','" + Constants.CARD_TYPE_SMZK + "')");
                    zzAccSb.append("       and b.card_no <> t.card_no");
                    zzAccSb.append("   )");
                    zzAccSb.append(") card_no2 ");
                    zzAccSb.append("from card_apply t ");
                    zzAccSb.append("where t.task_id = '" + taskIdOrCardNo + "' and (t.apply_state >= '" + Constants.APPLY_STATE_YJS + "' and t.apply_state < '91')  ");
                    if(Tools.processNull(cardApplyTask.getCardType()).equals(Constants.CARD_TYPE_QGN)){
                    	zzAccSb.append("and not exists (select 1 from card_baseinfo d where d.customer_id = t.customer_id and d.card_type = '" + Constants.CARD_TYPE_SMZK + "' )");
                    }
                    List allOldCardNos = this.findBySql(zzAccSb.toString());
                    if(allOldCardNos != null && allOldCardNos.size() > 0){
                        for(int i = 0; i < allOldCardNos.size(); i++){
                            Object[] tempCardNos = (Object[]) allOldCardNos.get(i);
                            if(Tools.processNull(tempCardNos[1]).equals("") || Tools.processNull(tempCardNos[0]).equals(Tools.processNull(tempCardNos[1]))){
                                continue;
                            }
                            SysActionLog tempLog = saveZxRec(Tools.processNull(tempCardNos[0]), Tools.processNull(tempCardNos[1]), actionLog, rec, syncOldCard2Sb);
                            List tempAccList = this.findBySql("select card_no,acc_kind,bal from acc_account_sub where bal >= 0 and acc_kind <> '" + Constants.ACC_KIND_QBZH + "' and card_no = '" + Tools.processNull(tempCardNos[1]) + "'");
                            if(tempAccList != null && tempAccList.size() > 0){
                                for(int j = 0; j < tempAccList.size(); j++){
                                    Object[] oldAcc = (Object[]) tempAccList.get(j);
                                    if(oldAcc != null && ((BigDecimal) oldAcc[2]).longValue() > 0){
                                        HashMap<String,String> accMap = new HashMap<String,String>();
                                        accMap.put("acpt_id", actionLog.getBrchId());//
                                        accMap.put("acpt_type", Constants.ACPT_TYPE_GM);//0商户  1网点  柜面的为网点,终端的为商户
                                        accMap.put("tr_batch_no", "");
                                        accMap.put("term_tr_no", "");
                                        accMap.put("card_no1", Tools.processNull(oldAcc[0]));
                                        accMap.put("acc_kind1", Tools.processNull(oldAcc[1]));//联机账户
                                        accMap.put("wallet_id1", "00");
                                        accMap.put("card_no2", Tools.processNull(tempCardNos[0]));
                                        accMap.put("acc_kind2", Tools.processNull(oldAcc[1]));//联机账户
                                        accMap.put("wallet_id2", "00");
                                        accMap.put("tr_amt", Tools.processNull(oldAcc[2]));
                                        accMap.put("tr_state", Constants.TR_STATE_ZC);
                                        accMap.put("pwd", "");//转出卡账户密文密码
                                        SysActionLog ww = (SysActionLog) BeanUtils.cloneBean(tempLog);
                                        ww.setDealCode(DealCode.RECHARGE_ACC_ACC);
                                        accService.transfer(ww, accMap);
                                    }
                                }
                            }
                        }
                    }
                }catch(Exception e2){
                    logger.error(e2);
                    logger.error("规模发放转账发生错误:" + e2.getMessage());
                }
				/*rec.setDealCode(actionLog.getDealCode());
				rec.setNote(actionLog.getMessage());
				rec.setBrchId(actionLog.getBrchId());
				rec.setUserId(actionLog.getUserId());
				rec.setBizTime(actionLog.getDealTime());
				rec.setDealState(Constants.TR_STATE_ZC);
				rec.setClrDate(this.getClrDate());
				publicDao.save(rec);*/
				// 保存业务凭证
				JSONObject json = new JSONObject();
				json.put(ReceiptContants.FIELD.TITLE, ReceiptContants.TITLE); // 标题
				json.put(ReceiptContants.FIELD.DEAL_NO, actionLog.getDealNo()); // 交易流水号
				json.put(ReceiptContants.FIELD.MAKE_BATCH_ID, cardApplyTask.getMakeBatchId()); // 批次号
				json.put(ReceiptContants.FIELD.TASK_ID, cardApplyTask.getTaskId()); // 任务号
				json.put(ReceiptContants.FIELD.TASK_COUNT, cardApplyTask.getTaskSum()); // 任务数量
				json.put("p_End_Num", cardApplyTask.getEndNum());
				json.put("p_Yh_Num", cardApplyTask.getYhNum());
				if (!Tools.processNull(cardApplyTask.getCorpId()).equals("")) {
					json.put(ReceiptContants.FIELD.CUSTOMER_ID, cardApplyTask.getCorpId()); // 客户编号
				} else {
					json.put(ReceiptContants.FIELD.CUSTOMER_ID, cardApplyTask.getCommId()); // 客户编号
				}
				json.put(ReceiptContants.FIELD.CUSTOMER_NAME, cardApplyTask.getTaskName()); // 客户名称
				json.put(ReceiptContants.FIELD.AGENT_NAME, rec.getAgtName()); // 代理人姓名
				json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_TYPE, getCodeNameBySYS_CODE("CERT_TYPE", rec.getAgtCertType())); // 代理人证件类型
				json.put(ReceiptContants.FIELD.AGENT_CERTIFICATE_NO, rec.getAgtCertNo()); // 代理人证件号码
				json.put(ReceiptContants.FIELD.ACCEPT_BRANCH_NAME, getSessionSysBranch().getFullName()); // 受理网点名称
				json.put(ReceiptContants.FIELD.ACCEPT_USER_ID, this.getUser().getUserId()); // 受理点员工号
				json.put(ReceiptContants.FIELD.ACCEPT_USER_NAME, this.getUser().getName()); // 受理点员工姓名
				json.put(ReceiptContants.FIELD.ACCEPT_TIME, DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")); // 受理时间
				this.saveSysReport(actionLog, json, ReceiptContants.TYPE.BATCH_ISSUSE, Constants.APP_REPORT_TYPE_PDF, 1L, "", null);
				return rec;
			}else if(Tools.processNull(flag).equals("1")){
				if(Tools.processNull(taskIdOrCardNo).equals("")){
					throw new CommonException("申请编号不能为空！");
				}
				CardApply apply = (CardApply) this.findOnlyRowByHql("from CardApply where applyId = " + taskIdOrCardNo);
				if(apply == null){
					throw new CommonException("根据申请编号" + taskIdOrCardNo + "找不到申领记录信息！");
				}
				if(!Tools.processNull(apply.getApplyState()).equals(Constants.APPLY_STATE_YJS)){
					throw new CommonException("申请编号" + taskIdOrCardNo + "对应的申请记录信息不是【已接收】状态，无法进行发放！");
				}
				apply.setRelsBrchId(actionLog.getBrchId());
				apply.setRelsUserId(actionLog.getUserId());
				apply.setRelsDate(actionLog.getDealTime());
				apply.setRecvCertType(rec.getAgtCertType());
				apply.setRecvCertNo(rec.getAgtCertNo());
				apply.setRecvName(rec.getAgtName());
				apply.setRecvPhone(rec.getAgtTelNo());
				apply.setApplyState(Constants.APPLY_STATE_YFF);
				CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo where cardNo = '" + apply.getCardNo() + "'");
				if(card == null){
					throw new CommonException("根据申请编号" + apply.getApplyId() + "找不到对应的卡信息！");
				}
				if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_WQY)){
					throw new CommonException("申请编号" + apply.getApplyId() + "对应的卡信息不是【未启用】状态！");
				}
				rec = this.saveOneCardIssuse(apply,card);
				apply.setIssuseDealNo(rec.getDealNo());
			}else{
				throw new CommonException("按照任务编号或是卡号发放标志不正确！");
			}
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 判断实名制卡是否符合发放条件，如果申领表中的卡片状态为已接收、已退卡，那么才允许其发放
	 */
	public boolean judgekff(String[] applyidstr) throws CommonException{
		if(applyidstr==null||applyidstr.length<1){
			throw new CommonException("当前没有选中要发放的卡片");
		}
		for(int i=0;i<applyidstr.length;i++){
			if(Tools.processNull(applyidstr[i]).equals("")){
				throw new CommonException("当前选中的卡片申领单号为空");
			}
			if(publicDao.findOnlyFieldBySql("select 1 from cm_card_apply a where (a.apply_state='"+Constants.APPLY_STATE_YJS+"' or a.apply_state='"+Constants.APPLY_STATE_YTK+"') and a.apply_id='"+applyidstr[i]+"'") == null){
				throw new CommonException("当前发放的申领状态不符合发放条件");
			}
		}
		return true;
	}
	/**
	 * 在卡片发放时判断老卡是否开通应用信息（例如公园年卡）,
	 * 如果老卡已经应用信息,则新卡自动关联应用开通信息。
	 * @param serv  TrServRec 发放的综合业务日志
	 * @param card  CardBaseinfo 新卡信息
	 */
	public void autoSynAppOpenState(TrServRec serv,CardBaseinfo card,CardApply apply) throws CommonException{
		try{
			if(serv == null){
				throw new CommonException("发放的综合业务日志不能为空！");
			}
			//如果申领记录是补换卡,则判断老卡查询老卡,并判断老卡是否开通应用信息
			if(Tools.processNull(apply.getApplyType()).equals(DealCode.NAMEDCARD_CHG) || Tools.processNull(apply.getApplyType()).equals(DealCode.NAMEDCARD_REISSUE)){
				CardBaseinfo cm = (CardBaseinfo) this.findOnlyRowByHql("select t from CardBaseinfo t where t.customer_Id = '" +
			                           card.getCustomerId() + "' and t.card_No <> '" + card.getCardNo() + "' and t.card_State > '1' and t.card_Type = '200' ");
				//查找公园年卡开通表
				if(cm != null){
					//Tr_Yearcard_Book book = (Tr_Yearcard_Book) dao.findOnlyRowByHql("from Tr_Yearcard_Book t where t.card_No = '" +  cm.getCard_No() + "' and t.client_Id = '" + apply.getClient_Id() + "'" );
					//构建综合业务日志
					TrServRec rec = new TrServRec();
					rec.setDealNo(Long.valueOf(this.getSequenceByName("ONECARD_YX.SEQ_ACTION_NO")));
					rec.setDealCode(DealCode.KFW_OPEN_YEARCARD);
					rec.setCardType(card.getCardType());
					rec.setCustomerId(card.getCustomerId());
					rec.setOldCardNo(cm.getCardNo());
					rec.setOldCardId(cm.getCardId());
					rec.setCardNo(card.getCardNo());
					rec.setCardId(card.getCardId());
					rec.setBizTime(publicDao.getDateBaseDate());
					rec.setUserId(serv.getUserId());
					rec.setBrchId(serv.getBrchId());
					publicDao.save(rec);
				}
			}
		}catch(Exception e){
			throw new CommonException("发放过程出现错误:",e);
		}
	}
	/**
	 * 规模发放时，根据任务号查询是否需要同步应用开通信息
	 * @param serv TrServRec  规模发放的操作日志
	 * @param task CardApplyTask 制卡任务
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public void autoSynAppOpenStateByTask(TrServRec serv,CardApplyTask task) throws CommonException{
		try{
			if(task == null){
				return;
			}
			List<CardApply> list = this.findByHql("from CardApply t where t.task_Id = '" + task.getTaskId() + "' and (t.applyType = '1' or t.applyType = '2') ");
			if(list != null && list.size() > 0){
				for (CardApply cardApply : list) {
					CardBaseinfo newcard = (CardBaseinfo) this.findOnlyRowByHql("select t from CardBaseinfo t where t.card_No = '" + cardApply.getCardNo() + "' and t.customerId = " + cardApply.getCustomerId() + " and t.cardState <= '1'");
					autoSynAppOpenState(serv,newcard,cardApply);
				}
			}
		}catch(Exception e){
			throw new CommonException("发放过程同步应用开通信息出现错误,:",e);
		}
	}
	
    /**
     * 人个发放撤销
     * @param apply_Id
     * @param actionLog
     * @param serv
     * @return
     * @throws CommonException
     */
	@SuppressWarnings({ "rawtypes","unchecked" })
	@Override
	public TrServRec saveUndoCardIssuse(String applyId,SysActionLog actionLog,TrServRec serv) throws CommonException {
		try{
			StringBuffer sb = new StringBuffer();
			sb.append(Tools.processNull(actionLog.getBrchId()) + "|");
			sb.append(Constants.ACPT_TYPE_GM + "|");
			sb.append(Tools.processNull(actionLog.getUserId()) + "|");
			sb.append("" + "|");
			sb.append(Tools.processNull(serv.getDealNo()) + "|");
			sb.append("1" + "|");
			sb.append("1" + "|");
			sb.append(Tools.processNull(serv.getAgtCertType()) + "|");
			sb.append(Tools.processNull(serv.getAgtCertNo()) + "|");
			sb.append(Tools.processNull(serv.getAgtName()) + "|");
			sb.append(Tools.processNull(serv.getAgtTelNo()) + "|");
			sb.append("" + "|");			
			List<Object> in = new java.util.ArrayList<Object>(); //1action_no|2tr_code|3oper_id|4oper_time|5main_type|6sub_type|7obj_id  
			in.add(sb.toString());
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			List ret = publicDao.callProc("pk_card_apply_issuse.p_undo_smz_kff",in,out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					serv = (TrServRec) this.findOnlyRowByHql("from TrServRec where dealNo = " + ret.get(2).toString());
				}
			} else{
				throw new CommonException("调取过程失败！");
			}
			CardApply apply = (CardApply) this.findOnlyRowByHql("from CardApply where cardNo = '" + serv.getCardNo() + "'");
			actionLog = (SysActionLog) this.findOnlyRowByHql("from SysActionLog where dealNo = '" + serv.getDealNo() + "'");
			JSONObject report = new JSONObject();
			report.put("p_Agtcerttype", "");
			report.put("p_Title",Constants.APP_REPORT_TITLE + this.findTrCodeNameByCodeType(serv.getDealCode()));
			report.put("p_Actionno", Tools.processNull(serv.getDealNo()));
			report.put("p_Card_No", Tools.processNull(serv.getCardNo()));
			report.put("p_Costfee", Arith.cardreportsmoneydiv(Tools.processNull(apply.getCostFee())));
			report.put("p_Client_Name", Tools.processNull(serv.getCustomerName()));
			report.put("p_Urgent_Fee", Arith.cardreportsmoneydiv("0"));
			report.put("p_Other_Fee", Arith.cardreportsmoneydiv(Tools.processNull(apply.getOtherFee())));
			report.put("p_Foregift",Arith.cardreportsmoneydiv(0+""));
			report.put("p_Cert_Type", Tools.processNull(this.getCodeNameBySYS_CODE("CERT_TYPE",serv.getCertType())));
			report.put("p_Cert_No", Tools.processNull(serv.getCertNo()));
			report.put("p_Card_Type", this.getCodeNameBySYS_CODE("CARD_TYPE",serv.getCardType()));
			report.put("p_Bus_Type", this.getCodeNameBySYS_CODE("BUS_TYPE", apply.getBusType()));
			report.put("p_Oper_Time", DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss"));
			report.put("p_Oper_Id", this.getUser().getUserId());
			report.put("p_Print_Name", Tools.processNull(this.getUser().getFullName()));
			report.put("p_Print_Time", DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss"));
			report.put("p_Brch", Tools.processNull(this.getSessionSysBranch().getEname()));
            this.saveSysReport(actionLog,report,"/reportfiles/grffqx.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
			return serv;
		}catch(CommonException e){
			throw new CommonException(e.getMessage());
		}
	}
	@SuppressWarnings("unchecked")
	public SysActionLog saveZxRec(String newCardNo,String oldCardNo,SysActionLog oldLog,TrServRec oldRec, boolean sync2Sb) throws Exception{
		SysActionLog newLog = (SysActionLog) BeanUtils.cloneBean(oldLog);
		newLog.setDealNo(null);
		newLog.setDealCode(DealCode.ISSUSE_OLD_ZZ_NEW);
		newLog.setNote("老卡换发新卡:新卡号:" + newCardNo + ",老卡号:" + oldCardNo);
		newLog.setMessage(newLog.getNote());
		this.publicDao.save(newLog);
		CardBaseinfo tempCard = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + oldCardNo + "'");
		if(Tools.processNull(tempCard.getCardState()).equals(Constants.CARD_STATE_ZX)){
			return newLog;//如果老卡已注销,则不在重复注销
		}
		BasePersonal tempBp = new BasePersonal();
		if(!Tools.processNull(tempCard.getCustomerId()).equals("")){
			tempBp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + tempCard.getCustomerId() + "'");
			if(tempBp == null){
				tempBp = new BasePersonal();
			}
		}
		publicDao.doSql("update card_apply set apply_state = '" + Constants.APPLY_STATE_YZX + "' where card_no = '" + oldCardNo + "'");
		this.publicDao.doSql("update card_baseinfo t set t.card_state = '" + Constants.CARD_STATE_ZX + "',t.last_modify_date = to_date('"
		    + DateUtil.formatDate(newLog.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','yyyy-mm-dd hh24:mi:ss'),t.cancel_reason = '" + Constants.CANCEL_REASON_HK + "' "
			+ "where t.card_no = '" + oldCardNo + "'");
		this.publicDao.doSql("update acc_account_sub t set t.acc_state = '" + Constants.ACC_STATE_ZX + "',t.lss_date = to_date('"
		    + DateUtil.formatDate(newLog.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','yyyy-mm-dd hh24:mi:ss'),t.cls_date = to_date('"
		    + DateUtil.formatDate(newLog.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','yyyy-mm-dd hh24:mi:ss'),t.cls_user_id = '" + newLog.getUserId() + "' "
			+ "where t.card_no = '" + oldCardNo + "'");
		TrServRec rec = new TrServRec();
		rec.setDealNo(newLog.getDealNo());
		rec.setDealCode(newLog.getDealCode());
        rec.setOrgId(oldLog.getOrgId());
		rec.setBrchId(newLog.getBrchId());
		rec.setUserId(newLog.getUserId());
		rec.setBizTime(newLog.getDealTime());
		rec.setDealState(Constants.TR_STATE_ZC);
		rec.setClrDate(oldRec.getClrDate());
		rec.setAgtCertType(oldRec.getAgtCertType());
		rec.setAgtCertNo(oldRec.getAgtCertNo());
		rec.setAgtName(oldRec.getAgtName());
		rec.setAgtTelNo(oldRec.getAgtTelNo());
		rec.setCertNo(tempBp.getCertNo());
		rec.setCustomerId(tempBp.getCustomerId() + "");
		rec.setCustomerName(tempBp.getName());
		rec.setCertType(tempBp.getCertType());
		rec.setCardNo(tempCard.getCardNo());
		rec.setCardId(tempCard.getCardId());
		rec.setCardType(tempCard.getCardType());
		rec.setInCardNo(newCardNo);
		rec.setNote(newLog.getMessage());
		publicDao.save(rec);
		
		// 发送社保老卡注销
		if(sync2Sb){
			saveSynch2CardUpate(null, tempBp.getCertNo(), oldCardNo, null, newLog.getDealNo(), null);
		}
		return newLog;
	}
	public void setAccService(AccAcountService accService) {
		this.accService = accService;
	}
	public void setRechargeService(RechargeService rechargeService) {
		this.rechargeService = rechargeService;
	}
}
