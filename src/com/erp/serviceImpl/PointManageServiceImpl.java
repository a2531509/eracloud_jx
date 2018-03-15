package com.erp.serviceImpl;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.PointsRule;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.PointManageService;
import com.erp.util.DealCode;
import com.erp.util.Tools;


@Service("pointManageService")
@SuppressWarnings("unchecked")
public class PointManageServiceImpl extends BaseServiceImpl implements PointManageService {

	@Override
	public void saveOrUpdatePointPara(SysActionLog actionLog, Users user,PointsRule para) throws CommonException {
		try {
			if(Tools.processNull(para.getId()).equals("")){
				actionLog.setMessage("积分参数添加");
				actionLog.setDealCode(DealCode.POINT_PARA_ADD);
				publicDao.save(actionLog);
				para.setInsertUser(user.getUserId());
				para.setInsertDate(actionLog.getDealTime());
				publicDao.save(para);
			}else{
				actionLog.setMessage("积分参数编辑");
				actionLog.setDealCode(DealCode.POINT_PARA_EDIT);
				publicDao.save(actionLog);
				para.setInsertUser(user.getUserId());
				para.setInsertDate(actionLog.getDealTime());
				publicDao.merge(para);
			}
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(Tools.processNull(user.getOrgId()));
			rec.setBrchId(user.getBrchId());
			rec.setUserId(user.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setNote(actionLog.getMessage());
		} catch (Exception e) {
			throw new CommonException("交易积分保存发生错误："+e.getMessage());
		}
	}

	@Override
	public void deletePointPara(SysActionLog actionLog, Users user,String paraIds) throws CommonException {
		try {
			actionLog.setMessage("积分参删除");
			actionLog.setDealCode(DealCode.POINT_PARA_DELETE);
			publicDao.save(actionLog);
			publicDao.doSql("delete from Points_Rule where id in("+paraIds+")");
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(Tools.processNull(user.getOrgId()));
			rec.setBrchId(user.getBrchId());
			rec.setUserId(user.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setNote(actionLog.getMessage());
			rec.setRsvOne(paraIds);
		} catch (Exception e) {
			throw new CommonException("交易积分删除发生错误："+e.getMessage());
		}
	}

	@Override
	public void saveCancelPointPara(SysActionLog actionLog, Users user,String paraIds) throws CommonException {
		try {
			actionLog.setMessage("积分参注销");
			actionLog.setDealCode(DealCode.POINT_PARA_CANCEL);
			publicDao.save(actionLog);
			publicDao.doSql("update Points_Rule set state = '1' where id in("+paraIds+")");
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(Tools.processNull(user.getOrgId()));
			rec.setBrchId(user.getBrchId());
			rec.setUserId(user.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setNote(actionLog.getMessage());
			rec.setRsvOne(paraIds);
		} catch (Exception e) {
			throw new CommonException("交易积分注销发生错误："+e.getMessage());
		}
		
	}

	@Override
	public void saveActivePointPara(SysActionLog actionLog, Users user,String paraIds) throws CommonException {
		try {
			actionLog.setMessage("积分参删除");
			actionLog.setDealCode(DealCode.POINT_PARA_ACTIVE);
			publicDao.save(actionLog);
			publicDao.doSql("update Points_Rule set state = '0' where id in("+paraIds+")");
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(Tools.processNull(user.getOrgId()));
			rec.setBrchId(user.getBrchId());
			rec.setUserId(user.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setNote(actionLog.getMessage());
			rec.setRsvOne(paraIds);
		} catch (Exception e) {
			throw new CommonException("交易积分激活发生错误："+e.getMessage());
		}
		
	}

}
