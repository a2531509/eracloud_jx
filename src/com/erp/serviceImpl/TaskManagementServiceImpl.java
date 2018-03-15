package com.erp.serviceImpl;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.sql.Blob;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.commons.compress.archivers.zip.ZipArchiveEntry;
import org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream;
import org.apache.commons.net.ftp.FTP;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPReply;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseBank;
import com.erp.model.BaseBankFile;
import com.erp.model.BaseCity;
import com.erp.model.BaseRegion;
import com.erp.model.BaseVendor;
import com.erp.model.CardApplyTask;
import com.erp.model.CardConfig;
import com.erp.model.CardRecharge;
import com.erp.model.CardTaskBatch;
import com.erp.model.CardTaskList;
import com.erp.model.StockAcc;
import com.erp.model.StockList;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.CardApplyService;
import com.erp.service.DoWorkClientService;
import com.erp.service.TaskManagementService;
import com.erp.task.DefaultFTPClient;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.FileIO;
import com.erp.util.Tools;

@Service("taskManagementService")
public class TaskManagementServiceImpl extends BaseServiceImpl implements TaskManagementService {
	private static final Logger logger = Logger.getLogger(TaskManagementServiceImpl.class);
	private CardApplyService cardApplyService;
	private DoWorkClientService doWorkClientService;
	
