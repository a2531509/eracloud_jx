package com.erp.service;

import java.util.List;

import com.erp.model.BaseCity;
import com.erp.model.BaseComm;
import com.erp.model.BaseRegion;
import com.erp.model.BaseTown;
import com.erp.serviceImpl.BaseServiceImpl;


/**
* 类功能说明 TODO:城市区域街道service接口
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
public interface CityRegionTownService extends BaseService {
	
	List<BaseCity> findAllCity();
	List<BaseRegion> findAllRegionByCity(String cityId);
	List<BaseTown> findAllTownByRegion(String regionId);
	List<BaseComm> findAllCommByTown(String TownId);
	List<BaseCity> findBasicAreaCityByCityId(String cityId);
	List<BaseRegion>  findBasicAreaRegionByRegionId(String regionId);
	List<BaseTown> findBasicAreaTownByTownId(String townId);
	

}
