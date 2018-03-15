package com.erp.model;

import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * SysPara entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "SYS_PARA")
public class SysPara extends AbstractSysPara implements java.io.Serializable {

	// Constructors

	/** default constructor */
	public SysPara() {
	}

	/** minimal constructor */
	public SysPara(String paraCode) {
		super(paraCode);
	}

	/** full constructor */
	public SysPara(String paraCode, String paraValue, String paraValue2,
			String paraValue3, String paraValue4, String paraValue5,
			String paraValue6, String paraValue7, String paraValue8,
			String paraDesc) {
		super(paraCode, paraValue, paraValue2, paraValue3, paraValue4,
				paraValue5, paraValue6, paraValue7, paraValue8, paraDesc);
	}

}
