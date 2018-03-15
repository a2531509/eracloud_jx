package com.erp.serviceImpl;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.BasePersonal;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.SysErrLog;
import com.erp.model.SysSmessages;
import com.erp.model.SysSmessagesPara;
import com.erp.service.ShortMessageService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.Tools;

@Service(value="shortMessageService")
public class ShortMessageServiceImpl extends BaseServiceImpl implements ShortMessageService{
	private static Log log = LogFactory.getLog(ShortMessageServiceImpl.class.getName());
	@Override
	public void saveSys_Smessages(SysSmessages smessages)throws CommonException {
		try {
			if(smessages==null){
				throw new CommonException("短信实体不能为空！");
			}
			if(Tools.processNull(smessages.getMobileNo()).equals("")||Tools.processNull(smessages.getContent()).equals("")){
				throw new CommonException("短信手机号码或内容不能为空！");
			}
			if(Tools.processNull(smessages.getMobileNo()).length()!=11){
				throw new CommonException("短信手机号码长度不正确！");
			}

			SysSmessagesPara smessagesPara = (SysSmessagesPara)getSys_Smessages_ParaByTrCode(smessages.getDealCode());
			if(!Tools.processNull(smessages.getDealCode()).equals("")&&smessagesPara!=null){
				if(smessagesPara.getIsfixed().equals("0")){
					smessages.setContent(smessagesPara.getContent());
				}
			}
			if(smessages.getCreateTime()==null){
				smessages.setCreateTime(DateUtil.formatDate(this.getDateBaseTime(),"yyyy-MM-dd HH:mm:ss"));
			}
			publicDao.save(smessages);
		} catch (Exception ex) {
			throw new CommonException(ex);
		}
		
	}
	
	public SysSmessagesPara getSys_Smessages_ParaByTrCode(Integer dealcode){
		SysSmessagesPara para=null;
		List smessagesParaList=this.findByHql("from Sys_Smessages_Para p where p.state='0' ");
		if(Tools.processNull(dealcode).equals(""))return null;
		for(int i=0;i<smessagesParaList.size();i++){
			para = (SysSmessagesPara)smessagesParaList.get(i);
			if(para.getDealCode()==dealcode){
				return para;
			}
		}
		return null;
	}

	@Override
	public void saveMessage(CardBaseinfo card, BasePersonal person, String amt,SysActionLog actionLog, AccAccountSub accsubledger,String sms_Type, String content, String note, int flag)
			throws CommonException {
		try {
			if(actionLog==null){
				throw new CommonException("actionLog不能为空！");
			}
			if(actionLog.getDealCode()==null){
				throw new CommonException("交易代码信息不能为空！");
			}

			// 根据交易代码查询短信对应的短信参数配置信息，只有配置表中存在对应的交易代码记录时，才会进行下面的操作
			SysSmessagesPara smspara=(SysSmessagesPara)this.findOnlyRowByHql("from Sys_Smessages_Para s where dealCode="+actionLog.getDealCode());
			if(smspara!=null && "0".equals(smspara.getState())){
				//验证个人信息
				if(person==null){
					if(Tools.processNull(card.getCustomerId()).equals("")){
						person=null ;//对于非记名的卡转账业务，不存在客户信息
					}else {
						person=(BasePersonal)this.findOnlyRowByHql("from BasePersonal b where b.customerId='"+card.getCustomerId()+"'");
					}
				}
				if(person==null || Tools.processNull(person.getMobileNo()).equals("")){
					//若个人信息不存在，或者个人信息的手机号验证不通过（暂只验证是否为空），则不生成该条短信，但同时会记录一条错误日志
					SysErrLog errlog = new SysErrLog();
					errlog.setUserId(actionLog.getUserId());
					errlog.setErrTime(new Timestamp(actionLog.getDealTime().getTime()));
					errlog.setMessage("业务流水号为："+actionLog.getDealNo()+"的业务，未成功生成短信，客户信息不存在，或手机号信息不正确！");
					errlog.setIp("");
					errlog.setErrType("0");
					publicDao.save(errlog);
					return ;
				}
				
				//根据短信参数配置信息生成短信
				SysSmessages smessage=new SysSmessages();
				smessage.setDealNo(actionLog.getDealNo());//业务流水号：关联业务表记录
				smessage.setCardNo(card==null?"":card.getCardNo());//卡号
				smessage.setCustomerId(person.getCustomerId()+"");//客户编号：关联客户信息
				smessage.setMobileNo(person.getMobileNo());//电话号码：取自bs_person.MOBILE_NO手机号码或调用者传入
				smessage.setUserId(actionLog.getUserId());//柜员编号
				smessage.setSmsType(Tools.processNull(sms_Type).equals("")?"99":sms_Type);//短信类型 01发放02充值03消费04圈存 99自定义短信
				smessage.setCreateTime(DateUtil.formatDate(actionLog.getDealTime(),"yyyy-MM-dd HH:mm:ss"));//短信生成时间：默认数据库系统时间
				smessage.setDealCode(actionLog.getDealCode());
				smessage.setSmsState("0");//短信状态 0未发送 1已发送 2发送成功 3发送失败
				smessage.setNote(note);//备注
				//短信内容
				if(!Tools.processNull(content).equals("")){//若已有短信内容
					smessage.setContent(content);
			    }else {//根据参数拼接短信内容
					if("0".equals(smspara.getIsfixed())){//若是固定短语
						smessage.setContent(smspara.getContent());
					}else {//按不同城市、不同交易代码组装不同短信内容
						String datestr=DateUtil.formatDate(actionLog.getDealTime(),"yyyy年MM月dd日");
						if(smspara.getDealCode()==DealCode.CARD_LOSS){//预挂失
							String zdjgsj=super.getSysParaByParaCode("zdjgsj").getParaValue();
							smessage.setContent("尊敬的用户，您的市民卡已成功"+super.getCodeNameBySYS_CODE("LSS_FLAG","1")+"，系统将在"+zdjgsj+"日后自动解挂，请您在"+zdjgsj+"日内到市民一卡通服务中心办理书面挂失。[银川一卡通服务中心]");
						} else if (smspara.getDealCode() == 30101010 || smspara.getDealCode()== 30101020	||  smspara.getDealCode()== 30105010|| smspara.getDealCode() == 30301020 ||smspara.getDealCode() == 30301010) {// 所有充值、圈存、转账、车改单位批量充值相关的交易代码
							if(amt!=null){
								amt=Arith.cardreportsmoneydiv(amt);//发生金额
							}
							String accKindName="";//账户类型名称
							//对于柜面消费、资金账户圈提，卡账户余额减少
							accKindName=super.getCodeNameBySYS_CODE("ACC_KIND", accsubledger.getAccKind());
							if(accsubledger.getAccKind().equals("01")){//钱包账户还要分普通还是月票
								accKindName=super.getCodeNameBySYS_CODE("MONEYBAG_TYPE", accsubledger.getWalletNo())+accKindName;
							}
							smessage.setContent("尊敬的用户，您的一卡通卡（尾号为"+card.getCardNo().substring(card.getCardNo().length()-6,card.getCardNo().length())+"）"+accKindName+datestr+(flag==1?"增加":"减少") + amt	 + "元。[银川一卡通服务中心]");
							
						}else {
							throw new CommonException("该业务对应的短信功能待完善！");
						}
					}
				}
				publicDao.save(smessage);
			}
		} catch (Exception e) {
			throw new CommonException("生成短信失败！"+e.getMessage());
		}
		
	}
	
	
	/**
	 * 嘉兴短信，本类调用
	 */
	private String saveSendMessage_Jiaxing(String sms_No, String ChannelID,String SerialID,String AcptNbr, String NotifyType,String content,Date nowTime)throws CommonException{
		return null;
		
	}	
	/**
	 * 短信结果状态报告，在action中作为服务给短信网关调用
	 * @param mid 短信网关的消息id
	 * @param rtn_State 返回状态0为成功，-9001009为失败
	 * @throws CommonException
	 */

