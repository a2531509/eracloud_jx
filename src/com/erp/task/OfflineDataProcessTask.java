package com.erp.task;

import java.io.IOException;
import java.util.Iterator;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.net.ftp.FTPClient;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Component;

import com.erp.exception.CommonException;
import com.erp.service.OfflineDataProcessService;
import com.erp.util.Arith;
import com.erp.util.NumberUtil;
import com.erp.util.Tools;

/**
 * 所有的脱机消费文件入全都由汤伟忠来代理处理。
 * @category 公交消费文件处理
 * @author yangn
 * @version 1.0
 */
@Component(value="offlineDataProcessTask")
public class OfflineDataProcessTask{
	public static Logger logger = Logger.getLogger(OfflineDataProcessTask.class);
	@Resource(name="OfflineDataProcessService")
	private  OfflineDataProcessService offlineDataProcessService;
	public static boolean dealState = false;
	public void execute(){
		String starttime = System.currentTimeMillis() + "";
		//第一步，处理海宁城管公交脱机数据 
		/*try{
			processOfflineData();//海宁城管公交消费文件处理
		}catch(Exception e){
			logger.error("海宁城管公交脱机数据处理有误:"+e.getMessage());
		}finally{
			String endtime = System.currentTimeMillis() + "";
			logger.fatal("本次(海宁城管公交)脱机数据处理耗费了" + NumberUtil.scale(Arith.div(Arith.sub(endtime,starttime),1000*60 + ""),3) + "分钟.");
		}*/
		try{
			offlineDataProcessService.saveOffineData_Zxc();//自行车消费文件处理
		}catch(Exception e){
			logger.error("自行车开通与黑名单文件处理有误:"+e.getMessage());
		}finally{
			String endtime = System.currentTimeMillis() + "";
			logger.fatal("本次自行车开通与黑名单文件处理耗费了" + NumberUtil.scale(Arith.div(Arith.sub(endtime,starttime),1000*60 + ""),3) + "分钟.");
		}
		/*//第三步，验证TAC 
		try{
			//processTac();//验证TAC
		}catch(Exception e){
			logger.error("验证TAC有误:"+e.getMessage());
		}*/
         // 第222222222222步，验证账户处理
		/*try{
			offlineDataProcessService.p_OfflineConsume();
		}catch(Exception e){
			logger.error("公交脱机入账户处理有误:"+e.getMessage());
		}
		try{
			offlineDataProcessService.p_OfflineConsume_Zxc();
		}catch(Exception e){
			logger.error("自行车脱机入账户处理有误:"+e.getMessage());
		}
		try{
			offlineDataProcessService.p_OfflineConsume_hncg();
		}catch(Exception e){
			logger.error("海宁城管脱机入账户处理有误:"+e.getMessage());
		}*/
		
		
		
	}
	/**
	 * 处理公交脱机数据 
	 */
	public void processOfflineData(){
		DefaultFTPClient defaultFTPClient = null;
		try{
			//1.判断当前任务是否正在处理
			DefaultFTPClient.writeLog("开始处理公交离线数据文件...");
			if(dealState){
				DefaultFTPClient.writeLog("正在处理离线数据文件,本次执行取消...");
				return;
			}
			//2.更新当前任务状态正在执行
			dealState = true;
			//3.获取指定商户的FTP配置信息
			String ip = offlineDataProcessService.getSysConfigurationParameters("hncg_ftp_ip");//XF消费文件所在FTP地址
			String user = offlineDataProcessService.getSysConfigurationParameters("hncg_ftp_user");//FTP用户名
			String pwd = offlineDataProcessService.getSysConfigurationParameters("hncg_ftp_password");//FTP密码
			String biz_Id = offlineDataProcessService.getSysConfigurationParameters("BIZ_ID_HNCG");//商户BizId
			if(Tools.processNull(ip).equals("") || Tools.processNull(user).equals("") || Tools.processNull(pwd).equals("") || Tools.processNull(biz_Id).equals("")){
				throw new CommonException("商户FTP配置信息不完整,无法进行文件处理." + (!Tools.processNull(biz_Id).equals("") ? biz_Id : ""));
			}
			//4.获取FTP目录结构
			String upload = offlineDataProcessService.getSysConfigurationParameters("hncg_ftp_upload");
			String historyfiles = offlineDataProcessService.getSysConfigurationParameters("hncg_ftp_history");
			String gj_ftp_repeat = offlineDataProcessService.getSysConfigurationParameters("hncg_ftp_repeat");
			String gj_ftp_errors = offlineDataProcessService.getSysConfigurationParameters("hncg_ftp_error");
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
						offlineDataProcessService.saveProcessData(defaultFTPClient,biz_Id,"",tempFileName,upload,historyfiles,gj_ftp_repeat,gj_ftp_errors);
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
			DefaultFTPClient.writeLog("结束处理公交离线数据文件...");
		}
	}
	
	
	//验证TAC
	@SuppressWarnings("unchecked")
	public void processTac(){
		DefaultFTPClient.writeLog("开始验证消费数据TAC...");
		try{
			offlineDataProcessService.saveCheckOffineDataTac();
		}catch(Exception e){
			logger.error(e);
			DefaultFTPClient.writeLog("验证XF消费数据 " + "TAC出现错误！" + e.getMessage());
		}finally{
			DefaultFTPClient.writeLog("结束验证消费数据TAC...");
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
			offlineDataProcessService.p_OfflineConsume();
		}catch(Exception e){
			logger.error(e);
			DefaultFTPClient.writeLog("脱机数据处理出现错误！" + e.getMessage());
		}finally{
			DefaultFTPClient.writeLog("结束脱机数据处理...");
		}
	}
	

	

}