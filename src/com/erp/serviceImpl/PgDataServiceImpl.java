package com.erp.serviceImpl;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.service.PgDataService;
import com.erp.service.Switchservice;
import com.erp.util.Constants;

@Service(value="pgDataService")
public class PgDataServiceImpl extends BaseServiceImpl implements PgDataService {
	@Autowired
	private Switchservice switchservice;

	@Override
	public void reSendCard(String certNo) {
		try {
			Object[] card = (Object[]) switchservice.findOnlyRowBySql("select t.cert_no, t2.sub_card_no, t2.sub_card_id, t2.card_no, t.customer_id "
					+ "from base_personal t join card_baseinfo t2 on t.customer_id = t2.customer_id "
					+ "where t.cert_no = '" + certNo + "' and t2.card_type in ('100','120') and t2.card_state = '1'");
			//
			if (card == null || card.length == 0 || card[0] == null) {
				throw new CommonException("客户无卡或卡片状态不正常!");
			}
			String customerId = (String) card[4];
			String subCardId = (String) card[2];
			String cardNo = (String) card[3];
			String subCardNo = (String) card[1];
			String atr = subCardId.substring(6);
			// 检查人员信息是否已发送，若没有发送则先发送人员信息
			try {
				Object o = switchservice.findOnlyFieldBySql("select 1 from base_st where customer_id = '" + customerId + "' and clbz = '0'");
				if (o == null) {
					switchservice.sendPersonData(certNo);
				}
			} catch (Exception e) {

			}
			// 1.获取省厅卡信息
			Map<String, String> pgCard = null;
			try {
				pgCard = switchservice.getCard(certNo, subCardNo, null, null);
			} catch (Exception e) { // no data
				// 3.省厅无卡信息，新增（发省厅）
				try {
					switchservice.sendCardData(certNo);
				} catch (Exception e1) {
					throw new CommonException("省厅无卡信息, 发送新卡到省厅失败, " + e1.getMessage());
				}
			}

			// 2.省厅有卡信息（则检查是否与卡管一致）
			if (pgCard.get("subCardId").substring(6).equals(atr)) { // 省厅卡 与 本地卡 相同（卡复位信息相同说明是同一张卡）
				// 2.1
				if (!pgCard.get("subCardId").equals(subCardId)) { // 卡识别码不同（说明统筹区不一致），变更统筹区
					try {
						switchservice.updateMedWholeNo(cardNo, pgCard.get("regionId"), subCardId.substring(0, 6));
					} catch (Exception e) {
						throw new CommonException("社保卡号相同, 卡复位信息相同, 卡识别码不同, 发送省厅变更统筹区失败, " + e.getMessage());
					}
				}
			} else { // 卡复位信息不相同，注销老卡（因为查询的时候加了社保卡号，所以不可能是其他地区的卡），发送新卡
				// 2.2.1 注销老卡
				try {
					String cardNo2 = (String) switchservice.findOnlyFieldBySql("select card_no from card_baseinfo where customer_id = '" + customerId + "' and substr(sub_card_id,7) = '" + pgCard.get("subCardId").substring(6) + "'");
					if (cardNo2 == null || cardNo2.trim().equals("")) {// 本区域的卡但是卡识别码不存在, 这种情况不大可能
						throw new CommonException("省厅老卡信息（卡识别码）不存在本地库");
					}
					switchservice.updateCardState(cardNo2, Constants.CARD_STATE_ZC, Constants.CARD_STATE_ZX);
				} catch (Exception e) {
					throw new CommonException("社保卡号相同, 卡复位信息不相同, 发送省厅注销老卡失败, " + e.getMessage());
				}
				// 2.2.2 发送新卡
				try {
					switchservice.sendCardData(certNo);
				} catch (Exception e) {
					throw new CommonException("社保卡号相同, 卡复位信息不相同, 注销老卡成功, 发送省厅新卡失败, " + e.getMessage());
				}
			}
			
			publicDao.doSql("update resend_card_data set state = '0' where cert_no = '" + certNo + "'");
		} catch (Exception e) {
			throw new CommonException(e);
		}
	}

	@Override
	public void removeReSendCard(String certNo, String reason) {
		publicDao.doSql("update resend_card_data set state = '2', note = '" + reason + "' where cert_no = '" + certNo + "'");
	}

}
