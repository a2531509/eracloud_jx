package com.erp.task;

import javax.annotation.Resource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Component;

import com.erp.service.CuteDayService;
import com.erp.service.OfflineDataService;
import com.erp.util.Arith;
import com.erp.util.NumberUtil;

/**
 * @category 日终处理
 * @author hujc
 * @version 1.0
 *
 */
@Component(value="cuteDayTask")
public class CuteDayTask {
	public static Log log = LogFactory.getLog(CuteDayTask.class);
	public static Logger logger = Logger.getLogger(CuteDayTask.class);
	@Resource(name="cuteDayService")
	public CuteDayService cuteDayService;
	@Resource(name="offlineDataService")
	public OfflineDataService offlineDataService;
	
	public void execute() {
		String starttime = System.currentTimeMillis() + "";
		DefaultFTPClient.writeLog("=========开始处理公交与自行车返回文件======");
		try {
			cuteDayService.persistenceCuteDay();
		} catch (Exception e) {
			DefaultFTPClient.writeLog("公交与自行车发生错误："+e.getMessage());
		}finally{
			String endtime = System.currentTimeMillis() + "";
			DefaultFTPClient.writeLog("=========结束开始处理公交与自行车返回文件处理======");
			logger.fatal("结束开始处理公交与自行车返回文件处理,耗费了" + NumberUtil.scale(Arith.div(Arith.sub(endtime,starttime),1000*60 + ""),3) + "分钟.");
		}
		
	
	}

	
	
}
