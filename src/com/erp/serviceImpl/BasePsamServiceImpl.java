package com.erp.serviceImpl;

import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.BasePsam;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.BasePsamService;
import com.erp.util.DealCode;
import com.erp.util.Sys_Code;
import com.erp.util.Tools;
@Service("basePsamService")
public class BasePsamServiceImpl extends BaseServiceImpl implements BasePsamService {

	@Override
	public void saveBasePsam(BasePsam basePsam) throws CommonException {
		try {	
		
			Object  providerId= publicDao.findOnlyFieldBySql("select provider_Id from Base_Provider where provider_Name='"+basePsam.getPsamManufacturer()+"'");
			if(!Tools.processNull(providerId).equals("")){
				long proId=Long.valueOf(providerId.toString());
				basePsam.setProviderId(proId);
			}
			SysActionLog actionLog = this.getCurrentActionLog();
			actionLog.setDealCode(DealCode.BASE_PSAM);
			actionLog.setMessage("Psam卡信息保存");
			publicDao.save(actionLog);
			Users user=this.getSessionUser();	
			basePsam.setOperId(user.getUserId());
			basePsam.setOperDate(getDateBaseTime());
			basePsam.setPsamState("0");
			publicDao.save(basePsam);			
		} catch (Exception e) {
			throw new CommonException(e);
		}
		
	}

	@Override
	public void delBasePsam(String psamNo) throws CommonException {
		SysActionLog actionLog = this.getCurrentActionLog();
		actionLog.setDealCode(DealCode.BASE_PSAM);
		actionLog.setMessage("Psam卡信息删除");
		publicDao.save(actionLog);	
		publicDao.doSql("delete from Base_Pasm where psam_No='"+psamNo+"'");	
	}

	@Override
	public void updateBasePsam(BasePsam basePsam,String type) throws CommonException {
		Object  providerId= publicDao.findOnlyFieldBySql("select provider_Id from Base_Provider where provider_Name='"+basePsam.getPsamManufacturer()+"'");
		if(!Tools.processNull(providerId).equals("")){
			long proId=Long.valueOf(providerId.toString());
			basePsam.setProviderId(proId);
		}
		SysActionLog actionLog = this.getCurrentActionLog();
		actionLog.setInOutData(actionLog.getInOutData().length()>500 ? actionLog.getInOutData().substring(0, 500) + ".....":actionLog.getInOutData());
		actionLog.setDealCode(DealCode.BASE_PSAM);
		actionLog.setMessage("Psam卡信息修改");
		Users user=this.getSessionUser();
		if(Tools.processNull(type).equals("0")){
			basePsam.setOperId(user.getUserId());
			basePsam.setOperDate(getDateBaseTime());
			basePsam.setPsamState("0");
		}else if(Tools.processNull(type).equals("1")){
			basePsam.setCancleUserId(user.getUserId());
			basePsam.setCancleDate(getDateBaseTime());
			basePsam.setPsamState("1");
		}else if(Tools.processNull(type).equals("2")){
			basePsam.setReceiveUserId(user.getUserId());
			basePsam.setReceiveTime(getDateBaseTime());
			basePsam.setPsamState("2");
		}
		publicDao.save(actionLog);
		if(basePsam != null){	
			publicDao.merge(basePsam);
		}
		
	}

	@Override
	public List<BasePsam> saveBasePsam(List<BasePsam> list) {
		try {
			if (list == null || list.isEmpty()) {
				throw new CommonException("psam卡信息为空.");
			}
			
			//
			SysActionLog actionLog = this.getCurrentActionLog();
			actionLog.setDealCode(DealCode.BASE_PSAM);
			actionLog.setMessage("Psam卡信息批量新增");
			publicDao.save(actionLog);
			
			//
			List<BasePsam> failList = new ArrayList<BasePsam>();
			for (BasePsam basePsam : list) {
				try {
					if (Tools.processNull(basePsam.getPsamNo()).equals("")) {
						throw new CommonException("PSAM卡序列号为空！");
					} else if (Tools.processNull(basePsam.getPsamType()).equals("")) {
						throw new CommonException("PSAM卡类型为空！");
					}
					
					BasePsam basePsam2 = (BasePsam) findOnlyRowByHql("from BasePsam where psamNo = '" + basePsam.getPsamNo() + "'");
					if (basePsam2 != null) {
						throw new CommonException("卡序列号为[" + basePsam2.getPsamNo() + "]的psam卡已经存在.");
					}
					
					Object providerId = publicDao.findOnlyFieldBySql("select provider_Id from Base_Provider where provider_Name='" + basePsam.getPsamManufacturer() + "'");
					if (!Tools.processNull(providerId).equals("")) {
						long proId = Long.valueOf(providerId.toString());
						basePsam.setProviderId(proId);
					}

					Users user = this.getSessionUser();
					basePsam.setOperId(user.getUserId());
					basePsam.setOperDate(getDateBaseTime());
					basePsam.setPsamState("0");
					publicDao.save(basePsam);
				} catch (Exception e) {
					basePsam.setNote(e.getMessage());
					failList.add(basePsam);
				}
			}
			
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
			throw new CommonException(e.getMessage());
		}
	}
}
