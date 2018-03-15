<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib uri="/WEB-INF/tlds/erp2tag.tld" prefix="n"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<c:set var="APP_SHOW_BANK_MSG" value="<%=com.erp.util.Constants.APP_SHOW_BANK_MSG%>" /> 
<c:set var="YES_NO_YES" value="<%=com.erp.util.Constants.YES_NO_YES%>"/> 
<c:set var="YES_NO_NO" value="<%=com.erp.util.Constants.YES_NO_NO%>"/> 
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
<title>功能描述</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0"> 
<OBJECT	id=CardCtl  align="middle" WIDTH=0 HEIGHT=0 codeBase=js/Card_JX.CAB#version=1,0,0,3  classid=CLSID:83766BBD-2217-4432-895A-4AA12545CDDF></OBJECT>
<link rel="stylesheet" type="text/css" href="themes/<%=easyuiThemeName %>/easyui.css">
<link rel="shortcut icon" type="image/x-icon" href="../extend/iconkey.ico" media="screen" />
<link rel="stylesheet" type="text/css" href="themes/icon.css">
<link rel="stylesheet" type="text/css" href="css/common.css">
<link rel="stylesheet" type="text/css" href="css/jquery-ui.css">
<link rel="stylesheet" type="text/css" href="css/cropper.min.css">
<style type="text/css">
	body {font-family:微软雅黑,helvetica,tahoma,verdana,sans-serif;font-size:13px;margin:0px 0px 0px 0px;padding:0px 0px 0px 0px;}
	.datagrid-header td,.datagrid-body td,.datagrid-footer td {border-width: 0 1px 1px 0px;border-style: solid;margin: 0;padding: 0;}
	.datagrid-header td span{font-family:幼圆,helvetica,tahoma,verdana,sans-serif;color:black;font-weight:600;}
	.datagrid-cell-group{font-family:幼圆,helvetica,tahoma,verdana,sans-serif;color:black;font-weight:600;}
	.datagrid-footer td{font-family:幼圆,helvetica,tahoma,verdana,sans-serif;color:black;font-weight:600;}
    .textinput{padding-left:2px;}
</style>
<script type="text/javascript" src="js/jquery-1.8.0.min.js"></script>
<script type='text/javascript' src='/js/My97DatePicker/WdatePicker.js'></script>
<script type='text/javascript' src='js/layer.js' charset="UTF-8"></script>
<script type='text/javascript' src='js/des.js'></script>
<script type='text/javascript' src='js/cardservice.js' charset="UTF-8"></script>
<script type="text/javascript" src="js/jquery.easyui.min.js"></script>
<script type="text/javascript" src="js/easyui-lang-zh_CN.js"></script>
<script type="text/javascript" src="js/jqueryUtil.js"></script>
<script type="text/javascript" src="js/jquery-ui.js"></script>
<script type="text/javascript" src="js/json2.js"></script>
<script type="text/javascript" src="js/jquery.switchbutton.js"></script>
<script type="text/javascript" src="js/validator.js"></script>
<script type="text/javascript" src="js/ajaxfileupload.js"></script>
<script type="text/javascript" src="js/cropper.min.js"></script>
<script type='text/javascript' src='dwr/engine.js'></script>
<script type='text/javascript' src='dwr/util.js'></script>
<script type='text/javascript' src='/dwr/interface/commonDwr.js'></script>