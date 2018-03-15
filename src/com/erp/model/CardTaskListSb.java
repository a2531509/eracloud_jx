package com.erp.model;

import java.math.BigDecimal;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * CardTaskListSb entity. @author MyEclipse Persistence Tools
 */
@Entity
@Table(name = "CARD_TASK_LIST_SB")
public class CardTaskListSb implements java.io.Serializable {

	// Fields

	private String taskId;
	private String ssseef0701;
	private String ssseef0702;
	private String ssseef0703;
	private String ssseef0cf0;
	private String ssseef0cf1;
	private String df01ef092e;
	private String df01ef0930;
	private String df01ef0931;
	private String df01ef0932;
	private String df01ef0a37;
	private String df01ef0a38;
	private String df01ef0a39;
	private String df01ef0cf2;
	private String df01ef0cf3;
	private String df02ef055701;
	private String df02ef055801;
	private String df02ef055901;
	private String df02ef055702;
	private String df02ef055802;
	private String df02ef055902;
	private String df02ef0542;
	private String df02ef055a01;
	private String df02ef055b01;
	private String df02ef055c01;
	private String df02ef055d01;
	private String df02ef055a02;
	private String df02ef055b02;
	private String df02ef055c02;
	private String df02ef055d02;
	private String df02ef064b;
	private String df02ef064c;
	private String df02ef0660;
	private String df02ef064d;
	private String df02ef064f;
	private String df02ef0650;
	private String df02ef063a;
	private String df02ef070101;
	private String df02ef070102;
	private String df02ef070103;
	private String df02ef070104;
	private String df02ef070201;
	private String df02ef070202;
	private String df02ef070203;
	private String df02ef070204;
	private String df02ef070301;
	private String df02ef070302;
	private String df02ef070303;
	private String df02ef070304;
	private String df02ef070401;
	private String df02ef070402;
	private String df02ef070403;
	private String df02ef070404;
	private String df03ef0598;
	private String df03ef0561;
	private String df03ef0562;
	private String df03ef0563;
	private String df03ef0564;
	private String df03ef0565;
	private String df03ef0566;
	private String df03ef0667;
	private String df03ef0668;
	private String df03ef0669;
	private String df03ef066a;
	private String df03ef066b;
	private String df03ef076c;
	private String df03ef076d;
	private String df03ef076e;
	private String df03ef076f;
	private String df03ef0770;
	private String df03ef0771;
	private String df03ef0772;
	private String df03ef0773;
	private String df04ef0580;
	private String df04ef0583;
	private String df04ef058b;
	private String df04ef058c;
	private String df04ef058f;
	private String df04ef05f4;
	private String df04ef05f5;
	private String df04ef05f6;
	private String df04ef05f7;
	private String df04ef05f8;
	private String df04ef05f9;
	private String df04ef05fa;
	private String df04ef05fb;
	private String df04ef05fc;
	private String df04ef05fd;
	private String df04ef0790;
	private String df04ef0792;
	private String df04ef0793;
	private String df04ef0794;
	private String df04ef0795;
	private String df04ef0c0101;
	private String df04ef0c0102;
	private String df04ef0c0201;
	private String df04ef0c0202;
	private String df04ef0d0101;
	private String df04ef0d0102;
	private String df04ef0d0201;
	private String df04ef0d0202;
	private String df04ef0ee1;
	private String df04ef0ee2;
	private String df04ef0ee3;
	private String df04ef0ee4;
	private String df04ef10b0;
	private String df04ef10b1;
	private String df04ef10b2;
	private String df04ef10b3;
	private String df04ef10b4;
	private String df04ef10b5;
	private String df04ef10b6;
	private String df04ef10b7;
	private String df04ef10b8;
	private String df04ef10b9;
	private String df04ef10ba;
	private String df04ef10bb;
	private String df04ef10bc;
	private String df04ef10bd;
	private String df04ef10be;
	private String df04ef10bf;
	private String df04ef10c0;
	private String df04ef10c1;
	private String df04ef10c2;
	private String df04ef10c3;
	private String df04ef10c4;
	private String df0aef05d0;
	private String df0aef05d1;
	private String df0aef05d2;
	private String df0aef05d3;
	private String df0aef05d4;
	private String df0aef05d5;
	private String df0aef05d6;
	private String df0aef05d7;
	private String df0aef05d8;
	private String df0aef05d9;
	private String df0aef05da;
	private String df0aef05db;
	private String df0aef05dc;
	private String df0aef05dd;
	private String df0aef05de;
	private String df0aef05df;
	private String df0aef06a0;
	private String df0aef06a1;
	private String df0aef06a2;
	private String df0aef06a3;
	private String df0aef06a4;
	private String df0aef06a5;
	private String df0aef06a6;
	private String df0aef06a7;
	private String df0aef06a8;
	private String df0aef06a9;
	private String df0aef06aa;
	private String df0aef06ab;
	private String cardId;
	private String atr;
	private String rfatr;
	private String nj;
	private String df02ef0852;
	private String df02ef0853;
	private String df02ef0854;
	private String df02ef0955;
	private String df02ef0956;
	private String df02ef0996;
	private String df02ef0997;
	private String df03ef0560;
	private String df04ef0581;
	private String df04ef0584;
	private String df04ef0586;
	private String df04ef0587;
	private String df04ef0589;
	private String df04ef058a;
	private String df04ef0690;
	private String df04ef0692;
	private String df04ef0693;
	private String df04ef0ca0;
	private String ssseef0507;
	private String ssseef0506;
	private BigDecimal sbId;
	private String sbState;
	private String customerId;

	// Constructors

	/** default constructor */
	public CardTaskListSb() {
	}

	/** minimal constructor */
	public CardTaskListSb(String taskId) {
		this.taskId = taskId;
	}

