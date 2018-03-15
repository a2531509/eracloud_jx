package com.erp.task;

import java.util.List;

import javax.annotation.Resource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.erp.service.PgDataService;
import com.erp.service.Switchservice;
import com.erp.util.Arith;
import com.erp.util.NumberUtil;

/**
 * @category 省厅处理
 * @author gecc
 * @version 1.0
 *
 */
@Component(value="switchTask")
public class SwitchTask {
	public static Log log = LogFactory.getLog(SwitchTask.class);
	public static Logger logger = Logger.getLogger(SwitchTask.class);
	@Resource(name="switchservice")
	public Switchservice switchservice;
	@Autowired
	private PgDataService pgDataService;
	
	@SuppressWarnings("unchecked")
	public void execute() {
		log.debug("=========开始发送省厅数据======");
		// sendPerson
		String starttime = System.currentTimeMillis() + "";
		try {
			log.debug("开始发送省厅人员数据...");
			switchservice.savePersonInfo();
			log.debug("发送省厅人员数据成功");
		} catch (Exception e) {
			log.debug("发送省厅人员数据失败，" + e.getMessage());
		} finally {
			String endtime = System.currentTimeMillis() + "";
			logger.debug("发送省厅人员数据耗时 " + NumberUtil.scale(Arith.div(Arith.sub(endtime, starttime), 1000 * 60 + ""), 3) + " 分钟.");
		}
		// sendCard
		starttime = System.currentTimeMillis() + "";
		try {
			log.debug("开始发送省厅卡片数据...");
			switchservice.saveAddCardInfo();
			log.debug("发送省厅卡片数据成功");
		} catch (Exception e) {
			log.debug("发送省厅卡片数据失败，" + e.getMessage());
		}finally{
			String endtime = System.currentTimeMillis() + "";
			logger.fatal("发送省厅卡片数据耗时 " + NumberUtil.scale(Arith.div(Arith.sub(endtime,starttime),1000*60 + ""),3) + "分钟.");
		}
		// sendPhoto
		starttime = System.currentTimeMillis() + "";
		try {
			log.debug("开始发送省厅人员照片数据...");
			//switchservice.saveSendPhoto(); // 照片
			log.debug("发送省厅人员照片数据成功");
		} catch (Exception e) {
			log.debug("发送省厅人员照片数据失败，" + e.getMessage());
		} finally {
			String endtime = System.currentTimeMillis() + "";
			logger.fatal("发送省厅人员照片数据耗时 " + NumberUtil.scale(Arith.div(Arith.sub(endtime, starttime), 1000 * 60 + ""), 3) + "分钟.");
		}
		// reSendCard
		starttime = System.currentTimeMillis() + "";
		try {
			log.debug("开始发送省厅人员卡片重发数据...");
			List<String> certNoList = pgDataService.findBySql("select cert_no from (select * from resend_card_data t where state = '1' order by update_time desc) where rownum < 20000");
			for(String certNo : certNoList){
				try {
					pgDataService.reSendCard(certNo);
				} catch (Exception e) {
					pgDataService.removeReSendCard(certNo, e==null?"null":(e.getMessage()==null?"null":e.getMessage()));
				}
			}
			log.debug("发送省厅人员卡片重发数据成功");
		} catch (Exception e) {
			log.debug("发送省厅人员卡片重发数据失败，" + e.getMessage());
		} finally {
			String endtime = System.currentTimeMillis() + "";
			logger.fatal("发送省厅人员卡片重发数据耗时 " + NumberUtil.scale(Arith.div(Arith.sub(endtime, starttime), 1000 * 60 + ""), 3)
					+ "分钟.");
		}
		log.debug("=========发送省厅数据完毕======");
	}

}
