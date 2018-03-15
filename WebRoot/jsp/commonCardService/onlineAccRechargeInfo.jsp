<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
	$(function(){
		$.addRbmReg("onlineRechargeAmt");
		$.addRbmReg("onlineRechargeConfirmAmt");
	});
	function saveOnlineRechargeInfo(){
		var rows = $cardInfoGrid.datagrid("getChecked");
		if(rows && rows.length == 1){
			if(rows[0].CARD_STATE != "1"){
				$.messager.alert("系统消息","当前卡片状态不正常，不能进行${ACC_KIND_NAME_LJ }进行充值！","error");
				return;
			}
			if($("#onlineRechargeAmt").val().replace(/\s/g,"") == ""){
				$.messager.alert("系统消息","请输入${ACC_KIND_NAME_LJ }充值金额！","error",function(){
					$("#onlineRechargeAmt").focus();
				});
				return;
			}
			if($("#onlineRechargeConfirmAmt").val() == ""){
				$.messager.alert("系统消息","请输入${ACC_KIND_NAME_LJ }确认充值金额！","error",function(){
					$("#onlineRechargeConfirmAmt").focus();
				});
				return;
			}
			var exp = /^\d+(\.?\d{1,2})?$/g;
			if(!exp.test($("#onlineRechargeAmt").val())){
				$.messager.alert("系统消息","充值金额格式不正确，请重新输入！","error",function(){
					$("#onlineRechargeAmt").val("");
					$("#onlineRechargeAmt").focus();
				});
				return;
			}
			if(isNaN($("#onlineRechargeAmt").val())){
				$.messager.alert("系统消息","充值金额格式不正确，请重新进行输入！","error",function(){
					$("#onlineRechargeAmt").val("");
					$("#onlineRechargeAmt").focus();
				});
				return;
			}
			if($("#onlineRechargeAmt").val() != $("#onlineRechargeConfirmAmt").val()){
				$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }充值金额和确认充值金额不一致，请重新输入！","error",function(){
					$("#onlineRechargeAmt").val("");
					$("#onlineRechargeAmt").focus();
				});
				return;
			}
			if(parseFloat($("#onlineRechargeAmt").val()) <= 0){
				$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }充值金额必须大于0！","error",function(){
					$("#onlineRechargeAmt").val("");
					$("#onlineRechargeAmt").focus();
				});
				return;
			}
			$.messager.confirm("系统消息","您确定要为卡号为【" + rows[0].CARD_NO + "】的卡片充值<" + $("#onlineRechargeAmt").val() + ">元？", function(is) {
				if(is){
					$.messager.progress({text : "正在进行充值，请稍后...."});
					$.post("recharge/rechargeAction!saveOnlineAccountR.action",{cardNo:rows[0].CARD_NO,amt:$("#onlineRechargeAmt").val()},function(data,status){
						if(status == "success"){
							if(data.status != "0"){
								$.messager.progress("close");
								$.messager.alert("系统消息",data.msg,"error");
							}else if(data.status == "0"){
								$.messager.progress("close");
								if(data.isReminder == "0") {
									$.messager.alert("系统消息",data.reminderMsg,"info",function(){
										showReport("${ACC_KIND_NAME_LJ }充值",data.dealNo);
										$accInfoGrid.datagrid("load",{cardNo:rows[0].CARD_NO,queryType:"0"});
										$("#onlineRechargeInfo").form("reset");
									});
								} else {
									showReport("${ACC_KIND_NAME_LJ }充值",data.dealNo);
									$accInfoGrid.datagrid("load",{cardNo:rows[0].CARD_NO,queryType:"0"});
									$("#onlineRechargeInfo").form("reset");
								}
							}
						}else{
							$.messager.progress("close");
							$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }充值请求出现错误，请重试！","error");
						}
					},"json").error(function(){
						$.messager.progress("close");
						$.messager.alert("系统消息","${ACC_KIND_NAME_LJ }充值请求出现错误，请重试！","error");
					});
				}
			});
		}else{
			$.messager.alert("系统消息","请勾选一条卡记录信息进行充值！","error");
		}
	}
</script>
<h3 class="subtitle">${ACC_KIND_NAME_LJ }充值</h3>
<form id="onlineRechargeInfo">
	<table class="tablegrid" style="width:600px;margin: 30px auto 0 auto;">
		<tr>
			<td class="tableleft">充值金额：</td>
			<td class="tableright"><input id="onlineRechargeAmt" name="onlineRechargeAmt" class="textinput easyui-validatebox"  type="text" required="required" maxlength="5"/></td>
			<td class="tableleft">确认充值金额：</td>
			<td class="tableright"><input id="onlineRechargeConfirmAmt" name="onlineRechargeConfirmAmt" type="text" required="required" class="textinput easyui-validatebox" maxlength="5"/></td>
			<td class="tableright" colspan="1">
				<a data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="saveOnlineRechargeInfo()">确定充值</a>
			</td>
		</tr>
	</table>
</form>