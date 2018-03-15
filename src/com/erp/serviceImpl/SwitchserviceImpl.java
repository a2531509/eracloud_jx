package com.erp.serviceImpl;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.math.BigDecimal;
import java.net.Socket;
import java.sql.Blob;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.log4j.Logger;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.service.Switchservice;
import com.erp.util.Base64;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.ResourceUtil;
import com.erp.util.Tools;

import edu.emory.mathcs.backport.java.util.Arrays;
@Service("switchservice")
public class SwitchserviceImpl  extends BaseServiceImpl  implements Switchservice {
	private static Logger logger = Logger.getLogger(SwitchserviceImpl.class);
	private final static int port = Integer.parseInt(ResourceUtil.getStInterfaceIPPort());// 正式库的端口是9008，，9008
	private final static String ipAddress = ResourceUtil.getStInterfaceIP();// 10.82.18.51

	/**
     * 发送个人信息
     */
	@SuppressWarnings({ "unchecked"})
	public void savePersonInfo() {
		try{
			List<Object[]> list = this.findBySql("select p.customer_id, p.name, p.cert_no, p.gender, substr(cert_no, 7, 8) from BASE_ST t, base_personal p "
					+ "where p.customer_id = t.customer_id and length(cert_no) = 18 and t.st_person_id is null and rownum <= 500");
			if (list == null || list.isEmpty()) {
				throw new CommonException("没有需要上传的人员信息");
			}
			// 循环发送
		    logger.debug("发送省厅人员信息开始，共 " + list.size() + " 条人员信息");
			for (int i = 0; i < list.size(); i++) {
				try {
					Object[] personData = (Object[]) list.get(i);
					logger.debug("第" + (i + 1) + "个，发送数据开始：" + Arrays.toString(personData));
					sendPersonData(personData);
					logger.debug("第" + (i + 1) + "个，发送数据完成");
				} catch (Exception e) {
					logger.error("第" + (i + 1) + "个，发送数据失败：" + e.getMessage());
				}
			}
			logger.debug("发送省厅人员信息完成");
		} catch (Exception ee) {
			logger.error("发送省厅人员信息失败，" + ee.getMessage());
			throw new CommonException("发送数据失败", ee);
		}
	}

    /**
     * 上传卡信息
     */
	@SuppressWarnings("unchecked")
	public void saveAddCardInfo() throws CommonException {
		try {
			List<Object[]> list = this.findBySql("select p.customer_id, p.name, p.cert_no, t.st_person_id, c.sub_card_no, c.sub_card_id, c.issue_date from BASE_ST t,base_personal p,card_baseinfo c where p.customer_id = t.customer_id and t.customer_id = c.customer_id and t.clbz = '0' and c.card_state <> '9' and card_type in ('100', '120') and t.card_clbz <> '0' and t.card_clbz <> '9999' and length(c.sub_card_id) = 32 and rownum <= 500");
			if (list == null || list.isEmpty()) {
				throw new CommonException("没有需要上传的卡信息");
			}
			logger.debug("发送省厅卡信息开始，共 " + list.size() + " 条卡信息");
			for (int i = 0; i < list.size(); i++) {
				try {
					Object[] cardData = (Object[]) list.get(i);
					logger.debug("第" + (i + 1) + "个，发送数据开始：" + Arrays.toString(cardData));
					sendCardData(cardData);
					logger.debug("第" + (i + 1) + "个，发送数据完成");
				} catch (Exception e) {
					logger.error("第" + (i + 1) + "个，发送数据失败：" + e.getMessage());
				}
			}
			logger.debug("发送省厅卡信息完成");
		} catch (Exception ee) {
			logger.error("发送省厅卡信息失败，" + ee.getMessage());
			throw new CommonException("上传卡信息出错" + ee.getMessage());
		}
	}
	
	/**
	 * 正式
	 * @param code
	 * @return
	 */
	public String getZsTAC(String code){
		String tacs="";
		//7004	卡新增	315B4DF935F4775EF5033A4833A9E0E1
		//7005	卡状态变更	F514CEC81CB148559CF475E7426EED5E
		//7010	照片指纹上传	281715CAFA675BF359EBAA42CB44FA17
		//7015	社保卡鉴权	885FE656777008C335AC96072A45BE15
		//7017	卡查询	E9A53D0ED1816293EF24647C7B33D819
		//7020	卡信息补全	35A12C43227F217207D4E06FFEFE39D3
		//7026	社保卡鉴权及交易认证	5DCA4C6B9E244D24A30B4C45601D9720
		//7027	社保卡结算及交易认证	313F422AC583444BA6045CD122653B0E
		//7030	卡片统筹区变更	B25B911FFC2B76A647454E5A53EDF8B5
		if(!Tools.processNull(code).equals("7004")){
			tacs="315B4DF935F4775EF5033A4833A9E0E1";
		}else if(!Tools.processNull(code).equals("7005")){
			tacs="F514CEC81CB148559CF475E7426EED5E";
		}else if(!Tools.processNull(code).equals("7010")){
			tacs="281715CAFA675BF359EBAA42CB44FA17";
		}else if(!Tools.processNull(code).equals("7015")){
			tacs="885FE656777008C335AC96072A45BE15";
		}else if(!Tools.processNull(code).equals("7017")){
			tacs="E9A53D0ED1816293EF24647C7B33D819";
		}else if(!Tools.processNull(code).equals("7020")){
			tacs="35A12C43227F217207D4E06FFEFE39D3";
		}else if(!Tools.processNull(code).equals("7026")){
			tacs="5DCA4C6B9E244D24A30B4C45601D9720";
		}else if(!Tools.processNull(code).equals("7027")){
			tacs="313F422AC583444BA6045CD122653B0E";
		}else if(!Tools.processNull(code).equals("7030")){
			tacs="B25B911FFC2B76A647454E5A53EDF8B5";
		}

		return tacs;
	}
	
	/**
	 * 测试
	 * @param code
	 * @return
	 */
	public String getCsTAC(String code){
		//7004	卡新增	315B4DF935F4775EF5033A4833A9E0E1CSK
		//7005	卡状态变更	F514CEC81CB148559CF475E7426EED5ECSK
		//7010	照片指纹上传	281715CAFA675BF359EBAA42CB44FA17CSK
		//7015	社保卡鉴权	885FE656777008C335AC96072A45BE15CSK
		//7017	卡查询	E9A53D0ED1816293EF24647C7B33D819CSK
		//7020	卡信息补全	35A12C43227F217207D4E06FFEFE39D3CSK
		//7026	社保卡鉴权及交易认证	5DCA4C6B9E244D24A30B4C45601D9720CSK
		//7027	社保卡结算及交易认证	313F422AC583444BA6045CD122653B0ECSK
		//7030	卡片统筹区变更	B25B911FFC2B76A647454E5A53EDF8B5CSK

		String tacs="";
		if(!Tools.processNull(code).equals("7004")){
			tacs="315B4DF935F4775EF5033A4833A9E0E1CSK";
		}else if(!Tools.processNull(code).equals("7005")){
			tacs="F514CEC81CB148559CF475E7426EED5ECSK";
		}else if(!Tools.processNull(code).equals("7010")){
			tacs="281715CAFA675BF359EBAA42CB44FA17CSK";
		}else if(!Tools.processNull(code).equals("7015")){
			tacs="885FE656777008C335AC96072A45BE15CSK";
		}else if(!Tools.processNull(code).equals("7017")){
			tacs="E9A53D0ED1816293EF24647C7B33D819CSK";
		}else if(!Tools.processNull(code).equals("7020")){
			tacs="35A12C43227F217207D4E06FFEFE39D3CSK";
		}else if(!Tools.processNull(code).equals("7026")){
			tacs="5DCA4C6B9E244D24A30B4C45601D9720CSK";
		}else if(!Tools.processNull(code).equals("7027")){
			tacs="313F422AC583444BA6045CD122653B0ECSK";
		}else if(!Tools.processNull(code).equals("7030")){
			tacs="B25B911FFC2B76A647454E5A53EDF8B5CSK";
		}

		return tacs;
	}
  public String cardStateToSTstate(String cardstate){
		//1新发卡，2补卡，3换卡，4挂失，5解挂，6注销，9银行卡激活状态
		//0	封存	1正常 2挂失	3应用锁定 4临时挂失	9注销
	    String STstate="";
		if(!Tools.processNull(cardstate).equals("1")){
			STstate="1";
		}else if(!Tools.processNull(cardstate).equals("2")){
			STstate="1";
		}else if(!Tools.processNull(cardstate).equals("3")){
			STstate="1";
		}else if(!Tools.processNull(cardstate).equals("4")){
			STstate="2";
		}else if(!Tools.processNull(cardstate).equals("5")){
			STstate="1";
		}else if(!Tools.processNull(cardstate).equals("6")){
			STstate="9";
		}
	  
	  return STstate;
	}
  
