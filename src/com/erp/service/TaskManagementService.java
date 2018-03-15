package com.erp.service;

import java.io.InputStream;
import java.util.Map;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.task.DefaultFTPClient;

public interface TaskManagementService extends BaseService {	
	/**
	 * 任务明细添加
	 * @param actionLog
	 * @param personIds customer_id|customer_id|customer_id
	 * @param taskId
	 * @throws CommonException
	 */
	public void saveAddTaskMx(SysActionLog actionLog,String personIds,String taskId)throws CommonException;
	/**
	 * 任务明细删除
	 * @param actionLog
	 * @param mxIds
	 * @param taskId
	 * @throws CommonException
	 */
	public void deleteTaskMx(String taskId,String mxIds,String customerIds,SysActionLog actionLog)throws CommonException;

	/**
	 * 删除（回退）任务
	 * @param actionLog
	 * @param mxIds
	 * @param taskId
	 * @throws CommonException
	 */
	public TrServRec deleteTask(String taskId,SysActionLog actionLog)throws CommonException;
	
	/**
	 * 任务生成
	 * @param selectIds
	 * @param actionLog
	 * @param oper_Id
	 * @throws CommonException
	 */
	public void saveTaskCreate(String[] selectIds,SysActionLog actionLog,String oper_Id)throws CommonException;
	
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
	 * @Version 1.0
	 */
	public Long saveExportTaskToBank(String[] taskId,String cardType,String isUrgent,String bankId,String vendorId,Users user,SysActionLog actionLog) throws CommonException;
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
	public String saveImportTaskRhFile(DefaultFTPClient ftpClient,String fileName,String ImpBankId,Map<String,String> ftpOptions,Users user,SysActionLog actionLog)throws CommonException;	
	/**
	 * 导出卡厂制卡文件
	 * @param batchId  批次号
	 * @param vendorId 卡厂
	 * @param user 操作员
	 * @param log 操作日志
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveExportMadeCardData(String batchId,String vendorId,Users user,SysActionLog log) throws CommonException;
	
	/**
	 * 导出制卡文件数据
	 * @param taskIds 逗号分隔的字符串 1,2,3,4,5,6
	 * @param vendorId
	 * @param user
	 * @param log
	 * @return
	 */
	public TrServRec saveExportMadeCardDataFromTask(String taskIds,String vendorId,Users user,SysActionLog log) throws CommonException;
	/**
	 * 制卡文件导入（单个文件）
	 * @param fileName  文件名称
	 * @param is 文件输入流
	 * @param oper 操作员
	 * @param log  操作日志
	 * @throws CommonException
	 */
	public int saveImportCardData(String fileName,InputStream is,Users oper,SysActionLog log) throws CommonException;
	
	/**
	 * 充值卡制卡文件导入
	 * @param fileName 文件名称
	 * @param is 文件输入流
	 * @param oper 操作员
	 * @param log 操作日志
	 * @return 成功导入数据的条数
	 * @throws CommonException
	 */
	public int saveImportRechargeCardData(String fileName, InputStream is, Users oper, SysActionLog log) throws CommonException;
	/**
	 * 导入文件信息
	 * @param fileName 文件名信息
	 * @param ftpOptions ftp参数信息
	 * @param log 操作日志信息
	 * @return
	 */
	public int saveBatchImportMakeCardData(String fileName,Map<String,String> ftpOptions,SysActionLog log) throws CommonException;
	/**
	 * 检查ＦＴＰ配置信息
	 * @param ftpOptions ftp配置信息
	 * @return ＦＴＰ客户端
	 * @throws CommonException
	 */
	public DefaultFTPClient checkFtp(Map<String,String> ftpOptions) throws Exception;
	/**
	 * 获取FTP配置信息
	 * @param ftp_use
	 * @return map 参数信息
	 * @param host_ip 主机地址
	 * @param host_port 端口号
	 * @param host_upload_path 上传路径
	 * @param host_download_path 下载路径
	 * @param host_history_path 历史目录
	 * @param user_name 用户名
	 * @param pwd 密码
	 */
	public Map<String,String> initFtpOptions(String ftp_use) throws CommonException;
	
	/**
	 * 导出市民卡和银行卡号对应关系
	 * @param batchId 批次号
	 * @param user 操作员
	 * @param log  日志
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveExportBankBkFile(String batchId,String bankId,Users user,SysActionLog log) throws CommonException;
	/**
	 * 保存非个性化采购
	 * @param cardType 非个性化卡类型
	 * @param regionId 区域编号
	 * @param taskSum  采购数量
	 * @param oper 操作员
	 * @param log 操作日志
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveFgxhCg(String cardType, String bankId, String regionId,Long taskSum,Users oper,SysActionLog actionLog) throws CommonException;
	/**
	 * 删除非个性化采购任务
	 * @param taskId
	 * @param oper
	 * @param actionLog
	 * @return
	 */
	public TrServRec saveDeleteFgxhCg(String taskId,Users oper,SysActionLog actionLog) throws CommonException;
	/**
	 * 导出非个性化制卡采购
	 * @param taskIds
	 * @param vendorId
	 * @param oper
	 * @param actionLog
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveExportFgxhCg(String bankId, String[] taskIds,String vendorId,Users oper,SysActionLog actionLog) throws CommonException;
	
	/**
	 * 导入银行审核数据
	 */
	public void saveImportTaskRhFileAuto();
	
	/**
	 * 非个性化采购数据导入
	 * @param is 文件内容
	 * @param user 操作用户
	 * @param log 操作日志
	 * @return 导入数量
	 * @throws CommonException
	 */
	public long saveImportFgxhCgData(InputStream is,Users oper,SysActionLog log) throws CommonException;
	
	/**
	 * 非个性化采购数据导入
	 * @param is 文件内容
	 * @param user 操作用户
	 * @param log 操作日志
	 * @return 导入数量
	 * @throws CommonException
	 */
	public long saveImportFgxhCgData1(InputStream is,Users oper,SysActionLog log) throws CommonException;
	public void saveTaskReceiveRegist(String taskId, TrServRec rec);
}
