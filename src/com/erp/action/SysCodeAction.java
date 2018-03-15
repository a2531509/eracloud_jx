package com.erp.action;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.SysCode;
import com.erp.model.SysCodeId;
import com.erp.service.SysCodeService;
import com.erp.util.Tools;
import com.erp.viewModel.Page;
import com.erp.viewModel.SysCodeView;


@Namespace("/sysCode")
@Action(value = "sysCodeAction")
@InterceptorRefs({@InterceptorRef("jsondefalut")})
@Results({@Result(name="systemCodeEditDlg",location="/jsp/systemCode/systemCodeEditDlg.jsp")})
public class SysCodeAction extends BaseAction {
	private String codeName;
	private String codeType;
	private SysCodeId id;
	private String codeValue;
	private SysCodeService sysCodeService;
	private String queryType = "1";
	private String state;
	private String certNo;
	private String sort;
	private String order;
	private SysCode sysCode = new SysCode();
	
	public SysCode getSysCode() {
		return sysCode;
	}

	public void setSysCode(SysCode sysCode) {
		this.sysCode = sysCode;
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
	public String saveSysCode(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			BigDecimal count = (BigDecimal)baseService.findOnlyFieldBySql("select count(1) from SYS_CODE t where t.code_type = '"+sysCode.getId().getCodeType()+"'  and t.code_value = '"+sysCode.getId().getCodeValue()+"'");
			if(count.intValue() >0 ){
				throw new CommonException("该数据字典已存在。");
			}
			sysCodeService.saveOrUpdateSysCode(sysCode,this.getUsers(),sysCodeService.getCurrentActionLog());
			jsonObject.put("msg", "新增数据字典成功！");
			jsonObject.put("status","0");
			}catch(Exception e){
				jsonObject.put("msg",e.getMessage());
			}
			return this.JSONOBJ;
	}
	public String editsaveSysCode(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			sysCodeService.updateSysCode(sysCode,this.getUsers(),sysCodeService.getCurrentActionLog());
			jsonObject.put("msg","编辑数据字典成功！");
			jsonObject.put("status","0");
			}catch(Exception e){
				jsonObject.put("msg",e.getMessage());
			}
			return this.JSONOBJ;
	}
	public String queryEditSysCode(){
		try{
			sysCode = (SysCode)baseService.findOnlyRowByHql("from SysCode where id.codeType = '"+this.codeType+"'  and id.codeValue = '"+this.codeValue+"'");
			if(sysCode == null){
				throw new CommonException("编辑客户信息发生错误：根据客户编号未找到客户信息！");
			}
			}catch(Exception e){
				jsonObject.put("msg",e.getMessage());
			}
			return "systemCodeEditDlg";
	}
	public String removeSysCode(){
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			sysCode = (SysCode)baseService.findOnlyRowByHql("from SysCode where id.codeType = '"+this.codeType+"'  and id.codeValue = '"+this.codeValue+"'");
			sysCodeService.deleteSysCode(sysCode,this.getUsers(),sysCodeService.getCurrentActionLog());
			jsonObject.put("msg","删除数据字典成功！");
			jsonObject.put("status","0");
			}catch(Exception e){
				jsonObject.put("msg",e.getMessage());
			}
			return this.JSONOBJ;
	}
	/**
	 * 
	 * @return
	 */
	public String findSystemCodeList(){
		jsonObject.put("rows",new JSONArray());
		jsonObject.put("status","0");
		jsonObject.put("total",0);
		jsonObject.put("errMsg","");
		try{
				StringBuffer sb = new StringBuffer();
				sb.append("select t.code_type,t.type_name,t.code_value,t.code_name,t.code_state,t.ord_no,t.field_name from SYS_CODE t where 1=1 ");
				if(!Tools.processNull(state).equals("")){
					sb.append("and  t.CODE_STATE  = '" + state + "' ");
				}
				if(!Tools.processNull(certNo).equals("")){
					sb.append("and  t.code_type  = '" + certNo + "' ");
				}
				Page list = baseService.pagingQuery(sb.toString(),page,rows);	
				if(list.getAllRs() != null && list.getAllRs().size() > 0){
					jsonObject.put("rows",list.getAllRs());
					jsonObject.put("total",list.getTotalCount());
				}else{
					throw new CommonException("根据查询条件未找到对应库存类型信息！");
				}
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	
	public String findSysCodeListByType(){
		jsonObject.put("status","0");
		jsonObject.put("msg","");
		try {
			String para1 = (String) ServletActionContext.getRequest().getAttribute("codeType");
			List<SysCode> codelist = sysCodeService.findSysCodeListByType(para1,codeValue);
			List<SysCodeView> viewList = new ArrayList<SysCodeView>();
			SysCodeView  defaultOption = new SysCodeView();
			defaultOption.setCodeValue("");
			defaultOption.setCodeName("请选择");
			viewList.add(defaultOption);
			for(int i=0;i<codelist.size();i++){
				SysCodeView  view = new SysCodeView();
				view.setCodeType(codelist.get(i).getId().getCodeType());
				view.setCodeValue(codelist.get(i).getId().getCodeValue());
				view.setCodeName(codelist.get(i).getCodeName());
				view.setTypeName(codelist.get(i).getTypeName());
				view.setOrdNo(codelist.get(i).getOrdNo().toString());
				viewList.add(view);
			}
			jsonObject.put("rows",viewList);
		} catch (Exception e) {
			jsonObject.put("status","1");
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	@Autowired
	public void setSysCodeService(SysCodeService sysCodeService) {
		this.sysCodeService = sysCodeService;
	}
	public String getCodeName() {
		return codeName;
	}
	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public void setCodeName(String codeName) {
		this.codeName = codeName;
	}
	
	public String getCodeType() {
		return codeType;
	}
	public void setCodeType(String codeType) {
		this.codeType = codeType;
	}
	public SysCodeId getId() {
		return id;
	}
	public void setId(SysCodeId id) {
		this.id = id;
	}
	public String getQueryType() {
		return queryType;
	}

	public void setQueryType(String queryType) {
		this.queryType = queryType;
	}

	public String getCodeValue() {
		return codeValue;
	}
	public void setCodeValue(String codeValue) {
		this.codeValue = codeValue;
	}
}
