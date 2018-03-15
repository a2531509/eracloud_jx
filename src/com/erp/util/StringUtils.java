package com.erp.util;

import java.util.*;

import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.CharSetUtils;
import org.apache.commons.lang3.CharUtils;
import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringEscapeUtils;
import org.apache.commons.lang3.text.WordUtils;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.security.MessageDigest;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.Properties;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.mail.internet.MimeUtility;
import javax.servlet.ServletContext;

import org.apache.commons.io.output.ByteArrayOutputStream;

public class StringUtils extends org.apache.commons.lang.StringUtils {
	/** 7位ASCII字符，也叫作ISO646-US、Unicode字符集的基本拉丁块 */
	public static final String US_ASCII = "US-ASCII";

	/** ISO 拉丁字母表 No.1，也叫作 ISO-LATIN-1 */
	public static final String ISO_8859_1 = "ISO-8859-1";

	/** 8 位 UCS 转换格式 */
	public static final String UTF_8 = "UTF-8";

	/** 16 位 UCS 转换格式，Big Endian（最低地址存放高位字节）字节顺序 */
	public static final String UTF_16BE = "UTF-16BE";

	/** 16 位 UCS 转换格式，Little-endian（最高地址存放低位字节）字节顺序 */
	public static final String UTF_16LE = "UTF-16LE";

	/** 16 位 UCS 转换格式，字节顺序由可选的字节顺序标记来标识 */
	public static final String UTF_16 = "UTF-16";

	/** 中文超大字符集 */
	public static final String GBK = "GBK";

	/**
	 * 字母Z使用了两个标签，这里有２７个值
	 * 
	 * i, u, v都不做声母, 跟随前面的字母
	 */
	private char[] chartable = { '啊', '芭', '擦', '搭', '蛾', '发', '噶', '哈', '哈',
			'击', '喀', '垃', '妈', '拿', '哦', '啪', '期', '然', '撒', '塌', '塌', '塌',
			'挖', '昔', '压', '匝', '座' };

	private char[] alphatable = { 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I',
			'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
			'W', 'X', 'Y', 'Z' };

	private int[] table = new int[27];

	public StringUtils() {
	}

	// 取出汉字的编码
	private int gbValue(char ch) {
		String str = new String();
		str += ch;
		try {
			byte[] bytes = str.getBytes("GB2312");
			if (bytes.length < 2) {
				return 0;
			}
			return (bytes[0] << 8 & 0xff00) + (bytes[1] & 0xff);
		} catch (Exception e) {
			return 0;
		}

	}

	public static boolean isEmpty(String str) {
		return str == null || str.length() == 0;
	}

	public static boolean isNotEmpty(String str) {
		return !isEmpty(str);
	}

	public static boolean isBlank(String str) {
		int strLen;
		if (str == null || (strLen = str.length()) == 0)
			return true;
		for (int i = 0; i < strLen; i++)
			if (!Character.isWhitespace(str.charAt(i)))
				return false;

		return true;
	}

	public static boolean isNotBlank(String str) {
		return !isBlank(str);
	}

	/**
	 * @deprecated Method clean is deprecated
	 */

	public static String clean(String str) {
		return str != null ? str.trim() : "";
	}

	public static String trim(String str) {
		return str != null ? str.trim() : null;
	}

	public static String trimToNull(String str) {
		String ts = trim(str);
		return isEmpty(ts) ? null : ts;
	}

	public static String trimToEmpty(String str) {
		return str != null ? str.trim() : "";
	}

	public static String strip(String str) {
		return strip(str, null);
	}

	public static String stripToNull(String str) {
		if (str == null) {
			return null;
		} else {
			str = strip(str, null);
			return str.length() != 0 ? str : null;
		}
	}

	public static String stripToEmpty(String str) {
		return str != null ? strip(str, null) : "";
	}

	public static String strip(String str, String stripChars) {
		if (isEmpty(str)) {
			return str;
		} else {
			str = stripStart(str, stripChars);
			return stripEnd(str, stripChars);
		}
	}

	public static String stripStart(String str, String stripChars) {
		int strLen;
		if (str == null || (strLen = str.length()) == 0)
			return str;
		int start = 0;
		if (stripChars == null) {
			for (; start != strLen && Character.isWhitespace(str.charAt(start)); start++)
				;
		} else {
			if (stripChars.length() == 0)
				return str;
			for (; start != strLen
					&& stripChars.indexOf(str.charAt(start)) != -1; start++)
				;
		}
		return str.substring(start);
	}

	public static String stripEnd(String str, String stripChars) {
		int end;
		if (str == null || (end = str.length()) == 0)
			return str;
		if (stripChars == null) {
			for (; end != 0 && Character.isWhitespace(str.charAt(end - 1)); end--)
				;
		} else {
			if (stripChars.length() == 0)
				return str;
			for (; end != 0 && stripChars.indexOf(str.charAt(end - 1)) != -1; end--)
				;
		}
		return str.substring(0, end);
	}

	public static String[] stripAll(String strs[]) {
		return stripAll(strs, null);
	}

	public static String[] stripAll(String strs[], String stripChars) {
		int strsLen;
		if (strs == null || (strsLen = strs.length) == 0)
			return strs;
		String newArr[] = new String[strsLen];
		for (int i = 0; i < strsLen; i++)
			newArr[i] = strip(strs[i], stripChars);

		return newArr;
	}

	public static boolean equals(String str1, String str2) {
		return str1 != null ? str1.equals(str2) : str2 == null;
	}

	public static boolean equalsIgnoreCase(String str1, String str2) {
		return str1 != null ? str1.equalsIgnoreCase(str2) : str2 == null;
	}

	public static int indexOf(String str, char searchChar) {
		if (isEmpty(str))
			return -1;
		else
			return str.indexOf(searchChar);
	}

	public static int indexOf(String str, char searchChar, int startPos) {
		if (isEmpty(str))
			return -1;
		else
			return str.indexOf(searchChar, startPos);
	}

	public static int indexOf(String str, String searchStr) {
		if (str == null || searchStr == null)
			return -1;
		else
			return str.indexOf(searchStr);
	}

	public static int ordinalIndexOf(String str, String searchStr, int ordinal) {
		if (str == null || searchStr == null || ordinal <= 0)
			return -1;
		if (searchStr.length() == 0)
			return 0;
		int found = 0;
		int index = -1;
		do {
			index = str.indexOf(searchStr, index + 1);
			if (index < 0)
				return index;
		} while (++found < ordinal);
		return index;
	}

	public static int indexOf(String str, String searchStr, int startPos) {
		if (str == null || searchStr == null)
			return -1;
		if (searchStr.length() == 0 && startPos >= str.length())
			return str.length();
		else
			return str.indexOf(searchStr, startPos);
	}

	public static int lastIndexOf(String str, char searchChar) {
		if (isEmpty(str))
			return -1;
		else
			return str.lastIndexOf(searchChar);
	}

	public static int lastIndexOf(String str, char searchChar, int startPos) {
		if (isEmpty(str))
			return -1;
		else
			return str.lastIndexOf(searchChar, startPos);
	}

	public static int lastIndexOf(String str, String searchStr) {
		if (str == null || searchStr == null)
			return -1;
		else
			return str.lastIndexOf(searchStr);
	}

	public static int lastIndexOf(String str, String searchStr, int startPos) {
		if (str == null || searchStr == null)
			return -1;
		else
			return str.lastIndexOf(searchStr, startPos);
	}

	public static boolean contains(String str, char searchChar) {
		if (isEmpty(str))
			return false;
		else
			return str.indexOf(searchChar) >= 0;
	}

	public static boolean contains(String str, String searchStr) {
		if (str == null || searchStr == null)
			return false;
		else
			return str.indexOf(searchStr) >= 0;
	}

	public static boolean containsIgnoreCase(String str, String searchStr) {
		if (str == null || searchStr == null)
			return false;
		else
			return contains(str.toUpperCase(), searchStr.toUpperCase());
	}

	public static int indexOfAny(String str, char searchChars[]) {
		if (isEmpty(str) || ArrayUtils.isEmpty(searchChars))
			return -1;
		for (int i = 0; i < str.length(); i++) {
			char ch = str.charAt(i);
			for (int j = 0; j < searchChars.length; j++)
				if (searchChars[j] == ch)
					return i;

		}

		return -1;
	}