	/** full constructor */
	public CardTaskListSb(String taskId, String ssseef0701, String ssseef0702,
			String ssseef0703, String ssseef0cf0, String ssseef0cf1,
			String df01ef092e, String df01ef0930, String df01ef0931,
			String df01ef0932, String df01ef0a37, String df01ef0a38,
			String df01ef0a39, String df01ef0cf2, String df01ef0cf3,
			String df02ef055701, String df02ef055801, String df02ef055901,
			String df02ef055702, String df02ef055802, String df02ef055902,
			String df02ef0542, String df02ef055a01, String df02ef055b01,
			String df02ef055c01, String df02ef055d01, String df02ef055a02,
			String df02ef055b02, String df02ef055c02, String df02ef055d02,
			String df02ef064b, String df02ef064c, String df02ef0660,
			String df02ef064d, String df02ef064f, String df02ef0650,
			String df02ef063a, String df02ef070101, String df02ef070102,
			String df02ef070103, String df02ef070104, String df02ef070201,
			String df02ef070202, String df02ef070203, String df02ef070204,
			String df02ef070301, String df02ef070302, String df02ef070303,
			String df02ef070304, String df02ef070401, String df02ef070402,
			String df02ef070403, String df02ef070404, String df03ef0598,
			String df03ef0561, String df03ef0562, String df03ef0563,
			String df03ef0564, String df03ef0565, String df03ef0566,
			String df03ef0667, String df03ef0668, String df03ef0669,
			String df03ef066a, String df03ef066b, String df03ef076c,
			String df03ef076d, String df03ef076e, String df03ef076f,
			String df03ef0770, String df03ef0771, String df03ef0772,
			String df03ef0773, String df04ef0580, String df04ef0583,
			String df04ef058b, String df04ef058c, String df04ef058f,
			String df04ef05f4, String df04ef05f5, String df04ef05f6,
			String df04ef05f7, String df04ef05f8, String df04ef05f9,
			String df04ef05fa, String df04ef05fb, String df04ef05fc,
			String df04ef05fd, String df04ef0790, String df04ef0792,
			String df04ef0793, String df04ef0794, String df04ef0795,
			String df04ef0c0101, String df04ef0c0102, String df04ef0c0201,
			String df04ef0c0202, String df04ef0d0101, String df04ef0d0102,
			String df04ef0d0201, String df04ef0d0202, String df04ef0ee1,
			String df04ef0ee2, String df04ef0ee3, String df04ef0ee4,
			String df04ef10b0, String df04ef10b1, String df04ef10b2,
			String df04ef10b3, String df04ef10b4, String df04ef10b5,
			String df04ef10b6, String df04ef10b7, String df04ef10b8,
			String df04ef10b9, String df04ef10ba, String df04ef10bb,
			String df04ef10bc, String df04ef10bd, String df04ef10be,
			String df04ef10bf, String df04ef10c0, String df04ef10c1,
			String df04ef10c2, String df04ef10c3, String df04ef10c4,
			String df0aef05d0, String df0aef05d1, String df0aef05d2,
			String df0aef05d3, String df0aef05d4, String df0aef05d5,
			String df0aef05d6, String df0aef05d7, String df0aef05d8,
			String df0aef05d9, String df0aef05da, String df0aef05db,
			String df0aef05dc, String df0aef05dd, String df0aef05de,
			String df0aef05df, String df0aef06a0, String df0aef06a1,
			String df0aef06a2, String df0aef06a3, String df0aef06a4,
			String df0aef06a5, String df0aef06a6, String df0aef06a7,
			String df0aef06a8, String df0aef06a9, String df0aef06aa,
			String df0aef06ab, String cardId, String atr, String rfatr,
			String nj, String df02ef0852, String df02ef0853, String df02ef0854,
			String df02ef0955, String df02ef0956, String df02ef0996,
			String df02ef0997, String df03ef0560, String df04ef0581,
			String df04ef0584, String df04ef0586, String df04ef0587,
			String df04ef0589, String df04ef058a, String df04ef0690,
			String df04ef0692, String df04ef0693, String df04ef0ca0,
			String ssseef0507, String ssseef0506, BigDecimal sbId,
			String sbState, String customerId) {
		this.taskId = taskId;
		this.ssseef0701 = ssseef0701;
		this.ssseef0702 = ssseef0702;
		this.ssseef0703 = ssseef0703;
		this.ssseef0cf0 = ssseef0cf0;
		this.ssseef0cf1 = ssseef0cf1;
		this.df01ef092e = df01ef092e;
		this.df01ef0930 = df01ef0930;
		this.df01ef0931 = df01ef0931;
		this.df01ef0932 = df01ef0932;
		this.df01ef0a37 = df01ef0a37;
		this.df01ef0a38 = df01ef0a38;
		this.df01ef0a39 = df01ef0a39;
		this.df01ef0cf2 = df01ef0cf2;
		this.df01ef0cf3 = df01ef0cf3;
		this.df02ef055701 = df02ef055701;
		this.df02ef055801 = df02ef055801;
		this.df02ef055901 = df02ef055901;
		this.df02ef055702 = df02ef055702;
		this.df02ef055802 = df02ef055802;
		this.df02ef055902 = df02ef055902;
		this.df02ef0542 = df02ef0542;
		this.df02ef055a01 = df02ef055a01;
		this.df02ef055b01 = df02ef055b01;
		this.df02ef055c01 = df02ef055c01;
		this.df02ef055d01 = df02ef055d01;
		this.df02ef055a02 = df02ef055a02;
		this.df02ef055b02 = df02ef055b02;
		this.df02ef055c02 = df02ef055c02;
		this.df02ef055d02 = df02ef055d02;
		this.df02ef064b = df02ef064b;
		this.df02ef064c = df02ef064c;
		this.df02ef0660 = df02ef0660;
		this.df02ef064d = df02ef064d;
		this.df02ef064f = df02ef064f;
		this.df02ef0650 = df02ef0650;
		this.df02ef063a = df02ef063a;
		this.df02ef070101 = df02ef070101;
		this.df02ef070102 = df02ef070102;
		this.df02ef070103 = df02ef070103;
		this.df02ef070104 = df02ef070104;
		this.df02ef070201 = df02ef070201;
		this.df02ef070202 = df02ef070202;
		this.df02ef070203 = df02ef070203;
		this.df02ef070204 = df02ef070204;
		this.df02ef070301 = df02ef070301;
		this.df02ef070302 = df02ef070302;
		this.df02ef070303 = df02ef070303;
		this.df02ef070304 = df02ef070304;
		this.df02ef070401 = df02ef070401;
		this.df02ef070402 = df02ef070402;
		this.df02ef070403 = df02ef070403;
		this.df02ef070404 = df02ef070404;
		this.df03ef0598 = df03ef0598;
		this.df03ef0561 = df03ef0561;
		this.df03ef0562 = df03ef0562;
		this.df03ef0563 = df03ef0563;
		this.df03ef0564 = df03ef0564;
		this.df03ef0565 = df03ef0565;
		this.df03ef0566 = df03ef0566;
		this.df03ef0667 = df03ef0667;
		this.df03ef0668 = df03ef0668;
		this.df03ef0669 = df03ef0669;
		this.df03ef066a = df03ef066a;
		this.df03ef066b = df03ef066b;
		this.df03ef076c = df03ef076c;
		this.df03ef076d = df03ef076d;
		this.df03ef076e = df03ef076e;
		this.df03ef076f = df03ef076f;
		this.df03ef0770 = df03ef0770;
		this.df03ef0771 = df03ef0771;
		this.df03ef0772 = df03ef0772;
		this.df03ef0773 = df03ef0773;
		this.df04ef0580 = df04ef0580;
		this.df04ef0583 = df04ef0583;
		this.df04ef058b = df04ef058b;
		this.df04ef058c = df04ef058c;
		this.df04ef058f = df04ef058f;
		this.df04ef05f4 = df04ef05f4;
		this.df04ef05f5 = df04ef05f5;
		this.df04ef05f6 = df04ef05f6;
		this.df04ef05f7 = df04ef05f7;
		this.df04ef05f8 = df04ef05f8;
		this.df04ef05f9 = df04ef05f9;
		this.df04ef05fa = df04ef05fa;
		this.df04ef05fb = df04ef05fb;
		this.df04ef05fc = df04ef05fc;
		this.df04ef05fd = df04ef05fd;
		this.df04ef0790 = df04ef0790;
		this.df04ef0792 = df04ef0792;
		this.df04ef0793 = df04ef0793;
		this.df04ef0794 = df04ef0794;
		this.df04ef0795 = df04ef0795;
		this.df04ef0c0101 = df04ef0c0101;
		this.df04ef0c0102 = df04ef0c0102;
		this.df04ef0c0201 = df04ef0c0201;
		this.df04ef0c0202 = df04ef0c0202;
		this.df04ef0d0101 = df04ef0d0101;
		this.df04ef0d0102 = df04ef0d0102;
		this.df04ef0d0201 = df04ef0d0201;
		this.df04ef0d0202 = df04ef0d0202;
		this.df04ef0ee1 = df04ef0ee1;
		this.df04ef0ee2 = df04ef0ee2;
		this.df04ef0ee3 = df04ef0ee3;
		this.df04ef0ee4 = df04ef0ee4;
		this.df04ef10b0 = df04ef10b0;
		this.df04ef10b1 = df04ef10b1;
		this.df04ef10b2 = df04ef10b2;
		this.df04ef10b3 = df04ef10b3;
		this.df04ef10b4 = df04ef10b4;
		this.df04ef10b5 = df04ef10b5;
		this.df04ef10b6 = df04ef10b6;
		this.df04ef10b7 = df04ef10b7;
		this.df04ef10b8 = df04ef10b8;
		this.df04ef10b9 = df04ef10b9;
		this.df04ef10ba = df04ef10ba;
		this.df04ef10bb = df04ef10bb;
		this.df04ef10bc = df04ef10bc;
		this.df04ef10bd = df04ef10bd;
		this.df04ef10be = df04ef10be;
		this.df04ef10bf = df04ef10bf;
		this.df04ef10c0 = df04ef10c0;
		this.df04ef10c1 = df04ef10c1;
		this.df04ef10c2 = df04ef10c2;
		this.df04ef10c3 = df04ef10c3;
		this.df04ef10c4 = df04ef10c4;
		this.df0aef05d0 = df0aef05d0;
		this.df0aef05d1 = df0aef05d1;
		this.df0aef05d2 = df0aef05d2;
		this.df0aef05d3 = df0aef05d3;
		this.df0aef05d4 = df0aef05d4;
		this.df0aef05d5 = df0aef05d5;
		this.df0aef05d6 = df0aef05d6;
		this.df0aef05d7 = df0aef05d7;
		this.df0aef05d8 = df0aef05d8;
		this.df0aef05d9 = df0aef05d9;
		this.df0aef05da = df0aef05da;
		this.df0aef05db = df0aef05db;
		this.df0aef05dc = df0aef05dc;
		this.df0aef05dd = df0aef05dd;
		this.df0aef05de = df0aef05de;
		this.df0aef05df = df0aef05df;
		this.df0aef06a0 = df0aef06a0;
		this.df0aef06a1 = df0aef06a1;
		this.df0aef06a2 = df0aef06a2;
		this.df0aef06a3 = df0aef06a3;
		this.df0aef06a4 = df0aef06a4;
		this.df0aef06a5 = df0aef06a5;
		this.df0aef06a6 = df0aef06a6;
		this.df0aef06a7 = df0aef06a7;
		this.df0aef06a8 = df0aef06a8;
		this.df0aef06a9 = df0aef06a9;
		this.df0aef06aa = df0aef06aa;
		this.df0aef06ab = df0aef06ab;
		this.cardId = cardId;
		this.atr = atr;
		this.rfatr = rfatr;
		this.nj = nj;
		this.df02ef0852 = df02ef0852;
		this.df02ef0853 = df02ef0853;
		this.df02ef0854 = df02ef0854;
		this.df02ef0955 = df02ef0955;
		this.df02ef0956 = df02ef0956;
		this.df02ef0996 = df02ef0996;
		this.df02ef0997 = df02ef0997;
		this.df03ef0560 = df03ef0560;
		this.df04ef0581 = df04ef0581;
		this.df04ef0584 = df04ef0584;
		this.df04ef0586 = df04ef0586;
		this.df04ef0587 = df04ef0587;
		this.df04ef0589 = df04ef0589;
		this.df04ef058a = df04ef058a;
		this.df04ef0690 = df04ef0690;
		this.df04ef0692 = df04ef0692;
		this.df04ef0693 = df04ef0693;
		this.df04ef0ca0 = df04ef0ca0;
		this.ssseef0507 = ssseef0507;
		this.ssseef0506 = ssseef0506;
		this.sbId = sbId;
		this.sbState = sbState;
		this.customerId = customerId;
	}

