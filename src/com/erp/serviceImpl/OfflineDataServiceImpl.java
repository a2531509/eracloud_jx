package com.erp.serviceImpl;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import sun.net.TelnetOutputStream;
import sun.net.ftp.FtpClient;

import com.erp.exception.CommonException;
import com.erp.model.BaseMerchant;
import com.erp.service.OfflineDataService;
import com.erp.task.DefaultFTPClient;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.Tools;
@Service("offlineDataService")
@SuppressWarnings("rawtypes")
public class OfflineDataServiceImpl extends BaseServiceImpl implements OfflineDataService {
	public static Logger logger = Logger.getLogger(OfflineDataServiceImpl.class);
	public static Log log = LogFactory.getLog(OfflineDataServiceImpl.class);
	
	/**
	 * 脱机数据
	 * 1.公交文件批处理入库插入临时表
	 * 2.对临时表中所有记录做验证，包括（非法，灰记录，重复记录，TAC验证）
	 * 3.对拒付表中的记录做调整
	 * 4.对公交商户产生清算文件
	 */
	public String saveOfflineData_Gj_Hncg() throws CommonException{
		DefaultFTPClient.writeLog("====================================开始处理公交脱机数据!");
		FtpClient ftpClient=null;
		String biz_Id = "";// = "041010010010001";
		String org_Id;
		String user="";
		String password="";
		Integer dealCode = DealCode.OFFLINE_CONSUME;
		String sysdate = publicDao.getDateBaseTimeStr("yyyyMMdd");
		DefaultFTPClient.writeLog("sysdate:" + sysdate);
		String acpt_Type ="6";//受理点类型(1-柜面 2-代理 3-自助 4-电话 5-网站 6-商场)
		String clr_Date=getBeforeClrDate();
		DefaultFTPClient.writeLog("clr_Date:" + clr_Date);
		try{
			List list_merchant = this.findByHql("from BaseMerchant t where t.merchantId in ('"+this.getSysConfigurationParameters("BIZ_ID_GJ0")+"','"+this.getSysConfigurationParameters("BIZ_ID_HNCG")+"')");
			//List list_merchant = this.findByHql("from BaseMerchant t where t.merchantId in ('"+this.getSysConfigurationParameters("BIZ_ID_HNCG")+"')");
			for(int i=0;i<list_merchant.size();i++){//循环公交
				biz_Id = ((BaseMerchant)list_merchant.get(i)).getMerchantId();
				org_Id = ((BaseMerchant)list_merchant.get(i)).getOrgId();
				if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_GJ0"))){
					user=this.getSysConfigurationParameters("gj_ftp_user0");
					password=this.getSysConfigurationParameters("gj_ftp_password0");
					ftpClient = reConnectFtp_gj(ftpClient,user,password,this.getSysConfigurationParameters("gj_ftp_ip0"));
				}else if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_HNCG"))){
					user=this.getSysConfigurationParameters("hncg_ftp_user");
					password=this.getSysConfigurationParameters("hncg_ftp_password");
					ftpClient = reConnectFtp_gj(ftpClient,user,password,this.getSysConfigurationParameters("hncg_ftp_ip"));
				} else{
					DefaultFTPClient.writeLog("无效商户编号"+sysdate);
				} 
                
				DefaultFTPClient.writeLog("商户号：" + biz_Id + "，商户名称：" + ((BaseMerchant)list_merchant.get(i)).getMerchantName());
				List list_clrDate = publicDao.findBySQL("select deal_batch_no from pay_offline_filename t where t.merchant_id='"+biz_Id+"' and state='3' group by deal_batch_no order by deal_batch_no");
				for(int ii=0;ii<list_clrDate.size();ii++){
					clr_Date = list_clrDate.get(ii).toString();
					sysdate = clr_Date.replace("-", "");
					this.adjustOfflineData_Gj(ftpClient,user,password, biz_Id, sysdate, dealCode, acpt_Type, org_Id, clr_Date,"1");
				}
				//生成黑名单
				if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_GJ0"))){
					user=this.getSysConfigurationParameters("gj_ftp_user0");
					password=this.getSysConfigurationParameters("gj_ftp_password0");
					ftpClient = reConnectFtp_gj(ftpClient,user,password,this.getSysConfigurationParameters("gj_ftp_ip0"));
				}else if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_HNCG"))){
					user=this.getSysConfigurationParameters("hncg_ftp_user");
					password=this.getSysConfigurationParameters("hncg_ftp_password");
					ftpClient = reConnectFtp_gj(ftpClient,user,password,this.getSysConfigurationParameters("hncg_ftp_ip"));
				} else {
					DefaultFTPClient.writeLog("无效商户编号"+sysdate);
				} 
				//FileUtil.createDir(ftpClient, this.getSysConfigurationParameters("gj_ftp_download") + "/" +sysdate+"/");//按每天的日期生成一个目录 
				if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_GJ0"))){
					//writeBlackFile_Gj(ftpClient,sysdate);//全黑名单
				}else if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_HNCG"))){
