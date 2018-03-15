package com.erp.util;

import java.lang.reflect.InvocationTargetException;
import java.util.Map;

import org.apache.commons.beanutils.BeanUtils;

/**
 * 类功能说明 TODO:
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
public class HqlUtil {
	public static boolean paramNotNull(Object[] param){
		
		return true;
	}
	
	public static Object assemble(Map<String, Object> objs, Class<?> targetClass) throws IllegalAccessException, InvocationTargetException, InstantiationException {  
	       if (null == objs) {  
	           return null;  
	       }  
	       Object target = targetClass.newInstance();  
	       if (target != null) {  
	           for(Map.Entry<String, Object> e : objs.entrySet()) {  
	               BeanUtils.copyProperty(target, e.getKey(), e.getValue());  
	           }  
	       }  
	       return target;  
	}  

}
