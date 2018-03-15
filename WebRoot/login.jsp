<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
	/*response.setHeader("Pragma","No-cache"); 
	response.setHeader("Cache-Control","no-cache"); 
	response.setDateHeader("Expires", 0); 
	response.flushBuffer();*/
%>
<%
		String easyuiThemeName="default";
		Cookie cookies[] =request.getCookies();
		if(cookies!=null&&cookies.length>0){
			for(Cookie cookie : cookies){
				if (cookie.getName().equals("cookiesColor")) {
					easyuiThemeName = cookie.getValue();
					break;
				}
			}
		}
	%>
<!DOCTYPE HTML>
<html>
  <head>
    <base href="<%=basePath%>">
    <title>欢迎登陆<%=com.erp.util.Constants.APP_REPORT_TITLE %></title>
	<link rel="shortcut icon" type="image/x-icon" href="../extend/iconkey.ico" media="screen" />
	<link rel="stylesheet" type="text/css" href="themes/<%=easyuiThemeName %>/easyui.css">
	<script type="text/javascript" src="js/jquery-1.8.0.min.js"></script>
	<script type="text/javascript" src="js/jquery.easyui.min.js"></script>
	<script type="text/javascript" src="js/easyui-lang-zh_CN.js"></script>
	<script type="text/javascript" src="js/jquery.cookie.js"></script>
	<link rel="stylesheet" type="text/css" href="css/zice.style.css">
	<link rel="stylesheet" type="text/css" href="css/tipsy.css">
	<link rel="stylesheet" type="text/css" href="css/icon.css">
	<link rel="stylesheet" type="text/css" href="css/buttons.css">
	<script type="text/javascript" src="js/iphone.check.js"></script>
	<script type="text/javascript" src="js/jquery-jrumble.js"></script>
	<script type="text/javascript" src="js/jquery.tipsy.js"></script>
	<script type="text/javascript" src="js/login.js"></script>
	<script type="text/javascript">
	 window.history.forward(1);
		if(top!=self){
			if(top.location != self.location)
			 top.location=self.location; 
		}
		$(function(){$("#userName").focus();});
	</script>
	 <style type="text/css">
	html {
		background-image: none;
	}
	
	label.iPhoneCheckLabelOn span {
		padding-left: 0px
	}
	
	#versionBar {
		background-color: #212121;
		position: fixed;
		width: 100%;
		height: 35px;
		bottom: 0;
		left: 0;
		text-align: center;
		line-height: 35px;
		z-index: 11;
		-webkit-box-shadow: black 0px 10px 10px -10px inset;
		-moz-box-shadow: black 0px 10px 10px -10px inset;
		box-shadow: black 0px 10px 10px -10px inset;
	}
	
	.copyright {
		text-align: center;
		font-size: 10px;
		color: #CCC;
	}
	
	.copyright a {
		color: #A31F1A;
		text-decoration: none
	}
	.uibutton-group li{
		margin:0 7px;
		height:20px;
		width:60px;
		text-align:center;
	}
	/*update-begin--Author:tanghong  Date:20130419 for：【是否】按钮错位*/
	.on_off_checkbox{
		width:0px;
	}
	/*update-end--Author:tanghong  Date:20130419 for：【是否】按钮错位*/
	#login .logo {
		
	}
	#cap{
	margin-left: 88px;
	}
	</style>
  </head>
  <body>
	<div id="alertMessage"></div>
	<div id="successLogin"></div>
	<div class="text_success">
		<img src="extend/loader_green.gif" alt="Please wait" /> <span>登陆成功!请稍后....</span>
	</div>
	<script type="text/javascript">
	if(top!=self){
		if(top.location != self.location)
		 top.location=self.location; 
	}else{
	}
	</script>
	<div id="login">
		<div class="inner">
			<div class="logo">
				<img src="extend/jx_logo.png" style="border-radius: 10px;width:480px;"/>
			</div>
			<div class="formLogin">
				<form name="formLogin" action="systemAction!load.action" id="formLogin" method="post">
					<input name="userKey" type="hidden" id="userKey" value="D1B5CC2FE46C4CC983C073BCA897935608D926CD32992B5900" />
					<div class="tip">
						<label for="userName" style="font-size:15px;color:#417CA5">用户名：</label>
						<input class="userName" name="userName" type="text" id="userName" iscookie="true"  placeholder="请输入用户名"/>
					</div>
					<div class="tip">
						<label for="userName" style="font-size:15px;color:#417CA5">密&nbsp;&nbsp;&nbsp;&nbsp;码：</label>
						<input class="password" name="password" type="password" id="password" maxlength="16"  value="" placeholder="请输入密码" />
					</div>
					<div class="loginButton">
						<div style="padding:3px 0;">
							<div>
								<ul class="uibutton-group">
									<li><a class="uibutton normal" href="javascript:void(0);" id="but_login" style="border-radius:6px;display:inline-block;width:45px;maring-right:2px;" >登陆</a></li>
									<li><a class="uibutton normal" href="javascript:void(0);" id="forgetpass" style="border-radius:6px;display:inline-block;width:45px;margin-left:2px;">重置</a></li>
								</ul>
							</div>
						</div>
						<div class="clear"></div>
					</div>
				</form>
				<div style="float:left; margin-left: 5px;">
					<input type="checkbox" id="on_off" name="remember" checked="ture" class="on_off_checkbox" value="0" /> <span class="f_help">是否记住用户名</span>
				</div>
			</div>
		</div>
		<div class="shadow"></div>
	</div>
	<!--Login div-->
	<div class="clear"></div>
	<div id="versionBar">
		<div class="copyright"><!-- &copy; 版权所有 <span class="tip"> --><!-- <a href="javascript:void(0);" title="sysErp">Yirui Technology Co.,Ltd.</a> -->
				(推荐使用IE9+,谷歌浏览器可以获得更快,更安全的页面响应速度)<!-- 技术支持:<a href="javascript:void(0);" title="sysErp">Yirui Technology Co.,Ltd.</a> </span> -->
		</div>
	</div>
</body>
</html>
