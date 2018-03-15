package com.erp.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class MD5Util
{
	 static MessageDigest md = null;

	    static {
	        try {
	            md = MessageDigest.getInstance("MD5");
	        } catch (NoSuchAlgorithmException ne) {
	            //log.error("NoSuchAlgorithmException: md5", ne);
	        }
	    }

	    /**
	     * 对一个文件求他的md5值
	     * @param f 要求md5值的文件
	     * @return md5串
	     */
	    public static String md5(File f) {
	        FileInputStream fis = null;
	        try {
	            fis = new FileInputStream(f);
	            byte[] buffer = new byte[8192];
	            int length;
	            while ((length = fis.read(buffer)) != -1) {
	                md.update(buffer, 0, length);
	            }

	            //return new String(Hex.encodeHex(md.digest()));
	            return null;
	        } catch (FileNotFoundException e) {
	           // log.error("md5 file " + f.getAbsolutePath() + " failed:" + e.getMessage());
	            return null;
	        } catch (IOException e) {
	           // log.error("md5 file " + f.getAbsolutePath() + " failed:" + e.getMessage());
	            return null;
	        } finally {
	            try {
	                if (fis != null) {
	                    fis.close();
	                }
	            } catch (IOException ex) {
	            // log.error("文件操作失败",ex);
	            }
	        }
	    }
	    /**
		 * Encodes a string
		 * @param str String to encode
		 * @return Encoded String
		 * @throws NoSuchAlgorithmException
		 */
		public static String crypt(String str) throws NoSuchAlgorithmException {
			if (str == null || str.length() == 0) {
				throw new IllegalArgumentException("String to encript cannot be null or zero length");
			}
			MessageDigest md = MessageDigest.getInstance("MD5");
			md.update(str.getBytes());
			byte[] hash = md.digest();
			StringBuffer hexString = new StringBuffer();
			for (int i = 0; i < hash.length; i++) {
				if ((0xff & hash[i]) < 0x10) {
					hexString.append("0" + Integer.toHexString((0xFF & hash[i])));
				} else {
					hexString.append(Integer.toHexString(0xFF & hash[i]));
				}
			}
			return hexString.toString();
		}

	    /**
	     * 求一个字符串的md5值
	     * @param target 字符串
	     * @return md5 value
	     */
	    public static String md5(String target) {
	    	//DigestUtils.md5Hex(target);
	        return  null;
	    }
	    /**
	     * 可以比较两个文件是否内容相等
	     * @param args 
	     */
	    public static void main(String[] args){
	        System.out.println("");
	    }
}