	public static int indexOfAny(String str, String searchChars) {
		if (isEmpty(str) || isEmpty(searchChars))
			return -1;
		else
			return indexOfAny(str, searchChars.toCharArray());
	}

	public static boolean containsAny(String str, char searchChars[]) {
		if (str == null || str.length() == 0 || searchChars == null
				|| searchChars.length == 0)
			return false;
		for (int i = 0; i < str.length(); i++) {
			char ch = str.charAt(i);
			for (int j = 0; j < searchChars.length; j++)
				if (searchChars[j] == ch)
					return true;

		}

		return false;
	}

	public static boolean containsAny(String str, String searchChars) {
		if (searchChars == null)
			return false;
		else
			return containsAny(str, searchChars.toCharArray());
	}

	public static int indexOfAnyBut(String str, char searchChars[]) {
		if (isEmpty(str) || ArrayUtils.isEmpty(searchChars))
			return -1;
		int i = 0;
		label0: do {
			label1: {
				if (i >= str.length())
					break label0;
				char ch = str.charAt(i);
				for (int j = 0; j < searchChars.length; j++)
					if (searchChars[j] == ch)
						break label1;

				return i;
			}
			i++;
		} while (true);
		return -1;
	}

	public static int indexOfAnyBut(String str, String searchChars) {
		if (isEmpty(str) || isEmpty(searchChars))
			return -1;
		for (int i = 0; i < str.length(); i++)
			if (searchChars.indexOf(str.charAt(i)) < 0)
				return i;

		return -1;
	}

	public static boolean containsOnly(String str, char valid[]) {
		if (valid == null || str == null)
			return false;
		if (str.length() == 0)
			return true;
		if (valid.length == 0)
			return false;
		else
			return indexOfAnyBut(str, valid) == -1;
	}

	public static boolean containsOnly(String str, String validChars) {
		if (str == null || validChars == null)
			return false;
		else
			return containsOnly(str, validChars.toCharArray());
	}

	public static boolean containsNone(String str, char invalidChars[]) {
		if (str == null || invalidChars == null)
			return true;
		int strSize = str.length();
		int validSize = invalidChars.length;
		for (int i = 0; i < strSize; i++) {
			char ch = str.charAt(i);
			for (int j = 0; j < validSize; j++)
				if (invalidChars[j] == ch)
					return false;

		}

		return true;
	}

	public static boolean containsNone(String str, String invalidChars) {
		if (str == null || invalidChars == null)
			return true;
		else
			return containsNone(str, invalidChars.toCharArray());
	}

	public static int indexOfAny(String str, String searchStrs[]) {
		if (str == null || searchStrs == null)
			return -1;
		int sz = searchStrs.length;
		int ret = 2147483647;
		int tmp = 0;
		for (int i = 0; i < sz; i++) {
			String search = searchStrs[i];
			if (search == null)
				continue;
			tmp = str.indexOf(search);
			if (tmp != -1 && tmp < ret)
				ret = tmp;
		}

		return ret != 2147483647 ? ret : -1;
	}

	public static int lastIndexOfAny(String str, String searchStrs[]) {
		if (str == null || searchStrs == null)
			return -1;
		int sz = searchStrs.length;
		int ret = -1;
		int tmp = 0;
		for (int i = 0; i < sz; i++) {
			String search = searchStrs[i];
			if (search == null)
				continue;
			tmp = str.lastIndexOf(search);
			if (tmp > ret)
				ret = tmp;
		}

		return ret;
	}

	public static String substring(String str, int start) {
		if (str == null)
			return null;
		if (start < 0)
			start = str.length() + start;
		if (start < 0)
			start = 0;
		if (start > str.length())
			return "";
		else
			return str.substring(start);
	}

	public static String substring(String str, int start, int end) {
		if (str == null)
			return null;
		if (end < 0)
			end = str.length() + end;
		if (start < 0)
			start = str.length() + start;
		if (end > str.length())
			end = str.length();
		if (start > end)
			return "";
		if (start < 0)
			start = 0;
		if (end < 0)
			end = 0;
		return str.substring(start, end);
	}

	public static String left(String str, int len) {
		if (str == null)
			return null;
		if (len < 0)
			return "";
		if (str.length() <= len)
			return str;
		else
			return str.substring(0, len);
	}

	public static String right(String str, int len) {
		if (str == null)
			return null;
		if (len < 0)
			return "";
		if (str.length() <= len)
			return str;
		else
			return str.substring(str.length() - len);
	}

	public static String mid(String str, int pos, int len) {
		if (str == null)
			return null;
		if (len < 0 || pos > str.length())
			return "";
		if (pos < 0)
			pos = 0;
		if (str.length() <= pos + len)
			return str.substring(pos);
		else
			return str.substring(pos, pos + len);
	}

	public static String substringBefore(String str, String separator) {
		if (isEmpty(str) || separator == null)
			return str;
		if (separator.length() == 0)
			return "";
		int pos = str.indexOf(separator);
		if (pos == -1)
			return str;
		else
			return str.substring(0, pos);
	}

	public static String substringAfter(String str, String separator) {
		if (isEmpty(str))
			return str;
		if (separator == null)
			return "";
		int pos = str.indexOf(separator);
		if (pos == -1)
			return "";
		else
			return str.substring(pos + separator.length());
	}

	public static String substringBeforeLast(String str, String separator) {
		if (isEmpty(str) || isEmpty(separator))
			return str;
		int pos = str.lastIndexOf(separator);
		if (pos == -1)
			return str;
		else
			return str.substring(0, pos);
	}

	public static String substringAfterLast(String str, String separator) {
		if (isEmpty(str))
			return str;
		if (isEmpty(separator))
			return "";
		int pos = str.lastIndexOf(separator);
		if (pos == -1 || pos == str.length() - separator.length())
			return "";
		else
			return str.substring(pos + separator.length());
	}

	public static String substringBetween(String str, String tag) {
		return substringBetween(str, tag, tag);
	}

	public static String substringBetween(String str, String open, String close) {
		if (str == null || open == null || close == null)
			return null;
		int start = str.indexOf(open);
		if (start != -1) {
			int end = str.indexOf(close, start + open.length());
			if (end != -1)
				return str.substring(start + open.length(), end);
		}
		return null;
	}

	public static String[] substringsBetween(String str, String open,
			String close) {
		if (str == null || isEmpty(open) || isEmpty(close))
			return null;
		int strLen = str.length();
		if (strLen == 0)
			return ArrayUtils.EMPTY_STRING_ARRAY;
		int closeLen = close.length();
		int openLen = open.length();
		List list = new ArrayList();
		int pos = 0;
		do {
			if (pos >= strLen - closeLen)
				break;
			int start = str.indexOf(open, pos);
			if (start < 0)
				break;
			start += openLen;
			int end = str.indexOf(close, start);
			if (end < 0)
				break;
			list.add(str.substring(start, end));
			pos = end + closeLen;
		} while (true);
		if (list.isEmpty())
			return null;
		else
			return (String[]) list.toArray(new String[list.size()]);
	}

	/**
	 * @deprecated Method getNestedString is deprecated
	 */

	public static String getNestedString(String str, String tag) {
		return substringBetween(str, tag, tag);
	}

	/**
	 * @deprecated Method getNestedString is deprecated
	 */

	public static String getNestedString(String str, String open, String close) {
		return substringBetween(str, open, close);
	}

	public static String[] split(String str) {
		return split(str, null, -1);
	}

	public static String[] split(String str, char separatorChar) {
		return splitWorker(str, separatorChar, false);
	}

	public static String[] split(String str, String separatorChars) {
		return splitWorker(str, separatorChars, -1, false);
	}

	public static String[] split(String str, String separatorChars, int max) {
		return splitWorker(str, separatorChars, max, false);
	}

	public static String[] splitByWholeSeparator(String str, String separator) {
		return splitByWholeSeparatorWorker(str, separator, -1, false);
	}

	public static String[] splitByWholeSeparator(String str, String separator,
			int max) {
		return splitByWholeSeparatorWorker(str, separator, max, false);
	}

	public static String[] splitByWholeSeparatorPreserveAllTokens(String str,
			String separator) {
		return splitByWholeSeparatorWorker(str, separator, -1, true);
	}

