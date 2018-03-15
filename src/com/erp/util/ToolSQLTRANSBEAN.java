package com.erp.util;

import java.lang.reflect.Method;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.math.NumberUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class ToolSQLTRANSBEAN {
	public static Log log = LogFactory.getLog(Tools.class);
	/**
	 * @author yangn
	 * @email yangn@insigmacc.com
	 * <p>工具类,将sql语句查询出的结果集,转换成T对象列表.<p>
	 * @param clazz     list元素类型
	 * @param list      sql查询出的结果集
	 * @param attr      对象属性字符串
	 * @return          对象列表
	 * @throws Exception
	 */
	public static <T> List<T> toListBySqlResultSet(Class<T> clazz,List list,String attr) throws Exception{
		List<T> reList = new ArrayList<T>();
		if(clazz == null || list == null || StringUtils.isBlank(attr)){
			throw new Exception("all incoming parameters can not be null");
		}
		if(list.size() <= 0){
			return null;
		}
		String[] attrs = attr.split(",");
		for (int i = 0; i < list.size(); i++) {
			Object[] row = (Object[])list.get(i);
			T o = clazz.newInstance();
			for (int j = 0; j < attrs.length && j < row.length; j++){
				if(StringUtils.isBlank(attrs[j])){
					log.error("对象属性列表传入的第" + (j + 1) + "个参数为空，不能进行赋值!");
					continue;
				}
				Class<?> fieldType = getFieldTypeClass(clazz,attrs[j]);
				if(fieldType == null){
					log.error(clazz.getName() + "中不存在字短域" + attrs[j] + "不能进行赋值!");
					continue;
				}
				String setter = getSetter(attrs[j].replaceAll(" ",""));//构建setter方法
				Method method = getSetterMethod(clazz,setter,fieldType);
				if(method == null){
					log.error("未找到属性" + attrs[j] + "对应的setter方法,不能进行赋值!");
					continue;
				}
				if(row[j] == null){
					log.info("结果集中第" + i + "行,第" + j + "列值为空,不能赋值!");
					continue;
				}
				//if BigDecimal or String
				if((row[j] instanceof BigDecimal) || (row[j] instanceof String)){
					if(fieldType.getSimpleName().equals("String")){
						method.invoke(o,row[j].toString());
					}else if(!NumberUtils.isDigits(row[j].toString())){
						throw new Exception("The input parameters, the attributes of the object corresponding to the result set is not digital array.attribute:" + attrs[j] + " and value:" +  row[j].toString());
					}else if(fieldType.getSimpleName().equals("int")){
						method.invoke(o,NumberUtils.toInt(row[j].toString()));
					}else if(fieldType.getSimpleName().equals("Integer")){
						method.invoke(o,NumberUtils.createInteger(row[j].toString()));
					}else if(fieldType.getSimpleName().equals("long")){
						method.invoke(o,NumberUtils.toLong(row[j].toString()));
					}else if(fieldType.getSimpleName().equals("Long")){
						method.invoke(o,NumberUtils.createLong(row[j].toString()));
					}else if(fieldType.getSimpleName().equals("double")){
						method.invoke(o,NumberUtils.toDouble(row[j].toString()));
					}else if(fieldType.getSimpleName().equals("Double")){
						method.invoke(o,NumberUtils.createDouble(row[j].toString()));
					}else if(fieldType.getSimpleName().equals("float")){
						method.invoke(o,NumberUtils.toFloat(row[j].toString()));
					}else if(fieldType.getSimpleName().equals("Float")){
						method.invoke(o,NumberUtils.createFloat(row[j].toString()));
					}else if(fieldType.getSimpleName().equals("Byte") || fieldType.getSimpleName().equals("byte") ){
						method.invoke(o,NumberUtils.toByte(row[j].toString()));
					}else if(fieldType.getSimpleName().equals("Short") || fieldType.getSimpleName().equals("short") ){
						method.invoke(o,NumberUtils.toShort(row[j].toString()));
					}else if(fieldType.getSimpleName().equals("BigInteger")){
						method.invoke(o,NumberUtils.createBigInteger(row[j].toString()));
					}else if(fieldType.getSimpleName().equals("BigDecimal")){
						method.invoke(o,NumberUtils.createBigDecimal(row[j].toString()));
					}else if(fieldType.getSimpleName().equals("Number")){
						method.invoke(o,NumberUtils.createNumber(row[j].toString()));
					}else{
						throw new Exception("BigDecimal或String转换为未处理的java数据类型" + fieldType.getSimpleName());
					}
				}else if(row[j] instanceof java.sql.Date){
					if(fieldType.getName().equals("java.sql.Date")){
						method.invoke(o,(java.sql.Date)(row[j]));
					}else if(fieldType.getName().equals("java.util.Date")){
						method.invoke(o,new java.util.Date(((java.sql.Date)(row[j])).getTime()));
					}else{
						throw new Exception("日期类型转换出现错误.row:" + i + "column:" + j + " attribute:" + attrs[j]);
					}
				}else if(row[j] instanceof java.util.Date){
					if(fieldType.getName().equals("java.sql.Date")){
						method.invoke(o,new java.sql.Date(((java.util.Date)(row[j])).getTime()));
					}else if(fieldType.getName().equals("java.util.Date")){
						method.invoke(o,(java.sql.Date)(row[j]));
					}else{
						throw new Exception("日期类型转换出现错误.row:" + i + "column:" + j + " attribute:" + attrs[j]);
					}
				}else if(row[j] instanceof java.sql.Blob){
					if(fieldType.getName().equals("java.sql.Blob")){
						method.invoke(o,(java.sql.Blob)(row[j]));
					}else if(fieldType.getSimpleName().equals("byte[]")){
						method.invoke(o,((java.sql.Blob)(row[j])).getBytes(1,new BigDecimal(((java.sql.Blob)(row[j])).length()).intValue()));
					}else if(fieldType.getSimpleName().equals("InputStream")){
						method.invoke(o,((java.sql.Blob)(row[j])).getBinaryStream());
					}else{
						throw new Exception("转换出现错误.row:" + i + "column:" + j + " attribute:" + attrs[j]);
					}
				}else if(row[j] instanceof byte[]){
					if(fieldType.getName().equals("byte[]")){
						method.invoke(o,(byte[])row[j]);
					}else{
						//Blob.
					}
				}else{
					log.error("未处理的数据库返回数据类型" + row[j].getClass().getName());
				}
			}
			reList.add(o);
		}
		return reList;
	}
	/**
	 * @author yangn
	 * @email yangn@insigmacc.com
	 * <p>工具类,将sql语句查询出的结果集,转换成T对象列表.<p>
	 * @param clazz     list元素类型
	 * @param list      sql查询出的结果集
	 * @param attr      对象属性字符串
	 * @return          对象列表
	 * @throws Exception
	 */
	public static <T> List<T> toListBySqlResultSet_New(Class<T> clazz,List<Object[]> list,String attr) throws Exception{
		List<T> reList = new ArrayList<T>();
		if(clazz == null || list == null || StringUtils.isBlank(attr)){
			throw new Exception("all incoming parameters can not be null");
		}
		if(list.size() <= 0){
			return null;
		}
		String[] attrs = attr.split(",");
		for (int i = 0; i < list.size(); i++) {
			Object[] row = list.get(i);
			T o = clazz.newInstance();
			for (int j = 0; j < attrs.length && j < row.length; j++){
				if(StringUtils.isBlank(attrs[j])){
					log.error("对象属性列表传入的第" + (j + 1) + "个参数为空，不能进行赋值!");
					continue;
				}
				Class<?> fieldType = getFieldTypeClass(clazz,attrs[j]);
				if(fieldType == null){
					log.error(clazz.getName() + "中不存在字短域" + attrs[j] + "不能进行赋值!");
					continue;
				}
				String setter = getSetter(attrs[j].replaceAll(" ",""));//构建setter方法
				Method method = getSetterMethod(clazz,setter,fieldType);
				if(method == null){
					log.error("未找到属性" + attrs[j] + "对应的setter方法,不能进行赋值!");
					continue;
				}
				if(row[j] == null){
					log.info("结果集中第" + i + "行,第" + j + "列值为空,不能赋值!");
					continue;
				}
				//=================================================================================================
				if(fieldType.getSimpleName().equals("String")){
					method.invoke(o,row[j].toString());
				}else if(fieldType.getName().equals("java.sql.Date")){
					method.invoke(o,(java.sql.Date)(row[j]));
				}else if(fieldType.getName().equals("java.util.Date")){
					method.invoke(o,new java.util.Date(((java.sql.Date)(row[j])).getTime()));
				}else if(fieldType.getName().equals("java.sql.Date")){
					method.invoke(o,new java.sql.Date(((java.util.Date)(row[j])).getTime()));
				}else if(fieldType.getName().equals("java.util.Date")){
					method.invoke(o,(java.sql.Date)(row[j]));
				}else if(fieldType.getName().equals("java.sql.Blob")){
					method.invoke(o,(java.sql.Blob)(row[j]));
				}else if(fieldType.getSimpleName().equals("byte[]")){
					method.invoke(o,((java.sql.Blob)(row[j])).getBytes(1,new BigDecimal(((java.sql.Blob)(row[j])).length()).intValue()));
				}else if(fieldType.getSimpleName().equals("InputStream")){
					method.invoke(o,((java.sql.Blob)(row[j])).getBinaryStream());
				}else if(fieldType.getName().equals("byte[]")){
					method.invoke(o,(byte[])row[j]);
				}else if(fieldType.getSimpleName().equals("int")){
					method.invoke(o,NumberUtils.toInt(row[j].toString()));
				}else if(fieldType.getSimpleName().equals("Integer")){
					method.invoke(o,NumberUtils.createInteger(row[j].toString()));
				}else if(fieldType.getSimpleName().equals("long")){
					method.invoke(o,NumberUtils.toLong(row[j].toString()));
				}else if(fieldType.getSimpleName().equals("Long")){
					method.invoke(o,NumberUtils.createLong(row[j].toString()));
				}else if(fieldType.getSimpleName().equals("double")){
					method.invoke(o,NumberUtils.toDouble(row[j].toString()));
				}else if(fieldType.getSimpleName().equals("Double")){
					method.invoke(o,NumberUtils.createDouble(row[j].toString()));
				}else if(fieldType.getSimpleName().equals("float")){
					method.invoke(o,NumberUtils.toFloat(row[j].toString()));
				}else if(fieldType.getSimpleName().equals("Float")){
					method.invoke(o,NumberUtils.createFloat(row[j].toString()));
				}else if(fieldType.getSimpleName().equals("Byte") || fieldType.getSimpleName().equals("byte") ){
					method.invoke(o,NumberUtils.toByte(row[j].toString()));
				}else if(fieldType.getSimpleName().equals("Short") || fieldType.getSimpleName().equals("short") ){
					method.invoke(o,NumberUtils.toShort(row[j].toString()));
				}else if(fieldType.getSimpleName().equals("BigInteger")){
					method.invoke(o,NumberUtils.createBigInteger(row[j].toString()));
				}else if(fieldType.getSimpleName().equals("BigDecimal")){
					method.invoke(o,NumberUtils.createBigDecimal(row[j].toString()));
				}else if(fieldType.getSimpleName().equals("Number") || fieldType.getSimpleName().equals("number")){
					method.invoke(o,NumberUtils.createNumber(row[j].toString()));
				}else{
					//Blob.
				}
			}
			reList.add(o);
		}
		return reList;
	}
	//构建getter方法
	public static String getGetter(String string){
		return "get" + String.valueOf(Character.toUpperCase(string.charAt(0))) + string.substring(1);
	}
	//构建setter方法
	public static String getSetter(String string){
		return "set" + String.valueOf(Character.toUpperCase(string.charAt(0))) + string.substring(1);
	}
	//获取Class中某字段的setter方法
	public static Method getSetterMethod(Class<?> clazz,String attr,Class<?> type){
		try {
			String methodName = getSetter(attr);
			return clazz.getDeclaredMethod(methodName,type);
		} catch (Exception e) {
			log.error(e);
		}
		return null;
	}
	//获取Class中某字段的setter方法
	public static Method getGetterMethod(Class<?> clazz,String attr){
		try {
			String methodName = getGetter(attr);
			return clazz.getMethod(methodName);
		} catch (Exception e) {
			//log.error(e);
		}
		return null;
	}
	//判断bean中指定字段域的类型
	public static Class<?> getFieldTypeClass(Class<?> clazz,String field){
		try {
			return clazz.getDeclaredField(field).getType();
		} catch (Exception e) {
			//log.error(e);
		}
		return null;
	}
	
}
