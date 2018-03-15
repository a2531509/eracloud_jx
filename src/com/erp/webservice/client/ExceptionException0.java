
/**
 * ExceptionException0.java
 *
 * This file was auto-generated from WSDL
 * by the Apache Axis2 version: 1.4.1  Built on : Aug 13, 2008 (05:03:35 LKT)
 */

package com.erp.webservice.client;

public class ExceptionException0 extends java.lang.Exception{
    
    private com.erp.webservice.client.SealServiceStub.ExceptionE faultMessage;
    
    public ExceptionException0() {
        super("ExceptionException0");
    }
           
    public ExceptionException0(java.lang.String s) {
       super(s);
    }
    
    public ExceptionException0(java.lang.String s, java.lang.Throwable ex) {
      super(s, ex);
    }
    
    public void setFaultMessage(com.erp.webservice.client.SealServiceStub.ExceptionE msg){
       faultMessage = msg;
    }
    
    public com.erp.webservice.client.SealServiceStub.ExceptionE getFaultMessage(){
       return faultMessage;
    }
}
    