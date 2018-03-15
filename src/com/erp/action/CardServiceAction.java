package com.erp.action;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.log4j.Logger;
import org.apache.shiro.SecurityUtils;
import org.apache.struts2.ServletActionContext;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.Namespace;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.Results;
import org.springframework.beans.factory.annotation.Autowired;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.erp.exception.CommonException;
import com.erp.model.AccAccountSub;
import com.erp.model.AccQcqfLimit;
import com.erp.model.BaseMerchant;
import com.erp.model.BasePersonal;
import com.erp.model.CardAppSyn;
import com.erp.model.CardApply;
import com.erp.model.CardBaseinfo;
import com.erp.model.CardBindBankCard;
import com.erp.model.CardConfig;
import com.erp.model.CardFjmkSaleList;
import com.erp.model.SysActionLog;
import com.erp.model.TrServRec;
import com.erp.service.AccAcountService;
import com.erp.service.CardServiceService;
import com.erp.service.DoWorkClientService;
import com.erp.service.RechargeService;
import com.erp.service.Switchservice;
import com.erp.util.Arith;
import com.erp.util.CardIdValidator;
import com.erp.util.Constants;
import com.erp.util.DateUtil;
import com.erp.util.DealCode;
import com.erp.util.Tools;
import com.erp.viewModel.CardServiceLosModel;
import com.erp.viewModel.GridModel;
import com.erp.viewModel.Page;

import net.sf.jasperreports.engine.JasperRunManager;

@SuppressWarnings("serial")
@Namespace("/cardService")
@Action("cardServiceAction")
@InterceptorRef("jsondefalut")
@Results({
        @Result(name = "bkCardIndex", location = "/jsp/cardService/cardfill.jsp"),
        @Result(name = "hkCardIndex", location = "/jsp/cardService/changecard.jsp"),
        @Result(name = "toBhkZzINdex", location = "/jsp/cardService/bhkzz.jsp"),
        @Result(name = "tofjmkChangeCardIndex", location = "/jsp/cardService/fjmkChangeCard.jsp")
})
public class CardServiceAction extends BaseAction{
    public Logger log = Logger.getLogger(CardServiceAction.class);
    public CardServiceService cardServiceService;
    @Resource(name="accAcountService")
    private AccAcountService accAcountService;
    @Resource(name="rechargeService")
	private RechargeService rechargeService;
    public CardBaseinfo card = new CardBaseinfo();
    public BasePersonal person = new BasePersonal();
    public TrServRec rec = new TrServRec();
    public CardAppSyn cay = new CardAppSyn();
    private String queryType = "1";//查询类型 1 不进行查询,直接返回;0 进行查询,返回查询结果。
    private Long dealNo;
    public String lss_Flag;
    private String sort = "";
    private String order = "";
    private String selectId = "";
    private String certType;//证件类型
    private String certNo;//证件号码
    private String cardType;//卡类型
    private String cardNo;//卡号
    private String isGoodCard;
    private String cardAmt;
    private String zxreason;
    private String totalAmt;
    private String accKind;
    private String noAccKind;
    private String accState, fkDate;
    private String costFee = "0.00";
    private String costFeeSelect;
    private String defaultErrMsg;
    private CardConfig cfg = new CardConfig();
    private String merchantId = "";
    private String toExamine;
    private String bankCardNo;
    private String name;
    private String returnState;
    @Resource(name = "doWorkClientService")
    private DoWorkClientService doWorkClientService;
    private AccQcqfLimit limit = new AccQcqfLimit();
    private String oldCardNo;
    private String newCardNo;
    private String dealNo2;
    private String fjmkCostFee1;
    private String fjmkCostFee2;
    private String startDate;
    private String endTime;
    private String startMonth;
    private String endMonth;
    @Autowired
    private Switchservice switchservice;

