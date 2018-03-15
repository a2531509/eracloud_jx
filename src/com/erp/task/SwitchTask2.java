package com.erp.task;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Component;

import com.erp.model.BaseRegion;
import com.erp.service.Switchservice;
import com.erp.util.Arith;
import com.erp.util.DateUtil;
import com.erp.util.DateUtils;
import com.erp.util.NumberUtil;
@Component(value="switchTask2")
public class SwitchTask2 {
	public static Log log = LogFactory.getLog(SwitchTask2.class);
	public static Logger logger = Logger.getLogger(SwitchTask2.class);
	@Resource(name="switchservice")
	public Switchservice switchservice;
	
	public void execute() {
		String starttime = System.currentTimeMillis() + "";
		DefaultFTPClient.writeLog("=========开始卡交易对账======");

		try {
			Calendar cal = Calendar.getInstance();
			cal.setTime(new Date());
			cal.add(Calendar.DAY_OF_MONTH, -1);
			Date date = cal.getTime();
			List<BaseRegion> regions = switchservice.findByHql("from BaseRegion where regionState = '0'");
			for (BaseRegion region : regions) {
				switchservice.sendCardNum2ST(region.getRegionId(), DateUtil.formatDate(date, "yyyyMMdd"));
			}
		} catch (Exception e) {
			DefaultFTPClient.writeLog("卡交易对账："+e.getMessage());
		}finally{
			String endtime = System.currentTimeMillis() + "";
			DefaultFTPClient.writeLog("=========结束卡交易对账======");
			logger.fatal("结束卡交易对账,耗费了" + NumberUtil.scale(Arith.div(Arith.sub(endtime,starttime),1000*60 + ""),3) + "分钟.");
		}
	}
}

