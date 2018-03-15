package com.erp.service;

import java.util.List;
import java.util.Map;

import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.util.PageUtil;

/**
* 类功能说明 TODO:数据采集service接口
* 类修改者
* 修改日期
* 修改说明
* <p>Title: FunctionService.java</p>
* <p>Description:杰斯科技</p>
* <p>Copyright: Copyright (c) 2006</p>
* <p>Company:杰斯科技有限公司</p>
* @author hujc 631410114@qq.com
* @date 2013-5-9 下午1:46:41
* @version V1.0
*/
public interface BasicPersonService {
	
	List<BasePersonal> findPersonAllList(Map<String, Object> map, PageUtil pageUtil);
	Long getCount(Map<String, Object> map , PageUtil pageUtil);
	
	List<BasePersonal> findPersonByClientId(String clientId);
	
	
	boolean persistenceBasicPerson(BasePersonal u );
	/**
	 * 人员基本信息新增保存或是编辑保存
	 * @param bp
	 * @param rec
	 * @param log
	 * @param type
	 * @return
	 */
	@SuppressWarnings("unchecked")
	public TrServRec saveAddOrUpdateBasePersonal(BasePersonal bp, String corpName,TrServRec rec,SysActionLog log,String type) throws CommonException;
	
	void savePersonMerge(String certNo1, String certNo2, String name1, String name2, String personalId1, String personalId2, String photoCertNo);
	Object getCurrentActionLog();
}
