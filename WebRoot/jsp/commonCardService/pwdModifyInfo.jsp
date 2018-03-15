<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<script type="text/javascript">
	var globalcurreadmodifycardno = "";
	var nums = "";
	function initplainpwd(type){
		$.messager.progress({text:"正在获取密码信息，请稍后...."});
		if(type == "00"){
			$("#oldServicePwd").val(getPlaintextPwd());
		}else if(type == "01"){
			$("#servicePwd").val(getPlaintextPwd());
			$("#serviceConfirmPwd").val(getPlaintextEnsurePwd());
		}else if(type == "10"){
			var row = $cardInfoGrid.datagrid("getSelected");
			if(row){
				globalcurreadmodifycardno = row.CARD_NO;
				$("#oldPayPwd").val(getEnPin(1,row.CARD_NO));
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","请勾选一条将要进行密码修改的卡片记录！","error");
			}
		}else if(type == "11"){
			var row = $cardInfoGrid.datagrid("getSelected");
			if(row){
				if(globalcurreadmodifycardno != "" && globalcurreadmodifycardno != row.CARD_NO){
					$.messager.progress("close");
					jAlert("选择卡信息发生变化，请重新输入原始密码！");
					return;
				}
				$("#payPwd").val(getEnPin(1,row.CARD_NO));
				$("#payConfirmPwd").val(getEnPin(2,row.CARD_NO));
			}else{
				$.messager.progress("close");
				$.messager.alert("系统消息","请勾选一条将要进行密码修改的卡片记录！","error");
			}
		}else if(type == "20"){
			$("#oldSbPwd").val(getPlaintextPwd());
		}else if(type == "21"){
			$("#sbPwd").val(getPlaintextPwd());
			$("#sbConfirmPwd").val(getPlaintextEnsurePwd());
		}
		$.messager.progress("close");
	}

	function modifypwd(type){
		if(type == "0"){
			if($("#personalInfoCustomerId").val() == ""){
				$.messager.alert("系统消息", "请先进行客户信息查询再进行密码修改！", "error");
				return;
			}
			var oldServicePwd = dealNull($("#oldServicePwd").val());
			var servicePwd = dealNull($("#servicePwd").val());
			var serviceConfirmPwd = $("#serviceConfirmPwd").val();
			if(oldServicePwd == ""){
				$.messager.alert("系统消息", "请输入原始服务密码！", "error");
				return;
			}
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
				$.messager.alert("系统消息","客户状态不正常，无法进行服务密码修改！","error");
				return;
			}
			$.messager.confirm("系统消息","您确定要修改【" + $("#personalInfoName").val() + "】的服务密码吗？",function(e){
				if(e){
					$.messager.progress({text:"数据处理中，请稍后...."});
					$.post("pwdservice/pwdserviceAction!saveServicePwd.action",{
						"oldPwd": oldServicePwd,
						"pwd": servicePwd,
						"confirmPwd": serviceConfirmPwd,
						"certNo": $("#personalInfoCertNo").val()
					},function(data,status){
						$.messager.progress("close");
						if(status == "success"){
							$.messager.alert("系统消息",data.message,(data.status ? "info" :"error"),function(){
								if(data.status){
									showReport("服务密码修改",data.dealNo,function(){
										$("#oldServicePwd").val("");
										$("#servicePwd").val("");
										$("#serviceConfirmPwd").val("");
									});
								}
							});
						}else{
							$.messager.alert("系统消息","服务密码修改失败，请重新进行操作！","error");
						}
					},"json");
				}
			});
		}else if(type == "1"){
			var rows = $cardInfoGrid.datagrid("getRows");
			if(rows.length == 0) {
				$.messager.alert("系统消息", "请先进行读卡再进行密码修改！", "error");
				return;
			}
			var rows = $cardInfoGrid.datagrid("getChecked");
			if (rows.length != 1) {
				$.messager.alert("系统消息", "请选择要修改交易密码的卡号！", "error");
				return;
			}
			var oldPayPwd = $("#oldPayPwd").val();
			var payPwd = $("#payPwd").val();
			var payConfirmPwd = $("#payConfirmPwd").val();
			if(oldPayPwd == ""){
				$.messager.alert("系统消息", "请输入原始交易密码！", "error");
				return;
			}
			if(payPwd == ""){
				$.messager.alert("系统消息", "请输入新交易密码！", "error");
				return;
			}
			if(payConfirmPwd == ""){
				$.messager.alert("系统消息", "请再次输入新交易密码！", "error");
				return;
			}
			if(payPwd != payConfirmPwd){
				$.messager.alert("系统消息", "新交易密码与确认交易密码不一致！请重新输入！", "error");
				return;
			}
			$.messager.confirm("系统消息","您确定要修改卡号为【" + rows[0].CARD_NO + "】的交易密码吗？",function(e){
				if(e){
					$.messager.progress({text : "数据处理中，请稍后...."});
					$.post("pwdservice/pwdserviceAction!savePayPwdModify.action",{
							"oldPwd": oldPayPwd,
							"pwd": payPwd,
							"cardNo": rows[0].CARD_NO
						},function(data,status){
							$.messager.progress("close");
							if(status == "success"){
								if(data.status == "0"){
									jAlert("交易密码修改成功！","info",function(){
										showReport("交易密码修改",data.dealNo,function(){
											$("#oldPayPwd").val("");
											$("#payPwd").val("");
											$("#payConfirmPwd").val("");
										});
									});
								}else{
									$.messager.alert("系统消息",data.msg,"error");
								}
							}else{
								$.messager.alert("系统消息","交易密码修改失败！","error");
							}
					},"json");
				}
			});
		}else if(type == "2"){
			var rows = $cardInfoGrid.datagrid("getRows");
			if(rows.length == 0) {
				$.messager.alert("系统消息", "请先进行读卡再进行密码修改！", "error");
				return;
			}
			rows = $cardInfoGrid.datagrid("getChecked");
			if (rows.length != 1) {
				$.messager.alert("系统消息", "请选择要修改社保密码的卡号！", "error");
				return;
			}
			var oldSbPwd = dealNull($("#oldSbPwd").val());
			var sbPwd = dealNull($("#sbPwd").val());
			var sbConfirmPwd = dealNull($("#sbConfirmPwd").val());
			if(oldSbPwd == ""){
				$.messager.alert("系统消息", "请输入原始社保密码！", "error");
				return;
			}
			if(sbPwd == ""){
				$.messager.alert("系统消息", "请输入新社保密码！", "error");
				return;
			}
			if(sbConfirmPwd == ""){
				$.messager.alert("系统消息", "请再次输入新社保密码！", "error");
				return;
			}
			if(sbPwd != sbConfirmPwd){
				$.messager.alert("系统消息", "新社保密码与确认社保密码不一致！请重新输入！", "error");
				return;
			}
			$.messager.confirm("系统消息","您确定要修改卡号为【" + rows[0].CARD_NO + "】的社保密码吗？",function(e){
				if(e){
					$.messager.progress({text:"正在修改密码，请不要取走卡片..."});
					if(!modifyTouchPwd2(oldSbPwd,sbPwd)){
						$("#oldSbPwd").val("");
						$("#sbPwd").val("");
						$("#sbConfirmPwd").val("");
						$.messager.progress("close");
						return;
					}
					$.messager.progress("close");
					$.post("pwdservice/pwdserviceAction!saveSbPwd.action",{
						"cardNo": rows[0].CARD_NO,
						"pwd": sbPwd
					},function(data,status){
						//$.messager.progress("close");
						if(data.status == "0"){
							$.messager.alert("系统消息",data.message, "info",function(){
								showReport("社保密码修改",data.dealNo,function(){
									$("#oldSbPwd").val("");
									$("#sbPwd").val("");
									$("#sbConfirmPwd").val("");
								});
							});
						}else{
							$.messager.alert("系统消息",data.message,"error");
						}
					},"json");
				}
			});
		}
	}
	function judgeTouchPwd2(pwd){
		try{
			var isOpenPortOk = openTouchPort();
			if(!isOpenPortOk){
				nums = 0;
				return false;
			}
			if(dealNull(pwd).length != 6 || typeof(pwd) != "string"){
				$.messager.alert("系统消息","输入密码长度不正确！","error");
				nums = 0;
				return false;
			}
			CardCtl.CardTouchPINVerify(pwd);
			if(CardCtl.Status == 0){
				nums = 0;
				return true;
			}else{
				//$.messager.alert("系统消息", cardgeterrmessage(CardCtl.Status), "error");
				if(CardCtl.Status == -200069){
					nums = 5;
				}if(CardCtl.Status == -200070){
					nums = 4;
				}if(CardCtl.Status == -200071){
					nums = 3;
				}if(CardCtl.Status == -200072){
					nums = 2;
				}if(CardCtl.Status == -200073){
					nums = 1;
				}if(CardCtl.Status == -200074){
					nums = 6;
				}else{
					nums = 0;
					$.messager.alert("系统消息",cardgeterrmessage(CardCtl.Status),"error");
				}
				if(nums != 0){
					$.messager.alert("系统消息","原密码不正确，已输入错误次数：" + nums,"error");
				}
				return false;
			}
		}catch(e){
			nums = 0;
			errMsg = "";
			for (i in e) {
				errMsg += i + ":" + eval("e." + i) + "<br/>";
			}
			if(dealNull(errorsMsg) == ""){
				errMsg = e.toString();
			}
			jAlert(errMsg);
			return false;
		}finally {
			closeTouchPort();
		}
	}
