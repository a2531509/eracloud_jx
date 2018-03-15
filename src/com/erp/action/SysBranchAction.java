package com.erp.action;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import javax.annotation.Resource;

import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Namespace;
import org.springframework.beans.factory.annotation.Autowired;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.SysBranch;
import com.erp.service.CardIssuseService;
import com.erp.service.SysBranchService;
import com.erp.util.Constants;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.Json;
import com.erp.viewModel.Page;
import com.opensymphony.xwork2.ModelDriven;

/**
* 类功能说明 TODO:组织action
* 类修改者
* 修改日期
* 修改说明
* <p>Title: SysBranchAction.java</p>
* <p>Description:杰斯科技</p>
* <p>Copyright: Copyright (c) 2006</p>
* <p>Company:杰斯科技有限公司</p>
* @author hujc 631410114@qq.com
* @date 2013-5-29 上午11:20:45
* @version V1.0
*/

@Namespace("/orgz")
@Action(value = "SysBranchAction")
public class SysBranchAction extends BaseAction implements ModelDriven<SysBranch>{
	private static final long serialVersionUID = -4604242185439314975L;
	private SysBranchService SysBranchService;
	@Resource
	private CardIssuseService cardIssuseService;
	private Integer id;
	private SysBranch SysBranch;
	private String brchId;
	private List<String> bankIds = new ArrayList<String>();
	private String reqData;
	
	public Integer getId()
	{
		return id;
	}

	public void setId(Integer id )
	{
		this.id = id;
	}

	public SysBranch getSysBranch()
	{
		return SysBranch;
	}

	public void setSysBranch(SysBranch SysBranch )
	{
		this.SysBranch = SysBranch;
	}

	@Autowired
	public void setSysBranchService(SysBranchService SysBranchService )
	{
		this.SysBranchService = SysBranchService;
	}
	
	
	
	public String getBrchId() {
		return brchId;
	}

	public void setBrchId(String brchId) {
		this.brchId = brchId;
	}

	/**  
	* 函数功能说明 TODO:查询所有组织
	* hujc修改者名字
	* 2013-5-29修改日期
	* 修改内容
	* @Title: findSysBranchList 
	* @Description: 
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws Exception
	*/
	public String findSysBranchList() throws Exception
	{
		OutputJson(SysBranchService.findSysBranchList());
		return null;
	}
	
