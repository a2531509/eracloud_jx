package com.erp.service;

import java.util.List;


import com.erp.model.BaseCity;

/**
* 类功能说明 TODO:城市代码service接口
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
public interface BasicAreaCityService {
	
	List<BaseCity> findBasicAreaCityAll();
	List<BaseCity> findBasicAreaCityByCityId(String cityId);

}
