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
<title>${ACC_KIND_NAME_LJ }圈存</title>
<meta http-equiv="pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">   
<jsp:include page="../../layout/script.jsp"></jsp:include>
<style type="text/css">
	.label_left{text-align:right;padding-right:2px;height:30px;font-weight:700;}
	.label_right{text-align:left;padding-left:5px;height:30px;}
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
			$.messager.alert("系统消息","读卡出现错误，请拿起并重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"warning",function(){
				window.history.go(0);
			});
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
		validCard();
	}
	function validCard(){
		$.post("cardService/cardServiceAction!getCardAndPersonInfo.action",{cardNo: $("#cardNo").val(),paySource:"0"},function(data,status){
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
					$.messager.alert("系统消息","验证卡片信息发生错误：卡号信息不存在，该卡不能进行圈存。","error",function(){
						window.history.go(0);
					});
				}else{
					$.messager.progress({text : "正在加载银行卡信息,请稍后..."});
					$.post("recharge/rechargeAction!getCardBindBankInfo.action",{cardNo: $("#cardNo").val()},function(data,status){
						if(status == "success"){
							if(data.status == "0"){
								$("#bankCardNo").val(data.alldata.bankCardNo);
								$("#bankId").val(data.alldata.bankName);
								$("#qcLimitAmt").val(data.alldata.qcLimitAmt);
								if(parseFloat(data.alldata.qcAvaiAmt) <= 0){
									$("#avaiQcLimitAmt").val("0");
								}else{
									$("#avaiQcLimitAmt").val(data.alldata.qcAvaiAmt);
								}
								$("#abcdrfg").val(data.alldata.state);
								if(data.alldata.isSetLimit == "0"){//isSetLimit
									$("#isSetLimit").html("已设限额 " + "（重设限额？<a style='color:red;cursor:pointer;' onclick='parent.addTab(\"圈存限额设置||icon-orgAccManage||jsp/cardService/qcqfLimitSet.jsp\")'>点击这里</a>）");
								}else{
									$("#isSetLimit").html("默认限额" + "（设置限额？<a style='color:red;cursor:pointer;' onclick='parent.addTab(\"圈存限额设置||icon-orgAccManage||jsp/cardService/qcqfLimitSet.jsp\")'>点击这里</a>）");
								}
								$("#todayTotAmt").val(data.alldata.qcTodayAmt);
								$("#todayTotNum").val(data.alldata.qcTodayNum);
								$.messager.progress("close");
							}else{
								$.messager.alert("系统消息","获取银行卡信息时出现错误：" + data.errMsg,"error",function(){
									window.history.go(0);
								});
							}
						}else{
							$.messager.alert("系统消息","获取银行卡信息时出现错误，请重试...","error",function(){
								window.history.go(0);
							});
						}
					},"json").error(function(){
						$.messager.alert("系统消息","获取银行卡信息时出现错误，请重试...","error",function(){
							window.history.go(0);
						});
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
			$.messager.alert("系统消息","卡号已被修改，请重新进行读卡或查询，再进行圈存！","warning");
			return;
		}
		if($("#cardNo").val().replace(/\s/g,"") == "" || $("#cardAmt").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请先进行读卡或查询以获取圈存卡号和当前账户余额信息！","warning");
			return;
		}
		if($("#cardStateHidden").val() != "1"){
			$.messager.alert("系统消息","当前卡片状态不正常，不能进行${ACC_KIND_NAME_LJ }进行圈存！","warning");
			return;
		}
		if(dealNull($("#abcdrfg").val()) != "0" && dealNull($("#abcdrfg").val()) != "1"){
			jAlert("该卡未开通银行卡自主圈存或实时圈存！","warning");
			return;
		}
		if(!$("#pwd").val()){
			$.messager.alert("系统消息","交易密码不能为空！","warning");
			return;
		}
		if($("#amt").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请输入${ACC_KIND_NAME_LJ }圈存金额！","warning",function(){
				$("#amt").focus();
			});
			return;
		}
		if($("#amt2").val() == ""){
			$.messager.alert("系统消息","请输入${ACC_KIND_NAME_LJ }确认圈存金额！","warning",function(){
				$("#amt2").focus();
			});
			return;
		}
		var exp = /^\d+(\.?\d{1,2})?$/g;
		if(!exp.test($("#amt").val())){
			$.messager.alert("系统消息","圈存金额格式不正确，请重新输入！","warning",function(){
				$("#amt").val("");
				$("#amt").focus();
			});
			return;
		}
		if(isNaN($("#amt").val())){
			$.messager.alert("系统消息","圈存金额格式不正确，请重新进行输入！","warning",function(){
				$("#amt").val("");
				$("#amt").focus();
			});
			return;
		}
		if($("#amt").val() != $("#amt2").val()){
			$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }圈存金额和确认圈存金额不一致，请重新输入！","warning",function(){
				$("#amt2").val("");
				$("#amt2").focus();
			});
			return;
		}
		if(parseFloat($("#amt").val()) > parseFloat($("#avaiQcLimitAmt").val())){
			jAlert("圈存金额不能大于今日可用圈存金额，请重新进行输入！","warning",function(){
				$("#amt").val("");
				$("#amt").focus();
			});
			return;
		}
		if(parseFloat($("#amt").val()) <= 0){
			$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }圈存金额必须大于0！","warning",function(){
				$("#amt").val("");
				$("#amt").focus();
			});
			return;
		}
		$.messager.confirm("系统消息","您确定要为卡号为【" + $("#cardNo").val() + "】的卡片圈存<" + $("#amt").val() + ">元？", function(is) {
			if(is){
				$.messager.progress({text : "正在进行圈存，请稍后...."});
				$.post("recharge/rechargeAction!saveBankToZjzzQc.action",{cardNo:$("#cardNo").val(),amt:$("#amt").val(),pwd:$("#pwd").val()},function(data,status){
					if(status == "success"){
						if(data.status != "0"){
							$.messager.progress("close");
							$.messager.alert("系统消息","操作失败，详细信息：" + data.errMsg,"error");
						}else if(data.status == "0"){
							$.messager.progress("close");
							if(data.isReminder == "0") {
								$.messager.alert("系统消息",data.reminderMsg,"info",function(){
									showReport("${ACC_KIND_NAME_LJ }圈存",data.dealNo,function(){
										window.history.go(0);
									});
								});
							} else {
								showReport("${ACC_KIND_NAME_LJ }圈存",data.dealNo,function(){
									window.history.go(0);
								});
							}
						}
					}else{
						$.messager.progress("close");
						$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }圈存请求出现错误，请重试！","error",function(){
							window.history.go(0);
						});
					}
				},"json").error(function(){
						$.messager.progress("close");
						$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }圈存请求出现错误，请重试！","error",function(){
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
	
	//获取明文密码
	function inpwd(){
		if(dealNull($('#cardNo').val()).length == 0){
			jAlert("请读取或输入卡号！");
			return;
		}
		if(dealNull($('#cardNo').val()).length != 20){
			jAlert("卡号不正确！");
			return;
		}
		$.messager.progress({text : "正在获取密码信息，请稍后...."});
		$('#pwd').val(getEnPin(1,$('#cardNo').val()));
		$.messager.progress("close");
	}
</script>
</head>
<body class="easyui-layout" data-options="fit:true">
  	<div data-options="region:'north',border:false" title="" style="height:auto;overflow: hidden;">
 			<div class="well well-small datagrid-toolbar" style="margin-left:0px;margin-right:0px;margin-top: 2px;margin-bottom: 2px;">
			<span class="badge">提示</span><span>在此你可以对卡片进行<span class="label-info"><strong>银行卡圈存操作，<span style='color:red'>注意</span>：圈存金额不能超过可圈存额度！</strong></span></span>
		</div>
	</div>
	<div data-options="region:'center',border:true" style="height:50px;margin:0px;width:auto;border-left:none;border-bottom:none;">
		<form id="form" method="post">
			<input type="hidden" value="9" name="cardStateHidden" id="cardStateHidden"/><!-- 卡状态 -->
			<input type="hidden" value="" name="abcdrfg" id="abcdrfg"/><!-- 卡状态 -->
		</form>	
	  	<div id="tb" style="padding:2px 0;" class="easyui-panel datagrid-toolbar" data-options="cache:false,border:false,fit:true,tools:'#toolspanel'" title="银行卡圈存">
			<table cellpadding="0" cellspacing="0" id="toolpanel" style="width:100%">
				<tr>
					<td width="20%" align="right" class="label_left">卡号：</td>
					<td width="30%"  align="left" class="label_right"><input name="cardNo" data-options="required:true,invalidMessage:'请读卡以获取卡号信息',missingMessage:'请读卡以获取卡号信息'" class="textinput easyui-validatebox" id="cardNo" type="text" maxlength="20"/></td>
					<td width="15%"  align="right" class="label_left">账户余额：</td>
					<td width="35%"  class="label_right">
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
					<td align="right" class="label_left">银行卡卡号：</td>
					<td class="label_right"><input id="bankCardNo" type="text" class="textinput" name="bankCardNo" readonly="readonly" disabled="disabled"/></td>
					<td align="right" class="label_left">所属银行：</td>
					<td class="label_right"><input id="bankId" type="text" class="textinput" name="bankId" readonly="readonly" disabled="disabled"/></td>
				</tr>
				<tr>
					<td colspan="4"><h3 class="subtitle">市民卡信息</h3></td>
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
					<td colspan="4"><h3 class="subtitle">圈存信息</h3></td>
				</tr>
				<tr>
					<td align="right" class="label_left">圈存限额：</td>
					<td class="label_right">
						<input id="qcLimitAmt" type="text" class="textinput" name="qcLimitAmt" readonly="readonly" disabled="disabled"/>
						<span id="isSetLimit" style="color:#3a87ad;margin-left:10px;font-size:10px;"></span>
					</td>
					<td align="right" class="label_left">今日已圈存金额：</td>
					<td class="label_right"><input id="todayTotAmt" type="text" class="textinput" name="todayTotAmt" readonly="readonly" disabled="disabled"/></td>
				</tr>
				<tr>
					<td align="right" class="label_left">今日已圈存笔数：</td>
					<td class="label_right"><input id="todayTotNum" type="text" class="textinput" name="todayTotNum" readonly="readonly" disabled="disabled"/></td>
					<td align="right" class="label_left">今日可圈存额度：</td>
					<td class="label_right"><input id="avaiQcLimitAmt" type="text" class="textinput" name="avaiQcLimitAmt" readonly="readonly" disabled="disabled"/></td>
				</tr>
				<tr>
					<td class="label_left">转出卡账户密码：</td>
					<td class="label_right">
						<input id="pwd" type="password" maxlength="12" readonly="readonly" class="easyui-validatebox textinput" name="pwd"/>
						<a  data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="inpwd()">密码输入</a>
					</td>
					<td class="label_right" colspan="2">&nbsp;</td>
				</tr>
				<tr>
					<td align="right" class="label_left">圈存金额：</td>
					<td class="label_right"><input id="amt" type="text" class="textinput easyui-validatebox" maxlength="8" required="required" name="amt" onkeyup="validRmb(this)" onkeydown="validRmb(this)"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span></td>
					<td align="right" class="label_left">确定圈存金额：</td>
					<td class="label_right">
						<input id="amt2" type="text" class="textinput easyui-validatebox" required="required" maxlength="8" onkeyup="validRmb(this)" onkeydown="validRmb(this)" name="amt2"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span>
						<shiro:hasPermission name="OnlineRechargeSave">
							<a  data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="tijiao()">确定圈存</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
	</div>
</body>
</html>