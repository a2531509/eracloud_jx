<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
	var cycleNum0 = 0,cycleNum1 = 0,cycleNum2 = 0;finalwritenum = 2;
	var offlineRechargeCard;
	var offlineRechargeToop = "";
	$(function(){
		$.addRbmReg("offlineRechargeAmt");
		$.addRbmReg("offlineRechargeConfirmAmt");
	});
	function readOfflieRechargeCard(){
		$.messager.progress({text : '正在验证卡信息,请稍后...'});
		offlineRechargeCard = getcardinfo();
		if(dealNull(offlineRechargeCard["card_No"]).length == 0){
			$.messager.progress("close");
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！" + offlineRechargeCard["errMsg"],"error");
			return false;
		}
		$("#offlineRechargeCardNo").val(offlineRechargeCard["card_No"]);
		$("#offlineRechargeCardAmt").val((parseFloat(isNaN(offlineRechargeCard["wallet_Amt"]) ? 0 : offlineRechargeCard["wallet_Amt"])/100).toFixed(2));
		$("#offlineRechargeTrcount").val(offlineRechargeCard["recharge_Tr_Count"]);
		offlineRechargeValidCard();
	}
	function offlineRechargeValidCard(){
		$.post("cardService/cardServiceAction!getCardAndPersonInfo.action","cardNo=" + $("#offlineRechargeCardNo").val(),function(data,status){
			$.messager.progress("close");
			if(status == "success"){
				$("#offlineRechargeCardState").val(data.card.cardState);
				if(dealNull(data.card.cardNo).length == 0){
					offlineRechargeToop = "验证卡片信息发生错误，卡号信息不存在，该卡不能进行充值！";
					jAlert(offlineRechargeToop);
				}else{
					offlineRechargeToop = "";
					$("#offlineRechargeAmt").focus();
				}
			}else{
				offlineRechargeToop = "验证卡片信息发生错误，请重试...";
				jAlert(offlineRechargeToop);
			}
		},"json").error(function(){
			$.messager.progress("close");
			offlineRechargeToop = "验证卡片信息发生错误，请重试...";
			jAlert(offlineRechargeToop);
		});
	}
	function offlineRecharge(){
		if(dealNull(offlineRechargeToop).length != 0){
			jAlert(offlineRechargeToop);
			return;
		}
		if($("#offlineRechargeCardNo").val().replace(/\s/g,"") == "" || $("#offlineRechargeCardAmt").val().replace(/\s/g,"") == ""){
			$.messager.alert("系统消息","请先进行读卡以获取充值卡号和当前卡内余额！","error");
			return;
		}
		if($("#offlineRechargeCardState").val() != "1"){
			$.messager.alert("系统消息","当前卡片状态不正常，不能进行${ACC_KIND_NAME_QB }充值！","error");
			return;
		}
		if($("#offlineRechargeAmt").val().replace(/\s/g) == ""){
			$.messager.alert("系统消息","请输入${ACC_KIND_NAME_QB }充值金额！","error",function(){
				$("#offlineRechargeAmt").focus();
			});
			return;
		}
		if($("#offlineRechargeConfirmAmt").val() == ""){
			$.messager.alert("系统消息","请输入${ACC_KIND_NAME_QB }确认充值金额！","error",function(){
				$("#offlineRechargeConfirmAmt").focus();
			});
			return;
		}
		var exp = /^\d+(\.?\d{1,2})?$/g;
		if(!exp.test($("#offlineRechargeAmt").val())){
			$.messager.alert("系统消息","充值金额格式不正确，请重新进行输入！","error",function(){
				$("#offlineRechargeAmt").val("");
				$("#offlineRechargeAmt").focus();
			});
			return;
		}
		if(isNaN($("#offlineRechargeAmt").val())){
			$.messager.alert("系统消息","充值金额格式不正确，请重新进行输入！","error",function(){
				$("#offlineRechargeAmt").val("");
				$("#offlineRechargeAmt").focus();
			});
			return;
		}
		if($("#offlineRechargeAmt").val() != $("#offlineRechargeConfirmAmt").val()){
			$.messager.alert("系统消息","钱包充值金额和确认充值金额不一致，请重新输入！","error",function(){
				$("#offlineRechargeConfirmAmt").val("");
				$("#offlineRechargeConfirmAmt").focus();
			});
			return;
		}
		if(parseFloat($("#offlineRechargeAmt").val()) <= 0){
			$.messager.alert("系统消息","${ACC_KIND_NAME_QB }充值金额必须大于0！","error",function(){
				$("#offlineRechargeAmt").val("");
				$("#offlineRechargeAmt").focus();
			});
			return;
		}
		$.messager.confirm("系统消息","您确定要为卡号为【" + $("#offlineRechargeCardNo").val() + "】的卡片充值<" + $("#offlineRechargeAmt").val().replace(/\s/g,"") + ">元？", function(is) {
			if(is){
				$.messager.progress({text : "正在进行充值，请稍后...."});
				$.ajax({url:"recharge/rechargeAction!_saveHjlWallet.action",
				    dataType:"json",
				    data:{
				    	cardNo:$("#offlineRechargeCardNo").val(),
				    	cardAmt:$("#offlineRechargeCardAmt").val(),
				    	amt:$("#offlineRechargeAmt").val().replace(/\s/g,""),
				    	card_Recharge_TrCount:$("#offlineRechargeTrcount").val(),
				    	_times_:Math.random()
				    },
				    success:function(data){
						if(data.status != "0"){
							$.messager.progress("close");
							$.messager.alert("系统消息",data.msg,"error");
						}else if(data.status == "0"){
							$("#offlineRechargeDealNo").val(data.dealNo);
							write_card(data.writecarddata);
						}
					},
					error:function(){
						$.messager.progress("close");
						$.messager.alert("系统消息","${ACC_KIND_NAME_QB }充值请求出现错误，请重试！","error");
					}
				});
			}
		});
	}
	function getOfflineRechargeFinalAmt(){
		return Number(Number($("#offlineRechargeCardAmt").val()).mul100()) + Number(Number($("#offlineRechargeAmt").val()).mul100());
	}
	function write_card(writecarddata){
		offlineRechargeCard = getcardinfo();
		if(judgeReadCardOk(offlineRechargeCard)){
			cycleNum0 = 0;
			wirtecard_recharge($("#offlineRechargeCardNo").val(),writecarddata);
			offlineRechargeCard = getcardinfo();
			if(judgeReadCardOk(offlineRechargeCard)){
				if(Number((isNaN(offlineRechargeCard["wallet_Amt"]) ? -1 : offlineRechargeCard["wallet_Amt"])) == getOfflineRechargeFinalAmt()){
					OfflineRechargeConfirm();
				}else{
					cycleNum1++;
					if(cycleNum1 >= finalwritenum){
						OfflineRechargeCancel();
					}else{
						$.messager.progress("close");
						$.messager.alert("系统消息","${ACC_KIND_NAME_QB }充值写卡出现错误，请拿起并重新放置好卡片，点击【确定】再次进行充值！","error",function(){
							$.messager.progress({text : "正在进行充值，请稍后...."});
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
				OfflineRechargeCancel();
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡前获取卡片信息出现错误，请拿起并重新放置好卡片，点击【确定】再次进行充值！0" + cycleNum0,"error",function(){
					$.messager.progress({text : "正在进行充值，请稍后...."});
					write_card(writecarddata);
				});
			}
		}
	}
	function write_card_next(writecarddata){
		offlineRechargeCard = getcardinfo();
		if(judgeReadCardOk(offlineRechargeCard)){
			cycleNum2 = 0;
			if(Number((isNaN(offlineRechargeCard["wallet_Amt"]) ? -1 : offlineRechargeCard["wallet_Amt"])) == getOfflineRechargeFinalAmt()){
				OfflineRechargeConfirm();
			}else{
				cycleNum1++;
				if(cycleNum1 >= finalwritenum){
					OfflineRechargeCancel();
				}else{
					$.messager.progress("close");
					$.messager.alert("系统消息","钱包充值写卡出现错误，请拿起并重新放置好卡片，点击【确定】再次进行充值！","error",function(){
						$.messager.progress({text : "正在进行充值，请稍后...."});
						write_card(writecarddata);
					});
				}
			}
		}else{
			cycleNum2++;
			if(cycleNum2 >= finalwritenum){
				$.messager.progress("close");
				$.messager.alert("系统消息","充值出现错误，<span style=\"color:red;font-weight:600;font-style:italic;\">请再次进行读卡确认是否充值成功，并处理【灰记录】！</span>","error",function(){
					$("#offlineRechargeInfo").form("reset");
					cycleNum0 = 0,cycleNum1 = 0,cycleNum2 = 0;
				});
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡后获取卡片信息出现错误，请拿起并重新放置好卡片，点击【确定】再次进行充值！","error",function(){
					$.messager.progress({text : "正在进行充值，请稍后...."});
					write_card_next(writecarddata);
				});
			}
		}
	}
	function OfflineRechargeCancel(){
		$.post("recharge/rechargeAction!saveWalletCancel.action",{dealNo:$("#offlineRechargeDealNo").val()},function(data,status){
			$.messager.progress("close");
			if(status == "success"){
				if(data.status == "0"){
					$.messager.alert("系统消息","${ACC_KIND_NAME_QB }充值出现错误，请重新充值！","error");
					$("#offlineRechargeInfo").form("reset");
					cycleNum0 = 0,cycleNum1 = 0,cycleNum2 = 0;
				}else{
					$.messager.alert("系统消息","充值出现错误，冲正出现错误，" + data.msg + "请人工进行取消【灰记录】！","error");
					$("#offlineRechargeInfo").form("reset");
					cycleNum0 = 0,cycleNum1 = 0,cycleNum2 = 0;
				}
			}else{
				$.messager.alert("系统消息","充值出现错误，冲正出现错误，请人工进行取消【灰记录】！","error");
				$("#offlineRechargeInfo").form("reset");
				cycleNum0 = 0,cycleNum1 = 0,cycleNum2 = 0;
			}
		},"json").error(function(){
			$.messager.progress("close");
			$.messager.alert("系统消息","充值出现错误，冲正出现错误，请人工进行取消【灰记录】！","error");
			$("#offlineRechargeInfo").form("reset");
			cycleNum0 = 0,cycleNum1 = 0,cycleNum2 = 0;
		});
	}
	function OfflineRechargeConfirm(){
		$.post("recharge/rechargeAction!saveWalletConfirm.action",{dealNo:$("#offlineRechargeDealNo").val()},function(data,status){
			if(status == "success"){
				if(data.status == "0"){
					$.messager.progress("close");
					showReport("${ACC_KIND_NAME_QB }充值",data.dealNo);
					$("#offlineRechargeInfo").form("reset");
					cycleNum0 = 0,cycleNum1 = 0,cycleNum2 = 0;
				}else{
					$.messager.progress("close");
					$.messager.alert("系统消息","写卡成功，确认充值灰记录出现错误，" + data.msg + "请在打印凭证后人工确认【灰记录】！","error",function(){
						showReport("${ACC_KIND_NAME_QB }充值",data.dealNo);
						$("#offlineRechargeInfo").form("reset");
						cycleNum0 = 0,cycleNum1 = 0,cycleNum2 = 0;
					});
				}
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","写卡成功，确认充值灰记录出现错误，请在打印凭证后人工确认【灰记录】！","error",function(){
					showReport("${ACC_KIND_NAME_QB }充值",data.dealNo);
					$("#offlineRechargeInfo").form("reset");
					cycleNum0 = 0,cycleNum1 = 0,cycleNum2 = 0;
				});
			}		
		},"json").error(function(){
			$.messager.progress("close");
			if(dealNull($("#offlineRechargeDealNo").val()) == ""){
				$.messager.alert("系统消息","写卡成功，确认充值灰记录出现错误，请人工进行确认【灰记录】！","error");
			}else{
				$.messager.alert("系统消息","写卡成功，确认充值灰记录出现错误，请在打印凭证后人工确认【灰记录】！","error",function(){
					showReport("${ACC_KIND_NAME_QB }充值",data.dealNo);
					$("#offlineRechargeInfo").form("reset");
					cycleNum0 = 0,cycleNum1 = 0,cycleNum2 = 0;
				});
			}
		});
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
		if(obj["card_No"] != $("#offlineRechargeCardNo").val()){
			return false;
		}
		return true;
	}
