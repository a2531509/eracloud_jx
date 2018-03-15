package com.erp.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * CardConfig entity. @author MyEclipse Persistence Tools
 */
@SuppressWarnings("serial")
@Entity
@Table(name = "CARD_CONFIG")
public class CardConfig implements java.io.Serializable {

	// Fields

	private String cardType;
	private String cardName;
	private String stkCode;
	private Short ordNo;
	private String cardTypeState;
	private String cardTypeCatalog;
	private String only;
	private String namedFlag;
	private String facePersonal;
	private String inPersonal;
	private String onsiteMake;
	private String chgNameFlag;
	private String lssFlag;
	private String reuseFlag;
	private String redeemFlag;
	private String reissueFlag;
	private String reCardnoFlag;
	private String reSubnoFlag;
	private String reBanknoFlag;
	private String reBarnoFlag;
	private String chgFlag;
	private String chgCardnoFlag;
	private String chgSubnoFlag;
	private String chgBanknoFlag;
	private String chgBarnoFlag;
	private String structMainType;
	private String structChildType;
	private Long faceVal;
	private String taskInoutStk;
	private String pwdFlag;
	private String lstFlag;
	private String isparent;
	private String glLss;
	private Short cardValidityPeriod;
	private String perOrBiz;
	private String agentSale;
	private Long walletCaseRechgLmt;
	private Long accCaseRechgLmt;
	private Long bankRechgLmt;
	private Long cashRechgLow;
	private Long costFee;
	private Long urgentFee;//加急费
	private Long foregift;
	private String cardEnd;
	private String cardBegin;
	private String isStock;
	private String isApp;
	private Long cardNum;//加急费
	private Long accOneAllowMax;//账户单笔充值限额
	private Long walletOneAllowMax;//电子钱包单笔充值限额
	private Long bankRechgQtLmtMax;
	

	// Constructors

	/** default constructor */
	public CardConfig() {
	}

	/** minimal constructor */
	public CardConfig(String cardType, String cardName, String stkCode,
			String namedFlag) {
		this.cardType = cardType;
		this.cardName = cardName;
		this.stkCode = stkCode;
		this.namedFlag = namedFlag;
	}

	/** full constructor */
	public CardConfig(String cardType, String cardName, String stkCode,
			Short ordNo, String cardTypeState, String cardTypeCatalog,
			String only, String namedFlag, String facePersonal,
			String inPersonal, String onsiteMake, String chgNameFlag,
			String lssFlag, String reuseFlag, String redeemFlag,
			String reissueFlag, String reCardnoFlag, String reSubnoFlag,
			String reBanknoFlag, String reBarnoFlag, String chgFlag,
			String chgCardnoFlag, String chgSubnoFlag, String chgBanknoFlag,
			String chgBarnoFlag, String structMainType, String structChildType,
			Long faceVal, String taskInoutStk, String pwdFlag, String lstFlag,
			String isparent, String glLss, Short cardValidityPeriod,
			String perOrBiz, String agentSale, Long walletCaseRechgLmt,
			Long accCaseRechgLmt, Long bankRechgLmt, Long cashRechgLow,
			Long costFee, Long foregift, String cardEnd, String cardBegin) {
		this.cardType = cardType;
		this.cardName = cardName;
		this.stkCode = stkCode;
		this.ordNo = ordNo;
		this.cardTypeState = cardTypeState;
		this.cardTypeCatalog = cardTypeCatalog;
		this.only = only;
		this.namedFlag = namedFlag;
		this.facePersonal = facePersonal;
		this.inPersonal = inPersonal;
		this.onsiteMake = onsiteMake;
		this.chgNameFlag = chgNameFlag;
		this.lssFlag = lssFlag;
		this.reuseFlag = reuseFlag;
		this.redeemFlag = redeemFlag;
		this.reissueFlag = reissueFlag;
		this.reCardnoFlag = reCardnoFlag;
		this.reSubnoFlag = reSubnoFlag;
		this.reBanknoFlag = reBanknoFlag;
		this.reBarnoFlag = reBarnoFlag;
		this.chgFlag = chgFlag;
		this.chgCardnoFlag = chgCardnoFlag;
		this.chgSubnoFlag = chgSubnoFlag;
		this.chgBanknoFlag = chgBanknoFlag;
		this.chgBarnoFlag = chgBarnoFlag;
		this.structMainType = structMainType;
		this.structChildType = structChildType;
		this.faceVal = faceVal;
		this.taskInoutStk = taskInoutStk;
		this.pwdFlag = pwdFlag;
		this.lstFlag = lstFlag;
		this.isparent = isparent;
		this.glLss = glLss;
		this.cardValidityPeriod = cardValidityPeriod;
		this.perOrBiz = perOrBiz;
		this.agentSale = agentSale;
		this.walletCaseRechgLmt = walletCaseRechgLmt;
		this.accCaseRechgLmt = accCaseRechgLmt;
		this.bankRechgLmt = bankRechgLmt;
		this.cashRechgLow = cashRechgLow;
		this.costFee = costFee;
		this.foregift = foregift;
		this.cardEnd = cardEnd;
		this.cardBegin = cardBegin;
	}

