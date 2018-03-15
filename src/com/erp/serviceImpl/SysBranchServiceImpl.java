package com.erp.serviceImpl;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.dao.PublicDao;
import com.erp.exception.CommonException;
import com.erp.model.SysBranch;
import com.erp.model.SysActionLog;
import com.erp.service.AccAcountService;
import com.erp.service.SysBranchService;
import com.erp.util.Constants;
import com.erp.util.Err_Code;
import com.erp.util.Sys_Code;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.TreeModel;

@Service("SysBranchService")
@SuppressWarnings("unchecked")
public class SysBranchServiceImpl extends BaseServiceImpl implements SysBranchService
{
	public AccAcountService accACountService;
	
	@Autowired
	public void setAccACountService(AccAcountService accACountService) {
		this.accACountService = accACountService;
	}
	
	public List<TreeModel> findSysBranchList()
	{
		String hql="from SysBranch o where o.status='A'";
		List<SysBranch> tempList = publicDao.find(hql);
		List<TreeModel> list=new ArrayList<TreeModel>();
		for (SysBranch o : tempList)
		{
			TreeModel treeModel=new TreeModel();
			treeModel.setId(o.getSysBranchId()+Constants.NULL_STRING);
			treeModel.setPid(o.getPid()==null?null:o.getPid().toString());
			treeModel.setName(o.getFullName());
			treeModel.setState(Constants.TREE_STATUS_OPEN);
			treeModel.setIconCls(o.getIconCls());
			list.add(treeModel);
		}
		return list;
	}
	public List<SysBranch> findSysBranchList(Integer id){
		String hql = "from SysBranch o where o.status = 'A' ";
		if (null == id || "".equals(id)){
			hql += " and o.pid is null";
		}else {
			hql += " and o.pid = " + id;
		}
		return publicDao.find(hql);
	}
	
	public boolean persistenceSysBranch(SysBranch o,List<String> bankIds ) throws CommonException{
		try{
			Integer userId = Constants.getCurrendUser().getUserId();
			if (null == o.getSysBranchId() || "".equals(o.getSysBranchId())){
				o.setCreated(new Date());
				o.setLastmod(new Date());
				o.setCreater(userId);
				o.setModifyer(userId);
				o.setStatus(Constants.PERSISTENCE_STATUS);
				publicDao.save(o);
			}else{
				o.setLastmod(new Date());
				o.setModifyer(userId);
				publicDao.update(o);
				//对应的操作员表中的网点名称也要一起修改
				List list= (List)publicDao.findBySQL("select * from SYS_USERS s where s.brch_id='"+o.getBrchId()+"'");
				if(list!=null && list.size()>0){
					publicDao.doSql("update SYS_USERS s set s.brch_name='"+o.getFullName()+"' where s.brch_id='"+o.getBrchId()+"'");
				}

			}
			if(bankIds != null && bankIds.size() > 0){
				publicDao.doSql("delete from branch_bank where brch_id = '" + o.getBrchId() + "'");
				if(!Tools.processNull(bankIds.get(0)).equals("")){
					for (String bankId : bankIds) {
						String sql = "insert into branch_bank values('" + o.getBrchId() + "','" + bankId + "','" + Constants.STATE_ZC + "')";
						publicDao.doSql(sql);
					}
				}
			}
			return true;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	
	@SuppressWarnings("rawtypes")
	public boolean delSysBranch(Integer id){
		String hql = "from SysBranch o where o.status = 'A' and o.pid = " + id;
		List<SysBranch> list = publicDao.find(hql);
		if (list.size() != 0){
			return false;
		}else{
			String brch_id = (String)publicDao.findOnlyFieldBySql("select brch_id from sys_branch t where t.SysBranch_ID = '" + id + "'");
			String hql2 = "from Users t where t.brchId = " + brch_id;
			List list2 = publicDao.find(hql2);
			if (list2.size() != 0){
				return false;
			}else {
				SysBranch o = (SysBranch)publicDao.get(SysBranch.class, id);
				o.setStatus(Constants.PERSISTENCE_DELETE_STATUS);
				o.setLastmod(new Date());
				o.setModifyer(Constants.getCurrendUser().getUserId());
				publicDao.deleteToUpdate(o);
			}
			return true;
		}
	}
	@Override
	public void saveopenBranchAcc(SysActionLog actionLog,
			SysBranch branch) throws CommonException {
		try {
			if(!actionLog.getDealCode().equals(DealCode.BRCH_ADD)){
				//记录系统日志
				publicDao.save(actionLog);
				//综合业务记录 Tr_Serv_Rec_年份
				this.saveTrServRec(actionLog);
			}
			//判断是否注销
			if(branch.getStatus().equals("I")){
				throw new CommonException(Err_Code.ALREADY_CANCELED_BRCH_CANT_OPEN_ACC,branch.getFullName());
			}
			HashMap<String, String> hm = new HashMap<String, String>();
			hm.put("obj_type", Sys_Code.CLIENT_TYPE_WD);
			hm.put("sub_type", branch.getBrchType());
			hm.put("pwd", null);
			hm.put("obj_id", branch.getBrchId());
			accACountService.createAccount(actionLog, hm);
			
		} catch (Exception e) {
			throw new CommonException(e);
		}
		
	}

	/* 
	 * @see com.erp.service.SysBranchService#saveBranchBank(com.erp.model.SysBranch, java.util.List)
	 */
	@Override
	public void saveBranchBank(SysBranch brch, List<String> bankIds) {
		try {
			if (brch == null || brch.getBrchId() == null) {
				throw new CommonException("网点信息为空.");
			} else if (bankIds == null || bankIds.isEmpty()) {
				throw new CommonException("银行信息为空.");
			}
			
			publicDao.doSql("delete from branch_bank where brch_id = '" + brch.getBrchId() + "'");
			
			for (String bankId : bankIds) {
				String sql = "insert into branch_bank values('"
						+ brch.getBrchId() + "','" + bankId + "','"
						+ Constants.STATE_ZC + "')";

				publicDao.doSql(sql);
			}
		} catch (Exception e) {
			throw new CommonException("保存网点银行信息为空.");
		}
	}
}
