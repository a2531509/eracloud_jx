package com.erp.serviceImpl;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import javax.annotation.Resource;

import net.sf.json.JSONArray;

import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPReply;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import sun.net.TelnetInputStream;
import sun.net.TelnetOutputStream;
import sun.net.ftp.FtpClient;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseMerchant;
import com.erp.model.BasicMerchant;
import com.erp.model.PayOfflineFilename;
import com.erp.service.DoWorkClientService;
import com.erp.service.OfflineDataProcessService;
import com.erp.service.ShortMessageService;
import com.erp.task.DefaultFTPClient;
import com.erp.util.DateUtil;
import com.erp.util.Tools;
import com.erp.util.DealCode;


/**
 * @Describe 批量处理FTP上脱机数据
 * @version 1.0
 */
@SuppressWarnings({"unused","rawtypes"})
@Service(value="OfflineDataProcessService")
public class OfflineDataProcessServiceImpl extends BaseServiceImpl implements OfflineDataProcessService {
	private static Logger logger = Logger.getLogger(OfflineDataProcessServiceImpl.class);
	@Resource(name="doWorkClientService")
	private DoWorkClientService doWorkClientService;
	@Resource(name="shortMessageService")
	private ShortMessageService shortMessageService;
	
	/**
	 * <p>根据文件的每一行组装成一条insert sql语句</p>
	 * @param sb           insert 语句缓冲区
	 * @param line         文件的一行记录
	 * @param org_Id       机构编号
	 * @param fileName     所属文件名称
	 * @param file_Line_No 所有行号
	 * @param clr_Date     清分日期
	 * @return
	 * end_deal_no,acpt_id,end_id,card_no,card_in_type,card_in_subtype,card_valid_date,card_start_date,app_valid_date,
	 * card_deal_count,psam_deal_no,acc_bal,deal_amt,deal_date,deal_kind,psam_no,tac,ash_flag,credit_limit,deal_batch_no,send_file_name,file_line_no,send_date,
	 * deal_no,deal_code,deal_state,clr_date,refuse_reason,org_id,cancel_deal_batch_id,cancel_end_deal_no,points
	 */
	public StringBuffer createPayoffline(BaseMerchant mer,StringBuffer sb,String line,String org_Id,String fileName,String file_Line_No,String clr_Date) throws CommonException{
		sb.append("'insert into pay_offline (end_deal_no,acpt_id,end_id,card_no,card_in_type,card_in_subtype,card_valid_date,card_start_date,app_valid_date," +
				  "card_deal_count,psam_deal_no,acc_bal,deal_amt,deal_date,deal_kind,psam_no,tac,ash_flag,deal_state,deal_batch_no,send_file_name,file_line_no,send_date," +
				  "deal_no,deal_code,clr_date,org_id)values (");
		int pos = 0;
		String tramt,trdate,cardno;
		sb.append("''"+line.substring(pos,pos + 8)+"'',");//end_deal_no N8 POS流水号
		pos = pos + 8;
		String biz_Id = line.substring(pos, pos + 15);//acpt_id N15 商户编号
		if(!biz_Id.equals(mer.getMerchantId())){
			throw new CommonException("文件明细中的商户号不一致");
		}
		sb.append("''" + biz_Id + "'',");//Deptno	N15	商户代码	 受理点编码(网点号/商户号等)
		pos = pos + 15;
		sb.append("''"+line.substring(pos, pos + 8)+"'',");//end_id	N8	POS机号终端编号
		pos = pos + 8;
		cardno = line.substring(pos, pos + 20);
		sb.append("''" + cardno + "'',");//Cardno N20 卡号
		pos = pos + 20;
		sb.append("''" + line.substring(pos,pos + 2)+"'',");//Cardtype	N2	卡主类型	CARD_IN_TYPE	VARCHAR2(3)	Y			卡规划类别
		pos = pos + 2;
		sb.append("''"+line.substring(pos, pos + 2)+"'',");//Cardchildtype	N2	卡子类型	CARD_IN_SUBTYPE	VARCHAR2(3)	Y			卡规划子类别
		pos = pos + 2;
		sb.append("''"+line.substring(pos, pos + 8)+"'',");//Cardvaliddate	N8	卡有效期	YYYYMMDD CARD_VALID_DATE
		pos = pos + 8;
		sb.append("''"+line.substring(pos, pos + 8)+"'',");//Applyusedate	N8	应用启动日期
		pos = pos + 8;
		sb.append("''"+line.substring(pos, pos + 8)+"'',");//Applyvaliddate	N8	应用有效日期	YYYYMMDD APP_VALID_DATE	VARCHAR2(10)
		pos = pos + 8;
		sb.append(Long.parseLong(line.substring(pos, pos + 6))+",");//Moneynum	N6	电子钱包交易序号
		pos = pos + 6;
		sb.append(Long.parseLong(line.substring(pos, pos + 10))+",");//Psamnum	N10	终端交易序号	PSAM卡交易序号PSAM_TR_NO	INTEGER	Y
		pos = pos + 10;
		sb.append(Long.parseLong(line.substring(pos, pos + 8))+",");//Cardmoney	N8	交易前金额	单位到分ACC_BAL	NUMBER(16)
		pos = pos + 8;
		tramt = line.substring(pos, pos + 8);
		sb.append(Long.parseLong(tramt)+",");//Trademoney	N8	交易金额	单位到分TR_AMT	NUMBER(16)	Y
		pos = pos + 8;
		trdate = line.substring(pos, pos + 14);
		sb.append("''"+trdate+"'',");//Tradetime	N14	交易日期和时间
		pos = pos + 14;
		sb.append("''"+line.substring(pos, pos + 2)+"'',");//Tradetype	N2	交易类型	09复合应用电子钱包消费06普通电子钱包消费
		pos = pos + 2;
		sb.append("''"+line.substring(pos, pos + 12)+"'',");//Psamid	N12	PSAM卡终端编号
		pos = pos + 12;
		sb.append("''"+line.substring(pos, pos + 8)+"'',");//Tac	N8	交易认证码
		pos = pos + 8;
		String ash_flag = line.substring(pos, pos + 2);
		sb.append("''"+ ash_flag +"'',");//Flag	N2	灰记录标志	01表示灰记录 00表示正常记录
		sb.append("''" + (Tools.processNull(ash_flag).equals("00") ? "0" : "9") + "'',");//deal_state 交易流水状态0-正常 1-撤销 2-冲正3退货9-灰记录
		pos = pos + 2;
		/*sb.append(Long.parseLong(line.substring(pos, pos + 8))+",");//receivablemoneyN8	信用额度	单位到分
		pos = pos + 8;
		sb.append("''"+line.substring(pos, pos + 10)+"'',");//batchno	N10	批次号
		pos = pos + 10;*/
		//写入文件中没有的字段
		sb.append("''" + clr_Date + "'',");//交易批次号
		sb.append("''" + fileName + "'',");//SEND_FILE_NAME	VARCHAR2(64)	Y			批上传文件名称
		sb.append("''" + file_Line_No + "'',");//FILE_LINE_NO	INTEGER	Y			文件行号
		sb.append("sysdate,");//上传时间
		sb.append("seq_action_no.nextval,");//deal_no
		sb.append("''" + DealCode.OFFLINE_CONSUME + "'',");//TR_CODE	VARCHAR2(4)交易代码
		sb.append("''" + clr_Date + "'',");
		sb.append(mer.getOrgId());
		sb.append(")',");
		if(Integer.valueOf(file_Line_No)%200 == 0){//如果超过这个数的就先给与处理入库
			publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + sb.substring(0,sb.length() - 1) + "))");
			sb = new StringBuffer(512);
		}
		return sb;
	}
	
	/**
	 * @TODO 处理单个XF消费文件（可能以后用于多线程处理）
	 * @param defaultFTPClient 传入FTP客户端连接
	 * @param bizId     当前处理商户bizId
	 * @param parent    文件所在FTP绝对路径
	 * @param fileName  当前处理文件名
	 * @param upload    上传文件目录
	 * @param download  供下载文件所在目录
	 * @param historyes 历史文件存放目录
	 * @param fail      处理失败文件存放目录
	 */
	@SuppressWarnings("unchecked")
	public void saveProcessData(DefaultFTPClient defaultFTPClient,String bizId,String parentPath,String fileName,String upload,String historyes,String repeatFiles,String errors)throws CommonException{
		String clr_date="";
		try{
			clr_date=this.getClrDate();
			//1.FTP目录结构判断
			if(defaultFTPClient == null || !defaultFTPClient.isConnected()){
				throw new CommonException("FTP未连接或已关闭,无法连接FTP服务器");
			}
			if(Tools.processNull(bizId).equals("")){
				throw new CommonException("商户BIZID不能为空！");
			}
			if(Tools.processNull(fileName).equals("")){
				throw new CommonException("商户【" + bizId + "】传入【处理文件名】不能为空");
			}
			//2.商户是否登记注册判断
			BaseMerchant mer = (BaseMerchant)this.findOnlyRowByHql("from BaseMerchant t where t.merchantId = '" + bizId + "'");
			if(mer == null){
				throw new CommonException("商户【" + bizId + "】未在系统中进行注册登记，消费文件不能进行处理！文件名" + fileName);
			}
			//3.当前处理文件是否已经存在于pay_offline_filename
			BigDecimal isRepeat =  (BigDecimal) this.findOnlyFieldBySql("select count(1) from PAY_OFFLINE_FILENAME t where t.send_file_name = '" + fileName + "'");
			if(isRepeat.intValue() > 0){
				//defaultFTPClient.rename("/" + parentPath + "/" + upload + "/" + fileName,"/" + parentPath + "/" + repeatFiles + "/" + fileName);
				defaultFTPClient.rename("/" + upload + "/" + fileName,"/"+ repeatFiles + "/" + fileName);
				if(!FTPReply.isPositiveCompletion(defaultFTPClient.getReplyCode())){
					DefaultFTPClient.writeLog("商户【" + bizId + "】移动文件"  + "/" + upload + "/" + fileName + "出现错误:" + defaultFTPClient.getReplyString() + ",将在下次处理时进行移动.");
				}
				throw new CommonException("商户【" + bizId + "】消费文件：" + upload + "/" + fileName +" 重复,现在移到repeat目录下");
			}
			//4.处理文件内容
			List<String> fileConts = defaultFTPClient.getFileContent("/" + upload + "/" + fileName);
			if(fileConts == null || fileConts.size() < 1){
				defaultFTPClient.rename( "/" + upload + "/" + fileName,"/"  + historyes + "/" + fileName);
				if(!FTPReply.isPositiveCompletion(defaultFTPClient.getReplyCode())){
					DefaultFTPClient.writeLog("商户【" + bizId + "】移动文件" + "/" + upload + "/" + fileName + "出现错误:" + defaultFTPClient.getReplyString() + ",将在下次处理时进行移动.");
				}
				throw new CommonException("商户【" + bizId + "】,文件名" + fileName + "内容为空,不能进行处理！");
			}
			boolean isDealSuc = false;
			StringBuffer sb = new StringBuffer(512);
			if(fileName.toUpperCase().startsWith("XF") && fileName.length() == 36){
				String firstRow = fileConts.get(0);
				//if(Integer.valueOf(firstRow.substring(4,12)).intValue() == (fileConts.size() - 1)){
					try{
						publicDao.doSql("delete from Pay_Offline where send_file_name = '" + fileName + "'");
						for(int j = 1;j < fileConts.size();j++){
							if(!Tools.processNull(fileConts.get(j)).replaceAll(" ","").equals("")){
								sb = createPayoffline(mer,sb,fileConts.get(j),mer.getOrgId(),fileName,j + "",clr_date);
							}
						}
						if(!Tools.processNull(sb.toString()).equals("")){
							publicDao.doSql("call PK_PUBLIC.P_DEALSQLBYARRAY(strArray(" + sb.substring(0,sb.length() - 1) + "))");
						}
						isDealSuc = true;
					}catch(Exception e1){
						DefaultFTPClient.writeLog("商户【" + bizId + "】,消费文件" + upload + "/" + fileName + "处理失败！" + e1.getMessage());
					}
				/*}else{
					DefaultFTPClient.writeLog("商户【" + bizId +"非法文件："  + upload + "/" + fileName + ",第一行记录条数不正确");
				}*/
			}else if(fileName.endsWith("Lock.txt") && fileName.length() == 17){
				try{
					//锁卡文件名日期+Lock.txt且17位长度
					sb = new StringBuffer(512);
					for(int j = 1;j < fileConts.size();j++){
						sb.append("'update card_black set blk_state = 1,blk_type=''04'' where card_no =  ''" + Tools.processNull(fileConts.get(j)) + "''',");
					}
					if(!Tools.processNull(sb.toString()).equals("")){
						publicDao.doSql("call PK_PUBLIC.P_DEALSQLBYARRAY(strArray(" + sb.substring(0,sb.length()-1) + "))");
					}
					DefaultFTPClient.writeLog("处理锁卡文件成功："  + upload + "/" + fileName);
					isDealSuc = true;
				}catch(Exception e){
					DefaultFTPClient.writeLog("商户【" + bizId + "】,锁卡文件" + upload + "/" + fileName + "处理失败！");
				}
			}else{
				DefaultFTPClient.writeLog("商户【" + bizId +"非法文件："  + upload + "/" + fileName + " 文件名格式不正确，未知文件类型!");
			}
			//6.如果处理成功移动文件到历史目录,如果处理失败移动到失败目录
			if(isDealSuc){
				PayOfflineFilename curFile = new PayOfflineFilename();
				curFile.setFileType("XF");
				curFile.setMerchantId(bizId);
				curFile.setSendFileName(fileName);
				curFile.setSendDate(this.getDateBaseTime());
				curFile.setDealBatchNo(this.getClrDate());
				curFile.setState("1");
				publicDao.save(curFile);
				defaultFTPClient.rename("/" + upload + "/" + fileName, "/" + historyes + "/" + fileName);
				if(!FTPReply.isPositiveCompletion(defaultFTPClient.getReplyCode())){
					DefaultFTPClient.writeLog("商户【" + bizId + "】移动文件" + "/" + upload + "/" + fileName + "出现错误:" + defaultFTPClient.getReplyString() + ",将在下次处理时进行移动.");
				}
				DefaultFTPClient.writeLog("/" + upload + "/" + fileName + "处理成功.");
			}else{
				defaultFTPClient.rename( "/" + upload + "/" + fileName,"/" + errors + "/" + fileName);
			}
		}catch(CommonException e){
			throw new CommonException("处理文件失败,位置在商户" + bizId + ",文件名称" + fileName + " , " + e.getMessage());
		}catch(IOException e){
			throw new CommonException("商户【" + bizId + "】移动文件" + "/" + upload + "/" + fileName + "出现错误:" + e.getMessage() + ",将在下次处理时进行移动.");
		}
	}
	
	
	/**
	 * @TODO 处理单个嘉善XF消费文件（可能以后用于多线程处理）
	 * @param defaultFTPClient 传入FTP客户端连接
	 * @param bizId     当前处理商户bizId
	 * @param parent    文件所在FTP绝对路径
	 * @param fileName  当前处理文件名
	 * @param upload    上传文件目录
	 * @param download  供下载文件所在目录
	 * @param historyes 历史文件存放目录
	 * @param fail      处理失败文件存放目录
	 */
	@SuppressWarnings("unchecked")
	public void saveProcessDataJS(DefaultFTPClient defaultFTPClient,String bizId,String parentPath,String fileName,String upload,String historyes,String repeatFiles,String errors)throws CommonException{
		String clr_date="";
		try{
			clr_date=this.getClrDate();
			//1.FTP目录结构判断
			if(defaultFTPClient == null || !defaultFTPClient.isConnected()){
				throw new CommonException("FTP未连接或已关闭,无法连接FTP服务器");
			}
			if(Tools.processNull(bizId).equals("")){
				throw new CommonException("商户BIZID不能为空！");
			}
			if(Tools.processNull(fileName).equals("")){
				throw new CommonException("商户【" + bizId + "】传入【处理文件名】不能为空");
			}
			//2.商户是否登记注册判断
			BaseMerchant mer = (BaseMerchant)this.findOnlyRowByHql("from BaseMerchant t where t.merchantId = '" + bizId + "'");
			if(mer == null){
				throw new CommonException("商户【" + bizId + "】未在系统中进行注册登记，消费文件不能进行处理！文件名" + fileName);
			}
			//3.当前处理文件是否已经存在于pay_offline_filename
			BigDecimal isRepeat =  (BigDecimal) this.findOnlyFieldBySql("select count(1) from PAY_OFFLINE_FILENAME t where t.send_file_name = '" + fileName + "'");
			if(isRepeat.intValue() > 0){
				//defaultFTPClient.rename("/" + parentPath + "/" + upload + "/" + fileName,"/" + parentPath + "/" + repeatFiles + "/" + fileName);
				defaultFTPClient.rename("/" + upload + "/" + fileName,"/"+ repeatFiles + "/" + fileName);
				if(!FTPReply.isPositiveCompletion(defaultFTPClient.getReplyCode())){
					DefaultFTPClient.writeLog("商户【" + bizId + "】移动文件"  + "/" + upload + "/" + fileName + "出现错误:" + defaultFTPClient.getReplyString() + ",将在下次处理时进行移动.");
				}
				throw new CommonException("商户【" + bizId + "】消费文件：" + upload + "/" + fileName +" 重复,现在移到repeat目录下");
			}
			//4.处理文件内容
			List<String> fileConts = defaultFTPClient.getFileContent("/" + upload + "/" + fileName);
			if(fileConts == null || fileConts.size() < 1){
				defaultFTPClient.rename( "/" + upload + "/" + fileName,"/"  + historyes + "/" + fileName);
				if(!FTPReply.isPositiveCompletion(defaultFTPClient.getReplyCode())){
					DefaultFTPClient.writeLog("商户【" + bizId + "】移动文件" + "/" + upload + "/" + fileName + "出现错误:" + defaultFTPClient.getReplyString() + ",将在下次处理时进行移动.");
				}
				throw new CommonException("商户【" + bizId + "】,文件名" + fileName + "内容为空,不能进行处理！");
			}
			boolean isDealSuc = false;
			StringBuffer sb = new StringBuffer(512);
			if(fileName.toUpperCase().startsWith("XF") && fileName.length() == 30){
				String firstRow = fileConts.get(0);
				//if(Integer.valueOf(firstRow.substring(4,12)).intValue() == (fileConts.size() - 1)){
					try{
						publicDao.doSql("delete from Pay_Offline where send_file_name = '" + fileName + "'");
						for(int j = 1;j < fileConts.size();j++){
							if(!Tools.processNull(fileConts.get(j)).replaceAll(" ","").equals("")){
								sb = createPayoffline(mer,sb,fileConts.get(j),mer.getOrgId(),fileName,j + "",clr_date);
							}
						}
						if(!Tools.processNull(sb.toString()).equals("")){
							publicDao.doSql("call PK_PUBLIC.P_DEALSQLBYARRAY(strArray(" + sb.substring(0,sb.length() - 1) + "))");
						}
						isDealSuc = true;
					}catch(Exception e1){
						DefaultFTPClient.writeLog("商户【" + bizId + "】,消费文件" + upload + "/" + fileName + "处理失败！" + e1.getMessage());
					}
				/*}else{
					DefaultFTPClient.writeLog("商户【" + bizId +"非法文件："  + upload + "/" + fileName + ",第一行记录条数不正确");
				}*/
			}else if(fileName.endsWith("Lock.txt") && fileName.length() == 17){
				try{
					//锁卡文件名日期+Lock.txt且17位长度
					sb = new StringBuffer(512);
					for(int j = 1;j < fileConts.size();j++){
						sb.append("'update card_black set blk_state = 1,blk_type=''04'' where card_no =  ''" + Tools.processNull(fileConts.get(j)) + "''',");
					}
					if(!Tools.processNull(sb.toString()).equals("")){
						publicDao.doSql("call PK_PUBLIC.P_DEALSQLBYARRAY(strArray(" + sb.substring(0,sb.length()-1) + "))");
					}
					DefaultFTPClient.writeLog("处理锁卡文件成功："  + upload + "/" + fileName);
					isDealSuc = true;
				}catch(Exception e){
					DefaultFTPClient.writeLog("商户【" + bizId + "】,锁卡文件" + upload + "/" + fileName + "处理失败！");
				}
			}else{
				DefaultFTPClient.writeLog("商户【" + bizId +"非法文件："  + upload + "/" + fileName + " 文件名格式不正确，未知文件类型!");
			}
			//6.如果处理成功移动文件到历史目录,如果处理失败移动到失败目录
			if(isDealSuc){
				PayOfflineFilename curFile = new PayOfflineFilename();
				curFile.setFileType("XF");
				curFile.setMerchantId(bizId);
				curFile.setSendFileName(fileName);
				curFile.setSendDate(this.getDateBaseTime());
				curFile.setDealBatchNo(this.getClrDate());
				curFile.setState("1");
				publicDao.save(curFile);
				defaultFTPClient.rename("/" + upload + "/" + fileName, "/" + historyes + "/" + fileName);
				if(!FTPReply.isPositiveCompletion(defaultFTPClient.getReplyCode())){
					DefaultFTPClient.writeLog("商户【" + bizId + "】移动文件" + "/" + upload + "/" + fileName + "出现错误:" + defaultFTPClient.getReplyString() + ",将在下次处理时进行移动.");
				}
				DefaultFTPClient.writeLog("/" + upload + "/" + fileName + "处理成功.");
			}else{
				defaultFTPClient.rename( "/" + upload + "/" + fileName,"/" + errors + "/" + fileName);
			}
		}catch(CommonException e){
			throw new CommonException("处理文件失败,位置在商户" + bizId + ",文件名称" + fileName + " , " + e.getMessage());
		}catch(IOException e){
			throw new CommonException("商户【" + bizId + "】移动文件" + "/" + upload + "/" + fileName + "出现错误:" + e.getMessage() + ",将在下次处理时进行移动.");
		}
	}
	
	
	/**
	 * 验证公交TAC码
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public void saveCheckOffineDataTac() throws CommonException{
		int len=2000;
		String fileName="";
		try{
			//查询未验证TAC的消费文件
			List<String> listNames = this.findBySql("select t.send_file_name from PAY_OFFLINE_FILENAME t where t.state = '1' and t.file_type='XF' ");
			if(listNames == null || listNames.size() < 1){
				throw new CommonException("未获取到需要验证TAC的数据文件...");
			}
			Iterator<String> its = listNames.iterator();
			while(its.hasNext()){
				fileName = its.next();
				List<String> refuseList = new ArrayList<String>();
				List list = publicDao.findBySQL("select t.deal_no||','||t.card_no||','||t.deal_amt||','||t.deal_kind||','||t.psam_no||','||t.psam_deal_no||','||t.deal_date||','||t.tac||'|'   from Pay_Offline t where t.refuse_reason is null and t.deal_no is not null and (t.card_no <> '75000000000000000000' and t.card_no <> '00000000000000000000') and t.send_file_name = '" + fileName + "' and rownum <= " + len);
				if(list == null || list.size() < 1){
					DefaultFTPClient.writeLog("文件" + fileName + ",未获取到待验证TAC的记录.");
					throw new CommonException("文件" + fileName + ",未获取到待验证TAC的记录.");
				}
				StringBuffer consumeStr = new StringBuffer();
				for(int  i = 0;i < list.size();i++){
					consumeStr.append(Tools.processNull(list.get(i)));
					if(i > 0 && i % 2502 == 0){
						if(!Tools.processNull(consumeStr).trim().equals("")){
							com.alibaba.fastjson.JSONArray jsonArray =(com.alibaba.fastjson.JSONArray) doWorkClientService.checkTacByFileName(fileName,consumeStr.toString());
							JSONObject return_first=null;
							String errcode="";
							Long deal_No=0L;
							for(int s=0;s<jsonArray.size();s++){
								return_first = jsonArray.getJSONObject(s);
								if(return_first == null || return_first.isEmpty()){
									throw new CommonException("验证TAC出现错误,前置返回空!");
								}
								errcode=Tools.processNull(return_first.getString("errcode"));
								deal_No=Tools.processLong(return_first.getString("deal_no"));//中心交易流水号
								if(errcode.equals("00")){
									refuseList.add("'update Pay_Offline t set t.refuse_reason = ''10'' where t.deal_no = " + deal_No + "',");
								}else{
									refuseList.add("'update Pay_Offline t set t.refuse_reason = ''" + errcode + "'' where t.deal_no = " + deal_No + "',");
								}
							}
							consumeStr = new StringBuffer();
						}
					}
				}
				if(!Tools.processNull(consumeStr).equals("")){
					com.alibaba.fastjson.JSONArray jsonArray =(com.alibaba.fastjson.JSONArray) doWorkClientService.checkTacByFileName(fileName,consumeStr.toString());
					JSONObject return_first=null;
					String errcode="";
					Long deal_No=0L;
					for(int s=0;s<jsonArray.size();s++){
						return_first = jsonArray.getJSONObject(s);
						if(return_first == null || return_first.isEmpty()){
							throw new CommonException("验证TAC出现错误,前置返回空!");
						}
						errcode=Tools.processNull(return_first.getString("errcode"));
						deal_No=Tools.processLong(return_first.getString("deal_no"));//中心交易流水号
						if(errcode.equals("00")){
							refuseList.add("'update Pay_Offline t set t.refuse_reason = ''10'' where t.deal_no = " + deal_No + "',");
						}else{
							refuseList.add("'update Pay_Offline t set t.refuse_reason = ''" + errcode + "'' where t.deal_no = " + deal_No + "',");
						}
					}
				}
				StringBuffer exesql = new StringBuffer();
				for (int jj = 0; jj < refuseList.size(); jj++) {
					exesql.append(refuseList.get(jj));
					if(jj%900 == 0){
						publicDao.doSql("call PK_PUBLIC.P_DEALSQLBYARRAY(strArray(" + exesql.substring(0,exesql.length() - 1) + "))");
						exesql = new StringBuffer();
					}
				}
				if(!Tools.processNull(exesql).equals("")){
					publicDao.doSql("call PK_PUBLIC.P_DEALSQLBYARRAY(strArray(" + exesql.substring(0,exesql.length() - 1) + "))");
				}
				BigDecimal isExists = (BigDecimal) this.findOnlyFieldBySql("select count(1) from Pay_Offline t where t.refuse_reason is null and t.deal_no is not null  and t.send_file_name = '" + fileName + "'");
				if(isExists.longValue() > 0){
					saveCheckOffineDataTac();
				}else{
					publicDao.doSql("update pay_offline_filename set state = '2' where send_file_name = '" + fileName + "' and state = '1' and file_type = 'XF'");
				}
			}
		}catch(Exception e1){
			//验证一个文件失败
			logger.error(e1.getMessage());
			DefaultFTPClient.writeLog("验证XF消费数据 " + fileName + "TAC出现错误！" + e1.getMessage());
		}
		
	}
	
	
	/**
	 * 验证嘉善TAC码
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	public void saveCheckOffineDataTacJS() throws CommonException{
		int len=2000;
		String fileName="";
		try{
			//查询未验证TAC的消费文件
			List<String> listNames = this.findBySql("select t.send_file_name from PAY_OFFLINE_FILENAME t where t.state = '1' and t.file_type='XF' ");
			if(listNames == null || listNames.size() < 1){
				throw new CommonException("未获取到需要验证TAC的数据文件...");
			}
			Iterator<String> its = listNames.iterator();
			while(its.hasNext()){
				fileName = its.next();
				List<String> refuseList = new ArrayList<String>();
				List list = publicDao.findBySQL("select t.deal_no||','||t.card_no||','||t.deal_amt||','||t.deal_kind||','||t.psam_no||','||t.psam_deal_no||','||t.deal_date||','||t.tac||'|'   from Pay_Offline t where t.refuse_reason is null and t.deal_no is not null and (t.card_no <> '75000000000000000000' and t.card_no <> '00000000000000000000') and t.send_file_name = '" + fileName + "' and rownum <= " + len);
				if(list == null || list.size() < 1){
					DefaultFTPClient.writeLog("文件" + fileName + ",未获取到待验证TAC的记录.");
					throw new CommonException("文件" + fileName + ",未获取到待验证TAC的记录.");
				}
				StringBuffer consumeStr = new StringBuffer();
				for(int  i = 0;i < list.size();i++){
					consumeStr.append(Tools.processNull(list.get(i)));
					if(i > 0 && i % 2502 == 0){
						if(!Tools.processNull(consumeStr).trim().equals("")){
							com.alibaba.fastjson.JSONArray jsonArray =(com.alibaba.fastjson.JSONArray) doWorkClientService.checkTacByFileName(fileName,consumeStr.toString());
							JSONObject return_first=null;
							String errcode="";
							Long deal_No=0L;
							for(int s=0;s<jsonArray.size();s++){
								return_first = jsonArray.getJSONObject(s);
								if(return_first == null || return_first.isEmpty()){
									throw new CommonException("验证TAC出现错误,前置返回空!");
								}
								errcode=Tools.processNull(return_first.getString("errcode"));
								deal_No=Tools.processLong(return_first.getString("deal_no"));//中心交易流水号
								if(errcode.equals("00")){
									refuseList.add("'update Pay_Offline t set t.refuse_reason = ''10'' where t.deal_no = " + deal_No + "',");
								}else{
									refuseList.add("'update Pay_Offline t set t.refuse_reason = ''" + errcode + "'' where t.deal_no = " + deal_No + "',");
								}
							}
							consumeStr = new StringBuffer();
						}
					}
				}
				if(!Tools.processNull(consumeStr).equals("")){
					com.alibaba.fastjson.JSONArray jsonArray =(com.alibaba.fastjson.JSONArray) doWorkClientService.checkTacByFileName(fileName,consumeStr.toString());
					JSONObject return_first=null;
					String errcode="";
					Long deal_No=0L;
					for(int s=0;s<jsonArray.size();s++){
						return_first = jsonArray.getJSONObject(s);
						if(return_first == null || return_first.isEmpty()){
							throw new CommonException("验证TAC出现错误,前置返回空!");
						}
						errcode=Tools.processNull(return_first.getString("errcode"));
						deal_No=Tools.processLong(return_first.getString("deal_no"));//中心交易流水号
						if(errcode.equals("00")){
							refuseList.add("'update Pay_Offline t set t.refuse_reason = ''10'' where t.deal_no = " + deal_No + "',");
						}else{
							refuseList.add("'update Pay_Offline t set t.refuse_reason = ''" + errcode + "'' where t.deal_no = " + deal_No + "',");
						}
					}
				}
				StringBuffer exesql = new StringBuffer();
				for (int jj = 0; jj < refuseList.size(); jj++) {
					exesql.append(refuseList.get(jj));
					if(jj%900 == 0){
						publicDao.doSql("call PK_PUBLIC.P_DEALSQLBYARRAY(strArray(" + exesql.substring(0,exesql.length() - 1) + "))");
						exesql = new StringBuffer();
					}
				}
				if(!Tools.processNull(exesql).equals("")){
					publicDao.doSql("call PK_PUBLIC.P_DEALSQLBYARRAY(strArray(" + exesql.substring(0,exesql.length() - 1) + "))");
				}
				BigDecimal isExists = (BigDecimal) this.findOnlyFieldBySql("select count(1) from Pay_Offline t where t.refuse_reason is null and t.deal_no is not null  and t.send_file_name = '" + fileName + "'");
				if(isExists.longValue() > 0){
					saveCheckOffineDataTac();
				}else{
					publicDao.doSql("update pay_offline_filename set state = '2' where send_file_name = '" + fileName + "' and state = '1' and file_type = 'XF'");
				}
			}
		}catch(Exception e1){
			//验证一个文件失败
			logger.error(e1.getMessage());
			DefaultFTPClient.writeLog("验证XF消费数据 " + fileName + "TAC出现错误！" + e1.getMessage());
		}
		
	}
	
	/**
	 * 处理非法卡号引起的验证TAC异常 card_no = '21420000000000000000' 或是 card_no = '0000000000000000000'
	 * @throws CommonException
	 */
	public void dealErrorCardNo() throws CommonException {
		try{
			List<?> objs = this.findBySql("select t.acpt_id,t.clr_date,t.card_no,t.send_file_name,t.file_line_no from pay_offline t where t.refuse_reason is null ");
			for (int i = 0; i < objs.size(); i++) {
				Object[] arryObj = (Object[]) objs.get(i);
				writeLog("检索到非法数据:公交标识 = " + arryObj[0].toString() + " 清分日期 = " + arryObj[1].toString() + " 卡号 = " + arryObj[2].toString() + " 文件名 = " + arryObj[3].toString() + " 行号 = " + arryObj[4].toString());
			}
			publicDao.doSql("update pay_offline t set t.refuse_reason = '01' where t.refuse_reason is null ");
		}catch(Exception e){
			writeLog("检索到非法数据但处理失败。");
		}
	}
	 /**
		**脱机数据处理
		**av_in: 各字段以|分割
		**       1biz_id    商户号
		**拒付原因:00－卡片发行方调整01－tac码错02－数据非法03－数据重复04－灰记录05－金额不足06-测试数据09调整拒付10正常数据
	    */
	public void p_OfflineConsume()throws CommonException{
		try {
			String biz_Id=this.getSysConfigurationParameters("BIZ_ID_GJ0");
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
	**脱机数据处理
	**av_in: 各字段以|分割
	**       1biz_id    商户号
	**拒付原因:00－卡片发行方调整01－tac码错02－数据非法03－数据重复04－灰记录05－金额不足06-测试数据09调整拒付10正常数据
    */
	public void p_OfflineConsume_hncg()throws CommonException{
		try {
			String biz_Id=this.getSysConfigurationParameters("BIZ_ID_HNCG");
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
	
	
	
	public DoWorkClientService getDoWorkClientService() {
		return doWorkClientService;
	}
	public void setDoWorkClientService(DoWorkClientService doWorkClientService) {
		this.doWorkClientService = doWorkClientService;
	}
	
	
	
	/**
	 * 处理自行车脱机数据
	 * @throws CommonException
	 */
	public void saveOffineData_Zxc()throws CommonException{
		DefaultFTPClient defaultFTPClient = null;
		String sysdate="";
		String ip="",user="",pwd="",biz_Id="",upload="",historyfiles="",gj_ftp_repeat="",gj_ftp_errors="",fileName="";
		try{
			sysdate= publicDao.getDateBaseTimeStr("yyyyMMddHHmmss");
			List list=(List)publicDao.findBySQL("select ftp_use from SYS_FTP_CONF t where t.ftp_use = 'zxc_041010010010003' group by t.ftp_use ");
		    if(list!=null && list.size()>0){
		    	String ftp_use=null;
		    	//logger.error("#正在检查FTP配置信息");
		    	for(int i=0;i<list.size();i++){//多个自行车的FTP配置信息
		    		ftp_use=(String)list.get(i);
		    		Map<String,String>  ftpOptions = this.initFtpOptions(ftp_use);
		    		defaultFTPClient = this.checkFtp(ftpOptions);
					//logger.error(ftp_use+",当前工作目录" + defaultFTPClient.printWorkingDirectory());
					defaultFTPClient.logout();
					defaultFTPClient.disconnect();
					defaultFTPClient = null;
					//logger.error("FTP检查完毕");
					ip =Tools.processNull(ftpOptions.get("host_ip"));//XF消费文件所在FTP地址
					user =Tools.processNull(ftpOptions.get("user_name"));//FTP用户名
					pwd = Tools.processNull(ftpOptions.get("pwd"));//FTP密码
					biz_Id =Tools.processNull(ftp_use.substring(4, 19));//商户BizId
					if(Tools.processNull(ip).equals("") || Tools.processNull(user).equals("") || Tools.processNull(pwd).equals("") || Tools.processNull(biz_Id).equals("")){
						throw new CommonException("商户FTP配置信息不完整,无法进行文件处理." + (!Tools.processNull(biz_Id).equals("") ? biz_Id : ""));
					}
					//4.获取FTP目录结构
					upload = Tools.processNull(ftpOptions.get("host_upload_path"));
					historyfiles =Tools.processNull(ftpOptions.get("host_history_path"));
					gj_ftp_repeat = Tools.processNull(ftpOptions.get("host_history_path"));
					gj_ftp_errors =Tools.processNull(ftpOptions.get("host_history_path"));
					//5.创建FTP连接获取目录下的文件列表
					defaultFTPClient = new DefaultFTPClient();
					boolean isCanConn = defaultFTPClient.toConnect(ip,Integer.parseInt(Tools.processNull(ftpOptions.get("host_port"))));
					if(!isCanConn){
						return;//FTP连接失败
					}
					boolean isCanLogin = defaultFTPClient.toLogin(user,pwd);
					if(!isCanLogin){
						return;//FTP登陆失败
					}
					defaultFTPClient.setFileType(FTPClient.BINARY_FILE_TYPE);
					defaultFTPClient.changeWorkingDirectory("/");
					//第一步，写自行车的黑名单信息
					try{//写自行车的黑名单信息
						DefaultFTPClient.writeLog("=================写自行车的黑名单信息文件=================");
						writeBlackFile(defaultFTPClient, sysdate,ftpOptions,ftp_use);
						DefaultFTPClient.writeLog("=================写自行车的黑名单信息文件成功完成=================");
					}catch(Exception ee){
						DefaultFTPClient.writeLog("写黑名单信息有误:"+ee.getMessage());
					}
					//第二步，读取自行车的开通信息
				 	try{//读取自行车的开通信息
				 		DefaultFTPClient.writeLog("=================开始读取开通文件=================");
						ReadKTQSFile(defaultFTPClient, sysdate,ftpOptions,ftp_use);
				 		DefaultFTPClient.writeLog("=================读取开通文件成功完成=================");
					}catch(Exception ee){
						DefaultFTPClient.writeLog("读取开通文件有误:"+ee.getMessage());
					}
					//第三步，自行车脱机消费入库信息
					//List<String> fileNameList = defaultFTPClient.listNames(upload + "/" ,2000);
					//Thread.sleep(60000 * 3);
					/***
					if(fileNameList != null && fileNameList.size() > 0){
						Iterator<String> its = fileNameList.iterator();
						while(its.hasNext()){
							try{
								String tempFileName = its.next();
								saveProcessData_Zxc(defaultFTPClient,biz_Id,"",tempFileName,upload,historyfiles,gj_ftp_repeat,gj_ftp_errors);
							}catch(Exception e){
								DefaultFTPClient.writeLog(e.getMessage());
							}
						}
					}// 没有文件要处理
					****/
						
		    	}//for循环结束，多个自行车的FTP配置信息
		    	
     	    }else{
		    	DefaultFTPClient.writeLog("没有配置FTP信息");
		    }
		}catch(Exception e){
			throw new CommonException("脱机数据处理出错："+e.getMessage());
		}
		
	}
	/**
	 * 自行车处理单个XF消费文件（可能以后用于多线程处理）
	 * @param defaultFTPClient 传入FTP客户端连接
	 * @param bizId     当前处理商户bizId
	 * @param parent    文件所在FTP绝对路径
	 * @param fileName  当前处理文件名
	 * @param upload    上传文件目录
	 * @param download  供下载文件所在目录
	 * @param historyes 历史文件存放目录
	 * @param fail      处理失败文件存放目录
	 */
	@SuppressWarnings("unchecked")
	public void saveProcessData_Zxc(DefaultFTPClient defaultFTPClient,String bizId,String parentPath,String fileName,String upload,String historyes,String repeatFiles,String errors)throws CommonException{
		String clr_date="";
		try{
			clr_date=this.getClrDate();
			//1.FTP目录结构判断
			if(defaultFTPClient == null || !defaultFTPClient.isConnected()){
				throw new CommonException("FTP未连接或已关闭,无法连接FTP服务器");
			}
			if(Tools.processNull(bizId).equals("")){
				throw new CommonException("商户BIZID不能为空！");
			}
			if(Tools.processNull(fileName).equals("")){
				throw new CommonException("商户【" + bizId + "】传入【处理文件名】不能为空");
			}
			//2.商户是否登记注册判断
			BaseMerchant mer = (BaseMerchant)this.findOnlyRowByHql("from BaseMerchant t where t.merchantId = '" + bizId + "'");
			if(mer == null){
				throw new CommonException("商户【" + bizId + "】未在系统中进行注册登记，消费文件不能进行处理！文件名" + fileName);
			}
			//3.当前处理文件是否已经存在于pay_offline_filename
			BigDecimal isRepeat =  (BigDecimal) this.findOnlyFieldBySql("select count(1) from PAY_OFFLINE_FILENAME t where t.send_file_name = '" + fileName + "'");
			if(isRepeat.intValue() > 0){
				defaultFTPClient.rename("/" + upload + "/" + fileName,"/" +  repeatFiles + "/" + fileName);
				if(!FTPReply.isPositiveCompletion(defaultFTPClient.getReplyCode())){
					DefaultFTPClient.writeLog("商户【" + bizId + "】移动文件"  + "/" + upload + "/" + fileName + "出现错误:" + defaultFTPClient.getReplyString() + ",将在下次处理时进行移动.");
				}
				throw new CommonException("商户【" + bizId + "】消费文件：" +  upload + "/" + fileName +" 重复,现在移到repeat目录下");
			}
			//4.处理文件内容
			List<String> fileConts = defaultFTPClient.getFileContent("/"+ upload + "/" + fileName);
			if(fileConts == null || fileConts.size() < 1){
				defaultFTPClient.rename("/"  + upload + "/" + fileName,"/"  + historyes + "/" + fileName);
				if(!FTPReply.isPositiveCompletion(defaultFTPClient.getReplyCode())){
					DefaultFTPClient.writeLog("商户【" + bizId + "】移动文件" + "/"  + upload + "/" + fileName + "出现错误:" + defaultFTPClient.getReplyString() + ",将在下次处理时进行移动.");
				}
				throw new CommonException("商户【" + bizId + "】,文件名" + fileName + "内容为空,不能进行处理！");
			}
			boolean isDealSuc = false;
			StringBuffer sb = new StringBuffer();
			if(fileName.toUpperCase().startsWith("XF") && fileName.length() == 32){
				String firstRow = fileConts.get(0);
				if(Integer.valueOf(firstRow.substring(4,12)).intValue() == (fileConts.size() - 1)){
					try{
						publicDao.doSql("delete from Pay_Offline where send_file_name = '" + fileName + "'");
						for(int j = 1;j < fileConts.size();j++){
							if(!Tools.processNull(fileConts.get(j)).replaceAll(" ","").equals("")){
								sb = createPayoffline(mer,sb,fileConts.get(j),mer.getOrgId(),fileName,j + "",clr_date);
							}
						}
						if(!Tools.processNull(sb.toString()).equals("")){
							publicDao.doSql("call PK_PUBLIC.P_DEALSQLBYARRAY(strArray(" + sb.substring(0,sb.length() - 1) + "))");
						}
						isDealSuc = true;
					}catch(Exception e1){
						DefaultFTPClient.writeLog("商户【" + bizId + "】,消费文件" + upload + "/" + fileName + "处理失败！" + e1.getMessage());
					}
				}else{
					DefaultFTPClient.writeLog("商户【" + bizId +"非法文件："  + upload + "/" + fileName + ",第一行记录条数不正确");
				}
			}else{
				DefaultFTPClient.writeLog("商户【" + bizId +"非法文件："  + upload + "/" + fileName + " 文件名格式不正确，未知文件类型!");
			}
			//6.如果处理成功移动文件到历史目录,如果处理失败移动到失败目录
			if(isDealSuc){
				PayOfflineFilename curFile = new PayOfflineFilename();
				curFile.setFileType("XF");
				curFile.setMerchantId(bizId);
				curFile.setSendFileName(fileName);
				curFile.setSendDate(this.getDateBaseTime());
				curFile.setDealBatchNo(this.getClrDate());
				curFile.setState("1");
				publicDao.save(curFile);
				defaultFTPClient.rename("/" + upload + "/" + fileName, "/" + historyes + "/" + fileName);
				if(!FTPReply.isPositiveCompletion(defaultFTPClient.getReplyCode())){
					DefaultFTPClient.writeLog("商户【" + bizId + "】移动文件" + "/"  + upload + "/" + fileName + "出现错误:" + defaultFTPClient.getReplyString() + ",将在下次处理时进行移动.");
				}
				DefaultFTPClient.writeLog("/" + upload + "/" + fileName + "处理成功.");
			}else{
				defaultFTPClient.rename( "/" + upload + "/" + fileName,"/"  + errors + "/" + fileName);
			}
		}catch(CommonException e){
			throw new CommonException("处理文件失败,位置在商户" + bizId + ",文件名称" + fileName + " , " + e.getMessage());
		}catch(IOException e){
			throw new CommonException("商户【" + bizId + "】移动文件" + "/"  + upload + "/" + fileName + "出现错误:" + e.getMessage() + ",将在下次处理时进行移动.");
		}
	}
	

	/**
	**自行车脱机数据处理(有4个自行车公司脱机数据处理)
	**av_in: 各字段以|分割
	**       1biz_id    商户号
	**拒付原因:00－卡片发行方调整01－tac码错02－数据非法03－数据重复04－灰记录05－金额不足06-测试数据09调整拒付10正常数据
    */

	public void p_OfflineConsume_Zxc()throws CommonException{
		String biz_Id="",ftp_use="";
		try {//(有4个自行车公司)
			List list=(List)publicDao.findBySQL("select ftp_use from SYS_FTP_CONF t where t.ftp_use like 'zxc_%' group by t.ftp_use ");
		    if(list!=null && list.size()>0){
		    	for(int i=0;i<list.size();i++){
		    		ftp_use=(String)list.get(i);
		    		//Map<String,String>  ftpOptions = this.initFtpOptions(ftp_use);
					biz_Id = ((String)ftp_use.substring(4, 19));
					List<Object> in = new ArrayList<Object>();
					in.add(biz_Id);
					in.add("0");
					List<Integer> out = new java.util.ArrayList<Integer>();
					out.add(java.sql.Types.VARCHAR);
					out.add(java.sql.Types.VARCHAR);
					publicDao.callProc("pk_consume.p_offlineconsume",in,out);
		    	}
		    }
			
			
		} catch (Exception e) {
			throw new CommonException("脱机数据处理出错："+e.getMessage());
		}
	}
	/**
	 * 读取开通、取消租车文件
	 * @param defaultFTPClient
	 * @param sysdate
	 * @return
	 * @throws CommonException
	 */
	private int ReadKTQSFile(DefaultFTPClient defaultFTPClient,String sysdate,Map<String,String>  ftpOptions,String ftp_use) throws CommonException{
		int serial=0;
		StringBuffer sb = new StringBuffer(512);
		String cert_No="",card_No="",zxc_Flag="",bind_State="",biz_id="";
		String fileName = ""; 
		try{
			biz_id=ftp_use.substring(4, 19);
			defaultFTPClient.setFileType(FTPClient.BINARY_FILE_TYPE);
			defaultFTPClient.changeWorkingDirectory("/");
			List<String> fileNameList = defaultFTPClient.listNames(ftpOptions.get("zxcktqx")+"/",2000);
			//Thread.sleep(60000 * 3);
			if(fileNameList != null && fileNameList.size() > 0){
				Iterator<String> its = fileNameList.iterator();
				while(its.hasNext()){
					try {
						fileName = its.next();
						DefaultFTPClient.writeLog("【"+biz_id+"】商户名的开通文件文件名为==="+fileName);
						List<String> fileConts = defaultFTPClient.getFileContent(ftpOptions.get("zxcktqx") + "/" + fileName);
						String line="";
						List<String> refuseList = new ArrayList<String>();
						for(int j = 1;j < fileConts.size();j++){
							line=fileConts.get(j);
							if(!Tools.processNull(line).replaceAll(" ","").equals("")){
								int pos = 0;
								card_No=Tools.processNull(line.substring(0, 20));//N20	卡应用序列号
								pos = pos + 20;
								cert_No=line.substring(pos, pos + 18);//N18	身份证号
								pos = pos + 18;
								zxc_Flag=line.substring(pos, pos + 2);//N2	租车功能类型 01开通租车02取消租车
								pos = pos + 2;
								String medwholeno = "330499";//自行车公司区域代码  嘉兴自行车公司这行无需添加，入库时默认写330499，海宁为330481
								if(line.length() >= 46){
									medwholeno = line.substring(pos,pos + 6);
								}
								if(zxc_Flag.equals("01")){
									bind_State="0";
								}else if(zxc_Flag.equals("02")){
									bind_State="1";
								}else{
									bind_State="0";
								}
								//bind_State=zxc_Flag.equals("01")?"0":"1";
								List list=publicDao.findBySQL("select * from CARD_APP_BIND a where a.CARD_NO='"+card_No+"' and a.APP_TYPE='05' ");//( 01-广电 02-自来水 03-电力 04-过路过桥 05-自行车 06-移动）
								if(list!=null && list.size()>0){//开通过的，就更新数据   绑定状态和区域
									sb.append(" 'update CARD_APP_BIND c set c.bind_State=''" + bind_State + "'',c.RESERVE2=''"+medwholeno+"'',bind_date=sysdate  where c.card_no=''"+card_No+"'' and c.APP_TYPE=''05''',");
								}else{//插入数据
									sb.append(" 'insert into CARD_APP_BIND(BIND_ID,CARD_NO,APP_TYPE,BIND_STATE,MERCHANT_ID,RESERVE2,BIND_DATE) ");
									sb.append(" values (SEQ_BIND_ID.NEXTVAL,''"+card_No+"'',''05'',''"+bind_State+"'',''"+biz_id+"'',''"+medwholeno+"'',sysdate)',");
								}
							   try{
						        	if(Integer.valueOf(j)%200==0){//如果超过这个数的就先给与处理入库
						        		if(!Tools.processNull(sb.toString()).equals("")){
						        			//System.out.println(sb.substring(0,sb.length() - 1));
						        			 publicDao.doSql("call PK_PUBLIC.P_DEALSQLBYARRAY(strArray(" + sb.substring(0,sb.length()-1) + "))");
											sb = new StringBuffer(512);
										}
									
									}
						        }catch (Exception ep) {
									DefaultFTPClient.writeLog("第" + j + "行有错误");
								}
							}
							
						}
						if(!Tools.processNull(sb.toString()).equals("")){
						   publicDao.doSql("call PK_PUBLIC.P_DEALSQLBYARRAY(strArray(" + sb.substring(0,sb.length()-1) + "))");
						   publicDao.doSql("commit");
						   sb = new StringBuffer(512);
						}
					} catch (Exception e) {
						DefaultFTPClient.writeLog("【" + biz_id + "】商户名的开通文件文件名为【" + fileName + "】处理失败，" + e.getMessage());
					}
				}//读文件结束
				DefaultFTPClient.writeLog(fileName+"=================读文件结束,移到历史目录下=================");
				defaultFTPClient.rename(ftpOptions.get("zxcktqx") + "/" + fileName, ftpOptions.get("host_history_path") + "/" + fileName);
			}
			return 1;
		}catch(Exception e){
			writeLog("error：" + e.getMessage());
			return -1;
		}
	}
	/**
	 * 写黑名单文件
	 */
	private int writeBlackFile(DefaultFTPClient defaultFTPClient,String sysdate,Map<String,String>  ftpOptions,String ftp_use) throws CommonException{
		int num=0;
		String medwholeno="";
		FtpClient ftpClient=null;
		try{
			
			writeLog("写黑名单文件");
			List list = new java.util.ArrayList();
			//文件名YYYYMMDD_Black.txt;
			String fileName = sysdate + "_Black.txt";
			StringBuffer sb = new StringBuffer();
			//写文件头
			sb.append(sysdate);//Blackversion	N8	黑名单版本	YYYYMMDD
			sb.append("\n");
			//写记录
			medwholeno=Tools.processNull(ftpOptions.get("medwholeno"));
			list = publicDao.findBySQL("select a.card_no,decode(a.bind_state,'0','01','1','02','') as  zxc_flag from card_app_bind a,card_baseinfo c where a.card_no=c.card_no and a.app_type='05' and c.card_state in('9','2','3') and a.bind_state='0' ");//黑名单列表
			//list = publicDao.findBySQL("select a.card_no,decode(a.bind_state,'0','01','1','02','') as  zxc_flag from card_app_bind a,card_baseinfo c where a.card_no=c.card_no and a.app_type='05' and c.card_state in('9','2','3') and a.bind_state='0' and a.reserve2='"+medwholeno+"'");//黑名单列表
			if(null!=list&&list.size()>0){
				for(int i=0;i<list.size();i++){
					Object[] obj=(Object[])list.get(i);
					String card_No = obj[0].toString();
					String zxc_Flag = obj[1].toString();
					sb.append(Tools.tensileString(card_No,20,true,"0"));//Cardno	N20	卡应用序列号	发行流水号(卡面号)
					sb.append(Tools.tensileString(zxc_Flag,2,true,"0"));//
					if(!medwholeno.equals("330499")){
						sb.append(Tools.tensileString(medwholeno, 6, true, "0"));
					}
					sb.append("\n");//
				}
				ftpClient = reConnectFtp_zxc_gj(ftpClient,ftpOptions.get("user_name"), ftpOptions.get("pwd"),ftpOptions.get("host_ip"));
				writeFile(ftpClient,Tools.processNull(ftpOptions.get("black")) + "/" + fileName,sb.toString());
				//writeFile_zxc(defaultFTPClient,Tools.processNull(ftpOptions.get("black")) , fileName,sb.toString(),ftpOptions);
			}
			
		}catch(Exception e){
			writeLog("error：" + e.getMessage());
			return -1;
		}
		return num;
		
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

	/**
	 *写文件 
	 */
	@SuppressWarnings("static-access")
	private int writeFile_zxc(DefaultFTPClient defaultFTPClient,String fileName,String path,String content,Map<String,String>  ftpOptions) throws CommonException{
		try{
			InputStream input = new ByteArrayInputStream(content.getBytes("utf-8"));
			boolean flag=defaultFTPClient.uploadFile(ftpOptions.get("host_ip"), Integer.parseInt(ftpOptions.get("host_port")), ftpOptions.get("user_name"), ftpOptions.get("pwd"), path, fileName, input);
			if(!flag){
				return 0;
			}
			//boolean flag = uploadFile("127.0.0.1", 21, "test", "test", "D:/ftp", "test.txt", input);
		}catch(Exception e){
			e.printStackTrace();
			writeLog("写文件" + fileName + "出错：" + e.getMessage());
			return -1;
		}
		return 0;
	}
	
	private FtpClient reConnectFtp_zxc_gj(FtpClient ftpClient,String user,String password,String ip){
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

	/**
	 *写文件 
	 */
	private int writeFile(FtpClient ftpClient,String fileName,String content) throws CommonException{
		try{
			TelnetOutputStream stream=ftpClient.put(fileName);
			stream.write(content.getBytes());
			stream.close();
		}catch(Exception e){
			e.printStackTrace();
			DefaultFTPClient.writeLog("写文件" + fileName + "出错：" + e.getMessage());
			return -1;
		}
		return 0;
	}

	public void setShortMessageService(ShortMessageService shortMessageService) {
		this.shortMessageService = shortMessageService;
	}


	
}