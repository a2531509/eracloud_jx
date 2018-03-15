package com.erp.util;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;

public class DateUtil implements Cloneable, Serializable{
	
	  public static boolean checkDate(String dateStr)
	    {
	        dateStr = dateStr.replaceAll("-", "");
	        dateStr = dateStr.replaceAll("/", "");
	        dateStr = dateStr.replaceAll("\\.", "");
	        dateStr = dateStr.replaceAll("\u5E74", "");
	        dateStr = dateStr.replaceAll("\u6708", "");
	        dateStr = dateStr.replaceAll("\u65E5", "");
	        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
	        dateFormat.setLenient(false);
	        try
	        {
	            dateFormat.parse(dateStr);
	            return true;
	        }
	        catch(Exception e)
	        {
	            return false;
	        }
	    }

	    public DateUtil()
	    {
	        GregorianCalendar todaysDate = new GregorianCalendar();
	        year = todaysDate.get(1);
	        month = todaysDate.get(2) + 1;
	        day = todaysDate.get(5);
	    }

	    public DateUtil(int yyyy, int mm, int dd)
	    {
	        year = yyyy;
	        month = mm;
	        day = dd;
	        if(!isValid())
	            throw new IllegalArgumentException();
	        else
	            return;
	    }

	    public void setDate(int yyyy, int mm, int dd)
	    {
	        year = yyyy;
	        month = mm;
	        day = dd;
	    }

	    public void setDate(String yyyy, String mm, String dd)
	    {
	        try
	        {
	            setDate(Integer.parseInt(yyyy), Integer.parseInt(mm), Integer.parseInt(dd));
	        }
	        catch(Exception e)
	        {
	            e.printStackTrace();
	        }
	    }

	    public static java.util.Date parse(String pattern, String date)
	        throws Exception
	    {
	        SimpleDateFormat sdf = new SimpleDateFormat(pattern);
	        try
	        {
	            return sdf.parse(date);
	        }
	        catch(Exception e)
	        {
	            throw new Exception((new StringBuilder("\u65E5\u671F\u683C\u5F0F\u9519\u8BEF:")).append(date).toString());
	        }
	    }

	    public static Date parseSqlDate(String pattern, String date)
	        throws Exception
	    {
	        SimpleDateFormat sdf = new SimpleDateFormat(pattern);
	        try
	        {
	            return new Date(sdf.parse(date).getTime());
	        }
	        catch(Exception e)
	        {
	            throw new Exception((new StringBuilder("\u65E5\u671F\u683C\u5F0F\u9519\u8BEF:")).append(date).toString());
	        }
	    }

	    public static String getDayList(String selectday)
	    {
	        String daylist = "";
	        String value = "";
	        String tstr = selectday != null ? selectday : "";
	        int i = 0;
	        for(i = 1; i < 32; i++)
	        {
	            value = i >= 10 ? (new StringBuilder()).append(i).toString() : (new StringBuilder("0")).append(i).toString();
	            if(tstr.equals(value))
	                daylist = (new StringBuilder(String.valueOf(daylist))).append("<option value=\"").append(value).append("\" selected>").append(value).append("</option>\n").toString();
	            else
	                daylist = (new StringBuilder(String.valueOf(daylist))).append("<option value=\"").append(value).append("\">").append(value).append("</option>\n").toString();
	        }

	        return daylist;
	    }

	    public static String getMonthList(String selectmonth)
	    {
	        String monthlist = "";
	        String value = "";
	        String tstr = selectmonth != null ? selectmonth : "";
	        int i = 0;
	        for(i = 1; i < 13; i++)
	        {
	            value = i >= 10 ? (new StringBuilder()).append(i).toString() : (new StringBuilder("0")).append(i).toString();
	            if(tstr.equals(value))
	                monthlist = (new StringBuilder(String.valueOf(monthlist))).append("<option value=\"").append(value).append("\" selected>").append(value).append("</option>\n").toString();
	            else
	                monthlist = (new StringBuilder(String.valueOf(monthlist))).append("<option value=\"").append(value).append("\">").append(value).append("</option>\n").toString();
	        }

	        return monthlist;
	    }

