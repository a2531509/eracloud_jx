package com.erp.model;

import java.math.BigDecimal;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;


/**
 * BaseMerchantType entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name="BASE_MERCHANT_TYPE")
@SequenceGenerator(name="SEQ_BASIC_MerchantType",allocationSize=1,initialValue=230,sequenceName="SEQ_BS_MERCHANT_TYPE_ID" )
public class BaseMerchantType  implements java.io.Serializable {


    // Fields    

     private Long id;
     private String typeName;
     private Integer parentId;
     private Integer lev;
     private String typeState;
     private Integer ordNo;
     private String note;


    // Constructors

    /** default constructor */
    public BaseMerchantType() {
    }

	/** minimal constructor */
    public BaseMerchantType(Long id) {
        this.id = id;
    }
    
    /** full constructor */
    public BaseMerchantType(Long id, String typeName, Integer parentId, Integer lev, String typeState, Integer ordNo, String note) {
        this.id = id;
        this.typeName = typeName;
        this.parentId = parentId;
        this.lev = lev;
        this.typeState = typeState;
        this.ordNo = ordNo;
        this.note = note;
    }

   
    // Property accessors
    @Id 
	@GeneratedValue(strategy=GenerationType.SEQUENCE,generator="SEQ_BASIC_MerchantType")
    @Column(name="ID", unique=true, nullable=false, precision=22, scale=0)
    public Long getId() {
        return this.id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    @Column(name="TYPE_NAME", length=128)

    public String getTypeName() {
        return this.typeName;
    }
    
    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }
    
    @Column(name="PARENT_ID", precision=22, scale=0)

    public Integer getParentId() {
        return this.parentId;
    }
    
    public void setParentId(Integer parentId) {
        this.parentId = parentId;
    }
    
    @Column(name="LEV", precision=22, scale=0)

    public Integer getLev() {
        return this.lev;
    }
    
    public void setLev(Integer lev) {
        this.lev = lev;
    }
    
    @Column(name="TYPE_STATE", length=1)

    public String getTypeState() {
        return this.typeState;
    }
    
    public void setTypeState(String typeState) {
        this.typeState = typeState;
    }
    
    @Column(name="ORD_NO", precision=22, scale=0)

    public Integer getOrdNo() {
        return this.ordNo;
    }
    
    public void setOrdNo(Integer ordNo) {
        this.ordNo = ordNo;
    }
    
    @Column(name="NOTE", length=500)

    public String getNote() {
        return this.note;
    }
    
    public void setNote(String note) {
        this.note = note;
    }
   








}