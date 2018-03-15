package com.erp.task;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Component;

import com.erp.exception.CommonException;
import com.erp.service.OfflineDataProcessService;
import com.erp.service.OfflineDataService;
import com.erp.service.OfflineHlhtService;
import com.erp.service.UnionCardService;
import com.erp.util.JdbcUtils;
import com.erp.util.Tools;



/**
 * @author Administrator
 *
 */
@Component(value="offlineHlhtTask")
public class OfflineHlhtTask {
	public static Log log = LogFactory.getLog(OfflineHlhtTask.class);
	public static Logger logger = Logger.getLogger(OfflineHlhtTask.class);
	@Resource(name="offlineHlhtService")
	public OfflineHlhtService offlineHlhtService;
	@Resource(name="offlineDataService")
	public OfflineDataService offlineDataService;
	@Resource(name="unionCardService")
	public UnionCardService unionCardService;
	@Resource(name="OfflineDataProcessService")
	private  OfflineDataProcessService offlineDataProcessService;
	public static boolean dealState = false;
	//public static boolean doWork = false;
	public String url="";//ftp ip地址
	public String port="";//ftp 端口
	public String userName="";//登录用户名
	public String pwd="";//密码
	public String host_upload_path="";//此次操作上传文件的主目录
	public String host_download_path="";//此次操作下载文件的主目录
	public String host_history_path="";//此次操作历史文件目录
	public String host_repeat_path="";//重复文件目录
	public String host_errors_path="";//错误文件目录
	
	String[] bizids = new String[]{"041010010010002","041010010010001","041010010010011","100102100101030",
			"100102100101010","100102100101013","100102100101050"};
	String[] jsctsf = new String[] {"100102100101450"};
	//100102100101042 全国      100102100101043 上海  
	String clrDate = "";
	
	

	public void execute(){
		
		
		try {
			
			clrDate = (String)JdbcUtils.queryObject(JdbcUtils.openConnection(), "select clr_date from pay_clr_para", String.class);
			//clrDate = DateUtil.formatDate(DateUtils.addDays(DateUtil.parse("yyyy-MM-dd", clrDate), -1), "yyyy-MM-dd");
		} catch (Exception e1) {
			logger.error("获取清分日期出错有误:"+e1.getMessage());
			throw new CommonException(e1.getMessage());
		} 
		try {
			
		/*//第一步
			try{
				processOfflineDataJS();//停车收费消费文件处理
				}catch(Exception e){
				logger.error("嘉善停车收费数据处理有误:"+e.getMessage());
			}
		//第二步，验证TAC 
			try{
				processTacJS();//验证TAC
				}catch(Exception e){
				logger.error("验证TAC有误:"+e.getMessage());
			}*/
			//1,取本地卡在异地的消费数据DF文件 和 互联互通返回的DT文件。
			try {
				unionCardService.saveDownLoadUnionCardFile();
			} catch (Exception e) {
				logger.error("获取DF和DT有误:"+e.getMessage());
			}
			logger.info("完成第一步： 取本地卡在异地的消费数据DF文件 和 互联互通返回的DT文件");
			//2,进行DF、DT文件处理。
			try {
				offlineHlhtService.saveDFandDT_Handle("admin", clrDate);
			} catch (Exception e) {
				logger.error("处理DF和DT有误:"+e.getMessage());
			}
			logger.info("完成第二步：进行DF、DT文件处理");
			//3,调用扣款存储过程,写入FH表。
			try {
				p_OfflineConsume();
			} catch (Exception e) {
				logger.error("脱机扣款有误:"+e.getMessage());
			}
			logger.info("完成第三步：扣款存储过程,写入FH表");
			//嘉善停车收费,用扣款存储过程,写入FH表
			try {
				p_OfflineConsumeJS();
				logger.info("完成第三步：嘉善扣款存储过程,写入FH表");
			} catch (Exception e) {
				logger.error("嘉善脱机扣款有误:"+e.getMessage());
			}
			//4,处理SA中的本地卡在异地的消费数据。
			logger.info("完成第四步：处理SA中的本地卡在异地的消费数据 （暂时没有开发）");
			//5，上传SS,QS,NS文件
			try {
				p_SSNSQSFileR(this.clrDate);
			} catch (Exception e) {
				logger.error("上传脱机SS,QS,NS有误:"+e.getMessage());
			}
			logger.info("完成第五步：上传SS,QS,NS文件");
			//处理嘉善的;
			try {
				p_SSNSQSFileRJS(this.clrDate);
				logger.info("完成第五步：上传嘉善SS,QS,NS文件");
			} catch (Exception e) {
				logger.error("上传脱机SS,QS,NS有误:"+e.getMessage());
			}
			
			//6,返回GF文件。
			try {
				saveDownGF_File(clrDate);
			} catch (Exception e) {
				logger.error("上传脱机GF文件有误:"+e.getMessage());
			}
			logger.info("完成第六步：返回GF文件");
			
			//7,上传FH文件。
			try {
				unionCardService.saveUploadUnionCardFh("2000", true, clrDate);
			} catch (Exception e) {
				logger.error("上传上海FH文件有误:"+e.getMessage());
			}
			try {
				unionCardService.saveUploadUnionCardFh("2000", false, clrDate);
			} catch (Exception e) {
				logger.error("上传全国FH文件有误:"+e.getMessage());
			}
			logger.info("完成第七步：上传FH文件");
			logger.info("完成第八步：上传可以文件（暂时未开发）");
		} catch (Exception e) {
			logger.error("脱机数据处理出错:"+e.getMessage());
		}
	}
	
