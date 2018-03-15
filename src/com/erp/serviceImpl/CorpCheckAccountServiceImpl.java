/**
 * 
 */
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
import com.erp.model.CardBaseinfo;
import com.erp.model.PayCoCheckList;
import com.erp.model.PayCoCheckSingle;
import com.erp.model.PayCoDealRec;
import com.erp.model.SysActionLog;
import com.erp.model.Users;
import com.erp.service.AccAcountService;
import com.erp.service.CorpCheckAccountService;
import com.erp.service.DoWorkClientService;
import com.erp.task.DefaultFTPClient;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.Tools;

/**
 * @author Administrator
 *
 */

@Service("corpCheckAccountService")
@SuppressWarnings("rawtypes")
public class CorpCheckAccountServiceImpl extends BaseServiceImpl implements CorpCheckAccountService  {
	@Autowired
	private AccAcountService acc;
	
	private String url;
	private String host_upload_path;
	private String host_download_path;
	private String port;
	private String pwd;
	private String userName;
	private String host_history_path;
	
	@Resource(name="doWorkClientService")
	private DoWorkClientService doWorkClientService;

	/**
	 * 对账合作机构补交易,只能针对运营机构多出的交易
	 */
	@SuppressWarnings({"unchecked"})
	@Override
	public void saveDealdzcorepair(String fileListId, Users user,SysActionLog actionLog) throws CommonException {
		try {
			//1根据fileListId查询对账明细记录，根据记录判断是否可以进行该操作
			actionLog.setDealCode(DealCode.CO_CHECK_LIST_COREPAIR);
			PayCoCheckList checkList = (PayCoCheckList)this.findOnlyRowByHql("from PayCoCheckList t where t.id = '"+fileListId+"'");
			PayCoCheckSingle sign  = null;
			if(checkList == null){
				throw new CommonException("根据选中的记录无法找到对对账明细信息，请确认选择是否有误！");
			}
			if(!checkList.getState().equals("1")){
				throw new CommonException("选中的记录不是《运营机构多出数据》，不能进行合作机构补充值，请选择《合作机构撤销》或《运营机构补交易》");
			}
			sign = (PayCoCheckSingle)this.findOnlyRowByHql("from PayCoCheckSingle t1 where t1.id ='"+checkList.getFileid()+"'");
			//2保存业务日志
			publicDao.save(actionLog);
			publicDao.doSql("update pay_co_deal_rec t set t.deal_state = '05' where t.deal_no = '" + checkList.getOldActionNo() + "'");
			publicDao.doSql("update pay_card_deal_rec_" + checkList.getClrDate().substring(0, 6).replace("-", "") + " set posp_proc_state = '0' where deal_no = '" + checkList.getOldActionNo() + "'");
			//3修改对账明细记录
			checkList.setDealNo(actionLog.getDealNo());
			checkList.setOperType("03");
			checkList.setUserId(actionLog.getUserId());
			checkList.setBz("运营机构补交易进行平账");
			checkList.setOperState("1");
			publicDao.update(checkList);
			//4判断对账明细数据是否全部处理完成，如果全部处理完成，则进行最后对账数据的统计
			  //实际笔数 = 两边存在的笔数+运营机构补交易+合作机构补交易
			BigDecimal checkbillCount = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t where t.fileid = '"+checkList.getFileid()+"' and"
					+ " t.oper_state = '0'");
			if(checkbillCount.intValue() == 0){
				saveEndDeal(checkList.getFileid().toString(),sign.getFileType(),actionLog.getDealNo());//更新对账的总记录数
			}
		} catch (Exception e) {
			throw new CommonException("平账《合作机构补充值》发生错误："+e.getMessage());
		}
	}

	/**
	 * 运营机构撤销 只能针对运营机构多出数据
	 */
	@Override
	public void saveDealdzorgcancel(String fileListId, Users user,SysActionLog actionLog) throws CommonException {
		try {
			//1根据fileListId查询对账明细记录，根据记录判断是否可以进行该操作
			actionLog.setDealCode(DealCode.CO_CHECK_LIST_ORGCANCEL);
			PayCoCheckList checkList = (PayCoCheckList)this.findOnlyRowByHql("from PayCoCheckList t where t.id = '"+fileListId+"'");
			PayCoCheckSingle sign  = null;
			if(checkList == null){
				throw new CommonException("根据选中的记录无法找到对对账明细信息，请确认选择是否有误！");
			} else if(!checkList.getState().equals("1") && !checkList.getState().equals("4")){
				throw new CommonException("选中的记录不是《运营机构多出数据》，不能进行运营机构撤销，请选择《合作机构撤销》或《运营机构补交易》");
			} else if ("1".equals(checkList.getOperState())) {
				throw new CommonException("选中的记录已处理");
			}
			sign = (PayCoCheckSingle)this.findOnlyRowByHql("from PayCoCheckSingle t1 where t1.id ='"+checkList.getFileid()+"'");
			//2保存业务日志
			publicDao.save(actionLog);
			//3修改对账明细记录
			checkList.setDealNo(actionLog.getDealNo());
			checkList.setOperType("02");
			checkList.setUserId(actionLog.getUserId());
			checkList.setBz("运营机构撤销交易进行平账");
			checkList.setOperState("1");
			publicDao.update(checkList);
			// 如果是灰记录则撤销灰记录
			if ("4".equals(checkList.getState())) { // 如果是灰记录则撤销灰记录
				Object hjl = (Object) findOnlyFieldBySql("select deal_no from acc_inout_detail where deal_state = '09' and deal_no = '" + checkList.getOldActionNo() + "'");
				if (hjl != null) {
					actionLog.setDealCode(DealCode.RECHARGE_WALLET_HJL_QX);
					actionLog.setMessage("灰记录取消,原业务流水:" + checkList.getOldActionNo());

					HashMap hm = new HashMap();
					hm.put("deal_no", checkList.getOldActionNo());// 原来交易序列
					hm.put("card_no", checkList.getCardNo());// 原交易卡号
					hm.put("deal_state", Constants.TR_STATE_HJL);// 原充值记录状态
					hm.put("card_tr_count", checkList.getPurseserial());// 卡交易计数器
					hm.put("card_bal", checkList.getAmtbef());// 钱包交易前金额
					acc.rechargeCancel(actionLog, hm);
				}
				publicDao.doSql("update pay_co_deal_rec set deal_state = '02' where deal_no = '" + checkList.getOldActionNo() + "'");
			} else {
				saveRechageCancel(checkList,actionLog,sign);
			}
			//4判断对账明细数据是否全部处理完成，如果全部处理完成，则进行最后对账数据的统计
			//实际笔数 = 两边存在的笔数+运营机构补交易+合作机构补交易
			BigDecimal checkbillCount = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t where t.fileid = '"+checkList.getFileid()+"' and"
					+ " t.oper_state = '0'");
			if(checkbillCount.intValue() == 0){
				saveEndDeal(checkList.getFileid().toString(),sign.getFileType(),actionLog.getDealNo());
			}
		} catch (Exception e) {
			throw new CommonException("平账《运营机构撤销》发生错误："+e.getMessage());
		}
		
	}
	/**
	 * 运营机构补交易
	 */
	@SuppressWarnings("unchecked")
	@Override
	public void saveDealdzorgadd(String fileListId, Users user,SysActionLog actionLog) throws CommonException {
		try {
			//1根据fileListId查询对账明细记录，根据记录判断是否可以进行该操作
			actionLog.setDealCode(DealCode.CO_CHECK_LIST_ORGADD);
			publicDao.save(actionLog);
			PayCoCheckList checkList = (PayCoCheckList)this.findOnlyRowByHql("from PayCoCheckList t where t.id = '"+fileListId+"'");
			PayCoCheckSingle sign  = null;
			if (checkList == null) {
				throw new CommonException("根据选中的记录无法找到对对账明细信息，请确认选择是否有误！");
			} else if (!checkList.getState().equals("2") && !checkList.getState().equals("3")) {
				throw new CommonException("选中的记录不是《合作机构多出数据》或《运营机构灰记录》，不能进行运营机构补充值，请选择《运营机构撤销》或《合作机构补交易》");
			} else if ("1".equals(checkList.getOperState())) {
				throw new CommonException("选中的记录已处理");
			}
			sign = (PayCoCheckSingle)this.findOnlyRowByHql("from PayCoCheckSingle t1 where t1.id ='"+checkList.getFileid()+"'");
			//2保存业务日志
			//3修改对账明细记录
			checkList.setDealNo(actionLog.getDealNo());
			checkList.setOperType("01");
			checkList.setUserId(actionLog.getUserId());
			checkList.setBz("运营机构补交易进行平账");
			checkList.setOperState("1");
			publicDao.update(checkList);
			//
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
				String date2 = clrDate.substring(0, 6).replace("-", "");
				publicDao.doSql("update pay_card_deal_rec_" + date1 + " set posp_proc_state = '0' where deal_no = '" + checkList.getOldActionNo() + "'");
				if(!date1.equals(date2)){
					publicDao.doSql("insert into pay_card_deal_rec_" + date2 + " select * from pay_card_deal_rec_" + date1 + " where deal_no = '" + checkList.getOldActionNo() + "'");
					publicDao.doSql("delete from pay_card_deal_rec_" + date1 + " where deal_no = '" + checkList.getOldActionNo() + "'");
				}
				publicDao.doSql("update pay_co_deal_rec set deal_state = '05' where deal_no = '" + checkList.getOldActionNo() + "'");
			} else {
				saveRechageDeal(checkList,actionLog,sign);
			}
			//4判断对账明细数据是否全部处理完成，如果全部处理完成，则进行最后对账数据的统计
			  //实际笔数 = 两边存在的笔数+运营机构补交易+合作机构补交易
			BigDecimal checkbillCount = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t where t.fileid = '"+checkList.getFileid()+"' and"
					+ " t.oper_state = '0'");
			if(checkbillCount.intValue() == 0){
				saveEndDeal(checkList.getFileid().toString(),sign.getFileType(),actionLog.getDealNo());
			}
		} catch (Exception e) {
			throw new CommonException("平账《运营机构补交易》发生错误："+e.getMessage());
		}
		
	}

	/**
	 * 合作机构撤销
	 */
	@Override
	public void saveDealdzdeletemx(String fileListId, Users user,SysActionLog actionLog) throws CommonException {
		try {
			//1根据fileListId查询对账明细记录，根据记录判断是否可以进行该操作
			actionLog.setDealCode(DealCode.CO_CHECK_LIST_CODELETEMX);
			PayCoCheckList checkList = (PayCoCheckList)this.findOnlyRowByHql("from PayCoCheckList t where t.id = '"+fileListId+"'");
			PayCoCheckSingle sign  = null;
			if(checkList == null){
				throw new CommonException("根据选中的记录无法找到对对账明细信息，请确认选择是否有误！");
			} else if(!checkList.getState().equals("2")  && !checkList.getState().equals("3")){
				throw new CommonException("选中的记录不是《合作机构多出数据》，不能进行合作机构撤销，请选择《运营机构撤销》或《合作机构补交易》");
			} else if ("1".equals(checkList.getOperState())) {
				throw new CommonException("选中的记录已处理");
			}
			sign = (PayCoCheckSingle)this.findOnlyRowByHql("from PayCoCheckSingle t1 where t1.id ='"+checkList.getFileid()+"'");
			//2保存业务日志
			publicDao.save(actionLog);
			//3修改对账明细记录
			checkList.setDealNo(actionLog.getDealNo());
			checkList.setOperType("04");
			checkList.setUserId(actionLog.getUserId());
			checkList.setBz("合作机构撤销交易进行平账");
			checkList.setOperState("1");
			publicDao.update(checkList);
			
			// 如果是灰记录则撤销灰记录
			if ("3".equals(checkList.getState())) { // 如果是灰记录则撤销灰记录
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
				publicDao.doSql("update pay_co_deal_rec set deal_state = '02' where deal_no = '" + checkList.getOldActionNo() + "'");
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
			if(fileType.equals("01")){// ('30105020','30105010');
				//查找两边都存在的笔数和金额
				BigDecimal total_comm_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.STATE = '0' and t.deal_code in ('" + DealCode.RECHARGE_QB_CASH + "','" + DealCode.RECHARGE_ACC_CASH + "', '" + DealCode.RECHARGE_ACC_TO_QB + "')");
				BigDecimal total_comm_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.STATE = '0' and t.deal_code in ('" + DealCode.RECHARGE_QB_CASH + "','" + DealCode.RECHARGE_ACC_CASH + "', '" + DealCode.RECHARGE_ACC_TO_QB + "') ");
				publicDao.doSql("update PAY_CO_CHECK_SINGLE t set t.SJ_TOTAL_ZC_SUM = "+(total_comm_sum.intValue())+","
						+ "t.SJ_TOTAL_ZC_AMT ="+(total_comm_amt.intValue())+" where id = '" + fileId + "'");
			}else if(fileType.equals("02")){//('40202010','40102010') ('40102051','40202051')
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
				publicDao.doSql("update PAY_CO_CHECK_SINGLE t set t.proc_state = '0', t.SJ_TOTAL_ZC_SUM = "+(total_comm_zc_sum.intValue()+total_Orgadd_zc_sum.intValue()+total_Coadd_zc_sum.intValue())+","
						+ "t.SJ_TOTAL_ZC_AMT ="+(total_comm_zc_amt.intValue()+total_Orgadd_zc_amt.intValue()+total_Coadd_zc_amt.intValue())+" where t.id ='"+fileId+"'");
				
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
				publicDao.doSql("update PAY_CO_CHECK_SINGLE t set t.proc_state = '0', t.SJ_TOTAL_TH_SUM = "+(total_comm_th_sum.intValue()+total_Orgadd_th_sum.intValue()+total_Coadd_th_sum.intValue())+","
						+ "t.SJ_TOTAL_TH_AMT ="+(total_comm_th_amt.intValue()+total_Orgadd_th_amt.intValue()+total_Coadd_th_amt.intValue())+" where t.id ='"+fileId+"'");
			}else if(fileType.equals("03")){
				BigDecimal total_comm_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.STATE = '0' and t.deal_code ='30105070'");
					BigDecimal total_comm_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
							+ " t.STATE = '0' and t.deal_code ='30105070' ");
					//查询运营机构补交易
					BigDecimal total_Orgadd_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
							+ " t.OPER_TYPE = '01' and t.deal_code ='30105070' ");
					BigDecimal total_Orgadd_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
							+ " t.OPER_TYPE = '01' and t.deal_code ='30105070' ");
					//查询合作机构补交易
					BigDecimal total_Coadd_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
							+ " t.OPER_TYPE = '03' and t.deal_code ='30105070' ");
					BigDecimal total_Coadd_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
							+ " t.OPER_TYPE = '03' and t.deal_code ='30105070' ");
					publicDao.doSql("update PAY_CO_CHECK_SINGLE t set t.proc_state = '0', t.SJ_TOTAL_ZC_SUM = "+(total_comm_sum.intValue()+total_Orgadd_sum.intValue()+total_Coadd_sum.intValue())+","
							+ "t.SJ_TOTAL_ZC_AMT ="+(total_comm_amt.intValue()+total_Orgadd_amt.intValue()+total_Coadd_amt.intValue())+" where t.id ='"+fileId+"'");
			}else if(fileType.equals("04")){
				//查找两边都存在的笔数和金额
				BigDecimal total_comm_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
					+ " t.STATE = '0' and t.deal_code ='30105090'");
				BigDecimal total_comm_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.STATE = '0' and t.deal_code ='30105090' ");
				//查询运营机构补交易
				BigDecimal total_Orgadd_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.OPER_TYPE = '01' and t.deal_code ='30105090' ");
				BigDecimal total_Orgadd_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.OPER_TYPE = '01' and t.deal_code ='30105090' ");
				//查询合作机构补交易
				BigDecimal total_Coadd_sum = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.OPER_TYPE = '03' and t.deal_code ='30105090' ");
				BigDecimal total_Coadd_amt = (BigDecimal)publicDao.findOnlyFieldBySql("select nvl(sum(t.amt),0) from pay_co_check_list t  where t.fileid = '"+fileId+"' and"
						+ " t.OPER_TYPE = '03' and t.deal_code ='30105090' ");
				publicDao.doSql("update PAY_CO_CHECK_SINGLE t set t.proc_state = '0',t.SJ_TOTAL_ZC_SUM = "+(total_comm_sum.intValue()+total_Orgadd_sum.intValue()+total_Coadd_sum.intValue())+","
						+ "t.SJ_TOTAL_ZC_AMT ="+(total_comm_amt.intValue()+total_Orgadd_amt.intValue()+total_Coadd_amt.intValue())+" where t.id ='"+fileId+"'");
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
	private void saveRechageDeal(PayCoCheckList checkList,SysActionLog actionLog,PayCoCheckSingle sign){
		try {
			if(sign.getFileType().equals("01")||sign.getFileType().equals("04")){//充值（圈存）或圈付
				StringBuffer  inpara = new StringBuffer();
				inpara.append(actionLog.getDealNo() + "|");//1action_no
				if(sign.getFileType().equals("01")){//2tr_code 
					inpara.append("30106010" + "|");
				}else{
					inpara.append("30106020" + "|");
				}
				inpara.append("0001"+"|");//3item_type
				inpara.append(DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")+"|");//4oper_time
				inpara.append("01"+"|");//5acpt_type  
				inpara.append(checkList.getCoOrgId()+"|");//6acpt_id 
				inpara.append(""+"|");//7oper_id
				inpara.append(this.getClrDate().replaceAll("-", "")+"|"); //8end_batch_no
				inpara.append(DateUtil.formatDate(this.getDateBaseTime(), "HHMMSS")+"|");//9end_deal_no 
				inpara.append("03"+"|");//10source  
				inpara.append(""+"|");//11source_id
				inpara.append(""+"|");//12source_name
				inpara.append(""+"|");//13source_description
				inpara.append(checkList.getAccKind()+"|");//14acc_kind 
				inpara.append(checkList.getAmt()+"|");//15amt
				CardBaseinfo cardinfo = null;
				String cardNo = "";
				if(Tools.processNull(checkList.getCardNo()).length() == 9 ){
					cardNo = (String)this.findOnlyFieldBySql("select card_no from Card_Baseinfo a where a.sub_Card_No ='"+checkList.getCardNo()+"' and a.last_Modify_Date ="
							+ " (SELECT max(t.last_Modify_Date) FROM Card_Baseinfo t WHERE t.sub_Card_No  ='"+checkList.getCardNo()+"' AND t.card_State = '1')");
				}else if(Tools.processNull(checkList.getCardNo()).length() == 20 ){
					cardNo = checkList.getCardNo();
				}else{
					throw new CommonException("账明细未中卡号格式不正确！");
				}
				if(cardNo.equals("")){
					throw new CommonException("根据对账明细未中卡号未查询到卡信息！");
				}
				
				cardinfo = (CardBaseinfo)this.findOnlyRowByHql("from CardBaseinfo a where a.cardNo ='"+cardNo+"' and a.cardState = '1'");
				
				if(cardinfo == null ){
					throw new CommonException("根据对账明细未中卡号未查询到卡信息！");
				}
				
				AccAccountSub account_sub = (AccAccountSub)this.findOnlyRowByHql("from AccAccountSub t where t.cardNo ='"+
						cardinfo.getCardNo()+"' and t.accKind ='"+checkList.getAccKind()+"'");
				
				if(account_sub == null){
					throw new CommonException("未查询到对账记录的账户信息！");
				}
				inpara.append(account_sub.getBal()+"|");//16acc_bal
				String entry = "";
				if(!account_sub.getAccKind().equals("01")){
					entry = doWorkClientService.money2EncryptCal(cardinfo.getCardNo(), account_sub.getBal().toString(),
							checkList.getAmt().toString(), Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD);
				}
				inpara.append(entry+"|");//17encrypt
				inpara.append(cardinfo.getCardNo()+"|");//18cardno  
				if(sign.getFileType().equals("01")){//19qcorqf 
					inpara.append("0" + "|");
				}else{
					inpara.append("1" + "|");
				}
				inpara.append(checkList.getCoOrgId()+"|");//20dz_acpt_id   
				List<Object> in = new java.util.ArrayList<Object>();
				in.add(inpara.toString());
				List<Integer> out = new java.util.ArrayList<Integer>();
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				try {
					List ret = publicDao.callProc("pk_co_service.online_recharge", in, out);
					if (!(ret == null || ret.size() == 0)) {
						int res = Integer.parseInt(ret.get(1).toString());
						if (res != 0) {
							String outMsg = ret.get(2).toString();
							throw new CommonException(outMsg);
						} 
					} else {
						throw new CommonException("运营机构补充值记录 《id："+checkList.getId()+"》"+"出错！");
					}
					publicDao.doSql("update pay_co_deal_rec t set t.deal_State = '05',t.rsv_five = '"+checkList.getOldActionNo()+"' where t.deal_no = '"+actionLog.getDealNo()+"'");
				} catch (Exception ex) {
					ex.printStackTrace();
					throw new CommonException(ex.getMessage());
				}
			}else if(sign.getFileType().equals("02")){//消费
				throw new CommonException("暂时不支持该类型对账文件的处理！");
			}else if(sign.getFileType().equals("03")){//圈提
				//组装调用存储过程参数	
				PayCoDealRec coDealRec = (PayCoDealRec)this.findOnlyRowByHql("from PayCoDealRec t where t.dealNo='"+checkList.getOldActionNo()+"' and t.dealState='04'");
			    if(coDealRec == null ){
			    	throw new CommonException("未查询到要撤销的圈提明细信息！");
			    }
				StringBuffer  inpara = new StringBuffer();
				CardBaseinfo cardinfo = null;
				String cardNo = "";
				if(Tools.processNull(checkList.getCardNo()).length() == 9 ){
					cardNo = (String)this.findOnlyFieldBySql("select card_no from Card_Baseinfo a where a.sub_Card_No ='"+checkList.getCardNo()+"' and a.last_Modify_Date ="
							+ " (SELECT max(t.last_Modify_Date) FROM Card_Baseinfo t WHERE t.sub_Card_No  ='"+checkList.getCardNo()+"' AND t.card_State = '1')");
				}else if(Tools.processNull(checkList.getCardNo()).length() == 20 ){
					cardNo = checkList.getCardNo();
				}else{
					throw new CommonException("账明细未中卡号格式不正确！");
				}
				if(cardNo.equals("")){
					throw new CommonException("根据对账明细未中卡号未查询到卡信息！");
				}
				
				cardinfo = (CardBaseinfo)this.findOnlyRowByHql("from CardBaseinfo a where a.cardNo ='"+cardNo+"' and a.cardState = '1'");
				
				if(cardinfo == null ){
					throw new CommonException("根据对账明细未中卡号未查询到卡信息！");
				}
				inpara.append(inpara.append(actionLog.getDealNo()) + "|");//1action_no
				inpara.append("30105070"+"|");//2tr_code
				inpara.append("0003"+"|");//3item_type 
				inpara.append(DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")+"|");//4oper_time
				inpara.append("01"+"|");//5acpt_type 
				inpara.append(coDealRec.getDzAcptId()+"|");//6acpt_id
				inpara.append("cooouser"+"|");//7oper_id
				inpara.append(this.getClrDate().replaceAll("-", "")+"|");//8end_batch_no
				inpara.append(DateUtil.formatDate(this.getDateBaseTime(), "HHMMSS")+"|");//9end_deal_no
				inpara.append(coDealRec.getSource()+"|");//10source
				inpara.append(""+"|");//11source_id
				inpara.append(""+"|");//12source_name
				inpara.append(""+"|");//13source_description
				inpara.append(checkList.getAccKind()+"|");//14acc_kind
				inpara.append(checkList.getAmt()+"|");//15amt
				AccAccountSub account_sub = (AccAccountSub)this.findOnlyRowByHql("from AccAccountSub t where t.cardNo ='"+
							cardinfo.getCardNo()+"' and t.accKind ='"+checkList.getAccKind()+"'");
				
				if(account_sub == null){
					throw new CommonException("未查询到对账记录的账户信息！");
				}
				String entry = "";
				if(!account_sub.getAccKind().equals("01")){
					entry = doWorkClientService.money2EncryptCal(checkList.getCardNo(), account_sub.getBal().toString(),
							checkList.getAmt().toString(), Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB);
				}
				inpara.append(account_sub.getBal()+"|");//16acc_bal
				inpara.append(entry+"|");//17encrypt 
				inpara.append(cardinfo.getCardNo()+"|");//18cardno 
				inpara.append(checkList.getCoOrgId());//19dz_acpt_id
				List<Object> in = new java.util.ArrayList<Object>();
				in.add(inpara.toString());
				List<Integer> out = new java.util.ArrayList<Integer>();
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				try {
					List ret = publicDao.callProc("pk_co_service.online_qt_handle_undo", in, out);
					if (!(ret == null || ret.size() == 0)) {
						int res = Integer.parseInt(ret.get(0).toString());
						if (res != 0) {
							String outMsg = ret.get(1).toString();
							throw new CommonException(outMsg);
						} 
					} else {
						throw new CommonException("运营机构撤销记录 《id："+checkList.getOldActionNo()+"》"+"出错！");
					}
					publicDao.doSql("update pay_co_deal_rec t set t.deal_State = '05',t.rsv_five = '"+checkList.getOldActionNo()+"' where t.deal_no = '"+actionLog.getDealNo()+"'");
				} catch (Exception ex) {
					ex.printStackTrace();
					throw new CommonException(ex.getMessage());
				}
			}else{
				throw new CommonException("对账文件的类型不正确！");
			}
		} catch (Exception e) {
			throw new CommonException("平账充值《id："+checkList.getId()+"》撤销发生错："+e.getMessage());
		}
	}

	
	/**
	 * 平账充值撤销
	 * @param checkList
	 * @param actionLog
	 */
	private void saveRechageCancel(PayCoCheckList checkList,SysActionLog actionLog,PayCoCheckSingle sign){
		try {
			if(sign.getFileType().equals("01")||sign.getFileType().equals("04")){//充值（圈存）或圈付
			    PayCoDealRec coDealRec = (PayCoDealRec)this.findOnlyRowByHql("from PayCoDealRec t where t.dealNo='"+checkList.getOldActionNo()+"' and t.dealState='04'");
			    if(coDealRec == null ){
			    	throw new CommonException("未查询到要撤销的充值明细信息！");
			    }
				StringBuffer  inpara = new StringBuffer();
				inpara.append(actionLog.getDealNo() + "|");//1action_no 
				if(sign.getFileType().equals("01")){//2tr_code
					inpara.append("30105011" + "|");
				}else{
					inpara.append("30105091" + "|");
				}
				inpara.append(checkList.getAcptId() + "|");//3acpt_id 
				inpara.append(actionLog.getUserId() + "|");//4oper_id  
				inpara.append(DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")+"|");//5oper_time 
				inpara.append(checkList.getOldActionNo()+"|");//6old_action_no 
				inpara.append(checkList.getClrDate()+"|");//7old_clr_date
				inpara.append(checkList.getCardNo()+"|");//8card_no 
				AccAccountSub account_sub = (AccAccountSub)this.findOnlyRowByHql("from AccAccountSub t where t.cardNo ='"+
							checkList.getCardNo()+"' and t.accKind ='"+checkList.getAccKind()+"'");
				
				if(account_sub == null){
					throw new CommonException("未查询到对账记录的账户信息！");
				}
				String entry = "";
				if(!account_sub.getAccKind().equals("01")){
					entry = doWorkClientService.money2EncryptCal(checkList.getCardNo(), account_sub.getBal().toString(),
							checkList.getAmt().toString(), Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB);
				}
				inpara.append(entry+"|");//9encrypt   
				inpara.append(coDealRec.getSource()+"|");//10source
				inpara.append(""+"|");//11source_id
				inpara.append(""+"|");//12source_name
				inpara.append(""+"|");//13source_description
				inpara.append(this.getClrDate().replaceAll("-", "")+"|");//14end_batch_no 
				inpara.append(DateUtil.formatDate(this.getDateBaseTime(), "HHMMSS")+"|");//15end_deal_no 
				inpara.append(entry+"|");//16entry
				if(sign.getFileType().equals("01")){//17qcorqf
					inpara.append("0" + "|");
				}else{
					inpara.append("1" + "|");
				}
				inpara.append(checkList.getAcptId()+"|");//18dz_acpt_id
				inpara.append("1");//19dz_cl_flag 
				List<Object> in = new java.util.ArrayList<Object>();
				in.add(inpara.toString());
				List<Integer> out = new java.util.ArrayList<Integer>();
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				try {
					List ret = publicDao.callProc("pk_co_service.online_recharge_cancel", in, out);
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
			}else if(sign.getFileType().equals("02")){//消费
				throw new CommonException("暂时不支持该类型对账文件的处理！");
			}else if(sign.getFileType().equals("03")){//圈提
				//组装调用存储过程参数	
				PayCoDealRec coDealRec = (PayCoDealRec)this.findOnlyRowByHql("from PayCoDealRec t where t.dealNo='"+checkList.getOldActionNo()+"' and t.dealState='04'");
			    if(coDealRec == null ){
			    	throw new CommonException("未查询到要撤销的圈提明细信息！");
			    }
				StringBuffer  inpara = new StringBuffer();
				inpara.append(inpara.append(actionLog.getDealNo()) + "|");//1action_no 
				inpara.append("30105071"+"|");//2tr_code  
				inpara.append(coDealRec.getAcptId()+"|");//3acpt_id 
				inpara.append("cooouser"+"|");//4oper_id 
				inpara.append(DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")+"|");//5oper_time 
				inpara.append(checkList.getOldActionNo()+"|");//6old_action_no
				inpara.append(checkList.getClrDate()+"|");//7old_clr_date 
				inpara.append(checkList.getCardNo()+"|");//8card_no
				AccAccountSub account_sub = (AccAccountSub)this.findOnlyRowByHql("from AccAccountSub t where t.cardNo ='"+
							checkList.getCardNo()+"' and t.accKind ='"+checkList.getAccKind()+"'");
				
				if(account_sub == null){
					throw new CommonException("未查询到对账记录的账户信息！");
				}
				String entry = "";
				if(!account_sub.getAccKind().equals("01")){
					entry = doWorkClientService.money2EncryptCal(checkList.getCardNo(), account_sub.getBal().toString(),
							checkList.getAmt().toString(), Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB);
				}
				inpara.append(entry+"|");//9encrypt
				inpara.append(coDealRec.getSource()+"|");//10source
				inpara.append(""+"|");//11source_id 
				inpara.append(""+"|");//12source_name 
				inpara.append(""+"|");//13source_description
				inpara.append(checkList.getAcptId()+"|");//14dz_acpt_id 
				inpara.append(this.getClrDate().replaceAll("-", "")+"|");//15end_batch_no 
				inpara.append(DateUtil.formatDate(this.getDateBaseTime(), "HHMMSS")+"|");//16end_deal_no
				inpara.append("1");//17dz_cl_flag 
				List<Object> in = new java.util.ArrayList<Object>();
				in.add(inpara.toString());
				List<Integer> out = new java.util.ArrayList<Integer>();
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				try {
					List ret = publicDao.callProc("pk_co_service.online_qt_handle_undo", in, out);
					if (!(ret == null || ret.size() == 0)) {
						int res = Integer.parseInt(ret.get(0).toString());
						if (res != 0) {
							String outMsg = ret.get(1).toString();
							throw new CommonException(outMsg);
						} 
					} else {
						throw new CommonException("运营机构撤销记录 《id："+checkList.getOldActionNo()+"》"+"出错！");
					}
				} catch (Exception ex) {
					ex.printStackTrace();
					throw new CommonException(ex.getMessage());
				}
			}else{
				throw new CommonException("对账文件的类型不正确！");
			}
		} catch (Exception e) {
			throw new CommonException("平账充值《id："+checkList.getId()+"》撤销发生错："+e.getMessage());
		}
	}
	
	



	@SuppressWarnings("unchecked")
	@Override
	public void saveGetCheckFile(SysActionLog actionLog, Users user,String coOrgId, String checkDate,String fileType) throws CommonException {
		DefaultFTPClient ftpClient =null;
		String fileTypeTemp ="";
		try {
			if("CZ".equals(fileType)||"XF".equals(fileType)||"QF".equals(fileType)||"QT".equals(fileType)){
				String isBank = (String) findOnlyFieldBySql("select bank_id from base_bank where bank_id = '" + coOrgId + "'");
				String ftpuser = coOrgId;
				if (isBank != null) {
					ftpuser = "co_bank_" + coOrgId;
				}
				fileTypeTemp = getFileType(fileType);
				//-----------------------1获取系统配置的文件目录并判断该对账日期的对账数据是否存在，准许进行文件的获取----------------------
				initFtpPara(ftpuser);
				PayCoCheckSingle signle = (PayCoCheckSingle)this.findOnlyRowByHql("from PayCoCheckSingle where coOrgId = '"+coOrgId+"' and checkDate = '"+checkDate+"' and fileType ='"+fileTypeTemp+"'");
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
				ftpClient.connect(url, Integer.parseInt(port));
				ftpClient.login(userName, pwd);
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
				
				if(fileTypeTemp == ""){
					throw new CommonException("无法转换的对账类型！");
				}
				//-----------------------2调用存储过程对总账-----------------------------------
				if(list == null || list.size() == 0){
					throw new CommonException("<font style='color:red'>"+fileName+"对账文件不存在或无记录无需对账！</font>");
				}
				String[] checkTotInfo = list.get(0).toString().split("\\|");
				List inparam = new ArrayList();
				inparam.add(coOrgId);
				inparam.add(coOrgId);
				inparam.add("");
				inparam.add("");
				inparam.add(fileTypeTemp);
				inparam.add(fileName);
				inparam.add(checkDate);
				inparam.add(checkTotInfo[0]);
				inparam.add(checkTotInfo[1]);
				inparam.add(checkTotInfo[2]);
				inparam.add(checkTotInfo[3]);
				List<Integer> outparam = new java.util.ArrayList<Integer>();
				outparam.add(java.sql.Types.VARCHAR);
				outparam.add(java.sql.Types.VARCHAR);
				List res = publicDao.callProc("pk_co_org_handle.p_check_billnew",inparam,outparam);
				if(res == null || res.size() <= 0){
					throw new CommonException("<font style='color:red'>请重新进行操作,对总账发生错误！</font>");
				}
				if(Integer.parseInt(res.get(0) + "") != 0){
					throw new CommonException(res.get(1).toString());
				}
				//-----------------------3明细入账-------------------------------------------
				PayCoCheckSingle sign_now = (PayCoCheckSingle)this.findOnlyRowByHql("from PayCoCheckSingle where coOrgId = '"+coOrgId+"' and checkDate = '"+checkDate+"' and fileType ='"+fileTypeTemp+"'");
				if(sign_now == null){
					throw new CommonException("<font style='color:red'>获取对账文件发生错误，对总账没有成功！</font>");
				}else{
					
					for(int i=2;i<list.size();i++){
						if(!"".equals(Tools.processNull(list.get(i)))){
							String[] content = list.get(i).toString().split("\\|", 14);
							List inparam_content = new ArrayList();
							inparam_content.add(Tools.processNull(content[0].toString()));
							inparam_content.add(Tools.processNull(content[0].toString()));
							String endId = Tools.processNull(content[1].toString());
							try {
								inparam_content.add(Integer.parseInt(endId));
							} catch (Exception e) {
								inparam_content.add(endId);
							}
							inparam_content.add(Tools.processNull(content[2].toString()));
							inparam_content.add(Tools.processNull(content[3].toString()));
							inparam_content.add(Tools.processNull(content[6].toString()));
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
							inparam_content.add("");
							String dealCode = "";
							if("CZ".equals(fileType)){
								if(Tools.processNull(content[7].toString()).equals(Constants.ACC_KIND_QBZH)){
									dealCode=DealCode.CORECHAGE_CZ_QBZH.toString();
								}else{
									dealCode=DealCode.CORECHAGE_CZ_ZJZH.toString();
								}
							}else if("XF".equals(fileType)){
								if(Tools.processNull(content[7].toString()).equals(Constants.ACC_KIND_QBZH)){
									if(Tools.processNull(content[7].toString()).equals("0")){
										dealCode=DealCode.CO_OFFLINE_CONSUME.toString();
									}else{
										dealCode=DealCode.CO_OFFLINE_CONSUME_RETURN.toString();
									}
								}else{
									if(Tools.processNull(content[7].toString()).equals("0")){
										dealCode=DealCode.ONLINE_CONSUME.toString();
									}else{
										dealCode=DealCode.ONLINE_CONSUME_RETURN.toString();
									}
								}
							}else if("QT".equals(fileType)){
								dealCode = DealCode.COSERVICE_LJ2YH.toString();
							}else if("QF".equals(fileType)){
								dealCode = DealCode.CORECHAGE_QF_ZJZH.toString();
							}else{
								throw new CommonException("交易代码无法转换！");
							}
							inparam_content.add(""+i);
							inparam_content.add(dealCode);
							inparam_content.add(fileTypeTemp);
							List<Integer> outparam_content = new java.util.ArrayList<Integer>();
							outparam_content.add(java.sql.Types.VARCHAR);
							outparam_content.add(java.sql.Types.VARCHAR);
							List res_content = publicDao.callProc("pk_co_org_handle.p_check_bill_implistnew",inparam_content,outparam_content);
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
					inparam_list.add(Tools.processNull(fileTypeTemp));
					List<Integer> outparam_list = new java.util.ArrayList<Integer>();
					outparam_list.add(java.sql.Types.VARCHAR);
					outparam_list.add(java.sql.Types.VARCHAR);
					List res_list = publicDao.callProc("pk_co_org_handle.p_check_list_billnew", inparam_list, outparam_list);
					if (res_list == null || res_list.size() <= 0) {
						throw new CommonException("<font style='color:red'>请重新进行操作,明细对账发生错误！</font>");
					}
					if (Integer.parseInt(res_list.get(0) + "") != 0) {
						throw new CommonException("<font style='color:red'>请重新进行操作,明细对账发生错误：" + res_list.get(1).toString() + "</font>");
					}
				}
				ftpClient.logout();
			}else{
				throw new CommonException("暂不支持该类型的对账文件！");
			}
		} catch (Exception e) {
			throw new CommonException("获取合作机构对账发生错误，请重新获取！"+e.getMessage());
		}finally{
			try {
				ftpClient.logout();
			} catch (Exception e) {
				//e.printStackTrace();
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
	
	public String getFileType(String fileType){
		if(fileType.equals("CZ")){
			return "01";
		}else if(fileType.equals("XF")){
			return "02";
		}else if(fileType.equals("QT")){
			return "03";
		}else if(fileType.equals("QF")){
			return "04";
		}else{
			return "";
		}
	}
	
	
	
	private String getInsTypeName(String subId){
		String insTypeName = null;
		if("1".equals(subId)){
			insTypeName = "太平盛世团体终身重大疾病保险（C款）条款";
		}else if("2".equals(subId)){
			insTypeName = "太平盛世团体终身重大疾病保险，附加盛世住院津贴团体医疗保险";
		}else if("3".equals(subId)){
			insTypeName = "贴心卡.太平盛世团体意外伤害保险（201308）";
		}else if("4".equals(subId)){
			insTypeName = "关爱保险（重大疾病保险）";
		}else if("5".equals(subId)){
			insTypeName = "贴心保险";
		}else if("6".equals(subId)){
			insTypeName = "安康保险";
		}else if("7".equals(subId)){
			insTypeName = "康福卡";
		}else if("8".equals(subId)){
			insTypeName = "安心卡H";
		}else if("9".equals(subId)){
			insTypeName = "安康保险";
		}else if("10".equals(subId)){
			insTypeName = "退休职工住院医疗互助保险";
		}else if("11".equals(subId)){
			insTypeName = "安享套餐A";
		}else if("12".equals(subId)){
			insTypeName = "安享套餐B";
		}else if("13".equals(subId)){
			insTypeName = "安享套餐C";
		}else if("14".equals(subId)){
			insTypeName = "畅行天下A款保险计划";
		}else if("15".equals(subId)){
			insTypeName = "医惠宝重大疾病保险，医惠宝住院补充医疗保险";
		}
		return insTypeName;
	}
	
	private String getCertType(String certType){
		if("居民身份证(户口簿)".equals(certType)){
			certType = "1";
		}else if("户口簿".equals(certType)){
			certType = "2";
		}else if("军官证".equals(certType)){
			certType = "3";
		}else if("护照".equals(certType)){
			certType = "4";
		}else if("户籍证明".equals(certType)){
			certType = "5";
		}else if("其他".equals(certType)){
			certType = "6";
		}else if("港澳居民来往内地通行证".equals(certType)){
			certType = "7";
		}else if("台湾居民来往大陆通行证".equals(certType)){
			certType = "8";
		}else if("外国人永久居留证".equals(certType)){
			certType = "9";
		}
		return certType;
	}

	
	@Override
	public void saveAutoFtpCheckFile(String coOrgId, String fileType, int day) throws CommonException {
		try {
			SysActionLog actionLog = new SysActionLog();
			Users user = (Users) findOnlyRowByHql("from Users where userId = 'admin'");
			String checkDate = "";
			Calendar now = Calendar.getInstance();
			now.setTime(new Date());
			now.add(Calendar.DAY_OF_MONTH, day);
			checkDate = DateUtil.formatDate(now.getTime(), "yyyyMMdd");
			this.saveGetCheckFile(actionLog, user, coOrgId, checkDate, fileType);
		} catch (Exception e) {
			throw new CommonException("获取合作机构对账发生错误，请重新获取！" + e.getMessage());
		}
	}
}
