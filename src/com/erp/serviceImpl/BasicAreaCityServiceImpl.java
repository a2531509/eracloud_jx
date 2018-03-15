package com.erp.serviceImpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.dao.PublicDao;
import com.erp.model.BaseCity;
import com.erp.service.BasicAreaCityService;

@Service("basicAreaCityService")
public class BasicAreaCityServiceImpl implements BasicAreaCityService {
	private PublicDao<BaseCity> publicDao;
	private PublicDao publicDaoSQL;
	
	@Autowired
	public void setPublicDao(PublicDao<BaseCity> publicDao )
	{
		this.publicDao = publicDao;
	}
	@Autowired
	public void setPublicDaoSQL(PublicDao publicDaoSQL )
	{
		this.publicDaoSQL = publicDaoSQL;
	}

	public List<BaseCity> findBasicAreaCityAll() {
		String hql="from BaseCity u where 1=1 ";
		List<BaseCity> list = publicDao.find(hql);
		return list;
	}
	public List<BaseCity> findBasicAreaCityByCityId(String cityId) {
		String hql="from BaseCity u where u.cityId='"+cityId+"'";
		List<BaseCity> list = publicDao.find(hql);
		return list;
	}

}
