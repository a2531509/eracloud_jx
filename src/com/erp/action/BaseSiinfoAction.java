package com.erp.action;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.BaseCorp;
import com.erp.model.BasePersonal;
import com.erp.model.BaseSiinfo;
import com.erp.model.CardBaseinfo;
import com.erp.service.BaseSiinfoService;
import com.erp.service.Switchservice;
import com.erp.util.DateUtil;
import com.erp.util.Tools;
import com.erp.viewModel.Page;

/**
 * 统筹区域信息管理，主要功能： 1.统筹区域信息查询，2.统筹区域信息修改。
 * 
 * @author 钱佳明。
 * @version 1.0。
 * @date 2015-12-04。
 *
 */
@Namespace("/baseSiinfo")
@Action(value = "baseSiinfoAction")
@Results({@Result(name="addOrEditBaseSiinfo",location="/jsp/baseSiinfoManagement/baseSiinfoManagementEdit2.jsp")})
public class BaseSiinfoAction extends BaseAction {

	private static final long serialVersionUID = 1L;
	public Logger logger = Logger.getLogger(BaseSiinfoAction.class);

	@Resource(name = "baseSiinfoService")
	private BaseSiinfoService baseSiinfoService;
	@Autowired
	private Switchservice switchservice;
	private BaseSiinfo baseSiinfo;
	private BaseCorp baseCorp;
	private String subCardNo;
	private String queryType = "1";
	private String sort;
	private String order;
	private String defaultErrorMsg;
	private String preMedWholeNo;
	private String subCardId;
	private String oldSubCardId;