	// Property accessors
	@Id
	@Column(name = "TASK_ID", unique = true, nullable = false, length = 18)
	public String getTaskId() {
		return this.taskId;
	}

	public void setTaskId(String taskId) {
		this.taskId = taskId;
	}

	@Column(name = "SSSEEF0701", length = 768)
	public String getSsseef0701() {
		return this.ssseef0701;
	}

	public void setSsseef0701(String ssseef0701) {
		this.ssseef0701 = ssseef0701;
	}

	@Column(name = "SSSEEF0702", length = 1)
	public String getSsseef0702() {
		return this.ssseef0702;
	}

	public void setSsseef0702(String ssseef0702) {
		this.ssseef0702 = ssseef0702;
	}

	@Column(name = "SSSEEF0703", length = 2)
	public String getSsseef0703() {
		return this.ssseef0703;
	}

	public void setSsseef0703(String ssseef0703) {
		this.ssseef0703 = ssseef0703;
	}

	@Column(name = "SSSEEF0CF0", length = 18)
	public String getSsseef0cf0() {
		return this.ssseef0cf0;
	}

	public void setSsseef0cf0(String ssseef0cf0) {
		this.ssseef0cf0 = ssseef0cf0;
	}

	@Column(name = "SSSEEF0CF1", length = 20)
	public String getSsseef0cf1() {
		return this.ssseef0cf1;
	}

	public void setSsseef0cf1(String ssseef0cf1) {
		this.ssseef0cf1 = ssseef0cf1;
	}

	@Column(name = "DF01EF092E", length = 70)
	public String getDf01ef092e() {
		return this.df01ef092e;
	}

	public void setDf01ef092e(String df01ef092e) {
		this.df01ef092e = df01ef092e;
	}

	@Column(name = "DF01EF0930", length = 9)
	public String getDf01ef0930() {
		return this.df01ef0930;
	}

	public void setDf01ef0930(String df01ef0930) {
		this.df01ef0930 = df01ef0930;
	}

	@Column(name = "DF01EF0931", length = 1)
	public String getDf01ef0931() {
		return this.df01ef0931;
	}

	public void setDf01ef0931(String df01ef0931) {
		this.df01ef0931 = df01ef0931;
	}

	@Column(name = "DF01EF0932", length = 3)
	public String getDf01ef0932() {
		return this.df01ef0932;
	}

	public void setDf01ef0932(String df01ef0932) {
		this.df01ef0932 = df01ef0932;
	}

	@Column(name = "DF01EF0A37", length = 8)
	public String getDf01ef0a37() {
		return this.df01ef0a37;
	}

	public void setDf01ef0a37(String df01ef0a37) {
		this.df01ef0a37 = df01ef0a37;
	}

	@Column(name = "DF01EF0A38", length = 8)
	public String getDf01ef0a38() {
		return this.df01ef0a38;
	}

	public void setDf01ef0a38(String df01ef0a38) {
		this.df01ef0a38 = df01ef0a38;
	}

	@Column(name = "DF01EF0A39", length = 8)
	public String getDf01ef0a39() {
		return this.df01ef0a39;
	}

	public void setDf01ef0a39(String df01ef0a39) {
		this.df01ef0a39 = df01ef0a39;
	}

	@Column(name = "DF01EF0CF2", length = 2)
	public String getDf01ef0cf2() {
		return this.df01ef0cf2;
	}

	public void setDf01ef0cf2(String df01ef0cf2) {
		this.df01ef0cf2 = df01ef0cf2;
	}

	@Column(name = "DF01EF0CF3", length = 2)
	public String getDf01ef0cf3() {
		return this.df01ef0cf3;
	}

	public void setDf01ef0cf3(String df01ef0cf3) {
		this.df01ef0cf3 = df01ef0cf3;
	}

	@Column(name = "DF02EF055701", length = 3)
	public String getDf02ef055701() {
		return this.df02ef055701;
	}

	public void setDf02ef055701(String df02ef055701) {
		this.df02ef055701 = df02ef055701;
	}

	@Column(name = "DF02EF055801", length = 6)
	public String getDf02ef055801() {
		return this.df02ef055801;
	}

	public void setDf02ef055801(String df02ef055801) {
		this.df02ef055801 = df02ef055801;
	}

	@Column(name = "DF02EF055901", length = 40)
	public String getDf02ef055901() {
		return this.df02ef055901;
	}

	public void setDf02ef055901(String df02ef055901) {
		this.df02ef055901 = df02ef055901;
	}

	@Column(name = "DF02EF055702", length = 3)
	public String getDf02ef055702() {
		return this.df02ef055702;
	}

	public void setDf02ef055702(String df02ef055702) {
		this.df02ef055702 = df02ef055702;
	}

	@Column(name = "DF02EF055802", length = 6)
	public String getDf02ef055802() {
		return this.df02ef055802;
	}

	public void setDf02ef055802(String df02ef055802) {
		this.df02ef055802 = df02ef055802;
	}

