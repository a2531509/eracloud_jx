package com.erp.serviceImpl;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.BaseVendor;
import com.erp.model.SysActionLog;
import com.erp.model.Users;
import com.erp.service.BaseVendorService;
import com.erp.util.DealCode;
import com.erp.util.Tools;
@Service("baseVendorService")
public class BaseVendorServiceImpl extends BaseServiceImpl implements BaseVendorService {
    /**
     * 卡商管理保存
     */
	@Override
	public void saveBaseVendor(BaseVendor baseVendor) throws CommonException {
		try {	
			
			SysActionLog actionLog = this.getCurrentActionLog();
			actionLog.setDealCode(DealCode.BASE_VENDOR);
			actionLog.setMessage("卡商管理信息保存");
			publicDao.save(actionLog);
			Users user=this.getSessionUser();	
			baseVendor.setOpenUserId(user.getUserId());
			baseVendor.setOpenDate(this.getDateBaseDate());
			baseVendor.setState("0");
			publicDao.save(baseVendor);			
		} catch (Exception e) {
			throw new CommonException(e);
		}

	}
	 /**
     * 卡商管理删除
     */
	@Override
	public void delBaseVendor(String vendorId) throws CommonException {
		SysActionLog actionLog = this.getCurrentActionLog();
		actionLog.setDealCode(DealCode.BASE_VENDOR);
		actionLog.setMessage("卡商管理信息删除");
		publicDao.save(actionLog);	
			publicDao.doSql("delete from Base_Vendor where vendor_id='"+vendorId+"'");
		// TODO Auto-generated method stub
		
	}
	 /**
     * 卡商管理更新
     */
	@Override
	public void updateBaseVendor(BaseVendor baseVendor) throws CommonException {
		SysActionLog actionLog = this.getCurrentActionLog();
		actionLog.setDealCode(DealCode.BASE_VENDOR);
		actionLog.setMessage("卡商管理信息修改");
		Users user=this.getSessionUser();	
		baseVendor.setOpenUserId(user.getUserId());
		baseVendor.setOpenDate(this.getDateBaseTime());
		baseVendor.setState("0");
		publicDao.save(actionLog);
        publicDao.merge(baseVendor);
		// TODO Auto-generated method stub
		
	}
	/**
	 * 注销卡商
	 */
	@Override
	public void cancelBaseVendor(BaseVendor baseVendor) throws CommonException {
		SysActionLog actionLog = this.getCurrentActionLog();
		actionLog.setDealCode(DealCode.BASE_VENDOR);
		actionLog.setMessage("卡商管理信息注销");
		Users user=this.getSessionUser();	
		publicDao.save(actionLog);
		baseVendor.setState("1");
		baseVendor.setClsUserId(user.getUserId());
		baseVendor.setClsDate(this.getDateBaseTime());
		publicDao.save(baseVendor);	
	}
	@Override
	public void activaBaseVendor(BaseVendor baseVendor) throws CommonException {
		SysActionLog actionLog = this.getCurrentActionLog();
		actionLog.setDealCode(DealCode.BASE_VENDOR);
		actionLog.setMessage("卡商管理信息激活");
		Users user=this.getSessionUser();	
		publicDao.save(actionLog);
		baseVendor.setState("0");
		baseVendor.setClsUserId("");
		baseVendor.setClsDate(null);
		baseVendor.setOpenUserId(user.getUserId());
		baseVendor.setOpenDate(this.getDateBaseTime());
		publicDao.save(baseVendor);	
	}
	

}
