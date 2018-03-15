<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
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
<c:set var="ACC_KIND_NAME_QB" value="<%=com.erp.util.Constants.ACC_KIND_NAME_QB%>" scope="application"/>
<c:set var="ACC_KIND_NAME_LJ" value="<%=com.erp.util.Constants.ACC_KIND_NAME_LJ%>" scope="application"/> 
<c:set var="YES_NO_NO" value="<%=com.erp.util.Constants.YES_NO_NO%>"/> 
<OBJECT	id=CardCtl  align="middle" WIDTH=0 HEIGHT=0 codeBase=js/Card_JX.CAB#version=1,0,0,2  classid=CLSID:83766BBD-2217-4432-895A-4AA12545CDDF></OBJECT>
<link rel="stylesheet" type="text/css" href="themes/<%=easyuiThemeName %>/easyui.css" />
<link rel="shortcut icon" type="image/x-icon" href="../extend/iconkey.ico" media="screen" />
<link rel="stylesheet" type="text/css" href="themes/icon.css" />
<link rel="stylesheet" type="text/css" href="css/common.css" />
<link rel="stylesheet" type="text/css" href="css/jquery-ui.css" />
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
<script type="text/javascript" src="js/validator.js"></script>
<script type="text/javascript" src="js/ajaxfileupload.js"></script>
<script type='text/javascript' src='dwr/engine.js'></script>
<script type='text/javascript' src='dwr/util.js'></script>
<script type='text/javascript' src='/dwr/interface/commonDwr.js'></script>
<style type="text/css">
	body {
	    font-family:微软雅黑,helvetica,tahoma,verdana,sans-serif;
	    font-size:13px;
	    margin:0px 0px 0px 0px;
	    padding:0px 0px 0px 0px;
	}
	.datagrid-header td,
	.datagrid-body td,
	.datagrid-footer td {
		  border-width: 0 1px 1px 0px;
		  border-style: solid;
		  margin: 0;
		  padding: 0;
	}
	.datagrid-header td span{
		  font-family:幼圆,helvetica,tahoma,verdana,sans-serif;
		  color:black;
		  font-weight:600;
	}
</style>