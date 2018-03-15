package com.erp.task;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Component;

import com.erp.service.CardApplyService;

/**
 * @category 生成卡号处理
 * @author gecc
 * @version 1.0
 *
 */
@Component(value="createCardNoTask")
public class CreateCardNoTask {
	private static Logger logger = Logger.getLogger(CreateCardNoTask.class);
	@Resource(name="cardApplyService")
	private  CardApplyService cardApplyService;
	public void execute(){
		try {
	        cardApplyService.saveCardNoTask();
		} catch (Exception e) {
			logger.error(e.getMessage());
		}
	}
}
