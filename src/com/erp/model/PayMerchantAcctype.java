package com.erp.model;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.EmbeddedId;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * PayMerchantAcctype entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "PAY_MERCHANT_ACCTYPE")
public class PayMerchantAcctype implements java.io.Serializable {

	// Fields

	private PayMerchantAcctypeId id;

	// Constructors

	/** default constructor */
	public PayMerchantAcctype() {
	}

	/** full constructor */
	public PayMerchantAcctype(PayMerchantAcctypeId id) {
		this.id = id;
	}

	// Property accessors
	@EmbeddedId
	@AttributeOverrides({
			@AttributeOverride(name = "merchantId", column = @Column(name = "MERCHANT_ID", nullable = false, length = 16)),
			@AttributeOverride(name = "accKind", column = @Column(name = "ACC_KIND", nullable = false, length = 2)) })
	public PayMerchantAcctypeId getId() {
		return this.id;
	}

	public void setId(PayMerchantAcctypeId id) {
		this.id = id;
	}

}