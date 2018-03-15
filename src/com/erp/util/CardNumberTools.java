package com.erp.util;
import java.io.Serializable;

import com.erp.exception.CommonException;


@SuppressWarnings("serial")
public class CardNumberTools implements Serializable{
	/**
	 * @param cardnumseq SEQ_CARD_APPLY_ID的序列号
	 * @param prefix 首位校验码
	 * @return 获得卡号
	 */
	public static String createCardNumber(String cardnumseq,String prefix){
		/** 百事通vip卡和vip半成品卡的卡号生成，现在全通过一个seq产生，8位，不需要变换。
		 * （以前生成市民卡也就是实名制卡的卡号是拉成9位，第一位是字符，最后一位通过中间7位换算而成，中间7位就是seq产生） */
		//if(true)return Tools.tensileString(cardnumseq,8,true,"0");
		//以下代码实名制卡产生卡号的时候用到，现在权当注释掉
		try{
			Integer.valueOf(cardnumseq);
		}catch(Exception e){
			throw new CommonException("输入的卡序列号不是有效的数字！");
		}
		String center_cardnumber=Tools.tensileString(cardnumseq,7,true,"0");
		int tempnum=0;
		int totalnum=0;
		String checknumber="";
		if(prefix.equalsIgnoreCase("A")) totalnum = 10*3;//首位字符对应的数值*权
		else if (prefix.equalsIgnoreCase("B"))totalnum = 11 * 3;
		else if (prefix.equalsIgnoreCase("C")) totalnum = 12 * 3;
		else if (prefix.equalsIgnoreCase("D")) totalnum = 13 * 3;
		else if (prefix.equalsIgnoreCase("E")) totalnum = 14 * 3;
		else if (prefix.equalsIgnoreCase("F")) totalnum = 15 * 3;
		else if (prefix.equalsIgnoreCase("G")) totalnum = 16 * 3;
		else if (prefix.equalsIgnoreCase("H")) totalnum = 17 * 3;
		else if (prefix.equalsIgnoreCase("I")) totalnum = 18 * 3;
		else totalnum = 10* 3;
		for(int i=0;i<7;i++){
			if(i==0)tempnum = 7;
			if(i==1)tempnum = 9;
			if(i==2)tempnum = 10;
			if(i==3)tempnum = 5;
			if(i==4)tempnum = 8;
			if(i==5)tempnum = 4;
			if(i==6)tempnum = 2;
			totalnum = totalnum +tempnum * Integer.valueOf(center_cardnumber.substring(i,i+1)).intValue();
		}
		tempnum = 11 - (totalnum%11);
	    if (tempnum == 10 )checknumber = "X";
	    else if( tempnum == 11)checknumber ="0";
	    else checknumber = String.valueOf(tempnum);
		return prefix+center_cardnumber+checknumber;
	}
	/**
	 * 验证起止号段合法性
	 * @param startNo 开始号码
	 * @param endNo 结束号码
	 * @return
	 * @throws CommonException
	 */
	public static String[] disposeCardNo(String startNo,String endNo,String card_Type) throws CommonException{
		if(Tools.processNull(startNo).equals("")||Tools.processNull(endNo).equals(""))
			throw new CommonException("起止号码不能为空！");
		if(startNo.length()!=endNo.length())
			throw new CommonException("起止号码长度不相等！");
		String [] ret=new String[4];
		try {
			String s_prifixStr="";//开始号码前缀
			String e_prifixStr="";//结束号码前缀
			
			boolean isLpk=false;//是否是19位礼品卡，最后一位是校验位
			boolean isJmk=false;//是否是20位全功能卡或临海通卡，后4位是校验位（4位城市号+2位区号+10位序列号+4校验位）
			if(!Tools.processNull(card_Type).equals("") && card_Type.startsWith("8") && startNo.length()==19 ){//若是礼品卡，并且卡号长度为19位
				isLpk=true;
				startNo=startNo.substring(0,18);
				endNo=endNo.substring(0,18);
			}else if((card_Type.equals(Constants.CARD_TYPE_SMZK)||card_Type.equals(Constants.CARD_TYPE_JMK))&&
					startNo.length()==20){//以最新的卡号规则4位城市代码+2位区代码+10位序列号+4位校验码 （如果单独的总库入库卡号段，不经此方法，因为可能没有后面校验位）
				isJmk=true;
				if(!startNo.substring(4,6).equals(endNo.substring(4,6)))
					throw new CommonException("两个卡号段所属区号不一致，不能按号段配送！");
				s_prifixStr=startNo.substring(0,6);
				e_prifixStr=s_prifixStr;
				startNo=startNo.substring(6,16);
				endNo=endNo.substring(6,16);
			}
				
			for(int i=0;i<startNo.length();i++){
				//startNo.charAt(i)>='0' && startNo.charAt(i)<='9' && endNo.charAt(i)>='0' && endNo.charAt(i)<='9'  && (endNo.charAt(i)=='0' || endNo.charAt(i)>'9')
				if(startNo.charAt(i)==endNo.charAt(i) && i<startNo.length()-1){
					continue;
				}else{
					s_prifixStr+=startNo.substring(0,i);
					e_prifixStr+=endNo.substring(0,i);
					startNo=startNo.substring(i);
					endNo=endNo.substring(i);
					if(Long.parseLong(endNo)<Long.parseLong(startNo)){
						throw new CommonException("起始号码必须小于等于结束号码！");
					}
					if(!s_prifixStr.equals(e_prifixStr)){//若两个号段前缀字符串不相等，返回异常
						throw new CommonException("起止号码段前缀不相符！");
					}
					break;
				}
			}
			ret[0]=e_prifixStr;
			ret[3]=((Long.parseLong(endNo)-Long.parseLong(startNo))+1l)+"";//数量
			ret[1]=startNo;
			ret[2]=endNo;
			if(isLpk){
				ret[1]=startNo+"0";
				ret[2]=endNo+"9";
			}else if (isJmk){
				ret[1]=startNo+"0000";
				ret[2]=endNo+"9999";
			}
		} catch (Exception e) {
			e.printStackTrace();
			throw new CommonException("验证起止号段合法性出错！"+e.getMessage());
		}
		return ret;
	}
	
	/**
	 * 生成磁条卡末尾的校验码
	 * @param para_1
	 * @return
	 */
	public static String makeVerifyCode(String para_1){
		return "5";//校验码，暂时任意返回一个数字
	}
	/**
	 * 验证磁条卡卡号是否合法
	 * @param para_1
	 * @return
	 */
	public static boolean verifyCardNo(String para_1){
		return true;
	}
}
