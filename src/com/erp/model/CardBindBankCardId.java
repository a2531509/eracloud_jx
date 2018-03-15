/**
 * 
 */
package com.erp.model;

import java.io.Serializable;

import javax.persistence.Column;

/**
 * @author Yueh
 *
 */
public class CardBindBankCardId implements Serializable {
	private static final long serialVersionUID = 1L;

	@Column(name = "CERT_NO")
	private String certNo;

	@Column(name = "SUB_CARD_NO")
	private String subCardNo;

	public CardBindBankCardId() {
		super();
	}

	public CardBindBankCardId(String certNo, String subCardNo) {
		super();
		this.certNo = certNo;
		this.subCardNo = subCardNo;
	}

	public String getCertNo() {
		return certNo;
	}

	public void setCertNo(String certNo) {
		this.certNo = certNo;
	}

	public String getSubCardNo() {
		return subCardNo;
	}

	public void setSubCardNo(String subCardNo) {
		this.subCardNo = subCardNo;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((certNo == null) ? 0 : certNo.hashCode());
		result = prime * result
				+ ((subCardNo == null) ? 0 : subCardNo.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		CardBindBankCardId other = (CardBindBankCardId) obj;
		if (certNo == null) {
			if (other.certNo != null)
				return false;
		} else if (!certNo.equals(other.certNo))
			return false;
		if (subCardNo == null) {
			if (other.subCardNo != null)
				return false;
		} else if (!subCardNo.equals(other.subCardNo))
			return false;
		return true;
	}
}