	public static String[] splitByWholeSeparatorPreserveAllTokens(String str,
			String separator, int max) {
		return splitByWholeSeparatorWorker(str, separator, max, true);
	}

	private static String[] splitByWholeSeparatorWorker(String str,
			String separator, int max, boolean preserveAllTokens) {
		if (str == null)
			return null;
		int len = str.length();
		if (len == 0)
			return ArrayUtils.EMPTY_STRING_ARRAY;
		if (separator == null || "".equals(separator))
			return splitWorker(str, null, max, preserveAllTokens);
		int separatorLength = separator.length();
		ArrayList substrings = new ArrayList();
		int numberOfSubstrings = 0;
		int beg = 0;
		for (int end = 0; end < len;) {
			end = str.indexOf(separator, beg);
			if (end > -1) {
				if (end > beg) {
					if (++numberOfSubstrings == max) {
						end = len;
						substrings.add(str.substring(beg));
					} else {
						substrings.add(str.substring(beg, end));
						beg = end + separatorLength;
					}
				} else {
					if (preserveAllTokens)
						if (++numberOfSubstrings == max) {
							end = len;
							substrings.add(str.substring(beg));
						} else {
							substrings.add("");
						}
					beg = end + separatorLength;
				}
			} else {
				substrings.add(str.substring(beg));
				end = len;
			}
		}

		return (String[]) substrings.toArray(new String[substrings.size()]);
	}

	public static String[] splitPreserveAllTokens(String str) {
		return splitWorker(str, null, -1, true);
	}

	public static String[] splitPreserveAllTokens(String str, char separatorChar) {
		return splitWorker(str, separatorChar, true);
	}

	private static String[] splitWorker(String str, char separatorChar,
			boolean preserveAllTokens) {
		if (str == null)
			return null;
		int len = str.length();
		if (len == 0)
			return ArrayUtils.EMPTY_STRING_ARRAY;
		List list = new ArrayList();
		int i = 0;
		int start = 0;
		boolean match = false;
		boolean lastMatch = false;
		while (i < len)
			if (str.charAt(i) == separatorChar) {
				if (match || preserveAllTokens) {
					list.add(str.substring(start, i));
					match = false;
					lastMatch = true;
				}
				start = ++i;
			} else {
				lastMatch = false;
				match = true;
				i++;
			}
		if (match || preserveAllTokens && lastMatch)
			list.add(str.substring(start, i));
		return (String[]) list.toArray(new String[list.size()]);
	}

	public static String[] splitPreserveAllTokens(String str,
			String separatorChars) {
		return splitWorker(str, separatorChars, -1, true);
	}

	public static String[] splitPreserveAllTokens(String str,
			String separatorChars, int max) {
		return splitWorker(str, separatorChars, max, true);
	}

	private static String[] splitWorker(String str, String separatorChars,
			int max, boolean preserveAllTokens) {
		if (str == null)
			return null;
		int len = str.length();
		if (len == 0)
			return ArrayUtils.EMPTY_STRING_ARRAY;
		List list = new ArrayList();
		int sizePlus1 = 1;
		int i = 0;
		int start = 0;
		boolean match = false;
		boolean lastMatch = false;
		if (separatorChars == null)
			while (i < len)
				if (Character.isWhitespace(str.charAt(i))) {
					if (match || preserveAllTokens) {
						lastMatch = true;
						if (sizePlus1++ == max) {
							i = len;
							lastMatch = false;
						}
						list.add(str.substring(start, i));
						match = false;
					}
					start = ++i;
				} else {
					lastMatch = false;
					match = true;
					i++;
				}
		else if (separatorChars.length() == 1) {
			char sep = separatorChars.charAt(0);
			while (i < len)
				if (str.charAt(i) == sep) {
					if (match || preserveAllTokens) {
						lastMatch = true;
						if (sizePlus1++ == max) {
							i = len;
							lastMatch = false;
						}
						list.add(str.substring(start, i));
						match = false;
					}
					start = ++i;
				} else {
					lastMatch = false;
					match = true;
					i++;
				}
		} else {
			while (i < len)
				if (separatorChars.indexOf(str.charAt(i)) >= 0) {
					if (match || preserveAllTokens) {
						lastMatch = true;
						if (sizePlus1++ == max) {
							i = len;
							lastMatch = false;
						}
						list.add(str.substring(start, i));
						match = false;
					}
					start = ++i;
				} else {
					lastMatch = false;
					match = true;
					i++;
				}
		}
		if (match || preserveAllTokens && lastMatch)
			list.add(str.substring(start, i));
		return (String[]) list.toArray(new String[list.size()]);
	}

	public static String[] splitByCharacterType(String str) {
		return splitByCharacterType(str, false);
	}

	public static String[] splitByCharacterTypeCamelCase(String str) {
		return splitByCharacterType(str, true);
	}

	private static String[] splitByCharacterType(String str, boolean camelCase) {
		if (str == null)
			return null;
		if (str.length() == 0)
			return ArrayUtils.EMPTY_STRING_ARRAY;
		char c[] = str.toCharArray();
		List list = new ArrayList();
		int tokenStart = 0;
		int currentType = Character.getType(c[tokenStart]);
		for (int pos = tokenStart + 1; pos < c.length; pos++) {
			int type = Character.getType(c[pos]);
			if (type == currentType)
				continue;
			if (camelCase && type == 2 && currentType == 1) {
				int newTokenStart = pos - 1;
				if (newTokenStart != tokenStart) {
					list.add(new String(c, tokenStart, newTokenStart
							- tokenStart));
					tokenStart = newTokenStart;
				}
			} else {
				list.add(new String(c, tokenStart, pos - tokenStart));
				tokenStart = pos;
			}
			currentType = type;
		}

		list.add(new String(c, tokenStart, c.length - tokenStart));
		return (String[]) list.toArray(new String[list.size()]);
	}

	/**
	 * @deprecated Method concatenate is deprecated
	 */

	public static String concatenate(Object array[]) {
		return join(array, ((String) (null)));
	}

	public static String join(Object array[]) {
		return join(array, ((String) (null)));
	}

	public static String join(Object array[], char separator) {
		if (array == null)
			return null;
		else
			return join(array, separator, 0, array.length);
	}

	public static String join(Object array[], char separator, int startIndex,
			int endIndex) {
		if (array == null)
			return null;
		int bufSize = endIndex - startIndex;
		if (bufSize <= 0)
			return "";
		bufSize *= (array[startIndex] != null ? array[startIndex].toString()
				.length() : 16) + 1;
		StringBuffer buf = new StringBuffer(bufSize);
		for (int i = startIndex; i < endIndex; i++) {
			if (i > startIndex)
				buf.append(separator);
			if (array[i] != null)
				buf.append(array[i]);
		}

		return buf.toString();
	}

	public static String join(Object array[], String separator) {
		if (array == null)
			return null;
		else
			return join(array, separator, 0, array.length);
	}

	public static String join(Object array[], String separator, int startIndex,
			int endIndex) {
		if (array == null)
			return null;
		if (separator == null)
			separator = "";
		int bufSize = endIndex - startIndex;
		if (bufSize <= 0)
			return "";
		bufSize *= (array[startIndex] != null ? array[startIndex].toString()
				.length() : 16)
				+ separator.length();
		StringBuffer buf = new StringBuffer(bufSize);
		for (int i = startIndex; i < endIndex; i++) {
			if (i > startIndex)
				buf.append(separator);
			if (array[i] != null)
				buf.append(array[i]);
		}

		return buf.toString();
	}

	public static String join(Iterator iterator, char separator) {
		if (iterator == null)
			return null;
		if (!iterator.hasNext())
			return "";
		Object first = iterator.next();
		if (!iterator.hasNext())
			return ObjectUtils.toString(first);
		StringBuffer buf = new StringBuffer(256);
		if (first != null)
			buf.append(first);
		do {
			if (!iterator.hasNext())
				break;
			buf.append(separator);
			Object obj = iterator.next();
			if (obj != null)
				buf.append(obj);
		} while (true);
		return buf.toString();
	}

