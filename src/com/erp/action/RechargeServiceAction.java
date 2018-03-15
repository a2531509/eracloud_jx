package com.erp.action;

import java.io.File;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.DataFormat;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.shiro.SecurityUtils;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardRecharge;
import com.erp.model.TrServRec;
import com.erp.service.RechargeService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.Page;
@Namespace("/recharge")
@Action("rechargeAction")
@InterceptorRefs({@InterceptorRef("jsondefalut")})
@SuppressWarnings("serial")
public class RechargeServiceAction extends BaseAction {
	private static Logger logger = Logger.getLogger(RechargeServiceAction.class);
	private boolean isDebug = false;
	@Resource(name="rechargeService")
	private RechargeService recharge;
	private TrServRec rec;//综合业务日志
	private String cardNo;//充值卡号
	private String amt = "0";//充值金额
	private String cardAmt;//充值前卡内余额
	private String card_Recharge_TrCount;//卡片充值计数器
	private String card_Recharge_TrCount2;
	private String paySource = "0";//资金来源,现金或是转账
	private String trCode;//交易码
	private String rechargeCardNo;//充值卡卡号(刮刮卡卡号)
	private String rechargeCardPwd;//充值卡密码(刮刮卡密码)
	private Long dealNo;//流水号
	private String certType;
	private String certNo;
	private String cardType;
	private String sort;
	private String order;
	private String queryType = "1";
	private String outCardNo;//转账相关 转出卡号
	private String outAccBal = "0";//转账相关 转出账户金额
	private String inCardNo;//转账相关   转入卡号
	private String inAccBal = "0";//转账相关  转入账户
	private String pwd;
	private String zgOperId;//授权业务,授权网点主管ID
	private String beginTime;
	private String endTime;
	private String branchId;
	private String operId;
	private Boolean isHkZzGoodCard = false;
	private String state;
	private File file;
	/**
	 * 》》钱包充值写灰记录
	 * @return
	 */
	public String _saveHjlWallet(){
		jsonObject.put("status",1);
		jsonObject.put("msg","");
		try{
			Map<String,Object> map = new HashMap<String,Object>();
			map.put("cardNo",Tools.processNull(cardNo));
			map.put("userId",recharge.getUser().getUserId());
			map.put("amt",Arith.cardmoneymun(amt));//充值金额
			map.put("cardAmt",Arith.cardmoneymun(cardAmt));//充值前卡内余额
			map.put("cardTrCount",Tools.processNull(card_Recharge_TrCount));//交易计数器
			map.put("paySource",(Tools.processNull(paySource).equals("") ? "0" : paySource));//充值资金来源0现金1转账/银行卡2充值卡3促销4更改信用额度5网点预存款
			map.put("rechargeCardNo","");//充值卡卡号
			map.put("rechargeCardPwd","");//充值卡密码
			map.put("actionlog",baseService.getCurrentActionLog());
			rec = recharge.saveHjlWallet(map,DealCode.RECHARGE_CASH_WALLET);
			String camt = String.format("%010d",Long.valueOf(Arith.cardmoneymun(amt)));
			String ctime = DateUtil.formatDate(rec.getBizTime(),"yyyyMMddHHmmss");
			jsonObject.put("dealNo",rec.getDealNo());
			jsonObject.put("status","0");
			jsonObject.put("writecarddata",camt + ctime + "123456");//写卡字符串
		} catch (Exception e){
			jsonObject.put("msg",Constants.ACC_KIND_NAME_QB + "充值发生错误：" + e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return "jsonObj";
	}
	/**
	 * 》》钱包账户现金充值灰记录确认
	 * @return
	 */
	public String saveWalletConfirm(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo",dealNo);
		try{
			Map<String,Object> map = new HashMap<String, Object>();
			map.put("dealNo",dealNo);
			map.put("userId",recharge.getUser().getUserId());
			map.put("actionlog",baseService.getCurrentActionLog());
			recharge.saveWalletAshConfirm(map);
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return "jsonObj";
	}
	/**
	 * 》》钱包账户现金充值灰记录冲正
	 * @return
	 */
	public String saveWalletCancel(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			Map<String,Object> map = new HashMap<String, Object>();
			map.put("dealNo",dealNo);
			map.put("userId",recharge.getUser().getUserId());
			map.put("actionlog",baseService.getCurrentActionLog());
			recharge.saveWalletAshCancel(map);
			jsonObject.put("status","0");
		} catch (Exception e) {
			jsonObject.put("msg",e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return "jsonObj";
	}
	/**
	 * 》》钱包账户现金充值撤销,查询
	 * @return
	 */
	public String offlineAccRechargeQuery(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		try{
			if(this.queryType.equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select t.deal_no,t.customer_id,t.acc_name,t.card_no,");
				sb.append("(select d.code_name from sys_code d where d.code_type = 'CARD_TYPE' and d.code_value = t.card_type) cardType,");
				sb.append("t.acc_no,");
				sb.append("(select d.code_name from sys_code d where d.code_type = 'ACC_KIND' and d.code_value = t.acc_kind) accKind,");
				sb.append("trim(to_char(nvl(t.card_bal,0)/100,'999,990.99')) accBal,");
				sb.append("trim(to_char(nvl(t.amt,0)/100,'999,990.99')) amt,to_char(t.deal_date,'yyyy-mm-dd hh24:mi:ss') dealDate,");
				sb.append("decode(t.deal_state,'0','正常','1','撤销','冲正','其他') dealState,t.clr_date,b.full_name,a.name ");
				sb.append("from PAY_CARD_DEAL_REC_" + recharge.getClrDate().substring(0,7).replaceAll("-",""));
				sb.append(" t left join sys_users a on t.user_id = a.user_id left join sys_branch b on a.brch_id = b.brch_id ");
				sb.append("left join base_personal p on t.customer_Id = p.customer_id ");
				sb.append("where t.deal_state = '0' and t.deal_code = '" + DealCode.RECHARGE_CASH_WALLET + "' and t.user_id = '" 
						+ baseService.getUser().getUserId() + "' ");
				if(!Tools.processNull(this.certType).equals("")){
					sb.append("and p.cert_type = '" + this.certType + "' ");
				}
				if(!Tools.processNull(this.certNo).equals("")){
					sb.append("and p.cert_no = '" + this.certNo + "' ");
				}
				/*if(!Tools.processNull(this.cardType).equals("")){
					sb.append("and t.card_type = '" + this.cardType + "' ");
				}*/
				if(!Tools.processNull(this.cardNo).equals("")){
					sb.append("and t.card_no = '" + this.cardNo + "' ");
				}
				if(Tools.processNull(this.sort).equals("")){
					sb.append("order by t.deal_no desc");
				}else{
					sb.append("order by " + sort + " " +  order);
				}
				Page list = recharge.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("未查询到正常的" + Constants.ACC_KIND_NAME_QB + "充值记录或充值记录不是该柜员操作，不能进行撤销。<br/><span style='color:red'>提示:请查询该卡是否存在未确认的灰记录，或已冲正的记录</span>");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》钱包账户充值撤销(写灰记录)
	 * @return
	 */
	public String saveOfflineAccRechargeCancel(){
		try{
			if(zgOperId.equals(getUsers().getUserId())){
				throw new CommonException("授权柜员不能是当前柜员");
			}
			baseService.judgeOperPwd(this.zgOperId, pwd);
			Map<String,Object> map = new HashMap<String, Object>();
			map.put("userId",baseService.getUser().getUserId());
			map.put("dealNo",this.dealNo);
			map.put("cardTrCount",this.card_Recharge_TrCount);//当前卡钱包账户充值序列号
			map.put("cardAmt",Arith.cardmoneymun(this.cardAmt));//当前卡内余额
			map.put("actionlog",baseService.getCurrentActionLog());
			map.put("zgOperId",zgOperId);
			trCode = String.valueOf(DealCode.RECHARGE_CASH_WALLET_REV);
			if(Integer.parseInt(this.trCode) == DealCode.RECHARGE_ACC_WALLET//联机→钱包
					||Integer.parseInt(this.trCode) == DealCode.RECHARGE_NORECHARGE_WALLET//待圈存账户→钱包
					||Integer.parseInt(this.trCode) == DealCode.TRM_CHARGE_SPECACC2WALLET//终端_未圈存账户→钱包
					||Integer.parseInt(this.trCode) == DealCode.TRM_CHARGE_ACC2WALLET){//终端_联机→钱包
					//action_No = recharge.saveTransferRevoke(map,Integer.parseInt(trCode));
			}else{
				rec = recharge.saveAccRechargeRevoke(map,DealCode.RECHARGE_CASH_WALLET_REV);
			}
			String camt = String.format("%010d",Math.abs(rec.getAmt()));//10个数字，单位到分
			String ctime = DateUtil.formatDate(rec.getBizTime(),"yyyyMMddHHmmss");//YYYYMMDDHHMMSS
			jsonObject.put("writecarddata",camt + ctime);
			jsonObject.put("status","0");
			jsonObject.put("dealNo", rec.getDealNo());
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status","1");
			jsonObject.put("msg",Constants.ACC_KIND_NAME_QB + "充值撤销发生错误：" +  e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 钱包账户充值撤销灰记录（确认）
	 * @return
	 */
	public String saveOfflineAccRechargeCancelConfirm(){
		try{
			Map<String,Object> map = new HashMap<String, Object>();
			map.put("dealNo",this.dealNo);
			map.put("userId",baseService.getUser().getUserId());
			map.put("actionlog",baseService.getCurrentActionLog());
			trCode = "0";
			if(Integer.parseInt(this.trCode) == DealCode.RECHARGE_ACC_WALLET////联机→钱包
					||Integer.parseInt(trCode)==DealCode.RECHARGE_NORECHARGE_WALLET//待圈存账户→钱包
					||Integer.parseInt(trCode)==DealCode.TRM_CHARGE_SPECACC2WALLET//终端_未圈存账户→钱包
					||Integer.parseInt(trCode)==DealCode.TRM_CHARGE_ACC2WALLET){//终端_联机→钱包
				//recharge.saveTransferToWalletConfirm(map);
			}else{
				dealNo = recharge.saveWalletAshConfirm(map);
			}
			jsonObject.put("status","0");
			jsonObject.put("dealNo",dealNo);//确认流水
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("msg", e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 钱包账户现金充值撤销灰记录（冲正）
	 * @return
	 */
	public String saveOfflineAccRechargeCancelCz(){
		try{
			Map<String,Object> map = new HashMap<String, Object>();
			map.put("dealNo",this.dealNo);
			map.put("userId",baseService.getUser().getUserId());
			map.put("actionlog",baseService.getCurrentActionLog());
			trCode = "0";
			if(Integer.parseInt(this.trCode) == DealCode.RECHARGE_ACC_WALLET
					||Integer.parseInt(trCode)==DealCode.RECHARGE_NORECHARGE_WALLET
					||Integer.parseInt(trCode)==DealCode.TRM_CHARGE_SPECACC2WALLET
					||Integer.parseInt(trCode)==DealCode.TRM_CHARGE_ACC2WALLET){
				//this.jsonObject=recharge.saveTransferToWalletCancel(map);
			}else{
				recharge.saveWalletAshCancel(map);
			}
			jsonObject.put("status","0");
		} catch (Exception e) {
			jsonObject.put("status","1");//验证不通过
			jsonObject.put("msg",e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 》》联机账户充值,联机直接确认
	 * @return
	 */
	public String saveOnlineAccountR(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			Map<String,Object> map = new HashMap<String, Object>();
			map.put("userId",recharge.getUser().getUserId());
			map.put("cardNo",cardNo);
			map.put("amt",Arith.cardmoneymun(amt));
			map.put("paySource",paySource);//充值资金来源0现金1转账/银行卡2充值卡3促销4更改信用额度5网点预存款
			map.put("actionlog",baseService.getCurrentActionLog());
			rec = recharge.saveOnlineAccRecharge(map,DealCode.RECHARGE_CASH_ACC);
			// 判断交易密码是否为空
			CardBaseinfo card = (CardBaseinfo) baseService.findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + cardNo + "'");
			jsonObject.put("isReminder", "1");
			jsonObject.put("reminderMsg", "");
			if (Tools.processNull(card.getPayPwd()).equals("")) {
				jsonObject.put("isReminder","0");
				jsonObject.put("reminderMsg","<span style='color:red'>充值成功！【交易密码未设置，请重置交易密码】</span>");
			}else if ((new Long(Long.parseLong(Tools.processNull(card.getPayPwdErrNum()))).compareTo(6L)) == 1) {
				jsonObject.put("isReminder","0");
				jsonObject.put("reminderMsg","<span style='color:red'>充值成功！【交易密码错误次数大于6次，请重置交易密码】</span>");
			}
			jsonObject.put("status","0");
			jsonObject.put("dealNo",rec.getDealNo());
		}catch(Exception e){
			jsonObject.put("msg", Constants.ACC_KIND_NAME_LJ + "充值发生错误：" + e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》联机账户充值撤销,查询
	 * @return
	 */
	public String onlineAccRechargeQuery(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		try{
			if(this.queryType.equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select t.deal_no,t.customer_id,t.acc_name,t.card_no,");
				sb.append("(select d.code_name from sys_code d where d.code_type = 'CARD_TYPE' and d.code_value = t.card_type) cardType,");
				sb.append("t.acc_no,");
				sb.append("(select d.code_name from sys_code d where d.code_type = 'ACC_KIND' and d.code_value = t.acc_kind) accKind,");
				sb.append("trim(to_char(nvl(t.acc_bal,0)/100,'999,990.99')) accBal,");
				sb.append("trim(to_char(nvl(t.amt,0)/100,'999,990.99')) amt,to_char(t.deal_date,'yyyy-mm-dd hh24:mi:ss') dealDate,");
				sb.append("decode(t.deal_state,'0','正常','1','撤销','冲正','其他') dealState,t.clr_date,b.full_name,a.name,t.note ");
				sb.append("from PAY_CARD_DEAL_REC_" + recharge.getClrDate().substring(0,7).replaceAll("-",""));
				sb.append(" t left join sys_users a on t.user_id = a.user_id left join sys_branch b on a.brch_id = b.brch_id ");
				sb.append("left join base_personal p on t.customer_Id = p.customer_id ");
				sb.append("where t.deal_state = '0' and t.deal_code = '" + DealCode.RECHARGE_CASH_ACC + "' and t.user_id = '" 
						+ baseService.getUser().getUserId() + "'");
				sb.append(" and t.clr_date = '" + recharge.getClrDate() + "' ");
				if(!Tools.processNull(this.certType).equals("")){
					sb.append("and p.cert_type = '" + this.certType + "' ");
				}
				if(!Tools.processNull(this.certNo).equals("")){
					sb.append("and p.cert_no = '" + this.certNo + "' ");
				}
				if(!Tools.processNull(this.cardType).equals("")){
					//sb.append("and t.card_type = '" + this.cardType + "' ");
				}
				if(!Tools.processNull(this.cardNo).equals("")){
					sb.append("and t.card_no = '" + this.cardNo + "' ");
				}
				if(!Tools.processNull(this.dealNo).equals("")){
					sb.append("and t.deal_no = " + this.dealNo + " ");
				}
				if(Tools.processNull(this.sort).equals("")){
					sb.append("order by t.deal_no desc");
				}else{
					sb.append("order by " + sort + " " +  order);
				}
				Page list = recharge.pagingQuery(sb.toString(),page,rows);
				if(list.getAllRs() != null){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("未查询到正常的" + Constants.ACC_KIND_NAME_LJ + "充值记录或充值记录不是该柜员操作，不能进行撤销。<span style='color:red'>提示:请查询该卡是否存在未确认的灰记录，或已冲正的记录</span>");
				}
			}
		}catch(Exception e){
			logger.error(e);
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》联机账户充值撤销保存
	 * @return
	 */
	public String onlineAccRechargeCancel(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			//校验授权网点主管密码
			if(zgOperId.equals(getUsers().getUserId())){
				throw new CommonException("授权柜员不能是当前柜员");
			}
			baseService.judgeOperPwd(this.zgOperId, pwd);
			if(Tools.processNull(this.dealNo).equals("")){
				throw new CommonException("请选择一条充值记录，流水不能为空！");
			}
			Map<String,Object> map = new HashMap<String, Object>();
			map.put("userId",recharge.getUser().getUserId());
			map.put("dealNo",dealNo);
			map.put("zgOperId",zgOperId);
			map.put("actionlog",baseService.getCurrentActionLog());
			if(Integer.parseInt("0") == DealCode.RECHARGE_ACC_ACC){
				//recharge.saveTransferRevoke(map,Integer.parseInt(trCode));
			}else{
				rec = recharge.saveAccRechargeRevoke(map,DealCode.RECHARGE_CASH_ACC_REV);
			}
			jsonObject.put("status","0");
			jsonObject.put("dealNo",rec.getDealNo());
		}catch(Exception e){
			jsonObject.put("msg",Constants.ACC_KIND_NAME_LJ + "充值撤销发生错误：" + e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 》》联机账户转联机账户
	 * @return
	 */
	public String transferOnlineAcc2OnlineAcc(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			Map<String,Object> inparameters = new HashMap<String, Object>();
			inparameters.put("oper",baseService.getUser());//操作柜员
			inparameters.put("actionlog",baseService.getCurrentActionLog());//操作日志
			inparameters.put("outCardNo",this.outCardNo);//转出卡卡号
			inparameters.put("outAccBal",Arith.cardmoneymun(this.outAccBal));//转出卡卡账户余额 单位:分
			inparameters.put("outAccKind",Constants.ACC_KIND_ZJZH);//转出卡转出账户类型
			inparameters.put("inCardNo", this.inCardNo);//转入卡号
			inparameters.put("inAccBal", this.inAccBal);//转入卡账户余额
			inparameters.put("inAccKind",Constants.ACC_KIND_ZJZH);//转入卡转入账户类型
			inparameters.put("amt",Arith.cardmoneymun(this.amt));//转账金额
			inparameters.put("pwd",this.pwd);//转出账户联机账户密码
			rec = recharge.saveTransferOnlineAcc2OnlineAcc(inparameters);
			jsonObject.put("status","0");
			jsonObject.put("dealNo",rec.getDealNo());
		}catch(Exception e){
			jsonObject.put("msg",Constants.ACC_KIND_NAME_LJ + "转" + Constants.ACC_KIND_NAME_LJ + "发生错误：" + e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》联机转脱机,写灰记录
	 * @return
	 */
	public String transferOnlineAcc2OfflineAcc(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			Map<String,Object> inparameters = new HashMap<String, Object>();
			inparameters.put("oper",baseService.getUser());//操作柜员
			inparameters.put("actionlog",baseService.getCurrentActionLog());//操作日志
			inparameters.put("outCardNo",this.outCardNo);//转出卡卡号
			inparameters.put("outAccBal",Arith.cardmoneymun(this.outAccBal));//转出卡卡账户余额 单位:分
			inparameters.put("outAccKind",Constants.ACC_KIND_ZJZH);//转出卡转出账户类型
			inparameters.put("inCardNo",this.inCardNo);//转入卡号
			inparameters.put("inAccBal",Arith.cardmoneymun(inAccBal));//转入卡卡面余额
			inparameters.put("card_tr_count2",this.card_Recharge_TrCount);//转入卡卡面余额
			inparameters.put("inAccKind",Constants.ACC_KIND_QBZH);//转入卡转入账户类型
			inparameters.put("amt",Arith.cardmoneymun(this.amt));//转账金额
			inparameters.put("pwd",this.pwd);//转出账户联机账户密码
			rec = recharge.saveTransferOnlineAcc2OfflineAcc(inparameters);			
			String camt = String.format("%010d",Long.valueOf(Arith.cardmoneymun(amt)));
			String ctime = DateUtil.formatDate(rec.getBizTime(),"yyyyMMddHHmmss");
			jsonObject.put("dealNo",rec.getDealNo());
			jsonObject.put("status","0");
			jsonObject.put("writecarddata",camt + ctime + "123456");
		}catch(Exception e){
			jsonObject.put("msg",Constants.ACC_KIND_NAME_LJ + "转" + Constants.ACC_KIND_NAME_QB + "发生错误：" + e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》联机转脱机灰记录确认
	 * @return
	 */
	public String saveTransferToWalletConfirm(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			Map<String,Object> map = new HashMap<String, Object>();
			map.put("dealNo",this.dealNo);
			map.put("operid",baseService.getUser().getUserId());
			map.put("actionlog",baseService.getCurrentActionLog());
			recharge.saveTransferToWalletConfirm(map);
			jsonObject.put("status","0");
			jsonObject.put("dealNo",this.dealNo);
		} catch(Exception e) {
			jsonObject.put("msg",e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》联机转脱机灰记录取消
	 * @return
	 */
	public String saveTransferToWalletCancel(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			Map<String,Object> map = new HashMap<String, Object>();
			map.put("dealNo",this.dealNo);
			map.put("operid",baseService.getUser().getUserId());
			map.put("actionlog",baseService.getCurrentActionLog());
			recharge.saveTransferToWalletCancel(map);
			jsonObject.put("status","0");
		} catch(Exception e) {
			jsonObject.put("msg",e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 脱机转联机，写入灰记录
	 * @return
	 */
	public String saveTransferOfflineAcc2OnlineAcc() {
		try {
			jsonObject.put("status","1");
			jsonObject.put("msg","");
			/** userId    	        操作员编号
		    * trBatchNo 	         批次号
		    * termTrNo  	         终端交易流水号
			* outCardNo     	转出卡号
			* outAccKind       转出卡转出账户类型
			* outCardTrCount 	转出卡交易计数器
			* outCardAmt		转出卡钱包交易前金额
			* isJudgeOutCardHjl是否判断转出卡有灰记录
			* inCardNo     	转入卡号
			* inAccKind 		转入卡账户类型
			* inCardTrCount 	转入卡交易计数器
			* inCardAmt		转入卡钱包交易前金额
			* isJudgeInCardHjl 是否判断转入卡有灰记录
			* dealCode         交易代码
			* amt  			转账金额  null时转出所有金额
			* isJudgeOutAccPwd 是否判断转出卡密码 0 判断
			* pwd				转账密码
			* dealState        9写灰记录0直接写正常记录
			*/
			if (!Tools.processNull(inCardNo).equals(Tools.processNull(outCardNo))) {
				throw new CommonException("转出卡与转入卡不是同一张卡！");
			}
			Map<String, Object> inParameters = new HashMap<String, Object>();
			inParameters.put("userId",baseService.getUser().getUserId());
			inParameters.put("trBatchNo","");
			inParameters.put("termTrNo","");
			inParameters.put("outCardNo", this.outCardNo);
			inParameters.put("outAccKind",Constants.ACC_KIND_QBZH);
			inParameters.put("outCardTrCount",this.card_Recharge_TrCount);
			inParameters.put("outCardAmt",Arith.cardmoneymun(outAccBal));
			inParameters.put("isJudgeOutCardHjl",Constants.YES_NO_NO);
			inParameters.put("inCardNo", this.inCardNo);
			inParameters.put("inAccKind",Constants.ACC_KIND_ZJZH);
			inParameters.put("inCardTrCount","");
			inParameters.put("inCardAmt","");
			inParameters.put("isJudgeInCardHjl",Constants.YES_NO_NO);
			inParameters.put("dealCode",DealCode.RECHARGE_WALLET_ACC);
			inParameters.put("amt",Arith.cardmoneymun(this.amt));
			inParameters.put("isJudgeOutAccPwd",Constants.YES_NO_NO);
			inParameters.put("pwd","");
			inParameters.put("dealState",Constants.TR_STATE_HJL);
			TrServRec trServRec = recharge.saveAccTransfer(inParameters);
			jsonObject.put("dealNo",trServRec.getDealNo());
			jsonObject.put("status","0");
			String camt = String.format("%010d",Long.valueOf(Arith.cardmoneymun(amt)));
			String ctime = DateUtil.formatDate(trServRec.getBizTime(),"yyyyMMddHHmmss");
			jsonObject.put("writecarddata",camt + ctime + "00");
		}catch(Exception e){
			jsonObject.put("msg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 脱机转联机，灰记录确认
	 * @return
	 */
	public String saveTransferToOnlineConfirm() {
		try {
			jsonObject.put("status", "1");
			jsonObject.put("msg", "");
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("isHkZzGoodCard", isHkZzGoodCard);
			map.put("dealNo", dealNo);
			recharge.saveAccTransferConfirm(map);
			jsonObject.put("status","0");
		} catch (Exception e) {
			jsonObject.put("msg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 脱机转联机，灰记录取消
	 * @return
	 */
	public String saveTransferToOnlineCancel() {
		try {
			jsonObject.put("status", "1");
			jsonObject.put("msg", "");
			/**dealNo   	       转账时的业务流水号
			* outCardTrCount   转出卡卡交易计数器
			* inCardTrCount    转入卡卡交易计数器
			* outCardAmt	       转出卡钱包交易前金额
			* inCardAmt		       转入卡钱包交易前金额
			*/
			Map<String, Object> inParameters = new HashMap<String, Object>();
			inParameters.put("dealNo",dealNo);
			inParameters.put("outCardTrCount",this.card_Recharge_TrCount);
			inParameters.put("outCardAmt",Arith.cardmoneymun(outAccBal));
			inParameters.put("inCardTrCount","");
			inParameters.put("inCardAmt","");
			recharge.saveAccTransferCancel(inParameters);
			jsonObject.put("status", "0");
		}catch(Exception e) {
			jsonObject.put("msg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 脱机转脱机，写入灰记录
	 * @return
	 */
	public String saveTransferOfflineAcc2OfflineAcc() {
		try {
			jsonObject.put("status","1");
			jsonObject.put("msg","");
			if(Tools.processNull(this.outCardNo).equals(Tools.processNull(this.inCardNo))){
				throw new CommonException("脱机账户转脱机账户卡号不能相同！");
			}
			Map<String, Object> inParameters = new HashMap<String, Object>();
			inParameters.put("userId",baseService.getUser().getUserId());
			inParameters.put("trBatchNo","");
			inParameters.put("termTrNo","");
			inParameters.put("outCardNo",this.outCardNo);
			inParameters.put("outAccKind",Constants.ACC_KIND_QBZH);
			inParameters.put("outCardTrCount",this.card_Recharge_TrCount);
			inParameters.put("outCardAmt",Arith.cardmoneymun(outAccBal));
			inParameters.put("isJudgeOutCardHjl",Constants.YES_NO_NO);
			inParameters.put("inCardNo", this.inCardNo);
			inParameters.put("inAccKind",Constants.ACC_KIND_QBZH);
			inParameters.put("inCardTrCount",Tools.processNull(this.card_Recharge_TrCount2));
			inParameters.put("inCardAmt",Arith.cardmoneymun(inAccBal));
			inParameters.put("isJudgeInCardHjl",Constants.YES_NO_NO);
			inParameters.put("dealCode",DealCode.RECHARGE_WALLET_WALLET);
			inParameters.put("amt",Arith.cardmoneymun(this.amt));
			inParameters.put("isJudgeOutAccPwd",Constants.YES_NO_NO);
			inParameters.put("pwd","");
			inParameters.put("dealState",Constants.TR_STATE_HJL);
			TrServRec trServRec = recharge.saveAccTransfer(inParameters);
			jsonObject.put("dealNo",trServRec.getDealNo());
			String camt = String.format("%010d",Long.valueOf(Arith.cardmoneymun(amt)));
			String ctime = DateUtil.formatDate(trServRec.getBizTime(),"yyyyMMddHHmmss");
			jsonObject.put("writecarddata",camt + ctime + "123456");
			jsonObject.put("writecarddata2",camt + ctime + "00");
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",this.saveErrLog(e));
		}
		return this.JSONOBJ;
	}
	/**
	 * 脱机转脱机，灰记录取消
	 * @return
	 */
	public String saveTransferOfflineAcc2OfflineAccCancel() {
		try {
			jsonObject.put("status", "1");
			jsonObject.put("msg", "");
			/**dealNo   	       转账时的业务流水号
			* outCardTrCount   转出卡卡交易计数器
			* inCardTrCount    转入卡卡交易计数器
			* outCardAmt	       转出卡钱包交易前金额
			* inCardAmt		       转入卡钱包交易前金额
			*/
			Map<String, Object> inParameters = new HashMap<String, Object>();
			inParameters.put("dealNo",dealNo);
			inParameters.put("outCardTrCount",this.card_Recharge_TrCount);
			inParameters.put("outCardAmt",Arith.cardmoneymun(outAccBal));
			inParameters.put("inCardTrCount",this.card_Recharge_TrCount2);
			inParameters.put("inCardAmt",Arith.cardmoneymun(inAccBal));
			recharge.saveAccTransferCancel(inParameters);
			jsonObject.put("status", "0");
		}catch(Exception e) {
			jsonObject.put("msg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	public String getCardBindBankInfo(){
		try{
			Map map = recharge.getCardBindBankInfo(cardNo,paySource);
			this.jsonObject.put("status","0");
			this.jsonObject.put("alldata",map);
		}catch(Exception e){
			this.jsonObject.put("status","1");
			this.jsonObject.put("errMsg",e.getMessage());
			logger.error(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 银行卡圈存
	 * @return
	 */
	public String saveBankToZjzzQc(){
		try {
			Map hm = new HashMap();
			hm.put("userId",recharge.getUser().getUserId());
			hm.put("cardNo",Tools.processNull(cardNo));
			hm.put("pwd",Tools.processNull(pwd));
			hm.put("amt",Arith.cardmoneymun(amt));
			hm.put("actionlog",recharge.getCurrentActionLog());
			rec = recharge.saveOnAccRecharge(hm,DealCode.RECHARGE_ACC_CASH);
			this.jsonObject.put("status","0");
			this.jsonObject.put("dealNo",rec.getDealNo());
		}catch(Exception e) {
			this.jsonObject.put("status","1");
			this.jsonObject.put("errMsg",e.getMessage());
			logger.error(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 银行卡圈提
	 * @return
	 */
	public String saveZjzzToBankQt(){
		try {
			Map hm = new HashMap();
			hm.put("userId",recharge.getUser().getUserId());
			hm.put("cardNo",Tools.processNull(cardNo));
			hm.put("pwd",Tools.processNull(pwd));
			hm.put("amt",Arith.cardmoneymun(amt));
			hm.put("actionlog",recharge.getCurrentActionLog());
			rec = recharge.saveOnAccRechargeToBank(hm,Integer.valueOf("30105070"));
			this.jsonObject.put("status","0");
			this.jsonObject.put("dealNo",rec.getDealNo());
		}catch(Exception e) {
			this.jsonObject.put("status","1");
			this.jsonObject.put("errMsg",e.getMessage());
			logger.error(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 获取网点主管
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public String getBranchSupervisor(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("rows","");
		try{
			//+ "' and t.duty_id = '" + Constants.SYS_OPERATOR_LEVEL_BRANCH + "'"
			List<Object> allSupervisor = baseService.findBySql("select t.user_id,t.name,duty_id from SYS_USERS t where t.brch_id = '" + 
			baseService.getUser().getBrchId() + "'");
			JSONArray jsonArray = new JSONArray();
			if(allSupervisor != null && allSupervisor.size() > 0){
				for (Object object : allSupervisor) {
					Object[] onerow = (Object[]) object;
					JSONObject t = new JSONObject();
					t.put("operId",onerow[0].toString());
					t.put("name",onerow[1].toString());
					t.put("dutyId",onerow[2].toString());
					jsonArray.add(t);
				}
			}
			jsonObject.put("status","0");
			jsonObject.put("rows",jsonArray);
		}catch(Exception e){
			logger.error(e);
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》灰记录处理,信息查询
	 * @return
	 */
	public String dealAshRecord(){
		try{
			this.initBaseDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("select a.deal_no,s.deal_code_name,a.cr_customer_id,b.name,b.cert_no,a.cr_card_no,");
			sb.append("(select c.code_name from sys_code c where c.code_type = 'CARD_TYPE' and c.code_value = a.cr_card_type) cardtype,");
			sb.append("trim(to_char(nvl(a.cr_card_bal,0)/100,'999,990.99')) card_bal,");
			sb.append("trim(to_char(abs(nvl(a.cr_amt,0)/100),'999,990.99')) cr_amt ,a.cr_card_counter,to_char(a.deal_date,'yyyy-mm-dd hh24:mi:ss') deal_date,a.clr_date,");
			sb.append("nvl(h.full_name, co.co_org_name) full_name,nvl(u.name,a.user_id) opername from (select t.acpt_id,t.user_id, t.deal_no,t.deal_code,");
			sb.append("t.db_customer_id,t.db_card_no,t.db_card_type,t.db_acc_kind,t.db_acc_bal,t.db_card_bal,t.db_amt,t.db_card_counter,");
			sb.append("t.cr_customer_id,t.cr_card_no,t.cr_card_type,t.cr_acc_kind,t.cr_acc_bal,t.cr_card_bal,t.cr_amt,t.cr_card_counter, ");
			sb.append("t.deal_date,t.clr_date  ");
			sb.append("from acc_inout_detail t where t.deal_state = '9' ");
			if(!Tools.processNull(this.beginTime).equals("")){
				sb.append("and t.clr_date >= '" + this.beginTime + "' ");
			}
			if(!Tools.processNull(this.endTime).equals("")){
				sb.append("and t.clr_date <= '" + this.endTime + "' ");
			}
			if(!Tools.processNull(this.branchId).equals("")){
				sb.append("and t.acpt_id = '" + this.branchId + "' ");
			}
			if(!Tools.processNull(this.operId).equals("")){
				sb.append("and (t.user_id = '" + this.operId + "' or t.user_id = 'admin') ");
			}
			if(!Tools.processNull(this.cardType).equals("")){
				sb.append("and t.cr_card_type = '" + this.cardType + "' ");
			}
			if(!Tools.processNull(this.cardNo).equals("")){
				sb.append("and t.cr_card_no = '" + this.cardNo + "' ");
			}
			sb.append(") a,sys_code_tr s, base_personal b,sys_users u,sys_branch h, base_co_org co ");
			sb.append("where a.deal_code = s.deal_code(+) and a.user_id = u.user_id(+) and a.acpt_id = h.brch_id(+) and a.acpt_id = co.co_org_id(+) ");
			sb.append("and  a.cr_customer_id = b.customer_id(+) ");
			// 自有网点
			List<String> brchIds = recharge.findBySql("select brch_id from sys_branch start with brch_id = '10000000' connect by prior sysbranch_id =  pid");
			brchIds.add("99999999");
			String brchId = getUsers().getBrchId();
			if(brchIds.contains(brchId)){ // 自有网点
				// 不做限制
			} else { // 非自有网点
				sb.append("and ( ( 1 = 1 " + recharge.getLimitQueryData("h.brch_id","u.user_id") + ") or u.user_id = 'admin' )");//限制性语句
			}
			if(!Tools.processNull(this.certType).equals("")){
				sb.append(" and b.cert_Type = '" + this.certType + "' ");
			}
			if(!Tools.processNull(this.certNo).equals("")){
				sb.append(" and b.cert_no = '" + this.certNo + "' ");
			}
			if(Tools.processNull(this.sort).equals("")){
				sb.append(" order by a.deal_no desc");
			}else{
				sb.append(" order by " + this.sort + " " + this.order);
			}
			Page list = recharge.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("未查询到灰记录信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",this.saveErrLog(e));
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 》》灰记录处理,灰记录确认
	 * @return
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public String dealAshRecordConfrim(){
		try{
			jsonObject.put("status","1");
			jsonObject.put("msg","");
			if(Tools.processNull(this.dealNo).equals("")){
				throw new CommonException("灰记录处理确认，请至少选择一条记录！");
			}
			Map map = new HashMap();
			map.put("dealNo",dealNo);
			map.put("actionlog",BeanUtils.cloneBean(recharge.getCurrentActionLog()));
			map.put("oper",recharge.getUser());
			String dealCode = (String) recharge.findOnlyFieldBySql("select to_char(deal_code) from acc_inout_detail where deal_no = '" + dealNo + "' and deal_state = '9'");
			if (Tools.processNull(dealCode).equals("")) {
				throw new CommonException("灰记录不存在！");
			} else if (DealCode.RECHARGE_ACC_WALLET.toString().equals(dealCode) || DealCode.COTRANSFER_LJ2QB_QBZH.toString().equals(dealCode)) {// 联机转钱包
				map.put("operid", recharge.getUser().getUserId());
				recharge.saveTransferToWalletConfirm(map);
			} else if (DealCode.BHK_QB_ZZ.toString().equals(dealCode)) { // 好卡换卡钱包转账
				recharge.saveAccTransferConfirm(map);
			} else {
				rec = recharge.saveDealAshRecordConfrim(map);
			}
			jsonObject.put("status","0");
			jsonObject.put("msg","灰记录确认成功！");
			jsonObject.put("dealNo",rec.getOldDealNo());//原业务流水
		}catch(Exception e){
			jsonObject.put("msg","灰记录确认发生错误：" + e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 》》灰记录处理,灰记录取消
	 * @return
	 */
	public String dealAshRecordCancel(){
		try{
			jsonObject.put("status","1");
			jsonObject.put("msg","");
			if(Tools.processNull(this.dealNo).equals("")){
				throw new CommonException("灰记录处理，请至少选择一条记录！");
			}
			Map map = new HashMap();
			map.put("dealNo",this.getDealNo());
			map.put("actionlog",recharge.getCurrentActionLog());
			map.put("oper",recharge.getUser());
			rec = recharge.saveDealAshRecordCancel(map);
			jsonObject.put("status","0");
			jsonObject.put("msg","灰记录取消成功！");
			jsonObject.put("dealNo",rec.getOldDealNo());//原业务流水
		}catch(Exception e){
			jsonObject.put("msg","灰记录取消发生错误：" + e.getMessage());
			logger.error(e);
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	
	public String getRechargeCardInfo(){
		jsonObject.put("cardRecharge",new CardRecharge());
		try{
			if(!Tools.processNull(cardNo).equals("")) {
				CardRecharge cardRecharge = (CardRecharge) baseService.findOnlyRowByHql("from CardRecharge c where c.cardNo = '" + cardNo + "'");
				String cardType = (String) baseService.findOnlyFieldBySql("select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = '" + cardRecharge.getCardType() + "'");
				String useState = (String) baseService.findOnlyFieldBySql("select code_name from sys_code where code_type = 'RECHG_STATE' and code_value = '" + cardRecharge.getUseState() + "'");
				if(cardRecharge != null) {
					cardRecharge.setCardType(cardType);
					cardRecharge.setUseState(useState);
					jsonObject.put("cardRecharge", cardRecharge);
				}
			}
		}catch(Exception e){
			logger.error(e);
		}
		return this.JSONOBJ;
	}

	public String saveRechargeCardAccount(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
		try{
			rec = recharge.saveRechargeCardAccount(cardNo, rechargeCardNo, rechargeCardPwd);
			jsonObject.put("status","0");
			jsonObject.put("dealNo",rec.getDealNo());
		}catch(Exception e){
			jsonObject.put("msg",Constants.ACC_KIND_NAME_LJ + "充值发生错误：" + e.getMessage());
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 好卡换卡转钱包
	 * @return
	 */
	public String hkzzGoodCard() {
		try {
			jsonObject.put("status","1");
			jsonObject.put("msg","");
			if(Tools.processNull(this.outCardNo).equals(Tools.processNull(this.inCardNo))){
				throw new CommonException("脱机账户转脱机账户卡号不能相同！");
			}
			Map<String, Object> inParameters = new HashMap<String, Object>();
			inParameters.put("userId",baseService.getUser().getUserId());
			inParameters.put("trBatchNo","");
			inParameters.put("termTrNo","");
			inParameters.put("outCardNo",this.outCardNo);
			inParameters.put("outAccKind",Constants.ACC_KIND_QBZH);
			inParameters.put("outCardTrCount",this.card_Recharge_TrCount);
			inParameters.put("outCardAmt",Arith.cardmoneymun(outAccBal));
			inParameters.put("isJudgeOutCardHjl",Constants.YES_NO_NO);
			inParameters.put("inCardNo", this.inCardNo);
			inParameters.put("inAccKind",Constants.ACC_KIND_QBZH);
			inParameters.put("inCardTrCount",Tools.processNull(this.card_Recharge_TrCount2));
			inParameters.put("inCardAmt",Arith.cardmoneymun(inAccBal));
			inParameters.put("isJudgeInCardHjl",Constants.YES_NO_YES);
			inParameters.put("dealCode",DealCode.BHK_QB_ZZ);
			inParameters.put("amt",Arith.cardmoneymun(this.amt));
			inParameters.put("isJudgeOutAccPwd",Constants.YES_NO_NO);
			inParameters.put("pwd","");
			inParameters.put("dealState",Constants.TR_STATE_HJL);
			inParameters.put("agtCertType", rec.getAgtCertType());
			inParameters.put("agtCertNo", rec.getAgtCertNo());
			inParameters.put("agtName", rec.getAgtName());
			inParameters.put("agtTelNo", rec.getAgtTelNo());
			TrServRec trServRec = recharge.saveHkzzGoodCard(inParameters);
			jsonObject.put("dealNo",trServRec.getDealNo());
			String camt = String.format("%010d",Long.valueOf(Arith.cardmoneymun(amt)));
			String ctime = DateUtil.formatDate(trServRec.getBizTime(),"yyyyMMddHHmmss");
			jsonObject.put("writecarddata",camt + ctime + "123456");
			jsonObject.put("writecarddata2",camt + ctime + "00");
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",this.saveErrLog(e));
		}
		return this.JSONOBJ;
	}
	
	public String accBalReturnQuery () {
		try {
			initBaseDataGrid();
			String sql = " select t.deal_no, to_char(max(t.return_date), 'yyyy-mm-dd hh24:mi:ss') return_date, count(1) num, sum(t.return_bal) amt, "
					+ "sum(decode(t.state, 0, 1, 0)) return_num, sum(decode(t.state, 0, t.return_bal, 0)) return_amt, max(t2.full_name) brch_name, "
					+ "max(t3.name) user_name, max(t.state) max_state, min(t.state) min_state from acc_bal_return t join sys_branch t2 on t.brch_id = t2.brch_id "
					+ "join sys_users t3 on t.user_id = t3.user_id where 1 = 1 ";
			if(!Tools.processNull(dealNo).equals("")){
				sql += "and t.deal_no = '" + dealNo + "' ";
			}
			if(!Tools.processNull(beginTime).equals("")){
				sql += "and t.return_date >= to_date('" + beginTime + "', 'yyyy-mm-dd') ";
			}
			if(!Tools.processNull(endTime).equals("")){
				sql += "and t.return_date <= to_date('" + endTime + " 23:59:59', 'yyyy-mm-dd hh24:mi:ss') ";
			}
			sql += "group by t.deal_no having 1 = 1 ";
			if("0".equals(state)){
				sql += "and max(t.state) = 0 ";
			} else if("1".equals(state)){
				sql += "and min(t.state) = 1 ";
			} else if("2".equals(state)){
				sql += "and min(t.state) = 0 and max(t.state) = '1' ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			} else {
				sql += "order by deal_no";
			}
			//
			Page data = baseService.pagingQuery(sql, page, rows);
			if (data == null || data.getAllRs() == null || data.getAllRs().isEmpty()) {
				throw new CommonException("根据条件未找到对应数据！");
			}
			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String importAccBalReturnData() {
		try {
			if (file == null) {
				throw new CommonException("导入文件为空！");
			}
			long dealNo = recharge.saveImportAccBalReturnData(file);
			recharge.saveProcessAccBalReturnData(dealNo);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String accBalReturnDetail () {
		try {
			initBaseDataGrid();
			String sql = "select * from acc_bal_return t where 1 = 1 ";
			if(!Tools.processNull(dealNo).equals("")){
				sql += "and t.deal_no = '" + dealNo + "' ";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort + " ";
				if(!Tools.processNull(order).equals("")){
					sql += order;
				}
			}
			//
			Page data = baseService.pagingQuery(sql, page, rows);
			if (data == null || data.getAllRs() == null || data.getAllRs().isEmpty()) {
				throw new CommonException("根据条件未找到对应数据！");
			}
			jsonObject.put("rows", data.getAllRs());
			jsonObject.put("total", data.getTotalCount());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String doReturn () {
		try {
			if (dealNo == null) {
				throw new CommonException("回退流水为空！");
			}
			List<String> msg = new ArrayList<String>();
			List<Object[]> list = baseService.findBySql("select name, cert_no, sub_card_no, remain_bal from acc_bal_return where state = '1' and deal_no = '" + dealNo + "'");
			for (Object[] item : list) {
				try {
					recharge.saveReturn((String) item[1], dealNo);
				} catch (Exception e) {
					msg.add("【" + item[0] + ", " + item[1] + "】， " + e.getMessage());
				}
			}
			jsonObject.put("msg", msg);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportReturnData() {
		try {
			rows = 6000;
			accBalReturnDetail();
			JSONArray data = (JSONArray) jsonObject.get("rows");
			
			//
			String fileName = "车改资金回退明细";
			JSONObject r = data.getJSONObject(0);
			if(r == null){
				throw new Exception("没有记录！");
			}
			
			//
			response.setContentType("application/ms-excel;charset=utf-8");
			String userAgent = request.getHeader("user-agent");
			if (userAgent.toUpperCase().contains("MSIE") || userAgent.contains("Trident")) {
				response.setHeader("Content-disposition", "attachment; filename=" + URLEncoder.encode(fileName, "utf-8").replaceAll("\\+", " ") + ".xls");
			} else {
				response.setHeader("Content-disposition", "attachment; filename=" + new String((fileName).getBytes(), "iso8859-1") + ".xls");
			}

			// workbook
			Workbook workbook = new HSSFWorkbook();
			Sheet sheet = workbook.createSheet(fileName);

			sheet.setColumnWidth(0, 3000);
			sheet.setColumnWidth(1, 6000);
			sheet.setColumnWidth(2, 6000);
			sheet.setColumnWidth(3, 6000);
			sheet.setColumnWidth(4, 3000);
			sheet.setColumnWidth(5, 3000);
			sheet.setColumnWidth(6, 3000);
			sheet.setColumnWidth(7, 4000);
			sheet.setColumnWidth(8, 3000);
			sheet.setColumnWidth(9, 6000);
			sheet.setColumnWidth(10, 6000);
			sheet.setColumnWidth(11, 6000);

			// Font
			Font headCellFont = workbook.createFont();
			headCellFont.setBold(true);

			// cellStyle
			CellStyle headCellStyle = workbook.createCellStyle();
			headCellStyle.setBorderTop(CellStyle.BORDER_THIN);
			headCellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			headCellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			headCellStyle.setBorderRight(CellStyle.BORDER_THIN);
			headCellStyle.setAlignment(CellStyle.ALIGN_CENTER);
			headCellStyle.setVerticalAlignment(CellStyle.VERTICAL_CENTER);
			headCellStyle.setFont(headCellFont);
			// headCellStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
			// headCellStyle.setFillForegroundColor(HSSFColor.LEMON_CHIFFON.index);

			CellStyle cellStyle = workbook.createCellStyle();
			cellStyle.setBorderTop(CellStyle.BORDER_THIN);
			cellStyle.setBorderLeft(CellStyle.BORDER_THIN);
			cellStyle.setBorderBottom(CellStyle.BORDER_THIN);
			cellStyle.setBorderRight(CellStyle.BORDER_THIN);
			
			// moneyCellStyle
			CellStyle moneyCellStyle = workbook.createCellStyle();
			DataFormat moneyDataFormat = workbook.createDataFormat();
			moneyCellStyle.setBorderBottom(HSSFCellStyle.BORDER_THIN);// 下边框
			moneyCellStyle.setBorderLeft(HSSFCellStyle.BORDER_THIN);// 左边框
			moneyCellStyle.setBorderRight(HSSFCellStyle.BORDER_THIN);// 右边框
			moneyCellStyle.setBorderTop(HSSFCellStyle.BORDER_THIN);// 上边框
			moneyCellStyle.setAlignment(CellStyle.ALIGN_RIGHT);
			moneyCellStyle.setDataFormat(moneyDataFormat.getFormat("#,##0.00"));

			// head row 1
			int maxColumn = 12;
			int headRows = 3;
			for (int i = 0; i < headRows; i++) {
				Row row = sheet.createRow(i);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					cell.setCellStyle(headCellStyle);
				}
			}
			sheet.getRow(0).getCell(0).setCellValue(fileName);

			// second header
			String string = "导出时间：" + DateUtil.formatDate(new Date());
			sheet.getRow(1).getCell(0).setCellValue(string);

			// third header
			sheet.getRow(2).getCell(0).setCellValue("姓名");
			sheet.getRow(2).getCell(1).setCellValue("证件号码");
			sheet.getRow(2).getCell(2).setCellValue("卡号");
			sheet.getRow(2).getCell(3).setCellValue("银行卡号");
			sheet.getRow(2).getCell(4).setCellValue("留存金额");
			sheet.getRow(2).getCell(5).setCellValue("账户余额");
			sheet.getRow(2).getCell(6).setCellValue("回退金额");
			sheet.getRow(2).getCell(7).setCellValue("回退后账户余额");
			sheet.getRow(2).getCell(8).setCellValue("状态");
			sheet.getRow(2).getCell(9).setCellValue("银行");
			sheet.getRow(2).getCell(10).setCellValue("开户银行");
			sheet.getRow(2).getCell(11).setCellValue("备注");

			// 
			sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, maxColumn - 1));
			sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, maxColumn - 1));
			sheet.createFreezePane(4, headRows);
			
			// data
			int num = 0;
			int num2 = 0;
			int num3 = 0;
			double amt = 0;
			double amt2 = 0; 
			double amt3 = 0; 
			for (int i = 0; i < data.size(); i++, num++) {
				// cell
				Row row = sheet.createRow(i + headRows);
				for (int j = 0; j < maxColumn; j++) {
					Cell cell = row.createCell(j);
					if (j > 3 && j < 8) {
						cell.setCellStyle(moneyCellStyle);
					} else {
						cell.setCellStyle(cellStyle);
					}
				}
				// data
				JSONObject item = data.getJSONObject(i);
				row.getCell(0).setCellValue(item.getString("NAME"));
				row.getCell(1).setCellValue(item.getString("CERT_NO"));
				row.getCell(2).setCellValue(item.getString("CARD_NO"));
				row.getCell(3).setCellValue(item.getString("BANK_CARD_NO"));
				row.getCell(4).setCellValue(item.getDoubleValue("REMAIN_BAL")/100);
				row.getCell(5).setCellValue(item.getDoubleValue("ACC_BAL")/100);
				//
				double returnAmt = item.getDoubleValue("RETURN_BAL");
				row.getCell(6).setCellValue(returnAmt/100);
				amt += returnAmt;
				//
				if (item.containsKey("AFTER_ACC_BAL") && !item.get("AFTER_ACC_BAL").equals("")) {
					row.getCell(7).setCellValue(item.getDoubleValue("AFTER_ACC_BAL") / 100);
				}
				//
				String state = item.getString("STATE");
				if ("0".equals(state)) {
					state = "已回退";
					num2++;
					amt2 += returnAmt;
				} else {
					state = "未回退";
					num3++;
					amt3 += returnAmt;
				}
				row.getCell(8).setCellValue(state);
				//
				row.getCell(9).setCellValue(item.getString("BANK_NAME"));
				row.getCell(10).setCellValue(item.getString("BANK_ADDR"));
				row.getCell(11).setCellValue(item.getString("NOTE"));
			}

			Row row = sheet.createRow(data.size() + headRows);
			for (int j = 0; j < maxColumn; j++) {
				Cell cell = row.createCell(j);
				cell.setCellStyle(cellStyle);
			}
			row.getCell(0).setCellValue("统计：");
			row.getCell(1).setCellValue("共 " + num + " 人回退数据，总金额：" + amt/100 + ", 回退成功人数 ：" + num2 + "，回退成功 金额：" + amt2/100 + "；未回退人数 ：" + num3 + "，未回退 金额：" + amt3/100);
			sheet.addMergedRegion(new CellRangeAddress(data.size() + headRows, data.size() + headRows, 1, maxColumn - 1));
			//
			OutputStream os = response.getOutputStream();
			workbook.write(os);
			workbook.close();
			os.flush();
			os.close();
			SecurityUtils.getSubject().getSession().setAttribute("exportReturnData",Constants.YES_NO_YES);
		} catch (Exception e) {
			e.printStackTrace();
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String deleteAccBalReturnData() {
		try {
			if (dealNo == null) {
				throw new CommonException("回退数据流水为空！");
			}
			recharge.deleteAccBalReturnData(dealNo);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	/**
	 * 批量充值导入信息查询
	 */
	public String toQueryBatchRechargeImportData(){
		try{
			this.initBaseDataGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			//单据充值状态: 0 初始导入;1 未审核 2 审核失败;3 审核成功;4 充值全部失败; 5：部分充值 9 充值完成;
			StringBuffer sb = new StringBuffer();
			sb.append("select t.data_seq,to_char(t.imp_date,'yyyy-mm-dd hh24:mi:ss') impdate,");
			sb.append("t.tot_num,trim(to_char(t.tot_amt/100,'999,999,999,990.99')) tot_amt,t.useable_num,trim(to_char(t.useable_amt/100,'999,999,999,990.99')) useable_amt,");
			sb.append("t.suc_num,trim(to_char(t.suc_amt/100,'999,999,999,990.99')) suc_amt,t.err_num,trim(to_char(t.err_amt/100,'999,999,999,990.99')) err_amt,");
			sb.append("decode(t.state,'0','初始导入','1','未审核','2','审核失败','3','审核成功','4','充值失败','5','部分充值','9','充值完成','其他') statestr,t.state,");
			sb.append("t.acc_kind,(select s.code_name from sys_code s where s.code_type = 'ACC_KIND' and s.code_value= t.acc_kind) acckind,");
			sb.append("t.is_audit,decode(t.is_audit,'0','是','1','否','其他') isaudit,");
			sb.append("(select a.full_name from sys_branch a where a.brch_id = t.imp_brch_id) fullname,");
			sb.append("(select b.name from sys_users b where b.user_id = t.imp_user_id) username, ");
			sb.append("t.note ");
			sb.append("from base_batch_recharge_bills t where 1 = 1 ");
			if(!Tools.processNull(rec.getDealNo()).equals("")){
				sb.append("and t.data_seq = " + rec.getDealNo() + " ");
			}
			if(!Tools.processNull(rec.getBrchId()).equals("")){
				sb.append("and t.imp_brch_id = '" + rec.getBrchId() + "' ");
			}
			if(!Tools.processNull(rec.getUserId()).equals("")){
				sb.append("and t.imp_user_id = '" + rec.getUserId() + "' ");
			}
			if(!Tools.processNull(rec.getDealState()).equals("")){
				sb.append("and t.state = '" + rec.getDealState() + "' ");
			}
			if(!Tools.processNull(this.beginTime).equals("")){
				sb.append("and t.imp_date >= to_date('" + this.beginTime + " 00:00:00','yyyy-mm-dd hh24:mi:ss') ");
			}
			if(!Tools.processNull(this.endTime).equals("")){
				sb.append("and t.imp_date <= to_date('" + this.endTime + " 23:59:59','yyyy-mm-dd hh24:mi:ss') ");
			}
			if(Tools.processNull(sort).equals("")){
				sb.append("order by t.data_seq desc ");
			}else{
				sb.append("order by " + sort + " " + order);
			}
			Page list = baseService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未找到导入记录信息！");
			}
		}catch(Exception e){
			this.jsonObject.put("status",1);
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	public String saveBatchRecharge(){
		try {
			if(dealNo == null) {
				throw new CommonException("请勾选需要充值的记录信息！");
			}
			int count = recharge.saveBatchRecharge(dealNo,baseService.getUser(),baseService.getCurrentActionLog());
			jsonObject.put("status", "0");
			jsonObject.put("count",count);
		} catch (CommonException e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
			jsonObject.put("count",e.getErrorCode());
		}
		return JSONOBJ;
	}
	public String toQueryBatchRechargeData(){
		try{
			StringBuffer stringBuffer = new StringBuffer();
			stringBuffer.append("select t.data_id,t.name,t.cert_no,t.card_type,t.card_no,t.acc_kind,nvl(t.amt,0)/100 amt,");
			stringBuffer.append("(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.card_type) cardtype,");
			stringBuffer.append("(select code_name from sys_code where code_type = 'ACC_KIND' and code_value = t.acc_kind) acckind,");
			stringBuffer.append("t.state,decode(t.state,'0','初始导入','1','比对失败','2','比对成功','3','审核失败','4','审核成功','5','充值失败','9','充值成功','其他') statestr,");
			stringBuffer.append("(select full_name from sys_branch where brch_id = t.brch_id) brchName,");
			stringBuffer.append("(select name from sys_users where user_id = t.user_id) username ,");
			stringBuffer.append("to_char(t.recharge_time,'yyyy-mm-dd hh24:mi:ss') rechargetime,t.line_num,t.note ");
			stringBuffer.append("from base_batch_recharge_details t where 1 = 1 ");
			if(dealNo != null){
				stringBuffer.append("and t.data_seq = " + dealNo + " ");
			}
			if(!Tools.processNull(rec.getCustomerName()).equals("")){
                stringBuffer.append("and t.name = " + rec.getCustomerName() + " ");
            }
            if(!Tools.processNull(rec.getCertNo()).equals("")){
                stringBuffer.append("and t.cert_no = " + rec.getCertNo() + " ");
            }
			Page list = baseService.pagingQuery(stringBuffer.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommonException("根据查询条件未找到导入记录信息！");
			}
		}catch(Exception e){
            this.jsonObject.put("status",1);
            jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	public String saveBatchRechargeStateChanged(){
	    try{
            //queryType:0 删除,1 文件整体全部审核,2 明细单条记录审核
            //dealNo:唯一性索引 queryType = 0 or 1 时代表data_seq ,queryType = 2 代表data_id
            String changedState = this.request.getParameter("changedState");
            recharge.saveBatchRechargeStateChanged(dealNo,queryType,changedState,baseService.getUser(),null,baseService.getCurrentActionLog());
            this.jsonObject.put("status",0);
	    }catch(Exception e){
            this.jsonObject.put("status",1);
            jsonObject.put("errMsg",e.getMessage());
	    }
	    return this.JSONOBJ;
    }
	public String getCardNo() {
		return cardNo;
	}
	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}
	public String getAmt() {
		return amt;
	}
	public void setAmt(String amt) {
		this.amt = amt;
	}
	public String getCardAmt() {
		return cardAmt;
	}
	public void setCardAmt(String cardAmt) {
		this.cardAmt = cardAmt;
	}
	public String getCard_Recharge_TrCount() {
		return card_Recharge_TrCount;
	}
	public void setCard_Recharge_TrCount(String card_Recharge_TrCount) {
		this.card_Recharge_TrCount = card_Recharge_TrCount;
	}
	public String getCard_Recharge_TrCount2() {
		return card_Recharge_TrCount2;
	}
	public void setCard_Recharge_TrCount2(String card_Recharge_TrCount2) {
		this.card_Recharge_TrCount2 = card_Recharge_TrCount2;
	}
	public TrServRec getRec() {
		return rec;
	}
	public void setRec(TrServRec rec) {
		this.rec = rec;
	}
	public RechargeService getRecharge() {
		return recharge;
	}
	public void setRecharge(RechargeService recharge) {
		this.recharge = recharge;
	}
	public String getPaySource() {
		return paySource;
	}
	public void setPaySource(String paySource) {
		this.paySource = paySource;
	}
	public String getDealCode() {
		return trCode;
	}
	public void setDealCode(String trCode) {
		this.trCode = trCode;
	}
	public String getRechargeCardNo() {
		return rechargeCardNo;
	}
	public void setRechargeCardNo(String rechargeCardNo) {
		this.rechargeCardNo = rechargeCardNo;
	}
	public String getRechargeCardPwd() {
		return rechargeCardPwd;
	}
	public void setRechargeCardPwd(String rechargeCardPwd) {
		this.rechargeCardPwd = rechargeCardPwd;
	}
	public Long getDealNo() {
		return dealNo;
	}
	public void setDealNo(Long dealNo) {
		this.dealNo = dealNo;
	}
	public boolean isDebug() {
		return isDebug;
	}
	public void setDebug(boolean isDebug) {
		this.isDebug = isDebug;
	}
	public String getCertType() {
		return certType;
	}
	public void setCertType(String certType) {
		this.certType = certType;
	}
	public String getCertNo() {
		return certNo;
	}
	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}
	public String getCardType() {
		return cardType;
	}
	public void setCardType(String cardType) {
		this.cardType = cardType;
	}
	public String getSort() {
		return sort;
	}
	public void setSort(String sort) {
		this.sort = sort;
	}
	public String getOrder() {
		return order;
	}
	public void setOrder(String order) {
		this.order = order;
	}
	public String getQueryType() {
		return queryType;
	}
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	public String getOutCardNo() {
		return outCardNo;
	}
	public void setOutCardNo(String outCardNo) {
		this.outCardNo = outCardNo;
	}
	public String getOutAccBal() {
		return outAccBal;
	}
	public void setOutAccBal(String outAccBal) {
		this.outAccBal = outAccBal;
	}
	public String getInCardNo() {
		return inCardNo;
	}
	public void setInCardNo(String inCardNo) {
		this.inCardNo = inCardNo;
	}
	public String getInAccBal() {
		return inAccBal;
	}
	public void setInAccBal(String inAccBal) {
		this.inAccBal = inAccBal;
	}
	public String getPwd() {
		return pwd;
	}
	public void setPwd(String pwd) {
		this.pwd = pwd;
	}
	public String getZgOperId() {
		return zgOperId;
	}
	public void setZgOperId(String zgOperId) {
		this.zgOperId = zgOperId;
	}
	public String getBeginTime() {
		return beginTime;
	}
	public void setBeginTime(String beginTime) {
		this.beginTime = beginTime;
	}
	public String getEndTime() {
		return endTime;
	}
	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}
	public String getBranchId() {
		return branchId;
	}
	public void setBranchId(String branchId) {
		this.branchId = branchId;
	}
	public String getUserId() {
		return operId;
	}
	public void setOperId(String operId) {
		this.operId = operId;
	}
	public Boolean getIsHkZzGoodCard() {
		return isHkZzGoodCard;
	}
	public void setIsHkZzGoodCard(Boolean isHkZzGoodCard) {
		this.isHkZzGoodCard = isHkZzGoodCard;
	}
	public String getState() {
		return state;
	}
	public void setState(String state) {
		this.state = state;
	}
	public File getFile() {
		return file;
	}
	public void setFile(File file) {
		this.file = file;
	}
}