	/**
	 * 获取统筹区域信息。
	 * 
	 * @return
	 */
	public String findAllBaseSiinfo() {
		try {
			initGrid();
			if (Tools.processNull(queryType).equals("0")) {
				StringBuffer sb = new StringBuffer("");
				sb.append("select s.*,to_char(s.birthday,'yyyy-mm-dd') birthday_f, (select b.region_name from base_region b where b.city_id = s.med_whole_no and rownum = 1 ) region_name, ");
				sb.append("p.corp_customer_id, (select corp_name from base_corp c where c.customer_id = p.corp_customer_id) corp_name, ");
				sb.append("(select s1.code_name from sys_code s1 where s1.code_type = 'CERT_TYPE' and s1.code_value = s.cert_type) cert_type_name, ");
				sb.append("(select s2.code_name from sys_code s2 where s2.code_type = 'SEX' and s2.code_value = s.gender ) gender_name, ");
				sb.append("to_char(tr.biz_time, 'yyyy-mm-dd hh24:mi:ss') biz_time, (select full_name from sys_branch where brch_id = tr.brch_id) brch_name, (select name from sys_users where user_id = tr.user_id) user_name ");
				sb.append(" from base_siinfo s, base_personal p, tr_serv_rec tr where s.customer_id = p.customer_id and s.reserve_18 = tr.deal_no(+) ");
				if (!Tools.processNull(baseSiinfo.getId().getPersonalId()).equals("")) {
					sb.append(" and s.personal_id = '" + baseSiinfo.getId().getPersonalId() + "'");
				}
				if (!Tools.processNull(baseCorp.getCustomerId()).equals("")) {
					sb.append(" and p.corp_customer_id = '" + baseCorp.getCustomerId() + "'");
				}
				if (!Tools.processNull(baseCorp.getCorpName()).equals("")) {
					sb.append(" and p.corp_customer_id in (select customer_id from base_corp where corp_name like '%" + baseCorp.getCorpName() + "%')");
				}
				if (!Tools.processNull(baseSiinfo.getCustomerId()).equals("")) {
					sb.append(" and s.customer_id = '" + baseSiinfo.getCustomerId()+ "'");
				}
				if (!Tools.processNull(baseSiinfo.getName()).equals("")) {
					sb.append(" and s.name like '%" + baseSiinfo.getName() + "%'");
				}
				if (!Tools.processNull(baseSiinfo.getCertType()).equals("")) {
					sb.append(" and s.cert_type = '" + baseSiinfo.getCertType() + "'");
				}
				if (!Tools.processNull(baseSiinfo.getCertNo()).equals("")) {
					sb.append(" and s.cert_no = '" + baseSiinfo.getCertNo() + "'");
				}
				if (!Tools.processNull(baseSiinfo.getBirthday()).equals("")) {
					sb.append(" and to_char(s.birthday, 'yyyy-mm-dd') = '" + DateUtil.formatDate(baseSiinfo.getBirthday(), "yyyy-MM-dd") + "'");
				}
				if (!Tools.processNull(baseSiinfo.getGender()).equals("")) {
					sb.append(" and s.gender = '" + baseSiinfo.getGender() + "'");
				}
				if (!Tools.processNull(baseSiinfo.getMedState()).equals("")) {
					sb.append(" and s.med_state = '" + baseSiinfo.getMedState() + "'");
				}
				if (!Tools.processNull(baseSiinfo.getId().getMedWholeNo()).equals("")) {
					sb.append(" and s.med_whole_no = '" + baseSiinfo.getId().getMedWholeNo() + "'");
				}
				if (!Tools.processNull(this.sort).equals("")) {
					sb.append("order by " + this.sort + " " + this.order);
				} else {
					sb.append("order by s.personal_id");
				}
				Page list = baseService.pagingQuery(sb.toString(), page, rows);
				if (list.getAllRs() != null && list.getAllRs().size() > 0) {
					jsonObject.put("rows", list.getAllRs());
					jsonObject.put("total", list.getTotalCount());
				} else {
					throw new CommonException("根据查询条件未找到对应的统筹区域信息！");
				}
			}
		} catch (Exception e) {
			jsonObject.put("status", 1);
			jsonObject.put("errMsg", e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String addOrEditBaseSiinfo() {
		try{
			if(Tools.processNull(this.queryType).equals("1")){
				if (Tools.processNull(baseSiinfo.getCustomerId()).equals("")) {
					throw new CommonException("编辑统筹区域信息发生错误：传入客户编号不能为空！" );
				}
				baseSiinfo = (BaseSiinfo) baseService.findOnlyRowByHql("from BaseSiinfo b where b.customerId = '" + baseSiinfo.getCustomerId() + "'");
				if (baseSiinfo == null) {
					throw new CommonException("编辑统筹区域信息发生错误：未找到统筹区域信息！" );
				}
			}
		}catch(Exception e){
			this.defaultErrorMsg = e.getMessage();
		}
		return "addOrEditBaseSiinfo";
	}
	
	public String saveOrUpdateBaseSiinfo() {
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			if(Tools.processNull(this.queryType).equals("1")){
				baseSiinfoService.updateMedWholeNo(baseSiinfo, null, baseService.getCurrentActionLog(), queryType);
				jsonObject.put("status","0");
				jsonObject.put("msg",(Tools.processNull(this.queryType).equals("0") ? "新增" : "编辑") + "统筹区域信息成功！");
			}
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}

	/**
	 * 获取统筹区域信息和卡信息。
	 * 
	 * @return
	 */
	public String getCardAndBaseSiinfo() {
		jsonObject.put("baseSiinfo", new BaseSiinfo());
		jsonObject.put("cardBaseinfo", new CardBaseinfo());
		try {
			if (!Tools.processNull(baseSiinfo.getCertNo()).equals("")) {
				BasePersonal tempBasePersonal = (BasePersonal) baseService
						.findOnlyRowByHql("from BasePersonal b where b.certNo = '" + baseSiinfo.getCertNo() + "'");
				if (tempBasePersonal != null) {
					BaseSiinfo tempBaseSiinfo = (BaseSiinfo) baseService.findOnlyRowByHql(
							"from BaseSiinfo b where b.customerId = '" + tempBasePersonal.getCustomerId() + "'");
					if (tempBaseSiinfo != null) {
						JSONObject o = JSONObject.parseObject(JSONObject.toJSONString(tempBaseSiinfo));
						jsonObject.put("baseSiinfo", o);
					}
				}
				if (!Tools.processNull(subCardNo).equals("")) {
					CardBaseinfo tempCardBaseinfo = (CardBaseinfo) baseService
							.findOnlyRowByHql("from CardBaseinfo c where c.subCardNo = '" + subCardNo + "'");
					if (tempCardBaseinfo != null) {
						JSONObject o = JSONObject.parseObject(JSONObject.toJSONString(tempCardBaseinfo));
						jsonObject.put("cardBaseinfo", o);
					}
				}
			}
		} catch (Exception e) {
			logger.error(e);
		}
		return "jsonObj";
	}

	public String updateMedWholeNo() {
		jsonObject.put("status", "1");
		jsonObject.put("msg", "");
		try {
			baseSiinfoService.updateMedWholeNo(baseSiinfo, null, baseService.getCurrentActionLog(), "1");
			jsonObject.put("status", "0");
			jsonObject.put("msg", "更改医疗统筹区域信息成功！");
		} catch (Exception e) {
			jsonObject.put("msg", e.getMessage());
		}
		return this.JSONOBJ;
	}

	private void initGrid() throws Exception {
		jsonObject.put("rows", new JSONArray());
		jsonObject.put("total", 0);
		jsonObject.put("status", 0);
		jsonObject.put("errMsg", "");
	}
	
	/**
	 * 获取新统筹区编码
	 * @author Yueh
	 * @return
	 */
	public String getNewBaseSiinfo(){
		try {
			//baseService.judgeRegion(baseSiinfo.getCertNo());
			BaseSiinfo newBaseSiinfo = baseSiinfoService.getNewBaseSiinfo(baseSiinfo.getCertNo(), subCardNo);
			jsonObject.put("status","0");
			jsonObject.put("baseSiinfo", newBaseSiinfo);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	/**
	 * 统筹区编码变更
	 * @author Yueh
	 */
	public String updateBaseSiinfo(){
		try {
			if(Tools.processNull(subCardId).equals("")){
				throw new CommonException("新社保卡号为空");
			}
			if(Tools.processNull(oldSubCardId).equals("")){
				throw new CommonException("旧社保卡号为空");
			}
			CardBaseinfo cardInfo = baseSiinfoService.updateBaseSiinfoMedWholeNo(baseSiinfo, subCardNo, subCardId, oldSubCardId);
			String msg = "更改医疗统筹区域信息成功！";
			try {
				switchservice.updateMedWholeNo(cardInfo.getCardNo(), oldSubCardId.substring(0, 6), subCardId.substring(0, 6));
			} catch (Exception e) {
				msg += e.getMessage();
			}
			jsonObject.put("status", "0");
			jsonObject.put("cardInfo", msg);
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return JSONOBJ;
	}
	
	//TODO 

	public BaseSiinfo getBaseSiinfo() {
		return baseSiinfo;
	}

	public void setBaseCorp(BaseCorp baseCorp) {
		this.baseCorp = baseCorp;
	}

	public BaseCorp getBaseCorp() {
		return baseCorp;
	}

	public void setBaseSiinfo(BaseSiinfo baseSiinfo) {
		this.baseSiinfo = baseSiinfo;
	}

	public String getSubCardNo() {
		return subCardNo;
	}

	public void setSubCardNo(String subCardNo) {
		this.subCardNo = subCardNo;
	}

	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}

	public String getSort() {
		return sort;
	}

	public void setSort(String sort) {
		this.sort = sort;
	}

	public String getOrder() {
		return order;
	}

	public void setOrder(String order) {
		this.order = order;
	}

	public String getDefaultErrorMsg() {
		return defaultErrorMsg;
	}

	public void setDefaultErrorMsg(String defaultErrorMsg) {
		this.defaultErrorMsg = defaultErrorMsg;
	}

	public String getPreMedWholeNo() {
		return preMedWholeNo;
	}

	public void setPreMedWholeNo(String preMedWholeNo) {
		this.preMedWholeNo = preMedWholeNo;
	}
	/**
	 * @return the subCardId
	 */
	public String getSubCardId() {
		return subCardId;
	}

	/**
	 * @param subCardId the subCardId to set
	 */
	public void setSubCardId(String subCardId) {
		this.subCardId = subCardId;
	}

	public String getOldSubCardId() {
		return oldSubCardId;
	}

	public void setOldSubCardId(String oldSubCardId) {
		this.oldSubCardId = oldSubCardId;
	}
}