package com.erp.serviceImpl;

import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.subject.Subject;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.BaseCorp;
import com.erp.model.BasePersonal;
import com.erp.model.BaseSiinfo;
import com.erp.model.CardApply;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.SysPara;
import com.erp.model.TrServRec;
import com.erp.service.BasicPersonService;
import com.erp.util.Constants;
import com.erp.util.DealCode;
import com.erp.util.PageUtil;
import com.erp.util.Tools;

@Service("basicPersonService")
public class BasicPersonServiceImpl extends BaseServiceImpl implements BasicPersonService {
	public List<BasePersonal> findPersonAllList(Map<String, Object> map,
			PageUtil pageUtil) {
		String hql="from BasePersonal u where 1=1 ";
		hql+=Constants.getSearchConditionsHQL("u", map);
		hql+=Constants.getGradeSearchConditionsHQL("u", pageUtil);
		if(map.get("sortName")!=null){
			hql+=" order by "+map.get("sortName")+" "+ map.get("orderBy");
			map.remove("sortName");
			map.remove("orderBy");
		}
		
		List<BasePersonal> list = publicDao.find(hql, map, pageUtil.getPage(), pageUtil.getRows());
		return list;
	}

	public Long getCount(Map<String, Object> map, PageUtil pageUtil) {
		String hql="select count(*) from BasePersonal  u where 1=1 ";
		hql+=Constants.getSearchConditionsHQL("u", map);
		hql+=Constants.getGradeSearchConditionsHQL("u", pageUtil);
		return publicDao.count(hql, map);
	}
	public boolean persistenceBasicPerson(BasePersonal u) {
		Subject subject=SecurityUtils.getSubject();
		Long clientId = u.getCustomerId();
		if (null==clientId||0==clientId)
		{
			u.setOpenUserId(Constants.getCurrendUser().getAccount());
			u.setOpenDate(new Date());
			publicDao.save(u);
		}else {
			publicDao.update(u);
		}
		return true;
	}
	
