package com.erp.serviceImpl;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.BaseCorp;
import com.erp.model.BasePersonal;
import com.erp.model.BaseSiinfo;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.BaseSiinfoService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.PageUtil;
import com.erp.util.Tools;

/**
 * 统筹区域信息管理业务实现类。
 * 
 * @author 钱佳明。
 * @version 1.0。
 * @date 2015-12-02。
 *
 */
@Service("baseSiinfoService")
@SuppressWarnings("unchecked")
public class BaseSiinfoServiceImpl extends BaseServiceImpl implements BaseSiinfoService {

	/**
	 * 查询统筹区域信息。
	 */
	@Override
	public List<BaseSiinfo> findBaseSiinfoAllList(Map<String, Object> map, PageUtil pageUtil) {
		String hql = "from BaseSiinfo b where 1 = 1";
		hql += Constants.getSearchConditionsHQL("b", map);
		hql += Constants.getGradeSearchConditionsHQL("b", pageUtil);
		List<BaseSiinfo> list = publicDao.find(hql, map, pageUtil.getPage(), pageUtil.getRows());
		return list;
	}

	/**
	 * 返回信息记录数。
	 */
	@Override
	public Long getCount(Map<String, Object> map, PageUtil pageUtil) {
		String hql = "select count(*) from BaseSiinfo b where 1 = 1";
		hql += Constants.getSearchConditionsHQL("b", map);
		hql += Constants.getGradeSearchConditionsHQL("b", pageUtil);
		return publicDao.count(hql, map);
	}

