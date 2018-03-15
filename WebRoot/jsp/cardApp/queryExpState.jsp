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
    <title>任务导出银行</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
	<link rel="stylesheet" type="text/css" href="css/jquery-ui.css">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript" src="js/jquery-ui.js"></script>
	<script type="text/javascript">
		var $dg;
		var $temp;
		var $grid;
		var $querycerttype;
		$(function() {
			//制卡任务状态
			$("#taskState").combobox({
				width:174,
				url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=TASK_STATE",
				valueField:'codeValue',
				editable:false, //不可编辑状态
			    textField:'codeName',
			    panelHeight: 'auto',//自动高度适合
			    onSelect:function(node){
			 		$("#taskState").val(node.text);
			 	}
			});
			
			//查询条件卡类型
			$("#cardType").combobox({
				width:174,
				url:"sysCode/sysCodeAction!findSysCodeListByType.action?codeType=CARD_TYPE",
				valueField:'codeValue',
				editable:false, //不可编辑状态
			    textField:'codeName',
			    panelHeight: 'auto',//自动高度适合
			    value:'100',
			    onSelect:function(node){
			 		$("#queryCardType").val(node.text);
			 	}
			});
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "madeCardTask/madeCardTaskAction!cardTaskQuery.action",
				pagination:true,
				rownumbers:true,
				border:false,
				striped:true,
				fit:true,
				fitColumns: true,
				singleSelect:true,
				scrollbarSize:0,
				autoRowHeight:true,
				//0未启用1正常2口头挂失3书面挂失9注销
				columns : [ [   {field:'SETTLEID',title:'id',sortable:true,checkbox:'ture'},
								{field:'TASK_ID',title:'任务编号',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'MAKE_BATCH_ID',title:'批次号',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'TASK_STATE',title:'任务状态',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'TASK_WAY',title:'任务组织方式',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'TASK_NAME',title:'任务名称',sortable:true,width : parseInt($(this).width() * 0.2)},
								{field:'TASK_DATE',title:'任务时间',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'CARD_TYPE',title:'卡类型',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'IS_URGENT',title:'制卡方式',sortable:true,width : parseInt($(this).width() * 0.1)},
								{field:'TASK_SUM',title:'任务数量',sortable:true,width : parseInt($(this).width() * 0.05)}
				              ]],toolbar:'#tb',
				              onLoadSuccess:function(data){
				            	  $("input[type='checkbox']").each(function(){ if(this.checked){ this.checked=false; } });//初始话默认不选中
				            	  if(data.status != 0){
				            		 $.messager.alert('系统消息',data.errMsg,'error');
				            	  }
				              }
			});
		});
		
		function queryone(){
			$dg.datagrid('load',{
				queryType:'0',//查询类型
				madeCardBatchNo:$("#madeCardBatchNo").val(),
				madeCardTaskNo:$("#madeCardTaskNo").val(),
				taskState:$("#taskState").combobox('getValue'),
				corpId:$("#corpId").combobox('getValue'),
				cardType:$("#cardType").combobox('getValue'),
				taskStartDate:$("#taskStartDate").val(),
				taskEndDate:$("#taskEndDate").val()
			});
		}

		
		function viewTaskState(){
			var rows = $dg.datagrid('getChecked');
			if(rows.length == 1){
				$.modalDialog({
					title:"任务明细预览",
					iconCls:"icon-viewInfo",
					fit:true,
					maximized:true,
					closable:false,
					//maximizable:true,
					href:"jsp/cardApp/viewTaskState.jsp",
					onLoad:function(){
						if(rows){
							viewLoad(rows[0].TASK_ID);
						}
					},
					tools:[
							{
								iconCls:'icon_cancel_01',
								handler:function(){
									$.modalDialog.handler.dialog('destroy');
								    $.modalDialog.handler = undefined;
							   }
							}
					]
				});
			}else{
				$.messager.alert('提示信息','请选择一条记录进行预览','info');
			}
		}
	</script>
	
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>个性化制卡数据</strong></span>导出给卫生，也可以导入卫生返回!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:true" style="border-left:none;border-bottom:none;height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0">
				<table cellpadding="0" cellspacing="0"  style="width:100%" class="tablegrid">
					<tr>
						<td class="tableleft">批次号：</td>
						<td class="tableright"><input id="madeCardBatchNo" name="madeCardBatch" type="text" class="textinput" /></td>
						<td class="tableleft">任务号：</td>
						<td class="tableright"><input id="madeCardTaskNo" name="madeCardTaskNo" type="text" class="textinput" /></td>
						<td class="tableleft">任务状态：</td>
						<td class="tableright"><input id="taskState" name="taskState" type="text" class="easyui-combobox" style="width:174px;"/></td>
						<td class="tableleft">单位名称：</td>
						<td class="tableright"><input id="corpId" name="corpId"  class="easyui-combobox"  type="text"  style="width:174px;"/></td>
					</tr>
					<tr>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" name="cardType" type="text"  class="easyui-combobox"  style="width:174px;"/></td>
						<td class="tableleft">任务开始日期：</td>
						<td class="tableright"><input id="taskStartDate" name="taskStartDate" type="text" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
						<td class="tableleft">任务结束日期：</td>
						<td class="tableright"><input id="taskEndDate" name="taskEndDate" type="text"  class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
						<td class="tableright" colspan="4" >
								<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="queryone()">查询</a>
							<shiro:hasPermission name="viewTaskState">
								<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-viewInfo"  plain="false" onclick="viewTaskState();">预览明细</a>
							</shiro:hasPermission>
						</td>
				</table>
			</div>
	  		<table id="dg" title="任务信息"></table>
	  </div>
  </body>
</html>
