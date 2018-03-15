package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.CardAppBind;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardInsuranceInfo;
import com.erp.model.CardInsuranceInfoId;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.service.AccAcountService;
import com.erp.service.DoWorkClientService;
import com.erp.service.ZxcService;
import com.erp.util.Arith;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.ZxcModel;
@Service("zxcService")
public class ZxcServiceImpl extends BaseServiceImpl implements ZxcService {
	@Resource(name="doWorkClientService")
	private DoWorkClientService doWorkClientService;
	@Resource(name="accAcountService")
	private AccAcountService accAcountService;

	
	/**
	 * 自行车应用开通
	 * @param person
	 * @param log
	 * @param zxcModel
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	@Override
	public TrServRec saveZxcOpen(BasePersonal personal, SysActionLog log,ZxcModel zxcModel) throws CommonException {
		TrServRec rec=new TrServRec();
		String flag="0";//0是现金，1转账
		try{
			//1、记录日志
			log.setDealCode(DealCode.ZXC_APP_OPEN);
			log.setMessage("自行车应用开通,卡号："+zxcModel.getCardno());
			publicDao.save(log);
			CardBaseinfo card=(CardBaseinfo)this.findOnlyRowByHql("from CardBaseinfo c where c.cardNo='"+zxcModel.getCardno()+"'");
			//2、调用接口
			zxcModel.setTrdate(publicDao.getDateBaseTimeStr("yyyyMMdd"));
			zxcModel.setTrdate(publicDao.getDateBaseTimeStr("hhmmss"));
			com.alibaba.fastjson.JSONArray jsonArray =(com.alibaba.fastjson.JSONArray) doWorkClientService.saveZxc(personal, zxcModel, "bk10001");
			//data=流水号，卡号，金额，交易类型，终端编号 或 psam卡号，终端交易序号(psam卡交易序号)，交易时间(yyyymmddhhmmss)，TAC
			JSONObject return_first = jsonArray.getJSONObject(0);
			String errcode=return_first.getString("errcode");
			String errmessage=return_first.getString("errmessage");
			if(!Tools.processNull(errcode).equals("00")){
				throw new CommonException("开通保存失败："+errmessage);
			}
			//3、押金记账
			if(Tools.processInt(zxcModel.getAmt())*100>0){
				
				accAcountService.zxcjz(Constants.ACPT_TYPE_GM, log.getUserId(), Tools.processLong(zxcModel.getAmt())*100, flag, log);
			}
			//4、保存业务记录
			rec.setDealCode(log.getDealCode());	
			rec.setDealNo(log.getDealNo());
			rec.setNote(log.getMessage());
			rec.setCardNo(zxcModel.getCardno());
			rec.setAmt(Tools.processLong(zxcModel.getAmt()));
			rec.setCertNo(personal.getCertNo());
			rec.setCardType(card.getCardType());
			rec.setCardId(card.getCardId());
			rec.setCardTrCount("1");
			rec.setBrchId(log.getBrchId());
			rec.setUserId(log.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setOrgId(log.getOrgId());
			rec.setCustomerName(personal.getName());
			rec.setClrDate(this.getClrDate());
			publicDao.save(rec);
			//5、插入绑定表
			CardAppBind bind=new CardAppBind();
			bind.setBindDate(publicDao.getDateBaseDate());
			bind.setBindState("0");//绑定状态 0-是 1-否
			bind.setCardNo(zxcModel.getCardno());
			bind.setDealNo(log.getDealNo());
			bind.setAppType("05");//各应用绑定类型( 01-广电 02-自来水 03-电力 04-过路过桥 05-自行车 06-移动）
			bind.setNote(log.getMessage());
			bind.setUserId(log.getUserId());
			bind.setBrchId(log.getBrchId());
			publicDao.save(bind);
			//6、更新绑定信息
			CardAppBind cancelbind=(CardAppBind)this.findOnlyRowByHql("select c from CardAppBind c ,TrServRec t where c.dealNo=t.dealNo and c.appType='05' and bindState='0' and c.cardNo='"+zxcModel.getCardno()+"' and t.dealCode="+DealCode.ZXC_APP_CANCEL+" order by c.bindDate desc ");
			if(cancelbind!=null){
				cancelbind.setBindState("1");
				publicDao.update(cancelbind);
			}
			//7.保存报表信息
			this.saveSysReport(log,reportSetValue(rec),"/reportfiles/GuaShiJieGuaZhuXiaoPZ.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
		  return rec;		
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 自行车应用取消
	 * @param person
	 * @param log
	 * @param zxcModel
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	@Override
	public TrServRec saveZxcCancel(BasePersonal personal, SysActionLog log,ZxcModel zxcModel) throws CommonException {
		TrServRec rec=new TrServRec();
		String flag="0";//0是现金，1转账
		try{
			//1、写日志
			log.setDealCode(DealCode.ZXC_APP_CANCEL);
			log.setMessage("自行车应用开通,卡号："+zxcModel.getCardno());
			publicDao.save(log);
			CardBaseinfo card=(CardBaseinfo)this.findOnlyRowByHql("from CardBaseinfo c where c.cardNo='"+zxcModel.getCardno()+"'");
			//2、调用取消接口
			zxcModel.setTrdate(publicDao.getDateBaseTimeStr("yyyyMMdd"));
			zxcModel.setTrdate(publicDao.getDateBaseTimeStr("hhmmss"));
			com.alibaba.fastjson.JSONArray jsonArray =(com.alibaba.fastjson.JSONArray) doWorkClientService.saveZxc(personal, zxcModel, "bk10002");
			//data=流水号，卡号，金额，交易类型，终端编号 或 psam卡号，终端交易序号(psam卡交易序号)，交易时间(yyyymmddhhmmss)，TAC
			JSONObject return_first = jsonArray.getJSONObject(0);
			String errcode=return_first.getString("errcode");
			String errmessage=return_first.getString("errmessage");
			if(!Tools.processNull(errcode).equals("00")){
				throw new CommonException("取消保存失败："+errmessage);
			}
			//3、自行车押金接口
			if(Tools.processInt(zxcModel.getAmt())*100>0){
				//自行车收押金记账
				accAcountService.zxcjz(Constants.ACPT_TYPE_GM, log.getUserId(), -Tools.processLong(zxcModel.getAmt())*100, flag, log);
			}
			//4、保存业务记录
			rec.setDealCode(log.getDealCode());	
			rec.setDealNo(log.getDealNo());
			rec.setNote(log.getMessage());
			rec.setCardNo(zxcModel.getCardno());
			rec.setAmt(Tools.processLong(zxcModel.getAmt()));
			rec.setCertNo(personal.getCertNo());
			rec.setCardType(card.getCardType());
			rec.setCardId(card.getCardId());
			rec.setCardTrCount("1");
			rec.setBrchId(log.getBrchId());
			rec.setUserId(log.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setOrgId(log.getOrgId());
			rec.setCustomerName(personal.getName());
			rec.setClrDate(this.getClrDate());
			publicDao.save(rec);
			//5、插入绑定表
			CardAppBind bind=new CardAppBind();
			bind.setBindDate(publicDao.getDateBaseDate());
			bind.setBindState("0");//绑定状态 0-是 1-否
			bind.setCardNo(zxcModel.getCardno());
			bind.setDealNo(log.getDealNo());
			bind.setAppType("05");//各应用绑定类型( 01-广电 02-自来水 03-电力 04-过路过桥 05-自行车 06-移动）
			bind.setNote(log.getMessage());
			bind.setUserId(log.getUserId());
			bind.setBrchId(log.getBrchId());
			publicDao.save(bind);
			//6、更新绑定信息
			CardAppBind cancelbind=(CardAppBind)this.findOnlyRowByHql("select c from CardAppBind c ,TrServRec t where c.dealNo=t.dealNo and c.appType='05' and bindState='0' and c.cardNo='"+zxcModel.getCardno()+"' and t.dealCode="+DealCode.ZXC_APP_OPEN +" order by c.bindDate desc ");
			if(cancelbind!=null){
				cancelbind.setBindState("1");
				publicDao.update(cancelbind);
			}
			//7.保存报表信息
		   this.saveSysReport(log,reportSetValue(rec),"/reportfiles/GuaShiJieGuaZhuXiaoPZ.jasper",Constants.APP_REPORT_TYPE_PDF,1L,"",null);
		   return rec;		
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 组装数据
	 * @param tsr
	 * @return
	 * @throws CommonException
	 */
	public JSONObject reportSetValue(TrServRec tsr)throws CommonException{
		try{
			JSONObject json = new JSONObject();
			String ywlx = "";
			//根据交易代码获取业务操作类型
			if(!Tools.processNull(tsr.getDealCode()).equals("")){
				ywlx = this.findTrCodeNameByCodeType(tsr.getDealCode());
			}
			String dlrzjlx = ""; //代理人证件类型
			if(!Tools.processNull(tsr.getAgtCertType()).equals("")){ 
				dlrzjlx = this.getCodeNameBySYS_CODE("CERT_TYPE",tsr.getAgtCertType());
			}
			String zjlx = "";   //本人人证件类型
			if(!Tools.processNull(tsr.getCertType()).equals("")){
				zjlx = this.getCodeNameBySYS_CODE("CERT_TYPE",tsr.getCertType());
			}
			json.put("p_Title",Constants.APP_REPORT_TITLE + ywlx + "办理凭证");//挂失、解挂没用到
			json.put("p_Actionno", Tools.processNull(tsr.getDealNo()));//流水
			json.put("p_Print_Time", DateUtil.formatDate(tsr.getBizTime(), "yyyy-MM-dd HH:mm:ss"));//业务办理时间
			json.put("p_Print_Name", Tools.processNull(this.getUser().getAccount()));
			json.put("p_ywlx",ywlx);//业务办理类型  挂失、解挂
			json.put("p_Cardno", Tools.processNull(tsr.getCardNo()));//业务办理的卡号
			json.put("p_Cardtype",this.getCodeNameBySYS_CODE("CARD_TYPE",tsr.getCardType()));//卡类型
			json.put("p_Clientname", Tools.processNull(tsr.getCustomerName()));
			json.put("p_Certtype", Tools.processNull(zjlx));
			json.put("p_Certno", Tools.processNull(tsr.getCertNo()));
			//reportsHashMap.put("p_Subcardno",cardServiceService.getCodeNameBySYS_CODE("CARD_TYPE",tsr.getCardType()));//为空时，表格线不显示，因此写上“无”
			//String subcardno = Tools.processNull(cardServiceService.findOnlyFieldBySql(" select sub_card_no from card_baseInfo where card_no = '"+tsr.getCardNo()+"'"));
			//reportsHashMap.put("p_Trcode", Tools.processNull(ywlx));
			if(!Tools.processNull(tsr.getAgtName()).equals("")){//根据姓名判断如果代理人不为空，办理人为代理人
				json.put("p_Agtname", Tools.processNull(tsr.getAgtName()));
			}else{
				json.put("p_Agtname", Tools.processNull(tsr.getCustomerName()));	
			}
			if(!Tools.processNull(dlrzjlx).equals("")){
				json.put("p_Agtcerttype", Tools.processNull(dlrzjlx));
			}else{
				json.put("p_Agtcerttype", Tools.processNull(zjlx));
			}
			if(!Tools.processNull(tsr.getAgtCertNo()).equals("")){
				json.put("p_Agtcertno", Tools.processNull(tsr.getAgtCertNo()));
			}else{
				json.put("p_Agtcertno", Tools.processNull(tsr.getCertNo()));
			}
			if(!Tools.processNull(tsr.getAgtTelNo()).equals("")){
				json.put("p_Agttelno", Tools.processNull(tsr.getAgtTelNo()));
			}else{
				json.put("p_Agttelno", Tools.processNull(tsr.getTelNo()));
			}
			json.put("p_Brchid", Tools.processNull(this.getSysBranchByUserId().getFullName()));
			json.put("p_Biztime", DateUtil.formatDate(tsr.getBizTime(), "yyyy-MM-dd HH:mm:ss"));
			json.put("p_Operid", Tools.processNull(tsr.getUserId()));
			json.put("p_bal_rtn_amt",  Arith.cardreportsmoneydiv(Arith.add(String.valueOf((Tools.processNull(tsr.getRtnFgft()).equals("")?"0":tsr.getRtnFgft())),String.valueOf((Tools.processNull(tsr.getBalRtnAmt()).equals("")?"0":tsr.getBalRtnAmt()))))); 
			//reportsHashMap.put("p_Title_Logo", ServletActionContext.getServletContext().getRealPath("/")+"/images/reportimage/logo_jx.gif");//logo图
			return json;
		}catch(Exception e){
			throw new CommonException("生成报表数据错误：" + e.getMessage());
		}
	}
	@SuppressWarnings("unchecked")
	@Override
	public List<CardInsuranceInfo> saveCardInsurance(List<CardInsuranceInfo> list) {
		try {
			List<CardInsuranceInfo> failList = new ArrayList<CardInsuranceInfo>();
			// 参数验证
			if (list == null || list.isEmpty()) {
				throw new CommonException("导入记录为空.");
			}
			// 日志记录
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.CARD_INSURANCE_INFO_IMPORT);
			log.setMessage("卡片保险数据导入");
			publicDao.save(log);

			// 3.循环处理每条记录
			for (int i = 0; i < list.size(); i++) {
				CardInsuranceInfo item = list.get(i);
				item.setId(new CardInsuranceInfoId());
				if (Tools.processNull(item.getCertNo()).equals("")) {
					item.setNote("第 " + (i + 1) + " 行，证件号码不能为空！");
					failList.add(item);
					continue;
				} else if (Tools.processNull(item.getSubCardNo()).equals("")) {
					item.setNote("第 " + (i + 1) + " 行，市民卡号不能为空！");
					failList.add(item);
					continue;
				} else if (Tools.processNull(item.getInsuranceNo()).equals("")) {
					item.setNote("第 " + (i + 1) + " 行，暂不支持导入未生效数据");
					failList.add(item);
					continue;
				} else if (Tools.processNull(item.getStartDateStr()).equals("")) {
					item.setNote("第 " + (i + 1) + " 行，参保生效日期不能为空");
					failList.add(item);
					continue;
				} else if (Tools.processNull(item.getEndDateStr()).equals("")) {
					item.setNote("第 " + (i + 1) + " 行，参保到期日期不能为空");
					failList.add(item);
					continue;
				}
				item.setCertNo(item.getCertNo().trim().toUpperCase());
				item.setInsuranceNo(item.getInsuranceNo().toUpperCase());
				// 1.验证员工信息
				List<BasePersonal> persons = findByHql("from BasePersonal where certNo = '" + item.getCertNo() + "'");
				if (persons == null || persons.isEmpty()) {
					item.setNote("第 " + (i + 1) + " 行，人员信息不存在或证件号码不正确");
					failList.add(item);
					continue;
				} else if(persons.size() >1){
					item.setNote("第 " + (i + 1) + " 行，同一身份证号码有多个人");
					failList.add(item);
					continue;
				}
				BasePersonal person = persons.get(0);
				
				// 2.验证卡
				List<CardBaseinfo> cards = (List<CardBaseinfo>) findByHql("from CardBaseinfo where customerId = '" + person.getCustomerId() 
						+ "' and subCardNo  ='" + item.getSubCardNo().trim() + "' and cardState <> '" + Constants.CARD_STATE_ZX 
						+ "' and cardState <> '" + Constants.CARD_STATE_WQY + "'");
				if (cards == null || cards.isEmpty()) {
					item.setNote("第 " + (i + 1) + " 行，人员【卡片已注销】或【卡号不正确】！");
					failList.add(item);
					continue;
				} else if(cards.size()>1){
					item.setNote("第 " + (i + 1) + " 行，人员有多张【正常】状态卡片");
					failList.add(item);
					continue;
				}
				CardBaseinfo card = cards.get(0);
				
				// 3.验证重复
				BigDecimal info = (BigDecimal) findOnlyFieldBySql("select count(1) from Card_Insurance_Info where card_No = '" 
						+ card.getCardNo() + "' and insurance_No = '" + item.getInsuranceNo() + "'");
				if (info.compareTo(BigDecimal.ZERO) > 0) {
					item.setNote("第 " + (i + 1) + " 行，保险信息已经存在！");
					failList.add(item);
					continue;
				}
				
				// 4.保存数据
				String data = (String) findOnlyRowBySql("select card_no from card_insurance_info where card_no = '" + card.getCardNo() + "' and state = '0'");
				if (Tools.processNull(data).equals("")) {
					item.getId().setCardNo(card.getCardNo());
					item.getId().setInsuranceNo(item.getInsuranceNo());
					item.setInsuredDate(log.getDealTime());
					item.setStartDate(DateUtils.parse(item.getStartDateStr(), "yyyy/MM/dd"));
					item.setEndDate(DateUtils.parse(item.getEndDateStr(), "yyyy/MM/dd"));
					item.setDealNo(log.getDealNo());
					item.setSource("1");
					if (item.getInsuranceNo().equals("")) {
						item.setState("0");
					} else {
						item.setState("1");
					}
					publicDao.save(item);
				} else {
					int r = publicDao.doSql("update card_insurance_info set insurance_no = '" + item.getInsuranceNo() + "', insurance_kind = '" + item.getInsuranceKind() + "', "
							+ "start_date = to_date('" + item.getStartDateStr() + "', 'yyyy/mm/dd'), end_date = to_date('" + item.getEndDateStr() + "', 'yyyy/mm/dd'), state = '1', note = '" + item.getNote() + "' "
							+ "where card_no = '" + card.getCardNo() + "' and state = '0'");
					if(r != 1){
						throw new CommonException("更新数量不正确！");
					}
				}
			}

			//业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setNote(log.getMessage());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			publicDao.save(trServRec);

			// 5. 返回导入失败的记录
			return failList;
		} catch (CommonException e) {
			throw new CommonException("导入数据失败, " + e.getMessage());
		} catch (Exception e) {
			throw new CommonException("导入数据失败, 系统异常.");
		}
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public void deleteCardInsurance(String dealNo) {
		try {
			// 日志记录
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.CARD_INSURANCE_INFO_DELETE);
			log.setMessage("卡片保险数据删除");
			publicDao.save(log);
			
			CardInsuranceInfo info = (CardInsuranceInfo) findOnlyRowByHql("from CardInsuranceInfo where dealNo = '" + dealNo + "'");
			if(info == null){
				throw new CommonException("保险信息不存在！");
			}
			publicDao.delete(info);
			
			// 业务日志
			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(log.getDealNo());
			trServRec.setDealCode(log.getDealCode());
			trServRec.setNote(log.getMessage());
			trServRec.setBizTime(log.getDealTime());
			trServRec.setUserId(log.getUserId());
			trServRec.setBrchId(getUser().getBrchId());
			trServRec.setOrgId(getUser().getOrgId());
			trServRec.setDealState(Constants.TR_STATE_ZC);
			trServRec.setClrDate(this.getClrDate());
			publicDao.save(trServRec);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
}
