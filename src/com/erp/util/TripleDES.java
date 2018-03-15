package com.erp.util;


	import java.security.Key;
	import java.security.SecureRandom;
	import javax.crypto.Cipher;
	import javax.crypto.KeyGenerator;
	import javax.crypto.spec.SecretKeySpec;

import com.erp.exception.CommonException;

	import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;

	/**
	 * @author ChairmanZheng
	 * @email:zhengzhuxi@qq.com
	 * @Describe DES加密与解密 以及 3DES加密与解密
	 * @version 1.0
	 */
	public class TripleDES {
		private static Key key;

		/**
		 * 根据参数生成KEY
		 * @param strKey
		 */
		public static void getKey(String strKey) {
			try {
				KeyGenerator _generator = KeyGenerator.getInstance("DES");
				_generator.init(new SecureRandom(strKey.getBytes()));
				key = _generator.generateKey();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		
		/**
		 * 加密String明文输入,String密文输出
		 * @param strMing
		 * @return
		 */
		public static String encrypt_DES(String strMing) {
			return encrypt_DES(strMing, "");
		}
		/**
		 * 加密String明文输入,String密文输出
		 * @param strMing
		 * @return
		 */
		public static String encrypt_DES(String strMing,String keystr) {
			getKey(keystr);
			String result = "";
			BASE64Encoder base64en = new BASE64Encoder();
			try {
				Cipher cipher = Cipher.getInstance("DES");
				cipher.init(Cipher.ENCRYPT_MODE,key);
				byte[] byteMi = cipher.doFinal(strMing.getBytes("UTF8"));
				result = base64en.encode(byteMi);
			} catch (Exception e) {
				throw new CommonException("加解密字符串失败！");
			}
			return result;
		}

		/**
		 * 解密 以String密文输入,String明文输出
		 * @param strMi
		 * @return
		 */
		public static String decrypt_DES(String strMi) {
			return decrypt_DES(strMi==null?"":strMi, "");
		}
		/**
		 * 解密 以String密文输入,String明文输出
		 * @param strMi
		 * @return
		 */
		public static String decrypt_DES(String strMi,String keystr) {
			getKey(keystr);
			BASE64Decoder base64De = new BASE64Decoder();
			byte[] byteMing = null;
			String result = "";
			try {
				Cipher cipher = Cipher.getInstance("DES");
				cipher.init(Cipher.DECRYPT_MODE, key);
				byteMing = cipher.doFinal(base64De.decodeBuffer(strMi==null?"":strMi));
				result = new String(byteMing, "UTF8");
			} catch (Exception e) {
				throw new CommonException("加解密字符串失败！");
			}
			return result;
		}
		
		/**
		 * 3DES加解密key的产生方法
		 */
		public static SecretKeySpec getSecretKeySpec(String key)throws Exception{
			if(key==null||key.length()!=24)
				throw new Exception("输入key字符长度必须为24位");
			SecretKeySpec keySpec = new SecretKeySpec(key.getBytes(), "DESede");
			return  keySpec;
		}
		
		/**
		 * 3DES加密算法
		 * @param key (需要24位，作为产生Key的字符)
		 * @param value （需要加密的字符）
		 * @return
		 * @throws Exception 
		 */
		public static String encrypt_3DES(String value,String key) throws Exception {
			if(key==null||key.length()!=24)
				throw new Exception("输入key字符长度必须为24位");
			String result="";
			try{
		        Cipher cipher = Cipher.getInstance("DESede");
		        cipher.init(Cipher.ENCRYPT_MODE, getSecretKeySpec(key));
		        byte[] encryptedByte = cipher.doFinal(value.getBytes("GBK"));
		        result= Base64.encodeBytes(encryptedByte);
			}catch(Exception e){
				throw new Exception("3DES加密算法发生错误："+e.getMessage());
			}
	        return result;
		}
		/**
		 * 3DES解密算法
		 * @param key (需要24位，作为产生Key的字符)
		 * @param value （需要解密的字符）
		 * @return
		 * @throws Exception 
		 */
		public static String decrypt_3DES(String value,String key) throws Exception {
			if(key==null||key.length()!=24)
				throw new Exception("输入key字符长度必须为24位");
			String result="";
			try{
		        Cipher cipher = Cipher.getInstance("DESede");
		        cipher.init(Cipher.DECRYPT_MODE, getSecretKeySpec(key));
		        byte[] decodedByte = Base64.decode(value);
	            byte[] decryptedByte = cipher.doFinal(decodedByte);            
	            result= new String(decryptedByte);
			}catch(Exception e){
				throw new Exception("3DES解密算法发生错误："+e.getMessage());
			}
	        return result;
		}
		
	    public static void main(String[] value) {
	        try {
	        	//目前当前普遍的3DES使用示例
	        	String key="hehe";
	        	key=MD5Util.crypt(key).substring(0,24);
	        	String ss=TripleDES.encrypt_3DES("你好吗",key);
	            System.out.println("3DES加密结果："+ss);
	            
	            ss=TripleDES.decrypt_3DES(ss,key);       
	            System.out.println("3DES解密结果："+ss);
	            
	            System.out.println("----------");
	            
	            //下面是辽宁电信使用des算法调用示例
	            ss=TripleDES.encrypt_DES("你好吗",key);
	            System.out.println("DES加密结果："+ss);
	            
	            ss=TripleDES.decrypt_DES(ss,key);       
	            System.out.println("DES解密结果："+ss);
	        } catch(Exception e) {
	        	System.out.println("发生错误："+e.getMessage());
	        }
	    }
}
