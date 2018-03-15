package com.erp.service;

import java.util.Date;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.Users;


/**
* 类功能说明 TODO:城市区域街道service接口
* 类修改者
* 修改日期
* 修改说明
* <p>Title: FunctionService.java</p>
* <p>Description:杰斯科技</p>
* <p>Copyright: Copyright (c) 2006</p>
* <p>Company:杰斯科技有限公司</p>
* @author hujc 631410114@qq.com
* @date 2015-08-27
* @version V1.0
*/
public interface ClrDealService extends BaseService {
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
     * 脱机数据入账
     * @param actionLog
     * @param user
     * @param dealNo
     * @throws CommonException
     */
    public void saveDealOffilne(SysActionLog actionLog,Users user,String dealNo)throws CommonException;
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
	 * 自动取Ftp文件对账
     * @param coOrgId 
	 * @throws CommonException
	 */
	public void saveAutoFtpCheckFile(String coOrgId) throws CommonException;
	
	public void saveCoOrgStat(String coOrgId, Date start);
}