	    public static String getYearList(String selectyear, int start, int end)
	    {
	        String yearlist = "";
	        String tstr = selectyear != null ? selectyear : "";
	        String value = "";
	        int i = 0;
	        for(i = start; i <= end; i++)
	        {
	            value = (new StringBuilder(String.valueOf(i))).toString();
	            if(tstr.equals(value))
	                yearlist = (new StringBuilder(String.valueOf(yearlist))).append("<option value=\"").append(value).append("\" selected>").append(value).append("</option>\n").toString();
	            else
	                yearlist = (new StringBuilder(String.valueOf(yearlist))).append("<option value=\"").append(value).append("\">").append(value).append("</option>\n").toString();
	        }

	        return yearlist;
	    }

	    public void advance(int n)
	    {
	        fromJulian(toJulian() + n);
	    }

	    public int getDay()
	    {
	        return day;
	    }

	    public int getMonth()
	    {
	        return month;
	    }

	    public int getYear()
	    {
	        return year;
	    }

	    public int weekday()
	    {
	        return (toJulian() + 1) % 7 + 1;
	    }

	    public static String formatDate(java.util.Date date, String format)
	    {
	        return (new SimpleDateFormat(format)).format(date);
	    }

	    public static String formatDate(java.util.Date date)
	    {
	        return dateFormat.format(date);
	    }

	    public int daysBetween(DateUtil du)
	    {
	        int tNum = 0;
	        tNum = toJulian() - du.toJulian();
	        if(tNum < 0)
	            tNum *= -1;
	        return tNum;
	    }

	    public String toString()
	    {
	        return (new StringBuilder("Day[")).append(year).append(",").append(month).append(",").append(day).append("]").toString();
	    }

	    public Object clone()
	    {
	        try
	        {
	            return super.clone();
	        }
	        catch(CloneNotSupportedException e)
	        {
	            return null;
	        }
	    }

	    public boolean equals(Object obj)
	    {
	        if(!getClass().equals(obj.getClass()))
	            return false;
	        DateUtil b = (DateUtil)obj;
	        return day == b.day && month == b.month && year == b.year;
	    }

	    private boolean isValid()
	    {
	        DateUtil t = new DateUtil();
	        t.fromJulian(toJulian());
	        return t.day == day && t.month == month && t.year == year;
	    }

	    private int toJulian()
	    {
	        int jy = year;
	        if(year < 0)
	            jy++;
	        int jm = month;
	        if(month > 2)
	        {
	            jm++;
	        } else
	        {
	            jy--;
	            jm += 13;
	        }
	        int jul = (int)(Math.floor(365.25D * (double)jy) + Math.floor(30.600100000000001D * (double)jm) + (double)day + 1720995D);
	        int IGREG = 588829;
	        if(day + 31 * (month + 12 * year) >= IGREG)
	        {
	            int ja = (int)(0.01D * (double)jy);
	            jul += (2 - ja) + (int)(0.25D * (double)ja);
	        }
	        return jul;
	    }

	    private void fromJulian(int j)
	    {
	        int ja = j;
	        int JGREG = 2299161;
	        if(j >= JGREG)
	        {
	            int jalpha = (int)(((double)(float)(j - 1867216) - 0.25D) / 36524.25D);
	            ja += (1 + jalpha) - (int)(0.25D * (double)jalpha);
	        }
	        int jb = ja + 1524;
	        int jc = (int)(6680D + ((double)(float)(jb - 2439870) - 122.09999999999999D) / 365.25D);
	        int jd = (int)((double)(365 * jc) + 0.25D * (double)jc);
	        int je = (int)((double)(jb - jd) / 30.600100000000001D);
	        day = jb - jd - (int)(30.600100000000001D * (double)je);
	        month = je - 1;
	        if(month > 12)
	            month -= 12;
	        year = jc - 4715;
	        if(month > 2)
	            year--;
	        if(year <= 0)
	            year--;
	    }

