/**
 * 
 */
package com.erp.service;

import com.erp.exception.CommonException;

/**
 * @author hujc
 * @Describe 互联互通公交交互数据处理
 * @version 1.0
 * 
 */
public interface OfflineHlhtService {
	
	
	/**
	 * Description <p>>公交清算数据下发GF</p>
	 * @param bizId 此商户是公交在市民卡系统对应的商户
	 * @param clrDate
	 * @param ftpUserId
	 * @throws CommonException
	 */
	public void saveDownGF_File(String bizId,String clrDate,String ftpUserId)throws CommonException;
	
	/**
	 * Description <p>下发公交黑名单</p>
	 * @param bizId
	 * @param clrDate
	 * @param ftpUserId
	 * @throws CommonException
	 */
    public void savep_WriteBlack(String bizId,String clrDate,String ftpUserId)throws CommonException;
    
    
    /**
	 * Description <p>下发公交黑名单</p>
	 * @param bizId
	 * @param clrDate
	 * @param ftpUserId
	 * @throws CommonException
	 */
    public void saveDFandDT_Handle(String userId,String clrDate)throws CommonException;
    /**
     * 
     * Description <p>TODO</p>
     * @param bizid
     * @param url
     * @param port
     * @param userName
     * @param pwd
     * @param host_download_path
     * @param clrDate
     * @throws CommonException
     */
    public void savep_SSNSQSFileR(String bizid,String url,String port,String userName,String pwd, String host_download_path,String clrDate) throws CommonException;
    
    public void savep_SSNSQSFileRJS(String bizid,String url,String port,String userName,String pwd, String host_download_path,String clrDate) throws CommonException;

    /**
	**脱机数据处理
	**av_in: 各字段以|分割
	**       1biz_id    商户号
	**拒付原因:00－卡片发行方调整01－tac码错02－数据非法03－数据重复04－灰记录05－金额不足06-测试数据09调整拒付10正常数据
    */
    public void savep_OfflineConsume(String bizid)throws CommonException;
}
