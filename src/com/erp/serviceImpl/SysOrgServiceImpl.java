package com.erp.serviceImpl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.erp.util.DateUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.SysOrgan;
import com.erp.model.TrServRec;
import com.erp.service.AccAcountService;
import com.erp.service.SysOrgService;
import com.erp.util.Constants;
import com.erp.util.Err_Code;
import com.erp.util.Sys_Code;
import com.erp.util.Tools;
import com.erp.util.DealCode;
import com.erp.viewModel.TreeModel;

@Service("sysOrgService")
public class SysOrgServiceImpl extends BaseServiceImpl implements SysOrgService{
	
	public AccAcountService accACountService;
	
	@Autowired
	public void setAccACountService(AccAcountService accACountService) {
		this.accACountService = accACountService;
	}

	public List<SysOrgan> findOrganList(Map<String, Object> map) {
		String hql="from SysOrgan u where 1=1 and u.orgState='0' ";
		if(map.get("orgId")!=null){
			hql+=" and orgId='"+map.get("orgId")+"'";
		}
		if(map.get("orgName")!=null){
			hql+=" and orgName='"+map.get("orgName")+"'";
		}
		//hql+=Constants.getSearchConditionsHQL("u", map);
		if(map.get("sortName")!=null){
			hql+=" order by "+map.get("sortName")+" "+ map.get("orderBy");
			map.remove("sortName");
			map.remove("orderBy");
		}
		List<SysOrgan> list = publicDao.find(hql);
		return list;
	}

	public List<SysOrgan> findOrganListByClientId(Integer id) {
		String hql="from SysOrgan o where o.orgState='0' ";
		if (null==id||"".equals(id))
		{
			hql+=" and o.orgId ='"+id+"'";
		}
		return publicDao.find(hql);
	}

	public boolean persistenceSysOrgan(SysOrgan o) {
		Integer userId = Constants.getCurrendUser().getUserId();
		SysActionLog actionLog =this.getCurrentActionLog();
		actionLog.setUserId(Constants.getCurrendUser().getAccount().toString());
		actionLog.setDealTime(publicDao.getDateBaseTime());
		if (null==o.getCustomerId()||"".equals(o.getCustomerId()))
		{
			o.setOpenDate(DateUtil.formatDate(publicDao.getDateBaseDate(), "yyyy-mm-dd"));
			o.setOpenOperId(userId.toString());
			o.setOrgState("0");
			publicDao.save(o);
			actionLog.setDealCode(DealCode.ORG_ADD);
			actionLog.setNote("组织机构新增");
		}else {
			actionLog.setDealCode(DealCode.ORG_EDIT);
			actionLog.setNote("组织机构修改");
			publicDao.update(o);
		}
		publicDao.save(actionLog);
		return true;
	}

	public boolean savezxSys_OrganByOrgan(SysActionLog actionLog,String  orgId ) throws CommonException{
		boolean ret = true;
		try{
			SysOrgan org = (SysOrgan)this.findOnlyRowByHql("from SysOrgan where orgId='"+orgId+"'");
			if(!Tools.processNull(actionLog.getDealCode()).equals(DealCode.ORG_EDIT)){//不是机构编辑则记录系统日志
				//登记日志
				publicDao.save(actionLog);
				//综合业务记录 Tr_Serv_Rec_年份
				saveTrServRec(actionLog,org);
			}
			if(orgId!=null){
				//判断是否已经注销
				List<SysOrgan> list = this.findByHql("from SysOrgan where orgId='"+orgId+"' and org_State='I'");
				if(list!=null && list.size()>0){
					throw new CommonException(Err_Code.ALREADY_CANCELED_ORG,list.get(0).getOrgName());
				}
				SysOrgan organ  = (SysOrgan)this.findOnlyRowByHql("from SysOrgan where orgId='"+orgId+"'");
				
				//注销机构所属网点和柜员信息
				
				publicDao.doSql("update sys_users t set t.status='I',t.lastmod=" +"to_date('"+
						DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")+"','yyyy-mm-dd hh24:mi:ss')," +
							"t.MODIFYER='"+actionLog.getUserId() + "' where t.org_Id='"+orgId+"'");
				//注销与此机构有关的账户信息级联更新					
				publicDao.doSql("update acc_account_sub t set t.acc_state='"+Sys_Code.ACC_STATE_ZX+
						"' ,t.cls_date= to_date('" + DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss") +
						"','yyyy-MM-dd hh24:mi:ss') ,t.CLS_USER_ID='"+ actionLog.getUserId() +"' where t.customer_id='"+organ.getCustomerId()+"'");
				//注销机构
				publicDao.doSql("update sys_organ o set o.org_state='"+Sys_Code.STATE_ZX+"',o.cls_Date=to_date('"+
						DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd hh:mm:ss")+"','yyyy-mm-dd hh24:mi:ss'),o.cls_oper_id='"+
						actionLog.getUserId() + "'  where  o.customer_id='"+organ.getCustomerId()+"'");
				}
		}catch(Exception e){
			throw new CommonException(e);
		}
		return ret;
	}

