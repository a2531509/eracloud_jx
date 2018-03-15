package com.erp.serviceImpl;

import java.sql.Timestamp;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.BaseBill;
import com.erp.model.BaseProvider;
import com.erp.model.SysActionLog;
import com.erp.model.Users;
import com.erp.service.BaseBillService;
import com.erp.util.DealCode;
import com.erp.util.Tools;
@Service("baseBillService")
public class BaseBillServiceImpl extends BaseServiceImpl implements BaseBillService {
    public Timestamp currentDate;
	@Override
	public void saveBaseBill(BaseBill baseBill) throws CommonException {
		try {	
			currentDate= new Timestamp(System.currentTimeMillis());
			SysActionLog Log = this.getCurrentActionLog();
			Log.setDealCode(DealCode.BASE_PROVIDER);
			Log.setMessage("票据信息保存");
			publicDao.save(Log);
			Users user=this.getSessionUser();			
			baseBill.setOperDate(currentDate);
			baseBill.setOperId(user.getUserId());
			baseBill.setOrgId(user.getOrgId());
			publicDao.save(baseBill);
			
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}

	@Override
	public void delBaseBill(BaseBill baseBill) throws CommonException {
		SysActionLog actionLog = this.getCurrentActionLog();
		actionLog.setDealCode(DealCode.BASE_BILL);
		actionLog.setMessage("票据信息删除");
		publicDao.save(actionLog);	
			publicDao.doSql("delete from Base_Bill where bill_No='"+baseBill.getBillNo()+"'");	
	}

	@Override
	public void updateBaseBill(BaseBill baseBill) throws CommonException {
		currentDate= new Timestamp(System.currentTimeMillis());
		SysActionLog actionLog = this.getCurrentActionLog();
		actionLog.setDealCode(DealCode.BASE_BILL);
		actionLog.setMessage("票据信息修改");
		Users user=this.getSessionUser();	
		baseBill.setOperDate(currentDate);
		baseBill.setOperId(user.getUserId());
		baseBill.setOrgId(user.getOrgId());
		publicDao.save(actionLog);	
		publicDao.merge(baseBill);
	}
	
}