	/**
	 * @author Yueh
	 */
	@Override
	public void sendPersonData(String certNo) {
		try {
			if (certNo == null || certNo.equals("")) {
				throw new CommonException("证件号码为空！");
			} else if (certNo.length() != 18) {
				throw new CommonException("证件号码不是身份证号码！");
			}
			BigDecimal count = (BigDecimal) findOnlyFieldBySql("select count(1) from base_st t where exists (select 1 from base_personal where customer_id = t.customer_id and cert_no = '" + certNo + "')");
			if (count.compareTo(BigDecimal.ZERO) <= 0) {
				publicDao.doSql("insert into base_st(customer_id, st_person_id, clbz, card_clbz, card_state, photo_state) select customer_id,'','1','1','1','1' from base_personal where cert_no = '" + certNo + "'");
			}
			Object[] personData = (Object[]) findOnlyRowBySql("select p.customer_id, p.name, p.cert_no, p.gender, substr(cert_no, 7, 8), t.clbz, t.st_person_id from BASE_ST t, base_personal p where p.customer_id = t.customer_id and p.cert_no = '" + certNo + "'");
			if(personData == null) {
				throw new CommonException("未找到人员数据！");
			}/* else if ("0".equals(personData[5].toString()) && personData[6] != null && personData[6].toString().length() > 0) {
				throw new CommonException("人员信息已发送！");
			}*/
			sendPersonData(personData);
		} catch (Exception e) {
			throw new CommonException("发送人员失败，" + e.getMessage());
		}
	}

	/**
	 * @author Yueh
	 */
	@Override
	public void sendCardData(String certNo) {
		try {
			if (certNo == null || certNo.equals("")) {
				throw new CommonException("证件号码为空！");
			} else if (certNo.length() != 18) {
				throw new CommonException("证件号码不是身份证号码！");
			}
			Object[] cardData = (Object[]) findOnlyRowBySql("select p.customer_id, p.name, p.cert_no, decode(t.st_person_id, '9999', '', t.st_person_id), c.sub_card_no, c.sub_card_id, c.issue_date, t.clbz, t.card_clbz "
					+ "from BASE_ST t join base_personal p on p.customer_id = t.customer_id left join card_baseinfo c on t.customer_id = c.customer_id "
					+ "where c.card_state <> '9' and c.card_type in ('100', '120') and p.cert_no = '" + certNo + "'");
			if(cardData == null) {
				throw new CommonException("未找到人员数据！");
			} else if ("1".equals(cardData[7].toString())) { // 人员未发送
				throw new CommonException("人员数据未发送省厅！");
			} else if (cardData[4] == null || "".equals(cardData[4].toString())) {
				throw new CommonException("该人员卡片信息不存在！");
			}
			sendCardData(cardData);
		} catch (Exception e) {
			throw new CommonException("发送卡片失败，" + e.getMessage());
		}
	}

