package com.erp.action;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.BaseBank;
import com.erp.model.CardApplyTask;
import com.erp.model.SysActionLog;
import com.erp.service.MakeTaskService;
import com.erp.task.DefaultFTPClient;
import com.erp.util.Constants;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.Json;
import com.erp.viewModel.Page;
import org.apache.log4j.Logger;

@SuppressWarnings("serial")
@Namespace("/madeCardTask")
@Action(value = "madeCardTaskAction")
@Results({@Result(type="json",name="json"),
@Result(name="viewTask",location="/jsp/cardApp/viewWsTaskMx.jsp")})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class MadeCardTaskAction extends BaseAction {
	private Logger logger = Logger.getLogger(MadeCardTaskAction.class);
	private String queryType="1";//查询标志
	private String madeCardBatchNo="";
	private String madeCardTaskNo="";
	private String taskState="";
	private String corpId="";
	private String cardType="";
	private String taskStartDate="";
	private String taskEndDate="";
	private String regionId="";
	private String townId="";
	private String commId="";
	private String bankId="";
	private String bankIdimp="";
	private String sort="";
	private String order="";
	private String taskids="";//已|分割  1|23|43
	private MakeTaskService makeTaskService;
	private String name="";
	private String certNo="";
	private String taskId ="";
	private String taskNum = "";
	private String dataSeqs = "";
	private String personIds = "";
	private String vendorId ="";
	public String url="";//ftp ip地址
	public String port="";//ftp 端口
	public String userName="";//登录用户名
	public String pwd="";//密码
	public String host_upload_path="";//此次操作上传文件的主目录
	public String host_download_path="";//此次操作下载文件的主目录
	public String host_history_path="";//此次操作历史文件目录
	
	/**
	 * 查询任务信息
	 * @return
	 */
	public String cardTaskQuery(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		try{//0网点1社区2单位3学校
			if(this.queryType.equals("0")){
				String head="",htj="";
				head = "select a.task_id SETTLEID,a.task_id,a.make_batch_id,(select code_name from sys_Code where code_type='TASK_STATE' and code_value = a.task_state) task_state,"
						+ "decode(a.task_way,'0','网点','1','社区','2','单位','3','学校','其他') task_way,CASE WHEN a.note is null then a.task_name else a.note end task_name ," +
						"to_char(a.task_date,'yyyy-mm-dd hh24:mi:ss') task_date,(select code_name from sys_Code where code_type='CARD_TYPE' and code_value = a.card_type) card_type,"
						+ "decode(a.is_urgent,'0','本地制卡','1','外包制卡','其他') is_urgent,a.task_sum";
				String head2 = "select to_char(sum(a.task_sum))";
				htj = " from card_apply_task a where a.TASK_SRC <> '"+Constants.TASK_SRC_FGXHCG+"'";
				
				if(!Tools.processNull(madeCardBatchNo).equals("")){
					htj+=" and a.make_batch_id = '"+madeCardBatchNo+"'";
				}
				if(!Tools.processNull(madeCardTaskNo).equals("")){
					htj+=" and a.task_id = '"+madeCardTaskNo+"'";
				}
				if(!Tools.processNull(taskState).equals("")){
					htj+=" and a.task_state = '"+taskState+"'";
				}
				if(!Tools.processNull(corpId).equals("")){
					htj+=" and a.CORP_ID = '"+corpId+"'";
				}
				if(!Tools.processNull(cardType).equals("")){
					htj+=" and a.card_Type = '"+cardType+"'";
				}
				if(!Tools.processNull(taskStartDate).equals("")){
					htj+=" and a.task_date >= to_date('"+taskStartDate+" 00:00:00"+"','yyyy-MM-dd hh24:mi:ss')";
				}
				if(!Tools.processNull(taskEndDate).equals("")){
					htj+=" and a.task_date <= to_date('"+taskEndDate+" 23:59:59"+"','yyyy-MM-dd hh24:mi:ss')";
				}
				if(!Tools.processNull(regionId).equals("")){
					htj+=" and a.region_id = '"+regionId+"'";
				}
				if(!Tools.processNull(townId).equals("")){
					htj+=" and a.town_id = '"+townId+"'";
				}
				if(!Tools.processNull(commId).equals("")){
					htj+=" and a.comm_id = '"+commId+"'";
				}
				if(Tools.processNull(sort).equals("")){
					htj+=" order by a.task_id ";
				}else{
					htj+=" order by  "+sort+" "+order;
				}
				Page list = makeTaskService.pagingQuery(head+htj.toString(),page,rows);
				if(list.getAllRs() != null){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应任务信息！");
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 任务回退
	 * @return
	 */
	public String backTask(){
		jsonObject.put("status","0");
		jsonObject.put("msg","导出成功");
		jsonObject.put("title","导出卫计委成功信息");
		try {
			//查询客户选中任务列表
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(makeTaskService.getSysBranchByUserId().getBrchId());
			actionLog.setMessage("任务回退");
			actionLog.setDealTime(makeTaskService.getDateBaseTime());
			actionLog.setDealCode(DealCode.PUBLICCARD_BACKTASK);
			String[] test = taskids.split("\\|");
			makeTaskService.saveTaskBack(actionLog,makeTaskService.getUser(),test);
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
			jsonObject.put("title","导出卫计委失败信息");
		}
		OutputJson(jsonObject,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	/**
	 * 获取银行编号
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public String getBankName(){
		Json json = new Json();
		try {
			String hql = "from BaseBank where bankState='0'  ";
			String objStr  = ServletActionContext.getRequest().getParameter("objStr");
			if(!Tools.processNull(objStr).equals("")){
				hql+=" and bankName like '%"+objStr+"%'";
			}			
			List<BaseBank> merlists = (List<BaseBank>)makeTaskService.findByHql(hql);
			OutputJson(merlists);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		return null;
	}
	
	/**
	 * 获取卡商编号
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public String getvendorName(){
		Json json = new Json();
		try {
			String hql = "from BaseVendor where state='0'  ";
			String objStr  = ServletActionContext.getRequest().getParameter("objStr");
			if(!Tools.processNull(objStr).equals("")){
				hql+=" and vendorName like '%"+objStr+"%'";
			}			
			List<BaseBank> merlists = (List<BaseBank>)makeTaskService.findByHql(hql);
			OutputJson(merlists);
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		return null;
	}
	
	/**
	 * 导出卫生系统：1，勾选任务；2，生成批次 3，按照批次生成文件给卫计委审核
	 * @return
	 */
	public String exportFtpFileToWjw(){
		jsonObject.put("status","0");
		jsonObject.put("msg","导出成功");
		jsonObject.put("title","导出卫计委成功信息");
		try {
			//查询客户选中任务列表
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(makeTaskService.getSysBranchByUserId().getBrchId());
			actionLog.setMessage("制卡任务导出给卫生系统");
			actionLog.setDealTime(makeTaskService.getDateBaseTime());
			actionLog.setDealCode(DealCode.PUBLICCARD_EXPORTTOWJW);
			if(Tools.processNull(taskids).equals("")){
				throw new CommonException("未选中任何任务信息，请重新选择！");
			}
			String[] test = taskids.split("\\|");
			//判断勾选的任务状态是否是否都是任务已生成状态，只有任务已生成状态，才能进行任务任务的导出
			BigDecimal bg = (BigDecimal)makeTaskService.findOnlyFieldBySql("select count(*) from card_apply_task t where t.task_state <>'"+Constants.TASK_STATE_YSC+"'"
					+ " and t.task_id in ("+Tools.getConcatStrFromArray(test, "'", ",")+")");
			if(bg.intValue()>0){
				throw new CommonException("选中的任务中任务的状态不都是《任务已生成》状态，请重新选择！");
			}
			
			makeTaskService.saveexportTaskToWjw(actionLog, makeTaskService.getUser(),test);
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
			jsonObject.put("title","导出卫计委失败信息");
		}
		OutputJson(jsonObject,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	/**
	 * 导入卫计委文件
	 * @return
	 */
	public String  importFtpFileByWjw(){
		jsonObject.put("status","0");
		jsonObject.put("msg","导入成功");
		jsonObject.put("title","导入卫计委文件成功信息");
		try {
			//查询客户选中任务列表
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(makeTaskService.getSysBranchByUserId().getBrchId());
			actionLog.setMessage("卫生系统文件导入一卡通系统");
			actionLog.setDealTime(makeTaskService.getDateBaseTime());
			actionLog.setDealCode(DealCode.PUBLICCARD_IMPORTBWJW);
			makeTaskService.saveimportTaskReByWjw(actionLog, makeTaskService.getUser());
		} catch (Exception e) {
			e.printStackTrace();
			this.saveErrLog(e);
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
			jsonObject.put("title","导入卫计委文件失败信息");
		}
		OutputJson(jsonObject, Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	/**
	 * 导出给银行的制卡文件
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public String exportFtpFileToBank(){
		try {
			String isExportWsFlag = baseService.getSysConfigurationParameters("Apply_Ws_Flag");//是否导出卫生标志  0 不导出给卫生  1 导出给卫生
			if(Tools.processNull(isExportWsFlag).equals("0")){
				isExportWsFlag = "0";
			}else if(Tools.processNull(isExportWsFlag).equals("1")){
				isExportWsFlag = "1";
			}else{
				throw new CommonException("是否导出给卫生标志不存在！");
			}
			String jAlertString = "";
			if(Tools.processNull(isExportWsFlag).equals("0")){
				jAlertString = "请选择同一种卡类型，同一种制卡方式的任务信息进行导出！";
			}else{
				jAlertString = "请选择同一批次，同一卡类型的任务信息进行进行导出！";
			}
			SysActionLog actionLog = baseService.getCurrentActionLog();
			String[] test = taskids.split("\\|");
			BigDecimal count = (BigDecimal)makeTaskService.findOnlyRowBySql("select count(1) from card_apply_task t where t.task_state <> '"  +
			(isExportWsFlag.equals("1") ? Constants.TASK_STATE_WJWYSH : Constants.TASK_STATE_YSC) +
			"' and task_id in (" + Tools.getConcatStrFromArray(test, "'", ",") + ")");
			if(count != null && count.intValue() > 0){
				throw new CommonException("请选择任务状态为" + (Tools.processNull(isExportWsFlag).equals("0") ? "《任务已生成》" : "《卫生审核通过》") + "的任务信息进行导出！");
			}
			List<Object[]> list = makeTaskService.findBySql("select nvl(make_Batch_Id,'') make_Batch_Id,nvl(card_type,'') card_type,nvl(is_urgent,'1') urgent from card_apply_task where task_id in (" + Tools.getConcatStrFromArray(test,"'",",") + ") group by make_Batch_Id,card_type,is_urgent");
			if(list == null || list.size() != 1){
				throw new CommonException(jAlertString);
			}
			Object[] batchAndCardType = (Object[]) list.get(0);
			String makeTaskBatch = Tools.processNull(batchAndCardType[0]).toString();
			String taskCardType  = Tools.processNull(batchAndCardType[1]).toString();
			if(isExportWsFlag.equals("1")){
				makeTaskService.saveexportTaskToBank(actionLog, makeTaskService.getUser(),test,makeTaskBatch,bankId,vendorId);
			}else{
				makeTaskService.saveexportTaskToBank_Temp(test,taskCardType,bankId,vendorId,baseService.getUser(),baseService.getCurrentActionLog());
			}
			jsonObject.put("status","0");
			jsonObject.put("msg","任务导出成功！");
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
		}
		OutputJson(jsonObject,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	/**
	 * 导入银行审核的数据
	 * @return
	 */
	public String importFtpFileByBank(){
		jsonObject.put("status","0");
		jsonObject.put("msg","导入成功");
		jsonObject.put("title","导入银行返回信息");
		try {
			//查询客户选中任务列表
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(makeTaskService.getSysBranchByUserId().getBrchId());
			actionLog.setMessage("制卡任务导入银行返回");
			actionLog.setDealTime(makeTaskService.getDateBaseTime());
			actionLog.setDealCode(DealCode.PUBLICCARD_IMPORTBYH);
			makeTaskService.saveimportTaskReByBank(actionLog, makeTaskService.getUser(), bankIdimp);
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
			jsonObject.put("title","导入银行失败信息");
		}
		OutputJson(jsonObject,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	/**
	 * 查询FTP上的文件
	 * Description <p>TODO</p>
	 * @return
	 */
	public String toQueryFtpFile(){
		try{
			initFtpPara("make_card_task_to_bank_" + bankIdimp);
		}catch(Exception e){
			
		}
		return this.JSONOBJ;
	}
	public String importFtpFileByBank_Temp(){
		DefaultFTPClient ftpClient = new DefaultFTPClient();
		try{
			logger.error("...............................");
			logger.error("#开始导入银行审核结果文件");
			logger.error("#正在检查FTP配置信息");
			initFtpPara("make_card_task_to_bank_" + bankIdimp);
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
			if(Tools.processNull(this.host_upload_path).equals("")){
				throw new CommonException("获取ftp配置出错，ftp上传文件路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_upload_path:" + this.host_upload_path);
			}
			if(Tools.processNull(this.host_history_path).equals("")){
				throw new CommonException("获取ftp配置出错，ftp历史文件路径未配置，请联系系统管理员！");
			}else{
				logger.error("host_history_path:" + this.host_history_path);
			}
			ftpClient.setControlEncoding("GBK");
			if(!ftpClient.toConnect(url,Integer.valueOf(port))){
				throw new CommonException("FTP连接失败！");
			}
			ftpClient.setControlEncoding("GBK");
			if(!ftpClient.toLogin(userName,pwd)){
				throw new CommonException("FTP登录失败！");
			}
			logger.error("当前工作目录" + ftpClient.printWorkingDirectory());
			logger.error("正在检查是否存在银行审核返回文件");
			if(!ftpClient.changeWorkingDirectory("/") || !ftpClient.changeWorkingDirectory(this.host_upload_path)){
				throw new CommonException("FTP切换到目录" + host_upload_path + "失败！");
			}
			List list = ftpClient.listNames(this.host_upload_path,100);
			if(list == null || list.size() <= 0){
				throw new CommonException("没有文件需要获取，银行没有发送文件到指定ftp目录！");
			}
			logger.error("检测到需要处理的文件个数" + list.size());
			for (int i = 0; i < list.size(); i++) {
				makeTaskService.saveimportTaskReByBank_Temp(ftpClient,bankIdimp,this.host_upload_path,list.get(i).toString(),this.host_history_path,makeTaskService.getCurrentActionLog(),makeTaskService.getUser());
			}
			jsonObject.put("status","0");
			jsonObject.put("msg","银行文件处理成功！");
		}catch(Exception e){
			logger.error(e.getMessage());
			jsonObject.put("msg",e.getMessage());
		}finally{
			if(ftpClient.isConnected()){
				try {
					ftpClient.disconnect();
				} catch (IOException e) {
					logger.error(e.getMessage());
				}
			}
			logger.error("结束处理银行审核结果文件");
		}
		return this.JSONOBJ;
	}
	/**
	 * 导入卡厂数据
	 * @return
	 */
	public String importFtpFileByFactory(){
		jsonObject.put("status","0");
		jsonObject.put("msg","导入成功");
		jsonObject.put("title","导入卡厂返回信息");
		try {
			//查询客户选中任务列表
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(makeTaskService.getSysBranchByUserId().getBrchId());
			actionLog.setMessage("制卡任务导入卡厂返回");
			actionLog.setDealTime(makeTaskService.getDateBaseTime());
			actionLog.setDealCode(DealCode.PUBLICCARD_IMPORTBYFAC);
			//导入正式表
			makeTaskService.saveimportTaskReByFacTory(actionLog, makeTaskService.getUser());
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
			jsonObject.put("title","导入卡厂返回信息失败");
		}
		OutputJson(jsonObject,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	/**
	 * 批量开户
	 * @return
	 */
	public String openAcc(){
		jsonObject.put("status","0");
		jsonObject.put("msg","开户成功");
		jsonObject.put("title","开户信息");
		try {
			//查询客户选中任务列表
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(makeTaskService.getSysBranchByUserId().getBrchId());
			actionLog.setOrgId(makeTaskService.getSysBranchByUserId().getOrgId()+"");
			actionLog.setDealTime(makeTaskService.getDateBaseTime());
			//导入正式表
			makeTaskService.saveOpenAcc(actionLog, makeTaskService.getUser());
		} catch (Exception e) {
			this.saveErrLog(e);
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
			jsonObject.put("title","导入银行失败信息");
		}
		OutputJson(jsonObject,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	/**
	 * 到达预览任务明细
	 * @return
	 */
	public String viewTask(){
		taskId = (ServletActionContext.getRequest().getParameter("taskids").split("\\|"))[0];
		return "viewTask";
	}

	/**
	 * 查询任务明细
	 * @return
	 */
	public String queryCardTaskList(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		try{//0网点1社区2单位3学校
			String head="",htj="";
			head = "select a.DATA_SEQ,a.TASK_ID,a.CUSTOMER_ID,a.NAME,a.CERT_NO,a.CARD_NO,a.RESIDE_ADDR ";
			htj = " from card_task_list a where 1=1 and task_id='"+taskId+"' ";
			
			if(!Tools.processNull(madeCardBatchNo).equals("")){
				htj+=" and a.task_id = '"+madeCardBatchNo+"'";
			}
			if(!Tools.processNull(name).equals("")){
				htj+=" and a.name = '"+name+"'";
			}
			if(!Tools.processNull(certNo).equals("")){
				htj+=" and a.cert_No = '"+certNo+"'";
			}
			if(Tools.processNull(sort).equals("")){
				htj+=" order by a.task_id ";
			}else{
				htj+=" order by  "+sort+" "+order;
			}
			Page list = makeTaskService.pagingQuery(head+htj.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 查询某个任务下可以填加的 
	 * @return
	 */
	public String findNoInsertPerson(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		try{//0网点1社区2单位3学校
			String head="",htj="";
			head = "SELECT a.customer_id PERSON_ID,a.customer_id CUSTOMER_ID,a.cert_no CERT_NO,a.name NAME " ;
			htj = "FROM base_personal a WHERE NOT EXISTS(SELECT 1 FROM card_apply b WHERE a.customer_id = b.customer_id AND "
					+ " b.apply_state <> '"+Constants.APPLY_STATE_WJWSHBTG+"' and  "
					+ " b.apply_state <> '"+Constants.APPLY_STATE_YHSHBTG+"' and b.apply_state <> '"+Constants.APPLY_STATE_YTK+"' "
					+ " and b.apply_state <> '"+Constants.APPLY_STATE_YZX+"') ";
			//按照任务条件查询可以添加的人员
			if(Tools.processNull(taskId).equals("")){
				throw new CommonException("未查询到任务数据");
			}else{
				CardApplyTask task = (CardApplyTask)makeTaskService.findOnlyRowByHql("from CardApplyTask a where a.taskId='"+taskId+"'");
				if(task ==null){
					throw new CommonException("未查询到任务数据");
				}else{
					if(task.getTaskWay().equals("0")){//网点方式申领
						throw new CommonException("网点申领方式不支持添加！");
					}else if(task.getTaskWay().equals("1")){//社区
						if(!Tools.processNull(task.getRegionId()).equals("")){
							htj += " and a.region_id ='"+Tools.processNull(task.getRegionId())+"'";
						}
						if(!Tools.processNull(task.getTownId()).equals("")){
							htj += " and a.town_id ='"+Tools.processNull(task.getTownId())+"'";
						}
						if(!Tools.processNull(task.getCommId()).equals("")){
							htj += " and a.comm_id ='"+Tools.processNull(task.getCommId())+"'";
						}
						if(!Tools.processNull(task.getGroup_Id()).equals("")){
							htj += " and a.group_id ='"+Tools.processNull(task.getGroup_Id())+"'";
						}
					}else if(task.getTaskWay().equals("2")){//单位
						if(!Tools.processNull(task.getCorpId()).equals("")){
							htj += " and a.corp_customer_id = '"+task.getCorpId()+"'";
						}
					}else if(task.getTaskWay().equals("3")){//学校
						throw new CommonException("学校申领方式不支持添加！");
					}
				}
			}
			
			Page list = makeTaskService.pagingQuery(head+htj.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 查询半成品任务信息
	 * @return
	 */
	public String cardTaskQueryBcp(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		try{//0网点1社区2单位3学校
			if(this.queryType.equals("0")){
				String head="",htj="";
				head = "select a.task_id SETTLEID,a.task_id,a.make_batch_id,(select code_name from sys_Code where code_type='TASK_STATE' and code_value = a.task_state) task_state,"
						+ "decode(a.task_way,'0','网点','1','社区','2','单位','3','学校','其他') task_way,CASE WHEN a.note is null then a.task_name else a.note end task_name ," +
						"to_char(a.task_date,'yyyy-mm-dd hh24:mi:ss') task_date,(select code_name from sys_Code where code_type='CARD_TYPE' and code_value = a.card_type) card_type,"
						+ "decode(a.is_urgent,'0','本地制卡','1','外包制卡','其他') is_urgent,a.task_sum";
				htj = " from card_apply_task a where a.TASK_SRC = '"+Constants.TASK_SRC_FGXHCG+"' ";
				
				if(!Tools.processNull(madeCardBatchNo).equals("")){
					htj+=" and a.make_batch_id = '"+madeCardBatchNo+"'";
				}
				if(!Tools.processNull(madeCardTaskNo).equals("")){
					htj+=" and a.task_id = '"+madeCardTaskNo+"'";
				}
				if(!Tools.processNull(taskState).equals("")){
					htj+=" and a.task_state = '"+taskState+"'";
				}
				if(!Tools.processNull(cardType).equals("")){
					htj+=" and a.card_Type = '"+cardType+"'";
				}
				if(!Tools.processNull(taskStartDate).equals("")){
					htj+=" and a.task_date >= to_date('"+taskStartDate+"','yyyy-MM-dd')";
				}
				if(!Tools.processNull(taskEndDate).equals("")){
					htj+=" and a.task_date <= to_date('"+taskEndDate+"','yyyy-MM-dd')";
				}
				if(Tools.processNull(sort).equals("")){
					htj+=" order by a.task_id ";
				}else{
					htj+=" order by  "+sort+" "+order;
				}
				System.out.println(head+htj.toString());
				Page list = makeTaskService.pagingQuery(head+htj.toString(),page,rows);
				if(list.getAllRs() != null){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 半成卡任务采购保存
	 * @return
	 */
	public String saveNotOnlyTask(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(makeTaskService.getSysBranchByUserId().getBrchId());
			actionLog.setOrgId(makeTaskService.getSysBranchByUserId().getOrgId()+"");
			actionLog.setDealTime(makeTaskService.getDateBaseTime());
			makeTaskService.saveNotOnlyTask(actionLog,makeTaskService.getUser(),cardType, bankId, taskNum);
			jsonObject.put("errMsg","非个性化采购成功");
			jsonObject.put("status","0");
		} catch (Exception e) {
			jsonObject.put("errMsg","非个性化采购出错："+e.getMessage());
			jsonObject.put("status","1");
		}
		return  this.JSONOBJ;
	}
	/**
	 * 删除半成品卡制卡任务信息
	 * @return
	 */
	public String delNotOnlyTask(){
		Json json = new Json();
		String message="";
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(makeTaskService.getSysBranchByUserId().getBrchId());
			actionLog.setOrgId(makeTaskService.getSysBranchByUserId().getOrgId()+"");
			actionLog.setDealTime(makeTaskService.getDateBaseTime());
			makeTaskService.delNotOnlyTask(actionLog, makeTaskService.getUser(), taskId);
			json.setMessage(message);
			json.setStatus(true);
			json.setTitle("提示信息");
		} catch (Exception e) {
			json.setMessage(e.getMessage());
			json.setStatus(false);
			json.setTitle("提示信息");
		}
		OutputJson(jsonObject,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	/**
	 * 导出半成制卡任务信息
	 * @return
	 */
	public String expNotOnlyTask(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("title", "");
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(makeTaskService.getSysBranchByUserId().getBrchId());
			actionLog.setOrgId(makeTaskService.getSysBranchByUserId().getOrgId()+"");
			actionLog.setDealTime(makeTaskService.getDateBaseTime());
			String[] test = taskids.split("\\|");
			//判断选中的任务是否都是已生成状态
			String taskid = Tools.getConcatStrFromArray(test, "'", ",");
			BigDecimal tc = (BigDecimal) makeTaskService.findOnlyFieldBySql("select count(1) from card_apply_task t "
					+ "where t.task_id in("+taskid+") and t.task_state='"+Constants.TASK_STATE_YSC+"'");
			if(tc.intValue()!=test.length){
				throw new CommonException("选中的任务不都是《任务已生成》状态，请重新选择！");
			}
			//判断选中的任务是否是同一个银行
			List rwbank_id = makeTaskService.findBySql("select bank_id from card_apply_task where task_id in("+Tools.getConcatStrFromArray(test, "'", ",")+") group by bank_id ");
			if(rwbank_id == null || rwbank_id.size() > 1){
				throw new CommonException("选中的任务不属于同一个银行！请重新选择");
			}
			if(rwbank_id.size() == 1){
				if(rwbank_id.get(0) == null){
					throw new CommonException("选中的任务不属于同一个银行！请重新选择");
				}else{
					if(!Tools.processNull(rwbank_id.get(0)).equals(bankId)){
						throw new CommonException("选中的任务不属于同一个银行！请重新选择");
					}
				}
			}
			makeTaskService.expNotOnlyTask(actionLog, makeTaskService.getUser(), test,bankId);
			jsonObject.put("errMsg","非个性化卡任务导出成功！");
			jsonObject.put("title", "提示信息");
		} catch (Exception e) {
			jsonObject.put("status","0");
			jsonObject.put("errMsg","非个性化卡任务导出错误："+e.getMessage());
			jsonObject.put("title", "错误提示");
			this.saveErrLog(e);
		}
		return this.JSONOBJ;
	}
	/**
	 * 导入半成制卡任务信息
	 * @return
	 */
	public String impNotOnlyTask(){
		Json json = new Json();
		String message="";
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(makeTaskService.getSysBranchByUserId().getBrchId());
			actionLog.setOrgId(makeTaskService.getSysBranchByUserId().getOrgId()+"");
			actionLog.setDealTime(makeTaskService.getDateBaseTime());
			makeTaskService.impNotOnlyTask(actionLog, makeTaskService.getUser(), bankId);
			json.setMessage(message);
			json.setStatus(true);
			json.setTitle("提示信息");
		} catch (Exception e) {
			json.setMessage(e.getMessage());
			json.setStatus(false);
			json.setTitle("提示信息");
		}
		OutputJson(jsonObject,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	/**
	 * 制卡任务审核信息
	 * @return
	 */
	public String checkTask(){
		Json json = new Json();
		String message="";
		try {
			SysActionLog actionLog = baseService.getCurrentActionLog();
			actionLog.setBrchId(makeTaskService.getSysBranchByUserId().getBrchId());
			actionLog.setOrgId(makeTaskService.getSysBranchByUserId().getOrgId()+"");
			actionLog.setDealTime(makeTaskService.getDateBaseTime());
			makeTaskService.checkTask(actionLog, makeTaskService.getUser(), taskId);
			json.setMessage(message);
			json.setStatus(true);
			json.setTitle("提示信息");
		} catch (Exception e) {
			json.setMessage(e.getMessage());
			json.setStatus(false);
			json.setTitle("提示信息");
		}
		OutputJson(jsonObject,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	/**
	 * 添加任务明细信息
	 * @return
	 */
	public String addTaskMx(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		try {
			//1,判断任务是否准许添加人员信息
			if(Tools.processNull(taskId).equals("")){
				throw new CommonException("任务信息没有，不能添加任务明细信息！");
			}
			CardApplyTask task = (CardApplyTask)makeTaskService.findOnlyRowByHql("from CardApplyTask where taskId='"+taskId+"'");
			if(task==null){
				throw new CommonException("未找到任务信息，请确认任务信息是否存在！");
			}else{
				if(!Tools.processNull(task.getTaskState()).equals(Constants.APPLY_STATE_RWYSC)){
					throw new CommonException("任务已经确认，不能进行人员明细的添加！");
				}else{
					//2,处理业务日志信息
					//3,调用业务类进行业务处理
					SysActionLog actionLog = makeTaskService.getCurrentActionLog();
					makeTaskService.saveAddTaskMx(actionLog, personIds, taskId);
				}
			}
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * 删除任务明细信息
	 * @return
	 */
	public String deleteTaskMx(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		try {
			//1,判断任务是否准许添加人员信息
			if(Tools.processNull(taskId).equals("")){
				throw new CommonException("任务信息没有，不能删除任务明细信息！");
			}
			CardApplyTask task = (CardApplyTask)makeTaskService.findOnlyRowByHql("from CardApplyTask where taskId='"+taskId+"'");
			if(task==null){
				throw new CommonException("未找到任务信息，请确认任务信息是否存在！");
			}else{
				if(!Tools.processNull(task.getTaskState()).equals(Constants.APPLY_STATE_RWYSC)){
					throw new CommonException("任务已经确认，不能进行人员明细的删除！");
				}else{
					//2,处理业务日志信息
					//3,调用业务类进行业务处理
					SysActionLog actionLog = makeTaskService.getCurrentActionLog();
					makeTaskService.deleteTaskMx(actionLog, dataSeqs, taskId);
				}
			}
			
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	/**
	 * 查询制卡任务明细（包含第三方审核结果查询和制卡情况查询）
	 * @return
	 */
	public String queryPersonMakeCardInfo(){
		jsonObject.put("status","0");
		jsonObject.put("errMsg","");
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("total",0);
		try{
			String head="",htj="";
			head = "SELECT T1.TASK_ID TASK_ID,T1.CUSTOMER_ID CUSTOMER_ID,T2.CERT_NO CERT_NO,T2.NAME NAME," + 
					"T1.CARD_TYPE CARD_TYPE,t4.code_name CARD_TYPE_NAME,T1.CARD_NO CARD_NO,t1.apply_state APPLY_STATE," +
					"to_char(t1.apply_date,'yyyy-mm-dd hh24:mi:ss') APPLY_DATE,T3.CODE_NAME APPLY_STATE_NAME ";
			htj = " FROM CARD_APPLY T1, BASE_PERSONAL T2 ,Sys_Code t3,Sys_Code t4 WHERE T1.CUSTOMER_ID = T2.CUSTOMER_ID(+) "+
				  " AND t1.apply_state = t3.code_value(+) AND t1.card_type  = t4.code_value(+) AND t3.code_type = 'APPLY_STATE' AND t4.code_type = 'CARD_TYPE' ";
			if(!Tools.processNull(taskId).equals("")){
				htj+=" and t1.task_id = '"+taskId+"'";
			}
			if(!Tools.processNull(certNo).equals("")){
				htj+=" and t2.cert_No = '"+certNo+"'";
			}
			if(!Tools.processNull(name).equals("")){
				htj+=" and t2.name like '%"+name+"%'";
			}
			if(Tools.processNull(sort).equals("")){
				htj+=" order by t1.apply_date desc ";
			}else{
				htj+=" order by  "+sort+" "+order;
			}
			Page list = makeTaskService.pagingQuery(head+htj.toString(),page,rows);
			if(list.getAllRs() != null){
				jsonObject.put("rows",list.getAllRs());
				jsonObject.put("total",list.getTotalCount());
			}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	/**
	 * FTP参数信息初始化
	 * Description <p>TODO</p>
	 * @param ftp_use
	 * @throws CommonException
	 */
	public void initFtpPara(String ftp_use) throws CommonException{
		List ftpPara = makeTaskService.findBySql("select t.ftp_para_name,t.ftp_para_value from SYS_FTP_CONF t where t.ftp_use = '" + ftp_use + "'");
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
	@Autowired
	public void setMakeTaskService(MakeTaskService makeTaskService) {
		this.makeTaskService = makeTaskService;
	}

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}

	public String getMadeCardBatchNo() {
		return madeCardBatchNo;
	}

	public void setMadeCardBatchNo(String madeCardBatchNo) {
		this.madeCardBatchNo = madeCardBatchNo;
	}

	public String getMadeCardTaskNo() {
		return madeCardTaskNo;
	}

	public void setMadeCardTaskNo(String madeCardTaskNo) {
		this.madeCardTaskNo = madeCardTaskNo;
	}

	public String getTaskState() {
		return taskState;
	}

	public void setTaskState(String taskState) {
		this.taskState = taskState;
	}

	public String getCorpId() {
		return corpId;
	}

	public void setCorpId(String corpId) {
		this.corpId = corpId;
	}

	public String getCardType() {
		return cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	public String getTaskStartDate() {
		return taskStartDate;
	}

	public void setTaskStartDate(String taskStartDate) {
		this.taskStartDate = taskStartDate;
	}

	public String getTaskEndDate() {
		return taskEndDate;
	}

	public void setTaskEndDate(String taskEndDate) {
		this.taskEndDate = taskEndDate;
	}

	public String getRegionId() {
		return regionId;
	}

	public void setRegionId(String regionId) {
		this.regionId = regionId;
	}

	public String getTownId() {
		return townId;
	}

	public void setTownId(String townId) {
		this.townId = townId;
	}

	public String getCommId() {
		return commId;
	}

	public void setCommId(String commId) {
		this.commId = commId;
	}

	public String getSort() {
		return sort;
	}

	public void setSort(String sort) {
		this.sort = sort;
	}

	public String getOrder() {
		return order;
	}

	public void setOrder(String order) {
		this.order = order;
	}

	public String getTaskids() {
		return taskids;
	}
	public void setTaskids(String taskids) {
		this.taskids = taskids;
	}
	public String getBankId() {
		return bankId;
	}
	public void setBankId(String bankId) {
		this.bankId = bankId;
	}
	public String getBankIdimp() {
		return bankIdimp;
	}
	public void setBankIdimp(String bankIdimp) {
		this.bankIdimp = bankIdimp;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getCertNo() {
		return certNo;
	}
	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}
	public String getTaskId() {
		return taskId;
	}
	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}
	public String getTaskNum() {
		return taskNum;
	}
	public void setTaskNum(String taskNum) {
		this.taskNum = taskNum;
	}
	public String getDataSeqs() {
		return dataSeqs;
	}
	public void setDataSeqs(String dataSeqs) {
		this.dataSeqs = dataSeqs;
	}
	public String getPersonIds() {
		return personIds;
	}
	public void setPersonIds(String personIds) {
		this.personIds = personIds;
	}
	public String getVendorId() {
		return vendorId;
	}
	public void setVendorId(String vendorId) {
		this.vendorId = vendorId;
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
	 * @return the makeTaskService
	 */
	public MakeTaskService getMakeTaskService() {
		return makeTaskService;
	}	
}
