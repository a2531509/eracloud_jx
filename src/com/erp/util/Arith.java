package com.erp.util;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.NumberFormat;

public class Arith {
	private Arith()
    {
    }

    public static double add(double v1, double v2)
    {
        BigDecimal b1 = new BigDecimal(Double.toString(v1));
        BigDecimal b2 = new BigDecimal(Double.toString(v2));
        return b1.add(b2).doubleValue();
    }

    public static double add(Double v1, Double v2)
    {
        BigDecimal b1 = new BigDecimal(v1.doubleValue());
        BigDecimal b2 = new BigDecimal(v2.doubleValue());
        return b1.add(b2).doubleValue();
    }

    public static double sub(double v1, double v2)
    {
        BigDecimal b1 = new BigDecimal(Double.toString(v1));
        BigDecimal b2 = new BigDecimal(Double.toString(v2));
        return b1.subtract(b2).doubleValue();
    }

    public static double sub(Double v1, Double v2)
    {
        BigDecimal b1 = new BigDecimal(v1.doubleValue());
        BigDecimal b2 = new BigDecimal(v2.doubleValue());
        return b1.subtract(b2).doubleValue();
    }

    public static double mul(double v1, double v2)
    {
        BigDecimal b1 = new BigDecimal(Double.toString(v1));
        BigDecimal b2 = new BigDecimal(Double.toString(v2));
        return b1.multiply(b2).doubleValue();
    }

    public static double mul(Double v1, Double v2)
    {
        BigDecimal b1 = new BigDecimal(v1.doubleValue());
        BigDecimal b2 = new BigDecimal(v2.doubleValue());
        return b1.multiply(b2).doubleValue();
    }

    public static double div(double v1, double v2)
    {
        return div(v1, v2, 10);
    }

    public static double div(Double v1, Double v2)
    {
        return div(v1, v2, 10);
    }

    public static double div(double v1, double v2, int scale)
    {
        if(scale < 0)
        {
            throw new IllegalArgumentException("The scale must be a positive integer or zero");
        } else
        {
            BigDecimal b1 = new BigDecimal(Double.toString(v1));
            BigDecimal b2 = new BigDecimal(Double.toString(v2));
            return b1.divide(b2, scale, 4).doubleValue();
        }
    }

    public static double div(Double v1, Double v2, int scale)
    {
        if(scale < 0)
        {
            throw new IllegalArgumentException("The scale must be a positive integer or zero");
        } else
        {
            BigDecimal b1 = new BigDecimal(v1.doubleValue());
            BigDecimal b2 = new BigDecimal(v2.doubleValue());
            return b1.divide(b2, scale, 4).doubleValue();
        }
    }

    public static double round(double v, int scale)
    {
        if(scale < 0)
        {
            throw new IllegalArgumentException("The scale must be a positive integer or zero");
        } else
        {
            BigDecimal b = new BigDecimal(Double.toString(v));
            BigDecimal one = new BigDecimal("1");
            return b.divide(one, scale, 4).doubleValue();
        }
    }

    public static double round(Double v, int scale)
    {
        if(scale < 0)
        {
            throw new IllegalArgumentException("The scale must be a positive integer or zero");
        } else
        {
            BigDecimal b = new BigDecimal(v.doubleValue());
            BigDecimal one = new BigDecimal("1");
            return b.divide(one, scale, 4).doubleValue();
        }
    }

    public static String add(String str1, String str2)
    {
        BigDecimal b1 = new BigDecimal(Tools.processNull(str1).equals("")?"0":str1);
        BigDecimal b2 = new BigDecimal(Tools.processNull(str2).equals("")?"0":str2);
        return b1.add(b2).toString();
    }
    
    public static String add(String str1, String str2, String str3)
    {
        BigDecimal b1 = new BigDecimal(Tools.processNull(str1).equals("")?"0":str1);
        BigDecimal b2 = new BigDecimal(Tools.processNull(str2).equals("")?"0":str2);
        BigDecimal b3 = new BigDecimal(Tools.processNull(str3).equals("")?"0":str3);
        return b1.add(b2).add(b3).toString();
    }

    public static String sub(String str1, String str2)
    {
        BigDecimal b1 = new BigDecimal(str1);
        BigDecimal b2 = new BigDecimal(str2);
        return b1.subtract(b2).toString();
    }

