/**
 * 
 */
package com.erp.util;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;

import com.erp.exception.CommonException;
/**
 * @author Administrator
 *
 */
public class ObjectCopyTools {
	public static Object CopyObjectToOtherObject(Object object1, Object object2) {
		try {
			Field fields2[] = object2.getClass().getDeclaredFields();
			Field fields1[] = object1.getClass().getDeclaredFields();
			for (int i = 0; i < fields2.length; i++) {
				Field field2 = fields2[i];
				String fieldName2 = field2.getName();
				String setMethodName = (new StringBuilder("set")).append(
						fieldName2.substring(0, 1).toUpperCase()).append(
						fieldName2.substring(1)).toString();
				Method setMethod = object2.getClass().getMethod(setMethodName,
						new Class[] { field2.getType() });
				try {
					for (int j = 0; j < fields1.length; j++) {
						Field field1 = fields1[j];
						if (!StringUtils.processNull(field1.getName()).equals(
								StringUtils.processNull(fieldName2)))
							continue;
						String getMethodName = (new StringBuilder("get"))
								.append(field1.getName().substring(0, 1).toUpperCase()).append(field1.getName().substring(1)).toString();
						Method getMethod = object1.getClass().getMethod(
								getMethodName, new Class[0]);
						Object returnvalue = getMethod.invoke(object1,
								new Object[0]);
						if (returnvalue == null || returnvalue.equals(""))
							continue;
						String getvalue = returnvalue.toString();
						if (field2.getType().getName().equals("java.util.Date")) {
							java.util.Date value = DateUtil
									.formatSqlDate(getvalue.toString());
							setMethod.invoke(object2, new Object[] { value });
						} else if (field2.getType().getName().equals(
								"java.util.Date")) {
							java.util.Date value = DateUtil
									.formatDate(getvalue);
							setMethod.invoke(object2, new Object[] { value });
						} else if (field2.getType().getName().equals(
								"java.lang.Integer")) {
							Integer value = new Integer(getvalue);
							setMethod.invoke(object2, new Object[] { value });
						} else if (field2.getType().getName().equals(
								"java.lang.Float")) {
							Float value = new Float(getvalue);
							setMethod.invoke(object2, new Object[] { value });
						} else if (field2.getType().getName().equals(
								"java.lang.Boolean")) {
							Boolean value = Boolean.valueOf(getvalue);
							setMethod.invoke(object2, new Object[] { value });
						} else if (field2.getType().getName().equals(
								"java.lang.Long")) {
							Long value = Long.valueOf(getvalue);
							setMethod.invoke(object2, new Object[] { value });
						} else if (field2.getType().getName().equals(
								"java.lang.Short")) {
							Short value = Short.valueOf(getvalue);
							setMethod.invoke(object2, new Object[] { value });
						} else if (field2.getType().getName().equals(
								"java.lang.Byte")) {
							Byte value = Byte.valueOf(getvalue);
							setMethod.invoke(object2, new Object[] { value });
						} else if (field2.getType().getName().equals(
								"java.lang.Double")) {
							Double value = Double.valueOf(getvalue);
							setMethod.invoke(object2, new Object[] { value });
						} else {
							setMethod
									.invoke(object2, new Object[] { getvalue });
						}
						break;
					}

				} catch (Exception ee) {
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return object2;
	}

	public static String getValueInHashMap(String str, HashMap hash) {
		String wantvalue = "";
		try {
			Iterator ite = hash.keySet().iterator();
			while (ite.hasNext()) {
				String key = (String) (String) ite.next();
				Object geto = hash.get(key);
				if (geto instanceof Vector) {
					Vector vt = (Vector) geto;
					Object oo[] = vt.toArray();
					for (int vihm = 0; vihm < oo.length; vihm++) {
						HashMap hs = (HashMap) oo[vihm];
						wantvalue = getValueInHashMap(str, hs);
						if (wantvalue != null && !wantvalue.equals(""))
							break;
					}

					continue;
				}
				if (!StringUtils.processNull(str).equals(key))
					continue;
				wantvalue = (String) geto;
				break;
			}
		} catch (Exception e) {
		}
		return wantvalue;
	}

	public static Object hashMapConvertToObject(Object object, HashMap hash)
			throws CommonException {
		Object newObject = null;
		try {
			newObject = object.getClass().newInstance();
			Field fields[] = object.getClass().getDeclaredFields();
			for (int i = 0; i < fields.length; i++)
				try {
					Field field = fields[i];
					String fieldName = field.getName();
					String setMethodName = (new StringBuilder("set")).append(
							fieldName.substring(0, 1).toUpperCase()).append(
							fieldName.substring(1)).toString();
					Method setMethod = object.getClass().getMethod(
							setMethodName, new Class[] { field.getType() });
					String getvalue = getValueInHashMap(fieldName, hash);
					if (getvalue != null && !getvalue.equals(""))
						if (field.getType().getName().equals("java.sql.Date")) {
							Date value = DateUtil.formatSqlDate(getvalue);
							setMethod.invoke(newObject, new Object[] { value });
						} else if (field.getType().getName().equals(
								"java.util.Date")) {
							java.util.Date value = DateUtil
									.formatDate(getvalue);
							setMethod.invoke(newObject, new Object[] { value });
						} else if (field.getType().getName().equals(
								"java.lang.Integer")) {
							Integer value = new Integer(getvalue);
							setMethod.invoke(newObject, new Object[] { value });
						} else if (field.getType().getName().equals(
								"java.lang.Float")) {
							Float value = new Float(getvalue);
							setMethod.invoke(newObject, new Object[] { value });
						} else if (field.getType().getName().equals(
								"java.lang.Boolean")) {
							Boolean value = Boolean.valueOf(getvalue);
							setMethod.invoke(newObject, new Object[] { value });
						} else if (field.getType().getName().equals(
								"java.lang.Long")) {
							Long value = Long.valueOf(getvalue);
							setMethod.invoke(newObject, new Object[] { value });
						} else if (field.getType().getName().equals(
								"java.lang.Short")) {
							Short value = Short.valueOf(getvalue);
							setMethod.invoke(newObject, new Object[] { value });
						} else if (field.getType().getName().equals(
								"java.lang.Byte")) {
							Byte value = Byte.valueOf(getvalue);
							setMethod.invoke(newObject, new Object[] { value });
						} else if (field.getType().getName().equals(
								"java.lang.Double")) {
							Double value = Double.valueOf(getvalue);
							setMethod.invoke(newObject, new Object[] { value });
						} else {
							setMethod.invoke(newObject,
									new Object[] { getvalue });
						}
				} catch (Exception exception) {
				}

		} catch (Exception e) {
			throw new CommonException((new StringBuilder(
					"ת��HashMap�������ִ���:"))
					.append(e.getMessage().toString()).toString());
		}
		return newObject;
	}

	public static List hashMapConvertToObjectList(Object object, HashMap hash) {
		List list = new ArrayList();
		Object newObject = null;
		Object oneObject = null;
		boolean onedo = false;
		try {
			oneObject = object.getClass().newInstance();
			for (Iterator ite = hash.keySet().iterator(); ite.hasNext();) {
				String key = (String) (String) ite.next();
				Object geto = hash.get(key);
				if (geto instanceof Vector) {
					Vector vt = (Vector) geto;
					Object oo[] = vt.toArray();
					for (int i = 0; i < oo.length; i++) {
						HashMap hs = (HashMap) oo[i];
						newObject = object.getClass().newInstance();
						Field fields[] = object.getClass().getDeclaredFields();
						for (int j = 0; j < fields.length; j++) {
							Field field = fields[j];
							String fieldName = field.getName();
							String setMethodName = (new StringBuilder("set"))
									.append(
											fieldName.substring(0, 1)
													.toUpperCase()).append(
											fieldName.substring(1)).toString();
							Method setMethod = object.getClass().getMethod(
									setMethodName,
									new Class[] { field.getType() });
							setMethod.invoke(newObject, new Object[] { hs
									.get(fieldName) });
						}

						list.add(newObject);
					}

				} else {
					Field fields[] = oneObject.getClass().getDeclaredFields();
					for (int j = 0; j < fields.length; j++) {
						Field field = fields[j];
						String fieldName = field.getName();
						if (!fieldName.equals(StringUtils.processNull(key)))
							continue;
						onedo = true;
						String setMethodName = (new StringBuilder("set"))
								.append(fieldName.substring(0, 1).toUpperCase())
								.append(fieldName.substring(1)).toString();
						Method setMethod = object.getClass().getMethod(
								setMethodName, new Class[] { field.getType() });
						setMethod.invoke(oneObject, new Object[] { hash
								.get(fieldName) });
						break;
					}

				}
			}

			if (onedo)
				list.add(oneObject);
		} catch (Exception e) {
			throw new CommonException((new StringBuilder(
					"ת��HashMap��ָ���������鷢�ִ���:")).append(
					e.getMessage().toString()).toString());
		}
		return list;
	}

	public static HashMap objectConvertToHashMap(Object object, HashMap hash) {
		try {
			Field fields[] = object.getClass().getDeclaredFields();
			for (int i = 0; i < fields.length; i++) {
				Field field = fields[i];
				String fieldName = field.getName();
				String getMethodName = (new StringBuilder("get")).append(
						fieldName.substring(0, 1).toUpperCase()).append(
						fieldName.substring(1)).toString();
				Method getMethod = object.getClass().getMethod(getMethodName,
						new Class[0]);
				hash.put(fieldName, getMethod.invoke(object, new Object[0]));
			}

		} catch (Exception e) {
			throw new CommonException((new StringBuilder(
					"错误:"))
					.append(e.getMessage().toString()).toString());
		}
		return hash;
	}

	public ObjectCopyTools() {
	}
}
