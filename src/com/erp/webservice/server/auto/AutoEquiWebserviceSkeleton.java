
/**
 * AutoEquiWebserviceSkeleton.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis2 version: 1.4.1  Built on : Aug 13, 2008 (05:03:35 LKT)
 */
    package com.erp.webservice.server.auto;

import java.util.ArrayList;

import org.apache.log4j.Logger;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.web.context.ContextLoader;
import org.springframework.web.context.WebApplicationContext;

import com.erp.service.AutoEquiService;
import com.erp.service.NetAppOfSbService;
import com.erp.util.Tools;
import com.erp.util.XmlBeanUtil;
import com.erp.webservice.server.bean.Data;
import com.erp.webservice.server.bean.InNetRequestBean;
import com.erp.webservice.server.bean.ResponseBean;
import com.erp.webservice.server.sbsl.NetAppOfSbServiceSkeleton;
    /**
     *  AutoEquiWebserviceSkeleton java skeleton for the axisService
     */
    public class AutoEquiWebserviceSkeleton implements AutoEquiWebserviceSkeletonInterface{
    	public static Logger logger = Logger.getLogger(NetAppOfSbServiceSkeleton.class);
    	private static WebApplicationContext context = ContextLoader.getCurrentWebApplicationContext();
    	AutoEquiService autoEquiService = (AutoEquiService)context.getBean("autoEquiService");
        
         
        /**
         * Auto generated method signature
         * 
                                     * @param ljtoqbCharge0
         */
        
                 public com.erp.webservice.server.auto.LjtoqbChargeResponse ljtoqbCharge
                  (com.erp.webservice.server.auto.LjtoqbCharge ljtoqbCharge0){
                	 LjtoqbChargeResponse mps = new LjtoqbChargeResponse();
                 	try {
                 		Thread.sleep(600);
             			mps.set_return(autoEquiService.ljtoqbCharge(ljtoqbCharge0.getInXml()));
             		} catch (Exception e) {
             			try {
             				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(ljtoqbCharge0.getInXml(), "RequestBean", InNetRequestBean.class);
             				mps.set_return(autoEquiService.createReturnXml(new ResponseBean("1", e.getMessage()),getMethod(),false,reqBean));
             			} catch (Exception e1) {
             				e1.printStackTrace();
             			}
             		}
             		return mps;
        }
     
         
        /**
         * Auto generated method signature
         * 
                                     * @param czqrorcz2
         */
        
                 public com.erp.webservice.server.auto.CzqrorczResponse czqrorcz
                  (com.erp.webservice.server.auto.Czqrorcz czqrorcz2 ) {
                	 CzqrorczResponse mps = new CzqrorczResponse();
                 	try {
                 		mps.set_return(autoEquiService.czqrorcz(czqrorcz2.getInXml()));
             			
             		} catch (Exception e) {
             			try {
             				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(czqrorcz2.getInXml(), "RequestBean", InNetRequestBean.class);
             				mps.set_return(autoEquiService.createReturnXml(new ResponseBean("1", e.getMessage()),getMethod(),false,reqBean));
             			} catch (Exception e1) {
             				e1.printStackTrace();
             			}
             		}
             		return mps;
        }
     
         
        /**
         * Auto generated method signature
         * 
                                     * @param reportLoss4
         */
        
                 public com.erp.webservice.server.auto.ReportLossResponse reportLoss(com.erp.webservice.server.auto.ReportLoss reportLoss4){
                		ReportLossResponse mps = new ReportLossResponse();
                    	try {
                    		Thread.sleep(600);
                    		String s=autoEquiService.reportLoss(reportLoss4.getInXml());
                    		mps.set_return(s);
                	
                			
                		} catch (Exception e) {
                			try {
                				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(reportLoss4.getInXml(), "RequestBean", InNetRequestBean.class);
                				mps.set_return(autoEquiService.createReturnXml(new ResponseBean("1", e.getMessage()),getMethod(),false,reqBean));
                			} catch (Exception e1) {
                				e1.printStackTrace();
                			}
                		}
                		return mps;
        }
     
         
        /**
         * Auto generated method signature
         * 
                                     * @param loginValidate6
         */
        
                 public com.erp.webservice.server.auto.LoginValidateResponse loginValidate(com.erp.webservice.server.auto.LoginValidate loginValidate6) {
                		LoginValidateResponse mps = new LoginValidateResponse();
                    	try {
                    		Thread.sleep(600);
                    		String s=autoEquiService.loginValidate(loginValidate6.getInXml());
                    		mps.set_return(s);
                		} catch (Exception e) {
                			try {
                				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(loginValidate6.getInXml(), "RequestBean", InNetRequestBean.class);
                				mps.set_return(autoEquiService.createReturnXml(new ResponseBean("1", e.getMessage()),getMethod(),false,reqBean));
                			} catch (Exception e1) {
                				e1.printStackTrace();
                			}
                		}
                		return mps;
        }
     
         
        /**
         * Auto generated method signature
         * 
                                     * @param checkMac8
         */
        
                 public com.erp.webservice.server.auto.CheckMacResponse checkMac (
                  com.erp.webservice.server.auto.CheckMac checkMac8){
                	 CheckMacResponse mps = new CheckMacResponse();
             		try {
             			mps.set_return(autoEquiService.checkMac(checkMac8.getInXml()));
             			
             		} catch (Exception e) {
             			try {
             				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(checkMac8.getInXml(), "RequestBean", InNetRequestBean.class);
             				mps.set_return(autoEquiService.createReturnXml(new ResponseBean("1", e.getMessage()),getMethod(),false,reqBean));
             			} catch (Exception e2) {
             				e2.printStackTrace();
             			}
             		}
             		return mps;
        }
     
         
        /**
         * Auto generated method signature
         * 
                                     * @param charge10
         */
        
                 public com.erp.webservice.server.auto.ChargeResponse charge(com.erp.webservice.server.auto.Charge charge10){
                	 ChargeResponse mps = new ChargeResponse();
                 	try {
                 		Thread.sleep(600);
                 		mps.set_return(autoEquiService.chargeAuto(charge10.getInXml()));
             		
             		} catch (Exception e) {
             			try {
             				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(charge10.getInXml(), "RequestBean", InNetRequestBean.class);
             				// 若出现日志异常时，此时消费事务已提交，还是当作当前业务成功
             				// e.message="Sys_Action_Log Error！"+交易后余额+"|"+交易流水号+"|"+清分日期+"|"
             				if(!Tools.processNull(e.getMessage()).equals("") && Tools.processNull(e.getMessage()).startsWith("Sys_Action_Log Error！")){
             					String[]ret=e.getMessage().split("\\|");
             					ArrayList datas=new ArrayList();
             					Data data=new Data();
             					data.setAccBalAft(ret[1]);
             					data.setTrActionNo(new Long(ret[2]));
             					data.setClrDate(ret[3]);
             					datas.add(data);
             					mps.set_return(autoEquiService.createReturnXml(new ResponseBean("0","",datas), getMethod(),false,null));
             				}else 				
             					mps.set_return(autoEquiService.createReturnXml(new ResponseBean("1", e.getMessage()),getMethod(),false,reqBean));
             			} catch (Exception e1) {
             				e1.printStackTrace();
             			}
             		}
             		return mps;
        }
     
         
        /**
         * Auto generated method signature
         * 
                                     * @param queryBal12
         */
        
                 public com.erp.webservice.server.auto.QueryBalResponse queryBal(com.erp.webservice.server.auto.QueryBal queryBal12) {
                		QueryBalResponse mps = new QueryBalResponse();
                    	try {
                    		Thread.sleep(600);
                    		String s=autoEquiService.queryBal(queryBal12.getInXml());
                    		mps.set_return(s);
                		} catch (Exception e) {
                			try {
                				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(queryBal12.getInXml(), "RequestBean", InNetRequestBean.class);
                				mps.set_return(autoEquiService.createReturnXml(new ResponseBean("1", e.getMessage()),getMethod(),false,reqBean));
                			} catch (Exception e1) {
                				e1.printStackTrace();
                			}
                		}
                		return mps;
        }
     
         
        /**
         * Auto generated method signature
         * 
                                     * @param earmarkCharge14
         */
        
                 public com.erp.webservice.server.auto.EarmarkChargeResponse earmarkCharge(com.erp.webservice.server.auto.EarmarkCharge earmarkCharge14){
                	 EarmarkChargeResponse mps = new EarmarkChargeResponse();
                   	try {
                   		Thread.sleep(600);
                 		mps.set_return(autoEquiService.earmarkCharge(earmarkCharge14.getInXml()));///这里是业务实现
               			
               		} catch (Exception e) {
               			try {
               				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(earmarkCharge14.getInXml(), "RequestBean", InNetRequestBean.class);
               				mps.set_return(autoEquiService.createReturnXml(new ResponseBean("1", e.getMessage()),getMethod(),false,reqBean));
               			} catch (Exception  e1) {
               				e1.printStackTrace();
               			}
               		}
             	return mps;
        }
     
         
        /**
         * Auto generated method signature
         * 
                                     * @param queryTransDetail16
         */
        
                 public com.erp.webservice.server.auto.QueryTransDetailResponse queryTransDetail(
                  com.erp.webservice.server.auto.QueryTransDetail queryTransDetail16){
                	 QueryTransDetailResponse mps = new QueryTransDetailResponse();
                 	try {
                 		Thread.sleep(600);
                 		String s=autoEquiService.queryTransDetail(queryTransDetail16.getInXml());
             			mps.set_return(s);
             			
             		} catch (Exception e) {
             			try {
             				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(queryTransDetail16.getInXml(), "RequestBean", InNetRequestBean.class);
             				mps.set_return(autoEquiService.createReturnXml(new ResponseBean("1", e.getMessage()),getMethod(),false,reqBean));
             			} catch (Exception e1) {
             				e1.printStackTrace();
             			}
             		}
             		return mps;
        }
     
         
        /**
         * Auto generated method signature
         * 
                                     * @param modifyPwd18
         */
        
                 public com.erp.webservice.server.auto.ModifyPwdResponse modifyPwd( com.erp.webservice.server.auto.ModifyPwd modifyPwd18 ){
                	 ModifyPwdResponse mps = new ModifyPwdResponse();
                 	try {
                 		Thread.sleep(600);
                  		mps.set_return(autoEquiService.modifyPwd(modifyPwd18.getInXml()));
             			
             		} catch (Exception e) {
             			try {
             				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(modifyPwd18.getInXml(), "RequestBean", InNetRequestBean.class);
             				mps.set_return(autoEquiService.createReturnXml(new ResponseBean("1", e.getMessage()),getMethod(),false,reqBean));
             			} catch (Exception e1) {
             				e1.printStackTrace();
             			}
             		}
             		return mps;
        }
     
         
        /**
         * Auto generated method signature
         * 
                                     * @param judgePwd20
         */
        
                 public com.erp.webservice.server.auto.JudgePwdResponse judgePwd(com.erp.webservice.server.auto.JudgePwd judgePwd20 ) {
                		JudgePwdResponse mps = new JudgePwdResponse();
                     	try {
                     		Thread.sleep(600);
                     		mps.set_return(autoEquiService.judgePwd(judgePwd20.getInXml()));///这里是业务实现
                 			
                 		} catch (Exception e) {
                 			try {
                 				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(judgePwd20.getInXml(), "RequestBean", InNetRequestBean.class);
                 				mps.set_return(autoEquiService.createReturnXml(new ResponseBean("1", e.getMessage()),getMethod(),false,reqBean));
                 			} catch (Exception e1) {
                 				e1.printStackTrace();
                 			}
                 		}
                	     return mps;
        }
     
         
        /**
         * Auto generated method signature
         * 
                                     * @param queryCardState22
         */
        
                 public com.erp.webservice.server.auto.QueryCardStateResponse queryCardState( com.erp.webservice.server.auto.QueryCardState queryCardState22){
                	 QueryCardStateResponse mps = new QueryCardStateResponse();
                 	try {
                 		Thread.sleep(600);
                 		String s=autoEquiService.queryCardState(queryCardState22.getInXml());
                 		mps.set_return(s);
             			
             		} catch (Exception e) {
             			try {
             				InNetRequestBean reqBean = (InNetRequestBean) XmlBeanUtil.xml2java(queryCardState22.getInXml(), "RequestBean", InNetRequestBean.class);
             				mps.set_return(autoEquiService.createReturnXml(new ResponseBean("1", e.getMessage()),getMethod(),false,reqBean));
             			} catch (Exception e1) {
             				e1.printStackTrace();
             			}
             		}
             		return mps;
        }
     
         
        /**
         * Auto generated method signature
         * 
                                     * @param qcxeedit24
         */
        
                 public com.erp.webservice.server.auto.QcxeeditResponse qcxeedit
                  (
                  com.erp.webservice.server.auto.Qcxeedit qcxeedit24
                  )
            {
                //TODO : fill this with the necessary business logic
                throw new  java.lang.UnsupportedOperationException("Please implement " + this.getClass().getName() + "#qcxeedit");
        }
                 
                 /**
          	    * 公共方法
          	    * @return
          	    */
          	private String getMethod(){
          		try {
          			return new Exception().getStackTrace()[0].getClassName()+"["+new Exception().getStackTrace()[1].getMethodName()+"]";
          		} catch (Exception e) {
          			return this.getClass()+"";
          		}
          	}

     
    }
    