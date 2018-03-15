package com.erp.serviceImpl;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.beanutils.BeanUtils;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.BaseCorp;
import com.erp.model.BaseKanwuPrint;
import com.erp.model.CardApplyTask;
import com.erp.model.CardConfig;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.CardApplyService;
import com.erp.service.PersonInfoErrataService;
import com.erp.util.Constants;
import com.erp.util.Tools;


/**
 * 类修改者	修改日期
 * 修改说明
 * <p>Title: PersonInfoErrataServiceImpl.java</p>
 * <p>Description:制卡人员信息校验业务类</p>
 * <p>Copyright: Copyright (c) 2012</p>
 * <p>Company:颐瑞科技</p>
 * @author hujc 631410114@qq.com
 * @date 2015-12-04 下午03:18:37
 * @version V1.0
 */
@Service("personInfoErrataService")
@SuppressWarnings("unchecked")
public class PersonInfoErrataServiceImpl extends BaseServiceImpl implements
		PersonInfoErrataService {
	@Resource(name="cardApplyService")
	private CardApplyService cardApplyService;

	@Override
	public SysActionLog savePrintReport(SysActionLog actionLog, Users operator) throws CommonException {
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
	public void saveKanwuPrint(BaseKanwuPrint print) throws CommonException {
		try {
			publicDao.merge(print);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}

	/**
	 * 
	 */
	@SuppressWarnings("rawtypes")
	@Override
	public String saveSbApplyInfo(SysActionLog actionLog, Users oper,String selectIds) throws CommonException {
		String returnStr = "";
		try {
			CardConfig config = (CardConfig)this.findOnlyRowByHql("from CardConfig t where cardType='"+Constants.CARD_TYPE_SMZK+"'");
			StringBuffer sqlHead = new StringBuffer("");
			sqlHead.append("SELECT T.EMP_ID EMP_ID1,T.EMP_ID EMP_ID,T.EMP_NAME EMP_NAME,T.COMPANYID COMPANYID,"
					+ " (SELECT b.brch_id FROM sys_branch b WHERE b.brch_id = t1.lk_brch_id ) RECV_BRCH_ID, "
					+ " (SELECT b.full_name FROM sys_branch b WHERE b.brch_id = t1.lk_brch_id ) RECV_BRCH_NAME,"
					+ " COUNT(1) APPLY_NUM FROM CARD_APPLY_SB T, base_corp T1 WHERE T.Emp_Id = T1.Customer_Id "
					+ " and t.SB_APPLY_STATE = '" +Constants.CARD_APPLY_SB_STATE_DSL+"'");
			sqlHead.append(" and t.cert_no not in  (select b.cert_no from Card_Apply a,base_personal b  where a.customer_id = b.customer_id and b.cert_no = t.cert_no ");
			sqlHead.append(" and (a.apply_State < '" + Constants.APPLY_STATE_YZX + "' and a.apply_State <> '" + Constants.APPLY_STATE_WJWSHBTG + "' and a.apply_State <> '" + Constants.APPLY_STATE_YZX  + "' "
					+ " and a.apply_state <> '" + Constants.APPLY_STATE_YHSHBTG + "' )) ");
			sqlHead.append("  GROUP BY T.EMP_ID, T.EMP_NAME, T.COMPANYID,t1.lk_brch_id ");
			List baseCardApplySb = publicDao.findBySQL(sqlHead.toString());
			for (int i = 0; i < baseCardApplySb.size(); i++) {
				Object[] obj = (Object[])baseCardApplySb.get(i);
				BaseCorp baseCorp = (BaseCorp)this.findOnlyRowByHql("from BaseCorp t where t.customerId = '"+Tools.processNull(obj[1])+"'");
				CardApplyTask tempTask = new CardApplyTask();
				String taskName = baseCorp.getCorpName();
				tempTask.setTaskName(taskName);
				tempTask.setIsPhoto(Tools.processNull(Constants.YES_NO_YES));
				tempTask.setTaskSrc(Constants.TASK_SRC_SBSL);
				tempTask.setIsUrgent("1");
				tempTask.setCardType(Tools.processNull(Constants.CARD_TYPE_SMZK));
				tempTask.setTaskWay(Constants.TASK_WAY_DW);
				tempTask.setIsList("0");
				tempTask.setCorpId(baseCorp.getCustomerId());
				tempTask.setBrchId(baseCorp.getLkBrchId());
				//b代表人员表 r代表区域
				StringBuffer sb = new StringBuffer();
				sb.append(" and b.corp_customer_id = '"+tempTask.getCorpId()+"'");
				sb.append(" and exists(select 1 from card_apply_sb asb where asb.emp_id = b.corp_customer_id and sb_apply_state ='"+Constants.CARD_APPLY_SB_STATE_DSL+"') ");
				//调用申领进行申领
				TrServRec rec = cardApplyService.saveBatchApply(sb,tempTask,config,actionLog,oper);
				//更改社保申领表数据
				publicDao.doSql("update card_apply_sb t set t.sb_apply_state = '"+Constants.CARD_APPLY_SB_STATE_YSL+"' where t.cert_no in (select "
						+ " t2.cert_no from card_apply t1,base_personal t2 where t1.customer_id = t2.customer_id and t1.task_id ='"+tempTask.getTaskId()+"')");
				publicDao.doSql("update card_apply_sb t set t.sb_apply_state = '"+Constants.CARD_APPLY_SB_STATE_YJJ+"' where t.emp_id ='"+tempTask.getCorpId()+"'");
				returnStr += "申领成功数量："+rec.getCardAmt() +"未能正确申领数量："+(baseCardApplySb.size()-rec.getCardAmt()+1);
			}
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
		return returnStr;
	}

	@Override
	public void saveSbApply(String applyIds, String cardType, SysActionLog log) {
		try {
			if(applyIds == null) {
				throw new CommonException("申领数据为空");
			}
			String[] applyIdArr = applyIds.split(",");
			if(applyIdArr == null || applyIdArr.length == 0) {
				throw new CommonException("申领数据为空");
			}
			
			String applyIdSql = "";
			for (String applyId : applyIdArr) {
				applyIdSql += "'" + applyId + "',";
			}
			String sbApplyCountSql = "select emp_id, max(recv_brch_id), min(recv_brch_id), "
					+ "(select corp_name from base_corp where customer_id = t.emp_id), "
					+ "count(1) from card_apply_sb t where sb_apply_id in ("
					+ applyIdSql.substring(0, applyIdSql.length() - 1) + ") group by emp_id";
			
			// 循环申领
			CardConfig config = (CardConfig) findOnlyRowByHql("from CardConfig t where cardType='" + cardType + "'");
			if (config == null) {
				throw new CommonException("要申领的卡类型不存在【" + cardType + "】");
			}
			Users user = (Users) findOnlyRowByHql("from Users where userId = '" + log.getUserId() + "'");
			List<Object[]> sbApplyCounts = findBySql(sbApplyCountSql);
			for (Object[] sbApplyCount : sbApplyCounts) {
				int num = ((BigDecimal) sbApplyCount[4]).intValue();
				if (num == 0) {
					continue;
				}
				if(Tools.processNull(sbApplyCount[0]).equals("")){
					throw new CommonException("单位编号为空");
				}
				BaseCorp corp = (BaseCorp) findOnlyRowByHql("from BaseCorp where customerId = '" + sbApplyCount[0] + "'");
				if(corp == null) {
					throw new CommonException("编号为【" + sbApplyCount[0] + "】单位不存在");
				}
				
				if(!sbApplyCount[1].equals(sbApplyCount[2])){
					throw new CommonException("单位【" + corp.getCorpName() + "】下人员领卡网点不一致");
				} else if (Tools.processNull(sbApplyCount[1]).equals("")){
					throw new CommonException("单位【" + corp.getCorpName() + "】下人员领卡网点为空");
				}
				SysBranch lkBrch = (SysBranch) findOnlyRowByHql("from SysBranch where brchId = '" + sbApplyCount[1] + "'");
				if (lkBrch == null) {
					throw new CommonException("单位【" + corp.getCorpName() + "】领卡网点编号对应领卡网点不存在");
				}
				if (Constants.CARD_TYPE_QGN.equals(cardType)) {
					corp.setLkBrchId2(lkBrch.getBrchId());
				} else if (Constants.CARD_TYPE_SMZK.equals(cardType)) {
					if (Tools.processNull(corp.getLkBrchId()).equals("")) {// 如果单位没有设置金融社保卡领卡网点，就用申报的
						corp.setLkBrchId(lkBrch.getBrchId());
					}
				}
				publicDao.update(corp);
				
				// 申领
				CardApplyTask task = new CardApplyTask();
				task.setTaskName(corp.getCorpName());
				task.setIsPhoto(Tools.processNull(Constants.YES_NO_YES));
				task.setTaskSrc(Constants.TASK_SRC_SBSL);
				task.setIsUrgent("1");
				task.setCardType(Tools.processNull(cardType));
				task.setTaskWay(Constants.TASK_WAY_DW);
				task.setIsList("0");
				task.setCorpId(corp.getCustomerId());
				task.setBrchId(sbApplyCount[1].toString());
				task.setIsJudgeSbState(Constants.YES_NO_YES);
				task.setIsBatchHf(Constants.YES_NO_NO);
				
				StringBuffer sb = new StringBuffer();
				sb.append(" and b.corp_customer_id = '" + task.getCorpId() + "'");
				sb.append(" and exists(select 1 from card_apply_sb asb where asb.emp_id = b.corp_customer_id and b.cert_no = asb.cert_no and sb_apply_state = '"
						+ Constants.CARD_APPLY_SB_STATE_DSL + "' and asb.sb_apply_id in (" + applyIdSql.substring(0, applyIdSql.length() - 1) + ") and asb.emp_id = '" + sbApplyCount[0] + "') "
						+ "and f.MED_WHOLE_NO = '" + lkBrch.getRegionId() + "'");
				
				try {
					cardApplyService.saveBatchApply(sb, task, config, (SysActionLog) BeanUtils.cloneBean(log), user);
				} catch (Exception e) {
					throw new CommonException("单位【" + corp.getCorpName() + "】批量申领失败，" + e.getMessage());
				}
				
				// 更新申领信息
				publicDao.doSql("update card_apply_sb t set t.sb_apply_state = '" + Constants.CARD_APPLY_SB_STATE_YSL 
						+ "' where sb_apply_id in (" + applyIdSql.substring(0, applyIdSql.length() - 1) + ") and exists "
						+ "(select 1 from card_apply a join base_personal b on a.customer_id = b.customer_id "
						+ "where b.cert_no = t.cert_no and a.apply_state = '" + Constants.APPLY_STATE_RWYSC + "')");
			}
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}

	@Override
	public void updateSbApply() {
		// 若人员已申领， 更新社保申领状态为已申领
		int rn = publicDao.doSql("update CARD_APPLY_SB sb set sb_apply_state = '" + Constants.CARD_APPLY_SB_STATE_YSL + "' where sb_apply_state = '" + Constants.CARD_APPLY_SB_STATE_DSL 
				+ "' and exists (select 1 from base_personal t join card_apply t2 on t.customer_id = t2.customer_id where t.cert_no = sb.cert_no and t2.apply_state >= '" 
				+ Constants.APPLY_STATE_YSQ + "' and t2.apply_state < '" + Constants.APPLY_STATE_YZX + "' and t2.apply_state <> '" + Constants.APPLY_STATE_YHSHBTG + "')");
		// 若人员已断保， 更新社保申领状态为已拒绝
		int rn2 = publicDao.doSql("update CARD_APPLY_SB sb set sb_apply_state = '" + Constants.CARD_APPLY_SB_STATE_YJJ + "' where sb_apply_state = '" + Constants.CARD_APPLY_SB_STATE_DSL 
				+ "' and exists (select 1 from base_personal t join base_siinfo t2 on t.customer_id = t2.customer_id where t.cert_no = sb.cert_no and t2.med_state <> '" + Constants.STATE_ZC + "')");
		
		// 若人员无照片， 更新社保申领状态为已拒绝
		int rn3 = publicDao.doSql("update CARD_APPLY_SB sb set sb_apply_state = '" + Constants.CARD_APPLY_SB_STATE_YJJ + "' where sb_apply_state = '" + Constants.CARD_APPLY_SB_STATE_DSL
				+ "' and not exists (select 1 from base_personal t join base_photo t2 on t.customer_id = t2.customer_id where t.cert_no = sb.cert_no and t2.photo_state = '" + Constants.STATE_ZC + "')");
		
		// 若人员单位不正确， 更新社保申领状态为已拒绝
		int rn4 = publicDao.doSql("update CARD_APPLY_SB sb set sb_apply_state = '" + Constants.CARD_APPLY_SB_STATE_YJJ + "' where sb_apply_state = '" + Constants.CARD_APPLY_SB_STATE_DSL
				+ "' and exists (select 1 from base_personal t where t.cert_no = sb.cert_no and t.corp_customer_id <> sb.emp_id)");
		
		// 若人员姓名不匹配， 更新社保申领状态为已拒绝
		int rn5 = publicDao.doSql("update CARD_APPLY_SB sb set sb_apply_state = '" + Constants.CARD_APPLY_SB_STATE_YJJ + "' where sb_apply_state = '" + Constants.CARD_APPLY_SB_STATE_DSL
				+ "' and exists (select 1 from base_personal t where t.cert_no = sb.cert_no and t.name <> sb.name)");
	}
}
