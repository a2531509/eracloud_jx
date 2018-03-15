<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%
	String path = request.getContextPath();
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
%>
<!doctype html>
<html>
<head>
	<base href="<%=basePath%>">
	<title>${ACC_KIND_NAME_QB }转${ACC_KIND_NAME_LJ }</title>
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">   
	<jsp:include page="../../layout/script.jsp"></jsp:include>
	<style type="text/css">.tableleft{font-weight:600}</style>
	<script type="text/javascript">
		$(function(){
			$("#outCardNo").validatebox({required:true,validType:"email",invalidMessage:"请读卡以获取转出卡信息<br/><span style=\"color:red\">提示：卡号为有效的20位数字或字母组成</span>",missingMessage:"请读卡以获取转出卡信息<br/><span style=\"color:red;\">提示：卡号为有效的20位数字或字母组成</span>"});
			$("#outAccBal").validatebox({required:true,validType:"email",invalidMessage:"请读卡以获取转出卡账户信息<br/><span style=\"color:red;\">提示：卡号为有效的20位数字或字母组成</span>",missingMessage:"请读卡以获取转出卡账户信息<br/><span style=\"color:red;\">提示：卡号为有效的20位数字或字母组成</span>"});
			$("#inCardNo").validatebox({required:true,validType:"email",invalidMessage:"请读卡或是查询以获取转入卡信息<br/><span style=\"color:red;\">提示：卡号为有效的20位数字或字母组成</span>",missingMessage:"请读卡或是查询以获取转入卡信息<br/><span style=\"color:red;\">提示：卡号为有效的20位数字或字母组成</span>"});
			$("#inAccBal").validatebox({required:true,validType:"email",invalidMessage:"请读卡或是查询以获取转入卡账户信息<br/><span style=\"color:red;\">提示：卡号为有效的20位数字或字母组成</span>",missingMessage:"请读卡或是查询以获取转入卡账户信息<br/><span style=\"color:red;\">提示：卡号为有效的20位数字或字母组成</span>"});
			$("#amt").validatebox("validate");
		});
		var cycleNum0 = 0, cycleNum1 = 0, cycleNum2 = 0, finalwritenum = 2;
		var cardinfo;
		var currentOutCard = "";//当前转出卡
		var currentInCard = "";//当前转入卡
		var dealNo = ""; //灰记录流水号
		function readcard(type){
			$.messager.progress({text:"正在验证卡信息,请稍后..."});
			cardinfo = getcardinfo();
			if(dealNull(cardinfo["card_No"]).length == 0){
				$.messager.progress("close");
				$.messager.alert("系统消息","读卡出现错误，请拿起并重新放置好卡片，再次进行读取！" + cardinfo["errMsg"],"error");
				return;
			}
			if(type == "0"){
				$("#outCardNo").val(cardinfo["card_No"]);
				$("#outAccBal").val(Number(cardinfo["wallet_Amt"]).div100());
				$("#recharge_Tr_Count").val(cardinfo["recharge_Tr_Count"]);//充值序列号
			}else if(type == "1"){
				$("#inCardNo").val(cardinfo["card_No"]);
			}else{
				$.messager.alert("系统消息","传入操作类型错误！","error");
				return;
			}
			validCard(type);
		}
		function validCard(type){
			var tempcardno = "";
			if(type == "0"){
				tempcardno = $("#outCardNo").val();
			}else if(type == "1"){
				tempcardno = $("#inCardNo").val();
			}else{
				jAlert("传入操作类型错误！");
				return;
			}
			$.post("cardService/cardServiceAction!getCardAndPersonInfo.action","cardNo=" + tempcardno ,function(data,status){
				$.messager.progress("close");
				if(status == "success"){
					if(dealNull(data.card.cardNo).length == 0){
						if(type == "0"){
							outCardMsg = "转出卡验证卡片错误，卡号信息不存在，该卡不能进行" + (type == "0" ? "转出" : "转入") + "。";
						}else if(type == "1"){
							inCardMsg = "转入卡验证卡片错误，卡号信息不存在，该卡不能进行" + (type == "0" ? "转出" : "转入") + "。";
						}
						$.messager.alert("系统消息","验证卡片错误，卡号信息不存在，该卡不能进行" + (type == "0" ? "转出" : "转入") + "。","error");
						return;
					}
					if(type == "0"){
						outCardMsg = "";
						$("#outCertType").val(dealNull(data.person.certTypeStr));
						$("#outCertNo").val(dealNull(data.person.certNo));
						$("#outCardType").val(dealNull(data.card.cardTypeStr));
						$("#outCardState").val(dealNull(data.card.note));
						$("#outCardStateHidden").val(data.card.cardState);
						$("#outBusType").val(dealNull(data.card.busTypeStr));
						$("#outFkDate").val(dealNull(data.card.issueDate));
						$("#outName").val(dealNull(data.person.name));
						$("#outCsex").val(dealNull(data.person.csex));
						//$("#outAccBal").val(Number(data.acc.bal).div100());
						currentOutCard = data.card.cardNo;//防止卡号被修改
					}else if(type == "1"){
						inCardMsg = "";
						$("#inCertType").val(dealNull(data.person.certTypeStr));
						$("#inCertNo").val(dealNull(data.person.certNo));
						$("#inCardType").val(dealNull(data.card.cardTypeStr));
						$("#inCardState").val(dealNull(data.card.note));
						$("#inBusType").val(dealNull(data.card.busTypeStr));
						$("#inFkDate").val(dealNull(data.card.issueDate));
						$("#inCardStateHidden").val(data.card.cardState);
						$("#inName").val(dealNull(data.person.name));
						$("#inCsex").val(dealNull(data.person.csex));
						$("#inAccBal").val(Number(data.acc.bal).div100());
						currentInCard = data.card.cardNo;//防止卡号被修改
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
		function querycard(type){
			var tempcardno = "";
			if(type == "0"){
				tempcardno = $("#outCardNo").val();
			}else if(type == "1"){
				tempcardno = $("#inCardNo").val();
			}else{
				jAlert("传入操作类型错误！");
				return;
			}
			if(dealNull(tempcardno).length != 20){
				$.messager.alert("系统消息","输入的卡号不正确！请仔细核对" + (type == "0" ? "转出" : "转入") + "卡片信息并重新输入！<br/><span style=\"color:red;\">提示：卡号为有效的20位数字或字母组成</span>","warning",function(){
					if(type == "0"){
						$("#outCardNo").focus();
					}else if(type == "1"){
						$("#inCardNo").focus();
					}
				});
				return;
			}
			$.messager.progress({text : "正在验证卡信息,请稍后..."});
			validCard(type);
		}
		// 确认转账
		function confirmTransfer() {
			if(dealNull(outCardMsg).length > 0){
				$.messager.alert("系统消息",outCardMsg,"error")
				return;
			}
			if(dealNull(inCardMsg).length > 0){
				$.messager.alert("系统消息",inCardMsg,"error")
				return;
			}
			if(dealNull($("#outCardNo").val()).length == 0){
				jAlert("请先进行读卡以获取转出卡卡片信息！");
			}
			if(dealNull($("#outAccBal").val()).length == 0) {
				jAlert("请先进行读卡以获取转出卡卡片余额信息！");
				return;
			}
			if(Number($("#outAccBal").val()) == 0) {
				jAlert("转出卡卡片余额为0，不能进行转出！");
				return;
			}
			if(currentOutCard != dealNull($("#outCardNo").val())) {
				jAlert("转出卡卡信息发生变动，请重新读取卡信息！");
				return;
			}
			if(dealNull($("#outCardStateHidden").val()) != "<%=com.erp.util.Constants.CARD_STATE_ZC%>") {
				jAlert("转出卡卡状态不正常，不能进行转出操作！");
				return;
			}
			if(dealNull($("#inCardNo").val()).length == 0){
				jAlert("请先进行读卡或查询以获取转入卡卡片信息！");
			}
			if(dealNull($("#inAccBal").val()).length == 0){
				jAlert("请先进行读卡或查询以获取转入卡账户余额信息！");
			}
			if(currentInCard != dealNull($("#inCardNo").val())) {
				jAlert("转入卡卡信息发生变动，请重新读取卡信息！");
				return;
			}
			if(dealNull($("#inCardStateHidden").val()) != "<%=com.erp.util.Constants.CARD_STATE_ZC%>") {
				jAlert("转入卡卡状态不正常，不能进行转入操作！");
				return;
			}
			// 判断转账金额
			if(dealNull($("#amt").val()).length == 0) {
				jAlert("请输入转账金额！","error",function(){
					$("#amt").focus();
				});
				return;
			}
			if(dealNull($("#confirmAmt").val()).length == 0) {
				$.messager.alert("系统消息", "请输入确认转账金额！", "info", function() {
					$("#confirmAmt").focus();
				});
				return;
			}
			if(!/^\d+(\.?\d{1,2})?$/g.test(dealNull($("#amt").val()))) {
				$.messager.alert("系统消息", "转账金额格式不正确，请重新输入转账金额！", "info", function() {
					$("#amt").val("");
					$("#amt").focus();
				});
				return;
			}
			if(dealNull($("#amt").val()) != dealNull($("#confirmAmt").val())) {
				$.messager.alert("系统消息", "转账金额和确认转账金额输入不一致，请重新输入转账金额！", "info", function() {
					$("#confirmAmt").val("");
					$("#confirmAmt").focus();
				});
				return;
			}
			if(parseFloat(dealNull($("#amt").val())) <= 0) {
				$.messager.alert("系统消息", "转账金额必须大于0！", "info", function() {
					$("#amt").val("");
					$("#confirmAmt").val("");
					$("#amt").focus();
				});
				return;
			}
			//判断转账金额是否大于电子钱包账户余额
			if(Number(dealNull($("#amt").val())) > Number(dealNull($("#outAccBal").val()))) {
				$.messager.alert("系统消息", "转账金额不能大于转出卡卡面余额，请重新进行输入！", "error", function() {
					$("#amt").val("");
					$("#amt").focus();
				});
				return;
			}
			$.messager.confirm("系统消息", "您确定要从卡号为【" + dealNull($("#outCardNo").val()) + "】往${ACC_KIND_NAME_LJ }转账<" + dealNull($("#amt").val()) + ">元？", function(r) {
				if(r){
					$.messager.progress({text: "正在进行转账，请稍后...."});
					writeAshRecord();
				}
			});
		}
		
		function getAmt(){
			return Number(Number($("#outAccBal").val()).mul100()) - Number(Number($("#amt").val()).mul100());
		}
		
		function write_card(writecarddata){
			cardinfo = getcardinfo();
			if(judgeReadCardOk(cardinfo)){
				cycleNum0 = 0;
				wirtecard_consume($("#outCardNo").val(),writecarddata);
				cardinfo = getcardinfo();
				if(judgeReadCardOk(cardinfo)){
					if(Number((isNaN(cardinfo["wallet_Amt"]) ? -1 : cardinfo["wallet_Amt"])) == getAmt()){
						confirmAshRecord(dealNo);
					}else{
						cycleNum1++;
						if(cycleNum1 >= finalwritenum){
							cancelAshRecord(dealNo);
						}else{
							$.messager.progress("close");
							$.messager.alert("系统消息","市民卡钱包写卡出现错误，请拿起并重新放置好卡片，点击【确定】再次进行写卡！","error",function(){
								$.messager.progress({text : "正在进行写卡，请稍后...."});
								write_card(writecarddata);
							});
						}
					}
				}else{
					write_card_next(writecarddata);
				}
			}else{
				cycleNum0++;
				if(cycleNum0 >= finalwritenum){
					cancelAshRecord(dealNo);
				}else{
					$.messager.progress("close");
					$.messager.alert("系统消息","写卡前获取卡片信息出现错误，请拿起并重新放置好卡片，点击【确定】再次进行写卡！0" + cycleNum0,"error",function(){
						$.messager.progress({text : "正在进行写卡，请稍后...."});
						write_card(writecarddata);
					});
				}
			}
		}
		
		function judgeReadCardOk(obj){
			if(obj["card_No"] == ""){
				return false;
			}
			if(obj["card_No"] == undefined){
				return false;
			}
			if(typeof(obj["card_No"]) == "undefined"){
				return false;
			}
			if(obj["card_No"] == "undefined"){
				return false;
			}
			if(obj["card_No"] != $("#outCardNo").val()){
				return false;
			}
			return true;
		}
		
		function write_card_next(writecarddata){
			cardinfo = getcardinfo();
			if(judgeReadCardOk(cardinfo)){
				cycleNum2 = 0;
				if(Number((isNaN(cardinfo["wallet_Amt"]) ? -1 : cardinfo["wallet_Amt"])) == getAmt()){
					confirmAshRecord(dealNo);
				}else{
					cycleNum1++;
					if(cycleNum1 >= finalwritenum){
						cancelAshRecord(dealNo);
					}else{
						$.messager.progress("close");
						$.messager.alert("系统消息","市民卡钱包写卡出现错误，请拿起并重新放置好卡片，点击【确定】再次进行写卡！","error",function(){
							$.messager.progress({text : "正在进行写卡，请稍后...."});
							write_card(writecarddata);
						});
					}
				}
			}else{
				cycleNum2++;
				if(cycleNum2 >= finalwritenum){
					$.messager.progress("close");
					$.messager.alert("系统消息","写卡出现错误，<span style=\"color:red;font-weight:600;font-style:italic;\">请再次进行读卡确认是否转账成功，并处理【灰记录】！</span>","error",function(){
						$.messager.progress({text : "正在加载，请稍后...."});
						window.history.go(0);
					});
				}else{
					$.messager.progress("close");
					$.messager.alert("系统消息","写卡后获取卡片信息出现错误，请拿起并重新放置好卡片，点击【确定】再次进行写卡！","error",function(){
						$.messager.progress({text : "正在进行写卡，请稍后...."});
						write_card_next(writecarddata);
					});
				}
			}
		}
		
		// 1.写灰记录
		function writeAshRecord() {
			dealNo = "";
			$.post("recharge/rechargeAction!saveTransferOfflineAcc2OnlineAcc.action", {
				"outCardNo": dealNull($("#outCardNo").val()),
				"outAccBal": dealNull($("#outAccBal").val()),
				"inCardNo": dealNull($("#inCardNo").val()),
				"inAccBal": dealNull($("#inAccBal").val()),
				"amt":dealNull($("#amt").val()),
				"card_Recharge_TrCount":$("#recharge_Tr_Count").val()
			},function(data, status){
				$.messager.progress("close");
				if(status == "success"){
					if(data.status == "0"){
						$.messager.progress({text: "正在进行写卡，请稍后...."});
						dealNo = data.dealNo;
						write_card(data.writecarddata);
					}else{
						$.messager.alert("系统消息", data.msg, "error");
					}
				}else{
					$.messager.alert("系统消息", "${ACC_KIND_NAME_QB }转${ACC_KIND_NAME_LJ }请求出现错误，请重试！", "error");
				}
			},"json").error(function() {
				$.messager.progress("close");
				$.messager.alert("系统消息", "${ACC_KIND_NAME_QB }转${ACC_KIND_NAME_LJ }请求出现错误，请重试！", "error");
			});
		}
		
		// 3.写卡成功后，确认灰记录
		function confirmAshRecord(dealNo) {
			$.post("recharge/rechargeAction!saveTransferToOnlineConfirm.action", {
				"dealNo": dealNull(dealNo)
			}, function(data, status) {
				$.messager.progress("close");
				if (status == "success") {
					if (data.status == "0") {
						$.messager.alert("系统消息", "${ACC_KIND_NAME_QB }转${ACC_KIND_NAME_LJ }操作成功！", "info", function() {
							showReport("${ACC_KIND_NAME_QB }转${ACC_KIND_NAME_LJ }", dealNo, function() {
								clearInfo();
							});
						});
					} else {
						$.messager.progress("close");
						$.messager.alert("系统消息", "写卡成功，确认转账记录出现错误！请手工确认【灰记录】", "error", function() {
							showReport("${ACC_KIND_NAME_QB }转${ACC_KIND_NAME_LJ }", dealNo, function() {
								clearInfo();
							});
						});
					}
				} else {
					$.messager.alert("系统消息", "写卡成功，确认转账记录出现错误！请手工确认【灰记录】", "error", function() {
						showReport("${ACC_KIND_NAME_QB }转${ACC_KIND_NAME_LJ }", dealNo, function() {
							clearInfo();
						});
					});
				}
			},"json").error(function() {
				$.messager.progress("close");
				$.messager.alert("系统消息", "写卡成功，确认转账记录出现错误！请手工确认【灰记录】", "error", function() {
					showReport("${ACC_KIND_NAME_QB }转${ACC_KIND_NAME_LJ }", dealNo, function() {
						clearInfo();
					});
				});
			});
		}
		//4.写卡失败，取消灰记录
		function cancelAshRecord(dealNo) {
			$.post("recharge/rechargeAction!saveTransferToOnlineCancel.action", {
				"dealNo":dealNull(dealNo),
				"outCardTrCount":$("#recharge_Tr_Count").val(),
				"outAccBal": dealNull($("#outAccBal").val()),
			}, function(data, status) {
				$.messager.progress("close");
				if(status == "success") {
					if (data.status == "0") {
						$.messager.alert("系统消息", "转账出现错误，请重新转账！", "error", function() {
							clearInfo();
						});
					}else{
						$.messager.alert("系统消息", "转账出现错误，冲正出现错误，请人工取消【灰记录】！", "error", function() {
							clearInfo();
						});
					}
				} else {
					$.messager.alert("系统消息", "转账出现错误，冲正出现错误，请人工取消【灰记录】！", "error", function() {
						clearInfo();
					});
				}
			},"json").error(function(){
				$.messager.alert("系统消息", "转账出现错误，冲正出现错误，请人工取消【灰记录】！", "error", function() {
					clearInfo();
				});
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
		function clearInfo(){
			cycleNum0 = 0;
			cycleNum1 = 0;
			cycleNum2 = 0;
			$("input").val("");
		}
	</script>
</head>
<body class="easyui-layout" data-options="fit: true">
	<div style="height: auto; overflow: hidden;" data-options="region: 'north', border: false">
 		<div class="well well-small datagrid-toolbar" style="margin-left: 0px; margin-right: 0px; margin-top: 2px; margin-bottom: 2px;">
			<span class="badge">提示</span>
			<span>
				在此你可以对卡片进行<span class="label-info"><strong>${ACC_KIND_NAME_QB }转${ACC_KIND_NAME_LJ }，</strong><span style="color:red">注意：</span>卡账户状态不正常不能进行转出或是转入操作！</span>
			</span>
		</div>
	</div>
	<div data-options="region:'center',border:true,fit:true" style="margin:0px;width:auto;height:auto" title="${ACC_KIND_NAME_QB }转${ACC_KIND_NAME_LJ }" class="datagrid-toolbar">
		<form id="form" method="post">
			<input type="hidden" value="" name="dealNo" id="dealNo"/><!-- 转出卡卡状态 -->
			<input type="hidden" value="9" name="outCardStateHidden" id="outCardStateHidden"/><!-- 转出卡卡状态 -->
			<input type="hidden" value="9" name="inCardStateHidden" id="inCardStateHidden"/><!-- 转入卡卡状态 -->
			<input type="hidden" value="" name="recharge_Tr_Count" id="recharge_Tr_Count"/><!-- 脱机账户充值序列号 -->
		</form>
		<!-- 转出卡信息 -->
		<div style="width:100%;height:auto;border:none;">
		  	<div id="tb" style="padding:2px 0;background-color:rgb(245,245,245);overflow:hidden;" class="easyui-panel" data-options="border:false,tools:'#toolspanel',fit:true" >
				<h3 class="subtitle">转出卡信息</h3>
				<table cellpadding="0" cellspacing="0" id="toolpanel" style="width:100%" class="tablegrid">
					<tr>
						<td width="25%" class="tableleft">卡号：</td>
						<td width="25%" class="tableright"><input name="outCardNo" class="textinput easyui-validatebox" id="outCardNo" type="text" maxlength="20" readonly="readonly"/></td>
						<td width="15%" class="tableleft">卡面余额：</td>
						<td width="35%" class="tableright">
							<input name="outAccBal" class="textinput easyui-validatebox" id="outAccBal" type="text" readonly="readonly" style="display:inline-block;"/>
								<a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readcard('0')">读卡</a>
						</td>
					</tr>
					<tr>
						<td class="tableleft">姓名：</td>
						<td class="tableright"><input id="outName" type="text" class="textinput" name="outName" readonly="readonly" disabled="disabled"/></td>
						<td class="tableleft">性别：</td>
						<td class="tableright"><input name="outCsex"  class="textinput" id="outCsex" type="text" readonly="readonly" disabled="disabled"/></td>
					</tr>
					<tr>
						<td class="tableleft">证件类型：</td>
						<td class="tableright"><input id="outCertType" type="text" class="textinput" name="outCertType" readonly="readonly" disabled="disabled"/></td>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input name="outCertNo"  class="textinput" id="outCertNo" type="text" readonly="readonly" disabled="disabled"/></td>
					</tr>
					<tr>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="outCardType" type="text" class="textinput" name="outCardType" readonly="readonly" disabled="disabled"/></td>
						<td class="tableleft">卡状态：</td>
						<td class="tableright"><input id="outCardState" type="text" class="textinput" name="outCardState"  readonly="readonly" disabled="disabled"/></td>
					</tr>
					<tr>
						<td class="tableleft">公交类型：</td>
						<td class="tableright"><input id="outBusType" type="text" class="textinput" name="outBusType" readonly="readonly" disabled="disabled"/></td>
						<td class="tableleft">发卡日期：</td>
						<td class="tableright"><input id="outFkDate" type="text" class="textinput" name="outFkDate"  readonly="readonly" disabled="disabled"/></td>
					</tr>
				</table>
			</div>
		</div>
		<!-- 转入卡信息 -->
		<div style="width:100%;height:auto;border:none;">
			<div id="tb2" style="padding:2px 0;background-color:rgb(245,245,245);overflow:hidden;" class="easyui-panel" data-options="fit:true,cache:false,border:false,tools:'#toolspanel2'">
				<h3 class="subtitle">转入卡信息</h3>
				<table cellpadding="0" cellspacing="0" id="toolpanel2" style="width:100%" class="tablegrid">
					<tr>
						<td width="25%" class="tableleft">卡号：</td>
						<td width="25%" align="left" class="tableright"><input name="inCardNo" class="textinput easyui-validatebox" id="inCardNo" type="text" maxlength="20"/></td>
						<td width="15%" class="tableleft">账户余额：</td>
						<td width="35%" class="tableright">
							<input name="inAccBal" class="textinput easyui-validatebox" id="inAccBal" type="text" readonly="readonly" style="display:inline-block;vertical-align: baseline;"/>
							<a data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton"   onclick="readcard('1')">读卡</a>
							<a  data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="querycard('1')">查询</a>
						</td>
					</tr>
					<tr>
						<td class="tableleft">姓名：</td>
						<td class="tableright"><input id="inName" type="text" class="textinput" name="inName" readonly="readonly" disabled="disabled"/></td>
						<td class="tableleft">性别：</td>
						<td class="tableright"><input name="inCsex"  class="textinput" id="inCsex" type="text" readonly="readonly" disabled="disabled"/></td>
					</tr>
					<tr>
						<td class="tableleft">证件类型：</td>
						<td class="tableright"><input id="inCertType" type="text" class="textinput" name="inCertType" readonly="readonly" disabled="disabled"/></td>
						<td class="tableleft">证件号码：</td>
						<td class="tableright"><input name="inCertNo"  class="textinput" id="inCertNo" type="text" readonly="readonly" disabled="disabled"/></td>
					</tr>
					<tr>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="inCardType" type="text" class="textinput" name="inCardType" readonly="readonly" disabled="disabled"/></td>
						<td class="tableleft">卡状态：</td>
						<td class="tableright"><input id="inCardState" type="text" class="textinput" name="inCardState"  readonly="readonly" disabled="disabled"/></td>
					</tr>
					<tr>
						<td class="tableleft">公交类型：</td>
						<td class="tableright"><input id="inBusType" type="text" class="textinput" name="inBusType" readonly="readonly" disabled="disabled"/></td>
						<td class="tableleft">发卡日期：</td>
						<td class="tableright"><input id="inFkDate" type="text" class="textinput" name="inFkDate"  readonly="readonly" disabled="disabled"/></td>
					</tr>
				</table>
			</div>
		</div>
		<!-- 转账信息 -->
		<div style="width:100%;height:auto;border:none;">
			<div id="tb2" style="padding:2px 0;background-color:rgb(245,245,245);overflow:hidden;" class="easyui-panel" data-options="fit:true,cache:false,border:false,tools:'#zzMsg'">
				<h3 class="subtitle">转账信息</h3>
				<table cellpadding="0" cellspacing="0" id="toolpanel2" style="width:100%" class="tablegrid" id="zzMsg">
					<tr>
						<td width="25%" class="tableleft">转账金额：</td>
						<td width="25%" class="tableright"><input id="amt" type="text" class="easyui-validatebox textinput" name="amt" data-options="required:true,validType:'email',invalidMessage:'转账金额不可大于转出卡的账户余额',missingMessage:'转账金额不可大于转出卡的账户余额'" onkeydown="validRmb(this)" onkeyup="validRmb(this)"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span></td>
						<td width="15%" class="tableleft">确认金额：</td>
						<td width="35%" class="tableright">
							<input style="display:inline-block;vertical-align: baseline;" id="confirmAmt" type="text" class="textinput easyui-validatebox" name="confirmAmt" data-options="required:true,validType:'number',invalidMessage:'转账金额不可大于转出卡的账户余额',missingMessage:'转账金额不可大于转出卡的账户余额'" onkeydown="validRmb(this)" onkeyup="validRmb(this)"/><span style="color:red;margin-left:10px;font-size:9px;">单位：元</span>
							<a  data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="confirmTransfer()">确定转账</a>
						</td>
					</tr>
				</table>
			</div>
		</div>
	</div>
</body>
</html>