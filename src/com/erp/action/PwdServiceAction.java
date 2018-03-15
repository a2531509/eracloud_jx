package com.erp.action;

import java.math.BigDecimal;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.CardBaseinfo;
import com.erp.model.TrServRec;
import com.erp.service.PwdService;
import com.erp.util.Constants;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

import net.sf.jasperreports.web.commands.CommandException;

@Namespace(value="/pwdservice")
@Action(value="pwdserviceAction")
@InterceptorRefs({@InterceptorRef("jsondefalut")})
@SuppressWarnings("serial")
public class PwdServiceAction extends BaseAction {
	public Log log = LogFactory.getLog(PwdServiceAction.class);
	@Autowired
	private PwdService pwdService;
	private TrServRec rec = new TrServRec();
	private String queryType = "1";
	private String certType;
	private String certNo;
	private String certNo2;
	private String cardType;
	private String cardNo;
	private Long customerId;
	private String pwd;
	private String oldPwd;
	private int opType = 0;
	private String sort;
	private String order;
	
	/**
	 * 社保密码修改,重置查询
	 * Description <p>TODO</p>
	 * @return
	 */
	public String sbPwdModifyQuery(){
		initGrid();
		try{
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select c.customer_id,b.name,");
				sb.append("(select s0.code_name from sys_code s0 where s0.code_type = 'SEX' and s0.code_value = b.gender) gender,");
				sb.append("(select s1.code_name from sys_code s1 where s1.code_type = 'CERT_TYPE' and s1.code_value = b.cert_type) cert_type,");
				sb.append("b.cert_no,c.card_no,");
				sb.append("(select s2.code_name from sys_code s2 where s2.code_type = 'CARD_TYPE' and s2.code_value = c.card_type) card_type,c.sub_card_no,");
				sb.append("(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_STATE' and s3.code_value = c.card_state) card_state,");
				sb.append("(select s4.code_name from sys_code s4 where s4.code_type = 'CARD_STATE' and s4.code_value = c.bus_type) bus_type,");
				sb.append("(case when c.start_date is not null then to_char(to_date(c.start_date,'yyyymmdd'),'yyyy-mm-dd') else '' end) start_date ");
				sb.append("from card_baseinfo c ,base_personal b ");
				sb.append("where c.customer_id = b.customer_id(+) ");
				if(!Tools.processNull(this.cardNo).trim().equals("")){
					sb.append("and c.card_no = '" + this.cardNo + "' ");
				}
				if(!Tools.processNull(this.cardType).trim().equals("")){
					sb.append("and c.card_type = '" + this.cardType + "' ");
				}
				if(!Tools.processNull(this.certNo).trim().equals("")){
					sb.append("and b.cert_no = '" + this.certNo + "'");
				}
				if(!Tools.processNull(this.certType).trim().equals("")){
					sb.append("and b.cert_type = '" + this.certType + "'");
				}
				Page list = pwdService.pagingQuery(sb.toString(),1,100);
				if(list.getAllRs() != null){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommandException("根据查询条件未找到卡片信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 社保密码记录
	 * Description <p>TODO</p>
	 * @return
	 */
	public String saveSbPwd(){
		try{
			//1.条件判断
			if(Tools.processNull(this.cardNo).equals("")){
				throw new Exception("卡号不能为空");
			}
			CardBaseinfo tempcard = (CardBaseinfo) pwdService.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
			if(tempcard == null){
				throw new Exception("根据客户编号未查询到对应的人员信息，无法修改社保密码！");
			}
			BasePersonal bp = (BasePersonal) pwdService.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + tempcard.getCustomerId() + "'");
			if(bp == null){
				throw new Exception("根据证件号码未查询到对应的人员信息，无法修改社保密码！");
			}
			//3.业务日志
			Long dealNo =  pwdService.saveSbPwd(this.cardNo,pwd,rec);
			//4.设置凭证
			jsonObject.put("dealNo",dealNo);
			jsonObject.put("status","0");
			jsonObject.put("message","社保密码修改成功！");
		}catch(Exception e){
			log.error(e);
			jsonObject.put("status","1");
			jsonObject.put("message",e.getMessage());
		}
		return "jsonObj";
	}
	
	
	/**
	 * 服务密码修改,重置查询
	 * Description <p>TODO</p>
	 * @return
	 */
	public String servicePwdModifyQuery(){
		try{
			initGrid();
			if(!Tools.processNull(this.queryType).equals("0")){
				return this.JSONOBJ;
			}
			StringBuffer sb = new StringBuffer();
			sb.append("SELECT  T.CUSTOMER_ID,T.NAME,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CERT_TYPE' AND CODE_VALUE = T.CERT_TYPE) CERTTYPE,");
			sb.append("T.CERT_NO,NVL(T.CUSTOMER_STATE,'1') CUSTOMER_STATE,NVL(T.NET_PWD_ERR_NUM,0) NET_PWD_ERR_NUM,");
			sb.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'SEX' AND CODE_VALUE = T.GENDER) GENDER,");
			sb.append("DECODE(T.CUSTOMER_STATE,'0','正常','1','注销','未说明') CUSTOMERSTATE,");
			sb.append("DECODE(T.RESIDE_TYPE,'0','本地','1','外地','未说明') RESIDETYPE ");
			sb.append("FROM BASE_PERSONAL T WHERE 1 = 1 ");
			if(!Tools.processNull(this.certType).equals("")){
				sb.append("AND T.CERT_TYPE = '" + this.certType + "' ");
			}
			if(!Tools.processNull(this.certNo).equals("")){
				sb.append("AND T.CERT_NO = '" + this.certNo + "' ");
			}
			if(!(Tools.processNull(this.cardType).equals("") && Tools.processNull(this.cardNo).equals(""))){
				sb.append("AND EXISTS (SELECT 1 FROM CARD_BASEINFO C WHERE T.CUSTOMER_ID = C.CUSTOMER_ID ");
				if(!Tools.processNull(this.cardType).equals("")){
					sb.append("AND C.CARD_TYPE = '" + this.cardType + "' ");
				}
				if(!Tools.processNull(this.cardNo).equals("")){
					sb.append("AND C.CARD_NO = '" + this.cardNo + "' ");
				}
				sb.append(") ");
			}
			Page list = pwdService.pagingQuery(sb.toString(),page,rows);
			if(list.getAllRs() != null && list.getAllRs().size() > 0){
				jsonObject.put("rows",list.getAllRs());
			}else{
				throw new Exception("未找到人员信息，无法" + (opType == 0 ? "修改" : "重置") + "服务密码！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 社保密码重置
	 * @return
	 */
	public String sbPwdReset(){
		try{
			initJson();
			JSONObject para = new JSONObject();
			para.put("cardNo",this.cardNo);
			para.put("pwd",this.pwd);
			para.put("rec",this.rec);
			rec = pwdService.sbPwdReset(para,pwdService.getUser(),pwdService.getCurrentActionLog());
			jsonObject.put("dealNo",rec.getDealNo());
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 个人服务密码修改
	 * Description <p>TODO</p>
	 * @return
	 */
	public String saveServicePwd(){
		try{
			//1.条件判断
			if(Tools.processNull(this.certNo).equals("")){
				throw new Exception("证件号码不能为空，请选择一条记录信息进行服务密码修改！");
			}
			BasePersonal bp = (BasePersonal) pwdService.findOnlyRowByHql("from BasePersonal t where t.certNo = '" + this.certNo + "'");
			if(bp == null){
				throw new Exception("根据证件号码未查询到对应的人员信息，无法修改服务密码！");
			}
			//2.判断原始密码是否正确
			Map<String,String> pwdMap = pwdService.judgeCustomerServicePwd(bp.getCustomerId(),oldPwd);
			if(!pwdMap.get("isVerifyOk").equals("0")){
				throw new Exception("原始密码验证失败，" + pwdMap.get("msg") + "！");
			}
			rec.setOldPwd(baseService.encrypt_des(oldPwd,bp.getCertNo()));
			//3.业务日志
			Long dealNo = pwdService.saveServicePwdModify(bp.getCustomerId(),pwd,rec,0);
			jsonObject.put("status",true);
			jsonObject.put("message","服务密码修改成功！");
			jsonObject.put("dealNo",dealNo);
		}catch(Exception e){
			jsonObject.put("status",false);
			jsonObject.put("message",e.getMessage());
		}
		return "jsonObj";
	}
	
	/**
	 * <p>个人服务密码重置<p>
	 * @return
	 */
	public String saveServicePwdReset(){
		try{
			//1.条件判断
			if(Tools.processNull(this.certNo).equals("")){
				throw new Exception("证件号码不能为空，请选择一条记录信息进行服务密码重置！");
			}
			BasePersonal bp = (BasePersonal) pwdService.findOnlyRowByHql("from BasePersonal t where t.certNo = '" + this.certNo + "'");
			if(bp == null){
				throw new Exception("根据证件号码未查询到对应的人员信息，无法重置服务密码！");
			}
			rec.setNewPwd(baseService.encrypt_des(pwd,bp.getCertNo()));
			//3.业务日志
			Long dealNo =  pwdService.saveServicePwdModify(bp.getCustomerId(),pwd,rec,1);
			//4.设置凭证
			jsonObject.put("dealNo",dealNo);
			jsonObject.put("status",true);
			jsonObject.put("message","服务密码重置成功！");
		}catch(Exception e){
			log.error(e);
			jsonObject.put("status",false);
			jsonObject.put("message",e.getMessage());
		}
		return "jsonObj";
	}
	/**
	 * 联机账户密码修改,重置进行信息查询
	 * @return
	 */
	public String payPwdQuery(){
		initGrid();
		try{
			if(Tools.processNull(this.queryType).equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append("select c.customer_id,b.name,");
				sb.append("(select s0.code_name from sys_code s0 where s0.code_type = 'SEX' and s0.code_value = b.gender) gender,");
				sb.append("(select s1.code_name from sys_code s1 where s1.code_type = 'CERT_TYPE' and s1.code_value = b.cert_type) cert_type,");
				sb.append("b.cert_no,c.card_no,");
				sb.append("(select s2.code_name from sys_code s2 where s2.code_type = 'CARD_TYPE' and s2.code_value = c.card_type) card_type,");
				sb.append("(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_STATE' and s3.code_value = c.card_state) card_state,");
				sb.append("(select s4.code_name from sys_code s4 where s4.code_type = 'CARD_STATE' and s4.code_value = c.bus_type) bus_type,");
				sb.append("(case when c.start_date is not null then to_char(to_date(c.start_date,'yyyymmdd'),'yyyy-mm-dd') else '' end) start_date ");
				sb.append("from card_baseinfo c ,base_personal b ");
				sb.append("where c.customer_id = b.customer_id(+) ");
				if(!Tools.processNull(this.cardNo).trim().equals("")){
					sb.append("and c.card_no = '" + this.cardNo + "' ");
				}
				if(!Tools.processNull(this.cardType).trim().equals("")){
					sb.append("and c.card_type = '" + this.cardType + "' ");
				}
				if(!Tools.processNull(this.certNo).trim().equals("")){
					sb.append("and b.cert_no = '" + this.certNo + "'");
				}
				if(!Tools.processNull(this.certType).trim().equals("")){
					sb.append("and b.cert_type = '" + this.certType + "'");
				}
				Page list = pwdService.pagingQuery(sb.toString(),1,100);
				if(list.getAllRs() != null){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommandException("根据查询条件未找到卡片信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 联机账户支付密码重置
	 * @return
	 */
	public String savePayPwdReset(){
		try{
			initJson();
			JSONObject para = new JSONObject();
			para.put("cardNo",this.cardNo);
			para.put("pwd",this.pwd);
			para.put("rec",this.rec);
			rec = pwdService.savePayPwdReset(para,pwdService.getUser(),pwdService.getCurrentActionLog());
			jsonObject.put("dealNo",rec.getDealNo());
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 联机账户支付密码修改
	 * @return
	 */
	public String savePayPwdModify(){
		try{
			initJson();
			JSONObject para = new JSONObject();
			para.put("cardNo",this.cardNo);//卡号
			para.put("pwd",this.pwd);//新密码
			para.put("oldPwd",this.oldPwd);//原密码
			para.put("rec",this.rec);
			rec = pwdService.savePayPwdModify(para,pwdService.getUser(),pwdService.getCurrentActionLog());
			jsonObject.put("dealNo",rec.getDealNo());
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	//服务已误次数获取
	public String getserverrtime(){
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("select t.serv_pwd_err_num from BASE_PERSONAL t where t.cert_no ='"+ certNo2 +"'");
			Page list = pwdService.pagingQuery(sb.toString(),1,100);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommandException("服务已误次数获取失败！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	//服务密码重置
	public String serverrtimereset(){
		try{
			String sbl = "select count(1)  from BASE_PERSONAL t where t.CERT_NO ='"+ certNo2 +"'";
			BigDecimal bd = (BigDecimal)pwdService.findOnlyFieldBySql(sbl);
			if(bd == null){
				throw new CommandException("该人员信息不存在");
			}
			rec = pwdService.servpwdErrTimeReset(certNo2,pwdService.getUser(),pwdService.getCurrentActionLog());
			jsonObject.put("status","0");
			jsonObject.put("msg","服务密码错误次数重置成功");
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	//交易已误次数重置
	public String delerrtimereset(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			String sql = "select count(1)  from CARD_BASEINFO t where t.CARD_NO ='"+ cardNo +"'";
			BigDecimal bd = (BigDecimal)pwdService.findOnlyFieldBySql(sql);
			if(bd == null){
				throw new CommandException("该卡号信息不存在");
			}
			rec = pwdService.dealpwdErrTimeReset(cardNo,pwdService.getUser(),pwdService.getCurrentActionLog());
			jsonObject.put("status","0");
			jsonObject.put("msg","交易密码错误次数重置成功");
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	//交易已误次数获取
	public String getdelerrtime(){
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("select t.PAY_PWD_ERR_NUM  from CARD_BASEINFO t where t.CARD_NO ='"+ cardNo +"'");
			Page list = pwdService.pagingQuery(sb.toString(),1,100);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommandException("交易已误次数获取失败！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	//可错误次数获取
	public String getallerrtime(){
		try{
			StringBuffer sb = new StringBuffer();
			sb.append("select t.para_value  from SYS_PARA t where t.para_code = 'TRADE_PWD_ERR_NUM' or t.para_code = 'SERV_PWD_ERR_NUM'  order by t.para_code asc");
			Page list = pwdService.pagingQuery(sb.toString(),1,100);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}else{
				throw new CommandException("根据查询可错误次数信息！");
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String getSBPwdServInfos() {
		try {
			initGrid();

			if (Tools.processNull(cardNo).equals("")) {
				throw new CommonException("卡号为空.");
			}
			
			CardBaseinfo tempcard = (CardBaseinfo)pwdService.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
			
			if(tempcard == null || tempcard.getCustomerId() == null){
				throw new CommonException("卡片信息不存在, 不能进行社保密码重置.");
			} else if(!Constants.CARD_STATE_ZC.equals(tempcard.getCardState())){
				throw new CommonException("卡片状态不正常, 不能进行社保密码重置.");
			}
			
			BasePersonal bp = (BasePersonal) pwdService.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + tempcard.getCustomerId() + "'");
			if(bp == null){
				throw new CommonException("人员信息不存在, 不能进行社保密码重置.");
			} else if(!Constants.STATE_ZC.equals(bp.getCustomerState())){
				throw new CommonException("人员状态不正常, 不能进行社保密码重置.");
			}

			String sql = "select t.deal_no, t.deal_code, c.deal_code_name, "
					+ "t.card_no, t.customer_id, t.customer_name, "
					+ "to_char(t.biz_time, 'yyyy-mm-dd hh24:mi:ss') biz_time, "
					+ "t.brch_id, b.full_name, t.user_id, t.note from tr_serv_rec t "
					+ "join sys_code_tr c on t.deal_code = c.deal_code join sys_branch b "
					+ "on t.brch_id = b.brch_id  where t.deal_code in ('"
					+ DealCode.SB_PWD_MODIFY + "','" + DealCode.SB_PWD_RESET
					+ "') " + "and t.card_no = '" + cardNo + "' ";
			
			if (!Tools.processNull(sort).equals("")) {
				sql += " order by " + sort;

				if (!Tools.processNull(order).equals("")) {
					sql += " " + order;
				}
			} else {
				sql += " order by t.biz_time desc";
			}

			Page pageData = pwdService.pagingQuery(sql, page, rows);

			if (pageData == null || pageData.getAllRs() == null
					|| pageData.getAllRs().isEmpty()) {
				jsonObject.put("rows", new JSONArray());
				jsonObject.put("total", 0);
			}else{
				jsonObject.put("rows", pageData.getAllRs());
				jsonObject.put("total", pageData.getTotalCount());
			}
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}

		return JSONOBJ;
	}
	//初始化表格数据
	private void initGrid(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
	}
	//初始化返回
	private void initJson(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		jsonObject.put("dealNo","");
	}	
	public PwdService getPwdService() {
		return pwdService;
	}
	public void setPwdService(PwdService pwdService) {
		this.pwdService = pwdService;
	}
	public String getQueryType() {
		return queryType;
	}
	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}
	public TrServRec getRec() {
		return rec;
	}
	public void setRec(TrServRec rec) {
		this.rec = rec;
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
	public String getCardNo() {
		return cardNo;
	}
	public void setCardNo(String cardNo) {
		this.cardNo = cardNo;
	}
	public Long getCustomerId() {
		return customerId;
	}
	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}
	public String getPwd() {
		return pwd;
	}
	public void setPwd(String pwd) {
		this.pwd = pwd;
	}
	public String getOldPwd() {
		return oldPwd;
	}
	public void setOldPwd(String oldPwd) {
		this.oldPwd = oldPwd;
	}
	public int getOpType() {
		return opType;
	}
	public void setOpType(int opType) {
		this.opType = opType;
	}
	public String getCertNo2() {
		return certNo2;
	}
	public void setCertNo2(String certNo2) {
		this.certNo2 = certNo2;
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
	
}
