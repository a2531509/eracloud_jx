package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import com.erp.util.DateUtil;
import org.springframework.stereotype.Service;

import com.alibaba.fastjson.JSON;
import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.AccCreditLimit;
import com.erp.model.AccFreezeRec;
import com.erp.model.AccKindConfig;
import com.erp.model.AccOpenConf;
import com.erp.model.AccStateTradingBan;
import com.erp.model.BasePersonal;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.SysCode;
import com.erp.model.SysCodeId;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.AccAcountService;
import com.erp.service.AccountManagementService;
import com.erp.service.DoWorkClientService;
import com.erp.util.Constants;
import com.erp.util.DealCode;
import com.erp.util.Tools;
@Service("accountManagementService")
public class AccountManagementServiceImpl extends BaseServiceImpl implements AccountManagementService {
	@Resource(name="accAcountService")
	private AccAcountService accAcountService;
	@Resource(name="doWorkClientService")
	private DoWorkClientService doWorkClient;
	/**
	 * 新增或是编辑保存账户类型
	 */
	@SuppressWarnings("unchecked")
	@Override
	public TrServRec saveOrUpdateAccKindConfig(AccKindConfig config,String otype) throws CommonException {
		try{
			//1.基本条件判断
			Integer tempDealCode = 0;
			String string = "";
			if(Tools.processNull(otype).equals("0")){
				string = "新增账户类型";
				tempDealCode = DealCode.ACC_MANAGER_ADD;
			}else if(Tools.processNull(otype).equals("1")){
				string = "编辑账户类型";
				tempDealCode = DealCode.ACC_MANAGER_EDIT;
			}else{
				throw new CommonException(string + "，操作类型不正确！");
			}
			if(config == null){
				throw new CommonException(string + "，账户类型不能为空！");
			}
			if(Tools.processNull(config.getAccKind()).equals("")){
				throw new CommonException(string + "，账户类型编码不能为空！");
			}
			if(Tools.processNull(config.getAccName()).equals("")){
				throw new CommonException(string + "，账户类型名称不能为空！");
			}
			if(Tools.processNull(config.getAccKind()).equals("")){
				throw new CommonException(string + "，请选择账户类型状态！");
			}
			//2.账户类型新增或是编辑
			SysActionLog log = this.getCurrentActionLog();
			log.setMessage(string + "【" + config.getAccName() + "】" + JSON.toJSONString(config));
			log.setDealCode(tempDealCode);
			publicDao.save(log);
			AccKindConfig oldCfg = (AccKindConfig) this.findOnlyRowByHql("from AccKindConfig t where t.accKind = '" + config.getAccKind() + "'");
			if(otype.equals("0")){
				if(oldCfg != null){
					throw new CommonException("该账户类型编码【" + config.getAccKind() + "】已存在，不能重复进行添加！");
				}
				config.setOpenDate(this.getDateBaseTime());//新增时间
				config.setOpenUserId(this.getUser().getUserId());//新增柜员
				publicDao.save(config);
			}else if(otype.equals("1")){
				if(oldCfg == null){
					throw new CommonException(string + "发生错误，未获取到原始账户类型，无法进行编辑！");
				}
				oldCfg.setAccName(config.getAccName());
				//oldCfg.setAccKindState(config.getAccKindState());
				oldCfg.setAloneActivateFlag(config.getAloneActivateFlag());
				oldCfg.setNote(config.getNote());
				oldCfg.setOrdNo(config.getOrdNo());
				publicDao.update(oldCfg);
			}
			//3.保存SYS_CODE表
			SysCode sysCode = (SysCode) this.findOnlyRowByHql("from SysCode t where id.codeType = 'ACC_KIND' and id.codeValue = '" + config.getAccKind() + "'");
			if(sysCode == null){
				sysCode = new SysCode();
				SysCodeId codeId = new SysCodeId();
				codeId.setCodeType("ACC_KIND");
				codeId.setCodeValue(config.getAccKind());
				sysCode.setId(codeId);
				sysCode.setCodeState(config.getAccKindState());
				sysCode.setTypeName("账户类型");
				sysCode.setCodeName(config.getAccName());
				sysCode.setOrdNo(config.getOrdNo());
				publicDao.save(sysCode);
			}else{
				SysCodeId codeId = new SysCodeId();
				codeId.setCodeType("ACC_KIND");
				codeId.setCodeValue(config.getAccKind());
				sysCode.setId(codeId);
				//sysCode.setCodeState(config.getAccKindState());
				sysCode.setTypeName("账户类型");
				sysCode.setCodeName(config.getAccName());
				sysCode.setOrdNo(config.getOrdNo());
				publicDao.update(sysCode);
			}
			//4.保存业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.STATE_ZC);
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setAccKind(config.getAccKind());
			rec.setNote(log.getMessage());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 禁用或启用账户类型
	 * @param config
	 * @param type 0 启用 1 禁用
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveEnableOrDisable(AccKindConfig config,String type) throws CommonException{
		try{
			//1.基本条件判断
			String string = "";
			Integer tempDealCode = 0;
			if(Tools.processNull(type).equals("0")){
				string = "启用账户类型";
				tempDealCode = DealCode.ACC_MANAGER_ENABLE;
			}else if(Tools.processNull(type).equals("1")){
				string = "禁用账户类型";
				tempDealCode = DealCode.ACC_MANAGER_DISABLE;
			}else{
				throw new CommonException("启用或禁用账户类型发生错误，传入操作类型不正确！" );
			}
			if(config == null || Tools.processNull(config.getAccKind()).equals("")){
				throw new CommonException(string + "发生错误，传入账户类型编码不能为空！");
			}
			//2.业务操作
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(tempDealCode);
			AccKindConfig oldCfg = (AccKindConfig) this.findOnlyRowByHql("from AccKindConfig t where t.accKind = '" + config.getAccKind() + "'");
			if(oldCfg == null){
				throw new CommonException(string + "发生错误，原始账户类型记录不存在！");
			}
			log.setMessage(string + "【" + oldCfg.getAccName() + "】");
			publicDao.save(log);
			oldCfg.setAccKindState(type);
			if(type.equals("0")){
				oldCfg.setStopDate(null);
				oldCfg.setStopUserId("");
			}else{
				oldCfg.setStopDate(this.getDateBaseTime());
				oldCfg.setStopUserId(this.getUser().getUserId());
			}
			publicDao.update(oldCfg);
			//3.SYS_COE代码表
			SysCode sysCode = (SysCode) this.findOnlyRowByHql("from SysCode t where id.codeType = 'ACC_KIND' and id.codeValue = '" + oldCfg.getAccKind() + "'");
			if(sysCode == null){
				sysCode = new SysCode();
				SysCodeId codeId = new SysCodeId();
				codeId.setCodeType("ACC_KIND");
				codeId.setCodeValue(oldCfg.getAccKind());
				sysCode.setId(codeId);
				sysCode.setCodeState(oldCfg.getAccKindState());
				sysCode.setTypeName("账户类型");
				sysCode.setCodeName(oldCfg.getAccName());
				sysCode.setOrdNo(oldCfg.getOrdNo());
				publicDao.save(sysCode);
			}else{
				SysCodeId codeId = new SysCodeId();
				codeId.setCodeType("ACC_KIND");
				codeId.setCodeValue(oldCfg.getAccKind());
				sysCode.setId(codeId);
				sysCode.setCodeState(oldCfg.getAccKindState());
				publicDao.update(sysCode);
			}
			//4.记录综合业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.STATE_ZC);
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setAccKind(config.getAccKind());
			rec.setNote(log.getMessage());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 账户类型删除
	 */
	public TrServRec saveAccKindConfigDelete(String accKind) throws CommonException{
		try{
			//1.基本条件判断
			System.out.println("accKind=================="+accKind);
			if(Tools.processNull(accKind).equals("")){
				throw new CommonException("删除账户类型，账户类型编号不能为空！");
			}
			//2.业务处理
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(DealCode.ACC_MANAGER_DEL);
			AccKindConfig config = (AccKindConfig) this.findOnlyRowByHql("from AccKindConfig t where t.accKind = '" + accKind + "'");
			if(config != null){
				log.setMessage("账户类型删除" + "【" + config.getAccName() + "】");
				publicDao.delete(config);
			}
			publicDao.save(log);
			//删除SYS_CODE
			publicDao.doSql("delete from  sys_code t where t.code_type = 'ACC_KIND' and t.code_value = '" + accKind + "'");
			//3.记录日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setDealState(Constants.STATE_ZC);
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			if(config != null){
				rec.setAccKind(config.getAccKind());
			}
			rec.setNote(log.getMessage());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 新增保存或是编辑保存账户开户规则
	 * @param conf
	 * @param type
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveOrUpdateAccOpenConf(AccOpenConf conf,String type) throws CommonException{
		try{
			//1.基本条件判断
			Integer tempDealCode = 0;
			String judgeSql = "";
			String string = "";
			if(Tools.processNull(type).equals("0")){
				string = "新增账户开户规则";
				tempDealCode = DealCode.ACC_OPEN_RULE_ADD;
			}else if(Tools.processNull(type).equals("1")){
				string = "编辑账户开户规则";
				tempDealCode = DealCode.ACC_OPEN_RULE_EDIT;
			}else{
				throw new CommonException(string + "，操作类型不正确！");
			}
			if(conf == null){
				throw new CommonException(string + "，账户规则内容不能为空！");
			}
			if(Tools.processNull(conf.getMainType()).equals("")){
				throw new CommonException(string + "，账户开户规则主体类型不能为空！");
			}
			//2.插入操作日志
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(tempDealCode);
			log.setMessage(string + JSON.toJSONString(conf));
			publicDao.save(log);
			//3.插入规则
			if(Tools.processNull(type).equals("0")){
				if(Tools.processNull(conf.getMainType()).equals("1")){
					judgeSql = "select t.id from ACC_OPEN_CONF t where t.sub_type = '" + conf.getSubType() +  "' and t.acc_kind = '" + conf.getAccKind() + "'";
				}else{
					judgeSql = "select t.id from ACC_OPEN_CONF t where t.main_type = '" + conf.getMainType() +  "' and t.item_id = '" + conf.getItemId() + "'";
				}
				List<?> jb = this.findBySql(judgeSql);
				if(jb != null && jb.size() > 0){
					throw new CommonException("相同开户规则已存在，请不要重复添加！");
				}
				publicDao.save(conf);
			}else if(Tools.processNull(type).equals("1")){
				AccOpenConf oldConf = (AccOpenConf) this.findOnlyRowByHql("from AccOpenConf t where t.id = " + conf.getId());
				if(oldConf == null){
					throw new CommonException("编辑开户规则出现错误，根据规则编号ID=" + conf.getId() + "未找到规则信息！");
				}
				oldConf.setAccInitState(conf.getAccInitState());
				if(Tools.processNull(oldConf.getMainType()).equals("1")){
					oldConf.setSubType(conf.getSubType());
					oldConf.setAccKind(conf.getAccKind());
				}else{
					oldConf.setItemId(conf.getItemId());
				}
				if(Tools.processNull(oldConf.getMainType()).equals("1")){
					judgeSql = "select t.id from ACC_OPEN_CONF t where t.sub_type = '" + oldConf.getSubType() +  "' and t.acc_kind = '" + oldConf.getAccKind() + "' and t.id <> " + oldConf.getId();
				}else{
					judgeSql = "select t.id from ACC_OPEN_CONF t where t.main_type = '" + oldConf.getMainType() +  "' and t.item_id = '" + oldConf.getItemId() + "' and t.id <> " + oldConf.getId();
				}
				List<?> jb = this.findBySql(judgeSql);
				if(jb != null && jb.size() > 0){
					throw new CommonException("相同开户规则已存在，请编辑成其他开户规则！");
				}
				publicDao.update(oldConf);
				conf = oldConf;
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setDealState(Constants.STATE_ZC);
			rec.setAccKind(conf.getAccKind());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 删除账户开户规则
	 * @param id
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveAccOpenConfDelete(Long id) throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(id).equals("")){
				throw new CommonException("删除账户开户规则出现错误，规则编号不能为空！");
			}
			AccOpenConf conf = (AccOpenConf) this.findOnlyRowByHql("from AccOpenConf t where t.id = " + id );
			if(conf == null){
				throw new CommonException("删除账户开户规则出现错误，根据规则编号ID=" + id + "未找到规则信息！");
			}
			//2.记录日志信息
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(DealCode.ACC_OPEN_RULE_DEL);
			log.setMessage("账户开户规则删除ID=" + id + JSON.toJSONString(conf));
			publicDao.save(log);
			//删除规则信息
			int isExists = publicDao.doSql("delete from ACC_OPEN_CONF t where t.id = " + id);
			if(isExists != 1){
				throw new CommonException("删除账户开户规则出现错误，根据规则编号ID=" + id + "删除" + isExists + "行！");
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setDealState(Constants.STATE_ZC);
			rec.setAccKind(conf.getAccKind());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 启用或是禁用账户开户规则
	 * @param id   规则ID
	 * @param type 操作类型 type == 0启用   type == 1禁用
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveDisableOrEnableAccOpenConf(Long id,String type) throws CommonException{
		try{
			//1.基本条件判断
			String string = "";
			Integer tempdealcode = 0;
			if(Tools.processNull(type).equals("0")){
				string += "启用账户开户规则";
				tempdealcode = DealCode.ACC_OPEN_RULE_ENABLE;
			}else if(Tools.processNull(type).equals("1")){
				string += "禁用账户开户规则";
				tempdealcode = DealCode.ACC_OPEN_RULE_DISABLE;
			}else{
				throw new CommonException("启用或禁用账户开户规则出现错误，传入错误类型不正确！");
			}
			if(Tools.processNull(id).equals("")){
				throw new CommonException(string + "出现错误，规则编号不能为空！");
			}
			AccOpenConf conf = (AccOpenConf) this.findOnlyRowByHql("from AccOpenConf t where t.id = " + id );
			if(conf == null){
				throw new CommonException(string + "出现错误，根据规则编号ID=" + id + "未找到规则信息！");
			}
			//2.记录日志信息
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(tempdealcode);
			log.setMessage(string + "ID=" + id);
			publicDao.save(log);
			//3.业务处理
			conf.setConfState(type);
			int upcount = publicDao.doSql("update acc_open_conf t set conf_state = '" + type + "' where t.id = " + id);
			if(upcount != 1){
				throw new CommonException(string + "发生错误，更新" + upcount + "行！");
			}
			///4.记录综合业务日志
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setDealState(Constants.STATE_ZC);
			rec.setAccKind(conf.getAccKind());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 新增保存或是编辑保存账户状态和禁止交易码关联
	 * @param ban  账户状态和禁止交易码关联对象  
	 * @param type 操作类型 type == 0 新增   type == 1 编辑
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveOrUpdateAccStateTradingBan(AccStateTradingBan ban,String type) throws CommonException{
		try{
			//1.基本条件判断
			String string = "";
			Integer tempdealcode = 0;
			if(Tools.processNull(type).equals("0")){
				string += "新增账户状态和禁止交易关联";
				tempdealcode = DealCode.ACC_STATE_TRADING_BAN_MANAGER_ADD;
			}else if(Tools.processNull(type).equals("1")){
				string += "编辑账户状态和禁止交易关联";
				tempdealcode = DealCode.ACC_STATE_TRADING_BAN_MANAGER_EDIT;
			}else{
				throw new CommonException("新增或编辑账户状态和禁止交易代码关联发生错误，传入错误类型不正确！");
			}
			if(ban == null){
				throw new CommonException("传入内容不能为空！");
			}
			if(ban.getId() == null && type.equals("1")){
				throw new CommonException(string + "发生错误，传入参数不能为空！");
			}
			if(Tools.processNull(ban.getCardType()).equals("")){
				throw new CommonException(string + "发生错误，传入卡类型不能为空！");
			}
			if(Tools.processNull(ban.getAccKind()).equals("")){
				throw new CommonException(string + "发生错误，传入账户类型不能为空！");
			}
			if(Tools.processNull(ban.getAccState()).equals("")){
				throw new CommonException(string + "发生错误，传入账户状态不能为空！");
			}
			if(Tools.processNull(ban.getBanDealCode()).equals("")){
				throw new CommonException(string + "发生错误，传入禁止交易代码不能为空！");
			}
			//2.插入日志信息
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(tempdealcode);
			log.setMessage("");
			publicDao.save(log);
			//3.业务处理
			StringBuffer judgeSql = new StringBuffer();
			judgeSql.append("select count(1) from acc_state_trading_ban t ");
			judgeSql.append("where t.card_type = '" + ban.getCardType() + "' and t.acc_kind = '" + ban.getAccKind() + "' ");
			judgeSql.append("and t.acc_state = '" + ban.getAccState() + "' and t.ban_deal_code = '" + ban.getBanDealCode() + "' ");
			if(type.equals("1")){
				judgeSql.append("and t.id <> " + ban.getId());
			}
			BigDecimal icount = (BigDecimal) this.findOnlyFieldBySql(judgeSql.toString());
			if((type.equals("0") && icount.longValue() > 0) || (type.equals("1") && icount.longValue() > 0)){
				throw new CommonException(string + "发生错误，相同账户状态禁止交易规则已存在！"); 
			}
			if(type.equals("0")){
				publicDao.save(ban);
			}else{
				AccStateTradingBan oldban = (AccStateTradingBan) this.findOnlyRowByHql("from AccStateTradingBan t where t.id = " + ban.getId());
				oldban.setCardType(ban.getCardType());
				oldban.setAccKind(ban.getAccKind());
				oldban.setAccState(ban.getAccState());
				oldban.setBanDealCode(ban.getBanDealCode());
				oldban.setNote(ban.getNote());
				//oldban.setState(state);
				publicDao.update(oldban);
				ban = oldban;
			}
			//4.插入日志信息
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage() + JSON.toJSONString(ban));
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setDealState(Constants.STATE_ZC);
			rec.setAccKind(ban.getAccKind());
			rec.setCardType(ban.getCardType());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 删除账户状态和禁止交易代码关联信息
	 * @param id 账户状态和禁止交易代码关联信息编号
	 * @return  TrServRec 操作日志信息
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec  saveAccStateTradingBanDelete(Long id)throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(id).equals("")){
				throw new CommonException("删除账户状态和禁止交易代码关联发生错误，关联ID不能为空！");
			}
			AccStateTradingBan ban = (AccStateTradingBan) this.findOnlyRowByHql("from AccStateTradingBan t where t.id = " + id);
			if(ban == null){
				throw new CommonException("删除账户状态和禁止交易代码关联发生错误，根据ID=" + id + "未找到禁止规则信息！");
			}
			//2.插入日志信息
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(DealCode.ACC_STATE_TRADING_BAN_MANAGER_DEAL);
			log.setMessage("删除账户状态和禁止交易代码关联ID=" + id);
			publicDao.save(log);
			//3.业务处理
			publicDao.delete(ban);
			//4.插入日志信息
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage() + JSON.toJSONString(ban));
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setDealState(Constants.STATE_ZC);
			rec.setAccKind(ban.getAccKind());
			rec.setCardType(ban.getCardType());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 启用或是禁用账户状态和禁止交易代码关联信息
	 * @param id   规则ID
	 * @param type 操作类型
	 * @return TrServRec 操作日志信息
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveDisableOrEnableAccStateTradingBan(Long id,String type) throws CommonException{
		try{
			//1.基本条件判断
			String string = "";
			Integer tempdealcode = 0;
			if(Tools.processNull(type).equals("0")){
				string += "启用账户状态和禁止交易代码关联信息";
				tempdealcode = DealCode.ACC_STATE_TRADING_BAN_MANAGER_ENABLE;
			}else if(Tools.processNull(type).equals("1")){
				string += "禁用账户状态和禁止交易代码关联信息";
				tempdealcode = DealCode.ACC_STATE_TRADING_BAN_MANAGER_DISABLE;
			}else{
				throw new CommonException("启用或禁用账户状态和禁止交易代码关联信息出现错误，传入错误类型不正确！");
			}
			if(Tools.processNull(id).equals("")){
				throw new CommonException(string + "出现错误，账户状态和禁止交易代码关联编号不能为空！");
			}
			AccStateTradingBan ban = (AccStateTradingBan) this.findOnlyRowByHql("from AccStateTradingBan t where t.id = '" + id + "'");
			if(ban == null){
				throw new CommonException(string + "出现错误，根据ID=" + id + "未找到任何信息！");
			}
			//2.插入日志信息
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(tempdealcode);
			log.setMessage(string + "ID=" + id);
			publicDao.save(log);
			//3.业务处理
			int upcount = publicDao.doSql("update ACC_STATE_TRADING_BAN t set t.state = '" + type + "' where t.id = " + id);
			if(upcount != 1){
				throw new CommonException(string + "出现错误，根据ID=" + id + "更新" + upcount + "行！");
			}
			//4.插入日志信息
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setDealState(Constants.STATE_ZC);
			rec.setAccKind(ban.getAccKind());
			rec.setCardType(ban.getCardType());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 新增保存或是编辑保存账户限额设置信息
	 * @param limit  账户限额设置信息对象
	 * @param rec    新增或是更新日志信息
	 * @param type   操作类型 type == 0 新增   type == 1 编辑
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveOrUpdateAccLimit(AccCreditLimit limit,TrServRec rec,String type) throws CommonException{
		try{
			//1.基本条件判断
			String string = "";
			Integer tempdealcode = 0;
			AccAccountSub targerAcc = new AccAccountSub();
			if(Tools.processNull(type).equals("0")){
				string += "新增账户限额信息";
				tempdealcode = DealCode.ACC_CREDIT_LIMIT_ADD;
			}else if(Tools.processNull(type).equals("1")){
				string += "编辑账户限额信息";
				tempdealcode = DealCode.ACC_CREDIT_LIMIT_EDIT;
			}else{
				throw new CommonException("新增或编辑账户限额信息发生错误，传入错误类型不正确！");
			}
			if(limit == null){
				throw new CommonException(string + "出现错误，传入参数信息不正确！");
			}
			if(Tools.processNull(type).equals("0")){
				if(Tools.processNull(limit.getCardNo()).equals("")){
					throw new CommonException(string + "出现错误，卡号不能为空！");
				}
				if(Tools.processNull(limit.getAccKind()).equals("")){
					throw new CommonException(string + "出现错误，账户类型不能为空！");
				}
				targerAcc = accAcountService.getAccSubLedgerByCardNoAndAccKind(limit.getCardNo(),limit.getAccKind(),"00");
				if(targerAcc == null){
					throw new CommonException(string + "出现错误，获取账户信息失败！");
				}
			}
			if(Tools.processNull(limit.getAmt()).equals("") || Tools.processNull(limit.getMinAmt()).equals("") || Tools.processNull(limit.getMaxAmt()).equals("")){
				throw new CommonException(string + "出现错误，限额信息不能全为空！");
			}
			//2.插入日志信息
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(tempdealcode);
			log.setMessage(string);
			publicDao.save(log);
			//3.业务处理
			if(Tools.processNull(type).equals("0")){
				AccCreditLimit oldLimit = (AccCreditLimit) this.findOnlyRowByHql("from AccCreditLimit t where t.cardNo = '" + limit.getCardNo() + "' and t.accKind = '" + limit.getAccKind() + "'");
				if(oldLimit != null){
					throw new CommonException("卡号为【" + limit.getCardNo() + "】的【" + this.getCodeNameBySYS_CODE("ACC_KIND",limit.getAccKind()) + "】限额信息已存在，请使用编辑功能进行编辑！");
				}
				limit.setCardNo(targerAcc.getCardNo());
				limit.setAccKind(targerAcc.getAccKind());
				limit.setAccNo(targerAcc.getAccNo());
				limit.setBizTime(log.getDealTime());
				limit.setBrchId(this.getUser().getBrchId());
				limit.setUserId(this.getUser().getUserId());
				limit.setCardType(targerAcc.getCardType());
				limit.setClrDate(this.getClrDate());
				limit.setCustomerId(targerAcc.getCustomerId());
				limit.setDealNo(log.getDealNo());
				limit.setItemNo(targerAcc.getItemId());
				limit.setNote(log.getNote());
				limit.setOrgId(log.getOrgId());
				limit.setState(Constants.STATE_ZC);
				publicDao.save(limit);
			}else if(Tools.processNull(type).equals("1")){
				int upcount = publicDao.doSql("update acc_credit_limit t set t.amt = '" + limit.getAmt() + "',min_amt = '" + limit.getMinAmt() + "',max_amt = '" + limit.getMaxAmt() + "',max_num='"+limit.getMaxNum()+"' where t.deal_no = " + limit.getDealNo());
				if(upcount != 1){
					throw new CommonException(string + "出现错误，根据限额编号" + limit.getDealNo() + "更新" + upcount + "行！");
				}
			}
			//4.插入日志信息
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setNote(log.getMessage());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setDealState(Constants.STATE_ZC);
			rec.setAccKind(targerAcc.getAccKind());
			rec.setCardType(targerAcc.getCardType());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 删除账户限额设置信息
	 * @param dealNo 限额设置信息的ID
	 * @return TrServRec 删除的操作日志信息
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveAccLimitDelete(Long dealNo) throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(dealNo).equals("")){
				throw new CommonException("删除账户限额设置信息发生错误，传入限额设置编号为空！");
			}
			AccCreditLimit limit = (AccCreditLimit) this.findOnlyRowByHql("from AccCreditLimit t where t.dealNo = " + dealNo);
			if(limit == null){
				throw new CommonException("删除账户限额设置信息发生错误,根据限额设置编号" + dealNo + "未找到有效的设置信息！");
			}
			//2.业务处理
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(DealCode.ACC_CREDIT_LIMIT_DEL);
			log.setMessage("删除账户限额设置信息");
			publicDao.save(log);
			int upcount = publicDao.doSql("delete from Acc_Credit_Limit t where t.deal_no = " + dealNo);
			if(upcount != 1){
				throw new CommonException("删除账户限额设置信息发生错误,根据限额设置编号" + dealNo + "删除" + upcount + "行记录！");
			}
			//3.记录业务日志信息
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setDealState(Constants.STATE_ZC);
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setOrgId(log.getOrgId());
			rec.setCardType(limit.getCardType());
			rec.setCardNo(limit.getCardNo());
			rec.setAccKind(limit.getAccKind());
			rec.setAccNo(limit.getAccNo() + "");
			rec.setCustomerId(limit.getCustomerId());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 启用或是禁用账户限额设置信息
	 * @param dealNo  限额设置信息的ID
	 * @return  TrServRec 启用或是禁用的操作日志信息
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveDisableOrEnableAccLimit(Long dealNo,String type) throws CommonException{
		try{
			//1.基本条件判断
			String string = "";
			Integer tempdealcode = 0;
			if(Tools.processNull(type).equals("0")){
				string += "启用账户限额设置信息";
				tempdealcode = DealCode.ACC_CREDIT_LIMIT_ENABLE;
			}else if(Tools.processNull(type).equals("1")){
				string += "禁用账户限额设置信息";
				tempdealcode = DealCode.ACC_CREDIT_LIMIT_DISABLE;
			}else{
				throw new CommonException("启用或禁用账户限额设置信息发生错误，传入错误类型不正确！");
			}
			if(Tools.processNull(dealNo).equals("")){
				throw new CommonException(string + "出现错误，账户限额设置信息编号不能为空！");
			}
			AccCreditLimit limit = (AccCreditLimit) this.findOnlyRowByHql("from AccCreditLimit t where t.dealNo = " + dealNo);
			if(limit == null){
				throw new CommonException(string + "出现错误，根据账户限额设置编号" + dealNo + "未找到任何信息！");
			}
			//2.插入日志信息
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(tempdealcode);
			log.setMessage(string + "dealNo=" + dealNo);
			publicDao.save(log);
			//3.业务处理
			int upcount = publicDao.doSql("update Acc_Credit_Limit  t set t.state = '" + type + "' where t.deal_no = " + dealNo);
			if(upcount != 1){
				throw new CommonException(string + "出现错误，根据账户限额设置编号" + dealNo + "更新" + upcount + "行！");
			}
			//4.插入日志信息
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setDealState(Constants.STATE_ZC);
			rec.setClrDate(this.getClrDate());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setUserId(this.getUser().getUserId());
			rec.setOrgId(log.getOrgId());
			rec.setCardType(limit.getCardType());
			rec.setCardNo(limit.getCardNo());
			rec.setAccKind(limit.getAccKind());
			rec.setAccNo(limit.getAccNo() + "");
			rec.setCustomerId(limit.getCustomerId());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 账户锁定与解锁
	 * @param cardNo  锁定/解锁的卡号
	 * @param accKind 锁定/解锁的账户类型
	 * @param type    type == 0 锁定  type == 1 解锁
	 * @return  操作业务日志
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveAccountLockOrUnlock(String cardNo,String accKind,String type)throws CommonException{
		try{
			//1.基本条件判断
			String temp_state = "";
			String string = "";
			Integer tempdealcode = 0;
			if(Tools.processNull(type).equals("0")){
				string = "账户锁定";
				temp_state = Constants.ACC_STATE_SD;
				tempdealcode = DealCode.ACC_STATE_LOCK;
			}else if(Tools.processNull(type).equals("1")){
				string = "账户解锁";
				temp_state = Constants.ACC_STATE_ZC;
				tempdealcode = DealCode.ACC_STATE_UNLOCK;
			}else{
				throw new CommonException("账户锁定（解锁）失败，传入操作类型不正确！");
			}
			if(Tools.processNull(cardNo).equals("")){
				throw new CommonException(string + "发生错误，传入卡号不能为空！");
			}
			if(Tools.processNull(accKind).equals("")){
				throw new CommonException(string + "发生错误，传入账户类型不能为空！");
			}
			//2.记录日志信息
			SysActionLog log = this.getCurrentActionLog();
			log.setDealCode(tempdealcode);
			log.setMessage(string + ",card_no=" + cardNo + ",acc_kind=" + accKind);
			publicDao.save(log);
			//3.业务处理
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
			AccAccountSub accstub = (AccAccountSub) this.findOnlyRowByHql("from AccAccountSub t where t.cardNo = '" + cardNo + "' and t.accKind = '" + accKind + "'");
			if(card == null){
				throw new CommonException(string + "发生错误，根据卡号【" + cardNo + "】未查询到卡信息！");
			}
			if(accstub == null){
				throw new CommonException(string + "发生错误，根据卡号【" + cardNo + "】未查询到" + this.getCodeNameBySYS_CODE("ACC_KIND",accKind) + "信息！");
			}
			if(type.equals("0")){
				/*if(Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_SD)){
					throw new CommonException(string + "发生错误,卡号【" + cardNo + "】状态已是锁定状态无需重复锁定！" );
				}else if(!Tools.processNull(card.getCardState()).equals("1")){
					throw new CommonException(string + "发生错误,卡号【" + cardNo + "】状态不正常，当前状态：" + this.getCodeNameBySYS_CODE("CARD_STATE",card.getCardState()));
				}*/
				if(Tools.processNull(accstub.getAccState()).equals(Constants.ACC_STATE_SD)){
					throw new CommonException(string + "发生错误,卡号【" + cardNo + "】" + this.getCodeNameBySYS_CODE("ACC_KIND",accKind) + "已是锁定状态，无需重复锁定！");
				}else if(!Tools.processNull(accstub.getAccState()).equals("1")){
					throw new CommonException(string + "发生错误,卡号【" + cardNo + "】" + this.getCodeNameBySYS_CODE("ACC_KIND",accKind) + "状态不正常，当前状态：" + this.getCodeNameBySYS_CODE("ACC_STATE",accstub.getAccState()));
				}
			}else if(type.equals("1")){
				/*if(Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZC)){
					throw new CommonException(string + "发生错误,卡号【" + cardNo + "】状态已是正常状态，无需重复解锁！");
				}
				if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_SD)){
					throw new CommonException(string + "发生错误,卡号【" + cardNo + "】状态不是锁定状态，当前状态：" + this.getCodeNameBySYS_CODE("CARD_STATE",card.getCardState()));
				}*/
				if(Tools.processNull(accstub.getAccState()).equals(Constants.ACC_STATE_ZC)){
					throw new CommonException(string + "发生错误,卡号【" + cardNo + "】" + this.getCodeNameBySYS_CODE("ACC_KIND",accKind) + "已是正常状态，无需重复解锁！");
				}
				if(!Tools.processNull(accstub.getAccState()).equals(Constants.ACC_STATE_SD)){
					throw new CommonException(string + "发生错误,卡号【" + cardNo + "】" + this.getCodeNameBySYS_CODE("ACC_KIND",accKind) + "不是锁定状态，当前状态：" + this.getCodeNameBySYS_CODE("ACC_STATE",accstub.getAccState()));
				}
			}
			int upcount = publicDao.doSql("update acc_account_sub t set t.acc_state = '" + temp_state + "' where t.card_no = '" + cardNo + "' and t.acc_kind = '" + accKind + "'");
			if(upcount != 1){
				throw new CommonException(string + "发生错误，根据卡号【" + cardNo + "】更新" + this.getCodeNameBySYS_CODE("ACC_KIND",accKind) + upcount + "行！");
			}
			/*int upcounts = publicDao.doSql("update CARD_BASEINFO t set t.card_state = '" + temp_state + "' where t.card_no = '" + cardNo + "'");
			if(upcounts != 1){
				throw new CommonException(string + "发生错误，根据卡号【" + cardNo + "】更新卡片信息" + upcount + "行！");
			}*/
			//记录日志
			BasePersonal bp = new BasePersonal();
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(bp == null){
					bp = new BasePersonal();
				}
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBrchId(this.getUser().getBrchId());
			rec.setOrgId(log.getOrgId());
			rec.setUserId(this.getUser().getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setDealState(Constants.STATE_ZC);
			rec.setNote(log.getMessage());
			rec.setClrDate(this.getClrDate());
			rec.setCustomerId(card.getCustomerId());
			rec.setCustomerName(bp.getName());
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setAccKind(accstub.getAccKind());
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			rec.setCardId(card.getCardId());
			rec.setCardAmt(1L);
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 账户状态激活（未激活状态的账户进行激活）
	 * @param cardNo  卡号
	 * @param accKind 账户类型
	 * @param log     操作日志
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveAccEnableQuery(String cardNo,String accKind,String pwd,TrServRec rec,SysActionLog log) throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(cardNo).equals("")){
				throw new CommonException("账户激活发生错误，传入卡号不能为空！");
			}
			if(Tools.processNull(accKind).equals("")){
				throw new CommonException("账户激活发生错误，传入账户类型不能为空！");
			}
			if(log == null){
				throw new CommonException("账户激活发生错误，操作日志不能为空！");
			}
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
			if(card == null){
				throw new CommonException("账户激活发生错误，卡片信息不存在！");
			}
			if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZC)){
				throw new CommonException("账户激活发生错误，卡片信息状态不正常！当前状态：" + this.getCodeNameBySYS_CODE("CARD_STATE",card.getCardState()));
			}
			AccAccountSub stub = (AccAccountSub) this.findOnlyRowByHql("from AccAccountSub t where t.cardNo = '" + cardNo + "' and t.accKind = '" + accKind + "'");
			if(stub == null){
				throw new CommonException("账户激活发生错误，根据卡号未找到卡号为【" +cardNo + "】的" + this.getCodeNameBySYS_CODE("ACC_KIND",accKind) + "信息！");
			}
			if(!Tools.processNull(stub.getAccState()).equals(Constants.ACC_STATE_WQY)){
				throw new CommonException("账户激活发生错误，卡号为【" +cardNo + "】的" + this.getCodeNameBySYS_CODE("ACC_KIND",accKind) + "不是未启用状态！");
			}
			//2.插入日志信息
			log.setDealCode(DealCode.ACC_STATE_ENABLE);
			log.setMessage("未激活账户激活card_no=" + cardNo + ",acc_kind=" + accKind);
			publicDao.save(log);
			//3.业务处理
			int upcount = publicDao.doSql("update acc_account_sub t set t.acc_state = '" + Constants.ACC_STATE_ZC + "' where t.card_no = '" + cardNo + "' and t.acc_kind = '" + accKind + "'");
			if(upcount != 1){
				throw new CommonException("账户激活发生错误，根据卡号【" + cardNo + "】和账户类型类型" + accKind + "更新" + upcount + "行！");
			}
			String newPwd = doWorkClient.encrypt_PinPwd(card.getCardNo(),pwd);
			if(Tools.processNull(newPwd).equals("")){
				throw new CommonException("密文加密失败！");
			}
			int updatarows = publicDao.doSql("update CARD_BASEINFO t set t.pay_pwd = '" + newPwd + "' where t.card_no = '" + card.getCardNo() + "'");
			if(updatarows != 1){
				throw new CommonException("账户激活发生错误，更新密码，更新" + updatarows + "行！");
			}
			//4.记录业务日志
			BasePersonal bp = new BasePersonal();
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(bp == null){
					bp = new BasePersonal();
				}
			}
			rec.setCardId(card.getCardId());
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCardAmt(1L);
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			rec.setAccKind(stub.getAccKind());
			rec.setAccNo(stub.getAccNo() + "");
			rec.setDealCode(log.getDealCode());
			rec.setDealNo(log.getDealNo());
			rec.setBizTime(log.getDealTime());
			rec.setBrchId(this.getUser().getUserId());
			rec.setUserId(this.getUser().getUserId());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Constants.STATE_ZC);
			rec.setNewPwd(newPwd);
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 账户金额冻结
	 * @param cardNo     冻结卡号
	 * @param accKind    冻结账户类型
	 * @param freezeAmt  冻结金额
	 * @param users      操作用户
	 * @param rec        操作业务日志
	 * @param log        操作日志
	 * @return           操作业务日志
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec  saveAccFreeze(String cardNo,String accKind,Long freezeAmt,String pwd,Users users,TrServRec rec,SysActionLog log) throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(cardNo).equals("")){
				throw new CommonException("冻结卡号不能为空");
			}
			if(Tools.processNull(accKind).equals("")){
				throw new CommonException("冻结账户类型不能为空");
			}
			if(Tools.processNull(freezeAmt).equals("") || freezeAmt <= 0){
				throw new CommonException("冻结金额不能为空或小于等于0");
			}
			if(users == null || Tools.processNull(users.getUserId()).equals("")){
				throw new CommonException("操作员不能为空");
			}
			CardBaseinfo card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
			if(card == null){
				throw new CommonException("卡片信息不存在");
			}
			AccAccountSub acc = accAcountService.getAccSubLedgerByCardNoAndAccKind(cardNo,accKind,"00");
			//2.插入日志
			log.setDealCode(DealCode.ACC_STATE_FREEZE);
			log.setMessage("冻结账户金额卡号" + cardNo + ",账户类型" + accKind + ",金额" + freezeAmt);
			publicDao.save(log);
			//3.业务处理
			StringBuffer sb = new StringBuffer();
			sb.append(log.getDealNo()).append("|");//操作流水
			sb.append(users.getBrchId()).append("|");//受理网点
			sb.append(Constants.ACPT_TYPE_GM).append("|");//受理点分类
			sb.append(users.getUserId()).append("|");//操作员/终端号
			sb.append(DateUtil.formatDate(log.getDealTime(),"yyyyMMddHHmmss")).append("|");//操作时间
			sb.append(cardNo).append("|");//卡号
			sb.append(accKind).append("|");//账户类型
			sb.append(card.getPayPwd()).append("|");//密码
			sb.append(freezeAmt).append("|");//冻结金额
			sb.append(acc.getBal()).append("|");//账户余额
			sb.append(this.getClrDate()).append("|");//批次号
			sb.append("").append("|");//终端交易流水
			sb.append("").append("|");//终端编号
			sb.append("").append("|");//冻结类型
			sb.append(log.getMessage()).append("|");//备注
			List inparam = new ArrayList();
			inparam.add(sb.toString());
			inparam.add("1");
			List<Integer> outparam = new java.util.ArrayList<Integer>();
			outparam.add(java.sql.Types.VARCHAR);
			outparam.add(java.sql.Types.VARCHAR);
			outparam.add(java.sql.Types.VARCHAR);
			List res = publicDao.callProc("pk_consume.p_accFreeze",inparam,outparam);
			if(res == null || res.size() <= 0){
				throw new CommonException("请重新进行操作");
			}
			if(Integer.parseInt(res.get(0) + "") != 0){
				throw new CommonException(res.get(1).toString());
			}
			//4.业务日志
			if(rec == null){
				rec = new TrServRec();
			}
			BasePersonal bp = new BasePersonal();
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(bp == null){
					bp = new BasePersonal();
				}
			}
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Constants.STATE_ZC);
			rec.setBrchId(users.getBrchId());
			rec.setUserId(users.getUserId());
			rec.setCardId(card.getCardId());
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setAccKind(acc.getAccKind());
			rec.setAccNo(acc.getAccNo() + "");
			rec.setPrvBal(acc.getBal());
			rec.setAmt(freezeAmt);
			rec.setNote(log.getMessage());
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCustomerName(bp.getName());
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * 账户金额解冻
	 * @param dealNo  原始冻结流水
	 * @param pwd     账户密码
	 * @param users   操作员
	 * @param rec     业务日志
	 * @param log     操作日志
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveAccUnFreeze(long dealNo,String pwd,Users users,TrServRec rec,SysActionLog log) throws CommonException{
		try{
			//1.基本条件判断
			if(Tools.processNull(dealNo).equals("")){
				throw new CommonException("原始冻结流水不能为空");
			}
			AccFreezeRec freeze = (AccFreezeRec) this.findOnlyRowByHql("from AccFreezeRec t where t.dealNo = " + dealNo);
			if(freeze == null){
				throw new CommonException("根据原始冻结流水" + dealNo + "未找到冻结记录信息");
			}
			CardBaseinfo card = new CardBaseinfo();
			if(Tools.processNull(freeze.getCardNo()).equals("")){
				card = (CardBaseinfo) this.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + freeze.getCardNo() + "'");
				if(card== null){
					card = new CardBaseinfo();
				}
			}
			//2.插入日志
			log.setDealCode(DealCode.ACC_STATE_UNFREEZE);
			log.setMessage("解冻账户冻结金额原始流水" + dealNo);
			publicDao.save(log);
			//3.业务处理
			StringBuffer sb = new StringBuffer();
			sb.append(log.getDealNo()).append("|");//操作流水
			sb.append(users.getBrchId()).append("|");//受理网点
			sb.append(Constants.ACPT_TYPE_GM).append("|");//受理点分类
			sb.append(users.getUserId()).append("|");//操作员/终端号
			sb.append(DateUtil.formatDate(log.getDealTime(),"yyyyMMddHHmmss")).append("|");//操作时间
			sb.append(dealNo).append("|");//原始冻结流水
			sb.append(Tools.processNull(pwd)).append("|");//密码
			sb.append(this.getClrDate()).append("|");//批次号
			sb.append("").append("|");//终端交易流水
			sb.append("").append("|");//终端编号
			sb.append(log.getMessage()).append("|");//备注
			sb.append("40301010").append("|");
			sb.append("40301011").append("|");
			List inparam = new ArrayList();
			inparam.add(sb.toString());
			inparam.add("1");
			List<Integer> outparam = new java.util.ArrayList<Integer>();
			outparam.add(java.sql.Types.VARCHAR);
			outparam.add(java.sql.Types.VARCHAR);
			outparam.add(java.sql.Types.VARCHAR);
			List<?> res = publicDao.callProc("pk_consume.p_accUnFreeze",inparam,outparam);
			if(res == null || res.size() <= 0){
				throw new CommonException("请重新进行操作");
			}
			if(Integer.parseInt(res.get(0) + "") != 0){
				throw new CommonException(res.get(1).toString());
			}
			//4.业务日志
			if(rec == null){
				rec = new TrServRec();
			}
			BasePersonal bp = new BasePersonal();
			if(!Tools.processNull(card.getCustomerId()).equals("")){
				bp = (BasePersonal) this.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
				if(bp == null){
					bp = new BasePersonal();
				}
			}
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Constants.STATE_ZC);
			rec.setBrchId(users.getBrchId());
			rec.setUserId(users.getUserId());
			rec.setCardId(card.getCardId());
			rec.setCardNo(card.getCardNo());
			rec.setCardType(card.getCardType());
			rec.setAccKind(freeze.getAccKind());
			rec.setAccNo(freeze.getAccNo());
			rec.setAmt(freeze.getFrzAmt());
			rec.setNote(log.getMessage());
			rec.setCustomerId(bp.getCustomerId() + "");
			rec.setCertType(bp.getCertType());
			rec.setCertNo(bp.getCertNo());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
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
		rec.setBrchId(this.getUser().getBrchId());
		rec.setUserId(this.getUser().getUserId());
		return rec;
	}
}
