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

var $queryCardType;
$(function() {
	createSysCode("cardType",{codeType:"CARD_TYPE",codeValue:"810"});
	//查询条件卡类型
});
function readCard(){
	$.messager.progress({text:'正在获取卡信息，请稍后....'});
	cardmsg = getcardinfo();
	if(dealNull(cardmsg["card_No"]).length == 0){
		$.messager.progress('close');
		$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + cardmsg["errMsg"],"error");
		return;
	}
	$.messager.progress('close');
	$('#cardNo').val(cardmsg["card_No"]);
	isreadcard = 0;
	curreadcardno = cardmsg["card_No"];
	query();
}
//新增或是编辑保存
function toSaveInfo(){
	if(dealNull($("#cardType").combobox('getValue')) == ''){
		$.messager.alert('系统消息','卡类型不能为空！','error');
		return;
	}
	if(dealNull($("#startNum").val()) == ''){
		$.messager.alert('系统消息','起始卡号不能为空！','error');
		return;
	}
	if(dealNull($("#endNum").val()) == ''){
		$.messager.alert('系统消息','结束卡号不能为空！','error');
		return;
	}
	if(dealNull($("#agtTelNo").val()) == ''){
		$.messager.alert('系统消息','客户联系电话不能为空！','error');
		return;
	}
     $.messager.confirm("系统消息","您确定要确认批量销售吗？",function(r){
	 if(r){
			$.messager.progress({text:'数据处理中，请稍后....'});
			$.ajax({
				url:"/rechargeCard/RechargeCardSellAction!saveBatchCardSell.action",
				data:{ 
					cardType:$('#cardType').combobox('getValue'),
					startNum:$('#startNum').val(),
					endNum:$('#endNum').val(),
					totNum:$('#totNum').val(),
					agtTelNo:$('#agtTelNo').val(),
					agtName:$('#agtName').val(),
					agtCertNo:$('#agtCertNo').val(),
					totAmt:$('#totAmt').val()
				  },
				success: function(rsp){
					$.messager.progress('close');
					rsp = $.parseJSON(rsp);
					$.messager.alert('系统消息',rsp.message,(rsp.status ? 'info':'error'),function(){
						if(rsp.status){
							showReport('报表信息',rsp.dealNo);
							$("#dg").datagrid('reload');
						}
					});
				},
				error:function(){
					$.messager.progress('close');
					$.messager.alert("系统消息","确认批量销售发生错误：请求失败，请重试！","error");
				}
			});
		}
	});
}

function query(){
	var certNo=$('#certNo').val();
	var cardNo=$('#cardNo').val();
	if(dealNull(certNo) == ''&& dealNull(cardNo) == ''){
		$.messager.alert('系统消息','证件编号和卡号不能同时为空','error');
		return;
	}
   $dg.datagrid('load',{
	    queryType:'0',
		certNo:$("#certNo").val(),
		name:$("#cardNo").val()
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
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>充值卡批量 销售</strong></span></span>
		</div>
     </div>
	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;" class="datagrid-toolbar">
        <h3 class="subtitle">充值卡批量 销售</h3>
	     <form id="form" method="post" >
				<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tablegrid">
				<tr>
					<td class="tableleft" align="right" width="5%">卡类型:</td>
					<td class="tableright" align="left" width="12%"><input id="cardType" name="cardType" type="text"  class="textinput easyui-validatebox"  required="required" style="width:174px;" data-options="missingMessage:'请选择卡类型',invalidMessage:'请选择卡类型',required:true"/></td>
					<td class="tableleft" align="right" width="5%">起始卡号:</td>
					<td class="tableright" align="left" width="12%"><input name="startNum"  maxLength="20" class="textinput easyui-validatebox" class="easyui-textbox easyui-validatebox" data-options="required:true,missingMessage:'请输入起始卡号',invalidMessage:'请输入起始卡号'" /></td>
					<td class="tableleft" align="right" width="5%">结束卡号:</td>
					<td class="tableright" align="left" width="12%"><input name="endNum"  maxLength="20" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入结束卡号',invalidMessage:'请输入结束卡号'"/></td>
					<td class="tableleft" align="right" width="5%">总数量:</td>
					<td class="tableright" align="left" width="15%"><input type="text" name="count" class="textinput easyui-validatebox" maxlength="7" value="" id="count" onblur="javascript:check();"/>张</td>
				</tr>
				<tr>
				    <td class="tableleft" align="right" width="5%">联系电话:</td>
					<td class="tableright" align="left" width="12%"><input type="text" name="agtTelNo" class="textinput easyui-validatebox" id="agtTelNo" data-options="required:true,missingMessage:'请输入联系电话',invalidMessage:'请输入联系电话'"/></td>
					<td class="tableleft" align="right" width="5%">客户名称:</td>
					<td  class="tableright" align="left" width="12%"><input type="text" name="agtName" class="textinput" maxlength="20"  id="agtName"/>	</td>
					<td class="tableleft" align="right" width="5%">证件号码:</td>
					<td class="tableright" align="left" width="12%"><input type="text" name="agtCertNo" class="textinput" id="agtCertNo"/></td>
					<td class="tableleft" align="right" width="5%">总金额:</td>
					<td class="tableright" align="left"><input type="text" name="totNum" class="textinput easyui-validatebox" maxlength="7" id="totNum" />元</td>
				</tr>
				<tr>
				<td colspan="8" align="center">
				  <a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="toSaveInfo();">保存</a>
					</td>
				</tr>
			</table>
	   </form>
	   </div>
  </body>
</html>