	// Property accessors
	@Id
	@Column(name = "CARD_TYPE", unique = true, nullable = false, length = 3)
	public String getCardType() {
		return this.cardType;
	}

	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	@Column(name = "CARD_NAME", nullable = false, length = 32)
	public String getCardName() {
		return this.cardName;
	}

	public void setCardName(String cardName) {
		this.cardName = cardName;
	}

	@Column(name = "STK_CODE", nullable = false, length = 4)
	public String getStkCode() {
		return this.stkCode;
	}

	public void setStkCode(String stkCode) {
		this.stkCode = stkCode;
	}

	@Column(name = "ORD_NO", precision = 3, scale = 0)
	public Short getOrdNo() {
		return this.ordNo;
	}

	public void setOrdNo(Short ordNo) {
		this.ordNo = ordNo;
	}

	@Column(name = "CARD_TYPE_STATE", length = 1)
	public String getCardTypeState() {
		return this.cardTypeState;
	}

	public void setCardTypeState(String cardTypeState) {
		this.cardTypeState = cardTypeState;
	}

	@Column(name = "CARD_TYPE_CATALOG", length = 1)
	public String getCardTypeCatalog() {
		return this.cardTypeCatalog;
	}

	public void setCardTypeCatalog(String cardTypeCatalog) {
		this.cardTypeCatalog = cardTypeCatalog;
	}

	@Column(name = "ONLY", length = 1)
	public String getOnly() {
		return this.only;
	}

	public void setOnly(String only) {
		this.only = only;
	}

	@Column(name = "NAMED_FLAG", nullable = false, length = 1)
	public String getNamedFlag() {
		return this.namedFlag;
	}

	public void setNamedFlag(String namedFlag) {
		this.namedFlag = namedFlag;
	}

	@Column(name = "FACE_PERSONAL", length = 1)
	public String getFacePersonal() {
		return this.facePersonal;
	}

	public void setFacePersonal(String facePersonal) {
		this.facePersonal = facePersonal;
	}

	@Column(name = "IN_PERSONAL", length = 1)
	public String getInPersonal() {
		return this.inPersonal;
	}

	public void setInPersonal(String inPersonal) {
		this.inPersonal = inPersonal;
	}

	@Column(name = "ONSITE_MAKE", length = 1)
	public String getOnsiteMake() {
		return this.onsiteMake;
	}

	public void setOnsiteMake(String onsiteMake) {
		this.onsiteMake = onsiteMake;
	}

	@Column(name = "CHG_NAME_FLAG", length = 1)
	public String getChgNameFlag() {
		return this.chgNameFlag;
	}

	public void setChgNameFlag(String chgNameFlag) {
		this.chgNameFlag = chgNameFlag;
	}

	@Column(name = "LSS_FLAG", length = 1)
	public String getLssFlag() {
		return this.lssFlag;
	}

	public void setLssFlag(String lssFlag) {
		this.lssFlag = lssFlag;
	}

	@Column(name = "REUSE_FLAG", length = 1)
	public String getReuseFlag() {
		return this.reuseFlag;
	}

	public void setReuseFlag(String reuseFlag) {
		this.reuseFlag = reuseFlag;
	}

	@Column(name = "REDEEM_FLAG", length = 1)
	public String getRedeemFlag() {
		return this.redeemFlag;
	}

	public void setRedeemFlag(String redeemFlag) {
		this.redeemFlag = redeemFlag;
	}

	@Column(name = "REISSUE_FLAG", length = 1)
	public String getReissueFlag() {
		return this.reissueFlag;
	}

	public void setReissueFlag(String reissueFlag) {
		this.reissueFlag = reissueFlag;
	}

	@Column(name = "RE_CARDNO_FLAG", length = 1)
	public String getReCardnoFlag() {
		return this.reCardnoFlag;
	}