	 /**=======================================================================================
	**脱机数据处理
	**av_in: 各字段以|分割
	**       1biz_id    商户号
	**拒付原因:00－卡片发行方调整01－tac码错02－数据非法03－数据重复04－灰记录05－金额不足06-测试数据09调整拒付10正常数据
  =======================================================================================*/
	@SuppressWarnings("unchecked")
	public void p_OfflineConsume(){
		DefaultFTPClient.writeLog("开始脱机数据处理...");
		try{
			for (int i = 0; i < bizids.length; i++) {
				offlineHlhtService.savep_OfflineConsume(bizids[i]);
			}
		}catch(Exception e){
			logger.error(e);
			DefaultFTPClient.writeLog("脱机数据处理出现错误！" + e.getMessage());
		}finally{
			DefaultFTPClient.writeLog("结束脱机数据处理...");
		}
	}
	/**
	 * 嘉善停车收费脱机数据处理
	 */
	@SuppressWarnings("unchecked")
	public void p_OfflineConsumeJS(){
		DefaultFTPClient.writeLog("开始脱机数据处理...");
		try{
			for (int i = 0; i < jsctsf.length; i++) {
				offlineHlhtService.savep_OfflineConsume(jsctsf[i]);
			}
		}catch(Exception e){
			logger.error(e);
			DefaultFTPClient.writeLog("脱机数据处理出现错误！" + e.getMessage());
		}finally{
			DefaultFTPClient.writeLog("结束脱机数据处理...");
		}
	}
	
	/**
	 * 写拒付（SS）、清算(QS)、清算文件明细(NS)  文件
	 */
	public void p_SSNSQSFileR(String clrDate){
		DefaultFTPClient.writeLog("开始上传拒付（SS）、清算(QS)、清算文件明细(NS)  文件...");
		try{
			List<Map<String,String>>  list  = initBizInfo();
			for (int i = 0; i < list.size(); i++) {
				Map map = list.get(i);
				String bizid = (String)map.get("bizid");
				initFtpPara(Tools.processNull(map.get("ftpconfig")));
				offlineHlhtService.savep_SSNSQSFileR(bizid,url,port,userName,pwd,host_download_path,clrDate);
			}
		}catch(Exception e){
			logger.error(e);
			DefaultFTPClient.writeLog("脱机数据处理出现错误！" + e.getMessage());
		}finally{
			DefaultFTPClient.writeLog("结束上传拒付（SS）、清算(QS)、清算文件明细(NS)  文件...");
		}
	}
	
	/**
	 * 写嘉善停车收费拒付（SS）、清算(QS)、清算文件明细(NS)  文件 
	 */
	public void p_SSNSQSFileRJS(String clrDate){
		DefaultFTPClient.writeLog("开始上传嘉善拒付（SS）、清算(QS)、清算文件明细(NS)  文件...");
		try{
			List<Map<String,String>>  list  = initJSBizInfo();//嘉善合作机构编号
			for (int i = 0; i < list.size(); i++) {
				Map map = list.get(i);
				String bizidjs = (String)map.get("bizidjs");
				initFtpPara(Tools.processNull(map.get("ftpconfig")));
				offlineHlhtService.savep_SSNSQSFileRJS(bizidjs,url,port,userName,pwd,host_download_path,clrDate);
			}
		}catch(Exception e){
			logger.error(e);
			DefaultFTPClient.writeLog("脱机数据处理出现错误！" + e.getMessage());
		}finally{
			DefaultFTPClient.writeLog("结束上传嘉善拒付（SS）、清算(QS)、清算文件明细(NS)  文件...");
		}
	}
	
