package com.erp.util;

import java.sql.Date;
import java.util.HashMap;

public class SqlTools {
	public SqlTools()
    {
    }

    public static String eq(String fieldName, HashMap hm, String queryName)
    {
        String sqlWhere = "";
        if(hm.containsKey(queryName) && !hm.get(queryName).equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" = '").append(hm.get(queryName)).append("'").toString();
        return sqlWhere;
    }

    public static String eq(String fieldName, Object matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" = '").append(matchObject).append("'").toString();
        return sqlWhere;
    }

    public static String eq(String fieldName, String matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" = '").append(matchObject).append("'").toString();
        return sqlWhere;
    }

    public static String eq(String fieldName, Long matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" = ").append(matchObject).toString();
        return sqlWhere;
    }

    public static String eq(String fieldName, Integer matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" = ").append(matchObject).toString();
        return sqlWhere;
    }

    public static String eq(String fieldName, Date matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" = to_date('").append(matchObject).append("','yyyy-MM-dd')").toString();
        return sqlWhere;
    }

    public static String ne(String fieldName, HashMap hm, String queryName)
    {
        String sqlWhere = "";
        if(hm.containsKey(queryName) && !hm.get(queryName).equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" <> '").append(hm.get(queryName)).append("'").toString();
        return sqlWhere;
    }

    public static String ne(String fieldName, String matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" <> '").append(matchObject).append("'").toString();
        return sqlWhere;
    }

    public static String ne(String fieldName, Long matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" <> ").append(matchObject).toString();
        return sqlWhere;
    }

    public static String ne(String fieldName, Integer matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" <> ").append(matchObject).toString();
        return sqlWhere;
    }

    public static String ne(String fieldName, Date matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" <> to_date('").append(matchObject).append("','yyyy-MM-dd')").toString();
        return sqlWhere;
    }

    public static String like(String fieldName, HashMap hm, String queryName, int matchMode)
    {
        String sqlWhere = "";
        if(hm.containsKey(queryName) && !hm.get(queryName).equals(""))
            if(matchMode == NOTADD)
                sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" like '").append(hm.get(queryName)).append("'").toString();
            else
            if(matchMode == LEFTADD)
                sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" like '%").append(hm.get(queryName)).append("'").toString();
            else
            if(matchMode == BOTHADD)
                sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" like '%").append(hm.get(queryName)).append("%'").toString();
            else
            if(matchMode == RIGHTADD)
                sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" like '").append(hm.get(queryName)).append("%'").toString();
        return sqlWhere;
    }

    public static String like(String fieldName, String matchObject, int matchMode)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            if(matchMode == NOTADD)
                sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" like '").append(matchObject).append("'").toString();
            else
            if(matchMode == LEFTADD)
                sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" like '%").append(matchObject).append("'").toString();
            else
            if(matchMode == BOTHADD)
                sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" like '%").append(matchObject).append("%'").toString();
            else
            if(matchMode == RIGHTADD)
                sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" like '").append(matchObject).append("%'").toString();
        return sqlWhere;
    }

    public static String like(String fieldName, Date matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" like date'").append(matchObject).append("'").toString();
        return sqlWhere;
    }

    public static String like(String fieldName, java.util.Date matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" like date'").append(matchObject).append("%'").toString();
        return sqlWhere;
    }

    public static String gt(String fieldName, HashMap hm, String queryName)
    {
        String sqlWhere = "";
        if(hm.containsKey(queryName) && !hm.get(queryName).equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" > '").append(hm.get(queryName)).append("'").toString();
        return sqlWhere;
    }

    public static String gt(String fieldName, String matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" > '").append(matchObject).append("'").toString();
        return sqlWhere;
    }

    public static String gt(String fieldName, Long matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" > ").append(matchObject).toString();
        return sqlWhere;
    }

    public static String gt(String fieldName, Integer matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" > ").append(matchObject).toString();
        return sqlWhere;
    }

    public static String gt(String fieldName, Date matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" > to_date('").append(matchObject).append("','yyyy-MM-dd')").toString();
        return sqlWhere;
    }

    public static String lt(String fieldName, HashMap hm, String queryName)
    {
        String sqlWhere = "";
        if(hm.containsKey(queryName) && !hm.get(queryName).equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" < '").append(hm.get(queryName)).append("'").toString();
        return sqlWhere;
    }

    public static String lt(String fieldName, String matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" < '").append(matchObject).append("'").toString();
        return sqlWhere;
    }

    public static String lt(String fieldName, Long matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" < ").append(matchObject).toString();
        return sqlWhere;
    }

    public static String lt(String fieldName, Integer matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" < ").append(matchObject).toString();
        return sqlWhere;
    }

    public static String lt(String fieldName, Date matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" < to_date('").append(matchObject).append("','yyyy-MM-dd')").toString();
        return sqlWhere;
    }

    public static String ge(String fieldName, HashMap hm, String queryName)
    {
        String sqlWhere = "";
        if(hm.containsKey(queryName) && !hm.get(queryName).equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= '").append(hm.get(queryName)).append("'").toString();
        return sqlWhere;
    }

    public static String ge(String fieldName, String matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= '").append(matchObject).append("'").toString();
        return sqlWhere;
    }

    public static String ge(String fieldName, Long matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= ").append(matchObject).toString();
        return sqlWhere;
    }

    public static String ge(String fieldName, Integer matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= ").append(matchObject).toString();
        return sqlWhere;
    }

    public static String ge(String fieldName, Object matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= to_date('").append(matchObject).append("','yyyy-MM-dd')").toString();
        return sqlWhere;
    }

    public static String le(String fieldName, HashMap hm, String queryName)
    {
        String sqlWhere = "";
        if(hm.containsKey(queryName) && !hm.get(queryName).equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" <= '").append(hm.get(queryName)).append("'").toString();
        return sqlWhere;
    }

    public static String le(String fieldName, String matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" <= '").append(matchObject).append("'").toString();
        return sqlWhere;
    }

    public static String le(String fieldName, Long matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" <= ").append(matchObject).toString();
        return sqlWhere;
    }

    public static String le(String fieldName, Integer matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" <= ").append(matchObject).toString();
        return sqlWhere;
    }

    public static String le(String fieldName, Date matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" <= to_date('").append(matchObject).append("','yyyy-MM-dd')").toString();
        return sqlWhere;
    }

    public static String between(String fieldName, HashMap hm, String loQueryName, String hiQueryName)
    {
        String sqlWhere = "";
        if(hm.containsKey(loQueryName) && !hm.get(loQueryName).equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= '").append(hm.get(loQueryName)).append("'").toString();
        if(hm.containsKey(hiQueryName) && !hm.get(hiQueryName).equals(""))
            sqlWhere = (new StringBuilder(String.valueOf(sqlWhere))).append(" and ").append(fieldName).append(" <= '").append(hm.get(hiQueryName)).append("'").toString();
        return sqlWhere;
    }

    public static String between(String fieldName, String loMatchObject, String hiMatchObject)
    {
        String sqlWhere = "";
        if(loMatchObject != null && !loMatchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= '").append(loMatchObject).append("'").toString();
        if(hiMatchObject != null && !hiMatchObject.equals(""))
            sqlWhere = (new StringBuilder(String.valueOf(sqlWhere))).append(" and ").append(fieldName).append(" <= '").append(hiMatchObject).append("'").toString();
        return sqlWhere;
    }

    public static String between(String fieldName, Long loMatchObject, Long hiMatchObject)
    {
        String sqlWhere = "";
        if(loMatchObject != null && !loMatchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= ").append(loMatchObject).toString();
        if(hiMatchObject != null && !hiMatchObject.equals(""))
            sqlWhere = (new StringBuilder(String.valueOf(sqlWhere))).append(" and ").append(fieldName).append(" <= ").append(hiMatchObject).toString();
        return sqlWhere;
    }

    public static String between(String fieldName, Integer loMatchObject, Integer hiMatchObject)
    {
        String sqlWhere = "";
        if(loMatchObject != null && !loMatchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= ").append(loMatchObject).toString();
        if(hiMatchObject != null && !hiMatchObject.equals(""))
            sqlWhere = (new StringBuilder(String.valueOf(sqlWhere))).append(" and ").append(fieldName).append(" <= ").append(hiMatchObject).toString();
        return sqlWhere;
    }

    public static String between(String fieldName, Date loMatchObject, Date hiMatchObject)
    {
        String sqlWhere = "";
        if(loMatchObject != null && !loMatchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= to_date('").append(loMatchObject).append("','yyyy-MM-dd')").toString();
        if(hiMatchObject != null && !hiMatchObject.equals(""))
            sqlWhere = (new StringBuilder(String.valueOf(sqlWhere))).append(" and ").append(fieldName).append(" <= to_date('").append(hiMatchObject).append("','yyyy-MM-dd')").toString();
        return sqlWhere;
    }

    public static String betweens(String fieldName, String loMatchObject, String hiMatchObject)
    {
        String sqlWhere = "";
        if(loMatchObject != null && !loMatchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= date'").append(loMatchObject).append("'").toString();
        if(hiMatchObject != null && !hiMatchObject.equals(""))
            sqlWhere = (new StringBuilder(String.valueOf(sqlWhere))).append(" and ").append(fieldName).append(" <= date'").append(hiMatchObject).append("'").toString();
        return sqlWhere;
    }

    public static String betweens(String fieldName, java.util.Date loMatchObject, java.util.Date hiMatchObject)
    {
        String sqlWhere = "";
        if(loMatchObject != null && !loMatchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= date'").append(loMatchObject).append("'").toString();
        if(hiMatchObject != null && !hiMatchObject.equals(""))
            sqlWhere = (new StringBuilder(String.valueOf(sqlWhere))).append(" and ").append(fieldName).append(" <= date'").append(hiMatchObject).append("'").toString();
        return sqlWhere;
    }

    public static String in(String fieldName, HashMap hm, String queryName)
    {
        String sqlWhere = "";
        if(hm.containsKey(queryName) && !hm.get(queryName).equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" in '").append(hm.get(queryName)).append("'").toString();
        return sqlWhere;
    }

    public static String in(String fieldName, String matchObject)
    {
        String sqlWhere = "";
        if(matchObject != null && !matchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" in ('").append(matchObject).append("')").toString();
        return sqlWhere;
    }

    public static String order(String fieldName, int orderType)
    {
        String sqlWhere = "";
        if(!fieldName.equals(""))
            sqlWhere = (new StringBuilder(" order by ")).append(fieldName).append(orderType != 1 ? " desc" : "").toString();
        return sqlWhere;
    }

    public static String order(String fieldName)
    {
        return order(fieldName, 1);
    }

    public static String betweenDate(String fieldName, String loMatchObject, String hiMatchObject)
    {
        String sqlWhere = "";
        if(loMatchObject != null && !loMatchObject.equals(""))
            sqlWhere = (new StringBuilder(" and ")).append(fieldName).append(" >= to_date('").append(loMatchObject).append("','yyyy-MM-dd hh24:mi:ss')").toString();
        if(hiMatchObject != null && !hiMatchObject.equals(""))
            sqlWhere = (new StringBuilder(String.valueOf(sqlWhere))).append(" and ").append(fieldName).append(" <= to_date('").append(hiMatchObject).append("','yyyy-MM-dd hh24:mi:ss')").toString();
        return sqlWhere;
    }

    public static String divHundred(String fieldName)
    {
        return "trim(to_char(nvl(" + fieldName + ", 0)/100,'99999999999990.99'))";
    }

    public static int NOTADD = 1;
    public static int LEFTADD = 2;
    public static int BOTHADD = 3;
    public static int RIGHTADD = 4;
}
