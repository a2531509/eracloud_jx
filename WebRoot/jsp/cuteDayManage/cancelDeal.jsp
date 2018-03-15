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
    <title>联机账户充值撤销</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
<jsp:include page="../../layout/script.jsp"></jsp:include>
<script type="text/javascript">
	var $grid;
	$(function(){
		 $grid = createDataGrid({
			 id:"dg",
			 url:"adjustSysAccAction/adjustSysAccAction!dealNoInfoQuery.action",
			 idField:"V_V",
			 fitColumns:false,
			 scrollbarSize:0,
			 columns:[[
				 {field:"V_V",title:"",sortable:true,checkbox:true},
				 {field:"DEALNO",title:"流水号",sortable:true,width:parseInt($(this).width() * 0.05)},
				 {field:"ACCNO",title:"账户号",sortable:true,width:parseInt($(this).width() * 0.05)},
				 {field:"ACCKIND",title:"账户类型",sortable:true,width:parseInt($(this).width() * 0.05)},
				 {field:"ACCBAL",title:"交易前金额",sortable:true,align:"right",width:parseInt($(this).width() * 0.1)},
				 {field:"AMT",title:"交易金额",sortable:true,align:"right",width:parseInt($(this).width() * 0.05)},
				 {field:"DEALDATE",title:"交易日期",sortable:true,width:parseInt($(this).width() * 0.12)},
				 {field:"DEALSTATE",title:"交易状态",sortable:true},
	        	 {field:"CLR_DATE",title:"清分日期",sortable:true}
             ]]
		 });
	});
	function query(){
		if($("#dealNo").val().replace(/\s/g,"") == "" || $("#clrDate").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请输入查询流水号和清分日期！","error");
			return;
		}
		$grid.datagrid("load",{
			queryType:"0",
			dealNo:$("#dealNo").val(),
			clrDate:$("#clrDate").val()
		});
	}
	function saveCancel(){
		var temprow = $grid.datagrid("getSelected");
		if(temprow){
			$.messager.confirm("系统消息","您确定要撤销流水号 = " + temprow.DEALNO + "的交易记录吗？",function(is){
				if(is){
					$.messager.progress({text : "正在进行撤销,请稍后..."});
					$.post("adjustSysAccAction/adjustSysAccAction!saveDealCancel.action",{dealNo:temprow.DEALNO,clrDate:temprow.CLR_DATE,dealCode:temprow.DEALCODE,trAmt:temprow.AMT,userId:temprow.USER_ID},function(data,status){
						$.messager.progress("close");
						if(status == "success"){
							if(data.status != "0"){
								$.messager.alert("系统消息",data.errMsg,"error");
							}else if(data.status == "0"){
								$.messager.alert("系统消息",data.errMsg,"info");
							}
						}else{
							$.messager.alert(",系统消息","联机账户充值撤销出现错误，请重试！","error");
						}
					},"json");
				}
			});
		}else{
			$.messager.alert("系统消息","联机账户充值撤销，请选择一条充值记录！","error");
			return;
		}
	}
	
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
 		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>联机账户充值记录</strong></span><span class="label-info">进行撤销操作！<span style="color:red;font-weight:600">注意：</span>只有当日且充值成功的记录才能进行联机账户充值撤销！</span></span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="height:50px;margin:0px;width:auto;border-left:none;border-bottom:none;">
	  	<div id="tb" style="padding:2px 0">
			<table style="width:100%" class="tablegrid">
				<tr>
					<tr>
						<td class="tableleft" style ="width:10%">流水号：</td>
						<td class="tableright" style ="width:10%"><input id="dealNo" name="dealNo" type="text" class="textinput"/></td>
						<td class="tableleft" style ="width:10%">清分日期：</td>
						<td class="tableright" style ="width:10%"><input name="clrDate" id="clrDate" class="textinput Wdate" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})"/></td>
						<td class="tableright">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" id="subbutton" name="subbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-cancel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="saveCancel()">确定撤销</a>
						</td>
					</tr>
			</table>
		</div>
  		<table id="dg" title="交易记录"></table>
	</div>
</body>
</html>