	    public static String formatDate(String strDate, String strFormat)
	    {
	        int index = 0;
	        String s = "";
	        if(strDate == null)
	            return "";
	        for(int i = 0; i < strDate.length(); i++)
	            if(!Character.isDigit(strDate.charAt(i)))
	                return strDate;

	        index = strFormat.indexOf("yyyy");
	        if(index >= 0)
	        {
	            s = strDate.substring(0, 4);
	            strFormat = replace(strFormat, "yyyy", s);
	        }
	        index = strFormat.indexOf("yy");
	        if(index >= 0)
	        {
	            s = strDate.substring(2, 4);
	            strFormat = replace(strFormat, "yy", s);
	        }
	        index = strFormat.indexOf("MM");
	        if(index >= 0)
	        {
	            s = strDate.substring(4, 6);
	            strFormat = replace(strFormat, "MM", s);
	        }
	        index = strFormat.indexOf("dd");
	        if(index >= 0)
	        {
	            s = strDate.substring(6, 8);
	            strFormat = replace(strFormat, "dd", s);
	        }
	        index = strFormat.indexOf("HH");
	        if(index >= 0)
	        {
	            s = strDate.substring(8, 10);
	            strFormat = replace(strFormat, "HH", s);
	        }
	        index = strFormat.indexOf("hh");
	        if(index >= 0)
	        {
	            s = strDate.substring(8, 10);
	            if(Integer.parseInt(s) > 12)
	                s = Integer.toString(Integer.parseInt(s) - 12);
	            strFormat = replace(strFormat, "hh", s);
	        }
	        index = strFormat.indexOf("mm");
	        if(index >= 0)
	        {
	            s = strDate.substring(10, 12);
	            strFormat = replace(strFormat, "mm", s);
	        }
	        index = strFormat.indexOf("ss");
	        if(index >= 0)
	        {
	            s = strDate.substring(12);
	            strFormat = replace(strFormat, "ss", s);
	        }
	        return strFormat;
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

	    public static String getNowDate()
	    {
	        return (new SimpleDateFormat("yyyy-MM-dd")).format(new java.util.Date());
	    }

	    public static String getNowTime()
	    {
	        return (new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")).format(new java.util.Date());
	    }

	    public static String getNowDateNormal()
	    {
	        return (new SimpleDateFormat("yyyyMMddHHmmss")).format(new java.util.Date());
	    }

	    public static String getNowTimestampStr()
	    {
	        return (new Timestamp((new java.util.Date()).getTime())).toString();
	    }

	    public static Timestamp getNowTimestamp()
	    {
	        return new Timestamp(System.currentTimeMillis());
	    }

	    public static String processDate(java.util.Date date)
	    {
	        if(date == null)
	            return "";
	        try
	        {
	            SimpleDateFormat myDateFormat = new SimpleDateFormat("yyyy-MM-dd");
	            return myDateFormat.format(date);
	        }
	        catch(Exception e)
	        {
	            return date.toString();
	        }
	    }

	    public static String processTime(java.util.Date date)
	    {
	        if(date == null)
	            return "";
	        try
	        {
	            SimpleDateFormat myDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	            return myDateFormat.format(date);
	        }
	        catch(Exception e)
	        {
	            return date.toString();
	        }
	    }

	    public static java.util.Date formatDate(String date)
	    {
	        if(date == null)
	            return null;
	        try
	        {
	            SimpleDateFormat myDateFormat = new SimpleDateFormat("yyyy-MM-dd");
	            return myDateFormat.parse(date);
	        }
	        catch(Exception e)
	        {
	            return null;
	        }
	    }

	    public static Date formatSqlDate(String str)
	    {
	        if(str == null || str.equals(""))
	            return null;
	        else
	            return new Date(formatDate(str).getTime());
	    }

	    public static Date formatSqlTime(String str)
	    {
	        if(str == null || str.equals(""))
	            return null;
	        else
	            return new Date(formatDateTime(str).getTime());
	    }

	    public static int getMinutes(java.util.Date date)
	    {
	        try
	        {
	            Calendar cal = Calendar.getInstance();
	            cal.setTime(date);
	            return cal.get(12) + cal.get(10) * 60 + cal.get(5) * 1440;
	        }
	        catch(Exception e)
	        {
	            return 0;
	        }
	    }
	   
	    public static java.util.Date formatDateTime(String date)
	    {
	        if(date == null)
	            return null;
	        try
	        {
	            SimpleDateFormat myDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	            return myDateFormat.parse(date);
	        }
	        catch(Exception e)
	        {
	            e.printStackTrace();
	        }
	        return null;
	    }

	    public static String processDateAddYear(String inputDate, int i)
	    {
	        if(inputDate == null)
	            return null;
	        try
	        {
	            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	            Calendar calendar = new GregorianCalendar();
	            calendar.setTime(formatDate(inputDate));
	            calendar.add(1, i);
	            return sdf.format(calendar.getTime());
	        }
	        catch(Exception e)
	        {
	            e.printStackTrace();
	        }
	        return null;
	    }

	    public static String processDateAddMonth(String inputDate, int i)
	    {
	        if(inputDate == null)
	            return null;
	        try
	        {
	            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	            Calendar calendar = new GregorianCalendar();
	            calendar.setTime(formatDate(inputDate));
	            calendar.add(2, i);
	            return sdf.format(calendar.getTime());
	        }
	        catch(Exception e)
	        {
	            e.printStackTrace();
	        }
	        return null;
	    }

	    public static String processDateAddDay(String inputDate, int i)
	    {
	        if(inputDate == null)
	            return null;
	        try
	        {
	            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	            Calendar calendar = new GregorianCalendar();
	            calendar.setTime(formatDate(inputDate));
	            calendar.add(5, i);
	            return sdf.format(calendar.getTime());
	        }
	        catch(Exception e)
	        {
	            e.printStackTrace();
	        }
	        return null;
	    }

	    public static String processSQLDateAddOne(String inputDate)
	    {
	        if(inputDate == null)
	            return null;
	        try
	        {
	            return (new StringBuilder("TO_DATE('")).append(inputDate).append("', 'yyyy-mm-dd')").append(" and TO_DATE('").append(processDateAddDay(inputDate, 1)).append("', 'yyyy-mm-dd')").toString();
	        }
	        catch(Exception e)
	        {
	            e.printStackTrace();
	        }
	        return null;
	    }

	    public static long getDaysFromTwoDate(java.util.Date startDate, java.util.Date endDate)
	    {
	        if(endDate == null || startDate == null)
	        {
	            return -1L;
	        } else
	        {
	            long times = endDate.getTime() - startDate.getTime();
	            return times / 86400000L;
	        }
	    }

	    public static long getMonthsFromTwoDate(java.util.Date startDate, java.util.Date endDate)
	    {
	        Calendar cal1 = new GregorianCalendar();
	        cal1.setTime(startDate);
	        Calendar cal2 = new GregorianCalendar();
	        cal2.setTime(endDate);
	        int c = ((cal2.get(1) - cal1.get(1)) * 12 + cal2.get(2)) - cal1.get(2);
	        return (long)c;
	    }

	    public static long getYearsFromTwoDate(java.util.Date startDate, java.util.Date endDate)
	    {
	        Calendar cal1 = new GregorianCalendar();
	        cal1.setTime(startDate);
	        Calendar cal2 = new GregorianCalendar();
	        cal2.setTime(endDate);
	        int c = cal2.get(1) - cal1.get(1);
	        return (long)c;
	    }
	    public static String formatDate(String paramString1, String paramString2, String paramString3)
	    {
	      if (paramString1 == null)
	        return null;
	      try
	      {
	        return formatDate(new SimpleDateFormat(paramString2).parse(paramString1), paramString3);
	      }
	      catch (Exception localException)
	      {
	      }
	      return null;
	    }
	    
	    

	    private static final long serialVersionUID = 1L;
	    public static SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	    public static int SUNDAY = 1;
	    public static int MONDAY = 2;
	    public static int TUESDAY = 3;
	    public static int WEDNESDAY = 4;
	    public static int THURSDAY = 5;
	    public static int FRIDAY = 6;
	    public static int SATURDAY = 7;
	    private int day;
	    private int month;
	    private int year;

}
