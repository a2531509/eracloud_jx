package com.erp.serviceImpl;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.apache.commons.net.ftp.FTPClient;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.service.OfflineHlhtService;
import com.erp.task.DefaultFTPClient;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.JdbcUtils;
import com.erp.util.Tools;

/**
 * @author hujc
 * @Describe 互联互通公交交互数据处理
 * @version 1.0
 */
@SuppressWarnings({"unused","rawtypes"})
@Service(value="offlineHlhtService")
public class OfflineHlhtServiceImpl extends BaseServiceImpl implements OfflineHlhtService {
	private static Logger logger = Logger.getLogger(OfflineHlhtServiceImpl.class);
	private String url;
	private String userName;//ftp登录用户名
	private String pwd;//ftp登录密码
	private String port;//ftp端口
	private String host_download_path;//下发文件目录
	private String ftp_download_history;//下发文件历史目录
	private String host_upload_path;//下载文件目录
	private String host_history_path;//下载文件历史目录
	private String host_repeat_path;//重复文件目录
	private String host_errors_path;//错误文件目录
	private String host_shgf_download_path;//上海gf下发文件目录
	private String host_qggf_download_path;//全国gf下发文件目录
	
	@Override
	public void saveDownGF_File(String bizId, String clrDate, String ftpUserId)
			throws CommonException {
		DefaultFTPClient ftpClient = new DefaultFTPClient();
		try {
			if(Tools.processNull(bizId).equals("041010010010002")){
				//这个公交不发卡
				return;
			}
			DefaultFTPClient.writeLog("-----开始上传"+bizId+"GF文件-----");
			//1，登录ftp
			//1.1初始化ftp参数
			initFtpInfo(ftpUserId);
			Map  ftpOptions= new HashMap() ;
			ftpOptions.put("host_ip", url);
			ftpOptions.put("user_name", userName);
			ftpOptions.put("pwd", pwd);
			//1.2登录ftp操作
			boolean isCanConn = ftpClient.toConnect(url,21);
			if(!isCanConn){
				try{
					ftpClient.logout();
					ftpClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
				return;//FTP连接失败
			}
			boolean isCanLogin = ftpClient.toLogin(userName,pwd);
			if(!isCanLogin){
				try{
					ftpClient.logout();
					ftpClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
				return;//FTP登陆失败
			}
			ftpClient.setConnectTimeout(60000);
			ftpClient.setDataTimeout(60000);
			ftpClient.setFileType(FTPClient.BINARY_FILE_TYPE);
			ftpClient.changeWorkingDirectory("/");
			//获取此商户关联的发卡方
			List belongList = this.findBySql("select t.CARD_ORG_ID from card_org_bind_section t where t.acpt_id ='"+bizId+"'");
			if(belongList == null || belongList.size() == 0){
				throw new CommonException("该商户没有配置发卡方，无法下发GF文件");
			} 
			String belongs = Tools.getConcatStrFromList(belongList, "'", ",");
			List gfshList = this.findBySql("SELECT ROW_NUMBER() over(order by t.deal_date) seq,t.acpt_id,t.card_no,t.card_tr_count,"
					+ " t.sam_seq,t.bal_bef,t.deal_amt,t.deal_date||t.deal_time deal_date,t.deal_type,'' psam_no,t.tac,t.trans_city_code"
					+ "  FROM pay_offline_union_df t WHERE t.acpt_id ='"+Constants.SHANGHAI_BIZID+"' and t.CARD_ORG_ID in("+belongs+") and t.clr_Date ='"+clrDate+"'");
			System.out.println("SELECT ROW_NUMBER() over(order by t.deal_date) seq,t.acpt_id,t.card_no,t.card_tr_count,"
					+ " t.sam_seq,t.bal_bef,t.deal_amt,t.deal_date||t.deal_time deal_date,t.deal_type,'' psam_no,t.tac,t.trans_city_code"
					+ "  FROM pay_offline_union_df t WHERE t.acpt_id ='"+Constants.SHANGHAI_BIZID+"' and t.CARD_ORG_ID in("+belongs+") and t.clr_Date ='"+clrDate+"'");
			//2，开始上传GF文件 上海
			String gfshFileName = "GF" + clrDate.replaceAll("-", "") + "01" + bizId + "001";
			StringBuffer gfshcontent = new StringBuffer();
			gfshcontent.append("GF01"+Tools.tensileString(Tools.processNull(gfshList.size()), 8, true, "0")+Tools.tensileString(Tools.processNull("146"), 8, true, "0") +Tools.tensileString(Tools.processNull("F"), 24, true, "F"));
			gfshcontent.append("\r\n");
			if(gfshList != null && gfshList.size() >0 ){
				for(int i=0;i<gfshList.size();i++){
					Object[] obj = (Object[])gfshList.get(i);
					gfshcontent.append(Tools.tensileString(Tools.processNull(obj[0]), 8, true, "0"));
					gfshcontent.append(Tools.tensileString(Tools.processNull(obj[1]), 15, true, "0"));
					gfshcontent.append(Tools.tensileString(Tools.processNull(obj[2]), 20, true, "0"));
					gfshcontent.append(Tools.tensileString(Tools.processNull(obj[3]), 6, true, "0"));
					gfshcontent.append(Tools.tensileString(Tools.processNull(obj[4]), 10, true, "0"));
					gfshcontent.append(Tools.tensileString(Tools.processNull(obj[5]), 8, true, "0"));
					gfshcontent.append(Tools.tensileString(Tools.processNull(obj[6]), 8, true, "0"));
					gfshcontent.append(Tools.tensileString(Tools.processNull(obj[7]), 14, true, "0"));
					gfshcontent.append(Tools.tensileString(Tools.processNull(obj[8]), 2, true, "0"));
					gfshcontent.append(Tools.tensileString(Tools.processNull(obj[9]), 12, true, "0"));
					gfshcontent.append(Tools.tensileString(Tools.processNull(obj[10]), 8, true, "0"));
					gfshcontent.append(Tools.tensileString(Tools.processNull(obj[11]), 4, true, "0"));
					gfshcontent.append(Tools.tensileString(Tools.processNull("F"), 30, true, "F"));
					gfshcontent.append("\r\n");
				}
			}
			writeFile(ftpClient,gfshFileName ,host_shgf_download_path ,gfshcontent.toString(),ftpOptions);
			/*ftpClient.logout();
			
			boolean isCanLogin = ftpClient.toLogin(userName,pwd);
			if(!isCanLogin){
				try{
					ftpClient.logout();
					ftpClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
				return;//FTP登陆失败
			}
			ftpClient.setConnectTimeout(60000);
			ftpClient.setDataTimeout(60000);
			ftpClient.setFileType(FTPClient.BINARY_FILE_TYPE);
			ftpClient.changeWorkingDirectory("/");*/
			//结束上传GF文件 上海
			
			List gfqgList = this.findBySql("SELECT ROW_NUMBER() over(order by t.deal_date) seq,t.acpt_id,t.card_no,t.card_tr_count,"
					+ " t.sam_seq,t.bal_bef,t.deal_amt,t.deal_date||t.deal_time deal_date,t.deal_type,'' psam_no,t.tac,t.trans_city_code"
					+ "  FROM pay_offline_union_df t WHERE t.acpt_id ='"+Constants.QUANGUO_BIZID+"' and t.CARD_ORG_ID in("+belongs+") and t.clr_Date ='"+clrDate+"'");
			System.out.println("SELECT ROW_NUMBER() over(order by t.deal_date) seq,t.acpt_id,t.card_no,t.card_tr_count,"
					+ " t.sam_seq,t.bal_bef,t.deal_amt,t.deal_date||t.deal_time deal_date,t.deal_type,'' psam_no,t.tac,t.trans_city_code"
					+ "  FROM pay_offline_union_df t WHERE t.acpt_id ='"+Constants.QUANGUO_BIZID+"' and t.CARD_ORG_ID in("+belongs+") and t.clr_Date ='"+clrDate+"'");
			//2，开始上传GF文件 全国
			String gfqgFileName = "GF" + clrDate.replaceAll("-", "") + "01" + bizId + "002";
			StringBuffer gfqgcontent = new StringBuffer();
			gfqgcontent.append("GF01"+Tools.tensileString(Tools.processNull(gfqgList.size()), 8, true, "0")+Tools.tensileString(Tools.processNull("146"), 8, true, "0") +Tools.tensileString(Tools.processNull("F"), 24, true, "F"));
			gfqgcontent.append("\r\n");
			if(gfqgList != null && gfqgList.size() >0 ){
				for(int i=0;i<gfqgList.size();i++){
					Object[] obj = (Object[])gfqgList.get(i);
					gfqgcontent.append(Tools.tensileString(Tools.processNull(obj[0]), 8, true, "0"));
					gfqgcontent.append(Tools.tensileString(Tools.processNull(obj[1]), 15, true, "0"));
					gfqgcontent.append(Tools.tensileString(Tools.processNull(obj[2]), 20, true, "0"));
					gfqgcontent.append(Tools.tensileString(Tools.processNull(obj[3]), 6, true, "0"));
					gfqgcontent.append(Tools.tensileString(Tools.processNull(obj[4]), 10, true, "0"));
					gfqgcontent.append(Tools.tensileString(Tools.processNull(obj[5]), 8, true, "0"));
					gfqgcontent.append(Tools.tensileString(Tools.processNull(obj[6]), 8, true, "0"));
					gfqgcontent.append(Tools.tensileString(Tools.processNull(obj[7]), 14, true, "0"));
					gfqgcontent.append(Tools.tensileString(Tools.processNull(obj[8]), 2, true, "0"));
					gfqgcontent.append(Tools.tensileString(Tools.processNull(obj[9]), 12, true, "0"));
					gfqgcontent.append(Tools.tensileString(Tools.processNull(obj[10]), 8, true, "0"));
					gfqgcontent.append(Tools.tensileString(Tools.processNull(obj[11]), 4, true, "0"));
					gfqgcontent.append(Tools.tensileString(Tools.processNull("F"), 30, true, "F"));
					gfqgcontent.append("\r\n");
				}
			}
			writeFile(ftpClient,gfqgFileName ,host_qggf_download_path ,gfqgcontent.toString(),ftpOptions);
			//结束上传GF文件 全国
			DefaultFTPClient.writeLog("-----结束上传"+bizId+"GF文件-----");
		} catch (Exception e) {
			DefaultFTPClient.writeLog("上传"+bizId+"GF文件出错："+e.getMessage());
			throw new CommonException("下发"+bizId+"GF文件出错："+e.getMessage());
		}
	}
	
	
	@Override
	public void savep_WriteBlack(String bizId, String clrDate, String ftpUserId)
			throws CommonException {
		DefaultFTPClient ftpClient = new DefaultFTPClient();
    	try {
    		DefaultFTPClient.writeLog("写清算文件");
			//1登录ftp
			boolean isCanConn = ftpClient.toConnect(url,21);
			if(!isCanConn){
				try{
					ftpClient.logout();
					ftpClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
				return;//FTP连接失败
			}
			boolean isCanLogin = ftpClient.toLogin(userName,pwd);
			if(!isCanLogin){
				try{
					ftpClient.logout();
					ftpClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
				return;//FTP登陆失败
			}
			DefaultFTPClient.writeLog("-----开始上传"+bizId+"black文件-----");
			ftpClient.changeWorkingDirectory("/");
			Map  ftpOptions= new HashMap() ;
			ftpOptions.put("host_ip", url);
			ftpOptions.put("user_name", userName);
			ftpOptions.put("pwd", pwd);
			List hmdlist  = publicDao.findBySQL("SELECT t.card_no FROM CARD_BLACK T WHERE " + 
											  "  t.blk_state = '0' AND ROWNUM < 10000 ORDER BY t.last_date DESC ");//黑名单数据列表
			//2，写黑名单
			//2.1文件名YYYYMMDD_Black.txt;
			String fileName = clrDate.replaceAll("-", "") + "_Black";
			StringBuffer sb = new StringBuffer();
			//2.2写文件头
			sb.append(clrDate.replaceAll("-", ""));//Blackversion	N8	黑名单版本	YYYYMMDD
			sb.append("\r\n");
			//2.3写记录
			if(null!=hmdlist&&hmdlist.size()>0){
				for (int j = 0; j < hmdlist.size(); j++) {
					String card_No=(String)hmdlist.get(j);
					sb.append(Tools.tensileString(card_No,20,true,"0"));//Cardno	N20	卡应用序列号	发行流水号(卡面号)
					sb.append("\r\n");//
				}
			}
			writeFile(ftpClient, fileName,host_download_path,sb.toString(),ftpOptions);
			DefaultFTPClient.writeLog("-----结束上传"+bizId+"black文件-----");
		} catch (Exception e) {
			DefaultFTPClient.writeLog("error：" + e.getMessage());
		}finally{
			if(ftpClient != null && ftpClient.isConnected()){
				try{
					ftpClient.logout();
					ftpClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
			}
		}
    }
	
	/**
	 * Description <p>内部调用方法《写文件》</p>
	 * @param ftpClient
	 * @param fileName
	 * @param path
	 * @param content
	 * @param ftpOptions
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("static-access")
	private int writeFile(DefaultFTPClient ftpClient,String fileName,String path,String content,Map<String,String>  ftpOptions) throws CommonException{
		InputStream input = null;
		try{
			//System.out.println(ftpClient.isConnected());
			ftpClient.enterLocalPassiveMode();
			ftpClient.setControlEncoding("UTF-8");
			input = new ByteArrayInputStream(content.getBytes("UTF-8"));
			//System.out.println(ftpClient.printWorkingDirectory());
			boolean  c = ftpClient.changeWorkingDirectory("/");
			ftpClient.setFileType(FTPClient.BINARY_FILE_TYPE);
			boolean  b =ftpClient.changeWorkingDirectory(path);
			boolean  a =  ftpClient.storeFile(fileName, input);
			//System.out.println("============="+fileName + path  + a  +  b + c);
			/*for(String key : ftpOptions.keySet()){
				System.out.println(key + "===" + ftpOptions.get(key));
			}*/
		}catch(Exception e){
			e.printStackTrace();
			DefaultFTPClient.writeLog("写文件" + fileName + "出错：" + e.getMessage());
			return -1;
		}finally{
			try {
				input.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return 0;
	}
	
	/**
	 * Description <p>内部调用方法《获取ftp配置》</p>
	 * @param ftp_user_id
	 */
	private void initFtpInfo(String ftp_user_id){
		List ftpPara;
		try {
			ftpPara = JdbcUtils.queryMapList(JdbcUtils.openConnection(), "select t.ftp_para_name,t.ftp_para_value from SYS_FTP_CONF t where t.ftp_use = '" + ftp_user_id + "'");
		} catch (Exception e) {
			logger.error("获取清分日期出错有误:"+e.getMessage());
			throw new CommonException(e.getMessage());
		}
		if(ftpPara == null || ftpPara.size() <= 0){
			throw new CommonException("获取ftp配置出错，请联系系统管理员！");
		}
		for(int k = 0;k < ftpPara.size();k++){
			Map<String, String> map = (Map)ftpPara.get(k);
			if(Tools.processNull(map.get("FTP_PARA_NAME")).equals("host_ip")){
				url = Tools.processNull(map.get("FTP_PARA_VALUE"));
			}
			if(Tools.processNull(map.get("FTP_PARA_NAME")).equals("host_upload_path")){
				host_upload_path = Tools.processNull(map.get("FTP_PARA_VALUE"));
			}
			if(Tools.processNull(map.get("FTP_PARA_NAME")).equals("host_download_path")){
				host_download_path = Tools.processNull(map.get("FTP_PARA_VALUE"));
			}
			if(Tools.processNull(map.get("FTP_PARA_NAME")).equals("host_history_path")){
				host_history_path = Tools.processNull(map.get("FTP_PARA_VALUE"));
			}
			if(Tools.processNull(map.get("FTP_PARA_NAME")).equals("host_port")){
				port = Tools.processNull(map.get("FTP_PARA_VALUE"));
			}
			if(Tools.processNull(map.get("FTP_PARA_NAME")).equals("pwd")){
				pwd = Tools.processNull(map.get("FTP_PARA_VALUE"));
			}
			if(Tools.processNull(map.get("FTP_PARA_NAME")).equals("user_name")){
				userName = Tools.processNull(map.get("FTP_PARA_VALUE"));
			}
			if(Tools.processNull(map.get("FTP_PARA_NAME")).equals("host_repeat_path")){
				host_repeat_path = Tools.processNull(map.get("FTP_PARA_VALUE"));
			}
			if(Tools.processNull(map.get("FTP_PARA_NAME")).equals("host_errors_path")){
				host_errors_path = Tools.processNull(map.get("FTP_PARA_VALUE"));
			}
			if(Tools.processNull(map.get("FTP_PARA_NAME")).equals("host_shgf_download")){
				host_shgf_download_path = Tools.processNull(map.get("FTP_PARA_VALUE"));
			}
			if(Tools.processNull(map.get("FTP_PARA_NAME")).equals("host_qggf_download")){
				host_qggf_download_path = Tools.processNull(map.get("FTP_PARA_VALUE"));
			}
		}
	}


	@Override
	public void saveDFandDT_Handle(String userId, String clrDate)
			throws CommonException {
		try {
			List<Object> in = new ArrayList<Object>();
			in.add(userId);
			in.add("0");
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			publicDao.callProc("pk_consume.p_offlineconsume_ydtobd",in,out);
		} catch (Exception e) {
			DefaultFTPClient.writeLog("处理DT文件出错出错："+e.getMessage());
			//throw new CommonException("处理DT文件出错出错："+e.getMessage());
			
		}
		
		try {
			List<Object> in = new ArrayList<Object>();
			in.add(userId);
			in.add("0");
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			publicDao.callProc("pk_consume.p_offlineconsume_bdtoyd",in,out);
		} catch (Exception e) {
			DefaultFTPClient.writeLog("处理DF文件出错出错："+e.getMessage());
			//throw new CommonException("处理DF文件出错出错："+e.getMessage());
		}
		
	}

	@Override
	public void savep_SSNSQSFileR(String bizid, String url, String port,
			String userName, String pwd, String host_download_path,
			String clrDate) throws CommonException {

		DefaultFTPClient ftpClient = new DefaultFTPClient();
		try{
			writeLog("写公交清算文件开始");
			//1登录ftp
			boolean isCanConn = ftpClient.toConnect(url,21);
			if(!isCanConn){
				try{
					ftpClient.logout();
					ftpClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
				return;//FTP连接失败
			}
			boolean isCanLogin = ftpClient.toLogin(userName,pwd);
			if(!isCanLogin){
				try{
					ftpClient.logout();
					ftpClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
				return;//FTP登陆失败
			}
			//and t.refuse_reason not in ('53','63')
			ftpClient.setFileType(FTPClient.BINARY_FILE_TYPE);
			ftpClient.changeWorkingDirectory("/");
			List sslist  = publicDao.findBySQL("select t.send_file_name,t.end_deal_no,t.clr_date,t.refuse_reason,t.acpt_id, " +
											" t.end_id,t.card_no,t.card_in_type,t.card_in_subtype,t.card_valid_date bb ," + 
											" t.card_start_date,t.card_valid_date aa ,t.card_deal_count,t.psam_deal_no," + 
											" t.acc_bal,t.deal_amt,t.deal_date,t.deal_kind,t.psam_no,t.tac, "+
											" t.ash_flag,'00','0','FFFFFF' "+ 
											" from pay_offline_black t where t.acpt_id = '" + bizid +"' and clr_date ='"
											+clrDate+"' and t.send_file_name is not null "
											+ " and t.deal_code = '40101010' union all  select t.send_file_name,t.end_deal_no,t.clr_date,t.refuse_reason,t.acpt_id, " +
											" t.end_id,t.card_no,t.card_in_type,t.card_in_subtype,t.card_valid_date bb ," + 
											" t.card_start_date,t.card_valid_date aa ,t.card_deal_count,t.psam_deal_no," + 
											" t.acc_bal,t.deal_amt,t.deal_date,t.deal_kind,t.psam_no,t.tac, "+
											" t.ash_flag,'00','0','FFFFFF' "+ 
											" from pay_offline_list  t where t.acpt_id = '" + bizid +"' and clr_date ='"
											+clrDate+"' and t.send_file_name is not null and t.refuse_reason = '00' "
											+ " and t.deal_code = '40101010' ");//拒付数据列表
			//2，写拒付文件SS
			//2.1定义文件名
			String ssFileName = "SS"+ clrDate.replace("-", "") + "01" + 
							     bizid + "001";
			StringBuffer sb = new StringBuffer();
			//2.2文件头
			sb.append("SS"+"01" +Tools.tensileString(Tools.processNull(sslist.size()+""), 8, true, "0") + "00000200" + "FFFFFFFFFFFFFFFFFFFFFFFF");//Blackversion	N8	黑名单版本	YYYYMMDD
			sb.append("\r\n");
			//2.3写记录
			//ftpOptions.get("host_ip"), 21, ftpOptions.get("user_name"), ftpOptions.get("pwd")
			Map  ftpOptions= new HashMap() ;
			ftpOptions.put("host_ip", url);
			ftpOptions.put("user_name", userName);
			ftpOptions.put("pwd", pwd);
			if(null!=sslist&&sslist.size()>0){
				int pos = 0;
				for(int i=0;i<sslist.size();i++){
					Object[] obj = (Object[])sslist.get(i);
					sb.append(Tools.tensileString(Tools.processNull(obj[0]), 30, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[1]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[2]).replaceAll("-", ""), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[3]), 2, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[4]), 15, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[5]), 10, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[6]), 20, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[7]), 2, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[8]), 2, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[9]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[10]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[11]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[12]), 6, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[13]), 10, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[14]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[15]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[16]), 14, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[17]), 2, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[18]), 12, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[19]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[20]), 2, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[21]), 2, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[22]), 1, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[23]), 6, true, "0"));
					//sb.append(Tools.tensileString(Tools.processNull(obj[24]), 1, true, "24"));
					sb.append("\r\n");
				}
			}
			writeFile(ftpClient,ssFileName ,"download" ,sb.toString(),ftpOptions);
			//3，写清算文件
			//3.1定义文件名
			String qsFileName = "QS"+ clrDate.replace("-", "") + "01" + 
							     bizid + "001";
			
			Object[] zcinfo = (Object[])this.findOnlyRowBySql("select count(1),sum(deal_amt) from pay_offline_list t where t.acpt_id = '" + bizid +"' and clr_date ='" +clrDate+"' and t.REFUSE_REASON <> '00' and t.send_file_name is not null  and t.deal_code = '40101010' ");
			Object[] jfinfo = (Object[])this.findOnlyRowBySql("select count(1),sum(deal_amt) from pay_offline_black t where t.acpt_id = '" + bizid +"' and clr_date ='" +clrDate+"' and t.send_file_name is not null and t.deal_code = '40101010' and t.REFUSE_REASON not in ('90','92','93','94','67','68','69') ");
			Object[] tzinfo = (Object[])this.findOnlyRowBySql("select count(1),sum(deal_amt) from pay_offline_list t where t.acpt_id = '" + bizid +"' and clr_date ='" +clrDate+"' and t.REFUSE_REASON = '00'  and t.send_file_name is not null and t.deal_code = '40101010' ");
			Object[] tzjfinfo = (Object[])this.findOnlyRowBySql("select count(1),sum(deal_amt) from pay_offline_black t where t.acpt_id = '" + bizid +"' and clr_date ='" +clrDate+"' and t.REFUSE_REASON in ('90','92','93','94','67','68','69') and   t.send_file_name is not null and t.deal_code = '40101010' ");
			StringBuffer qssb = new StringBuffer();
			//3.2文件头
			qssb.append("QS"+"000000" +"01" + "00000103" + "FFFFFFFFFFFFFFFFFFFFFFFF");//Blackversion	N8	黑名单版本	YYYYMMDD
			qssb.append("\r\n");
			
			//3.3写记录
			//ftpOptions.get("host_ip"), 21, ftpOptions.get("user_name"), ftpOptions.get("pwd")
			qssb.append(bizid);
			qssb.append(clrDate.replaceAll("-", ""));
			if( !(zcinfo == null && jfinfo == null && tzinfo == null && tzjfinfo == null) ){
				if(zcinfo == null){
					qssb.append(Tools.tensileString("0", 8, true, "0"));
					qssb.append(Tools.tensileString("0", 10, true, "0"));
				}else{
					qssb.append(Tools.tensileString(Tools.processNull(zcinfo[0]), 8, true, "0"));
					qssb.append(Tools.tensileString(Tools.processNull(zcinfo[1]), 10, true, "0"));
				}
				if(jfinfo == null){
					qssb.append(Tools.tensileString("0", 8, true, "0"));
					qssb.append(Tools.tensileString("0", 10, true, "0"));
				}else{
					qssb.append(Tools.tensileString(Tools.processNull(jfinfo[0]), 8, true, "0"));
					qssb.append(Tools.tensileString(Tools.processNull(jfinfo[1]), 10, true, "0"));
				}
				if(tzinfo == null){
					qssb.append(Tools.tensileString("0", 8, true, "0"));
					qssb.append(Tools.tensileString("0", 10, true, "0"));
				}else{
					qssb.append(Tools.tensileString(Tools.processNull(tzinfo[0]), 8, true, "0"));
					qssb.append(Tools.tensileString(Tools.processNull(tzinfo[1]), 10, true, "0"));
				}
				if(tzjfinfo == null){
					qssb.append(Tools.tensileString("0", 8, true, "0"));
					qssb.append(Tools.tensileString("0", 10, true, "0"));
				}else{
					qssb.append(Tools.tensileString(Tools.processNull(tzjfinfo[0]), 8, true, "0"));
					qssb.append(Tools.tensileString(Tools.processNull(tzjfinfo[1]), 10, true, "0"));
				}
				qssb.append(Tools.tensileString("0", 8, true, "0"));
				qssb.append("\r\n");
				writeFile(ftpClient,qsFileName ,"download" ,qssb.toString(),ftpOptions);
			}
			
			
			
			//4，写清算文件记录
			//4.1定义文件名
			String nsFileName = "NS"+ clrDate.replaceAll("-", "") + "01" + 
							     bizid + "001";
			
			List nslist = this.findBySql(" select t.send_file_name from pay_offline_filename t where to_char(t.send_date,'yyyy-mm-dd') ='"+clrDate+"'"
								+ " and t.merchant_id = '" +bizid+"' and t.send_file_name like 'XF%' "
								+ "  group by t.send_file_name ORDER BY t.send_file_name ");
			StringBuffer nssb = new StringBuffer();
			//4.2文件头
			nssb.append("NS"+"01"+Tools.tensileString(Tools.processNull(nslist.size()+""), 8, true, "0") + "00000046" + "FFFFFFFFFFFFFFFFFFFFFFFF");//Blackversion	N8	黑名单版本	YYYYMMDD
			nssb.append("\r\n");
			//4.3写记录
			if(null!=nslist&&nslist.size()>0){
				for(int i=0;i<nslist.size();i++){
					String nsobj = (String)nslist.get(i);
					nssb.append(Tools.tensileString(Tools.processNull(nsobj), 30, false, " "));
					nssb.append(Tools.tensileString(Tools.processNull(clrDate.replaceAll("-", "")), 8, true, ""));
					nssb.append("FFFFFFFF");
					nssb.append("\r\n");
				}
			}
			writeFile(ftpClient, nsFileName,"download", nssb.toString(),ftpOptions);
		}catch(Exception e){
			writeLog("error：" + e.getMessage());
		}finally{
			if(ftpClient != null && ftpClient.isConnected()){
				try{
					ftpClient.logout();
					ftpClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
			}
		}
		
	}
	
	@Override
	public void savep_SSNSQSFileRJS(String bizid, String url, String port,
			String userName, String pwd, String host_download_path,
			String clrDate) throws CommonException {

		DefaultFTPClient ftpClient = new DefaultFTPClient();
		try{
			writeLog("写嘉善停车收费清算文件开始");
			//1登录ftp
			boolean isCanConn = ftpClient.toConnect(url,21);
			if(!isCanConn){
				try{
					ftpClient.logout();
					ftpClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
				return;//FTP连接失败
			}
			boolean isCanLogin = ftpClient.toLogin(userName,pwd);
			if(!isCanLogin){
				try{
					ftpClient.logout();
					ftpClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
				return;//FTP登陆失败
			}
			//and t.refuse_reason not in ('53','63')
			ftpClient.setFileType(FTPClient.BINARY_FILE_TYPE);
			ftpClient.changeWorkingDirectory("/");
			List sslist  = publicDao.findBySQL("select t.send_file_name,t.end_deal_no,t.clr_date,t.refuse_reason,t.acpt_id, " +
											" t.end_id,t.card_no,t.card_in_type,t.card_in_subtype,t.card_valid_date bb ," + 
											" t.card_start_date,t.card_valid_date aa ,t.card_deal_count,t.psam_deal_no," + 
											" t.acc_bal,t.deal_amt,t.deal_date,t.deal_kind,t.psam_no,t.tac, "+
											" t.ash_flag,'00','0','FFFFFF' "+ 
											" from pay_offline_black t where t.acpt_id = '" + bizid +"' and clr_date ='"
											+clrDate+"' and t.send_file_name is not null "
											+ " and t.deal_code = '40101010' union all  select t.send_file_name,t.end_deal_no,t.clr_date,t.refuse_reason,t.acpt_id, " +
											" t.end_id,t.card_no,t.card_in_type,t.card_in_subtype,t.card_valid_date bb ," + 
											" t.card_start_date,t.card_valid_date aa ,t.card_deal_count,t.psam_deal_no," + 
											" t.acc_bal,t.deal_amt,t.deal_date,t.deal_kind,t.psam_no,t.tac, "+
											" t.ash_flag,'00','0','FFFFFF' "+ 
											" from pay_offline_list  t where t.acpt_id = '" + bizid +"' and clr_date ='"
											+clrDate+"' and t.send_file_name is not null and t.refuse_reason = '00' "
											+ " and t.deal_code = '40101010' ");//拒付数据列表
			//2，写拒付文件SS
			//2.1定义文件名
			String ssFileName = "SS"+ clrDate.replace("-", "") + "06" + 
							     bizid + "001";
			StringBuffer sb = new StringBuffer();
			//2.2文件头
			sb.append("SS"+"06" +Tools.tensileString(Tools.processNull(sslist.size()+""), 8, true, "0") + "00000200" + "FFFFFFFFFFFFFFFFFFFFFFFF");//Blackversion	N8	黑名单版本	YYYYMMDD
			sb.append("\r\n");
			//2.3写记录
			//ftpOptions.get("host_ip"), 21, ftpOptions.get("user_name"), ftpOptions.get("pwd")
			Map  ftpOptions= new HashMap() ;
			ftpOptions.put("host_ip", url);
			ftpOptions.put("user_name", userName);
			ftpOptions.put("pwd", pwd);
			if(null!=sslist&&sslist.size()>0){
				int pos = 0;
				for(int i=0;i<sslist.size();i++){
					Object[] obj = (Object[])sslist.get(i);
					sb.append(Tools.tensileString(Tools.processNull(obj[0]), 30, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[1]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[2]).replaceAll("-", ""), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[3]), 2, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[4]), 15, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[5]), 10, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[6]), 20, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[7]), 2, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[8]), 2, true, "0"));
					//减少两位
					sb.append(Tools.tensileString(Tools.processNull(obj[9]), 6, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[10]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[11]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[12]), 6, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[13]), 10, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[14]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[15]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[16]), 14, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[17]), 2, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[18]), 12, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[19]), 8, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[20]), 2, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[21]), 2, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[22]), 1, true, "0"));
					sb.append(Tools.tensileString(Tools.processNull(obj[23]), 10, true, "0"));
					//sb.append(Tools.tensileString(Tools.processNull(obj[24]), 1, true, "24"));
					sb.append("\r\n");
				}
			}
			writeFile(ftpClient,ssFileName ,"download" ,sb.toString(),ftpOptions);
			//3，写清算文件
			//3.1定义文件名
			String qsFileName = "QS"+ clrDate.replace("-", "") + "06" + 
							     bizid + "001";
			
			Object[] zcinfo = (Object[])this.findOnlyRowBySql("select count(1),sum(deal_amt) from pay_offline_list t where t.acpt_id = '" + bizid +"' and clr_date ='" +clrDate+"' and t.REFUSE_REASON <> '00' and t.send_file_name is not null  and t.deal_code = '40101010' ");
			Object[] jfinfo = (Object[])this.findOnlyRowBySql("select count(1),sum(deal_amt) from pay_offline_black t where t.acpt_id = '" + bizid +"' and clr_date ='" +clrDate+"' and t.send_file_name is not null and t.deal_code = '40101010' and t.REFUSE_REASON not in ('90','92','93','94','67','68','69') ");
			Object[] tzinfo = (Object[])this.findOnlyRowBySql("select count(1),sum(deal_amt) from pay_offline_list t where t.acpt_id = '" + bizid +"' and clr_date ='" +clrDate+"' and t.REFUSE_REASON = '00'  and t.send_file_name is not null and t.deal_code = '40101010' ");
			Object[] tzjfinfo = (Object[])this.findOnlyRowBySql("select count(1),sum(deal_amt) from pay_offline_black t where t.acpt_id = '" + bizid +"' and clr_date ='" +clrDate+"' and t.REFUSE_REASON in ('90','92','93','94','67','68','69') and   t.send_file_name is not null and t.deal_code = '40101010' ");
			StringBuffer qssb = new StringBuffer();
			//3.2文件头
			qssb.append("QS"+"000000" +"06" + "00000103" + "FFFFFFFFFFFFFFFFFFFFFFFF");//Blackversion	N8	黑名单版本	YYYYMMDD
			qssb.append("\r\n");
			
			//3.3写记录
			//ftpOptions.get("host_ip"), 21, ftpOptions.get("user_name"), ftpOptions.get("pwd")
			qssb.append(bizid);
			qssb.append(clrDate.replaceAll("-", ""));
			if( !(zcinfo == null && jfinfo == null && tzinfo == null && tzjfinfo == null) ){
				if(zcinfo == null){
					qssb.append(Tools.tensileString("0", 8, true, "0"));
					qssb.append(Tools.tensileString("0", 10, true, "0"));
				}else{
					qssb.append(Tools.tensileString(Tools.processNull(zcinfo[0]), 8, true, "0"));
					qssb.append(Tools.tensileString(Tools.processNull(zcinfo[1]), 10, true, "0"));
				}
				if(jfinfo == null){
					qssb.append(Tools.tensileString("0", 8, true, "0"));
					qssb.append(Tools.tensileString("0", 10, true, "0"));
				}else{
					qssb.append(Tools.tensileString(Tools.processNull(jfinfo[0]), 8, true, "0"));
					qssb.append(Tools.tensileString(Tools.processNull(jfinfo[1]), 10, true, "0"));
				}
				if(tzinfo == null){
					qssb.append(Tools.tensileString("0", 8, true, "0"));
					qssb.append(Tools.tensileString("0", 10, true, "0"));
				}else{
					qssb.append(Tools.tensileString(Tools.processNull(tzinfo[0]), 8, true, "0"));
					qssb.append(Tools.tensileString(Tools.processNull(tzinfo[1]), 10, true, "0"));
				}
				if(tzjfinfo == null){
					qssb.append(Tools.tensileString("0", 8, true, "0"));
					qssb.append(Tools.tensileString("0", 10, true, "0"));
				}else{
					qssb.append(Tools.tensileString(Tools.processNull(tzjfinfo[0]), 8, true, "0"));
					qssb.append(Tools.tensileString(Tools.processNull(tzjfinfo[1]), 10, true, "0"));
				}
				qssb.append(Tools.tensileString("0", 8, true, "0"));
				qssb.append("\r\n");
				writeFile(ftpClient,qsFileName ,"download" ,qssb.toString(),ftpOptions);
			}
			
			
			
			//4，写清算文件记录
			//4.1定义文件名
			String nsFileName = "NS"+ clrDate.replaceAll("-", "") + "06" + 
							     bizid + "001";
			
			List nslist = this.findBySql(" select t.send_file_name from pay_offline_filename t where to_char(t.send_date,'yyyy-mm-dd') ='"+clrDate+"'"
								+ " and t.merchant_id = '" +bizid+"' and t.send_file_name like 'XF%' "
								+ "  group by t.send_file_name ORDER BY t.send_file_name ");
			StringBuffer nssb = new StringBuffer();
			//4.2文件头
			nssb.append("NS"+"06"+Tools.tensileString(Tools.processNull(nslist.size()+""), 8, true, "0") + "00000046" + "FFFFFFFFFFFFFFFFFFFFFFFF");//Blackversion	N8	黑名单版本	YYYYMMDD
			nssb.append("\r\n");
			//4.3写记录
			if(null!=nslist&&nslist.size()>0){
				for(int i=0;i<nslist.size();i++){
					String nsobj = (String)nslist.get(i);
					nssb.append(Tools.tensileString(Tools.processNull(nsobj), 30, false, " "));
					nssb.append(Tools.tensileString(Tools.processNull(clrDate.replaceAll("-", "")), 8, true, ""));
					nssb.append("FFFFFFFF");
					nssb.append("\r\n");
				}
			}
			writeFile(ftpClient, nsFileName,"download", nssb.toString(),ftpOptions);
		}catch(Exception e){
			writeLog("error：" + e.getMessage());
		}finally{
			if(ftpClient != null && ftpClient.isConnected()){
				try{
					ftpClient.logout();
					ftpClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
			}
		}
		
	}
	
	
	@Override
	public void savep_OfflineConsume(String bizid) throws CommonException {
		try {
			String biz_Id=bizid;
			List<Object> in = new ArrayList<Object>();
			in.add(biz_Id);
			in.add("0");
			List<Integer> out = new java.util.ArrayList<Integer>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			publicDao.callProc("pk_consume.p_offlineconsume",in,out);
		} catch (Exception e) {
			throw new CommonException("脱机数据处理出错："+e.getMessage());
		}
	}
	
	/**
	 * 写日志
	 */
	private void writeLog(String content) throws CommonException{
		String operation = System.getProperty("os.name").toUpperCase(Locale.ENGLISH);    
		if (operation.indexOf("AIX") != -1){
			try{
				content = new String(content.getBytes("GBK"), "ISO8859_1");
			}catch(Exception e){
				System.out.println(e.getMessage());
			}
		}
		try{
			File write = new File((DateUtil.getNowDate()).replace("-","").substring(0,6)+"rzcl.log");//公交处理每月一个文件
			FileWriter fw = new FileWriter(write,true);
			fw.write(DateUtil.getNowTime() + "---" + content + "\r\n");
			fw.close();
		}catch(Exception e){
			System.out.println(e.getMessage());
		}
	}


	
}
