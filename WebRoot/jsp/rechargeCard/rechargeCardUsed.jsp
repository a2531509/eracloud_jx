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
<title>个人申领</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">    
<link rel="stylesheet" type="text/css" href="css/jquery-ui.css">
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript" src="js/jquery-ui.js"></script>
<style>
	.tablegrid th{font-weight:700};
</style>
<script type="text/javascript">
var isFirstLoad = true;
var $dg;
var $temp;
var $grid;
$(function(){
	$(document).keypress(function(event){
		if(event.keyCode == 13){
			query();
		}
	});
	
	isFirstLoad = true;
	if("${defaultErrorMasg}" != ''){
		$.messager.alert("系统消息","${defaultErrorMasg}","error");
	}
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

//新增或是编辑保存
function toSaveInfo(){
	var allRows = $personinfo.datagrid('getSelections');
	var dealNos  = "";
	var SALE_STATE  = "";
	if(allRows){
		for(var d=0;d<allRows.length;d++){
			dealNos += allRows[d].DEAL_NO + ",";
		}
		for(var d=0;d<allRows.length;d++){
			SALE_STATE = allRows[d].SALE_STATE;
			if(SALE_STATE==0){
				$.messager.alert('系统消息','不能启用保存!','error');
				return;
			}
			SALE_STATE="";
		}
	}
	var dealNos = dealNos.substring(0,dealNos.length -1)
	if(dealNos.length==0){
		$.messager.alert('系统消息','至少选择一行记录进行处理!','error');
		return;
	}
	$.messager.confirm('系统消息','您是否确定要进行批量启用么？',function(is){
		if(is){  
			//正式提交
			setTimeout('Timeout()', 60000); 
			$.messager.progress({text : '正在生成预申领数据，请稍后....'});
			$.post('rechargeCard/RechargeCardSellAction!saveBatchCardUsed.action',
					{
				      dealNoStr:dealNos,
					},
					function(data,status){
						$.messager.progress('close');
						if(status == 'success'){
							if(data.status == '0'){
								//刷新表格
							    $.messager.alert('系统消息',data.msg,'warning',function(){
							    	 $personinfo.datagrid('load',{
							    		 queryType:'0',
							    		 endDate:$("#endDate").val(),
							    		 startDate:$("#startDate").val()
							    	 });
							    });
							   
							}else{
								$.messager.alert('系统消息',data.msg,'error');
							}
						}else{
							$.messager.alert('系统消息','批量启用出现错误，请重试！','error');
						}
					},
			'json');
		}
	});
}

function query(){
   $dg.datagrid('load',{
	    queryType:'0',
	    endDate:$("#endDate").val(),
		startDate:$("#startDate").val()
	});
}
function readIdCard(){
	var certinfo = getcertinfo();
	$("#certNo").val(certinfo["cert_No"]);
	query();
}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>充值卡销售信息进行批量启用操作。</strong></span></span>
		</div>
     </div>
       <form id="form" method="post" >
	<div data-options="region:'center',border:true" style="border-left:none;width:100%";overflow:hidden;padding:0px;" >
		<div id="tb" style="padding:2px 0,width:100%">
		<table cellpadding="0" cellspacing="0"  width="100%" class="tablegrid">
				<tr>
					<td  class="tableleft" align="right" width="8%">销售日期始：</td>
					<td  class="tableright" align="left" width="15%" ><input id="startDate" name="startDate" type="text" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
					<td  class="tableleft" align="right" width="8%">销售日期止：</td>
					<td  class="tableright" align="left" width="15%" ><input id="endDate" name="endDate" type="text"  class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})"/></td>
					<td  class="tableright" colspan="2">
						<a style="text-align:center;margin:0 auto;" data-options="iconCls:'icon-search',plain:false" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="toSaveInfo();">启用保存</a>
					</td>
				</tr>
			</table>
		</div>
  		<table id="dg" title="销售信息" style="width:100%"></table>
  	</div>
  </form>
  </body>
</html>
