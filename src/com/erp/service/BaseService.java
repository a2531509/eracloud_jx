/**   
* @Title: BaseService.java TODO:
* @Package com.erp.service
* @Description: TODO
* @author chenguang 
* @date 2013-4-19 下午03:18:05
* @version V1.0   
*/
package com.erp.service;

import java.sql.ResultSet;
import java.util.Date;
import java.util.List;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.CardConfig;
import com.erp.model.SysBranch;
import com.erp.model.PayClrPara;
import com.erp.model.SysActionLog;
import com.erp.model.SysReport;
import com.erp.model.Users;
import com.erp.viewModel.Page;

/**
 * 类功能说明 TODO:
 * 类修改者	修改日期
 * 修改说明
 * <p>Title: BaseService.java</p>
 * <p>Description:福产流通科技</p>
 * <p>Copyright: Copyright (c) 2012</p>
 * <p>Company:福产流通科技</p>
 * @author hujc 631410114@qq.com
 * @date 2013-4-19 下午03:18:05
 * @version V1.0
 */
@SuppressWarnings("rawtypes")
public interface BaseService
{
  
	/**
	 * 通过hibernate的HQL方法来查询返回第一条数据
	 */
	public Object findOnlyRowByHql(String hql) throws CommonException;
	
	/**
	 * 通过SQL方法来查询返回第一条数据
	 */
	public Object findOnlyRowBySql(String hql) throws Exception;
	
	/**
	 * 获取当前操作员
	 */
	public Users  getUser() throws CommonException;
	
	/**
	 * 获取当前session操作员
	 */
	public Users  getSessionUser() throws CommonException;
	/**
	 * 获取当前操作员所属的网点
	 */
	public SysBranch  getSysBranchByUserId() throws CommonException;
	
	/**
	 * 获取当天的清分日期
	 */
	public PayClrPara  getPayClrPara() throws CommonException;
	
	/**
	 * 获取字典参数的名称 按照类型和值 
	 */
	public String  getCodeNameBySYS_CODE(String CodeType,String codeValue) throws CommonException;
	
	/**
	 * 根据卡类型获取卡参数
	 */
	public CardConfig  getCardConfigByCardType(String CardType) throws CommonException;
	
	/**
	 * 根据sequence 名字获取sequence的下一个值
	 * 
	 */
	public String getSequenceByName(String seqName);
	/**
	 * 通过SQL找到某个字段
	 * @param sql
	 * @return
	 * @throws CommonException
	 */
	public Object findOnlyFieldBySql(String sql) throws CommonException;
	
	public List findByHql(String hql) throws CommonException;
	
	public List findBySql(String sql) throws CommonException;
	/** 
	* @Title: findTrCodeNameByCodeType 
	* @Description: TODO:获取指定的值 精确查找
	* @param sql
	* @param @return    设定文件 
	* @return Integer    返回类型 
	* @throws 
	*/
	public String findTrCodeNameByCodeType(Integer codeValue) throws CommonException;
	/**
	 * @Title: getSysConfigurationParameters 
	 * @Description 获取配置文件中的值
	 * @param key  键值对key
	 * @return     键值对value
	 */
	public String getSysConfigurationParameters(String key);
	/**
	 * @Title: getClrDate
	 * @Description 获取当前的清分日期
	 * @return 当前的清分日期
	 */
	public String getClrDate();
	/**
	 * @Title: saveTrServRec
	 * @Description 根据业务流水保存业务日志
	 * @return 
	 */
	public void saveTrServRec(SysActionLog actionLog) throws CommonException;
	
	/**
	 * 保存系统打印报表
	 * @param actionLog   SysActionLog 操作日志
	 * @param jsonObject  JSONObject 报表数据
	 * @param filename    filename 报表路径 + 文件名
	 * @param format      String 报表格式
	 * @param print_Times Long 打印次数
	 * @param return_Url  String 打印后跳转路径 @可设空
	 * @return SysReport 报表对象
	 */
	public SysReport saveSysReport(SysActionLog actionLog,JSONObject jsonObject,String filename,String format,Long print_Times,String return_Url,byte[] pdfContent) throws CommonException;
	/**
	 * 分页查询
	 * @param sql
	 * @param pageNum
	 * @param pageSize
	 * @return
	 * @throws Exception
	 */
	public Page pagingQuery(String sql,Integer page,Integer rows) throws Exception;
	