	/**  
	* 函数功能说明 TODO:按节点查询所有组织
	* hujc修改者名字
	* 2013-6-14修改日期
	* 修改内容
	* @Title: findSysBranchListTreeGrid 
	* @Description: 
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String findSysBranchListTreeGrid() throws Exception
	{
		OutputJson(SysBranchService.findSysBranchList(id));
		return null;
	}
	
	/**  
	* 函数功能说明 TODO:持久化组织
	* hujc修改者名字
	* 2013-6-14修改日期
	* 修改内容
	* @Title: persistenceSysBranch 
	* @Description: 
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String persistenceSysBranch() throws Exception{
		Json json = new Json();
		String f = "0";
		try {
			SysBranch brch = getModel();
			BigDecimal bg = (BigDecimal)SysBranchService.findOnlyFieldBySql("select count(1) from Sys_Branch where brch_id = '" + Tools.processNull(brch.getBrchId()) + "'");
			if(Tools.processNull(brch.getSysBranchId()).equals("")){
				if(bg.intValue() > 0){
					throw new CommonException("已经存在相同的网点编号，不可以重复添加，请重新输入网点编号！");
				}
			}else{
				if(bg.intValue() <= 0){
					throw new CommonException("根据网点编号找不到网点信息，不能进行编辑！");
				}
				f = "1";
			}
			if(!Tools.processNull(brch.getPid()).equals("")){
				SysBranch superbrch = (SysBranch)SysBranchService.findOnlyRowByHql("from SysBranch where brchId = '" + brch.getPid() + "'");
				if(superbrch == null ){
					throw new CommonException("上层网点信息不存在，请重新进行选择！");
				}
				if(Tools.processNull(brch.getBrchId()).equals(Tools.processNull(superbrch.getBrchId()))){
					throw new CommonException("上层网点和网点编号不能相同");
				}
				brch.setPid(superbrch.getSysBranchId());
			}
			if(Tools.processNull(brch.getAssistantManager()).equals("1")){
				brch.setPid(null);
			}
			SysBranchService.persistenceSysBranch(brch,bankIds);
			json.setStatus(true);
			if(Tools.processNull(f).equals("0")){
				json.setMessage("网点新增成功！");
			}else{
				json.setMessage("网点编辑成功！");
			}
		}catch(Exception e){
			json.setStatus(false);
			json.setMessage("保存网点信息出现错误，" + e.getMessage());
			this.saveErrLog(e);
		}
		OutputJson(json, Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	
	/**  
	* 函数功能说明 TODO:删除SysBranch
	* hujc修改者名字
	* 2013-6-14修改日期
	* 修改内容
	* @Title: delSysBranch 
	* @Description: 
	* @param @return
	* @param @throws Exception    设定文件 
	* @return String    返回类型 
	* @throws 
	*/
	public String delSysBranch() throws Exception{
		Json json = new Json();
		try{
			if(SysBranchService.delSysBranch(id)){
				json.setStatus(true);
				json.setMessage(Constants.POST_DATA_SUCCESS);
			}else {
				json.setMessage("注销网点出现错误，" + Constants.IS_EXT_SUBMENU);
			}
		}catch(Exception e){
			json.setStatus(false);
			json.setMessage(e.getMessage());
			this.saveErrLog(e);
		}
		OutputJson(json);
		return null;
	}
	/**
	 * 函数功能说明 TODO:网点商户开户
	 * hujc修改者名字
	 * 2013-6-14修改日期
	 * 修改内容
	 * @Title: openBrchAcc 
	 * @return String    返回类型 
	 * @throws 
	 */
	public String openBrchAcc(){
		try {
			brchId = (String)ServletActionContext.getRequest().getAttribute("brchId");
			SysActionLog action_Log = baseService.getCurrentActionLog();
			action_Log.setDealCode(DealCode.BRCH_OPEN_ACC);
			action_Log.setMessage(SysBranchService.findTrCodeNameByCodeType(action_Log.getDealCode()));
			//网点账户开户
			SysBranchService.saveopenBranchAcc(action_Log,(SysBranch)SysBranchService.findOnlyRowByHql("from  SysBranch where brchId='"+brchId+"'"));	
			Json json =new Json();
			json.setStatus(true);
			json.setTitle("提示信息");
			json.setMessage("开户成功");
			OutputJson(json, Constants.TEXT_TYPE_PLAIN);
		} catch (Exception e) {
			this.saveErrLog(e);
			Json json =new Json();
			json.setStatus(false);
			json.setTitle("提示信息");
			json.setMessage("错误信息："+e.getMessage());
			OutputJson(json, Constants.TEXT_TYPE_PLAIN);
		}
		return null;
	}
	
	// get branch banks
	public String getBranchBanks() {
		try {
			if (Tools.processNull(reqData).equals("")) {
				throw new CommonException("网点编号为空.");
			}

			String sql = "select * from branch_bank where brch_id = '" + reqData + "'";

			Page data = SysBranchService.pagingQuery(sql, page, 100);

			if (data == null || data.getAllRs() == null || data.getAllRs().isEmpty()) {
				throw new CommonException("没有数据.");
			}
			jsonObject.put("status", "0");
			jsonObject.put("data", data.getAllRs());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	// get branch banks
	public String getPidSysBranch() {
		try {
			if (Tools.processNull(reqData).equals("")) {
				throw new CommonException("网点编号为空.");
			}

			String sql = "select * from sys_branch where SYSBRANCH_ID = '" + reqData + "'";
			Page data = SysBranchService.pagingQuery(sql, page, 100);
			if (data == null || data.getAllRs() == null || data.getAllRs().isEmpty()) {
				throw new CommonException("没有数据.");
			}
			jsonObject.put("status", "0");
			jsonObject.put("data", data.getAllRs());
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public SysBranch getModel()
	{
		if(null==SysBranch){
			SysBranch=new SysBranch();
		}
		return SysBranch;
	}

	public List<String> getBankIds() {
		return bankIds;
	}

	public void setBankIds(List<String> bankIds) {
		this.bankIds = bankIds;
	}

	public String getReqData() {
		return reqData;
	}

	public void setReqData(String reqData) {
		this.reqData = reqData;
	}
}
