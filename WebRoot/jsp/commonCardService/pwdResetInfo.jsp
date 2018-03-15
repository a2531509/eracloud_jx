<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
	function initplainpwd2(type){
		$.messager.progress({text:"正在获取密码信息，请稍后...."});
		if(type == "01"){
			$("#servicePwd2").val(getPlaintextPwd());
			$("#serviceConfirmPwd2").val(getPlaintextEnsurePwd());
		}else if(type == "11"){
			var rows = $cardInfoGrid.datagrid("getChecked");
			if(rows && rows.length == 1){
				if(dealNull(rows[0].CARD_NO) == ""){
					jAlert("卡号为空，无法读取密码！","warning");
					$.messager.progress("close");
					return;
				}
				if(dealNull(rows[0].CARD_NO).length < 20){
					jAlert("勾选记录的卡号的位数不正确！","warning");
					$.messager.progress("close");
					return;
				}
				$("#payPwd2").val(getEnPin(1,rows[0].CARD_NO));
				$("#payConfirmPwd2").val(getEnPin(2,rows[0].CARD_NO));
			}else{
				jAlert("请勾选一条将要进行交易密码修改的卡记录信息！","warning");
				$.messager.progress("close");
				return;
			}
		}else if(type == "21"){
			$("#sbPwd2").val(getPlaintextPwd());
			$("#sbConfirmPwd2").val(getPlaintextEnsurePwd());
		}
		$.messager.progress("close");
	}
	function resetpwd(type){
		if(type == "0"){
			if($("#personalInfoCustomerId").val() == ""){
				$.messager.alert("系统消息", "请先进行客户信息查询再进行密码重置！", "error");
				return;
			}
			var servicePwd = dealNull($("#servicePwd2").val());
			var serviceConfirmPwd = dealNull($("#serviceConfirmPwd2").val());
			if(servicePwd == ""){
				$.messager.alert("系统消息", "请输入新服务密码！", "error");
				return;
			}
			if(serviceConfirmPwd == ""){
				$.messager.alert("系统消息", "请再次输入新服务密码！", "error");
				return;
			}
			if(servicePwd != serviceConfirmPwd){
				$.messager.alert("系统消息", "新服务密码与确认服务密码不一致！请重新输入！", "error");
				return;
			}
			if($("#personalInfoCustomerState").combobox("getValue") != "0"){
				$.messager.alert("系统消息","客户状态不正常，无法进行服务密码重置！","error");
				return;
			}
			$.messager.confirm("系统消息","您确定要重置【" + $("#personalInfoName").val() + "】的服务密码吗？",function(e){
				if(e){
					$.messager.progress({text:"数据处理中，请稍后...."});
					$.post("pwdservice/pwdserviceAction!saveServicePwdReset.action",{
						"pwd": servicePwd,
						"confirmPwd": serviceConfirmPwd,
						"certNo": $("#personalInfoCertNo").val()
					},function(data,status){
						$.messager.progress("close");
						if(status == "success"){
							$.messager.alert("系统消息",data.message,(data.status ? "info" :"error"),function(){
								if(data.status){
									showReport("服务密码重置",data.dealNo,function(){
										$("#servicePwd2").val("");
										$("#serviceConfirmPwd2").val("");
									});
								}
							});
						}else{
							$.messager.alert("系统消息","服务密码重置失败，请重新进行操作！","error");
						}
					},"json");
				}
			});
		}else if(type == "1"){
			var rows = $cardInfoGrid.datagrid("getRows");
			if(rows.length == 0) {
				$.messager.alert("系统消息", "请先进行读卡再进行密码重置！", "error");
				return;
			}
			rows = $cardInfoGrid.datagrid("getChecked");
			if (rows.length != 1) {
				$.messager.alert("系统消息", "请勾选要重置交易密码的卡片信息！", "error");
				return;
			}
			var payPwd = $("#payPwd2").val();
			var payConfirmPwd = $("#payConfirmPwd2").val();
			if(payPwd == ""){
				$.messager.alert("系统消息","请输入新交易密码！","error");
				return;
			}
			if(payConfirmPwd == ""){
				$.messager.alert("系统消息","请再次输入新交易密码！","error");
				return;
			}
			if(payPwd != payConfirmPwd){
				$.messager.alert("系统消息","新交易密码与确认交易密码不一致！请重新输入！","error");
				return;
			}
			$.messager.confirm("系统消息","您确定要重置卡号为【" + rows[0].CARD_NO + "】的交易密码吗？",function(e){
				if (e) {
					$.messager.progress({text : "数据处理中，请稍后...."});
					$.post("pwdservice/pwdserviceAction!savePayPwdReset.action",{
						"pwd": payPwd,
						"cardNo": rows[0].CARD_NO
					},function(data,status){
						$.messager.progress("close");
						if(status == "success"){
							if(data.status == "0"){
								jAlert("交易密码重置成功！","info",function(){
									showReport("交易密码重置",data.dealNo,function(){
										$("#payPwd2").val("");
										$("#payConfirmPwd2").val("");
									});
								})
							}else{
								$.messager.alert("系统消息",data.msg,"error");
							}
						}else{
							$.messager.alert("系统消息","交易密码重置失败！","error");
						}
					},"json");
				}
			});
		}else if(type == "2"){
			var rows = $cardInfoGrid.datagrid("getRows");
			if(rows.length == 0) {
				$.messager.alert("系统消息", "请先进行读卡再进行密码重置！", "error");
				return;
			}
			var rows = $cardInfoGrid.datagrid("getChecked");
			if (rows.length != 1) {
				$.messager.alert("系统消息", "请选择要重置社保密码的卡号！", "error");
				return;
			}
			var sbPwd = dealNull($("#sbPwd2").val());
			var sbConfirmPwd = dealNull($("#sbConfirmPwd2").val());
			if(sbPwd == ""){
				$.messager.alert("系统消息", "请输入新社保密码！","error");
				return;
			}
			if(sbConfirmPwd == ""){
				$.messager.alert("系统消息", "请再次输入新社保密码！","error");
				return;
			}
			if(sbPwd != sbConfirmPwd){
				$.messager.alert("系统消息", "新社保密码与确认社保密码不一致！请重新输入！","error");
				return;
			}
			$.messager.confirm("系统消息","您确定要重置卡号为【" + rows[0].SUB_CARD_NO + "】的社保密码吗？",function(e){
				if(e){
					$.messager.progress({text:"正在重置密码，请不要取走卡片..."});
					if(!reSetTouchPwd(sbPwd)){
						$.messager.progress("close");
						return;
					}
					$.messager.progress("close");
					$.messager.progress({text:"密码重置成功, 正在同步业务日志. .."});
					$.post("pwdservice/pwdserviceAction!sbPwdReset.action",{
						"pwd": sbPwd,
						"cardNo": rows[0].CARD_NO
					},function(data,status){
						$.messager.progress("close");
						if(data.status == "0"){
							$.messager.alert("系统消息","重置密码成功", "info",function(){
								showReport("社保密码重置",data.dealNo,function(){
									$("#sbPwd2").val("");
									$("#sbConfirmPwd2").val("");
								});
							});
						}else{
							$.messager.alert("系统消息",data.msg,"error");
						}
					},"json");
				}
			});
		}
	}
