/**   
* @Title: JsonHelper.java TODO:
* @Package com.erp.util
* @Description: TODO
* @author chenguang 
* @date 2015-4-1 上午08:19:37
* @version V1.0   
*/
package com.erp.util;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import com.google.gson.stream.JsonReader;

/**
 * 类功能说明 TODO:json帮助类
 * 类修改者	修改日期
 * 修改说明
 * <p>Title: JsonHelper.java</p>
 * <p>Description:杰斯科技</p>
 * <p>Copyright: Copyright (c) 2012</p>
 * <p>Company:杰斯科技</p>
 * @author hujc 631410114@qq.com
 * @date 2015-4-1 上午08:19:37
 * @version V1.0
 */
public class JsonHelper{

	public static List<Map<String, Object>> parseJSON2List(String jsonStr) {
		JSONArray jsonArr = JSONArray.fromObject(jsonStr);
		List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
		Iterator<JSONObject> it = jsonArr.iterator();
		while (it.hasNext()) {
			JSONObject json2 = it.next();
			list.add(parseJSON2Map(json2.toString()));
		}
		return list;
	}

	public static Map<String, Object> parseJSON2Map(String jsonStr) {
		Map<String, Object> map = new HashMap<String, Object>();
		// 最外层解析
		JSONObject json = JSONObject.fromObject(jsonStr);
		for (Object k : json.keySet()) {
			Object v = json.get(k);
			// 如果内层还是数组的话，继续解析
			if (v instanceof JSONArray) {
				List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
				Iterator<JSONObject> it = ((JSONArray) v).iterator();
				while (it.hasNext()) {
					JSONObject json2 = it.next();
					list.add(parseJSON2Map(json2.toString()));
				}
				map.put(k.toString(), list);
			} else {
				map.put(k.toString(), v);
			}
		}
		return map;
	}

