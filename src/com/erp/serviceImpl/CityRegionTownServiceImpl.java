package com.erp.serviceImpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.dao.PublicDao;
import com.erp.model.BaseCity;
import com.erp.model.BaseComm;
import com.erp.model.BaseRegion;
import com.erp.model.BaseTown;
import com.erp.service.CityRegionTownService;

@Service("cityRegionTownService")
public class CityRegionTownServiceImpl extends BaseServiceImpl implements CityRegionTownService {

	private PublicDao<BaseCity> publicDao_city;
	@Autowired
	public void setPublicDao_city(PublicDao<BaseCity> publicDao_city )
	{
		this.publicDao_city = publicDao_city;
	}
	private PublicDao<BaseRegion> publicDao_region;
	@Autowired
	public void setPublicDao_region(PublicDao<BaseRegion> publicDao_region )
	{
		this.publicDao_region = publicDao_region;
	}
	private PublicDao<BaseTown> publicDao_town;
	@Autowired
	public void setPublicDao_town(PublicDao<BaseTown> publicDao_town )
	{
		this.publicDao_town = publicDao_town;
	}
	
	public List<BaseCity> findAllCity() {
		String hql="from BaseCity t where t.cityType='2' ";
		List<BaseCity> list = publicDao_city.find(hql);
		return list;
	}

	public List<BaseRegion> findAllRegionByCity(String cityId) {
		String hql="from BaseRegion t where t.regionState='0' and t.cityId='"+cityId+"'";
		List<BaseRegion> list = publicDao_region.find(hql);
		return list;
	}

	public List<BaseTown> findAllTownByRegion(String regionId) {
		String hql="from BaseTown t where t.townState='0' and t.regionId='"+regionId+"'";
		List<BaseTown> list = publicDao_town.find(hql);
		return list;
	}

	public List<BaseCity> findBasicAreaCityByCityId(String cityId) {
		String hql="from BaseCity u where u.cityId='"+cityId+"'";
		List<BaseCity> list = publicDao_city.find(hql);
		return list;
	}

	public List<BaseRegion> findBasicAreaRegionByRegionId(String regionId) {
		String hql="";
		if(regionId==null||"".equals(regionId)){
			hql="from BaseRegion u where 1=1";
		}else{
			hql="from BaseRegion u where u.regionId ='"+regionId+"'";
		}
		List<BaseRegion> list = publicDao_region.find(hql);
		return list;
	}

	public List<BaseTown> findBasicAreaTownByTownId(String townId) {
		String hql="";
		if(townId==null||"".equals(townId)){
			hql="from BaseTown u where 1=1 ";
		}else{
			hql="from BaseTown u where u.townId ='"+townId+"'";
		}
		List<BaseTown> list = publicDao_town.find(hql);
		return list;
	}

	@Override
	public List<BaseComm> findAllCommByTown(String TownId) {
		String hql="";
		if(TownId==null||"".equals(TownId)){
			hql="from BaseComm u where 1=1";
		}else{
			hql="from BaseComm u where u.townId ='"+TownId+"'";
		}
		List<BaseComm> list = publicDao.find(hql);
		return list;
	}

}