	@Column(name = "DF02EF055902", length = 40)
	public String getDf02ef055902() {
		return this.df02ef055902;
	}

	public void setDf02ef055902(String df02ef055902) {
		this.df02ef055902 = df02ef055902;
	}

	@Column(name = "DF02EF0542", length = 3)
	public String getDf02ef0542() {
		return this.df02ef0542;
	}

	public void setDf02ef0542(String df02ef0542) {
		this.df02ef0542 = df02ef0542;
	}

	@Column(name = "DF02EF055A01", length = 7)
	public String getDf02ef055a01() {
		return this.df02ef055a01;
	}

	public void setDf02ef055a01(String df02ef055a01) {
		this.df02ef055a01 = df02ef055a01;
	}

	@Column(name = "DF02EF055B01", length = 1)
	public String getDf02ef055b01() {
		return this.df02ef055b01;
	}

	public void setDf02ef055b01(String df02ef055b01) {
		this.df02ef055b01 = df02ef055b01;
	}

	@Column(name = "DF02EF055C01", length = 9)
	public String getDf02ef055c01() {
		return this.df02ef055c01;
	}

	public void setDf02ef055c01(String df02ef055c01) {
		this.df02ef055c01 = df02ef055c01;
	}

	@Column(name = "DF02EF055D01", length = 8)
	public String getDf02ef055d01() {
		return this.df02ef055d01;
	}

	public void setDf02ef055d01(String df02ef055d01) {
		this.df02ef055d01 = df02ef055d01;
	}

	@Column(name = "DF02EF055A02", length = 7)
	public String getDf02ef055a02() {
		return this.df02ef055a02;
	}

	public void setDf02ef055a02(String df02ef055a02) {
		this.df02ef055a02 = df02ef055a02;
	}

	@Column(name = "DF02EF055B02", length = 1)
	public String getDf02ef055b02() {
		return this.df02ef055b02;
	}

	public void setDf02ef055b02(String df02ef055b02) {
		this.df02ef055b02 = df02ef055b02;
	}

	@Column(name = "DF02EF055C02", length = 9)
	public String getDf02ef055c02() {
		return this.df02ef055c02;
	}

	public void setDf02ef055c02(String df02ef055c02) {
		this.df02ef055c02 = df02ef055c02;
	}

	@Column(name = "DF02EF055D02", length = 8)
	public String getDf02ef055d02() {
		return this.df02ef055d02;
	}

	public void setDf02ef055d02(String df02ef055d02) {
		this.df02ef055d02 = df02ef055d02;
	}

	@Column(name = "DF02EF064B", length = 8)
	public String getDf02ef064b() {
		return this.df02ef064b;
	}

	public void setDf02ef064b(String df02ef064b) {
		this.df02ef064b = df02ef064b;
	}

	@Column(name = "DF02EF064C", length = 8)
	public String getDf02ef064c() {
		return this.df02ef064c;
	}

	public void setDf02ef064c(String df02ef064c) {
		this.df02ef064c = df02ef064c;
	}

	@Column(name = "DF02EF0660", length = 8)
	public String getDf02ef0660() {
		return this.df02ef0660;
	}

	public void setDf02ef0660(String df02ef0660) {
		this.df02ef0660 = df02ef0660;
	}

	@Column(name = "DF02EF064D", length = 8)
	public String getDf02ef064d() {
		return this.df02ef064d;
	}

	public void setDf02ef064d(String df02ef064d) {
		this.df02ef064d = df02ef064d;
	}

	@Column(name = "DF02EF064F", length = 8)
	public String getDf02ef064f() {
		return this.df02ef064f;
	}

	public void setDf02ef064f(String df02ef064f) {
		this.df02ef064f = df02ef064f;
	}

	@Column(name = "DF02EF0650", length = 8)
	public String getDf02ef0650() {
		return this.df02ef0650;
	}

	public void setDf02ef0650(String df02ef0650) {
		this.df02ef0650 = df02ef0650;
	}

	@Column(name = "DF02EF063A", length = 7)
	public String getDf02ef063a() {
		return this.df02ef063a;
	}

	public void setDf02ef063a(String df02ef063a) {
		this.df02ef063a = df02ef063a;
	}

	@Column(name = "DF02EF070101", length = 7)
	public String getDf02ef070101() {
		return this.df02ef070101;
	}

	public void setDf02ef070101(String df02ef070101) {
		this.df02ef070101 = df02ef070101;
	}

	@Column(name = "DF02EF070102", length = 8)
	public String getDf02ef070102() {
		return this.df02ef070102;
	}

	public void setDf02ef070102(String df02ef070102) {
		this.df02ef070102 = df02ef070102;
	}

	@Column(name = "DF02EF070103", length = 8)
	public String getDf02ef070103() {
		return this.df02ef070103;
	}

	public void setDf02ef070103(String df02ef070103) {
		this.df02ef070103 = df02ef070103;
	}

	@Column(name = "DF02EF070104", length = 70)
	public String getDf02ef070104() {
		return this.df02ef070104;
	}

	public void setDf02ef070104(String df02ef070104) {
		this.df02ef070104 = df02ef070104;
	}

	@Column(name = "DF02EF070201", length = 7)
	public String getDf02ef070201() {
		return this.df02ef070201;
	}

	public void setDf02ef070201(String df02ef070201) {
		this.df02ef070201 = df02ef070201;
	}

	@Column(name = "DF02EF070202", length = 8)
	public String getDf02ef070202() {
		return this.df02ef070202;
	}

	public void setDf02ef070202(String df02ef070202) {
		this.df02ef070202 = df02ef070202;
	}

	@Column(name = "DF02EF070203", length = 8)
	public String getDf02ef070203() {
		return this.df02ef070203;
	}

	public void setDf02ef070203(String df02ef070203) {
		this.df02ef070203 = df02ef070203;
	}

	@Column(name = "DF02EF070204", length = 70)
	public String getDf02ef070204() {
		return this.df02ef070204;
	}

	public void setDf02ef070204(String df02ef070204) {
		this.df02ef070204 = df02ef070204;
	}

	@Column(name = "DF02EF070301", length = 7)
	public String getDf02ef070301() {
		return this.df02ef070301;
	}

	public void setDf02ef070301(String df02ef070301) {
		this.df02ef070301 = df02ef070301;
	}

	@Column(name = "DF02EF070302", length = 8)
	public String getDf02ef070302() {
		return this.df02ef070302;
	}

	public void setDf02ef070302(String df02ef070302) {
		this.df02ef070302 = df02ef070302;
	}

	@Column(name = "DF02EF070303", length = 8)
	public String getDf02ef070303() {
		return this.df02ef070303;
	}

	public void setDf02ef070303(String df02ef070303) {
		this.df02ef070303 = df02ef070303;
	}

	@Column(name = "DF02EF070304", length = 70)
	public String getDf02ef070304() {
		return this.df02ef070304;
	}

	public void setDf02ef070304(String df02ef070304) {
		this.df02ef070304 = df02ef070304;
	}

	@Column(name = "DF02EF070401", length = 7)
	public String getDf02ef070401() {
		return this.df02ef070401;
	}

	public void setDf02ef070401(String df02ef070401) {
		this.df02ef070401 = df02ef070401;
	}

	@Column(name = "DF02EF070402", length = 8)
	public String getDf02ef070402() {
		return this.df02ef070402;
	}

	public void setDf02ef070402(String df02ef070402) {
		this.df02ef070402 = df02ef070402;
	}

	@Column(name = "DF02EF070403", length = 8)
	public String getDf02ef070403() {
		return this.df02ef070403;
	}

	public void setDf02ef070403(String df02ef070403) {
		this.df02ef070403 = df02ef070403;
	}

	@Column(name = "DF02EF070404", length = 70)
	public String getDf02ef070404() {
		return this.df02ef070404;
	}