	public void saveDownGF_File(String clrDate){
		try{
			List<Map<String,String>>  list  = initBizInfo();
			for (int i = 0; i < list.size(); i++) {
				Map map = list.get(i);
				String bizid = (String)map.get("bizid");
				offlineHlhtService.saveDownGF_File(bizid, clrDate, map.get("ftpconfig").toString());
			}
		}catch(Exception e){
			logger.error(e);
			DefaultFTPClient.writeLog("脱机数据处理出现错误！" + e.getMessage());
		}finally{
			DefaultFTPClient.writeLog("结束上传Gf文件...");
		}
	}
	
	/**
	 * FTP参数信息初始化
	 * Description <p>TODO</p>
	 * @param ftp_use
	 * @throws CommonException
	 */
	public void initFtpPara(String ftp_use) throws CommonException{
		List ftpPara;
		try {
			ftpPara = JdbcUtils.queryMapList(JdbcUtils.openConnection(), "select t.ftp_para_name,t.ftp_para_value from SYS_FTP_CONF t where t.ftp_use = '" + ftp_use + "'");
		} catch (Exception e) {
			logger.error("获取清分日期出错有误:"+e.getMessage());
			throw new CommonException(e.getMessage());
		}
	    //offlineDataProcessService.findBySql("select t.ftp_para_name,t.ftp_para_value from SYS_FTP_CONF t where t.ftp_use = '" + ftp_use + "'");
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
		}
	}
	
	/*String[] bizids = new String[]{"041010010010002","041010010010001","041010010010011","100102100101030",
			"100102100101010","100102100101013","100102100101050"};*/
	public List<Map<String,String>> initBizInfo() throws CommonException{
		List<Map<String,String>> list = new ArrayList<Map<String,String>>();
		for (int i = 0; i < bizids.length; i++) {
			Map<String,String> map = new HashMap<String,String>();
			map.put("bizid", bizids[i]);
			if(bizids[i].equals("041010010010002")){
				map.put("ftpconfig", "gj_041010010010002");
			}else if(bizids[i].equals("041010010010001")){
				map.put("ftpconfig", "gj_041010010010001");
			}else if(bizids[i].equals("041010010010011")){
				map.put("ftpconfig", "gj_041010010010011");
			}else if(bizids[i].equals("100102100101030")){
				map.put("ftpconfig", "gj_100102100101030");
			}else if(bizids[i].equals("100102100101010")){
				map.put("ftpconfig", "gj_100102100101010");
			}else if(bizids[i].equals("100102100101013")){
				map.put("ftpconfig", "gj_100102100101013");
			}else if(bizids[i].equals("100102100101050")){
				map.put("ftpconfig", "gj_100102100101050");
			}else if(bizids[i].equals("100102100101450")){
				map.put("ftpconfig", "tcsf_100102100101450");
			}
			/*if(bizids[i].equals("000001000009999")||bizids[i].equals("000000705000201")){
				map.put("ishlhtbiz", "0");
			}else{
				map.put("ishlhtbiz", "1");
			}*/
			/*if(bizids[i].equals("000001000009999")){
				map.put("ishlhtbiz", "0");
			}else{
				map.put("ishlhtbiz", "1");
			}*/
			list.add(map);
		}
		return list;
	}
	
	public List<Map<String,String>> initJSBizInfo() throws CommonException{
		List<Map<String,String>> list = new ArrayList<Map<String,String>>();
		for (int i = 0; i < jsctsf.length; i++) {
			Map<String,String> map = new HashMap<String,String>();
			map.put("bizidjs", jsctsf[i]);
			if(jsctsf[i].equals("100102100101450")){
				map.put("ftpconfig", "tcsf_100102100101450");
			}
			list.add(map);
		}
		return list;
	}
	
	
	/**
	 * 处理嘉善停车收费
	 */
	public void processOfflineDataJS(){
		DefaultFTPClient defaultFTPClient = null;
		try{
			//1.判断当前任务是否正在处理
			DefaultFTPClient.writeLog("开始处理嘉善停车收费离线数据文件...");
			if(dealState){
				DefaultFTPClient.writeLog("正在处理嘉善停车收费离线数据文件,本次执行取消...");
				return;
			}
			//2.更新当前任务状态正在执行
			dealState = true;
			/*//3.获取指定商户的FTP配置信息
			String ip = offlineDataProcessService.getSysConfigurationParameters("tcsf_ftp_ip");//XF消费文件所在FTP地址
			String user = offlineDataProcessService.getSysConfigurationParameters("tcsf_ftp_user");//FTP用户名
			String pwd = offlineDataProcessService.getSysConfigurationParameters("tcsf_ftp_password");//FTP密码
			String biz_Id = offlineDataProcessService.getSysConfigurationParameters("BIZ_ID_TCSF");//商户BizId*/	
			String ip ="10.82.21.184";//XF消费文件所在FTP地址
			String user ="bus_tcsf";//FTP用户名
			String pwd = "1qaz2wsx";//FTP密码
			String biz_Id ="100102100101450";//商户BizId
			if(Tools.processNull(ip).equals("") || Tools.processNull(user).equals("") || Tools.processNull(pwd).equals("") || Tools.processNull(biz_Id).equals("")){
				throw new CommonException("商户FTP配置信息不完整,无法进行文件处理." + (!Tools.processNull(biz_Id).equals("") ? biz_Id : ""));
			}
			//4.获取FTP目录结构
			String upload = "upload";
			String historyfiles = "historyfiles";
			String gj_ftp_repeat = "repeat";
			String gj_ftp_errors = "errors";
			if(Tools.processNull(upload).equals("")){
				throw new CommonException("商户【" + biz_Id + "】文件存放【上传目录】不能为空！");
			}
			if(Tools.processNull(historyfiles).equals("")){
				throw new CommonException("商户【" + biz_Id + "】文件存放【历史目录】不能为空！");
			}
			if(Tools.processNull(gj_ftp_repeat).equals("")){
				throw new CommonException("商户【" + biz_Id + "】文件存放【重复文件目录】不能为空！");
			}
			if(Tools.processNull(gj_ftp_errors).equals("")){
				throw new CommonException("商户【" + biz_Id + "】处理【失败文件目录】不能为空！");
			}
			//5.创建FTP连接获取目录下的文件列表
		    defaultFTPClient = new DefaultFTPClient();
			boolean isCanConn = defaultFTPClient.toConnect(ip,21);
			if(!isCanConn){
				return;//FTP连接失败
			}
			boolean isCanLogin = defaultFTPClient.toLogin(user,pwd);
			if(!isCanLogin){
				return;//FTP登陆失败
			}
			defaultFTPClient.setFileType(FTPClient.BINARY_FILE_TYPE);
			defaultFTPClient.changeWorkingDirectory("/");
			List<String> fileNameList = defaultFTPClient.listNames("/" + upload + "/" ,2000);
			//Thread.sleep(60000 * 3);
			if(fileNameList != null && fileNameList.size() > 0){
				Iterator<String> its = fileNameList.iterator();
				while(its.hasNext()){
					try{
						String tempFileName = its.next();
						offlineDataProcessService.saveProcessDataJS(defaultFTPClient,biz_Id,"",tempFileName,upload,historyfiles,gj_ftp_repeat,gj_ftp_errors);
						//doWork = true;
					}catch(Exception e){
						DefaultFTPClient.writeLog(e.getMessage());
					}
				}
			}
		}catch(Exception e){
			DefaultFTPClient.writeLog(e.getMessage());
		}finally{
			if(defaultFTPClient != null && defaultFTPClient.isConnected()){
				try{
					defaultFTPClient.logout();
					defaultFTPClient.disconnect();
				}catch(IOException e){
					e.printStackTrace();
				}
			}
			dealState = false;
			DefaultFTPClient.writeLog("结束处理嘉善停车收费离线数据文件...");
		}
	}
	
	
	//验证TAC
		@SuppressWarnings("unchecked")
		public void processTacJS(){
			DefaultFTPClient.writeLog("开始验证消费数据TAC...");
			try{
				offlineDataProcessService.saveCheckOffineDataTacJS();
			}catch(Exception e){
				logger.error(e);
				DefaultFTPClient.writeLog("验证XF消费数据 " + "TAC出现错误！" + e.getMessage());
			}finally{
				DefaultFTPClient.writeLog("结束验证消费数据TAC...");
			}
		}

}
