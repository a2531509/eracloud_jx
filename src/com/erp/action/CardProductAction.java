package com.erp.action;

import java.util.List;




import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.InterceptorRefs;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;




import com.alibaba.fastjson.JSONArray;
import com.erp.model.CardProducts;
import com.erp.service.CardProductsService;
import com.erp.util.Constants;
import com.erp.util.Tools;
import com.erp.viewModel.Json;
import com.erp.viewModel.Page;
@Namespace("/cardProduct")
@Action(value = "CardProductAction")
@Results({@Result(type="json",name="json"),
			@Result(name="toAddCardPro",location="/jsp/cardProduct/cardProductAdd.jsp"),
			@Result(name="toEditCardPro",location="/jsp/cardProduct/cardProductEdit.jsp")
			})
@InterceptorRefs({@InterceptorRef("jsondefalut")})
public class CardProductAction extends BaseAction{
	/**
	 * 
	 */
	private String queryType = "1";//查询类型 1 不进行查询,直接返回;0 进行查询,返回查询结果。
	private String cardType="";
	private String chiType="";
	private String mediaType="";
	private CardProducts  cardPro=null;

	private CardProductsService cardProductsService;
	public CardProducts getCardPro() {
		return cardPro;
	}
	public String getCardType() {
		return cardType;
	}
	public void setCardType(String cardType) {
		this.cardType = cardType;
	}
	public void setCardPro(CardProducts cardPro) {
		this.cardPro = cardPro;
	}
	/**
	 * 到达编辑页面
	 * @return
	 */
	public String toEditCardPro(){
		try {

			cardPro = (CardProducts)cardProductsService.findOnlyRowByHql("from CardProducts where cardType like'"+this.cardType.charAt(0)+"%'");
			
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toEditCardPro";
	}
	/**
	 * 跳转到新增页面
	 * @return
	 */
	public String toAddCardPro(){
		try {
			cardPro = new CardProducts();
		} catch (Exception e) {
			this.saveErrLog(e);
		}
		return "toAddCardPro";
	}
	/**
	 * 保存卡片信息
	 * @return
	 */
	public String saveMerCardPro(){
		Json json = new Json();
		try {
              
			CardProducts  cardPro1 = (CardProducts)cardProductsService.findOnlyRowByHql("from CardProducts where cardType='"+cardPro.getCardType()+"'");
               if(!Tools.processNull(cardPro1).equals("")){
            	   json.setMessage("卡片信息已存在");            	             	   
               }else{           	  
            	   cardProductsService.saveCardPro(cardPro);
               }
			

			json.setStatus(true);
			json.setTitle("成功提示");
			json.setMessage("商户终端信息保存成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	public String editMerCardPro(){
		Json json = new Json();
		try {	
				cardProductsService.updateCardPro(cardPro);
	
			json.setStatus(true);
			json.setTitle("成功提示");
			json.setMessage("商户终端信息编辑成功");
		} catch (Exception e) {
			this.saveErrLog(e);
			json.setStatus(false);
			json.setMessage(e.getMessage());
			json.setTitle("错误提示");
		}
		OutputJson(json,Constants.TEXT_TYPE_PLAIN);
		return null;
	}
	/**
	 * 查询卡片
	 * @param cardProductsService
	 */
	
	public String queryMerCardProInfo(){
		try {
			initGrid();
			StringBuffer head = new StringBuffer();
		          head.append("select t.card_type, ");
				  head.append("(select s.code_name from sys_code s where s.code_type='CHIP_TYPE'and s.code_value=t.chip_type) as chip_type , ");
				  head.append("(select s.code_name from sys_code s where s.code_type='CARD_TYPE_BANKSTRIPE'and s.code_value=t.Is_Bankstripe) as is_bankstripe , ");
				  head.append("(select s.code_name from sys_code s where s.code_type='CARD_TYPE_MEDIA'and s.code_value=t.media_type) as media_type , ");
				  head.append("(select s.code_name from sys_code s where s.code_type='CARD_TYPE_STATE'and s.code_value=t.pro_state) as pro_state , ");
				  head.append("t.card1_volumen,t.card1_version,t.card1_cos_vender,t.card2_volumen,t.card2_version,t.card2_cos_vender,t.brch_id,");
				  head.append("t.oper_id,t.org_id from CARD_PRODUCTS t where 1=1 ");
		  if(!Tools.processNull(this.cardType).equals("")){
			  head.append(" and t.card_type like '" + this.cardType.charAt(0) + "%' ");
			}
		  if(!Tools.processNull(this.chiType).equals("")){
			  head.append(" and t.chip_type = '" + this.chiType + "' ");
			}
		  if(!Tools.processNull(this.mediaType).equals("")){
			  head.append("and t.media_type = '" + this.mediaType + "' ");
			}
		
		  Page p = baseService.pagingQuery(head.toString(),page,rows);
		 if(p.getAllRs() != null){
				jsonObject.put("rows",p.getAllRs());
				jsonObject.put("total",p.getTotalCount());
		  }
		}catch(Exception e){
			jsonObject.put("status","1");
			jsonObject.put("errMsg",e.getMessage());
		}
		return this.JSONOBJ;
	}
	

	public String getChiType() {
		return chiType;
	}
	public void setChiType(String chiType) {
		this.chiType = chiType;
	}
	public String getMediaType() {
		return mediaType;
	}
	public void setMediaType(String mediaType) {
		this.mediaType = mediaType;
	}
	/**
	 * 删除卡片信息
	 * @return
	 */
	public String deleteMerCardPro(){
	   
		jsonObject.put("status","1");
		jsonObject.put("msg","");
		try{
			cardProductsService.delCardPro(cardType);
			jsonObject.put("msg","删除账户类型成功！");
			jsonObject.put("status","0");
		}catch(Exception e){
			jsonObject.put("msg",e.getMessage());
		}
		return this.JSONOBJ;
		
	}
	//初始化表格
		private void initGrid() throws Exception{
			jsonObject.put("rows",new JSONArray());//记录行数
			jsonObject.put("total",0);//总条数
			jsonObject.put("status",0);//查询状态
			jsonObject.put("errMsg","");//错误信息
		}

	public void setCardProductsService(CardProductsService cardProductsService) {
		this.cardProductsService = cardProductsService;
	}

	
}