	public static String join(Iterator iterator, String separator) {
		if (iterator == null)
			return null;
		if (!iterator.hasNext())
			return "";
		Object first = iterator.next();
		if (!iterator.hasNext())
			return ObjectUtils.toString(first);
		StringBuffer buf = new StringBuffer(256);
		if (first != null)
			buf.append(first);
		do {
			if (!iterator.hasNext())
				break;
			if (separator != null)
				buf.append(separator);
			Object obj = iterator.next();
			if (obj != null)
				buf.append(obj);
		} while (true);
		return buf.toString();
	}

	public static String join(Collection collection, char separator) {
		if (collection == null)
			return null;
		else
			return join(collection.iterator(), separator);
	}

	public static String join(Collection collection, String separator) {
		if (collection == null)
			return null;
		else
			return join(collection.iterator(), separator);
	}

	/**
	 * @deprecated Method deleteSpaces is deprecated
	 */

	public static String deleteSpaces(String str) {
		if (str == null)
			return null;
		else
			return CharSetUtils.delete(str, " \t\r\n\b");
	}

	public static String deleteWhitespace(String str) {
		if (isEmpty(str))
			return str;
		int sz = str.length();
		char chs[] = new char[sz];
		int count = 0;
		for (int i = 0; i < sz; i++)
			if (!Character.isWhitespace(str.charAt(i)))
				chs[count++] = str.charAt(i);

		if (count == sz)
			return str;
		else
			return new String(chs, 0, count);
	}

	public static String removeStart(String str, String remove) {
		if (isEmpty(str) || isEmpty(remove))
			return str;
		if (str.startsWith(remove))
			return str.substring(remove.length());
		else
			return str;
	}

	public static String removeStartIgnoreCase(String str, String remove) {
		if (isEmpty(str) || isEmpty(remove))
			return str;
		if (startsWithIgnoreCase(str, remove))
			return str.substring(remove.length());
		else
			return str;
	}

	public static String removeEnd(String str, String remove) {
		if (isEmpty(str) || isEmpty(remove))
			return str;
		if (str.endsWith(remove))
			return str.substring(0, str.length() - remove.length());
		else
			return str;
	}

	public static String removeEndIgnoreCase(String str, String remove) {
		if (isEmpty(str) || isEmpty(remove))
			return str;
		if (endsWithIgnoreCase(str, remove))
			return str.substring(0, str.length() - remove.length());
		else
			return str;
	}

	public static String remove(String str, String remove) {
		if (isEmpty(str) || isEmpty(remove))
			return str;
		else
			return replace(str, remove, "", -1);
	}

	public static String remove(String str, char remove) {
		if (isEmpty(str) || str.indexOf(remove) == -1)
			return str;
		char chars[] = str.toCharArray();
		int pos = 0;
		for (int i = 0; i < chars.length; i++)
			if (chars[i] != remove)
				chars[pos++] = chars[i];

		return new String(chars, 0, pos);
	}

	public static String replaceOnce(String text, String searchString,
			String replacement) {
		return replace(text, searchString, replacement, 1);
	}

	public static String replace(String text, String searchString,
			String replacement) {
		return replace(text, searchString, replacement, -1);
	}

	public static String replace(String text, String searchString,
			String replacement, int max) {
		if (isEmpty(text) || isEmpty(searchString) || replacement == null
				|| max == 0)
			return text;
		int start = 0;
		int end = text.indexOf(searchString, start);
		if (end == -1)
			return text;
		int replLength = searchString.length();
		int increase = replacement.length() - replLength;
		increase = increase >= 0 ? increase : 0;
		increase *= max >= 0 ? max <= 64 ? max : 64 : 16;
		StringBuffer buf = new StringBuffer(text.length() + increase);
		do {
			if (end == -1)
				break;
			buf.append(text.substring(start, end)).append(replacement);
			start = end + replLength;
			if (--max == 0)
				break;
			end = text.indexOf(searchString, start);
		} while (true);
		buf.append(text.substring(start));
		return buf.toString();
	}

	public static String replaceEach(String text, String searchList[],
			String replacementList[]) {
		return replaceEach(text, searchList, replacementList, false, 0);
	}

	public static String replaceEachRepeatedly(String text,
			String searchList[], String replacementList[]) {
		int timeToLive = searchList != null ? searchList.length : 0;
		return replaceEach(text, searchList, replacementList, true, timeToLive);
	}

	private static String replaceEach(String text, String searchList[],
			String replacementList[], boolean repeat, int timeToLive) {
		if (text == null || text.length() == 0 || searchList == null
				|| searchList.length == 0 || replacementList == null
				|| replacementList.length == 0)
			return text;
		if (timeToLive < 0)
			throw new IllegalStateException("TimeToLive of " + timeToLive
					+ " is less than 0: " + text);
		int searchLength = searchList.length;
		int replacementLength = replacementList.length;
		if (searchLength != replacementLength)
			throw new IllegalArgumentException(
					"Search and Replace array lengths don't match: "
							+ searchLength + " vs " + replacementLength);
		boolean noMoreMatchesForReplIndex[] = new boolean[searchLength];
		int textIndex = -1;
		int replaceIndex = -1;
		int tempIndex = -1;
		for (int i = 0; i < searchLength; i++) {
			if (noMoreMatchesForReplIndex[i] || searchList[i] == null
					|| searchList[i].length() == 0
					|| replacementList[i] == null)
				continue;
			tempIndex = text.indexOf(searchList[i]);
			if (tempIndex == -1) {
				noMoreMatchesForReplIndex[i] = true;
				continue;
			}
			if (textIndex == -1 || tempIndex < textIndex) {
				textIndex = tempIndex;
				replaceIndex = i;
			}
		}

		if (textIndex == -1)
			return text;
		int start = 0;
		int increase = 0;
		for (int i = 0; i < searchList.length; i++) {
			int greater = replacementList[i].length() - searchList[i].length();
			if (greater > 0)
				increase += 3 * greater;
		}

		increase = Math.min(increase, text.length() / 5);
		StringBuffer buf = new StringBuffer(text.length() + increase);
		while (textIndex != -1) {
			int i;
			for (i = start; i < textIndex; i++)
				buf.append(text.charAt(i));

			buf.append(replacementList[replaceIndex]);
			start = textIndex + searchList[replaceIndex].length();
			textIndex = -1;
			replaceIndex = -1;
			tempIndex = -1;
			i = 0;
			while (i < searchLength) {
				if (!noMoreMatchesForReplIndex[i] && searchList[i] != null
						&& searchList[i].length() != 0
						&& replacementList[i] != null) {
					tempIndex = text.indexOf(searchList[i], start);
					if (tempIndex == -1)
						noMoreMatchesForReplIndex[i] = true;
					else if (textIndex == -1 || tempIndex < textIndex) {
						textIndex = tempIndex;
						replaceIndex = i;
					}
				}
				i++;
			}
		}
		int textLength = text.length();
		for (int i = start; i < textLength; i++)
			buf.append(text.charAt(i));

		String result = buf.toString();
		if (!repeat)
			return result;
		else
			return replaceEach(result, searchList, replacementList, repeat,
					timeToLive - 1);
	}

	public static String replaceChars(String str, char searchChar,
			char replaceChar) {
		if (str == null)
			return null;
		else
			return str.replace(searchChar, replaceChar);
	}

	public static String replaceChars(String str, String searchChars,
			String replaceChars) {
		if (isEmpty(str) || isEmpty(searchChars))
			return str;
		if (replaceChars == null)
			replaceChars = "";
		boolean modified = false;
		int replaceCharsLength = replaceChars.length();
		int strLength = str.length();
		StringBuffer buf = new StringBuffer(strLength);
		for (int i = 0; i < strLength; i++) {
			char ch = str.charAt(i);
			int index = searchChars.indexOf(ch);
			if (index >= 0) {
				modified = true;
				if (index < replaceCharsLength)
					buf.append(replaceChars.charAt(index));
			} else {
				buf.append(ch);
			}
		}

		if (modified)
			return buf.toString();
		else
			return str;
	}

	/**
	 * @deprecated Method overlayString is deprecated
	 */

	public static String overlayString(String text, String overlay, int start,
			int end) {
		return (new StringBuffer(
				((start + overlay.length() + text.length()) - end) + 1))
				.append(text.substring(0, start)).append(overlay).append(
						text.substring(end)).toString();
	}

