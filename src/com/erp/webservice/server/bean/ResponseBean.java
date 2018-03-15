package com.erp.webservice.server.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
@SuppressWarnings({"serial","static-access","unused","unchecked"})
public class ResponseBean implements Serializable {
	public String result;

	public String message;
	
	public String eCode;

	public Long totCount;// 记录总条数
	
	public String actionNo;// 交易流水号
	
	public String totInAmt;// 收入总金额，如退货
	
	public String totOutAmt;// 付出总金额，如消费
	
	public String totAmt;//总交易金额
	
	public String crmActionNo;//crm平台的交易流水号，返回时加写

	public List<Data> datas = new ArrayList<Data>();
	
	public String RET_CODE;
	
	public String RET_MSG;

	public String PDF_BASE64;// 
	

	
	public String getECode() {
		return eCode;
	}

	public void setECode(String code) {
		eCode = code;
	}

	public String getPDF_BASE64() {
		return PDF_BASE64;
	}

	public void setPDF_BASE64(String pdf_base64) {
		PDF_BASE64 = pdf_base64;
	}

	public String getRET_CODE() {
		return RET_CODE;
	}

	public void setRET_CODE(String ret_code) {
		RET_CODE = ret_code;
	}

	public String getRET_MSG() {
		return RET_MSG;
	}

	public void setRET_MSG(String ret_msg) {
		RET_MSG = ret_msg;
	}

	//此方法会使节点元素变成小写，因此注释
//	public void addData(Data Data) {
//		datas.add(Data);
//	}
	public ResponseBean(String result, String message,String actionNo) {
		super();
		this.result = result;
		this.message = message;
		this.actionNo = actionNo;
	}

	public ResponseBean() {
		super();
	}
	
	public ResponseBean(String result, String message) {
		super();
		this.result = result;
		this.message = message;
	}
	public ResponseBean(String result, String message,ArrayList<Data> datas) {
		super();
		this.result = result;
		this.message = message;
		this.datas = datas;
	}
	public ResponseBean(String result, String message, Long totCount, ArrayList<Data> datas) {
		super();
		this.result = result;
		this.message = message;
		this.totCount = totCount;
		this.datas = datas;
	}
	public ResponseBean(String result, String message, Long totCount, String totAmt,ArrayList<Data> datas) {
		super();
		this.result = result;
		this.message = message;
		this.totCount = totCount;
		this.totAmt = totAmt;
		this.datas = datas;
	}
	public ResponseBean(String result, String message, Long totCount, String totInAmt,String totOutAmt,ArrayList<Data> datas) {
		super();
		this.result = result;
		this.message = message;
		this.totCount = totCount;
		this.totInAmt = totInAmt;
		this.totOutAmt = totOutAmt;
		this.datas = datas;
	}
	public ResponseBean(String result, String message,String actionNo,String crmActionNo) {
		super();
		this.result = result;
		this.message = message;
		this.actionNo = actionNo;
		this.crmActionNo = crmActionNo;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}
	
	public String geteCode() {
		return eCode;
	}

	public void seteCode(String eCode) {
		this.eCode = eCode;
	}

	public String getResult() {
		return result;
	}

	public void setResult(String result) {
		this.result = result;
	}

	public Long getTotCount() {
		return totCount;
	}

	public void setTotCount(Long totCount) {
		this.totCount = totCount;
	}

	public List<Data> getDatas() {
		return datas;
	}

	public void setDatas(List<Data> datas) {
		this.datas = datas;
	}

	public String getActionNo() {
		return actionNo;
	}

	public void setActionNo(String actionNo) {
		this.actionNo = actionNo;
	}

	public String getTotInAmt() {
		return totInAmt;
	}

	public void setTotInAmt(String totInAmt) {
		this.totInAmt = totInAmt;
	}

	public String getTotOutAmt() {
		return totOutAmt;
	}

	public void setTotOutAmt(String totOutAmt) {
		this.totOutAmt = totOutAmt;
	}

	public String getCrmActionNo() {
		return crmActionNo;
	}

	public void setCrmActionNo(String crmActionNo) {
		this.crmActionNo = crmActionNo;
	}

	public String getTotAmt() {
		return totAmt;
	}

	public void setTotAmt(String totAmt) {
		this.totAmt = totAmt;
	}
}