	public List<BasePersonal>  findPersonByClientId(String clientId) {
		return publicDao.find("from BasePersonal where customerId='"+clientId+"'");
	}
	/**
	 * 人员基本信息新增保存或是编辑保存
	 * @param bp
	 * @param rec
	 * @param log
	 * @param type
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveAddOrUpdateBasePersonal(BasePersonal bp, String corpName,TrServRec rec,SysActionLog log,String type) throws CommonException{
		try{
			System.out.println(new Date());
			//1.基本条件判断
			String string = "";
			Integer tempdealcode = 0;
			if(Tools.processNull(type).equals("0")){
				string = "人员基本信息新增";
				tempdealcode = DealCode.BASE_DATA_SJCJ_ADD;
			}else if(Tools.processNull(type).equals("1")){
				string = "人员基本信息编辑";
				tempdealcode = DealCode.BASE_DATA_SJCJ_EDIT;
			}else{
				throw new CommonException(string + "发生错误：操作类型传入错误！");
			}
			if(bp == null){
				throw new CommonException(string + "发生错误：传入人员信息不能为空！");
			}
			if(log == null){
				log = this.getCurrentActionLog();
			}
			SysPara res = this.getSysParaByParaCode("CITY_CODE");
			if(res == null || Tools.processNull(res.getParaCode()).equals("")){
				throw new CommonException(string + "发生错误：SYS_PARA 城市代码未设置！");
			}
			//2.插入操作日志信息
			log.setDealCode(tempdealcode);
			log.setMessage(string);
			publicDao.save(log);
			if("-1".equals(bp.getCorpCustomerId()) && !Tools.processNull(corpName).equals("")) {
				List<BaseCorp> list = this.findByHql("from BaseCorp bc where bc.corpName = '" + corpName + "'");
				if(list.size() == 0) {
					throw new CommonException((type.equals("0") ? "新增" : "编辑") + "人员信息失败！原因：单位不存在！");
				} else if(list.size() > 1) {
					throw new CommonException((type.equals("0") ? "新增" : "编辑") + "人员信息失败！原因：单位选择不明确！");
				} else if(list.size() == 1) {
					BaseCorp tempbc = (BaseCorp) this.findOnlyRowByHql("from BaseCorp bc where bc.corpName = '" + corpName + "'");
					if(tempbc == null) {
						throw new CommonException((type.equals("0") ? "新增" : "编辑") + "人员信息失败！原因：单位不存在！");
					}
					bp.setCorpCustomerId(tempbc.getCustomerId());
				}
			}
			if(!"".equals(bp.getCorpCustomerId()) && !Tools.processNull(corpName).equals("")) {
				BaseCorp tempbc = (BaseCorp) this.findOnlyRowByHql("from BaseCorp b where b.customerId = '" + bp.getCorpCustomerId() + "'");
				if(tempbc == null) {
					throw new CommonException((type.equals("0") ? "新增" : "编辑") + "人员信息失败！原因：单位不存在！");
				}
			}
			//3.业务处理
			if(Tools.processNull(type).equals("0")){
				if(Tools.processNull(bp.getName()).equals("")){
					throw new CommonException(string + "发生错误：客户姓名不能为空！");
				}
				if(Tools.processNull(bp.getCertNo()).equals("")){
					throw new CommonException(string + "发生错误：客户证件号码不能为空！");
				}
				BasePersonal tempbp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.certNo = '" + bp.getCertNo() + "'");
				if(tempbp != null){
					throw new CommonException(string + "发生错误：该客户证件号码已存在，请进行编辑！");
				}
				bp.setOpenDate(this.getDateBaseTime());
				bp.setCustomerState("0");
				bp.setSureFlag("0");
				bp.setCityId(res.getParaValue());
				bp.setOpenDate(this.getDateBaseTime());
				bp.setName(Tools.processNull(bp.getName().trim()));
				bp.setCertNo(Tools.processNull(bp.getCertNo().trim().toUpperCase()));
				bp.setOpenUserId(log.getUserId());
				publicDao.save(bp);
			}else if(Tools.processNull(type).equals("1")){
				BasePersonal tempbp1 = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.certNo = '" + bp.getCertNo() + "' and t.customerId <> '" + bp.getCustomerId() + "'");
				if(tempbp1 != null){
					throw new CommonException(string + "发生错误：该证件号码【" + bp.getCertNo() + "】客户信息已存在！");
				}
				BasePersonal tempbp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + bp.getCustomerId() + "'");
				if(tempbp == null){
					throw new CommonException(string + "发生错误：根据客户编号【" + bp.getCustomerId() + "】未找到客户信息！");
				}
				tempbp.setName(bp.getName().trim());
				tempbp.setCertType(bp.getCertType());
				tempbp.setCertNo(Tools.processNull(bp.getCertNo()).toUpperCase().trim());
				tempbp.setBirthday(bp.getBirthday());
				tempbp.setGender(bp.getGender());
				tempbp.setNation(bp.getNation());
				tempbp.setEducation(bp.getEducation());
				tempbp.setMarrState(bp.getMarrState());
				tempbp.setResideType(bp.getResideType());
				tempbp.setEmail(bp.getEmail());
				tempbp.setPhoneNo(bp.getPhoneNo());
				tempbp.setTelNos(bp.getTelNos());
				tempbp.setMobileNo(bp.getMobileNo());
				tempbp.setMobileNos(bp.getMobileNos());
				tempbp.setRegionId(bp.getRegionId());
				tempbp.setTownId(bp.getTownId());
				tempbp.setCommId(bp.getCommId());
				tempbp.setCareer(bp.getCareer());
				tempbp.setCorpCustomerId(bp.getCorpCustomerId());
				//tempbp.setDataSrc(bp.getDataSrc());
				tempbp.setResideAddr(bp.getResideAddr());
				tempbp.setLetterAddr(bp.getLetterAddr());
				tempbp.setCustomerState(bp.getCustomerState());
				if(tempbp.getCustomerState().equals(Constants.STATE_ZC) && bp.getCustomerState().equals(Constants.STATE_ZX)){// 如果是注销操作, 需要判断人员卡状态
					judgePersonCard(bp.getCustomerId());
					tempbp.setCustomerState(bp.getCustomerState());
				}
				tempbp.setPinying(bp.getPinying());
				if(Tools.processNull(bp.getCustomerState()).equals("1")){
					tempbp.setClsDate(this.getDateBaseTime());
					tempbp.setClsUserId(this.getUser().getUserId());
				}else{
					tempbp.setClsDate(null);
					tempbp.setClsUserId("");
				}
				tempbp.setPostCode(bp.getPostCode());
				tempbp.setCityId(res.getParaValue());
				bp.setRegionId(res.getParaCode());
				tempbp.setNote(bp.getNote());
				tempbp.setSureFlag(bp.getSureFlag());
				publicDao.update(tempbp);
				//修改参保信息
				List<BaseSiinfo> siinfos = (List<BaseSiinfo>) findByHql("from BaseSiinfo where customerId = '" + tempbp.getCustomerId() + "'");
				if (siinfos.size() > 1) {
					throw new CommonException("该客户有多条参保信息！");
				} else if (siinfos.size() == 1 && siinfos.get(0) != null) {
					siinfos.get(0).setName(tempbp.getName());
					siinfos.get(0).setCertNo(tempbp.getCertNo());
				}
			}
			//4.业务日志信息
			rec = getTrServRec(rec,bp,null,null,log);
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	private void judgePersonCard(Long customerId) {
		CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where customerId = '" + customerId + "' and cardState = '" + Constants.CARD_STATE_ZC + "'");
		if(card != null) {
			throw new CommonException("人员卡片 [" + card.getCardNo() + "] 不是 [已注销] 状态.");
		}
	}

	/**
	 * 根据基本信息构建基本业务操作日志
	 * @param rec   业务日志
	 * @param bp    个人信息
	 * @param card  卡信息
	 * @param acc   账户信息
	 * @param log   操作日志信息
	 * @return      基本业务操作日志
	 */
	public TrServRec getTrServRec(TrServRec rec,BasePersonal bp,CardBaseinfo card,AccAccountSub acc,SysActionLog log){
		//1.基本条件判断
		if(bp == null){
			if(card != null && !Tools.processNull(card.getCustomerId()).equals("")){
				bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
			}
		}
		if(rec == null){
			rec = new TrServRec();
		}
		//2.设值SysActionLog相关
		rec.setDealNo(log.getDealNo());
		rec.setDealCode(log.getDealCode());
		rec.setBizTime(log.getDealTime());
		rec.setOrgId(log.getOrgId());
		rec.setNote(log.getMessage());
		//3.设值BasePersonal相关
		if(bp != null){
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			rec.setCustomerName(bp.getName());
			rec.setTelNo(bp.getMobileNo());
			if(Tools.processNull(rec.getCertType()).equals("")){
				rec.setAgtCertType(bp.getCertType());
			}
			if(Tools.processNull(rec.getAgtCertNo()).equals("")){
				rec.setAgtCertNo(bp.getCertNo());
			}
			if(Tools.processNull(rec.getAgtName()).equals("")){
				rec.setAgtName(bp.getName());
			}
			if(Tools.processNull(rec.getAgtTelNo()).equals("")){
				rec.setAgtTelNo(bp.getMobileNo());
			}
		}
		//4设值CardBaseinfo相关
		if(card != null){
			rec.setCardId(card.getCardId());
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setCardAmt(1L);
		}
		if(acc != null){
			rec.setAccKind(acc.getAccKind());
			rec.setAccNo(acc.getAccNo() + "");
		}
		//5通用
		rec.setClrDate(this.getClrDate());
		rec.setDealState(Constants.STATE_ZC);
		rec.setBrchId(log.getBrchId());
		rec.setUserId(log.getUserId());
		return rec;
	}

