package com.erp.task;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.Scanner;

import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPClientConfig;
import org.apache.commons.net.ftp.FTPCmd;
import org.apache.commons.net.ftp.FTPFile;
import org.apache.commons.net.ftp.FTPReply;
import org.apache.log4j.Logger;

import com.erp.exception.CommonException;


public class DefaultFTPClient extends FTPClient {
	public static Logger logger = Logger.getLogger(DefaultFTPClient.class);
	//private Logger log = Logger.getLogger(FtpClients.class);
	public static void main(String[] args) throws Exception {
		
		//注释部分请勿删除
		/*DefaultFTPClient test = new DefaultFTPClient();
		test.setControlEncoding("GBK");
		boolean isCanConn = test.toConnect("127.0.0.1",21);
		test.enterLocalPassiveMode();//被动模式：必须在connect() 方法之后调用才会有效,因为调用任何的connect() 都会重置数据传输模式
		if(!isCanConn){
			return;//服务器连接失败
		}
		boolean isLoginSuc = test.toLogin("admin","admin");
		if(!isLoginSuc){
			return;
		}
		test.changeWorkingDirectory("/");
		//test.changeWorkingDirectory("/upload");
		test.changeWorkingDirectory("/001/upload");
		boolean sss = test.rename("/001/upload/XF201507050104101001001000100339","/001/errors/XF201507050104101001001000100339");
		System.out.println(test.getReplyCode());
		System.out.println(test.getReplyString());
		//test.completePendingCommand();
		System.out.println(sss);
		test.logout();
		test.disconnect();*/
		//writeLog("dededdddddddddddddddddddddddddddddddddd");
		
		DefaultFTPClient test = new DefaultFTPClient();
		test.setControlEncoding("GBK");
		boolean isCanConn = test.toConnect("10.82.23.181",21);
		test.login("admin","admin");
		test.setListHiddenFiles(true);
		//test.dddd("/bank/100003000000002/downfile");
		
		test.logout();
		test.disconnect();
	}
	
