package com.erp.model;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "pay_car_total")
public class PayCarTotal {
	@Id
	@Column(name = "batch_number")
	private Long batchNumber;

	@Column(name = "provide_year")
	private String provideYear;

	@Column(name = "provide_month")
	private String provideMonth;

	@Column(name = "provide_day")
	private String provideDay;

	@Column(name = "emp_name")
	private String empName;

	@Column(name = "num")
	private Long number;

	@Column(name = "amt")
	private BigDecimal amt;

	@Column(name = "state")
	private String state;

	@Column(name = "recharge_num")
	private Long rechargeNum;

	@Column(name = "recharge_amt")
	private BigDecimal rechargeAmt;

	@Column(name = "fail_num")
	private Long failNum;

	public PayCarTotal() {
		super();
	}

	public PayCarTotal(Long batchNumber) {
		super();
		this.batchNumber = batchNumber;
	}

	public PayCarTotal(Long batchNumber, String provideYear,
			String provideMonth, String provideDay, String empName,
			Long number, BigDecimal amt, String state, Long rechargeNum,
			BigDecimal rechargeAmt, Long failNum) {
		super();
		this.batchNumber = batchNumber;
		this.provideYear = provideYear;
		this.provideMonth = provideMonth;
		this.provideDay = provideDay;
		this.empName = empName;
		this.number = number;
		this.amt = amt;
		this.state = state;
		this.rechargeNum = rechargeNum;
		this.rechargeAmt = rechargeAmt;
		this.failNum = failNum;
	}

	public Long getBatchNumber() {
		return batchNumber;
	}

	public void setBatchNumber(Long batchNumber) {
		this.batchNumber = batchNumber;
	}

	public String getProvideYear() {
		return provideYear;
	}

	public void setProvideYear(String provideYear) {
		this.provideYear = provideYear;
	}

	public String getProvideMonth() {
		return provideMonth;
	}

	public void setProvideMonth(String provideMonth) {
		this.provideMonth = provideMonth;
	}

	public String getProvideDay() {
		return provideDay;
	}

	public void setProvideDay(String provideDay) {
		this.provideDay = provideDay;
	}

	public String getEmpName() {
		return empName;
	}

	public void setEmpName(String empName) {
		this.empName = empName;
	}

	public Long getNumber() {
		return number;
	}

	public void setNumber(Long number) {
		this.number = number;
	}

	public BigDecimal getAmt() {
		return amt;
	}

	public void setAmt(BigDecimal amt) {
		this.amt = amt;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public Long getRechargeNum() {
		return rechargeNum;
	}

	public void setRechargeNum(Long rechargeNum) {
		this.rechargeNum = rechargeNum;
	}

	public BigDecimal getRechargeAmt() {
		return rechargeAmt;
	}

	public void setRechargeAmt(BigDecimal rechargeAmt) {
		this.rechargeAmt = rechargeAmt;
	}

	public Long getFailNum() {
		return failNum;
	}

	public void setFailNum(Long failNum) {
		this.failNum = failNum;
	}
}
