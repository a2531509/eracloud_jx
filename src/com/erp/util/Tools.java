package com.erp.util;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.MessageDigest;
import java.text.DecimalFormat;
import java.util.Date;
import java.util.List;
import java.util.Properties;

import javax.servlet.ServletContext;

import com.erp.exception.CommonException;


public class Tools {
	public Tools()
    {
    }

    public static boolean parseBoolean(int value)
    {
        return value == 1;
    }

    public static boolean parseBoolean(String value)
    {
        return processNull(value).equals("true");
    }

    public static int parseInt(boolean value)
    {
        return !value ? 0 : 1;
    }

    public static String replace(String str, String oldStr, String newStr)
    {
        if(str != null)
        {
            int index = 0;
            int oldLen = oldStr.length();
            if(oldLen <= 0)
                return str;
            int newLen = newStr.length();
            do
            {
                index = str.indexOf(oldStr, index);
                if(index == -1)
                    return str;
                str = (new StringBuilder(String.valueOf(str.substring(0, index)))).append(newStr).append(str.substring(index + oldLen)).toString();
                index += newLen;
            } while(true);
        } else
        {
            return "";
        }
    }

    public static String strToHtml(String str, boolean supportHtml)
    {
        if(str == null)
            return "";
        str = replace(str, " ", "&nbsp;");
        str = replace(str, "\n", "<br>");
        if(!supportHtml)
        {
            str = replace(str, "&", "&amp;");
            str = replace(str, "<", "&lt;");
        }
        return str;
    }

    public static String strToShow(String str, String showstr)
    {
        if(str == null)
            return "";
        str = replace(str, " ", "&nbsp;");
        str = replace(str, "\n", "<br>");
        if(!showstr.equals(""))
        {
            String repstr = (new StringBuilder("<font color=green><b>")).append(showstr).append("</b></font>").toString();
            str = replace(str, showstr, repstr);
        }
        return str;
    }

    public static String strToHtml(String str)
    {
        return strToHtml(str, true);
    }

    public static String getWebDir(ServletContext application)
    {
        String strWebDir = application.getRealPath("/");
        return strWebDir;
    }

    public static String getPathSplit(ServletContext application)
    {
        String strWebDir = application.getRealPath("/");
        if(strWebDir.charAt(0) == '/')
            return "/";
        else
            return "\\";
    }

    public static String getSeparator()
    {
        Properties prop = new Properties(System.getProperties());
        return prop.getProperty("file.separator");
    }

    public static String processNull(String str)
    {
        return str != null ? str : "";
    }

    public static String processNull(Date date)
    {
        return date != null ? date.toString() : "";
    }

    public static String processNull(Long value)
    {
        return value != null ? value.toString() : "";
    }

    public static String processNull(Object value)
    {
        return value != null ? value.toString() : "";
    }

    public static String processNull(float value)
    {
        return (double)value != 0.0D ? (new StringBuilder(String.valueOf(value))).toString() : "";
    }

    public static String processSpace(String str)
    {
        return str != null ? str : "&nbsp;";
    }

    public static int processInt(String str)
    {
        try
        {
            return Integer.parseInt(str);
        }
        catch(Exception e)
        {
            return -1;
        }
    }

    public static String processLong(Long date)
    {
        if(date == null)
            return "";
        try
        {
            return (new StringBuilder()).append(date).toString();
        }
        catch(Exception e)
        {
            return date.toString();
        }
    }

    public static Long processLong(String str)
    {
        try
        {
            return new Long(str);
        }
        catch(Exception e)
        {
            return new Long(-1L);
        }
    }

    public static float processFloat(String str)
    {
        try
        {
            return Float.parseFloat(str);
        }
        catch(Exception e)
        {
            return 0.0F;
        }
    }

    public static String getMoney(double money)
    {
        DecimalFormat df = new DecimalFormat("###,##0.00");
        return df.format(money);
    }

    public static double round(double from, int num)
    {
        if(num < 1)
        {
            return from;
        } else
        {
            BigDecimal b = new BigDecimal(from);
            double to = b.setScale(num, 4).doubleValue();
            return to;
        }
    }

