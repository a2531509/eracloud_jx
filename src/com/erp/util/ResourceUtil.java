package com.erp.util;

import java.util.ResourceBundle;
/**
 * 类功能说明 TODO: 项目参数工具类
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
public class ResourceUtil {

	private static final ResourceBundle bundle = java.util.ResourceBundle.getBundle("config");
	private static final ResourceBundle sysconfig = java.util.ResourceBundle.getBundle("sysconfig");
	

	/**
	 * 获得sessionInfo名字
	 * 
	 * @return
	 */
	public static final String getSessionInfoName() {
		return bundle.getString("sessionInfoName");
	}

	/**
	 * 获得上传表单域的名称
	 * 
	 * @return
	 */
	public static final String getUploadFieldName() {
		return bundle.getString("uploadFieldName");
	}

	/**
	 * 获得上传文件的最大大小限制
	 * 
	 * @return
	 */
	public static final long getUploadFileMaxSize() {
		return Long.valueOf(bundle.getString("uploadFileMaxSize"));
	}

	/**
	 * 获得允许上传文件的扩展名
	 * 
	 * @return
	 */
	public static final String getUploadFileExts() {
		return bundle.getString("uploadFileExts");
	}

	/**
	 * 获得上传文件要放到那个目录
	 * 
	 * @return
	 */
	public static final String getUploadDirectory() {
		return bundle.getString("uploadDirectory");
	}
	
	
	public static final String getWebServicePath() {
		return sysconfig.getString("app_webserivce_path");
	}
	
	public static final String getwebWebServicePath(){
		return sysconfig.getString("web_webservice_path");
	}
	
	public static final String getQmWebservicePath() {
		return sysconfig.getString("qm_webserivce_path");
	}
	
	public static final String getJfbHttpInterfacePath() {
		return sysconfig.getString("jfb_http_interface_path");
	}

	public static String getDownloadDirPath() {
		return sysconfig.getString("download_dir_path");
	}
	
	public static final String getStInterfaceIP() {
		return sysconfig.getString("st_interface_ip");
	}
	
	public static final String getStInterfaceIPPort() {
		return sysconfig.getString("st_interface_ip_port");
	}
}
