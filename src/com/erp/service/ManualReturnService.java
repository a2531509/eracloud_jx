package com.erp.service;

import java.sql.ResultSet;

import com.erp.exception.CommonException;
import com.erp.model.AccAdjustbytradHandle;
import com.erp.model.CardBaseinfo;

/**
 * 手工退货业务接口。
 * 
 * @author 钱佳明。
 * @date 2016-03-14。
 *
 */
public interface ManualReturnService {

	public void saveManualReturn(CardBaseinfo cardBaseinfo, String returnAmount, String clearingDate, ResultSet resultSet) throws CommonException;

	public void saveManaulReturnExecute(AccAdjustbytradHandle accAdjustbytradHandle) throws CommonException;

	public void deleteManaulReturnInfo(AccAdjustbytradHandle accAdjustbytradHandle);

}
