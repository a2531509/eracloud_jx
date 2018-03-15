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
    <title>制卡任务管理</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<jsp:include page="../../layout/script.jsp"></jsp:include>
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
		
			$dg = $("#dg");
			$grid=$dg.datagrid({
				url : "/stockManage/StockAction!queryBranchAccept.action",
				width : $(this).width() - 0.1,
				height : $(this).height() - 45,
				pagination:true,
				rownumbers:true,
				border:true,
				striped:true,
				fit:true,
				fitColumns: true,
				scrollbarSize:0,
				autoRowHeight:true,
				columns : [ [   {field:'SETTLEID',title:'id',sortable:true,checkbox:'ture'},
				                {field:'stk_Type',title:'库存种类',sortable:true,width : parseInt($(this).width() * 0.05)},
				                {field:'stk_Code',title:'库存代码',sortable:true,width : parseInt($(this).width() * 0.05)},
								{field:'stk_Name',title:'库存类型名称',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'MAKE_BATCH_ID',title:'批次号',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'task_Id',title:'任务号',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'start_No',title:'起始号码',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'end_No',title:'结束号码',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'tot_Num',title:'数量',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'tr_Date',title:'配送日期',sortable:true,width : parseInt($(this).width() * 0.08)},
								{field:'is_Sure',title:'是否确认',sortable:true,width : parseInt($(this).width() * 0.08)}
				              ]],toolbar:'#tb',
				              onLoadSuccess:function(data){
				            	  $("input[type='checkbox']").each(function(){ if(this.checked){ this.checked=false; } });//初始话默认不选中
				            	  if(data.status != 0){
				            		 $.messager.alert('系统消息',data.errMsg,'error');
				            	  }
				              }
			});
		});
		</script>
  </head>
  <body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
				<span class="badge">提示</span>
				<span>在此你可以对<span class="label-info"><strong>总库配送数据</strong></span>进行操作!</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
			<div id="tb" >
				<table class="tablegrid" width="100%" cellpadding="0" cellspacing="0" >
					<tr>
						<td align="right" class="tableleft">任务号：</td>
						<td align="left" class="tableright"><input id="taskId" name="taskId" type="text" maxlength="20" class="textinput" /></td>
						<td align="right" class="tableleft">任务名称：</td>
						<td align="left" class="tableright"><input id="task_Name" name="task_Name" type="text"  maxlength="20" class="textinput" style="width:174px;"/></td>
					    <td align="right" class="tableleft">配送开始日期：</td>
						<td align="left" class="tableright"><input id="startDate" name="startDate" type="text" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
						<td align="right" class="tableleft">配送结束日期：</td>
						<td align="left" class="tableright"><input id="endDate" name="endDate" type="text"  class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
						
					</tr>
					
					<tr>
					   <td align="right" class="tableleft">库存代码：</td>
						<td align="left" class="tableright"><input id="stkCodeId" name="stkCodeId" type="text" class="textinput" /></td>
						<td align="right" class="tableleft">库存种类：</td>
						<td align="left" class="tableright"><input id="stkTypeId" name="stkCodeId" type="text" class="textinput" /></td>
						<td align="left" class="tableright" colspan="2">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="viewTask();">领用入库</a>
							
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="总库配送信息"></table>
	  </div>
  </body>
</html>
<script type="text/javascript">
	function query(){
		$dg.datagrid('load',{
			queryType:'0',//查询类型
			stkCodeId:$("#stkCodeId").val(),
			stkTypeId:$("#stkTypeId").val(),
			taskId:$("#taskId").val(),
			task_Name:$("#task_Name").val(),
			cardType:$("#startDate").val(),
			taskStartDate:$("#endDate").val()
	
		});
	}

	//任务回退
	function taskReBack(){
		 var rows = $dg.datagrid('getChecked');
		 var dataSeqs="";
		 var TASK_STATE="";
		 var taskState="";
		 var TASK_SRC="";
		 if(rows.length==1){
			 for(var d=0;d<rows.length;d++){
				 taskState = rows[d].TASKSTATE;
				 TASK_STATE= rows[d].TASK_STATE;
				 TASK_SRC=rows[d].TASK_SRC;
					if(taskState!='00'){
						$.messager.alert("系统消息","任务状态为【"+TASK_STATE+"】，不能回滚!","error");
						return;
					}
					if(TASK_SRC!='0'){
						$.messager.alert("系统消息","申领方式为【规模申领】，不能回滚!","error");
						return;
					}
					TASK_SRC="";
					taskState="";
			 }
			 //组转勾选的参数
			 $.messager.confirm('系统消息','回滚之后就不可回退的，你真的确定回滚吗？', function(r){
	     		if (r){
	  				 $.post("/stockManage/StockAction!delTaskBack.action", {taskId:rows[0].TASK_ID},
	  						   function(data){
	  						     	if(data.status == '0'){
	  						     		$dg.datagrid('reload');
	  						     		$.messager.alert('系统消息','回滚保存成功','info');
	  						     	}else{
	  						     		$.messager.alert('系统消息',data.errMsg,'error');
	  						     	}
	  						   }, "json");
	     			}
	     		});
		 }else{
			 $.messager.alert('系统消息','请选择一条记录进行回滚','info');
			 return;
		 }
	 }
	
</script>