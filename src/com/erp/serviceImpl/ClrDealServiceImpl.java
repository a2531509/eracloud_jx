package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.net.ftp.FTPClientConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.BaseCoOrg;
import com.erp.model.CardBaseinfo;
import com.erp.model.PayCoCheckList;
import com.erp.model.PayCoCheckSingle;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.AccAcountService;
import com.erp.service.AdjustSysAccService;
import com.erp.service.ClrDealService;
import com.erp.service.DoWorkClientService;
import com.erp.task.DefaultFTPClient;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.Tools;

@Service("clrDealService")
@SuppressWarnings("rawtypes")
public class ClrDealServiceImpl extends BaseServiceImpl implements ClrDealService {
	@Autowired
	private AccAcountService acc;
	private String url;
	private String host_upload_path;
	private String host_download_path;
	private String port;
	private String pwd;
	private String userName;
	private String host_history_path;
	
	@Autowired
	private DoWorkClientService doWorkService;
	@Resource(name="adjustSysAccService")
	private AdjustSysAccService adjustSysAccService;

	@SuppressWarnings({"unchecked"})
	@Override
	public void saveDealdzcorepair(String fileListId, Users user,SysActionLog actionLog) throws CommonException {
		try {
			// 1保存业务日志
			actionLog.setDealCode(DealCode.CO_CHECK_LIST_COREPAIR);
			publicDao.save(actionLog);
			
			// 2根据fileListId查询对账明细记录，根据记录判断是否可以进行该操作
			PayCoCheckList checkList = (PayCoCheckList) this.findOnlyRowByHql("from PayCoCheckList t where t.id = '" + fileListId + "'");
			if (checkList == null) {
				throw new CommonException("根据选中的记录无法找到对账明细信息，请确认选择是否有误！");
			} else if ("1".equals(checkList.getOperState())) {
				throw new CommonException("对账明细已经处理过了！");
			} else if (!checkList.getState().equals("1") && !checkList.getState().equals("4")) {
				throw new CommonException("选中的记录不是《运营机构多出数据》，不能进行合作机构补充值，请选择《合作机构撤销》或《运营机构补交易》");
			}
			PayCoCheckSingle sign = (PayCoCheckSingle)this.findOnlyRowByHql("from PayCoCheckSingle t1 where t1.id ='" + checkList.getFileid() + "'");
			
			String clrDate = this.getClrDate();
			if("4".equals(checkList.getState())){ //如果是灰记录则确认灰记录
				String date1 = (String) findOnlyFieldBySql("select to_char(deal_date, 'yyyymm') from acc_inout_detail where deal_no = '" + checkList.getOldActionNo() + "'");
				if (date1 == null) {
					throw new CommonException("灰记录不存在！");
				}
				actionLog.setDealCode(DealCode.RECHARGE_WALLET_HJL_QR);
				actionLog.setMessage("灰记录确认：原业务流水:" + checkList.getOldActionNo());
				//4.调存存储过程
				HashMap hm = new HashMap();
				hm.put("deal_no",checkList.getOldActionNo());//处理流水
				hm.put("clr_date",clrDate);//清分日期
				hm.put("card_no",checkList.getCardNo());//卡号
				acc.rechargeConfirm(actionLog, hm);
				
				// 修改对账状态
				String date2 = clrDate.substring(0, 7).replace("-", "");
				publicDao.doSql("update pay_card_deal_rec_" + date1 + " set posp_proc_state = '0' where deal_no = '" + checkList.getOldActionNo() + "'");
				if(!date1.equals(date2)){
					publicDao.doSql("insert into pay_card_deal_rec_" + date2 + " select * from pay_card_deal_rec_" + date1 + " where deal_no = '" + checkList.getOldActionNo() + "'");
					publicDao.doSql("delete from pay_card_deal_rec_" + date1 + " where deal_no = '" + checkList.getOldActionNo() + "'");
				}
			}
			// 3修改对账明细记录
			checkList.setDealNo(actionLog.getDealNo());
			checkList.setOperType("03");
			checkList.setUserId(actionLog.getUserId());
			checkList.setBz("合作机构补交易进行平账");
			checkList.setOperState("1");
			checkList.setState("0");
			publicDao.update(checkList);
			
			// 修改对账状态
			publicDao.doSql("update pay_card_deal_rec_" + checkList.getClrDate().substring(0, 7).replace("-", "") + " set posp_proc_state = '0' where deal_no = '" + checkList.getOldActionNo() + "'");
			
			// 4判断对账明细数据是否全部处理完成，如果全部处理完成，则进行最后对账数据的统计
			// 实际笔数 = 两边存在的笔数+运营机构补交易+合作机构补交易
			BigDecimal checkbillCount = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t where t.fileid = '"+checkList.getFileid()+"' and t.oper_state = '0'");
			if(checkbillCount.intValue() == 0){
				saveEndDeal(checkList.getFileid().toString(),sign.getFileType(),actionLog.getDealNo());
			}
		} catch (Exception e) {
			throw new CommonException("平账《合作机构补充值》发生错误："+e.getMessage());
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveDealdzorgcancel(String fileListId, Users user,SysActionLog actionLog) throws CommonException {
		try {
			// 1保存业务日志
			actionLog.setMessage("运营机构撤销交易进行平账");
			publicDao.save(actionLog);
			
			// 2根据fileListId查询对账明细记录，根据记录判断是否可以进行该操作
			PayCoCheckList checkList = (PayCoCheckList) this.findOnlyRowByHql("from PayCoCheckList t where t.id = '" + fileListId + "'");
			if (checkList == null) {
				throw new CommonException("根据选中的记录无法找到对对账明细信息，请确认选择是否有误！");
			} else if ("1".equals(checkList.getOperState())) {
				throw new CommonException("对账明细已经处理过了！");
			} else if (!checkList.getState().equals("1") && !checkList.getState().equals("4")) {
				throw new CommonException("选中的记录不是《运营机构多出数据》，不能进行运营机构撤销，请选择《合作机构撤销》或《运营机构补交易》");
			}
			PayCoCheckSingle sign = (PayCoCheckSingle) findOnlyRowByHql("from PayCoCheckSingle t1 where t1.id ='" + checkList.getFileid() + "'");
			
			// 3修改对账明细记录
			checkList.setOperType("02");
			checkList.setUserId(actionLog.getUserId());
			checkList.setBz("运营机构撤销交易进行平账");
			checkList.setOperState("1");
			checkList.setDealNo(actionLog.getDealNo());
			publicDao.update(checkList);
			
			// 4撤销
			if (checkList.getState().equals("1")) { // 运营机构多出
				if(checkList.getDealCode().equals(DealCode.RECHARGE_ACC_CASH)){
					actionLog.setDealCode(DealCode.RECHARGE_ACC_CASH_CX);
				} else if (checkList.getDealCode().equals(DealCode.RECHARGE_QB_CASH)){
					actionLog.setDealCode(DealCode.RECHARGE_QB_CASH_CX);
				}
				saveRechageCancel(checkList, actionLog);
				// 修改对账状态
				publicDao.doSql("update pay_card_deal_rec_" + checkList.getClrDate().substring(0, 7).replace("-", "") + " set posp_proc_state = '0' where deal_no = '" + checkList.getOldActionNo() + "'");
				publicDao.doSql("update pay_card_deal_rec_" + getClrDate().substring(0, 7).replace("-", "") + " set posp_proc_state = '0', note = '平账运营机构撤销' where deal_no = '" + actionLog.getDealNo() + "'");
			} else { // 运营机构多出（灰记录）
				Object hjl = (Object) findOnlyFieldBySql("select deal_no from acc_inout_detail where deal_state = '09' and deal_no = '" + checkList.getOldActionNo() + "'");
				if (hjl != null) {
					actionLog.setDealCode(DealCode.RECHARGE_WALLET_HJL_QX);
					actionLog.setMessage("灰记录取消,原业务流水:" + checkList.getOldActionNo());
					HashMap hm = new HashMap();
					hm.put("deal_no",checkList.getOldActionNo());//原来交易序列
					hm.put("card_no",checkList.getCardNo());//原交易卡号
					hm.put("deal_state",Constants.TR_STATE_HJL);//原充值记录状态
					hm.put("card_tr_count",checkList.getPurseserial());//卡交易计数器
					hm.put("card_bal",checkList.getAmtbef());//钱包交易前金额
					acc.rechargeCancel(actionLog, hm);
				}
			}
			
			// 4判断对账明细数据是否全部处理完成，如果全部处理完成，则进行最后对账数据的统计
			// 实际笔数 = 两边存在的笔数+运营机构补交易+合作机构补交易
			BigDecimal checkbillCount = (BigDecimal) publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t where t.fileid = '" 
					+ checkList.getFileid() + "' and t.oper_state = '0'");
			if (checkbillCount.intValue() == 0) {
				saveEndDeal(checkList.getFileid().toString(), sign.getFileType(), actionLog.getDealNo());
			}
		} catch (Exception e) {
			throw new CommonException("平账《运营机构撤销》发生错误：" + e.getMessage());
		}
		
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveDealdzorgadd(String fileListId, Users user,SysActionLog actionLog) throws CommonException {
		try {
			// 1保存业务日志
			actionLog.setDealCode(DealCode.CO_CHECK_LIST_ORGADD);
			publicDao.save(actionLog);
			
			// 2根据fileListId查询对账明细记录，根据记录判断是否可以进行该操作
			PayCoCheckList checkList = (PayCoCheckList) this.findOnlyRowByHql("from PayCoCheckList t where t.id = '" + fileListId + "'");
			if (checkList == null) {
				throw new CommonException("根据选中的记录无法找到对对账明细信息，请确认选择是否有误！");
			} else if (!checkList.getState().equals("2") && !checkList.getState().equals("3")) {
				throw new CommonException("选中的记录不是《合作机构多出数据》或《运营机构灰记录》，不能进行运营机构补充值，请选择《运营机构撤销》或《合作机构补交易》");
			} else if ("1".equals(checkList.getOperState())) {
				throw new CommonException("选中的记录已处理");
			}
			PayCoCheckSingle sign = (PayCoCheckSingle) this.findOnlyRowByHql("from PayCoCheckSingle t1 where t1.id ='" + checkList.getFileid() + "'");
			
			// 补交易
			String clrDate = this.getClrDate();
			if("3".equals(checkList.getState())){ //如果是灰记录则确认灰记录
				String date1 = (String) findOnlyFieldBySql("select to_char(deal_date, 'yyyymm') from acc_inout_detail where deal_no = '" + checkList.getOldActionNo() + "'");
				if (date1 == null) {
					throw new CommonException("灰记录不存在！");
				}
				actionLog.setDealCode(DealCode.RECHARGE_WALLET_HJL_QR);
				actionLog.setMessage("灰记录确认：原业务流水:" + checkList.getOldActionNo());
				//4.调存存储过程
				HashMap hm = new HashMap();
				hm.put("deal_no",checkList.getOldActionNo());//处理流水
				hm.put("clr_date",clrDate);//清分日期
				hm.put("card_no",checkList.getCardNo());//卡号
				acc.rechargeConfirm(actionLog, hm);
				
				// 修改对账状态
				String date2 = clrDate.substring(0, 7).replace("-", "");
				publicDao.doSql("update pay_card_deal_rec_" + date1 + " set posp_proc_state = '0' where deal_no = '" + checkList.getOldActionNo() + "'");
				if(!date1.equals(date2)){
					publicDao.doSql("insert into pay_card_deal_rec_" + date2 + " select * from pay_card_deal_rec_" + date1 + " where deal_no = '" + checkList.getOldActionNo() + "'");
					publicDao.doSql("delete from pay_card_deal_rec_" + date1 + " where deal_no = '" + checkList.getOldActionNo() + "'");
				}
			} else {
				saveRechageDeal(checkList, actionLog);
				
				// 修改对账状态2011-01-01
				publicDao.doSql("update pay_card_deal_rec_" + clrDate.substring(0, 7).replace("-", "") + " set posp_proc_state = '0' where deal_no = '" + actionLog.getDealNo() + "'");
			}
			
			// 3修改对账明细记录
			checkList.setDealNo(actionLog.getDealNo());
			checkList.setOperType("01");
			checkList.setUserId(actionLog.getUserId());
			checkList.setBz("运营机构补充值进行平账");
			checkList.setOperState("1");
			checkList.setState("0");
			publicDao.update(checkList);
			
			// 4判断对账明细数据是否全部处理完成，如果全部处理完成，则进行最后对账数据的统计
			// 实际笔数 = 两边存在的笔数+运营机构补交易+合作机构补交易
			BigDecimal checkbillCount = (BigDecimal) publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t where t.fileid = '"
							+ checkList.getFileid() + "' and t.oper_state = '0'");
			if (checkbillCount.intValue() == 0) {
				saveEndDeal(checkList.getFileid().toString(), sign.getFileType(), actionLog.getDealNo());
			}
		} catch (Exception e) {
			throw new CommonException("平账《运营机构补交易》发生错误：" + e.getMessage());
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveDealdzdeletemx(String fileListId, Users user,SysActionLog actionLog) throws CommonException {
		try {
			//1根据fileListId查询对账明细记录，根据记录判断是否可以进行该操作
			actionLog.setDealCode(DealCode.CO_CHECK_LIST_CODELETEMX);
			publicDao.save(actionLog);
			
			PayCoCheckList checkList = (PayCoCheckList)this.findOnlyRowByHql("from PayCoCheckList t where t.id = '"+fileListId+"'");
			PayCoCheckSingle sign  = null;
			if(checkList == null){
				throw new CommonException("根据选中的记录无法找到对对账明细信息，请确认选择是否有误！");
			} else if (!checkList.getState().equals("2") && !checkList.getState().equals("3")){
				throw new CommonException("选中的记录不是《合作机构多出数据》，不能进行合作机构撤销，请选择《运营机构撤销》或《合作机构补交易》");
			} else if ("1".equals(checkList.getOperState())) {
				throw new CommonException("选中的记录已处理");
			}
			sign = (PayCoCheckSingle)this.findOnlyRowByHql("from PayCoCheckSingle t1 where t1.id ='"+checkList.getFileid()+"'");
			//2保存业务日志
			//3修改对账明细记录
			checkList.setDealNo(actionLog.getDealNo());
			checkList.setOperType("04");
			checkList.setUserId(actionLog.getUserId());
			checkList.setBz("合作机构撤销交易进行平账");
			checkList.setOperState("1");
			publicDao.update(checkList);
			
			// 补交易
			if ("3".equals(checkList.getState())) { // 如果是灰记录则撤销灰记录
				actionLog.setDealCode(DealCode.RECHARGE_WALLET_HJL_QX);
				actionLog.setMessage("灰记录取消,原业务流水:" + checkList.getOldActionNo());
				HashMap hm = new HashMap();
				hm.put("deal_no", checkList.getOldActionNo());//原来交易序列
				hm.put("card_no", checkList.getCardNo());//原交易卡号
				hm.put("deal_state", Constants.TR_STATE_HJL);//原充值记录状态
				hm.put("card_tr_count", checkList.getPurseserial());//卡交易计数器
				hm.put("card_bal", checkList.getAmtbef());//钱包交易前金额
				acc.rechargeCancel(actionLog, hm);
			}
			
			//4判断对账明细数据是否全部处理完成，如果全部处理完成，则进行最后对账数据的统计
			//实际笔数 = 两边存在的笔数+运营机构补交易+合作机构补交易
			BigDecimal checkbillCount = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t where t.fileid = '"+checkList.getFileid()+"' and"
					+ " t.oper_state = '0'");
			if(checkbillCount.intValue() == 0){
				saveEndDeal(checkList.getFileid().toString(),sign.getFileType(),actionLog.getDealNo());
			}
		} catch (Exception e) {
			throw new CommonException("平账《合作机构记录撤销》发生错误："+e.getMessage());
		}
		
	}
	
	/**
	 * 内部调用方法
	 * @param fileId
	 * @param fileType
	 */
	private void saveEndDeal(String fileId,String fileType,Long actionLog){
		try {
			PayCoCheckSingle single = (PayCoCheckSingle) findOnlyRowByHql("from PayCoCheckSingle where id = '" + fileId + "'");
			if(fileType.equals("01")){//充值
				//查找两边都存在的笔数和金额
				BigDecimal total_comm_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.STATE = '0' and t.deal_code in ('" + DealCode.RECHARGE_QB_CASH + "','" + DealCode.RECHARGE_ACC_CASH + "')");
				BigDecimal total_comm_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.STATE = '0' and t.deal_code in ('" + DealCode.RECHARGE_QB_CASH + "','" + DealCode.RECHARGE_ACC_CASH + "') ");
				//查询运营机构补交易
//				BigDecimal total_Orgadd_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
//						+ " t.OPER_TYPE = '01' and t.deal_code in ('" + DealCode.RECHARGE_QB_CASH + "','" + DealCode.RECHARGE_ACC_CASH + "') ");
//				BigDecimal total_Orgadd_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
//						+ " t.OPER_TYPE = '01' and t.deal_code in ('" + DealCode.RECHARGE_QB_CASH + "','" + DealCode.RECHARGE_ACC_CASH + "') ");
//				//查询合作机构补交易
//				BigDecimal total_Coadd_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
//						+ " t.OPER_TYPE = '03' and t.deal_code in ('" + DealCode.RECHARGE_QB_CASH + "','" + DealCode.RECHARGE_ACC_CASH + "') ");
//				BigDecimal total_Coadd_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
//						+ " t.OPER_TYPE = '03' and t.deal_code in ('" + DealCode.RECHARGE_QB_CASH + "','" + DealCode.RECHARGE_ACC_CASH + "') ");
				publicDao.doSql("update PAY_CO_CHECK_SINGLE t set t.SJ_TOTAL_ZC_SUM = "+(total_comm_sum.intValue())+","
						+ "t.SJ_TOTAL_ZC_AMT ="+(total_comm_amt.intValue())+" where id = '" + fileId + "'");
			}else if(fileType.equals("03")){//('40202010','40102010') ('40102051','40202051')
				//查找两边都存在的笔数和金额
				BigDecimal total_comm_zc_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
					+ " t.STATE = '0' and t.deal_code in ('40202010','40102010')");
				BigDecimal total_comm_zc_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.STATE = '0' and t.deal_code in ('40202010','40102010') ");
				//查询运营机构补交易
				BigDecimal total_Orgadd_zc_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.OPER_TYPE = '01' and t.deal_code in ('40202010','40102010') ");
				BigDecimal total_Orgadd_zc_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.OPER_TYPE = '01' and t.deal_code in ('40202010','40102010') ");
				//查询合作机构补交易
				BigDecimal total_Coadd_zc_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.OPER_TYPE = '03' and t.deal_code in ('40202010','40102010') ");
				BigDecimal total_Coadd_zc_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.OPER_TYPE = '03' and t.deal_code in ('40202010','40102010') ");
				publicDao.doSql("update PAY_CO_CHECK_SINGLE t set t.SJ_TOTAL_ZC_SUM = "+(total_comm_zc_sum.intValue()+total_Orgadd_zc_sum.intValue()+total_Coadd_zc_sum.intValue())+","
						+ "t.SJ_TOTAL_ZC_AMT ="+(total_comm_zc_amt.intValue()+total_Orgadd_zc_amt.intValue()+total_Coadd_zc_amt.intValue())+" where id = '" + fileId + "'");
				
				//查找两边都存在的笔数和金额
				BigDecimal total_comm_th_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
					+ " t.STATE = '0' and t.deal_code in ('40102051','40202051')");
				BigDecimal total_comm_th_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.STATE = '0' and t.deal_code in ('40102051','40202051') ");
				//查询运营机构补交易
				BigDecimal total_Orgadd_th_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.OPER_TYPE = '01' and t.deal_code in ('40102051','40202051') ");
				BigDecimal total_Orgadd_th_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.OPER_TYPE = '01' and t.deal_code in ('40102051','40202051') ");
				//查询合作机构补交易
				BigDecimal total_Coadd_th_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.OPER_TYPE = '03' and t.deal_code in ('40102051','40202051') ");
				BigDecimal total_Coadd_th_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.OPER_TYPE = '03' and t.deal_code in ('40102051','40202051') ");
				publicDao.doSql("update PAY_CO_CHECK_SINGLE t set t.SJ_TOTAL_TH_SUM = "+(total_comm_th_sum.intValue()+total_Orgadd_th_sum.intValue()+total_Coadd_th_sum.intValue())+","
						+ "t.SJ_TOTAL_TH_AMT ="+(total_comm_th_amt.intValue()+total_Orgadd_th_amt.intValue()+total_Coadd_th_amt.intValue())+" where id = '" + fileId + "'");
			}else{
				throw new CommonException("对账类型错误："+fileType);
			}
			publicDao.doSql("update PAY_CO_CHECK_SINGLE set PROC_STATE = '0',deal_no='"+actionLog.toString()+"', DZPZLX = '02' where id ='"+fileId+"'");
			// 统计对账
		} catch (Exception e) {
			throw new CommonException("平账发生错误："+e.getMessage());
		}
	}
	
