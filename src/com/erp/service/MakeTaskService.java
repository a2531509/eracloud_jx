package com.erp.service;

import java.util.List;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.Users;
import com.erp.task.DefaultFTPClient;

public interface MakeTaskService extends BaseService {
	
	/**
	 * 任务回退
	 * @param actionLog
	 * @param user
	 * @param taskId
	 * @return
	 * @throws CommonException
	 */
	public String saveTaskBack(SysActionLog actionLog,Users user,String[] taskId) throws CommonException;
	/**
	 * 导出制卡任务给卫计委
	 * @param actionLog
	 * @param user
	 * @param taskId
	 * @return
	 * @throws CommonException
	 */
	public String saveexportTaskToWjw(SysActionLog actionLog,Users user,String[] taskId)throws CommonException;
	/**
	 * 导入卫计委返回数据
	 * @param actionLog
	 * @param user
	 * @param contents
	 * @return
	 * @throws CommonException
	 */
	public String saveimportTaskReByWjw(SysActionLog actionLog,Users user) throws CommonException;
	
	/**
	 * 导出制卡任务给银行
	 * @param actionLog
	 * @param user
	 * @param taskId
	 * @return
	 * @throws CommonException
	 */
	public String saveexportTaskToBank(SysActionLog actionLog,Users user,String[] taskId,String makeBatchId,String bankId,String vendorId)throws CommonException;
	
	
	/**
	 * 导入银行返回数据
	 * @param actionLog
	 * @param user
	 * @param contents
	 * @return
	 * @throws CommonException
	 */
	public String saveimportTaskReByBank(SysActionLog actionLog,Users user,String bankIdimp) throws CommonException;

	/**
	 * 导入卡厂返回数据
	 * @param actionLog
	 * @param user
	 * @param contents
	 * @return
	 * @throws CommonException
	 */
	public String saveimportTaskReByFacTory(SysActionLog actionLog,Users user) throws CommonException;
	
	/**
	 * 批量开户
	 * @param actionLog
	 * @param user
	 * @throws CommonException
	 */
	public void saveOpenAcc(SysActionLog actionLog,Users user) throws CommonException;
	/**
	 * 半成品卡任务生成
	 * @param actionLog
	 * @param user
	 * @param cardType
	 * @param bankId
	 * @param taskNum
	 * @throws CommonException
	 */
	public void saveNotOnlyTask(SysActionLog actionLog,Users user,String cardType,String bankId,String taskNum )throws CommonException;
	/**
	 * 删除半成品卡制卡任务信息
	 * @param actionLog
	 * @param user
	 * @param taskId
	 * @throws CommonException
	 */
	public void delNotOnlyTask(SysActionLog actionLog,Users user,String taskId) throws CommonException;
	/**
	 * 导出半成品卡制卡任务信息
	 * @param actionLog
	 * @param user
	 * @param taskIds
	 * @throws CommonException
	 */
	public void expNotOnlyTask(SysActionLog actionLog,Users user,String[] taskIds,String bankId)throws CommonException;
	/**
	 * 导入半成品卡任务回盘数据
	 * @param actionLog
	 * @param user
	 * @param bankId
	 * @throws CommonException
	 */
	public void impNotOnlyTask(SysActionLog actionLog,Users user,String bankId)throws CommonException;
	/**
	 * 制卡任务审核信息
	 * @param actionLog
	 * @param user
	 * @param taskId
	 * @throws CommonException
	 */
	public void checkTask(SysActionLog actionLog,Users user,String taskId) throws CommonException;
	/**
	 * 任务明细添加
	 * @param actionLog
	 * @param personIds customer_id|customer_id|customer_id
	 * @param taskId
	 * @throws CommonException
	 */
	public void saveAddTaskMx(SysActionLog actionLog,String personIds,String taskId)throws CommonException;
	/**
	 * 删除任务明细
	 * @param actionLog
	 * @param mxIds
	 * @param taskId
	 * @throws CommonException
	 */
	public void deleteTaskMx(SysActionLog actionLog,String mxIds,String taskId)throws CommonException;
	
	/**
	 * 直接导出文件给银行（不导卫生）嘉兴临时
	 * Description <p>TODO</p>
	 * @param actionLog   操作日志
	 * @param user        操作员
	 * @param taskId      任务编号
	 * @param bankId      银行编号
	 * @param vendorId    卡商编号
	 * @return            
	 * @throws CommonException
	 */
	public String saveexportTaskToBank_Temp(String[] taskId,String cardType,String bankId,String vendorId,Users user,SysActionLog actionLog) throws CommonException;
	
	/**
	 * FTP标识
	 * Description <p>TODO</p>
	 * @param ftp_use
	 * @throws CommonException
	 */
	public void initFtpPara(String ftp_use) throws CommonException;
	
	/**
	 * 嘉兴导入银行审核数据
	 * Description <p>TODO</p>
	 * @param ftpClient FTP客户端
	 * @param bankIdimp 银行编号
	 * @param subDirPath 待处理子目录
	 * @param fileName   文件名
	 * @param subHisDir  历史目录
	 * @param actionLog  操作日志
	 * @param user       操作员
	 * @return
	 * @throws CommonException
	 */
	public String saveimportTaskReByBank_Temp(DefaultFTPClient ftpClient,String bankIdimp,String subDirPath,String fileName,String subHisDir,SysActionLog actionLog,Users user)throws CommonException;
}
