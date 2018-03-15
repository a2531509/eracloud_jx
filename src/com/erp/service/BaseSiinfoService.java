package com.erp.service;

import java.util.List;
import java.util.Map;

import com.erp.exception.CommonException;
import com.erp.model.BaseSiinfo;
import com.erp.model.CardBaseinfo;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.util.PageUtil;

/**
 * 统筹区域信息管理接口。
 * 
 * @author 钱佳明。
 * @version 1.0。
 * @date 2015-12-02。
 *
 */
public interface BaseSiinfoService {

	public List<BaseSiinfo> findBaseSiinfoAllList(Map<String, Object> map, PageUtil pageUtil);

	public Long getCount(Map<String, Object> map, PageUtil pageUtil);

	public TrServRec updateMedWholeNo(BaseSiinfo baseSiinfo, TrServRec trServRec, SysActionLog sysActionLog,
			String type) throws CommonException;

	/**
	 * 更新社保统筹区编码:<br>
	 * 1.同步新旧卡到社保交换表(card_update);<br>
	 * 2.更新卡片信息<br>
	 * 3.返回更新后的卡片信息<br>
	 * 注:不修改社保信息, 调用后或调用前需要写卡</p>
	 * 
	 * @author Yueh
	 * 
	 * @param baseSiinfo
	 *            社保信息
	 * @throws CommonException
	 */
	CardBaseinfo updateBaseSiinfoMedWholeNo(BaseSiinfo baseSiinfo, String subCardNo, String subCardId, String oldSubCardId);

	/**
	 * 获取新的社保信息:
	 * <p>
	 * 当客户社保信息变更(注:社保自动维护)后, 通过此方法获取变更后的社保信息<br>
	 * 注:certNo(身份证号)和subCardNo(社保卡号)
	 * </p>
	 * 
	 * @param certNo
	 *            身份证号
	 * @param subCardNo
	 *            社保卡号
	 * @return
	 */
	BaseSiinfo getNewBaseSiinfo(String certNo, String subCardNo) throws CommonException ;
}
