<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<script type="text/javascript">
	$(function() {
		addNumberValidById("bankCardNo2");
		addNumberValidById("mobileNum2");
		
		$.extend($.fn.validatebox.defaults.rules, {
		    bankCardNo: {
		        validator: function(value){
		        	var reg = /\d{19}/g;
		            return value.length == 19 && reg.test(value);
		        },
		        message: '银行卡号格式不正确.'
		    },
		    mobileNo: {
		    	validator: function(value, param){
		    		var reg = /1[358]\d{9}/g;
		            return value.length == 11 && reg.test(value);
		        },
		        message: '手机号码格式不正确.'
		    }
		});  
		
		$("#bankId2").combobox({
			url:"cardService/cardBindBankCardAction!getCurrentBrchBanks.action",
			valueField:"bankId",
			textField:"bankName",
			panelHeight: '200',
			loadFilter:function(data){
				return data.rows;
			}
		});
		
		$("#form2").form({
			onSubmit : function() {
				$.messager.progress({
					text:"数据处理中, 请稍候..."
				})
			},
			success : function(data) {
				$.messager.progress("close")
				
				var info = JSON.parse(data);

				if (info.status == "1") {
					$.messager.alert("消息提示", info.errMsg, "error");
				} else {
					$.messager.alert("消息提示", "验证通过", "info");
				}
			}
		});
	})

	function save2() {
		if($("#bankId2").combobox("getValue") == ""){
			$.messager.alert("系统消息", "银行不能为空", "warning", function(){
				$("#bankId2").combobox("showPanel");
			});
			return false;
		}
		
		if($("#form2").form("validate")){
			$.messager.confirm("消息提示", "确认绑定？", function(e){
				if(e){
					$("#form2").form("submit", {
						url:"cardService/cardBindBankCardAction!cardBindBankCard.action",
						success : function(data) {
							$.messager.progress("close");
						
							var info = JSON.parse(data);
		
							if (info.status == "1") {
								$.messager.alert("消息提示", info.errMsg, "error");
							} else {
									$.messager.alert("消息提示", "操作成功", "info", function(){
									$.modalDialog.handler.dialog('destroy');
									$.modalDialog.handler = undefined;
									query();
								});
							}
						}
					});
				}
			});
		}
	}
	
	function valid2(){
		$("#form2").form("submit", {
			url:"cardService/cardBindBankCardAction!validCardBindBankCard.action",
			onSubmit:function(){
				if($("#bankId2").combobox("getValue") == ""){
					$.messager.alert("系统消息", "银行不能为空", "warning", function(){
						$("#bankId2").combobox("showPanel");
					});
					return false;
				}
				
				if(!$("#bankCardNo2").val()){
					$.messager.alert("系统消息", "银行卡号不能为空", "warning", function(){
						$("#bankCardNo2").focus();
					});
					return false;
				} /* else if ($("#bankCardNo2").val().length != 19 || !/\d{19}/g.test($("#bankCardNo2").val())){
					$.messager.alert("系统消息", "银行卡号格式不正确", "warning", function(){
						$("#bankCardNo2").focus();
					});
					return false;
				} */
				
				$.messager.progress({
					text:"数据处理中, 请稍候..."
				})
			}
		});
	}
</script>
<div class="easyui-layout" data-options="fit:true">
	<div data-options="region:'center',border:false"
		style="overflow: hidden; padding: 0px;" class="datagrid-toolbar">
		<form id="form2" method="post">
			<table class="tablegrid" style="width: 100%">
				<tbody>
					<tr>
						<td colspan="6">
							<h3 class="subtitle">绑定银行卡信息</h3>
						</td>
					</tr>
					<tr>
						<th class="tableleft">姓名：</th>
						<td class="tableright"><input id="name2" name="bindInfo.name"
							class="textinput easyui-validatebox" data-options="required:true"
							style="background: rgb(235, 235, 228);" readonly="readonly"
							value="${person.name}" /></td>
						<th class="tableleft">身份证号：</th>
						<td class="tableright"><input id="certNo3"
							name="bindInfo.id.certNo" class="textinput easyui-validatebox"
							data-options="required:true"
							style="background: rgb(235, 235, 228);" readonly="readonly"
							value="${person.certNo}" /></td>
						<th class="tableleft">社保卡号：</th>
						<td class="tableright"><input id="subCardNo2"
							class="textinput easyui-validatebox" data-options="required:true"
							style="background: rgb(235, 235, 228);" readonly="readonly"
							name="bindInfo.id.subCardNo" value="${card.subCardNo}" /></td>
					</tr>
					<tr>
						<th class="tableleft">银行编号：</th>
						<td class="tableright"><input id="bankId2"
							class="textinput" name="bindInfo.bankId" /></td>
						<th class="tableleft">银行卡号：</th>
						<td class="tableright"><input id="bankCardNo2"
							name="bindInfo.bankCardNo" class="textinput easyui-validatebox"
							data-options="required:true" /></td>
						<th class="tableleft">联行号：</th>
						<td class="tableright">
							<input id="lineNo2" name="bindInfo.lineNo" class="textinput" placeholder="仅当外地银行时填写"/>
							<a href="javascript:void(0);" class="easyui-linkbutton"
								iconCls="icon-checkInfo" onclick="valid2()">验证</a>
						</td>
					</tr>
					<tr>
						<td colspan="6">
							<h3 class="subtitle">客户信息</h3>
						</td>
					</tr>
					<tr>
						<th class="tableleft">客户编号：</th>
						<td class="tableright"><input id="customerId2"
							class="textinput" style="background: rgb(235, 235, 228);"
							readonly="readonly" value="${person.customerId}" /></td>
						<th class="tableleft">市民卡号：</th>
						<td class="tableright"><input id="cardNo2" class="textinput"
							style="background: rgb(235, 235, 228);" readonly="readonly"
							value="${card.cardNo}" /></td>
						<th class="tableleft">手机号码：</th>
						<td class="tableright"><input id="mobileNum2"
							class="textinput easyui-validatebox" name="bindInfo.mobileNum"
							data-options="required:true"
							value="${person.mobileNo}" /></td>
					</tr>
					<tr>
						<th class="tableleft">联系地址：</th>
						<td class="tableright" colspan="5"><input id="address2"
							name="bindInfo.address" style="width: 84.5%" 
							class="textinput easyui-validatebox"
							data-options="required:true"
							value="${person.letterAddr}" /></td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
</div>