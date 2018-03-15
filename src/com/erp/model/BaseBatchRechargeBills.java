package com.erp.model;

import javax.persistence.*;
import java.util.Date;

@Entity
@Table(name = "BASE_BATCH_RECHARGE_BILLS")
public class BaseBatchRechargeBills{
    private long dataSeq;
    private String customerId;
    private String customerName;
    private String accKind;
    private String isAudit;
    private Long totNum;
    private Long totAmt;
    private Long useableNum;
    private Long useableAmt;
    private Long sucNum;
    private Long sucAmt;
    private Long errNum;
    private Long errAmt;
    private String state;
    private String impBrchId;
    private String impUserId;
    private Date impDate;
    private String auditBrchId;
    private String auditUserId;
    private Date auditDate;
    private String note;
    @Id
    @Column(name = "DATA_SEQ", nullable = false, precision = 0)
    public long getDataSeq(){
        return dataSeq;
    }
    public void setDataSeq(long dataSeq){
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
    @Column(name = "CUSTOMER_NAME", nullable = true, length = 200)
    public String getCustomerName(){
        return customerName;
    }
    public void setCustomerName(String customerName){
        this.customerName = customerName;
    }
    @Basic
    @Column(name = "ACC_KIND", nullable = true, length = 2)
    public String getAccKind(){
        return accKind;
    }
    public void setAccKind(String accKind){
        this.accKind = accKind;
    }
    @Basic
    @Column(name = "IS_AUDIT", nullable = true, length = 1)
    public String getIsAudit(){
        return isAudit;
    }
    public void setIsAudit(String isAudit){
        this.isAudit = isAudit;
    }
    @Basic
    @Column(name = "TOT_NUM", nullable = true, precision = 0)
    public Long getTotNum(){
        return totNum;
    }
    public void setTotNum(Long totNum){
        this.totNum = totNum;
    }
    @Basic
    @Column(name = "TOT_AMT", nullable = true, precision = 0)
    public Long getTotAmt(){
        return totAmt;
    }
    public void setTotAmt(Long totAmt){
        this.totAmt = totAmt;
    }
    @Basic
    @Column(name = "USEABLE_NUM", nullable = true, precision = 0)
    public Long getUseableNum(){
        return useableNum;
    }
    public void setUseableNum(Long useableNum){
        this.useableNum = useableNum;
    }
    @Basic
    @Column(name = "USEABLE_AMT", nullable = true, precision = 0)
    public Long getUseableAmt(){
        return useableAmt;
    }
    public void setUseableAmt(Long useableAmt){
        this.useableAmt = useableAmt;
    }
    @Basic
    @Column(name = "SUC_NUM", nullable = true, precision = 0)
    public Long getSucNum(){
        return sucNum;
    }
    public void setSucNum(Long sucNum){
        this.sucNum = sucNum;
    }
    @Basic
    @Column(name = "SUC_AMT", nullable = true, precision = 0)
    public Long getSucAmt(){
        return sucAmt;
    }
    public void setSucAmt(Long sucAmt){
        this.sucAmt = sucAmt;
    }
    @Basic
    @Column(name = "ERR_NUM", nullable = true, precision = 0)
    public Long getErrNum(){
        return errNum;
    }
    public void setErrNum(Long errNum){
        this.errNum = errNum;
    }
    @Basic
    @Column(name = "ERR_AMT", nullable = true, precision = 0)
    public Long getErrAmt(){
        return errAmt;
    }
    public void setErrAmt(Long errAmt){
        this.errAmt = errAmt;
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
    @Column(name = "IMP_BRCH_ID", nullable = true, length = 15)
    public String getImpBrchId(){
        return impBrchId;
    }
    public void setImpBrchId(String impBrchId){
        this.impBrchId = impBrchId;
    }
    @Basic
    @Column(name = "IMP_USER_ID", nullable = true, length = 15)
    public String getImpUserId(){
        return impUserId;
    }
    public void setImpUserId(String impUserId){
        this.impUserId = impUserId;
    }
    @Basic
    @Column(name = "IMP_DATE", nullable = true)
    public Date getImpDate(){
        return impDate;
    }
    public void setImpDate(Date impDate){
        this.impDate = impDate;
    }
    @Basic
    @Column(name = "AUDIT_BRCH_ID", nullable = true, length = 15)
    public String getAuditBrchId(){
        return auditBrchId;
    }
    public void setAuditBrchId(String auditBrchId){
        this.auditBrchId = auditBrchId;
    }
    @Basic
    @Column(name = "AUDIT_USER_ID", nullable = true, length = 15)
    public String getAuditUserId(){
        return auditUserId;
    }
    public void setAuditUserId(String auditUserId){
        this.auditUserId = auditUserId;
    }
    @Basic
    @Column(name = "AUDIT_DATE", nullable = true)
    public Date getAuditDate(){
        return auditDate;
    }
    public void setAuditDate(Date auditDate){
        this.auditDate = auditDate;
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

        BaseBatchRechargeBills that = (BaseBatchRechargeBills) o;

        if(dataSeq != that.dataSeq)
            return false;
        if(customerId != null ? !customerId.equals(that.customerId) : that.customerId != null)
            return false;
        if(customerName != null ? !customerName.equals(that.customerName) : that.customerName != null)
            return false;
        if(accKind != null ? !accKind.equals(that.accKind) : that.accKind != null)
            return false;
        if(isAudit != null ? !isAudit.equals(that.isAudit) : that.isAudit != null)
            return false;
        if(totNum != null ? !totNum.equals(that.totNum) : that.totNum != null)
            return false;
        if(totAmt != null ? !totAmt.equals(that.totAmt) : that.totAmt != null)
            return false;
        if(useableNum != null ? !useableNum.equals(that.useableNum) : that.useableNum != null)
            return false;
        if(useableAmt != null ? !useableAmt.equals(that.useableAmt) : that.useableAmt != null)
            return false;
        if(sucNum != null ? !sucNum.equals(that.sucNum) : that.sucNum != null)
            return false;
        if(sucAmt != null ? !sucAmt.equals(that.sucAmt) : that.sucAmt != null)
            return false;
        if(errNum != null ? !errNum.equals(that.errNum) : that.errNum != null)
            return false;
        if(errAmt != null ? !errAmt.equals(that.errAmt) : that.errAmt != null)
            return false;
        if(state != null ? !state.equals(that.state) : that.state != null)
            return false;
        if(impBrchId != null ? !impBrchId.equals(that.impBrchId) : that.impBrchId != null)
            return false;
        if(impUserId != null ? !impUserId.equals(that.impUserId) : that.impUserId != null)
            return false;
        if(auditBrchId != null ? !auditBrchId.equals(that.auditBrchId) : that.auditBrchId != null)
            return false;
        if(auditUserId != null ? !auditUserId.equals(that.auditUserId) : that.auditUserId != null)
            return false;
        if(auditDate != null ? !auditDate.equals(that.auditDate) : that.auditDate != null)
            return false;
        if(note != null ? !note.equals(that.note) : that.note != null)
            return false;

        return true;
    }
    @Override
    public int hashCode(){
        int result = (int) (dataSeq ^ (dataSeq >>> 32));
        result = 31 * result + (customerId != null ? customerId.hashCode() : 0);
        result = 31 * result + (customerName != null ? customerName.hashCode() : 0);
        result = 31 * result + (accKind != null ? accKind.hashCode() : 0);
        result = 31 * result + (isAudit != null ? isAudit.hashCode() : 0);
        result = 31 * result + (totNum != null ? totNum.hashCode() : 0);
        result = 31 * result + (totAmt != null ? totAmt.hashCode() : 0);
        result = 31 * result + (useableNum != null ? useableNum.hashCode() : 0);
        result = 31 * result + (useableAmt != null ? useableAmt.hashCode() : 0);
        result = 31 * result + (sucNum != null ? sucNum.hashCode() : 0);
        result = 31 * result + (sucAmt != null ? sucAmt.hashCode() : 0);
        result = 31 * result + (errNum != null ? errNum.hashCode() : 0);
        result = 31 * result + (errAmt != null ? errAmt.hashCode() : 0);
        result = 31 * result + (state != null ? state.hashCode() : 0);
        result = 31 * result + (impBrchId != null ? impBrchId.hashCode() : 0);
        result = 31 * result + (impUserId != null ? impUserId.hashCode() : 0);
        result = 31 * result + (auditBrchId != null ? auditBrchId.hashCode() : 0);
        result = 31 * result + (auditUserId != null ? auditUserId.hashCode() : 0);
        result = 31 * result + (auditDate != null ? auditDate.hashCode() : 0);
        result = 31 * result + (note != null ? note.hashCode() : 0);
        return result;
    }
}
