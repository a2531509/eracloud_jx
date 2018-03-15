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
<title>${ACC_KIND_NAME_LJ }充值</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">   
<jsp:include page="../../layout/script.jsp"></jsp:include>
<style type="text/css">
	.label_left{text-align:right;padding-right:2px;height:30px;font-weight:700;}
	.label_right{text-align:left;padding-left:2px;height:30px;}
	#tb table,#tb table td{border:1px dotted rgb(149, 184, 231);}
	#tb table{border-left:none;border-right:none;}
	body{font-family:'微软雅黑'}
</style> 
<script type="text/javascript">
	var cardinfo;
	var currentCard;
	$(function(){
		$('#cardNo').validatebox('validate');
		$('#cardAmt').validatebox('validate');
	});
	function readCard(){
		$.messager.progress({text : "正在验证卡信息,请稍后..."});
		cardinfo = getcardinfo();
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请拿起并重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"error",function(){
				window.history.go(0);
			});
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
		validCard();
	}
	function validCard(){
		$.post("cardService/cardServiceAction!getCardAndPersonInfo.action","cardNo=" + $("#cardNo").val(),function(data,status){
			$.messager.progress("close");
			if(status == "success"){
				$("#certType").val(data.person.certTypeStr);
				$("#certNo").val(data.person.certNo);
				$("#cardType").val(data.card.cardTypeStr);
				$("#cardState").val(data.card.note);
				$("#busType").val(data.card.busTypeStr);
				$("#fkDate").val(data.card.issueDate);
				$("#cardStateHidden").val(data.card.cardState);
				$("#name").val(data.person.name);
				$("#csex").val(data.person.csex);
				$("#cardAmt").val(Number(data.acc.bal).div100());
				currentCard = data.card.cardNo;
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
	function queryCard(){
		if(dealNull($("#cardNo").val()).length != 20){
			$.messager.alert("系统消息","输入的卡号不正确！请仔细核对卡片信息并重新输入！<br/><span style=\"color:red;\">提示：卡号为有效的20位数字或字母组成</span>","warning",function(){
				//window.history.go(0);
			});
			return;
		}
		$.messager.progress({text : "正在验证卡信息,请稍后..."});
		validCard();
	}
	function tijiao(){
		if(currentCard != $("#cardNo").val()){
			$.messager.alert("系统消息","卡号已被修改，请重新进行读卡或查询，再进行充值！","warning");
			return;
		}
		if($("#cardNo").val().replace(/\s/g,"") == "" || $("#cardAmt").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请先进行读卡或查询以获取充值卡号和当前账户余额信息！","error");
			return;
		}
		if($("#cardStateHidden").val() != "1"){
			$.messager.alert("系统消息","当前卡片状态不正常，不能进行${ACC_KIND_NAME_LJ }进行充值！","error");
			return;
		}
		if($("#amt").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请输入${ACC_KIND_NAME_LJ }充值金额！","error",function(){
				$("#amt").focus();
			});
			return;
		}
		if($("#amt2").val() == ""){
			$.messager.alert("系统消息","请输入${ACC_KIND_NAME_LJ }确认充值金额！","error",function(){
				$("#amt2").focus();
			});
			return;
		}
		var exp = /^\d+(\.?\d{1,2})?$/g;
		if(!exp.test($("#amt").val())){
			$.messager.alert("系统消息","充值金额格式不正确，请重新输入！","error",function(){
				$("#amt").val("");
				$("#amt").focus();
			});
			return;
		}
		if(isNaN($("#amt").val())){
			$.messager.alert("系统消息","充值金额格式不正确，请重新进行输入！","error",function(){
				$("#amt").val("");
				$("#amt").focus();
			});
			return;
		}
		if($("#amt").val() != $("#amt2").val()){
			$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }充值金额和确认充值金额不一致，请重新输入！","error",function(){
				$("#amt2").val("");
				$("#amt2").focus();
			});
			return;
		}
		if(parseFloat($("#amt").val()) <= 0){
			$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }充值金额必须大于0！","error",function(){
				$("#amt").val("");
				$("#amt").focus();
			});
			return;
		}
		$.messager.confirm("系统消息","您确定要为卡号为【" + $("#cardNo").val() + "】的卡片充值<" + $("#amt").val() + ">元？", function(is) {
			if(is){
				$.messager.progress({text : "正在进行充值，请稍后...."});
				$.post("recharge/rechargeAction!saveOnlineAccountR.action",{cardNo:$("#cardNo").val(),amt:$("#amt").val()},function(data,status){
					if(status == "success"){
						if(data.status != "0"){
							$.messager.progress("close");
							$.messager.alert("系统消息",data.msg,"error");
						}else if(data.status == "0"){
							$.messager.progress("close");
							if(data.isReminder == "0") {
								$.messager.alert("系统消息",data.reminderMsg,"info",function(){
									showReport("${ACC_KIND_NAME_LJ }充值",data.dealNo,function(){
										window.history.go(0);
									});
								});
							} else {
								showReport("${ACC_KIND_NAME_LJ }充值",data.dealNo,function(){
									window.history.go(0);
								});
							}
						}
					}else{
						$.messager.progress("close");
						$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }充值请求出现错误，请重试！","error",function(){
							window.history.go(0);
						});
					}
				},"json").error(function(){
						$.messager.progress("close");
						$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }充值请求出现错误，请重试！","error",function(){
							window.history.go(0);
						});
				});
			}
		});
	}
	function validRmb(obj){
		var v = obj.value;
		var exp = /^\d+(\.?\d{0,2})?$/g;
		if(!exp.test(v)){
			obj.value = v.substring(0,v.length - 1);
		}else{
			var zeroexp = /^0{2,}$/g;
			if(zeroexp.test(v)){
				obj.value = 0;
			}
		}
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
 			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对卡片进行<span class="label-info"><strong>${ACC_KIND_NAME_LJ }充值</strong></span>操作!</span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="height:50px;margin:0px;width:auto;border-left:none;border-bottom:none;">
		<form id="form" method="post">
			<input type="hidden" value="9" name="cardStateHidden" id="cardStateHidden"/><!-- 卡状态 -->
		</form>	
	  	<div id="tb" style="padding:2px 0;" class="easyui-panel datagrid-toolbar" data-options="cache:false,border:false,fit:true,tools:'#toolspanel'" title="${ACC_KIND_NAME_LJ }充值">
			<table cellpadding="0" cellspacing="0" id="toolpanel" style="width:100%">
				<tr>
					<td width="20%" align="right" class="label_left">卡号：</td>
					<td align="left" class="label_right"><input name="cardNo" data-options="required:true,invalidMessage:'请读卡以获取卡号信息',missingMessage:'请读卡以获取卡号信息'" class="textinput easyui-validatebox" id="cardNo" type="text" maxlength="20"/></td>
					<td align="right" class="label_left">账户余额：</td>
					<td class="label_right">
						<input name="cardAmt" data-options="required:true,invalidMessage:'请读卡以获取账户余额信息',missingMessage:'请读卡以获取账户余额信息'" class="textinput easyui-validatebox" id="cardAmt" type="text" readonly="readonly"/>
						<shiro:hasPermission name="OnlineRechargeReadCard">
							<a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="readCard()">读卡</a>
						</shiro:hasPermission>
						<shiro:hasPermission name="OnlineRechargeQueryCard">
							<a  data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton"    onclick="queryCard()">查询</a>
						</shiro:hasPermission>
					</td>
				</tr>
				<tr>
					<td align="right" class="label_left">姓名：</td>
					<td class="label_right"><input id="name" type="text" class="textinput" name="name" readonly="readonly" disabled="disabled"/></td>
					<td align="right" class="label_left">性别：</td>
					<td class="label_right"><input name="csex"  class="textinput" id="csex" type="text" readonly="readonly" disabled="disabled"/></td>
				</tr>
				<tr>
					<td align="right" class="label_left">证件类型：</td>
					<td class="label_right"><input id="certType" type="text" class="textinput" name="certType" readonly="readonly" disabled="disabled"/></td>
					<td align="right" class="label_left">证件号码：</td>
					<td class="label_right"><input name="certNo"  class="textinput" id="certNo" type="text" readonly="readonly" disabled="disabled"/></td>
				</tr>
				<tr>
					<td align="right" class="label_left">卡类型：</td>
					<td class="label_right"><input id="cardType" type="text" class="textinput" name="cardType" readonly="readonly" disabled="disabled"/></td>
					<td align="right" class="label_left">卡状态：</td>
					<td class="label_right"><input id="cardState" type="text" class="textinput" name="cardState"  readonly="readonly" disabled="disabled"/></td>
				</tr>
				<tr>
					<td align="right" class="label_left">公交类型：</td>
					<td class="label_right"><input id="busType" type="text" class="textinput" name="busType" readonly="readonly" disabled="disabled"/></td>
					<td align="right" class="label_left">发卡日期：</td>
					<td class="label_right"><input id="fkDate" type="text" class="textinput" name="fkDate"  readonly="readonly" disabled="disabled"/></td>
				</tr>
				<tr>
					<td align="right" class="label_left">充值金额：</td>
					<td class="label_right"><input id="amt" type="text" class="textinput easyui-validatebox" maxlength="8" required="required" name="amt" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span></td>
					<td align="right" class="label_left">确定充值金额：</td>
					<td class="label_right">
						<input id="amt2" type="text" class="textinput easyui-validatebox" required="required" maxlength="8" onkeyup="validRmb(this)" onkeydown="validRmb(this)" name="amt2"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span>
						<shiro:hasPermission name="OnlineRechargeSave">
							<a  data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="tijiao()">确定充值</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
	</div>
</body>
</html>