package com.erp.model;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;


/**
 * BaseMerchant entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name="BASE_MERCHANT")
@SequenceGenerator(name="SEQ_BASIC_MERCHANT",allocationSize=1,initialValue=10010089,sequenceName="SEQ_CLIENT_ID" )
public class BaseMerchant  implements java.io.Serializable {


    // Fields    

     private Long customerId;
     private String orgId;
     private String merchantId;
     private String merchantName;
     private String abbrName;
     private Long merchantType;
     private String topMerchantId;
     private String indusCode;
     private String address;
     private String postCode;
     private String contact;
     private String conPhone;
     private String conPhone2;
     private String conCertType;
     private String conCertNo;
     private String legName;
     private String legPhone;
     private String legCertType;
     private String legCertNo;
     private String phoneNo;
     private String faxNum;
     private String email;
     private String hotline;
     private String taxRegNo;
     private String bizRegNo;
     private String bankId;
     private String bankBrch;
     private String bankAccName;
     private String bankAccNo;
     private String provCode;
     private String cityCode;
     private Date signDate;
     private String signUserId;
     private String contactNo;
     private String contactType;
     private String billAddr;
     private String billAddrPostcode;
     private String stlType;
     private String PKey;
     private String divId;
     private String servPwd;
     private String servPwdErrNum;
     private String netPwd;
     private String netPwdErrNum;
     private String merchantState;
     private String note;
     private String isSettleMonth;
     private String region;


    // Constructors

    /** default constructor */
    public BaseMerchant() {
    }

	/** minimal constructor */
    public BaseMerchant(Long customerId, String orgId, String merchantId) {
        this.customerId = customerId;
        this.orgId = orgId;
        this.merchantId = merchantId;
    }
    
    /** full constructor */
    public BaseMerchant(Long customerId, String orgId, String merchantId, String merchantName, String abbrName, Long merchantType, String topMerchantId, String indusCode, String address, String postCode, String contact, String conPhone, String conCertType, String conCertNo, String legName, String legPhone, String legCertType, String legCertNo, String phoneNo, String faxNum, String email, String hotline, String taxRegNo, String bizRegNo, String bankId, String bankBrch, String bankAccName, String bankAccNo, String provCode, String cityCode, Date signDate, String signUserId, String contactNo, String contactType, String billAddr, String billAddrPostcode, String stlType, String PKey, String divId, String servPwd, String servPwdErrNum, String netPwd, String netPwdErrNum, String merchantState, String note) {
        this.customerId = customerId;
        this.orgId = orgId;
        this.merchantId = merchantId;
        this.merchantName = merchantName;
        this.abbrName = abbrName;
        this.merchantType = merchantType;
        this.topMerchantId = topMerchantId;
        this.indusCode = indusCode;
        this.address = address;
        this.postCode = postCode;
        this.contact = contact;
        this.conPhone = conPhone;
        this.conCertType = conCertType;
        this.conCertNo = conCertNo;
        this.legName = legName;
        this.legPhone = legPhone;
        this.legCertType = legCertType;
        this.legCertNo = legCertNo;
        this.phoneNo = phoneNo;
        this.faxNum = faxNum;
        this.email = email;
        this.hotline = hotline;
        this.taxRegNo = taxRegNo;
        this.bizRegNo = bizRegNo;
        this.bankId = bankId;
        this.bankBrch = bankBrch;
        this.bankAccName = bankAccName;
        this.bankAccNo = bankAccNo;
        this.provCode = provCode;
        this.cityCode = cityCode;
        this.signDate = signDate;
        this.signUserId = signUserId;
        this.contactNo = contactNo;
        this.contactType = contactType;
        this.billAddr = billAddr;
        this.billAddrPostcode = billAddrPostcode;
        this.stlType = stlType;
        this.PKey = PKey;
        this.divId = divId;
        this.servPwd = servPwd;
        this.servPwdErrNum = servPwdErrNum;
        this.netPwd = netPwd;
        this.netPwdErrNum = netPwdErrNum;
        this.merchantState = merchantState;
        this.note = note;
    }

   
    // Property accessors
    @Id 
    @GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_BASIC_MERCHANT")
    @Column(name="CUSTOMER_ID", unique=true, nullable=false, length=22)

    public Long getCustomerId() {
        return this.customerId;
    }
    
    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }
    
    @Column(name="ORG_ID", nullable=false, length=4)

    public String getOrgId() {
        return this.orgId;
    }
    
    public void setOrgId(String orgId) {
        this.orgId = orgId;
    }
    
    @Column(name="MERCHANT_ID", nullable=false, length=16)

    public String getMerchantId() {
        return this.merchantId;
    }
    
    public void setMerchantId(String merchantId) {
        this.merchantId = merchantId;
    }
    
    @Column(name="MERCHANT_NAME", length=128)

    public String getMerchantName() {
        return this.merchantName;
    }
    
    public void setMerchantName(String merchantName) {
        this.merchantName = merchantName;
    }
    
    @Column(name="ABBR_NAME", length=128)

    public String getAbbrName() {
        return this.abbrName;
    }
    
    public void setAbbrName(String abbrName) {
        this.abbrName = abbrName;
    }
    
    @Column(name="MERCHANT_TYPE", precision=16, scale=0)

    public Long getMerchantType() {
        return this.merchantType;
    }
    
    public void setMerchantType(Long merchantType) {
        this.merchantType = merchantType;
    }
    
    @Column(name="TOP_MERCHANT_ID", length=16)

    public String getTopMerchantId() {
        return this.topMerchantId;
    }
    
    public void setTopMerchantId(String topMerchantId) {
        this.topMerchantId = topMerchantId;
    }
    
    @Column(name="INDUS_CODE", length=128)

    public String getIndusCode() {
        return this.indusCode;
    }
    
    public void setIndusCode(String indusCode) {
        this.indusCode = indusCode;
    }
    
    @Column(name="ADDRESS", length=128)

    public String getAddress() {
        return this.address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    @Column(name="POST_CODE", length=6)

    public String getPostCode() {
        return this.postCode;
    }
    
    public void setPostCode(String postCode) {
        this.postCode = postCode;
    }
    
    @Column(name="CONTACT", length=32)

    public String getContact() {
        return this.contact;
    }
    
    public void setContact(String contact) {
        this.contact = contact;
    }
    
    @Column(name="CON_PHONE", length=32)

    public String getConPhone() {
        return this.conPhone;
    }
    
    public void setConPhone(String conPhone) {
        this.conPhone = conPhone;
    }
    
    @Column(name="CON_CERT_TYPE", length=1)

    public String getConCertType() {
        return this.conCertType;
    }
    
    public void setConCertType(String conCertType) {
        this.conCertType = conCertType;
    }
    
    @Column(name="CON_CERT_NO", length=36)

    public String getConCertNo() {
        return this.conCertNo;
    }
    
    public void setConCertNo(String conCertNo) {
        this.conCertNo = conCertNo;
    }
    
    @Column(name="LEG_NAME", length=32)

    public String getLegName() {
        return this.legName;
    }
    
    public void setLegName(String legName) {
        this.legName = legName;
    }
    
    @Column(name="LEG_PHONE", length=32)

    public String getLegPhone() {
        return this.legPhone;
    }
    
    public void setLegPhone(String legPhone) {
        this.legPhone = legPhone;
    }
    
    @Column(name="LEG_CERT_TYPE", length=1)

    public String getLegCertType() {
        return this.legCertType;
    }
    
    public void setLegCertType(String legCertType) {
        this.legCertType = legCertType;
    }
    
    @Column(name="LEG_CERT_NO", length=36)

    public String getLegCertNo() {
        return this.legCertNo;
    }
    
    public void setLegCertNo(String legCertNo) {
        this.legCertNo = legCertNo;
    }
    
    @Column(name="PHONE_NO", length=32)

    public String getPhoneNo() {
        return this.phoneNo;
    }
    
    public void setPhoneNo(String phoneNo) {
        this.phoneNo = phoneNo;
    }
    
    @Column(name="FAX_NUM", length=32)

    public String getFaxNum() {
        return this.faxNum;
    }
    
    public void setFaxNum(String faxNum) {
        this.faxNum = faxNum;
    }
    
    @Column(name="EMAIL", length=64)

    public String getEmail() {
        return this.email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    @Column(name="HOTLINE", length=32)

    public String getHotline() {
        return this.hotline;
    }
    
    public void setHotline(String hotline) {
        this.hotline = hotline;
    }
    
    @Column(name="TAX_REG_NO", length=32)

    public String getTaxRegNo() {
        return this.taxRegNo;
    }
    
    public void setTaxRegNo(String taxRegNo) {
        this.taxRegNo = taxRegNo;
    }
    
    @Column(name="BIZ_REG_NO", length=32)

    public String getBizRegNo() {
        return this.bizRegNo;
    }
    
    public void setBizRegNo(String bizRegNo) {
        this.bizRegNo = bizRegNo;
    }
    
    @Column(name="BANK_ID", length=4)

    public String getBankId() {
        return this.bankId;
    }
    
    public void setBankId(String bankId) {
        this.bankId = bankId;
    }
    
    @Column(name="BANK_BRCH", length=128)

    public String getBankBrch() {
        return this.bankBrch;
    }
    
    public void setBankBrch(String bankBrch) {
        this.bankBrch = bankBrch;
    }
    
    @Column(name="BANK_ACC_NAME", length=128)

    public String getBankAccName() {
        return this.bankAccName;
    }
    
    public void setBankAccName(String bankAccName) {
        this.bankAccName = bankAccName;
    }
    
    @Column(name="BANK_ACC_NO", length=50)

    public String getBankAccNo() {
        return this.bankAccNo;
    }
    
    public void setBankAccNo(String bankAccNo) {
        this.bankAccNo = bankAccNo;
    }
    
    @Column(name="PROV_CODE", length=2)

    public String getProvCode() {
        return this.provCode;
    }
    
    public void setProvCode(String provCode) {
        this.provCode = provCode;
    }
    
    @Column(name="CITY_CODE", length=6)

    public String getCityCode() {
        return this.cityCode;
    }
    
    public void setCityCode(String cityCode) {
        this.cityCode = cityCode;
    }
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name="SIGN_DATE", length=7)

    public Date getSignDate() {
        return this.signDate;
    }
    
    public void setSignDate(Date signDate) {
        this.signDate = signDate;
    }
    
    @Column(name="SIGN_USER_ID", length=10)

    public String getSignUserId() {
        return this.signUserId;
    }
    
    public void setSignUserId(String signUserId) {
        this.signUserId = signUserId;
    }
    
    @Column(name="CONTACT_NO", length=100)

    public String getContactNo() {
        return this.contactNo;
    }
    
    public void setContactNo(String contactNo) {
        this.contactNo = contactNo;
    }
    
    @Column(name="CONTACT_TYPE", length=100)

    public String getContactType() {
        return this.contactType;
    }
    
    public void setContactType(String contactType) {
        this.contactType = contactType;
    }
    
    @Column(name="BILL_ADDR", length=100)

    public String getBillAddr() {
        return this.billAddr;
    }
    
    public void setBillAddr(String billAddr) {
        this.billAddr = billAddr;
    }
    
    @Column(name="BILL_ADDR_POSTCODE", length=100)

    public String getBillAddrPostcode() {
        return this.billAddrPostcode;
    }
    
    public void setBillAddrPostcode(String billAddrPostcode) {
        this.billAddrPostcode = billAddrPostcode;
    }
    
    @Column(name="STL_TYPE", length=1)

    public String getStlType() {
        return this.stlType;
    }
    
    public void setStlType(String stlType) {
        this.stlType = stlType;
    }
    
    @Column(name="P_KEY", length=32)

    public String getPKey() {
        return this.PKey;
    }
    
    public void setPKey(String PKey) {
        this.PKey = PKey;
    }
    
    @Column(name="DIV_ID", length=16)

    public String getDivId() {
        return this.divId;
    }
    
    public void setDivId(String divId) {
        this.divId = divId;
    }
    
    @Column(name="SERV_PWD", length=128)

    public String getServPwd() {
        return this.servPwd;
    }
    
    public void setServPwd(String servPwd) {
        this.servPwd = servPwd;
    }
    
    @Column(name="SERV_PWD_ERR_NUM", precision=1, scale=0)

    public String getServPwdErrNum() {
        return this.servPwdErrNum;
    }
    
    public void setServPwdErrNum(String servPwdErrNum) {
        this.servPwdErrNum = servPwdErrNum;
    }
    
    @Column(name="NET_PWD", length=128)

    public String getNetPwd() {
        return this.netPwd;
    }
    
    public void setNetPwd(String netPwd) {
        this.netPwd = netPwd;
    }
    
    @Column(name="NET_PWD_ERR_NUM", precision=1, scale=0)

    public String getNetPwdErrNum() {
        return this.netPwdErrNum;
    }
    
    public void setNetPwdErrNum(String netPwdErrNum) {
        this.netPwdErrNum = netPwdErrNum;
    }
    
    @Column(name="MERCHANT_STATE", length=1)

    public String getMerchantState() {
        return this.merchantState;
    }
    
    public void setMerchantState(String merchantState) {
        this.merchantState = merchantState;
    }
    
    @Column(name="NOTE", length=64)

    public String getNote() {
        return this.note;
    }
    
    public void setNote(String note) {
        this.note = note;
    }

    @Column(name="is_settle_month", length=1)
	public String getIsSettleMonth() {
		return isSettleMonth;
	}

	public void setIsSettleMonth(String isSettleMonth) {
		this.isSettleMonth = isSettleMonth;
	}

	@Column(name = "CON_PHONE2")
	public String getConPhone2() {
		return conPhone2;
	}

	public void setConPhone2(String conPhone2) {
		this.conPhone2 = conPhone2;
	}

	@Column(name = "REGION_ID")
	public String getRegion() {
		return region;
	}

	public void setRegion(String region) {
		this.region = region;
	}
}