    public static String mul(String str1, String str2)
    {
        BigDecimal b1 = new BigDecimal(str1);
        BigDecimal b2 = new BigDecimal(str2);
        return b1.multiply(b2).toString();
    }

    public static String div(String str1, String str2)
    {
        BigDecimal b1 = new BigDecimal(str1);
        BigDecimal b2 = new BigDecimal(str2);
        return b1.divide(b2, 10, 4).toString();
    }

    public static String cardreportstomoney(String str1)
    {
        if(str1 == null || str1.equals(""))
            return " ";
        if(str1.endsWith(".0"))
            str1 = (new StringBuilder(String.valueOf(str1))).append("0").toString();
        if(str1.indexOf(".") == -1)
            str1 = (new StringBuilder(String.valueOf(str1))).append(".00").toString();
        return str1;
    }

    public static String cardreportsmoneymun(String str1)
    {
        if(str1 == null || str1.equals(""))
            return " ";
        BigDecimal b1 = new BigDecimal(str1);
        BigDecimal b2 = new BigDecimal("100");
        String result = b1.multiply(b2).toString();
        if(result.endsWith(".0"))
            result = (new StringBuilder(String.valueOf(result))).append("0").toString();
        if(result.indexOf(".") == -1)
            result = (new StringBuilder(String.valueOf(result))).append(".00").toString();
        return result;
    }

    public static String cardreportsmoneydiv(String str1)
    {
        if(str1 == null || str1.equals(""))
            return " ";
        BigDecimal b1 = new BigDecimal(str1);
        BigDecimal b2 = new BigDecimal("100");
        String result = b1.divide(b2, 2, 4).toString();
        if(result.endsWith(".0"))
            result = (new StringBuilder(String.valueOf(result))).append("0").toString();
        if(result.indexOf(".") == -1)
            result = (new StringBuilder(String.valueOf(result))).append(".00").toString();
        return result;
    }

    public static String cardmoneymun(String str1)
    {
        BigDecimal b1 = new BigDecimal(str1);
        BigDecimal b2 = new BigDecimal("100");
        String result = b1.multiply(b2).toString();
        if(result.endsWith(".00"))
            result = result.substring(0, result.indexOf(".00"));
        if(result.endsWith(".0"))
            result = result.substring(0, result.indexOf(".0"));
        return result;
    }

    public static String cardmoneydiv(String str1)
    {
        BigDecimal b1 = new BigDecimal(str1);
        BigDecimal b2 = new BigDecimal("100");
        String result = b1.divide(b2, 2, 4).toString();
        if(result.endsWith(".00"))
            result = result.substring(0, result.indexOf(".00"));
        if(result.endsWith(".0"))
            result = result.substring(0, result.indexOf(".0"));
        return result;
    }

    public static String thousandsSeparator(String str)
    {
        if(str == null)
            return "";
        char str_a[] = str.substring(0, str.indexOf(".") == -1 ? str.length() : str.indexOf(".")).toCharArray();
        String str_b = str.indexOf(".") == -1 ? "" : str.substring(str.indexOf("."), str.length());
        StringBuffer last_str = new StringBuffer("");
        if(str_a.length > 3)
        {
            last_str.append(str.substring(0, str_a.length % 3));
            if(!last_str.toString().equals(""))
                last_str.append(",");
            int i = str_a.length % 3;
            for(int j = 1; i < str_a.length; j++)
            {
                last_str.append(str_a[i]);
                if(j % 3 == 0 && i < str_a.length - 1)
                    last_str.append(",");
                i++;
            }

        } else
        {
            last_str.append(str_a);
        }
        last_str.append(str_b);
        return last_str.toString();
    }
    
    /**
	 * 金额格式化
	 * @param s 金额
	 * @param len 小数位数
	 * @return 格式后的金额
	 */

	public static String insertComma(String s, int len) {
	    if (s == null || s.length() < 1) {
	        return "";
	    }
	    NumberFormat formater = null;
	    double num = Double.parseDouble(s);
	    if (len == 0) {
	        formater = new DecimalFormat("###,###");
	    } else {
	        StringBuffer buff = new StringBuffer();
	        buff.append("###,##0.");
	        for (int i = 0; i < len; i++) {
	            buff.append("0");
	        }
	        formater = new DecimalFormat(buff.toString());
	    }
	    return formater.format(num);
	}

    private static final int DEF_DIV_SCALE = 10;
}
