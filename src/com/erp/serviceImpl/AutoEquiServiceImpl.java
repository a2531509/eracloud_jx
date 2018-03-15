package com.erp.serviceImpl;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseMerchant;
import com.erp.model.BasePersonal;
import com.erp.model.BasePhoto;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardBindBankCard;
import com.erp.model.SysActionLog;
import com.erp.model.SysErrLog;
import com.erp.model.TrServRec;
import com.erp.service.AutoEquiService;
import com.erp.service.DoWorkClientService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.Des3Util;
import com.erp.util.JsonHelper;
import com.erp.util.MD5Util;
import com.erp.util.SqlTools;
import com.erp.util.Tools;
import com.erp.util.TripleDES;
import com.erp.webservice.server.bean.Data;
import com.erp.webservice.server.bean.InNetRequestBean;
import com.erp.webservice.server.bean.RequestBean;
import com.erp.webservice.server.bean.ResponseBean;


@Service("autoEquiService")
public class AutoEquiServiceImpl extends BaseServiceImpl implements AutoEquiService {
	private String methodName;
	private String Oper_Brch_Id;
	private DoWorkClientService doWorkClientService;
	
	/**
	 * 登录验证
	 */
	public synchronized String loginValidate(String inXml) throws CommonException {
		String  corp_Name=null;
		BasePersonal person=null;
		Data data=new Data();
		try {
			ArrayList datas=new ArrayList();
			InNetRequestBean reqBean=(InNetRequestBean)this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			if("1".equals(reqBean.getClientType())){//个人账户登录
				validCardnoAndCertno(reqBean.getCardNo(),reqBean.getCertNo());//验证卡号或证件号
				if (Tools.processNull(reqBean.getPwd()).equals("")){ 
					throw new CommonException("参数pwd不能为空！");
				}
				CardBaseinfo card=(CardBaseinfo)findCardByCardnoAndCertNo(reqBean.getCardNo(),reqBean.getCertNo(),"");
				reqBean.setPwd(decrypt_3DES(reqBean.getPwd(),reqBean.getCardNo()));
				person=this.findPersonByCardNo(card.getCardNo());
				reqBean.setPwd(Des3Util.encrypt_3des(reqBean.getPwd(),person.getCertNo(),"",""));
				if(!reqBean.getPwd().equals(person.getServPwd()))
					throw new CommonException("原密码不正确！");
				String personalId=Tools.processNull((String)this.findOnlyFieldBySql("select personal_id from  base_siinfo b where b.customer_Id='"+person.getCustomerId()+"'"));
				
				if (!Tools.processNull(person.getCorpCustomerId()).equals("")) {
					corp_Name=(String)this.findOnlyFieldBySql("select b.corp_Name from BaseCorp b where b.customer_Id='"+person.getCorpCustomerId()+"'");
				}
				BasePhoto photo = (BasePhoto)this.findByHql(" from BasePhoto o where o.customerId='"+person.getCustomerId()+"'");
				CardBindBankCard bank_Bind = (CardBindBankCard)this.findOnlyRowByHql("from BaseCardBankBind c where bind_State='0' and c.customer_Id = '"+person.getCustomerId()+"'") ;
				if(bank_Bind !=null){
					String Bank_name =(String)this.findOnlyFieldBySql("select bank_name from base_bank where bank_id= '"+bank_Bind.getBankId()+"'");
					data.setBank_Card_No(bank_Bind.getBankCardNo());
					data.setBank_Id(bank_Bind.getBankId());	
					data.setInLimitOneDay(Arith.cardreportsmoneydiv("0" + "")) ;
					data.setBank_Name(Bank_name);
				}
				data.setSubCardNo(card.getSubCardNo());//社保卡号
				data.setCardNo(card.getCardNo());//市民卡卡号
				data.setCardType(card.getCardType());//卡类型
				data.setCardTypeName(super.getCodeNameBySYS_CODE("CARD_TYPE", card.getCardType()));
				data.setCertType(person.getCertType());//证件类型
				data.setCertTypeName(super.getCodeNameBySYS_CODE("CERT_TYPE", person.getCertType()));
				data.setCardState(card.getCardState());//卡状态
				data.setCardStateName(super.getCodeNameBySYS_CODE("CARD_STATE", card.getCardState()));
				data.setCertNo(person.getCertNo());//证件号
				data.setPersonalId(personalId);
				data.setClientName(person.getName());
				data.setClientId(person.getCustomerId()+"");
			
				data.setSexName(super.getCodeNameBySYS_CODE("SEX",person.getGender()));
				data.setBirthday(person.getBirthday());
				data.setNationName(super.getCodeNameBySYS_CODE("NATION", person.getNation()));
				data.setLetterAddr(person.getLetterAddr());
				if (Tools.processNull(person.getPhoneNo()).equals("") || Tools.processNull(person.getMobileNo()).equals("")) {
					data.setTelNo(Tools.processNull(person.getPhoneNo()) + Tools.processNull(person.getMobileNo()));
				}else {
					data.setTelNo(person.getPhoneNo() + "," + person.getMobileNo());
				}
				data.setEmpName(Tools.processNull(corp_Name).equals("")?"":corp_Name);
				//if (photo !=null && !Tools.processNull(photo.getPhotob()).equals("")) 
					//data.setPhoto(Base64.encodeBytes(photo.getPhotob()));
				datas.add(data);
			}else if("2".equals(reqBean.getClientType())){//商户账户登录
				if (Tools.processNull(reqBean.getBizId()).equals("") || Tools.processNull(reqBean.getPwd()).equals("")) 
					throw new CommonException("参数bizId、pwd不能为空！");
				reqBean.setPwd(decrypt_3DES(reqBean.getPwd(),reqBean.getBizId()));//密码解密，商户号作为key
				BaseMerchant merchant=findMerchantByBizIdOrClientIdOrName(reqBean.getBizId(),null,null);
				if(!reqBean.getPwd().equals(merchant.getServPwd())){
					throw new CommonException("原密码不正确！");
				}
				data.setClientId(merchant.getCustomerId()+"");
				data.setBizClientId(merchant.getCustomerId()+"");
				data.setBizId(merchant.getCustomerId()+"");
				data.setBizType(merchant.getMerchantType()+"");
				data.setBizTypeName(super.getCodeNameBySYS_CODE("BIZ_TYPE", merchant.getMerchantType()+""));
				data.setClientName(merchant.getMerchantName());
				datas.add(data);
			}else{
				throw new CommonException("参数clientType不合法！");
			}
			return createReturnXml(new ResponseBean("0","",datas), getMethodName(1),true,reqBean);
		} catch (Exception e) {
			throw new CommonException(e.toString());
		}
	}
	/**
	 * 密码判断
	 */
	public String judgePwd(String inXml) throws CommonException{
		try{
			RequestBean reqBean=(RequestBean)this.xml2java("judgePwd",inXml, "RequestBean", InNetRequestBean.class);
			if (Tools.processNull(reqBean.getCardNo()).equals("") && Tools.processNull(reqBean.getCertNo()).equals("")){
				throw new CommonException("参数cardNo,certNo不能都为空！");
			}
			List list=this.findBySql("select distinct b.* from BasePersonal b , c where b.customer_Id=c.customer_Id and (c.card_No='"+reqBean.getCardNo()+"' or c.sub_Card_No='"+reqBean.getCardNo()+"') or b.cert_no='"+reqBean.getCertNo()+"'");
			if(list.size()==0||list==null){
				throw new CommonException("输入的身份证或者卡号信息错误！");
			}
			if(Tools.processNull(reqBean.getOldPwd()).equals("")){
				throw new CommonException("原密码不能为空！");
			}
			
			boolean eqs=false;
			if("1".equals(reqBean.getClientType())){
				initBaseQueryData(reqBean);//初始卡号和还原个人密码
			}else{
				reqBean.setOldPwd(decrypt_3DES(reqBean.getOldPwd(),Tools.processNull(reqBean.getBizId())));
			}
			checkGegex(reqBean.getPwd());//用于检验必须为6位数字的正则表达式
			
			Object pwd=null;
			if (Tools.processNull(reqBean.getPwdType()).equals("1")) {//服务密码判断
				if("1".equals(reqBean.getClientType())){
					String pwd_Err_Num=(String)this.findOnlyFieldBySql("select distinct to_char(pwd_Err_Num) from BasePersonal b , c " +"where b.customer_Id=c.customer_Id and (c.card_No='"+reqBean.getCardNo()+"' or c.sub_Card_No='"+reqBean.getCardNo()+"')");
					if(Tools.processNull(pwd_Err_Num).equals("")){//GECC-2011-08-02
						pwd_Err_Num="0";
					}
					if(new Long(pwd_Err_Num)>=3){
						throw new CommonException("密码错误次数已经超过3次！");
					}
					pwd = this.findOnlyRowByHql("select b from BasePersonal b, CardBaseinfo c where b.customer_Id=c.customer_Id and (c.card_No='"+reqBean.getCardNo()+"' or c.sub_Card_No='"+reqBean.getCardNo()+"') and b.serv_Pwd='"+reqBean.getPwd()+"'");
					if(pwd==null){
						publicDao.doSql("update BasePersonal b set pwd_Err_Num=pwd_Err_Num+1 where exists (select 1 from " +" c where b.customer_Id=c.customer_Id and (c.card_No='"+reqBean.getCardNo()+"' or c.sub_Card_No='"+reqBean.getCardNo()+"'))");
					}
				}else if("2".equals(reqBean.getClientType())){
					if(new Long(Tools.processNull(this.findOnlyFieldBySql("select to_char(pwd_Err_Num) from BaseMerchant b " + "where b.biz_Id='"+reqBean.getBizId()+"'")))>=3)
						throw new CommonException("密码错误次数已经超过5次！");
					pwd = this.findOnlyRowByHql("from BaseMerchant b where b.biz_Id='"+reqBean.getBizId()+"' and b.serv_Pwd='"+reqBean.getPwd()+"'");
					if(pwd==null)
						publicDao.doSql("update BaseMerchant b set pwd_Err_Num=pwd_Err_Num+1 where b.biz_Id='"+reqBean.getBizId()+"' ");
				}
			}else if(Tools.processNull(reqBean.getPwdType()).equals("2")) {//账户交易密码判断
				if(new Long(Tools.processNull(this.findOnlyFieldBySql("select to_char(pwd_Err_Num) from Cm_Pwd b " +
						"where exists (select 1 from  CardBaseinfo c where p.pwd_No=c.card_No and (c.card_No='"+reqBean.getCardNo()+
						"' or c.sub_Card_No='"+reqBean.getCardNo()+"'))")))>=3)
					throw new CommonException("密码错误次数已经超过3次！");
				//密码主体类型：0-网点1-个人卡 2-单位 3-商户4-机构   正好跟reqBean.getClientType()定义匹配
				pwd=(CardBaseinfo)this.findOnlyRowByHql("select c from CardBaseinfo c where card_No='"+
						this.encryptPin(reqBean.getPwd(),reqBean.getCardNo())+"' and (c.card_No='"+reqBean.getCardNo()+
						"' or c.sub_Card_No='"+reqBean.getCardNo()+"')");
				publicDao.doSql("update CardBaseinfo p set pwd_Err_Num=pwd_Err_Num+1 where exists " +
						"(select 1 from  c where p.pwd_No=c.card_No and (c.card_No='"+reqBean.getCardNo()+
						"' or c.sub_Card_No='"+reqBean.getCardNo()+"'))");
			}else if(Tools.processNull(reqBean.getPwdType()).equals("3")) {//网上支付密码判断
				if(new Long(Tools.processNull(this.findOnlyFieldBySql("select to_char(netpwd_Err_Num) from Cm_Pwd p " +
						"where exists (select 1 from  c where p.pwd_No=c.card_No and (c.card_No='"+reqBean.getCardNo()+
						"' or c.sub_Card_No='"+reqBean.getCardNo()+"'))")))>=3)
					throw new CommonException("密码错误次数已经超过3次！");
				pwd=(CardBaseinfo)this.findOnlyRowByHql("select c from CardBaseinfo c where p.pwd_No=c.card_No and p.net_Pwd=='"+
						this.encryptPin(reqBean.getPwd(),reqBean.getCardNo())+"' and (c.card_No='"+reqBean.getCardNo()+
						"' or c.sub_Card_No='"+reqBean.getCardNo()+"') and p.pwd_Type='"+reqBean.getClientType()+"'");
				
			}else{
				throw new CommonException("不支持当前密码类型判断！");
			}
			if(pwd!=null)
				eqs=true;
			else
				throw new CommonException("密码错误！");
			return createReturnXml(new ResponseBean("0",eqs?"true":"false"), getMethodName(1),true,reqBean);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	/**
	 * 修改（重置）个人或商户 密码
	 * @param inXml 参数说明详见接口说明文档
	 * @return
	 * @throws CommonException
	 */
	public synchronized String modifyPwd(String inXml) throws CommonException {
		try {
			RequestBean reqBean=(RequestBean)this.xml2java("modifyPwd",inXml, "RequestBean", InNetRequestBean.class);
			// 先验证
			if (!("1".equals(reqBean.getModType()) || "2".equals(reqBean.getModType())))
				throw new CommonException("参数modType不正确！");
			if(Tools.processNull(reqBean.getNewPwd()).equals(""))
				throw new CommonException("参数newPwd不能为空！");
			if (reqBean.getModType().equals("1") && Tools.processNull(reqBean.getOldPwd()).equals(""))
				throw new CommonException("参数oldPwd不能为空！");
			if (!("1".equals(reqBean.getPwdType()) || "2".equals(reqBean.getPwdType()) || "3".equals(reqBean.getPwdType())))
				throw new CommonException("参数pwdType不正确！");

			if("1".equals(reqBean.getClientType())){
				validCardnoAndCertnoAndCardTye(reqBean);// 先验证
				//密码3des解密
				if(!Tools.processNull(reqBean.getOldPwd()).equals("")){
					if(!Tools.processNull(reqBean.getCardNo()).equals(""))
						reqBean.setOldPwd(decrypt_3DES(reqBean.getOldPwd(),reqBean.getCardNo()));//密码解密，卡号作为key
					if(!Tools.processNull(reqBean.getCertNo()).equals(""))
						reqBean.setOldPwd(decrypt_3DES(reqBean.getOldPwd(),reqBean.getCertNo().toUpperCase()));//密码解密，卡号作为key
				}
				if(!Tools.processNull(reqBean.getNewPwd()).equals("")){
					if(!Tools.processNull(reqBean.getCardNo()).equals(""))
						reqBean.setNewPwd(decrypt_3DES(reqBean.getNewPwd(),reqBean.getCardNo()));//密码解密，卡号作为key
					if(!Tools.processNull(reqBean.getCertNo()).equals(""))
						reqBean.setNewPwd(decrypt_3DES(reqBean.getNewPwd(),reqBean.getCertNo().toUpperCase()));//密码解密，卡号作为key
					checkGegex(reqBean.getNewPwd());
				}
				modifyPwd_Person(reqBean);
			}else if("2".equals(reqBean.getClientType())){
				if(Tools.processNull(reqBean.getBizId()).equals(""))
					throw new CommonException("参数bizId不能为空！");
				//密码3des解密
				if(!Tools.processNull(reqBean.getOldPwd()).equals(""))
					reqBean.setOldPwd(decrypt_3DES(reqBean.getOldPwd(),reqBean.getBizId()));//密码解密，商户号作为key
				if(!Tools.processNull(reqBean.getNewPwd()).equals("")){
					reqBean.setNewPwd(decrypt_3DES(reqBean.getNewPwd(),reqBean.getBizId()));//密码解密，商户号作为key
					checkGegex(reqBean.getNewPwd());
				}
				modifyPwd_Merchant(reqBean);
			}else 
				throw new CommonException("参数clientType不正确！");
			return createReturnXml(new ResponseBean("0",""), getMethodName(1),true,reqBean);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	/**
	 * 挂失
	 * @param inXml 参数说明详见接口说明文档
	 * @return
	 * @throws CommonException
	 */
	public synchronized String reportLoss(String inXml) throws CommonException {//挂失是通过身份证号来挂失的
		JSONArray return_parameters=null;
		try {
			RequestBean reqBean=(RequestBean)this.xml2java("reportLoss",inXml, "RequestBean", InNetRequestBean.class);
			if (Tools.processNull(reqBean.getLssFlag()).equals("")){
				reqBean.setLssFlag("0");
			}
			BasePersonal person = findPersonByCertNo( reqBean.getCertNo());
			String hql="select c from CardBaseinfo c,BasePersonal b where c.customer_Id=b.customer_Id and  c.customer_Id='"+person.getCustomerId()+"' and c.card_State<>'0' and c.card_State<>'9'";
			if(!Tools.processNull(reqBean.getCardNo()).equals(""))
				hql+=" and (c.card_No='"+reqBean.getCertNo()+"' or c.sub_Card_No='"+reqBean.getCertNo()+"' or b.cert_No='"+reqBean.getCertNo()+"')";
			if(!Tools.processNull(reqBean.getCardType()).equals(""))
				hql+=" and  card_Type='"+reqBean.getCardType()+"'";	
			List list=this.findByHql(hql);
			for (int i = 0; i < list.size(); i++) {
				CardBaseinfo card=(CardBaseinfo) list.get(i);
				JSONArray inParameter = new JSONArray();
				JSONObject onepara = new JSONObject();
				onepara.put("trcode","P005");//
				onepara.put("cardno",Tools.processNull(card.getCardNo()));//卡号
				onepara.put("telno",Tools.processNull(reqBean.getTelNo()));//卡号
				onepara.put("certno",Tools.processNull(reqBean.getCertNo()));//身份证号
				onepara.put("flag",Tools.processNull(reqBean.getLssFlag()));//标志
				inParameter.add(onepara);
				return_parameters = doWorkClientService.invoke_Outer(inParameter);
				if(return_parameters == null || return_parameters.isEmpty()){
					throw new CommonException("获取记录返回null");
				}
				JSONObject return_first = return_parameters.getJSONObject(0);
				if(return_first == null || return_first.isEmpty()){
					throw new CommonException("获取节点为空！");
				}
				if(!Tools.processNull(return_first.getString("errcode")).equals("00")){
					throw new CommonException(Tools.processNull(return_first.getString("errmessage")));
				}
			}
			return createReturnXml(new ResponseBean("0",""), getMethodName(1),true,reqBean);
		} catch (Exception e) {
			//统一返回异常消息
			throw new CommonException(e.getMessage().indexOf("挂失失败，")==0?e.getMessage().substring(5):e.getMessage());
		}
	}
	/**
	 * 余额查询
	 */
	
	public synchronized String queryBal(String inXml) throws CommonException {
		// 查询当前卡对应的所有状态为正常的账户信息
		 CardBaseinfo card=null;
		try {
			RequestBean reqBean=(RequestBean)this.xml2java("queryBal",inXml, "RequestBean", InNetRequestBean.class);
			validCardnoAndCertnoAndCardTye(reqBean);// 先验证
			initBaseQueryData(reqBean);//初始卡号和还原个人密码
			card=findCardByCardnoAndCertNo(reqBean.getCardNo(),reqBean.getCertNo(),reqBean.getCardType());
			if(card!=null){
				if(!Tools.processNull(card.getMainCardNo()).equals("")&&Tools.processNull(card.getMainFlag()).equals("1")){//0为主卡，1为副卡
					card=(CardBaseinfo)this.findOnlyRowByHql(" from  CardBaseinfo c where c.cardNo='"+card.getMainCardNo()+"'");
				}
			}
			
			String sql = "select acc_kind," + SqlTools.divHundred("bal") + " , "+
				SqlTools.divHundred("bal-frz_amt") +" , "+ SqlTools.divHundred("frz_amt") +","+
				" acc_no from Acc_Account_Sub a, CardBaseinfo c where 1=1 ";
			//sql += " acc_state=" + GlobalConst.STATE_ZC + " and a.card_no=c.card_no";
			sql += "  and a.card_no=c.card_no";
			sql += " and c.card_No='" + card.getCardNo() + "'";
			sql +=" and card_State not in('0','9')";
			sql += SqlTools.eq("a.acc_kind",Constants.getAccKind(reqBean.getAccKind()));//账户类型
			List list = this.findBySql(sql);
			if (list == null || list.size() == 0){
				throw new CommonException("查询客户账户信息失败，账户信息不存在或状态不为正常状态，或提供信息不正确！");
			}
			ArrayList datas=new ArrayList();
			//参数指定查询押金账户，或不指定账户类型时，才查询押金账户

			for (int i = 0; i < list.size(); i++) {//其它账户信息
				Data data=new Data();
				data.setAccNo(Tools.processNull(((Object[]) list.get(i))[4]));//账户号
				data.setAccKind(Tools.processNull(((Object[]) list.get(i))[0]));
				data.setAccKindName( super.getCodeNameBySYS_CODE("ACC_KIND", data.getAccKind()));
				data.setAccBal(((Object[]) list.get(i))[1].toString());
				data.setAccUsableBal(Tools.processNull(((Object[]) list.get(i))[2]));//可用余额
				data.setAccUnUsableBal(Tools.processNull(((Object[]) list.get(i))[3]));
				datas.add(data);
			}
			return createReturnXml(new ResponseBean("0","",datas), getMethodName(1),true,reqBean);
		} catch (Exception e) {
			throw new CommonException(e.toString());
		}
	}
	/**
	 * 查询交易记录
	 */
	public synchronized String queryTransDetail(String inXml) throws CommonException {
		JSONArray return_parameters=null;
		JSONObject return_first=null;
		JSONObject dataobj=null;
		try {
			InNetRequestBean reqBean=(InNetRequestBean)this.xml2java("queryTransDetail",inXml, "RequestBean", InNetRequestBean.class);
			JSONArray inParameter = new JSONArray();
			JSONObject onepara = new JSONObject();
			onepara.put("trcode","P009");//
			onepara.put("cardno",Tools.processNull(reqBean.getCardNo()));//卡号
			onepara.put("trtype",Tools.processNull(reqBean.getTrKind()).equals("")?"0":reqBean.getTrKind());//交易类型，暂定0查询所有，1是查询充值，2是查询消费，3 圈存圈提，缺省为0
			onepara.put("startdate",Tools.processNull(reqBean.getStartDate()));//起始时间
			onepara.put("enddate",Tools.processNull(reqBean.getEndDate()));//结束时间
			onepara.put("pageno",Tools.processNull(reqBean.getPageNo()));//页面
			onepara.put("pcount",Tools.processNull(reqBean.getPCount()));//总记录
	
			inParameter.add(onepara);
			return_parameters = doWorkClientService.invoke_Outer(inParameter);
			if(return_parameters == null || return_parameters.isEmpty()){
				throw new CommonException("获取记录返回null");
			}
			Long totCount=Tools.processLong(return_parameters.getJSONObject(0).getString("totCount"));
			String dataArray=Tools.processNull(return_parameters.getJSONObject(0).getString("datas"));
			List<Map<String, Object>> listmap= JsonHelper.parseJSON2List(dataArray);
			ArrayList datas=new ArrayList();
			if (listmap != null && listmap.size() > 0) {
				for (int i = 0; i < listmap.size(); i++) {
					Data data=new Data();
					Map<String, Object> mapObject=listmap.get(i);
				     //trname:交易名, acptname :受理点名称,accname:户名,actionno:交易流水,bal:交易前余额,amt:交易发生额,trdate:交易时间
				     //":"[{\"trname\":\"市民卡账户现金充值\",\"acptname \":\"中心营业大厅\",\"accname\":\"02\",\"actionno\":\"136023\",\"bal\":\"3090.26\",\"amt\":\"10\",\"trdate\":\"2016-03-16 17:44:31
					data.setTrDate(Tools.processNull(mapObject.get("trdate")));
					data.setAcptName(Tools.processNull(mapObject.get("acptname")));
					data.setAccNo(Tools.processNull(mapObject.get("errcode")).equals("")?"":Tools.processNull(mapObject.get("errcode")));
					data.setAccKindName(Tools.processNull(mapObject.get("accname")).equals("02")?"市民卡帐户":"市民卡钱包");
					data.setTrCodeName(Tools.processNull(mapObject.get("trname")));
					data.setAccBalBef(Tools.processNull(mapObject.get("bal")));
					data.setAmtIn(Tools.processNull(mapObject.get("amt")));
					data.setAmtOut(Tools.processNull(mapObject.get("bal")));
					data.setAccBalAft(Tools.processNull(mapObject.get("bal")));
					data.setTrState("0");
					data.setTrStateName(super.getCodeNameBySYS_CODE("BOOK_STATE", "0"));
					data.setAccName(Tools.processNull(super.getCodeNameBySYS_CODE("BOOK_STATE", Tools.processNull(mapObject.get("accname")))));
					datas.add(data);
				}
			}
			return createReturnXml(new ResponseBean("0", "", totCount, datas),getMethodName(1),true,reqBean);
		} catch (Exception e) {
			throw new CommonException(e.toString());
		}
	}

	/**
	 * 查询卡状态
	 * 
	 */
	public synchronized String queryCardState(String inXml) throws CommonException {
		try {
			ArrayList datas=new ArrayList();
			RequestBean reqBean=(RequestBean)this.xml2java("queryCardState",inXml, "RequestBean", InNetRequestBean.class);
			//本查询，要么以卡号来查询，要么以证件号+客户姓名来查询，要么以证件号码+卡类型来查询
			if(Tools.processNull(reqBean.getCardNo()).equals("")){
				initBaseQueryData(reqBean);//初始卡号和还原个人密码
			}
			String hql = "select c.card_state,a.card_no,p.reside_type,a.apply_state,a.sub_card_no,bs.emp_name "+
			" from  CardBaseinfo c,card_apply a,BasePersonal p,BaseCorp bs "+
			" where c.card_no(+) = a.card_no and a.customer_Id=p.customer_Id  and a.corp_Id=bs.customer_Id(+)  and a.apply_state <> '09' ";
			if(!Tools.processNull(reqBean.getCardNo()).equals("")){
				hql +=" and (c.card_No='"+reqBean.getCardNo()+"' or c.sub_Card_No='"+reqBean.getCardNo()+"')";
			}
			if(!Tools.processNull(reqBean.getCertNo()).equals("") || !Tools.processNull(reqBean.getClientName()).equals("")){
				hql += SqlTools.eq("p.cert_No", reqBean.getCertNo());
				hql += SqlTools.eq("p.name",reqBean.getClientName());
			}
			
			List<Object[]> list=findBySql(hql);
			if(list!=null && list.size()>0){
				for(Object[] objs:list){
					Data data=new Data();
					//data.setCardNo(Tools.processNull(objs[1]));
					data.setCardNo(Tools.processNull(objs[4]));//当作社保卡号
					data.setSubCardNo(Tools.processNull(objs[4]));//社保卡号
					data.setCardType(Tools.processNull(objs[2]));//当作户籍类型
					data.setEmpName(Tools.processNull(objs[5]));//单位名称
					data.setCardTypeName(super.getCodeNameBySYS_CODE("RESIDE_TYPE", Tools.processNull(objs[2])));//户籍类型（0市民卡1新居民卡）
					//cardstate这个字段结构改为两位数字，第一位:1申领状态，2卡状态，第二位：状态值
					//在卡未发放(申领状态<=5)前返回申领状态，发放后返回卡状态
					if(!Tools.processNull(objs[3]).equals("") && Tools.processInt(objs[3]+"")<=Tools.processInt("01")){//取申领状态
						data.setCardState("1"+objs[3]);
						data.setCardStateName(super.getCodeNameBySYS_CODE("APPLY_STATE",Tools.processNull(objs[3])));
					}else {//取卡状态
						data.setCardState("2"+Tools.processNull(objs[0]));//
						data.setCardStateName(super.getCodeNameBySYS_CODE("CARD_STATE", Tools.processNull(objs[0])));
					}
					datas.add(data);
				}
				return createReturnXml(new ResponseBean("0", "", new Long(list == null ? '0' : list.size()), datas),getMethodName(1),true,reqBean);
			}else{
				throw new CommonException("卡信息不存在，提供信息不正确！");
			}
		} catch (Exception e) {
			throw new CommonException(e.toString());
		}
	}
	
	/**
	 * 圈存限额修改
	 */
	public String qcxeedit(String inXml) throws CommonException {
		try {
			
			return createReturnXml(new ResponseBean("0","",""), getMethodName(1),true,null);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	
	/**
	 *  
	 *  圈存充值(银行到联机账户)--自助设备
	 */
	public String earmarkCharge(String inXml) throws CommonException {
		String action_no="";
		try {
			InNetRequestBean reqBean=(InNetRequestBean)this.xml2java("earmarkCharge",inXml, "RequestBean", InNetRequestBean.class);
	
			
			
			return createReturnXml(new ResponseBean("0","",action_no), getMethodName(1),true,reqBean);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
   /**
    * 充值
    * @param inXml 参数说明详见接口说明文档
	* @return CommonException
    */
	public String charge(String inXml) throws CommonException {
		String  actionNo="";
		try {
			InNetRequestBean reqBean=(InNetRequestBean)this.xml2java(inXml, "RequestBean", InNetRequestBean.class);
			//validateSjsmkMac(reqBean);//验证mac
			if(Tools.processNull(reqBean.getWalletId()).equals("")){
				reqBean.setWalletId("00");
			}
			if (Tools.processNull(reqBean.getCardNo()).equals("")&& Tools.processNull(reqBean.getTrKind()).equals("")&& Tools.processNull(reqBean.getAmt()).equals("")&& Tools.processNull(reqBean.getTrNum()).equals("")){
				throw new CommonException("参数cardNo、trKind、amt,trNum都不能为空！");
			}
			CardBaseinfo card = findCardByCardnoAndCertNo(reqBean.getCardNo(),reqBean.getCertNo(),reqBean.getCardType());
			BasePersonal person = (BasePersonal)this.findOnlyRowByHql(" from BasePersonal where customer_Id = '"+card.getCustomerId()+"'");
			int trnum=reqBean.getTrNum().length();
			if(reqBean.getTrKind().equals("0")){//现金充值到联机账户
				actionNo=XjTolj(reqBean,person,card);//手机市民卡和自助设备
			}else if(reqBean.getTrKind().equals("1")){//现金充值---脱机账户
				actionNo=XjTotj(reqBean,person,card);
			}else{
				throw new CommonException("参数trKind错误！");
			}
			return createReturnXml(new ResponseBean("0","",actionNo), getMethodName(1),true,reqBean);
		} catch (Exception e) {
			throw new CommonException(e.toString());
		}
	}
	   /**
	    * 充值-自助设备
	    * @param inXml 参数说明详见接口说明文档
		* @return CommonException
	    */
	public String chargeAuto(String inXml) throws CommonException {
		String  actionNo="";
		try {
			InNetRequestBean reqBean=(InNetRequestBean)this.xml2java("chargeAuto",inXml, "RequestBean", InNetRequestBean.class);
			//validateSjsmkMac(reqBean);//验证mac
			if(Tools.processNull(reqBean.getWalletId()).equals("")){
				reqBean.setWalletId("00");
			}
			if (Tools.processNull(reqBean.getCardNo()).equals("")&& Tools.processNull(reqBean.getTrKind()).equals("")&& Tools.processNull(reqBean.getAmt()).equals("")&& Tools.processNull(reqBean.getTrNum()).equals("")){
				throw new CommonException("参数cardNo、trKind、amt,trNum都不能为空！");
			}
			CardBaseinfo card = findCardByCardnoAndCertNo(reqBean.getCardNo(),reqBean.getCertNo(),reqBean.getCardType());
			BasePersonal person = (BasePersonal)this.findOnlyRowByHql(" from BasePersonal where customer_Id = '"+card.getCustomerId()+"'");
			if(reqBean.getTrKind().equals("0")){//现金充值到联机账户
				actionNo=XjTolj(reqBean,person,card);//现金充值到联机账户
			}else if(reqBean.getTrKind().equals("1")){//现金充值---脱机账户
				actionNo=XjTolj(reqBean,person,card);
			}else{
				throw new CommonException("参数trKind错误！");
			}
			return createReturnXml(new ResponseBean("0","",actionNo), getMethodName(1),true,reqBean);
		} catch (Exception e) {
			throw new CommonException(e.toString());
		}
	}
	
	/**
	 * 充值确认（确认，冲正）---手机市民卡
	 * @param inXml 参数说明详见接口说明文档
	 * @return CommonException
	 */
	public String czqrorcz(String inXml)throws CommonException {
		String trNum="";
		String terminalId="";//终端号
		String OperId="";
		String dealNo="";
		JSONArray return_parameters = null;
		try {
			InNetRequestBean reqBean=(InNetRequestBean)this.xml2java("czqrorcz",inXml, "RequestBean", InNetRequestBean.class);
			if(Tools.processNull(reqBean.getActionNo()).equals("")||Tools.processNull(reqBean.getTrKind()).equals(""))
				throw new CommonException("中心交易流水号或交易类别都不能为空！");
			//trKind交易类别：0表示对钱包充值确认，1表示冲正,2,表示撤销
			int trnum=reqBean.getActionNo().length();
			trNum=reqBean.getActionNo();
			terminalId=reqBean.getTerminalId();//自助设备的
			if(Tools.processNull(reqBean.getTrKind()).equals("0")){//0表示对钱包充值确认，1表示冲正,2,表示撤销
				OperId="admin";
				JSONArray inParameter = new JSONArray();
				JSONObject onepara = new JSONObject();
				onepara.put("trcode","P016");//2.16联机账户充值冲正(P012)
				onepara.put("cardno",Tools.processNull(reqBean.getCardNo()));//卡号
				onepara.put("amt",Tools.processNull(reqBean.getAmt()));//金额
				onepara.put("tradeno",Tools.processNull(reqBean.getCertNo()));//交易流水
				onepara.put("trdate", Tools.processNull(reqBean.getCardNo()));//交易日期(yyyymmdd)
				onepara.put("trtime", Tools.processNull(reqBean.getCardNo()));//交易时间(hhmmss)
				onepara.put("bankcardno", Tools.processNull(reqBean.getCardNo()));//银行卡号
				onepara.put("bizid", Tools.processNull(reqBean.getCardNo()));//机构号
				onepara.put("actionno", Tools.processNull(OperId));//操作员号
				onepara.put("cardtradeno", Tools.processNull(OperId));//卡交易序号
				onepara.put("premoney", Tools.processNull(OperId));//交易前金额
				onepara.put("walletid", "00");//钱包编号00
				onepara.put("random", Tools.processNull(OperId));//随机数
				onepara.put("tradetype", Tools.processNull(OperId));//操作员号
				onepara.put("tac", Tools.processNull(OperId));//操作员号
				onepara.put("psamcardno", Tools.processNull(OperId));//psam卡号	
				
				inParameter.add(onepara);
				return_parameters = doWorkClientService.invoke_Outer(inParameter);
				if(return_parameters == null || return_parameters.isEmpty()){
					throw new CommonException("获取记录返回null");
				}
				JSONObject return_first = return_parameters.getJSONObject(0);
				if(return_first == null || return_first.isEmpty()){
					throw new CommonException("获取节点为空！");
				}
				if(!Tools.processNull(return_first.getString("errcode")).equals("00")){
					throw new CommonException(Tools.processNull(return_first.getString("errmessage")));
				}
				
				dealNo=Tools.processNull(return_first.getString("dealNo"));
			}
			
			return createReturnXml(new ResponseBean("0",""), getMethodName(1),true,reqBean);
		} catch (Exception e) {
			throw new CommonException(e.toString());
		}
	}
	/**
	 * 现金到联机账户
	 * @param reqBean 参数说明详见接口说明文档
	 * @return actionNo
	 */
	public String  XjTolj(InNetRequestBean reqBean,BasePersonal person,CardBaseinfo card) {
		String walletId = "00";//钱包
		String chargeFlag = "0";
		String actionNo="";
		String biz_id="";//商户号
		String trNum="";//对方的交易流水号
		String terminalId="";//终端号
		String acptId="";
		String OperId="";
		JSONArray return_parameters = null;
		SysActionLog actionlog=null;
		try{
			terminalId=reqBean.getTerminalId();//自助设备的
			acptId="admin";
			biz_id = (String)this.findOnlyFieldBySql("select brch_id from Sys_Users t where t.oper_id = '" + reqBean.getTerminalId() + "'");
			//OperId=!reqBean.getTerminalId().equals("AutoOperId")?AutoOperId:reqBean.getTerminalId();//自动终端完全走柜员模式AutoOperId;
			OperId="admin";
			JSONArray inParameter = new JSONArray();
			JSONObject onepara = new JSONObject();
			onepara.put("trcode","P011");//2.15联机账户充值(P011)
			onepara.put("cardno",Tools.processNull(reqBean.getCardNo()));//卡号
			onepara.put("amt",Tools.processNull(reqBean.getAmt()));//金额
			onepara.put("tradeno",Tools.processNull(reqBean.getCertNo()));//交易流水
			onepara.put("trdate", Tools.processNull(reqBean.getCardNo()));//交易日期(yyyymmdd)
			onepara.put("trtime", Tools.processNull(reqBean.getCardNo()));//交易时间(hhmmss)
			onepara.put("bankcardno", Tools.processNull(reqBean.getCardNo()));//银行卡号
			onepara.put("bizid", Tools.processNull(reqBean.getCardNo()));//机构号
			onepara.put("operid", Tools.processNull(OperId));//操作员号
			inParameter.add(onepara);
			return_parameters = doWorkClientService.invoke_Outer(inParameter);
			if(return_parameters == null || return_parameters.isEmpty()){
				throw new CommonException("获取记录返回null");
			}
			JSONObject return_first = return_parameters.getJSONObject(0);
			if(return_first == null || return_first.isEmpty()){
				throw new CommonException("获取节点为空！");
			}
			if(!Tools.processNull(return_first.getString("errcode")).equals("00")){
				throw new CommonException(Tools.processNull(return_first.getString("errmessage")));
			}
			actionlog=this.createActionlog("30101020", OperId, OperId, reqBean);
			publicDao.save(actionlog);//插入日志信息
			actionNo=Tools.processNull(return_first.getString("dealNo"));
			if(Tools.processLong(actionNo)==0){
				throw new CommonException("充值失败");
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionlog.getDealNo());
			rec.setDealCode(actionlog.getDealCode());
			rec.setBizTime(actionlog.getDealTime());
			rec.setUserId(actionlog.getUserId());
			rec.setCardNo(card.getCardNo());
			rec.setDealState("0");
			rec.setCertNo(person.getCertNo());
			rec.setCustomerId(person.getCustomerId()+"");
			rec.setCustomerName(person.getName());
			rec.setAmt(reqBean.getAmt());
			rec.setBrchId("10010001");
			rec.setNote("现金充值。卡号："+card.getCardNo()+",金额："+new Long(Arith.cardmoneymun(Tools.processNull(reqBean.getAmt()))));
			publicDao.save(rec);
		} catch (Exception e) {
		   throw new CommonException(e.toString());
	    }
		return actionNo;
		
	}
	/**
	 * 现金到脱机账户
	 * @param reqBean 参数说明详见接口说明文档
	 * @return actionNo
	 */
	public String  XjTotj(InNetRequestBean reqBean,BasePersonal person,CardBaseinfo card) {
		String actionNo="";
		String terminalId="";//终端号
		String biz_id="";//商户号
		String acptId="";
		String OperId="";
		JSONArray return_parameters = null;
		SysActionLog actionlog=null;
		try{
			terminalId=reqBean.getTerminalId();//自助设备的
			//acptId=AutoBrchId;
			biz_id = (String)this.findOnlyFieldBySql("select brch_id from Sys_Users t where t.oper_id = '" + reqBean.getTerminalId() + "'");
			OperId=reqBean.getTerminalId();//自动终端完全走柜员模式AutoOperId;
			JSONArray inParameter = new JSONArray();
			JSONObject onepara = new JSONObject();
			onepara.put("trcode","P016");//
			onepara.put("cardno",Tools.processNull(reqBean.getCardNo()));//卡号
			onepara.put("telNo",Tools.processNull(reqBean.getTelNo()));//卡号
			onepara.put("certNo",Tools.processNull(reqBean.getCertNo()));//卡号
			inParameter.add(onepara);
			return_parameters = doWorkClientService.invoke_Outer(inParameter);
			if(return_parameters == null || return_parameters.isEmpty()){
				throw new CommonException("获取记录返回null");
			}
			JSONObject return_first = return_parameters.getJSONObject(0);
			if(return_first == null || return_first.isEmpty()){
				throw new CommonException("获取节点为空！");
			}
			if(!Tools.processNull(return_first.getString("errcode")).equals("00")){
				throw new CommonException(Tools.processNull(return_first.getString("errmessage")));
			}
			actionlog=this.createActionlog("30101020", OperId, OperId, reqBean);
			publicDao.save(actionlog);//插入日志信息
			actionNo=Tools.processNull(return_first.getString("dealNo"));
			if(Tools.processLong(actionNo)==0){
				throw new CommonException("充值失败");
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionlog.getDealNo());
			rec.setDealCode(actionlog.getDealCode());
			rec.setBizTime(actionlog.getDealTime());
			rec.setUserId(actionlog.getUserId());
			rec.setCardNo(card.getCardNo());
			rec.setDealState("0");
			rec.setCertNo(person.getCertNo());
			rec.setCustomerId(person.getCustomerId()+"");
			rec.setCustomerName(person.getName());
			rec.setAmt(reqBean.getAmt());
			rec.setBrchId("10010001");
			rec.setNote("现金充值。卡号："+card.getCardNo()+",金额："+new Long(Arith.cardmoneymun(Tools.processNull(reqBean.getAmt()))));
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e.toString());
		}
		
		return actionNo.toString();
	}

	/**
	 * 修改个人客户密码信息，供本类调用
	 * @param reqBean
	 */
	private Long modifyPwd_Person(RequestBean reqBean) {
		if (reqBean.getModType().equals("2") && Tools.processNull(reqBean.getCertNo()).equals("")){
			throw new CommonException("重置密码时参数cert_No不能为空！");
		}
		CardBaseinfo card = findCardByCardnoAndCertNo(reqBean.getCardNo(),reqBean.getCertNo(),reqBean.getCardType());
		SysActionLog actionlog =new SysActionLog();
		if (reqBean.getPwdType().equals("1")) {// 服务密码
			BasePersonal person = null;
			if(!Tools.processNull(reqBean.getCardNo()).equals(""))
				person = findPersonByCardNo(reqBean.getCardNo());
			
			if(!Tools.processNull(reqBean.getCertNo()).equals("")){
				person=findPersonByCertNo(reqBean.getCertNo());
			}
			if(person==null)
				throw new CommonException("找不到个人的信息！");//验证传入证件是否与当前客户信息匹配
			if (reqBean.getModType().equals("1")) {// 修改
				//person.setServ_Pwd(reqBean.getNewPwd());//多余的-gecc
				actionlog= createActionlog("",reqBean.getOperId(),getMethodName(2),reqBean);// 业务日志对象
				updateServPwd(person.getCustomerId()+"", null, Tools.processNull(actionlog.getUserId()).equals("")?"admin":actionlog.getUserId(), actionlog, reqBean.getOldPwd(),reqBean.getNewPwd());
			} else {// 重置
				actionlog = createActionlog("",reqBean.getOperId(),getMethodName(2),reqBean);// 业务日志对象
				resetServPwd(person.getCustomerId()+"", null, Tools.processNull(actionlog.getUserId()).equals("")?"admin":actionlog.getUserId(), actionlog,reqBean.getNewPwd());
			}
		} else if (reqBean.getPwdType().equals("2")) {// 账户交易密码
			if (reqBean.getModType().equals("1")) {
				actionlog = createActionlog("",reqBean.getOperId(),getMethodName(2),reqBean);// 业务日志对象
				this.updatePwd(card.getCardNo(), null, Tools.processNull(actionlog.getUserId()).equals("")?"admin":actionlog.getUserId(), actionlog, reqBean.getOldPwd(),reqBean.getNewPwd());
			} else {
				actionlog = createActionlog("",reqBean.getOperId(),getMethodName(2),reqBean);// 业务日志对象
				this.resetPwd(card.getCardNo(), null, Tools.processNull(actionlog.getUserId()).equals("")?"admin":actionlog.getUserId(), actionlog,reqBean.getNewPwd());
			}
		} 
		return actionlog.getDealNo();
	}
	/**
	 * 修改个人商户密码信息，供本类调用
	 * @param reqBean
	 */
	private Long modifyPwd_Merchant(RequestBean bean) {
		InNetRequestBean reqBean=(InNetRequestBean)bean;
		BaseMerchant merchant = findMerchantByBizIdOrClientIdOrName(reqBean.getBizId(), reqBean.getClientId(), reqBean.getClientName());
		SysActionLog actionlog =new SysActionLog();
		if (reqBean.getPwdType().equals("1")) {// 服务密码
			if (reqBean.getModType().equals("1")) {// 修改
				actionlog = createActionlog("",reqBean.getOperId(),getMethodName(2),reqBean);// 业务日志对象
				this.updateDwServPwd(merchant.getCustomerId()+"", null, Tools.processNull(actionlog.getUserId()).equals("")?"admin":actionlog.getUserId(), actionlog, reqBean.getOldPwd(),reqBean.getNewPwd());
			} else {// 重置
				actionlog = createActionlog("","",getMethodName(2),reqBean);// 业务日志对象
				this.resetDwServPwd(merchant.getCustomerId()+"", null,  Tools.processNull(actionlog.getUserId()).equals("")?"admin":actionlog.getUserId(),actionlog, reqBean.getNewPwd());
			}
		}
		return actionlog.getDealNo();
	}
	/**
	 * 联机转脱机充值
	 */
	public String ljtoqbCharge(String inXml) throws CommonException {
		String actionNo="";
		String terminalId="";//终端号
		String biz_id="";//商户号
		String acptId="";
		String OperId="";
		JSONArray return_parameters = null;
		try{
			InNetRequestBean reqBean=(InNetRequestBean)this.xml2java("czqrorcz",inXml, "RequestBean", InNetRequestBean.class);
			JSONArray inParameter = new JSONArray();
			JSONObject onepara = new JSONObject();
			onepara.put("trcode","P004");//
			onepara.put("cardno",Tools.processNull(reqBean.getCardNo()));//卡号
			onepara.put("telNo",Tools.processNull(reqBean.getTelNo()));//卡号
			onepara.put("certNo",Tools.processNull(reqBean.getCertNo()));//卡号
			inParameter.add(onepara);
			return_parameters = doWorkClientService.invoke_Outer(inParameter);
			if(return_parameters == null || return_parameters.isEmpty()){
				throw new CommonException("获取记录返回null");
			}
			JSONObject return_first = return_parameters.getJSONObject(0);
			if(return_first == null || return_first.isEmpty()){
				throw new CommonException("获取节点为空！");
			}
			if(!Tools.processNull(return_first.getString("errcode")).equals("00")){
				throw new CommonException(Tools.processNull(return_first.getString("errmessage")));
			}
			actionNo=Tools.processNull(return_first.getString("dealNo"));
		} catch (Exception e) {
			throw new CommonException(e);
		}
		return actionNo;
	}
	/**
	 * 组装SysActionLog对象，操作员暂使用admin
     * @param trCode  交易代码
     * @param operid  操作员，一般使用“接口”，但特殊需要记账的调用acc的接口的必须使用“admin”
     * @param trCode  交易代码
     * @param methodName  接口方法名称
     * @param reqBean  入中参数bean,用于获取actionlog的in_out_data
	 */
	public SysActionLog createActionlog(String trCode,String operid,String methodName,RequestBean reqBean) throws CommonException{
		try {
			SysActionLog actionLog = new SysActionLog();
			if(Tools.processNull(reqBean.getNote()).equals(""))
				actionLog.setNote("外围系统调用接口"+methodName+"进行" + super.getCodeNameBySYS_CODE("TRCODE", trCode) + "操作");
			actionLog.setNote(Tools.processNull(actionLog.getNote())+Tools.processNull(reqBean.getNote()));
			actionLog.setUserId(Tools.processNull(operid).equals("")?"admin":operid);
			actionLog.setDealTime(Tools.processNull(reqBean.getTrDate()).equals("")?publicDao.getDateBaseTime():DateUtil.parse("yyyy-MM-dd HH:mm:ss", reqBean.getTrDate()));
			actionLog.setDealCode(Tools.processInt(trCode));
			actionLog.setLogType("0");
			actionLog.setCanRoll("0");
			actionLog.setRollFlag("0");
			actionLog.setMessage(actionLog.getNote());
			actionLog.setFuncName(actionLog.getNote());
			actionLog.setIp("127.0.0.1");
			actionLog.setInOutData(reqBean!=null?reqBean.toString():"");//这个字段必须补全，从reqbean中获取
//			if(reqBean instanceof TeleComRequestBean){
//				TeleComRequestBean bean=(TeleComRequestBean)reqBean;
//				actionLog.setUser_Id(bean.getOperId());
//			}
			return actionLog;
		} catch (Exception e) {
			throw new CommonException("根据入口参数信息组装SysActionLog信息异常 "+e.getMessage());
		}
	}
	
	public String getMethodName() {
		return methodName;
	}
	public void setMethodName(String methodName) {
		this.methodName = methodName;
	}
	
	public String getOper_Brch_Id() {
		return Oper_Brch_Id;
	}
	public void setOper_Brch_Id(String oper_Brch_Id) {
		Oper_Brch_Id = oper_Brch_Id;
	}
	public String getMethodName(int i) {
		methodName=new Exception().getStackTrace()[i].getClassName()+"["+new Exception().getStackTrace()[i].getMethodName()+"]";
		return methodName;
	}
	
	/**
	 * 用于检验必须为6位数字的正则表达式
	 * @param str
	 * @return
	 */
	public boolean checkGegex(String str){
        String regex="^[0-9]{6}$";

        boolean valid=false;
        if(Pattern.matches(regex, str)){
         valid=true;
        }else {
        	throw new CommonException("密码必须为6位整数！");
		}
        return valid;
    }
	/**
	 * 用于检验必须为6位数字的正则表达式
	 * @param str
	 * @return
	 */
	public String decrypt_3DES(String str,String key){
		try {
			return TripleDES.decrypt_3DES(str, MD5Util.crypt(key).substring(0,24).trim());
		}  catch (Exception e) {
			throw new CommonException("处理密码失败，密码格式不正确！");
		}
    }
	
	/**
	 * 验证卡号或手机号或证件号,供本类调用
	 * @param cardNo
	 * @param telNo
	 * @param certNo
	 */
	public void validCardnoAndTelnoAndCertno(String cardNo, String telNo, String certNo) {
		if (Tools.processNull(cardNo).equals("") && Tools.processNull(certNo).equals(""))
			throw new CommonException("参数cardNo、certNo必须有一项不为空！");
	}
	/**
	 * 验证卡号或证件号,供本类调用
	 * @param cardNo
	 * @param telNo
	 * @param certNo
	 */
	public void validCardnoAndCertno(String cardNo,String certNo) {
		if (Tools.processNull(cardNo).equals("") && Tools.processNull(certNo).equals("")){
			throw new CommonException("参数cardNo、certNo必须有一项不为空！");
		}
	}
	/**
	 * 根据卡号（或手机号）、证件号码查询卡信息，供本类调用
	 * @param telNo 手机号
	 * @param cardNo 卡号
	 * @param certNo 证件号
	 * @return 卡信息
	 */
	public CardBaseinfo findCardByCardnoAndCertNo(String cardNo,String certNo,String cardType) {
		validCardnoAndCertno(cardNo,certNo);// 先验证
		try {
			String hql = "select c from CardBaseinfo c,BasePersonal p where c.customerId=p.customerId and 1=1 ";
			if (!Tools.processNull(certNo).equals("")){
				hql += " and p.certNo='" + certNo + "'";
			}
			if (!Tools.processNull(cardType).equals("")){
				hql += " and c.cardType='" + cardType + "'";
			}
			if (!Tools.processNull(cardNo).equals("")){
				if(cardNo.length()==9){
					hql+=" and  c.subCardNo='"+cardNo+"'";
				}else if(cardNo.length()==20){
					hql+=" and c.cardNo='"+cardNo+"'";
				}else if(cardNo.length()==18){
					hql+=" and p.certNo='"+cardNo+"'";
				}
			}
		
			List<CardBaseinfo> list=this.findByHql(hql);
			if(list==null || list.size()==0)
				throw new CommonException("卡信息不存在，提供信息不正确！");
			else if(list.size()>0){//查询条件去掉卡状态，有可能会查询出多条卡信息，因此需要循环找出正常的卡信息
				for(CardBaseinfo card:list){
					if(!card.getCardState().equals("0") && !card.getCardState().equals("9") )
						return card;
				}
				throw new CommonException("卡状态不为正常状态！");
			}
		} catch (CommonException e) {
			throw new CommonException("查询卡信息失败，"+e.toString());
		}
		return null;
	}
	
	/**
	 * 根据卡号或手机号查询客户信息，供本类调用
	 * @param cardNo 卡号
	 * @return 客户基本信息
	 */
	public BasePersonal findPersonByCardNo(String cardNo) {
		BasePersonal person = null;
		String hql = "select p from BasePersonal p,CardBaseinfo c where p.customerId = c.customerId  ";
		if(!Tools.processNull(cardNo).equals("")){
			hql+=" and (c.cardNo='"+cardNo+"' or c.subCardNo='"+cardNo+"')";
		}
		hql+=") and p.customerState ='0'";
		List list=this.findByHql(hql);
		if (list == null || list.size() == 0)
			throw new CommonException("查询客户信息失败，客户信息不存在或状态不为正常状态，或提供信息不正确！");
		else if(list.size()>1)
			throw new CommonException("查询客户信息失败，查询到多条客户信息！");
		person = (BasePersonal) list.get(0);
		return person;
	}
	public void initBaseQueryData(RequestBean reqBean){
		//几种密码解密key的依据优先级：cardNo、certNo
		//呼叫中心他们传来的密码是身份号有X的小写的加密，我方库是大写的，必用小写来解密-gecc-20101109
		if(!Tools.processNull(reqBean.getPwd()).equals("")){
			if(!Tools.processNull(reqBean.getCardNo()).equals("")){
//				CardBaseinfo ccard = (CardBaseinfo)dao.findOnlyRowByHql(" from CardBaseinfo t where t.card_No='"+reqBean.getCardNo()+"' or t.sub_Card_No ='"+reqBean.getCardNo()+"' and t.card_State='1'");
//				reqBean.setCardNo(ccard.getCardNo());
				reqBean.setPwd(decrypt_3DES(reqBean.getPwd(),reqBean.getCardNo()));
			}
			else if(!Tools.processNull(reqBean.getCertNo()).equals(""))
				reqBean.setPwd(decrypt_3DES(reqBean.getPwd(), reqBean.getCertNo().toLowerCase()));
		}
		if(!Tools.processNull(reqBean.getOldPwd()).equals("")){
			if(!Tools.processNull(reqBean.getCardNo()).equals(""))
				reqBean.setPwd(decrypt_3DES(reqBean.getOldPwd(),reqBean.getCardNo()));
			else if(!Tools.processNull(reqBean.getCertNo()).equals(""))
				reqBean.setPwd(decrypt_3DES(reqBean.getOldPwd(), reqBean.getCertNo().toLowerCase()));
		}
		if(!Tools.processNull(reqBean.getNewPwd()).equals("")){
			if(!Tools.processNull(reqBean.getCardNo()).equals(""))
				reqBean.setPwd(decrypt_3DES(reqBean.getNewPwd(),reqBean.getCardNo()));
			else if(!Tools.processNull(reqBean.getCertNo()).equals(""))
				reqBean.setPwd(decrypt_3DES(reqBean.getNewPwd(), reqBean.getCertNo().toLowerCase()));
		}
		if(Tools.processNull(reqBean.getCardNo()).equals("") && !Tools.processNull(reqBean.getCertNo()).equals("")&&
				!Tools.processNull(reqBean.getCardType()).equals("")){
			String cardNo=Tools.processNull(this.findOnlyFieldBySql("select c.card_no from CardBaseinfo c,BasePersonal b " +
					"where c.client_id=b.client_id and b.cert_type='1' and c.card_type='"+reqBean.getCardType()+
					"' and b.cert_no='"+reqBean.getCertNo()+"'"));
			reqBean.setCardNo(cardNo);
		}
	}
	
	/**
	 * 根据商户编号或客户编号查询商户信息
	 * @param bizId
	 * @param clientId
	 * @param bizName
	 * @return
	 */
	public BaseMerchant findMerchantByBizIdOrClientIdOrName(String bizId, String clientId,String bizName) {
		try {
			if(Tools.processNull(bizId).equals("") && Tools.processNull(clientId).equals(""))
				throw new CommonException("参数bizId、clientId不能都为空！");
			String hql = "from BaseMerchant where bizState='0'";
			hql+=SqlTools.eq("customerId", clientId);
			hql+=SqlTools.eq("bizId", bizId);
			hql+=SqlTools.eq("bizName", bizName);
			BaseMerchant mer=(BaseMerchant)findOnlyRowByHql(hql);
//			if(mer==null)
//				throw new CommonException("商户信息不存在或状态不为正常状态，或提供信息不正确！");
			return mer;
		}  catch (Exception e) {
			throw new CommonException("查询商户信息失败，"+e.toString());
		}
	}
	
	
	/**
	 * 验证卡号或证件号,供本类调用
	 * 呼叫中心是通过身份证号和卡类型来操作业务
	 * @param cardNo
	 * @param telNo
	 * @param certNo
	 */
	public void validCardnoAndCertnoAndCardTye(RequestBean reqBean) {
		if (Tools.processNull(reqBean.getCardNo()).equals("") && Tools.processNull(reqBean.getCertNo()).equals(""))
			throw new CommonException("参数cardNo不能为空或certNo不能都为空！");
		if (Tools.processNull(reqBean.getCardNo()).equals("") && (Tools.processNull(reqBean.getCertNo()).equals("")))
			throw new CommonException("参数cardNo不能为空或certNo、cardType不能都为空！");
	}
	

	/**
	 * 交易密码加密，用于初始密码设置
	 * @param pwd 密码明文
	 * @param card_No 卡号
	 * @return
	 * @throws CommonException
	 */
	public String encryptPin(String pwd,String card_No) throws CommonException{
		if(Tools.processNull(pwd).equals(""))
			return "";
		if(Tools.processNull(card_No).equals("")){
			return "";
		}
		String str="";
		try{
			str=doWorkClientService.encrypt_PinPwd(card_No, pwd);
	        return str;
		}catch(Exception ex){
			throw new CommonException(ex);
		}
	} 

	
	/**
	 * 根据证件号码查询客户信息，供本类调用
	 * @param certNo 证件号
	 * @return 客户基本信息
	 */
	public BasePersonal findPersonByCertNo(String certNo) {
		if (Tools.processNull(certNo).equals("")){
			throw new CommonException("参数certNo不能为空！");// 先验证
		}
		BasePersonal person = null;
		try {
			String hql = "from BasePersonal p where p.certNo='" + certNo + "' and p.customerState ='0'";
			person = (BasePersonal) this.findOnlyRowByHql(hql);
			if (person == null){
				throw new CommonException("查询客户信息失败，客户信息不存在或状态不为正常状态，或提供信息不正确！");
			}
		} catch (Exception e) {
			throw new CommonException("查询客户信息失败，"+e.getMessage());
		}
		
		return person;
	}
	public String checkMac(String inXml) throws CommonException {
		// TODO Auto-generated method stub
		return null;
	}
	public String createReturnXml(ResponseBean resBean, String methodName, boolean isActionLog, RequestBean reqBean) throws CommonException {
		try {
			//记业务日志，对于查询的一些接口，业务方法并没有主动记日志，不便于以后查询，因此需要手工记日志
			if(isActionLog){
				//dao.insert(createActionlog("", Tools.processNull(reqBean.getOperId()), methodName,reqBean));
			}
			//记错误日志
			if ("1".equals(resBean.getResult())) {
				if(resBean.getMessage().indexOf("com.zt.common.CommonException:")==0)
					resBean.setMessage(resBean.getMessage().substring("com.zt.common.CommonException:".length()+1));
				resBean.setMessage(resBean.getMessage().replaceAll("com.zt.common.CommonException:", ""));
				resBean.seteCode("");
				SysErrLog errlog = new SysErrLog();
				errlog.setUserId("admin");
				errlog.setErrTime(new Timestamp(publicDao.getDateBaseTime().getTime()));
				errlog.setMessage("外围系统调用接口方法：" + methodName + "发生错误：" + resBean.getMessage()+"请求参数："+(reqBean==null?"未取到":reqBean.toString()));//异常时也将入口参数记录下来
				errlog.setMessage(errlog.getMessage().length()>1000?errlog.getMessage().substring(0,1000):errlog.getMessage());//截取长度，以免字段内容超长
				errlog.setIp("127.0.0.1");
				errlog.setErrType("0");
				publicDao.save(errlog);
			}
			return this.java2xml(resBean);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	
	/**
	 * 账户密码修改
	 * @param cardNo 卡号
	 * @param brch_id 操作员所属网点
	 * @param operid 操作员
	 * @param actionLog 业务日志
	 * @param oldPwd 旧密码
	 * @param newPwd 新密码
	 * @throws CommonException
	 */
	public TrServRec updatePwd(String cardNo, String brchid, String operid, SysActionLog actionLog,String oldPwd,String newPwd)  throws CommonException {
		try {
			// 查询卡信息，密码信息，验证旧密码是否正确
			CardBaseinfo card = (CardBaseinfo)this.findOnlyRowByHql(" from CardBaseinfo c where c.cardNo='"+cardNo+"'");
			BasePersonal person=(BasePersonal)findOnlyRowByHql("from BasePersonal t where t.customer_Id in (select tt.customer_Id from CardBaseinfo tt where tt.card_No='"+cardNo+"')");
			CardBaseinfo cardOther =null;//关联卡账户密码
			if(card==null || card.getPayPwd()==null){
				throw new CommonException("该客户还没有设置过账户密码，请先到账户密码重置中设置账户密码！");
			}
			
			//若当前卡是副卡，
			if("0".equals(card.getMainFlag()) && !"".equals(Tools.processNull(card.getMainCardNo()))){
				// 若是副卡时，则查找与其关联的主卡账户密码信息
				cardOther=(CardBaseinfo)findOnlyRowByHql("from CardBaseinfo t where t.mainCardNo='"+card.getMainCardNo()+"'");
				if(cardOther==null || cardOther.getPayPwd()==null){
					throw new CommonException("该客户还没有设置过关联卡账户密码，请先到账户密码重置中设置关联卡账户密码！");
				}
			}
			//若当前卡是主卡
			if("0".equals(card.getMainFlag())){
				CardBaseinfo subCard=(CardBaseinfo)this.findOnlyRowByHql("from CardBaseinfo where mainFlag='1' " +
						" and mainCardNo='"+card.getCardNo()+"' " +
						" and cardState not in('0','9')");
				if(subCard!=null){
					// 若是主卡时，则查找与其关联的副卡账户密码信息
					cardOther=(CardBaseinfo)findOnlyRowByHql("from CardBaseinfo t where t.mainCardNo='"+card.getMainCardNo()+"'");
					if(cardOther==null || cardOther.getPayPwd()==null){
						throw new CommonException("该客户还没有设置过关联卡账户密码，请先到账户密码重置中设置关联卡账户密码！");
					}
				}
			}
			
			if(!card.getPayPwd().equals(doWorkClientService.encrypt_MwPwd(cardNo, oldPwd))){
				throw new CommonException("原密码不正确！");//F605E07A66E95AEE
			}
			
			//保存系统操作日志
			actionLog.setDealCode(DealCode.PERSON_TRADEPWD_MODIFY);
			publicDao.save(actionLog);

			//保存业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo()); // 业务流水号
			rec.setBizTime(actionLog.getDealTime()); // 业务办理时间
			rec.setBrchId(brchid);
			rec.setUserId(operid);
			rec.setOldPwd(card.getPayPwd());
			rec.setNewPwd(doWorkClientService.encrypt_MwPwd(cardNo, newPwd));//加密码新密码
			rec.setDealState("0"); // 业务状态(0正常1撤销)
			rec.setNote("修改交易密码");
			rec.setDealCode(DealCode.PERSON_TRADEPWD_MODIFY); // 交易代码
			rec.setCustomerId(card.getCustomerId());
			rec.setCardNo(card.getCardNo());
			if(!Tools.processNull(person).equals("")){
				rec.setCertNo(person.getCertNo());
				rec.setCertType(person.getCertType());
				rec.setCustomerName(person.getName()); // 客户姓名
			}
			
			publicDao.save(rec);
			
			//更新密码信息
			card.setPayPwd(rec.getNewPwd());
			publicDao.update(card);
			
			//同时更新关联卡密码信息
			if(cardOther!=null){
				//cardOther.setPay_Pwd(this.encryptPin(newPwd, cardOther.getPay_Pwd()));
				cardOther.setPayPwd(doWorkClientService.encrypt_PinPwd(cardNo, newPwd));
				publicDao.update(cardOther);
			}
			
			//发送短信
			//shortMessageManager.saveMessage(card, person, null,actionLog,null, GlobalConst.SMS_TYPE_MMWH,null,null,0);
			return rec;
		} catch (CommonException e) {
			throw e;
		}
	}

	/**
	 * 账户密码重置
	 * @param cardNo 卡号
	 * @param brch_id 操作员所属网点
	 * @param operid 操作员
	 * @param actionLog 业务日志
	 * @throws CommonException
	 */
	public TrServRec resetPwd(String cardNo, String brchid, String operid, SysActionLog actionLog,String newPwd)throws CommonException {
		try {
			//查询卡信息和密码信息
			CardBaseinfo card = (CardBaseinfo)this.findOnlyRowByHql(" from CardBaseinfo c where c.cardNo='"+cardNo+"'");
			BasePersonal person=(BasePersonal)findOnlyRowByHql("from BasePersonal t where t.customer_Id in (select tt.customer_Id from CardBaseinfo tt where tt.card_No='"+cardNo+"')");
			CardBaseinfo cardOther =null;//关联卡账户密码
		
			// 若当前卡是副卡，
			if("0".equals(card.getMainFlag()) && !"".equals(Tools.processNull(card.getMainCardNo()))){
				// 若是副卡时，则查找与其关联的主卡账户密码信息
				cardOther=findMmByTypeAndIdNoValidate("1", card.getMainCardNo());
			}
			//若当前卡是主卡
			if("0".equals(card.getMainFlag())){
				CardBaseinfo subCard=(CardBaseinfo)this.findOnlyRowByHql("from CardBaseinfo where mainFlag='1' " +
						"and parent_Card_No='"+card.getCardNo()+"' " +
						"and card_State not in('0','9')");
				if(subCard!=null){
					// 若是主卡时，则查找与其关联的副卡账户密码信息
					cardOther=findMmByTypeAndIdNoValidate("1", subCard.getCardNo());
				}
			}

			//保存系统操作日志
			actionLog.setDealCode(DealCode.PERSON_TRADEPWD_RESET);
			publicDao.save(actionLog);

			//保存业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo()); // 业务流水号
			rec.setBizTime(actionLog.getDealTime()); // 业务办理时间
			rec.setBrchId(brchid);
			rec.setUserId(operid);
			rec.setOldPwd(card.getPayPwd());
			rec.setNewPwd(this.encryptPin(newPwd,cardNo));//网上密码加密码
			rec.setDealState("0"); // 业务状态(0正常1撤销)
			rec.setNote("重置密码");
			rec.setDealCode(actionLog.getDealCode()); // 交易代码
			rec.setCustomerId(card.getCustomerId());
			rec.setCardNo(card.getCardNo());
			rec.setCertNo(person.getCertNo());
			rec.setCertType(person.getCertType());
			rec.setCustomerName(person.getName()); // 客户姓名
			publicDao.save(rec);
			
			//更新密码信息
			card.setPayPwd(this.encryptPin(newPwd, card.getPayPwd()));
			publicDao.update(card);
			//发送短信
			return rec;
		} catch (CommonException e) {
			throw e;
		}
	}


	
	/**
	 * 单位/商户服务密码修改
	 * @param clientId 客户id，若是商户，则是对应的bizid
	 * @param brch_id 操作员所属网点
	 * @param operid 操作员
	 * @param actionlog 业务日志
	 * @param oldPwd 旧密码
	 * @param newPwd 新密码
	 * @throws CommonException
	 */
	public void updateDwServPwd(String clientId, String brchid, String operid, SysActionLog actionLog, String oldPwd,String newPwd)throws CommonException{
		try {
			String client_Type="";
			String sql="select * from (select customer_Id,corp_name,'2' client_type from base_corp t where customer_Id= '"+clientId+"' union "+
			"select customer_Id,merchant_name,'3' client_type from base_merchant t  where customer_Id='"+clientId+"')";
			List list=findBySql(sql);
			if(list!=null && list.size()==1){
				client_Type=((Object[])list.get(0))[2].toString();
				clientId=((Object[])list.get(0))[0].toString();
			}else {
				throw new CommonException("商户信息不存在！");
			}

			BaseMerchant mer=(BaseMerchant)findOnlyRowByHql("from BaseMerchant where bizState='0' and customerId='"+clientId+"'");
			if(!oldPwd.equals(mer.getServPwd())){
				throw new CommonException("原密码不正确！");
			}
			mer.setServPwd(newPwd);
			publicDao.merge(mer);
			
			//保存系统操作日志
			actionLog.setDealCode(DealCode.PERSON_SERVICEPWD_RESET);
			publicDao.save(actionLog);

			//保存业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo()); // 业务流水号
			rec.setBizTime(actionLog.getDealTime()); // 业务办理时间
			rec.setBrchId(brchid);
			rec.setUserId(operid);
			rec.setOldPwd(oldPwd);
			rec.setNewPwd(newPwd);//服务密码不加密
			rec.setDealState("0"); // 业务状态(0正常1撤销)
			rec.setNote("修改单位服务密码");
			rec.setDealCode(actionLog.getDealCode()); // 交易代码
			rec.setCustomerId(clientId);
			publicDao.save(rec);
		} catch (CommonException e) {
			throw e;
		}
	}
	/**
	 * 单位/商户服务密码修改
	 * @param clientId 客户id，若是商户，则是对应的bizid
	 * @param brch_id 操作员所属网点
	 * @param operid 操作员
	 * @param actionLog 业务日志
	 * @throws CommonException
	 */
	public void resetDwServPwd(String clientId, String brchid, String operid, SysActionLog actionLog,String newPwd) throws CommonException{
		try {
			//查询卡信息和密码信息
			String client_Type="";
			String sql="select * from (select customer_Id,corp_name,'2' client_type from base_corp t where customer_Id= '"+clientId+"' union "+
			"select customer_Id,merchant_name,'3' client_type from base_merchant t  where customer_Id='"+clientId+"')";
			List list=findBySql(sql);
			if(list!=null && list.size()==1){
				client_Type=((Object[])list.get(0))[2].toString();
				clientId=((Object[])list.get(0))[0].toString();
			}else {
				throw new CommonException("商户信息不存在！");
			}
			
			String oldPwd="";
			BaseMerchant mer=(BaseMerchant)findOnlyRowByHql("from BaseMerchant where bizState='0' and customerId='"+clientId+"'");
			oldPwd=mer.getServPwd();
			mer.setServPwd(newPwd);
			publicDao.merge(mer);

			//保存系统操作日志
			actionLog.setDealCode(DealCode.PERSON_SERVICEPWD_RESET);
			publicDao.save(actionLog);

			// 保存业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo()); // 业务流水号
			rec.setBizTime(actionLog.getDealTime()); // 业务办理时间
			rec.setBrchId(brchid);
			rec.setUserId(operid);
			rec.setOldPwd(oldPwd);
			rec.setNewPwd(newPwd);//服务密码不加密
			rec.setDealState("0"); // 业务状态(0正常1撤销)
			rec.setNote("重置商户服务密码");
			rec.setDealCode(actionLog.getDealCode()); // 交易代码
			rec.setCustomerId(clientId);
			publicDao.save(rec);
		} catch (CommonException e) {
			throw e;
		}
	}
	
	/**
	 * 根据密码类型和主体ID(card_No或者client_Id)，不验证密码信息是否存在，主要用于密码重置时
	 * @param pwdOwnerType 密码主体类型，0-网点1-个人卡 2-单位 3-商户4-机构
	 * @param id card_No或者client_Id
	 * @return
	 * @throws CommonException
	 */
	public CardBaseinfo findMmByTypeAndIdNoValidate(String pwdOwnerType,String id)throws CommonException {
		try {
			if(Tools.processNull(pwdOwnerType).equals("")||Tools.processNull(id).equals(""))
				throw new CommonException("主体ID、或密码类型不能为空");
			return (CardBaseinfo)this.findOnlyRowByHql(" from CardBaseinfo where cardNo='"+id+"'");
		} catch (Exception e) {
			throw new CommonException("查询密码失败，"+e.getMessage());
		}
	}
	
	
	/**
	 * 服务密码修改
	 * @param customer_Id 客户号
	 * @param brch_id 操作员所属网点
	 * @param operid 操作员
	 * @param actionlog 业务日志
	 * @param oldPwd 旧密码
	 * @param newPwd 新密码
	 * @throws CommonException
	 */
	public TrServRec updateServPwd(String customer_Id, String brchid, String operid, SysActionLog actionLog, String oldPwd,String newPwd)  throws CommonException {
		try {
			//查询客户信息，验证旧密码
			BasePersonal person=(BasePersonal)this.findOnlyRowByHql(" from BasePersonal t where t.customerId='"+customer_Id+"'");
			CardBaseinfo card=(CardBaseinfo)findOnlyRowByHql(" from CardBaseinfo t where t.customerId='"+customer_Id+"'");
			if(person.getServPwd()==null){
				throw new CommonException("该客户还没有设置过服务密码，请先到服务密码重置中设置服务密码！");
			}
			newPwd=Des3Util.encrypt_3des(newPwd,person.getCertNo(),"","");
			oldPwd=Des3Util.encrypt_3des(oldPwd,person.getCertNo(),"","");
			if(!person.getServPwd().equals(oldPwd)){
				throw new CommonException("原密码不正确！");
			}
			
			//保存系统操作日志
			actionLog.setDealCode(DealCode.PERSON_SERVICEPWD_MODIFY);
			publicDao.save(actionLog);

			//保存业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo()); // 业务流水号
			rec.setCustomerName(person.getName()); // 客户姓名
			rec.setCertType(person.getCertType()); // 持卡人证件类型
			rec.setCertNo(person.getCertNo()); // 持卡人证件号码
			rec.setBizTime(actionLog.getDealTime()); // 业务办理时间
			rec.setBrchId(brchid); // 办理网点编号
			rec.setUserId(operid); // 办理操作员编号
			rec.setOldPwd(oldPwd); // 原密码
			rec.setNewPwd(newPwd); // 新密码
			rec.setDealState("0"); // 业务状态(0正常1撤销)
			rec.setNote("");
			rec.setDealCode(DealCode.PERSON_SERVICEPWD_MODIFY); // 交易代码
			rec.setCustomerId(person.getCustomerId()+""); // 客户号
			rec.setCardNo(card.getCardNo());
			publicDao.save(rec);
			//修改密码信息
			person.setServPwd(rec.getNewPwd());
			publicDao.merge(person);
			
			//发送短信
			//shortMessageManager.saveMessage(card, person, null,actionLog, null, GlobalConst.SMS_TYPE_MMWH,null,null,0);
			return rec;
		} catch (CommonException e) {
			throw e;
		}
		
	}

	/**
	 * 服务密码重置
	 * @param customer_Id 客户号
	 * @param brch_id 操作员所属网点
	 * @param operid 操作员
	 * @param actionlog 业务日志
	 * @throws CommonException
	 */
	public TrServRec resetServPwd(String customerId, String brchid, String operid, SysActionLog actionLog,String newPwd)  throws CommonException {
		try {
			// 查询客户信息，验证旧密码
			BasePersonal person=(BasePersonal)this.findOnlyRowByHql(" from BasePersonal t where t.customerId='"+customerId+"'");
			CardBaseinfo card=(CardBaseinfo)findOnlyRowByHql(" from CardBaseinfo t where t.customerId='"+customerId+"'");
			//保存系统操作日志
			actionLog.setDealCode(DealCode.PERSON_SERVICEPWD_RESET);
			publicDao.save(actionLog);

			//保存业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo()); // 业务流水号
			rec.setCustomerName(person.getName()); // 客户姓名
			rec.setCertType(person.getCertType()); // 持卡人证件类型
			rec.setCertNo(person.getCertNo()); // 持卡人证件号码
			rec.setBizTime(actionLog.getDealTime()); // 业务办理时间
			rec.setBrchId(brchid); // 办理网点编号
			rec.setUserId(operid); // 办理操作员编号
			rec.setOldPwd(person.getServPwd()); // 原密码
			rec.setNewPwd(newPwd); // 新密码
			rec.setDealState("0"); // 业务状态(0正常1撤销)
			rec.setNote("个人服务密码重置");
			rec.setDealCode(DealCode.PERSON_SERVICEPWD_RESET); // 交易代码
			rec.setCustomerId(person.getCustomerId()+""); // 客户号
			rec.setCardNo(card.getCardNo());
			publicDao.save(rec);
			// 修改密码信息
			person.setServPwd(rec.getNewPwd());
			publicDao.merge(person);

			// 发送短信
			//shortMessageManager.saveMessage(card, person, null,actionLog,null, GlobalConst.SMS_TYPE_MMWH,null,null,0);
			return rec;
		} catch (CommonException e) {
			throw e;
		}
	}

}