	/**
	 * 获取数据的时间 格式为 yyyy-MM-dd hh24:mi:ss
	 * @return
	 * @throws CommonException
	 */
	public Date getDateBaseTime() throws CommonException;
	/**
	 * 获取数据的时间 格式为 yyyy-MM-dd
	 * @return
	 * @throws CommonException
	 */
    public Date getDateBaseDate() throws CommonException;
    
    public String getDateBaseDateStr() throws CommonException;
    
    public ResultSet tofindResultSet(String sql)throws CommonException;
    /**
     * 获取当操作的日志信息
     * @return
     * @throws CommonException
     */
    public SysActionLog getCurrentActionLog() throws CommonException;
    
    /**
	 * 判断柜员数据权限
	 * @param branchColumnName
	 * @param operColumn
	 * @return
	 * @throws CommonException
	 */
	public String getLimitQueryData(String branchColumnName,String operColumn) throws CommonException;
	/***
	 * 
	 * @param branchColumnName
	 * @return
	 */
	public String getLimitSysBranchQueryData(String branchColumnName);
	
	/***
	 * 
	 * @param orgClounmName
	 * @return
	 */
	public String getLimitSysOrganQueryData(String orgClounmName);
	/**
	 * 获取机构限制性语句
	 * @param orgIdColumn
	 * @return
	 * @throws CommonException
	 */
	public String getLimitSysOrgQueryData(String orgIdColumn) throws CommonException;
	/**
	 * 根据传入的网点编号和柜员权限获取下级网点 字符串 格式：'123','456','789'
	 * @param branchColumnName
	 * @param operColumn
	 * @return
	 * @throws CommonException
	 */
	public String getNextLimitBrch(String curBrchId) throws CommonException;
	/**
	 * 验证操作员密码
	 * @param operId
	 * @param pwd
	 * @return
	 * @throws CommonException
	 */
	public boolean judgeOperPwd(String operId,String pwd) throws CommonException;
	/**
	 * 获取当前的网点信息
	 * @return
	 * @throws CommonException
	 */
	public SysBranch getSessionSysBranch() throws CommonException;
	/**
	 * 新生成卡号到预生成表中
	 * @param region_code
	 * @param card_Type
	 * @param size
	 * @throws CommonException
	 */
	public void createCard_No(String card_Type,String region_code,int size)throws CommonException;
	/**
	 * 获取卡号
	 * @param region_Id
	 * @param region_Code
	 * @param card_Type
	 * @param action_NO
	 * @param size
	 * @return
	 * @throws CommonException
	 */
	
	public List getCard_No(String region_Id,String region_Code,String card_Type,Long action_NO,int size)throws CommonException;
	/**
	 * 根据证件号码判断该人员是否属于当前的统筹区域
	 * Description <p>TODO</p>
	 * @param certNo  证件号码
	 * @return  true 返回true 验证成功
	 */
	@SuppressWarnings("unchecked")
	public boolean judgeRegion(String certNo) throws CommonException;
	/**
	 * 根据证件号码,网点编号判断是否是同一统筹区域
	 * Description <p>TODO</p>
	 * @param certNo
	 * @param brchId
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public boolean judgeRegion(String certNo,String brchId) throws CommonException;
	
	/**
	 * 获取网点所属统筹区域编号
	 * Description <p>TODO</p>
	 * @return
	 * @throws CommonException
	 */
	public String getBrchRegion() throws CommonException;
	/**
	 * 同步社保信息
	 * @param taskId
	 * @param certNo
	 * @param cardNo1
	 * @param cardNo2
	 * @param dealNo
	 * @param applyType
	 * @throws CommonException
	 */
	public void saveSynch2CardUpate(String taskId,String certNo,String cardNo1,String cardNo2,Long dealNo,String applyType) throws CommonException;
	
	/**
	 * DES加密。
	 * @param data
	 * @param key
	 * @return
	 */
	public String encrypt_des(String data, String key);
	
	/**
	 * DES解密。
	 * @param data
	 * @param key
	 * @return
	 */
	public String decrypt_des(String data, String key);
	
    
}