	/**
	 * 平账充值确认
	 * @param checkList
	 * @param actionLog
	 */
	private void saveRechageDeal(PayCoCheckList checkList,SysActionLog actionLog){
		try {
			CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where cardNo = '" + checkList.getCardNo() + "'");
			if (card == null) {
				throw new CommonException("卡号为【" + checkList.getCardNo() + "】的卡片不存在！");
			} else if (!card.getCardState().equals(Constants.CARD_STATE_ZC)) {
				if(checkList.getDealCode().equals(DealCode.RECHARGE_QB_CASH)){
					throw new CommonException("卡号为【" + checkList.getCardNo() + "】的卡片状态不正常！");
				} else if(checkList.getDealCode().equals(DealCode.RECHARGE_ACC_CASH)){
					card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where customerId = '" + card.getCustomerId() + "' and cardState = '" + Constants.CARD_STATE_ZC + "'");
					if (card == null) {
						throw new CommonException("客户没有正常状态的卡片，无法补充值！");
					}
					checkList.setCardNo(card.getCardNo());
					checkList.setCardNo2(card.getCardNo());
					actionLog.setMessage(actionLog.getMessage() + ", 新卡卡号【" + card.getCardNo() + "】");
				}
			}
			AccAccountSub acc = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where cardNo = '" + card.getCardNo() 
				+ "' and accKind = '" + checkList.getAccKind() + "'");
			if (acc == null) {
				throw new CommonException("卡号【" + card.getCardNo() + "】对应账户不存在");
			}
			//1，根据记录找到充值信息，进行一笔充值 card_no amt
			  //组装参数
			StringBuffer  inpara = new StringBuffer();
			inpara.append(actionLog.getDealNo().toString()+"|");//1action_no
			inpara.append(checkList.getDealCode()+"|");//2tr_code
			inpara.append(actionLog.getUserId()+"|");//3oper_id
			inpara.append(DateUtil.formatDate(actionLog.getDealTime(),"yyyy-MM-dd HH:mm:ss")+"|");//4yyyy-mm-dd hh24:mi:ss
			inpara.append(Tools.processNull(checkList.getAcptId())+"|");//5acpt_id
			inpara.append(Tools.processNull(checkList.getDealBatchNo())+"|");//6tr_batch_no
			inpara.append(Tools.processNull(checkList.getEndDealNo())+"|");//7term_tr_no
			inpara.append(Tools.processNull(acc.getCardNo())+"|");//8card_no
			inpara.append(Tools.processNull(checkList.getPurseserial())+"|");//9card_tr_count
			inpara.append(Tools.processNull(checkList.getAmtbef())+"|");//10card_bal
			inpara.append(Tools.processNull(checkList.getAccKind())+"|");//11acc_kind
			inpara.append("00"+"|");//12wallet_id
			inpara.append(Tools.processNull(checkList.getAmt().toString())+"|");//13tr_amt
			inpara.append("1"+"|");//14pay_source
			inpara.append(Tools.processNull(checkList.getBankAcc())+"|");//15sourcecard
			inpara.append("|");//16rechg_pwd
			inpara.append("平账运营机构确认"+"|");//17note  
			inpara.append("0|");//18tr_state
			if(checkList.getDealCode().equals(DealCode.RECHARGE_ACC_CASH)){
				String encryptBal = doWorkService.money2EncryptCal(acc.getCardNo(), acc.getBal() + "", checkList.getAmt() + "", Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD);
				inpara.append(encryptBal  +"|");//19encrypt ---等待汤伟忠接口
			}else{
				inpara.append("|");//19encrypt 
			}
			inpara.append("2|");//20acpt_type
			inpara.append(acc.getBal() + "|");//21acc_bal
			List<Object> in = new java.util.ArrayList<Object>();
			in.add(inpara.toString());
			in.add("1");
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			try {
				List ret = publicDao.callProc("PK_RECHARGE.P_RECHARGE", in, out);
				if (!(ret == null || ret.size() == 0)) {
					int res = Integer.parseInt(ret.get(0).toString());
					if (res != 0) {
						String outMsg = ret.get(1).toString();
						throw new CommonException(outMsg);
					} 
				} else {
					throw new CommonException("运营机构补记录 《id："+checkList.getId()+"》"+"出错！");
				}
			} catch (Exception ex) {
				ex.printStackTrace();
				throw new CommonException(ex.getMessage());
			}
			
		} catch (Exception e) {
			throw new CommonException("平账充值《id："+checkList.getId()+"》确认发生错："+e.getMessage());
		}
	}

	/**
	 * 平账充值撤销
	 * @param checkList
	 * @param actionLog
	 */
	private void saveRechageCancel(PayCoCheckList checkList,SysActionLog actionLog){
		try {
			TrServRec rec = new TrServRec(actionLog.getDealNo(), actionLog.getDealTime(), actionLog.getUserId());
			rec.setAccKind(checkList.getAccKind());
			rec.setAcptType("2");
			rec.setAmt(checkList.getAmt());
			rec.setDealCode(actionLog.getDealCode());
			rec.setBrchId(actionLog.getBrchId());
			rec.setCardNo(checkList.getCardNo());
			rec.setClrDate(getClrDate());
			rec.setDealState("9");
			rec.setCoOrgId(checkList.getCoOrgId());
			rec.setNote(actionLog.getMessage());
			publicDao.save(rec);
			
			//组装参数--av_in: 1action_no|2tr_code|3oper_id|4oper_time|
			//  --       5action_no|6clr_date|7card_no|8tr_state|9card_tr_count|10card_bal|11撤销后卡账户金额密文
			AccAccountSub acc = new AccAccountSub();
			String balEncrypt = "";
			if (checkList.getDealCode().equals(DealCode.RECHARGE_ACC_CASH)) {
				acc = (AccAccountSub) findOnlyRowByHql("from AccAccountSub where cardNo = '"
						+ checkList.getCardNo() + "' and accKind = '" + Constants.ACC_KIND_ZJZH + "'");
				balEncrypt = doWorkService.money2EncryptCal(acc.getCardNo(), acc.getBal() + "", 
						checkList.getAmt() + "", Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB);
			}
			StringBuffer  inpara = new StringBuffer();
			inpara.append(actionLog.getDealNo().toString() + "|");// 1action_no
			inpara.append(actionLog.getDealCode() + "|");// 2tr_code
			inpara.append(checkList.getEndId() + "|");// 3oper_id
			inpara.append(DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss") + "|");// 4yyyy-mm-dd hh24:mi:ss
			inpara.append(checkList.getOldActionNo() + "|");// 5action_no
			inpara.append(checkList.getClrDate() + "|");// 6clr_date
			inpara.append(checkList.getCardNo() + "|");// 7card_no
			inpara.append("0|");// 8tr_state
			inpara.append("|");// 10card_tr_count
			if (checkList.getDealCode().equals(DealCode.RECHARGE_ACC_CASH)) {
				inpara.append(acc.getBal() + "|");// 10card_bal
			} else {
				inpara.append("|");// 10card_bal
			}
			if (checkList.getDealCode().equals(DealCode.RECHARGE_ACC_CASH)) {
				inpara.append(balEncrypt + "|");// 11encrypt ---等待汤伟忠接口
			} else {
				inpara.append("|");// 11encrypt
			}
			List<Object> in = new java.util.ArrayList<Object>();
			in.add(inpara.toString());
			in.add("1");
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			try {
				List ret = publicDao.callProc("PK_RECHARGE.p_rechargecancel", in, out);
				if (!(ret == null || ret.size() == 0)) {
					int res = Integer.parseInt(ret.get(0).toString());
					if (res != 0) {
						String outMsg = ret.get(1).toString();
						throw new CommonException(outMsg);
					} 
				} else {
					throw new CommonException("运营机构撤销记录 《id："+checkList.getId()+"》"+"出错！");
				}
			} catch (Exception ex) {
				ex.printStackTrace();
				throw new CommonException(ex.getMessage());
			}
		} catch (Exception e) {
			throw new CommonException("平账充值《id："+checkList.getId()+"》撤销发生错："+e.getMessage());
		}
	}
	
	/**
	 * 平账消费确认（暂未实现）
	 * @param checkList
	 * @param actionLog
	 */
	@SuppressWarnings("unused")
	private void saveConsumeDeal(PayCoCheckList checkList,SysActionLog actionLog){
		
	}
	
	/**
	 * 平账消费撤销（暂未实现）
	 * @param checkList
	 * @param actionLog
	 */
	@SuppressWarnings("unused")
	private void saveConsumeCancel(PayCoCheckList checkList,SysActionLog actionLog){
		
	}

	/**
	 * 脱机消费数据处理
	 */
	@Override
	public void saveDealOffilne(SysActionLog actionLog, Users user,String dealNo) throws CommonException {
		try {
			actionLog.setDealCode(DealCode.DEAL_OFFLINE_IN);
			publicDao.save(actionLog);
			//组装参数--dealNo
			List<Object> in = new java.util.ArrayList<Object>();
			in.add(dealNo);
			in.add("1");
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			try {
				List ret = publicDao.callProc("pk_consume.p_black2normal", in, out);
				if (!(ret == null || ret.size() == 0)) {
					int res = Integer.parseInt(ret.get(0).toString());
					if (res != 0) {
						String outMsg = ret.get(1).toString();
						throw new CommonException(outMsg);
					} 
				} else {
					throw new CommonException("脱机数据入账流水号 《dealNo："+dealNo+"》"+"出错！");
				}
			} catch (Exception ex) {
				ex.printStackTrace();
				throw new CommonException(ex.getMessage());
			}
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveGetCheckFile(SysActionLog actionLog, Users user,String coOrgId, String checkDate,String fileType) throws CommonException {
		DefaultFTPClient ftpClient =null;
		try {
			if(!"CZ".equals(fileType)){
				throw new CommonException("暂不支持该类型的对账文件！");
			}
			//-----------------------1获取系统配置的文件目录并判断该对账日期的对账数据是否存在，准许进行文件的获取----------------------
			initFtpPara(coOrgId);
			PayCoCheckSingle signle = (PayCoCheckSingle)this.findOnlyRowByHql("from PayCoCheckSingle where coOrgId = '"+coOrgId+"' and checkDate = '"+checkDate+"'");
			if(signle != null){
				//如果对账文件状态为proc_state, varchar2(1), optional, default = '1', 0对账平，1平账中，2对账不平明细未上传  3 对账不平明细已上传。缺省为1
				if("0".equals(signle.getProcState())||"1".equals(signle.getProcState())||"3".equals(signle.getProcState())){
					throw new CommonException("<font style='color:red'>当前对账文件在系统中存在，且对账状态为不准许重新对账</font>");
				}
			}
			//-----------------------1读取对账文件信息-------------------------------------
			ftpClient = new DefaultFTPClient();
			ftpClient.setControlEncoding("GBK");
			FTPClientConfig conf = new FTPClientConfig(FTPClientConfig.SYST_NT);
			conf.setServerLanguageCode("zh");
			if(!ftpClient.toConnect(url, Integer.parseInt(port))){
				throw new CommonException("ftp连接失败");
			}
			ftpClient.toLogin(userName, pwd);
			ftpClient.enterLocalPassiveMode();
			ftpClient.changeWorkingDirectory(host_upload_path);
			//构造要获取的文件名
			String fileName = fileType+checkDate+coOrgId+".txt";
			List list = null;
			try {
				list = ftpClient.getFileContent(fileName);
			} catch (Exception e) {
				throw new CommonException("<font style='color:red'>文件夹"+host_download_path+"未发现文件名为："+fileName+"的文件！</font>");
			}
			//-----------------------2调用存储过程对总账-----------------------------------
			if(list == null || list.size() == 0){
				throw new CommonException("<font style='color:red'>"+fileName+"对账文件不存在或无记录无需对账！</font>");
			}
			String[] checkTotInfo = list.get(0).toString().split("\\|");
			// 验证总数与明细和是否相同
			int num = 0;
			long amt = 0;
			for (int i = 2; i < list.size(); i++) {
				String[] content = list.get(i).toString().split("\\|", 14);
				num++;
				amt += Long.parseLong(content[9]);
			}
			if(num != (Integer.parseInt(checkTotInfo[0]) + Integer.parseInt(checkTotInfo[2]))){
				throw new CommonException("笔数与明细总笔数不一致");
			}
			if(amt != (Long.parseLong(checkTotInfo[1]) + Long.parseLong(checkTotInfo[3]))){
				throw new CommonException("金额与明细总金额不一致");
			}
			
			List inparam = new ArrayList();
			inparam.add(coOrgId);
			inparam.add(coOrgId);
			inparam.add("");
			inparam.add("");
			inparam.add(fileType.equals("CZ")?"01":"02");
			inparam.add(fileName);
			inparam.add(checkDate);
			inparam.add(checkTotInfo[0]);
			inparam.add(checkTotInfo[1]);
			inparam.add(checkTotInfo[2]);
			inparam.add(checkTotInfo[3]);
			List<Integer> outparam = new java.util.ArrayList<Integer>();
			outparam.add(java.sql.Types.VARCHAR);
			outparam.add(java.sql.Types.VARCHAR);
			List res = publicDao.callProc("pk_co_org_handle.p_check_bill",inparam,outparam);
			if(res == null || res.size() <= 0){
				throw new CommonException("<font style='color:red'>请重新进行操作,对总账发生错误！</font>");
			}
			if(Integer.parseInt(res.get(0) + "") != 0){
				throw new CommonException(res.get(1).toString());
			}
			//-----------------------3明细入账-------------------------------------------
			PayCoCheckSingle sign_now = (PayCoCheckSingle)this.findOnlyRowByHql("from PayCoCheckSingle where coOrgId = '"+coOrgId+"' and checkDate = '"+checkDate+"'");
			if(sign_now == null){
				throw new CommonException("<font style='color:red'>获取对账文件发生错误，对总账没有成功！</font>");
			} else { // 不管总账是否对得上，都要入明细
				for(int i=2;i<list.size();i++){
					if(!"".equals(Tools.processNull(list.get(i)))){
						String[] content = list.get(i).toString().split("\\|", 14);
						List inparam_content = new ArrayList();
						inparam_content.add(Tools.processNull(content[0].toString()));
						inparam_content.add(Tools.processNull(content[0].toString()));
						inparam_content.add(Tools.processNull(content[1].toString()));
						inparam_content.add(Tools.processNull(content[2].toString()));
						inparam_content.add(Tools.processNull(content[3].toString()));
						inparam_content.add("");
						inparam_content.add(Tools.processNull(content[4].toString()));
						inparam_content.add(Tools.processNull(content[5].toString()));
						inparam_content.add(Tools.processNull(content[6].toString()));
						inparam_content.add(Tools.processNull(content[7].toString()));
						inparam_content.add("");
						inparam_content.add("");
						inparam_content.add(Tools.processNull(content[10].toString()));
						inparam_content.add(Tools.processNull(content[11].toString()));
						inparam_content.add(Tools.processNull(content[9].toString()));
						inparam_content.add(Tools.processNull(DateUtil.formatDate(DateUtil.parse("yyyyMMddHHmmss", content[8].toString()))));
						inparam_content.add(Tools.processNull(content[12].toString()));
						inparam_content.add(Tools.processNull(checkDate.substring(0, 4)+"-"+checkDate.substring(4, 6)+"-"+checkDate.substring(6, 8)));
						inparam_content.add(Tools.processNull(checkDate.substring(0, 4)+"-"+checkDate.substring(4, 6)+"-"+checkDate.substring(6, 8)));
						String dealCode = "";
						inparam_content.add(""+i);
						if("CZ".equals(fileType)){
							if(Tools.processNull(content[7].toString()).equals(Constants.ACC_KIND_QBZH)){
								dealCode=DealCode.RECHARGE_QB_CASH.toString();
							}else{
								dealCode=DealCode.RECHARGE_ACC_CASH.toString();
							}
						}
						inparam_content.add(dealCode);
						List<Integer> outparam_content = new java.util.ArrayList<Integer>();
						outparam_content.add(java.sql.Types.VARCHAR);
						outparam_content.add(java.sql.Types.VARCHAR);
						List res_content = publicDao.callProc("pk_co_org_handle.p_check_bill_implist",inparam_content,outparam_content);
						if(res_content == null || res_content.size() <= 0){
							throw new CommonException("<font style='color:red'>请重新进行操作,明细入库发生错误！</font>");
						}
						if(Integer.parseInt(res_content.get(0) + "") != 0){
							throw new CommonException("<font style='color:red'>请重新进行操作,明细入库发生错误："+res_content.get(1).toString()+"</font>");
						}
					}else{
						i = i+1;
						continue;
					}
				}
				
				//-----------------------4对明细账-------------------------------------------
				List inparam_list = new ArrayList();
				inparam_list.add(Tools.processNull(coOrgId));
				inparam_list.add(Tools.processNull(coOrgId));
				inparam_list.add(Tools.processNull(checkDate));
				List<Integer> outparam_list = new java.util.ArrayList<Integer>();
				outparam_list.add(java.sql.Types.VARCHAR);
				outparam_list.add(java.sql.Types.VARCHAR);
				List res_list = publicDao.callProc("pk_co_org_handle.p_check_list_bill",inparam_list,outparam_list);
				if(res_list == null || res_list.size() <= 0){
					throw new CommonException("<font style='color:red'>请重新进行操作,明细对账发生错误！</font>");
				}
				if(Integer.parseInt(res_list.get(0) + "") != 0){
					throw new CommonException("<font style='color:red'>请重新进行操作,明细对账发生错误："+res_list.get(1).toString()+"</font>");
				}
			}
		} catch (Exception e) {
			throw new CommonException("获取合作机构对账发生错误，"+e.getMessage());
		}finally{
			try {
				if(ftpClient!=null){
					ftpClient.logout();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	
	public void initFtpPara(String ftp_use){
		List ftpPara = this.findBySql("select t.ftp_para_name,t.ftp_para_value from SYS_FTP_CONF t where t.ftp_use = '"+ftp_use+"'");
		if(ftpPara==null||ftpPara.size()<=0){
			throw new CommonException("获取ftp配置出错，请联系系统管理员！");
		}
		for(int k=0;k<ftpPara.size();k++){
			Object[] objs = (Object[])ftpPara.get(k);
			if(Tools.processNull(objs[0]).equals("host_ip")){
				this.url=Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("host_upload_path")){
				this.host_upload_path=Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("host_download_path")){
				this.host_download_path=Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("host_history_path")){
				this.host_history_path=Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("host_port")){
				this.port=Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("pwd")){
				this.pwd=Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("user_name")){
				this.userName=Tools.processNull(objs[1]);
			}
		}
	}
	
	
	 /**
	 * 自动取Ftp文件对账
	 * @throws CommonException
	 */
	public void saveAutoFtpCheckFile(String coOrgId) throws CommonException {
		try {
			SysActionLog actionLog = new SysActionLog();
			Users user = (Users) findOnlyRowByHql("from Users where userId = 'admin'");
			String checkDate = "", fileType = "CZ";
			Calendar now = Calendar.getInstance();
			now.setTime(new Date());
			now.add(Calendar.DAY_OF_MONTH, -1);
			checkDate = DateUtil.formatDate(now.getTime(), "yyyyMMdd");
			this.saveGetCheckFile(actionLog, user, coOrgId, checkDate, fileType);
		} catch (Exception e) {
			throw new CommonException("获取合作机构对账发生错误，请重新获取！" + e.getMessage());
		}

	}
	
	@SuppressWarnings("unchecked")
	public void saveCoOrgStat(String coOrgId, Date start) {
		try {
			Calendar startCal = Calendar.getInstance();
			startCal.setTime(start);
			Date now = DateUtils.parse(getClrDate(), "yyyy-MM-dd");

			while (startCal.getTime().compareTo(now) < 0) {
				List<Object> in = new ArrayList<Object>();
				in.add(DateUtil.formatDate(startCal.getTime(), "yyyy-MM-dd"));
				in.add(coOrgId);
				in.add("1");
				List<Integer> out = new ArrayList<Integer>();
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				List rets = publicDao.callProc("pk_statistic.p_stat_charge_consume_co_org", in, out);
				if (!(rets == null || rets.size() == 0)) {
					int res = Integer.parseInt(rets.get(0).toString());
					if (res != 0) {
						String outMsg = rets.get(1).toString();
						throw new CommonException(outMsg);
					}
				} else {
					throw new CommonException("调用合作机构充值统计过程出错！");
				}
				startCal.add(Calendar.DAY_OF_YEAR, 1);
			}
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
}