//					writeBlackFile_Gj(ftpClient,sysdate);//全黑名单
				}else{
					DefaultFTPClient.writeLog("写黑名单无效商户编号"+sysdate);
				}
			}
		
			return "调整帐成功";
		}catch(Exception ex){
			ex.printStackTrace();
			throw new CommonException("调整账失败：" + ex.getMessage());
		}finally{
			DefaultFTPClient.writeLog("====================================结束处理公交脱机数据!");
			try{
				if(ftpClient !=null){
					ftpClient.closeServer();
				}
			}catch(Exception ex){
				ex.printStackTrace();
			}
		}
	}
	
	/**
	 * 对一家商户脱机数据处理
	 * @param ftpClient
	 * @param biz_Id
	 * @param sysdate
	 * @param tr_Code
	 * @param acpt_Type
	 * @param org_Id
	 * @param clr_Date
	 * @param type	1 表示公交，2表示公交0-
	 * @return
	 * @throws CommonException
	 */
	public String adjustOfflineData_Gj(FtpClient ftpClient,String user,String password,String biz_Id,String sysdate,Integer dealCode,
			String acpt_Type,String org_Id,String clr_Date,String type) throws CommonException{
		int serial=0;
		try{
			//FileUtil.createDir(ftpClient, this.getSysConfigurationParameters("gj_ftp_download") + "/" +sysdate+"/");
			String fileName = ""; 
			String deal_Batch_No = clr_Date;
			DefaultFTPClient.writeLog("deal_Batch_No==" + deal_Batch_No);
			String noNum = Tools.tensileString(this.getSequenceByName("SEQ_BATCHFILE_NUM"),5,true,"0");//整体文件序列号
			StringBuffer nssb = new StringBuffer();
			
			List list=publicDao.findBySQL("select send_file_name from pay_offline_filename  t where t.merchant_id='"+biz_Id+"' and deal_batch_no = '" + deal_Batch_No + "'");
			if(list.size()==0){
				return "1";
			}
			for(int i=0;i<list.size();i++){
				fileName = list.get(i).toString();
				//已清算记录
				if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_GJ0"))){
					nssb.append(Tools.tensileString(fileName,30,false," "));//FileName	ANS30	已清算文件名	要求文件名长度为30
				}else{
					nssb.append(Tools.tensileString(fileName,36,false," "));//FileName	ANS36	已清算文件名	要求文件名长度为36
				}
				nssb.append(sysdate);//Sndate	N8	清算日期	YYYYMMDD
				nssb.append(Tools.tensileString("F",8,true,"F"));//Reserved	ANS8	保留域	全F
				nssb.append("\n\r");
			}
				
			if (writeSS_Gj_Jx(ftpClient,deal_Batch_No,biz_Id,sysdate,type,noNum) <0 ){//SS文件
				//SS写拒付文件出错
			}
			//对公交商户产生清算文件
			if (writeQS_Gj(ftpClient,deal_Batch_No,biz_Id,sysdate,type,noNum) <0){//QS文件
				//写QS清算文件出错
			}
			//已清算文件名
			DefaultFTPClient.writeLog("写已清算NS文件名开始==");
//			文件名
			String  settledFileName = "NS" + sysdate + "01" + Tools.tensileString(biz_Id,15,true,"0") + noNum;
			StringBuffer sb1 = new StringBuffer();
			//写文件头
			sb1.append("NS");//Filetype	N2	文件标识	NS
			sb1.append("01");//N2行业代码公交01、
			sb1.append(Tools.tensileString(""+list.size(),8,true,"0"));//RecNum	N8	记录总数
			sb1.append("00000046");//RecLength	N8	记录长度	单条记录的长度
			sb1.append(Tools.tensileString("F",24,true,"F"));//Reserved	ANS24	保留域	全F
			sb1.append("\n\r");
			//记录
			sb1.append(nssb.toString());
			if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_GJ0"))){
				user=this.getSysConfigurationParameters("gj_ftp_user0");
				password=this.getSysConfigurationParameters("gj_ftp_password0");
				ftpClient = reConnectFtp_gj(ftpClient,user,password,this.getSysConfigurationParameters("gj_ftp_ip0"));
				writeFile(ftpClient,this.getSysConfigurationParameters("gj_ftp_download") + "/"+ settledFileName,sb1.toString());
				writeFile(ftpClient,this.getSysConfigurationParameters("gj_ftp_historyfiles") + "/"+ settledFileName,sb1.toString());
			}else if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_HNCG"))){
				user=this.getSysConfigurationParameters("hncg_ftp_user");
				password=this.getSysConfigurationParameters("hncg_ftp_password");
				ftpClient = reConnectFtp_gj(ftpClient,user,password,this.getSysConfigurationParameters("hncg_ftp_ip"));
				writeFile(ftpClient,this.getSysConfigurationParameters("hncg_ftp_download") + "/"+ settledFileName,sb1.toString());
				 writeFile(ftpClient,this.getSysConfigurationParameters("hncg_ftp_historyfiles") + "/"+ settledFileName,sb1.toString());
			} else {
				DefaultFTPClient.writeLog("无效商户编号"+sysdate);
				return "-1";
			} 
			DefaultFTPClient.writeLog("写已清算文件名结束==");
			deal_Batch_No = deal_Batch_No.replace("-", "");
			publicDao.doSql("update pay_offline_filename f set f.state = '4' where f.merchant_id = '" + biz_Id + "' and deal_batch_no = '" + deal_Batch_No + "'");
			publicDao.doSql("commit");
			return "1";
		}catch(Exception e){
			DefaultFTPClient.writeLog("error：" + e.getMessage());
			return "-1";
		}
	}
	/**
	 * 写已清算文件
	 *//*

	public int writeYiRefusfile_Gj(FtpClient ftpClient,String deal_Batch_No,String biz_Id,String sysdate,String type,String noNum) throws CommonException{
		DefaultFTPClient.writeLog("写已清算文件");
		List list =this.findBySql(" select s.send_file_name from ("+
				 " select t.send_file_name from Pay_Offline_black t  where t.send_file_name!='f' and  t.acpt_id='"+biz_Id+"' and  t.deal_Batch_No ='"+deal_Batch_No+"'  group by t.send_file_name"+
				 " union "+
				 " select r.send_file_name from pay_offline r  where  r.acpt_id='"+biz_Id+"' and  r.deal_Batch_No ='"+deal_Batch_No+"'  group by r.batch_file_name"+
				 " ) s");
		//已清算文件名
		DefaultFTPClient.writeLog("写已清算文件名开始==");
//		文件名
		String  settledFileName = "NS" + sysdate + "01" + Tools.tensileString(biz_Id,15,true,"0") + noNum;
		StringBuffer sb1 = new StringBuffer();
		//写文件头
		sb1.append("NS");//Filetype	N2	文件标识	NS
		sb1.append("01");//N2行业代码公交01、
		sb1.append(Tools.tensileString(list.size()+"",8,true,"0"));//RecNum	N8	记录总数
		sb1.append("00000046");//RecLength	N8	记录长度	单条记录的长度
		sb1.append(Tools.tensileString("F",24,true,"F"));//Reserved	ANS24	保留域	全F
		sb1.append("\n\r");
		
		//写记录
		StringBuffer nssb = new StringBuffer();
		for(int i=0;i<list.size();i++){
			Object o = (Object)list.get(i);
			//已清算记录
			nssb.append(Tools.tensileString(o.toString(),30,false," "));//FileName	ANS30	已清算文件名	上传的消费文件名
			nssb.append(sysdate);//Sndate	N8	清算日期	YYYYMMDD
			nssb.append(Tools.tensileString("F",8,true,"F"));//Reserved	ANS8	保留域	全F
			nssb.append("\n\r");
		}
		//记录
		sb1.append(nssb.toString());
		
		DefaultFTPClient.writeLog("写已清算文件名结束==");
		writeFile(ftpClient,this.getSysConfigurationParameters("gj_ftp_download") + "/" +sysdate+"/"+ settledFileName,sb1.toString());
		return writeFile(ftpClient,this.getSysConfigurationParameters("gj_ftp_historyfiles") + "/" + settledFileName,sb1.toString());
	}*/
	/**
	 * 写拒付SS文件
	 * 拒付：trbatchno.deal_batch_no='..' and (in black or 后来被调整(refuse_reason='00')) 
	 * 调整：消费表deal_batch_no = '..' and refuse_reason = '00'
	 * 调整拒付：消费表deal_batch_no = '..' and refuse_reason='09'
	 */
	@SuppressWarnings("rawtypes")
	public int writeSS_Gj(FtpClient ftpClient,String deal_Batch_No,String biz_Id,String sysdate,String type,String noNum) throws CommonException{
		DefaultFTPClient.writeLog("写拒付SS文件");
		StringBuffer sb1 = new StringBuffer();
		//拒付
		sb1.append("select t2.Send_File_Name,decode(t2.Refuse_Reason,'00',decode(t2.ash_flag,'01','04','01'),'09',decode(t2.ash_flag,'01','04','01'),t2.Refuse_Reason) as Refuse_Reason,t2.File_Line_No,t2.end_deal_no from pay_offline_filename t1,Pay_Offline_black t2 where t1.send_file_name = t2.send_file_name and t1.merchant_id = '" + biz_Id + "' and t1.deal_batch_no = '" + deal_Batch_No + "'");
		sb1.append(" union all ");
		//拒付--重新生成历史--后来被调整
		sb1.append("select t2.Send_File_Name,decode(t2.ash_flag,'01','04','01') as Refuse_Reason,t2.File_Line_No,t2.end_deal_no from pay_offline_filename t1,pay_offline t2 where t1.send_file_name = t2.send_file_name and t1.merchant_id = '" + biz_Id + "' and t1.deal_batch_no = '" + deal_Batch_No + "' and refuse_reason = '00'");
		sb1.append(" union all ");
		//调整
		sb1.append("select Send_File_Name,t.Refuse_Reason,t.File_Line_No,t.end_deal_no from pay_offline_list t where t.acpt_id = '" + biz_Id + "' and deal_Batch_No = '" + deal_Batch_No + "'  and refuse_reason = '00'");
		sb1.append(" union all ");
		//调整拒付
		sb1.append("select t.Send_File_Name,t.Refuse_Reason,t.File_Line_No,t.end_deal_no from Pay_Offline_black t where t.acpt_id = '" + biz_Id + "' and t.deal_Batch_No = '" + deal_Batch_No + "' and refuse_reason = '09'");
		
		List list = publicDao.findBySQL(" select Send_File_Name,Refuse_Reason,File_Line_No,end_deal_no from ( "+ sb1.toString() + ") order by send_File_Name, file_Line_No");
		String fileName="";
		//文件名
		fileName = "SS" + sysdate + "01" + Tools.tensileString(biz_Id,15,true,"0") + noNum;
		
		StringBuffer sb = new StringBuffer();
		//写文件头
		sb.append("SS01");//Filetype	N2	文件标识	SS Callingno	N2	行业代码	公交01
		sb.append(Tools.tensileString(""+list.size(),8,true,"0"));//RecNum	N8	记录总数
		sb.append("00000198");//RecLength	N8	记录长度	单条记录的长度
		sb.append(Tools.tensileString("F",24,true,"F"));//Reserved	ANS24	保留域	全F
		sb.append("\n\r");
		//写记录
		for(int i=0;i<list.size();i++){
			Object[] o = (Object[])list.get(i);
			sb.append(Tools.tensileString(Tools.processNull(o[0]),40,false," "));//FileName	AN40	所属文件名
			sb.append(sysdate);//Ssdate	N8	拒付交易发生结算日期（调整当天日期）	交易全‘F’（发卡方调整结算日期）
			sb.append(Tools.tensileString(Tools.processNull(o[1]),2,true,"0"));//RefuseCause	N2	拒付原因	00－卡片发行方调整01－TAC码错02－数据非法    03－数据重复    04－灰记录    05－超时92 – 数据非法调整据付93 – 数据重复调整拒付94 – 灰记录调整拒付90-其它错误
			sb.append(Tools.tensileString(biz_Id,15,true,"0"));//Deptno	N15	商户代码
			sb.append(Tools.tensileString(Tools.processNull(o[2]),10,true,"0"));//消费文件中的行号 N10
			sb.append(Tools.tensileString(Tools.processNull( o[3]),10,true,"0"));//Orderno	N10	本地流水号	与所属消费文件中的本地流水号一致
			sb.append(Tools.tensileString("0",8,true,"0"));//保留 N8		
			sb.append("\n\r");//
		}
		String user;
		String password;
		if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_GJ0"))){
			user=this.getSysConfigurationParameters("gj_ftp_user0");
			password=this.getSysConfigurationParameters("gj_ftp_password0");
			ftpClient = reConnectFtp_gj(ftpClient,user,password,this.getSysConfigurationParameters("gj_ftp_ip0"));
		}else if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_HNCG"))){
			user=this.getSysConfigurationParameters("hncg_ftp_user");
			password=this.getSysConfigurationParameters("hncg_ftp_password");
			ftpClient = reConnectFtp_gj(ftpClient,user,password,this.getSysConfigurationParameters("hncg_ftp_ip"));
		}else{
			DefaultFTPClient.writeLog("无效商户编号"+sysdate);
		}
		writeFile(ftpClient,this.getSysConfigurationParameters("gj_ftp_historyfiles") + "/" + fileName,sb.toString());
		return writeFile(ftpClient,this.getSysConfigurationParameters("gj_ftp_download") +"/" + fileName,sb.toString());
	}
	/**
	 * 写拒付SS文件
	 * 拒付：trbatchno.deal_batch_no='..' and (in black or 后来被调整(refuse_reason='00')) 
	 * 调整：消费表deal_batch_no = '..' and refuse_reason = '00'
	 * 调整拒付：消费表deal_batch_no = '..' and refuse_reason='09'
	 */
	@SuppressWarnings("rawtypes")
	public int writeSS_Gj_Jx(FtpClient ftpClient,String deal_Batch_No,String biz_Id,String sysdate,String type,String noNum) throws CommonException{
		DefaultFTPClient.writeLog("写拒付SS文件");
		StringBuffer sb1 = new StringBuffer();
		//拒付
		sb1.append(" select t1.send_file_name,t1.end_deal_no,decode(t1.Refuse_Reason,'00',decode(t1.ash_flag,'01','04','01'),'09',decode(t1.ash_flag,'01','04','01'),t1.Refuse_Reason) as Refuse_Reason,t1.end_id,t1.card_no,t1.card_in_type,t1.card_in_subtype,t1.card_valid_date,t1.card_start_date,t1.app_valid_date,t1.card_deal_count,t1.psam_deal_no,t1.acc_bal,t1.deal_amt,t1.deal_date,t1.deal_kind,t1.psam_no,t1.tac,t1.deal_state,t1.FILE_LINE_NO  from pay_offline_filename t0,Pay_Offline_black t1 where t0.send_file_name = t1.send_file_name and t0.merchant_id = '" + biz_Id + "' and t0.deal_batch_no = '" + deal_Batch_No + "'");
		sb1.append(" union all ");
		//拒付--重新生成历史--后来被调整
		sb1.append(" select t2.send_file_name,t2.end_deal_no,decode(t2.Refuse_Reason,'00',decode(t2.ash_flag,'01','04','01'),'09',decode(t2.ash_flag,'01','04','01'),t2.Refuse_Reason) as Refuse_Reason,t2.end_id,t2.card_no,t2.card_in_type,t2.card_in_subtype,t2.card_valid_date,t2.card_start_date,t2.app_valid_date,t2.card_deal_count,t2.psam_deal_no,t2.acc_bal,t2.deal_amt,t2.deal_date,t2.deal_kind,t2.psam_no,t2.tac,t2.deal_state,t2.FILE_LINE_NO  from pay_offline_filename t1,pay_offline t2 where t1.send_file_name = t2.send_file_name and t1.merchant_id = '" + biz_Id + "' and t1.deal_batch_no = '" + deal_Batch_No + "' and t2.refuse_reason = '00'");
		sb1.append(" union all ");
		//调整
		sb1.append(" select t3.send_file_name,t3.end_deal_no,decode(t3.Refuse_Reason,'00',decode(t3.ash_flag,'01','04','01'),'09',decode(t3.ash_flag,'01','04','01'),t3.Refuse_Reason) as Refuse_Reason,t3.end_id,t3.card_no,t3.card_in_type,t3.card_in_subtype,t3.card_valid_date,t3.card_start_date,t3.app_valid_date,t3.card_deal_count,t3.psam_deal_no,t3.acc_bal,t3.deal_amt,t3.deal_date,t3.deal_kind,t3.psam_no,t3.tac,t3.deal_state,t3.FILE_LINE_NO  from pay_offline_list t3 where t3.acpt_id = '" + biz_Id + "' and t3.deal_Batch_No = '" + deal_Batch_No + "'  and t3.refuse_reason = '00'");
		sb1.append(" union all ");
		//调整拒付
		sb1.append(" select t4.send_file_name,t4.end_deal_no,decode(t4.Refuse_Reason,'00',decode(t4.ash_flag,'01','04','01'),'09',decode(t4.ash_flag,'01','04','01'),t4.Refuse_Reason) as Refuse_Reason,t4.end_id,t4.card_no,t4.card_in_type,t4.card_in_subtype,t4.card_valid_date,t4.card_start_date,t4.app_valid_date,t4.card_deal_count,t4.psam_deal_no,t4.acc_bal,t4.deal_amt,t4.deal_date,t4.deal_kind,t4.psam_no,t4.tac,t4.deal_state,t4.FILE_LINE_NO from Pay_Offline_black t4 where t4.acpt_id = '" + biz_Id + "' and t4.deal_Batch_No = '" + deal_Batch_No + "' and t4.refuse_reason = '09'");
		List list = publicDao.findBySQL(" select t.send_file_name,t.end_deal_no,t.Refuse_Reason,t.end_id,t.card_no,t.card_in_type,t.card_in_subtype,t.card_valid_date,t.card_start_date,t.app_valid_date,t.card_deal_count,t.psam_deal_no,t.acc_bal,t.deal_amt,t.deal_date,t.deal_kind,t.psam_no,t.tac,t.deal_state from ( "+ sb1.toString() + ") t order by send_File_Name, FILE_LINE_NO");
		String fileName="";
		int num=list.size();
		String user="";
		String password="";
		Object[] o =null;
        //文件名
		fileName = "SS" + sysdate + "01" + Tools.tensileString(biz_Id,15,true,"0") + noNum;
		StringBuffer sb = new StringBuffer();
 		//写文件头
 		sb.append("SS01");//Filetype	N2	文件标识	SS Callingno	N2	行业代码	公交01
 		sb.append(Tools.tensileString(""+num,8,true,"0"));//RecNum	N8	记录总数
 		sb.append("00000198");//RecLength	N8	记录长度	单条记录的长度
 		sb.append(Tools.tensileString("F",24,true,"F"));//Reserved	ANS24	保留域	全F
 		sb.append("\n\r");
	    for (int i=0;i<num;i++){
	    	o = (Object[])list.get(i);
	 		sb.append(Tools.tensileString(Tools.processNull(o[0]),30,false," "));//FileName	AN40	所属文件名
	 		sb.append(Tools.tensileString("" + Tools.processNull(o[1]),8,true,"0"));//Orderno	N8	本地流水号	与所属消费文件中的本地流水号一致
	 		sb.append(sysdate);//Ssdate	N8	拒付交易发生结算日期（调整当天日期）	交易全‘F’（发卡方调整结算日期）
	 		sb.append(Tools.tensileString(Tools.processNull(o[2]),2,true,"0"));//RefuseCause	N2	拒付原因	00－卡片发行方调整01－TAC码错02－数据非法    03－数据重复    04－灰记录    05－超时92 – 数据非法调整据付93 – 数据重复调整拒付94 – 灰记录调整拒付90-其它错误
	 		sb.append(Tools.tensileString(biz_Id,15,true,"0"));//Deptno	N15	商户代码
	 		sb.append(Tools.tensileString(Tools.processNull(o[3]),8,true,"0"));//Termid	N8	POS机号
	 		sb.append(Tools.tensileString(Tools.processNull(o[4]),8,true,"0"));//Cardno	N20	卡应用序列号	发行流水号
	 		sb.append(Tools.tensileString(Tools.processNull(o[5]),2,true,"0"));//Cardtype	N2	卡主类型	
	 		sb.append(Tools.tensileString(Tools.processNull(o[6]),2,true,"0"));//Cardchildtype	N2	卡子类型	
	 		sb.append(Tools.processNull(o[7]));//Cardvaliddate	N8	卡有效期	YYYYMMDD
	 		sb.append(Tools.processNull(o[8]));//Applyusedate	N8	应用启动日期
	 		sb.append(Tools.processNull(o[9]));//Applyvaliddate	N8	应用有效日期	YYYYMMDD
	 		sb.append(Tools.tensileString("" + Tools.processNull(o[10]),6,true,"0"));//Moneynum	N6	电子钱包交易序号
	 		sb.append(Tools.tensileString("" + Tools.processNull(o[11]),10,true,"0"));//Psamnum	N10	终端交易序号	PSAM卡交易序号
	 		sb.append(Tools.tensileString("" + Tools.processNull(o[12]),8,true,"0"));//Cardmoney	N8	交易前金额	单位到分
	 		sb.append(Tools.tensileString("" + Tools.processNull(o[13]),8,true,"0"));//Trademoney	N8	交易金额	单位到分
	 		sb.append(DateUtil.formatDate(Tools.processNull(o[14]), "yyyyMMddHHmmss"));//Tradetime	N14	交易日期和时间	YYYYMMDDHHMMSS
	 		sb.append(Tools.processNull(o[15]));//Tradetype	N2	交易类型	09复合应用电子钱包消费06普通电子钱包消费
	 		sb.append(Tools.tensileString(Tools.processNull(o[16]),12,true,"0"));//Psamid	N12	PSAM卡终端编号
	 		sb.append(Tools.processNull(o[17]));//Tac	N8	交易认证码	TAC
	 		if(Tools.processNull(o[18]).equals("9")){
	 			sb.append("01");//Flag	N2	灰记录标志	01表示灰记录00表示正常记录
	 		}else{
	 			sb.append("00");
	 		}
	 		sb.append("00");//Monthtype	N2	月票标志	00普通消费, 01月票，02季票消费，03年票消费
	 		sb.append("0");//Monthflag	N1	月票扣钱标志	如果为月票则1表示扣当月(季)的钱2表示扣上个月(季)多余的钱不为月票则填0
	 		sb.append(Tools.tensileString("F",6,true,"F"));//Reserved	ANS6	保留域	全F/如果扣上期的月票钱包，此处填此次消费金额
	 		//sb.append("\n");//	
	 		sb.append("\n\r");//
		  }
		if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_GJ0"))){
			user=this.getSysConfigurationParameters("gj_ftp_user0");
			password=this.getSysConfigurationParameters("gj_ftp_password0");
			ftpClient = reConnectFtp_gj(ftpClient,user,password,this.getSysConfigurationParameters("gj_ftp_ip0"));
			//writeFile(ftpClient,this.getSysConfigurationParameters("gj_ftp_historyfiles") + "/" + fileName,sb.toString());
		     writeFile(ftpClient,this.getSysConfigurationParameters("gj_ftp_download") +"/" + fileName,sb.toString());
		}else if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_HNCG"))){
			user=this.getSysConfigurationParameters("hncg_ftp_user");
			password=this.getSysConfigurationParameters("hncg_ftp_password");
			ftpClient = reConnectFtp_gj(ftpClient,user,password,this.getSysConfigurationParameters("hncg_ftp_ip"));
			//writeFile(ftpClient,this.getSysConfigurationParameters("hncg_ftp_historyfiles") + "/" + fileName,sb.toString());
		    writeFile(ftpClient,this.getSysConfigurationParameters("hncg_ftp_download") +"/" + fileName,sb.toString());
		}else{
			DefaultFTPClient.writeLog("无效商户编号"+sysdate);
			return 0;
		}
		return 1;
	}
	/**
	 * 写清算QS文件
	 * 确认：消费表deal_batch_no = '..' and  refuse_reason = '10'
	 * 拒付：trbatchno.deal_batch_no='..' and (in black or 后来被调整(refuse_reason='00')) 
	 * 调整：消费表deal_batch_no = '..' and refuse_reason = '00'
	 * 调整拒付：消费表deal_batch_no = '..' and refuse_reason='09'
	 */
	private int writeQS_Gj(FtpClient ftpClient,String deal_Batch_No,String biz_Id,String sysdate,String type,String noNum) throws CommonException{
		try{
			DefaultFTPClient.writeLog("写清算QS文件");
			StringBuffer sb = new StringBuffer();
			//写文件头
			sb.append("QS");//Filetype	N2	文件标识	QS
			sb.append(Tools.tensileString("1",8,true,"0"));//RecNum	N8	记录总数
			sb.append("00000103");//RecLength	N8	记录长度	单条记录的长度
			sb.append(Tools.tensileString("F",24,true,"F"));//Reserved	ANS24	保留域	全F
			sb.append("\n\r");
			//写记录
			sb.append(Tools.tensileString(biz_Id,15,true,"0"));//Deptno	N15	商户代码
			sb.append(sysdate);//SettDate	N8	结算日期	YYYYMMDD
			//确认--当天
			Object[] objects = (Object[])this.findOnlyRowBySql("select count(*) as cnt,nvl(sum(deal_amt),0) as deal_amt from pay_offline_list t where t.acpt_id = '" + biz_Id + "' and t.deal_batch_no = '" + deal_Batch_No + "' and  refuse_reason = '10'");
			long fhCmTimes = ((BigDecimal)objects[0]).longValue();
			long fhCmMoney = ((BigDecimal)objects[1]).longValue();
	
			sb.append(Tools.tensileString("" +fhCmTimes,8,true,"0"));//FhCmTimes	N8	消费确认笔数	
			sb.append(Tools.tensileString("" +fhCmMoney,10,true,"0"));//FhCmMoney	N10	消费确认金额	
			//拒付--
			objects =  (Object[])this.findOnlyRowBySql("select count(*) as cnt,nvl(sum(deal_amt),0) as deal_amt from pay_offline_filename t1,Pay_Offline_black t2 where t1.send_file_name = t2.send_file_name and t1.merchant_id = '" + biz_Id + "' and t1.deal_batch_no = '" + deal_Batch_No + "'");
			long fhRefuseTimes = ((BigDecimal)objects[0]).longValue();
			long fhRefuseMoney = ((BigDecimal)objects[1]).longValue();

			sb.append(Tools.tensileString("" +fhRefuseTimes,8,true,"0"));//FhRefuseTimes	N8	消费拒付笔数	
			sb.append(Tools.tensileString("" +fhRefuseMoney,10,true,"0"));//FhRefuseMoney	N10	消费拒付金额	
			//调整--当天生成
			objects =  (Object[])this.findOnlyRowBySql("select count(*) as cnt,nvl(sum(deal_amt),0) as deal_amt from pay_offline_list t where t.acpt_id = '" + biz_Id + "' and deal_Batch_No = '" + deal_Batch_No + "'   and refuse_reason = '00'");
			long adjTimes = ((BigDecimal)objects[0]).longValue();
			long adjMoney = ((BigDecimal)objects[1]).longValue();

			sb.append(Tools.tensileString("" +adjTimes,8,true,"0"));//AdjTimes	N8	调整笔数	
			sb.append(Tools.tensileString("" +adjMoney,10,true,"0"));//AdjMoney	N10	调整金额	
			//调整拒付
			objects =  (Object[])this.findOnlyRowBySql("select count(*) as cnt,nvl(sum(deal_amt),0) as deal_amt from Pay_Offline_black t where t.acpt_id = '" + biz_Id + "' and deal_Batch_No = '" + deal_Batch_No + "' and refuse_reason = '09' ");
			long adjRefuseTimes = ((BigDecimal)objects[0]).longValue();
			long adjRefuseMoney = ((BigDecimal)objects[1]).longValue();
			sb.append(Tools.tensileString("" +adjRefuseTimes,8,true,"0"));//AdjRefuseTimes	N8	调整拒付笔数	
			sb.append(Tools.tensileString("" +adjRefuseMoney,10,true,"0"));//AdjRefuseMoney	N10	调整拒付金额 	
			sb.append(Tools.tensileString("0",8,true,"0"));//Reserved	ANS8	保留域	全0
			//文件名
			String  fileName = "QS" + sysdate + "01" + Tools.tensileString(biz_Id,15,true,"0") + noNum;
			String user;
			String password;
			if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_GJ0"))){
				user=this.getSysConfigurationParameters("gj_ftp_user0");
				password=this.getSysConfigurationParameters("gj_ftp_password0");
				ftpClient = reConnectFtp_gj(ftpClient,user,password,this.getSysConfigurationParameters("gj_ftp_ip0"));
				writeFile(ftpClient,this.getSysConfigurationParameters("gj_ftp_historyfiles") + "/" + fileName,sb.toString());
				return writeFile(ftpClient,this.getSysConfigurationParameters("gj_ftp_download") + "/" + fileName,sb.toString());
			}else if(biz_Id.equals(this.getSysConfigurationParameters("BIZ_ID_HNCG"))){
				user=this.getSysConfigurationParameters("hncg_ftp_user");
				password=this.getSysConfigurationParameters("hncg_ftp_password");
				ftpClient = reConnectFtp_gj(ftpClient,user,password,this.getSysConfigurationParameters("hncg_ftp_ip"));
				writeFile(ftpClient,this.getSysConfigurationParameters("hncg_ftp_historyfiles") + "/" + fileName,sb.toString());
				return writeFile(ftpClient,this.getSysConfigurationParameters("hncg_ftp_download") + "/" + fileName,sb.toString());
			}else{
				DefaultFTPClient.writeLog("无效商户编号"+sysdate);
				return 0;
			}
			
		}catch(Exception e){
			DefaultFTPClient.writeLog("写清算文件失败：" + e.getMessage());
			return 0;
		}
		
	}
	
	/**
	 * 写黑名单文件
	 */
	@SuppressWarnings("rawtypes")
	public int writeBlackFile_Gj(FtpClient ftpClient,String sysdate) throws CommonException{
		DefaultFTPClient.writeLog("写黑名单文件");
		List list = new java.util.ArrayList();
		//文件名YYYYMMDD_Black.txt;
		String fileName = sysdate + "_Black.txt";
		StringBuffer sb = new StringBuffer();
		//写文件头
		sb.append(sysdate);//Blackversion	N8	黑名单版本	YYYYMMDD
		//写记录
		list = this.findBySql("select t1.card_no from card_baseinfo t1,card_black t2 where t1.card_Id = t2.card_Id and t2.blk_State = '0'");//黑名单列表
		sb.append(Tools.tensileString(""+list.size(),6,true,"0"));//RecNum	N6	记录总数
		sb.append("\n\r");
		for(int i=0;i<list.size();i++){
			String card_No =  list.get(i).toString();
			sb.append(Tools.tensileString(card_No,20,true,"0"));//Cardno	N20	卡应用序列号	发行流水号(卡面号)
			sb.append("00");//名单等级	默认00
			sb.append("\n\r");//
		}
		writeFile(ftpClient,this.getSysConfigurationParameters("gj_ftp_historyfiles") + "/" + fileName,sb.toString());
		return writeFile(ftpClient,this.getSysConfigurationParameters("gj_ftp_download") + "/"  + fileName,sb.toString());
	}


	private FtpClient reConnectFtp_gj(FtpClient ftpClient,String user,String password,String host_ip){
		DefaultFTPClient.writeLog("开始连接公交ftp");
		try{
			ftpClient=new FtpClient(host_ip,21);
			ftpClient.login(user,password);
			//ftpClient.cd("/");C:\ftp\001
			ftpClient.cd("/");
			ftpClient.binary();
		}catch(Exception e){
			DefaultFTPClient.writeLog("连接公交ftp出错：" + e.getMessage());
		}
		return ftpClient;
	}

	@Override
	/**
	 * 自行车脱机返回数据
	 * 1.自行车文件批处理入库插入临时表
	 * 2.对临时表中所有记录做验证，包括（非法，灰记录，重复记录，TAC验证）
	 * 3.对拒付表中的记录做调整
	 * 4.对自行车商户产生清算文件
	 */
	@SuppressWarnings("rawtypes")
	public String saveOfflineData_Zxc() throws CommonException{
		DefaultFTPClient.writeLog("=============开始处理自行车脱机返回数据!");
		FtpClient ftpClient=null;
		String biz_Id = "";// = "041010010010001";
		Integer dealCode = DealCode.OFFLINE_CONSUME;
		String sysdate = publicDao.getDateBaseTimeStr("yyyyMMdd");
		DefaultFTPClient.writeLog("sysdate:" + sysdate);
		String clr_Date=getBeforeClrDate();
		DefaultFTPClient.writeLog("clr_Date:" + clr_Date);
		try{
			List list=(List)publicDao.findBySQL("select ftp_use from SYS_FTP_CONF t where t.ftp_use like 'zxc_%' group by t.ftp_use ");
		    if(list!=null && list.size()>0){
		    	String ftp_use=null;
		    	String user_name="";
				String password="",host_ip="";
		    	logger.error("#正在检查自行车FTP配置信息");
		    	for(int i=0;i<list.size();i++){//多个自行车商户
		    		ftp_use=(String)list.get(i);
		    		Map<String,String>  ftpOptions = this.initFtpOptions(ftp_use);
					biz_Id = ((String)ftp_use.substring(4, 19));//zxc_041010010010007格式
					user_name=ftpOptions.get("user_name");
					password=ftpOptions.get("pwd");
					host_ip=ftpOptions.get("host_ip");
					ftpClient = reConnectFtp_Zxc(ftpClient,user_name,password,host_ip);
					BaseMerchant merchart=(BaseMerchant)this.findOnlyRowByHql("from BaseMerchant t where t.merchantId='"+biz_Id+"'");
					DefaultFTPClient.writeLog("商户号：" + biz_Id + "，商户名称：" + merchart.getMerchantName());
					List list_clrDate = publicDao.findBySQL("select deal_batch_no from pay_offline_filename t where t.merchant_id='"+biz_Id+"' and state='3' group by deal_batch_no order by deal_batch_no ");
					for(int ii=0;ii<list_clrDate.size();ii++){
						clr_Date = list_clrDate.get(ii).toString();
						sysdate = clr_Date.replace("-", "");
						this.adjustOfflineData_Zxc(ftpClient,user_name,password, biz_Id, sysdate, dealCode, merchart.getOrgId(), clr_Date,"1",ftpOptions);
					}
				}
		    }
		
			return "脱机返回数据处理成功";
		}catch(Exception ex){
			ex.printStackTrace();
			throw new CommonException("脱机返回数据处理失败：" + ex.getMessage());
		}finally{
			DefaultFTPClient.writeLog("=============结束处理自行车脱机返回数据!");
			try{
				if(ftpClient !=null){
					ftpClient.closeServer();
				}
			}catch(Exception ex){
				ex.printStackTrace();
			}
		}
	}
	
	/**
	 * 对一家商户脱机返回数据处理
	 * @param ftpClient
	 * @param biz_Id
	 * @param sysdate
	 * @param tr_Code
	 * @param acpt_Type
	 * @param org_Id
	 * @param clr_Date
	 * @param type	1 表示公交，2表示公交0-
	 * @return
	 * @throws CommonException
	 */
	@SuppressWarnings("rawtypes")
	public String adjustOfflineData_Zxc(FtpClient ftpClient,String user_name,String password,String biz_Id,String sysdate,Integer dealCode,String org_Id,String clr_Date,String type,Map<String,String> ftpOptions) throws CommonException{
		try{
			String fileName = ""; 
			String deal_Batch_No = clr_Date;
			DefaultFTPClient.writeLog("deal_Batch_No" + deal_Batch_No);
			String noNum = Tools.tensileString(this.getSequenceByName("SEQ_BATCHFILE_NUM"),5,true,"0");//整体文件序列号
			StringBuffer nssb = new StringBuffer();
			
			List list=publicDao.findBySQL("select send_file_name from pay_offline_filename  t where t.merchant_id='"+biz_Id+"' and deal_batch_no = '" + deal_Batch_No + "'");
			if(list.size()==0)
				return "1";
			for(int i=0;i<list.size();i++){
				fileName = list.get(i).toString();
				//已清算记录
				nssb.append(Tools.tensileString(fileName,40,false," "));//FileName	ANS40	已清算文件名	上传的消费文件名
				nssb.append(sysdate);//Sndate	N8	清算日期	YYYYMMDD
				nssb.append(Tools.tensileString("F",8,true,"F"));//Reserved	ANS8	保留域	全F
				nssb.append("\n\r");
			}
				
			if (writeSS_Zxc_Jx(ftpClient,deal_Batch_No,biz_Id,sysdate,type,noNum,ftpOptions) <0 ){//SS文件
				//SS写拒付文件出错
			}
			//对公交商户产生清算文件
			if (writeQS_Zxc(ftpClient,deal_Batch_No,biz_Id,sysdate,type,noNum,ftpOptions) <0){//QS文件
				//写QS清算文件出错
			}
			//已清算文件名
			DefaultFTPClient.writeLog("写已清算NS文件名开始==");
//			文件名
			String  settledFileName = "NS" + sysdate + "01" + Tools.tensileString(biz_Id,15,true,"0") + noNum;
			StringBuffer sb1 = new StringBuffer();
			//写文件头
			sb1.append("NS");//Filetype	N2	文件标识	NS
			sb1.append("01");//N2行业代码公交01、
			sb1.append(Tools.tensileString(""+list.size(),8,true,"0"));//RecNum	N8	记录总数
			sb1.append("00000056");//RecLength	N8	记录长度	单条记录的长度
			sb1.append(Tools.tensileString("F",24,true,"F"));//Reserved	ANS24	保留域	全F
			sb1.append("\n\r");
			//记录
			sb1.append(nssb.toString());
			user_name=ftpOptions.get("user_name");
			password=ftpOptions.get("pwd");
			ftpClient = reConnectFtp_Zxc(ftpClient,user_name,password,ftpOptions.get("host_ip"));
			writeFile(ftpClient,ftpOptions.get("host_download_path")+ "/" + settledFileName,sb1.toString());
			writeFile(ftpClient,ftpOptions.get("host_history_path") + "/" + settledFileName,sb1.toString());
			DefaultFTPClient.writeLog("写已清算文件名结束==");
			
			publicDao.doSql("update pay_offline_filename set state = '4' where merchant_id = '" + biz_Id + "' and deal_batch_no = '" + sysdate + "'");
			publicDao.doSql("commit");
			return "1";
		}catch(Exception e){
			DefaultFTPClient.writeLog("error：" + e.getMessage());
			return "-1";
		}
	}

	/**
	 * 写拒付SS文件
	 * 拒付：trbatchno.deal_batch_no='..' and (in black or 后来被调整(refuse_reason='00')) 
	 * 调整：消费表deal_batch_no = '..' and refuse_reason = '00'
	 * 调整拒付：消费表deal_batch_no = '..' and refuse_reason='09'
	 */
	@SuppressWarnings("rawtypes")
	private int writeSS_Zxc_Jx(FtpClient ftpClient,String deal_Batch_No,String biz_Id,String sysdate,String type,String noNum,Map<String,String> ftpOptions) throws CommonException{
		DefaultFTPClient.writeLog("写拒付SS文件");
		StringBuffer sb1 = new StringBuffer();
		//拒付
		sb1.append(" select t1.send_file_name,t1.end_deal_no,decode(t1.Refuse_Reason,'00',decode(t1.ash_flag,'01','04','01'),'09',decode(t1.ash_flag,'01','04','01'),t1.Refuse_Reason) as Refuse_Reason,t1.end_id,t1.card_no,t1.card_in_type,t1.card_in_subtype,t1.card_valid_date,t1.card_start_date,t1.app_valid_date,t1.card_deal_count,t1.psam_deal_no,t1.acc_bal,t1.deal_amt,t1.deal_date,t1.deal_kind,t1.psam_no,t1.tac,t1.deal_state,t1.FILE_LINE_NO  from pay_offline_filename t0,Pay_Offline_black t1 where t0.send_file_name = t1.send_file_name and t0.merchant_id = '" + biz_Id + "' and t0.deal_batch_no = '" + deal_Batch_No + "'");
		sb1.append(" union all ");
		//拒付--重新生成历史--后来被调整
		sb1.append(" select t2.send_file_name,t2.end_deal_no,decode(t2.Refuse_Reason,'00',decode(t2.ash_flag,'01','04','01'),'09',decode(t2.ash_flag,'01','04','01'),t2.Refuse_Reason) as Refuse_Reason,t2.end_id,t2.card_no,t2.card_in_type,t2.card_in_subtype,t2.card_valid_date,t2.card_start_date,t2.app_valid_date,t2.card_deal_count,t2.psam_deal_no,t2.acc_bal,t2.deal_amt,t2.deal_date,t2.deal_kind,t2.psam_no,t2.tac,t2.deal_state,t2.FILE_LINE_NO  from pay_offline_filename t1,pay_offline t2 where t1.send_file_name = t2.send_file_name and t1.merchant_id = '" + biz_Id + "' and t1.deal_batch_no = '" + deal_Batch_No + "' and t2.refuse_reason = '00'");
		sb1.append(" union all ");
		//调整
		sb1.append(" select t3.send_file_name,t3.end_deal_no,decode(t3.Refuse_Reason,'00',decode(t3.ash_flag,'01','04','01'),'09',decode(t3.ash_flag,'01','04','01'),t3.Refuse_Reason) as Refuse_Reason,t3.end_id,t3.card_no,t3.card_in_type,t3.card_in_subtype,t3.card_valid_date,t3.card_start_date,t3.app_valid_date,t3.card_deal_count,t3.psam_deal_no,t3.acc_bal,t3.deal_amt,t3.deal_date,t3.deal_kind,t3.psam_no,t3.tac,t3.deal_state,t3.FILE_LINE_NO  from pay_offline_list t3 where t3.acpt_id = '" + biz_Id + "' and t3.deal_Batch_No = '" + deal_Batch_No + "'  and t3.refuse_reason = '00'");
		sb1.append(" union all ");
		//调整拒付
		sb1.append(" select t4.send_file_name,t4.end_deal_no,decode(t4.Refuse_Reason,'00',decode(t4.ash_flag,'01','04','01'),'09',decode(t4.ash_flag,'01','04','01'),t4.Refuse_Reason) as Refuse_Reason,t4.end_id,t4.card_no,t4.card_in_type,t4.card_in_subtype,t4.card_valid_date,t4.card_start_date,t4.app_valid_date,t4.card_deal_count,t4.psam_deal_no,t4.acc_bal,t4.deal_amt,t4.deal_date,t4.deal_kind,t4.psam_no,t4.tac,t4.deal_state,t4.FILE_LINE_NO from Pay_Offline_black t4 where t4.acpt_id = '" + biz_Id + "' and t4.deal_Batch_No = '" + deal_Batch_No + "' and t4.refuse_reason = '09'");
		List list = publicDao.findBySQL(" select t.send_file_name,t.end_deal_no,t.Refuse_Reason,t.end_id,t.card_no,t.card_in_type,t.card_in_subtype,t.card_valid_date,t.card_start_date,t.app_valid_date,t.card_deal_count,t.psam_deal_no,t.acc_bal,t.deal_amt,t.deal_date,t.deal_kind,t.psam_no,t.tac,t.deal_state from ( "+ sb1.toString() + ") t order by send_File_Name, FILE_LINE_NO");
		String fileName="";
		//文件名
		fileName = "SS" + sysdate + "01" + Tools.tensileString(biz_Id,15,true,"0") + noNum;
		
		StringBuffer sb = new StringBuffer();
		//写文件头
		sb.append("SS01");//Filetype	N2	文件标识	SS Callingno	N2	行业代码	公交01
		sb.append(Tools.tensileString(""+list.size(),8,true,"0"));//RecNum	N8	记录总数
		sb.append("00000198");//RecLength	N8	记录长度	单条记录的长度
		sb.append(Tools.tensileString("F",24,true,"F"));//Reserved	ANS24	保留域	全F
		sb.append("\n\r");
		//t.send_file_name,t.end_deal_no,t.refuse_reason,t.end_id,t.card_no,t.card_in_type,t.card_in_subtype,
		//t.card_valid_date,t.card_start_date,t.app_valid_date,t.card_deal_count,t.psam_deal_no,t.acc_bal,t.deal_amt,
		//t.deal_date,t.deal_kind,t.psam_no,t.tac,t.deal_state
		//写记录
		for(int i=0;i<list.size();i++){
			Object[] o = (Object[])list.get(i);
			sb.append(Tools.tensileString(Tools.processNull(o[0]),30,false," "));//FileName	AN40	所属文件名
			sb.append(Tools.tensileString("" + Tools.processNull(o[1]),8,true,"0"));//Orderno	N8	本地流水号	与所属消费文件中的本地流水号一致
			sb.append(sysdate);//Ssdate	N8	拒付交易发生结算日期（调整当天日期）	交易全‘F’（发卡方调整结算日期）
			sb.append(Tools.tensileString(Tools.processNull(o[2]),2,true,"0"));//RefuseCause	N2	拒付原因	00－卡片发行方调整01－TAC码错02－数据非法    03－数据重复    04－灰记录    05－超时92 – 数据非法调整据付93 – 数据重复调整拒付94 – 灰记录调整拒付90-其它错误
			sb.append(Tools.tensileString(biz_Id,15,true,"0"));//Deptno	N15	商户代码
			sb.append(Tools.tensileString(Tools.processNull(o[3]),8,true,"0"));//Termid	N8	POS机号
			sb.append(Tools.tensileString(Tools.processNull(o[4]),8,true,"0"));//Cardno	N20	卡应用序列号	发行流水号
			sb.append(Tools.tensileString(Tools.processNull(o[5]),2,true,"0"));//Cardtype	N2	卡主类型	
			sb.append(Tools.tensileString(Tools.processNull(o[6]),2,true,"0"));//Cardchildtype	N2	卡子类型	
			sb.append(Tools.processNull(o[7]));//Cardvaliddate	N8	卡有效期	YYYYMMDD
			sb.append(Tools.processNull(o[8]));//Applyusedate	N8	应用启动日期
			sb.append(Tools.processNull(o[9]));//Applyvaliddate	N8	应用有效日期	YYYYMMDD
			sb.append(Tools.tensileString("" + Tools.processNull(o[10]),6,true,"0"));//Moneynum	N6	电子钱包交易序号
			sb.append(Tools.tensileString("" + Tools.processNull(o[11]),10,true,"0"));//Psamnum	N10	终端交易序号	PSAM卡交易序号
			sb.append(Tools.tensileString("" + Tools.processNull(o[12]),8,true,"0"));//Cardmoney	N8	交易前金额	单位到分
			sb.append(Tools.tensileString("" + Tools.processNull(o[13]),8,true,"0"));//Trademoney	N8	交易金额	单位到分
			sb.append(DateUtil.formatDate(Tools.processNull(o[14]), "yyyyMMddHHmmss"));//Tradetime	N14	交易日期和时间	YYYYMMDDHHMMSS
			sb.append(Tools.processNull(o[15]));//Tradetype	N2	交易类型	09复合应用电子钱包消费06普通电子钱包消费
			sb.append(Tools.tensileString(Tools.processNull(o[16]),12,true,"0"));//Psamid	N12	PSAM卡终端编号
			sb.append(Tools.processNull(o[17]));//Tac	N8	交易认证码	TAC
			if(Tools.processNull(o[18]).equals("9")){
				sb.append("01");//Flag	N2	灰记录标志	01表示灰记录00表示正常记录
			}else{
				sb.append("00");
			}
			sb.append("00");//Monthtype	N2	月票标志	00普通消费, 01月票，02季票消费，03年票消费
			sb.append("0");//Monthflag	N1	月票扣钱标志	如果为月票则1表示扣当月(季)的钱2表示扣上个月(季)多余的钱不为月票则填0
			
			sb.append(Tools.tensileString("F",6,true,"F"));//Reserved	ANS6	保留域	全F/如果扣上期的月票钱包，此处填此次消费金额
			//sb.append("\n");//	
			sb.append("\n\r");//
		}
		String user_name=ftpOptions.get("user_name");
		String password=ftpOptions.get("pwd");
		ftpClient = reConnectFtp_Zxc(ftpClient,user_name,password,ftpOptions.get("host_ip"));
		writeFile(ftpClient,ftpOptions.get("host_history_path") + "/" + fileName,sb.toString());
		return writeFile(ftpClient,ftpOptions.get("host_download_path") +"/" + fileName,sb.toString());
	}
	/**
	 * 写拒付SS文件
	 * 拒付：trbatchno.deal_batch_no='..' and (in black or 后来被调整(refuse_reason='00')) 
	 * 调整：消费表deal_batch_no = '..' and refuse_reason = '00'
	 * 调整拒付：消费表deal_batch_no = '..' and refuse_reason='09'
	 */
	@SuppressWarnings("rawtypes")
	private int writeSS_Zxc(FtpClient ftpClient,String deal_Batch_No,String biz_Id,String sysdate,String type,String noNum,Map<String,String> ftpOptions) throws CommonException{
		DefaultFTPClient.writeLog("写拒付SS文件");
		StringBuffer sb1 = new StringBuffer();
		//拒付
		sb1.append(" select t1.send_file_name,t1.end_deal_no,decode(t1.Refuse_Reason,'00',decode(t1.ash_flag,'01','04','01'),'09',decode(t1.ash_flag,'01','04','01'),t1.Refuse_Reason) as Refuse_Reason,t1.end_id,t1.card_no,t1.card_in_type,t1.card_in_subtype,t1.card_valid_date,t1.card_start_date,t1.app_valid_date,t1.card_deal_count,t1.psam_deal_no,t1.acc_bal,t1.deal_amt,t1.deal_date,t1.deal_kind,t1.psam_no,t1.tac,t1.deal_state,t1.FILE_LINE_NO  from pay_offline_filename t0,Pay_Offline_black t1 where t0.send_file_name = t1.send_file_name and t0.merchant_id = '" + biz_Id + "' and t0.deal_batch_no = '" + deal_Batch_No + "'");
		sb1.append(" union all ");
		//拒付--重新生成历史--后来被调整
		sb1.append(" select t2.send_file_name,t2.end_deal_no,decode(t2.Refuse_Reason,'00',decode(t2.ash_flag,'01','04','01'),'09',decode(t2.ash_flag,'01','04','01'),t2.Refuse_Reason) as Refuse_Reason,t2.end_id,t2.card_no,t2.card_in_type,t2.card_in_subtype,t2.card_valid_date,t2.card_start_date,t2.app_valid_date,t2.card_deal_count,t2.psam_deal_no,t2.acc_bal,t2.deal_amt,t2.deal_date,t2.deal_kind,t2.psam_no,t2.tac,t2.deal_state,t2.FILE_LINE_NO  from pay_offline_filename t1,pay_offline t2 where t1.send_file_name = t2.send_file_name and t1.merchant_id = '" + biz_Id + "' and t1.deal_batch_no = '" + deal_Batch_No + "' and t2.refuse_reason = '00'");
		sb1.append(" union all ");
		//调整
		sb1.append(" select t3.send_file_name,t3.end_deal_no,decode(t3.Refuse_Reason,'00',decode(t3.ash_flag,'01','04','01'),'09',decode(t3.ash_flag,'01','04','01'),t3.Refuse_Reason) as Refuse_Reason,t3.end_id,t3.card_no,t3.card_in_type,t3.card_in_subtype,t3.card_valid_date,t3.card_start_date,t3.app_valid_date,t3.card_deal_count,t3.psam_deal_no,t3.acc_bal,t3.deal_amt,t3.deal_date,t3.deal_kind,t3.psam_no,t3.tac,t3.deal_state,t3.FILE_LINE_NO  from pay_offline_list t3 where t3.acpt_id = '" + biz_Id + "' and t3.deal_Batch_No = '" + deal_Batch_No + "'  and t3.refuse_reason = '00'");
		sb1.append(" union all ");
		//调整拒付
		sb1.append(" select t4.send_file_name,t4.end_deal_no,decode(t4.Refuse_Reason,'00',decode(t4.ash_flag,'01','04','01'),'09',decode(t4.ash_flag,'01','04','01'),t4.Refuse_Reason) as Refuse_Reason,t4.end_id,t4.card_no,t4.card_in_type,t4.card_in_subtype,t4.card_valid_date,t4.card_start_date,t4.app_valid_date,t4.card_deal_count,t4.psam_deal_no,t4.acc_bal,t4.deal_amt,t4.deal_date,t4.deal_kind,t4.psam_no,t4.tac,t4.deal_state,t4.FILE_LINE_NO from Pay_Offline_black t4 where t4.acpt_id = '" + biz_Id + "' and t4.deal_Batch_No = '" + deal_Batch_No + "' and t4.refuse_reason = '09'");
		List list = publicDao.findBySQL(" select t.send_file_name,t.end_deal_no,t.Refuse_Reason,t.end_id,t.card_no,t.card_in_type,t.card_in_subtype,t.card_valid_date,t.card_start_date,t.app_valid_date,t.card_deal_count,t.psam_deal_no,t.acc_bal,t.deal_amt,t.deal_date,t.deal_kind,t.psam_no,t.tac,t.deal_state from ( "+ sb1.toString() + ") t order by send_File_Name, FILE_LINE_NO");
		String fileName="";
		//文件名
		fileName = "SS" + sysdate + "01" + Tools.tensileString(biz_Id,15,true,"0") + noNum;
		
		StringBuffer sb = new StringBuffer();
		//写文件头
		sb.append("SS01");//Filetype	N2	文件标识	SS Callingno	N2	行业代码	公交01
		sb.append(Tools.tensileString(""+list.size(),8,true,"0"));//RecNum	N8	记录总数
		sb.append("00000093");//RecLength	N8	记录长度	单条记录的长度
		sb.append(Tools.tensileString("F",24,true,"F"));//Reserved	ANS24	保留域	全F
		sb.append("\n\r");
		//写记录
		for(int i=0;i<list.size();i++){
			Object[] o = (Object[])list.get(i);
			
			sb.append(Tools.tensileString(Tools.processNull(o[0]),40,false," "));//FileName	AN40	所属文件名
			sb.append(sysdate);//Ssdate	N8	拒付交易发生结算日期（调整当天日期）	交易全‘F’（发卡方调整结算日期）
			sb.append(Tools.tensileString(Tools.processNull(o[1]),2,true,"0"));//RefuseCause	N2	拒付原因	00－卡片发行方调整01－TAC码错02－数据非法    03－数据重复    04－灰记录    05－超时92 – 数据非法调整据付93 – 数据重复调整拒付94 – 灰记录调整拒付90-其它错误
			sb.append(Tools.tensileString(biz_Id,15,true,"0"));//Deptno	N15	商户代码
			sb.append(Tools.tensileString(Tools.processNull(o[2]),10,true,"0"));//消费文件中的行号 N10
			sb.append(Tools.tensileString(Tools.processNull( o[3]),10,true,"0"));//Orderno	N10	本地流水号	与所属消费文件中的本地流水号一致
			sb.append(Tools.tensileString("0",8,true,"0"));//保留 N8		
			sb.append("\n\r");//
		}
		String user_name=ftpOptions.get("user_name");
		String password=ftpOptions.get("pwd");
		ftpClient = reConnectFtp_Zxc(ftpClient,user_name,password,ftpOptions.get("host_ip"));
		writeFile(ftpClient,ftpOptions.get("host_history_path") + "/" + fileName,sb.toString());
		return writeFile(ftpClient,ftpOptions.get("host_download_path") +"/" + fileName,sb.toString());
	}
	/**
	 * 写清算QS文件
	 * 确认：消费表deal_batch_no = '..' and  refuse_reason = '10'
	 * 拒付：trbatchno.deal_batch_no='..' and (in black or 后来被调整(refuse_reason='00')) 
	 * 调整：消费表deal_batch_no = '..' and refuse_reason = '00'
	 * 调整拒付：消费表deal_batch_no = '..' and refuse_reason='09'
	 */
	private int writeQS_Zxc(FtpClient ftpClient,String deal_Batch_No,String biz_Id,String sysdate,String type,String noNum,Map<String,String> ftpOptions) throws CommonException{
		try{
			DefaultFTPClient.writeLog("写清算QS文件");
			StringBuffer sb = new StringBuffer();
			//写文件头
			sb.append("QS");//Filetype	N2	文件标识	QS
			sb.append(Tools.tensileString("1",8,true,"0"));//RecNum	N8	记录总数
			sb.append("00000103");//RecLength	N8	记录长度	单条记录的长度
			sb.append(Tools.tensileString("F",24,true,"F"));//Reserved	ANS24	保留域	全F
			sb.append("\n\r");
			//写记录
			sb.append(Tools.tensileString(biz_Id,15,true,"0"));//Deptno	N15	商户代码
			sb.append(sysdate);//SettDate	N8	结算日期	YYYYMMDD
			//确认--当天
			Object[] objects = (Object[])this.findOnlyRowBySql("select count(*) as cnt,nvl(sum(deal_amt),0) as deal_amt from pay_offline_list t where t.acpt_id = '" + biz_Id + "' and t.deal_batch_no = '" + deal_Batch_No + "' and  refuse_reason = '10'");
			long fhCmTimes = ((BigDecimal)objects[0]).longValue();
			long fhCmMoney = ((BigDecimal)objects[1]).longValue();
			//确认--重新生成历史
			//objects =   (Object[])this.findOnlyRowBySql("select count(*) as cnt,nvl(sum(deal_amt),0) as deal_amt from pay_offline_filename t1,pay_offline t2 where t1.send_file_name = t2.send_file_name and t1.merchant_id = '" + biz_Id + "' and t1.deal_batch_no = '" + deal_Batch_No + "' and t2.deal_batch_no = '" + deal_Batch_No + "' and refuse_reason = '10'");
			//fhCmTimes += ((BigDecimal)objects[0]).longValue();
			//fhCmMoney += ((BigDecimal)objects[1]).longValue();
			sb.append(Tools.tensileString("" +fhCmTimes,8,true,"0"));//FhCmTimes	N8	消费确认笔数	
			sb.append(Tools.tensileString("" +fhCmMoney,10,true,"0"));//FhCmMoney	N10	消费确认金额	
			//拒付--
			objects =  (Object[])this.findOnlyRowBySql("select count(*) as cnt,nvl(sum(deal_amt),0) as deal_amt from pay_offline_filename t1,Pay_Offline_black t2 where t1.send_file_name = t2.send_file_name and t1.merchant_id = '" + biz_Id + "' and t1.deal_batch_no = '" + deal_Batch_No + "'");
			long fhRefuseTimes = ((BigDecimal)objects[0]).longValue();
			long fhRefuseMoney = ((BigDecimal)objects[1]).longValue();
			//拒付--重新生成历史--后来被调整
			//objects = (Object[])this.findOnlyRowBySql("select count(*) as cnt,nvl(sum(deal_amt),0) as deal_amt from pay_offline_filename t1,pay_offline t2 where t1.send_file_name = t2.send_file_name and t1.merchant_id = '" + biz_Id + "' and t1.deal_batch_no = '" + deal_Batch_No + "' and refuse_reason = '00'");
			//fhRefuseTimes += ((BigDecimal)objects[0]).longValue();
			//fhRefuseMoney += ((BigDecimal)objects[1]).longValue();
			sb.append(Tools.tensileString("" +fhRefuseTimes,8,true,"0"));//FhRefuseTimes	N8	消费拒付笔数	
			sb.append(Tools.tensileString("" +fhRefuseMoney,10,true,"0"));//FhRefuseMoney	N10	消费拒付金额	
			//调整--当天生成
			objects =  (Object[])this.findOnlyRowBySql("select count(*) as cnt,nvl(sum(deal_amt),0) as deal_amt from pay_offline_list t where t.acpt_id = '" + biz_Id + "' and deal_Batch_No = '" + deal_Batch_No + "'   and refuse_reason = '00'");
			long adjTimes = ((BigDecimal)objects[0]).longValue();
			long adjMoney = ((BigDecimal)objects[1]).longValue();
			//调整--重新生成历史
			//objects =  (Object[])this.findOnlyRowBySql("select count(*) as cnt,nvl(sum(deal_amt),0) as deal_amt from pay_offline t2 where t2.acpt_id = '" + biz_Id + "' and t2.deal_batch_no = '" + deal_Batch_No + "' and refuse_reason = '00'");
			//adjTimes += ((BigDecimal)objects[0]).longValue();
			//adjMoney += ((BigDecimal)objects[1]).longValue();
			sb.append(Tools.tensileString("" +adjTimes,8,true,"0"));//AdjTimes	N8	调整笔数	
			sb.append(Tools.tensileString("" +adjMoney,10,true,"0"));//AdjMoney	N10	调整金额	
			//调整拒付
			objects =  (Object[])this.findOnlyRowBySql("select count(*) as cnt,nvl(sum(deal_amt),0) as deal_amt from Pay_Offline_black t where t.acpt_id = '" + biz_Id + "' and deal_Batch_No = '" + deal_Batch_No + "' and refuse_reason = '09' ");
			long adjRefuseTimes = ((BigDecimal)objects[0]).longValue();
			long adjRefuseMoney = ((BigDecimal)objects[1]).longValue();
			sb.append(Tools.tensileString("" +adjRefuseTimes,8,true,"0"));//AdjRefuseTimes	N8	调整拒付笔数	
			sb.append(Tools.tensileString("" +adjRefuseMoney,10,true,"0"));//AdjRefuseMoney	N10	调整拒付金额 	
			sb.append(Tools.tensileString("0",8,true,"0"));//Reserved	ANS8	保留域	全0
			//文件名
			String  fileName = "QS" + sysdate + "01" + Tools.tensileString(biz_Id,15,true,"0") + noNum;
			String user_name=ftpOptions.get("user_name");
			String password=ftpOptions.get("pwd");
			ftpClient = reConnectFtp_Zxc(ftpClient,user_name,password,ftpOptions.get("host_ip"));
			writeFile(ftpClient,ftpOptions.get("host_history_path") + "/" + fileName,sb.toString());
			return writeFile(ftpClient,ftpOptions.get("host_download_path") +"/" + fileName,sb.toString());
		}catch(Exception e){
			DefaultFTPClient.writeLog("写清算文件失败：" + e.getMessage());
			return 0;
		}
		
	}
	

	
	
	/**
	 *写文件 
	 */
	private int writeFile(FtpClient ftpClient,String fileName,String content) throws CommonException{
		try{
			TelnetOutputStream stream=ftpClient.put(fileName);
			stream.write(content.getBytes());
			stream.close();
			/*TelnetOutputStream os=ftpClient.put(fileName);
			java.io.File file_in=new java.io.File(filename);
			FileInputStream is=new FileInputStream(file_in);
			byte[] bytes=new byte[1024];
			int c;
			while ((c=is.read(bytes))!=-1){
			 os.write(bytes,0,c); 
			}
			is.close(); 
			os.close();*/
		}catch(Exception e){
			e.printStackTrace();
			DefaultFTPClient.writeLog("写文件" + fileName + "出错：" + e.getMessage());
			return -1;
		}
		return 0;
	}
	
	private FtpClient reConnectFtp_Zxc(FtpClient ftpClient,String user,String password,String ip){
		DefaultFTPClient.writeLog("开始连接公交ftp");
		try{
			ftpClient=new FtpClient(ip,21);
			ftpClient.login(user,password);
			//ftpClient.cd("/");C:\ftp\001
			ftpClient.cd("/");
			ftpClient.binary();
		}catch(Exception e){
			DefaultFTPClient.writeLog("连接公交ftp出错：" + e.getMessage());
		}
		return ftpClient;
	}


}
