package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.webservice.server.bean.RequestBean;
import com.erp.webservice.server.bean.ResponseBean;


public interface AutoEquiService extends BaseService {
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
	 * 登录验证与基础信息查询
	 * @param inXml 参数说明详见接口说明文档
	 * @return
	 */
	public String loginValidate(String inXml)throws CommonException;
	/**
	 * 密码判断
	 * @param inXml 参数说明详见接口说明文档
	 * @return
	 */
	public String judgePwd(String inXml)throws CommonException;
	/**
	 * 修改（重置）密码
	 * @param inXml 参数说明详见接口说明文档
	 * @return
	 */
	public String modifyPwd(String inXml)throws CommonException;
	/**
	 * 预挂失
	 * @param inXml 参数说明详见接口说明文档
	 * @return
	 */
	public String reportLoss(String inXml)throws CommonException;
	
	/**
	 * 查询余额
	 * @param inXml 参数说明详见接口说明文档
	 * @return
	 */
	public String queryBal(String inXml)throws CommonException;
	/**
	 * 查询卡状态
	 * @param inXml 参数说明详见接口说明文档
	 * @return
	 */
	public String queryCardState(String inXml)throws CommonException;
	/**
	 * 查询交易详情
	 * @param inXml 参数说明详见接口说明文档
	 * @return
	 */
	public String queryTransDetail(String inXml)throws CommonException;
	/**
	 * 修改圈存限额
	 * @param inXml 参数说明详见接口说明文档
	 * @return
	 */
	public String qcxeedit(String inXml)throws CommonException;
	/**
	 * 银行卡转联机
	 * @param inXml 参数说明详见接口说明文档
	 * @return
	 */
	public String earmarkCharge(String inXml)throws CommonException;

	/**
	 * 联机转联机
	 * @param inXml 参数说明详见接口说明文档
	 * @return CommonException
	 */
	public String ljtoqbCharge(String inXml)throws CommonException;
	/**
	 * 现金充值
	 * @param inXml
	 * @return
	 */
	public String charge(String inXml)throws CommonException;
	/**
	 * 充值确认（确认，冲正）
	 * @param inXml 参数说明详见接口说明文档
	 * @return
	 */
	public String czqrorcz(String inXml)throws CommonException;
	
	/**
	 * 自助设备-现金充值
	 * @param inXml
	 * @return
	 */
	public String chargeAuto(String inXml)throws CommonException;

	
	/**
	 * 申请写卡提示MAC2
	 * @param inXml
	 * @return
	 * @throws CommonException
	 */
	public String checkMac(String inXml)throws CommonException;
}