	public DefaultFTPClient(){
		super();
		this.setControlEncoding("GBK");
		this.setBufferSize(this.getBufferSize() * 100);
	}
	/**
	 * <p>根据指定的主机地址,端口号连接FTP服务器<p>
	 * @param hostname String 主机地址（IP地址）
	 * @param port  int FTP 服务器端口
	 * @return boolean 连接是否成功  true 成功 false 连接失败
	 */
	public boolean toConnect(String hostname,int port){
		boolean _connectReslut = false;
		try{
			this.connect(hostname,port);
			int replyCode = this.getReplyCode();
			if(!FTPReply.isPositiveCompletion(replyCode)){
				this.disconnect();
				writeLog("FTP连接失败：" + this.getReplyString());
				return _connectReslut;
			}
			writeLog("FTP连接成功：" + this.getReplyString());
			_connectReslut = true;
		}catch(Exception e){
			_connectReslut = false;
			writeLog("FTP连接失败：" + e.getMessage());
		}
		return _connectReslut;
	}
	/**
	 * 登录FTP服务器
	 * @param username  FTP用户名
	 * @param password  FTP密码
	 * @return          是否登录成功，自动捕捉异常。
	 */
	public boolean toLogin(String username,String password){
		boolean isLoginSuc = false;
		try {
			isLoginSuc = this.login(username,password);
			if(!isLoginSuc){
				writeLog("FTP登录失败：" + this.getReplyString());
			}else{
				writeLog("FTP登录成功：" + this.getReplyString());
			}
		} catch (IOException e) {
			logger.error(e);
			writeLog("FTP登录失败：" + e.getMessage());
		}
		return isLoginSuc;
	}
	/**
	 * 获取FTP指定目录下的文件名称列表
	 * @param pathname     FTP目录
	 * @param num          获取指定的个数,最好指定获取文件的个数(因为当FTP指定目录下的文件过多时,可能会引起获取FTP目录错误)
	 * @return             FTP目录下文件名称列表，如果出错返回或是FTP目录下没有文件则返回null
	 * @throws IOException
	 */
	public List<String> listNames(String pathname,long num){
		ArrayList<String> results = new ArrayList<String>();
		long index = 1L;
		try{
			Socket socket = _openDataConnection_(FTPCmd.NLST,getListArguments(pathname));
			if (socket == null) {
				writeLog("未获取到指定目录下的文件：" + pathname);
				return null;
			}
			BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream(),getControlEncoding()));
			String line;
			while ((line = reader.readLine()) != null && index <= num) {
				results.add(line);
				index++;
			}
			reader.close();
			socket.close();
			if(completePendingCommand()){
				return results;
			}else{
				writeLog("FTP获取文件出现异常：" + this.getReplyString());
			}
		}catch(Exception e){
			if(e.getMessage() != null && e.getMessage().indexOf("550") > -1){
				writeLog("指定目录" + printCurrentDirectory() + "下不存在文件," + printCurrentDirectory() + "  " + pathname);
			}else{
				writeLog("FTP获取文件出现异常：" + e.getMessage());
				logger.error(e);
			}
		}
	    return null;
	}
	/**
	 * <p>在当前目录下,根据文件名获取文件内容</p>
	 * @param filename  文件名名称
	 * @return          List 以list形式返回文件内容,list元素的为文件的每一行。
	 */
	public  List<String> getFileContent(String filename){
		List<String> reContent = new ArrayList<String>();
		try{
			InputStream is = this.retrieveFileStream(filename);
			InputStreamReader isr = new InputStreamReader(is,"GBK");
			BufferedReader br = new BufferedReader(isr);
			String row = null;
			while((row = br.readLine()) != null){
				reContent.add(row);
			}
			br.close();
			isr.close();
			is.close();
			if(completePendingCommand()){
				return reContent;
			}else{
				writeLog("FTP获取文件出现异常：" + this.getReplyString());
			}
		}catch(Exception e){
			logger.error(e);
			writeLog("获取文件内容出现错误：[" + filename + "]" + e.getMessage());
		}
		return null;
	}
	/**
	 * 读取大文件
	 * @param filename
	 * @return
	 * @throws IOException
	 */
	public List<String> LargeMappedFiles(String filename) throws IOException{
		List<String> reContent = new ArrayList<String>();
		FileInputStream inputStream = null;
		Scanner sc = null;
		try {
		    inputStream = new FileInputStream(filename);
		    sc = new Scanner(inputStream, "UTF-8");
		    while (sc.hasNextLine()) {
		        String line = sc.nextLine();
		        reContent.add(line);
		    }
		    // note that Scanner suppresses exceptions
		    if (sc.ioException() != null) {
		        throw sc.ioException();
		    }
		}catch(Exception e){
			logger.error(e);
			writeLog("获取文件内容出现错误：[" + filename + "]" + e.getMessage());
		}finally {
			try{
			   if (inputStream != null) {
			        inputStream.close();
			    }
			    if (sc != null) {
			        sc.close();
			    }
			}catch(Exception ee){
				
			}
		   
		}
		return null;
	}
	
	
	
	/**
	 * 显示FTP当前的工作目录
	 */
	public String printCurrentDirectory(){
		try{
			return this.printWorkingDirectory();
		}catch(Exception e){
			logger.error("获取FTP当前工作目录失败！");
			logger.error(e);
			return "";
		}
	}
	public List<String> listFtpFileMsg(String pathname) throws CommonException{
		try{
			List<String> fileMsgs = new ArrayList<String>(); 
			Socket socket = _openDataConnection_(FTPCmd.NLST,"-lkh " + getListArguments(pathname));
			if (socket == null) {
				writeLog("未获取到指定目录下的文件：" + pathname);
				return null;
			}
			BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream(),getControlEncoding()));
			String line = "";
			reader.readLine();
			while ((line = reader.readLine()) != null) {
				fileMsgs.add(line);
			}
			reader.close();
			socket.close();
			if (completePendingCommand()){
				return fileMsgs;
			}else{
				writeLog("FTP获取文件信息出现异常：" + this.getReplyString());
			}
			return null;
		}catch(Exception e){
			throw new CommonException(e.getMessage());
		}
	}
	/**
	 * Description: 向FTP服务器上传文件
	 * @param url FTP服务器hostname
	 * @param port FTP服务器端口
	 * @param username FTP登录账号
	 * @param password FTP登录密码
	 * @param path FTP服务器保存目录
	 * @param filename 上传到FTP服务器上的文件名
	 * @param input 输入流
	 * @return 成功返回true，否则返回false
	 */
	public static boolean uploadFile(String url,int port,String username, String password, String path, String filename, InputStream input) throws CommonException{
		boolean success = false;
		FTPClient ftp = new FTPClient();
		ftp.setControlEncoding("GBK");
		//ftp.setControlEncoding("UTF-8");
		FTPClientConfig conf = new FTPClientConfig(FTPClientConfig.SYST_NT);
		conf.setServerLanguageCode("zh");
		try {
			int reply;
			ftp.connect(url, port);//连接FTP服务器
			//如果采用默认端口，可以使用ftp.connect(url)的方式直接连接FTP服务器
			ftp.login(username, password);//登录
			ftp.setBufferSize(1024);
			//ftp.enterLocalActiveMode();
			ftp.enterLocalPassiveMode(); 
		    //设置以二进制方式传输       
			reply = ftp.getReplyCode();
			if (!FTPReply.isPositiveCompletion(reply)){
				ftp.disconnect();
				return success;
			}
			ftp.changeWorkingDirectory(path);
			ftp.enterLocalPassiveMode();
			ftp.storeFile(filename, input);	
			input.close();
			ftp.logout();
			success = true;
		} catch (IOException e) {
			throw new CommonException(e.getMessage());
		} finally {
			if (ftp.isConnected()) {
				try {
					ftp.disconnect();
				} catch (IOException ioe) {
				}
			}
		}
		return success;
	}
	/**
	 * 
	 * @param ip
	 * @param socket
	 * @param user
	 * @param pwd
	 * @param oldfilename
	 * @param newfilename
	 * @return
	 */
	public static boolean reNameInFtp(String ip, int socket, String user, String pwd, String oldfilename, String newfilename){
			boolean success = false;
        	FTPClient ftp = new FTPClient();
    		ftp.setControlEncoding("GBK");
    		FTPClientConfig conf = new FTPClientConfig(FTPClientConfig.SYST_NT);
    		conf.setServerLanguageCode("zh");
    		try {
    			int reply;
    			ftp.connect(ip, socket);//连接FTP服务器
    			//如果采用默认端口，可以使用ftp.connect(url)的方式直接连接FTP服务器
    			ftp.login(user, pwd);//登录
    			reply = ftp.getReplyCode();
    			if (!FTPReply.isPositiveCompletion(reply)) {
    				ftp.disconnect();
    				return success;
    			}
    			ftp.changeWorkingDirectory("/");
    			ftp.rename(oldfilename, newfilename);		
    			
    			ftp.logout();
    			success = true;
    		} catch (IOException e) {
    			e.printStackTrace();
    		} finally {
    			if (ftp.isConnected()) {
    				try {
    					ftp.disconnect();
    				} catch (IOException ioe) {
    				}
    			}
    		}
    		return success;
	        
	}
	/**  
     * 删除FTP文件  
     *   
     * @param url  
     *            FTP地址  
     * @param port  
     *            FTP端口  
     * @param username  
     *            用户名  
     * @param password  
     *            密 码  
     * @param remoteAdr  
     *            文件路径  
     * @param localAdr  
     *            文件名称  
     * @return true/false 成功/失败  
     */    
	public static boolean deleteFile(String url, int port, String username,
			String password, String remoteAdr, String localAdr) {
		boolean success = false;
		FTPClient ftp = new FTPClient();
		ftp.setControlEncoding("GBK");
		FTPClientConfig conf = new FTPClientConfig(FTPClientConfig.SYST_NT);
		conf.setServerLanguageCode("zh");
		try {
			int reply;
			ftp.connect(url, port);// 连接FTP服务器
			// 如果采用默认端口，可以使用ftp.connect(url)的方式直接连接FTP服务器
			ftp.login(username, password);// 登录
			ftp.enterLocalPassiveMode();
			reply = ftp.getReplyCode();
			if (!FTPReply.isPositiveCompletion(reply)) {
				ftp.disconnect();
				return success;
			}
			ftp.changeWorkingDirectory(remoteAdr);

			FTPFile[] fs = ftp.listFiles(); // 得到目录的相应文件列表
			if (fs.length > 0) {
				success = ftp.deleteFile(localAdr);
				ftp.logout();
			}

		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (ftp.isConnected()) {
				try {
					ftp.disconnect();
				} catch (IOException ioe) {
				}
			}
		}
		return success;
	}
  
	/**
	 * 写日志，控制台 and 日志文件
	 * @param content 日志内容
	 */
	public static void writeLog(String content){
		if(content == null){
			return;
		}else{
			content = content.replaceAll("\r\n","");
		}
		String operation = System.getProperty("os.name").toUpperCase(Locale.ENGLISH);    
		if (operation.indexOf("AIX") != -1){
			try{
				content = new String(content.getBytes("GBK"), "ISO8859_1");
			}catch(Exception e){
				logger.error(e);
			}
		}
		try{
			File write = new File((new SimpleDateFormat("yyyyMM")).format(new Date()) + "_erp2.log");
			FileWriter fw = new FileWriter(write,true);
			fw.write((new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")).format(new Date()) + "------" + content + "\r\n");
			logger.error(content);
			fw.close();
		}catch(Exception e){
			logger.error(e);
		}
	}
	public static void mainaasa(String[] args) {
		//SimpleDateFormat f = new SimpleDateFormat("yyyy-MM");
		//System.out.println(f.format(new Date()));
	}
}