	public void setDf02ef070404(String df02ef070404) {
		this.df02ef070404 = df02ef070404;
	}

	@Column(name = "DF03EF0598", length = 8)
	public String getDf03ef0598() {
		return this.df03ef0598;
	}

	public void setDf03ef0598(String df03ef0598) {
		this.df03ef0598 = df03ef0598;
	}

	@Column(name = "DF03EF0561", length = 8)
	public String getDf03ef0561() {
		return this.df03ef0561;
	}

	public void setDf03ef0561(String df03ef0561) {
		this.df03ef0561 = df03ef0561;
	}

	@Column(name = "DF03EF0562", length = 8)
	public String getDf03ef0562() {
		return this.df03ef0562;
	}

	public void setDf03ef0562(String df03ef0562) {
		this.df03ef0562 = df03ef0562;
	}

	@Column(name = "DF03EF0563", length = 3)
	public String getDf03ef0563() {
		return this.df03ef0563;
	}

	public void setDf03ef0563(String df03ef0563) {
		this.df03ef0563 = df03ef0563;
	}

	@Column(name = "DF03EF0564", length = 3)
	public String getDf03ef0564() {
		return this.df03ef0564;
	}

	public void setDf03ef0564(String df03ef0564) {
		this.df03ef0564 = df03ef0564;
	}

	@Column(name = "DF03EF0565", length = 3)
	public String getDf03ef0565() {
		return this.df03ef0565;
	}

	public void setDf03ef0565(String df03ef0565) {
		this.df03ef0565 = df03ef0565;
	}

	@Column(name = "DF03EF0566", length = 3)
	public String getDf03ef0566() {
		return this.df03ef0566;
	}

	public void setDf03ef0566(String df03ef0566) {
		this.df03ef0566 = df03ef0566;
	}

	@Column(name = "DF03EF0667", length = 8)
	public String getDf03ef0667() {
		return this.df03ef0667;
	}

	public void setDf03ef0667(String df03ef0667) {
		this.df03ef0667 = df03ef0667;
	}

	@Column(name = "DF03EF0668", length = 62)
	public String getDf03ef0668() {
		return this.df03ef0668;
	}

	public void setDf03ef0668(String df03ef0668) {
		this.df03ef0668 = df03ef0668;
	}

	@Column(name = "DF03EF0669", length = 62)
	public String getDf03ef0669() {
		return this.df03ef0669;
	}

	public void setDf03ef0669(String df03ef0669) {
		this.df03ef0669 = df03ef0669;
	}

	@Column(name = "DF03EF066A", length = 16)
	public String getDf03ef066a() {
		return this.df03ef066a;
	}

	public void setDf03ef066a(String df03ef066a) {
		this.df03ef066a = df03ef066a;
	}

	@Column(name = "DF03EF066B", length = 60)
	public String getDf03ef066b() {
		return this.df03ef066b;
	}

	public void setDf03ef066b(String df03ef066b) {
		this.df03ef066b = df03ef066b;
	}

	@Column(name = "DF03EF076C", length = 8)
	public String getDf03ef076c() {
		return this.df03ef076c;
	}

	public void setDf03ef076c(String df03ef076c) {
		this.df03ef076c = df03ef076c;
	}

	@Column(name = "DF03EF076D", length = 8)
	public String getDf03ef076d() {
		return this.df03ef076d;
	}

	public void setDf03ef076d(String df03ef076d) {
		this.df03ef076d = df03ef076d;
	}

	@Column(name = "DF03EF076E", length = 8)
	public String getDf03ef076e() {
		return this.df03ef076e;
	}

	public void setDf03ef076e(String df03ef076e) {
		this.df03ef076e = df03ef076e;
	}

	@Column(name = "DF03EF076F", length = 8)
	public String getDf03ef076f() {
		return this.df03ef076f;
	}

	public void setDf03ef076f(String df03ef076f) {
		this.df03ef076f = df03ef076f;
	}

	@Column(name = "DF03EF0770", length = 3)
	public String getDf03ef0770() {
		return this.df03ef0770;
	}

	public void setDf03ef0770(String df03ef0770) {
		this.df03ef0770 = df03ef0770;
	}

	@Column(name = "DF03EF0771", length = 8)
	public String getDf03ef0771() {
		return this.df03ef0771;
	}

	public void setDf03ef0771(String df03ef0771) {
		this.df03ef0771 = df03ef0771;
	}

	@Column(name = "DF03EF0772", length = 8)
	public String getDf03ef0772() {
		return this.df03ef0772;
	}

	public void setDf03ef0772(String df03ef0772) {
		this.df03ef0772 = df03ef0772;
	}

	@Column(name = "DF03EF0773", length = 8)
	public String getDf03ef0773() {
		return this.df03ef0773;
	}

	public void setDf03ef0773(String df03ef0773) {
		this.df03ef0773 = df03ef0773;
	}

	@Column(name = "DF04EF0580", length = 8)
	public String getDf04ef0580() {
		return this.df04ef0580;
	}

	public void setDf04ef0580(String df04ef0580) {
		this.df04ef0580 = df04ef0580;
	}

	@Column(name = "DF04EF0583", length = 9)
	public String getDf04ef0583() {
		return this.df04ef0583;
	}

	public void setDf04ef0583(String df04ef0583) {
		this.df04ef0583 = df04ef0583;
	}

	@Column(name = "DF04EF058B", length = 10)
	public String getDf04ef058b() {
		return this.df04ef058b;
	}

	public void setDf04ef058b(String df04ef058b) {
		this.df04ef058b = df04ef058b;
	}

	@Column(name = "DF04EF058C", length = 2)
	public String getDf04ef058c() {
		return this.df04ef058c;
	}

	public void setDf04ef058c(String df04ef058c) {
		this.df04ef058c = df04ef058c;
	}

	@Column(name = "DF04EF058F", length = 1)
	public String getDf04ef058f() {
		return this.df04ef058f;
	}

	public void setDf04ef058f(String df04ef058f) {
		this.df04ef058f = df04ef058f;
	}

	@Column(name = "DF04EF05F4", length = 14)
	public String getDf04ef05f4() {
		return this.df04ef05f4;
	}

	public void setDf04ef05f4(String df04ef05f4) {
		this.df04ef05f4 = df04ef05f4;
	}

	@Column(name = "DF04EF05F5", length = 2)
	public String getDf04ef05f5() {
		return this.df04ef05f5;
	}

	public void setDf04ef05f5(String df04ef05f5) {
		this.df04ef05f5 = df04ef05f5;
	}

	@Column(name = "DF04EF05F6", length = 1)
	public String getDf04ef05f6() {
		return this.df04ef05f6;
	}

	public void setDf04ef05f6(String df04ef05f6) {
		this.df04ef05f6 = df04ef05f6;
	}

	@Column(name = "DF04EF05F7", length = 1)
	public String getDf04ef05f7() {
		return this.df04ef05f7;
	}

	public void setDf04ef05f7(String df04ef05f7) {
		this.df04ef05f7 = df04ef05f7;
	}

	@Column(name = "DF04EF05F8", length = 1)
	public String getDf04ef05f8() {
		return this.df04ef05f8;
	}

	public void setDf04ef05f8(String df04ef05f8) {
		this.df04ef05f8 = df04ef05f8;
	}

	@Column(name = "DF04EF05F9", length = 14)
	public String getDf04ef05f9() {
		return this.df04ef05f9;
	}

	public void setDf04ef05f9(String df04ef05f9) {
		this.df04ef05f9 = df04ef05f9;
	}

	@Column(name = "DF04EF05FA", length = 6)
	public String getDf04ef05fa() {
		return this.df04ef05fa;
	}

	public void setDf04ef05fa(String df04ef05fa) {
		this.df04ef05fa = df04ef05fa;
	}

	@Column(name = "DF04EF05FB", length = 6)
	public String getDf04ef05fb() {
		return this.df04ef05fb;
	}

