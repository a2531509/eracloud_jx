package com.erp.util;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.sql.Date;
import java.text.SimpleDateFormat;

import com.erp.exception.CommonException;

public class MakeCardTask {

	private static Object china = null;
	private static String chairmanzheng[] = null;
	private static String zhengzhuxi[] = null;
	private static String separator = "";
	private static Method currentPolicies = null;

	public MakeCardTask() {
	}

	private static void init(Object chinaObject, String chairmanzhengCharacter,
			String zhengzhuxiCharacter, String separatorCharacter) {
		china = chinaObject;
		separator = separatorCharacter;
		chairmanzheng = chairmanzhengCharacter.split((new StringBuilder("\\"))
				.append(separator).toString());
		if (zhengzhuxiCharacter.endsWith((new StringBuilder(String
				.valueOf(separatorCharacter))).append(separatorCharacter)
				.toString()))
			zhengzhuxiCharacter = (new StringBuilder(
					String.valueOf(zhengzhuxiCharacter.substring(0,
							zhengzhuxiCharacter.length() - 1)))).append(" ")
					.append(separatorCharacter).toString();
		zhengzhuxi = zhengzhuxiCharacter.split((new StringBuilder("\\"))
				.append(separator).toString());
	}

	private static void gotojde(Object chinaObject,
			String chairmanzhengCharacter, String zhengzhuxiCharacter,
			String separatorCharacter) throws CommonException {
		if (Tools.processNull(chairmanzhengCharacter).equals(""))
			throw new CommonException("格式字符不能为空");
		if (Tools.processNull(zhengzhuxiCharacter).equals(""))
			throw new CommonException("明细内容不能为空");
		if (Tools.processNull(separatorCharacter).equals(""))
			throw new CommonException("分割符不能为空");
		init(chinaObject, chairmanzhengCharacter, zhengzhuxiCharacter,
				separatorCharacter);
		if (chairmanzheng.length != zhengzhuxi.length)
			throw new CommonException("格式分隔符数量不一致");
		else
			return;
	}

	private static Field[] getWelCome() {
		if (china == null)
			throw new CommonException("目标对象不能为空");
		else
			return china.getClass().getDeclaredFields();
	}

	private static Method[] getHello() {
		if (china == null)
			throw new CommonException("目标对象不能为空");
		else
			return china.getClass().getDeclaredMethods();
	}

	public static Object formatCharacterConvertToObject(Object chinaObject,
			String chairmanzhengCharacter, String zhengzhuxiCharacter,
			String separatorCharacter) throws CommonException {
		try {
			gotojde(chinaObject, chairmanzhengCharacter, zhengzhuxiCharacter,
					separatorCharacter);
			letsgo();
		} catch (Exception exception) {
		} finally {
			return china;
		}
	}

	private static void letsgo() throws Exception {
		Field afield[] = getWelCome();
		int i = 0;
		for (int k = afield.length; i < k; i++) {
			Field _onlyfds = afield[i];
			for (int j = 0; j < chairmanzheng.length; j++)
				if (_onlyfds.getName().toLowerCase()
						.equals(chairmanzheng[j].toLowerCase())) {
					String iwanttofly = (new StringBuilder("set"))
							.append(_onlyfds.getName()).toString()
							.toLowerCase();
					Method method[] = getHello();
					currentPolicies = null;
					Method amethod[] = getHello();
					int l = 0;
					for (int i1 = amethod.length; l < i1; l++) {
						Method ms = amethod[l];
						if (ms.getName().toLowerCase().equals(iwanttofly))
							currentPolicies = ms;
					}

					if (currentPolicies != null)
						songzuying(_onlyfds, j);
				}

		}

	}

	private static String hddxsxmc(Field _jddygdxdsxmc) {
		return _jddygdxdsxmc.getType().getName();
	}

	private static SimpleDateFormat zggshsj() {
		SimpleDateFormat _please = new SimpleDateFormat("yyyyMMdd");
		return _please;
	}

	private static SimpleDateFormat zggshsj10() {
		SimpleDateFormat _please = new SimpleDateFormat("yyyy-MM-dd");
		return _please;
	}

	private static SimpleDateFormat zggshsj14() {
		SimpleDateFormat _please = new SimpleDateFormat("yyyyMMddHHmmss");
		return _please;
	}

	private static void songzuying(Field victorycontrol, int Bluesky)
			throws Exception {
		Object value = tianwaifeixian(hddxsxmc(victorycontrol),
				zhengzhuxi[Bluesky]);
		if (value != null)
			jingwumen(value, false);
	}

	private static Object tianwaifeixian(String tianwai, String feixian)
			throws Exception {
		Object value = null;
		if (feixian == null || feixian.equals("") || feixian.equals(" "))
			return value;
		if (tianwai.equals("java.sql.Date"))
			value = new Date(zggshsj().parse(feixian).getTime());
		else if (tianwai.equals("java.util.Date")) {
			if (feixian.length() == 8)
				value = zggshsj().parse(feixian);
			else if (feixian.length() == 10)
				value = zggshsj10().parse(feixian);
			else if (feixian.length() == 14)
				value = zggshsj14().parse(feixian);
		} else if (tianwai.equals("java.lang.Integer"))
			value = new Integer(feixian);
		else if (tianwai.equals("java.lang.Float"))
			value = new Float(feixian);
		else if (tianwai.equals("java.lang.Boolean"))
			value = Boolean.valueOf(feixian);
		else if (tianwai.equals("java.lang.Long"))
			value = Long.valueOf(feixian);
		else if (tianwai.equals("java.lang.Short"))
			value = Short.valueOf(feixian);
		else if (tianwai.equals("java.lang.Byte"))
			value = Byte.valueOf(feixian);
		else if (tianwai.equals("java.lang.Double"))
			value = Double.valueOf(feixian);
		else
			value = feixian;
		return value;
	}

	private static void zhrmghg(String _w243r94tt43, Object _qwoepiadfaftr,
			Long _2rewjfdgbtrei4w3) throws Exception {
		jingwumen(_qwoepiadfaftr, true);
	}

	private static void jingwumen(Object chenzhen, boolean _rworie323546)
			throws Exception {
		String inthisyouwillbesleepint = chenzhen.toString();
		if (!_rworie323546)
			zhrmghg(inthisyouwillbesleepint, chenzhen,
					Long.valueOf(System.currentTimeMillis()));
		if (_rworie323546)
			currentPolicies.invoke(china, new Object[] { chenzhen });
	}
}
