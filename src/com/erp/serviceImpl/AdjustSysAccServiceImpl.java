package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.AccAdjustInfo;
import com.erp.model.CardBaseinfo;
import com.erp.model.PayOfflineBlack;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.AdjustSysAccService;
import com.erp.service.BaseService;
import com.erp.service.DoWorkClientService;
import com.erp.util.Constants;
import com.erp.util.DealCode;
import com.erp.util.Tools;

@Service("adjustSysAccService")
public class AdjustSysAccServiceImpl extends BaseServiceImpl implements AdjustSysAccService {

	@Resource(name="doWorkClientService")
	private DoWorkClientService doWorkClientService;
	@Resource(name="baseService")
	private BaseService baseService;
	@SuppressWarnings("unchecked")
	@Override
	public TrServRec saveAddAdjustInfo(AccAdjustInfo adjustInfo,SysActionLog actionLog, Users user) throws CommonException {
		TrServRec rec = new TrServRec();
		try {
			publicDao.save(actionLog);
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(actionLog.getOrgId());
			rec.setBrchId(actionLog.getBrchId());
			rec.setUserId(actionLog.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setRsvOne(adjustInfo.getAmt().toString());
			rec.setCardNo(adjustInfo.getCardInNo());
			rec.setRsvTwo(adjustInfo.getOldDealNo().toString());
			publicDao.save(rec);
			publicDao.save(adjustInfo);
		} catch (Exception e) {
			throw new CommonException("保存调账信息出错："+e.getMessage());
		}
		return rec;
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveCheckAdjustInfo(String ids, SysActionLog actionLog,Users user) throws CommonException {
		TrServRec rec = new TrServRec();
		try {
			publicDao.save(actionLog);
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(actionLog.getOrgId());
			rec.setBrchId(actionLog.getBrchId());
			rec.setUserId(actionLog.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setRsvTwo(ids);
			publicDao.save(rec);
			publicDao.doSql("update acc_adjust_info t set t.deal_state = '02' where t.id in("+ids+")");
		} catch (Exception e) {
			throw new CommonException("审核调账信息出错："+e.getMessage());
		}
		
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveDelAdjustInfo(String ids, SysActionLog actionLog, Users user)
			throws CommonException {
		TrServRec rec = new TrServRec();
		try {
			publicDao.save(actionLog);
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(actionLog.getOrgId());
			rec.setBrchId(actionLog.getBrchId());
			rec.setUserId(actionLog.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setRsvTwo(ids);
			publicDao.save(rec);
			publicDao.doSql("update acc_adjust_info t set t.deal_state = '03' where t.id in("+ids+")");
		} catch (Exception e) {
			throw new CommonException("删除调账信息出错："+e.getMessage());
		}
	}

	@Override
	public TrServRec saveDealAdjustInfo(AccAdjustInfo adjustInfo,SysActionLog actionLog, Users user) throws CommonException {
		TrServRec rec = new TrServRec();
		try {
			publicDao.save(actionLog);
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(actionLog.getOrgId());
			rec.setBrchId(actionLog.getBrchId());
			rec.setUserId(actionLog.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setRsvOne(adjustInfo.getAmt().toString());
			rec.setCardNo(adjustInfo.getCardInNo());
			rec.setRsvTwo(adjustInfo.getOldDealNo().toString());
			publicDao.save(rec);
			//根据调账类型如果是确认交易不去查找原交易，如果是撤销交易需要查找原交易是否存在再做处理
			if(adjustInfo.getAdjustType().equals("01")){
				
			}else{
				BigDecimal bg = (BigDecimal)this.findOnlyFieldBySql("select count(1) from "
						+ " pay_card_deal_rec_"+adjustInfo.getClrDate().substring(0, 4) +adjustInfo.getClrDate().substring(5, 7)+" where deal_no = '"+adjustInfo.getOldDealNo()+"'"
						+ " and clr_Date = '"+adjustInfo.getClrDate()+"'");
				if(bg == null || bg.intValue() == 0){
					throw new CommonException("未找到原记录,不能进行调账撤销操作");
				}
				//找到原记录进行撤销操作
                Object[] obj = (Object[])this.findOnlyRowBySql("select t.acc_inout_no,t.clr_date,t.cr_acc_no,T.CR_CARD_NO,T.CR_AMT, t.db_acc_no,T.DB_CARD_NO,T.DB_AMT"
                		             + " from acc_inout_detail_"+adjustInfo.getClrDate().substring(0, 4) +adjustInfo.getClrDate().substring(5, 7)
                					 + " where deal_no='"+adjustInfo.getOldDealNo()+"'");
                if(obj == null ){
                	throw new CommonException("未找到原记录,不能进行调账撤销操作");
                }
				List<Object> in = new java.util.ArrayList<Object>();
				in.add(adjustInfo.getOldDealNo());//要撤销业务流水号
				in.add(actionLog.getDealNo());//新业务流水号
				in.add(publicDao.getDateBaseDate());//撤销记录的清分日期
				in.add(publicDao.getDateBaseDate());//当前清分日期
				in.add(actionLog.getDealCode());//交易代码
				in.add(actionLog.getUserId());//当前柜员
				BigDecimal dbbal = (BigDecimal)this.findOnlyFieldBySql("select t.bal from acc_account_sub t where t.acc_no = '"+obj[5]+"'");
				in.add(dbbal);//借方卡面交易前金额
				BigDecimal crbal = (BigDecimal)this.findOnlyFieldBySql("select t.bal from acc_account_sub t where t.acc_no = '"+obj[2]+"'");
				in.add(crbal);//贷方卡面交易前金额
				in.add("");
				in.add("");
				if(!"".equals(obj[3])){//卡号不为空则进行交易余额的计算
					doWorkClientService.money2EncryptCal(obj[3].toString(), dbbal.intValue()+"",adjustInfo.getAmt()+"",Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD);
				}else{
					in.add("");//借方金额密文
				}
				if(!"".equals(obj[6])){//卡号不为空则进行交易余额的计算
					doWorkClientService.money2EncryptCal(obj[6].toString(), dbbal.intValue()+"",adjustInfo.getAmt()+"",Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB);
				}else{
					in.add("");//贷方金额密文
				}
				in.add("1");
				in.add("1");
				List<Integer> out = new java.util.ArrayList<Integer>();
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				try {
					List ret = publicDao.callProc("PK_BUSINESS.p_daybookcancel", in,out);
					if (!(ret == null || ret.size() == 0)) {
						int res = Integer.parseInt(ret.get(0).toString());
						if (res != 0) {
							String outMsg = ret.get(1).toString();
							throw new CommonException(outMsg);
						} else {
							return null;
						}
					} else {
						throw new CommonException("建账户出错！");
					}
				} catch (Exception ex) {
					ex.printStackTrace();
					throw new CommonException(ex.getMessage());
				}
			}
		} catch (Exception e) {
			throw new CommonException("处理调账信息出错："+e.getMessage());
		}
		return rec;
	}

	@Override
	public TrServRec saveProcessWallet(PayOfflineBlack polb,SysActionLog actionLog,TrServRec rec)
			throws CommonException {
		try {
			//记录操作日志
			actionLog.setDealCode(DealCode.OFFLINE_DATA_CONFIRM);
			publicDao.save(actionLog);
			
			List<Object> in = new ArrayList<Object>();
			in.add(polb.getDealNo());
			in.add("1");
			List<Integer> out = new ArrayList<Integer>();
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
					throw new CommonException("脱机数据入账流水号《dealNo："+polb.getDealNo()+"》"+"出错！");
				}
			} catch (Exception e) {
				e.printStackTrace();
				throw new CommonException(e.getMessage());
			}
			CardBaseinfo cbi = (CardBaseinfo) baseService.findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" +polb.getCardNo()+ "'");
			//记录业务日志
			rec.setDealNo(actionLog.getDealNo());
			rec.setBizTime(actionLog.getDealTime());
			rec.setBrchId(actionLog.getBrchId());
			rec.setCardNo(polb.getCardNo());
			rec.setAmt(polb.getDealAmt());
			rec.setDealCode(actionLog.getDealCode());
			rec.setCustomerId(cbi.getCustomerId());
			rec.setCardId(cbi.getCardId());
			rec.setCardType(cbi.getCardType());
			rec.setNote("电子钱包数据处理，原交易流水号：" + polb.getDealNo());
			
			rec.setUserId(actionLog.getUserId());
			
			publicDao.save(rec);
			return rec;
		} catch (Exception e) {
			throw new CommonException("电子钱包数据处理出错："+e.getMessage());
		}
	}
	
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public TrServRec saveDealCancel(SysActionLog actionLog,String oldDealNo,String amt,String cardNo,String accKind,String oldClrDate,String userId) throws CommonException{
		TrServRec rec = new TrServRec();
		try {
			publicDao.save(actionLog);
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(actionLog.getOrgId());
			rec.setBrchId(actionLog.getBrchId());
			rec.setUserId(actionLog.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setDealCode(actionLog.getDealCode());
			rec.setRsvTwo(oldDealNo.toString());
			String encrypt_Money  = "";
			AccAccountSub sub = null;
			
			if(!Tools.processNull(cardNo).equals("")&&!Tools.processNull(accKind).equals(Constants.ACC_KIND_QBZH)){
				sub = (AccAccountSub)this.findOnlyRowByHql("from AccAccountSub c where c.cardNo='"+cardNo+"' and accKind='"+accKind+"'");
				if(sub == null){
					throw new CommonException("根据撤销流水未查询到账户信息");
				}
				encrypt_Money = doWorkClientService.money2EncryptCal(cardNo, sub.getBal()+"", amt, Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB);
				if(Tools.processNull(encrypt_Money).equals("")||Tools.processNull(encrypt_Money).equals(Tools.processNull(sub.getBal()))){
					throw new CommonException("计算金额密文发生错误");
				}
				//publicDao.doSql("update acc_account_sub t set t.BAL_CRYPT ='"+encrypt_Money+"' where card_no='"+cardNo+"' and acc_kind='"+accKind+"'");
			}
			try{
			      List in = new ArrayList();
			      StringBuffer inpara = new StringBuffer();
			      in.add(Tools.processNull(Tools.processNull(oldDealNo)));
			      in.add(Tools.processNull(actionLog.getDealNo()));
			      in.add(Tools.processNull(oldClrDate));
			      in.add(Tools.processNull(getClrDate()));
			      in.add(Tools.processNull(actionLog.getDealCode()));
			      in.add(userId);
			      in.add("");
			      in.add("");
			      in.add("");
			      in.add("");
			      in.add("");
			      in.add(encrypt_Money);
			      in.add("1");
			      in.add("1");
			      List out = new ArrayList();
			      out.add(Integer.valueOf(12));
			      out.add(Integer.valueOf(12));
			      try {
			        List ret = this.publicDao.callProc("pk_business.p_daybookcancel", in, out);
			        if ((ret != null) && (ret.size() != 0)) {
			          int res = Integer.parseInt(ret.get(0).toString());
			          if (res != 0) {
			            String outMsg = ret.get(1).toString();
			            throw new CommonException(outMsg);
			          }
			        } else {
			          throw new CommonException("调用撤销流水存储过程发生错误");
			        }
			      } catch (Exception ex) {
			        ex.printStackTrace();
			        throw new CommonException(ex.getMessage());
			      }
		    } catch (Exception e) {
		      throw new CommonException(e.getMessage());
		    }
			publicDao.save(rec);
			
		} catch (Exception e) {
			throw new CommonException("撤销账户流水发生错误"+e.getMessage());
		}
		return rec;
	}

}
