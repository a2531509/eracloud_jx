package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.BaseCoOrg;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.BaseService;
import com.erp.service.CooperationAgencyService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.Tools;

@Service("cooperationAgencyService")
public class CooperationAgencyServiceImpl extends BaseServiceImpl implements CooperationAgencyService {
	/**
	 * 新增或是编辑保存合作机构
	 * @param co
	 * @param users
	 * @param log
	 * @param type
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	@Override
	public TrServRec saveOrUpdateBaseCoOrg(BaseCoOrg co,Users users,SysActionLog log,String type,String safeCode,String ipAddress,String portAddress) throws CommonException {
		try{
			//1.基本条件判断
			String string = "";
			Integer tempdealcode = 0;
			if(Tools.processNull(type).equals("0")){
				string = "新增";
				tempdealcode = DealCode.CO_ORG_MANAGER_ADD;
			}else if(Tools.processNull(type).equals("1")){
				string = "编辑";
				tempdealcode = DealCode.CO_ORG_MANAGER_EDIT;
			}else{
				throw new CommonException("传入操作类型错误！");
			}
			if(co == null){
				throw new CommonException(string + "传入合作机构不能为空！");
			}
			/*if(Tools.processNull(co.getCoOrgId()).equals("")){
				throw new CommonException(st
				ring + "合作机构编号不能为空！");
			}*/
			
			if(Tools.processNull(co.getCoOrgName()).equals("")){
				throw new CommonException(string + "合作机构名称不能为空！");
			}
			if(Tools.processNull(co.getCoAbbrName()).equals("")){
				throw new CommonException(string + "合作机构简称不能为空！");
			}
			if(Tools.processNull(co.getCoOrgType()).equals("")){
				throw new CommonException(string + "合作机构类型不能为空！");
			}
			if(Tools.processNull(co.getCheckType()).equals("")){
				throw new CommonException(string + "合作机构对账主体不能为空！");
			}
			if(Tools.processNull(co.getContactNo()).equals("")){
				throw new CommonException(string + "合作机构签约合同编号不能为空！");
			}
			if(Tools.processNull(co.getCheckType()).equals("")){
				throw new CommonException(string + "合作机构签约合同类型不能为空！");
			}
			//2.插入操作日志
			log.setDealCode(tempdealcode);
			log.setMessage(string + "合作机构");
			publicDao.save(log);
			//3.业务逻辑处理
			
		
			
