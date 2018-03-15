package com.erp.service;

import java.util.Map;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;

public interface PwdService extends BaseService {
	/**
	 * 个人服务密码修改或是重置
	 * @param customerId 客户编号
	 * @param pwd        客户新密码
	 * @param rec        业务日志信息
	 * @param type       保存类型 0 服务密码修改   1  服务密码重置
	 * @return
	 * @throws CommonException
	 */
	public Long saveServicePwdModify(Long customerId,String pwd,TrServRec rec,int type) throws CommonException;
	/**
	 * <p>校验个人用户的服务密码</p>
	 * @param customerId 用户customerId
	 * @param pwd 用户密码
	 * @return 校验是否成功
	 */
	public Map<String,String> judgeCustomerServicePwd(Long customerId,String pwd)throws CommonException;
	
	/**
	 * 联机账户服务密码重置 
	 * @param para JSONObject 参数信息  para.cardNo 卡号,para.pwd 密码
	 * @param oper Users 操作柜员
	 * @param log SysActionLog 操作日志
	 * @return TrServRec 业务日志
	 * @throws CommonException
	 */
	public TrServRec savePayPwdReset(JSONObject para,Users oper,SysActionLog log) throws CommonException;
	/**
	 * 联机账户服务密码修改
	 * @param para JSONObject 参数信息  para.cardNo 卡号,para.pwd 密码,para.oldPwd 旧密码
	 * @param oper Users 操作柜员
	 * @param log SysActionLog 操作日志
	 * @return TrServRec 业务日志
	 * @throws CommonException
	 */
	public TrServRec savePayPwdModify(JSONObject para,Users oper,SysActionLog log) throws CommonException;
	
	/**
	 * 添加社保密码
	 * @param cardNo     卡号
	 * @param pwd        客户新密码
	 * @param rec        业务日志信息
	 * @return
	 * @throws CommonException
	 */
	public Long saveSbPwd(String cardNo,String pwd,TrServRec rec) throws CommonException;
	
	/**
	 * 社保密码重置 
	 * @param para JSONObject 参数信息  para.cardNo 卡号,para.pwd 密码
	 * @param oper Users 操作柜员
	 * @param log SysActionLog 操作日志
	 * @return TrServRec 业务日志
	 * @throws CommonException
	 */
	public TrServRec sbPwdReset(JSONObject para,Users oper,SysActionLog log) throws CommonException;
	
	/**
	 * 服务密码输入错误次数重置 
	 * @param oper Users 操作柜员
	 * @param log SysActionLog 操作日志
	 * @return TrServRec 业务日志
	 * @throws CommonException
	 */
	public TrServRec servpwdErrTimeReset(String certNo,Users oper,SysActionLog log) throws CommonException;
	
	/**
	 * 交易密码输入错误次数重置 
	 * @param oper Users 操作柜员
	 * @param log SysActionLog 操作日志
	 * @return TrServRec 业务日志
	 * @throws CommonException
	 */
	public TrServRec dealpwdErrTimeReset(String cardNo,Users oper,SysActionLog log) throws CommonException;
	
	
}
