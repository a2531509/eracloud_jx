

        package com.erp.webservice.server.auto;

        public class AutoEquiWebserviceMessageReceiverInOut extends org.apache.axis2.receivers.AbstractInOutMessageReceiver{

        public void invokeBusinessLogic(org.apache.axis2.context.MessageContext msgContext, org.apache.axis2.context.MessageContext newMsgContext)
        throws org.apache.axis2.AxisFault{

        try {

        // get the implementation class for the Web Service
        Object obj = getTheImplementationObject(msgContext);

        AutoEquiWebserviceSkeletonInterface skel = (AutoEquiWebserviceSkeletonInterface)obj;
        //Out Envelop
        org.apache.axiom.soap.SOAPEnvelope envelope = null;
        //Find the axisOperation that has been set by the Dispatch phase.
        org.apache.axis2.description.AxisOperation op = msgContext.getOperationContext().getAxisOperation();
        if (op == null) {
        throw new org.apache.axis2.AxisFault("Operation is not located, if this is doclit style the SOAP-ACTION should specified via the SOAP Action to use the RawXMLProvider");
        }

        java.lang.String methodName;
        if((op.getName() != null) && ((methodName = org.apache.axis2.util.JavaUtils.xmlNameToJava(op.getName().getLocalPart())) != null)){

        

            if("ljtoqbCharge".equals(methodName)){
                
                com.erp.webservice.server.auto.LjtoqbChargeResponse ljtoqbChargeResponse27 = null;
	                        com.erp.webservice.server.auto.LjtoqbCharge wrappedParam =
                                                             (com.erp.webservice.server.auto.LjtoqbCharge)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.LjtoqbCharge.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               ljtoqbChargeResponse27 =
                                                   
                                                   
                                                         skel.ljtoqbCharge(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), ljtoqbChargeResponse27, false);
                                    } else 

            if("czqrorcz".equals(methodName)){
                
                com.erp.webservice.server.auto.CzqrorczResponse czqrorczResponse29 = null;
	                        com.erp.webservice.server.auto.Czqrorcz wrappedParam =
                                                             (com.erp.webservice.server.auto.Czqrorcz)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.Czqrorcz.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               czqrorczResponse29 =
                                                   
                                                   
                                                         skel.czqrorcz(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), czqrorczResponse29, false);
                                    } else 

            if("reportLoss".equals(methodName)){
                
                com.erp.webservice.server.auto.ReportLossResponse reportLossResponse31 = null;
	                        com.erp.webservice.server.auto.ReportLoss wrappedParam =
                                                             (com.erp.webservice.server.auto.ReportLoss)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.ReportLoss.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               reportLossResponse31 =
                                                   
                                                   
                                                         skel.reportLoss(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), reportLossResponse31, false);
                                    } else 

            if("loginValidate".equals(methodName)){
                
                com.erp.webservice.server.auto.LoginValidateResponse loginValidateResponse33 = null;
	                        com.erp.webservice.server.auto.LoginValidate wrappedParam =
                                                             (com.erp.webservice.server.auto.LoginValidate)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.LoginValidate.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               loginValidateResponse33 =
                                                   
                                                   
                                                         skel.loginValidate(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), loginValidateResponse33, false);
                                    } else 

            if("checkMac".equals(methodName)){
                
                com.erp.webservice.server.auto.CheckMacResponse checkMacResponse35 = null;
	                        com.erp.webservice.server.auto.CheckMac wrappedParam =
                                                             (com.erp.webservice.server.auto.CheckMac)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.CheckMac.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               checkMacResponse35 =
                                                   
                                                   
                                                         skel.checkMac(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), checkMacResponse35, false);
                                    } else 

            if("charge".equals(methodName)){
                
                com.erp.webservice.server.auto.ChargeResponse chargeResponse37 = null;
	                        com.erp.webservice.server.auto.Charge wrappedParam =
                                                             (com.erp.webservice.server.auto.Charge)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.Charge.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               chargeResponse37 =
                                                   
                                                   
                                                         skel.charge(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), chargeResponse37, false);
                                    } else 

            if("queryBal".equals(methodName)){
                
                com.erp.webservice.server.auto.QueryBalResponse queryBalResponse39 = null;
	                        com.erp.webservice.server.auto.QueryBal wrappedParam =
                                                             (com.erp.webservice.server.auto.QueryBal)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.QueryBal.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               queryBalResponse39 =
                                                   
                                                   
                                                         skel.queryBal(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), queryBalResponse39, false);
                                    } else 

            if("earmarkCharge".equals(methodName)){
                
                com.erp.webservice.server.auto.EarmarkChargeResponse earmarkChargeResponse41 = null;
	                        com.erp.webservice.server.auto.EarmarkCharge wrappedParam =
                                                             (com.erp.webservice.server.auto.EarmarkCharge)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.EarmarkCharge.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               earmarkChargeResponse41 =
                                                   
                                                   
                                                         skel.earmarkCharge(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), earmarkChargeResponse41, false);
                                    } else 

            if("queryTransDetail".equals(methodName)){
                
                com.erp.webservice.server.auto.QueryTransDetailResponse queryTransDetailResponse43 = null;
	                        com.erp.webservice.server.auto.QueryTransDetail wrappedParam =
                                                             (com.erp.webservice.server.auto.QueryTransDetail)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.QueryTransDetail.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               queryTransDetailResponse43 =
                                                   
                                                   
                                                         skel.queryTransDetail(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), queryTransDetailResponse43, false);
                                    } else 

            if("modifyPwd".equals(methodName)){
                
                com.erp.webservice.server.auto.ModifyPwdResponse modifyPwdResponse45 = null;
	                        com.erp.webservice.server.auto.ModifyPwd wrappedParam =
                                                             (com.erp.webservice.server.auto.ModifyPwd)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.ModifyPwd.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               modifyPwdResponse45 =
                                                   
                                                   
                                                         skel.modifyPwd(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), modifyPwdResponse45, false);
                                    } else 

            if("judgePwd".equals(methodName)){
                
                com.erp.webservice.server.auto.JudgePwdResponse judgePwdResponse47 = null;
	                        com.erp.webservice.server.auto.JudgePwd wrappedParam =
                                                             (com.erp.webservice.server.auto.JudgePwd)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.JudgePwd.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               judgePwdResponse47 =
                                                   
                                                   
                                                         skel.judgePwd(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), judgePwdResponse47, false);
                                    } else 

            if("queryCardState".equals(methodName)){
                
                com.erp.webservice.server.auto.QueryCardStateResponse queryCardStateResponse49 = null;
	                        com.erp.webservice.server.auto.QueryCardState wrappedParam =
                                                             (com.erp.webservice.server.auto.QueryCardState)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.QueryCardState.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               queryCardStateResponse49 =
                                                   
                                                   
                                                         skel.queryCardState(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), queryCardStateResponse49, false);
                                    } else 

            if("qcxeedit".equals(methodName)){
                
                com.erp.webservice.server.auto.QcxeeditResponse qcxeeditResponse51 = null;
	                        com.erp.webservice.server.auto.Qcxeedit wrappedParam =
                                                             (com.erp.webservice.server.auto.Qcxeedit)fromOM(
                                    msgContext.getEnvelope().getBody().getFirstElement(),
                                    com.erp.webservice.server.auto.Qcxeedit.class,
                                    getEnvelopeNamespaces(msgContext.getEnvelope()));
                                                
                                               qcxeeditResponse51 =
                                                   
                                                   
                                                         skel.qcxeedit(wrappedParam)
                                                    ;
                                            
                                        envelope = toEnvelope(getSOAPFactory(msgContext), qcxeeditResponse51, false);
                                    
            } else {
              throw new java.lang.RuntimeException("method not found");
            }
        

        newMsgContext.setEnvelope(envelope);
        }
        }
        catch (java.lang.Exception e) {
        throw org.apache.axis2.AxisFault.makeFault(e);
        }
        }
        
        //
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.LjtoqbCharge param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.LjtoqbCharge.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.LjtoqbChargeResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.LjtoqbChargeResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.Czqrorcz param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.Czqrorcz.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.CzqrorczResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.CzqrorczResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.ReportLoss param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.ReportLoss.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.ReportLossResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.ReportLossResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.LoginValidate param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.LoginValidate.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.LoginValidateResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.LoginValidateResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.CheckMac param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.CheckMac.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.CheckMacResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.CheckMacResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.Charge param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.Charge.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.ChargeResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.ChargeResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.QueryBal param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.QueryBal.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.QueryBalResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.QueryBalResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.EarmarkCharge param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.EarmarkCharge.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.EarmarkChargeResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.EarmarkChargeResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.QueryTransDetail param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.QueryTransDetail.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.QueryTransDetailResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.QueryTransDetailResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.ModifyPwd param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.ModifyPwd.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.ModifyPwdResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.ModifyPwdResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.JudgePwd param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.JudgePwd.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.JudgePwdResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.JudgePwdResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.QueryCardState param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.QueryCardState.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.QueryCardStateResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.QueryCardStateResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.Qcxeedit param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.Qcxeedit.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
            private  org.apache.axiom.om.OMElement  toOM(com.erp.webservice.server.auto.QcxeeditResponse param, boolean optimizeContent)
            throws org.apache.axis2.AxisFault {

            
                        try{
                             return param.getOMElement(com.erp.webservice.server.auto.QcxeeditResponse.MY_QNAME,
                                          org.apache.axiom.om.OMAbstractFactory.getOMFactory());
                        } catch(org.apache.axis2.databinding.ADBException e){
                            throw org.apache.axis2.AxisFault.makeFault(e);
                        }
                    

            }
        
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.LjtoqbChargeResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.LjtoqbChargeResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.LjtoqbChargeResponse wrapljtoqbCharge(){
                                com.erp.webservice.server.auto.LjtoqbChargeResponse wrappedElement = new com.erp.webservice.server.auto.LjtoqbChargeResponse();
                                return wrappedElement;
                         }
                    
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.CzqrorczResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.CzqrorczResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.CzqrorczResponse wrapczqrorcz(){
                                com.erp.webservice.server.auto.CzqrorczResponse wrappedElement = new com.erp.webservice.server.auto.CzqrorczResponse();
                                return wrappedElement;
                         }
                    
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.ReportLossResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.ReportLossResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.ReportLossResponse wrapreportLoss(){
                                com.erp.webservice.server.auto.ReportLossResponse wrappedElement = new com.erp.webservice.server.auto.ReportLossResponse();
                                return wrappedElement;
                         }
                    
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.LoginValidateResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.LoginValidateResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.LoginValidateResponse wraploginValidate(){
                                com.erp.webservice.server.auto.LoginValidateResponse wrappedElement = new com.erp.webservice.server.auto.LoginValidateResponse();
                                return wrappedElement;
                         }
                    
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.CheckMacResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.CheckMacResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.CheckMacResponse wrapcheckMac(){
                                com.erp.webservice.server.auto.CheckMacResponse wrappedElement = new com.erp.webservice.server.auto.CheckMacResponse();
                                return wrappedElement;
                         }
                    
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.ChargeResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.ChargeResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.ChargeResponse wrapcharge(){
                                com.erp.webservice.server.auto.ChargeResponse wrappedElement = new com.erp.webservice.server.auto.ChargeResponse();
                                return wrappedElement;
                         }
                    
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.QueryBalResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.QueryBalResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.QueryBalResponse wrapqueryBal(){
                                com.erp.webservice.server.auto.QueryBalResponse wrappedElement = new com.erp.webservice.server.auto.QueryBalResponse();
                                return wrappedElement;
                         }
                    
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.EarmarkChargeResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.EarmarkChargeResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.EarmarkChargeResponse wrapearmarkCharge(){
                                com.erp.webservice.server.auto.EarmarkChargeResponse wrappedElement = new com.erp.webservice.server.auto.EarmarkChargeResponse();
                                return wrappedElement;
                         }
                    
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.QueryTransDetailResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.QueryTransDetailResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.QueryTransDetailResponse wrapqueryTransDetail(){
                                com.erp.webservice.server.auto.QueryTransDetailResponse wrappedElement = new com.erp.webservice.server.auto.QueryTransDetailResponse();
                                return wrappedElement;
                         }
                    
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.ModifyPwdResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.ModifyPwdResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.ModifyPwdResponse wrapmodifyPwd(){
                                com.erp.webservice.server.auto.ModifyPwdResponse wrappedElement = new com.erp.webservice.server.auto.ModifyPwdResponse();
                                return wrappedElement;
                         }
                    
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.JudgePwdResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.JudgePwdResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.JudgePwdResponse wrapjudgePwd(){
                                com.erp.webservice.server.auto.JudgePwdResponse wrappedElement = new com.erp.webservice.server.auto.JudgePwdResponse();
                                return wrappedElement;
                         }
                    
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.QueryCardStateResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.QueryCardStateResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.QueryCardStateResponse wrapqueryCardState(){
                                com.erp.webservice.server.auto.QueryCardStateResponse wrappedElement = new com.erp.webservice.server.auto.QueryCardStateResponse();
                                return wrappedElement;
                         }
                    
                    private  org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory, com.erp.webservice.server.auto.QcxeeditResponse param, boolean optimizeContent)
                        throws org.apache.axis2.AxisFault{
                      try{
                          org.apache.axiom.soap.SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
                           
                                    emptyEnvelope.getBody().addChild(param.getOMElement(com.erp.webservice.server.auto.QcxeeditResponse.MY_QNAME,factory));
                                

                         return emptyEnvelope;
                    } catch(org.apache.axis2.databinding.ADBException e){
                        throw org.apache.axis2.AxisFault.makeFault(e);
                    }
                    }
                    
                         private com.erp.webservice.server.auto.QcxeeditResponse wrapqcxeedit(){
                                com.erp.webservice.server.auto.QcxeeditResponse wrappedElement = new com.erp.webservice.server.auto.QcxeeditResponse();
                                return wrappedElement;
                         }
                    


        /**
        *  get the default envelope
        */
        private org.apache.axiom.soap.SOAPEnvelope toEnvelope(org.apache.axiom.soap.SOAPFactory factory){
        return factory.getDefaultEnvelope();
        }


        private  java.lang.Object fromOM(
        org.apache.axiom.om.OMElement param,
        java.lang.Class type,
        java.util.Map extraNamespaces) throws org.apache.axis2.AxisFault{

        try {
        
                if (com.erp.webservice.server.auto.LjtoqbCharge.class.equals(type)){
                
                           return com.erp.webservice.server.auto.LjtoqbCharge.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.LjtoqbChargeResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.LjtoqbChargeResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.Czqrorcz.class.equals(type)){
                
                           return com.erp.webservice.server.auto.Czqrorcz.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.CzqrorczResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.CzqrorczResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.ReportLoss.class.equals(type)){
                
                           return com.erp.webservice.server.auto.ReportLoss.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.ReportLossResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.ReportLossResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.LoginValidate.class.equals(type)){
                
                           return com.erp.webservice.server.auto.LoginValidate.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.LoginValidateResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.LoginValidateResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.CheckMac.class.equals(type)){
                
                           return com.erp.webservice.server.auto.CheckMac.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.CheckMacResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.CheckMacResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.Charge.class.equals(type)){
                
                           return com.erp.webservice.server.auto.Charge.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.ChargeResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.ChargeResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.QueryBal.class.equals(type)){
                
                           return com.erp.webservice.server.auto.QueryBal.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.QueryBalResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.QueryBalResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.EarmarkCharge.class.equals(type)){
                
                           return com.erp.webservice.server.auto.EarmarkCharge.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.EarmarkChargeResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.EarmarkChargeResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.QueryTransDetail.class.equals(type)){
                
                           return com.erp.webservice.server.auto.QueryTransDetail.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.QueryTransDetailResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.QueryTransDetailResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.ModifyPwd.class.equals(type)){
                
                           return com.erp.webservice.server.auto.ModifyPwd.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.ModifyPwdResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.ModifyPwdResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.JudgePwd.class.equals(type)){
                
                           return com.erp.webservice.server.auto.JudgePwd.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.JudgePwdResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.JudgePwdResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.QueryCardState.class.equals(type)){
                
                           return com.erp.webservice.server.auto.QueryCardState.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.QueryCardStateResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.QueryCardStateResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.Qcxeedit.class.equals(type)){
                
                           return com.erp.webservice.server.auto.Qcxeedit.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
                if (com.erp.webservice.server.auto.QcxeeditResponse.class.equals(type)){
                
                           return com.erp.webservice.server.auto.QcxeeditResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
                    

                }
           
        } catch (java.lang.Exception e) {
        throw org.apache.axis2.AxisFault.makeFault(e);
        }
           return null;
        }



    

        /**
        *  A utility method that copies the namepaces from the SOAPEnvelope
        */
        private java.util.Map getEnvelopeNamespaces(org.apache.axiom.soap.SOAPEnvelope env){
        java.util.Map returnMap = new java.util.HashMap();
        java.util.Iterator namespaceIterator = env.getAllDeclaredNamespaces();
        while (namespaceIterator.hasNext()) {
        org.apache.axiom.om.OMNamespace ns = (org.apache.axiom.om.OMNamespace) namespaceIterator.next();
        returnMap.put(ns.getPrefix(),ns.getNamespaceURI());
        }
        return returnMap;
        }

        private org.apache.axis2.AxisFault createAxisFault(java.lang.Exception e) {
        org.apache.axis2.AxisFault f;
        Throwable cause = e.getCause();
        if (cause != null) {
            f = new org.apache.axis2.AxisFault(e.getMessage(), cause);
        } else {
            f = new org.apache.axis2.AxisFault(e.getMessage());
        }

        return f;
    }

        }//end of class
    