			//验证上级合作机构
			if(!Tools.processNull(co.getTopCoOrgId()).equals("")){
				BaseCoOrg topcoorg = (BaseCoOrg) this.findOnlyRowByHql("from BaseCoOrg t where t.coOrgId = '" + co.getTopCoOrgId() + "'" );
				if(topcoorg == null){
					throw new CommonException("上级合作机构编号不正确，根据上级合作机构编号【" + co.getTopCoOrgId() + "】未找到合作机构信息！");
				}
				co.setOrgId(topcoorg.getOrgId());//如果选择上级合作机构，则运营机构应该是相同的
			}
			if(Tools.processNull(type).equals("0")){
				//构建合作机构编号信息
				String newcoorgid = co.getOrgId() + co.getCoOrgType() +  publicDao.findOnlyFieldBySql("select lpad(SEQ_BIZ_ID.nextval,9,'0') from dual").toString();
				co.setCoOrgId(newcoorgid);
				//避免重复验证合作机构编号是否已经存在
				BaseCoOrg tempBaseCoOrg = (BaseCoOrg) this.findOnlyRowByHql("from BaseCoOrg t where t.coOrgId = '" + co.getCoOrgId() + "'");
				if(tempBaseCoOrg != null){
					throw new CommonException("相同合作机构编号或是合作机构名称已经存在，不同重复进行登记！");
				}
				
				
				co.setCoState("2");//待审核
				co.setSignDate(log.getDealTime());
				co.setSignUserId(users.getUserId());
				co.setServPwd(this.encrypt_des("000000", Constants.APP_DES3_DEFAULT));
				publicDao.save(co);
				//是否下发安全码
				if(Tools.processNull(safeCode).equals("01")){
					publicDao.doSql("insert into merchant_safecode(merchant_id,ip,port) values" + "(" + newcoorgid + ", '" + ipAddress + "' ," + portAddress +")");
				}
				}else if(Tools.processNull(type).equals("1")){
				if(Tools.processNull(co.getCustomerId()).equals("")){
					throw new CommonException(string + "合作机构传入合作机构唯一标识不能为空！");
				}
				BaseCoOrg tempBaseCoOrg = (BaseCoOrg) this.findOnlyRowByHql("from BaseCoOrg t where (t.coOrgId = '" + co.getCoOrgId() + "' or t.coOrgName = '" + co.getCoOrgName() + "') and t.customerId <> " + co.getCustomerId());
				if(tempBaseCoOrg != null){
					throw new CommonException("相同合作机构编号或是合作机构名称已经存在，不同重复进行编辑！");
				}
				BaseCoOrg oldCoOrg = (BaseCoOrg) this.findOnlyRowByHql("from BaseCoOrg t where t.customerId = " + co.getCustomerId());
				if(oldCoOrg == null){
					throw new CommonException("根据合作机构标识" + co.getCustomerId() + "未找到合作机构信息，不能进行编辑！");
				}
				//合作机构基本信息
				//oldCoOrg.setCoOrgId(co.getCoOrgId());//合作机构编号 自动生成
				oldCoOrg.setCoOrgName(co.getCoOrgName());//合作机构名称
				oldCoOrg.setCoAbbrName(co.getCoAbbrName());//合作机构简称
				oldCoOrg.setOrgId(co.getOrgId());//运营机构
				
				oldCoOrg.setCoOrgType(co.getCoOrgType());//合作机构类型
				oldCoOrg.setTopCoOrgId(co.getTopCoOrgId());//上级合作机构
				oldCoOrg.setCheckType(co.getCheckType());//对账主体
				oldCoOrg.setIndusCode(co.getIndusCode());//所属行业
				oldCoOrg.setStlType(co.getStlType());//结算方式
				oldCoOrg.setPostCode(co.getPostCode());//邮政编码
				oldCoOrg.setAddress(co.getAddress());//合作机构地址
				oldCoOrg.setHotline(co.getHotline());//咨询热线
				//联系人信息
				oldCoOrg.setContact(co.getContact());//联系人
				oldCoOrg.setConCertNo(co.getConCertNo());//联系人证件号码
				oldCoOrg.setConCertType(co.getConCertType());//联系人证件类型
				oldCoOrg.setConPhone(co.getConPhone());//联系人电话
				//法人信息
				oldCoOrg.setLegName(co.getLegName());//法人姓名
				oldCoOrg.setLegPhone(co.getLegPhone());//法人联系方式
				oldCoOrg.setLegCertType(co.getLegCertType());//法人证件类型
				oldCoOrg.setLegCertNo(co.getLegCertNo());//法人证件类型
				oldCoOrg.setPhoneNo(co.getPhoneNo());//法人联系电话
				oldCoOrg.setFaxNum(co.getFaxNum());//法人传真
				oldCoOrg.setEmail(co.getEmail());//法人邮箱
				//税务登记信息
				oldCoOrg.setTaxRegNo(co.getTaxRegNo());//税务登记号
				oldCoOrg.setBizRegNo(co.getBizRegNo());//工商注册号
				oldCoOrg.setBankId(co.getBankId());//开户银行
				oldCoOrg.setBankAccName(co.getBankAccName());//开户银行名称
				oldCoOrg.setBankAccNo(co.getBankAccNo());//银行账号
				oldCoOrg.setBankBrch(co.getBankBrch());//开户网点
				oldCoOrg.setContactNo(co.getContactNo());//签约合同编号
				oldCoOrg.setContactType(co.getContactType());//签约合同类型
				//签约柜员信息
				oldCoOrg.setSignUserId(users.getUserId());//登记注册柜员
				//oldCoOrg.setSignDate(log.getDealTime());
				oldCoOrg.setNote(co.getNote()); //备注
				if(Tools.processNull(oldCoOrg.getCoState()).equals("9")){
					oldCoOrg.setCoState("2");
					//如果是审核不通过则在编辑时修改为待审核状态，否则维持原始状态
				}
				//oldCoOrg.setCoState(co.getco);
				publicDao.update(oldCoOrg);
				//是否下发安全码
				if(Tools.processNull(safeCode).equals("01")){
					publicDao.doSql("insert into merchant_safecode(merchant_id,ip,port) values" + "(" + oldCoOrg.getCoOrgId() + ", '" + ipAddress + "' ," + portAddress + ")");
				}else if(Tools.processNull(safeCode).equals("02")){
					publicDao.doSql("delete from merchant_safecode where merchant_id = " + oldCoOrg.getCoOrgId());
				}
			}else{
				throw new CommonException("合作机构操作类型错误！");
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setBrchId(users.getBrchId());
			rec.setUserId(users.getUserId());
			rec.setClrDate(this.getClrDate());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	
	
	@Override
	public TrServRec saveOrUpdateBaseCoOrg(BaseCoOrg co,Users users,SysActionLog log,String type,String safeCode) throws CommonException {
		try{
			//1.基本条件判断
			String string = "";
			Integer tempdealcode = 0;
			if(Tools.processNull(type).equals("0")){
				string = "新增";
				tempdealcode = DealCode.CO_ORG_MANAGER_ADD;
			}else if(Tools.processNull(type).equals("1")){
				string = "编辑";
				tempdealcode = DealCode.CO_ORG_MANAGER_EDIT;
			}else{
				throw new CommonException("传入操作类型错误！");
			}
			if(co == null){
				throw new CommonException(string + "传入合作机构不能为空！");
			}
			/*if(Tools.processNull(co.getCoOrgId()).equals("")){
				throw new CommonException(st
				ring + "合作机构编号不能为空！");
			}*/
			
			if(Tools.processNull(co.getCoOrgName()).equals("")){
				throw new CommonException(string + "合作机构名称不能为空！");
			}
			if(Tools.processNull(co.getCoAbbrName()).equals("")){
				throw new CommonException(string + "合作机构简称不能为空！");
			}
			if(Tools.processNull(co.getCoOrgType()).equals("")){
				throw new CommonException(string + "合作机构类型不能为空！");
			}
			if(Tools.processNull(co.getCheckType()).equals("")){
				throw new CommonException(string + "合作机构对账主体不能为空！");
			}
			if(Tools.processNull(co.getContactNo()).equals("")){
				throw new CommonException(string + "合作机构签约合同编号不能为空！");
			}
			if(Tools.processNull(co.getCheckType()).equals("")){
				throw new CommonException(string + "合作机构签约合同类型不能为空！");
			}
			//2.插入操作日志
			log.setDealCode(tempdealcode);
			log.setMessage(string + "合作机构");
			publicDao.save(log);
			//3.业务逻辑处理
			
		
			
			//验证上级合作机构
			if(!Tools.processNull(co.getTopCoOrgId()).equals("")){
				BaseCoOrg topcoorg = (BaseCoOrg) this.findOnlyRowByHql("from BaseCoOrg t where t.coOrgId = '" + co.getTopCoOrgId() + "'" );
				if(topcoorg == null){
					throw new CommonException("上级合作机构编号不正确，根据上级合作机构编号【" + co.getTopCoOrgId() + "】未找到合作机构信息！");
				}
				co.setOrgId(topcoorg.getOrgId());//如果选择上级合作机构，则运营机构应该是相同的
			}
			if(Tools.processNull(type).equals("0")){
				//构建合作机构编号信息
				String newcoorgid = co.getOrgId() + co.getCoOrgType() +  publicDao.findOnlyFieldBySql("select lpad(SEQ_BIZ_ID.nextval,9,'0') from dual").toString();
				co.setCoOrgId(newcoorgid);
				//避免重复验证合作机构编号是否已经存在
				BaseCoOrg tempBaseCoOrg = (BaseCoOrg) this.findOnlyRowByHql("from BaseCoOrg t where t.coOrgId = '" + co.getCoOrgId() + "'");
				if(tempBaseCoOrg != null){
					throw new CommonException("相同合作机构编号或是合作机构名称已经存在，不同重复进行登记！");
				}
				
				
				co.setCoState("2");//待审核
				co.setSignDate(log.getDealTime());
				co.setSignUserId(users.getUserId());
				co.setServPwd(this.encrypt_des("000000", Constants.APP_DES3_DEFAULT));
				publicDao.save(co);
				//是否下发安全码
				/*if(Tools.processNull(safeCode).equals("01")){
					publicDao.doSql("insert into merchant_safecode(merchant_id) values" + "(" + newcoorgid + ")");
				}*/
			}else if(Tools.processNull(type).equals("1")){
				if(Tools.processNull(co.getCustomerId()).equals("")){
					throw new CommonException(string + "合作机构传入合作机构唯一标识不能为空！");
				}
				BaseCoOrg tempBaseCoOrg = (BaseCoOrg) this.findOnlyRowByHql("from BaseCoOrg t where (t.coOrgId = '" + co.getCoOrgId() + "' or t.coOrgName = '" + co.getCoOrgName() + "') and t.customerId <> " + co.getCustomerId());
				if(tempBaseCoOrg != null){
					throw new CommonException("相同合作机构编号或是合作机构名称已经存在，不同重复进行编辑！");
				}
				BaseCoOrg oldCoOrg = (BaseCoOrg) this.findOnlyRowByHql("from BaseCoOrg t where t.customerId = " + co.getCustomerId());
				if(oldCoOrg == null){
					throw new CommonException("根据合作机构标识" + co.getCustomerId() + "未找到合作机构信息，不能进行编辑！");
				}
				//合作机构基本信息
				//oldCoOrg.setCoOrgId(co.getCoOrgId());//合作机构编号 自动生成
				oldCoOrg.setCoOrgName(co.getCoOrgName());//合作机构名称
				oldCoOrg.setCoAbbrName(co.getCoAbbrName());//合作机构简称
				oldCoOrg.setOrgId(co.getOrgId());//运营机构
				
				oldCoOrg.setCoOrgType(co.getCoOrgType());//合作机构类型
				oldCoOrg.setTopCoOrgId(co.getTopCoOrgId());//上级合作机构
				oldCoOrg.setCheckType(co.getCheckType());//对账主体
				oldCoOrg.setIndusCode(co.getIndusCode());//所属行业
				oldCoOrg.setStlType(co.getStlType());//结算方式
				oldCoOrg.setPostCode(co.getPostCode());//邮政编码
				oldCoOrg.setAddress(co.getAddress());//合作机构地址
				oldCoOrg.setHotline(co.getHotline());//咨询热线
				//联系人信息
				oldCoOrg.setContact(co.getContact());//联系人
				oldCoOrg.setConCertNo(co.getConCertNo());//联系人证件号码
				oldCoOrg.setConCertType(co.getConCertType());//联系人证件类型
				oldCoOrg.setConPhone(co.getConPhone());//联系人电话
				//法人信息
				oldCoOrg.setLegName(co.getLegName());//法人姓名
				oldCoOrg.setLegPhone(co.getLegPhone());//法人联系方式
				oldCoOrg.setLegCertType(co.getLegCertType());//法人证件类型
				oldCoOrg.setLegCertNo(co.getLegCertNo());//法人证件类型
				oldCoOrg.setPhoneNo(co.getPhoneNo());//法人联系电话
				oldCoOrg.setFaxNum(co.getFaxNum());//法人传真
				oldCoOrg.setEmail(co.getEmail());//法人邮箱
				//税务登记信息
				oldCoOrg.setTaxRegNo(co.getTaxRegNo());//税务登记号
				oldCoOrg.setBizRegNo(co.getBizRegNo());//工商注册号
				oldCoOrg.setBankId(co.getBankId());//开户银行
				oldCoOrg.setBankAccName(co.getBankAccName());//开户银行名称
				oldCoOrg.setBankAccNo(co.getBankAccNo());//银行账号
				oldCoOrg.setBankBrch(co.getBankBrch());//开户网点
				oldCoOrg.setContactNo(co.getContactNo());//签约合同编号
				oldCoOrg.setContactType(co.getContactType());//签约合同类型
				//签约柜员信息
				oldCoOrg.setSignUserId(users.getUserId());//登记注册柜员
				//oldCoOrg.setSignDate(log.getDealTime());
				oldCoOrg.setNote(co.getNote()); //备注
				if(Tools.processNull(oldCoOrg.getCoState()).equals("9")){
					oldCoOrg.setCoState("2");
					//如果是审核不通过则在编辑时修改为待审核状态，否则维持原始状态
				}
				//oldCoOrg.setCoState(co.getco);
				publicDao.update(oldCoOrg);
				//是否下发安全码
				/*if(Tools.processNull(safeCode).equals("01")){
					publicDao.doSql("insert into merchant_safecode(merchant_id) values" + "(" + oldCoOrg.getCoOrgId() + ")");
				}else*/ 
				if(Tools.processNull(safeCode).equals("02")){
					publicDao.doSql("delete from merchant_safecode where merchant_id = " + oldCoOrg.getCoOrgId());
				}
			}else{
				throw new CommonException("合作机构操作类型错误！");
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setBrchId(users.getBrchId());
			rec.setUserId(users.getUserId());
			rec.setClrDate(this.getClrDate());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	
	/**
	 * 合作机构状态管理
	 * @param customerId  合作机构标识符
	 * @param users       操作柜员
	 * @param log         操作日志
	 * @param type        操作类型  0-审批通过，1-注销（退网）， 3 启用    9 审核不通过
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveDealBaseCoOrg(Long customerId,Users users,SysActionLog log,String type) throws CommonException{
		try{
			//1.基本条件判断
			String string = "";
			Integer tempdealcode = 0;
			String state = "-1";
			if(Tools.processNull(type).equals("0")){
				string = "审核通过";
				tempdealcode = DealCode.CO_ORG_MANAGER_PASS;
				state = "0";
			}else if(Tools.processNull(type).equals("1")){
				string = "注销";
				tempdealcode = DealCode.CO_ORG_MANAGER_ZX;
				state = "1";
			}else if(Tools.processNull(type).equals("3")){
				string = "启用";
				tempdealcode = DealCode.CO_ORG_MANAGER_QY;
				state = "0";
			}else if(Tools.processNull(type).equals("9")){
				string = "审核不通过";
				tempdealcode = DealCode.CO_ORG_MANAGER_NOPASS;
				state = "9";
			}else{
				throw new CommonException("传入操作类型错误！");
			}
			BaseCoOrg coorg = (BaseCoOrg) this.findOnlyRowByHql("from BaseCoOrg t where t.customerId = '" + customerId + "'");
			if(coorg == null){
				throw new CommonException(string + "合作机构发生错误：合作机构信息不存在，唯一标识符【" + customerId + "】");
			}
			//2.记录操作日志
			log.setDealCode(tempdealcode);
			log.setMessage(string + "合作机构,合作机构编号" + coorg.getCoOrgId());
			publicDao.save(log);
			//3.业务处理
			if(type.equals(coorg.getCoState())){
				throw new CommonException(string + "合作机构发生错误：该合作机构已经【" + string + "】无需重复进行操作！");
			}
			if(type.equals("0")){
				if(!Tools.processNull(coorg.getCoState()).equals("2") && !Tools.processSpace(coorg.getCoState()).equals("9")){
					throw new CommonException(string + "合作机构发生错误：该合作机构不是【待审核】或【审核不通过】状态！");
				}
			}
			if(type.equals("3")){
				if(Tools.processNull(coorg.getCoState()).equals("0")){
					throw new CommonException(string + "合作机构发生错误：该合作机构已是【正常】状态，无需重复进行启用！");
				}
				if(Tools.processNull(coorg.getCoState()).equals("2")){
					throw new CommonException(string + "合作机构发生错误：该合作机构当前处于【待审核】状态，不能直接进行启用！");
				}
				if(Tools.processNull(coorg.getCoState()).equals("9")){
					throw new CommonException(string + "合作机构发生错误：该合作机构已【审核不通过】，不能进行启用！");
				}
				if(!Tools.processNull(coorg.getCoState()).equals("1")){
					throw new CommonException(string + "合作机构发生错误：该合作机构不是【注销】状态，无法进行重新进行启用！");
				}
			}
			if(type.equals("9") && !Tools.processNull(coorg.getCoState()).equals("2")){
				throw new CommonException(string + "合作机构发生错误：该合作机构不是【待审核】状态，不能进行审核不通过！");
			}
			int c = publicDao.doSql("update Base_Co_Org t set t.co_state = '" + state + "' where t.customer_id = '" + customerId + "'");
			if(c != 1){
				throw new CommonException(string + "合作机构发生错误：根据合作机构唯一标识符【" + customerId + "】更新" + c + "行 ！");
			}
			//如果是审核通过则需要建帐户
			if(type.equals("0")){
				StringBuffer sb = new StringBuffer();
				sb.append(log.getDealNo() + "|");
				sb.append(log.getDealCode() + "|");
				sb.append(users.getUserId() + "|");
				sb.append(DateUtil.formatDate(log.getDealTime(),"yyyyMMddHHmmdd") + "|");
				sb.append(Constants.MAIN_TYPE_HZJG + "|");//合作机构 主体类型为5
				sb.append("" + "|");
				sb.append(customerId + "|");
				sb.append("" + "|");
				sb.append("" + "|");
				List inParamList = new ArrayList();
				inParamList.add(sb.toString());
				List outParamList = new ArrayList();
				outParamList.add(java.sql.Types.VARCHAR);
				outParamList.add(java.sql.Types.VARCHAR);
				List outs = publicDao.callProc("pk_business.p_createaccount", inParamList, outParamList);
				if(outs == null || outs.size() <= 0){
					throw new CommonException(string + "发生错误：创建账户信息失败！");
				}
				if(Integer.valueOf(outs.get(0).toString()) != 0){
					throw new CommonException(string + "发生错误：创建账户信息失败，" + outs.get(1) + "！");
				}
			}else if(type.equals("1")){
				publicDao.doSql("update acc_account_sub t set t.acc_state = '" + Constants.ACC_STATE_ZX + "' where t.customer_id = '" + customerId + "' ");
			}else if(type.equals("3")){
				if(((BigDecimal) this.findOnlyFieldBySql("select count(1) from ACC_ACCOUNT_SUB t where t.customer_id = '" + customerId + "'")).intValue() <= 0){
					StringBuffer sb = new StringBuffer();
					sb.append(log.getDealNo() + "|");
					sb.append(log.getDealCode() + "|");
					sb.append(users.getUserId() + "|");
					sb.append(DateUtil.formatDate(log.getDealTime(),"yyyyMMddHHmmdd") + "|");
					sb.append(Constants.MAIN_TYPE_HZJG + "|");//合作机构 主体类型为5
					sb.append("" + "|");
					sb.append(customerId + "|");
					sb.append("" + "|");
					sb.append("" + "|");
					List inParamList = new ArrayList();
					inParamList.add(sb.toString());
					List outParamList = new ArrayList();
					outParamList.add(java.sql.Types.VARCHAR);
					outParamList.add(java.sql.Types.VARCHAR);
					List outs = publicDao.callProc("pk_business.p_createaccount", inParamList, outParamList);
					if(outs == null || outs.size() <= 0){
						throw new CommonException(string + "发生错误：创建账户信息失败！");
					}
					if(Integer.valueOf(outs.get(0).toString()) != 0){
						throw new CommonException(string + "发生错误：创建账户信息失败，" + outs.get(1) + "！");
					}
				}else{
					publicDao.doSql("update acc_account_sub t set t.acc_state = '" + Constants.ACC_STATE_ZC +"' where t.customer_id = '" + customerId + "' ");
				}
			}
			//4.业务日志信息
			TrServRec rec = new TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBizTime(log.getDealTime());
			rec.setDealState(Constants.TR_STATE_ZC);
			rec.setBrchId(users.getBrchId());
			rec.setUserId(users.getUserId());
			rec.setClrDate(this.getClrDate());
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
}