	public void setDf04ef05fb(String df04ef05fb) {
		this.df04ef05fb = df04ef05fb;
	}

	@Column(name = "DF04EF05FC", length = 6)
	public String getDf04ef05fc() {
		return this.df04ef05fc;
	}

	public void setDf04ef05fc(String df04ef05fc) {
		this.df04ef05fc = df04ef05fc;
	}

	@Column(name = "DF04EF05FD", length = 6)
	public String getDf04ef05fd() {
		return this.df04ef05fd;
	}

	public void setDf04ef05fd(String df04ef05fd) {
		this.df04ef05fd = df04ef05fd;
	}

	@Column(name = "DF04EF0790", length = 10)
	public String getDf04ef0790() {
		return this.df04ef0790;
	}

	public void setDf04ef0790(String df04ef0790) {
		this.df04ef0790 = df04ef0790;
	}

	@Column(name = "DF04EF0792", length = 10)
	public String getDf04ef0792() {
		return this.df04ef0792;
	}

	public void setDf04ef0792(String df04ef0792) {
		this.df04ef0792 = df04ef0792;
	}

	@Column(name = "DF04EF0793", length = 10)
	public String getDf04ef0793() {
		return this.df04ef0793;
	}

	public void setDf04ef0793(String df04ef0793) {
		this.df04ef0793 = df04ef0793;
	}

	@Column(name = "DF04EF0794", length = 10)
	public String getDf04ef0794() {
		return this.df04ef0794;
	}

	public void setDf04ef0794(String df04ef0794) {
		this.df04ef0794 = df04ef0794;
	}

	@Column(name = "DF04EF0795", length = 10)
	public String getDf04ef0795() {
		return this.df04ef0795;
	}

	public void setDf04ef0795(String df04ef0795) {
		this.df04ef0795 = df04ef0795;
	}

	@Column(name = "DF04EF0C0101", length = 10)
	public String getDf04ef0c0101() {
		return this.df04ef0c0101;
	}

	public void setDf04ef0c0101(String df04ef0c0101) {
		this.df04ef0c0101 = df04ef0c0101;
	}

	@Column(name = "DF04EF0C0102", length = 10)
	public String getDf04ef0c0102() {
		return this.df04ef0c0102;
	}

	public void setDf04ef0c0102(String df04ef0c0102) {
		this.df04ef0c0102 = df04ef0c0102;
	}

	@Column(name = "DF04EF0C0201", length = 10)
	public String getDf04ef0c0201() {
		return this.df04ef0c0201;
	}

	public void setDf04ef0c0201(String df04ef0c0201) {
		this.df04ef0c0201 = df04ef0c0201;
	}

	@Column(name = "DF04EF0C0202", length = 10)
	public String getDf04ef0c0202() {
		return this.df04ef0c0202;
	}

	public void setDf04ef0c0202(String df04ef0c0202) {
		this.df04ef0c0202 = df04ef0c0202;
	}

	@Column(name = "DF04EF0D0101", length = 10)
	public String getDf04ef0d0101() {
		return this.df04ef0d0101;
	}

	public void setDf04ef0d0101(String df04ef0d0101) {
		this.df04ef0d0101 = df04ef0d0101;
	}

	@Column(name = "DF04EF0D0102", length = 100)
	public String getDf04ef0d0102() {
		return this.df04ef0d0102;
	}

	public void setDf04ef0d0102(String df04ef0d0102) {
		this.df04ef0d0102 = df04ef0d0102;
	}

	@Column(name = "DF04EF0D0201", length = 100)
	public String getDf04ef0d0201() {
		return this.df04ef0d0201;
	}

	public void setDf04ef0d0201(String df04ef0d0201) {
		this.df04ef0d0201 = df04ef0d0201;
	}

	@Column(name = "DF04EF0D0202", length = 100)
	public String getDf04ef0d0202() {
		return this.df04ef0d0202;
	}

	public void setDf04ef0d0202(String df04ef0d0202) {
		this.df04ef0d0202 = df04ef0d0202;
	}

	@Column(name = "DF04EF0EE1", length = 100)
	public String getDf04ef0ee1() {
		return this.df04ef0ee1;
	}

	public void setDf04ef0ee1(String df04ef0ee1) {
		this.df04ef0ee1 = df04ef0ee1;
	}

	@Column(name = "DF04EF0EE2", length = 2000)
	public String getDf04ef0ee2() {
		return this.df04ef0ee2;
	}

	public void setDf04ef0ee2(String df04ef0ee2) {
		this.df04ef0ee2 = df04ef0ee2;
	}

	@Column(name = "DF04EF0EE3", length = 100)
	public String getDf04ef0ee3() {
		return this.df04ef0ee3;
	}

	public void setDf04ef0ee3(String df04ef0ee3) {
		this.df04ef0ee3 = df04ef0ee3;
	}

	@Column(name = "DF04EF0EE4", length = 100)
	public String getDf04ef0ee4() {
		return this.df04ef0ee4;
	}

	public void setDf04ef0ee4(String df04ef0ee4) {
		this.df04ef0ee4 = df04ef0ee4;
	}

	@Column(name = "DF04EF10B0", length = 100)
	public String getDf04ef10b0() {
		return this.df04ef10b0;
	}

	public void setDf04ef10b0(String df04ef10b0) {
		this.df04ef10b0 = df04ef10b0;
	}

	@Column(name = "DF04EF10B1", length = 100)
	public String getDf04ef10b1() {
		return this.df04ef10b1;
	}

	public void setDf04ef10b1(String df04ef10b1) {
		this.df04ef10b1 = df04ef10b1;
	}

	@Column(name = "DF04EF10B2", length = 100)
	public String getDf04ef10b2() {
		return this.df04ef10b2;
	}

	public void setDf04ef10b2(String df04ef10b2) {
		this.df04ef10b2 = df04ef10b2;
	}

	@Column(name = "DF04EF10B3", length = 100)
	public String getDf04ef10b3() {
		return this.df04ef10b3;
	}

	public void setDf04ef10b3(String df04ef10b3) {
		this.df04ef10b3 = df04ef10b3;
	}

	@Column(name = "DF04EF10B4", length = 100)
	public String getDf04ef10b4() {
		return this.df04ef10b4;
	}

	public void setDf04ef10b4(String df04ef10b4) {
		this.df04ef10b4 = df04ef10b4;
	}

	@Column(name = "DF04EF10B5", length = 100)
	public String getDf04ef10b5() {
		return this.df04ef10b5;
	}

	public void setDf04ef10b5(String df04ef10b5) {
		this.df04ef10b5 = df04ef10b5;
	}

	@Column(name = "DF04EF10B6", length = 100)
	public String getDf04ef10b6() {
		return this.df04ef10b6;
	}

	public void setDf04ef10b6(String df04ef10b6) {
		this.df04ef10b6 = df04ef10b6;
	}

	@Column(name = "DF04EF10B7", length = 100)
	public String getDf04ef10b7() {
		return this.df04ef10b7;
	}

	public void setDf04ef10b7(String df04ef10b7) {
		this.df04ef10b7 = df04ef10b7;
	}

	@Column(name = "DF04EF10B8", length = 100)
	public String getDf04ef10b8() {
		return this.df04ef10b8;
	}

	public void setDf04ef10b8(String df04ef10b8) {
		this.df04ef10b8 = df04ef10b8;
	}

	@Column(name = "DF04EF10B9", length = 100)
	public String getDf04ef10b9() {
		return this.df04ef10b9;
	}

	public void setDf04ef10b9(String df04ef10b9) {
		this.df04ef10b9 = df04ef10b9;
	}

	@Column(name = "DF04EF10BA", length = 100)
	public String getDf04ef10ba() {
		return this.df04ef10ba;
	}

	public void setDf04ef10ba(String df04ef10ba) {
		this.df04ef10ba = df04ef10ba;
	}