    public static int getStrLen(String instr)
    {
        if(instr == null)
            return 0;
        int Num = 0;
        int i = 0;
        char chr = ' ';
        for(i = 0; i < instr.length(); i++)
        {
            chr = instr.charAt(i);
            if(chr <= '~')
                Num++;
            else
                Num += 2;
        }

        return Num;
    }

    public static String tensileString(String str, int len, boolean pre, String addStr)
    {
        if(str == null)
            return null;
        if(str.length() >= len)
            return str.substring(0, len);
        while(str.length() < len) 
            if(pre)
                str = (new StringBuilder(String.valueOf(addStr))).append(str).toString();
            else
                str = (new StringBuilder(String.valueOf(str))).append(addStr).toString();
        if(pre)
            str = str.substring(str.length() - len, str.length());
        else
            str = str.substring(0, len);
        return str;
    }
    public static String tensileStringByByte(String str,int len,boolean pre,String addStr){
    	try{
    		if(str == null){
    			return null;
    		}
    		byte[] finalByteArray = new byte[len];
    		byte[] srcByteArray = str.getBytes("GBK");//原字节
    		int srcLen = srcByteArray.length;//原字节长度
    		int tempLen = srcLen;
    		byte[] addByteArray =  addStr.getBytes("GBK");//增加的字节
    		int addLen = addByteArray.length;//增加字节长度
    		byte[] finalByteArr = new byte[len];//最终字节数组
    		System.arraycopy(srcByteArray,0,finalByteArr,0,srcLen<len?srcLen:len);
    		if(srcLen < len){
    			int i__ = 0;
    			while(srcLen < len){
    				if(pre){
    					i__ ++;
    					System.arraycopy(addByteArray,0,finalByteArr,0,addLen);
    					System.arraycopy(srcByteArray,0,finalByteArr,addLen * i__,tempLen);
    				}else{
    					System.arraycopy(addByteArray,0,finalByteArr,srcLen,addLen);
    				}
    				srcLen += addLen;
    			}
    		}
    		if(pre){
    			System.arraycopy(finalByteArr,finalByteArr.length - len,finalByteArray,0,len);
    		}else{
    			System.arraycopy(finalByteArr,0,finalByteArray,0,len);
    		}
    		return new String(finalByteArray,"GBK");
    	}catch(Exception e){
    		throw new CommonException(e.getMessage());
    	}
    }

    public static String isoToGBK(String src)
    {
        String sDst = "";
        try
        {
            sDst = new String(src.getBytes("ISO8859_1"), "GBK");
        }
        catch(Exception e)
        {
            System.out.println(e.getMessage());
        }
        return sDst;
    }

    public static String gbkToISO(String src)
    {
        String sDst = "";
        try
        {
            sDst = new String(src.getBytes("GBK"), "ISO8859_1");
        }
        catch(Exception e)
        {
            System.out.println(e.getMessage());
        }
        return sDst;
    }

    public static String strtoUTF8(String src)
    {
        try
        {
            return URLEncoder.encode(src, "UTF-8");
        }
        catch(Exception e)
        {
            System.out.println(e.getMessage());
        }
        return src;
    }

    public static String UTF8tostr(String src)
    {
        try
        {
            return URLDecoder.decode(src, "UTF-8");
        }
        catch(Exception e)
        {
            System.out.println(e.getMessage());
        }
        return src;
    }

    public static String encode4URL(String s)
    {
        if(s == null || s.trim().length() == 0)
            return "";
        if(s.indexOf("=") < 0)
            return s;
        StringBuffer url = new StringBuffer();
        try
        {
            String temS[] = s.split("&");
            for(int i = 0; i < temS.length; i++)
            {
                String tem = temS[i].toString();
                if(tem != null && tem.trim().length() != 0)
                {
                    String ss[] = tem.split("=");
                    url.append(ss[0].toString()).append("=").append(URLEncoder.encode(ss[1], "UTF-8")).append("&");
                }
            }

        }
        catch(Exception e)
        {
            return s;
        }
        return url.toString();
    }

