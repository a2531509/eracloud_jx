package com.erp.service;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.CardApply;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardRecoverReginfo;
import com.erp.model.TrServRec;
import com.erp.model.Users;

/**
 * 卡片回收登记业务接口。
 * 
 * @author 钱佳明。
 * @date 2016-03-10。
 *
 */
public interface CardRecoverRegisterService {
	public void saveCardRecoverRegister(JSONObject jsonObject, String registerInfo) throws CommonException;
	
	public Long saveCardRecovery(String cardNo,String boxNo,String orderNo,Users oper) throws CommonException;
	
	public TrServRec saveCardRecoveryIssuse(CardApply apply, TrServRec rec)throws CommonException;
	
	public TrServRec saveCardIssue(BasePersonal basePersonal, CardApply cardApply, CardRecoverReginfo cardRecoverReginfo, CardBaseinfo cardBaseinfo) throws CommonException;
}
