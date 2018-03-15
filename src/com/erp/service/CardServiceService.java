package com.erp.service;

import java.util.Map;

import com.erp.exception.CommonException;
import com.erp.model.AccFreezeRec;
import com.erp.model.AccQcqfLimit;
import com.erp.model.BasePersonal;
import com.erp.model.CardAppSyn;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.util.PageUtil;

public interface CardServiceService extends BaseService{
	
	public Long getCount(Map<String, Object> map, PageUtil pageUtil) throws CommonException;
	
	public Long savegs(CardBaseinfo card, TrServRec rec, String lss_Flag,SysActionLog actionLog) throws CommonException;
	/**
	 * 解挂
	 * @param card             待解挂的卡
	 * @param rec              业务操作日志
	 * @return                 业务操作日志
	 * @throws CommonException 
	 */
	public Long saveGj(CardBaseinfo card, TrServRec rec) throws CommonException;
	/**
	 * 注销
	 * @param rec        业务日志
	 * @param card       注销卡
	 * @param isGoodCard 是否好卡
	 * @param cardAmt    卡内余额
	 * @param zxreason   注销原因
	 * @return
	 * @throws Exception 
	 */
	public TrServRec saveZx(Users oper,SysActionLog actionLog,TrServRec rec,CardBaseinfo card,String isGoodCard,String cardAmt,String zxreason) throws CommonException;
	
	/**
	 * 账户返还保存
	 * @param oper      操作员
	 * @param actionLog 操作日志
	 * @param cardNo    账户卡号
	 * @param totalAmt  账户返还总金额
	 * @return          业务日志
	 * @throws CommonException
	 */
	TrServRec saveReturnCash(String cardNo, String bankCardNo, Long totalAmt);
	/**
	 * 补换卡
	 * Description <p>TODO</p>
	 * @param rec   业务日志
	 * @param users 操作员信息
	 * @param log   操作日志信息
	 * @param type  操作类型  0 = 补换  1 = 换卡
	 * @return      业务日志信息
	 * @throws CommonException
	 */
	public TrServRec saveBhk(TrServRec rec,Users users,SysActionLog log,String type) throws CommonException;
	
	public TrServRec saveAppLockHjl(TrServRec rec,Users user,SysActionLog log)throws CommonException;
	
	public TrServRec saveAppLockHjlConfirm(TrServRec rec,Users user)throws CommonException;
	
	public TrServRec saveAppLockHjlCancel(TrServRec rec,Users user,SysActionLog log)throws CommonException;
	public TrServRec saveAppUnlockHjl(TrServRec rec,Users user,SysActionLog log)throws CommonException;
	public TrServRec saveAppUnlockHjlConfirm(TrServRec rec,Users user)throws CommonException;
	public TrServRec saveAppUnlockHjlCancel(TrServRec rec,Users user,SysActionLog log)throws CommonException;
	/**
	 * 换卡转钱包写灰记录
	 * @param rec  业务日志信息
	 * @param oper 操作员
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveBhkZzTjHjl(TrServRec rec,Users oper) throws CommonException;
    /**
     * 换卡转钱包写灰记录(新)
     * @param rec   业务日志信息
     * @param oper  操作员
     * @param log   操作日志
     * @return
     * @throws CommonException
     */
    public TrServRec saveBhkZzTjHjl2(TrServRec rec,Users oper) throws CommonException;
	
