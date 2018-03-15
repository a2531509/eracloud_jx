package com.erp.service;

import java.io.File;
import java.util.List;

import com.erp.exception.CommonException;
import com.erp.model.CardApplyTask;
import com.erp.model.CardBaseinfo;
import com.erp.model.StockAcc;
import com.erp.model.StockRec;
import com.erp.model.StockType;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;



public interface StockService extends BaseService {
	/**
	 * 库存账开户开户
	 * @param acc
	 * @param oper
	 * @param log
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveStockAccOpen(StockAcc acc,Users oper,SysActionLog log) throws CommonException;
	/**
	 * 库存配送保存
	 * @param stockRec 库存配送日志信息
	 * @param stockDeliveryWay 库存配送方式
	 * @param oper 操作员
	 * @param log 操作日志
	 * @return
	 */
	public TrServRec saveStockDelivery(StockRec stockRec,String stockDeliveryWay,Users oper,SysActionLog log) throws CommonException;
	/**
	 * 
	 * @param stockDealNo
	 * @param oper
	 * @param log
	 * @throws CommonException
	 */
	public void saveStockDeliveryConfirm(String stockDealNo,Users oper,SysActionLog log) throws CommonException;
	
	/**
	 * 库存配送取消
	 * @param stkDealNos  库存配送流水号
	 * @param oper 操作员
	 * @param log  操作日志
	 * @return     业务日志
	 * @throws CommonException
	 */
	public TrServRec saveStockDeliveryCancel(String stkDealNos,Users oper,SysActionLog log) throws CommonException;
	
	/**
	 * 柜员领用
	 * @param stockRec 库存流水
	 * @param oper     操作员
	 * @param log      操作日志
	 * @return         业务日志
	 */
	public TrServRec saveTellerReceive(StockRec stockRec,String stockDeliveryWay,Users oper,SysActionLog log) throws CommonException;
	
	/**
	 * 柜员交接
	 * @param stockRec 库存流水
	 * @param oper     操作员
	 * @param log      操作日志
	 * @return         业务日志
	 */
	public TrServRec saveTellerTransitionMain(StockRec stockRec,String stockDeliveryWay,Users oper,SysActionLog log) throws CommonException;
	
	/**
	 * 新版卡发放,个人发放，规模发放
	 * @param card_no  个人发放时传入卡号
	 * @param task_id  规模发放时传入任务编号
	 * @param log 操作日志
	 */
	public void saveCardRelease(String card_no,String task_id,SysActionLog log) throws CommonException;
	/**
	 * 制卡导入,读取文件,将数据存到临时表中,判断成功再导入正式表
	 * @param userId 当前操作员
	 * @param file 导入的文件
	 * @return
	 * @throws CommonException
	 */
	public String readFileToTable(String userId, File file) throws CommonException;
	/**
	 * 制卡导入,读取文件,将数据存到临时表中,判断成功再导入正式表
	 * @param userId 当前操作员
	 * @param file 导入的文件
	 * @return
	 * @throws CommonException
	 */
	public String readFileToTable(String userId, String fileStr) throws CommonException;
	/**
	 * 保存个人发放/规模发放
	 * @param stk_Code 库存代码
	 * @param card 个人发放
	 * @param task 规模发放
	 * @param log
	 * @throws CommonException
	 */
	public void saveCardRelease(CardBaseinfo card,CardApplyTask task,SysActionLog sysActionLog) throws CommonException ;
	/**
	 * 撤销卡销售
	 * @param dealNo 被撤销的业务流水号
	 * @param log 当前日志对象
	 */
	public void saveSaleCard_Cancel(Long dealNo, String userId) throws CommonException ;
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
	public void saveOpenBatch(String stk_Code,String start_No, String end_No,int size,String coustomerId,SysActionLog actionLog) throws CommonException;
	/**
	 * 保存补换卡
	 * @param oldcard 如果为null，表示补卡（没有老卡）
	 * @param newcard 如果为null，表示后续制卡（没有新卡）
	 * @param actionLog 日志对象
	 * @throws CommonException
	 */
	public void saveExchangeCard(CardBaseinfo oldcard,CardBaseinfo newcard,SysActionLog actionLog) throws CommonException;
	/**
	 * 撤销补卡、换卡
	 * @param action_No 被撤销的业务流水号
	 * @param log 当前日志对象
	 * @throws CommonException
	 */
	public void saveChangeCard_Cancel(Long dealNo, String userId)throws CommonException;
	/**
	 * 白卡零星制卡，出库入库
	 */
	public void saveInOutStock(CardBaseinfo card,String customerId,SysActionLog actionLog)throws CommonException;
	/**
	 * 非记名卡退卡
	 * @param oldRec 老的综合业务日志
	 * @param actionLog 操作日志对象
	 * @throws CommonException
	 */
	public void savelFjmkTk(TrServRec oldRec,SysActionLog actionLog,Users oper)throws CommonException;
	/**
	 * Official Import Database
	 * @param isname 是否有申领信息，是否记名
	 * @param make_Batch_Id 制卡批次号
	 * @param pch 导入批次号
	 * @param make_Way 制卡方式
	 * @param oper 当前操作员
	 * @param actionLog 业务日志对象
	 * @param totalcount 总的任务明细数量
	 */
	public void importtasklist(boolean isname,String make_Batch_Id,String pch,String make_Way,String cardType,Users oper,SysActionLog actionLog,int totalcount)throws CommonException;
	/**
	 * 保存配送确认
	 * @param rec
	 * @param action_no
	 * @throws CommonException
	 */
	public void saveBranchAccept(StockRec rec,String[] dealnos) throws CommonException;
	
	/**
	 * 柜员领用
	 * @param rec
	 * @param pwd
	 * @return
	 * @throws CommonException
	 */
	public List saveUserDownStock(StockRec rec,String pwd,String send_Type) throws CommonException;
	/**
	 * 柜员上交
	 * @param rec
	 * @param pwd
	 * @return
	 * @throws CommonException
	 */
	public long saveUserUpStock(StockRec rec,String pwd) throws CommonException;
	/**
	 * 库存类型新增或是编辑保存
	 * @param stockType
	 * @param user
	 * @param actionLog
	 * @param type
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveOrUpdateStockType(StockType stockType,Users user,SysActionLog actionLog,String type) throws CommonException;
	public void saveTellerTransitionAll(StockRec rec, Users user, SysActionLog currentActionLog);
}
