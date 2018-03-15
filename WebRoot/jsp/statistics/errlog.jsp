<%@ page language="java" import="java.util.*" pageEncoding="utf-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<%-- 
#*---------------------------------------------#
# Template for a JSP
# @version: 1.2
# @author: yangn
# @author: Jed Anderson
# @describle:功能说明  系统错误日志查询
#---------------------------------------------#
--%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<base href="<%=basePath%>">
<title> 系统错误日志查询</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">    
<%@ include file="../../layout/script.jsp"%>
<script type="text/javascript">
	var $dg ;
	$(function(){
		createSysBranch("branchId","userId");
		$dg = $("#dg");
		$grid=$dg.datagrid({
			url : "statistical/statisticalAnalysisAction!errLogQuery.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			pageSize:20,
			singleSelect:true,
			autoRowHeight:true,
			showFooter: true,
			scrollbarSize:0,
			fitColumns:true,
			//scrollbarSize:0,
			columns :[[
					{field:'ERR_NO',title:'错误流水',sortable:true,width:parseInt($(this).width() * 0.04)},
					{field:'FULL_NAME',title:'发起请求网点名称',sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:'NAME',title:'发起请求柜员名称',sortable:true,width:parseInt($(this).width() * 0.1)},
					{field:'MESSAGES',title:'错误信息',sortable:true,width:parseInt($(this).width() * 0.1)},
					{field:'ERRTIME',title:'请求时间',sortable:true,width:parseInt($(this).width() * 0.1)},
					{field:'IP',title:'客户端IP',sortable:true,width:parseInt($(this).width() * 0.08)},
			  ]],
			  toolbar:'#tb',
	          onLoadSuccess:function(data){
	        	  $("input[type=checkbox]").each(function(){
	    				this.checked = false;
	    		  });
	        	  if(data.status != "0"){
	        		 $.messager.alert('系统消息',data.errMsg,'error');
	        	  }
	          }
		});
	});
	function query(){
		var params = getformdata("operLogQuery");
		if(params["isNotBlankNum"] == 0){
			$.messager.alert("系统消息","查询不能全部为空，请至少输入或选择一个参数信息！","warning");
			return;
		}
		params["queryType"] = 0;
		params["beginTime"] = $("#beginTime").val().replace(/\D/g,'');
		params["endTime"] = $("#endTime").val().replace(/\D/g,'');
		params["sysLog.ip"] = $("#ip").val().replace(/\D/g,"");
		$dg.datagrid('load',params);
	}
</script>
</head>
<body class="easyui-layout">
	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong> 系统错误日志进行查询操作！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="height:auto;overflow:hidden;border-left:none;border-bottom:none;">
		<div id="tb" style="padding:2px 0">
			<form id="operLogQuery">
				<table cellpadding="0" cellspacing="0" class="tablegrid" style="width:100%">
					<tr>
						<td class="tableleft">所属网点：</td>
						<td class="tableright"><input id="branchId" type="text" class="textinput" name="sysLog.brchId"/></td>
						<td class="tableleft">柜员：</td>
						<td class="tableright"><input id="userId" type="text" class="textinput" name="sysLog.userId"/></td>
						<td class="tableleft">IP地址：</td>
						<td class="tableright"><input id="ip" type="text"  class="textinput" name="sysLog.ip"/></td>
					</tr>
					<tr>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input id="beginTime" type="text" name="beginTime" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',qsEnabled:false,maxDate:'%y-%M-%d 0:0:0'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright" colspan="1"><input id="endTime" type="text"  name="endTime" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td colspan="2" align="center">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="系统错误日志信息"></table>
	</div>
</body>
</html>
