
package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.TrServRec;

/**
 * 单位/社区（村）领卡网点设置业务接口。
 * 
 * @author 钱佳明。
 * @date 2015-12-10。
 *
 */
public interface LkBranchService extends BaseService {

	public TrServRec saveLkBranch(String isCorpOrComm, String corpOrCommId, String lkBranchId, String lkBranchId2, String isBatchHf, boolean isBatchSetting) throws CommonException;

}
