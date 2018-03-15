/**
 * NetAppOfSbServiceSkeleton.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis2 version: 1.4.1  Built on : Aug 13, 2008 (05:03:35 LKT)
 */
package com.erp.webservice.server.sbsl;

import java.util.Date;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.AbstractApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.stereotype.Component;
import org.springframework.web.context.ContextLoader;
import org.springframework.web.context.WebApplicationContext;

import com.erp.action.CardApplyAction;
import com.erp.exception.CommonException;
import com.erp.service.ClrDealService;
import com.erp.service.NetAppOfSbService;
import com.erp.service.OfflineDataService;
import com.erp.service.TaskManagementService;
import com.erp.service.WebserviceUtilService;
import com.erp.util.DateUtil;
import com.erp.util.XmlBeanUtil;
import com.erp.webservice.server.bean.InNetRequestBean;
import com.erp.webservice.server.bean.ResponseBean;

/**
 * NetAppOfSbServiceSkeleton java skeleton for the axisService
 */
@Component(value = "netAppOfSbServiceSkeletonInterface")
public class NetAppOfSbServiceSkeleton implements NetAppOfSbServiceSkeletonInterface {
	public static Logger logger = Logger.getLogger(NetAppOfSbServiceSkeleton.class);
	private static WebApplicationContext context = ContextLoader.getCurrentWebApplicationContext();
	NetAppOfSbService netAppOfSbService = (NetAppOfSbService)context.getBean("netAppOfSbService");


	/**
	 * Auto generated method signature
	 * 
	 * @param execute0
	 */

	public com.erp.webservice.server.sbsl.ExecuteResponse execute(
			com.erp.webservice.server.sbsl.Execute execute0) {
		//AbstractApplicationContext ctx = new ClassPathXmlApplicationContext("classpath:spring-hibernate.xml","classpath:spring.xml");
		//NetAppOfSbService netAppOfSbService = ctx.getBean(NetAppOfSbService.class);
	
		com.erp.webservice.server.sbsl.ExecuteResponse mps = new com.erp.webservice.server.sbsl.ExecuteResponse();
		try {
			if (execute0.getParam0() == null) {
				throw new CommonException("交易代码不能为空!");
			} else {
				int trcode2 = 1001;
				logger.error(DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss")+"=Param0="+execute0.getParam0());
				logger.error("Param1="+execute0.getParam1());

				if (Integer.valueOf(execute0.getParam0()).equals(trcode2++)) {
					mps.set_return(netAppOfSbService.savequeryyzk(execute0.getParam1()));// 1001查询已制卡人员信息
				} else if (Integer.valueOf(execute0.getParam0()).equals(trcode2++)) {
					mps.set_return(netAppOfSbService.saveapplyinfo(execute0.getParam1()));// 1002将网上申报数据录入卡管系统数据库
				} else if (Integer.valueOf(execute0.getParam0()).equals(trcode2++)) {
					mps.set_return(netAppOfSbService.updateapplyphoto(execute0.getParam1()));// 1003更新个人照片
				} else if (Integer.valueOf(execute0.getParam0()).equals(trcode2++)) {
					mps.set_return(netAppOfSbService.updatesureFlag(execute0.getParam1()));// 1004更新个人信息
				} else if (Integer.valueOf(execute0.getParam0()).equals(trcode2++)) {
					mps.set_return(netAppOfSbService.savequerywzk(execute0.getParam1()));// 1005查询未制卡人员信息
				} else if (Integer.valueOf(execute0.getParam0()).equals(trcode2++)) {
					mps.set_return(netAppOfSbService.savechexiaoapply(execute0.getParam1()));// 1006撤销申报
				} else if (Integer.valueOf(execute0.getParam0()).equals(trcode2++)) {// 1007查询统计
					mps.set_return(netAppOfSbService.savetongjiquery(execute0.getParam1()));
				} else if (Integer.valueOf(execute0.getParam0()).equals(trcode2++)) {// 1008打印领卡单
					mps.set_return(netAppOfSbService.savelingkadan(execute0.getParam1()));//
				} else if (Integer.valueOf(execute0.getParam0()).equals(trcode2++)) {// 1009查询单位经办人,银行领卡网点名称
					mps.set_return(netAppOfSbService.saveQueryEmp(execute0.getParam1()));//
				} else if (Integer.valueOf(execute0.getParam0()).equals(trcode2++)) {// 1010获取单位勘误人员
					mps.set_return(netAppOfSbService.expPersonErrata(execute0.getParam1()));//
				} else if (Integer.valueOf(execute0.getParam0()).equals(trcode2++)) {// 1011上传申领人员
					mps.set_return(netAppOfSbService.impCorpNetAppData(execute0.getParam1()));//
				} else if (Integer.valueOf(execute0.getParam0()).equals(trcode2++)) {// 1012下载申领人员数据
					mps.set_return(netAppOfSbService.getCorpNetAppData(execute0.getParam1()));//
				} else if (Integer.valueOf(execute0.getParam0()).equals(2001)) {// 2001获取人员照片
					mps.set_return(netAppOfSbService.getPersonPhoto(execute0.getParam1()));//
				} else if (Integer.valueOf(execute0.getParam0()).equals(2002)) {// 2002获取银行卡信息
					mps.set_return(netAppOfSbService.getBankCardInfo(execute0.getParam1()));//
				}
			}
		} catch (Exception e) {
			try {
				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(execute0.getParam1(), "RequestBean",InNetRequestBean.class);
				mps.set_return(netAppOfSbService.createReturnXml(new ResponseBean("1", e.getMessage()), getMethod(),false, reqBean));
			} catch (Exception e1) {
				e1.printStackTrace();
			}
		}finally{
			try {
				//ctx.close();
				System.gc();
			} catch (Exception ee) {
				ee.printStackTrace();
			}
		}
		return mps;
	}

	private String getMethod() {
		try {
			return new Exception().getStackTrace()[0].getClassName() + "["
					+ new Exception().getStackTrace()[1].getMethodName() + "]";
		} catch (Exception e) {
			return this.getClass() + "";
		}
	}



}
