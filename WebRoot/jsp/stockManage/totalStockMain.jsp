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
<title>总库入库</title>
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
	isFirstLoad = true;
	if("${defaultErrorMasg}" != ''){
		$.messager.alert("系统消息","${defaultErrorMasg}","error");
	}
});
//新增或是编辑保存
function toSaveInfo(){
	var certNo=$('#certNo2').val();
	if(dealNull(certNo2) == ''){
		$.messager.alert('系统消息','证件号码不能为空,请先进行查询再进行申领！','error');
		return;
	}

	$.messager.confirm("系统消息","您确定要确认申领吗？",function(r){
		 if(r){
			 $.messager.progress({title : '提示',text : '数据处理中，请稍后....'});
			 $.post("/stockManage/StockAction!saveTotalStockMain.action", 
				{ 
				    bustype:$('#bustype2').combobox('getValue'),
				    isUrgent:$('#makeCardWay2').combobox('getValue')
				  },
				 function(data){
					 $.messager.progress('close');
			     	if(data.status == '0'){
			     		$.messager.alert('系统消息','申领保存成功','info',function(){
			     			$dg.datagrid('reload');
			     		});
			     	}else{
			     		$.messager.alert('系统消息',data.msg,'error');
			     	}
			 },"json");
		 }
	});
}

</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>总库入库进行入库操作。</strong></span></span>
		</div>
     </div>
	<div data-options="region:'center',border:false" style="overflow:auto;padding:0px;" class="datagrid-toolbar">
		<div id="tb" style="padding:2px 0,width:100%">
			<table class="tablegrid" width="100%" cellpadding="0" cellspacing="0" >
				<tr >
					<td align="right" class="tableleft" width="8%">库存代码：</td>
					<td align="left" class="tableright" width="18%"><input name="certNo"  class="textinput" id="certNo" type="text"/></td>
					<td  align="right" class="tableleft" width="8%">库存类型：</td>
					<td align="left" class="tableright"><input name="clientName"   class="textinput" id="clientName" type="text"/></td>
					
				</tr>
				<tr >
					<td align="right" class="tableleft">起始号码:</td>
					<td align="left" class="tableright"><input name="certNo" class="textinput" id="certNo" type="text"/></td>
					<td align="right" class="tableleft">终止号码:</td>
					<td align="left" class="tableright"><input name="certNo"  class="textinput" id="certNo" type="text"/></td>
				</tr>
				<tr>
					<td align="right" class="tableleft">数量：</td>
					<td colspan="4" align="left" class="tableright"><input name="num"   class="textinput" id="num" type="text"/>温馨提示：数量、起止号码必须有一项不为空，有起止号码时，以号码为准计算数量，无起止号码时，只取数量 </td>
			    </tr>
			    <tr>
				<td colspan="2" align="center">
					<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="toSaveInfo();">入库保存</a>
				</td>
				<td colspan="2" align="center"></td>
			    </tr>
			</table>
		</div>
		
	</div>
  </body>
</html>