</script>
<div>
	<div style="margin-bottom: 20px;">
		<h3 class="subtitle">服务密码重置</h3>
		<table style="width:100%;" class="tablegrid">
			<tr>
			 	<th class="tableleft">新密码：</th>
				<td class="tableright"><input id="servicePwd2" type="password" class="textinput" name="servicePwd2"  maxlength="6" readonly="readonly"/></td>
				<th class="tableleft">确认密码：</th>
				<td class="tableright"><input id="serviceConfirmPwd2" name="serviceConfirmPwd2" class="textinput" type="password" maxlength="6" readonly="readonly"/></td>
				<td style="text-align:center;">
					<a data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="initplainpwd2('01')">密码输入</a>
					<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="resetpwd('0')">重置密码</a>
				</td>
			</tr>
		</table>
	</div>
	<div style="margin-bottom: 20px;">
		<h3 class="subtitle">交易密码重置</h3>
		<table style="width:100%;" class="tablegrid">
			<tr>
			 	<th class="tableleft">新密码：</th>
				<td class="tableright"><input id="payPwd2" type="password" class="textinput" name="payPwd2"  maxlength="6" readonly="readonly"/></td>
				<th class="tableleft">确认密码：</th>
				<td class="tableright"><input id="payConfirmPwd2" name="payConfirmPwd2" class="textinput" type="password" maxlength="6" readonly="readonly"/></td>
				<td style="text-align:center;">
					<a data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="initplainpwd2('11')">密码输入</a>
					<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="resetpwd('1')">重置密码</a>
				</td>
			</tr>
		</table>
	</div>
	<div style="margin-bottom: 20px;display: none;">
		<h3 class="subtitle">医保密码重置</h3>
		<table style="width:100%;" class="tablegrid">
			<tr>
			 	<th class="tableleft">新密码：</th>
				<td class="tableright"><input id="sbPwd2" type="password" class="textinput" name="sbPwd2"  maxlength="6" readonly="readonly"/></td>
				<th class="tableleft">确认密码：</th>
				<td class="tableright"><input id="sbConfirmPwd2"  name="sbConfirmPwd2" class="textinput" type="password" maxlength="6" readonly="readonly"/></td>
				<td style="text-align:center;">
					<a data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="initplainpwd2('21')">密码输入</a>
					<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="resetpwd('2')">重置密码</a>
				</td>
			</tr>
		</table>
	</div>
</div>