package com.erp.serviceImpl;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.BaseProvider;
import com.erp.model.CardProducts;
import com.erp.model.SysActionLog;
import com.erp.model.Users;
import com.erp.service.BaseProviderService;
import com.erp.util.DealCode;
@Service("baseProviderService")
public  class BaseProviderServiceImpl extends BaseServiceImpl implements BaseProviderService {

    /**
     * 保存供应商信息
     */
	@Override
	public void saveBaseProvider(BaseProvider basePro) throws CommonException {
		try {		
			SysActionLog actionLog = this.getCurrentActionLog();
			actionLog.setDealCode(DealCode.BASE_PROVIDER);
			actionLog.setMessage("供应商信息保存");
			publicDao.save(actionLog);
			Users user=this.getSessionUser();
			basePro.setOperId(user.getUserId());
			basePro.setOperDate(actionLog.getDealTime());
			basePro.setProviderState("0");
			publicDao.save(basePro);
			
		} catch (Exception e) {
			throw new CommonException(e);
		}
		
	}

	@Override
	public void delBaseProvider(Long providerId) throws CommonException {
		SysActionLog actionLog = this.getCurrentActionLog();
		actionLog.setDealCode(DealCode.BASE_PROVIDER);
		actionLog.setMessage("供应商信息删除");
		publicDao.save(actionLog);
		BaseProvider basePro = (BaseProvider) this.findOnlyRowByHql("from BaseProvider where providerId='"+providerId+"'");		
		if(basePro != null){	
			publicDao.delete(basePro);
		}
		
	}

	@Override
	public void updateBaseProvider(BaseProvider basePro) throws CommonException {
		SysActionLog actionLog = this.getCurrentActionLog();
		actionLog.setDealCode(DealCode.BASE_PROVIDER);
		actionLog.setMessage("供应商信息修改");
		Users user=this.getSessionUser();		
		basePro.setOperId(user.getUserId());
		basePro.setOperDate(getDateBaseTime());
		basePro.setProviderState("0");
		publicDao.save(actionLog);
		 
		if(basePro != null){	
			publicDao.merge(basePro);
		}
		
	}



}
