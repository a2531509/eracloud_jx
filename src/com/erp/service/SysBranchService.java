package com.erp.service;

import java.util.List;






import com.erp.exception.CommonException;
import com.erp.model.SysBranch;
import com.erp.model.SysActionLog;
import com.erp.viewModel.TreeModel;

public interface SysBranchService  extends BaseService
{
	List<TreeModel> findSysBranchList();

	List<SysBranch> findSysBranchList(Integer id );

	boolean persistenceSysBranch(SysBranch o,List<String> bankIds);

	boolean delSysBranch(Integer id );
	
	public void saveopenBranchAcc(SysActionLog actionLog,SysBranch branch) throws CommonException;

	/**
	 * 保存网点银行信息
	 * @param brch
	 * @param bankIds
	 */
	void saveBranchBank(SysBranch brch, List<String> bankIds); 
}