	@Column(name = "DF04EF10BB", length = 100)
	public String getDf04ef10bb() {
		return this.df04ef10bb;
	}

	public void setDf04ef10bb(String df04ef10bb) {
		this.df04ef10bb = df04ef10bb;
	}

	@Column(name = "DF04EF10BC", length = 100)
	public String getDf04ef10bc() {
		return this.df04ef10bc;
	}

	public void setDf04ef10bc(String df04ef10bc) {
		this.df04ef10bc = df04ef10bc;
	}

	@Column(name = "DF04EF10BD", length = 100)
	public String getDf04ef10bd() {
		return this.df04ef10bd;
	}

	public void setDf04ef10bd(String df04ef10bd) {
		this.df04ef10bd = df04ef10bd;
	}

	@Column(name = "DF04EF10BE", length = 100)
	public String getDf04ef10be() {
		return this.df04ef10be;
	}

	public void setDf04ef10be(String df04ef10be) {
		this.df04ef10be = df04ef10be;
	}

	@Column(name = "DF04EF10BF", length = 100)
	public String getDf04ef10bf() {
		return this.df04ef10bf;
	}

	public void setDf04ef10bf(String df04ef10bf) {
		this.df04ef10bf = df04ef10bf;
	}

	@Column(name = "DF04EF10C0", length = 100)
	public String getDf04ef10c0() {
		return this.df04ef10c0;
	}

	public void setDf04ef10c0(String df04ef10c0) {
		this.df04ef10c0 = df04ef10c0;
	}

	@Column(name = "DF04EF10C1", length = 100)
	public String getDf04ef10c1() {
		return this.df04ef10c1;
	}

	public void setDf04ef10c1(String df04ef10c1) {
		this.df04ef10c1 = df04ef10c1;
	}

	@Column(name = "DF04EF10C2", length = 100)
	public String getDf04ef10c2() {
		return this.df04ef10c2;
	}

	public void setDf04ef10c2(String df04ef10c2) {
		this.df04ef10c2 = df04ef10c2;
	}

	@Column(name = "DF04EF10C3", length = 100)
	public String getDf04ef10c3() {
		return this.df04ef10c3;
	}

	public void setDf04ef10c3(String df04ef10c3) {
		this.df04ef10c3 = df04ef10c3;
	}

	@Column(name = "DF04EF10C4", length = 100)
	public String getDf04ef10c4() {
		return this.df04ef10c4;
	}

	public void setDf04ef10c4(String df04ef10c4) {
		this.df04ef10c4 = df04ef10c4;
	}

	@Column(name = "DF0AEF05D0", length = 100)
	public String getDf0aef05d0() {
		return this.df0aef05d0;
	}

	public void setDf0aef05d0(String df0aef05d0) {
		this.df0aef05d0 = df0aef05d0;
	}

	@Column(name = "DF0AEF05D1", length = 100)
	public String getDf0aef05d1() {
		return this.df0aef05d1;
	}

	public void setDf0aef05d1(String df0aef05d1) {
		this.df0aef05d1 = df0aef05d1;
	}

	@Column(name = "DF0AEF05D2", length = 100)
	public String getDf0aef05d2() {
		return this.df0aef05d2;
	}

	public void setDf0aef05d2(String df0aef05d2) {
		this.df0aef05d2 = df0aef05d2;
	}

	@Column(name = "DF0AEF05D3", length = 100)
	public String getDf0aef05d3() {
		return this.df0aef05d3;
	}

	public void setDf0aef05d3(String df0aef05d3) {
		this.df0aef05d3 = df0aef05d3;
	}

	@Column(name = "DF0AEF05D4", length = 100)
	public String getDf0aef05d4() {
		return this.df0aef05d4;
	}

	public void setDf0aef05d4(String df0aef05d4) {
		this.df0aef05d4 = df0aef05d4;
	}

	@Column(name = "DF0AEF05D5", length = 100)
	public String getDf0aef05d5() {
		return this.df0aef05d5;
	}

	public void setDf0aef05d5(String df0aef05d5) {
		this.df0aef05d5 = df0aef05d5;
	}

	@Column(name = "DF0AEF05D6", length = 100)
	public String getDf0aef05d6() {
		return this.df0aef05d6;
	}

	public void setDf0aef05d6(String df0aef05d6) {
		this.df0aef05d6 = df0aef05d6;
	}

	@Column(name = "DF0AEF05D7", length = 1)
	public String getDf0aef05d7() {
		return this.df0aef05d7;
	}

	public void setDf0aef05d7(String df0aef05d7) {
		this.df0aef05d7 = df0aef05d7;
	}

	@Column(name = "DF0AEF05D8", length = 1)
	public String getDf0aef05d8() {
		return this.df0aef05d8;
	}

	public void setDf0aef05d8(String df0aef05d8) {
		this.df0aef05d8 = df0aef05d8;
	}

	@Column(name = "DF0AEF05D9", length = 1)
	public String getDf0aef05d9() {
		return this.df0aef05d9;
	}

	public void setDf0aef05d9(String df0aef05d9) {
		this.df0aef05d9 = df0aef05d9;
	}

	@Column(name = "DF0AEF05DA", length = 6)
	public String getDf0aef05da() {
		return this.df0aef05da;
	}

	public void setDf0aef05da(String df0aef05da) {
		this.df0aef05da = df0aef05da;
	}

	@Column(name = "DF0AEF05DB", length = 6)
	public String getDf0aef05db() {
		return this.df0aef05db;
	}

	public void setDf0aef05db(String df0aef05db) {
		this.df0aef05db = df0aef05db;
	}

	@Column(name = "DF0AEF05DC", length = 6)
	public String getDf0aef05dc() {
		return this.df0aef05dc;
	}

	public void setDf0aef05dc(String df0aef05dc) {
		this.df0aef05dc = df0aef05dc;
	}

	@Column(name = "DF0AEF05DD", length = 6)
	public String getDf0aef05dd() {
		return this.df0aef05dd;
	}

	public void setDf0aef05dd(String df0aef05dd) {
		this.df0aef05dd = df0aef05dd;
	}

	@Column(name = "DF0AEF05DE", length = 6)
	public String getDf0aef05de() {
		return this.df0aef05de;
	}

	public void setDf0aef05de(String df0aef05de) {
		this.df0aef05de = df0aef05de;
	}

	@Column(name = "DF0AEF05DF", length = 8)
	public String getDf0aef05df() {
		return this.df0aef05df;
	}

	public void setDf0aef05df(String df0aef05df) {
		this.df0aef05df = df0aef05df;
	}

	@Column(name = "DF0AEF06A0", length = 4)
	public String getDf0aef06a0() {
		return this.df0aef06a0;
	}

	public void setDf0aef06a0(String df0aef06a0) {
		this.df0aef06a0 = df0aef06a0;
	}

	@Column(name = "DF0AEF06A1", length = 4)
	public String getDf0aef06a1() {
		return this.df0aef06a1;
	}

	public void setDf0aef06a1(String df0aef06a1) {
		this.df0aef06a1 = df0aef06a1;
	}

	@Column(name = "DF0AEF06A2", length = 10)
	public String getDf0aef06a2() {
		return this.df0aef06a2;
	}

	public void setDf0aef06a2(String df0aef06a2) {
		this.df0aef06a2 = df0aef06a2;
	}

	@Column(name = "DF0AEF06A3", length = 10)
	public String getDf0aef06a3() {
		return this.df0aef06a3;
	}

	public void setDf0aef06a3(String df0aef06a3) {
		this.df0aef06a3 = df0aef06a3;
	}

	@Column(name = "DF0AEF06A4", length = 10)
	public String getDf0aef06a4() {
		return this.df0aef06a4;
	}

	public void setDf0aef06a4(String df0aef06a4) {
		this.df0aef06a4 = df0aef06a4;
	}

