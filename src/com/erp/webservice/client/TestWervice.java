package com.erp.webservice.client;

import java.util.Scanner;


public class TestWervice {

	public static void main(String[] args) {
		try{
			for (int i=0; i<1;i++){
				
		     /*  AutoEquiWebserviceStub stub=new AutoEquiWebserviceStub();
				AutoEquiWebserviceStub.QueryBal ben=new AutoEquiWebserviceStub.QueryBal();
				//ben.setInXml("<?xml version='1.0' encoding='utf-8' ?><RequestBean><companyId>70108871</companyId><certNo>330423195709080067</certNo><pwd>123456</pwd><applyState>012</applyState></RequestBean>");
				ben.setInXml("<?xml version='1.0' encoding='utf-8' ?><RequestBean><cardNo>31400400006364501399</cardNo><certNo></certNo><accKind>2</accKind></RequestBean>");
				String  s=stub.queryBal(ben).get_return();
				 AutoEquiWebserviceStub stub=new AutoEquiWebserviceStub();
				AutoEquiWebserviceStub.LoginValidate ben1=new AutoEquiWebserviceStub.LoginValidate();
				ben1.setInXml("<?xml version='1.0' encoding='utf-8' ?><RequestBean><cardNo>31400400006364501399</cardNo><certNo></certNo><bizId>3</bizId><pwd>uiOzlh19NwM=</pwd><clientType>1</clientType></RequestBean>");
				String  s1=stub.loginValidate(ben1).get_return();*/
				
				NetAppOfSbServiceStub stub=new NetAppOfSbServiceStub();
				NetAppOfSbServiceStub.Execute execute=new NetAppOfSbServiceStub.Execute();
				execute.setParam0("1001");
				execute.setParam1("<RequestBean><companyId>994428</companyId><xmName>张政</xmName><certNo>330402196304011517</certNo><mobileNo>13645838123</mobileNo><sureFlag>0</sureFlag><letterAddr>�㽭ʡ�������л���·1882��</letterAddr></RequestBean> ");
				String  si=stub.execute(execute).get_return();
				System.out.println("sfsfsfsfsfdsdfsfdsdf============"+i+"dsfsdf"+si);
			}
		/*	NetAppOfSbServiceStub stub=new NetAppOfSbServiceStub();
			NetAppOfSbServiceStub.Execute execute=new NetAppOfSbServiceStub.Execute();
			execute.setTrcode("1006");
			execute.setInxml("<RequestBean><companyId>00011717</companyId><applyDate></applyDate><pCount>10</pCount><pageNo>1</pageNo></RequestBean> ");
			String  i=stub.execute(execute).get_return();
			System.out.println(i);*/
		}catch (Exception e) {
			e.printStackTrace();
		}

	}
}
