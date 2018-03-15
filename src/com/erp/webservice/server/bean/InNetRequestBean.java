package com.erp.webservice.server.bean;

import java.io.Serializable;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

import com.erp.util.Tools;


@SuppressWarnings({"serial","static-access","unused","unchecked"})
public class InNetRequestBean extends RequestBean implements Serializable{	
	/**
	 * 客户id
	 */
	public String clientId;		
	
	/**
	 * 交易类型，暂定0查询所有，1是查询充值，2是查询消费，3圈存圈提，缺省为0
	 */
	public String trKind;
	
	/**
	 * 收付类型，1收，2付，3收付，缺省为3
	 */
	public String inOutType;
	
	/**
	 * 科目编号，主要征对于商户，缺省为 "207101";// 代理网点预存款
	 * 	"205201";// 手续费待清算款
		"205101";// 市民卡商户待清算款
		"207101";// 代理网点预存款
		"703101"; // 卡押金月收入
		"709999"; // 其他收入款
		"701101"; // 商户手续费收入	
	 */
	public String itemNo;
	
	/**
	 * 订单日期，长度8 格式YYYYMMDD
	 */
	public String orderDate;
	
	/**
	 * 客户手机号码
	 */
	public String mobileNo;
	
	
	/**
	 * 银行编号
	 * 
	 */
	public String bank_Id;
	
	/**
	 * 银行名称
	 * @return
	 */
	public String bank_Name;
	/**
	 * 银行卡号
	 * @return
	 */
	public String bank_Card_No;
	
	public String recvBrchId;
	
	public String taskDate;
	
	public String startDate;
	public String endDate;
	
	
	
	public String getStartDate() {
		return startDate;
	}

	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}

	public String getEndDate() {
		return endDate;
	}

	public void setEndDate(String endDate) {
		this.endDate = endDate;
	}

	public String getTaskDate() {
		return taskDate;
	}

	public void setTaskDate(String taskDate) {
		this.taskDate = taskDate;
	}

	public String getRecvBrchId() {
		return recvBrchId;
	}

	public void setRecvBrchId(String recvBrchId) {
		this.recvBrchId = recvBrchId;
	}

	public String getBank_Id() {
		return bank_Id;
	}

	public void setBank_Id(String bank_Id) {
		this.bank_Id = bank_Id;
	}

	public String getBank_Name() {
		return bank_Name;
	}

	public void setBank_Name(String bank_Name) {
		this.bank_Name = bank_Name;
	}

	public String getBank_Card_No() {
		return bank_Card_No;
	}

	public void setBank_Card_No(String bank_Card_No) {
		this.bank_Card_No = bank_Card_No;
	}

	public String getMobileNo() {
		return mobileNo;
	}

	public void setMobileNo(String mobileNo) {
		this.mobileNo = mobileNo;
	}
	
	public InNetRequestBean() {
		super();
	}
	
	public String getClientId() {
		return clientId;
	}


	public void setClientId(String clientId) {
		this.clientId = clientId;
	}


	public String getInOutType() {
		return inOutType;
	}


	public void setInOutType(String inOutType) {
		this.inOutType = inOutType;
	}


	public String getItemNo() {
		return itemNo;
	}


	public void setItemNo(String itemNo) {
		this.itemNo = itemNo;
	}


	public String getOrderDate() {
		return orderDate;
	}


	public void setOrderDate(String orderDate) {
		this.orderDate = orderDate;
	}


	public String getTrKind() {
		return trKind;
	}


	public void setTrKind(String trKind) {
		this.trKind = trKind;
	}


	@Override
	public String toString() {
		try {
			StringBuffer retstr=new StringBuffer();
			Field fields[]=this.getClass().getFields();
			for(int k=0;k< fields.length; k++){
				Field onefield=fields[k];
				Method ms = this.getClass().getMethod("get"+onefield.getName().substring(0, 1).toUpperCase()+onefield.getName().substring(1));
				Object value=Tools.processNull(ms.invoke(this,new Object[0]));
				if(!value.equals(""))//仅输出有值的字段，以免记录actionlog里字段长度超出范围
					retstr.append(onefield.getName()+"="+value+",");
			}
			return retstr.toString();
		} catch (Exception e) {
			e.printStackTrace();
			return "";
		}
	}
}
