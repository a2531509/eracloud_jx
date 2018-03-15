package com.erp.serviceImpl;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.BaseEndOut;
import com.erp.model.BaseMerchant;
import com.erp.model.BaseMerchantType;
import com.erp.model.BaseTagEnd;
import com.erp.model.CardOrgBindSection;
import com.erp.model.PayAcctypeSqn;
import com.erp.model.PayFeeRate;
import com.erp.model.PayFeeRateSection;
import com.erp.model.PayMerchantAcctype;
import com.erp.model.PayMerchantAcctypeId;
import com.erp.model.PayMerchantLim;
import com.erp.model.StlDealSum;
import com.erp.model.StlMode;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.AccAcountService;
import com.erp.service.MerchantMangerService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.Sys_Code;
import com.erp.util.Tools;

import oracle.net.aso.b;

@Service("merchantMangerService")
public class MerchantMangerServiceImpl extends BaseServiceImpl implements MerchantMangerService {
    
	
	public AccAcountService accACountService;
	
	@Autowired
	public void setAccACountService(AccAcountService accACountService) {
		this.accACountService = accACountService;
	}
	@Override
	public List cancelMerType(String merTypeId) throws CommonException {
		//1，注销该类型及子类型
		//
		return null;
	}

	@Override
	public void saveMerType(SysActionLog actionLog, BaseMerchantType mtype)
			throws CommonException {
		try {
			
			if(Tools.processNull(mtype.getId())==null||Tools.processNull(mtype.getId()).equals("")){
				actionLog.setMessage("新增商户类型信息");
				publicDao.save(mtype);
			}else{
				actionLog.setMessage("修改商户类型信息");
				publicDao.update(mtype);
			}
			publicDao.save(actionLog);
			this.saveTrServRec(actionLog);
		} catch (Exception e) {
			throw new CommonException("发生错误："+e.getMessage());
		}
	}

	@Override
	public boolean checkBiz_Name(String Biz_Name) throws CommonException {
		boolean rs = false;
		try {
			if (!Tools.processNull(Biz_Name).equals("")) {
				BaseMerchant chant = (BaseMerchant) this.findOnlyRowByHql(" from BaseMerchant chant where "
						+ " chant.merchantName='"+ Biz_Name.trim() + "'");
				if (chant != null) {
					rs = true;
				} else
					rs = false;
			}
		} catch (Exception e) {
			throw new CommonException(e);
		}
		return rs;
	}