    /**
     * 按照条件查询需要挂失的人员信息
     *
     * @return
     */
    public String findAllLostPerson(){
        try{
            this.initBaseDataGrid();
            if(!Tools.processNull(this.queryType).equals("0")){
                return this.JSONOBJ;
            }
            StringBuffer hql = new StringBuffer();
            hql.append("SELECT B.NAME,(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CERT_TYPE' AND CODE_VALUE = B.CERT_TYPE) CERTTYPE,");
            hql.append("T.CARD_ID,T.CARD_NO,DECODE(G.LSS_FLAG,'0','是','否') LSSFLAG,G.LSS_FLAG,T.CARD_STATE,B.CERT_NO,");
            hql.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CARD_TYPE' AND CODE_VALUE = T.CARD_TYPE ) CARDTYPE,");
            hql.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'BUS_TYPE' AND CODE_VALUE = T.BUS_TYPE) BUSTYPE,");
            hql.append("(SELECT CODE_NAME FROM SYS_CODE WHERE CODE_TYPE = 'CARD_STATE' AND CODE_VALUE = T.CARD_STATE) CARDSTATE ");
            hql.append("FROM CARD_BASEINFO T,BASE_PERSONAL B,CARD_CONFIG G ");
            hql.append("WHERE T.CUSTOMER_ID = B.CUSTOMER_ID(+) AND T.CARD_TYPE = G.CARD_TYPE ");
            if(!Tools.processNull(this.certType).equals("")){
                //where += " and b.cert_Type = '" + this.certType + "'";
            }
            if(!Tools.processNull(this.certNo).equals("")){
                hql.append("AND B.CERT_NO = '" + this.certNo + "'");
            }
            if(!Tools.processNull(this.cardType).equals("")){
                hql.append("AND T.CARD_TYPE = '" + this.cardType + "'");
            }
            if(!Tools.processNull(this.cardNo).equals("")){
                hql.append("AND T.CARD_NO = '" + this.cardNo + "'");
            }
            Page listview = cardServiceService.pagingQuery(hql.toString(), page, rows);
            if(listview.getAllRs() == null || listview.getAllRs().size() <= 0){
                throw new CommonException("未查询到对应卡信息，不能进行挂失！");
            }else{
                jsonObject.put("rows", listview.getAllRs());
                jsonObject.put("total", listview.getTotalCount());
            }
        }catch(Exception e){
            log.error(e);
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 挂失保存
     */
    public String tosavegs(){
        String lssFlagString = "";
        try{
            if(Tools.processNull(this.lss_Flag).equals("")){
                throw new CommonException("挂失类型不能为空！");
            }
            if(Tools.processNull(cardNo).equals("")){
                throw new CommonException("挂失卡号不能为空！");
            }
            if(Tools.processNull(lss_Flag).equals(Constants.LSS_FLAG_KTGS)){
                lssFlagString = "临时挂失";
            }else if(Tools.processNull(lss_Flag).equals(Constants.LSS_FLAG_SMGS)){
                lssFlagString = "书面挂失";
            }else{
                throw new CommonException("挂失类型选择不正确！");
            }
            card = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + cardNo + "'");
            if(card == null){
                throw new CommonException("卡片信息不存在！");
            }
            if(Tools.processNull(this.lss_Flag).equals("2")){
                if(Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_GS)){
                    throw new CommonException("该卡已是【书面挂失】状态，不能重复进行书面挂失！");
                }
                if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_YGS) && !Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZC)){
                    throw new CommonException("卡状态不是【正常或临时挂失】状态，不能进行书面挂失！");
                }
            }else if(Tools.processNull(this.lss_Flag).equals("1")){
                if(Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_YGS)){
                    throw new CommonException("该卡已是【临时挂失】状态，不能重复进行临时挂失！");
                }
                if(Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_GS)){
                    throw new CommonException("该卡已是【书面挂失】状态，不能再进行临时挂失！");
                }
                if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZC)){
                    throw new CommonException("卡状态不是【正常】状态，不能进行临时挂失！");
                }
            }else{
                throw new CommonException("传入挂失类型参数不正确！");
            }
            if(!Tools.processNull(card.getCustomerId()).equals("")){
                person = (BasePersonal) cardServiceService.findOnlyRowByHql("from BasePersonal where customerId = '" + card.getCustomerId() + "'");
            }
            if(person == null){
                person = new BasePersonal();
            }
            if(!Tools.processNull(card.getCustomerId()).equals("")){
                rec.setCustomerName(person.getName());
                rec.setCertType(person.getCertType());
                if(person.getCertType().equals(Constants.CERT_TYPE_SFZ) && person.getCertNo().length() == 15){
                    rec.setCertNo(CardIdValidator.cardidto18(person.getCertNo()));
                }else{
                    rec.setCertNo(person.getCertNo());
                }
                rec.setTelNo(person.getPhoneNo());
            }
            rec.setCustomerId(card.getCustomerId());
            rec.setCardId(card.getCardId());
            rec.setCardNo(card.getCardNo());
            rec.setCardType(card.getCardType());
            rec.setCardAmt(Long.valueOf("1"));
            rec.setBrchId(baseService.getUser().getBrchId());
            rec.setUserId(baseService.getUser().getUserId());
            rec.setClrDate(baseService.getClrDate());
            rec.setDealState(Constants.STATE_ZC);
            long dealNo = cardServiceService.savegs(card, rec, lss_Flag, null);
            String message = lssFlagString + "成功！";
            try {
				switchservice.updateCardState(card.getCardNo(), Constants.CARD_STATE_ZC, lss_Flag.equals("1") ? Constants.CARD_STATE_YGS : Constants.CARD_STATE_GS);
			} catch (Exception e) {
				message += "同步省厅失败【" + e.getMessage() + "】，请手动同步！";
			}
            jsonObject.put("dealNo", dealNo);
            jsonObject.put("status", true);
			jsonObject.put("message", message);
        }catch(Exception e){
            log.error(e);
            jsonObject.put("status", false);
            jsonObject.put("message", lssFlagString + "发生错误：" + e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * @return
     * @category 卡片解挂, 查询待解挂的人员, 卡信息
     */
    public String to_QueryJg(){
        GridModel gridModel = new GridModel();
        List<CardServiceLosModel> list = new ArrayList<CardServiceLosModel>();
        try{
            if(Tools.processNull(this.queryType).equals("0")){
                String hql = "select b.cardId, t.name, t.certType,t.certNo,b.cardType,b.cardNo,b.cardState,b.busType from BasePersonal t,CardBaseinfo b where t.customerId = b.customerId";
                if(!Tools.processNull(this.certType).equals("")){
                    //hql += " and t.certType = '" + this.certType + "'";
                }
                if(!Tools.processNull(this.certNo).equals("")){
                    hql += " and t.certNo = '" + this.certNo + "'";
                }
                if(!Tools.processNull(this.cardType).equals("")){
                    //hql += " and b.cardType = '" + this.cardType + "'";
                }
                if(!Tools.processNull(this.cardNo).equals("")){
                    hql += " and b.cardNo = '" + this.cardNo + "'";
                }
                //hql += " and b.cardState in ('" + Constants.CARD_STATE_GS + "','" + Constants.CARD_STATE_YGS + "')";
                List<?> listview = cardServiceService.findByHql(hql);
                if(listview != null && listview.size() > 0){
                    for(int i = 0; i < listview.size(); i++){
                        Object[] obj = (Object[]) listview.get(i);
                        CardServiceLosModel cardServiceLosModel = new CardServiceLosModel();
                        cardServiceLosModel.setId(Tools.processNull(obj[0]));// cardId
                        cardServiceLosModel.setName(Tools.processNull(obj[1]));//name
                        cardServiceLosModel.setCertType(cardServiceService.getCodeNameBySYS_CODE("CERT_TYPE", Tools.processNull(obj[2])));//certType
                        cardServiceLosModel.setCertNo(Tools.processNull(obj[3]));//certNo
                        cardServiceLosModel.setCardType(cardServiceService.getCodeNameBySYS_CODE("CARD_TYPE", Tools.processNull(obj[4])));//cardType
                        cardServiceLosModel.setCardNo(Tools.processNull(obj[5]));//cardNo
                        cardServiceLosModel.setCardState(cardServiceService.getCodeNameBySYS_CODE("CARD_STATE", Tools.processNull(obj[6])));//cardState
                        cardServiceLosModel.setBusType(cardServiceService.getCodeNameBySYS_CODE("BUS_TYPE", Tools.processNull(obj[7])));
                        list.add(cardServiceLosModel);
                    }
                }else{
                    throw new CommonException("未查询到已挂失或临时挂失的卡信息不能进行解挂！");
                }
            }
        }catch(Exception e){
            log.error(e);
            gridModel.setStatus(1);//查询表格出错
            gridModel.setErrMsg(e.getMessage());
        }
        gridModel.setRows(list);
        OutputJson(gridModel);
        return null;
    }

    /**
     * <p>解挂保存</p>
     *
     * @return 解挂保存是否成功
     */
    public String toSaveJg(){
        try{
            if(Tools.processNull(this.selectId).equals("")){
                throw new CommonException("请勾选一条卡信息进行解挂！");
            }
            CardBaseinfo cb = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + selectId + "'");
            if(cb == null){
                throw new CommonException("卡片信息不正确，不能进行解挂！");
            }
            if(!Tools.processNull(cb.getCardState()).equals(Constants.CARD_STATE_GS) && !Tools.processNull(cb.getCardState()).equals(Constants.CARD_STATE_YGS)){
                throw new CommonException("该卡片不是临时挂失或书面挂失状态，不能进行解挂！");
            }
            Long dealNo = cardServiceService.saveGj(cb, rec);
            String message = "解挂成功！";
           
            try {
				switchservice.updateCardState(cb.getCardNo(), cb.getCardState(), Constants.CARD_STATE_ZC);
			} catch (Exception e) {
				message += "同步省厅失败【" + e.getMessage() + "】，请手动同步！";
			}
			jsonObject.put("message", message);
            jsonObject.put("dealNo", dealNo);
            jsonObject.put("status", true);
        }catch(Exception e){
            log.error(e);
            jsonObject.put("status", false);
            jsonObject.put("message", e.getMessage());
        }
        return "jsonObj";
    }

    /**
     * 卡账户信息查询,此账户信息查询为公用代码,不同地方都会调用此处。
     *
     * @return
     */
    public String accountQuery(){
        jsonObject.put("rows", new JSONArray());
        jsonObject.put("total", 0);
        jsonObject.put("status", 0);
        jsonObject.put("errMsg", 0);
        try{
            if(this.queryType.equals("0")){
                StringBuffer sb = new StringBuffer();
                sb.append("select t.customer_id,t.acc_kind,b.name,(select c.code_name from sys_code c where c.code_type = 'CERT_TYPE' and c.code_value = b.cert_type) certtype,b.cert_no,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'CARD_TYPE' and s.code_value =  c.card_type) cardtype,c.card_no,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'BUS_TYPE' and s.code_value = c.bus_type) bustype,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'CARD_STATE' and s.code_value = c.card_state) cardstate,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'ACC_KIND' and s.code_value = t.acc_kind) acckind,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'ACC_STATE' and s.code_value = t.acc_state) accState,t.acc_state,");
                sb.append("(case when t.acc_kind <> '03' then trim(to_char(nvl(t.bal,0)/100,'999,990.99')) else to_char(t.bal)  end) bal ,");
                sb.append("(case when t.frz_date is not null then to_char(t.frz_date,'yyyy-mm-dd hh24:mi:ss') else '' end) frz_date,");
                sb.append("(case when t.acc_kind <> '03' then trim(to_char((nvl(t.bal,0) - nvl(t.frz_amt,0))/100,'999,990.99')) else to_char(nvl(t.bal,0) - nvl(t.frz_amt,0)) end) availableAmt,");
                sb.append("t.last_deal_date last_deal_date ,t.acc_no,t.acc_name,(case when t.acc_kind <> '03' then trim(to_char(nvl(t.frz_amt,0)/100,'999,999,990.99')) else to_char(t.frz_amt) end) frz_amt,");
                sb.append("(select a.full_name from sys_branch a where a.brch_id = t.open_brch_id) open_brch_id,");
                sb.append("(select q.name from Sys_Users q where q.user_id = t.open_user_id and q.brch_id = t.open_brch_id) open_user_id,");
                sb.append("(case when t.open_date is not null then to_char(t.open_date,'yyyy-mm-dd hh24:mi:ss') else '' end) open_date,");
                sb.append("(case when t.lss_date is not null then to_char(t.lss_date,'yyyy-mm-dd hh24:mi:ss') else '' end) lss_date,");
                sb.append("(case when t.cls_date is not null then to_char(t.cls_date,'yyyy-mm-dd hh24:mi:ss') else '' end) cls_date,");
                sb.append("(select q.name from Sys_Users q where q.user_id = t.cls_user_id) cls_user_id , ");
                sb.append("(case when t.lss_date is not null then to_char(t.lss_date + 7,'yyyy-mm-dd') else '' end ) fhrq, ");//BAL_RSLT
                sb.append("decode(t.bal_rslt,'0','未处理','已处理') bal_rslt,t.bal_rslt bal_rslt_flag ");
                sb.append("from ACC_ACCOUNT_SUB t,card_baseinfo c,base_personal b ");
                sb.append("where t.card_no = c.card_no and t.customer_id = b.customer_id(+) ");
                if(!Tools.processNull(certType).equals("")){
                    sb.append(" and b.cert_Type = '" + certType + "'");
                }
                if(!Tools.processNull(certNo).equals("")){
                    sb.append(" and b.cert_No = '" + certNo + "' ");
                }
                if(!Tools.processNull(cardType).equals("")){
                    sb.append(" and c.card_type = '" + cardType + "'");
                }
                if(!Tools.processNull(cardNo).equals("")){
                    sb.append(" and c.card_No = '" + cardNo + "' ");
                }
                if(!Tools.processNull(this.accKind).equals("")){
                    sb.append(" and t.acc_kind = '" + accKind + "' ");
                }
                if(!Tools.processNull(this.noAccKind).equals("")){
                    sb.append(" and t.acc_kind <> '" + noAccKind + "' ");
                }
                if(!Tools.processNull(this.accState).equals("")){
                    sb.append(" and t.acc_state = '" + accState + "' ");
                }
                if(!Tools.processNull(sort).equals("")){
                    sb.append(" order by " + sort + " " + this.getOrder());
                }else{
                    sb.append(" order by t.card_no desc, t.acc_kind asc ");
                }
                Page page = cardServiceService.pagingQuery(sb.toString(), 1, 1000);
                if(page.getAllRs() == null || page.getAllRs().size() <= 0){
                    throw new CommonException("根据指定信息未查询到对应账户信息！");
                }else{
                    jsonObject.put("rows", page.getAllRs());
                    jsonObject.put("total", page.getTotalCount());
                }
            }
        }catch(Exception e){
            log.error(e);
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return "jsonObj";
    }

    /**
     * 到达补卡首页
     *
     * @return
     */
    public String bkCardIndex(){
        try{
            //获取全功能卡类型参数信息,初始化补卡卡类型下拉框
            cfg = (CardConfig) baseService.findOnlyRowByHql("from CardConfig t where t.cardType = '" + Constants.CARD_TYPE_SMZK + "'");
            if(cfg == null){
                throw new CommonException("未找到全功能卡卡类型参数设置信息！");
            }
            costFee = Arith.cardreportsmoneydiv(Tools.processNull(cfg.getCostFee()).equals("") ? "0" : cfg.getCostFee() + "");
            costFeeSelect = "[";
            costFeeSelect += "{value:'0',text:'0.00'},";
            // 设置默认的工本费
            costFeeSelect += "{value:'" + costFee + "',text:'" + costFee + "','selected':true}]";
        }catch(Exception e){
            log.error(e);
            this.defaultErrMsg = e.getMessage();
        }
        return "bkCardIndex";
    }

    /**
     * 补卡查询
     *
     * @return
     */
    public String bkCardQuery(){
        jsonObject.put("rows", new JSONArray());
        jsonObject.put("total", 0);
        jsonObject.put("status", 0);
        jsonObject.put("errMsg", 0);
        try{
            if(this.queryType.equals("0")){
                if(Tools.processNull(this.certNo).trim().equals("") && Tools.processNull(this.cardNo).trim().equals("")){
                    throw new CommonException("请输入证件号码或是卡号进行查询！");
                }
                StringBuffer sb = new StringBuffer();
                sb.append("select b.customer_id,b.name,b.cert_no,");
                sb.append("(select s1.code_name from sys_code s1 where s1.code_type = 'CERT_TYPE' and s1.code_value = b.cert_type ) certtype,b.cert_type,");
                sb.append("(select s2.code_name from sys_code s2 where s2.code_type = 'SEX' and s2.code_value = b.gender ) genders,b.gender,");
                sb.append("t.card_id,t.card_no,");
                sb.append("(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_TYPE' and s3.code_value = t.card_type ) cardtype,t.card_type,");
                sb.append("(select s4.code_name from sys_code s4 where s4.code_type = 'CARD_STATE' and s4.code_value = t.card_state ) cardstate, t.card_state,");
                sb.append("t.start_date,t.valid_date,");
                sb.append("(select s5.code_name from sys_code s5 where s5.code_type = 'BUS_TYPE' and s5.code_value = t.bus_type) bustype, t.bus_type,");
                sb.append("decode(g.reissue_flag,'0','是','否') reissueflag , g.reissue_flag,");
                sb.append("to_char(nvl(g.cost_fee ,0)/100,'990.99') costfee,t.cost_fee ");
                sb.append("from card_baseinfo t,base_personal b,card_config g ");
                sb.append("where t.customer_id = b.customer_id and t.card_type = g.card_type ");
                if(!Tools.processNull(certType).equals("")){
                    sb.append(" and b.cert_Type = '" + certType + "' ");
                }
                if(!Tools.processNull(certNo).equals("")){
                    sb.append(" and b.cert_No = '" + certNo + "' ");
                }
                if(!Tools.processNull(cardType).equals("")){
                    sb.append(" and t.card_type = '" + cardType + "' ");
                }
                if(!Tools.processNull(cardNo).equals("")){
                    sb.append(" and t.card_No = '" + cardNo + "' ");
                }
                if(!Tools.processNull(this.card.getCardState()).equals("")){
                    sb.append(" and t.card_state = '" + this.card.getCardState() + "' ");
                }
                if(!Tools.processNull(sort).equals("")){
                    sb.append(" order by " + sort + " " + this.getOrder());
                }else{
                    sb.append(" order by t.card_no desc ");
                }
                Page page = cardServiceService.pagingQuery(sb.toString(), 1, 1000);
                if(page.getAllRs() == null || page.getAllRs().size() <= 0){
                    throw new CommonException("根据指定条件未查询到对应信息！");
                }else{
                    jsonObject.put("rows", page.getAllRs());
                    jsonObject.put("total", page.getTotalCount());
                }
            }
        }catch(Exception e){
            log.error(e);
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return "jsonObj";
    }

    /**
     * 换卡首页
     *
     * @return
     */
    public String hkCardIndex(){
        try{
            //获取全功能卡类型参数信息,初始化补卡卡类型下拉框
            cfg = (CardConfig) baseService.findOnlyRowByHql("from CardConfig t where t.cardType = '" + Constants.CARD_TYPE_SMZK + "'");
            if(cfg == null){
                throw new CommonException("未找到全功能卡卡类型参数设置信息！");
            }
            List allReason = baseService.findBySql("select code_name,code_value from sys_code where code_type = 'CHG_CARD_REASON' and code_state = '0'");
            String tempstring = "";
            //判断是否有免费换卡的权限
            if(allReason != null && allReason.size() > 0){
                for(int i = 0; i < allReason.size(); i++){
                    Object[] o = (Object[]) allReason.get(i);
                    if(o[1].toString().equals(Constants.CHG_CARD_REASON_ZLWT)){
                        if(SecurityUtils.getSubject().isPermitted("chgCardNoMoney")){
                            tempstring += "{codeName:'" + o[0].toString() + "',codeValue:'" + o[1].toString() + "'},";
                        }
                    }else{
                        tempstring += "{codeName:'" + o[0].toString() + "',codeValue:'" + o[1].toString() + "'},";
                    }
                }
            }
            if(!Tools.processNull(tempstring).equals("")){
                tempstring = tempstring.substring(0, tempstring.length() - 1);
            }
            isGoodCard = tempstring;
            costFee = Arith.cardreportsmoneydiv(Tools.processNull(cfg.getCostFee()).equals("") ? "0" : cfg.getCostFee() + "");
        }catch(Exception e){
            log.error(e);
            this.defaultErrMsg = e.getMessage();
        }
        return "hkCardIndex";
    }

    /**
     * 换卡查询
     *
     * @return
     */
    public String hkCardQuery(){
        jsonObject.put("rows", new JSONArray());
        jsonObject.put("total", 0);
        jsonObject.put("status", 0);
        jsonObject.put("errMsg", 0);
        try{
            if(this.queryType.equals("0")){
                if(Tools.processNull(this.certNo).trim().equals("") && Tools.processNull(this.cardNo).trim().equals("")){
                    throw new CommonException("请输入证件号码或是卡号进行查询！");
                }
                StringBuffer sb = new StringBuffer();
                sb.append("select b.customer_id,b.name,b.cert_no,");
                sb.append("(select s1.code_name from sys_code s1 where s1.code_type = 'CERT_TYPE' and s1.code_value = b.cert_type ) certtype,b.cert_type,");
                sb.append("(select s2.code_name from sys_code s2 where s2.code_type = 'SEX' and s2.code_value = b.gender ) genders,b.gender,");
                sb.append("t.card_id,t.card_no,");
                sb.append("(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_TYPE' and s3.code_value = t.card_type ) cardtype,t.card_type,");
                sb.append("(select s4.code_name from sys_code s4 where s4.code_type = 'CARD_STATE' and s4.code_value = t.card_state ) cardstate, t.card_state,");
                sb.append("t.start_date,t.valid_date,");
                sb.append("(select s5.code_name from sys_code s5 where s5.code_type = 'BUS_TYPE' and s5.code_value = t.bus_type) bustype, t.bus_type,");
                sb.append("decode(g.reissue_flag,'0','是','否') reissueflag , g.reissue_flag,g.chg_flag,decode(g.chg_flag,'0','是','否') chgflag ,");
                sb.append("to_char(nvl(g.cost_fee ,0)/100,'990.99') costfee,t.cost_fee ");
                sb.append("from card_baseinfo t,base_personal b,card_config g ");
                sb.append("where t.customer_id = b.customer_id and t.card_type = g.card_type ");
                if(!Tools.processNull(certType).equals("")){
                    sb.append(" and b.cert_Type = '" + certType + "' ");
                }
                if(!Tools.processNull(certNo).equals("")){
                    sb.append(" and b.cert_No = '" + certNo + "' ");
                }
                if(!Tools.processNull(cardType).equals("")){
                    sb.append(" and t.card_type = '" + cardType + "' ");
                }
                if(!Tools.processNull(cardNo).equals("")){
                    sb.append(" and t.card_No = '" + cardNo + "' ");
                }
                if(!Tools.processNull(this.card.getCardState()).equals("")){
                    sb.append(" and t.card_state = '" + this.card.getCardState() + "' ");
                }
                if(!Tools.processNull(sort).equals("")){
                    sb.append(" order by " + sort + " " + this.getOrder());
                }else{
                    sb.append(" order by t.card_no desc ");
                }
                Page page = cardServiceService.pagingQuery(sb.toString(), 1, 1000);
                if(page.getAllRs() == null || page.getAllRs().size() <= 0){
                    throw new CommonException("根据指定条件未查询到对应信息！");
                }else{
                    jsonObject.put("rows", page.getAllRs());
                    jsonObject.put("total", page.getTotalCount());
                }
            }
        }catch(Exception e){
            log.error(e);
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return "jsonObj";
    }

    /**
     * 补换卡保存
     *
     * @return
     */
    public String saveBhk(){
        jsonObject.put("status", "1");
        jsonObject.put("msg", "");
        try{
            if(Tools.processNull(this.cardNo).equals("")){
                throw new CommonException("老卡卡号不能为空！");
            }
            rec.setCostFee(Long.valueOf(Arith.cardmoneymun(costFee)));//工本费
            if(Tools.processNull(this.queryType).equals("1")){
                rec.setRsvOne(isGoodCard);//是否好卡 0
                if(Tools.processNull(this.isGoodCard).equals("0")){
                    rec.setPrvBal(Long.valueOf(Arith.cardmoneymun(this.cardAmt)));
                }else{
                    rec.setPrvBal(0L);
                }
            }else if(Tools.processNull(this.queryType).equals("0")){
                rec.setPrvBal(0L);//补卡时 卡面金额 默认0 以后台为准
                rec.setRsvOne("1");//补卡时 默认是坏卡
            }
            rec.setCardNo(cardNo);//老卡卡号
            rec.setAmt(Long.valueOf(Arith.cardmoneymun(costFee)));
            rec = cardServiceService.saveBhk(rec, baseService.getUser(), baseService.getCurrentActionLog(), this.queryType);
            jsonObject.put("dealNo", rec.getDealNo());
            jsonObject.put("status", "0");
            jsonObject.put("msg", (Tools.processNull(queryType).equals("0") ? "补卡成功！点击【确定】跳转打印凭证" : "换卡成功！点击【确定】跳转打印凭证"));
        }catch(Exception e){
            log.error(e);
            jsonObject.put("msg", (Tools.processNull(queryType).equals("0") ? "补卡发生错误：" : "换卡发生错误：") + e.getMessage());
        }
        return this.JSONOBJ;
    }

    /*
     * 注销查询
     */
    public String toZxquery(){
        jsonObject.put("rows", new JSONArray());
        jsonObject.put("total", 0);
        jsonObject.put("status", 0);
        jsonObject.put("errMsg", 0);
        try{
            if(queryType.equals("0")){
                if(Tools.processNull(this.certNo).equals("") && Tools.processNull(this.cardNo).equals("")){
                    throw new CommonException("请输入证件号码或卡号以进行查询！");
                }
                StringBuffer sb = new StringBuffer();
                sb.append("select t.customer_id,");
                sb.append("b.name,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'CERT_TYPE' and s.code_value = b.cert_type) cert_type,");
                sb.append("b.cert_no,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'CARD_TYPE' and s.code_value = t.card_type) card_type,");
                sb.append("t.card_no,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'CARD_STATE' and s.code_value = t.card_state) card_state,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'BUS_TYPE' and s.code_value = t.bus_type) bus_type,");
                sb.append("decode(g.redeem_flag,'0','是','否') redeem_flag ");//是否允许注销
                sb.append("from card_baseinfo t ,Base_Personal b,card_config g ");
                sb.append("where t.customer_id = b.customer_id(+) and t.card_type = g.card_type ");
                if(!Tools.processNull(this.certType).equals("")){
                    sb.append("and b.cert_type = '" + this.certType + "' ");
                }
                if(!Tools.processNull(this.certNo).equals("")){
                    sb.append("and b.cert_no = '" + this.certNo + "' ");
                }
                if(!Tools.processNull(this.cardType).equals("")){
                    sb.append("and t.card_type = '" + this.cardType + "' ");
                }
                if(!Tools.processNull(this.cardNo).equals("")){
                    sb.append("and t.card_no = '" + this.cardNo + "' ");
                }
                if(!Tools.processNull(this.sort).equals("")){
                    sb.append("order by " + this.sort + " " + this.order);
                }else{
                    sb.append("order by t.last_modify_date desc ");
                }
                Page list = cardServiceService.pagingQuery(sb.toString(), 1, 1000);
                if(list == null || list.getAllRs() == null){
                    throw new CommonException("根据指定信息未查询到对应账户信息！");
                }else{
                    jsonObject.put("rows", list.getAllRs());
                }
            }
        }catch(Exception e){
            log.error(e);
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return "jsonObj";
    }

    /**
     * 注销
     *
     * @return
     */
    public String zx(){
        jsonObject.put("status", "1");
        jsonObject.put("msg", "");
        jsonObject.put("dealNo", "");
        try{
            //1.判断卡信息
            if(Tools.processNull(this.isGoodCard).equals("")){
                throw new CommonException("是否是好卡参数传入不正确！");
            }
            CardBaseinfo card = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
            if(card == null){
                throw new CommonException("该卡信息不存在不能进行注销，请仔细核对后重试！");
            }
            if(Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZX)){
                throw new CommonException("该卡信息已注销，不能重复进行注销！");
            }
//			if(!Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_GS)){
//				throw new CommonException("该卡不是挂失状态不能进行注销！当前卡状态：" + cardServiceService.getCodeNameBySYS_CODE("CARD_STATE",card.getCardState()));
//			}
            rec = cardServiceService.saveZx(baseService.getUser(), baseService.getCurrentActionLog(), rec, card, isGoodCard, Arith.cardmoneymun(cardAmt), zxreason);
            String message = "注销成功！";
            try {
				switchservice.updateCardState(card.getCardNo(), card.getCardState(), Constants.CARD_STATE_ZX);
			} catch (Exception e) {
				message += "同步省厅失败【" + e.getMessage() + "】，请手动同步！";
			}
            jsonObject.put("status", "0");
            jsonObject.put("dealNo", rec.getDealNo());
			jsonObject.put("msg", message);
            jsonObject.put("dealNo", rec.getDealNo());
        }catch(Exception e){
            log.error(e);
            jsonObject.put("msg", e.getMessage());
        }
        return "jsonObj";
    }

    /**
     * 账户返还查询
     *
     * @return
     */
    @SuppressWarnings("unchecked")
    public String returnCashQuery(){
        jsonObject.put("rows", new JSONArray());
        jsonObject.put("total", 0);
        jsonObject.put("status", "0");
        jsonObject.put("errMsg", "");
        try{
            if(Tools.processNull(this.queryType).equals("0")){
                StringBuffer sb = new StringBuffer();
                sb.append("SELECT P.CUSTOMER_ID,P.NAME,");
                sb.append("(SELECT S3.CODE_NAME FROM SYS_CODE S3 WHERE S3.CODE_TYPE = 'CERT_TYPE' AND S3.CODE_VALUE = P.CERT_TYPE) CERT_TYPE,P.CERT_NO,");
                sb.append("(SELECT S4.CODE_NAME FROM SYS_CODE S4 WHERE S4.CODE_TYPE = 'CARD_TYPE' AND S4.CODE_VALUE = T.CARD_TYPE) CARD_TYPE,T.CARD_NO,");
                sb.append("(SELECT S1.CODE_NAME FROM SYS_CODE S1 WHERE S1.CODE_TYPE = 'CARD_STATE' AND S1.CODE_VALUE = T.CARD_STATE) CARDSTATE,");
                sb.append("(SELECT S2.CODE_NAME FROM SYS_CODE S2 WHERE S2.CODE_TYPE = 'BUS_TYPE' AND S2.CODE_VALUE = T.BUS_TYPE) BUSTYPE,T.CARD_STATE,");
                sb.append("DECODE(NVL(C.REDEEM_FLAG,'0'),'0','是','否') REDEEM_FLAG,TO_NUMBER(NVL(T.COST_FEE,0))/100 COST_FEE,TO_NUMBER(NVL(T.FOREGIFT,0))/100");
                sb.append(" FOREGIFT,TO_NUMBER(NVL(T.FOREGIFT_BAL,0))/100 FOREGIFT_BAL ");
                sb.append("FROM CARD_BASEINFO T,BASE_PERSONAL P,CARD_CONFIG C ");
                sb.append("WHERE T.CARD_TYPE = C.CARD_TYPE AND T.CUSTOMER_ID = P.CUSTOMER_ID(+) ");
                if(!Tools.processNull(this.certType).equals("")){
                    sb.append("AND P.CERT_TYPE = '" + this.certType + "' ");
                }
                if(!Tools.processNull(this.certNo).equals("")){
                    sb.append("AND P.CERT_NO = '" + this.certNo + "' ");
                }
                if(!Tools.processNull(this.cardType).equals("")){
                    sb.append("AND T.CARD_TYPE = '" + this.cardType + "' ");
                }
                if(!Tools.processNull(this.cardNo).equals("")){
                    sb.append("AND T.CARD_NO = '" + this.cardNo + "' ");
                }
                if(!Tools.processNull(bankCardNo).equals("")){
                    sb.append("AND T.BANK_CARD_NO = '" + this.bankCardNo + "' ");
                }
                if(!Tools.processNull(this.sort).equals("")){
                    sb.append("ORDER BY " + this.sort + " " + this.order);
                }else{
                    sb.append("ORDER BY T.LAST_MODIFY_DATE DESC ");
                }
                Page list = cardServiceService.pagingQuery(sb.toString(), 1, 10);
                if(list.getAllRs() != null){
                    Iterator<Object> its = list.getAllRs().iterator();
                    JSONArray finalArray = new JSONArray();
                    while(its.hasNext()){
                        JSONObject temp = (JSONObject) its.next();
                        List<Object[]> zxinfo = cardServiceService.findBySql("SELECT DECODE(R1.RSV_ONE,'0','联机 + 卡面','1','联机 + 钱包','2','联机'), TRIM(TO_CHAR(NVL(R1.PRV_BAL,0)/100,'999,990.99')),R1.RSV_ONE " +
                                "FROM (SELECT R.* FROM TR_SERV_REC R WHERE R.DEAL_CODE IN('" + DealCode.NAMEDCARD_REDEEM + "','" + DealCode.NAMEDCARD_REISSUE + "','" +
                                DealCode.NAMEDCARD_CHG + "') AND R.CARD_NO = '" + temp.getString("CARD_NO") + "' ORDER BY R.BIZ_TIME DESC) R1 WHERE ROWNUM = 1");
                        if(zxinfo != null && zxinfo.size() > 0){
                            Object[] io = zxinfo.get(0);
                            temp.put("RSV_ONE", io[0].toString());
                            temp.put("PRV_BAL", io[1].toString());
                            temp.put("RSV_ONE_FLAG", io[2].toString());
                            finalArray.add(temp);
                        }else{
                            temp.put("RSV_ONE", "未处理");
                            temp.put("PRV_BAL", "0");
                            temp.put("RSV_ONE_FLAG", "2");//未找到注销或补换卡记录
                            finalArray.add(temp);
                        }
                    }
                    jsonObject.put("rows", finalArray);
                }else{
                    throw new CommonException("未找到对应的卡片信息！");
                }
            }
        }catch(Exception e){
            log.error(e);
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 账户返还保存
     *
     * @return
     */
    public String saveReturnCash(){
        jsonObject.put("status", "1");
        jsonObject.put("msg", "");
        try{
            if(Tools.processNull(this.cardNo).equals("")){
                throw new CommonException("传入卡号不能为空！");
            }
            if(Tools.processNull(bankCardNo).equals("")){
                throw new CommonException("银行卡号不能为空！");
            }
            rec = cardServiceService.saveReturnCash(cardNo, bankCardNo, Long.valueOf(Arith.cardmoneymun(totalAmt)));
            jsonObject.put("dealNo", rec.getDealNo());
            jsonObject.put("status", "0");
        }catch(Exception e){
            log.error(e);
            jsonObject.put("msg", "余额返还登记失败, " + e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 补换卡转账首页
     *
     * @return
     */
    public String toBhkZzINdex(){
        try{

        }catch(Exception e){

        }
        return "toBhkZzINdex";
    }

    /**
     * 补换卡转账查询
     *
     * @return
     */
    public String toBhkZzQuery(){
        jsonObject.put("rows", new JSONArray());
        jsonObject.put("total", 0);
        jsonObject.put("status", "0");
        jsonObject.put("errMsg", "");
        try{
            if(Tools.processNull(this.queryType).equals("0")){
                //1.基本条件判断
                if(Tools.processNull(this.cardNo).equals("")){
                    throw new CommonException("新卡卡号不能为空！");
                }
                //2.新卡判断
                CardBaseinfo newCard = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
                if(newCard == null){
                    throw new CommonException("新卡卡片信息不存在！");
                }
    			//灰记录自动处理开始
                if(!Tools.processNull(this.cardNo).equals("") && !Tools.processNull(this.cardAmt).equals("") && !Tools.processNull(this.selectId).equals("")){
                    Map dealHjlMap = new HashMap();
                    dealHjlMap.put("cardNo",this.cardNo);
                    dealHjlMap.put("cardAmt",Arith.cardmoneymun(this.cardAmt));
                    dealHjlMap.put("cardTrCount",this.selectId);
                    Long qrDealNo = rechargeService.saveAutoWalletAshDeal(dealHjlMap,null,null);
                    jsonObject.put("qrDealNo_qrDealNo",qrDealNo);
                }
                //灰记录处理结束
                if(!Tools.processNull(newCard.getCardState()).equals(Constants.CARD_STATE_ZC)){
                    throw new CommonException("新卡卡片状态不正常，当前状态：" + cardServiceService.getCodeNameBySYS_CODE("CARD_STATE", newCard.getCardState()));
                }
                //3.新卡申领记录判断
                CardApply newCardApply = (CardApply) cardServiceService.findOnlyRowByHql("from CardApply t where t.cardNo = '" + this.cardNo + "'");
                if(newCardApply == null){
                    throw new CommonException("新卡申领记录信息不存在！");
                }
                if(!Tools.processNull(newCardApply.getApplyType()).equals(Constants.APPLY_TYPE_HK) && !Tools.processNull(newCardApply.getApplyType()).equals(Constants.APPLY_TYPE_BK)){
                    throw new CommonException("新卡申领类型不是补换卡，不能进行转账！");
                }
                // 如果新卡申领类型是补卡，不能进行转账
                if(Tools.processNull(newCardApply.getApplyType()).equals(Constants.APPLY_TYPE_BK)){
                    throw new CommonException("新卡申领类型是补卡，不能进行转账！");
                }
                if(Tools.processNull(newCardApply.getOldCardNo()).equals("")){
                    throw new CommonException("根据新卡申领记录找不到老卡卡号，不能进行转账！");
                }
                if(!Tools.processNull(newCardApply.getApplyState()).equals(Constants.APPLY_STATE_YFF)){
                    String cstate = cardServiceService.getCodeNameBySYS_CODE("APPLY_STATE", newCardApply.getApplyState());
                    throw new CommonException("新卡申领记录信息状态不是【已发放】状态，不能进行转账！新卡当前申领状态：【" + Tools.processNull(cstate) + "】");
                }
                //4.通过新卡申领记录获取老卡
                CardBaseinfo oldCard = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + newCardApply.getOldCardNo() + "'");
                if(oldCard == null){
                    throw new CommonException("老卡卡片信息不存在！");
                }
                if(!Tools.processNull(oldCard.getCardState()).equals(Constants.CARD_STATE_ZX)){
                    throw new CommonException("老卡卡片状态不是【注销】状态，不能进行转账！");
                }
                Object[] zxrec = (Object[]) cardServiceService.findOnlyRowBySql("select r1.deal_No, r1.prv_Bal,r1.rsv_one from (select r.* from tr_serv_rec r where r.deal_code in('" + DealCode.NAMEDCARD_REDEEM + "','" + DealCode.NAMEDCARD_REISSUE + "','" +
                        DealCode.NAMEDCARD_CHG + "') and r.card_no = '" + oldCard.getCardNo() + "' order by r.biz_time desc) r1 where rownum = 1");
                if(zxrec == null || zxrec.length < 2){
                    throw new CommonException("找不到原始老卡补换卡记录信息！");
                }
                //5.根据新卡持有人获取个人信息
                BasePersonal bp = (BasePersonal) cardServiceService.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + newCard.getCustomerId() + "'");
                if(bp == null){
                    throw new CommonException("客户信息不存在！");
                }
                if(!Tools.processNull(oldCard.getCustomerId()).equals(bp.getCustomerId() + "")){
                    throw new CommonException("新卡持有人和老卡持有人不匹配！");
                }
                JSONArray array = new JSONArray();
                JSONObject temprow = new JSONObject();
                temprow.put("V_V", "1");
                temprow.put("CUSTOMER_ID", newCard.getCustomerId());
                temprow.put("NAME", bp.getName());
                temprow.put("CERT_TYPE", cardServiceService.getCodeNameBySYS_CODE("CERT_TYPE", bp.getCertType()));
                temprow.put("CERT_NO", bp.getCertNo());
                temprow.put("CARD_STATE", oldCard.getCardState());
                temprow.put("CARD_TYPE", cardServiceService.getCodeNameBySYS_CODE("CARD_TYPE", oldCard.getCardType()));
                temprow.put("CARD_NO", oldCard.getCardNo());
                temprow.put("CARDSTATE", cardServiceService.getCodeNameBySYS_CODE("CARD_STATE", oldCard.getCardState()));
                temprow.put("BUSTYPE", cardServiceService.getCodeNameBySYS_CODE("BUS_TYPE", oldCard.getBusType()));
                if(Tools.processNull(zxrec[2].toString()).equals("0")){
                    temprow.put("RSV_ONE", "以卡面为准");
                    temprow.put("RSV_ONE_FLAG", zxrec[2].toString());
                    temprow.put("PRV_BAL", Arith.cardreportsmoneydiv(zxrec[1].toString()));
                }else{
                    temprow.put("RSV_ONE", "以账户为准");
                    temprow.put("RSV_ONE_FLAG", zxrec[2].toString());
                    temprow.put("PRV_BAL", "0.00");
                }
                array.add(temprow);
                jsonObject.put("rows", array);
            }
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", "换卡转钱包出现错误：" + e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 补换卡转账写灰记录
     *
     * @return
     */
    public String saveBhkZzAshHjl(){
        jsonObject.put("status", "1");
        jsonObject.put("msg", "");
        try{
            rec.setPrvBal(Long.valueOf(Arith.cardmoneymun(cardAmt)));
            rec.setAmt(Long.valueOf(Arith.cardmoneymun(totalAmt)));
            rec = cardServiceService.saveBhkZzTjHjl(rec, baseService.getUser());
            String camt = String.format("%010d", Long.valueOf(Arith.cardmoneymun(totalAmt)));
            String ctime = DateUtil.formatDate(rec.getBizTime(), "yyyyMMddHHmmss");
            jsonObject.put("dealNo", rec.getDealNo());
            jsonObject.put("status", "0");
            jsonObject.put("writecarddata", camt + ctime + "123456");//写卡字符串
        }catch(Exception e){
            jsonObject.put("msg", "换卡转钱包记录灰记录发生错误：" + e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 补换卡转账确认
     *
     * @return
     */
    public String saveBhkZzConfirm(){
        jsonObject.put("status", "1");
        jsonObject.put("msg", "");
        try{
            Map mp = new HashMap();
            mp.put("acptId", this.getUsers().getBrchId());
            mp.put("acptType", Constants.ACPT_TYPE_GM);
            mp.put("userId", this.getUsers().getUserId());
            mp.put("endDealNo", "");
            mp.put("dealNo", this.dealNo);
            mp.put("dealNo2", dealNo2);
            cardServiceService.saveBhkZzTjConfirm(mp);
            jsonObject.put("status", "0");
        }catch(Exception e){
            jsonObject.put("msg", "补换卡转账确认：" + e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 补换卡转账冲正
     *
     * @return
     */
    public String saveBhkZzCz(){
        jsonObject.put("status", "1");
        jsonObject.put("msg", "");
        try{
            cardServiceService.saveBhkZzTjCz(dealNo);
            jsonObject.put("status", "0");
        }catch(Exception e){
            log.error(e);
            jsonObject.put("msg", "补换卡转账冲正：" + e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 到达应用锁定首页
     *
     * @return
     */
    public String toAppLockIndex(){
        return this.JSONOBJ;
    }

    /**
     * 应用锁定查询
     *
     * @return
     */
    public String toAppLockQuery(){
        try{
            jsonObject.put("rows", new JSONArray());
            jsonObject.put("total", 0);
            jsonObject.put("status", 0);
            jsonObject.put("errMsg", "");
            if(queryType.equals("0")){
                if(Tools.processNull(this.certNo).equals("") && Tools.processNull(this.cardNo).equals("")){
                    throw new CommonException("请输入证件号码或卡号以进行查询！");
                }
                StringBuffer sb = new StringBuffer();
                sb.append("select t.customer_id,");
                sb.append("b.name,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'CERT_TYPE' and s.code_value = b.cert_type) certtype,");
                sb.append("b.cert_no,t.card_state,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'CARD_TYPE' and s.code_value = t.card_type) cardtype,");
                sb.append("t.card_no,t.start_date,t.valid_date,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'CARD_STATE' and s.code_value = t.card_state) cardstate,");
                sb.append("(select s.code_name from sys_code s where s.code_type = 'BUS_TYPE' and s.code_value = t.bus_type) bustype,");
                sb.append("decode(g.redeem_flag,'0','是','否') redeem_flag ");//是否允许注销
                sb.append("from card_baseinfo t ,Base_Personal b,card_config g ");
                sb.append("where t.customer_id = b.customer_id(+) and t.card_type = g.card_type ");
                if(!Tools.processNull(this.certType).equals("")){
                    sb.append("and b.cert_type = '" + this.certType + "' ");
                }
                if(!Tools.processNull(this.certNo).equals("")){
                    sb.append("and b.cert_no = '" + this.certNo + "' ");
                }
                if(!Tools.processNull(this.cardType).equals("")){
                    sb.append("and t.card_type = '" + this.cardType + "' ");
                }
                if(!Tools.processNull(this.cardNo).equals("")){
                    sb.append("and t.card_no = '" + this.cardNo + "' ");
                }
                if(!Tools.processNull(this.sort).equals("")){
                    sb.append("order by " + this.sort + " " + this.order);
                }else{
                    sb.append("order by t.last_modify_date desc ");
                }
                Page list = cardServiceService.pagingQuery(sb.toString(), 1, 1000);
                if(list == null || list.getAllRs() == null){
                    throw new CommonException("根据指定信息未查询到对应账户信息！");
                }else{
                    jsonObject.put("rows", list.getAllRs());
                }
            }
        }catch(Exception e){
            log.error(e);
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return "jsonObj";
    }

    /**
     * 应用锁定记录灰记录
     *
     * @return
     */
    public String saveAppLockHjl(){
        try{
            jsonObject.put("status", "1");
            jsonObject.put("msg", "");
            if(Tools.processNull(this.cardAmt).equals("")){
                rec.setPrvBal(Long.valueOf(Arith.cardreportsmoneymun(cardAmt)));
            }
            rec = cardServiceService.saveAppLockHjl(rec, baseService.getUser(), baseService.getCurrentActionLog());
            jsonObject.put("status", "0");
            jsonObject.put("dealNo", rec.getDealNo());
        }catch(Exception e){
            log.error(e);
            jsonObject.put("msg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 应用锁定灰记录确认
     *
     * @return
     */
    public String saveAppLockHjlConfirm(){
        try{
            jsonObject.put("status", "1");
            jsonObject.put("msg", "");
            cardServiceService.saveAppLockHjlConfirm(rec, baseService.getUser());
            jsonObject.put("status", "0");
        }catch(Exception e){
            log.error(e);
            jsonObject.put("msg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 应用锁定灰记录取消
     *
     * @return
     */
    public String saveAppLockHjlCancel(){
        try{
            jsonObject.put("status", "1");
            jsonObject.put("msg", "");
            cardServiceService.saveAppLockHjlCancel(rec, baseService.getUser(), baseService.getCurrentActionLog());
            jsonObject.put("status", "0");
        }catch(Exception e){
            log.error(e);
            jsonObject.put("msg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 应用解锁记录灰记录
     *
     * @return
     */
    public String saveAppUnlockHjl(){
        try{
            jsonObject.put("status", "1");
            jsonObject.put("msg", "");
            if(Tools.processNull(this.cardAmt).equals("")){
                rec.setPrvBal(Long.valueOf(Arith.cardreportsmoneymun(cardAmt)));
            }
            rec = cardServiceService.saveAppUnlockHjl(rec, baseService.getUser(), baseService.getCurrentActionLog());
            jsonObject.put("status", "0");
            jsonObject.put("dealNo", rec.getDealNo());
        }catch(Exception e){
            log.error(e);
            jsonObject.put("msg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 应用解锁灰记录确认
     *
     * @return
     */
    public String saveAppUnlockHjlConfirm(){
        try{
            jsonObject.put("status", "1");
            jsonObject.put("msg", "");
            cardServiceService.saveAppUnlockHjlConfirm(rec, baseService.getUser());
            jsonObject.put("status", "0");
        }catch(Exception e){
            log.error(e);
            jsonObject.put("msg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 应用解锁灰记录取消
     *
     * @return
     */
    public String saveAppUnlockHjlCancel(){
        try{
            jsonObject.put("status", "1");
            jsonObject.put("msg", "");
            cardServiceService.saveAppUnlockHjlCancel(rec, baseService.getUser(), baseService.getCurrentActionLog());
            jsonObject.put("status", "0");
        }catch(Exception e){
            log.error(e);
            jsonObject.put("msg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 此方法为N多公用方法，修改此处请注意兼容所有
     *
     * @return
     */
    public String getCardAndPersonInfo(){
        jsonObject.put("card", new CardBaseinfo());
        jsonObject.put("person", new BasePersonal());
        jsonObject.put("acc", new AccAccountSub());
        try{
            if(!Tools.processNull(cardNo).equals("")){
                CardBaseinfo tempcard = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
                if(tempcard != null){
                    //翻译
                    JSONObject o = new JSONObject();
                    o = JSONObject.parseObject(JSONObject.toJSONString(tempcard));
                    o.put("busTypeStr", cardServiceService.getCodeNameBySYS_CODE("BUS_TYPE", tempcard.getBusType()));
                    o.put("cardTypeStr", cardServiceService.getCodeNameBySYS_CODE("CARD_TYPE", tempcard.getCardType()));
                    o.put("note", cardServiceService.getCodeNameBySYS_CODE("CARD_STATE", tempcard.getCardState()));
                    jsonObject.put("card", o);
                    //获取个人信息
                    if(!Tools.processNull(tempcard.getCustomerId()).equals("")){
                        BasePersonal tempperson = (BasePersonal) cardServiceService.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + tempcard.getCustomerId() + "'");
                        if(tempperson != null){
                            JSONObject b = new JSONObject();
                            b = JSONObject.parseObject(JSONObject.toJSONString(tempperson));
                            b.put("certTypeStr", cardServiceService.getCodeNameBySYS_CODE("CERT_TYPE", tempperson.getCertType()));
                            b.put("csex", cardServiceService.getCodeNameBySYS_CODE("SEX", tempperson.getGender()));
                            jsonObject.put("person", b);
                        }
                    }
                    //获取账户信息
                    AccAccountSub acc = (AccAccountSub) cardServiceService.findOnlyRowByHql("from AccAccountSub t where t.cardNo = '" + tempcard.getCardNo() + "' and t.accKind = '02'");
                    if(acc != null){
                        jsonObject.put("acc", acc);
                    }
                  //如果是钱包充值
					if(Tools.processNull(this.queryType).equals("abcb")){
						if(!Tools.processNull(this.cardNo).equals("") && !Tools.processNull(this.cardAmt).equals("") && !Tools.processNull(this.selectId).equals("")){
							Map dealHjlMap = new HashMap();
							dealHjlMap.put("cardNo",this.cardNo);
							dealHjlMap.put("cardAmt",Arith.cardmoneymun(this.cardAmt));
							dealHjlMap.put("cardTrCount",this.selectId);
							Long qrDealNo = rechargeService.saveAutoWalletAshDeal(dealHjlMap,null,null);
							jsonObject.put("qrDealNo_qrDealNo",qrDealNo);
						}
					}else{
						jsonObject.put("qrDealNo_qrDealNo","-1");
					}
                }
            }
        }catch(Exception e){
            log.error(e);
        }
        return this.JSONOBJ;
    }

    /**
     * 柜面服务-卡服务-修改卡子类型  修改前先判断当前卡片是否可修改
     *
     * @param card_no 卡号
     */
    public String saveBusTypeModifyHjl(){
        jsonObject.put("status", "0");
        jsonObject.put("msg", "");
        jsonObject.put("validDate", "");
        CardBaseinfo card = null;
        try{
            String bus_type = super.request.getParameter("bus_type");
            if(Tools.processNull(cardNo).equals("") || Tools.processNull(bus_type).equals("")){
                jsonObject.put("status", "1");
                jsonObject.put("msg", "修改卡号或目标修改子类型不能为空！");
                return this.JSONOBJ;
            }
            card = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo t where  t.cardNo = '" + cardNo + "'");
            if(card == null){
                jsonObject.put("status", "1");
                jsonObject.put("msg", "当前卡片信息不存在，不能修改公交子类型！");
                return this.JSONOBJ;
            }
            if(Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_WQY)){
                jsonObject.put("status", "1");
                jsonObject.put("msg", "当前卡片信息未启用，不能修改公交子类型！");
                return this.JSONOBJ;
            }
            if(Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_GS) || Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_YGS)){
                jsonObject.put("status", "1");
                jsonObject.put("msg", "当前卡片信息已挂失，不能修改公交子类型！");
                return this.JSONOBJ;
            }
            if(Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZX)){
                jsonObject.put("status", "1");
                jsonObject.put("msg", "当前卡片信息已注销，不能修改公交子类型！");
                return this.JSONOBJ;
            }
            if(Tools.processNull(card.getCardState()).equals(Constants.CARD_STATE_ZF)){
                jsonObject.put("status", "1");
                jsonObject.put("msg", "当前卡片信息已作废，不能修改公交子类型！");
                return this.JSONOBJ;
            }
            BasePersonal bs = null;
            bs = (BasePersonal) cardServiceService.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + card.getCustomerId() + "'");
            if(bs == null){
                jsonObject.put("status", "1");
                jsonObject.put("msg", "当前卡片信息对应的人员信息不存在，不能修改公交子类型！");
                return this.JSONOBJ;
            }
            String bustypes = "00";
            CardBaseinfo cardinfo = (CardBaseinfo) cardServiceService.findOnlyRowByHql("select c from BasePersonal b,CardBaseinfo c where  c.cardState <> '9'  " +
                    "and  b.customerId = c.customerId  and c.busType in('11','20','33','21','10') and b.certNo='" + bs.getCertNo() + "' and c.cardNo <> '" + cardNo + "'");
            if(cardinfo != null && !Tools.processNull(bus_type).equals("01")){
                jsonObject.put("status", "1");
                jsonObject.put("msg", "已存在优惠老卡信息，不能修改公交子类型！");
                return this.JSONOBJ;
            }else{
                if(!Tools.processNull(bs.getCertType()).equals("1")){
                    bs.setCertNo("320282" + Tools.processNull(bs.getBirthday()).trim().replaceAll("-", "") + "1153");
                }
                Date date = cardServiceService.getDateBaseDate();
                Date date0 = DateUtil.formatDate(DateUtil.processDateAddYear(DateUtil.formatDate(bs.getCertNo().substring(6, 14), "yyyy-MM-dd"), 18));
                Date date1 = DateUtil.formatDate(DateUtil.processDateAddYear(DateUtil.formatDate(bs.getCertNo().substring(6, 14), "yyyy-MM-dd"), 60));
                Date date2 = DateUtil.formatDate(DateUtil.processDateAddYear(DateUtil.formatDate(bs.getCertNo().substring(6, 14), "yyyy-MM-dd"), 70));
                if((date.getTime() / (24 * 60 * 60 * 1000) - date0.getTime() / (24 * 60 * 60 * 1000)) < 0){
                    bustypes = "03";
                }
                if((date.getTime() / (24 * 60 * 60 * 1000) - date1.getTime() / (24 * 60 * 60 * 1000)) >= 0){
                    bustypes = "01";
                }
                if((date.getTime() / (24 * 60 * 60 * 1000) - date2.getTime() / (24 * 60 * 60 * 1000)) >= 0){
                    bustypes = "08";
                }
            }
            if(bus_type.equals("03")){
                Date date0 = DateUtil.formatDate(DateUtil.processDateAddYear(DateUtil.formatDate(bs.getCertNo().substring(6, 14), "yyyy-MM-dd"), 18));
                jsonObject.put("validDate", DateUtil.formatDate(date0, "yyyyMMdd"));
            }else{
                Date date0 = DateUtil.formatDate(DateUtil.processDateAddYear(DateUtil.formatDate(new Date(), "yyyy-MM-dd"), 10));
                jsonObject.put("validDate", DateUtil.formatDate(date0, "yyyyMMdd"));
            }
            if(Tools.processNull(bus_type).equals("33") || Tools.processNull(bus_type).equals("21") || Tools.processNull(bus_type).equals("01")){
                jsonObject.put("status", "0");
                jsonObject.put("isHjl", "0");
                rec = cardServiceService.saveBusTypeModifyHjl(bus_type, jsonObject.getString("validDate"), card, bs, cardServiceService.getUser(), cardServiceService.getCurrentActionLog());
                jsonObject.put("dealNo", rec.getDealNo());
                return this.JSONOBJ;
            }
            if(Tools.processNull(bus_type).equals(bustypes)){
                jsonObject.put("status", "0");
            }else{
                jsonObject.put("status", "1");
                jsonObject.put("msg", "当前卡片信息的公交子类型应为“" + cardServiceService.getCodeNameBySYS_CODE("BUS_TYPE", bustypes) + "”类型，不能修改到其他类型！");
            }
            jsonObject.put("isHjl", "0");
            rec = cardServiceService.saveBusTypeModifyHjl(bus_type, jsonObject.getString("validDate"), card, bs, cardServiceService.getUser(), cardServiceService.getCurrentActionLog());
            jsonObject.put("dealNo", rec.getDealNo());
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("msg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 公交类型修改灰记录确认
     *
     * @return
     */
    public String saveBusTypeModifyConfirm(){
        try{
            if(Tools.processNull(this.dealNo).equals("")){
                throw new CommonException("确认原流水不能为空！");
            }
            cardServiceService.saveBusTypeModifyConfirm(this.dealNo);
            jsonObject.put("status", "0");
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("msg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 公交类型修改灰记录取消
     *
     * @return
     */
    public String saveBusTypeModifyCancel(){
        try{
            if(Tools.processNull(this.dealNo).equals("")){
                throw new CommonException("取消原流水不能为空！");
            }
            cardServiceService.saveBusTypeModifyCancel(this.dealNo);
            jsonObject.put("status", "0");
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("msg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 服务密码解锁查询
     *
     * @return
     */
    public String queryServPwdInfo(){
        try{
            jsonObject.put("rows", new JSONArray());
            jsonObject.put("total", 0);
            jsonObject.put("status", 0);
            jsonObject.put("errMsg", "");
            if(queryType.equals("0")){
                if(Tools.processNull(this.certNo).equals("")){
                    throw new CommonException("请输入证件号码以进行查询！");
                }
                //查询系统配置的参数
                String errservpwd = (String) cardServiceService.findOnlyFieldBySql("select t.para_value from sys_para t where t.para_code = 'SERV_PWD_ERR_NUM'");
                StringBuffer sb = new StringBuffer();
                sb.append("SELECT T.CUSTOMER_ID,T.NAME,DECODE(T.CERT_TYPE,'身份证','2','户口簿','3','军官证','4','护照',");
                sb.append("'5','户籍证明','6','其他') CERT_TYPE,T.CERT_NO,(CASE WHEN nvl(t.serv_pwd_err_num,0) >" + errservpwd + "  THEN '是' ELSE ");
                sb.append("'否' END ) ISLOCKPWD FROM BASE_PERSONAL T WHERE 1=1 ");
                if(!Tools.processNull(this.certType).equals("")){
                    sb.append("and t.cert_type = '" + this.certType + "' ");
                }
                if(!Tools.processNull(this.certNo).equals("")){
                    sb.append("and t.cert_no = '" + this.certNo + "' ");
                }
                Page list = cardServiceService.pagingQuery(sb.toString(), 1, 1000);
                if(list == null || list.getAllRs() == null){
                    throw new CommonException("根据指定信息未查询到对应的信息！");
                }else{
                    jsonObject.put("rows", list.getAllRs());
                }
            }
        }catch(Exception e){
            log.error(e);
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return "jsonObj";
    }

    public String toSaveUndoServPwdInfo(){
        jsonObject.put("status", "1");
        jsonObject.put("msg", "");
        try{
            SysActionLog actionLog = cardServiceService.getCurrentActionLog();
            cardServiceService.saveundoServPwdorTradePwd(actionLog, "1", certNo, "");
            jsonObject.put("status", "0");
            jsonObject.put("msg", "解锁成功");
        }catch(Exception e){
            jsonObject.put("msg", e.getMessage());
        }
        return "jsonObj";
    }

    /**
     * 交易密码输入错误次数重置
     *
     * @return
     */
    public String queryPayPwdInfo(){
        try{
            jsonObject.put("rows", new JSONArray());
            jsonObject.put("total", 0);
            jsonObject.put("status", 0);
            jsonObject.put("errMsg", "");
            if(queryType.equals("0")){
                if(Tools.processNull(this.cardNo).equals("")){
                    throw new CommonException("请输入卡号以进行查询！");
                }
                //查询系统配置的参数
                String errpaypwd = (String) cardServiceService.findOnlyFieldBySql("select t.para_value from sys_para t where t.para_code = 'TRADE_PWD_ERR_NUM'");
                StringBuffer sb = new StringBuffer();
                sb.append("SELECT T.CUSTOMER_ID,T.NAME,DECODE(T.CERT_TYPE,'身份证','2','户口簿','3','军官证','4','护照',");
                sb.append("'5','户籍证明','6','其他') CERT_TYPE,T.CERT_NO,decode(t1.card_type,'100','全功能卡','其他卡') CARD_TYPE , t1.card_no CARD_NO ,(CASE WHEN nvl(t1.Pay_Pwd_Err_Num,0) >" + errpaypwd + "  THEN '是' ELSE ");
                sb.append("'否' END ) ISLOCKPWD FROM BASE_PERSONAL t,card_baseinfo t1  WHERE t.CUSTOMER_ID = t1.CUSTOMER_ID ");
                if(!Tools.processNull(this.cardType).equals("")){
                    sb.append("and t1.card_type = '" + this.cardType + "' ");
                }
                if(!Tools.processNull(this.cardNo).equals("")){
                    sb.append("and t1.card_no = '" + this.cardNo + "' ");
                }
                Page list = cardServiceService.pagingQuery(sb.toString(), 1, 1000);
                if(list == null || list.getAllRs() == null){
                    throw new CommonException("根据指定信息未查询到对应的信息！");
                }else{
                    jsonObject.put("rows", list.getAllRs());
                }
            }
        }catch(Exception e){
            log.error(e);
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return "jsonObj";
    }

    public String toSaveUndoPayPwdInfo(){
        jsonObject.put("status", "1");
        jsonObject.put("msg", "");
        try{
            SysActionLog actionLog = cardServiceService.getCurrentActionLog();
            cardServiceService.saveundoServPwdorTradePwd(actionLog, "2", "", cardNo);
            jsonObject.put("status", "0");
            jsonObject.put("msg", "解锁成功");
        }catch(Exception e){
            jsonObject.put("msg", e.getMessage());
        }
        return "jsonObj";
    }

    /**
     * 修改卡片有效日期
     *
     * @return
     */
    public String UpdateCardDate(){
        jsonObject.put("status", "1");
        jsonObject.put("msg", "");
        try{
            SysActionLog actionLog = cardServiceService.getCurrentActionLog();
            cardServiceService.saveCardDate(actionLog, fkDate, cardNo);
            jsonObject.put("status", "0");
            jsonObject.put("msg", "修改成功");
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("msg", e.getMessage());
        }
        return "jsonObj";
    }

    /**
     * 获取商户信息
     *
     * @return
     */
    public String getPosMainKeyMerInfo(){
        jsonObject.put("status", "1");
        jsonObject.put("merchantName", "");
        jsonObject.put("msg", "");
        try{
            BaseMerchant merchant = (BaseMerchant) cardServiceService.findOnlyRowByHql("from BaseMerchant t where t.merchantId='" + merchantId + "'");
            jsonObject.put("status", "0");
            jsonObject.put("merchantName", Tools.processNull(merchant.getMerchantName()));
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("msg", e.getMessage());
        }

        return "jsonObj";
    }

    public String getPosMainKey(){
        this.jsonObject.put("status", "1");
        this.jsonObject.put("mainkey", "1");
        this.jsonObject.put("dealDate", DateUtil.formatDate(new Date(), "yyyyMMddHHmmss"));
        this.jsonObject.put("msg", "");
        try{
            JSONArray returnstr = this.doWorkClientService.getPosMainKey(this.merchantId);
            if((returnstr == null) || (returnstr.isEmpty())){
                throw new CommonException("获取主密钥发生错误，返回值为null");
            }
            JSONObject return_first = returnstr.getJSONObject(0);
            if((returnstr == null) || (returnstr.isEmpty())){
                throw new CommonException("获取主密钥发生错误，返回值为null");
            }
            this.jsonObject.put("status", "0");
            this.jsonObject.put("mainkey", return_first.get("mainkey"));
        }catch(Exception e){
            this.jsonObject.put("status", "1");
            this.jsonObject.put("msg", e.getMessage());
        }
        return "jsonObj";
    }

    public String queryCardAccBalReturn(){
        try{
            initBaseDataGrid();
            String sql = "select deal_no, customer_id, customer_name, cert_no, card_no, rsv_two bank_card_no, "
                    + "amt, rsv_five flag, to_char(biz_time, 'yyyy-MM-dd hh24:mi:ss') deal_time, t.brch_id, "
                    + "t2.full_name brch_name ,user_id, note from tr_serv_rec t join sys_branch t2 "
                    + "on t.brch_id = t2.brch_id where t.deal_code = '" + DealCode.BALANCE_RESTORE + "' and deal_state = '"
                    + Constants.TR_STATE_ZC + "' ";
            if(!Tools.processNull(dealNo).equals("")){
                sql += "and t.deal_no = '" + dealNo + "' ";
            }
            if(!Tools.processNull(name).equals("")){
                sql += "and t.customer_name like '%" + name + "%' ";
            }
            if(!Tools.processNull(certNo).equals("")){
                sql += "and t.cert_no = '" + certNo + "' ";
            }
            if(!Tools.processNull(cardNo).equals("")){
                sql += "and t.card_no = '" + cardNo + "'";
            }
            if(!Tools.processNull(returnState).equals("")){
                sql += "and t.rsv_five = '" + returnState + "' ";
            }
            if(!Tools.processNull(sort).equals("")){
                sql += "order by " + sort;

                if(!Tools.processNull(order).equals("")){
                    sql += " " + order;
                }
            }

            Page pageData = cardServiceService.pagingQuery(sql, page, rows);

            if(pageData == null || pageData.getAllRs() == null || pageData.getAllRs().isEmpty()){
                throw new CommonException("没有数据.");
            }

            jsonObject.put("status", "0");
            jsonObject.put("total", pageData.getTotalCount());
            jsonObject.put("rows", pageData.getAllRs());
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return JSONOBJ;
    }

    public String confirmCardAccBalReturn(){
        try{
            if(dealNo == null){
                throw new CommonException("业务流水为空.");
            }

            cardServiceService.saveConfirmReturnCash(dealNo);

            jsonObject.put("status", "0");
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }

        return JSONOBJ;
    }

    public String cancelCardAccBalReturn(){
        try{
            if(dealNo == null){
                throw new CommonException("业务流水为空.");
            }
            cardServiceService.saveCancelReturnCash(dealNo);
            jsonObject.put("status", "0");
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }

        return JSONOBJ;
    }

    /**
     * @return
     * @author Yueh
     */
    public String getAccQcqfLimitInfo(){
        try{
            CardBaseinfo cardInfo = null;
            if(Tools.processNull(limit.getCardNo()).equals("")){
                throw new CommonException("卡号不能为空！");
            }else if(limit.getCardNo().length() == 9){
                cardInfo = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo where subCardNo = '" + limit.getCardNo() + "' and cardState = '" + Constants.CARD_STATE_ZC + "'");
            }else if(limit.getCardNo().length() == 20){
                cardInfo = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo where cardNo = '" + limit.getCardNo() + "'");
            }else{
                throw new CommonException("卡号不正确！");
            }
            if(cardInfo == null){
                throw new CommonException("根据卡号" + Tools.processNull(limit.getCardNo()) + "找不到卡片信息！");
            }
            BasePersonal person = (BasePersonal) cardServiceService.findOnlyRowByHql("from BasePersonal where customerId = '" + cardInfo.getCustomerId() + "'");
            if(person == null){
                throw new CommonException("人员信息不存在！");
            }
            if(Constants.CARD_TYPE_QGN.equals(cardInfo.getCardType())){
                CardBindBankCard bindInfo = (CardBindBankCard) cardServiceService.findOnlyRowByHql("from CardBindBankCard where id.certNo = '" + person.getCertNo() + "' and id.subCardNo = '" + cardInfo.getSubCardNo() + "'");
                if(bindInfo == null){
                    throw new CommonException("该卡片未绑定银行卡，不能进行限额信息设置！");
                }
            }
            AccQcqfLimit limit2 = (AccQcqfLimit) cardServiceService.findOnlyRowByHql("from AccQcqfLimit where cardNo = '" + cardInfo.getCardNo() + "' or subCardNo = '" + cardInfo.getSubCardNo() + "'");
            if(limit2 != null){
                limit = limit2;
            }else{
                limit.setCardType(cardInfo.getCardType());
                limit.setAccKind(Constants.ACC_KIND_ZJZH);
            }
            limit.setCardState(cardInfo.getCardState());
            limit.setName(person.getName());
            limit.setCertNo(person.getCertNo());
            limit.setQcLimitAmt(limit.getQcLimitAmt() == null ? 0 : limit.getQcLimitAmt() / 100);
            limit.setQtLimitAmt(limit.getQtLimitAmt() == null ? 0 : limit.getQtLimitAmt() / 100);
            limit.setQfLimitAmt(limit.getQfLimitAmt() == null ? 0 : limit.getQfLimitAmt() / 100);
            jsonObject.put("status", "0");
            jsonObject.put("limit", limit);
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return JSONOBJ;
    }

    /**
     * @return
     * @author Yueh
     */
    public String saveAccQcLimitInfo(){
        try{
            if(Tools.processNull(limit.getCardNo()).equals("")){
                throw new CommonException("卡号不能为空！");
            }else if(limit.getQcLimitAmt() == null){
                throw new CommonException("圈存限额不能为空！");
            }
            SysActionLog log = cardServiceService.getCurrentActionLog();
            limit.setQcLimitAmt(limit.getQcLimitAmt() * 100); // 元转为分
            cardServiceService.saveAccQcLimitInfo(limit, log);
            jsonObject.put("status", "0");
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return JSONOBJ;
    }

    public String bhkzzRegisterQuery(){
        try{
            initBaseDataGrid();
            if(Tools.processNull(cardNo).equals("")){
                throw new CommonException("卡号不能为空！");
            }
            String sql = "select t4.customer_id, t4.name, t4.cert_type, t4.cert_no, t.card_type, t.card_no, "
                    + "t.card_state, t2.bal qb_bal, t2.bal_rslt qb_bal_rslt, t3.state register_state, t5.apply_type cancel_reason, "
                    + "(select full_name from sys_branch where brch_id = t3.register_brch_id) register_brch_id, "
                    + "t3.register_user_id, to_char(t3.register_date, 'yyyy-mm-dd hh24:mi:ss') register_date, t3.deal_no "
                    + "from card_baseinfo t join acc_account_sub t2 on t.card_no = t2.card_no and t2.acc_kind = '"
                    + Constants.ACC_KIND_QBZH + "' "
                    + "left join card_apply t5 on t5.old_card_no = t.card_no and t.customer_id = t5.customer_id "
                    + "join base_personal t4 on t.customer_id = t4.customer_id "
                    + "left join bhk_zz_register t3 on t.card_no = t3.card_no where t.card_no <> '" + cardNo
                    + "' and exists (select 1 from card_baseinfo where t.customer_id = customer_id and card_no = '" + cardNo + "') order by t.issue_date";
            Page data = baseService.pagingQuery(sql, page, rows);
            if(data == null || data.getAllRs() == null || data.getAllRs().isEmpty()){
                throw new CommonException("根据条件找不到数据！");
            }
            jsonObject.put("total", data.getTotalCount());
            jsonObject.put("rows", data.getAllRs());
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return JSONOBJ;
    }

    public String bhkzzRegister(){
        try{
            if(Tools.processNull(cardNo).equals("")){
                throw new CommonException("卡号不能为空！");
            }
            SysActionLog log = cardServiceService.getCurrentActionLog();
            cardServiceService.saveBhkzzRegister(cardNo, log);
            jsonObject.put("stattus", "0");
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return JSONOBJ;
    }

    public String saveBhkZzBadCard(){
        jsonObject.put("status", "1");
        jsonObject.put("msg", "");
        try{
            rec.setPrvBal(Long.valueOf(Arith.cardmoneymun(cardAmt)));
            rec.setAmt(Long.valueOf(Arith.cardmoneymun(totalAmt)));
            rec = cardServiceService.saveBhkZzBadCardHjl(rec, baseService.getUser());
            String camt = String.format("%010d", Long.valueOf(Arith.cardmoneymun(totalAmt)));
            String ctime = DateUtil.formatDate(rec.getBizTime(), "yyyyMMddHHmmss");
            jsonObject.put("dealNo", rec.getDealNo());
            jsonObject.put("status", "0");
            jsonObject.put("writecarddata", camt + ctime + "123456");//写卡字符串
        }catch(Exception e){
            jsonObject.put("msg", "换卡转钱包记录灰记录发生错误：" + e.getMessage());
        }
        return this.JSONOBJ;
    }

    public String getCardAccBalInfo(){
        try{
            if(Tools.processNull(cardNo).equals("")){
                throw new CommonException("卡号不能为空！");
            }
            CardBaseinfo cardInfo = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo where cardNo = '" + cardNo + "'");
            if(cardInfo == null){
                throw new CommonException("根据卡号" + Tools.processNull(cardNo) + "找不到卡片信息！");
            }
            BasePersonal person = (BasePersonal) cardServiceService.findOnlyRowByHql("from BasePersonal where customerId = '" + cardInfo.getCustomerId() + "'");
            if(person == null){
                throw new CommonException("人员信息不存在！");
            }
            List<AccAccountSub> accs = (List<AccAccountSub>) cardServiceService.findByHql("from AccAccountSub where cardNo = '" + cardInfo.getCardNo() + "'");
            if(accs == null || accs.isEmpty()){
                throw new CommonException("卡片账户信息不存在！");
            }
            jsonObject.put("cardNo", cardInfo.getCardNo());
            jsonObject.put("subCardNo", cardInfo.getSubCardNo());
            jsonObject.put("cardType", cardInfo.getCardType());
            jsonObject.put("cardState", cardInfo.getCardState());
            jsonObject.put("name", person.getName());
            jsonObject.put("certType", person.getCertType());
            jsonObject.put("certNo", person.getCertNo());
            jsonObject.put("bankId", cardInfo.getBankId());
            jsonObject.put("bankCardNo", cardInfo.getBankCardNo());
            for(AccAccountSub acc : accs){
                if(acc.getAccKind().equals(Constants.ACC_KIND_ZJZH)){
                    jsonObject.put("ljAccBal", Arith.cardreportsmoneydiv(acc.getBal() + ""));
                    jsonObject.put("ljAccFrzBal", Arith.cardreportsmoneydiv(acc.getFrzAmt() + ""));
                }else if(acc.getAccKind().equals(Constants.ACC_KIND_QBZH)){
                    jsonObject.put("qbAccBal", Arith.cardreportsmoneydiv(acc.getBal() + ""));
                    jsonObject.put("qbAccFrzBal", Arith.cardreportsmoneydiv(acc.getFrzAmt() + ""));
                }
            }
            jsonObject.put("status", "0");
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return JSONOBJ;
    }

    @SuppressWarnings("deprecation")
    public String printCardAccBalCer(){
        try{
            getCardAccBalInfo();
            if(jsonObject.getString("status").equals("1")){
                return JSONOBJ;
            }
            SysActionLog log = cardServiceService.getCurrentActionLog();
            log.setDealNo(Long.valueOf(cardServiceService.getSequenceByName("SEQ_ACTION_NO")));
            log.setDealTime(new Date());
            log.setDealCode(0);
            String path = ServletActionContext.getRequest().getRealPath("/reportfiles/CardAccBalCer.jasper");
            Map<String,Object> map = new HashMap<String,Object>();
            map.putAll(jsonObject);
            map.put("cardType", cardServiceService.getCodeNameBySYS_CODE("CARD_TYPE", (String) map.get("cardType")));
            map.put("cardState", cardServiceService.getCodeNameBySYS_CODE("CARD_STATE", (String) map.get("cardState")));
            map.put("certType", cardServiceService.getCodeNameBySYS_CODE("CERT_TYPE", (String) map.get("certType")));
            map.put("p_DealNo", log.getDealNo() + "");
            map.put("p_Brch", cardServiceService.findOnlyFieldBySql("select full_name from sys_branch where brch_id = '" + log.getBrchId() + "'"));
            map.put("p_UserId", log.getUserId());
            map.put("p_UserName", getUsers().getName());
            map.put("p_printTime", DateUtil.formatDate(log.getDealTime()));
            byte[] pdfContent = JasperRunManager.runReportToPdf(path, map);
            cardServiceService.saveSysReport(log, new JSONObject(), "", Constants.APP_REPORT_TYPE_PDF2, 1l, "", pdfContent);
            jsonObject.put("dealNo", log.getDealNo());
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return JSONOBJ;
    }
    
    public String printChangeServiceBankCer(){
    	try{
            getCardAccBalInfo();
            if(jsonObject.getString("status").equals("1")){
                return JSONOBJ;
			} else if (!Constants.CARD_TYPE_SMZK.equals(jsonObject.getString("cardType"))) {
				throw new CommonException("该卡片类型不是金融市民卡！");
			}
            SysActionLog log = cardServiceService.getCurrentActionLog();
            log.setDealNo(Long.valueOf(cardServiceService.getSequenceByName("SEQ_ACTION_NO")));
            log.setDealTime(new Date());
            log.setDealCode(0);
            String path = ServletActionContext.getRequest().getRealPath("/reportfiles/changeServiceBank.jasper");
            Map<String,Object> map = new HashMap<String,Object>();
            map.putAll(jsonObject);
            map.put("p_Title", "嘉兴社会保障市民卡业务办理凭证");
            map.put("p_Deal_No", log.getDealNo() + "");
            map.put("p_Accept_Time", DateUtil.formatDate(log.getDealTime()));
            map.put("p_Card_No", map.get("cardNo"));
            map.put("p_sub_card_no", map.get("subCardNo"));
            map.put("p_Deal_Type", "更换服务银行");
            map.put("p_name", map.get("name"));
            map.put("p_cert_type", cardServiceService.getCodeNameBySYS_CODE("CERT_TYPE", (String) map.get("certType")));
            map.put("p_cert_no", map.get("certNo"));
            map.put("p_agt_name", rec.getAgtName());
            map.put("p_agt_cert_type", cardServiceService.getCodeNameBySYS_CODE("CERT_TYPE", rec.getAgtCertType()));
            map.put("p_agt_cert_no", rec.getAgtCertNo());
            map.put("p_bank_name", cardServiceService.findOnlyFieldBySql("select bank_name from base_bank where bank_id = '" + map.get("bankId") + "'"));
            map.put("p_bank_card_no", map.get("bankCardNo"));
            map.put("p_Accept_Branch_Name", cardServiceService.findOnlyFieldBySql("select full_name from sys_branch where brch_id = '" + log.getBrchId() + "'"));
            map.put("p_Accept_User_Id", log.getUserId());
            map.put("p_Accept_User_Name", getUsers().getName());
            byte[] pdfContent = JasperRunManager.runReportToPdf(path, map);
            cardServiceService.saveSysReport(log, new JSONObject(), "", Constants.APP_REPORT_TYPE_PDF2, 1l, "", pdfContent);
            jsonObject.put("dealNo", log.getDealNo());
        }catch(Exception e){
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return JSONOBJ;
    }

    /**
     * 根据卡号获取非个性化卡销售信息
     *
     * @return String
     */
    public String getFjmkSaleInfo(){
        try{
            this.jsonObject.put("card", new CardFjmkSaleList());
            this.jsonObject.put("person", new BasePersonal());
            this.jsonObject.put("status", "0");
            if(!Tools.processNull(this.cardNo).equals("")){
                CardFjmkSaleList cardFjmkSaleList = (CardFjmkSaleList) baseService.findOnlyRowByHql("from CardFjmkSaleList t where t.cardNo = '" + this.cardNo + "'");
                if(cardFjmkSaleList != null){
                    this.jsonObject.put("card", cardFjmkSaleList);
                    this.jsonObject.put("cardTypeStr", baseService.getCodeNameBySYS_CODE("CARD_TYPE", cardFjmkSaleList.getCardType()));
                    this.jsonObject.put("busTypeStr", "普通卡");
                    CardConfig config = (CardConfig) baseService.findOnlyRowByHql("from CardConfig t where t.cardType = '" + cardFjmkSaleList.getCardType() + "'");
                    if(config == null){
                        throw new CommonException("卡类型：" + cardFjmkSaleList.getCardType() + "，参数信息未设置！");
                    }
                    if(Tools.processNull(config.getCostFee()).equals("")){
                        throw new CommonException("卡类型：" + cardFjmkSaleList.getCardType() + "，工本费参数信息未设置！");
                    }
                    String tempstring = "";
                    tempstring += "{codeName:'" + Arith.cardmoneydiv(config.getCostFee() + "") + "',codeValue:'" + Arith.cardmoneydiv(config.getCostFee() + "") + "'}";
                    if(config.getCostFee() != 0 && Tools.processNull(config.getCardType()).equals(Constants.CARD_TYPE_FJMK) && SecurityUtils.getSubject().isPermitted("isNoMoneySaleFjmkPt")){
                        tempstring += ",{codeName:'" + "0" + "',codeValue:'" + "0" + "'}";
                    }
                    if(config.getCostFee() != 0 && Tools.processNull(config.getCardType()).equals(Constants.CARD_TYPE_FJMK_XS) && SecurityUtils.getSubject().isPermitted("isNoMoneySaleFjmkXs")){
                        tempstring += ",{codeName:'" + "0" + "',codeValue:'" + "0" + "'}";
                    }
                    this.jsonObject.put("isGoodCard", tempstring);
                    if(Tools.processNull(cardFjmkSaleList.getSaleState()).equals(Constants.SALE_STATE.YXS)){
                        BasePersonal basePersonal = (BasePersonal) baseService.findOnlyRowByHql("select b from BasePersonal b,CardBaseinfo c where b.customerId = c.customerId and c.cardNo = '" + cardFjmkSaleList.getCardNo() + "'");
                        if(basePersonal != null){
                            this.jsonObject.put("person", basePersonal);
                        }
                    }
                }
            }
        }catch(Exception e){
            this.jsonObject.put("status", "1");
            this.jsonObject.put("errMsg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 保存非个性化卡销售
     *
     * @return String
     */
    public String saveFjmkSale(){
        try{
            Map map = new HashMap();
            /** saleCardNo 销售卡号
             * saleCostFee 销售工本费
             * saleForegiftfee 销售押金
             * saleManager 客户经理
             * corpId 销售单位编号
             * corpName 销售单位名称
             * note 备注
             * */
            map.put("saleCardNo", this.cardNo);
            map.put("saleCostFee", Arith.cardmoneymun(this.costFee));
            map.put("saleForegiftfee", Arith.cardmoneymun("0"));
            map.put("saleManager", "");
            map.put("corpId", "");
            map.put("corpName", "");
            map.put("note", "");
            rec = cardServiceService.saveFjmkSell(map, rec, baseService.getCurrentActionLog(), baseService.getUser());
            this.jsonObject.put("status", "0");
            this.jsonObject.put("dealNo", rec.getDealNo());
        }catch(Exception e){
            this.jsonObject.put("status", "1");
            this.jsonObject.put("errMsg", e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 到达非记名卡换卡首页（支持不能类型的非记名卡，不同工本费）
     *
     * @return
     */
    public String toFjmkHkIndex(){
        try{
            CardConfig fjmk1 = (CardConfig) baseService.findOnlyRowByHql("from CardConfig t where t.cardType = '" + Constants.CARD_TYPE_FJMK + "'");
            if(fjmk1 == null){
                throw new CommonException("卡类型：" + Constants.CARD_TYPE_FJMK + "卡参数信息未设置！");
            }
            if(Tools.processNull(fjmk1.getCostFee()).equals("")){
                throw new CommonException("卡类型：" + Constants.CARD_TYPE_FJMK + "工本费参数信息未设置！");
            }
            fjmkCostFee1 = Arith.cardreportsmoneydiv(fjmk1.getCostFee() + "");
            CardConfig fjmk2 = (CardConfig) baseService.findOnlyRowByHql("from CardConfig t where t.cardType = '" + Constants.CARD_TYPE_FJMK_XS + "'");
            if(fjmk2 == null){
                throw new CommonException("卡类型：" + Constants.CARD_TYPE_FJMK_XS + "卡参数信息未设置！");
            }
            if(Tools.processNull(fjmk2.getCostFee()).equals("")){
                throw new CommonException("卡类型：" + Constants.CARD_TYPE_FJMK_XS + "工本费参数信息未设置！");
            }
            fjmkCostFee2 = Arith.cardreportsmoneydiv(fjmk2.getCostFee() + "");
        }catch(Exception e){
            this.defaultErrorMsg = e.getMessage();
        }
        return "tofjmkChangeCardIndex";
    }

    /**
     * 换卡查询
     * @return
     */
    public String fjmkHkCardQuery(){
        try{
            initBaseDataGrid();
            if(this.queryType.equals("0")){
                if(Tools.processNull(this.certNo).trim().equals("") && Tools.processNull(this.cardNo).trim().equals("")){
                    throw new CommonException("请输入证件号码或是卡号进行查询！");
                }
                StringBuffer sb = new StringBuffer();
                sb.append("select b.customer_id,b.name,b.cert_no,");
                sb.append("(select s1.code_name from sys_code s1 where s1.code_type = 'CERT_TYPE' and s1.code_value = b.cert_type ) certtype,b.cert_type,");
                sb.append("(select s2.code_name from sys_code s2 where s2.code_type = 'SEX' and s2.code_value = b.gender ) genders,b.gender,");
                sb.append("t.card_id,t.card_no,");
                sb.append("(select s3.code_name from sys_code s3 where s3.code_type = 'CARD_TYPE' and s3.code_value = t.card_type ) cardtype,t.card_type,");
                sb.append("(select s4.code_name from sys_code s4 where s4.code_type = 'CARD_STATE' and s4.code_value = t.card_state ) cardstate, t.card_state,");
                sb.append("t.start_date,t.valid_date,");
                sb.append("(select s5.code_name from sys_code s5 where s5.code_type = 'BUS_TYPE' and s5.code_value = t.bus_type) bustype, t.bus_type,");
                sb.append("decode(g.reissue_flag,'0','是','否') reissueflag , g.reissue_flag,g.chg_flag,decode(g.chg_flag,'0','是','否') chgflag ,");
                sb.append("to_char(nvl(g.cost_fee ,0)/100,'990.99') costfee,t.cost_fee ");
                sb.append("from card_baseinfo t,base_personal b,card_config g ");
                sb.append("where t.customer_id = b.customer_id(+) and t.card_type = g.card_type and t.card_type in ('" + Constants.CARD_TYPE_FJMK + "', '" + Constants.CARD_TYPE_FJMK_XS + "')");
                if(!Tools.processNull(certNo).equals("")){
                    sb.append(" and b.cert_No = '" + certNo + "' ");
                }
                if(!Tools.processNull(cardNo).equals("")){
                    sb.append(" and t.card_No = '" + cardNo + "' ");
                }
                if(!Tools.processNull(sort).equals("")){
                    sb.append(" order by " + sort + " " + this.getOrder());
                }else{
                    sb.append(" order by t.card_no desc ");
                }
                Page page = cardServiceService.pagingQuery(sb.toString(), 1, 1000);
                if(page.getAllRs() == null || page.getAllRs().size() <= 0){
                    throw new CommonException("根据指定条件未查询到对应信息！");
                }else{
                    jsonObject.put("rows", page.getAllRs());
                    jsonObject.put("total", page.getTotalCount());
                }
            }
        }catch(Exception e){
            log.error(e);
            jsonObject.put("status", "1");
            jsonObject.put("errMsg", e.getMessage());
        }
        return "jsonObj";
    }

    public String getFjmkCardInfo(){
        try{
            CardFjmkSaleList list = (CardFjmkSaleList) cardServiceService.findOnlyRowByHql("from CardFjmkSaleList t where t.cardNo = '" + cardNo + "'");
            if(list == null){
                throw new CommonException("根据卡号" + cardNo + "找不到非个性化卡信息！");
            }
            jsonObject.put("cardNo", list.getCardNo());
            jsonObject.put("cardState", list.getSaleState());
        }catch(Exception e){
            jsonObject.put("status", 1);
            jsonObject.put("errMsg", e.getMessage());
        }
        return JSONOBJ;
    }

    /**
     * 非记名卡补换卡保存
     * @return
     */
    public String saveFjmkHk(){
        try{
            if(Tools.processNull(cardNo).equals("")){
                throw new CommonException("老卡卡号不能为空！");
            }else if(Tools.processNull(newCardNo).equals("")){
                throw new CommonException("新卡卡号不能为空！");
            }
            rec.setCostFee(Long.valueOf(Arith.cardmoneymun(costFee)));
            rec.setRsvOne(isGoodCard);
            if(Tools.processNull(isGoodCard).equals("0")){
                rec.setPrvBal(Long.valueOf(Arith.cardmoneymun(cardAmt)));
            }else{
                rec.setPrvBal(0L);
            }
            rec.setCardNo(newCardNo);
            rec.setOldCardNo(cardNo);
            rec.setAmt(Long.valueOf(Arith.cardmoneymun(costFee)));
            rec = cardServiceService.saveFjmkHk(rec, baseService.getUser(), baseService.getCurrentActionLog());
            jsonObject.put("dealNo", rec.getDealNo());
            jsonObject.put("status", "0");
            jsonObject.put("msg", "换卡成功！点击【确定】跳转打印凭证");
        }catch(Exception e){
            log.error(e);
            jsonObject.put("msg", e.getMessage());
        }
        return JSONOBJ;
    }
    /**
     * 非记名卡补换卡转账查询
     * @return
     */
    public String toFjmkBhkZzQuery(){
        try{
            this.initBaseDataGrid();
            if(!Tools.processNull(this.queryType).equals("0")){
                return this.JSONOBJ;
            }
            if(Tools.processNull(this.cardNo).equals("")){
                throw new CommonException("新卡卡号不能为空！");
            }
            CardBaseinfo newCard = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo t where t.cardNo = '" + cardNo + "'");
            if(newCard == null){
                throw new CommonException("新卡卡片信息不存在！");
            }
            if(!Tools.processNull(newCard.getCardState()).equals(Constants.CARD_STATE_ZC)){
                throw new CommonException("新卡卡状态不正常，当前状态：" + cardServiceService.getCodeNameBySYS_CODE("CARD_STATE", newCard.getCardState()));
            }
            if(Tools.processNull(newCard.getCustomerId()).equals("")){
                //throw new CommonException("新卡未记名不能进行补换卡转钱包！");
            }
            StringBuffer sb = new StringBuffer();
            sb.append("select rownum rn,t.customer_id,b.name,b.cert_type,(select code_name from sys_code where code_type = 'CERT_TYPE' and code_value = b.cert_type) certtype,");
            sb.append("b.cert_no,t.card_state,(select code_name from sys_code where code_type = 'CARD_STATE' and code_value = t.card_state) cardstate,");
            sb.append("t.card_no,t.bus_type,(select code_name from sys_code where code_type = 'BUS_TYPE' and code_value = t.bus_type) bustype,");
            sb.append("nvl(i.is_good_card,'1') is_good_card,cast(decode(i.is_good_card,'0','以卡面为准','1','以账户为准','以账户为准') as varchar2(20)) isgoodcard,");
            sb.append("i.old_card_amt/100 prv_bal,t.card_type,(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.card_type) cardtype ");
            sb.append("from card_baseinfo t, base_personal b, card_config c,card_change_info i ");
            sb.append("where t.customer_id = b.customer_id(+) and t.card_type = c.card_type and t.card_no = i.old_card_no and t.card_type in ('" + Constants.CARD_TYPE_FJMK + "','" + Constants.CARD_TYPE_FJMK_XS + "') ");
            sb.append("and exists (select 1 from acc_account_sub s where s.card_no = t.card_no and s.acc_kind = '01' and s.BAL_RSLT = '0') ");
            if(!Tools.processNull(newCard.getCustomerId()).equals("")){
                sb.append("and t.customer_id = '" + newCard.getCustomerId() + "'");
            }else{
                sb.append("and i.new_card_no = '" + newCard.getCardNo() + "'");
            }
            sb.append("and t.card_state = '" + Constants.CARD_STATE_ZX + "' and t.card_no <> '" + newCard.getCardNo() + "'");
            Page page = cardServiceService.pagingQuery(sb.toString(),1,1000);
            if(page.getAllRs() == null || page.getAllRs().size() <= 0){
                throw new CommonException("根据指定条件未查询到对应信息！");
            }else{
                jsonObject.put("rows", page.getAllRs());
                jsonObject.put("total", page.getTotalCount());
            }
        }catch(Exception e){
            jsonObject.put("status","1");
            jsonObject.put("errMsg","换卡转钱包出现错误：" + e.getMessage());
        }
        return this.JSONOBJ;
    }
    /**
     * 非记名卡补换卡转账写灰记录
     */
    public String saveFjmkBhkZzAshHjl(){
        jsonObject.put("status", "1");
        jsonObject.put("msg","");
        try{
            rec.setPrvBal(Long.valueOf(Arith.cardmoneymun(cardAmt)));
            rec.setAmt(Long.valueOf(Arith.cardmoneymun(totalAmt)));
            rec = cardServiceService.saveBhkZzTjHjl2(rec, baseService.getUser());
            String camt = String.format("%010d", Long.valueOf(Arith.cardmoneymun(totalAmt)));
            String ctime = DateUtil.formatDate(rec.getBizTime(), "yyyyMMddHHmmss");
            jsonObject.put("dealNo", rec.getDealNo());
            jsonObject.put("status", "0");
            jsonObject.put("writecarddata", camt + ctime + "123456");//写卡字符串
        }catch(Exception e){
            jsonObject.put("msg", "换卡转钱包记录灰记录发生错误：" + e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 根据号码或是卡号查询应用开通情况
     * @return
     */
    public String cardAppOpenQuery(){
        try{
            this.initBaseDataGrid();
            if(!Tools.processNull(this.queryType).equals("0")){
                return this.JSONOBJ;
            }
            CardBaseinfo tempCard = null;
            BasePersonal tempBp = null;
            if(Tools.processNull(this.cardNo).equals("") && Tools.processNull(this.certNo).equals("")){
                throw new CommonException("请输入证件号码或是卡号进行查询！");
            }
            if(!Tools.processNull(this.certNo).equals("")){
                tempBp = (BasePersonal) cardServiceService.findOnlyRowByHql("from BasePersonal where certNo = '" + this.certNo + "'");
                if(tempBp == null){
                    throw new CommonException("根据证件号码" + this.certNo + "找不到客户信息！");
                }
            }
            if(!Tools.processNull(this.cardNo).equals("")){
                tempCard = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + this.getCardNo() + "'");
                if(tempCard == null){
                    throw new CommonException("根据卡号" + this.cardNo + "找不到卡信息！");
                }
                if(!Tools.processNull(tempCard.getCustomerId()).equals("") && tempBp == null){
                    tempBp = (BasePersonal)cardServiceService.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + tempCard.getCustomerId() + "'");
                    if(tempBp == null){
                        throw new CommonException("卡片对应客户信息不存在");
                    }
                }
            }else{
                throw new CommonException("请输入需要查询的卡号！");
            }
            this.jsonObject.put("card",tempCard);
            this.jsonObject.put("bp",tempBp);
            StringBuffer sb = new StringBuffer();
            sb.append("select t.data_id,t.customer_id,t.card_id,t.card_no,t.sub_card_no,");
            sb.append("t.card_type,(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.card_type) cardtype,");
            sb.append("t.app_type,decode(t.app_type,'01','广电','02','自来水','03','电力','04','过路过桥','05','自行车','06','移动','07','公园年卡','08','积分宝','09','新自行车','其他') apptype,");
            sb.append("t.state,decode(t.state,'0','正常','终止') statestr,to_char(t.last_modify_date,'yyyy-mm-dd hh24:mi:ss') last_modify_date,t.open_date,");
            sb.append("t.valid_date valid_date,nvl(t.open_fee,0)/100 openfee,t.merchant_id,m.merchant_name,");
            sb.append("t.the_only_no,t.clr_date,");
            sb.append("t.acpt_org_id,(case when t.acpt_type = '1' then (select org_name from sys_organ where org_id = t.acpt_org_id) when t.acpt_type = '2' then ");
            sb.append("(select co_org_name from base_co_org where co_org_id = t.acpt_org_id) else t.acpt_org_id end) acptorgname,");
            sb.append("t.acpt_type,");
            sb.append("(nvl((select full_name from sys_branch where brch_id = t.acpt_id),t.acpt_id)) acptid,");
            sb.append("nvl((select name from sys_users where user_id = t.user_id),t.user_id) user_id,");
            sb.append("t.end_deal_no,t.deal_no,t.note ");
            sb.append("from card_app_open t,card_baseinfo c,base_personal b,base_merchant m ");
            sb.append("where t.card_no = c.card_no and t.customer_id = b.customer_id and c.customer_id = b.customer_id ");
            sb.append("and t.merchant_id = m.merchant_id(+) ");
            if(tempCard != null){
                if(Tools.processNull(tempCard.getSubCardNo()).equals("")){
                    sb.append("and (t.card_no = '" + tempCard.getCardNo() + "' ");
                    sb.append("or t.sub_card_no = '" + tempCard.getSubCardNo() + "') ");
                }else{
                    sb.append("and t.card_no = '" + tempCard.getCardNo() + "' ");
                }
            }
            if(tempBp != null){
                sb.append("and t.customer_id = '" + tempBp.getCustomerId() + "' ");
            }
            if(!Tools.processNull(this.sort).equals("")){
                sb.append("order by " + this.sort + " " + this.order);
            }else{
                sb.append("order by t.app_type asc ");
            }
            JSONArray allData = new JSONArray();
            Page list = cardServiceService.pagingQuery(sb.toString(),1,100);
            if(list.getAllRs() != null && list.getAllRs().size() > 0){
                allData.addAll(list.getAllRs());
            }
            //兼容老的应用开通查询
            StringBuffer oldSb =  new StringBuffer();
            oldSb.append("select t.bind_id data_id,'' customer_id ,'' card_id , '' card_no,'' sub_card_no,'' card_type,");
            oldSb.append("'' cardtype, t.app_type,decode(t.app_type,'01','广电','02','自来水','03','电力','04','过路过桥','05','自行车','06','移动','07','公园年卡','08','积分宝','其他') apptype,");
            oldSb.append("t.bind_state state,decode(t.bind_state,'0','正常','失效') statestr,");
            oldSb.append("to_char(t.bind_date,'yyyy-mm-dd hh24:mi:ss') last_modify_date,to_char(t.bind_date,'yyyy-mm-dd') open_date,");
            oldSb.append("'' valid_date,0 openfee,'' merchant_id,'' merchant_name,t.family_no the_only_no,'' clr_date,");
            oldSb.append("'' acpt_org_id,'' acptorgname ,'' acpt_type,'' acptid,'' user_id,'' end_deal_no,'' deal_no,'' note ");
            oldSb.append("from card_app_bind t where 1 = 1 ");
            if(tempCard != null){
                oldSb.append("and t.card_no = '" + tempCard.getCardNo() + "' ");
            }
            if(!Tools.processNull(this.sort).equals("")){
                oldSb.append("order by " + this.sort + " " + this.order);
            }else{
                oldSb.append("order by t.bind_date desc ");
            }
            Page list2 = cardServiceService.pagingQuery(oldSb.toString(),1,100);
            if(list2.getAllRs() != null && list2.getAllRs().size() > 0){
                allData.addAll(list2.getAllRs());
            }
            jsonObject.put("rows",allData);
            if(allData.size() <= 0){
                jsonObject.put("execSql","0");
                jsonObject.put("errMsg","");
            }
        }catch(Exception e){
            this.jsonObject.put("status","1");
            this.jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }
    
    /**
     * 根据号码或是卡号查询应用开通情况
     * @return
     */
    public String cardZXCOpenQuery(){
        try{
            this.initBaseDataGrid();
            if(!Tools.processNull(this.queryType).equals("0")){
                return this.JSONOBJ;
            }
            CardBaseinfo tempCard = null;
            BasePersonal tempBp = null;
            if(Tools.processNull(this.cardNo).equals("") && Tools.processNull(this.certNo).equals("")){
                throw new CommonException("请输入证件号码或是卡号进行查询！");
            }
            if(!Tools.processNull(this.certNo).equals("")){
                tempBp = (BasePersonal) cardServiceService.findOnlyRowByHql("from BasePersonal where certNo = '" + this.certNo + "'");
                if(tempBp == null){
                    throw new CommonException("根据证件号码" + this.certNo + "找不到客户信息！");
                }
            }
            if(!Tools.processNull(this.cardNo).equals("")){
                tempCard = (CardBaseinfo) cardServiceService.findOnlyRowByHql("from CardBaseinfo c where c.cardNo = '" + this.getCardNo() + "'");
                if(tempCard == null){
                    throw new CommonException("根据卡号" + this.cardNo + "找不到卡信息！");
                }
                if(!Tools.processNull(tempCard.getCustomerId()).equals("") && tempBp == null){
                    tempBp = (BasePersonal)cardServiceService.findOnlyRowByHql("from BasePersonal t where t.customerId = '" + tempCard.getCustomerId() + "'");
                    if(tempBp == null){
                        throw new CommonException("卡片对应客户信息不存在");
                    }
                }
            }else{
                throw new CommonException("请输入需要查询的卡号！");
            }
            this.jsonObject.put("card",tempCard);
            this.jsonObject.put("bp",tempBp);
            StringBuffer sb = new StringBuffer();
            sb.append("select t.customer_id,t.card_id,t.card_no,t.sub_card_no,");
            sb.append("t.card_type,(select code_name from sys_code where code_type = 'CARD_TYPE' and code_value = t.card_type) cardtype,");
            sb.append("t.app_type,decode(t.app_type,'01','广电','02','自来水','03','电力','04','过路过桥','05','自行车','06','移动','07','公园年卡','08','积分宝','09','新自行车','10','自行车','其他') apptype,");
            sb.append("z.bind_state state,decode(z.bind_state,'0','正常','终止') statestr,to_char(z.bind_date,'yyyy-mm-dd hh24:mi:ss') last_modify_date,to_char(z.bind_date, 'yyyy-mm-dd') open_date,");
            sb.append("to_char(z.bind_date + 365*100,'yyyy-mm-dd') valid_date,nvl(a.deal_amt,0)/100 openfee,t.merchant_id,m.merchant_name,");
            sb.append("t.the_only_no,t.clr_date,");
            sb.append("t.acpt_org_id,(case when t.acpt_type = '1' then (select org_name from sys_organ where org_id = t.acpt_org_id) when t.acpt_type = '2' then ");
            sb.append("(select co_org_name from base_co_org where co_org_id = t.acpt_org_id) else t.acpt_org_id end) acptorgname,");
            sb.append("t.acpt_type,");
            sb.append("(nvl((select full_name from sys_branch where brch_id = t.acpt_id),t.acpt_id)) acptid,");
            sb.append("nvl((select name from sys_users where user_id = t.user_id),t.user_id) user_id,");
            sb.append("t.end_deal_no,t.deal_no,t.note ");
            sb.append("from card_app_syn t,card_baseinfo c,base_personal b,base_merchant m, card_app_bind z,acc_freeze_rec a ");
            sb.append("where t.card_no = c.card_no and t.customer_id = b.customer_id and c.customer_id = b.customer_id and t.deal_no = z.deal_no ");
            sb.append("and t.merchant_id = m.merchant_id(+) ");
            if(tempCard != null){
                if(Tools.processNull(tempCard.getSubCardNo()).equals("")){
                    sb.append("and (t.card_no = '" + tempCard.getCardNo() + "' ");
                    sb.append("or t.sub_card_no = '" + tempCard.getSubCardNo() + "') ");
                }else{
                    sb.append("and t.card_no = '" + tempCard.getCardNo() + "' ");
                }
            }
            if(tempBp != null){
                sb.append("and t.customer_id = '" + tempBp.getCustomerId() + "' ");
            }
            sb.append(" and rownum = 1");
            if(!Tools.processNull(this.sort).equals("")){
                sb.append("order by " + this.sort + " " + this.order);
            }else{
                sb.append("order by t.end_deal_no desc ");
            }
            JSONArray allData = new JSONArray();
            Page list = cardServiceService.pagingQuery(sb.toString(),1,100);
            if(list.getAllRs() != null && list.getAllRs().size() > 0){
                allData.addAll(list.getAllRs());
            }
            jsonObject.put("rows",allData);
            if(allData.size() <= 0){
                jsonObject.put("execSql","0");
                jsonObject.put("errMsg","");
            }
        }catch(Exception e){
            this.jsonObject.put("status","1");
            this.jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }
    
    /**
     * 》》应用开通与终止记录灰记录（开通与终止需写卡类应用）
     */
	public String saveCardAppOpenOrCloseHjl(){
        try{
            String operString = "";
            if(Tools.processNull(this.queryType).equals("0")){
                operString = "卡应用开通";
            }else if(Tools.processNull(this.queryType).equals("1")){
                operString = "卡应用取消";
            }
            if(Tools.processNull(rec.getCardNo()).equals("")){
                throw new CommonException(operString + "，卡号不能为空！");
            }
            if(Tools.processNull(rec.getRsvTwo()).equals("")){
                throw new CommonException(operString + "，应用类型不能为空！");
            }
            if(Tools.processNull(this.queryType).equals("0")){
                if(Tools.processNull(this.costFee).equals("")){
                    throw new CommonException(operString + "，开通费用不能为空！");
                }
            }
            Map<String,String> map = new HashMap<String,String>();
            map.put("cardNo",rec.getCardNo());
            map.put("appType",rec.getRsvTwo());
            if(Tools.processNull(this.queryType).equals("0")){
                map.put("fee",Arith.cardmoneymun(this.costFee));
            }else if(Tools.processNull(this.queryType).equals("1")){
            	map.put("fee",Arith.sub("0",Arith.cardmoneymun(this.costFee)));
            }
            map.put("theOnlyOne",rec.getRsvThree());//开通应用时关联的唯一号
            map.put("operType",this.queryType);//借用查询类型queryType参数标识业务类型 0应用开通；1应用终止
            rec.setAmt(Long.valueOf(Arith.cardmoneymun(this.costFee)));
            rec = cardServiceService.saveCardAppOpenOrCloseHjl(map,cardServiceService.getUser(),rec,null);
            this.jsonObject.put("status","0");
            this.jsonObject.put("dealNo",rec.getDealNo());
            this.jsonObject.put("writecarddata",rec.getRsvFour());
            String camt = String.format("%010d",Long.valueOf(Arith.cardmoneymun(this.costFee)));
			String ctime = DateUtil.formatDate(rec.getBizTime(),"yyyyMMddHHmmss");
            this.jsonObject.put("writecarddata2",camt + ctime + "123456");
        }catch(Exception e){
            this.jsonObject.put("status","1");
            this.jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }
    /**
     * 》》应用开通灰记录确认（开通与终止需写卡类应用）
     */
    public String saveCardAppOpenOrCloseConfirm(){
        try{
            /**
             * 1、确认流水
             * 2、确认类型 0 自动确认 1 手工确认（手工确认时会记录确认日志信息）
             * 3、业务类型 0 开通  1 终止
             */
        	String ywlx = this.request.getParameter("ywlx");
            cardServiceService.saveCardAppOpenOrCloseHjlConfirm(rec.getDealNo(),this.queryType,ywlx);
            this.jsonObject.put("status","0");
        }catch(Exception e){
            this.jsonObject.put("status","1");
            this.jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }
    /**
     * 》》应用开通灰记录取消（开通与终止需写卡类应用）
     */
    public String saveCardAppOpenOrCloseCancel(){
        try{
            /**
             * 1、取消流水
             * 2、取消类型 0 自动取消 1 手工取消（手工取消时会记录取消日志信息）
             * 3、业务类型 0 开通  1 终止
             */
        	String ywlx = this.request.getParameter("ywlx");
            cardServiceService.saveCardAppOpenOrCloseHjlCancel(rec.getDealNo(),this.queryType,ywlx);
            this.jsonObject.put("status","0");
        }catch(Exception e){
            log.error(this.saveErrLog(e));
            this.jsonObject.put("status","1");
            this.jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }
    /**
     * 》》查询自行车开通与终止的灰记录信息
     */
    public String queryCardAppOpenOrCloseHjl(){
        try{
            this.initBaseDataGrid();
            StringBuffer sb = new StringBuffer();
            sb.append("select t.deal_no selectid,t.deal_no,t.customer_name,(select s1.code_name from sys_code s1 ");
            sb.append("where s1.code_type = 'CERT_TYPE' and s1.code_value = t.cert_type) certtype,t.cert_no, ");
            sb.append("t.card_no,(select s2.code_name from sys_code s2 where s2.code_type = 'CARD_TYPE' and ");
            sb.append("s2.code_value = t.card_type) cardtype,to_char(t.biz_time,'yyyy-mm-dd hh24:mi:ss') biztime,t.deal_code,");
            sb.append("r.deal_code_name, t.deal_state,decode(t.deal_state,'0','正常','2','已冲正','9','灰记录','其他') dealstate,");
            sb.append("(select b1.full_name from sys_branch b1 where b1.brch_id = t.brch_id) brchname ,");
            sb.append("(select u1.name from sys_users u1 where u1.user_id = t.user_id) username ");
            sb.append("from tr_serv_rec t,sys_code_tr r \n");
            sb.append("where t.deal_code = r.deal_code(+) \n ");
            sb.append("and t.deal_state = '" + Constants.TR_STATE_HJL + "' ");
            String tempQueryType = this.request.getParameter("tempQueryType");
            if(Tools.processNull(tempQueryType).equals("0")){
            	sb.append("and t.deal_code = '" + DealCode.ZXC_APP_OPEN + "' ");
            }else if(Tools.processNull(tempQueryType).equals("1")){
            	sb.append("and t.deal_code = '" + DealCode.ZXC_APP_CANCEL + "' ");
            }else {
				throw new CommonException("查询类型不正确！");
			}
            if(!Tools.processNull(this.cardNo).equals("")){
                sb.append("and t.card_no = '" + this.cardNo + "' ");
            }
            if(!Tools.processNull(this.sort).equals("")){
                sb.append("order by " + this.sort + " " + this.order);
            }else{
                sb.append("order by t.deal_no desc ");
            }
            Page page = cardServiceService.pagingQuery(sb.toString(),1,100);
            if(page.getAllRs() == null || page.getAllRs().size() <= 0){
                throw new CommonException("根据指定条件未查询到对应信息！");
            }else{
                jsonObject.put("rows", page.getAllRs());
                jsonObject.put("total", page.getTotalCount());
            }
        }catch(Exception e){
            this.jsonObject.put("status","1");
            this.jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }

    /**
     * 》》应用开通与取消(直接开通与终止类应用，无需写卡)
     */
    public String saveCardAppOpenOrClose(){
    	String operString = "";
        try{
            if(Tools.processNull(this.queryType).equals("0")){
                operString = "卡应用开通";
            }else if(Tools.processNull(this.queryType).equals("1")){
                operString = "卡应用终止";
            }
            if(Tools.processNull(rec.getCardNo()).equals("")){
                throw new CommonException(operString + "，卡号不能为空！");
            }
            if(Tools.processNull(rec.getRsvTwo()).equals("")){
                throw new CommonException(operString + "，应用类型不能为空！");
            }
            if(Tools.processNull(this.queryType).equals("0")){
                if(Tools.processNull(this.costFee).equals("")){
                    throw new CommonException(operString + "，开通费用不能为空！");
                }
            }
            Map map = new HashMap();
            map.put("cardNo",rec.getCardNo());
            map.put("appType",rec.getRsvTwo());
            if(Tools.processNull(this.queryType).equals("0")){
                map.put("fee",Arith.cardmoneymun(this.costFee));
            }else if(Tools.processNull(this.queryType).equals("1")){
                map.put("fee",0L);
            }
            map.put("theOnlyOne",rec.getRsvThree());
            map.put("operType",this.queryType);
            rec = cardServiceService.saveCardAppOpenOrClose(map,cardServiceService.getUser(),rec,null);
            this.jsonObject.put("status","0");
            this.jsonObject.put("dealNo",rec.getDealNo());
            this.jsonObject.put("errMsg",operString + "成功！");
        }catch(Exception e){
            log.error(e);
            this.jsonObject.put("status","1");
            this.jsonObject.put("errMsg",this.saveErrLog(new CommonException("同步" + operString + "状态出现错误：" + e.getMessage())));
        }
        return this.JSONOBJ;
    }
    
    
    /**
     * 》》自行车开通与取消(需写卡)
     */
    public String saveZXCAppOpenOrClose(){
    	String operString = "";
        try{
            if(Tools.processNull(this.queryType).equals("0")){
                operString = "卡应用开通";
            }else if(Tools.processNull(this.queryType).equals("1")){
                operString = "卡应用终止";
            }
            if(Tools.processNull(rec.getCardNo()).equals("")){
                throw new CommonException(operString + "，卡号不能为空！");
            }
            if(Tools.processNull(rec.getRsvTwo()).equals("")){
                throw new CommonException(operString + "，应用类型不能为空！");
            }
            if(Tools.processNull(this.queryType).equals("0")){
                if(Tools.processNull(this.costFee).equals("")){
                    throw new CommonException(operString + "，开通费用不能为空！");
                }
            }
            Map map = new HashMap();
            map.put("cardNo",rec.getCardNo());
            map.put("appType",rec.getRsvTwo());
            map.put("amt", rec.getCostFee());
            map.put("acptType", rec.getAcptType());
            if(Tools.processNull(this.queryType).equals("0")){
                map.put("fee",Arith.cardmoneymun(this.costFee));
            }else if(Tools.processNull(this.queryType).equals("1")){
                map.put("fee",0L);
            }
            map.put("theOnlyOne",rec.getRsvThree());
            map.put("operType",this.queryType);
            cay = cardServiceService.saveZXCAppOpenOrClose(map,cardServiceService.getUser(),rec,null);
            this.jsonObject.put("status","0");
            this.jsonObject.put("dealNo",cay.getDealNo());
            this.jsonObject.put("errMsg",operString + "成功！");
        }catch(Exception e){
            log.error(e);
            this.jsonObject.put("status","1");
            this.jsonObject.put("errMsg",this.saveErrLog(new CommonException("同步" + operString + "状态出现错误：" + e.getMessage())));
        }
        return this.JSONOBJ;
    }
    
    //自行车应用开通终止明细查询
    public String queryZXCDetailed(){
        try{
        	
            this.initBaseDataGrid();
            StringBuffer sb = new StringBuffer();
            sb.append("select t.customer_name,t.cert_no,t.card_no,to_char(t.biz_time,'YYYY-MM-DD') biz_time,");
            sb.append("decode( t.rsv_one,'00','开通','03','终止') rsv_one,t.rtn_fgft / 100 rtn_fgft,");
            sb.append("(select full_name from sys_branch where brch_id = t.brch_id) acpt_id,");
            sb.append("(select name from sys_users where user_id = t.user_id) user_id ");
            sb.append("from tr_serv_rec t ");
            sb.append("where t.rsv_one in  ('00','03')");
            
            if(!Tools.processNull(this.certNo).equals("")){
                sb.append("and t.cert_no = '" + this.certNo + "' ");
            }
            if(!Tools.processNull(this.cardNo).equals("")){
                sb.append("and t.card_no = '" + this.cardNo + "' ");
            }
            if(!Tools.processNull(startDate).equals("")){
				sb.append(" and to_char(t.biz_time, 'YYYY-MM-DD') >='"+Tools.processNull(startDate)+"'");
			}
			if(!Tools.processNull(endTime).equals("")){
				sb.append(" and to_char(t.biz_time, 'YYYY-MM-DD') <='"+Tools.processNull(endTime)+"'");
			}
            sb.append(" order by biz_time desc");
            Page page = cardServiceService.pagingQuery(sb.toString(),1,100);
            if(page.getAllRs() == null || page.getAllRs().size() <= 0){
                throw new CommonException("根据指定条件未查询到对应信息！");
            }else{
                jsonObject.put("rows", page.getAllRs());
                jsonObject.put("total", page.getTotalCount());
            }
        }catch(Exception e){
            this.jsonObject.put("status","1");
            this.jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }
    
    
    
    //自行车应用开通终止汇总查询
    public String queryZXCAggregatQuery(){
        try{
            this.initBaseDataGrid();
            StringBuffer sb = new StringBuffer();
            sb.append("select to_char(t.biz_time,'MM') mon,");
            sb.append("nvl(sum(decode(t.rsv_one, '00', t.num)), 0) open_num,");
            sb.append("nvl(sum(decode(t.rsv_one, '00', t.rtn_fgft)), 0) open_sum,");
            sb.append("nvl(sum(decode(t.rsv_one, '03', t.num)), 0) close_num,");
            sb.append("nvl(sum(decode(t.rsv_one, '03', t.rtn_fgft)), 0) close_sum ");
            sb.append("from tr_serv_rec t ");
            sb.append("where to_char(t.biz_time, 'YYYY') = to_char(sysdate, 'YYYY')");
			sb.append(" group by to_char(t.biz_time,'MM')");
			sb.append(" order by to_char(t.biz_time,'MM') asc");
            Page page = cardServiceService.pagingQuery(sb.toString(),1,100);
            if(page.getAllRs() == null || page.getAllRs().size() <= 0){
                throw new CommonException("根据指定条件未查询到对应信息！");
            }else{
                jsonObject.put("rows", page.getAllRs());
                jsonObject.put("total", page.getTotalCount());
            }
        }catch(Exception e){
            this.jsonObject.put("status","1");
            this.jsonObject.put("errMsg",e.getMessage());
        }
        return this.JSONOBJ;
    }

    public String getSort(){
        return sort;
    }

    public void setSort(String sort){
        this.sort = sort;
    }

    public String getOrder(){
        return order;
    }

    public void setOrder(String order){
        this.order = order;
    }

    @Autowired
    public void setCardServiceService(CardServiceService cardServiceService){
        this.cardServiceService = cardServiceService;
    }
    public String getSelectId(){
        return selectId;
    }

    public void setSelectId(String selectId){
        this.selectId = selectId;
    }

    public String getLss_Flag(){
        return lss_Flag;
    }

    public void setLss_Flag(String lss_Flag){
        this.lss_Flag = lss_Flag;
    }

    public CardBaseinfo getCard(){
        return card;
    }

    public void setCard(CardBaseinfo card){
        this.card = card;
    }

    public BasePersonal getPerson(){
        return person;
    }

    public void setPerson(BasePersonal person){
        this.person = person;
    }

    public TrServRec getRec(){
        return rec;
    }

    public void setRec(TrServRec rec){
        this.rec = rec;
    }

    public String getQueryType(){
        return queryType;
    }

    public void setQueryType(String queryType){
        this.queryType = queryType;
    }

    public String getCertType(){
        return certType;
    }

    public void setCertType(String certType){
        this.certType = certType;
    }

    public String getCertNo(){
        return certNo;
    }

    public void setCertNo(String certNo){
        this.certNo = certNo;
    }

    public String getCardType(){
        return cardType;
    }

    public void setCardType(String cardType){
        this.cardType = cardType;
    }

    public String getCardNo(){
        return cardNo;
    }

    public void setCardNo(String cardNo){
        this.cardNo = cardNo;
    }

    public String getIsGoodCard(){
        return isGoodCard;
    }

    public void setIsGoodCard(String isGoodCard){
        this.isGoodCard = isGoodCard;
    }

    public String getCardAmt(){
        return cardAmt;
    }

    public void setCardAmt(String cardAmt){
        this.cardAmt = cardAmt;
    }

    public String getZxreason(){
        return zxreason;
    }

    public void setZxreason(String zxreason){
        this.zxreason = zxreason;
    }

    public String getTotalAmt(){
        return totalAmt;
    }

    public void setTotalAmt(String totalAmt){
        this.totalAmt = totalAmt;
    }

    /**
     * @return the accKind
     */
    public String getAccKind(){
        return accKind;
    }

    /**
     * @param accKind the accKind to set
     */
    public void setAccKind(String accKind){
        this.accKind = accKind;
    }

    /**
     * @return the accState
     */
    public String getAccState(){
        return accState;
    }

    /**
     * @param accState the accState to set
     */
    public void setAccState(String accState){
        this.accState = accState;
    }

    /**
     * @return the costFee
     */
    public String getCostFee(){
        return costFee;
    }

    /**
     * @param costFee the costFee to set
     */
    public void setCostFee(String costFee){
        this.costFee = costFee;
    }

    /**
     * @return the defaultErrMsg
     */
    public String getDefaultErrMsg(){
        return defaultErrMsg;
    }

    /**
     * @param defaultErrMsg the defaultErrMsg to set
     */
    public void setDefaultErrMsg(String defaultErrMsg){
        this.defaultErrMsg = defaultErrMsg;
    }

    /**
     * @return the cfg
     */
    public CardConfig getCfg(){
        return cfg;
    }

    /**
     * @param cfg the cfg to set
     */
    public void setCfg(CardConfig cfg){
        this.cfg = cfg;
    }

    public String getNoAccKind(){
        return noAccKind;
    }

    public void setNoAccKind(String noAccKind){
        this.noAccKind = noAccKind;
    }

    public Long getDealNo(){
        return dealNo;
    }

    public void setDealNo(Long dealNo){
        this.dealNo = dealNo;
    }

    public String getFkDate(){
        return fkDate;
    }

    public void setFkDate(String fkDate){
        this.fkDate = fkDate;
    }

    /**
     * @return the cardServiceService
     */
    public CardServiceService getCardServiceService(){
        return cardServiceService;
    }

    /**
     * @return the costFeeSelect
     */
    public String getCostFeeSelect(){
        return costFeeSelect;
    }

    /**
     * @param costFeeSelect the costFeeSelect to set
     */
    public void setCostFeeSelect(String costFeeSelect){
        this.costFeeSelect = costFeeSelect;
    }

    public String getMerchantId(){
        return merchantId;
    }

    public void setMerchantId(String merchantId){
        this.merchantId = merchantId;
    }

    public String getToExamine(){
        return toExamine;
    }

    public void setToExamine(String toExamine){
        this.toExamine = toExamine;
    }

    public String getBankCardNo(){
        return bankCardNo;
    }

    public void setBankCardNo(String bankCardNo){
        this.bankCardNo = bankCardNo;
    }

    public String getName(){
        return name;
    }

    public void setName(String name){
        this.name = name;
    }

    public String getReturnState(){
        return returnState;
    }

    public void setReturnState(String returnState){
        this.returnState = returnState;
    }

    public AccQcqfLimit getLimit(){
        return limit;
    }

    public void setLimit(AccQcqfLimit limit){
        this.limit = limit;
    }

    public String getOldCardNo(){
        return oldCardNo;
    }

    public void setOldCardNo(String oldCardNo){
        this.oldCardNo = oldCardNo;
    }

    public String getNewCardNo(){
        return newCardNo;
    }

    public void setNewCardNo(String newCardNo){
        this.newCardNo = newCardNo;
    }

    public String getDealNo2(){
        return dealNo2;
    }

    public void setDealNo2(String dealNo2){
        this.dealNo2 = dealNo2;
    }

    public String getFjmkCostFee1(){
        return fjmkCostFee1;
    }

    public void setFjmkCostFee1(String fjmkCostFee1){
        this.fjmkCostFee1 = fjmkCostFee1;
    }

    public String getFjmkCostFee2(){
        return fjmkCostFee2;
    }

    public void setFjmkCostFee2(String fjmkCostFee2){
        this.fjmkCostFee2 = fjmkCostFee2;
    }

    public AccAcountService getAccAcountService() {
        return accAcountService;
    }
    public void setAccAcountService(AccAcountService accAcountService) {
        this.accAcountService = accAcountService;
    }
    public DoWorkClientService getDoWorkClientService() {
        return doWorkClientService;
    }
    public void setDoWorkClientService(DoWorkClientService doWorkClientService) {
        this.doWorkClientService = doWorkClientService;
    }
	public RechargeService getRechargeService() {
		return rechargeService;
	}
	public void setRechargeService(RechargeService rechargeService) {
		this.rechargeService = rechargeService;
	}

	public String getStartDate() {
		return startDate;
	}
	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}

	public String getEndTime() {
		return endTime;
	}

	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}

	public String getStartMonth() {
		return startMonth;
	}

	public void setStartMonth(String startMonth) {
		this.startMonth = startMonth;
	}

	public String getEndMonth() {
		return endMonth;
	}

	public void setEndMonth(String endMonth) {
		this.endMonth = endMonth;
	}
	
	
	
}
