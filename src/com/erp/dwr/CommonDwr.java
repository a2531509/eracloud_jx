package com.erp.dwr;

import java.io.File;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.Resource;

import com.erp.model.TrServRec;
import com.erp.service.RechargeService;
import net.sourceforge.pinyin4j.PinyinHelper;
import net.sourceforge.pinyin4j.format.HanyuPinyinCaseType;
import net.sourceforge.pinyin4j.format.HanyuPinyinOutputFormat;
import net.sourceforge.pinyin4j.format.HanyuPinyinToneType;
import net.sourceforge.pinyin4j.format.HanyuPinyinVCharType;

import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.shiro.SecurityUtils;
import org.directwebremoting.io.FileTransfer;
import org.springframework.stereotype.Component;

import com.erp.exception.CommonException;
import com.erp.model.CardBaseinfo;
import com.erp.service.BaseService;
import com.erp.service.CardApplyService;
import com.erp.service.TaskManagementService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.Tools;

@Component(value="commonDwr")
public class CommonDwr {
	public Logger log = Logger.getLogger(CommonDwr.class);
	@Resource(name="baseService")
	private BaseService baseService;
	@Resource(name="cardApplyService")
	private CardApplyService cardApplyService;
	@Resource(name="taskManagementService")
	private TaskManagementService taskManagementService;
	@Resource(name = "rechargeService")
	private RechargeService rechargeService;

	public String getDatabaseDate(){
		try{
			return (String)baseService.findOnlyRowBySql("select to_char(sysdate,'yyyy-mm-dd') from dual");
		}catch(Exception e){
			return DateUtil.getNowDate();
		}
	}
	public String getPinYin(String string){
		String res = "";
		try{
			if(Tools.processNull(string).equals("")){
				return res;
			}
			String t4 = "";
	        char[] t1 = null;
	        t1 = string.trim().toCharArray();
	        String[] t2 = new String[t1.length];
	        HanyuPinyinOutputFormat t3 = new HanyuPinyinOutputFormat();
	        t3.setCaseType(HanyuPinyinCaseType.LOWERCASE);//大小写
	        t3.setToneType(HanyuPinyinToneType.WITHOUT_TONE);//音标
	        t3.setVCharType(HanyuPinyinVCharType.WITH_V);
	        int t0 = t1.length;
            for (int i = 0; i < t0; i++){
                if(Character.toString(t1[i]).matches("[\\u4E00-\\u9FA5]+")){
                   t2 = PinyinHelper.toHanyuPinyinStringArray(t1[i],t3);
                   if(i == (t0 - 1)){
                	   t4 += t2[0];
                   }else{
                	   t4 += t2[0] + "-";
                   }
                }else {
                   t4 += Character.toString(t1[i]);
                }
            }
            if(!Tools.processNull(t4).equals("")){
            	String[] result =  t4.split("-");
            	for(String s:result){
            		res += Character.toUpperCase(s.charAt(0)) + s.substring(1) + " ";
            	}
            }
		}catch(Exception e){
			log.error(e);
		}
		return res.trim();
	}
	/**
	 * 文件上传
	 * @return
	 */
	public Map<String,String> upLoadFile(FileTransfer fileTransfer,String fileName){
		Map<String,String> res = new HashMap<String,String>();
		res.put("status","1");
		res.put("errMsg","");
		Workbook book = null;
		try{
			try{
				if(Tools.processNull(fileTransfer.getFilename()).toLowerCase().endsWith(".xls")){
					book = new HSSFWorkbook(fileTransfer.getInputStream());
				}else if(Tools.processNull(fileTransfer.getFilename()).toLowerCase().endsWith(".xlsx")){
					book = new XSSFWorkbook(fileTransfer.getInputStream());
				}else{
					throw new CommonException("导入文件类型不正确！");
				}
			}catch(Exception e1){
				throw new CommonException("导入的文件转换失败，导入文件不是完整的EXCEL文件！");
			}
			fileName = fileTransfer.getFilename().substring(fileTransfer.getFilename().lastIndexOf(File.separatorChar) + 1);
			cardApplyService.saveImportFileApply(book,fileName,baseService.getUser(),cardApplyService.getCurrentActionLog());
			res.put("status","0");
		}catch(Exception e){
			res.put("errMsg","处理文件出现错误：" + e.getMessage());
		}
		return res;
	}
	public Map<String,String> isDownloadComplete(String flag){
		Map<String,String> map = new HashMap<String,String>();
		map.put("returnValue","");
		String returnValue = "";
		if(Tools.processNull(flag).equals("")){
			return map;
		}
		Object o = SecurityUtils.getSubject().getSession().getAttribute(flag);
		if(o != null){
			String state = (String)o;
			returnValue = state == Constants.YES_NO_YES ? "0" : Constants.YES_NO_NO;
		}else{
			returnValue = Constants.YES_NO_NO;
		}
		if(Tools.processNull(returnValue).equals(Constants.YES_NO_YES)){
			SecurityUtils.getSubject().getSession().removeAttribute(flag);
		}
		map.put("returnValue",returnValue);
		return map;
	}
	/**
	 * 制卡文件导入
	 * @return
	 */
	public Map<String,String> saveMakeCardData(FileTransfer fileTransfer,String fileName){
		Map<String,String> res = new HashMap<String,String>();
		res.put("status","1");
		res.put("errMsg","");
		try{
			fileName = fileTransfer.getFilename().substring(fileTransfer.getFilename().lastIndexOf(File.separatorChar) + 1);
			int totalNum = taskManagementService.saveImportCardData(fileName,fileTransfer.getInputStream(),taskManagementService.getUser(),taskManagementService.getCurrentActionLog());
			res.put("totalNum",totalNum + "");
			res.put("status","0");
		}catch(Exception e){
			res.put("errMsg","处理文件出现错误：" + e.getMessage());
		}
		return res;
	}

