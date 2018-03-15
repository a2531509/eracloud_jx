<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <base href="<%=basePath%>">
    <title>申领情况查询</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">   
	<link rel="stylesheet" type="text/css" href="css/jquery-ui.css">
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<script type="text/javascript" src="js/jquery-ui.js"></script>
<script type="text/javascript">
	var  $personinfo;//人员列表
	$(function(){
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
		selectByType('applyWay','APPLY_WAY');
		 $personinfo = $("#personinfo");
		 $personinfo.datagrid({
			url : "/cardapply/cardApplyAction!toApplyStateQuery.action",
			fit:true,
			//scrollbarSize:0,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			singleSelect:true,
			//fitColumns:true,
			pageList:[10,20,30,40,50],
			pageSize:20,
			columns : [ [   {field:'TASKID',title:'id',sortable:true,checkbox:'ture'},
							{field:'TASK_ID',title:'任务编号',sortable:true,width : parseInt($(this).width() * 0.12)},
							{field:'MAKE_BATCH_ID',title:'批次号',sortable:true,width : parseInt($(this).width() * 0.05)},
							{field:'TASK_NAME',title:'任务名称',sortable:true,width : parseInt($(this).width() * 0.2)},
							{field:'TASK_SUM',title:'任务数量',sortable:true,width : parseInt($(this).width() * 0.08)},
							{field:'WS_NUM',title:'卫计委通过数量',sortable:true,width : parseInt($(this).width() * 0.08)},
							{field:'WS_NOT_NUM',title:'卫计委不通过数量',sortable:true,width : parseInt($(this).width() * 0.08)},
							{field:'YH_NUM',title:'银行通过数量',sortable:true,width : parseInt($(this).width() * 0.08)},
							{field:'YH_NOT_NUM',title:'银行不通过数量',sortable:true,width : parseInt($(this).width() * 0.08)},
							{field:'END_NUM',title:'最终数量',sortable:true,width : parseInt($(this).width() * 0.05)},
							{field:'TASK_SRC',title:'任务来源',sortable:true,width : parseInt($(this).width() * 0.08)},
							{field:'TASK_WAY',title:'任务组织方式',sortable:true,width : parseInt($(this).width() * 0.08)}

			              ]],

			
		 	toolbar:'#tb',
		 	onLoadSuccess:function(data){
		 		if(dealNull(data.errMsg).length > 0){
		 			$.messager.alert('系统消息',data.errMsg,'error');
		 		}
		 		var allch = $(':checkbox').get(0);
		 		if(allch){
		 			allch.checked = false;
		 		}
		 		//$personinfo.datagrid('resize',{scrollbarSize:18});
		 	}
		 });
	});
	//查询
	function toquery(){
		var params = {};
		params['queryType'] = '0';
		params['taskId'] = $("#taskId").val();
		params['apply.buyPlanId'] = $("#makeBatchId").val();
		params['task_state'] = $("#taskState").combobox("getValue");
		params['beginTime'] = $("#beginTime").val();
		params['endTime'] = $("#endTime").val();
		$personinfo.datagrid('load',params);
	}


</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
 		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top:2px;margin-bottom:2px;">
			<span class="badge">提示</span><span>在此您可以进行<span class="label-info"><strong>申领情况查询</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="margin:0px;width:auto">
	  	<div id="tb" style="padding:2px 0">
	  		<form id="applyMsgForm">
				<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
					<tr id="dwapply">
						<td  class="tableleft" style="width:7%">任务编号：</td>
						<td  class="tableright" style="width:15%"><input name="taskId"  class="textinput" id="taskId" type="text"/></td>
						<td  class="tableleft" style="width:7%">批次号：</td>
						<td  class="tableright" style="width:15%"><input name="makeBatchId"  class="textinput" id="makeBatchId" type="text"/></td>
						 <td class="tableleft" style="width:7%">任务状态：</td>
						<td class="tableright"><input id="taskState" name="taskState" type="text" class="textinput" style="width:174px;"/></td>
					</tr>
					<tr>
						<td class="tableleft">任务时间始：</td>
						<td class="tableright"><input name="beginTime"  class="Wdate textinput" id="beginTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">任务时间止：</td>
						<td class="tableright"><input name="endTime"  class="Wdate textinput" id="endTime" type="text" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
                        <td class="tableright" colspan="2"> <a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0)" class="easyui-linkbutton" onclick="toquery()">查询</a></td>
					</tr>
				
				</table>
			</form>
		</div>
  		<table id="personinfo" title="查询条件"></table>
	</div>
</body>
</html>