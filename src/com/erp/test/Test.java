package com.erp.test;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

import com.erp.util.Tools;



public class Test
{
		public static void main(String[] orgs) throws Exception{		
			//String param=Test.getCityId();
			//System.out.println(param);
			/*try {
				//String param=Test.getCityId();
				String urlStr="http://m.weather.com.cn/data/101190401.html";
				URL url=new URL(urlStr);
				HttpURLConnection conn=(HttpURLConnection)url.openConnection();
				conn.connect();
				InputStreamReader r=new InputStreamReader(conn.getInputStream(),"UTF-8");
				BufferedReader rd=new BufferedReader(r);
				String line;
				String str="";
				while((line=rd.readLine())!=null){
					if(line!=null&&(!line.equals(""))){
						//System.out.println(line);
						str=line;
					}
				}
				conn.disconnect();
				r.close();
				rd.close();
				System.out.println(str);
				
				
			} catch (Exception e) {
				e.printStackTrace();
			}*/
			//System.out.println(false == Boolean.parseBoolean("true")); 80  40汉字
			//
			//System.out.println("嘉兴经济技术开发区人力资源和社会保障局(嘉兴经济技术开发区(国际商务区)劳动保障监察大队)建设南杨社区".getBytes("GBK").length);
			System.out.println(Tools.tensileStringByByte(Tools.tensileString("嘉兴经济技术开发区人力资源和社会保障局(嘉兴经济技术开发区(国际商务区)劳动保障监察大队)建设南杨社区",40,false," "),80,false," "));
			
			//System.out.println(Tools.tensileStringByByte("嘉兴经济技术开发区人力资源和社会保障局(嘉兴经济技术开发区(国际商务区)劳动保障监察大队)建设南杨社区",80,false," "));
		}
		
	public static String getCityId(){
		String str="";
		try {
			URL url=new URL("http://61.4.185.48:81/g/");
			HttpURLConnection conn=(HttpURLConnection)url.openConnection();
			conn.connect();
			InputStreamReader r=new InputStreamReader(conn.getInputStream(),"UTF-8");
			BufferedReader rd=new BufferedReader(r);
			String line;
			while ((line = rd.readLine()) != null) {
				//out.println(line+"</br>");
				//out.println(line.substring(line.indexOf("id="),line.length())+"</br>");
				if(line!=null&&(!line.equals(""))){
					//out.println(line.substring(line.indexOf("id=")+3,line.indexOf("if")-1));
					str=line.substring(line.indexOf("id=")+3,line.indexOf("if")-1);
				}
			}
			conn.disconnect();
			r.close();
			rd.close();
		}catch(Exception e){
			e.printStackTrace();
		}
		return str;
	}
}
