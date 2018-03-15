package com.erp.serviceImpl;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.PointsRule;
import com.erp.model.SysActionLog;
import com.erp.model.SysCode;
import com.erp.model.SysCodeId;
import com.erp.model.TrServRec;
import com.erp.model.Users;
import com.erp.service.SysCodeService;
import com.erp.util.Constants;
import com.erp.util.DealCode;
import com.erp.util.PageUtil;
import com.erp.util.Tools;

@Service("sysCodeService")
@SuppressWarnings("unchecked")
public class SysCodeServiceImpl extends BaseServiceImpl implements
		SysCodeService {

	@Override
	public List<SysCode> findSysCodeListByTypeName(String typeName) throws CommonException {
		List<SysCode> list=null;
		try {
			list =publicDao.find("from SysCode where typeName ='" + typeName + "'");
		} catch (Exception e) {
			// TODO: handle exception
		}
		return list;
	}

	
	@Override
	public List<SysCode> findSysCodeListByType(String type,String codeValues) throws CommonException {
		List<SysCode> list=null;
		try {
			SysCodeId id = new SysCodeId();
			id.setCodeType(type);
			String hql ="from SysCode  where   codeState='0'";
			if(!Tools.processNull(type).equals("")){
				hql+=" and id.codeType='" + type + "'";
			}
			if(!Tools.processNull(codeValues).equals("")){
				hql+=" and id.codeValue in(" + codeValues + ")";
			}
			hql+="order by ordNo";
			list =publicDao.find(hql);
		} catch (Exception e) {
			// TODO: handle exception
		}
		return list;
	}

	@Override
	public SysCode findSysCodeById(SysCodeId id) {
		SysCode list=null;
		try {
			list =(SysCode)publicDao.find("from SysCode where SysCodeId='"+id+"'").get(0);
		} catch (Exception e) {
			// TODO: handle exception
		}
		return list;
	}

	@Override
	public List<SysCode> findAllCodeList(Map<String, Object> map,
			PageUtil pageUtil) throws CommonException {
		List<SysCode> list  =null;
		try {
			String hql = "from SysCode u where 1=1 ";
			hql += Constants.getSearchConditionsHQL("u", map);
			hql += Constants.getGradeSearchConditionsHQL("u", pageUtil);
			if (map.get("sortName") != null) {
				hql += " order by " + map.get("sortName") + " "
						+ map.get("orderBy");
				map.remove("sortName");
				map.remove("orderBy");
			}
			list = publicDao.find(hql, map, pageUtil.getPage(),
					pageUtil.getRows());
		} catch (Exception e) {
			throw new CommonException("查询信息出错了"+e.getMessage());
		}
		return list;
	}
	
	public void saveOrUpdateSysCode(SysCode sysCode,Users user,SysActionLog actionLog) throws CommonException{
		try {
			actionLog.setMessage("数据字典参数编辑");
//			actionLog.setDealCode(DealCode.POINT_PARA_EDIT);
			publicDao.save(actionLog);
			publicDao.save(sysCode);
			
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(Tools.processNull(user.getOrgId()));
			rec.setBrchId(user.getBrchId());
			rec.setUserId(user.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setNote(actionLog.getMessage());
		} catch (Exception e) {
			throw new CommonException("交易积分保存发生错误："+e.getMessage());
		}
	}
	
	public void UpdateSysCode(SysCode sysCode,Users user,SysActionLog actionLog) throws CommonException{
		try {
			actionLog.setMessage("数据字典参数编辑");
//			actionLog.setDealCode(DealCode.POINT_PARA_EDIT);
			publicDao.save(actionLog);
			publicDao.save(sysCode);
			
			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(Tools.processNull(user.getOrgId()));
			rec.setBrchId(user.getBrchId());
			rec.setUserId(user.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setNote(actionLog.getMessage());
		} catch (Exception e) {
			throw new CommonException("交易积分保存发生错误："+e.getMessage());
		}
	}


	public void updateSysCode(SysCode sysCode, Users user,SysActionLog actionLog) throws CommonException {
		try {
			actionLog.setMessage("数据字典参数编辑");
			// actionLog.setDealCode(DealCode.POINT_PARA_EDIT);
			publicDao.save(actionLog);
			publicDao.update(sysCode);

			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(Tools.processNull(user.getOrgId()));
			rec.setBrchId(user.getBrchId());
			rec.setUserId(user.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setNote(actionLog.getMessage());
		} catch (Exception e) {
			throw new CommonException("交易积分保存发生错误：" + e.getMessage());
		}
	}
	
	public void deleteSysCode(SysCode sysCode, Users user,SysActionLog actionLog) throws CommonException {
		try {
			actionLog.setMessage("数据字典参数编辑");
			// actionLog.setDealCode(DealCode.POINT_PARA_EDIT);
			publicDao.save(actionLog);
			publicDao.delete(sysCode);

			TrServRec rec = new TrServRec();
			rec.setDealNo(actionLog.getDealNo());
			rec.setOrgId(Tools.processNull(user.getOrgId()));
			rec.setBrchId(user.getBrchId());
			rec.setUserId(user.getUserId());
			rec.setBizTime(actionLog.getDealTime());
			rec.setNote(actionLog.getMessage());
		} catch (Exception e) {
			throw new CommonException("交易积分保存发生错误：" + e.getMessage());
		}
	}
	

}
