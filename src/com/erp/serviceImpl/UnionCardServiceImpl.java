package com.erp.serviceImpl;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.net.ftp.FTPClient;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.SysPara;
import com.erp.service.UnionCardService;
import com.erp.task.DefaultFTPClient;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.Tools;

/********************************************
 * @desc 互联互通文件处理
 * @author yangn
 * @date 2016-09-18
 * @Msg 互联互通文件处理
 *      异地消费文件上传
 *      下发文件处理
 ********************************************/
@Service("unionCardService")
public class UnionCardServiceImpl extends BaseServiceImpl implements UnionCardService{
    private Logger logger = Logger.getLogger(UnionCardServiceImpl.class);
    public static final String testFlag = "0";
    public static final String CONNECT_UNION_DATA_ADMIN = "connect_union_data_admin";
    public static final boolean IS_SLEEP_WAIT = false;
    public static final long  SLEEP_WAIT_LONG = 5000L;
    /**
     * 写互联互通消费文件
     * @param transCityCode 交易地城市代码
     * @param belongCityCode 卡属地城市代码 形如 '2144','5000','3000'
     * @param includeFlag true 包含卡属地城市代码  false 排除卡属地城市代码
     * @param clrDate 清分日期
     * @throws CommonException
     */
    public void saveUploadUnionCardFh(String belongCityCode,boolean includeFlag,String clrDate) throws CommonException{
        DefaultFTPClient client = null;
        try{
            //1.基本条件判断
            logger.error("-------------------------------------------------------");
            logger.error("写互联互通消费文件");
            SysPara sysPara = this.getSysParaByParaCode("CITY_CODE");
            if(sysPara == null){
                throw new CommonException("城市代码配置不正确！");
            }
            if(Tools.processNull(sysPara.getParaValue()).length() != 4 ){
                throw new CommonException("城市代码配置不正确！");
            }
            String transCityCode = sysPara.getParaValue();
            logger.error("检查FTP配置信息");
            Map<String,String> ftpMap = this.initFtpOptions(CONNECT_UNION_DATA_ADMIN);
            if(Tools.processNull(ftpMap.get("host_upload_path")).equals("")){
                throw new CommonException("获取ftp配置出错，数据存放路径未配置，请联系系统管理员！");
            }else{
                logger.error("host_upload_path:" + ftpMap.get("host_upload_path"));
            }
            client = this.checkFtp(ftpMap);
            if(!(client.changeWorkingDirectory(Tools.processNull(ftpMap.get("host_upload_path"))))){
                throw new CommonException("FTP切换到目录" + ftpMap.get("host_upload_path") + "失败！请检查FTP路径设置信息！");
            }else{
                logger.error("FTP目录切换正常");
            }
            logger.error("当前工作目录" + client.printWorkingDirectory());
            logger.error("FTP检查完毕");
            Date sysDate = (Date) this.findOnlyFieldBySql("select sysdate from dual");
            String sendDate = DateUtil.formatDate(sysDate,"yyyyMMddHHmmss");
            String sendDealNo = this.getSequenceByName("seq_action_no");//发送批次号
            String serial = this.getSequenceByName("seq_union_file_no");//文件序列号
            String fileName = "FH" + sendDate.substring(2,8) + Tools.tensileString(transCityCode,8,false,"0") + Tools.tensileString(String.valueOf(serial),6,true,"0");//文件名
            String upsql = "update pay_offline_union_fh t set t.fh_falg = '0',t.fh_deal_no = " + sendDealNo + ",t.fh_name = '" + fileName +"' where t.fh_falg = '1' and t.fh_deal_no is null ";
            if(includeFlag){
                if(!Tools.processNull(belongCityCode).equals("")){
                    upsql += " and t.belong_city_code in (" + belongCityCode + ")";
                }
            }else{
                if(!Tools.processNull(belongCityCode).equals("")){
                    upsql += " and t.belong_city_code not in (" + belongCityCode + ")";
                }
            }
            if(!Tools.processNull(clrDate).equals("")){
                upsql += " and t.clr_date = '" + clrDate + "'";
            }
            int count = this.publicDao.doSql(upsql);
            if(count <= 0){
                throw new CommonException("未找到需要上传的互联互通消费数据");
            }
            StringBuffer querySql = new StringBuffer();
            querySql.append("select t.deal_no,'0600000000',t.acpt_id,'00000001','" + transCityCode +"',t.end_id,");
            querySql.append("t.psam_no psam_no01,'0',t.end_deal_no,t.psam_deal_no,t.psam_no psam_no02,t.card_no,");
            querySql.append("t.card_deal_count,t.card_in_type,t.card_in_subtype,t.acc_bal,t.deal_amt,");
            querySql.append("t.deal_date,t.tac ");
            querySql.append("from pay_offline_union_fh t where t.fh_deal_no = " + sendDealNo);
            List<?> allData = this.findBySql(querySql.toString());
            if(allData == null || allData.isEmpty()){
                throw new CommonException("根据发送流水获取异地消费数据不正确！");
            }
            if(allData.size() != count){
                throw new CommonException("根据发送流水获取异地消费数据数量不一致！");
            }
            //2.写文件头
            StringBuffer fhData = new StringBuffer();
            fhData.append("01");//N2 版本号
            fhData.append("2000");//N4 值2000 ；(注：主要用于区别文件类型，类型源存在于交易类型对应描述表格中)
            fhData.append(Constants.NEWLINE);//N2 回车符 0x0d和0x0a
            fhData.append(Tools.tensileString("" + allData.size(),5,true,"0"));//N5	记录总数
            fhData.append(Tools.tensileString(transCityCode,8,false,"0"));//N8 交易地城市代码+0000
            fhData.append("0174");//N4 记录长度 单条记录的长度
            fhData.append("0");//N1	特有数据启用标志 0：不用；1：启用
            fhData.append(Tools.tensileString("0",8,true,"0"));//保留域 全0
            fhData.append(Constants.NEWLINE);//N2 回车符 0x0d和0x0a
            int dataLen = allData.size();
            for(int i = 0;i < dataLen;i++){
                Object[] tempObj = (Object[]) allData.get(i);
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[0]),12,true,"0"));//N12 （注：由接入城市产生的交易流水号）
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[1]),10,true,"0"));//N10  交易性质
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[2]),8,true,"0"));//N8 企业运营系统下的营运单位代码
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[3]),8,true,"0"));//N8 运营系统的公司采集点序号8位：取值范围为00000001～99999999
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[4]),4,true,"0"));//N4 交易发生地城市代码
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[5]),12,true,"0"));//N12 POS机编号
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[6]),16,true,"0"));//N16 PSAM卡号
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[7]),1,true,"0"));//N1 0为正常交易 1为锁卡交易
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[8]),9,true,"0"));//N9 POS机交易流水号
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[9]),9,true,"0"));//N9 SAM卡流水号
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[10]),12,true,"0"));//N12 由文件发送方按一定规则编定的下属的终端机编码：取值范围为000000000001～999999999999（PSAM卡终端机编号）
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[11]),20,true,"0"));//N4 + N16 卡属地城市代码 + 卡内号（从卡内读出的城市代码）
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[12]),6,true,"0"));//N6 卡消费计数器
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[13]),2,true,"0"));//N2 主卡类型
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[14]),2,true,"0"));//N2 子卡类型
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[15]),8,true,"0"));//N8 消费前卡余额
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[16]),8,true,"0"));//N8 交易金额
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[17]),14,true,"0"));//N14 交易日期 + 交易时间
                fhData.append(Tools.tensileString(Tools.processNull(tempObj[18]),8,true,"0"));//N8 交易认证码
                fhData.append(Tools.tensileString(Tools.processNull("01"),2,true,"0"));//N2 卡内版本号
                fhData.append(Tools.tensileString(Tools.processNull(testFlag),1,true,"0"));//N1 测试标志1
                fhData.append(Constants.NEWLINE);//N2 回车符 0x0d和0x0a
            }
            StringBuffer moveDataSql = new StringBuffer();
            moveDataSql.append("insert into pay_offline_union_fs(");
            moveDataSql.append("end_deal_no,acpt_id,end_id,card_no,card_in_type,card_in_subtype,card_valid_date,card_start_date,");
            moveDataSql.append("app_valid_date,card_deal_count,psam_deal_no,acc_bal,deal_amt,deal_date,deal_kind,psam_no,tac,");
            moveDataSql.append("ash_flag,credit_limit,deal_batch_no,send_file_name,file_line_no,send_date,deal_no,deal_code,");
            moveDataSql.append("deal_state,clr_date,refuse_reason,org_id,cancel_deal_batch_id,cancel_end_deal_no,points,fh_falg,");
            moveDataSql.append("fh_name,fh_date,belong_city_code,trans_city_code,fh_deal_no) ");
            moveDataSql.append("select b.end_deal_no,b.acpt_id,b.end_id,b.card_no,b.card_in_type,b.card_in_subtype,b.card_valid_date,b.card_start_date,");
            moveDataSql.append("b.app_valid_date,b.card_deal_count,b.psam_deal_no,b.acc_bal,b.deal_amt,b.deal_date,b.deal_kind,b.psam_no,b.tac,");
            moveDataSql.append("b.ash_flag,b.credit_limit,b.deal_batch_no,b.send_file_name,b.file_line_no,b.send_date,b.deal_no,b.deal_code,");
            moveDataSql.append("b.deal_state,b.clr_date, b.refuse_reason,b.org_id,b.cancel_deal_batch_id,b.cancel_end_deal_no,b.points,b.fh_falg,");
            moveDataSql.append("b.fh_name,b.fh_date,b.belong_city_code,b.trans_city_code,b.fh_deal_no ");
            moveDataSql.append("from  pay_offline_union_fh b where b.FH_DEAL_NO = " + sendDealNo);
            int moveCount = this.publicDao.doSql(moveDataSql.toString());
            if(moveCount != count){
                throw new CommonException("上传数据数量和移入历史表数据不一致！");
            }
            ByteArrayInputStream is = new ByteArrayInputStream(fhData.toString().getBytes("GBK"));
            client.setControlEncoding("UTF-8");
            client.enterLocalPassiveMode();
            client.setFileType(FTPClient.BINARY_FILE_TYPE);
            try {
            	client.storeFile(new String(fileName.getBytes("UTF-8"),"iso-8859-1"),is);
			} catch (Exception e) {
				throw new CommonException("上传文件到FTP出现错误：请检查ftp路径设置及网络问题！");
			}
            logger.error("文件" + fileName + "上传成功");
        }catch(Exception e){
            logger.error(e);
            throw new CommonException(e.getMessage());
        }finally{
            if(client != null && client.isAvailable()){
                try{
                    client.logout();
                    client.disconnect();
                }catch(IOException e){
                    e.printStackTrace();
                }
            }
            logger.error("结束上传互联互通消费文件");
        }
    }

    /**
     * 处理互联互通下发文件
     * @throws CommonException
     */
    public void saveDownLoadUnionCardFile() throws CommonException{
        DefaultFTPClient client = null;
        try{
            //1.基本条件判断
            logger.error("-------------------------------------------------------");
            logger.error("开始读取互联互通下发文件");
            SysPara sysPara = this.getSysParaByParaCode("CITY_CODE");
            if(sysPara == null){
                throw new CommonException("城市代码配置不正确！");
            }
            if(Tools.processNull(sysPara.getParaValue()).length() != 4 ){
                throw new CommonException("城市代码配置不正确！");
            }
            @SuppressWarnings("unused")
			String transCityCode = sysPara.getParaCode();
            String sysDate = this.getDateBaseDateStr();
            String clrDate = this.getClrDate();
            Map<String,String> cardOrgIds = getCardOrgIds();
            logger.error("检查FTP配置信息");
            Map<String,String> ftpMap = this.initFtpOptions(CONNECT_UNION_DATA_ADMIN);
            if(Tools.processNull(ftpMap.get("host_download_path")).equals("")){
                throw new CommonException("获取ftp配置出错，异地消费数据存放路径未配置，请联系系统管理员！");
            }else{
                logger.error("host_download_path:" + ftpMap.get("host_download_path"));
            }
            if(Tools.processNull(ftpMap.get("host_err_path")).equals("")){
                throw new CommonException("获取ftp配置出错，异地消费错误数据存放路径未配置，请联系系统管理员！");
            }else{
                logger.error("host_err_path:" + ftpMap.get("host_err_path"));
            }
            if(Tools.processNull(ftpMap.get("host_repeat_path")).equals("")){
                throw new CommonException("获取ftp配置出错，异地消费重复数据存放路径未配置，请联系系统管理员！");
            }else{
                logger.error("host_repeat_path:" + ftpMap.get("host_repeat_path"));
            }
            if(Tools.processNull(ftpMap.get("host_history_path")).equals("")){
                throw new CommonException("获取ftp配置出错，异地消费历史数据存放路径未配置，请联系系统管理员！");
            }else{
                logger.error("host_history_path:" + ftpMap.get("host_history_path"));
            }
            try {
            	logger.error("检测是否存在往日未处理数据......");
            	StringBuffer eqs = new StringBuffer();
            	eqs.append("update pay_offline_union_dt t set ");
            	eqs.append("(t.deal_no,t.acpt_id,t.deal_amt) = (select b.deal_no,b.acpt_id,b.deal_amt from pay_offline_union_fh b where b.deal_no = t.centerseq)  ");
            	eqs.append("where  exists (select 1 from pay_offline_union_fh b where b.deal_no = t.centerseq)  ");
            	eqs.append("and t.acpt_id = '000000000000000' ");
            	int eqsint = publicDao.doSql(eqs.toString());
            	logger.error("检测往日未处理数据:" + eqsint + "条！");
            	this.publicDao.doSql("commit");
            }catch(Exception eq) {
            	logger.error("处理往日数据失败：" + eq.getMessage());
            }
            client = this.checkFtp(ftpMap);
            if(!(client.changeWorkingDirectory(Tools.processNull(ftpMap.get("host_download_path"))))){
                throw new CommonException("FTP切换到目录" + ftpMap.get("host_download_path") + "失败！请检查FTP路径设置信息！");
            }else{
                logger.error("FTP目录切换正常");
            }
            logger.error("当前工作目录" + client.printWorkingDirectory());
            logger.error("FTP检查完毕");
            List<String> fileNames = client.listNames(null,1000);
            if(fileNames == null || fileNames.isEmpty()){
                throw new CommonException("未查询到需要处理的互联互通下发文件!");
            }else{
                logger.error("检测到" + fileNames.size() + "个文件需要处理！");
            }
            int len = fileNames.size();
            for(int i = 0;i < len;i++){
                String tempFileName = fileNames.get(i);
                if(Tools.processNull(tempFileName).toUpperCase().startsWith("DF")){
                    logger.error("读取互联互通卡属地清算中心接收数据中心下发的消费处理结果DF," + tempFileName);
                    try{
                        List<String> allFileConts = client.getFileContent(tempFileName);
                        if(allFileConts == null || allFileConts.isEmpty()){
                            logger.error("处理文件" + tempFileName + "失败,内容为空!");
                            continue;
                        }
                        String firstRow = allFileConts.get(0);
                        if(Tools.processNull(firstRow).length() != 6){
                            logger.error("处理文件" + tempFileName + "失败,文件说明区字段不正确!");
                            continue;
                        }
                        String dfVersion = firstRow.substring(0,2);
                        String dfDealType = firstRow.substring(2,6);
                        String secRow = allFileConts.get(1);
                        if(Tools.processNull(secRow).length() != 25){
                            logger.error("处理文件" + tempFileName + "失败,交易头说明字段不正确!");
                            continue;
                        }
                        String dfRecCount = secRow.substring(0,5);
                        String dfTransCityCode = secRow.substring(5,13);
                        String dfRecLen = secRow.substring(13,17);
                        String dfReserved = secRow.substring(17,25);
                        int dfSize = allFileConts.size();
                        BigDecimal isExistsCount = (BigDecimal) this.findOnlyFieldBySql("select count(1) from pay_offline_union_df t where t.send_file_name = '" + tempFileName + "'");
                        if(isExistsCount.longValue() > 0){
                            logger.error("文件" + tempFileName + "已处理，无需重复进行处理!");
                            if(!client.rename(tempFileName,Tools.processNull(ftpMap.get("host_repeat_path")) + tempFileName)){
                                throw new CommonException("移动文件到历史目录失败,filename=" + tempFileName);
                            }
                            continue;
                        }else{
                            if(IS_SLEEP_WAIT){
                                logger.error("延迟等待文件" + SLEEP_WAIT_LONG + "毫秒");
                                Thread.sleep(SLEEP_WAIT_LONG);
                            }
                        }
                        StringBuffer dfSb = new StringBuffer();
                        for(int j = 2;j < dfSize;j++){
                            int pos = 0;
                            String tempDfRow = allFileConts.get(j);
                            dfSb.append("'insert into pay_offline_union_df(center_seq,deal_type,lock_flag,trans_city_code,acpt_id,belong_city_code,card_no,card_org_id,");
                            dfSb.append("card_tr_count,bal_bef,deal_amt,deal_date,deal_time,tac,card_ver_no,settle_date,");
                            dfSb.append("test_flag,send_file_name,file_line_no,send_date,rec_num,area_id,reclens,version,txn_sub_type,clr_date,reserved) values (");
                            dfSb.append("''" + Tools.processNull(tempDfRow.substring(pos,pos + 10)) + "'',");
                            pos = pos + 10;
                            dfSb.append("''" + Tools.processNull(tempDfRow.substring(pos,pos + 10)) + "'',");
                            pos = pos + 10;
                            dfSb.append("''" + Tools.processNull(tempDfRow.substring(pos,pos + 1)) + "'',");
                            pos = pos + 1;
                            String tempAcptId = Tools.processNull(tempDfRow.substring(pos,pos + 4));
                            dfSb.append("''" + tempAcptId + "'',");
                            if(tempAcptId.equals(cityCodes.sh)){
                                dfSb.append("''" + Constants.SHANGHAI_BIZID + "'',");
                            }else{
                                dfSb.append("''" + Constants.QUANGUO_BIZID + "'',");
                            }
                            pos = pos + 4;
                            dfSb.append("''" + Tools.processNull(tempDfRow.substring(pos,pos + 4)) + "'',");
                            //pos = pos + 4;
                            String tempCardNo = Tools.processNull(tempDfRow.substring(pos,pos + 20));
                            dfSb.append("''" + tempCardNo + "'',");
                            dfSb.append("''" + Tools.processNull(cardOrgIds.get(tempCardNo.substring(4,6))) + "'',");
                            pos = pos + 20;
                            dfSb.append("''" + Tools.processNull(tempDfRow.substring(pos,pos + 6)) + "'',");
                            pos = pos + 6;
                            dfSb.append("''" + Tools.processNull(tempDfRow.substring(pos,pos + 8)) + "'',");
                            pos = pos + 8;
                            dfSb.append("''" + Tools.processNull(tempDfRow.substring(pos,pos + 8)) + "'',");
                            pos = pos + 8;
                            dfSb.append("''" + Tools.processNull(tempDfRow.substring(pos,pos + 8)) + "'',");
                            pos = pos + 8;
                            dfSb.append("''" + Tools.processNull(tempDfRow.substring(pos,pos + 6)) + "'',");
                            pos = pos + 6;
                            dfSb.append("''" + Tools.processNull(tempDfRow.substring(pos,pos + 8)) + "'',");
                            pos = pos + 8;
                            dfSb.append("''" + Tools.processNull(tempDfRow.substring(pos,pos + 2)) + "'',");
                            pos = pos + 2;
                            String tempQsDateString = Tools.processNull(tempDfRow.substring(pos,pos + 8));
                            String tempQsDate = tempQsDateString.substring(0,4) + "-" + tempQsDateString.substring(4,6) + "-" + tempQsDateString.substring(6,8);
                            dfSb.append("''" + tempQsDate + "'',");
                            pos = pos + 8;
                            dfSb.append("''" + Tools.processNull(tempDfRow.substring(pos,pos + 1)) + "'',");
                            pos = pos + 1;
                            dfSb.append("''" + tempFileName + "'',");
                            dfSb.append("" + (j - 1) + ",");
                            dfSb.append("to_date(''" + sysDate + "'',''yyyy-mm-dd hh24:mi:ss''),");
                            dfSb.append("" + dfRecCount + ",");
                            dfSb.append("''" + dfTransCityCode + "'',");
                            dfSb.append("''" + dfRecLen + "'',");
                            dfSb.append("''" + dfVersion + "'',");
                            dfSb.append("''" + dfDealType + "'',");
                            dfSb.append("''" + clrDate + "'',");
                            dfSb.append("''" + dfReserved + "'')',");
                            if(j % 500 == 0){
                                dfSb = dfSb.deleteCharAt(dfSb.length() - 1);
                                publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + dfSb.toString() + "))");
                                dfSb = new StringBuffer();
                            }
                        }
                        if(dfSb.length() > 0){
                            dfSb = dfSb.deleteCharAt(dfSb.length() - 1);
                            publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + dfSb.toString() + "))");
                            dfSb = new StringBuffer();
                        }
                        if(!client.rename(tempFileName,Tools.processNull(ftpMap.get("host_history_path")) + tempFileName)){
                            throw new CommonException("移动文件到历史目录失败,filename=" + tempFileName);
                        }
                        this.publicDao.doSql("commit");
                        logger.error("文件" + tempFileName + "处理成功!");
                    }catch(Exception e){
                        this.publicDao.doSql("rollback");
                        logger.error("处理文件" + tempFileName + "出现错误:" + e.getMessage());
                    }
                }else if(Tools.processNull(tempFileName).toUpperCase().startsWith("DT")){
                    logger.error("读取互联互通交易发生地清算中心接收数据中心下发的消费处理结果DT," + tempFileName);
                    try{
                        List<String> allFileConts = client.getFileContent(tempFileName);
                        if(allFileConts == null || allFileConts.isEmpty()){
                            logger.error("处理文件" + tempFileName + "失败,内容为空!");
                            continue;
                        }
                        String firstRow = allFileConts.get(0);
                        if(Tools.processNull(firstRow).length() != 6){
                            logger.error("处理文件" + tempFileName + "失败,文件说明区字段不正确!");
                            continue;
                        }
                        String dtVersion = firstRow.substring(0,2);
                        String dtDealType = firstRow.substring(2,6);
                        String secRow = allFileConts.get(1);
                        if(Tools.processNull(secRow).length() != 25){
                            logger.error("处理文件" + tempFileName + "失败,交易头说明字段不正确!");
                            continue;
                        }
                        String dtRecCount = secRow.substring(0,5);
                        String dtTransCityCode = secRow.substring(5,13);
                        String dtRecLen = secRow.substring(13,17);
                        String dtReserved = secRow.substring(17,25);
                        int dtSize = allFileConts.size();
                        BigDecimal isExistsCount = (BigDecimal) this.findOnlyFieldBySql("select count(1) from pay_offline_union_dt t where t.send_file_name = '" + tempFileName + "'");
                        if(isExistsCount.longValue() > 0){
                            logger.error("文件" + tempFileName + "已处理，无需重复进行处理!");
                            if(!client.rename(tempFileName,Tools.processNull(ftpMap.get("host_repeat_path")) + tempFileName)){
                                throw new CommonException("移动文件到历史目录失败,filename=" + tempFileName);
                            }
                            continue;
                        }else{
                            if(IS_SLEEP_WAIT){
                                logger.error("延迟等待文件" + SLEEP_WAIT_LONG + "毫秒");
                                Thread.sleep(SLEEP_WAIT_LONG);
                            }
                        }
                        StringBuffer dtSb = new StringBuffer();
                        for(int j = 2;j < dtSize;j++){
                            int pos = 0;
                            String tempDtRow = allFileConts.get(j);
                            dtSb.append("'insert into pay_offline_union_dt(");
                            dtSb.append("centerseq,psam_no,psam_deal_no,trans_city_code,belong_city_code,card_org_id,");
                            dtSb.append("card_no,card_tr_count,deal_date,deal_time,settle_date,settle_state,refuse_reason,test_flag,");
                            dtSb.append("send_file_name,file_line_no,deal_amt,acpt_id,rec_num,area_id,reserved,reclens,version,send_date,clr_date,txn_sub_type) values (");
                            dtSb.append("''" + Tools.processNull(tempDtRow.substring(pos,pos + 10)) + "'',");
                            pos = pos + 10;
                            dtSb.append("''" + Tools.processNull(tempDtRow.substring(pos,pos + 16)) + "'',");
                            pos = pos + 16;
                            dtSb.append("''" + Tools.processNull(tempDtRow.substring(pos,pos + 9)) + "'',");
                            pos = pos + 9;
                            dtSb.append("''" + Tools.processNull(tempDtRow.substring(pos,pos + 4)) + "'',");
                            pos = pos + 4;
                            String tempBelongCityCode = Tools.processNull(tempDtRow.substring(pos,pos + 4));
                            dtSb.append("''" + tempBelongCityCode + "'',");
                            if(Tools.processNull(tempBelongCityCode).equals(cityCodes.sh)){
                                dtSb.append("''" + "0001" + "'',");
                            }else{
                                dtSb.append("''" + "0000" + "'',");
                            }
                            //pos = pos + 4;
                            dtSb.append("''" + Tools.processNull(tempDtRow.substring(pos,pos + 20)) + "'',");
                            pos = pos + 20;
                            dtSb.append("''" + Tools.processNull(tempDtRow.substring(pos,pos + 6)) + "'',");
                            pos = pos + 6;
                            dtSb.append("to_date(''" + Tools.processNull(tempDtRow.substring(pos,pos + 14)) + "'',''yyyymmddhh24miss''),");
                            dtSb.append("to_date(''" + Tools.processNull(tempDtRow.substring(pos,pos + 14)) + "'',''yyyymmddhh24miss''),");
                            pos = pos + 14;
                            String tempQsDateString = Tools.processNull(tempDtRow.substring(pos,pos + 8));
                            String tempQsDate = tempQsDateString.substring(0,4) + "-" + tempQsDateString.substring(4,6) + "-" + tempQsDateString.substring(6,8);
                            dtSb.append("''" + tempQsDate + "'',");
                            pos = pos + 8;
                            String settleState = Tools.processNull(tempDtRow.substring(pos,pos + 6));
                            dtSb.append("''" + settleState + "'',");
                            if(Tools.processNull(settleState).equals(settleStates.zc)){
                                dtSb.append("''" + "00" + "'',");
                            }else{
                                dtSb.append("''" + "90" + "'',");
                            }
                            pos = pos + 6;
                            dtSb.append("''" + Tools.processNull(tempDtRow.substring(pos,pos + 1)) + "'',");
                            pos = pos + 1;
                            dtSb.append("''" + tempFileName + "'',");
                            dtSb.append("" + (j - 1) + ",");
                            dtSb.append(0 + ",");
                            dtSb.append("''" + "000000000000000" + "'',");
                            dtSb.append(dtRecCount + ",");
                            dtSb.append("''" + dtTransCityCode + "'',");
                            dtSb.append("''" + dtReserved + "'',");
                            dtSb.append(dtRecLen + ",");
                            dtSb.append("''" + dtVersion + "'',");
                            dtSb.append("to_date(''" + sysDate + "'',''yyyy-mm-dd hh24:mi:ss''),");
                            dtSb.append("''" + clrDate + "'',");
                            dtSb.append("''" + dtDealType + "'')',");
                            if(j % 500 == 0){
                                dtSb = dtSb.deleteCharAt(dtSb.length() - 1);
                                publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + dtSb.toString() + "))");
                                dtSb = new StringBuffer();
                            }
                        }
                        if(dtSb.length() > 0){
                            dtSb = dtSb.deleteCharAt(dtSb.length() - 1);
                            publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + dtSb.toString() + "))");
                            dtSb = new StringBuffer();
                        }
                        String updateDtSql = "update pay_offline_union_dt t set ";
                        updateDtSql = updateDtSql + "(t.deal_no,t.acpt_id,t.deal_amt) = (select b.deal_no,b.acpt_id,b.deal_amt from pay_offline_union_fs b where b.deal_no = t.centerseq) ";
                        updateDtSql = updateDtSql + "where t.send_file_name = '" + tempFileName + "' ";
                        updateDtSql = updateDtSql + "and exists (select 1 from pay_offline_union_fs b where b.deal_no = t.centerseq )";
                        this.publicDao.doSql(updateDtSql);
                        if(!client.rename(tempFileName,Tools.processNull(ftpMap.get("host_history_path")) + tempFileName)){
                            throw new CommonException("移动文件到历史目录失败,filename=" + tempFileName);
                        }
                        this.publicDao.doSql("commit");
                        logger.error("文件" + tempFileName + "处理成功!");
                    }catch(Exception e){
                        this.publicDao.doSql("rollback");
                        logger.error("处理文件" + tempFileName + "出现错误:" + e.getMessage());
                    }
                }else if(Tools.processNull(tempFileName).toUpperCase().startsWith("EC")){
                    logger.error("读取互联互通数据中心发布错误代码说明的文件EC," + tempFileName);
                    try{
                        List<String> allFileConts = client.getFileContent(tempFileName);
                        if(allFileConts == null || allFileConts.isEmpty()){
                            logger.error("处理文件" + tempFileName + "失败,内容为空!");
                            continue;
                        }
                        String firstRow = allFileConts.get(0);
                        if(Tools.processNull(firstRow).length() != 6){
                            logger.error("处理文件" + tempFileName + "失败,文件说明区字段不正确!");
                            continue;
                        }
                        String ecVersion = firstRow.substring(0,2);
                        String ecDealType = firstRow.substring(2,6);
                        String secRow = allFileConts.get(1);
                        if(Tools.processNull(secRow).length() != 8){
                            logger.error("处理文件" + tempFileName + "失败,交易头说明字段不正确!");
                            continue;
                        }
                        String ecRecCount = secRow.substring(0,8);
                        int ecSize = allFileConts.size();
                        BigDecimal isExistsCount = (BigDecimal) this.findOnlyFieldBySql("select count(1) from pay_offline_union_ec t where t.send_file_name = '" + tempFileName + "'");
                        if(isExistsCount.longValue() > 0){
                            logger.error("文件" + tempFileName + "已处理，无需重复进行处理!");
                            if(!client.rename(tempFileName,Tools.processNull(ftpMap.get("host_repeat_path")) + tempFileName)){
                                throw new CommonException("移动文件到历史目录失败,filename=" + tempFileName);
                            }
                            continue;
                        }else{
                            if(IS_SLEEP_WAIT){
                                logger.error("延迟等待文件" + SLEEP_WAIT_LONG + "毫秒");
                                Thread.sleep(SLEEP_WAIT_LONG);
                            }
                        }
                        StringBuffer ecSb = new StringBuffer();
                        for(int j = 2;j < ecSize;j++){
                            int pos = 0;
                            String tempEcRow = allFileConts.get(j);
                            ecSb.append("'insert into pay_offline_union_ec(");
                            ecSb.append("code_type,code_num,chn_desc,reserved,rec_num,version,");
                            ecSb.append("txn_sub_type,send_file_name,file_line_no,send_date,state ");
                            ecSb.append(") values (");
                            ecSb.append("''" + Tools.processNull(tempEcRow.substring(pos,pos + 4)) + "'',");
                            pos = pos + 4;
                            ecSb.append("''" + Tools.processNull(tempEcRow.substring(pos,pos + 6)) + "'',");
                            pos = pos + 6;
                            String tempChnName = tempEcRow.substring(pos,tempEcRow.length() - 18).trim();
                            ecSb.append("''" + Tools.processNull(new String(tempChnName.getBytes("GBK"),"GBK")) + "'',");
                            pos = pos + tempEcRow.length() - 18;
                            ecSb.append("''" + Tools.processNull(tempEcRow.substring(pos,pos + 8)) + "'',");
                            pos = pos + 8;
                            ecSb.append("" + ecRecCount + ",");
                            ecSb.append("''" + ecVersion + "'',");
                            ecSb.append("''" + ecDealType + "'',");
                            ecSb.append("''" + tempFileName + "'',");
                            ecSb.append("" + (j - 1) + ",");
                            ecSb.append("to_date(''" + sysDate + "'',''yyyy-mm-dd hh24:mi:ss''),");
                            ecSb.append("''" + "0" + "'')',");
                            if(j % 500 == 0){
                                ecSb = ecSb.deleteCharAt(ecSb.length() - 1);
                                publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + ecSb.toString() + "))");
                                ecSb = new StringBuffer();
                            }
                        }
                        if(ecSb.length() > 0){
                            ecSb = ecSb.deleteCharAt(ecSb.length() - 1);
                            publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + ecSb.toString() + "))");
                            ecSb = new StringBuffer();
                        }
                        this.publicDao.doSql("update pay_offline_union_ec t set t.state = '1' where t.state = '0' and t.send_file_name <> '" + tempFileName + "'");
                        if(!client.rename(tempFileName,Tools.processNull(ftpMap.get("host_history_path")) + tempFileName)){
                            throw new CommonException("移动文件到历史目录失败,filename=" + tempFileName);
                        }
                        this.publicDao.doSql("commit");
                        logger.error("文件" + tempFileName + "处理成功!");
                    }catch(Exception e){
                        this.publicDao.doSql("rollback");
                        logger.error("处理文件" + tempFileName + "出现错误:" + e.getMessage());
                    }
                }else if(Tools.processNull(tempFileName).toUpperCase().startsWith("WL")){
                    logger.error("读取互联互通交易地所承认的卡属城市代码文件WL," + tempFileName);
                    try{
                        List<String> allFileConts = client.getFileContent(tempFileName);
                        if(allFileConts == null || allFileConts.isEmpty()){
                            logger.error("处理文件" + tempFileName + "失败,内容为空!");
                            continue;
                        }
                        String firstRow = allFileConts.get(0);
                        if(Tools.processNull(firstRow).length() != 6){
                            logger.error("处理文件" + tempFileName + "失败,文件说明区字段不正确!");
                            continue;
                        }
                        String wlVersion = firstRow.substring(0,2);
                        String wlDealType = firstRow.substring(2,6);
                        String secRow = allFileConts.get(1);
                        if(Tools.processNull(secRow).length() != 4){
                            logger.error("处理文件" + tempFileName + "失败,交易头说明字段不正确!");
                            continue;
                        }
                        String wlRecCount = secRow.substring(0,4);
                        int wlSize = allFileConts.size();
                        BigDecimal isExistsCount = (BigDecimal) this.findOnlyFieldBySql("select count(1) from pay_offline_union_wl t where t.send_file_name = '" + tempFileName + "'");
                        if(isExistsCount.longValue() > 0){
                            logger.error("文件" + tempFileName + "已处理，无需重复进行处理!");
                            if(!client.rename(tempFileName, Tools.processNull(ftpMap.get("host_repeat_path")) + tempFileName)){
                                throw new CommonException("移动文件到历史目录失败,filename=" + tempFileName);
                            }
                            continue;
                        }else{
                            if(IS_SLEEP_WAIT){
                                logger.error("延迟等待文件" + SLEEP_WAIT_LONG + "毫秒");
                                Thread.sleep(SLEEP_WAIT_LONG);
                            }
                        }
                        StringBuffer wlSb = new StringBuffer();
                        for(int j = 2;j < wlSize;j++){
                            int pos = 0;
                            String tempWlRow = allFileConts.get(j);
                            wlSb.append("'insert into pay_offline_union_wl(");
                            wlSb.append("city_code,city_name,rec_num,send_file_name,");
                            wlSb.append("file_line_no,send_date,version,txn_sub_type,state");
                            wlSb.append(") values (");
                            wlSb.append("''" + Tools.processNull(tempWlRow.substring(pos,pos + 8)) + "'',");
                            pos = pos + 8;
                            wlSb.append("''" + "" + "'',");
                            wlSb.append("" + wlRecCount + ",");
                            wlSb.append("''" + tempFileName + "'',");
                            wlSb.append("" + (j - 1) + ",");
                            wlSb.append("to_date(''" + sysDate + "'',''yyyy-mm-dd hh24:mi:ss''),");
                            wlSb.append("''" + wlVersion + "'',");
                            wlSb.append("''" + wlDealType + "'',");
                            wlSb.append("''" + "0" + "'')',");
                            if(j % 500 == 0){
                                wlSb = wlSb.deleteCharAt(wlSb.length() - 1);
                                publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + wlSb.toString() + "))");
                                wlSb = new StringBuffer();
                            }
                        }
                        if(wlSb.length() > 0){
                            wlSb = wlSb.deleteCharAt(wlSb.length() - 1);
                            publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + wlSb.toString() + "))");
                            wlSb = new StringBuffer();
                        }
                        this.publicDao.doSql("update pay_offline_union_wl t set t.state = '1' where t.state = '0' and t.send_file_name <> '" + tempFileName + "'");
                        if(!client.rename(tempFileName,Tools.processNull(ftpMap.get("host_history_path")) + tempFileName)){
                            throw new CommonException("移动文件到历史目录失败,filename=" + tempFileName);
                        }
                        this.publicDao.doSql("commit");
                        logger.error("文件" + tempFileName + "处理成功!");
                    }catch(Exception e){
                        this.publicDao.doSql("rollback");
                        logger.error("处理文件" + tempFileName + "出现错误:" + e.getMessage());
                    }
                }else if(Tools.processNull(tempFileName).toUpperCase().startsWith("SA")){
                    logger.error("读取互联互通可疑交易调整明细文件SA," + tempFileName);
                    try{
                        List<String> allFileConts = client.getFileContent(tempFileName);
                        if(allFileConts == null || allFileConts.isEmpty()){
                            logger.error("处理文件" + tempFileName + "失败,内容为空!");
                            continue;
                        }
                        String firstRow = allFileConts.get(0);
                        if(Tools.processNull(firstRow).length() != 6){
                            logger.error("处理文件" + tempFileName + "失败,文件说明区字段不正确!");
                            continue;
                        }
                        String saVersion = firstRow.substring(0,2);
                        String saDealType = firstRow.substring(2,6);
                        String secRow = allFileConts.get(1);
                        if(Tools.processNull(secRow).length() != 28){
                            logger.error("处理文件" + tempFileName + "失败,交易头说明字段不正确!");
                            continue;
                        }
                        String saRecCount = secRow.substring(0,8);
                        String saTransCityCode = secRow.substring(8,16);
                        String saRecLen = secRow.substring(16,20);
                        String saReserved = secRow.substring(20,28);
                        int saSize = allFileConts.size();
                        BigDecimal isExistsCount = (BigDecimal) this.findOnlyFieldBySql("select count(1) from pay_offline_union_sa t where t.send_file_name = '" + tempFileName + "'");
                        if(isExistsCount.longValue() > 0){
                            logger.error("文件" + tempFileName + "已处理，无需重复进行处理!");
                            if(!client.rename(tempFileName, Tools.processNull(ftpMap.get("host_repeat_path")) + tempFileName)){
                                throw new CommonException("移动文件到历史目录失败,filename=" + tempFileName);
                            }
                            continue;
                        }else{
                            if(IS_SLEEP_WAIT){
                                logger.error("延迟等待文件" + SLEEP_WAIT_LONG + "毫秒");
                                Thread.sleep(SLEEP_WAIT_LONG);
                            }
                        }
                        StringBuffer saSb = new StringBuffer();
                        for(int j = 2;j < saSize;j++){
                            int pos = 0;
                            String tempSaRow = allFileConts.get(j);
                            saSb.append("'insert into pay_offline_union_sa(center_seq,deal_type,lock_flag,trans_city_code,belong_city_code,card_no,");
                            saSb.append("card_tr_count,bal_bef,deal_amt,deal_date,deal_time,tac,card_ver_no,settle_date,test_flag,rec_num,area_id,reserved,reclens,");
                            saSb.append("txn_sub_type,version,send_file_name,file_line_no,send_date) values (");
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 10)) + "'',");
                            pos = pos + 10;
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 10)) + "'',");
                            pos = pos + 10;
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 1)) + "'',");
                            pos = pos + 1;
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 4)) + "'',");
                            pos = pos + 4;
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 4)) + "'',");
                            //pos = pos + 4;
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 20)) + "'',");
                            pos = pos + 20;
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 6)) + "'',");
                            pos = pos + 6;
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 8)) + "'',");
                            pos = pos + 8;
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 8)) + "'',");
                            pos = pos + 8;
                            ////////////////
                            saSb.append("to_date(''" + Tools.processNull(tempSaRow.substring(pos,pos + 14)) + "'',''yyyymmddhh24miss''),");
                            saSb.append("to_date(''" + Tools.processNull(tempSaRow.substring(pos,pos + 14)) + "'',''yyyymmddhh24miss''),");
                           /* saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 8)) + "'',");
                            pos = pos + 8;
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 6)) + "'',");
                            pos = pos + 6;*/
                            pos = pos + 14;
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 8)) + "'',");
                            pos = pos + 8;
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 2)) + "'',");
                            pos = pos + 2;
                            String tempQsDateString = Tools.processNull(tempSaRow.substring(pos,pos + 8));
                            String tempQsDate = tempQsDateString.substring(0,4) + "-" + tempQsDateString.substring(4,6) + "-" + tempQsDateString.substring(6,8);
                            saSb.append("''" + tempQsDate + "'',");
                            pos = pos + 8;
                            saSb.append("''" + Tools.processNull(tempSaRow.substring(pos,pos + 1)) + "'',");
                            pos = pos + 1;
                            saSb.append("" + saRecCount + ",");
                            saSb.append("" + saTransCityCode + ",");
                            saSb.append("" + saReserved + ",");
                            saSb.append("" + saRecLen + ",");
                            saSb.append("''" + saDealType + "'',");
                            saSb.append("''" + saVersion + "'',");
                            saSb.append("''" + tempFileName + "'',");
                            saSb.append("" + (j - 1) + ",");
                            saSb.append("to_date(''" + sysDate + "'',''yyyy-mm-dd hh24:mi:ss''))',");
                            if(j % 500 == 0){
                                saSb = saSb.deleteCharAt(saSb.length() - 1);
                                publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + saSb.toString() + "))");
                                saSb = new StringBuffer();
                            }
                        }
                        if(saSb.length() > 0){
                            saSb = saSb.deleteCharAt(saSb.length() - 1);
                            publicDao.doSql("call pk_public.p_dealsqlbyarray(strArray(" + saSb.toString() + "))");
                            saSb = new StringBuffer();
                        }
                        List tzCenterSeqsList =  this.findBySql("select t.center_seq,t.settle_date from pay_offline_union_sa t where t.send_file_name = '" + tempFileName + "'");
                        if(tzCenterSeqsList != null && tzCenterSeqsList.size() > 0){
                        	for(int m = 0;m < tzCenterSeqsList.size(); m++){
                        		Object[] tempSaRow = (Object[]) tzCenterSeqsList.get(m);
                        		BigDecimal tempTzCenterSeqBig = (BigDecimal) tempSaRow[0];
                        		String tempSaTzSettdate = Tools.processNull(tempSaRow[1]);
                        		this.publicDao.doSql("update pay_offline_union_dt t set t.refuse_reason = '00',t.clr_date = '" + clrDate + "',t.settle_date = '" + tempSaTzSettdate + "' where t.centerseq = " + tempTzCenterSeqBig.longValue() + " "
                        		+ " and rownum < 2 and not exists (select 1 from pay_offline_union_dt b where b.centerseq = " + tempTzCenterSeqBig.longValue() + " and b.refuse_reason = '00')");
                        	}
                        }
                        /*String updateSaSql = "update pay_offline_union_dt t set t.refuse_reason = '00',t.clr_date = '" + clrDate + "' ";
                        updateSaSql = updateSaSql + "where exists (select 1 from pay_offline_union_sa b where b.center_seq = t.centerseq and b.send_file_name = '" + tempFileName + "') ";
                        updateSaSql = updateSaSql + "and rownum < 2 ";
                        this.publicDao.doSql(updateSaSql);*/
                        if(!client.rename(tempFileName,Tools.processNull(ftpMap.get("host_history_path")) + tempFileName)){
                            throw new CommonException("移动文件到历史目录失败,filename=" + tempFileName);
                        }
                        this.publicDao.doSql("commit");
                        logger.error("文件" + tempFileName + "处理成功!");
                    }catch(Exception e){
                        this.publicDao.doSql("rollback");
                        logger.error("处理文件" + tempFileName + "出现错误:" + e.getMessage());
                    }
                }
            }
        }catch(Exception e){
            logger.error(e);
            throw new CommonException(e.getMessage());
        }finally{
            if(client != null && client.isAvailable()){
                try{
                    client.logout();
                    client.disconnect();
                }catch(IOException e){
                   logger.error(e);
                }
            }
            logger.error("结束读取互联互通下发文件");
        }
    }

    public static final class settleStates{
        /**正常*/
        public static final String zc = "000000";
    }
    public static final class cityCodes{
        public static final String sh = "2000";
    }
    public Map<String,String> getCardOrgIds() throws CommonException{
        try{
            List<?> list = this.findBySql("select t.bind_section,t.card_org_id from card_org_bind_section t");
            if(list == null || list.isEmpty()){
                throw new CommonException("找不到发卡方与卡号段对应关系！");
            }
            Map<String,String> map = new HashMap<String,String>();
            int size = list.size();
            for(int i = 0;i < size;i++){
                Object[] tempObj = (Object[]) list.get(i);
                map.put(Tools.processNull(tempObj[0]),Tools.processNull(tempObj[1]));
            }
            return map;
        }catch(Exception e){
            throw new CommonException(e.getMessage());
        }
    }
    /**
     * 手动处理文件
     * @param args
     */
    @SuppressWarnings("unused")
	public static void main(String[] args) throws Exception{
        File tarFile = new File("");
        FileInputStream fis = new FileInputStream(tarFile);
        @SuppressWarnings("resource")
		BufferedReader br = new BufferedReader(new InputStreamReader(fis));
        String firstRow = br.readLine();
        String secRow = br.readLine();
        String tempRow = "";
        while((tempRow = br.readLine()) != null){

        }
    }
}
