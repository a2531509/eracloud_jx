package com.erp.webservice.server.bean;

import java.io.Serializable;

@SuppressWarnings("serial")
public class Response implements Serializable{	
	public String RET_CODE;
	
	public String RET_MSG;

	public String PDFBASE64;// 

	public String getPDFBASE64() {
		return PDFBASE64;
	}

	public void setPDFBASE64(String pdfbase64) {
		PDFBASE64 = pdfbase64;
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
	

}
