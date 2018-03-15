/**
 * 
 */
package com.erp.service;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.Users;

/**
 * @author Administrator
 *
 */

public interface CorpCheckAccountService extends BaseService {
	/**
	 * 合作机构对账平账--合作机构补充值（运营机构多出数据）
	 * 不做任何处理
	 * @param fileListId
	 * @param user
	 * @param actionLog
	 * @throws CommonException
	 */
    public void saveDealdzcorepair(String fileListId,Users user,SysActionLog actionLog) throws CommonException;
    
    /**
     * 合作机构对账平账--运营机构撤销（运营机构多出数据）
     * 对卡做消费交易但是不进行商户的清分 固定交易代码
     * @param fileListId
     * @param user
     * @param actionLog
     * @throws CommonException
     */
    public void saveDealdzorgcancel(String fileListId,Users user,SysActionLog actionLog) throws CommonException;
    
    /**
     * 合作机构对账平账--运营机构补交易（合作机构多出数据）
     * 对卡进行充值 固定交易代码
     * @param fileListId
     * @param user
     * @param actionLog
     * @throws CommonException
     */
    public void saveDealdzorgadd(String fileListId,Users user,SysActionLog actionLog) throws CommonException;
    
    /**
     * 合作机构对账平账--合作机构记录删除（合作机构多出数据）
     * 不做任何处理，只是把对账上传数据该为平账
     * @param fileListId
     * @param user
     * @param actionLog
     * @throws CommonException
     */
    public void saveDealdzdeletemx(String fileListId,Users user,SysActionLog actionLog) throws CommonException;
    
    /**
     * 获取对账文件进行对账处理
     * @param actionLog
     * @param user
     * @param coOrgId
     * @param checkDate
     * @param fileType
     * @throws CommonException
     */
     public void saveGetCheckFile(SysActionLog actionLog,Users user,String coOrgId,String checkDate,String fileType) throws CommonException;
     
     /**
      * 自动获取对账文件进行对账处理
      */
     /**
 	 * 自动取Ftp文件对账
     * @param coOrgId 
 	 * @throws CommonException
 	 */
 	public void saveAutoFtpCheckFile(String coOrgId, String fileType, int day) throws CommonException;
}