</script>
<div>
	<div style="margin-bottom: 20px;">
		<h3 class="subtitle">服务密码修改</h3>
		<table style="width:100%;" class="tablegrid">
			<tr>
			 	<th class="tableleft">原始密码：</th>
			 	<td class="tableright">
					<input id="oldServicePwd" type="password" class="textinput" name="oldPwd" maxlength="6" readonly="readonly"/>
					<a data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="initplainpwd('00')">密码输入</a>
			 	</td>
			 	<th class="tableleft">新密码：</th>
				<td class="tableright"><input id="servicePwd" type="password" class="textinput" name="pwd"  maxlength="6" readonly="readonly"/></td>
				<th class="tableleft">确认密码：</th>
				<td class="tableright"><input id="serviceConfirmPwd" name="confirmPwd" class="textinput"  type="password" maxlength="6" readonly="readonly"/></td>
				<td style="text-align:center;">
					<a data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="initplainpwd('01')">密码输入</a>
					<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="modifypwd('0')">修改密码</a>
				</td>
			</tr>
		</table>
	</div>
	<div style="margin-bottom: 20px;">
		<h3 class="subtitle">交易密码修改</h3>
		<table style="width:100%;" class="tablegrid">
			<tr>
			 	<th class="tableleft">原始密码：</th>
			 	<td class="tableright">
					<input id="oldPayPwd" type="password" class="textinput" name="oldPwd" maxlength="6" readonly="readonly"/>
					<a data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="initplainpwd('10')">密码输入</a>
			 	</td>
			 	<th class="tableleft">新密码：</th>
				<td class="tableright"><input id="payPwd" type="password" class="textinput" name="pwd"  maxlength="6" readonly="readonly"/></td>
				<th class="tableleft">确认密码：</th>
				<td class="tableright"><input name="confirmPwd" class="textinput" id="payConfirmPwd" type="password" maxlength="6" readonly="readonly"/></td>
				<td style="text-align:center;">
					<a data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="initplainpwd('11')">密码输入</a>
					<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="modifypwd('1')">修改密码</a>
				</td>
			</tr>
		</table>
	</div>
	<div style="margin-bottom: 20px;display: none;">
		<h3 class="subtitle">医保密码修改</h3>
		<table style="width:100%;" class="tablegrid">
			<tr>
			 	<th class="tableleft">原始密码：</th>
			 	<td class="tableright">
					<input id="oldSbPwd" type="password" class="textinput" name="oldPwd" maxlength="6" readonly="readonly"/>
					<a data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="initplainpwd('20')">密码输入</a>
			 	</td>
			 	<th class="tableleft">新密码：</th>
				<td class="tableright"><input id="sbPwd" type="password" class="textinput" name="pwd"  maxlength="6" readonly="readonly"/></td>
				<th class="tableleft">确认密码：</th>
				<td class="tableright"><input id="sbConfirmPwd"  name="confirmPwd" class="textinput"  type="password" maxlength="6" readonly="readonly"/></td>
				<td style="text-align:center;">
					<a data-options="plain:false,iconCls:'icon-pwdbtn'" href="javascript:void(0);" class="easyui-linkbutton"  onclick="initplainpwd('21')">密码输入</a>
					<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-save'" href="javascript:void(0);" class="easyui-linkbutton" onclick="modifypwd('2')">修改密码</a>
				</td>
			</tr>
		</table>
	</div>
</div>