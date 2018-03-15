package com.erp.listener;



import net.sf.ehcache.CacheManager;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.cache.ehcache.EhCacheManager;
import org.apache.shiro.session.Session;
import org.apache.shiro.session.SessionListener;

public class SessionHandler implements SessionListener
{

	public void onStart(Session session )
	{
		// TODO Auto-generated method stub
		
	}

	public void onStop(Session session )
	{
		
		//CacheManager.getInstance().clearAll();
	//	Cache sdf2 = CacheManager.getInstance().getCache("shiro.authorizationCache");
		// sdf2.removeAll();
		//EhCacheManager = new EhCacheManager();
//		CacheManager sdf=CacheManager.getInstance();
//		sdf.getCache("shiro-activeSessionCache");
//		sdf.getCache("shiro.authorizationCache");
//		sdf.getCache("shiro-kickout-session");
//		sdf.clearAll();
//		session.stop();
//		SecurityUtils.getSubject().logout();         
		
	}

	public void onExpiration(Session session )
	{
		// TODO Auto-generated method stub
		
	}

}