	public void saveMessageResultReport(String mid, String rtn_State) throws CommonException {
		try {
			String sms_State=Constants.SMS_STATE_CG;//默认成功
			if(!Constants.YES_NO_YES.equals(rtn_State))
				sms_State=Constants.SMS_STATE_SB;//返回状态不为0时，表示失败
			int i=publicDao.doSql("update sys_smessages set  sms_state='"+sms_State+"',rtn_state='"+rtn_State+"', where mid='"+mid+"'");
		} catch (Exception e) {
			throw new CommonException("更新短信结果状态失败！mid="+mid +" 原因："+e.toString());
		}
		
	}

	public void saveSendMessage2Gate() throws CommonException {
		try {
			Date nowTime=publicDao.getDateBaseTime();//把时间传入，保证每次job的发送时间一致
			List list=this.findBySql("select * from (select sms_no,mobile_no,content from sys_smessages where SMS_STATE='"+Constants.SMS_STATE_WFS+"' order by CREATE_TIME )where rownum <21");//每次取一定条数
			if(list!=null && list.size()>0){
				for(int i=0;i<list.size();i++){
					Object[]objs=(Object[])list.get(i);
					//((BigDecimal)publicDao.findOnlyFieldBySql("select SEQ_CALL_MESSAGE.nextval from dual")).longValue();
					String seq=this.getSequenceByName("SEQ_CALL_MESSAGE");
					try {
						this.saveSendMessage_Jiaxing(Tools.processNull(objs[0]),"101","DXJK1000000001"+seq,Tools.processNull(objs[1]),"1000000001",Tools.processNull(objs[2]),nowTime);
					} catch (Exception e) {
						SysErrLog errlog = new SysErrLog();
						errlog.setUserId("admin");
						errlog.setErrTime(new Timestamp(nowTime.getTime()));
						errlog.setMessage(e.getMessage().replaceAll("\r\n", " ").replaceAll("\n", " "). replaceAll("\'", "’"));//替换回车、换行、单引号等符号
						errlog.setMessage(errlog.getMessage().length()>1000?errlog.getMessage().substring(0,1000):errlog.getMessage());
						errlog.setErrType("0");
						//检查错误日志中若存在相同记录，则仅更新时间，不插入新记录
						SysErrLog err = (SysErrLog) this.findOnlyRowByHql("from SysErrLog where userId='" + errlog.getUserId()
								+ "' and message='" + errlog.getMessage() + "'");
						if(err!=null){
							err.setErrTime(errlog.getErrTime());
							publicDao.update(err);
						}else
							publicDao.save(errlog);
					}
				}
			}
		} catch (Exception e) {
			log.error(e.getMessage());
		}
		
	}
	


}
