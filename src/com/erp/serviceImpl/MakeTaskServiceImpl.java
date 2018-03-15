package com.erp.serviceImpl;

import java.io.ByteArrayInputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.apache.commons.net.ftp.FTPClientConfig;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.CardApply;
import com.erp.model.CardApplyTask;
import com.erp.model.CardConfig;
import com.erp.model.CardTaskBatch;
import com.erp.model.CardTaskList;
import com.erp.model.CardTaskListWs;
import com.erp.model.SysActionLog;
import com.erp.model.SysPara;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.AccAcountService;
import com.erp.service.CardApplyService;
import com.erp.service.MakeTaskService;
import com.erp.task.DefaultFTPClient;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.Sys_Code;
import com.erp.util.Tools;

@Service("makeTaskService")
@SuppressWarnings({"rawtypes","unchecked"})
public class MakeTaskServiceImpl extends BaseServiceImpl implements MakeTaskService {
	
	private static final Logger logger = Logger.getLogger(MakeTaskServiceImpl.class);

	public AccAcountService accACountService;
	public CardApplyService cardApplyService;
	public String url="";//ftp ip地址
	public String port="";//ftp 端口
	public String userName="";//登录用户名
	public String pwd="";//密码
	public String host_upload_path="";//此次操作上传文件的主目录
	public String host_download_path="";//此次操作下载文件的主目录
	public String host_history_path="";//此次操作历史文件目录
	@Autowired
	public void setAccACountService(AccAcountService accACountService) {
		this.accACountService = accACountService;
	}
	@Autowired
	public void setCardApplyService(CardApplyService cardApplyService) {
		this.cardApplyService = cardApplyService;
	}	
	@Override
	public String saveTaskBack(SysActionLog actionLog, Users user,
			String[] taskId) throws CommonException {
		String listTaskId="";//所要取消的所有任务ID，连接成字符串
		try{
			
			for(int i=0;i<taskId.length;i++){
				//判断该任务是否可以回退
				CardApplyTask cmCardTask =(CardApplyTask)this.findOnlyRowByHql("from CardApplyTask a   where a.taskId='"+taskId[i]+"'");
				if (!cmCardTask.getTaskState().equals(Constants.TASK_STATE_YSC)){
					throw new CommonException("需要取消的任务必须为‘任务已生成’状态，否则不允许取消！");
				}
				publicDao.doSql("delete from card_task_list l where l.task_id='"+cmCardTask.getTaskId()+"'");
				publicDao.doSql("delete from card_apply_task t where t.task_id='"+cmCardTask.getTaskId()+"'");
				
				//申领信息更新到初始状态
				String exeSql = "update card_apply a set a.task_id='',apply_state='"+Constants.APPLY_STATE_YZX+"'";
				exeSql += " where a.task_id = '" + cmCardTask.getTaskId() +"' ";
				listTaskId += "%"+cmCardTask.getTaskId();
				publicDao.doSql(exeSql);
			}
			actionLog.setMessage("取消制卡任务,任务号:"+listTaskId);
			publicDao.save(actionLog);//保存业务日志
		}catch(Exception e){
			throw new CommonException("制卡任务取消出错！",e);
		}
		return null;
	}
	
	
	@Override
	/**
	 * 1，获取此次导出的批次号，2，发送文件给卫计委  3，更新任务批次号  
	 */
	public String saveexportTaskToWjw(SysActionLog actionLog, Users user,
			String[] taskId) throws CommonException {
		String isRight="1";//成功失败标志 1 成功，0 失败
		logger.info("====================结束ftp任务导出操作处理================");
		try {
			//1-----》获取批次信息
			CardTaskBatch taskBatch = new CardTaskBatch();
			String batchId = this.getSequenceByName("seq_cm_card_task_batch");
			taskBatch.setBatchId(batchId);
			taskBatch.setSendtowjwUserId(user.getUserId());
			taskBatch.setSendtowjwDate(actionLog.getDealTime());
			StringBuffer sbline=new StringBuffer("");
			//2-----》发送卫计委文件
			sbline.append("batch_id|task_id|data_seq|client_id|name|sex|cert_typed|cert_no|"+Constants.NEWLINE);
			int icount = 0;
			for(int i=0;i<taskId.length;i++){
				List taskcontent = publicDao.findBySQL("select "+batchId+"||'|'||t.task_id"+
										"||'|'||t.data_seq||'|'||t.CUSTOMER_ID||'|'||t.name||'|'||"+
										"t.sex||'|'||decode(t.cert_type,'1','01',2,'02','3',"
										+ "'03','4','04','5','05','6','10')||'|'||t.cert_no||'|' from card_task_list t where task_id='"+taskId[i]+"'");
				icount+=taskcontent.size();
				for(int j=0;j<taskcontent.size();j++){
					sbline.append(taskcontent.get(j)+Constants.NEWLINE);
				}
			}
			String fileName="全功能卡"+"_"+taskBatch.getBatchId()+"_"+DateUtil.formatDate(actionLog.getDealTime(), "yyyyMMdd")+
					"_"+DateUtil.formatDate(actionLog.getDealTime(), "HHmmss")+"_wexp.txt";
			//只有查询到数据的时候才进行ftp的上传
			if(icount!=0){
				ByteArrayInputStream is = new ByteArrayInputStream(sbline.toString().getBytes("GB2312"));
				//获取卫计委ftp信息 SYS_FTP_CONF 表下的 ftp_use=make_card_task_to_wjw 的所有内容
				//文件名称为“卡类型（中文）+‘_’ +批次号+ ‘_’ + 生成日期(8位) + 生成时间(6位) +‘_wexp’.txt”
				initFtpPara("make_card_task_to_wjw");
				DefaultFTPClient.uploadFile(url, Integer.parseInt(port),userName, pwd, host_upload_path, fileName, is);
				System.gc();
			}
//			ByteArrayInputStream is = new ByteArrayInputStream(sbline.toString().getBytes("GBK"));
//			DefaultFTPClient.uploadFile(url, Integer.parseInt(port),userName, pwd, host_upload_path, "2222.txt", is);
			//3------》更新任务的批次号
			taskBatch.setBatchId(batchId);
			this.rwdc(taskId, taskBatch, user.getUserId(), actionLog, true, Constants.TASK_STATE_YFWJW,fileName);
			logger.info("===================结束ftp任务导出操作处理================批次为："+taskBatch);
		} catch (Exception e) {
			isRight="0";
			logger.info("===================ftp导出卫计委文件出错================："+e.getMessage());
			throw new CommonException("导出卫计委文件出错"+e.getMessage());
			
		}
		return isRight;
	}

	@Override
	public String saveimportTaskReByWjw(SysActionLog actionLog, Users user) throws CommonException {
		String isRight="1";
		logger.info("===============================================================================================");
		logger.info("====================开始导入卫计委返回信息================");
		try {
			//步骤 1，连接卫生系统的ftp 验证ftp文件名是否正确，获取list形式的列表文件
			//步骤 2，循环list的数据将导出任务的明细数据修改为相应的状态
			initFtpPara("make_card_task_to_wjw");
			DefaultFTPClient ftpClient = new DefaultFTPClient();
			ftpClient.setControlEncoding("GBK");
			FTPClientConfig conf = new FTPClientConfig(FTPClientConfig.SYST_NT);
			conf.setServerLanguageCode("zh");
			ftpClient.connect(url, Integer.parseInt(port));
			ftpClient.login(userName, pwd);
			ftpClient.enterLocalPassiveMode();
			List list = ftpClient.listNames(host_download_path, 100);
			if(list==null || list.size()<=0){
				isRight="2";
				logger.info("========没有文件需要获取，卫计委没有发送文件到指定ftp目录！========");
				throw new CommonException("没有文件需要获取，卫计委没有发送文件到指定ftp目录！");
			}
			int count_shtg=0;
			int count_shbtg=0;
			for(int i=0;i<list.size();i++){
				//判断文件名是否正确，“卡类型（中文）+‘_’ +批次号+ ‘_’ + 生成日期(8位) + 生成时间(6位) +‘_wret’.txt
				//判断批次号和文件后缀是否正确
				String fileNamebywjw =  list.get(i).toString();
				logger.info("========开始处理卫计委导入"+fileNamebywjw+"文件！========");
				BigDecimal count_msg = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from card_task_batch b where b.BATCH_ID='"+list.get(i).toString().split("\\_")[1]+"'");
				if(fileNamebywjw.indexOf("_wret.txt")>0&&count_msg.intValue()>=1){
					ftpClient.changeWorkingDirectory(host_download_path);
					List<String> fileContent= ftpClient.getFileContent(list.get(i).toString());
					//根据文件名获取批次号
					if(fileContent!=null){
						String batch_id = list.get(i).toString().split("\\_")[1];
						if(fileContent!=null&&fileContent.size()>=2){
							//开始执行步骤2
							//batch_id|task_id|data_seq|client_id|name|sex|cert_typed|cert_no|check_flag|refuse_reson|
							//ws_card_type|ws_version|ws_orgname|ws_orgid|ws_certificate|ws_opertime|ws_certno|ws_safety_code|
							//ws_makeno|ws_citycode|ws_name|ws_sex|ws_nation|ws_birthday|ws_certno|ws_photo|ws_valatedate|ws_mobino|
							//ws_teleno|ws_paywayone|ws_paywaytwo|ws_paywaythree|ws_addresstypeone|ws_addressone|ws_addresstypetwo|
							//ws_addressttwo|ws_education|ws_ marriage|ws_ occupation|ws_certtype|ws_certno|ws_healthno|ws_sbcardno|ws_abono|ws_rhno
							for(int j=1;j<fileContent.size();j++){
									if(!Tools.processNull(fileContent.get(j).split("\\|")).equals("")){
										String[] contents = fileContent.get(j).split("\\|",-1);
										//修改申领表信息---》修改任务状态表---》修改批次表
										if(Tools.processNull(contents[8]).equals("0")){
											count_shtg++;
											//更新申领表
											publicDao.doSql("update card_apply c set c.APPLY_STATE='"+Constants.APPLY_STATE_WJWSHTG+"'  where BUY_PLAN_ID = '"+Tools.processNull(contents[0])+"' and TASK_ID ='"+Tools.processNull(contents[1])+"'"
													+ " and APPLY_STATE='"+Constants.APPLY_STATE_YFWJW
													+ "' and CUSTOMER_ID ='"+Tools.processNull(contents[3])+"'");
											//录入卫计委制卡文件信息
											//从CARD_TASK_FILE_HEAD表中找到要插入的字段以及顺序 卫计委 
	//										String paraCardList = (String)this.findOnlyFieldBySql("select data_conf_value from where where card_type_catalog='100' and flag='0'");
											CardTaskList cardTaskList  = (CardTaskList)this.findOnlyRowByHql("from CardTaskList where dataSeq='"+contents[2]+"'");
											CardTaskListWs wsmx = (CardTaskListWs)this.findOnlyRowByHql("from CardTaskListWs where dataSeq ='"+contents[2]+"'");
											if(cardTaskList!=null){
												if(wsmx == null ){
													wsmx = new  CardTaskListWs();
													wsmx.setTaskId(cardTaskList.getTaskId());
													wsmx.setCustomerId(cardTaskList.getCustomerId());
													wsmx.setWsCardType(Tools.processNull(contents[10]));
													wsmx.setWsVersion(Tools.processNull(contents[11]));
													wsmx.setWsOrgname(Tools.processNull(contents[12]));
													wsmx.setWsOrgid(Tools.processNull(contents[13]));
													wsmx.setWsCertificate(Tools.processNull(contents[14]));
													wsmx.setWsOpertime(Tools.processNull(contents[15]));
													wsmx.setWsCertno1(Tools.processNull(contents[16]));
													wsmx.setWsSafetyCode(Tools.processNull(contents[17]));
													wsmx.setWsCardid(Tools.processNull(contents[18]));
													wsmx.setWsCitycode(Tools.processNull(contents[19]));
													wsmx.setWsName(Tools.processNull(contents[20]));
													wsmx.setWsSex(Tools.processNull(contents[21]));
													wsmx.setWsNation(Tools.processNull(contents[22]));
													wsmx.setWsBirthday(Tools.processNull(contents[23]));
													wsmx.setWsCertno2(Tools.processNull(contents[24]));
													wsmx.setWsPhoto(Tools.processNull(contents[25]));
													wsmx.setWsValatedate(Tools.processNull(contents[26]));
													wsmx.setWsMobino(Tools.processNull(contents[27]));
													wsmx.setWsTeleno(Tools.processNull(contents[28]));
													wsmx.setWsPaywayone(Tools.processNull(contents[29]));
													wsmx.setWsPaywaytwo(Tools.processNull(contents[30]));
													wsmx.setWsPaywaythree(Tools.processNull(contents[31]));
													wsmx.setWsAddresstypeone(Tools.processNull(contents[32]));
													wsmx.setWsAddressone(Tools.processNull(contents[33]));
													wsmx.setWsAddresstypetwo(Tools.processNull(contents[34]));
													wsmx.setWsAddressttwo(Tools.processNull(contents[35]));
													wsmx.setWsEducation(Tools.processNull(contents[36]));
													wsmx.setWsMarriage(Tools.processNull(contents[37]));
													wsmx.setWsOccupation(Tools.processNull(contents[38]));
													wsmx.setWsCerttype(Tools.processNull(contents[39]));
													wsmx.setWsCertno3(Tools.processNull(contents[40]));
													wsmx.setWsHealthno(Tools.processNull(contents[41]));
													wsmx.setWsSbcardno(Tools.processNull(contents[42]));
													wsmx.setWsAbono(Tools.processNull(contents[43]));
													wsmx.setWsRhno(Tools.processNull(contents[44]));
													publicDao.save(wsmx);
												}else{
													wsmx.setWsCardType(Tools.processNull(contents[10]));
													wsmx.setWsVersion(Tools.processNull(contents[11]));
													wsmx.setWsOrgname(Tools.processNull(contents[12]));
													wsmx.setWsOrgid(Tools.processNull(contents[13]));
													wsmx.setWsCertificate(Tools.processNull(contents[14]));
													wsmx.setWsOpertime(Tools.processNull(contents[15]));
													wsmx.setWsCertno1(Tools.processNull(contents[16]));
													wsmx.setWsSafetyCode(Tools.processNull(contents[17]));
													wsmx.setWsCardid(Tools.processNull(contents[18]));
													wsmx.setWsCitycode(Tools.processNull(contents[19]));
													wsmx.setWsName(Tools.processNull(contents[20]));
													wsmx.setWsSex(Tools.processNull(contents[21]));
													wsmx.setWsNation(Tools.processNull(contents[22]));
													wsmx.setWsBirthday(Tools.processNull(contents[23]));
													wsmx.setWsCertno2(Tools.processNull(contents[24]));
													wsmx.setWsPhoto(Tools.processNull(contents[25]));
													wsmx.setWsValatedate(Tools.processNull(contents[26]));
													wsmx.setWsMobino(Tools.processNull(contents[27]));
													wsmx.setWsTeleno(Tools.processNull(contents[28]));
													wsmx.setWsPaywayone(Tools.processNull(contents[29]));
													wsmx.setWsPaywaytwo(Tools.processNull(contents[30]));
													wsmx.setWsPaywaythree(Tools.processNull(contents[31]));
													wsmx.setWsAddresstypeone(Tools.processNull(contents[32]));
													wsmx.setWsAddressone(Tools.processNull(contents[33]));
													wsmx.setWsAddresstypetwo(Tools.processNull(contents[34]));
													wsmx.setWsAddressttwo(Tools.processNull(contents[35]));
													wsmx.setWsEducation(Tools.processNull(contents[36]));
													wsmx.setWsMarriage(Tools.processNull(contents[37]));
													wsmx.setWsOccupation(Tools.processNull(contents[38]));
													wsmx.setWsCerttype(Tools.processNull(contents[39]));
													wsmx.setWsCertno3(Tools.processNull(contents[40]));
													wsmx.setWsHealthno(Tools.processNull(contents[41]));
													wsmx.setWsSbcardno(Tools.processNull(contents[42]));
													wsmx.setWsAbono(Tools.processNull(contents[43]));
													wsmx.setWsRhno(Tools.processNull(contents[44]));
													publicDao.merge(wsmx);
												}
											}
										}else{
											//更新申领表
											count_shbtg++;
											publicDao.doSql("update card_apply c set c.APPLY_STATE='"+Constants.APPLY_STATE_WJWSHBTG+"',WJW_CHECKREFUSE_REASON='"+Tools.processNull(contents[9])+"'  where BUY_PLAN_ID = '"+Tools.processNull(contents[0])+"' and TASK_ID ='"+Tools.processNull(contents[1])+"'"
													+ " and CUSTOMER_ID ='"+Tools.processNull(contents[3])+"' and c.apply_state='"+Constants.APPLY_STATE_YFWJW+"'");
										}
									}
								}
								
							//更新任务表
							publicDao.doSql("update CARD_APPLY_TASK t set t.TASK_STATE='"+Constants.TASK_STATE_WJWYSH+"',TASK_SUM='"+count_shtg+"' where MAKE_BATCH_ID='"+batch_id+"' and TASK_STATE='"+Constants.TASK_STATE_YFWJW+"'");
							//更新批次表
							publicDao.doSql("update CARD_TASK_BATCH set RECEIVEBYWJW_USER_ID='"+user.getUserId()+"',RECEIVEBYWJW_DATE=to_date('"+DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")+"','yyyy-mm-dd hh24:mi:ss')"
									+ " where BATCH_ID='"+batch_id+"'");
							//移走处理好的文件
//							ftpClient.rename(host_download_path+"/" + list.get(i).toString(), host_history_path+"/" + list.get(i).toString());
							DefaultFTPClient.reNameInFtp(url, 21, userName,pwd,host_download_path+"/" + list.get(i).toString(), host_history_path+"/" + list.get(i).toString());
							DefaultFTPClient.deleteFile(url, 21, userName, pwd, host_download_path, list.get(i).toString());
							logger.info("========结束处理卫计委导入"+fileNamebywjw+"文件！========");
						}
					}else{
						logger.info("========结束处理卫计委导入"+fileNamebywjw+"文件！========文件没有内容");
					}
					
				}else{
					logger.info("====================文件名为"+fileNamebywjw+"的卫计委返回文件文件名不正确，或对应批次不是一卡通导出================");
				}
				
			}
			ftpClient.logout();
			if (ftpClient.isConnected()) {
				try {
					ftpClient.disconnect();
				} catch (Exception e) {
					throw new CommonException("FTP断开连接异常:"
							+ e.getMessage());
				}
			}
			System.gc();
		} catch (Exception e) {
			logger.error("========开始处理卫计委导入文件出错！========"+e.getMessage());
			isRight="0";
			throw new CommonException("导入卫计委文件出错"+e.getMessage());
		}
		return null;
	}