	@SuppressWarnings("unchecked")
	@Override
	public void savePersonMerge(String rightCertNo, String wrongCertNo, String rightName, String wrongName, String rightMedWholeNoAndPersonalId, String wrongMedWholeNoAndPersonalId, String photoCertNo) {
		try {
			if (Tools.processNull(rightCertNo).equals("") || Tools.processNull(wrongCertNo).equals("")) {
				throw new CommonException("证件号码不能为空！");
			} else if (rightCertNo.equals(wrongCertNo)) {
				throw new CommonException("证件号码不能相同！");
			}
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.PERSON_MERGE);
			log.setMessage("人员合并，正确信息【" + rightCertNo + ", " + rightName + ", " + rightMedWholeNoAndPersonalId + "】，错误信息【" + wrongCertNo + ", " + wrongName + ", " + wrongMedWholeNoAndPersonalId + "】");
			publicDao.save(log);
			
			//
			Object photoCustomerId = findOnlyFieldBySql("select customer_id from base_photo t where exists (select 1 from base_personal where customer_id = t.customer_id and cert_no = '" + photoCertNo + "')");
			BasePersonal rightPerson, wrongPerson;
			BasePersonal ps1 = (BasePersonal) findOnlyRowByHql("from BasePersonal where certNo = '" + rightCertNo + "'");
			if(ps1 == null){
				throw new CommonException("证件号码为【" + rightCertNo + "】的人员信息不存在！");
			}
			BasePersonal ps2 = (BasePersonal) findOnlyRowByHql("from BasePersonal where certNo = '" + wrongCertNo + "'");
			if (ps2 == null) {
				throw new CommonException("证件号码为【" + wrongCertNo + "】的人员信息不存在！");
			}
			
			// 1.检查有没有申领过卡片
			CardApply apply1 = (CardApply) findOnlyRowByHql("from CardApply where customerId = '" + ps1.getCustomerId() + "'");
			CardApply apply2 = (CardApply) findOnlyRowByHql("from CardApply where customerId = '" + ps2.getCustomerId() + "'");
			
			if (apply1 == null && apply2 == null) {
				rightPerson = ps1;
				wrongPerson = ps2;
			} else if (apply1 != null && apply2 == null) {
				rightPerson = ps1;
				wrongPerson = ps2;
			} else if (apply1 == null && apply2 != null) {
				rightPerson = ps2;
				wrongPerson = ps1;
			} else {
				apply1 = (CardApply) findOnlyRowByHql("from CardApply where customerId = '" + ps1.getCustomerId() + "' and applyState < '90'");
				apply2 = (CardApply) findOnlyRowByHql("from CardApply where customerId = '" + ps2.getCustomerId() + "' and applyState < '90'");
				//
				if (apply1 == null && apply2 == null) {
					rightPerson = ps1;
					wrongPerson = ps2;
				} else if (apply1 != null && apply2 == null) {
					rightPerson = ps1;
					wrongPerson = ps2;
				} else if (apply1 == null && apply2 != null) {
					rightPerson = ps2;
					wrongPerson = ps1;
				} else {
					CardBaseinfo card1 = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where cardType in ('" + Constants.CARD_TYPE_QGN + "', '" + Constants.CARD_TYPE_SMZK + "') and customerId = '" + ps1.getCustomerId() + "' and cardState <> '9'");
					CardBaseinfo card2 = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where cardType in ('" + Constants.CARD_TYPE_QGN + "', '" + Constants.CARD_TYPE_SMZK + "') and customerId = '" + ps2.getCustomerId() + "' and cardState <> '9'");
					//
					if (card1 == null && card2 == null) {
						rightPerson = ps1;
						wrongPerson = ps2;
					} else if (card1 != null && card2 == null) {
						rightPerson = ps1;
						wrongPerson = ps2;
					} else if (card1 == null && card2 != null) {
						rightPerson = ps2;
						wrongPerson = ps1;
					} else {
						throw new CommonException("两个证件号码都有状态【未注销】的卡片，请选择一张做【卡片注销】操作后再进行合并操作！");
					}
				}
			}
			
			// 人员信息
			rightPerson.setCertNo(rightCertNo);
			if (!Tools.processNull(rightName).equals("")) {
				rightPerson.setName(rightName);
			}
			rightPerson.setBirthday(ps1.getBirthday());
			rightPerson.setGender(ps1.getGender());
			// 参保信息
			String rightPersonalId = rightMedWholeNoAndPersonalId.substring(6);
			String rightMedWholeNo = rightMedWholeNoAndPersonalId.substring(0, 6);
			int r = publicDao.doSql("delete from base_siinfo where customer_id = '" + rightPerson.getCustomerId() + "' and personal_id <> '" + rightPersonalId + "'");
			if (r > 1) {
				throw new CommonException("删除参保记录大于1");
			}
			BaseSiinfo rightSiinfo = (BaseSiinfo) findOnlyRowByHql("from BaseSiinfo where id.personalId = '" + rightPersonalId + "' and id.medWholeNo = '" + rightMedWholeNo + "'");
			if(rightSiinfo == null){
				throw new CommonException("社保编号为【" + rightPersonalId + "】的人员参保信息不存在！");
			}
			rightSiinfo.setCustomerId(rightPerson.getCustomerId() + "");
			rightSiinfo.setCertNo(rightCertNo);
			if (!Tools.processNull(rightName).equals("")) {
				rightSiinfo.setName(rightName);
			}
			// 单位信息
			if(!Tools.processNull(rightSiinfo.getCompanyId()).equals("")){
				String corpId = (String) findOnlyFieldBySql("select customer_id from base_corp where companyid = '" + rightSiinfo.getCompanyId() + "'");
				rightPerson.setCorpCustomerId(corpId);
			}
			publicDao.save(rightPerson);
			publicDao.save(rightSiinfo);
			
			// 照片信息
			if(photoCustomerId != null){ // 如果有照片
				// 正确的人对应的照片
				Object rightPersonPhoto = findOnlyFieldBySql("select 1 from base_photo where customer_id = '" + rightPerson.getCustomerId() + "'");
				if(rightPersonPhoto == null){ // 如果没有照片，更新正确照片的 customer_id 为 rightPerson 的customer_id
					r = publicDao.doSql("update base_photo t set customer_id = '" + rightPerson.getCustomerId() + "' where customer_id = '" + photoCustomerId + "'");
				} else { // 如果已经有照片，更新 rightPerson 照片为正确照片
					r = publicDao.doSql("update base_photo t set photo = (select photo from base_photo p where customer_id = '" + photoCustomerId + "') where customer_id = '" + rightPerson.getCustomerId() + "'");
				}
			}
			// 绑定信息
			r = publicDao.doSql("update card_bind_bankcard t set cert_no = '" + rightCertNo + "' where customer_id = '" + rightPerson.getCustomerId() + "'");
			if (r > 1) {
				throw new CommonException("更新绑定记录大于1");
			}
			// 删除错误信息
			CardBaseinfo wrongPersonCard = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where customerId = '" + wrongPerson.getCustomerId() + "'");
			if(wrongPersonCard == null){
				r = publicDao.doSql("delete from base_personal where customer_id = '" + wrongPerson.getCustomerId() + "'");
				if (r > 1) {
					throw new CommonException("删除人员记录大于1");
				}
			} else {
				wrongPerson.setName(wrongPerson.getName() + "（合并注销）");
				wrongPerson.setCertNo(wrongCertNo);
				wrongPerson.setCustomerState(Constants.STATE_ZX);
				wrongPerson.setNote("合并注销，正确：" + rightCertNo + "，错误：" + wrongCertNo);
			}
			
			// 业务日志
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setCustomerId(rightPerson.getCustomerId().toString());
			rec.setCustomerName(rightPerson.getName());
			rec.setCertType(rightPerson.getCertType());
			rec.setCertNo(rightPerson.getCertNo());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.STATE_ZC);
			rec.setNote(log.getMessage());
			rec.setRsvOne("");
			rec.setClrDate(getClrDate());
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
}
