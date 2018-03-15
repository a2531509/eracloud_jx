package com.erp.util;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

/**
 * @author Administrator
 * 
 */
public class AesPlus {
	/**
	 * 默认key
	 */
	private static String defaultKey = "jfb318";

	/**
	 * 加密
	 * 
	 * @param value
	 * @param key
	 * @return
	 */
	private static String EncryptA(String sSrc, String sKey) throws Exception {
		if (sKey == null) {
			return null;
		}
		// 判断Key是否为16位
		if (sKey.length() != 16) {
			return null;
		}
		byte[] raw = sKey.getBytes("ASCII");
		// byte[] raw = sKey.getBytes("utf-8");
		SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
		Cipher cipher = Cipher.getInstance("AES");
		cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
		byte[] encrypted = cipher.doFinal(sSrc.getBytes());
		return byte2hex(encrypted).toUpperCase();

	}

	public static String Encrypt(String sSrc, String sKey) {
		String result = "";
		try {
			result = EncryptA(sSrc, sKey);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

	public static String AppEncrypt(String sSrc, String sKey) throws Exception {
		if (sKey == null) {
			return null;
		}
		// 判断Key是否为16位
		if (sKey.length() != 16) {
			return null;
		}
		byte[] raw = sKey.getBytes("utf-8");
		SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
		Cipher cipher = Cipher.getInstance("AES");
		cipher.init(Cipher.ENCRYPT_MODE, skeySpec);
		byte[] encrypted = cipher.doFinal(sSrc.getBytes());
		return byte2hex(encrypted).toUpperCase();
	}

	public static byte[] hex2byte(String strhex) {
		if (strhex == null) {
			return null;
		}
		int l = strhex.length();
		if (l % 2 == 1) {
			return null;
		}
		byte[] b = new byte[l / 2];
		for (int i = 0; i != l / 2; i++) {
			b[i] = (byte) Integer.parseInt(strhex.substring(i * 2, i * 2 + 2), 16);
		}
		return b;
	}

	public static String byte2hex(byte[] b) {
		String hs = "";
		String stmp = "";
		for (int n = 0; n < b.length; n++) {
			stmp = (java.lang.Integer.toHexString(b[n] & 0XFF));
			if (stmp.length() == 1) {
				hs = hs + "0" + stmp;
			} else {
				hs = hs + stmp;
			}
		}
		return hs.toUpperCase();
	}

	public static String Decrypt(String sSrc, String sKey) {
		try {
			// 判断Key是否正确
			if (sKey == null) {
				return null;
			}
			// 判断Key是否为16位
			if (sKey.length() != 16) {
				return null;
			}
			byte[] raw = sKey.getBytes("utf-8");
			SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
			Cipher cipher = Cipher.getInstance("AES");
			cipher.init(Cipher.DECRYPT_MODE, skeySpec);
			byte[] encrypted1 = hex2byte(sSrc);
			try {
				byte[] original = cipher.doFinal(encrypted1);
				String originalString = new String(original);
				return originalString;
			} catch (Exception e) {
				System.out.println(e.toString());
				return null;
			}
		} catch (Exception ex) {
			System.out.println(ex.toString());
			return null;
		}
	}

	public static String AppDecrypt(String sSrc, String sKey) {
		try {
			// 判断Key是否正确
			if (sKey == null) {
				return null;
			}
			// 判断Key是否为16位
			if (sKey.length() != 16) {
				return null;
			}
			byte[] raw = sKey.getBytes("ASCII");
			SecretKeySpec skeySpec = new SecretKeySpec(raw, "AES");
			Cipher cipher = Cipher.getInstance("AES");
			cipher.init(Cipher.DECRYPT_MODE, skeySpec);
			byte[] encrypted1 = hex2byte(sSrc);
			try {
				byte[] original = cipher.doFinal(encrypted1);
				String originalString = new String(original);
				return originalString;
			} catch (Exception e) {
				System.out.println(e.toString());
				return null;
			}
		} catch (Exception ex) {
			System.out.println(ex.toString());
			return null;
		}
	}

	public static void main(String[] args) {
		// try {
		// long l1 = System.currentTimeMillis();
		// //for(int i=0; i<100000; i++){
		// String kaka = AesPlus.Encrypt("123456", "1234567890123456");
		// System.out.println(kaka);
		// kaka = AesPlus.Decrypt(kaka,"1234567890123456");
		// System.out.println(kaka);
		//
		//
		// //}
		// long l2 = System.currentTimeMillis();
		//
		// System.out.println(l2-l1);
		// } catch (Exception e) {
		// // TODO Auto-generated catch block
		// e.printStackTrace();
		// }

		System.out.println(AesPlus.Encrypt("123456787777777777777777777777777", "1234567812345678"));

		System.out.println(AesPlus.Decrypt("99D4A6D11981FB100AAD36A1DC31B7D4", "1234567812345678"));
		// String kaka =
		// AesPlus.Decrypt("2244202976B5CEC3B73045AEFD068AF455AF08CACE74C8AC9121BC3B8304368007AFD775CED7F81DF69C586260BA80BC77219D29A17B7C1FE4B4632C32995331C98D10E4357AD8122EB8A92A367984A2C906327FD2DD482CE63AFB805AC4686306A877C82E0A20DDB6072CC93A4B38C5020FF3B4059E551D52318975C360CB590A866B923B33CEF6A6DCC813B2C537C8CB293DD300B6B1D717F8B3D9BBE31C5167018FF8ABEC54A8734ECB8091153090F1756D1B959267C40B88A234BFC348F08CE70B12F0F2A433AD7E03840AC59BA29F90C07AEB4874CD957D57434BFFE9BA2C017130345EF4904DFC6F10006689CD20AF06D2AC3BF5DA3E269B62835AADF57EB3B69386C45E6487572963B2C07859BD7DBE68E74003E43895220C96F1F56FCB5462F7AC2F5A6298EB6823324443BA659AAD7A8A7F23A30E7E350BF6D3CA2747CC1571A63619031C544D5DE7A9FC045AE6D9E39449B741CD4A1C11751322E272502A3A2A8F71F06908B18B00196FEC33573B0254DD5554BE48E7908B7EEEC86CC14E1A694A2754A1EC142CE192FF502A4AD70BA0B8B6FFA3619C33B8777A44D5361D1AD09CAAD7B9D1E73C8D6A8A79D22CA1DBD1EB7431B6F8846927A26166CBEFA40ECCA4031E17F714918CE2EFA4A4F74053FD104B8505F30BC07CB14A95",
		// "1234567890123456");
		// try {
		//
		// System.out.println(URLDecoder.decode(kaka,"unicode"));
		// System.out.println(new String(kaka.getBytes("utf8"), "gbk"));
		// } catch (UnsupportedEncodingException e) {
		// // TODO Auto-generated catch block
		// e.printStackTrace();
		// }

		// DA36CDCEC8A9EE00A9EB703E478DED11
	}
}
