package com.erp.serviceImpl;

import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.AccAdjustbytradHandle;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.service.DoWorkClientService;
import com.erp.service.ManualReturnService;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.StringUtils;
import com.erp.util.Tools;

/**
 * 手工退货业务接口实现。
 * 
 * @author 钱佳明。
 * @date 2016-03-14。
 *
 */
@Service("manualReturnService")
public class ManualReturnServiceImpl extends BaseServiceImpl implements ManualReturnService {
	@Autowired
	private DoWorkClientService doWorkClientService;

	@Override
	@SuppressWarnings("unchecked")
	public void saveManualReturn(CardBaseinfo cardBaseinfo, String returnAmount, String clearingDate, ResultSet resultSet) throws CommonException {
		try {
			SysActionLog sysActionLog = getCurrentActionLog();
			sysActionLog.setDealCode(DealCode.ONLINE_DATA_RETURN_HANDLE);
			sysActionLog.setNote("手工退货登记[卡类型：" + cardBaseinfo.getCardType() + ",卡号：" + cardBaseinfo.getCardNo() + "]");
			sysActionLog.setMessage(sysActionLog.getNote());
			publicDao.save(sysActionLog);

			AccAdjustbytradHandle accAdjustbytradHandle = new AccAdjustbytradHandle();
			accAdjustbytradHandle.setOldDealNo(resultSet.getString("DEAL_NO"));
			accAdjustbytradHandle.setCardType(cardBaseinfo.getCardType());
			accAdjustbytradHandle.setCardNo(cardBaseinfo.getCardNo());
			accAdjustbytradHandle.setTradAmt(returnAmount);
			accAdjustbytradHandle.setTradTime(sysActionLog.getDealTime());
			accAdjustbytradHandle.setClrDate(resultSet.getString("CLR_DATE"));
			accAdjustbytradHandle.setTradAcptId(resultSet.getString("ACPT_ID"));
			accAdjustbytradHandle.setTradBatchNo(Tools.processNull(resultSet.getString("DEAL_BATCH_NO")));
			accAdjustbytradHandle.setTradEndId(resultSet.getString("USER_ID"));
			Object object = (Object) findOnlyRowBySql("select max(end_deal_no) from acc_inout_detail_" + clearingDate + " t where t.db_card_no = '" + cardBaseinfo.getCardNo() + "'");
			Long endDealNo = Long.parseLong((String)object) + 1L;
			accAdjustbytradHandle.setTradEndDealNo(Tools.tensileString(String.valueOf(endDealNo), 10, true, "0"));
			accAdjustbytradHandle.setTradState("0");
			accAdjustbytradHandle.setTradUserId(sysActionLog.getUserId());
			publicDao.save(accAdjustbytradHandle);

			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(sysActionLog.getDealNo());
			trServRec.setDealCode(sysActionLog.getDealCode());
			trServRec.setUserId(sysActionLog.getUserId());
			trServRec.setBrchId(sysActionLog.getBrchId());
			trServRec.setBizTime(sysActionLog.getDealTime());
			trServRec.setCardType(cardBaseinfo.getCardType());
			trServRec.setCardNo(cardBaseinfo.getCardNo());
			trServRec.setNote(sysActionLog.getNote());
			publicDao.save(trServRec);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}

	@Override
	@SuppressWarnings("unchecked")
	public void saveManaulReturnExecute(AccAdjustbytradHandle accAdjustbytradHandle) throws CommonException {
		try {
			SysActionLog sysActionLog = getCurrentActionLog();
			sysActionLog.setDealCode(DealCode.ONLINE_CONSUME_RETURN);
			sysActionLog.setNote("手工退货处理[卡类型：" + accAdjustbytradHandle.getCardType() + ", 卡号：" + accAdjustbytradHandle.getCardNo() + "]");
			sysActionLog.setMessage(sysActionLog.getNote());
			publicDao.save(sysActionLog);

			StringBuffer parameters = null;
			List<Object> in = null;
			List<Object> out = null;
			List<Object> results = null;
			// 调用pk_consume.p_onlineconsumereturn_calc存储过程
			parameters = new StringBuffer();
			parameters.append(accAdjustbytradHandle.getOldDealNo() + "|"); // 消费记录的业务流水号
			parameters.append(accAdjustbytradHandle.getCardNo() + "|"); // 卡号
			parameters.append(accAdjustbytradHandle.getClrDate() + "|"); // 消费记录的清分日期
			parameters.append(accAdjustbytradHandle.getTradAmt()); // 退货金额
			in = new ArrayList<Object>();
			in.add(parameters.toString());
			out = new ArrayList<Object>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			results = publicDao.callProc("pk_consume.p_onlineconsumereturn_calc", in, out);
			if (!(results == null || results.size() == 0)) {
				int res = Integer.parseInt(results.get(0).toString());
				if (res != 0) {
					String msg = results.get(1).toString();
					throw new CommonException(msg);
				}
			} else {
				throw new CommonException("调用pk_consume.p_onlineconsumereturn_calc存储过程发生错误！");
			}
			// 调用pk_consume.p_onlineconsumereturn存储过程
			parameters = new StringBuffer();
			parameters.append(sysActionLog.getDealNo() + "|"); // 交易流水号
			parameters.append(DealCode.ONLINE_CONSUME_RETURN + "|"); // 交易代码
			parameters.append(accAdjustbytradHandle.getTradEndId() + "|"); // 终端号
			parameters.append(DateUtil.formatDate(sysActionLog.getDealTime(), "yyyy-MM-dd HH:mm:ss") + "|"); // 操作时间
			parameters.append(accAdjustbytradHandle.getTradAcptId() + "|"); // 商户编号
			parameters.append(accAdjustbytradHandle.getTradBatchNo() + "|"); // 批次号
			parameters.append(accAdjustbytradHandle.getTradEndDealNo() + "|"); // 终端交易流水号
			parameters.append(accAdjustbytradHandle.getCardNo() + "|"); // 卡号
			parameters.append(accAdjustbytradHandle.getTradAmt() + "|"); // 总交易金额
			String list = (String) results.get(2);
			String[] listArr = list.split("\\$");
			if (listArr != null && listArr.length > 3 && Constants.ACC_KIND_ZJZH.equals(listArr[0])) {
				listArr[3] = doWorkClientService.money2EncryptCal(accAdjustbytradHandle.getCardNo(), listArr[2], "0", "0");
			}
			parameters.append(StringUtils.join(listArr, "$") + "|"); // 账户列表
			parameters.append(accAdjustbytradHandle.getOldDealNo() + "|"); // 被退货的业务日志序列号
			parameters.append(accAdjustbytradHandle.getClrDate()); // 被退货记录的清分日期
			in = new ArrayList<Object>();
			in.add(parameters.toString());
			in.add(java.sql.Types.VARCHAR);
			out = new ArrayList<Object>();
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			out.add(java.sql.Types.VARCHAR);
			results = publicDao.callProc("pk_consume.p_onlineconsumereturn", in, out);
			if (!(results == null || results.size() == 0)) {
				int res = Integer.parseInt(results.get(0).toString());
				if (res != 0) {
					String msg = results.get(1).toString();
					throw new CommonException(msg);
				}
			} else {
				throw new CommonException("调用pk_consume.p_onlineconsumereturn存储过程发生错误！");
			}

			accAdjustbytradHandle.setTradState("1");
			accAdjustbytradHandle.setTradHandleUserId(sysActionLog.getUserId());
			accAdjustbytradHandle.setTradHandleTime(sysActionLog.getDealTime());
			publicDao.update(accAdjustbytradHandle);

			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(sysActionLog.getDealNo());
			trServRec.setDealCode(sysActionLog.getDealCode());
			trServRec.setUserId(sysActionLog.getUserId());
			trServRec.setBrchId(sysActionLog.getBrchId());
			trServRec.setBizTime(sysActionLog.getDealTime());
			trServRec.setCardType(accAdjustbytradHandle.getCardType());
			trServRec.setCardNo(accAdjustbytradHandle.getCardNo());
			trServRec.setNote(sysActionLog.getNote());
			publicDao.save(trServRec);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void deleteManaulReturnInfo(AccAdjustbytradHandle accAdjustbytradHandle) {
		try {
			SysActionLog sysActionLog = getCurrentActionLog();
			sysActionLog.setDealCode(DealCode.DELETE_MANUAL_RETURN_INFO);
			sysActionLog.setNote("手工退货删除[卡类型：" + accAdjustbytradHandle.getCardType() + ", 卡号：" + accAdjustbytradHandle.getCardNo() + "]");
			sysActionLog.setMessage(sysActionLog.getNote());
			publicDao.save(sysActionLog);

			accAdjustbytradHandle.setTradState("2");
			accAdjustbytradHandle.setTradHandleUserId(sysActionLog.getUserId());
			accAdjustbytradHandle.setTradHandleTime(sysActionLog.getDealTime());
			publicDao.update(accAdjustbytradHandle);

			TrServRec trServRec = new TrServRec();
			trServRec.setDealNo(sysActionLog.getDealNo());
			trServRec.setDealCode(sysActionLog.getDealCode());
			trServRec.setUserId(sysActionLog.getUserId());
			trServRec.setBrchId(sysActionLog.getBrchId());
			trServRec.setBizTime(sysActionLog.getDealTime());
			trServRec.setCardType(accAdjustbytradHandle.getCardType());
			trServRec.setCardNo(accAdjustbytradHandle.getCardNo());
			trServRec.setNote(sysActionLog.getNote());
			publicDao.save(trServRec);
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}
}