    /**
     * 金融市民卡导入申领
     * @param fileTransfer 文件对象
     * @param fileName 导入文件名称
     * @return 处理结果
     */
    public Map<String,String> uploadPersonDataFile(FileTransfer fileTransfer,String fileName) {
        Map<String,String> res = new HashMap<String,String>();
        res.put("status","1");
        res.put("errMsg","");
        try {
            if(fileTransfer == null || fileTransfer.getInputStream() == null){
                throw new CommonException("请选择需要导入的申领数据文件！");
            }
            Workbook workbook;
            try{
                if(Tools.processNull(fileTransfer.getFilename()).toLowerCase().endsWith(".xls")) {
                    workbook = new HSSFWorkbook(fileTransfer.getInputStream());
                }else if(Tools.processNull(fileTransfer.getFilename()).toLowerCase().endsWith(".xlsx")) {
                    workbook = new XSSFWorkbook(fileTransfer.getInputStream());
                }else{
                    throw new CommonException("选择的导入文件不是有效的EXCEL文件！");
                }
                TrServRec rec = cardApplyService.saveImportJrsbkApplyData(workbook,null,cardApplyService.getCurrentActionLog());
                res.put("status","0");
                res.put("errMsg","0");
            }catch(Exception e){
                throw new CommonException(e.getMessage());
            }
        }catch(Exception e){
            log.error(e);
            res.put("errMsg",e.getMessage());
        }
        return res;
    }
	/**
	 * 充值卡制卡文件导入
	 * @return
	 */
	public Map<String,String> saveRechargeCardData(FileTransfer fileTransfer, String fileName) {
		Map<String, String> res = new HashMap<String, String>();
		res.put("status", "1");
		try {
			fileName = fileTransfer.getFilename().substring(fileTransfer.getFilename().lastIndexOf(File.separatorChar) + 1);
			int totalNum = taskManagementService.saveImportRechargeCardData(fileName, fileTransfer.getInputStream(), taskManagementService.getUser(), taskManagementService.getCurrentActionLog());
			res.put("totalNum", totalNum + "");
			res.put("status", "0");
		} catch (Exception e) {
			res.put("errMsg", "处理文件出现错误：" + e.getMessage());
		}
		return res;
	}
	/**
	 * 判断应属公交类型
	 * @param cert_No 身份证号码
	 * @return
	 */
	public Map<String,String> judgeBusType(String certNo){
		Map<String,String> map = new HashMap<String, String>();
		map.put("status","0");
		String bustypes = "00";
		try{
			CardBaseinfo card=(CardBaseinfo)baseService.findOnlyRowByHql("select c from BasePersonal b,CardBaseinfo c where  c.cardState <> '9'  and  b.customerId = c.customerId  and c.busType in('10','11','20','33','21') and b.certNo = '" + certNo + "'");
			if(card != null){
				bustypes = "00";
			}else{
				Date date =  baseService.getDateBaseDate(); 
			    Date date0 = DateUtil.formatDate(DateUtil.processDateAddYear(DateUtil.formatDate(certNo.substring(6, 14),"yyyy-MM-dd"), 18)); 
		        Date date1 = DateUtil.formatDate(DateUtil.processDateAddYear(DateUtil.formatDate(certNo.substring(6, 14),"yyyy-MM-dd"), 60)); 
		        Date date2 = DateUtil.formatDate(DateUtil.processDateAddYear(DateUtil.formatDate(certNo.substring(6, 14),"yyyy-MM-dd"), 70));
		        if((date.getTime()/ (24 * 60 * 60 * 1000)-date0.getTime()/ (24 * 60 * 60 * 1000)) < 0){
		        	bustypes = "03";
				}
				if((date.getTime()/ (24 * 60 * 60 * 1000)-date1.getTime()/ (24 * 60 * 60 * 1000)) >= 0){
					bustypes = "01";
				}
				if((date.getTime()/ (24 * 60 * 60 * 1000)-date2.getTime()/ (24 * 60 * 60 * 1000)) >= 0){
					bustypes = "08";
				}
			}
		}catch(Exception e){
			
		}
		map.put("busType",bustypes);
		return map;
	}
	@SuppressWarnings({"rawtypes","unchecked"})
	public Map<String,String> saveImportFgxhCgData(FileTransfer fileTransferArr){
		Map res = new HashMap();
		res.put("status","1");
		res.put("importCount",0);
		res.put("errMsg","");
		try{
			long importCount = taskManagementService.saveImportFgxhCgData(fileTransferArr.getInputStream(),baseService.getUser(),baseService.getCurrentActionLog());
			res.put("importCount",importCount);
			res.put("status","0");
		}catch(Exception e){
			res.put("errMsg","处理文件出现错误：" + e.getMessage());
		}
		return res;
	}
	/**
	 * 批量充值导入
	 */
	public Map<String,String> uploadBatchRechargeDataFile(FileTransfer fileTransfer,String fileName,String accKind,String isAudit) {
		Map<String,String> res = new HashMap<String,String>();
		res.put("status","1");
		res.put("errMsg","");
		try {
			if(fileTransfer == null || fileTransfer.getInputStream() == null){
				throw new CommonException("请选择需要导入的申领数据文件！");
			}
			if(Tools.processNull(accKind).equals("")){
                throw new CommonException("充值账户类型不正确！");
            }
			Workbook workbook;
			try{
				if(Tools.processNull(fileTransfer.getFilename()).toLowerCase().endsWith(".xls")) {
					workbook = new HSSFWorkbook(fileTransfer.getInputStream());
				}else if(Tools.processNull(fileTransfer.getFilename()).toLowerCase().endsWith(".xlsx")) {
					workbook = new XSSFWorkbook(fileTransfer.getInputStream());
				}else{
					throw new CommonException("选择的导入文件不是有效的EXCEL文件！");
				}
				TrServRec rec = rechargeService.saveImportBatchRechargeData(workbook,accKind,isAudit,null,cardApplyService.getCurrentActionLog());
				res.put("status","0");
				res.put("errMsg","");
			}catch(Exception e){
				throw new CommonException(e.getMessage());
			}
		}catch(Exception e){
			log.error(e);
			res.put("errMsg",e.getMessage());
		}
		return res;
	}
	public BaseService getBaseService(){
		return baseService;
	}
	public void setBaseService(BaseService baseService){
		this.baseService = baseService;
	}
	/**
	 * @return the cardApplyService
	 */
	public CardApplyService getCardApplyService() {
		return cardApplyService;
	}
	/**
	 * @param cardApplyService the cardApplyService to set
	 */
	public void setCardApplyService(CardApplyService cardApplyService) {
		this.cardApplyService = cardApplyService;
	}
	/**
	 * @return the taskManagementService
	 */
	public TaskManagementService getTaskManagementService() {
		return taskManagementService;
	}
	/**
	 * @param taskManagementService the taskManagementService to set
	 */
	public void setTaskManagementService(TaskManagementService taskManagementService) {
		this.taskManagementService = taskManagementService;
	}
    public RechargeService getRechargeService(){
        return rechargeService;
    }
    public void setRechargeService(RechargeService rechargeService){
        this.rechargeService = rechargeService;
    }
}