	@Override
	public String saveMer(BaseMerchant merchant, SysActionLog actionLog,
			Users user, BaseMerchant mer_old, StlMode merchantStlMode)
			throws CommonException {
		try {
			publicDao.save(actionLog);
			if (Tools.processNull(merchant.getCustomerId()).equals("")) {//新增保存
				//设置商户编号
				
				//s1 = ((BigDecimal)findOnlyFieldBySql((new StringBuilder("select ")).append(s).append(".nextval from dual").toString())).toString();
				String biz_Id = merchant.getOrgId() + "02" + publicDao.findOnlyFieldBySql("select lpad(SEQ_BIZ_ID.nextval,9,'0') from dual").toString();//生成商户编号
				boolean flag = this.checkBiz_id(biz_Id);//判断是否有相同的商户编号
				if (flag) {
					throw new CommonException("已经存在相同的商户编号！");
				}
				merchantStlMode.getId().setMerchantId(biz_Id);
				merchant.setMerchantId(biz_Id);
				//设置结算模式的商户号height
				merchantStlMode = checkStlmode(merchantStlMode);
				//判断结算模式是否重复
				int a = publicDao.doSql("select merchant_id from Stl_mode where merchant_id='"+merchantStlMode.getId().getMerchantId()+
						"' and VALID_DATE=to_date('"+DateUtil.formatDate(merchantStlMode.getId().getValidDate(), "yyyy-MM-dd HH:mm:ss")+"','yyyy-MM-dd HH24:mi:ss')");
				if(a>0)throw new CommonException("存在相同的结算模式！");
				
				//设置商户状态
				merchant.setMerchantState("2");//设置正常状态
				//设置商户客户号
				merchant.setCustomerId(((BigDecimal)publicDao.findOnlyFieldBySql("select SEQ_CLIENT_ID.nextval from dual")).longValue());
				/*//设置卡表位置
                String mode = this.getSysParaByParaValue("CM_CARD_NUMS").getPara_Value();
                int number = Integer.parseInt(mode);
                String cardIndex = "";//卡号表索引
                if(number > 0){
                	for(int i = 0;i < number;i++){
                		cardIndex = cardIndex + "0";
                	}
                }
                mer.setCard_No_Idx(cardIndex);//默认卡号表索引
*/                //设置服务密码
				merchant.setServPwd(this.encrypt_des("000000",Constants.APP_DES3_DEFAULT));
				//设置错误次数
				merchant.setNetPwdErrNum("0");
				merchant.setServPwdErrNum("0");
                //设置签约信息
				merchant.setSignUserId(actionLog.getUserId());
				merchant.setSignDate(actionLog.getDealTime());
                //保存商户信息
				publicDao.save(merchant);
				//保存商户结算模式
				
				publicDao.save(merchantStlMode);
				//添加账户
				HashMap<String, Object> hm = new HashMap<String, Object>();
				hm.put("obj_type", Sys_Code.CLIENT_TYPE_SH);
				hm.put("sub_type", merchant.getMerchantType()+"");
				hm.put("obj_id", merchant.getCustomerId());
				hm.put("pwd", "");
				actionLog.setDealCode(DealCode.MERCHANT_ACC_ADD);
				accACountService.createAccount(actionLog, hm);
				//添加ftp目录
				//String returnMsg = createFtplib(merchant);
				//return "add"+returnMsg;
				actionLog.setDealCode(DealCode.MERCHANT_ADD);
				TrServRec rec = new TrServRec();
				rec.setCustomerId(merchant.getCustomerId()+"");
				rec.setDealCode(actionLog.getDealCode());
				rec.setDealNo(actionLog.getDealNo());
				rec.setBizTime(actionLog.getDealTime());
				rec.setClrDate(this.getClrDate());
				rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
				rec.setNote(actionLog.getMessage());
				rec.setBrchId(actionLog.getBrchId());//办理网点编号
				rec.setUserId(user.getUserId());//办理操作员编号
				publicDao.save(rec);
				return "add";
			} else {//编辑保存
				publicDao.merge(merchant);
			}
			actionLog.setDealCode(DealCode.MERCHANT_ADD);
			TrServRec rec = new TrServRec();
			rec.setCustomerId(merchant.getCustomerId()+"");
			rec.setDealCode(actionLog.getDealCode());
			rec.setDealNo(actionLog.getDealNo());
			rec.setBizTime(actionLog.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(actionLog.getBrchId());//办理网点编号
			rec.setUserId(user.getUserId());//办理操作员编号
			publicDao.save(rec);
			return "edit";
		} catch (Exception e) {
			e.printStackTrace();
			throw new CommonException(e);
		}
	}
	
	/**
	 * 判断是否存在相同的商户号
	 */
	public boolean checkBiz_id(String biz_id) throws CommonException {
		boolean rs = false;
		try {
			if (!Tools.processNull(biz_id).equals("")) {
				BaseMerchant chant = (BaseMerchant) this
						.findOnlyRowByHql(" from BaseMerchant chant where chant.merchantId='"
								+ biz_id.trim() + "'");
				if (chant != null) {
					rs = true;
				} else
					rs = false;
			}
		} catch (Exception e) {
			throw new CommonException(e);
		}
		return rs;
	}
	
	/**
	 * 结算模式的格式化，仅供本类使用
	 * @param merStlmode
	 * @return
	 */
	public StlMode checkStlmode(StlMode merStlmode){
		if(merStlmode.getStlMode().equals("1")){//全部扎差
			//1.退货结算方式、周期、限额
			merStlmode.setStlWayRet("");//退货结算方式01-日结 02-限额结 03-周结 04 月结05日结+月结 06限额结+月结
			merStlmode.setStlDaysRet("");//退货结算周期（限额结时设置金额，其它每个日期以|分别，如1|2|3，32表示月底最后一天）
			merStlmode.setStlLimRet(null);//退货结算限额
			//2.手续费结算方式、周期、限额
			merStlmode.setStlWayFee("");//手续费结算方式01-日结 02-限额结 03-周结 04 月结05日结+月结 06限额结+月结
			merStlmode.setStlDaysFee("");//手续费结算周期（限额结时设置金额，其它每个日期以|分别，如1|2|3，32表示月底最后一天）
			merStlmode.setStlLimFee(null);//手续费结算限额
			if(merStlmode.getStlWay().equals("02")){
				merStlmode.setStlDays("");
			}else{
				merStlmode.setStlLim(null);
			}
		}else if(merStlmode.getStlMode().equals("2")){//全部不扎差
			if(merStlmode.getStlWay().equals("02")){
				merStlmode.setStlDays("");
			}else{
				merStlmode.setStlLim(null);
			}
			if(merStlmode.getStlWayRet().equals("02")){
				merStlmode.setStlDaysRet("");
			}else{
				merStlmode.setStlLimRet(null);
			}
			if(merStlmode.getStlWayFee().equals("02")){
				merStlmode.setStlDaysFee("");
			}else{
				merStlmode.setStlLimFee(null);
			}
		}else if(merStlmode.getStlMode().equals("3")){//消费退货扎差
			merStlmode.setStlWayRet("");
			merStlmode.setStlDaysRet("");
			merStlmode.setStlLimRet(null);
			if(merStlmode.getStlWay().equals("02")){
				merStlmode.setStlDays("");
			}else{
				merStlmode.setStlLim(null);
			}
			if(merStlmode.getStlWayFee().equals("02")){
				merStlmode.setStlDaysFee("");
			}else{
				merStlmode.setStlLimFee(null);
			}
		}else if(merStlmode.getStlMode().equals("4")){//服务费扎差
			merStlmode.setStlWayFee("");
			merStlmode.setStlDaysFee("");
			merStlmode.setStlLimFee(null);
			if(merStlmode.getStlWay().equals("02")){
				merStlmode.setStlDays("");
			}else{
				merStlmode.setStlLim(null);
			}
			if(merStlmode.getStlWayRet().equals("02")){
				merStlmode.setStlDaysRet("");
			}else{
				merStlmode.setStlLimRet(null);
			}
		}
		return merStlmode;
	}

	/**
	 * 单个商户创建ftp文件夹
	 */
	public String createFtplib(BaseMerchant merchant){
		try {
			/*String ip=(String)dao.findOnlyFieldBySql("select ftp_para_value from SYS_FTP_CONF t where ftp_use = 'TERM_OFFLINE_TRADE' and ftp_para_name = 'IP'");
			String user=(String)dao.findOnlyFieldBySql("select ftp_para_value from SYS_FTP_CONF t where ftp_use = 'TERM_OFFLINE_TRADE' and ftp_para_name = 'USER_NAME'");
			String pwd=(String)dao.findOnlyFieldBySql("select ftp_para_value from SYS_FTP_CONF t where ftp_use = 'TERM_OFFLINE_TRADE' and ftp_para_name = 'PWD'");
			String upload=(String)dao.findOnlyFieldBySql("select ftp_para_value from SYS_FTP_CONF t where ftp_use = 'TERM_OFFLINE_TRADE' and ftp_para_name = 'UPLOAD'");
			String download=(String)dao.findOnlyFieldBySql("select ftp_para_value from SYS_FTP_CONF t where ftp_use = 'TERM_OFFLINE_TRADE' and ftp_para_name = 'DOWNLOAD'");
			String historyfiles=(String)dao.findOnlyFieldBySql("select ftp_para_value from SYS_FTP_CONF t where ftp_use = 'TERM_OFFLINE_TRADE' and ftp_para_name = 'HISTORYFILES'");
			String fail=(String)dao.findOnlyFieldBySql("select ftp_para_value from SYS_FTP_CONF t where ftp_use = 'TERM_OFFLINE_TRADE' and ftp_para_name = 'FAIL'");
			String port=(String)dao.findOnlyFieldBySql("select ftp_para_value from SYS_FTP_CONF t where ftp_use = 'TERM_OFFLINE_TRADE' and ftp_para_name = 'PORT'");

			//String resetfiles=(String)dealTjsj.findOnlyFieldBySql("select ftp_para_value from SYS_FTP_CONF t where ftp_use = 'TERM_OFFLINE_TRADE' and ftp_para_name = 'RESETFILES'");
			//获得ftlClient对象
			FtpClient ftpClient = getFtpClient(ip,user,pwd,Integer.valueOf(port));
			List<String> list = new ArrayList<String>();
			list.add(upload);
			list.add(download);
			list.add(fail);
			list.add(historyfiles);
			//pathLib=/org_id/biz_id
			//String org = (String) dao.findOnlyFieldBySql("select org_Name from Sys_Organ where org_Id='"+merchant.getOrg_Id()+"'");
			String[] path = {"/"+merchant.getOrg_Id(),"/"+merchant.getOrg_Id()+"/"+merchant.getBiz_Id()};
			int a = createLib(ftpClient,path,0,list);
			ftpClient.closeServer();
			if(a!=1){
				return "error";
			}else{
				return "success";
			}*/
			return null;
		} catch (Exception e) {
			throw new CommonException("商户创建ftp目录出错：" + e.getMessage());
		}
	}
	@Override
	public void saveMerchantQuota(PayMerchantLim merLmt,
			SysActionLog actionLog, Users user) throws CommonException {
		try {
			actionLog.setDealCode(DealCode.MERCHANT_CONSUME_LMT);
			publicDao.save(actionLog);
			publicDao.merge(merLmt);
			TrServRec rec = new TrServRec();
			BaseMerchant merchant = (BaseMerchant)this.findOnlyRowByHql("from BaseMerchant where merchantId='"+merLmt.getMerchantId()+"'");
			if(merchant == null){
				throw new CommonException("商户已被删除，不能进行编辑！");
			}
			rec.setCustomerId(merchant.getCustomerId()+"");
			rec.setDealNo(actionLog.getDealNo());
			rec.setBizTime(actionLog.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(actionLog.getBrchId());//办理网点编号
			rec.setUserId(user.getUserId());//办理操作员编号
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException("发生错误：" + e.getMessage());
		}
		
	}
	@Override
	public void saveMerchantConsLmt(String acckinds, String merchantId,
			SysActionLog actionLog) throws CommonException {
		
		try {
			actionLog.setDealCode(DealCode.MERCHANT_ACCKIND_LMT);
			
			//acckinds 用逗号分隔
			if(acckinds.equals("")){
				actionLog.setMessage("删除账户关联信息");
				publicDao.doSql("delete from pay_merchant_AccType where merchant_id='"+merchantId+"'");
			}else{
				publicDao.doSql("delete from pay_merchant_AccType where  merchant_id='"+merchantId+"' and acc_kind not in("+acckinds+")");
				String[] acckindarray = acckinds.split("\\,");
				for(int i=0;i<acckindarray.length;i++){
					PayMerchantAcctypeId  accId = new PayMerchantAcctypeId();
					accId.setMerchantId(merchantId);
					accId.setAccKind(acckindarray[i].trim());
					PayMerchantAcctype  accType =  new PayMerchantAcctype();
					accType.setId(accId);
					publicDao.merge(accType);
				}
			}
			publicDao.save(actionLog);
			TrServRec rec = new TrServRec();
			BaseMerchant merchant = (BaseMerchant)this.findOnlyRowByHql("from BaseMerchant where merchantId='"+merchantId+"'");
			rec.setCustomerId(merchant.getCustomerId()+"");
			rec.setDealNo(actionLog.getDealNo());
			rec.setBizTime(actionLog.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(actionLog.getBrchId());//办理网点编号
			rec.setUserId(actionLog.getUserId());//办理操作员编号
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException("发生错误：" + e.getMessage());
		}
	}
	@Override
	public void saveMerchantStlMode(StlMode mode, SysActionLog actionLog)
			throws CommonException {
		try {
			actionLog.setDealCode(DealCode.SETTLEMENT_MODE_EIDT);
			publicDao.merge(checkStlmode(mode));
			publicDao.save(actionLog);
			TrServRec rec = new TrServRec();
			BaseMerchant merchant = (BaseMerchant)this.findOnlyRowByHql("from BaseMerchant where merchantId='"+mode.getId().getMerchantId()+"'");
			rec.setCustomerId(merchant.getCustomerId()+"");
			rec.setDealNo(actionLog.getDealNo());
			rec.setBizTime(actionLog.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(actionLog.getBrchId());//办理网点编号
			rec.setUserId(actionLog.getUserId());//办理操作员编号
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException("发生错误：" + e.getMessage());
		}
	}
	@Override
	public void delMerMode(String merchantId, String valilDate,SysActionLog actionLog)
			throws CommonException {
		try {
			actionLog.setDealCode(DealCode.SETTLEMENT_MODE_DEL);
			actionLog.setMessage("商户结算模式删除");
			publicDao.save(actionLog);
			publicDao.doSql("delete from stl_mode t where t.merchant_id = '"+merchantId+"' and to_char(t.VALID_DATE,'yyyy-mm-dd')='"+valilDate+"'");
			TrServRec rec = new TrServRec();
			BaseMerchant merchant = (BaseMerchant)this.findOnlyRowByHql("from BaseMerchant where merchantId='"+merchantId+"'");
			rec.setCustomerId(merchant.getCustomerId()+"");
			rec.setDealNo(actionLog.getDealNo());
			rec.setBizTime(actionLog.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(actionLog.getBrchId());//办理网点编号
			rec.setUserId(actionLog.getUserId());//办理操作员编号
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException("发生错误：" + e.getMessage());
		}
	}
	@Override
	public void saveClr_Fee_Rate(PayFeeRate payFeeRate, SysActionLog actionLog,
			Users users, String dealType, List list) throws CommonException {
		try {
			Long id=null;
			publicDao.save(actionLog);
			BaseMerchant bm = (BaseMerchant) this.findOnlyRowByHql("from BaseMerchant where merchantId='"+ payFeeRate.getMerchantId() + "'");
			if (bm == null)
				throw new CommonException("该商户信息不存在");
			//删除分段费率信息
			publicDao.doSql("delete from Pay_Fee_Rate_Section where fee_Rate_Id="+payFeeRate.getFeeRateId());
			if (Tools.processNull(dealType).equals("1")) {// 新增
				String hql = "select c from PayFeeRate c "
						+ " where c.merchantId = '" + payFeeRate.getMerchantId()
						+ "' and c.dealCode = '" + payFeeRate.getDealCode() + "' and to_char(c.begindate,'yyyy-MM-dd') = '"
						+DateUtil.formatDate(payFeeRate.getBegindate(), "yyyy-MM-dd")+"'";
				List list1 = this.findByHql(hql);
				if (list1 != null && list1.size() > 0)
					throw new CommonException("商户预设费率重复，不可添加！");
				payFeeRate.setInsertDate(actionLog.getDealTime());// 费率创建时间
				payFeeRate.setUserId(actionLog.getUserId());// 创建操作员
				payFeeRate.setChkState(Sys_Code.SH_STATE_DSH);//新增待审核
				id = (Long)publicDao.save(payFeeRate);
				
			} else if(Tools.processNull(dealType).equals("2")) {// 修改
				publicDao.merge(payFeeRate);
			}else{
				throw new  CommonException("参数错误");
			}
			if(payFeeRate.getHaveSection().equals(Sys_Code.HAVE_SECTION_S)){
				for(int j=0;j<list.size();j++){
					PayFeeRateSection sect =  (PayFeeRateSection)list.get(j);
					if(Tools.processNull(dealType).equals("1")){
						 sect.getId().setFeeRateId(id);
						 publicDao.save(sect);
					}else{
						publicDao.merge(sect);
					}
					
				}
			}
			
			//综合业务记录 Tr_Serv_Rec_年份
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());//业务流水号
			rec.setDealCode(actionLog.getDealCode());//交易代码
			rec.setBizTime(actionLog.getDealTime());//业务办理时间
			rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(users.getBrchId());//办理网点编号
			rec.setUserId(users.getUserId());//办理操作员编号
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
		
	}
	@Override
	public void chkRate(PayFeeRate payFeeRate, SysActionLog actionLog,
			Users users) throws CommonException {
		try {
			actionLog.setMessage("商户费率审核");
			publicDao.save(actionLog);
			publicDao.doSql("update pay_fee_rate set chk_state='0' , chk_user_id='"+users.getUserId()+"',chk_date=to_date('"+DateUtil.formatDate(actionLog.getDealTime(),"yyyy-MM-dd HH:mm:ss")+"','yyyy-mm-dd hh24:mi:ss') where fee_rate_id='"+payFeeRate.getFeeRateId()+"'");
			//综合业务记录 Tr_Serv_Rec_年份
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());//业务流水号
			rec.setDealCode(actionLog.getDealCode());//交易代码
			rec.setBizTime(actionLog.getDealTime());//业务办理时间
			rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(users.getBrchId());//办理网点编号
			rec.setUserId(users.getUserId());//办理操作员编号
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e);
		}
		
		
	}
	@Override
	public void delRate(PayFeeRate payFeeRate, SysActionLog actionLog,
			Users users) throws CommonException {
		try {
			actionLog.setMessage("商户费率删除即停用");
			publicDao.save(actionLog);
			publicDao.doSql("update pay_fee_rate set fee_state='1' where fee_rate_id='"+payFeeRate.getFeeRateId()+"'" );
			//综合业务记录 Tr_Serv_Rec_年份
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());//业务流水号
			rec.setDealCode(actionLog.getDealCode());//交易代码
			rec.setBizTime(actionLog.getDealTime());//业务办理时间
			rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(users.getBrchId());//办理网点编号
			rec.setUserId(users.getUserId());//办理操作员编号
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e);
		}
		
	}
	@Override
	public void saveMerTerm(BaseTagEnd tagEnd, SysActionLog actionLog,
			Users users) throws CommonException {
		try {
			if(Tools.processNull(tagEnd.getEndId()).equals("")){
				actionLog.setMessage("终端信息新增");
			}else{
				actionLog.setMessage("终端信息修改");
			}
			publicDao.save(actionLog);
			tagEnd.setEndState("0");
			if(Tools.processNull(tagEnd.getEndId()).equals("")){
				publicDao.save(tagEnd);
			}else{
				publicDao.merge(tagEnd);
			}
			
			//综合业务记录 Tr_Serv_Rec_年份
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());//业务流水号
			rec.setDealCode(actionLog.getDealCode());//交易代码
			rec.setBizTime(actionLog.getDealTime());//业务办理时间
			rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(users.getBrchId());//办理网点编号
			rec.setUserId(users.getUserId());//办理操作员编号
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	@Override
	public void savesettlementAudit(SysActionLog actionLog,Users operator, String[] ids)
			throws CommonException {
		try {
			// 保存系统日志
			actionLog.setDealCode(DealCode.MERCHANT_SETTLEMENT);
			actionLog.setMessage("商户结算审核");
			publicDao.save(actionLog);
			String logmsg="";
			for(int i = 0; i < ids.length; i++){
				List<StlDealSum> tradeSums = (List<StlDealSum>) this.findByHql("from StlDealSum  where id.stlSumNo = "+ ids[i]);
				if (tradeSums == null) {
					throw new CommonException("商户结算汇总表没有该记录：" + ids[i]);
				}
				logmsg+=ids[i]+",";
				for(int j=0;j<tradeSums.size();j++){
					if (tradeSums.get(j).getStlState().equals(Sys_Code.STL_STATE_ZF)) {	
						throw new CommonException("已支付，不能再审核：" + tradeSums.get(j).getId().getStlSumNo() +","+tradeSums.get(j).getId().getCardType()+","
								+tradeSums.get(j).getId().getAccKind());
					}

					tradeSums.get(j).setStlState(Sys_Code.STL_STATE_SH);
					tradeSums.get(j).setChkDate(actionLog.getDealTime());
					tradeSums.get(j).setChkUserId(operator.getUserId());
					publicDao.update(tradeSums.get(j));
				}
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealCode(actionLog.getDealCode());
			rec.setBizTime(actionLog.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setRsvOne(logmsg);
			rec.setBrchId(operator.getBrchId());//办理网点编号
			rec.setUserId(operator.getUserId());//办理操作员编号
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
	@Override
	public void saverollback(SysActionLog actionLog, Users operator, String stlNo)
			throws CommonException {
		try {
			actionLog.setDealCode(DealCode.MERCHANT_SETTLEMENT_ROLLBACK);
			actionLog.setMessage("商户结算回退");
			actionLog.setDealTime(this.getDateBaseTime());
			Long actionNo = (Long)publicDao.save(actionLog);
			SysActionLog log = (SysActionLog)this.findOnlyRowByHql("from SysActionLog where dealNo='"+actionNo+"'");
			HashMap hm = new HashMap();
			hm.put("stl_sum_no", stlNo);
			accACountService.merchantSettleRollback(log, hm);
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealCode(actionLog.getDealCode());
			rec.setBizTime(actionLog.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(operator.getBrchId());//办理网点编号
			rec.setUserId(operator.getUserId());//办理操作员编号
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e);
		}
		
	}
	@Override
	public SysActionLog savePrintReport(SysActionLog actionLog, Users operator,String stlNos) throws CommonException {
		SysActionLog actionLognew = null;
		try {
			
			Serializable ser = publicDao.save(actionLog);
			actionLognew= (SysActionLog)this.findOnlyRowByHql("from SysActionLog where dealNo='"+ser.toString()+"'");
			if(stlNos!=null){
				publicDao.doSql("update stl_Deal_sum set stl_state='2' , exp_date=to_date('"+DateUtil.formatDate(actionLognew.getDealTime())+"','yyyy-MM-dd hh24:mi:ss')"
						+ ", exp_user_id='"+operator.getUserId()+"' where stl_sum_no in (" + stlNos + ") and stl_state <= '2'");
			}
		} catch (Exception e) {
			throw new CommonException(e);
		}
		return actionLognew;
	}
	@SuppressWarnings("unchecked")
	@Override
	public void savesettlementPayment(SysActionLog actionLog, Users operator,
			String ids, String bankSheetNo) throws CommonException {
		SysActionLog actionLognew = null;
		try{

			/**
			 * 要支付的结算记录  STL_SUM_NO$CARD_TYPE$ACC_KIND,STL_SUM_NO$CARD_TYPE$ACC_KIND
			 */
			Serializable ser = publicDao.save(actionLog);
			actionLognew= (SysActionLog)this.findOnlyRowByHql("from SysActionLog where dealNo='"+ser.toString()+"'");
			
			List<StlDealSum> listsum =(List<StlDealSum>) this.findByHql("from StlDealSum where id.stlSumNo in("+ids+")");
			if(listsum==null||listsum.size()==0){
				throw new CommonException("没有找到可以支付的数据！");
			}
			String inone = "";
			for(int i=0;i<listsum.size();i++){
				if(i==listsum.size()-1){
					inone+=listsum.get(i).getId().getStlSumNo()+"$"+listsum.get(i).getId().getCardType()+"$"+listsum.get(i).getId().getAccKind();
				}else{
					inone+=listsum.get(i).getId().getStlSumNo()+"$"+listsum.get(i).getId().getCardType()+"$"+listsum.get(i).getId().getAccKind()+",";
				}
				
			}
			
			
			HashMap hm = new HashMap();
			hm.put("stlsumnos", inone);
			
			hm.put("bank_sheet_no", bankSheetNo);
			accACountService.merchantSettlePay(actionLog, hm);
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setDealCode(actionLog.getDealCode());
			rec.setBizTime(actionLog.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Sys_Code.STATE_ZC);//业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(operator.getBrchId());//办理网点编号
			rec.setUserId(operator.getUserId());//办理操作员编号
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	
		
	}
	@SuppressWarnings("unchecked")
	@Override
	public void saveConsumeMode(SysActionLog actionLog, Users operator,
			PayAcctypeSqn paySqn) throws CommonException {
		try {
			if(Tools.processNull(paySqn.getModeId()).equals("")){//新增
				actionLog.setMessage("添加商户消费模式，模式名称为："+paySqn.getModeName());
			}else if(!Tools.processNull(paySqn.getModeId()).equals("")){//修改
				actionLog.setMessage("修改商户消费模式，模式名称为："+paySqn.getModeName());
			}
			publicDao.merge(paySqn);
		} catch (Exception e) {
			throw new CommonException("保存商户消费模式出错："+e.getMessage());
		}
	}
	@SuppressWarnings("unchecked")
	@Override
	public void saveMerGetCosMode(SysActionLog actionLog, Users operator,
			String merchantId, String modeIds) throws CommonException {
		try {
			publicDao.save(actionLog);
			String[] ids = modeIds.split("\\,");
			String modeType = "";
			for (int i = 0; i < ids.length; i++) {
				//判断MODEtype类型
				PayAcctypeSqn sqn = (PayAcctypeSqn)this.findOnlyRowByHql("from PayAcctypeSqn where modeId='"+ids[i].toString().trim()+"'");
				if(sqn==null){
					throw new CommonException("消费模式系统不存在："+ids[i]);
				}
				//判断是不是存在了该消费模式
				BigDecimal modeCount = (BigDecimal)this.findOnlyFieldBySql("select count(1) from base_merchant_mode "
						+ " where merchant_id = '"+merchantId+"' and mode_id='"+ids[i]+"'");
				if(modeCount.intValue()>0){
					throw new CommonException("已存在相同的结算模式，请重新选择或点击编辑按钮后重新启用");
				}
				if(sqn.getAccSqn().split("\\|").length>1){
					modeType = "1";
				}else{
					modeType = "0";
				}
				publicDao.doSql("insert into base_merchant_mode(merchant_id,mode_id,mode_type,mode_state,note)"
						+ " values('"+merchantId+"','"+ids[i].toString().trim()+"','"+modeType+"','0','新增')");
			}
		} catch (Exception e) {
			throw new CommonException("保存商户消费模式设置发生错误："+e.getMessage());
		}
	}
	@Override
	public void saveMerGetCosModeEdit(SysActionLog actionLog, Users operator,
			String merchantId, String modeId,String modeState) throws CommonException {
		try {
			publicDao.save(actionLog);
			publicDao.doSql("update base_merchant_mode set mode_state = '"+modeState+"' where merchant_id ='"+merchantId+"' and mode_id='"+modeId+"'" );
		} catch (Exception e) {
			throw new CommonException("保存商户消费模式设置发生错误："+e.getMessage());
		}
	}
	/**
	 * 更新商户状态信息
	 * @param customerId
	 * @param user
	 * @param actionLog
	 * @param queryType
	 * @throws CommonException
	 */
	@SuppressWarnings({ "unused", "unchecked" })
	@Override
	public void updateState(Long customerId, Users user,SysActionLog actionLog, String queryType) throws CommonException {
		try {
			//1.基本条件判断
			String string = "";
			Integer tempdealcode = 0;
			String state = "-1";
			String accState="";
			if(Tools.processNull(queryType).equals("0")){
				string = "审核通过";
				tempdealcode = DealCode.MERCHANT_CHECK_YES;
				state = "0";
				accState="0";
			}else if(Tools.processNull(queryType).equals("1")){
				string = "注销";
				tempdealcode = DealCode.MERCHANT_CHECK_YES;
				state = "1";
				accState="9";
			}else if(Tools.processNull(queryType).equals("2")){
				string = "待审核";
				tempdealcode = DealCode.MERCHANT_CHECK_YES;
				state = "0";
				accState="0";
			}else if(Tools.processNull(queryType).equals("3")){
				string = "暂停";
				tempdealcode = DealCode.MERCHANT_CHECK_NO;
				state = "3";
				accState="4";
			}else if(Tools.processNull(queryType).equals("9")){
				string = "审核不通过";
				tempdealcode = DealCode.MERCHANT_CHECK_NO;
				state = "9";
			}else{
				throw new CommonException("传入操作类型错误！");
			}
			//2.记录操作日志
			actionLog.setDealCode(tempdealcode);
			actionLog.setMessage("更新商户的状态=" + queryType);
			publicDao.save(actionLog);
			//更新商户的状态
			publicDao.doSql("update base_merchant t set t.merchant_state = '"+queryType+"' where t.customer_id ="+customerId );
			//更新商户账户的状态
			publicDao.doSql("update acc_account_sub s set s.acc_state='"+state+"'  where s.customer_id='"+customerId+"' ");
		} catch (Exception e) {
			throw new CommonException("保存商户状态发生错误："+e.getMessage());
		}
		
		
	}
	@SuppressWarnings("unchecked")
	@Override
	public void saveMerSettleImmediate(String merchantId, Users user) {
		try {
			if(merchantId==null||merchantId.trim().equals("")){
				throw new CommonException("商户编号为空.");
			}
			if(user==null){
				throw new CommonException("操作柜员为空.");
			}
			
			List<Object>in = new ArrayList<Object>();
			in.add(merchantId);
			in.add(user.getUserId());
			
			List<Integer>outType = new ArrayList<Integer>();
			outType.add(java.sql.Types.VARCHAR);
			outType.add(java.sql.Types.VARCHAR);
			
			List<Object> ret = publicDao.callProc("pk_merchantsettle.p_settle_immediate", in, outType);
			
			if(ret==null||ret.isEmpty()){
				throw new CommonException("调用即时结算过程失败.");
			}
			
			if(!ret.get(0).toString().equals("00000000")){
				String errMsg = "调用结算过程失败";
				if(ret.size()==2){
					errMsg += ", " + ret.get(1);
				}
				throw new CommonException(errMsg);
			}
			
		} catch (Exception e) {
			throw new CommonException("商户即时结算失败, " + e.getMessage());
		}
	}
	/**
	 * 终端信息报废
	 * @param endid
	 * @param actionLog
	 * @throws CommonException
	 */
	@Override
	public void delTermInfo(String endid, SysActionLog actionLog)
			throws CommonException {
		try {
			Users users=this.getSessionUser();
			actionLog.setDealCode(DealCode.TERMINAL_CANCEL);
			actionLog.setMessage("终端信息报废");
			publicDao.save(actionLog);
			//终端状态0-未启用1-启用9-注销
			publicDao.doSql("update  base_tag_end b set b.end_State='3',b.cls_User_Id='"+users.getUserId()+"', cls_Date=to_date('"+DateUtil.formatDate(getDateBaseTime(), "yyyy-MM-dd HH:mm:ss")+"','yyyy-MM-dd HH24:mi:ss') where b.end_id="+Tools.processLong(endid));
		} catch (Exception e) {
			throw new CommonException("发生错误：" + e.getMessage());
		}
		
	}
    /**
	 * 终端信息报修
     * @param endid
     * @param maintCorp
     * @param maintPhone
     * @param actionLog
     * @throws CommonException
     */
	@Override
	public void updateTermRepairs(String endid, String maintCorp, String maintPhone,String note,Date maintPeriod, SysActionLog actionLog) throws CommonException {
		try {
			actionLog.setDealCode(DealCode.TERMINAL_EDIT);
			actionLog.setMessage("终端信息报修");
			publicDao.save(actionLog);
			//终端状态0-未启用1-启用9-注销
			publicDao.doSql("update  base_tag_end b set b.maint_Corp='"+maintCorp+"',b.end_state='"+2+"',b.maint_Phone='"+maintPhone+"',b.note='"+note+"',b.maint_Period=to_date('"+DateUtil.formatDate(maintPeriod, "yyyy-MM-dd")+"','yyyy-MM-dd')  where b.end_id="+Tools.processLong(endid));
		} catch (Exception e) {
			throw new CommonException("发生错误：" + e.getMessage());
		}
	}
	
	/**
	 * 商户终端回收
	 */
	@Override
	public void updateRecycle(String endid, String recycleDate,
			String recycleUserId, Date recycleTime, SysActionLog actionLog)
			throws CommonException {
		try {
			actionLog.setDealCode(DealCode.TERMINAL_EDIT);
			actionLog.setMessage("终端回收");
			publicDao.save(actionLog);
			publicDao.doSql("update  base_tag_end b set b.RECYCLE_DATE='"+recycleDate+"',b.end_state='5',b.RECYCLE_USER_ID='"+recycleUserId+"',b.RECYCLE_TIME=to_date('"+DateUtil.formatDate(recycleTime, "yyyy-MM-dd HH:mm:ss")+"','yyyy-MM-dd HH24:mi:ss')  where b.end_id="+Tools.processLong(endid));
		} catch (Exception e) {
			throw new CommonException("发生错误：" + e.getMessage());
		}
		
	}
	/**
	 * 商户终端出库信息保存
	 */
	@Override
	public void saveOutbound(BaseEndOut baseEndOut,String endid)
			throws CommonException {
		try {	
			SysActionLog actionLog = this.getCurrentActionLog();
			actionLog.setDealCode(DealCode.TERMINAL_EDIT);
			actionLog.setMessage("商户终端出库信息保存");
			publicDao.save(actionLog);
			Users user=this.getSessionUser();	
			baseEndOut.setOutId(endid);
			baseEndOut.setUserId(user.getUserId());
			baseEndOut.setOperTime(getDateBaseTime());
			publicDao.save(baseEndOut);			
			publicDao.doSql("update  base_tag_end b set b.end_state='4' where b.end_id="+Tools.processLong(endid));
		} catch (Exception e) {
			throw new CommonException(e);
		}
		
	}
	/**
	 * 商户终端启用注销
	 */
	@Override
	public void saveDisableOrEnableMerTer(String endId, String type)
			throws CommonException {
		SysActionLog actionLog = this.getCurrentActionLog();
		actionLog.setDealCode(DealCode.TERMINAL_EDIT);
		actionLog.setMessage("商户终端启用或注销");
		publicDao.save(actionLog);
		Users user=this.getSessionUser();	
		if(Tools.processNull(type).equals("1")){
			publicDao.doSql("update  base_tag_end b set b.end_state='1',b.REG_USER_ID='"+user.getUserId()+"',b.REG_DATE=to_date('"+DateUtil.formatDate(getDateBaseTime(), "yyyy-MM-dd HH:mm:ss")+"','yyyy-MM-dd HH24:mi:ss')  where b.end_id="+Tools.processLong(endId));
		}else if(Tools.processNull(type).equals("9")){
			publicDao.doSql("update  base_tag_end b set b.end_state='9',b.CLS_USER_ID='"+user.getUserId()+"',b.CLS_DATE=to_date('"+DateUtil.formatDate(getDateBaseTime(), "yyyy-MM-dd HH:mm:ss")+"','yyyy-MM-dd HH24:mi:ss')  where b.end_id="+Tools.processLong(endId));
		}
		// TODO Auto-generated method stub
		
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveMerTerm(BaseTagEnd tagEnd, String type) {
		try {
			// 1.日志
			if (tagEnd == null || tagEnd.getEndId() == null) {
				throw new CommonException("终端信息为空");
			}
			
			SysActionLog actionLog = getCurrentActionLog();
			if (Tools.processNull(type).equals("0")) {
				actionLog.setDealCode(DealCode.TERMINAL_ADD);
				tagEnd.setRegUserId(getUser().getUserId());
				tagEnd.setRegDate(getDateBaseDate());
				tagEnd.setLoginFlag("0");
			} else {
				actionLog.setDealCode(DealCode.TERMINAL_EDIT);
			}
			publicDao.save(actionLog);
			
			// 2.
			tagEnd.setEndState("0");
			if (Tools.processNull(type).equals("0")) {
				BaseTagEnd end = (BaseTagEnd) findOnlyRowByHql("from BaseTagEnd where endId = '" + tagEnd.getEndId() + "'");
				if (end != null) {
					throw new CommonException("编号为[" + tagEnd.getEndId() + "]的终端已经存在");
				}
				
				publicDao.save(tagEnd);
			} else {
				publicDao.merge(tagEnd);
			}

			// 综合业务记录 Tr_Serv_Rec_年份
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());// 业务流水号
			rec.setDealCode(actionLog.getDealCode());// 交易代码
			rec.setBizTime(actionLog.getDealTime());// 业务办理时间
			rec.setDealState(Sys_Code.STATE_ZC);// 业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(actionLog.getBrchId());// 办理网点编号
			rec.setUserId(actionLog.getUserId());// 办理操作员编号
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException("保存终端信息失败.", e);
		}
	}
	@Override
	public void saveOutboundCancel(String endId) {
		try {	
			SysActionLog actionLog = this.getCurrentActionLog();
			actionLog.setDealCode(DealCode.TERMINAL_EDIT);
			actionLog.setMessage("商户终端出库撤销");
			publicDao.save(actionLog);
			
			BaseEndOut baseEndOut = (BaseEndOut) findOnlyRowByHql("from BaseEndOut where outId = '" + endId + "' order by endOutId desc");
			if (baseEndOut == null) {
				throw new CommonException("出库记录不存在.");
			}
			publicDao.delete(baseEndOut);
			
			publicDao.doSql("update  base_tag_end b set b.end_state='0' where b.end_id='" + endId + "'");
		
			TrServRec rec = new TrServRec(actionLog.getDealNo(), actionLog.getDealTime(), actionLog.getUserId());
			rec.setNote(actionLog.getMessage());
			rec.setClrDate(getClrDate());
			rec.setBrchId(actionLog.getBrchId());
			rec.setOrgId(actionLog.getOrgId());
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException("终端出库撤销失败.", e);
		}
	}
	@Override
	public List<BaseTagEnd> saveMerTerm(List<BaseTagEnd> terminals) {
		try {
			// 1.日志
			if (terminals == null || terminals.isEmpty()) {
				throw new CommonException("终端信息为空");
			}
			
			SysActionLog actionLog = getCurrentActionLog();
			actionLog.setDealCode(DealCode.TERMINAL_BATCH_ADD);
			publicDao.save(actionLog);
			
			// 2.
			List<BaseTagEnd> failList = new ArrayList<BaseTagEnd>();
			for(BaseTagEnd tagEnd:terminals){
				try {
					if (tagEnd.getEndId() == null) {
						throw new CommonException("终端编号为空！");
					} else if (Tools.processNull(tagEnd.getEndName()).equals("")) {
						throw new CommonException("终端名称为空！");
					} else if (Tools.processNull(tagEnd.getInsLocation()).equals("")) {
						throw new CommonException("终端安装位置为空！");
					} else if (tagEnd.getInsDate() == null) {
						throw new CommonException("终端安装日期为空！");
					}
					
					tagEnd.setEndState("0");
					tagEnd.setRegUserId(getUser().getUserId());
					tagEnd.setRegDate(getDateBaseDate());
					tagEnd.setLoginFlag("0");
					
					BaseTagEnd end = (BaseTagEnd) findOnlyRowByHql("from BaseTagEnd where endId = '" + tagEnd.getEndId() + "'");
					if (end != null) {
						throw new CommonException("编号为[" + tagEnd.getEndId() + "]的终端已经存在");
					}

					publicDao.save(tagEnd);
				} catch (Exception e) {
					tagEnd.setNote(e.getMessage());
					failList.add(tagEnd);
				}
			}

			// 综合业务记录 Tr_Serv_Rec_年份
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());// 业务流水号
			rec.setDealCode(actionLog.getDealCode());// 交易代码
			rec.setBizTime(actionLog.getDealTime());// 业务办理时间
			rec.setDealState(Sys_Code.STATE_ZC);// 业务状态(0正常1撤销)
			rec.setNote(actionLog.getMessage());
			rec.setBrchId(actionLog.getBrchId());// 办理网点编号
			rec.setUserId(actionLog.getUserId());// 办理操作员编号
			rec.setClrDate(getClrDate());
			publicDao.save(rec);
			
			return failList;
		} catch (Exception e) {
			throw new CommonException("保存终端信息失败.", e);
		}
	}

	/**
	 * @author Yueh
	 * @param bindSection
	 * @param log
	 */
	@SuppressWarnings("unchecked")
	@Override
	public void saveAddCardOrgBindSection(CardOrgBindSection bindSection, SysActionLog log) {
		try {
			if (bindSection == null) {
				throw new CommonException("发卡方机构信息为空！");
			} else if (Tools.processNull(bindSection.getBindSection()).equals("")) {
				throw new CommonException("发卡方机构卡号段为空！");
			} else if (Tools.processNull(bindSection.getCardOrgId()).equals("")) {
				throw new CommonException("发卡方机构编号为空！");
			} else if (Tools.processNull(bindSection.getCardOrgName()).equals("")) {
				throw new CommonException("发卡方机构名称为空！");
			} else if (Tools.processNull(bindSection.getAcptId()).equals("")) {
				throw new CommonException("发卡方机构结算商户为空！");
			}
			log.setDealCode(DealCode.ADD_CARD_ORG_BIND_SECTION);
			log.setMessage("新增发卡方信息，卡号段：" + bindSection.getBindSection());
			publicDao.save(log);
			
			//
			BaseMerchant merchant = (BaseMerchant) findOnlyRowByHql("from BaseMerchant where merchantId = '" + bindSection.getAcptId() + "'");
			if (merchant == null) {
				throw new CommonException("发卡方机构结算商户【" + bindSection.getAcptId() + "】不存在！");
			}
			
			//
			CardOrgBindSection bindSection2 = (CardOrgBindSection) findOnlyRowByHql("from CardOrgBindSection where bindSection = '" + bindSection.getBindSection() + "'");
			if (bindSection2 != null) {
				throw new CommonException("卡号段为【" + bindSection.getBindSection() + "】的发卡方机构信息已经存在！");
			}
			
			//
			bindSection.setOrgId(log.getOrgId());
			bindSection.setBrchId(log.getBrchId());
			bindSection.setUserId(log.getUserId());
			bindSection.setLastModifyDate(log.getDealTime());
			bindSection.setState(Constants.STATE_ZC);
			publicDao.save(bindSection);
			
			//
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setClrDate(getClrDate());
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
}