	public List<TreeModel> findAllSysOrgan() {
		String hql="from SysOrgan o where o.orgState='0'";
		List<SysOrgan> tempList = publicDao.find(hql);
		List<TreeModel> list=new ArrayList<TreeModel>();
		for (SysOrgan o : tempList)
		{
			TreeModel treeModel=new TreeModel();
			treeModel.setId(o.getOrgId()+Constants.NULL_STRING);
			treeModel.setPid(o.getParentOrgId()==null?null:o.getParentOrgId().toString());
			treeModel.setName(o.getOrgName());
			treeModel.setState(Constants.TREE_STATUS_OPEN);
			list.add(treeModel);
		}
		return list;
	}

	

	@Override
	public void saveOpenOrgAcc(List<SysOrgan> orges, SysActionLog actionLog)
			throws CommonException {
		try {
			if(!actionLog.getDealCode().equals(DealCode.ORG_ADD)){
				//记录系统日志
				publicDao.save(actionLog);
				//综合业务记录 Tr_Serv_Rec_年份
				this.saveTrServRec(actionLog);
			}
			for (SysOrgan org : orges) {
				//判断是否注销
				if(org.getOrgState().equals(Sys_Code.STATE_ZX)){
					throw new CommonException(Err_Code.ALREADY_CANCELED_ORG_CANT_OPEN_ACC,org.getOrgName());
				}
				// 开户
				HashMap<String, String> hm = new HashMap<String, String>();
				hm.put("obj_type", Sys_Code.CLIENT_TYPE_JG);
				hm.put("sub_type", org.getOrgType());
				//hm.put("pwd", null);
				hm.put("obj_id", org.getCustomerId()+"");
				accACountService.createAccount(actionLog, hm);
			}
		} catch (Exception e) {
			throw new CommonException(e);
		}
		
	}

	public void saveTrServRec(SysActionLog actionLog,SysOrgan org) throws CommonException {
		try {
			TrServRec serv = new TrServRec();
			serv.setDealNo(actionLog.getDealNo());//业务流水号
			serv.setCustomerId(org.getCustomerId()+"");
			serv.setDealCode(actionLog.getDealCode());//交易代码
			serv.setBizTime(actionLog.getDealTime());//业务办理时间
			serv.setUserId(actionLog.getUserId());//办理操作员编号
			serv.setBrchId(actionLog.getBrchId());//办理柜员所在网点
			serv.setClrDate(this.getClrDate());//清分日期
			serv.setCustomerId(org.getCustomerId()+"");
			serv.setNote(actionLog.getMessage());//note字段
			serv.setDealState(Sys_Code.TR_STATE_ZC);//业务状态0正常1撤销)
			publicDao.save(serv);
		} catch (Exception e) {
			throw new CommonException("保存业务日志出错，请稍后再试！"+e.getMessage());
		}
	}
	
	

}
