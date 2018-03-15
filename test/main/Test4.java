package main;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.List;

import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import com.erp.exception.CommonException;
import com.erp.model.BasePersonal;
import com.erp.model.SysActionLog;
import com.erp.service.TestService;
import com.erp.task.OfflineHlhtTask;

public class Test4 {
	

	@SuppressWarnings({ "unchecked", "resource" })
	public static void main(String[] args) {
		ApplicationContext ctx = new ClassPathXmlApplicationContext("classpath:spring.xml", "classpath:spring-hibernate.xml");
		TestService service = ctx.getBean(TestService.class);
		/*OfflineHlhtTask service = ctx.getBean(OfflineHlhtTask.class);
		//service.execute();
		service.p_SSNSQSFileRJS("2018-01-06");*/

		//service.saveHandleExcel();
		
		// 合作机构充值统计
		/*List<String> coOrgIdList = service.findBySql("select co_org_id from base_co_org t where t.co_state = '0'");
		for (String coOrgId : coOrgIdList) {
			service.saveStatCoOrgRchgStat(coOrgId, "2017-11-01", "2017-11-30");
		}*/
		
		// 网点充值统计
	/*	service.saveStatBrchRchgStat("2017-11-01", "2017-11-30");*/
		//发送9,参数是身份证号
		//service.saveCardUpateCardBankCardActive("");
		// 金额密文计算卡
		
		String encryptStr = service.encryptBal("31400510003119833137","400");
		System.out.println(encryptStr);
		
		
		
		// 卡发放(1)同步到 card_update, 参数为申领编号
		/*try {
			String [] certNo= {};
			for (int i = 0; i < certNo.length; i++) {
				String cert = certNo[i];
				String sql = "select apply_id from card_apply t where apply_state = '60' and exists (select * from base_personal where customer_id = t.customer_id and cert_no = '"+cert +"')";
				Object applyId = service.findOnlyFieldBySql(sql);
				if(applyId != null){
					service.saveCardUpateCardIssue(applyId.toString());
				}
			}
		} catch (CommonException e) {
			e.printStackTrace();
		}*/
		/*String sql = "select apply_id from card_apply"
					+" where apply_way = '0'"
					+"and is_urgent = '0'"
					+"and rels_date >= to_date('2017-10-01', 'yyyy-mm-dd')"
					+"and rels_date <= to_date('2017-12-25', 'yyyy-mm-dd')"
					+"and bank_id = '100003000000013'"
					+"and apply_state = '60'";
		int count = 0;
		List apply = service.findBySql(sql);
		for (Object object : apply) {
			service.saveCardUpateCardIssue(object.toString());
			count++;
		}
		System.out.println("总共发送(1)信息" + count + "条");*/
		
		
		
		/*service.saveCardUpateCardIssue("503882890");
		System.out.println("完成");*/
		/*String list [] = {""};
		for (int i = 0; i < list.length; i++) {
			SysActionLog log = service.getCurrentActionLog();
			service.deleteTask(list[i],log);
		}
		
		System.out.println("完成");*/
		
		
		//String [] certNo = {};
		/*String sql = "select cert_no from base_personal where customer_id in (select customer_id from card_apply where task_id = '2017062112187242')";
		List certNo = service.findBySql(sql);
		for (Object object : certNo) {
			System.out.println(object);
		}*/
		
		/*for (int i = 0; i < certNo.length; i++) {
			service.saveCardUpateCardCancel(certNo[i]);
		}
		System.out.println("完成");*/
		// 卡注销(6)同步到 card_update, 参数为证件号码
		/*String sql = "select cert_no from base_personal"
					+" where customer_id in (select customer_id from card_apply"
					+" where customer_id in(select customer_id from card_apply"
					+" where apply_way = '0'"
					+"and is_urgent = '0'"
					+"and rels_date >= to_date('2017-10-01', 'yyyy-mm-dd')"
					+"and rels_date <= to_date('2017-12-25', 'yyyy-mm-dd')"
					+"and bank_id = '100003000000013'"
					+"and apply_state = '60')"
					+"and card_type = '100')";
		int count = 0;
		List certNo = service.findBySql(sql);
		for (Object object : certNo) {
			service.saveCardUpateCardCancel(object.toString());
			count++;
		}
		System.out.println("总共发送注销信息" + count + "条");*/
		
		
		/*service.saveCardUpateCardCancel("330482199702102145");
		System.out.println("完成");*/
		
		/*service.saveOpenAcc("31400000002137024902");*/
	/*	try {
			int i = 0;
			String sql = "select cert_no from base_personal"
						+" where customer_id in(select customer_id from card_apply"
						+" where apply_way = '0'"
						+"and is_urgent = '0'"
						+"and rels_date >= to_date('2017-10-01', 'yyyy-mm-dd')"
						+"and rels_date <= to_date('2017-12-25', 'yyyy-mm-dd')"
						+"and bank_id = '100003000000013'"
						+"and apply_state = '60')";
			List certNo = service.findBySql(sql);
			for (Object object : certNo) {
				service.saveCardUpateCardBankCardActive(object.toString());
				i++;
			}
			System.out.println("总共发送(9)信息" + i + "条");
		} catch (CommonException e) {
			e.printStackTrace();
		}*/
		//service.saveCardUpateCardBankCardActive("232302195806101625");
		/*String [] certNo = {};
		for (int i = 0; i <certNo.length; i++) {
			service.saveCardUpateCardBankCardActive(certNo[i]);
		}*/
		/*String [] applyId = {};
		for (int i = 0; i <applyId.length; i++) {
			service.saveCardUpateCardIssue(applyId[i]);
		}*/
	}
}
