package com.erp.interceptor;

import java.util.Map;

import org.apache.log4j.Logger;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.subject.Subject;

import com.alibaba.fastjson.JSONObject;
import com.erp.model.SysActionLog;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.Interceptor;

public class SuperInterceptor implements Interceptor{
	private static final long serialVersionUID = 1L;
	private Logger log = Logger.getLogger(SuperInterceptor.class);
	public void destroy() {  
			
	}  
	public void init() {  
	    
	}     
	public String intercept(ActionInvocation invocation) throws Exception {
		StringBuffer reqUrl = new StringBuffer();
		StringBuffer buffer = new StringBuffer();
		buffer.append("Action:" + invocation.getAction().getClass().getName() + " || ");
		buffer.append("Method:" + invocation.getProxy().getMethod() + " || ");
		String namespace = "";
		namespace = invocation.getProxy().getNamespace();
		if(!Tools.processNull(namespace).equals("") && !Tools.processNull(namespace).equals("/")){
			reqUrl.append(namespace);
		}
		String actionName = "";
		actionName = invocation.getProxy().getActionName();
		if(!Tools.processNull(actionName).equals("")){
			reqUrl.append("/");
			reqUrl.append(actionName);
		}
		String methodName = "";
		methodName = invocation.getProxy().getMethod();
		if(!Tools.processNull(methodName).equals("")){
			reqUrl.append("!");
			reqUrl.append(methodName);
		}
		reqUrl.append(".action");
		Map<String,Object> params = invocation.getInvocationContext().getParameters();  
		JSONObject jsonParams = new JSONObject();
		buffer.append("Params:");
		for(String key : params.keySet()){  
		    Object obj = params.get(key);  
		    String tempparamvalue = "";
		    if(obj instanceof String[]){  
		        String[] arr = (String[]) obj;  
				for (String value : arr){  
					tempparamvalue += value + ",";
		        }  
				tempparamvalue = tempparamvalue.substring(0,tempparamvalue.length() - 1);
		    }else{
		    	tempparamvalue = obj.toString();
		    }
		    jsonParams.put(key,tempparamvalue);
		}  
		buffer.append(jsonParams.toJSONString());
		//log.error(buffer.toString());
		if(!invocation.getAction().getClass().getName().equals("com.erp.action.LoginAction")){
			Subject subject = SecurityUtils.getSubject();
			SysActionLog log = (SysActionLog)subject.getSession().getAttribute(Constants.ACTIONLOG);
		    log.setDealNo(null);
		    log.setFuncUrl(reqUrl.toString());
		    log.setInOutData(buffer.toString());
		    log.setIp(Constants.getIpAddr());
		    log.setMessage("");
		    log.setNote("");
		    subject.getSession().setAttribute(Constants.ACTIONLOG, log);
		} 
		String resultCode = invocation.invoke();  
		//在Action和Result运行之后，得到Result对象  并且可以强制转换成ServletDispatcherResult，打印其下一个JSP的位置  
	   /* Result rresult = invocation.getResult();  
		if (rresult instanceof ServletDispatcherResult){  
		    ServletDispatcherResult result = (ServletDispatcherResult) rresult;  
		    System.out.println("JSP:"+result.getLastFinalLocation());  
		    buffer.append("JSP:"+result.getLastFinalLocation());
		}  */
		return resultCode;  
	}
	public Logger getLog() {
		return log;
	}
	public void setLog(Logger log) {
		this.log = log;
	}  
}
