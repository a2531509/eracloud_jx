<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://shiro.apache.org/tags" prefix="shiro"%>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://"
			+ request.getServerName() + ":" + request.getServerPort()
			+ path + "/";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<base href="<%=basePath%>">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>登录日志查询</title>
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	$(function() {
		createSysCode({
			id:'userType',
			codeType:'USER_TYPE',
			
			onSelect:function(rec){
				if(rec.VALUE=="0"){
					$("#loginId").removeAttr("disabled");
				}else if(rec.VALUE=="1"){
					$("#loginId").removeAttr("disabled");
				}else{
					$("#loginId").prop("disabled",true);
				}
			}
		});

		createSysCode({
			id:"logType",
			codeType:"Log_Type"
		});
		
		
		$("#dg").datagrid({
			url : "logs/logManagerAction!getLoginLogs.action",
			pagination : true,
			rownumbers : true,
			border : false,
			singleSelect : true,
			fit : true,
			fitColumns : true,
			scrollbarSize : 0,
			striped : true,
			toolbar : '#tb',
			columns:[[
				{field:"LOGIN_NO",title:"编号",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"OPER_TERM_ID",title:"操作员编号",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"TERM_ID",title:"终端编号",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"IP",title:"登录IP",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"LOGON_TIME",title:"签到时间",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"LOGOFF_TIME",title:"签退时间",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"USER_TYPE",title:"用户类型",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"LOG_TYPE",title:"日志类型",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"LOGIN_ERRO",title:"错误日志",sortable:true,width:parseInt($(this).width()*0.08)}]],
				
			onLoadSuccess : function(data) {
				if (data.status != 0) {
					$.messager.alert('系统消息', data.errMsg, 'error');
				}
				var allch = $(':checkbox').get(0);
				if (allch) {
					allch.checked = false;
				}
			}
		});
	});
	
	function query(){
		$("#dg").datagrid("reload",{
			"log.userType":$("#userType").combobox("getValue"),
			loginId:$("#loginId").val(),
			"log.logType":$("#logType").combobox("getValue"),
			startDate:$("#startDate").val(),
			endDate:$("#endDate").val(),
			queryType:"0"
		});
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
	<div data-options="region:'north',border:false"
		style="overflow: hidden;">
		<div class="well well-small datagrid-toolbar"
			style="margin-left: 0px; margin-top: 2px; margin-right: 0px; margin-bottom: 2px;">
			<span class="badge">提示</span> <span> 在此你可以查看操作员或终端<span
				class="label-info"><strong>登录日志</strong></span>
			</span>
		</div>
	</div>
	<div data-options="region:'center', split:false, border:true"
		style="border-left: none; border-bottom: none; height: auto; overflow: hidden;">
		<div id="tb" style="padding: 2px 0">
			<form action="">
				<table class="tablegrid" style="width: 100%;">
					<tr>
						<td class="tableleft">用户类型：</td>
						<td class="tableright"><input id="userType" class="textinput" /></td>
						<td class="tableleft">用户编号：</td>
						<td class="tableright"><input id="loginId" class="textinput" disabled="disabled"/></td>
						<td class="tableleft">日志类型：</td>
						<td class="tableright"><input id="logType" class="textinput" /></td>
					</tr>
					<tr>
						<td class="tableleft">起始时间：</td>
						<td class="tableright"><input id="startDate" class="textinput Wdate" editable="false" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束时间：</td>
						<td class="tableright"><input id="endDate" class="textinput Wdate" editable="false" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td colspan="2" class="tableright" style="padding-left: 15px;"><a
							href="javascript:void(0);" class="easyui-linkbutton"
							iconCls="icon-search" plain="false" onclick="query()">查询</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
		<table id="dg" title="登录日志查询"></table>
	</div>
</body>
</html>