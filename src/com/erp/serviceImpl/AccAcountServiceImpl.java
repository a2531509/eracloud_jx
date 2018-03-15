package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.CashBox;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.service.AccAcountService;
import com.erp.service.DoWorkClientService;
import com.erp.util.AccItemUtils;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.Sys_Code;
import com.erp.util.Tools;

@Service("accAcountService")
public class AccAcountServiceImpl extends BaseServiceImpl implements AccAcountService{
	@Resource(name="doWorkClientService")
	private DoWorkClientService doWorkClientService;
	
	private String debugFlag = "1";

	/**
	 * 建立账户  先保存cm_card,sys_branch等表后再调用
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			obj_type 类型（与账户主体类型一致，0-网点1-个人/卡 2-单位 3-商户4-机构）
	 * 			sub_type 子类型（可放卡类型，或者商户类型之类的信息）
	 * 			obj_id   账户主体类型是卡时，传入卡号，其它传入client_id，(多个卡号时，卡号之间以,分割 cardno1,cardno2)
	 * @return HashMap
	 * @throws CommonException 
	 */
	public HashMap createAccount(SysActionLog log, HashMap hm)
			throws CommonException {
		List<Object> in = new java.util.ArrayList<Object>(); //1ACTION_NO|2TR_CODE|3OPER_ID|4OPER_TIME|5OBJ_TYPE|6SUB_TYPE|7OBJ_ID|8PWD|
		StringBuffer inpara = new StringBuffer();
		inpara.append(Tools.processNull(log.getDealNo())).append("|");
		inpara.append(Tools.processNull(log.getDealCode())).append("|");
		inpara.append(Tools.processNull(log.getUserId())).append("|");
		inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));
		inpara.append("|").append(Tools.processNull(hm.get("obj_type")));
		inpara.append("|").append(Tools.processNull(hm.get("sub_type")));
		inpara.append("|").append(Tools.processNull(hm.get("obj_id")));
		//密码
		inpara.append("|").append(Tools.processNull(hm.get("pwd")));
		//金额密文
		if(Tools.processNull(hm.get("obj_type")).equals("1")){
			String cardno = Tools.processNull(hm.get("obj_id"));
			//tensileString少拼了个金额0,所以追加一个逗号
			if(!cardno.trim().substring(cardno.length()).equals(",")){
				cardno=cardno+",";
			}
			int cardnos = (cardno.length() - cardno.replace(",", "").length());
			long startTime = System.currentTimeMillis();
//			inpara.append("|").append(this.money2Encrypt(cardno, Tools.tensileString("", cardnos * 2, true, "0,")));
			inpara.append("|").append(" ");
		}else{
			inpara.append("|").append("");
		}
		in.add(inpara.toString());
		List<Integer> out = new java.util.ArrayList<Integer>();
		out.add(java.sql.Types.VARCHAR);
		out.add(java.sql.Types.VARCHAR);
		try {
			List ret = publicDao.callProc("PK_BUSINESS.P_CREATEACCOUNT", in,out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					return null;
				}
			} else {
				throw new CommonException("建账户出错！");
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			throw new CommonException(ex.getMessage());
		}
	}
		

	/**
	 * 建立账户撤销
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			obj_type 类型（与账户主体类型一致，0-网点1-个人/卡 2-单位 3-商户4-机构）
	 * 			sub_type 子类型（可放卡类型，或者商户类型之类的信息）
	 * 			obj_id   账户主体类型是卡时，传入卡号，其它传入client_id
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap createAccountCancel(SysActionLog log, HashMap hm)
			throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * 》》钱包账户现金充值记录灰记录
	 * 》》联机账户充值
	 * 充值写灰记录（充值送、 收押金、更改信用额度 也调用这个）
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			acpt_id  		受理点编号(网点号或商户编号)
	 * 			oper_id  		操作员编号或终端号
	 * 			tr_batch_no 	批次号
	 * 			term_tr_no  	终端交易流水号
	 * 			card_no     	卡号
	 *			card_tr_count 	卡交易计数器
	 *			card_bal		钱包交易前金额
	 *			acc_kind 		账户类型
	 *			wallet_id		钱包编号 默认00
	 *			tr_amt			充值金额(更改信用额度时传入更改后的信用额度)
	 *			pay_source		充值资金来源0现金1转账2充值卡3促销4更改信用额度5网点预存款
	 *			sourcecard		充值卡卡号或银行卡卡号
	 *			rechg_pwd		充值卡密码
	 *			tr_state        9写灰记录0直接写正常记录
	 *			acpt_type		受理点分类，0商户1网点
	 * @return HashMap
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public HashMap recharge(SysActionLog log,HashMap hm)throws CommonException {
		List<Object> in = new java.util.ArrayList<Object>();
		in.add(getInpara4Recharge(log,hm));
		in.add(debugFlag);
		List<Integer> out = new java.util.ArrayList<Integer>();
		out.add(java.sql.Types.VARCHAR);
		out.add(java.sql.Types.VARCHAR);
		try {
			List ret = publicDao.callProc("PK_RECHARGE.P_RECHARGE", in, out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} 
			} else {
				throw new CommonException("充值" + (Tools.processNull(hm.get("tr_state")).equals(Constants.TR_STATE_HJL)?"灰":"")+"记录出错！");
			}
			//log4j.info("调用充值接口花费时间为：" + (System.currentTimeMillis()-startTime) + "ms");
		} catch (Exception ex) {
			ex.printStackTrace();
			throw new CommonException(ex.getMessage());
		}
		return null;
	}
	/**
	 * 新版联机账户充值
	 * @param log
	 * @param hm
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public HashMap saveOnLineAccRecharge(SysActionLog log,HashMap hm)throws CommonException{
		try{
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(log.getDealNo())).append("|");//1.流水号
			inpara.append(Tools.processNull("")).append("|");//2.交易代码 交易代码为30105010或30105090，不可传入其他交易码
			inpara.append(Tools.processNull(hm.get("itemType"))).append("|");//3.交易类型 0001 充值  0002 消费  0003 未登项圈提到电子钱包
			inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime()))).append("|");//4.操作时间
			inpara.append(Tools.processNull(hm.get("acptType"))).append("|");//5.受理点分类 ---》2合作机构
			inpara.append(Tools.processNull(hm.get("acptId"))).append("|");;//6.受理点编号
			inpara.append(Tools.processNull(log.getUserId())).append("|");//7.操作员
			inpara.append(Tools.processNull(hm.get("trBatchNo"))).append("|");;//8.批次号
			inpara.append(Tools.processNull(hm.get("termTrNo"))).append("|");//9.终端交易流水号
			inpara.append(Tools.processNull(hm.get("source"))).append("|");//10.来源 00：柜面 01：支付宝 02 微信 03 银行 04待定   99其他
			inpara.append(Tools.processNull(hm.get("sourceId"))).append("|");//11.卡号充值方id（if source = 01 then 支付宝账号 elsif source = 02 微信账号 elsif 银行账号...else ... end if）
			inpara.append(Tools.processNull(hm.get("sourceName"))).append("|");//12.充值方名称 （if source = 01 then 支付宝户名 elsif source = 02 微信名 elsif 银行户名...else ... end if）
			inpara.append(Tools.processNull(hm.get("sourceDesc"))).append("|");//13.自定义字段（比如说银行充值时，可以用中文描叙银行名称）
			inpara.append(Tools.processNull(hm.get("accKind"))).append("|");//14.账户类型
			inpara.append(Tools.processNull(hm.get("amt"))).append("|");//15.充值金额
			AccAccountSub  account = (AccAccountSub)this.findOnlyRowByHql("from AccAccountSub t where t.cardNo = '" + Tools.processNull(hm.get("cardNo")) + "' and t.accKind = '"+Tools.processNull(hm.get("accKind")) + "'");
			if(account == null){
				throw new CommonException("未查询到相关卡的账户信息！");
			}
			inpara.append(Tools.processNull(account.getBal())).append("|");//16.账户交易前金额
			if(!Tools.processNull(hm.get("accKind")).equals(Constants.ACC_KIND_QBZH) && !Tools.processNull(hm.get("accKind")).equals(Constants.ACC_KIND_JFZH)){
				if(!money2Encrypt(Tools.processNull(hm.get("cardNo")),Tools.processNull(account.getBal()),"0",Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD).equals(account.getBalCrypt())){
					throw new CommonException("账户交易的明文和密文不一致！");
				}
				inpara.append(money2Encrypt(Tools.processNull(hm.get("cardNo")),Tools.processNull(account.getBal()),Tools.processNull(hm.get("amt")),Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD)); 
				inpara.append("|");
			}else{
				inpara.append("").append("|");
			}
			inpara.append(Tools.processNull(hm.get("cardNo"))).append("|");//18.卡号
			inpara.append(Tools.processNull("0")).append("|");//19.圈存圈付标志 0 圈存  1 圈付
			inpara.append(Tools.processNull(hm.get("dzAcptId"))).append("|");//20.对账主体编号 必须输入
			List<Object> in = new java.util.ArrayList<Object>();
			in.add(inpara.toString());
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			List ret = publicDao.callProc("pk_co_service.online_recharge",in,out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(1).toString());
				if (res != 0) {
					String outMsg = ret.get(2).toString();
					throw new CommonException(outMsg);
				} 
			} else {
				throw new CommonException("充值记录出错！");
			}
		}catch(Exception ex){
			if(ex instanceof NullPointerException){
				throw new CommonException("充值记录错误" + ex.getMessage());
			}else{
				throw new CommonException(ex.getMessage());
			}
		}
		return null;
	}
	
	/**
	 * 充值到网点预存款账户
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			acpt_id  		预存款的网点
	 *			tr_amt			充值金额(更改信用额度时传入更改后的信用额度)
	 *			pay_source		充值资金来源0现金1转账4更改信用额度
	 *			tr_state        9写灰记录0直接写正常记录
	 *			acpt_type		受理点分类，0商户1网点
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap recharge2Brch(SysActionLog log, HashMap hm)
			throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * 》》钱包账户现金充值灰记录确认
	 * 》》联机账户现金充值（撤销）确认
	 * 》》 钱包账户现金充值（撤销）确认
	 * @param log SysActionLog
	 * @param hm HashMap
	 * @return HashMap
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public HashMap rechargeConfirm(SysActionLog log, HashMap hm)throws CommonException {
		//查询账户流水表
		List list = this.findBySql("select acc_inout_no,cr_card_no,cr_acc_kind,cr_amt from acc_inout_detail where deal_no = " + Tools.processNull(hm.get("deal_no")) + " and deal_state = '" + Constants.TR_STATE_HJL + "'");
		if(list == null || list.size() <= 0){
			throw new CommonException("根据流水号" + Tools.processNull(hm.get("deal_no")) + " ，未查询到需要确认的记录！");
		}
		for(int i=0;i<list.size();i++){
			Object[] o = (Object[])list.get(i);
			List<Object> in = new java.util.ArrayList<Object>(); 
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(log.getDealNo())).append("|");
			inpara.append(Tools.processNull(log.getDealCode())).append("|");
			inpara.append(Tools.processNull(log.getUserId())).append("|");
			inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));
			inpara.append("|").append(Tools.processNull(o[0]));//流水号
			inpara.append("|").append(this.getClrDate());//清分日期
			AccAccountSub acc = new AccAccountSub();
			if(Tools.processNull(o[1]).length() > 0){
				acc = (AccAccountSub) this.findOnlyRowByHql("from AccAccountSub t where t.cardNo = '" + Tools.processNull(o[1]) + "'  and t.accKind = '" + Tools.processNull(o[2]) + "'");
			}
			if(Tools.processNull(o[2]).equals(Constants.ACC_KIND_ZJZH)){
				inpara.append("|").append(money2Encrypt(acc.getCardNo(),acc.getBal() + "",Tools.processNull(o[3]),Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD));
				inpara.append("|").append(Tools.processNull(acc.getBal()));
				inpara.append("|").append(Tools.processNull(acc.getBalCrypt()));
			}else{
				inpara.append("|").append("");
				inpara.append("|").append(Tools.processNull(acc.getBal()));
				inpara.append("|").append(Tools.processNull(""));
			}
			in.add(inpara.toString());
			in.add(debugFlag);
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			try {
				List<?> ret = publicDao.callProc("PK_RECHARGE.p_rechargeconfirm_onerow", in, out);
				if (!(ret == null || ret.size() == 0)) {
					int res = Integer.parseInt(ret.get(0).toString());
					if (res != 0) {
						String outMsg = ret.get(1).toString();
						throw new CommonException(outMsg);
					}
				} else {
					throw new CommonException("灰记录确认出错！");
				}
			} catch (Exception ex) {
				ex.printStackTrace();
				throw new CommonException(ex.getMessage());
			}
		}
		return null;
	}

	/**
	 * 》》钱包账户现金充值灰记录冲正
	 * 》》钱包账户现金充值（撤销）灰记录冲正
	 * 》》充值正常记录撤销（联机、脱机）
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		充值时的业务流水号
	 * 			clr_date		撤销记录的清分日期
	 * 			card_no			卡号-----不用
	 * 			tr_state		原充值记录状态（ 灰记录或正常记录）, 对应的处理是冲正和撤销
	 *			card_tr_count 	卡交易计数器
	 *			card_bal		钱包交易前金额
	 * @return HashMap
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public HashMap rechargeCancel(SysActionLog log, HashMap hm) throws CommonException {
		if(Tools.processNull(hm.get("deal_state")).equals(Constants.TR_STATE_ZC)){
			List list = this.findBySql("select acc_inout_no,cr_card_no,cr_acc_kind,cr_amt from acc_inout_detail_" + Tools.processNull(hm.get("clr_date")).replace("-", "").substring(0,6) + " where deal_no =" + Tools.processNull(hm.get("deal_no")) + " and cr_card_no is not null and db_card_no is null and deal_state = '" + Constants.TR_STATE_ZC + "'");
			if(list == null || list.size() <= 0){
				throw new CommonException("根据流水号" + Tools.processNull(hm.get("deal_no")) + " ，未查询到对应的记录！");
			}
			for(int i=0;i<list.size();i++){
				//正常记录撤销
				Object[] o = (Object[])list.get(i);
				List<Object> in = new java.util.ArrayList<Object>(); 
				StringBuffer inpara = new StringBuffer();
				inpara.append(Tools.processNull(log.getDealNo())).append("|");
				inpara.append(Tools.processNull(log.getDealCode())).append("|");
				inpara.append(Tools.processNull(log.getUserId())).append("|");
				inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));
				inpara.append("|").append(Tools.processNull(Tools.processNull(o[0])));
				inpara.append("|").append(Tools.processNull(hm.get("clr_date")));
				inpara.append("|").append(Tools.processNull(hm.get("card_tr_count")));
				AccAccountSub acc = new AccAccountSub();
				if(Tools.processNull(o[1]).length() > 0){
					acc = (AccAccountSub) this.findOnlyRowByHql("from AccAccountSub t where t.cardNo = '" + Tools.processNull(o[1]) + "'  and t.accKind = '" + Tools.processNull(o[2]) + "'");
				}
				//联机撤销
				if(Tools.processNull(o[2]).equals(Constants.ACC_KIND_ZJZH)){
					inpara.append("|").append("");//撤销后账户余额  Tools.processNull(Arith.sub(acc.getBal() + "",o[3].toString()))
					inpara.append("|").append(money2Encrypt(acc.getCardNo(),acc.getBal() + "",Tools.processNull(o[3]),Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB));
					inpara.append("|").append(acc.getBal());//撤销前账户余额
					inpara.append("|").append(acc.getBalCrypt());//撤销前账户余额密文
				}else{
					inpara.append("|").append(Tools.processNull(hm.get("card_bal").toString()));//8card_bal 交易前卡面金额
					inpara.append("|").append("");//9撤销后卡账户金额密文
					inpara.append("|").append(acc.getBal());//10撤销前卡账户余额
					inpara.append("|").append("");//11撤销前卡账户密文
				}
				in.add(inpara.toString());
				in.add(debugFlag);
				List<Integer> out = new java.util.ArrayList<Integer>();
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				try {
					List<?> ret = publicDao.callProc("PK_RECHARGE.p_rechargecancel_onerow", in, out);
					if (!(ret == null || ret.isEmpty())) {
						if(ret.get(0) == null){
							throw new CommonException("存储过程返回码为空");
						}
						int res = Integer.parseInt(ret.get(0).toString());
						if (res != 0) {
							String outMsg = ret.get(1).toString();
							throw new CommonException(outMsg);
						}
					} else {
						throw new CommonException("充值撤销出错！");
					}
				} catch (Exception ex) {
					ex.printStackTrace();
					throw new CommonException(ex.getMessage());
				}
			}
		}else{
			//灰记录取消
			List<Object> in = new java.util.ArrayList<Object>(); 
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(log.getDealNo())).append("|");
			inpara.append(Tools.processNull(log.getDealCode())).append("|");
			inpara.append(Tools.processNull(log.getUserId())).append("|");
			inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));
			inpara.append("|").append(Tools.processNull(hm.get("deal_no")));
			inpara.append("|").append(Tools.processNull(hm.get("clr_date")));
			inpara.append("|").append(Tools.processNull(hm.get("card_no")));
			inpara.append("|").append(Tools.processNull(hm.get("deal_state")));
			inpara.append("|").append(Tools.processNull(hm.get("card_tr_count")));
			inpara.append("|").append(Tools.processNull(hm.get("card_bal")));
			inpara.append("|").append(""); //灰记录取消，金额密文不需要更新
			in.add(inpara.toString());
			in.add(debugFlag);
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			try {
				List ret = publicDao.callProc("PK_RECHARGE.P_RECHARGECANCEL", in, out);
				if (!(ret == null || ret.size() == 0)) {
					int res = Integer.parseInt(ret.get(0).toString());
					if (res != 0) {
						String outMsg = ret.get(1).toString();
						throw new CommonException(outMsg);
					} else {
						return null;
					}
				} else {
					throw new CommonException("冲正出现错误！");
				}
			} catch (Exception ex) {
				ex.printStackTrace();
				throw new CommonException(ex.getMessage());
			}
		}
		return null;
	}

	/**
	 * 充值冲正记录转成灰记录状态
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		充值时的业务流水号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap rechargeCancel2Ash(SysActionLog log, HashMap hm) throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * 账户返现
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			acpt_id  		受理点编号(网点号或商户编号)
	 * 			oper_id  		操作员编号或终端号
	 * 			tr_batch_no 	批次号
	 * 			term_tr_no  	终端交易流水号
	 * 			card_no     	卡号
	 *			card_tr_count 	卡交易计数器
	 *			card_bal		钱包交易前金额
	 *			acc_kind 		账户类型
	 *			wallet_id		钱包编号 默认00
	 *			tr_amt			返现金额
	 *			acpt_type		受理点分类，0商户1网点
	 * @return HashMap
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public HashMap returnCash(SysActionLog log, HashMap hm)throws CommonException {
		AccAccountSub acc = (AccAccountSub) this.findOnlyRowByHql("from AccAccountSub t where t.cardNo = '" + Tools.processNull(hm.get("card_no")) + "' and t.accKind = '" + Tools.processNull(hm.get("acc_kind")) + "'");//.fingetAcc_Sub_LedgerByCard_No(Tools.processNull(hm.get("card_no")),Tools.processNull(hm.get("acc_kind")));
		HashMap resHm = new HashMap();
		List<Object> in = new java.util.ArrayList<Object>(); 
		StringBuffer inpara = new StringBuffer();
		inpara.append(Tools.processNull(log.getDealNo())).append("|");//1
		inpara.append(Tools.processNull(log.getDealCode())).append("|");//2
		inpara.append(Tools.processNull(log.getUserId())).append("|");//3
		inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));//4
		inpara.append("|").append(Tools.processNull(hm.get("acpt_id")));//5
		inpara.append("|").append(Tools.processNull(hm.get("tr_batch_no")));//6
		inpara.append("|").append(Tools.processNull(hm.get("term_tr_no")));//7
		inpara.append("|").append(Tools.processNull(hm.get("card_no")));//8
		inpara.append("|").append(Tools.processNull(hm.get("card_tr_count")));//9
		inpara.append("|").append(Tools.processNull(hm.get("card_bal")));//10
		inpara.append("|").append(Tools.processNull(hm.get("acc_kind")));//11
		inpara.append("|").append(Tools.processNull(hm.get("wallet_id")));//12
		inpara.append("|").append(Tools.processNull(hm.get("tr_amt")));//13
		inpara.append("|").append(Tools.processNull(log.getMessage()));//14
		if(Tools.processNull(acc.getAccKind()).equals(Constants.ACC_KIND_ZJZH)){
			inpara.append("|").append(money2Encrypt(acc.getCardNo(),acc.getBal() + "",Tools.processNull(hm.get("tr_amt")),Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB));
		}else{
			inpara.append("|").append("");//15
		}
		inpara.append("|").append(Tools.processNull(hm.get("acpt_type")));//16
		inpara.append("|").append(Tools.processNull(acc.getBal()));//17

		in.add(inpara.toString());
		in.add(debugFlag);
		List<Integer> out = new java.util.ArrayList<Integer>();
		out.add(java.sql.Types.VARCHAR);
		out.add(java.sql.Types.VARCHAR);
		try {
			List ret = publicDao.callProc("PK_RECHARGE.P_RETURNCASH", in, out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					return resHm;
				}
			} else {
				throw new CommonException("账户返现出错！");
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			throw new CommonException(ex.getMessage());
		}
	}

	/**
	 * 转账写灰记录
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			acpt_id  		受理点编号(网点号或商户编号)
	 * 			oper_id  		操作员编号或终端号
	 * 			tr_batch_no 	批次号
	 * 			term_tr_no  	终端交易流水号
	 * 			card_no1     	转出卡号
	 *			card_tr_count1 	转出卡交易计数器
	 *			card_bal1		转出卡钱包交易前金额
	 *			acc_kind1 		转出卡账户类型
	 *			wallet_id1		转出卡钱包编号 默认00
	 * 			card_no2     	转入卡号
	 *			card_tr_count2 	转入卡交易计数器
	 *			card_bal2		转入卡钱包交易前金额
	 *			acc_kind2 		转入卡账户类型
	 *			wallet_id2		转入卡钱包编号 默认00
	 *			tr_amt			转账金额  null时转出所有金额
	 *			pwd				转账密码
	 * 			tr_state        9写灰记录0直接写正常记录
	 *			acpt_type		受理点分类，0商户1网点
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap transfer(SysActionLog log, HashMap<String,String> hm) throws CommonException {
		AccAccountSub acc1 = this.getAccSubLedgerByCardNoAndAccKind(Tools.processNull(hm.get("card_no1")),Tools.processNull(hm.get("acc_kind1")),"00");
		if(Tools.processNull(hm.get("tr_amt")).length() == 0){
			hm.put("tr_amt", "" + acc1.getBal());
		}
		hm.put("acc_bal1","" + acc1.getBal());
		if(Tools.processNull(hm.get("acc_kind1")).equals(Constants.ACC_KIND_ZJZH)){
			hm.put("encrypt1",money2Encrypt(acc1.getCardNo(),acc1.getBal() + "",Tools.processNull(hm.get("tr_amt")),Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB));
		}
		AccAccountSub acc2 = getAccSubLedgerByCardNoAndAccKind(Tools.processNull(hm.get("card_no2")),Tools.processNull(hm.get("acc_kind2")),"00");
		hm.put("acc_bal2","" + acc2.getBal());
		if(Tools.processNull(hm.get("acc_kind2")).equals(Constants.ACC_KIND_ZJZH)){
			hm.put("encrypt2", money2Encrypt(acc2.getCardNo(),acc2.getBal() + "",Tools.processNull(hm.get("tr_amt")),Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD));
		}
		List<Object> in = new java.util.ArrayList<Object>(); 
		StringBuffer inpara = new StringBuffer();
		inpara.append(Tools.processNull(log.getDealNo())).append("|");
		inpara.append(Tools.processNull(log.getDealCode())).append("|");
		inpara.append(Tools.processNull(log.getUserId())).append("|");
		inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));
		inpara.append("|").append(Tools.processNull(hm.get("acpt_id")));//受理点编号
		inpara.append("|").append(Tools.processNull(hm.get("tr_batch_no")));//自助终端使用
		inpara.append("|").append(Tools.processNull(hm.get("term_tr_no")));//终端交易序列号
		inpara.append("|").append(Tools.processNull(hm.get("card_no1")));//借方卡号  8
		inpara.append("|").append(Tools.processNull(hm.get("card_tr_count1")));
		inpara.append("|").append(Tools.processNull(hm.get("card_bal1")));//借方交易前卡片金额 10
		inpara.append("|").append(Tools.processNull(hm.get("acc_kind1")));
		inpara.append("|").append(Tools.processNull(hm.get("wallet_id1")));
		inpara.append("|").append(Tools.processNull(hm.get("card_no2")));
		inpara.append("|").append(Tools.processNull(hm.get("card_tr_count2")));
		inpara.append("|").append(Tools.processNull(hm.get("card_bal2")));//贷方交易前卡片金额
		inpara.append("|").append(Tools.processNull(hm.get("acc_kind2")));
		inpara.append("|").append(Tools.processNull(hm.get("wallet_id2")));
		inpara.append("|").append(Tools.processNull(hm.get("tr_amt")));//转账金额
		inpara.append("|").append(Tools.processNull(hm.get("pwd")));//转出账户密码  19
		inpara.append("|").append(Tools.processNull(log.getMessage()));
		inpara.append("|").append(Tools.processNull(hm.get("encrypt1")));
		inpara.append("|").append(Tools.processNull(hm.get("encrypt2")));
		inpara.append("|").append(Tools.processNull(hm.get("tr_state")));
		inpara.append("|").append(Tools.processNull(hm.get("acpt_type")));
		inpara.append("|").append(Tools.processNull(hm.get("acc_bal1")));//转出卡交易前金额 25
		inpara.append("|").append(Tools.processNull(hm.get("acc_bal2")));//转入卡交易前金额 26
		in.add(inpara.toString());
		in.add(debugFlag);
		List<Integer> out = new java.util.ArrayList<Integer>();
		out.add(java.sql.Types.VARCHAR);
		out.add(java.sql.Types.VARCHAR);
		try {
			List ret = publicDao.callProc("PK_TRANSFER.P_TRANSFER",in,out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					return null;
				}
			} else {
				throw new CommonException("转账出错！");
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			throw new CommonException(ex.getMessage());
		}
	}

	/**
	 * 联机转脱机灰记录确认
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		转账时的业务流水号
	 * 			clr_date		写灰记录时的清分日期
	 * 			card_no1		转出卡号
	 * 			card_no2		转入卡号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap transferConfirm(SysActionLog log, HashMap hm)throws CommonException {
		List list = this.findBySql("select acc_inout_no,db_card_no,db_acc_kind,db_amt,cr_card_no,cr_acc_kind,cr_amt from acc_inout_detail where deal_no =" + Tools.processNull(hm.get("deal_no")) + " and deal_state = '" + Sys_Code.TR_STATE_HJL + "'");
		if(list == null || list.size()==0){
			throw new CommonException("不存在要确认的灰记录");
		}
		for(int i=0;i<list.size();i++){
			Object[] o = (Object[])list.get(i);
			List<Object> in = new java.util.ArrayList<Object>(); 
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(log.getDealNo())).append("|");
			inpara.append(Tools.processNull(log.getDealCode())).append("|");
			inpara.append(Tools.processNull(log.getUserId())).append("|");
			inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));
			inpara.append("|").append(Tools.processNull(o[0]));
			inpara.append("|").append("");
			AccAccountSub acc1 = getAccSubLedgerByCardNoAndAccKind(Tools.processNull(o[1]),Tools.processNull(o[2]),"00");
			AccAccountSub acc2 = getAccSubLedgerByCardNoAndAccKind(Tools.processNull(o[4]),Tools.processNull(o[5]),"00");
			inpara.append("|").append(Tools.processNull(acc1.getBal()));
			inpara.append("|").append(Tools.processNull(acc2.getBal()));
			if(Tools.processNull(acc1.getAccKind()).equals(Sys_Code.ACC_KIND_ZJZH)){
				inpara.append("|").append(money2Encrypt(acc1.getCardNo(),acc1.getBal().toString(),Tools.processNull(o[3]),Sys_Code.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB));
			}else{
				inpara.append("|").append("");
			}
			if(Tools.processNull(acc2.getAccKind()).equals(Sys_Code.ACC_KIND_ZJZH)){
				inpara.append("|").append(money2Encrypt(acc2.getCardNo(),acc2.getBal().toString(),Tools.processNull(o[3]),Sys_Code.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD));
			}else{
				inpara.append("|").append("");
			}
			in.add(inpara.toString());
			in.add(debugFlag);
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			try {
				List ret = publicDao.callProc("PK_TRANSFER.p_transferconfirm_onerow", in, out);
				if (!(ret == null || ret.size() == 0)) {
					int res = Integer.parseInt(ret.get(0).toString());
					if (res != 0) {
						String outMsg = ret.get(1).toString();
						throw new CommonException(outMsg);
					}
				} else {
					throw new CommonException("转账确认出错！");
				}
			} catch (Exception ex) {
				ex.printStackTrace();
				throw new CommonException(ex.getMessage());
			}
		}
		return null;
	}

	/**
	 * 转账撤销
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		转账时的业务流水号
	 * 			clr_date		写灰记录时的清分日期
	 * 			tr_state		原转账记录状态  灰记录或正常记录允许撤销
	 * 			card_no1		转出卡号
	 * 			card_no2		转入卡号
	 *			card_tr_count1 	转出卡卡交易计数器
	 *			card_tr_count2 	转入卡卡交易计数器
	 *			card_bal1		转出卡钱包交易前金额
	 *			card_bal2		转入卡钱包交易前金额
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap transferCancel(SysActionLog log, HashMap hm)throws CommonException {
		if(Tools.processNull(hm.get("tr_state")).equals(Sys_Code.TR_STATE_ZC)){
			List list = this.findBySql("select acc_inout_no,db_card_no,db_acc_kind,db_amt,cr_card_no,cr_acc_kind,cr_amt from acc_inout_detail_" + Tools.processNull(hm.get("clr_date")).replace("-", "").substring(0,6) + " where deal_no =" + Tools.processNull(hm.get("action_no")) + " and cr_card_no is not null and db_card_no is not null and deal_state = '" + Sys_Code.TR_STATE_ZC + "'");
			if(list.size() == 0){
				throw new CommonException("不存在要撤销的灰记录");
			}
			for(int i = 0;i < list.size();i++){
				//正常记录撤销
				Object[] o = (Object[])list.get(i);
				AccAccountSub acc1 = this.getAccSubLedgerByCardNoAndAccKind(Tools.processNull(o[1]),Tools.processNull(o[2]),"00");//借方
				AccAccountSub acc2 = this.getAccSubLedgerByCardNoAndAccKind(Tools.processNull(o[4]),Tools.processNull(o[5]),"00");//贷方
				List<Object> in = new java.util.ArrayList<Object>(); 
				StringBuffer inpara = new StringBuffer();
				inpara.append(Tools.processNull(log.getDealNo())).append("|");
				inpara.append(Tools.processNull(log.getDealCode())).append("|");
				inpara.append(Tools.processNull(log.getUserId())).append("|");
				inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));
				inpara.append("|").append(Tools.processNull(o[0]));
				inpara.append("|").append(Tools.processNull(hm.get("clr_date")));
				inpara.append("|").append(Tools.processNull(acc1.getBal()));
				inpara.append("|").append(Tools.processNull(acc2.getBal()));
				inpara.append("|").append(Tools.processNull(hm.get("card_tr_count1")));
				inpara.append("|").append(Tools.processNull(hm.get("card_tr_count2")));
				inpara.append("|").append(Tools.processNull(hm.get("card_bal1")));
				inpara.append("|").append(Tools.processNull(hm.get("card_bal2")));
				if(Tools.processNull(acc1.getAccKind()).equals(Sys_Code.ACC_KIND_ZJZH)){
					inpara.append("|").append(money2Encrypt(acc1.getCardNo(),acc1.getBalCrypt(),Tools.processNull(o[3]),Sys_Code.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD));
				}else{
					inpara.append("|").append("");
				}
				if(Tools.processNull(acc2.getAccKind()).equals(Sys_Code.ACC_KIND_ZJZH)){
					inpara.append("|").append(money2Encrypt(acc2.getCardNo(),acc2.getBalCrypt(),Tools.processNull(o[3]),Sys_Code.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_SUB));
				}else{
					inpara.append("|").append("");
				}
				in.add(inpara.toString());
				in.add(debugFlag);
				List<Integer> out = new java.util.ArrayList<Integer>();
				out.add(java.sql.Types.VARCHAR);
				out.add(java.sql.Types.VARCHAR);
				try {
					List ret = publicDao.callProc("PK_TRANSFER.p_transfercancel_onerow", in, out);
					if (!(ret == null || ret.size() == 0)) {
						int res = Integer.parseInt(ret.get(0).toString());
						if (res != 0) {
							String outMsg = ret.get(1).toString();
							throw new CommonException(outMsg);
						}
					} else {
						throw new CommonException("转账撤销出错！");
					}
				} catch (Exception ex) {
					ex.printStackTrace();
					throw new CommonException(ex.getMessage());
				}
			}
		}else{
			//灰记录取消
			List<Object> in = new java.util.ArrayList<Object>(); 
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(log.getDealNo())).append("|");
			inpara.append(Tools.processNull(log.getDealCode())).append("|");
			inpara.append(Tools.processNull(log.getUserId())).append("|");
			inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));
			inpara.append("|").append(Tools.processNull(hm.get("action_no")));
			inpara.append("|").append(Tools.processNull(hm.get("clr_date")));
			inpara.append("|").append(Tools.processNull(hm.get("tr_state")));
			inpara.append("|").append(Tools.processNull(hm.get("card_no1")));
			inpara.append("|").append(Tools.processNull(hm.get("card_no2")));
			inpara.append("|").append(Tools.processNull(hm.get("card_tr_count1")));
			inpara.append("|").append(Tools.processNull(hm.get("card_tr_count2")));
			inpara.append("|").append(Tools.processNull(hm.get("card_bal1")));
			inpara.append("|").append(Tools.processNull(hm.get("card_bal2")));
			inpara.append("|").append(Tools.processNull(hm.get("encrypt1")));
			inpara.append("|").append(Tools.processNull(hm.get("encrypt2")));
			in.add(inpara.toString());
			in.add(debugFlag);
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			try {
				List ret = publicDao.callProc("PK_TRANSFER.P_TRANSFERCANCEL", in, out);
				if (!(ret == null || ret.size() == 0)) {
					int res = Integer.parseInt(ret.get(0).toString());
					if (res != 0) {
						String outMsg = ret.get(1).toString();
						throw new CommonException(outMsg);
					} else {
						return null;
					}
				} else {
					throw new CommonException("转账撤销出错！");
				}
			} catch (Exception ex) {
				ex.printStackTrace();
				throw new CommonException(ex.getMessage());
			}
		}
		return null;
	}

	/**
	 * 记现金尾箱
	 * @param userId String 操作员
	 * @param amt Long 记账金额 单位:分           
	 * @param actionLog 业务操作日志
	 * @param flag 收付标志 Constants.IN_OUT_FLAG_SR 收;Constants.IN_OUT_FLAG_FC 付
	 * @param note 备注
	 * @throws CommonException
	 */
	@SuppressWarnings({"unchecked","rawtypes"})
	@Override
	public HashMap updateCashBox(String userId,Long amt,SysActionLog actionLog,String flag)throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(userId).equals("")){
				throw new CommonException("现金尾箱记账发生错误，柜员编号不能为空！");
			}
			if(amt == null || amt <= 0){
				return null;
			}
			if(!Tools.processNull(flag).equals("0") && !Tools.processNull(flag).equals("1")){
				throw new CommonException("现金尾箱记账发生错误，收付标志只能是0或是1！");
			}
			//2.调存储过程
			List<Object> in = new java.util.ArrayList<Object>(); 
			in.add(actionLog.getDealNo());//交易流水号
			in.add(actionLog.getDealCode());//交易代码
			in.add(actionLog.getUserId());//柜员编号
			in.add(DateUtil.formatDate(actionLog.getDealTime(),"yyyy-MM-dd HH:mm:ss"));
			in.add(Tools.processNull(flag).equals("0") ? amt + "" : Arith.sub("0",amt + ""));//金额
			in.add(actionLog.getMessage());//备注
			in.add(this.getClrDate());//清分日期
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			List ret = publicDao.callProc("PK_BUSINESS.P_UPDATECASHBOX", in, out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					return null;
				}
			} else {
				throw new CommonException("记现金尾箱出错！");
			}
		}catch (Exception ex) {
			ex.printStackTrace();
			throw new CommonException(ex.getMessage());
		}
	}

	/**
	 * 收取服务费、工本费等、销售充值卡、网点存款、网点取款也调用这个
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			item_no  	收费类型（用科目号，充值卡销售201104，网点存取款102100，工本费702101，其它收入709999等）
	 * 			amt			金额  正值现金收入 负值现金支出
	 *			acpt_type	受理点分类，0商户1网点
	 *			pay_source  0现金1非现金
	 * @return HashMap
	 * @throws CommonException
	 */
	@SuppressWarnings({"unchecked","rawtypes"})
	public HashMap cost(SysActionLog log, HashMap hm) throws CommonException {
		List<Object> in = new java.util.ArrayList<Object>(); 
		StringBuffer inpara = new StringBuffer();
		inpara.append(Tools.processNull(log.getDealNo())).append("|");
		inpara.append(Tools.processNull(log.getDealCode())).append("|");
		inpara.append(Tools.processNull(log.getUserId())).append("|");
		inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));
		inpara.append("|").append(Tools.processNull(hm.get("item_no")));
		inpara.append("|").append(Tools.processNull(hm.get("amt")));
		inpara.append("|").append(Tools.processNull(log.getMessage()));
		inpara.append("|").append(Tools.processNull(hm.get("acpt_type")));
		inpara.append("|").append(Tools.processNull(hm.get("pay_source")));
		in.add(inpara.toString());
		in.add(debugFlag);
		List<Integer> out = new java.util.ArrayList<Integer>();
		out.add(java.sql.Types.VARCHAR);
		out.add(java.sql.Types.VARCHAR);
		try {
			List<?> ret = publicDao.callProc("PK_BUSINESS.P_COST", in, out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					return null;
				}
			} else {
				throw new CommonException("记账出错！");
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			throw new CommonException(ex.getMessage());
		}
	}
	/**
	 * 押金记账接口
	 * @param acptType  受理点类型
	 * @param userId    受理柜员
	 * @param amt       金额   正金额    =  收押金   ; 负数   =  付押金
	 * @param paySource 资金来源  0 现金   1 转账
	 * @param actionLog 操作日志
	 * @return          null
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public HashMap yjjz(String acptType,String userId,Long amt,String paySource,SysActionLog actionLog) throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(userId).equals("")){
				throw new CommonException("押金记账发生错误，柜员编号不能为空！");
			}
			if(amt == null || amt <= 0){
				return null;
			}
			List<Object> in = new java.util.ArrayList<Object>(); 
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(actionLog.getDealNo())).append("|");
			inpara.append(Tools.processNull(actionLog.getDealCode())).append("|");
			inpara.append(Tools.processNull(actionLog.getUserId())).append("|");
			inpara.append(Tools.processNull(DateUtil.formatDate(actionLog.getDealTime())));
			inpara.append("|").append(Tools.processNull(AccItemUtils.ACCITEM_KYJYSR));//科目编号
			inpara.append("|").append(Tools.processNull(amt));
			inpara.append("|").append(Tools.processNull(actionLog.getMessage()));
			inpara.append("|").append(Tools.processNull(acptType));
			inpara.append("|").append(Tools.processNull(paySource));
			in.add(inpara.toString());
			in.add(debugFlag);
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			List<?> ret = publicDao.callProc("PK_BUSINESS.P_COST", in, out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					return null;
				}
			} else {
				throw new CommonException("押金记账出错！");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 工本费记账接口
	 * @param acptType   受理点类型
	 * @param userId     受理柜员编号
	 * @param amt        金额   正金额    =  收押金   ; 负数   =  付押金
	 * @param paySource  资金来源  0 现金   1 转账
	 * @param actionLog  操作日志
	 * @return           null;
	 * @throws CommonException
	 */
	public HashMap gbfjz(String acptType,String userId,Long amt,String paySource,SysActionLog actionLog) throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(userId).equals("")){
				throw new CommonException("工本费记账发生错误，柜员编号不能为空！");
			}
			if(amt == null || amt <= 0){
				return null;
			}
			List<Object> in = new java.util.ArrayList<Object>(); 
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(actionLog.getDealNo())).append("|");
			inpara.append(Tools.processNull(actionLog.getDealCode())).append("|");
			inpara.append(Tools.processNull(actionLog.getUserId())).append("|");
			inpara.append(Tools.processNull(DateUtil.formatDate(actionLog.getDealTime())));
			inpara.append("|").append(Tools.processNull(AccItemUtils.ACCITEM_GBFSR));//科目编号
			inpara.append("|").append(Tools.processNull(amt));
			inpara.append("|").append(Tools.processNull(actionLog.getMessage()));
			inpara.append("|").append(Tools.processNull(acptType));
			inpara.append("|").append(Tools.processNull(paySource));
			in.add(inpara.toString());
			in.add(debugFlag);
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			List<?> ret = publicDao.callProc("PK_BUSINESS.P_COST", in, out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					return null;
				}
			} else {
				throw new CommonException("工本费记账出错！");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 其他收入记账接口
	 * @param acptType 受理点类型 Constants.ACPT_TYPE_SH = 0 商户   Constants.ACPT_TYPE_GM = 1 网点
	 * @param userId String 操作员
	 * @param amt Long 记账金额 单位:分         金额   正金额    =  收押金   ; 负数   =  付押金  
	 * @param paySource 付款方式 0 现金 1 转账
	 * @param actionLog 业务操作日志
	 * @param note 备注
	 * @throws CommonException
	 */
	public HashMap qtsr(String acptType,String userId,Long amt,String paySource,SysActionLog actionLog) throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(userId).equals("")){
				throw new CommonException("其他收入记账发生错误，柜员编号不能为空！");
			}
			if(amt == null || amt <= 0){
				return null;
			}
			List<Object> in = new java.util.ArrayList<Object>(); 
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(actionLog.getDealNo())).append("|");
			inpara.append(Tools.processNull(actionLog.getDealCode())).append("|");
			inpara.append(Tools.processNull(actionLog.getUserId())).append("|");
			inpara.append(Tools.processNull(DateUtil.formatDate(actionLog.getDealTime())));
			inpara.append("|").append(Tools.processNull(AccItemUtils.ACCITEM_GBFSR));//科目编号
			inpara.append("|").append(Tools.processNull(amt));
			inpara.append("|").append(Tools.processNull(actionLog.getMessage()));
			inpara.append("|").append(Tools.processNull(acptType));
			inpara.append("|").append(Tools.processNull(paySource));
			in.add(inpara.toString());
			in.add(debugFlag);
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			List<?> ret = publicDao.callProc("PK_BUSINESS.P_COST", in, out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					return null;
				}
			} else {
				throw new CommonException("其他收入记账出错！");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 自行车押金记账接口
	 * @param acptType 受理点类型 Constants.ACPT_TYPE_SH = 0 商户   Constants.ACPT_TYPE_GM = 1 网点
	 * @param userId String 操作员
	 * @param amt Long 记账金额 单位:分         金额   正金额    =  收押金   ; 负数   =  付押金  
	 * @param paySource 付款方式 0 现金 1 转账
	 * @param actionLog 业务操作日志
	 * @throws CommonException
	 */
	public HashMap zxcjz(String acptType,String userId,Long amt,String paySource,SysActionLog actionLog) throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(userId).equals("")){
				throw new CommonException("自行车押金记账发生错误，柜员编号不能为空！");
			}
			if(amt == null || amt <= 0){
				return null;
			}
			List<Object> in = new java.util.ArrayList<Object>(); 
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(actionLog.getDealNo())).append("|");
			inpara.append(Tools.processNull(actionLog.getDealCode())).append("|");
			inpara.append(Tools.processNull(actionLog.getUserId())).append("|");
			inpara.append(Tools.processNull(DateUtil.formatDate(actionLog.getDealTime())));
			inpara.append("|").append(Tools.processNull(AccItemUtils.ACCITEM_ZXC));//科目编号
			inpara.append("|").append(Tools.processNull(amt));
			inpara.append("|").append(Tools.processNull(actionLog.getMessage()));
			inpara.append("|").append(Tools.processNull(acptType));
			inpara.append("|").append(Tools.processNull(paySource));
			in.add(inpara.toString());
			in.add(debugFlag);
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			List<?> ret = publicDao.callProc("PK_BUSINESS.P_COST", in, out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					return null;
				}
			} else {
				throw new CommonException("自行车押金记账出错！");
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 现金交接
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			oper_id1  	付出方柜员
	 * 			oper_id2	收入方柜员
	 * 			amt			金额
	 *			acpt_type	受理点分类，0商户1网点
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap cashHandOver(SysActionLog log, HashMap hm)
			throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}
	/**
	 * 根据柜员编号和币种获取柜员尾箱
	 * @param userId  柜员编号
	 * @param coin_Kind 币种类型  1人民币 2积分
	 * @return
	 * @throws CommonException
	 */
	public CashBox getCashBoxByOperidAndCoinKind(String userId, String coinKind) throws CommonException {
		try{
			List list = this.findByHql("from CashBox t where t.userId = '" + userId + "' and coinKind = '" + coinKind + "'");
			if(list == null || list.size() == 0) {
				throw new CommonException("根据柜员号：" + userId + "、币种：" + super.getCodeNameBySYS_CODE("COIN_TYPE",coinKind) + " 找不到柜员尾箱！");
			}else {
				CashBox box = (CashBox)list.get(0);
				return box;
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}

	/**
	 * 轧账
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			oper_id  	要轧账的操作员，传入空的话对log中的操作员轧账
	 * 			clr_date    要轧账的日期，传入空的话对当日轧账
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap daybal(SysActionLog log, HashMap hm) throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * 商户结算
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			biz_id  	商户号  传入空的时候表示对所有商户结算
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap merchantSettle(SysActionLog log, HashMap hm)
			throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * 商户即时结算
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			biz_id  	商户号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap merchantSettleImmeidate(SysActionLog log, HashMap hm)
			throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * 商户结算回退
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			stl_sum_no  	商户结算汇总序号(回退之后的结算记录)
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap merchantSettleRollback(SysActionLog log, HashMap hm)
			throws CommonException {
		List<Object> in = new java.util.ArrayList<Object>(); 
		in.add(hm.get("stl_sum_no")); //商户结算汇总序号
		List<Integer> out = new java.util.ArrayList<Integer>();
		out.add(java.sql.Types.VARCHAR);
		out.add(java.sql.Types.VARCHAR);
		try {
			List ret = publicDao.callProc("PK_MERCHANTSETTLE.P_SETTLEROLLBACK", in, out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					return null;
				}
			} else {
				throw new CommonException("商户结算回退出错！");
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			throw new CommonException(ex.getMessage());
		}
	}

	/**
	 * 商户结算支付
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			stlsumnos  要支付的结算记录  STL_SUM_NO$CARD_TYPE$ACC_KIND,STL_SUM_NO$CARD_TYPE$ACC_KIND
	 * 			bank_sheet_no 银行回单号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap merchantSettlePay(SysActionLog log, HashMap hm)
			throws CommonException {
		List<Object> in = new java.util.ArrayList<Object>(); 
		StringBuffer inpara = new StringBuffer();
		inpara.append(Tools.processNull(log.getDealNo())).append("|");
		inpara.append(Tools.processNull(log.getDealCode())).append("|");
		inpara.append(Tools.processNull(log.getUserId())).append("|");
		inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));
		inpara.append("|").append(Tools.processNull(hm.get("stlsumnos")));
		inpara.append("|").append(Tools.processNull(log.getMessage()));
		inpara.append("|").append(Tools.processNull(hm.get("bank_sheet_no")));
		in.add(inpara.toString());
		in.add(debugFlag);
		List<Integer> out = new java.util.ArrayList<Integer>();
		out.add(java.sql.Types.VARCHAR);
		out.add(java.sql.Types.VARCHAR);
		try {
			List ret = publicDao.callProc("PK_MERCHANTSETTLE.P_SETTLEPAY", in, out);
			if (!(ret == null || ret.size() == 0)) {
				int res = Integer.parseInt(ret.get(0).toString());
				if (res != 0) {
					String outMsg = ret.get(1).toString();
					throw new CommonException(outMsg);
				} else {
					return null;
				}
			} else {
				throw new CommonException("商户结算支付出错！");
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			throw new CommonException(ex.getMessage());
		}
	}

	/**
	 * 积分兑换
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			card_no     	卡号
	 *			tr_amt			兑换的积分数
	 *			type		         兑换类型 1兑换到未圈存账户2兑换礼品
	 *			acpt_type		受理点分类，0商户1网点
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap pointsExchange(SysActionLog log, HashMap hm)
			throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * 积分兑换撤销
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no		被撤销记录的action_no
	 * 			clr_date		被撤销记录的清分日期
	 * 			card_no     	卡号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap pointsExchangeCancel(SysActionLog log, HashMap hm)
			throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * 脱机消费灰记录确认
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		消费的业务流水号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap offlineConsumeConfirm(SysActionLog log, HashMap hm)
			throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * 脱机消费退货
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		消费的业务流水号
	 * 			clr_date 		消费记录的清分日期
	 *			card_tr_count 	卡交易计数器
	 *			card_bal		钱包交易前金额
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap offlineConsumeReturn(SysActionLog log, HashMap hm)
			throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * 脱机消费灰记录冲正
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		消费的业务流水号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap offlineConsumeCancel(SysActionLog log, HashMap hm)
			throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * 脱机消费拒付改成正常
	 * @param log SysActionLog
	 * @param hm HashMap
	 * 			action_no 		消费的业务流水号
	 * @return HashMap
	 * @throws CommonException
	 */
	public HashMap offlineConsumeBlack2Normal(SysActionLog log, HashMap hm)
			throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}
	/**
	 * 金额加密
	 * @param cardno
	 * @param encrymoney
	 * @param amt
	 * @param op
	 * @return
	 * @throws CommonException
	 */
	private String money2Encrypt(String cardno,String encrymoney,String amt,String op) throws CommonException{
		String money = doWorkClientService.money2EncryptCal(Tools.processNull(cardno),Tools.processNull(encrymoney),Tools.processNull(amt),op);
		return money;
	}
	/**
	 * 根据卡号和账户种类、钱包编号查询分户账
	 * 
	 * @param card_No
	 * @param acc_Kind
	 * @param wallet_Id
	 * @return
	 * @throws CommonException
	 */
	public AccAccountSub getAccSubLedgerByCardNoAndAccKind(String card_No, String acc_Kind, String wallet_Id) throws CommonException {
		List<?> list = this.findByHql("from AccAccountSub t where cardNo = '" + card_No + "' and accKind = '" + acc_Kind + "' and walletNo = '" + wallet_Id + "'");
		if (list == null || list.size() == 0) {
			throw new CommonException("根据卡号：" + card_No + "、账户类型：" + super.getCodeNameBySYS_CODE("ACC_KIND", acc_Kind) + "、钱包编号：" + wallet_Id + " 找不到分户账！");
		} else {
			AccAccountSub accSubLedger = (AccAccountSub) list.get(0);
			return accSubLedger;
		}
	}
	/**
	 * 根据科目号和客户号(网点号)查询分户账
	 * 
	 * @param item_No
	 * @param client_Id
	 * @param sub_Acc_No
	 * @return
	 * @throws CommonException
	 */
	public AccAccountSub getAccSubLedgerByItemNoAndClientid(String item_No, String client_Id, Long sub_Acc_No) throws CommonException {
		String hql = "from Acc_Sub_Ledger t where item_No = '" + item_No + "' and client_Id = '" + client_Id + "' ";
		if (sub_Acc_No == 0) {
			hql += " and sub_Acc_No = 0";
		} else {
			hql += " and sub_Acc_No > 0";
		}
		List list = this.findByHql(hql);
		if (list == null || list.size() == 0) {
			throw new CommonException("根据科目号：" + item_No + "、客户号(网点号)：" + client_Id + " 找不到分户账！");
		} else {
			AccAccountSub accSubLedger = (AccAccountSub) list.get(0);
			return accSubLedger;
		}
	}
	/**
	 * recharge调用存储过程参数拼接
	 * @param log
	 * @param hm
	 * @return
	 */
	private String getInpara4Recharge(SysActionLog log,HashMap hm) throws CommonException{
		try{
			StringBuffer inpara = new StringBuffer();
			inpara.append(Tools.processNull(log.getDealNo())).append("|");//1.流水号
			inpara.append(Tools.processNull(log.getDealCode())).append("|");//2.交易代码
			inpara.append(Tools.processNull(log.getUserId())).append("|");//3.操作员
			inpara.append(Tools.processNull(DateUtil.formatDate(log.getDealTime())));//4.操作时间
			inpara.append("|").append(Tools.processNull(hm.get("acpt_id")));//5.受理点编号
			inpara.append("|").append(Tools.processNull(hm.get("tr_batch_no")));//6.批次号
			inpara.append("|").append(Tools.processNull(hm.get("term_tr_no")));//7.终端交易流水号
			inpara.append("|").append(Tools.processNull(hm.get("card_no")));//8.卡号
			inpara.append("|").append(Tools.processNull(hm.get("card_tr_count")));//9.卡交易计数器
			inpara.append("|").append(Tools.processNull(hm.get("card_bal")));//10.钱包交易前金额   卡面金额
			inpara.append("|").append(Tools.processNull(hm.get("acc_kind")));//11.账户类型
			inpara.append("|").append(Tools.processNull(hm.get("wallet_id")));//12.钱包编号
			inpara.append("|").append(Tools.processNull(hm.get("tr_amt")));//13.充值金额
			inpara.append("|").append(Tools.processNull(hm.get("pay_source")));//14.资金来源
			inpara.append("|").append(Tools.processNull(hm.get("sourcecard")));//15.充值卡卡号
			inpara.append("|").append(Tools.processNull(hm.get("rechg_pwd")));//16.充值卡密码
			inpara.append("|").append(Tools.processNull(log.getMessage()));//17.备注
			inpara.append("|").append(Tools.processNull(hm.get("deal_state")));//18.  9写灰记录   0   直接写正常记录
			if(Tools.processNull(hm.get("deal_state")).equals(Constants.STATE_ZC)){//19.充值后卡账户金额密文
				AccAccountSub  account = (AccAccountSub)this.findOnlyRowByHql("from AccAccountSub t where t.cardNo = '" + Tools.processNull(hm.get("card_no")) + "' and t.accKind = '"+Tools.processNull(hm.get("acc_kind")) + "'");
				if(account == null){
					throw new CommonException("未查询到相关卡的账户信息！");
				}
				if(!Tools.processNull(hm.get("acc_kind")).equals(Constants.ACC_KIND_QBZH)&&!Tools.processNull(hm.get("acc_kind")).equals(Constants.ACC_KIND_JFZH)){
					//判断充值前密文是否正确
					if(!money2Encrypt(Tools.processNull(hm.get("card_no")),Tools.processNull(hm.get("acc_bal")),"0",Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD).equals(account.getBalCrypt())){
						throw new CommonException("账户交易的明文和密文不一致！");
					}
					inpara.append("|").append(money2Encrypt(Tools.processNull(hm.get("card_no")),Tools.processNull(hm.get("acc_bal")),Tools.processNull(hm.get("tr_amt")),Constants.ENCRYPT_MONEY_OP_ENCRYPT_MONEY_OP_ADD)); 
				}else{
					inpara.append("|").append("");
				}
			}else{
				inpara.append("|").append("");//不是直接确认的，金额密文不需要更新
			}
			inpara.append("|").append(Tools.processNull(hm.get("acpt_type")));//20.受理点分类 ---》2合作机构
			inpara.append("|").append(Tools.processNull(hm.get("acc_bal")));//21.卡账户交易前金额
			return inpara.toString();
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	public DoWorkClientService getDoWorkClientService() {
		return doWorkClientService;
	}
	public void setDoWorkClientService(DoWorkClientService doWorkClientService) {
		this.doWorkClientService = doWorkClientService;
	}
	
	public void saveCancelDayBook(SysActionLog log, String oldactionno)
		    throws CommonException{
		try{
		      List in = new ArrayList();
		      StringBuffer inpara = new StringBuffer();
		      in.add(Tools.processNull(Tools.processNull(oldactionno)));
		      in.add(Tools.processNull(log.getDealNo()));
		      in.add(Tools.processNull(getClrDate()));
		      in.add(Tools.processNull(getClrDate()));
		      in.add(Tools.processNull(log.getDealCode()));
		      in.add(Tools.processNull("admin"));
		      in.add("");
		      in.add("");
		      in.add("");
		      in.add("");
		      in.add("");
		      in.add("");
		      in.add("1");
		      in.add(this.debugFlag);
		      List out = new ArrayList();
		      out.add(Integer.valueOf(12));
		      out.add(Integer.valueOf(12));
		      try {
		        List ret = this.publicDao.callProc("pk_business.p_daybookcancel", in, out);
		        if ((ret != null) && (ret.size() != 0)) {
		          int res = Integer.parseInt(ret.get(0).toString());
		          if (res != 0) {
		            String outMsg = ret.get(1).toString();
		            throw new CommonException(outMsg);
		          }
		        } else {
		          throw new CommonException("流水撤销出错！");
		        }
		      } catch (Exception ex) {
		        ex.printStackTrace();
		        throw new CommonException(ex.getMessage());
		      }
		    } catch (Exception e) {
		      throw new CommonException(e.getMessage());
		}
	}


	@Override
	public void account(AccAccountSub accountDb, AccAccountSub accountCr, BigDecimal amount, SysActionLog log, String credit, String batchNo, String termNo, String state, String note) throws CommonException {
		try {
			SysBranch currentBranch = (SysBranch)findOnlyRowByHql("from SysBranch where brchId = '" + 
					log.getBrchId() + "'");
		    List inparams = new ArrayList();
		    inparams.add(accountDb.getAccNo());
		    inparams.add(accountCr.getAccNo());
		    inparams.add(accountDb.getBal());
		    inparams.add(accountCr.getBal());
		    inparams.add("");
		    inparams.add("");
		    inparams.add(accountDb.getBalCrypt() == null ? "" : accountDb.getBalCrypt());
		    inparams.add(accountCr.getBalCrypt() == null ? "" : accountCr.getBalCrypt());
		    inparams.add(amount.multiply(BigDecimal.valueOf(100L)));
		    inparams.add(credit);
		    inparams.add(getSequenceByName("SEQ_ACC_INOUT_NO"));
		    inparams.add(log.getDealCode());
		    inparams.add(accountCr.getOrgId());
		    inparams.add(currentBranch.getOrgId());
		    inparams.add(currentBranch.getBrchType());
		    inparams.add(log.getBrchId());
		    inparams.add(log.getUserId());
		    inparams.add(batchNo);
		    inparams.add(termNo);
		    inparams.add(DateUtil.formatDate(log.getDealTime()));
		    inparams.add(state);
		    inparams.add(log.getDealNo());
		    inparams.add(note);
		    inparams.add(getClrDate());
		    inparams.add("");
		    inparams.add("");

		    List outTypes = new ArrayList();
		    outTypes.add(Integer.valueOf(12));
		    outTypes.add(Integer.valueOf(12));

		    List rets = this.publicDao.callProc("pk_business.p_account2", 
		      inparams, outTypes);

		    if ((rets == null) || (rets.isEmpty())) {
		    	throw new CommonException("调用充值过程失败.");
		    }

		    if (!rets.get(0).equals("00000000")){
		    	throw new CommonException(rets.get(1).toString().equals("null") ? "" : rets.get(1).toString());
		    }
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
		
	}
}
