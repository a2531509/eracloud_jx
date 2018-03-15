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
    <title>充值卡销售撤销</title>
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
			$(document).keypress(function(event){
				if(event.keyCode == 13){
					query();
				}
			});
			
			$dg = $("#dg");
			$grid=$dg.datagrid({
				 url : "/rechargeCard/RechargeCardSellAction!toBatchCardUsedQuery.action",
				 pagination:true,
					rownumbers:true,
					border:true,
					striped:true,
					fit:true,
					fitColumns: true,
					scrollbarSize:0,
					autoRowHeight:true,
					columns : [ [   {field:'DEAL_NO',title:'id',sortable:true,checkbox:'ture'},
									{field:'DEALNOS',title:'业务流水号',sortable:true,width : parseInt($(this).width() * 0.08)},
									{field:'SALE_DATE',title:'销售时间',sortable:true,width : parseInt($(this).width() * 0.08)},
									{field:'CARD_TYPE_CATALOG',title:'卡种类',sortable:true,width : parseInt($(this).width() * 0.05)},
									{field:'START_CARD_NO',title:'起始卡号',sortable:true,width : parseInt($(this).width() * 0.08)},
									{field:'END_CARD_NO',title:'结束卡号',sortable:true,width : parseInt($(this).width() * 0.08)},
									{field:'TOT_NUM',title:'总数量',sortable:true,width : parseInt($(this).width() * 0.05)},
									{field:'TOT_AMT',title:'总金额',sortable:true,width : parseInt($(this).width() * 0.05)},
									{field:'PAY_WAY',title:'付款标志',sortable:true,width : parseInt($(this).width() * 0.05)},
									{field:'INV_FLAG',title:'开票标志',sortable:true,width : parseInt($(this).width() * 0.05)},
									{field:'VRF_FLAG',title:'审核标志',sortable:true,width : parseInt($(this).width() * 0.05)},
									{field:'AGT_NAME',title:'客户姓名',sortable:true,width : parseInt($(this).width() * 0.08)},
									{field:'AGT_CERT_NO',title:'证件号码',sortable:true,width : parseInt($(this).width() * 0.08)},
									{field:'AGT_TEL_NO',title:'客户电话',sortable:true,width : parseInt($(this).width() * 0.05)},
									{field:'SALE_STATE',title:'业务状态',sortable:true,width : parseInt($(this).width() * 0.05)},
									{field:'USER_ID',title:'操作员编号',sortable:true,width : parseInt($(this).width() * 0.05)}
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
				<span>在此你可以对<span class="label-info"><strong>充值 卡销售信息</strong></span>进行撤销售操作!注意已经启用过的，不能进行销售撤销操作。谨慎操作！</span>
			</div>
	</div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
			<div id="tb" style="padding:2px 0,width:100%">
				<table cellpadding="0" cellspacing="0"  style="width:100%" class="tablegrid">
					<tr>
						<td  class="tableleft" align="right" width="8%">网点编号：</td>
						<td  class="tableright" align="left" width="17%" ><input id="brchId" type="text" class="textinput" name="brch.brchId" value="${brch.brchId}"  style="cursor:pointer;"/></td>
						<td  class="tableleft" align="right" width="8%">网点名称：</td >
						<td  class="tableright" align="left" width="17%" ><input id="brchName" type="text" class="textinput" name="brch.fullName" value="${brch.fullName}" style="cursor:pointer;" /></td>
						<td  class="tableright" colspan="2"></td>
					</tr>
					<tr>
						<td  class="tableleft" align="right">销售日期始：</td>
						<td  class="tableright" align="left" ><input id="startDate" name="startDate" type="text" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
						<td  class="tableleft" align="right">销售日期止：</td>
						<td  class="tableright" align="left" ><input id="endDate" name="endDate" type="text"  class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
						<td  class="tableright" colspan="2">
							<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="toquery()">查询</a>
						    <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="taskReBack();">撤销保存</a>
						    <a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-viewInfo',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="toview()">查看明细</a>
						</td>
					</tr>
				</table>
			</div>
	  		<table id="dg" title="销售信息"></table>
	  </div>
  </body>
</html>
<script type="text/javascript">
	function query(){
		$dg.datagrid('load',{
			queryType:'0',//查询类型
			brchId:$("#brchId").val(),
			brchName:$("#brchName").val(),
			startDate:$("#startDate").val(),
			endDate:$("#endDate").val()
		});
	}

	//回退
	function taskReBack(){
		 var rows = $dg.datagrid('getChecked');
		 var selectIds="";
		 var SALE_STATE="";
		 if(rows.length==1){
			 for(var d=0;d<rows.length;d++){
				 selectIds = rows[d].DEAL_NO;
			 }
			 SALE_STATE = rows[d].SALE_STATE;
				if(SALE_STATE==0){
					$.messager.alert('系统消息','不能销售撤销!','error');
					return;
				}
			 //组转勾选的参数
			 $.messager.confirm('系统消息','你真的确定销售撤销吗？', function(r){
	     		if (r){
	  				 $.post("/rechargeCard/RechargeCardSellAction!saveOneCardUndo.action", {dealNo:selectIds},
  						   function(data){
  						     	if(data.status == '0'){
  						     		$dg.datagrid('reload');
  						     		$.messager.alert('系统消息','销售撤销保存成功','info');
  						     	}else{
  						     		$.messager.alert('系统消息',data.errMsg,'error');
  						     	}
  						   }, "json");
	     			}
	     		});
		 }else{
			 $.messager.alert('系统消息','请选择一条记录进行确认','info');
			 return;
		 }
	 }
	
</script>