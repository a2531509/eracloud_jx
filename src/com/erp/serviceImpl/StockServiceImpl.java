package com.erp.serviceImpl;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSON;
import com.erp.exception.CommonException;
import com.erp.model.CardApplyTask;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardTaskBatch;
import com.erp.model.CardTaskImp;
import com.erp.model.StockAcc;
import com.erp.model.StockList;
import com.erp.model.StockRec;
import com.erp.model.StockType;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.StockService;
import com.erp.util.CardNumberTools;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.MakeCardTask;
import com.erp.util.SqlTools;
import com.erp.util.Tools;
@Service("stockService")
public class StockServiceImpl extends BaseServiceImpl implements StockService {
	/**
	 * 库存类型新增或是编辑保存
	 * @param stockType
	 * @param user
	 * @param actionLog
	 * @param type
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveOrUpdateStockType(StockType stockType,Users user,SysActionLog actionLog,String type) throws CommonException{
		try{
			//1.基本条件判断
			String string = "";
			Integer tempDealCode = 0;
			if(Tools.processNull(type).equals("0")){
				tempDealCode = DealCode.STOCK_TYPE_ADD;
				string = "新增库存类型";
			}else if(Tools.processNull(type).equals("1")){
				tempDealCode = DealCode.STOCK_TYPE_EDIT;
				string = "编辑库存类型";
			}else if(Tools.processNull(type).equals("2")){
				tempDealCode = DealCode.STOCK_TYPE_DEL;
				string = "删除库存类型";	
			}else if(Tools.processNull(type).equals("3")){
				tempDealCode = DealCode.STOCK_TYPE_DISABLE;
				string = "注销库存类型";
			}else if(Tools.processNull(type).equals("4")){
				tempDealCode = DealCode.STOCK_TYPE_ENABLE;
				string = "启用库存类型";
			}else{
				throw new CommonException("库存类型的操作类型不正确！");
			}
			//2.业务处理
			actionLog.setDealCode(tempDealCode);
			StockType oldStockType = (StockType) this.findOnlyRowByHql("from StockType t where t.stkCode = '" + stockType.getStkCode() + "'");
			if(Tools.processNull(type).equals("0")){
				if(oldStockType != null){
					throw new CommonException("相同库存类型代码已存在，请不要重复进行添加！");
				}
				stockType.setOpenDate(actionLog.getDealTime());
				stockType.setOpenUserId(user.getUserId());
				stockType.setStkCodeState("0");
				publicDao.save(stockType);
				actionLog.setMessage(string + stockType.getStkCode() + "," + stockType.getStkName());
				actionLog.setNote(JSON.toJSONString(stockType));
			}else if(Tools.processNull(type).equals("1")){
				if(oldStockType == null){
					throw new CommonException("根据库存类型代码" + stockType.getStkCode() + "，找不到对应的库存类型信息，无法进行编辑！");
				}
				oldStockType.setOrgId(stockType.getOrgId());
				oldStockType.setLstFlag(stockType.getLstFlag());
				oldStockType.setOutFlag(stockType.getOutFlag());
				oldStockType.setNote(stockType.getNote());
				publicDao.update(oldStockType);
				actionLog.setMessage(string + oldStockType.getStkCode() + "," + oldStockType.getStkName());
				actionLog.setNote(JSON.toJSONString(oldStockType));
			}else if(Tools.processNull(type).equals("2")){
				if(oldStockType == null){
					throw new CommonException("根据库存类型代码" + stockType.getStkCode() + "，找不到对应的库存类型信息，无法进行删除！");
				}
				actionLog.setMessage(string + oldStockType.getStkCode() + "," + oldStockType.getStkName());
				actionLog.setNote(JSON.toJSONString(oldStockType));
				publicDao.delete(oldStockType);
			}else if(Tools.processNull(type).equals("3")){
				if(oldStockType == null){
					throw new CommonException("根据库存类型代码" + stockType.getStkCode() + "，找不到对应的库存类型信息，无法进行禁用！");
				}
				actionLog.setMessage(string + oldStockType.getStkCode() + "," + oldStockType.getStkName());
				actionLog.setNote(JSON.toJSONString(oldStockType));
				oldStockType.setStkCodeState(Constants.YES_NO_NO);
				oldStockType.setClsUserId(user.getUserId());
				oldStockType.setClsDate(actionLog.getDealTime());
				publicDao.update(oldStockType);
			}else if(Tools.processNull(type).equals("4")){
				if(oldStockType == null){
					throw new CommonException("根据库存类型代码" + stockType.getStkCode() + "，找不到对应的库存类型信息，无法进行启用！");
				}
				actionLog.setMessage(string + oldStockType.getStkCode() + "," + oldStockType.getStkName());
				actionLog.setNote(JSON.toJSONString(oldStockType));
				oldStockType.setStkCodeState(Constants.YES_NO_YES);
				oldStockType.setClsUserId(null);
				oldStockType.setClsDate(null);
				publicDao.update(oldStockType);
			}
			//3.日志信息
			publicDao.save(actionLog);
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealCode(actionLog.getDealCode());
			rec.setOrgId(actionLog.getOrgId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(user.getBrchId());
			rec.setUserId(user.getUserId());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setNote(actionLog.getMessage());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 保存库存账户开户
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public TrServRec saveStockAccOpen(StockAcc acc,Users oper,SysActionLog log) throws CommonException{
		try{
			//1.基本条件判断
			if(acc == null){
				throw new CommonException("库存账户开户参数不能为空！");
			}
			if(Tools.processNull(acc.getId()).equals("")){
				//throw new CommonException("柜员信息或开户信息不能为空！");
			}
			if(Tools.processNull(acc.getId().getUserId()).equals("")){
				//throw new CommonException("开户柜员信息不能为空！");
			}
			if(Tools.processNull(acc.getId().getStkCode()).equals("")){
				//throw new CommonException("开户库存类型不能为空！");
			}
			if(Tools.processNull(acc.getBrchId()).equals("")){
				throw new CommonException("开户库存网点不能为空！");
			}
			if(oper == null || Tools.processNull(oper.getUserId()).equals("")){
				throw new CommonException("开户操作员不能为空！");
			}
			log.setDealCode(DealCode.STOCK_ACC_OPEN);
			log.setMessage("库存账户开户");
			publicDao.save(log);
			//2.业务处理
			StringBuffer sb = new StringBuffer();
			sb.append(oper.getBrchId() + "|");
			sb.append(Constants.ACPT_TYPE_GM + "|");
			sb.append(oper.getUserId() + "|");
			sb.append("" + "|");
			sb.append(acc.getBrchId() + "|");
			sb.append(acc.getId().getUserId() + "|");
			sb.append(acc.getId().getStkCode() + "|");
			sb.append("" + "|");
			sb.append(acc.getNote() + "|");
			List<String> inParameters = new ArrayList<String>();
			inParameters.add(sb.toString());
			List outParameters = new ArrayList();
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List  outParams = publicDao.callProc("pk_card_Stock.p_stockacc_open",inParameters,outParameters);
			if(outParams == null || outParams.size() <= 0){
				throw new CommonException("调取过程出现错误！");
			}
			if(Integer.valueOf(outParams.get(0).toString()) != 0){
				throw new CommonException(outParams.get(1).toString() + "！");
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setOrgId(oper.getOrgId());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(log.getUserId());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setNote(log.getMessage());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 库存配送保存
	 * @param stockRec 库存配送日志信息
	 * @param stockDeliveryWay 库存配送方式
	 * @param oper 操作员
	 * @param log 操作日志
	 * @return
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public TrServRec saveStockDelivery(StockRec stockRec,String stockDeliveryWay,Users oper,SysActionLog log) throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(stockDeliveryWay).equals("")){
				throw new CommonException("库存配送方式不能为空！");
			}else if(Tools.processNull(stockDeliveryWay).equals("1")){
				if(Tools.processNull(stockRec.getTaskId()).equals("")){
					throw new CommonException("库存配送方式已选择【按任务方式配送】请选择任务编号！");
				}
			}else if(Tools.processNull(stockDeliveryWay).equals("2")){
				if(Tools.processNull(stockRec.getStartNo()).trim().equals("") || Tools.processNull(stockRec.getEndNo()).trim().equals("") ||
						Tools.processNull(stockRec.getGoodsNums()).trim().equals("")){
					throw new CommonException("配送方式已选择【按号段配送】请输入起止号码和数量！");
				}
			}else{
				throw new CommonException("库存配送方式选择不正确！");
			}
			//2.记录操作日志
			log.setDealCode(DealCode.STOCK_DELIVERY);
			log.setMessage("库存配送,配送方式:" + (Tools.processNull(stockDeliveryWay).equals("1") ? "按照任务配送" : "按照号段配送") + "," +
			(Tools.processNull(stockDeliveryWay).equals("1") ? stockRec.getTaskId() : "起始卡号:" + stockRec.getStartNo() + ",截止卡号" + stockRec.getEndNo()) );
			if (log.getMessage().length() > 1000) {
				log.setMessage(log.getMessage().substring(0, 1000) + "....");
			}
			publicDao.save(log);
			//3.业务处理
			StringBuffer sb = new StringBuffer();
			sb.append(Tools.processNull(oper.getBrchId()) + "|");//1.受理点编号
			sb.append(Constants.ACPT_TYPE_GM + "|");//2.受理点类型
			sb.append(Tools.processNull(oper.getUserId()) + "|");//3.受理柜员编号
			sb.append(log.getDealNo() + "|");//4.流水号
			sb.append(log.getDealCode() + "|");//5.交易代码
			sb.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "|");//6.业务受理时间
			sb.append(Tools.processNull(stockRec.getStkCode()) + "|");//7.库存类型
			sb.append(Tools.processNull(oper.getBrchId()) + "|");//8.出库网点 为 操作网点
			sb.append(Tools.processNull(oper.getUserId()) + "|");//9.出库柜员 为操作柜员
			sb.append("0" + "|");//10.出库物品状态
			sb.append(Tools.processNull(stockRec.getInBrchId()) + "|");//11.收方网点编号
			sb.append(Tools.processNull(stockRec.getInUserId()) + "|");//12.收方柜员编号
			sb.append("0" + "|");//13.入库物品状态
			sb.append(stockDeliveryWay + "|");//14.配送方式
			sb.append(Tools.processNull(stockRec.getTaskId()) + "|");//15.任务编号
			sb.append(Tools.processNull(stockRec.getStartNo()) + "|");//16.起始编号
			sb.append(Tools.processNull(stockRec.getEndNo()) + "|");//17.结果编号
			sb.append(Tools.processNull(stockRec.getGoodsNums()) + "|");//18.数量
			sb.append(Tools.processNull(log.getMessage().length()>100 ? log.getMessage().substring(0, 100) + "..." : log.getMessage()) + "|");//19.备注
			List inParameters = new ArrayList();
			List outParameters = new ArrayList();
			inParameters.add(sb.toString());
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List outList = publicDao.callProc("pk_card_Stock.p_stock_delivery",inParameters,outParameters);
			if(outList == null || outList.size() <= 0){
				throw new CommonException("库存配送调取过程出现错误！");
			}
			if(Integer.valueOf(outList.get(0).toString()) != 0){
				throw new CommonException(outList.get(1).toString());
			}
			//4.业务日志
			TrServRec rec = new TrServRec();
			rec.setDealCode(log.getDealCode());
			rec.setDealNo(log.getDealNo());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchIdIn(stockRec.getInBrchId());
			rec.setUserIdIn(stockRec.getInUserId());
			rec.setBrchIdOut(stockRec.getOutBrchId());
			rec.setUserIdOut(stockRec.getOutUserId());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setNote(log.getMessage());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 库存配送确认保存
	 * @param stockDealNo
	 * @param oper
	 * @param log
	 * @return
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public void saveStockDeliveryConfirm(String stockDealNo,Users oper,SysActionLog log) throws CommonException{
		try{
			StringBuffer sb = new StringBuffer();
			sb.append(oper.getBrchId() + "|");
			sb.append("1" + "|");
			sb.append(oper.getUserId() + "|");
			sb.append(log.getDealNo() + "|");
			sb.append(stockDealNo + "|");
			List inParameters = new ArrayList();
			List outParameters = new ArrayList();
			inParameters.add(sb.toString());
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.INTEGER);
			List outList = publicDao.callProc("pk_card_Stock.p_stock_delivery_confirm",inParameters,outParameters);
			if(outList == null || outList.size() <= 0){
				throw new CommonException("库存配送确认调取过程出现错误！");
			}
			if(Integer.valueOf(outList.get(0).toString()) != 0){
				Integer okNums = Integer.valueOf(outList.get(2).toString());
				throw new CommonException("已确认成功" + okNums + "条记录，其中在确认第" + (okNums + 1) + "条记录时出现错误：" + outList.get(1).toString());
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 库存配送取消
	 * @param stkDealNos  库存配送流水号
	 * @param oper 操作员
	 * @param log  操作日志
	 * @return     业务日志
	 * @throws CommonException
	 */
	public TrServRec saveStockDeliveryCancel(String stkDealNos,Users oper,SysActionLog log) throws CommonException{
		try{
			//1.插入日志
			log.setDealCode(DealCode.STOCK_DELIVERY_CANCEL);
			log.setMessage("库存配送取消,库存流水:" + stkDealNos);
			publicDao.save(log);
			//2.调取过程
			StringBuffer sb = new StringBuffer();
			sb.append(oper.getBrchId() + "|");
			sb.append(Constants.ACPT_TYPE_GM + "|");
			sb.append(oper.getUserId() + "|");
			sb.append(log.getDealNo() + "|");
			sb.append(stkDealNos + "|");
			sb.append(log.getDealCode() + "|");
			sb.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "|");
			sb.append(log.getMessage() + "|");
			List inParameters = new ArrayList();
			List outParameters = new ArrayList();
			inParameters.add(sb.toString());
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.INTEGER);
			List outList = publicDao.callProc("pk_card_Stock.p_stock_delivery_cancel",inParameters,outParameters);
			if(outList == null || outList.size() <= 0){
				throw new CommonException("库存配送取消调取过程出现错误！");
			}
			if(Integer.valueOf(outList.get(0).toString()) != 0){
				throw new CommonException(outList.get(1).toString());
			}
			//3.记录业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setOrgId(oper.getOrgId());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setClrDate(this.getClrDate());
			rec.setNote(log.getMessage());
			rec.setDealState(Constants.TR_STATE_ZC);
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 柜员领用
	 * @param stockRec 库存流水
	 * @param oper     操作员
	 * @param log      操作日志
	 * @return         业务日志
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public TrServRec saveTellerReceive(StockRec stockRec,String stockDeliveryWay,Users oper,SysActionLog log) throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(stockDeliveryWay).equals("")){
				throw new CommonException("柜员领用方式不能为空！");
			}else if(Tools.processNull(stockDeliveryWay).equals("1")){
				if(Tools.processNull(stockRec.getTaskId()).equals("")){
					throw new CommonException("领用方式已选择【按任务方式领用】请选择任务编号！");
				}
			}else if(Tools.processNull(stockDeliveryWay).equals("2")){
				if(Tools.processNull(stockRec.getStartNo()).trim().equals("") || Tools.processNull(stockRec.getEndNo()).trim().equals("") || Tools.processNull(stockRec.getGoodsNums()).trim().equals("")){
					throw new CommonException("领用方式已选择【按号段领用】请输入起止号码和数量！");
				}
			}else{
				throw new CommonException("柜员领用方式选择不正确！");
			}
			//2.记录操作日志
			log.setDealCode(DealCode.STOCK_TELLER_RECEIVE);
			log.setMessage("柜员领用,领用方式:" + (Tools.processNull(stockDeliveryWay).equals("1") ? "按照任务领用" : "按照号段领用") + "," +
			(Tools.processNull(stockDeliveryWay).equals("1") ? stockRec.getTaskId() : "起始卡号:" + stockRec.getStartNo() + ",截止卡号" + stockRec.getEndNo()) );
			publicDao.save(log);
			//3.业务处理
			StringBuffer sb = new StringBuffer();
			sb.append(Tools.processNull(oper.getBrchId()) + "|");//1.受理点编号
			sb.append(Constants.ACPT_TYPE_GM + "|");//2.受理点类型
			sb.append(Tools.processNull(oper.getUserId()) + "|");//3.受理柜员编号
			sb.append(log.getDealNo() + "|");//4.流水号
			sb.append(log.getDealCode() + "|");//5.交易代码
			sb.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "|");//6.业务受理时间
			sb.append(Tools.processNull(stockRec.getStkCode()) + "|");//7.领用库存类型
			sb.append("0" + "|");//8.领用物品状态
			sb.append(Tools.processNull(oper.getBrchId()) + "|");//9.出库网点 为 操作网点
			sb.append(Tools.processNull(oper.getUserId()) + "|");//10.出库柜员 为操作柜员
			sb.append(Tools.processNull(stockRec.getInBrchId()) + "|");//11.收方网点编号
			sb.append(Tools.processNull(stockRec.getInUserId()) + "|");//12.收方柜员编号
			sb.append(stockDeliveryWay + "|");//13.领用方式
			sb.append(Tools.processNull(stockRec.getTaskId()) + "|");//14.任务编号
			sb.append(Tools.processNull(stockRec.getStartNo()) + "|");//15.起始编号
			sb.append(Tools.processNull(stockRec.getEndNo()) + "|");//16.结果编号
			sb.append(Tools.processNull(stockRec.getGoodsNums()) + "|");//17.数量
			sb.append(Tools.processNull(log.getMessage()) + "|");//18.备注
			List inParameters = new ArrayList();
			List outParameters = new ArrayList();
			inParameters.add(sb.toString());
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List outList = publicDao.callProc("pk_card_Stock.p_stock_exchange",inParameters,outParameters);
			if(outList == null || outList.size() <= 0){
				throw new CommonException("库存配送调取过程出现错误！");
			}
			if(Integer.valueOf(outList.get(0).toString()) != 0){
				throw new CommonException(outList.get(1).toString() + "！");
			}
			//4.业务日志
			TrServRec rec = new TrServRec();
			rec.setDealCode(log.getDealCode());
			rec.setDealNo(log.getDealNo());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchIdIn(stockRec.getInBrchId());
			rec.setUserIdIn(stockRec.getInUserId());
			rec.setBrchIdOut(stockRec.getOutBrchId());
			rec.setUserIdOut(stockRec.getOutUserId());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setNote(log.getMessage());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 柜员交接
	 * @param stockRec 库存流水
	 * @param oper     操作员
	 * @param log      操作日志
	 * @return         业务日志
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public TrServRec saveTellerTransitionMain(StockRec stockRec,String stockDeliveryWay,Users oper,SysActionLog log) throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(stockDeliveryWay).equals("")){
				throw new CommonException("柜员交接方式不能为空！");
			}else if(Tools.processNull(stockDeliveryWay).equals("1")){
				if(Tools.processNull(stockRec.getTaskId()).equals("")){
					throw new CommonException("交接方式已选择【按任务方式交接】请选择任务编号！");
				}
			}else if(Tools.processNull(stockDeliveryWay).equals("2")){
				if(Tools.processNull(stockRec.getStartNo()).trim().equals("") || Tools.processNull(stockRec.getEndNo()).trim().equals("") ||
						Tools.processNull(stockRec.getGoodsNums()).trim().equals("")){
					throw new CommonException("交接方式已选择【按号段交接】请输入起止号码和数量！");
				}
			}else{
				throw new CommonException("柜员交接方式选择不正确！");
			}
			//2.记录操作日志
			log.setDealCode(DealCode.STOCK_TELLER_TRANSITIONMAIN);
			log.setMessage("柜员交接,交接方式:" + (Tools.processNull(stockDeliveryWay).equals("1") ? "按照任务交接" : "按照号段交接") + "," +
			(Tools.processNull(stockDeliveryWay).equals("1") ? stockRec.getTaskId() : "起始卡号:" + stockRec.getStartNo() + ",截止卡号" + stockRec.getEndNo()) );
			publicDao.save(log);
			//3.业务处理
			StringBuffer sb = new StringBuffer();
			sb.append(Tools.processNull(oper.getBrchId()) + "|");//1.受理点编号
			sb.append(Constants.ACPT_TYPE_GM + "|");//2.受理点类型
			sb.append(Tools.processNull(oper.getUserId()) + "|");//3.受理柜员编号
			sb.append(log.getDealNo() + "|");//4.流水号
			sb.append(log.getDealCode() + "|");//5.交易代码
			sb.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "|");//6.业务受理时间
			sb.append(Tools.processNull(stockRec.getStkCode()) + "|");//7.领用库存类型
			sb.append("0" + "|");//8.领用物品状态
			sb.append(Tools.processNull(oper.getBrchId()) + "|");//9.出库网点 为 操作网点
			sb.append(Tools.processNull(oper.getUserId()) + "|");//10.出库柜员 为操作柜员
			sb.append(Tools.processNull(stockRec.getInBrchId()) + "|");//11.收方网点编号
			sb.append(Tools.processNull(stockRec.getInUserId()) + "|");//12.收方柜员编号
			sb.append(stockDeliveryWay + "|");//13.领用方式
			sb.append(Tools.processNull(stockRec.getTaskId()) + "|");//14.任务编号
			sb.append(Tools.processNull(stockRec.getStartNo()) + "|");//15.起始编号
			sb.append(Tools.processNull(stockRec.getEndNo()) + "|");//16.结果编号
			sb.append(Tools.processNull(stockRec.getGoodsNums()) + "|");//17.数量
			sb.append(Tools.processNull(log.getMessage()) + "|");//18.备注
			List inParameters = new ArrayList();
			List outParameters = new ArrayList();
			inParameters.add(sb.toString());
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List outList = publicDao.callProc("pk_card_Stock.p_stock_exchange",inParameters,outParameters);
			if(outList == null || outList.size() <= 0){
				throw new CommonException("柜员交接调取过程出现错误！");
			}
			if(Integer.valueOf(outList.get(0).toString()) != 0){
				throw new CommonException(outList.get(1).toString() + "！");
			}
			//4.业务日志
			TrServRec rec = new TrServRec();
			rec.setDealCode(log.getDealCode());
			rec.setDealNo(log.getDealNo());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchIdIn(stockRec.getInBrchId());
			rec.setUserIdIn(stockRec.getInUserId());
			rec.setBrchIdOut(stockRec.getOutBrchId());
			rec.setUserIdOut(stockRec.getOutUserId());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setNote(log.getMessage());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 新版卡发放,个人发放，规模发放
	 * @param card_no  个人发放时传入卡号
	 * @param task_id  规模发放时传入任务编号
	 * @param log 操作日志
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public void saveCardRelease(String card_no,String task_id,SysActionLog log) throws CommonException{
		try{
			StringBuffer sb = new StringBuffer();
			sb.append(log.getBrchId() + "|");
			sb.append(Constants.ACPT_TYPE_GM + "|");
			sb.append(log.getUserId() + "|");
			sb.append(log.getUserId() + "|");
			sb.append(log.getDealCode() + "|");
			sb.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "|");
			sb.append(card_no + "|");
			sb.append(task_id + "|");
			sb.append(log.getMessage() + "|");
			List inParameters = new ArrayList();
			List outParameters = new ArrayList();
			inParameters.add(sb.toString());
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List outList = publicDao.callProc("pk_card_Stock.p_stock_exchange",inParameters,outParameters);
			if(outList == null || outList.size() <= 0){
				throw new CommonException("发放过程中出现错误！");
			}
			if(Integer.valueOf(outList.get(0).toString()) != 0){
				throw new CommonException(outList.get(1).toString() + "！");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 物品入库
	 * @param stock  库存明细参数信息
	 * 参数信息说明：
	 * StockList.id.stkCode 必填 物品库存类型
	 * StockList.id.goodsId 选填 物品唯一性编号  空值时将依据StockList.goodsNo
	 * StockList.goodsNo 必填 物品编号
	 * StockList.id.goodsState 必填 物品状态
	 * StockList.batchId 选填  批次号
	 * StockList.taskId 选填    任务号
	 * StockList.stkIsSure必填 0 或 1  是否确认
	 * StockList.inBrchId 选填  入库网点 空值时依据当前操作柜员所属网点
	 * StockList.inUserId 选填  入库柜员 空值时依据当前操作员编号
	 * StockList.ownType 必填 物品归属类型
	 * StockList.orgId   归属类型属于柜员时 柜员所属机构
	 * StockList.brchId; 归属类型属于柜员时 柜员所属网点
	 * StockList.userId  归属类型属于柜员时 柜员编号
	 * StockList.customerId 归属类型属于客户时 客户编号
	 * StockList.customerName 归属类型属于客户时 客户名称
	 * StockList.note 备注
	 * @param log    入库日志信息
	 */
	public void saveInStock(StockList stock,SysActionLog log) throws CommonException{
		try{
			StringBuffer sb = new StringBuffer();
			sb.append(log.getBrchId() + "|");
			sb.append(Constants.ACPT_TYPE_GM + "|");
			sb.append(log.getUserId() + "|");
			sb.append(log.getDealNo() + "|");
			sb.append(log.getDealCode() + "|");
			sb.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss"));
			sb.append(stock.getId().getStkCode() + "|");
			sb.append(stock.getId().getGoodsId() + "|");
			sb.append(stock.getGoodsNo() + "|");
			sb.append(stock.getId().getGoodsState() + "|");
			sb.append(stock.getBatchId() + "|");
			sb.append(stock.getTaskId() + "|");
			sb.append(stock.getStkIsSure() + "|");
			sb.append(stock.getInBrchId() + "|");
			sb.append(stock.getInUserId() + "|");
			sb.append(stock.getOwnType() + "|");
			sb.append(stock.getOrgId() + "|");
			sb.append(stock.getBrchId() + "|");
			sb.append(stock.getUserId() + "|");
			sb.append(stock.getCustomerId() + "|");
			sb.append(stock.getCustomerName() + "|");
			sb.append(log.getMessage() + "|");
			List inParameters = new ArrayList();
			List outParameters = new ArrayList();
			inParameters.add(sb.toString());
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List outList = publicDao.callProc("pk_card_Stock.p_stock_exchange",inParameters,outParameters);
			if(outList == null || outList.size() <= 0){
				throw new CommonException("物品入库发生错误！");
			}
			if(Integer.valueOf(outList.get(0).toString()) != 0){
				throw new CommonException(outList.get(1).toString() + "！");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	public String readFileToTable(String userId, File file) throws CommonException {
		BufferedReader br = null;
		try{
			br=new BufferedReader(new InputStreamReader(new FileInputStream(file),"GBK"));
			return readFileToTable(userId,br,file.getName());
		}catch (Exception e) {
			throw new CommonException("处理上传文件失败！",e);
		} catch (Throwable e) {
			throw new CommonException("处理上传文件失败！",e);
		} finally{
			try {
				if(br!=null)br.close();//关闭流
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	public String readFileToTable(String userId, String fileStr) throws CommonException {
		BufferedReader br = null;
		try{
			ByteArrayInputStream stream = new ByteArrayInputStream(fileStr.getBytes()); 
			br=new BufferedReader(new InputStreamReader(stream));
			return readFileToTable(userId,br,"本地制卡文件");
		}catch (Exception e) {
			throw new CommonException("处理上传文件失败！",e);
		} catch (Throwable e) {
			throw new CommonException("处理上传文件失败！",e);
		} finally{
			try {
				if(br!=null)br.close();//关闭流
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	/**
	 * 制卡导入,读取文件,将数据存到临时表中,判断成功再导入正式表
	 * @param oper_Id 当前操作员
	 * @param file 导入的文件
	 * @return
	 * @throws CommonException
	 * @throws IOException 
	 */
	public String readFileToTable(String userId, BufferedReader br,String filename) throws CommonException, IOException {
		try{
			SysActionLog actionLog = this.getCurrentActionLog();
			actionLog.setMessage("制卡导入文件【"+filename+"】及处理入库");
			actionLog.setDealCode(DealCode.ACC_BLANCE_ENCRYPT);
			if(Tools.processNull(actionLog.getInOutData()).length()>1000){
				actionLog.setInOutData(actionLog.getInOutData().substring(0,1000));
			}
			publicDao.save(actionLog);
			//1.删除历史导入信息
			publicDao.doSql("delete from Cm_Card_Import where userId='" + userId + "'");
			//2.获取当前操作眼对象
			Users oper=(Users)findOperByOperId(userId,null);//付方柜员
			
			List escter=this.findBySql("select t.code_value2,t.code_value from escapecharacter t Where " + "t.code_type='CERT_TYPE' And t.code_value<>'2'");//当前系统给卡厂的身份证类型跟库中身份证类型不一致，需要转换
			HashMap esctermap = new HashMap();
			for(int i=0;i<escter.size();i++){
				Object[] o =(Object[])escter.get(i);
				esctermap.put(Tools.processNull(o[0]),Tools.processNull(o[1]));
			}
			
			String data = null;
			String[] onerow=null;//内容行
			String pch=this.getSequenceByName("SEQ_CARD_IMPORT");//本次导入操作的批次号
			String make_Batch_Id=null;//制卡任务批次
			String bank_Id="";
			int i=0;int c=0;//更新记录数
			String taskhead="";
			String currentcardtype="";//当前卡类型
			int totalcount=0;
			int count_OneTask=0;//每个任务的制卡数量
			String task_Id_Prev=null;//前一个任务编号，用于判断前一个任务的任务数量与明细是否一致
			int task_Sum_Prev=0;//前一个任务卡数，用于判断前一个任务的任务数量与明细是否一致
			while ((data = br.readLine()) != null) {
				i++;
				if(data.equals("")){
					continue;
				}
				onerow = (data+" ").split("\\|");//任务内容数据
				if(i==1)taskhead=data;
				if(i==1 && (
							!data.startsWith("task_id|card_type|bank_id|recordcount|taskaddr|serid|sername|companyid|company|region_name|street|community|")
						      &&
						    !data.startsWith("task_id|card_type|recordcount|")
						   )
						   &&!data.startsWith("task_id|data_seq|client_id|name|cert_no|ssseef0507|card_no|struct_main_type|struct_child_type|bar_code|card_id|atr|rfatr|bankcardno|")
				  )
					throw new CommonException("制卡导入文件有误！");
				if(i>2){// 后面为正文信息，中间的分隔用----分隔
					if(onerow[0].indexOf('-')>-1){//若出现分隔线
						i++;//跳过当前分隔线行;
						data=br.readLine();//读后面一行概要信息;
						//data=new String(data.getBytes(),"UTF-8");  
						onerow = data.split("\\|");
						currentcardtype = onerow[1];//卡片类型
						//验证前一个任务的明细数量与概要文件数量是否一致
						//count_OneTask 一个制卡任务的总数量
						//比较上一个制卡文件中  实际读取明细条数 和 概要文件中记录制卡总数是否相等
						if(count_OneTask>0 && task_Sum_Prev!=count_OneTask){
							throw new CommonException("文件中任务号为“"+task_Id_Prev+"”的任务制卡数量与明细制卡数量不一致，请检查！");
						}
						count_OneTask=0;//初始化当前任务的明细数
						//task_Id_Prev 前已任务的ID
						task_Id_Prev=onerow[0];//任务号
						//任务头格式判断
						if(taskhead.startsWith("task_id|card_type|bank_id|recordcount|taskaddr|serid|sername|companyid|company|region_name|street|community|"))
							task_Sum_Prev=Integer.parseInt(onerow[3]);//任务卡数
						else if(taskhead.startsWith("task_id|card_type|recordcount|"))
							task_Sum_Prev=Integer.parseInt(onerow[2]);//任务卡数
						else
							throw new CommonException("制卡文件格式不正确");
						
						//验证同一文件中不同任务号的批次号是否相同，不允许不同的制卡批次
						//校验文件中每个任务是否是同一制卡批次
						//查询内容：批次号，任务数量，任务状态，是否加急
						Object[] obj=(Object[])this.findOnlyRowBySql("select b.make_batch_id,t.task_sum,t.task_State,t.is_urgent   from Cm_Make_Batch b,Cm_Card_Task t  where b.make_batch_id=t.make_batch_id and t.task_id='"+onerow[0]+"'");
						if(obj==null || obj.length==0){
							throw new CommonException("导入文件任务号对应的制卡任务信息不存在，在第 "+i+" 行附近！");
						}
						//根据任务号,查询出任务的相关属性,进行比较,看看是否能够导入文件。
						// 比较制卡数量
						if(Tools.processNull(obj[3]).equals(Constants.MAKE_TYPE_HXZK) && task_Sum_Prev != Integer.parseInt(obj[1].toString())){
							throw new CommonException("导入文件中任务号为“"+task_Id_Prev+"”的任务制卡数量与原始制卡任务信息中的制卡数量不一致，在第 "+i+" 行附近！");
						}
						//1、比较导入文件中卡数量  是否 等于任务对象中的保存的卡数量
						if(Tools.processNull(obj[3]).equals(Constants.MAKE_TYPE_XCZK) && task_Sum_Prev > Integer.parseInt(obj[1].toString())){
							throw new CommonException("导入文件中任务号为“"+task_Id_Prev+"”的任务制卡数量不能大于原始制卡任务信息中的制卡数量，在第 "+i+" 行附近！");
						}
						//2、判断任务状态
						if(!Tools.processNull(obj[2]).equals(Constants.TASK_STATE_ZKZ)){
							throw new CommonException("导入文件中任务号为“"+task_Id_Prev+"”的制卡任务其库中任务状态不为“制卡中”，不能导入，在第 "+i+" 行附近！");
						}
						String batchid= (String)obj[0];//制卡批次号
						//3、比较批次号
						if(make_Batch_Id != null && !make_Batch_Id.equals(batchid)){//与前一制卡批次号不相同
							throw new CommonException("导入文件中包含不同批次的制卡任务信息，在第 "+i+" 行附近！");
						}
						make_Batch_Id = batchid;//从概要信息中取出的制卡批次号
						//==================================================================================
						if(Integer.parseInt(((java.math.BigDecimal)this.findOnlyFieldBySql("select count(*) from Cm_Card_Import t where " +
								"t.task_id='"+task_Id_Prev+"'")).toString())>Integer.parseInt(obj[1].toString())){
							throw new CommonException("导入文件中任务号为“"+task_Id_Prev+"”的制卡明细数不能大于原制卡任务数量，在第 "+i+" 行附近！");
						}
						//更新库存账户
						c=publicDao.doSql("update StockAcc set tot_Num= tot_Num + " + task_Sum_Prev+",last_Tr_Date = sysdate " +
								"where user_Id = '"+actionLog.getUserId()+"' and stk_Code = '"+this.getStkCodeByCardType(currentcardtype)+
								"' and goods_State = '"+Constants.STATE_ZC+"'");
						if(c!=1){
							throw new CommonException("库存分户账<"+this.getStkCodeByCardType(currentcardtype)+">不存在！");
						}
						
						if(Integer.parseInt(((java.math.BigDecimal)publicDao.findOnlyFieldBySql("select count(*) from cm_card_apply t where " +
								"t.apply_state='"+Constants.APPLY_STATE_YZK+"' and t.task_id='"+task_Id_Prev+"'")).toString())+
								task_Sum_Prev==Integer.parseInt(obj[1].toString())){
							c=publicDao.doSql("update Cm_Card_Task set task_State='"+Constants.TASK_STATE_YZK+"',bank_Id='"+bank_Id+"' where task_Id='"+task_Id_Prev+"'");
							if(c!=1){
								throw new CommonException("任务号为<"+task_Id_Prev+">的制卡任务不存在！");
							}
						}
						continue;
					}
					try {
						count_OneTask++;
						totalcount++;
						CardTaskImp imp=new CardTaskImp();
						//imp.setCardTaskImpId(Tools.processInt(pch));//批次号
						imp.setStatustext("正常");//状态描述
						imp.setUserId(userId);//操作员编号
						imp.setStatusid(Constants.CARD_STATE_WQY);//状态号，未启用卡
						if(data.endsWith("||")){
							data=data.substring(0,data.length()-1)+" |";
						}
						imp=(CardTaskImp)MakeCardTask.formatCharacterConvertToObject(imp,this.getSysConfigurationParameters("imptasklist"+currentcardtype).trim(),data.trim(),"|");
						
						if(Tools.processNull(imp.getRfatr()).equals("")){
							imp.setRfatr(imp.getCardId());
						}
						if(!Tools.processNull(imp.getCertType()).equals("")){
							imp.setCertType(Tools.processNull(esctermap.get(imp.getCertType())));
						}
						publicDao.save(imp);
					} catch (Exception e) {
						throw new CommonException("导入文件格式不符合要求，问题可能出现在第 "+i+" 行附近！原因："+e.getMessage());
					}
				}
			}//循环结束
			if(task_Sum_Prev!=count_OneTask){
				throw new CommonException("文件中任务号为“"+task_Id_Prev+"”的任务制卡数量与明细制卡数量不一致，请检查！");
			}
			int implist =this.findByHql("select i.card_Id from Cm_Card_Import i where i.batch_Id='"+pch+"'").size();
			if(implist==0){
				throw new CommonException("文件导入卡数量为零");
			}
			
			int ydr=((java.math.BigDecimal)this.findOnlyFieldBySql("select count(1) from Cm_Card_Import t,Cm_Card c where t.batch_Id='"+pch+
					"' and (c.card_Id=t.card_Id or c.card_No=t.card_No) and c.card_State<>'"+Constants.CARD_STATE_ZX+"'")).intValue();
			if(ydr!=0){
				//return "2";
				throw new CommonException("当前制卡导入文件中已有“"+ydr+"”条数据已经导入，请不要重复导入！");
			}
			
			CardTaskBatch make_batch = (CardTaskBatch)this.findOnlyRowByHql(" from CardTaskBatch c where c.batchId="+make_Batch_Id);
			
			if(make_batch==null||Tools.processNull(make_batch.getBatchId()).equals("")){
				throw new CommonException("当前库中不存在卡制作采购批次号："+make_Batch_Id);
			}
			
			if(((java.math.BigDecimal)this.findOnlyFieldBySql("select nvl(sum(t.task_sum),0) from card_task t where t.make_batch_id='"+make_Batch_Id+"'")).intValue()<totalcount){
				throw new CommonException("当前文件导入制卡明细数不能大于该批次的制卡明细数！");
			}
			
			///==================================================================================
			int applycount = ((java.math.BigDecimal)this.findOnlyFieldBySql("select count(*) from Card_Apply a where a.task_Id='"+
					task_Id_Prev+"'")).intValue();
			
			if(applycount>0){//如果有申领信息说明是记名卡，记名卡需要判断姓名和证件是否正确
				List ndcount = this.findByHql("select i.card_Id from Cm_Card_Import i,Cm_Cardtask_List l  " +
						                     "where l.task_Id=i.task_Id and l.data_Seq=i.data_Seq and l.name=i.name  " +
					                         "and l.cert_No=i.cert_No and i.batch_Id='"+pch+"'");
				if(totalcount!=ndcount.size()){
					throw new CommonException("当前文件中有"+(totalcount-ndcount.size())+"条数据的个人信息不正确，请校验文件");
				}
			}
			
			/** 开始数据的导入工作 **/
			this.importtasklist((applycount>0)?true:false,make_Batch_Id,pch,make_batch.getMakeWay(),currentcardtype,oper,actionLog,totalcount);
			return Integer.valueOf(totalcount).toString();
		}catch(Exception ex){
			throw new CommonException(ex.getMessage());
		}
	}
	
	/**
	 * 保存个人发放/规模发放
	 * @param stk_Code 库存代码
	 * @param card 个人发放
	 * @param task 规模发放
	 * @param sysActionLog
	 * @throws CommonException
	 */
	@Override
	public void saveCardRelease(CardBaseinfo card, CardApplyTask task,SysActionLog sysActionLog) throws CommonException {
		String stkCode=null;//库存代码
		StockType stkType=null;
		StockRec stockRec=new StockRec();
		try{
			if(card==null&&task==null){
				throw new CommonException("发放库存接口中卡片信息或任务号不能同时为空！");
			}
			if(card!=null&&Tools.processNull(card.getCardNo()).equals("")){
				throw new CommonException("卡号不能为空！");
			}
			int tot_Num=0;//卡数量
			int c=0;//更新数量
			Users oper=(Users)findOperByOperId(sysActionLog.getUserId(),null);//付方柜员
			Users outoper=null;//实名制卡、记名卡按网点处理,付方柜员员可能为其它柜员
			if(task == null && card != null){
				tot_Num = 1;
				stkCode=this.getStkCodeByCardType(card.getCardType());
				StockList stklist = (StockList)this.findOnlyRowByHql("from StockList l where l.brchId='"+
						oper.getBrchId()+"' and l.stkCode='"+stkCode+"' and l.goodsState='"+Constants.GOODS_STATE_ZC+
						"' and l.goodsNo='"+card.getCardNo()+"'");
				if(stklist==null)
					throw new CommonException("当前库存明细不存在！");
				outoper=(Users)findOperByOperId(stklist.getUserId(),null);//付方柜员
				c=publicDao.doSql("update Stock_List s set s.own_Type=" + Constants.OWN_TYPE_KH+
						",s.user_Id= (select customer_id from card_baseinfo b where b.card_no=s.goods_no)"+
						",s.brch_Id='',s.org_Id='',out_Date=to_date('" + DateUtil.formatDate(sysActionLog.getDealTime())+
						"','yyyy-MM-dd hh24:mi:ss'),out_user_Id='" + oper.getUserId() + "',out_deal_no='" + sysActionLog.getDealNo()+
						"' where s.brch_Id='"+oper.getBrchId()+"' and s.goods_State='" + Constants.GOODS_STATE_ZC + 
						"' and user_Id='" + outoper.getUserId()+"' and stk_Code='" + stkCode +
						"' and s.goods_No='" + card.getCardNo() + "' ");
				if(c!=tot_Num)
					throw new CommonException("库存物品可用数量不够！");
			}else if(task!=null&&card==null){
				stockRec.setTaskId(task.getTaskId());//任务号
				stockRec.setBatchId(Tools.processNull(task.getMakeBatchId()));//制卡批次号
				tot_Num=task.getTaskSum();
				stkCode=this.getStkCodeByCardType(task.getCardType());
				
				StockList stklist = (StockList)this.findOnlyRowByHql("from StockList l where l.brchId='"+
					oper.getBrchId()+"' and l.stkCode='"+stkCode+"' and l.goodsState='"+Constants.GOODS_STATE_ZC+
					"' and l.taskId='"+task.getTaskId()+"'");
				if(stklist==null)
					throw new CommonException("当前库存明细不存在！");
				outoper=(Users)findOperByOperId(stklist.getUserId(),null);//付方柜员
				c=publicDao.doSql("update Stock_List s set s.own_Type=" + Constants.OWN_TYPE_KH+
						",s.user_Id= (select customer_id from Card_Apply a where a.card_no=s.goods_no and a.task_Id='"+task.getTaskId()+"')"+
						",s.brch_Id='',s.org_Id='',out_Date=to_date('" + DateUtil.formatDate(sysActionLog.getDealTime())+
						"','yyyy-MM-dd hh24:mi:ss'),out_user_Id='" + oper.getUserId() + "',out_Deal_No='" + sysActionLog.getDealNo()+
						"' where s.goods_State='" + Constants.GOODS_STATE_ZC+"' and s.brch_Id='"+oper.getBrchId()+
						"' and stk_Code='" + stkCode +"' and task_Id='" + task.getTaskId() + "' ");
				if(c!=tot_Num)
					throw new CommonException("库存物品可用数量不够！");
			}else{
				throw new CommonException("发放调用更新库存明细接口发生错误！");
			}
			stkType=super.getStockTypeByStkCode(stkCode);//库存种类
			// 4、库存业务记录
			stockRec.setDealCode(sysActionLog.getDealCode());//业务号从日志中获取
			stockRec.setDealCode(sysActionLog.getDealCode());//交易代码
			stockRec.setStkCode(stkCode);//库存代码
			//stockRec.setStockType(stkType.getStkType());//库存种类
			//stockRec.setTotNum(new Long(tot_Num));//数量
			//stockRec.setTotAmt(0);//金额
			stockRec.setOutGoodsState(Constants.GOODS_STATE_ZC);//付方物品状态
			stockRec.setOutUserId(outoper.getUserId());//付方柜员编号
			stockRec.setOutBrchId(outoper.getBrchId());//付方网点编号
			stockRec.setOutOrgId(outoper.getOrgId());//付方机构编号
			stockRec.setInOutFlag(Constants.IN_OUT_FLAG_FC);//收付标志-付
			stockRec.setTrDate(sysActionLog.getDealTime());//交易时间
			stockRec.setUserId(oper.getUserId());//柜员编号
			stockRec.setBrchId(oper.getBrchId());//网点编号
			stockRec.setOrgId(oper.getOrgId());//机构编号
			stockRec.setBookState(Constants.BOOK_STATE_ZS);//业务状态-正常;
			stockRec.setClrDate(this.getClrDate());//清分日期从公用方法中获取
			stockRec.setIsSure(Constants.STK_SEND_STATE_NO);//库存配送状态，默认为未确认
			publicDao.save(stockRec);//此处可能会新增,可能会修改
			//6、更新付方库存账户
			c=publicDao.doSql("update stock_acc s set s.tot_Num=(tot_Num-"+tot_Num+"),last_Tr_Date=to_date('"+
					DateUtil.formatDate(sysActionLog.getDealTime())+"','yyyy-MM-dd HH24:mi:ss') where s.user_Id='"+
					outoper.getUserId()+"' and s.stk_Code='"+stkCode+"' and s.goods_State='"+Constants.GOODS_STATE_ZC+"'");
			if(c!=1){
				throw new CommonException("付方库存分户账不存在！");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
		
	}

	/**
	 * 撤销卡销售
	 * @param dealNo 被撤销的业务流水号
	 * @param sysActionLog 当前日志对象
	 */
	public void saveSaleCard_Cancel(Long dealNo, String userId)
			throws CommonException {
		try{
		//1、验证库存业务记录及业务流水是否存在，若存在，更新记录状态为撤销
			StockRec rec=(StockRec)this.findOnlyRowByHql("from StockRec s where s.dealNo="+dealNo);
			if (rec == null){
				throw new CommonException("业务流水号为“" + dealNo + "”的库存业务记录不存在！");
			}
			if (!rec.getUserId().equals(userId)){
				throw new CommonException("业务流水号为“" + dealNo + "”的库存业务记录不是当前操作员的操作记录！");
			}
			//更新库存业务记录状态为撤销
			rec.setBookState(Constants.BOOK_STATE_CX);
			publicDao.update(rec);
			Users oper=(Users)findOperByOperId(userId,null);//付方柜员
			//2、更新业务流水记录状态为撤销
			//3、更新库存明细归属人信息
			int ssi=publicDao.doSql("update Stock_List s set own_Type='"+Constants.OWN_TYPE_GY+"' ,userId='"+oper.getUserId()+
					"',brch_Id='"+oper.getBrchId()+"',org_Id='"+oper.getOrgId()+"' where exists(select 1 from StockRec b " +
					"where  s.goods_No=b.goods_No and b.deal_No="+dealNo+" and b.user_Id='"+userId+"') ");
			
			//4、更新库存账户数量,非记名销售可能多种卡类型一起销售，因此stockRec中的库存类型为空
			List stks = publicDao.findBySQL("select stk_Code,to_char(count(*)) from StockRec s where s.deal_No="+dealNo+
					" and user_Id='"+userId+"' group by stk_Code");
			for(int i=0;i<stks.size();i++){
				Object[] o = (Object[])stks.get(i);
				int ssl=publicDao.doSql("update stock_Acc a set a.tot_Num=tot_Num+"+o[1]+" where a.stk_Code='"+o[0]+
						"' and user_Id='"+oper.getUserId()+"' and a.goods_State='"+Constants.GOODS_STATE_ZC+"'");
				if(ssl!=1){
					throw new CommonException("当前库存"+o[0]+"分户账不存在！");
				}
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
		
	}
	/**
	 * 非记名卡批量启用
	 * @param stk_Code 库存代码
	 * @param start_No 开始号码
	 * @param end_No 结束号码
	 * @param size 启用卡片数量
	 * @param coustomerId
	 * @param actionLog 日志对象
	 * @throws CommonException
	 */
	@Override
	public void saveOpenBatch(String stk_Code, String start_No, String end_No,int size, String coustomerId, SysActionLog actionLog) throws CommonException {
		try{
			if("".equals(end_No) || "".equals(start_No)){
				throw new CommonException("卡号不能为空！");
			}
			if(size==0){
				throw new CommonException("非记名卡启用数量不能为0");
			}
			
			String[] cardNoArr=CardNumberTools.disposeCardNo(start_No, end_No,super.getCardTypeByStkCode(stk_Code));
			
			// 2、验证库存明细是否存在
			Users oper=(Users)findOperByOperId(actionLog.getUserId(),null);//当前操作员，也是付方柜员(付方柜员与当前柜员一致)
			StockType stk_Type=super.getStockTypeByStkCode(stk_Code);//库存种类
			List detailList=findDetailByCardNoAndOper(oper.getUserId(),null,start_No,end_No,stk_Code,Constants.GOODS_STATE_ZC);;
			StockAcc stksub_out=findLedgerByIdAndState(oper.getUserId(), stk_Code, Constants.GOODS_STATE_ZC);//付方账户
			
			if(stksub_out.getTotNum()<size||detailList.size()<size)
				throw new CommonException("付方库存物品可用数量不够！");
			
			// 3、取系统时间
			Date dt = actionLog.getDealTime();
			String dtstr = DateUtil.formatDate(dt);
			
			// 4、库存业务记录
			List list=publicDao.find("from StockRec t where t.dealNo="+actionLog.getDealNo());
			StockRec rec=null;
			if(list.size()==0){
				rec=new StockRec();
				rec.setTaskId("");//任务号
				rec.setBatchId("");//制卡批次号
				rec.setDealNo(actionLog.getDealNo());//业务号从日志中获取
				rec.setDealCode(actionLog.getDealCode());//交易代码
				rec.setStkCode(stk_Type.getStkCode());//库存种类
				//rec.setStkType(stk_Type.getStkType());//库存代码
				rec.setGoodsNums(size);//数量
				//rec.setGoodsAmt(rec.getGoodsNums()*(this.getCardparaByStkCode(stk_Code).getFaceVal()));//金额
				rec.setOutGoodsState(Constants.GOODS_STATE_ZC);//付方物品状态
				rec.setOutUserId(oper.getUserId());//付方柜员编号
				rec.setOutBrchId(oper.getBrchId());//付方网点编号
				rec.setOutOrgId(oper.getOrgId());//付方机构编号
				rec.setInOutFlag(Constants.IN_OUT_FLAG_FC);//收付标志-付
				rec.setTrDate(dt);//交易时间
				rec.setUserId(oper.getUserId());//柜员编号
				rec.setBrchId(oper.getBrchId());//网点编号
				rec.setOrgId(oper.getOrgId());//机构编号
				rec.setBookState(Constants.BOOK_STATE_ZS);//业务状态-正常;
				rec.setClrDate(this.getClrDate());//清分日期从公用方法中获取
				rec.setIsSure(Constants.STK_SEND_STATE_NO);//库存配送状态，默认为未确认
				publicDao.save(rec);//卡销售的时候，可能一下子销售多种卡类型的，因此会多次调用本办法
			}else{//礼品卡销售第二张调用本方法
				rec=(StockRec)list.get(0);
				if(!Tools.processNull(rec.getStkCode()).equals(stk_Type.getStkCode())){
					rec.setStkCode("");
					//rec.setStkType("");
				}
				rec.setGoodsNums(rec.getGoodsNums()+size);//数量
				//rec.setTot_Amt(rec.getTotAmt()+(size)*(this.getCardparaByStkCode(stk_Code).getFace_al()));//金额
				publicDao.merge(rec);
			}
			
			int c=0;
			String sql="";
			// 5、库存业务流水及修改库存明细
			if(Tools.processNull(stk_Type.getLstFlag()).equals(Constants.YES_NO_YES)){
		
				sql = "update Stock_List s set s.own_Type=" + Constants.OWN_TYPE_KH + ",s.userId='',s.brch_Id='',s.org_Id=''," +
						"out_Date=to_date('" + DateUtil.formatDate(actionLog.getDealTime())+ "','yyyy-MM-dd hh24:mi:ss')," +
						"out_Oper_Id='" + rec.getOutUserId() + "',out_Action_No='" + actionLog.getDealNo()+ "' where goods_State='" +
						rec.getOutGoodsState() + "' and userId='" + rec.getOutUserId()+ "' and stk_Code='" + stk_Code + 
						"' and goods_No between '" + start_No + "' and '" + end_No + "' ";
				c=publicDao.doSql(sql);//库存明细
				if(c!=size)
					throw new CommonException("库存明细数量与当前业务操作数量不一致！");
			}
			//6、更新付方库存账户
			c=publicDao.doSql("update Stock_Acc s set s.tot_Num=(tot_Num-"+size+"),last_Tr_Date=to_date('"+DateUtil.formatDate(dt)+
					"','yyyy-MM-dd HH24:mi:ss') where userId='"+oper.getUserId()+"' and s.stk_Code='"+stk_Code+
					"' and goods_State='"+Constants.GOODS_STATE_ZC+"'");
			if(c!=1){
				throw new CommonException("付方库存账户不存在！");
			}
		}catch(Exception e){
			
		}
		
	}
	/**
	 * 保存补换卡
	 * @param oldcard 如果为null，表示补卡（没有老卡）
	 * @param newcard 如果为null，表示后续制卡（没有新卡）
	 * @param actionLog 日志对象
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	@Override
	public void saveExchangeCard(CardBaseinfo oldcard, CardBaseinfo newcard, SysActionLog actionLog) throws CommonException {
		try{
			actionLog.setDealCode(DealCode.APPLY_TYPE_LXSL);
			actionLog.setMessage("个人申领");
			publicDao.save(actionLog);
			List<Object> in = new java.util.ArrayList<Object>();
			in.add(oldcard.getCardNo());
			in.add(newcard.getCardNo());
			in.add(actionLog.getDealNo());
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			List ret = publicDao.callProc("pk_card_Stock.p_updateCardStock",in,out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(1).toString());
				if (res != 0) {
					String outMsg = ret.get(2).toString();
					throw new CommonException(outMsg);
				}
			} else {
				throw new CommonException("更新库存出错！");
			}
		}catch(Exception e) {
			throw new CommonException("保存补换卡更新库存失败！", e);
		}
		
	}
	/**
	 * 撤销补卡、换卡
	 * @param dealNo 被撤销的业务流水号
	 * @param sysActionLog 当前日志对象
	 * @throws CommonException
	 */
	/***********************************************************************
	 * 流程说明
	 * 1、处理参数
	 * 2、验证库存业务记录及业务流水是否存在
	 * 3、更新存业务记录及业务流水记录状态为撤销
	 * 4、更新库存明细归属人信息
	 * 5、更新库存账户数量
	 **********************************************************************/	
	@Override
	public void saveChangeCard_Cancel(Long dealNo, String userId)throws CommonException {
		try{
	
			//1、处理参数
			String client_Id="";//换卡客户编号，从原出库的存明细中获取
			boolean isExistsOldCard=false;//原交易是否存在旧卡退回，若存在，则原交易对应两条库存明细和两条库存业务流水
			boolean isExistsNewCard=false;//
			
			//2、验证库存业务记录及业务流水是否存在，若存在，更新记录状态为撤销
			StockRec rec=(StockRec)this.findOnlyRowByHql("from StockRec t where t.dealNo="+dealNo);
			TrServRec srec = (TrServRec)this.findOnlyRowByHql("from TrServRec t where t.dealNo="+dealNo);
			if (rec == null)
				throw new CommonException("业务流水号为“" + dealNo + "”的库存业务记录不存在！");
			if(rec.getInOutFlag().equals(Constants.IN_OUT_FLAG_SF) || rec.getInOutFlag().equals(Constants.IN_OUT_FLAG_SR)){//收付标志为收付
				isExistsOldCard=true;
			}
			if(rec.getInOutFlag().equals(Constants.IN_OUT_FLAG_SF) || rec.getInOutFlag().equals(Constants.IN_OUT_FLAG_FC)){//收付标志为收付
				isExistsNewCard=true;
			}
			
			if (!rec.getUserId().equals(userId))
				throw new CommonException("业务流水号为“" + dealNo + "”的库存业务记录不是当前操作员的操作记录！");
			//验证业务流水是否存在
			StockRec book_in=null;//原收入业务流水对象
			StockRec book_out=null;//原付出业务流水对象
			if (isExistsOldCard){//若存在旧卡
				book_in = (StockRec) this.findOnlyRowByHql("from StockRec where dealNo=" + dealNo + " and userId='" + userId
						+ "' and in_Goods_State='" + rec.getInGoodsState() + "'");//旧卡状态为质量退卡待处理
				if (book_in == null)
					throw new CommonException("旧卡库存业务流水信息不存在！");
			}
			if (isExistsNewCard){//
			book_out = (StockRec) this.findOnlyRowByHql("from StockRec where dealNo='" + dealNo + "' and in_Goods_State='"
					+ rec.getInGoodsState() + "'");// 原付出业务流水对象
				if (book_out == null)
					throw new CommonException("新卡库存存业务流水不存在!");
			}
			
			//验证库存明细是否存在
			List daybookList=this.findByHql("from StockRec where dealNo="+dealNo +" and userId='"+userId+"'");
			if(daybookList==null || (isExistsOldCard && isExistsNewCard && daybookList.size()!=2) ||((isExistsOldCard ||isExistsNewCard) && daybookList.size()!=1))
				throw new CommonException("业务流水号为“" + dealNo + "”的库存业务流水不存在！");
			StockRec daybook=(StockRec)daybookList.get(0);
			
			StockList detail_in=null;//原收入物品明细对象
			StockList detail_out=null;//原付出物品明细对象
			if (isExistsOldCard){//若存在旧卡
				String sql = "from StockList where goods_No='" + book_in.getGoodsNo() + "' and userId='" + userId
				+ "' and Goods_State='" +rec.getInGoodsState() + "'";
				detail_in = (StockList) this.findOnlyRowByHql("from StockList where goods_No='" + book_in.getGoodsNo() + "' and userId='" + userId
						+ "' and Goods_State='" +rec.getInGoodsState() + "'");//旧卡状态为质量退卡待处理
				if (detail_in == null){
					throw new CommonException("旧卡"+book_in.getGoodsNo()+"库存明细不存在！");
				}
			}
			if (isExistsNewCard){//若存在新卡
			detail_out = (StockList) this.findOnlyRowByHql("from StockList where goods_No='" + book_out.getGoodsNo()
					+ "' and Goods_State='" + rec.getInGoodsState() + "'");// 原付出物品明细对象
				if (detail_out == null){
					throw new CommonException("新卡"+book_out.getGoodsNo()+"库存明细不存在！");
				}
			}
			//3、更新存业务记录及业务流水记录状态为撤销
			rec.setBookState(Constants.BOOK_STATE_CX);
			publicDao.update(rec);
			int c=publicDao.doSql("update Stock_Rec set book_state='"+Constants.BOOK_STATE_CX+"' where deal_no='"+dealNo+"'");
			if ((isExistsOldCard && isExistsNewCard && daybookList.size()!=2) ||((isExistsOldCard ||isExistsNewCard) && daybookList.size()!=1))
				throw new CommonException("库存业务流水数量与卡数量不一致！");
			
			//4、更新库存明细归属人信息
			if(detail_in!=null){
				String sql = " update stock_list set user_id = '"+srec.getUserId()+"', brch_id =null , " +
						"org_id = null, own_type = '"+Constants.OWN_TYPE_KH+
				"',goods_state ='"+Constants.GOODS_STATE_ZC+"' where goods_No= '" + srec.getCardNo() +
				"' and stk_Code ='"+rec.getStkCode()+"'";
//				dao.update(detail_in);
				publicDao.doSql(sql);
			}
			Users oper=(Users)findOperByOperId(userId,null);
			if(detail_out!=null){
				String sql = " update stock_list set user_id = '"+rec.getUserId()+"', brch_id ='"
				+rec.getBrchId()+"', org_id = '"+rec.getOrgId()+"', own_type = '"+Constants.OWN_TYPE_GY+
				"',goods_state ='"+rec.getInGoodsState()+"' where goods_No= '" + srec.getOldCardNo() +
				"' and stk_Code ='"+rec.getStkCode()+"' and goods_State='"+Constants.GOODS_STATE_ZC+"'";
//				dao.update(detail_in);
				publicDao.doSql(sql);
			}
			srec.setDealState("1");
			publicDao.merge(srec);   //修改综合业务日志表
			//5、更新库存账户数量
			if(detail_out!=null){
				//publicDao.doSql("update stock_Acc set tot_num=tot_num+1 where stk_code='"+detail_out.get+"' and user_id='"+oper.getUserId()+"' and goods_state='"+rec.getInGoodsState()+"'");
			}
			if(detail_in!=null){
				//publicDao.doSql("update stock_Acc set tot_num=tot_num-1 where stk_code='"+detail_in.getStkCode()+"' and user_id='"+oper.getUserId()+"' and goods_state='"+rec.getInGoodsState()+"'");
			}
		}catch(Exception e){
			
		}
		
	}
	/**
	 * 白卡零星制卡，出库入库
	 */
	@Override
	public void saveInOutStock(CardBaseinfo card, String customerId,SysActionLog actionLog) throws CommonException {
		try{
			Users outOper = (Users)this.findOperByOperId(actionLog.getUserId(),null);//付方柜员
			String stk_Code=this.getStkCodeByCardType(card.getCardType());// 库存代码
			String stk_Type=this.getStkTypeByCardType(card.getCardType());// 库存种类
			String stk_Code_out="5100";// 付方库存代码，指定为白卡
			
			/** 更新付方帐户 */
			StockAcc stksub_out = findLedgerByIdAndState(actionLog.getUserId(),stk_Code_out,Constants.GOODS_STATE_ZC);
			if (stksub_out == null) {
				throw new CommonException("未查询到付方柜员对应的账户信息,请到“库存账户”中开户！");
			}
			if (stksub_out.getTotNum() < 1) {
				throw new CommonException("付方库存类型对应的账户物品数量不够！");
			}
			stksub_out.setTotNum(stksub_out.getTotNum() - 1);// 数量
			stksub_out.setLastDealDate(actionLog.getDealTime());// 最后交易日期
			publicDao.update(stksub_out);
			
			/** 插入库存明细 */
			StockList stklist = new StockList();
			//stklist.setStkType(stk_Type);
			//stklist.setStkCode(stk_Code);
			stklist.setGoodsNo(card.getCardId());
			stklist.setGoodsNo(card.getCardNo());
			//stklist.setGoodsState(Constants.GOODS_STATE_ZC);
			//stklist.setValidDate(card.getValidDate());
			stklist.setInDate(actionLog.getDealTime());
			stklist.setInUserId(outOper.getUserId());
			stklist.setInDealNo(actionLog.getDealNo());
			stklist.setOutDate(actionLog.getDealTime());
			stklist.setOutUserId(outOper.getUserId());
			stklist.setOutDealNo(actionLog.getDealNo());
			stklist.setOwnType(Constants.OWN_TYPE_KH);
			stklist.setOrgId(null);//机构号置空
			stklist.setBrchId(null);//网点号置空
			stklist.setUserId(customerId);//客户编号
			stklist.setNote("白卡零星制卡，出库入库");
			publicDao.save(stklist);
			
			/** 库存业务记录 */
			// 4、库存业务记录
			StockRec rec=new StockRec();
			rec.setTaskId("");//任务号
			rec.setBatchId(null);//制卡批次号
			rec.setDealNo(actionLog.getDealNo());//业务号从日志中获取
			rec.setDealCode(actionLog.getDealCode());//交易代码
			rec.setStkCode(stk_Code);//库存种类
			//rec.setStkType(stk_Type);//库存代码
			rec.setGoodsNums(1);//数量
			//rec.setTot_Amt(0l);//金额
			rec.setStartNo(card.getCardNo());//开始号码
			rec.setEndNo(card.getCardNo());//结束号码
			rec.setOutGoodsState(Constants.GOODS_STATE_ZC);//付方物品状态
			rec.setOutUserId(outOper.getUserId());//付方柜员编号
			rec.setOutBrchId(outOper.getBrchId());//付方网点编号
			rec.setOutOrgId(outOper.getOrgId());//付方机构编号
			rec.setInOutFlag(Constants.IN_OUT_FLAG_FC);//收付标志-付
			rec.setTrDate(actionLog.getDealTime());//交易时间
			rec.setUserId(outOper.getUserId());//柜员编号
			rec.setBrchId(outOper.getBrchId());//网点编号
			rec.setOrgId(outOper.getOrgId());//机构编号
			rec.setBookState(Constants.BOOK_STATE_ZS);//业务状态-正常;
			rec.setClrDate(this.getClrDate());//清分日期从公用方法中获取
			rec.setIsSure(Constants.STK_SEND_STATE_NO);//库存配送状态，默认为未确认
			publicDao.save(rec);
	
		}catch(Exception e){
			
		}
		
	}
	/**
	 * 非记名卡退卡
	 * @param oldRec 老的综合业务日志
	 * @param actionLog 操作日志对象
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	@Override
	public void savelFjmkTk(TrServRec oldRec, SysActionLog actionLog, Users oper)
			throws CommonException {
		try{
			//1.记录库存业务日志
			StockRec stk_rec = new StockRec();//库存业务记录对象
			StockType stk_Type=super.getStockTypeByStkCode(this.getStkCodeByCardType(oldRec.getCardType()));//获取库存类型
			stk_rec.setDealNo(actionLog.getDealNo());//业务流水号
			stk_rec.setDealCode(actionLog.getDealCode());//交易代码
			stk_rec.setStkCode(stk_Type.getStkCode());//库存代码
			//stk_rec.setStkType(stk_Type.getStkType());//库丰种类
			stk_rec.setGoodsNums(1);
			stk_rec.setInOutFlag(Constants.IN_OUT_FLAG_SR);//收付标志-收
			stk_rec.setInGoodsState(Constants.GOODS_STATE_ZLTKDCL);//收方物品状态
			stk_rec.setInUserId(oper.getUserId());//收方柜员编号
			stk_rec.setInBrchId(oper.getBrchId());//收方网点编号
			stk_rec.setInOrgId(oper.getOrgId());//收方机构编号
			//stk_rec.setTotAmt(0l);//金额
			stk_rec.setTrDate(actionLog.getDealTime());//交易时间
			stk_rec.setUserId(oper.getUserId());//柜员编号
			stk_rec.setBrchId(oper.getBrchId());//柜员网点编号
			stk_rec.setOrgId(oper.getOrgId());//柜员机构编号
			stk_rec.setBookState(Constants.BOOK_STATE_ZS);//业务状态-正常
			stk_rec.setClrDate(this.getClrDate());//清分日期
			stk_rec.setIsSure(Constants.STK_SEND_STATE_NO);//库存配送状态，默认为未确认
			publicDao.save(stk_rec);
	
			//2.更新库存明细归属人信息
			int ssi=publicDao.doSql("update Stock_List s set s.goods_State = '2', s.own_Type='"+Constants.OWN_TYPE_GY+"' ,s.user_Id='"+oper.getUserId()+
					          "',s.brch_Id='"+oper.getBrchId() + "',s.in_Date = to_date('" + DateUtil.formatDate(actionLog.getBrchId(),"yyyy-MM-dd HH:mm:ss") +"','yyyy-mm-dd hh24:mi:ss'),s.in_user_Id='" + oper.getUserId() + "',s.in_deal_No='" + actionLog.getDealNo() +
					          "' where s.GOODS_NO='"+oldRec.getCardNo() + "' and exists (select 1 from Stock_Rec t where t.goods_No='" + oldRec.getCardNo().trim() + "' and t.deal_No=" + actionLog.getDealNo() + ")");
			//3.更新库存账户数量
			int ssl=publicDao.doSql("update Stock_Acc set tot_Num=tot_Num+"+1+",last_Tr_Date=to_date('"+ DateUtil.formatDate(actionLog.getDealTime()) +"','yyyy-mm-dd hh24:mi:ss') where stk_Code='"+this.getStkCodeByCardType(oldRec.getCardType())+
					          "' and user_Id='"+oper.getUserId()+"' and goods_State='"+Constants.GOODS_STATE_ZLTKDCL+"'");
			if(ssl!=1){
				throw new CommonException("当前库存"+this.getStkCodeByCardType(oldRec.getCardType())+"分户账不存在！");
			}
		}catch(Exception e){
			throw new CommonException("C卡/异型卡销售退卡出现错误，入库发生错误",e);
		}
		
	}
	
	/**
	 * 根据起止号码查询库存明细信息
	 * @param userId
	 * @param brch_Id
	 * @param start_No
	 * @param end_No
	 * @param stk_Code
	 * @param goods_State
	 * @return
	 * @throws CommonException
	 */
	public List findDetailByCardNoAndOper(String user_Id, String brch_Id, String start_No, String end_No, String stk_Code,
			String goods_State) throws CommonException {
		try {
			String sql = " from Stock_List where length(goods_No)=" + end_No.length();
			if(start_No.equals(end_No)){
				sql+=" and goods_No = '" + start_No + "' ";
			}else{
				sql+=" and goods_No between '" + start_No + "' and '" + end_No+"' ";
			}
			sql += SqlTools.eq("userId", user_Id);
			sql += SqlTools.eq("brchId", brch_Id);
			sql += SqlTools.eq("goodsState", goods_State);
			sql += SqlTools.eq("stkCode", stk_Code);
			return publicDao.find(sql);
		} catch (Exception e) {
			throw new CommonException("根据起止号码查询库存明细信息失败！", e);
		}
	}
	
	/**
	 * 根据柜员编号、库存代码、物品状态查询账户
	 * @param userId
	 * @param stkCode
	 * @param goodsState
	 * @return
	 * @throws CommonException
	 */
	public StockAcc findLedgerByIdAndState(String userId, String stkCode, String goodsState) throws CommonException {
		try {
			String hql = "from StockAcc s where s.userId='" + userId + "' and stkCode='" + stkCode + "' and good_State='"
					+ goodsState + "'";
			return (StockAcc) publicDao.find(hql).get(0);
		} catch (Exception e) {
			throw new CommonException("根据柜员编号、库存代码、物品状态查询账户信息失败！", e);
		}
	}
	/**
	 * 通过卡类型查找库存类型
	 */
	public String getStkTypeByCardType(String cardtype){
		return getStkTypeByStkCode(getStkCodeByCardType(cardtype));
	}
	/**
	 * 通过库存代码查找库存种类实体
	 */
	public StockType getStockTypeByStkCode(String stkCode){
		initStkStockTypeList();
		for(int i=0;i<stockTypeList.size();i++){
			StockType stocktype = (StockType)stockTypeList.get(i);
			if(Tools.processNull(stocktype.getStkCode()).equals(stkCode))
				return stocktype;
		}
		throw new CommonException("通过库存代码'"+stkCode+"'找不到库存种类实体");
	}
	/**
	 * 通过库存代码查找库存类型
	 */
	public String getStkTypeByStkCode(String stkCode){
		return getStockTypeByStkCode(stkCode).getStkType();
	}
	/***
	 * 插入库存
	 * @param isname
	 * @param make_Batch_Id
	 * @param pch
	 * @param make_Way
	 * @param cardType
	 * @param oper
	 * @param actionLog
	 * @param totalcount
	 * @throws CommonException
	 */
	public void importtasklist(boolean isname,String make_Batch_Id,String pch,String make_Way,String cardType,Users oper, SysActionLog actionLog,int totalcount) throws CommonException{
		int c=0;
		int kcexistcount=publicDao.doSql("update Stock_List l set l.goods_State='"+Constants.STATE_ZC+"',l.make_Batch_Id='"+make_Batch_Id+
				"',l.own_Type='"+Constants.OWN_TYPE_GY+"',l.org_Id='"+oper.getOrgId()+"',l.brch_Id='"+oper.getBrchId()+"',l.oper_Id='"+
				oper.getUserId()+"',(l.goods_No,l.goods_Alias_No,l.task_Id)=(select t.rfatr,t.card_no,t.task_id from Cm_Card c,Cm_Card_Import t " +
				"where (t.card_no=c.card_no or t.ssseef0507=c.sub_card_no) and c.card_State<>'"+Constants.CARD_STATE_ZX+
				"' and c.card_no=l.goods_Alias_No and t.batch_Id='"+pch+"') where exists(select 1 from Cm_Card_Import i,Cm_Card c " +
				" where (i.card_no=c.card_no or i.ssseef0507=c.sub_card_no) and c.card_State<>'"+Constants.CARD_STATE_ZX+
				"' and c.card_No=l.goods_No and i.batch_Id='"+pch+"') ");
		int existcount=publicDao.doSql("update Card_Baseinfo c set c.card_State='"+Constants.CARD_STATE_WQY+
				"',(c.card_Id,c.card_No,sub_Card_Id,sub_card_no,atr)=(select t.rfatr,t.card_no,t.card_Id,t.ssseef0507,t.atr from " +
				" Cm_Card_Import t where (t.card_no=c.card_no or t.ssseef0507=c.sub_card_no) and t.batch_Id='"+pch+
				"') where exists(select 1 from Cm_Card_Import i where (i.card_No=c.card_No or i.ssseef0507=c.sub_card_no) and c.card_State<>'"+
				Constants.CARD_STATE_ZX+"' and i.batch_Id='"+pch+"') ");

		/**cm_card表中已经存在 与cm_card_import表相对应的数据    则将cm_card_import表中数据删除*/
		int delcount=publicDao.doSql("delete from Cm_Card_Import i where exists(select 1 from Cm_Card c where (c.card_No=i.card_No or " +
				"i.ssseef0507=c.sub_card_no) and c.card_State<>'"+Constants.CARD_STATE_ZX+"' ) and i.batch_Id='"+pch+"'");
		if(delcount>0){
			publicDao.doSql("update Stock_Acc set tot_Num= tot_Num - "+delcount+",last_Tr_Date = sysdate " +
					"where oper_Id = '"+actionLog.getUserId()+"' and stk_Code = '"+this.getStkCodeByCardType(cardType)+
					"' and goods_State = '"+Constants.STATE_ZC+"'");
		}
		if(existcount!=kcexistcount||existcount!=delcount||delcount>totalcount)
			throw new CommonException("制卡文件导入发生错误");
		totalcount=totalcount-existcount;
		if(isname){
			//修改申领表申领状态
			c=publicDao.doSql("update Card_Apply a set (a.apply_State,a.card_No,a.bank_Card_No)=(select '"+Constants.APPLY_STATE_YZK+
					"',i.card_No,case when i.bankcardno is null then a.bank_Card_No else i.bankcardno end " +
					"from Cm_Card_Import i,Cm_Cardtask_List l where i.data_Seq=l.data_Seq and l.apply_Id=" +
					"a.apply_Id and i.batch_Id='"+pch+"') where exists(select 1 from Cm_Card_Import i,Cm_Cardtask_List l " +
					"where i.data_Seq=l.data_Seq and l.apply_Id=a.apply_Id and i.batch_Id='"+pch+"')");
			if(c!=totalcount)throw new CommonException("当前导入文件数据不正确！");
			//重复导入的话修改任务明细里的卡号
			c=publicDao.doSql("update CM_CARDTASK_LIST a set a.CARD_NO=(select b.card_no from CM_CARD_IMPORT b where b.data_seq=a.data_seq and " +
				"b.batch_id='"+pch+"') where exists (select 1 from cm_card_import c where c.data_seq = a.data_seq and c.batch_id='"+pch+"')");
			if(c!=totalcount)throw new CommonException("当前导入文件数据不正确！");
			
			c=publicDao.doSql("insert into Card_Baseinfo (card_id,card_no,sub_Card_Id,sub_card_no,client_id,card_type,version,org_code,city_code,ind_code," +
					"issue_date,start_date,valid_date,card_state,last_Modi_Date,cost_fee,rent_foregift,foregift,foregift_bal," +
					"bank_id,bank_card_no,bar_code,atr,rfatr,note,isparent,parent_card_no,bus_type) " +
					"(select i.rfatr,i.card_no,i.card_id,i.ssseef0507,i.client_id,a.card_type,a.version,a.org_code," +
					"a.city_Code,a.indus_Code,l.cardissuedate,l.cardissuedate,l.SSSEEF0506,'"+Constants.CARD_STATE_WQY+
					"',sysdate,a.cost_fee,0,a.foregift,a.foregift,a.bank_Id,a.bank_Card_No,a.bar_code,i.atr,i.rfatr,'记名卡批量导入',a.isparent,a.parent_card_no,l.struct_main_type " +
					"from Cm_Cardtask_List l,Card_Apply a,Cm_Card_Import i " +
					"where i.data_Seq=l.data_Seq and l.apply_Id=a.apply_Id and i.batch_Id='"+pch+"')");
			if(c!=totalcount)throw new CommonException("当前导入文件数据不正确！");
		}else{
			c=publicDao.doSql("insert into Card_Baseinfo (card_id,card_no,sub_Card_Id,sub_card_no,card_type,version,org_code,city_code,ind_code," +
					"issue_date,start_date,valid_date,card_state,last_Modi_Date,cost_fee,rent_foregift,foregift,foregift_bal,atr,note,isparent,bank_id,bank_card_no,bus_type) " +
					"(select i.card_id,i.card_no,i.card_id,i.ssseef0507,l.card_type,l.version,l.org_code," +
					"l.city_code,l.ind_code,l.cardissuedate,l.cardissuedate,l.validitydate,'"+Constants.CARD_STATE_WQY+
					"',sysdate,0,0,p.foregift,p.foregift,i.atr,'非个性化卡采购批量导入', '"+Constants.YES_NO_YES+"'," +"t.bank_id,i.bankcardno,l.struct_main_type "+
					"from Cm_Cardtask_List l,Cm_Card_Import i,Cm_Card_Para p,Cm_Card_Task t " +
					"where i.data_Seq=l.data_Seq and t.task_id=i.task_id and l.card_Type=p.card_Type and i.batch_Id='"+pch+"')");
			if(c!=totalcount)throw new CommonException("当前导入文件数据不正确！");
		}
		/** 本地制卡的处理 */
		if(make_Way.equals(Constants.MAKE_WAY_BD)){//The local system Card white card storage, and outsourcing system, the difference between cards here
			//更新半成品分户账
			StockAcc bk_ledger = (StockAcc)this.findByHql("from StockAcc s where " +
				" s.oper_Id = '"+actionLog.getUserId()+"' and s.stk_Code = '"+this.getStkCodeByCardType(Constants.CARD_TYPE_JMK_BCP)+
				"' and s.goods_State = '"+Constants.STATE_ZC+"'").get(0);
			if(bk_ledger.getTotNum()<totalcount)
				throw new CommonException("该柜员库存分户账没有足够白卡（半成品卡）制卡，请更换成领取白卡制卡柜员操作入库");
			c=publicDao.doSql("update StockAcc set tot_Num= tot_Num - "+totalcount+",last_Tr_Date = sysdate " +
					"where oper_Id = '"+actionLog.getUserId()+"' and stk_Code = '"+
					this.getStkCodeByCardType(Constants.CARD_TYPE_JMK_BCP)+
					"' and goods_State = '"+Constants.STATE_ZC+"'");
			if(c!=1)throw new CommonException("半成品库存分户账不存在！");
		
		}
		//写入库存交易流水Stk_Day_Book
		String note=make_Way.equals(Constants.MAKE_WAY_BD)?"本地制卡批量导入":"外包制卡批量导入";
		if(isname){
		
			
			//记录库存明细Stock_List
			c=publicDao.doSql("insert into Stock_List (stk_type,stk_code,goods_no,goods_no,goods_state," +
					"make_batch_id,task_id,in_date,in_user_id,in_deal_no,reuse_num,org_id,brch_id,own_type,oper_id,note) " +
					"(select t.stk_Type,t.stk_code,i.rfatr,i.card_no,0,i.batch_id,i.task_id,sysdate,'"+oper.getUserId()+
					"','"+actionLog.getDealNo()+"',0,'"+oper.getOrgId()+"','"+oper.getBrchId()+"',0,'"+oper.getUserId()+"','"+note+"'  " +
					"from Card_Apply l,Cm_Card_Import i,Cm_Card_Para p,Stk_Stock_Type t,Cm_Card_Task  ct  " +
					"where i.card_No = l.card_No and l.card_Type=p.card_Type and p.stk_Code=t.stk_Code and i.batch_Id='"+pch+"'  and i.task_Id=ct.task_Id and ct.make_Batch_Id="+make_Batch_Id+")");
			if(c!=totalcount)throw new CommonException("当前导入文件数据不正确！");
		}else{
	
			//记录库存明细Stock_List
			c=publicDao.doSql("insert into Stock_List (stk_type,stk_code,goods_no,goods_no,goods_state,valid_date," +
					"make_batch_id,task_id,in_date,in_user_id,in_deal_no,reuse_num,org_id,brch_id,own_type,oper_id,note) " +
					"(select t.stk_Type,t.stk_code,i.card_no,i.card_no,0,l.validitydate,i.batch_id,i.task_id,sysdate,'"+oper.getUserId()+
					"','"+actionLog.getDealNo()+"',0,'"+oper.getOrgId()+"','"+oper.getBrchId()+"',0,'"+oper.getUserId()+"','"+note+"'  " +
					"from Cm_Cardtask_List l,Cm_Card_Import i,Cm_Card_Para p,Stk_Stock_Type t " +
					"where i.data_Seq=l.data_Seq and l.card_Type=p.card_Type and p.stk_Code=t.stk_Code and i.batch_Id='"+pch+"')");
			if(c!=totalcount)throw new CommonException("当前导入文件数据不正确！");
		}
		
		//记录入库业务Stock_Rec
		publicDao.doSql("insert into Stock_Rec (deal_no,deal_code,make_batch_id,tot_num,tot_amt,out_goods_state,in_goods_state," +
				"in_user_id,in_brch_id,in_org_id,tr_date,org_id,brch_id,oper_id,in_out_flag,tr_state,clr_date) " +
				"values ("+actionLog.getDealNo()+",'"+actionLog.getDealCode()+"','"+make_Batch_Id+"','"+totalcount+"',0,0,0,'"+
				oper.getUserId()+"','"+oper.getBrchId()+"','"+oper.getOrgId()+"',sysdate,'"+oper.getOrgId()+"','"+
				oper.getBrchId()+"','"+oper.getUserId()+"',1,0,'"+this.getClrDate()+"')");
		
		//完善制卡批次表Cm_Make_Batch的接受人和接受时间
		publicDao.doSql("update Cm_Make_Batch set recv_Oper_Id='"+oper.getUserId()+"',recv_Time=sysdate where make_Batch_Id='"+make_Batch_Id+"'");
	}
	/**
	 * 保存配送确认
	 * @param rec
	 * @param action_no
	 * @throws CommonException
	 */
	@Override
	public void saveBranchAccept(StockRec rec, String[] dealnos)throws CommonException {
		try {
			// 记日志
			SysActionLog log = this.getCurrentActionLog();
			log.setMessage("配送确认");
			log.setDealCode(DealCode.ACC_CREDIT_LIMIT_ADD);//暂不获取交易代码
			publicDao.save(log);
			for(int i=0;i<dealnos.length;i++){
				if(Tools.processNull(dealnos[i]).equals(""))
					continue;
				long current_action_no=new Long(Integer.valueOf(Tools.processNull(dealnos[i])));
				publicDao.doSql(" update stock_Rec set is_Sure='" + Constants.STK_SEND_STATE_YES + "',tr_code='"+
						DealCode.ACC_CREDIT_LIMIT_ADD+"' where action_No=" + current_action_no);// 更新业务记录确认状态
				publicDao.doSql(" update Cm_Card_Task set task_State='" + Constants.TASK_STATE_YJS + "' where task_State='"+ 
						Constants.TASK_STATE_YPS + "' and task_Id=(select task_Id from Stk_Biz_Rec where action_No=" + 
						current_action_no+ ")");// 更新任务状态为已接收
				publicDao.doSql(" update Cm_Card_Apply set apply_State='" + Constants.APPLY_STATE_YJS + 
						"' where apply_State='"+ Constants.APPLY_STATE_YPS + 
						"' and task_Id=(select task_Id from Stk_Biz_Rec where action_No=" + current_action_no+ ")");// 更新申领状态为已接收
				
				Object[] dxpara=(Object[])this.findOnlyRowBySql("select p.isfixed,p.content from sys_smessages_para p where p.state="+
						Constants.YES_NO_YES+" and p.tr_code="+DealCode.ACC_CREDIT_LIMIT_ADD);
				if(dxpara!=null){//配送之后是否需要固定短信内容提示
					Object[] tcn=(Object[])this.findOnlyRowBySql("select t.task_id,c.code_name from Stk_Biz_Rec r,cm_card_task t,sys_code c " +
							"where r.task_id=t.task_id and t.card_type=c.code_value and c.code_type='CARD_TYPE' and r.action_no='"+
							current_action_no+"'");
					
					if(Tools.processNull(dxpara[0]).equals(Constants.YES_NO_YES)){
						publicDao.doSql("insert into sys_smessages(select SEQ_SYS_SMESSAGES.Nextval,'01',p.client_id,a.card_no," +
								"p.mobile_no,'"+dxpara[1]+"',null,0,null,'admin',"+DealCode.ACC_CREDIT_LIMIT_ADD+",'"+current_action_no+
								"',to_char(sysdate,'yyyy-mm-dd mm:mi:ss') ,'任务已接收，通知客户来领卡' from bs_person p,cm_card_apply a " +
								"where p.client_id=a.client_id and length(p.mobile_no)=11 and a.task_id='" + tcn[0]+ "')");
					}else{
						publicDao.doSql("insert into sys_smessages (SMS_NO, SMS_TYPE, CLIENT_ID, CARD_NO, MOBILE_NO, CONTENT, RTN_STATE, " +
							"SMS_STATE, SEND_TIME, OPER_ID, TR_CODE, ACTION_NO, TIME, NOTE) " +
							"(select SEQ_SYS_SMESSAGES.Nextval,'01',p.client_id,a.card_no,p.mobile_no," +
							"'新天短信提醒：您于'||to_char(a.apply_date,'yyyy-MM-dd HH24:mi:ss')||'在'||b.brch_name||" +
							"'办理的"+tcn[1]+"现已制作完成，请您及时到该营业厅领取。',null,0,null,'admin','"+DealCode.ACC_CREDIT_LIMIT_ADD+"','"+
							current_action_no+"',to_char(sysdate,'yyyy-mm-dd mm:mi:ss') ,'任务已接收，通知客户来领卡' " +
							"from bs_person p,cm_card_apply a,sys_branch b where p.client_id=a.client_id and " +
							"a.apply_brch_id=b.brch_id and length(p.mobile_no)=11 and a.task_id='" + tcn[0]+ "')");
				
					}
				}
			}
		} catch (Exception e) {
			throw new CommonException("配送确认操作失败！", e);
		}
		
	}
	@Override
	public List saveUserDownStock(StockRec rec, String pwd, String send_Type)
			throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}
	@Override
	public long saveUserUpStock(StockRec rec, String pwd)
			throws CommonException {
		// TODO Auto-generated method stub
		return 0;
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public void saveTellerTransitionAll(StockRec stockRec, Users curUser, SysActionLog log) {
		try {
			// 1.
			if (stockRec.getUserId() == null) {
				throw new CommonException("出库柜员为空！");
			} else if (stockRec.getInUserId() == null) {
				throw new CommonException("接收柜员为空！");
			} else if(stockRec.getStkCode()==null){
				throw new CommonException("库存类型为空！");
			}

			log.setDealCode(DealCode.STOCK_TELLER_TRANSITIONMAIN);
			log.setMessage("柜员交接.");
			publicDao.save(log);

			if (!stockRec.getUserId().equals(curUser.getUserId())) {
				throw new CommonException("出库柜员不是当前柜员！");
			}
			Users inUser = (Users) findOnlyRowByHql("from Users where userId = '" + stockRec.getInUserId() + "'");
			if (inUser == null) {
				throw new CommonException("接收柜员不存在！");
			}
			
			// 2.交接
			StringBuffer sb = new StringBuffer();
			sb.append(Tools.processNull(curUser.getBrchId()) + "|");//1.受理点编号
			sb.append(Constants.ACPT_TYPE_GM + "|");//2.受理点类型
			sb.append(Tools.processNull(curUser.getUserId()) + "|");//3.受理柜员编号
			sb.append(log.getDealNo() + "|");//4.流水号
			sb.append(log.getDealCode() + "|");//5.交易代码
			sb.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "|");//6.业务受理时间
			sb.append(stockRec.getBrchId() + "|");//7.出网点
			sb.append(Tools.processNull(curUser.getUserId()) + "|");//8.出库柜员 为操作柜员
			sb.append(Tools.processNull(stockRec.getInBrchId()) + "|");//9.收方网点编号
			sb.append(Tools.processNull(stockRec.getInUserId()) + "|");//10.收方柜员编号
			sb.append(stockRec.getStkCode() + "|");//11.库存类型
			sb.append("|");//12.库存状态
			sb.append(Tools.processNull(log.getMessage()) + "|");//13.备注
			List inParameters = new ArrayList();
			List outParameters = new ArrayList();
			inParameters.add(sb.toString());
			outParameters.add(java.sql.Types.VARCHAR);
			outParameters.add(java.sql.Types.VARCHAR);
			List outList = publicDao.callProc("pk_card_Stock.p_teller_jj", inParameters, outParameters);
			if (outList == null || outList.size() <= 0) {
				throw new CommonException("柜员交接调取过程出现错误！");
			}
			if (Integer.valueOf(outList.get(0).toString()) != 0) {
				throw new CommonException(outList.get(1).toString() + "！");
			}
			
			// 4.业务日志
			TrServRec rec = new TrServRec();
			rec.setDealCode(log.getDealCode());
			rec.setDealNo(log.getDealNo());
			rec.setBrchId(log.getBrchId());
			rec.setUserId(log.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchIdIn(inUser.getBrchId());
			rec.setUserIdIn(stockRec.getInUserId());
			rec.setBrchIdOut(stockRec.getBrchId());
			rec.setUserIdOut(stockRec.getUserId());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setNote(log.getMessage());
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
}
