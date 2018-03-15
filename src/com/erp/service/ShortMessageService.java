package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.BasePersonal;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.SysSmessages;



public interface ShortMessageService extends BaseService {
	
	/**
	 * 保存短信
	 */
	public void saveSys_Smessages(SysSmessages smessages)throws CommonException;
	
	/**
	 * 公用的插入短信表方法，用于在日常业务方法中调用，目前能考虑到的参数只有这几个，若后面业务扩展，再修改此方法
	 * @param card 用于提取第一卡号、第二卡号，来拼接短信，必填
	 * @param person 用于提取手机号，若该对象为空，会根据card参数的client_id来查询个人信息，
	 * 				若个人信息不存在，或者个人信息的手机号验证不通过（暂只验证是否为空），则不生成该条短信，但同时会记录一条错误日志
	 * @param amt 发生金额
	 * @param actionLog 用来提取交易代码、业务流水号、业务时间、操作员、操作网点等信息
	 * @param smsType 短信类型 01发放02充值03消费04圈存 99自定义短信，若为空，则默认为99
	 * @param content 短信内容，对于复杂的业务可直接将内容拼接后传进来，若此参数不为空，则短信内容以此参数为准
	 * @param flag 标识账户余额变动方向，-1减少，1增加
	 * @param note 短信备注
	 * @param accsubledger 用来提取账户余额信息，对于与账户无关的操作，可以为空
	 */
	public void saveMessage(CardBaseinfo card,BasePersonal person,String amt,SysActionLog actionLog,AccAccountSub accsubledger,String sms_Type,String content,String note,int flag)throws CommonException;
	/**
	 * 提交短信到短信网关，由于是定时检测短信表，因此暂仅支持单条短信发送
	 * @param sms_No 短信ID 
	 * @param ChannelID 发送方标识 
	 * @param SerialID 消息流水号
	 * @param AcptNbr 手机号码
	 * @param NotifyType 业务类型
	 * @param content 发送内容
	 * @param nowTime job时间，也当作是发送时间
	 * @throws CommonException
	 */
	public void saveSendMessage2Gate()throws CommonException;
	
	/**
	 * 短信结果状态报告
	 * @param mid 短信网关的消息id
	 * @param rtn_State 返回状态0为成功，-9001009为失败
	 * @throws CommonException
	 */
	public void saveMessageResultReport(String mid,String rtn_State)throws CommonException;
}
