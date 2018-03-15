package com.erp.service;

import java.util.Map;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.model.Users;

public interface CuteDayService extends BaseService {
	
	/**
	 * 日终扎帐
	 * @throws CommonException
	 */
	public void persistenceCuteDay() throws CommonException;

	
	/**
	 * 用户扎帐
	 * @param actionLog
	 * @param user
	 * @param dealType 1：临时扎帐   2，表示最终扎帐
	 * @return
	 * @throws CommonException
	 */
	public String saveUserDayBal(SysActionLog actionLog,Users user,String dealType) throws CommonException;
	
	/**
	 * 
	 * @param actionLog
	 * @param user
	 * @param dealType 1：临时扎帐   2，表示最终扎帐
	 * @return
	 * @throws CommonException
	 */
	public String saveBrchDayBal(SysActionLog actionLog,Users user,String dealType) throws CommonException;
	
	/**
	 * 强制柜员扎帐
	 * @param actionLog
	 * @param user
	 * @param ids
	 * @return
	 * @throws CommonException
	 */
	public String saveReforceUserDayBal(SysActionLog actionLog, Users user, String[] ids)throws CommonException;

	/**
	 * 填入报表信息公共方法
	 * Description <p>TODO</p>
	 * @param map  报表参数
	 * @param type 类型  1 柜员  2 网点
	 * @param user 柜员
	 * @param brch 网点
	 * @param clrDate 清分日期
	 * @return
	 */
	public Map setReportPara(Map map,String type,Users user,SysBranch brch,String clrDate);
}
