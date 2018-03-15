package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.service.BaseService;
import com.erp.task.DefaultFTPClient;

/**
 * @author yangn
 * @Describe 批量处理FTP上离线数据
 * @version 1.0
 * @data 2015.05.15
 */
public interface OfflineDataProcessService extends BaseService{
	
	/**
	 * 商户离线数据处理
	 * @param ftpClient
	 * @param bizId
	 * @param parentPath
	 * @param fileName
	 * @param upload
	 * @param download
	 * @param historyes
	 * @param repeatFiles
	 * @param failFiles
	 * @throws CommonException
	 */
	public void saveProcessData(DefaultFTPClient ftpClient,String bizId,String parentPath,String fileName,String upload,String historyes,String repeatFiles,String failFiles)throws CommonException;
	
	public void saveProcessDataJS(DefaultFTPClient ftpClient,String bizId,String parentPath,String fileName,String upload,String historyes,String repeatFiles,String failFiles)throws CommonException;
	/**
	 * 验证商户离线数据TAC码
	 * @param len  每次验证数据的条数
	 * @throws CommonException
	 */
	public void saveCheckOffineDataTac()throws CommonException;
	
	
	public void saveCheckOffineDataTacJS()throws CommonException;
	
	/**
	 * 处理非法卡号引起的验证TAC异常 card_no = '21420000000000000000' 或是 card_no = '0000000000000000000'
	 * @throws CommonException
	 */
	public void dealErrorCardNo()throws CommonException;
	 /**
		**脱机数据处理
		**av_in: 各字段以|分割
		**       1biz_id    商户号
		**拒付原因:00－卡片发行方调整01－tac码错02－数据非法03－数据重复04－灰记录05－金额不足06-测试数据09调整拒付10正常数据
	    */
	public void p_OfflineConsume()throws CommonException;
	/**
	 * 自行车商户离线数据处理
	 * @param ftpClient
	 * @param bizId
	 * @param parentPath
	 * @param fileName
	 * @param upload
	 * @param download
	 * @param historyes
	 * @param repeatFiles
	 * @param failFiles
	 * @throws CommonException
	 */
	public void saveProcessData_Zxc(DefaultFTPClient ftpClient,String bizId,String parentPath,String fileName,String upload,String historyes,String repeatFiles,String failFiles)throws CommonException;
	 /**
		**自行车脱机数据处理
		**av_in: 各字段以|分割
		**       1biz_id    商户号
		**拒付原因:00－卡片发行方调整01－tac码错02－数据非法03－数据重复04－灰记录05－金额不足06-测试数据09调整拒付10正常数据
	    */
	public void p_OfflineConsume_Zxc()throws CommonException;
    /**
     * 自行车脱机数据处理（上传消费数据，上传开通）
     * @throws CommonException
     */
    public void saveOffineData_Zxc()throws CommonException;
    
    public void p_OfflineConsume_hncg()throws CommonException;
    
	
}

