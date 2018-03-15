package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.beanutils.BeanUtils;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.CashBox;
import com.erp.model.SysBranch;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.AccAcountService;
import com.erp.service.CashManageService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.Tools;
import com.erp.util.DealCode;

@Service(value="cashManageService")
public class CashManageServiceImpl extends BaseServiceImpl implements CashManageService {
	@Resource(name="accAcountService")
	AccAcountService accService;
	private String debugFlag = "1";
	/**
	 * 查询柜员尾箱信息
	 * @param sql    查询sql
	 * @param page   第几页
	 * @param rows   每页多少条
	 * @return       list 列表柜员尾箱信息
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public List<?> toQueryCashBox(String sql,Integer page,Integer rows) throws CommonException{
		return publicDao.findSQL(sql,null,page,rows);
	}
	/**
	 * 柜员调剂，当前柜员向其他柜员调剂现金尾箱
	 * @param currentUser  当前调剂柜员
	 * @param inUser       接收柜员
	 * @param amt          调剂金额  @单位：分
	 * @return             业务操作日志
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	@Override
	public Long saveTellerTransfer(Users currentUser, Users inUser,long amt) throws CommonException {
		try{
			//1.记录操作日志
			if(Tools.processNull(currentUser.getUserId()).equals(inUser.getUserId()) && Tools.processNull(currentUser.getBrchId()).equals(inUser.getBrchId())){
				throw new CommonException("不能向本人进行调剂！");
			}
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(DealCode.TELLER_SWAP);
			log.setMessage("柜员调剂:付方柜员userId=" + currentUser.getUserId() + ",收方柜员userId=" + inUser.getUserId() + ",调剂金额:" + Arith.cardreportsmoneydiv(amt + ""));
			publicDao.save(log);
			//2.调剂
			CashBox box = (CashBox) this.findOnlyRowByHql("from CashBox t where t.brchId = '" + currentUser.getBrchId() + "' and t.userId = '" + currentUser.getUserId() + "'");
			if((box.getTdBlc() - box.getFrzAmt()) != amt){
				throw new CommonException("调剂金额不等于尾箱余额！");
			}
			HashMap<String,String> map = new HashMap<String, String>();
			map.put("oper_id1",currentUser.getUserId());//付方柜员编号
			map.put("oper_id2",inUser.getUserId());//收方柜员编号
			map.put("amt",amt + "");
			map.put("acpt_type",Constants.ACPT_TYPE_GM);
			cashHandOver(log,map);
			//3.记录业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Constants.STATE_ZC);
			rec.setOtherFee(amt);//调剂金额
			rec.setOrgIdIn(inUser.getOrgId());
			rec.setBrchIdIn(inUser.getBrchId());//收方柜员网点
			rec.setUserIdIn(inUser.getUserId());//收方柜员编号
			rec.setAmt(amt);
			rec.setOrgIdOut(currentUser.getOrgId());
			rec.setBrchIdOut(currentUser.getBrchId());//付方柜员网点
			rec.setUserIdOut(currentUser.getUserId());//付方柜员编号
			
			rec.setOrgId(currentUser.getOrgId());
			rec.setBrchId(currentUser.getBrchId());//付方操作柜员网点
			rec.setUserId(currentUser.getUserId());//付方操作员编号
			publicDao.save(rec);
			//4.保存报表显示内容数据
			JSONObject report = new JSONObject();
			report.put("p_Action_No",rec.getDealNo());//凭证流水
			report.put("p_Print_Time",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));
			report.put("p_One","付方柜员");
			report.put("p_One_Value",currentUser.getName());
			report.put("p_Two","接收柜员");
			report.put("p_Two_Value",inUser.getName());
			report.put("p_Acept_Type",this.findTrCodeNameByCodeType(log.getDealCode()));
			report.put("p_Acept_Amt",Arith.cardreportsmoneydiv(amt + ""));
			report.put("p_Print_Year", DateUtil.formatDate(log.getDealTime(),"yyyy"));
			report.put("p_Print_Month", DateUtil.formatDate(log.getDealTime(),"MM"));
			report.put("p_Print_Day", DateUtil.formatDate(log.getDealTime(),"dd"));
			SysBranch branch = (SysBranch) this.findOnlyRowByHql(" from SysBranch t where t.brchId = '" + currentUser.getBrchId() + "'");
			if(branch == null){
				branch = new SysBranch();
			}
			report.put("p_Acept_Branch",branch.getFullName());
			report.put("p_Acept_Time",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));
			report.put("p_Oper_Id",currentUser.getUserId());
			this.saveSysReport(log,report,"/reportfiles/XianJinGuanLiPZ.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
			return rec.getDealNo();
		}catch(Exception e){
			throw new CommonException("柜员调剂发生错误:" + e.getMessage());
		}
	}
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public HashMap cashHandOver(SysActionLog log,HashMap<String, String> hm) throws CommonException{
		List<Object> in = new java.util.ArrayList<Object>(); 
		StringBuffer inpara = new StringBuffer();
		inpara.append(Tools.processNull(log.getDealNo())).append("|");
		inpara.append(Tools.processNull(log.getDealCode())).append("|");
		inpara.append(Tools.processNull(log.getUserId())).append("|");
		inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));
		inpara.append("|").append(Tools.processNull(hm.get("oper_id1")));
		inpara.append("|").append(Tools.processNull(hm.get("oper_id2")));
		inpara.append("|").append(Tools.processNull(hm.get("amt")));
		inpara.append("|").append(Tools.processNull(log.getMessage()));
		inpara.append("|").append(Tools.processNull(hm.get("acpt_type")));
		in.add(inpara.toString());
		in.add(debugFlag);
		List<Integer> out = new java.util.ArrayList<Integer>();
		out.add(java.sql.Types.VARCHAR);
		out.add(java.sql.Types.VARCHAR);
		try {
			List ret = publicDao.callProc("PK_BUSINESS.P_CASHHANDOVER",in,out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					return null;
				}
			} else {
				throw new CommonException("现金记账出错！");
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			throw new CommonException(ex.getMessage());
		}
	}
	/**
	 * 》》网点存款确认（老版保留）直接确认
	 * @param oper  操作员
	 * @param amt   网点存款金额  单位：分
	 * @param bankNo网点存款银行存款凭证号
	 * @return      业务操作流水
	 */
	@Deprecated
	@SuppressWarnings("unchecked")
	public Long saveCertainDeposit(Users oper,Long amt,String bankNo) throws CommonException{
		try{
			//1.记录操作日志
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(DealCode.BRANCH_DEPOSIT);
			log.setMessage("网点存款,柜员编号:" + oper.getUserId() + " , 存款金额:" + Arith.cardreportsmoneydiv(amt + "") + " , 银行存款编号:" + bankNo);
			publicDao.save(log);
			//2.调存储过程进行网点存款
			HashMap depositMap = new HashMap();
			depositMap.put("item_no","102100");//科目 机构往来款
			depositMap.put("amt", -amt);//网点存款金额
			depositMap.put("acpt_type", Constants.ACPT_TYPE_GM);//受理点类型
			accService.cost(log,depositMap);
			//3.记录业务操作日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setBizTime(log.getDealTime());
			rec.setOrgId(oper.getOrgId());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.STATE_ZC);
			rec.setOtherFee(-amt);
			rec.setClrDate(this.getClrDate());
			publicDao.save(rec);
			//4.记录报表日志
			JSONObject report = new JSONObject();
			report.put("p_Action_No",log.getDealNo());
			report.put("p_Print_Time",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));
			SysBranch branch = (SysBranch) this.findOnlyRowByHql(" from SysBranch t where t.brchId = '" + oper.getBrchId() + "'");
			if(branch == null){
				branch = new SysBranch();
			}
			report.put("p_Branch_Name",branch.getFullName());
			report.put("p_Acpt_Type",this.findTrCodeNameByCodeType(log.getDealCode()));
			report.put("p_Oper_Name",oper.getName());
			report.put("p_Acept_Amt",Arith.cardreportsmoneydiv(amt + ""));
			report.put("p_Bank_Num",bankNo);
			report.put("p_Acpt_Time",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));		
			this.saveSysReport(log,report,"/reportfiles/WangDianCunQuKuanPZ.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
			return log.getDealNo();
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 》》网点预存款（只记录灰记录不进行实际转账）
	 * @param oper  操作员
	 * @param amt   预存款金额
	 * @param bankNo银行存款凭证号
	 * @return      业务日志
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveCertainDepositPre(Users oper,Long amt,String bankNo) throws CommonException{
		try{
			//1.记录操作日志
			if(Tools.processNull(amt).equals("")){
				throw new CommonException("网点存款金额不能为空！");
			}
			if(amt <= 0){
				throw new CommonException("网点存款金额必须是数字类型");
			}
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(DealCode.BRANCH_DEPOSIT);
			log.setMessage("网点预存款,柜员编号:" + oper.getUserId() + " , 存款金额:" + Arith.cardreportsmoneydiv(amt + "") + " , 银行存款编号:" + bankNo);
			publicDao.save(log);
			//2.记录业务操作日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setOrgId(oper.getOrgId());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setNote(log.getMessage());
			rec.setDealState(Constants.TR_STATE_HJL);//预存款待审核状态 9 
			rec.setAmt(-amt);
			rec.setClrDate(this.getClrDate());
			rec.setRsvOne(bankNo);//银行存款凭证编号
			publicDao.save(rec);
			//3.冻结尾箱
			CashBox box = (CashBox) this.findOnlyRowByHql("from CashBox t where t.brchId = '" + oper.getBrchId() + "' and t.userId = '" + oper.getUserId() + "'");
			if((box.getTdBlc() - box.getFrzAmt()) < amt){
				throw new CommonException("尾箱余额不足！");
			}
			int frzcount = publicDao.doSql("UPDATE cash_box t SET t.frz_amt = NVL(t.frz_amt,0) + " + amt +  " WHERE t.brch_id = '" + oper.getBrchId() + "' AND t.user_id = '" + oper.getUserId() + "'");
			if(frzcount != 1){
				throw new CommonException("网点存款时，冻结尾箱金额更新" + frzcount + "行！");
			}
			//4.记录报表日志
			JSONObject report = new JSONObject();
			report.put("p_Title",Constants.APP_REPORT_TITLE + this.findTrCodeNameByCodeType(log.getDealCode()) + "凭证");
			report.put("p_Action_No",log.getDealNo());
			report.put("p_Print_Time",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));
			SysBranch branch = (SysBranch) this.findOnlyRowByHql(" from SysBranch t where t.brchId = '" + oper.getBrchId() + "'");
			if(branch == null){
				branch = new SysBranch();
			}
			report.put("p_Branch_Name",branch.getFullName());
			report.put("p_Acpt_Type",this.findTrCodeNameByCodeType(log.getDealCode()));
			report.put("p_Oper_Name",oper.getName());
			report.put("p_Acept_Amt",Arith.cardreportsmoneydiv(amt + ""));
			report.put("p_Bank_Num",bankNo);
			report.put("p_Acpt_Time",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));		
			this.saveSysReport(log,report,"/reportfiles/WangDianCunQuKuanPZ.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 》》网点存款确认（新版需要确认才进行实际转账）
	 * @param oper
	 * @param amt
	 * @param bankNo
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public Long saveCertainDepositConfirm(Users oper,Long dealNo) throws CommonException{
		try{
			//1.记录操作日志
			SysActionLog log = (SysActionLog) BeanUtils.cloneBean(this.getCurrentActionLog());
			log.setDealCode(DealCode.BRANCH_DEPOSIT_CONFIRM);
			log.setMessage("网点存款确认,原待确认流水" + dealNo);
			publicDao.save(log);
			//2.调存储过程进行网点存款
			TrServRec oldRec = (TrServRec) this.findOnlyRowByHql("from TrServRec t where t.dealNo = " + dealNo);
			if(oldRec == null){
				throw new CommonException("根据流水【" + dealNo + "】找不到网点存款待确认记录！");
			}
			if(Tools.processNull(oldRec.getDealState()).equals(Constants.TR_STATE_ZC)){
				throw new CommonException("根据流水【" + dealNo + "】找到的网点存款记录已经确认，无需重复确认！");
			}
			if(!Tools.processNull(oldRec.getDealState()).equals(Constants.TR_STATE_HJL)){
				throw new CommonException("根据流水【" + dealNo + "】找到的网点存款记录不是待确认状态！");
			}
			SysActionLog oldLog = (SysActionLog) this.findOnlyRowByHql("from SysActionLog t where t.dealNo = " + dealNo);
			if(oldLog == null){
				throw new CommonException("网点存款原操作流水不存在！");
			}
			oldLog.setDealTime(log.getDealTime());
			oldLog.setMessage(oldLog.getMessage() + "，确认");
			HashMap depositMap = new HashMap();
			depositMap.put("item_no","102100");//科目 机构往来款
			depositMap.put("amt",oldRec.getAmt() + "");//网点存款金额
			depositMap.put("acpt_type", Constants.ACPT_TYPE_GM);//受理点类型
			depositMap.put("pay_source","0");//科目 机构往来款
			SysActionLog newLog = new SysActionLog();
			newLog.setDealNo(oldLog.getDealNo());
			newLog.setBrchId(oldLog.getBrchId());
			newLog.setOrgId(oldLog.getOrgId());
			newLog.setUserId(oldLog.getUserId());
			newLog.setDealTime(log.getDealTime());
			newLog.setMessage(oldLog.getMessage() + "，确认");
			newLog.setDealCode(DealCode.BRANCH_DEPOSIT_CONFIRM);//GECC--入参数前面，强行赋值
			accService.cost(newLog,depositMap);
			//3.修改原网点存款状态
			int iscount = publicDao.doSql("update tr_serv_rec set deal_state = '" + Constants.TR_STATE_ZC + "',clr_date = '" + 
			this.getClrDate() + "',old_deal_no = " + log.getDealNo() + " where deal_no = " + dealNo);
			if(iscount != 1){
				throw new CommonException("根据流水【" + dealNo + "】确认网点存款记录，更新" + iscount + "行！");
			}
			int frzcount = publicDao.doSql("UPDATE cash_box t SET t.frz_amt = NVL(t.frz_amt,0) - " + Math.abs(oldRec.getAmt()) +  " WHERE t.brch_id = '" + oldRec.getBrchId() + "' AND t.user_id = '" + oldRec.getUserId() + "'");
			if(frzcount != 1){
				throw new CommonException("确认网点存款时，解冻尾箱金额更新" + frzcount + "行！");
			}
			//4.记录业务操作日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setBizTime(log.getDealTime());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setNote(log.getMessage());
			rec.setOldDealNo(dealNo);
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(this.getClrDate());
			rec.setAmt(oldRec.getAmt());
			publicDao.save(rec);
			//4.记录报表日志
			JSONObject report = new JSONObject();
			report.put("p_Action_No",log.getDealNo());
			report.put("p_Print_Time",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));
			SysBranch branch = (SysBranch) this.findOnlyRowByHql(" from SysBranch t where t.brchId = '" + oper.getBrchId() + "'");
			if(branch == null){
				branch = new SysBranch();
			}
			report.put("p_Branch_Name",branch.getFullName());
			report.put("p_Acpt_Type",this.findTrCodeNameByCodeType(log.getDealCode()));
			report.put("p_Oper_Name",oper.getName());
			//report.put("p_Acept_Amt",Arith.cardreportsmoneydiv(amt + ""));
			//report.put("p_Bank_Num",bankNo);
			report.put("p_Acpt_Time",DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));		
			//this.saveSysReport(log,report,"/reportfiles/WangDianCunQuKuanPZ.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
			return log.getDealNo();
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	public Long calculateAvailableCashboxAmt(String brchId,String userId) throws CommonException{
		try{
			Long av_res = 0L;
			BigDecimal bd = (BigDecimal) this.findOnlyFieldBySql("");
			return av_res;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	public AccAcountService getAccService() {
		return accService;
	}
	public void setAccService(AccAcountService accService) {
		this.accService = accService;
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public SysActionLog saveLog(SysActionLog log) {
		publicDao.save(log);
		
		TrServRec tr = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
		tr.setClrDate(getClrDate());
		tr.setBrchId(log.getBrchId());
		tr.setDealCode(log.getDealCode());
		tr.setOrgId(log.getOrgId());
		tr.setNote(log.getMessage());
		publicDao.save(tr);
		
		return log;
	}
}
