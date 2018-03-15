package com.erp.serviceImpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.dao.PublicDao;
import com.erp.model.BaseRegion;
import com.erp.service.BasicAreaRegionService;
@Service("basicAreaRegionService")
public class BasicAreaRegionServiceImpl implements BasicAreaRegionService {
	
	private PublicDao<BaseRegion> publicDao;
	private PublicDao publicDaoSQL;
	
	@Autowired
	public void setPublicDao(PublicDao<BaseRegion> publicDao )
	{
		this.publicDao = publicDao;
	}
	@Autowired
	public void setPublicDaoSQL(PublicDao publicDaoSQL )
	{
		this.publicDaoSQL = publicDaoSQL;
	}
	public List<BaseRegion> findBasicAreaRegionAll() {
		String hql="from BaseRegion u where 1=1 ";
		List<BaseRegion> list = publicDao.find(hql);
		return list;
	}
	public List<BaseRegion> findBasicAreaRegionByRegionId(String regionId) {
		String hql="from BaseRegion u where u.regionId ='"+regionId+"'";
		List<BaseRegion> list = publicDao.find(hql);
		return list;
	}

}
