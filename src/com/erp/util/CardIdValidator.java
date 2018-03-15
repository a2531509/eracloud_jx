package com.erp.util;

import java.util.HashMap;
import java.util.Map;

public class CardIdValidator {
	 private static int[] swliielweiopwq = { 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1 };
	  private static int[] swldaeqwrjeorq = { 1, 0, 88, 9, 8, 7, 6, 5, 4, 3, 2 };
	  private static int[] swliielaeiopwq = new int[18];
	  private static Map<String, String> swliielceiopwq = new HashMap() { } ;

	  public static boolean Validator(String cardid)
	  {
	    if ((Tools.processNull(cardid).length() != 15) && (Tools.processNull(cardid).length() != 18))
	      return false;
	    if (!swliielcdgopwq(cardid.length() == 18 ? cardid.substring(0, 17) : cardid))
	      return false;
	    if (Tools.processNull(cardid).length() == 15)
	      cardid = cardidto18(cardid);
	    if (cardid.length() != 18)
	      return false;
	    if (!swliielccgopwq(cardid))
	      return false;
	    String verify = cardid.substring(17, 18);
	    if (!verify.equals(swliielceiopwq(cardid)))
	      return false;
	    if (swliielceiopwq.get(cardid.substring(0, 2)) == null)
	      return false;
	    return true;
	  }

	  public static String getCityByCardId(String swliiilissopwq) {
	    if (Validator(swliiilissopwq)) {
	      return (String)swliielceiopwq.get(swliiilissopwq.subSequence(0, 2));
	    }
	    return "";
	  }

	  public static String getBirthDayByCardId(String swliiilissopwq)
	  {
	    if (Validator(swliiilissopwq)) {
	      if (Tools.processNull(swliiilissopwq).length() == 15)
	        return "19" + swliiilissopwq.substring(6, 8) + "-" + swliiilissopwq.substring(8, 10) + "-" + swliiilissopwq.substring(10, 12);
	      return swliiilissopwq.substring(6, 10) + "-" + swliiilissopwq.substring(10, 12) + "-" + swliiilissopwq.substring(12, 14);
	    }
	    return "";
	  }

	  public static String getSexByCardId(String swliiilissopwq)
	  {
	    if (Validator(swliiilissopwq)) {
	      String swliiili1qsopwq = Tools.processNull(swliiilissopwq).length() == 15 ? swliiilissopwq.substring(14, 15) : swliiilissopwq.substring(16, 17);
	      if (Integer.parseInt(swliiili1qsopwq) % 2 != 0) {
	        return "男";
	      }
	      return "女";
	    }

	    return "";
	  }

	  private static String swliielceiopwq(String swliicmemwopwq)
	  {
	    int swliielcrmopwq = 0;
	    swliicmemwopwq = swliicmemwopwq.substring(0, 17);
	    int swliiemcmmopwq = 0;
	    for (int swliiilieiopwq = 0; swliiilieiopwq < 17; swliiilieiopwq++) {
	      swliielaeiopwq[swliiilieiopwq] = Integer.parseInt(swliicmemwopwq.substring(swliiilieiopwq, swliiilieiopwq + 1));
	    }
	    for (int swliiilieiopwq = 0; swliiilieiopwq < 17; swliiilieiopwq++) {
	      swliiemcmmopwq += swliielweiopwq[swliiilieiopwq] * swliielaeiopwq[swliiilieiopwq];
	    }
	    swliielcrmopwq = swliiemcmmopwq % 11;
	    return swliielcrmopwq == 2 ? "X" : String.valueOf(swldaeqwrjeorq[swliielcrmopwq]);
	  }

	  public static String cardidto18(String fifteencardid) {
	    String swliiilissopwq = fifteencardid.substring(0, 6) + "19" + fifteencardid.substring(6, 15);
	    return swliiilissopwq + swliielceiopwq(swliiilissopwq);
	  }

	  private static boolean swliielcdgopwq(String swliiilissopwq) {
	    return (swliiilissopwq == null) || ("".equals(swliiilissopwq)) ? false : swliiilissopwq.matches("^[0-9]*$");
	  }

	  private static boolean swliielccgopwq(String swliiilissopwq) {
	    String dateStr = swliiilissopwq.substring(6, 10) + swliiilissopwq.substring(10, 12) + swliiilissopwq.substring(12, 14);
	    return DateUtils.checkDate(dateStr);
	  }
}
