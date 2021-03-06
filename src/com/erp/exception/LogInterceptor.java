package com.erp.exception;

import org.aopalliance.intercept.MethodInterceptor;

import org.aopalliance.intercept.MethodInvocation;
import org.apache.log4j.Logger;  

public class LogInterceptor implements MethodInterceptor {

		public Object invoke(MethodInvocation invocation) throws Throwable  
	    {  
	        Logger loger = Logger.getLogger(invocation.getClass());  
	  
	        loger.info("--Log By Andy Chan -----------------------------------------------------------------------------");  
	        loger.info(invocation.getMethod() + ":BEGIN!--(Andy ChanLOG)");// 方法前的操作  
	        Object obj = invocation.proceed();// 执行需要Log的方法  
	        loger.info(invocation.getMethod() + ":END!--(Andy ChanLOG)");// 方法后的操作  
	        loger.info("-------------------------------------------------------------------------------------------------");  
	  
	        return obj;  
	    }  

}
