package com.erp.model;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "BASE_BATCH_RECHARGE_DETAILS")
public class BaseBatchRechargeDetails{
    private Long dataId;
    private Long dataSeq;
    private String customerId;
    private String name;
    private String certNo;
    private String cardType;
    private String cardNo;
    private String accKind;
    private Long amt;
    private String state;
    private String brchId;
    private String userId;
    private String note;
    private Long lineNum;
    private Date rechargeTime;
    @Id
    @Basic
    @Column(name = "DATA_ID", nullable = true, precision = 0)
    public Long getDataId(){
        return dataId;
    }
    public void setDataId(Long dataId){
        this.dataId = dataId;
    }
    @Basic
    @Column(name = "DATA_SEQ", nullable = true, precision = 0)
    public Long getDataSeq(){
        return dataSeq;
    }
    public void setDataSeq(Long dataSeq){
        this.dataSeq = dataSeq;
    }
    @Basic
    @Column(name = "CUSTOMER_ID", nullable = true, length = 15)
    public String getCustomerId(){
        return customerId;
    }
    public void setCustomerId(String customerId){
        this.customerId = customerId;
    }
    @Basic
    @Column(name = "NAME", nullable = true, length = 50)
    public String getName(){
        return name;
    }
    public void setName(String name){
        this.name = name;
    }
    @Basic
    @Column(name = "CERT_NO", nullable = true, length = 20)
    public String getCertNo(){
        return certNo;
    }
    public void setCertNo(String certNo){
        this.certNo = certNo;
    }
    @Basic
    @Column(name = "CARD_TYPE", nullable = true, length = 3)
    public String getCardType(){
        return cardType;
    }
    public void setCardType(String cardType){
        this.cardType = cardType;
    }
    @Basic
    @Column(name = "CARD_NO", nullable = true, length = 20)
    public String getCardNo(){
        return cardNo;
    }
    public void setCardNo(String cardNo){
        this.cardNo = cardNo;
    }
    @Basic
    @Column(name = "ACC_KIND", nullable = true, length = 20)
    public String getAccKind(){
        return accKind;
    }
    public void setAccKind(String accKind){
        this.accKind = accKind;
    }
    @Basic
    @Column(name = "AMT", nullable = true, precision = 0)
    public Long getAmt(){
        return amt;
    }
    public void setAmt(Long amt){
        this.amt = amt;
    }
    @Basic
    @Column(name = "STATE", nullable = true, length = 1)
    public String getState(){
        return state;
    }
    public void setState(String state){
        this.state = state;
    }
    @Basic
    @Column(name = "BRCH_ID", nullable = true, length = 15)
    public String getBrchId(){
        return brchId;
    }
    public void setBrchId(String brchId){
        this.brchId = brchId;
    }
    @Basic
    @Column(name = "USER_ID", nullable = true, length = 15)
    public String getUserId(){
        return userId;
    }
    public void setUserId(String userId){
        this.userId = userId;
    }
    @Basic
    @Column(name = "NOTE", nullable = true, length = 200)
    public String getNote(){
        return note;
    }
    public void setNote(String note){
        this.note = note;
    }
    @Override
    public boolean equals(Object o){
        if(this == o)
            return true;
        if(o == null || getClass() != o.getClass())
            return false;

        BaseBatchRechargeDetails that = (BaseBatchRechargeDetails) o;

        if(dataId != null ? !dataId.equals(that.dataId) : that.dataId != null)
            return false;
        if(dataSeq != null ? !dataSeq.equals(that.dataSeq) : that.dataSeq != null)
            return false;
        if(customerId != null ? !customerId.equals(that.customerId) : that.customerId != null)
            return false;
        if(name != null ? !name.equals(that.name) : that.name != null)
            return false;
        if(certNo != null ? !certNo.equals(that.certNo) : that.certNo != null)
            return false;
        if(cardType != null ? !cardType.equals(that.cardType) : that.cardType != null)
            return false;
        if(cardNo != null ? !cardNo.equals(that.cardNo) : that.cardNo != null)
            return false;
        if(accKind != null ? !accKind.equals(that.accKind) : that.accKind != null)
            return false;
        if(amt != null ? !amt.equals(that.amt) : that.amt != null)
            return false;
        if(state != null ? !state.equals(that.state) : that.state != null)
            return false;
        if(brchId != null ? !brchId.equals(that.brchId) : that.brchId != null)
            return false;
        if(userId != null ? !userId.equals(that.userId) : that.userId != null)
            return false;
        if(note != null ? !note.equals(that.note) : that.note != null)
            return false;

        return true;
    }
    @Override
    public int hashCode(){
        int result = dataId != null ? dataId.hashCode() : 0;
        result = 31 * result + (dataSeq != null ? dataSeq.hashCode() : 0);
        result = 31 * result + (customerId != null ? customerId.hashCode() : 0);
        result = 31 * result + (name != null ? name.hashCode() : 0);
        result = 31 * result + (certNo != null ? certNo.hashCode() : 0);
        result = 31 * result + (cardType != null ? cardType.hashCode() : 0);
        result = 31 * result + (cardNo != null ? cardNo.hashCode() : 0);
        result = 31 * result + (accKind != null ? accKind.hashCode() : 0);
        result = 31 * result + (amt != null ? amt.hashCode() : 0);
        result = 31 * result + (state != null ? state.hashCode() : 0);
        result = 31 * result + (brchId != null ? brchId.hashCode() : 0);
        result = 31 * result + (userId != null ? userId.hashCode() : 0);
        result = 31 * result + (note != null ? note.hashCode() : 0);
        return result;
    }
    @Basic
    @Column(name = "LINE_NUM", nullable = true, precision = 0)
    public Long getLineNum(){
        return lineNum;
    }
    public void setLineNum(Long lineNum){
        this.lineNum = lineNum;
    }
    @Basic
    @Column(name = "RECHARGE_TIME", nullable = true)
    public Date getRechargeTime(){
        return rechargeTime;
    }
    public void setRechargeTime(Date rechargeTime){
        this.rechargeTime = rechargeTime;
    }
}
