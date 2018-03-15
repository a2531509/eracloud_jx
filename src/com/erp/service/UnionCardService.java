package com.erp.service;

import com.erp.exception.CommonException;

/**
 * Created by Administrator on 2016/9/19.
 */
public interface UnionCardService extends BaseService{
    /**
     * 写互联互通消费文件
     * @param belongCityCode 卡属地城市代码 形如 '2144','5000','3000'
     * @param includeFlag true 包含卡属地城市代码  false 排除卡属地城市代码
     * @param clrDate 清分日期
     * @throws CommonException
     */
    public void saveUploadUnionCardFh(String belongCityCode,boolean includeFlag,String clrDate) throws CommonException;

    /**
     * 处理互联互通下发文件
     * @throws CommonException
     */
    public void saveDownLoadUnionCardFile() throws CommonException;
}
