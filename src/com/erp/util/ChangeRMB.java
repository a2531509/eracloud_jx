package com.erp.util;

import com.erp.exception.CommonException;


public class ChangeRMB {

    public ChangeRMB()
    {
    }

    public static String praseUpcaseRMB(String s)
    {
        if(s.equals("0.00"))
            return "\u96F6\u5706\u6574";
        StringBuilder stringbuilder = new StringBuilder("");
        if(s.indexOf(".") == -1)
            s = (new StringBuilder(String.valueOf(s))).append(".00").toString();
        if(s.substring(s.indexOf(".") + 1, s.length()).length() > 2)
            throw new CommonException("转换发生错误");
        if(s.substring(s.indexOf(".") + 1, s.length()).length() == 1)
            s = (new StringBuilder(String.valueOf(s))).append("0").toString();
        int i = s.length();
        String s1 = "";
        if(i > b.length)
        	throw new CommonException("转换发生错误");
        for(int j = 0; j < s.length(); j++)
        {
            int k;
            if(Tools.processNull(s.substring(j, j + 1)).equals("."))
            {
                if(stringbuilder.toString().equals("\u96F6"))
                    stringbuilder = new StringBuilder("");
                else
                if(stringbuilder.substring(stringbuilder.length() - 1, stringbuilder.length()).equals(a[0]))
                    stringbuilder = new StringBuilder((new StringBuilder(String.valueOf(stringbuilder.substring(0, stringbuilder.length() - 1)))).append("\u5706").toString());
            } else
            if((k = Integer.valueOf(Tools.processNull(s.substring(j, j + 1))).intValue()) == 0)
            {
                if(stringbuilder.length() > 0 && !stringbuilder.substring(stringbuilder.length() - 1, stringbuilder.length()).equals(a[0]))
                    stringbuilder.append(a[k]);
                else
                if(stringbuilder.length() == 0)
                    stringbuilder.append(a[k]);
            } else
            {
                if(stringbuilder.length() > 2 && s1.substring(s1.length() - 1, s1.length()).equals(b[(b.length - i) + j].substring(b[(b.length - i) + j].length() - 1, b[(b.length - i) + j].length())))
                    if(stringbuilder.substring(stringbuilder.length() - 1, stringbuilder.length()).equals(a[0]))
                    {
                        if(s1.length() == 3)
                            stringbuilder = new StringBuilder((new StringBuilder(String.valueOf(stringbuilder.substring(0, stringbuilder.length() - 3)))).append(a[0]).toString());
                        else
                            stringbuilder = new StringBuilder((new StringBuilder(String.valueOf(stringbuilder.substring(0, stringbuilder.length() - 2)))).append(a[0]).toString());
                    } else
                    if(s1.length() == 3)
                        stringbuilder = new StringBuilder(stringbuilder.substring(0, stringbuilder.length() - 2));
                    else
                        stringbuilder = new StringBuilder(stringbuilder.substring(0, stringbuilder.length() - 1));
                stringbuilder.append(a[k]);
                stringbuilder.append(b[(b.length - i) + j]);
                s1 = b[(b.length - i) + j];
            }
        }

        if(stringbuilder.substring(stringbuilder.length() - 1, stringbuilder.length()).equals(a[0]))
            stringbuilder = new StringBuilder(stringbuilder.substring(0, stringbuilder.length() - 1));
        if(stringbuilder.indexOf("\u89D2") == -1 && stringbuilder.indexOf("\u5206") == -1)
            if(stringbuilder.substring(stringbuilder.length() - 1, stringbuilder.length()).equals("\u5706"))
                stringbuilder.append("\u6574");
            else
                stringbuilder.append("\u5706\u6574");
        if(stringbuilder.length() == 3 && stringbuilder.substring(0, 1).equals("\u96F6") && stringbuilder.substring(2, 3).equals("\u5206"))
            stringbuilder = new StringBuilder(stringbuilder.substring(1, 3));
        return stringbuilder.toString();
    }

    public static void main(String args[])
    {
        System.out.println(praseUpcaseRMB("12345678901234567890.68"));
    }

    private static final String a[] = {
        "\u96F6", "\u58F9", "\u8D30", "\u53C1", "\u8086", "\u4F0D", "\u9646", "\u67D2", "\u634C", "\u7396"
    };
    private static final String b[] = {
        "\u4E07\u4E07\u5146", "\u4EDF\u4E07\u5146", "\u4F70\u4E07\u5146", "\u5341\u4E07\u5146", "\u4E07\u5146", "\u4EDF\u5146", "\u4F70\u5146", "\u5341\u5146", "\u5146", "\u4E07\u4EBF", 
        "\u4EDF\u4EBF", "\u4F70\u4EBF", "\u62FE\u4EBF", "\u4EBF", "\u4EDF\u4E07", "\u4F70\u4E07", "\u62FE\u4E07", "\u4E07", "\u4EDF", "\u4F70", 
        "\u62FE", "\u5706", ".", "\u89D2", "\u5206"
    };
}
