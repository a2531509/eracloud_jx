/**
 * 
 */
package com.erp.service;

import java.io.File;
import java.util.List;
import java.util.Map;

import org.apache.poi.ss.usermodel.Workbook;

import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.CardApply;
import com.erp.model.CardApplyTask;
import com.erp.model.CardConfig;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.viewModel.Page;

/**
 * 申领action
 * @author yangn
 * @version 1.0
 * @email yn_yangning@foxmail.com
 * @date  2015-06-09
 */
public interface CardApplyService extends BaseService {
	
	/**
	 * 保存个人申领信息 
	 * @param actionLog
	 * @param person
	 * @param apply
	 * @param rec
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveOneCardApply(SysActionLog actionLog,BasePersonal person,CardApply apply,TrServRec rec) throws CommonException;
	/**
	 * 规模申领
	 * @param sql      人员信息限制性语句
	 * @param task     任务信息
	 * @param config   申领卡参数配置信息
	 * @param log      操作日志
	 * @param oper     操作柜员
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveBatchApply(StringBuffer sql,CardApplyTask task,CardConfig config,SysActionLog log,Users oper) throws CommonException;
	
	/**
	 * 个人申领信息查询
	 * @param taskId      任务编号
	 * @param applyId     申领编号
	 * @param customerId  客户I编号
	 * @param certType    证件类型
	 * @param certNo      证件号码
	 * @param beginTime   申领开始时间
	 * @param endTime     申领结束时间
	 * @param branchId    申领网点
	 * @param operId      申领柜员
	 * @return            查询数据结果 带分页
	 */
	public Page getApplyMsg(String taskId,Long applyId,String customerId,String certType,String certNo,String beginTime,String endTime,String branchId,String operId,String orderby,Integer pageNum,Integer row) throws CommonException;
	
	/**
	 * 新版申领信息查询
	 * @param para
	 * @param pageNum
	 * @param pageSize
	 * @return
	 * @throws CommonException
	 */
	public Page toSearchApplyMsg(JSONObject para,Integer pageNum,Integer pageSize) throws CommonException;
	
	/**
	 * 撤销申领信息
	 * @param actionLog
	 * @param apply_Id
	 * @return
	 * @throws CommonException
	 */
	public Long saveUndoCardApply(SysActionLog actionLog,String apply_Id) throws CommonException;
	
	/**
	 * 创建卡号
	 * @throws CommonException
	 */
	public void saveCardNoTask() throws CommonException;
	/**
	 * 插入任务明细
	 * @param task
	 * @param para
	 * @throws CommonException
	 */
	public void insertCardtasklist(CardApplyTask task,CardConfig para)throws CommonException;
	
	/**
	 * 
	 * @param bp
	 * @param filebyte
	 * @param apply
	 * @param rec
	 * @param queryType
	 * @param actionLog
	 * @return
	 * @throws CommonException
	 */
	public TrServRec saveOneCardByIdCardApply(BasePersonal bp ,byte[] filebyte ,CardApply apply,TrServRec rec,String queryType,SysActionLog actionLog ) throws CommonException;
	/**
	 * 导入申领将文件导入临时表
	 * Description <p>TODO</p>
	 * @param book     excel表格
	 * @param fileName 文件名称
	 * @param oper     操作员
	 * @param log      操作日志
	 * @return         业务日志
	 */
	public TrServRec saveImportFileApply(Workbook book,String fileName,Users oper,SysActionLog log)throws CommonException;
	/**
	 * 导入申领将文件导入临时表
	 * Description <p>TODO</p>
	 * @param file     excel表格
	 * @param fileFileName
	 * @param log      操作日志
	 * @return         业务日志
	 */
	public TrServRec saveImpApplyView(File file,String fileFileName,SysActionLog log)throws CommonException;
	/**
	 * 导入申领将文件导入临时表
	 * Description <p>TODO</p>
	 * @param card_type     操作员
	 * @param log      操作日志
	 * @return         业务日志
	 */
	public void saveImpApply(String dealno,String card_type,Users users,SysActionLog log,Object[] obj)throws CommonException;

    /**
     * 金融市民卡申领数据导入操作
     * @param file excel文件
     * @param rec 业务日志
     * @param actionLog 操作日志
     * @return 业务日志
     */
    public TrServRec saveImportJrsbkApplyData(Workbook file,TrServRec rec,SysActionLog actionLog) throws CommonException;
    /**
     * 金融市民卡申领导入人员数据删除
     * @param dealNo
     * @param oper
     * @param actionLog
     * @return
     * @throws CommonException
     * TrServRec
     */
    public TrServRec saveDelJrsbkApplyImportData(Long dealNo,Users oper,SysActionLog actionLog) throws CommonException;

	/**
	 * 金融市民卡申领导入人员数据申领
	 * @param ids
	 * @param oper
	 * @param log
	 * @param onlyAppNewCard 
	 * @param onlyAppHFCard 
	 * @return
	 * @throws CommonException
	 * TrServRec
	 */
	public Map<String,String> saveJrsbkApplyImportDataApply(String ids,Users oper,SysActionLog log, boolean onlyAppNewCard, boolean onlyAppHFCard) throws CommonException;
	
	/**
	 * 保存申领时的历史状态
	 * @param selectId
	 * @param batchNo 
	 * @param certNoList 
	 */
	public String saveAppSnap(String selectId, String batchNo, String isBatchHf, List<String> certNoList);
	
	/**
	 * 更新申领时的历史状态
	 * @param snapDealNo
	 * @param tempTask
	 */
	public void updateAppSnap(String snapDealNo, CardApplyTask tempTask);
	public SysActionLog savePrintReport(SysActionLog actionLog, Users user);
	public TrServRec saveCorpNetAppData(String corpId, String regionId, List<Map<String, String>> persons, SysActionLog log);
}
