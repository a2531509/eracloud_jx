package com.erp.service;

import java.util.List;





import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.BaseCoOrg;
import com.erp.model.SysActionLog;

public interface WebserviceUtilService extends BaseService {
	  public abstract JSONArray findAllBizInfo(String paramString1, String paramString2)
		    throws CommonException;

	  public abstract JSONArray findAllAccLKindList()
	    throws CommonException;
	
	  public abstract void saveUnionInfo(String paramString1, String paramString2)
	    throws CommonException;
	
	  public abstract void saveopenUnionAcc(String paramString)
	    throws CommonException;
	
	  public abstract SysActionLog saveCheckUnion(String paramString1, String paramString2, String paramString3, String paramString4, String paramString5)
	    throws CommonException;
	
	  public abstract SysActionLog saveIssueAmt(String paramString1, String paramString2, String paramString3, String paramString4, String paramString5, String paramString6, String paramString7)
	    throws CommonException;
	
	  public abstract String findBankNoandCardNo(String paramString1, String paramString2)
	    throws CommonException;
	
	  public abstract String saveJysmkIssue(String paramString1, String paramString2, String paramString3, String paramString4, BaseCoOrg paramBaseCoOrg, String paramString5, String paramString6)
	    throws CommonException;
	
	  public abstract String saveSynCardState(String paramString1, String paramString2, String paramString3, String paramString4, String paramString5, String paramString6, BaseCoOrg paramBaseCoOrg)
	    throws CommonException;
}