	/**
	 * 更新
	 */
	@Override
	public TrServRec updateMedWholeNo(BaseSiinfo baseSiinfo, TrServRec trServRec, SysActionLog sysActionLog, String type) throws CommonException {
		try {
			String string = "";
			Integer tempdealcode = 0;
			if (Tools.processNull(type).equals("1")) {
				string = "区域统筹信息编辑";
				tempdealcode = DealCode.BASE_DATA_SJCJ_EDIT;
			} else {
				throw new CommonException(string + "发生错误：操作类型传入错误！");
			}
			if (baseSiinfo == null) {
				throw new CommonException(string + "发生错误：传入区域统筹信息不能为空！");
			}
			if (sysActionLog == null) {
				sysActionLog = this.getCurrentActionLog();
			}
			sysActionLog.setDealCode(tempdealcode);
			sysActionLog.setMessage(string);
			publicDao.save(sysActionLog);
			//
			trServRec = getTrServRec(trServRec, baseSiinfo, sysActionLog);
			//
			if (Tools.processNull(type).equals("1")) {
				BaseSiinfo baseSiinfoTemp = (BaseSiinfo) findOnlyRowByHql("from BaseSiinfo b where b.id.personalId = '" + baseSiinfo.getId().getPersonalId() + "' and b.id.medWholeNo = '" + baseSiinfo.getId().getMedWholeNo() + "'");
				if (baseSiinfoTemp != null && !baseSiinfoTemp.getCustomerId().equals(baseSiinfo.getCustomerId())) {
					throw new CommonException("参保信息已经存在【" + baseSiinfoTemp.getName() + "，" + baseSiinfoTemp.getCertNo() + "】！");
				}
				BaseSiinfo oldSiinfo = (BaseSiinfo) findOnlyRowByHql("from BaseSiinfo b where customerId = '" + baseSiinfo.getCustomerId() + "'");
				BaseCorp corp = (BaseCorp) findOnlyRowByHql("from BaseCorp where companyid='" + baseSiinfo.getCompanyId() + "' and regionId='" + baseSiinfo.getId().getMedWholeNo() + "'");
				publicDao.doSql("update base_siinfo set personal_id='" + baseSiinfo.getId().getPersonalId() + "', med_whole_no = '" + baseSiinfo.getId().getMedWholeNo()  + "', name='" + baseSiinfo.getName() +  "', cert_no='" + baseSiinfo.getCertNo() + "', company_id='" + baseSiinfo.getCompanyId() + "', med_state = '" + baseSiinfo.getMedState() + "', reserve_18 = '" + sysActionLog.getDealNo() + "' where customer_id = '" + baseSiinfo.getCustomerId() + "'");
				publicDao.doSql("update base_personal t set name='" + baseSiinfo.getName() + "', cert_no='" + baseSiinfo.getCertNo() + "', corp_customer_id='" + (corp == null ? "" : corp.getCustomerId()) + "' where customer_id='" + baseSiinfo.getCustomerId() + "'");
				//
				trServRec.setRsvOne(oldSiinfo.getId().getPersonalId());
				trServRec.setRsvTwo(oldSiinfo.getId().getMedWholeNo());
				trServRec.setRsvThree(oldSiinfo.getName());
				trServRec.setRsvFour(oldSiinfo.getCertNo());
				trServRec.setRsvFive(oldSiinfo.getCompanyId());
			}
			publicDao.save(trServRec);
			return trServRec;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}

	public TrServRec getTrServRec(TrServRec trServRec, BaseSiinfo baseSiinfo, SysActionLog sysActionLog) {
		if (trServRec == null) {
			trServRec = new TrServRec();
		}
		trServRec.setDealNo(sysActionLog.getDealNo());
		trServRec.setDealCode(sysActionLog.getDealCode());
		trServRec.setBizTime(sysActionLog.getDealTime());
		trServRec.setOrgId(sysActionLog.getOrgId());
		trServRec.setNote(sysActionLog.getMessage());

		if (baseSiinfo != null) {
			trServRec.setCustomerId(baseSiinfo.getCustomerId());
			trServRec.setCustomerName(baseSiinfo.getName());
			trServRec.setCertType(baseSiinfo.getCertType());
			trServRec.setCertNo(baseSiinfo.getCertNo());
		}

		trServRec.setClrDate(this.getClrDate());
		trServRec.setDealState(Constants.STATE_ZC);
		trServRec.setBrchId(this.getUser().getBrchId());
		trServRec.setUserId(this.getUser().getUserId());
		return trServRec;
	}

	@Override
	public CardBaseinfo updateBaseSiinfoMedWholeNo(BaseSiinfo newBaseSiinfo, String subCardNo, String newSubCardId, String oldSubCardId) {
		try {
			//1.参数验证,日志
			if (newBaseSiinfo == null || newBaseSiinfo.getId() == null) {
				throw new CommonException("参保信息不能为空！");
			} else if (newBaseSiinfo.getId().getPersonalId() == null) {
				throw new CommonException("新社保信息[社保编号]为空！");
			} else if (newBaseSiinfo.getId().getMedWholeNo() == null) {
				throw new CommonException("新社保信息[统筹区编码]为空！");
			}
			SysActionLog log = getCurrentActionLog();
			log.setDealCode(DealCode.SIINFO_MEDWHOLENO_UPDATE);
			publicDao.save(log);
			//2.新社保信息验证
			BaseSiinfo baseSiinfo2 = (BaseSiinfo) findOnlyRowByHql("from BaseSiinfo b where b.id.personalId = '" + newBaseSiinfo.getId().getPersonalId() 
					+ "' and b.id.medWholeNo = '" + newBaseSiinfo.getId().getMedWholeNo() +  "'");
			if(baseSiinfo2 == null){
				throw new CommonException("参保信息不存在！");
			}
			baseSiinfo2.getId().setMedWholeNo(newBaseSiinfo.getId().getMedWholeNo());
			//3.人员信息验证
			BasePersonal person = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.certNo = '" + newBaseSiinfo.getCertNo() + "'");
			if(person == null) {
				throw new CommonException("客户信息不存在！");
			}else if(!person.getCustomerState().equals(Constants.STATE_ZC)){
				throw new CommonException("客户信息[状态]不正常！");
			}
			// 4.卡片信息验证
			CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where customerId = '"
					+ person.getCustomerId() + "' and subCardNo = '" + subCardNo + "' and subCardId = '" + oldSubCardId + "'");
			if(card == null) {
				throw new CommonException("客户卡片信息不存在！");
			} else if (!card.getCardState().equals(Constants.CARD_STATE_ZC)) {
				throw new CommonException("客户卡片状态不正常！");
			}
			//6.更新卡社保卡号subCardId, 不是subCardNo
			String updateSql = "update card_baseinfo set sub_card_id = '" + newSubCardId + "' where card_no = '" + card.getCardNo() + "'";
			int rows = publicDao.doSql(updateSql);
			if (rows != 1) {
				throw new CommonException("更新社保卡号统筹区编码失败！");
			}
			//7.同步新卡
			synchNew2SB(person, card, baseSiinfo2, newSubCardId, oldSubCardId);// 卡号信息
			if(card.getCardType().equals(Constants.CARD_TYPE_SMZK)){
				synchBankCardInfo2SB(person, card, baseSiinfo2, newSubCardId, oldSubCardId); //银行卡激活信息
			}
			// 日志
			Users oper = this.getUser();
			log.setMessage("社保统筹区编码变更[新社保编号：" + newSubCardId + "，老社保编号：" + oldSubCardId + "]");
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.STATE_ZC);
			rec.setBizTime(log.getDealTime());
			rec.setNote(log.getMessage());
			rec.setOrgId(oper.getOrgId());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setCardAmt(1L);
			rec.setCardId(card.getCardId());
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setCustomerId(person.getCustomerId() + "");
			rec.setCustomerName(person.getName());
			rec.setCertNo(person.getCertNo());
			rec.setCertType(person.getCertType());
			rec.setClrDate(getClrDate());
			this.publicDao.save(rec);
			return (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + card.getCardNo() + "'");
		} catch (Exception e) {
			throw new CommonException("社保统筹区编码变更失败, " + e.getMessage());
		}
	}
	
	private void synchBankCardInfo2SB(BasePersonal person, CardBaseinfo card, BaseSiinfo newSiinfo,
			String newSubCardId, String oldSubCardId) {
		try {
			SysActionLog log = getCurrentActionLog();
			
			String insertSql = "insert into card_update("
					+ "CARDUPDATESEQ, CLIENTID, SUB_CARDID, SUB_CARDNUMBER, "
					+ "NAME, CERTTYPE, CERTNUMBER, SEX, CARDBIZTYPE, OLD_SUBCARDID, "
					+ "OLD_SUBCARDNUMBER, PERSONALID, SWITCHNODE, UPDATETIME, ACTIONNO, "
					+ "CARD_TYPE, VERSION, ORG_CODE, ISSUE_DATE, VALID_DATE, NATION, "
					+ "BIRTHDAY, RESIDE_ADDR, MED_WHOLE_NO, PRO_ORG_CODE, PRO_MEDIA_TYPE, "
					+ "PRO_VERSION, PRO_INIT_DATE, CLBZ, CLSJ, STCLSJ, NOTE, BANK_ID, BANK_CARD_NO, JHZT) values("
					+ "seq_card_update.nextval,"
					+ "'" + Tools.processNull(person.getCustomerId()) + "',"
					+ "'" + Tools.processNull(newSubCardId) + "',"
					+ "'" + Tools.processNull(card.getSubCardNo()) + "',"
					+ "'" + Tools.processNull(person.getName()) + "',"
					+ "'" + Tools.processNull(person.getCertType()) + "',"
					+ "'" + Tools.processNull(person.getCertNo()) + "',"
					+ "'" + Tools.processNull(person.getGender()) + "',"
					+ "'9',"//激活
					+ "'" + Tools.processNull(oldSubCardId) + "',"
					+ "'" + Tools.processNull(card.getSubCardNo()) + "',"
					+ "'" + Tools.processNull(newSiinfo.getId().getPersonalId()) + "',"
					+ "'04',"
					+ "to_date('" + DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss") + "', 'yyyy-mm-dd hh24:mi:ss'),"
					+ "'" + Tools.processNull(log.getDealNo()) + "',"
					+ "'" + Tools.processNull(card.getCardType()) + "',"
					+ "'" + Tools.processNull(card.getVersion()) + "',"
					+ "'" + Tools.processNull(card.getInitOrgId()) + "',"
					+ "'" + Tools.processNull(card.getIssueDate()) + "',"
					+ "'" + Tools.processNull(card.getValidDate()) + "',"
					+ "'" + Tools.processNull(person.getNation()) + "',"
					+ "'" + Tools.processNull(person.getBirthday()) + "',"
					+ "'" + Tools.processNull(person.getResideAddr()) + "',"
					+ "'" + Tools.processNull(newSiinfo.getId().getMedWholeNo()) + "',"
					+ "'" + Tools.processNull(card.getProOrgCode()) + "',"
					+ "'" + Tools.processNull(card.getProMediaType()) + "',"
					+ "'" + Tools.processNull(card.getProVersion()) + "',"
					+ "'" + Tools.processNull(card.getProInitDate()) + "',"
					+ "'0',"
					+ "'',"
					+ "'',"
					+ "'',"
					+ "'" + card.getBankId() + "'," // BANK_ID
					+ "'" + card.getBankCardNo() + "'," // BANK_CARD_NO
					+ "'" + (card.getBankActiveState() == null?1:Integer.parseInt(card.getBankActiveState())) + "'" // JHZT
					+ ")";
			
			publicDao.doSql(insertSql);
		} catch (Exception e) {
			throw new CommonException("同步新卡到社保失败, " + e.getMessage());
		}
	}

	/**
	 * @author Yueh
	 */
	@Override
	public BaseSiinfo getNewBaseSiinfo(String certNo, String subCardNo) throws CommonException {
		try {
			if(certNo == null) {
				throw new CommonException("获取客户参保区域信息，身份证号不能为空！");
			} else if (subCardNo == null) {
				throw new CommonException("社保卡号为空！");
			}
			//1.验证人员
			BasePersonal person = (BasePersonal) findOnlyRowByHql("from BasePersonal where certNo = '" + certNo + "' and customerState = '" + 
			Constants.STATE_ZC + "'");
			if(person == null) {
				throw new CommonException("客户信息不存在或客户状态不正常！");
			}
			//2.验证卡片
			CardBaseinfo card = (CardBaseinfo) findOnlyRowByHql("from CardBaseinfo where customerId = '"
					+ person.getCustomerId() + "' and subCardNo = '" + subCardNo + "' and cardState = '" + Constants.CARD_STATE_ZC + "'");
			if (card == null) {
				throw new CommonException("卡片信息不存在或卡状态不正常！");
			} else if (!card.getCardState().equals(Constants.CARD_STATE_ZC)) {
				throw new CommonException("卡片信息[状态]不正常！");
			}
			//3.验证社保
			BaseSiinfo baseSiinfo = (BaseSiinfo) findOnlyRowByHql("from BaseSiinfo where customerId = '" + person.getCustomerId() + 
					"' and certNo = '" + certNo + "' and id.medWholeNo = '" + this.getBrchRegion() + "'");
			if(baseSiinfo == null){
				throw new CommonException("客户参保信息不存在或参保区域不属于本区域！");
			}
			return baseSiinfo;
		} catch (CommonException e) {
			throw e;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}

	/**
	 * 同步旧卡到社保
	 * @param oldPerson
	 * @param oldCard
	 */
	private void synchOld2SB(BasePersonal oldPerson, CardBaseinfo oldCard) {
		try {
			SysActionLog log = getCurrentActionLog();
			
			String insertSql = "insert into card_update("
					+ "CARDUPDATESEQ, CLIENTID, SUB_CARDID, SUB_CARDNUMBER, "
					+ "NAME, CERTTYPE, CERTNUMBER, SEX, CARDBIZTYPE, OLD_SUBCARDID, "
					+ "OLD_SUBCARDNUMBER, PERSONALID, SWITCHNODE, UPDATETIME, ACTIONNO, "
					+ "CARD_TYPE, VERSION, ORG_CODE, ISSUE_DATE, VALID_DATE, NATION, "
					+ "BIRTHDAY, RESIDE_ADDR, MED_WHOLE_NO, PRO_ORG_CODE, PRO_MEDIA_TYPE, "
					+ "PRO_VERSION, PRO_INIT_DATE, CLBZ, CLSJ, STCLSJ, NOTE) values("
					+ "seq_card_update.nextval,"
					+ "'" + Tools.processNull(oldPerson.getCustomerId()) + "',"
					+ "'" + Tools.processNull(oldCard.getSubCardId()) + "',"
					+ "'" + Tools.processNull(oldCard.getSubCardNo()) + "',"
					+ "'" + Tools.processNull(oldPerson.getName()) + "',"
					+ "'" + Tools.processNull(oldPerson.getCertType()) + "',"
					+ "'" + Tools.processNull(oldPerson.getCertNo()) + "',"
					+ "'" + Tools.processNull(oldPerson.getGender()) + "',"
					+ "'3',"//换卡
					+ "'" + Tools.processNull(oldCard.getSubCardId()) + "',"
					+ "'" + Tools.processNull(oldCard.getSubCardNo()) + "',"
					+ "'',"//旧卡为空,
					+ "'04',"
					+ "to_date('" + DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss") + "', 'yyyy-mm-dd hh24:mi:ss'),"
					+ "'" + log.getDealNo() + "',"
					+ "'" + Tools.processNull(oldCard.getCardType()) + "',"
					+ "'" + Tools.processNull(oldCard.getVersion()) + "',"
					+ "'" + Tools.processNull(oldCard.getInitOrgId()) + "',"
					+ "'" + Tools.processNull(oldCard.getIssueDate()) + "',"
					+ "'" + Tools.processNull(oldCard.getValidDate()) + "',"
					+ "'" + Tools.processNull(oldPerson.getNation()) + "',"
					+ "'" + Tools.processNull(oldPerson.getBirthday()) + "',"
					+ "'" + Tools.processNull(oldPerson.getResideAddr()) + "',"
					+ "'',"//就卡为空
					+ "'" + Tools.processNull(oldCard.getProOrgCode()) + "',"
					+ "'" + Tools.processNull(oldCard.getProMediaType()) + "',"
					+ "'" + Tools.processNull(oldCard.getProVersion()) + "',"
					+ "'" + Tools.processNull(oldCard.getProInitDate()) + "',"
					+ "'0',"
					+ "'',"
					+ "'',"
					+ "''"
					+ ")";
			
			publicDao.doSql(insertSql);
		} catch (Exception e) {
			throw new CommonException("同步旧卡到社保失败, " + e.getMessage());
		}
	}
	
	/**
	 * 同步新卡到社保
	 * @param newPerson
	 * @param newCard
	 */
	private void synchNew2SB(BasePersonal newPerson, CardBaseinfo newCard, BaseSiinfo newSiinfo, String newSubCardId, String oldSubCardId) {
		try {
			SysActionLog log = getCurrentActionLog();
			
			String insertSql = "insert into card_update("
					+ "CARDUPDATESEQ, CLIENTID, SUB_CARDID, SUB_CARDNUMBER, "
					+ "NAME, CERTTYPE, CERTNUMBER, SEX, CARDBIZTYPE, OLD_SUBCARDID, "
					+ "OLD_SUBCARDNUMBER, PERSONALID, SWITCHNODE, UPDATETIME, ACTIONNO, "
					+ "CARD_TYPE, VERSION, ORG_CODE, ISSUE_DATE, VALID_DATE, NATION, "
					+ "BIRTHDAY, RESIDE_ADDR, MED_WHOLE_NO, PRO_ORG_CODE, PRO_MEDIA_TYPE, "
					+ "PRO_VERSION, PRO_INIT_DATE, CLBZ, CLSJ, STCLSJ, NOTE, BANK_ID, BANK_CARD_NO, JHZT) values("
					+ "seq_card_update.nextval,"
					+ "'" + Tools.processNull(newPerson.getCustomerId()) + "',"
					+ "'" + Tools.processNull(newSubCardId) + "',"
					+ "'" + Tools.processNull(newCard.getSubCardNo()) + "',"
					+ "'" + Tools.processNull(newPerson.getName()) + "',"
					+ "'" + Tools.processNull(newPerson.getCertType()) + "',"
					+ "'" + Tools.processNull(newPerson.getCertNo()) + "',"
					+ "'" + Tools.processNull(newPerson.getGender()) + "',"
					+ "'3',"//换卡
					+ "'" + Tools.processNull(oldSubCardId) + "',"
					+ "'" + Tools.processNull(newCard.getSubCardNo()) + "',"
					+ "'" + Tools.processNull(newSiinfo.getId().getPersonalId()) + "',"//旧卡为空,
					+ "'04',"
					+ "to_date('" + DateUtil.formatDate(log.getDealTime(), "yyyy-MM-dd HH:mm:ss") + "', 'yyyy-mm-dd hh24:mi:ss'),"
					+ "'" + Tools.processNull(log.getDealNo()) + "',"
					+ "'" + Tools.processNull(newCard.getCardType()) + "',"
					+ "'" + Tools.processNull(newCard.getVersion()) + "',"
					+ "'" + Tools.processNull(newCard.getInitOrgId()) + "',"
					+ "'" + Tools.processNull(newCard.getIssueDate()) + "',"
					+ "'" + Tools.processNull(newCard.getValidDate()) + "',"
					+ "'" + Tools.processNull(newPerson.getNation()) + "',"
					+ "'" + Tools.processNull(newPerson.getBirthday()) + "',"
					+ "'" + Tools.processNull(newPerson.getResideAddr()) + "',"
					+ "'" + Tools.processNull(newSiinfo.getId().getMedWholeNo()) + "',"//旧卡为空
					+ "'" + Tools.processNull(newCard.getProOrgCode()) + "',"
					+ "'" + Tools.processNull(newCard.getProMediaType()) + "',"
					+ "'" + Tools.processNull(newCard.getProVersion()) + "',"
					+ "'" + Tools.processNull(newCard.getProInitDate()) + "',"
					+ "'0',"
					+ "'',"
					+ "'',"
					+ "'',"
					+ "'" + Tools.processNull(newCard.getBankId()) + "'," // BANK_ID
					+ "'" + Tools.processNull(newCard.getBankCardNo()) + "'," // BANK_CARD_NO
					+ "'1'" // JHZT
					+ ")";
			
			publicDao.doSql(insertSql);
		} catch (Exception e) {
			throw new CommonException("同步新卡到社保失败, " + e.getMessage());
		}
	}
}