	public static String overlay(String str, String overlay, int start, int end) {
		if (str == null)
			return null;
		if (overlay == null)
			overlay = "";
		int len = str.length();
		if (start < 0)
			start = 0;
		if (start > len)
			start = len;
		if (end < 0)
			end = 0;
		if (end > len)
			end = len;
		if (start > end) {
			int temp = start;
			start = end;
			end = temp;
		}
		return (new StringBuffer(((len + start) - end) + overlay.length() + 1))
				.append(str.substring(0, start)).append(overlay).append(
						str.substring(end)).toString();
	}

	public static String chomp(String str) {
		if (isEmpty(str))
			return str;
		if (str.length() == 1) {
			char ch = str.charAt(0);
			if (ch == '\r' || ch == '\n')
				return "";
			else
				return str;
		}
		int lastIdx = str.length() - 1;
		char last = str.charAt(lastIdx);
		if (last == '\n') {
			if (str.charAt(lastIdx - 1) == '\r')
				lastIdx--;
		} else if (last != '\r')
			lastIdx++;
		return str.substring(0, lastIdx);
	}

	public static String chomp(String str, String separator) {
		if (isEmpty(str) || separator == null)
			return str;
		if (str.endsWith(separator))
			return str.substring(0, str.length() - separator.length());
		else
			return str;
	}

	/**
	 * @deprecated Method chompLast is deprecated
	 */

	public static String chompLast(String str) {
		return chompLast(str, "\n");
	}

	/**
	 * @deprecated Method chompLast is deprecated
	 */

	public static String chompLast(String str, String sep) {
		if (str.length() == 0)
			return str;
		String sub = str.substring(str.length() - sep.length());
		if (sep.equals(sub))
			return str.substring(0, str.length() - sep.length());
		else
			return str;
	}

	/**
	 * @deprecated Method getChomp is deprecated
	 */

	public static String getChomp(String str, String sep) {
		int idx = str.lastIndexOf(sep);
		if (idx == str.length() - sep.length())
			return sep;
		if (idx != -1)
			return str.substring(idx);
		else
			return "";
	}

	/**
	 * @deprecated Method prechomp is deprecated
	 */

	public static String prechomp(String str, String sep) {
		int idx = str.indexOf(sep);
		if (idx == -1)
			return str;
		else
			return str.substring(idx + sep.length());
	}

	/**
	 * @deprecated Method getPrechomp is deprecated
	 */

	public static String getPrechomp(String str, String sep) {
		int idx = str.indexOf(sep);
		if (idx == -1)
			return "";
		else
			return str.substring(0, idx + sep.length());
	}

	public static String chop(String str) {
		if (str == null)
			return null;
		int strLen = str.length();
		if (strLen < 2)
			return "";
		int lastIdx = strLen - 1;
		String ret = str.substring(0, lastIdx);
		char last = str.charAt(lastIdx);
		if (last == '\n' && ret.charAt(lastIdx - 1) == '\r')
			return ret.substring(0, lastIdx - 1);
		else
			return ret;
	}

	/**
	 * @deprecated Method chopNewline is deprecated
	 */

	public static String chopNewline(String str) {
		int lastIdx = str.length() - 1;
		if (lastIdx <= 0)
			return "";
		char last = str.charAt(lastIdx);
		if (last == '\n') {
			if (str.charAt(lastIdx - 1) == '\r')
				lastIdx--;
		} else {
			lastIdx++;
		}
		return str.substring(0, lastIdx);
	}

	/**
	 * @deprecated Method escape is deprecated
	 */

	public static String escape(String str) {
		return StringEscapeUtils.escapeJava(str);
	}

	public static String repeat(String str, int repeat) {
		if (str == null)
			return null;
		if (repeat <= 0)
			return "";
		int inputLength = str.length();
		if (repeat == 1 || inputLength == 0)
			return str;
		if (inputLength == 1 && repeat <= 8192)
			return padding(repeat, str.charAt(0));
		int outputLength = inputLength * repeat;
		switch (inputLength) {
		case 1: // '\001'
			char ch = str.charAt(0);
			char output1[] = new char[outputLength];
			for (int i = repeat - 1; i >= 0; i--)
				output1[i] = ch;

			return new String(output1);

		case 2: // '\002'
			char ch0 = str.charAt(0);
			char ch1 = str.charAt(1);
			char output2[] = new char[outputLength];
			for (int i = repeat * 2 - 2; i >= 0; i--) {
				output2[i] = ch0;
				output2[i + 1] = ch1;
				i--;
			}

			return new String(output2);
		}
		StringBuffer buf = new StringBuffer(outputLength);
		for (int i = 0; i < repeat; i++)
			buf.append(str);

		return buf.toString();
	}

	private static String padding(int repeat, char padChar)
			throws IndexOutOfBoundsException {
		if (repeat < 0)
			throw new IndexOutOfBoundsException(
					"Cannot pad a negative amount: " + repeat);
		char buf[] = new char[repeat];
		for (int i = 0; i < buf.length; i++)
			buf[i] = padChar;

		return new String(buf);
	}

	public static String rightPad(String str, int size) {
		return rightPad(str, size, ' ');
	}

	public static String rightPad(String str, int size, char padChar) {
		if (str == null)
			return null;
		int pads = size - str.length();
		if (pads <= 0)
			return str;
		if (pads > 8192)
			return rightPad(str, size, String.valueOf(padChar));
		else
			return str.concat(padding(pads, padChar));
	}

	public static String rightPad(String str, int size, String padStr) {
		if (str == null)
			return null;
		if (isEmpty(padStr))
			padStr = " ";
		int padLen = padStr.length();
		int strLen = str.length();
		int pads = size - strLen;
		if (pads <= 0)
			return str;
		if (padLen == 1 && pads <= 8192)
			return rightPad(str, size, padStr.charAt(0));
		if (pads == padLen)
			return str.concat(padStr);
		if (pads < padLen)
			return str.concat(padStr.substring(0, pads));
		char padding[] = new char[pads];
		char padChars[] = padStr.toCharArray();
		for (int i = 0; i < pads; i++)
			padding[i] = padChars[i % padLen];

		return str.concat(new String(padding));
	}

	public static String leftPad(String str, int size) {
		return leftPad(str, size, ' ');
	}

	public static String leftPad(String str, int size, char padChar) {
		if (str == null)
			return null;
		int pads = size - str.length();
		if (pads <= 0)
			return str;
		if (pads > 8192)
			return leftPad(str, size, String.valueOf(padChar));
		else
			return padding(pads, padChar).concat(str);
	}

	public static String leftPad(String str, int size, String padStr) {
		if (str == null)
			return null;
		if (isEmpty(padStr))
			padStr = " ";
		int padLen = padStr.length();
		int strLen = str.length();
		int pads = size - strLen;
		if (pads <= 0)
			return str;
		if (padLen == 1 && pads <= 8192)
			return leftPad(str, size, padStr.charAt(0));
		if (pads == padLen)
			return padStr.concat(str);
		if (pads < padLen)
			return padStr.substring(0, pads).concat(str);
		char padding[] = new char[pads];
		char padChars[] = padStr.toCharArray();
		for (int i = 0; i < pads; i++)
			padding[i] = padChars[i % padLen];

		return (new String(padding)).concat(str);
	}

	public static int length(String str) {
		return str != null ? str.length() : 0;
	}

	public static String center(String str, int size) {
		return center(str, size, ' ');
	}

	public static String center(String str, int size, char padChar) {
		if (str == null || size <= 0)
			return str;
		int strLen = str.length();
		int pads = size - strLen;
		if (pads <= 0) {
			return str;
		} else {
			str = leftPad(str, strLen + pads / 2, padChar);
			str = rightPad(str, size, padChar);
			return str;
		}
	}

	public static String center(String str, int size, String padStr) {
		if (str == null || size <= 0)
			return str;
		if (isEmpty(padStr))
			padStr = " ";
		int strLen = str.length();
		int pads = size - strLen;
		if (pads <= 0) {
			return str;
		} else {
			str = leftPad(str, strLen + pads / 2, padStr);
			str = rightPad(str, size, padStr);
			return str;
		}
	}

	public static String upperCase(String str) {
		if (str == null)
			return null;
		else
			return str.toUpperCase();
	}

