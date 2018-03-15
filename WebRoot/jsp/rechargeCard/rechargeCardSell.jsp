
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
$(function(){
	$.autoComplete({
		id:"agtCertNo",
		text:"cert_no",
		value:"name",
		table:"base_personal",
		keyColumn:"cert_no",
		//minLength:"1"
	},"agtName");
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
	var cardNo=$('#cardNo').val();
	var agtTelNo=$('#agtTelNo').val();
	if(dealNull(cardNo) == ''){
		$.messager.alert('系统消息','卡号不能为空！','error');
		document.getElementById("cardNo").focus();
		return;
	}
	if(dealNull(agtTelNo) == ''){
		$.messager.alert('系统消息','联系电话不能为空！','error');
		return;
	}
     $.messager.confirm("系统消息","您确定要确认销售保存吗？",function(r){
	 if(r){
			$.messager.progress({text:'数据处理中，请稍后....'});
			$.ajax({
				url:"/rechargeCard/RechargeCardSellAction!saveOneCardSell.action",
				data:{ 
				    cardNo:$('#cardNo').val(),
				    agtTelNo:$('#agtTelNo').val(),
				    agtName:$('#agtName').val(),
				    agtCertNo:$('#agtCertNo').val()
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
					$.messager.alert("系统消息","销售保存发生错误：请求失败，请重试！","error");
				}
			});
		}
		});
}

</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>充值卡单张 销售</strong></span></span>
		</div>
     </div>
     	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
        <h3 class="subtitle">充值单张销售</h3>
	     <form id="form" method="post" >
				<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tablegrid">
				<tr>
				    <td class="tableleft" align="right" width="8%">卡号:</td>
					<td class="tableright" align="left" width="18%"><input name="cardNo" id="cardNo"   maxLength="20" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入卡号',invalidMessage:'请输入卡号'" />*
					<!--<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>  -->
					</td>
					<td class="tableleft" align="right" width="8%">联系电话:</td>
					<td class="tableright" align="left" width="18%"><input type="text" name="agtTelNo"  maxLength="11" class="textinput easyui-validatebox" id="agtTelNo" data-options="required:true,missingMessage:'请输入联系电话',invalidMessage:'请输入联系电话'" />*</td>
				    <td class="tableright" align="left" colspan="2"><a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="toSaveInfo();">保存</a></td>
				</tr>
				<tr>
					<td class="tableleft" align="right" width="8%">客户名称:</td>
					<td class="tableright" align="left" width="18%"><input type="text" name="agtName" id="agtName" class="textinput" maxlength="25"/></td>
					<td class="tableleft" align="right" width="8%">证件号码:</td>
					<td class="tableright" align="left" width="18%"><input type="text" name="agtCertNo" class="textinput" id="agtCertNo"/></td>
				    <td align="center" colspan="2"></td>
				</tr>
			</table>
	   </form>
	   </div>
  </body>
</html>
