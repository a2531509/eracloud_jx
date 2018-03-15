<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>系统管理操作日志</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript"> 
	//$.fn.datagrid.defaults.loadMsg = '正在处理，请稍待。。。';
		var $dg;
		var $grid;
		$(function(){
			$dg = $("#dg2");
			$grid=$dg.datagrid({
				url:"accountManager/accountManagerAction!queryAccKindLog.action",
				fit:true,
				pagination:true,
				rownumbers:true,
				//scrollbarSize:18,
				border:true,
				striped:true,
				pageSize:20,
				singleSelect:true,
				autoRowHeight:true,
				fitColumns:true,
				columns :[[
						{field:'DEAL_NO',title:'操作流水',sortable:true,width:parseInt($(this).width()*0.05)},
						{field:'DEAL_CODE_NAME',title:'业务名称',sortable:true,width:parseInt($(this).width()*0.08)},
						{field:'FULL_NAME',title:'操作网点',sortable:true,width:parseInt($(this).width()*0.08)},
						{field:'NAME',title:'操作柜员',sortable:true,width:parseInt($(this).width()*0.05)},
						{field:'BIZTIME',title:'办理时间',sortable:true,width:parseInt($(this).width()*0.1)},
						{field:'CLR_DATE',title:'清分日期',sortable:true,width:parseInt($(this).width()*0.08)},
						{field:'NOTE',title:'备注',sortable:true}
					]],
	              onLoadSuccess:function(data){
	            	  if(data.status != 0){
	            		 $.messager.alert('系统消息',data.errMsg,'error');
	            	  }
	              }
			});
		});
	</script>
  </head>
<body style="padding:0px;margin:0px;">
  <div class="easyui-layout" data-options="fit:true,border:true" style="margin-top:-3px;">
	  <div data-options="region:'center',split:false,border:false" style="height:auto;overflow:auto;">
	  		<table id="dg2" title="账户管理操作日志"></table>
	  </div>
  </div>
</body>
</html>