</script>
<h3 class="subtitle">${ACC_KIND_NAME_QB }充值</h3>
<form id="offlineRechargeInfo">
	<input type="hidden" id="offlineRechargeDealNo" name="offlineRechargeTrcount">
	<input type="hidden" id="offlineRechargeTrcount" name="offlineRechargeTrcount">
	<input type="hidden" id="offlineRechargeCardState" name="offlineRechargeCardState">
	<table id="toolpanel" class="tablegrid" style="width:700px;margin: 30px auto 0 auto;">
		<tr>
			<td class="tableleft">卡号：</td>
			<td class="tableright"><input name="offlineRechargeCardNo" data-options="required:true,invalidMessage:'请读卡以获取卡号信息',missingMessage:'请读卡以获取卡号信息'" class="textinput easyui-validatebox" id="offlineRechargeCardNo" type="text" readonly="readonly"/></td>
			<td class="tableleft">卡内余额：</td>
			<td class="tableright">
				<input name="offlineRechargeCardAmt" data-options="required:true,invalidMessage:'请读卡以获取卡内余额信息',missingMessage:'请读卡以获取卡内余额信息'" class="textinput easyui-validatebox" id="offlineRechargeCardAmt" type="text" readonly="readonly"/>
				<shiro:hasPermission name="OfflineRechargeReadCard">
					<a  data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0)" class="easyui-linkbutton" onclick="readOfflieRechargeCard()">读&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;卡&nbsp;</a>
				</shiro:hasPermission>
			</td>
		</tr>
		<tr>
			<td class="tableleft">充值金额：</td>
			<td class="tableright"><input id="offlineRechargeAmt" type="text" class="textinput easyui-validatebox" required="required" name="offlineRechargeAmt" maxlength="5"/></td>
			<td class="tableleft">确定充值金额：</td>
			<td class="tableright">
				<input id="offlineRechargeConfirmAmt" type="text" class="textinput easyui-validatebox" required="required" name="offlineRechargeConfirmAmt" maxlength="5"/>
				<shiro:hasPermission name="OfflineRechargeSave">
					<a  data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="offlineRecharge()">确定充值</a>
			    </shiro:hasPermission>
			</td>
		</tr>
	</table>
</form>