	/**
	 * @author Yueh
	 */
	@Override
	public Map<String, String> getCard(String certNo) {
		try {
			if (Tools.processNull(certNo).equals("")) {
				throw new CommonException("证件号码不能为空！");
			}
			Object[] personData = (Object[]) findOnlyRowBySql("select t2.st_person_id, t.cert_no, t.name from base_personal t left join base_st t2 on t.customer_id = t2.customer_id where t.cert_no = '" + certNo + "'");
			if (personData == null) {
				throw new CommonException("卡管不存在该人员信息！");
			}
			return getCard((String)personData[0], (String)personData[1], (String)personData[2], null, null, null);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}

	/**
	 * @author Yueh
	 */
	@Override
	public Map<String, String> getCard(String subCardNo, String regionId, String subCardId) {
		try {
			if(Tools.processNull(subCardNo).equals("") || Tools.processNull(regionId).equals("")){
				throw new CommonException("【社保卡号】和【区域】不能为空！");
			}
			return getCard(null, null, null, subCardNo, regionId, subCardId);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	
	/**
	 * @author Yueh
	 */
	@Override
	public Map<String, String> getCard(String certNo, String subCardNo, String regionId, String subCardId) {
		try {
			String personId = "";
			String name = "";
			if (!Tools.processNull(certNo).equals("")) {
				Object[] personData = (Object[]) findOnlyRowBySql("select t2.st_person_id, t.cert_no, t.name from base_personal t left join base_st t2 on t.customer_id = t2.customer_id where t.cert_no = '" + certNo + "'");
				if (personData != null) {
					personId = (String)personData[0];
					name = (String)personData[2];
				}
			}
			Map<String, String> pgCard = getCard(personId, certNo, name, subCardNo, regionId, subCardId);
			
			//
			Object[] card = (Object[]) findOnlyRowBySql("select t.cert_no, t2.sub_card_no, t2.sub_card_id, t2.card_no, t.customer_id from base_personal t join card_baseinfo t2 on t.customer_id = t2.customer_id where t.cert_no = '" + certNo + "' and t2.card_type in ('100','120') and t2.card_state = '1'");
			if (card != null && card.length > 0) {
				String customerId = (String) card[4];
				String subCardId2 = (String) card[2];
				if (pgCard.get("subCardId").equals(subCardId2)) { // 卡识别码相同
					publicDao.doSql("update base_st t set card_clbz = '0', clbz = '0', st_person_id = '" + pgCard.get("stPersonId") + "', card_clsj = sysdate, note = '" + DateUtil.formatDate(new Date()) + "，获取省厅数据一致' where t.customer_id = '" + customerId + "'");
				}
			}
			
			//
			return pgCard;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public void updateCardState(String cardNo, String cardStateBeforeChange, String cardStateAfterChange) {
		try {
			if (Tools.processNull(cardNo).equals("")) {
				throw new CommonException("卡号不能为空！");
			} else if (Tools.processNull(cardStateBeforeChange).equals("")) {
				throw new CommonException("原【卡状态】不能为空！");
			}
			Object[] cardData = (Object[]) findOnlyRowBySql("select t.sub_card_no, t.sub_card_id, t2.st_person_id, t.card_state, t3.customer_id, t3.cert_no, t2.clbz "
					+ "from card_baseinfo t join base_st t2 on t.customer_id = t2.customer_id join base_personal t3 on t.customer_id = t3.customer_id where card_no = '" + cardNo + "'");
			if (cardData == null) {
				throw new CommonException("卡片信息不存在！");
			} else if (cardData[2] == null || !cardData[6].equals("0")) {
				throw new CommonException("人员未发送省厅！");
			} else if (Tools.processNull(cardStateAfterChange).equals("")) {
				cardStateAfterChange = (String) cardData[3];
			}
			updateCardState((String)cardData[0], (String)cardData[1], (String)cardData[2], ((String)cardData[1]).substring(0, 6), DateUtil.formatDate(new Date(), "yyyyMMddHHmmss"), cardStateBeforeChange, cardStateAfterChange);
			//
			SysActionLog log = (SysActionLog) BeanUtils.cloneBean(getCurrentActionLog());
			log.setDealCode(DealCode.UPDATE_ST_CARD_STATE);
			log.setMessage("省厅卡状态变更【原状态" + cardStateBeforeChange + "，新状态：" + cardStateAfterChange + "】");
			publicDao.save(log);
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setClrDate(getClrDate());
			rec.setCardNo(cardNo);
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setCustomerId((String) cardData[4]);
			rec.setCertNo((String) cardData[5]);
			rec.setRsvFive(cardStateAfterChange);
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}
	
	@Override
	public SysActionLog getCurrentActionLog() throws CommonException {
		SysActionLog log = new SysActionLog();
		log.setBrchId("10010001");
		log.setUserId("admin");
		log.setDealCode(99999999);
		log.setOrgId("1001");
		log.setDealTime(new Date());
		
		return log;
	}
	
	@SuppressWarnings("unchecked")
	@Override
	public void updateMedWholeNo(String cardNo, String oldRegionId, String newRegionId) {
		try {
			if (Tools.processNull(cardNo).equals("")) {
				throw new CommonException("证件号码不能为空！");
			} else if (Tools.processNull(oldRegionId).equals("")) {
				throw new CommonException("原统筹区不能为空！");
			}
			// 获取本地卡信息
			Object[] newCardData = (Object[]) findOnlyRowBySql("select t3.st_person_id, t2.sub_card_no, t2.sub_card_id, t2.card_state, t4.customer_id, t4.cert_no "
					+ "from card_baseinfo t2 left join base_st t3 on t2.customer_id = t3.customer_id left join base_personal t4 on t2.customer_id = t4.customer_id where t2.card_no = '" + cardNo + "'");
			if (newCardData == null) {
				throw new CommonException("卡片数据不存在！");
			} else if (!Tools.processNull(newCardData[3]).equals(Constants.CARD_STATE_ZC)){
				throw new CommonException("卡片状态不正常！");
			} else if (Tools.processNull(newCardData[0]).equals("")) {
				throw new CommonException("人员数据未发送省厅！");
			} else if (Tools.processNull(newRegionId).equals("")) {
				newRegionId = newCardData[2].toString().substring(0, 6);
			}
			// 发送省厅卡状态变更
			updateMedWholeNo(newCardData[1].toString(), oldRegionId + newCardData[2].toString().substring(6), newCardData[0].toString(), oldRegionId, DateUtil.formatDate(new Date(), "yyyyMMddHHmmss"), newCardData[1].toString(), newCardData[2].toString(), newRegionId);
			//
			SysActionLog log = (SysActionLog) BeanUtils.cloneBean(getCurrentActionLog());
			log.setDealCode(DealCode.UPDATE_ST_CARD_MED_WHOLE_NO);
			log.setMessage("省厅卡统筹区变更【新：" + newRegionId + "，旧：" + oldRegionId + "】");
			publicDao.save(log);
			TrServRec rec = new TrServRec(log.getDealNo(), log.getDealTime(), log.getUserId());
			rec.setClrDate(getClrDate());
			rec.setCardNo(cardNo);
			rec.setBrchId(log.getBrchId());
			rec.setNote(log.getMessage());
			rec.setDealCode(log.getDealCode());
			rec.setCustomerId((String) newCardData[4]);
			rec.setCertNo((String) newCardData[5]);
			publicDao.save(rec);
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		}
	}

	// private methods
	/**
	 * @author Yueh
	 * @param personData
	 */
	private void sendPersonData(Object[] personData) {
		Socket clientSocket = null;
		DataInputStream dataIS = null;
		InputStreamReader inSR = null;
		DataOutputStream dataOS = null;
		OutputStreamWriter outSW = null;
		try {
			String date = DateUtil.formatDate(new Date(), "yyyyMMdd");
			// data
			String trsernos = "330400501" + date + Tools.tensileString("" + this.getSequenceByName("SEQ_SWITCH_SERVICE"), 9, true, "0");
			String sendstr = "####0010|6020|330400501|AC2A728F9F17B5D860B6DABD80A5162F|" + trsernos + "|admin|"
					+ DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss") + "|"
					+ DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss") + "|0~679578~330400~"
					+ personData[2].toString() + "~01~" + personData[2].toString() + "~~CHN~" + personData[1].toString() + "~"
					+ personData[3].toString() + "~01~~~" + personData[4].toString()
					+ "~~~330400~11~~~~330400~批量上传~~~~~~~1~~~0~$$$$";
			logger.debug("发送数据：" + sendstr);
			
			// send
			clientSocket = new Socket(ipAddress, port);
			dataIS = new DataInputStream(clientSocket.getInputStream());
			inSR = new InputStreamReader(dataIS, "GBK");
			BufferedReader br = new BufferedReader(inSR);
			dataOS = new DataOutputStream(clientSocket.getOutputStream());
			outSW = new OutputStreamWriter(dataOS, "GBK");
			BufferedWriter bw = new BufferedWriter(outSW);
			bw.write(sendstr);
			bw.flush();
			// 接收数据
			String resps = null;
			while ((resps = br.readLine()) != null) {
				resps = resps.trim();
				logger.debug("服务器回复：" + resps);
				break;
			}
			
			// parse message
			if(!resps.startsWith("####") || !resps.endsWith("$$$$")) {
				throw new CommonException("服务器返回报文格式错误，返回报文：" + resps);
			}
			resps = resps.replaceAll("####|\\$\\$\\$\\$", "");
			// 1.head
			String[] respHead = resps.substring(0, resps.indexOf("~")).split("\\|");
			if(respHead.length != 11){
				throw new CommonException("服务器返回【报文头】格式错误，返回报文：" + resps);
			}
			// 2.body
			String[] respBody =resps.substring(resps.indexOf("~") + 1).split("~", 7);
			if(respBody.length != 7){
				throw new CommonException("服务器返回【报文体】格式错误，返回报文：" + resps);
			}
			
			// handle
			String flag = respHead[8];
			if (flag.equals("0")) { // 0：交易成功，业务成功,1：交易成功，业务失败,2：交易成功，查询无记录,3：交易成功，数据由勘误变成正常,6：交易成功，公安库比对不通过,7：交易成功，公安库网络异常,8：交易成功，业务需勘误等待,9：交易成功，业务需会商等待,-1：交易失败，其他,-4：交易失败，超时,-108：交易失败，断网
				publicDao.doSql("update base_st t set t.st_person_id='" + respBody[3] + "', clbz='0', clsj=sysdate, note='" + respHead[10] + "' where t.customer_id='" + personData[0] + "'");
			} else {
				String errMsg = "发送人员信息，交易结果：【" + flag + "】 - ";
				if (flag.equals("1")) {
					errMsg += "交易成功，业务失败";
				} else if (flag.equals("2")) {
					errMsg += "交易成功，查询无记录";
				} else if (flag.equals("3")) {
					errMsg += "交易成功，数据由勘误变成正常";
				} else if (flag.equals("6")) {
					errMsg += "交易成功，公安库比对不通过";
				} else if (flag.equals("7")) {
					errMsg += "交易成功，公安库网络异常";
				} else if (flag.equals("8")) {
					errMsg += "交易成功，业务需勘误等待";
				} else if (flag.equals("9")) {
					errMsg += "交易成功，业务需会商等待";
				} else if (flag.equals("-1")) {
					errMsg += "交易失败，其他";
				} else if (flag.equals("-4")) {
					errMsg += "交易失败，超时";
				} else if (flag.equals("-108")) {
					errMsg += "交易失败，断网";
				} else {
					errMsg += "未定义返回码[" + flag + "]";
				}
				errMsg += "；错误信息：【" + respHead[9] + "】 - " + respHead[10];
				throw new CommonException(errMsg);
			}
		} catch (Exception e) {
			publicDao.doSql("update base_st t set t.st_person_id='9999', clbz='9', clsj=sysdate, note='" + e.getMessage() + "' where t.customer_id='" + personData[0].toString() + "'");
			throw new CommonException(e.getMessage());
		} finally {
			publicDao.doSql("commit");
			try {
				if (inSR != null) {
					inSR.close();
				}
				if (dataIS != null) {
					dataIS.close();
				}
				if (dataOS != null) {
					dataOS.close();
				}
				if (outSW != null) {
					outSW.close();
				}
				if (clientSocket != null) {
					clientSocket.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	/**
	 * @author Yueh
	 * @param cardData
	 */
	private void sendCardData(Object[] cardData) {
		Socket clientSocket = null;
		DataInputStream dataIS = null;
		InputStreamReader inSR = null;
		DataOutputStream dataOS = null;
		OutputStreamWriter outSW = null;
		try {
			String spPersonFlag = "0";
			String spPerson = "";
			if (Tools.processNull(cardData[3]).equals("")) { // 人员id没有
				cardData[3] = "";
				spPersonFlag = "1";
				spPerson = "勘误人员";
			}
			// data
			String date1 = DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss");
			String date2 = DateUtil.formatDate(new Date(), "yyyyMMdd");
			String trsernos = "330400501" + date2 + Tools.tensileString("" + this.getSequenceByName("SEQ_SWITCH_SERVICE"), 9, true, "0");
			String sendstr = "####0010|7004|330400501|315B4DF935F4775EF5033A4833A9E0E1|" + trsernos + "|admin|"
					+ date1 + "|" + date1 + "|0~" + cardData[4].toString() + "~" + cardData[5].toString()
					+ "~" + cardData[5].toString().substring(0, 6) + "~" + cardData[5].toString().substring(6, 32) + "~" + cardData[6].toString()
					+ "~20251231~1~~~" + cardData[3].toString() + "~" + cardData[2].toString() + "~"
					+ cardData[1].toString() + "~" + spPersonFlag + "~" + spPerson + "~1.0X~330400501~3~0~11330100_2016090101~3~" + cardData[6].toString()
					+ "~" + cardData[6].toString() + "~1.0~91560000023310003301007B~" + cardData[6].toString()
					+ "~无卡商$$$$";
			
			// send
			logger.debug("发送数据 ：" + sendstr);
			clientSocket = new Socket(ipAddress, port);
			dataIS = new DataInputStream(clientSocket.getInputStream());
			inSR = new InputStreamReader(dataIS, "GBK");
			BufferedReader br = new BufferedReader(inSR);
			dataOS = new DataOutputStream(clientSocket.getOutputStream());
			outSW = new OutputStreamWriter(dataOS, "GBK");
			BufferedWriter bw = new BufferedWriter(outSW);
			bw.write(sendstr); // 加上分行符，以便服务器按行读取
			bw.flush();
			// 接收数据
			String resps = null;
			while ((resps = br.readLine()) != null) {
				resps = resps.trim();
				logger.debug("服务器回复：" + resps);
				break;
			}

			// parse message
			if(!resps.startsWith("####") || !resps.endsWith("$$$$")) {
				throw new CommonException("服务器返回报文格式错误，返回报文：" + resps);
			}
			resps = resps.replaceAll("####|\\$\\$\\$\\$", "");
			// 1.head
			String[] respHead = resps.substring(0, resps.indexOf("~")).split("\\|");
			if (respHead.length != 11) {
				throw new CommonException("服务器返回【报文头】格式错误，返回报文：" + resps);
			}
			// 2.body
			String[] respBody = resps.substring(resps.indexOf("~") + 1).split("~", 2);
			if (respBody.length != 2) {
				throw new CommonException("服务器返回【报文体】格式错误，返回报文：" + resps);
			}

			// handle
			String flag = respHead[8];
			if (flag.equals("0")) { // 0：交易成功，业务成功,1：交易成功，业务失败,2：交易成功，查询无记录,3：交易成功，数据由勘误变成正常,6：交易成功，公安库比对不通过,7：交易成功，公安库网络异常,8：交易成功，业务需勘误等待,9：交易成功，业务需会商等待,-1：交易失败，其他,-4：交易失败，超时,-108：交易失败，断网
				publicDao.doSql("update base_st t set card_clbz = '0', clbz = '0', st_person_id = decode(st_person_id, '9999', '', st_person_id), clsj=sysdate, card_clsj = sysdate, note = '" + respHead[10] + "' where t.customer_id = '" + cardData[0] + "'");
				publicDao.doSql("insert into base_st_upload (SUB_CARD_NO, SUB_CARD_ID, SEND_DATE, SEND_TYPE, ST_PERSON_ID, CERT_NO, NAME, REGION_ID, CARD_STATE) "
						+ "values ('" + cardData[4] + "', '" + cardData[5] + "', '" + date2 + "', '1', '" + cardData[3] + "', '" + cardData[2] + "', '" + cardData[1] + "', '" + cardData[5].toString().substring(0, 6) + "', '1')");
			} else {
				String errMsg = "发送卡信息，交易结果：【" + flag + "】 - ";
				if (flag.equals("1")) {
					errMsg += "交易成功，业务失败";
				} else if (flag.equals("2")) {
					errMsg += "交易成功，查询无记录";
				} else if (flag.equals("3")) {
					errMsg += "交易成功，数据由勘误变成正常";
				} else if (flag.equals("6")) {
					errMsg += "交易成功，公安库比对不通过";
				} else if (flag.equals("7")) {
					errMsg += "交易成功，公安库网络异常";
				} else if (flag.equals("8")) {
					errMsg += "交易成功，业务需勘误等待";
				} else if (flag.equals("9")) {
					errMsg += "交易成功，业务需会商等待";
				} else if (flag.equals("-1")) {
					errMsg += "交易失败，其他";
				} else if (flag.equals("-4")) {
					errMsg += "交易失败，超时";
				} else if (flag.equals("-108")) {
					errMsg += "交易失败，断网";
				} else {
					errMsg += "未定义返回码[" + flag + "]";
				}
				errMsg += "；错误信息：【" + respHead[9] + "】 - " + respHead[10];
				throw new CommonException(errMsg);
			}
		} catch (Exception e) {
			publicDao.doSql("update base_st t set card_clbz = '9999', clsj=sysdate, note = '" + e.getMessage() + "' where t.customer_id = '" + cardData[0] + "'");
			throw new CommonException(e.getMessage());
		} finally {
			publicDao.doSql("commit");
			try {
				if (inSR != null) {
					inSR.close();
				}
				if (dataIS != null) {
					dataIS.close();
				}
				if (dataOS != null) {
					dataOS.close();
				}
				if (outSW != null) {
					outSW.close();
				}
				if (clientSocket != null) {
					clientSocket.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	/**
	 * @author Yueh
	 * @param personId
	 * @param certNo
	 * @param name
	 * @param subCardNo
	 * @param regionId
	 * @param subCardId
	 * @return
	 */
	private Map<String, String> getCard(String personId, String certNo, String name, String subCardNo, String regionId, String subCardId) {
		Socket clientSocket = null;
		DataInputStream dataIS = null;
		InputStreamReader inSR = null;
		DataOutputStream dataOS = null;
		OutputStreamWriter outSW = null;
		try {
			personId = personId == null ? "" : personId.trim();
			certNo = certNo == null ? "" : certNo.trim();
			name = name == null ? "" : name.trim();
			subCardNo = subCardNo == null ? "" : subCardNo.trim();
			regionId = regionId == null ? "" : regionId.trim();
			subCardId = subCardId == null ? "" : subCardId.trim();
			//
			Map<String, String> result = new HashMap<String, String>();
			// data
			String date1 = DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss");
			String date2 = DateUtil.formatDate(new Date(), "yyyyMMdd");
			String trsernos = "330400501" + date2 + Tools.tensileString("" + this.getSequenceByName("SEQ_SWITCH_SERVICE"), 9, true, "0");
			String sendstr = "####0010|7017|330400501|E9A53D0ED1816293EF24647C7B33D819|" + trsernos + "|admin|"
					+ date1 + "|" + date1 + "|0~0~" + personId + "~" + certNo + "~" + name + "~" + subCardNo + "~" + regionId + "~" + subCardId + "$$$$";
			
			// send
			logger.debug("发送数据 ：" + sendstr);
			clientSocket = new Socket(ipAddress, port);
			dataIS = new DataInputStream(clientSocket.getInputStream());
			inSR = new InputStreamReader(dataIS, "GBK");
			BufferedReader br = new BufferedReader(inSR);
			dataOS = new DataOutputStream(clientSocket.getOutputStream());
			outSW = new OutputStreamWriter(dataOS, "GBK");
			BufferedWriter bw = new BufferedWriter(outSW);
			bw.write(sendstr); // 加上分行符，以便服务器按行读取
			bw.flush();
			// 接收数据
			String resps = null;
			while ((resps = br.readLine()) != null) {
				resps = resps.trim();
				logger.debug("服务器回复：" + resps);
				break;
			}

			// parse message
			if(!resps.startsWith("####") || !resps.endsWith("$$$$")) {
				throw new CommonException("服务器返回报文格式错误，返回报文：" + resps);
			}
			resps = resps.replaceAll("####|\\$\\$\\$\\$", "");
			// 1.head
			String[] respHead = resps.substring(0, resps.indexOf("~")).split("\\|", 11);
			if (respHead.length != 11) {
				throw new CommonException("服务器返回【报文头】格式错误，返回报文：" + resps);
			}
			// 2.body
			String[] respBody = resps.substring(resps.indexOf("~") + 1).split("~", 15);
			if (respBody.length != 15) {
				throw new CommonException("服务器返回【报文体】格式错误，返回报文：" + resps);
			}

			// handle
			String flag = respHead[8];
			if (flag.equals("0")) { // 0：交易成功，业务成功,1：交易成功，业务失败,2：交易成功，查询无记录,3：交易成功，数据由勘误变成正常,6：交易成功，公安库比对不通过,7：交易成功，公安库网络异常,8：交易成功，业务需勘误等待,9：交易成功，业务需会商等待,-1：交易失败，其他,-4：交易失败，超时,-108：交易失败，断网
				// success
				result.put("subCardInfoId", respBody[0]);
				result.put("stPersonId", respBody[1]);
				result.put("subCardNo", respBody[2]);
				result.put("subCardId", respBody[3]);
				result.put("atr", respBody[4]);
				result.put("cardIssueDate", respBody[5]);
				result.put("certValidDate", respBody[6]);
				result.put("cardAppState", respBody[7]);
				result.put("bankId", respBody[8]);
				result.put("bankCardNo", respBody[9]);
				result.put("regionId", respBody[10]);
				result.put("name", respBody[11]);
				result.put("certNo", respBody[12]);
				result.put("cardVersion", respBody[13]);
				result.put("cardStdVersion", respBody[14]);
			} else {
				String errMsg = "交易结果：【" + flag + "】 - ";
				if (flag.equals("1")) {
					errMsg += "交易成功，业务失败";
				} else if (flag.equals("2")) {
					errMsg += "交易成功，查询无记录";
				} else if (flag.equals("3")) {
					errMsg += "交易成功，数据由勘误变成正常";
				} else if (flag.equals("6")) {
					errMsg += "交易成功，公安库比对不通过";
				} else if (flag.equals("7")) {
					errMsg += "交易成功，公安库网络异常";
				} else if (flag.equals("8")) {
					errMsg += "交易成功，业务需勘误等待";
				} else if (flag.equals("9")) {
					errMsg += "交易成功，业务需会商等待";
				} else if (flag.equals("-1")) {
					errMsg += "交易失败，其他";
				} else if (flag.equals("-4")) {
					errMsg += "交易失败，超时";
				} else if (flag.equals("-108")) {
					errMsg += "交易失败，断网";
				} else {
					errMsg += "未定义返回码[" + flag + "]";
				}
				errMsg += "；错误信息：【" + respHead[9] + "】 - " + respHead[10];
				throw new CommonException(errMsg);
			}
			
			return result;
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		} finally {
			try {
				if (inSR != null) {
					inSR.close();
				}
				if (dataIS != null) {
					dataIS.close();
				}
				if (dataOS != null) {
					dataOS.close();
				}
				if (outSW != null) {
					outSW.close();
				}
				if (clientSocket != null) {
					clientSocket.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	private void updateMedWholeNo(String oldSubCardNo, String oldSubCardId, String personId, String oldRegionId, String date,
			String newSubCardNo, String newSubCardId, String newRegionId) {
		Socket clientSocket = null;
		DataInputStream dataIS = null;
		InputStreamReader inSR = null;
		DataOutputStream dataOS = null;
		OutputStreamWriter outSW = null;
		try {
			//
			if (Tools.processNull(oldSubCardNo).equals("") || Tools.processNull(oldSubCardId).equals("")
					|| Tools.processNull(personId).equals("") || Tools.processNull(oldRegionId).equals("")
					|| Tools.processNull(date).equals("") || Tools.processNull(newSubCardNo).equals("")
					|| Tools.processNull(newSubCardId).equals("") || Tools.processNull(newRegionId).equals("")) {
				throw new CommonException("参数为空！");
			}
			// data
			String date1 = DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss");
			String date2 = DateUtil.formatDate(new Date(), "yyyyMMdd");
			String trsernos = "330400501" + date2 + Tools.tensileString("" + this.getSequenceByName("SEQ_SWITCH_SERVICE"), 9, true, "0");
			String sendstr = "####0010|7030|330400501|B25B911FFC2B76A647454E5A53EDF8B5|" + trsernos + "|admin|"
					+ date1 + "|" + date1 + "|0~" + oldSubCardNo + "~" + oldSubCardId + "~" + personId + "~" + oldRegionId + "~" + date + "~" + newSubCardNo + "~" + newSubCardId + "~" + newRegionId + "$$$$";
			// send
			logger.debug("发送数据 ：" + sendstr);
			clientSocket = new Socket(ipAddress, port);
			dataIS = new DataInputStream(clientSocket.getInputStream());
			inSR = new InputStreamReader(dataIS, "GBK");
			BufferedReader br = new BufferedReader(inSR);
			dataOS = new DataOutputStream(clientSocket.getOutputStream());
			outSW = new OutputStreamWriter(dataOS, "GBK");
			BufferedWriter bw = new BufferedWriter(outSW);
			bw.write(sendstr); // 加上分行符，以便服务器按行读取
			bw.flush();
			// 接收数据
			String resps = null;
			while ((resps = br.readLine()) != null) {
				resps = resps.trim();
				logger.debug("服务器回复：" + resps);
				break;
			}
			
			// test
//			ISwitchServiceServiceLocator locator = new ISwitchServiceServiceLocator();
//			ISwitchService service = locator.getISwitchServicePort();
//			String resps = service.switchToBusinessService("####0010|7030|330400501|315B4DF935F4775EF5033A4833A9E0E1|33040050120170424020901261|admin|2017-04-24 09:58:30|2017-04-24 09:58:30|0~1~2~3~4~201111111111~6~7~8$$$$");
//			logger.error("服务器回复：" + resps);

			// parse message
			if(!resps.startsWith("####") || !resps.endsWith("$$$$")) {
				throw new CommonException("服务器返回报文格式错误，返回报文：" + resps);
			}
			resps = resps.replaceAll("####|\\$\\$\\$\\$", "");
			// 1.head
			String[] respHead = resps.substring(0, resps.indexOf("~")).split("\\|", 11);
			if (respHead.length != 11) {
				throw new CommonException("服务器返回【报文头】格式错误，返回报文：" + resps);
			}
			// 2.body
			String[] respBody = resps.substring(resps.indexOf("~") + 1).split("~", 2);
			if (respBody.length != 2) {
				throw new CommonException("服务器返回【报文体】格式错误，返回报文：" + resps);
			}

			// handle
			String flag = respHead[8];
			if (flag.equals("0")) { // 0：交易成功，业务成功,1：交易成功，业务失败,2：交易成功，查询无记录,3：交易成功，数据由勘误变成正常,6：交易成功，公安库比对不通过,7：交易成功，公安库网络异常,8：交易成功，业务需勘误等待,9：交易成功，业务需会商等待,-1：交易失败，其他,-4：交易失败，超时,-108：交易失败，断网
				// success
			} else {
				String errMsg = "交易结果：【" + flag + "】 - ";
				if (flag.equals("1")) {
					errMsg += "交易成功，业务失败";
				} else if (flag.equals("2")) {
					errMsg += "交易成功，查询无记录";
				} else if (flag.equals("3")) {
					errMsg += "交易成功，数据由勘误变成正常";
				} else if (flag.equals("6")) {
					errMsg += "交易成功，公安库比对不通过";
				} else if (flag.equals("7")) {
					errMsg += "交易成功，公安库网络异常";
				} else if (flag.equals("8")) {
					errMsg += "交易成功，业务需勘误等待";
				} else if (flag.equals("9")) {
					errMsg += "交易成功，业务需会商等待";
				} else if (flag.equals("-1")) {
					errMsg += "交易失败，其他";
				} else if (flag.equals("-4")) {
					errMsg += "交易失败，超时";
				} else if (flag.equals("-108")) {
					errMsg += "交易失败，断网";
				} else {
					errMsg += "未定义返回码[" + flag + "]";
				}
				errMsg += "；错误信息：【" + respHead[9] + "】 - " + respHead[10];
				throw new CommonException(errMsg);
			}
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		} finally {
			try {
				if (inSR != null) {
					inSR.close();
				}
				if (dataIS != null) {
					dataIS.close();
				}
				if (dataOS != null) {
					dataOS.close();
				}
				if (outSW != null) {
					outSW.close();
				}
				if (clientSocket != null) {
					clientSocket.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	private void updateCardState(String subCardNo, String subCardId, String personId, String regionId, String date, String cardStateBeforeChange, String cardStateAfterChange) {
		Socket clientSocket = null;
		DataInputStream dataIS = null;
		InputStreamReader inSR = null;
		DataOutputStream dataOS = null;
		OutputStreamWriter outSW = null;
		try {
			if (Tools.processNull(subCardNo).equals("") || Tools.processNull(subCardId).equals("")
					|| Tools.processNull(personId).equals("") || Tools.processNull(regionId).equals("")
					|| Tools.processNull(date).equals("") || Tools.processNull(cardStateBeforeChange).equals("")
					|| Tools.processNull(cardStateAfterChange).equals("")) {
				throw new CommonException("参数为空！");
			}
			// data
			String date1 = DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss");
			String date2 = DateUtil.formatDate(new Date(), "yyyyMMdd");
			String trsernos = "330400501" + date2 + Tools.tensileString("" + this.getSequenceByName("SEQ_SWITCH_SERVICE"), 9, true, "0");
			String sendstr = "####0010|7005|330400501|F514CEC81CB148559CF475E7426EED5E|" + trsernos + "|admin|"
					+ date1 + "|" + date1 + "|0~" + subCardNo + "~" + subCardId + "~" + personId + "~" + regionId + "~" + date + "~" + cardStateBeforeChange + "~" + cardStateAfterChange + "$$$$";
			
			// send
			logger.debug("发送数据 ：" + sendstr);
			/*// test
			ISwitchServiceServiceLocator locator = new ISwitchServiceServiceLocator();
			ISwitchService service = locator.getISwitchServicePort();
			String resps = service.switchToBusinessService("####0010|7030|330400501|315B4DF935F4775EF5033A4833A9E0E1|33040050120170424020901261|admin|2017-04-24 09:58:30|2017-04-24 09:58:30|0~1~2~3~4~201111111111~6~7~8$$$$");
			logger.error("服务器回复：" + resps);*/
			
			clientSocket = new Socket(ipAddress, port);
			dataIS = new DataInputStream(clientSocket.getInputStream());
			inSR = new InputStreamReader(dataIS, "GBK");
			BufferedReader br = new BufferedReader(inSR);
			dataOS = new DataOutputStream(clientSocket.getOutputStream());
			outSW = new OutputStreamWriter(dataOS, "GBK");
			BufferedWriter bw = new BufferedWriter(outSW);
			bw.write(sendstr); // 加上分行符，以便服务器按行读取
			bw.flush();
			// 接收数据
			String resps = null;
			while ((resps = br.readLine()) != null) {
				resps = resps.trim();
				logger.debug("服务器回复：" + resps);
				break;
			}

			// parse message
			if(!resps.startsWith("####") || !resps.endsWith("$$$$")) {
				throw new CommonException("服务器返回报文格式错误，返回报文：" + resps);
			}
			resps = resps.replaceAll("####|\\$\\$\\$\\$", "");
			// 1.head
			String[] respHead = resps.substring(0, resps.indexOf("~")).split("\\|", 11);
			if (respHead.length != 11) {
				throw new CommonException("服务器返回【报文头】格式错误，返回报文：" + resps);
			}
			// 2.body
			String[] respBody = resps.substring(resps.indexOf("~") + 1).split("~", 2);
			if (respBody.length < 2) {
				throw new CommonException("服务器返回【报文体】格式错误，返回报文：" + resps);
			}

			// handle
			String flag = respHead[8];
			if (flag.equals("0")) { // 0：交易成功，业务成功,1：交易成功，业务失败,2：交易成功，查询无记录,3：交易成功，数据由勘误变成正常,6：交易成功，公安库比对不通过,7：交易成功，公安库网络异常,8：交易成功，业务需勘误等待,9：交易成功，业务需会商等待,-1：交易失败，其他,-4：交易失败，超时,-108：交易失败，断网
				// success
				publicDao.doSql("insert into base_st_upload (SUB_CARD_NO, SUB_CARD_ID, SEND_DATE, SEND_TYPE, ST_PERSON_ID, CERT_NO, NAME, REGION_ID, CARD_STATE) "
						+ "select '" + subCardNo + "', '" + subCardId + "', '" + date2 + "', '2', '" + personId + "', cert_no, name, '" + subCardId.substring(0, 6) + "', '" + cardStateAfterChange + "' from base_personal t where exists (select 1 from card_baseinfo where customer_id = t.customer_id and sub_card_id = '" + subCardId + "')");
			} else {
				String errMsg = "交易结果：【" + flag + "】 - ";
				if (flag.equals("1")) {
					errMsg += "交易成功，业务失败";
				} else if (flag.equals("2")) {
					errMsg += "交易成功，查询无记录";
				} else if (flag.equals("3")) {
					errMsg += "交易成功，数据由勘误变成正常";
				} else if (flag.equals("6")) {
					errMsg += "交易成功，公安库比对不通过";
				} else if (flag.equals("7")) {
					errMsg += "交易成功，公安库网络异常";
				} else if (flag.equals("8")) {
					errMsg += "交易成功，业务需勘误等待";
				} else if (flag.equals("9")) {
					errMsg += "交易成功，业务需会商等待";
				} else if (flag.equals("-1")) {
					errMsg += "交易失败，其他";
				} else if (flag.equals("-4")) {
					errMsg += "交易失败，超时";
				} else if (flag.equals("-108")) {
					errMsg += "交易失败，断网";
				} else {
					errMsg += "未定义返回码[" + flag + "]";
				}
				errMsg += "；错误信息：【" + respHead[9] + "】 - " + respHead[10];
				throw new CommonException(errMsg);
			}
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		} finally {
			try {
				if (inSR != null) {
					inSR.close();
				}
				if (dataIS != null) {
					dataIS.close();
				}
				if (dataOS != null) {
					dataOS.close();
				}
				if (outSW != null) {
					outSW.close();
				}
				if (clientSocket != null) {
					clientSocket.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	@Override
	public void updateCardState(List<String> oldCardNos, String cardState, String cardState2) {
		try {
			if (oldCardNos.isEmpty()) {
				throw new CommonException("卡号为空！");
			}
			for (String oldCardNo : oldCardNos) {
				try {
					updateCardState(oldCardNo, cardState, cardState2);
				} catch (Exception e) {
					//
				}
			}
		} catch (Exception e) {
			throw new CommonException("同步省厅失败，" + e.getMessage());
		}
	}

	/**
	 * 发送整个任务卡片到省厅（这里只保存到处理表，发送由定时任务处理，因为太多的话处理时间太长）
	 */
	@Override
	public void sync2ST(String taskId) {
		try {
			if (Tools.processNull(taskId).equals("")) {
				throw new CommonException("卡号为空！");
			}
			// 插入没有的
			publicDao.doSql("insert into base_st select customer_id, '', '1', sysdate, '1', '1', '1', '' from card_apply t where task_id = '" + taskId + "' and not exists (select 1 from base_st where customer_id = t.customer_id) ");
			// 更新存在的
			publicDao.doSql("update base_st t set card_clbz = '1' where exists (select 1 from card_apply where customer_id = t.customer_id and task_id = '" + taskId + "')");
		} catch (CommonException e) {
			throw new CommonException("同步省厅失败，" + e.getMessage());
		}
	}
	
	@Override
	public void sendCardNum2ST(String regionId, String date) {
		try {
			if (Tools.processNull(date).equals("")) {
				throw new CommonException("对账日期为空！");
			}
			int keyWords = 0;
			int normalCardNum = 0;
			int lossCardNum = 0;
			int preLossCardNum = 0;
			int totCardNum = 0;
			Object[] data = (Object[]) findOnlyRowBySql("select count(1), nvl(sum(securitycode(sub_card_id, 7051)), 0), nvl(sum(decode(t.send_type, '1', 1, 0)), 0) normalCardNum, "
					+ "nvl(sum(decode(t.send_type, '2', decode(t.card_state, '2', 1, 0), 0)), 0) preLossCardNum, nvl(sum(decode(t.send_type, '2', decode(t.card_state, '3', 1, 0), 0)), 0) lossCardNum "
					+ "from base_st_upload t where send_date = '" + date + "' and region_id = '" + regionId + "'");
			totCardNum += ((BigDecimal) data[0]).intValue();
			keyWords += ((BigDecimal) data[1]).intValue();
			normalCardNum += ((BigDecimal) data[2]).intValue();
			lossCardNum += ((BigDecimal) data[4]).intValue();
			preLossCardNum += ((BigDecimal) data[3]).intValue();
			//
			publicDao.doSql("delete from BASE_ST_DZ where dz_date = '" + date + "' and region_id = '" + regionId + "'");
			publicDao.doSql("insert into BASE_ST_DZ (DZ_DATE, DZ_STATE, TOT_CARD_NUM, NORMAL_CARD_NUM, LOSS_CARD_NUM, PRELOSS_CARD_NUM, ST_TOT_CARD_NUM, ST_NORMAL_CARD_NUM, ST_LOSS_CARD_NUM, ST_PRELOSS_CARD_NUM, REGION_ID) "
					+ "values ('" + date + "', '0', " + totCardNum + ", " + normalCardNum + ", " + lossCardNum + ", " + preLossCardNum + ", 0, 0, 0, 0, '" + regionId + "')");
			//
			sendCardNum2ST(date, regionId, keyWords, totCardNum, normalCardNum, lossCardNum, preLossCardNum);
		} catch (Exception e) {
			throw new CommonException("省厅对账失败[" + regionId + ", " + date + "]， " + e.getMessage());
		}
	}

	@Override
	public void downLoadSTCardData(String date, String regionId, long pv) {
		Socket clientSocket = null;
		DataInputStream dataIS = null;
		InputStreamReader inSR = null;
		DataOutputStream dataOS = null;
		OutputStreamWriter outSW = null;
		try {
			//
			if (Tools.processNull(date).equals("") || Tools.processNull(regionId).equals("")) {
				throw new CommonException("参数为空！");
			}
			// data
			String date1 = DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss");
			String date2 = DateUtil.formatDate(new Date(), "yyyyMMdd");
			String trsernos = "330400501" + date2 + Tools.tensileString("" + this.getSequenceByName("SEQ_SWITCH_SERVICE"), 9, true, "0");
			String sendstr = "####0010|7052|330400501|5DCA4C6B9E244D24A30B4C45601D9743|" + trsernos + "|admin|"
					+ date1 + "|" + date1 + "|0~" + date + "~" + regionId + "~~" + pv + "$$$$";
			// send
			logger.debug("发送数据 ：" + sendstr);
			clientSocket = new Socket(ipAddress, port);
			dataIS = new DataInputStream(clientSocket.getInputStream());
			inSR = new InputStreamReader(dataIS, "GBK");
			BufferedReader br = new BufferedReader(inSR);
			dataOS = new DataOutputStream(clientSocket.getOutputStream());
			outSW = new OutputStreamWriter(dataOS, "GBK");
			BufferedWriter bw = new BufferedWriter(outSW);
			bw.write(sendstr); // 加上分行符，以便服务器按行读取
			bw.flush();
			// 接收数据
			String resps = null;
			while ((resps = br.readLine()) != null) {
				resps = resps.trim();
				logger.debug("服务器回复：" + resps);
				break;
			}
			
			// test
//			ISwitchServiceServiceLocator locator = new ISwitchServiceServiceLocator();
//			ISwitchService service = locator.getISwitchServicePort();
//			String resps = service.switchToBusinessService(sendstr);
//			logger.error("服务器回复：" + resps);

			// parse message
			if(!resps.startsWith("####") || !resps.endsWith("$$$$")) {
				throw new CommonException("服务器返回报文格式错误，返回报文：" + resps);
			}
			resps = resps.replaceAll("####|\\$\\$\\$\\$", "");
			// 1.head
			String[] respHead = resps.substring(0, resps.indexOf("~")).split("\\|", 11);
			if (respHead.length != 11) {
				throw new CommonException("服务器返回【报文头】格式错误，返回报文：" + resps);
			}
			// 2.body
			String[] respBody = resps.substring(resps.indexOf("~") + 1).split("~", 5);
			if (respBody.length < 5) {
				throw new CommonException("服务器返回【报文体】格式错误，返回报文：" + resps);
			}

			// handle
			String flag = respHead[8];
			if (flag.equals("0")) { // 0：交易成功，业务成功,1：交易成功，业务失败,2：交易成功，查询无记录,3：交易成功，数据由勘误变成正常,6：交易成功，公安库比对不通过,7：交易成功，公安库网络异常,8：交易成功，业务需勘误等待,9：交易成功，业务需会商等待,-1：交易失败，其他,-4：交易失败，超时,-108：交易失败，断网
				String[] cardData = respBody[4].split("\\^");
				if (cardData.length > 0) {
					for (String card : cardData) {
						String[] cardInfo = card.split("\\|");
						publicDao.doSql("insert into base_st_download (DOWNLOAD_DATE, SUB_CARD_NO, SUB_CARD_ID, SEND_DATE, ST_PERSON_ID, CERT_NO, NAME, REGION_ID, CARD_STATE, UNDEFINED) "
								+ "values ('" + getClrDate() + "', '" + cardInfo[0] + "', '" + cardInfo[1] + "', '" + cardInfo[2] + "', '" + cardInfo[3] + "', '" + cardInfo[4] + "', '" + cardInfo[5] + "', '" + cardInfo[6] + "', '" + cardInfo[7] + "', '" + cardInfo[8] + "')");
						//
						long pv2 = Long.parseLong(cardInfo[8]);
						if (pv2 > pv) {
							pv = pv2;
						}
					}
				}
				if (respBody[2].toString().equals("1")) { // 没下载完
					downLoadSTCardData(date2, regionId, pv);
				}
			} else {
				String errMsg = "交易结果：【" + flag + "】 - ";
				if (flag.equals("1")) {
					errMsg += "交易成功，业务失败";
				} else if (flag.equals("2")) {
					errMsg += "交易成功，查询无记录";
				} else if (flag.equals("3")) {
					errMsg += "交易成功，数据由勘误变成正常";
				} else if (flag.equals("6")) {
					errMsg += "交易成功，公安库比对不通过";
				} else if (flag.equals("7")) {
					errMsg += "交易成功，公安库网络异常";
				} else if (flag.equals("8")) {
					errMsg += "交易成功，业务需勘误等待";
				} else if (flag.equals("9")) {
					errMsg += "交易成功，业务需会商等待";
				} else if (flag.equals("-1")) {
					errMsg += "交易失败，其他";
				} else if (flag.equals("-4")) {
					errMsg += "交易失败，超时";
				} else if (flag.equals("-108")) {
					errMsg += "交易失败，断网";
				} else {
					errMsg += "未定义返回码[" + flag + "]";
				}
				errMsg += "；错误信息：【" + respHead[9] + "】 - " + respHead[10];
				throw new CommonException(errMsg);
			}
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		} finally {
			try {
				if (inSR != null) {
					inSR.close();
				}
				if (dataIS != null) {
					dataIS.close();
				}
				if (dataOS != null) {
					dataOS.close();
				}
				if (outSW != null) {
					outSW.close();
				}
				if (clientSocket != null) {
					clientSocket.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	private void sendCardNum2ST(String date, String regionId, int keyWords, int totCardNum, int normalCardNum, int lossCardNum, int preLossCardNum) {
		Socket clientSocket = null;
		DataInputStream dataIS = null;
		InputStreamReader inSR = null;
		DataOutputStream dataOS = null;
		OutputStreamWriter outSW = null;
		try {
			//
			if (Tools.processNull(date).equals("") || Tools.processNull(regionId).equals("")) {
				throw new CommonException("参数为空！");
			}
			// data
			String date1 = DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss");
			String date2 = DateUtil.formatDate(new Date(), "yyyyMMdd");
			String trsernos = "330400501" + date2 + Tools.tensileString("" + this.getSequenceByName("SEQ_SWITCH_SERVICE"), 9, true, "0");
			String sendstr = "####0010|7051|330400501|5DCA4C6B9E244D24A30B4C45601D9742|" + trsernos + "|admin|"
					+ date1 + "|" + date1 + "|0~" + date + "~" + date + "~" + regionId + "~" + keyWords + "~" + totCardNum + "~" + normalCardNum + "~" + lossCardNum + "~0~" + preLossCardNum + "~0$$$$";
			// send
			logger.debug("发送数据 ：" + sendstr);
			clientSocket = new Socket(ipAddress, port);
			dataIS = new DataInputStream(clientSocket.getInputStream());
			inSR = new InputStreamReader(dataIS, "GBK");
			BufferedReader br = new BufferedReader(inSR);
			dataOS = new DataOutputStream(clientSocket.getOutputStream());
			outSW = new OutputStreamWriter(dataOS, "GBK");
			BufferedWriter bw = new BufferedWriter(outSW);
			bw.write(sendstr); // 加上分行符，以便服务器按行读取
			bw.flush();
			// 接收数据
			String resps = null;
			while ((resps = br.readLine()) != null) {
				resps = resps.trim();
				logger.debug("服务器回复：" + resps);
				break;
			}
			
			// test
//			ISwitchServiceServiceLocator locator = new ISwitchServiceServiceLocator();
//			ISwitchService service = locator.getISwitchServicePort();
//			String resps = service.switchToBusinessService(sendstr);
//			logger.error("服务器回复：" + resps);

			// parse message
			if(!resps.startsWith("####") || !resps.endsWith("$$$$")) {
				throw new CommonException("服务器返回报文格式错误，返回报文：" + resps);
			}
			resps = resps.replaceAll("####|\\$\\$\\$\\$", "");
			// 1.head
			String[] respHead = resps.substring(0, resps.indexOf("~")).split("\\|", 11);
			if (respHead.length != 11) {
				throw new CommonException("服务器返回【报文头】格式错误，返回报文：" + resps);
			}
			// 2.body
			String[] respBody = resps.substring(resps.indexOf("~") + 1).split("~", 9);
			if (respBody.length < 9) {
				throw new CommonException("服务器返回【报文体】格式错误，返回报文：" + resps);
			}

			// handle
			String flag = respHead[8];
			if (flag.equals("0")) { // 0：交易成功，业务成功,1：交易成功，业务失败,2：交易成功，查询无记录,3：交易成功，数据由勘误变成正常,6：交易成功，公安库比对不通过,7：交易成功，公安库网络异常,8：交易成功，业务需勘误等待,9：交易成功，业务需会商等待,-1：交易失败，其他,-4：交易失败，超时,-108：交易失败，断网
				String bFlag = respBody[0];
				int sum = Integer.parseInt(respBody[2]);
				if (!"0".equals(bFlag)) {// 对账不通过 TODO
					try {
						downLoadSTCardData(date, regionId, 0);
					} catch (Exception e1) {
						logger.debug("下载省厅对账数据失败，" + e1.getMessage());
					}
				}
				publicDao.doSql("update BASE_ST_DZ t set dz_state = '" + bFlag + "', ST_TOT_CARD_NUM = " + respBody[2] + ", ST_NORMAL_CARD_NUM = " + respBody[3] + ", ST_LOSS_CARD_NUM = " + respBody[4] + ", ST_PRELOSS_CARD_NUM = " + respBody[6] + " where dz_date = '" + date + "' and region_id = '" + regionId + "'");
			} else {
				String errMsg = "交易结果：【" + flag + "】 - ";
				if (flag.equals("1")) {
					errMsg += "交易成功，业务失败";
				} else if (flag.equals("2")) {
					errMsg += "交易成功，查询无记录";
				} else if (flag.equals("3")) {
					errMsg += "交易成功，数据由勘误变成正常";
				} else if (flag.equals("6")) {
					errMsg += "交易成功，公安库比对不通过";
				} else if (flag.equals("7")) {
					errMsg += "交易成功，公安库网络异常";
				} else if (flag.equals("8")) {
					errMsg += "交易成功，业务需勘误等待";
				} else if (flag.equals("9")) {
					errMsg += "交易成功，业务需会商等待";
				} else if (flag.equals("-1")) {
					errMsg += "交易失败，其他";
				} else if (flag.equals("-4")) {
					errMsg += "交易失败，超时";
				} else if (flag.equals("-108")) {
					errMsg += "交易失败，断网";
				} else {
					errMsg += "未定义返回码[" + flag + "]";
				}
				errMsg += "；错误信息：【" + respHead[9] + "】 - " + respHead[10];
				throw new CommonException(errMsg);
			}
		} catch (Exception e) {
			throw new CommonException(e.getMessage());
		} finally {
			try {
				if (inSR != null) {
					inSR.close();
				}
				if (dataIS != null) {
					dataIS.close();
				}
				if (dataOS != null) {
					dataOS.close();
				}
				if (outSW != null) {
					outSW.close();
				}
				if (clientSocket != null) {
					clientSocket.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	/**
	 * @author Yueh
	 */
	@Override
	public void sendPersonPhoto(String certNo) {
		try {
			if (certNo == null || certNo.equals("")) {
				throw new CommonException("证件号码为空！");
			} else if (certNo.length() != 18) {
				throw new CommonException("证件号码不是身份证号码！");
			}
			Object[] cardData = (Object[]) findOnlyRowBySql("select t.st_person_id, t2.cert_no, t2.name, t3.photo, t.customer_id from BASE_ST t join base_personal t2 on t.customer_id = t2.customer_id join base_photo t3 on t.customer_id = t3.customer_id where t.clbz = '0' and t3.photo_state = '0' and t2.cert_no = '" + certNo + "'");
			if(cardData == null) {
				throw new CommonException("未找到照片数据！");
			}
			sendPhotoData(cardData);
		} catch (Exception e) {
			throw new CommonException("发送照片失败，" + e.getMessage());
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public void saveSendPhoto() {
		try {
			List<Object[]> list = this.findBySql("select t.st_person_id, t2.cert_no, t2.name, t3.photo, t.customer_id from BASE_ST t join base_personal t2 on t.customer_id = t2.customer_id join base_photo t3 on t.customer_id = t3.customer_id where t.clbz = '0' and t.photo_state = '1' and t3.photo_state = '0' and rownum <= 100");
			if (list == null || list.isEmpty()) {
				throw new CommonException("没有需要上传的照片信息");
			}
			logger.debug("发送省厅照片数据开始，共 " + list.size() + " 条照片信息");
			for (int i = 0; i < list.size(); i++) {
				try {
					Object[] cardData = (Object[]) list.get(i);
					logger.debug("第" + (i + 1) + "个，发送数据开始：" + Arrays.toString(cardData));
					sendPhotoData(cardData);
					logger.debug("第" + (i + 1) + "个，发送数据完成");
				} catch (Exception e) {
					logger.error("第" + (i + 1) + "个，发送数据失败：" + e.getMessage());
				}
			}
			logger.debug("发送省厅照片数据完成");
		} catch (Exception ee) {
			logger.error("发送省厅照片数据失败，" + ee.getMessage());
			throw new CommonException("上传照片数据出错" + ee.getMessage());
		}
	}

	/*
	 * st_person_id
	 * cert_no
	 * name
	 * photo
	 * customer_id
	 */
	private void sendPhotoData(Object[] photoData) {
		Socket clientSocket = null;
		DataInputStream dataIS = null;
		InputStreamReader inSR = null;
		DataOutputStream dataOS = null;
		OutputStreamWriter outSW = null;
		try {
			// data
			String date1 = DateUtil.formatDate(new Date(), "yyyy-MM-dd HH:mm:ss");
			String date2 = DateUtil.formatDate(new Date(), "yyyyMMdd");
			String trsernos = "330400501" + date2 + Tools.tensileString("" + this.getSequenceByName("SEQ_SWITCH_SERVICE"), 9, true, "0");
			String sendstr = "####0010|7010|330400501|281715CAFA675BF359EBAA42CB44FA17|" + trsernos + "|admin|"
					+ date1 + "|" + date1 + "|1~1~" + photoData[0] + "~" + photoData[1] + "~" + photoData[2] + "~~~1~330400501" + photoData[1] + DateUtil.formatDate(new Date(), "yyyyMMddHHmmss") + ".jpg|" + Base64.Blob2String((Blob) photoData[3]) + "$$$$";
			
			// send
			String logMsg = "####0010|7010|330400501|281715CAFA675BF359EBAA42CB44FA17|" + trsernos + "|admin|" + date1 + "|" + date1 + "|1~1~" + photoData[0] + "~" + photoData[1] + "~" + photoData[2] + "~~~1~330400501" + photoData[1] + DateUtil.formatDate(new Date(), "yyyyMMddHHmmss") + ".jpg|base64code$$$$";
			logger.debug("发送数据 ：" + logMsg);
			clientSocket = new Socket(ipAddress, port);
			dataIS = new DataInputStream(clientSocket.getInputStream());
			inSR = new InputStreamReader(dataIS, "GBK");
			BufferedReader br = new BufferedReader(inSR);
			dataOS = new DataOutputStream(clientSocket.getOutputStream());
			outSW = new OutputStreamWriter(dataOS, "GBK");
			BufferedWriter bw = new BufferedWriter(outSW);
			bw.write(sendstr); // 加上分行符，以便服务器按行读取
			bw.flush();
			// 接收数据
			String resps = null;
			while ((resps = br.readLine()) != null) {
				resps = resps.trim();
				logger.debug("服务器回复：" + resps);
				break;
			}
			
			// test
//			ISwitchServiceServiceLocator locator = new ISwitchServiceServiceLocator();
//			ISwitchService service = locator.getISwitchServicePort();
//			String resps = service.switchToBusinessService(sendstr);
//			logger.error("服务器回复：" + resps);

			// parse message
			if(!resps.startsWith("####") || !resps.endsWith("$$$$")) {
				throw new CommonException("服务器返回报文格式错误，返回报文：" + resps);
			}
			resps = resps.replaceAll("####|\\$\\$\\$\\$", "");
			if (resps.equals("")) {
				throw new CommonException("服务器返回报文为空");
			}
			// 1.head
			String[] respHead = resps.substring(0, resps.indexOf("~")).split("\\|", 11);
			if (respHead.length != 11) {
				throw new CommonException("服务器返回【报文头】格式错误，返回报文：" + resps);
			}
			// 2.body
			String[] respBody = resps.substring(resps.indexOf("~") + 1).split("~", 2);
			if (respBody.length != 2) {
				throw new CommonException("服务器返回【报文体】格式错误，返回报文：" + resps);
			}

			// handle
			String flag = respHead[8];
			if (flag.equals("0") && respBody[0].equals("0")) { // 0：交易成功，业务成功,1：交易成功，业务失败,2：交易成功，查询无记录,3：交易成功，数据由勘误变成正常,6：交易成功，公安库比对不通过,7：交易成功，公安库网络异常,8：交易成功，业务需勘误等待,9：交易成功，业务需会商等待,-1：交易失败，其他,-4：交易失败，超时,-108：交易失败，断网
				publicDao.doSql("update base_st t set photo_state = '0', card_clsj = sysdate, note = '" + respHead[10] + "' where t.customer_id = '" + photoData[4] + "'");
			} else {
				String errMsg = "发送照片数据，交易结果：【" + flag + "】 - ";
				if (flag.equals("1")) {
					errMsg += "交易成功，业务失败";
				} else if (flag.equals("2")) {
					errMsg += "交易成功，查询无记录";
				} else if (flag.equals("3")) {
					errMsg += "交易成功，数据由勘误变成正常";
				} else if (flag.equals("6")) {
					errMsg += "交易成功，公安库比对不通过";
				} else if (flag.equals("7")) {
					errMsg += "交易成功，公安库网络异常";
				} else if (flag.equals("8")) {
					errMsg += "交易成功，业务需勘误等待";
				} else if (flag.equals("9")) {
					errMsg += "交易成功，业务需会商等待";
				} else if (flag.equals("-1")) {
					errMsg += "交易失败，其他";
				} else if (flag.equals("-4")) {
					errMsg += "交易失败，超时";
				} else if (flag.equals("-108")) {
					errMsg += "交易失败，断网";
				} else {
					errMsg += "未定义返回码[" + flag + "]";
				}
				errMsg += "；错误信息：【" + respHead[9] + "】 - " + respHead[10] + "，" + respBody[1];
				throw new CommonException(errMsg);
			}
		} catch (Exception e) {
			publicDao.doSql("update base_st t set photo_state = '9', note = '发送照片失败，" + e.getMessage() + "' where t.customer_id = '" + photoData[4] + "'");
			throw new CommonException(e.getMessage());
		} finally {
			publicDao.doSql("commit");
			try {
				if (inSR != null) {
					inSR.close();
				}
				if (dataIS != null) {
					dataIS.close();
				}
				if (dataOS != null) {
					dataOS.close();
				}
				if (outSW != null) {
					outSW.close();
				}
				if (clientSocket != null) {
					clientSocket.close();
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	@Override
	public void updatePerson(String certNo) {
		try {
			if (certNo == null || certNo.equals("")) {
				throw new CommonException("证件号码为空！");
			} else if (certNo.length() != 18) {
				throw new CommonException("证件号码不是身份证号码！");
			}
			Object[] personData = (Object[]) findOnlyRowBySql("select p.customer_id, p.name, p.cert_no, p.gender, substr(cert_no, 7, 8), t.clbz, t.st_person_id from BASE_ST t, base_personal p where p.customer_id = t.customer_id and p.cert_no = '" + certNo + "'");
			if(personData == null) {
				throw new CommonException("未找到人员数据！");
			}/* else if ("0".equals(personData[5].toString()) && personData[6] != null && personData[6].toString().length() > 0) {
				throw new CommonException("人员信息已发送！");
			}*/
			updatePerson(personData);
		} catch (Exception e) {
			throw new CommonException("发送人员失败，" + e.getMessage());
		}
	}

	private void updatePerson(Object[] personData) {
		// TODO
	}
}
