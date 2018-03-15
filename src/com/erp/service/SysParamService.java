package com.erp.service;

import com.erp.exception.CommonException;
import com.erp.model.CardConfig;
import com.erp.model.SysActionLog;


/**
 * 类功能说明 TODO:科目表service
 * 类修改者	修改日期
 * 修改说明
 * <p>Title: BaseService.java</p>
 * <p>Description:杰斯科技</p>
 * <p>Copyright: Copyright (c) 2012</p>
 * <p>Company:杰斯科技</p>
 * @author hujc 631410114@qq.com
 * @date 2015-4-1 下午03:18:05
 * @version V1.0
 */
public interface SysParamService extends BaseService{
	
	public void saveItem(SysActionLog log ,String item_id ,String item_name) throws CommonException;
	
	public void saveCardConfig(SysActionLog log ,CardConfig config,String editOrAdd)throws CommonException;
	
	public void saveErrPwdPara(SysActionLog log ,String servPwderr,String loginPwdErr,String tradePwdErr)throws CommonException;

}