	/**
	 * --补换卡转钱包灰记录确认
	 * --1.受理点编号/网点编号
	 * --2.受理点类型   1 柜面  2 代理
	 * --3.受理点终端编号/操作员
	 * --4.终端操作流水 受理点类型为 1的时候可为空
	 * --5.确认流水号
	 * --6.清分日期
	 * @param inParameters
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveBhkZzTjConfirm(Map inParameters) throws CommonException;
	
	/**
	 * 补换卡转钱包灰记录冲正
	 * @param oldDealNo 原始流水号
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveBhkZzTjCz(Long oldDealNo) throws CommonException;
	
	/**
	 * 服务密码或交易码输入错误次数超限解锁
	 * @param actionLog
	 * @param dealType
	 * @param certNo
	 * @param cardNo
	 * @throws CommonException
	 */
	public void saveundoServPwdorTradePwd(SysActionLog actionLog,String dealType,String certNo,String cardNo) throws CommonException;
   /**
    * 修改卡片有效日期
    * @param actionLog
    * @param vdate
    * @param cardNo
    * @throws CommonException
    */
	public void saveCardDate(SysActionLog actionLog,String vdate,String cardNo) throws CommonException;
	/**
	 * 公交子类型修改记灰记录
	 * @param tarBusType  目标公交子类型
	 * @param validDate   新的应用有效期
	 * @param card        卡片信息
	 * @param bp          人员信息
	 * @param oper        操作员信息
	 * @param log         操作日志信息
	 * @return            业务日志信息
	 * @throws CommonException
	 */
	public TrServRec saveBusTypeModifyHjl(String tarBusType,String validDate,CardBaseinfo card,BasePersonal bp,Users oper,SysActionLog log) throws CommonException;
	/**
	 * 公交子类型修改灰记录确认
	 * Description <p>TODO</p>
	 * @param dealNo  原流水 
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveBusTypeModifyConfirm(Long dealNo)throws CommonException;
	/**
	 * 公交子类型修改灰记录取消
	 * Description <p>TODO</p>
	 * @param dealNo 原流水
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveBusTypeModifyCancel(Long dealNo)throws CommonException;

	/**
	 * 余额返现确认
	 * @param dealNo
	 */
	public void saveConfirmReturnCash(Long dealNo);

	public void saveAccQcLimitInfo(AccQcqfLimit limit, SysActionLog log);

	public void saveBhkzzRegister(String cardNo, SysActionLog log);

	public TrServRec saveBhkZzBadCardHjl(TrServRec rec, Users user);

	public void saveCancelReturnCash(Long dealNo);

    /**
     * 保存非个性化卡销售
     * @param inpara
     * saleCardNo 销售卡号
     * saleCostFee 销售工本费
     * saleForegiftfee 销售押金
     * saleManager 客户经理
     * corpId 销售单位编号
     * corpName 销售单位名称
     * note 备注
     * @param log
     * @param oper
     * @return
     * @throws CommonException
     */
    public TrServRec saveFjmkSell(Map inpara,TrServRec rec,SysActionLog log,Users oper) throws CommonException;

	public TrServRec saveFjmkHk(TrServRec rec, Users user, SysActionLog currentActionLog);

    /**
     * 写卡应用开通,写卡前条件判断
     * @param inpara
     * @param oper
     * @param rec
     * @param log
     * @return
     * @throws CommonException
     */
    public TrServRec saveCardAppOpenOrCloseHjl(Map<String,String> inpara, Users oper, TrServRec rec,SysActionLog log) throws CommonException;

    /**
     * 写卡失败后,撤销预开通记录
     * @param dealNo
     * @throws CommonException
     */
    public void saveCardAppOpenOrCloseHjlCancel(long dealNo,String type,String ywlx) throws CommonException;


    /**
     * 应用开通灰记录确认
     * @param dealNo 确认流水
     * @param type 确认类型 0 自动确认 1 手工确认
     * @throws CommonException
     */
    public void saveCardAppOpenOrCloseHjlConfirm(long dealNo,String type,String ywlx) throws CommonException;

	/**
	 * 卡应用开通
	 * @param inpara 参数信息
	 * @param oper 操作员
	 * @param rec 业务日志
	 * @param log 操作日志
	 * @return 业务日志
	 */
	public TrServRec saveCardAppOpenOrClose(Map inpara, Users oper, TrServRec rec,SysActionLog log) throws CommonException;
	
	
	/**
	 * 自行车应用开通
	 * @param inpara 参数信息
	 * @param oper 操作员
	 * @param rec 业务日志
	 * @param log 操作日志
	 * @return 业务日志
	 */
	public CardAppSyn saveZXCAppOpenOrClose(Map inpara, Users oper, TrServRec rec,SysActionLog log) throws CommonException;
	public void saveZXCAppReportOrLoss(TrServRec rec,Long dealNo) throws CommonException;
}