	public static List<Map<String, Object>> getListByUrl(String url) {
		try {
			// 通过HTTP获取JSON数据
			InputStream in = new URL(url).openStream();
			BufferedReader reader = new BufferedReader(
					new InputStreamReader(in));
			StringBuilder sb = new StringBuilder();
			String line;
			while ((line = reader.readLine()) != null) {
				sb.append(line);
			}
			return parseJSON2List(sb.toString());
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static Map<String, Object> getMapByUrl(String url) {
		try {
			// 通过HTTP获取JSON数据
			InputStream in = new URL(url).openStream();
			BufferedReader reader = new BufferedReader(
					new InputStreamReader(in));
			StringBuilder sb = new StringBuilder();
			String line;
			while ((line = reader.readLine()) != null) {
				sb.append(line);
			}
			return parseJSON2Map(sb.toString());
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}
	
	/**
	 * 该字符串可能转为 JSONObject 或 JSONArray
	 * 
	 * @param string
	 * @return
	 */
	public static boolean mayBeJSON(String string) {
		return ((string != null) && ((("null".equals(string))
				|| ((string.startsWith("[")) && (string.endsWith("]"))) || ((string
				.startsWith("{")) && (string.endsWith("}"))))));
	}

	/**
	 * 该字符串可能转为JSONObject
	 * 
	 * @param string
	 * @return
	 */
	public static boolean mayBeJSONObject(String string) {
		return ((string != null) && ((("null".equals(string)) || ((string
				.startsWith("{")) && (string.endsWith("}"))))));
	}

	/**
	 * 该字符串可能转为 JSONArray
	 * 
	 * @param string
	 * @return
	 */
	public static boolean mayBeJSONArray(String string) {
		return ((string != null) && ((("null".equals(string)) || ((string
				.startsWith("[")) && (string.endsWith("]"))))));
	}




	/**
	 * 
	 * map转换json. <br>
	 * 详细说明
	 * 
	 * @param map
	 *            集合
	 * @return
	 * @return String json字符串
	 * @throws
	 * @author slj
	 */
	public static String mapToJson(Map<String, String> map) {
		Set<String> keys = map.keySet();
		String key = "";
		String value = "";
		StringBuffer jsonBuffer = new StringBuffer();
		jsonBuffer.append("{");
		for (Iterator<String> it = keys.iterator(); it.hasNext();) {
			key = (String) it.next();
			value = map.get(key);
			jsonBuffer.append(key + ":" + "\"" + value + "\"");
			if (it.hasNext()) {
				jsonBuffer.append(",");
			}
		}
		jsonBuffer.append("}");
		return jsonBuffer.toString();
	}

	/**
	 * 函数注释：parseJSON2Map()<br>
	 * 时间：2014-10-28-上午10:50:21<br>
	 * 用途：该方法用于json数据转换为<Map<String, Object>
	 * 
	 * @param jsonStr
	 * @return
	 */
	public static Map<String, Object> parseJSON2Map_(String jsonStr) {
		Map<String, Object> map = new HashMap<String, Object>();
		// 最外层解析
		JSONObject json = JSONObject.fromObject(jsonStr);
		for (Object k : json.keySet()) {
			Object v = json.get(k);
			// 如果内层还是数组的话，继续解析
			if (v instanceof JSONArray) {
				List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
				Iterator<JSONObject> it = ((JSONArray) v).iterator();
				while (it.hasNext()) {
					JSONObject json2 = it.next();
					list.add(parseJSON2Map(json2.toString()));
				}
				map.put(k.toString(), list);
			} else {
				map.put(k.toString(), v);
			}
		}
		return map;
	}

	/**
	 * 函数注释：parseJSON2MapString()<br>
	 * 用途：该方法用于json数据转换为<Map<String, String><br>
	 * 备注：***<br>
	 */
	public static Map<String, String> parseJSON2MapString_(String jsonStr) {
		Map<String, String> map = new HashMap<String, String>();
		// 最外层解析
		JSONObject json = JSONObject.fromObject(jsonStr);
		for (Object k : json.keySet()) {
			Object v = json.get(k);
			if (null != v) {
				map.put(k.toString(), v.toString());
			}
		}
		return map;
	}

	/**
	 * 将List<Map<String,Object>>转换成JSON字符串
	 * 
	 * @param o
	 * @return
	 */
	public static String parseListMap2JSon(Object o) {
		Gson gson = new GsonBuilder().create();
		return gson.toJson(o, new TypeToken<List<Map<String, Object>>>() {
		}.getType());
	}

	/**
	 * 将JSON格式转换成Map
	 * 
	 * @param json
	 * @return
	 */
	public static Map<String, Object> parseJSON2Map_1(String json) {
		Map<String, Object> map = new HashMap<String, Object>();
		Gson gson = new GsonBuilder().create();
		JsonReader reader = new JsonReader(new StringReader(json));
		map = gson.fromJson(reader, new TypeToken<Map<String, Object>>() {
		}.getType());
		return map;
	}

	/**
	 * 将JSON转成List<Map>
	 * 
	 * @param json
	 * @return
	 */
	public static List<Map<String, Object>> parseJSON2ListMap_1(String json) {
		List<Map<String, Object>> rst = new ArrayList<Map<String, Object>>();
		Gson gson = new Gson();
		JsonReader reader = new JsonReader(new StringReader(json));
		rst = gson.fromJson(reader, new TypeToken<List<Map<Object, String>>>() {
		}.getType());
		return rst;
	}

	/**
	 * 将对象转换成JSON格式
	 * 
	 * @param o
	 * @return
	 */
	public static String parse2JSON_1(Object o) {
		if (o == null) {
			return "";
		}
		Gson g = new GsonBuilder().create();
		String json = g.toJson(o, o.getClass());
		return json;
	}

	/**
	 * 将json字符串转换成指定类型的对象
	 * 
	 * @param json
	 * @param typeToken
	 * @return
	 */
	public static <T> T parseJson2_1(String json, TypeToken<T> typeToken) {
		Gson gson = new Gson();
		JsonReader reader = new JsonReader(new StringReader(json));
		return gson.fromJson(reader, typeToken.getType());
	}

	/**
	 * 将对象转换成JSON格式
	 * 
	 * @param o
	 * @return
	 */
	public static String parse2JSON(Object o) {
		if (o == null) {
			return "";
		}
		Gson g = new GsonBuilder().create();
		String json = g.toJson(o, o.getClass());
		return json;
	}

	/**
	 * 将json字符串转换成指定类型的对象
	 * 
	 * @param json
	 * @param typeToken
	 * @return
	 */
	public static <T> T parseJson2(String json, TypeToken<T> typeToken) {
		Gson gson = new Gson();
		JsonReader reader = new JsonReader(new StringReader(json));
		return gson.fromJson(reader, typeToken.getType());
	}

	/**
	 * 将JSON转成List<Map>
	 * 
	 * @param json
	 * @return
	 */
	public static List<Map<String, Object>> parseJSON2ListMap(String json) {
		List<Map<String, Object>> rst = new ArrayList<Map<String, Object>>();
		Gson gson = new Gson();
		JsonReader reader = new JsonReader(new StringReader(json));
		rst = gson.fromJson(reader, new TypeToken<List<Map<Object, String>>>() {
		}.getType());
		return rst;
	}

}