	@Override
	public String saveexportTaskToBank(SysActionLog actionLog, Users user,String[] taskId,String makeBatchId,String bankId,String vendorId) throws CommonException {
		//文件名  卡类型（中文）+‘_’ +批次号+ ‘_’ + 生成日期(8位) + 生成时间(6位) +‘_’+卡商编号+‘_’+卡商名字+‘_’+银行编号+‘_’+银行名字+’_s’.txt
		String bankName = (String)this.findOnlyFieldBySql("select bank_name from base_bank where bank_id='"+bankId+"'");
		String vendorName = (String)this.findOnlyFieldBySql("select vendor_Name from base_vendor where vendor_Id='"+vendorId+"'");
		String fileName = "全功能卡"+"_"+makeBatchId+"_"+DateUtil.formatDate(actionLog.getDealTime(),"yyyyMMdd")
				+DateUtil.formatDate(actionLog.getDealTime(),"HHmmss")+"_"+vendorId+"_"+vendorName+"_"+bankId+"_"+bankName+"_s.txt";
		String headOne="task_id|card_type|bank_id|recordcount|taskaddr|serid|sername|companyid|company|region_name|street|community|";
		/*String headTwo="data_seq|task_id|client_id|photofilename|name|sex|cert_typed|cert_no|card_no|struct_main_type|"
				+ "struct_child_type|cardissuedate|validitydate|useflag|bursestartdate|bursevaliddate|bursebalance|"
				+ "ws_card_type|ws_ version|ws_orgname|ws_orgid|ws_certificate|ws_opertime|ws_certno|ws_safety_code|"
				+ "ws_makeno|ws_citycode|ws_name|ws_sex|ws_nation|ws_birthday|ws_certno|ws_photo|ws_valatedate|ws_mobino|"
				+ "ws_teleno|ws_paywayone|ws_paywaytwo|ws_paywaythree|ws_addresstypeone|ws_addressone|ws_addresstypetwo|"
				+ "ws_addressttwo|ws_education|ws_marriage|ws_occupation|ws_certtype|ws_certno|ws_healthno|ws_sbcardno|ws_abono|ws_rhno|";*/
		String headTwo="data_seq|task_id|client_id|photofilename|name|sex|cert_typed|cert_no|card_no|struct_main_type|"
		+ "struct_child_type|cardissuedate|validitydate|useflag|bursestartdate|bursevaliddate|bursebalance|";
		String splitStr ="----------";
		//构造数据
		try {
			logger.info("===============================================================================================");
			//1-----》按照任务进行数据的封装
			logger.info("========开始导出银行文件"+fileName+"========");
			List<CardApplyTask> list = this.findByHql("from CardApplyTask where makeBatchId ='"+makeBatchId+"' and taskState='"+Constants.TASK_STATE_WJWYSH+"'");
			if(list==null||list.size()<=0){
				throw new CommonException("该批次没有要生成的银行制卡文件！");
			}
			CardApplyTask task = null;
			//获取导出卫生字段 CARD_TASK_FILE_HEAD 表
			/*String ws_str = (String)this.findOnlyFieldBySql("select data_conf_value from CARD_TASK_FILE_HEAD t where t.card_type_catalog = '100'  and t.flag = '0'");
			if(Tools.processNull(ws_str).equals("")){
				throw new CommonException("银行导出头没有配置！");
			}*/
			StringBuffer sbline = new StringBuffer();
			sbline.append(headOne);
			sbline.append(Constants.NEWLINE);
			sbline.append(headTwo);
			sbline.append(Constants.NEWLINE);
			sbline.append(splitStr);
			sbline.append(Constants.NEWLINE);
			for(int i=0;i<list.size();i++){
				task = list.get(i);
				BigDecimal counttask = (BigDecimal)this.findOnlyFieldBySql("select count(1) from card_task_list t1,card_apply t2 where t1.customer_id = t2.customer_id and "
						+ "t1.task_id = t2.task_id and t2.apply_state ='"+Constants.APPLY_STATE_WJWSHTG+"' and t2.task_id='"+task.getTaskId()+"'");
				//只有任务下有数据才拼接字符串
				if(counttask.intValue()>0){
					sbline.append(task.getTaskId()+"|"+task.getCardType()+"|"+bankId+"|"+counttask.intValue()+"|"+task.getTaskName()+"|"+task.getBrchId()
							+"|"+Tools.processNull(this.findOnlyFieldBySql("select full_name from sys_branch where brch_id='"+task.getBrchId()+"'"))+"|"
							+Tools.processNull(task.getCorpId())+"|"
							+Tools.processNull(this.findOnlyFieldBySql("select h.corp_name from base_corp h where h.customer_id='"+task.getCorpId()+"'"))+"|"
							+Tools.processNull(this.findOnlyFieldBySql("select h.region_name from base_region h where h.region_id='"+task.getRegionId()+"'"))+"|"
							+Tools.processNull(this.findOnlyFieldBySql("select h.town_name from base_town h where h.town_id='"+task.getTownId()+"'"))+"|"
							+Tools.processNull(this.findOnlyFieldBySql("select h.comm_name from base_comm h where h.comm_id='"+task.getCommId()+"'"))+"|");
					sbline.append(Constants.NEWLINE);//换行
					//查询任务字段
					/*String sqlContent ="select a.data_seq,a.task_id,a.customer_id,a.photofilename,a.name,a.sex,decode(a.cert_type,'1','01','2','02','3','03','4','04','5','05','6','10'),"
							+ "a.cert_no,a.card_no,a.struct_main_type,nvl(a.struct_child_type,'00'),a.cardissuedate,a.validitydate,a.useflag,a.bursestartdate,a.bursevaliddate,a.bursebalance,"
							+ws_str+" from card_task_list a,card_apply b,card_task_list_ws w  where a.customer_id=b.customer_id and  a.customer_id = w.customer_id and b.customer_id = w.customer_id and "
							+ " a.task_id='"+Tools.processNull(task.getTaskId())+"' and b.task_id='"+Tools.processNull(task.getTaskId())+"' and w.task_id='"+Tools.processNull(task.getTaskId())+"'"
							+ " and b.apply_state='"+Constants.APPLY_STATE_WJWSHTG+"'";*/
					String sqlContent ="select a.data_seq,a.task_id,a.customer_id,a.photofilename,a.name,a.sex,decode(a.cert_type,'1','01','2','02','3','03','4','04','5','05','6','10'),"
							+ "a.cert_no,a.card_no,a.struct_main_type,nvl(a.struct_child_type,'00'),a.cardissuedate,a.validitydate,a.useflag,a.bursestartdate,a.bursevaliddate,a.bursebalance"
							+" from card_task_list a,card_apply b  where a.customer_id=b.customer_id and "
							+ " a.task_id='"+Tools.processNull(task.getTaskId())+"' and b.task_id='"+Tools.processNull(task.getTaskId())+"'"
							+ " and b.apply_state='"+Constants.APPLY_STATE_WJWSHTG+"' order by a.card_no ";
					List<Object[]>  listcontent = (List<Object[]>)this.findBySql(sqlContent);
					if(listcontent!=null&&listcontent.size()>=1){
						for(int j=0;j<listcontent.size();j++){
							Object[] obj = null;
							obj = listcontent.get(j);
							for(int k=0;k<obj.length;k++){
								sbline.append(Tools.processNull(obj[k])+"|");//添加卫生的导出数据
							}
							if(j != listcontent.size() -1){
								sbline.append(Constants.NEWLINE);
							}
						}
					}
					if(i!=list.size()-1){
						sbline.append(Constants.NEWLINE);
						sbline.append(splitStr);//添加分割符
						sbline.append(Constants.NEWLINE);
					}
				}
				
			}
			initFtpPara("make_card_task_to_bank_"+bankId);
			//2---->导出文件给银行
			ByteArrayInputStream is = new ByteArrayInputStream(sbline.toString().getBytes("GB2312"));
			DefaultFTPClient.uploadFile(url, 21, userName, pwd, host_upload_path, fileName, is);
			//3---->修改相关数据
			//修改任务状态---》修改申领表状态 --》修改批次表信息
			publicDao.doSql("update card_apply_task c set c.task_state='"+Constants.TASK_STATE_YFYH+"' where make_Batch_Id='"+makeBatchId+"'");
			publicDao.doSql("update card_apply set apply_state = '"+Constants.APPLY_STATE_YFBANK+"' where BUY_PLAN_ID='"+makeBatchId+"'"
					+ " and apply_state = '"+Constants.APPLY_STATE_WJWSHTG+"'");
			publicDao.doSql("update card_task_batch set SEND_USER_ID='"+user.getUserId()+"',SEND_DATE=to_date('"+DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")+"','yyyy-mm-dd hh24:mi:ss')  where BATCH_ID='"+makeBatchId+"'");
			logger.info("========结束导出银行文件"+fileName+"========");
			System.gc();
		} catch (Exception e) {
			//出错后删除ftp上的文件，上传ftp是不受事务控制的
			DefaultFTPClient.deleteFile(url,  Integer.parseInt(port), userName, pwd, host_upload_path, fileName);
			logger.info("========导出银行文件"+fileName+"出错："+e.getMessage()+"========");
			throw new CommonException("导出银行制卡文件出错："+e.getMessage());
		}
		return null;
	}
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
	public String saveexportTaskToBank_Temp(String[] taskId,String cardType,String bankId,String vendorId,Users user,SysActionLog actionLog) throws CommonException {
		String fileName = "";
		try {
			logger.error("...............................");
			logger.error("#开始生成市民卡银行审核文件");
			logger.error("#正在检查FTP配置信息");
			initFtpPara("make_card_task_to_bank_" + bankId);
			if(Tools.processNull(this.url).equals("")){
				throw new CommonException("获取ftp配置出错，ftp地址未配置，请联系系统管理员！");
			}else{
				logger.error("ip:" + this.url);
			}
			if(Tools.processNull(this.port).equals("")){
				throw new CommonException("获取ftp配置出错，ftp端口未配置，请联系系统管理员！");
			}else{
				logger.error("port:" + this.port);
			}
			if(Tools.processNull(this.userName).equals("")){
				throw new CommonException("获取ftp配置出错，ftp用户名未配置，请联系系统管理员！");
			}else{
				logger.error("name:" + this.userName);
			}
			if(Tools.processNull(this.pwd).equals("")){
				throw new CommonException("获取ftp配置出错，ftp密码未配置，请联系系统管理员！");
			}else{
				logger.error("pwd:" + this.pwd);
			}
			if(Tools.processNull(this.host_download_path).equals("")){
				throw new CommonException("获取ftp配置出错，ftp文件下载路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_download_path:" + this.host_download_path);
			}
			CardTaskBatch taskBatch = new CardTaskBatch();
			taskBatch.setBatchId(this.getSequenceByName("seq_cm_card_task_batch"));
			taskBatch.setSendtowjwUserId(user.getUserId());
			taskBatch.setSendtowjwDate(actionLog.getDealTime());
			taskBatch.setVendorId(vendorId);
			Long totNums = 0L;
			fileName = "SH" + "_" + taskBatch.getBatchId() + "_" + Tools.tensileString(bankId,15,false,"0") + "_" + DateUtil.formatDate(actionLog.getDealTime(),"yyyyMMddHHmmss");
			logger.error("生成银行审核文件名:" + fileName);
			actionLog.setDealCode(DealCode.PUBLICCARD_EXPORTTOYH);
			actionLog.setMessage("制卡数据导出到银行,批次号" + taskBatch.getBatchId());
			publicDao.save(actionLog);
			taskBatch.setDealNo(Integer.valueOf(actionLog.getDealNo() + ""));
			taskBatch.setMakeWay("1");
			taskBatch.setSendDate(actionLog.getDealTime());
			taskBatch.setSendUserId(actionLog.getUserId());
			publicDao.save(taskBatch);
			List<CardApplyTask> list = this.findByHql("from CardApplyTask where taskId in (" + Tools.getConcatStrFromArray(taskId,"'",",") + ") and taskState = '" + Constants.TASK_STATE_YSC + "'");
			if(list == null || list.size() <= 0){
				throw new CommonException("根据选定的任务编号，找不到对应任务信息！");
			}
			logger.error("开始写入文件需要审核数据");
			StringBuffer sbline = new StringBuffer();
			for(int i = 0;i < list.size();i++){
				CardApplyTask task = list.get(i);
				totNums = totNums + task.getTaskSum();
				StringBuffer execCardTaskListSql = new StringBuffer();
				execCardTaskListSql.append("SELECT l.data_seq,l.task_id,b.name,b.gender,decode(b.cert_type,'1','01','2','10','3','02','4','03','5','10','6','10','10') cert_type,");
				execCardTaskListSql.append("b.cert_no,b.nation,'CHN' country,");
				execCardTaskListSql.append("b.reside_addr,substr(b.cert_no,7,8) birthday,b.mobile_no,b.phone_no,b.letter_addr,b.corp_customer_id,p.corp_name,m.town_name,");
				execCardTaskListSql.append("n.comm_name,'' jhname,'' jhgender,'' jhcerttype,'' jhcertno,c.recv_brch_id,s.full_name ");
				execCardTaskListSql.append("FROM card_task_list l,card_apply c,base_personal b,base_corp p,base_town m,base_comm n,Sys_Branch s ");
				execCardTaskListSql.append("WHERE l.apply_id = c.apply_id AND c.customer_id = b.customer_id AND b.corp_customer_id = p.customer_id(+) AND ");
				execCardTaskListSql.append("b.town_id = m.town_id AND b.comm_id = n.comm_id AND c.recv_brch_id = s.brch_id ");
				execCardTaskListSql.append("and l.task_id = '" + task.getTaskId() + "'");
				List<Object[]> allRes = this.findBySql(execCardTaskListSql.toString());
				if(allRes != null && allRes.size() > 0){
					for(int m = 0;m < allRes.size();m++){
						Object[] tempRow = allRes.get(m);
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[0]),12,false," "));//任务明细号 12 左靠齐，右补空格
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[1]),32,false," "));//任务编号  32 左靠齐，右补空格
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[2]),30,false," "));//姓名  30 左靠齐，右补空格
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[3]),1,false," "));//性别 1 
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[4]),2,false," "));//证件类型 2
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[5]),18,false," "));//证件号码 18
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[6]),2,false," "));//民族 2
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[7]),3,false," "));//国国籍 3
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[8]),6,false," "));//出生地 6 待定
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[9]),8,false," "));//出生年月 8 
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[10]),11,false," "));//手机号码 11
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[11]),15,false," "));//联系电话 15
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[12]),60,false," "));//联系地址
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[13]),20,false," "));//单位编号 20
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[14]),80,false," "));//单位名称 80
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[15]),50,false," "));//乡镇街道 50
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[16]),50,false," "));//村社区 50
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[17]),60,false," "));//监护人姓名 50
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[18]),1,false," "));//监护人性别 1
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[19]),2,false," "));//监护人证件类型 2
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[20]),18,false," "));//监护人证件号码 18
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[21]),8,false," "));//领卡网点 8
						sbline.append(Tools.tensileStringByByte(Tools.processNull(tempRow[22]),50,false," "));//领卡网点名称
						sbline.append(Tools.tensileStringByByte(Tools.processNull("F"),50,false,"F"));//保留域 50
						sbline.append("\n");
					}
				}else{
					throw new CommonException("在导出任务【" + task.getTaskName() + "】时，找不到制卡明细信息或个人信息不完善！");
				}
				int updateCts = publicDao.doSql("update card_apply_task c set c.task_state = '" + Constants.TASK_STATE_YFYH + "',c.make_Batch_Id = '" + taskBatch.getBatchId() +
				"' ,c.bank_id = '" + bankId + "' where task_id = '" + task.getTaskId() + "' and c.task_state = '" + Constants.TASK_STATE_YSC  + "'");
				if(updateCts != 1){
					throw new CommonException("在导出任务【" + task.getTaskName() + "】时，更新任务状态不正确！");
				}
				updateCts = publicDao.doSql("update card_apply set apply_state = '"+Constants.APPLY_STATE_YFBANK + "',buy_plan_id = '" + taskBatch.getBatchId() +
				"' bank_id = '" + bankId + "' where task_id = '" + task.getTaskId() + "' and apply_state = '" + Constants.APPLY_STATE_RWYSC + "'");
				if(updateCts != task.getTaskSum()){
					throw new CommonException("在导出任务【" + task.getTaskName() + "】时，更新申领状态数量和任务数量不一致！");
				}
				logger.error("写入任务 " + task.getTaskId() + " " + task.getTaskName() + " 数量 " + task.getTaskSum() );
			}
			StringBuffer finalFileConts = new StringBuffer();
			finalFileConts.append("SH".toUpperCase() + Tools.tensileString(totNums + "",8,true,"0") + Tools.tensileString("589",8,true,"0"));
			finalFileConts.append(Tools.tensileString("F",10,true,"F") + "\n");
			finalFileConts.append(sbline);
			logger.error("文件生成成功,开始上传FTP:" + host_download_path + "/" + fileName);
			ByteArrayInputStream is = new ByteArrayInputStream(finalFileConts.toString().getBytes("GBK"));
			DefaultFTPClient ftpClient = new DefaultFTPClient();
			if(!ftpClient.toConnect(url,Integer.valueOf(port))){
				throw new CommonException("FTP连接失败！");
			}
			ftpClient.setControlEncoding("GBK");
			if(!ftpClient.toLogin(userName,pwd)){
				throw new CommonException("FTP登录失败！");
			}
			logger.error("当前工作目录" + ftpClient.printWorkingDirectory());
			if(!ftpClient.changeWorkingDirectory("/") || !ftpClient.changeWorkingDirectory(host_download_path)){
				throw new CommonException("FTP切换到目录" + host_download_path + "失败！");
			}
			if(!ftpClient.storeFile(fileName.toUpperCase(),is)){
				throw new CommonException("上传文件到FTP出现错误：请检查ftp路径设置及网络问题！");
			}
			logger.error("文件" + fileName + "上传成功");
			System.gc();
		}catch(Exception e){
			logger.error("导出银行审核文件" + fileName + "出现错误：" + e.getMessage());
			throw new CommonException("导出银行审核文件出现错误：" + e.getMessage());
		}finally{
			logger.error("结束导出银行文件！");
		}
		return null;
	}

	@Override
	public String saveimportTaskReByBank(SysActionLog actionLog, Users user,String bankIdimp)
			throws CommonException {
		String isRight="1";
		logger.info("===============================================================================================");
		logger.info("====================开始导入银行文件==================");
		try {
			//步骤 1----->初始话ftp目录----->获取该目录下所有文件---->循环每个文件获取明细数据
			initFtpPara("make_card_task_to_bank_"+bankIdimp);
			DefaultFTPClient ftpClient = new DefaultFTPClient();
			ftpClient.setControlEncoding("GBK");
			FTPClientConfig conf = new FTPClientConfig(FTPClientConfig.SYST_NT);
			conf.setServerLanguageCode("zh");
			ftpClient.connect(url, Integer.parseInt(port));
			ftpClient.login(userName, pwd);
			ftpClient.enterLocalPassiveMode();
			List list = ftpClient.listNames(host_download_path, 100);
			if(list==null || list.size()<=0){
				isRight="2";
				logger.info("========没有文件需要获取，银行没有发送文件到指定ftp目录！========");
				throw new CommonException("没有文件需要获取，银行没有发送文件到指定ftp目录！");
			}
			int count_shtg=0;
			int count_shbtg=0;
			for(int i=0;i<list.size();i++){
				
				//判断文件名是否正确，“卡类型（中文）+‘_’ +批次号+ ‘_’ + 生成日期(8位) + 生成时间(6位) +‘_wret’.txt
				//判断批次号和文件后缀是否正确
				String fileNamebybank =  list.get(i).toString();
				logger.info("========开始处理银行导入"+fileNamebybank+"文件！========");
				BigDecimal count_msg = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from card_task_batch c where c.BATCH_ID='"+list.get(i).toString().split("\\_")[1]+"'");
				if(fileNamebybank.indexOf("_bret.txt")>0&&count_msg.intValue()>=1){
					ftpClient.changeWorkingDirectory(host_download_path);
					List<String> fileContent= ftpClient.getFileContent(list.get(i).toString());
					//根据文件名获取批次号
					if(fileContent!=null){
						String batch_id = list.get(i).toString().split("\\_")[1];
						if(fileContent!=null&&fileContent.size()>=2){
							//开始执行步骤2 ----->开始处理到获取的文件----->修改申领表的记录为制卡中------->任务更新为制卡中------->批次表更新状态
							//batch_id|task_id|data_seq|client_id|name|sex|cert_typed|cert_no|check_flag|refuse_reson|
							for(int j=1;j<fileContent.size();j++){
								String[] contents = fileContent.get(j).split("\\|");
								if(Tools.processNull(contents[8]).equals("0")){
									count_shtg++;
									//更新申领表
									publicDao.doSql("update card_apply c set c.APPLY_STATE='"+Constants.APPLY_STATE_YHSHTG+"'  where BUY_PLAN_ID = '"+Tools.processNull(contents[0])+"' and TASK_ID ='"+Tools.processNull(contents[1])+"'"
											+ " and APPLY_STATE='"+Constants.APPLY_STATE_YFBANK
											+ "' and CUSTOMER_ID ='"+Tools.processNull(contents[3])+"'");
								}else{
									count_shbtg++;
									if(contents.length == 9){
										//更新申领表
										publicDao.doSql("update card_apply c set c.APPLY_STATE='"+Constants.APPLY_STATE_YHSHBTG+"',BANK_CHECKREFUSE_REASON=''  where BUY_PLAN_ID = '"+Tools.processNull(contents[0])+"' and TASK_ID ='"+Tools.processNull(contents[1])+"'"
												+ " and CUSTOMER_ID ='"+Tools.processNull(contents[3])+"' and APPLY_STATE='"+Constants.APPLY_STATE_YFBANK+"'");
									}else if(contents.length == 10){
										//更新申领表
										publicDao.doSql("update card_apply c set c.APPLY_STATE='"+Constants.APPLY_STATE_YHSHBTG+"',BANK_CHECKREFUSE_REASON='"+Tools.processNull(contents[9])+"'  where BUY_PLAN_ID = '"+Tools.processNull(contents[0])+"' and TASK_ID ='"+Tools.processNull(contents[1])+"'"
												+ " and CUSTOMER_ID ='"+Tools.processNull(contents[3])+"' and APPLY_STATE='"+Constants.APPLY_STATE_YFBANK+"'");
									}else{
										throw new CommonException("文件格式不正确：文件行数为："+count_shbtg);
									}
									
								}
							}
							//更新任务表
							publicDao.doSql("update CARD_APPLY_TASK c set c.TASK_STATE='"+Constants.TASK_STATE_YHYSH+"',TASK_SUM='"+count_shtg+"' where MAKE_BATCH_ID='"+batch_id+"' and TASK_STATE='"+Constants.TASK_STATE_YFYH+"'");
							//更新批次表
							publicDao.doSql("update CARD_TASK_BATCH c set c.RECEIVEBYBANK_USER_ID='"+user.getUserId()+"',RECEIVEBYBANK_DATE=to_date('"+DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")+"','yyyy-mm-dd hh24:mi:ss')"
									+ " where BATCH_ID='"+batch_id+"'");
							//移走处理好的文件
							DefaultFTPClient.reNameInFtp(url, 21, userName,pwd,host_download_path+"/" + list.get(i).toString(), host_history_path+"/" + list.get(i).toString());
							DefaultFTPClient.deleteFile(url, 21, userName, pwd, host_download_path, list.get(i).toString());
							logger.info("========结束处理银行导入"+fileNamebybank+"文件！========");
						}
					}else{
						logger.info("========结束处理银行入"+fileNamebybank+"文件！========文件没有内容");
					}
					
				}else{
					logger.info("====================文件名为"+fileNamebybank+"的银行返回文件文件名不正确，或对应批次不是一卡通导出================");
				}
				
			}
			ftpClient.logout();
			if (ftpClient.isConnected()) {
				try {
					ftpClient.disconnect();
				} catch (Exception e) {
					throw new CommonException("FTP断开连接异常:"
							+ e.getMessage());
				}
			}
			System.gc();
		} catch (Exception e) {
			logger.error("========导入银行文件出错！========"+e.getMessage());
			isRight="0";
			throw new CommonException("导入银行文件出错"+e.getMessage());
		}
		return null;
	}
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
	public String saveimportTaskReByBank_Temp(DefaultFTPClient ftpClient,String bankIdimp,String subDirPath,String fileName,String subHisDir,SysActionLog actionLog,Users user)throws CommonException {
		try {
			long totRows = 0L;
			long tempRows = 0L;
			String batchId = "";
			if(Tools.processNull(fileName).length() <= 35){
				throw new CommonException("文件" + fileName + "处理失败，文件名不正确！");
			}
			batchId = fileName.split("_")[1];
			if(fileName.length() >= 30 && batchId.equals(bankIdimp)){
				throw new CommonException("该文件" + fileName + "不是选定银行返回的审核文件");
			}
			BigDecimal count_msg = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from card_task_batch c where c.batch_id = '" + batchId + "'");
			if(fileName.toUpperCase().startsWith("RH") && count_msg.intValue() >= 1){
				List<String> fileContent = ftpClient.getFileContent(fileName);
				if(fileContent != null && fileContent.size() > 1){
					totRows = Long.valueOf(new String(fileContent.get(0).getBytes("GBK"),2,8));
					StringBuffer sb = new StringBuffer();
					for(int j = 1;j < fileContent.size();j++){
						int pos = 0;
						tempRows++;
						byte[] contents = fileContent.get(j).getBytes("GBK");
						sb.append("'insert into card_apply_bank_rh (res_flag,data_seq,task_id,name,gender,cert_type,cert_no,res_msg,resv_one,file_name,file_line_no,tot_rows,state,batch_id,deal_time) values (");
						sb.append("''" + Tools.processNull(getStringByByte(contents,pos,1)).trim() + "'',");//审核结果
						pos = pos + 1;
						sb.append("''" + Tools.processNull(getStringByByte(contents,pos,12)).trim() + "'',");//任务明细号
						pos = pos + 12;
						sb.append("''" + Tools.processNull(getStringByByte(contents,pos,32)).trim() + "'',");//任务号
						pos = pos + 32;
						sb.append("''" + Tools.processNull(getStringByByte(contents,pos,30)).trim() + "'',");//姓名
						pos = pos + 30;
						sb.append("''" + Tools.processNull(getStringByByte(contents,pos,1)).trim() + "'',");//性别
						pos = pos + 1;
						sb.append("''" + Tools.processNull(getStringByByte(contents,pos,2)).trim() + "'',");//证件类型
						pos = pos + 2;
						sb.append("''" + Tools.processNull(getStringByByte(contents,pos,18)).trim() + "'',");//证件号码
						pos = pos + 18;
						sb.append("''" + Tools.processNull(getStringByByte(contents,pos,200)).trim() + "'',");//失败原因
						pos = pos + 200;
						sb.append("''" + Tools.processNull(getStringByByte(contents,pos,20)).trim() + "'',");//保留字段
						sb.append("''" + fileName + "'',");//文件名称
						sb.append("" + j + ",");//行号
						sb.append("" + totRows + ",");//总条数
						sb.append("''1'',''");//状态
						sb.append(batchId + "'',sysdate");
						sb.append(")',");
						if((j + 1) % 500 == 0){
							publicDao.doSql("call PK_PUBLIC.p_DEALSQLBYARRAY(strArray(" + sb.substring(0,sb.length()-1) + "))");
							sb = new StringBuffer();
						}
					}
					if(totRows != tempRows){
						throw new CommonException("文件" + fileName + ",内容详细条数和头部设置的总条数不一致！");
					}
					if(!Tools.processNull(sb.toString()).equals("")){
						publicDao.doSql("call PK_PUBLIC.P_DEALSQLBYARRAY(strArray(" + sb.substring(0,sb.length()-1) + "))");
					}
					//调取过程
					StringBuffer execsql = new StringBuffer();
					execsql.append(batchId + "|");
					List inParameters = new ArrayList();
					List outParameters = new ArrayList();
					inParameters.add(execsql.toString());
					outParameters.add(java.sql.Types.VARCHAR);
					outParameters.add(java.sql.Types.VARCHAR);
					List outList = publicDao.callProc("pk_card_apply_issuse.p_apply_bank_sh",inParameters,outParameters);
					if(outList == null || outList.size() <= 0){
						throw new CommonException("银行返回文件入库调取过程出现错误！");
					}
					if(Integer.valueOf(outList.get(0).toString()) != 0){
						throw new CommonException(outList.get(1).toString());
					}
					if(!ftpClient.rename(fileName,subHisDir + "/" + fileName)){
						throw new CommonException("移动文件" + fileName + "时失败,处理失败");
					}
					logger.error("文件" + fileName + "处理成功");
				}else{
					throw new CommonException("文件" + fileName + ",内容为空！");
				}
			}else{
				throw new CommonException("文件" + fileName + "的文件名不正确，或对应批次不是一卡通导出");
			}
			System.gc();
		} catch (Exception e) {
			logger.error("========导入银行文件出错！========" + e.getMessage());
			throw new CommonException("导入银行文件出错" + e.getMessage());
		}finally{
			
		}
		return null;
	}
	public  String getStringByByte(byte[] string,int pos,int len) throws Exception{
		return new String(string,pos,len);
	}
	/**
	 * 导入卡厂数据
	 */
	
	@SuppressWarnings("unchecked")
	@Override
	public String saveimportTaskReByFacTory(SysActionLog actionLog,Users user) throws CommonException {
		//--->获取指定银行目录下的文件--->更新申领表--->任务表--->批次表
		DefaultFTPClient ftpClient = new DefaultFTPClient();
		String isRight="1";
		try {
			publicDao.save(actionLog);
			logger.info("===============================================================================================");
			logger.info("====================开始导入卡厂文件==================");
			//步骤 1----->初始话ftp目录----->获取该目录下所有文件---->循环每个文件获取明细数据
			initFtpPara("make_card_task_to_fact");
			ftpClient.setControlEncoding("GBK");
			FTPClientConfig conf = new FTPClientConfig(FTPClientConfig.SYST_NT);
			conf.setServerLanguageCode("zh");
			ftpClient.connect(url, Integer.parseInt(port));
			ftpClient.login(userName, pwd);
			ftpClient.enterLocalPassiveMode();
			List list = ftpClient.listNames(host_download_path, 100);
			if(list==null || list.size()<=0){
				isRight="2";
				logger.info("========没有文件需要获取，卡厂没有发送文件到指定ftp目录！========");
				throw new CommonException("没有文件需要获取，卡厂没有发送文件到指定ftp目录！");
			}
			int count=0;
			StringBuffer fileNamebuffer = new StringBuffer();
			for(int i=0;i<list.size();i++){//多个文件
				//判断文件名是否正确，“卡类型（中文）+‘_’ +批次号+ ‘_’ + 生成日期(8位) + 生成时间(6位) +‘_’+卡商编号+‘_’+卡商名字+‘_’+银行编号+‘_’+银行名字+’_d’.txt”
				//判断批次号和文件后缀是否正确
				String fileNamebyfact =  list.get(i).toString();
				fileNamebuffer.append(fileNamebyfact+"|");
				String batchTaskNo = list.get(i).toString().split("\\_")[1];
				logger.info("========开始处理卡厂导入"+fileNamebyfact+"文件！========");
				BigDecimal count_msg = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from card_task_batch c where BATCH_ID='"+list.get(i).toString().split("\\_")[1]+"'");
				if(fileNamebyfact.indexOf("_d.txt")>0&&count_msg.intValue()>=1){
					ftpClient.changeWorkingDirectory(host_download_path);
					List<String> fileContent= ftpClient.getFileContent(list.get(i).toString());
					//根据文件名获取批次号
					if(fileContent!=null){
						//1入临时表
						String[] taskContent=null;
						for(int j=0;j<fileContent.size();j++){
							//第一行，第二行为文件头，第三行为第一次---分割线，先判断这三行是否正确，不正确该文件不入临时表，写日志该文件处理出错，继续下文件
							if(j==0){
								try {
									if(!fileContent.get(j).startsWith("task_id|card_type|bank_id|recordcount|taskaddr|serid|sername|companyid|company|region_name|street|community|")){
										throw new CommonException("制卡导入文件有误！");
									}
								} catch (CommonException e) {
									logger.info("========开始处理卡厂导入"+fileNamebyfact+"文件！文件所属第一行的头不正确========");
									break;
								}
							}
							if(j==1){
								try {
									if(!fileContent.get(j).startsWith("task_id|data_seq|client_id|name|sex|cert_no|card_no|ws_certno|bank_card_no|card_id|")){
										throw new CommonException("制卡导入文件有误！");
									}
								} catch (CommonException e) {
									logger.info("========开始处理卡厂导入"+fileNamebyfact+"文件！文件所属第二行的头不正确========");
									break;
								}
							}
							if(j==2){
								try {
									if(!fileContent.get(j).startsWith("---")){
										throw new CommonException("制卡导入文件有误！");
									}
								} catch (CommonException e) {
									logger.info("========开始处理卡厂导入"+fileNamebyfact+"文件！文件所属第三行的头不正确========");
									break;
								}
							}
							//从第三行开始是正式的文件
							if(j>=2){
								//每个任务用---隔开
								if(fileContent.get(j).startsWith("---")){
									String[] taskMsg=null;
									taskMsg=fileContent.get(j+1).split("\\|");
									try {
										BigDecimal tasknum = (BigDecimal) publicDao.findOnlyFieldBySql("select t.task_sum from card_apply_task t where t.task_id='"+ taskMsg[0] + "'");
										if (tasknum.intValue() != Integer.parseInt(taskMsg[3])) {
											throw new CommonException("开始处理卡厂导入"+ fileNamebyfact+ "文件！文件中的任务号为:"+ taskMsg[0]+ "的任务数量大于导出时的任务数量！");
										}
									} catch (Exception e) {
										logger.info("========"+e.getMessage()+"========");
										break;
									}
									j=j+2;
								}
								
								taskContent = fileContent.get(j).split("\\|");
								if(taskContent==null){
									j++;
									continue;
								}
								/*task_id|card_type|bank_id|recordcount|taskaddr|serid|sername|companyid|company|region_name|street|community|
								task_id|data_seq|client_id|name|sex|cert_no|card_no|ws_certno|bank_card_no|card_id|*/
								//判断任务中的数据是不是属于同一批次
								String curentBatchId = (String)this.findOnlyFieldBySql("select BUY_PLAN_ID from card_apply where task_id='"+taskContent[0]+"' and customer_id='"+taskContent[2]+"'");
								if(!curentBatchId.equals(batchTaskNo)){
									throw new CommonException("开始处理卡厂导入"+ fileNamebyfact+ "文件！文件中行数为:"+ (j+1)+ "的数据不属于批次号为："+batchTaskNo+"的数据");
								}
								//0、task_id|1、data_seq|2、client_id|3、name|4、sex|5、cert_no|6、card_no|7、ws_certno|8、bank_card_no|9、card_id|
								//[2015082500004787, 394, 1000026191, 李越, 2, 640382199202171344, 75000001000000014645, 640382199202171344, 6217712400256729, 0D78007102008C86650C6D167E]
								publicDao.doSql("insert into card_task_imp_tmp  (USER_ID,BATCH_ID,TASK_ID,DATA_SEQ,customer_id,NAME,sex,card_no,cert_no,BANKCARDNO,CARD_ID,STATUSTEXT) values('"+user.getUserId()+"','"+curentBatchId+"','"+Tools.processNull(taskContent[0])+"','"+Tools.processNull(taskContent[1])+"','"+Tools.processNull(taskContent[2])+"','"+Tools.processNull(taskContent[3])+"','"+Tools.processNull(taskContent[4])+"','"+Tools.processNull(taskContent[6])+"','"+Tools.processNull(taskContent[7])+"','"+Tools.processNull(taskContent[8])+"','"+Tools.processNull(taskContent[9])+"','"+fileNamebyfact+"') ");
							}
							
						}
						publicDao.doSql("update card_apply_task t set t.TASK_STATE ='"+Constants.TASK_STATE_YJS+"' where make_batch_id='"+batchTaskNo+"' and task_state ='"+Constants.TASK_STATE_YHYSH+"'");
						logger.info("========开始处理卡厂导入"+fileNamebyfact+"文件！========");
					}else{
						logger.info("========结束卡厂导入"+fileNamebyfact+"文件！========文件没有内容");
						throw new CommonException("========结束卡厂导入"+fileNamebyfact+"文件！========文件没有内容");
					}
					
				}else{
					logger.info("====================文件名为"+fileNamebyfact+"的银行返回文件文件名不正确，或对应批次不是一卡通导出================");
					throw new CommonException("文件名为"+fileNamebyfact+"的银行返回文件文件名不正确，或对应批次不是一卡通导出");
				}
			}
			//进行建卡和建立账户，按照临时表数据，将临时表数据移到正式表，删除临时表数据，移动文件  此过程中记录下没有开户成功的客户信息
			List listopenAcc  =this.findBySql("select * from Card_Task_Imp_Tmp t where 1=1");
			for(int k=0;k<listopenAcc.size();k++){
				Object[] taskimptemp = (Object[])listopenAcc.get(k);
				//判断卡号是不是导出过，状态是不是银行审核成功，按照身份证，和卡号以及customer_id
				List<CardApply> temp =(List<CardApply>)this.findByHql("from CardApply a where a.customerId='"+Tools.processNull(taskimptemp[4])+"'"+ " and a.applyState='"+Constants.APPLY_STATE_YHSHTG+"' and a.cardNo ='"+Tools.processNull(taskimptemp[8])+"'");
				if(temp!=null&&temp.size()==1){
					CardApply apply = temp.get(0);
					CardTaskList cardtaskList = (CardTaskList) this.findByHql("from CardTaskList where dataSeq='"+Tools.processNull(((BigDecimal)taskimptemp[3]).intValue())+"'").get(0);
					// 判断用户是否有正常的卡信息和账户信息-->如果有则不进行开户，而是修改此临时表的状态为 STATUSID = 3：未开户成功 ，已存在该卡的账户
					List tempBaseCard  = this.findByHql("from CardBaseinfo where customerId='"+Tools.processNull(taskimptemp[4])+"' and cardState='1'");
					List tempBaseAcc  = this.findByHql("from AccAccountSub where customerId='"+Tools.processNull(taskimptemp[4])+"' and accState<3 ");
					if((tempBaseCard!=null&&tempBaseCard.size()>0)||(tempBaseAcc!=null&&tempBaseAcc.size()>0)){
						//修改导入临时表的记录为此次开户不成功STATUSID  3：未开户成功 ，已存在该卡的账户
						publicDao.doSql("update CARD_TASK_IMP_TMP t set STATUSID='3' where task_id='"+Tools.processNull(taskimptemp[2])+"'"+ " and DATA_SEQ='"+Tools.processNull(taskimptemp[3])+"' and card_no='"+Tools.processNull(taskimptemp[10])+"'");
					}else{
						//插入卡信息
						publicDao.doSql("insert into card_baseinfo (Customer_Id,Card_No,card_state,version,card_type,Issue_Org_Id,"
								+ "init_org_id,city_code,start_date,valid_date,bus_use_flag,bus_type,card_id,Last_Modify_Date,sub_Card_no,"
								+ "bank_card_no) values('"+Tools.processNull(taskimptemp[4])+"','"+Tools.processNull(taskimptemp[10])+"','0','"+apply.getVersion()+"','"+apply.getCardType()+"','"+apply.getOrgCode()+"'"
								+ ",'"+apply.getOrgCode()+"','"+apply.getCityCode()+"','"+cardtaskList.getCardissuedate()+"'"
								+ ",'"+cardtaskList.getValiditydate()+"','"+Tools.processNull(cardtaskList.getBusUseFlag())+"','"+apply.getBusType()+"'"
								+ ",'"+Tools.processNull(taskimptemp[15])+"',to_date('"+DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")+"','yyyy-mm-dd hh24:mi:ss')"
								+ ",'"+Tools.processNull(taskimptemp[20])+"','"+Tools.processNull(taskimptemp[14])+"')");
						//添加账户 暂时不实现
						/*HashMap<String, Object> hm = new HashMap<String, Object>();
						hm.put("obj_type", Sys_Code.CLIENT_TYPE_SALE_GR);
						hm.put("sub_type", apply.getCardType());
						hm.put("obj_id", Tools.processNull(taskimptemp[10]));
						accACountService.createAccount(actionLog, hm);
						publicDao.doSql("update CARD_TASK_IMP_TMP t set t.STATUSID='1' where task_id='"+Tools.processNull(taskimptemp[2])+"'"
								+ " and DATA_SEQ='"+Tools.processNull(((BigDecimal)taskimptemp[3]).intValue())+"' and card_no='"+Tools.processNull(taskimptemp[10])+"'");*/
						//修改申领表状态为已制卡
						publicDao.doSql("update card_apply a set a.APPLY_STATE='"+Constants.APPLY_STATE_YZK+"',a.bank_card_no='"+Tools.processNull(taskimptemp[14])+"'  where Customer_Id='"+apply.getCustomerId()+"' and TASK_ID ='"+apply.getTaskId()+"' and APPLY_STATE='"+Constants.APPLY_STATE_YHSHTG+"'");
					}
				}else{
					//修改导入临时表的记录为此次开户不成功STATUSID  0未启用，1已启用  2未开户成功，找不到申领记录
					publicDao.doSql("update CARD_TASK_IMP_TMP t set t.STATUSID='2' where task_id='"+Tools.processNull(taskimptemp[2])+"' and DATA_SEQ='"+Tools.processNull(((BigDecimal)taskimptemp[3]).intValue())+"'");
				}
			}
			publicDao.doSql("insert into CARD_TASK_IMP select * from CARD_TASK_IMP_TMP c where c.STATUSID='1'");
			publicDao.doSql("delete from CARD_TASK_IMP_TMP t  where t.STATUSID='1'");
			//修改任务状为已接收
			String[] filenames = fileNamebuffer.toString().split("\\|");
			for(int p=0;p<filenames.length;p++){
				if(!Tools.processNull(filenames[p]).equals("")){
					DefaultFTPClient.reNameInFtp(url, 21, userName,pwd,host_download_path+"/" + filenames[p].toString(), host_history_path+"/" + filenames[p].toString()+".bak");
					DefaultFTPClient.deleteFile(url, 21, userName, pwd, host_download_path, filenames[p].toString());
				}
			}
			
		} catch (Exception e) {
			logger.error("========导入卡厂文件出错！========"+e.getMessage());
			isRight="0";
			throw new CommonException("导入卡厂文件出错"+e.getMessage());
		}finally{
			try{
				ftpClient.logout();
				if (ftpClient.isConnected()) {
					try {
						ftpClient.disconnect();
					} catch (Exception e) {
						throw new CommonException("FTP断开连接异常:"+ e.getMessage());
					}
				}
				System.gc();
			}catch (Exception ee) {
				
			}
		}
		
		return null;
	}

	@Override
	public void saveOpenAcc(SysActionLog actionLog, Users user)
			throws CommonException {
		try {
			actionLog.setDealCode(DealCode.PUBLICCARD_BACKOPENACC);
			actionLog.setMessage("批量开户");
			publicDao.save(actionLog);
			List accInfo = publicDao.findBySQL("select t1.card_type,t1.card_no from card_baseinfo t1 where not exists(select 1 from acc_account_sub t2"
					+ " where t1.customer_id = t2.customer_id and t1.card_no =t2.card_no)");
			if(accInfo!=null&&accInfo.size()>0){
				for(int i=0;i<accInfo.size();i++){
					Object[] cardinfo = (Object[])accInfo.get(i);
					//添加账户
					HashMap<String, Object> hm = new HashMap<String, Object>();
					hm.put("obj_type", Sys_Code.CLIENT_TYPE_SALE_GR);
					hm.put("sub_type", cardinfo[0]);
					hm.put("obj_id", cardinfo[1]);
					accACountService.createAccount(actionLog, hm);
				}
			}
			
		} catch (Exception e) {
			throw new CommonException("开户出错："+e.getMessage());
		}
	}

	/**
	 * 制卡任务导出
	 * @param id 制卡任务id数组
	 * @param cmMakeBatch 卡制作采购批次
	 * @param operId 操作人员id
	 * @param isgx 是否个性化制卡导出，true表示是，false表示否
	 * @throws CommonException
	 */
	public void rwdc(String[] id,CardTaskBatch cmMakeBatch,String userId,SysActionLog actionLog,boolean isgx,String taskState,String fileName) throws CommonException{
		try{
			//按照id进行循环
			for(int i=0;i<id.length;i++){
				//判断该任务是否可以导出
				CardApplyTask cmCardTask =(CardApplyTask)this.findOnlyRowByHql("from CardApplyTask t where taskId='"+id[i]+"'");
				if (!cmCardTask.getTaskState().equals(Constants.TASK_STATE_YSC)){
					throw new CommonException("需要导出的任务必须为‘任务生成’状态，否则不允许导出！");
				}
				if(isgx){//如果个性化制卡任务导出，需要更新卡片申领信息的申领状态为制卡中
					String exeSql = "update card_apply c set c.BUY_PLAN_ID='"+cmMakeBatch.getBatchId()+"',apply_state='"+Constants.APPLY_STATE_YFWJW+"'";
					exeSql += " where task_id = '" + cmCardTask.getTaskId() +"' and apply_state='"+Constants.APPLY_STATE_RWYSC+"'";
					publicDao.doSql(exeSql);
				}
				//更新任务信息
				if(cmCardTask.getCardType().equals(Constants.CARD_TYPE_JMK_BCP)){
					//如果是半成品卡导出，那么因为他只有导出没有导入因此修改任务状态为已接收，其他卡类型的制卡导出，修改任务状态为制卡中。
					cmCardTask.setTaskState(Constants.TASK_STATE_YHYSH);
				}else{
					cmCardTask.setTaskState(taskState);  //将任务状态更新为制卡中
				}
				cmCardTask.setMakeBatchId(cmMakeBatch.getBatchId()+"");
				//cmCardTask.setm("1");//制卡方式（1外包2本地）
				publicDao.update(cmCardTask);
			}
			actionLog.setMessage("任务导出为制卡文件，批次号为:"+cmMakeBatch.getBatchId());
			publicDao.save(actionLog);
			cmMakeBatch.setDealNo(Integer.parseInt(actionLog.getDealNo()+""));
			if(taskState.equals("1")){
				cmMakeBatch.setSendtowjwUserId(userId);
				cmMakeBatch.setSendtowjwDate(actionLog.getDealTime());//数据发送时间
			}else if(taskState.equals("3")){
				cmMakeBatch.setSendUserId(userId);
				cmMakeBatch.setSendDate(actionLog.getDealTime());
			}
			publicDao.save(cmMakeBatch);//保存卡制作采购批次
		}catch(Exception e){
			//出错后删除ftp上的文件，上传ftp是不受事务控制的
			DefaultFTPClient.deleteFile(url,  Integer.parseInt(port), userName, pwd, host_upload_path, fileName);
			throw new CommonException("制卡任务导出保存数据库时出错！",e);
		}
	}
	
	public void initFtpPara(String ftp_use) throws CommonException{
		List ftpPara = this.findBySql("select t.ftp_para_name,t.ftp_para_value from SYS_FTP_CONF t where t.ftp_use = '" + ftp_use + "'");
		if(ftpPara == null || ftpPara.size() <= 0){
			throw new CommonException("获取ftp配置出错，请联系系统管理员！");
		}
		for(int k = 0;k < ftpPara.size();k++){
			Object[] objs = (Object[])ftpPara.get(k);
			if(Tools.processNull(objs[0]).equals("host_ip")){
				url = Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("host_upload_path")){
				host_upload_path = Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("host_download_path")){
				host_download_path = Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("host_history_path")){
				host_history_path = Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("host_port")){
				port = Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("pwd")){
				pwd = Tools.processNull(objs[1]);
			}
			if(Tools.processNull(objs[0]).equals("user_name")){
				userName = Tools.processNull(objs[1]);
			}
		}
	}


	@Override
	public void saveNotOnlyTask(SysActionLog actionLog, Users user,
			String cardType, String bankId, String taskNum)
			throws CommonException {
		CardConfig para = this.getCardConfigByCardType(cardType);
		boolean getCardno = true;//当前是否获得卡号处理
		try{
			//1,保存操作日志
			actionLog.setDealCode(DealCode.PUBLICCARD_ADD);
			actionLog.setMessage("新增非个性化卡采购计划"+cardType+"|"+bankId+"|"+taskNum);
			publicDao.save(actionLog);
			String bank_name = (String)this.findOnlyFieldBySql("select bank_name from base_bank where bank_id='"+bankId+"'");
			//2,生成任务信息
			CardApplyTask task = new CardApplyTask();
			task.setTaskId(DateUtil.formatDate(actionLog.getDealTime(),"yyyyMMdd") + Tools.tensileString(this.getSequenceByName("SEQ_CM_CARD_TASK"),8,true,"0"));// //生成任务编号  yyyymmdd+8位序列号
			task.setDealCode(DealCode.APPLY_TYPE_BCPKSL);
			task.setTaskName("半成品卡_"+Tools.processNull(bank_name)+"_"+taskNum);
			task.setTaskSum(Integer.parseInt(taskNum));
			task.setTaskSrc(Constants.TASK_SRC_FGXHCG);
			task.setTaskDate(actionLog.getDealTime());
			task.setCardType(cardType);
			task.setBankId(bankId);
			task.setBrchId(user.getBrchId());
			task.setIsPhoto("1");
			task.setDealNo(actionLog.getDealNo());
			task.setIsUrgent("1");
			task.setOrgId(user.getOrgId());
			task.setTaskState(Constants.TASK_STATE_YSC);
			if (task.getTaskSum()<1){
				throw new CommonException("请填写制卡任务数量！");
			}
			
			//3,生成任务明细  
				//a,取卡号  按照卡号前16为排序去需要的条数
			CardApplyServiceImpl cardImp  = new CardApplyServiceImpl();
			try {
//				this.createCardNo(task.getCardType(), Long.parseLong(taskNum), actionLog.getDealNo());
				//获取卡参数表
				SysPara parasys = this.getSysParaByParaCode("CITY_CODE");
				
				if("".equals(Tools.processNull(parasys.getParaValue()))){
					throw new CommonException("系统未配置城市代码");
				}
				this.getCard_No(parasys.getParaValue(), "00", task.getCardType(), actionLog.getDealNo(), Integer.parseInt(taskNum));
			} catch (Exception e) {
				throw new CommonException("获取卡号出错："+e.getMessage());
			}
				//b,将卡号信息插入到任务明细表
			String pwd_rule=this.getSysParaByParaCode("TRADE_PWD_RULE").getParaValue();//开通交易密码规则，0常数，1随机
			String initpwd=this.getSysParaByParaCode("TRADE_PWD_DEFAULT").getParaValue();
			String org_code=user.getOrgId();
			String city_code=Tools.tensileString(this.getSysParaByParaCode("CITY_CODE").getParaValue(), 4, true, "0");
			String startdate=DateUtil.formatDate(actionLog.getDealTime(),"yyyyMMdd");
			String enddate=DateUtil.processDateAddYear(DateUtil.formatDate(actionLog.getDealTime(),"yyyy-MM-dd"),
					Integer.parseInt(this.getSysParaByParaCode("CARD_VALIDITY_PERIOD").getParaValue())).replace("-","");
			
			
			int faceval=(int) (Tools.processNull(para.getFaceVal()).equals("")?0:para.getFaceVal());
			String sql="insert into card_task_list(data_seq,task_id,card_no,struct_main_type,struct_child_type,cardissuedate," +
					"validitydate,bursestartdate,bursevaliddate,monthstartdate,monthvaliddate,face_val,pwd,card_type,version," +
					"INIT_ORG_ID,city_code,INDUS_CODE,useflag,month_type,bursebalance,monthbalance) select ";
			sql+="SEQ_DATA_SEQ.Nextval,'"+task.getTaskId()+"',a.card_no,'"+Tools.processNull(para.getStructMainType())+"','"+
				Tools.processNull(para.getStructChildType())+"','"+startdate+"','"+enddate+"','"+startdate+"','"+enddate+"','"+startdate+"','"+
				startdate+"','"+faceval+"',"+(Tools.processNull(pwd_rule).equals("0")?"'"+initpwd+
				"'":"ceil(dbms_random.value(100000,999999))")+",'"+task.getCardType()+"','1.0','"+
				org_code+"','"+city_code+"','"+Constants.INDUS_CODE+"','"+Constants.USED_FLAG+"','"+
				this.getSysParaByParaCode("MONTH_TYPE").getParaValue()+"','"+Constants.BURSEBALANCE+"','"+Constants.MONTHBALANCE+
				"' from card_no a where a.deal_no='"+actionLog.getDealNo()+"'";
			int cc = publicDao.doSql(sql);
			if(cc!=task.getTaskSum())
				throw new CommonException("当前非个性化采购计划获取卡号失败！");
			
				//c,修改任务明细表的起始卡号和结束卡号
			Object[] o =(Object[])this.findOnlyRowBySql("select min(card_no),max(card_no) " + "from card_task_list l where l.task_id = '" + task.getTaskId() + "'");
			task.setStartCardNo(Tools.processNull(o[0]));
			task.setEndCardNo(Tools.processNull(o[1]));
			publicDao.save(task);
		} catch(Exception e){
			throw new CommonException("保存非个性化卡采购计划出错:",e);
		}
	}


	@Override
	public void delNotOnlyTask(SysActionLog actionLog, Users user, String taskId)
			throws CommonException {
		try {
			actionLog.setDealCode(DealCode.PUBLICCARD_DEL);
			publicDao.save(actionLog);
			//判断任务状态看是否可以删除
			CardApplyTask task = (CardApplyTask)this.findOnlyRowByHql("from CardApplyTask t where t.taskId='"+taskId+"'");
			if(task==null||Tools.processNull(task.getTaskState()).equals("")){
				throw new CommonException("任务信息不正确，无法删除");
			}
			publicDao.doSql("delete from card_apply_task where task_id='"+taskId+"'");
			publicDao.doSql("update card_no t2 set t2.used ='1'  where  exists (select 1 from card_task_list t1.card_no = t2.card_no and t1.task_id='"+taskId+"')");
			publicDao.doSql("delete from card_task_list where task_id='"+taskId+"'");
		} catch (Exception e) {
			throw new CommonException("发生错误："+e.getMessage());
		}
	}


	@Override
	public void expNotOnlyTask(SysActionLog actionLog, Users user,
			String[] taskIds,String bankId) throws CommonException {
		String fileName = "";
		String cutLine = "----------";
		try {
			//1,初始化ftp参数
			initFtpPara("make_NOnlycard_task_to_bank_"+bankId);
			actionLog.setDealCode(DealCode.PUBLICCARD_DEL);
			publicDao.save(actionLog);
			//2,获取批次信息
			CardTaskBatch taskBatch = new CardTaskBatch();
			String batchId = this.getSequenceByName("seq_cm_card_task_batch");
			taskBatch.setBatchId(batchId);
			taskBatch.setSendUserId(user.getUserId());
			taskBatch.setSendDate(actionLog.getDealTime());
			taskBatch.setDealNo(Integer.parseInt(actionLog.getDealNo()+""));
			publicDao.save(taskBatch);
			//3,构造要上传的文件的文件名 卡类型（中文）+‘_’ +批次号+ ‘_’ + 生成日期(8位) + 生成时间(6位) +‘_’+卡商名字+’_S’.TXT
			fileName = "半成品卡_"+batchId+"_"+DateUtil.formatDate(actionLog.getDealTime(), "yyyyMMdd")
						+"_"+DateUtil.formatDate(actionLog.getDealTime(), "HHmmss")+"_"+bankId+"_S.txt";
			//4,修改任务的批次号
			publicDao.doSql("update card_apply_task t set t.make_batch_id='"+batchId+"',t.task_state='"+Constants.TASK_STATE_ZKZ+"' where task_id in("+Tools.getConcatStrFromArray(taskIds, "'", ",")+")");
			//5,构造上传数据 Constants.NEWLINE
			StringBuffer sbline=new StringBuffer("");
			String oneLine = "task_id|recordcount|";
			String twoLine = "data_seq|task_id|card_no|";
			sbline.append(oneLine);
			sbline.append(Constants.NEWLINE);
			sbline.append(twoLine);
			sbline.append(cutLine);
			sbline.append(Constants.NEWLINE);
			//开始循环任务
			for(int i=0;i<taskIds.length;i++){
				List taskContent = publicDao.findBySQL("select t.data_seq||'|'||t.task_id||'|'||t.card_no||'|' from "
						+ "card_task_list t where t.task_id='"+taskIds[i]+"'");
				String content="";
				for(int j=0;j<taskContent.size();j++){
					content = taskContent.get(j).toString();
					sbline.append(content);
				}
				if(i!=taskIds.length-1){
					sbline.append(Constants.NEWLINE+cutLine+Constants.NEWLINE);
				}
			}
			ByteArrayInputStream is = new ByteArrayInputStream(sbline.toString().getBytes("GB2312"));
			DefaultFTPClient.uploadFile(url, 21, userName, pwd, host_upload_path, fileName, is);
			System.gc();
		} catch (Exception e) {
			throw new CommonException("导出文件给银行出错，事务已回退，请重新操作！");
		}
		
	}


	@Override
	public void impNotOnlyTask(SysActionLog actionLog, Users user, String bankId)
			throws CommonException {
		try {
			logger.info("========开始导入半成品卡回盘数据=============");
			//1,初始化ftp参数，保存操作日志
			initFtpPara("make_NOnlycard_task_to_bank_"+bankId);
			actionLog.setDealCode(DealCode.PUBLICCARD_EXPORT);
			publicDao.save(actionLog);
			//2,根据客户的输入的银行导入回盘，
			DefaultFTPClient ftpClient = new DefaultFTPClient();
			ftpClient.setControlEncoding("GBK");
			FTPClientConfig conf = new FTPClientConfig(FTPClientConfig.SYST_NT);
			conf.setServerLanguageCode("zh");
			ftpClient.connect(url, Integer.parseInt(port));
			ftpClient.login(userName, pwd);
			List list = ftpClient.listNames(host_download_path, 100);
			if(list==null || list.size()<=0){
				logger.info("========没有文件需要获取，该银行没有发送文件到指定ftp目录！========");
				throw new CommonException("没有文件需要获取，该银行没有发送文件到指定ftp目录！");
			}
			for(int i=0;i<list.size();i++){
				//判断文件名是否正确，“卡类型（中文）+‘_’ +批次号+ ‘_’ + 生成日期(8位) + 生成时间(6位) +‘_’ +卡商名字+’_D’.TXT”
				//判断批次号和文件后缀是否正确
				String fileNamebybank =  list.get(i).toString();
				logger.info("========开始处理银行导入"+fileNamebybank+"文件！========");
				BigDecimal count_msg = (BigDecimal)publicDao.findOnlyFieldBySql("select count(1) from card_task_batch b where b.BATCH_ID='"+list.get(i).toString().split("\\_")[1]+"'");
				if(fileNamebybank.indexOf("_D.txt")>0&&count_msg.intValue()>=1){
					ftpClient.changeWorkingDirectory(host_download_path);
					List<String> fileContent= ftpClient.getFileContent(list.get(i).toString());
					//根据文件名获取批次号
					if(fileContent!=null){
						String batch_id = list.get(i).toString().split("\\_")[1];
						if(fileContent!=null&&fileContent.size()>=2){
							//开始执行步骤2 ----->开始处理到获取的文件----->修改申领表的记录为制卡中------->任务更新为制卡中------->批次表更新状态
							//batch_id|task_id|data_seq|client_id|name|sex|cert_typed|cert_no|check_flag|refuse_reson|
							String[] taskInfo = null;
							for(int j=2;j<fileContent.size();j++){
								if(fileContent.get(j).indexOf("--")>0){//的到任务的信息
									//判断任务是否为该批次 下面两个一行是任务信息，一行是数据字段信息
									taskInfo = fileContent.get(j+1).split("\\|");
									CardApplyTask task = (CardApplyTask)this.findOnlyRowByHql("from CardApplyTask c where c.taskId='"+taskInfo[0]+"'");
									if(!Tools.processNull(task.getMakeBatchId()).equals(batch_id)){
										throw new CommonException("该文件中的任务不属于一个批次，请核对！");
									}
									//判断任务是否已处理过
									if(Tools.processNull(task.getTaskState()).equals(Constants.TASK_STATE_YHYSH)){
										throw new CommonException("该文件中有任务已经处理完成，无需处理！");
									}
									//若任务数量和库里的数量一直则更新任务状态为TASK_STATE_YHSHWC
									if(Tools.processNull(task.getTaskSum()).equals(Tools.processNull(taskInfo[1]))){
										publicDao.doSql("update CARD_APPLY_TASK set TASK_STATE='"+Constants.TASK_STATE_YHYSH+" where task_id='"+Tools.processNull(taskInfo[0]));
									}
									j=j+3;
								}
								if(Tools.processNull(fileContent.get(j)).equals("")){
									j++;
								}
								String[] contents = fileContent.get(j).split("\\|");
								publicDao.doSql("update card_task_list l set l.card_id='"+contents[3]+"' where data_seq = '"+contents[0]+"'");
							}
							
							//更新批次表
							publicDao.doSql("update CARD_TASK_BATCH c set c.RECEIVEBYBANK_USER_ID='"+user.getUserId()+"',RECEIVEBYBANK_DATE=to_date('"+DateUtil.formatDate(actionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss")+"','yyyy-mm-dd hh24:mi:ss')"
									+ " where BATCH_ID='"+batch_id+"'");
							//移走处理好的文件
							DefaultFTPClient.reNameInFtp(url, 21, userName,pwd,host_download_path+"/" + list.get(i).toString(), host_history_path+"/" + list.get(i).toString());
							DefaultFTPClient.deleteFile(url, 21, userName, pwd, host_download_path, list.get(i).toString());
							logger.info("========结束回盘文件导入"+fileNamebybank+"文件！========");
						}
					}else{
						logger.info("========结束回盘文件导入"+fileNamebybank+"文件！========文件没有内容");
					}
					
				}else{
					logger.info("====================文件名为"+fileNamebybank+"的回盘文件文件名不正确，或对应批次不是一卡通导出================");
				}
				
			}
			ftpClient.logout();
			if (ftpClient.isConnected()) {
				try {
					ftpClient.disconnect();
				} catch (Exception e) {
					throw new CommonException("FTP断开连接异常:"
							+ e.getMessage());
				}
			}
			System.gc();
		} catch (Exception e) {
			throw new CommonException("导入回盘文件发生错误："+e.getMessage());
		}
	}
	/**
	 * 制卡任务审核信息
	 * @param actionLog
	 * @param user
	 * @param taskId
	 * @throws CommonException
	 */
	@Override
	public void checkTask(SysActionLog actionLog, Users user, String taskId)
			throws CommonException {
		try {
			actionLog.setDealCode(DealCode.PUBLICCARD_CHECK);
			publicDao.save(actionLog);
			//判断任务状态看是否可以删除
			CardApplyTask task = (CardApplyTask)this.findOnlyRowByHql("from CardApplyTask t where t.taskId='"+taskId+"'");
			if(task==null||Tools.processNull(task.getTaskState()).equals("")){
				throw new CommonException("任务信息不正确，无法审核");
			}
			publicDao.doSql("update card_apply_task t2 set t2.state ='1'  where t2.state='0' and t2.task_id='"+taskId+"'");
		} catch (Exception e) {
			throw new CommonException("发生错误："+e.getMessage());
		}
	}


	@Override
	public void saveAddTaskMx(SysActionLog actionLog, String personIds,
			String taskId) throws CommonException {
		try {
			actionLog.setDealCode(DealCode.APPLY_PROCESS_ADDMXTOTASK);
			actionLog.setMessage("向任务明细表插入数据");
			//1,插入申领表
			String[] customer_ids = personIds.split("\\|");
			String personals = Tools.getConcatStrFromArray(customer_ids, "'", ",");
			BigDecimal count_person = (BigDecimal) publicDao.findOnlyFieldBySql("select count(1) from card_apply t where "
					+ " t.customer_id in ("+personals+") and t.apply_state <> '"+Constants.APPLY_STATE_WJWSHBTG+"' and "
					+ " t.apply_state <> '"+Constants.APPLY_STATE_YHSHBTG+"' and t.apply_state <> '"+Constants.APPLY_STATE_YTK+"' "
					+ " and t.apply_state <> '"+Constants.APPLY_STATE_YZX+"'");
			if(count_person.intValue()>0){
				throw new CommonException("选中的人员已申领，不可添加，请重新选择！");
			}
			//判断card_no表里卡号是否够用
			BigDecimal cc  = (BigDecimal)publicDao.findOnlyFieldBySql(" SELECT count(1) FROM card_no WHERE used = '0' ");
			if(cc.intValue() < customer_ids.length){
				throw new CommonException("没有足够的备用卡号，请先生成备用卡号！");
			}
			StringBuffer limitPersons = new StringBuffer();
			limitPersons.append("and b.customer_id in ("+personals+")");
			CardApplyTask task = (CardApplyTask)this.findOnlyRowByHql("from CardApplyTask a where a.taskId='"+taskId+"'");
			CardConfig config = (CardConfig)this.findOnlyRowByHql("from CardConfig where cardType ='"+task.getCardType()+"'");
			Users oper = (Users)this.findOnlyRowByHql("from Users where userId='"+actionLog.getUserId()+"'");
			saveBatchApply(limitPersons,task,config,actionLog,oper,customer_ids,customer_ids.length);
		} catch (Exception e) {
			throw new CommonException("任务新增人员信息出错："+e.getMessage());
		}
	}
	
	/**
	 * 规模制卡数据生成
	 * @param StringBuffer   sql   人员信息限制性语句
	 * @param CardApplyTask  task  本次申领任务
	 * @param SysActionLog   log   申领操作日志
	 * @param Users          oper  申领制卡操作员
	 */
	
	public TrServRec saveBatchApply(StringBuffer limitPersons,CardApplyTask task,CardConfig config,SysActionLog log,Users oper,String[] customer_ids,Integer num) throws CommonException {
		try{
			//1.记录本次的操作日志信息
			publicDao.save(log);
			//2.定义本次申领任务所需人员信息
			String city_code = Tools.tensileString(this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'CITY_CODE'").toString(),4,true,"0");
			if(Tools.processNull(city_code).trim().equals("")){
				throw new CommonException("城市代码不能为空，SYS_PARA中找不到参数CITY_CODE");
			}
			StringBuffer slsql = new StringBuffer();
			slsql.append("insert into CARD_APPLY_GMSL_TEMP (APPLY_ID,BAR_CODE,CUSTOMER_ID,CARD_NO,SUB_CARD_NO,CARD_TYPE,Bank_Id,VERSION,ORG_CODE,");
			slsql.append("CITY_CODE,INDUS_CODE,APPLY_WAY,APPLY_TYPE,MAKE_TYPE,APPLY_BRCH_ID,CORP_ID,COMM_ID,TOWN_ID,APPLY_STATE,APPLY_USER_ID,");
			slsql.append("APPLY_DATE,COST_FEE,FOREGIFT,IS_URGENT,URGENT_FEE,IS_PHOTO,BUS_TYPE, MAIN_FLAG, OTHER_FEE, WALLET_USE_FLAG,DEAL_NO) ");
			//3.符合本次申领条件的限制语句
			slsql.append("select seq_apply_id.nextval,lpad(seq_bar_code.nextval,9,'0'),b.customer_id,");
			slsql.append("(case when b.reside_Type = 0 then r.region_Code else '" + "00" + "' end),'','");
			slsql.append(task.getCardType() + "','" + "" + "','" + Constants.CARD_VERSION + "','" + oper.getOrgId() + "','" + city_code + "','");
			slsql.append(Constants.INDUS_CODE + "','" + (task.getTaskWay().equals("2") ? "1" : task.getTaskWay().equals("1") ? "2" : "") + "','" + Constants.APPLY_TYPE_CCSL + "','" + "1" + "','");//是否加急
			slsql.append(oper.getBrchId() + "','" + Tools.processNull(task.getCorpId()) + "',b.comm_Id,b.town_Id,'");
			slsql.append(Constants.APPLY_STATE_YSQ + "','" + oper.getUserId() + "',to_date('");
			slsql.append(DateUtil.formatDate(log.getDealTime(),"yyyy-MM-dd HH:mm:ss") + "','yyyy-MM-dd HH24:mi:ss'),0,0,'" + Constants.URGENT_WB + "',0,'1',");
			slsql.append("case when months_between(sysdate,to_date(substr(b.cert_no,7,8),'yyyymmdd')) >= 840 then '20' ");
			slsql.append("when months_between(sysdate,to_date(substr(b.cert_no,7,8),'yyyymmdd')) >= 720 then '11'  when months_between(sysdate,to_date(substr(b.cert_no,7,8),'yyyymmdd')) < 216 then '10' else '01' end ");
			slsql.append(",'',0,'" + Constants.BUS_USE_FLAG_QB + "'," + log.getDealNo() + " ");
			slsql.append("from base_personal b,base_region r " );
			slsql.append("where b.sure_Flag = '0' and b.customer_state = '0' ");
			slsql.append("and b.region_id = r.region_id(+) and not exists(select 1 from Card_Apply a where a.card_type = '" + task.getCardType() + "' and a.customer_Id = b.customer_Id ");
			slsql.append("and (a.apply_State < " + Constants.APPLY_STATE_YZX + " and a.apply_State <> " + Constants.APPLY_STATE_WJWSHBTG + " and a.apply_State <> " + Constants.APPLY_STATE_YHSHBTG  + " )) ");
			slsql.append(limitPersons);//申领人员限制性语句
			//4.删除临时表上次已过期申领信息
			publicDao.doSql("delete from card_apply_gmsl_temp t where t.apply_user_id = '" + oper.getUserId() + "'");
			//5.申领信息预处理
			int allCount = publicDao.doSql(slsql.toString());
			if(allCount == 0){
				throw new CommonException("根据本次条件申领0个人员，本次操作无效，请仔细核对后重新进行操作！");
			}
			int region_Code_Count = publicDao.findBySQL("select 1 from card_apply_gmsl_temp where length(CARD_NO) != 2 and APPLY_USER_ID = '" + oper.getUserId() + "' and DEAL_NO = " + log.getDealNo()).size();
			if(region_Code_Count != 0){
				throw new CommonException("当前申领人员中有\"" + region_Code_Count + "\"个人所在区县编号为空，请先设置城区编码");
			}
			//6.对规模申领临时表进行预处理
			publicDao.doSql("update CARD_APPLY_GMSL_TEMP c set c.task_id = " + task.getTaskId() + " where apply_user_id = '" + oper.getUserId() + "' and deal_no = " + log.getDealNo());
			//TODO 如果需要对申领数据做进一步处理,请在此处添加。 
			
			//7.判断制卡方式 0 本地制卡不生成卡号  1 外包制卡 需要生成卡号
			if(Tools.processNull(task.getIsUrgent()).equals("1")){
				//每个卡类型,每种卡类型数量
				List<?> cardno = this.findBySql("SELECT CARD_TYPE,COUNT(1) FROM CARD_APPLY_GMSL_TEMP t WHERE t.APPLY_USER_ID = '" + oper.getUserId() + "' and DEAL_NO = " + log.getDealNo() + " GROUP BY CARD_TYPE ");
				for(int n = 0;n < cardno.size();n++){
					Object[] o = (Object[])cardno.get(n);
					String tempconfig = "";
					if(Tools.processNull(config.getCardTypeCatalog()).length() < 2){
						tempconfig += "0" + config.getCardTypeCatalog();
					}
					String updatecardno = "merge into card_apply_gmsl_temp a using (select a.card_no,b.apply_id from (select card_no,rownum rn " +
					"from card_no where used = 0 and card_catalog = '" + tempconfig + "' and deal_no = " + log.getDealNo() +
					") a, (select apply_id,rownum rn from card_apply_gmsl_temp where  card_type = '" + o[0] +
					"' and deal_no = " + log.getDealNo() + ") b where a.rn = b.rn) c on (a.apply_id = c.apply_id) " +
					"when matched then update set a.card_no = c.card_no";
					publicDao.doSql(updatecardno);
				}
			}
			//8.规模申领临时表数据移动到正式申领表  
			StringBuffer insertApplySql = new StringBuffer();
			insertApplySql.append("insert into CARD_APPLY (APPLY_ID, BAR_CODE, CUSTOMER_ID,CARD_NO,TASK_ID,SUB_CARD_NO,CARD_TYPE,SUB_CARD_TYPE, ");
			insertApplySql.append("BANK_ID, BANK_CARD_NO, VERSION, ORG_CODE, CITY_CODE, INDUS_CODE, APPLY_WAY, APPLY_TYPE, MAKE_TYPE, APPLY_BRCH_ID, CORP_ID,");
			insertApplySql.append("APPLY_STATE, APPLY_USER_ID, APPLY_DATE, COST_FEE, FOREGIFT, IS_URGENT, IS_PHOTO, RECV_BRCH_ID,");
			insertApplySql.append("RECV_CERT_TYPE, RECV_CERT_NO, RECV_NAME, RELS_BRCH_ID, RELS_USER_ID, RELS_DATE, AGT_CERT_TYPE, AGT_CERT_NO, AGT_NAME,");
			insertApplySql.append("AGT_PHONE, DEAL_NO, NOTE, BUS_TYPE, OLD_CARD_NO, OLD_SUB_CARD_NO, MESSAGE_FLAG, MOBILE_PHONE, MAIN_FLAG, MAIN_CARD_NO,");
			insertApplySql.append("OTHER_FEE, WALLET_USE_FLAG, MONTH_TYPE, MONTH_CHARGE_MODE,TOWN_ID,COMM_ID) ");
			// select 
			insertApplySql.append("select t.APPLY_ID,t.BAR_CODE,t.CUSTOMER_ID,t.CARD_NO,t.TASK_ID,t.SUB_CARD_NO,");
			insertApplySql.append("t.CARD_TYPE,t.SUB_CARD_TYPE,'',t.BANK_CARD_NO,t.VERSION,t.ORG_CODE,t.CITY_CODE,t.INDUS_CODE,t.APPLY_WAY,");
			insertApplySql.append("t.APPLY_TYPE,t.MAKE_TYPE,t.APPLY_BRCH_ID,t.CORP_ID,t.APPLY_STATE,t.APPLY_USER_ID,t.APPLY_DATE,");
			insertApplySql.append("t.COST_FEE,t.FOREGIFT,t.IS_URGENT,t.IS_PHOTO,t.RECV_BRCH_ID,t.RECV_CERT_TYPE,t.RECV_CERT_NO,t.RECV_NAME,t.RELS_BRCH_ID,");
			insertApplySql.append("t.RELS_USER_ID,t.RELS_DATE,t.AGT_CERT_TYPE,t.AGT_CERT_NO,t.AGT_NAME,t.AGT_PHONE,t.DEAL_NO,null,t.BUS_TYPE,");
			insertApplySql.append("t.OLD_CARD_NO,t.OLD_SUB_CARD_NO,t.MESSAGE_FLAG,t.MOBILE_PHONE,t.MAIN_FLAG,t.MAIN_CARD_NO,t.OTHER_FEE,t.WALLET_USE_FLAG,t.MONTH_TYPE,");
			insertApplySql.append("t.MONTH_CHARGE_MODE,t.TOWN_ID,t.COMM_ID from CARD_APPLY_GMSL_TEMP t where t.APPLY_USER_ID = '" + oper.getUserId() + "' and DEAL_NO = " + log.getDealNo());
			publicDao.doSql(insertApplySql.toString());
			//9.生成制卡明细
			insertCardtasklist(limitPersons.toString(), task, config, this.getSysConfigurationParameters("Apply_Ws_Flag"), customer_ids);
			//10.更新补充任务相关信息
			Object[] o =(Object[])this.findOnlyRowBySql("select min(card_no),max(card_no) " + "from card_task_list l where l.task_id = '" + task.getTaskId() + "'");
			task.setStartCardNo(Tools.processNull(o[0]));
			task.setEndCardNo(Tools.processNull(o[1]));
			task.setTaskSum(task.getTaskSum()+num);
			publicDao.update(task);
			//11.是否计算工本费；待定  
			
			//12.记录业务日志
			TrServRec rec = new  TrServRec();
			rec.setDealNo(log.getDealNo());
			rec.setDealCode(log.getDealCode());
			rec.setBrchId(oper.getBrchId());
			rec.setUserId(oper.getUserId());
			rec.setBizTime(log.getDealTime());
			rec.setNote(log.getMessage());
			rec.setCardType(task.getCardType());
			rec.setCardAmt(Long.valueOf(task.getTaskSum() + ""));
			rec.setClrDate(this.getClrDate());
			rec.setDealState(Constants.TR_STATE_ZC);
			publicDao.save(rec);
			return rec;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	
	/**
	 * <h3>根据任务号插入制卡数据明细表<h3>
	 * @param CardApplyTask task 当前任务
	 */
	public void insertCardtasklist(String limitpersons,CardApplyTask task,CardConfig para,String isInsertWs,String[] args)throws CommonException{
		try{
			//CardConfig para = (CardConfig) this.findOnlyRowByHql("from CardConfig t where t.cardType = '" + task.getCardType() + "'");
			if(para == null){
				throw new CommonException("该卡类型参数设置信息不存在！");
			}
			//1.获取指定卡类型相关的参数信息
			if(Tools.processNull(para.getCardValidityPeriod()).equals("")){
				throw new CommonException("该卡类型卡片有效期年数信息未设置！" + para.getCardType());
			}
			String city_code = Tools.tensileString(this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'CITY_CODE'").toString(),4,true,"0");
			if(Tools.processNull(city_code).trim().equals("")){
				throw new CommonException("城市代码不能为空，SYS_PARA中找不到参数CITY_CODE");
			}
			String month_Type = this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'MONTH_TYPE'").toString();
			if(Tools.processNull(month_Type).trim().equals("")){
				month_Type = "00";
			}
			String ndate = DateUtil.formatDate(task.getTaskDate(),"yyyyMMdd");//卡片发行日期,钱包应用启用日期
			String lsdate = DateUtil.processDateAddYear(DateUtil.formatDate(task.getTaskDate(),"yyyy-MM-dd"),para.getCardValidityPeriod()).replaceAll("-","");//根据设置参数计算卡片有效期限 格式:YYYYMMDD
			//密码规则   1随机生成;0默认固定密码
			String pwd_rule = this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'PWD_RULE'").toString();//开通交易密码规则，0常数，1随机
			if(Tools.processNull(pwd_rule).trim().equals("")){
				pwd_rule = "0";
			}
			//如果是固定密码,则获取固定的初始密码
			String initpwd = this.findOnlyFieldBySql("select t.para_value from SYS_PARA t where t.para_code = 'INITPWD'").toString();
			if(Tools.processNull(initpwd).trim().equals("")){
				initpwd = "123456";
			}
			//2.定义生成制卡明细的sql语句
			StringBuffer exesql = new StringBuffer();
			exesql.append("insert into card_task_list(data_seq,task_id,customer_id,name,sex,cert_type,cert_no,");
			exesql.append("nation,birthplace,birthday,reside_type,reside_addr,letter_addr,post_code,mobile_no,education,");
			exesql.append("marr_state,card_type,card_no,version,init_org_id,city_code,indus_code,cardissuedate,validitydate,bursestartdate,");
			exesql.append("bursevaliddate,monthstartdate,monthvaliddate,struct_main_type,struct_child_type,face_val,pwd,");
			exesql.append("bar_code,comm_id,bursebalance,monthbalance,bank_id,bankcardno,banksection2,banksection3,photofilename,");
			exesql.append("useflag,department,classid,apply_id,MONTH_TYPE)");
			//select 
			exesql.append(" select seq_data_seq.nextval,a.task_Id,b.customer_id,b.name,b.gender,b.cert_Type,b.cert_No,b.nation,'',");
			exesql.append("substr(b.cert_no,7,8),b.reside_type,b.reside_addr,b.letter_addr,b.post_code,b.mobile_no,b.education,");
			exesql.append("b.marr_state,a.card_type,a.card_No,a.version,a.org_code,a.city_code,a.indus_code,'");
			//cardissuedate  validitydate  bursestartdate  bursevaliddate monthstartdate  monthvaliddate
			//发卡日期、               卡片有效期、         钱包应用开始日期、钱包应用有效日期、月票开始日期、          月票有效期限
			exesql.append(ndate + "','" + lsdate + "','" + ndate + "','" + lsdate + "','" + ndate + "','" + ndate + "',a.bus_Type,'" + Tools.processNull(para.getStructChildType()) + "',nvl(");
			exesql.append(para.getFaceVal() + ",'0')," + (Tools.processNull(pwd_rule).equals("0") ? "'" + initpwd + "'" : "ceil(dbms_random.value(100000,999999))") + ",");
			exesql.append("a.bar_code,b.comm_id,'" + Constants.BURSEBALANCE+"','" + Constants.MONTHBALANCE + "',");
			exesql.append("a.bank_id,a.bank_card_no,'','',b.cert_No||'.jpg','" + Constants.USED_FLAG);
			exesql.append("',b.department,b.classid,a.apply_Id,'" + month_Type + "'");
			exesql.append("from card_apply a ,base_personal b where b.customer_id = a.customer_id  ");
			exesql.append("and a.apply_state = '" + Constants.APPLY_STATE_YSQ + "'");
			exesql.append(limitpersons);
			//3.生成制卡明细
			int c = publicDao.doSql(exesql.toString());
			//4.生成卫生明细
			if(isInsertWs.equals("1")){
				StringBuffer exesqlws = new StringBuffer();
				exesqlws.append("insert into card_task_list_ws(task_id,customer_id,ws_id) select "+task.getTaskId()+", b.customer_id, seq_ws_id.nextval from base_personal b where 1=1 ");
				exesqlws.append(limitpersons);
			}
			
			//4.处理证件类型、婚姻状况
			publicDao.doSql("update card_task_list c set c.marr_State = (decode(c.marr_State,'10','1','20','2','21','2','22','2','23','2','30','3','40','4','10'))  where c.TASK_ID = '" + task.getTaskId() + "' and c.customer_id in("+Tools.getConcatStrFromArray(args, "'",",")+")");
			int ci = publicDao.doSql("update card_task_list c set c.cert_typed = (decode(c.cert_type,'1','00','2','05','3','01','4','02','5','04','6','05','05')) where c.TASK_ID = '" + task.getTaskId() + "' and c.customer_id in("+Tools.getConcatStrFromArray(args, "'",",")+")");
			//4.更新学生卡、敬老卡的应用期限
			//学生卡的钱包应用有效日期为18岁止//to_date(birthday,'yyyyMMdd')
			publicDao.doSql("update card_task_list c set c.bursevaliddate = to_char(add_months(to_date(bursestartdate,'yyyymmdd'),(18 * 12 - months_between(sysdate,to_date(c.birthday,'yyyymmdd')))),'yyyymmdd') "
					       +"where c.struct_main_type = '10' and c.TASK_ID = '" + task.getTaskId() + "' and c.customer_id in("+Tools.getConcatStrFromArray(args, "'",",")+")"); 
			//更新半价老年人卡的钱包应用有效日期为70岁止
			publicDao.doSql("update card_task_list c set c.bursevaliddate = to_char(add_months(to_date(bursestartdate,'yyyymmdd'),(70 * 12 - months_between(sysdate,to_date(c.birthday,'yyyymmdd')))),'yyyymmdd')" +
					      	"where c.struct_main_type = '11' and c.TASK_ID = '" + task.getTaskId() + "' and c.customer_id in("+Tools.getConcatStrFromArray(args, "'",",")+")"); 
//			if(c != task.getTaskSum() || ci != task.getTaskSum()){
//				throw new CommonException("生成制卡明细数量跟制卡任务中定义的数量不一致");
//			}
		}catch(Exception e){
			logger.error(e);
			throw new CommonException("生成制卡明细出错！" + e.getMessage());
		}
	}
	@Override
	public void deleteTaskMx(SysActionLog actionLog, String mxIds,String taskId)
			throws CommonException {
		try {
			actionLog.setDealCode(DealCode.APPLY_PROCESS_DELETEMXFROMTASK);
			actionLog.setMessage("删除任务明细信息："+mxIds);
			publicDao.save(actionLog);
			String[] mxs = mxIds.split("\\|");
			if(mxs.length <1){
				throw new CommonException("未选择任何任务明细，请选择任务明细进行操作！");
			}
			String aa = Tools.getConcatStrFromArray(mxs, "'", ",");
			publicDao.doSql("update card_apply t set t.apply_state ='"+Constants.APPLY_STATE_YZX+"' where t.task_id ='"+taskId+"' and exists ("
					+ "	select 1 from card_task_list t1 where t1.customer_id = t.customer_id and t1.data_seq in("+aa+"))");
			publicDao.doSql("delete from card_task_list a where a.data_seq in ("+aa+")");
			publicDao.doSql("update card_apply_task b set b.task_sum=b.task_sum -"+mxs.length+" where b.task_id ='"+taskId+"'");
		} catch (Exception e) {
			throw new CommonException("删除制卡任务明细：" + e.getMessage());
		}
	}
	/**
	 * @return the url
	 */
	public String getUrl() {
		return url;
	}
	/**
	 * @param url the url to set
	 */
	public void setUrl(String url) {
		this.url = url;
	}
	/**
	 * @return the port
	 */
	public String getPort() {
		return port;
	}
	/**
	 * @param port the port to set
	 */
	public void setPort(String port) {
		this.port = port;
	}
	/**
	 * @return the userName
	 */
	public String getUserName() {
		return userName;
	}
	/**
	 * @param userName the userName to set
	 */
	public void setUserName(String userName) {
		this.userName = userName;
	}
	/**
	 * @return the pwd
	 */
	public String getPwd() {
		return pwd;
	}
	/**
	 * @param pwd the pwd to set
	 */
	public void setPwd(String pwd) {
		this.pwd = pwd;
	}
	/**
	 * @return the host_upload_path
	 */
	public String getHost_upload_path() {
		return host_upload_path;
	}
	/**
	 * @param host_upload_path the host_upload_path to set
	 */
	public void setHost_upload_path(String host_upload_path) {
		this.host_upload_path = host_upload_path;
	}
	/**
	 * @return the host_download_path
	 */
	public String getHost_download_path() {
		return host_download_path;
	}
	/**
	 * @param host_download_path the host_download_path to set
	 */
	public void setHost_download_path(String host_download_path) {
		this.host_download_path = host_download_path;
	}
	/**
	 * @return the host_history_path
	 */
	public String getHost_history_path() {
		return host_history_path;
	}
	/**
	 * @param host_history_path the host_history_path to set
	 */
	public void setHost_history_path(String host_history_path) {
		this.host_history_path = host_history_path;
	}
	/**
	 * @return the accACountService
	 */
	public AccAcountService getAccACountService() {
		return accACountService;
	}
	/**
	 * @return the cardApplyService
	 */
	public CardApplyService getCardApplyService() {
		return cardApplyService;
	}	
}
