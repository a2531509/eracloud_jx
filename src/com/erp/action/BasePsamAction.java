package com.erp.action;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;

import com.alibaba.fastjson.JSONArray;
import com.erp.exception.CommonException;
import com.erp.model.BasePsam;
import com.erp.model.BaseTagEnd;
import com.erp.service.BasePsamService;
import com.erp.util.Constants;
import com.erp.util.ExcelUtil;
import com.erp.util.Tools;
import com.erp.viewModel.Json;
import com.erp.viewModel.Page;
@SuppressWarnings("serial")
@Namespace("/BasePsam")
@Action(value = "basePsamAction")
@Results({@Result(type="json",name="json"),
			@Result(name="toAddBasePsam",location="/jsp/basePsam/basePsamAdd.jsp"),
			@Result(name="toEditBasePsam",location="/jsp/basePsam/basePsamAdd.jsp"),
			@Result(name="toReceivePsam",location="/jsp/basePsam/receivePsam.jsp"),
			@Result(name="toCanclePsam",location="/jsp/basePsam/canclePsam.jsp")
			})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class BasePsamAction extends BaseAction{
	private BasePsamService basePsamService;
	private BasePsam basePsam=new BasePsam();
	private String psamState="";
	private String psamNo;
	private String psamId;
	private String psamRreceive;
	private String psamRreceiveDate;
	private String cancleReason;
	private File file;
	private String expid;
	private String psamNos;


	/**
	 * 跳转到新增页面
	 * @return
	 */
	public String toAddBasePsam(){
		
		try {
			basePsam = new BasePsam();
		} catch (Exception e) {
		    this.saveErrLog(e);
		}
		return "toAddBasePsam";
	}
	
	/**
	 * 跳转到编辑页面
	 * @return
	 */
	
	public String toEditBasePsam(){
		try {
			
			basePsam = (BasePsam)basePsamService.findOnlyRowByHql("from BasePsam where psamNo ='"+psamNo+"'");
			
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toEditBasePsam";
	}
	/**
	 * 跳转到领用页面
	 * @return
	 */
	
	public String toReceivePsam(){
		try {
			
			basePsam = (BasePsam)basePsamService.findOnlyRowByHql("from BasePsam where psamNo ='"+psamNo+"'");
			
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toReceivePsam";
	}
	/**
	 * 跳转到领用页面
	 * @return
	 */
	
	public String toCanclePsam(){
		try {
			
			basePsam = (BasePsam)basePsamService.findOnlyRowByHql("from BasePsam where psamNo ='"+psamNo+"'");
			
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toCanclePsam";
	}
	/**
	 * 保存新增数据
	 */
	public void saveBasePsam(){
		Json json = new Json();
		try {  
			Object psamN= basePsamService.findOnlyRowByHql("from BasePsam where psamNo ='"+basePsam.getPsamNo()+"'");
               if(!Tools.processNull(psamN).equals("")){
            		BasePsam basePsamVo = (BasePsam)basePsamService.findOnlyRowByHql("from BasePsam where psamNo ='"+basePsam.getPsamNo()+"'");
        			basePsam.setPsamRreceive(basePsamVo.getPsamRreceive());
        			basePsam.setPsamRreceiveDate(basePsamVo.getPsamRreceiveDate());
        			basePsam.setReceiveTime(basePsamVo.getReceiveTime());
        			basePsam.setReceiveUserId(basePsamVo.getReceiveUserId());
        			basePsam.setCancleUserId(basePsamVo.getCancleUserId());
        			basePsam.setCancleDate(basePsamVo.getCancleDate());
        			basePsam.setCancleReason(basePsamVo.getCancleReason());
            	   basePsamService.updateBasePsam(basePsam,"0");      	            	             	   
               }else{           	             	 
            	   basePsamService.saveBasePsam(basePsam);
               }
			json.setStatus(true);
			json.setTitle("成功提示");
			json.setMessage("PSAM卡信息保存成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
	}
	/**
	 * 更新PSAM领用信息
	 */
	public void updateReceivePsam(){
		Json json = new Json();
		try {  
			psamRreceive = basePsam.getPsamRreceive();
			psamRreceiveDate = basePsam.getPsamRreceiveDate();
			basePsam = (BasePsam)basePsamService.findOnlyRowByHql("from BasePsam where psamNo ='"+basePsam.getPsamNo()+"'");
			basePsam.setPsamRreceive(psamRreceive);
			basePsam.setPsamRreceiveDate(psamRreceiveDate);
            basePsamService.updateBasePsam(basePsam,"2");      	            	             	   
			json.setStatus(true);
			json.setTitle("成功提示");
			json.setMessage("PSAM卡领用成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
	}
	
	/**
	 *注销PSAM卡
	 */
	public void updateCanclePsam(){
		Json json = new Json();
		try {  
			cancleReason = basePsam.getCancleReason();
			basePsam = (BasePsam)basePsamService.findOnlyRowByHql("from BasePsam where psamNo ='"+basePsam.getPsamNo()+"'");
			basePsam.setCancleReason(cancleReason);
            basePsamService.updateBasePsam(basePsam,"1");      	            	             	   
			json.setStatus(true);
			json.setTitle("成功提示");
			json.setMessage("PSAM卡注销成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
	}
	/**
	 * 查询psam卡信息
	 */
	public String queryBasePsam(){
		try{
		    clearGrid();
			String sql="select t.psam_no,t.psam_id,t.psam_end_no,t.psam_issuse_date,"
					+ "t.psam_valid_date,t.psam_use,"
					+ "(select s.code_name from sys_code s where s.code_type='PSAM_STATE' "
					+ "and s.code_value=t.psam_state) as psam_state ,"
					+ "t.psam_brand,t.psam_manufacturer, "
					+ "to_char(t.oper_date,'yyyy-MM-dd hh24:mi:ss') as oper_date,"
					+ "t.oper_id,t.provider_id,t.note,t.psam_receive,"
					+ "t.psam_receive_date,to_char(t.receive_time,'yyyy-MM-dd hh24:mi:ss') as receive_time,"
					+ "t.receive_userid,t.cancel_userid,"
					+ "to_char(t.cancel_date,'yyyy-MM-dd hh24:mi:ss') as cancel_date,"
					+ "t.cancel_reason,t.psam_type from BASE_PASM t where 1=1.";
			if(!Tools.processNull(psamNo).equals("")){
				sql+="and t.psam_no='"+this.psamNo+"'";
			}
			if(!Tools.processNull(psamId).equals("")){
				sql+="and t.psam_id='"+this.psamId+"'";
			}
			if(!Tools.processNull(psamState).equals("")){
				sql+="and t.psam_State='"+this.psamState+"'";
			}
			if(!Tools.processNull(sort).equals("")){
				sql += "order by " + sort;
				
				if(!Tools.processNull(order).equals("")){
					sql += " " + order;
				}
			} else {
				sql += "order by t.psam_no";
			}
			 Page p = baseService.pagingQuery(sql.toString(),page,rows);
			 if(p.getAllRs() != null){
					jsonObject.put("rows",p.getAllRs());
					jsonObject.put("total",p.getTotalCount());
			  }
			
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
		
	}
	/**
	 * 删除供应商信息
	 * @return
	 */
	public String deleteBasePsam(){
	   
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			basePsamService.delBasePsam(psamNo);
			jsonObject.put("msg","删除psam卡成功！");
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
		
	}
	public String findBasePsam(){
		try {
			String hql = "from BaseProvider where providerName is not null ";
			List list = basePsamService.findByHql(hql);
			OutputJson(list);  
		} catch (Exception e) {
			
		}
		return null;
	}
	
	public String importBatchPSAMCard() {
		try {
			if (file == null) {
				throw new CommonException("导入文件为空.");
			}
			
			ExcelUtil<BasePsam> util = new ExcelUtil<BasePsam>(BasePsam.class);
			List<BasePsam> list;
			try {
				list = util.importExcel("", new FileInputStream(file));
			} catch (Exception e1) {
				throw new CommonException("导入文件格式或文件内容格式不正确.");
			}
			
			for (BasePsam basePsam : list) {
				if ("人社".equals(basePsam.getPsamType())) {
					basePsam.setPsamType("1");
				} else if ("住建".equals(basePsam.getPsamType())) {
					basePsam.setPsamType("2");
				} else {
					basePsam.setPsamType(null);
				}
			}
			
			List<BasePsam> failList = basePsamService.saveBasePsam(list);
			
			if (!failList.isEmpty()) {
				String expid = "exp" + new Date().getTime();
				request.getSession().setAttribute(expid, failList);
				jsonObject.put("hasFail", true);
				jsonObject.put("expid", expid);
			}
			
			jsonObject.put("status", "0");
			jsonObject.put("msg", "共 " + list.size() + " 条数据记录, 成功导入 " + (list.size() - failList.size()) + " 条, 失败 " + failList.size() + " 条");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	public String exportBatchPsamFailList() {
		try {
			String fileName = "商户终端批量导入失败数据";
			if (expid == null) {
				throw new CommonException("expid is null.");
			}
			HttpSession session = request.getSession();
			List<BasePsam> failList = (List<BasePsam>) session.getAttribute(expid);
			session.removeAttribute(expid);
			if (failList == null || failList.isEmpty()) {
				throw new CommonException("数据为空.");
			}
			for (BasePsam basePsam : failList) {
				if ("1".equals(basePsam.getPsamType())) {
					basePsam.setPsamType("人社");
				} else if ("2".equals(basePsam.getPsamType())) {
					basePsam.setPsamType("住建");
				} else {
					basePsam.setPsamType(null);
				}
			}
			ExcelUtil<BasePsam> excelUtil = new ExcelUtil<BasePsam>(BasePsam.class);
			response.setContentType("application/ms-excel;charset=utf-8");
			response.setHeader("Content-disposition", "attachment; filename=" + new String(fileName.getBytes(), "iso8859-1") + ".xls");
			OutputStream output = response.getOutputStream();
			excelUtil.exportExcel(failList, fileName, 0, output);
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	// 批量领用
	public String batchUsePSAM() {
		try {
			if (Tools.processNull(basePsam.getPsamRreceive()).equals("") || Tools.processNull(basePsam.getPsamRreceiveDate()).equals("")) {
				throw new CommonException("领用人和领用日期不能为空.");
			} else if (Tools.processNull(psamNos).equals("")) {
				throw new CommonException("领用 PSAM 卡不能为空.");
			}

			String[] psamNoArr = psamNos.split(",");
			for (String psamNo : psamNoArr) {
				BasePsam basePsam = (BasePsam) basePsamService.findOnlyRowByHql("from BasePsam where psamNo ='" + psamNo + "'");
				basePsam.setPsamRreceive(psamRreceive);
				basePsam.setPsamRreceiveDate(psamRreceiveDate);
				basePsamService.updateBasePsam(basePsam, "2");
			}

			jsonObject.put("status", "0");
		} catch (Exception e) {
			jsonObject.put("status", "1");
			jsonObject.put("errMsg", e.getMessage());
		}
		return JSONOBJ;
	}
	
	//初始化表格
		private void clearGrid() throws Exception{
			jsonObject.put("rows",new JSONArray());//记录行数
			jsonObject.put("total",0);//总条数
			jsonObject.put("status",0);//查询状态
			jsonObject.put("errMsg","");//错误信息
		}

		public BasePsamService getBasePsamService() {
			return basePsamService;
		}

		public void setBasePsamService(BasePsamService basePsamService) {
			this.basePsamService = basePsamService;
		}

		public BasePsam getBasePsam() {
			return basePsam;
		}

		public void setBasePsam(BasePsam basePsam) {
			this.basePsam = basePsam;
		}

		public String getPsamNo() {
			return psamNo;
		}

		public void setPsamNo(String psamNo) {
			this.psamNo = psamNo;
		}
		public String getPsamId() {
			return psamId;
		}

		public void setPsamId(String psamId) {
			this.psamId = psamId;
		}

		public File getFile() {
			return file;
		}

		public void setFile(File file) {
			this.file = file;
		}

		public String getExpid() {
			return expid;
		}

		public void setExpid(String expid) {
			this.expid = expid;
		}

		public String getPsamNos() {
			return psamNos;
		}

		public void setPsamNos(String psamNos) {
			this.psamNos = psamNos;
		}

		public String getCancleReason() {
			return cancleReason;
		}

		public void setCancleReason(String cancleReason) {
			this.cancleReason = cancleReason;
		}

		public String getPsamRreceive() {
			return psamRreceive;
		}

		public void setPsamRreceive(String psamRreceive) {
			this.psamRreceive = psamRreceive;
		}

		public String getPsamRreceiveDate() {
			return psamRreceiveDate;
		}

		public void setPsamRreceiveDate(String psamRreceiveDate) {
			this.psamRreceiveDate = psamRreceiveDate;
		}

		public String getPsamState() {
			return psamState;
		}

		public void setPsamState(String psamState) {
			this.psamState = psamState;
		}
		
		
}
