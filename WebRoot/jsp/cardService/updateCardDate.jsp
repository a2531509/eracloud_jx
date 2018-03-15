
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
function validCard(){
	$.post("cardService/cardServiceAction!getCardAndPersonInfo.action","cardNo=" + $("#cardNo").val(),function(data,status){
		$.messager.progress("close");
		if(status == "success"){
			$("#certNo").val(data.person.certNo);
			$("#fkDate").val(data.card.issueDate);
			$("#name").val(data.person.name);
			if(dealNull(data.card.cardNo).length == 0){
				$.messager.alert("系统消息","验证卡片信息发生错误：卡号信息不存在，该卡不能进行充值。","error",function(){
					window.history.go(0);
				});
			}
		}else{
			$.messager.alert("系统消息","验证卡信息时出现错误，请重试...","error",function(){
				window.history.go(0);
			});
		}
	},"json").error(function(){
		$.messager.alert("系统消息","验证卡信息时出现错误，请重试...","error",function(){
			window.history.go(0);
		});
	});
}

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
	validCard();
}
//新增或是编辑保存
function toSaveInfo(){
	var fkDate=$('#fkDate').val();
	if(dealNull(fkDate) == ''){
		$.messager.alert('系统消息','有效日期不能为空！','error');
		document.getElementById("fkDate").focus();
		return;
	}
     $.messager.confirm("系统消息","您确定要确认修改卡片有效日期吗？",function(r){
      wirtecard_UpdateDate($('#cardNo').val(),$('#fkDate').val());
	 if(r){
		$.messager.progress({text : "正在进行，请稍后...."});
		$.post("cardService/cardServiceAction!UpdateCardDate.action",{cardNo:$("#cardNo").val(),fkDate:$("#fkDate").val()},function(data,status){
			if(status == "success"){
				if(data.status != "0"){
					$.messager.progress("close");
					$.messager.alert("系统消息",data.msg,"error");
				}else if(data.status == "0"){
					$.messager.progress("close");
					$.messager.alert("系统消息",data.msg,"error");
				
				}
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","修改有效日期请求出现错误，请重试！","error",function(){
					window.history.go(0);
				});
			}
		},"json").error(function(){
				$.messager.progress("close");
				$.messager.alert("系统消息","修改有效日期请求出现错误，请重试！","error",function(){
					window.history.go(0);
				});
		});
	}
	});
}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow:hidden;">
		<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对<span class="label-info"><strong>修改卡片有效日期</strong></span></span>
		</div>
     </div>
     	<div data-options="region:'center',split:false,border:false" style="height:auto;overflow:hidden;">
        <h3 class="subtitle">修改卡片有效日期</h3>
	     <form id="form" method="post" >
				<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="tablegrid">
				<tr>
				    <td class="tableleft" align="right" width="8%">卡号:</td>
					<td class="tableright" align="left" width="25%"><input name="cardNo" id="cardNo"   maxLength="20" class="textinput easyui-validatebox" data-options="required:true,missingMessage:'请输入卡号',invalidMessage:'请输入卡号'" />*
					<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a> 
					</td>
					<td class="tableleft" align="right" width="8%">有效日期:</td>
					<td class="tableright" align="left" width="25%"><input id="fkDate" type="text" class="textinput" name="fkDate"  class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd'})" />*</td>
				    <td class="tableright" align="left" colspan="2"><a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-save"  plain="false" onclick="toSaveInfo();">确认保存</a></td>
				</tr>
				<tr>
					<td class="tableleft" align="right" width="8%">客户名称:</td>
					<td class="tableright" align="left" width="18%"><input type="text" id="name" name="name" readonly="readonly" disabled="disabled" class="textinput" maxlength="25"/></td>
					<td class="tableleft" align="right" width="8%">证件号码:</td>
					<td class="tableright" align="left" width="18%"><input name="certNo"  class="textinput" id="certNo" type="text" readonly="readonly" disabled="disabled"/></td>
				    <td align="center" colspan="2"></td>
				</tr>
			</table>
	   </form>
	   </div>
  </body>
</html>