package com.erp.util;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.ParseException;
import java.util.Locale;

/**
 * Number工具类
 * @author yangn
 * @date 2015-07-05 17:50:00
 * @version 1.0
 */
public class NumberUtil {
	private NumberUtil(){
		/*构造函数私有化,不能实例化*/
	}
	/****************************************钱币形式格式化****************************
	/**
	* 格式化数字,显示钱币的形式###,###,###.00 保留两位小数.
	* @param value 将要被格式化的int值.
	* @return 格式化后的字符串
	*/
	public static String format(int value){
		DecimalFormat format = new DecimalFormat("###,###,##0.00");
		String result = format.format(value);
		return result;
		
	}
	/**
	* 格式化数字,显示钱币的形式###,###,###.00 保留两位小数.
	* @param string 将要被格式化的String值.
	* @return 格式化后的字符串
	*/
	public static String format(String string){
		DecimalFormat format = new DecimalFormat("###,###,##0.00");
		Number number = 0;
		try {
			number = format.parse(string);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		Double value = number.doubleValue();
		String result = format.format(value);
		return result;
	}
	/**
	* 格式化数字,显示钱币的形式###,###,###.00 保留两位小数.
	* @param value 将要被格式化的double值.
	* @return 格式化后的字符串
	*/
	public static String format(double value){
		DecimalFormat format = new DecimalFormat("###,###,##0.00");
		String result = format.format(value);
		return result;
	}
	/**
	* 以人民币的形式格式化数字,显示钱币的形式￥###,###,###.00 保留两位小数.
	* @param value 将要被格式化的double值.
	* @return 格式化后的字符串
	*/
	public static String RMB(double value){
		NumberFormat format = DecimalFormat.getCurrencyInstance(Locale.SIMPLIFIED_CHINESE);
		String result = format.format(value);
		return result;
	}
	/**
	* 以美元的形式格式化数字,显示钱币的形式$###,###,###.00 保留两位小数.
	* @param value 将要被格式化的double值.
	* @return 格式化后的字符串
	*/
	public static String US(double value){
		NumberFormat format = DecimalFormat.getCurrencyInstance(Locale.US);
		String result = format.format(value);
		return result;
	}
	/**
	* 设置给定value参数的精度,保留num位小数
	* @param value String 参数值value
	* @param num int 小数的位数
	* @return 格式化后的数字
	*/
	public static String scale(String value,int num){
		BigDecimal big = new BigDecimal(value);
		big = big.setScale(num,BigDecimal.ROUND_HALF_UP);
		String result = big.toString();
		return result;
	}
	/**
	* 设置给定value参数的精度,保留num位小数
	* @param value double 参数值value
	* @param num int 小数的位数
	* @return 格式化后的数字
	*/
	public static String scale(double value,int num){
		BigDecimal big = new BigDecimal(value);
		big = big.setScale(num,BigDecimal.ROUND_HALF_UP);
		String result = big.toString();
		return result;
	}
	/****************************************加法运算*************************************
	/**
	* String 字符串形式的数字进行'加'运算
	* @param str1  被加数
	* @param str2  加数
	* @return 计算加运算后的字符串形式的结果.
	*/
	public static String add(String str1,String str2){
		BigDecimal big1 = new BigDecimal(str1);
		BigDecimal big2 = new BigDecimal(str2);
		big1 = big1.add(big2);
		String result = big1.setScale(6,BigDecimal.ROUND_HALF_UP).toString();
		return result;
	}
	/**
	* Double形式的数字进行'加'运算
	* @param str1  被加数
	* @param str2  加数
	* @return 计算加运算后的double形式的结果.
	*/
	public static double add(double str1,double str2){
		String string1 = String.valueOf(str1);
		String string2 = String.valueOf(str2);
		BigDecimal big1 = new BigDecimal(string1);
		BigDecimal big2 = new BigDecimal(string2);
		big1 = big1.add(big2);
		double result = big1.setScale(6,BigDecimal.ROUND_HALF_UP).doubleValue();
		return result;
	}
	/**
	* Integer形式的数字进行'加'运算
	* @param str1  被加数
	* @param str2  加数
	* @return 计算加运算后的int形式的结果.
	*/
	public static int add(int str1,int str2){
		String string1 = String.valueOf(str1);
		String string2 = String.valueOf(str2);
		BigDecimal big1 = new BigDecimal(string1);
		BigDecimal big2 = new BigDecimal(string2);
		big1 = big1.add(big2);
		int result = big1.setScale(6,BigDecimal.ROUND_HALF_UP).intValue();
		return result;
	}
	/*******************************************减法运算*********************************************
	/**
	* double形式的数字进行'减'运算
	* @param str1  被加数
	* @param str2  加数
	* @return 计算加运算后的字符串形式的结果.
	*/
	public static double subtract(double str1,double str2){
		String string1 = String.valueOf(str1);
		String string2 = String.valueOf(str2);
		BigDecimal big1 = new BigDecimal(string1);
		BigDecimal big2 = new BigDecimal(string2);
		big1 = big1.subtract(big2);
		double result = big1.setScale(6,BigDecimal.ROUND_HALF_UP).doubleValue();
		return result;
	}
	/**
	* 字符串形式的数字进行'减'运算
	* @param str1  被加数
	* @param str2  加数
	* @return 计算加运算后的字符串形式的结果.
	*/
	public static String subtract(String str1,String str2){
		BigDecimal big1 = new BigDecimal(str1);
		BigDecimal big2 = new BigDecimal(str2);
		big1 = big1.subtract(big2);
		String result = big1.setScale(6,BigDecimal.ROUND_HALF_UP).toString();
		return result;
	}
	/***********************************乘法运算************************************************
	/**
	* 字符串形式的数字进行'乘'运算
	* @param str1  被加数
	* @param str2  加数
	* @return 计算加运算后的字符串形式的结果.
	*/
	public static String multiply(String str1,String str2){
		BigDecimal big1 = new BigDecimal(str1);
		BigDecimal big2 = new BigDecimal(str2);
		big1 = big1.multiply(big2);
		String result = big1.setScale(6,BigDecimal.ROUND_HALF_UP).toString();
		return result;
	}
	/**
	* 字符串形式的数字进行'乘'运算
	* @param str1  被加数
	* @param str2  加数
	* @return 计算加运算后的字符串形式的结果.
	*/
	public static double multiply(double str1,double str2){
		String string1 = String.valueOf(str1);
		String string2 = String.valueOf(str2);
		BigDecimal big1 = new BigDecimal(string1);
		BigDecimal big2 = new BigDecimal(string2);
		big1 = big1.multiply(big2);
		double result = big1.setScale(6,BigDecimal.ROUND_HALF_UP).doubleValue();
		return result;
	}
	/******************************除法运算***********************************************************
	/**
	* 字符串形式的数字进行'除'运算
	* @param str1  被加数
	* @param str2  加数
	* @return 计算加运算后的字符串形式的结果.
	*/
	public static String divide(String str1,String str2){
		BigDecimal big1 = new BigDecimal(str1);
		BigDecimal big2 = new BigDecimal(str2);
		big1 = big1.divide(big2,6,BigDecimal.ROUND_HALF_UP);
		String result = big1.toString();
		return result;
	}
	/**
	* 字符串形式的数字进行'除'运算
	* @param str1  被除数
	* @param str2  除数
	* @return 计算除运算后的字符串形式的结果.
	*/
	public static double divide(double str1,double str2){
		String string1,string2;
		string1 = String.valueOf(str1);
		string2 = String.valueOf(str2);
		BigDecimal big1 = new BigDecimal(string1);
		BigDecimal big2 = new BigDecimal(string2);
		big1 = big1.divide(big2,6,BigDecimal.ROUND_HALF_UP);
		double result = big1.doubleValue();
		return result;
	}
	/******************************增大或缩小N倍***********************************************************
	/**
	* 将数字字符串value扩大,缩小num倍
	* @param value 将被扩大或缩小的字符串数字
	* @param num 扩大或缩小的倍数
	* @return 扩大或缩小后的结果
	*/
	public static String moveLeft(String value,int num){
		BigDecimal big = new BigDecimal(value);
		big = big.movePointLeft(num);
		String result = big.toString();
		return result;
	}
	/**
	* 将int型数字value扩大,缩小num倍
	* @param value 将被扩大或缩小的字符串数字
	* @param num 扩大或缩小的倍数
	* @return 扩大或缩小后的结果
	*/
	public static String moveLeft(int value,int num){
		String string = String.valueOf(value);
		BigDecimal big = new BigDecimal(string);
		big = big.movePointLeft(num);
		String result = big.toString();
		return result;
	}
	/**
	* 将double型数字value扩大,缩小num倍
	* @param value 将被扩大或缩小的字符串数字
	* @param num 扩大或缩小的倍数
	* @return 扩大或缩小后的结果
	*/
	public static String moveLeft(double value,int num){
		String string = String.valueOf(value);
		BigDecimal big = new BigDecimal(string);
		big = big.movePointLeft(num);
		String result = big.toString();
		return result;
	}
	/**
	* 将long型数字value扩大,缩小num倍
	* @param value 将被扩大或缩小的字符串数字
	* @param num 扩大或缩小的倍数
	* @return 扩大或缩小后的结果
	*/
	public static String moveLeft(long value,int num){
		String string = String.valueOf(value);
		BigDecimal big = new BigDecimal(string);
		big = big.movePointLeft(num);
		String result = big.toString();
		return result;
	}
	public static void main(String[] args) {
		System.out.println(add(1,8));
	}
}
