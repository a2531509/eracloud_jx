package com.erp.serviceImpl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardConfig;
import com.erp.model.CardSaleList;
import com.erp.model.CardSaleRec;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.AccAcountService;
import com.erp.service.RechargeCardService;
import com.erp.service.RechargeService;
import com.erp.service.StockService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.Sys_Code;
import com.erp.util.Tools;
@SuppressWarnings("unchecked")
@Service("rechargeCardService")
public class RechargeCardServiceImpl extends BaseServiceImpl implements RechargeCardService {
	@Resource(name="stockService")
	private StockService stockService;
	@Resource(name="accAcountService")
	private AccAcountService accAcountService;
	@Resource(name="rechargeService")
	private RechargeService rechargeService;
	/**
	 * 保存销售
	 * @param cardSaleRec
	 * @param cardSaleList
	 * @param rec
	 * @param actionLog
	 * @throws CommonExceptiony
	 */
	@Override
	public void saveCardSell(CardSaleRec cardSaleRec,List<CardSaleList> saleList, TrServRec rec, SysActionLog actionLog)throws CommonException {
		CardConfig para=null;
		String cardType="";
		try{
			Users users=this.getSessionUser();
			SysBranch branch = (SysBranch) this.findOnlyRowByHql("from SysBranch t where t.brchId = '" + users.getBrchId() + "'");
			//1 业务日志
			actionLog.setDealCode(DealCode.RECHANGE_CARD_SELL);
			cardSaleRec.setSaleDate(actionLog.getDealTime());
			publicDao.save(actionLog);
			
			//2 销售登记表
			cardSaleRec.setDealNo(actionLog.getDealNo());//业务流水号
			cardSaleRec.setClrDate(this.getClrDate());//清分日期
			cardSaleRec.setForegiftAmt(new Long(0));//默认为0
			publicDao.save(cardSaleRec);
	
			for(CardSaleList cardSaleList:saleList){
				cardType=cardSaleList.getCardType();
				//3 销售登记明细表
				List<CardBaseinfo> list1 = (List<CardBaseinfo>)publicDao.find("from CardBaseinfo a where a.cardState='"+Constants.CARD_STATE_ZC+"' and a.cardType='"+cardSaleRec.getCardTypeCatalog()+"' and a.cardNo between '"+cardSaleRec.getStartCardNo()+"' and '"+cardSaleRec.getEndCardNo()+"'");
				if(list1.size()>0){
					throw new CommonException("非记名卡批量登记："+cardSaleRec.getStartCardNo()+"-"+cardSaleRec.getEndCardNo()+"已启用或已激活，不能再次销售");
				}
				List<Object[]> list=(List<Object[]>)publicDao.find("from CardSaleList l,CardSaleRec b where l.dealNo=b.dealNo and (b.startCardNo='"+cardSaleRec.getStartCardNo()+"' or b.endCardNo='"+cardSaleRec.getEndCardNo()+"') and b.saleState='"+Constants.STATE_ZC+"'");
				if(list.size()>0){
					throw new CommonException("非记名卡批量登记已存在："+cardSaleRec.getStartCardNo()+"-"+cardSaleRec.getEndCardNo());
				}
				cardSaleList.setDealNo(actionLog.getDealNo());//申购单号
				//cardSaleList.setSaleListId(this.getSequenceByName("SEQ_CARD_SALE_LIST"));//序号
				publicDao.save(cardSaleList);
				para=(CardConfig)this.findOnlyRowByHql("from CardConfig c  where c.cardType='"+cardSaleList.getCardType()+"'");
				CardBaseinfo card=(CardBaseinfo)this.findOnlyRowByHql("from CardBaseinfo c where c.cardNo='"+cardSaleList+"'");
				if(card!=null){
					// 4、 建立卡分户帐  不是礼品卡的建账户时金额为零
					HashMap<String, Object> hm = new HashMap<String, Object>();
					hm.put("obj_type", Sys_Code.CLIENT_HAVE_ONLY);
					hm.put("sub_type", card.getCardType());
					hm.put("obj_id", card.getCardNo());
					accAcountService.createAccount(actionLog, hm);
					//5、按卡面值来充值
					Map<String,Object> map = new HashMap<String, Object>();
					map.put("userId",users.getUserId());
					map.put("cardNo",card.getCardNo());
					map.put("amt",para.getFaceVal());
					map.put("paySource","0");//充值资金来源0现金1转账/银行卡2充值卡3促销4更改信用额度5网点预存款
					map.put("actionlog",actionLog);
					rechargeService.saveOnlineAccRecharge(map, DealCode.RECHARGE_CASH_ACC);
					//更新卡状态
					publicDao.doSql("update card_base c set c.card_state='1' where c.card_state='0' and card_no='"+card.getCardNo()+"'");
				}
			
			}
			
			//5、销售登记业务日志信息
			rec.setNote(actionLog.getMessage());
			rec.setDealCode(actionLog.getDealCode());
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealState(Constants.STATE_ZC);
			rec.setBizTime(actionLog.getDealTime());
			publicDao.save(rec);
			Long totAmt = new Long(cardSaleRec.getTotAmt());
			
		    String stk_Code="1"+cardType;//库存账户格式
			//6。更新柜员库存流水
			//stockService.saveOpenBatch(stk_Code, cardSaleRec.getStartCardNo(), cardSaleRec.getEndCardNo(), 1, users.getUserId(), actionLog);
			//7.保存业务凭证	
			JSONObject json=new JSONObject();
			json.put("p_Actionno",actionLog.getDealNo());
			json.put("p_Print_Time1",DateUtil.formatDate(actionLog.getDealTime(),"yyyy-MM-dd"));
			json.put("p_Rechg_Time",DateUtil.formatDate(actionLog.getDealTime(),"yyyy-MM-dd HH:mm:ss"));
			json.put("p_Yw_Type", this.findTrCodeNameByCodeType(DealCode.RECHARGE_CASH_ACC));//业务名称
			json.put("p_Client_Name", rec.getCustomerName());
			json.put("p_Cert_No", Tools.processNull(rec.getAgtCertNo()));//证件号
			json.put("cardType",this.getCodeNameBySYS_CODE("CARD_TYPE", rec.getCardType()));
			json.put("p_Subcardno", cardSaleRec.getStartCardNo());
			json.put("p_Cardno", cardSaleRec.getStartCardNo());
			json.put("p_Prv_Bal",Arith.cardreportsmoneydiv("0"));
			json.put("p_Rechg_Amt",Arith.cardreportsmoneydiv(Tools.processNull(rec.getAmt())));
			json.put("accBalAfter",Arith.cardreportsmoneydiv(totAmt+""));
			json.put("rechargeCardNo",Tools.processNull(cardSaleRec.getStartCardNo()));//充值卡号
			json.put("p_Acpt_Branch", branch.getFullName());
			json.put("p_Oper_Id",users.getUserId());
			
			
			this.saveSysReport(actionLog,json,"/reportfiles/cashrecharge.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
		}catch(CommonException e){
			throw new CommonException("充值卡销售登记发生错误："+e.getMessage());
		}
	}
	/**
	 * 非记名卡销售登记撤销
	 * @param dealNo 销售登记表
	 * @param actionlog 业务日志对象
	 * @throws CommonException
	 */
	@SuppressWarnings("rawtypes")
	@Override
	public List deleteCardSell(Long dealNo, SysActionLog actionLog) throws CommonException {
		String cardList="";
		List list=new ArrayList();
		try {
			//1 业务日志
			actionLog.setDealCode(DealCode.RECHANGE_CARD_UNDO);//默认以礼品卡的交易代码，
			actionLog.setRollFlag(Constants.YES_NO_NO);
			actionLog.setMessage("非记名销售登记撤销");
			publicDao.save(actionLog);
			
			//2 销售登记表
			CardSaleRec cardSaleRec=(CardSaleRec)this.findOnlyRowByHql("from CardSaleRec c where c.dealNo="+dealNo);
			if(cardSaleRec.getSaleState().equals(Constants.YES_NO_NO)){
				throw new CommonException("该非记名销售登记已经撤销！");
			}
			String saleDate = DateUtil.processDate(cardSaleRec.getSaleDate());//销售日期
			String nowDate = DateUtil.getNowDate();//当前日期
			if(!nowDate.equals(saleDate)){
				throw new CommonException("该非记名销售登记只可当天撤销！");
			}
			
			cardSaleRec.setSaleState(Constants.BOOK_STATE_CX);
			cardSaleRec.setDealCode(DealCode.RECHANGE_CARD_UNDO);
			publicDao.update(cardSaleRec);
			
			
			
			//3 销售登记明细表
			List<CardSaleList> salelist=(List<CardSaleList>)publicDao.find("from CardSaleList c where c.dealNo="+cardSaleRec.getDealNo());
			for(CardSaleList sale:salelist){
				CardConfig para=super.getCardparaByCardType(sale.getCardType());
				if(cardSaleRec.getCardTypeCatalog().equals(Constants.CARD_TYPE_FJMK)){
					cardList+=" "+this.getCodeNameBySYS_CODE("CARD_TYPE", cardSaleRec.getCardTypeCatalog())+"卡类型: "+cardSaleRec.getStartCardNo()+"  ---  "+cardSaleRec.getEndCardNo()+" ,  小计数量："+cardSaleRec.getTotNum()+",  小计面额："+cardSaleRec.getTotAmt()/100+"  元;";
				}else{
					cardList+=" "+para.getFaceVal()/100+"元卡类型: "+cardSaleRec.getStartCardNo()+"  ---  "+cardSaleRec.getEndCardNo()+" ,  小计数量："+cardSaleRec.getTotNum()+",  小计面额："+cardSaleRec.getTotAmt()/100+"  元;";
				}
			}
			publicDao.doSql(" update Card_Sale_List t  set t.list_State='"+Constants.BOOK_STATE_CX+"' where  t.deal_No="+cardSaleRec.getDealNo());
			
			list.add(cardList);
			return list;
		} catch (Exception e) {
			throw new CommonException("销售登记失败",e);
		}
	}
	/**
	 * 非记名卡批量启用
	 * @param cardType
	 * @param startNum
	 * @param endNum
	 * @param users
	 * @return
	 * @throws CommonException
	 */
	@Override
	public void saveCardSellUsed(String dealNoStr,SysActionLog actionLog) throws CommonException {
		try{
			//Users users=this.getSessionUser();
			//1 action日志
			actionLog.setDealCode(DealCode.RECHANGE_CARD_BATHCHUSED);
			actionLog.setMessage("充值卡批量启用");
			publicDao.save(actionLog);
			
			String[] dealNos=dealNoStr.split(",");
			Long DealNo=0L;
			CardSaleRec cardSaleRec=null;
			for(int i=0;i<dealNos.length;i++){
				DealNo=Long.valueOf(dealNos[i].toString());
				cardSaleRec=(CardSaleRec)this.findOnlyRowByHql("from CardSaleRec c where c.dealNo="+DealNo);
				List<CardSaleList> list=(List<CardSaleList>)this.findByHql("from CardSaleList c where c.dealNo="+DealNo);
				if(list.size()!=Tools.processInt(cardSaleRec.getTotNum()+"")){
					throw new CommonException("销售明细总数不对");
				}
				publicDao.doSql("update Card_Baseinfo c set c.card_State='"+Constants.CARD_STATE_ZC+"',c.last_Modi_Date=to_date('"
					+ DateUtil.formatDate(actionLog.getDealTime()) + "', 'yyyy-MM-dd hh24:mi:ss') " +
					"where card_State='"+Constants.CARD_STATE_WQY+"' and card_Type='"+((CardSaleList)list.get(0)).getCardType()+"' and card_No between '"+cardSaleRec.getStartCardNo()+"' and '"+cardSaleRec.getEndCardNo()+"'");
		
				//5 库存变动(记录柜员库存卡的出入流水（stock_rec）更新柜员库存分户账（stock_acc）,更新库存明细)
				stockService.saveOpenBatch(this.getStkCodeByCardType(((CardSaleList)list.get(0)).getCardType()), cardSaleRec.getStartCardNo(), cardSaleRec.getEndCardNo(),Tools.processInt(cardSaleRec.getTotNum()+""), "", actionLog);
			}
		
		}catch(Exception e){
			throw new CommonException("充值卡批量启用发生错误",e);
		}
	}

}