	@Column(name = "DF0AEF06A5", length = 10)
	public String getDf0aef06a5() {
		return this.df0aef06a5;
	}

	public void setDf0aef06a5(String df0aef06a5) {
		this.df0aef06a5 = df0aef06a5;
	}

	@Column(name = "DF0AEF06A6", length = 10)
	public String getDf0aef06a6() {
		return this.df0aef06a6;
	}

	public void setDf0aef06a6(String df0aef06a6) {
		this.df0aef06a6 = df0aef06a6;
	}

	@Column(name = "DF0AEF06A7", length = 10)
	public String getDf0aef06a7() {
		return this.df0aef06a7;
	}

	public void setDf0aef06a7(String df0aef06a7) {
		this.df0aef06a7 = df0aef06a7;
	}

	@Column(name = "DF0AEF06A8", length = 10)
	public String getDf0aef06a8() {
		return this.df0aef06a8;
	}

	public void setDf0aef06a8(String df0aef06a8) {
		this.df0aef06a8 = df0aef06a8;
	}

	@Column(name = "DF0AEF06A9", length = 10)
	public String getDf0aef06a9() {
		return this.df0aef06a9;
	}

	public void setDf0aef06a9(String df0aef06a9) {
		this.df0aef06a9 = df0aef06a9;
	}

	@Column(name = "DF0AEF06AA", length = 8)
	public String getDf0aef06aa() {
		return this.df0aef06aa;
	}

	public void setDf0aef06aa(String df0aef06aa) {
		this.df0aef06aa = df0aef06aa;
	}

	@Column(name = "DF0AEF06AB", length = 8)
	public String getDf0aef06ab() {
		return this.df0aef06ab;
	}

	public void setDf0aef06ab(String df0aef06ab) {
		this.df0aef06ab = df0aef06ab;
	}

	@Column(name = "CARD_ID", length = 32)
	public String getCardId() {
		return this.cardId;
	}

	public void setCardId(String cardId) {
		this.cardId = cardId;
	}

	@Column(name = "ATR", length = 34)
	public String getAtr() {
		return this.atr;
	}

	public void setAtr(String atr) {
		this.atr = atr;
	}

	@Column(name = "RFATR", length = 34)
	public String getRfatr() {
		return this.rfatr;
	}

	public void setRfatr(String rfatr) {
		this.rfatr = rfatr;
	}

	@Column(name = "NJ", length = 10)
	public String getNj() {
		return this.nj;
	}

	public void setNj(String nj) {
		this.nj = nj;
	}

	@Column(name = "DF02EF0852", length = 20)
	public String getDf02ef0852() {
		return this.df02ef0852;
	}

	public void setDf02ef0852(String df02ef0852) {
		this.df02ef0852 = df02ef0852;
	}

	@Column(name = "DF02EF0853", length = 64)
	public String getDf02ef0853() {
		return this.df02ef0853;
	}

	public void setDf02ef0853(String df02ef0853) {
		this.df02ef0853 = df02ef0853;
	}

	@Column(name = "DF02EF0854", length = 8)
	public String getDf02ef0854() {
		return this.df02ef0854;
	}

	public void setDf02ef0854(String df02ef0854) {
		this.df02ef0854 = df02ef0854;
	}

	@Column(name = "DF02EF0955", length = 20)
	public String getDf02ef0955() {
		return this.df02ef0955;
	}

	public void setDf02ef0955(String df02ef0955) {
		this.df02ef0955 = df02ef0955;
	}

	@Column(name = "DF02EF0956", length = 64)
	public String getDf02ef0956() {
		return this.df02ef0956;
	}

	public void setDf02ef0956(String df02ef0956) {
		this.df02ef0956 = df02ef0956;
	}

	@Column(name = "DF02EF0996", length = 8)
	public String getDf02ef0996() {
		return this.df02ef0996;
	}

	public void setDf02ef0996(String df02ef0996) {
		this.df02ef0996 = df02ef0996;
	}

	@Column(name = "DF02EF0997", length = 8)
	public String getDf02ef0997() {
		return this.df02ef0997;
	}

	public void setDf02ef0997(String df02ef0997) {
		this.df02ef0997 = df02ef0997;
	}

	@Column(name = "DF03EF0560", length = 8)
	public String getDf03ef0560() {
		return this.df03ef0560;
	}

	public void setDf03ef0560(String df03ef0560) {
		this.df03ef0560 = df03ef0560;
	}

	@Column(name = "DF04EF0581", length = 64)
	public String getDf04ef0581() {
		return this.df04ef0581;
	}

	public void setDf04ef0581(String df04ef0581) {
		this.df04ef0581 = df04ef0581;
	}

	@Column(name = "DF04EF0584", length = 64)
	public String getDf04ef0584() {
		return this.df04ef0584;
	}

	public void setDf04ef0584(String df04ef0584) {
		this.df04ef0584 = df04ef0584;
	}

	@Column(name = "DF04EF0586", length = 9)
	public String getDf04ef0586() {
		return this.df04ef0586;
	}

	public void setDf04ef0586(String df04ef0586) {
		this.df04ef0586 = df04ef0586;
	}

	@Column(name = "DF04EF0587", length = 64)
	public String getDf04ef0587() {
		return this.df04ef0587;
	}

	public void setDf04ef0587(String df04ef0587) {
		this.df04ef0587 = df04ef0587;
	}

	@Column(name = "DF04EF0589", length = 9)
	public String getDf04ef0589() {
		return this.df04ef0589;
	}

	public void setDf04ef0589(String df04ef0589) {
		this.df04ef0589 = df04ef0589;
	}

	@Column(name = "DF04EF058A", length = 20)
	public String getDf04ef058a() {
		return this.df04ef058a;
	}

	public void setDf04ef058a(String df04ef058a) {
		this.df04ef058a = df04ef058a;
	}

	@Column(name = "DF04EF0690", length = 10)
	public String getDf04ef0690() {
		return this.df04ef0690;
	}

	public void setDf04ef0690(String df04ef0690) {
		this.df04ef0690 = df04ef0690;
	}

	@Column(name = "DF04EF0692", length = 10)
	public String getDf04ef0692() {
		return this.df04ef0692;
	}

	public void setDf04ef0692(String df04ef0692) {
		this.df04ef0692 = df04ef0692;
	}

	@Column(name = "DF04EF0693", length = 10)
	public String getDf04ef0693() {
		return this.df04ef0693;
	}

	public void setDf04ef0693(String df04ef0693) {
		this.df04ef0693 = df04ef0693;
	}

	@Column(name = "DF04EF0CA0", length = 10)
	public String getDf04ef0ca0() {
		return this.df04ef0ca0;
	}

	public void setDf04ef0ca0(String df04ef0ca0) {
		this.df04ef0ca0 = df04ef0ca0;
	}

	@Column(name = "SSSEEF0507", length = 20)
	public String getSsseef0507() {
		return this.ssseef0507;
	}

	public void setSsseef0507(String ssseef0507) {
		this.ssseef0507 = ssseef0507;
	}

	@Column(name = "SSSEEF0506", length = 8)
	public String getSsseef0506() {
		return this.ssseef0506;
	}

	public void setSsseef0506(String ssseef0506) {
		this.ssseef0506 = ssseef0506;
	}

	@Column(name = "SB_ID", precision = 20, scale = 0)
	public BigDecimal getSbId() {
		return this.sbId;
	}

	public void setSbId(BigDecimal sbId) {
		this.sbId = sbId;
	}

	@Column(name = "SB_STATE", length = 1)
	public String getSbState() {
		return this.sbState;
	}

	public void setSbState(String sbState) {
		this.sbState = sbState;
	}

	@Column(name = "CUSTOMER_ID", length = 10)
	public String getCustomerId() {
		return this.customerId;
	}

	public void setCustomerId(String customerId) {
		this.customerId = customerId;
	}

}