	public static String lowerCase(String str) {
		if (str == null)
			return null;
		else
			return str.toLowerCase();
	}

	public static String capitalize(String str) {
		int strLen;
		if (str == null || (strLen = str.length()) == 0)
			return str;
		else
			return (new StringBuffer(strLen)).append(
					Character.toTitleCase(str.charAt(0))).append(
					str.substring(1)).toString();
	}

	/**
	 * @deprecated Method capitalise is deprecated
	 */

	public static String capitalise(String str) {
		return capitalize(str);
	}

	public static String uncapitalize(String str) {
		int strLen;
		if (str == null || (strLen = str.length()) == 0)
			return str;
		else
			return (new StringBuffer(strLen)).append(
					Character.toLowerCase(str.charAt(0))).append(
					str.substring(1)).toString();
	}

	/**
	 * @deprecated Method uncapitalise is deprecated
	 */

	public static String uncapitalise(String str) {
		return uncapitalize(str);
	}

	public static String swapCase(String str) {
		int strLen;
		if (str == null || (strLen = str.length()) == 0)
			return str;
		StringBuffer buffer = new StringBuffer(strLen);
		char ch = '\0';
		for (int i = 0; i < strLen; i++) {
			ch = str.charAt(i);
			if (Character.isUpperCase(ch))
				ch = Character.toLowerCase(ch);
			else if (Character.isTitleCase(ch))
				ch = Character.toLowerCase(ch);
			else if (Character.isLowerCase(ch))
				ch = Character.toUpperCase(ch);
			buffer.append(ch);
		}

		return buffer.toString();
	}

	/**
	 * @deprecated Method capitaliseAllWords is deprecated
	 */

	public static String capitaliseAllWords(String str) {
		return WordUtils.capitalize(str);
	}

	public static int countMatches(String str, String sub) {
		if (isEmpty(str) || isEmpty(sub))
			return 0;
		int count = 0;
		for (int idx = 0; (idx = str.indexOf(sub, idx)) != -1; idx += sub
				.length())
			count++;

		return count;
	}

	public static boolean isAlpha(String str) {
		if (str == null)
			return false;
		int sz = str.length();
		for (int i = 0; i < sz; i++)
			if (!Character.isLetter(str.charAt(i)))
				return false;

		return true;
	}

	public static boolean isAlphaSpace(String str) {
		if (str == null)
			return false;
		int sz = str.length();
		for (int i = 0; i < sz; i++)
			if (!Character.isLetter(str.charAt(i)) && str.charAt(i) != ' ')
				return false;

		return true;
	}

	public static boolean isAlphanumeric(String str) {
		if (str == null)
			return false;
		int sz = str.length();
		for (int i = 0; i < sz; i++)
			if (!Character.isLetterOrDigit(str.charAt(i)))
				return false;

		return true;
	}

	public static boolean isAlphanumericSpace(String str) {
		if (str == null)
			return false;
		int sz = str.length();
		for (int i = 0; i < sz; i++)
			if (!Character.isLetterOrDigit(str.charAt(i))
					&& str.charAt(i) != ' ')
				return false;

		return true;
	}

	public static boolean isAsciiPrintable(String str) {
		if (str == null)
			return false;
		int sz = str.length();
		for (int i = 0; i < sz; i++)
			if (!CharUtils.isAsciiPrintable(str.charAt(i)))
				return false;

		return true;
	}

	public static boolean isNumeric(String str) {
		if (str == null)
			return false;
		int sz = str.length();
		for (int i = 0; i < sz; i++)
			if (!Character.isDigit(str.charAt(i)))
				return false;

		return true;
	}

	public static boolean isNumericSpace(String str) {
		if (str == null)
			return false;
		int sz = str.length();
		for (int i = 0; i < sz; i++)
			if (!Character.isDigit(str.charAt(i)) && str.charAt(i) != ' ')
				return false;

		return true;
	}

	public static boolean isWhitespace(String str) {
		if (str == null)
			return false;
		int sz = str.length();
		for (int i = 0; i < sz; i++)
			if (!Character.isWhitespace(str.charAt(i)))
				return false;

		return true;
	}

	public static String defaultString(String str) {
		return str != null ? str : "";
	}

	public static String defaultString(String str, String defaultStr) {
		return str != null ? str : defaultStr;
	}

	public static String defaultIfEmpty(String str, String defaultStr) {
		return isEmpty(str) ? defaultStr : str;
	}

	public static String reverse(String str) {
		if (str == null)
			return null;
		else
			return (new StringBuffer(str)).reverse().toString();
	}

	public static String reverseDelimited(String str, char separatorChar) {
		if (str == null) {
			return null;
		} else {
			String strs[] = split(str, separatorChar);
			ArrayUtils.reverse(strs);
			return join(strs, separatorChar);
		}
	}

	/**
	 * @deprecated Method reverseDelimitedString is deprecated
	 */

	public static String reverseDelimitedString(String str,
			String separatorChars) {
		if (str == null)
			return null;
		String strs[] = split(str, separatorChars);
		ArrayUtils.reverse(strs);
		if (separatorChars == null)
			return join(strs, ' ');
		else
			return join(strs, separatorChars);
	}

	public static String abbreviate(String str, int maxWidth) {
		return abbreviate(str, 0, maxWidth);
	}

	public static String abbreviate(String str, int offset, int maxWidth) {
		if (str == null)
			return null;
		if (maxWidth < 4)
			throw new IllegalArgumentException(
					"Minimum abbreviation width is 4");
		if (str.length() <= maxWidth)
			return str;
		if (offset > str.length())
			offset = str.length();
		if (str.length() - offset < maxWidth - 3)
			offset = str.length() - (maxWidth - 3);
		if (offset <= 4)
			return str.substring(0, maxWidth - 3) + "...";
		if (maxWidth < 7)
			throw new IllegalArgumentException(
					"Minimum abbreviation width with offset is 7");
		if (offset + (maxWidth - 3) < str.length())
			return "..." + abbreviate(str.substring(offset), maxWidth - 3);
		else
			return "..." + str.substring(str.length() - (maxWidth - 3));
	}

	public static String difference(String str1, String str2) {
		if (str1 == null)
			return str2;
		if (str2 == null)
			return str1;
		int at = indexOfDifference(str1, str2);
		if (at == -1)
			return "";
		else
			return str2.substring(at);
	}

	public static int indexOfDifference(String str1, String str2) {
		if (str1 == str2)
			return -1;
		if (str1 == null || str2 == null)
			return 0;
		int i;
		for (i = 0; i < str1.length() && i < str2.length()
				&& str1.charAt(i) == str2.charAt(i); i++)
			;
		if (i < str2.length() || i < str1.length())
			return i;
		else
			return -1;
	}

	public static int indexOfDifference(String strs[]) {
		if (strs == null || strs.length <= 1)
			return -1;
		boolean anyStringNull = false;
		boolean allStringsNull = true;
		int arrayLen = strs.length;
		int shortestStrLen = 2147483647;
		int longestStrLen = 0;
		for (int i = 0; i < arrayLen; i++)
			if (strs[i] == null) {
				anyStringNull = true;
				shortestStrLen = 0;
			} else {
				allStringsNull = false;
				shortestStrLen = Math.min(strs[i].length(), shortestStrLen);
				longestStrLen = Math.max(strs[i].length(), longestStrLen);
			}

		if (allStringsNull || longestStrLen == 0 && !anyStringNull)
			return -1;
		if (shortestStrLen == 0)
			return 0;
		int firstDiff = -1;
		int stringPos = 0;
		do {
			if (stringPos >= shortestStrLen)
				break;
			char comparisonChar = strs[0].charAt(stringPos);
			int arrayPos = 1;
			do {
				if (arrayPos >= arrayLen)
					break;
				if (strs[arrayPos].charAt(stringPos) != comparisonChar) {
					firstDiff = stringPos;
					break;
				}
				arrayPos++;
			} while (true);
			if (firstDiff != -1)
				break;
			stringPos++;
		} while (true);
		if (firstDiff == -1 && shortestStrLen != longestStrLen)
			return shortestStrLen;
		else
			return firstDiff;
	}

