package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.webservice.server.bean.RequestBean;
import com.erp.webservice.server.bean.ResponseBean;

public interface NetAppOfSbService extends BaseService {
	/**
	 * 根据单位编号，返回该单位人员的制卡情况
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String savequeryyzk(String inXml) throws CommonException;
	
	/**
	 * 根据单位编号，返回该单位人员的制卡情况
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String savequerywzk(String inXml) throws CommonException;
	
	/**
	 * 更新保存个人照片
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String updateapplyphoto(String inXml) throws CommonException;
	
	/**
	 * 更新个人的确认标志
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String updatesureFlag(String inXml) throws CommonException;
	
	/**
	 * 保存网上申报数据录入卡管系统数据库
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String saveapplyinfo(String inXml) throws CommonException;
	
	/**
	 * 组装返回值的xml字符串
	 * @param resBean 返回对象bean
	 * @param methodName 调用方法名
	 * @param isActionLog 是否记录actionlog
	 * @param reqBean 入口参数bean
	 * @return xml
	 * @throws CommonException
	 */
	public String createReturnXml(ResponseBean resBean, String methodName,boolean isActionLog,RequestBean reqBean) throws CommonException;
	/**
	 * -撤销申报
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String savechexiaoapply(String inXml) throws CommonException ;
	/**
	 * -查询统计
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String savetongjiquery(String inXml) throws CommonException ;
	/**
	 * -打印领卡单
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String savelingkadan(String inXml) throws CommonException ;
	
	/**
	 * 1009查询单位经办人
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String saveQueryEmp(String inXml) throws CommonException ;
	
	/**
	 * 1010导出单位勘误数据
	 * @param inXml
	 * @return
	 */
	String expPersonErrata(String inXml);

	/**
	 * 1011导入单位申领人员数据
	 * @param inXml
	 * @return
	 */
	public String impCorpNetAppData(String inXml);

	/**
	 * 1012下载单位申领人员数据
	 * @param inXml
	 * @return
	 */
	public String getCorpNetAppData(String inXml);

	/**
	 * 2001获取照片
	 * @param inXml
	 * @return
	 */
	public String getPersonPhoto(String inXml);

	/**
	 * 2001获取银行卡信息
	 * @param inXml
	 * @return
	 */
	public String getBankCardInfo(String inXml);
	
}
