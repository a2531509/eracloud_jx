package com.erp.service;

import java.io.File;
import java.util.List;

import com.erp.exception.CommonException;
import com.erp.model.BasePhoto;
import com.erp.model.SysActionLog;

public interface BasicPhotoService extends BaseService{
	
	List<BasePhoto>  findPhotoByClientId(String clientId);
	boolean persistenceBasicPhoto(BasePhoto photo,byte[] filebyte,SysActionLog actionLog);
	
	Integer deleteBasicPhotoByClientId(String clientId);

	/**
	 * 批量导入照片
	 */
	public void saveImportPhoto(File zipFile, String uploadType, SysActionLog actionLog) throws CommonException;

}
