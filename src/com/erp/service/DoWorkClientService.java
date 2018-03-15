package com.erp.service;

import java.util.List;
import java.util.Map;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.viewModel.ZxcModel;

public interface DoWorkClientService {
	
	/**
	 * 
	 * @param cardNo 卡号
	 * @param mwpwd  密码明文
	 * @return
	 * @throws CommonException
	 */
	public String encrypt_MwPwd(String cardNo,String mwpwd)  throws CommonException;

	/**
	 * 将键盘的pin密码加密成后台存储的密码
	 * @param cardNo   卡号
	 * @param pinPwd   密码键盘读取的pin密码
	 * @return         如果加密成功,则返回加密后的密码密文
	 * @throws CommonException 如果加密过程中出现错误,则抛出CommonException异常
	 */
	public String encrypt_PinPwd(String cardNo, String pinPwd)
			throws CommonException;

	/**
	 * 金额加密
	 * @param cardNo   卡号
	 * @param minutes  金额(分)
	 * @return  加密后的金额密文
	 */
	public JSONObject encrypt_Money(String cardNo,Long minutes);

	/**
	 * 调取汤伟忠统一接口
	 * @param code   交易代码
	 * @param list   参数信息 xml节点和节点属性
	 * @return       结果集
	 * @throws CommonException
	 */
	public List<Map<String, String>> doWork(String code,List<Map<String, String>> list) throws CommonException;
	/**
	 * 验证消费数据的TAC
	 * @param fileName
	 * @param data
	 * @return
	 * @throws CommonException
	 */
	public JSONArray checkTacByFileName(String fileName,String data) throws CommonException;
	
	public String money2EncryptCal(String cardno,String encrymoney,String amt,String op) throws CommonException;
	/**
	 * json转换
	 * @param inParameter
	 * @return
	 * @throws CommonException
	 */
	public JSONArray invoke(JSONArray inParameter) throws CommonException;
    /**
     * 自行车应用
     * @param personal
     * @param zxcModel
     * @param trcode
     * @return
     * @throws CommonException
     */
	public JSONArray saveZxc(BasePersonal personal,ZxcModel zxcModel,String trcode) throws CommonException;
	
	/**
	 * 获取主密钥
	 * @param bizid
	 * @return
	 * @throws CommonException
	 */
	public JSONArray getPosMainKey(String bizid)throws CommonException;
	/**
	 * 获取工作密钥
	 * @param bizid
	 * @return
	 * @throws CommonException
	 */
	public JSONArray getPosWorkKey(String bizid,String endid)throws CommonException;
	
	/**
	 * 获取充值卡密码
	 * @param cardno
	 * @param length
	 * @return
	 * @throws CommonException
	 */
	public JSONArray getRechargeCardPwd(String cardno, int length) throws CommonException;
	
	/**
	 * json转换
	 * @param inParameter
	 * @return
	 * @throws CommonException
	 */
	public JSONArray invoke_Outer(JSONArray inParameter) throws CommonException;

}