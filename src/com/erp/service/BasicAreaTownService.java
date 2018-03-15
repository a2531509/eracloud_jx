/**   
* @Title: BaseService.java TODO:
* @Package com.erp.service
* @Description: TODO
* @author chenguang 
* @date 2015-4-1 下午03:18:05
* @version V1.0   
*/
package com.erp.service;

import java.util.List;

import com.erp.model.BaseTown;

/**
 * 类功能说明 TODO:乡镇街道代码表service
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
public interface BasicAreaTownService
{
	
	 List<BaseTown> findBasicAreaTownAll();
	 List<BaseTown> findBasicAreaTownByTownId(String townId);
}