	public void setReCardnoFlag(String reCardnoFlag) {
		this.reCardnoFlag = reCardnoFlag;
	}

	@Column(name = "RE_SUBNO_FLAG", length = 1)
	public String getReSubnoFlag() {
		return this.reSubnoFlag;
	}

	public void setReSubnoFlag(String reSubnoFlag) {
		this.reSubnoFlag = reSubnoFlag;
	}

	@Column(name = "RE_BANKNO_FLAG", length = 1)
	public String getReBanknoFlag() {
		return this.reBanknoFlag;
	}

	public void setReBanknoFlag(String reBanknoFlag) {
		this.reBanknoFlag = reBanknoFlag;
	}

	@Column(name = "RE_BARNO_FLAG", length = 1)
	public String getReBarnoFlag() {
		return this.reBarnoFlag;
	}

	public void setReBarnoFlag(String reBarnoFlag) {
		this.reBarnoFlag = reBarnoFlag;
	}

	@Column(name = "CHG_FLAG", length = 1)
	public String getChgFlag() {
		return this.chgFlag;
	}

	public void setChgFlag(String chgFlag) {
		this.chgFlag = chgFlag;
	}

	@Column(name = "CHG_CARDNO_FLAG", length = 1)
	public String getChgCardnoFlag() {
		return this.chgCardnoFlag;
	}

	public void setChgCardnoFlag(String chgCardnoFlag) {
		this.chgCardnoFlag = chgCardnoFlag;
	}

	@Column(name = "CHG_SUBNO_FLAG", length = 1)
	public String getChgSubnoFlag() {
		return this.chgSubnoFlag;
	}

	public void setChgSubnoFlag(String chgSubnoFlag) {
		this.chgSubnoFlag = chgSubnoFlag;
	}

	@Column(name = "CHG_BANKNO_FLAG", length = 1)
	public String getChgBanknoFlag() {
		return this.chgBanknoFlag;
	}

	public void setChgBanknoFlag(String chgBanknoFlag) {
		this.chgBanknoFlag = chgBanknoFlag;
	}

	@Column(name = "CHG_BARNO_FLAG", length = 1)
	public String getChgBarnoFlag() {
		return this.chgBarnoFlag;
	}

	public void setChgBarnoFlag(String chgBarnoFlag) {
		this.chgBarnoFlag = chgBarnoFlag;
	}

	@Column(name = "STRUCT_MAIN_TYPE", length = 2)
	public String getStructMainType() {
		return this.structMainType;
	}

	public void setStructMainType(String structMainType) {
		this.structMainType = structMainType;
	}

	@Column(name = "STRUCT_CHILD_TYPE", length = 2)
	public String getStructChildType() {
		return this.structChildType;
	}

	public void setStructChildType(String structChildType) {
		this.structChildType = structChildType;
	}

	@Column(name = "FACE_VAL", precision = 10, scale = 0)
	public Long getFaceVal() {
		return this.faceVal;
	}

	public void setFaceVal(Long faceVal) {
		this.faceVal = faceVal;
	}

	@Column(name = "TASK_INOUT_STK", length = 1)
	public String getTaskInoutStk() {
		return this.taskInoutStk;
	}

	public void setTaskInoutStk(String taskInoutStk) {
		this.taskInoutStk = taskInoutStk;
	}

	@Column(name = "PWD_FLAG", length = 1)
	public String getPwdFlag() {
		return this.pwdFlag;
	}

	public void setPwdFlag(String pwdFlag) {
		this.pwdFlag = pwdFlag;
	}

	@Column(name = "LST_FLAG", length = 1)
	public String getLstFlag() {
		return this.lstFlag;
	}

	public void setLstFlag(String lstFlag) {
		this.lstFlag = lstFlag;
	}

	@Column(name = "ISPARENT", length = 1)
	public String getIsparent() {
		return this.isparent;
	}

	public void setIsparent(String isparent) {
		this.isparent = isparent;
	}

	@Column(name = "GL_LSS", length = 1)
	public String getGlLss() {
		return this.glLss;
	}

	public void setGlLss(String glLss) {
		this.glLss = glLss;
	}

	@Column(name = "CARD_VALIDITY_PERIOD", precision = 4, scale = 0)
	public Short getCardValidityPeriod() {
		return this.cardValidityPeriod;
	}

	public void setCardValidityPeriod(Short cardValidityPeriod) {
		this.cardValidityPeriod = cardValidityPeriod;
	}

