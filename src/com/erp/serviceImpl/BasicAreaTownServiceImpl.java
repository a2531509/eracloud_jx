package com.erp.serviceImpl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.dao.PublicDao;
import com.erp.model.BaseTown;
import com.erp.service.BasicAreaTownService;

@Service("basicAreaTownService")
public class BasicAreaTownServiceImpl implements BasicAreaTownService {

	private PublicDao<BaseTown> publicDao;
	private PublicDao publicDaoSQL;
	
	@Autowired
	public void setPublicDao(PublicDao<BaseTown> publicDao )
	{
		this.publicDao = publicDao;
	}
	@Autowired
	public void setPublicDaoSQL(PublicDao publicDaoSQL )
	{
		this.publicDaoSQL = publicDaoSQL;
	}
	public List<BaseTown> findBasicAreaTownAll() {
		String hql="from BaseTown u where 1=1 ";
		List<BaseTown> list = publicDao.find(hql);
		return list;
	}
	public List<BaseTown> findBasicAreaTownByTownId(String townId) {
		String hql="from BaseTown u where u.townId ='"+townId+"'";
		List<BaseTown> list = publicDao.find(hql);
		return list;
	}

}