	public static String getCommonPrefix(String strs[]) {
		if (strs == null || strs.length == 0)
			return "";
		int smallestIndexOfDiff = indexOfDifference(strs);
		if (smallestIndexOfDiff == -1)
			if (strs[0] == null)
				return "";
			else
				return strs[0];
		if (smallestIndexOfDiff == 0)
			return "";
		else
			return strs[0].substring(0, smallestIndexOfDiff);
	}

	public static int getLevenshteinDistance(String s, String t) {
		if (s == null || t == null)
			throw new IllegalArgumentException("Strings must not be null");
		int n = s.length();
		int m = t.length();
		if (n == 0)
			return m;
		if (m == 0)
			return n;
		if (n > m) {
			String tmp = s;
			s = t;
			t = tmp;
			n = m;
			m = t.length();
		}
		int p[] = new int[n + 1];
		int d[] = new int[n + 1];
		for (int i = 0; i <= n; i++)
			p[i] = i;

		for (int j = 1; j <= m; j++) {
			char t_j = t.charAt(j - 1);
			d[0] = j;
			for (int i = 1; i <= n; i++) {
				int cost = s.charAt(i - 1) != t_j ? 1 : 0;
				d[i] = Math.min(Math.min(d[i - 1] + 1, p[i] + 1), p[i - 1]
						+ cost);
			}

			int _d[] = p;
			p = d;
			d = _d;
		}

		return p[n];
	}

	public static boolean startsWith(String str, String prefix) {
		return startsWith(str, prefix, false);
	}

	public static boolean startsWithIgnoreCase(String str, String prefix) {
		return startsWith(str, prefix, true);
	}

	private static boolean startsWith(String str, String prefix,
			boolean ignoreCase) {
		if (str == null || prefix == null)
			return str == null && prefix == null;
		if (prefix.length() > str.length())
			return false;
		else
			return str.regionMatches(ignoreCase, 0, prefix, 0, prefix.length());
	}

	public static boolean endsWith(String str, String suffix) {
		return endsWith(str, suffix, false);
	}

	public static boolean endsWithIgnoreCase(String str, String suffix) {
		return endsWith(str, suffix, true);
	}

	private static boolean endsWith(String str, String suffix,
			boolean ignoreCase) {
		if (str == null || suffix == null)
			return str == null && suffix == null;
		if (suffix.length() > str.length()) {
			return false;
		} else {
			int strOffset = str.length() - suffix.length();
			return str.regionMatches(ignoreCase, strOffset, suffix, 0, suffix
					.length());
		}
	}

	public static final String EMPTY = "";

	public static final int INDEX_NOT_FOUND = -1;

	private static final int PAD_LIMIT = 8192;

	public static String processLong(Long date) {
		if (date == null)
			return "";
		try {
			return (new StringBuilder()).append(date).toString();
		} catch (Exception e) {
			return date.toString();
		}
	}

	public static Long processLong(String str) {
		try {
			return new Long(str);
		} catch (Exception e) {
			return new Long(-1L);
		}
	}

	public static String processNull(Date date) {
		return date != null ? date.toString() : "";
	}

	public static String processNull(float value) {
		return (double) value != 0.0D ? (new StringBuilder(String
				.valueOf(value))).toString() : "";
	}

	public static String processNull(Long value) {
		return value != null ? value.toString() : "";
	}

	public static String processNull(Object value) {
		return value != null ? value.toString() : "";
	}

	public static String processNull(String str) {
		return str != null ? str : "";
	}

	public static String processSpace(String str) {
		return str != null ? str : "&nbsp;";
	}

	public static String queryDateString(String column, String expression,
			Date date) {
		String hql = "";
		if (StringUtils.isEmpty(column) || StringUtils.isEmpty(expression)
				|| null == date) {
			return hql;
		}
		hql = " to_char(" + column + ",'yyyymmdd hh24:mi:ss') " + expression
				+ " to_char('" + date + "','yyyymmdd hh24:mi:ss')";
		return hql;
	}

	public static String queryDateString(String column, String expression,
			String date) {
		String hql = "";
		if (StringUtils.isEmpty(column) || StringUtils.isEmpty(expression)
				|| StringUtils.isEmpty(date)) {
			return hql;
		}
		hql = " to_char(" + column + ",'yyyymmdd hh24:mi:ss') " + expression
				+ " to_char(to_date('" + date
				+ "','yyyymmdd hh24:mi:ss'),'yyyymmdd hh24:mi:ss')";
		return hql;
	}

	public static String replaces(String str, String oldStr, String newStr) {
		if (str != null) {
			int index = 0;
			int oldLen = oldStr.length();
			if (oldLen <= 0)
				return str;
			int newLen = newStr.length();
			do {
				index = str.indexOf(oldStr, index);
				if (index == -1)
					return str;
				str = (new StringBuilder(String
						.valueOf(str.substring(0, index)))).append(newStr)
						.append(str.substring(index + oldLen)).toString();
				index += newLen;
			} while (true);
		} else {
			return "";
		}
	}

	/**
	 * 转义页面输入的特殊符号
	 * 
	 * @param str
	 * @return
	 */
	public static String replaceHtml(String str) {
		if (null == str) {
			return "";
		}
		str = StringUtils.replace(str, "&", "&amp;");
		str = StringUtils.replace(str, "'", "&apos;");
		str = StringUtils.replace(str, "\"", "&quot;");
		str = StringUtils.replace(str, "\n", "<br>");
		str = StringUtils.replace(str, "\t", "&nbsp;&nbsp;");// 替换跳格
		str = StringUtils.replace(str, " ", "&nbsp;");// 替换空格
		return str;
	}

	/**
	 * 反向转义页面输入的特殊符号
	 * 
	 * @param str
	 * @return
	 */
	public static String reReplaceHtml(String str) {
		if (null == str) {
			return "";
		}
		str = StringUtils.replace(str, "&amp;", "&");
		str = StringUtils.replace(str, "&apos;", "'");
		str = StringUtils.replace(str, "&quot;", "\"");
		str = StringUtils.replace(str, "<br>", "\n");
		str = StringUtils.replace(str, "&nbsp;&nbsp;", "\t");// 替换跳格
		str = StringUtils.replace(str, "&nbsp;", " ");// 替换空格
		return str;
	}

	/**
	 * 去除字符串右边的空格
	 * 
	 * @param str
	 * @return
	 */
	public static String rightTrim(String str) {
		String regex = "(.*\\S+)(\\s+$)";
		Pattern p = Pattern.compile(regex);
		Matcher m = p.matcher(str);
		if (m.matches()) {
			str = m.group(1);
		}
		return str;
	}

	public static double round(double from, int num) {
		if (num < 1) {
			return from;
		} else {
			BigDecimal b = new BigDecimal(from);
			double to = b.setScale(num, 4).doubleValue();
			return to;
		}
	}

	/**
	 * SHA加密方式
	 * 
	 * @param newPass
	 * @return
	 */
	public static String setPassword(String newPass) {
		try {
			MessageDigest md;
			ByteArrayOutputStream bos;
			md = MessageDigest.getInstance("SHA");
			byte[] digest = md.digest(newPass.getBytes("iso-8859-1"));
			bos = new ByteArrayOutputStream();
			OutputStream encodedStream = MimeUtility.encode(bos, "base64");
			encodedStream.write(digest);
			return bos.toString("iso-8859-1");
		} catch (Exception e) {
			return null;
		}
	}

	public static String strToHtml(String str) {
		return strToHtml(str, true);
	}

	public static String strToHtml(String str, boolean supportHtml) {
		if (str == null)
			return "";
		str = replace(str, " ", "&nbsp;");
		str = replace(str, "\n", "<br>");
		if (!supportHtml) {
			str = replace(str, "&", "&amp;");
			str = replace(str, "<", "&lt;");
		}
		return str;
	}

	public static String strToShow(String str, String showstr) {
		if (str == null)
			return "";
		str = replace(str, " ", "&nbsp;");
		str = replace(str, "\n", "<br>");
		if (!showstr.equals("")) {
			String repstr = (new StringBuilder("<font color=green><b>"))
					.append(showstr).append("</b></font>").toString();
			str = replace(str, showstr, repstr);
		}
		return str;
	}