	@Column(name = "PER_OR_BIZ", length = 1)
	public String getPerOrBiz() {
		return this.perOrBiz;
	}

	public void setPerOrBiz(String perOrBiz) {
		this.perOrBiz = perOrBiz;
	}

	@Column(name = "AGENT_SALE", length = 1)
	public String getAgentSale() {
		return this.agentSale;
	}

	public void setAgentSale(String agentSale) {
		this.agentSale = agentSale;
	}

	@Column(name = "WALLET_CASE_RECHG_LMT", precision = 10, scale = 0)
	public Long getWalletCaseRechgLmt() {
		return this.walletCaseRechgLmt;
	}

	public void setWalletCaseRechgLmt(Long walletCaseRechgLmt) {
		this.walletCaseRechgLmt = walletCaseRechgLmt;
	}

	@Column(name = "ACC_CASE_RECHG_LMT", precision = 10, scale = 0)
	public Long getAccCaseRechgLmt() {
		return this.accCaseRechgLmt;
	}

	public void setAccCaseRechgLmt(Long accCaseRechgLmt) {
		this.accCaseRechgLmt = accCaseRechgLmt;
	}

	@Column(name = "BANK_RECHG_LMT", precision = 10, scale = 0)
	public Long getBankRechgLmt() {
		return this.bankRechgLmt;
	}

	public void setBankRechgLmt(Long bankRechgLmt) {
		this.bankRechgLmt = bankRechgLmt;
	}

	@Column(name = "BANK_RECHG_QT_LMT_MAX")
	public Long getBankRechgQtLmtMax() {
		return bankRechgQtLmtMax;
	}

	public void setBankRechgQtLmtMax(Long bankRechgQtLmtMax) {
		this.bankRechgQtLmtMax = bankRechgQtLmtMax;
	}

	@Column(name = "CASH_RECHG_LOW", precision = 10, scale = 0)
	public Long getCashRechgLow() {
		return this.cashRechgLow;
	}

	public void setCashRechgLow(Long cashRechgLow) {
		this.cashRechgLow = cashRechgLow;
	}

	@Column(name = "COST_FEE", precision = 10, scale = 0)
	public Long getCostFee() {
		return this.costFee;
	}

	public void setCostFee(Long costFee) {
		this.costFee = costFee;
	}

	@Column(name = "FOREGIFT", precision = 10, scale = 0)
	public Long getForegift() {
		return this.foregift;
	}

	public void setForegift(Long foregift) {
		this.foregift = foregift;
	}

	@Column(name = "CARD_END", length = 20)
	public String getCardEnd() {
		return this.cardEnd;
	}

	public void setCardEnd(String cardEnd) {
		this.cardEnd = cardEnd;
	}

	@Column(name = "CARD_BEGIN", length = 20)
	public String getCardBegin() {
		return this.cardBegin;
	}

	public void setCardBegin(String cardBegin) {
		this.cardBegin = cardBegin;
	}
	@Column(name = "IS_STOCK", length = 20)
	public String getIsStock() {
		return isStock;
	}

	public void setIsStock(String isStock) {
		this.isStock = isStock;
	}
	@Column(name = "IS_APP", length = 20)
	public String getIsApp() {
		return isApp;
	}

	public void setIsApp(String isApp) {
		this.isApp = isApp;
	}
	
	@Column(name = "URGENT_FEE", precision = 10, scale = 0)
	public Long getUrgentFee() {
		return urgentFee;
	}

	public void setUrgentFee(Long urgentFee) {
		this.urgentFee = urgentFee;
	}
	
	@Column(name = "CARD_NUM", precision = 10, scale = 0)
	public Long getCardNum() {
		return cardNum;
	}

	public void setCardNum(Long cardNum) {
		this.cardNum = cardNum;
	}

	@Column(name = "ACC_ONE_ALLOW_MAX", precision = 10, scale = 0)
	public Long getAccOneAllowMax() {
		return accOneAllowMax;
	}

	public void setAccOneAllowMax(Long accOneAllowMax) {
		this.accOneAllowMax = accOneAllowMax;
	}

	@Column(name = "WALLET_ONE_ALLOW_MAX", precision = 10, scale = 0)
	public Long getWalletOneAllowMax() {
		return walletOneAllowMax;
	}

	public void setWalletOneAllowMax(Long walletOneAllowMax) {
		this.walletOneAllowMax = walletOneAllowMax;
	}

	
}