	/**
	 * 》》制卡任务生成
	 * @param selectIds
	 * @param actionLog
	 * @param userId
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	@Override
	public void saveTaskCreate(String[] selectIds, SysActionLog actionLog, String userId) throws CommonException {
		try {
			actionLog.setDealCode(DealCode.TASK_MANAGE_ADD);
			actionLog.setMessage("制卡任务生成:本次生成" + selectIds.length + "个任务");
			publicDao.save(actionLog);
			Users oper = this.getUser();
			for(int i = 0;i < selectIds.length;i++){
				String[] rows =  selectIds[i].split("%");//10011002%中心营业大厅%100%1%3%%%0% 
				Long tmpNum = Long.valueOf(Tools.processNull(rows[4]));//总个数
				while(tmpNum > 0){
					Long taskNum = Tools.processLong(this.getSysConfigurationParameters("TASK_NUM"));
					if(taskNum == null || taskNum == -1 || taskNum == 0){
						throw new CommonException("任务大小参数信息未设置！");
					}
					tmpNum = tmpNum - taskNum;//每次更新掉50个
					String makeCardBatch = getSequenceByName("seq_cm_card_task_batch");
					CardApplyTask cardApplyTask = new CardApplyTask();
					String taskId = DateUtil.formatDate(actionLog.getDealTime(),"yyyyMMdd") + Tools.tensileString(this.getSequenceByName("SEQ_TASK_ID"),8,true,"0");
					cardApplyTask.setTaskId(taskId);
					cardApplyTask.setMakeBatchId(makeCardBatch);
					cardApplyTask.setTaskName(rows[1] + "-" + this.getCodeNameBySYS_CODE("CARD_TYPE",rows[2]));//任务名称
					cardApplyTask.setIsList(Constants.YES_NO_YES);//是否有明细(0是1否)
					cardApplyTask.setTaskDate(actionLog.getDealTime());//任务产生时间
					cardApplyTask.setTaskOperId(userId);//任务产生操作员
					cardApplyTask.setCardType(rows[2]);//卡类型
					cardApplyTask.setDealNo(actionLog.getDealNo());//取业务日志序列号
					cardApplyTask.setIsUrgent(rows[3]);//是否加急(0是1否)
					cardApplyTask.setTaskState(Constants.TASK_STATE_YSC);//任务状态
					cardApplyTask.setDealCode(DealCode.TASK_MANAGE_ADD);//交易代码
					cardApplyTask.setTaskSrc(Constants.TASK_SRC_LXSLHZ);//任务来源（0零星申领汇总1规模申领直接产生2非个性化采购任务）
					Object brStringObj = this.findOnlyFieldBySql("select b.city_id from sys_branch t,base_region b where t.region_id = b.region_id and t.brch_id = '" + rows[0] + "'");
					if(Tools.processNull(brStringObj).equals("")){
						throw new CommonException(rows[1] + "所属区域不正确！");
					}
					cardApplyTask.setBrchId(rows[0]);
					cardApplyTask.setTaskOrgId(oper.getOrgId());
					cardApplyTask.setTaskBrchId(oper.getBrchId());
					cardApplyTask.setMedWholeNo(Tools.processNull(brStringObj));
					if(Tools.processNull(rows[2]).equals(Constants.CARD_TYPE_SMZK)){
						String bankId = (String) this.findOnlyFieldBySql("select bank_id from branch_bank where brch_id = '" + rows[0] + "'");
						cardApplyTask.setBankId(Tools.processNull(bankId));
					}
					cardApplyTask.setTaskOperId(oper.getUserId());
					cardApplyTask.setIsPhoto(this.getSysConfigurationParameters("IS_PHOTO"));
					CardConfig para = this.getCardConfigByCardType(cardApplyTask.getCardType());
					StringBuffer header = new StringBuffer();
					StringBuffer where = new StringBuffer();
					header.append("update card_apply b set b.task_id = '" + taskId + "',b.apply_state = '" + Constants.APPLY_STATE_RWYSC + "', b.BUY_PLAN_ID='" + makeCardBatch + "' ");
					where.append("where a.customer_id = c.customer_id and a.task_id is null and a.apply_state = '" + Constants.APPLY_STATE_YSQ + "' ");
					where.append("and a.recv_brch_id = '" + rows[0] + "' and a.card_type = '" + rows[2] + "' and a.is_urgent = '" + rows[3] + "' ");
					if(!Tools.processNull(rows[8]).equals("")){
						where.append("and a.apply_user_id = '" + rows[8] + "' ");
					}
					if(rows.length > 4 && !Tools.processNull(rows[5]).trim().equals("")){
						where.append("and a.apply_date >= to_date('" + rows[5] + "','yyyymmddhh24miss') ");
					}
					if(rows.length > 5 && !Tools.processNull(rows[6]).trim().equals("")){
						where.append("and a.apply_date <= to_date('" + rows[6] + "','yyyymmddhh24miss') ");
					}
					if(rows.length > 8 && !Tools.processNull(rows[9]).trim().equals("")){
						where.append("and a.apply_brch_id = '" + rows[9] + "' ");
					}
					/*if(!Tools.processNull(rows[10]).trim().equals("")){
						where.append("and a.apply_brch_id = '" + rows[10] + "' ");
					}*/
					where.append("and a.apply_way = '" + rows[7] + "' ");
					header.append("where b.apply_id in (select t.apply_id from (select rank() over(order by a.apply_id asc) as nums,");
					header.append("a.* from card_apply a ,base_personal c "); 
					header.append(where);
					header.append(") t where t.nums <= " + taskNum + ")");
					if(!Constants.TASK_SRC_LXSLHZ.equals(rows[7])){
						cardApplyTask.setTaskWay(Constants.TASK_WAY_DW);
					}else{
						cardApplyTask.setTaskWay(Constants.TASK_WAY_WD);//零星申领生成任务组织方式暂定为“网点”
					}
					int count = publicDao.doSql(header.toString());
					if(count == 0){
						throw new CommonException("满足条件的卡数量为零，请检查任务是否已经执行！");
					}
					cardApplyTask.setTaskSum(count);//任务数量
					cardApplyTask.setYhNum(Long.valueOf(count + ""));
					cardApplyTask.setEndNum(Long.valueOf(count + ""));
					publicDao.save(cardApplyTask);//保存任务实体类1
					/** 插入制卡数据明细表 */
					cardApplyService.insertCardtasklist(cardApplyTask, para);
				}
			}
		} catch(Exception e){
			throw new CommonException("制卡任务生成出错：" + e.getMessage());
		}
	}
	/**
	 * 任务明细添加
	 * @param actionLog
	 * @param personIds customer_id|customer_id|customer_id
	 * @param taskId
	 * @throws CommonException
	 */
	@Override
	public void saveAddTaskMx(SysActionLog actionLog, String personIds,String taskId) throws CommonException {
		try {
			if(Tools.processNull(taskId).equals("")){
				throw new CommonException("任务编号不能为空！");
			}
			CardApplyTask tempTask = (CardApplyTask)this.findOnlyRowByHql("from CardApplyTask where taskId = '" + taskId + "'");
			if(tempTask == null){
				throw new CommonException("未找到任务信息，请确认任务信息是否存在！");
			}
			if(!Tools.processNull(tempTask.getTaskState()).equals(Constants.TASK_STATE_YSC)){
				throw new CommonException("任务已经确认，不能进行人员明细的添加！");
			}
			if(Tools.processNull(personIds).equals("")){
				throw new CommonException("请选择需要进行添加的人员信息！");
			}
			actionLog.setDealCode(DealCode.APPLY_PROCESS_ADDMXTOTASK);
			actionLog.setMessage("向任务明细表插入数据,人员编号" + personIds);
			String[] customer_ids = personIds.split("\\|");
			String personals = Tools.getConcatStrFromArray(customer_ids, "'", ",");
			if(personals.length() <= 0){
				throw new CommonException("请选择需要进行添加的人员信息！");
			}
			BigDecimal count_person = (BigDecimal) publicDao.findOnlyFieldBySql("select count(1) from card_apply t where "
			+ " t.customer_id in (" + personals + ") and t.apply_state <> '" + Constants.APPLY_STATE_WJWSHBTG + "' and "
			+ " t.apply_state <> '" + Constants.APPLY_STATE_YHSHBTG + "' and t.apply_state <> '" + Constants.APPLY_STATE_YTK + "' "
			+ " and t.apply_state <> '" + Constants.APPLY_STATE_YZX + "'");
			if(count_person.intValue() > 0){
				throw new CommonException("选中的人员中含有已申领人员，不可添加，请重新选择！");
			}
			StringBuffer limitPersons = new StringBuffer();
			limitPersons.append("and b.customer_id in (" + personals + ")");
			CardApplyTask task = (CardApplyTask)this.findOnlyRowByHql("from CardApplyTask a where a.taskId = '" + taskId + "'");
			CardConfig config = (CardConfig)this.findOnlyRowByHql("from CardConfig where cardType = '" + task.getCardType() + "'");
			Users oper = (Users)this.findOnlyRowByHql("from Users where userId = '" + actionLog.getUserId() + "'");
			saveBatchApply(limitPersons,task,config,actionLog,oper,customer_ids,customer_ids.length);
		}catch(Exception e){
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
	@SuppressWarnings("unchecked")
	public TrServRec saveBatchApply(StringBuffer limitPersons,CardApplyTask task,CardConfig config,SysActionLog log,Users oper,String[] customer_ids,Integer num) throws CommonException {
		try{
			publicDao.save(log);
			String city_code = Tools.tensileString(this.findOnlyFieldBySql("SELECT T.PARA_VALUE FROM SYS_PARA T WHERE T.PARA_CODE = 'CITY_CODE'").toString(),4,true,"0");
			if(Tools.processNull(city_code).trim().equals("")){
				throw new CommonException("城市代码不能为空，SYS_PARA中找不到参数CITY_CODE");
			}
			Object[] branch_card_flag = (Object[])this.findOnlyRowBySql("SELECT B.CARD_FLAG,B.REGION_CODE FROM SYS_BRANCH S,BASE_REGION B WHERE S.REGION_ID = B.REGION_ID AND S.BRCH_ID = '" + oper.getBrchId() + "'");           
			if(branch_card_flag == null || branch_card_flag.length <= 0){
				throw new CommonException("网点所属区域或区域区编码设置不正确！");
			}
			if(branch_card_flag == null || branch_card_flag.length <= 0){
				throw new CommonException("网点所属区域或区域区编码设置不正确！");
			}
			if(Tools.processNull(branch_card_flag[0]).equals("")){
				throw new CommonException("网点所属区域的CARD_FLAG字段设置不正确！");
			}
			if(Tools.processNull(branch_card_flag[1]).equals("")){
				throw new CommonException("网点所属区域的REGION_CODE字段设置不正确！");
			}
			if(Tools.processNull(task.getMedWholeNo()).equals(this.getBrchRegion())){
				throw new CommonException("网点所属区域和任务的原所属区域不一致！");
			}
			StringBuffer slsql = new StringBuffer();
			slsql.append("INSERT INTO CARD_APPLY_GMSL_TEMP (APPLY_ID,BAR_CODE,CUSTOMER_ID,CARD_NO,SUB_CARD_NO,CARD_TYPE,BANK_ID,VERSION,ORG_CODE,");
			slsql.append("CITY_CODE,INDUS_CODE,APPLY_WAY,APPLY_TYPE,MAKE_TYPE,APPLY_BRCH_ID,CORP_ID,COMM_ID,TOWN_ID,APPLY_STATE,APPLY_USER_ID,");
			slsql.append("APPLY_DATE,COST_FEE,FOREGIFT,IS_URGENT,URGENT_FEE,IS_PHOTO,BUS_TYPE, MAIN_FLAG, OTHER_FEE, WALLET_USE_FLAG,RECV_BRCH_ID,DEAL_NO,MED_WHOLE_NO) ");
			//3.符合本次申领条件的限制语句
			slsql.append("SELECT SEQ_APPLY_ID.NEXTVAL,LPAD(SEQ_BAR_CODE.NEXTVAL,9,'0'),B.CUSTOMER_ID,");
			//slsql.append("(case when b.reside_Type = 0 then r.region_Code else '" + branch_card_flag[1].toString() + "' end),");
			slsql.append(Tools.processNull(branch_card_flag[1]) + "',");
			slsql.append("PK_PUBLIC.CREATESUBCARDNO('" + branch_card_flag[0] + "',LPAD(SEQ_SUB_CARD_NO.NEXTVAL,7,'0')),'");
			slsql.append(task.getCardType() + "','" + task.getBankId() + "','" + Constants.CARD_VERSION + "','" + Constants.INIT_ORG_ID + "','" + city_code + "','");
			slsql.append(Constants.INDUS_CODE + "','" + (task.getTaskWay().equals("2") ? "1" : task.getTaskWay().equals("1") ? "2" : "") + "','" + Constants.APPLY_TYPE_CCSL + "','" + "1" + "','");//是否加急
			slsql.append(oper.getBrchId() + "','" + Tools.processNull(task.getCorpId()) + "',B.COMM_ID,B.TOWN_ID,'");
			slsql.append(Constants.APPLY_STATE_RWYSC + "','" + oper.getUserId() + "',to_date('");
			slsql.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','yyyy-MM-dd HH24:mi:ss'),0,0,'" + Constants.URGENT_WB + "',0,'0',");
			slsql.append("'00'");
			//slsql.append("CASE WHEN MONTHS_BETWEEN(SYSDATE,TO_DATE(SUBSTR(B.CERT_NO,7,8),'YYYYMMDD')) >= 840 THEN '20' ");
			//slsql.append("WHEN MONTHS_BETWEEN(SYSDATE,TO_DATE(SUBSTR(B.CERT_NO,7,8),'YYYYMMDD')) >= 720 THEN '11'  WHEN MONTHS_BETWEEN(SYSDATE,TO_DATE(SUBSTR(B.CERT_NO,7,8),'YYYYMMDD')) < 216 THEN '10' ELSE '01' END ");
			slsql.append(",'',0,'" + Constants.BUS_USE_FLAG_QB + "','" + task.getBrchId() + "'," + log.getDealNo() + ",'" + this.getBrchRegion() + "' ");
			slsql.append("FROM BASE_PERSONAL B,BASE_SIINFO F " );
			if(Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_SQ)){
				slsql.append(",BASE_REGION R,BASE_TOWN W,BASE_COMM M ");
			}
			slsql.append("WHERE B.SURE_FLAG = '0' AND B.CUSTOMER_STATE = '0' AND B.CERT_NO = F.CERT_NO AND B.NAME = F.NAME AND F.MED_STATE = '0' AND F.MED_WHOLE_NO = '" + task.getMedWholeNo() + "' ");
			if(Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_SQ)){
				slsql.append("AND B.REGION_ID = R.REGION_ID AND B.TOWN_ID = W.TOWN_ID AND B.COMM_ID = M.COMM_ID AND R.REGION_ID = W.REGION_ID AND W.TOWN_ID = M.TOWN_ID ");
			}
			slsql.append("AND NOT EXISTS(SELECT 1 FROM CARD_APPLY A WHERE A.CUSTOMER_ID = B.CUSTOMER_ID ");
			slsql.append("AND (A.APPLY_STATE < '" + Constants.APPLY_STATE_YZX + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_WJWSHBTG + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_YZX  + "' AND A.APPLY_STATE <> '" + Constants.APPLY_STATE_YHSHBTG + "')) ");
			if(Tools.processNull(task.getIsPhoto()).equals(Constants.YES_NO_YES)){
				slsql.append("AND EXISTS (SELECT 1 FROM BASE_PHOTO P WHERE P.CUSTOMER_ID = B.CUSTOMER_ID AND P.PHOTO_STATE = '0' AND LENGTHB(P.PHOTO) > 0) ");
			}
			slsql.append(limitPersons);
			publicDao.doSql("DELETE FROM CARD_APPLY_GMSL_TEMP T WHERE T.APPLY_USER_ID = '" + oper.getUserId() + "'");
			int allCount = publicDao.doSql(slsql.toString());
			if(allCount == 0){
				throw new CommonException("根据本次条件申领0个人员，本次操作无效，请仔细核对后重新进行操作！");
			}
			int region_Code_Count = publicDao.findBySQL("SELECT 1 FROM CARD_APPLY_GMSL_TEMP WHERE LENGTH(CARD_NO) != 2 AND APPLY_USER_ID = '" + oper.getUserId() + "' AND DEAL_NO = " + log.getDealNo()).size();
			if(region_Code_Count != 0){
				throw new CommonException("当前申领人员中有\"" + region_Code_Count + "\"个人所在区县编号为空，请先设置城区编码");
			}
			publicDao.doSql("UPDATE CARD_APPLY_GMSL_TEMP C SET C.TASK_ID = " + task.getTaskId() + " WHERE APPLY_USER_ID = '" + oper.getUserId() + "' AND DEAL_NO = " + log.getDealNo()); 
			if(Tools.processNull(task.getIsUrgent()).equals(Constants.URGENT_WB)){
				List<?> cardno = this.findBySql("SELECT CARD_TYPE,CARD_NO,COUNT(1) FROM CARD_APPLY_GMSL_TEMP T WHERE t.APPLY_USER_ID = '" + oper.getUserId() + "' and DEAL_NO = " + log.getDealNo() + " GROUP BY CARD_TYPE,CARD_NO ");
				for(int n = 0;n < cardno.size();n++){
					Object[] o = (Object[])cardno.get(n);
					try{
						this.createCardNo(Tools.processNull(o[0]),o[1].toString(),((BigDecimal)(o[2])).longValue(),log.getDealNo());
					}catch(Exception e){
						throw new CommonException(e.getMessage());
					}finally{
						DEAL_CARD_NO_WAIT = false;
					}
					String updatecardno = "MERGE INTO CARD_APPLY_GMSL_TEMP A USING (SELECT A.CARD_NO,B.APPLY_ID FROM (SELECT CARD_NO,ROWNUM RN " +
					"FROM CARD_NO WHERE USED = 0 AND DEAL_NO = " + log.getDealNo() +
					") A, (SELECT APPLY_ID,ROWNUM RN FROM CARD_APPLY_GMSL_TEMP WHERE  CARD_TYPE = '" + o[0] +
					"' AND DEAL_NO = " + log.getDealNo() + ") B WHERE A.RN = B.RN) C ON (A.APPLY_ID = C.APPLY_ID) WHEN MATCHED THEN UPDATE SET A.CARD_NO = C.CARD_NO";
					publicDao.doSql(updatecardno);
				}
			}else if(Tools.processNull(task.getIsUrgent()).equals(Constants.URGENT_BD)){
				publicDao.doSql("UPDATE CARD_APPLY_GMSL_TEMP T SET T.CARD_NO = '' WHERE T.TASK_ID = '" + task.getTaskId() + "' AND T.DEAL_NO = " + log.getDealNo());
			}
			StringBuffer insertApplySql = new StringBuffer();
			insertApplySql.append("INSERT INTO CARD_APPLY (APPLY_ID, BAR_CODE, CUSTOMER_ID,CARD_NO,TASK_ID,SUB_CARD_NO,CARD_TYPE,SUB_CARD_TYPE, ");
			insertApplySql.append("BANK_ID, BANK_CARD_NO, VERSION, ORG_CODE, CITY_CODE, INDUS_CODE, APPLY_WAY, APPLY_TYPE, MAKE_TYPE, APPLY_BRCH_ID, CORP_ID,");
			insertApplySql.append("APPLY_STATE, APPLY_USER_ID, APPLY_DATE, COST_FEE, FOREGIFT, IS_URGENT, IS_PHOTO, RECV_BRCH_ID,");
			insertApplySql.append("RECV_CERT_TYPE, RECV_CERT_NO, RECV_NAME, RELS_BRCH_ID, RELS_USER_ID, RELS_DATE, AGT_CERT_TYPE, AGT_CERT_NO, AGT_NAME,");
			insertApplySql.append("AGT_PHONE, DEAL_NO, NOTE, BUS_TYPE, OLD_CARD_NO, OLD_SUB_CARD_NO, MESSAGE_FLAG, MOBILE_PHONE, MAIN_FLAG, MAIN_CARD_NO,");
			insertApplySql.append("OTHER_FEE, WALLET_USE_FLAG, MONTH_TYPE, MONTH_CHARGE_MODE,TOWN_ID,COMM_ID,MED_WHOLE_NO) ");
			insertApplySql.append("SELECT T.APPLY_ID,T.BAR_CODE,T.CUSTOMER_ID,T.CARD_NO,T.TASK_ID,t.SUB_CARD_NO,");
			insertApplySql.append("T.CARD_TYPE,T.SUB_CARD_TYPE,'',T.BANK_CARD_NO,T.VERSION,T.ORG_CODE,T.CITY_CODE,T.INDUS_CODE,T.APPLY_WAY,");
			insertApplySql.append("T.APPLY_TYPE,t.MAKE_TYPE,t.APPLY_BRCH_ID,t.CORP_ID,T.APPLY_STATE,t.APPLY_USER_ID,T.APPLY_DATE,");
			insertApplySql.append("T.COST_FEE,T.FOREGIFT,T.IS_URGENT,T.IS_PHOTO,T.RECV_BRCH_ID,T.RECV_CERT_TYPE,T.RECV_CERT_NO,T.RECV_NAME,T.RELS_BRCH_ID,");
			insertApplySql.append("T.RELS_USER_ID,T.RELS_DATE,T.AGT_CERT_TYPE,T.AGT_CERT_NO,T.AGT_NAME,T.AGT_PHONE,T.DEAL_NO,NULL,'00',");//嘉兴公交类型00
			insertApplySql.append("T.OLD_CARD_NO,T.OLD_SUB_CARD_NO,T.MESSAGE_FLAG,T.MOBILE_PHONE,T.MAIN_FLAG,T.MAIN_CARD_NO,T.OTHER_FEE,T.WALLET_USE_FLAG,T.MONTH_TYPE,");
			insertApplySql.append("T.MONTH_CHARGE_MODE,t.TOWN_ID,t.COMM_ID,MED_WHOLE_NO FROM CARD_APPLY_GMSL_TEMP t WHERE t.APPLY_USER_ID = '" + oper.getUserId() + "' AND DEAL_NO = " + log.getDealNo());
			publicDao.doSql(insertApplySql.toString());
			insertCardtasklist(limitPersons.toString(), task, config, this.getSysConfigurationParameters("Apply_Ws_Flag"), customer_ids);
			Object[] o =(Object[])this.findOnlyRowBySql("select min(card_no),max(card_no) " + "from card_task_list l where l.task_id = '" + task.getTaskId() + "'");
			task.setStartCardNo(Tools.processNull(o[0]));
			task.setEndCardNo(Tools.processNull(o[1]));
			task.setTaskSum(task.getTaskSum() + num);
			publicDao.update(task);
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
	public void insertCardtasklist(String limitpersons,CardApplyTask task,CardConfig para,String isInsertWs,String[] args)throws CommonException{
		try{
			if(para == null){
				throw new CommonException("该卡类型参数设置信息不存在！");
			}
			if(Tools.processNull(para.getCardValidityPeriod()).equals("")){
				throw new CommonException("该卡类型卡片有效期年数信息未设置！" + para.getCardType());
			}
			String city_code = Tools.tensileString(this.findOnlyFieldBySql("SELECT T.PARA_VALUE FROM SYS_PARA T WHERE T.PARA_CODE = 'CITY_CODE'").toString(),4,true,"0");
			if(Tools.processNull(city_code).trim().equals("")){
				throw new CommonException("城市代码不能为空，SYS_PARA中找不到参数CITY_CODE");
			}
			String month_Type = this.findOnlyFieldBySql("SELECT T.PARA_VALUE FROM SYS_PARA T WHERE T.PARA_CODE = 'MONTH_TYPE'").toString();
			if(Tools.processNull(month_Type).trim().equals("")){
				month_Type = "00";
			}
			String ndate = DateUtil.formatDate(task.getTaskDate(),"yyyyMMdd");
			String lsdate = DateUtil.processDateAddYear(DateUtil.formatDate(task.getTaskDate(),"yyyy-MM-dd"),para.getCardValidityPeriod()).replaceAll("-","");//根据设置参数计算卡片有效期限 格式:YYYYMMDD
			String pwd_rule = this.findOnlyFieldBySql("SELECT T.PARA_VALUE FROM SYS_PARA T WHERE T.PARA_CODE = 'PWD_RULE'").toString();//开通交易密码规则，0常数，1随机
			if(Tools.processNull(pwd_rule).trim().equals("")){
				pwd_rule = "0";
			}
			String initpwd = this.findOnlyFieldBySql("SELECT T.PARA_VALUE FROM SYS_PARA T WHERE T.PARA_CODE = 'INITPWD'").toString();
			if(Tools.processNull(initpwd).trim().equals("")){
				initpwd = "888888";
			}
			StringBuffer exesql = new StringBuffer();
			exesql.append("INSERT INTO CARD_TASK_LIST(DATA_SEQ,TASK_ID,CUSTOMER_ID,NAME,SEX,CERT_TYPE,CERT_NO,");
			exesql.append("NATION,BIRTHPLACE,BIRTHDAY,RESIDE_TYPE,RESIDE_ADDR,LETTER_ADDR,POST_CODE,MOBILE_NO,EDUCATION,");
			exesql.append("MARR_STATE,CARD_TYPE,CARD_NO,VERSION,INIT_ORG_ID,CITY_CODE,INDUS_CODE,CARDISSUEDATE,VALIDITYDATE,BURSESTARTDATE,");
			exesql.append("BURSEVALIDDATE,MONTHSTARTDATE,MONTHVALIDDATE,STRUCT_MAIN_TYPE,STRUCT_CHILD_TYPE,FACE_VAL,PWD,");
			exesql.append("BAR_CODE,COMM_ID,BURSEBALANCE,MONTHBALANCE,BANK_ID,BANKCARDNO,BANKSECTION2,BANKSECTION3,PHOTOFILENAME,");
			exesql.append("USEFLAG,DEPARTMENT,CLASSID,APPLY_ID,MONTH_TYPE)");
			exesql.append(" SELECT SEQ_DATA_SEQ.NEXTVAL,A.TASK_ID,B.CUSTOMER_ID,B.NAME,B.GENDER,B.CERT_TYPE,B.CERT_NO,B.NATION,'',");
			exesql.append("REPLACE(B.BIRTHDAY,'-',''),B.RESIDE_TYPE,B.RESIDE_ADDR,B.LETTER_ADDR,B.POST_CODE,B.MOBILE_NO,B.EDUCATION,");
			exesql.append("B.MARR_STATE,A.CARD_TYPE,A.CARD_NO,A.VERSION,A.ORG_CODE,A.CITY_CODE,A.INDUS_CODE,'");
			exesql.append(ndate + "','" + lsdate + "','" + ndate + "','" + lsdate + "','" + ndate + "','" + ndate + "',a.bus_Type,'" + Tools.processNull(para.getStructChildType()) + "',nvl(");
			exesql.append(para.getFaceVal() + ",'0')," + (Tools.processNull(pwd_rule).equals("0") ? "'" + initpwd + "'" : "ceil(dbms_random.value(100000,999999))") + ",");
			exesql.append("A.BAR_CODE,B.COMM_ID,'" + Constants.BURSEBALANCE+"','" + Constants.MONTHBALANCE + "',");
			exesql.append("A.BANK_ID,A.BANK_CARD_NO,'','',B.CERT_NO||'.jpg','" + Constants.USED_FLAG);
			exesql.append("',B.DEPARTMENT,B.CLASSID,A.APPLY_ID,'" + month_Type + "'");
			exesql.append("FROM CARD_APPLY A ,BASE_PERSONAL B WHERE B.CUSTOMER_ID = A.CUSTOMER_ID  ");
			exesql.append("AND A.APPLY_STATE = '" + Constants.APPLY_STATE_RWYSC + "'");
			exesql.append(limitpersons);
			int c = publicDao.doSql(exesql.toString());
			publicDao.doSql("UPDATE CARD_TASK_LIST C SET C.MARR_STATE = (DECODE(C.MARR_STATE,'10','1','20','2','21','2','22','2','23','2','30','3','40','4','10'))  WHERE C.TASK_ID = '" 
			+ task.getTaskId() + "' AND C.CUSTOMER_ID IN (" + Tools.getConcatStrFromArray(args, "'",",") + ")");
			int ci = publicDao.doSql("UPDATE CARD_TASK_LIST C SET C.CERT_TYPED = (DECODE(C.CERT_TYPE,'1','00','2','05','3','01','4','02','5','04','6','05','05')) WHERE c.TASK_ID = '" 
			+ task.getTaskId() + "' AND C.CUSTOMER_ID IN (" + Tools.getConcatStrFromArray(args, "'",",") + ")");
			//publicDao.doSql("UPDATE CARD_TASK_LIST C SET C.BURSEVALIDDATE = TO_CHAR(ADD_MONTHS(TO_DATE(BURSESTARTDATE,'YYYYMMDD'),(18 * 12 - MONTHS_BETWEEN(SYSDATE,TO_DATE(C.BIRTHDAY,'YYYYMMDD')))),'YYYYMMDD') "
			//+ "WHERE C.STRUCT_MAIN_TYPE = '10' AND C.TASK_ID = '" + task.getTaskId() + "' AND C.CUSTOMER_ID IN ("+Tools.getConcatStrFromArray(args, "'",",")+")"); 
			//publicDao.doSql("UPDATE CARD_TASK_LIST C SET C.BURSEVALIDDATE = TO_CHAR(ADD_MONTHS(TO_DATE(BURSESTARTDATE,'YYYYMMDD'),(70 * 12 - MONTHS_BETWEEN(SYSDATE,TO_DATE(C.BIRTHDAY,'YYYYMMDD')))),'YYYYMMDD')" +
			//"WHERE C.STRUCT_MAIN_TYPE = '11' AND C.TASK_ID = '" + task.getTaskId() + "' AND C.CUSTOMER_ID IN(" + Tools.getConcatStrFromArray(args, "'",",") + ")"); 
			if(c != args.length || ci != args.length){
				throw new CommonException("生成制卡明细数量和勾选人员的数量不一致");
			}
		}catch(Exception e){
			logger.error(e);
			throw new CommonException("生成制卡明细出错！" + e.getMessage());
		}
	}
	/**
	 * 任务明细删除
	 * @param actionLog
	 * @param mxIds
	 * @param taskId
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	@Override
	public void deleteTaskMx(String taskId,String mxIds,String customerIds,SysActionLog actionLog)throws CommonException {
		try {
			if(Tools.processNull(taskId).equals("")){
				throw new CommonException("任务编号不能为空！");
			}
			CardApplyTask tempTask = (CardApplyTask)this.findOnlyRowByHql("from CardApplyTask where taskId = '" + taskId + "'");
			if(tempTask == null){
				throw new CommonException("根据任务编号【" + taskId + "】 未找到任务信息，请确认任务信息是否存在！");
			}
			if(!Tools.processNull(tempTask.getTaskState()).equals(Constants.TASK_STATE_YSC)){
				throw new CommonException("任务状态已是【" + this.getCodeNameBySYS_CODE("TASK_STATE",tempTask.getTaskState()) + "】，无法进行删除！");
			}
			if(Tools.processNull(mxIds).equals("")){
				throw new CommonException("请勾选需要进行删除的制卡明细信息！");
			}
			actionLog.setDealCode(DealCode.APPLY_PROCESS_DELETEMXFROMTASK);
			actionLog.setMessage("删除任务明细信息,任务编号:" + taskId + ",人员编号:" + customerIds + ",明细号:" + mxIds);
			publicDao.save(actionLog);
			String[] dataSeqs = mxIds.split("\\|");
			if(dataSeqs.length < 1){
				throw new CommonException("未选择任何任务明细，请选择任务明细进行操作！");
			}
			String dataSeqSql = Tools.getConcatStrFromArray(dataSeqs, "'", ",");
			int hasDelCount = 0;
			if(Tools.processNull(tempTask.getIsUrgent()).equals(Constants.URGENT_WB)){
				hasDelCount = publicDao.doSql("update card_no b set b.used = '1',b.deal_no = null where exists ("
				+ "select 1 from card_task_list t1 where t1.card_no = b.card_no and t1.data_seq in (" + dataSeqSql + ") and t1.task_id ='" + tempTask.getTaskId() + "')");
				if(hasDelCount != dataSeqs.length){
					throw new CommonException("删除制卡明细时，释放卡号资源数量不正确！");
				}
			}
			if(Tools.processNull(tempTask.getTaskWay()).equals(Constants.TASK_WAY_SQ) || Tools.processNull(tempTask.getTaskWay()).equals(Constants.TASK_WAY_DW) ||
				Tools.processNull(tempTask.getTaskWay()).equals(Constants.TASK_WAY_XX)
			){
				hasDelCount = publicDao.doSql("delete from card_apply t where t.task_id = '" + taskId + "' and exists (select 1 from card_task_list t1 where t1.task_id = '" +
				taskId + "' and t1.apply_id = t.apply_id and t1.customer_id = t.customer_id and t1.data_seq in (" + dataSeqSql + "))");
				if(hasDelCount != dataSeqs.length){
					throw new CommonException("删除制卡明细时，删除申领信息数量不正确！");
				}
			}else{
				hasDelCount = publicDao.doSql("update card_apply t set t.task_id = null,t.apply_state = '" + Constants.APPLY_STATE_YSQ + "' where t.task_id = '" + taskId + "' and exists ("
				+ "select 1 from card_task_list t1 where t1.customer_id = t.customer_id and t1.data_seq in (" + dataSeqSql + "))");
				if(hasDelCount != dataSeqs.length){
					throw new CommonException("删除制卡明细时，更新申领信息数量不正确！");
				}
			}
			hasDelCount = publicDao.doSql("delete from card_task_list a where a.data_seq in (" + dataSeqSql + ")");
			if(hasDelCount != dataSeqs.length){
				throw new CommonException("删除制卡明细数量和勾选数量不一致！");
			}
			if(tempTask.getTaskSum() == dataSeqs.length){
				publicDao.doSql("delete card_apply_task where task_id = '" + taskId + "'");
			}else{
				publicDao.doSql("update card_apply_task b set b.task_sum = b.task_sum - " + dataSeqs.length + " where b.task_id = '" + taskId + "'");
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealCode(actionLog.getDealCode());
			rec.setBrchId(actionLog.getBrchId());
			rec.setUserId(actionLog.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setOrgId(actionLog.getOrgId());
			rec.setClrDate(this.getClrDate());
			rec.setCardType(tempTask.getCardType());
			rec.setNote(actionLog.getMessage());
			publicDao.save(rec);
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}

	/**
	 * 删除（回退）任务
	 * @param actionLog
	 * @param mxIds
	 * @param taskId
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec deleteTask(String taskId,SysActionLog actionLog)throws CommonException {
		try {
			if(Tools.processNull(taskId).equals("")){
				throw new CommonException("任务编号不能为空！");
			}
			CardApplyTask task = (CardApplyTask) this.findOnlyRowByHql("from CardApplyTask t where t.taskId = '" + taskId + "'");
			if(task == null){
				throw new CommonException("任务编号为【" + taskId + "】的任务无法进行删除，根据编号找不到任务信息！");
			}
			if(!Tools.processNull(task.getTaskState()).equals(Constants.TASK_STATE_YSC)){
				throw new CommonException("任务编号为【" + taskId + "】的任务的任务状态已是【" + this.getCodeNameBySYS_CODE(task.getTaskState(),"TASK_STATE") + "】无法进行删除！");
			}
			if(!Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_SQ) && !Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_DW)
				&& !Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_XX) && !Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_WD)
				&& !Tools.processNull(task.getTaskWay()).equals(Constants.TASK_WAY_DR)
			){
				throw new CommonException("任务编号为【" + taskId + "】的任务，找不到任务组织方式！");
			}
			actionLog.setDealCode(DealCode.TASK_MANAGE_DEL);
			actionLog.setMessage("任务删除，编号为:" + taskId + "");
			publicDao.save(actionLog);
			int hasDeleCount = 0;
			if(Tools.processNull(task.getIsUrgent()).equals(Constants.URGENT_WB)){
				hasDeleCount = publicDao.doSql("update card_no c set c.used = '1',c.deal_no = null where "
						+ "exists (select 1 from card_apply a where a.card_no = c.card_no and a.task_id = '" + taskId + "' and a.apply_state = '" + Constants.APPLY_STATE_RWYSC + "')");
				if(hasDeleCount != task.getTaskSum()){
					throw new CommonException("删除任务【" + taskId + "】时更新卡号数量不正确！");
				}
			}
			if(Tools.processNull(task.getIsJrsbkDr()).equals(Constants.YES_NO_YES)){
				BigDecimal tempDrDealNoBig = (BigDecimal) this.findOnlyFieldBySql("select deal_no from base_personal_import where task_id = '" + task.getTaskId() + "' and rownum = 1");
				this.publicDao.doSql("update base_personal_import t set t.deal_state = '2',t.task_id = '',t.apply_id = '' where t.task_id = '" + task.getTaskId() + "'");
				this.publicDao.doSql("update base_personal_import_batch t set t.state = '2',t.apply_nums = (t.apply_nums - " + task.getTaskSum() + ") where t.deal_no = " + tempDrDealNoBig.intValue() + "");
			}
			if(Tools.processNull(task.getTaskSrc()).equals(Constants.TASK_SRC_GMSL)){
				hasDeleCount = publicDao.doSql("delete card_apply t where t.task_id = '" + taskId + "'");
				if(hasDeleCount != task.getTaskSum()){
					throw new CommonException("删除任务【" + taskId + "】时，申领信息数量和任务数量不一致！");
				}
			}else{
				hasDeleCount = publicDao.doSql("update card_apply t set t.task_id = null,t.apply_state = '" + Constants.APPLY_STATE_YSQ + "' where t.task_id = '" + taskId + "'");
				if(hasDeleCount != task.getTaskSum()){
					throw new CommonException("删除任务【" + taskId + "】时，申领信息数量和任务数量不一致！");
				}
			}
			hasDeleCount = publicDao.doSql("delete card_task_list a where a.task_id = '" + taskId + "'");
			if(hasDeleCount != task.getTaskSum()){
				throw new CommonException("删除任务【" + taskId + "】时，制卡明细数量和任务数量不一致！");
			}
			publicDao.delete(task);
			publicDao.doSql("delete base_personal_apply b where  b.task_id = '" + taskId + "'");
            if(this.getSysConfigurationParameters("Apply_Sb_Flag").equals("0")){//#申领数据是否导出给社保明细0不导出,1导出
    			publicDao.doSql("delete card_apply_task_sb sb where  sb.task_id = '" + taskId + "'");
			}
            if(this.getSysConfigurationParameters("Apply_Ws_Flag").equals("0")){//#申领数据是否导出给卫生明细0不导出,1导出
    			publicDao.doSql("delete card_task_list_ws ws where  ws.task_id = '" + taskId + "'");
			}
            TrServRec rec = new TrServRec();
            rec.setDealNo(actionLog.getDealNo());
            rec.setDealCode(actionLog.getDealCode());
            rec.setBizTime(actionLog.getDealTime());
            rec.setBrchId(actionLog.getBrchId());
            rec.setUserId(actionLog.getUserId());
            rec.setClrDate(this.getClrDate());
            rec.setDealState(Constants.TR_STATE_ZC);
            rec.setNote(actionLog.getMessage());
            rec.setOrgId(rec.getOrgId());
            publicDao.save(rec);
            return rec;
		}catch(Exception e){
			throw new CommonException("删除制卡任务明细：" + e.getMessage());
		}
	}
	/**
	 * 导出数据给银行进行数据审核
	 * @param actionLog 操作日志
	 * @param user 操作员
	 * @param taskId 任务编号
	 * @param bankId 银行编号
	 * @param vendorId 卡商编号
	 * @return 导出记录总数          
	 * @throws CommonException
	 * @Version 1.0
	 */
	@SuppressWarnings("unchecked")
	public Long saveExportTaskToBank(String[] taskId,String cardType,String isUrgent,String bankId,String vendorId,Users user,SysActionLog actionLog) throws CommonException {
		String fileName = "";
		DefaultFTPClient ftpClient = null;
		Long totNums = 0L;
		try {
			logger.error(Tools.tensileString("-",50,true,"-"));
			logger.error("#开始生成市民卡银行审核文件");
			logger.error("#正在检查FTP配置信息");
			Map<String,String>  ftpOptions = this.initFtpOptions("make_card_task_to_bank_" + bankId);
			ftpClient = this.checkFtp(ftpOptions);
			if(Tools.processNull(ftpOptions.get("host_download_path")).equals("")){
				throw new CommonException("获取ftp配置出错，ftp银行下载路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_download_path:" + ftpOptions.get("host_download_path"));
			}
			if(!ftpClient.changeWorkingDirectory("/") || !ftpClient.changeWorkingDirectory(ftpOptions.get("host_download_path"))){
				throw new CommonException("FTP切换到目录" + ftpOptions.get("host_download_path") + "失败！");
			}else{
				logger.error("FTP目录切换正常");
			}
			logger.error("当前工作目录" + ftpClient.printWorkingDirectory());
			ftpClient.logout();
			ftpClient.disconnect();
			ftpClient = null;
			logger.error("FTP检查完毕");
			CardTaskBatch taskBatch = new CardTaskBatch();
			taskBatch.setBatchId(this.getSequenceByName("seq_cm_card_task_batch"));//批次号
			taskBatch.setSendtobankOrgId(user.getOrgId());//发送银行机构
			taskBatch.setSendtobankBrchId(user.getBrchId());//发送银行网点
			taskBatch.setSendtobankUserId(user.getUserId());//发送银行柜员编号
			taskBatch.setSendtobankDate(actionLog.getDealTime());//发送银行时间
			taskBatch.setVendorId(vendorId);//卡厂编号
			taskBatch.setMakeWay(isUrgent);//制卡方式
			taskBatch.setCardType(cardType);//卡类型
			taskBatch.setBankId(bankId);//接收银行编号
			fileName = "SH" + "_" + taskBatch.getBatchId() + "_" + Tools.tensileString(bankId,15,false,"0") + "_" + DateUtil.formatDate(actionLog.getDealTime(),"yyyyMMddHHmmss");
			logger.error("生成银行审核文件名:" + fileName);
			actionLog.setDealCode(DealCode.PUBLICCARD_EXPORTTOYH);
			actionLog.setMessage("制卡数据导出到银行,批次号" + taskBatch.getBatchId());
			publicDao.save(actionLog);
			taskBatch.setDealNo(Integer.valueOf(actionLog.getDealNo() + ""));//批次生成流水
			List<CardApplyTask> list = this.findByHql("from CardApplyTask where taskId in (" + Tools.getConcatStrFromArray(taskId,"'",",") + ") and taskState = '" + Constants.TASK_STATE_YSC + "'");
			if(list == null || list.size() <= 0){
				throw new CommonException("根据选定的任务编号，找不到对应任务信息！");
			}
			logger.error("开始写入文件需要审核数据");
			StringBuffer sbline = new StringBuffer();
			for(int i = 0;i < list.size();i++){
				CardApplyTask task = list.get(i);
				totNums = totNums + task.getTaskSum();
				StringBuffer execCardTaskListSql = new StringBuffer();
				execCardTaskListSql.append("select l.data_seq,l.task_id,l.name,b.gender,decode(b.cert_type,'1','01','2','10','3','02','4','03','5','10','6','10','10') cert_type,");
				execCardTaskListSql.append("b.cert_no,b.nation,'CHN' country,");
				execCardTaskListSql.append("b.reside_addr,substr(b.cert_no,7,8) birthday,b.mobile_no,b.phone_no,b.letter_addr,b.corp_customer_id,p.corp_name,m.town_name,");
				execCardTaskListSql.append("n.comm_name,'' jhname,'' jhgender,'' jhcerttype,'' jhcertno,c.recv_brch_id,s.full_name ");
				execCardTaskListSql.append("from card_task_list l,card_apply c,base_personal b,base_corp p,base_town m,base_comm n,Sys_Branch s ");
				execCardTaskListSql.append("where l.apply_id = c.apply_id and c.customer_id = b.customer_id AND b.corp_customer_id = p.customer_id(+) and ");
				execCardTaskListSql.append("b.town_id = m.town_id(+) and b.comm_id = n.comm_id(+) and c.recv_brch_id = s.brch_id(+) ");
				execCardTaskListSql.append("and l.task_id = '" + task.getTaskId() + "'");
				List<Object[]> allRes = this.findBySql(execCardTaskListSql.toString());
				if(allRes != null && allRes.size() > 0){
					if(allRes.size() != task.getTaskSum()){
						throw new CommonException("在导出任务【" + task.getTaskName() + "】时，制卡明细数量和任务数量不一致！");
					}
					for(int m = 0;m < allRes.size();m++){
						Object[] tempRow = allRes.get(m);
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[0]),12,false," "));//任务明细号 12 左靠齐，右补空格
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[1]),32,false," "));//任务编号  32 左靠齐，右补空格
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[2]),30,false," "));//姓名  30 左靠齐，右补空格
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[3]),1,false," "));//性别 1 
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[4]),2,false," "));//证件类型 2
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[5]),18,false," "));//证件号码 18
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[6]),2,false," "));//民族 2
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[7]),3,false," "));//国国籍 3
						sbline.append(Tools.tensileStringByByte(Tools.processNull(" "),6,false," "));//出生地 6 待定
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[9]),8,false," "));//出生年月 8 
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[10]),11,false," "));//手机号码 11
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[11]),15,false," "));//联系电话 15
						sbline.append(Tools.tensileStringByByte(Tools.tensileString(Tools.processNull(tempRow[12]),30,false," "),60,false," "));//联系地址
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[13]),20,false," "));//单位编号 20
						sbline.append(Tools.tensileStringByByte(Tools.tensileString(Tools.processNull(tempRow[14]),40,false," "),80,false," "));//单位名称 80
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[15]),50,false," "));//乡镇街道 50
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[16]),50,false," "));//村社区 50
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[17]),60,false," "));//监护人姓名 60
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[18]),1,false," "));//监护人性别 1
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[19]),2,false," "));//监护人证件类型 2
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[20]),18,false," "));//监护人证件号码 18
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[21]),8,false," "));//领卡网点 8
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[22]),50,false," "));//领卡网点名称
						sbline.append(Tools.tensileStringByByte(Tools.processNull("F"),50,false,"F"));//保留域 50
						sbline.append("\n");
					}
				}else{
					throw new CommonException("在导出任务【" + task.getTaskName() + "】时，找不到制卡明细信息或个人信息不完善！");
				}
				int updateCts = publicDao.doSql("update card_apply_task c set c.task_state = '" + Constants.TASK_STATE_YFYH + "',c.make_Batch_Id = '" + taskBatch.getBatchId() +
				"' ,c.bank_id = '" + bankId + "' where c.task_id = '" + task.getTaskId() + "' and c.task_state = '" + Constants.TASK_STATE_YSC  + "'");
				if(updateCts != 1){
					throw new CommonException("在导出任务【" + task.getTaskName() + "】时，更新任务状态不正确！");
				}
				updateCts = publicDao.doSql("update card_apply set apply_state = '" + Constants.APPLY_STATE_YFBANK + "',buy_plan_id = '" + taskBatch.getBatchId() +
				"' ,bank_id = '" + bankId + "' where task_id = '" + task.getTaskId() + "' and apply_state = '" + Constants.APPLY_STATE_RWYSC + "'");
				if(updateCts != task.getTaskSum()){
					throw new CommonException("在导出任务【" + task.getTaskName() + "】时，更新申领状态数量和任务数量不一致！");
				}
				logger.error("写入任务 " + task.getTaskId() + " " + task.getTaskName() + " 数量 " + task.getTaskSum() );
			}
			taskBatch.setBatchNum(Integer.valueOf(totNums + ""));//批次内总的制卡数量
			taskBatch.setTaskNum(list.size());//批次内包含任务的个数
			publicDao.save(taskBatch);
			StringBuffer finalFileConts = new StringBuffer();
			finalFileConts.append("SH".toUpperCase() + Tools.tensileString(totNums + "",8,true,"0") + Tools.tensileString("589",8,true,"0"));
			finalFileConts.append(Tools.tensileString("F",10,true,"F") + "\n");
			finalFileConts.append(sbline);
			logger.error("文件生成成功,开始上传FTP:" + ftpOptions.get("host_download_path") + fileName);
			ByteArrayInputStream is = new ByteArrayInputStream(finalFileConts.toString().getBytes("GBK"));
			ftpClient = new DefaultFTPClient();
			if(!ftpClient.toConnect(ftpOptions.get("url"),Integer.valueOf(ftpOptions.get("port")))){
				throw new CommonException("FTP连接失败！");
			}
			ftpClient.setControlEncoding("GBK");
			if(!ftpClient.toLogin(ftpOptions.get("userName"),ftpOptions.get("pwd"))){
				throw new CommonException("FTP登录失败！");
			}
			if(!ftpClient.changeWorkingDirectory("/") || !ftpClient.changeWorkingDirectory(ftpOptions.get("host_download_path"))){
				throw new CommonException("FTP切换到目录" + ftpOptions.get("host_download_path") + "失败！");
			}
			logger.error("当前工作目录" + ftpClient.printWorkingDirectory());
			ftpClient.setFileType(FTPClient.BINARY_FILE_TYPE);
			if(ftpClient.storeFile(fileName.toUpperCase(),is)){
				try{
					JSONArray array = new JSONArray();
					JSONObject one = new JSONObject();
					one.put("trcode","B0055");
					one.put("bizid",bankId);
					one.put("termid",user.getUserId());
					one.put("termno",actionLog.getDealNo());
					one.put("filetype","000001");
					one.put("makecardtype",(Tools.processNull(isUrgent).equals("0") ? "01" : "02"));
					one.put("filename",fileName);
					one.put("filesize",finalFileConts.toString().getBytes("GBK").length);
					array.add(one);
                    //logger.error(finalFileConts.toString().getBytes("GBK").length);
					JSONArray outs = this.doWorkClientService.invoke(array);
					if(outs == null || outs.size() < 1){
						throw new CommonException("调取银行接口返回为空！");
					}
					JSONObject res = new JSONObject();
					res = (JSONObject) outs.get(0);
					if(!Tools.processNull(res.getString("errcode")).equals("00")){
						throw new CommonException("调取银行接口出现错误，" + res.getString("errmessage"));
					}
				}catch(Exception e2){
					ftpClient.deleteFile(fileName.toUpperCase());
					throw new CommonException(e2.getMessage());
				}
			}else{
				throw new CommonException("上传文件到FTP出现错误：请检查ftp路径设置及网络问题！");
			}
			logger.error("文件" + fileName + "上传成功");
			TrServRec rec =  new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealCode(actionLog.getDealCode());
			rec.setBrchId(actionLog.getBrchId());
			rec.setUserId(actionLog.getUserId());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setOrgId(actionLog.getOrgId());
			rec.setNote(actionLog.getMessage());
			rec.setCardAmt(totNums);
			rec.setBizTime(actionLog.getDealTime());
			publicDao.save(rec);
			System.gc();
		}catch(Exception e){
			e.printStackTrace();
			logger.error("导出银行审核文件" + fileName + "出现错误：" + e.getMessage());
			throw new CommonException("导出银行审核文件出现错误：" + e.getMessage());
		}finally{
			try {
				if(ftpClient != null && ftpClient.isAvailable()){
					ftpClient.logout();
					ftpClient.disconnect();
				}else{
					ftpClient = null;
				}
			} catch (IOException e1){
				e1.printStackTrace();
			}
			logger.error("结束导出银行文件！");
		}
		return totNums;
	}
	/**
	 * 嘉兴导入银行审核数据
	 * @param ftpClient FTP客户端
	 * @param bankIdimp 银行编号
	 * @param subDirPath 待处理子目录
	 * @param fileName   文件名
	 * @param subHisDir  历史目录
	 * @param actionLog  操作日志
	 * @param user       操作员
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public String saveImportTaskRhFile(DefaultFTPClient ftpClient,String fileName,String ImpBankId,Map<String,String> ftpOptions,Users user,SysActionLog actionLog)throws CommonException{
		try {
			long totRows = 0L;
			long tempRows = 0L;
			String batchId = "";
			String bankId = "";
			if(Tools.processNull(ImpBankId).equals("")){
				throw new CommonException("导入的银行编号不能为空！");
			}
			if(!(fileName.toUpperCase().startsWith("RH"))){
				throw new CommonException("文件" + fileName + "的文件名不正确，或对应批次不是一卡通导出");
			}
			String[] fileNameArr = Tools.processNull(fileName).split("_");
			if(fileNameArr.length != 4){
				throw new CommonException("文件" + fileName + "处理失败，文件名不正确！");
			}
			batchId = Tools.processNull(fileNameArr[1]);
			bankId = Tools.processNull(fileNameArr[2]);
			if(!bankId.equals(ImpBankId)){
				throw new CommonException("该文件" + fileName + "不是选定银行返回的审核文件");
			}
			CardTaskBatch taskBatch = (CardTaskBatch) this.findOnlyRowByHql("from CardTaskBatch t where t.batchId = '" + batchId + "'");
			if(taskBatch == null){
				throw new CommonException("根据文件中的批次编号找不到批次信息！");
			}
			taskBatch.setReceivebybankOrgId(user.getOrgId());
			taskBatch.setReceivebybankBrchId(user.getBrchId());
			taskBatch.setReceivebybankUserId(user.getUserId());
			taskBatch.setReceivebybankDate(actionLog.getDealTime());
			publicDao.update(taskBatch);
			BaseBankFile baseBankFile = (BaseBankFile) this.findOnlyRowByHql("from BaseBankFile t where t.fileName = '" + fileName + "'");
			if(baseBankFile == null){
				baseBankFile = new BaseBankFile();
				baseBankFile.setBankId(bankId);
				baseBankFile.setBatchId(batchId);
				baseBankFile.setCardType(Constants.CARD_TYPE_SMZK);
				baseBankFile.setDealState("1");
				baseBankFile.setFileName(fileName);
				baseBankFile.setTransPatch("1");
				baseBankFile.setInDate(actionLog.getDealTime());
				publicDao.save(baseBankFile);
			}else{
				if(!Tools.processNull(baseBankFile.getDealState()).equals("1")){
					throw new CommonException("已入库文件" + baseBankFile.getFileName() + "不是未处理状态，无法进行处理！");
				}
			}
			List<String> fileContent = ftpClient.getFileContent(fileName);
			if(fileContent == null || fileContent.size() <= 1){
				throw new CommonException("文件" + fileName + ",内容为空！");
			}
			totRows = Long.valueOf(new String(fileContent.get(0).getBytes("GBK"),2,8));
			actionLog.setDealCode(DealCode.PUBLICCARD_IMPORTBYH);
			actionLog.setMessage("银行审核文件导入:" + fileName + ",总条数:" + totRows);
			publicDao.save(actionLog);
			StringBuffer sb = new StringBuffer();
			for(int j = 1;j < fileContent.size();j++){
				int pos = 0;
				tempRows++;
				byte[] contents = fileContent.get(j).getBytes("GBK");
				sb.append("'insert into card_apply_bank_rh (res_flag,data_seq,task_id,name,gender,cert_type,cert_no,res_msg,");
				sb.append("resv_one,file_name,file_line_no,tot_rows,state,batch_id,deal_time,bank_id) values (");
				sb.append("''" + Tools.processNull(getStringByByte(contents,pos,1)).trim() + "'',");//审核结果
				pos = pos + 1;
				sb.append("''" + Tools.processNull(getStringByByte(contents,pos,12)).trim() + "'',");//任务明细号
				pos = pos + 12;
				sb.append("''" + Tools.processNull(getStringByByte(contents,pos,32)).trim() + "'',");//任务号
				pos = pos + 32;
				sb.append("''" + Tools.processNull(getStringByByte(contents,pos,30)).trim() + "'',");//姓名
				pos = pos + 30;
				sb.append("''" + Tools.processNull(getStringByByte(contents,pos,1)).trim() + "'',");//性别
				pos = pos + 1;
				sb.append("''" + Tools.processNull(getStringByByte(contents,pos,2)).trim() + "'',");//证件类型
				pos = pos + 2;
				sb.append("''" + Tools.processNull(getStringByByte(contents,pos,18)).trim() + "'',");//证件号码
				pos = pos + 18;
				sb.append("''" + Tools.processNull(getStringByByte(contents,pos,200)).trim() + "'',");//失败原因
				pos = pos + 200;
				sb.append("''" + Tools.processNull(getStringByByte(contents,pos,30)).trim().replaceAll("F","") + "'',");//保留字段
				sb.append("''" + fileName + "'',");//文件名称
				sb.append("" + j + ",");//行号
				sb.append("" + totRows + ",");//总条数
				sb.append("''1'',''");//状态
				sb.append(batchId + "'',sysdate,''" + bankId + "''");
				sb.append(")',");
				if((j + 1) % 500 == 0){
					publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + sb.substring(0,sb.length() - 1) + "))");
					sb = new StringBuffer();
				}
			}
			if(totRows != tempRows){
				throw new CommonException("文件" + fileName + ",内容详细条数和头部设置的总条数不一致！");
			}
			if(!Tools.processNull(sb.toString()).equals("")){
				publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + sb.substring(0,sb.length()-1) + "))");
			}
			//调取过程
			StringBuffer execsql = new StringBuffer();
			execsql.append(batchId + "|");
			List inParameters = new ArrayList();
			List outParameters = new ArrayList();
			inParameters.add(execsql.toString());
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List outList = publicDao.callProc("pk_card_apply_issuse.p_apply_bank_sh",inParameters,outParameters);
			if(outList == null || outList.size() <= 0){
				throw new CommonException("银行返回文件入库调取过程出现错误！");
			}
			if(Integer.valueOf(outList.get(0).toString()) != 0){
				throw new CommonException(outList.get(1).toString());
			}
			String tempHisFilePath = "";
			if(Tools.processNull(ftpOptions.get("host_history_path")).endsWith("/")){
				tempHisFilePath = ftpOptions.get("host_history_path");
			}else{
				tempHisFilePath = ftpOptions.get("host_history_path") + "/";
			}
			if(!ftpClient.rename(fileName,tempHisFilePath + fileName)){
				throw new CommonException("将文件" + fileName + "移动到历史目录时出现错误！");
			}
			logger.error("文件" + fileName + "处理成功");
			baseBankFile.setDealState("0");//文件处理状态
			publicDao.update(baseBankFile);
			TrServRec rec =  new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealCode(actionLog.getDealCode());
			rec.setBizTime(actionLog.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(actionLog.getBrchId());
			rec.setUserId(actionLog.getUserId());
			rec.setOrgId(actionLog.getOrgId());
			publicDao.save(rec);
			System.gc();
		}catch(Exception e) {
			logger.error("文件" + fileName + "处理失败," + e.getMessage());
			throw new CommonException("导入银行文件出错" + e.getMessage());
		}finally{
			logger.error("结束处理文件" + fileName);
		}
		return null;
	}
	public  String getStringByByte(byte[] string,int pos,int len) throws Exception{
		return new String(string,pos,len,"GBK");
	}
	/**
	 * 导出制卡文件数据
	 * @param batchId
	 * @param vendorId
	 * @param user
	 * @param log
	 * @return
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public TrServRec saveExportMadeCardData(String batchId,String vendorId,Users user,SysActionLog log) throws CommonException{
		DefaultFTPClient ftpClient = null;
		ZipArchiveOutputStream zip = null;
		OutputStream os = null;
		String ftpPatch = "";
		try{
		    //删除一个任务银行审核都不通过的空任务
            this.publicDao.doSql("delete from card_apply_task s where s.task_id in (select a.task_id from (" +
            "select t.task_id,t.task_sum,(select count(1) from card_apply c where c.task_id = t.task_id and c.apply_state = '15') notapplynum " +
            "from card_apply_task t where t.task_state = '04' ) a where a.task_sum = a.notapplynum)"
            );
            this.publicDao.doSql("commit");
			//1.基本条件判断
			if(Tools.processNull(batchId).equals("")){
				throw new CommonException("批次号不能为空！");
			}
			if(Tools.processNull(vendorId).equals("")){
				throw new CommonException("卡厂编号不能为空！");
			}
			BaseVendor vendor = (BaseVendor) this.findOnlyRowByHql("from BaseVendor where vendorId = '" + vendorId + "'");
			if(vendor == null){
				throw new CommonException("根据卡商编号" + vendorId + "找不到卡商信息！");
			}
			log.setDealCode(DealCode.MAKE_CARD_TASK_EXPORT);
			log.setMessage("制卡任务导出, 批次号：" + batchId);
			publicDao.save(log);
			//2.FTP连接判断
			logger.error(Tools.tensileString("-",50,true,"-"));
			logger.error("开始导出卡厂制卡文件,批次:" + batchId + ",卡厂编号:" + vendorId + ",卡厂名称:" + vendor.getVendorName());
			logger.error("检查FTP配置信息");
			Map<String,String>  ftpOptions = this.initFtpOptions("make_card_task_to_vendor_admin");
			ftpClient = this.checkFtp(ftpOptions);
			if(Tools.processNull(ftpOptions.get("host_upload_path")).equals("")){
				throw new CommonException("获取ftp配置出错，ftp制卡数据存放路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_upload_path:" + ftpOptions.get("host_upload_path"));
			}
			ftpPatch = "/vendor/" + vendorId + "/" + ftpOptions.get("host_upload_path");
			if(!(ftpClient.changeWorkingDirectory(ftpPatch))){
				throw new CommonException("FTP切换到目录" + ftpPatch + "失败！请检查FTP路径设置信息！");
			}else{
				logger.error("FTP目录切换正常");
			}
			logger.error("当前工作目录" + ftpClient.printWorkingDirectory());
			logger.error("FTP检查完毕");
			//3.导出批次任务信息判断
			BigDecimal sucTaskNums = (BigDecimal) this.findOnlyFieldBySql("select count(1) from card_apply_task t where t.make_batch_id = '" + batchId + "'");
			if(sucTaskNums.intValue() < 1){
				throw new CommonException("根据批次编号" + batchId + "找不到任务信息！");
			}
			List<?> allTasks = this.findByHql("from CardApplyTask where makeBatchId = '" + batchId + "' and taskState = '" + Constants.TASK_STATE_YHYSH + "' order by brchId");
			if(allTasks == null || allTasks.size() <= 0){
				throw new CommonException("根据批号编号" + batchId + "未找到符合导出条件的任务信息！");
			}
			if(sucTaskNums.intValue() != allTasks.size()){
				throw new CommonException("批次编号为" + batchId + "的批次下，有" + (sucTaskNums.intValue() - allTasks.size()) + "个任务信息不是【银行已审核】状态！");
			}
			//卡类型CARD_TYPE和制卡方式IS_URGENT判断
			List<?> cardTypeAndIsUrgent = this.findBySql("select card_type,is_urgent from card_apply_task where make_batch_id = '" + batchId + "' group by card_type,is_urgent");
			if(cardTypeAndIsUrgent == null || cardTypeAndIsUrgent.size() <= 0){
				throw new CommonException("批号编号" + batchId + "的任务信息中找不到卡类型和制卡方式信息！");
			}
			if(cardTypeAndIsUrgent.size() > 1){
				throw new CommonException("批号编号" + batchId + "的任务信息中含有多种卡类型或多种制卡方式信息！");
			}
			String cardType = (String) ((Object[])cardTypeAndIsUrgent.get(0))[0];
			if(Tools.processNull(cardType).trim().equals("")){
				throw new CommonException("批号编号" + batchId + "的任务信息中找不到卡类型信息！");
			}
			String isUrgent = (String) ((Object[])cardTypeAndIsUrgent.get(0))[1];
			if(Tools.processNull(isUrgent).trim().equals("")){
				throw new CommonException("批号编号" + batchId + "的任务信息中找不到制卡方式信息！");
			}
			if(!Tools.processNull(isUrgent).equals(vendor.getMakeWay())){
				throw new CommonException("选择的卡厂的制卡方式和任务的制卡方式不一致！");
			}
			//任务所属区REGION_ID域判断
			List<?> regionIds = this.findBySql("select nvl(med_whole_no,'') from card_apply_task where make_batch_id = '" + batchId + "' group by med_whole_no");
			if(regionIds == null || regionIds.size() <= 0){
				throw new CommonException("批号编号" + batchId + "的任务信息中找不到统筹区域编号信息！");
			}
			if(regionIds.size() > 1){
				throw new CommonException("批号编号" + batchId + "的任务信息中包含有多个统筹区域的任务信息！");
			}
			BaseCity city = null;
			if(!Tools.processNull(regionIds.get(0)).equals("")){
				city = (BaseCity) this.findOnlyRowByHql("from BaseCity where cityId = '" + Tools.processNull(regionIds.get(0).toString()) + "'");
				if(city == null){
					throw new CommonException("批号编号" + batchId + "的任务信息中统筹区域编号不正确！");
				}
			}else{
				throw new CommonException("批号编号" + batchId + "的任务信息中找不到统筹区域编号信息！");
			}
			//银行信息
            List<?> bankIds = this.findBySql("select nvl(bank_id,'') from card_apply_task where make_batch_id = '" + batchId + "' group by bank_id");
            if(bankIds == null || bankIds.size() <= 0){
                throw new CommonException("批号编号" + batchId + "的任务信息中找不到银行编号信息！");
            }
            if(bankIds.size() > 1){
                throw new CommonException("批号编号" + batchId + "的任务信息中包含有多个银行的任务信息！");
            }
            BaseBank bank = null;
            if(!Tools.processNull(bankIds.get(0)).equals("")){
                bank = (BaseBank) this.findOnlyRowByHql("from BaseBank where bankId = '" + Tools.processNull(bankIds.get(0)) + "'");
                if(bank == null){
                    throw new CommonException("批号编号" + batchId + "的任务信息中银行编号不正确！");
                }
            }else{
                throw new CommonException("批号编号" + batchId + "的任务信息中找不到银行编号信息！");
            }
            //领卡网点
            SysBranch recvBrch = null;
            List<?> recvBrchids = this.findBySql("select nvl(brch_id,'') from card_apply_task where make_batch_id = '" + batchId + "' group by brch_id");
            if(recvBrchids != null && recvBrchids.size() == 1){
                if(!Tools.processNull(recvBrchids.get(0)).equals("")){
                    recvBrch = (SysBranch) this.findOnlyRowByHql("from SysBranch where brchId = '" + Tools.processNull(recvBrchids.get(0)) + "'");
                }
            }
			//4.生成文件名称
			String fileName = this.getCodeNameBySYS_CODE("CARD_TYPE",cardType) + "_" + batchId + "_" + DateUtil.formatDate(log.getDealTime(),"yyyyMMddHHmmss") + "_";
			fileName = fileName + vendor.getVendorName() + "_S_" + this.getCodeNameBySYS_CODE("URGENT",isUrgent) + "_" + city.getCityName() + "_" + bank.getBankName();
			if(recvBrch != null && !Tools.processNull(recvBrch.getFullName()).equals("")){
                fileName = fileName + "_" + Tools.processNull(recvBrch.getFullName());
            }
            fileName = fileName + ".txt";
            StringBuffer photoSql = new StringBuffer();
			photoSql.append("SELECT t.photofilename,c.photo ");
			photoSql.append("FROM card_task_list t,card_apply b,base_photo c ");
			photoSql.append("WHERE t.task_id = b.task_id AND t.apply_id = b.apply_id ");
			photoSql.append("AND t.customer_id = b.customer_id AND t.card_no = b.card_no ");
			photoSql.append("AND b.customer_id = c.customer_id AND c.photo_state = '0' AND lengthb(c.photo) > 0 ");
			photoSql.append("and b.apply_state = '" + Constants.APPLY_STATE_ZKZ + "' ");
			StringBuffer taskHeader = new StringBuffer();
			taskHeader.append("task_id|card_type|bank_id|recordcount|taskaddr|serid|sername|companyid|company|region_name|street|community|" + Constants.NEWLINE);
			taskHeader.append("task_id|data_seq|client_id|department|classid|photofilename|bar_code|");
			taskHeader.append("card_no|struct_main_type|struct_child_type|validitydate|useflag|bursestartdate|bursevaliddate|monthstartdate|monthvaliddate|");
			taskHeader.append("month_type|bursebalance|monthbalance|df04ef10b0|cert_typed|");//互联互通标志| 证件类型
			taskHeader.append("card_type|version|org_code|cardissuedate|ssseef0506|ssseef0507|cert_no|name|sex|nation|birthplace|birthday|ssseef0701|reside_type|");
			taskHeader.append("reside_addr|letter_addr|post_code|mobile_no|");
			taskHeader.append("df01ef0729|education|marr_state|");
			taskHeader.append("df01ef092e|df01ef0930|df01ef0931|df01ef0932|");//DF01EF09单位信息文件
			taskHeader.append("df01ef0a37|df01ef0a38|df01ef0a39|");//DF01EF0A工资信息文件
			taskHeader.append("df02ef055701|df02ef055801|df02ef055901|df02ef055702|df02ef055802|df02ef055902|df02ef0542|df02ef055a01|df02ef055b01|");
			taskHeader.append("df02ef055c01|df02ef055d01|df02ef055a02|df02ef055b02|df02ef055c02|df02ef055d02|");//DF02EF05专业技能性能基本文件
			taskHeader.append("df02ef064b|df02ef064c|df02ef064d|df02ef064f|df02ef0650|df02ef063a|");//DF02EF06就失业基本文件
			taskHeader.append("df02ef070101|df02ef070102|df02ef070103|df02ef070104|df02ef070201|df02ef070202|df02ef070203|df02ef070204|df02ef070301|df02ef070302|");
			taskHeader.append("df02ef070303|df02ef070304|df02ef070401|df02ef070402|df02ef070403|df02ef070404|");//DF02EF07就业信息文件
			taskHeader.append("df02ef0852|df02ef0853|df02ef0854|");//DF02EF08外出就业信息文件
			taskHeader.append("df02ef0955|df02ef0956|df02ef0996|df02ef0997|");//DF02EF09外来就业信息
			taskHeader.append("df03ef0560|df03ef0598|df03ef0561|df03ef0562|df03ef0563|df03ef0564|df03ef0565|df03ef0566|");//DF03EF05失业保险信息文件
			taskHeader.append("df03ef0667|df03ef0668|df03ef0669|df03ef066b|");//DF03EF06丧失劳动力鉴定信息文件
			taskHeader.append("df03ef076c|df03ef076d|df03ef076e|df03ef076f|df03ef0770|df03ef0771|df03ef0772|df03ef0773|");
			taskHeader.append("df04ef0580|df04ef0581|df04ef0583|df04ef0584|df04ef0586|");
			taskHeader.append("df04ef0587|df04ef0589|df04ef058a|df04ef058b|df04ef058c|df04ef058f|df04ef0690|df04ef0692|df04ef0693|df04ef0ca0|" + Constants.NEWLINE);
			StringBuffer execSql = new StringBuffer();
			//任务明细头
			execSql.append("t.task_id,t.data_seq,t.customer_id,t.department,t.classid,t.cert_no || '.jpg' photofilename,t.bar_code,");
			//非接触卡信息
			execSql.append("t.card_no,t.struct_main_type,nvl(t.struct_child_type,'00') struct_child_type,t.cardissuedate,t.useflag,t.bursestartdate,t.bursevaliddate,t.monthstartdate,t.monthvaliddate,");
			execSql.append("t.month_type,t.bursebalance,t.monthbalance,t.hlht_flag,t.cert_typed,");
			//接触卡信息
			execSql.append("'3' card_type,t.version,t.init_org_id,t.touch_startdate,t.touch_validdate,t.sub_card_no,t.cert_no,t.name,t.sex,");
			execSql.append("t.nation,t.birthplace,t.birthday,'' ssseef0701,t.reside_type,t.reside_addr,t.letter_addr,t.post_code,t.mobile_no,");
			//DF01EF07个人状况信息文件, DF01EF08婚姻状况信息文件
			execSql.append("t.df01ef0729,t.education,'' marr_state,");
			//DF01EF09单位信息文件
			execSql.append("'' df01ef092e,'' df01ef0930,'' df01ef0931,'' df01ef0932,");
			//DF01EF0A工资信息文件
			execSql.append("'' df01ef0a37,'' df01ef0a38,'' df01ef0a39,");
			//DF02EF05专业技能性能基本文件
			execSql.append("'' df02ef055701,'' df02ef055801,'' df02ef055901,'' df02ef055702,'' df02ef055802,'' df02ef055902,'' df02ef0542,");
			execSql.append("'' df02ef055a01,'' df02ef055b01,'' df02ef055c01,'' df02ef055d01,'' df02ef055a02,'' df02ef055b02,'' df02ef055c02,'' df02ef055d02,");
			//DF02EF06就失业基本文件
			execSql.append("'' df02ef064b,'' df02ef064c,'' df02ef064d,'' df02ef064f,'' df02ef0650,'' df02ef063a,");
			//DF02EF07就业信息文件
			execSql.append("'' df02ef070101,'' df02ef070102,'' df02ef070103,'' df02ef070104,'' df02ef070201,'' df02ef070202,'' df02ef070203,'' df02ef070204,");
			execSql.append("'' df02ef070301,'' df02ef070302,'' df02ef070303,'' df02ef070304,'' df02ef070401,'' df02ef070402,'' df02ef070403,'' df02ef070404,");
			//DF02EF08外出就业信息文件
			execSql.append("'' df02ef0852,'' df02ef0853,'' df02ef0854,");
			//DF02EF09外来就业信息文件
			execSql.append("'' df02ef0955,'' df02ef0956,'' df02ef0996,'' df02ef0997,");
			//DF03EF05失业保险信息文件
			execSql.append("'' df03ef0560,'' df03ef0598,'' df03ef0561,'' df03ef0562,'' df03ef0563,'' df03ef0564,'' df03ef0565,'' df03ef0566,");
			//DF03EF06丧失劳动力鉴定信息文件
			execSql.append("'' df03ef0667,'' df03ef0668,'' df03ef0669,'' df03ef066b,");
			//DF03EF07养老保险信息文件
			execSql.append("'' df03ef076c,'' df03ef076d,'' df03ef076e,'' df03ef076f ,'' df03ef0770 ,'' df03ef0771 ,'' df03ef0772,'' df03ef0773,");
			//DF04EF05医疗保险基本信息文件
			execSql.append("'' df04ef0580,'' df04ef0581,'' df04ef0583,'' df04ef0584,'' df04ef0586,'' df04ef0587,'' df04ef0589,'' df04ef058a,'' df04ef058b,'' df04ef058c,'' df04ef058f,");
			execSql.append("'' df04ef0690,'' df04ef0692,'' df04ef0693,b.med_whole_no df04ef0ca0 ");
			execSql.append("from card_task_list t,card_apply b,base_personal p ");
			execSql.append("WHERE t.apply_id = b.apply_id AND t.customer_id = b.customer_id and b.customer_id = p.customer_id ");
			//execSql.append("and t.cert_no = r.cert_no and t.name = r.name and");
			execSql.append("and b.apply_state = '" + Constants.APPLY_STATE_YHSHTG + "' ");
			StringBuffer details = new StringBuffer();
			for(int i = 0;i < allTasks.size(); i++){
				CardApplyTask tempTask = (CardApplyTask) allTasks.get(i);
				logger.error("开始写入第" + (i + 1) + "个任务,任务编号:" + tempTask.getTaskId() + ",任务名称:" + tempTask.getTaskName());
				details.append(Tools.tensileString("-",10,true,"-") + Constants.NEWLINE);//任务分隔符
				details.append(Tools.processNull(tempTask.getTaskId()) + "|");//任务编号
				details.append(Tools.processNull(tempTask.getCardType()) + "|");//卡类型
				details.append(Tools.processNull(tempTask.getBankId()) + "|");//银行编号
				details.append(Tools.processNull(tempTask.getYhNum()) + "|");//记录数量
				details.append(Tools.processNull(tempTask.getTaskName()) + "|");//任务地址
				details.append(Tools.processNull(tempTask.getBrchId()) + "|");//网点编号
				if(!Tools.processNull(tempTask.getBrchId()).equals("")){
					details.append(Tools.processNull((this.findOnlyFieldBySql("select full_name from sys_branch where brch_id = '" + tempTask.getBrchId() + "'"))) + "|");//网点名称
				}else{
					details.append("|");
				}
				details.append(Tools.processNull(tempTask.getCorpId()) + "|");
				if(!Tools.processNull(tempTask.getCorpId()).equals("")){
					details.append(Tools.processNull(this.findOnlyFieldBySql("select corp_name from base_corp where customer_id = '" + tempTask.getCorpId() + "'")) + "|");
				}else{
					details.append("|");
				}
				if(!Tools.processNull(tempTask.getRegionId()).equals("")){
					//details.append(Tools.processNull(tempTask.getRegionId()) + "|");
					details.append(Tools.processNull(this.findOnlyFieldBySql("select region_name from base_region where region_id = '" + tempTask.getRegionId() + "'")) + "|");
				}else{
					//details.append("|");
					details.append("|");
				}
				if(!Tools.processNull(tempTask.getTownId()).equals("")){
					//details.append(Tools.processNull(tempTask.getTownId()) + "|");
					details.append(Tools.processNull(this.findOnlyFieldBySql("select town_name from base_town where town_id = '" + tempTask.getTownId() + "'")) + "|");
				}else{
					//details.append("|");
					details.append("|");
				}
				if(!Tools.processNull(tempTask.getCommId()).equals("")){
					//details.append(Tools.processNull(tempTask.getCommId()) + "|");
					details.append(Tools.processNull(this.findOnlyFieldBySql("select comm_name from base_comm where comm_id = '" + tempTask.getCommId() + "'")) + "|");
				}else{
					//details.append("|");
					details.append("|");
				}
				details.append(Constants.NEWLINE);
				List<?> tempDetails = this.findBySql("select " + execSql.toString() + " and t.task_id = '" + tempTask.getTaskId() + "'");
				if(tempDetails == null || tempDetails.size() <= 0){
					throw new CommonException("批号编号" + batchId + "中，任务编号为" + tempTask.getTaskId() + "的任务明细不存在，或是申领状态不正常！");
				}
				if(!Tools.processNull(tempTask.getYhNum() + "").equals(tempDetails.size() + "")){
					throw new CommonException("批号编号" + batchId + "中，任务编号为" + tempTask.getTaskId() + "的任务明细数量和任务中的数量不一致！");
				}
				for (int j = 0; j < tempDetails.size(); j++) {
					Object[] oneRow = (Object[]) tempDetails.get(j);
					for (Object object : oneRow) {
						details.append(Tools.processNull(object).toString() + "|");
					}
					details.append(Constants.NEWLINE);
				}
				int upcount = publicDao.doSql("update card_apply_task t set t.task_state = '" + Constants.TASK_STATE_ZKZ + "' where t.task_id = '" + tempTask.getTaskId() + "' and " +
					"t.task_state = '" + Constants.TASK_STATE_YHYSH + "'"
				);
				if(upcount != 1){
					throw new CommonException("更新批号编号" + batchId + "中，任务编号为" + tempTask.getTaskId() + "的任务状态为【制卡中】时出现错误！");
				}
				upcount = publicDao.doSql("update card_apply t set t.apply_state = '" + Constants.APPLY_STATE_ZKZ + "' where t.task_id = '" +
				tempTask.getTaskId() + "' and t.apply_state = '" + Constants.APPLY_STATE_YHSHTG + "'");
				if(upcount != tempTask.getYhNum()){
					throw new CommonException("更新批号编号" + batchId + "中，任务编号为" + tempTask.getTaskId() + "的申领状态为【制卡中】时出现错误，更新数量和银行审核数量不一致！");
				}
				logger.error("任务" + tempTask.getTaskId() + "写入成功");
			}
			if(!(ftpClient.isConnected() && ftpClient.isAvailable())){
				ftpClient = new DefaultFTPClient();
				if(!ftpClient.toConnect(ftpOptions.get("url"),Integer.valueOf(ftpOptions.get("port")))){
					throw new CommonException("FTP连接失败！");
				}
				if(!ftpClient.toLogin(ftpOptions.get("userName"),ftpOptions.get("pwd"))){
					throw new CommonException("FTP登录失败！");
				}
				ftpClient.setControlEncoding("GBK");
				ftpClient.setFileTransferMode(DefaultFTPClient.STREAM_TRANSFER_MODE);
				ftpClient.setFileType(DefaultFTPClient.BINARY_FILE_TYPE);
				if(!ftpClient.changeWorkingDirectory(ftpPatch)){
					throw new CommonException("FTP切换到目录" + ftpPatch + "失败！");
				}
			}
			logger.error("开始上传文件" + fileName +  "...");
			ftpClient.setFileType(FTP.BINARY_FILE_TYPE);
			os = ftpClient.storeFileStream(new String(fileName.replace("txt","zip").getBytes()));
			zip = new ZipArchiveOutputStream(os);
			zip.setEncoding("GBK");
			zip.setComment("卡厂制卡文件_" + fileName);
			ByteArrayInputStream  fileConts = new ByteArrayInputStream(taskHeader.append(details).toString().getBytes("GBK"));
			ZipArchiveEntry tarFile = new ZipArchiveEntry(fileName);
			zip.putArchiveEntry(tarFile);
			byte[] buf = new byte[1024 * 1024];
			int pos = 0;
			while((pos = fileConts.read(buf)) != -1) {
				zip.write(buf,0,pos);					
			}
			zip.closeArchiveEntry();
			logger.error("开始写入照片...");
			for(int i = 0; i < allTasks.size(); i++) {
				CardApplyTask tempTask = (CardApplyTask) allTasks.get(i);
				if(Tools.processNull(tempTask.getIsPhoto()).equals(Constants.YES_NO_NO)){
					logger.error("批号编号" + batchId + "中，任务编号为" + tempTask.getTaskId() + "的任务是否导出照片标志设置为无需导出照片！");
					continue;
				}
				logger.error("开始写入任务编号为" + tempTask.getTaskId() + ",任务名称:" + tempTask.getTaskName() + "的照片,数量" + tempTask.getTaskSum() + " ...");
				List tempOneRow = findBySql(photoSql.toString() + " and t.task_id = '" + tempTask.getTaskId() + "'");
				if(tempOneRow.size() != tempTask.getYhNum()){
					throw new CommonException("批号编号" + batchId + "中，任务编号为" + tempTask.getTaskId() + "的任务的照片数量和任务明细数量不一致！");
				}
				for (int j = 0; j < tempOneRow.size(); j++) {
					Object[] o = (Object[]) tempOneRow.get(j);
					ZipArchiveEntry tempPhoto = new ZipArchiveEntry(Tools.processNull(o[0]));
					zip.putArchiveEntry(tempPhoto);
					zip.write(FileIO.InputStreamToByte(((Blob)o[1]).getBinaryStream()));
					zip.closeArchiveEntry();
				}
				logger.error("写入成功");
				os.flush();
				tempOneRow = null;
			}
			zip.finish();
			zip.flush();
			zip.close();
			zip = null;
			os.flush();
			os.close();
			os = null;
			if(!(FTPReply.isPositiveCompletion(ftpClient.getReply()))){
				throw new CommonException("文件上传失败，请检查FTP设置信息！");
			}
			logger.error("文件" + fileName + "上传成功！");
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setBizTime(log.getDealTime());
			rec.setBrchId(log.getBrchId());
			rec.setUserId(log.getUserId());
			rec.setOrgId(log.getOrgId());
			rec.setClrDate(getClrDate());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setNote(log.getMessage());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			logger.error(e.getMessage());
			throw new CommonException(e.getMessage());
		}finally{
			logger.error("结束批次" + batchId + "导出");
			try{
				if(zip != null){
					zip.close();
					zip = null;
				}
				if(os != null){
					os.close();
					os = null;
				}
				if(ftpClient != null && ftpClient.isAvailable()){
					ftpClient.logout();
					ftpClient.disconnect();
				}
			}catch(Exception e1){
				
			}
		}
	}
	/**
	 * 导出制卡文件数据
	 * @param taskIds 逗号分隔的字符串 1,2,3,4,5,6
	 * @param vendorId
	 * @param user
	 * @param log
	 * @return
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public TrServRec saveExportMadeCardDataFromTask(String taskIds,String vendorId,Users user,SysActionLog log) throws CommonException{
		DefaultFTPClient ftpClient = null;
		ZipArchiveOutputStream zip = null;
		OutputStream os = null;
		String taskIdsString = "";
		try{
			//1.基本条件判断
			String ftpPatch = "";
			String[] taskIdArr = null;
			if(Tools.processNull(taskIds).equals("")){
				throw new CommonException("任务编号不能为空，请勾选需要导出的任务信息！");
			}
			taskIdArr = Tools.processNull(taskIds).split("\\|");
			if(taskIdArr.length <= 0){
				throw new CommonException("请勾选需要导出的任务信息！");
			}else{
				taskIdsString = Tools.getConcatStrFromArray(taskIdArr,"'",",");
			}
			if(Tools.processNull(vendorId).equals("")){
				throw new CommonException("卡厂编号不能为空！");
			}
			BaseVendor vendor = (BaseVendor) this.findOnlyRowByHql("from BaseVendor where vendorId = '" + vendorId + "'");
			if(vendor == null){
				throw new CommonException("根据卡商编号" + vendorId + "找不到卡商信息！");
			}
			log.setDealCode(DealCode.MAKE_CARD_TASK_EXPORT);
			log.setInOutData(log.getInOutData().length()>500?log.getInOutData().substring(0, 500) + "....":log.getInOutData());
			log.setMessage("制卡任务导出, 任务编号：" + (taskIdsString.length()>500?taskIdsString.substring(0, 500) + "....":taskIdsString));
			publicDao.save(log);
			//2.FTP连接判断
			logger.error(Tools.tensileString("-",50,true,"-"));
			logger.error("开始导出卡厂制卡文件,任务编号:" + taskIds + ",卡厂编号:" + vendorId + ",卡厂名称:" + vendor.getVendorName());
			logger.error("检查FTP配置信息");
            Map<String,String>  ftpOptions = this.initFtpOptions("make_card_task_to_vendor_admin");
            ftpClient = this.checkFtp(ftpOptions);
            ftpClient.setControlEncoding("GBK");
            if(Tools.processNull(ftpOptions.get("host_upload_path")).equals("")){
                throw new CommonException("获取ftp配置出错，ftp制卡数据存放路径未配置，请联系系统管理员！");
            }else{
                logger.error("host_upload_path:" + ftpOptions.get("host_upload_path"));
            }
            ftpPatch = "/vendor/" + vendorId + "/" + ftpOptions.get("host_upload_path");
            if(!(ftpClient.changeWorkingDirectory(ftpPatch))){
                throw new CommonException("FTP切换到目录" + ftpPatch + "失败！请检查FTP路径设置信息！");
            }else{
                logger.error("FTP目录切换正常");
            }
            logger.error("当前工作目录" + ftpClient.printWorkingDirectory());
            logger.error("FTP检查完毕");
			//3.导出批次任务信息判断
			CardTaskBatch taskBatch = new CardTaskBatch();
			taskBatch.setBatchId(this.getSequenceByName("seq_cm_card_task_batch"));
			taskBatch.setSendOrgId(user.getOrgId());
			taskBatch.setSendBrchId(user.getBrchId());
			taskBatch.setSendUserId(user.getUserId());
			taskBatch.setSendDate(log.getDealTime());
			taskBatch.setVendorId(vendorId);
			taskBatch.setMakeWay(vendor.getMakeWay());
			BigDecimal sucTaskNums = (BigDecimal) this.findOnlyFieldBySql("select count(1) from card_apply_task t where t.task_id in (" + taskIdsString + ")");
			if(sucTaskNums.intValue() < 1){
				throw new CommonException("根据勾选的制卡任务找不到任务信息！");
			}
			List<?> allTasks = this.findByHql("from CardApplyTask where task_id in (" + taskIdsString + ") and taskState = '" + Constants.TASK_STATE_YSC + "'");
			if(allTasks == null || allTasks.size() <= 0){
				throw new CommonException("勾选的制卡任务信息，任务状态不为【任务已生成】！");
			}
			if(taskIdArr.length != allTasks.size()){
				throw new CommonException("勾选的制卡任务中含有" + (taskIdArr.length - allTasks.size()) + "个任务的任务状态不是【任务已生成】！");
			}
			//卡类型CARD_TYPE和制卡方式IS_URGENT判断
			List<?> cardTypeAndIsUrgent = this.findBySql("select card_type,is_urgent from card_apply_task where task_id in (" + taskIdsString + ") group by card_type,is_urgent");
			if(cardTypeAndIsUrgent == null || cardTypeAndIsUrgent.size() <= 0){
				throw new CommonException("根据勾选的制卡任务信息找不到卡类型和制卡方式信息！");
			}
			if(cardTypeAndIsUrgent.size() > 1){
				throw new CommonException("勾选的制卡任务信息中含有多种卡类型或多种制卡方式！");
			}
			String cardType = (String) ((Object[])cardTypeAndIsUrgent.get(0))[0];
			if(Tools.processNull(cardType).trim().equals("")){
				throw new CommonException("勾选的制卡任务信息中找不到卡类型信息！");
			}else{
				taskBatch.setCardType(cardType);
			}
			String isUrgent = (String) ((Object[])cardTypeAndIsUrgent.get(0))[1];
			if(Tools.processNull(isUrgent).trim().equals("")){
				throw new CommonException("勾选的制卡任务信息中找不到制卡方式信息！");
			}
			if(!Tools.processNull(isUrgent).equals(vendor.getMakeWay())){
				throw new CommonException("选择的卡厂的制卡方式和任务的制卡方式不一致！");
			}
			List<?> regionIds = this.findBySql("select nvl(med_whole_no,'') from card_apply_task where task_id in (" + taskIdsString + ") group by med_whole_no");
			if(regionIds == null || regionIds.size() <= 0){
				throw new CommonException("勾选的制卡任务信息中找不到统筹区域编号信息！");
			}
			if(regionIds.size() > 1){
				throw new CommonException("勾选的制卡任务信息中包含有多个统筹区域的任务信息！");
			}
			BaseCity city = null;
			if(!Tools.processNull(regionIds.get(0)).equals("")){
				city = (BaseCity) this.findOnlyRowByHql("from BaseCity where cityId = '" + Tools.processNull(regionIds.get(0).toString()) + "'");
				if(city == null){
					throw new CommonException("勾选的制卡任务信息中统筹区域编号不正确！");
				}
			}else{
				throw new CommonException("勾选的制卡任务信息中找不到统筹区域编号信息！");
			}
			this.publicDao.save(taskBatch);
			//4.生成文件名称
			String fileName = this.getCodeNameBySYS_CODE("CARD_TYPE",cardType) + "_" + taskBatch.getBatchId() + "_" + DateUtil.formatDate(log.getDealTime(),"yyyyMMddHHmmss") + "_";
			fileName = fileName + vendor.getVendorName() + "_S_" + this.getCodeNameBySYS_CODE("URGENT",isUrgent) + "_" + city.getCityName() + ".txt";
			StringBuffer photoSql = new StringBuffer();
			photoSql.append("SELECT T.PHOTOFILENAME,C.PHOTO ");
			photoSql.append("FROM CARD_TASK_LIST T,CARD_APPLY B,BASE_PHOTO C ");
			photoSql.append("WHERE T.TASK_ID = B.TASK_ID AND T.APPLY_ID = B.APPLY_ID ");
			photoSql.append("AND T.CUSTOMER_ID = B.CUSTOMER_ID ");
			photoSql.append("AND B.CUSTOMER_ID = C.CUSTOMER_ID AND C.PHOTO_STATE = '0' AND LENGTHB(C.PHOTO) > 0 ");
			photoSql.append("AND B.APPLY_STATE = '" + Constants.APPLY_STATE_ZKZ + "' ");
			StringBuffer taskHeader = new StringBuffer();
			taskHeader.append("task_id|card_type|bank_id|recordcount|taskaddr|serid|sername|companyid|company|region_name|street|community|" + Constants.NEWLINE);
			taskHeader.append("task_id|data_seq|client_id|department|classid|photofilename|bar_code|");
			taskHeader.append("card_no|struct_main_type|struct_child_type|validitydate|useflag|bursestartdate|bursevaliddate|monthstartdate|monthvaliddate|");
			taskHeader.append("month_type|bursebalance|monthbalance|df04ef10b0|cert_typed|");//互联互通标志| 证件类型
			taskHeader.append("card_type|version|org_code|cardissuedate|ssseef0506|ssseef0507|cert_no|name|sex|nation|birthplace|birthday|ssseef0701|reside_type|");
			taskHeader.append("reside_addr|letter_addr|post_code|mobile_no|");
			taskHeader.append("df01ef0729|education|marr_state|");
			taskHeader.append("df01ef092e|df01ef0930|df01ef0931|df01ef0932|");//DF01EF09单位信息文件
			taskHeader.append("df01ef0a37|df01ef0a38|df01ef0a39|");//DF01EF0A工资信息文件
			taskHeader.append("df02ef055701|df02ef055801|df02ef055901|df02ef055702|df02ef055802|df02ef055902|df02ef0542|df02ef055a01|df02ef055b01|");
			taskHeader.append("df02ef055c01|df02ef055d01|df02ef055a02|df02ef055b02|df02ef055c02|df02ef055d02|");//DF02EF05专业技能性能基本文件
			taskHeader.append("df02ef064b|df02ef064c|df02ef064d|df02ef064f|df02ef0650|df02ef063a|");//DF02EF06就失业基本文件
			taskHeader.append("df02ef070101|df02ef070102|df02ef070103|df02ef070104|df02ef070201|df02ef070202|df02ef070203|df02ef070204|df02ef070301|df02ef070302|");
			taskHeader.append("df02ef070303|df02ef070304|df02ef070401|df02ef070402|df02ef070403|df02ef070404|");//DF02EF07就业信息文件
			taskHeader.append("df02ef0852|df02ef0853|df02ef0854|");//DF02EF08外出就业信息文件
			taskHeader.append("df02ef0955|df02ef0956|df02ef0996|df02ef0997|");//DF02EF09外来就业信息
			taskHeader.append("df03ef0560|df03ef0598|df03ef0561|df03ef0562|df03ef0563|df03ef0564|df03ef0565|df03ef0566|");//DF03EF05失业保险信息文件
			taskHeader.append("df03ef0667|df03ef0668|df03ef0669|df03ef066b|");//DF03EF06丧失劳动力鉴定信息文件
			taskHeader.append("df03ef076c|df03ef076d|df03ef076e|df03ef076f|df03ef0770|df03ef0771|df03ef0772|df03ef0773|");
			taskHeader.append("df04ef0580|df04ef0581|df04ef0583|df04ef0584|df04ef0586|");
			taskHeader.append("df04ef0587|df04ef0589|df04ef058a|df04ef058b|df04ef058c|df04ef058f|df04ef0690|df04ef0692|df04ef0693|df04ef0ca0|" + Constants.NEWLINE);
			StringBuffer execSql = new StringBuffer();
			//任务明细头
			execSql.append("t.task_id,t.data_seq,t.customer_id,t.department,t.classid,t.cert_no || '.jpg' photofilename,t.bar_code,");
			//非接触卡信息
			execSql.append("t.card_no,t.struct_main_type,nvl(t.struct_child_type,'00') struct_child_type,t.cardissuedate,t.useflag,t.bursestartdate,t.bursevaliddate,t.monthstartdate,t.monthvaliddate,");
			execSql.append("t.month_type,t.bursebalance,t.monthbalance,t.hlht_flag,t.cert_typed,");
			//接触卡信息
			execSql.append("'3' card_type,t.version,t.init_org_id,t.touch_startdate,t.touch_validdate,t.sub_card_no,t.cert_no,t.name,t.sex,");
			execSql.append("t.nation,t.birthplace,t.birthday,'' ssseef0701,t.reside_type,t.reside_addr,t.letter_addr,t.post_code,t.mobile_no,");
			//DF01EF07个人状况信息文件, DF01EF08婚姻状况信息文件
			execSql.append("t.df01ef0729,t.education,'' marr_state,");
			//DF01EF09单位信息文件
			execSql.append("'' df01ef092e,'' df01ef0930,'' df01ef0931,'' df01ef0932,");
			//DF01EF0A工资信息文件
			execSql.append("'' df01ef0a37,'' df01ef0a38,'' df01ef0a39,");
			//DF02EF05专业技能性能基本文件
			execSql.append("'' df02ef055701,'' df02ef055801,'' df02ef055901,'' df02ef055702,'' df02ef055802,'' df02ef055902,'' df02ef0542,");
			execSql.append("'' df02ef055a01,'' df02ef055b01,'' df02ef055c01,'' df02ef055d01,'' df02ef055a02,'' df02ef055b02,'' df02ef055c02,'' df02ef055d02,");
			//DF02EF06就失业基本文件
			execSql.append("'' df02ef064b,'' df02ef064c,'' df02ef064d,'' df02ef064f,'' df02ef0650,'' df02ef063a,");
			//DF02EF07就业信息文件
			execSql.append("'' df02ef070101,'' df02ef070102,'' df02ef070103,'' df02ef070104,'' df02ef070201,'' df02ef070202,'' df02ef070203,'' df02ef070204,");
			execSql.append("'' df02ef070301,'' df02ef070302,'' df02ef070303,'' df02ef070304,'' df02ef070401,'' df02ef070402,'' df02ef070403,'' df02ef070404,");
			//DF02EF08外出就业信息文件
			execSql.append("'' df02ef0852,'' df02ef0853,'' df02ef0854,");
			//DF02EF09外来就业信息文件
			execSql.append("'' df02ef0955,'' df02ef0956,'' df02ef0996,'' df02ef0997,");
			//DF03EF05失业保险信息文件
			execSql.append("'' df03ef0560,'' df03ef0598,'' df03ef0561,'' df03ef0562,'' df03ef0563,'' df03ef0564,'' df03ef0565,'' df03ef0566,");
			//DF03EF06丧失劳动力鉴定信息文件
			execSql.append("'' df03ef0667,'' df03ef0668,'' df03ef0669,'' df03ef066b,");
			//DF03EF07养老保险信息文件
			execSql.append("'' df03ef076c,'' df03ef076d,'' df03ef076e,'' df03ef076f ,'' df03ef0770 ,'' df03ef0771 ,'' df03ef0772,'' df03ef0773,");
			//DF04EF05医疗保险基本信息文件
			execSql.append("'' df04ef0580,'' df04ef0581,'' df04ef0583,'' df04ef0584,'' df04ef0586,'' df04ef0587,'' df04ef0589,'' df04ef058a,'' df04ef058b,'' df04ef058c,'' df04ef058f,");
			execSql.append("'' df04ef0690,'' df04ef0692,'' df04ef0693,b.med_whole_no df04ef0ca0 ");
			execSql.append("from card_task_list t,card_apply b,base_personal p ");
			execSql.append("WHERE t.apply_id = b.apply_id AND t.customer_id = b.customer_id and b.customer_id = p.customer_id ");
			//execSql.append("and t.cert_no = r.cert_no and t.name = r.name and");
			execSql.append("and b.apply_state = '" + Constants.APPLY_STATE_RWYSC + "' ");
			StringBuffer details = new StringBuffer();
			for(int i = 0;i < allTasks.size(); i++){
				CardApplyTask tempTask = (CardApplyTask) allTasks.get(i);
				logger.error("开始写入第" + (i + 1) + "个任务,任务编号:" + tempTask.getTaskId() + ",任务名称:" + tempTask.getTaskName());
				details.append(Tools.tensileString("-",10,true,"-") + Constants.NEWLINE);//任务分隔符
				details.append(Tools.processNull(tempTask.getTaskId()) + "|");//任务编号
				details.append(Tools.processNull(tempTask.getCardType()) + "|");//卡类型
				details.append(Tools.processNull(tempTask.getBankId()) + "|");//银行编号
				details.append(Tools.processNull(tempTask.getTaskSum()) + "|");//记录数量
				details.append(Tools.processNull(tempTask.getTaskName()) + "|");//任务地址
				details.append(Tools.processNull(tempTask.getBrchId()) + "|");//网点编号
				if(!Tools.processNull(tempTask.getBrchId()).equals("")){
					details.append(Tools.processNull((this.findOnlyFieldBySql("select full_name from sys_branch where brch_id = '" + tempTask.getBrchId() + "'"))) + "|");//网点名称
				}else{
					details.append("|");
				}
				details.append(Tools.processNull(tempTask.getCorpId()) + "|");
				if(!Tools.processNull(tempTask.getCorpId()).equals("")){
					details.append(Tools.processNull(this.findOnlyFieldBySql("select corp_name from base_corp where customer_id = '" + tempTask.getCorpId() + "'")) + "|");
				}else{
					details.append("|");
				}
				if(!Tools.processNull(tempTask.getRegionId()).equals("")){
					details.append(Tools.processNull(this.findOnlyFieldBySql("select region_name from base_region where region_id = '" + tempTask.getRegionId() + "'")) + "|");
				}else{
					details.append("|");
				}
				if(!Tools.processNull(tempTask.getTownId()).equals("")){
					details.append(Tools.processNull(this.findOnlyFieldBySql("select town_name from base_town where town_id = '" + tempTask.getTownId() + "'")) + "|");
				}else{
					details.append("|");
				}
				if(!Tools.processNull(tempTask.getCommId()).equals("")){
					details.append(Tools.processNull(this.findOnlyFieldBySql("select comm_name from base_comm where comm_id = '" + tempTask.getCommId() + "'")) + "|");
				}else{
					details.append("|");
				}
				details.append(Constants.NEWLINE);
				List<?> tempDetails = this.findBySql("select " + execSql.toString() + " and t.task_id = '" + tempTask.getTaskId() + "' ORDER BY T.NAME ASC");
				if(tempDetails == null || tempDetails.size() <= 0){
					throw new CommonException("勾选的制卡任务信息中，任务编号为" + tempTask.getTaskId() + "的任务明细不存在，或是申领状态不正常！");
				}
				if(!Tools.processNull(tempTask.getTaskSum() + "").equals(tempDetails.size() + "")){
					throw new CommonException("勾选的制卡任务信息中，任务编号为" + tempTask.getTaskId() + "的任务明细数量和任务中的数量不一致！");
				}
				for (int j = 0; j < tempDetails.size(); j++) {
					Object[] oneRow = (Object[]) tempDetails.get(j);
					for (Object object : oneRow) {
						details.append(Tools.processNull(object).toString() + "|");
					}
					details.append(Constants.NEWLINE);
				}
				int upcount = publicDao.doSql("update card_apply_task t set t.vendor_id = '" + vendorId + "',t.make_batch_id = '" + taskBatch.getBatchId() +  "',t.task_state = '" + Constants.TASK_STATE_ZKZ +
				"',t.yh_num = " + tempTask.getTaskSum() + ",end_num = " + tempTask.getTaskSum() + " where t.task_id = '" + tempTask.getTaskId() + "' and t.task_state = '" + Constants.TASK_STATE_YSC + "'");
				if(upcount != 1){
					throw new CommonException("更新勾选的制卡任务信息中，任务编号为" + tempTask.getTaskId() + "的任务状态为【制卡中】时出现错误！");
				}
				upcount = publicDao.doSql("update card_apply t set t.buy_plan_id = '" + taskBatch.getBatchId() + "', t.apply_state = '" + Constants.APPLY_STATE_ZKZ +
				"' where t.task_id = '" +tempTask.getTaskId() + "' and t.apply_state = '" + Constants.APPLY_STATE_RWYSC + "'");
				if(upcount != tempTask.getTaskSum()){
					throw new CommonException("更新勾选的制卡任务信息中，任务编号为" + tempTask.getTaskId() + "的申领状态为【制卡中】时出现错误，更新数量和银行审核数量不一致！");
				}
				logger.error("任务" + tempTask.getTaskId() + "写入成功");
			}
			if(!(ftpClient.isConnected() && ftpClient.isAvailable())){
				ftpClient = new DefaultFTPClient();
				if(!ftpClient.toConnect(ftpOptions.get("url"),Integer.valueOf(ftpOptions.get("port")))){
					throw new CommonException("FTP连接失败！");
				}
				if(!ftpClient.toLogin(ftpOptions.get("userName"),ftpOptions.get("pwd"))){
					throw new CommonException("FTP登录失败！");
				}
				ftpClient.setControlEncoding("GBK");
				ftpClient.setFileTransferMode(DefaultFTPClient.STREAM_TRANSFER_MODE);
				ftpClient.setFileType(DefaultFTPClient.BINARY_FILE_TYPE);
				if(!ftpClient.changeWorkingDirectory(ftpPatch)){
					throw new CommonException("FTP切换到目录" + ftpPatch + "失败！");
				}
			}
			logger.error("开始上传文件" + fileName +  "...");
			ftpClient.setFileType(FTP.BINARY_FILE_TYPE);
            os = ftpClient.storeFileStream(new String(fileName.replace("txt","zip").getBytes()));
			zip = new ZipArchiveOutputStream(os);
			zip.setEncoding("GBK");
			zip.setComment("卡厂制卡文件_" + fileName);
			ByteArrayInputStream  fileConts = new ByteArrayInputStream(taskHeader.append(details).toString().getBytes("GBK"));
			ZipArchiveEntry tarFile = new ZipArchiveEntry(fileName);
			zip.putArchiveEntry(tarFile);
			byte[] buf = new byte[1024 * 1024];
			int pos = 0;
			while((pos = fileConts.read(buf)) != -1) {
				zip.write(buf,0,pos);					
			}
			zip.closeArchiveEntry();
			logger.error("开始写入照片...");
			for(int i = 0; i < allTasks.size(); i++) {
				CardApplyTask tempTask = (CardApplyTask) allTasks.get(i);
				if(Tools.processNull(tempTask.getIsPhoto()).equals(Constants.YES_NO_NO)){
					logger.error("勾选的制卡任务信息中，任务编号为" + tempTask.getTaskId() + "的任务是否导出照片标志设置为无需导出照片！");
					continue;
				}
				logger.error("开始写入任务编号为" + tempTask.getTaskId() + ",任务名称:" + tempTask.getTaskName() + "的照片,数量" + tempTask.getTaskSum() + " ...");
				List tempOneRow = findBySql(photoSql.toString() + " and t.task_id = '" + tempTask.getTaskId() + "'");
				if(tempOneRow.size() != tempTask.getTaskSum()){
					try{
						ftpClient.deleteFile(fileName.replace("txt","zip"));
					}catch(Exception e){
						logger.error(e);
					}
					throw new CommonException("勾选的制卡任务信息中，任务编号为" + tempTask.getTaskId() + "的任务的照片数量和任务明细数量不一致！");
				}
				for (int j = 0; j < tempOneRow.size(); j++) {
					Object[] o = (Object[]) tempOneRow.get(j);
					ZipArchiveEntry tempPhoto = new ZipArchiveEntry(Tools.processNull(o[0]));
					zip.putArchiveEntry(tempPhoto);
					zip.write(FileIO.InputStreamToByte(((Blob)o[1]).getBinaryStream()));
					zip.closeArchiveEntry();
				}
				logger.error("写入成功");
				os.flush();
				tempOneRow = null;
			}
			zip.finish();
			zip.flush();
			zip.close();
			zip = null;
			os.flush();
			os.close();
			os = null;
			if(!(FTPReply.isPositiveCompletion(ftpClient.getReply()))){
				throw new CommonException("文件上传失败，请检查FTP设置信息！");
			}
			logger.error("文件" + fileName + "上传成功！");
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setBizTime(log.getDealTime());
			rec.setBrchId(log.getBrchId());
			rec.setCardType(cardType);
			rec.setUserId(log.getUserId());
			rec.setOrgId(log.getOrgId());
			rec.setClrDate(getClrDate());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setNote(log.getMessage());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			logger.error(e.getMessage());
			throw new CommonException(e.getMessage());
		}finally{
			logger.error("结束任务" + taskIdsString + "的导出");
			try{
				if(zip != null){
					zip.close();
					zip = null;
				}
				if(os != null){
					os.close();
					os = null;
				}
				if(ftpClient != null && ftpClient.isAvailable()){
					ftpClient.logout();
					ftpClient.disconnect();
				}
			}catch(Exception e1){
				logger.error(e1);
			}
		}
	}
	/**
	 * 导出市民卡和银行卡号对应关系
	 * @param batchId 批次号
	 * @param user 操作员
	 * @param log  日志
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveExportBankBkFile(String batchId,String bankId,Users user,SysActionLog log) throws CommonException{
		DefaultFTPClient  ftpClient = null;
		try{
			if(Tools.processNull(batchId).equals("")){
				throw new CommonException("批次编号不能为空！");
			}
			if(Tools.processNull(bankId).equals("")){
				throw new CommonException("银行编号不能为空！");
			}
			CardTaskBatch batch = (CardTaskBatch) this.findOnlyRowByHql("from CardTaskBatch t where t.batchId = '" + batchId + "'");
			if(batch == null){
				throw new CommonException("根据批次编号" + batchId + "找不到批次信息！");
			}
			List<?> allTask = this.findByHql("from CardApplyTask t where t.makeBatchId = '" + batchId + "'");
			if(allTask == null || allTask.size() < 1){
				throw new CommonException("根据批次编号" + batchId + "找不到任务信息！");
			}
			BigDecimal isCount = (BigDecimal) this.findOnlyFieldBySql("select count(1) from card_apply_task where make_batch_id = '" + batchId + "' "
			+ "and task_state < '" + Constants.TASK_STATE_YZK + "' and task_sum > 0");
			if(isCount.intValue() > 0){
				throw new  CommonException("编号为" + batchId + "的批次中，有" + isCount.intValue() + "个任务未制卡无法进行导出卡号对应关系！");
			}
			List<?> allBankIds = this.findBySql("select t.bank_id from card_apply_task t where t.make_batch_id = '" + batchId + "' group by t.bank_id"); 
			if(allBankIds == null || allBankIds.size() < 1){
				throw new CommonException("批次编号为" + batchId + "的任务信息中找不到银行编号信息！");
			}
			if(allBankIds.size() > 1){
				throw new CommonException("批次编号为" + batchId + "的任务信息中银行编号不一致！");
			}
			if(!bankId.equals(allBankIds.get(0))){ 
				throw new CommonException("批次编号为" + batchId + "的任务信息中银行编号和传入的银行编号不一致！");
			}
			List<?> cardTypeAndIsUrgent = this.findBySql("select card_type,is_urgent from card_apply_task where make_batch_id = '" + batchId + "' group by card_type,is_urgent");
			if(cardTypeAndIsUrgent == null || cardTypeAndIsUrgent.size() <= 0){
				throw new CommonException("批号编号" + batchId + "的任务信息中找不到卡类型和制卡方式信息！");
			}
			if(cardTypeAndIsUrgent.size() > 1){
				throw new CommonException("批号编号" + batchId + "的任务信息中含有多种卡类型或多种制卡方式信息！");
			}
			String cardType = (String) ((Object[])cardTypeAndIsUrgent.get(0))[0];
			if(Tools.processNull(cardType).trim().equals("")){
				throw new CommonException("批号编号" + batchId + "的任务信息中找不到卡类型信息！");
			}
			String isUrgent = (String) ((Object[])cardTypeAndIsUrgent.get(0))[1];
			if(Tools.processNull(isUrgent).trim().equals("")){
				throw new CommonException("批号编号" + batchId + "的任务信息中找不到制卡方式信息！");
			}
			logger.error(Tools.tensileString("-",50,true,"-"));
			logger.error("#开始生成市民卡银行卡号对应关系文件");
			logger.error("#正在检查FTP配置信息");
			Map<String,String>  ftpOptions = this.initFtpOptions("make_card_task_to_bank_" + bankId);
			ftpClient = this.checkFtp(ftpOptions);
			if(Tools.processNull(ftpOptions.get("host_download_path")).equals("")){
				throw new CommonException("获取ftp配置出错，ftp银行下载路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_download_path:" + ftpOptions.get("host_download_path"));
			}
			if(!ftpClient.changeWorkingDirectory("/") || !ftpClient.changeWorkingDirectory(ftpOptions.get("host_download_path"))){
				throw new CommonException("FTP切换到目录" + ftpOptions.get("host_download_path") + "失败！");
			}else{
				logger.error("FTP目录切换正常");
			}
			logger.error("当前工作目录" + ftpClient.printWorkingDirectory());
			ftpClient.logout();
			ftpClient.disconnect();
			logger.error("FTP检查完毕");
			
			log.setDealCode(DealCode.MAKE_CARD_TASK_EXPORT_BANK_OPENACC);
			log.setMessage("导出银行开户文件.");
			publicDao.save(log);
			
			String fileName = "BK_" + Tools.tensileString(bankId,15,true,"0") + "_" + DateUtil.formatDate(log.getDealTime(),"yyyyMMddHHmmss");
			StringBuffer sb = new StringBuffer();
			Long totRowsNum = 0L;
			StringBuffer execSql = new StringBuffer();
			execSql.append("SELECT C.SUB_CARD_NO,C.BANK_CARD_NO,T.NAME,T.SEX,DECODE(b.CERT_TYPE,'1','01','2','10','3','02','4','03','5','10','6','10','10') CERT_TYPE,");
			execSql.append("T.CERT_NO,T.NATION,B.COUNTRY,T.BIRTHPLACE,T.BIRTHDAY,");
			execSql.append("B.MOBILE_NO,B.TEL_NOS,T.LETTER_ADDR,B.CORP_CUSTOMER_ID,P.CORP_NAME,");
			execSql.append("M.TOWN_NAME,N.COMM_NAME,C.RECV_BRCH_ID,S.FULL_NAME, '' BANK_DEAL_NO ");
			execSql.append("FROM CARD_TASK_LIST T,CARD_APPLY C,BASE_PERSONAL B,BASE_CORP P,SYS_BRANCH S,BASE_TOWN M,BASE_COMM N ");
			execSql.append("WHERE T.TASK_ID = C.TASK_ID AND T.APPLY_ID = C.APPLY_ID ");
			execSql.append("AND C.CUSTOMER_ID = B.CUSTOMER_ID AND B.CORP_CUSTOMER_ID = P.CUSTOMER_ID(+) AND ");
			execSql.append("C.RECV_BRCH_ID = S.BRCH_ID(+) AND B.TOWN_ID = M.TOWN_ID(+) AND B.COMM_ID = N.COMM_ID(+) ");
			execSql.append("AND C.APPLY_STATE >= '" + Constants.APPLY_STATE_YZK + "' AND ");
			for (int i = 0 ;i < allTask.size(); i++) {
				CardApplyTask tempTask  = (CardApplyTask) allTask.get(i);
				if (tempTask.getTaskSum() == 0) {
					continue;
				}
				if(Tools.processNull(tempTask.getTaskState()).compareTo(Constants.TASK_STATE_YZK) < 0){
					throw new CommonException("批次编号" + batchId + "中，任务编号为" + tempTask.getTaskId() + "的任务未制卡，无法导出卡号对应关系！");
				}
				if(Tools.processNull(tempTask.getYhNum()).equals("")){
					throw new CommonException("批次编号" + batchId + "中，任务编号为" + tempTask.getTaskId() + "的任务，银行审核成功条数为空！");
				}
				BigDecimal noBankNoNum = (BigDecimal) this.findOnlyFieldBySql("select count(1) from card_apply t where t.task_id = '" + tempTask.getTaskId() + 
				"' and t.bank_card_no is null and t.apply_state >= '" + Constants.APPLY_STATE_YZK + "' and t.apply_state < '" + Constants.APPLY_STATE_YZX + "'");
				if(noBankNoNum.intValue() > 0){
					throw new CommonException("批次编号" + batchId + "中，任务编号为" + tempTask.getTaskId() + "的任务，有" + noBankNoNum.intValue() + "条申领记录没有银行卡号！");
				}
				totRowsNum += tempTask.getYhNum();
				List<?> tempRows = this.findBySql(execSql.toString() + "t.task_id = '" + tempTask.getTaskId() + "' ");
				if(tempRows.size() != tempTask.getYhNum()){
					throw new CommonException("批次编号" + batchId + "中，任务编号为" + tempTask.getTaskId() + "的任务明细数量和制卡导入数量不一致！或该任务下的申领记录不为【制卡中】");
				}
				for (Object object : tempRows) {
					Object[] tempRowColumns = (Object[]) object;
					sb.append(Tools.tensileStringByByte(Tools.processNull(tempRowColumns[0]),20,false," "));//社保卡卡号
					sb.append(Tools.tensileStringByByte(Tools.processNull(tempRowColumns[1]),20,false," "));//银行卡卡号
					sb.append(Tools.tensileStringByByte(Tools.processNull(tempRowColumns[2]),30,false," "));//姓名
					sb.append(Tools.tensileStringByByte(Tools.processNull(tempRowColumns[3]),1,false," "));//性别
					sb.append(Tools.tensileStringByByte(Tools.processNull(tempRowColumns[4]),2,false," "));//证件类型
					sb.append(Tools.tensileStringByByte(Tools.processNull(tempRowColumns[5]),18,false," "));//证件号码
					sb.append(Tools.tensileStringByByte(Tools.tensileString(Tools.processNull(tempRowColumns[6]),1,false," "),2,true," "));//民族
					sb.append(Tools.tensileStringByByte(Tools.processNull("CHN"),3,false," "));//国籍
					sb.append(Tools.tensileStringByByte(Tools.tensileString(Tools.processNull(tempRowColumns[8]),3,false," "),6,true," "));//出生地
					sb.append(Tools.tensileStringByByte(Tools.processNull(tempRowColumns[9]).replaceAll("-", ""),8,false," "));//出生日期
					sb.append(Tools.tensileStringByByte(Tools.processNull(tempRowColumns[10]),11,false," "));//手机号码
					sb.append(Tools.tensileStringByByte(Tools.processNull(tempRowColumns[11]),15,false," "));//联系电话
					sb.append(Tools.tensileStringByByte(Tools.tensileString(Tools.processNull(tempRowColumns[12]),30,false," "),60,false," "));//联系地址
					sb.append(Tools.tensileStringByByte(Tools.processNull(tempRowColumns[13]),20,false," "));//单位编号
					sb.append(Tools.tensileStringByByte(Tools.tensileString(Tools.processNull(tempRowColumns[14]),40,false," "),80,false," "));//单位名称
					sb.append(Tools.tensileStringByByte(Tools.tensileString(Tools.processNull(tempRowColumns[15]),25,false," "),50,false," "));//乡镇街道
					sb.append(Tools.tensileStringByByte(Tools.tensileString(Tools.processNull(tempRowColumns[16]),25,false," "),50,false," "));//社区村
					sb.append(Tools.tensileStringByByte(Tools.processNull(tempRowColumns[17]),8,false," "));//领卡网点编号
					sb.append(Tools.tensileStringByByte(Tools.tensileString(Tools.processNull(tempRowColumns[18]),25,false," "),50,false," "));//领卡网点名称
					sb.append(Tools.tensileStringByByte(Tools.processNull(tempRowColumns[19]),10,false," "));//凭证号
					sb.append(Tools.tensileStringByByte("F",20,false,"F"));//保留域
					sb.append(Constants.NEWLINE);
				}
				//导出市民卡和银行的卡号对应关系后 修改任务，申领的状态
				/*publicDao.doSql("update card_apply t set t.apply_state = '" + Constants.APPLY_STATE_YHKHZ + "' where t.buy_plan_id = '" + tempTask.getTaskId() +
				"' and t.apply_state = '" + Constants.APPLY_STATE_YZK + "'");
				publicDao.doSql("update card_apply_task t set t.task_state = '" + Constants.TASK_STATE_YHKHZ + "' where t.task_id = '" + tempTask.getTaskId() + 
				"' and t.task_state = '" + Constants.TASK_STATE_YZK + "' ");*/
			}
			int upcount = publicDao.doSql("update card_task_batch t set t.export_bank_state = '0' where t.batch_id = '" + batchId + "'");
			if(upcount != 1){
				throw new CommonException("修改批次是否导出卡号对应关系标志时出现错误，更新" + upcount + "行！");
			}
			StringBuffer finalFileConts = new StringBuffer();
			finalFileConts.append("BK".toUpperCase() + Tools.tensileString(totRowsNum + "",8,true,"0") + Tools.tensileString("484",8,true,"0"));
			finalFileConts.append(Tools.tensileString("F",10,true,"F") + "\n");
			finalFileConts.append(sb);
			logger.error("文件生成成功,开始上传FTP:" + ftpOptions.get("host_download_path") + fileName);
			ByteArrayInputStream is = new ByteArrayInputStream(finalFileConts.toString().getBytes("GBK"));
			ftpClient = new DefaultFTPClient();
			if(!ftpClient.toConnect(ftpOptions.get("url"),Integer.valueOf(ftpOptions.get("port")))){
				throw new CommonException("FTP连接失败！");
			}
			ftpClient.setControlEncoding("GBK");
			if(!ftpClient.toLogin(ftpOptions.get("userName"),ftpOptions.get("pwd"))){
				throw new CommonException("FTP登录失败！");
			}
			if(!ftpClient.changeWorkingDirectory("/") || !ftpClient.changeWorkingDirectory(ftpOptions.get("host_download_path"))){
				throw new CommonException("FTP切换到目录" + ftpOptions.get("host_download_path") + "失败！");
			}
			ftpClient.setFileType(FTPClient.BINARY_FILE_TYPE);
			if(ftpClient.storeFile(fileName.toUpperCase(),is)){
				try{
					JSONArray array = new JSONArray();
					JSONObject one = new JSONObject();
					one.put("trcode","B0055");
					one.put("bizid",bankId);
					one.put("termid",user.getUserId());
					one.put("termno",log.getDealNo());
					one.put("makecardtype",(Tools.processNull(isUrgent).equals("0") ? "01" : "02"));
					one.put("filetype","000002");
					one.put("filename",fileName);
					one.put("filesize",finalFileConts.toString().getBytes("GBK").length);
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
				}catch(Exception e2){
					ftpClient.deleteFile(fileName.toUpperCase());
					throw new CommonException(e2.getMessage());
				}
			}else{
				throw new CommonException("上传文件到FTP出现错误：请检查ftp路径设置及网络问题！");
			}
			logger.error("文件" + fileName + "上传成功");
			System.gc();
			return null;
		}catch(Exception e){
			logger.error(e.getMessage());
			throw new CommonException(e.getMessage());
		}finally{
			try {
				if(ftpClient != null && ftpClient.isAvailable()){
					ftpClient.logout();
					ftpClient.disconnect();
				}else{
					ftpClient = null;
				}
			} catch (IOException e1){
				e1.printStackTrace();
			}
			logger.error("结束批次" + bankId + "市民卡银行卡号对应关系导出");
		}
	}
	/**
	 * 组装数据插入临时表
	 * @param drBatchId 导入的批次号
	 * @param batchId   任务的批次号
	 * @param taskId    任务编号
	 * @param tempRow   文件行数据
	 * @param rowNum    任务的第几条数据
	 * @param sb        缓冲区
	 * @param oper      操作员
	 * @return          缓冲区
	 * @throws CommonException
	 */
	public StringBuffer createImportCardDataSql(String drBatchId,String batchId,String taskId,String tempRow,int rowNum,StringBuffer sb,Users oper) throws CommonException{
		try{
			//tempRow = new String(tempRow.getBytes(),"GBK");
			if(Tools.processNull(tempRow).equals("")){
				throw new CommonException("第" + rowNum + "行内容为空，无法进行解析！");
			}
			String[] tempColumns = new String[15];
			String[] srcColumns = tempRow.split("\\|");
			System.arraycopy(srcColumns, 0, tempColumns, 0,srcColumns.length);
			if(!Tools.processNull(taskId).equals(tempColumns[0])){
				throw new CommonException("导入文件中任务编号为【" + taskId + "】的任务，第" + rowNum + "条的数据任务编号和任务说明中的任务编号不一致！");
			}
			sb.append("'insert into card_task_imp_tmp(task_id,data_seq,customer_id,name,cert_no,ssseef0507,card_no,");
			sb.append("struct_main_type,struct_child_type,bar_code,card_id,atr,rfatr,bankcardno,bank_certificate_no,org_id,brch_id,user_id,batch_id,dr_batch_id) values (");
			sb.append("''" + Tools.processNull(tempColumns[0]) + "'',");//任务号
			sb.append("''" + Tools.processNull(tempColumns[1]) + "'',");//任务明细号
			sb.append("''" + Tools.processNull(tempColumns[2]) + "'',");//客户编号
			sb.append("''" + Tools.processNull(tempColumns[3]) + "'',");//姓名
			sb.append("''" + Tools.processNull(tempColumns[4]) + "'',");//证件号码
			sb.append("''" + Tools.processNull(tempColumns[5]) + "'',");//接触式卡号
			sb.append("''" + Tools.processNull(tempColumns[6]) + "'',");//非接触卡号
			System.out.println(Tools.processNull(tempColumns[6]));//加的这句怎么没用?
			sb.append("''" + Tools.processNull(tempColumns[7]) + "'',");//非接触主类型
			sb.append("''" + Tools.processNull(tempColumns[8]) + "'',");//非接触子类型
			sb.append("''" + Tools.processNull(tempColumns[9]) + "'',");//条形码
			sb.append("''" + Tools.processNull(tempColumns[10]) + "'',");//卡识别码
			sb.append("''" + Tools.processNull(tempColumns[11]) + "'',");//接触式卡上电复位信息
			sb.append("''" + Tools.processNull(tempColumns[12]) + "'',");//非接触卡上电复位信息
			sb.append("''" + Tools.processNull(tempColumns[13]) + "'',");//银行卡号
			sb.append("''" + Tools.processNull(tempColumns[14]) + "'',");//银行凭证号
			sb.append("''" + Tools.processNull(oper.getOrgId()) + "'',");//机构
			sb.append("''" + Tools.processNull(oper.getBrchId()) + "'',");//网点
			sb.append("''" + Tools.processNull(oper.getUserId()) + "'',");//柜员
			sb.append("''" + Tools.processNull(batchId) + "'',");//批次号
			sb.append("''" + Tools.processNull(drBatchId) + "''");//导入临时批次号
			sb.append(")',");
			if(rowNum% 500 == 0){
				publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + sb.substring(0,sb.length() - 1) + "))");
				sb = new StringBuffer();
			}
			return sb;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 制卡文件导入（单个文件）
	 * @param fileName  文件名称
	 * @param is 文件输入流
	 * @param oper 操作员
	 * @param log  操作日志
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public int saveImportCardData(String fileName,InputStream is,Users oper,SysActionLog log) throws CommonException {
		try{
			if(is == null){
				throw new CommonException("文件内容不能空！");
			}
			if(Tools.processNull(fileName).trim().equals("")){
				throw new CommonException("文件名称不能为空！");
			}
			BufferedReader br = new BufferedReader(new InputStreamReader(is,"GBK"));
			String firstRow = br.readLine();
			String import_makecarddata_taskcolumn_100 = this.getSysConfigurationParameters("import_makecarddata_taskcolumn_100");
			String import_makecarddata_datacolumn_100 = this.getSysConfigurationParameters("import_makecarddata_datacolumn_100");	
			if(!Tools.processNull(firstRow).toLowerCase().equals(import_makecarddata_taskcolumn_100)){
				throw new CommonException("文件第1行中任务字段说明不正确！");
			}
			String secRow = br.readLine();
			if(!Tools.processNull(secRow).toLowerCase().equals(import_makecarddata_datacolumn_100)){
				throw new CommonException("文件第2行中数据字段说明不正确！");
			}
			this.publicDao.doSql("DELETE FROM CARD_TASK_IMP_TMP T WHERE T.BRCH_ID = '" + oper.getBrchId() + "' AND T.USER_ID = '" + oper.getUserId() + "'");
			String drBatchId = this.getSequenceByName("SEQ_CM_CARD_TASK_IMPORT");
			int fileRowNum = 2;
			int oneTaskSum = 0;
			int oneTaskRowNum = 0;
			int batchTotalNum = 0;
			String tempMakeBatchId = "";
			String tempTaskId = "";
			String tempRow = "";
			StringBuffer sb =  new StringBuffer();
			while((tempRow = br.readLine()) != null){
				fileRowNum++;
				if(tempRow.startsWith("-")){
					if(sb != null && sb.length() > 0){
						publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + sb.substring(0,sb.length() - 1) + "))");
						sb = new StringBuffer();
					}
					if(oneTaskRowNum > 0 && oneTaskRowNum != oneTaskSum){
						throw new CommonException("导入的制卡文件中任务编号为【" + tempTaskId + "】的制卡任务，实际制卡明细数量和原制卡任务数量不一致！");
					}
					oneTaskRowNum = 0;
					String taskColumnDefine = br.readLine();
					fileRowNum++;
					String[] taskColumns = Tools.processNull(taskColumnDefine).split("\\|");
					Object[] tempTaskMsg = (Object[]) this.findOnlyRowBySql("SELECT MAKE_BATCH_ID,CARD_TYPE,TASK_STATE,YH_NUM,IS_URGENT,BANK_ID FROM "
					+ "CARD_APPLY_TASK WHERE TASK_ID = '" + Tools.processNull(taskColumns[0]) + "'");
					if(tempTaskMsg == null || tempTaskMsg.length <= 0){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务信息不存在，位置在导入文件第" + fileRowNum + "行数据！");
					}
					if(!Tools.processNull(tempTaskMsg[2]).equals(Constants.TASK_STATE_ZKZ)){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务状态不为【制卡中】，位置在导入文件第" + fileRowNum + "行数据！");
					}
					if(!Tools.processNull(tempTaskMsg[3]).equals(Tools.processNull(taskColumns[3]))){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务，任务说明字段中制卡数量和导出制卡数量不一致，位置在导入文件第" + fileRowNum + "行数据！");
					}
					if(!Tools.processNull(tempMakeBatchId).equals("") && !Tools.processNull(tempTaskMsg[0]).equals(tempMakeBatchId)){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务，所属制卡批次和上一个任务的制卡批次不一致，位置在导入文件第" + fileRowNum + "行数据！");
					}
					if(!Tools.processNull(tempTaskMsg[5]).equals(taskColumns[2])){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务，任务说明字段中银行编号和导出时的银行编号不一致，位置在导入文件第" + fileRowNum + "行数据！");
					}
					tempMakeBatchId = tempTaskMsg[0].toString();
					tempTaskId = taskColumns[0];
					oneTaskSum = Integer.parseInt(taskColumns[3]);
					BigDecimal tempApplyCount = (BigDecimal)this.findOnlyFieldBySql("SELECT COUNT(1) FROM CARD_APPLY WHERE APPLY_STATE = '" + Constants.APPLY_STATE_ZKZ + "' AND TASK_ID = '" + tempTaskId + "'");
					if(tempApplyCount.intValue() != oneTaskSum){
						throw new CommonException("导入制卡文件中任务编号为【" + tempTaskId + "】的制卡任务信息，申领制卡数量和实际制卡数量不一致或该任务下的申领记录不为【制卡中】状态，位置在导入文件第" + fileRowNum + "行数据！");
					}
					/*int upStockCount = publicDao.doSql("UPDATE STOCK_ACC  T SET T.TOT_NUM = NVL(T.TOT_NUM,0) + '" + oneTaskSum + "',T.LAST_DEAL_DATE = TO_DATE('" + 
					DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','YYYY-MM-DD HH24:MI:SS') WHERE " +
					"T.ORG_ID = '" + oper.getOrgId() + "' AND T.BRCH_ID = '" + oper.getBrchId() + "' AND  T.USER_ID = '" + oper.getUserId() + "' " +
					"AND T.STK_CODE = '1" +  Tools.processNull(tempTaskMsg[1]) + "' AND T.GOODS_STATE = '" + Constants.STATE_ZC + "'"
					);
					if(upStockCount != 1){
						throw new CommonException("柜员库存分账户不存在！");
					}*/
					continue;
				}
				oneTaskRowNum++;
				batchTotalNum++;
				sb = createImportCardDataSql(drBatchId,tempMakeBatchId,tempTaskId,tempRow,oneTaskRowNum,sb,oper);
			}
			if(sb != null && sb.length() > 0){
				publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + sb.substring(0,sb.length() - 1) + "))");
			}
			if(oneTaskRowNum > 0 && oneTaskRowNum != oneTaskSum){
				throw new CommonException("任务编号" + tempTaskId + "的制卡任务，实际制卡明细数量和原制卡任务数量不一致！");
			}
			BigDecimal hasImportCount =  (BigDecimal)this.findOnlyFieldBySql("SELECT COUNT(1) FROM CARD_TASK_IMP_TMP T,CARD_BASEINFO C WHERE "
			+ "T.CARD_NO = C.CARD_NO AND T.CARD_ID = C.CARD_ID AND T.DR_BATCH_ID = '" + drBatchId + "'");
			if(hasImportCount.intValue() != 0){
				throw new CommonException("当前制卡导入的文件中已经有" + hasImportCount.intValue() + "条数据已经导入，请不要重复进行导入！");
			}
			BigDecimal batchTotAmt = (BigDecimal)this.findOnlyFieldBySql("SELECT SUM(T.YH_NUM) FROM CARD_APPLY_TASK T WHERE T.MAKE_BATCH_ID = '" + tempMakeBatchId + "'");
			if(batchTotAmt.intValue() < batchTotalNum){
				throw new CommonException("当前制卡导入文件的制卡明细数量不能大于该批次的制卡明细数量！");
			}
			BigDecimal judgeSucNum = (BigDecimal)this.findOnlyFieldBySql("SELECT COUNT(1) FROM CARD_TASK_IMP_TMP T,CARD_TASK_LIST L WHERE "
			+ "T.TASK_ID = L.TASK_ID AND T.DATA_SEQ = L.DATA_SEQ AND T.CERT_NO = L.CERT_NO AND T.NAME = L.NAME AND T.DR_BATCH_ID = '" + drBatchId + "'");
			if(judgeSucNum.intValue() != batchTotalNum){
				//throw new CommonException("当前文件中有" + (batchTotalNum - judgeSucNum.intValue()) + "条数据的个人信息不正确，请校验文件");
			}
			StringBuffer execsql = new StringBuffer();
			execsql.append(oper.getBrchId() + "|");
			execsql.append(Constants.ACPT_TYPE_GM + "|");
			execsql.append(oper.getUserId()+ "|");
			execsql.append("" + "|");
			execsql.append(drBatchId + "|");
			List inParameters = new ArrayList();
			inParameters.add(execsql.toString());
			List outParameters = new ArrayList();
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List outList = publicDao.callProc("PK_CARD_STOCK.PK_IMPORT_CARDDATA",inParameters,outParameters);
			if(outList == null || outList.size() <= 0){
				throw new CommonException("调取过程进行入库出现错误，返回为空！");
			}
			if(Integer.valueOf(outList.get(0).toString()) != 0){
				throw new CommonException(outList.get(1).toString());
			}
			return batchTotalNum;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	
	/**
	 * 充值卡制卡文件导入
	 * @param fileName 文件名称
	 * @param is 文件输入流
	 * @param oper 操作员
	 * @param log 操作日志
	 * @return 成功导入数据的条数
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public int saveImportRechargeCardData(String fileName, InputStream is, Users oper, SysActionLog log) throws CommonException {
		try {
			// 判断当前柜员是否存在充值卡账户
			StockAcc stockAcc = (StockAcc) findOnlyRowByHql("from StockAcc s where s.id.userId = '" + getSessionUser().getUserId() + "' and s.id.stkCode = '1" + Constants.CARD_TYPE_CZK + "' and s.id.goodsState = '" + Constants.GOODS_STATE_ZC + "'");
			if (stockAcc == null) {
				throw new CommonException("柜员【" + getSessionUser().getName() + "】不存在充值卡库存账户！");
			}
			// 判断当前柜员充值卡账户状态
			if (!stockAcc.getAccState().equals(Constants.STATE_ZC)) {
				throw new CommonException("柜员【" + getSessionUser().getName() + "】充值卡库存账户为【注销】状态！");
			}
			// 判断文件名称是否为空
			if (Tools.processNull(fileName).equals("")) {
				throw new CommonException("文件名称不能为空！");
			}
			// 判断文件内容是否为空
			if (is == null) {
				throw new CommonException("文件内容不能为空！");
			}
			BufferedReader br = new BufferedReader(new InputStreamReader(is));
			String firstRow = br.readLine();
			// 读取文件内容第一行判断任务字段说明是否匹配
			if (!Tools.processNull(firstRow).toLowerCase().equals("batch_id|task_id|seq|cardno|cardtype")) {
				throw new CommonException("文件第1行中任务字段说明不正确！");
			}
			log.setDealCode(DealCode.RECHANGE_CARD_IMPORT);
			log.setMessage("充值卡制卡数据导入");
			log.setNote("充值卡制卡数据导入");
			publicDao.save(log);
			int totalNum = 0;
			int count = 1;
			String tempRow = "";
			String batchId = "";
			String taskId = "";
			HashSet<String> logs = new HashSet<String>();
			while((tempRow = br.readLine()) != null) {
				count++;
				String[] columns = tempRow.split("\\|");
				if (columns.length != 5) {
					throw new CommonException("文件第" + count + "行：数据不完整！");
				}
				batchId = Tools.processNull(columns[0].trim());				// 批次号
				taskId = Tools.processNull(columns[1].trim());				// 任务号
				String seq = Tools.processNull(columns[2].trim());			// 任务明细序号
				String cardNo = Tools.processNull(columns[3].trim());		// 卡号
				String cardType = Tools.processNull(columns[4].trim());		// 卡类型
				CardApplyTask cardApplyTask = (CardApplyTask) findOnlyRowByHql("from CardApplyTask c where c.taskId = '" + taskId + "'");
				// 判断任务号是否存在
				if (cardApplyTask == null) {
					throw new CommonException("文件第" + count + "行：任务号【" + taskId + "】不存在！");
				}
				// 判断任务号和批次号是否匹配
				if (!batchId.equals(cardApplyTask.getMakeBatchId())) {
					throw new CommonException("文件第" + count + "行：任务号【" + taskId + "】与批次号【" + batchId + "】不匹配！");
				}
				CardTaskList cardTaskList = (CardTaskList) findOnlyRowByHql("from CardTaskList c where c.taskId = '" + taskId + "' and c.dataSeq = " + seq);
				// 判断任务明细序号是否存在
				if (cardTaskList == null) {
					throw new CommonException("文件第" + count + "行：任务明细序号【" + seq + "】不存在！");
				}
				// 判断卡号和任务明细序号是否匹配
				if (!cardNo.equals(cardTaskList.getCardNo())) {
					throw new CommonException("文件第" + count + "行：卡号【" + cardNo + "】与任务明细序号【" + seq + "】不匹配！");
				}
				// 判断卡类型和卡号是否匹配
				if (!cardType.equals(cardTaskList.getCardType())) {
					throw new CommonException("文件第" + count + "行：卡类型【" + cardType + "】与卡号【" + cardNo + "】不匹配！");
				}
				StockList stockList = (StockList) findOnlyRowByHql("from StockList s where s.goodsNo = '" + cardNo + "'");
				// 判断当前充值卡是否已入库
				if (stockList != null) {
					throw new CommonException("文件第" + count + "行：卡号【" + cardNo + "】已入库！");
				}
				CardRecharge cardRecharge = new CardRecharge();
				cardRecharge.setDataSeq(Long.parseLong(seq));
				cardRecharge.setTaskId(taskId);
				cardRecharge.setOrgId(cardTaskList.getInitOrgId());
				cardRecharge.setCardType(cardType);
				cardRecharge.setCardNo(cardNo);
				cardRecharge.setFaceVal(cardTaskList.getFaceVal());
				cardRecharge.setPwd(cardTaskList.getPwd());
				cardRecharge.setUseState(Constants.CARD_RECHARGE_STATE_WSY);
				publicDao.save(cardRecharge);
				logs.add("任务号：" + taskId + "，批次号：" + batchId + "充值卡制卡数据入库");
				// 调用存储过程，库存物品入库
				List inParamList = new ArrayList();
				StringBuffer inParams = new StringBuffer();
				inParams.append(getSessionSysBranch().getBrchId() + "|");										// 网点编号
				inParams.append(Constants.ACPT_TYPE_GM + "|"); 													// 受理点类型
				inParams.append(getSessionUser().getUserId() + "|");											// 柜员编号
				inParams.append(log.getDealNo() + "|");															// 业务流水号
				inParams.append(log.getDealCode() + "|");														// 交易代码
				inParams.append(DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss") + "|");			// 业务操作时间
				inParams.append("1" + Constants.CARD_TYPE_CZK + "|");											// 库存类型
				inParams.append(cardNo + "|");																	// 物品编号id
				inParams.append(cardNo + "|");																	// 物品编号no
				inParams.append(Constants.GOODS_STATE_ZC + "|");												// 物品状态
				inParams.append(batchId + "|");																	// 所属批次
				inParams.append(taskId + "|");																	// 所属任务
				inParams.append(Constants.YES_NO_YES + "|");													// 是否确认
				inParams.append(getSessionSysBranch().getBrchId() + "|");										// 入库网点
				inParams.append(getSessionUser().getUserId() + "|");											// 入库柜员
				inParams.append(Constants.OWN_TYPE_GY + "|");													// 归属类型
				inParams.append(getSessionSysBranch().getOrgId() + "|");										// 归属机构
				inParams.append(getSessionSysBranch().getBrchId() + "|");										// 归属网点
				inParams.append(getSessionUser().getUserId() + "|");											// 归属柜员
				inParams.append("" + "|");																		// 归属客户编号
				inParams.append("" + "|");																		// 归属客户名称
				inParams.append("充值卡批量导入" + "|");															// 备注
				inParamList.add(inParams);
				List outParamList = new ArrayList();
				outParamList.add(java.sql.Types.VARCHAR);				// result
				outParamList.add(java.sql.Types.VARCHAR);				// message
				List resultList = publicDao.callProc("pk_card_stock.p_in_stock", inParamList, outParamList);
				if (resultList == null || resultList.size() <= 0) {
					throw new CommonException("调取过程进行入库出现错误，返回为空！");
				}
				if (Integer.valueOf(resultList.get(0).toString()) != 0) {
					throw new CommonException(resultList.get(1).toString());
				}
				totalNum++;
			}
			is.close();
			publicDao.doSql("update stock_acc s set s.tot_num = s.tot_num + " + totalNum + " where s.user_id = '" + getSessionUser().getUserId() +  "' and s.stk_code = '1" + Constants.CARD_TYPE_CZK + "' and s.goods_state = '0'");
			publicDao.doSql("update card_apply_task set task_state = '" + Constants.TASK_STATE_YZK + "' where task_id = '" + taskId + "' and make_batch_id = '" + batchId + "'");
			// 记录业务
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setClrDate(this.getClrDate());
			trServRec.setNote(Arrays.toString(logs.toArray()));
			trServRec.setDealState(Constants.TR_STATE_ZC);
			publicDao.save(trServRec);
			return totalNum;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 导入制卡文件（连接FTP）
	 * @param fileName 文件名信息
	 * @param ftpOptions ftp参数信息
	 * @param log 操作日志信息
	 * @return
	 */
	public int saveBatchImportMakeCardData(String fileName,Map<String,String> ftpOptions,SysActionLog log) throws CommonException{
		DefaultFTPClient client = null;
		InputStream tempFileIs = null;
		try{
			client = new DefaultFTPClient();
			if(!client.toConnect(ftpOptions.get("url"),Integer.valueOf(ftpOptions.get("port")))){
				throw new CommonException("FTP连接失败！");
			}else{
				logger.error("连接正常");
			}
			client.setControlEncoding("GBK");
			client.setFileType(DefaultFTPClient.BINARY_FILE_TYPE);
			if(!client.toLogin(ftpOptions.get("userName"),ftpOptions.get("pwd"))){
				throw new CommonException("FTP登录失败！");
			}else{
				logger.error("登录正常");
			}
			if(!client.changeWorkingDirectory("/") || !client.changeWorkingDirectory(ftpOptions.get("host_download_path"))){
				throw new CommonException("FTP切换到目录" + ftpOptions.get("host_download_path") + "失败，请检查ftp配置信息！");
			}else{
				logger.error("目录切换正常");
			}
			tempFileIs = client.retrieveFileStream(fileName);
			this.saveImportCardData(fileName,tempFileIs,this.getUser(),log);
			tempFileIs.close();
			tempFileIs = null;
			if(!client.completePendingCommand()){
				throw new CommonException("FTP取文件出现错误！");
			}
			if(!(client.isConnected() && client.isAvailable())){
				client = new DefaultFTPClient();
				client.setControlEncoding("GBK");
				client.setFileType(DefaultFTPClient.BINARY_FILE_TYPE);
				if(!client.toLogin(ftpOptions.get("userName"),ftpOptions.get("pwd"))){
					throw new CommonException("FTP登录失败！");
				}
				if(!client.changeWorkingDirectory("/") || !client.changeWorkingDirectory(ftpOptions.get("host_download_path"))){
					throw new CommonException("FTP切换到目录" + ftpOptions.get("host_download_path") + "失败，请检查ftp配置信息！");
				}
			}
			if(!client.rename(ftpOptions.get("host_download_path") + fileName.toUpperCase(),ftpOptions.get("host_history_path") + fileName.toUpperCase())){
				throw new CommonException("移动文件" + fileName + "到历史目录" + ftpOptions.get("host_history_path") + "失败！");
			}
		}catch(Exception e){
			throw new CommonException("处理文件" + fileName + "出现错误," + e.getMessage());
		}finally{
			if(client != null && client.isConnected()){
				try{
					client.logout();
					client.disconnect();
				}catch(IOException e) {
					e.printStackTrace();
				}
			}else{
				client = null;
			}
			if(tempFileIs != null){
				try{
					tempFileIs.close();
				}catch (IOException e){
					e.printStackTrace();
				}
			}
		}
		return 0;
	}
	/**
	 * 保存非个性化采购
	 * @param cardType 非个性化卡类型
	 * @param regionId 区域编号
	 * @param taskSum  采购数量
	 * @param oper 操作员
	 * @param log 操作日志
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveFgxhCg(String cardType,String bankId, String regionId,Long taskSum,Users oper,SysActionLog actionLog) throws CommonException {
		try{
			if(Tools.processNull(cardType).equals("")){
				throw new CommonException("非个性化采购卡类型不能为空！");
			}
			if(Tools.processNull(regionId).equals("")){
				throw new CommonException("非个性化采购区域编码不能为空！");
			}
			if(Tools.processNull(taskSum).equals("")){
				throw new CommonException("非个性化采购数量不能为空！");
			}
			if(Tools.processNull(bankId).equals("")){
				throw new CommonException("銀行不能为空！");
			}
			BaseRegion region = (BaseRegion) this.findOnlyRowByHql("from BaseRegion t where t.regionId = '" + regionId + "' ");
			if(region == null){
				throw new CommonException("根据区域代码" + regionId + "找不带区域信息！");
			}
			if(Tools.processNull(region.getRegionCode()).equals("")){
				throw new CommonException("区域【" + region.getRegionName() + "】的区编码未设置！");
			}
			if(Tools.processNull(region.getRegionCode()).length() != 2){
				throw new CommonException("区域【" + region.getRegionName() + "】的区编码设置不正确！");
			}
			actionLog.setDealCode(DealCode.PUBLICCARD_ADD);
			actionLog.setMessage("非个性化卡采购:" + this.getCodeNameBySYS_CODE("CARD_TYPE",cardType) + ",数量:" + taskSum);
			publicDao.save(actionLog);
			CardApplyTask task = new CardApplyTask();
			task.setDealNo(actionLog.getDealNo());
			task.setDealCode(actionLog.getDealCode());
			task.setIsList(Constants.YES_NO_YES);
			task.setCardType(cardType);
			task.setBankId(bankId);
			String taskId = DateUtil.formatDate(actionLog.getDealTime(),"yyyyMMdd") + Tools.tensileString(this.getSequenceByName("SEQ_TASK_ID"),8,true,"0");
			task.setTaskId(taskId);
			task.setTaskName("非个性化采购_" + this.getCodeNameBySYS_CODE("CARD_TYPE",task.getCardType()) + "_" + DateUtil.formatDate(actionLog.getDealTime(),"yyyyMMdd") + "_" + oper.getUserId());
			task.setTaskSum(Integer.valueOf(taskSum + ""));
			task.setTaskWay(Constants.TASK_WAY_WD);
			task.setTaskSrc(Constants.TASK_SRC_FGXHCG);
			task.setTaskDate(actionLog.getDealTime());
			task.setBrchId(oper.getBrchId());
			task.setTaskOperId(oper.getUserId());
			task.setTaskBrchId(oper.getBrchId());
			task.setTaskOrgId(oper.getOrgId());
			task.setIsUrgent(Constants.URGENT_WB);
			task.setTaskState(Constants.TASK_STATE_YSC);
			task.setRegionId(region.getRegionId());
			task.setYhNum(Long.valueOf(task.getTaskSum() + ""));
            task.setEndNum(Long.valueOf(task.getTaskSum() + ""));
            task.setWsNum(Long.valueOf(task.getTaskSum() + ""));
			task.setIsPhoto(Constants.YES_NO_NO);
			task.setNote(actionLog.getMessage());
			CardConfig config  = (CardConfig) this.findOnlyRowByHql("from CardConfig t where t.cardType = '" + cardType + "'");
			if(config == null){
				throw new CommonException("卡类型" + cardType + "参数信息未设置！");
			}
			task.setIsList(config.getLstFlag());
			if(Tools.processNull(config.getLstFlag()).equals(Constants.YES_NO_YES)){
				if(Tools.processNull(config.getCardValidityPeriod()).equals("")){
					throw new CommonException("该卡类型卡片有效期年数信息未设置！" + config.getCardType());
				}
				String city_code = Tools.tensileString(this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'CITY_CODE'").toString(),4,true,"0");
				if(Tools.processNull(city_code).trim().equals("")){
					throw new CommonException("城市代码不能为空，SYS_PARA中找不到参数CITY_CODE");
				}
				String month_Type = this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'MONTH_TYPE'").toString();
				if(Tools.processNull(month_Type).trim().equals("")){
					month_Type = "00";
				}
				String ndate = DateUtil.formatDate(task.getTaskDate(),"yyyyMMdd");
				String lsdate = DateUtil.processDateAddYear(DateUtil.formatDate(task.getTaskDate(),"yyyy-MM-dd"),config.getCardValidityPeriod()).replaceAll("-","");
				String pwd_rule = this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'PWD_RULE'").toString();
				if(Tools.processNull(pwd_rule).trim().equals("")){
					pwd_rule = "0";
				}
				String initpwd = this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'INITPWD'").toString();
				if(Tools.processNull(initpwd).trim().equals("")){
					initpwd = "888888";
				}
				this.createCardNo(task.getCardType(),region.getRegionCode(),Long.valueOf(task.getTaskSum() + ""),actionLog.getDealNo());
				StringBuffer exesql = new StringBuffer();
				exesql.append("insert into card_task_list(data_seq,task_id,");
				exesql.append("card_type,card_no,version,init_org_id,city_code,indus_code,cardissuedate,validitydate,bursestartdate,");
				exesql.append("bursevaliddate,monthstartdate,monthvaliddate,struct_main_type,struct_child_type,face_val,pwd,");
				exesql.append("bursebalance,monthbalance,bank_id,bankcardno,banksection2,banksection3,");
				exesql.append("useflag,month_type,hlht_flag,touch_startdate,touch_validdate)");
				exesql.append("(select seq_data_seq.nextval,'" + task.getTaskId() + "','" + task.getCardType() + "',");
				exesql.append("a.card_No,'" + Constants.CARD_VERSION + "','" + Constants.INIT_ORG_ID + "',a.city,'" + Constants.INDUS_CODE + "','");
				exesql.append(ndate + "','" + lsdate + "','" + ndate + "','" + lsdate + "','" + ndate + "','" + ndate + "','" + Tools.processNull(config.getStructMainType()) + "','" + Tools.processNull(config.getStructChildType()) + "',nvl(");
				exesql.append(config.getFaceVal() + ",'0')," + (Tools.processNull(pwd_rule).equals("0") ? "'" + initpwd + "'" : "ceil(dbms_random.value(100000,999999))") + ",");
				exesql.append("'" + Constants.BURSEBALANCE+"','" + Constants.MONTHBALANCE + "',");
				exesql.append("'','','','','" + Constants.USED_FLAG);
				exesql.append("','" + month_Type + "','" + city_code + "','" + ndate + "','" + lsdate+"' ");
				exesql.append("from card_no a where a.used = '0' and a.deal_no = " + actionLog.getDealNo());
				exesql.append(" and a.card_type = '" + task.getCardType() + "' and a.region_code = '" + region.getRegionCode() +"')");
				int c = publicDao.doSql(exesql.toString());
				if(c != task.getTaskSum()){
					throw new CommonException("\u63d2\u5165\u4efb\u52a1\u660e\u7ec6\u6570\u91cf\u4e0d\u6b63\u786e\uff0c\u83b7\u53d6\u5361\u53f7\u6570\u91cf\u4e0d\u6b63\u786e\uff01");
				}
				Object[] slCardNos = (Object[]) this.findOnlyRowBySql("select max(t.card_no),min(t.card_no) from card_task_list t where t.task_id = '" + task.getTaskId() + "'");
				task.setStartCardNo(Tools.processNull(slCardNos[0]));
				task.setEndCardNo(Tools.processNull(slCardNos[1]));
                if(Tools.processNull(cardType).equals(Constants.CARD_TYPE_FJMK) || Tools.processNull(cardType).equals(Constants.CARD_TYPE_FJMK_XS)){
                    int insertCount = this.publicDao.doSql("insert into card_fjmk_sale_list(data_seq,make_batch_id,task_id,card_id,card_no,card_type,sale_cost_fee,sale_foregift,sale_manager," +
                    "sale_to_corp_id,sale_to_corp_name,sale_state,sale_user_id,sale_brch_id,deal_no,note,parent_card_type,child_card_type)  select " +
                    "t.data_seq,null,t.task_id,null,t.card_no,t.card_type,0,0,null,null,null,'01',null,null,null,null,null,null from card_task_list t " +
                     "where t.task_id = '" + task.getTaskId() + "'"
                    );
                    if(insertCount != task.getTaskSum()){
                        throw new CommonException("插入非记名卡销售明细表数量和任务采购数量不一致！");
                    }
                }
			}
			publicDao.save(task);
			TrServRec rec =  new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealCode(actionLog.getDealCode());
			rec.setOrgId(actionLog.getOrgId());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(this.getClrDate());
			rec.setNote(actionLog.getMessage());
			rec.setCardAmt(Long.valueOf(task.getTaskSum()));
			rec.setCardType(task.getCardType());
			rec.setBizTime(actionLog.getDealTime());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 删除非个性化采购任务
	 * @param taskId
	 * @param oper
	 * @param actionLog
	 * @return
	 */
	public TrServRec saveDeleteFgxhCg(String taskId,Users oper,SysActionLog actionLog) throws CommonException{
		try{
			if(Tools.processNull(taskId).equals("")){
				throw new CommonException("任务编号不能为空！");
			}
			CardApplyTask task = (CardApplyTask) this.findOnlyRowByHql("from CardApplyTask t where t.taskId = '" + taskId + "'");
			if(task == null){
				throw new CommonException("根据任务编号" + taskId + "找不到任务信息！");
			}
			if(!Tools.processNull(task.getTaskSrc()).equals(Constants.TASK_SRC_FGXHCG)){
				throw new CommonException("任务编号" + taskId + "的制卡任务数据来源不是【非个性化】制卡，无法进行删除！");
			}
			if(!Tools.processNull(task.getTaskState()).equals(Constants.TASK_STATE_YSC)){
				throw new CommonException("任务编号" + taskId + "的制卡任务状态不是【任务已生成】状态，无法进行删除！");
			}
			actionLog.setDealCode(DealCode.PUBLICCARD_DEL);
			actionLog.setMessage("非个性化制卡删除,任务编号:" + taskId + ",数量:" + task.getTaskSum() + ",区域:" + task.getRegionId() + "卡类型:" + task.getCardType());
			publicDao.save(actionLog);
			int upcount = publicDao.doSql("update card_no t set t.used = '1',t.deal_no = null where t.deal_no = '" + task.getDealNo() + "'");
			if(upcount != task.getTaskSum()){
				throw new CommonException("删除任务" + task.getTaskId() + "时，释放卡号数量不正确！");
			}
			upcount = publicDao.doSql("delete from card_task_list t where t.task_id = '" + task.getTaskId() + "'");
			if(upcount != task.getTaskSum()){
				throw new CommonException("删除任务" + task.getTaskId() + "时,处理制卡明细数量不正确！");
			}
			if(Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_FJMK) || Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_FJMK_XS)){
                this.publicDao.doSql("delete from card_fjmk_sale_list t where t.task_id = '" + task.getTaskId() + "'");
            }
			publicDao.delete(task);
			TrServRec rec =  new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealCode(actionLog.getDealCode());
			rec.setOrgId(actionLog.getOrgId());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(this.getClrDate());
			rec.setNote(actionLog.getMessage());
			rec.setCardAmt(Long.valueOf(task.getTaskSum()));
			rec.setCardType(task.getCardType());
			rec.setBizTime(actionLog.getDealTime());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 导出非个性化制卡采购
	 * @param taskIds
	 * @param vendorId
	 * @param oper
	 * @param actionLog
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveExportFgxhCg(String bankId, String[] taskIds,String vendorId,Users oper,SysActionLog actionLog) throws CommonException{
		DefaultFTPClient ftpClient = null;
		OutputStream os = null;
		ZipArchiveOutputStream zip = null;
		String fileName = "";
		int totNums = 0;
		String ftpPath = "";
		
		try{
			String cardType = "";String isUrgent = "";String regionId = "";String regionName = "";String bankName = "";
			if(taskIds == null || !(taskIds instanceof String[])){
				throw new CommonException("导出的任务编号不能为空！");
			}
			if(Tools.processNull(vendorId).equals("")){
				throw new CommonException("卡厂编号不能为空！");
			}
			BaseVendor vendor =  (BaseVendor) this.findOnlyRowByHql("from BaseVendor t where t.vendorId = '" + vendorId + "'");
			if(vendor == null){
				throw new CommonException("根据卡厂编号" + vendorId + "找不到卡厂信息！");
			}
			logger.error(Tools.tensileString("-",50,true,"-"));
			logger.error("\u0023\u5f00\u59cb\u751f\u6210\u975e\u4e2a\u6027\u5316\u5236\u5361\u91c7\u8d2d\u6587\u4ef6");
			logger.error("#正在检查FTP配置信息");
			Map<String,String>  ftpOptions = this.initFtpOptions("make_card_task_to_vendor_admin");
			ftpClient = this.checkFtp(ftpOptions);
			if(Tools.processNull(ftpOptions.get("host_upload_path")).equals("")){
				throw new CommonException("获取ftp配置出错，ftp制卡数据存放路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_upload_path:" + ftpOptions.get("host_upload_path"));
			}
			ftpPath = "/vendor/" + vendorId + "/" + ftpOptions.get("host_upload_path");
			if(!(ftpClient.changeWorkingDirectory(ftpPath))){
				throw new CommonException("FTP切换到目录" + ftpPath + "失败！请检查FTP路径设置信息！");
			}else{
				logger.error("FTP目录切换正常");
			}
			logger.error("当前工作目录" + ftpClient.printWorkingDirectory());
			logger.error("FTP检查完毕");
			List<?> regionIdList = this.findBySql("select region_id from card_apply_task where task_id in (" + Tools.getConcatStrFromArray(taskIds,"'",",") + ") group by region_id");
			if(regionIdList != null && regionIdList.size() > 1){
				throw new CommonException("勾选的任务中包含有多个区域！");
			}
			if(regionIdList != null && regionIdList.size() == 1){
				regionId = Tools.processNull(regionIdList.get(0));
			}
			if(!Tools.processNull(regionId).equals("")){
				BaseRegion baseRegion = (BaseRegion) this.findOnlyRowByHql("from BaseRegion where regionId = '" + regionId + "'");
				if(baseRegion == null){
					throw new CommonException("根据区域编号" + regionId + "找不到区域信息！");
				}else{
					regionName = baseRegion.getRegionName();
				}
			}
			if(!Tools.processNull(bankId).equals("")){
				BaseBank baseBank = (BaseBank) this.findOnlyRowByHql("from BaseBank where bankId = '" + bankId + "'");
				if(baseBank == null){
					throw new CommonException("根据银行编号" + bankId + "找不到银行信息！");
				}else{
					bankName = baseBank.getBankName();
				}
			}
			
			
			List<?> cardTypeAndUrgList = this.findBySql("select card_type,is_urgent from card_apply_task where task_id in (" + Tools.getConcatStrFromArray(taskIds,"'",",") + ") group by card_type,is_urgent");
			if(cardTypeAndUrgList == null || cardTypeAndUrgList.size() < 1){
				throw new CommonException("采购任务信息不存在，请仔细核对后重试！");
			}
			if(cardTypeAndUrgList.size() > 1){
				throw new CommonException("勾选的任务中包含多种卡类型或多种制卡方式，请选择同一种卡类型，同一种制卡方式的任务进行导出！");
			}
			Object[] cardTypeAndUrgs = (Object[]) cardTypeAndUrgList.get(0);
			if(Tools.processNull(cardTypeAndUrgs[0]).equals("")){
				throw new CommonException("勾选的采购任务中找不到卡类型信息！");
			}else{
				cardType = Tools.processNull(cardTypeAndUrgs[0]);
			}
			if(Tools.processNull(cardTypeAndUrgs[1]).equals("")){
				throw new CommonException("勾选的采购任务中找不到制卡方式信息！");
			}else{
				isUrgent = Tools.processNull(cardTypeAndUrgs[1]);
			}
			if(!Tools.processNull(vendor.getMakeWay()).equals(isUrgent)){
				throw new CommonException("选择卡厂的制卡方式和任务的制卡方式不一致！");
			}
			CardTaskBatch taskBatch = new CardTaskBatch();
			taskBatch.setBatchId(this.getSequenceByName("seq_cm_card_task_batch"));
			taskBatch.setSendOrgId(oper.getOrgId());
			taskBatch.setSendBrchId(oper.getBrchId());
			taskBatch.setSendUserId(oper.getUserId());
			taskBatch.setSendDate(actionLog.getDealTime());
			taskBatch.setVendorId(vendorId);
			taskBatch.setMakeWay(isUrgent);
			taskBatch.setCardType(cardType);
			taskBatch.setVendorId(vendorId);
			fileName = bankName + "_" + this.getCodeNameBySYS_CODE("CARD_TYPE",cardType) + "_" + taskBatch.getBatchId() + "_" + DateUtil.formatDate(actionLog.getDealTime(),"yyyyMMddHHmmss");
			fileName = fileName + "_" + vendor.getVendorName() + "_S_" + this.getCodeNameBySYS_CODE("URGENT",isUrgent) + (Tools.processNull(regionName).equals("") ? "" : "_" + regionName) + ".txt";
			logger.error("生成非个性化制卡采购文件名:" + fileName);
			actionLog.setDealCode(DealCode.PUBLICCARD_EXPORT);
			actionLog.setMessage("非个性化制卡采购导出卡厂,批次号" + taskBatch.getBatchId());
			publicDao.save(actionLog);
			taskBatch.setDealNo(Integer.valueOf(actionLog.getDealNo() + ""));
			List<CardApplyTask> list = this.findByHql("from CardApplyTask where taskId in (" + Tools.getConcatStrFromArray(taskIds,"'",",") + ") and taskState <> '" + Constants.TASK_STATE_YSC + "'");
			if(list != null && list.size() > 0){
				throw new CommonException("勾选的采购任务中含有不是【任务已生成】状态的采购任务！");
			}
			list = this.findByHql("from CardApplyTask where taskId in (" + Tools.getConcatStrFromArray(taskIds,"'",",") + ") and taskState = '" + Constants.TASK_STATE_YSC + "'");
			if(list == null || list.size() <= 0){
				throw new CommonException("根据选定的任务编号，找不到对应任务信息！");
			}
			if(list.size() != taskIds.length){
				throw new CommonException("勾选的任务中有" + (taskIds.length - list.size()) + "个任务不是【" + this.getCodeNameBySYS_CODE("TASK_STATE",Constants.TASK_STATE_YSC) + "】状态！" );
			}
			//判断是否重复
			BigDecimal bgCount = (BigDecimal) this.findOnlyFieldBySql("select count(1) from card_task_list l where l.task_id in (" + Tools.getConcatStrFromArray(taskIds,"'",",") + ")"
					+ " and exists (select 1 from card_task_list d where d.card_no = l.card_no and d.data_seq <> l.data_seq)");
			if(bgCount.intValue() > 0){
				throw new CommonException("勾选的任务中卡号有重复，请联系系统管理员进行数据校对！");
			}
			logger.error("开始写入文件非个性化制卡采购数据");
			StringBuffer sbline = new StringBuffer();
			for(int i = 0;i < list.size();i++){
				CardApplyTask task = list.get(i);
				totNums = totNums + task.getTaskSum();
				StringBuffer execCardTaskListSql = new StringBuffer();
				execCardTaskListSql.append("select t.data_seq,t.task_id,t.card_no,t.struct_main_type,t.struct_child_type,t.cardissuedate,t.useflag,");
				execCardTaskListSql.append("t.bursestartdate,t.bursevaliddate,t.monthstartdate,t.monthvaliddate,t.month_type,t.bursebalance,t.monthbalance from card_task_list t ");
				execCardTaskListSql.append("where t.task_id = '" + task.getTaskId() + "'");
				List<Object[]> allRes = this.findBySql(execCardTaskListSql.toString());
				sbline.append(Tools.tensileString("-",10,true,"-") + Constants.NEWLINE);//任务分隔符
				sbline.append(task.getTaskId() + "|" + task.getTaskSum() + "|" + Constants.NEWLINE);
				if(allRes != null && allRes.size() > 0){
					if(allRes.size() != task.getTaskSum()){
						throw new CommonException("在导出任务【" + task.getTaskName() + "】时，制卡明细数量和任务数量不一致！");
					}
					if(Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_JMK_BCP)){
                        for(int m = 0;m < allRes.size();m++){
                            Object[] tempRow = allRes.get(m);
                            sbline.append(Tools.processNull(tempRow[0]) + "|");
                            sbline.append(Tools.processNull(tempRow[1]) + "|");
                            sbline.append(Tools.processNull(tempRow[2]) + "|");
                            sbline.append(Constants.NEWLINE);
                        }
                    }else if(Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_FJMK) || Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_FJMK_XS)){
                        for(int m = 0;m < allRes.size();m++){
                            Object[] tempRow = allRes.get(m);
                            sbline.append(Tools.processNull(tempRow[0]) + "|");
                            sbline.append(Tools.processNull(tempRow[1]) + "|");
                            sbline.append(Tools.processNull(tempRow[2]) + "|");
                            sbline.append(Tools.processNull(tempRow[3]) + "|");
                            sbline.append(Tools.processNull(tempRow[4]) + "|");
                            sbline.append(Tools.processNull(tempRow[5]) + "|");
                            sbline.append(Tools.processNull(tempRow[6]) + "|");
                            sbline.append(Tools.processNull(tempRow[7]) + "|");
                            sbline.append(Tools.processNull(tempRow[8]) + "|");
                            sbline.append(Tools.processNull(tempRow[9]) + "|");
                            sbline.append(Tools.processNull(tempRow[10]) + "|");
                            sbline.append(Tools.processNull(tempRow[11]) + "|");
                            sbline.append(Tools.processNull(tempRow[12]) + "|");
                            sbline.append(Tools.processNull(tempRow[13]) + "|");
                            sbline.append(Constants.NEWLINE);
                        }
                    }
				}else{
					throw new CommonException("在导出任务【" + task.getTaskName() + "】时，找不到制卡明细信息！");
				}
				int c = publicDao.doSql("update card_apply_task set task_state = '" + Constants.TASK_STATE_ZKZ + "',vendor_id = '" + vendorId + "',"
				+ "make_batch_id = '" + taskBatch.getBatchId() + "' where task_id = '" + task.getTaskId() + "' and task_state = '" + Constants.TASK_STATE_YSC + "'");
				if(c != 1){
					throw new CommonException("在导出任务" + task.getTaskName() + "时，更新任务状态为制卡中出现错误，更新" + c + "条！");
				}
				if(Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_FJMK) || Tools.processNull(task.getCardType()).equals(Constants.CARD_TYPE_FJMK_XS)){
                    this.publicDao.doSql("update card_fjmk_sale_list set make_batch_id = '" + taskBatch.getBatchId() + "' where task_id = '" + task.getTaskId() + "'");
                }
			}
			taskBatch.setTaskNum(list.size());
			taskBatch.setBatchNum(totNums);
			publicDao.save(taskBatch);
			StringBuffer taskHeader = new StringBuffer();
			if(Tools.processNull(cardType).equals(Constants.CARD_TYPE_JMK_BCP)){
				taskHeader.append("task_id|recordcount|" + Constants.NEWLINE);
				taskHeader.append("data_seq|task_id|card_no|" + Constants.NEWLINE);
			}else if(Tools.processNull(cardType).equals(Constants.CARD_TYPE_FJMK) || Tools.processNull(cardType).equals(Constants.CARD_TYPE_FJMK_XS)){
				taskHeader.append(this.getSysConfigurationParameters("export_makecarddata_taskcolumn_fjmk") + Constants.NEWLINE);
				taskHeader.append(this.getSysConfigurationParameters("export_makecarddata_datacolumn_fjmk") + Constants.NEWLINE);
			}else{
				taskHeader.append("task_id|recordcount|" + Constants.NEWLINE);
				taskHeader.append("data_seq|task_id|card_no|" + Constants.NEWLINE);
			}
			logger.error("开始上传文件" + fileName +  "...");
			os = ftpClient.storeFileStream(fileName.replace("txt","zip"));
			zip = new ZipArchiveOutputStream(os);
			zip.setEncoding("GBK");
			zip.setComment("卡厂制卡文件_" + fileName);
			ByteArrayInputStream  fileConts = new ByteArrayInputStream(taskHeader.append(sbline).toString().getBytes("GBK"));
			ZipArchiveEntry tarFile = new ZipArchiveEntry(fileName);
			zip.putArchiveEntry(tarFile);
			byte[] buf = new byte[1024 * 1024];
			int pos = 0;
			while((pos = fileConts.read(buf)) != -1) {
				zip.write(buf,0,pos);					
			}
			zip.closeArchiveEntry();
			zip.finish();
			zip.flush();
			os.flush();
			os.close();
			os = null;
			zip.close();
			zip = null;
			if(!(FTPReply.isPositiveCompletion(ftpClient.getReply()))){
				throw new CommonException("\u6587\u4ef6\u4e0a\u4f20\u5931\u8d25\uff0c\u8bf7\u68c0\u67e5\u0046\u0054\u0050\u8bbe\u7f6e\u4fe1\u606f\uff01");
			}
			logger.error("\u6587\u4ef6" + fileName + "\u4e0a\u4f20\u6210\u529f\uff01");
			TrServRec rec =  new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealCode(actionLog.getDealCode());
			rec.setOrgId(actionLog.getOrgId());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(this.getClrDate());
			rec.setNote(actionLog.getMessage());
			rec.setCardAmt(Long.valueOf(totNums));
			rec.setCardType(cardType);
			rec.setBizTime(actionLog.getDealTime());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			logger.error(e.getMessage());
			throw new CommonException(e.getMessage());
		}finally{
			logger.error("\u7ed3\u675f\u975e\u4e2a\u6027\u5316\u5236\u5361\u91c7\u8d2d\u5bfc\u51fa");
			try{
				if(zip != null){
					zip.close();
					zip = null;
				}
				if(os != null){
					os.close();
					os = null;
				}
				if(ftpClient != null){
					ftpClient.logout();
					ftpClient.disconnect();
				}
			}catch(Exception e1){
				
			}
		}
	}
	/**
	 * 非个性化采购数据导入
	 * @param is 文件内容
	 * @param user 操作用户
	 * @param log 操作日志
	 * @return 导入数量
	 * @throws CommonException
	 */
	public long saveImportFgxhCgData(InputStream is,Users oper,SysActionLog log) throws CommonException{
		try{
			if(is == null){
				throw new CommonException("文件内容不能空！");
			}
			BufferedReader br = new BufferedReader(new InputStreamReader(is,"GBK"));
			String firstRow = br.readLine();
			String import_makecarddata_taskcolumn_390 = this.getSysConfigurationParameters("import_makecarddata_taskcolumn_390");
			String import_makecarddata_datacolumn_390 = this.getSysConfigurationParameters("import_makecarddata_datacolumn_390");	
			if(!Tools.processNull(firstRow).toLowerCase().equals(import_makecarddata_taskcolumn_390)){
				throw new CommonException("文件第1行中任务字段说明不正确！");
			}
			String secRow = br.readLine();
			if(!Tools.processNull(secRow).toLowerCase().equals(import_makecarddata_datacolumn_390)){
				throw new CommonException("文件第2行中数据字段说明不正确！");
			}
			log.setDealCode(DealCode.PUBLICCARD_IMPORT);
			log.setMessage("非个性化采购数据导入");
			this.publicDao.save(log);
			this.publicDao.doSql("DELETE FROM CARD_TASK_IMP_BCP_TMP T WHERE T.BRCH_ID = '" + oper.getBrchId() + "' AND T.USER_ID = '" + oper.getUserId() + "'");
			String drBatchId = this.getSequenceByName("SEQ_CM_CARD_TASK_IMPORT");
			int fileRowNum = 2;
			int oneTaskSum = 0;
			int oneTaskRowNum = 0;
			int batchTotalNum = 0;
			String tempMakeBatchId = "";
			String tempTaskId = "";
			String tempRow = "";
			StringBuffer sb =  new StringBuffer();
			while((tempRow = br.readLine()) != null){
				fileRowNum++;
				if(tempRow.startsWith("-")){
					if(sb != null && sb.length() > 0){
						publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + sb.substring(0,sb.length() - 1) + "))");
						sb = new StringBuffer();
					}
					if(oneTaskRowNum > 0 && oneTaskRowNum != oneTaskSum){
						throw new CommonException("导入的制卡文件中任务编号为【" + tempTaskId + "】的制卡任务，实际制卡明细数量和原制卡任务数量不一致！");
					}
					oneTaskRowNum = 0;
					String taskColumnDefine = br.readLine();
					fileRowNum++;
					String[] taskColumns = Tools.processNull(taskColumnDefine).split("\\|");
					Object[] tempTaskMsg = (Object[]) this.findOnlyRowBySql("SELECT MAKE_BATCH_ID,CARD_TYPE,TASK_STATE,TASK_SUM FROM "
					+ "CARD_APPLY_TASK WHERE TASK_ID = '" + Tools.processNull(taskColumns[0]) + "'");
					if(tempTaskMsg == null || tempTaskMsg.length <= 0){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务信息不存在，位置在导入文件第" + fileRowNum + "行数据！");
					}
					if(!Tools.processNull(tempTaskMsg[2]).equals(Constants.TASK_STATE_ZKZ)){
						throw new CommonException("导入制卡文件中任务编号【" + Tools.processNull(taskColumns[0]) + "】的制卡任务状态不正确或采购数据已导入不能重复导入,位置在导入文件第" + fileRowNum + "行数据！");
					}
					if(!Tools.processNull(tempTaskMsg[3]).equals(Tools.processNull(taskColumns[1]))){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务，任务说明字段中制卡数量和导出制卡数量不一致，位置在导入文件第" + fileRowNum + "行数据！");
					}
					if(!Tools.processNull(tempMakeBatchId).equals("") && !Tools.processNull(tempTaskMsg[0]).equals(tempMakeBatchId)){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务，所属制卡批次和上一个任务的制卡批次不一致，位置在导入文件第" + fileRowNum + "行数据！");
					}
					if(!Tools.processNull(tempTaskMsg[1]).equals(Constants.CARD_TYPE_JMK_BCP)){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务，不是非个性化采购任务，位置在导入文件第" + fileRowNum + "行数据！");
					}
					tempMakeBatchId = tempTaskMsg[0].toString();
					tempTaskId = taskColumns[0];
					oneTaskSum = Integer.parseInt(taskColumns[1]);
					int upStockCount = publicDao.doSql("UPDATE STOCK_ACC  T SET T.TOT_NUM = NVL(T.TOT_NUM,0) + '" + oneTaskSum + "',T.LAST_DEAL_DATE = TO_DATE('" + 
					DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','YYYY-MM-DD HH24:MI:SS') WHERE " +
					"T.ORG_ID = '" + oper.getOrgId() + "' AND T.BRCH_ID = '" + oper.getBrchId() + "' AND  T.USER_ID = '" + oper.getUserId() + "' " +
					"AND T.STK_CODE = '1" +  Tools.processNull(tempTaskMsg[1]) + "' AND T.GOODS_STATE = '" + Constants.STATE_ZC + "'"
					);
					if(upStockCount != 1){
						throw new CommonException("柜员库存分账户不存在！");
					}
					upStockCount = this.publicDao.doSql("update card_apply_task set task_state = '" + Constants.TASK_STATE_YJS + "' where card_type = '" + Constants.CARD_TYPE_JMK_BCP + "' and task_id = '" + Tools.processNull(taskColumns[0]) + "'");
					if(upStockCount != 1){
						throw new CommonException("更新任务编号" + Tools.processNull(taskColumns[0]) + "的采购状态时出现错误！");
					}
					continue;
				}
				oneTaskRowNum++;
				batchTotalNum++;
				sb = createImportFgxhCgData(drBatchId,tempMakeBatchId,tempTaskId,tempRow,oneTaskRowNum,sb,oper,log);
			}
			if(sb != null && sb.length() > 0){
				publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + sb.substring(0,sb.length() - 1) + "))");
			}
			if(oneTaskRowNum > 0 && oneTaskRowNum != oneTaskSum){
				throw new CommonException("任务编号" + tempTaskId + "的制卡任务，实际制卡明细数量和原制卡任务数量不一致！");
			}
			BigDecimal hasImportCount =  (BigDecimal)this.findOnlyFieldBySql("SELECT COUNT(1) FROM CARD_TASK_IMP_BCP_TMP T,CARD_TASK_IMP_BCP C WHERE "
			+ "T.CARD_NO = C.CARD_NO AND T.BANK_CARD_NO = C.BANK_CARD_NO AND T.DR_BATCH_ID = '" + drBatchId + "'");
			if(hasImportCount.intValue() != 0){
				throw new CommonException("当前制卡导入的文件中已经有" + hasImportCount.intValue() + "条数据已经导入，请不要重复进行导入！");
			}
			BigDecimal batchTotAmt = (BigDecimal)this.findOnlyFieldBySql("SELECT SUM(T.TASK_SUM) FROM CARD_APPLY_TASK T WHERE T.MAKE_BATCH_ID = '" + tempMakeBatchId + "'");
			if(batchTotAmt.intValue() < batchTotalNum){
				throw new CommonException("当前制卡导入文件的制卡明细数量不能大于该批次的制卡明细数量！");
			}
			BigDecimal judgeSucNum = (BigDecimal)this.findOnlyFieldBySql("SELECT COUNT(1) FROM CARD_TASK_IMP_BCP_TMP T,CARD_TASK_LIST L WHERE "
			+ "T.TASK_ID = L.TASK_ID AND T.DATA_SEQ = L.DATA_SEQ AND T.CARD_NO = L.CARD_NO AND T.DR_BATCH_ID = '" + drBatchId + "'");
			if(judgeSucNum.intValue() != batchTotalNum){
				throw new CommonException("当前文件中有" + (batchTotalNum - judgeSucNum.intValue()) + "条数据的不是非个性化采购数据，请校验文件");
			}
			int importCount = publicDao.doSql("insert into card_task_imp_bcp(task_id,data_seq,card_id,card_type,card_no,bank_card_no,bank_certificate_no,state," +
				"dr_batch_id,batch_id,org_id,brch_id,user_id,imp_date)  select task_id, data_seq,card_id,card_type,card_no,bank_card_no,bank_certificate_no,state,"
				+ "dr_batch_id,batch_id,org_id,brch_id,user_id,imp_date from card_task_imp_bcp_tmp where dr_batch_id = '" + drBatchId + "'"
			);
			if(importCount != batchTotalNum){
				throw new CommonException("导入正式表的数量不正确！");
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage());
			rec.setClrDate(this.getClrDate());
			rec.setBizTime(log.getDealTime());
			rec.setOrgId(oper.getOrgId());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setCardAmt(Long.valueOf(batchTotalNum));
			this.publicDao.save(rec);
			return batchTotalNum;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 组装非个性化制卡数据导入的SQL
	 * @param drBatchId
	 * @param batchId
	 * @param taskId
	 * @param tempRow
	 * @param rowNum
	 * @param sb
	 * @param oper
	 * @param log
	 * @return
	 * @throws CommonException
	 */
	private StringBuffer createImportFgxhCgData1(String drBatchId,String batchId,String taskId,String tempRow,int rowNum,StringBuffer sb,Users oper,SysActionLog log) throws CommonException{
		try{
			if(Tools.processNull(tempRow).equals("")){
				throw new CommonException("第" + rowNum + "行内容为空，无法进行解析！");
			}
			String[] tempColumns = new String[6];
			String[] srcColumns = tempRow.split("\\|");
			System.arraycopy(srcColumns, 0, tempColumns, 0,srcColumns.length);
			if(!Tools.processNull(taskId).equals(tempColumns[1])){
				throw new CommonException("导入文件中任务编号为【" + taskId + "】的任务，第" + rowNum + "条的数据任务编号和任务说明中的任务编号不一致！");
			}
			sb.append("'insert into card_task_imp_bcp_tmp(data_seq,task_id,card_id,card_type,card_no,bank_card_no,bank_certificate_no,");
			sb.append("state,org_id,brch_id,user_id,imp_date,batch_id,dr_batch_id) values (");
			sb.append("''" + Tools.processNull(tempColumns[0]) + "'',");//任务明细号
			sb.append("''" + Tools.processNull(tempColumns[1]) + "'',");//任务号
			sb.append("''" + Tools.processNull(tempColumns[3]) + "'',");//card_id
			sb.append("''" + Tools.processNull(Constants.CARD_TYPE_JMK_BCP) + "'',");//卡类型
			sb.append("''" + Tools.processNull(tempColumns[2]) + "'',");//卡号
			sb.append("''" + Tools.processNull("") + "'',");//银行卡卡号
			sb.append("''" + Tools.processNull("") + "'',");//银行凭证号
			sb.append("''" + Tools.processNull("1") + "'',");//状态
			sb.append("''" + Tools.processNull(oper.getOrgId()) + "'',");//机构
			sb.append("''" + Tools.processNull(oper.getBrchId()) + "'',");//网点
			sb.append("''" + Tools.processNull(oper.getUserId()) + "'',");//柜员
			sb.append("to_date(''" + Tools.processNull(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss")) + "'',''yyyy-mm-dd hh24:mi:ss''),");//导入时间
			sb.append("''" + Tools.processNull(batchId) + "'',");//批次号
			sb.append("''" + Tools.processNull(drBatchId) + "''");//导入临时批次号
			sb.append(")',");
			if(rowNum% 500 == 0){
				publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + sb.substring(0,sb.length() - 1) + "))");
				sb = new StringBuffer();
			}
			return sb;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 非个性化采购数据导入
	 * @param is 文件内容
	 * @param user 操作用户
	 * @param log 操作日志
	 * @return 导入数量
	 * @throws CommonException
	 */
	public long saveImportFgxhCgData1(InputStream is,Users oper,SysActionLog log) throws CommonException{
		try{
			if(is == null){
				throw new CommonException("文件内容不能空！");
			}
			BufferedReader br = new BufferedReader(new InputStreamReader(is,"GBK"));
			String firstRow = br.readLine();
			String import_makecarddata_taskcolumn_390 = this.getSysConfigurationParameters("import_makecarddata_taskcolumn_390");
			String import_makecarddata_datacolumn_390 = this.getSysConfigurationParameters("import_makecarddata_datacolumn_390");	
			if(!Tools.processNull(firstRow).toLowerCase().equals(import_makecarddata_taskcolumn_390)){
				throw new CommonException("文件第1行中任务字段说明不正确！");
			}
			String secRow = br.readLine();
			if(!Tools.processNull(secRow).toLowerCase().equals(import_makecarddata_datacolumn_390)){
				throw new CommonException("文件第2行中数据字段说明不正确！");
			}
			log.setDealCode(DealCode.PUBLICCARD_IMPORT);
			log.setMessage("非个性化采购数据导入");
			this.publicDao.save(log);
			this.publicDao.doSql("DELETE FROM CARD_TASK_IMP_BCP_TMP T WHERE T.BRCH_ID = '" + oper.getBrchId() + "' AND T.USER_ID = '" + oper.getUserId() + "'");
			String drBatchId = this.getSequenceByName("SEQ_CM_CARD_TASK_IMPORT");
			int fileRowNum = 2;
			int oneTaskSum = 0;
			int oneTaskRowNum = 0;
			int batchTotalNum = 0;
			String tempMakeBatchId = "";
			String tempTaskId = "";
			String tempRow = "";
			StringBuffer sb =  new StringBuffer();
			while((tempRow = br.readLine()) != null){
				fileRowNum++;
				if(tempRow.startsWith("-")){
					if(sb != null && sb.length() > 0){
						publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + sb.substring(0,sb.length() - 1) + "))");
						sb = new StringBuffer();
					}
					if(oneTaskRowNum > 0 && oneTaskRowNum != oneTaskSum){
						throw new CommonException("导入的制卡文件中任务编号为【" + tempTaskId + "】的制卡任务，实际制卡明细数量和原制卡任务数量不一致！");
					}
					oneTaskRowNum = 0;
					String taskColumnDefine = br.readLine();
					fileRowNum++;
					String[] taskColumns = Tools.processNull(taskColumnDefine).split("\\|");
					Object[] tempTaskMsg = (Object[]) this.findOnlyRowBySql("SELECT MAKE_BATCH_ID,CARD_TYPE,TASK_STATE,TASK_SUM FROM "
					+ "CARD_APPLY_TASK WHERE TASK_ID = '" + Tools.processNull(taskColumns[0]) + "'");
					if(tempTaskMsg == null || tempTaskMsg.length <= 0){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务信息不存在，位置在导入文件第" + fileRowNum + "行数据！");
					}
					if(!Tools.processNull(tempTaskMsg[2]).equals(Constants.TASK_STATE_ZKZ)){
						throw new CommonException("导入制卡文件中任务编号【" + Tools.processNull(taskColumns[0]) + "】的制卡任务状态不正确或采购数据已导入不能重复导入,位置在导入文件第" + fileRowNum + "行数据！");
					}
					if(!Tools.processNull(tempTaskMsg[3]).equals(Tools.processNull(taskColumns[1]))){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务，任务说明字段中制卡数量和导出制卡数量不一致，位置在导入文件第" + fileRowNum + "行数据！");
					}
					if(!Tools.processNull(tempMakeBatchId).equals("") && !Tools.processNull(tempTaskMsg[0]).equals(tempMakeBatchId)){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务，所属制卡批次和上一个任务的制卡批次不一致，位置在导入文件第" + fileRowNum + "行数据！");
					}
					if(!Tools.processNull(tempTaskMsg[1]).equals(Constants.CARD_TYPE_JMK_BCP)){
						throw new CommonException("导入制卡文件中任务编号为【" + Tools.processNull(taskColumns[0]) + "】的制卡任务，不是非个性化采购任务，位置在导入文件第" + fileRowNum + "行数据！");
					}
					tempMakeBatchId = tempTaskMsg[0].toString();
					tempTaskId = taskColumns[0];
					oneTaskSum = Integer.parseInt(taskColumns[1]);
					int upStockCount = publicDao.doSql("UPDATE STOCK_ACC  T SET T.TOT_NUM = NVL(T.TOT_NUM,0) + '" + oneTaskSum + "',T.LAST_DEAL_DATE = TO_DATE('" + 
					DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','YYYY-MM-DD HH24:MI:SS') WHERE " +
					"T.ORG_ID = '" + oper.getOrgId() + "' AND T.BRCH_ID = '" + oper.getBrchId() + "' AND  T.USER_ID = '" + oper.getUserId() + "' " +
					"AND T.STK_CODE = '1" +  Tools.processNull(tempTaskMsg[1]) + "' AND T.GOODS_STATE = '" + Constants.STATE_ZC + "'"
					);
					if(upStockCount != 1){
						throw new CommonException("柜员库存分账户不存在！");
					}
					upStockCount = this.publicDao.doSql("update card_apply_task set task_state = '" + Constants.TASK_STATE_YJS + "' where card_type = '" + Constants.CARD_TYPE_JMK_BCP + "' and task_id = '" + Tools.processNull(taskColumns[0]) + "'");
					if(upStockCount != 1){
						throw new CommonException("更新任务编号" + Tools.processNull(taskColumns[0]) + "的采购状态时出现错误！");
					}
					continue;
				}
				oneTaskRowNum++;
				batchTotalNum++;
				sb = createImportFgxhCgData(drBatchId,tempMakeBatchId,tempTaskId,tempRow,oneTaskRowNum,sb,oper,log);
			}
			if(sb != null && sb.length() > 0){
				publicDao.doSql("CALL PK_PUBLIC.P_DEALSQLBYARRAY(STRARRAY(" + sb.substring(0,sb.length() - 1) + "))");
			}
			if(oneTaskRowNum > 0 && oneTaskRowNum != oneTaskSum){
				throw new CommonException("任务编号" + tempTaskId + "的制卡任务，实际制卡明细数量和原制卡任务数量不一致！");
			}
			BigDecimal hasImportCount =  (BigDecimal)this.findOnlyFieldBySql("SELECT COUNT(1) FROM CARD_TASK_IMP_BCP_TMP T,CARD_TASK_IMP_BCP C WHERE "
			+ "T.CARD_NO = C.CARD_NO AND T.BANK_CARD_NO = C.BANK_CARD_NO AND T.DR_BATCH_ID = '" + drBatchId + "'");
			if(hasImportCount.intValue() != 0){
				throw new CommonException("当前制卡导入的文件中已经有" + hasImportCount.intValue() + "条数据已经导入，请不要重复进行导入！");
			}
			BigDecimal batchTotAmt = (BigDecimal)this.findOnlyFieldBySql("SELECT SUM(T.TASK_SUM) FROM CARD_APPLY_TASK T WHERE T.MAKE_BATCH_ID = '" + tempMakeBatchId + "'");
			if(batchTotAmt.intValue() < batchTotalNum){
				throw new CommonException("当前制卡导入文件的制卡明细数量不能大于该批次的制卡明细数量！");
			}
			BigDecimal judgeSucNum = (BigDecimal)this.findOnlyFieldBySql("SELECT COUNT(1) FROM CARD_TASK_IMP_BCP_TMP T,CARD_TASK_LIST L WHERE "
			+ "T.TASK_ID = L.TASK_ID AND T.DATA_SEQ = L.DATA_SEQ AND T.CARD_NO = L.CARD_NO AND T.DR_BATCH_ID = '" + drBatchId + "'");
			if(judgeSucNum.intValue() != batchTotalNum){
				throw new CommonException("当前文件中有" + (batchTotalNum - judgeSucNum.intValue()) + "条数据的不是非个性化采购数据，请校验文件");
			}
			int importCount = publicDao.doSql("insert into card_task_imp_bcp(task_id,data_seq,card_id,card_type,card_no,bank_card_no,bank_certificate_no,state," +
				"dr_batch_id,batch_id,org_id,brch_id,user_id,imp_date)  select task_id, data_seq,card_id,card_type,card_no,bank_card_no,bank_certificate_no,state,"
				+ "dr_batch_id,batch_id,org_id,brch_id,user_id,imp_date from card_task_imp_bcp_tmp where dr_batch_id = '" + drBatchId + "'"
			);
			if(importCount != batchTotalNum){
				throw new CommonException("导入正式表的数量不正确！");
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage());
			rec.setClrDate(this.getClrDate());
			rec.setBizTime(log.getDealTime());
			rec.setOrgId(oper.getOrgId());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setCardAmt(Long.valueOf(batchTotalNum));
			this.publicDao.save(rec);
			return batchTotalNum;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	
	/**
	 * 组装非个性化制卡数据导入的SQL
	 * @param drBatchId
	 * @param batchId
	 * @param taskId
	 * @param tempRow
	 * @param rowNum
	 * @param sb
	 * @param oper
	 * @param log
	 * @return
	 * @throws CommonException
	 */
	private StringBuffer createImportFgxhCgData(String drBatchId,String batchId,String taskId,String tempRow,int rowNum,StringBuffer sb,Users oper,SysActionLog log) throws CommonException{
		try{
			if(Tools.processNull(tempRow).equals("")){
				throw new CommonException("第" + rowNum + "行内容为空，无法进行解析！");
			}
			String[] tempColumns = new String[5];
			String[] srcColumns = tempRow.split("\\|");
			System.arraycopy(srcColumns, 0, tempColumns, 0,srcColumns.length);
			if(!Tools.processNull(taskId).equals(tempColumns[1])){
				throw new CommonException("导入文件中任务编号为【" + taskId + "】的任务，第" + rowNum + "条的数据任务编号和任务说明中的任务编号不一致！");
			}
			sb.append("'insert into card_task_imp_bcp_tmp(data_seq,task_id,card_id,card_type,card_no,bank_card_no,bank_certificate_no,");
			sb.append("state,org_id,brch_id,user_id,imp_date,batch_id,dr_batch_id) values (");
			sb.append("''" + Tools.processNull(tempColumns[0]) + "'',");//任务明细号
			sb.append("''" + Tools.processNull(tempColumns[1]) + "'',");//任务号
			sb.append("''" + Tools.processNull("") + "'',");//card_id
			sb.append("''" + Tools.processNull(Constants.CARD_TYPE_JMK_BCP) + "'',");//卡类型
			sb.append("''" + Tools.processNull(tempColumns[2]) + "'',");//卡号
			sb.append("''" + Tools.processNull(tempColumns[3]) + "'',");//银行卡卡号
			sb.append("''" + Tools.processNull(tempColumns[4]) + "'',");//银行凭证号
			sb.append("''" + Tools.processNull("1") + "'',");//状态
			sb.append("''" + Tools.processNull(oper.getOrgId()) + "'',");//机构
			sb.append("''" + Tools.processNull(oper.getBrchId()) + "'',");//网点
			sb.append("''" + Tools.processNull(oper.getUserId()) + "'',");//柜员
			sb.append("to_date(''" + Tools.processNull(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss")) + "'',''yyyy-mm-dd hh24:mi:ss''),");//导入时间
			sb.append("''" + Tools.processNull(batchId) + "'',");//批次号
			sb.append("''" + Tools.processNull(drBatchId) + "''");//导入临时批次号
			sb.append(")',");
			if(rowNum % 500 == 0){
				publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + sb.substring(0,sb.length() - 1) + "))");
				sb = new StringBuffer();
			}
			return sb;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 检查ＦＴＰ配置信息
	 * @param ftpOptions ftp配置信息
	 * @return ＦＴＰ客户端
	 * @throws CommonException
	 */
	public DefaultFTPClient checkFtp(Map<String,String> ftpOptions) throws Exception{
		DefaultFTPClient client = null;
		if(Tools.processNull(ftpOptions.get("url")).equals("")){
			throw new CommonException("获取ftp配置出错，ftp地址未配置，请联系系统管理员！");
		}else{
			logger.error("ip:" + ftpOptions.get("url"));
		}
		if(Tools.processNull(ftpOptions.get("port")).equals("")){
			throw new CommonException("获取ftp配置出错，ftp端口未配置，请联系系统管理员！");
		}else{
			logger.error("port:" + ftpOptions.get("port"));
		}
		if(Tools.processNull(ftpOptions.get("userName")).equals("")){
			throw new CommonException("获取ftp配置出错，ftp用户名未配置，请联系系统管理员！");
		}else{
			logger.error("name:" + ftpOptions.get("userName"));
		}
		if(Tools.processNull(ftpOptions.get("pwd")).equals("")){
			throw new CommonException("获取ftp配置出错，ftp密码未配置，请联系系统管理员！");
		}else{
			logger.error("pwd:" + ftpOptions.get("pwd"));
		}
		client = new DefaultFTPClient();
		if(!client.toConnect(ftpOptions.get("url"),Integer.valueOf(ftpOptions.get("port")))){
			throw new CommonException("FTP连接失败！");
		}else{
			logger.error("FTP连接正常");
		}
		if(!client.toLogin(ftpOptions.get("userName"),ftpOptions.get("pwd"))){
			throw new CommonException("FTP登录失败！");
		}else{
			logger.error("FTP登录正常");
		}
		client.setControlEncoding("GBK");
		client.setFileTransferMode(DefaultFTPClient.STREAM_TRANSFER_MODE);
		client.setFileType(DefaultFTPClient.BINARY_FILE_TYPE);

		return client;
	}
	/**
	 * 获取FTP配置信息
	 * @param ftp_use
	 * @return map 参数信息
	 * @param host_ip 主机地址
	 * @param host_port 端口号
	 * @param host_upload_path 上传路径
	 * @param host_download_path 下载路径
	 * @param host_history_path 历史目录
	 * @param user_name 用户名
	 * @param pwd 密码
	 */
	public Map<String,String> initFtpOptions(String ftp_use) throws CommonException {
		try{
			Map<String,String> res = new HashMap<String, String>();
			List<?> ftpPara = this.findBySql("select t.ftp_para_name,t.ftp_para_value from SYS_FTP_CONF t "
			+ "where t.ftp_use = '" + ftp_use + "'");
			if(ftpPara == null || ftpPara.size() <= 0){
				throw new CommonException("获取ftp配置出错，请联系系统管理员！");
			}
			for(int k = 0;k < ftpPara.size();k++){
				Object[] objs = (Object[])ftpPara.get(k);
				if(Tools.processNull(objs[0]).equals("host_ip")){
					res.put("url",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_upload_path")){
					res.put("host_upload_path",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_download_path")){
					res.put("host_download_path",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_history_path")){
					res.put("host_history_path",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("host_port")){
					res.put("port",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("pwd")){
					res.put("pwd",Tools.processNull(objs[1]));
				}else if(Tools.processNull(objs[0]).equals("user_name")){
					res.put("userName",Tools.processNull(objs[1]));
				}
			}
			return res;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	
	@Autowired
	public void setCardApplyService(CardApplyService cardApplyService) {
		this.cardApplyService = cardApplyService;
	}
	/**
	 * @return the cardApplyService
	 */
	public CardApplyService getCardApplyService() {
		return cardApplyService;
	}
	/**
	 * @return the doWorkClientService
	 */
	public DoWorkClientService getDoWorkClientService() {
		return doWorkClientService;
	}
	/**
	 * @param doWorkClientService the doWorkClientService to set
	 */
	@Resource(name="doWorkClientService")
	public void setDoWorkClientService(DoWorkClientService doWorkClientService) {
		this.doWorkClientService = doWorkClientService;
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public void saveImportTaskRhFileAuto() {
		try{
			logger.error("导入银行审核结果文件任务开始------------------------------------------------------------------------");
			Users user = (Users) findOnlyRowByHql("from Users where userId = 'admin'");
			SysActionLog log = new SysActionLog();
			log.setUserId(user.getUserId());
			log.setDealTime(getDateBaseTime());

			logger.error("获取 FTP 配置信息...");
			List<String> ftpList = findBySql("select distinct ftp_use from SYS_FTP_CONF t where ftp_use like 'make_card_task_to_bank_%'");
			if(ftpList==null||ftpList.isEmpty()){
				throw new CommonException("获取 FTP 配置列表失败, FTP 列表配置为空.");
			}
			logger.error("获取 FTP 配置成功, 共 " + ftpList.size() + " 条 FTP 配置 [" + ftpList + "]");
			
			
			for (int i = 0; i < ftpList.size(); i++) {
				String ftp = ftpList.get(i);
				DefaultFTPClient ftpClient = new DefaultFTPClient();
				int totNums = 0;
				int sucNums = 0;
				try {
					// 1. 检查 FTP
					logger.error("处理第 " + (i + 1) + " 个银行 [" + ftp + "] ...");
					Map<String, String> ftpOptions = initFtpOptions(ftp);
					ftpClient = checkFtp(ftpOptions);
					
					if (Tools.processNull(ftpOptions.get("host_upload_path")).equals("")) {
						throw new CommonException("获取 FTP 配置出错, FTP 上传文件路径未配置, 请联系系统管理员.");
					}
					logger.error("host_upload_path : " + ftpOptions.get("host_upload_path"));
					
					if (Tools.processNull(ftpOptions.get("host_history_path")).equals("")) {
						throw new CommonException("获取 FTP 配置出错, FTP 历史文件路径未配置, 请联系系统管理员.");
					}
					logger.error("host_history_path : " + ftpOptions.get("host_history_path"));

					if (!(ftpClient.changeWorkingDirectory("/") && ftpClient.changeWorkingDirectory(ftpOptions.get("host_history_path")) && ftpClient.changeWorkingDirectory(ftpOptions.get("host_upload_path")))) {
						throw new CommonException("FTP 切换目录失败, 请检查 FTP 路径设置信息.");
					}
					logger.error("当前工作目录 : " + ftpClient.printWorkingDirectory());

					// 2. 检查 FTP 文件
					logger.error("检查银行审核返回文件...");
					List<String> fileList = ftpClient.listNames(ftpOptions.get("host_upload_path") + "RH_*", 100);
					if (fileList == null || fileList.size() <= 0) {
						throw new CommonException("未查询到需要处理的银行返回文件.");
					}
					totNums = fileList.size();
					logger.error("检测到 " + totNums + " 个需要处理的文件.");
					
					// 3. 处理文件
					String bankId = ftp.substring(23);
					for (int j = 0; j < fileList.size(); j++) {
						try {
							logger.error("开始处理第 " + (j + 1) + " 个文件, 文件名 [" + fileList.get(j) + "]...");
							saveImportTaskRhFile(ftpClient, fileList.get(j).toString(), bankId, ftpOptions, user, log);
							sucNums++;
						} catch (Exception e) {
							logger.error("处理第 " + (j + 1) + " 个文件失败, " + e.getMessage());
							continue;
						}
					}
				} catch (Exception e) {
					logger.error("处理第 " + i + " 个银行失败, " + e.getMessage());
					continue;
				} finally {
					if(ftpClient.isAvailable()){
						try {
							ftpClient.logout();
							ftpClient.disconnect();
						} catch (Exception e) {
							logger.error("断开 FTP 连接出错", e);
						}
					}

					logger.error("第 " + i + " 个银行处理完成, 共 " + totNums + " 个需要处理的文件, 处理成功 " + sucNums + " 个.");
				}
			}
		} catch (Exception e) {
			logger.error("导入银行审核结果文件任务失败, " + e.getMessage());
			throw new CommonException("导入银行审核结果文件任务失败", e);
		}
	}
	@SuppressWarnings("unchecked")
	@Override
	public void saveTaskReceiveRegist(String taskId, TrServRec rec) {
		try {
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.CARD_RECEIVE_REGIST);
			log.setMessage("领卡登记");
			publicDao.save(log);
			
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.STATE_ZC);
			rec.setBizTime(log.getDealTime());
			rec.setNote(log.getMessage());
			rec.setOrgId(log.getOrgId());
			rec.setBrchId(log.getBrchId());
			rec.setUserId(log.getUserId());
			rec.setClrDate(getClrDate());
			rec.setRsvFive(taskId);
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException("领卡登记失败， " + e.getMessage());
		}
	}
}