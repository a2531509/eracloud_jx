package com.erp.serviceImpl;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.axis2.transport.http.HTTPConstants;
import org.apache.log4j.Logger;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.input.SAXBuilder;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.service.DoWorkClientService;
import com.erp.util.Arith;
import com.erp.util.Tools;
import com.erp.viewModel.ZxcModel;
import com.erp.webservice.client.EasyServiceStub;
import com.erp.webservice.client.EasyServiceStub_Inter;

@Service("doWorkClientService")
public class DoWorkClientServiceImpl implements DoWorkClientService {
	private Logger logger = Logger.getLogger(CardApplyServiceImpl.class);
	private EasyServiceStub easyServiceClient = null;
	private EasyServiceStub_Inter easyServiceStub_Inter = null;
	
	/**
	 * @param cardno 卡号
	 * @param encrymoney 账户原金额
	 * @param amt 变动金额
	 * @param op 操作类型 0-加, 1-减
	 */
	public String money2EncryptCal(String cardno,String encrymoney,String amt,String op) throws CommonException{
		try{
			if(Tools.processNull(cardno).equals("")){
				throw new CommonException("获取金额密文失败，卡号不能为空！");
			}
			if(Tools.processNull(encrymoney).equals("")){
				throw new CommonException("获取金额密文失败，原金额不能为空！");
			}
			if(Tools.processNull(amt).equals("")){
				throw new CommonException("获取金额密文失败，变动金额不能为空！");
			}
			if(Tools.processNull(op).equals("")){
				throw new CommonException("获取金额密文失败，操作类型不能为空！");
			}
			JSONArray inParameter = new JSONArray();
			JSONObject onepara = new JSONObject();
			onepara.put("trcode","0103");
			onepara.put("cardno",cardno);
			if(Tools.processNull(op).equals("0")){
				onepara.put("money",Arith.add(encrymoney,amt));
			}else if(Tools.processNull(op).equals("1")){
				onepara.put("money",Arith.sub(encrymoney,amt));
			}else{
				throw new CommonException("获取金额密文失败，金额方向参数不正确！");
			}
			inParameter.add(onepara);
			JSONArray return_parameters = this.invoke(inParameter);
			if(return_parameters == null || return_parameters.isEmpty()){
				throw new CommonException("获取金额密文返回null");
			}
			JSONObject return_first = return_parameters.getJSONObject(0);
			if(return_first == null || return_first.isEmpty()){
				throw new CommonException("获取金额密文节点为空！");
			}
			if(!Tools.processNull(return_first.getString("errcode")).equals("00")){
				throw new CommonException(Tools.processNull(return_first.getString("errmessage")));
			}
			if(Tools.processNull(return_first.getString("money")).equals("")){
				throw new CommonException("获取金额密文失败，密文值为空！");
			}
			return return_first.getString("money");
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 
	 * @param cardNo 卡号
	 * @param mwpwd  密码明文
	 * @return
	 * @throws CommonException
	 */
	public String encrypt_MwPwd(String cardNo,String mwpwd)  throws CommonException{
		try{
			JSONArray inParameter = new JSONArray();
			JSONObject onepara = new JSONObject();
			onepara.put("trcode","0104");//trcode
			onepara.put("cardno",cardNo);//cardNo
			onepara.put("psw",mwpwd);
			inParameter.add(onepara);
			JSONArray return_parameters = this.invoke(inParameter);
			if(return_parameters == null || return_parameters.isEmpty()){
				throw new CommonException("获取密码密文返回null");
			}
			JSONObject return_first = return_parameters.getJSONObject(0);
			if(return_first == null || return_first.isEmpty()){
				throw new CommonException("获取密码密文节点为空！");
			}
			if(!Tools.processNull(return_first.getString("errcode")).equals("00")){
				throw new CommonException("获取密码失败，" + Tools.processNull(return_first.getString("errmessage")));
			}
			if(Tools.processNull(return_first.getString("pin")).equals("")){
				throw new CommonException("获取密码密文失败，密文值为空！");
			}
			return Tools.processNull(return_first.getString("pin"));
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * pin密码键盘码转密文密码
	 * Description <p>TODO</p>
	 * @param cardNo  卡号
	 * @param pwd     键盘密文码
	 * @return        密文
	 * @throws CommonException
	 */
	public String encrypt_PinPwd(String cardNo,String pinPwd) throws CommonException{
		try{
			JSONArray inParameter = new JSONArray();
			JSONObject onepara = new JSONObject();
			onepara.put("trcode","0105");
			onepara.put("bizid","999999999999999");
			onepara.put("termid","9999999999");
			onepara.put("cardno",cardNo);
			onepara.put("pin",pinPwd);
			inParameter.add(onepara);
			JSONArray return_parameters = this.invoke(inParameter);
			if(return_parameters == null || return_parameters.isEmpty()){
				throw new CommonException("获取密码密文返回null");
			}
			JSONObject return_first = return_parameters.getJSONObject(0);
			if(return_first == null || return_first.isEmpty()){
				throw new CommonException("获取密码密文节点为空！");
			}
			if(!Tools.processNull(return_first.getString("errcode")).equals("00")){
				throw new CommonException("获取密码失败，" + Tools.processNull(return_first.getString("errmessage")));
			}
			if(Tools.processNull(return_first.getString("pin")).equals("")){
				throw new CommonException("获取密码密文失败，密文值为空！");
			}
			return Tools.processNull(return_first.getString("pin"));
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 明文密码加密
	 * Description <p>TODO</p>
	 * @param cardNo  卡号
	 * @param pwd     明文密码
	 * @return        密文
	 * @throws CommonException
	 */
	public String encrypt_Pwd(String cardNo,String pwd) throws CommonException{
		try{
			JSONArray inParameter = new JSONArray();
			JSONObject onepara = new JSONObject();
			onepara.put("trcode","0104");
			onepara.put("psw",pwd);
			onepara.put("cardno",cardNo);
			inParameter.add(onepara);
			JSONArray return_parameters = this.invoke(inParameter);
			if(return_parameters == null || return_parameters.isEmpty()){
				throw new CommonException("获取密码密文返回null");
			}
			JSONObject return_first = return_parameters.getJSONObject(0);
			if(return_first == null || return_first.isEmpty()){
				throw new CommonException("获取密码密文节点为空！");
			}
			if(!Tools.processNull(return_first.getString("errcode")).equals("00")){
				throw new CommonException(Tools.processNull(return_first.getString("errmessage")));
			}
			if(Tools.processNull(return_first.getString("pin")).equals("")){
				throw new CommonException("获取密码密文失败，密文值为空！");
			}
			return Tools.processNull(return_first.getString("pin"));
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}

	@Override
	public JSONObject encrypt_Money(String cardNo,Long minutes){
		try{
			if(Tools.processNull(cardNo).equals("")){
				throw new CommonException("获取金额密文卡号不能为空！");
			}
			if(Tools.processNull(minutes).equals("")){
				throw new CommonException("获取金额密文原金额不能为空！");
			}
			JSONObject onepara = new JSONObject();
			onepara.put("cardno",cardNo);
			onepara.put("money",minutes + "");
			JSONArray inParameter = new JSONArray();
			inParameter.add(onepara);
			JSONArray return_parameters = this.invoke(inParameter);
			if(return_parameters == null || return_parameters.isEmpty()){
				throw new CommonException("获取金额密文返回null");
			}else{
				return return_parameters.getJSONObject(0);
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 验证消费数据的TAC
	 * @param fileName
	 * @param data
	 * @return
	 * @throws CommonException
	 */
	public JSONArray checkTacByFileName(String fileName,String data) throws CommonException{
		JSONArray return_parameters=null;
		try{
			if(Tools.processNull(data).equals("")){
				throw new CommonException("验证TAC出现错误," + "验证TAC传入数据都不能为空！");
			}
			//data=流水号，卡号，金额，交易类型，终端编号 或 psam卡号，终端交易序号(psam卡交易序号)，交易时间(yyyymmddhhmmss)，TAC
			String [] strs=data.split("\\|");
			JSONArray inParameter = new JSONArray();
			
			for(int j=0;j<strs.length;j++){
				JSONObject onepara = new JSONObject();
				String[] s=strs[j].split(",");
				onepara.put("trcode","0120");//2.1.6	验证消费TAC(0120)
				onepara.put("cardno",Tools.processNull(s[1]));//卡号
				onepara.put("money",Tools.processNull(s[2]));//交易金额
				onepara.put("type",Tools.processNull(s[3]));//交易类型
				onepara.put("psamcode",Tools.processNull(s[4]));//PASM卡号
				onepara.put("bizserial",Tools.processNull(s[5]));//商户交易流水号
				onepara.put("bizdate",Tools.processNull(s[6]));//交易时间
				onepara.put("tac",Tools.processNull(s[7]));//TAC
				onepara.put("deal_no",Tools.processNull(s[0]));//交易流水号
				
				inParameter.add(onepara);
			}
			return_parameters = this.invoke(inParameter);
			return return_parameters;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	@Override
	@SuppressWarnings({ "rawtypes","unchecked" })
	@Deprecated
	//gecc-注意一下，暂时没用到这个类，没有测试过的的，
	public List<Map<String,String>> doWork(String code,List<Map<String,String>> list)throws CommonException{
		Long startTime = System.currentTimeMillis();
		StringBuffer sb = new StringBuffer("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
		try{
			if(easyServiceClient == null){
				easyServiceClient = new EasyServiceStub();
			}
			EasyServiceStub.Execute execute = new EasyServiceStub.Execute();
			sb.append("<Fields>");
			Map map = null;
			for(int i = 0;i < list.size();i++){
				new HashMap();
				map = list.get(i);
				Iterator ite = map.keySet().iterator();
				while(ite.hasNext()){
					String key = Tools.processNull(ite.next());
					String cardnos=(String)map.get(key);
					String[] strcardno=cardnos.split(",");
					for(int j = 0;j < strcardno.length;j++){
						sb.append("<parms ");
						sb.append(" trcode=\""  + code + "\" ");
						sb.append(" money=\"0\" ");
						//sb.append(" psw=\""+ Tools.processNull(pwd) +"\"  ");
						sb.append(" "+key + "=\"" + strcardno[j].toString() + "\" ");
						sb.append(">" + j + "</parms>");
					}
				}
			}
			map = null;
			list = null;
			sb.append("</Fields>");
			execute.setXml(sb.toString());
			easyServiceClient._getServiceClient().getOptions().setProperty(HTTPConstants.CHUNKED,"false");			
			String return_str = easyServiceClient.Execute(execute).getExecuteResult();
			execute = null;
			//开始构造返回数据
			List<Map<String,String>> rt_map = new ArrayList<Map<String,String>>();
			SAXBuilder saxb = new SAXBuilder();
			Document doc = saxb.build(new ByteArrayInputStream(return_str.getBytes("UTF-8")));   
			Element root = doc.getRootElement();
			List e_param_name_list = null;
			List param = root.getChild("parms",root.getNamespace()).getChildren("parm",root.getNamespace());
			for(int j = 0;j < param.size();j++){
				Element param_e = (Element)param.get(j);//每一个parm对应的节点
				Map param_map = new HashMap();
				e_param_name_list = param_e.getAttributes();//每一个parm对应的节点的所有Attribute属性
				for(int k = 0;k < e_param_name_list.size();k++){
					org.jdom.Attribute abt = (org.jdom.Attribute)e_param_name_list.get(k);
					param_map.put(abt.getName(),abt.getValue());
					abt = null;
				}
				e_param_name_list = null;
				rt_map.add(Integer.valueOf(param_e.getText()).intValue(),param_map);
				if(!Tools.processNull(param_map.get("err_code")).equals("00")){
					logger.info("("+code+")发生失败，入参：" + sb.toString() + "。出参：" + param_map.toString());
				}
			}
			param = null;
			return rt_map;
		}catch (Exception e){
			System.gc();
			if(Tools.processNull(e.getMessage()).startsWith("org.apache.axis2.AxisFault")){
				throw new CommonException("前置系统正在启动中");
			}
			throw new CommonException(e.getMessage());
		}finally{
			Long endTime = System.currentTimeMillis();
			if((endTime - startTime) / 1000 > 10){
				logger.info("执行时间为" + (endTime-startTime) / 1000 + "秒，需小汤优化，入参如下：\r\n" + sb.toString());
			}
		}
	}
	/**
	 * 调取webservice统一接口
	 * @param trCode      交易代码
	 * @param inParameter 本次业务所需传入参数信息
	 * @return
	 */
	public JSONArray invoke(JSONArray inParameter) throws CommonException{
		Long startTime = System.currentTimeMillis();
		try{
			//1.比较条件判断
			if(inParameter == null || inParameter.isEmpty()){
				throw new CommonException("调取webservice传入参数不能为空！");
			}
			if(easyServiceClient == null){
				easyServiceClient = new EasyServiceStub();
			}
			//2.获取客户端信息
			if(easyServiceClient == null){
				easyServiceClient = new EasyServiceStub();
			}
			//3.定义请求参数
			EasyServiceStub.Invoke invoke = new EasyServiceStub.Invoke();
			invoke.setJson(inParameter.toJSONString());
			easyServiceClient._getServiceClient().getOptions().setProperty(HTTPConstants.CHUNKED,"false");
			//3.发起请求
			String return_str = easyServiceClient.Invoke(invoke).getInvokeResult();
			//4.判断请求结果
			if(Tools.processNull(return_str).equals("")){
				throw new CommonException("调取webservice返回返回null");
			}else{
				return JSONArray.parseArray(return_str);
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}finally{
			Long endTime = System.currentTimeMillis();
			if((endTime - startTime) / 1000 > 10){
				logger.error("执行时间为" + (endTime - startTime) / 1000 + "秒，需小汤优化，入参如下：" + inParameter.toJSONString());
			}
		}
	}
	
	/**
     * 自行车应用
     * @param personal
     * @param zxcModel
     * @return
     * @throws CommonException
     */
	public JSONArray saveZxc(BasePersonal personal,ZxcModel zxcModel,String trcode) throws CommonException{
		JSONArray return_parameters=null;
		try{
			if(Tools.processNull(trcode).equals("")){
				throw new CommonException("交易代码不为能空");
			}
			//data=流水号，卡号，金额，交易类型，终端编号 或 psam卡号，终端交易序号(psam卡交易序号)，交易时间(yyyymmddhhmmss)，TAC
			JSONArray inParameter = new JSONArray();
			JSONObject onepara = new JSONObject();
			onepara.put("trcode",trcode);//2.1.6	验证消费TAC(0120)
			if(Tools.processNull(trcode).equals("bk10001")){//开通
				//trdate	交易日期yyyymmdd/trtime	交易时间hhmmss/operid	柜员/cardno	卡号/name		姓名/cardtype		证件类型(身份证:01军官证:02护照:03                 入境证:04  临时身份证:05其他:10)/cardid	证件号/addr联系地址/phone	联系电话/phone_other备用电话/sex	性别/people_born	生日yyyymmdd
				onepara.put("trdate",Tools.processNull(zxcModel.getTrdate()));//交易日期yyyymmdd
				onepara.put("trtime",Tools.processNull(zxcModel.getTrtime()));//交易时间hhmmss
				onepara.put("operid",Tools.processNull(zxcModel.getOperid()));//柜员
				onepara.put("cardno",Tools.processNull(zxcModel.getCardno()));//卡号
				onepara.put("name",Tools.processNull(personal.getName()));//姓名
				onepara.put("cardtype",Tools.processNull(personal.getCertType()));//证件类型
				onepara.put("cardid",Tools.processNull(personal.getCertNo()));//证件编号
				onepara.put("addr",Tools.processNull(personal.getLetterAddr()));//联系地址
				onepara.put("phone_other",Tools.processNull(personal.getPhoneNo()));//电话
				onepara.put("phone",Tools.processNull(personal.getMobileNo()));//手机号
				onepara.put("sex",Tools.processNull(personal.getGender()));//性别
				onepara.put("people_born",Tools.processNull(personal.getBirthday()).replaceAll("-", ""));//出生年月
			}else if(Tools.processNull(trcode).equals("bk10002")){//取消
				//trdate，交易日期yyyymmdd/trtime，交易时间hhmmss/operid，柜员/cardno，卡号/Cancle_reason，取消原因
				onepara.put("trdate",Tools.processNull(zxcModel.getTrdate()));//交易日期yyyymmdd
				onepara.put("trtime",Tools.processNull(zxcModel.getTrtime()));//交易时间hhmmss
				onepara.put("operid",Tools.processNull(zxcModel.getOperid()));//柜员
				onepara.put("cardno",Tools.processNull(zxcModel.getCardno()));//卡号
				onepara.put("Cancle_reason",Tools.processNull(zxcModel.getCancle_reason()));//取消原因
			}
	
			inParameter.add(onepara);
			return_parameters = this.invoke(inParameter);
			return return_parameters;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 获取主密钥
	 */
	public JSONArray getPosMainKey(String bizid) throws CommonException{
		JSONArray return_parameters=null;
		try {
			JSONArray inParameter = new JSONArray();
			JSONObject onepara = new JSONObject();
			onepara.put("trcode","0100");//2.1.1	取主密钥(0100)
			onepara.put("bizid",bizid);//卡号
			onepara.put("termid","");//交易金额
			inParameter.add(onepara);
			return_parameters = this.invoke(inParameter);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
		return return_parameters;
		
	}
	/**
	 * 获取工作密钥
	 */
	public JSONArray getPosWorkKey(String bizid,String endid)throws CommonException{
		JSONArray return_parameters=null;
		try {
			JSONArray inParameter = new JSONArray();
			JSONObject onepara = new JSONObject();
			onepara.put("trcode","0101");//2.1.2	取主密钥(0101)
			onepara.put("bizid",bizid);//卡号
			onepara.put("termid",endid);//交易金额
			inParameter.add(onepara);
			return_parameters = this.invoke(inParameter);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
		return return_parameters;
	}
	public EasyServiceStub getEasyServiceClient() {
		return easyServiceClient;
	}
	public void setEasyServiceClient(EasyServiceStub easyServiceClient) {
		this.easyServiceClient = easyServiceClient;
	}

	/**
	 * 获取充值卡密码。
	 */
	@Override
	public JSONArray getRechargeCardPwd(String cardno, int length) throws CommonException {
		JSONArray return_parameters = null;
		try {
			if(Tools.processNull(cardno).equals("")) {
				throw new CommonException("卡号不能为空！");
			}
			JSONArray inParameter = new JSONArray();
			JSONObject onepara = new JSONObject();
			onepara.put("trcode", "0106");
			onepara.put("cardno", cardno);
			onepara.put("len", length);
			inParameter.add(onepara);
			return_parameters = this.invoke(inParameter);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
		return return_parameters;
	}
	
	/**
	 * 调取webservice统一接口
	 * @param trCode      交易代码
	 * @param inParameter 本次业务所需传入参数信息
	 * @return
	 */
	public JSONArray invoke_Outer(JSONArray inParameter) throws CommonException{
		Long startTime = System.currentTimeMillis();
		try{
			//1.比较条件判断
			if(inParameter == null || inParameter.isEmpty()){
				throw new CommonException("调取webservice传入参数不能为空！");
			}
			//2.获取客户端信息
			if(easyServiceStub_Inter == null){
				easyServiceStub_Inter = new EasyServiceStub_Inter();
			}
			//3.定义请求参数
			EasyServiceStub_Inter.Invoke invoke = new EasyServiceStub_Inter.Invoke();
			invoke.setJson(inParameter.toJSONString());
			easyServiceStub_Inter._getServiceClient().getOptions().setProperty(HTTPConstants.CHUNKED,"false");
			//3.发起请求
			String return_str = easyServiceStub_Inter.Invoke(invoke).getInvokeResult();
			//invoke(invoke).getInvokeResult();
			//4.判断请求结果
			if(Tools.processNull(return_str).equals("")){
				throw new CommonException("调取webservice返回返回null");
			}else{
				return JSONArray.parseArray(return_str);
			}
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}finally{
			Long endTime = System.currentTimeMillis();
			if((endTime - startTime) / 1000 > 10){
				logger.error("执行时间为" + (endTime - startTime) / 1000 + "秒，需小汤优化，入参如下：" + inParameter.toJSONString());
			}
		}
	}
	
}
