package com.erp.action;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.CardApply;
import com.erp.model.CardApplyTask;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.service.CardIssuseService;
import com.erp.service.Switchservice;
import com.erp.util.Constants;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

@Namespace("/cardIssuse")
@Action(value="cardIssuseAction")
@Results({@Result(name="viewIssuse",location="/jsp/cardIssuse/viewIssuse.jsp")})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class CardIssuseAction extends BaseAction {
	private static Log log = LogFactory.getLog(CardIssuseAction.class);
	private static final long serialVersionUID = 1L;
	@Resource(name="cardIssuseService")
	private CardIssuseService cardIssuseService;
	private String queryType = "1";
	private TrServRec rec = new TrServRec();
	private CardApply apply = new CardApply();
	private BasePersonal person = new BasePersonal();
	private String madeCardBatchNo = "";
	private String madeCardTaskNo = "";
	private String applyId;
	private String taskIds = "";
	private String taskId = "";
	private String taskState = "";
	private String corpId = "";
	private String corpName;
	private String cardType = "";
	private String taskStartDate = "";
	private String taskEndDate = "";
	private String regionId = "";
	private String townId = "";
	private String commId = "";
	private String sort = "";
	private String order = "";
	private String customerIds = "";
	private String taskNum = "";
	private String dataSeqs = "";
	private String taskStateName = "";
	private String brchId = "";
	private String userId = "";
	private String issuseType = "0";
	private String isBatchHf = "";
	private boolean sync2Sb = false;
	@Autowired
	private Switchservice switchservice;
	/**
	 * 个人发放查询
	 * @return
	 */
	public String oneCardIssuseQuery(){
		try{
			initGridData();
			if(!this.queryType.equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT b.name,b.cert_no,t.task_id,k.make_batch_id,t.apply_id,t.customer_id,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'APPLY_STATE' AND CODE_VALUE = t.apply_state) applystate,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CERT_TYPE' AND CODE_VALUE = b.cert_type) certtype,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CARD_TYPE' AND CODE_VALUE = t.card_type) cardtype,");
			sb.append("(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = t.agt_cert_type) agt_cert_type, t.agt_cert_no, t.agt_name, t.agt_phone,");
			sb.append("t.card_no,DECODE(t.is_urgent,'0','本地制卡','1','外包制卡','其他') is_urgent,(SELECT CODE_NAME FROM SYS_CODE ");
			sb.append("WHERE CODE_TYPE = 'APPLY_TYPE' AND CODE_VALUE = t.apply_type) APPLYTYPE,DECODE(k.task_way,'0','网点','1','社区','2','单位','3','学校','其他') task_way, ");
			sb.append("(select code_name from sys_code where code_type = 'APPLY_WAY' and code_value = t.apply_way) applyway,");
			sb.append("(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = t.recv_cert_type) recv_cert_type,t.recv_cert_no,t.recv_name,t.RECV_PHONE, ");
			sb.append("nvl((select full_name from sys_branch where brch_id = t.rels_brch_id), t.rels_brch_id) brch_name, t.rels_user_id, t.rels_date, t.apply_state ");
			sb.append("FROM card_apply t,base_personal b,card_apply_task k ");
			sb.append("WHERE t.customer_id = b.customer_id AND t.task_id = k.task_id ");
			//sb.append("and t.apply_state = '" + Constants.APPLY_STATE_YJS + "' ");
			if(!Tools.processNull(apply.getApplyId()).equals("")){
				sb.append(" and t.apply_id = '" + apply.getApplyId() + "' ");
			}
			if(!Tools.processNull(person.getName()).equals("")){
				sb.append(" and b.name like '%" + person.getName() + "%' ");
			}
			if(!Tools.processNull(person.getCertNo()).equals("")){
				Object tempcusid = baseService.findOnlyFieldBySql("select t.customer_id from base_personal t where t.cert_no = '" + person.getCertNo() + "'");
				sb.append(" and b.cert_No = '" + person.getCertNo() + "' ");
				if(!Tools.processNull(tempcusid).equals("")){
					sb.append("and t.customer_id = '" + tempcusid.toString() + "' ");
				}
			}
			if(Tools.processNull(sort).equals("")){
				sb.append(" order by t.apply_date desc ");
			}else{
				sb.append(" order by " + sort + " " + order);
			}
			Page list = cardIssuseService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未找到对应申领记录信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 个人发放保存
	 * @return
	 */
	public String saveOneCardIssuse(){
		try{
			log.debug("个人发放，申领编号【" + applyId + "】");
			CardApply apply = (CardApply)baseService.findOnlyRowByHql("from CardApply a where a.applyId = " + applyId);//
			if(apply == null){
				throw new CommonException("申领信息不存在，无法进行个人发放！");
			} else if(Constants.APPLY_TYPE_HK.equals(apply.getApplyType())){
				jsonObject.put("isHk", true);
			} else if(Constants.CARD_TYPE_QGN.equals(apply.getCardType())){
				BigDecimal num = (BigDecimal) baseService.findOnlyFieldBySql("select count(1) from card_baseinfo t where t.card_type = '"
						+ Constants.CARD_TYPE_SMZK + "' and t.card_state = '" + Constants.CARD_STATE_WQY + "' and t.customer_id = '" + apply.getCustomerId() + "'");
				if (num.compareTo(BigDecimal.ZERO) > 0) {
					throw new CommonException("人员已经申领金融市民卡，不能再发放全功能卡！");
				}
			}
			log.debug("新卡卡号【" + apply.getCardNo() + "】");
			// 获取老卡
			CardBaseinfo oldCard = null;
			if (Constants.YES_NO_YES.equals(apply.getIsBatchHf())) {
				oldCard = (CardBaseinfo)baseService.findOnlyRowByHql("from CardBaseinfo where customerId = '" + apply.getCustomerId() + "' and cardState in ('1', '2', '3')");
				log.debug("换发卡，老卡【" + oldCard.getCardNo() + "】，" + oldCard.getCardState() + "】");
			}
			CardApplyTask task = (CardApplyTask)baseService.findOnlyRowByHql("from CardApplyTask c " + "where  c.taskId = '" + taskId + "'");
			if(task == null){
				throw new CommonException("所属任务信息不存在，无法进行个人发放！");
			}
			if((!task.getTaskState().equals(Constants.TASK_STATE_YJS) && !task.getTaskState().equals(Constants.TASK_STATE_FFZ))){
				throw new CommonException("所属任务不是【已接收】或【发卡中】状态，无法进行发放！");
			}
			apply.setRelsBrchId(this.getUsers().getBrchId());
			apply.setRelsUserId(this.getUserId());
			if(Tools.processNull(apply.getAgtCertType()).equals(Constants.CERT_TYPE_SFZ)&&Tools.processNull(apply.getAgtCertNo()).length()==15){
				apply.setAgtCertNo(rec.getAgtCertNo());
			}
			apply.setRecvCertType(rec.getAgtCertType());
			apply.setRecvCertNo(rec.getAgtCertNo());
			apply.setRecvName(rec.getAgtName());
			apply.setAgtPhone(rec.getAgtTelNo());
			CardBaseinfo card = (CardBaseinfo)baseService.findOnlyRowByHql("from CardBaseinfo where cardNo = '" + apply.getCardNo() + "'");
			if(card == null){
				throw new CommonException("卡片信息不存在，无法进行发放！");
			}
			if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_WQY)){
			    throw new CommonException("卡片不是【未启用】状态，不能进行发放操作！");
			}
			log.debug("新卡【" + card.getCardNo() + "，" + card.getCardState() + "】");
			CardApply tttt = (CardApply) BeanUtils.cloneBean(apply);
			TrServRec tempRec = cardIssuseService.saveOneCardIssuse(tttt,card);//进行实名制卡个人发放登
			Object[] newCardDbg = (Object[]) cardIssuseService.findOnlyRowBySql("select t.card_no, t.card_state, t2.apply_state from card_baseinfo t join card_apply t2 on t.card_no = t2.card_no where t.card_no = '" + card.getCardNo() + "'");
			log.debug("发放完成，新卡【" + newCardDbg[0] + "，" + newCardDbg[1] + "，" + newCardDbg[2] + "】");
			if (oldCard != null) {
				Object[] oldCardDbg = (Object[]) cardIssuseService.findOnlyRowBySql("select card_no, card_state from card_baseinfo where card_no = '" + oldCard.getCardNo() + "'");
				log.debug("发放完成，老卡【" + oldCardDbg[0] + "，" + oldCardDbg[1] + "】");
			}
			String message = "个人发放成功！";
			try {
				try {
					if(apply.getApplyType().equals(Constants.APPLY_TYPE_HK) || apply.getApplyType().equals(Constants.APPLY_TYPE_BK)){
						switchservice.updateCardState(apply.getOldCardNo(), Constants.CARD_STATE_ZC, Constants.CARD_STATE_ZX);
					} else if (Constants.YES_NO_YES.equals(apply.getIsBatchHf())){
						switchservice.updateCardState(oldCard.getCardNo(), Constants.CARD_STATE_ZC, Constants.CARD_STATE_ZX);
					}
				} catch (Exception e) {
					// 老卡注销，可能失败(没有上传省厅)
				}
				switchservice.sendCardData(tempRec.getCertNo());
			} catch (Exception e) {
				message += "同步省厅失败【" + e.getMessage() + "】，请手动同步！";
			}
			newCardDbg = (Object[]) cardIssuseService.findOnlyRowBySql("select card_no, card_state from card_baseinfo where card_no = '" + card.getCardNo() + "'");
			log.debug("同步省厅完成，新卡【" + newCardDbg[0] + "，" + newCardDbg[1] + "】");
			if (oldCard != null) {
				Object[] oldCardDbg = (Object[]) cardIssuseService.findOnlyRowBySql("select card_no, card_state from card_baseinfo where card_no = '" + oldCard.getCardNo() + "'");
				log.debug("同步省厅完成，老卡【" + oldCardDbg[0] + "，" + oldCardDbg[1] + "】");
			}
			jsonObject.put("status","0");
			jsonObject.put("dealNo",tempRec.getDealNo());
			jsonObject.put("message", message);
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg","个人发放登记保存发生错误：" + e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 规模发放查询
	 * @return
	 */
	public String cardBatchIssuseQuery(){
		try{
			initGridData();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select t.task_id SETTLEID,t.task_id,t.make_batch_id,(select code_name from sys_Code where code_type = 'TASK_STATE' and code_value = t.task_state) task_state,");
			sb.append("decode(t.task_way,'0','网点','2','社区','1','单位','3','学校','其他') task_way,t.task_name, t.is_batch_hf, ");
			sb.append("to_char(t.task_date,'yyyy-mm-dd hh24:mi:ss') task_date,(select code_name from sys_Code where code_type = 'CARD_TYPE' and code_value = t.card_type) card_type,");
			sb.append("decode(t.is_urgent,'0','本地制卡','1','外包制卡','其他') is_urgent,t.task_sum,t.yh_num, t.end_num, t.card_type card_type2, t.TASK_STATE as taskstate ");
			sb.append(" from card_apply_task t where  (t.task_state = '" + Constants.TASK_STATE_YJS + "' or t.task_state = '" + Constants.TASK_STATE_FFZ + "' or t.task_state = '" + Constants.TASK_STATE_FFWC +  "') and t.TASK_SRC <> '" + Constants.TASK_SRC_FGXHCG + "' ");
			if(!Tools.processNull(madeCardBatchNo).equals("")){
				sb.append(" and t.make_batch_id = '" + madeCardBatchNo + "'");
			}
			if(!Tools.processNull(madeCardTaskNo).equals("")){
				sb.append(" and t.task_id = '" + madeCardTaskNo + "'");
			}
			if(!Tools.processNull(taskState).equals("")){
				sb.append(" and t.task_state = '" + taskState + "'");
			}
			if(!Tools.processNull(corpId).equals("")){
				sb.append(" and t.CORP_ID = '" + corpId + "'");
			}
			if(!Tools.processNull(brchId).equals("")){
				String regionId2 = (String) cardIssuseService.findOnlyFieldBySql("select region_id from sys_branch where brch_id = '" + brchId + "'");
				sb.append(" and exists (select 1 from sys_branch b where t.brch_id = b.brch_id and b.region_id = '" + regionId2 + "')");
			}
			if(!Tools.processNull(cardType).equals("")){
				sb.append(" and t.card_Type = '" + cardType + "'");
			}
			if(!Tools.processNull(taskStartDate).equals("")){
				sb.append(" and to_char(t.task_date,'yyyy-MM-dd') >= '" + taskStartDate + "'");
			}
			if(!Tools.processNull(taskEndDate).equals("")){
				sb.append(" and to_char(t.task_date,'yyyy-MM-dd') <= '" + taskEndDate + "'");
			}
			if(!Tools.processNull(regionId).equals("")){
				sb.append(" and t.region_id = '" + regionId + "'");
			}
			if(!Tools.processNull(townId).equals("")){
				sb.append(" and t.town_id = '" + townId + "'");
			}
			if(!Tools.processNull(commId).equals("")){
				sb.append(" and t.comm_id = '" + commId + "'");
			}
			if (!Tools.processNull(isBatchHf).equals("")) {
				sb.append(" and t.is_batch_hf = '" + isBatchHf + "'");
			}
			if(Tools.processNull(sort).equals("")){
				sb.append(" order by t.task_id ");
			}else{
				sb.append(" order by " + sort + " " + order);
			}
			Page list = cardIssuseService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据指定条件未找到对应任务信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 规模发放预览
	 * @return
	 */
	public String viewCardIssuse(){
		try{
			initGridData();
			if(!this.queryType.equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT b.name,b.cert_no,t.task_id,k.make_batch_id,t.apply_id,t.apply_state,t.customer_id,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'APPLY_STATE' AND CODE_VALUE = t.apply_state) applystate,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CARD_TYPE' AND CODE_VALUE = t.card_type) cardtype,");
			sb.append("t.card_no,DECODE(t.is_urgent,'0','本地制卡','1','外包制卡','其他') is_urgent,(SELECT CODE_NAME FROM SYS_CODE ");
			sb.append("WHERE CODE_TYPE = 'APPLY_TYPE' AND CODE_VALUE = t.apply_type) APPLYTYPE,DECODE(k.task_way,'0','网点','1','社区','2','单位','3','学校','其他') task_way ");
			sb.append("FROM card_apply t,base_personal b,card_apply_task k ");
			sb.append("WHERE t.customer_id = b.customer_id AND t.task_id = k.task_id ");
			//sb.append("and t.apply_state = '" + Constants.APPLY_STATE_YJS + "' ");
			
			if(!Tools.processNull(apply.getApplyId()).equals("")){
				sb.append(" and t.apply_id = '" + apply.getApplyId() + "' ");
			}
			if(!Tools.processNull(person.getName()).equals("")){
				sb.append(" and b.name like '%" + person.getName() + "%' ");
			}
			if(!Tools.processNull(this.taskId).equals("")){
				sb.append(" and t.task_id = '" + this.taskId + "' ");
			}
			if(!Tools.processNull(person.getCertNo()).equals("")){
				sb.append(" and b.cert_No = '" + person.getCertNo() + "' ");
			}
			if(Tools.processNull(sort).equals("")){
				sb.append(" order by t.apply_state ");
			}else{
				sb.append(" order by " + sort + " " + order);
			}
			Page list = cardIssuseService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未找到对应申领记录信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 规模发放保存
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public String saveBatchCardIssuse(){
		int sucNums = 0;
		int totNums = 0;
		String subtitle = "";
		try{
			if(Tools.processNull(taskIds).equals("")){
				throw new CommonException("请勾选需要进行批量发放的制卡任务或申领记录信息！");
			}
			if(Tools.processNull(this.issuseType).equals("0")){
				subtitle = "任务";
			}else if(Tools.processNull(this.issuseType).equals("1")){
				subtitle = "申领记录";
			}
			// 规模发放（换发）isBatchHf = 0
			if(!Tools.processNull(isBatchHf).equals("0")){
				List<String> list = (List<String>) baseService.findBySql("select task_id from card_apply_task where task_id in (" + taskIds + ") and is_batch_hf = '0'");
				if (!list.isEmpty()) {
					throw new CommonException("任务号为" + Arrays.toString(list.toArray()) + "的任务为批量换发任务，不能进行规模发放，仅能进行领卡登记！");
				}
			}
			String[] task_Ids = taskIds.split(",");
			totNums = task_Ids.length;
			StringBuffer dealNos = new StringBuffer();
			for(int i = 0;i < task_Ids.length; i++){
				try{
					// 老卡卡号
					List<String> oldCardNos = cardIssuseService.findBySql("select card_no from card_baseinfo t where card_state in ('1', '2', '3') and exists (select 1 from card_apply where customer_id = t.customer_id and task_id = '" + task_Ids[i] + "')");
					TrServRec tempRec = new TrServRec();
					tempRec = (TrServRec) BeanUtils.cloneBean(rec);
					SysActionLog tempActionLog = (SysActionLog) BeanUtils.cloneBean(baseService.getCurrentActionLog());
					TrServRec hrec = cardIssuseService.saveBatchCardIssuse(task_Ids[i],this.issuseType,cardIssuseService.getUser(),tempRec,tempActionLog, sync2Sb);
					if (!dealNos.toString().equals("")) {
						dealNos.append(",");
					}
					dealNos.append(hrec.getDealNo());
					sucNums++;
					// 同步新卡到省厅
					try {
						switchservice.updateCardState(oldCardNos, Constants.CARD_STATE_ZC, Constants.CARD_STATE_ZX); // 注销老卡
						switchservice.sync2ST(task_Ids[i]);//同步新卡到省厅
					} catch (Exception e) {
						continue;
					}
				}catch(Exception e){
					throw new CommonException(e.getMessage());
				}
			}
			jsonObject.put("dealNos", dealNos.toString());
			jsonObject.put("status","0");
			jsonObject.put("errMsg","计划完成发放" + totNums + "个" + subtitle + "，成功完成" + sucNums + "个" + subtitle + "！");
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg","计划完成发放" + totNums + "个" + subtitle + "，已成功完成" + sucNums + "个" + subtitle + "，");
			jsonObject.put("errMsg",jsonObject.get("errMsg") + "其中在执行第" + (sucNums + 1) + "个" + subtitle + "时出现错误！" + e.getMessage());
		}
		jsonObject.put("sucNums",sucNums);
		return this.JSONOBJ;
	}
	
	/**
	 * 个人发放记录查询
	 * @return
	 */
	public String queryUndoCardIssue(){
		try{		
			initGridData();
			if(!this.queryType.equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT T.DEAL_NO,B.APPLY_ID,P.CERT_NO,P.NAME,B.APPLY_STATE,(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'APPLY_STATE' ");
			sb.append("AND CODE_VALUE = B.APPLY_STATE) APPLYSTATE,B.CARD_NO,TO_CHAR(T.BIZ_TIME,'YYYY-MM-DD HH:MI:SS') BIZ_DATE,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CARD_TYPE' AND CODE_VALUE = B.CARD_TYPE) CARDTYPE,T.BRCH_ID,T.USER_ID ");
			sb.append("FROM TR_SERV_REC T,CARD_APPLY B,BASE_PERSONAL P WHERE T.CUSTOMER_ID = B.CUSTOMER_ID AND B.CUSTOMER_ID = P.CUSTOMER_ID ");
			sb.append("AND T.CARD_NO = B.CARD_NO AND T.DEAL_CODE = '" + DealCode.ISSUSE_TYPE_PERSONAL + "' AND T.DEAL_STATE = '" + Constants.TR_STATE_ZC + "' ");
			sb.append("and t.RSV_ONE = '0' ");
			if(!Tools.processNull(person.getCertNo()).equals("")){
				sb.append(" and p.cert_No = '" + person.getCertNo() + "' ");
			}
			if(!Tools.processNull(person.getName()).equals("")){
				sb.append(" and p.name like '%" + person.getName() + "%' ");
			}
			if(!Tools.processNull(taskStartDate).equals("")){
				sb.append(" and to_char(t.biz_time,'yyyy-MM-dd') >= '" + taskStartDate + "' ");
			}
			if(!Tools.processNull(taskEndDate).equals("")){
				sb.append(" and to_char(t.biz_time,'yyyy-MM-dd') <= '" + taskEndDate + "' ");
			}
			if(!Tools.processNull(brchId).equals("")){
				sb.append(" and t.brch_Id = '" + brchId + "' ");
			}
			if(!Tools.processNull(userId).equals("")){
				sb.append(" and t.user_Id = '" + userId + "' ");
			}
			if(!Tools.processNull(applyId).equals("")){
				sb.append(" and b.apply_Id = '" + applyId + "' ");
			}
			sb.append(" and t.clr_date = '" + cardIssuseService.getClrDate() + "' ");
			if(Tools.processNull(sort).equals("")){
				sb.append(" order by t.biz_time desc ");
			}else{
				sb.append(" order by  " + sort + " " + order);
			}
			Page list = cardIssuseService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未找到对应发放记录信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 发放撤销保存
	 * @return
	 */
	public String saveUndoCardIssuse(){
		try{
			SysActionLog actionLog = baseService.getCurrentActionLog();
			if(Tools.processNull(taskIds).equals("")){
				throw new CommonException("请勾选需要进行撤销的发放记录信息！");
			}
			if(taskIds.split(",").length > 1){
				throw new CommonException("请勾选一条发放记录进行撤销！");
			}
			rec.setDealNo(Long.valueOf(taskIds));
			rec = cardIssuseService.saveUndoCardIssuse(taskIds,actionLog,rec);//进行实名制卡个人发放登记保存
			jsonObject.put("status","0");
			jsonObject.put("dealNo",rec.getDealNo());
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg","个人发放撤销发生错误：" + e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 初始化表格
	 */
	private void initGridData(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
	}
	public String getQueryType() {
		return queryType;
	}
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	public String getMadeCardBatchNo() {
		return madeCardBatchNo;
	}
	public void setMadeCardBatchNo(String madeCardBatchNo) {
		this.madeCardBatchNo = madeCardBatchNo;
	}
	public String getMadeCardTaskNo() {
		return madeCardTaskNo;
	}
	public void setMadeCardTaskNo(String madeCardTaskNo) {
		this.madeCardTaskNo = madeCardTaskNo;
	}
	public String getTaskState() {
		return taskState;
	}
	public void setTaskState(String taskState) {
		this.taskState = taskState;
	}
	public String getCorpId() {
		return corpId;
	}
	public void setCorpId(String corpId) {
		this.corpId = corpId;
	}
	public String getCardType() {
		return cardType;
	}
	public void setCardType(String cardType) {
		this.cardType = cardType;
	}
	public String getTaskStartDate() {
		return taskStartDate;
	}
	public void setTaskStartDate(String taskStartDate) {
		this.taskStartDate = taskStartDate;
	}
	public String getTaskEndDate() {
		return taskEndDate;
	}
	public void setTaskEndDate(String taskEndDate) {
		this.taskEndDate = taskEndDate;
	}
	public String getRegionId() {
		return regionId;
	}
	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}
	public String getTownId() {
		return townId;
	}
	public void setTownId(String townId) {
		this.townId = townId;
	}
	public String getCommId() {
		return commId;
	}
	public void setCommId(String commId) {
		this.commId = commId;
	}
	public String getSort() {
		return sort;
	}
	public void setSort(String sort) {
		this.sort = sort;
	}
	public String getOrder() {
		return order;
	}
	public void setOrder(String order) {
		this.order = order;
	}
	
	public String getTaskId() {
		return taskId;
	}
	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}
	public String getTaskNum() {
		return taskNum;
	}
	public void setTaskNum(String taskNum) {
		this.taskNum = taskNum;
	}
	public String getDataSeqs() {
		return dataSeqs;
	}
	public void setDataSeqs(String dataSeqs) {
		this.dataSeqs = dataSeqs;
	}
	public String getTaskStateName() {
		return taskStateName;
	}
	public void setTaskStateName(String taskStateName) {
		this.taskStateName = taskStateName;
	}
	public String getCustomerIds() {
		return customerIds;
	}
	public void setCustomerIds(String customerIds) {
		this.customerIds = customerIds;
	}
	public String getApplyId() {
		return applyId;
	}
	public String getTaskIds() {
		return taskIds;
	}
	public void setTaskIds(String taskIds) {
		this.taskIds = taskIds;
	}
	public String getBrchId() {
		return brchId;
	}
	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}
	public void setApplyId(String applyId) {
		this.applyId = applyId;
	}
	public void setCardIssuseService(CardIssuseService cardIssuseService) {
		this.cardIssuseService = cardIssuseService;
	}
	public TrServRec getRec() {
		return rec;
	}
	public void setRec(TrServRec rec) {
		this.rec = rec;
	}
	public CardApply getApply() {
		return apply;
	}
	public void setApply(CardApply apply) {
		this.apply = apply;
	}
	public BasePersonal getPerson() {
		return person;
	}
	public void setPerson(BasePersonal person) {
		this.person = person;
	}
	public CardIssuseService getCardIssuseService() {
		return cardIssuseService;
	}

	public String getCorpName() {
		return corpName;
	}

	public void setCorpName(String corpName) {
		this.corpName = corpName;
	}

	/**
	 * @return the issuseType
	 */
	public String getIssuseType() {
		return issuseType;
	}
	
	/**
	 * @param issuseType the issuseType to set
	 */
	public void setIssuseType(String issuseType) {
		this.issuseType = issuseType;
	}

	/**
	 * @return the userId
	 */
	public String getUserId() {
		return userId;
	}

	/**
	 * @param userId the userId to set
	 */
	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getIsBatchHf() {
		return isBatchHf;
	}

	public void setIsBatchHf(String isBatchHf) {
		this.isBatchHf = isBatchHf;
	}

	public boolean getSync2Sb() {
		return sync2Sb;
	}

	public void setSync2Sb(boolean sync2Sb) {
		this.sync2Sb = sync2Sb;
	}
}
