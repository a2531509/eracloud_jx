package com.erp.service;

import com.erp.exception.CommonException;

public interface OfflineDataService extends BaseService {
	/**
	 * 公交和城管脱机数据处理
	 * @return
	 * @throws CommonException
	 */
	public String saveOfflineData_Gj_Hncg() throws CommonException;
	/**
	 * 自行车脱机数据处理
	 * @return
	 * @throws CommonException
	 */
	public String saveOfflineData_Zxc() throws CommonException;

}
