package com.erp.service;

import java.util.List;

import com.erp.exception.CommonException;
import com.erp.model.BasePsam;

public interface BasePsamService  extends BaseService  {

	/**
	 * 保存Psam卡信息
	 * @param basePasm
	 * @throws CommonException
	 */
	public  void  saveBasePsam(BasePsam basePsam)throws CommonException;
	
    /**
     * 删除Psam卡信息
     * @param psamNo
     * @throws CommonException
     */
	public void delBasePsam(String psamNo)throws CommonException;
	/**
	 * 修改Psam卡信息
	 * @param basePasm
	 * @throws CommonException
	 */
	public void updateBasePsam(BasePsam basePsam,String Type)throws CommonException;

	public List<BasePsam> saveBasePsam(List<BasePsam> list);

	
}
