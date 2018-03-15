package com.erp.serviceImpl;

import org.springframework.stereotype.Service;

import com.erp.exception.CommonException;
import com.erp.model.CardProducts;
import com.erp.model.SysActionLog;
import com.erp.model.Users;
import com.erp.service.CardProductsService;
import com.erp.util.DealCode;
@Service("cardProductsService")
public class CardProductsServiceImpl extends BaseServiceImpl implements CardProductsService  {
	public CardProductsServiceImpl() {
		// TODO Auto-generated constructor stub
	}
    /**
     * 保存卡片信息
     */
	@Override
	public void saveCardPro(CardProducts cardPro) throws CommonException {
		
		try {		
			SysActionLog actionLog = this.getCurrentActionLog();
			actionLog.setDealCode(DealCode.CARD_PRODUCT);
			actionLog.setMessage("卡片档案保存");
			publicDao.save(actionLog);
			Users user=this.getSessionUser();
			cardPro.setBrchId(user.getBrchId());
			cardPro.setOperId(user.getUserId());
			cardPro.setOrgId(user.getOrgId());
			cardPro.setProState("0");
			publicDao.save(cardPro);
			
		} catch (Exception e) {
			throw new CommonException(e);
		}
		
		
	}
    /**
     * 删除卡片信息
     */
	@Override
	public void delCardPro(String cardType) throws CommonException {
	
		try{
			SysActionLog actionLog = this.getCurrentActionLog();
			actionLog.setDealCode(DealCode.CARD_PRODUCT);
			actionLog.setMessage("卡片档案删除");
			publicDao.save(actionLog);
			CardProducts cardPro = (CardProducts) this.findOnlyRowByHql("from CardProducts where cardType='"+cardType+"'");
			
			if(cardPro != null){	
				publicDao.delete(cardPro);
			}

		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	
	}
    /**
     * 修改卡片信息
     */
	@Override
	public void updateCardPro(CardProducts cardPro) throws CommonException {
		try{
			SysActionLog actionLog = this.getCurrentActionLog();
			actionLog.setDealCode(DealCode.CARD_PRODUCT);
			actionLog.setMessage("卡片档案修改");
			publicDao.save(actionLog);
			CardProducts cardPros = (CardProducts) this.findOnlyRowByHql("from CardProducts where cardType='"+cardPro.getCardType()+"'");
			
			if(cardPros != null){	
				publicDao.merge(cardPro);
			}

		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
		
	}
    /**
     * 查找卡片信息
     */
	@Override
	public void findCardPro(CardProducts cardPro) throws CommonException {
		// TODO Auto-generated method stub
		
	}

}