    public static String getConcatStrFromList(List list, String qhzf, String split)
    {
        StringBuffer sb = new StringBuffer();
        try
        {
            for(int i = 0; i < list.size(); i++)
                if(!processNull(list.get(i)).equals(""))
                    sb.append((new StringBuilder(String.valueOf(qhzf))).append(processNull(list.get(i)).trim()).append(qhzf).append(split).toString());

            if(sb.length() > 0)
                return sb.substring(0, sb.length() - 1);
        }
        catch(Exception e)
        {
            return "";
        }
        return sb.toString();
    }

    public static String getConcatStrFromList(List list, String split)
    {
        return getConcatStrFromList(list, "'", split);
    }

    public static String getConcatStrFromList(List list)
    {
        return getConcatStrFromList(list, ",");
    }

    public static String getConcatStrFromArray(String arr[], String qhzf, String split)
    {
        StringBuffer sb = new StringBuffer();
        try
        {
            for(int i = 0; i < arr.length; i++)
                if(!processNull(arr[i]).equals(""))
                    sb.append((new StringBuilder(String.valueOf(qhzf))).append(processNull(arr[i]).trim()).append(qhzf).append(split).toString());

            if(sb.length() > 0)
                return sb.substring(0, sb.length() - 1);
        }
        catch(Exception e)
        {
            return "";
        }
        return sb.toString();
    }

    public static String getConcatStrFromArray(String arr[], String split)
    {
        return getConcatStrFromArray(arr, "'", split);
    }

    public static String getConcatStrFromArray(String arr[])
    {
        return getConcatStrFromArray(arr, ",");
    }

    public static String getFieldFromObjcet(Object object)
    {
        StringBuffer str = new StringBuffer("{");
        try
        {
            Class classType = object.getClass();
            Field fields[] = classType.getDeclaredFields();
            for(int i = 0; i < fields.length; i++)
            {
                Field field = fields[i];
                String fieldName = field.getName();
                String getMethodName = (new StringBuilder("get")).append(fieldName.substring(0, 1).toUpperCase()).append(fieldName.substring(1)).toString();
                Method getMethod = classType.getMethod(getMethodName, new Class[0]);
                Object value = getMethod.invoke(object, new Object[0]);
                str.append((new StringBuilder("[")).append(fieldName).append(":").append(value).append("],").toString());
            }

            if(str.toString().length() > 1)
                str = new StringBuffer(str.toString().substring(0, str.toString().length() - 1));
            str.append("}");
        }
        catch(Exception exception) { }
        return str.toString();
    }

    public static Object getvalueByObject(Object o, String str)
        throws SecurityException, NoSuchMethodException, IllegalArgumentException, IllegalAccessException, InvocationTargetException
    {
        Method getMethod = o.getClass().getMethod((new StringBuilder("get")).append(str).toString(), new Class[0]);
        return getMethod.invoke(o, new Object[0]);
    }

    public static String getMD5(File file) throws Exception {
    	return getMD5(new BufferedInputStream(new FileInputStream(file)));
    }

    public static String getMD5(InputStream inputStream) throws Exception {
    	BufferedInputStream bufferedInputStream = null;
    	if (inputStream instanceof BufferedInputStream) {
    		bufferedInputStream = (BufferedInputStream) inputStream;
    	} else {
    		bufferedInputStream = new BufferedInputStream(inputStream);
    	}
    	MessageDigest messageDigest = MessageDigest.getInstance("MD5");
    	byte[] buffer = new byte[10240];
    	int length = 0;
    	while ((length = bufferedInputStream.read(buffer, 0, 10240)) != -1) {
    		messageDigest.update(buffer, 0, length);
    	}
    	BigInteger bigInteger = new BigInteger(1, messageDigest.digest());
    	return bigInteger.toString(16);
    }
    public static void main(String args[]) throws UnsupportedEncodingException
    {
    	System.err.println(Tools.tensileStringByByte("你好",10,false,"0"));
    	System.out.println("你好".getBytes("UTF-8").length);
    }

}