	public static String strtoUTF8(String src) {
		try {
			return URLEncoder.encode(src, "UTF-8");
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
		return src;
	}

	public static String tensileString(String str, int len, boolean pre,
			String addStr) {
		if (str == null) {
			return null;
		}
		if (str.length() >= len) {
			return str.substring(0, len);
		}
		while (str.length() < len)
			if (pre) {
				str = (new StringBuilder(String.valueOf(addStr))).append(str)
						.toString();
			} else {
				str = (new StringBuilder(String.valueOf(str))).append(addStr)
						.toString();
			}
		if (pre) {
			str = str.substring(str.length() - len, str.length());
		} else {
			str = str.substring(0, len);
		}
		return str;
	}

	{// 初始化
		for (int i = 0; i < 27; ++i) {
			table[i] = gbValue(chartable[i]);
		}
	}
	public static String checkStr(String inputStr) {
		String error = "";
		if (null != inputStr && !"".equals(inputStr.trim())) {
			char c;
			for (int i = 0; i < inputStr.length(); i++) {
				c = inputStr.charAt(i);
				if (c == '"') {
					error += " 特殊字符[\"]";
				}
				if (c == '\'') {
					error += " 特殊字符[']";
				}
				if (c == '<') {
					error += " 特殊字符[<]";
				}
				if (c == '>') {
					error += " 特殊字符[>]";
				}
				if (c == '&') {
					error += " 特殊字符[&]";
				}
				if (c == '%') {
					error += " 特殊字符[%]";
				}
				if (c == ';') {
					error += " 特殊字符[;]";
				}
				if (c == '|') {
					error += " 特殊字符[|]";
				}
				if (c == '(') {
					error += " 特殊字符[(]";
				}
				if (c == ')') {
					error += " 特殊字符[)]";
				}
				if (c == '+') {
					error += " 特殊字符[+]";
				}
				if (c == '=') {
					error += " 特殊字符[=]";
				}
				if (c == '}') {
					error += " 特殊字符[}]";
				}
				if (c == '{') {
					error += " 特殊字符[{]";
				}
				//if (c == '.') {
				//	error += " 特殊字符[.]";
				//}
			}
			if (inputStr.toLowerCase().contains("script")) {
				error += " 特殊字符[script]";
			}
			if (inputStr.toLowerCase().contains("eval")) {
				error += " 特殊字符[eval]";
			}
			if (inputStr.toLowerCase().contains("lf")) {
				error += " 特殊字符[LF]";
			}
			if (inputStr.toLowerCase().contains("cr")) {
				error += " 特殊字符[CR]";
			}
			if (inputStr.toLowerCase().contains("div")) {
				error += " 特殊字符[div]";
			}
			if (inputStr.toLowerCase().contains("iframe")) {
				error += " 特殊字符[iframe]";
			}	
			if (inputStr.toLowerCase().contains("img")) {
				error += " 特殊字符[img]";
			}
			if (inputStr.toLowerCase().contains("onmouse")) {
				error += " 特殊字符[onmouse]";
			}
			if (inputStr.toLowerCase().contains("cr")) {
				error += " 特殊字符[CR]";
			}
			if (inputStr.toLowerCase().contains("insert")) {
				error += " 特殊字符[insert]";
			}
			if (inputStr.toLowerCase().contains("update")) {
				error += " 特殊字符[update]";
			}	
			if (inputStr.toLowerCase().contains("delete")) {
				error += " 特殊字符[delete]";
			}
			if (inputStr.toLowerCase().contains("select")) {
				error += " 特殊字符[select]";
			}
			if (inputStr.toLowerCase().contains("and")) {
				error += " 特殊字符[and]";
			}
			if (inputStr.toLowerCase().contains("exec")) {
				error += " 特殊字符[exec]";
			}
			if (inputStr.toLowerCase().contains("truncate")) {
				error += " 特殊字符[truncate]";
			}
			if (inputStr.toLowerCase().contains("declare")) {
				error += " 特殊字符[declare]";
			}
			if (inputStr.toLowerCase().contains("length")) {
				error += " 特殊字符[length]";
			}
			if (inputStr.toLowerCase().contains("drop")) {
				error += " 特殊字符[drop]";
			}
			
			
		}
		return error;
	}
	
	public static String checkPwd(String inputStr) {
		String error = "";
		if (null != inputStr && !"".equals(inputStr.trim())) {
			char c;
			for (int i = 0; i < inputStr.length(); i++) {
				c = inputStr.charAt(i);
				if (c == '"') {
					error += " 特殊字符[\"]";
				}
				if (c == '\'') {
					error += " 特殊字符[']";
				}
				if (c == '<') {
					error += " 特殊字符[<]";
				}
				if (c == '>') {
					error += " 特殊字符[>]";
				}
				if (c == '&') {
					error += " 特殊字符[&]";
				}
				if (c == '%') {
					error += " 特殊字符[%]";
				}
				if (c == ';') {
					error += " 特殊字符[;]";
				}
				if (c == '|') {
					error += " 特殊字符[|]";
				}
				if (c == '(') {
					error += " 特殊字符[(]";
				}
				if (c == ')') {
					error += " 特殊字符[)]";
				}
				if (c == '+') {
					error += " 特殊字符[+]";
				}
				if (c == '=') {
					error += " 特殊字符[=]";
				}
				if (c == '}') {
					error += " 特殊字符[}]";
				}
				if (c == '{') {
					error += " 特殊字符[{]";
				}
				if (c == '^') {
					error += " 特殊字符[^]";
				}
			
			}
			if (inputStr.toLowerCase().contains("script")) {
				error += " 特殊字符[script]";
			}
			if (inputStr.toLowerCase().contains("eval")) {
				error += " 特殊字符[eval]";
			}
			
			if (inputStr.toLowerCase().contains("onmouse")) {
				error += " 特殊字符[onmouse]";
			}

			if (inputStr.toLowerCase().contains("insert")) {
				error += " 特殊字符[insert]";
			}
			if (inputStr.toLowerCase().contains("update")) {
				error += " 特殊字符[update]";
			}	
			if (inputStr.toLowerCase().contains("delete")) {
				error += " 特殊字符[delete]";
			}
			if (inputStr.toLowerCase().contains("select")) {
				error += " 特殊字符[select]";
			}
			if (inputStr.toLowerCase().contains("from")) {
				error += " 特殊字符[from]";
			}
			if (inputStr.toLowerCase().contains("and")) {
				error += " 特殊字符[and]";
			}
			if (inputStr.toLowerCase().contains("exec")) {
				error += " 特殊字符[exec]";
			}
			if (inputStr.toLowerCase().contains("truncate")) {
				error += " 特殊字符[truncate]";
			}
			if (inputStr.toLowerCase().contains("declare")) {
				error += " 特殊字符[declare]";
			}
			if (inputStr.toLowerCase().contains("length")) {
				error += " 特殊字符[length]";
			}
			if (inputStr.toLowerCase().contains("table")) {
				error += " 特殊字符[table]";
			}
			if (inputStr.toLowerCase().contains("dual")) {
				error += " 特殊字符[dual]";
			}
			if (inputStr.toLowerCase().contains("char")) {
				error += " 特殊字符[char]";
			}
			if (inputStr.toLowerCase().contains("drop")) {
				error += " 特殊字符[drop]";
			}
		}
		return error;
	}
	/**
	 * 填充字符
	 * 
	 * @param source
	 *            源字符串
	 * @param fillChar
	 *            填充字符
	 * @param len
	 *            填充到的长度
	 * @return 填充后的字符串
	 */
	public static String fillLeft(String source, char fillChar, long len) {
		StringBuffer ret = new StringBuffer();
		if (null == source)
			ret.append("");
		if (source.length() > len) {
			ret.append(source);
		} else {
			long slen = source.length();
			while (ret.toString().length() + slen < len) {
				ret.append(fillChar);
			}
			ret.append(source);
		}
		return ret.toString();
	}

	public static String filterStr(String str) {
		if (null == str || "".equals(str)) {
			return str;
		}
		str = str.replaceAll("'", "''");
		return str;
	}
	
	public static List str2List(String str,String splitStr){
		List l=new ArrayList();
		if (null == str || "".equals(str)) {
			return l;
		}
		String [] s=str.split(splitStr);
		for (int i=0;i<s.length;i++){
			l.add(s[i].toString());
		}
		return l;
	}

}
