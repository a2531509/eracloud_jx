package com.erp.service;

import java.util.List;

import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.CardInsuranceInfo;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.viewModel.ZxcModel;

public interface ZxcService extends BaseService {
	/**
	 * 自行车应用开通
	 * @param person
	 * @param log
	 * @param zxcModel
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveZxcOpen(BasePersonal person,SysActionLog log,ZxcModel zxcModel)throws CommonException;
	
	/**
	 * 自行车应用取消
	 * @param person
	 * @param log
	 * @param zxcModel
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveZxcCancel(BasePersonal person,SysActionLog log,ZxcModel zxcModel)throws CommonException;

	public List<CardInsuranceInfo> saveCardInsurance(List<CardInsuranceInfo> list);

	public void deleteCardInsurance(String dealNo);
	 

}
